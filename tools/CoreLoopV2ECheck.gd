extends Node
## ORDER-57 E: actual weeks 21–24, collision receipts, and turn-25 recap.

const CORE_LOOP := preload("res://systems/DemoCoreLoopV2.gd")
const MAIN_GAME_SCRIPT := preload("res://scenes/MainGame.gd")

const BASE_OFFERS := [
	"m6_public_recruitment",
	"m6_holiday_night_shift",
	"m6_last_study_group",
	"m6_no_plans_day",
	"m6_gangnam_receipt_walk",
]

const CONDITIONAL_OFFERS := [
	"hyunsu_exam_eve",
	"m6_daeun_tuesday_followthrough",
]

const OBLIGATION_IDS := [
	"father_call",
	"hanbit_month_close",
	"city_work_sample",
	"daeun_checkin",
	"jaehyuk_reply",
	"sangchul_ledger",
	"urgent_paid_shift",
	"body_rest",
]

const ACTION_STORY_FIXTURES := [
	{
		"bundle_id": "m1_convenience_trial_shift",
		"turn": 2,
		"root": "v2_convenience_trial_shift",
		"effects": {"money": 137000, "stress": 4, "health": -2},
		"axis": "money",
		"place_id": "work",
		"details": {
			"execution": "side_shift",
			"earned": 137000,
			"health_delta": -2,
			"mental_delta": -4,
		},
	},
	{
		"bundle_id": "m3_inventory_shift",
		"turn": 10,
		"root": "v2_inventory_count_nights",
	},
	{
		"bundle_id": "m4_certificate_session",
		"turn": 14,
		"root": "v2_logistics_class_session",
	},
	{
		"bundle_id": "m5_weekend_move_shift",
		"turn": 18,
		"root": "v2_moving_crew_days",
	},
	{
		"bundle_id": "m5_last_empty_sunday",
		"turn": 19,
		"root": "v2_empty_sunday",
	},
]

const PRIOR_SCHEDULES := {
	"1": {
		"1": "m1_mirae_application",
		"2": "m1_convenience_trial_shift",
		"3": "m1_youth_center_resume_clinic",
		"4": "first_temptation_boss",
	},
	"2": {
		"5": "m2_seorin_application",
		"6": "m2_rain_delivery_shift",
		"7": "m2_youth_center_mock_interview",
		"8": "m2_sleep_debt_sunday",
	},
	"3": {
		"9": "m3_hanbit_application",
		"10": "m3_inventory_shift",
		"11": "hyunsu_study_followup",
		"12": "m3_empty_saturday",
	},
	"4": {
		"13": "m4_dodam_application",
		"14": "m4_certificate_session",
		"15": "m4_logistics_shift",
		"16": "m4_health_check_day",
	},
	"5": {
		"17": "m5_city_service_application",
		"18": "m5_evening_spreadsheet_class",
		"19": "m5_employment_contract_clinic",
		"20": "m5_last_empty_sunday",
	},
}

var _failures: Array[String] = []
var _autosave_backup: Dictionary = {}
var _captured_terminal_saves: Array[Dictionary] = []
var _game_over_signals := 0

