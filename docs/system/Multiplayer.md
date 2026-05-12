# System: Multiplayer

## Purpose
The Solar Siege supports up to 4 cooperative players. One player hosts a server; others join as clients. All players share the same game state, Job Board, and colony. Any player can possess any worker and issue any command.

---

## Architecture

**Transport:** ENet
**Max players:** 4
**Port:** 7000 (default)
**Mode:** Dedicated host (one player runs the server); no dedicated server binary planned for MVP

---

## Connection

```gdscript
# MultiplayerManager (autoload)

const PORT = 7000
const MAX_PLAYERS = 4

func create_game():
    var peer = ENetMultiplayerPeer.new()
    peer.create_server(PORT, MAX_PLAYERS)
    multiplayer.multiplayer_peer = peer

func join_game(address: String = "127.0.0.1"):
    var peer = ENetMultiplayerPeer.new()
    peer.create_client(address, PORT)
    multiplayer.multiplayer_peer = peer
```

Player IDs are assigned by Godot's multiplayer system. Host is always peer ID 1.

---

## What Gets Synchronized

Every networked object requires a `MultiplayerSynchronizer` node. The following must be synced:

| Node | Synced Properties |
|---|---|
| Worker | `global_position`, `current_job`, `xp`, `specialty`, `is_possessed`, `possessing_player` |
| Robot | `global_position`, `health`, `scrap`, `is_frozen` |
| SolarCycle | `current_time`, `current_phase` |
| JobBoard | `available_jobs` |
| PossessionManager | `possessed` dictionary |
| FoodManager | `food_points`, `nutrition_state` |
| Hub / ResourceBuffer | `current` (resource amounts) |
| ResourcePile | `global_position`, `contents`, `is_being_hauled` |

---

## Authority Model

- **Server (host) is authoritative** for all game state
- Clients send input and intent; server validates and applies
- `@rpc` calls used for player actions (possess, force task, place track, etc.)

```gdscript
# Example: player initiates possession
@rpc("any_peer", "call_local", "reliable")
func request_possess(unit_path: NodePath):
    if not multiplayer.is_server():
        return
    var unit = get_node(unit_path)
    var player_id = multiplayer.get_remote_sender_id()
    PossessionManager.possess(player_id, unit)
```

---

## Shared Access

All players share:
- The Job Board (any player can post, assign, or force-task)
- The possession system (any player can possess any available worker)
- The RTS camera (each player has their own camera, independently positioned)

No player has exclusive ownership of workers or structures. Coordination is a social contract, not an enforced mechanic.

---

## Player Cameras

Each player maintains their own `RTSCamera` instance. Camera positions are local — not synced. When a player possesses a worker, their camera switches to the worker's 1st-person camera. On unpossess, it returns to their personal RTS camera at its last position.

---

## Dependencies

- All major game nodes — require `MultiplayerSynchronizer`
- `PossessionManager` — synced; `possess` / `unpossess` called via RPC
- `JobBoard` — synced; job mutations via RPC from any client
- `InputManager` (planned) — handles per-player controller mapping
