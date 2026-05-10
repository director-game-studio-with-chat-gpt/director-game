# Architecture — module ownership and public interfaces

This document defines **who owns what** and **what interfaces each module exposes** to others.

If you are a Devin session: find your module below. **You only edit files in your module's folder.** If you need something from another module, look at its public interface below — if it doesn't exist, open an Issue or PR comment requesting it.

For team-level rules (how to ask for help, paired work, escalation), see [team.md](team.md).

---

## Module ownership

| Session | Module | Folder(s) | Complexity |
|---|---|---|---|
| **Devin-L** | **TEAM LEAD** (no module — reviews everyone) | — | high |
| **Devin-1** | **Core + Network** | `src/core/`, `src/network/` | high |
| **Devin-2** | **Director Systems** (camera, mana, ALL abilities) | `src/director/` | high |
| **Devin-3** | **Player + Classes** (FP-controller + 4 classes) | `src/player/` | medium |
| **Devin-4** | **Monsters A** (Worm + Mirror) | `src/monsters/worm/`, `src/monsters/mirror/`, `src/monsters/base_monster.gd` | medium |
| **Devin-5** | **Monsters B** (Swarm + Tongue) | `src/monsters/swarm/`, `src/monsters/tongue/` | medium |
| **Devin-6** | **World system (runtime)** (rooms, walls, doors, items, map loader) | `src/world/` | high |
| **Devin-7** | **Shaders + VFX** (cel-shading, outline, fog) | `src/shaders/` | medium |
| **Devin-8** | **UI** (HUD + Lobby + Menu) | `src/ui/` | medium |
| **Devin-9** | **Audio + Proximity Chat** | `src/audio/` | medium |
| **Devin-10** | **Map 1 — The Childhood Home** (geometry, rooms, doors placement) | `scenes/main/`, `src/assets/maps/` | medium |

**Plus shared:** `src/assets/` (anyone can add models/textures with attribution in `src/assets/SOURCES.md`)

---

## Public interfaces

Each module exposes a small set of **public functions/signals** through a singleton-like API. Below is the contract — modules MUST follow this. If you change a public interface, you MUST update this doc in the same PR.

### `Core` (Devin-1)

**Autoloads:** `GameState`, `EventBus` (singletons, registered in `project.godot`)

```gdscript
# GameState
GameState.role: String          # "director" or "escapist"
GameState.player_id: int        # Steam ID or local ID
GameState.match_phase: String   # "lobby", "playing", "ending"
GameState.mana: int             # Director's mana, 0–200

# GameState signals
GameState.match_started
GameState.match_ended(winner: String)   # winner = "director" or "escapists"
GameState.role_assigned(role: String)   # role = "director" or "escapist"

# EventBus
EventBus.emit(event_name: String, payload: Dictionary) -> void
EventBus.connect_event(event_name: String, callable: Callable) -> void
EventBus.disconnect_event(event_name: String, callable: Callable) -> void
```

### `Network` (Devin-1)

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

### `Director` (Devin-2)

**Autoload:** `Director`

```gdscript
Director.try_use_ability(ability_name: String, target_data: Dictionary) -> bool
Director.get_remaining_mana() -> int
Director.get_cooldown(ability_name: String) -> float
Director.register_ability(name: String, handler: Node, mana_cost: int, cooldown: float) -> void

# Signals
Director.ability_used(ability_name: String)
Director.mana_changed(new_mana: int)
```

Devin-2 implements all 8 abilities internally within `src/director/`:
- Move Wall, Open/Close Door, Swap Doors, Create Door (`src/director/walls_doors.gd`)
- Toggle Light, Swap Items, Program Monster Trigger (`src/director/lights_items.gd`)
- Summon Monster (`src/director/monster_summon.gd`)

### `Player` (Devin-3)

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

Devin-3 implements:
- First-person controller, stamina, flashlight, interaction (`src/player/`)
- 4 classes (Scout, Locksmith, Medic, Listener) in `src/player/classes/`

### `Monster` (Devin-4 and Devin-5)

Each monster is a `Node3D` extending `BaseMonster`. Common interface:

