@tool
class_name Map1ChildhoodHome extends Node3D
## Map 1: The Childhood Home — placeholder geometry.
##
## A 2-floor Victorian-style home with 12 rooms. This script builds the
## geometry procedurally on `_ready()` so future iterations can iterate by
## editing the room table below rather than wrangling hundreds of mesh nodes
## in the editor.
##
## Reference: docs/GDD.md §8 Map 1, Issue #7.
##
## To swap a room for a hand-authored .tscn, edit `ROOMS` and replace the
## entry's `procedural=true` with a packed scene reference.

const RoomScript: Script = preload("res://src/world/room.gd")
const WallScript: Script = preload("res://src/world/wall.gd")
const DoorScript: Script = preload("res://src/world/door.gd")
const ArtifactScript: Script = preload("res://src/world/artifact.gd")

const WALL_HEIGHT: float = 3.0
const WALL_THICKNESS: float = 0.2
const FLOOR_THICKNESS: float = 0.1
const FLOOR_GAP_Y: float = 3.2

# Each room: id, display_name, floor_index, grid position (col, row), size (w, d),
# is_fixed (Director can't remove walls), is_outdoor.
const ROOMS: Array = [
	# Floor 0 (ground)
	{"id": "foyer",       "name": "Foyer",       "floor": 0, "cell": Vector2i(0, 0), "size": Vector2(6, 6), "fixed": true,  "outdoor": false},
	{"id": "living_room", "name": "Living Room", "floor": 0, "cell": Vector2i(0, 1), "size": Vector2(6, 6), "fixed": false, "outdoor": false},
	{"id": "kitchen",     "name": "Kitchen",     "floor": 0, "cell": Vector2i(1, 1), "size": Vector2(6, 6), "fixed": false, "outdoor": false},
	{"id": "hallway1",    "name": "Hallway 1",   "floor": 0, "cell": Vector2i(1, 0), "size": Vector2(6, 6), "fixed": false, "outdoor": false},
	{"id": "bathroom",    "name": "Bathroom",    "floor": 0, "cell": Vector2i(2, 1), "size": Vector2(4, 6), "fixed": false, "outdoor": false},
	{"id": "cellar",      "name": "Cellar",      "floor": 0, "cell": Vector2i(-1, 1), "size": Vector2(5, 6), "fixed": false, "outdoor": false},
	{"id": "stairwell",   "name": "Stairwell",   "floor": 0, "cell": Vector2i(2, 0), "size": Vector2(4, 6), "fixed": true,  "outdoor": false},
	{"id": "main_exit",   "name": "Main Exit",   "floor": 0, "cell": Vector2i(3, 0), "size": Vector2(5, 6), "fixed": true,  "outdoor": false},
	{"id": "garden",      "name": "Garden",      "floor": 0, "cell": Vector2i(3, 1), "size": Vector2(5, 6), "fixed": false, "outdoor": true},

	# Floor 1 (upper)
	{"id": "hallway2",    "name": "Hallway 2",   "floor": 1, "cell": Vector2i(1, 0), "size": Vector2(6, 6), "fixed": false, "outdoor": false},
	{"id": "bedroom",     "name": "Bedroom",     "floor": 1, "cell": Vector2i(0, 0), "size": Vector2(6, 6), "fixed": false, "outdoor": false},
	{"id": "attic",       "name": "Attic",       "floor": 1, "cell": Vector2i(2, 0), "size": Vector2(6, 6), "fixed": false, "outdoor": false},
]

# Each door: from room id, to room id, optional locked
const DOORS: Array = [
	{"a": "foyer",       "b": "hallway1",    "main_exit": false, "locked": false},
	{"a": "hallway1",    "b": "living_room", "main_exit": false, "locked": false},
	{"a": "hallway1",    "b": "kitchen",     "main_exit": false, "locked": false},
	{"a": "hallway1",    "b": "stairwell",   "main_exit": false, "locked": false},
	{"a": "kitchen",     "b": "bathroom",    "main_exit": false, "locked": false},
	{"a": "living_room", "b": "cellar",      "main_exit": false, "locked": true},
	{"a": "stairwell",   "b": "main_exit",   "main_exit": true,  "locked": true},
	{"a": "main_exit",   "b": "garden",      "main_exit": false, "locked": false},
	{"a": "stairwell",   "b": "hallway2",    "main_exit": false, "locked": false},
	{"a": "hallway2",    "b": "bedroom",     "main_exit": false, "locked": false},
	{"a": "hallway2",    "b": "attic",       "main_exit": false, "locked": false},
]

