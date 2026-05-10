extends "res://addons/gut/test.gd"
## Tests for GameState autoload.
## Devin-1: expand these as you implement the full GameState logic.

func test_initial_state() -> void:
	assert_eq(GameState.match_phase, GameState.PHASE_LOBBY, "Should start in lobby phase")
	assert_eq(GameState.role, "", "Role should be unset initially")
	assert_eq(GameState.mana, 100, "Mana should start at 100")

func test_assign_role_director() -> void:
	GameState.assign_role(GameState.ROLE_DIRECTOR)
	assert_eq(GameState.role, GameState.ROLE_DIRECTOR)
	assert_true(GameState.is_director())
	assert_false(GameState.is_escapist())

func test_assign_role_escapist() -> void:
	GameState.assign_role(GameState.ROLE_ESCAPIST)
	assert_eq(GameState.role, GameState.ROLE_ESCAPIST)
	assert_true(GameState.is_escapist())
	assert_false(GameState.is_director())

func test_invalid_role_rejected() -> void:
	GameState.assign_role(GameState.ROLE_DIRECTOR)
	GameState.assign_role("nonsense")
	assert_eq(GameState.role, GameState.ROLE_DIRECTOR, "Invalid role should not overwrite")

func test_match_lifecycle() -> void:
	GameState.start_match()
	assert_eq(GameState.match_phase, GameState.PHASE_PLAYING)
	GameState.end_match("director")
	assert_eq(GameState.match_phase, GameState.PHASE_ENDING)
