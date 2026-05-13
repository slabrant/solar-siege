# Solar Siege — Design Document Compilation

Complete design and technical documentation. Organized for review and print.

## Contents

1. **Game Design Document (GDD)** — Vision, gameplay, design intent
2. **System Specifications (SYSTEMS)**
    1. SYSTEMS overview (architecture, autoloads, signal flow)
    2. Balance
    3. Colonist
    4. Job Board
    5. Solar Cycle
    6. Robot
    7. Structure (base class)
    8. Hub
    9. Tower
    10. Hunting Tower
    11. Animals
    12. Food
    13. Possession
    14. Recall
    15. Resource Pile
    16. Transport
    17. Processing Building
    18. Production Building
    19. Multiplayer
3. **Future / Long-Term Ideas (FUTURE)**
4. **Open Questions (OPEN_QUESTIONS)**

---


# Part 1 — Game Design Document

# Solar Siege — Game Design Document

**Engine:** Godot 4.6.2
**Genre:** Cooperative Tower Defense / Automation Strategy
**Perspective:** 3D Top-Down with 1st Person Possession

---

## What Is This Game?

A cooperative tower defense game that uses automation and possession. A group of colonists lands on an unknown world, plants a flag, names the planet, and starts building. The early game is peaceful: gather, explore, build the first hub. Then something stirs — and robots begin attacking by day and freezing by night.

Players manage the colony from a top-down strategic view, but can drop into any colonist at any time for direct 1st-person control. Every colonist levels up, develops a specialty, and becomes someone worth protecting.

---

## Core Loop

**Daytime:** Robots attack. Towers fire, colonists build and repair.

**Nighttime:** Robots freeze in place. Colonists salvage scrap, expand the colony, and prepare for the next day.

---

## The Solar Tide

Robot strength follows the arc of the sun. They're at peak power at Noon and weakest at the edges of the day. At night they freeze completely — but they're not gone. Frozen robots are full of salvageable material and can be hauled back to be processed.

---

## Colonists

Colonists are the heart of the colony. Every colonist starts nameless and dark gray. As they gain experience, they earn a name and their clothing shifts in color to reflect their growing skills.

All colonists can do all tasks. Skill level determines speed — not access. Colonists have no weapons and cannot fight — combat belongs entirely to towers.

### Colonist Color

A colonist's clothing color is a live readout of their skill level. No stat screen needed — a glance tells you everything.

- **Red channel** — Gunnery level
- **Green channel** — Harvesting level
- **Blue channel** — Engineering level

All colonists start dark gray. As levels increase, their color shifts toward the field they're developing. A pure Gunner turns red. A pure Engineer turns blue. A Gunner-Engineer turns magenta. A colonist who has maxed all three fields turns white — the visual and mechanical cap.

### The Three Fields

**Engineering** — Building, repairing, expanding, dismantling robots.
- *Construction* — walls, structures, Hub expansion
- *Mechanics* — repair, robot dismantling, salvage processing

**Gunnery** — Tower operation. Gunners don't carry weapons; they operate towers. Higher skill means faster fire rate.
- *Marksman* — combat towers
- *Hunter* — hunting towers

**Harvesting** — Gathering and hauling.
- *Miner* — ore, stone
- *Lumberjack* — wood, trees
- *Farmer* — crops, foraging
- *Hauler* — general transport

A low-level Gunner placed on a strong tower will impede the tower's effectiveness. The tower fires slower and does less damage than a high-skill operator would extract from it, but the Gunner gains experience faster. There's a tradeoff between training and effectiveness.

---

## Food & The Well-Fed Bonus

The colony is always in one of three nutrition states:

- **Hungry** — New colonists cannot be created.
- **Normal** — Standard operation.
- **Well-Fed** — All colonists gain a speed and XP bonus, regardless of where they are on the map.

Food comes from farming, foraging, and hunting. Different foods carry different point values. Food is a single shared pool across the entire colony — colonists don't need to be near a Hub to feel the effect of the bonus.

Food diminishes over time at a rate proportional to colony size.

---

## Hubs

Hubs are the colony's anchor points. Colonists are produced at Hubs, structures draw from Hub buffers, and the colony expands by building new Hubs further out. Food is colony-wide; ammo and materials are stored per Hub.

Hubs can be destroyed by robots. The game continues as long as either Hubs or colonists remain. The colony is lost only when both are gone.

---

## Building & Construction

Construction begins with the player marking a location. The marked location appears on the Job Board as a build job. Once materials are hauled to the site, Engineers can begin work. The structure is complete when work is finished.

Nothing is constructed in mid-air — a job needs both materials and labor at the site.

---

## Robot Salvage

Robots have two separate values: health and scrap. The player only sees the health bar. When a tower damages a robot, both health and scrap go down together. When an Engineer dismantles a robot, only health goes down — scrap is preserved.

This means careful dismantling at night always yields more than gunning a robot down by day.

An Engineer can dismantle an active robot, but the robot fights back proportional to its current solar strength — at noon, this is highly dangerous; at dusk it's marginal; at night it costs nothing. The XP rate is the same regardless. There's no reward for taking the risk — only the option.

A robot collapses into a Resource Pile when its health reaches zero. Piles are hauled back to processing buildings to be broken down into usable materials.

### Materials from Robots

- **Scrap** — Dropped by all robots. Processed into parts, materials, and a variable yield of Solite.
- **Shiny Scrap** — Dropped by late-game robots. Processed into Iridium alongside standard outputs.
- **Solite** — A glowing purple material. Required for advanced production, including conveyor belts.
- **Iridium** — Drives the highest tier of technology.

---

## Resource Piles

When a robot dies, its remaining scrap drops as a Resource Pile. When a Hub is destroyed, its full buffer drops as a pile. When colonists harvest in the field, what they gather goes into a pile rather than a personal inventory — colonists don't carry; they harvest, then haul.

A pile is a physical object that a colonist (or a railcar, or a conveyor belt) can pick up and move.

---

## Production & Manufacturing

Resources don't go directly into buildings — they're processed first. Processing buildings convert raw materials. Production buildings combine processed materials into ammo, components, and building materials. The colony needs a supply chain: gather → haul → process → haul → produce → haul → consume.

Hauling is done on foot at first. The player can lay railroad track to dramatically reduce haul distances — cheap, no Solite required. Conveyor belts come later: fully automated, Solite-required, end-game.

---

## Hunting Towers

Hunting Towers are placed by the player anywhere on the map — they don't need to be near a Hub. Animals roam the world and pass near hunting towers. An assigned Hunter operates the tower to bring food to the colony. The kill yields food, which a colonist must haul back to a Hub before it joins the colony food pool.

Hunting towers are stocked with Stone — their ammunition. Robots may occasionally target hunting towers but they're not primary targets.

---

## The Job Board

The Job Board is the colony's task management system. Every task — mining, construction, hauling, farming, hunting, dismantling — exists as a job on the board with a priority and a location. Colonists automatically claim the highest-priority job they can reach, weighted by proximity.

Jobs are stored in a priority-ordered list. Most jobs are *normal* priority; players can also flag a job *very_much* — pushing it to the very top. The Recall action uses this flag to ensure colonists drop everything immediately.

A more qualified colonist can take a job away from a less qualified one. The qualified colonist doesn't drop what they're doing for trivial reasons — but on important work, the right colonist gets routed in.

Players can post jobs directly: paint an area to harvest, click a single resource, or mark a location for a structure. A colonist working an area continues until either the resources are gone or they die.

There's an **idle colonist** indicator so players can find anyone not currently engaged.

Each colonist has a configurable **range cutoff** for jobs — adjustable from the Job Board. Colonists won't pick up tasks beyond that range.

---

## Possession

Any player can possess any colonist at any time. In possession mode, the camera shifts to 1st person and the player controls the colonist directly — faster, stronger, and more capable than their AI self.

