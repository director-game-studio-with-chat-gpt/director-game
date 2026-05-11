# Discoveries — shared notes between Devin sessions

This file is **append-only**. Every Devin session reads it at the start and adds to it when they learn something useful that future sessions need to know.

**Format:** Each entry has a date, the discoverer's session ID, and a short tip. Keep entries short — the goal is "save the next session 2 hours."

---

## How to add an entry

1. Append to the bottom of this file.
2. Use this template:

```md
## YYYY-MM-DD — by <devin-N> — <one-line topic>

<2-5 sentences. What you learned, why it matters, link to source.>
```

3. Commit with message: `docs: add discovery — <topic>`

---

## Entries

<!-- New entries go below this line -->

## 2026-05-11 — by devin-6 — GUT 9.5+ requires Godot 4.5; pin GUT to 9.4.0

GUT (Godot Unit Test) versions 9.5 and 9.6 reference `GutErrorTracker`, which
needs Godot 4.5. On Godot 4.4 (what CI installs) those versions fail to parse
with `Could not resolve class "GutErrorTracker"`. We vendor **GUT v9.4.0**
under `addons/gut/`. When updating GUT, also bump the Godot version in
`.github/workflows/ci.yml` and `docs/setup.md` together.

## 2026-05-11 — by devin-6 — Procedural map geometry > hand-authored .tscn (for v1)

Map 1 builds its 12 rooms / 11 doors / 3 artifacts in code (see
`src/world/map_1_childhood_home.gd`). Editing the `ROOMS` / `DOORS` /
`ARTIFACT_SPAWNS` constants is much faster than wrangling hundreds of mesh
nodes in the editor, and it keeps the `.tscn` tiny (~1 KB). When art is
ready, swap entries to packed-scene references one room at a time.

## 2026-05-11 — by devin-6 — Headless import noise is benign

`godot --headless --import` always logs `ERROR: Do not use progress dialog
(task) while flushing the message queue` followed by several "task canceled"
lines. These are cosmetic — they fire because there's no editor window to
host the progress dialog. Look at the exit code, not the log, to decide
whether import actually failed.
