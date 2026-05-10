# DIRECTOR — Game Design Document

**Version:** 0.1 (initial)
**Last updated:** 2026-05-10

---

## 1. Vision statement

> 5 friends queue up. One plays AS THE HOUSE. Four play INSIDE the house. The house reshapes itself in real time around them.

DIRECTOR is a **1v4 asymmetric PvP horror** game where the antagonist is not a slasher chasing players (Dead by Daylight) but the **environment itself**. The Director player edits the level live — moving walls, swapping doors, summoning monsters — while the four Escapists try to find 3 artifacts and reach the main exit.

**One-line pitch:** "Coraline meets Among Us, but the impostor is the house."

---

## 2. Inspirations & differentiation

| Game | What we take | What we change |
|---|---|---|
| **Dead by Daylight** | 1v4 asymmetric format | Antagonist controls the **environment**, not a chasing killer |
| **PEAK / REPO** | Stylized low-poly graphics, proximity-chat-driven panic | Replace co-op survival with PvP asymmetry |
| **Lethal Company** | Co-op extraction loop, voice chat as gameplay | Add a real human antagonist |
| **The Sims (build mode)** | Top-down room editor | Make it real-time, sabotage-focused |
| **Coraline (film)** | Stylized creepy doll-house aesthetic | Ours is grimmer; muted palette |
| **Inscryption / Mouthwashing** | Stylized + mood-heavy | Same visual ambition |

**Why our hook is original:** No published game lets a player **reshape the level live in 3D while opponents play inside it**. SCP: Containment Breach Multiplayer gestured at it but never shipped real geometry editing.

---

## 3. Core gameplay loop (one round, 8–15 minutes)

### Lobby
- 5 players queue → 1 randomly assigned **Director**, 4 are **Escapists**
- Players choose Escapist class (see §6)
- Director picks 1 primary monster + 1 backup (see §7)
- Map vote (Round 1: choose between 2 maps; later expansions add more)

### Match
1. **00:00** — 4 Escapists spawn at separate points in the house. Director sees full top-down 3D view.
2. **00:00–08:00** — Escapists explore, find 3 artifacts hidden in random rooms. Director uses abilities (move walls, swap doors, summon monsters, kill lights, spawn traps) to slow them down. Director resources are limited by **mana** (regenerates over time).
3. **08:00–12:00** — Escapists with all 3 artifacts must reach the **main exit** (a fixed unmoveable door). Director throws everything at them.
4. **End:**
   - **Escapists win** if at least 1 escapes through the main exit with the artifacts
   - **Director wins** if all 4 are killed

### Post-match
- Stats screen: artifacts found, monsters killed, time alive
- Vote MVP
- Queue again

---

## 4. Director gameplay

The Director sees a **top-down 3D camera** of the house with all 4 Escapists shown as colored dots in real time. Director hears the proximity chat of all Escapists (this is part of their power).

### Director abilities

| Ability | Cost (mana) | Cooldown | Effect |
|---|---|---|---|
| **Move wall** | 20 | 8s | Drag a movable wall to a new position. Animates over 5s — Escapists can see it happening. |
| **Open/close door** | 5 | 3s | Lock or unlock any non-fixed door. |
| **Swap doors** | 30 | 12s | Swap the destinations of 2 doors. Escapist enters door A, exits where door B used to lead. |
| **Create new door** | 50 | 20s | Place a new door anywhere in any wall. Choose where it leads. |
| **Toggle light** | 10 | 5s | Turn light on/off in a chosen room. Lights take 1s to actually flicker out. |
| **Summon monster** | 40 | 30s | Spawn a chosen monster in a chosen room. Limited to 2 monsters alive at once. |
| **Program monster trigger** | 25 | 15s | Set a monster to spawn/attack when a specific event happens (e.g. "appear from this door when an Escapist opens it"). |
| **Swap items** | 15 | 10s | Move an in-world item (artifact, key, weapon) to a different room. |

**Mana system:**
- Director starts with 100 mana, max 200, regenerates 5 mana/sec
- Spamming abilities = mana drained = forced cooldown window where Escapists can rush
- This is the **balance lever** — Escapists win by exploiting mana droughts

### Director UI (top-down view)

