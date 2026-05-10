# The Solar Siege — Technical Design Document

**Engine:** Godot 4.6.2
**Physics:** Jolt Physics
**Rendering:** Forward Plus / D3D12 (Windows)
**Multiplayer:** ENet, max 4 players

---

## Architecture Overview

### Autoloaded Singletons

| Singleton | Responsibility |
|---|---|
| `SolarCycle` | Tracks time of day, emits phase/hour signals, exposes solar strength |
| `JobBoard` | Global task registry; handles assignment, priority, and re-assignment |
| `MultiplayerManager` | Server/client connection management |
| `PossessionManager` | Tracks which worker each player is currently possessing |

### Scene Structure (planned)

```
Main
├── Environment (sun, terrain, navigation mesh)
├── Hubs (group: "Hubs")
│   └── Hub
│       ├── ResourceBuffer
│       └── SpawnPoint
├── Workers (spawned at runtime)
├── Robots (spawned at dawn or on trigger)
├── Structures (turrets, railcars, belts, production buildings)
└── RTSCamera
```

---

## Solar Cycle

Time runs from 0.0 to 24.0 on a configurable cycle (default 600 seconds = 10 min/day).

**Day:** 6:00 – 18:00
**Night:** 18:00 – 6:00

### Solar Strength Formula

```
S = sin(θ)
θ = ((current_time - 6.0) / 12.0) * PI   # maps 6AM→0, Noon→PI/2, 6PM→PI
S = 0.0 during night
```

`get_solar_strength()` returns a float in [0.0, 1.0]. Used to scale robot movement speed and combat damage.

### Signals

```gdscript
signal hour_changed(hour: float)      # emits every frame
signal phase_changed(phase: String)   # "DAY" or "NIGHT" on transition
```

---

## Robot System

### States

```
FUNCTIONAL → (health reaches 0) → SCRAPS
FUNCTIONAL → (night begins)     → FROZEN (inoperable, still FUNCTIONAL internally)
FROZEN     → (day begins)       → FUNCTIONAL
```

Robots track two separate values: `health` and `scrap`. Only health is shown to the player.

- **Turret/combat damage** — reduces both `health` and `scrap` proportionally
- **Engineer dismantling** — reduces `health` only; `scrap` is fully preserved

This means a robot carefully dismantled at night yields full scrap, while one gunned down yields less. Scrap yield at death equals the robot's remaining `scrap` value at the moment health hits zero.

Scrap is not processed at death — it is hauled to a processing building first. Solite and Iridium are extracted there, not in the field.

### Scrap Yield on Death

```gdscript
# scrap is tracked separately from health
var scrap_dropped = current_scrap  # whatever remains after combat damage
```

Solite and Iridium yields are determined at the processing building, not at robot death.

### AI Behaviour

- Uses `NavigationAgent3D` to path toward nearest Hub
- Movement speed: `base_speed * (1.0 + SolarCycle.get_solar_strength())`
- Damage output: `base_damage * (1.0 + SolarCycle.get_solar_strength())`
- At night: `set_physics_process(false)`, frozen in place, harvestable

### Robot Awakening Trigger

Robots do not spawn or activate on game start. A global `GameState` flag `robots_awakened: bool` gates all robot activity. When the trigger fires (TBD — e.g. entering a structure), `robots_awakened` is set to `true` and the first wave spawns at the next dawn.

---

## Worker System

### Fields & XP

Each worker tracks XP independently per field:

```gdscript
var xp: Dictionary = {
    "Engineering": 0.0,
    "Gunnery": 0.0,
    "Harvesting": 0.0,
}
```

### Specialty Derivation

```gdscript
func get_specialty() -> String:
    var sorted = xp.keys()
    sorted.sort_custom(func(a, b): return xp[a] > xp[b])
    var top = xp[sorted[0]]
    var second = xp[sorted[1]]
    var third = xp[sorted[2]]

    # Dual-specialty: top two are both significantly higher than the third
    if top > 0 and second > 0 and (top + second) > 0:
        var gap_ratio = (second - third) / (top + second)
        if gap_ratio > DUAL_SPECIALTY_THRESHOLD:
            return sorted[0] + "-" + sorted[1]

    if top > 0:
        return sorted[0]

    return "Recruit"
```

`DUAL_SPECIALTY_THRESHOLD` is a tunable constant. The exact value is to be playtested.

### Skill Effect on Tasks

Skill level is a float derived from XP (curve TBD). It scales **speed only** — all workers perform all tasks.

```gdscript
func get_skill_level(field: String) -> float:
    return sqrt(xp[field] / XP_SCALE)  # placeholder curve

func get_task_speed(field: String) -> float:
    return base_speed * (1.0 + get_skill_level(field) * SPEED_SCALE)
```

For Engineering tasks only, skill also scales **resource yield** from robot salvage.

### Possession Bonus

When a worker is possessed, all task speeds and yields receive an additional flat multiplier on top of skill scaling:

