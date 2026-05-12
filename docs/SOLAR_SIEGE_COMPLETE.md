# The Solar Siege — Design Document Compilation

This document compiles the complete design and technical documentation for The Solar Siege. It is organized for review and print.

## Contents

1. **Game Design Document (GDD)** — Vision, gameplay, design intent
2. **Technical Design Document (TECHNICAL)** — Architecture, autoloads, cross-system flow
3. **System Specifications (SYSTEMS)** — Implementation detail per system
   1. Balance
   2. Worker
   3. Job Board
   4. Robot
   5. Solar Cycle
   6. Hub
   7. Food
   8. Possession
   9. Recall
   10. Resource Pipeline
   11. Transport
   12. Turret
   13. Hunting Tower
   14. Processing Building
   15. Production Building
   16. Multiplayer
4. **Future / Long-Term Ideas (FUTURE)**
5. **Open Questions (OPEN_QUESTIONS)**

---


# Part 1 — Game Design Document

# The Solar Siege — Game Design Document

**Engine:** Godot 4.6.2
**Genre:** Cooperative Tower Defense / Automation Strategy
**Perspective:** 3D Top-Down with 1st Person Possession

---

## What Is This Game?

A cooperative tower defense game that uses automation and possession. A group of colonizers lands on an unknown world and starts building. As they push further out, something stirs. After a triggering event — entering a structure, crossing a threshold — robots begin activating across the world, attacking during the day and freezing at night.

Players manage the colony from a top-down strategic view, but can drop into any worker at any time for direct 1st-person control. Every worker levels up, develops a specialty, and becomes someone worth protecting.

---

## The World

The colonizers don't know what they've landed on. The robots are part of the world they're colonizing — but their origin is not presented upfront. The player discovers this gradually. The early game is peaceful: build, gather, explore. The threat emerges from the world itself.

---

## Core Loop

**Daytime:** Robots attack. Turrets fire, workers build and repair. Any worker can be possessed for direct control.

**Nighttime:** Robots freeze in place. Workers salvage scraps, expand the colony, and prepare for the next day.

**The pressure:** Everything runs on resources. Turrets need ammo, workers need food, structures need materials. None of it is free.

---

## The Solar Tide

Robot strength follows the arc of the sun. They're at peak power at Noon and weakest at the edges of the day. At night they freeze completely — but they're not gone. Frozen robots are full of salvageable material and can be hauled back to be processed.

---

## Workers

Workers are the heart of the colony. Every worker starts as a nameless Recruit. As they gain experience, they develop a name, a specialty, and an appearance to match. A veteran worker looks and performs differently from a fresh one, and losing them matters.

All workers can do all tasks. Skill level determines speed — not access. Colonists have no weapons and cannot fight — combat belongs entirely to turrets and hunting towers.

### Worker Color

A worker's clothing color is a live readout of their skill level. No stat screen needed — a glance tells you everything.

- **Red channel** — Gunnery level
- **Green channel** — Harvesting level  
- **Blue channel** — Engineering level

All workers start dark gray. As levels increase, their color shifts toward the field they're developing. A pure Gunner turns red. A pure Engineer turns blue. A Gunner-Engineer turns magenta. A worker who has maxed all three fields turns white — the visual and mechanical cap.

### The Three Fields

**Engineering** — Building, repairing, expanding, and salvaging robots.
- *Construction* — walls, structures, Hub expansion
- *Mechanics* — repair, robot dismantling, salvage processing

**Gunnery** — Turret and hunting tower operation. Gunners don't carry weapons — they operate stationary structures. Higher skill means faster fire rate.
- *Marksman* — precision targeting, optimized for combat turrets
- *Hunter* — operates hunting towers; draws food from the world

**Harvesting** — Gathering resources and hauling.
- *Miner* — ore, stone
- *Lumberjack* — wood, trees
- *Harvester-Farmer* — crops, foraging, gathering

Hauling is a general Harvesting capability, not a sub-specialty. All Harvesters haul.

### Specialty Titles

A worker's highest field is their specialty. If two fields are both significantly elevated relative to everything else, the worker earns a dual title — *Gunner-Engineer*, for example. This is rare and meaningful.

A worker receives their name and appearance when they first earn a specialty. Until then they are a nameless Recruit.

### Sub-Field Abilities

Workers will develop smaller abilities and traits within their fields beyond their sub-specialty. This system is planned but not yet designed.

---

## Food & The Well-Fed Bonus

The colony workforce is always in one of three states:

- **Hungry** — Workers cannot be produced. Population growth halts.
- **Normal** — Standard operation.
- **Well-Fed** — All workers gain increased speed and XP, regardless of where they are on the map.

The Well-Fed threshold scales with total workforce size. Food comes from farming (Harvester-Farmers), foraging (Harvesters), and hunting (Gunners/Hunters). Different foods carry different food point values. Food stores are shared across all Hubs. Workers don't need to return to a Hub to receive the bonus — it applies colony-wide.

---

## Hubs

Hubs are the anchor points of the colony. Workers spawn from Hubs but are free to roam anywhere on the map. Hubs share a common pool for food. Ammo and materials are stored locally per Hub. The colony expands by building new Hubs further out.

---

## Robot Salvage

Robots have two separate values: health and scrap. The player only sees the health bar. When turrets or workers damage a robot, both health and scrap go down together. When Engineers dismantle a frozen robot, only health goes down — scrap is preserved. This means careful dismantling at night always yields more than gunning a robot down during the day.

A robot collapses into scrap when its health reaches zero. Scrap is hauled back to a processing building to be broken down into usable materials, including Solite.

Robots can be hauled back while still functional — but a live robot inside the base will attack. That's a risk the player chooses to take.

### Materials from Robots

**Scrap** — All robots drop scrap when their health reaches zero. Hauled to a processing building where it's broken down into parts, materials, and a variable yield of Solite.

**Shiny Scrap** — Dropped by late-game robots. Processed into Iridium alongside standard outputs.

**Solite** — A glowing purple material extracted from scrap at the processing building. Yield varies per batch. Required for advanced production, including conveyor belts.

**Iridium** — Extracted only from shiny scrap at the processing building. Drives the highest tier of technology.

---

## Production & Manufacturing

Resources don't go directly into buildings — they're processed first. Production buildings convert raw materials into usable parts: ammo, components, building materials. This means the colony needs a supply chain: gather → haul → process → use.

Early-game hauling is done on foot. Railroads are laid directly by the player on the map — workers and railcars then path along them automatically. They're cheap, require no Solite, and dramatically cut haul distances. Conveyor belts come later, require Solite to build, and automate the flow entirely.

---

## Hunting Towers

Hunting towers are structures that can be placed anywhere on the map — they don't need to be near a Hub. Animals roam the world and are drawn toward or pass near hunting towers. An assigned Gunner/Hunter operates a hunting tower the same way they'd operate a combat turret.

Hunting towers are the primary early-game food source before farming is established. Robots may occasionally target them, but they are not primary targets. This makes them relatively safe to place in the field.

What hunting towers consume (traps, bait, ammo) is not yet designed.

---

## The Job Board

The Job Board is the colony's task management system. Every available task — mining, construction, hauling, farming, hunting, dismantling — exists as a job on the board with a priority level and a location. Workers automatically claim the highest-priority job they can reach, weighted by proximity.

Players can override this at any time by Force Tasking a worker to a specific job, locking them to it until released. The board is shared across all players — any of the four can assign or reassign any worker.

When a new job is posted or a job is completed, workers re-evaluate their assignments automatically. A worker mid-task will abandon it for something more urgent unless Force Tasked.

---

## Possession

Any player can possess any worker at any time. In possession mode, the camera shifts to 1st person and the player controls that worker directly — faster, stronger, and more capable than their AI self. Possession gives a direct bonus to all of the worker's abilities.

Workers don't possess turrets directly. A Gunner operates a turret — possessing the Gunner gives the player direct control of that turret through them.

All of a possessed worker's skills apply passively. A possessed Engineer builds faster. A possessed Gunner shoots better. A possessed Harvester gathers more.

The possessed worker can die. The player returns to the strategic view. The game doesn't end — but losing a veteran worker is a real loss.

Possessed workers are highlighted so other players know not to attempt possession of the same unit.

---

## Recall

Any player can sound a colony-wide recall from the strategic view. All non-possessed workers immediately drop their current task and path to their nearest Hub.

When the recall is lifted, workers re-evaluate the Job Board as normal. Their interrupted job is still on the board — and since they were likely already closest to it, they usually reclaim it. If another worker took it in the meantime, they move on to the next best thing.

Possessed workers are exempt from recall.

---

## The Three Ages

The Three Ages are a way of thinking about progression, not a hard rule. A player in the middle of the "first age" could build a late-game wall if they had the materials. Nothing is locked. The ages describe a philosophy of play — where the game tends to be at a given moment — not a gate.

**Age of Manual Labor** — Everything is done by hand. Workers mine, chop, haul, hunt, and build. Getting the first Hub defended and fed is the whole challenge.

**Age of Automation** — Railcars and eventually conveyor belts take over transport. Production buildings come online. Workers shift into more specialized roles.

**Age of Industry** — Massive automated fortresses. Iridium flows into advanced production. A few legendary workers oversee systems that would have been unthinkable at the start.

