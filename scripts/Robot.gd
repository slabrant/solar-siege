extends CharacterBody3D
class_name Robot

@export var max_health: float = 50.0
@export var movement_speed: float = 3.0
@export var damage: float = 10.0

var health: float = max_health
var is_frozen: bool = false
var target: Node3D = null

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	health = max_health
	SolarCycle.phase_changed.connect(_on_solar_phase_changed)
	_on_solar_phase_changed("DAY" if SolarCycle.current_phase == SolarCycle.DayPhase.DAY else "NIGHT")

func _physics_process(delta):
	if is_frozen or health <= 0:
		return
	
	if target:
		nav_agent.target_position = target.global_position
		
		if nav_agent.is_navigation_finished():
			_attack_target(delta)
		else:
			var next_pos = nav_agent.get_next_path_position()
			var solar_boost = 1.0 + SolarCycle.get_solar_strength()
			var velocity_boosted = global_position.direction_to(next_pos) * movement_speed * solar_boost
			velocity = velocity_boosted
			move_and_slide()

func _on_solar_phase_changed(phase: String):
	is_frozen = (phase == "NIGHT")
	if is_frozen:
		set_physics_process(false)
		# Visual indicator for "Scrap Statue" could be added here
	else:
		set_physics_process(true)

func take_damage(amount: float):
	health -= amount
	if health <= 0:
		_die()

func _die():
	# Drop scrap or become a harvestable object
	print("Robot died")
	queue_free()

func _attack_target(delta):
	if target.has_method(&"take_damage"):
		target.call(&"take_damage", damage * delta)
