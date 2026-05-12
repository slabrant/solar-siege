# The Solar Siege — Future & Long-Term Ideas

Everything here is explicitly out of scope for the MVP. Items are organized by system. Nothing in this document is designed — these are seeds for later.

---

## Worker

- **Sub-Field Abilities** — Minor traits and abilities within a field that don't constitute a full specialty. A layer of personalization beyond the three-field structure.
- **Branching Skill Tree** — Sub-specialties deepen as workers level up. Structure and unlock conditions TBD.
- **Skill Gates** — High-tier objects (rare crops, heavy robots, advanced structures) requiring a minimum skill level to interact with.
- **Sub-specialty unlock logic** — How and when workers commit to a sub-specialty (Miner, Lumberjack, Marksman, etc.).

---

## Job Board

- **CRITICAL priority force-override** — Whether CRITICAL priority jobs should hard-override force-tasked workers.
- **Job Board UI** — How the board is represented visually for players.

---

## Robot

- **Wave spawning system** — Timing, escalation, spawn points, and difficulty scaling.
- **Hauling live robots** — Implementation details for dragging a functional robot back to base.
- **Frozen robot visuals** — Visual state indicator for frozen robots.
- **Heavy robot introduction** — When heavy robots appear and their drop rate tuning.
- **Robot aggro behavior** — Whether robots have a detection/aggro range or always target the nearest Hub.
- **The Awakening** — The triggering event that activates robots is not finalized. Leading concept: colonists enter an ancient structure, activating all robots simultaneously. The origin of the robots is a mystery revealed gradually.
- **Covered structures / robot shade** — Robots aware of whether they're beneath a structure (bridge, overhang). If shaded from the sun, solar strength drops — robots could freeze mid-day under sufficient cover. Turns the solar mechanic into an architectural tool.
- **Rover power extension** — Late-game robot countermeasure. Rovers with solar panels follow robots via a tether, allowing them to operate under covered structures. Counter to shade-based defenses.

---

## Food

- **Food variety system** — A wider variety of foods raises the food level beyond quantity alone. A food quality multiplier on top of raw food points.
- **Hunting tower consumables** — What hunting towers consume (traps, bait, ammo) is not yet designed.
- **Animal behavior** — Animal spawn rates, pathing, and attraction to hunting towers.
- **Food spoilage** — Whether food decays if the pool overflows a cap.

---

## Transport

- **Railcar routing** — Whether railcar routes are one-way or bidirectional.
- **Belt-to-belt connection** — Auto-snap on placement, or manual linking?
- **Maximum belt segment length** — Whether there is a cap.
- **Railcar operator** — Whether railcars require a worker operator or are fully autonomous.

---

## Hub

- **Hub capacity upgrades** — Whether Hub buffer capacity can be upgraded.
- **Home Hub assignment** — Workers assigned to a specific Hub, enabling per-Hub recall, per-Hub population caps, and granular colony management.

---

## Recall

- **Per-Hub recall** — Requires home Hub assignment. Pull back frontier workers independently of base workers.
- **Auto-recall** — Optional setting to automatically recall all workers at a configurable time before dawn.
- **Recall bell visual/audio** — A world-space cue so all players know the recall fired.

---

## Possession

- **Possession initiation UI** — How possession is triggered (click worker, radial menu, etc.).
- **Possession cooldown** — Whether there is a cooldown after a possessed worker dies.
- **Visual differentiation** — How possessed workers are highlighted per player color (shader outline, overhead marker, etc.).

---

## Multiplayer

- **Online play** — LAN-only for MVP. Online requires relay/STUN server — not yet scoped.
- **Lobby & matchmaking** — Whether a lobby UI is in scope beyond MVP.
- **Player disconnection** — How mid-session disconnection is handled (pause, AI takeover, workers go autonomous).
- **Host migration** — Whether the host role can transfer if the host drops.
- **Split-screen** — Not planned; separate machines only for now.

---

## World

- **Weather system** — Cloudy days reduce solar strength, weakening robots below their normal sine-curve peak. Natural variance in the threat cycle.
- **World progression** — Colonizing the full planet is the stated goal. What comes after — additional planets, harder worlds — is an open question.
- **The map** — Size, layout, biomes, and resource distribution are not yet designed.

---

## Narrative

- **The Awakening** — Triggering event narrative and environmental storytelling. How the mystery of the robots is revealed to players over time.
