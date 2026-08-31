extends Node
## ORDER-36/37: player plan, delayed consequence, and one authored decision per
## foreground week without a duplicate generic AP board.

const CHAPTER5_CAUSAL_ROUTE := preload("res://systems/Chapter5CausalRoute.gd")
const CHAPTER5_FINALE_ROUTE := preload("res://systems/Chapter5FinaleRoute.gd")
const STORY_MODE_SCRIPT := preload("res://scenes/StoryMode.gd")

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
var _captured_endings: Array[String] = []

func _capture_ending(ending_id: String) -> void:
	_captured_endings.append(ending_id)

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
	await _check_chapter5_finale_direct_week_ownership()
	_check_chapter5_general_finale_direct_week_ownership()
	_check_result_portrait_without_background()
	_check_chapter_four_father_death_recovery()
	_check_father_terminal_final_week_repair()
	_check_father_terminal_ending_descriptions()
	_check_chapter_four_terminal_router_guards()
	_check_order143_family_chain()
	_check_father_terminal_legacy_routes()
	_check_foreground_commitment_weeks()
	if _failures.is_empty():
		await _stop_fixture_audio()
		print("CORE_CHOICE_SLICE_CHECK_OK intent=1 interview=causal job_gate=ledger jiyeon_lunch=branch_gated racetrack=handoff authored=7 generic=2 ap_duplicate=0 delayed=t8 branches=2 axes=money/human missed_cost=targeted story_graph=m23_visit+hospital+door_one_shot chapter5=w193_same_queue+causal19/47+finale11/30-active9/24+general-source-w211-w220+general8/17-active6/13-w224-w229-w234-w237-w240-same-turn+read-contract+direct-no-ap+w240-two-root+fatal-return-uncovered+normal-release-uncovered father_death=monotonic_repair father_active=guarded milestone_routing=dual late_routes=variant+closed save=roundtrip")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("CORE_CHOICE_SLICE_CHECK_FAIL: %s" % failure)
	await _stop_fixture_audio()
	get_tree().quit(1)

func _stop_fixture_audio() -> void:
	BGMPlayer.stop()
	var ambience_tween: Variant = BGMPlayer.get("_ambience_tween")
	if ambience_tween is Tween and (ambience_tween as Tween).is_running():
		(ambience_tween as Tween).kill()
	for player_key in [
		"_player_a", "_player_b", "_ambience_player", "_season_player",
		"_human_ambience_player",
	]:
		var raw_bgm_player: Variant = BGMPlayer.get(player_key)
		if is_instance_valid(raw_bgm_player):
			(raw_bgm_player as AudioStreamPlayer).stop()
			(raw_bgm_player as AudioStreamPlayer).stream = null
	var fixture_pool: Array = (AudioManager.get("_pool") as Array).duplicate()
	for raw_player in fixture_pool:
		if is_instance_valid(raw_player):
			(raw_player as AudioStreamPlayer).stop()
			(raw_player as AudioStreamPlayer).stream = null
			raw_player.free()
	(AudioManager.get("_pool") as Array).clear()
	# AudioServer releases active AudioStreamPlayback objects on its next mix.
	# The fixture is about to exit, so release its temporary autoload pool as well;
	# otherwise the ending-stinger playbacks outlive the assertion nodes.
	await get_tree().create_timer(0.25).timeout
	for _release_frame in range(4):
		await get_tree().process_frame

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

func _complete_chapter5_causal_product_route() -> bool:
	_prepare_chapter5_product_path()
	if not GameState.prepare_chapter5_causal_route_entry():
		return false
	var choice_indices := {
		"arc_y5_jaehyuk_guarantee_decision_reference": 1,
		"arc_sangchul_final_door": 0,
		"arc_y5_three_in_room_decision": 1,
	}
	for turn_value in range(195, 221):
		GameState.turn = turn_value
		while true:
			var event_id := GameState.chapter5_causal_next_event_for_turn()
			if event_id.is_empty():
				break
			var result := GameState.record_chapter5_causal_choice(
				event_id, int(choice_indices.get(event_id, 0)))
			if not bool(result.get("ok", false)):
				return false
	return CHAPTER5_CAUSAL_ROUTE.route_complete(
		GameState.chapter5_causal_state)

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
	GameState.turn = 93
	GameState.flags = {"arc_father_03_seen": true, "arc_sangchul_human_seen": true}
	GameState.cast["sangchul"]["affinity"] = 64
	_expect(not game._story_event_prerequisites_met(
		"arc_sangchul_mirror", 93, GameState.flags),
		"Sangchul mirror passed below affinity 65")
	GameState.cast["sangchul"]["affinity"] = 65
	_expect(game._story_event_prerequisites_met(
		"arc_sangchul_mirror", 93, GameState.flags),
		"Sangchul mirror failed at affinity 65")
	for blocker in ["father_passed", "arc_sangchul_mirror_seen"]:
		GameState.flags[blocker] = true
		_expect(not game._story_event_prerequisites_met(
			"arc_sangchul_mirror", 93, GameState.flags),
			"Sangchul mirror ignored blocker %s" % blocker)
		GameState.flags.erase(blocker)
	GameState.turn = 94
	GameState.flags = {"arc_sangchul_mirror_seen": true}
	GameState.current_job = {}
	GameState.job_tenure = 99
	_expect(not game._story_event_prerequisites_met(
		"arc_career_ceiling", 94, GameState.flags),
		"career truthy guard accepted an empty job with stale tenure")
	GameState.current_job = DataRegistry.get_job("job_01").duplicate(true)
	GameState.job_tenure = 5
	_expect(not game._story_event_prerequisites_met(
		"arc_career_ceiling", 94, GameState.flags),
		"career ceiling passed below six-month tenure")
	GameState.job_tenure = 6
	_expect(game._story_event_prerequisites_met(
		"arc_career_ceiling", 94, GameState.flags),
		"career ceiling failed at six-month tenure")
	GameState.flags["arc_career_ceiling_seen"] = true
	_expect(not game._story_event_prerequisites_met(
		"arc_career_ceiling", 94, GameState.flags),
		"career ceiling ignored its seen blocker")
	GameState.turn = 96
	GameState.flags = {"arc_father_03_seen": true}
	_expect(game._story_event_prerequisites_met(
		"arc_father_04_visit", 96, GameState.flags),
		"father door failed its exact clean W96 ingress")
	for blocker in ["father_passed", "visited_father", "father_visit_deferred"]:
		GameState.flags[blocker] = true
		_expect(not game._story_event_prerequisites_met(
			"arc_father_04_visit", 96, GameState.flags),
			"father door ignored blocker %s" % blocker)
		GameState.flags.erase(blocker)
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
		{"turn": 100, "event": "arc_father_05_after_visit",
			"erase": ["arc_father_05_seen", "father_visit_deferred"],
			"set": ["visited_father"]},
		{"turn": 102, "event": "arc_father_06_confession",
			"erase": ["arc_father_06_seen"],
			"set": ["visited_father", "arc_father_05_seen",
				"arc_sangchul_02_seen"]},
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


