extends Node3D

func _ready():
	# 1. Setup Environment
	var sun = DirectionalLight3D.new()
	add_child(sun)
	sun.rotation_degrees = Vector3(-45, 45, 0)
	
	var floor = MeshInstance3D.new()
	floor.mesh = PlaneMesh.new()
	floor.mesh.size = Vector2(100, 100)
	add_child(floor)
	floor.create_trimesh_collision()
	
	# 2. Setup Hub
	var hub = StaticBody3D.new()
	hub.name = "CentralHub"
	hub.set_script(load("res://scripts/Hub.gd"))
	var hub_buffer = Node.new()
	hub_buffer.name = "ResourceBuffer"
	hub_buffer.set_script(load("res://scripts/ResourceBuffer.gd"))
	hub.add_child(hub_buffer)
	add_child(hub)
	hub.position = Vector3.ZERO
	
	# 3. Setup Workers
	for i in range(3):
		var worker = CharacterBody3D.new()
		worker.name = "Worker_" + str(i)
		worker.set_script(load("res://scripts/Worker.gd"))
		var nav = NavigationAgent3D.new()
		nav.name = "NavigationAgent3D"
		worker.add_child(nav)
		add_child(worker)
		worker.position = Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))

	# 4. Setup RTS Camera
	var cam = Camera3D.new()
	cam.set_script(load("res://scripts/RTSCamera.gd"))
	add_child(cam)
	cam.position = Vector3(0, 20, 20)
	cam.rotation_degrees = Vector3(-45, 0, 0)
	cam.make_current()

	print("Solar Siege initialized. Use Arrow Keys to move camera, Wheel to zoom.")
	print("Robots will spawn at Dawn.")

func _on_solar_phase_changed(phase: String):
	if phase == "DAY":
		_spawn_robot_wave()

func _spawn_robot_wave():
	print("Spawning robot wave...")
	# Logic to spawn Robot instances
