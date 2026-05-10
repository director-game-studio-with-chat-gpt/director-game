# Architecture — module ownership and public interfaces

This document defines **who owns what** and **what interfaces each module exposes** to others.

If you are a Devin session: find your module below. **You only edit files in your module's folder.** If you need something from another module, look at its public interface below — if it doesn't exist, open an Issue or PR comment requesting it.

---

## Module ownership

| # | Module | Folder | Devin session(s) | Owner of |
|---|---|---|---|---|
| 1 | **Engine / core** | `src/core/` | Devin-1 | Game state, scene loader, autoloads, singletons |
| 2 | **Network / Steam** | `src/network/` | Devin-2 | Multiplayer, Steam integration, RPCs |
| 3 | **Director controller** | `src/director/` | Devin-3 | Top-down camera, ability bar, mana system |
| 4 | **Director: walls + doors** | `src/director/walls/` `src/director/doors/` | Devin-4 | Move-wall, swap-door, create-door logic |
| 5 | **Director: lights + items** | `src/director/lights/` `src/director/items/` | Devin-5 | Toggle lights, swap items |
| 6 | **Player controller** | `src/player/` | Devin-6 | First-person controller, stamina, flashlight |
| 7 | **Player classes** | `src/player/classes/` | Devin-7 | Scout, Locksmith, Medic, Listener — abilities + tools |
| 8 | **Monster: Worm + Mirror** | `src/monsters/worm/` `src/monsters/mirror/` | Devin-8 | Two monster types |
| 9 | **Monster: Swarm + Tongue** | `src/monsters/swarm/` `src/monsters/tongue/` | Devin-9 | Two monster types |
| 10 | **World: rooms + house** | `src/world/` | Devin-10 | Room, wall, door, item nodes; map loader |
| 11 | **Shaders + visual style** | `src/shaders/` | Devin-11 | Cel-shading, outline, fog, post-process |
| 12 | **UI: lobby + menus** | `src/ui/lobby/` `src/ui/menu/` | Devin-12 | Main menu, lobby browser, settings |
| 13 | **UI: HUD + in-game** | `src/ui/hud/` | Devin-13 | Director HUD (top-down + abilities), Escapist HUD |
| 14 | **Audio + proximity chat** | `src/audio/` | Devin-14 | Music, SFX, Steam Voice |

**Plus:** `src/assets/` is shared (anyone can add models/textures with attribution in `src/assets/SOURCES.md`)

---

## Public interfaces

Each module exposes a small set of **public functions/signals** through a singleton-like API. Below is the contract — modules MUST follow this. If you change a public interface, you MUST update this doc in the same PR.

### `Core` (Devin-1)

**Autoload:** `GameState` (singleton, registered in `project.godot`)

```gdscript
# Globals
GameState.role: String          # "director" or "escapist"
GameState.player_id: int        # Steam ID or local ID
GameState.match_phase: String   # "lobby", "playing", "ending"
GameState.mana: int             # Director's mana, 0–200

# Signals
GameState.match_started        # emitted when round starts
GameState.match_ended(winner)  # winner = "director" or "escapists"
GameState.role_assigned(role)  # role = "director" or "escapist"
```

### `Network` (Devin-2)

**Autoload:** `Net`

```gdscript
Net.host_match() -> int                  # returns lobby_id, you are the Director (host)
Net.join_match(lobby_id: int) -> bool    # returns true on success, you become an Escapist
Net.leave_match() -> void
Net.send_rpc(method: String, args: Array) -> void  # broadcast to all peers
Net.send_to_director(method: String, args: Array) -> void

# Signals
Net.peer_joined(peer_id: int)
Net.peer_left(peer_id: int)
```

### `Director` (Devin-3, 4, 5)

**Autoload:** `Director`

```gdscript
Director.try_use_ability(ability_name: String, target_data: Dictionary) -> bool
Director.get_remaining_mana() -> int
Director.get_cooldown(ability_name: String) -> float

# Signals
Director.ability_used(ability_name: String)
Director.mana_changed(new_mana: int)
```

### `Player` (Devin-6, 7)

Each player is a `Node3D` with attached scripts.

```gdscript
# Attached to Escapist root
escapist.health: int
escapist.class_name: String       # "scout", "locksmith", "medic", "listener"
escapist.use_class_ability() -> void
escapist.pick_up_item(item: Item) -> void
escapist.drop_item(slot: int) -> void

# Signal
escapist.died(by_monster: String)
```

### `Monster` (Devin-8, 9)

Each monster is a `Node3D`. They expose a common interface:

```gdscript
class_name Monster
var hp: int
var monster_type: String       # "worm", "mirror", "swarm", "tongue"
func spawn(at_position: Vector3) -> void
func receive_command(command: String, data: Dictionary) -> void
func take_damage(amount: int, source: Node) -> void

# Signals
killed(by: Node)
artifact_stolen(artifact: Item)   # only emitted by Worm
```

### `World` (Devin-10)

**Autoload:** `World`

```gdscript
World.get_room_at(position: Vector3) -> Room
World.get_door(door_id: String) -> Door
World.move_wall(wall_id: String, new_transform: Transform3D, duration: float) -> void
World.swap_doors(door_a_id: String, door_b_id: String) -> void
World.create_door(wall_id: String, position: Vector3, leads_to_room_id: String) -> Door

# Signals
World.wall_moved(wall_id: String)
World.door_created(door_id: String)
```

### `UI` (Devin-12, 13)

UI modules connect to signals from other modules. They expose only their own scenes, not functions.

### `Audio` (Devin-14)

**Autoload:** `Audio`

```gdscript
Audio.play_sfx(name: String, position: Vector3) -> void
Audio.play_music(track: String) -> void
Audio.set_proximity_chat_active(enabled: bool) -> void
```

---

## Message bus

For events that span modules, use the `EventBus` autoload (in `src/core/event_bus.gd`):

```gdscript
EventBus.emit("artifact_picked_up", {"artifact_id": "skull", "by_player": 12345})
EventBus.connect("artifact_picked_up", _on_artifact_picked_up)
```

This avoids tight coupling between modules.

---

## Branch / PR conventions

- Each Devin works on `<devin-name>/issue-<N>-<short>`
- PRs target `dev` branch
- After review and merge to `dev`, project lead merges `dev` → `main` periodically (~ once a sprint)

---

## Adding a new public interface

If your module needs to expose a new public function/signal:
1. Add it to your module's section above (in the SAME PR that introduces it)
2. Mention "**ADDED PUBLIC INTERFACE**" in the PR description
3. Project lead reviews and merges