Combat structures (towers) are controlled by possessing the assigned Gunner. The Gunner's skill applies on top of player input.

A possessed colonist can die. The player returns to the strategic view. The game doesn't end — but losing a veteran is a real loss.

---

## Recall

Any player can sound a colony-wide recall from the strategic view. Every non-possessed colonist drops their current task and paths to their nearest Hub. When the recall is lifted, colonists re-evaluate the Job Board and resume work.

---

## The Three Ages

The Three Ages are a way of thinking about progression, not a hard rule. Nothing is locked. The ages describe a philosophy of play — where the game tends to be at a given moment — not a gate.

**Age of Manual Labor** — Everything is done by hand. Colonists mine, chop, haul, hunt, and build. Getting the first Hub defended and fed is the whole challenge.

**Age of Automation** — Railcars and eventually conveyor belts take over transport. Production buildings come online. Colonists shift into more specialized roles.

**Age of Industry** — Massive automated fortresses. Iridium flows into advanced production. A few legendary colonists oversee systems that would have been unthinkable at the start.

---

# Part 2 — System Specifications

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

## Conventions

- All tunable constants live in `Balance.gd` (see Balance.md). System docs reference by name with `# see Balance.md`.
- Godot groups used: `"Hubs"`, `"Colonists"`, `"Robots"`, `"Animals"`, `"ResourcePiles"`.
- Resource type strings: `"Ammo"`, `"Stone"`, `"Metal"`, `"Lumber"`, `"Scrap"`, `"ShinyScrap"`, `"Solite"`, `"Iridium"`, `"Food"`, `"BuildingMaterials"`, `"Components"`.
- Field strings: `"Engineering"`, `"Gunnery"`, `"Harvesting"`.
- All structures inherit from `Structure` (see Structure.md) — they share construction, damage, destruction, and withdrawal contracts.
- `GameState.robots_awakened` gates all robot spawning; flips to `true` the first time a robot is dismantled.

---

# Balance Reference

All tunable constants for the game. Single source of truth. Referenced by name from system docs.

A `Balance.gd` autoload could be derived directly from this file.

---

```gdscript
# Balance.gd

# --- XP & Progression ---
const XP_PER_HEALTH: float            = 1.0     # XP per health point processed, all fields
const HAUL_XP_PER_METER: float        = 0.5     # Harvesting XP per meter hauled
const BASE_XP_PER_LEVEL: float        = 100.0   # XP for level n = BASE_XP_PER_LEVEL * n
const MAX_LEVEL: int                   = 128     # per field; also color channel range

# --- Color ---
const BASE_COLOR_CHANNEL: int         = 127     # starting gray; max channel = 127 + MAX_LEVEL

# --- Speed & Bonuses ---
const SPEED_SCALE: float              = 0.02    # +2% task speed per level
const POSSESSION_BONUS: float         = 1.5     # multiplier on all task speeds while possessed
const HAUL_CAPACITY_BASE: float       = 50.0    # base haul capacity in resource units
const HAUL_CAPACITY_PER_LEVEL: float  = 1.0     # Harvesting level adds to capacity

# --- Dual Specialty ---
const DUAL_SPECIALTY_THRESHOLD: float = 0.0     # ratio; needs playtesting

# --- Well-Fed ---
const WELL_FED_SPEED_BONUS: float     = 1.25
const WELL_FED_XP_BONUS: float        = 1.50
const BASE_WELL_FED: float            = 50.0    # points per colonist for Well-Fed threshold
const BASE_HUNGRY: float              = 10.0    # points per colonist for Hungry threshold
const FOOD_CONSUMPTION_RATE: float    = 0.1     # food consumed per colonist per second

# --- Hub Spawning ---
const COLONIST_FOOD_COST: float       = 25.0    # food cost to queue a new colonist
const SPAWN_DURATION: float           = 30.0    # seconds to produce one colonist

# --- Job Board ---
const RANGE_CUTOFF_DEFAULT: float     = 200.0   # default per-colonist range limit; configurable in UI
const QUAL_PREEMPT_LEVEL_GAP: int     = 20      # level gap required for a qualified colonist to preempt
```

---

## Object Health Values

Health doubles as XP yield — a 200hp tree gives 200 Harvesting XP.

### Natural Resources

| Object              | Health |
|---------------------|--------|
| Small tree          | 100    |
| Large tree          | 300    |
| Ore deposit (small) | 150    |
| Ore deposit (large) | 500    |
| Stone deposit       | 200    |
| Basic crop          | 20     |
| Premium crop        | 100    |
| Foraged item        | 10     |

### Animals

See SYSTEMS/Animals.md for behavior. XP is awarded as Gunnery.

| Animal | Health | Food Yield |
|--------|--------|------------|
| Bunny  | 60     | 30         |
| Turkey | 120    | 80         |
| Deer   | 240    | 200        |

### Robots

| Robot Type  | Health | Base Scrap | Notes                       |
|-------------|--------|------------|-----------------------------|
| Basic robot | 200    | 200        | Early game                  |
| Heavy robot | 600    | 600        | Late game; drops ShinyScrap |

### Structures

Building and repairing awards Engineering XP equal to health restored.

| Structure           | Health |
|---------------------|--------|
| Wall segment I      | 200    |
| Wall segment II     | 400    |
| Wall segment III    | 600    |
| Tower               | 400    |
| Hunting tower       | 300    |
| Processing building | 800    |
| Production building | 1000   |
| Hub                 | 3000   |
| Rail track segment  | 50     |
| Conveyor segment    | 120    |

---

## Pacing Sanity Check

Full day cycle: 600 real seconds. Day and night are each 300 seconds.

| Action                         | Time Per Action | XP Per Day (est.)     |
|--------------------------------|-----------------|-----------------------|
| Chop small trees               | ~15s            | ~4,000 Harvesting     |
| Mine ore (small)               | ~20s            | ~4,500 Harvesting     |
| Harvest basic crops            | ~3s             | ~4,000 Harvesting     |
| Build wall segments            | ~10s            | ~12,000 Engineering   |
| Dismantle basic robots (night) | ~30s            | ~4,000 Engineering    |
| Haul 50m loads                 | ~10s travel     | ~1,500 Harvesting     |

At ~4,000 XP/day: level 10 in ~2 days, level 50 in ~30 days, level 128 in ~200 days.

Specialties emerge in the first few days. Dual-specialties are mid-game. White-clad veterans are late-game.

---

# System: Colonist

Colonists are the primary agents of the colony. They execute tasks autonomously via the Job Board, level up through labor, and can be possessed for direct control. See GDD for design intent.

---

## Data

```gdscript
class_name Colonist extends CharacterBody3D

@export var base_speed: float = 5.0

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

# Identity
var colonist_name: String = ""
var is_new: bool = true                        # true until first specialty earned

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

var specialty: String = ""                     # "" until earned; e.g. "Gunner", "Gunner-Engineer"

# Task state
var current_job: Job = null
var is_force_tasked: bool = false
var is_recalled: bool = false
var range_cutoff: float = RANGE_CUTOFF_DEFAULT # see Balance.md; configurable per colonist

# Possession state
var is_possessed: bool = false
var possessing_player: int = -1
```

A colonist does not have an inventory. Harvested resources drop as Resource Piles in the world (see SYSTEMS/ResourcePile.md). Hauling moves piles from place to place.

---

## XP & Levels

XP = health points processed. Every action in every field follows this rule.

```gdscript
func award_xp(field: String, health_processed: float) -> void:
    xp[field] += health_processed * XP_PER_HEALTH  # see Balance.md
    _check_level_up(field)

func _check_level_up(field: String) -> void:
    var next_level = levels[field] + 1
    if next_level > MAX_LEVEL:                     # see Balance.md
        return
    if xp[field] >= BASE_XP_PER_LEVEL * next_level: # see Balance.md
        levels[field] = next_level
        _update_color()
        _update_specialty()
        level_up.emit(field, levels[field])
```

