# Playbook: Adding a new Director ability

Use this when adding a new ability to the Director's bar (e.g. "summon fog," "lock all doors").

## Prerequisites

- Read [GDD §4](../GDD.md#4-director-gameplay) for existing abilities.
- Understand the mana / cooldown / dispatcher system (Devin-3's module).

## Steps

1. **Get the design.** The user must specify:
   - Ability name
   - Mana cost
   - Cooldown
   - Effect (what happens when fired)
   - Target type (room / wall / door / item / position / passive)

2. **Add to GDD.md.** Append to the table in §4 in the SAME PR.

3. **Pick the right module** based on what the ability operates on:
   - Walls/Doors: `src/director/walls/` or `src/director/doors/`
   - Lights/Items: `src/director/lights/` or `src/director/items/`
   - Monster-related: `src/director/monsters/`
   - New category? Open an Issue, ask the project lead before creating new folders.

4. **Implement the ability handler:**
   ```gdscript
   class_name MyAbility extends Node

   const MANA_COST: int = 30
   const COOLDOWN: float = 12.0

   func execute(target_data: Dictionary) -> void:
       # actual logic
       pass
   ```

5. **Register with the dispatcher:**
   ```gdscript
   # In your module's _ready()
   Director.register_ability("my_ability", self, MANA_COST, COOLDOWN)
   ```

6. **Add UI button** in `src/ui/hud/director_hud.tscn` (Devin-13's module).
   - If you don't own the HUD module, open an Issue requesting the button addition.

7. **Tests.**
   - Mana is deducted only on success
   - Cooldown enforced
   - Target validation (e.g. ability needs a wall — fails if no wall provided)

8. **Open PR.**
