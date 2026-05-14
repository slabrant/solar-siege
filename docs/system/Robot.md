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
