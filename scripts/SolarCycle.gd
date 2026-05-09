extends Node

signal hour_changed(hour: float)
signal phase_changed(phase: String)

enum DayPhase { DAY, NIGHT }

@export var day_duration: float = 600.0 # 10 minutes per cycle
@export var current_time: float = 6.0 # 0.0 to 24.0, starts at 6 AM

var current_phase: DayPhase = DayPhase.DAY

func _process(delta: float):
	current_time += (delta / day_duration) * 24.0
	if current_time >= 24.0:
		current_time -= 24.0
	
	hour_changed.emit(current_time)
	
	var new_phase = DayPhase.DAY if (current_time >= 6.0 and current_time < 18.0) else DayPhase.NIGHT
	if new_phase != current_phase:
		current_phase = new_phase
		phase_changed.emit("DAY" if current_phase == DayPhase.DAY else "NIGHT")

func get_solar_strength() -> float:
	# S = S_max * sin(theta). Theta is 0 at 6 AM, PI/2 at Noon, PI at 6 PM.
	if current_phase == DayPhase.NIGHT:
		return 0.0
	
	# Map 6.0-18.0 to 0.0-PI
	var theta = clamp(((current_time - 6.0) / 12.0) * PI, 0.0, PI)
	return sin(theta)