func _prepare_order143_family_state() -> void:
	_prepare_chapter_four_router_state()
	GameState.flags["arc_father_02_done"] = true
	GameState.flags["arc_father_medication_seen"] = true
	for flag_id in [
		"arc_34_parents_visit_seen",
		"arc_father_03_seen",
		"visited_father",
		"father_visit_deferred",
		"arc_year2_close_seen",
	]:
		GameState.flags.erase(flag_id)


func _check_order143_family_chain() -> void:
	# A branch flag without the source receipt is corrupt evidence, not a license
	# to invent Daeun's missing same-scene receipt. A real interrupted source may
	# still recover it inside M22.
	_prepare_order143_family_state()
	GameState.flags.erase("arc_daeun_fork_seen")
	GameState.flags.erase("arc_daeun_fork_receipt_seen")
	GameState.flags.erase("daeun_let_her_go")
	GameState.flags["daeun_chose_her"] = true
	var game = _new_main_game()
	_expect(game._story_graph_contract_event_id(
			86, GameState.flags, false).is_empty(),
		"M22 branch-only corruption fabricated a Daeun hold receipt")
	GameState.flags["arc_daeun_fork_seen"] = true
	_expect(game._story_graph_contract_event_id(
			86, GameState.flags, false) == "arc_daeun_03_fork_hold_receipt",
		"M22 interrupted Daeun source lost its hold receipt recovery")
	game.free()

	# M20 owns only the door theme. Neither the parents nor the hospital may
	# pre-fire before the exact M23 family chain.
	_prepare_order143_family_state()
	GameState.flags.erase("arc_34_doors_open_seen")
	game = _new_main_game()
	var w77_route: String = game._next_arc_id(77, true, false)
	_expect(w77_route == "arc_34_doors_open",
		"W77 did not preserve the door owner or pre-fired the parents: %s" \
				% w77_route)
	game.free()

	_prepare_order143_family_state()
	GameState.flags["arc_34_doors_open_seen"] = true
	game = _new_main_game()
	var w82_route: String = game._next_arc_id(82, true, false)
	_expect(w82_route not in ["arc_34_parents_visit", "arc_father_03_hospital"],
		"W82 normal save pre-fired the M23 family chain: %s" % w82_route)
	game.free()

	# W89 owns the visit and authored four-day hospital time cut. W96 owns the
	# hospital-door boss decision after mirror/career. Apply the real choices so this is transaction
	# evidence, not only a string-selector assertion.
	_prepare_order143_family_state()
	GameState.flags["arc_34_doors_open_seen"] = true
	game = _new_main_game()
	var w89_route: String = game._next_arc_id(89, true, false)
	_expect(w89_route == "arc_34_parents_visit",
		"W89 living prerequisites did not open the parents visit: %s" % w89_route)
	GameState.flags["arc_father_03_seen"] = true
	_expect(game._story_graph_contract_event_id(
			89, GameState.flags, false) != "arc_34_parents_visit",
		"W89 inverse hospital receipt replayed the parents visit")
	GameState.flags.erase("arc_father_03_seen")
	GameState.flags["arc_34_parents_visit_seen"] = true
	_expect(not game._story_event_prerequisites_met(
			"arc_34_parents_visit", 89, GameState.flags),
		"M23 seen parents visit remained generically eligible")
	_expect(game._story_graph_contract_event_id(
			89, GameState.flags, false) == "arc_father_03_hospital",
		"M23 parent receipt did not recover the missing hospital call")
	GameState.flags.erase("arc_34_parents_visit_seen")
	var story = STORY_MODE_SCRIPT.new()
	var parents: Dictionary = DataRegistry.find_event("arc_34_parents_visit")
	var parent_choices: Array = parents.get("choices", [])
	_expect(parent_choices.size() == 2,
		"M23 parents visit lost its two human decisions")
	for choice_index in range(parent_choices.size()):
		var parent_choice: Dictionary = parent_choices[choice_index]
		_expect(story._choice_follow_up_id(
				parent_choice, "arc_34_parents_visit", choice_index) \
				== "arc_father_03_hospital",
			"M23 parents choice %d lost the four-day hospital time cut" \
					% choice_index)
	var parent_choice: Dictionary = parent_choices[0]
	_expect(GameState.apply_choice(parents, parent_choice) \
		and GameState.flags.get("arc_34_parents_visit_seen", false),
		"M23 parents choice did not commit its one-shot receipt")
	var hospital: Dictionary = DataRegistry.find_event("arc_father_03_hospital")
	var hospital_choices: Array = hospital.get("choices", [])
	_expect(hospital_choices.size() == 4 \
		and GameState.apply_choice(hospital, hospital_choices[1] as Dictionary) \
		and GameState.flags.get("arc_father_03_seen", false),
		"M23 hospital call did not commit after the parent visit")
	w89_route = game._next_arc_id(89, true, false)
	_expect(w89_route != "arc_father_04_visit",
		"M23 hospital receipt pre-fired the W96 door decision: %s" \
				% w89_route)
	GameState.flags.erase("arc_sangchul_03_seen")
	GameState.flags.erase("arc_sangchul_mirror_seen")
	GameState.flags.erase("arc_sangchul_mirror_receipt_seen")
	GameState.flags.erase("sangchul_mirror_hospital_face_up")
	GameState.flags.erase("sangchul_mirror_deal_face_up")
	GameState.flags.erase("arc_career_ceiling_seen")
	GameState.flags["arc_sangchul_human_seen"] = true
	GameState.apply_cast_effect("sangchul", {"affinity": 100})
	GameState.current_job = DataRegistry.get_job("job_01").duplicate(true)
	GameState.job_tenure = 6
	_expect(game._next_arc_id(93, true, false) == "arc_sangchul_mirror",
		"W93 mirror did not follow the hospital fact")
	GameState.flags["arc_sangchul_mirror_seen"] = true
	_expect(game._next_arc_id(94, true, false) == "arc_sangchul_mirror_receipt",
		"W94 interrupted mirror did not recover its receipt before career")
	GameState.flags["sangchul_mirror_hospital_face_up"] = true
	GameState.flags["arc_sangchul_mirror_receipt_seen"] = true
	_expect(game._next_arc_id(94, true, false) == "arc_career_ceiling",
		"W94 employed six-month route lost the salary ceiling")
	GameState.flags["arc_career_ceiling_seen"] = true
	var w96_route: String = game._next_arc_id(96, true, false)
	_expect(w96_route == "arc_father_04_visit",
		"W96 did not prioritize the hospital-door boss: %s" % w96_route)
	var father_decision: Dictionary = DataRegistry.find_event("arc_father_04_visit")
	_expect(not str(father_decision.get("description", "")).contains("상철") \
		and (father_decision.get("description_if_known", {}) as Dictionary).has(
			"arc_sangchul_03_seen"),
		"network-free father route fabricated Sangchul context")
	var father_choices: Array = father_decision.get("choices", [])
	var year2_close: Dictionary = DataRegistry.find_event("arc_year2_close")
	for choice_index in range(father_choices.size()):
		_prepare_order143_family_state()
		GameState.turn = 96
		GameState.flags["arc_34_parents_visit_seen"] = true
		GameState.flags["arc_father_03_seen"] = true
		var queue_game = _new_main_game()
		queue_game._go_story_mode(["arc_father_04_visit"])
		_expect(GameState.pending_story_queue.size() >= 2 \
			and GameState.pending_story_queue[0] == "arc_father_04_visit" \
			and GameState.pending_story_queue[1] == "arc_year2_close" \
			and GameState.pending_story_queue.count("arc_year2_close") == 1,
			"W96 father choice %d lost or duplicated close queue: %s" \
					% [choice_index, GameState.pending_story_queue])
		_expect(GameState.apply_choice(
				father_decision, father_choices[choice_index] as Dictionary),
			"W96 father choice %d did not commit" % choice_index)
		var close_choices: Array = year2_close.get("choices", [])
		_expect(not close_choices.is_empty() and GameState.apply_choice(
				year2_close, close_choices[0] as Dictionary),
			"W96 father choice %d did not commit Year 2 close" % choice_index)
		GameState.pending_story_queue = []
		GameState.flags.erase("foreground_story_turn")
		_expect(queue_game._next_arc_id(97, true, false) != "arc_year2_close",
			"W97 replayed Year 2 close after father choice %d" % choice_index)
		queue_game.free()
	_prepare_order143_family_state()
	GameState.turn = 96
	GameState.flags["arc_34_parents_visit_seen"] = true
	GameState.flags["arc_father_03_seen"] = true
	GameState.flags["arc_year2_close_seen"] = true
	var damaged_game = _new_main_game()
	damaged_game._go_story_mode(["arc_father_04_visit"])
	_expect(GameState.pending_story_queue.count("arc_year2_close") == 0,
		"damaged save replayed an already-seen Year 2 close")
	damaged_game.free()
	_prepare_order143_family_state()
	GameState.flags["arc_34_parents_visit_seen"] = true
	GameState.flags["arc_father_03_seen"] = true
	father_decision = DataRegistry.find_event("arc_father_04_visit")
	father_choices = father_decision.get("choices", [])
	_expect(father_choices.size() == 4 \
		and GameState.apply_choice(father_decision, father_choices[0] as Dictionary),
		"M23 hospital-door choice did not commit")
	w96_route = game._next_arc_id(96, true, false)
	_expect(w96_route == "arc_year2_close",
		"W96 door receipt did not release Year 2 close: %s" % w96_route)
	game.free()
	story.free()

	# The fourth door choice is also terminal for this month, and any monotonic
	# death evidence blocks all three living-Father roots.
	_prepare_order143_family_state()
	GameState.flags["arc_34_parents_visit_seen"] = true
	GameState.flags["arc_father_03_seen"] = true
	father_decision = DataRegistry.find_event("arc_father_04_visit")
	father_choices = father_decision.get("choices", [])
	_expect(GameState.apply_choice(father_decision, father_choices[3] as Dictionary) \
		and GameState.flags.get("father_visit_deferred", false),
		"W96 deferred door choice did not close its owner month")
	game = _new_main_game()
	_expect(game._next_arc_id(96, true, false) == "arc_year2_close",
		"W96 deferred door choice did not release Year 2 close")
	game.free()

	_prepare_order143_family_state()
	GameState.flags["father_passed"] = true
	game = _new_main_game()
	w89_route = game._next_arc_id(89, true, false)
	_expect(w89_route not in [
		"arc_34_parents_visit", "arc_father_03_hospital", "arc_father_04_visit"],
		"terminal Father evidence reopened the M23 family chain: %s" % w89_route)
	game.free()

	game = _new_main_game()
	var m34_cases: Array[Dictionary] = [
		{"turn": 133, "flag": "arc_sangchul_reckoning_seen"},
		{"turn": 134, "flag": "sangchul_truth_buried"},
		{"turn": 136, "flag": "sangchul_quietly_distanced"},
	]
	for route_case in m34_cases:
		var route_flags := {str(route_case["flag"]): true}
		_expect(game._story_graph_contract_event_id(
				int(route_case["turn"]), route_flags, false) \
				== "arc_y3_cost_of_knowing",
			"M34 typed aftermath lost %s" % route_case["flag"])
		route_flags["arc_y3_cost_of_knowing_seen"] = true
		_expect(game._story_graph_contract_event_id(
				int(route_case["turn"]), route_flags, false).is_empty(),
			"M34 typed aftermath replayed %s" % route_case["flag"])
	game.free()

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

