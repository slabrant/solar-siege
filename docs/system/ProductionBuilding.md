# System: Production Building

## Purpose
Production Buildings (Factories) combine processed materials into usable end-products: ammo, building materials, components. They are the final step before resources are consumed by structures and construction.

Structurally similar to a Processing Building but with multiple inputs per recipe.

---

## Data

```gdscript
class_name ProductionBuilding extends StaticBody3D

@export var max_health: float = 1000.0
@export var base_process_time: float = 15.0   # seconds per batch at level 0 Engineering

var health: float = max_health
var input_buffer: Dictionary = {}             # type → amount on hand
var output_queue: Dictionary = {}             # type → amount produced, waiting to haul
var assigned_worker: Worker = null
var current_recipe: Recipe = null
var process_progress: float = 0.0
```

---

## Recipes

Each recipe defines required inputs and produced outputs.

```gdscript
class_name Recipe extends Resource

@export var name: String
@export var inputs: Dictionary = {}       # type → amount required
@export var outputs: Dictionary = {}      # type → amount produced
```

### Example Recipes

| Recipe | Inputs | Outputs |
|---|---|---|
| Ammo | 2 Metal | 10 Ammo |
| Building Materials | 1 Metal + 1 Lumber | 1 Building Materials |
| Advanced Components | 1 Metal + 1 Solite | 1 Components |

Specific recipe balancing belongs in Balance.md once recipes are finalized.

---

## Processing Loop

```gdscript
func _process(delta: float) -> void:
    if not current_recipe or not _has_required_inputs():
        return

    var speed_bonus = 1.0
    if assigned_worker:
        speed_bonus = 1.0 + assigned_worker.levels["Engineering"] * SPEED_SCALE  # see Balance.md

    process_progress += delta * speed_bonus
    if process_progress >= base_process_time:
        process_progress = 0.0
        _consume_inputs()
        _produce_outputs()

func _has_required_inputs() -> bool:
    for type in current_recipe.inputs:
        if input_buffer.get(type, 0.0) < current_recipe.inputs[type]:
            return false
    return true

func _consume_inputs() -> void:
    for type in current_recipe.inputs:
        input_buffer[type] -= current_recipe.inputs[type]

func _produce_outputs() -> void:
    for type in current_recipe.outputs:
        output_queue[type] = output_queue.get(type, 0.0) + current_recipe.outputs[type]
        production_complete.emit(type, current_recipe.outputs[type])
```

---

## Recipe Selection

The player selects the active recipe for a Production Building. The building runs that recipe continuously while inputs are available. Recipe switching is instant — partial progress on the previous recipe is lost.

---

## Damage & Destruction

```gdscript
func take_damage(amount: float) -> void:
    health -= amount
    if health <= 0:
        _die()

func _die() -> void:
    building_destroyed.emit()
    queue_free()
```

Engineers can repair damaged production buildings, gaining Engineering XP equal to health restored.

---

## Signals

```gdscript
signal production_complete(output_type: String, amount: float)
signal building_destroyed()
```

---

## Dependencies

- `ProcessingBuilding` — typical source of input materials
- `Worker` — assigned operator; haulers move input and output
- `JobBoard` — posts HAULING jobs for input demand and output supply
- `Hub` — common destination for finished products (Ammo to buffer)
- `Transport` system — automated alternative for input/output
