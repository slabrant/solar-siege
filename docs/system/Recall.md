# System: Recall (Town Bell)

## Purpose
The Recall action lets any player instantly pull all non-possessed workers back to their nearest Hub from the strategic view. It is a safety valve — used to protect workers as dawn approaches, or to consolidate the workforce during a crisis.

---

## Trigger

Activated by a player action from the strategic (RTS) view. Global — affects all workers on the map simultaneously. There is no per-Hub or per-worker granularity at this time.

---

## Behavior

### On Recall

```gdscript
# GameState or a RecallManager
func recall_all():
    for worker in get_tree().get_nodes_in_group("Workers"):
        if not worker.is_possessed:
            worker.recall()
```

```gdscript
# Worker
func recall():
    is_recalled = true
    if current_job:
        current_job.assigned_worker = null
        current_job = null
    var nearest_hub = _find_nearest_hub()
    navigation_agent.target_position = nearest_hub.global_position
```

- Possession is not interrupted — possessed workers are exempt
- Current job is released immediately (unassigned on the Job Board)
- Worker paths to nearest Hub and waits

### On Release

```gdscript
func release_recall():
    is_recalled = false
    _find_new_job()   # standard Job Board evaluation
```

No saved job state. Workers re-evaluate the Job Board normally on release. Their previously interrupted job will still be on the board at the same priority — and since they were likely closest to it, they will usually reclaim it. If another worker took it in the interim, they are routed to the next best job.

---

## Data

```gdscript
# Worker
var is_recalled: bool = false
```

---

## Nearest Hub Resolution

```gdscript
func _find_nearest_hub() -> Node3D:
    var hubs = get_tree().get_nodes_in_group("Hubs")
    var nearest = null
    var nearest_dist = INF
    for hub in hubs:
        var d = global_position.distance_to(hub.global_position)
        if d < nearest_dist:
            nearest_dist = d
            nearest = hub
    return nearest
```

Workers are not tied to a specific Hub — nearest at the time of recall determines the destination.

---

## Signals

```gdscript
# GameState / RecallManager
signal recall_triggered()
signal recall_released()
```
