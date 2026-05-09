extends CharacterBody3D

@export var worker_name: String = "Recruit"
@export var movement_speed: float = 5.0

var current_job: Job = null
var is_force_tasked: bool = false
var inventory: Dictionary = {"Scrap": 0.0, "Food": 0.0, "Ammo": 0.0}

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	JobBoard.jobs_updated.connect(_on_jobs_updated)
	_find_new_job()

func _physics_process(delta):
	if current_job:
		_move_to_job(delta)
		_work_on_job(delta)

func _work_on_job(delta):
	if navigation_agent.is_navigation_finished():
		match current_job.type:
			Job.JobType.MINING:
				_harvest_scrap(delta)
			Job.JobType.LOGISTICS:
				_transfer_resources(delta)

func _harvest_scrap(delta):
	# Harvesting logic (e.g. from Robot Scrap Statues)
	inventory["Scrap"] += 10.0 * delta
	if inventory["Scrap"] >= 50.0:
		# Auto-create a logistics job or switch to returning it
		_return_to_hub()

func _return_to_hub():
	var hubs = get_tree().get_nodes_in_group(&"Hubs")
	if hubs.size() > 0:
		var hub = hubs[0] # Just pick the first for now
		navigation_agent.target_position = hub.global_position

func _transfer_resources(delta):
	# Logic to move items from buffer to buffer
	pass

func _on_jobs_updated():
	if not is_force_tasked:
		_find_new_job()

func _find_new_job():
	var best_job = JobBoard.get_best_job_for(self)
	if best_job != current_job:
		if current_job:
			current_job.assigned_worker = null
		
		current_job = best_job
		if current_job:
			current_job.assigned_worker = self
			navigation_agent.target_position = current_job.location

func _move_to_job(delta):
	if navigation_agent.is_navigation_finished():
		return

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed
	
	velocity = new_velocity
	move_and_slide()

func force_task(job):
	is_force_tasked = true
	if current_job:
		current_job.assigned_worker = null
	current_job = job
	current_job.assigned_worker = self
	navigation_agent.target_position = current_job.location

func release_task():
	is_force_tasked = false
	_find_new_job()
