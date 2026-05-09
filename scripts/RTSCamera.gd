extends Camera3D

@export var move_speed: float = 20.0
@export var zoom_speed: float = 2.0

func _process(delta):
	var input_dir = Vector3.ZERO
	if Input.is_action_pressed(&"ui_right"): input_dir.x += 1
	if Input.is_action_pressed(&"ui_left"): input_dir.x -= 1
	if Input.is_action_pressed(&"ui_down"): input_dir.z += 1
	if Input.is_action_pressed(&"ui_up"): input_dir.z -= 1
	
	global_position += input_dir.normalized() * move_speed * delta

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			position.y -= zoom_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			position.y += zoom_speed
		position.y = clamp(position.y, 5.0, 50.0)
