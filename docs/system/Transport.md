# System: Transport

Three tiers of moving resources around the map: hauling (always), railcars (mid-game), conveyor belts (late-game).

---

## Hauling

The default. Colonists pick up ResourcePiles and carry them to destinations as `HAULING` jobs from the Job Board. Capacity scales with Harvesting level — see SYSTEMS/Colonist.md.

No infrastructure required. Slow at distance.

---

## Railcars

Player-laid track. Railcars path along it automatically, stopping at designated pickup and dropoff points. Cheap; no Solite required.

```gdscript
class_name Railcar extends Node3D

var path: Path3D
var follow: PathFollow3D
var cargo: Dictionary = {}
var cargo_capacity: float = 200.0
var speed: float = 5.0
var stops: Array[Vector3] = []
```

### Track

Track is placed by the player in the strategic view. Tracks can branch — at a junction, a railcar selects based on cargo destination. Routing logic and branch handling details are in OPEN_QUESTIONS.md.

Conveyor belts cannot branch — they are one-way per segment. This is the primary structural difference between the two systems.

### Stop Behavior

At a stop, a railcar can withdraw or deposit cargo using the same `Structure.withdraw` contract used by colonists.

---

## Conveyor Belts

Fully automated, continuous item movers. One-way per segment. Items placed on the input end arrive on the output end. No colonist involvement.

Belts require Solite to build. They use `MultiMeshInstance3D` for efficient rendering of items along the path.

```gdscript
class_name ConveyorBelt extends Node3D

@export var speed: float = 2.0
@export var item_mesh: Mesh
var path: Path3D
var multimesh: MultiMeshInstance3D
var items: Array[Dictionary] = []   # { progress: float, type: String }
```

### Chaining

Belts connect end-to-end. On reaching the end of one belt, an item transfers to the connected belt or structure. If the output is blocked, items back up on the belt.

Belts cannot branch — splitter buildings would be required for that, and they're in OPEN_QUESTIONS.md.

---

## Comparison

| Feature        | Hauling    | Railcar    | Conveyor      |
|----------------|------------|------------|---------------|
| Infrastructure | None       | Track      | Belt + Solite |
| Branching      | N/A        | Yes        | No            |
| Throughput     | Low        | Medium     | High          |
| Automation     | Colonist   | Autonomous | Fully auto    |
| XP             | Harvesting | None       | None          |

---

## Signals

```gdscript
# Railcar
signal cargo_loaded(type: String, amount: float)
signal cargo_delivered(type: String, amount: float, destination: Node3D)

# ConveyorBelt
signal item_exited(type: String, destination: Node3D)
```
