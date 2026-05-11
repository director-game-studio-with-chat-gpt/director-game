class_name Wall extends StaticBody3D
## Wall — a single static wall segment.
##
## Walls have an ID, dimensions, and may be `is_movable=false` (the Director
## cannot relocate them). Each Wall owns a CollisionShape3D and a
## MeshInstance3D as children — the map script wires those up.

signal moved(new_transform: Transform3D)

@export var wall_id: String = ""
@export var room_a_id: String = ""
@export var room_b_id: String = ""
@export var is_movable: bool = true
@export var dimensions: Vector3 = Vector3(6.0, 3.0, 0.2)

var _tween: Tween = null

func _ready() -> void:
	pass

func get_id() -> String:
	if wall_id != "":
		return wall_id
	return name

## Animates the wall from its current transform to `target` over `duration`
## seconds. Cancels any previous animation. Emits `moved` on completion.
func animate_to_transform(target: Transform3D, duration: float) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	if duration <= 0.0:
		transform = target
		moved.emit(target)
		return
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(self, "transform", target, duration)
	_tween.tween_callback(func() -> void: moved.emit(target))