```gdscript
const POSSESSION_BONUS = 1.5  # tunable
```

This applies to all fields simultaneously — possession makes the worker better at everything they do, not just their specialty.

### Worker Identity

- Name: generated when the worker first earns a specialty
- Visuals: set based on specialty (tunic → occupation-specific outfit)
- Name tags: displayed on named workers, hidden on Recruits
- Recruits have no name and no appearance distinction until specialty is reached

---

## Job Board

### Job Data

```gdscript
class_name Job extends Resource
var id: String
var type: JobType        # CONSTRUCTION, LOGISTICS, MINING, COMBAT, HUNTING, FARMING, HAULING
var priority: Priority   # LOW, MEDIUM, HIGH, CRITICAL
var location: Vector3
var required_field: String   # "Engineering", "Gunnery", "Harvesting", or "" for any
var assigned_worker: Node3D
```

### Assignment Logic

Workers call `get_best_job_for(worker)` on the board. Sorting: priority first, then proximity. `required_field` is checked — if set, only workers with XP in that field above a minimum threshold are considered qualified. Below the threshold they can still be assigned, but at a lower effective priority.

Workers re-evaluate on every `jobs_updated` signal unless `is_force_tasked`.

---

## Food & Colony Nutrition

### Nutrition State

```gdscript
enum NutritionState { HUNGRY, NORMAL, WELL_FED }
```

Food points accumulate in a global food buffer. The Well-Fed threshold scales with current workforce size:

```gdscript
var well_fed_threshold = BASE_FOOD_THRESHOLD * worker_count
var hungry_threshold = HUNGRY_FOOD_THRESHOLD * worker_count
```

Nutrition state is evaluated globally — workers don't need to be near a Hub. Buffs apply colony-wide.

### Food Sources

- **Farming** (Harvesting/Harvester-Farmer) — crops, foraging
- **Hunting** (Gunnery/Hunter) — hunted animals; shares combat mechanics

Different food items carry different food point values. Food stores are kept in a single global pool shared across all Hubs.

### Well-Fed Buff

```gdscript
# Applied to all workers when NutritionState == WELL_FED
movement_speed *= WELL_FED_SPEED_BONUS
xp_gain_rate *= WELL_FED_XP_BONUS
```

Worker production (spawning new Recruits) is gated: `NutritionState != HUNGRY`.

---

## Resource Pipeline

```
Raw Material (scrap, wood, ore, food)
    → Hauled by worker or railcar
    → Processing Building
    → Usable Parts / Materials / Solite / Iridium
    → Hauled to Hub buffer or construction site
```

### Processing Buildings

Each building type accepts specific inputs and produces specific outputs. Processing is time-based (worker skill scales speed). No direct-to-use shortcuts — everything flows through the pipeline.

### Transport

**On foot** — baseline; workers carry items manually
**Railcar** — cheap, no Solite required; track is laid directly by the player on the map; workers and railcars path along placed track automatically
**Conveyor Belt** — requires Solite to build; fully automated item flow; end-game logistics backbone

---

## Hub System

Food is stored in a single global pool shared across all Hubs. Ammo and materials are stored locally per Hub in a `ResourceBuffer` node. Buffers emit `buffer_changed` and `buffer_empty` signals. Turrets and structures consume from the nearest Hub buffer.

Workers spawn from Hubs but are not tethered — they operate anywhere on the map.

---

## Possession System

### State

```gdscript
# PossessionManager (autoload)
var possessed: Dictionary = {
    1: null,  # player 1's possessed worker
    2: null,  # player 2's possessed worker
    3: null,
    4: null,
}
```

### Rules

- A worker can only be possessed by one player at a time
- Possessing an already-possessed worker is blocked
- Escape returns the player to RTS camera
- On death of a possessed worker: unpossess → player returns to RTS view
- Possession applies a flat speed/yield bonus to all the worker's actions

### Gunners & Turrets

Gunners operate turrets. Possessing a Gunner who is currently assigned to a turret puts the player in direct control of that turret through the Gunner. Camera perspective and input remapping occur on the Gunner node, not on the turret.

---

## Multiplayer

Architecture: ENet server/client, max 4 players, port 7000.

`MultiplayerSynchronizer` nodes are required on:
- All worker nodes (position, current_job, xp, specialty)
- All robot nodes (position, health, state)
- `SolarCycle` (current_time, current_phase)
- `JobBoard` (available_jobs array)
- `PossessionManager` (possessed dictionary)

Both players share full access to the Job Board and can issue Force Task commands to any worker.

---

## Known Gaps / Open Questions

- Robot awakening trigger: exact mechanic TBD (temple/structure entry is the leading idea)
- Dual-specialty threshold constant: needs playtesting to tune
- XP curve shape: `sqrt` is a placeholder; may need adjustment
- Sub-field ability system: not yet designed
- Railcar pathing: fixed track vs. dynamic routing TBD
- Food variety bonus implementation: planned, not yet designed
- Name generation system: not yet implemented
