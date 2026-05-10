# DIRECTOR

> 1v4 asymmetric PvP horror — one player IS the house

## What is this

DIRECTOR is a 3D multiplayer horror game where 5 players queue together. One is randomly chosen to play **THE DIRECTOR** — they see the house from above and reshape it in real time (move walls, swap doors, summon monsters). The other 4 are **ESCAPISTS**, playing in first-person inside the house, trying to find 3 artifacts and escape through the main exit before the house consumes them.

**Engine:** Godot 4.4+
**Target platforms:** Windows (primary), macOS, Linux
**Target audience:** PEAK / REPO / Lethal Company players
**Release target:** Steam ($9.99 - $14.99)

## For developers / Devin sessions

If you are a Devin session, your first stop is:

1. **[AGENTS.md](AGENTS.md)** — read this first. Always.
2. **[docs/GDD.md](docs/GDD.md)** — full game design document.
3. **[docs/architecture.md](docs/architecture.md)** — code structure and module boundaries.
4. **[docs/prompts.md](docs/prompts.md)** — 14 ready prompts, one per parallel session.
5. **[docs/discoveries.md](docs/discoveries.md)** — shared notes between sessions. Read it. Append to it when you learn something important.

## Quick start (local development)

```bash
# 1. Install Godot 4.4+
# Download from https://godotengine.org/download (or use the included blueprint)

# 2. Clone the repo
git clone https://github.com/director-game-studio-with-chat-gpt/director-game.git
cd director-game

# 3. Open in Godot
godot project.godot
# or
godot --editor

# 4. To run the game
godot --path .
```

## Project layout

```
director-game/
├── README.md                  ← this file
├── AGENTS.md                  ← rules for AI sessions / contributors
├── project.godot              ← Godot project file
├── docs/
│   ├── GDD.md                 ← game design doc
│   ├── architecture.md        ← module structure
│   ├── prompts.md             ← 14 parallel session prompts
│   ├── discoveries.md         ← shared notes (append-only)
│   └── playbooks/             ← reusable how-tos
├── scenes/
│   ├── main/                  ← gameplay scenes
│   └── lobby/                 ← lobby/menu scenes
├── src/
│   ├── director/              ← Director top-down editor + abilities
│   ├── player/                ← First-person controller for Escapists
│   ├── network/               ← multiplayer / Steam P2P
│   ├── world/                 ← house/room/door/wall systems
│   ├── monsters/              ← 4 monster types
│   ├── ui/                    ← menus, HUD, lobby
│   ├── audio/                 ← music, SFX, proximity chat
│   ├── shaders/               ← cel-shading + outline + fog
│   └── assets/                ← models, textures, audio
├── tests/                     ← unit + integration tests
└── .github/workflows/         ← CI
```

## License

Proprietary. © 2026 director-game-studio-with-chat-gpt. All rights reserved.
