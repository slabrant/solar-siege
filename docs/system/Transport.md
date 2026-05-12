# System: Transport

## Purpose
Transport moves raw and processed materials around the map so workers don't have to carry everything by hand. Three tiers exist: on-foot hauling (always available), railcars (mid-game, player-placed track), and conveyor belts (late-game, Solite-gated, automated).

---

## Tier 1: On-Foot Hauling

No infrastructure required. Workers pick up a resource, carry it to a destination, and return. Slowest method but available from the start.

Governed entirely by the Worker and Job Board systems. No separate transport nodes needed.

---

## Tier 2: Railcar

### Overview

The player lays railroad track directly on the map. Railcars spawn at a station and follow the laid track automatically, picking up and dropping off cargo at designated stops.

Railcars are cheap to build and require no Solite. They are the primary logistics backbone of the Age of Automation.

### Track Placement

Track is placed by the player in the top-down view, similar to drawing a path. Workers are not required for placement. Track segments snap to a grid — resolution in OPEN_QUESTIONS.md. Track can branch.

Implementation: likely a `Path3D` node generated from player input, with railcar nodes following it via `PathFollow3D`.

### Railcar Data

```gdscript
class_name Railcar extends Node3D

var path: Path3D
var follow: PathFollow3D
var cargo: Dictionary = {}        # resource type → amount
var cargo_capacity: float = 200.0
var speed: float = 5.0            # units/sec along path
var current_stop: int = 0
var stops: Array[Vector3] = []    # designated pickup/dropoff points
```

### Stop Behavior

At each stop, railcars:
1. Check if there is cargo to pick up (from a processing building output queue or scrap pile)
2. Load up to capacity
3. Check if there is a destination hub or building that needs the cargo
4. Move to next stop

Stop logic is simple — no dynamic routing. The player defines the route by laying track.

### Cost

- Track: cheap (wood/metal per segment)
- Railcar: moderate (metal components)
- No Solite required

---

## Tier 3: Conveyor Belt

### Overview

Conveyor belts are fully automated, continuous item movers. They replace manual hauling entirely on their route. Items placed at the belt's input end arrive at the output end without worker involvement.

Belts require Solite to build and are the defining feature of the Age of Industry.

### Implementation

Uses `MultiMeshInstance3D` for rendering items on the belt path — one draw call regardless of item count.

```gdscript
class_name ConveyorBelt extends Node3D

@export var speed: float = 2.0
@export var item_mesh: Mesh
var path: Path3D
var multimesh: MultiMeshInstance3D
var items: Array[Dictionary] = []    # { progress: float, type: String }
```

Items progress from 0.0 to 1.0 along the belt's path each frame. On reaching 1.0, the item exits and is delivered to the connected buffer or next belt.

### Belt Chaining

Belts connect to each other and to building input/output ports. Exit logic: on item reaching progress 1.0, check for a connected belt or buffer at the output end and transfer. If output is blocked (buffer full, no connection), item halts at end until cleared.

### Cost

- Belt segment: moderate (metal + Solite per segment)
- Higher throughput than railcars but higher build cost

---

## Signals

```gdscript
# Railcar
signal cargo_loaded(type: String, amount: float)
signal cargo_delivered(type: String, amount: float, destination: Node3D)

# ConveyorBelt
signal item_exited(type: String, progress_destination: Node3D)
```

---

## Dependencies

- `Worker` — on-foot hauling
- `JobBoard` — HAULING jobs for on-foot transport
- `ResourcePipeline` — source and destination of all cargo
- `Hub` — `ResourceBuffer` as delivery target