---

## Future / Long-Term

See `FUTURE.md` for the full list of ideas outside MVP scope. Key items:

- Sub-Field Abilities & Branching Skill Tree
- Food Variety System
- Weather (cloudy days reduce robot strength)
- Covered structures / robot shade mechanic, and rover power extension as a counter
- Per-Hub and auto-recall
- Skill gates on high-tier objects
- The Awakening — triggering event narrative
- World Progression beyond the first planet

---

# Part 2 — Technical Design Document

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

---

# Part 3 — System Specifications

# Balance Reference

All tunable constants for the game. This is the single source of truth for values that affect game feel. Constants are named here and referenced by name in system docs.

A `Balance.gd` autoload could be derived directly from this file.

---

```gdscript
# Balance.gd

# --- XP & Progression ---
const XP_PER_HEALTH: float        = 1.0    # XP awarded per health point processed, all fields
const HAUL_XP_PER_METER: float    = 0.5    # Harvesting XP per meter traveled while carrying
const BASE_XP_PER_LEVEL: float    = 100.0  # XP required for level n = BASE_XP_PER_LEVEL * n
const MAX_LEVEL: int               = 128    # per field; also the color channel range

# --- Worker Color ---
const BASE_COLOR_CHANNEL: int     = 127    # starting gray; all channels begin here
# Max channel = BASE_COLOR_CHANNEL + MAX_LEVEL = 255

# --- Worker Speed ---
const SPEED_SCALE: float          = 0.02   # +2% task speed per level in the relevant field

# --- Possession ---
const POSSESSION_BONUS: float     = 1.5    # flat multiplier on all task speeds while possessed

# --- Dual Specialty ---
const DUAL_SPECIALTY_THRESHOLD: float = 0.0  # ratio; needs playtesting — see OPEN_QUESTIONS.md

# --- Well-Fed ---
const WELL_FED_SPEED_BONUS: float = 1.25   # +25% task speed colony-wide
const WELL_FED_XP_BONUS: float    = 1.50   # +50% XP gain rate colony-wide
const BASE_WELL_FED: float        = 50.0   # food points per worker for Well-Fed threshold
const BASE_HUNGRY: float          = 10.0   # food points per worker for Hungry threshold
const FOOD_CONSUMPTION_RATE: float = 0.1   # food points consumed per worker per second

# --- Hub Spawning ---
const RECRUIT_FOOD_COST: float    = 25.0   # food points consumed to queue a Recruit
const SPAWN_DURATION: float       = 30.0   # seconds to produce one Recruit
```

---

## Object Health Values

Health doubles as XP yield — a 200hp tree gives 200 Harvesting XP. All values are starting estimates.

### Natural Resources

| Object | Health | Field |
|---|---|---|
| Small tree | 100 | Harvesting |
| Large tree | 300 | Harvesting |
| Ore deposit (small) | 150 | Harvesting |
| Ore deposit (large) | 500 | Harvesting |
| Basic crop | 20 | Harvesting |
| Premium crop | 100 | Harvesting |
| Foraged item | 10 | Harvesting |
| Small animal | 80 | Gunnery |
| Large animal | 250 | Gunnery |

### Robots

| Robot Type | Health | Base Scrap | Notes |
|---|---|---|---|
| Basic robot | 200 | 200 | Early game |
| Heavy robot | 600 | 600 | Late game; drops ShinyScrap |

### Structures

Building and repairing a structure awards Engineering XP equal to health points added or restored.

| Structure | Health |
|---|---|
| Wall segment | 200 |
| Reinforced wall | 600 |
| Basic turret | 400 |
| Hunting tower | 300 |
| Processing building | 800 |
| Production building | 1000 |
| Hub | 3000 |
| Rail track segment | 50 |
| Conveyor segment | 100 |

---

## Pacing Sanity Check

Full day cycle: 600 seconds real time. Day and night are each 300 seconds.

| Action | Time Per Action | XP Per Day (est.) |
|---|---|---|
| Chop small trees | ~15s | ~4,000 Harvesting |
| Mine ore (small) | ~20s | ~4,500 Harvesting |
| Harvest basic crops | ~3s | ~4,000 Harvesting |
| Build wall segments | ~10s | ~12,000 Engineering |
| Dismantle basic robots (night) | ~30s | ~4,000 Engineering |
| Haul 50m loads | ~10s travel | ~1,500 Harvesting |

At ~4,000 XP/day: level 10 in ~2 days, level 50 in ~30 days, level 128 in ~200 days.

Intent: specialties emerge in the first few days, dual-specialties are mid-game, white-clad veterans are late-game.

---

# System: Worker

## Purpose
Workers are the primary agents of the colony. They execute tasks autonomously via the Job Board, level up through labor, develop specialties, and can be directly controlled by players through possession. See the GDD for design intent.

---

## Data

```gdscript
class_name Worker extends CharacterBody3D

@export var base_speed: float = 5.0

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

# Identity
var worker_name: String = ""
var is_recruit: bool = true

# XP and levels per field
var xp: Dictionary = {
    "Engineering": 0.0,
    "Gunnery":     0.0,
    "Harvesting":  0.0,
}
var levels: Dictionary = {
    "Engineering": 0,
    "Gunnery":     0,
    "Harvesting":  0,
}

var specialty: String = "Recruit"

# Task state
var current_job: Job = null
var is_force_tasked: bool = false
var is_recalled: bool = false

# Inventory
var inventory: Dictionary = {
    "Scrap":      0.0,
    "ShinyScrap": 0.0,
    "Wood":       0.0,
    "Ore":        0.0,
    "Food":       0.0,
    "Ammo":       0.0,
}

# Possession state
var is_possessed: bool = false
var possessing_player: int = -1
```

---

## XP & Levels

**Core rule:** XP = health points processed. Every action in every field follows this rule. No completion bonuses.

```gdscript
func award_xp(field: String, health_processed: float) -> void:
    xp[field] += health_processed * XP_PER_HEALTH  # see Balance.md
    _check_level_up(field)

func _check_level_up(field: String) -> void:
    var next_level = levels[field] + 1
    if next_level > MAX_LEVEL:  # see Balance.md
        return
    if xp[field] >= BASE_XP_PER_LEVEL * next_level:  # see Balance.md
        levels[field] = next_level
        _update_color()
        _update_specialty()
        level_up.emit(field, levels[field])
```

Hauling awards XP per meter traveled while carrying. This bypasses `award_xp` because `HAUL_XP_PER_METER` is already a direct XP rate (not a health-point conversion):

```gdscript
func _on_haul_progress(meters: float) -> void:
    xp["Harvesting"] += meters * HAUL_XP_PER_METER  # see Balance.md
    _check_level_up("Harvesting")
```

---

## Worker Color

Clothing color is a live visual readout of skill level — no UI needed.

```gdscript
func _update_color() -> void:
    var r = BASE_COLOR_CHANNEL + levels["Gunnery"]      # see Balance.md
    var g = BASE_COLOR_CHANNEL + levels["Harvesting"]
    var b = BASE_COLOR_CHANNEL + levels["Engineering"]
    _apply_color_to_mesh(Color(r / 255.0, g / 255.0, b / 255.0))
```

| Field(s) at max level | Color |
|---|---|
| None | Dark gray |
| Gunnery | Red |
| Harvesting | Green |
| Engineering | Blue |
| Gunnery + Engineering | Magenta |
| Gunnery + Harvesting | Yellow |
| Engineering + Harvesting | Cyan |
| All three | White |

---

## Specialty Derivation

Recomputed on every level-up. A worker's highest field is their specialty. If two fields are both significantly elevated relative to the third, the worker earns a dual title.

```gdscript
func _update_specialty() -> void:
    var fields = levels.keys()
    fields.sort_custom(func(a, b): return levels[a] > levels[b])
    var top    = levels[fields[0]]
    var second = levels[fields[1]]
    var third  = levels[fields[2]]

    if top <= 0:
        specialty = "Recruit"
        return

    if second > 0:
        var gap_ratio = (second - third) / float(top + second)
        if gap_ratio > DUAL_SPECIALTY_THRESHOLD:  # see Balance.md
            specialty = fields[0] + "-" + fields[1]
            _on_specialty_changed()
            return

    specialty = fields[0]
    _on_specialty_changed()

func _on_specialty_changed() -> void:
    if is_recruit and specialty != "Recruit":
        is_recruit = false
        _generate_identity()
    specialty_changed.emit(specialty)
```

### Sub-Specialties

| Field | Sub-Specialties |
|---|---|
| Engineering | Construction, Mechanics |
| Gunnery | Marksman, Hunter |
| Harvesting | Miner, Lumberjack, Harvester-Farmer |

Unlock logic is not yet designed — see FUTURE.md.

---

## Skill Effect on Tasks

Level scales task speed. All workers perform all tasks — skill determines how fast, not whether.

```gdscript
func get_task_speed(field: String) -> float:
    var speed = base_speed * (1.0 + levels[field] * SPEED_SCALE)  # see Balance.md
    if is_possessed:
        speed *= POSSESSION_BONUS  # see Balance.md
    return speed
```

Well-Fed bonus is applied externally by FoodManager to XP gain rate and speed.

---

