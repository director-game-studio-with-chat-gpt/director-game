extends "res://addons/gut/test.gd"
## Tests for the World autoload (src/world/world.gd) plus the Room / Wall /
## Door / Item / Artifact scripts.

const RoomScript: Script = preload("res://src/world/room.gd")
const WallScript: Script = preload("res://src/world/wall.gd")
const DoorScript: Script = preload("res://src/world/door.gd")
const ItemScript: Script = preload("res://src/world/item.gd")
const ArtifactScript: Script = preload("res://src/world/artifact.gd")

func after_each() -> void:
	World.reset()

# ---------- World registry ----------

func test_world_initially_empty() -> void:
	World.reset()
	assert_eq(World.list_rooms().size(), 0, "No rooms after reset")
	assert_eq(World.list_doors().size(), 0)
	assert_eq(World.list_walls().size(), 0)
	assert_eq(World.get_current_map_name(), "")

func test_register_room_lookup_by_id() -> void:
	var room: Node3D = Node3D.new()
	room.set_script(RoomScript)
	room.name = "Room_living_room"
	room.set("room_id", "living_room")
	add_child_autofree(room)

	World.register_room(room)
	assert_eq(World.get_room("living_room"), room)
	assert_eq(World.list_rooms().size(), 1)

func test_register_door_and_swap() -> void:
	var a: Node3D = Node3D.new()
	a.set_script(DoorScript)
	a.name = "Door_A"
	a.set("door_id", "door_a")
	a.set("leads_to_room_id", "kitchen")
	add_child_autofree(a)
	World.register_door(a)

	var b: Node3D = Node3D.new()
	b.set_script(DoorScript)
	b.name = "Door_B"
	b.set("door_id", "door_b")
	b.set("leads_to_room_id", "cellar")
	add_child_autofree(b)
	World.register_door(b)

	World.swap_doors("door_a", "door_b")
	assert_eq(a.get_leads_to(), "cellar", "Door A should now lead where B used to")
	assert_eq(b.get_leads_to(), "kitchen")

func test_register_wall_and_move() -> void:
	var wall: StaticBody3D = StaticBody3D.new()
	wall.set_script(WallScript)
	wall.name = "Wall_test"
	wall.set("wall_id", "wall_test")
	add_child_autofree(wall)
	World.register_wall(wall)

	var target: Transform3D = Transform3D(Basis.IDENTITY, Vector3(5, 0, 0))
	var moved_count: Array[String] = []
	World.wall_moved.connect(func(id: String) -> void: moved_count.append(id))
	World.move_wall("wall_test", target, 0.0)
	assert_eq(moved_count.size(), 1)
	assert_eq(moved_count[0], "wall_test")
	assert_eq(wall.transform.origin, target.origin)

func test_move_wall_unknown_id_warns_no_crash() -> void:
	# Should warn and bail without crashing. Just verifying it returns.
	World.move_wall("does_not_exist", Transform3D.IDENTITY, 0.0)
	assert_eq(World.get_wall("does_not_exist"), null, "Unknown wall stays unregistered")

func test_move_wall_called_twice_emits_only_once() -> void:
	# Regression: calling move_wall on the same wall while a tween is still
	# in progress used to accumulate stale CONNECT_ONE_SHOT callbacks; when
	# the latest tween completed, wall_moved fired once per accumulated call.
	var wall: StaticBody3D = StaticBody3D.new()
	wall.set_script(WallScript)
	wall.name = "Wall_double"
	wall.set("wall_id", "wall_double")
	add_child_autofree(wall)
	World.register_wall(wall)

	var fired: Array[String] = []
	World.wall_moved.connect(func(id: String) -> void: fired.append(id))
	var t1: Transform3D = Transform3D(Basis.IDENTITY, Vector3(3, 0, 0))
	var t2: Transform3D = Transform3D(Basis.IDENTITY, Vector3(7, 0, 0))
	World.move_wall("wall_double", t1, 0.1)
	# Re-issue while the first tween is still mid-air.
	World.move_wall("wall_double", t2, 0.1)
	assert_eq(fired.size(), 0, "neither call has completed yet")
	await get_tree().create_timer(0.25).timeout
	assert_eq(fired.size(), 1,
		"wall_moved must fire exactly once even when move_wall is re-issued mid-tween")
	assert_eq(fired[0], "wall_double")
	assert_eq(wall.transform.origin, t2.origin,
		"second target wins; transform reflects latest call")

