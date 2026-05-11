extends "res://addons/gut/test.gd"
## Tests for MapLoader plus the Map 1 room/door tables.

const MapLoaderScript: Script = preload("res://src/world/map_loader.gd")
const Map1Script: Script = preload("res://src/world/map_1_childhood_home.gd")

# ---------- MapLoader ----------

func test_resolve_scene_path() -> void:
	assert_eq(
		MapLoader.resolve_scene_path("map_1_childhood_home"),
		"res://scenes/main/map_1_childhood_home.tscn"
	)

func test_map_exists_true_for_map_1() -> void:
	assert_true(MapLoader.map_exists("map_1_childhood_home"), "Map 1 scene must exist")

func test_map_exists_false_for_garbage() -> void:
	assert_false(MapLoader.map_exists("definitely_not_a_real_map_999"))

func test_list_known_maps_contains_map_1() -> void:
	var maps: Array[String] = MapLoader.list_known_maps()
	assert_true(maps.has("map_1_childhood_home"), "list_known_maps must surface Map 1")

func test_instantiate_map_returns_node3d() -> void:
	var inst: Node3D = MapLoader.instantiate_map("map_1_childhood_home")
	assert_not_null(inst, "Map 1 must instantiate")
	if inst != null:
		add_child_autofree(inst)
		assert_true(inst is Node3D)

func test_instantiate_unknown_map_returns_null() -> void:
	var inst: Node3D = MapLoader.instantiate_map("does_not_exist")
	assert_eq(inst, null)

# ---------- World.load_map integration ----------

func test_world_load_map_registers_contents_before_signal() -> void:
	World.reset()
	var rooms_when_emitted: Array[int] = []
	var doors_when_emitted: Array[int] = []
	var names_emitted: Array[String] = []
	World.map_loaded.connect(func(n: String) -> void:
		names_emitted.append(n)
		rooms_when_emitted.append(World.list_rooms().size())
		doors_when_emitted.append(World.list_doors().size())
	)

	var ok: bool = World.load_map("map_1_childhood_home")
	assert_true(ok, "load_map must succeed for a known map")

	# load_map adds the instance via call_deferred; wait two frames so that
	# add_child runs, _ready builds geometry, the ready signal propagates,
	# and our handler runs.
	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(names_emitted.size(), 1, "map_loaded fires exactly once")
	assert_eq(names_emitted[0], "map_1_childhood_home")
	assert_gt(rooms_when_emitted[0], 0,
		"World registry must be populated by the time map_loaded fires")
	assert_gt(doors_when_emitted[0], 0,
		"World door registry must be populated by the time map_loaded fires")
	assert_eq(World.list_rooms().size(), 12, "Map 1 declares 12 rooms")
	World.unload_map()

# ---------- Map 1 content sanity ----------

func test_map_1_has_12_rooms() -> void:
	var rooms: Array = Map1ChildhoodHome.get_room_table()
	assert_eq(rooms.size(), 12, "Map 1 must declare 12 rooms (Issue #7)")

func test_map_1_required_rooms_present() -> void:
	var required: Array[String] = [
		"foyer", "kitchen", "living_room", "bedroom", "bathroom",
		"cellar", "attic", "garden", "hallway1", "hallway2",
		"stairwell", "main_exit",
	]
	var ids: Array[String] = []
	for r in Map1ChildhoodHome.get_room_table():
		ids.append(r["id"])
	for name in required:
		assert_true(ids.has(name), "Map 1 must contain room '%s'" % name)

func test_map_1_main_exit_room_is_fixed() -> void:
	for r in Map1ChildhoodHome.get_room_table():
		if r["id"] == "main_exit":
			assert_true(r["fixed"], "Main Exit room must be fixed (Director can't remove)")
			return
	fail_test("main_exit room not found")

func test_map_1_foyer_is_fixed() -> void:
	for r in Map1ChildhoodHome.get_room_table():
		if r["id"] == "foyer":
			assert_true(r["fixed"], "Foyer (spawn) must be fixed")
			return
	fail_test("foyer room not found")

func test_map_1_has_main_exit_door() -> void:
	var main_exit_doors: int = 0
	for d in Map1ChildhoodHome.get_door_table():
		if d["main_exit"]:
			main_exit_doors += 1
	assert_eq(main_exit_doors, 1, "Map 1 must have exactly 1 main exit door")

func test_map_1_artifact_spawns() -> void:
	var spawns: Array = Map1ChildhoodHome.get_artifact_spawn_table()
	assert_eq(spawns.size(), 3, "GDD §5 requires 3 artifacts")
	var kinds: Array[String] = []
	for s in spawns:
		kinds.append(s["kind"])
	assert_true(kinds.has("skull"))
	assert_true(kinds.has("photograph"))
	assert_true(kinds.has("key"))

func test_map_1_doors_reference_existing_rooms() -> void:
	var room_ids: Dictionary = {}
	for r in Map1ChildhoodHome.get_room_table():
		room_ids[r["id"]] = true
	for d in Map1ChildhoodHome.get_door_table():
		assert_true(room_ids.has(d["a"]), "Door references unknown room A '%s'" % d["a"])
		assert_true(room_ids.has(d["b"]), "Door references unknown room B '%s'" % d["b"])