func _check_chapter5_finale_direct_week_ownership() -> void:
	_expect(_complete_chapter5_causal_product_route(),
		"M49-M55 causal source route could not reach its exact final receipt")
	_expect((GameState.chapter5_causal_state.get("order", []) as Array).size() == 19 \
		and CHAPTER5_CAUSAL_ROUTE.EXPECTED_CHOICE_COUNT == 47,
		"M49-M55 causal 19-root/47-choice inventory regressed")
	GameState.turn = 221
	GameState.action_points = GameState.max_action_points
	var economic_before := {
		"money": GameState.money,
		"portfolio": GameState.portfolio.duplicate(true),
		"loans": GameState.loans.duplicate(true),
		"health": GameState.health,
		"mental": GameState.mental,
		"intelligence": GameState.intelligence,
		"investment_skill": GameState.investment_skill,
		"moral_tint": GameState.moral_tint,
	}
	_expect(GameState.prepare_chapter5_finale_route_entry(),
		"W221 did not lock the completed causal route into the safe finale")
	var entry := GameState.chapter5_finale_entry_snapshot()
	_expect(str(entry.get("profile_id", "")) == "investment_safe_no_execution" \
		and str(entry.get("source_route_id", "")) == "investment_property" \
		and (entry.get("source_choices", {}) as Dictionary) == {
			"m55_decision": 1,
			"w212_guarantee": 1,
			"w215_final_door": 0,
		} \
		and str((entry.get("father", {}) as Dictionary).get("life", "")) == "alive",
		"W221 finale entry did not preserve exact source choices/father trace")
	var first_event_id := GameState.chapter5_finale_next_event_for_turn()
	_expect(first_event_id == "arc_y5_father_trace_alive_exact",
		"W221 finale selected the wrong father-trace variant")

	# Exercise the actual localized StoryMode loading path. Its deep source-array
	# equality must accept the canonical authored surface and reject a same-shape
	# source identity substitution before any choice can be shown.
	var story = STORY_MODE_SCRIPT.new()
	var raw_first: Dictionary = DataRegistry.find_event(first_event_id)
	var localized: Dictionary = story.call("_localized_story_event", first_event_id)
	_expect(not localized.is_empty() \
		and str(localized.get("id", "")) == first_event_id \
		and str(localized.get("description", "")) \
			!= str(raw_first.get("description", "")),
		"StoryMode actual loader did not prepend the exact finale read contract")
	var tampered_first: Dictionary = raw_first.duplicate(true)
	var tampered_reads: Dictionary = (
		tampered_first.get("chapter5_finale_reads", {}) as Dictionary).duplicate(true)
	var tampered_sources: Array = (
		tampered_reads.get("sources", []) as Array).duplicate(true)
	if not tampered_sources.is_empty():
		var tampered_source: Dictionary = (
			tampered_sources[0] as Dictionary).duplicate(true)
		tampered_source["id"] = "arc_y5_three_in_room"
		tampered_sources[0] = tampered_source
		tampered_reads["sources"] = tampered_sources
		tampered_first["chapter5_finale_reads"] = tampered_reads
	_expect((story.call(
		"_chapter5_finale_event_with_reads", tampered_first) as Dictionary).is_empty(),
		"StoryMode accepted a finale read source with substituted identity")

	var game = _new_main_game()
	game.set_meta("_screenshot_qa_static_surface", true)
	GameState.pending_story_queue = []
	_expect(game._route_chapter5_finale_week() \
		and GameState.pending_story_queue == [first_event_id] \
		and int(GameState.flags.get("foreground_story_turn", -1)) == 221,
		"W221 finale did not enter StoryMode as the direct foreground action")
	var before_rejected: Dictionary = GameState.serialize().duplicate(true)
	var rejected := GameState.record_chapter5_finale_choice(first_event_id, 99)
	_expect(not bool(rejected.get("ok", false)) \
		and GameState.serialize() == before_rejected,
		"rejected finale choice did not roll the whole live state back byte-exact")
	var accepted := GameState.record_chapter5_finale_choice(first_event_id, 0)
	_expect(bool(accepted.get("ok", false)) \
		and GameState.chapter5_finale_week_completed(221) \
		and GameState.action_points == GameState.max_action_points,
		"W221 finale receipt changed AP or failed to close its direct week")
	_expect(game._complete_chapter5_finale_week_after_story() \
		and GameState.turn == 222,
		"W221 finale returned to a generic AP question instead of advancing")

	var direct_turns: Array[int] = [224, 227, 230, 235, 238, 239, 240]
	for direct_turn in direct_turns:
		GameState.turn = direct_turn
		GameState.pending_story_queue = []
		GameState.flags.erase("foreground_story_turn")
		var event_id := GameState.chapter5_finale_next_event_for_turn()
		_expect(not event_id.is_empty() and game._route_chapter5_finale_week() \
			and GameState.pending_story_queue == [event_id] \
			and int(GameState.flags.get("foreground_story_turn", -1)) == direct_turn,
			"finale exact direct ingress failed at W%d" % direct_turn)
		var event: Dictionary = DataRegistry.find_event(event_id)
		var choice_index := 0
		if direct_turn == 240:
			GameState.apply_choice(event, (event.get("choices", []) as Array)[choice_index])
		var result := GameState.record_chapter5_finale_choice(
			event_id, choice_index)
		_expect(bool(result.get("ok", false)),
			"finale receipt commit failed at W%d/%s" % [direct_turn, event_id])
		if direct_turn == 240:
			_expect(GameState.chapter5_finale_next_event_for_turn() \
				== "arc_y5_final_week_daeun_outbound",
				"W240 signature did not expose the outbound root in the same turn")
			# StoryMode returns a newly fatal choice to MainGame before it queues
			# authored follow-ups. The canonical failure must win that race; otherwise
			# the outbound guard bounces between the two scenes forever.
			var before_fatal_return: Dictionary = GameState.serialize().duplicate(true)
			var meta_before_fatal_return: Dictionary = MetaProgression.data.duplicate(true)
			var unlocks_before_fatal_return: Dictionary = \
				MetaProgression.get("_new_this_run").duplicate(true)
			GameState.mental = 0
			GameState.pending_story_queue = []
			_captured_endings.clear()
			var ending_callback := Callable(self, "_capture_ending")
			GameState.game_over.connect(ending_callback, CONNECT_ONE_SHOT)
			var transition_overlay := SceneTransition.get("_overlay") as ColorRect
			_expect(is_instance_valid(transition_overlay),
				"fatal W240 return test could not inspect the global cover")
			if is_instance_valid(transition_overlay):
				SceneTransition.call("_set_transition_alpha", 1.0)
				transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
			game._continue_after_story()
			await _wait_for_transition_uncovered()
			if GameState.game_over.is_connected(ending_callback):
				GameState.game_over.disconnect(ending_callback)
			_expect(GameState.is_game_over \
				and _captured_endings == ["mental_break"] \
				and GameState.pending_story_queue.is_empty() \
				and is_instance_valid(transition_overlay) \
				and transition_overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE \
				and float(SceneTransition.get("_transition_alpha")) <= 0.01,
				"fatal W240 return hid or rerouted the mental-break ending")
			MetaProgression.data = meta_before_fatal_return
			MetaProgression.set("_new_this_run", unlocks_before_fatal_return)
			GameState.load_from_dict(before_fatal_return)
			story.set("_queue", [])
			story.call("_queue_chapter5_finale_same_turn_ingress")
			_expect(story.get("_queue") == [
				"arc_y5_final_week_daeun_outbound"],
				"StoryMode did not recover W240 signature -> outbound in one queue")
			var outbound_id := GameState.chapter5_finale_next_event_for_turn()
			var outbound: Dictionary = DataRegistry.find_event(outbound_id)
			GameState.apply_choice(
				outbound, (outbound.get("choices", []) as Array)[0])
			var outbound_result := GameState.record_chapter5_finale_choice(
				outbound_id, 0)
			_expect(bool(outbound_result.get("ok", false)),
				"W240 outbound receipt did not commit after signature")

	var nontransaction: Dictionary = (
		GameState.chapter5_finale_state.get("receipts", {}) as Dictionary).get(
			"arc_y5_property_not_executed_notice", {})
	_expect(CHAPTER5_FINALE_ROUTE.EXPECTED_ROOT_COUNT == 11 \
		and CHAPTER5_FINALE_ROUTE.EXPECTED_CHOICE_COUNT == 30 \
		and (GameState.chapter5_finale_state.get("order", []) as Array).size() == 9 \
		and CHAPTER5_FINALE_ROUTE.EXPECTED_ACTIVE_CHOICE_COUNT == 24 \
		and nontransaction.get("economic_outcome", {}) \
			== CHAPTER5_FINALE_ROUTE.NO_EXECUTABLE_CONTRACT_OUTCOME \
		and GameState.chapter5_finale_week_completed(240) \
		and GameState.chapter5_finale_ending_ready(),
		"M56-M60 11/30-active9/24/no-execution/ready contract regressed")
	_expect(GameState.money == economic_before["money"] \
		and GameState.portfolio == economic_before["portfolio"] \
		and GameState.loans == economic_before["loans"] \
		and GameState.health == economic_before["health"] \
		and GameState.mental == economic_before["mental"] \
		and GameState.intelligence == economic_before["intelligence"] \
		and GameState.investment_skill == economic_before["investment_skill"] \
		and GameState.moral_tint == economic_before["moral_tint"] \
		and not bool(GameState.flags.get("final_week_self_approval", false)) \
		and not bool(GameState.flags.get("final_week_gratitude", false)),
		"finale invented a hidden stat/economic result or legacy outbound meaning")

	# A normal outbound return is also covered by StoryMode. Consuming the ready
	# latch must emit one ending and uncover that modal on the same MainGame visit.
	var before_normal_release: Dictionary = GameState.serialize().duplicate(true)
	var meta_before_normal_release: Dictionary = MetaProgression.data.duplicate(true)
	var unlocks_before_normal_release: Dictionary = \
		MetaProgression.get("_new_this_run").duplicate(true)
	_captured_endings.clear()
	var normal_ending_callback := Callable(self, "_capture_ending")
	GameState.game_over.connect(normal_ending_callback, CONNECT_ONE_SHOT)
	var normal_transition_overlay := SceneTransition.get("_overlay") as ColorRect
	_expect(is_instance_valid(normal_transition_overlay),
		"normal W240 release test could not inspect the global cover")
	if is_instance_valid(normal_transition_overlay):
		SceneTransition.call("_set_transition_alpha", 1.0)
		normal_transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var normal_release_owned: bool = \
		game._complete_chapter5_finale_week_after_story()
	await _wait_for_transition_uncovered()
	if GameState.game_over.is_connected(normal_ending_callback):
		GameState.game_over.disconnect(normal_ending_callback)
	_expect(normal_release_owned \
		and GameState.is_game_over \
		and GameState.chapter5_finale_ending_consumed() \
		and _captured_endings == ["with_daeun"] \
		and is_instance_valid(normal_transition_overlay) \
		and normal_transition_overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE \
		and float(SceneTransition.get("_transition_alpha")) <= 0.01,
		"normal W240 release hid, duplicated, or skipped its canonical ending")
	MetaProgression.data = meta_before_normal_release
	MetaProgression.set("_new_this_run", unlocks_before_normal_release)
	GameState.load_from_dict(before_normal_release)
	story.free()
	game.free()

