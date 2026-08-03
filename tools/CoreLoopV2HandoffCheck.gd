extends Node
## ORDER-57: Week-24 V2 receipts must rejoin the real Chapter-One scheduler.

const CORE_LOOP := preload("res://systems/DemoCoreLoopV2.gd")

const HYUNSU_RESULT := "hyunsu_result_fail"
const HYUNSU_AFTERMATH := "arc_hyunsu_exam_fail"
const HYUNSU_DRIFT := "arc_hyunsu_drift"
const HYUNSU_NEW_PATH := "arc_hyunsu_new_path"
const CITY_RESULT := "v2_city_service_result_message"
const YEAR_ONE_CLOSE := "arc_year1_close"
const YEAR_ONE_CURATION := "arc_year1_scene"

const HANDOFF_EVENT_IDS := [
	HYUNSU_RESULT,
	HYUNSU_AFTERMATH,
	HYUNSU_DRIFT,
	HYUNSU_NEW_PATH,
	"hyunsu_pivot",
	CITY_RESULT,
	YEAR_ONE_CLOSE,
]

const WEEK_24_CANDIDATES := [
	"father_call",
	"hanbit_month_close",
	"city_work_sample",
	"daeun_checkin",
	"jaehyuk_reply",
	"sangchul_ledger",
	"urgent_paid_shift",
	"body_rest",
]

const WEEK_24_DEFERRED := [
	"father_call",
	"hanbit_month_close",
	"daeun_checkin",
	"jaehyuk_reply",
	"sangchul_ledger",
	"urgent_paid_shift",
	"body_rest",
]

var _failures: Array[String] = []
var _autosave_backup: Dictionary = {}
var _main_game: Node = null


