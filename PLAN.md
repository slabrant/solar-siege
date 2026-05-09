# Project Plan: The Solar Siege
**Engine:** Godot 4.6.2  
**Genre:** Logistics-Defense / Strategy Hybrid  
**Style:** 3D Top-Down Strategy with 1st Person Possession

---

## 1. Executive Summary

The Solar Siege is a cooperative logistics-defense game built around a workforce of named, specialized workers who build and maintain an automated factory-fortress. The game features a unique day/night cycle where solar-powered robots attack during the day and freeze into inoperable states at night — creating a structured loop of defense, expansion, and resource harvesting.

---

## 2. Core Gameplay Pillars

- **The Solar Tide:** Robot strength is dictated by a sine wave relative to the sun's angle ($S = S_{max} \cdot \sin(\theta)$). Robots reach peak power at Noon, weaken toward Dusk, and freeze into inoperable states at Night.
- **Logistics Persistence:** All defensive structures (Towers/Hubs) have internal resource buffers. These must be replenished via conveyor belts or manual worker labor to prevent the structure from shutting down.
- **Smart Task Logic:** AI workers utilize a Global Job Board to prioritize tasks. Workers automatically re-assign themselves to the highest-priority task they can perform — based on their skill level — unless "Force Tasked" by the player.
- **Hero Underlings:** Workers are persistent individuals with names and skills that improve through labor. All workers can perform all tasks; skill level determines speed and yield, not access.
- **Asymmetric Cooperation:** Players can swap between a strategic top-down view and 1st-person possession. Possession allows players to take direct control of a unit or turret to handle "clutch" moments.

---

## 3. The Three Ages of Progression

- **Age of Manual Labor:** Early game focused on a high worker population. Workers perform all harvesting, building, and carrying by hand to construct the first Hubs and basic turrets.
- **Age of Automation:** Introduction of the "Belt Revolution." Players build automated drills and conveyor belts to handle resource gathering and transport, transitioning workers into maintenance, construction, and combat roles.
- **Age of Industry:** Late game characterized by massive automated fortresses. Advanced assemblers process Robot Scrap and Solite to unlock high-tier technology, while veteran workers oversee elite systems and advanced weaponry.

---

## 4. Worker Fields & Skills

Workers have three fields of expertise. All workers can perform any task, but their skill level in the relevant field determines how fast they work and — in the case of harvesting — how much they yield. A worker's highest field is their specialty title. If two fields are both significantly elevated relative to that worker's other skills, both are combined into their specialty title (e.g., *"Gunner-Engineer"*).

### Fields

- **Engineering** — Building structures, repairing damage, expanding walls and Hubs, and dismantling robots for resources. Higher Engineering skill increases build/repair speed, dismantling speed, and resource yield from robots (including Solite).
  - *Late-game sub-specialties:* Construction, Mechanics.

- **Gunnery** — Operating turrets, manual fire during possession, and gunning down robots. Higher Gunnery skill increases fire rate and accuracy.
  - *Late-game sub-specialties:* TBD.

- **Harvesting** — Pre-belt resource gathering (mining, chopping, farming) and hauling robot husks after Solite extraction. Higher Harvesting skill increases gathering and hauling speed.
  - *Late-game sub-specialties:* Miner, Lumberjack, Hauler.

### Worker Identity

- **Recruits** have no name and no specialty. As they gain XP, they develop a name, a specialty title, and occupation-specific visuals.
- **Dual-specialty** is displayed when two fields are both significantly elevated relative to that worker's remaining skills.
- **The Well-Fed Bonus:** Hubs track their food buffer fill level. When food exceeds a threshold, all workers operating from that Hub gain increased speed and XP gain. Farming falls under Harvesting.

### Sub-Field Abilities *(stub — see Future section)*

Workers will have minor abilities and traits that don't rise to the level of a full field. These allow for further personalization without changing the three-field structure. To be expanded later.

---

## 5. The Robot Economy & Night Loop

