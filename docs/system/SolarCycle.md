# System: Solar Cycle

## Purpose
The Solar Cycle is the heartbeat of the game. It drives robot behavior, governs when the colony is under attack, and determines when night operations can begin. Everything time-sensitive listens to it.

---

## Data

```gdscript
# SolarCycle (autoload)

enum DayPhase { DAY, NIGHT }

@export var day_duration: float = 600.0   # real seconds per full 24-hour cycle
@export var start_time: float = 6.0       # game starts at 6 AM

var current_time: float = 6.0             # 0.0 to 24.0
var current_phase: DayPhase = DayPhase.DAY
```

---

## Time Progression

```gdscript
func _process(delta: float) -> void:
    current_time += (delta / day_duration) * 24.0
    if current_time >= 24.0:
        current_time -= 24.0

    hour_changed.emit(current_time)

    var new_phase = DayPhase.DAY if (current_time >= 6.0 and current_time < 18.0) else DayPhase.NIGHT
    if new_phase != current_phase:
        current_phase = new_phase
        phase_changed.emit(current_phase)
```

**Day:** 6:00 – 18:00
**Night:** 18:00 – 6:00

---

## Solar Strength Formula

```gdscript
func get_solar_strength() -> float:
    if current_phase == DayPhase.NIGHT:
        return 0.0
    # Maps 6AM → 0, Noon → 1.0, 6PM → 0
    var theta = ((current_time - 6.0) / 12.0) * PI
    return sin(theta)
```

Returns a float in [0.0, 1.0]. Used by robots to scale speed and damage.

---

## Signals

```gdscript
signal hour_changed(hour: float)              # emits every frame
signal phase_changed(phase: DayPhase)         # emits on transition only
```

Consumers compare against `SolarCycle.DayPhase.DAY` or `SolarCycle.DayPhase.NIGHT`.

---

## Consumers

| System | What it listens to |
|---|---|
| Robot | `phase_changed` — freeze/thaw; `get_solar_strength()` — speed/damage scaling |
| Turret | `phase_changed` — optional behavior changes |
| UI | `hour_changed` — clock display |
| GameState | `phase_changed` — triggers wave spawning at dawn |

---

## Dependencies

None. SolarCycle is a pure singleton with no external dependencies.