## Colonists Cannot Attack

Workers have no weapons and cannot engage in combat. Combat is handled exclusively by turrets and hunting towers, operated by Gunners.

---

## Job Assignment

```gdscript
func _ready() -> void:
    JobBoard.jobs_updated.connect(_on_jobs_updated)
    _find_new_job()

func _on_jobs_updated() -> void:
    if not is_force_tasked and not is_recalled:
        _find_new_job()

func _find_new_job() -> void:
    var best = JobBoard.get_best_job_for(self)
    if best != current_job:
        if current_job:
            current_job.assigned_worker = null
        current_job = best
        if current_job:
            current_job.assigned_worker = self
            navigation_agent.target_position = current_job.location

func force_task(job: Job) -> void:
    is_force_tasked = true
    if current_job:
        current_job.assigned_worker = null
    current_job = job
    current_job.assigned_worker = self
    navigation_agent.target_position = current_job.location

func release_task() -> void:
    is_force_tasked = false
    _find_new_job()
```

---

## Recall

```gdscript
func recall() -> void:
    is_recalled = true
    if current_job:
        current_job.assigned_worker = null
        current_job = null
    navigation_agent.target_position = _find_nearest_hub().global_position

func release_recall() -> void:
    is_recalled = false
    _find_new_job()
```

See SYSTEMS/Recall.md for full recall behavior.

---

## Possession

```gdscript
func on_possess(player_id: int) -> void:
    is_possessed = true
    possessing_player = player_id
    $Camera3D.make_current()
    # input remapping handled by InputManager

func on_unpossess() -> void:
    is_possessed = false
    possessing_player = -1
    # camera returns to player's RTSCamera
    _find_new_job()

func _die() -> void:
    if is_possessed:
        PossessionManager.unpossess(possessing_player)
    worker_died.emit(self)
    queue_free()
```

---

## Signals

```gdscript
signal specialty_changed(new_specialty: String)
signal level_up(field: String, new_level: int)
signal worker_died(worker: Node3D)
```

---

## Dependencies

- `JobBoard` (autoload)
- `PossessionManager` (autoload)
- `FoodManager` (autoload)
- `NavigationAgent3D`

---

# System: Job Board

## Purpose
The Job Board is a global singleton that maintains all available tasks in the colony. Workers query it to find their next assignment. Players interact with it to issue Force Task overrides. It is the central coordination layer between player intent and worker behavior.

---

## Data

```gdscript
# JobBoard (autoload)
var available_jobs: Array[Job] = []
```

### Job Resource

```gdscript
class_name Job extends Resource

enum Priority  { LOW, MEDIUM, HIGH, CRITICAL }
enum JobType   { CONSTRUCTION, REPAIR, MINING, HAULING, FARMING, HUNTING, COMBAT, DISMANTLING }

var id: String
var type: JobType
var priority: Priority
var location: Vector3
var required_field: String = ""    # "Engineering", "Gunnery", "Harvesting", or "" for any
var assigned_worker: Node3D = null
var metadata: Dictionary = {}      # job-specific data (e.g. target node, resource type)
```

---

## API

```gdscript
func add_job(type: Job.JobType, priority: Job.Priority, location: Vector3, required_field: String = "") -> String:
    # Creates job, appends to available_jobs, emits jobs_updated
    # Returns job ID

func remove_job(id: String):
    # Removes job by ID, emits jobs_updated

func get_best_job_for(worker: Node3D) -> Job:
    # Returns highest-priority available job the worker can take
    # Sort: priority DESC, then distance ASC
    # Respects required_field (see Qualification below)

func get_job_by_id(id: String) -> Job:
    # Returns job or null
```

---

## Assignment Logic

```gdscript
func get_best_job_for(worker: Node3D) -> Job:
    var candidates = available_jobs.filter(func(j):
        return j.assigned_worker == null or j.assigned_worker == worker
    )

    candidates.sort_custom(func(a, b):
        if a.priority != b.priority:
            return a.priority > b.priority
        return worker.global_position.distance_to(a.location) < worker.global_position.distance_to(b.location)
    )

    for job in candidates:
        if _worker_qualifies(worker, job):
            return job

    return null
```

### Qualification

`required_field` gates job eligibility by skill level, not XP. A worker must have a minimum level in the required field to be considered qualified. The threshold is in OPEN_QUESTIONS.md (`MIN_FIELD_LEVEL`).

- If `required_field == ""` — any worker qualifies
- If `required_field` is set — worker's `levels[required_field]` must meet the threshold

```gdscript
func _worker_qualifies(worker: Node3D, job: Job) -> bool:
    if job.required_field == "":
        return true
    return worker.levels[job.required_field] >= MIN_FIELD_LEVEL  # see Balance.md
```

This is a soft routing preference — skilled workers go to relevant jobs first. Unqualified workers can still be Force Tasked onto any job.

---

## Signals

```gdscript
signal jobs_updated    # emitted on any add or remove; workers re-evaluate on receipt
```

---

## Re-Assignment Behavior

Workers listen to `jobs_updated`. On receipt, if not force-tasked, they call `get_best_job_for(self)`. If a better job exists than their current one, they release the current job (set `assigned_worker = null`) and take the new one.

Force-tasked workers ignore `jobs_updated` entirely until `release_task()` is called.

---

## Player Interaction

All players (up to 4) can:
- View the job board state
- Issue a Force Task to any worker (calls `worker.force_task(job)`)
- Release a Force Task (calls `worker.release_task()`)
- Manually post jobs (e.g. "build wall here") which enter the board at the specified priority

---

## Dependencies

- `Worker` nodes — query and hold job references
- Scene systems — post jobs when tasks arise (e.g. a Hub buffer running low posts a HAULING job)

---

# System: Robot

## Purpose
Robots are the primary threat. They attack Hubs during the day, freeze at night, and are the sole source of Scrap, ShinyScrap, Solite, and Iridium. Managing the robot threat and the robot economy are the same problem.

---

## Data

```gdscript
class_name Robot extends CharacterBody3D

@export var max_health: float = 50.0
@export var base_speed: float = 3.0
@export var base_damage: float = 10.0
@export var base_scrap: float = 100.0
@export var is_heavy: bool = false     # true = drops ShinyScrap instead of Scrap

var health: float = max_health
var scrap: float = base_scrap          # tracked separately; only reduced by combat damage
var is_frozen: bool = false
var target: Node3D = null
```

---

## States

```
FUNCTIONAL  →  (health == 0)   →  DEAD (becomes scrap pile)
FUNCTIONAL  →  (night begins)  →  FROZEN
FROZEN      →  (day begins)    →  FUNCTIONAL
FROZEN      →  (health == 0)   →  DEAD (becomes scrap pile)
```

Frozen robots do not move or attack but retain full interactability. Workers can haul or dismantle them while frozen.

---

## Combat Damage (Turrets)

Both `health` and `scrap` are reduced proportionally on each hit. The assigned Gunner earns Gunnery XP equal to the health damage dealt — but only when actively operating the turret (possessed or manually assigned and present).

```gdscript
func take_combat_damage(amount: float):
    var scrap_ratio = scrap / max(health, 0.001)
    health -= amount
    scrap -= amount * scrap_ratio    # scrap tracks health loss proportionally
    scrap = max(scrap, 0.0)
    if health <= 0:
        _die()
```

---

## Dismantling Damage (Engineers)

Only `health` is reduced. `scrap` is fully preserved. The Engineer earns Engineering XP equal to the health damage dealt.

```gdscript
func take_dismantle_damage(amount: float):
    health -= amount
    # scrap unchanged
    if health <= 0:
        _die()
```

This is the core incentive for night dismantling — it always yields more than combat.

---

## Death

```gdscript
func _die():
    var pile = preload("res://scenes/ResourcePile.tscn").instantiate()
    if is_heavy:
        pile.contents = { "ShinyScrap": scrap }
    else:
        pile.contents = { "Scrap": scrap }
    get_parent().add_child(pile)
    pile.global_position = global_position
    robot_died.emit(self)
    queue_free()
```

Resource piles are physical objects in the world. Workers haul them to processing buildings.

---

## Movement & Combat

Speed and damage scale with solar strength:

```gdscript
func _physics_process(delta):
    if is_frozen or health <= 0:
        return

    var boost = 1.0 + SolarCycle.get_solar_strength()
    # movement
    nav_agent.target_position = target.global_position
    var dir = global_position.direction_to(nav_agent.get_next_path_position())
    velocity = dir * base_speed * boost
    move_and_slide()

    # attack on arrival
    if nav_agent.is_navigation_finished():
        _attack(delta, boost)

func _attack(delta: float, boost: float):
    if target.has_method(&"take_damage"):
        target.call(&"take_damage", base_damage * boost * delta)
```

---

## Freeze / Thaw

```gdscript
func _on_phase_changed(phase: SolarCycle.DayPhase) -> void:
    is_frozen = (phase == SolarCycle.DayPhase.NIGHT)
    set_physics_process(not is_frozen)
```

---

## Hauling While Functional

A functional robot can be hauled by workers toward the base. It will continue to attack anything in range while being moved. This is intentional — it's a player risk/reward decision.

Hauling mechanic: worker navigates to robot, robot becomes "cargo" and is dragged along the worker's path. If the worker is killed or releases the robot, it resumes autonomous behavior immediately.