### Daytime Combat

Robots use NavigationAgent3D pathfinding to target Hubs. Their movement speed and combat strength scale with solar strength via the sine wave formula. At peak Noon, robots are at maximum power.

### Robot States & Resource Harvesting

Robots exist in one of three states:

- **Functional** — Active during the day, attacking Hubs.
- **Inoperable** — Frozen at Night, or disabled by damage. Still contains all resources. Damaging a robot linearly reduces all resource yields, including Solite. Any worker can harvest an inoperable robot; Engineers yield more based on their skill level.
- **Husk** — A robot from which the Solite power source has been extracted. Contains remaining scrap but no Solite.

### Solite

Solite is a glowing purple power source found only inside robots. It cannot be mined or farmed. It is the primary driver of high-tier technology and is obtained exclusively through the night harvesting loop.

- **Dismantling:** Extracting Solite is an Engineering task. Higher Engineering skill increases dismantling speed and resource yield. A fully intact inoperable robot yields the maximum amount.
- **Gunfire yield:** Shooting a robot down leaves it inoperable with linearly reduced yields across all materials — including Solite. Faster, but wasteful.
- **Husk hauling:** After Solite is extracted, Harvesters haul husks back to Hubs for scrap processing.

---

## 6. Technical Roadmap

### Phase 1: Foundation (The Brains)

- **Multiplayer Framework:** Establish server/client architecture using MultiplayerSynchronizer in Godot 4.6.2.
- **Directive AI Engine:**
  - Implement the Global Job Board for priority and proximity ranking.
  - Workers automatically re-assign to the highest-priority available task when the Job Board updates.
  - Implement "Force Task" manual overrides to lock workers to a specific job.
- **Worker Skill System:**
  - Track XP per field (Engineering, Gunnery, Harvesting).
  - Derive specialty title from highest field, or dual-specialty when two fields are both significantly elevated relative to the worker's other skills.

### Phase 2: Solar Environment & Combat

- **Solar Cycle Singleton:** A global autoloaded script tracking sun position and emitting phase/hour signals. Triggers Robot freeze/thaw states.
- **Robot AI:** NavigationAgent3D pathfinding targeting Hubs, with speed and strength modifiers driven by `get_solar_strength()`.
- **Robot State Machine:** Functional → Inoperable → Husk. Resource yield tracked per robot instance and degraded linearly by damage taken.
- **The Possession System:** Camera switching and input remapping for 1st-person unit control. Escape exits possession.

### Phase 3: Logistics & Production

- **Belt System:** MultiMeshInstance3D for high-performance rendering of items on conveyor paths. Belt-to-belt and belt-to-buffer handoff logic.
- **Buffer & Decay Logic:** Turrets consume Ammo per shot. Hubs consume Food over time and track Well-Fed status.
- **Solite Economy:** Engineering-skill-scaled dismantling of inoperable robots. Solite feeds the high-tier tech tree exclusively.

---

## 7. Control & Possession

- **Shared Strategic Control:** Both players have full access to the Job Board and strategy tools.
- **Possession Synergies:** When a player possesses a turret, the assigned worker's Gunnery skill provides passive fire rate and accuracy bonuses even under player control.
- **Unit Lock-out:** Possessed units are highlighted. The other player cannot possess the same unit simultaneously.

---

## 8. Future / Long-Term Ideas

- **Sub-Field Abilities:** Workers develop minor traits and abilities within their fields that don't constitute a full specialty. To be designed separately.
- **Branching Skill Tree:** As workers advance, they commit to late-game sub-specialties (e.g., a Harvester becoming a Lumberjack or Hauler). The structure and unlock conditions are to be designed.
- **Planet Progression:** The game map is flat but implied to wrap on a planet surface — large enough that curvature is not visible. Once a planet is sufficiently conquered, players can establish a foothold and advance to a new, harder planet. The original planet persists as a passive base. Technical implications for the possession system on a multi-map setup are a known open question.