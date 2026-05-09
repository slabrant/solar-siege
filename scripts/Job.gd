extends Resource
class_name Job

enum Priority { LOW, MEDIUM, HIGH, CRITICAL }
enum JobType { CONSTRUCTION, LOGISTICS, MINING, COMBAT }

@export var id: String
@export var type: JobType
@export var priority: Priority
@export var location: Vector3
@export var required_skill: String = ""
var assigned_worker: Node3D = null

func _init(_id: String = "", _type: JobType = JobType.CONSTRUCTION, _priority: Priority = Priority.LOW, _location: Vector3 = Vector3.ZERO):
	id = _id
	type = _type
	priority = _priority
	location = _location
