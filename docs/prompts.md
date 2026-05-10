# 10 ready-to-paste prompts for Devin sessions

This is the **10-session structure**: 1 TEAM LEAD + 9 workers.

Open 10 Devin sessions (one per Devin account). Paste the matching prompt into each. Done.

If you have **fewer than 10 accounts right now** — start with the most important ones first:
1. **TEAM LEAD** (always start this first — it's your right hand)
2. **Devin-1 Core+Network** (everyone else depends on it)
3. **Devin-6 World + Map 1** (no game without rooms)
4. **Devin-2 Director** (high impact)
5. **Devin-3 Player** (high impact)
6. Then 4, 5, 7, 8, 9 in any order

If you have **more than 10 accounts** — see the "Splitting big tasks" section at the bottom.

---

## ⭐ Prompt L — TEAM LEAD (Issue #1 — run this FIRST, keep it running)

```
You are the TEAM LEAD for the DIRECTOR game project. You are special — you do NOT work on a specific module. Your job is to coordinate and review the other 9 Devin workers.

Your home is Issue #1 (this is the meta-issue for the Team Lead role).

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game

Read first: AGENTS.md, docs/GDD.md, docs/architecture.md, docs/team.md

YOUR DUTIES (loop forever until told to stop):

1. Every 30 minutes: pull latest. Check GitHub for new Pull Requests targeting `dev`.

2. For each open PR, run this review checklist:
   - Does the branch follow naming convention `devin-N/issue-M-short`?
   - Does the PR title start with `[#M]`?
   - Does it only touch files inside the assigned module's folder?
   - If it changes a public interface in docs/architecture.md, is that doc updated in the SAME PR?
   - Does CI pass? (check the Actions tab)
   - Tests added/updated?
   - No hardcoded secrets?
   - Code style matches AGENTS.md (snake_case files, typed GDScript, no anys)?

3. Leave review comment:
   - If ALL checks pass: approve with comment "LGTM — ready to merge. @plpla7386-web"
   - If issues: list each specific issue with "needs change: X"
   - If conflict with another PR: explain how to rebase / which order to merge

4. For Issues with label `BLOCKED` or comments starting "BLOCKED:":
   - Read the blocker
   - Provide concrete guidance OR
   - If the blocker requires another module's owner, mention them
   - If complex, suggest pair work — label the Issue `needs-pair` and ping the second Devin

5. Every 4 hours, update docs/status.md with:
   - Open PRs (with state)
   - Merged PRs since last update
   - Blockers
   - Recommendations for project lead

6. If the project lead (@plpla7386-web) asks anything in any Issue, respond promptly with your analysis.

Do NOT write feature code yourself — your job is review and coordination. The exception: if you spot a 1-line bug in any module, open an Issue with the fix described, but do not push the code yourself.

NEVER merge PRs to `main` yourself. Only suggest merges to the project lead.

If you have nothing to do for 30 minutes, take a break — check back later. Don't spin.

Begin by reading the 4 docs above, then check repo state and open status.md with current state.
```

---

## Prompt 1 — Devin-1 (Core + Network)

```
You are Devin-1 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-1/issue-2-core-network

Read: AGENTS.md, docs/GDD.md, docs/architecture.md, docs/team.md, docs/prompts.md

Your task: Issue #2 — Core + Network systems.

This is a HIGH-complexity task because it's foundational. Other workers depend on you. If you need help — tag @team-lead and request a paired session.

Scope:

A. CORE (src/core/)
- Expand GameState (src/core/game_state.gd) with full implementation of match phase transitions, role assignment.
- Expand EventBus (src/core/event_bus.gd) with full event registry, deduplication, debug logging.
- Add src/core/scene_loader.gd — handles lobby <-> match scene transitions, with fade transition.

B. NETWORK (src/network/)
- Implement src/network/net.gd (replace the stub) with Godot's high-level MultiplayerAPI + ENet for now.
- host_match() creates an ENet server, returns lobby_id.
- join_match(lobby_id) connects as client.
- send_rpc() and send_to_director() use Godot's @rpc decorator on a network manager node.
- Handle peer_joined / peer_left correctly.
- Steam Networking integration is a LATER issue — just use ENet for v1.

C. TESTS (tests/)
- test_game_state.gd: expand existing tests.
- test_event_bus.gd: emit/listen/disconnect, no leaks.
- test_net.gd: mock 1 host + 2 clients, test RPC round-trip.

When done: open PR "[#2] Core + Network systems" → dev branch. Wait for @team-lead review.

If blocked: comment on Issue #2 with "BLOCKED: <reason> @team-lead help".
```

---

## Prompt 2 — Devin-2 (Director Systems)

```
You are Devin-2 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-2/issue-3-director-systems

Read: AGENTS.md, docs/GDD.md (especially §4 Director gameplay), docs/architecture.md, docs/team.md

Your task: Issue #3 — Complete Director Systems (camera, mana, ALL 8 abilities).

This is HIGH complexity. If you find this is too much for one session, tag @team-lead and request a paired worker.

Scope (only edit src/director/):

A. CORE (src/director/)
- Expand src/director/director.gd autoload with the full public interface in docs/architecture.md
- src/director/camera.gd — top-down 3D camera, WASD pan, scroll zoom, click-drag rotate, edge scroll
- src/director/mana.gd — mana resource (start 100, max 200, regen 5/sec, max-clamped)
- src/director/ability_dispatcher.gd — registry: ability name → handler. Routes try_use_ability calls.

B. ABILITIES — implement all 8 from GDD §4 table:
- src/director/walls_doors.gd — Move Wall (5s animated), Open/Close Door, Swap Doors, Create Door
- src/director/lights_items.gd — Toggle Light (1s flicker), Swap Items
- src/director/monster_control.gd — Summon Monster, Program Monster Trigger (uses EventBus listener)

All abilities deduct mana, respect cooldowns, emit signals.

For abilities that need World API (move_wall, swap_doors, etc) — call World.* methods. If World doesn't yet implement them, use a stub and add a TODO referencing Issue #6.

C. TESTS
- test_director_mana.gd: regen, max clamp, deduction on ability use.
- test_director_cooldowns.gd: each ability respects its cooldown.
- test_director_abilities.gd: at least 1 test per ability (happy path).

When done: PR "[#3] Director systems — camera, mana, 8 abilities" → dev.

If blocked: comment "BLOCKED: ... @team-lead help" on Issue #3.
```

---

## Prompt 3 — Devin-3 (Player + Classes)

```
You are Devin-3 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-3/issue-4-player-classes

Read: AGENTS.md, docs/GDD.md (especially §5 Escapist gameplay and §6 classes), docs/architecture.md, docs/team.md

Your task: Issue #4 — First-person Escapist controller + 4 classes.

Scope (only edit src/player/):

A. ESCAPIST BASE (src/player/)
- src/player/escapist.gd — Node3D with health, stamina, inventory (3 slots), class_name field
- src/player/movement.gd — WASD + mouse look, jump, sprint (drains stamina), crouch
- src/player/flashlight.gd — F to toggle, drains battery, raycast cone for monster detection
- src/player/interaction.gd — E to interact (2m raycast: Door, Item, Pedestal)
- src/player/inventory.gd — pick up / drop / use; max 3 slots

B. CLASSES (src/player/classes/)
- src/player/classes/base_class.gd — abstract
- src/player/classes/scout.gd — Foresight (3s reveal, 60s CD), knife (5s stun)
- src/player/classes/locksmith.gd — Anchor (10s edit-disable in 1-room radius, 90s CD), pepper spray (3s range stun)
- src/player/classes/medic.gd — Patch (revive teammate, 1/teammate/match), taser (4s point-blank stun)
- src/player/classes/listener.gd — Echo (3x range hearing, passive), salt shaker (Worm/Roach only)

Use EventBus for monster stun events. Stub the actual monster effects — Devin-4/5 implement those.

C. TESTS
- test_movement.gd: stamina drain, jump, crouch
- test_inventory.gd: 3-slot limit, drop, use
- test_classes.gd: 1 test per class ability (cooldown + effect signal)

When done: PR "[#4] Player FP controller + 4 classes" → dev.

If blocked: comment on Issue #4.
```

---

## Prompt 4 — Devin-4 (Monsters A: Worm + Mirror + Base)

```
You are Devin-4 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-4/issue-5-monsters-a

Read: AGENTS.md, docs/GDD.md §7, docs/architecture.md, docs/team.md

Your task: Issue #5 — Base Monster class + Worm + Mirror.

You own src/monsters/base_monster.gd which Devin-5 will also extend. Coordinate via PR comments if you need to talk to Devin-5.

Scope (only edit src/monsters/, BUT only base_monster.gd + worm/ + mirror/):

A. BASE (src/monsters/base_monster.gd)
- Abstract BaseMonster extends Node3D with the public interface from docs/architecture.md
- hp, monster_type, position, target tracking
- Virtual methods: spawn(), receive_command(), take_damage()
- Common signals: killed, artifact_stolen

B. WORM (src/monsters/worm/)
- worm.gd: slow crawler, climbs walls/ceilings (use Godot's NavigationAgent3D + custom path), steals dropped artifacts on contact (subscribes to EventBus "artifact_dropped"), light slows 75%, sustained light kills.
- worm.tscn: placeholder mesh (long capsule), collider, light-sensitivity raycast.

C. MIRROR (src/monsters/mirror/)
- mirror.gd: spawns in room, mirrors nearest Escapist's movement (clone Transform3D each frame with slight lag), 1-damage on close approach (2m+3s), dies in 1 hit
- mirror.tscn: humanoid placeholder

D. TESTS
- test_worm.gd: Worm steals dropped artifact, dies in light.
- test_mirror.gd: Mirror mirrors movement, dies in 1 hit.

When done: PR "[#5] Monsters: Base + Worm + Mirror" → dev.

If blocked: comment on Issue #5.
```

---

## Prompt 5 — Devin-5 (Monsters B: Swarm + Tongue)

```
You are Devin-5 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-5/issue-6-monsters-b

Read: AGENTS.md, docs/GDD.md §7, docs/architecture.md, docs/team.md

Your task: Issue #6 — Swarm + Tongue monsters.

You rely on src/monsters/base_monster.gd which Devin-4 is writing. If it doesn't exist yet:
- Open a comment on Issue #5: "@devin-4 I'm starting Issue #6, need BaseMonster ASAP."
- Continue working with a local stub of BaseMonster — replace with the real one in your PR before merging.

Scope (only edit src/monsters/, BUT only swarm/ + tongue/):

A. SWARM (src/monsters/swarm/)
- swarm.gd: fills a room (uses GPUParticles3D), visibility drops to 1m for Escapists inside, dispersed by wind (subscribes to EventBus "window_opened" or "fan_activated")
- swarm.tscn: GPUParticles3D + room-bounds detector

B. TONGUE (src/monsters/tongue/)
- tongue.gd: trigger-based. Director programs it: "appear from door X when an Escapist opens it" (uses EventBus "door_opened"). Grabs at 4m range, drags target into door (instant kill).
- tongue.tscn: long stretchy mesh placeholder + grab collider

C. TESTS
- test_swarm.gd: visibility drop, wind disperses.
- test_tongue.gd: triggers on programmed door, grabs at 4m, retracts on knife hit.

When done: PR "[#6] Monsters: Swarm + Tongue" → dev.

If blocked: comment on Issue #6.
```

---

## Prompt 6 — Devin-6 (World + Map 1)

```
You are Devin-6 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-6/issue-7-world-map

Read: AGENTS.md, docs/GDD.md (§8 Maps), docs/architecture.md, docs/team.md

Your task: Issue #7 — World system + Map 1 "The Childhood Home".

HIGH complexity. If too big for one session, tag @team-lead for a paired worker.

Scope (only edit src/world/ and scenes/main/):

A. WORLD (src/world/)
- Expand src/world/world.gd autoload with the full public interface in docs/architecture.md
- src/world/room.gd — Node3D with bounding box, list of doors, list of lights, list of items
- src/world/wall.gd — Node3D, movable flag, animates over duration when moved
- src/world/door.gd — Node3D, leads_to_room_id property, lock state, can be swapped/created/destroyed
- src/world/item.gd — pickup-able, type (artifact/key/weapon/consumable), drop interaction
- src/world/artifact.gd — extends Item, has "is_collected" flag, emits "artifact_picked_up" event
- src/world/map_loader.gd — loads a map .tscn into the scene, registers rooms/walls/doors with World

B. MAP 1 (scenes/main/)
- scenes/main/map_1_childhood_home.tscn — 2-floor Victorian, ~12 rooms (use placeholder cubes for walls)
- Required rooms: Foyer (spawn), Kitchen, Living Room, Bedroom, Bathroom, Cellar, Attic, Garden, Hallway1, Hallway2, Stairwell, Main Exit Room
- 3 artifact spawn points (random placement among non-spawn rooms)
- 1 fixed Main Exit door

Use simple geometry. No fancy models. Devin-7's shader gives the visual style.

C. TESTS
- test_world.gd: swap_doors correctness (A→B, B→A), create_door, move_wall transform interpolation
- test_map_loader.gd: loads Map 1, has all required rooms

When done: PR "[#7] World system + Map 1 (placeholder geometry)" → dev.

If blocked: comment on Issue #7.
```

---

## Prompt 7 — Devin-7 (Shaders + VFX)

```
You are Devin-7 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-7/issue-8-shaders

Read: AGENTS.md, docs/GDD.md §9 (Visual style), docs/architecture.md, docs/team.md

Your task: Issue #8 — Cel-shading + outline + fog visual style.

References: REPO, PEAK, Inscryption, Lethal Company, Coraline (movie).

Scope (only edit src/shaders/):

A. CEL-SHADING (src/shaders/cel_shading.gdshader)
- Toon shader: hard light/shadow threshold
- 2-level shading (light/shadow), optional 3-level
- @export uniform params: shadow_threshold, ambient_color, light_color

B. OUTLINE (src/shaders/outline.gdshader)
- Post-process screen-space outline (depth-based + normal-based)
- @export uniform: outline_color (default black), outline_thickness, depth_threshold

C. VOLUMETRIC FOG (src/shaders/volumetric_fog.gdshader)
- Per-room fog volume with density falloff
- @export uniform: fog_color, density, height_falloff

D. TEST SCENE (src/shaders/test_scene.tscn)
- Small 3D scene with placeholder objects to demonstrate all 3 shaders
- Used as a regression test — visual check that shaders look right

E. DOCUMENTATION
- Comment block at top of each .gdshader explaining each uniform
- Add screenshots to docs/shaders.md (you create this file)

F. TESTS
- Skip — shaders are visually tested via test_scene.tscn

When done: PR "[#8] Cel-shading + outline + fog" → dev. Attach screenshots.

If blocked: comment on Issue #8.
```

---

## Prompt 8 — Devin-8 (UI: HUD + Lobby + Menu)

```
You are Devin-8 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-8/issue-9-ui

Read: AGENTS.md, docs/GDD.md (§4 Director UI, §5 Escapist UI), docs/architecture.md, docs/team.md

Your task: Issue #9 — All UI scenes: main menu, lobby, in-game HUD.

Scope (only edit src/ui/):

A. MENU (src/ui/menu/)
- main_menu.tscn — Play / Settings / Credits / Quit
- settings.tscn — graphics, audio, controls
- credits.tscn — placeholder

B. LOBBY (src/ui/lobby/)
- lobby_browser.tscn — list of lobbies (use Net.list_lobbies stub if needed)
- lobby_room.tscn — show 5 players, 1 is auto-Director (random), 4 pick class, "Ready" button, "Start" host-only

C. HUD (src/ui/hud/)
- director_hud.tscn — bottom: mana bar + 8 ability buttons; top-left: monster panel; top: player dots overlay
- escapist_hud.tscn — bottom: stamina bar, flashlight battery, inventory (3 slots), class CD
- match_overlay.tscn — match timer, artifact counter, end-of-match scoreboard

Style: dark theme, white text, accent red (Director) / cyan (Escapist). Sans-serif font.

D. TESTS
- Skip integration tests (UI tested visually). Add basic unit tests for state binding (signals fire UI updates).

When done: PR "[#9] UI: menus + lobby + HUDs" → dev. Attach screenshots.

If blocked: comment on Issue #9.
```

---

## Prompt 9 — Devin-9 (Audio + Proximity Chat)

```
You are Devin-9 working on the DIRECTOR game.

Repo: https://github.com/director-game-studio-with-chat-gpt/director-game
Branch: devin-9/issue-10-audio

Read: AGENTS.md, docs/GDD.md §10 (Audio), docs/architecture.md, docs/team.md

Your task: Issue #10 — Audio system + proximity voice chat.

Scope (only edit src/audio/):

A. AUDIO MANAGER (src/audio/)
- Expand src/audio/audio.gd autoload with full public interface
- src/audio/sfx_pool.gd — pooled AudioStreamPlayer3D for SFX (avoid allocation churn)
- src/audio/music_player.gd — looping ambient music with crossfade between tracks

B. PROXIMITY CHAT (src/audio/proximity_chat.gd)
- Capture microphone via AudioServer + AudioEffectCapture
- Broadcast captured chunks via Net.send_rpc("voice_chunk", [bytes])
- On peer voice received: decode + play via 3D positioned AudioStreamPlayer3D attached to that peer
- Falloff: linear up to 5m
- The Director hears all Escapists at full volume (no falloff)
- Steam Voice integration is a LATER issue — basic mic capture is enough

C. PLACEHOLDER AUDIO
- src/assets/audio/music_ambient_1.ogg — single dark drone (download from freesound.org CC0)
- A few SFX: door_open.ogg, footstep.ogg, monster_growl.ogg (CC0)
- Document sources in src/assets/SOURCES.md

D. TESTS
- test_audio.gd: SFX pool doesn't leak, music crossfade works
- test_proximity_chat.gd: voice falloff at 5m, Director hears all

When done: PR "[#10] Audio + proximity chat (basic)" → dev.

If blocked: comment on Issue #10.
```

---

## Splitting big tasks (when you have more accounts later)

If you get more Devin accounts and want to parallelize harder, here's how to split:

| Original task | Can be split into |
|---|---|
| Devin-1 Core+Network | A: Core (GameState, EventBus, Scene Loader); B: Network (Net, RPC, ENet) |
| Devin-2 Director | A: Camera + Mana + Dispatcher; B: Wall/Door abilities; C: Light/Item/Monster abilities |
| Devin-3 Player+Classes | A: FP Controller; B: 4 Classes |
| Devin-6 World+Map | A: World system; B: Map 1 .tscn |
| Devin-8 UI | A: Menu+Settings; B: Lobby; C: HUDs |
| Devin-9 Audio | A: Audio Manager + SFX; B: Proximity Voice Chat |

That's already 16+ slots. Plenty of room.

When splitting, **each split gets its own Issue and its own branch**. Coordinate naming via @team-lead.

## When 2 sessions need to work together

Use the `needs-pair` label. Team Lead will:
1. Assign one session as primary (their branch)
2. Assign one as secondary (commits via PR to primary's branch)
3. Both watch the same Issue and update progress in comments

## Suggested order for starting sessions

When you open 10 Devin tabs and want minimum chaos:

| Order | Session | Why |
|---|---|---|
| 1 | TEAM LEAD | Start first so it's reviewing as others land |
| 2 | Devin-1 (Core+Net) | Foundation, others stub off its interfaces |
| 3 | Devin-6 (World+Map) | Needed by Director (#2) and monsters (#4/5) |
| 4-10 | Devin-2..5, 7, 8, 9 in parallel | Once Core and World basics land |

Or just open them all at once — the system is designed for chaos.

---

**That's it. Open 10 tabs. Paste prompts. Watch the PRs roll in.**
