# System: Recall

A colony-wide bell. Any player can sound it from the strategic view. All non-possessed colonists drop their work and path to their nearest Hub.

Recall is implemented entirely through the Job Board — there is no separate routing system. When recalled, every eligible colonist receives a `very_much`-priority RETURN job targeting their nearest Hub.

---

## Trigger

```gdscript
# GameState or a RecallManager
func recall_all() -> void:
    for c in get_tree().get_nodes_in_group("Colonists"):
        if c.is_possessed:
            continue
        var hub = _find_nearest_hub_to(c)
        var job = Job.new()
        job.type = Job.JobType.RETURN
        job.location = hub.global_position
        job.assigned_colonist = c
        JobBoard.add_job(job, true)   # very_much = true
    recall_triggered.emit()

func release_recall() -> void:
    for job in JobBoard.jobs.filter(func(j): return j.type == Job.JobType.RETURN):
        JobBoard.remove_job(job.id)
    recall_released.emit()
```

Because the RETURN jobs are inserted at the top of the queue with `very_much`, every recalled colonist sees them as the highest-priority work available and pathing happens automatically through standard Job Board re-evaluation. Possessed colonists never get a RETURN job posted and are unaffected. Force-tasked colonists also ignore the recall — they ignore `jobs_updated` entirely until released.

On release, the RETURN jobs are removed from the queue and colonists re-evaluate the Job Board as normal. Their previously interrupted job is back at its prior position.

---

## Signals

```gdscript
signal recall_triggered()
signal recall_released()
```

---

## Dependencies

- `JobBoard` — posts and removes RETURN jobs
- `PossessionManager` (autoload) — for possession check
- `"Colonists"` and `"Hubs"` groups