```
┌─────────────────────────────────────────────────────────────┐
│  [House top-down 3D view, room layout, 4 colored dots]      │
│                                                             │
│   ┌─────┬──────┐    ┌──────────┐                           │
│   │ Bed │ Bath │    │ Kitchen  │                           │
│   │     │      │────┤   ●Red   │                           │
│   ├─────┴──────┤    └──────────┘                           │
│   │            │  ●Blue                                    │
│   │  Hall      │                                           │
│   └────────────┘                                           │
│                                                             │
├─ MANA ░░░░░░░░░░░░░░ 87/200 ────────────────────────────── │
│                                                             │
│ [Move Wall] [Doors▼] [Lights▼] [Monsters▼] [Items▼]        │
│                                                             │
│ Selected monster: WORM    Position: pending                 │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. Escapist gameplay

Escapists play **first-person**. They have a flashlight, a stamina bar, and an inventory of 3 slots.

### Escapist controls
- **WASD** — move
- **Mouse** — look
- **F** — flashlight on/off (but flashlight drains battery, found in world)
- **E** — interact (open door, pick up item)
- **Q** — drop held artifact
- **R** — use class ability (see §6)
- **Tab** — view inventory + minimap (only shows rooms you've already visited)
- **Push-to-talk (V)** — proximity chat (heard by nearby Escapists AND by the Director, always)
- **B** — radio (heard by all teammates AND by the Director, always — riskier but longer range)

### Escapist objectives
1. Find 3 **artifacts** (skull, photograph, key) hidden in random rooms
2. Bring them to the **main exit door**
3. Place each artifact on its pedestal at the exit
4. Open the exit door and walk out

Escapists do **not** know which rooms have artifacts. They must explore.

### Escapist combat / survival
- Escapists are **mostly defenseless**
- Each Escapist class has **one combat tool** (knife, pepper spray, taser — see §6)
- These weapons stun monsters for a few seconds; they do not kill
- Escapists die in 2 hits from any monster
- Death = spectator mode (you can watch teammates and the Director, can't communicate)

---

## 6. Escapist classes (4 unique roles)

Each round, the 4 Escapists each pick a different class. No duplicates allowed.

| Class | Ability | Combat tool |
|---|---|---|
| **THE SCOUT** | "Foresight": briefly see the layout of all rooms (3 sec) once per minute | Knife (1 stun, 5s) |
| **THE LOCKSMITH** | "Anchor": temporarily disables Director's edits in a 1-room radius for 10 sec, once per 90 sec | Pepper spray (range stun, 3s) |
| **THE MEDIC** | "Patch": revive a downed teammate (one revive per teammate per match) | Taser (point-blank stun, 4s) |
| **THE LISTENER** | "Echo": hear monster footsteps and Director ability sounds at 3x range, always on | Salt shaker (works only on Worm and Roach monsters) |

Picking the right class composition is part of the strategy.

---

## 7. Monsters (4 types, Director picks 1 + 1 backup)

Each monster is a **tool** the Director chooses based on map and play style. They are not autonomous AI — the Director **directs them**.

### Monster #1: WORM
- **Description:** A long, eyeless white worm that crawls along walls and ceilings
- **Speed:** Slow
- **Unique behavior:** **Steals artifacts.** If an Escapist drops an artifact (or dies and drops it), the Worm crawls to it and carries it away to a random hidden spot. Director can direct the Worm to specific drop points.
- **Weakness:** Light. A flashlight beam slows it 75%; sustained light kills it.
- **Counters:** Scout's Foresight, Listener's Echo

### Monster #2: MIRROR
- **Description:** A pale, slow figure that copies the movements of the nearest Escapist
- **Speed:** Identical to its target
- **Unique behavior:** Spawns in a chosen room and **mirrors** the closest Escapist's movements, causing dread and confusion. It does not attack directly — getting close (within 2m) for 3+ seconds causes 1 damage and disables flashlight for 5 sec.
- **Weakness:** A single shot from any combat tool destroys it.
- **Counters:** Locksmith (anchor stops it), all combat tools

### Monster #3: SWARM
- **Description:** A dense cloud of black moths and ash
- **Speed:** Slow but covers entire rooms
- **Unique behavior:** Fills a room. Visibility for Escapists in the room drops to 1m. Flashlights disperse a cone but slowly drain.
- **Weakness:** Wind. If a window is opened OR a fan is turned on, the Swarm dissipates in 5 sec.
- **Counters:** Scout (briefly sees through), opening windows

### Monster #4: TONGUE
- **Description:** A long pale tongue that emerges from doors the Director just placed
- **Speed:** Stationary, but can extend up to 4m
- **Unique behavior:** **Trigger-based.** Director "programs" the Tongue: "appear from THIS door when an Escapist opens it." Lures Escapists into newly placed doors. Grabs at 4m range and drags into the door (instant kill).
- **Weakness:** A knife strike to the tongue retracts it for 5 sec.
- **Counters:** Locksmith's anchor, knife strike

---

## 8. Maps (vertical slice = 1, full launch = 5–7)

### Map 1: "The Childhood Home" (vertical slice)
- 2-story Victorian-style home, ~12 rooms
- Coraline / Mouthwashing aesthetic
- Mood: muted greens and browns, a single warm light source per room
- Fixed rooms (Director can't remove): Foyer (spawn), Main Exit door

### Map 2: "The Sanitarium"
- Single-floor abandoned mental hospital
- Long corridors, rooms with patient beds
- Mood: cyan + bone white, fluorescent flicker

### Map 3: "Khrushchyovka" (5-floor Soviet apartment block)
- Vertical map, 5 floors with 2 apartments each
- Mood: brutalism, panel walls, tube TVs

### Map 4: "The Theater" (DLC)
- Empty old theater with backstage maze

### Map 5: "The Vault" (DLC)
- Bank vault tunnels, claustrophobic

We start with **Map 1 only** for vertical slice. Other maps are post-launch DLC if the game succeeds.

---

## 9. Visual style

### Direction: **Stylized low-poly horror with cel-shading**

Reference images: see `docs/moodboard.md` (TBD).

### Concrete style rules
- **Polygon budget:** 5k tris per character, 10k per room, 50k per full map
- **Texture budget:** 1024×1024 max, 512×512 default
- **Palette:** muted base (dark green, burgundy, dirty purple) + 1 strong accent per scene (warm orange, neon red, sickly yellow)
- **Cel-shading:** post-process shader with hard light/dark threshold + black silhouette outline (`src/shaders/cel_shading.gdshader`)
- **Lighting:** 1 main warm directional light + many small point lights (lamps, candles, monitors)
- **Fog:** volumetric fog in every scene, ~30% density
- **No PBR:** simple shaders only

### Reference points
- REPO (low-poly chunky horror)
- PEAK (cel-shading + stylized props)
- Inscryption (mood)
- Lethal Company (atmospheric lighting)
- Coraline (doll-house feel)

### Anti-references (DO NOT look like)
- The Sims (flat, cheery, daytime)
- AAA realism (too expensive, doesn't fit our pipeline)

---

## 10. Audio

- **Music:** dark ambient with a few orchestral motifs. No combat themes. References: *Mouthwashing* OST, *Pathologic 2* OST.
- **SFX:** practical foley (footsteps, doors, wood creaks). Director's edits make distinctive "wet wood" sound.
- **Proximity chat:** Steam Voice integration via [Steam Audio](https://godotengine.org/asset-library/asset/3046) or built-in Godot WebRTC voice. Range: ~5m falloff.
- **Director's "voice":** the Director can optionally type messages that appear on a chalkboard in any room (for taunts / roleplay).

---

## 11. Multiplayer architecture

- **Topology:** Client-server (host-authoritative). The Director player is the host (their machine has authoritative simulation).
- **Transport:** Steam Networking Sockets (P2P, free for Steam-published games)
- **Rationale for host-authoritative:** prevents cheating; only the Director can edit geometry, and they're already trusted with that.
- **Player capacity:** 5 (1 Director + 4 Escapists)
- **Region matchmaking:** Steam handles via lobby browser

---

## 12. Progression / monetization

- **Base game:** $9.99 launch, $14.99 post-Early-Access
- **No microtransactions, no battle pass, no ads**
- **Cosmetics:** unlocked by playing, free
- **DLC roadmap:** new maps + new monster types every 3-6 months ($4.99 per pack)
- **Steam Workshop support** (custom maps, stretch goal)

---

## 13. Roadmap

| Phase | Duration | Milestone |
|---|---|---|
| **Pre-prod** | 1 week | This GDD, repo skeleton, Devin sessions assigned |
| **Vertical slice** | 6–8 weeks | Map 1, 1 Director, 4 Escapist classes, 2 monsters playable |
| **Steam page + teaser trailer** | + 1 week (parallel) | Wishlist accumulation begins |
| **Closed alpha** | 4 weeks | 50 testers, balance feedback |
| **Demo for Steam Next Fest** | 4 weeks | Map 1 polished, all 4 monsters, all 4 classes |
| **Beta + content** | 8 weeks | Map 2, balance, polish |
| **Launch** | — | $9.99 Early Access |
| **Post-launch** | ongoing | Maps 3-5 as paid DLC, Workshop support |

**Total to launch:** ~6 months at 14-session parallel pace.

---

## 14. Risks

| Risk | Mitigation |
|---|---|
| Multiplayer netcode is hard | Host-authoritative + Steam P2P; budget 2 sessions on this |
| Director balance (1v4 is hard to tune) | Mana system + class anchor abilities; prioritize playtesting |
| Live geometry editing performance | Pre-built room "swap volumes" instead of arbitrary geometry |
| Asset bottleneck | Free CC0 assets + uniform cel-shader hides quality differences |
| Scope creep | Lock to 1 map / 4 monsters for vertical slice |

---

## 15. Open questions (TBD)

- Should the Director see Escapist health bars? (current: yes, simplifies decision-making)
- Should Escapists see each other's locations on minimap? (current: no, forces voice coordination)
- Difficulty tiers? (current: no, single difficulty for v1)
- Cross-play with non-Steam? (current: Steam only, simplifies networking)

---

**End of GDD v0.1.** Updates go in version 0.2 with changelog at top.
