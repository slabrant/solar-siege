# Systems Overview

This document covers cross-system architecture: autoloads, the scene tree, signal flow between systems, and project-wide conventions. Individual system implementation lives in its own file.

---

## Project

**Engine:** Godot 4.6.2
**Physics:** Jolt Physics
**Rendering:** Forward Plus / D3D12 (Windows)
**Multiplayer:** ENet, up to 4 players

---

## Autoloads

| Autoload             | Responsibility                                        | Doc            |
|----------------------|-------------------------------------------------------|----------------|
| `SolarCycle`         | Time of day, solar strength, phase signals            | SolarCycle.md  |
| `JobBoard`           | Global task registry and assignment                   | JobBoard.md    |
| `MultiplayerManager` | Server/client connection                              | Multiplayer.md |
| `PossessionManager`  | Tracks which player possesses which colonist          | Possession.md  |
| `FoodManager`        | Global food pool and nutrition state                  | Food.md        |
| `GameState`          | Global flags (`robots_awakened`, `game_over`), planet | (planned)      |
| `Balance`            | All tunable constants                                 | Balance.md     |

---

## Scene Tree

```
Main
├── Environment
│   ├── DirectionalLight3D       # sun; rotation tied to SolarCycle.current_time
│   ├── WorldEnvironment
│   └── NavigationRegion3D
├── Hubs            (group: "Hubs")
├── Colonists       (group: "Colonists")   # spawned at runtime by Hubs
├── Robots          (group: "Robots")      # spawned at dawn after awakening
├── Animals         (group: "Animals")     # ambient wildlife
├── Structures      (towers, hunting towers, processing/production buildings, walls)
├── Transport       (railcars, conveyor belts, rail tracks)
├── ResourcePiles   (group: "ResourcePiles")
└── Cameras         (one StrategicCamera per player, local only)
```

---

## Signal Flow

```
SolarCycle.phase_changed(DayPhase.NIGHT)
    → Robot._on_phase_changed()        # freeze
    → GameState                        # night events

SolarCycle.phase_changed(DayPhase.DAY)
    → Robot._on_phase_changed()        # thaw
    → GameState                        # spawn wave if robots_awakened

JobBoard.jobs_updated
    → Colonist._on_jobs_updated()      # all non-force-tasked colonists re-evaluate

Colonist.colonist_died
    → PossessionManager                # unpossess if possessed
    → GameState._check_game_over()

Robot.robot_died
    → spawns ResourcePile at position
    → JobBoard auto-posts HAULING job

Structure.structure_destroyed (Hub variant)
    → drops ResourcePile with full buffer
    → GameState._check_game_over()

FoodManager.nutrition_changed(HUNGRY)
    → Hub blocks new spawn queue requests

PossessionManager.possession_changed
    → Colonist camera switch
    → InputManager remap
```

---

## Game Over

The colony is lost when there are no Hubs and no Colonists. Either alone is enough to continue.

```gdscript
# GameState (autoload)
func _check_game_over() -> void:
    var colonists = get_tree().get_nodes_in_group("Colonists").size()
    var hubs      = get_tree().get_nodes_in_group("Hubs").size()
    if colonists == 0 and hubs == 0:
        game_over.emit()
```

`_check_game_over()` is connected to `Colonist.colonist_died` and `Structure.structure_destroyed` (Hub variant).

---

## Conventions

- All tunable constants live in `Balance.gd` (see Balance.md). System docs reference by name with `# see Balance.md`.
- Godot groups used: `"Hubs"`, `"Colonists"`, `"Robots"`, `"Animals"`, `"ResourcePiles"`.
- Resource type strings: `"Ammo"`, `"Stone"`, `"Metal"`, `"Lumber"`, `"Scrap"`, `"ShinyScrap"`, `"Solite"`, `"Iridium"`, `"Food"`, `"BuildingMaterials"`, `"Components"`.
- Field strings: `"Engineering"`, `"Gunnery"`, `"Harvesting"`.
- All structures inherit from `Structure` (see Structure.md) — they share construction, damage, destruction, and withdrawal contracts.
- `GameState.robots_awakened` gates all robot spawning; flips to `true` the first time a robot is dismantled.
