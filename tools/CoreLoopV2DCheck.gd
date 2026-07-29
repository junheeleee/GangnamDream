extends Node
## ORDER-57 D: weeks 17–20 offers, receipts, declines, and terminal boundary.

const CORE_LOOP := preload("res://systems/DemoCoreLoopV2.gd")

const BASE_OFFERS := [
	"m5_city_service_application",
	"m5_weekend_move_shift",
	"m5_evening_spreadsheet_class",
	"m5_last_empty_sunday",
	"m5_employment_contract_clinic",
]

const PERSON_OFFERS := [
	"daeun_shared_dream",
	"daeun_third_greeting",
	"jiyeon_second_crossing",
	"sangchul_second_coffee",
	"jaehyuk_plain_reunion_echo",
]

const M5_ACTIONS := {
	"m5_city_service_application": {
		"action": "apply",
		"execution": "application",
		"weeks": [17],
	},
	"m5_weekend_move_shift": {
		"action": "side_shift",
		"execution": "instant_effect",
		"weeks": [17, 18, 19, 20],
	},
	"m5_evening_spreadsheet_class": {
		"action": "study",
		"execution": "instant_effect",
		"weeks": [17, 18, 19, 20],
	},
	"m5_last_empty_sunday": {
		"action": "rest",
		"execution": "rest",
		"weeks": [17, 18, 19, 20],
	},
	"m5_employment_contract_clinic": {
		"action": "study",
		"execution": "instant_effect",
		"weeks": [17, 18, 19, 20],
	},
}

const M5_STORY_ROOTS := {
	"daeun_shared_dream": {
		"root": "v2_daeun_small_commitment",
		"phone_surface": "self_note",
		"weeks": [20],
	},
	"daeun_third_greeting": {
		"root": "v2_daeun_third_greeting",
		"phone_surface": "self_note",
		"weeks": [20],
	},
	"jiyeon_second_crossing": {
		"root": "v2_jiyeon_second_crossing",
		"phone_surface": "self_note",
		"weeks": [20],
	},
	"sangchul_second_coffee": {
		"root": "v2_sangchul_demo_echo",
		"phone_surface": "self_note",
		"weeks": [20],
	},
	"jaehyuk_plain_reunion_echo": {
		"root": "v2_jaehyuk_plain_reunion_echo",
		"phone_surface": "inbound_message",
		"weeks": [20],
	},
}

const EXPECTED_RELATIONSHIP_OUTCOMES := [
	{
		"bundle": "daeun_shared_dream",
		"event": "v2_daeun_small_commitment",
		"choice": 0,
		"character": "daeun",
		"from": "player_reached_out",
		"to": "shared_commitment",
		"initiative": "reciprocal",
		"memory": "daeun_same_tuesday_promised",
	},
	{
		"bundle": "daeun_shared_dream",
		"event": "v2_daeun_small_commitment",
		"choice": 1,
		"character": "daeun",
		"from": "player_reached_out",
		"to": "shared_commitment",
		"initiative": "reciprocal",
		"memory": "daeun_late_meal_promised",
	},
	{
		"bundle": "daeun_third_greeting",
		"event": "v2_daeun_third_greeting",
		"choice": 0,
		"character": "daeun",
		"from": "opening",
		"to": "player_reached_out",
		"initiative": "player",
		"memory": "daeun_third_greeting_started",
	},
	{
		"bundle": "daeun_third_greeting",
		"event": "v2_daeun_third_greeting",
		"choice": 1,
		"character": "daeun",
		"from": "opening",
		"to": "player_reached_out",
		"initiative": "player",
		"memory": "daeun_shift_question_asked",
	},
	{
		"bundle": "jiyeon_second_crossing",
		"event": "v2_jiyeon_second_crossing",
		"choice": 0,
		"character": "jiyeon",
		"from": "opening",
		"to": "player_reached_out",
		"initiative": "reciprocal",
		"memory": "jiyeon_neighborhood_coffee_accepted",
	},
	{
		"bundle": "jiyeon_second_crossing",
		"event": "v2_jiyeon_second_crossing",
		"choice": 1,
		"character": "jiyeon",
		"from": "opening",
		"to": "player_reached_out",
		"initiative": "player",
		"memory": "jiyeon_talk_without_debt_requested",
	},
	{
		"bundle": "jiyeon_second_crossing",
		"event": "v2_jiyeon_second_crossing",
		"choice": 2,
		"character": "jiyeon",
		"from": "opening",
		"to": "opening",
		"initiative": "reciprocal",
		"memory": "jiyeon_coffee_fully_refused",
	},
	{
		"bundle": "sangchul_second_coffee",
		"event": "v2_sangchul_demo_echo",
		"choice": 0,
		"character": "sangchul",
		"from": "met",
		"to": "opening",
		"initiative": "player",
		"memory": "sangchul_own_pace_stated",
	},
	{
		"bundle": "sangchul_second_coffee",
		"event": "v2_sangchul_demo_echo",
		"choice": 1,
		"character": "sangchul",
		"from": "met",
		"to": "opening",
		"initiative": "player",
		"memory": "sangchul_numbers_first_recorded",
	},
	{
		"bundle": "jaehyuk_plain_reunion_echo",
		"event": "v2_jaehyuk_plain_reunion_echo",
		"choice": 0,
		"character": "jaehyuk",
		"from": "met",
		"to": "opening",
		"initiative": "reciprocal",
		"memory": "jaehyuk_reunion_warm",
	},
	{
		"bundle": "jaehyuk_plain_reunion_echo",
		"event": "v2_jaehyuk_plain_reunion_echo",
		"choice": 1,
		"character": "jaehyuk",
		"from": "met",
		"to": "opening",
		"initiative": "reciprocal",
		"memory": "jaehyuk_reunion_guarded",
	},
]

const RELATIONSHIP_STAGES := [
	"unmet",
	"met",
	"opening",
	"player_reached_out",
	"shared_commitment",
	"romantic_intent",
	"date",
	"exclusive",
	"closed",
]

