extends SceneTree
## One-shot script that loads Map 1, parents a camera, renders a frame, and
## saves a PNG. Run via:
##   godot --rendering-driver opengl3 --resolution 1280x720 \
##         --headless -s tools/capture_map_screenshot.gd /tmp/map1.png
## (Or remove --headless if running with xvfb-run.)

const OUT_PATH: String = "user://map_1_screenshot.png"

func _initialize() -> void:
	var packed: PackedScene = load("res://scenes/main/map_1_childhood_home.tscn") as PackedScene
	if packed == null:
		printerr("Could not load map scene")
		quit(1)
		return
	var map: Node = packed.instantiate()
	root.add_child(map)

	# Wait a frame so the map's _ready() runs and builds the rooms, then hide
	# all ceilings so the screenshot can see inside the rooms.
	await process_frame
	_hide_ceilings(map)

	var cam: Camera3D = Camera3D.new()
	cam.fov = 55.0
	root.add_child(cam)
	cam.look_at_from_position(Vector3(8, 26, 22), Vector3(6, 0, 3), Vector3.UP)
	cam.current = true

	var light: DirectionalLight3D = DirectionalLight3D.new()
	root.add_child(light)
	light.look_at_from_position(Vector3(6, 20, 0), Vector3(6, 0, 4), Vector3(0, 0, 1))
	light.light_energy = 1.4

	for i in range(20):
		await process_frame
	var img: Image = root.get_viewport().get_texture().get_image()
	var save_to: String = OUT_PATH
	var err: int = img.save_png(save_to)
	if err != OK:
		printerr("save_png failed: %d" % err)
		quit(1)
		return
	print("Saved screenshot to %s (resolves to %s)" % [save_to, ProjectSettings.globalize_path(save_to)])
	quit(0)

func _hide_ceilings(root_node: Node) -> void:
	for n in _walk(root_node):
		if n is MeshInstance3D and n.name == "Ceiling":
			(n as MeshInstance3D).visible = false

func _walk(start: Node) -> Array[Node]:
	var out: Array[Node] = []
	var stack: Array[Node] = [start]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		out.append(n)
		for child in n.get_children():
			stack.append(child)
	return out
