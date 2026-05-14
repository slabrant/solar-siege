# Solar Siege — Game Design Document

**Engine:** Godot 4.6.2
**Genre:** Cooperative Tower Defense / Automation Strategy
**Perspective:** 3D Top-Down with 1st Person Possession

---

## What Is This Game?

A cooperative tower defense game that uses automation and possession. A group of colonists lands on an unknown world, plants a flag, names the planet, and starts building. The early game is peaceful: gather, explore, build the first hub. Then something stirs — and robots begin attacking by day and freezing by night.

Players manage the colony from a top-down strategic view, but can drop into any colonist at any time for direct 1st-person control. Every colonist levels up, develops a specialty, and becomes someone worth protecting.

---

## Core Loop

**Daytime:** Robots attack. Towers fire, colonists build and repair.

**Nighttime:** Robots freeze in place. Colonists salvage scrap, expand the colony, and prepare for the next day.

---

## The Solar Tide

Robot strength follows the arc of the sun. They're at peak power at Noon and weakest at the edges of the day. At night they freeze completely — but they're not gone. Frozen robots are full of salvageable material and can be hauled back to be processed.

---

## Colonists

Colonists are the heart of the colony. Every colonist starts nameless and dark gray. As they gain experience, they earn a name and their clothing shifts in color to reflect their growing skills.

All colonists can do all tasks. Skill level determines speed — not access. Colonists have no weapons and cannot fight — combat belongs entirely to towers.

### Colonist Color

A colonist's clothing color is a live readout of their skill level. No stat screen needed — a glance tells you everything.

- **Red channel** — Gunnery level
- **Green channel** — Harvesting level
- **Blue channel** — Engineering level

All colonists start dark gray. As levels increase, their color shifts toward the field they're developing. A pure Gunner turns red. A pure Engineer turns blue. A Gunner-Engineer turns magenta. A colonist who has maxed all three fields turns white — the visual and mechanical cap.

### The Three Fields

**Engineering** — Building, repairing, expanding, dismantling robots.
- *Construction* — walls, structures, Hub expansion
- *Mechanics* — repair, robot dismantling, salvage processing

**Gunnery** — Tower operation. Gunners don't carry weapons; they operate towers. Higher skill makes the tower fire faster and hit harder.
- *Marksman* — combat towers
- *Hunter* — hunting towers

**Harvesting** — Gathering and hauling.
- *Miner* — ore, stone
- *Lumberjack* — wood, trees
- *Farmer* — crops, foraging
- *Hauler* — general transport

A low-level Gunner placed on a strong tower will impede the tower's effectiveness. The tower fires slower and does less damage than a high-skill operator would extract from it, but the Gunner gains experience faster. There's a tradeoff between training and effectiveness.

---

## Food & The Well-Fed Bonus

The colony is always in one of three nutrition states:

- **Hungry** — New colonists cannot be created.
- **Normal** — Standard operation.
- **Well-Fed** — All colonists gain a speed and XP bonus, regardless of where they are on the map.

Food comes from farming, foraging, and hunting. Different foods carry different point values. Food is a single shared pool across the entire colony — colonists don't need to be near a Hub to feel the effect of the bonus.

Food diminishes over time at a rate proportional to colony size.

---

## Hubs

Hubs are the colony's anchor points. Colonists are produced at Hubs, structures draw from Hub buffers, and the colony expands by building new Hubs further out. Food is colony-wide; ammo and materials are stored per Hub.

Hubs can be destroyed by robots. The game continues as long as either Hubs or colonists remain. The colony is lost only when both are gone.

---

## Building & Construction

Construction begins with the player marking a location. The marked location appears on the Job Board as a build job. Once materials are hauled to the site, Engineers can begin work. The structure is complete when work is finished.

Nothing is constructed in mid-air — a job needs both materials and labor at the site.

---

## Robot Salvage

Robots have two separate values: health and scrap. The player only sees the health bar. When a tower damages a robot, both health and scrap go down together. When an Engineer dismantles a robot, only health goes down — scrap is preserved.

This means careful dismantling at night always yields more than gunning a robot down by day.

