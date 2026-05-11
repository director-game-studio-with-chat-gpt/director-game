extends Node
## World — autoloaded world manager.
##
## Owned by Devin-6 (World + Map 1). See docs/architecture.md.
##
## Tracks the active map, all rooms/doors/walls/items, and exposes the public
## query/mutation API used by the Director module to reshape geometry at runtime.

signal wall_moved(wall_id: String)
signal door_created(door_id: String)
signal map_loaded(map_name: String)

var _rooms_by_id: Dictionary = {}
var _doors_by_id: Dictionary = {}
var _walls_by_id: Dictionary = {}
var _items_by_id: Dictionary = {}
var _current_map: Node3D = null
var _current_map_name: String = ""

func _ready() -> void:
	pass

## Looks up the room containing a world-space position.
## Returns `null` if no room contains that point.
func get_room_at(world_position: Vector3) -> Node:
	for room in _rooms_by_id.values():
		if room == null or not is_instance_valid(room):
			continue
		if room.has_method("contains_point") and room.contains_point(world_position):
			return room
	return null

func get_room(room_id: String) -> Node:
	if _rooms_by_id.has(room_id):
		return _rooms_by_id[room_id]
	return null

func get_door(door_id: String) -> Node:
	if _doors_by_id.has(door_id):
		return _doors_by_id[door_id]
	return null

func get_wall(wall_id: String) -> Node:
	if _walls_by_id.has(wall_id):
		return _walls_by_id[wall_id]
	return null

func get_item(item_id: String) -> Node:
	if _items_by_id.has(item_id):
		return _items_by_id[item_id]
	return null

func list_rooms() -> Array:
	return _rooms_by_id.keys()

func list_doors() -> Array:
	return _doors_by_id.keys()

func list_walls() -> Array:
	return _walls_by_id.keys()

func get_current_map_name() -> String:
	return _current_map_name

func get_current_map() -> Node3D:
	return _current_map

## Moves a wall to a new transform over `duration` seconds (linear).
## The Director uses this for the "Move Wall" ability. `wall_moved` is emitted
## only after the animation actually completes — for `duration > 0` that's at
## the end of the tween, not when this call returns.
func move_wall(wall_id: String, new_transform: Transform3D, duration: float) -> void:
	var wall: Node = get_wall(wall_id)
	if wall == null:
		push_warning("World.move_wall: unknown wall '%s'" % wall_id)
		return
	if wall is Node3D and wall.has_method("animate_to_transform") and wall.has_signal("moved"):
		wall.moved.connect(_on_wall_moved.bind(wall_id), CONNECT_ONE_SHOT)
		wall.animate_to_transform(new_transform, duration)
		return
	if wall is Node3D:
		(wall as Node3D).transform = new_transform
	wall_moved.emit(wall_id)

func _on_wall_moved(_new_transform: Transform3D, wall_id: String) -> void:
	wall_moved.emit(wall_id)

## Swaps the destinations of two existing doors. Each door records which room
## it leads to; after this call door A leads where door B used to lead and
## vice versa. Used by Director's "Swap Doors" ability.
func swap_doors(door_a_id: String, door_b_id: String) -> void:
	var a: Node = get_door(door_a_id)
	var b: Node = get_door(door_b_id)
	if a == null or b == null:
		push_warning("World.swap_doors: unknown door(s) '%s' / '%s'" % [door_a_id, door_b_id])
		return
	if not (a.has_method("get_leads_to") and b.has_method("get_leads_to")):
		push_warning("World.swap_doors: door scripts missing get_leads_to")
		return
	var a_to: String = a.get_leads_to()
	var b_to: String = b.get_leads_to()
	a.set_leads_to(b_to)
	b.set_leads_to(a_to)

## Creates a new door in the given wall at the given position. The door is
## registered with World and added to the current map. Used by Director's
## "Create Door" ability. Returns the new door (or null on failure).
func create_door(wall_id: String, door_position: Vector3, leads_to_room_id: String) -> Node:
	var wall: Node = get_wall(wall_id)
	if wall == null:
		push_warning("World.create_door: unknown wall '%s'" % wall_id)
		return null
	if _current_map == null:
		push_warning("World.create_door: no map loaded")
		return null
	var DoorScript: Script = load("res://src/world/door.gd")
	var door: Node = DoorScript.new()
	door.name = "Door_%d" % (_doors_by_id.size() + 1)
	if door.has_method("setup"):
		door.setup(door.name, leads_to_room_id, wall_id)
	if door is Node3D:
		(door as Node3D).position = door_position
	_current_map.add_child(door)
	register_door(door)
	door_created.emit(door.name)
	return door