var _failures: Array[String] = []
var _captured_boundary_saves: Array[Dictionary] = []
var _autosave_backup: Dictionary = {}
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

	_check_contract()
	_check_month_five_offer_matrix()
	_check_person_climax_exclusivity()
	_check_m5_execution_surfaces()
	_check_hanbit_offer_choices()
	_check_hanbit_month_five_ledger()
	_check_relationship_outcomes_and_roundtrips()
	_check_m5_action_roundtrips()
	_check_month_five_declines_once()
	_check_c_system_records_once()
	await _check_week_twenty_terminal_boundary()

	if GameState.game_over.is_connected(game_over_callback):
		GameState.game_over.disconnect(game_over_callback)
	AudioManager.sfx_enabled = original_sfx_enabled
	_restore_autosave()
	if _failures.is_empty():
		print(
			"CORE_LOOP_V2_D_CHECK_OK schema=3 cap=20 prototype=1_20 "
			+ "offers=sparse5_rich7/c_path_exact "
			+ "person_climax=maximum1 surfaces=actions5/roots5 "
			+ "hanbit=inbox/interviewed_to_resolved/prorated_hire_or_decline/save/ledger1300000 "
			+ "relationship=all_choices/one_or_same_step/turn20/save "
			+ "actions=apply_shift_study_rest_clinic/atomic/no_reapply "
			+ "declines=month6_once/save system_records=month5_once "
			+ "terminal=week20/turn21/single_save/sticky/no_finish/no_legacy "
			+ "father_signal=week21/non_slot/not_executed")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("CORE_LOOP_V2_D_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)

func _check_contract() -> void:
	var contract := CORE_LOOP.contract()
	var scope: Dictionary = (
		(contract.get("scope", {}) as Dictionary).duplicate(true)
		if contract.get("scope", {}) is Dictionary else {}
	)
	var prototype_weeks: Array = (
		(scope.get("prototype_weeks", []) as Array).duplicate()
		if scope.get("prototype_weeks", []) is Array else []
	)
	_expect(int(contract.get("schema_version", 0)) == 3,
		"D runtime contract is not schema 3")
	_expect(CORE_LOOP.development_cap_week() == 20 \
			and int(scope.get("development_cap_week", 0)) == 20,
		"D development cap is not week 20")
	_expect(_int_array(prototype_weeks) == [1, 20],
		"D prototype window is not exactly weeks 1–20")
	_expect(not bool(contract.get("runtime_default", true)),
		"D enabled the unfinished V2 loop by default")

	var month_five := CORE_LOOP.month_spec(5)
	var month_five_weeks: Array = (
		(month_five.get("weeks", []) as Array).duplicate()
		if month_five.get("weeks", []) is Array else []
	)
	var month_five_offers: Array = (
		(month_five.get("offers", []) as Array).duplicate()
		if month_five.get("offers", []) is Array else []
	)
	_expect(_int_array(month_five_weeks) == [17, 20],
		"Month Five does not own exactly weeks 17–20")
	_expect(_same_string_set(
			month_five_offers, BASE_OFFERS + PERSON_OFFERS),
		"Month Five offer catalog drifted from five base and five path offers")

	var surface: Dictionary = (
		(contract.get("surface", {}) as Dictionary).duplicate(true)
		if contract.get("surface", {}) is Dictionary else {}
	)
	_expect(int(surface.get("foreground_slots_per_month", 0)) == 4 \
			and int(surface.get("minimum_offers_per_month", 0)) == 5 \
			and int(surface.get("maximum_offers_per_month", 0)) == 7,
		"Month Five offer/slot surface is not 4 / 5–7")

func _check_month_five_offer_matrix() -> void:
	_fresh_at(17)
	var sparse := CORE_LOOP.available_offer_ids(5)
	_expect(sparse.size() == 5 \
			and _same_string_set(sparse, BASE_OFFERS),
		"sparse Month Five is not exactly the five base offers: %s" % [
			str(sparse)])
	_expect(_string_intersection(sparse, PERSON_OFFERS).is_empty(),
		"a relationship or money follow-up appeared without its C path")

	for raw_bundle_id in PERSON_OFFERS:
		var bundle_id := str(raw_bundle_id)
		_fresh_at(17)
		_unlock_c_path_for(bundle_id)
		var offers := CORE_LOOP.available_offer_ids(5)
		var visible_people := _string_intersection(offers, PERSON_OFFERS)
		_expect(visible_people == [bundle_id],
			"C path for %s did not expose exactly its one D follow-up: %s" % [
				bundle_id, str(visible_people)])
		_expect(offers.size() == 6,
			"single C path for %s did not produce five base plus one follow-up"
				% bundle_id)

	_fresh_at(17)
	_unlock_c_path_for("daeun_shared_dream")
	_unlock_c_path_for("sangchul_second_coffee")
	var rich := CORE_LOOP.available_offer_ids(5)
	_expect(rich.size() == 7 \
			and _same_string_set(
				rich,
				BASE_OFFERS + [
					"daeun_shared_dream",
					"sangchul_second_coffee",
				]),
		"rich valid Month Five is not capped at seven offers: %s" % [
			str(rich)])

func _check_person_climax_exclusivity() -> void:
	var groups: Dictionary = (
		(CORE_LOOP.contract().get(
			"exclusive_groups", {}) as Dictionary).duplicate(true)
		if CORE_LOOP.contract().get(
			"exclusive_groups", {}) is Dictionary else {}
	)
	var raw_group: Variant = groups.get("month_five_person_climax", {})
	var group: Dictionary = (
		(raw_group as Dictionary).duplicate(true)
		if raw_group is Dictionary else {}
	)
	var members: Array = (
		(group.get("members", []) as Array).duplicate()
		if group.get("members", []) is Array else []
	)
	_expect(_same_string_set(members, PERSON_OFFERS) \
			and int(group.get("maximum_selected", 0)) == 1 \
			and str(group.get("scope", "")) == "month",
		"month_five_person_climax does not own all five paths at maximum one")

	_fresh_at(17)
	_unlock_c_path_for("daeun_shared_dream")
	_unlock_c_path_for("sangchul_second_coffee")
	var legal_schedule := _schedule_for_bundles([
		"m5_city_service_application",
		"m5_weekend_move_shift",
		"m5_evening_spreadsheet_class",
		"daeun_shared_dream",
	], [17, 18, 19, 20])
	_expect(legal_schedule.size() == 4 \
			and bool(CORE_LOOP.validate_plan(
				5, legal_schedule, _growth_routines()).get("ok", false)),
		"one Month Five person climax could not be scheduled legally")

	var two_person_schedule := _schedule_for_bundles([
		"m5_city_service_application",
		"m5_weekend_move_shift",
		"daeun_shared_dream",
		"sangchul_second_coffee",
	], [17, 18, 19, 20])
	_expect(two_person_schedule.is_empty(),
		"two week-20 person climaxes found distinct legal slots")
	var forced_two_person := {
		"17": "m5_city_service_application",
		"18": "m5_weekend_move_shift",
		"19": "daeun_shared_dream",
		"20": "sangchul_second_coffee",
	}
	_expect(not bool(CORE_LOOP.validate_plan(
			5, forced_two_person, _growth_routines()).get("ok", false)),
		"Month Five accepted two person climaxes in one plan")

func _check_m5_execution_surfaces() -> void:
	for raw_bundle_id in M5_ACTIONS:
		var bundle_id := str(raw_bundle_id)
		var expected: Dictionary = M5_ACTIONS[raw_bundle_id]
		var scene_bundle := CORE_LOOP.bundle(bundle_id)
		var config: Dictionary = (
			(scene_bundle.get("action_config", {}) as Dictionary)
				.duplicate(true)
			if scene_bundle.get("action_config", {}) is Dictionary else {}
		)
		_expect(_int_array(scene_bundle.get("allowed_weeks", [])) \
				== _int_array(expected.get("weeks", [])),
			"%s has the wrong machine deadline" % bundle_id)
		_expect(str(scene_bundle.get("action_id", "")) \
				== str(expected.get("action", "")) \
				and str(config.get("execution", "")) \
					== str(expected.get("execution", "")) \
				and bool(scene_bundle.get("consumes_slot", false)),
			"%s does not resolve to its executable action surface" % bundle_id)
		_expect(str(scene_bundle.get("phone_surface", "")) == "self_note",
			"%s is not presented as a player-owned phone note" % bundle_id)
		for copy_key in [
			"offer_ko", "offer_en", "detail_ko", "detail_en",
			"deadline_ko", "deadline_en", "decline_ko", "decline_en",
		]:
			_expect(not str(scene_bundle.get(
					copy_key, "")).strip_edges().is_empty(),
				"%s lacks %s" % [bundle_id, copy_key])
		for result_key in [
			"result_title_ko", "result_title_en",
			"result_body_ko", "result_body_en",
		]:
			_expect(not str(config.get(
					result_key, "")).strip_edges().is_empty(),
				"%s lacks executable result copy %s" % [
					bundle_id, result_key])
		match str(config.get("execution", "")):
			"application":
				_expect(not str(config.get(
						"application_id", "")).strip_edges().is_empty() \
						and str(config.get("status", "")) == "submitted",
					"%s application has no submitted receipt" % bundle_id)
			"instant_effect":
				_expect(config.get("effects", {}) is Dictionary \
						and not (config.get("effects", {}) as Dictionary)
							.is_empty() \
						and str(config.get("axis", "")) in ["money", "human"] \
						and not str(config.get(
							"place_id", "")).strip_edges().is_empty(),
					"%s instant action lacks effects, axis, or place" % bundle_id)
			"rest":
				_expect(config.get("effects", {}) is Dictionary \
						and not (config.get("effects", {}) as Dictionary)
							.is_empty(),
					"%s recovery action has no effects" % bundle_id)

	for raw_bundle_id in M5_STORY_ROOTS:
		var bundle_id := str(raw_bundle_id)
		var expected: Dictionary = M5_STORY_ROOTS[raw_bundle_id]
		var scene_bundle := CORE_LOOP.bundle(bundle_id)
		var roots := CORE_LOOP.resolved_event_roots(bundle_id)
		var root_id := str(expected.get("root", ""))
		_expect(_int_array(scene_bundle.get("allowed_weeks", [])) \
				== _int_array(expected.get("weeks", [])),
			"%s has the wrong machine deadline" % bundle_id)
		_expect(roots == [root_id] \
				and not DataRegistry.find_event(root_id).is_empty() \
				and not scene_bundle.has("action_id") \
				and bool(scene_bundle.get("consumes_slot", false)),
			"%s does not resolve to one real story root" % bundle_id)
		_expect(str(scene_bundle.get("phone_surface", "")) \
				== str(expected.get("phone_surface", "")),
			"%s has the wrong phone-origin surface" % bundle_id)

	var future_contracts: Dictionary = (
		(CORE_LOOP.contract().get(
			"future_application_contracts", {}) as Dictionary)
				.duplicate(true)
		if CORE_LOOP.contract().get(
			"future_application_contracts", {}) is Dictionary else {}
	)
	var raw_city_future: Variant = future_contracts.get(
		"m6_city_service_response", {})
	var city_future: Dictionary = (
		(raw_city_future as Dictionary).duplicate(true)
		if raw_city_future is Dictionary else {}
	)
	_expect(str(city_future.get("producer_bundle", "")) \
			== "m5_city_service_application" \
			and str(city_future.get("application_id", "")) \
				== "city_facility_ops_2026h1" \
			and str(city_future.get("from", "")) == "submitted" \
			and int(city_future.get("owner_month", 0)) == 6 \
			and int(city_future.get("activation_cap_week", 0)) == 24,
		"the Month Five application has no deferred Month Six reader")

func _check_hanbit_offer_choices() -> void:
	var offer := CORE_LOOP.bundle("m5_hanbit_offer_message")
	_expect(_int_array(offer.get("allowed_weeks", [])) == [17] \
			and not bool(offer.get("consumes_slot", true)) \
			and CORE_LOOP.resolved_event_roots(
				"m5_hanbit_offer_message") == [
					"v2_hanbit_offer_message",
				],
		"Hanbit's final result is not a non-slot Week-17 message")

	_fresh_at(17)
	_expect(CORE_LOOP.pending_consequence_id().is_empty(),
		"Hanbit's offer appeared without an interview receipt")
	_mark_completed("m4_hanbit_interview", 14)
	_expect(CORE_LOOP.pending_consequence_id().is_empty(),
		"Hanbit's offer appeared without interviewed application status")
	_set_application_status("hanbit_ops_2026q1", "interviewed")
	_expect(CORE_LOOP.pending_consequence_id() \
			== "m5_hanbit_offer_message",
		"the completed Hanbit interview did not unlock its Week-17 result")
	_expect(CORE_LOOP.received_phone_consequence_ids(5).is_empty(),
		"Hanbit's future Tuesday message leaked into the opening planner")

	for choice_index in [0, 1]:
		_fresh_at(17)
		_mark_completed("m4_hanbit_interview", 14)
		_set_application_status("hanbit_ops_2026q1", "interviewed")
		_expect(CORE_LOOP.begin_bundle(
				"m5_city_service_application", "schedule"),
			"Hanbit result fixture could not begin its Week-17 owner")
		var claimed := CORE_LOOP.claim_scheduled_prelude(
			"m5_city_service_application")
		var claim_receipt: Dictionary = (
			(claimed.get("receipt", {}) as Dictionary).duplicate(true)
			if claimed.get("receipt", {}) is Dictionary else {}
		)
		_expect(bool(claimed.get("ok", false)) \
				and bool(claimed.get("claimed", false)) \
				and str(claim_receipt.get("consequence_id", "")) \
					== "m5_hanbit_offer_message" \
				and str(claim_receipt.get("status", "")) == "presented",
			"Hanbit's result did not attach to the scheduled Week-17 owner")
		var duplicate_claim := CORE_LOOP.claim_scheduled_prelude(
			"m5_city_service_application")
		_expect(bool(duplicate_claim.get("ok", false)) \
				and not bool(duplicate_claim.get("claimed", true)) \
				and CORE_LOOP.received_phone_consequence_ids(5) \
					== ["m5_hanbit_offer_message"],
			"Hanbit's presented message was not durable or claimed twice")

		var event: Dictionary = DataRegistry.find_event(
			"v2_hanbit_offer_message")
		var choices: Array = (
			event.get("choices", []) as Array
			if event.get("choices", []) is Array else []
		)
		_expect(choices.size() == 2,
			"Hanbit's result no longer has accept and decline choices")
		if choice_index < 0 or choice_index >= choices.size():
			continue
		GameState.apply_choice(event, choices[choice_index])
		_expect(CORE_LOOP.note_story_choice(
				"v2_hanbit_offer_message", choice_index),
			"Hanbit result choice %d did not write its application receipt"
				% choice_index)
		var receipts: Dictionary = GameState.core_loop_v2_state.get(
			"application_transition_receipts", {})
		var receipt_count := receipts.size()
		var transition_receipt: Dictionary = (
			(receipts.values()[0] as Dictionary).duplicate(true)
			if receipt_count == 1 and receipts.values()[0] is Dictionary
			else {}
		)
		var consumed := CORE_LOOP.consume_scheduled_prelude(
			"m5_city_service_application")
		_expect(receipt_count == 1 \
				and int(transition_receipt.get(
					"choice_index", -1)) == choice_index \
				and CORE_LOOP.application_status(
					"hanbit_ops_2026q1") == "resolved" \
				and bool(consumed.get("ok", false)) \
				and bool(consumed.get("consumed", false)),
			"Hanbit result choice %d did not resolve and consume once"
				% choice_index)
		if choice_index == 0:
			_expect(str(GameState.current_job.get("id", "")) == "job_03" \
					and is_equal_approx(
						float(GameState.monthly_income), 2_240_000.0) \
					and is_equal_approx(
						GameState.get_monthly_payable_income(),
						1_680_000.0) \
					and str(GameState.current_job.get(
						"display_name_ko", "")) \
						== "한빛유통 물류센터 운영지원 계약직" \
					and str(GameState.current_job.get(
						"display_name_en", "")) \
						== "Hanbit Logistics Operations Support (Contract)",
				"Hanbit acceptance lost its exact job, first pay, or role name")
		else:
			_expect(GameState.current_job.is_empty() \
					and is_zero_approx(float(GameState.monthly_income)),
				"declining Hanbit granted a job or lost its exact receipt")
		_expect(CORE_LOOP.note_story_choice(
				"v2_hanbit_offer_message", choice_index) \
				and (
					GameState.core_loop_v2_state.get(
						"application_transition_receipts", {}) as Dictionary
				).size() == receipt_count,
			"Hanbit result choice %d duplicated its transition receipt"
				% choice_index)

		var saved: Dictionary = GameState.serialize().duplicate(true)
		GameState.start_new_game()
		GameState.load_from_dict(saved)
		CORE_LOOP.initialize_for_run()
		var expected_job_id := "job_03" if choice_index == 0 else ""
		var expected_income := 2_240_000.0 if choice_index == 0 else 0.0
		_expect(CORE_LOOP.application_status(
					"hanbit_ops_2026q1") == "resolved" \
				and str(GameState.current_job.get("id", "")) \
					== expected_job_id \
				and is_equal_approx(
					float(GameState.monthly_income), expected_income) \
				and (
					GameState.core_loop_v2_state.get(
						"application_transition_receipts", {}) as Dictionary
				).size() == receipt_count \
				and str(CORE_LOOP.scheduled_prelude_receipt(
					"m5_city_service_application", 17).get(
						"status", "")) == "consumed" \
				and CORE_LOOP.received_phone_consequence_ids(5) \
					== ["m5_hanbit_offer_message"] \
				and (
					choice_index != 0 or (
						is_equal_approx(
							GameState.get_monthly_payable_income(),
							1_680_000.0)
						and str(GameState.current_job.get(
							"display_name_ko", "")) \
								== "한빛유통 물류센터 운영지원 계약직"
						and str(GameState.current_job.get(
							"display_name_en", "")) \
								== "Hanbit Logistics Operations Support (Contract)"
					)
				),
			"Hanbit result choice %d did not survive save/load"
				% choice_index)
		GameState.turn = 18
		GameState.week_of_month = 2
		_expect(CORE_LOOP.received_phone_consequence_ids() \
				== ["m5_hanbit_offer_message"],
			"Hanbit's received message disappeared after Week 17")

func _check_hanbit_month_five_ledger() -> void:
	_fresh_at(17)
	_mark_completed("m4_hanbit_interview", 14)
	_set_application_status("hanbit_ops_2026q1", "interviewed")
	var schedule := {
		"17": "m5_city_service_application",
		"18": "m5_evening_spreadsheet_class",
		"19": "m5_employment_contract_clinic",
		"20": "m5_last_empty_sunday",
	}
	var commit := CORE_LOOP.commit_plan(
		5, schedule, {
			"primary": "livelihood",
			"secondary": "recovery",
		})
	_expect(bool(commit.get("ok", false)),
		"Hanbit ledger fixture could not commit Month Five")
	if not bool(commit.get("ok", false)):
		return
	# KRW 200,000 is the audited Week-16 endpoint after the Month-3 and
	# Month-4 legal shifts. Week 17 then follows the real MainGame order:
	# routines first, followed by the conditional hiring result.
	GameState.money = 200_000.0
	var week_seventeen := CORE_LOOP.apply_background_routines_for_turn(17)
	_expect(bool(week_seventeen.get("ok", false)) \
			and bool(week_seventeen.get("applied", false)) \
			and is_equal_approx(float(GameState.money), 270_000.0),
		"Week-17 unemployment livelihood did not add KRW 70,000 before hire")
	_expect(CORE_LOOP.begin_bundle(
			"m5_city_service_application", "schedule"),
		"Hanbit ledger could not begin its Week-17 owner")
	var claimed := CORE_LOOP.claim_scheduled_prelude(
		"m5_city_service_application")
	var event: Dictionary = DataRegistry.find_event(
		"v2_hanbit_offer_message")
	var choices: Array = (
		event.get("choices", []) as Array
		if event.get("choices", []) is Array else []
	)
	if choices.size() != 2:
		_expect(false, "Hanbit ledger lost its acceptance choice")
		return
	GameState.apply_choice(event, choices[0])
	_expect(bool(claimed.get("ok", false)) \
			and bool(claimed.get("claimed", false)) \
			and CORE_LOOP.note_story_choice(
				"v2_hanbit_offer_message", 0) \
			and bool(CORE_LOOP.consume_scheduled_prelude(
				"m5_city_service_application").get("ok", false)),
		"Hanbit ledger could not resolve its accepted prelude")
	CORE_LOOP.cancel_active_bundle()

	for week in [18, 19, 20]:
		GameState.turn = week
		var routine := CORE_LOOP.apply_background_routines_for_turn(week)
		_expect(bool(routine.get("ok", false)) \
				and bool(routine.get("applied", false)),
			"employed Month-Five routine failed in Week %d" % week)
	_expect(is_equal_approx(float(GameState.money), 270_000.0),
		"employed livelihood added a duplicate weekly wage")
	_expect(is_equal_approx(
			float(GameState.get_monthly_required_cash()), 650_000.0),
		"Hanbit ledger no longer uses the audited KRW 650,000 fixed cost")
	_expect(is_equal_approx(
			GameState.get_monthly_payable_income(), 1_680_000.0),
		"Hanbit's first paycheck is not the exact three-week proration")
	GameState.apply_monthly_pressure()
	_expect(is_equal_approx(float(GameState.money), 1_300_000.0) \
			and is_equal_approx(
				GameState.get_monthly_payable_income(), 2_240_000.0) \
			and not GameState.current_job.has(
				"pending_first_paycheck_ratio"),
		"the real Month-Five hire order did not prorate once to KRW 1,300,000")

func _check_relationship_outcomes_and_roundtrips() -> void:
	var mapped_by_bundle: Dictionary = {}
	for raw_expected in EXPECTED_RELATIONSHIP_OUTCOMES:
		var expected: Dictionary = raw_expected
		var bundle_id := str(expected.get("bundle", ""))
		var event_id := str(expected.get("event", ""))
		var choice_index := int(expected.get("choice", -1))
		var matching := _relationship_outcomes_for_choice(
			bundle_id, event_id, choice_index)
		_expect(matching.size() == 1,
			"%s choice %d is not mapped exactly once" % [
				bundle_id, choice_index])
		if matching.size() == 1:
			var actual: Dictionary = matching[0]
			for field in [
				"character", "from", "to", "initiative", "memory",
			]:
				_expect(str(actual.get(field, "")) \
						== str(expected.get(field, "")),
					"%s choice %d drifted in %s" % [
						bundle_id, choice_index, field])
			var from_rank := RELATIONSHIP_STAGES.find(
				str(actual.get("from", "")))
			var to_rank := RELATIONSHIP_STAGES.find(
				str(actual.get("to", "")))
			_expect(from_rank >= 0 and to_rank >= 0 \
					and to_rank - from_rank in [0, 1],
				"%s choice %d skips or reverses a relationship stage" % [
					bundle_id, choice_index])
		var key := "%s:%d" % [event_id, choice_index]
		mapped_by_bundle[key] = int(mapped_by_bundle.get(key, 0)) + 1
		_check_relationship_runtime_roundtrip(expected)

	for raw_bundle_id in PERSON_OFFERS:
		var bundle_id := str(raw_bundle_id)
		var roots := CORE_LOOP.resolved_event_roots(bundle_id)
		if roots.size() != 1:
			continue
		var event_id := str(roots[0])
		var event: Dictionary = DataRegistry.find_event(event_id)
		var choices: Array = (
			event.get("choices", []) as Array
			if event.get("choices", []) is Array else []
		)
		_expect(not choices.is_empty(),
			"%s story root has no choices" % bundle_id)
		for choice_index in range(choices.size()):
			var key := "%s:%d" % [event_id, choice_index]
			_expect(int(mapped_by_bundle.get(key, 0)) == 1,
				"%s choice %d is not covered by exactly one D outcome" % [
					bundle_id, choice_index])

func _check_relationship_runtime_roundtrip(expected: Dictionary) -> void:
	var bundle_id := str(expected.get("bundle", ""))
	var event_id := str(expected.get("event", ""))
	var choice_index := int(expected.get("choice", -1))
	var character := str(expected.get("character", ""))
	var from_stage := str(expected.get("from", ""))
	var to_stage := str(expected.get("to", ""))
	var initiative := str(expected.get("initiative", ""))
	var memory := str(expected.get("memory", ""))

	_fresh_at(20)
	_set_relationship_stage(character, from_stage)
	var event: Dictionary = DataRegistry.find_event(event_id)
	var choices: Array = (
		event.get("choices", []) as Array
		if event.get("choices", []) is Array else []
	)
	_expect(choice_index >= 0 and choice_index < choices.size(),
		"%s choice %d is not a real runtime choice" % [
			bundle_id, choice_index])
	_expect(not CORE_LOOP.note_story_choice(event_id, choice_index),
		"%s choice was accepted without its active owner" % bundle_id)
	_expect(CORE_LOOP.begin_bundle(bundle_id, "schedule") \
			and CORE_LOOP.complete_active_bundle().is_empty(),
		"%s completed before its relationship receipt" % bundle_id)
	if choice_index >= 0 and choice_index < choices.size():
		GameState.apply_choice(event, choices[choice_index])
	_expect(CORE_LOOP.note_story_choice(event_id, choice_index),
		"%s choice %d did not create its receipt" % [
			bundle_id, choice_index])
	var receipt := _relationship_receipt(
		bundle_id, event_id, choice_index, 20)
	var receipt_count := (
		GameState.core_loop_v2_state.get(
			"relationship_choice_receipts", {}) as Dictionary
	).size()
	var history_count := (
		GameState.core_loop_v2_state.get(
			"relationship_history", []) as Array
	).size()
	var memory_count := (
		GameState.core_loop_v2_state.get(
			"relationship_memories", []) as Array
	).size()
	_expect(int(receipt.get("turn", 0)) == 20 \
			and str(receipt.get("character", "")) == character \
			and str(receipt.get("from", "")) == from_stage \
			and str(receipt.get("to", "")) == to_stage \
			and str(receipt.get("initiative", "")) == initiative \
			and str(receipt.get("memory", "")) == memory \
			and CORE_LOOP.relationship_stage(character) == to_stage \
			and CORE_LOOP.has_relationship_memory(character, memory),
		"%s choice %d did not apply its exact turn-20 mapping" % [
			bundle_id, choice_index])
	if initiative == "player":
		_expect(CORE_LOOP.was_player_initiated(character),
			"%s choice %d lost player initiative" % [
				bundle_id, choice_index])
	else:
		_expect(not CORE_LOOP.was_player_initiated(character),
			"%s choice %d invented player initiative" % [
				bundle_id, choice_index])
	_expect(CORE_LOOP.note_story_choice(event_id, choice_index) \
			and (
				GameState.core_loop_v2_state.get(
					"relationship_choice_receipts", {}) as Dictionary
			).size() == receipt_count \
			and (
				GameState.core_loop_v2_state.get(
					"relationship_history", []) as Array
			).size() == history_count \
			and (
				GameState.core_loop_v2_state.get(
					"relationship_memories", []) as Array
			).size() == memory_count,
		"%s choice %d replayed its relationship effect" % [
			bundle_id, choice_index])
	_expect(CORE_LOOP.complete_active_bundle() == bundle_id \
			and CORE_LOOP.complete_active_bundle().is_empty(),
		"%s did not complete exactly once after its choice" % bundle_id)

	var saved: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	CORE_LOOP.initialize_for_run()
	var loaded_receipt := _relationship_receipt(
		bundle_id, event_id, choice_index, 20)
	_expect(GameState.turn == 20 \
			and loaded_receipt == receipt \
			and CORE_LOOP.relationship_stage(character) == to_stage \
			and CORE_LOOP.has_relationship_memory(character, memory) \
			and (
				GameState.core_loop_v2_state.get(
					"relationship_choice_receipts", {}) as Dictionary
			).size() == receipt_count \
			and (
				GameState.core_loop_v2_state.get(
					"relationship_history", []) as Array
			).size() == history_count,
		"%s choice %d did not survive save/load exactly once" % [
			bundle_id, choice_index])

func _check_m5_action_roundtrips() -> void:
	for raw_bundle_id in M5_ACTIONS:
		var bundle_id := str(raw_bundle_id)
		var weeks: Array = (
			(M5_ACTIONS[raw_bundle_id] as Dictionary).get("weeks", [])
			as Array
		)
		_check_atomic_action_roundtrip(bundle_id, int(weeks[0]))

func _check_atomic_action_roundtrip(
		bundle_id: String, action_turn: int) -> void:
	_fresh_at(action_turn)
	GameState.money = 2_000_000.0
	GameState.health = 50
	GameState.mental = 50
	GameState.intelligence = 50
	var scene_bundle := CORE_LOOP.bundle(bundle_id)
	var action_id := str(scene_bundle.get("action_id", ""))
	var config: Dictionary = (
		(scene_bundle.get("action_config", {}) as Dictionary).duplicate(true)
		if scene_bundle.get("action_config", {}) is Dictionary else {}
	)
	var execution := str(config.get("execution", ""))
	var effects: Dictionary = (
		(config.get("effects", {}) as Dictionary).duplicate(true)
		if config.get("effects", {}) is Dictionary else {}
	)
	var axis := str(config.get(
		"axis",
		"human" if execution == "rest" else "money"))
	var place_id := str(config.get(
		"place_id",
		"home" if execution == "rest" else "work"))
	var details := {
		"execution": execution,
	}
	if execution == "application":
		details["application_id"] = str(config.get("application_id", ""))
		details["status"] = str(config.get("status", "submitted"))
		var job_id := str(config.get("job_id", "")).strip_edges()
		if not job_id.is_empty():
			details["job_id"] = job_id
	else:
		details["effects"] = effects.duplicate(true)
		if execution == "instant_effect":
			details["axis"] = axis
			details["place_id"] = place_id
		if execution == "rest":
			details["diminished_by_recovery_routine"] = false

	var before_values := _effect_values(effects)
	_expect(CORE_LOOP.begin_bundle(bundle_id, "schedule") \
			and GameState.arm_weekly_commitment({
				"turn": action_turn,
				"pressure_id": bundle_id,
				"pressure_family": "qa_d",
				"choice_id": action_id,
				"forgone_ids": [],
			}),
		"%s atomic fixture could not arm" % bundle_id)
	var transaction := GameState.finalize_weekly_effect_action(
		action_id, effects, axis, place_id, "", details)
	var receipt := CORE_LOOP.action_receipt(bundle_id)
	_expect(bool(transaction.get("ok", false)) \
			and GameState.action_points == 0 \
			and GameState.weekly_commitments.size() == 1 \
			and int(GameState.action_axis_this_week.get(axis, 0)) == 1 \
			and CORE_LOOP.action_result_ready() \
			and str(receipt.get("bundle_id", "")) == bundle_id \
			and str(receipt.get("action_id", "")) == action_id \
			and int(receipt.get("turn", 0)) == action_turn,
		"%s did not atomically finalize AP, axis, commitment, and receipt"
			% bundle_id)
	_expect(_effects_applied_once(before_values, effects),
		"%s did not apply its authored effects exactly once" % bundle_id)
	if execution == "application":
		_expect(CORE_LOOP.application_status(
				str(config.get("application_id", ""))) == "submitted",
			"%s did not store its submitted application" % bundle_id)

	var state_after_first: Dictionary = GameState.serialize().duplicate(true)
	var repeated := GameState.finalize_weekly_effect_action(
		action_id, effects, axis, place_id, "", details)
	_expect(not bool(repeated.get("ok", false)) \
			and GameState.serialize() == state_after_first,
		"%s allowed a second application of its atomic action" % bundle_id)

	var saved: Dictionary = state_after_first.duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	CORE_LOOP.initialize_for_run()
	var loaded_state: Dictionary = GameState.serialize().duplicate(true)
	var recovered := CORE_LOOP.recover_action_result()
	var recovered_again := CORE_LOOP.recover_action_result()
	_expect(not recovered.is_empty() \
			and recovered == recovered_again \
			and GameState.serialize() == loaded_state \
			and CORE_LOOP.action_receipt(bundle_id) == receipt \
			and GameState.weekly_commitments.size() == 1,
		"%s result recovery mutated or duplicated its receipt" % bundle_id)
	_expect(CORE_LOOP.complete_active_bundle() == bundle_id \
			and CORE_LOOP.complete_active_bundle().is_empty() \
			and CORE_LOOP.turn_completed(action_turn) \
			and not CORE_LOOP.action_result_ready(),
		"%s result Continue did not complete exactly once" % bundle_id)

func _check_month_five_declines_once() -> void:
	for raw_bundle_id in BASE_OFFERS:
		_check_decline_once(str(raw_bundle_id), false)
	for raw_bundle_id in PERSON_OFFERS:
		_check_decline_once(str(raw_bundle_id), true)

func _check_decline_once(bundle_id: String, unlock_path: bool) -> void:
	_fresh_at(17)
	if unlock_path:
		_unlock_c_path_for(bundle_id)
	var offers := CORE_LOOP.available_offer_ids(5)
	_expect(offers.has(bundle_id),
		"%s decline fixture could not expose its offer" % bundle_id)
	if not offers.has(bundle_id):
		return
	var selected: Array[String] = []
	for raw_offer_id in offers:
		var offer_id := str(raw_offer_id)
		if offer_id == bundle_id:
			continue
		selected.append(offer_id)
		if selected.size() == 4:
			break
	var schedule := _schedule_for_bundles(
		selected, [17, 18, 19, 20])
	_expect(schedule.size() == 4,
		"%s decline fixture could not schedule the other four offers"
			% bundle_id)
	if schedule.size() != 4:
		return
	var commit := CORE_LOOP.commit_plan(
		5, schedule, _growth_routines())
	_expect(bool(commit.get("ok", false)),
		"%s decline fixture could not commit: %s" % [
			bundle_id, str(commit.get("error", "unknown"))])
	if not bool(commit.get("ok", false)):
		return
	var consequence_id := str(
		CORE_LOOP.bundle(bundle_id).get("decline_consequence", ""))
	var pending := _records_with_id(
		GameState.core_loop_v2_state.get(
			"pending_declines", []) as Array,
		consequence_id)
	_expect(not consequence_id.is_empty() and pending.size() == 1,
		"%s did not queue exactly one Month Six decline" % bundle_id)
	var outcome := CORE_LOOP.decline_outcome(consequence_id)
	var effects: Dictionary = (
		(outcome.get("effects", {}) as Dictionary).duplicate(true)
		if outcome.get("effects", {}) is Dictionary else {}
	)
	var before_values := _effect_values(effects)
	var consumed := CORE_LOOP.process_due_decline_outcomes(5)
	_expect(_records_with_id(consumed, consequence_id).size() == 1 \
			and _records_with_id(
				CORE_LOOP.decline_receipts_for_month(6),
				consequence_id).size() == 1 \
			and _effects_applied_once(before_values, effects),
		"%s decline did not surface once in Month Six" % bundle_id)
	var after_values := _effect_values(effects)

	var saved: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	CORE_LOOP.initialize_for_run()
	var replayed := CORE_LOOP.process_due_decline_outcomes(5)
	_expect(_records_with_id(replayed, consequence_id).is_empty() \
			and _records_with_id(
				CORE_LOOP.decline_receipts_for_month(6),
				consequence_id).size() == 1 \
			and _effect_values(effects) == after_values,
		"%s decline replayed after save/load" % bundle_id)

func _check_c_system_records_once() -> void:
	_fresh_at(13)
	var offers := CORE_LOOP.available_offer_ids(4)
	var target_bundle := "m4_housing_welfare_consultation"
	_expect(offers.size() == 5 and offers.has(target_bundle),
		"C System Records fixture did not expose its sparse fifth offer")
	if not offers.has(target_bundle):
		return
	var selected: Array[String] = []
	for raw_offer_id in offers:
		var offer_id := str(raw_offer_id)
		if offer_id != target_bundle:
			selected.append(offer_id)
	var schedule := _schedule_for_bundles(
		selected, [13, 14, 15, 16])
	_expect(schedule.size() == 4 \
			and bool(CORE_LOOP.commit_plan(
				4, schedule, _growth_routines()).get("ok", false)),
		"C System Records fixture could not commit its four kept offers")
	if schedule.size() != 4:
		return
	var consequence_id := str(
		CORE_LOOP.bundle(target_bundle).get(
			"decline_consequence", ""))
	var first := CORE_LOOP.process_due_decline_outcomes(4)
	_expect(_records_with_id(first, consequence_id).size() == 1 \
			and _records_with_id(
				CORE_LOOP.decline_receipts_for_month(5),
				consequence_id).size() == 1,
		"C missed path did not enter Month Five System Records once")

	var saved: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	CORE_LOOP.initialize_for_run()
	var replayed := CORE_LOOP.process_due_decline_outcomes(4)
	_expect(_records_with_id(replayed, consequence_id).is_empty() \
			and _records_with_id(
				CORE_LOOP.decline_receipts_for_month(5),
				consequence_id).size() == 1,
		"C System Record replayed after save/load")

func _check_week_twenty_terminal_boundary() -> void:
	_check_father_signal_contract()
	_fresh_at(20)
	GameState.money = 2_000_000.0
	GameState.health = 90
	GameState.mental = 90
	var packed := load("res://scenes/MainGame.tscn") as PackedScene
	_expect(packed != null,
		"week-20 terminal QA could not load MainGame")
	if packed == null:
		return
	var main_game = packed.instantiate()
	add_child(main_game)
	await get_tree().process_frame
	await get_tree().process_frame

	GameState.turn = 20
	GameState.month = 5
	GameState.week_of_month = 4
	var state: Dictionary = GameState.core_loop_v2_state
	state["completed_turns"] = range(1, 21)
	state["completed_through_week"] = 16
	state["development_cap_week"] = 20
	state["prototype_complete"] = false
	state["prototype_completed_at_turn"] = 0
	state["completed_at_turn"] = 0
	state["active_bundle"] = ""
	state["active_kind"] = ""
	state["active_turn"] = 0
	GameState.core_loop_v2_state = state

	_game_over_signals = 0
	_captured_boundary_saves.clear()
	var callback := Callable(self, "_capture_terminal_boundary_save")
	if not SaveManager.save_completed.is_connected(callback):
		SaveManager.save_completed.connect(callback)
	main_game._core_loop_v2_advance_completed_week()
	if SaveManager.save_completed.is_connected(callback):
		SaveManager.save_completed.disconnect(callback)
	await get_tree().process_frame

	_expect(_captured_boundary_saves.size() == 1,
		"week-20 rollover wrote an intermediate or duplicate autosave")
	if _captured_boundary_saves.size() == 1:
		var saved_state := _captured_boundary_saves[0]
		var saved_v2: Dictionary = (
			(saved_state.get(
				"core_loop_v2_state", {}) as Dictionary).duplicate(true)
			if saved_state.get(
				"core_loop_v2_state", {}) is Dictionary else {}
		)
		_expect(int(saved_state.get("turn", 0)) == 21 \
				and int(saved_v2.get(
					"completed_through_week", 0)) == 20 \
				and bool(saved_v2.get("prototype_complete", false)) \
				and int(saved_v2.get("completed_at_turn", 0)) == 21 \
				and (saved_v2.get(
					"month_summaries", {}) as Dictionary).has("5"),
			"the week-20 autosave is not one complete turn-21 snapshot")

	_expect(GameState.turn == 21 \
			and CORE_LOOP.is_prototype_complete() \
			and not CORE_LOOP.is_active() \
			and not GameState.is_game_over \
			and _game_over_signals == 0 \
			and not CORE_LOOP.has_completed_bundle(
				"father_health_signal") \
			and not _event_log_has("arc_father_02_signal"),
		"week-20 completion ran an ending, legacy week, or father signal")
	_expect(str(main_game._modal_kind) == "core_loop_v2_complete" \
			and bool(main_game.modal_layer.get_meta(
				"core_loop_v2_completion", false)) \
			and not main_game.modal_close_button.visible,
		"turn 21 did not open the sticky V2 completion record")

	var terminal_turn: int = GameState.turn
	var terminal_events: Array = GameState.event_log.duplicate(true)
	main_game._core_loop_v2_route_week()
	await get_tree().process_frame
	main_game._core_loop_v2_route_week()
	await get_tree().process_frame
	_expect(GameState.turn == terminal_turn \
			and GameState.event_log == terminal_events \
			and str(main_game._modal_kind) == "core_loop_v2_complete" \
			and CORE_LOOP.active_bundle_id().is_empty() \
			and not CORE_LOOP.has_completed_bundle(
				"father_health_signal") \
			and not GameState.is_game_over \
			and _game_over_signals == 0,
		"re-entering the terminal record advanced into legacy or father content")

	_expect(SaveManager.load_game(SaveManager.AUTOSAVE_SLOT) \
			and CORE_LOOP.initialize_for_run() \
			and GameState.turn == 21 \
			and int(GameState.core_loop_v2_state.get(
				"completed_through_week", 0)) == 20 \
			and CORE_LOOP.is_prototype_complete() \
			and not CORE_LOOP.is_active(),
		"durable week-20 completion did not reload at turn 21")
	main_game._core_loop_v2_route_week()
	await get_tree().process_frame
	_expect(str(main_game._modal_kind) == "core_loop_v2_complete" \
			and GameState.turn == 21 \
			and not CORE_LOOP.has_completed_bundle(
				"father_health_signal") \
			and not _event_log_has("arc_father_02_signal") \
			and not GameState.is_game_over \
			and _game_over_signals == 0,
		"loaded terminal state fell through to week 21 or finish_run")

	main_game.free()
	packed = null
	await get_tree().process_frame

func _check_father_signal_contract() -> void:
	var month_five := CORE_LOOP.month_spec(5)
	var month_six := CORE_LOOP.month_spec(6)
	var father := CORE_LOOP.bundle("father_health_signal")
	var month_five_surface: Array = []
	for key in ["prelude", "offers"]:
		var raw_ids: Variant = month_five.get(key, [])
		if raw_ids is Array:
			month_five_surface.append_array(raw_ids as Array)
	for raw_lock in month_five.get("locked", []):
		if raw_lock is Dictionary:
			month_five_surface.append(str(
				(raw_lock as Dictionary).get("bundle", "")))
	var month_six_prelude: Array = (
		(month_six.get("prelude", []) as Array).duplicate()
		if month_six.get("prelude", []) is Array else []
	)
	_expect(not month_five_surface.has("father_health_signal") \
			and month_six_prelude == ["father_health_signal"] \
			and _int_array(father.get("allowed_weeks", [])) == [21] \
			and not bool(father.get("consumes_slot", true)) \
			and CORE_LOOP.resolved_event_roots(
				"father_health_signal") == ["arc_father_02_signal"] \
			and not CORE_LOOP.bundle_allowed_in_week(
				"father_health_signal", 20) \
			and CORE_LOOP.bundle_allowed_in_week(
				"father_health_signal", 21),
		"father health signal is not a non-slot Week 21 Month Six prelude")

func _unlock_c_path_for(bundle_id: String) -> void:
	match bundle_id:
		"daeun_shared_dream":
			_mark_completed("daeun_player_return", 15)
			_set_relationship_stage("daeun", "player_reached_out")
			_set_relationship_memory(
				"daeun", "daeun_returned_using_her_name",
				"daeun_player_return", 15)
			_set_player_initiated("daeun")
		"daeun_third_greeting":
			_mark_completed("daeun_return_after_distance", 15)
			_set_relationship_stage("daeun", "opening")
			_set_relationship_memory(
				"daeun", "daeun_names_exchanged_on_return",
				"daeun_return_after_distance", 15)
			_set_player_initiated("daeun")
		"jiyeon_second_crossing":
			_mark_completed("jiyeon_bus_stop_reunion", 15)
			_set_relationship_stage("jiyeon", "opening")
			_set_relationship_memory(
				"jiyeon", "jiyeon_name_offered_after_silence",
				"jiyeon_bus_stop_reunion", 15)
		"sangchul_second_coffee":
			_mark_completed("sangchul_world_meet", 15)
			_set_relationship_stage("sangchul", "met")
			_set_relationship_memory(
				"sangchul", "sangchul_spoke_of_father",
				"sangchul_world_meet", 15)
			# C is a world encounter. The D phone call itself is the first
			# player-initiated Sangchul action, so no prior initiative is added.
		"jaehyuk_plain_reunion_echo":
			_mark_completed("jaehyuk_world_meet", 15)
			_set_relationship_stage("jaehyuk", "met")
			_set_relationship_memory(
				"jaehyuk", "jaehyuk_message_welcomed",
				"jaehyuk_world_meet", 15)

func _relationship_outcomes_for_choice(
		bundle_id: String, event_id: String,
		choice_index: int) -> Array[Dictionary]:
	var matches: Array[Dictionary] = []
	var raw_outcomes: Variant = CORE_LOOP.bundle(
		bundle_id).get("relationship_outcomes", [])
	if not raw_outcomes is Array:
		return matches
	for raw_outcome in raw_outcomes:
		if not raw_outcome is Dictionary:
			continue
		var outcome: Dictionary = raw_outcome
		if str(outcome.get("event_id", "")) != event_id:
			continue
		var raw_choices: Variant = outcome.get("choices", [])
		if raw_choices is Array:
			for raw_choice in raw_choices:
				if int(raw_choice) == choice_index:
					matches.append(outcome.duplicate(true))
	return matches

func _relationship_receipt(
		bundle_id: String, event_id: String,
		choice_index: int, receipt_turn: int) -> Dictionary:
	var key := "%s:%s:%d:%d" % [
		bundle_id, event_id, choice_index, receipt_turn]
	var raw_receipt: Variant = (
		GameState.core_loop_v2_state.get(
			"relationship_choice_receipts", {}) as Dictionary
	).get(key, {})
	return (raw_receipt as Dictionary).duplicate(true) \
		if raw_receipt is Dictionary else {}

func _schedule_for_bundles(
		bundle_ids: Array, weeks: Array) -> Dictionary:
	var schedule: Dictionary = {}
	if _assign_schedule(bundle_ids, 0, weeks, schedule):
		return schedule
	return {}

func _assign_schedule(
		bundle_ids: Array, bundle_index: int,
		weeks: Array, schedule: Dictionary) -> bool:
	if bundle_index >= bundle_ids.size():
		return true
	var bundle_id := str(bundle_ids[bundle_index])
	for raw_week in weeks:
		var week := int(raw_week)
		var week_key := str(week)
		if schedule.has(week_key) \
				or not CORE_LOOP.bundle_allowed_in_week(bundle_id, week):
			continue
		schedule[week_key] = bundle_id
		if _assign_schedule(
				bundle_ids, bundle_index + 1, weeks, schedule):
			return true
		schedule.erase(week_key)
	return false

func _fresh_at(target_turn: int) -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	GameState.turn = target_turn

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

func _growth_routines() -> Dictionary:
	return {"primary": "growth", "secondary": "livelihood"}

func _records_with_id(records: Array, record_id: String) -> Array:
	var result: Array = []
	for raw_record in records:
		if raw_record is Dictionary \
				and str((raw_record as Dictionary).get(
					"id", "")) == record_id:
			result.append((raw_record as Dictionary).duplicate(true))
	return result

func _event_log_has(event_id: String) -> bool:
	for raw_entry in GameState.event_log:
		if raw_entry is Dictionary \
				and str((raw_entry as Dictionary).get(
					"event_id", "")) == event_id:
			return true
	return false

func _effect_values(effects: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for raw_key in effects:
		var key := str(raw_key)
		match key:
			"money":
				result[key] = float(GameState.money)
			"monthly_income":
				result[key] = float(GameState.monthly_income)
			"health", "mental", "intelligence", "social_skill", \
			"appearance", "investment_skill", "luck", "work_performance":
				result[key] = int(GameState.get(key))
	return result

func _effects_applied_once(
		before_values: Dictionary, effects: Dictionary) -> bool:
	for raw_key in before_values:
		var key := str(raw_key)
		var before: Variant = before_values[key]
		var delta: Variant = effects.get(key, 0)
		match key:
			"money":
				if not is_equal_approx(
						float(GameState.money),
						float(before) + float(delta)):
					return false
			"monthly_income":
				if not is_equal_approx(
						float(GameState.monthly_income),
						float(before) + float(delta)):
					return false
			"health", "mental", "intelligence", "social_skill", \
			"appearance", "investment_skill", "luck", "work_performance":
				if int(GameState.get(key)) \
						!= clampi(int(before) + int(delta), 0, 100):
					return false
	return true

func _same_string_set(left: Array, right: Array) -> bool:
	if left.size() != right.size():
		return false
	var left_strings: Array[String] = []
	var right_strings: Array[String] = []
	for raw_value in left:
		left_strings.append(str(raw_value))
	for raw_value in right:
		right_strings.append(str(raw_value))
	left_strings.sort()
	right_strings.sort()
	return left_strings == right_strings

func _string_intersection(left: Array, right: Array) -> Array[String]:
	var result: Array[String] = []
	for raw_value in left:
		var value := str(raw_value)
		if right.has(value) and not result.has(value):
			result.append(value)
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

func _capture_terminal_boundary_save(
		success: bool, slot: int) -> void:
	if success and slot == SaveManager.AUTOSAVE_SLOT:
		_captured_boundary_saves.append(
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
		if file != null:
			file.store_buffer(
				_autosave_backup.get("bytes", PackedByteArray()))
			file.close()
	elif FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	_autosave_backup.clear()

func _exit_tree() -> void:
	_restore_autosave()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
