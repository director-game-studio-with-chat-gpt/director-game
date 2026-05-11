class_name Item extends Node3D
## Item — a pickup-able object in the world.
##
## Base class for artifacts, keys, weapons, batteries, etc. The Player
## module is responsible for actually picking these up (`escapist.pick_up_item`).

signal picked_up(by: Node)
signal dropped(at_position: Vector3)

@export var item_id: String = ""
@export var display_name: String = ""
@export var is_pickable: bool = true

var _holder: Node = null

func _ready() -> void:
	pass

func get_id() -> String:
	if item_id != "":
		return item_id
	return name

func can_be_picked_up_by(_who: Node) -> bool:
	return is_pickable and _holder == null

func mark_picked_up(by: Node) -> void:
	_holder = by
	picked_up.emit(by)

func mark_dropped(at_position: Vector3) -> void:
	_holder = null
	global_transform.origin = at_position
	dropped.emit(at_position)

func get_holder() -> Node:
	return _holder
