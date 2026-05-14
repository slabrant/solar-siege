# System: Production Building

Combines processed materials into end-products: ammo, building materials, components. Base behavior is in SYSTEMS/Structure.md. Structurally similar to ProcessingBuilding but with multi-input recipes.

---

## Data

```gdscript
class_name ProductionBuilding extends Structure

@export var base_process_time: float = 15.0

var input_buffer: Dictionary = {}
var output_queue: Dictionary = {}
var assigned_operator: Colonist = null
var current_recipe: Recipe = null
var process_progress: float = 0.0
```

---

## Recipes

```gdscript
class_name Recipe extends Resource

@export var name: String
@export var inputs: Dictionary = {}    # type → amount required
@export var outputs: Dictionary = {}   # type → amount produced
```

### Example Recipes

| Recipe              | Inputs             | Outputs              |
|---------------------|--------------------|----------------------|
| Ammo                | 2 Metal            | 10 Ammo              |
| Building Materials  | 1 Metal + 1 Lumber | 1 Building Materials |
| Advanced Components | 1 Metal + 1 Solite | 1 Components         |

Recipe values are tunable — final balancing belongs in Balance.md once recipes are finalized.

---

## Processing Loop

```gdscript
func _process(delta: float) -> void:
    if not is_complete or not current_recipe or not _has_required_inputs():
        return

    var speed_bonus = 1.0
    if assigned_operator:
        speed_bonus = 1.0 + assigned_operator.levels["Engineering"] * SPEED_SCALE  # see Balance.md

    process_progress += delta * speed_bonus
    if process_progress >= base_process_time:
        process_progress = 0.0
        _consume_inputs()
        _produce_outputs()
```

---

## Recipe Selection

The player selects the active recipe. The building runs that recipe continuously while inputs are available. Switching recipes is instant; partial progress on the previous recipe is lost.

---

## Signals

Inherits from Structure. Adds:

```gdscript
signal production_complete(output_type: String, amount: float)
```