Hauling is XP per meter traveled while carrying a load. This bypasses `award_xp` because `HAUL_XP_PER_METER` is already a direct XP rate:

```gdscript
func _on_haul_progress(meters: float) -> void:
    xp["Harvesting"] += meters * HAUL_XP_PER_METER  # see Balance.md
    _check_level_up("Harvesting")
```

---

## Color

Clothing color is the live visual readout of skill level.

```gdscript
func _update_color() -> void:
    var r = BASE_COLOR_CHANNEL + levels["Gunnery"]      # see Balance.md
    var g = BASE_COLOR_CHANNEL + levels["Harvesting"]
    var b = BASE_COLOR_CHANNEL + levels["Engineering"]
    _apply_color_to_mesh(Color(r / 255.0, g / 255.0, b / 255.0))
```

| Field(s) at max level    | Color     |
|--------------------------|-----------|
| None                     | Dark gray |
| Gunnery                  | Red       |
| Harvesting               | Green     |
| Engineering              | Blue      |
| Gunnery + Engineering    | Magenta   |
| Gunnery + Harvesting     | Yellow    |
| Engineering + Harvesting | Cyan      |
| All three                | White     |

---

## Specialty

Recomputed on every level-up. The colonist's highest field is their specialty. If two fields are both significantly elevated relative to the third, the colonist earns a dual specialty.

```gdscript
func _update_specialty() -> void:
    var fields = levels.keys()
    fields.sort_custom(func(a, b): return levels[a] > levels[b])
    var top    = levels[fields[0]]
    var second = levels[fields[1]]
    var third  = levels[fields[2]]

    if top <= 0:
        specialty = ""
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
    if is_new and specialty != "":
        is_new = false
        _generate_name()
    specialty_changed.emit(specialty)
```

### Sub-Specialties

Cosmetic only — drives no logic. Used for flavor display.

| Field        | Sub-Specialties                              |
|--------------|----------------------------------------------|
| Engineering  | Construction, Mechanics                      |
| Gunnery      | Marksman, Hunter                             |
| Harvesting   | Miner, Lumberjack, Farmer, Hauler            |

---

## Task Speed

Level scales task speed. All colonists perform all tasks — skill determines how fast.

```gdscript
func get_task_speed(field: String) -> float:
    var speed = base_speed * (1.0 + levels[field] * SPEED_SCALE)  # see Balance.md
    if is_possessed:
        speed *= POSSESSION_BONUS                                  # see Balance.md
    return speed
```

---

## Haul Capacity

```gdscript
func get_haul_capacity() -> float:
    return HAUL_CAPACITY_BASE + levels["Harvesting"] * HAUL_CAPACITY_PER_LEVEL  # see Balance.md
```

A maxed-out Harvester carries significantly more per trip than a fresh colonist.

---

## Combat

Colonists have no weapons. They cannot attack robots or animals. Combat is handled exclusively by towers.

---

## Job Assignment

```gdscript
func _ready() -> void:
    JobBoard.jobs_updated.connect(_on_jobs_updated)
    _find_new_job()

func _on_jobs_updated() -> void:
    if not is_force_tasked and not is_recalled:
        _find_new_job()
```

Possession contract (`on_possess`, `on_unpossess`) and death handling are defined in SYSTEMS/Possession.md.

---

## Signals

```gdscript
signal specialty_changed(new_specialty: String)
signal level_up(field: String, new_level: int)
signal colonist_died(colonist: Node3D)
```

---

## Dependencies

- `JobBoard` (autoload)
- `PossessionManager` (autoload)
- `FoodManager` (autoload)
- `NavigationAgent3D`

---

# System: Job Board

The Job Board is a global singleton holding every available task in the colony. Colonists query it for their next assignment. Players post jobs, force-task colonists, and configure routing here.

---

## Data

```gdscript
# JobBoard (autoload)

var jobs: Array[Job] = []   # ordered list, highest priority first
```

### Job Resource

```gdscript
class_name Job extends Resource

enum JobType { CONSTRUCTION, REPAIR, MINING, HAULING, FARMING, HUNTING, DISMANTLING, OPERATE_TOWER }

var id: String
var type: JobType
var location: Vector3
var required_field: String = ""    # "Engineering", "Gunnery", "Harvesting", or "" for any
var assigned_colonist: Node3D = null
var metadata: Dictionary = {}
```

---

## Priority

Priority is the colonist's position in the ordered `jobs` list, not an enum. When a job is posted, it inserts into the list at the appropriate position.

Most jobs are added at a default position. A job flagged `very_much` is inserted at the very top, ahead of all other work — used by Recall and other urgent player actions to ensure colonists drop everything.

```gdscript
func add_job(job: Job, very_much: bool = false) -> String:
    if very_much:
        jobs.push_front(job)
    else:
        jobs.append(job)
    jobs_updated.emit()
    return job.id

func remove_job(id: String) -> void:
    jobs = jobs.filter(func(j): return j.id != id)
    jobs_updated.emit()
```

---

## Assignment

A colonist queries for the best job they can reach within their `range_cutoff`:

```gdscript
func get_best_job_for(colonist: Node3D) -> Job:
    for job in jobs:
        if job.location.distance_to(colonist.global_position) > colonist.range_cutoff:
            continue
        if job.assigned_colonist == null:
            return job
        if _can_preempt(colonist, job):
            return job
    return null
```

Jobs are evaluated in priority order. The first reachable, takeable job wins. No sorting is needed at query time — the list is already ordered.

---

## Qualification & Preemption

A more qualified colonist can take a job away from a less qualified one — but only on jobs that have a `required_field`, and only when the skill gap is significant.

```gdscript
func _can_preempt(colonist: Node3D, job: Job) -> bool:
    if job.assigned_colonist == null:
        return true
    if job.required_field == "":
        return false                         # no field gate — first-come-first-served
    var their_level = job.assigned_colonist.levels[job.required_field]
    var my_level    = colonist.levels[job.required_field]
    return my_level - their_level >= QUAL_PREEMPT_LEVEL_GAP  # see Balance.md
```

The preempted colonist re-evaluates the Job Board on the next `jobs_updated` cycle and picks something else. They don't drop their current action mid-swing — they finish the tick and move on.

---

## Re-Assignment

When `jobs_updated` fires, colonists not force-tasked or recalled call `get_best_job_for(self)`. If a better job exists, they release the current one and take the new one.

Force-tasked colonists ignore `jobs_updated` until released.

---

## Range Cutoff

Each colonist has a `range_cutoff` field that limits how far they'll travel for a job. Default is in Balance.md. Adjustable from the Job Board UI per colonist — a player might give a homebody colonist a small radius and a scout a large one.

---

## Player-Initiated Jobs

Players can post jobs directly:

- **Area paint** — Select an area of the map; every resource of the chosen type within the area becomes a job
- **Single target** — Click one resource or structure to add it to the board
- **Build location** — Mark a spot for a structure. Materials are auto-requested via HAULING jobs; once delivered, the CONSTRUCTION job becomes takeable
- **Force task** — Lock a specific colonist to a specific job
- **Very_much** — Flag a job to jump to the top of the queue

A colonist working an area continues until either the resources are exhausted or they die.

---

## Idle Indicator

The Job Board exposes which colonists currently have no job. The UI presents a **Find Idle Colonist** action to focus the camera on one.

```gdscript
func get_idle_colonists() -> Array:
    return get_tree().get_nodes_in_group("Colonists").filter(func(c): return c.current_job == null)
```

---

## Signals

```gdscript
signal jobs_updated
```

---

## Dependencies

- `Colonist` nodes — query jobs, hold assignments
- Scene systems — post jobs when conditions arise (low buffer → HAULING, fresh ResourcePile → HAULING, etc.)

---

