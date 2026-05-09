extends Node3D

func _ready():
	print("Solar Siege Demo Started")
	SolarCycle.phase_changed.connect(_on_phase_changed)
	SolarCycle.hour_changed.connect(_on_hour_changed)
	
	# Create some test jobs
	JobBoard.add_job(Job.JobType.MINING, Job.Priority.LOW, Vector3(10, 0, 10))
	JobBoard.add_job(Job.JobType.CONSTRUCTION, Job.Priority.HIGH, Vector3(-5, 0, -5))

func _on_phase_changed(phase: String):
	print("Phase changed to: ", phase)

func _on_hour_changed(hour: float):
	if int(hour * 10) % 20 == 0: # Print every 2 hours-ish to avoid spam
		print("Current Time: ", snapped(hour, 0.1), " Solar Strength: ", snapped(SolarCycle.get_solar_strength(), 0.01))
