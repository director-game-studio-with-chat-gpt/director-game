extends Node
## Director — autoloaded Director ability dispatcher.
##
## Owned by Devin-3. STUB: full implementation in Issue #3.

signal ability_used(ability_name: String)
signal mana_changed(new_mana: int)

func try_use_ability(_ability_name: String, _target_data: Dictionary) -> bool:
	push_warning("Director.try_use_ability() — STUB.")
	return false

func get_remaining_mana() -> int:
	return 0

func get_cooldown(_ability_name: String) -> float:
	return 0.0