func _wait_for_transition_uncovered() -> void:
	# A mouse-passable cover can still be visually black. Give the real fade tween
	# enough frames to complete, then let the caller assert the canonical alpha.
	for _frame in range(90):
		if float(SceneTransition.get("_transition_alpha")) <= 0.01:
			return
		await get_tree().process_frame


func _check_chapter5_general_finale_direct_week_ownership() -> void:
	_seed_chapter5_general_w211_prechoice("투자형")
	GameState.turn = 211
	GameState.flags["chapter_37_seen"] = true
	var w211_game = _new_main_game()
	var routed_w211 := str(w211_game._next_arc_id(211, true, false))
	_expect(GameState.chapter5_general_finale_w211_available(211) \
		and routed_w211 == "arc_y5_general_name_boundary_exact",
		"general W211 exact source did not win the live MainGame router: %s" \
		% routed_w211)
	var w211_event: Dictionary = DataRegistry.find_event(
		"arc_y5_general_name_boundary_exact")
	var w211_choices: Array = w211_event.get("choices", [])
	_expect(w211_choices.size() == 2 \
		and GameState.apply_choice(w211_event, w211_choices[0] as Dictionary) \
		and not GameState.chapter5_general_finale_w211_available(211) \
		and w211_game._next_arc_id(211, true, false) \
			!= "arc_y5_general_name_boundary_exact",
		"general W211 did not become non-replayable after its exact choice")
	w211_game.free()

	_seed_chapter5_general_direct_sources("투자형", false)
	_saturate_seen_guards_for_w220_router_fixture()
	GameState.turn = 220
	var w220_game = _new_main_game()
	var w220_available := GameState.chapter5_general_finale_w220_available(220)
	_expect(w220_available,
		"general W220 exact source was unavailable for the coherent profile")
	var routed_w220 := str(w220_game._next_arc_id(220, true, false))
	_expect(routed_w220 == "arc_y5_general_debt_memory_reconnect",
		"general W220 exact source did not win the live MainGame router: %s" \
		% routed_w220)
	_expect(w220_game._chapter5_general_w220_reserves_generic(219) \
		and not w220_game._chapter5_general_w220_reserves_generic(221),
		"the W220 reservation did not release the generic fallback after its slot")
	var w220_event: Dictionary = DataRegistry.find_event(
		"arc_y5_general_debt_memory_reconnect")
	GameState.apply_choice(w220_event, (w220_event.get("choices", []) as Array)[0])
	_expect(bool(GameState.flags.get("arc_endgame_sixmonths_seen", false)) \
		and w220_game._next_arc_id(221, true, false) != "arc_endgame_sixmonths",
		"general W220 did not suppress the duplicate generic six-month stop")
	w220_game.free()

	# The duplicate guard is bidirectional. A run that already received the
	# generic stop before its exact M51 receipt became available may not surface
	# the W220 replacement later.
	_seed_chapter5_general_direct_sources("투자형", false)
	GameState.flags["arc_endgame_sixmonths_seen"] = true
	GameState.event_log.push_front({
		"event_id": "arc_endgame_sixmonths", "choice_index": 0, "turn": 216})
	GameState.turn = 220
	var generic_first_game = _new_main_game()
	_expect(not GameState.chapter5_general_finale_w220_available(220) \
		and generic_first_game._next_arc_id(220, true, false) \
			!= "arc_y5_general_debt_memory_reconnect",
		"generic six-month evidence did not suppress the later W220 replacement")
	generic_first_game.free()

	_seed_chapter5_general_direct_sources("투자형", true, 0)
	var game = _new_main_game()
	game.set_meta("_screenshot_qa_static_surface", true)
	var direct_steps: Array[Dictionary] = [
		{
			"turn": 224,
			"event_id": "arc_y5_general_father_legacy_voice_exact",
			"choice": 0,
		},
		{
			"turn": 229,
			"event_id": "arc_y5_general_debt_memory_voice_exact",
			"choice": 1,
		},
		{
			"turn": 234,
			"event_id": "arc_y5_general_pre_ending_summit_exact",
			"choice": 0,
		},
	]
	for step in direct_steps:
		var direct_turn := int(step["turn"])
		var direct_event_id := str(step["event_id"])
		GameState.turn = direct_turn
		GameState.pending_story_queue = []
		GameState.flags.erase("foreground_story_turn")
		_expect(game._route_chapter5_finale_week() \
			and GameState.pending_story_queue == [direct_event_id] \
			and int(GameState.flags.get(
				"foreground_story_turn", -1)) == direct_turn,
			"general W%d did not route %s as direct foreground" \
			% [direct_turn, direct_event_id])
		_expect(bool(GameState.record_chapter5_finale_choice(
			direct_event_id, int(step["choice"])).get("ok", false)) \
			and GameState.chapter5_finale_week_completed(direct_turn),
			"general W%d receipt did not close its direct week" % direct_turn)

	GameState.turn = 237
	GameState.pending_story_queue = []
	GameState.flags.erase("foreground_story_turn")
	_expect(game._route_chapter5_finale_week() \
		and GameState.pending_story_queue == ["arc_y5_general_final_record_seal"] \
		and int(GameState.flags.get("foreground_story_turn", -1)) == 237,
		"general W237 did not enter as direct foreground story")
	# Exercise the real localized inline-read path after all three predecessor
	# receipts exist. Token validation itself is owned by StoryMode's checks.
	var general_read_story = STORY_MODE_SCRIPT.new()
	var raw_general_w237: Dictionary = DataRegistry.find_event(
		"arc_y5_general_final_record_seal")
	var localized_general_w237: Dictionary = general_read_story.call(
		"_localized_story_event", "arc_y5_general_final_record_seal")
	_expect(not localized_general_w237.is_empty() \
		and str(localized_general_w237.get("id", "")) \
			== "arc_y5_general_final_record_seal" \
		and str(localized_general_w237.get("description", "")) \
			!= str(raw_general_w237.get("description", "")) \
		and "[[c5read:" not in str(localized_general_w237.get(
			"description", "")),
		"StoryMode actual loader did not resolve the general W237 inline reads")
	general_read_story.free()
	# A locale switch resolves the event again. If the selected locale's inline
	# surface is invalid, the live route must close instead of retaining old-
	# language prose underneath the newly selected UI language.
	var valid_general_state: Dictionary = \
		GameState.chapter5_finale_state.duplicate(true)
	var missing_summit_state: Dictionary = valid_general_state.duplicate(true)
	var missing_summit_receipts: Dictionary = (
		missing_summit_state.get("receipts", {}) as Dictionary).duplicate(true)
	missing_summit_receipts.erase("arc_y5_general_pre_ending_summit_exact")
	missing_summit_state["receipts"] = missing_summit_receipts
	var missing_summit_order: Array = (
		missing_summit_state.get("order", []) as Array).duplicate()
	missing_summit_order.erase("arc_y5_general_pre_ending_summit_exact")
	missing_summit_state["order"] = missing_summit_order
	GameState.chapter5_finale_state = missing_summit_state
	var language_refresh_story = STORY_MODE_SCRIPT.new()
	language_refresh_story.set("_current", raw_general_w237)
	language_refresh_story.set("_queue", ["arc_y5_general_final_record_seal"])
	var language_before := LocaleManager.language
	var language_after := "en" if language_before != "en" else "ko"
	language_refresh_story.call("_set_story_language", language_after)
	_expect(str(GameState.chapter5_finale_state.get("status", "")) == "closed" \
		and str(GameState.chapter5_finale_state.get("closed_reason", "")) \
			== "read_surface_invalid" \
		and (language_refresh_story.get("_current") as Dictionary).is_empty() \
		and (language_refresh_story.get("_queue") as Array).is_empty(),
		"StoryMode locale refresh kept a Chapter 5 invalid-read route open")
	LocaleManager.set_language(language_before)
	GameState.chapter5_finale_state = valid_general_state
	language_refresh_story.free()
	_expect(bool(GameState.record_chapter5_finale_choice(
		"arc_y5_general_final_record_seal", 1).get("ok", false)) \
		and GameState.chapter5_finale_week_completed(237),
		"general W237 receipt did not close its direct week")
	GameState.turn = 240
	GameState.pending_story_queue = []
	GameState.flags.erase("foreground_story_turn")
	_expect(game._route_chapter5_finale_week() \
		and GameState.pending_story_queue == [
			"arc_final_countdown_general_near_goal_passed"],
		"general W240 sacrifice did not own direct foreground")
	_expect(bool(GameState.record_chapter5_finale_choice(
		"arc_final_countdown_general_near_goal_passed", 1).get("ok", false)) \
		and GameState.chapter5_finale_next_event_for_turn() \
		== "arc_y5_final_week_general_people_outbound",
		"general W240 sacrifice did not expose same-turn outbound")
	var story = STORY_MODE_SCRIPT.new()
	story.set("_queue", [])
	story.call("_queue_chapter5_finale_same_turn_ingress")
	_expect(story.get("_queue") == ["arc_y5_final_week_general_people_outbound"],
		"StoryMode did not queue general same-turn outbound")
	story.free()
	game.free()
	GameState.start_new_game()
	GameState.turn = 224
	GameState.money = 2_500_000_000.0
	GameState.flags["father_passed"] = true
	GameState.pending_story_queue = []
	var fallback_game = _new_main_game()
	_expect(not fallback_game._route_chapter5_finale_week() \
		and GameState.pending_story_queue.is_empty() \
		and GameState.chapter5_finale_entry_snapshot().is_empty() \
		and not GameState.chapter5_finale_holds_ending(),
		"invalid general sources did not return ownership to generic scheduling")
	fallback_game.free()
	for excluded_route in ["직장형", "창업형"]:
		_seed_chapter5_general_direct_sources(excluded_route, false)
		GameState.turn = 220
		_expect(not GameState.chapter5_general_finale_w220_available(),
			"%s run exposed the general W220 foreground" % excluded_route)
		_seed_chapter5_general_direct_sources(excluded_route, true, 0)
		GameState.turn = 224
		GameState.pending_story_queue = []
		var excluded_game = _new_main_game()
		_expect(not excluded_game._route_chapter5_finale_week() \
			and GameState.pending_story_queue.is_empty() \
			and GameState.chapter5_finale_entry_snapshot().is_empty(),
			"%s run was misrouted into the general W224 foreground" \
			% excluded_route)
		excluded_game.free()


