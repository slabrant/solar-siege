extends Node3D
class_name ConveyorBelt

@export var speed: float = 2.0
@export var item_mesh: Mesh
@export var belt_width: float = 1.0

@onready var path: Path3D = $Path3D
@onready var multimesh: MultiMeshInstance3D = $MultiMeshInstance3D

var items: Array[Dictionary] = [] # { progress: float, type: String }

func _ready():
	if not multimesh.multimesh:
		multimesh.multimesh = MultiMesh.new()
		multimesh.multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.multimesh.mesh = item_mesh

func _process(delta):
	_update_items(delta)
	_draw_items()

func add_item(type: String):
	items.append({"progress": 0.0, "type": type})

func _update_items(delta):
	var to_remove = []
	for i in range(items.size()):
		items[i].progress += (speed * delta) / path.curve.get_baked_length()
		if items[i].progress >= 1.0:
			to_remove.append(i)
	
	# Handle item exiting belt (logic for next belt/buffer goes here)
	for index in to_remove:
		items.remove_at(index)

func _draw_items():
	multimesh.multimesh.instance_count = items.size()
	var curve = path.curve
	for i in range(items.size()):
		var pos = curve.sample_baked_with_rotation(items[i].progress * curve.get_baked_length())
		multimesh.multimesh.set_instance_transform(i, pos)
