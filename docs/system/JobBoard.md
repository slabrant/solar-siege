# System: Job Board

## Purpose
The Job Board is a global singleton that maintains all available tasks in the colony. Workers query it to find their next assignment. Players interact with it to issue Force Task overrides. It is the central coordination layer between player intent and worker behavior.

---

## Data

```gdscript
# JobBoard (autoload)
var available_jobs: Array[Job] = []
```

### Job Resource

```gdscript
class_name Job extends Resource

enum Priority  { LOW, MEDIUM, HIGH, CRITICAL }
enum JobType   { CONSTRUCTION, REPAIR, MINING, HAULING, FARMING, HUNTING, COMBAT, DISMANTLING }

var id: String
var type: JobType
var priority: Priority
var location: Vector3
var required_field: String = ""    # "Engineering", "Gunnery", "Harvesting", or "" for any
var assigned_worker: Node3D = null
var metadata: Dictionary = {}      # job-specific data (e.g. target node, resource type)
```

---

## API

```gdscript
func add_job(type: Job.JobType, priority: Job.Priority, location: Vector3, required_field: String = "") -> String:
    # Creates job, appends to available_jobs, emits jobs_updated
    # Returns job ID

func remove_job(id: String):
    # Removes job by ID, emits jobs_updated

func get_best_job_for(worker: Node3D) -> Job:
    # Returns highest-priority available job the worker can take
    # Sort: priority DESC, then distance ASC
    # Respects required_field (see Qualification below)

func get_job_by_id(id: String) -> Job:
    # Returns job or null
```

---

## Assignment Logic

```gdscript
func get_best_job_for(worker: Node3D) -> Job:
    var candidates = available_jobs.filter(func(j):
        return j.assigned_worker == null or j.assigned_worker == worker
    )

    candidates.sort_custom(func(a, b):
        if a.priority != b.priority:
            return a.priority > b.priority
        return worker.global_position.distance_to(a.location) < worker.global_position.distance_to(b.location)
    )

    for job in candidates:
        if _worker_qualifies(worker, job):
            return job

    return null
```

### Qualification

`required_field` gates job eligibility by skill level, not XP. A worker must have a minimum level in the required field to be considered qualified. The threshold is in OPEN_QUESTIONS.md (`MIN_FIELD_LEVEL`).

- If `required_field == ""` — any worker qualifies
- If `required_field` is set — worker's `levels[required_field]` must meet the threshold

```gdscript
func _worker_qualifies(worker: Node3D, job: Job) -> bool:
    if job.required_field == "":
        return true
    return worker.levels[job.required_field] >= MIN_FIELD_LEVEL  # see Balance.md
```

This is a soft routing preference — skilled workers go to relevant jobs first. Unqualified workers can still be Force Tasked onto any job.

---

## Signals

```gdscript
signal jobs_updated    # emitted on any add or remove; workers re-evaluate on receipt
```

---

## Re-Assignment Behavior

Workers listen to `jobs_updated`. On receipt, if not force-tasked, they call `get_best_job_for(self)`. If a better job exists than their current one, they release the current job (set `assigned_worker = null`) and take the new one.

Force-tasked workers ignore `jobs_updated` entirely until `release_task()` is called.

---

## Player Interaction

All players (up to 4) can:
- View the job board state
- Issue a Force Task to any worker (calls `worker.force_task(job)`)
- Release a Force Task (calls `worker.release_task()`)
- Manually post jobs (e.g. "build wall here") which enter the board at the specified priority

---

## Dependencies

- `Worker` nodes — query and hold job references
- Scene systems — post jobs when tasks arise (e.g. a Hub buffer running low posts a HAULING job)