func _check_result_portrait_without_background() -> void:
	var story = STORY_MODE_SCRIPT.new()
	var portrait := TextureRect.new()
	var portrait_frame := PanelContainer.new()
	var name_panel := PanelContainer.new()
	var name_tag := Label.new()
	story.add_child(portrait)
	story.add_child(portrait_frame)
	story.add_child(name_panel)
	name_panel.add_child(name_tag)
	story.set("_portrait", portrait)
	story.set("_portrait_frame", portrait_frame)
	story.set("_name_panel", name_panel)
	story.set("_name_tag", name_tag)
	story.set("_current_presentation", {
		"channel": "in_person", "portrait_role": "present"})
	var result_choice := {"result_portrait": "daeun_normal"}
	story.set("_current", {
		"id": "result_portrait_without_background_fixture",
		"portrait": "sangchul_serious",
		"bg_focus": true,
		"choices": [result_choice],
	})
	story.call("_apply_choice_result_visual", result_choice)
	var expected_name := str(
		ImageRegistry.get_person_info("daeun_normal").get("name", ""))
	_expect(not expected_name.is_empty() \
		and name_tag.text == expected_name \
		and name_panel.visible,
		"result_portrait without result_background did not update the live speaker")
	story.set("_pending_after_result", true)
	story.set("_pending_result_choice_index", 0)
	name_tag.text = ""
	story.call("_refresh_story_speaker_language")
	_expect(story.call("_resolved_story_surface_portrait_id") == "daeun_normal" \
		and name_tag.text == expected_name,
		"standalone result_portrait was not stable on result resume/language refresh")
	story.free()