func _ready() -> void:
	_backup_autosave()
	var original_sfx_enabled := AudioManager.sfx_enabled
	AudioManager.sfx_enabled = false
	var action_callback := Callable(self, "_capture_v2_action_receipt")
	if not GameState.weekly_commitment_finalized.is_connected(action_callback):
		GameState.weekly_commitment_finalized.connect(action_callback)
	var game_over_callback := Callable(self, "_capture_game_over")
	if not GameState.game_over.is_connected(game_over_callback):
		GameState.game_over.connect(game_over_callback)

	_check_contract_and_offer_matrix()
	_check_cash_position_copy()
	_check_action_story_roundtrips()
	_check_father_prelude_roundtrip()
	_check_application_response_roundtrips()
	_check_hyunsu_future_bridge()
	_check_deferred_foreground_scheduler()
	_check_collision_queue_and_receipts()
	_check_city_choice_preserves_submission()
	await _check_actual_weeks_and_terminal_recap()

	if GameState.weekly_commitment_finalized.is_connected(action_callback):
		GameState.weekly_commitment_finalized.disconnect(action_callback)
	if GameState.game_over.is_connected(game_over_callback):
		GameState.game_over.disconnect(game_over_callback)
	AudioManager.sfx_enabled = original_sfx_enabled
	_restore_autosave()

	if _failures.is_empty():
		print(
			"CORE_LOOP_V2_E_CHECK_OK schema=3 cap=24 prototype=1_24 "
			+ "action_story=5/once/save "
			+ "offers=base5/hyunsu6/daeun6/rich7 "
			+ "father=week21/pre_plan/three_exact_receipts/save "
			+ "applications=dodam_no_offer/city_submitted/inbox/save "
			+ "hyunsu=memory_receipt/week27_canonical_result "
			+ "collision=dirty_bill_morning/candidates4/selective_claim/"
			+ "obligation_and_callback_receipts/father_initiative/"
			+ "city_decline_or_preserve "
			+ "run=weeks21_24/routines48/salary2240000/fixed650000 "
			+ "terminal=turn25/six_summaries/full_declines/sticky_cta/"
			+ "single_save/resume/no_finish/no_legacy")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("CORE_LOOP_V2_E_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)

func _check_contract_and_offer_matrix() -> void:
	var contract := CORE_LOOP.contract()
	var scope: Dictionary = (
		(contract.get("scope", {}) as Dictionary).duplicate(true)
		if contract.get("scope", {}) is Dictionary else {}
	)
	_expect(int(contract.get("schema_version", 0)) == 3 \
			and CORE_LOOP.development_cap_week() == 24 \
			and int(scope.get("development_cap_week", 0)) == 24 \
			and _int_array(scope.get("prototype_weeks", [])) == [1, 24],
		"E contract is not the exact schema-3 weeks 1–24 gate")
	var month_six := CORE_LOOP.month_spec(6)
	var month_six_locks: Array = (
		(month_six.get("locked", []) as Array).duplicate(true)
		if month_six.get("locked", []) is Array else []
	)
	var month_six_lock: Dictionary = (
		(month_six_locks[0] as Dictionary).duplicate(true)
		if month_six_locks.size() == 1 \
			and month_six_locks[0] is Dictionary else {}
	)
	_expect(_int_array(month_six.get("weeks", [])) == [21, 24] \
			and month_six.get("prelude", []) == ["father_health_signal"] \
			and month_six.get("conditional_consequences", []) == [
				"m6_dodam_response",
				"m6_city_service_response",
			] \
			and month_six_locks.size() == 1 \
			and int(month_six_lock.get("week", 0)) == 24 \
			and str(month_six_lock.get("bundle", "")) \
				== "demo_collision",
		"Month Six does not own the exact prelude, responses, and boss lock")

	_fresh_at(21)
	var base := CORE_LOOP.available_offer_ids(6)
	_expect(_same_string_set(base, BASE_OFFERS),
		"sparse Month Six is not exactly five base offers: %s" % [str(base)])

	_fresh_at(21)
	_unlock_hyunsu()
	var hyunsu := CORE_LOOP.available_offer_ids(6)
	_expect(_same_string_set(
			hyunsu, BASE_OFFERS + ["hyunsu_exam_eve"]),
		"Hyunsu path did not expose exactly the sixth Month-Six card")

	_fresh_at(21)
	_unlock_daeun()
	var daeun := CORE_LOOP.available_offer_ids(6)
	_expect(_same_string_set(
			daeun, BASE_OFFERS + ["m6_daeun_tuesday_followthrough"]),
		"Daeun path did not expose exactly the sixth Month-Six card")

	_fresh_at(21)
	_unlock_hyunsu()
	_unlock_daeun()
	var rich := CORE_LOOP.available_offer_ids(6)
	_expect(_same_string_set(
			rich, BASE_OFFERS + CONDITIONAL_OFFERS),
		"rich Month Six is not the exact seven-card catalog")

	var father_event: Dictionary = DataRegistry.find_event(
		"v2_father_health_signal")
	var father_choices: Array = (
		father_event.get("choices", []) as Array
		if father_event.get("choices", []) is Array else []
	)
	var expected_father_effects := [
		{"mental": -3},
		{"mental": -2},
		{"mental": -5},
	]
	var expected_father_flags := [
		["arc_father_01_seen", "arc_father_02_done"],
		["arc_father_01_seen", "arc_father_02_done"],
		["arc_father_01_seen", "arc_father_02_done"],
	]
	_expect(father_choices.size() == 3,
		"Father's Week-21 signal does not have exactly three choices")
	for choice_index in range(mini(3, father_choices.size())):
		var choice: Dictionary = father_choices[choice_index]
		var effects: Dictionary = (
			(choice.get("effects", {}) as Dictionary).duplicate(true)
			if choice.get("effects", {}) is Dictionary else {}
		)
		_expect(effects.size() == 1 \
				and int(effects.get("mental", 0)) == int(
					(expected_father_effects[choice_index] as Dictionary).get(
						"mental", 0)) \
				and _same_string_set(
					choice.get("flags", []),
					expected_father_flags[choice_index]) \
				and not effects.has("money"),
			"Father choice %d invented or drifted from its exact receipt"
				% choice_index)

	var bill_event: Dictionary = DataRegistry.find_event(
		"v2_demo_first_bill")
	var bill_choices: Array = (
		bill_event.get("choices", []) as Array
		if bill_event.get("choices", []) is Array else []
	)
	var actual_obligations: Array[String] = []
	for raw_choice in bill_choices:
		actual_obligations.append(str(
			(raw_choice as Dictionary).get("v2_obligation_id", "")
			if raw_choice is Dictionary else ""))
	_expect(actual_obligations == _string_array(OBLIGATION_IDS),
		"First Bill choices are not the exact eight obligation IDs")
	_expect(not DataRegistry.find_event(
			"v2_hyunsu_exam_morning_echo").is_empty() \
			and DataRegistry.find_event("v2_hyunsu_exam_result").is_empty(),
		"Hyunsu's Saturday start-time echo is missing or a result was invented")

func _check_cash_position_copy() -> void:
	var original_language := LocaleManager.language
	LocaleManager.language = "ko"
	GameState.money = -770_000.0
	var ko_arrears := GameState.format_event_text("{cash_position}")
	_expect(ko_arrears == \
			"계좌 잔액은 0원이고, 밀린 비용은 %s이었다" % \
				GameState.format_money(770_000.0) \
			and ko_arrears.find(GameState.format_money(-770_000.0)) < 0,
		"Korean First Bill copy rendered arrears as a negative bank balance")
	GameState.money = 420_000.0
	var ko_balance := GameState.format_event_text("{cash_position}")
	_expect(ko_balance == "계좌 잔액은 %s이었다" % \
			GameState.format_money(420_000.0),
		"Korean First Bill positive path invented arrears")
	LocaleManager.language = "en"
	GameState.money = -770_000.0
	var en_arrears := GameState.format_event_text("{cash_position}")
	_expect(en_arrears.find("account balance was %s" % \
			GameState.format_money(0.0)) >= 0 \
			and en_arrears.find(GameState.format_money(770_000.0)) >= 0 \
			and en_arrears.find(GameState.format_money(-770_000.0)) < 0,
		"English First Bill copy rendered arrears as a negative bank balance")
	LocaleManager.language = original_language

func _check_action_story_roundtrips() -> void:
	for raw_fixture in ACTION_STORY_FIXTURES:
		var fixture: Dictionary = raw_fixture
		var bundle_id := str(fixture.get("bundle_id", ""))
		var root := str(fixture.get("root", ""))
		var target_turn := int(fixture.get("turn", 0))
		_fresh_at(target_turn)
		var scene_bundle := CORE_LOOP.bundle(bundle_id)
		var config: Dictionary = (
			(scene_bundle.get("action_config", {}) as Dictionary).duplicate(true)
			if scene_bundle.get("action_config", {}) is Dictionary else {}
		)
		var action_id := str(scene_bundle.get("action_id", ""))
		var effects: Dictionary = (
			(fixture.get("effects", {}) as Dictionary).duplicate(true)
			if fixture.get("effects", {}) is Dictionary \
				and not (fixture.get("effects", {}) as Dictionary).is_empty()
			else (config.get("effects", {}) as Dictionary).duplicate(true)
		)
		var execution := str(config.get("execution", "side_shift"))
		var axis := str(fixture.get(
			"axis", config.get(
				"axis", "human" if execution == "rest" else "money")))
		var place_id := str(fixture.get(
			"place_id", config.get(
				"place_id", "home" if execution == "rest" else "work")))
		var details: Dictionary = (
			(fixture.get("details", {}) as Dictionary).duplicate(true)
			if fixture.get("details", {}) is Dictionary \
				and not (fixture.get("details", {}) as Dictionary).is_empty()
			else {
				"execution": execution,
				"effects": effects.duplicate(true),
			}
		)
		if execution == "instant_effect":
			details["axis"] = axis
			details["place_id"] = place_id
		if execution == "rest":
			details["diminished_by_recovery_routine"] = false

		_expect(scene_bundle.get("existing_roots", []) == [root] \
				and not action_id.is_empty() \
				and CORE_LOOP.begin_bundle(bundle_id, "schedule") \
				and CORE_LOOP.action_story_stage(bundle_id) == "action" \
				and CORE_LOOP.complete_active_bundle().is_empty(),
			"%s did not begin as an action-first dual surface" % bundle_id)
		GameState.restore_ap()
		var armed := GameState.arm_weekly_commitment({
			"turn": target_turn,
			"pressure_id": bundle_id,
			"pressure_family": str(scene_bundle.get("kind", "routine")),
			"choice_id": action_id,
			"forgone_ids": [],
		})
		var transaction := GameState.finalize_weekly_effect_action(
			action_id, effects, axis, place_id, "", details) \
			if armed else {"ok": false}
		var after_action := _action_story_stat_snapshot()
		_expect(bool(transaction.get("ok", false)) \
				and CORE_LOOP.action_result_ready() \
				and not CORE_LOOP.action_receipt(bundle_id).is_empty() \
				and CORE_LOOP.action_story_stage(bundle_id) == "story" \
				and CORE_LOOP.complete_active_bundle().is_empty(),
			"%s skipped, duplicated, or prematurely completed its action"
				% bundle_id)
		_expect(CORE_LOOP.acknowledge_action_story_result(bundle_id) \
				and not CORE_LOOP.action_result_ready() \
				and CORE_LOOP.action_story_stage(bundle_id) == "story",
			"%s did not durably acknowledge its action result" % bundle_id)
		var finalized_record := GameState.get_weekly_commitment_for_turn(
			target_turn)
		_expect(CORE_LOOP.note_action_commitment(finalized_record) \
				and not CORE_LOOP.action_result_ready(),
			"%s duplicate action signal reopened an acknowledged result"
				% bundle_id)

		var mid_bridge_save: Dictionary = (
			GameState.serialize().duplicate(true))
		GameState.start_new_game()
		GameState.load_from_dict(mid_bridge_save)
		CORE_LOOP.initialize_for_run()
		_expect(CORE_LOOP.action_story_stage(bundle_id) == "story" \
				and not CORE_LOOP.action_result_ready() \
				and _action_story_stat_snapshot() == after_action,
			"%s replayed its action or lost its post-action story on load"
				% bundle_id)
		_apply_and_note_story_choice(root, 0)
		_expect(_action_story_stat_snapshot() == after_action \
				and CORE_LOOP.action_story_stage(bundle_id) == "complete" \
				and CORE_LOOP.complete_active_bundle() == bundle_id \
				and CORE_LOOP.complete_active_bundle().is_empty(),
			"%s result story changed gameplay effects or did not close once"
				% bundle_id)
		var completed_save: Dictionary = (
			GameState.serialize().duplicate(true))
		GameState.start_new_game()
		GameState.load_from_dict(completed_save)
		CORE_LOOP.initialize_for_run()
		_expect(CORE_LOOP.has_completed_bundle(bundle_id) \
				and CORE_LOOP.action_story_stage(bundle_id).is_empty() \
				and _action_story_stat_snapshot() == after_action,
			"%s lost completion or reapplied effects after completion load"
				% bundle_id)

	var recovery := CORE_LOOP.bundle("m5_last_empty_sunday")
	var recovery_config: Dictionary = recovery.get("action_config", {})
	var recovery_effects: Dictionary = recovery_config.get("effects", {})
	var diminished_effects: Dictionary = recovery_config.get(
		"recovery_routine_effects", {})
	_expect(int(recovery_effects.get("health", 0)) == 5 \
			and int(recovery_effects.get("mental", 0)) == 7 \
			and int(diminished_effects.get("health", 0)) == 2 \
			and int(diminished_effects.get("mental", 0)) == 3,
		"Empty Sunday lost its exact normal/diminished recovery ledger")

func _action_story_stat_snapshot() -> Dictionary:
	return {
		"money": float(GameState.money),
		"health": int(GameState.health),
		"mental": int(GameState.mental),
		"intelligence": int(GameState.intelligence),
		"action_points": int(GameState.action_points),
	}

func _check_father_prelude_roundtrip() -> void:
	_fresh_at(21)
	var money_before := float(GameState.money)
	var mental_before := int(GameState.mental)
	_expect(CORE_LOOP.needs_plan(6) \
			and CORE_LOOP.pending_month_prelude(6) \
				== "father_health_signal",
		"Father's Week-21 signal did not precede Month-Six planning")
	_expect(CORE_LOOP.begin_bundle(
			"father_health_signal", "consequence"),
		"Father prelude could not begin as a non-slot consequence")
	var event: Dictionary = DataRegistry.find_event(
		"v2_father_health_signal")
	var choices: Array = (
		event.get("choices", []) as Array
		if event.get("choices", []) is Array else []
	)
	if choices.size() < 2:
		_expect(false, "Father prelude lost its recall choice")
		return
	GameState.apply_choice(event, choices[1])
	_expect(CORE_LOOP.note_story_choice(
			"v2_father_health_signal", 1),
		"Father prelude did not write a story-choice receipt")
	_expect(CORE_LOOP.complete_active_bundle() \
			== "father_health_signal" \
			and CORE_LOOP.complete_active_bundle().is_empty(),
		"Father prelude did not consume exactly once")
	_expect(is_equal_approx(float(GameState.money), money_before) \
			and int(GameState.mental) == mental_before - 2 \
			and bool(GameState.flags.get("arc_father_01_seen", false)) \
			and bool(GameState.flags.get("arc_father_02_done", false)) \
			and CORE_LOOP.relationship_stage("father") == "opening" \
			and not GameState.flags.has(
				"father_recall_promised_week21") \
			and not GameState.flags.has(
				"father_hospital_name_asked_week21") \
			and not GameState.flags.has(
				"father_signal_calendar_opened") \
			and CORE_LOOP.plan_for_month(6).is_empty(),
		"Father prelude invented money, wrong flags, or a monthly plan")
	var receipt := _consequence_receipt("father_health_signal")
	_expect(str(receipt.get("status", "")) == "consumed" \
			and int(receipt.get("presented_turn", 0)) == 21 \
			and CORE_LOOP.received_phone_consequence_ids(6) \
				== ["father_health_signal"],
		"Father's phone receipt is not one consumed Week-21 message")

	var saved: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	CORE_LOOP.initialize_for_run()
	_expect(CORE_LOOP.pending_month_prelude(6).is_empty() \
			and CORE_LOOP.needs_plan(6) \
			and CORE_LOOP.relationship_stage("father") == "opening" \
			and _consequence_receipt("father_health_signal") == receipt \
			and CORE_LOOP.received_phone_consequence_ids(6) \
				== ["father_health_signal"],
		"Father prelude replayed or disappeared after save/load")

	# The universal signal must also be safe when the optional early call
	# already established an opening. It records the Week-21 memory without
	# inventing another relationship advance.
	_fresh_at(21)
	_set_relationship_stage("father", "opening")
	_expect(CORE_LOOP.begin_bundle(
			"father_health_signal", "consequence"),
		"pre-opened Father prelude could not begin")
	_apply_and_note_story_choice("v2_father_health_signal", 0)
	var preopened_history: Array = GameState.core_loop_v2_state.get(
		"relationship_history", [])
	var preopened_receipt: Dictionary = (
		preopened_history.back() as Dictionary
		if not preopened_history.is_empty() \
			and preopened_history.back() is Dictionary else {}
	)
	_expect(CORE_LOOP.relationship_stage("father") == "opening" \
			and str(preopened_receipt.get("from", "")) == "opening" \
			and str(preopened_receipt.get("to", "")) == "opening" \
			and str(preopened_receipt.get("memory", "")) \
				== "father_neighbor_detail_checked",
		"pre-opened Father signal failed its idempotent relationship receipt")

func _check_application_response_roundtrips() -> void:
	_fresh_at(22)
	_set_application_status("dodam_customer_ops_2026q2", "submitted")
	_expect(CORE_LOOP.begin_bundle(
			"m6_last_study_group", "schedule"),
		"Dodam fixture could not begin its Week-22 owner")
	var dodam_claim := CORE_LOOP.claim_scheduled_prelude(
		"m6_last_study_group")
	_expect(_claim_matches(
			dodam_claim, "m6_dodam_response",
			"m6_last_study_group", 22, "action"),
		"Dodam response did not attach to the Week-22 action")
	var dodam_event: Dictionary = DataRegistry.find_event(
		"v2_dodam_result_message")
	var dodam_choices: Array = (
		dodam_event.get("choices", []) as Array
		if dodam_event.get("choices", []) is Array else []
	)
	if dodam_choices.size() == 1:
		GameState.apply_choice(dodam_event, dodam_choices[0])
		_expect(CORE_LOOP.note_story_choice(
				"v2_dodam_result_message", 0),
			"Dodam response did not write its application receipt")
	_expect(CORE_LOOP.application_status(
			"dodam_customer_ops_2026q2") == "no_offer" \
			and _application_receipts_for(
				"m6_dodam_response",
				"v2_dodam_result_message").size() == 1 \
			and bool(CORE_LOOP.consume_scheduled_prelude(
				"m6_last_study_group").get("consumed", false)),
		"Dodam submitted→no_offer did not transition and consume once")
	CORE_LOOP.cancel_active_bundle()

	var dodam_saved: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(dodam_saved)
	CORE_LOOP.initialize_for_run()
	_expect(CORE_LOOP.application_status(
			"dodam_customer_ops_2026q2") == "no_offer" \
			and CORE_LOOP.received_phone_consequence_ids(6) \
				== ["m6_dodam_response"] \
			and CORE_LOOP.pending_consequence_id(6).is_empty(),
		"Dodam result replayed or vanished after save/load")

	_fresh_at(23)
	_set_application_status("city_facility_ops_2026h1", "submitted")
	_expect(CORE_LOOP.begin_bundle(
			"m6_last_study_group", "schedule"),
		"City fixture could not begin its Week-23 owner")
	var city_claim := CORE_LOOP.claim_scheduled_prelude(
		"m6_last_study_group")
	_expect(_claim_matches(
			city_claim, "m6_city_service_response",
			"m6_last_study_group", 23, "action"),
		"City work-sample message did not attach to Week 23")
	var city_event: Dictionary = DataRegistry.find_event(
		"v2_city_service_work_sample_message")
	var city_choices: Array = (
		city_event.get("choices", []) as Array
		if city_event.get("choices", []) is Array else []
	)
	if city_choices.size() == 1:
		GameState.apply_choice(city_event, city_choices[0])
		_expect(CORE_LOOP.note_story_choice(
				"v2_city_service_work_sample_message", 0),
			"City response did not write its generic story receipt")
	_expect(CORE_LOOP.application_status(
			"city_facility_ops_2026h1") == "submitted" \
			and _application_receipts_for(
				"m6_city_service_response",
				"v2_city_service_work_sample_message").is_empty() \
			and bool(CORE_LOOP.consume_scheduled_prelude(
				"m6_last_study_group").get("consumed", false)),
		"City's request changed submitted status or failed to consume")
	CORE_LOOP.cancel_active_bundle()
	var city_saved: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(city_saved)
	CORE_LOOP.initialize_for_run()
	_expect(CORE_LOOP.application_status(
			"city_facility_ops_2026h1") == "submitted" \
			and CORE_LOOP.received_phone_consequence_ids(6) \
				== ["m6_city_service_response"],
		"City request status or inbox receipt did not survive save/load")

func _check_collision_queue_and_receipts() -> void:
	_fresh_at(24)
	_unlock_hyunsu()
	_set_application_status("city_facility_ops_2026h1", "submitted")
	_seed_consumed_consequence("m6_city_service_response", 23)
	GameState.current_job = {
		"id": "job_03",
		"base_salary": 2_240_000,
	}
	GameState.monthly_income = 2_240_000.0
	_mark_completed("jaehyuk_plain_reunion_echo", 20)
	_set_relationship_memory(
		"jaehyuk", "jaehyuk_reunion_warm",
		"jaehyuk_plain_reunion_echo", 20)
	GameState.flags["escaped_dirty_money"] = true
	GameState.deferred_events = [
		{
			"event_id": "unrelated_due_callback",
			"trigger_turn": 24,
		},
		{
			"event_id": "callback_escaped_dirty_trace",
			"trigger_turn": 24,
		},
		{
			"event_id": "unrelated_future_callback",
			"trigger_turn": 25,
		},
	]
	_expect(CORE_LOOP.begin_bundle("demo_collision", "schedule"),
		"demo collision fixture could not begin")
	var prepared := CORE_LOOP.prepare_demo_collision()
	var context: Dictionary = (
		(prepared.get("context", {}) as Dictionary).duplicate(true)
		if prepared.get("context", {}) is Dictionary else {}
	)
	var expected_candidates := [
		"father_call",
		"hanbit_month_close",
		"city_work_sample",
		"jaehyuk_reply",
	]
	_expect(bool(prepared.get("ok", false)) \
			and bool(prepared.get("prepared", false)) \
			and context.get("roots", []) == [
				"v2_dirty_trace_initial_call",
				"v2_demo_first_bill",
				"v2_hyunsu_exam_morning_echo",
			] \
			and context.get("candidate_ids", []) == expected_candidates \
			and str(context.get("dirty_source", "")) \
				== "callback_escaped_dirty_trace" \
			and str(context.get("dirty_root", "")) \
				== "v2_dirty_trace_initial_call",
		"collision did not freeze dirty→bill→Saturday roots and four candidates")
	_expect(_deferred_event_ids() == [
			"unrelated_due_callback",
			"unrelated_future_callback",
		],
		"collision claimed or reordered an unrelated deferred event")
	var prepared_again := CORE_LOOP.prepare_demo_collision()
	_expect(bool(prepared_again.get("ok", false)) \
			and not bool(prepared_again.get("prepared", true)) \
			and prepared_again.get("context", {}) == context,
		"collision preparation was not idempotent")

	var saved: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	CORE_LOOP.initialize_for_run()
	var loaded_prepare := CORE_LOOP.prepare_demo_collision()
	_expect(bool(loaded_prepare.get("ok", false)) \
			and not bool(loaded_prepare.get("prepared", true)) \
			and loaded_prepare.get("context", {}) == context \
			and _deferred_event_ids() == [
				"unrelated_due_callback",
				"unrelated_future_callback",
			],
		"collision context or untouched callbacks drifted after save/load")

	for obligation_id in OBLIGATION_IDS:
		_expect(CORE_LOOP.story_choice_available(
				"v2_demo_first_bill", obligation_id) \
				== expected_candidates.has(obligation_id),
			"First Bill choice availability disagrees for %s"
				% obligation_id)
	_expect(CORE_LOOP.complete_active_bundle().is_empty(),
		"collision completed before callback and obligation receipts")

	_apply_and_note_story_choice("v2_dirty_trace_initial_call", 0)
	_expect(CORE_LOOP.complete_active_bundle().is_empty(),
		"collision completed before the First Bill obligation")
	_apply_and_note_story_choice("v2_demo_first_bill", 0)
	_apply_and_note_story_choice("v2_hyunsu_exam_morning_echo", 0)
	var obligation := _obligation_receipt()
	var callback := _callback_receipt("callback_escaped_dirty_trace")
	var father_story_receipt: Dictionary = {}
	for raw_receipt in (
			GameState.core_loop_v2_state.get(
				"story_choice_receipts", {}) as Dictionary
		).values():
		if raw_receipt is Dictionary \
				and str((raw_receipt as Dictionary).get(
					"event_id", "")) == "v2_demo_first_bill" \
				and int((raw_receipt as Dictionary).get(
					"choice_index", -1)) == 0:
			father_story_receipt = (
				raw_receipt as Dictionary).duplicate(true)
			break
	_expect(obligation == {
			"bundle_id": "demo_collision",
			"event_id": "v2_demo_first_bill",
			"turn": 24,
			"candidate_ids": expected_candidates,
			"selected_obligation_id": "father_call",
			"choice_index": 0,
			"deferred_obligation_ids": [
				"hanbit_month_close",
				"city_work_sample",
				"jaehyuk_reply",
			],
		},
		"collision obligation receipt is not the exact candidate partition")
	_expect(str(callback.get("source", "")) \
				== "callback_escaped_dirty_trace" \
			and int(callback.get("trigger_turn", 0)) == 24 \
			and int(callback.get("claimed_turn", 0)) == 24 \
			and str(callback.get("root", "")) \
				== "v2_dirty_trace_initial_call" \
			and str(callback.get("status", "")) == "resolved" \
			and not bool(callback.get("synthetic", true)) \
			and str(callback.get("event_id", "")) \
				== "v2_dirty_trace_initial_call" \
			and int(callback.get("choice_index", -1)) == 0 \
			and int(callback.get("resolved_turn", 0)) == 24,
		"escaped-dirty callback receipt is not exact")
	_expect(str(father_story_receipt.get(
				"player_initiated_character", "")) == "father" \
			and CORE_LOOP.was_player_initiated("father"),
		"First-Bill Father call did not become a durable player initiative")
	_expect(CORE_LOOP.application_status(
			"city_facility_ops_2026h1") == "no_offer" \
			and bool(GameState.flags.get("hyunsu_exam_day_seen", false)) \
			and CORE_LOOP.complete_active_bundle() == "demo_collision" \
			and CORE_LOOP.complete_active_bundle().is_empty(),
		"non-City collision choice failed to close City, mark Saturday, or finish")

func _check_city_choice_preserves_submission() -> void:
	_fresh_at(24)
	_set_application_status("city_facility_ops_2026h1", "submitted")
	_seed_consumed_consequence("m6_city_service_response", 23)
	_expect(CORE_LOOP.begin_bundle("demo_collision", "schedule"),
		"City-preserve collision could not begin")
	var prepared := CORE_LOOP.prepare_demo_collision()
	var context: Dictionary = prepared.get("context", {})
	_expect(bool(prepared.get("ok", false)) \
			and (context.get("candidate_ids", []) as Array).has(
				"city_work_sample") \
			and CORE_LOOP.story_choice_available(
				"v2_demo_first_bill", "city_work_sample"),
		"submitted City work sample was not a collision candidate")
	_apply_and_note_story_choice("v2_demo_first_bill", 2)
	var city_completed := CORE_LOOP.complete_active_bundle()
	var raw_future_city: Variant = (
		GameState.core_loop_v2_state.get(
			"future_application_receipts", {}) as Dictionary
	).get("city_facility_ops_2026h1_result", {})
	var future_city: Dictionary = (
		(raw_future_city as Dictionary).duplicate(true)
		if raw_future_city is Dictionary else {}
	)
	_expect(CORE_LOOP.application_status(
			"city_facility_ops_2026h1") == "submitted" \
			and _application_receipts_for(
				"demo_collision", "v2_demo_first_bill").is_empty() \
			and str(_obligation_receipt().get(
				"selected_obligation_id", "")) == "city_work_sample" \
			and city_completed == "demo_collision" \
			and str(future_city.get("receipt_id", "")) \
				== "city_facility_ops_2026h1_result" \
			and str(future_city.get("status", "")) == "pending" \
				and int(future_city.get("available_turn", 0)) == 28,
			"City work-sample choice did not preserve submitted status")
	var city_pending_saved: Dictionary = (
		GameState.serialize().duplicate(true)
	)
	GameState.start_new_game()
	GameState.load_from_dict(city_pending_saved)
	CORE_LOOP.initialize_for_run()
	var reloaded_future_city: Dictionary = (
		(GameState.core_loop_v2_state.get(
			"future_application_receipts", {}) as Dictionary
		).get("city_facility_ops_2026h1_result", {}) as Dictionary
	).duplicate(true)
	_expect(reloaded_future_city == future_city \
			and str(reloaded_future_city.get("status", "")) == "pending" \
			and CORE_LOOP.application_status(
				"city_facility_ops_2026h1") == "submitted",
		"pending City future-application receipt did not survive save/load")
	var city_partial_state: Dictionary = (
		GameState.core_loop_v2_state.duplicate(true)
	)
	city_partial_state["future_application_receipts"] = {}
	GameState.core_loop_v2_state = city_partial_state
	_set_turn_date(25)
	var city_partial_saved: Dictionary = (
		GameState.serialize().duplicate(true)
	)
	GameState.start_new_game()
	GameState.load_from_dict(city_partial_saved)
	CORE_LOOP.initialize_for_run()
	GameState.flags["prologue_done"] = true
	GameState.flags["chapter_33_seen"] = true
	var city_scheduler = MAIN_GAME_SCRIPT.new()
	var city_before_preview: Dictionary = (
		GameState.core_loop_v2_state.duplicate(true)
	)
	_expect(city_scheduler._next_arc_id(
				25, true, false) == "arc_temptation_01" \
			and GameState.core_loop_v2_state == city_before_preview,
		"MainGame City preview mutated the partial save or hid its competing arc")
	_expect(city_scheduler._next_arc_id(
				25, false, false) == "arc_temptation_01",
		"partial City save displaced the competing arc before Week 28")
	var reconstructed_future_city: Dictionary = (
		(GameState.core_loop_v2_state.get(
			"future_application_receipts", {}) as Dictionary
		).get("city_facility_ops_2026h1_result", {}) as Dictionary
	).duplicate(true)
	_expect(str(reconstructed_future_city.get(
				"receipt_id", "")) \
				== "city_facility_ops_2026h1_result" \
			and str(reconstructed_future_city.get(
				"selected_obligation_id", "")) \
				== "city_work_sample" \
			and str(reconstructed_future_city.get(
				"status", "")) == "pending" \
			and int(reconstructed_future_city.get(
				"available_turn", 0)) == 28,
		"partial City save did not reconstruct its typed future receipt")
	_set_turn_date(27)
	_expect(CORE_LOOP.post_demo_application_result_event_id(
			27).is_empty(),
		"City result appeared before its first-year callback window")
	_expect(CORE_LOOP.post_demo_application_result_event_id(
			33).is_empty(),
		"City result remained open after its Week-32 contract window")
	_set_turn_date(28)
	_expect(city_scheduler._next_arc_id(
			28, false, false) == "v2_city_service_result_message",
		"MainGame did not route the City Week-28 result before its competing arc")
	city_scheduler.free()
	var result_event: Dictionary = DataRegistry.find_event(
		"v2_city_service_result_message")
	var result_choices: Array = (
		result_event.get("choices", []) as Array
		if result_event.get("choices", []) is Array else []
	)
	if result_choices.size() == 1:
		GameState.apply_choice(result_event, result_choices[0])
		_expect(CORE_LOOP.note_post_demo_application_result(
				"v2_city_service_result_message", 0),
			"City future result did not consume its typed receipt")
	_expect(CORE_LOOP.application_status(
			"city_facility_ops_2026h1") == "no_offer" \
			and CORE_LOOP.post_demo_application_result_event_id(
				28).is_empty(),
		"City future result did not close the submitted application")

func _check_hyunsu_future_bridge() -> void:
	var memories := [
		"hyunsu_exam_eve_one_problem",
		"hyunsu_exam_eve_rest_protected",
	]
	var result_event: Dictionary = DataRegistry.find_event(
		"hyunsu_result_fail")
	var result_memory_copy: Dictionary = (
		(result_event.get(
			"description_memory_if_known", {}) as Dictionary
		).duplicate(true)
		if result_event.get(
			"description_memory_if_known", {}) is Dictionary else {}
	)
	for memory_id in memories:
		_fresh_at(25)
		_set_relationship_memory(
			"hyunsu", memory_id, "hyunsu_exam_eve", 23)
		_expect((GameState.core_loop_v2_state.get(
				"future_story_receipts", {}) as Dictionary).is_empty(),
			"selected-memory partial save unexpectedly began with a future receipt")
		var selected_memory_partial: Dictionary = (
			GameState.serialize().duplicate(true)
		)
		GameState.start_new_game()
		GameState.load_from_dict(selected_memory_partial)
		CORE_LOOP.initialize_for_run()
		_set_turn_date(25)
		GameState.flags["prologue_done"] = true
		GameState.flags["chapter_33_seen"] = true
		GameState.flags["hyunsu_exam_day_seen"] = true
		var hyunsu_scheduler = MAIN_GAME_SCRIPT.new()
		var before_preview: Dictionary = (
			GameState.core_loop_v2_state.get(
				"future_story_receipts", {}) as Dictionary
		).duplicate(true)
		_expect(hyunsu_scheduler._next_arc_id(
					25, true, false) == "arc_temptation_01" \
				and GameState.core_loop_v2_state.get(
					"future_story_receipts", {}) == before_preview,
			"MainGame Hyunsu preview mutated the partial save or failed immediately")
		_expect(hyunsu_scheduler._next_arc_id(
				25, false, false) == "arc_temptation_01",
			"MainGame Hyunsu partial save displaced its Week-25 competing arc")
		var raw_receipt: Variant = (
			GameState.core_loop_v2_state.get(
				"future_story_receipts", {}) as Dictionary
		).get("hyunsu_exam_2026", {})
		var receipt: Dictionary = (
			(raw_receipt as Dictionary).duplicate(true)
			if raw_receipt is Dictionary else {}
		)
		_expect(str(receipt.get("receipt_id", "")) \
					== "hyunsu_exam_2026" \
				and str(receipt.get("source_memory", "")) == memory_id \
				and str(receipt.get("source_kind", "")) \
					== "relationship_memory" \
				and str(receipt.get("outcome", "")) == "fail" \
				and int(receipt.get("exam_turn", 0)) == 24 \
				and int(receipt.get("available_turn", 0)) == 27 \
				and str(receipt.get("result_event", "")) \
					== "hyunsu_result_fail",
			"Hyunsu V2 future-story receipt is not exact for %s"
				% memory_id)
		var saved: Dictionary = GameState.serialize().duplicate(true)
		GameState.start_new_game()
		GameState.load_from_dict(saved)
		CORE_LOOP.initialize_for_run()
		_set_turn_date(26)
		_expect(CORE_LOOP.hyunsu_exam_result_event_id(
				26, false).is_empty(),
			"Hyunsu V2 result appeared in Week 26 after reload")
		_set_turn_date(27)
		_expect(hyunsu_scheduler._next_arc_id(
				27, false, false) == "hyunsu_result_fail",
			"MainGame did not route Hyunsu's Week-27 result before its competing arc")
		GameState.flags["hyunsu_failed"] = true
		GameState.add_deferred_event(
			"arc_hyunsu_exam_fail", 4)
		_set_turn_date(28)
		_expect(hyunsu_scheduler._next_arc_id(
				28, false, false) != "hyunsu_result_fail",
			"MainGame replayed Hyunsu's consumed Week-27 result")
		_set_turn_date(31)
		EventManager.pending_events.clear()
		_expect(hyunsu_scheduler._next_arc_id(
					31, false, false) == "arc_hyunsu_exam_fail" \
				and GameState.has_deferred_event(
					"arc_hyunsu_exam_fail") \
				and EventManager.pending_events.is_empty(),
			"Hyunsu's Week-31 follow-up did not outrank competing arcs without consuming its guard")
		_expect(hyunsu_scheduler._next_arc_id(
					31, false, true) == "arc_hyunsu_exam_fail" \
				and not GameState.has_deferred_event(
					"arc_hyunsu_exam_fail") \
				and EventManager.pending_events.is_empty(),
			"Hyunsu's Week-31 follow-up did not enter the direct foreground handoff")
		hyunsu_scheduler.free()
		_expect(result_memory_copy.has(
				"relationship_memory:hyunsu:%s" % memory_id),
			"Hyunsu failure scene does not visibly read %s" % memory_id)

	_fresh_at(24)
	_unlock_hyunsu()
	_expect(CORE_LOOP.begin_bundle("demo_collision", "schedule"),
		"Hyunsu unanswered path could not begin the Week-24 collision")
	var unanswered_prepare := CORE_LOOP.prepare_demo_collision()
	var raw_unanswered: Variant = (
		GameState.core_loop_v2_state.get(
			"future_story_receipts", {}) as Dictionary
	).get("hyunsu_exam_2026", {})
	var unanswered_receipt: Dictionary = (
		(raw_unanswered as Dictionary).duplicate(true)
		if raw_unanswered is Dictionary else {}
	)
	_expect(bool(unanswered_prepare.get("ok", false)) \
			and (unanswered_prepare.get(
				"context", {}) as Dictionary).get(
					"roots", []) == [
						"v2_demo_first_bill",
						"v2_hyunsu_exam_morning_echo",
					] \
			and str(unanswered_receipt.get(
				"source_memory", "")) \
					== "hyunsu_exam_eve_unanswered" \
			and str(unanswered_receipt.get(
				"source_kind", "")) == "declined" \
			and str(unanswered_receipt.get(
				"decline_outcome", "")) \
					== "hyunsu_takes_the_exam_without_another_shared_hour" \
			and int(unanswered_receipt.get(
				"recorded_turn", 0)) == 24 \
			and CORE_LOOP.has_hyunsu_exam_outcome_receipt() \
			and CORE_LOOP.future_story_source_matches(
				"hyunsu_exam_2026",
				"hyunsu_exam_eve_unanswered"),
			"Hyunsu unanswered path did not freeze its exact Week-27 receipt")
	_apply_and_note_story_choice("v2_demo_first_bill", 0)
	_apply_and_note_story_choice("v2_hyunsu_exam_morning_echo", 0)
	_expect(CORE_LOOP.complete_active_bundle() == "demo_collision",
		"Hyunsu unanswered partial-save path did not close Week 24")
	var unanswered_partial_state: Dictionary = (
		GameState.core_loop_v2_state.duplicate(true)
	)
	unanswered_partial_state["future_story_receipts"] = {}
	GameState.core_loop_v2_state = unanswered_partial_state
	_set_turn_date(25)
	var unanswered_partial_saved: Dictionary = (
		GameState.serialize().duplicate(true)
	)
	GameState.start_new_game()
	GameState.load_from_dict(unanswered_partial_saved)
	CORE_LOOP.initialize_for_run()
	GameState.flags["prologue_done"] = true
	GameState.flags["chapter_33_seen"] = true
	GameState.flags["hyunsu_exam_day_seen"] = true
	var unanswered_scheduler = MAIN_GAME_SCRIPT.new()
	var unanswered_before_preview: Dictionary = (
		GameState.core_loop_v2_state.duplicate(true)
	)
	_expect(unanswered_scheduler._next_arc_id(
				25, true, false) == "arc_temptation_01" \
			and GameState.core_loop_v2_state \
				== unanswered_before_preview,
		"MainGame unanswered preview mutated or failed immediately in Week 25")
	_expect(unanswered_scheduler._next_arc_id(
			25, false, false) == "arc_temptation_01",
		"MainGame unanswered recovery displaced its Week-25 competing arc")
	var raw_reconstructed_unanswered: Variant = (
		GameState.core_loop_v2_state.get(
			"future_story_receipts", {}) as Dictionary
	).get("hyunsu_exam_2026", {})
	var reconstructed_unanswered: Dictionary = (
		(raw_reconstructed_unanswered as Dictionary).duplicate(true)
		if raw_reconstructed_unanswered is Dictionary else {}
	)
	_expect(str(reconstructed_unanswered.get(
				"source_memory", "")) \
				== "hyunsu_exam_eve_unanswered" \
			and str(reconstructed_unanswered.get(
				"source_kind", "")) == "declined" \
			and int(reconstructed_unanswered.get(
				"available_turn", 0)) == 27,
		"Hyunsu unanswered partial save did not reconstruct its future receipt")
	_set_turn_date(26)
	_expect(CORE_LOOP.hyunsu_exam_result_event_id(
			26, false).is_empty(),
		"Hyunsu unanswered path failed in Week 26")
	_set_turn_date(27)
	_expect(unanswered_scheduler._next_arc_id(
				27, false, false) == "hyunsu_result_fail" \
			and result_memory_copy.has(
				"future_story_source:hyunsu_exam_2026:"
					+ "hyunsu_exam_eve_unanswered"),
		"MainGame unanswered path did not open its authored Week-27 prose")
	GameState.flags["hyunsu_failed"] = true
	_set_turn_date(28)
	_expect(unanswered_scheduler._next_arc_id(
			28, false, false) != "hyunsu_result_fail",
		"MainGame replayed the consumed unanswered result")
	unanswered_scheduler.free()

func _check_deferred_foreground_scheduler() -> void:
	_fresh_at(25)
	GameState.flags["prologue_done"] = true
	GameState.flags["chapter_33_seen"] = true
	GameState.flags["chain_interior_gig"] = true
	GameState.flags["congratulated_neighbor"] = true
	GameState.current_job = {"id": "job_03"}
	GameState.housing = "gosiwon"
	GameState.deferred_events = [
		{
			"event_id": "chain_interior_offer",
			"trigger_turn": 24,
		},
		{
			"event_id": "chain_neighbor_moving",
			"trigger_turn": 24,
		},
	]
	EventManager.pending_events.clear()
	var scheduler = MAIN_GAME_SCRIPT.new()
	var before_probe: Array = GameState.deferred_events.duplicate(true)
	_expect(scheduler._next_arc_id(
				25, false, false) == "chain_neighbor_moving" \
			and GameState.deferred_events == before_probe \
			and EventManager.pending_events.is_empty(),
		"MainGame deferred guard consumed a reservation or queued a duplicate")
	_expect(scheduler._next_arc_id(
				25, false, true) == "chain_neighbor_moving" \
			and GameState.deferred_events.is_empty() \
			and EventManager.pending_events.is_empty(),
		"MainGame did not discard the stale callback and directly claim the next foreground event")
	scheduler.free()

func _check_actual_weeks_and_terminal_recap() -> void:
	_fresh_at(21)
	_seed_prior_development_state()
	_unlock_hyunsu()
	_set_application_status("dodam_customer_ops_2026q2", "submitted")
	_set_application_status("city_facility_ops_2026h1", "submitted")
	GameState.current_job = {
		"id": "job_03",
		"base_salary": 2_240_000,
		"display_name_ko": "한빛유통 물류센터 운영지원 계약직",
		"display_name_en":
			"Hanbit Logistics Operations Support (Contract)",
	}
	GameState.monthly_income = 2_240_000.0
	GameState.money = 1_300_000.0
	GameState.health = 90
	GameState.mental = 90
	_set_turn_date(21)

	# Month Six cannot be planned until the world-owned father signal closes.
	_expect(CORE_LOOP.pending_month_prelude(6) \
			== "father_health_signal" \
			and CORE_LOOP.needs_plan(6),
		"actual run did not stop at the Father pre-plan signal")
	_expect(CORE_LOOP.begin_bundle(
			"father_health_signal", "consequence"),
		"actual run could not begin Father prelude")
	_apply_and_note_story_choice("v2_father_health_signal", 0)
	_expect(CORE_LOOP.complete_active_bundle() \
			== "father_health_signal",
		"actual run could not consume Father prelude")

	var month_six_schedule := {
		"21": "m6_public_recruitment",
		"22": "m6_last_study_group",
		"23": "hyunsu_exam_eve",
		"24": "demo_collision",
	}
	var commit := CORE_LOOP.commit_plan(
		6, month_six_schedule, {
			"primary": "livelihood",
			"secondary": "recovery",
		})
	_expect(bool(commit.get("ok", false)),
		"actual Month-Six plan could not commit: %s" % [
			str(commit.get("error", "unknown"))])
	if not bool(commit.get("ok", false)):
		return

	_set_turn_date(21)
	_apply_routines_once(21)
	_expect(_execute_active_action("m6_public_recruitment"),
		"Week 21 NCS commitment failed")

	_set_turn_date(22)
	_apply_routines_once(22)
	_expect(CORE_LOOP.begin_bundle(
			"m6_last_study_group", "schedule"),
		"Week 22 study group could not begin")
	var dodam_claim := CORE_LOOP.claim_scheduled_prelude(
		"m6_last_study_group")
	_expect(_claim_matches(
			dodam_claim, "m6_dodam_response",
			"m6_last_study_group", 22, "action"),
		"actual Week 22 did not receive Dodam's result")
	_apply_and_note_story_choice("v2_dodam_result_message", 0)
	_expect(bool(CORE_LOOP.consume_scheduled_prelude(
			"m6_last_study_group").get("consumed", false)) \
			and _finish_begun_action("m6_last_study_group"),
		"Week 22 response/action did not close in order")

	_set_turn_date(23)
	_apply_routines_once(23)
	_expect(CORE_LOOP.begin_bundle("hyunsu_exam_eve", "schedule"),
		"Week 23 Hyunsu card could not begin")
	var city_claim := CORE_LOOP.claim_scheduled_prelude("hyunsu_exam_eve")
	_expect(_claim_matches(
			city_claim, "m6_city_service_response",
			"hyunsu_exam_eve", 23, "story"),
		"actual Week 23 did not receive the City work-sample request")
	_apply_and_note_story_choice(
		"v2_city_service_work_sample_message", 0)
	_expect(bool(CORE_LOOP.consume_scheduled_prelude(
			"hyunsu_exam_eve").get("consumed", false)) \
			and CORE_LOOP.application_status(
				"city_facility_ops_2026h1") == "submitted",
		"Week-23 City request did not remain submitted")
	_apply_and_note_story_choice("v2_hyunsu_exam_eve", 0)
	var actual_future_receipt: Dictionary = (
		(GameState.core_loop_v2_state.get(
			"future_story_receipts", {}) as Dictionary
		).get("hyunsu_exam_2026", {}) as Dictionary
	).duplicate(true)
	_expect(CORE_LOOP.complete_active_bundle() == "hyunsu_exam_eve" \
			and str(actual_future_receipt.get(
				"source_memory", "")) \
				== "hyunsu_exam_eve_one_problem" \
			and int(actual_future_receipt.get(
				"recorded_turn", 0)) == 23 \
			and int(actual_future_receipt.get(
				"available_turn", 0)) == 27,
		"Week 23 Hyunsu story did not close once")

	_set_turn_date(24)
	_apply_routines_once(24)
	_expect(CORE_LOOP.begin_bundle("demo_collision", "schedule"),
		"Week 24 collision could not begin")
	var preparation := CORE_LOOP.prepare_demo_collision()
	var collision_context: Dictionary = preparation.get("context", {})
	_expect(bool(preparation.get("ok", false)) \
			and collision_context.get("roots", []) == [
				"v2_demo_first_bill",
				"v2_hyunsu_exam_morning_echo",
			],
		"actual Week 24 did not order Friday bill before Saturday echo")
	_apply_and_note_story_choice("v2_demo_first_bill", 1)
	_apply_and_note_story_choice("v2_hyunsu_exam_morning_echo", 0)
	_expect(CORE_LOOP.complete_active_bundle() == "demo_collision" \
			and CORE_LOOP.turn_completed(24) \
			and CORE_LOOP.application_status(
				"city_facility_ops_2026h1") == "no_offer",
		"actual Week-24 non-City choice did not complete or close City")

	var routine_receipts: Dictionary = (
		GameState.core_loop_v2_state.get(
			"routine_receipts", {}) as Dictionary
	)
	var routine_units := 0
	for raw_receipt in routine_receipts.values():
		if raw_receipt is Dictionary \
				and (raw_receipt as Dictionary).get("units", []) is Array:
			routine_units += (
				(raw_receipt as Dictionary).get("units", []) as Array
			).size()
	_expect(routine_receipts.size() == 24 and routine_units == 48,
		"actual six-month run did not write 24 receipts / 48 routine units")
	var before_repeat_money := float(GameState.money)
	var repeated_routine := CORE_LOOP.apply_background_routines_for_turn(24)
	_expect(bool(repeated_routine.get("ok", false)) \
			and not bool(repeated_routine.get("applied", true)) \
			and is_equal_approx(float(GameState.money), before_repeat_money),
		"Week-24 routines applied twice")
	_expect(is_equal_approx(float(GameState.money), 1_300_000.0) \
			and is_equal_approx(
				GameState.get_monthly_payable_income(), 2_240_000.0) \
			and is_equal_approx(
				GameState.get_monthly_required_cash(), 650_000.0),
		"Hanbit Month-Six pre-close ledger is not 1.3m / 2.24m / 650k")

	var packed := load("res://scenes/MainGame.tscn") as PackedScene
	_expect(packed != null, "terminal QA could not load MainGame")
	if packed == null:
		return
	var main_game = packed.instantiate()
	main_game.set_meta("_screenshot_qa_static_surface", true)
	add_child(main_game)
	await get_tree().process_frame
	await get_tree().process_frame
	main_game.remove_meta("_screenshot_qa_static_surface")
	_game_over_signals = 0
	_captured_terminal_saves.clear()
	var save_callback := Callable(self, "_capture_terminal_save")
	if not SaveManager.save_completed.is_connected(save_callback):
		SaveManager.save_completed.connect(save_callback)
	main_game._core_loop_v2_advance_completed_week()
	await get_tree().process_frame

	_expect(GameState.turn == 25 \
			and CORE_LOOP.is_prototype_complete() \
			and not CORE_LOOP.is_active() \
			and not GameState.is_game_over \
			and _game_over_signals == 0 \
			and is_equal_approx(float(GameState.money), 2_890_000.0),
		"terminal boundary is not turn 25 / KRW 2.89m / no ending")
	_expect(_captured_terminal_saves.size() == 1,
		"terminal boundary did not write exactly one durable autosave")
	if _captured_terminal_saves.size() == 1:
		var saved_state := _captured_terminal_saves[0]
		var saved_v2: Dictionary = saved_state.get(
			"core_loop_v2_state", {})
		_expect(int(saved_state.get("turn", 0)) == 25 \
				and is_equal_approx(
					float(saved_state.get("money", 0.0)), 2_890_000.0) \
				and int(saved_v2.get(
					"completed_through_week", 0)) == 24 \
				and int(saved_v2.get(
					"completed_at_turn", 0)) == 25 \
				and (saved_v2.get(
					"month_summaries", {}) as Dictionary).size() == 6,
			"terminal autosave is not the full six-month completion snapshot")

	var done := _find_meta_node(
		main_game.modal_layer, "core_loop_v2_recap_done")
	var decline_panel := _find_meta_node(
		main_game.modal_layer, "core_loop_v2_recap_final_declines")
	var first_bill_panel := _find_meta_node(
		main_game.modal_layer, "core_loop_v2_recap_first_bill")
	var selected_panel := _find_meta_node(
		main_game.modal_layer,
		"core_loop_v2_recap_selected_obligations")
	var deferred_panel := _find_meta_node(
		main_game.modal_layer,
		"core_loop_v2_recap_deferred_obligations")
	var expired_panel := _find_meta_node(
		main_game.modal_layer, "core_loop_v2_recap_expired")
	var unresolved_panel := _find_meta_node(
		main_game.modal_layer, "core_loop_v2_recap_unresolved")
	var terminal_text := _node_text(main_game.modal_layer)
	var final_declines := CORE_LOOP.decline_receipts_for_month(6)
	_expect(str(main_game._modal_kind) == "core_loop_v2_complete" \
			and bool(main_game.modal_layer.get_meta(
				"core_loop_v2_completion", false)) \
			and is_instance_valid(done) \
			and done.get_parent() == main_game.modal_footer \
			and main_game.modal_footer.visible \
			and is_instance_valid(decline_panel) \
			and is_instance_valid(first_bill_panel) \
			and is_instance_valid(selected_panel) \
			and is_instance_valid(deferred_panel) \
			and is_instance_valid(expired_panel) \
			and is_instance_valid(unresolved_panel) \
			and final_declines.size() == 3,
		"turn-25 recap lost its sticky CTA or a priority/decline/expired/unresolved record")
	var hanbit_month_close := LocaleManager.ui(
		"한빛유통 월말 오류표를 끝낸다",
		"Finish Hanbit Distribution's month-end discrepancy sheet")
	var father_call := LocaleManager.ui(
		"아버지에게 다시 전화한다",
		"Call Father again")
	var city_work_sample := LocaleManager.ui(
		"도시시설운영단 작업표를 제출한다",
		"Submit the City Facilities worksheet")
	var body_rest := LocaleManager.ui(
		"알람만 맞추고 몸부터 눕힌다",
		"Set one alarm and lie down first")
	var selected_text := _node_text(selected_panel)
	var deferred_text := _node_text(deferred_panel)
	var expired_text := _node_text(expired_panel)
	_expect(_string_array(selected_panel.get_meta(
				"core_loop_v2_recap_selected_obligations", [])) \
				== ["hanbit_month_close"] \
			and _string_array(deferred_panel.get_meta(
				"core_loop_v2_recap_deferred_obligations", [])) \
				== ["father_call", "body_rest"] \
			and _string_array(expired_panel.get_meta(
				"core_loop_v2_recap_expired_obligations", [])) \
				== ["city_work_sample"],
		"actual terminal recap metadata did not preserve the exact selected/deferred/expired partition")
	_expect(LocaleManager.ui(
				"이번 주에 끝낸 일",
				"What I Finished This Week").to_upper() in selected_text \
			and LocaleManager.ui(
				"이번 주에 하지 못한 일",
				"What I Couldn't Do This Week").to_upper() \
				in deferred_text,
		"actual terminal recap lost its direct weekly headings")
	_expect(selected_text.count(hanbit_month_close) == 1 \
			and selected_text.count(father_call) == 0 \
			and selected_text.count(city_work_sample) == 0 \
			and selected_text.count(body_rest) == 0 \
			and deferred_text.count(father_call) == 1 \
			and deferred_text.count(body_rest) == 1 \
			and deferred_text.count(hanbit_month_close) == 0 \
			and deferred_text.count(city_work_sample) == 0 \
			and expired_text.count(city_work_sample) == 1 \
			and expired_text.count(hanbit_month_close) == 0 \
			and expired_text.count(father_call) == 0 \
			and expired_text.count(body_rest) == 0,
		"actual terminal recap duplicated or misplaced a Week-24 obligation")
	var city_expiration_receipts := _application_receipts_for(
		"demo_collision", "v2_demo_first_bill")
	var city_expiration_key := (
		"demo_collision:v2_demo_first_bill:1:24"
	)
	var city_expiration: Dictionary = (
		city_expiration_receipts[0]
		if city_expiration_receipts.size() == 1 else {}
	)
	_expect(city_expiration_receipts.size() == 1 \
			and str(city_expiration.get("receipt_key", "")) \
				== city_expiration_key \
			and str(city_expiration.get("application_id", "")) \
				== "city_facility_ops_2026h1" \
			and str(city_expiration.get("from", "")) == "submitted" \
			and str(city_expiration.get("to", "")) == "no_offer" \
			and int(city_expiration.get("choice_index", -1)) == 1 \
			and int(city_expiration.get("turn", 0)) == 24,
		"expired City work sample was not backed by its exact Week-24 transition receipt")
	var completion_snapshot := CORE_LOOP.completion_snapshot()
	var completion_obligation: Dictionary = (
		(completion_snapshot.get(
			"obligation_receipts", {}) as Dictionary
		).get("demo_collision", {}) as Dictionary
	)
	var missing_transition_snapshot := completion_snapshot.duplicate(true)
	missing_transition_snapshot["application_transition_receipts"] = {}
	var malformed_transition_snapshot := completion_snapshot.duplicate(true)
	var malformed_transitions: Dictionary = (
		(completion_snapshot.get(
			"application_transition_receipts", {}) as Dictionary
		).duplicate(true)
	)
	var malformed_city_transition: Dictionary = (
		(malformed_transitions.get(
			city_expiration_key, {}) as Dictionary).duplicate(true)
	)
	malformed_city_transition["receipt_key"] = "wrong:key"
	malformed_transitions[city_expiration_key] = (
		malformed_city_transition
	)
	malformed_transition_snapshot[
		"application_transition_receipts"] = malformed_transitions
	_expect(main_game._core_loop_v2_city_work_sample_expired(
				completion_snapshot, completion_obligation) \
			and not main_game._core_loop_v2_city_work_sample_expired(
				missing_transition_snapshot, completion_obligation) \
			and not main_game._core_loop_v2_city_work_sample_expired(
				malformed_transition_snapshot,
				completion_obligation),
		"City expiry classification did not require its exact application-transition receipt")
	var expected_actual_unresolved := [
		LocaleManager.ui(
			"아버지가 병원에 다니는지, 어디가 아픈지는 아직 모른다.",
			"You still do not know whether Father has been visiting a hospital or what is wrong."),
		LocaleManager.ui(
			"현수의 시험은 시작됐지만 결과는 아직 나오지 않았다.",
			"Hyunsu has taken the exam, but the result is not available yet."),
	]
	_expect(main_game._core_loop_v2_unresolved_recap(
			completion_snapshot) == expected_actual_unresolved,
		"actual terminal unresolved recap was not the exact Father/Hyunsu pair")
	for expected_unresolved in expected_actual_unresolved:
		_expect(expected_unresolved in _node_text(unresolved_panel),
			"terminal recap omitted unresolved state: %s" % expected_unresolved)
	var malformed_unresolved_snapshot := {
		"consequence_receipts": {
			"father_health_signal": {
				"consequence_id": "father_health_signal",
				"turn": 20,
				"status": "consumed",
			},
		},
		"future_story_receipts": {
			"hyunsu_exam_2026": {
				"receipt_id": "hyunsu_exam_2026",
				"character": "hyunsu",
				"outcome": "fail",
				"exam_turn": 24,
				"available_turn": 26,
				"result_event": "hyunsu_result_fail",
			},
		},
		"deferred_callback_receipts": {
			"callback_escaped_dirty_trace": {
				"source": "callback_escaped_dirty_trace",
				"root": "v2_dirty_trace_initial_call",
				"claimed_turn": 24,
				"status": "claimed",
			},
		},
	}
	_expect(main_game._core_loop_v2_unresolved_recap(
			malformed_unresolved_snapshot).is_empty(),
		"malformed or stale receipt keys invented unresolved recap facts")
	for dirty_choice_index in [0, 1]:
		var exact_dirty_snapshot := {
			"deferred_callback_receipts": {
				"callback_escaped_dirty_trace": {
					"source": "callback_escaped_dirty_trace",
					"trigger_turn": 24,
					"root": "v2_dirty_trace_initial_call",
					"event_id": "v2_dirty_trace_initial_call",
					"claimed_turn": 24,
					"status": "resolved",
					"synthetic": false,
					"choice_index": dirty_choice_index,
					"resolved_turn": 24,
				},
			},
		}
		_expect(main_game._core_loop_v2_unresolved_recap(
				exact_dirty_snapshot) == [
					LocaleManager.ui(
						"경찰의 초기 확인 전화는 끝났지만 출석 일정과 처분은 아직 정해지지 않았다.",
						"The police's initial call is over, but no appearance date or disposition has been set."),
				],
			"Week-24 dirty callback choice %d did not preserve its unresolved clue"
				% dirty_choice_index)
	var dense_unresolved_snapshot := completion_snapshot.duplicate(true)
	var dense_statuses: Dictionary = (
		dense_unresolved_snapshot.get(
			"application_statuses", {}) as Dictionary
	).duplicate(true)
	dense_statuses["city_facility_ops_2026h1"] = "submitted"
	dense_statuses["hanbit_ops_2026q1"] = "resolved"
	dense_unresolved_snapshot["application_statuses"] = dense_statuses
	dense_unresolved_snapshot["deferred_callback_receipts"] = {
		"callback_escaped_dirty_trace": {
			"source": "callback_escaped_dirty_trace",
			"trigger_turn": 24,
			"root": "v2_dirty_trace_initial_call",
			"event_id": "v2_dirty_trace_initial_call",
			"claimed_turn": 24,
			"status": "resolved",
			"synthetic": false,
			"choice_index": 1,
			"resolved_turn": 24,
		},
	}
	_expect(main_game._core_loop_v2_unresolved_recap(
			dense_unresolved_snapshot) == [
				expected_actual_unresolved[0],
				expected_actual_unresolved[1],
				LocaleManager.ui(
					"경찰의 초기 확인 전화는 끝났지만 출석 일정과 처분은 아직 정해지지 않았다.",
					"The police's initial call is over, but no appearance date or disposition has been set."),
				LocaleManager.ui(
					"도시시설운영단은 작업표를 접수했지만 면접·채용 결과는 아직 오지 않았다.",
					"City Facilities received the work sample, but no interview or hiring decision has arrived."),
				LocaleManager.ui(
					"한빛유통 계약이 얼마나 이어질지는 아직 알 수 없다.",
					"You still do not know how long the Hanbit contract will last."),
			],
		"dense terminal recap silently truncated a valid unresolved thread")
	_expect(LocaleManager.ui(
			"여섯 달의 기록을 자동 저장했다. 첫해는 아직 끝나지 않았다.",
			"Your six-month record was saved automatically. The first year is not over yet."
		) in terminal_text,
		"terminal recap did not confirm its durable save without closing Year One")
	for raw_decline in final_declines:
		if not raw_decline is Dictionary:
			continue
		var decline: Dictionary = raw_decline
		var ko := str(decline.get("message_ko", "")).strip_edges()
		var en := str(decline.get("message_en", "")).strip_edges()
		_expect(not ko.is_empty() and not en.is_empty(),
			"terminal decline lost full bilingual copy")
		var visible := en if LocaleManager.is_english() else ko
		_expect(terminal_text.contains(
				GameState.format_event_text(visible)),
			"terminal recap did not render a full Month-Six decline")

	main_game.set_meta("_screenshot_qa_static_surface", true)
	main_game._core_loop_v2_return_to_title()
	main_game.remove_meta("_screenshot_qa_static_surface")
	_expect(_captured_terminal_saves.size() == 1,
		"successful completion CTA wrote a duplicate autosave")
	if SaveManager.save_completed.is_connected(save_callback):
		SaveManager.save_completed.disconnect(save_callback)
	main_game.free()
	packed = null
	await get_tree().process_frame

	var failure_packed := load("res://scenes/MainGame.tscn") as PackedScene
	if failure_packed == null:
		_expect(false, "autosave-failure QA could not load MainGame")
		return
	var failure_main = failure_packed.instantiate()
	failure_main.set_meta("_screenshot_qa_static_surface", true)
	failure_main.set_meta("_qa_core_loop_v2_autosave_result", false)
	add_child(failure_main)
	await get_tree().process_frame
	await get_tree().process_frame
	failure_main._core_loop_v2_show_completion(true)
	await get_tree().process_frame
	var failure_done := _find_meta_node(
		failure_main.modal_layer, "core_loop_v2_recap_done")
	var failure_text := _node_text(failure_main.modal_layer)
	_expect(str(failure_main._modal_kind) == "core_loop_v2_complete" \
			and failure_main.modal_layer.visible \
			and is_instance_valid(failure_done) \
			and bool(failure_done.get_meta(
				"core_loop_v2_recap_requires_autosave_retry", false)) \
			and not bool(failure_main.modal_layer.get_meta(
				"core_loop_v2_completion_autosave_succeeded", true)) \
			and LocaleManager.ui(
				"자동 저장에 실패했다. 시작 화면으로 나가기 전에 다시 시도해 주세요.",
				"Autosave failed. Please try again before returning to the title screen."
			) in failure_text \
			and LocaleManager.ui(
				"자동 저장 다시 시도  ›",
				"Retry Autosave  ›") in failure_text,
		"completion autosave failure did not expose its blocking retry state")
	failure_main._core_loop_v2_return_to_title()
	_expect(str(failure_main._modal_kind) == "core_loop_v2_complete" \
			and failure_main.modal_layer.visible \
			and not bool(failure_main.get(
				"_core_loop_v2_completion_autosave_succeeded")),
		"failed completion retry allowed the run to leave its recap")
	failure_main.free()
	failure_packed = null
	await get_tree().process_frame

	_expect(SaveManager.load_game(SaveManager.AUTOSAVE_SLOT) \
			and CORE_LOOP.initialize_for_run() \
			and GameState.turn == 25 \
			and CORE_LOOP.is_prototype_complete() \
			and not GameState.is_game_over,
		"terminal autosave did not reload as completed turn 25")
	var reloaded_packed := load("res://scenes/MainGame.tscn") as PackedScene
	if reloaded_packed == null:
		_expect(false, "terminal resume could not reload MainGame")
		return
	var reloaded_main = reloaded_packed.instantiate()
	# A persisted completion must not call autosave again. Force any attempted
	# write to fail; the real _ready path must still trust the loaded save and
	# expose a non-blocking recap.
	reloaded_main.set_meta("_qa_core_loop_v2_autosave_result", false)
	add_child(reloaded_main)
	await get_tree().process_frame
	await get_tree().process_frame
	var reloaded_done := _find_meta_node(
		reloaded_main.modal_layer, "core_loop_v2_recap_done")
	_expect(GameState.turn == 25 \
			and str(reloaded_main._modal_kind) \
				== "core_loop_v2_complete" \
			and is_instance_valid(reloaded_done) \
			and not bool(reloaded_done.get_meta(
				"core_loop_v2_recap_requires_autosave_retry", true)) \
			and bool(reloaded_main.modal_layer.get_meta(
				"core_loop_v2_completion_autosave_succeeded", false)) \
			and LocaleManager.ui(
				"저장된 여섯 달의 기록을 열었다. 첫해는 아직 끝나지 않았다.",
				"Your saved six-month record is open. The first year is not over yet."
			) in _node_text(reloaded_main.modal_layer) \
			and not GameState.is_game_over \
			and _game_over_signals == 0,
		"completed save did not reopen without a redundant blocking autosave")
	reloaded_main.free()
	reloaded_packed = null
	await get_tree().process_frame

func _seed_prior_development_state() -> void:
	var state: Dictionary = GameState.core_loop_v2_state
	var plans: Dictionary = state.get("plans", {})
	var completed_turns: Array = range(1, 21)
	var completed_bundles: Array = []
	var completed_bundle_turns: Dictionary = {}
	for raw_month_key in PRIOR_SCHEDULES:
		var month_key := str(raw_month_key)
		var schedule: Dictionary = (
			(PRIOR_SCHEDULES[raw_month_key] as Dictionary).duplicate(true)
		)
		var selected: Array = []
		for raw_week in schedule:
			var bundle_id := str(schedule[raw_week])
			selected.append(bundle_id)
			if not completed_bundles.has(bundle_id):
				completed_bundles.append(bundle_id)
			completed_bundle_turns[bundle_id] = int(raw_week)
		plans[month_key] = {
			"schedule": schedule,
			"selected": selected,
			"routines": {
				"primary": "livelihood",
				"secondary": "recovery",
			},
			"forgone": [],
			"planned_turn": (int(month_key) - 1) * 4 + 1,
		}
	state["plans"] = plans
	state["completed_turns"] = completed_turns
	state["completed_bundles"] = completed_bundles
	state["completed_bundle_turns"] = completed_bundle_turns
	state["completed_through_week"] = 20
	GameState.core_loop_v2_state = state

	for week in range(1, 21):
		var routine := CORE_LOOP.apply_background_routines_for_turn(week)
		_expect(bool(routine.get("ok", false)) \
				and bool(routine.get("applied", false)) \
				and (routine.get("receipt", {}) as Dictionary).get(
					"units", []).size() == 2,
			"prior routine receipt failed at Week %d" % week)
	for month_index in range(1, 6):
		var snapshot := {
			"money": float(GameState.money),
			"cash_shortfall": CORE_LOOP.cash_shortfall_for_money(
				float(GameState.money)),
			"monthly_income": float(GameState.monthly_income),
			"fixed_expense": float(GameState.get_monthly_required_cash()),
			"health": int(GameState.health),
			"mental": int(GameState.mental),
		}
		CORE_LOOP.record_month_summary(
			month_index, snapshot, snapshot)
		CORE_LOOP.acknowledge_month_summary(month_index)

func _apply_routines_once(week: int) -> void:
	var result := CORE_LOOP.apply_background_routines_for_turn(week)
	var receipt: Dictionary = result.get("receipt", {})
	_expect(bool(result.get("ok", false)) \
			and bool(result.get("applied", false)) \
			and int(receipt.get("turn", 0)) == week \
			and (receipt.get("units", []) as Array).size() == 2,
		"Week %d did not apply exactly two background routine units" % week)

func _execute_active_action(bundle_id: String) -> bool:
	if not CORE_LOOP.begin_bundle(bundle_id, "schedule"):
		return false
	return _finish_begun_action(bundle_id)

func _finish_begun_action(bundle_id: String) -> bool:
	var scene_bundle := CORE_LOOP.bundle(bundle_id)
	var action_id := str(scene_bundle.get("action_id", ""))
	var config: Dictionary = scene_bundle.get("action_config", {})
	var execution := str(config.get("execution", ""))
	var effects: Dictionary = (
		(config.get("effects", {}) as Dictionary).duplicate(true)
		if config.get("effects", {}) is Dictionary else {}
	)
	var axis := str(config.get(
		"axis", "human" if execution == "rest" else "money"))
	var place_id := str(config.get(
		"place_id", "home" if execution == "rest" else "work"))
	var details := {"execution": execution}
	if execution == "application":
		details["application_id"] = str(config.get("application_id", ""))
		details["status"] = str(config.get("status", "submitted"))
		details["job_id"] = str(config.get("job_id", ""))
	else:
		details["effects"] = effects.duplicate(true)
		if execution == "instant_effect":
			details["axis"] = axis
			details["place_id"] = place_id
		if execution == "rest":
			details["diminished_by_recovery_routine"] = false
	GameState.restore_ap()
	if not GameState.arm_weekly_commitment({
			"turn": int(GameState.turn),
			"pressure_id": bundle_id,
			"pressure_family": "qa_e",
			"choice_id": action_id,
			"forgone_ids": [],
		}):
		return false
	var transaction := GameState.finalize_weekly_effect_action(
		action_id, effects, axis, place_id, "", details)
	if not bool(transaction.get("ok", false)) \
			or not CORE_LOOP.action_result_ready() \
			or CORE_LOOP.action_receipt(bundle_id).is_empty():
		return false
	return CORE_LOOP.complete_active_bundle() == bundle_id

func _apply_and_note_story_choice(
		event_id: String, choice_index: int) -> bool:
	var event: Dictionary = DataRegistry.find_event(event_id)
	var choices: Array = (
		event.get("choices", []) as Array
		if event.get("choices", []) is Array else []
	)
	if choice_index < 0 or choice_index >= choices.size():
		_expect(false, "%s choice %d is missing" % [
			event_id, choice_index])
		return false
	GameState.apply_choice(event, choices[choice_index])
	var noted := CORE_LOOP.note_story_choice(event_id, choice_index)
	_expect(noted, "%s choice %d did not write its receipt" % [
		event_id, choice_index])
	return noted

func _claim_matches(
		result: Dictionary, consequence_id: String,
		scheduled_bundle: String, turn: int,
		surface_kind: String) -> bool:
	var receipt: Dictionary = result.get("receipt", {})
	return bool(result.get("ok", false)) \
		and bool(result.get("claimed", false)) \
		and str(receipt.get("consequence_id", "")) == consequence_id \
		and str(receipt.get("scheduled_bundle", "")) == scheduled_bundle \
		and int(receipt.get("turn", 0)) == turn \
		and str(receipt.get("status", "")) == "presented" \
		and str(receipt.get("surface_kind", "")) == surface_kind

func _application_receipts_for(
		bundle_id: String, event_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var raw_receipts: Variant = GameState.core_loop_v2_state.get(
		"application_transition_receipts", {})
	if not raw_receipts is Dictionary:
		return result
	for raw_receipt in (raw_receipts as Dictionary).values():
		if raw_receipt is Dictionary \
				and str((raw_receipt as Dictionary).get(
					"bundle_id", "")) == bundle_id \
				and str((raw_receipt as Dictionary).get(
					"event_id", "")) == event_id:
			result.append((raw_receipt as Dictionary).duplicate(true))
	return result

func _consequence_receipt(consequence_id: String) -> Dictionary:
	var raw_receipts: Variant = GameState.core_loop_v2_state.get(
		"consequence_receipts", {})
	if not raw_receipts is Dictionary:
		return {}
	var raw_receipt: Variant = (
		raw_receipts as Dictionary
	).get(consequence_id, {})
	return (raw_receipt as Dictionary).duplicate(true) \
		if raw_receipt is Dictionary else {}

func _obligation_receipt() -> Dictionary:
	var raw_receipts: Variant = GameState.core_loop_v2_state.get(
		"obligation_receipts", {})
	if not raw_receipts is Dictionary:
		return {}
	var raw_receipt: Variant = (
		raw_receipts as Dictionary
	).get("demo_collision", {})
	return (raw_receipt as Dictionary).duplicate(true) \
		if raw_receipt is Dictionary else {}

func _callback_receipt(source: String) -> Dictionary:
	var raw_receipts: Variant = GameState.core_loop_v2_state.get(
		"deferred_callback_receipts", {})
	if not raw_receipts is Dictionary:
		return {}
	var raw_receipt: Variant = (raw_receipts as Dictionary).get(source, {})
	return (raw_receipt as Dictionary).duplicate(true) \
		if raw_receipt is Dictionary else {}

func _seed_consumed_consequence(
		consequence_id: String, presented_turn: int) -> void:
	var state: Dictionary = GameState.core_loop_v2_state
	var shown: Array = state.get("shown_consequences", [])
	if not shown.has(consequence_id):
		shown.append(consequence_id)
	state["shown_consequences"] = shown
	var shown_turns: Dictionary = state.get("shown_consequence_turns", {})
	shown_turns[consequence_id] = presented_turn
	state["shown_consequence_turns"] = shown_turns
	var receipts: Dictionary = state.get("consequence_receipts", {})
	receipts[consequence_id] = {
		"consequence_id": consequence_id,
		"scheduled_bundle": "qa_prior_owner",
		"turn": presented_turn,
		"status": "consumed",
		"surface_kind": "story",
		"roots": CORE_LOOP.resolved_event_roots(consequence_id),
		"presented_turn": presented_turn,
		"consumed_turn": presented_turn,
		"legacy_separate_owner": false,
	}
	state["consequence_receipts"] = receipts
	GameState.core_loop_v2_state = state

func _deferred_event_ids() -> Array[String]:
	var result: Array[String] = []
	for raw_entry in GameState.deferred_events:
		if raw_entry is Dictionary:
			result.append(str(
				(raw_entry as Dictionary).get("event_id", "")))
	return result

func _fresh_at(target_turn: int) -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	_set_turn_date(target_turn)

func _set_turn_date(target_turn: int) -> void:
	GameState.turn = target_turn
	GameState.year = 1
	GameState.month = int((target_turn - 1) / 4) + 1
	GameState.week_of_month = ((target_turn - 1) % 4) + 1

func _mark_completed(bundle_id: String, completion_turn: int) -> void:
	var state: Dictionary = GameState.core_loop_v2_state
	var completed: Array = state.get("completed_bundles", [])
	if not completed.has(bundle_id):
		completed.append(bundle_id)
	state["completed_bundles"] = completed
	var turns: Dictionary = state.get("completed_bundle_turns", {})
	turns[bundle_id] = completion_turn
	state["completed_bundle_turns"] = turns
	GameState.core_loop_v2_state = state

func _set_application_status(
		application_id: String, status: String) -> void:
	var state: Dictionary = GameState.core_loop_v2_state
	var statuses: Dictionary = state.get("application_statuses", {})
	statuses[application_id] = status
	state["application_statuses"] = statuses
	GameState.core_loop_v2_state = state

func _set_relationship_stage(
		character: String, stage: String) -> void:
	var state: Dictionary = GameState.core_loop_v2_state
	var stages: Dictionary = state.get("relationship_stages", {})
	stages[character] = stage
	state["relationship_stages"] = stages
	GameState.core_loop_v2_state = state

func _set_relationship_memory(
		character: String, memory: String,
		bundle_id: String, memory_turn: int) -> void:
	var state: Dictionary = GameState.core_loop_v2_state
	var memories: Array = state.get("relationship_memories", [])
	for raw_receipt in memories:
		if raw_receipt is Dictionary \
				and str((raw_receipt as Dictionary).get(
					"character", "")) == character \
				and str((raw_receipt as Dictionary).get(
					"memory", "")) == memory:
			return
	memories.append({
		"character": character,
		"memory": memory,
		"bundle_id": bundle_id,
		"turn": memory_turn,
	})
	state["relationship_memories"] = memories
	GameState.core_loop_v2_state = state

func _set_player_initiated(character: String) -> void:
	var state: Dictionary = GameState.core_loop_v2_state
	var initiated: Array = state.get("player_initiated", [])
	if not initiated.has(character):
		initiated.append(character)
	state["player_initiated"] = initiated
	GameState.core_loop_v2_state = state

func _unlock_hyunsu() -> void:
	_mark_completed("hyunsu_study_followup", 11)
	_set_relationship_stage("hyunsu", "shared_commitment")

func _unlock_daeun() -> void:
	_mark_completed("daeun_shared_dream", 20)
	_set_relationship_stage("daeun", "shared_commitment")
	_set_relationship_memory(
		"daeun", "daeun_same_tuesday_promised",
		"daeun_shared_dream", 20)
	_set_player_initiated("daeun")

func _find_meta_node(root: Node, meta_key: String) -> Node:
	if not is_instance_valid(root):
		return null
	if root.has_meta(meta_key):
		return root
	for child in root.get_children():
		var found := _find_meta_node(child, meta_key)
		if is_instance_valid(found):
			return found
	return null

func _node_text(root: Node) -> String:
	if not is_instance_valid(root):
		return ""
	var parts: Array[String] = []
	if root is Label:
		parts.append((root as Label).text)
	elif root is Button:
		parts.append((root as Button).text)
	for child in root.get_children():
		var child_text := _node_text(child)
		if not child_text.is_empty():
			parts.append(child_text)
	return "\n".join(parts)

func _same_string_set(left: Array, right: Array) -> bool:
	if left.size() != right.size():
		return false
	var left_strings := _string_array(left)
	var right_strings := _string_array(right)
	left_strings.sort()
	right_strings.sort()
	return left_strings == right_strings

func _string_array(values: Array) -> Array[String]:
	var result: Array[String] = []
	for raw_value in values:
		result.append(str(raw_value))
	return result

func _int_array(raw_values: Variant) -> Array[int]:
	var result: Array[int] = []
	if raw_values is Array:
		for raw_value in raw_values:
			result.append(int(raw_value))
	return result

func _capture_v2_action_receipt(record: Dictionary) -> void:
	if CORE_LOOP.is_active():
		CORE_LOOP.note_action_commitment(record)

func _capture_terminal_save(success: bool, slot: int) -> void:
	if success and slot == SaveManager.AUTOSAVE_SLOT:
		_captured_terminal_saves.append(
			GameState.serialize().duplicate(true))

func _capture_game_over(_ending_id: String) -> void:
	_game_over_signals += 1

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
