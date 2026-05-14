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
