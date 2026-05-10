# The Solar Siege — Game Design Document

**Engine:** Godot 4.6.2
**Genre:** Cooperative Tower Defense / Automation Strategy
**Perspective:** 3D Top-Down with 1st Person Possession

---

## What Is This Game?

A cooperative tower defense game that uses automation and possession. A group of colonizers lands on an unknown world and starts building. As they push further out, something stirs. After a triggering event — entering a structure, crossing a threshold — robots begin activating across the world, attacking during the day and freezing at night.

Both players manage the colony from a top-down strategic view, but can drop into any worker at any time for direct 1st-person control. Every worker levels up, develops a specialty, and becomes someone worth protecting.

---

## The World

The colonizers don't know what they've landed on. The robots are part of the world they're colonizing — but their origin is not presented upfront. The player discovers this gradually. The early game is peaceful: build, gather, explore. The threat emerges from the world itself.

---

## Core Loop

**Daytime:** Robots attack. Turrets fire, workers build and repair. Any worker can be possessed for direct control.

**Nighttime:** Robots freeze in place. Workers salvage scraps, expand the colony, and prepare for the next day.

**The pressure:** Everything runs on resources. Turrets need ammo, workers need food, structures need materials. None of it is free.

---

## The Solar Tide

Robot strength follows the arc of the sun. They're at peak power at Noon and weakest at the edges of the day. At night they freeze completely — but they're not gone. Frozen robots are full of salvageable material and can be hauled back to be processed.

---

## Workers

Workers are the heart of the colony. Every worker starts as a nameless Recruit. As they gain experience, they develop a name, a specialty, and an appearance to match. A veteran worker looks and performs differently from a fresh one, and losing them matters.

All workers can do all tasks. Skill level determines speed — not access.

### The Three Fields

**Engineering** — Building, repairing, expanding, and salvaging robots.
- *Construction* — walls, structures, hub expansion
- *Mechanics* — repair, robot dismantling, salvage processing

**Gunnery** — Turret operation, direct combat, and hunting.
- *Marksman* — precision targeting, single-unit combat
- *Hunter* — food via hunting; doubles as combat capability

**Harvesting** — Gathering resources and hauling.
- *Miner* — ore, stone
- *Lumberjack* — wood, trees
- *Harvester-Farmer* — crops, foraging, gathering

Hauling is a general Harvesting capability, not a sub-specialty. All Harvesters haul.

### Specialty Titles

A worker's highest field is their specialty. If two fields are both significantly elevated relative to everything else, the worker earns a dual title — *Gunner-Engineer*, for example. This is rare and meaningful.

A worker receives their name and appearance when they first earn a specialty. Until then they are a nameless Recruit.

### Sub-Field Abilities

Workers will develop smaller abilities and traits within their fields beyond their sub-specialty. This system is planned but not yet designed — see Future section.

---

## Food & The Well-Fed Bonus

The colony workforce is always in one of three states:

- **Hungry** — Workers cannot be produced. Population growth halts.
- **Normal** — Standard operation.
- **Well-Fed** — All workers gain increased speed and XP, regardless of where they are on the map.

The Well-Fed threshold scales with total workforce size. Food comes from farming (Harvester-Farmers), foraging (Harvesters), and hunting (Gunners/Hunters). Different foods carry different food point values. Food stores are shared across all Hubs. Workers don't need to return to a Hub to receive the bonus — it applies colony-wide.

---

## Hubs

Hubs are the anchor points of the colony. Workers spawn from Hubs but are free to roam anywhere on the map. Hubs share a common pool for food. Ammo and materials are stored locally per Hub. The colony expands by building new Hubs further out.

---

## Robot Salvage

Robots have two separate values: health and scrap. The player only sees the health bar. When turrets or workers damage a robot, both health and scrap go down together. When Engineers dismantle a frozen robot, only health goes down — scrap is preserved. This means careful dismantling at night always yields more than gunning a robot down during the day.

A robot collapses into scrap when its health reaches zero. Scrap is hauled back to a processing building to be broken down into usable materials, including Solite.

Robots can be hauled back while still functional — but a live robot inside the base will attack. That's a risk the player chooses to take.

### Materials from Robots

**Scrap** — All robots drop scrap when their health reaches zero. Hauled to a processing building where it's broken down into parts, materials, and a variable yield of Solite.

**Shiny Scrap** — Dropped by late-game robots. Processed into Iridium alongside standard outputs.

**Solite** — A glowing purple material extracted from scrap at the processing building. Yield varies per batch. Required for advanced production, including conveyor belts.

**Iridium** — Extracted only from shiny scrap at the processing building. Drives the highest tier of technology.

---

## Production & Manufacturing

Resources don't go directly into buildings — they're processed first. Production buildings convert raw materials into usable parts: ammo, components, building materials. This means the colony needs a supply chain: gather → haul → process → use.

Early-game hauling is done on foot. Railroads are laid directly by the player on the map — workers and railcars then path along them automatically. They're cheap, require no Solite, and dramatically cut haul distances. Conveyor belts come later, require Solite to build, and automate the flow entirely.

---

## The Job Board

The Job Board is the colony's task management system. Every available task — mining, construction, hauling, combat, farming — exists as a job on the board with a priority level and a location. Workers automatically claim the highest-priority job they can reach, weighted by proximity.

Players can override this at any time by Force Tasking a worker to a specific job, locking them to it until released. The board is shared across all players — any of the four can assign or reassign any worker.

When a new job is posted or a job is completed, workers re-evaluate their assignments automatically. A worker mid-task will abandon it for something more urgent unless Force Tasked.

---

## Possession

Either player can possess any worker at any time. In possession mode, the camera shifts to 1st person and the player controls that worker directly — faster, stronger, and more capable than their AI self. Possession gives a direct bonus to the worker's abilities.

Workers don't possess turrets directly. A Gunner operates a turret — possessing the Gunner gives the player direct control of that turret through them.

All of a possessed worker's skills apply passively. A possessed Engineer builds faster. A possessed Gunner shoots better. A possessed Harvester gathers more.

The possessed worker can die. The player returns to the strategic view. The game doesn't end — but losing a veteran worker is a real loss.

Possessed workers are highlighted so the other player knows not to attempt possession of the same unit.

---

## The Three Ages

The Three Ages are a way of thinking about progression, not a hard rule. A player in the middle of the "first age" could build a late-game wall if they had the materials. Nothing is locked. The ages describe a philosophy of play — where the game tends to be at a given moment — not a gate.

**Age of Manual Labor** — Everything is done by hand. Workers mine, chop, haul, hunt, and build. Getting the first Hub defended and fed is the whole challenge.

**Age of Automation** — Railcars and eventually conveyor belts take over transport. Production buildings come online. Workers shift into more specialized roles.

**Age of Industry** — Massive automated fortresses. Iridium flows into advanced production. A few legendary workers oversee systems that would have been unthinkable at the start.

---

## Future / Long-Term

- **Sub-Field Abilities** — Minor worker traits and abilities within their field that don't constitute a full specialty. To be designed.
- **Branching Skill Tree** — Sub-specialties deepen as workers level up. Structure and unlock conditions TBD.
- **Food Variety System** — A wider variety of foods in the colony's food supply raises the food level beyond what quantity alone achieves.
- **World Progression** — Colonizing the full planet is the goal. What comes after is an open question.
- **The Awakening** — The triggering event that starts the robot attacks is not yet finalized. The temple idea — entering a structure that activates all robots simultaneously — is the leading concept.