func _seed_chapter5_general_direct_sources(
		chosen_route: String, include_w220: bool = true,
		w220_choice: int = 0) -> void:
	GameState.start_new_game("김민준", "지방_상경", chosen_route)
	GameState.money = 2_500_000_000.0
	GameState.flags["father_passed"] = true
	GameState.flags["chapter5_general_minseo_arrival_1"] = true
	GameState.flags["arc_y5_general_name_boundary_exact_seen"] = true
	GameState.flags["chapter5_general_name_boundary_0"] = true
	GameState.event_log = [
		{"event_id": "arc_minseo_03_arrival", "choice_index": 1, "turn": 203},
		{
			"event_id": "arc_y5_general_name_boundary_exact",
			"choice_index": 0,
			"turn": 211,
		},
	]
	if not include_w220:
		return
	GameState.flags["arc_y5_general_debt_memory_reconnect_seen"] = true
	GameState.flags[
		"chapter5_general_debt_memory_reconnect_%d" % w220_choice] = true
	GameState.flags["arc_endgame_sixmonths_seen"] = true
	GameState.event_log.append_array([
		{
			"event_id": "arc_y5_general_debt_memory_reconnect",
			"choice_index": w220_choice,
			"turn": 220,
		},
	])


func _seed_chapter5_general_w211_prechoice(chosen_route: String) -> void:
	GameState.start_new_game("김민준", "지방_상경", chosen_route)
	GameState.money = 2_500_000_000.0
	GameState.flags["father_passed"] = true
	GameState.flags["chapter5_general_minseo_arrival_1"] = true
	GameState.event_log = [
		{"event_id": "arc_minseo_03_arrival", "choice_index": 1, "turn": 203},
	]