An Engineer can dismantle an active robot, but the robot fights back proportional to its current solar strength — at noon, this is highly dangerous; at dusk it's marginal; at night it costs nothing. The XP rate is the same regardless. There's no reward for taking the risk — only the option.

A robot collapses into a Resource Pile when its health reaches zero. Piles are hauled back to processing buildings to be broken down into usable materials.

### Materials from Robots

- **Scrap** — Dropped by all robots. Processed into parts, materials, and a variable yield of Solite.
- **Shiny Scrap** — Dropped by late-game robots. Processed into Iridium alongside standard outputs.
- **Solite** — A glowing purple material. Required for advanced production, including conveyor belts.
- **Iridium** — Drives the highest tier of technology.

---

## Resource Piles

When a robot dies, its remaining scrap drops as a Resource Pile. When a Hub is destroyed, its full buffer drops as a pile. When colonists harvest in the field, what they gather goes into a pile rather than a personal inventory — colonists don't carry; they harvest, then haul.

A pile is a physical object that a colonist (or a railcar, or a conveyor belt) can pick up and move.

---

## Production & Manufacturing

Resources don't go directly into buildings — they're processed first. Processing buildings convert raw materials. Production buildings combine processed materials into ammo, components, and building materials. The colony needs a supply chain: gather → haul → process → haul → produce → haul → consume.

Hauling is done by colonists at first. The player can lay railroad track to dramatically reduce haul distances — cheap, no Solite required. Conveyor belts come later: fully automated, Solite-required, end-game.

---

## Hunting Towers

Hunting Towers are placed by the player anywhere on the map — they don't need to be near a Hub. Animals roam the world and pass near hunting towers. An assigned Hunter operates the tower to bring food to the colony. The kill yields food, which a colonist must haul back to a Hub before it joins the colony food pool.

Hunting towers are stocked with Stone — their ammunition. Robots may occasionally target hunting towers but they're not primary targets.

---

## The Job Board

The Job Board is the colony's task management system. Every task — mining, construction, hauling, farming, hunting, dismantling — exists as a job on the board with a priority and a location. Colonists automatically claim the highest-priority job they can reach, weighted by proximity.

Jobs are stored in a priority-ordered list. Most jobs are *normal* priority; players can also flag a job *very_much* — pushing it to the very top. The Recall action uses this flag to ensure colonists drop everything immediately.

A more qualified colonist can take a job away from a less qualified one. The qualified colonist doesn't drop what they're doing for trivial reasons — but on important work, the right colonist gets routed in.

Players can post jobs directly: paint an area to harvest, click a single resource, or mark a location for a structure. A colonist working an area continues until either the resources are gone or they die.

There's an **idle colonist** indicator so players can find anyone not currently engaged.

Each colonist has a configurable **range cutoff** for jobs — adjustable from the Job Board. Colonists won't pick up tasks beyond that range.

---

## Possession

Any player can possess any colonist at any time. In possession mode, the camera shifts to 1st person and the player controls the colonist directly — faster, stronger, and more capable than their AI self.

Combat structures (towers) are controlled by possessing the assigned Gunner. The Gunner's skill applies on top of player input.

A possessed colonist can die. The player returns to the strategic view. The game doesn't end — but losing a veteran is a real loss.

---

## Recall

Any player can sound a colony-wide recall from the strategic view. Every non-possessed colonist drops their current task and paths to their nearest Hub. When the recall is lifted, colonists re-evaluate the Job Board and resume work.

---

## The Three Ages

The Three Ages are a way of thinking about progression, not a hard rule. Nothing is locked. The ages describe a philosophy of play — where the game tends to be at a given moment — not a gate.

**Age of Manual Labor** — Everything is done by hand. Colonists mine, chop, haul, hunt, and build. Getting the first Hub defended and fed is the whole challenge.

**Age of Automation** — Railcars and eventually conveyor belts take over transport. Production buildings come online. Colonists shift into more specialized roles.

**Age of Industry** — Massive automated fortresses. Iridium flows into advanced production. A few legendary colonists oversee systems that would have been unthinkable at the start.
