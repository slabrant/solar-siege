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
