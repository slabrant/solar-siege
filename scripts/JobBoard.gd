extends Node

signal jobs_updated

var available_jobs: Array[Job] = []

func add_job(type: Job.JobType, priority: Job.Priority, location: Vector3) -> String:
	var id = str(Time.get_ticks_msec()) + "_" + str(randi())
	var new_job = Job.new(id, type, priority, location)
	available_jobs.append(new_job)
	jobs_updated.emit()
	return id

func remove_job(id: String):
	for i in range(available_jobs.size()):
		if available_jobs[i].id == id:
			available_jobs.remove_at(i)
			jobs_updated.emit()
			return

func get_best_job_for(worker: Node3D) -> Job:
	# Basic logic: Get highest priority, then closest
	if available_jobs.is_empty():
		return null
	
	var sorted_jobs = available_jobs.duplicate()
	sorted_jobs.sort_custom(func(a: Job, b: Job):
		if a.priority != b.priority:
			return a.priority > b.priority
		return worker.global_position.distance_to(a.location) < worker.global_position.distance_to(b.location)
	)
	
	for job in sorted_jobs:
		if job.assigned_worker == null or job.assigned_worker == worker:
			return job
	
	return null
