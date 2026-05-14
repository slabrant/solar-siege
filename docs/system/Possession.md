# System: Possession

Any player can drop into any colonist for direct 1st-person control. Possession gives a flat task-speed multiplier on top of skill — see `POSSESSION_BONUS` in Balance.md.

---

## Data

```gdscript
# PossessionManager (autoload)
var possessed: Dictionary = {
    1: null,
    2: null,
    3: null,
    4: null,
}
```

---

## Rules

- One colonist per player at a time
- One player per colonist at a time
- Possessed colonists are visually highlighted for all players
- Exiting possession returns the player to their strategic view at its last position

---

## Possess / Unpossess

```gdscript
func possess(player_id: int, unit: Node3D) -> bool:
    if unit.is_possessed:
        return false
    if possessed[player_id] != null:
        unpossess(player_id)
    possessed[player_id] = unit
    unit.call(&"on_possess", player_id)
    possession_changed.emit(player_id, unit, true)
    return true

func unpossess(player_id: int) -> void:
    var unit = possessed[player_id]
    if not unit:
        return
    possessed[player_id] = null
    unit.call(&"on_unpossess")
    possession_changed.emit(player_id, unit, false)
```

---

## Colonist Contract

The Colonist node implements:

```gdscript
func on_possess(player_id: int) -> void:
    is_possessed = true
    possessing_player = player_id
    $Camera3D.make_current()

func on_unpossess() -> void:
    is_possessed = false
    possessing_player = -1
    _find_new_job()
```

On colonist death while possessed, `PossessionManager.unpossess()` is called before `queue_free()`. The player returns to the strategic view. The game does not end.

---

## Towers via Gunners

Possessing the Gunner assigned to a tower gives the player direct control of that tower's aim and fire through them. Gunnery skill and possession bonus both apply.

---

## Signals

```gdscript
signal possession_changed(player_id: int, unit: Node3D, is_possessed: bool)
```

---

## Dependencies

- `Colonist` — implements `on_possess` / `on_unpossess`
- `StrategicCamera` — per-player camera returned to on exit
- `InputManager` (planned) — per-player controller mapping
