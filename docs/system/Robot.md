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
