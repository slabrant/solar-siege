# System: Job Board

The Job Board is a global singleton holding every available task in the colony. Colonists query it for their next assignment. Players post jobs, force-task colonists, and configure routing here.

---

## Data

```gdscript
# JobBoard (autoload)

var jobs: Array[Job] = []   # ordered list, highest priority first
```

### Job Resource

```gdscript
class_name Job extends Resource

enum JobType { CONSTRUCTION, REPAIR, MINING, HAULING, FARMING, HUNTING, DISMANTLING, OPERATE_TOWER, RETURN }

var id: String
var type: JobType
var location: Vector3
var required_field: String = ""    # "Engineering", "Gunnery", "Harvesting", or "" for any
var assigned_colonist: Node3D = null
var metadata: Dictionary = {}
```

---

## Priority

Priority is the colonist's position in the ordered `jobs` list, not an enum. When a job is posted, it inserts into the list at the appropriate position.

Most jobs are added at a default position. A job flagged `very_much` is inserted at the very top, ahead of all other work — used by Recall and other urgent player actions to ensure colonists drop everything.

```gdscript
func add_job(job: Job, very_much: bool = false) -> String:
    if very_much:
        jobs.push_front(job)
    else:
        jobs.append(job)
    jobs_updated.emit()
    return job.id

func remove_job(id: String) -> void:
    jobs = jobs.filter(func(j): return j.id != id)
    jobs_updated.emit()
```

---

## Assignment

A colonist queries for the best job they can reach within their `range_cutoff`:

```gdscript
func get_best_job_for(colonist: Node3D) -> Job:
    for job in jobs:
        if job.location.distance_to(colonist.global_position) > colonist.range_cutoff:
            continue
        if job.assigned_colonist == null or job.assigned_colonist == colonist:
            return job
        if _can_preempt(colonist, job):
            return job
    return null
```

Jobs are evaluated in priority order. The first reachable, takeable job wins. No sorting is needed at query time — the list is already ordered.

---

## Qualification & Preemption

A more qualified colonist can take a job away from a less qualified one — but only on jobs that have a `required_field`, and only when the skill gap is significant.

```gdscript
func _can_preempt(colonist: Node3D, job: Job) -> bool:
    if job.assigned_colonist == null:
        return true
    if job.required_field == "":
        return false                         # no field gate — first-come-first-served
    var their_level = job.assigned_colonist.levels[job.required_field]
    var my_level    = colonist.levels[job.required_field]
    return my_level - their_level >= QUAL_PREEMPT_LEVEL_GAP  # see Balance.md
```

The preempted colonist re-evaluates the Job Board on the next `jobs_updated` cycle and picks something else. They don't drop their current action mid-swing — they finish the tick and move on.

---

## Re-Assignment

When `jobs_updated` fires, colonists not force-tasked call `get_best_job_for(self)`. If a better job exists, they release the current one and take the new one.

Force-tasked colonists ignore `jobs_updated` until released.

---

## Range Cutoff

Each colonist has a `range_cutoff` field that limits how far they'll travel for a job. Default is in Balance.md. Adjustable from the Job Board UI per colonist — a player might give a homebody colonist a small radius and a scout a large one.

---

## Player-Initiated Jobs

Players can post jobs directly:

- **Area paint** — Select an area of the map; every resource of the chosen type within the area becomes a job
- **Single target** — Click one resource or structure to add it to the board
- **Build location** — Mark a spot for a structure. Materials are auto-requested via HAULING jobs; once delivered, the CONSTRUCTION job becomes takeable
- **Force task** — Lock a specific colonist to a specific job
- **Very_much** — Flag a job to jump to the top of the queue

A colonist working an area continues until either the resources are exhausted or they die.

---

## Idle Indicator

The Job Board exposes which colonists currently have no job. The UI presents a **Find Idle Colonist** action to focus the camera on one.

```gdscript
func get_idle_colonists() -> Array:
    return get_tree().get_nodes_in_group("Colonists").filter(func(c): return c.current_job == null)
```

---

## Signals

```gdscript
signal jobs_updated
```

---

## Dependencies

- `Colonist` nodes — query jobs, hold assignments
- Scene systems — post jobs when conditions arise (low buffer → HAULING, fresh ResourcePile → HAULING, etc.)