## Loads a map by name. Map name should match a file in `scenes/main/`,
## e.g. "map_1_childhood_home". Returns true on success. Registration of the
## map's rooms/doors/walls and the `map_loaded` signal are both deferred to
## the map instance's `ready` signal — procedural maps (like Map 1) build
## their geometry in `_ready()`, so we must wait until after that runs.
func load_map(map_name: String) -> bool:
	_clear_current_map()
	var instance: Node3D = MapLoader.instantiate_map(map_name)
	if instance == null:
		return false
	_current_map = instance
	_current_map_name = map_name
	instance.ready.connect(_on_current_map_ready.bind(map_name), CONNECT_ONE_SHOT)
	get_tree().get_root().call_deferred("add_child", instance)
	return true

func _on_current_map_ready(map_name: String) -> void:
	if _current_map == null or not is_instance_valid(_current_map):
		return
	_register_map_contents(_current_map)
	map_loaded.emit(map_name)

## Removes the current map from the tree and clears all registries.
func unload_map() -> void:
	_clear_current_map()

func _clear_current_map() -> void:
	_rooms_by_id.clear()
	_doors_by_id.clear()
	_walls_by_id.clear()
	_items_by_id.clear()
	if _current_map != null and is_instance_valid(_current_map):
		_current_map.queue_free()
	_current_map = null
	_current_map_name = ""

## Walks the loaded map tree and registers every Room, Wall, Door, Item it
## finds. Modules in other folders use the autoload to find these objects.
func _register_map_contents(root: Node) -> void:
	for node in _walk_tree(root):
		match _classify_node(node):
			"room":
				register_room(node)
			"wall":
				register_wall(node)
			"door":
				register_door(node)
			"item":
				register_item(node)
			_:
				pass

func _walk_tree(root: Node) -> Array[Node]:
	var out: Array[Node] = []
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		out.append(n)
		for child in n.get_children():
			stack.append(child)
	return out

func _classify_node(node: Node) -> String:
	# Use script class_name if available (the room/wall/door scripts set it).
	var script: Script = node.get_script() as Script
	if script != null:
		var cn: StringName = script.get_global_name()
		if cn == &"Room":
			return "room"
		if cn == &"Wall":
			return "wall"
		if cn == &"Door":
			return "door"
		if cn == &"Item" or cn == &"Artifact":
			return "item"
	# Fallback: name prefix (so authored scenes work even without scripts)
	var nm: String = node.name
	if nm.begins_with("Room_"):
		return "room"
	if nm.begins_with("Wall_"):
		return "wall"
	if nm.begins_with("Door_"):
		return "door"
	if nm.begins_with("Item_") or nm.begins_with("Artifact_"):
		return "item"
	return ""

## Public registration helpers — used by map scripts to add procedurally-built
## rooms/walls/doors after they've spawned the geometry.
func register_room(room: Node) -> void:
	var id: String = _resolve_id(room)
	if id == "":
		push_warning("World.register_room: skipping unnamed room")
		return
	_rooms_by_id[id] = room

func register_wall(wall: Node) -> void:
	var id: String = _resolve_id(wall)
	if id == "":
		return
	_walls_by_id[id] = wall

func register_door(door: Node) -> void:
	var id: String = _resolve_id(door)
	if id == "":
		return
	_doors_by_id[id] = door

func register_item(item: Node) -> void:
	var id: String = _resolve_id(item)
	if id == "":
		return
	_items_by_id[id] = item

func _resolve_id(node: Node) -> String:
	if node == null:
		return ""
	if node.has_method("get_id"):
		var maybe_id: String = node.get_id()
		if maybe_id != "":
			return maybe_id
	return node.name

## Used by tests to start from a known-empty state.
func reset() -> void:
	_clear_current_map()
