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
