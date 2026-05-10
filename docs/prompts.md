# 14 ready-to-paste prompts for Devin sessions

Each prompt below is **complete and self-contained**. Open a new Devin session, paste the prompt, hit Enter. The session will read the repo, find its module, and start working.

**Project lead:** copy each prompt into a different Devin account / session. There are 14 prompts; you have 14 accounts. 1:1 mapping.

---

## SHARED PREAMBLE (already inlined into each prompt below)

> You are part of a 14-session parallel team building DIRECTOR — a 1v4 asymmetric PvP horror game in Godot 4. Repo: `https://github.com/director-game-studio-with-chat-gpt/director-game`. Always read `AGENTS.md` and `docs/GDD.md` and `docs/architecture.md` before starting. Coordinate ONLY through GitHub (Issues, PRs, files in `/docs/`). The project lead is `@plpla7386-web` on GitHub.

---

## Prompt 1 — Devin-1 (Engine / Core)

```
You are Devin-1 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-1/issue-1-core-bootstrap

Read AGENTS.md, docs/GDD.md, docs/architecture.md.

Your task: Issue #1 — Set up the core game state and autoloads.

Scope (only edit src/core/):
1. Create src/core/game_state.gd — autoload "GameState" with the public interface from docs/architecture.md
2. Create src/core/event_bus.gd — autoload "EventBus" with emit() / connect() helpers
3. Create src/core/scene_loader.gd — handles transitions between lobby and match
4. Register the autoloads in project.godot
5. Write basic GUT tests in tests/test_game_state.gd

When done: open a PR titled "[#1] Core bootstrap — GameState, EventBus, SceneLoader" against dev branch. CI must pass.

If blocked: comment on Issue #1 with "BLOCKED: <reason> @plpla7386-web help".
```

---

## Prompt 2 — Devin-2 (Network / Steam)

```
You are Devin-2 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-2/issue-2-multiplayer

Read AGENTS.md, docs/GDD.md, docs/architecture.md.

Your task: Issue #2 — Set up multiplayer skeleton with Godot's high-level networking.

Scope (only edit src/network/):
1. Create src/network/net.gd — autoload "Net" with public interface from docs/architecture.md
2. Implement host_match() / join_match() using ENet for now (we'll swap to Steam later)
3. Set up RPC scaffolding for: Director→Escapist (geometry edits), Escapist→Director (interactions)
4. Implement peer joined/left signals
5. Write GUT tests for connection flow with 1 host + 2 clients (mocked)

Do NOT integrate Steam yet — that's a separate Issue. Use Godot's MultiplayerAPI.

When done: PR "[#2] Multiplayer skeleton with ENet" → dev. CI green.

If blocked: comment "BLOCKED: ... @plpla7386-web help" on Issue #2.
```

---

## Prompt 3 — Devin-3 (Director controller / mana / camera)

```
You are Devin-3 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-3/issue-3-director-base

Read AGENTS.md, docs/GDD.md, docs/architecture.md.

Your task: Issue #3 — Implement the Director's top-down camera, mana system, and ability bar UI hooks.

Scope (only edit src/director/ root level — NOT walls/doors/lights/items subfolders, those are Devin-4 and Devin-5):
1. src/director/director.gd — autoload "Director" with public interface
2. src/director/camera.gd — top-down 3D camera, WASD pan, scroll zoom, click-drag rotate
3. src/director/mana.gd — mana resource (start 100, max 200, regen 5/sec)
4. src/director/ability_bar.gd — central dispatcher: ability registered → cooldown tracked → mana deducted → fires signal for the actual ability owner (in walls/doors/etc) to execute
5. Stub all 8 abilities so they at least "do nothing but consume mana" — actual logic comes from Devin-4 and Devin-5
6. Tests for mana regen and cooldown

When done: PR "[#3] Director base: camera, mana, ability dispatcher" → dev.

If blocked: comment on Issue #3.
```

---

## Prompt 4 — Devin-4 (Walls + Doors)