---

## Awakening

Robots do not spawn or activate until the awakening trigger fires. A global `GameState.robots_awakened` bool gates all spawning. On trigger, the first wave spawns at the next dawn.

Wave spawning, timing, escalation, and difficulty scaling are in FUTURE.md.

---

## Signals

```gdscript
signal robot_died(robot: Node3D)
```

---

## Dependencies

- `SolarCycle` (autoload) — phase and strength
- `GameState` (autoload, planned) — awakening flag
- `NavigationAgent3D` — pathfinding to Hubs
- `ResourcePile` scene — spawned on death

---

# System: Solar Cycle

## Purpose
The Solar Cycle is the heartbeat of the game. It drives robot behavior, governs when the colony is under attack, and determines when night operations can begin. Everything time-sensitive listens to it.

---

## Data

```gdscript
# SolarCycle (autoload)

enum DayPhase { DAY, NIGHT }

@export var day_duration: float = 600.0   # real seconds per full 24-hour cycle
@export var start_time: float = 6.0       # game starts at 6 AM

var current_time: float = 6.0             # 0.0 to 24.0
var current_phase: DayPhase = DayPhase.DAY
```

---

## Time Progression

```gdscript
func _process(delta: float) -> void:
    current_time += (delta / day_duration) * 24.0
    if current_time >= 24.0:
        current_time -= 24.0

    hour_changed.emit(current_time)

    var new_phase = DayPhase.DAY if (current_time >= 6.0 and current_time < 18.0) else DayPhase.NIGHT
    if new_phase != current_phase:
        current_phase = new_phase
        phase_changed.emit(current_phase)
```

**Day:** 6:00 – 18:00
**Night:** 18:00 – 6:00

---

## Solar Strength Formula

```gdscript
func get_solar_strength() -> float:
    if current_phase == DayPhase.NIGHT:
        return 0.0
    # Maps 6AM → 0, Noon → 1.0, 6PM → 0
    var theta = ((current_time - 6.0) / 12.0) * PI
    return sin(theta)
```

Returns a float in [0.0, 1.0]. Used by robots to scale speed and damage.

---

## Signals

```gdscript
signal hour_changed(hour: float)              # emits every frame
signal phase_changed(phase: DayPhase)         # emits on transition only
```

Consumers compare against `SolarCycle.DayPhase.DAY` or `SolarCycle.DayPhase.NIGHT`.

---

## Consumers

| System | What it listens to |
|---|---|
| Robot | `phase_changed` — freeze/thaw; `get_solar_strength()` — speed/damage scaling |
| Turret | `phase_changed` — optional behavior changes |
| UI | `hour_changed` — clock display |
| GameState | `phase_changed` — triggers wave spawning at dawn |

---

## Dependencies

None. SolarCycle is a pure singleton with no external dependencies.

---

# System: Hub

## Purpose
Hubs are the colony's anchor points. Workers spawn from them, structures near them consume resources from their local buffers, and the colony expands by building new Hubs further out. Food is shared globally; ammo and materials are stored locally per Hub.

---

## Data

```gdscript
class_name Hub extends StaticBody3D

@export var max_health: float = 3000.0
var health: float = max_health

# Local resource buffers (ammo, materials — not food)
@onready var buffer: ResourceBuffer = $ResourceBuffer

# Spawn queue
var spawn_queue: int = 0                       # number of Recruits queued for production
var spawn_progress: float = 0.0                # seconds elapsed on current spawn
@export var spawn_duration: float = 30.0       # seconds to produce one Recruit; see Balance.md
```

### ResourceBuffer

```gdscript
class_name ResourceBuffer extends Node

signal buffer_changed(type: String, amount: float)
signal buffer_empty(type: String)

var capacities: Dictionary = {
    "Ammo":    500.0,
    "Metal":   1000.0,
    "Lumber":  1000.0,
    "Solite":  200.0,
    "Iridium": 50.0,
}
var current: Dictionary = {
    "Ammo":    0.0,
    "Metal":   0.0,
    "Lumber":  0.0,
    "Solite":  0.0,
    "Iridium": 0.0,
}

func add_resource(type: String, amount: float) -> float   # returns overflow
func consume_resource(type: String, amount: float) -> bool
func get_fill_percent(type: String) -> float
```

---

## Spawning Recruits

Recruits are spawned manually by players, not on a timer. Any player can click any Hub to add a Recruit to its spawn queue.

**Rules:**
- Each spawn request deducts a fixed food cost immediately from the global food pool (see `RECRUIT_FOOD_COST` in Balance.md)
- Queue requests cannot be added while `NutritionState == HUNGRY`
- Already-queued Recruits will still be produced even if the colony becomes Hungry mid-spawn — the food was already paid
- Hub produces one Recruit at a time, each taking `spawn_duration` seconds
- Hub damage does not interrupt or delay spawning

```gdscript
func request_spawn() -> bool:
    if FoodManager.nutrition_state == FoodManager.NutritionState.HUNGRY:
        return false
    if not FoodManager.consume_food(RECRUIT_FOOD_COST):  # see Balance.md
        return false
    spawn_queue += 1
    return true

func _process(delta: float) -> void:
    if spawn_queue == 0:
        return
    spawn_progress += delta
    if spawn_progress >= spawn_duration:
        spawn_progress = 0.0
        spawn_queue -= 1
        _spawn_recruit()

func _spawn_recruit() -> void:
    var recruit = preload("res://scenes/Worker.tscn").instantiate()
    get_parent().add_child(recruit)
    recruit.global_position = $SpawnPoint.global_position
    recruit.add_to_group("Workers")
    worker_spawned.emit(recruit)
```

---

## Resource Delivery

Workers (and railcars and belts) deliver resources to the Hub's buffer by calling `buffer.add_resource(type, amount)`. The Hub does not pull resources — it only receives them.

Food deliveries are routed to the global food pool (FoodManager), not the Hub's local buffer.

---

## Structure Consumption

Turrets and other structures near a Hub draw ammo from its buffer automatically via `buffer.consume_resource("Ammo", amount)`. If the buffer runs dry, the structure stops functioning until resupplied.

Structures query the nearest Hub in their group at `_ready`. If no Hub is within range, the structure cannot operate. Range threshold is in OPEN_QUESTIONS.md.

---

## Hub Expansion

New Hubs are built by Engineers (Construction sub-specialty preferred). Building a Hub requires:
- A sufficient supply of materials (build cost in OPEN_QUESTIONS.md)
- An Engineer assigned to the build job

Once built, the new Hub is added to the `"Hubs"` group and becomes a valid spawn point and delivery target.

---

## Damage & Destruction

Hubs take damage from robot attacks. Health is the primary target for robots — destroying a Hub is the colony's loss condition for that location.

```gdscript
func take_damage(amount: float) -> void:
    health -= amount
    if health <= 0:
        _die()

func _die() -> void:
    _drop_buffer_contents()
    hub_destroyed.emit()
    queue_free()

func _drop_buffer_contents() -> void:
    var pile = preload("res://scenes/ResourcePile.tscn").instantiate()
    pile.contents = buffer.current.duplicate()
    get_parent().add_child(pile)
    pile.global_position = global_position
```

Engineers can repair damaged Hubs, gaining Engineering XP equal to health restored.

When a Hub is destroyed:
- All resources in its `ResourceBuffer` drop as a haulable pile at the Hub's location
- The Hub is removed from the `"Hubs"` group
- Workers in the spawn queue are lost (their food cost was already paid and is not refunded)

---

## Game Over Condition

The game continues as long as either workers or Hubs remain. The colony is only lost when both the worker count is zero AND no Hubs remain. This is checked colony-wide, not per-Hub.

```gdscript
# GameState
func _check_game_over() -> void:
    var workers = get_tree().get_nodes_in_group("Workers").size()
    var hubs    = get_tree().get_nodes_in_group("Hubs").size()
    if workers == 0 and hubs == 0:
        game_over.emit()
```

---

## Signals

```gdscript
signal worker_spawned(worker: Node3D)
signal hub_built()
signal hub_destroyed()
```

---

## Dependencies

- `FoodManager` — food deliveries forwarded here
- `Worker` — spawned here; deliver resources here
- `ResourceBuffer` — local storage for non-food resources
- `JobBoard` — posts BUILD jobs when a new Hub is queued; posts HAULING jobs when buffer is low
- `Turret` / structures — consume from buffer

---

# System: Food

## Purpose
Food keeps the colony alive and productive. The workforce's nutrition state affects worker output and whether new workers can be produced. Food is a shared colonial resource — all Hubs draw from the same pool.

---

## Nutrition States

```gdscript
enum NutritionState { HUNGRY, NORMAL, WELL_FED }
```

| State | Condition | Effect |
|---|---|---|
| Hungry | Food pool below hungry threshold | Worker production halted |
| Normal | Food pool between thresholds | No modifier |
| Well-Fed | Food pool above well-fed threshold | Speed and XP gain bonus for all workers |

Both thresholds scale with current workforce size (queried from the `"Workers"` group):