func test_move_wall_with_duration_emits_after_completion() -> void:
	var wall: StaticBody3D = StaticBody3D.new()
	wall.set_script(WallScript)
	wall.name = "Wall_async"
	wall.set("wall_id", "wall_async")
	add_child_autofree(wall)
	World.register_wall(wall)

	var fired: Array[String] = []
	World.wall_moved.connect(func(id: String) -> void: fired.append(id))
	var target: Transform3D = Transform3D(Basis.IDENTITY, Vector3(9, 0, 0))
	World.move_wall("wall_async", target, 0.1)

	# wall_moved must NOT have fired yet — the tween is in progress.
	assert_eq(fired.size(), 0, "wall_moved is deferred until tween completes")
	await get_tree().create_timer(0.25).timeout
	assert_eq(fired.size(), 1, "wall_moved fires after tween completes")
	assert_eq(fired[0], "wall_async")
	assert_eq(wall.transform.origin, target.origin)

# ---------- Room contains_point ----------

func test_room_contains_point() -> void:
	var room: Node3D = Node3D.new()
	room.set_script(RoomScript)
	room.set("half_extents", Vector3(3, 1.5, 3))
	room.position = Vector3(10, 0, 10)
	add_child_autofree(room)

	assert_true(room.contains_point(Vector3(10, 0, 10)), "Center is inside")
	assert_true(room.contains_point(Vector3(12, 0, 12)), "Edge is inside")
	assert_false(room.contains_point(Vector3(20, 0, 10)), "Far away is outside")
	assert_false(room.contains_point(Vector3(10, 0, 20)))

func test_get_room_at_uses_contains_point() -> void:
	var room: Node3D = Node3D.new()
	room.set_script(RoomScript)
	room.set("room_id", "kitchen")
	room.set("half_extents", Vector3(3, 1.5, 3))
	room.position = Vector3(10, 0, 10)
	add_child_autofree(room)
	World.register_room(room)

	var hit: Node = World.get_room_at(Vector3(10, 0, 10))
	assert_eq(hit, room)
	assert_eq(World.get_room_at(Vector3(100, 0, 100)), null)

# ---------- Door state ----------

func test_door_locks_unlocks() -> void:
	var door: Node3D = Node3D.new()
	door.set_script(DoorScript)
	door.set("is_locked", false)
	add_child_autofree(door)

	assert_true(door.open(null), "Unlocked door opens")
	door.lock()
	assert_false(door.open(null), "Locked door refuses to open")
	door.unlock()
	assert_true(door.open(null))

func test_door_leads_to_signal() -> void:
	var door: Node3D = Node3D.new()
	door.set_script(DoorScript)
	door.set("leads_to_room_id", "foo")
	add_child_autofree(door)

	var changes: Array[String] = []
	door.leads_to_changed.connect(func(r: String) -> void: changes.append(r))
	door.set_leads_to("bar")
	assert_eq(changes.size(), 1)
	assert_eq(changes[0], "bar")
	assert_eq(door.get_leads_to(), "bar")

# ---------- Item / Artifact ----------

func test_item_pickup_drop() -> void:
	var item: Node3D = Node3D.new()
	item.set_script(ItemScript)
	add_child_autofree(item)

	var holder: Node = Node.new()
	add_child_autofree(holder)
	assert_true(item.can_be_picked_up_by(holder))
	item.mark_picked_up(holder)
	assert_eq(item.get_holder(), holder)
	assert_false(item.can_be_picked_up_by(holder))
	item.mark_dropped(Vector3(1, 2, 3))
	assert_eq(item.get_holder(), null)
	assert_eq(item.global_transform.origin, Vector3(1, 2, 3))

func test_artifact_valid_kinds() -> void:
	var a: Node3D = Node3D.new()
	a.set_script(ArtifactScript)
	a.set("artifact_kind", Artifact.KIND_SKULL)
	add_child_autofree(a)
	assert_true(a.is_artifact())
	assert_true(Artifact.VALID_KINDS.has(Artifact.KIND_SKULL))
	assert_true(Artifact.VALID_KINDS.has(Artifact.KIND_PHOTOGRAPH))
	assert_true(Artifact.VALID_KINDS.has(Artifact.KIND_KEY))
	assert_eq(Artifact.VALID_KINDS.size(), 3)
