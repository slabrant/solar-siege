# System: Animals

Animals roam the map ambient to the colony. They are the source of food for Hunters. They have no significance beyond hunting — they don't attack, they don't interact with structures, they wander.

---

## Data

```gdscript
class_name Animal extends CharacterBody3D

@export var max_health: float
@export var base_speed: float = 2.0
@export var food_yield: float          # delivered as Food on kill

var health: float
var attracted_to: HuntingTower = null  # if drawn by a nearby tower
```

---

## Species

See Balance.md for health and yield values per species.

| Species | Notes                   |
|---------|-------------------------|
| Bunny   | Small, fast, low yield  |
| Turkey  | Medium                  |
| Deer    | Large, slow, high yield |

---

## Behavior

Animals wander randomly. If a `HuntingTower` is within its `attraction_radius`, the animal drifts toward it. The wander/attraction balance and exact movement model are in OPEN_QUESTIONS.md.

```gdscript
func _physics_process(delta: float) -> void:
    if attracted_to:
        _move_toward(attracted_to.global_position, delta)
    else:
        _wander(delta)
```

---

## Damage

```gdscript
func take_damage(amount: float) -> void:
    health -= amount
    if health <= 0:
        _die()

func _die() -> void:
    animal_died.emit(self)
    queue_free()
```

The hunting tower handles food-yield drop on kill — see SYSTEMS/HuntingTower.md.

---

## Spawning

Animals spawn naturally around the map. Spawn rates, density, and distribution are in OPEN_QUESTIONS.md.

---

## Signals

```gdscript
signal animal_died(animal: Animal)
```
