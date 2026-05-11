class_name MapLoader extends RefCounted
## MapLoader — helper for loading map .tscn files.
##
## World.load_map() forwards to this. Kept as a separate class so tests can
## probe the loader without spinning up the full autoload, and so future maps
## can plug in custom pre/post-processing hooks here.

## Returns the resource path for a map given its name. Map names are
## snake_case and live under `scenes/main/`.
static func resolve_scene_path(map_name: String) -> String:
	return "res://scenes/main/%s.tscn" % map_name

static func map_exists(map_name: String) -> bool:
	return ResourceLoader.exists(resolve_scene_path(map_name))

## Loads and instantiates a map scene without parenting it. Returns null on
## failure. Caller is responsible for `queue_free()` if they don't add it.
static func instantiate_map(map_name: String) -> Node3D:
	var path: String = resolve_scene_path(map_name)
	if not ResourceLoader.exists(path):
		push_error("MapLoader.instantiate_map: scene not found at %s" % path)
		return null
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		push_error("MapLoader.instantiate_map: failed to load %s" % path)
		return null
	var instance: Node = packed.instantiate()
	if instance == null:
		push_error("MapLoader.instantiate_map: instantiate returned null")
		return null
	if not (instance is Node3D):
		push_error("MapLoader.instantiate_map: scene root is not Node3D")
		instance.queue_free()
		return null
	return instance as Node3D

## Returns a list of all known maps by scanning `scenes/main/`.
static func list_known_maps() -> Array[String]:
	var out: Array[String] = []
	var dir: DirAccess = DirAccess.open("res://scenes/main/")
	if dir == null:
		return out
	dir.list_dir_begin()
	var entry: String = dir.get_next()
	while entry != "":
		if not dir.current_is_dir() and entry.ends_with(".tscn"):
			out.append(entry.get_basename())
		entry = dir.get_next()
	dir.list_dir_end()
	out.sort()
	return out
