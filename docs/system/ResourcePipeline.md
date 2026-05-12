# System: Resource Pipeline

## Purpose
Raw materials are gathered in the world and must be processed before they become usable. Nothing goes directly from the ground (or a robot) into a building. The pipeline is: gather → haul → process → use.

---

## Resource Types

| Resource | Source | Raw or Processed |
|---|---|---|
| Wood | Trees (Lumberjacks) | Raw |
| Ore | Rock deposits (Miners) | Raw |
| Food | Farms, foraging, hunting | Raw |
| Scrap | Robot death | Raw |
| ShinyScrap | Heavy robot death | Raw |
| Lumber | Wood → Processing Building | Processed |
| Metal | Ore → Processing Building | Processed |
| Ammo | Metal + other → Production Building | Processed |
| Solite | Scrap → Processing Building (variable yield) | Processed |
| Iridium | ShinyScrap → Processing Building | Processed |
| Building Materials | Lumber + Metal → Production | Processed |

---

## Processing Buildings

Processing buildings accept specific raw inputs and produce processed outputs. Processing is time-based; worker skill (Engineering/Mechanics) scales processing speed.

### Scrap Processor

- **Input:** Scrap
- **Output:** Metal parts + Solite (variable yield, random per batch within a range)
- Solite yield is not determined at robot death — it is determined here

### Shiny Scrap Processor

- **Input:** ShinyScrap
- **Output:** Metal parts + Iridium + Solite (variable yield)
- May be the same building as Scrap Processor with a different processing mode, or a separate building — see OPEN_QUESTIONS.md

### Lumber Mill

- **Input:** Wood
- **Output:** Lumber

### Smelter

- **Input:** Ore
- **Output:** Metal

### Production Building (Factory)

- **Input:** Processed materials (Metal, Lumber, Solite)
- **Output:** Ammo, Building Materials, Components
- Ammo production is the primary use — turrets require a steady ammo supply

---

## Flow Diagram

```
[World]                    [Processing]              [Use]
Trees    → Haul → Lumber Mill    → Lumber    → Factory → Building Materials
Ore      → Haul → Smelter        → Metal     → Factory → Ammo / Components
Scrap    → Haul → Scrap Proc.    → Metal + Solite
ShinyScrap → Haul → Shiny Proc.  → Metal + Iridium + Solite
Food     → Haul → Hub Food Pool  → (colony-wide Well-Fed state)
```

---

## Hauling

Workers carry raw materials from source to processor, and processed materials from processor to Hub or construction site.

Haul capacity is fixed per worker (not skill-based) — exact value in OPEN_QUESTIONS.md.

### Transport Options

1. **On foot** — worker carries manually; slowest, no infrastructure required
2. **Railcar** — player lays track; railcars path along track automatically; cheap, no Solite required
3. **Conveyor Belt** — requires Solite to build; fully automated; end-game

---

## Resource Pile

When a robot dies or a Hub is destroyed, a `ResourcePile` node spawns at its location holding the dropped resources. A single scene handles both cases — its contents are configured at spawn time.

```gdscript
class_name ResourcePile extends Node3D

var contents: Dictionary = {}              # resource type → amount, e.g. { "Scrap": 100.0, "Solite": 5.0 }
var is_being_hauled: bool = false
var hauler: Node3D = null
```

Workers claim a ResourcePile by setting `hauler` and `is_being_hauled`. Unclaimed piles are visible to all workers and appear on the Job Board as HAULING jobs.

### Common spawn cases

- **Robot death** — `contents = { "Scrap": robot.scrap }` (or `"ShinyScrap"` if the robot was heavy)
- **Hub destruction** — `contents = buffer.current.duplicate()` (the full Hub buffer)

A pile may contain multiple resource types. Workers handle multi-type piles by hauling each type in separate trips, or in one trip if their inventory has room for all.

---

## Signals

```gdscript
# Processing Building
signal processing_complete(output_type: String, amount: float)
signal processing_started(input_type: String)

# ResourcePile
signal claimed(worker: Node3D)
signal delivered()
```

---

## Dependencies

- `Worker` — hauls materials
- `JobBoard` — auto-posts HAULING jobs when ResourcePiles spawn, and when processing buildings have output ready
- `Hub` — receives processed materials into local buffer
- `Transport` system — railcars and belts move materials automatically