# Artifact spawns. Each binds an artifact kind to a room. Per GDD §5, 3 artifacts.
const ARTIFACT_SPAWNS: Array = [
	{"kind": Artifact.KIND_SKULL,       "room": "cellar"},
	{"kind": Artifact.KIND_PHOTOGRAPH,  "room": "attic"},
	{"kind": Artifact.KIND_KEY,         "room": "bedroom"},
]

# Where each Escapist starts. Up to 4 spawn points; the Foyer is the primary.
const SPAWN_POINTS: Array = [
	{"room": "foyer",   "offset": Vector3(-1.5, 0, -1.5)},
	{"room": "foyer",   "offset": Vector3( 1.5, 0, -1.5)},
	{"room": "foyer",   "offset": Vector3(-1.5, 0,  1.5)},
	{"room": "foyer",   "offset": Vector3( 1.5, 0,  1.5)},
]

const CELL_SIZE: float = 6.0

var _room_nodes: Dictionary = {}
var _wall_counter: int = 0
var _door_counter: int = 0
var _floor_material: StandardMaterial3D = null
var _wall_material: StandardMaterial3D = null
var _ceiling_material: StandardMaterial3D = null
var _outdoor_floor_material: StandardMaterial3D = null

func _ready() -> void:
	_build_materials()
	_build_rooms()
	_build_doors()
	_build_artifacts()
	_build_spawn_points()
	_build_environment_light()
	_register_with_world()

func _build_materials() -> void:
	_floor_material = StandardMaterial3D.new()
	_floor_material.albedo_color = Color(0.32, 0.22, 0.16)
	_wall_material = StandardMaterial3D.new()
	_wall_material.albedo_color = Color(0.45, 0.42, 0.36)
	_ceiling_material = StandardMaterial3D.new()
	_ceiling_material.albedo_color = Color(0.28, 0.26, 0.24)
	_outdoor_floor_material = StandardMaterial3D.new()
	_outdoor_floor_material.albedo_color = Color(0.18, 0.32, 0.18)

func _build_rooms() -> void:
	var rooms_root: Node3D = Node3D.new()
	rooms_root.name = "Rooms"
	add_child(rooms_root)
	for data in ROOMS:
		var room: Node3D = _build_one_room(data)
		rooms_root.add_child(room)
		_room_nodes[data["id"]] = room

func _build_one_room(data: Dictionary) -> Node3D:
	var room: Node3D = Node3D.new()
	room.set_script(RoomScript)
	room.name = "Room_%s" % data["id"]
	room.set("room_id", data["id"])
	room.set("display_name", data["name"])
	room.set("floor_index", data["floor"])
	room.set("is_fixed", data["fixed"])
	room.set("is_outdoor", data["outdoor"])

	var size: Vector2 = data["size"]
	var half_extents: Vector3 = Vector3(size.x * 0.5, WALL_HEIGHT * 0.5, size.y * 0.5)
	room.set("half_extents", half_extents)

	var cell: Vector2i = data["cell"]
	var world_x: float = float(cell.x) * CELL_SIZE
	var world_z: float = float(cell.y) * CELL_SIZE
	var world_y: float = float(data["floor"]) * FLOOR_GAP_Y
	room.position = Vector3(world_x, world_y, world_z)

	_add_floor(room, size, data["outdoor"])
	if not data["outdoor"]:
		_add_ceiling(room, size)
	_add_walls(room, size, data)
	return room

func _add_floor(room: Node3D, size: Vector2, outdoor: bool) -> void:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.name = "Floor"
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(size.x, FLOOR_THICKNESS, size.y)
	mesh.mesh = box
	if outdoor:
		mesh.material_override = _outdoor_floor_material
	else:
		mesh.material_override = _floor_material
	mesh.position = Vector3(0, -WALL_HEIGHT * 0.5 - FLOOR_THICKNESS * 0.5, 0)
	room.add_child(mesh)

