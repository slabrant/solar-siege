# System: Solar Cycle

The Solar Cycle is the heartbeat of the game. Time advances, the phase changes, and solar strength scales robot behavior.

---

## Data

```gdscript
# SolarCycle (autoload)

enum DayPhase { DAY, NIGHT }

var current_time: float = START_TIME      # see Balance.md
var current_phase: DayPhase = DayPhase.DAY
```

---

## Time Progression

```gdscript
func _process(delta: float) -> void:
    current_time += (delta / DAY_DURATION) * 24.0  # see Balance.md
    if current_time >= 24.0:
        current_time -= 24.0

    _emit_hour_changed_if_crossed()

    var new_phase = DayPhase.DAY if (current_time >= 6.0 and current_time < 18.0) else DayPhase.NIGHT
    if new_phase != current_phase:
        current_phase = new_phase
        phase_changed.emit(current_phase)
```

**Day:** 6:00 – 18:00
**Night:** 18:00 – 6:00

---

## Solar Strength

```gdscript
func get_solar_strength() -> float:
    if current_phase == DayPhase.NIGHT:
        return 0.0
    var theta = ((current_time - 6.0) / 12.0) * PI  # 6AM=0, Noon=PI/2, 6PM=PI
    return sin(theta)
```

Returns a float in `[0.0, 1.0]`. Used by Robot for speed/damage scaling and Engineering dismantling for thorns damage.

---

## Signals

```gdscript
signal hour_changed(hour: int)                # emits when the hour rolls over (1-24)
signal phase_changed(phase: DayPhase)         # emits on transition only
```

`hour_changed` fires once per in-game hour, not every frame. Quarter-hour granularity is reserved for the clock UI to compute locally.

Consumers compare against `SolarCycle.DayPhase.DAY` or `SolarCycle.DayPhase.NIGHT`.
