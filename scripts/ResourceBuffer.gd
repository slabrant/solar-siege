extends Node
class_name ResourceBuffer

signal buffer_changed(type: String, amount: float)
signal buffer_empty(type: String)

@export var capacities: Dictionary = {"Ammo": 100.0, "Food": 100.0, "Scrap": 500.0}
var current_resources: Dictionary = {"Ammo": 0.0, "Food": 0.0, "Scrap": 0.0}

func add_resource(type: String, amount: float) -> float:
	if not current_resources.has(type):
		return amount # Rejected
	
	var space = capacities[type] - current_resources[type]
	var added = min(amount, space)
	current_resources[type] += added
	buffer_changed.emit(type, current_resources[type])
	return amount - added # Return overflow

func consume_resource(type: String, amount: float) -> bool:
	if not current_resources.has(type) or current_resources[type] < amount:
		if current_resources.has(type):
			buffer_empty.emit(type)
		return false
	
	current_resources[type] -= amount
	buffer_changed.emit(type, current_resources[type])
	return true

func get_fill_percent(type: String) -> float:
	if not current_resources.has(type): return 0.0
	return current_resources[type] / capacities[type]
