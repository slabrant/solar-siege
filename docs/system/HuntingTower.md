# System: Hunting Tower

A type of Tower (see SYSTEMS/Tower.md) specialized for hunting. This doc covers only what's different.

---

## Key Differences from Tower

- **Targets animals**, not robots
- **Consumes Stone** as ammunition instead of Ammo
- **Produces food on kill**, which drops as a Resource Pile at the tower's location
- **Can be placed anywhere on the map** — no Hub proximity required
- **Robots may target hunting towers**, but they are not primary targets
- **Attracts animals** within an `attraction_radius`

---

## Data

```gdscript
class_name HuntingTower extends Tower

@export var attraction_radius: float = 60.0
```

`ammo_per_shot` is interpreted as Stone per shot. Other Tower fields (`base_fire_rate`, `damage`, `attack_range`, `ammo_capacity`) function identically.

---

## Food Yield

When an animal is killed by a hunting tower, the food yield drops as a Resource Pile (containing `Food` type) at the tower's location. A Hauler is needed to bring it to a Hub before it joins the colony food pool.

```gdscript
func _on_animal_killed(animal: Animal) -> void:
    var pile = preload("res://scenes/ResourcePile.tscn").instantiate()
    pile.contents = { "Food": animal.food_yield }
    get_parent().add_child(pile)
    pile.global_position = global_position
    animal_killed.emit(animal)
```

---

## Animal Attraction

Animals within `attraction_radius` are drawn toward the tower. See SYSTEMS/Animals.md.

---

## Signals

Inherits from Tower. Adds:

```gdscript
signal animal_killed(animal: Animal)
```

---

## Dependencies

- `Animal` — target nodes; see SYSTEMS/Animals.md
- `ResourcePile` — food yield drop
