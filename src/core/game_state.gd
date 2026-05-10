extends Node
## GameState — global game state and match phase.
##
## Autoloaded as `GameState`. Owned by Devin-1 (Engine / Core).
##
## Public interface (see docs/architecture.md):
##   role: String                ("director" or "escapist")
##   player_id: int
##   match_phase: String         ("lobby", "playing", "ending")
##   mana: int                   (Director's mana 0-200)
##
## Signals:
##   match_started
##   match_ended(winner: String)
##   role_assigned(role: String)

signal match_started
signal match_ended(winner: String)
signal role_assigned(role: String)

const PHASE_LOBBY: String = "lobby"
const PHASE_PLAYING: String = "playing"
const PHASE_ENDING: String = "ending"

const ROLE_DIRECTOR: String = "director"
const ROLE_ESCAPIST: String = "escapist"

var role: String = ""
var player_id: int = 0
var match_phase: String = PHASE_LOBBY
var mana: int = 100

func _ready() -> void:
	# Devin-1: hook this up to scene loader transitions
	pass

func assign_role(new_role: String) -> void:
	if new_role != ROLE_DIRECTOR and new_role != ROLE_ESCAPIST:
		push_error("Invalid role: %s" % new_role)
		return
	role = new_role
	role_assigned.emit(new_role)

func start_match() -> void:
	match_phase = PHASE_PLAYING
	match_started.emit()

func end_match(winner: String) -> void:
	match_phase = PHASE_ENDING
	match_ended.emit(winner)

func is_director() -> bool:
	return role == ROLE_DIRECTOR

func is_escapist() -> bool:
	return role == ROLE_ESCAPIST
