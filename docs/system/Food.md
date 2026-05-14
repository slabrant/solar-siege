# System: Food

A single shared pool. The colony's nutrition state affects colonist output and spawning.

---

## Nutrition States

```gdscript
enum NutritionState { HUNGRY, NORMAL, WELL_FED }
```

| State    | Condition                        | Effect                         |
|----------|----------------------------------|--------------------------------|
| Hungry   | Food pool below hungry threshold | New colonists cannot be queued |
| Normal   | Between thresholds               | No modifier                    |
| Well-Fed | Above well-fed threshold         | Speed and XP bonus colony-wide |

Thresholds scale with current colony size:

```gdscript
var colonist_count = get_tree().get_nodes_in_group("Colonists").size()
var well_fed_threshold: float = BASE_WELL_FED * colonist_count   # see Balance.md
var hungry_threshold: float   = BASE_HUNGRY * colonist_count     # see Balance.md
```

---

## Global Food Pool

```gdscript
# FoodManager (autoload)

var food_points: float = 0.0
var nutrition_state: NutritionState = NutritionState.NORMAL

func add_food(amount: float) -> void:
    food_points += amount
    _evaluate_nutrition()

func consume_food(amount: float) -> bool:
    if food_points < amount:
        return false
    food_points -= amount
    _evaluate_nutrition()
    return true
```

Food is consumed over time proportional to colony size:

```gdscript
func _process(delta: float) -> void:
    var colonist_count = get_tree().get_nodes_in_group("Colonists").size()
    food_points -= FOOD_CONSUMPTION_RATE * colonist_count * delta  # see Balance.md
    food_points = max(food_points, 0.0)
    _evaluate_nutrition()
```

---

## Food Sources

| Source          | Field      | Sub-Specialty | Job Type |
|-----------------|------------|---------------|----------|
| Crops, foraging | Harvesting | Farmer        | FARMING  |
| Hunting tower   | Gunnery    | Hunter        | HUNTING  |

Hunting yields drop as Resource Piles at the hunting tower. A Hauler must bring them to a Hub before they count toward the global pool — see SYSTEMS/HuntingTower.md.

---

## Well-Fed Bonus

When `NutritionState == WELL_FED`, every colonist gains `WELL_FED_SPEED_BONUS` to task speed and `WELL_FED_XP_BONUS` to XP gain rate (see Balance.md). Applied colony-wide; no proximity to Hubs required.

---

## Signals

```gdscript
signal nutrition_changed(new_state: NutritionState)
signal food_delivered(amount: float, source: String)
```

---

## Dependencies

- `Colonist` — applies Well-Fed bonus
- `Hub` — receives food deliveries
- `JobBoard` — FARMING and HUNTING jobs
- `"Colonists"` group — for count
