class_name Room extends Node3D
## Room — a logical room in the house.
##
## Each Room owns its floor mesh, ceiling, walls, lights and any spawned
## items. World queries rooms via `World.get_room_at(position)` which calls
## `contains_point()` on each registered Room.
##
## Authored either:
##   - in code by the map script (procedural placeholder geometry), or
##   - in the editor as a child of the map scene with this script attached.

signal entered_by(player: Node)
signal exited_by(player: Node)

@export var room_id: String = ""
@export var display_name: String = ""
@export var floor_index: int = 0
## Half-extents of the room (XYZ), in world units. Used by contains_point and
## by the placeholder generator to size the floor / walls.
@export var half_extents: Vector3 = Vector3(3.0, 1.5, 3.0)
## Whether the Director is allowed to remove or move walls of this room.
## Foyer and Main Exit have this set to false.
@export var is_fixed: bool = false
## If true this room is outdoors (no ceiling, brighter ambient).
@export var is_outdoor: bool = false
## Optional spawn marker for artifacts. The map script populates these.
@export var artifact_spawn_priority: int = 0

func _ready() -> void:
	pass

func get_id() -> String:
	if room_id != "":
		return room_id
	return name

## Returns true if `world_pos` is within this room's AABB (in world space).
func contains_point(world_pos: Vector3) -> bool:
	var local: Vector3 = to_local(world_pos)
	return (
		absf(local.x) <= half_extents.x
		and absf(local.y) <= half_extents.y
		and absf(local.z) <= half_extents.z
	)

func get_center_world() -> Vector3:
	return global_transform.origin

func get_aabb_world() -> AABB:
	var origin: Vector3 = global_transform.origin
	var extents: Vector3 = half_extents
	return AABB(origin - extents, extents * 2.0)
