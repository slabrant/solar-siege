# The Solar Siege — Technical Design Document

**Engine:** Godot 4.6.2
**Physics:** Jolt Physics
**Rendering:** Forward Plus / D3D12 (Windows)
**Multiplayer:** ENet, max 4 players

For system-level implementation detail, see the relevant file in SYSTEMS/. This document covers architecture, cross-system connections, and conventions only.

---

## Autoloaded Singletons

| Singleton | Responsibility | System Doc |
|---|---|---|
| `SolarCycle` | Time of day, solar strength, phase signals | SYSTEMS/SolarCycle.md |
| `JobBoard` | Global task registry and assignment | SYSTEMS/JobBoard.md |
| `MultiplayerManager` | Server/client connection | SYSTEMS/Multiplayer.md |
| `PossessionManager` | Tracks which player possesses which worker | SYSTEMS/Possession.md |
| `FoodManager` | Global food pool and nutrition state | SYSTEMS/Food.md |
| `GameState` | Global flags (e.g. `robots_awakened`); planned | — |
| `Balance` | All tunable constants | SYSTEMS/Balance.md |

---

## Scene Structure

```
Main
├── Environment
│   ├── DirectionalLight3D       # sun; rotation tied to SolarCycle.current_time
│   ├── WorldEnvironment
│   └── NavigationRegion3D       # baked nav mesh for workers and robots
├── Hubs (group: "Hubs")
│   └── Hub
│       ├── ResourceBuffer
│       └── SpawnPoint
├── Workers (group: "Workers")   # spawned at runtime by Hubs
├── Robots (group: "Robots")     # spawned at dawn after awakening
├── Structures
│   ├── Turret
│   ├── HuntingTower
│   ├── ProcessingBuilding
│   ├── ProductionBuilding
│   └── ConveyorBelt / RailTrack
└── Cameras
    └── RTSCamera (one per player, local only — not synced)
```

---

## Cross-System Signal Flow

```
SolarCycle.phase_changed(DayPhase.NIGHT)
    → Robot._on_phase_changed()     # freeze all robots
    → GameState                     # (future) trigger night events

SolarCycle.phase_changed(DayPhase.DAY)
    → Robot._on_phase_changed()     # thaw all robots
    → GameState                     # spawn wave if robots_awakened

JobBoard.jobs_updated
    → Worker._on_jobs_updated()     # all non-force-tasked workers re-evaluate

Worker.worker_died
    → PossessionManager             # unpossess if possessed
    → (worker removed from "Workers" group automatically on queue_free)

Robot._die()
    → spawns ResourcePile at position
    → emits robot_died signal
    → JobBoard                      # posts a HAULING job for the new ResourcePile
```

---

## Multiplayer Synchronization

Server is authoritative. All game state mutations go through the server.

Nodes requiring `MultiplayerSynchronizer`:

| Node | Properties |
|---|---|
| Worker | `global_position`, `current_job`, `xp`, `levels`, `specialty`, `is_possessed`, `possessing_player` |
| Robot | `global_position`, `health`, `scrap`, `is_frozen` |
| SolarCycle | `current_time`, `current_phase` |
| JobBoard | `available_jobs` |
| PossessionManager | `possessed` |
| FoodManager | `food_points`, `nutrition_state` |
| Hub / ResourceBuffer | `current` |
| ResourcePile | `global_position`, `contents`, `is_being_hauled` |

Player actions (possess, force task, place track, recall) are sent as `@rpc` calls to the server. See SYSTEMS/Multiplayer.md.

---

## Conventions

- All tunable constants are defined in `Balance.gd` (see SYSTEMS/Balance.md) and referenced by name elsewhere with a `# see Balance.md` comment
- Groups used: `"Hubs"`, `"Workers"`, `"Robots"`
- Worker XP and levels are always accessed via `worker.xp[field]` and `worker.levels[field]`
- All resource types are string keys: `"Ammo"`, `"Metal"`, `"Lumber"`, `"Scrap"`, `"ShinyScrap"`, `"Solite"`, `"Iridium"`, `"Food"`
- `GameState.robots_awakened` gates all robot spawning