```
You are Devin-4 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-4/issue-4-walls-doors

Read AGENTS.md, docs/GDD.md, docs/architecture.md.

Your task: Issue #4 — Implement Director abilities: Move Wall, Open/Close Door, Swap Doors, Create New Door.

Scope (only edit src/director/walls/ and src/director/doors/):
1. src/director/walls/wall_mover.gd — handles "Move Wall" ability. Walls slide animated over 5s.
2. src/director/doors/door_swap.gd — handles "Swap Doors" — swaps "leads_to_room_id" between two doors
3. src/director/doors/door_creator.gd — handles "Create New Door" — instantiates a Door node in a wall and assigns destination
4. Visual feedback: walls "slide" with smooth tween, doors visually appear with a brief warp effect
5. Wire each ability to Director.try_use_ability dispatcher (Devin-3's API)
6. Tests for swap_doors logic (room A→B, B→A correctness)

You will need: World.move_wall(), World.swap_doors(), World.create_door() — these are Devin-10's API. If they're not implemented yet, use a stub and add a TODO referencing Issue #10.

When done: PR "[#4] Director abilities: walls + doors" → dev.

If blocked: comment on Issue #4.
```

---

## Prompt 5 — Devin-5 (Lights + Items)

```
You are Devin-5 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-5/issue-5-lights-items

Read AGENTS.md, docs/GDD.md, docs/architecture.md.

Your task: Issue #5 — Implement Director abilities: Toggle Lights, Swap Items, Program Monster Trigger.

Scope (only edit src/director/lights/ and src/director/items/):
1. src/director/lights/light_toggle.gd — toggles all OmniLight3D / SpotLight3D in a room. Lights flicker out over 1s.
2. src/director/items/item_swap.gd — moves an in-world item to a different room
3. src/director/items/trigger_programmer.gd — sets up a programmable trigger: "When event X happens, monster Y appears." Uses EventBus to register a one-shot listener.
4. Wire each ability to Director.try_use_ability dispatcher (Devin-3's API)
5. Tests for trigger_programmer (event fires → monster command issued)

When done: PR "[#5] Director abilities: lights + items + triggers" → dev.

If blocked: comment on Issue #5.
```

---

## Prompt 6 — Devin-6 (Player controller / first-person)

```
You are Devin-6 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-6/issue-6-player-controller

Read AGENTS.md, docs/GDD.md, docs/architecture.md.

Your task: Issue #6 — Implement the first-person Escapist controller (without class abilities — those are Devin-7).

Scope (only edit src/player/ root, NOT src/player/classes/):
1. src/player/escapist.gd — Node3D root with health, stamina, inventory (3 slots)
2. src/player/movement.gd — WASD + mouse look, jump, sprint with stamina drain
3. src/player/flashlight.gd — flashlight with battery
4. src/player/interaction.gd — E to interact (raycast 2m, find Item / Door / Pedestal)
5. src/player/inventory.gd — pick up / drop / use slot logic
6. Tests for stamina drain and inventory limits

When done: PR "[#6] First-person Escapist controller" → dev.

If blocked: comment on Issue #6.
```

---

## Prompt 7 — Devin-7 (Player classes — Scout, Locksmith, Medic, Listener)

```
You are Devin-7 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-7/issue-7-player-classes

Read AGENTS.md, docs/GDD.md, docs/architecture.md.

Your task: Issue #7 — Implement the 4 Escapist classes and their abilities + combat tools.

Scope (only edit src/player/classes/):
1. src/player/classes/base_class.gd — abstract base
2. src/player/classes/scout.gd — Foresight (3s map reveal, 60s cooldown), knife combat tool
3. src/player/classes/locksmith.gd — Anchor (10s edit-disable in 1-room radius, 90s cooldown), pepper spray
4. src/player/classes/medic.gd — Patch (revive teammate, 1 use per teammate per match), taser
5. src/player/classes/listener.gd — Echo (3x range hearing, passive), salt shaker (only stuns Worm + Roach)
6. Wire abilities to Escapist.use_class_ability()
7. Tests for cooldowns and ability effects

You'll need EventBus signals for monster stuns. If not yet defined, use stubs.

When done: PR "[#7] Escapist classes: Scout, Locksmith, Medic, Listener" → dev.

If blocked: comment on Issue #7.
```

---

## Prompt 8 — Devin-8 (Monster: Worm + Mirror)

