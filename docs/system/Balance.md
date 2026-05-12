# Balance Reference

All tunable constants for the game. This is the single source of truth for values that affect game feel. Constants are named here and referenced by name in system docs.

A `Balance.gd` autoload could be derived directly from this file.

---

```gdscript
# Balance.gd

# --- XP & Progression ---
const XP_PER_HEALTH: float        = 1.0    # XP awarded per health point processed, all fields
const HAUL_XP_PER_METER: float    = 0.5    # Harvesting XP per meter traveled while carrying
const BASE_XP_PER_LEVEL: float    = 100.0  # XP required for level n = BASE_XP_PER_LEVEL * n
const MAX_LEVEL: int               = 128    # per field; also the color channel range

# --- Worker Color ---
const BASE_COLOR_CHANNEL: int     = 127    # starting gray; all channels begin here
# Max channel = BASE_COLOR_CHANNEL + MAX_LEVEL = 255

# --- Worker Speed ---
const SPEED_SCALE: float          = 0.02   # +2% task speed per level in the relevant field

# --- Possession ---
const POSSESSION_BONUS: float     = 1.5    # flat multiplier on all task speeds while possessed

# --- Dual Specialty ---
const DUAL_SPECIALTY_THRESHOLD: float = 0.0  # ratio; needs playtesting — see OPEN_QUESTIONS.md

# --- Well-Fed ---
const WELL_FED_SPEED_BONUS: float = 1.25   # +25% task speed colony-wide
const WELL_FED_XP_BONUS: float    = 1.50   # +50% XP gain rate colony-wide
const BASE_WELL_FED: float        = 50.0   # food points per worker for Well-Fed threshold
const BASE_HUNGRY: float          = 10.0   # food points per worker for Hungry threshold
const FOOD_CONSUMPTION_RATE: float = 0.1   # food points consumed per worker per second

# --- Hub Spawning ---
const RECRUIT_FOOD_COST: float    = 25.0   # food points consumed to queue a Recruit
const SPAWN_DURATION: float       = 30.0   # seconds to produce one Recruit
```

---

## Object Health Values

Health doubles as XP yield — a 200hp tree gives 200 Harvesting XP. All values are starting estimates.

### Natural Resources

| Object | Health | Field |
|---|---|---|
| Small tree | 100 | Harvesting |
| Large tree | 300 | Harvesting |
| Ore deposit (small) | 150 | Harvesting |
| Ore deposit (large) | 500 | Harvesting |
| Basic crop | 20 | Harvesting |
| Premium crop | 100 | Harvesting |
| Foraged item | 10 | Harvesting |
| Small animal | 80 | Gunnery |
| Large animal | 250 | Gunnery |

### Robots

| Robot Type | Health | Base Scrap | Notes |
|---|---|---|---|
| Basic robot | 200 | 200 | Early game |
| Heavy robot | 600 | 600 | Late game; drops ShinyScrap |

### Structures

Building and repairing a structure awards Engineering XP equal to health points added or restored.

| Structure | Health |
|---|---|
| Wall segment | 200 |
| Reinforced wall | 600 |
| Basic turret | 400 |
| Hunting tower | 300 |
| Processing building | 800 |
| Production building | 1000 |
| Hub | 3000 |
| Rail track segment | 50 |
| Conveyor segment | 100 |

---

## Pacing Sanity Check

Full day cycle: 600 seconds real time. Day and night are each 300 seconds.

| Action | Time Per Action | XP Per Day (est.) |
|---|---|---|
| Chop small trees | ~15s | ~4,000 Harvesting |
| Mine ore (small) | ~20s | ~4,500 Harvesting |
| Harvest basic crops | ~3s | ~4,000 Harvesting |
| Build wall segments | ~10s | ~12,000 Engineering |
| Dismantle basic robots (night) | ~30s | ~4,000 Engineering |
| Haul 50m loads | ~10s travel | ~1,500 Harvesting |

At ~4,000 XP/day: level 10 in ~2 days, level 50 in ~30 days, level 128 in ~200 days.

Intent: specialties emerge in the first few days, dual-specialties are mid-game, white-clad veterans are late-game.
