# System: Processing Building

## Purpose
Processing Buildings convert raw materials into processed materials. They are the bridge between the world (gathered resources, robot scrap) and usable inventory. Each building type has specific inputs and outputs. Processing is time-based, with worker skill scaling speed.

This document covers the general processing mechanic. Specific variants (Scrap Processor, Lumber Mill, Smelter, Shiny Scrap Processor) follow the same pattern with different inputs/outputs.

---

## Data

```gdscript
class_name ProcessingBuilding extends StaticBody3D

@export var max_health: float = 800.0
@export var input_type: String = ""        # e.g. "Scrap", "Wood", "Ore"
@export var base_process_time: float = 10.0    # seconds per batch at level 0 Engineering

var health: float = max_health
var input_queue: float = 0.0               # raw material waiting to be processed
var output_queue: Dictionary = {}          # processed material waiting to be hauled out
var assigned_worker: Worker = null         # operator; scales processing speed
var process_progress: float = 0.0
```

---

## Processing Loop

```gdscript
func _process(delta: float) -> void:
    if input_queue <= 0.0:
        return

    var speed_bonus = 1.0
    if assigned_worker:
        speed_bonus = 1.0 + assigned_worker.levels["Engineering"] * SPEED_SCALE  # see Balance.md

    process_progress += delta * speed_bonus
    if process_progress >= base_process_time:
        process_progress = 0.0
        input_queue -= 1.0
        _produce_output()

func _produce_output() -> void:
    var outputs = _compute_outputs()   # specific to building type
    for type in outputs:
        output_queue[type] = output_queue.get(type, 0.0) + outputs[type]
        processing_complete.emit(type, outputs[type])
```

---

## Variants

### Scrap Processor
- Input: `Scrap`
- Output: `Metal` + variable `Solite` yield (random per batch)

### Shiny Scrap Processor
- Input: `ShinyScrap`
- Output: `Metal` + `Iridium` + variable `Solite` yield
- May share a building with Scrap Processor — see OPEN_QUESTIONS.md

### Smelter
- Input: `Ore`
- Output: `Metal`

### Lumber Mill
- Input: `Wood`
- Output: `Lumber`

---

## Input & Output Flow

Workers, railcars, and conveyor belts deliver raw materials by adding to `input_queue`. Processed materials sit in `output_queue` until hauled out by workers (HAULING jobs posted automatically to the Job Board), or picked up by railcars/belts.

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

Engineers can repair damaged processing buildings, gaining Engineering XP equal to health restored.

---

## Signals

```gdscript
signal processing_complete(output_type: String, amount: float)
signal building_destroyed()
```

---

## Dependencies

- `Worker` — assigned operator; haulers move input and output
- `JobBoard` — posts HAULING jobs for input demand and output supply
- `Transport` system — railcars and belts as alternative input/output methods