```gdscript
var worker_count = get_tree().get_nodes_in_group("Workers").size()
var well_fed_threshold: float = BASE_WELL_FED * worker_count  # see Balance.md
var hungry_threshold: float   = BASE_HUNGRY * worker_count    # see Balance.md
```

---

## Global Food Pool

```gdscript
# FoodManager (autoload)

var food_points: float = 0.0
var nutrition_state: NutritionState = NutritionState.NORMAL

signal nutrition_changed(new_state: NutritionState)

func consume_food(amount: float) -> bool:
    if food_points < amount:
        return false
    food_points -= amount
    _evaluate_nutrition()
    return true
```

Food points are added when workers deliver food to any Hub. The pool is shared — there is no per-Hub food storage.

Food is consumed over time at a rate proportional to workforce size:

```gdscript
func _process(delta):
    var worker_count = get_tree().get_nodes_in_group("Workers").size()
    food_points -= FOOD_CONSUMPTION_RATE * worker_count * delta  # see Balance.md
    food_points = max(food_points, 0.0)
    _evaluate_nutrition()
```

---

## Food Sources

All food sources are Harvesting or Gunnery tasks posted to the Job Board.

| Source | Field | Sub-Specialty | Job Type |
|---|---|---|---|
| Crops / Foraging | Harvesting | Harvester-Farmer | FARMING |
| Hunting tower | Gunnery | Hunter | HUNTING |

Hunting is operated from stationary hunting towers — Gunners cannot hunt on foot. Animals roam the map and are drawn toward hunting towers.

---

## Food Items & Points

Different foods contribute different point values when delivered. A basic crop might contribute 1–5 points; a hunted animal significantly more. Exact values are in Balance.md.

---

## Well-Fed Bonus

Applied colony-wide when `NutritionState == WELL_FED`. Speed and XP gain rate are both multiplied — see `WELL_FED_SPEED_BONUS` and `WELL_FED_XP_BONUS` in Balance.md.

Workers do not need to be near a Hub to receive the bonus. It applies to all workers regardless of location.

---

## Worker Production Gate

New Recruits cannot spawn from any Hub while `NutritionState == HUNGRY`. The spawn UI should reflect this clearly.

---

## Signals

```gdscript
signal nutrition_changed(new_state: NutritionState)
signal food_delivered(amount: float, source: String)
```

---

## Dependencies

- `Worker` — applies Well-Fed bonus to speed and XP gain rate
- `Hub` — receives food deliveries (routes to global pool)
- `JobBoard` — FARMING and HUNTING jobs posted here
- `"Workers"` group — for worker count in threshold scaling and food consumption

---

# System: Possession

## Purpose
Any of the four players can drop into any worker at any time for direct 1st-person control. Possession gives the player full control of that worker with a bonus to all their abilities. See the GDD for design intent.

---

## Data

```gdscript
# PossessionManager (autoload)
var possessed: Dictionary = {
    1: null,
    2: null,
    3: null,
    4: null,
}
```

---

## Rules

- A worker can only be possessed by one player at a time
- A player can only possess one worker at a time
- Possessed workers are highlighted visually for all players
- Escape exits possession and returns the player to their RTS camera

---

## Possess / Unpossess

```gdscript
func possess(player_id: int, unit: Node3D) -> bool:
    if unit.is_possessed:
        return false

    if possessed[player_id] != null:
        unpossess(player_id)

    possessed[player_id] = unit
    unit.call(&"on_possess", player_id)
    possession_changed.emit(player_id, unit, true)
    return true

func unpossess(player_id: int) -> void:
    var unit = possessed[player_id]
    if not unit:
        return
    possessed[player_id] = null
    unit.call(&"on_unpossess")
    possession_changed.emit(player_id, unit, false)
```

Worker-side implementation is in SYSTEMS/Worker.md.

---

## Possession Bonus

A flat multiplier applied to all task speeds while a worker is possessed. See `POSSESSION_BONUS` in Balance.md.

Applied inside `Worker.get_task_speed()` when `is_possessed` is true. All skill levels still apply on top.

---

## Gunners & Turrets

Workers don't possess turrets directly. A Gunner operates a turret — possessing the Gunner puts the player in direct control through them. The Gunner's skill and possession bonus both apply to fire rate.

```gdscript
# Turret — applies assigned worker's Gunnery skill to fire rate
func _fire() -> void:
    var skill_bonus = 1.0
    if assigned_worker:
        skill_bonus = 1.0 + assigned_worker.levels["Gunnery"] * SPEED_SCALE  # see Balance.md
    # apply skill_bonus to fire rate
```

---

## Death While Possessed

Handled in `Worker._die()`. The player is returned to their RTS view. The game does not end.

---

## Visual Indicator

Possessed workers display a distinct highlight visible to all players, differentiated by player. Implementation not yet decided — see OPEN_QUESTIONS.md.

---

## Signals

```gdscript
signal possession_changed(player_id: int, unit: Node3D, is_possessed: bool)
```

---

## Dependencies

- `Worker` — implements `on_possess` / `on_unpossess`
- `RTSCamera` — each player's strategic camera
- `InputManager` (planned) — per-player input remapping

---

# System: Recall (Town Bell)

## Purpose
The Recall action lets any player instantly pull all non-possessed workers back to their nearest Hub from the strategic view. It is a safety valve — used to protect workers as dawn approaches, or to consolidate the workforce during a crisis.

---

## Trigger

Activated by a player action from the strategic (RTS) view. Global — affects all workers on the map simultaneously. There is no per-Hub or per-worker granularity at this time.

---

## Behavior

### On Recall

```gdscript
# GameState or a RecallManager
func recall_all():
    for worker in get_tree().get_nodes_in_group("Workers"):
        if not worker.is_possessed:
            worker.recall()
```

```gdscript
# Worker
func recall():
    is_recalled = true
    if current_job:
        current_job.assigned_worker = null
        current_job = null
    var nearest_hub = _find_nearest_hub()
    navigation_agent.target_position = nearest_hub.global_position
```

- Possession is not interrupted — possessed workers are exempt
- Current job is released immediately (unassigned on the Job Board)
- Worker paths to nearest Hub and waits

### On Release

```gdscript
func release_recall():
    is_recalled = false
    _find_new_job()   # standard Job Board evaluation
```

No saved job state. Workers re-evaluate the Job Board normally on release. Their previously interrupted job will still be on the board at the same priority — and since they were likely closest to it, they will usually reclaim it. If another worker took it in the interim, they are routed to the next best job.

---

## Data

```gdscript
# Worker
var is_recalled: bool = false
```

---

## Nearest Hub Resolution

```gdscript
func _find_nearest_hub() -> Node3D:
    var hubs = get_tree().get_nodes_in_group("Hubs")
    var nearest = null
    var nearest_dist = INF
    for hub in hubs:
        var d = global_position.distance_to(hub.global_position)
        if d < nearest_dist:
            nearest_dist = d
            nearest = hub
    return nearest
```

Workers are not tied to a specific Hub — nearest at the time of recall determines the destination.

---

## Signals

```gdscript
# GameState / RecallManager
signal recall_triggered()
signal recall_released()
```

---

# System: Resource Pipeline

## Purpose
Raw materials are gathered in the world and must be processed before they become usable. Nothing goes directly from the ground (or a robot) into a building. The pipeline is: gather → haul → process → use.

---

## Resource Types

| Resource | Source | Raw or Processed |
|---|---|---|
| Wood | Trees (Lumberjacks) | Raw |
| Ore | Rock deposits (Miners) | Raw |
| Food | Farms, foraging, hunting | Raw |
| Scrap | Robot death | Raw |
| ShinyScrap | Heavy robot death | Raw |
| Lumber | Wood → Processing Building | Processed |
| Metal | Ore → Processing Building | Processed |
| Ammo | Metal + other → Production Building | Processed |
| Solite | Scrap → Processing Building (variable yield) | Processed |
| Iridium | ShinyScrap → Processing Building | Processed |
| Building Materials | Lumber + Metal → Production | Processed |

---

## Processing Buildings

Processing buildings accept specific raw inputs and produce processed outputs. Processing is time-based; worker skill (Engineering/Mechanics) scales processing speed.

### Scrap Processor

- **Input:** Scrap
- **Output:** Metal parts + Solite (variable yield, random per batch within a range)
- Solite yield is not determined at robot death — it is determined here

### Shiny Scrap Processor

- **Input:** ShinyScrap
- **Output:** Metal parts + Iridium + Solite (variable yield)
- May be the same building as Scrap Processor with a different processing mode, or a separate building — see OPEN_QUESTIONS.md

### Lumber Mill

- **Input:** Wood
- **Output:** Lumber

### Smelter

- **Input:** Ore
- **Output:** Metal

### Production Building (Factory)

- **Input:** Processed materials (Metal, Lumber, Solite)
- **Output:** Ammo, Building Materials, Components
- Ammo production is the primary use — turrets require a steady ammo supply

---

## Flow Diagram

```
[World]                    [Processing]              [Use]
Trees    → Haul → Lumber Mill    → Lumber    → Factory → Building Materials
Ore      → Haul → Smelter        → Metal     → Factory → Ammo / Components
Scrap    → Haul → Scrap Proc.    → Metal + Solite
ShinyScrap → Haul → Shiny Proc.  → Metal + Iridium + Solite
Food     → Haul → Hub Food Pool  → (colony-wide Well-Fed state)
```

