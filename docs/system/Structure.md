# System: Structure (Base Class)

All built objects in the colony — Hubs, Towers, Hunting Towers, Processing Buildings, Production Buildings, Walls — share a common base. This document defines that base. Specific structure docs only describe what's unique about them.

---

## Construction Flow

A structure goes through three phases:

1. **Marked** — Player marks a location. A `CONSTRUCTION` job appears on the Job Board.
2. **Materials Pending** — `HAULING` jobs are auto-posted for each required input. The structure cannot be worked on yet.
3. **Under Construction** — Once all materials are at the site, Engineers can begin. Progress accrues in health points. When `health == max_health`, the structure is complete and operational.

A structure marker has zero health while waiting for materials. Once construction starts, health accrues until `max_health` is reached.

---

## Data

```gdscript
class_name Structure extends StaticBody3D

@export var max_health: float       # set per structure type; see Balance.md
@export var build_cost: Dictionary  # type → amount required to construct

var health: float = 0.0             # starts at 0; rises during construction
var is_complete: bool = false
```

---

## Damage & Destruction

All structures take damage and can be destroyed.

```gdscript
func take_damage(amount: float) -> void:
    health -= amount
    if health <= 0:
        _die()

func _die() -> void:
    _drop_remaining_resources()  # if applicable; defined per structure
    structure_destroyed.emit()
    queue_free()
```

Engineers can repair damaged structures. Repair awards Engineering XP equal to health restored, identical to construction.

---

## Resource Withdrawal

Operational structures expose a `withdraw` interface for entities that pull resources from them:

```gdscript
func withdraw(type: String, amount: float) -> float:
    # returns amount actually withdrawn (≤ requested)
```

Withdrawers include `Colonist`, `Railcar`, and `Conveyor`. The structure decides whether to allow the request.

---

## Signals

```gdscript
signal structure_built()
signal structure_destroyed()
signal structure_damaged(amount: float)
```

These signals are inherited by all specific structure types and need not be re-declared.

---

## Subtypes

Each subtype only documents what's unique to it. None of them re-document damage, destruction, or repair.

| Subtype             | Doc                           |
|---------------------|-------------------------------|
| Hub                 | SYSTEMS/Hub.md                |
| Tower               | SYSTEMS/Tower.md              |
| Hunting Tower       | SYSTEMS/HuntingTower.md       |
| Processing Building | SYSTEMS/ProcessingBuilding.md |
| Production Building | SYSTEMS/ProductionBuilding.md |
| Wall                | (see Balance.md health tiers) |
