# Playbook: Adding a new monster

Use this when the project lead asks you to add a new monster type to the game.

## Prerequisites

- Read [GDD §7](../GDD.md#7-monsters-4-types-director-picks-1--1-backup) for the existing 4 monsters and the design pattern.
- Read [architecture.md — Monster](../architecture.md#monster-devin-8-9) for the public interface.

## Steps

1. **Get the design.** The user must specify:
   - Name
   - Description (visual + behavior)
   - Speed
   - Unique behavior / mechanic
   - Weakness
   - Counters (which Escapist class beats it)
   - Mana cost for Director to summon

2. **Add to GDD.md.** Edit `docs/GDD.md` §7. Add a new "Monster #N" subsection with all fields. **Same PR as the code.**

3. **Create folder.** `src/monsters/<name>/`

4. **Create script.** `src/monsters/<name>/<name>.gd` — extends `BaseMonster` (in `src/monsters/base_monster.gd`).

5. **Create scene.** `src/monsters/<name>/<name>.tscn` — Node3D + collider + placeholder mesh.

6. **Implement the public interface:**
   ```gdscript
   func spawn(at_position: Vector3) -> void
   func receive_command(command: String, data: Dictionary) -> void
   func take_damage(amount: int, source: Node) -> void
   ```

7. **Wire to Director's monster picker UI** — register the new monster in `src/director/monster_registry.gd`.

8. **Tests.** Add `tests/test_<name>_monster.gd` with at least:
   - Spawning at correct position
   - Reacting to correct command
   - Dying at correct damage threshold

9. **Open PR** with title `[#<issue>] Add <Name> monster` and link the GDD update.

## Common mistakes

- Forgetting to update `docs/architecture.md` if you add a new public method
- Hardcoding values — use `@export` so the project lead can balance from the editor
- Not pooling — monsters can be spawned/despawned many times per match; reuse instances if possible
