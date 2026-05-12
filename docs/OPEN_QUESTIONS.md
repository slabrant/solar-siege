# The Solar Siege — Open Questions

Implementation questions that need a decision before or during development. Organized by system. These are not shelved features — see FUTURE.md for those.

---

## Worker

- **Name generation** — Wordlist-based, procedural, or hand-authored? What's the pool size?
- **Color application** — How is the clothing color applied to the mesh? Shader parameter, material override, or vertex color?
- **SPEED_SCALE constant** — Needs balancing against BASE_XP_PER_LEVEL. +2% per level is a placeholder.
- **DUAL_SPECIALTY_THRESHOLD** — Exact ratio needs playtesting. Currently undefined.
- **Haul capacity** — How much can a worker carry at once? Fixed or upgradeable?

---

## Balance

- **BASE_XP_PER_LEVEL** — 100 is a placeholder. Total XP to max level (~836k) may need significant adjustment once action times are known.
- **HAUL_XP_PER_METER** — Needs calibration against typical map distances once map size is known.
- **Action times per object** — How long does it take to chop a tree, mine ore, harvest a crop? Depends on base worker speed and SPEED_SCALE.
- **BASE_XP_PER_LEVEL per field** — Should Engineering, Gunnery, and Harvesting have the same XP curve, or should natural action volume differences be accounted for?
- **Solite yield range** — Min and max Solite per batch of scrap processed. Needs balancing.
- **Well-Fed thresholds** — BASE_WELL_FED and BASE_HUNGRY constants need tuning against food production rates.
- **Food consumption rate** — How fast does the colony consume food per worker per second?

---

## Job Board

- **MIN_FIELD_LEVEL** — Minimum level a worker needs in a field for the Job Board to consider them qualified for jobs requiring that field. Soft routing preference, not a hard lock.

---

## Robot

- **GameState autoload** — Needs to be created. Owns `robots_awakened` flag and other global game state.
- **Scrap Processor** — Same building as Shiny Scrap Processor with a different mode, or a separate building?
- **Iridium processor** — Does Iridium require a separate late-game building?
- **Processed output queuing** — Do processed outputs queue in the building until hauled, or auto-deliver to the nearest Hub?

---

## Food

- **Food consumption rate** — Exact rate of food points consumed per worker per second.
- **BASE_WELL_FED / BASE_HUNGRY** — Scaling constants against workforce size.

---

## Transport

- **Track grid resolution** — What is the snapping grid for railroad track placement?
- **Track branching** — How are track branches handled in pathfinding?

---

## Hub

- **Structure range** — At what distance can a structure draw from a Hub buffer?
- **Hub build cost** — How much material is required to build a new Hub?
- **Population cap** — Whether there should be a maximum worker count colony-wide, and if so what determines it (food capacity, Hub count, fixed value).

---

## Possession

- **Input remapping** — How is controller input remapped per player for up to 4 simultaneous players in Godot 4?

---

## Solar Cycle

- **Day/night duration** — Is the 600-second cycle configurable per session, per map, or fixed?
- **Sun visual** — Should the DirectionalLight3D rotation be tied to `current_time` for a visible sun arc?
- **Time speed modifier** — Should players be able to speed up time during low-threat periods?

---

## Multiplayer

- **MultiplayerSynchronizer setup** — Needs implementing on all major nodes (Worker, Robot, SolarCycle, JobBoard, PossessionManager, FoodManager, Hub/ResourceBuffer, ScrapPile).
- **RPC authority model** — All game state mutations should be server-authoritative. Client RPC calls need validation.
