extends StaticBody3D
class_name Turret

@export var fire_rate: float = 1.0 # shots per second
@export var damage: float = 20.0
@export var ammo_per_shot: float = 1.0

@onready var buffer: ResourceBuffer = $ResourceBuffer
@onready var timer: Timer = $Timer
@onready var barrel: Node3D = $Barrel

var is_possessed: bool = false

func _ready():
	timer.wait_time = 1.0 / fire_rate
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout():
	if is_possessed: return # Handle manual fire in possession
	
	if buffer.consume_resource("Ammo", ammo_per_shot):
		_fire()

func _fire():
	# Visuals/Logic for firing
	print(name, " fired!")
	# Target finding logic would go here

func on_possess():
	is_possessed = true
	# Enable 1st person camera
	if has_node(^"Camera3D"):
		get_node(^"Camera3D").make_current()

func on_unpossess():
	is_possessed = false
	# Return to RTS camera handled by PossessionManager usually