```
You are Devin-8 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-8/issue-8-monsters-worm-mirror

Read AGENTS.md, docs/GDD.md, docs/architecture.md.

Your task: Issue #8 — Implement the Worm and Mirror monsters per the GDD.

Scope (only edit src/monsters/worm/ and src/monsters/mirror/):
1. src/monsters/base_monster.gd — abstract base implementing the Monster interface from architecture.md
2. src/monsters/worm/worm.gd — slow crawler, climbs walls/ceilings, steals dropped artifacts, weakness: light
3. src/monsters/worm/worm.tscn — Godot scene with placeholder model (use a free CC0 worm or a long capsule for now)
4. src/monsters/mirror/mirror.gd — copies nearest Escapist's movements, dread effect on close approach, dies in 1 hit
5. src/monsters/mirror/mirror.tscn — placeholder scene
6. Tests: Worm steals dropped artifact, Mirror dies in 1 hit

Use placeholder geometry. Real models come later.

When done: PR "[#8] Monsters: Worm + Mirror" → dev.

If blocked: comment on Issue #8.
```

---

## Prompt 9 — Devin-9 (Monster: Swarm + Tongue)

```
You are Devin-9 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-9/issue-9-monsters-swarm-tongue

Read AGENTS.md, docs/GDD.md, docs/architecture.md.

Your task: Issue #9 — Implement the Swarm and Tongue monsters per the GDD.

Scope (only edit src/monsters/swarm/ and src/monsters/tongue/):
1. src/monsters/swarm/swarm.gd — fills a room with low-vis fog particles, dispersed by wind (open window/fan)
2. src/monsters/swarm/swarm.tscn — uses GPUParticles3D
3. src/monsters/tongue/tongue.gd — trigger-based monster, spawns from a Director-placed door, grabs at 4m, drags target into door (kill)
4. src/monsters/tongue/tongue.tscn — placeholder scene
5. Tests: Swarm clears when wind triggered, Tongue retracts on knife hit

Use placeholder geometry. Real models come later.

When done: PR "[#9] Monsters: Swarm + Tongue" → dev.

If blocked: comment on Issue #9.
```

---

## Prompt 10 — Devin-10 (World — rooms, walls, doors, items)

```
You are Devin-10 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-10/issue-10-world

Read AGENTS.md, docs/GDD.md, docs/architecture.md.

Your task: Issue #10 — Build the World system: rooms, walls, doors, items, map loader.

Scope (only edit src/world/):
1. src/world/world.gd — autoload "World" with public interface from architecture.md
2. src/world/room.gd — Node3D with bounding box, list of doors, lights
3. src/world/wall.gd — Node3D, supports "movable" flag for Director's wall-move
4. src/world/door.gd — Node3D, has "leads_to_room_id" property, can be locked/unlocked, swappable
5. src/world/item.gd — pickup-able, has type (artifact, key, weapon, consumable)
6. src/world/map_loader.gd — loads "Map 1: The Childhood Home" from a .tres or .tscn
7. Tests for World.swap_doors() and World.create_door()

Map 1 ("The Childhood Home") layout: 2-floor Victorian house, ~12 rooms. Use placeholder cubes for walls. Real geometry comes later.

When done: PR "[#10] World system + Map 1 layout (placeholder)" → dev.

If blocked: comment on Issue #10.
```

---

## Prompt 11 — Devin-11 (Shaders + visual style)

```
You are Devin-11 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-11/issue-11-shaders

Read AGENTS.md, docs/GDD.md, docs/architecture.md.

Your task: Issue #11 — Build the cel-shading + outline + fog visual style. Reference: REPO, PEAK, Inscryption.

Scope (only edit src/shaders/):
1. src/shaders/cel_shading.gdshader — toon-shading shader (hard light/shadow threshold, 2 levels)
2. src/shaders/outline.gdshader — black silhouette outline (post-process, depth/normal-based)
3. src/shaders/volumetric_fog.gdshader — atmospheric fog (configurable density per scene)
4. src/shaders/test_scene.tscn — a small scene showing all 3 effects on placeholder objects
5. Document parameters in a comment block at the top of each shader

Visual target: muted base palette + 1 strong accent per scene. See GDD §9.

When done: PR "[#11] Cel-shading + outline + fog shaders" → dev.

If blocked: comment on Issue #11.
```

---

## Prompt 12 — Devin-12 (UI: Lobby + Menus)

