# System: Food

## Purpose
Food keeps the colony alive and productive. The workforce's nutrition state affects worker output and whether new workers can be produced. Food is a shared colonial resource — all Hubs draw from the same pool.

---

## Nutrition States

```gdscript
enum NutritionState { HUNGRY, NORMAL, WELL_FED }
```

| State | Condition | Effect |
|---|---|---|
| Hungry | Food pool below hungry threshold | Worker production halted |
| Normal | Food pool between thresholds | No modifier |
| Well-Fed | Food pool above well-fed threshold | Speed and XP gain bonus for all workers |

Both thresholds scale with current workforce size (queried from the `"Workers"` group):

```gdscript
var worker_count = get_tree().get_nodes_in_group("Workers").size()
var well_fed_threshold: float = BASE_WELL_FED * worker_count  # see Balance.md
var hungry_threshold: float   = BASE_HUNGRY * worker_count    # see Balance.md
```

---

## Global Food Pool

```gdscript
# FoodManager (autoload)

var food_points: float = 0.0
var nutrition_state: NutritionState = NutritionState.NORMAL

signal nutrition_changed(new_state: NutritionState)

func consume_food(amount: float) -> bool:
    if food_points < amount:
        return false
    food_points -= amount
    _evaluate_nutrition()
    return true
```

Food points are added when workers deliver food to any Hub. The pool is shared — there is no per-Hub food storage.

Food is consumed over time at a rate proportional to workforce size:

```gdscript
func _process(delta):
    var worker_count = get_tree().get_nodes_in_group("Workers").size()
    food_points -= FOOD_CONSUMPTION_RATE * worker_count * delta  # see Balance.md
    food_points = max(food_points, 0.0)
    _evaluate_nutrition()
```

---

## Food Sources

All food sources are Harvesting or Gunnery tasks posted to the Job Board.

| Source | Field | Sub-Specialty | Job Type |
|---|---|---|---|
| Crops / Foraging | Harvesting | Harvester-Farmer | FARMING |
| Hunting tower | Gunnery | Hunter | HUNTING |

Hunting is operated from stationary hunting towers — Gunners cannot hunt on foot. Animals roam the map and are drawn toward hunting towers.

---

## Food Items & Points

Different foods contribute different point values when delivered. A basic crop might contribute 1–5 points; a hunted animal significantly more. Exact values are in Balance.md.

---

## Well-Fed Bonus

Applied colony-wide when `NutritionState == WELL_FED`. Speed and XP gain rate are both multiplied — see `WELL_FED_SPEED_BONUS` and `WELL_FED_XP_BONUS` in Balance.md.

Workers do not need to be near a Hub to receive the bonus. It applies to all workers regardless of location.

---

## Worker Production Gate

New Recruits cannot spawn from any Hub while `NutritionState == HUNGRY`. The spawn UI should reflect this clearly.

---

## Signals

```gdscript
signal nutrition_changed(new_state: NutritionState)
signal food_delivered(amount: float, source: String)
```

---

## Dependencies

- `Worker` — applies Well-Fed bonus to speed and XP gain rate
- `Hub` — receives food deliveries (routes to global pool)
- `JobBoard` — FARMING and HUNTING jobs posted here
- `"Workers"` group — for worker count in threshold scaling and food consumption
