extends Node
class_name PossessionManager

signal possession_changed(unit: Node3D, is_possessed: bool)

var current_possessed_unit: Node3D = null
var rts_camera: Camera3D = null

func possess(unit: Node3D):
	if current_possessed_unit:
		unpossess()
	
	current_possessed_unit = unit
	if unit.has_method(&"on_possess"):
		unit.call(&"on_possess")
	
	possession_changed.emit(unit, true)
	print("Possessed: ", unit.name)

func unpossess():
	if not current_possessed_unit:
		return
	
	var unit = current_possessed_unit
	current_possessed_unit = null
	
	if unit.has_method(&"on_unpossess"):
		unit.call(&"on_unpossess")
	
	possession_changed.emit(unit, false)
	print("Unpossessed unit")

func _input(event):
	if event.is_action_pressed(&"ui_cancel") and current_possessed_unit:
		unpossess()
