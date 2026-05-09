extends StaticBody3D
class_name Hub

@export var well_fed_threshold: float = 0.8 # Percent of food buffer

@onready var buffer: ResourceBuffer = $ResourceBuffer

func _ready():
	add_to_group(&"Hubs")
	# Hubs naturally have high capacity
	buffer.capacities["Food"] = 1000.0
	buffer.capacities["Ammo"] = 500.0
	buffer.capacities["Scrap"] = 2000.0

func is_well_fed() -> bool:
	return buffer.get_fill_percent("Food") >= well_fed_threshold

func take_damage(amount: float):
	print("Hub under attack! Health logic needed.")