func _add_ceiling(room: Node3D, size: Vector2) -> void:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.name = "Ceiling"
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(size.x, FLOOR_THICKNESS, size.y)
	mesh.mesh = box
	mesh.material_override = _ceiling_material
	mesh.position = Vector3(0, WALL_HEIGHT * 0.5 + FLOOR_THICKNESS * 0.5, 0)
	room.add_child(mesh)

func _add_walls(room: Node3D, size: Vector2, room_data: Dictionary) -> void:
	# Skip walls for outdoor "rooms" — they're really markers for the garden area.
	if room_data["outdoor"]:
		return
	var walls_root: Node3D = Node3D.new()
	walls_root.name = "Walls"
	room.add_child(walls_root)

	var hx: float = size.x * 0.5
	var hz: float = size.y * 0.5
	# (offset, dims, name_suffix)
	var specs: Array = [
		[Vector3(0,  0, -hz), Vector3(size.x, WALL_HEIGHT, WALL_THICKNESS), "N"],
		[Vector3(0,  0,  hz), Vector3(size.x, WALL_HEIGHT, WALL_THICKNESS), "S"],
		[Vector3(-hx, 0, 0),  Vector3(WALL_THICKNESS, WALL_HEIGHT, size.y), "W"],
		[Vector3( hx, 0, 0),  Vector3(WALL_THICKNESS, WALL_HEIGHT, size.y), "E"],
	]
	for spec in specs:
		var offset: Vector3 = spec[0]
		var dims: Vector3 = spec[1]
		var suffix: String = spec[2]
		_wall_counter += 1
		var wall: StaticBody3D = StaticBody3D.new()
		wall.set_script(WallScript)
		wall.name = "Wall_%s_%s" % [room_data["id"], suffix]
		wall.set("wall_id", wall.name)
		wall.set("room_a_id", room_data["id"])
		wall.set("is_movable", not room_data["fixed"])
		wall.set("dimensions", dims)
		wall.position = offset

		var mesh: MeshInstance3D = MeshInstance3D.new()
		mesh.name = "Mesh"
		var box: BoxMesh = BoxMesh.new()
		box.size = dims
		mesh.mesh = box
		mesh.material_override = _wall_material
		wall.add_child(mesh)

		var coll: CollisionShape3D = CollisionShape3D.new()
		coll.name = "Collision"
		var shape: BoxShape3D = BoxShape3D.new()
		shape.size = dims
		coll.shape = shape
		wall.add_child(coll)

		walls_root.add_child(wall)

func _build_doors() -> void:
	var doors_root: Node3D = Node3D.new()
	doors_root.name = "Doors"
	add_child(doors_root)
	for data in DOORS:
		var a: Node3D = _room_nodes.get(data["a"]) as Node3D
		var b: Node3D = _room_nodes.get(data["b"]) as Node3D
		if a == null or b == null:
			push_warning("Map1: door references missing room (%s -> %s)" % [data["a"], data["b"]])
			continue
		_door_counter += 1
		var door: Node3D = Node3D.new()
		door.set_script(DoorScript)
		door.name = "Door_%s_to_%s" % [data["a"], data["b"]]
		door.set("door_id", door.name)
		door.set("room_a_id", data["a"])
		door.set("room_b_id", data["b"])
		door.set("leads_to_room_id", data["b"])
		door.set("is_locked", data["locked"])
		door.set("is_main_exit", data["main_exit"])
		# Place the door at the midpoint between the two room centers.
		door.position = (a.position + b.position) * 0.5
		var mesh: MeshInstance3D = MeshInstance3D.new()
		mesh.name = "Mesh"
		var box: BoxMesh = BoxMesh.new()
		box.size = Vector3(1.2, 2.4, 0.1)
		mesh.mesh = box
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		if data["main_exit"]:
			mat.albedo_color = Color(0.95, 0.85, 0.4)
		elif data["locked"]:
			mat.albedo_color = Color(0.5, 0.18, 0.18)
		else:
			mat.albedo_color = Color(0.3, 0.2, 0.12)
		mesh.material_override = mat
		mesh.position = Vector3(0, -WALL_HEIGHT * 0.5 + 1.2, 0)
		door.add_child(mesh)
		doors_root.add_child(door)