# System: Solar Cycle

The Solar Cycle is the heartbeat of the game. Time advances, the phase changes, and solar strength scales robot behavior.

---

## Data

```gdscript
# SolarCycle (autoload)

enum DayPhase { DAY, NIGHT }

@export var day_duration: float = 600.0   # real seconds per full 24-hour cycle
@export var start_time: float = 6.0

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

    _emit_hour_changed_if_crossed()

    var new_phase = DayPhase.DAY if (current_time >= 6.0 and current_time < 18.0) else DayPhase.NIGHT
    if new_phase != current_phase:
        current_phase = new_phase
        phase_changed.emit(current_phase)
```

**Day:** 6:00 – 18:00
**Night:** 18:00 – 6:00

---

## Solar Strength

```gdscript
func get_solar_strength() -> float:
    if current_phase == DayPhase.NIGHT:
        return 0.0
    var theta = ((current_time - 6.0) / 12.0) * PI  # 6AM=0, Noon=PI/2, 6PM=PI
    return sin(theta)
```

Returns a float in `[0.0, 1.0]`. Used by Robot for speed/damage scaling and Engineering dismantling for thorns damage.

---

## Signals

```gdscript
signal hour_changed(hour: int)                # emits when the hour rolls over (1-24)
signal phase_changed(phase: DayPhase)         # emits on transition only
```

`hour_changed` fires once per in-game hour, not every frame. Quarter-hour granularity is reserved for the clock UI to compute locally.

Consumers compare against `SolarCycle.DayPhase.DAY` or `SolarCycle.DayPhase.NIGHT`.

---

# System: Robot

Robots are the primary threat and the sole source of Scrap, ShinyScrap, Solite, and Iridium. Managing the robot threat and the robot economy are the same problem.

---

## Data

```gdscript
class_name Robot extends CharacterBody3D

@export var max_health: float = 200.0
@export var base_speed: float = 3.0
@export var base_damage: float = 10.0
@export var base_scrap: float = 200.0
@export var is_heavy: bool = false        # drops ShinyScrap instead of Scrap

var health: float = max_health
var scrap: float = base_scrap             # tracked separately; only reduced by combat damage
var is_frozen: bool = false
var target: Node3D = null

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
```

---

## Health vs Scrap

Two separate values. Only health is visible to the player. The rules:

- **Combat damage** (from towers) reduces both `health` and `scrap` proportionally
- **Dismantling** (from Engineers) reduces only `health` — `scrap` is preserved

```gdscript
func take_combat_damage(amount: float) -> void:
    var ratio = scrap / max(health, 0.001)
    health -= amount
    scrap -= amount * ratio
    scrap = max(scrap, 0.0)
    if health <= 0:
        _die()

func take_dismantle_damage(amount: float) -> void:
    health -= amount
    if health <= 0:
        _die()
```

---

## Thorns (Active Dismantling)

When an Engineer dismantles a robot that is not frozen, the robot fights back. Damage to the colonist scales with the robot's current solar strength:

```gdscript
func on_dismantled_by(colonist: Colonist, amount: float) -> void:
    take_dismantle_damage(amount)
    if not is_frozen:
        var thorns = base_damage * SolarCycle.get_solar_strength()
        colonist.take_damage(thorns)
```

At noon, thorns hurt the most. At dusk, less. At night (frozen), zero — dismantling is safe. Engineering XP is the same rate regardless.

---

## Death

```gdscript
func _die() -> void:
    var pile = preload("res://scenes/ResourcePile.tscn").instantiate()
    pile.contents = { ("ShinyScrap" if is_heavy else "Scrap"): scrap }
    get_parent().add_child(pile)
    pile.global_position = global_position
    robot_died.emit(self)
    queue_free()
```

---

## Movement & Combat

```gdscript
func _physics_process(delta: float) -> void:
    if is_frozen or health <= 0:
        return

    var boost = 1.0 + SolarCycle.get_solar_strength()
    nav_agent.target_position = target.global_position
    var dir = global_position.direction_to(nav_agent.get_next_path_position())
    velocity = dir * base_speed * boost
    move_and_slide()

    if nav_agent.is_navigation_finished():
        _attack(delta, boost)

func _attack(delta: float, boost: float) -> void:
    if target.has_method(&"take_damage"):
        target.take_damage(base_damage * boost * delta)
```

---

## Freeze / Thaw

```gdscript
func _on_phase_changed(phase: SolarCycle.DayPhase) -> void:
    is_frozen = (phase == SolarCycle.DayPhase.NIGHT)
    set_physics_process(not is_frozen)
```

---

## Awakening

Robots do not spawn or activate at game start. The awakening trigger fires when the first robot is dismantled — a global `GameState.robots_awakened` flag is set, and waves begin spawning at the next dawn.

How the first dismantle is set up — and how the first robot appears in the world for that to happen — is in OPEN_QUESTIONS.md.

---

## Signals

```gdscript
signal robot_died(robot: Node3D)
```

---

## Dependencies

- `SolarCycle` (autoload)
- `GameState` (autoload, planned)
- `NavigationAgent3D`
- `ResourcePile` scene

---

# System: Structure (Base Class)

All built objects in the colony — Hubs, Towers, Hunting Towers, Processing Buildings, Production Buildings, Walls — share a common base. This document defines that base. Specific structure docs only describe what's unique about them.

---

## Construction Flow

A structure goes through three phases:

1. **Marked** — Player marks a location. A `BUILD` job appears on the Job Board.
2. **Materials Pending** — `HAULING` jobs are auto-posted for each required input. The structure cannot be worked on yet.
3. **Under Construction** — Once all materials are at the site, Engineers can begin. Progress accrues in health points. When `health == max_health`, the structure is complete and operational.

A structure marker has zero health while waiting for materials. Once construction starts, health accrues until `max_health` is reached.

---

## Data

```gdscript
class_name Structure extends StaticBody3D

@export var max_health: float       # set per structure type; see Balance.md
@export var build_cost: Dictionary  # type → amount required to construct

var health: float = 0.0             # starts at 0; rises during construction
var is_complete: bool = false
```

---

## Damage & Destruction

All structures take damage and can be destroyed.

```gdscript
func take_damage(amount: float) -> void:
    health -= amount
    if health <= 0:
        _die()

func _die() -> void:
    _drop_remaining_resources()  # if applicable; defined per structure
    structure_destroyed.emit()
    queue_free()
```

Engineers can repair damaged structures. Repair awards Engineering XP equal to health restored, identical to construction.

---

## Resource Withdrawal

Operational structures expose a `withdraw` interface for entities that pull resources from them:

```gdscript
func withdraw(type: String, amount: float) -> float:
    # returns amount actually withdrawn (≤ requested)
```

Withdrawers include `Colonist`, `Railcar`, and `Conveyor`. The structure decides whether to allow the request.

---

## Signals

```gdscript
signal structure_built()
signal structure_destroyed()
signal structure_damaged(amount: float)
```

These signals are inherited by all specific structure types and need not be re-declared.

---

## Subtypes

Each subtype only documents what's unique to it. None of them re-document damage, destruction, or repair.

| Subtype             | Doc                              |
|---------------------|----------------------------------|
| Hub                 | SYSTEMS/Hub.md                   |
| Tower               | SYSTEMS/Tower.md                 |
| Hunting Tower       | SYSTEMS/HuntingTower.md          |
| Processing Building | SYSTEMS/ProcessingBuilding.md    |
| Production Building | SYSTEMS/ProductionBuilding.md    |
| Wall                | (see Balance.md health tiers)    |

---

# System: Hub

Anchor points of the colony. Colonists are produced here. Local resource buffers for ammo and materials. The colony expands by building new Hubs. Base behavior is in SYSTEMS/Structure.md.

---

## Data

