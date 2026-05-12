# System: Possession

## Purpose
Any of the four players can drop into any worker at any time for direct 1st-person control. Possession gives the player full control of that worker with a bonus to all their abilities. See the GDD for design intent.

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

- A worker can only be possessed by one player at a time
- A player can only possess one worker at a time
- Possessed workers are highlighted visually for all players
- Escape exits possession and returns the player to their RTS camera

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

Worker-side implementation is in SYSTEMS/Worker.md.

---

## Possession Bonus

A flat multiplier applied to all task speeds while a worker is possessed. See `POSSESSION_BONUS` in Balance.md.

Applied inside `Worker.get_task_speed()` when `is_possessed` is true. All skill levels still apply on top.

---

## Gunners & Turrets

Workers don't possess turrets directly. A Gunner operates a turret — possessing the Gunner puts the player in direct control through them. The Gunner's skill and possession bonus both apply to fire rate.

```gdscript
# Turret — applies assigned worker's Gunnery skill to fire rate
func _fire() -> void:
    var skill_bonus = 1.0
    if assigned_worker:
        skill_bonus = 1.0 + assigned_worker.levels["Gunnery"] * SPEED_SCALE  # see Balance.md
    # apply skill_bonus to fire rate
```

---

## Death While Possessed

Handled in `Worker._die()`. The player is returned to their RTS view. The game does not end.

---

## Visual Indicator

Possessed workers display a distinct highlight visible to all players, differentiated by player. Implementation not yet decided — see OPEN_QUESTIONS.md.

---

## Signals

```gdscript
signal possession_changed(player_id: int, unit: Node3D, is_possessed: bool)
```

---

## Dependencies

- `Worker` — implements `on_possess` / `on_unpossess`
- `RTSCamera` — each player's strategic camera
- `InputManager` (planned) — per-player input remapping
