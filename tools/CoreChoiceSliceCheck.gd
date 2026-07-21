extends Node
## ORDER-36/37: player plan, delayed consequence, and one authored decision per
## foreground week without a duplicate generic AP board.

var _failures: Array[String] = []

func _ready() -> void:
	_check_opening_intent()
	_check_opening_interview_causality()
	_check_boss_choice(0, "arc_temptation_clean")
	_check_boss_choice(1, "arc_temptation_fallout")
	_check_foreground_commitment_weeks()
	if _failures.is_empty():
		print("CORE_CHOICE_SLICE_CHECK_OK intent=1 interview=causal authored=7 generic=2 ap_duplicate=0 delayed=t8 branches=2 axes=money/human save=roundtrip")
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

func _check_opening_interview_causality() -> void:
	var game = _new_main_game()

	var non_application_routes: Array[Dictionary] = [
		{"action_id": "side_shift", "intent_id": "protect_cash"},
		{"action_id": "study", "intent_id": "build_capacity"},
	]
	for route in non_application_routes:
		GameState.start_new_game()
		GameState.turn = 1
		GameState.action_points = GameState.max_action_points
		GameState.flags["prologue_done"] = true
		GameState.flags["chapter_33_seen"] = true
		var pressure: Dictionary = game._demo_week_pressure()
		var action_id := str(route.get("action_id", ""))
		var commitment: Dictionary = game._weekly_commitment_payload(pressure, action_id)
		_expect(GameState.arm_weekly_commitment(commitment),
			"%s intent could not arm its transaction" % action_id)
		_expect(GameState.finalize_weekly_commitment(action_id),
			"%s intent could not finalize" % action_id)
		_expect(str(GameState.flags.get("chapter_intent_id", "")) == str(route.get("intent_id", "")),
			"%s intent did not persist" % action_id)
		_expect(not bool(GameState.flags.get("opening_interview_application_sent", false)),
			"%s intent silently submitted an application" % action_id)
		GameState.turn = 2
		_expect(game._next_arc_id(2, true, false) != "arc_intro_01_meal",
			"the first interview fired after the %s intent" % action_id)

	GameState.start_new_game()
	GameState.turn = 1
	GameState.action_points = GameState.max_action_points
	GameState.flags["prologue_done"] = true
	GameState.flags["chapter_33_seen"] = true
	var job_pressure: Dictionary = game._demo_week_pressure()
	var job_commitment: Dictionary = game._weekly_commitment_payload(job_pressure, "apply")
	_expect(GameState.arm_weekly_commitment(job_commitment),
		"job-first intent could not arm its transaction")
	_expect(game._commit_opening_interview_application(),
		"opening application could not finalize")
	_expect(bool(GameState.flags.get("opening_interview_application_sent", false)) \
			and int(GameState.flags.get("opening_interview_application_turn", -1)) == 1,
		"opening application did not persist its submission week")
	_expect(GameState.action_points == 0 and GameState.weekly_commitments.size() == 1,
		"opening application did not close the week with one transaction")
	_expect(game._next_arc_id(1, true, false) != "arc_intro_01_meal",
		"the first interview fired in the same week as the application")
	GameState.turn = 2
	_expect(game._next_arc_id(2, true, false) == "arc_intro_01_meal",
		"the first interview did not unlock one week after the application")
	GameState.current_job = DataRegistry.get_job("job_01").duplicate(true)
	_expect(game._next_arc_id(2, true, false) != "arc_intro_01_meal",
		"the opening interview fired for an already-employed save")
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
	var contract := EventManager.narrative_commitment_contract("arc_temptation_01", 4)
	var baseline := GameState.weekly_commitment_snapshot()
	GameState.apply_choice(event, choice)
	var forgone: Array[int] = [1 - choice_index]
	_expect(GameState.record_story_weekly_commitment(
		"arc_temptation_01", choice_index, baseline, forgone, contract),
		"story boss did not write its weekly transaction for branch %d" % choice_index)
	_expect(GameState.action_points == 0,
		"story boss left AP available for a duplicate decision")
	_expect(GameState.weekly_commitments.size() == 1,
		"story boss wrote a duplicate weekly record")
	_expect(not GameState.record_story_weekly_commitment(
		"arc_temptation_01", choice_index, baseline, forgone, contract),
		"story boss accepted a second record in the same week")
	var record := GameState.get_weekly_commitment_for_turn(4)
	_expect(str(record.get("source", "")) == "story_event",
		"week-four ledger does not identify its authored source")
	_expect(str(record.get("consequence_timing", "")) == "delayed",
		"week-four ledger lost its delayed-consequence contract")
	_expect(int(record.get("story_choice_index", -1)) == choice_index,
		"week-four ledger stored the wrong story choice")
	var game = _new_main_game()
	_expect(not game._demo_director_requires_player_input(),
		"week four still requests the generic AP board after the story boss")

	var saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	_expect(GameState.has_story_boss_commitment(4) \
			and GameState.has_story_weekly_commitment(4),
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

func _check_foreground_commitment_weeks() -> void:
	var representatives := {
		10: "arc_ch1_career_first_spec",
		13: "cafe_cb_honest_00",
		16: "arc_father_quiet_call",
		20: "arc_job_vs_invest",
		23: "story_first_savings_milestone",
		24: "hyunsu_exam_day",
	}
	for raw_week in representatives:
		var week := int(raw_week)
		var event_id := str(representatives[raw_week])
		GameState.start_new_game()
		GameState.turn = week
		GameState.action_points = GameState.max_action_points
		var event: Dictionary = DataRegistry.find_event(event_id)
		var choices: Array = event.get("choices", [])
		_expect(choices.size() >= 2,
			"%s is not a meaningful authored decision" % event_id)
		if choices.size() < 2:
			continue
		var contract := EventManager.narrative_commitment_contract(event_id, week)
		_expect(not contract.is_empty(),
			"week %d has no ownership contract for %s" % [week, event_id])
		if contract.is_empty():
			continue
		var axis := str(contract.get("axis", ""))
		var person_id := str(contract.get("person_id", ""))
		var baseline := GameState.weekly_commitment_snapshot(person_id)
		GameState.apply_choice(event, choices[0])
		var forgone: Array[int] = []
		for choice_index in range(1, choices.size()):
			forgone.append(choice_index)
		_expect(GameState.record_story_weekly_commitment(
			event_id, 0, baseline, forgone, contract),
			"week %d could not record %s" % [week, event_id])
		var record := GameState.get_weekly_commitment_for_turn(week)
		_expect(GameState.is_story_weekly_commitment_record(record),
			"week %d did not store an authored source" % week)
		_expect(str(record.get("axis", "")) == axis,
			"week %d lost its %s axis" % [week, axis])
		_expect(int(GameState.action_axis_this_week.get(axis, 0)) == 1,
			"week %d did not settle its authored choice on the %s axis" % [week, axis])
		_expect(GameState.action_points == 0,
			"week %d left AP for a duplicate generic decision" % week)
		var game = _new_main_game()
		_expect(not game._demo_director_requires_player_input(),
			"week %d still requests a generic AP board" % week)
		game.free()
		var saved: Dictionary = GameState.serialize()
		GameState.start_new_game()
		GameState.load_from_dict(saved)
		_expect(GameState.has_story_weekly_commitment(week),
			"week %d authored commitment did not survive save/load" % week)
	_expect(EventManager.narrative_commitment_event_ids(8).is_empty(),
		"week eight should remain a separate generic decision")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
