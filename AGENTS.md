# AGENTS.md — rules for all Devin sessions and contributors

This file is read **automatically** by every Devin session that opens this repo. Every contributor MUST follow these rules.

---

## 1. About the project

We are building **DIRECTOR**: a 1v4 asymmetric PvP horror game in Godot 4 (3D). See [README.md](README.md) and [docs/GDD.md](docs/GDD.md) for full context.

This project is built by **1 Team Lead + 10 worker Devin sessions** working in parallel, coordinated through GitHub. There is no real-time chat between sessions — all communication is through:
- GitHub Issues (your assigned tasks)
- GitHub Pull Requests (your work + reviews)
- Files in `/docs/` (shared knowledge)
- This `AGENTS.md` (rules)

See [docs/team.md](docs/team.md) for who does what and how to ask for help.

---

## 2. Before you do ANYTHING

1. Read this entire file.
2. Read [docs/GDD.md](docs/GDD.md).
3. Read [docs/architecture.md](docs/architecture.md) — find your module.
4. Read [docs/discoveries.md](docs/discoveries.md) — what other sessions have learned.
5. Find your assigned GitHub Issue. The user will give you an issue number in your prompt.

If any of these files are missing or empty, do not start coding — tell the user.

---

## 3. Stay in your lane

You will be assigned **one module** in `/src/<module>/`. **Only edit files inside your module's folder** unless explicitly told otherwise.

If you need a function from another module:
- Check if it's already in `docs/architecture.md` as a public interface
- If yes — use it
- If no — open a PR comment in your Issue: "I need `<thing>` from module `<X>`. Can someone in `<X>` add it?" — then continue with a TODO in your code

**Why this matters:** if 14 sessions edit the same file, you'll create endless merge conflicts. Stay in your folder.

---

## 4. Engine, language, style

- **Engine:** Godot 4.4 or later. Do not use Godot 3 syntax.
- **Language:** GDScript by default. Use C# only if explicitly required for performance.
- **Type hints:** Always use static typing in GDScript:
  ```gdscript
  var health: int = 100
  func attack(target: Node3D, damage: int) -> void:
      pass
  ```
- **Naming:**
  - Files: `snake_case.gd`, `snake_case.tscn`
  - Classes: `PascalCase`
  - Functions/variables: `snake_case`
  - Constants: `UPPER_SNAKE_CASE`
- **No tabs vs spaces drama:** use **tabs** (Godot default).

---

## 5. Git workflow

- **Default branch:** `main` (release-ready, protected — do not push directly)
- **Working branch:** `dev` (integration branch — you PR to this)
- **Your branch:** `<your-name>/issue-<N>-<short-description>`
  - Example: `devin1/issue-5-door-teleport`
- **Commit messages:**
  - Imperative: "Add door teleport system" (not "Added")
  - Reference issue: "Add door teleport system (#5)"
- **Open PR to `dev`**, not `main`.
- **Do not force-push** to anything other than your own feature branch.
- **Do not skip pre-commit hooks.**

---

## 6. Pull Request rules

- **Title format:** `[#<issue>] <Short description>`
  - Example: `[#5] Add door teleport system`
- **Description must include:**
  - What you built (1 paragraph)
  - How you tested it (steps to reproduce)
  - Screenshots/video if visual
  - Any new dependencies added
  - Any breaking changes to public interfaces
- **Wait for review** before merging. The user (project lead) reviews and merges.
- **Never** merge your own PR.
- If CI fails → fix it. If it's flaky → comment in the PR with details.

---

## 7. When you get stuck

Do **NOT** silently give up or fake working code. Instead:

1. Open a comment on your assigned Issue with prefix `BLOCKED:`
2. Describe: what you tried, what failed, what you need
3. Tag: `@plpla7386-web help`
4. Continue working on a different sub-task while you wait, OR stop and message the user

---

## 8. When you discover something useful

If you learn something that future sessions need to know (a Godot quirk, a workaround, a useful pattern), append it to **[docs/discoveries.md](docs/discoveries.md)** in a new section. Future sessions read this file automatically.

Example:
```md
## 2026-05-11 — by devin-3 — Godot 4 multiplayer authority

In Godot 4, you must call `set_multiplayer_authority(peer_id)` on a node BEFORE
spawning it on the network. Otherwise RPCs silently drop. Took me 2 hours to find.
Reference: https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html
```

Keep it short. The goal is "save the next session 2 hours."

---

## 9. Asset rules

- **Free / CC0 assets only** unless the user explicitly buys a license. Sources:
  - https://kenney.nl (free CC0 3D assets)
  - https://sketchfab.com (filter "free" + CC license)
  - https://opengameart.org
  - https://freesound.org (audio, check license)
- **Always cite** the source in `src/assets/SOURCES.md`.
- **Do not commit large binary assets** (>5 MB). Use Git LFS if needed.

---

## 10. Performance & quality

- **Target FPS:** 60 on a mid-range PC (RTX 3060 / similar)
- **Max polycount per character:** 5000 tris
- **Max texture size:** 1024×1024 by default
- **Always profile** if your code adds physics, AI, or shaders. Use Godot's built-in profiler.

---

## 11. Security

- **Never** commit secrets (API keys, Steam keys, OAuth tokens). Use environment variables.
- **Never** trust client input in multiplayer. Validate on the server (host).
- **No telemetry / analytics** without explicit user approval.

---

## 12. Tests

- Unit tests for game logic (not for Godot scenes).
- Use [GUT](https://github.com/bitwes/Gut) — Godot's test framework. Already configured.
- All PRs must keep CI green.
- New features should add at least 1 test. (No 80% coverage rule, just don't ship broken stuff.)

---

## 13. Comments

Bias toward **no comments**. Use clear function/variable names instead.

If you must comment:
- Comment **why**, not **what**.
- Never write comments that only describe your diff (e.g. "// fixed bug from before"). Put that in the PR description instead.

---

## 14. The user / project lead

- **GitHub username:** `plpla7386-web`
- **Devin username:** Ьалал (`plpla7386@gmail.com`)
- **Role:** Project lead. Reviews and merges all PRs. Creates Issues. Coordinates between sessions.
- **Tag with:** `@plpla7386-web` in PR / Issue comments when you need decisions.

---

## 15. Mental model — how 14 sessions stay in sync

Imagine you're one of 14 remote junior devs:
- You see the same code (this repo).
- You see the same docs (`/docs/`).
- You see the same Issues and PRs.
- You **don't** chat directly with other devs — you communicate through code and Issue comments.
- You trust the documents — if `docs/architecture.md` says "Module X exposes function `foo()`," you trust it. If it changes, the dev who changed it must update the doc.

If you're confused about who owns what — read `docs/architecture.md`. If still confused — ask the user.

---

**END OF AGENTS.md. Now go read [docs/GDD.md](docs/GDD.md).**