---

## Hauling

Workers carry raw materials from source to processor, and processed materials from processor to Hub or construction site.

Haul capacity is fixed per worker (not skill-based) — exact value in OPEN_QUESTIONS.md.

### Transport Options

1. **On foot** — worker carries manually; slowest, no infrastructure required
2. **Railcar** — player lays track; railcars path along track automatically; cheap, no Solite required
3. **Conveyor Belt** — requires Solite to build; fully automated; end-game

---

## Resource Pile

When a robot dies or a Hub is destroyed, a `ResourcePile` node spawns at its location holding the dropped resources. A single scene handles both cases — its contents are configured at spawn time.

```gdscript
class_name ResourcePile extends Node3D

var contents: Dictionary = {}              # resource type → amount, e.g. { "Scrap": 100.0, "Solite": 5.0 }
var is_being_hauled: bool = false
var hauler: Node3D = null
```

Workers claim a ResourcePile by setting `hauler` and `is_being_hauled`. Unclaimed piles are visible to all workers and appear on the Job Board as HAULING jobs.

### Common spawn cases

- **Robot death** — `contents = { "Scrap": robot.scrap }` (or `"ShinyScrap"` if the robot was heavy)
- **Hub destruction** — `contents = buffer.current.duplicate()` (the full Hub buffer)

A pile may contain multiple resource types. Workers handle multi-type piles by hauling each type in separate trips, or in one trip if their inventory has room for all.

---

## Signals

```gdscript
# Processing Building
signal processing_complete(output_type: String, amount: float)
signal processing_started(input_type: String)

# ResourcePile
signal claimed(worker: Node3D)
signal delivered()
```

---

## Dependencies

- `Worker` — hauls materials
- `JobBoard` — auto-posts HAULING jobs when ResourcePiles spawn, and when processing buildings have output ready
- `Hub` — receives processed materials into local buffer
- `Transport` system — railcars and belts move materials automatically

---

# System: Transport

## Purpose
Transport moves raw and processed materials around the map so workers don't have to carry everything by hand. Three tiers exist: on-foot hauling (always available), railcars (mid-game, player-placed track), and conveyor belts (late-game, Solite-gated, automated).

---

## Tier 1: On-Foot Hauling

No infrastructure required. Workers pick up a resource, carry it to a destination, and return. Slowest method but available from the start.

Governed entirely by the Worker and Job Board systems. No separate transport nodes needed.

---

## Tier 2: Railcar

### Overview

The player lays railroad track directly on the map. Railcars spawn at a station and follow the laid track automatically, picking up and dropping off cargo at designated stops.

Railcars are cheap to build and require no Solite. They are the primary logistics backbone of the Age of Automation.

### Track Placement

Track is placed by the player in the top-down view, similar to drawing a path. Workers are not required for placement. Track segments snap to a grid — resolution in OPEN_QUESTIONS.md. Track can branch.

Implementation: likely a `Path3D` node generated from player input, with railcar nodes following it via `PathFollow3D`.

### Railcar Data

```gdscript
class_name Railcar extends Node3D

var path: Path3D
var follow: PathFollow3D
var cargo: Dictionary = {}        # resource type → amount
var cargo_capacity: float = 200.0
var speed: float = 5.0            # units/sec along path
var current_stop: int = 0
var stops: Array[Vector3] = []    # designated pickup/dropoff points
```

### Stop Behavior

At each stop, railcars:
1. Check if there is cargo to pick up (from a processing building output queue or scrap pile)
2. Load up to capacity
3. Check if there is a destination hub or building that needs the cargo
4. Move to next stop

Stop logic is simple — no dynamic routing. The player defines the route by laying track.

### Cost

- Track: cheap (wood/metal per segment)
- Railcar: moderate (metal components)
- No Solite required

---

## Tier 3: Conveyor Belt

### Overview

Conveyor belts are fully automated, continuous item movers. They replace manual hauling entirely on their route. Items placed at the belt's input end arrive at the output end without worker involvement.

Belts require Solite to build and are the defining feature of the Age of Industry.

### Implementation

Uses `MultiMeshInstance3D` for rendering items on the belt path — one draw call regardless of item count.

```gdscript
class_name ConveyorBelt extends Node3D

@export var speed: float = 2.0
@export var item_mesh: Mesh
var path: Path3D
var multimesh: MultiMeshInstance3D
var items: Array[Dictionary] = []    # { progress: float, type: String }
```

Items progress from 0.0 to 1.0 along the belt's path each frame. On reaching 1.0, the item exits and is delivered to the connected buffer or next belt.

### Belt Chaining

Belts connect to each other and to building input/output ports. Exit logic: on item reaching progress 1.0, check for a connected belt or buffer at the output end and transfer. If output is blocked (buffer full, no connection), item halts at end until cleared.

### Cost

- Belt segment: moderate (metal + Solite per segment)
- Higher throughput than railcars but higher build cost

---

## Signals

```gdscript
# Railcar
signal cargo_loaded(type: String, amount: float)
signal cargo_delivered(type: String, amount: float, destination: Node3D)

# ConveyorBelt
signal item_exited(type: String, progress_destination: Node3D)
```

---

## Dependencies

- `Worker` — on-foot hauling
- `JobBoard` — HAULING jobs for on-foot transport
- `ResourcePipeline` — source and destination of all cargo
- `Hub` — `ResourceBuffer` as delivery target

---

# System: Turret

## Purpose
Turrets are stationary combat structures placed by the player. They target robots automatically and fire when ammo is available. A turret can be assigned a Gunner, whose Gunnery skill scales the turret's fire rate. Possessing the assigned Gunner gives the player direct control through them.

---

## Data

```gdscript
class_name Turret extends StaticBody3D

@export var max_health: float = 400.0
@export var base_fire_rate: float = 1.0    # shots per second at level 0 Gunnery
@export var damage: float = 20.0
@export var ammo_per_shot: float = 1.0
@export var attack_range: float = 30.0

var health: float = max_health
var assigned_worker: Worker = null         # null if no Gunner assigned
var target: Robot = null
var buffer_source: Hub = null

@onready var timer: Timer = $Timer
@onready var barrel: Node3D = $Barrel

func _ready() -> void:
    buffer_source = _find_nearest_hub()
    timer.timeout.connect(_on_timer_timeout)
    timer.wait_time = 1.0 / base_fire_rate
    timer.start()
```

---

## Fire Logic

```gdscript
func _on_timer_timeout() -> void:
    # update wait_time for next shot based on current Gunner skill
    var skill_bonus = 1.0
    if assigned_worker:
        skill_bonus = 1.0 + assigned_worker.levels["Gunnery"] * SPEED_SCALE  # see Balance.md
    timer.wait_time = 1.0 / (base_fire_rate * skill_bonus)

    if not target or not is_instance_valid(target):
        target = _find_target_in_range()
        if not target:
            return

    if buffer_source.buffer.consume_resource("Ammo", ammo_per_shot):
        _fire()

func _fire() -> void:
    target.take_combat_damage(damage)
    turret_fired.emit(target)
```

Higher Gunnery skill shortens the wait between shots — the turret fires faster.

---

## Damage & Destruction

```gdscript
func take_damage(amount: float) -> void:
    health -= amount
    if health <= 0:
        _die()

func _die() -> void:
    turret_destroyed.emit()
    queue_free()
```

Engineers can repair damaged turrets, gaining Engineering XP equal to health restored.

---

## Gunner Assignment

A Gunner can be assigned to a turret via a Job Board task or direct player command. While assigned, their Gunnery XP increases on each hit (see Robot.md combat damage). When possessed, the player controls the turret through them — see Possession.md.

---

## Ammo Supply

Turrets pull ammo from the nearest Hub's `ResourceBuffer`. If the buffer is empty, the turret stops firing until resupplied. No local ammo storage.

---

## Signals

```gdscript
signal turret_fired(target: Robot)
signal turret_destroyed()
```

---

## Dependencies

- `Hub` — ammo source via `ResourceBuffer`
- `Robot` — target via `take_combat_damage`
- `Worker` — assigned Gunner provides skill bonus
- `PossessionManager` — direct player control routed through assigned Gunner

---

# System: Hunting Tower

## Purpose
Hunting Towers are stationary structures placed by the player anywhere on the map — they don't need to be near a Hub. They draw animals toward them and shoot them down to produce food. Operated by an assigned Gunner/Hunter. Robots may occasionally target hunting towers but they're not primary targets.

---

## Data

```gdscript
class_name HuntingTower extends StaticBody3D

@export var max_health: float = 300.0
@export var base_fire_rate: float = 0.5    # shots per second at level 0 Gunnery
@export var damage: float = 30.0           # animal hp per shot
@export var attack_range: float = 40.0
@export var attraction_radius: float = 60.0

var health: float = max_health
var assigned_worker: Worker = null
var target: Node3D = null                  # animal node

@onready var timer: Timer = $Timer
@onready var barrel: Node3D = $Barrel

func _ready() -> void:
    timer.timeout.connect(_on_timer_timeout)
    timer.wait_time = 1.0 / base_fire_rate
    timer.start()
```

---

## Fire Logic

Functionally similar to a Turret but targets animals instead of robots, and produces food on kill instead of damage to the colony.

