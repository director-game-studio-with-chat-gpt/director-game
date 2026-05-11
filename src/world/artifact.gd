class_name Artifact extends Item
## Artifact — one of the three artifacts the Escapists must collect.
## Artifact kinds (per GDD §5): "skull", "photograph", "key".

const KIND_SKULL: String = "skull"
const KIND_PHOTOGRAPH: String = "photograph"
const KIND_KEY: String = "key"

const VALID_KINDS: Array[String] = [KIND_SKULL, KIND_PHOTOGRAPH, KIND_KEY]

@export var artifact_kind: String = KIND_SKULL
@export var pedestal_index: int = 0

func _ready() -> void:
	super._ready()
	if not VALID_KINDS.has(artifact_kind):
		push_warning("Artifact: unknown kind '%s'" % artifact_kind)

func is_artifact() -> bool:
	return true