```gdscript
class_name Hub extends Structure

@onready var buffer: ResourceBuffer = $ResourceBuffer

# Spawn queue
var spawn_queue: int = 0
var spawn_progress: float = 0.0
```

### ResourceBuffer

```gdscript
class_name ResourceBuffer extends Node

signal buffer_changed(type: String, amount: float)
signal buffer_empty(type: String)

var amounts: Dictionary = {
    "Ammo":    0.0,
    "Stone":   0.0,
    "Metal":   0.0,
    "Lumber":  0.0,
    "Solite":  0.0,
    "Iridium": 0.0,
}

func add(type: String, amount: float) -> float       # returns overflow
func withdraw(type: String, amount: float) -> float  # returns amount taken
func get_amount(type: String) -> float
```

---

## Spawning Colonists

Players initiate spawning by clicking a Hub. Each request:

1. Confirms `FoodManager.nutrition_state != HUNGRY` (cannot queue while Hungry)
2. Deducts `COLONIST_FOOD_COST` from the global food pool (see Balance.md)
3. Adds one to `spawn_queue`

Queued colonists are produced even if the colony becomes Hungry mid-production — the food was already paid.

```gdscript
func request_spawn() -> bool:
    if FoodManager.nutrition_state == FoodManager.NutritionState.HUNGRY:
        return false
    if not FoodManager.consume_food(COLONIST_FOOD_COST):  # see Balance.md
        return false
    spawn_queue += 1
    return true

func _process(delta: float) -> void:
    if spawn_queue == 0:
        return
    spawn_progress += delta
    if spawn_progress >= SPAWN_DURATION:  # see Balance.md
        spawn_progress = 0.0
        spawn_queue -= 1
        _spawn_colonist()

func _spawn_colonist() -> void:
    var c = preload("res://scenes/Colonist.tscn").instantiate()
    get_parent().add_child(c)
    c.global_position = $SpawnPoint.global_position
    c.add_to_group("Colonists")
    colonist_spawned.emit(c)
```

If the Hub is destroyed mid-queue, queued colonists are lost. The food cost is not refunded.

---

## Resource Delivery & Withdrawal

Food deliveries route to `FoodManager`, not the local buffer. Everything else (Ammo, Metal, Stone, Lumber, Solite, Iridium) lands in the Hub's `ResourceBuffer`.

The Hub uses the base `Structure.withdraw` contract — colonists, railcars, and conveyors all pull resources through the same interface.

---

## Destruction

When destroyed, the Hub's full buffer drops as a Resource Pile at its location:

```gdscript
func _drop_remaining_resources() -> void:
    var pile = preload("res://scenes/ResourcePile.tscn").instantiate()
    pile.contents = buffer.amounts.duplicate()
    get_parent().add_child(pile)
    pile.global_position = global_position
```

---

## Game Over

The colony is lost when there are no Hubs and no Colonists. Either alone is enough to continue.

```gdscript
# GameState
func _check_game_over() -> void:
    var colonists = get_tree().get_nodes_in_group("Colonists").size()
    var hubs      = get_tree().get_nodes_in_group("Hubs").size()
    if colonists == 0 and hubs == 0:
        game_over.emit()
```

---

## Signals

Inherits from Structure. Adds:

```gdscript
signal colonist_spawned(colonist: Node3D)
```

---

## Dependencies

- `FoodManager`
- `Colonist` scene
- `ResourceBuffer`
- `ResourcePile` scene

---

# System: Tower

Combat structures placed by the player to defend against robots. Base behavior is in SYSTEMS/Structure.md.

---

## Data

```gdscript
class_name Tower extends Structure

@export var base_fire_rate: float = 1.0   # shots per second at level 0 Gunnery
@export var damage: float = 20.0
@export var ammo_per_shot: float = 1.0
@export var attack_range: float = 30.0
@export var ammo_capacity: float = 100.0  # local stockpile

var ammo: float = 0.0
var assigned_gunner: Colonist = null
var current_target: Robot = null

@onready var timer: Timer = $Timer
@onready var barrel: Node3D = $Barrel
```

---

## Local Ammo

Towers hold their own ammo up to `ammo_capacity`. Haulers deliver from production buildings to the tower. When ammo runs dry, the tower stops firing until resupplied — `HAULING` jobs are auto-posted as ammo runs low.

Towers do not pull from Hub buffers automatically. Resupply is an explicit hauling task.

---

## Fire Logic

```gdscript
func _on_timer_timeout() -> void:
    # update fire rate based on current Gunner skill
    var skill_bonus = 1.0
    if assigned_gunner:
        skill_bonus = 1.0 + assigned_gunner.levels["Gunnery"] * SPEED_SCALE  # see Balance.md
    timer.wait_time = 1.0 / (base_fire_rate * skill_bonus)

    if not current_target or not is_instance_valid(current_target):
        current_target = _find_target_in_range()
        if not current_target:
            return

    if ammo < ammo_per_shot:
        return
    ammo -= ammo_per_shot
    _fire()

func _fire() -> void:
    var effective_damage = damage
    if assigned_gunner:
        effective_damage *= 1.0 + assigned_gunner.levels["Gunnery"] * SPEED_SCALE
    current_target.take_combat_damage(effective_damage)
    tower_fired.emit(current_target)
```

A low-level Gunner makes the tower fire slower and deal less damage than a high-level one would. This is the explicit tradeoff: assigning weak Gunners to strong towers builds them up at the cost of effective firepower.

---

## Gunner Assignment

A Gunner is assigned via a Job Board task (`OPERATE_TOWER`) or direct player command. While assigned, the Gunner earns Gunnery XP equal to health damage dealt by the tower.

If no Gunner is assigned, the tower fires at base rate and base damage. It still works — just at minimum effectiveness.

---

## Signals

Inherits from Structure. Adds:

```gdscript
signal tower_fired(target: Robot)
```

---

## Dependencies

- `Colonist` — assigned Gunner provides skill bonus
- `Robot` — target via `take_combat_damage`
- `PossessionManager` — player control via possessed Gunner
- `JobBoard` — posts HAULING jobs as ammo runs low

---

# System: Hunting Tower

A type of Tower (see SYSTEMS/Tower.md) specialized for hunting. This doc covers only what's different.

---

## Key Differences from Tower

- **Targets animals**, not robots
- **Consumes Stone** as ammunition instead of Ammo
- **Produces food on kill**, which drops as a Resource Pile at the tower's location
- **Can be placed anywhere on the map** — no Hub proximity required
- **Robots may target hunting towers**, but they are not primary targets
- **Attracts animals** within an `attraction_radius`

---

## Data

```gdscript
class_name HuntingTower extends Tower

@export var attraction_radius: float = 60.0
```

`ammo_per_shot` is interpreted as Stone per shot. Other Tower fields (`base_fire_rate`, `damage`, `attack_range`, `ammo_capacity`) function identically.

---

## Food Yield

When an animal is killed by a hunting tower, the food yield drops as a Resource Pile (containing `Food` type) at the tower's location. A Hauler is needed to bring it to a Hub before it joins the colony food pool.

```gdscript
func _on_animal_killed(animal: Animal) -> void:
    var pile = preload("res://scenes/ResourcePile.tscn").instantiate()
    pile.contents = { "Food": animal.food_yield }
    get_parent().add_child(pile)
    pile.global_position = global_position
    animal_killed.emit(animal)
```

---

## Animal Attraction

Animals within `attraction_radius` are drawn toward the tower. See SYSTEMS/Animals.md.

---

## Signals

Inherits from Tower. Adds:

```gdscript
signal animal_killed(animal: Animal)
```

---

## Dependencies

- `Animal` — target nodes; see SYSTEMS/Animals.md
- `ResourcePile` — food yield drop

---

# System: Animals

Animals roam the map ambient to the colony. They are the source of food for Hunters. They have no significance beyond hunting — they don't attack, they don't interact with structures, they wander.

---

## Data

