# Balance Reference

All tunable constants for the game. Single source of truth. Referenced by name from system docs.

A `Balance.gd` autoload could be derived directly from this file.

**What belongs here:** values that apply game-wide and have no per-instance variation — there is one kind of Colonist, one Solar Cycle, one possession bonus, one Well-Fed XP multiplier. Anything where the design says "this number is the same everywhere" lives here.

**What stays as `@export`:** values that vary per-instance — different robot types have different health and damage; different animals have different food yields; different recipes have different inputs and outputs; different tower tiers have different fire rates. These are configured on each scene/resource, not centrally.

---

```gdscript
# Balance.gd

# --- XP & Progression ---
const XP_PER_HEALTH: float            = 1.0     # XP per health point processed, all fields
const HAUL_XP_PER_METER: float        = 0.5     # Harvesting XP per meter hauled
const BASE_XP_PER_LEVEL: float        = 100.0   # XP for level n = BASE_XP_PER_LEVEL * n
const MAX_LEVEL: int                   = 128     # per field; also color channel range

# --- Color ---
const BASE_COLOR_CHANNEL: int         = 127     # starting gray; max channel = 127 + MAX_LEVEL

# --- Speed & Bonuses ---
const SPEED_SCALE: float              = 0.02    # +2% task speed per level
const POSSESSION_BONUS: float         = 1.5     # multiplier on all task speeds while possessed
const HAUL_CAPACITY_BASE: float       = 50.0    # base haul capacity in resource units
const HAUL_CAPACITY_PER_LEVEL: float  = 1.0     # Harvesting level adds to capacity

# --- Dual Specialty ---
const DUAL_SPECIALTY_THRESHOLD: float = 0.0     # ratio; needs playtesting

# --- Well-Fed ---
const WELL_FED_SPEED_BONUS: float     = 1.25
const WELL_FED_XP_BONUS: float        = 1.50
const BASE_WELL_FED: float            = 50.0    # points per colonist for Well-Fed threshold
const BASE_HUNGRY: float              = 10.0    # points per colonist for Hungry threshold
const FOOD_CONSUMPTION_RATE: float    = 0.1     # food consumed per colonist per second

# --- Colonist ---
const COLONIST_BASE_SPEED: float      = 5.0
const COLONIST_MAX_HEALTH: float      = 100.0

# --- Solar Cycle ---
const DAY_DURATION: float             = 600.0   # real seconds per full 24-hour cycle
const START_TIME: float               = 6.0     # game starts at 6 AM

# --- Robot Waves ---
const HEAVY_ROBOT_UNLOCK_DAY: int     = 10     # in-game day when heavy robots can start appearing
const WAVE_BASE_INTERVAL: float       = 300.0  # seconds between waves at game start
const WAVE_ESCALATION_RATE: float     = 0.95   # multiplier applied to interval each wave (shorter over time)

# --- Animals ---
const ANIMAL_SPAWN_INTERVAL: float    = 60.0   # seconds between animal spawns
const ANIMAL_MAX_COUNT: int           = 20     # max animals on map at once
const ANIMAL_ATTRACTION_STRENGTH: float = 0.5  # 0=fully random wander, 1=beeline to tower

# --- Hub Spawning ---
const COLONIST_FOOD_COST: float       = 25.0    # food cost to queue a new colonist
const SPAWN_DURATION: float           = 30.0    # seconds to produce one colonist

# --- Job Board ---
const RANGE_CUTOFF_DEFAULT: float     = 200.0   # default per-colonist range limit; configurable in UI
const QUAL_PREEMPT_LEVEL_GAP: int     = 20      # level gap required for a qualified colonist to preempt
```

---

## Object Health Values

Health doubles as XP yield — a 200hp tree gives 200 Harvesting XP.

### Natural Resources

XP is awarded as Harvesting for all natural resources.

| Object              | Health |
|---------------------|--------|
| Small tree          | 100    |
| Large tree          | 300    |
| Ore deposit (small) | 150    |
| Ore deposit (large) | 500    |
| Stone deposit       | 200    |
| Basic crop          | 20     |
| Premium crop        | 100    |
| Foraged item        | 10     |

### Animals

XP is awarded as Gunnery (the tower operator gets credit). See SYSTEMS/Animals.md for behavior.

| Animal | Health | Food Yield |
|--------|--------|------------|
| Bunny  | 60     | 30         |
| Turkey | 120    | 80         |
| Deer   | 240    | 200        |

### Robots

| Robot Type  | Health | Base Scrap | Notes                       |
|-------------|--------|------------|-----------------------------|
| Basic robot | 200    | 200        | Early game                  |
| Heavy robot | 600    | 600        | Late game; drops ShinyScrap |

### Colonist

| Object   | Health |
|----------|--------|
| Colonist | 100    |

### Structures

Building and repairing awards Engineering XP equal to health restored.

| Structure           | Health |
|---------------------|--------|
| Wall segment I      | 200    |
| Wall segment II     | 400    |
| Wall segment III    | 600    |
| Tower               | 400    |
| Hunting tower       | 300    |
| Processing building | 800    |
| Production building | 1000   |
| Hub                 | 3000   |
| Rail track segment  | 50     |
| Conveyor segment    | 120    |

---

## Pacing Sanity Check

Full day cycle: 600 real seconds. Day and night are each 300 seconds.

| Action                         | Time Per Action | XP Per Day (est.)     |
|--------------------------------|-----------------|-----------------------|
| Chop small trees               | ~15s            | ~4,000 Harvesting     |
| Mine ore (small)               | ~20s            | ~4,500 Harvesting     |
| Harvest basic crops            | ~3s             | ~4,000 Harvesting     |
| Build wall segments            | ~10s            | ~12,000 Engineering   |
| Dismantle basic robots (night) | ~30s            | ~4,000 Engineering    |
| Haul 50m loads                 | ~10s travel     | ~1,500 Harvesting     |

At ~4,000 XP/day: level 10 in ~2 days, level 50 in ~30 days, level 128 in ~200 days.

Specialties emerge in the first few days. Dual-specialties are mid-game. White-clad veterans are late-game.
