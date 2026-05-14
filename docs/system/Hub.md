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

Hub destruction contributes to the colony-wide game-over condition — see SYSTEMS.md.

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
