# System: Processing Building

Converts raw materials into processed materials. Base behavior is in SYSTEMS/Structure.md.

---

## Data

```gdscript
class_name ProcessingBuilding extends Structure

@export var input_type: String           # e.g. "Scrap", "Wood", "Ore"
@export var base_process_time: float = 10.0

var input_queue: float = 0.0
var output_queue: Dictionary = {}
var assigned_operator: Colonist = null
var process_progress: float = 0.0
```

---

## Processing Loop

```gdscript
func _process(delta: float) -> void:
    if not is_complete or input_queue <= 0.0:
        return

    var speed_bonus = 1.0
    if assigned_operator:
        speed_bonus = 1.0 + assigned_operator.levels["Engineering"] * SPEED_SCALE  # see Balance.md

    process_progress += delta * speed_bonus
    if process_progress >= base_process_time:
        process_progress = 0.0
        input_queue -= 1.0
        _produce_output()

func _produce_output() -> void:
    var outputs = _compute_outputs()
    for type in outputs:
        output_queue[type] = output_queue.get(type, 0.0) + outputs[type]
        processing_complete.emit(type, outputs[type])
```

---

## Variants

| Variant               | Input      | Output                            |
|-----------------------|------------|-----------------------------------|
| Scrap Processor       | Scrap      | Metal + variable Solite           |
| Shiny Scrap Processor | ShinyScrap | Metal + Iridium + variable Solite |
| Smelter               | Ore        | Metal                             |
| Lumber Mill           | Wood       | Lumber                            |
| Stone Cutter          | Stone      | Stone (refined for masonry)       |

Whether Scrap and Shiny Scrap share a building is in OPEN_QUESTIONS.md.

---

## Input & Output

Materials arrive via the Structure `withdraw`/delivery interface. Output is pulled out the same way — `HAULING` jobs are auto-posted when output accumulates.

---

## Signals

Inherits from Structure. Adds:

```gdscript
signal processing_complete(output_type: String, amount: float)
```