```gdscript
func _on_timer_timeout() -> void:
    var skill_bonus = 1.0
    if assigned_worker:
        skill_bonus = 1.0 + assigned_worker.levels["Gunnery"] * SPEED_SCALE  # see Balance.md
    timer.wait_time = 1.0 / (base_fire_rate * skill_bonus)

    if not target or not is_instance_valid(target):
        target = _find_animal_in_range()
        if not target:
            return

    _fire()

func _fire() -> void:
    target.take_damage(damage)
```

On animal death, food yield is delivered to the global food pool and `animal_killed` is emitted. Engineering/Mechanics is not involved — animals don't drop scrap.

---

## Damage & Destruction

```gdscript
func take_damage(amount: float) -> void:
    health -= amount
    if health <= 0:
        _die()

func _die() -> void:
    tower_destroyed.emit()
    queue_free()
```

---

## Consumables

What hunting towers consume (traps, bait, ammo) is in FUTURE.md. For MVP they may operate without consumables, or share ammo with combat turrets — decision pending.

---

## Animal Attraction

Animals within `attraction_radius` are drawn toward the tower. Exact pathing behavior is in FUTURE.md.

---

## Signals

```gdscript
signal animal_killed(animal: Node3D, food_yield: float)
signal tower_destroyed()
```

---

## Dependencies

- `FoodManager` — food yield delivered here on animal death
- `Worker` — assigned Hunter provides skill bonus
- `PossessionManager` — direct player control routed through assigned Hunter
- `Animal` (scene, not yet designed; see FUTURE.md) — target nodes

---

# System: Processing Building

## Purpose
Processing Buildings convert raw materials into processed materials. They are the bridge between the world (gathered resources, robot scrap) and usable inventory. Each building type has specific inputs and outputs. Processing is time-based, with worker skill scaling speed.

This document covers the general processing mechanic. Specific variants (Scrap Processor, Lumber Mill, Smelter, Shiny Scrap Processor) follow the same pattern with different inputs/outputs.

---

## Data

```gdscript
class_name ProcessingBuilding extends StaticBody3D

@export var max_health: float = 800.0
@export var input_type: String = ""        # e.g. "Scrap", "Wood", "Ore"
@export var base_process_time: float = 10.0    # seconds per batch at level 0 Engineering

var health: float = max_health
var input_queue: float = 0.0               # raw material waiting to be processed
var output_queue: Dictionary = {}          # processed material waiting to be hauled out
var assigned_worker: Worker = null         # operator; scales processing speed
var process_progress: float = 0.0
```

---

## Processing Loop

```gdscript
func _process(delta: float) -> void:
    if input_queue <= 0.0:
        return

    var speed_bonus = 1.0
    if assigned_worker:
        speed_bonus = 1.0 + assigned_worker.levels["Engineering"] * SPEED_SCALE  # see Balance.md

    process_progress += delta * speed_bonus
    if process_progress >= base_process_time:
        process_progress = 0.0
        input_queue -= 1.0
        _produce_output()

func _produce_output() -> void:
    var outputs = _compute_outputs()   # specific to building type
    for type in outputs:
        output_queue[type] = output_queue.get(type, 0.0) + outputs[type]
        processing_complete.emit(type, outputs[type])
```

---

## Variants

### Scrap Processor
- Input: `Scrap`
- Output: `Metal` + variable `Solite` yield (random per batch)

### Shiny Scrap Processor
- Input: `ShinyScrap`
- Output: `Metal` + `Iridium` + variable `Solite` yield
- May share a building with Scrap Processor — see OPEN_QUESTIONS.md

### Smelter
- Input: `Ore`
- Output: `Metal`

### Lumber Mill
- Input: `Wood`
- Output: `Lumber`

---

## Input & Output Flow

Workers, railcars, and conveyor belts deliver raw materials by adding to `input_queue`. Processed materials sit in `output_queue` until hauled out by workers (HAULING jobs posted automatically to the Job Board), or picked up by railcars/belts.

---

## Damage & Destruction

```gdscript
func take_damage(amount: float) -> void:
    health -= amount
    if health <= 0:
        _die()

func _die() -> void:
    building_destroyed.emit()
    queue_free()
```

Engineers can repair damaged processing buildings, gaining Engineering XP equal to health restored.

---

## Signals

```gdscript
signal processing_complete(output_type: String, amount: float)
signal building_destroyed()
```

---

## Dependencies

- `Worker` — assigned operator; haulers move input and output
- `JobBoard` — posts HAULING jobs for input demand and output supply
- `Transport` system — railcars and belts as alternative input/output methods

---

# System: Production Building

## Purpose
Production Buildings (Factories) combine processed materials into usable end-products: ammo, building materials, components. They are the final step before resources are consumed by structures and construction.

Structurally similar to a Processing Building but with multiple inputs per recipe.

---

## Data

```gdscript
class_name ProductionBuilding extends StaticBody3D

@export var max_health: float = 1000.0
@export var base_process_time: float = 15.0   # seconds per batch at level 0 Engineering

var health: float = max_health
var input_buffer: Dictionary = {}             # type → amount on hand
var output_queue: Dictionary = {}             # type → amount produced, waiting to haul
var assigned_worker: Worker = null
var current_recipe: Recipe = null
var process_progress: float = 0.0
```

---

## Recipes

Each recipe defines required inputs and produced outputs.

```gdscript
class_name Recipe extends Resource

@export var name: String
@export var inputs: Dictionary = {}       # type → amount required
@export var outputs: Dictionary = {}      # type → amount produced
```

### Example Recipes

| Recipe | Inputs | Outputs |
|---|---|---|
| Ammo | 2 Metal | 10 Ammo |
| Building Materials | 1 Metal + 1 Lumber | 1 Building Materials |
| Advanced Components | 1 Metal + 1 Solite | 1 Components |

Specific recipe balancing belongs in Balance.md once recipes are finalized.

---

## Processing Loop

```gdscript
func _process(delta: float) -> void:
    if not current_recipe or not _has_required_inputs():
        return

    var speed_bonus = 1.0
    if assigned_worker:
        speed_bonus = 1.0 + assigned_worker.levels["Engineering"] * SPEED_SCALE  # see Balance.md

    process_progress += delta * speed_bonus
    if process_progress >= base_process_time:
        process_progress = 0.0
        _consume_inputs()
        _produce_outputs()

func _has_required_inputs() -> bool:
    for type in current_recipe.inputs:
        if input_buffer.get(type, 0.0) < current_recipe.inputs[type]:
            return false
    return true

func _consume_inputs() -> void:
    for type in current_recipe.inputs:
        input_buffer[type] -= current_recipe.inputs[type]

func _produce_outputs() -> void:
    for type in current_recipe.outputs:
        output_queue[type] = output_queue.get(type, 0.0) + current_recipe.outputs[type]
        production_complete.emit(type, current_recipe.outputs[type])
```

---

## Recipe Selection

The player selects the active recipe for a Production Building. The building runs that recipe continuously while inputs are available. Recipe switching is instant — partial progress on the previous recipe is lost.

---

## Damage & Destruction

```gdscript
func take_damage(amount: float) -> void:
    health -= amount
    if health <= 0:
        _die()

func _die() -> void:
    building_destroyed.emit()
    queue_free()
```

Engineers can repair damaged production buildings, gaining Engineering XP equal to health restored.

---

## Signals

```gdscript
signal production_complete(output_type: String, amount: float)
signal building_destroyed()
```

---

## Dependencies

- `ProcessingBuilding` — typical source of input materials
- `Worker` — assigned operator; haulers move input and output
- `JobBoard` — posts HAULING jobs for input demand and output supply
- `Hub` — common destination for finished products (Ammo to buffer)
- `Transport` system — automated alternative for input/output

---

# System: Multiplayer

## Purpose
The Solar Siege supports up to 4 cooperative players. One player hosts a server; others join as clients. All players share the same game state, Job Board, and colony. Any player can possess any worker and issue any command.

---

## Architecture

**Transport:** ENet
**Max players:** 4
**Port:** 7000 (default)
**Mode:** Dedicated host (one player runs the server); no dedicated server binary planned for MVP

---

## Connection

```gdscript
# MultiplayerManager (autoload)

const PORT = 7000
const MAX_PLAYERS = 4

func create_game():
    var peer = ENetMultiplayerPeer.new()
    peer.create_server(PORT, MAX_PLAYERS)
    multiplayer.multiplayer_peer = peer

func join_game(address: String = "127.0.0.1"):
    var peer = ENetMultiplayerPeer.new()
    peer.create_client(address, PORT)
    multiplayer.multiplayer_peer = peer
```

Player IDs are assigned by Godot's multiplayer system. Host is always peer ID 1.

---

## What Gets Synchronized

Every networked object requires a `MultiplayerSynchronizer` node. The following must be synced:

| Node | Synced Properties |
|---|---|
| Worker | `global_position`, `current_job`, `xp`, `specialty`, `is_possessed`, `possessing_player` |
| Robot | `global_position`, `health`, `scrap`, `is_frozen` |
| SolarCycle | `current_time`, `current_phase` |
| JobBoard | `available_jobs` |
| PossessionManager | `possessed` dictionary |
| FoodManager | `food_points`, `nutrition_state` |
| Hub / ResourceBuffer | `current` (resource amounts) |
| ResourcePile | `global_position`, `contents`, `is_being_hauled` |

