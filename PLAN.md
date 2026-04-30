# Project Plan: The Solar Siege
**Engine:** Godot 4.6.2  
**Genre:** Logistics-Defense / Strategy Hybrid  
**Style:** 3D Top-Down Strategy with 1st Person Possession

---

## 1. Executive Summary
The Solar Siege is a cooperative logistics-defense game focusing on a workforce of named, specialized workers who build and maintain an automated factory-fortress. The game features a unique day/night cycle where solar-powered robots attack during the day and freeze at night, allowing for a structured loop of defense and expansion.

---

## 2. Core Gameplay Pillars
* **The Solar Tide:** Robot strength is dictated by a sine wave relative to the sun's angle ($S = S_{max} \cdot \sin(\theta)$). Robots reach peak power at Noon, retreat at Dusk, and freeze into "Scrap Statues" at Night.
* **Logistics Persistence:** All defensive structures (Towers/Hubs) have internal resource buffers. These must be replenished via conveyor belts or manual worker labor to prevent the structure from shutting down.
* **Smart Task Logic:** AI workers utilize a Global Job Board to prioritize tasks. Workers automatically re-assign themselves to the highest-priority task they are qualified for unless "Force Tasked" by the player.
* **Hero Underlings:** Workers are persistent individuals with names and skills that improve through labor.
* **Asymmetric Cooperation:** Players can swap between a strategic top-down view and 1st-person possession. Possession allows players to take direct control of a unit or turret to handle "clutch" moments.

---

## 3. The Three Ages of Progression
* **Age of Manual Labor:** Early game focused on high worker population. Workers perform all mining, chopping, and carrying by hand to build the first Hubs and basic turrets.
* **Age of Automation:** Introduction of the "Belt Revolution." Players build automated drills and conveyor belts to handle mining and transport, transitioning workers into maintenance and construction roles.
* **Age of Industry:** Late game characterized by massive automated fortresses. Advanced assemblers process "Robot Scrap" to unlock high-tier technology, while a few legendary workers oversee elite systems and advanced weaponry.

---

## 4. Technical Roadmap

### Phase 1: Foundation (The Brains)
* **Multiplayer Framework:** Establish server/client architecture using MultiplayerSynchronizer in Godot 4.6.2.
* **Directive AI Engine:**
    * Implement the Global Job Board for category ranking.
    * Create logic for automatic re-assignment: John drops an axe for a hammer if a building task appears and he is the most qualified.
    * Implement "Force Task" manual overrides to lock workers to a specific job.

### Phase 2: Solar Environment & Combat
* **Solar Cycle Singleton:** A global script tracking sun position and triggering Robot "Freeze/Thaw" states.
* **Robot AI:** Pathfinding logic using NavigationAgent3D targeting Hubs, with strength modifiers based on time of day.
* **The Possession System:** Implement camera switching and input remapping for 1st-person unit control.

### Phase 3: Logistics & Production
* **Belt System:** Utilize MultiMeshInstance3D for high-performance rendering of items on conveyor paths.
* **Buffer & Decay Logic:** Script towers to consume ammo per shot and Hubs to consume food for "Well-Fed" buffs.
* **Scrap Economy:** Logic for workers to harvest fallen robots during the night to fuel the high-tier tech tree.

---

## 5. Worker Mechanics & Identity
* **Naming and Visuals:** Recruits remain nameless and wear basic tunics. Veteran workers (e.g., John) display persistent name tags and occupation-specific outfits like yellow builder vests.
* **Skill Tracking:** Workers gain XP in fields like Forestry, Construction, Gunnery, and Logistics.
* **Dual-Specialty:** High-level workers can maintain multiple specialties, such as being a Master Builder at night and a Master Gunner during the day.
* **Nutrition:** The "Well-Fed" bonus incentivizes excess food production by granting workers increased speed and XP gain.

---

## 6. Control and Possession
* **Shared Strategic Control:** Both players have access to the Job Board and strategy tools.
* **Possession Synergies:** When a player possesses a turret, the worker's Gunnery skill still provides passive fire rate or accuracy buffs.
* **Unit Lock-out:** Possessed units are highlighted to prevent the other player from attempting to possess the same unit simultaneously.