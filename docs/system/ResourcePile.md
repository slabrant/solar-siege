# System: Resource Pile

A physical object holding one or more resource types. Spawned by anything that produces resources in the world: a dying robot, a harvested tree, a destroyed Hub, a hunting tower kill. Any haulable thing.

Colonists do not have inventories. Harvesting moves the resource from its source (tree, ore deposit, robot) into a ResourcePile at the location. Hauling moves the pile.

---

## Data

```gdscript
class_name ResourcePile extends Node3D

var contents: Dictionary = {}    # resource type → amount
var is_being_hauled: bool = false
var hauler: Colonist = null
```

---

## Spawn Cases

| Source              | Contents                               |
|---------------------|----------------------------------------|
| Robot death (basic) | `{ "Scrap": robot.scrap }`             |
| Robot death (heavy) | `{ "ShinyScrap": robot.scrap }`        |
| Hub destruction     | The full Hub buffer (`buffer.amounts`) |
| Tree felled         | `{ "Wood": yield }`                    |
| Ore mined           | `{ "Ore": yield }`                     |
| Stone mined         | `{ "Stone": yield }`                   |
| Crop harvested      | `{ "Food": yield }`                    |
| Hunting tower kill  | `{ "Food": animal.food_yield }`        |

A pile may contain multiple resource types when produced from a multi-resource source (e.g. a destroyed Hub).

---

## Hauling

A ResourcePile appears on the Job Board as a HAULING job. A claiming colonist sets `hauler` and `is_being_hauled`. They lift the pile (or as much as their `haul_capacity` allows) and carry it to a destination — typically a Hub, processing building, or production building.

If a colonist can't carry the whole pile in one trip, the pile remains in place with reduced contents and another HAULING job is reposted.

---

## Signals

```gdscript
signal claimed(hauler: Colonist)
signal delivered(destination: Node3D)
signal emptied()
```

---

## Dependencies

- `Colonist` — primary hauler
- `JobBoard` — auto-posts HAULING job on spawn
- `Railcar` / `Conveyor` — alternative haulers
