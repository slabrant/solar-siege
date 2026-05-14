# System: Multiplayer

Solar Siege supports up to 4 cooperative players. ENet transport. One player hosts; others join. All players share the same game state and colony.

---

## Connection

```gdscript
# MultiplayerManager (autoload)

const PORT = 7000
const MAX_PLAYERS = 4

func create_game() -> void:
    var peer = ENetMultiplayerPeer.new()
    peer.create_server(PORT, MAX_PLAYERS)
    multiplayer.multiplayer_peer = peer

func join_game(address: String = "127.0.0.1") -> void:
    var peer = ENetMultiplayerPeer.new()
    peer.create_client(address, PORT)
    multiplayer.multiplayer_peer = peer
```

Player IDs are assigned by Godot. Host is peer ID 1.

LAN-only for MVP. Online play is in FUTURE.md.

---

## Authority Model

Server (host) is authoritative for all game state. Clients send intent via `@rpc`; the server validates and applies.

```gdscript
# Example: client requests possession
@rpc("any_peer", "call_local", "reliable")
func request_possess(unit_path: NodePath) -> void:
    if not multiplayer.is_server():
        return
    var unit = get_node(unit_path)
    var player_id = multiplayer.get_remote_sender_id()
    PossessionManager.possess(player_id, unit)
```

---

## Synchronization

Every networked node requires a `MultiplayerSynchronizer`. The following are synced:

| Node                    | Synced Properties                                                                                  |
|-------------------------|----------------------------------------------------------------------------------------------------|
| Colonist                | `global_position`, `current_job`, `xp`, `levels`, `specialty`, `is_possessed`, `possessing_player` |
| Robot                   | `global_position`, `health`, `scrap`, `is_frozen`                                                  |
| Animal                  | `global_position`, `health`                                                                        |
| Structure (all types)   | `global_position`, `health`, `is_complete`, type-specific state                                    |
| SolarCycle              | `current_time`, `current_phase`                                                                    |
| JobBoard                | `jobs`                                                                                             |
| PossessionManager       | `possessed`                                                                                        |
| FoodManager             | `food_points`, `nutrition_state`                                                                   |
| ResourceBuffer (on Hub) | `amounts`                                                                                          |
| ResourcePile            | `global_position`, `contents`, `is_being_hauled`                                                   |

---

## Shared Access

All players share:

- The Job Board — any player can post, assign, or force-task
- Possession — any player can possess any unpossessed colonist
- Strategic view — each player has their own camera, independently positioned and not synced

Coordination is a social contract.

---

## Cameras

Each player maintains their own `StrategicCamera`. Positions are local. On possession, the player's camera switches to the colonist's 1st-person camera. On exit, it returns to their personal strategic camera at its last position.

---

## Dependencies

- All major game nodes — require `MultiplayerSynchronizer`
- `InputManager` (planned) — per-player controller mapping
