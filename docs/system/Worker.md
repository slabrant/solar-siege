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
