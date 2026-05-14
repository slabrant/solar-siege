# System: Colonist

Colonists are the primary agents of the colony. They execute tasks autonomously via the Job Board, level up through labor, and can be possessed for direct control. See GDD for design intent.

---

## Data

```gdscript
class_name Colonist extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

# Identity
var colonist_name: String = ""
var is_new: bool = true                        # true until first specialty earned

# Health
var health: float = COLONIST_MAX_HEALTH        # see Balance.md

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

| Field       | Sub-Specialties                   |
|-------------|-----------------------------------|
| Engineering | Construction, Mechanics           |
| Gunnery     | Marksman, Hunter                  |
| Harvesting  | Miner, Lumberjack, Farmer, Hauler |

---

## Task Speed

Level scales task speed. All colonists perform all tasks — skill determines how fast.

```gdscript
func get_task_speed(field: String) -> float:
    var speed = COLONIST_BASE_SPEED * (1.0 + levels[field] * SPEED_SCALE)  # see Balance.md
    if is_possessed:
        speed *= POSSESSION_BONUS                                           # see Balance.md
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

## Damage & Death

Colonists have no weapons and cannot attack. Combat is handled exclusively by towers.

Colonists can take damage from robot thorns (see SYSTEMS/Robot.md) and from any damage source that calls `take_damage`.

```gdscript
func take_damage(amount: float) -> void:
    health -= amount
    if health <= 0:
        _die()

func _die() -> void:
    if is_possessed:
        PossessionManager.unpossess(possessing_player)
    if current_job:
        current_job.assigned_colonist = null
    colonist_died.emit(self)
    queue_free()
```

On death, the colonist's possession is released (if any), their current job is unassigned, and `colonist_died` is emitted. `GameState._check_game_over()` is wired to this signal — see SYSTEMS.md.

---

## Job Assignment

```gdscript
func _ready() -> void:
    JobBoard.jobs_updated.connect(_on_jobs_updated)
    _find_new_job()

func _on_jobs_updated() -> void:
    if not is_force_tasked:
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
