extends Node
## World — autoloaded world manager.
##
## Owned by Devin-10. STUB: full implementation in Issue #10.

func get_room_at(_position: Vector3):
	push_warning("World.get_room_at() — STUB.")
	return null

func get_door(_door_id: String):
	push_warning("World.get_door() — STUB.")
	return null

func move_wall(_wall_id: String, _new_transform: Transform3D, _duration: float) -> void:
	push_warning("World.move_wall() — STUB.")

func swap_doors(_door_a_id: String, _door_b_id: String) -> void:
	push_warning("World.swap_doors() — STUB.")

func create_door(_wall_id: String, _position: Vector3, _leads_to_room_id: String):
	push_warning("World.create_door() — STUB.")
	return null
