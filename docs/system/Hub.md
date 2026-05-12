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