```gdscript
class_name Animal extends CharacterBody3D

@export var max_health: float
@export var base_speed: float = 2.0
@export var food_yield: float          # delivered as Food on kill

var health: float
var attracted_to: HuntingTower = null  # if drawn by a nearby tower
```

---

## Species

See Balance.md for health and yield values per species.

| Species | Notes                   |
|---------|-------------------------|
| Bunny   | Small, fast, low yield  |
| Turkey  | Medium                  |
| Deer    | Large, slow, high yield |

---

## Behavior

Animals wander randomly. If a `HuntingTower` is within its `attraction_radius`, the animal drifts toward it. The wander/attraction balance and exact movement model are in OPEN_QUESTIONS.md.

```gdscript
func _physics_process(delta: float) -> void:
    if attracted_to:
        _move_toward(attracted_to.global_position, delta)
    else:
        _wander(delta)
```

---

## Damage

```gdscript
func take_damage(amount: float) -> void:
    health -= amount
    if health <= 0:
        _die()

func _die() -> void:
    animal_died.emit(self)
    queue_free()
```

The hunting tower handles food-yield drop on kill — see SYSTEMS/HuntingTower.md.

---

## Spawning

Animals spawn naturally around the map. Spawn rates, density, and distribution are in OPEN_QUESTIONS.md.

---

## Signals

```gdscript
signal animal_died(animal: Animal)
```

---

# System: Food

A single shared pool. The colony's nutrition state affects colonist output and spawning.

---

## Nutrition States

```gdscript
enum NutritionState { HUNGRY, NORMAL, WELL_FED }
```

| State    | Condition                        | Effect                         |
|----------|----------------------------------|--------------------------------|
| Hungry   | Food pool below hungry threshold | New colonists cannot be queued |
| Normal   | Between thresholds               | No modifier                    |
| Well-Fed | Above well-fed threshold         | Speed and XP bonus colony-wide |

Thresholds scale with current colony size:

```gdscript
var colonist_count = get_tree().get_nodes_in_group("Colonists").size()
var well_fed_threshold: float = BASE_WELL_FED * colonist_count   # see Balance.md
var hungry_threshold: float   = BASE_HUNGRY * colonist_count     # see Balance.md
```

---

## Global Food Pool

```gdscript
# FoodManager (autoload)

var food_points: float = 0.0
var nutrition_state: NutritionState = NutritionState.NORMAL

func add_food(amount: float) -> void:
    food_points += amount
    _evaluate_nutrition()

func consume_food(amount: float) -> bool:
    if food_points < amount:
        return false
    food_points -= amount
    _evaluate_nutrition()
    return true
```

Food is consumed over time proportional to colony size:

```gdscript
func _process(delta: float) -> void:
    var colonist_count = get_tree().get_nodes_in_group("Colonists").size()
    food_points -= FOOD_CONSUMPTION_RATE * colonist_count * delta  # see Balance.md
    food_points = max(food_points, 0.0)
    _evaluate_nutrition()
```

---

## Food Sources

| Source          | Field      | Sub-Specialty | Job Type |
|-----------------|------------|---------------|----------|
| Crops, foraging | Harvesting | Farmer        | FARMING  |
| Hunting tower   | Gunnery    | Hunter        | HUNTING  |

Hunting yields drop as Resource Piles at the hunting tower. A Hauler must bring them to a Hub before they count toward the global pool — see SYSTEMS/HuntingTower.md.

---

## Well-Fed Bonus

When `NutritionState == WELL_FED`, every colonist gains `WELL_FED_SPEED_BONUS` to task speed and `WELL_FED_XP_BONUS` to XP gain rate (see Balance.md). Applied colony-wide; no proximity to Hubs required.

---

## Signals

```gdscript
signal nutrition_changed(new_state: NutritionState)
signal food_delivered(amount: float, source: String)
```

---

## Dependencies

- `Colonist` — applies Well-Fed bonus
- `Hub` — receives food deliveries
- `JobBoard` — FARMING and HUNTING jobs
- `"Colonists"` group — for count

---

# System: Possession

Any player can drop into any colonist for direct 1st-person control. Possession gives a flat task-speed multiplier on top of skill — see `POSSESSION_BONUS` in Balance.md.

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

- One colonist per player at a time
- One player per colonist at a time
- Possessed colonists are visually highlighted for all players
- Exiting possession returns the player to their strategic view at its last position

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

---

## Colonist Contract

The Colonist node implements:

```gdscript
func on_possess(player_id: int) -> void:
    is_possessed = true
    possessing_player = player_id
    $Camera3D.make_current()

func on_unpossess() -> void:
    is_possessed = false
    possessing_player = -1
    _find_new_job()
```

On colonist death while possessed, `PossessionManager.unpossess()` is called before `queue_free()`. The player returns to the strategic view. The game does not end.

---

## Towers via Gunners

Possessing the Gunner assigned to a tower gives the player direct control of that tower's aim and fire through them. Gunnery skill and possession bonus both apply.

---

## Signals

```gdscript
signal possession_changed(player_id: int, unit: Node3D, is_possessed: bool)
```

---

## Dependencies

- `Colonist` — implements `on_possess` / `on_unpossess`
- `StrategicCamera` — per-player camera returned to on exit
- `InputManager` (planned) — per-player controller mapping

---

# System: Recall

A colony-wide bell. Any player can sound it from the strategic view. All non-possessed colonists drop their work and path to their nearest Hub.

---

## Trigger

```gdscript
# GameState or a RecallManager
func recall_all() -> void:
    for c in get_tree().get_nodes_in_group("Colonists"):
        if not c.is_possessed:
            c.recall()

func release_recall() -> void:
    for c in get_tree().get_nodes_in_group("Colonists"):
        c.release_recall()
```

The recall is implemented by posting `very_much` priority "go to nearest Hub" jobs on the Job Board (see SYSTEMS/JobBoard.md). This guarantees those jobs override anything else in the queue.

Possessed colonists are exempt.

---

## Colonist Side

```gdscript
# Colonist
func recall() -> void:
    is_recalled = true
    if current_job:
        current_job.assigned_colonist = null
        current_job = null
    navigation_agent.target_position = _find_nearest_hub().global_position

func release_recall() -> void:
    is_recalled = false
    _find_new_job()
```

Colonists are not tied to a specific Hub — nearest at the time of recall determines the destination.

On release, colonists re-evaluate the Job Board. Their interrupted job is back on the board at its prior position.

---

## Signals

```gdscript
signal recall_triggered()
signal recall_released()
```

---

# System: Resource Pile

A physical object holding one or more resource types. Spawned by anything that produces resources in the world: a dying robot, a harvested tree, a destroyed Hub, a hunting tower kill. Any haulable thing.

Colonists do not have inventories. Harvesting moves the resource from its source (tree, ore deposit, robot) into a ResourcePile at the location. Hauling moves the pile.

---

## Data

```gdscript
class_name ResourcePile extends Node3D

var contents: Dictionary = {}    # resource type → amount
var is_being_hauled: bool = false
var hauler: Colonist = null
```

---

## Spawn Cases

| Source              | Contents                               |
|---------------------|----------------------------------------|
| Robot death (basic) | `{ "Scrap": robot.scrap }`             |
| Robot death (heavy) | `{ "ShinyScrap": robot.scrap }`        |
| Hub destruction     | The full Hub buffer (`buffer.amounts`) |
| Tree felled         | `{ "Wood": yield }`                    |
| Ore mined           | `{ "Ore": yield }`                     |
| Stone mined         | `{ "Stone": yield }`                   |
| Crop harvested      | `{ "Food": yield }`                    |
| Hunting tower kill  | `{ "Food": animal.food_yield }`        |

A pile may contain multiple resource types when produced from a multi-resource source (e.g. a destroyed Hub).

---

## Hauling