---

## Authority Model

- **Server (host) is authoritative** for all game state
- Clients send input and intent; server validates and applies
- `@rpc` calls used for player actions (possess, force task, place track, etc.)

```gdscript
# Example: player initiates possession
@rpc("any_peer", "call_local", "reliable")
func request_possess(unit_path: NodePath):
    if not multiplayer.is_server():
        return
    var unit = get_node(unit_path)
    var player_id = multiplayer.get_remote_sender_id()
    PossessionManager.possess(player_id, unit)
```

---

## Shared Access

All players share:
- The Job Board (any player can post, assign, or force-task)
- The possession system (any player can possess any available worker)
- The RTS camera (each player has their own camera, independently positioned)

No player has exclusive ownership of workers or structures. Coordination is a social contract, not an enforced mechanic.

---

## Player Cameras

Each player maintains their own `RTSCamera` instance. Camera positions are local — not synced. When a player possesses a worker, their camera switches to the worker's 1st-person camera. On unpossess, it returns to their personal RTS camera at its last position.

---

## Dependencies

- All major game nodes — require `MultiplayerSynchronizer`
- `PossessionManager` — synced; `possess` / `unpossess` called via RPC
- `JobBoard` — synced; job mutations via RPC from any client
- `InputManager` (planned) — handles per-player controller mapping

---

# Part 4 — Future / Long-Term Ideas

# The Solar Siege — Future & Long-Term Ideas

Everything here is explicitly out of scope for the MVP. Items are organized by system. Nothing in this document is designed — these are seeds for later.

---

## Worker

- **Sub-Field Abilities** — Minor traits and abilities within a field that don't constitute a full specialty. A layer of personalization beyond the three-field structure.
- **Branching Skill Tree** — Sub-specialties deepen as workers level up. Structure and unlock conditions TBD.
- **Skill Gates** — High-tier objects (rare crops, heavy robots, advanced structures) requiring a minimum skill level to interact with.
- **Sub-specialty unlock logic** — How and when workers commit to a sub-specialty (Miner, Lumberjack, Marksman, etc.).

---

## Job Board

- **CRITICAL priority force-override** — Whether CRITICAL priority jobs should hard-override force-tasked workers.
- **Job Board UI** — How the board is represented visually for players.

---

## Robot

- **Wave spawning system** — Timing, escalation, spawn points, and difficulty scaling.
- **Hauling live robots** — Implementation details for dragging a functional robot back to base.
- **Frozen robot visuals** — Visual state indicator for frozen robots.
- **Heavy robot introduction** — When heavy robots appear and their drop rate tuning.
- **Robot aggro behavior** — Whether robots have a detection/aggro range or always target the nearest Hub.
- **The Awakening** — The triggering event that activates robots is not finalized. Leading concept: colonists enter an ancient structure, activating all robots simultaneously. The origin of the robots is a mystery revealed gradually.
- **Covered structures / robot shade** — Robots aware of whether they're beneath a structure (bridge, overhang). If shaded from the sun, solar strength drops — robots could freeze mid-day under sufficient cover. Turns the solar mechanic into an architectural tool.
- **Rover power extension** — Late-game robot countermeasure. Rovers with solar panels follow robots via a tether, allowing them to operate under covered structures. Counter to shade-based defenses.

---

## Food

- **Food variety system** — A wider variety of foods raises the food level beyond quantity alone. A food quality multiplier on top of raw food points.
- **Hunting tower consumables** — What hunting towers consume (traps, bait, ammo) is not yet designed.
- **Animal behavior** — Animal spawn rates, pathing, and attraction to hunting towers.
- **Food spoilage** — Whether food decays if the pool overflows a cap.

---

## Transport

- **Railcar routing** — Whether railcar routes are one-way or bidirectional.
- **Belt-to-belt connection** — Auto-snap on placement, or manual linking?
- **Maximum belt segment length** — Whether there is a cap.
- **Railcar operator** — Whether railcars require a worker operator or are fully autonomous.

---

## Hub

- **Hub capacity upgrades** — Whether Hub buffer capacity can be upgraded.
- **Home Hub assignment** — Workers assigned to a specific Hub, enabling per-Hub recall, per-Hub population caps, and granular colony management.

---

## Recall

- **Per-Hub recall** — Requires home Hub assignment. Pull back frontier workers independently of base workers.
- **Auto-recall** — Optional setting to automatically recall all workers at a configurable time before dawn.
- **Recall bell visual/audio** — A world-space cue so all players know the recall fired.

---

## Possession

- **Possession initiation UI** — How possession is triggered (click worker, radial menu, etc.).
- **Possession cooldown** — Whether there is a cooldown after a possessed worker dies.
- **Visual differentiation** — How possessed workers are highlighted per player color (shader outline, overhead marker, etc.).

---

## Multiplayer

- **Online play** — LAN-only for MVP. Online requires relay/STUN server — not yet scoped.
- **Lobby & matchmaking** — Whether a lobby UI is in scope beyond MVP.
- **Player disconnection** — How mid-session disconnection is handled (pause, AI takeover, workers go autonomous).
- **Host migration** — Whether the host role can transfer if the host drops.
- **Split-screen** — Not planned; separate machines only for now.

---

## World

- **Weather system** — Cloudy days reduce solar strength, weakening robots below their normal sine-curve peak. Natural variance in the threat cycle.
- **World progression** — Colonizing the full planet is the stated goal. What comes after — additional planets, harder worlds — is an open question.
- **The map** — Size, layout, biomes, and resource distribution are not yet designed.

---

## Narrative

- **The Awakening** — Triggering event narrative and environmental storytelling. How the mystery of the robots is revealed to players over time.

---

# Part 5 — Open Questions

# The Solar Siege — Open Questions

Implementation questions that need a decision before or during development. Organized by system. These are not shelved features — see FUTURE.md for those.

---

## Worker

- **Name generation** — Wordlist-based, procedural, or hand-authored? What's the pool size?
- **Color application** — How is the clothing color applied to the mesh? Shader parameter, material override, or vertex color?
- **SPEED_SCALE constant** — Needs balancing against BASE_XP_PER_LEVEL. +2% per level is a placeholder.
- **DUAL_SPECIALTY_THRESHOLD** — Exact ratio needs playtesting. Currently undefined.
- **Haul capacity** — How much can a worker carry at once? Fixed or upgradeable?

---

## Balance

- **BASE_XP_PER_LEVEL** — 100 is a placeholder. Total XP to max level (~836k) may need significant adjustment once action times are known.
- **HAUL_XP_PER_METER** — Needs calibration against typical map distances once map size is known.
- **Action times per object** — How long does it take to chop a tree, mine ore, harvest a crop? Depends on base worker speed and SPEED_SCALE.
- **BASE_XP_PER_LEVEL per field** — Should Engineering, Gunnery, and Harvesting have the same XP curve, or should natural action volume differences be accounted for?
- **Solite yield range** — Min and max Solite per batch of scrap processed. Needs balancing.
- **Well-Fed thresholds** — BASE_WELL_FED and BASE_HUNGRY constants need tuning against food production rates.
- **Food consumption rate** — How fast does the colony consume food per worker per second?

---

## Job Board

- **MIN_FIELD_LEVEL** — Minimum level a worker needs in a field for the Job Board to consider them qualified for jobs requiring that field. Soft routing preference, not a hard lock.

---

## Robot

- **GameState autoload** — Needs to be created. Owns `robots_awakened` flag and other global game state.
- **Scrap Processor** — Same building as Shiny Scrap Processor with a different mode, or a separate building?
- **Iridium processor** — Does Iridium require a separate late-game building?
- **Processed output queuing** — Do processed outputs queue in the building until hauled, or auto-deliver to the nearest Hub?

---

## Food

- **Food consumption rate** — Exact rate of food points consumed per worker per second.
- **BASE_WELL_FED / BASE_HUNGRY** — Scaling constants against workforce size.

---

## Transport

- **Track grid resolution** — What is the snapping grid for railroad track placement?
- **Track branching** — How are track branches handled in pathfinding?

---

## Hub

- **Structure range** — At what distance can a structure draw from a Hub buffer?
- **Hub build cost** — How much material is required to build a new Hub?
- **Population cap** — Whether there should be a maximum worker count colony-wide, and if so what determines it (food capacity, Hub count, fixed value).

---

## Possession

- **Input remapping** — How is controller input remapped per player for up to 4 simultaneous players in Godot 4?

---

## Solar Cycle

- **Day/night duration** — Is the 600-second cycle configurable per session, per map, or fixed?
- **Sun visual** — Should the DirectionalLight3D rotation be tied to `current_time` for a visible sun arc?
- **Time speed modifier** — Should players be able to speed up time during low-threat periods?

---

## Multiplayer

- **MultiplayerSynchronizer setup** — Needs implementing on all major nodes (Worker, Robot, SolarCycle, JobBoard, PossessionManager, FoodManager, Hub/ResourceBuffer, ScrapPile).
- **RPC authority model** — All game state mutations should be server-authoritative. Client RPC calls need validation.