```
You are Devin-12 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-12/issue-12-lobby-menus

Read AGENTS.md, docs/GDD.md, docs/architecture.md.

Your task: Issue #12 — Build main menu and lobby UI.

Scope (only edit src/ui/lobby/ and src/ui/menu/):
1. src/ui/menu/main_menu.tscn — Play / Settings / Credits / Quit
2. src/ui/menu/settings.tscn — graphics, audio, controls (basic)
3. src/ui/lobby/lobby_browser.tscn — list of public lobbies (mock data ok for now)
4. src/ui/lobby/lobby_room.tscn — pre-match: see other 4 players, pick Escapist class (or be auto-Director), ready button
5. Wire to Net.host_match() / Net.join_match() (Devin-2's API)
6. Style: dark theme, sans-serif font, minimal — match the game's mood

When done: PR "[#12] Lobby + main menu UI" → dev.

If blocked: comment on Issue #12.
```

---

## Prompt 13 — Devin-13 (UI: HUD + in-game)

```
You are Devin-13 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-13/issue-13-hud

Read AGENTS.md, docs/GDD.md, docs/architecture.md.

Your task: Issue #13 — Build in-game HUDs for both Director and Escapist.

Scope (only edit src/ui/hud/):
1. src/ui/hud/director_hud.tscn — top-down view overlay: mana bar, ability bar (8 buttons), monster panel, player dots
2. src/ui/hud/escapist_hud.tscn — first-person overlay: stamina bar, flashlight battery, inventory (3 slots), class ability cooldown
3. src/ui/hud/match_overlay.tscn — match timer, artifact counter, post-match scoreboard
4. Wire to GameState signals (match_started, match_ended) and Director.mana_changed

Style: minimalist, semi-transparent black backgrounds, white text, single accent color per HUD type (red for Director, cyan for Escapist).

When done: PR "[#13] In-game HUDs" → dev.

If blocked: comment on Issue #13.
```

---

## Prompt 14 — Devin-14 (Audio + proximity chat)

```
You are Devin-14 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-14/issue-14-audio

Read AGENTS.md, docs/GDD.md, docs/architecture.md.

Your task: Issue #14 — Build audio system and proximity voice chat.

Scope (only edit src/audio/):
1. src/audio/audio.gd — autoload "Audio" with public interface from architecture.md
2. src/audio/sfx_pool.gd — pooled AudioStreamPlayer3D for SFX
3. src/audio/music_player.gd — looping ambient music with crossfade
4. src/audio/proximity_chat.gd — voice capture from microphone, broadcast to nearby peers via Net RPC, decode and play 3D-positioned. The Director hears all.
5. Use Godot's built-in AudioServer + AudioEffectCapture for voice. Steam Voice integration is a later Issue.
6. Placeholder SFX and music — use https://freesound.org or a single dark drone for now (CC0).

When done: PR "[#14] Audio + proximity chat (basic)" → dev.

If blocked: comment on Issue #14.
```

---

## How to use these prompts

1. **Open 14 separate Devin sessions** — one per Devin account.
2. **For each session**, copy the corresponding prompt above (#1 through #14).
3. **Hit Send / Start.**
4. Devin will read the repo, find its module, start working.
5. **Wait 30–90 minutes**, then go to GitHub → see 14 open Pull Requests.
6. **Review each PR.** Merge if good. Comment if not.
7. After all 14 are merged, you have a working vertical slice skeleton.

## What the Devin sessions WILL do automatically

- Read AGENTS.md, GDD, architecture.md
- Find their assigned Issue
- Create the right branch
- Write code in their assigned folder
- Run tests
- Open a PR with the right title and description
- Wait for review

## What the Devin sessions WILL NOT do

- Edit other modules' folders
- Merge their own PRs
- Push directly to main or dev
- Skip CI

## What the project lead (you) does

- Review PRs (or have Devin-1 / a "tech lead" Devin do it first)
- Merge approved PRs
- Resolve conflicts when 2 PRs touch shared files (rare if everyone stays in their lane)
- Update Issues / create new ones as work progresses
- Run the game and playtest
- Update GDD when you change design

## When something breaks

- Devin will leave a comment on the Issue: `BLOCKED: <reason> @plpla7386-web help`
- You read it, decide what to do, and reply in the thread or in the Devin session

---

**Good luck. Now go open 14 tabs.**