A ResourcePile appears on the Job Board as a HAULING job. A claiming colonist sets `hauler` and `is_being_hauled`. They lift the pile (or as much as their `haul_capacity` allows) and carry it to a destination — typically a Hub, processing building, or production building.

If a colonist can't carry the whole pile in one trip, the pile remains in place with reduced contents and another HAULING job is reposted.

---

## Signals

```gdscript
signal claimed(hauler: Colonist)
signal delivered(destination: Node3D)
signal emptied()
```

---

## Dependencies

- `Colonist` — primary hauler
- `JobBoard` — auto-posts HAULING job on spawn
- `Railcar` / `Conveyor` — alternative haulers

---

# System: Transport

Three tiers of moving resources around the map: hauling (always), railcars (mid-game), conveyor belts (late-game).

---

## Hauling

The default. Colonists pick up ResourcePiles and carry them to destinations as `HAULING` jobs from the Job Board. Capacity scales with Harvesting level — see SYSTEMS/Colonist.md.

No infrastructure required. Slow at distance.

---

## Railcars

Player-laid track. Railcars path along it automatically, stopping at designated pickup and dropoff points. Cheap; no Solite required.

```gdscript
class_name Railcar extends Node3D

var path: Path3D
var follow: PathFollow3D
var cargo: Dictionary = {}
var cargo_capacity: float = 200.0
var speed: float = 5.0
var stops: Array[Vector3] = []
```

### Track

Track is placed by the player in the strategic view. Tracks can branch — at a junction, a railcar selects based on cargo destination. Routing logic and branch handling details are in OPEN_QUESTIONS.md.

Conveyor belts cannot branch — they are one-way per segment. This is the primary structural difference between the two systems.

### Stop Behavior

At a stop, a railcar can withdraw or deposit cargo using the same `Structure.withdraw` contract used by colonists.

---

## Conveyor Belts

Fully automated, continuous item movers. One-way per segment. Items placed on the input end arrive on the output end. No worker involvement.

Belts require Solite to build. They use `MultiMeshInstance3D` for efficient rendering of items along the path.

```gdscript
class_name ConveyorBelt extends Node3D

@export var speed: float = 2.0
@export var item_mesh: Mesh
var path: Path3D
var multimesh: MultiMeshInstance3D
var items: Array[Dictionary] = []   # { progress: float, type: String }
```

### Chaining

Belts connect end-to-end. On reaching the end of one belt, an item transfers to the connected belt or structure. If the output is blocked, items back up on the belt.

Belts cannot branch — splitter buildings would be required for that, and they're in OPEN_QUESTIONS.md.

---

## Comparison

| Feature        | Hauling    | Railcar    | Conveyor      |
|----------------|------------|------------|---------------|
| Infrastructure | None       | Track      | Belt + Solite |
| Branching      | n/a        | Yes        | No            |
| Throughput     | Low        | Medium     | High          |
| Automation     | Colonist   | Autonomous | Fully auto    |
| XP             | Harvesting | None       | None          |

---

## Signals

```gdscript
# Railcar
signal cargo_loaded(type: String, amount: float)
signal cargo_delivered(type: String, amount: float, destination: Node3D)

# ConveyorBelt
signal item_exited(type: String, destination: Node3D)
```

---

# System: Processing Building

Converts raw materials into processed materials. Base behavior is in SYSTEMS/Structure.md.

---

## Data

```gdscript
class_name ProcessingBuilding extends Structure

@export var input_type: String           # e.g. "Scrap", "Wood", "Ore"
@export var base_process_time: float = 10.0

var input_queue: float = 0.0
var output_queue: Dictionary = {}
var assigned_operator: Colonist = null
var process_progress: float = 0.0
```

---

## Processing Loop

```gdscript
func _process(delta: float) -> void:
    if not is_complete or input_queue <= 0.0:
        return

    var speed_bonus = 1.0
    if assigned_operator:
        speed_bonus = 1.0 + assigned_operator.levels["Engineering"] * SPEED_SCALE  # see Balance.md

    process_progress += delta * speed_bonus
    if process_progress >= base_process_time:
        process_progress = 0.0
        input_queue -= 1.0
        _produce_output()

func _produce_output() -> void:
    var outputs = _compute_outputs()
    for type in outputs:
        output_queue[type] = output_queue.get(type, 0.0) + outputs[type]
        processing_complete.emit(type, outputs[type])
```

---

## Variants

| Variant               | Input      | Output                            |
|-----------------------|------------|-----------------------------------|
| Scrap Processor       | Scrap      | Metal + variable Solite           |
| Shiny Scrap Processor | ShinyScrap | Metal + Iridium + variable Solite |
| Smelter               | Ore        | Metal                             |
| Lumber Mill           | Wood       | Lumber                            |
| Stone Cutter          | Stone      | Stone (refined for masonry)       |

Whether Scrap and Shiny Scrap share a building is in OPEN_QUESTIONS.md.

---

## Input & Output

Materials arrive via the Structure `withdraw`/delivery interface. Output is pulled out the same way — `HAULING` jobs are auto-posted when output accumulates.

---

## Signals

Inherits from Structure. Adds:

```gdscript
signal processing_complete(output_type: String, amount: float)
```

---

# System: Production Building

Combines processed materials into end-products: ammo, building materials, components. Base behavior is in SYSTEMS/Structure.md. Structurally similar to ProcessingBuilding but with multi-input recipes.

---

## Data

```gdscript
class_name ProductionBuilding extends Structure

@export var base_process_time: float = 15.0

var input_buffer: Dictionary = {}
var output_queue: Dictionary = {}
var assigned_operator: Colonist = null
var current_recipe: Recipe = null
var process_progress: float = 0.0
```

---

## Recipes

```gdscript
class_name Recipe extends Resource

@export var name: String
@export var inputs: Dictionary = {}    # type → amount required
@export var outputs: Dictionary = {}   # type → amount produced
```

### Example Recipes

| Recipe              | Inputs             | Outputs              |
|---------------------|--------------------|----------------------|
| Ammo                | 2 Metal            | 10 Ammo              |
| Building Materials  | 1 Metal + 1 Lumber | 1 Building Materials |
| Advanced Components | 1 Metal + 1 Solite | 1 Components         |

Recipe values are tunable — final balancing belongs in Balance.md once recipes are finalized.

---

## Processing Loop

```gdscript
func _process(delta: float) -> void:
    if not is_complete or not current_recipe or not _has_required_inputs():
        return

    var speed_bonus = 1.0
    if assigned_operator:
        speed_bonus = 1.0 + assigned_operator.levels["Engineering"] * SPEED_SCALE  # see Balance.md

    process_progress += delta * speed_bonus
    if process_progress >= base_process_time:
        process_progress = 0.0
        _consume_inputs()
        _produce_outputs()
```

---

## Recipe Selection

The player selects the active recipe. The building runs that recipe continuously while inputs are available. Switching recipes is instant; partial progress on the previous recipe is lost.

---

## Signals

Inherits from Structure. Adds:

```gdscript
signal production_complete(output_type: String, amount: float)
```

---

# System: Multiplayer

Solar Siege supports up to 4 cooperative players. ENet transport. One player hosts; others join. All players share the same game state and colony.

---

## Connection

```gdscript
# MultiplayerManager (autoload)

const PORT = 7000
const MAX_PLAYERS = 4

func create_game() -> void:
    var peer = ENetMultiplayerPeer.new()
    peer.create_server(PORT, MAX_PLAYERS)
    multiplayer.multiplayer_peer = peer

func join_game(address: String = "127.0.0.1") -> void:
    var peer = ENetMultiplayerPeer.new()
    peer.create_client(address, PORT)
    multiplayer.multiplayer_peer = peer
```

Player IDs are assigned by Godot. Host is peer ID 1.

LAN-only for MVP. Online play is in FUTURE.md.

---

## Authority Model

Server (host) is authoritative for all game state. Clients send intent via `@rpc`; the server validates and applies.

