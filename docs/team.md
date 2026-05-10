# Team — roles and collaboration

This file defines **who does what** and **how sessions help each other**.

## The team

### Project Lead (Human)
- **GitHub:** `@plpla7386-web`
- **Devin chat:** Ьалал
- **Role:** Final decision-maker. Merges to `main`. Approves design changes. Plays the game and gives feedback.

### Devin-L — TEAM LEAD (one session, always running)
- **Role:** Code review, conflict resolution, integration.
- **Reviews every PR** before the Project Lead merges.
- **Resolves PR conflicts** by suggesting how to combine work.
- **Can assign a second worker** to a stuck session (paired work).
- **Tag:** `@team-lead` in PR / Issue comments.
- **Prompt template:** see `docs/prompts.md` § Team Lead.

### Devin-1 through Devin-10 — WORKERS (10 sessions)
Each worker owns one module. See module assignment in [architecture.md](architecture.md).

| Worker | Module | Folder |
|---|---|---|
| Devin-1 | Core + Network | `src/core/`, `src/network/` |
| Devin-2 | Director Systems (camera, mana, all abilities) | `src/director/` |
| Devin-3 | Player + Classes | `src/player/` |
| Devin-4 | Monsters A (Worm + Mirror) | `src/monsters/worm/`, `src/monsters/mirror/` |
| Devin-5 | Monsters B (Swarm + Tongue) | `src/monsters/swarm/`, `src/monsters/tongue/` |
| Devin-6 | World system (runtime) | `src/world/` |
| Devin-7 | Shaders + VFX | `src/shaders/` |
| Devin-8 | UI (HUD + Lobby + Menu) | `src/ui/` |
| Devin-9 | Audio + Proximity Chat | `src/audio/` |
| Devin-10 | Map 1 — The Childhood Home | `scenes/main/`, `src/assets/maps/` |

## Workflow

```
                   ┌──────────────────┐
                   │  Project Lead    │
                   │  @plpla7386-web  │
                   └────────┬─────────┘
                            │ creates Issues / approves merges to main
                            ▼
                   ┌──────────────────┐
                   │  Team Lead       │     reviews every PR
                   │  Devin-L         │     resolves conflicts
                   └────────┬─────────┘     pairs workers when needed
                            │
        ┌───────────────────┼────────────────────┐
        ▼                   ▼                    ▼
   [Devin-1]           [Devin-2]   ...     [Devin-9]
   Core+Net            Director            Audio
   src/core/           src/director/       src/audio/
```

## When you're stuck — how to ask for help

You have 3 escalation paths, in order:

### 1. Ask the Team Lead first
Open a comment on your Issue or PR:
```
@team-lead I need help with X. I tried Y, but Z happened.
What I think the fix is: ...
```
Team Lead will respond within their next review cycle (usually < 30 min).

### 2. Request a pair
If the task is too big or you need someone with deep context on another module:
```
@team-lead This task needs pair work with someone from <module>.
Adding label: needs-pair
```
Team Lead will assign a second Devin to pair with you, or pull in someone whose module you're touching.

### 3. Escalate to Project Lead
If Team Lead can't unblock you (or hasn't responded in 1 hour):
```
@plpla7386-web BLOCKED on Issue #X — Team Lead unresponsive.
Details: <what you tried, what failed>
```

## When you discover a problem in another module's code

Don't fix it yourself — **don't touch other modules**. Instead:

1. Open a new GitHub Issue
2. Title: `[<module>] <Bug description>`
3. Body: steps to reproduce, expected vs actual, link to the code
4. Assign label: `bug`
5. Tag the module owner: `@devin-N (Module Owner)`

Team Lead will route it.

## When two PRs conflict

This happens when 2 sessions touch the same shared file (e.g., `project.godot`, `docs/architecture.md`).

**Default rule: first-merged wins.** Second PR rebases.

Team Lead resolves merge conflicts when:
- Both PRs modify the same public interface
- Both PRs modify the same scene file
- The conflict is non-trivial

## When the task is too big for one session

Some Issues are marked `complexity: high`. These can be split:

1. Open the Issue
2. Read the "Sub-tasks" section
3. Pick a sub-task you can finish in one session
4. Comment: "Taking sub-task: <name>. Open the next sub-task in a new Issue."

OR ask Team Lead to assign a second worker to pair.

## Reporting progress

The Team Lead maintains `docs/status.md` — daily snapshot of:
- What's merged
- What's open (PRs)
- What's blocked
- Who's on what

Workers do NOT edit status.md (Team Lead's file). Workers update their own Issue's progress in comments.

## Code review checklist (used by Team Lead)

When the Team Lead reviews a PR, they check:

- [ ] Branch follows `devin-N/issue-M-short` naming
- [ ] PR title `[#M] Short description`
- [ ] Only touches the assigned module's folder
- [ ] No edits to public interfaces without updating `architecture.md` in the same PR
- [ ] No skipped CI
- [ ] Tests added or updated
- [ ] No hardcoded secrets
- [ ] Code follows GDScript style in AGENTS.md
- [ ] PR description has: what built, how tested, screenshots if visual

Workers should self-check this list before requesting review.