func _saturate_seen_guards_for_w220_router_fixture() -> void:
	var reserved := [
		"arc_y5_general_name_boundary_exact_seen",
		"arc_y5_general_debt_memory_reconnect_seen",
		"arc_y5_general_last_page_instruction_seen",
		"arc_endgame_sixmonths_seen",
		"chapter5_general_name_boundary_0",
		"chapter5_general_name_boundary_1",
		"chapter5_general_debt_memory_reconnect_0",
		"chapter5_general_debt_memory_reconnect_1",
		"chapter5_general_last_page_instruction_0",
		"chapter5_general_last_page_instruction_1",
		"chapter5_general_minseo_arrival_0",
		"chapter5_general_minseo_arrival_1",
		"route_career",
		"route_startup",
	]
	for raw_event in DataRegistry.get_all_events():
		if not raw_event is Dictionary:
			continue
		var event: Dictionary = raw_event
		var event_seen := "%s_seen" % str(event.get("id", ""))
		if event_seen not in reserved:
			GameState.flags[event_seen] = true
		for raw_choice in event.get("choices", []):
			if not raw_choice is Dictionary:
				continue
			for raw_flag in (raw_choice as Dictionary).get("flags", []):
				var flag_id := str(raw_flag)
				if flag_id not in reserved:
					GameState.flags[flag_id] = true
	GameState.flags["route_invest"] = true
	GameState.flags.erase("route_career")
	GameState.flags.erase("route_startup")
	GameState.flags["chapter5_general_minseo_arrival_1"] = true
	GameState.flags["father_passed"] = true

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
		211: "arc_y5_general_name_boundary_exact",
		220: "arc_y5_general_debt_memory_reconnect",
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
