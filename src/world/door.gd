class_name Door extends Node3D
## Door — a door connecting two rooms. Tracks which room it leads into.
##
## Doors can be locked/unlocked by the Director (`Open/Close Door` ability)
## and swapped with another door (`Swap Doors` ability). The Director can
## also `create_door()` at runtime, in which case a new Door is spawned by
## `World.create_door()`.

signal opened(by: Node)
signal closed(by: Node)
signal leads_to_changed(new_room_id: String)

@export var door_id: String = ""
@export var room_a_id: String = ""
@export var room_b_id: String = ""
## The room a player ends up in when they walk through this door.
## Normally equals `room_b_id`, but can be reassigned by `swap_doors`.
@export var leads_to_room_id: String = ""
@export var is_locked: bool = false
@export var is_main_exit: bool = false
@export var parent_wall_id: String = ""

func _ready() -> void:
	if leads_to_room_id == "":
		leads_to_room_id = room_b_id

func get_id() -> String:
	if door_id != "":
		return door_id
	return name

func get_leads_to() -> String:
	return leads_to_room_id

func set_leads_to(room_id: String) -> void:
	leads_to_room_id = room_id
	leads_to_changed.emit(room_id)

func open(by: Node = null) -> bool:
	if is_locked:
		return false
	opened.emit(by)
	return true

func close(by: Node = null) -> void:
	closed.emit(by)

func lock() -> void:
	is_locked = true

func unlock() -> void:
	is_locked = false

## Convenience used by World.create_door when spawning at runtime.
func setup(id: String, leads_to: String, wall_id: String) -> void:
	door_id = id
	leads_to_room_id = leads_to
	parent_wall_id = wall_id