```gdscript
# Example: client requests possession
@rpc("any_peer", "call_local", "reliable")
func request_possess(unit_path: NodePath) -> void:
    if not multiplayer.is_server():
        return
    var unit = get_node(unit_path)
    var player_id = multiplayer.get_remote_sender_id()
    PossessionManager.possess(player_id, unit)
```

---

## Synchronization

Every networked node requires a `MultiplayerSynchronizer`. The following are synced:

| Node                    | Synced Properties                                                                                  |
|-------------------------|----------------------------------------------------------------------------------------------------|
| Colonist                | `global_position`, `current_job`, `xp`, `levels`, `specialty`, `is_possessed`, `possessing_player` |
| Robot                   | `global_position`, `health`, `scrap`, `is_frozen`                                                  |
| Animal                  | `global_position`, `health`                                                                        |
| Structure (all types)   | `global_position`, `health`, `is_complete`, type-specific state                                    |
| SolarCycle              | `current_time`, `current_phase`                                                                    |
| JobBoard                | `jobs`                                                                                             |
| PossessionManager       | `possessed`                                                                                        |
| FoodManager             | `food_points`, `nutrition_state`                                                                   |
| ResourceBuffer (on Hub) | `amounts`                                                                                          |
| ResourcePile            | `global_position`, `contents`, `is_being_hauled`                                                   |

---

## Shared Access

All players share:

- The Job Board — any player can post, assign, or force-task
- Possession — any player can possess any unpossessed colonist
- Strategic view — each player has their own camera, independently positioned and not synced

Coordination is a social contract.

---

## Cameras

Each player maintains their own `StrategicCamera`. Positions are local. On possession, the player's camera switches to the colonist's 1st-person camera. On exit, it returns to their personal strategic camera at its last position.

---

## Dependencies

- All major game nodes — require `MultiplayerSynchronizer`
- `InputManager` (planned) — per-player controller mapping

---

# Part 3 — Future / Long-Term Ideas

# Solar Siege — Future / Long-Term Ideas

Out of scope for MVP. Organized by system.

---

## Colonist

- **Sub-Field Abilities** — Minor traits and abilities within a field that don't constitute a full specialty.
- **Branching Skill Tree** — Sub-specialties deepen as colonists level up. Structure and unlock conditions TBD.
- **Skill Gates** — High-tier objects require a minimum skill level to interact with.

---

## Robot

- **Wave spawning system** — Timing, escalation, spawn points, difficulty scaling.
- **Hauling live robots** — Dragging a functional robot back to base as a deliberate risk.
- **Heavy robot introduction** — When heavy robots first appear in a run.
- **Aggro behavior** — Whether robots have a detection range or always target the nearest Hub.
- **Covered structures / shade** — Robots aware of whether they're under cover. Shade drops solar strength — robots could freeze mid-day under sufficient cover.
- **Rover power extension** — Late-game robot countermeasure. Rovers with solar panels follow robots via a tether, allowing them to operate under cover.
- **Visual state for frozen robots**

---

## Job Board

- **CRITICAL force-override** — Whether `very_much` priority should hard-override force-tasked colonists.
- **Job Board UI** — Visual representation of the queue.

---

## Food

- **Food variety multiplier** — A wider variety in the colony's pool raises the effective food level beyond quantity alone.
- **Hunting tower stocking automation** — Whether Stone ammo can be auto-restocked vs. hauled manually.
- **Food spoilage** — Whether food decays if the pool overflows a cap.

---

## Animals

- **Wander/attraction model** — How aggressively are animals drawn to hunting towers?
- **Spawn rates and distribution** — How dense, where, when.
- **Animal AI variety** — Skittish prey, larger animals that resist attraction, etc.

---

## Transport

- **Railcar one-way vs. bidirectional** — Movement rules at junctions.
- **Branching belts via splitter buildings** — A late-game logistics structure.
- **Maximum belt segment length** — Whether a hard cap exists.
- **Railcar operator** — Whether railcars need a colonist driver.

---

## Hub

- **Hub capacity upgrades** — Whether buffer capacities can be increased.
- **Home Hub assignment** — Colonists tied to a specific Hub, enabling per-Hub recall and population caps.
- **Population cap** — Whether the colony has a maximum colonist count.

---

## Recall

- **Per-Hub recall** — Requires home Hub assignment.
- **Auto-recall** — Trigger automatically at a configurable time before dawn.
- **Bell visual/audio** — World-space cue when recall fires.

---

## Possession

- **Initiation UI** — Click-to-possess, radial menu, or other.
- **Death cooldown** — Whether possession is briefly locked after a possessed colonist dies.
- **Visual differentiation per player** — How possessed colonists are highlighted by owning player.

---

## Multiplayer

- **Online play** — Currently LAN-only. Requires relay/STUN.
- **Lobby & matchmaking**.
- **Player disconnection handling** — Pause, AI fallback, autonomous fallback.
- **Host migration** — Whether the host role can transfer mid-session.

---

## World

- **Weather** — Cloudy days reduce solar strength, weakening robots below their sine-curve peak.
- **Planet progression** — What comes after the first planet is colonized.
- **Map** — Size, layout, biomes, resource distribution.
- **Landing flag visual** — Whether the player designs the flag or it's randomly generated.

---

## Narrative

- **The Awakening** — Triggering event narrative. How the player learns the robots' origin over time. The mystery itself is by design.

---

## Rendering

- **Fog of war** — Strategic-view occlusion outside colonist sight.
- **First-person fog** — Atmospheric distance fog while possessed.

---

# Part 4 — Open Questions

# Solar Siege — Open Questions

Decisions needed before or during development. Not shelved features — see FUTURE.md for those.

Tunable constants are not listed here — see Balance.md. Anything here is a real design question with no clear answer yet.

---

## Colonist

- **Name generation** — Wordlist, procedural, or hand-authored? Pool size?
- **Color application** — Shader parameter, material override, or vertex color?

---

## Job Board

- **Active dismantling jobs** — Should DISMANTLING jobs auto-target active robots or only frozen ones? Player choice via priority flag?
- **Area-paint scope** — Can players paint across long distances, or is there a max area size?

---

## Robot

- **The first robot** — How does the very first robot appear so that a colonist can dismantle it and trigger the awakening? Player-placed during landing? A single dormant robot near the spawn?
- **Scrap Processor / Shiny Scrap Processor** — Same building with mode switch, or separate buildings?
- **Iridium processor** — Does Iridium require a dedicated late-game building?

---

## Food

- **Hunting tower stone consumption** — How much Stone per shot? Should the cost be visible in Balance.md?

---

## Animals

- **Wander/attraction model details** — How are wandering and tower-attraction balanced?
- **Spawn distribution** — Where do animals appear? Throughout the map evenly, or in habitats?

---

## Transport

- **Track grid resolution** — What's the snapping grid for track placement?
- **Track branching routing** — How does a railcar choose at a junction? By cargo destination, by next-stop logic, or player-specified?

---

## Hub

- **Structure range** — At what distance can a structure draw from a Hub buffer?
- **Hub build cost** — How much material is required to build a new Hub?

---

## Possession

- **Input remapping** — How is controller input remapped per player for up to 4 players in Godot 4?

---

## Solar Cycle

- **Day/night duration** — Configurable per session, per map, or fixed?
- **Sun visual** — Should DirectionalLight3D rotation be tied to `current_time`?
- **Time speed modifier** — Can players speed up time during low-threat periods?

---

## Multiplayer

- **RPC validation** — What state mutations are server-validated vs. trusted from clients?

---

## World

- **Landing flag** — Player-designed or randomly generated?
- **Planet name input** — Free text from one player, or proposed/voted by all?

---

## General

- **Recall behavior at the Hub** — Do recalled colonists stand outside (current assumption) or go inside? Inside requires interior representation.