func _build_artifacts() -> void:
	var artifacts_root: Node3D = Node3D.new()
	artifacts_root.name = "Artifacts"
	add_child(artifacts_root)
	for data in ARTIFACT_SPAWNS:
		var room: Node3D = _room_nodes.get(data["room"]) as Node3D
		if room == null:
			push_warning("Map1: artifact spawn references missing room '%s'" % data["room"])
			continue
		var marker: Marker3D = Marker3D.new()
		marker.name = "ArtifactSpawn_%s" % data["kind"]
		marker.position = room.position + Vector3(0, -WALL_HEIGHT * 0.5 + 1.0, 0)
		artifacts_root.add_child(marker)

		var artifact: Node3D = Node3D.new()
		artifact.set_script(ArtifactScript)
		artifact.name = "Artifact_%s" % data["kind"]
		artifact.set("item_id", "artifact_%s" % data["kind"])
		artifact.set("display_name", String(data["kind"]).capitalize())
		artifact.set("artifact_kind", data["kind"])
		artifact.position = marker.position
		# Visible cube placeholder so dev can see it in the editor.
		var mesh: MeshInstance3D = MeshInstance3D.new()
		mesh.name = "Mesh"
		var box: BoxMesh = BoxMesh.new()
		box.size = Vector3(0.4, 0.4, 0.4)
		mesh.mesh = box
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = Color(0.9, 0.7, 0.2)
		mat.emission_enabled = true
		mat.emission = Color(0.6, 0.45, 0.1)
		mesh.material_override = mat
		artifact.add_child(mesh)
		artifacts_root.add_child(artifact)

func _build_spawn_points() -> void:
	var spawns_root: Node3D = Node3D.new()
	spawns_root.name = "SpawnPoints"
	add_child(spawns_root)
	var idx: int = 0
	for data in SPAWN_POINTS:
		var room: Node3D = _room_nodes.get(data["room"]) as Node3D
		if room == null:
			continue
		var marker: Marker3D = Marker3D.new()
		marker.name = "EscapistSpawn_%d" % idx
		marker.position = room.position + (data["offset"] as Vector3) + Vector3(0, -WALL_HEIGHT * 0.5 + 0.5, 0)
		spawns_root.add_child(marker)
		idx += 1

func _build_environment_light() -> void:
	# Just enough light so the placeholder geometry is visible. Final lighting
	# lives in src/shaders/ (Devin-7) and is applied per-scene.
	if get_node_or_null("DirectionalLight") != null:
		return
	var light: DirectionalLight3D = DirectionalLight3D.new()
	light.name = "DirectionalLight"
	light.position = Vector3(0, 12, 0)
	light.rotation = Vector3(-1.0, 0.4, 0)
	light.light_energy = 0.6
	light.shadow_enabled = true
	add_child(light)

## Pushes all created rooms/walls/doors/items into the World autoload so
## other modules can query them. Safe to call multiple times.
func _register_with_world() -> void:
	# In @tool mode we run inside the editor without autoloads, so skip
	# registration during a tool-edit cycle.
	if Engine.is_editor_hint():
		return
	var world_node: Node = get_node_or_null("/root/World")
	if world_node == null:
		return
	for child in _walk(self):
		if not (child is Node):
			continue
		var script: Script = child.get_script() as Script
		if script == null:
			continue
		var cn: StringName = script.get_global_name()
		match cn:
			&"Room":
				world_node.call("register_room", child)
			&"Wall":
				world_node.call("register_wall", child)
			&"Door":
				world_node.call("register_door", child)
			&"Item", &"Artifact":
				world_node.call("register_item", child)
			_:
				pass

func _walk(root: Node) -> Array[Node]:
	var out: Array[Node] = []
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		out.append(n)
		for child in n.get_children():
			stack.append(child)
	return out

## Static helper so tests can verify the room table without instantiating the
## whole map. Returns the room metadata as declared above.
static func get_room_table() -> Array:
	return ROOMS

static func get_door_table() -> Array:
	return DOORS

static func get_artifact_spawn_table() -> Array:
	return ARTIFACT_SPAWNS
