extends Node
## ORDER-36/37: player plan, delayed consequence, and one authored decision per
## foreground week without a duplicate generic AP board.

const CHAPTER5_REQUIRED_ENTRY_FLAGS: Array[String] = [
	"arc_sangchul_met_seen",
	"arc_daeun_met",
	"daeun_romance_started",
	"arc_minseo_02_seen",
	"arc_jaehyuk_reunion_seen",
	"arc_jaehyuk_aftermath_seen",
]
const CHAPTER5_EXCLUDED_ENTRY_FLAGS: Array[String] = [
	"sangchul_reported",
	"sangchul_cut_ties",
	"sangchul_quietly_distanced",
	"daeun_let_her_go",
	"daeun_divorced",
	"arc_jaehyuk_mirror_seen",
	"refused_jaehyuk_guarantee",
	"vouched_jaehyuk_guarantee",
	"blocked_jaehyuk_guarantee",
	"jaehyuk_final_break",
]

var _failures: Array[String] = []

func _ready() -> void:
	_check_opening_intent()
	_check_opening_interview_causality()
	_check_story_prerequisite_contract()
	_check_racetrack_story_handoff()
	_check_boss_choice(0, "arc_temptation_clean")
	_check_boss_choice(1, "arc_temptation_fallout")
	_check_chapter_four_missed_cost_routing()
	_check_chapter_four_boundary_handoff()
	_check_chapter5_causal_direct_week_ownership()
	_check_chapter_four_father_death_recovery()
	_check_father_terminal_final_week_repair()
	_check_father_terminal_ending_descriptions()
	_check_chapter_four_terminal_router_guards()
	_check_father_terminal_legacy_routes()
	_check_foreground_commitment_weeks()
	if _failures.is_empty():
		print("CORE_CHOICE_SLICE_CHECK_OK intent=1 interview=causal job_gate=ledger jiyeon_lunch=branch_gated racetrack=handoff authored=7 generic=2 ap_duplicate=0 delayed=t8 branches=2 axes=money/human missed_cost=targeted chapter5=w193_same_queue+eligible-direct/fallback-w209/no-ap father_death=monotonic_repair father_active=guarded milestone_routing=dual late_routes=variant+closed save=roundtrip")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("CORE_CHOICE_SLICE_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)

func _new_main_game():
	return load("res://scenes/MainGame.gd").new()

func _prepare_chapter5_product_path() -> void:
	GameState.start_new_game("김민준", "지방_상경", "투자형")
	GameState.turn = 195
	GameState.money = 2_100_000_000.0
	GameState.portfolio = {}
	GameState.loans = {"bank": 0.0, "second": 0.0}
	GameState.pending_story_queue = []
	GameState.flags.erase("foreground_story_turn")
	GameState.flags["route_invest"] = true
	for flag in CHAPTER5_REQUIRED_ENTRY_FLAGS:
		GameState.flags[flag] = true
	for flag in CHAPTER5_EXCLUDED_ENTRY_FLAGS:
		GameState.flags.erase(flag)

func _expect_chapter5_direct_route_rejected(label: String) -> void:
	var game = _new_main_game()
	game.set_meta("_screenshot_qa_static_surface", true)
	_expect(not game._route_chapter5_causal_week() \
		and GameState.pending_story_queue.is_empty() \
		and int(GameState.flags.get("foreground_story_turn", -1)) != 195,
		"ineligible Chapter 5 route claimed W195: %s" % label)
	game.free()

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

func _check_story_prerequisite_contract() -> void:
	GameState.start_new_game()
	GameState.turn = 24
	GameState.investment_skill = 10
	GameState.current_job = DataRegistry.get_job("job_01").duplicate(true)
	var game = _new_main_game()
	_expect(not game._story_event_prerequisites_met(
		"arc_job_vs_invest", GameState.turn, GameState.flags),
		"survival job passed the company-manager story prerequisite")

	GameState.current_job = DataRegistry.get_job("job_03").duplicate(true)
	_expect(game._story_event_prerequisites_met(
		"arc_job_vs_invest", GameState.turn, GameState.flags),
		"corporate job did not pass the declarative story prerequisite")

	GameState.flags["arc_job_invest_clash_seen"] = true
	_expect(not game._story_event_prerequisites_met(
		"arc_job_vs_invest", GameState.turn, GameState.flags),
		"seen company-manager event passed its one-shot prerequisite")

	GameState.flags.erase("arc_job_invest_clash_seen")
	GameState.turn = 31
	_expect(not game._story_event_prerequisites_met(
		"arc_job_vs_invest", GameState.turn, GameState.flags),
		"company-manager event passed outside its authored week range")

	GameState.turn = 70
	GameState.flags = {
		"arc_jiyeon_offer_seen": true,
		"jiyeon_refused_coffee": true,
	}
	_expect(not game._story_event_prerequisites_met(
		"arc_jiyeon_03b_lunch", GameState.turn, GameState.flags),
		"Jiyeon lunch fired after the player refused both coffee and a meal")
	GameState.flags["jiyeon_had_coffee"] = true
	_expect(game._story_event_prerequisites_met(
		"arc_jiyeon_03b_lunch", GameState.turn, GameState.flags),
		"Jiyeon lunch did not open after the coffee route")
	GameState.flags.erase("jiyeon_had_coffee")
	GameState.flags["jiyeon_honest"] = true
	_expect(game._story_event_prerequisites_met(
		"arc_jiyeon_03b_lunch", GameState.turn, GameState.flags),
		"Jiyeon lunch did not open after the honest conversation route")
	GameState.flags["arc_jiyeon_03b_seen"] = true
	_expect(not game._story_event_prerequisites_met(
		"arc_jiyeon_03b_lunch", GameState.turn, GameState.flags),
		"seen Jiyeon lunch passed its one-shot prerequisite")
	game.free()

func _check_racetrack_story_handoff() -> void:
	GameState.start_new_game()
	var event: Dictionary = DataRegistry.find_event("race_first_visit")
	var choices: Array = event.get("choices", [])
	_expect(choices.size() >= 2, "race_first_visit no longer has its bet choice")
	if choices.size() < 2:
		return
	var starting_money: int = int(GameState.money)
	GameState.apply_choice(event, choices[1])
	_expect(int(GameState.money) == starting_money,
		"race_first_visit charged a scripted loss before the playable race")
	var game = _new_main_game()
	_expect(game._take_story_followup_activity() == "racetrack",
		"race_first_visit did not hand off to the playable racetrack")
	_expect(not bool(GameState.flags.get("open_racetrack_after_story", false)),
		"racetrack story handoff flag was not consumed")
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

func _check_chapter_four_father_death_recovery() -> void:
	for evidence_case in ["legacy_receipt", "cast_stage"]:
		GameState.start_new_game()
		GameState.turn = 174
		GameState.flags["arc_father_03_seen"] = true
		GameState.flags["arc_father_medication_seen"] = true
		GameState.flags["arc_y4_bill_night_seen"] = true
		GameState.flags["father_reconciled"] = true
		GameState.apply_cast_effect("father", {
			"met": true,
			"stage": "passed" if evidence_case == "cast_stage" else "health_crisis",
		})
		if evidence_case == "legacy_receipt":
			GameState.flags["arc_father_passing_seen"] = true
		GameState.flags.erase("father_passed")

		var game = _new_main_game()
		var preview_death: bool = game._father_death_is_monotonic(
			GameState.flags, false)
		_expect(preview_death,
			"%s was not recognized as terminal father evidence" % evidence_case)
		_expect(not bool(GameState.flags.get("father_passed", false)),
			"%s preview mutated the canonical father flag" % evidence_case)
		_expect(game._chapter_four_causal_arc_id(
			174, GameState.flags, preview_death) \
				not in ["arc_father_call_on_ktx", "arc_father_call_on_ktx_number"],
			"%s reopened the W174 father call" % evidence_case)
		_expect(game._chapter_four_causal_arc_id(
			185, GameState.flags, preview_death) != "arc_y4_father_crisis_contact",
			"%s reopened the W185 crisis contact" % evidence_case)

		game._next_arc_id(174, false, false)
		_expect(bool(GameState.flags.get("father_passed", false)),
			"%s live routing did not repair father_passed" % evidence_case)
		_expect(GameState.get_cast_stage("father") == "passed",
			"%s live routing did not repair Father's cast stage" % evidence_case)
		var saved: Dictionary = GameState.serialize()
		GameState.start_new_game()
		GameState.load_from_dict(saved)
		_expect(bool(GameState.flags.get("father_passed", false)) \
				and GameState.get_cast_stage("father") == "passed",
			"%s repaired death state did not survive save/load" % evidence_case)
		game.free()

func _check_father_terminal_final_week_repair() -> void:
	GameState.start_new_game()
	GameState.turn = 240
	GameState.age = 38
	GameState.flags["father_reconciled"] = true
	GameState.flags["arc_father_passing_seen"] = true
	GameState.flags.erase("father_passed")
	GameState.apply_cast_effect("father", {
		"met": true,
		"stage": "reconciled",
	})
	var endings: Array[String] = []
	var capture_ending := func(ending_id: String):
		endings.append(ending_id)
	var audio_ending_callback := Callable(AudioManager, "_on_game_over")
	var audio_was_connected := GameState.game_over.is_connected(
		audio_ending_callback)
	if audio_was_connected:
		GameState.game_over.disconnect(audio_ending_callback)
	GameState.game_over.connect(capture_ending)
	var game = _new_main_game()
	game._check_game_over_with_monotonic_story_state()
	_expect(bool(GameState.flags.get("father_passed", false)),
		"final-week repair did not restore canonical father_passed")
	_expect(GameState.get_cast_stage("father") == "passed",
		"final-week repair did not restore Father's passed cast stage")
	_expect(endings.size() == 1 and endings[0] != "late_call",
		"terminal Father receipt selected a live late_call ending")
	if GameState.game_over.is_connected(capture_ending):
		GameState.game_over.disconnect(capture_ending)
	if audio_was_connected and not GameState.game_over.is_connected(
			audio_ending_callback):
		GameState.game_over.connect(audio_ending_callback)
	game.free()

func _check_father_terminal_ending_descriptions() -> void:
	GameState.start_new_game()
	GameState.flags["father_reconciled"] = true
	GameState.flags["arc_father_passing_seen"] = true
	GameState.flags.erase("father_passed")
	var game = _new_main_game()
	for ending_id in [
		"with_daeun",
		"mental_break",
		"healthy_retirement",
		"orthodox_hollow",
		"gambling_recovery",
		"career_burnout",
	]:
		var ending: Dictionary = EndingSystem.get_ending(ending_id)
		_expect(game._resolved_ending_description(ending) \
				== str(ending.get("description", "")),
			"terminal Father evidence selected live prose for %s" % ending_id)
	var empty_house: Dictionary = EndingSystem.get_ending("empty_house")
	var empty_house_known: Dictionary = empty_house.get(
		"description_if_known", {})
	_expect(game._resolved_ending_description(empty_house) \
			== str(empty_house_known.get("father_reconciled", "")),
		"terminal Father evidence lost the death-safe empty-house memory")
	game.free()

func _check_chapter_four_terminal_router_guards() -> void:
	var fixed_week_cases: Array[Dictionary] = [
		{
			"turn": 153,
			"unset": "arc_y4_three_promises_seen",
			"alive_event": "arc_y4_three_promises_deal_only",
			"forbidden_events": [
				"arc_y4_three_promises",
				"arc_y4_three_promises_jiyeon_and_deal",
				"arc_y4_three_promises_deal_only",
			],
		},
		{
			"turn": 167,
			"unset": "arc_y4_family_table_seen",
			"alive_event": "arc_y4_family_commitment_none",
			"forbidden_events": [
				"arc_y4_family_partner_collision",
				"arc_y4_family_partner_collision_jiyeon",
				"arc_y4_family_commitment_none",
				"arc_y4_family_table_missed",
			],
		},
		{
			"turn": 181,
			"unset": "arc_y4_bill_night_seen",
			"alive_event": "arc_y4_bill_night_unattached",
			"forbidden_events": [
				"arc_y4_bill_night",
				"arc_y4_bill_night_jiyeon",
				"arc_y4_bill_night_unattached",
			],
		},
	]
	for route_case in fixed_week_cases:
		_prepare_chapter_four_router_state()
		GameState.flags.erase(str(route_case.get("unset", "")))
		var game = _new_main_game()
		var turn := int(route_case.get("turn", -1))
		_expect(game._next_arc_id(turn, true, false) \
				== str(route_case.get("alive_event", "")),
			"living Father lost the protected W%d scene" % turn)
		game.free()

		_prepare_chapter_four_router_state()
		GameState.flags.erase(str(route_case.get("unset", "")))
		GameState.flags["arc_father_passing_seen"] = true
		game = _new_main_game()
		var terminal_route: String = game._next_arc_id(turn, true, false)
		_expect(terminal_route not in route_case.get("forbidden_events", []),
			"terminal Father evidence reopened the protected W%d scene" % turn)
		game.free()

	# Two M40 variants explicitly reopen Father's ward; the person/deal variant
	# is father-free and remains valid after terminal evidence.
	_prepare_chapter_four_router_state()
	GameState.flags["arc_y4_three_promises_missed_father"] = true
	GameState.flags["arc_y4_three_promises_missed_person"] = true
	GameState.flags["arc_father_passing_seen"] = true
	var father_pair_game = _new_main_game()
	_expect(father_pair_game._next_arc_id(157, true, false) \
			!= "arc_36_unexpected_hand",
		"terminal Father evidence reopened a father-active M40 pair")
	father_pair_game.free()

	_prepare_chapter_four_router_state()
	GameState.flags["arc_y4_three_promises_missed_person"] = true
	GameState.flags["arc_y4_three_promises_missed_deal"] = true
	GameState.flags["arc_father_passing_seen"] = true
	var father_free_game = _new_main_game()
	_expect(father_free_game._next_arc_id(157, true, false) \
			== "arc_36_unexpected_hand_person_deal",
		"terminal Father evidence blocked the father-free M40 pair")
	father_free_game.free()

func _check_father_terminal_legacy_routes() -> void:
	var living_route_cases: Array[Dictionary] = [
		{"turn": 14, "event": "arc_father_01_call",
			"erase": ["arc_father_01_seen"], "set": []},
		{"turn": 16, "event": "arc_father_quiet_call",
			"erase": ["arc_father_quiet_call_seen"],
			"set": ["arc_father_01_seen"]},
		{"turn": 21, "event": "arc_father_02_signal",
			"erase": ["arc_father_02_done"],
			"set": ["arc_father_01_seen"]},
		{"turn": 58, "event": "arc_father_medication",
			"erase": ["arc_father_medication_seen"],
			"set": ["arc_father_02_done"]},
		{"turn": 82, "event": "arc_father_03_hospital",
			"erase": ["arc_father_03_seen"],
			"set": ["arc_father_02_done", "arc_father_medication_seen"]},
		{"turn": 100, "event": "arc_father_05_after_visit",
			"erase": ["arc_father_05_seen", "father_visit_deferred"],
			"set": ["visited_father"]},
		{"turn": 102, "event": "arc_father_06_confession",
			"erase": ["arc_father_06_seen"],
			"set": ["visited_father", "arc_father_05_seen",
				"arc_sangchul_02_seen"]},
		{"turn": 77, "event": "arc_34_parents_visit",
			"erase": ["arc_34_parents_visit_seen"], "set": []},
		{"turn": 100, "event": "arc_35_birthday",
			"erase": ["arc_35_birthday_seen"], "set": []},
		{"turn": 130, "event": "arc_minjun_first_call",
			"erase": ["arc_minjun_first_call_seen"], "set": []},
	]
	for route_case in living_route_cases:
		_prepare_chapter_four_router_state()
		for flag in route_case.get("erase", []):
			GameState.flags.erase(str(flag))
		for flag in route_case.get("set", []):
			GameState.flags[str(flag)] = true
		var game = _new_main_game()
		var turn := int(route_case.get("turn", -1))
		var expected := str(route_case.get("event", ""))
		var living_route: String = game._next_arc_id(turn, true, false)
		_expect(living_route == expected,
			"living Father route W%d expected=%s actual=%s" \
					% [turn, expected, living_route])
		game.free()

		_prepare_chapter_four_router_state()
		for flag in route_case.get("erase", []):
			GameState.flags.erase(str(flag))
		for flag in route_case.get("set", []):
			GameState.flags[str(flag)] = true
		GameState.flags["arc_father_passing_seen"] = true
		game = _new_main_game()
		var terminal_route: String = game._next_arc_id(turn, true, false)
		_expect(terminal_route != expected,
			"terminal Father route W%d reopened=%s actual=%s" \
					% [turn, expected, terminal_route])
		game.free()

	var milestone_cases: Array[Dictionary] = [
		{"turn": 200, "money": 50_000_000.0,
			"seen": "arc_first_real_win_seen",
			"alive": "arc_first_real_win",
			"passed": "arc_first_real_win_father_passed"},
		{"turn": 200, "money": 100_000_000.0,
			"seen": "arc_money_loneliness_seen",
			"alive": "arc_money_loneliness",
			"passed": "arc_money_loneliness_father_passed"},
		{"turn": 200, "money": 2_500_000_000.0,
			"seen": "arc_gangnam_real_estate_seen",
			"alive": "arc_gangnam_real_estate",
			"passed": "arc_gangnam_real_estate_father_passed"},
	]
	for route_case in milestone_cases:
		for passed in [false, true]:
			_prepare_chapter_four_router_state()
			GameState.money = float(route_case.get("money", 0.0))
			GameState.flags.erase(str(route_case.get("seen", "")))
			GameState.flags["arc_final_stretch_seen"] = true
			if passed:
				GameState.flags["father_passed"] = true
			var game = _new_main_game()
			var expected := str(route_case.get(
				"passed" if passed else "alive", ""))
			var actual: String = game._next_arc_id(
				int(route_case.get("turn", -1)), true, false)
			_expect(actual == expected,
				"milestone father_passed=%s expected=%s actual=%s" \
						% [passed, expected, actual])
			game.free()

	# A partial save must not replay the opening Dad call in the fifth year.
	_prepare_chapter_four_router_state()
	GameState.flags.erase("arc_intro_dad_seen")
	GameState.flags["arc_intro_meal_seen"] = true
	GameState.flags["arc_father_passing_seen"] = true
	var late_intro_game = _new_main_game()
	var late_dad_route: String = late_intro_game._next_arc_id(189, true, false)
	_expect(late_dad_route != "arc_intro_02_dad_call",
		"terminal partial save reopened the opening Dad call at W189")
	late_intro_game.free()

	_prepare_chapter_four_router_state()
	GameState.flags.erase("arc_intro_meal_seen")
	GameState.flags["opening_interview_application_sent"] = true
	GameState.flags["opening_interview_application_turn"] = 1
	var late_meal_game = _new_main_game()
	var late_meal_route: String = late_meal_game._next_arc_id(189, true, false)
	_expect(late_meal_route != "arc_intro_01_meal",
		"partial save reopened the first-week meal at W189")
	late_meal_game.free()

	for passed in [false, true]:
		_prepare_chapter_four_router_state()
		GameState.flags.erase("arc_sangchul_year3_seen")
		GameState.flags["arc_sangchul_confrontation_seen"] = true
		if passed:
			GameState.flags["father_passed"] = true
		var article_game = _new_main_game()
		var expected_article := "arc_sangchul_year3_father_passed" \
				if passed else "arc_sangchul_year3"
		var actual_article: String = article_game._next_arc_id(
				189, true, false)
		_expect(actual_article == expected_article,
			"late article father_passed=%s expected=%s actual=%s" \
					% [passed, expected_article, actual_article])
		article_game.free()

func _check_chapter_four_missed_cost_routing() -> void:
	var m40_ids: Array[String] = [
		"arc_36_unexpected_hand",
		"arc_36_unexpected_hand_father_deal",
		"arc_36_unexpected_hand_person_deal",
	]
	var route_cases: Array[Dictionary] = [
		{
			"missed": ["father", "person"],
			"event_id": "arc_36_unexpected_hand",
			"targets": ["father", "person"],
		},
		{
			"missed": ["father", "deal"],
			"event_id": "arc_36_unexpected_hand_father_deal",
			"targets": ["father", "deal"],
		},
		{
			"missed": ["person", "deal"],
			"event_id": "arc_36_unexpected_hand_person_deal",
			"targets": ["person", "deal"],
		},
	]
	for route_case in route_cases:
		_prepare_chapter_four_router_state()
		for missed_id in route_case.get("missed", []):
			GameState.flags["arc_y4_three_promises_missed_%s" % missed_id] = true
		var game = _new_main_game()
		var event_id := str(route_case.get("event_id", ""))
		_expect(game._next_arc_id(157, true, false) == event_id,
			"full router did not send the exact missed pair to %s at W157" % event_id)
		var event: Dictionary = DataRegistry.find_event(event_id)
		var contract := EventManager.narrative_commitment_contract(event_id, 157)
		_expect(not contract.is_empty() \
				and str(contract.get("axis", "")) == "human",
			"%s does not own the protected W157 human choice" % event_id)
		var actual_targets: Array[String] = []
		for choice in event.get("choices", []):
			for target_id in ["father", "person", "deal"]:
				if choice.get("flags", []).has(
						"arc_y4_missed_cost_repaired_%s" % target_id):
					actual_targets.append(target_id)
		actual_targets.sort()
		var expected_targets: Array = route_case.get("targets", []).duplicate()
		expected_targets.sort()
		_expect(actual_targets == expected_targets,
			"%s choices do not repair the two actual missed targets" % event_id)
		game.free()

	# The new receipt path owns one exact protected week. The broad legacy
	# fallback must not prefire its base variant at W156.
	_prepare_chapter_four_router_state()
	GameState.flags["arc_y4_three_promises_missed_father"] = true
	GameState.flags["arc_y4_three_promises_missed_person"] = true
	var prefire_game = _new_main_game()
	var prefire_route: String = prefire_game._next_arc_id(156, true, false)
	_expect(prefire_route not in m40_ids,
		"full router prefired/intercepted protected W157: %s" % prefire_route)
	prefire_game.free()

	# Missing receipts (0 or 1) and a contradictory three-target receipt are
	# corruption. Exercise the full router so its legacy fallback cannot invent
	# the base father/person repair after the exact helper fails closed.
	var damaged_cases: Array[Array] = [
		[],
		["father"],
		["father", "person", "deal"],
	]
	for damaged_missed in damaged_cases:
		_prepare_chapter_four_router_state()
		for missed_id in damaged_missed:
			GameState.flags["arc_y4_three_promises_missed_%s" % missed_id] = true
		var damaged_game = _new_main_game()
		var damaged_route: String = damaged_game._next_arc_id(157, true, false)
		_expect(damaged_route not in m40_ids,
			"full router returned %s from %d damaged receipts" \
					% [damaged_route, damaged_missed.size()])
		damaged_game.free()

	# Old saves predate the M39 receipt family and cannot identify two missed
	# targets. Both edges of the former broad fallback now fail closed.
	for receiptless_turn in [156, 188]:
		_prepare_chapter_four_router_state()
		GameState.flags.erase("arc_y4_three_promises_seen")
		var receiptless_game = _new_main_game()
		var receiptless_route: String = receiptless_game._next_arc_id(
			receiptless_turn, true, false)
		_expect(receiptless_route not in m40_ids,
			"receiptless save invented %s at W%d" \
					% [receiptless_route, receiptless_turn])
		receiptless_game.free()

		_prepare_chapter_four_router_state()
		GameState.flags.erase("arc_y4_three_promises_seen")
		GameState.flags["arc_father_passing_seen"] = true
		receiptless_game = _new_main_game()
		receiptless_route = receiptless_game._next_arc_id(
			receiptless_turn, true, false)
		_expect(receiptless_route not in m40_ids,
			"terminal receiptless save invented %s at W%d" \
					% [receiptless_route, receiptless_turn])
		receiptless_game.free()

	var trust_crack: Dictionary = DataRegistry.find_event("arc_36_trust_crack")
	for choice in trust_crack.get("choices", []):
		_expect(str(choice.get("follow_up_event", "")).is_empty(),
			"trust crack still consumes M40 before protected W157")

func _prepare_chapter_four_router_state() -> void:
	GameState.start_new_game()
	GameState.turn = 157
	# Silence every completed one-shot so a failed Chapter 4 receipt reaches the
	# actual legacy fallback instead of passing because an unrelated older arc
	# happened to intercept first.
	for event in DataRegistry.get_all_events():
		for choice in event.get("choices", []):
			for raw_flag in choice.get("flags", []):
				var flag := str(raw_flag)
				if flag.ends_with("_seen") \
						or flag.ends_with("_done") \
						or flag.ends_with("_closed"):
					GameState.flags[flag] = true
	for chapter_flag in [
		"chapter_33_seen",
		"chapter_34_seen",
		"chapter_35_seen",
		"chapter_36_seen",
	]:
		GameState.flags[chapter_flag] = true
	GameState.flags["prologue_done"] = true
	# Several first-meeting gates use durable actor facts rather than an event's
	# own `_seen` choice flag. Saturate those gates explicitly so full-router
	# fixtures reach the one route each case intentionally reopens.
	GameState.flags["arc_daeun_met"] = true
	GameState.flags["hyunsu_passed"] = true
	GameState.flags["visited_father"] = true
	GameState.flags["arc_y4_three_promises_seen"] = true
	GameState.flags["arc_36_trust_crack_seen"] = true
	GameState.flags.erase("arc_36_unexpected_hand_seen")
	GameState.flags.erase("father_passed")
	GameState.flags.erase("arc_father_passing_seen")
	GameState.apply_cast_effect("father", {"met": true, "stage": "health_crisis"})
	for target_id in ["father", "person", "deal"]:
		GameState.flags.erase(
			"arc_y4_three_promises_missed_%s" % target_id)

func _check_chapter_four_boundary_handoff() -> void:
	GameState.start_new_game()
	GameState.turn = 192
	GameState.add_deferred_event("arc_37_reckoning", 1)
	GameState.turn = 193
	var game = _new_main_game()
	game.set_meta("_screenshot_qa_static_surface", true)
	game._go_story_mode(["chapter_card_37"])
	_expect(GameState.pending_story_queue == [
			"chapter_card_37", "arc_37_reckoning"],
		"W193 chapter card did not carry the Year 4 reckoning in one story queue")
	_expect(not GameState.has_deferred_event("arc_37_reckoning"),
		"W193 chapter handoff left the claimed reckoning reservation behind")
	_expect(int(GameState.flags.get("foreground_story_turn", -1)) == 193,
		"W193 chapter handoff did not own the foreground week")
	game.free()

	# A damaged or future reservation must not be pulled into the canonical W193
	# boundary merely because it shares the same event id.
	GameState.start_new_game()
	GameState.turn = 193
	GameState.add_deferred_event("arc_37_reckoning", 1)
	game = _new_main_game()
	game.set_meta("_screenshot_qa_static_surface", true)
	game._go_story_mode(["chapter_card_37"])
	_expect(GameState.pending_story_queue == ["chapter_card_37"],
		"W193 chapter handoff pulled a future reckoning reservation early")
	_expect(GameState.has_deferred_event("arc_37_reckoning"),
		"W193 chapter handoff discarded a future reckoning reservation")
	game.free()

func _check_chapter5_causal_direct_week_ownership() -> void:
	_prepare_chapter5_product_path()
	GameState.player_route = "직장형"
	_expect_chapter5_direct_route_rejected("career route")
	_prepare_chapter5_product_path()
	GameState.player_route = "창업형"
	_expect_chapter5_direct_route_rejected("startup route")
	_prepare_chapter5_product_path()
	GameState.flags.erase("route_invest")
	_expect_chapter5_direct_route_rejected("unearned investment identity")
	_prepare_chapter5_product_path()
	GameState.money = 1_999_999_999.0
	_expect_chapter5_direct_route_rejected("assets below 2 billion")
	_prepare_chapter5_product_path()
	GameState.flags.erase("arc_minseo_02_seen")
	_expect_chapter5_direct_route_rejected("missing Minseo context")
	_prepare_chapter5_product_path()
	GameState.flags["daeun_let_her_go"] = true
	_expect_chapter5_direct_route_rejected("Daeun sent away Path A")

	_prepare_chapter5_product_path()
	GameState.action_points = GameState.max_action_points
	var game = _new_main_game()
	game.set_meta("_screenshot_qa_static_surface", true)
	_expect(game._route_chapter5_causal_week(),
		"W195 Chapter 5 direct receipt week did not route")
	_expect(GameState.pending_story_queue == [
		"arc_y5_contract_cover_investment"],
		"W195 Chapter 5 direct route opened the wrong story root")
	var entry := GameState.chapter5_causal_entry_snapshot()
	_expect(str(entry.get("route_id", "")) == "investment_property" \
		and int(entry.get("turn", -1)) == 195 \
		and str(entry.get("economic_route", "")) == "investment" \
		and str(entry.get("asset_band", "")) == "at_least_2b" \
		and (entry.get("actor_bindings", {}) as Dictionary).get(
			"protected_person", "") == "daeun",
		"W195 story displayed before the exact durable entry context was locked")
	_expect(int(GameState.flags.get("foreground_story_turn", -1)) == 195,
		"W195 Chapter 5 route did not own its foreground week")
	var money_before: float = float(GameState.money)
	var ap_before: int = int(GameState.action_points)
	var result := GameState.record_chapter5_causal_choice(
		"arc_y5_contract_cover_investment", 2)
	_expect(bool(result.get("ok", false)) \
		and GameState.chapter5_causal_week_completed(),
		"W195 Chapter 5 choice did not close its receipt-owned week")
	_expect(GameState.money == money_before \
		and GameState.action_points == ap_before,
		"W195 Chapter 5 receipt duplicated money/AP gameplay effects")
	GameState.money = 0.0
	GameState.player_route = "직장형"
	GameState.flags.erase("route_invest")
	GameState.flags["daeun_let_her_go"] = true
	_expect(game._complete_chapter5_causal_week_after_story(),
		"durable entry did not close W195 after assets/identity/relationship fell")
	_expect(GameState.turn == 196,
		"W195 Chapter 5 direct story week did not advance without the generic AP board")
	game.free()

	_check_chapter5_w209_mirror_fallback()

func _check_chapter5_w209_mirror_fallback() -> void:
	# Mark unrelated one-shots complete so _next_arc_id reaches the singular
	# Jaehyuk mirror. Then reopen only its unresolved canonical state.
	_prepare_chapter5_product_path()
	for event in DataRegistry.get_all_events():
		var event_id := str(event.get("id", ""))
		if not event_id.is_empty():
			GameState.flags["%s_seen" % event_id] = true
		for choice in event.get("choices", []):
			for raw_flag in choice.get("flags", []):
				GameState.flags[str(raw_flag)] = true
	for chapter_flag in [
		"prologue_done", "chapter_33_seen", "chapter_34_seen",
		"chapter_35_seen", "chapter_36_seen", "chapter_37_seen",
	]:
		GameState.flags[chapter_flag] = true
	for flag in CHAPTER5_REQUIRED_ENTRY_FLAGS:
		GameState.flags[flag] = true
	for flag in CHAPTER5_EXCLUDED_ENTRY_FLAGS:
		GameState.flags.erase(flag)
	GameState.flags["route_invest"] = true
	GameState.turn = 209
	GameState.money = 1_999_999_999.0
	var game = _new_main_game()
	_expect(GameState.chapter5_causal_guarantee_relocation_reserved() \
		and not GameState.chapter5_causal_product_path_available(),
		"sub-2-billion fallback fixture did not reserve unresolved mirror")
	_expect(game._next_arc_id(208, true, false) != "arc_jaehyuk_mirror",
		"reserved singular mirror escaped before W209")
	_expect(game._next_arc_id(209, true, false) == "arc_jaehyuk_mirror",
		"property-ineligible reserved candidate lost the W209 old-mirror fallback")
	GameState.money = 2_100_000_000.0
	GameState.flags["sangchul_cut_ties"] = true
	_expect(not GameState.chapter5_causal_product_path_available() \
		and game._next_arc_id(209, true, false) == "arc_jaehyuk_mirror",
		"closed Sangchul context lost the W209 old-mirror fallback")
	GameState.flags.erase("sangchul_cut_ties")
	GameState.flags.erase("arc_minseo_02_seen")
	_expect(not GameState.chapter5_causal_product_path_available() \
		and game._next_arc_id(209, true, false) == "arc_jaehyuk_mirror",
		"missing Minseo context lost the W209 old-mirror fallback")
	GameState.flags["arc_minseo_02_seen"] = true

	# Every canonical outcome resolves the singular mirror. None may allow the
	# old chain to appear again after the relocated W212 decision.
	for outcome_flag in [
		"refused_jaehyuk_guarantee",
		"vouched_jaehyuk_guarantee",
		"blocked_jaehyuk_guarantee",
	]:
		for reset_flag in [
			"arc_jaehyuk_mirror_seen",
			"refused_jaehyuk_guarantee",
			"vouched_jaehyuk_guarantee",
			"blocked_jaehyuk_guarantee",
		]:
			GameState.flags.erase(reset_flag)
		GameState.flags["arc_jaehyuk_mirror_seen"] = true
		GameState.flags[outcome_flag] = true
		_expect(game._next_arc_id(213, true, false) != "arc_jaehyuk_mirror",
			"W212 %s outcome reopened the old singular mirror" % outcome_flag)
	game.free()

func _check_foreground_commitment_weeks() -> void:
	var representatives := {
		10: "arc_ch1_career_first_spec",
		13: "cafe_cb_honest_00",
		16: "arc_father_quiet_call",
		20: "arc_job_vs_invest",
		23: "story_first_savings_milestone",
		24: "hyunsu_exam_day",
		153: "arc_y4_three_promises",
		157: "arc_36_unexpected_hand",
		161: "arc_36_body_signal",
		164: "arc_y4_body_witness",
		167: "arc_y4_family_partner_collision",
		174: "arc_father_call_on_ktx_number",
		177: "arc_y4_borrowed_name",
		181: "arc_y4_bill_night",
		185: "arc_y4_father_crisis_contact",
		188: "arc_y4_father_crisis_stabilized",
		190: "arc_y4_year_close_daeun",
		192: "arc_year4_close",
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