```gdscript
class_name BaseMonster extends Node3D
var hp: int
var monster_type: String       # "worm", "mirror", "swarm", "tongue"
func spawn(at_position: Vector3) -> void
func receive_command(command: String, data: Dictionary) -> void
func take_damage(amount: int, source: Node) -> void

# Signals
killed(by: Node)
artifact_stolen(artifact: Item)   # only emitted by Worm
```

**Devin-4** owns `src/monsters/base_monster.gd` (the shared base) plus Worm + Mirror.
**Devin-5** uses the base from Devin-4 — adds Swarm + Tongue only.

If Devin-5 starts work and `base_monster.gd` doesn't exist yet, create a stub and Devin-4 will finalize it. Coordinate via PR comments.

### `World` (Devin-6)

**Autoload:** `World`

```gdscript
World.get_room_at(position: Vector3) -> Room
World.get_door(door_id: String) -> Door
World.move_wall(wall_id: String, new_transform: Transform3D, duration: float) -> void
World.swap_doors(door_a_id: String, door_b_id: String) -> void
World.create_door(wall_id: String, position: Vector3, leads_to_room_id: String) -> Door
World.load_map(map_name: String) -> void

# Signals
World.wall_moved(wall_id: String)
World.door_created(door_id: String)
World.map_loaded(map_name: String)
```

Devin-6 also delivers **Map 1: The Childhood Home** as a `.tscn` in `scenes/main/`.

### `Shaders / VFX` (Devin-7)

No autoload. Provides reusable `.gdshader` files:
- `src/shaders/cel_shading.gdshader` — toon shader for materials
- `src/shaders/outline.gdshader` — post-process outline
- `src/shaders/volumetric_fog.gdshader` — atmospheric fog
- `src/shaders/test_scene.tscn` — demo / regression scene

Other modules pull these shaders by path when creating materials.

### `UI` (Devin-8)

Provides scenes (no autoload):
- `src/ui/menu/main_menu.tscn`
- `src/ui/menu/settings.tscn`
- `src/ui/lobby/lobby_browser.tscn`
- `src/ui/lobby/lobby_room.tscn`
- `src/ui/hud/director_hud.tscn`
- `src/ui/hud/escapist_hud.tscn`
- `src/ui/hud/match_overlay.tscn`

UI connects to signals from `GameState`, `Director`, `Net`. UI does NOT call mutating functions outside its module — it emits its own signals that other modules listen to.

### `Audio` (Devin-9)

**Autoload:** `Audio`

```gdscript
Audio.play_sfx(name: String, position: Vector3) -> void
Audio.play_music(track: String) -> void
Audio.set_proximity_chat_active(enabled: bool) -> void
```

---

## Message bus (EventBus)

For events that span modules, use the `EventBus` autoload (in `src/core/event_bus.gd`):

```gdscript
EventBus.emit("artifact_picked_up", {"artifact_id": "skull", "by_player": 12345})
EventBus.connect_event("artifact_picked_up", _on_artifact_picked_up)
```

Common events (any module can listen):
- `artifact_picked_up` — payload: `{artifact_id, by_player}`
- `artifact_dropped` — payload: `{artifact_id, at_position}`
- `door_opened` — payload: `{door_id, by_player}`
- `room_entered` — payload: `{room_id, by_player}`
- `monster_spawned` — payload: `{monster_type, position}`
- `escapist_died` — payload: `{player_id, by_monster}`
- `match_won` — payload: `{winner}`

If you add a new event, add it to this list.

---

## Branch / PR conventions

- Each Devin works on `<devin-name>/issue-<N>-<short>`
- PRs target `dev` branch
- After review by Team Lead AND merge to `dev`, Project Lead merges `dev` → `main` periodically (~ once a sprint)

---

## Adding a new public interface

If your module needs to expose a new public function/signal:
1. Add it to your module's section above (in the SAME PR that introduces it)
2. Mention "**ADDED PUBLIC INTERFACE**" in the PR description
3. Team Lead reviews → if breaking change, alert affected module owners
4. Project Lead merges