func _ready() -> void:
	_backup_autosave()
	var original_sfx_enabled := AudioManager.sfx_enabled
	AudioManager.sfx_enabled = false

	_check_hyunsu_min_turn_and_legacy_timing()
	_check_father_signal_replaces_skipped_first_call()
	_check_v2_week_24_handoff()

	if is_instance_valid(_main_game):
		_main_game.free()
		_main_game = null
	EventManager.pending_events.clear()
	EventManager.current_event = {}
	AudioManager.sfx_enabled = original_sfx_enabled
	_restore_autosave()

	if _failures.is_empty():
		print(
			"CORE_LOOP_V2_HANDOFF_CHECK_OK "
			+ "scheduler=real_next_arc_id "
			+ "v2=week25_26_hidden/week27_fail/week31_aftermath/"
			+ "week36_drift/week42_new_path "
			+ "legacy=week25_26_fail/week29_30_aftermath/"
			+ "week34_35_drift/week40_41_new_path "
			+ "city=week28/no_offer/save_load "
			+ "father=week21_replaces_skipped_first_call "
			+ "year1=week48_exact/close_then_curation/"
			+ "selected_and_deferred/result_known "
			+ "canon=week49_chapter34/run240")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("CORE_LOOP_V2_HANDOFF_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)


func _check_hyunsu_min_turn_and_legacy_timing() -> void:
	var expected_conditions := {
		HYUNSU_AFTERMATH: {
			"flag": "hyunsu_failed",
			"no_flag": "arc_hyunsu_exam_fail_seen",
			"min_turn": 25,
		},
		HYUNSU_DRIFT: {
			"flag": "arc_hyunsu_exam_fail_seen",
			"no_flag": "arc_hyunsu_drift_seen",
			"min_turn": 30,
		},
		HYUNSU_NEW_PATH: {
			"flag": "arc_hyunsu_drift_seen",
			"no_flag": "arc_hyunsu_new_path_seen",
			"min_turn": 36,
		},
	}
	for event_id in expected_conditions:
		var event: Dictionary = DataRegistry.find_event(
			str(event_id))
		var expected: Dictionary = expected_conditions[event_id]
		var conditions: Dictionary = (
			(event.get("conditions", {}) as Dictionary).duplicate(true)
			if event.get("conditions", {}) is Dictionary else {}
		)
		_expect(
			str(conditions.get("flag", "")) \
					== str(expected.get("flag", ""))
				and str(conditions.get("no_flag", "")) \
					== str(expected.get("no_flag", ""))
				and int(conditions.get("min_turn", 0)) \
					== int(expected.get("min_turn", 0))
				and conditions.size() == 3,
			"%s lost its exact flag/no_flag/min_turn scheduler contract: %s"
				% [event_id, str(conditions)])

	# The established representative full-run paths receive the result in Week
	# 25 or 26. They must retain their authored +4/+5/+6 cadence even though the
	# V2 receipt below deliberately delays its own result until Week 27.
	_check_legacy_hyunsu_timing_path(25, 29, 34, 40)
	_check_legacy_hyunsu_timing_path(26, 30, 35, 41)


func _check_legacy_hyunsu_timing_path(
		result_week: int,
		aftermath_week: int,
		drift_week: int,
		new_path_week: int) -> void:
	_seed_legacy_hyunsu_result_fixture(result_week)
	_recreate_main_game()
	if not is_instance_valid(_main_game):
		return

	var routed_result := _route_at(result_week)
	_expect(
		routed_result == HYUNSU_RESULT,
		"legacy Week %d scheduler selected %s instead of %s"
			% [result_week, routed_result, HYUNSU_RESULT])
	if routed_result != HYUNSU_RESULT:
		return
	_apply_event_choice(HYUNSU_RESULT, 0)
	_expect(
		_exact_deferred_turn(HYUNSU_AFTERMATH) == aftermath_week,
		"legacy Week %d result did not seed the exact +4 aftermath"
			% result_week)

	_route_and_apply_deferred(aftermath_week, HYUNSU_AFTERMATH, 0)
	_expect(
		_exact_deferred_turn(HYUNSU_DRIFT) == drift_week,
		"legacy aftermath did not seed the exact +5 drift at Week %d"
			% drift_week)

	_route_and_apply_deferred(drift_week, HYUNSU_DRIFT, 0)
	_expect(
		_exact_deferred_turn(HYUNSU_NEW_PATH) == new_path_week,
		"legacy drift did not seed the exact +6 new path at Week %d"
			% new_path_week)

	_route_and_apply_deferred(new_path_week, HYUNSU_NEW_PATH, 0)
	_expect(
		bool(GameState.flags.get("hyunsu_pivoted", false))
			and bool(GameState.flags.get(
				"arc_hyunsu_new_path_seen", false))
			and not GameState.has_deferred_event("hyunsu_pivot")
			and _route_at(new_path_week) != "hyunsu_pivot",
		"legacy path scheduled or routed the obsolete duplicate pivot")


func _check_v2_week_24_handoff() -> void:
	_seed_exact_v2_week_24_state()
	_recreate_main_game()
	if not is_instance_valid(_main_game):
		return

	var initial_state := GameState.core_loop_v2_state.duplicate(true)
	for week in [25, 26]:
		var routed := _route_at(week)
		_expect(
			routed != HYUNSU_RESULT,
			"V2 scheduler exposed Hyunsu's result early in Week %d"
				% week)
		_expect(
			GameState.core_loop_v2_state == initial_state,
			"Week %d scheduler preview mutated the durable V2 receipts"
				% week)

	var result_id := _route_at(27)
	_expect(
		result_id == HYUNSU_RESULT,
		"V2 Week-27 scheduler selected %s instead of %s"
			% [result_id, HYUNSU_RESULT])
	if result_id == HYUNSU_RESULT:
		_apply_event_choice(HYUNSU_RESULT, 0)
	_expect(
		bool(GameState.flags.get("hyunsu_failed", false)),
		"V2 result choice did not set hyunsu_failed")
	_expect(
		_exact_deferred_turn(HYUNSU_AFTERMATH) == 31,
		"V2 result choice did not seed its exact Week-31 follow-up: %s"
			% str(GameState.deferred_events))
	_expect(
		_route_at(27) != HYUNSU_RESULT,
		"V2 result replayed immediately after its choice")

	var city_id := _route_at(28)
	_expect(
		city_id == CITY_RESULT,
		"Week-28 scheduler did not prioritize the selected City result: %s"
			% city_id)
	if city_id == CITY_RESULT:
		_apply_event_choice(CITY_RESULT, 0)
		_expect(
			CORE_LOOP.note_post_demo_application_result(
				CITY_RESULT, 0),
			"City result choice did not resolve its typed future receipt")

	_expect(
		CORE_LOOP.application_status(
			"city_facility_ops_2026h1") == "no_offer"
			and CORE_LOOP.post_demo_application_result_event_id(
				28).is_empty()
			and _exact_city_transition_receipts().size() == 1,
		"City Week-28 submitted→no_offer transition was not exact")

	_expect(
		SaveManager.save_game(
			SaveManager.AUTOSAVE_SLOT, {}, {
				"label": "core-loop-v2-handoff",
				"qa_fixture": true,
		}),
		"City handoff fixture could not write its real autosave")
	GameState.start_new_game()
	_expect(
		SaveManager.load_game(SaveManager.AUTOSAVE_SLOT),
		"City handoff fixture could not reload its real autosave")
	CORE_LOOP.initialize_for_run()
	_expect(
		_city_result_receipt_resolved(),
		"resolved City receipt or transition drifted after save/load")
	_expect(
		CORE_LOOP.application_status(
			"city_facility_ops_2026h1") == "no_offer",
		"City no_offer status drifted after save/load")
	_expect(
		CORE_LOOP.obligation_receipt_matches(
			"demo_collision", "city_work_sample", "selected")
			and CORE_LOOP.obligation_receipt_matches(
				"demo_collision", "father_call", "deferred"),
		"Week-24 obligation partition drifted after save/load")
	_expect(
		CORE_LOOP.has_hyunsu_exam_outcome_receipt()
			and bool(GameState.flags.get("hyunsu_failed", false))
			and _exact_deferred_turn(HYUNSU_AFTERMATH) == 31,
		"Hyunsu result/+4 handoff drifted after save/load: flags=%s deferred=%s"
			% [str(GameState.flags), str(GameState.deferred_events)])
	_recreate_main_game()
	if not is_instance_valid(_main_game):
		return

	# Drive every remaining Chapter-One week through the real scheduler. Target
	# callbacks must be returned as foreground IDs; an EventManager pending row
	# plus an empty return is explicitly a failure.
	var target_routes: Dictionary = {
		31: HYUNSU_AFTERMATH,
		36: HYUNSU_DRIFT,
		42: HYUNSU_NEW_PATH,
		48: YEAR_ONE_CLOSE,
	}
	var routed_handoffs: Array[String] = []
	for week in range(29, 49):
		if target_routes.has(week):
			var expected_id := str(target_routes[week])
			if expected_id == YEAR_ONE_CLOSE:
				var close_id := _route_at(week)
				routed_handoffs.append(close_id)
				_expect(
					close_id == YEAR_ONE_CLOSE,
					"Week-48 scheduler jammed before Year-One close: %s"
						% close_id)
				_check_year_one_receipt_prose()
				if close_id == YEAR_ONE_CLOSE:
					var year_one_candidates := (
						GameState.get_year_scene_candidates(1, 4))
					_expect(
						year_one_candidates.size() >= 3,
						"Week-48 close fixture did not retain enough "
						+ "actually seen Year-One scenes for curation: %s"
							% str(year_one_candidates))
					GameState.pending_story_queue.clear()
					_main_game.call("_go_story_mode", [YEAR_ONE_CLOSE])
					_expect(
						GameState.pending_story_queue == [
							YEAR_ONE_CLOSE,
							YEAR_ONE_CURATION,
						]
							and int(GameState.flags.get(
								"foreground_story_turn", -1)) == 48,
						"Week-48 close did not build the exact "
						+ "close→curation StoryMode queue: %s"
							% str(GameState.pending_story_queue))
					_cancel_test_scene_transition()
					GameState.pending_story_queue.clear()
					_apply_event_choice(YEAR_ONE_CLOSE, 0)
				continue
			var routed_id := _route_at(week)
			_expect(
				routed_id == expected_id
					and GameState.has_deferred_event(expected_id),
				"Week %d observational scheduler did not preserve %s"
					% [week, expected_id])
			routed_id = _claim_deferred_foreground(
				week, expected_id)
			routed_handoffs.append(routed_id)
			if routed_id == expected_id:
				_apply_event_choice(expected_id, 0)
			if expected_id == HYUNSU_AFTERMATH:
				_expect(
					_exact_deferred_turn(HYUNSU_DRIFT) == 36,
					"V2 aftermath did not seed Week-36 drift")
			elif expected_id == HYUNSU_DRIFT:
				_expect(
					_exact_deferred_turn(HYUNSU_NEW_PATH) == 42,
					"V2 drift did not seed Week-42 new path")
			continue

		var incidental_id := _route_at(week)
		_expect(
			incidental_id not in HANDOFF_EVENT_IDS,
			"Week %d replayed or bypassed a handoff event: %s"
				% [week, incidental_id])

	_expect(
		routed_handoffs == [
			HYUNSU_AFTERMATH,
			HYUNSU_DRIFT,
			HYUNSU_NEW_PATH,
			YEAR_ONE_CLOSE,
		]
			and bool(GameState.flags.get("hyunsu_pivoted", false))
			and not GameState.has_deferred_event("hyunsu_pivot"),
		"Week 25–48 drive jammed, replayed, or created the legacy pivot")

	_set_turn_date(49)
	GameState.flags.erase("chapter_34_seen")
	var chapter_two_id := str(_main_game.call(
		"_next_arc_id", 49, false, false))
	_expect(
		GameState.RUN_TURN_LIMIT == 240
			and GameState.DEMO_TURN_LIMIT == 24
			and CORE_LOOP.development_cap_week() == 24
			and chapter_two_id == "chapter_card_34"
			and not GameState.is_game_over,
		"V2 handoff replaced the 48/240-week chapter canon: %s"
			% chapter_two_id)


func _check_father_signal_replaces_skipped_first_call() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	_set_turn_date(21)
	_expect(
		not bool(GameState.flags.get("arc_father_01_seen", false))
			and CORE_LOOP.relationship_stage("father") == "unmet",
		"Father skip fixture did not begin before first contact")
	_expect(
		CORE_LOOP.begin_bundle("father_health_signal", "consequence"),
		"Father skip fixture could not begin the universal Week-21 signal")
	_apply_event_choice("v2_father_health_signal", 1)
	_expect(
		CORE_LOOP.note_story_choice("v2_father_health_signal", 1)
			and CORE_LOOP.complete_active_bundle()
				== "father_health_signal",
		"Father skip fixture did not consume its Week-21 choice")
	_expect(
		bool(GameState.flags.get("arc_father_01_seen", false))
			and bool(GameState.flags.get("arc_father_02_done", false))
			and CORE_LOOP.relationship_stage("father") == "opening",
		"Week-21 signal did not replace the skipped first-call root")

	# Hold every earlier scheduler gate constant and toggle only the bridge
	# flag. This proves Week 25 cannot reopen the old first-call scene.
	_seed_scheduler_baseline()
	_recreate_main_game()
	if not is_instance_valid(_main_game):
		return
	GameState.flags.erase("arc_father_01_seen")
	_expect(
		_route_at(25) == "arc_father_01_call",
		"Father scheduler control fixture no longer exposes the old root")
	GameState.flags["arc_father_01_seen"] = true
	_expect(
		_route_at(25) != "arc_father_01_call",
		"Week-25 scheduler replayed the first Father call after its signal")


func _seed_exact_v2_week_24_state() -> void:
	GameState.start_new_game()
	_set_turn_date(24)
	_seed_scheduler_baseline()
	var state: Dictionary = GameState.core_loop_v2_state
	CORE_LOOP.initialize_for_run(true)
	state = GameState.core_loop_v2_state
	state["enabled"] = true
	state["development_cap_week"] = 24
	state["prototype_complete"] = true
	state["completed_through_week"] = 24
	state["prototype_completed_at_turn"] = 25
	state["completed_at_turn"] = 25
	state["completed_turns"] = range(1, 25)
	state["completed_bundles"] = [
		"hyunsu_study_followup",
		"hyunsu_exam_eve",
		"demo_collision",
	]
	state["completed_bundle_turns"] = {
		"hyunsu_study_followup": 11,
		"hyunsu_exam_eve": 23,
		"demo_collision": 24,
	}
	state["plans"]["6"] = {
		"schedule": {
			"23": "hyunsu_exam_eve",
			"24": "demo_collision",
		},
		"selected": [
			"hyunsu_exam_eve",
			"demo_collision",
		],
		"routines": {
			"primary": "livelihood",
			"secondary": "recovery",
		},
		"forgone": [],
		"planned_turn": 21,
	}
	state["relationship_stages"]["hyunsu"] = "shared_commitment"
	state["relationship_memories"] = [{
		"character": "hyunsu",
		"memory": "hyunsu_exam_eve_one_problem",
		"bundle_id": "hyunsu_exam_eve",
		"turn": 23,
	}]
	state["application_statuses"][
		"city_facility_ops_2026h1"] = "submitted"
	state["obligation_receipts"]["demo_collision"] = {
		"bundle_id": "demo_collision",
		"event_id": "v2_demo_first_bill",
		"turn": 24,
		"candidate_ids": WEEK_24_CANDIDATES.duplicate(),
		"selected_obligation_id": "city_work_sample",
		"choice_index": 2,
		"deferred_obligation_ids": WEEK_24_DEFERRED.duplicate(),
	}
	state["future_story_receipts"]["hyunsu_exam_2026"] = {
		"receipt_id": "hyunsu_exam_2026",
		"character": "hyunsu",
		"producer_bundle": "hyunsu_exam_eve",
		"source_memory": "hyunsu_exam_eve_one_problem",
		"source_kind": "relationship_memory",
		"outcome": "fail",
		"recorded_turn": 23,
		"exam_turn": 24,
		"available_turn": 27,
		"result_event": HYUNSU_RESULT,
	}
	state["future_application_receipts"][
		"city_facility_ops_2026h1_result"] = {
			"receipt_id": "city_facility_ops_2026h1_result",
			"application_id": "city_facility_ops_2026h1",
			"producer_bundle": "demo_collision",
			"producer_event": "v2_demo_first_bill",
			"producer_choice": 2,
			"selected_obligation_id": "city_work_sample",
			"from": "submitted",
			"to": "no_offer",
			"recorded_turn": 24,
			"available_turn": 28,
			"result_event": CITY_RESULT,
			"status": "pending",
		}
	state["demo_collision_context"] = {
		"bundle_id": "demo_collision",
		"turn": 24,
		"roots": [
			"v2_demo_first_bill",
			"v2_hyunsu_exam_morning_echo",
		],
		"candidate_ids": WEEK_24_CANDIDATES.duplicate(),
	}
	GameState.core_loop_v2_state = state
	GameState.flags["hyunsu_exam_day_seen"] = true
	GameState.flags.erase("hyunsu_encouraged")
	GameState.flags.erase("hyunsu_passed")
	GameState.flags.erase("hyunsu_failed")
	GameState.flags.erase("v2_city_service_result_seen")
	GameState.flags.erase("arc_year1_close_seen")
	GameState.deferred_events.clear()
	_set_turn_date(25)
	_expect(
		CORE_LOOP.has_hyunsu_exam_outcome_receipt()
			and CORE_LOOP.obligation_receipt_matches(
				"demo_collision", "city_work_sample", "selected")
			and CORE_LOOP.obligation_receipt_matches(
				"demo_collision", "father_call", "deferred")
			and CORE_LOOP.application_status(
				"city_facility_ops_2026h1") == "submitted",
		"seeded Week-24 V2 state is not accepted as exact durable evidence")


func _seed_legacy_hyunsu_result_fixture(result_week: int) -> void:
	GameState.start_new_game()
	GameState.core_loop_v2_state = {}
	_seed_scheduler_baseline()
	GameState.flags["hyunsu_exam_day_seen"] = true
	GameState.flags.erase("hyunsu_encouraged")
	GameState.flags.erase("hyunsu_passed")
	GameState.flags.erase("hyunsu_failed")
	GameState.flags.erase("arc_hyunsu_exam_fail_seen")
	GameState.flags.erase("arc_hyunsu_drift_seen")
	GameState.flags.erase("arc_hyunsu_new_path_seen")
	GameState.flags.erase("hyunsu_pivoted")
	GameState.deferred_events.clear()
	_set_turn_date(result_week)


func _seed_scheduler_baseline() -> void:
	GameState.housing = "gosiwon"
	GameState.current_job = {
		"id": "job_03",
		"category": "career",
		"base_salary": 2_240_000,
	}
	GameState.monthly_income = 2_240_000.0
	GameState.job_tenure = 6
	for flag_id in [
		"prologue_done",
		"chapter_33_seen",
		"arc_intro_meal_seen",
		"arc_intro_dad_seen",
		"arc_temptation_seen",
		"arc_intro_sns_seen",
		"cafe_scenario_seen",
		"cafe_callback_seen",
		"arc_intro_hyunsu_seen",
		"chapter1_closed",
		"arc_ch1_invest_chart_seen",
		"arc_ch1_career_spec_seen",
		"arc_ch1_startup_idea_seen",
		"arc_ch1_network_first_seen",
		"arc_ch1_theme_invest_deep_seen",
		"arc_job_rejection_seen",
		"arc_money_check_seen",
		"arc_gosiwon_wall_seen",
		"arc_first_job_week_seen",
		"arc_sangchul_met_seen",
		"arc_invest_guidance_seen",
		"arc_daeun_met",
		"arc_father_01_seen",
		"arc_father_quiet_call_seen",
		"arc_father_02_done",
		"arc_jiyeon_crash_seen",
		"arc_gangnam_visit_alone_seen",
		"arc_four_months_seen",
		"arc_job_invest_clash_seen",
		"hyunsu_study_together_seen",
		"arc_hyunsu_night_seen",
		"arc_night_routine_seen",
		"arc_jaehyuk_reunion_seen",
	]:
		GameState.flags[flag_id] = true


func _route_and_apply_deferred(
		week: int, expected_id: String, choice_index: int) -> void:
	var observed := _route_at(week)
	_expect(
		observed == expected_id
			and GameState.has_deferred_event(expected_id),
		"Week %d observational scheduler did not preserve %s"
			% [week, expected_id])
	var routed := _claim_deferred_foreground(
		week, expected_id)
	if routed == expected_id:
		_apply_event_choice(expected_id, choice_index)


func _claim_deferred_foreground(
		week: int, expected_id: String) -> String:
	if not is_instance_valid(_main_game):
		return ""
	_set_turn_date(week)
	var routed := str(_main_game.call(
		"_next_arc_id", week, false, true))
	_expect(
		routed == expected_id,
		"Week %d claiming scheduler returned %s instead of foreground %s"
			% [week, routed, expected_id])
	_expect(
		not GameState.has_deferred_event(expected_id)
			and EventManager.pending_events.is_empty()
			and EventManager.current_event.is_empty(),
		"Week %d did not atomically claim %s without the old EventManager queue"
			% [week, expected_id])
	if routed != expected_id:
		return routed

	# This is the same producer call used by MainGame's live week router. The
	# deferred ID must become StoryMode's foreground queue, not an invisible
	# EventManager pending row that montage compression can skip.
	GameState.pending_story_queue.clear()
	_main_game.call("_go_story_mode", [routed])
	_expect(
		GameState.pending_story_queue == [routed]
			and int(GameState.flags.get(
				"foreground_story_turn", -1)) == week,
		"Week %d did not hand %s to the real StoryMode queue"
			% [week, routed])
	_cancel_test_scene_transition()
	GameState.pending_story_queue.clear()
	return routed


func _route_at(week: int) -> String:
	if not is_instance_valid(_main_game):
		return ""
	_set_turn_date(week)
	return str(_main_game.call(
		"_next_arc_id", week, false, false))


func _cancel_test_scene_transition() -> void:
	var transition_tween: Variant = SceneTransition.get("_tween")
	if transition_tween is Tween:
		(transition_tween as Tween).kill()
	SceneTransition.set("_tween", null)
	var overlay: Variant = SceneTransition.get("_overlay")
	if overlay is Control:
		(overlay as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE


func _apply_event_choice(event_id: String, choice_index: int) -> bool:
	var event: Dictionary = DataRegistry.find_event(event_id)
	var choices: Array = (
		event.get("choices", []) as Array
		if event.get("choices", []) is Array else []
	)
	if event.is_empty() or choice_index < 0 \
			or choice_index >= choices.size():
		_expect(
			false,
			"%s choice %d is missing" % [event_id, choice_index])
		return false
	# StoryMode records the scene before presenting its choice. These focused
	# scheduler checks apply choices directly, so mirror only that durable
	# "actually seen this run" receipt before invoking the real choice path.
	GameState.record_run_scene_seen(event_id)
	GameState.apply_choice(event, choices[choice_index])
	return true


func _check_year_one_receipt_prose() -> void:
	var event: Dictionary = DataRegistry.find_event(
		YEAR_ONE_CLOSE)
	var memory_map: Dictionary = (
		(event.get(
			"description_memory_if_known", {}) as Dictionary
		).duplicate(true)
		if event.get(
			"description_memory_if_known", {}) is Dictionary else {}
	)
	var result_key := (
		"obligation_receipt:demo_collision:selected:"
		+ "city_work_sample&v2_city_service_result_seen"
	)
	var pending_key := (
		"obligation_receipt:demo_collision:selected:"
		+ "city_work_sample"
	)
	var deferred_key := (
		"obligation_receipt:demo_collision:deferred:father_call"
	)
	var story_script := load(
		"res://scenes/StoryMode.gd") as GDScript
	var story: Node = story_script.new() if story_script != null else null
	_expect(
		is_instance_valid(story),
		"Year-One prose QA could not instantiate StoryMode")
	if not is_instance_valid(story):
		return
	var resolved := str(story.call(
		"_resolved_story_description", event))
	var result_text := GameState.format_event_text(
		str(memory_map.get(result_key, "")))
	var pending_text := GameState.format_event_text(
		str(memory_map.get(pending_key, "")))
	var deferred_text := GameState.format_event_text(
		str(memory_map.get(deferred_key, "")))
	var visible_deferred_memories := 0
	for deferred_id in WEEK_24_DEFERRED:
		var candidate_key := (
			"obligation_receipt:demo_collision:deferred:"
			+ str(deferred_id)
		)
		var candidate_text := GameState.format_event_text(
			str(memory_map.get(candidate_key, "")))
		if not candidate_text.is_empty() \
				and resolved.contains(candidate_text):
			visible_deferred_memories += 1
	_expect(
		not result_text.is_empty()
			and resolved.count(result_text) == 1
			and not deferred_text.is_empty()
			and resolved.count(deferred_text) == 1
			and visible_deferred_memories == 1
			and (pending_text.is_empty()
				or not resolved.contains(pending_text)),
		"Year-One prose did not append exactly one selected City result and one deferred obligation")
	story.free()


func _exact_deferred_turn(event_id: String) -> int:
	var matches: Array[int] = []
	for raw_entry in GameState.deferred_events:
		if raw_entry is Dictionary \
				and str((raw_entry as Dictionary).get(
					"event_id", "")) == event_id:
			matches.append(int((raw_entry as Dictionary).get(
				"trigger_turn", 0)))
	return matches[0] if matches.size() == 1 else -1


func _exact_city_transition_receipts() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var raw_receipts: Variant = GameState.core_loop_v2_state.get(
		"application_transition_receipts", {})
	if not raw_receipts is Dictionary:
		return result
	for raw_receipt in (raw_receipts as Dictionary).values():
		if not raw_receipt is Dictionary:
			continue
		var receipt: Dictionary = raw_receipt
		if str(receipt.get("application_id", "")) \
					== "city_facility_ops_2026h1" \
				and str(receipt.get("from", "")) == "submitted" \
				and str(receipt.get("to", "")) == "no_offer" \
				and str(receipt.get("bundle_id", "")) \
					== "city_facility_ops_2026h1_result" \
				and str(receipt.get("event_id", "")) == CITY_RESULT \
				and int(receipt.get("choice_index", -1)) == 0 \
				and int(receipt.get("turn", 0)) == 28:
			result.append(receipt.duplicate(true))
	return result


func _city_result_receipt_resolved() -> bool:
	var raw_receipts: Variant = GameState.core_loop_v2_state.get(
		"future_application_receipts", {})
	if not raw_receipts is Dictionary:
		return false
	var raw_receipt: Variant = (raw_receipts as Dictionary).get(
		"city_facility_ops_2026h1_result", {})
	if not raw_receipt is Dictionary:
		return false
	var receipt: Dictionary = raw_receipt
	return str(receipt.get("receipt_id", "")) \
				== "city_facility_ops_2026h1_result" \
			and str(receipt.get("status", "")) == "resolved" \
			and int(receipt.get("resolved_turn", 0)) == 28 \
			and int(receipt.get("choice_index", -1)) == 0 \
			and _exact_city_transition_receipts().size() == 1


func _recreate_main_game() -> void:
	if is_instance_valid(_main_game):
		_main_game.free()
		_main_game = null
	EventManager.pending_events.clear()
	EventManager.current_event = {}
	var packed := load("res://scenes/MainGame.tscn") as PackedScene
	_expect(
		packed != null,
		"handoff QA could not load MainGame.tscn")
	if packed != null:
		_main_game = packed.instantiate()


func _set_turn_date(target_turn: int) -> void:
	var year_index := int((target_turn - 1) / 48)
	var week_in_year := (target_turn - 1) % 48
	GameState.turn = target_turn
	GameState.age = 33 + year_index
	GameState.year = 2026 + year_index
	GameState.month = int(week_in_year / 4) + 1
	GameState.week_of_month = (week_in_year % 4) + 1


func _backup_autosave() -> void:
	var path := SaveManager.slot_path(SaveManager.AUTOSAVE_SLOT)
	_autosave_backup = {
		"existed": FileAccess.file_exists(path),
		"bytes": (
			FileAccess.get_file_as_bytes(path)
			if FileAccess.file_exists(path) else PackedByteArray()
		),
	}


func _restore_autosave() -> void:
	if _autosave_backup.is_empty():
		return
	var path := SaveManager.slot_path(SaveManager.AUTOSAVE_SLOT)
	if bool(_autosave_backup.get("existed", false)):
		var file := FileAccess.open(path, FileAccess.WRITE)
		if file:
			file.store_buffer(
				_autosave_backup.get("bytes", PackedByteArray()))
			file.close()
	elif FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
