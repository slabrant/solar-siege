# Solar Siege — Open Questions

Decisions needed before or during development. Not shelved features — see FUTURE.md for those.

Items that are just "what value should X be" belong in Balance.md, not here. This list contains genuine design decisions with no clear answer yet.

---

## Colonist

- **Name generation** — Wordlist, procedural, or hand-authored? Pool size?
- **Color application** — Shader parameter, material override, or vertex color?

---

## Robot

- **Wave spawning** — What triggers a wave? Time of day only, or does colony size/progress also factor in? How does difficulty escalate?
- **Heavy robot introduction** — What determines when heavy robots first appear? Day count, Hub count, or a player-triggered threshold?
- **Aggro behavior** — Do robots target the nearest Hub blindly, or do they have a detection range that can be exploited?
- **Frozen robot visuals** — What does a frozen robot look like? Same model, or a distinct "statue" state?
- **The first robot** — How does the very first robot appear so that a colonist can dismantle it and trigger the awakening?

---

## Job Board

- **`very_much` vs force-task override** — Should `very_much` priority (e.g. Recall) hard-override force-tasked colonists, or remain blocked by them?
- **Job Board UI** — How is the queue represented visually? How does a player see what's pending, who's assigned, and what's urgent?

---

## Food

- **Food spoilage** — Does food decay if the pool overflows a cap? Yes or no.

---

## Animals

- **Wander/attraction balance** — How aggressively are animals drawn to hunting towers? Is wandering random or biome-influenced?
- **Spawn distribution** — Where do animals appear — evenly across the map, near resources, near hunting towers?

---

## Transport

- **Railcar routing** — At a junction, how does a railcar choose which branch? By cargo destination, next-stop logic, or player-specified?
- **Railcar operator** — Are railcars fully autonomous, or does a colonist need to drive?

---

## Hub

- **Population cap** — Is there a maximum colony size? If so, what determines it — food capacity, Hub count, a fixed value?
- **Hub build cost** — How much material is required to build a new Hub?
- **Structure range** — At what distance can a structure draw from a Hub buffer?

---

## Possession

- **Initiation** — How does a player enter possession? Click directly on a colonist, a radial menu, a selection panel?

---

## Multiplayer

- **Player disconnection** — What happens when a player disconnects mid-session? Pause, AI fallback, or workers go autonomous?

---

## World

- **Map type** — Finite bordered map, or infinite looping planet? A finite map is simpler for MVP; a looping map makes the planet feel real but requires more technical work.
- **First-person fog** — If the map loops, fog is essential to hide the seam. If finite, it's atmosphere only. Decision depends on map type above.
- **Map size, layout, biomes, resource distribution** — None of this is designed yet.
- **Landing flag** — Player-designed or randomly generated?
- **Planet name input** — Free text from one player, or proposed and agreed on by all?

---

## General

- **Recall at the Hub** — Do recalled colonists stand outside (current assumption) or go inside? Inside requires interior Hub representation.
- **Active dismantling targeting** — Do DISMANTLING jobs auto-target active robots, or only frozen ones? Can the player flag an active robot for dismantling?
