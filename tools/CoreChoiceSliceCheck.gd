extends Node
## ORDER-36: first-eight-week plan -> interruption -> delayed consequence contract.

var _failures: Array[String] = []

func _ready() -> void:
	_check_opening_intent()
	_check_boss_choice(0, "arc_temptation_clean")
	_check_boss_choice(1, "arc_temptation_fallout")
	if _failures.is_empty():
		print("CORE_CHOICE_SLICE_CHECK_OK intent=1 boss=t4 ap_duplicate=0 delayed=t8 branches=2 save=roundtrip")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("CORE_CHOICE_SLICE_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)

func _new_main_game():
	return load("res://scenes/MainGame.gd").new()

func _check_opening_intent() -> void:
	GameState.start_new_game()
	GameState.turn = 1
	GameState.action_points = GameState.max_action_points
	var game = _new_main_game()
	var pressure: Dictionary = game._demo_week_pressure()
	_expect(str(pressure.get("id", "")) == "chapter1_intent",
		"week one did not ask for the player's own first-two-month intent")
	_expect(pressure.get("action_ids", []) == ["apply", "side_shift", "study"],
		"week-one intent options drifted")
	var commitment: Dictionary = game._weekly_commitment_payload(pressure, "apply")
	_expect(str(commitment.get("chapter_intent_id", "")) == "secure_work",
		"job-first intent was not encoded in the weekly transaction")
	_expect(GameState.arm_weekly_commitment(commitment),
		"week-one intent could not arm its transaction")
	_expect(GameState.finalize_weekly_commitment("apply"),
		"week-one intent could not finalize")
	_expect(str(GameState.flags.get("chapter_intent_id", "")) == "secure_work",
		"week-one intent did not persist in the run ledger")
	_expect(int(GameState.flags.get("chapter_intent_turn", -1)) == 1,
		"week-one intent persisted with the wrong turn")
	_expect(GameState.weekly_commitments.size() == 1,
		"week-one intent wrote more than one weekly record")
	game.free()

func _check_boss_choice(choice_index: int, expected_follow_up: String) -> void:
	GameState.start_new_game()
	GameState.turn = 4
	GameState.action_points = GameState.max_action_points
	var event: Dictionary = DataRegistry.find_event("arc_temptation_01")
	var choices: Array = event.get("choices", [])
	_expect(choices.size() == 2, "burner-account boss no longer has two choices")
	if choice_index < 0 or choice_index >= choices.size():
		return
	var choice: Dictionary = choices[choice_index]
	_expect(str(choice.get("follow_up_event", "")).is_empty(),
		"burner-account consequence still plays immediately for branch %d" % choice_index)
	var baseline := GameState.weekly_commitment_snapshot()
	GameState.apply_choice(event, choice)
	var forgone: Array[int] = [1 - choice_index]
	_expect(GameState.record_story_boss_commitment(
		"arc_temptation_01", choice_index, baseline, forgone),
		"story boss did not write its weekly transaction for branch %d" % choice_index)
	_expect(GameState.action_points == 0,
		"story boss left AP available for a duplicate decision")
	_expect(GameState.weekly_commitments.size() == 1,
		"story boss wrote a duplicate weekly record")
	_expect(not GameState.record_story_boss_commitment(
		"arc_temptation_01", choice_index, baseline, forgone),
		"story boss accepted a second record in the same week")
	var record := GameState.get_weekly_commitment_for_turn(4)
	_expect(str(record.get("source", "")) == "story_boss",
		"week-four ledger does not identify its authored source")
	_expect(int(record.get("story_choice_index", -1)) == choice_index,
		"week-four ledger stored the wrong story choice")
	var game = _new_main_game()
	_expect(not game._demo_director_requires_player_input(),
		"week four still requests the generic AP board after the story boss")

	var saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	_expect(GameState.has_story_boss_commitment(4),
		"story boss commitment did not survive save/load")

	GameState.turn = 8
	GameState.flags["prologue_done"] = true
	GameState.flags["chapter_33_seen"] = true
	GameState.flags["arc_intro_meal_seen"] = true
	GameState.flags["arc_intro_dad_seen"] = true
	GameState.flags["arc_intro_sns_seen"] = true
	GameState.flags["cafe_scenario_seen"] = true
	var routed: String = game._next_arc_id(8, true, false)
	_expect(routed == expected_follow_up,
		"branch %d returned '%s' at week eight instead of '%s'" % [
			choice_index, routed, expected_follow_up])
	game.free()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
