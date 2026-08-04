extends Node
## ORDER-57 C: weeks 13–16 causality, relationship pursuit, and terminal gates.

const CORE_LOOP := preload("res://systems/DemoCoreLoopV2.gd")

const C_ACTIONS := {
	"m4_dodam_application": "apply",
	"m4_certificate_session": "study",
	"m4_logistics_shift": "side_shift",
	"m4_health_check_day": "rest",
	"m4_housing_welfare_consultation": "study",
}

const C_STORY_ROOTS := {
	"m4_hanbit_interview": ["v2_hanbit_interview"],
	"daeun_player_return": ["v2_daeun_return_named"],
	"daeun_return_after_distance": ["v2_daeun_return_after_distance"],
	"jiyeon_bus_stop_reunion": ["arc_jiyeon_02_store"],
	"sangchul_world_meet": ["v2_sangchul_housing_lead"],
	"jaehyuk_world_meet": ["v2_jaehyuk_message"],
}

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

func _ready() -> void:
	_backup_autosave()
	var original_sfx_enabled := AudioManager.sfx_enabled
	AudioManager.sfx_enabled = false
	var action_callback := Callable(self, "_capture_v2_action_receipt")
	if not GameState.weekly_commitment_finalized.is_connected(action_callback):
		GameState.weekly_commitment_finalized.connect(action_callback)

	_check_contract_and_twelve_week_resume()
	_check_month_four_offer_matrix()
	_check_hanbit_visibility_and_deadline()
	_check_hanbit_application_choices()
	_check_hanbit_decline_transition()
	_check_daeun_paths_and_choices()
	_check_jiyeon_choices()
	_check_one_relationship_step_per_month()
	_check_money_entry_prerequisites_and_exclusivity()
	_check_story_entry_roots_and_terminal_outcomes()
	_check_c_action_contracts_and_roundtrips()
	await _check_sixteen_week_continuation_boundary()

	AudioManager.sfx_enabled = original_sfx_enabled
	_restore_autosave()
	if _failures.is_empty():
		print(
			"CORE_LOOP_V2_C_CHECK_OK schema=3 cap=24 migration=12_to_24 "
			+ "offers=sparse5_rich7 hanbit=week14/submitted/interviewed/decline_once "
			+ "daeun=two_paths/two_choices/player_once "
			+ "jiyeon=reciprocal_or_player/opening "
			+ "relationship=one_stage_per_month/exact_stage "
			+ "money_entries=distinct_prerequisites/mutual_exclusion "
			+ "events=entry_roots/terminal_outcomes "
			+ "actions=apply_study_shift_recovery/atomic/save_once/story_bridge "
			+ "continuation=week16_to_17/month5_planner/no_legacy_fallback")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("CORE_LOOP_V2_C_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)

func _check_contract_and_twelve_week_resume() -> void:
	var contract := CORE_LOOP.contract()
	var raw_scope: Variant = contract.get("scope", {})
	var scope: Dictionary = (
		raw_scope as Dictionary if raw_scope is Dictionary else {}
	)
	var raw_prototype_weeks: Variant = scope.get("prototype_weeks", [])
	_expect(int(contract.get("schema_version", 0)) == 3,
		"C runtime contract is not schema 3")
	_expect(CORE_LOOP.development_cap_week() == 24 \
			and int(scope.get("development_cap_week", 0)) == 24,
		"C regression did not inherit the week-24 development cap")
	_expect(raw_prototype_weeks is Array \
			and (raw_prototype_weeks as Array).size() == 2 \
			and int((raw_prototype_weeks as Array)[0]) == 1 \
			and int((raw_prototype_weeks as Array)[1]) == 24,
		"C prototype window is not exactly weeks 1–24")
	_expect(not bool(contract.get("runtime_default", true)),
		"C enabled the unfinished V2 loop by default")

	GameState.start_new_game()
	GameState.turn = 13
	GameState.core_loop_v2_state = {
		"schema": 3,
		"enabled": true,
		"development_cap_week": 12,
		"prototype_complete": true,
		"prototype_completed_at_turn": 13,
		"completed_at_turn": 13,
		"completed_through_week": 12,
		"completed_turns": range(1, 13),
		"completed_bundles": [
			"m3_hanbit_application",
			"daeun_world_meet",
		],
		"completed_bundle_turns": {
			"m3_hanbit_application": 9,
			"daeun_world_meet": 11,
		},
		"plans": {
			"3": {
				"schedule": {
					"9": "m3_hanbit_application",
					"10": "m3_inventory_shift",
					"11": "daeun_world_meet",
					"12": "father_quiet_call",
				},
				"selected": [
					"m3_hanbit_application",
					"m3_inventory_shift",
					"daeun_world_meet",
					"father_quiet_call",
				],
				"routines": _growth_routines(),
				"forgone": [],
				"planned_turn": 9,
			},
		},
		"month_summaries": {
			"3": {
				"month": 3,
				"after": {"money": 50_000.0},
				"acknowledged": true,
			},
		},
		"application_statuses": {
			"hanbit_ops_2026q1": "submitted",
		},
		"relationship_stages": {"daeun": "opening"},
		"relationship_memories": [{
			"character": "daeun",
			"memory": "daeun_name_exchanged",
			"bundle_id": "daeun_world_meet",
			"turn": 11,
		}],
		"pending_declines": [{
			"id": "qa_preserved_decline",
			"producer_bundle": "qa",
			"month": 3,
			"visible_month": 5,
			"consumer_kind": "next_month_message",
		}],
	}
	_expect(CORE_LOOP.initialize_for_run(),
		"schema-3 week-12 terminal save did not initialize")
	var migrated: Dictionary = GameState.core_loop_v2_state
	_expect(int(migrated.get("schema", 0)) == 3 \
			and int(migrated.get("development_cap_week", 0)) == 24 \
			and int(migrated.get("completed_through_week", 0)) == 12 \
			and not bool(migrated.get("prototype_complete", true)),
		"week-12 completion did not reopen under the week-24 cap")
	_expect(CORE_LOOP.is_active() \
			and not CORE_LOOP.is_prototype_complete() \
			and CORE_LOOP.needs_plan(4),
		"migrated week-12 save did not resume at the Month Four planner")
	_expect(CORE_LOOP.application_status(
			"hanbit_ops_2026q1") == "submitted" \
			and CORE_LOOP.relationship_stage("daeun") == "opening" \
			and CORE_LOOP.has_relationship_memory(
				"daeun", "daeun_name_exchanged") \
			and (migrated.get("pending_declines", []) as Array).size() == 1,
		"week-12 migration lost application, relationship, or decline receipts")
	# An old completion timestamp is harmless historical evidence. The active
	# decision is completed-through versus the current development cap.
	_expect(int(migrated.get("completed_at_turn", 0)) == 13,
		"week-12 migration erased its historical completion timestamp")

	var saved: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	CORE_LOOP.initialize_for_run()
	_expect(GameState.turn == 13 \
			and CORE_LOOP.is_active() \
			and not CORE_LOOP.is_prototype_complete() \
			and int(GameState.core_loop_v2_state.get(
				"completed_through_week", 0)) == 12 \
			and CORE_LOOP.application_status(
				"hanbit_ops_2026q1") == "submitted",
		"week-13 C resume did not survive save/load")

func _check_month_four_offer_matrix() -> void:
	_fresh_at(13)
	var sparse: Array[String] = CORE_LOOP.available_offer_ids(4)
	_expect(sparse.size() == 5,
		"sparse Month Four did not expose exactly five offers: %s" % [
			str(sparse)])
	for bundle_id in C_ACTIONS:
		_expect(sparse.has(str(bundle_id)),
			"sparse Month Four lost action or fallback %s" % str(bundle_id))
	for gated_id in [
		"m4_hanbit_interview",
		"daeun_player_return",
		"daeun_return_after_distance",
		"jiyeon_bus_stop_reunion",
		"sangchul_world_meet",
		"jaehyuk_world_meet",
	]:
		_expect(not sparse.has(gated_id),
			"%s appeared without its authored C producer" % gated_id)

	var sangchul_producer := _completed_bundle_prerequisite_id(
		"sangchul_world_meet")
	var jaehyuk_producer := _completed_bundle_prerequisite_id(
		"jaehyuk_world_meet")
	_expect(not sangchul_producer.is_empty() \
			and not jaehyuk_producer.is_empty() \
			and sangchul_producer != jaehyuk_producer,
		"Sangchul and Jaehyuk do not have distinct prior-route producers")

	_fresh_at(13)
	_unlock_daeun_named_path()
	if not sangchul_producer.is_empty():
		_mark_completed(sangchul_producer, 7)
	if not jaehyuk_producer.is_empty():
		_mark_completed(jaehyuk_producer, 8)
	var rich: Array[String] = CORE_LOOP.available_offer_ids(4)
	var required_rich: Array[String] = [
		"m4_dodam_application",
		"m4_certificate_session",
		"m4_logistics_shift",
		"m4_health_check_day",
		"daeun_player_return",
		"sangchul_world_meet",
		"jaehyuk_world_meet",
	]
	_expect(rich.size() == 7,
		"rich Month Four did not expose exactly seven offers: %s" % [
			str(rich)])
	for bundle_id in required_rich:
		_expect(rich.has(bundle_id),
			"rich Month Four lost expected offer %s" % bundle_id)
	_expect(not rich.has("daeun_return_after_distance") \
			and not rich.has("jiyeon_bus_stop_reunion") \
			and not rich.has("m4_hanbit_interview") \
			and not rich.has("m4_housing_welfare_consultation"),
		"rich valid fixture exposed a mutually impossible relationship "
		+ "or unnecessary fallback")

	_fresh_at(13)
	_mark_completed("jiyeon_world_meet", 11)
	_set_relationship_stage("jiyeon", "met")
	_set_relationship_memory(
		"jiyeon", "jiyeon_repair_cost_taken",
		"jiyeon_world_meet", 11)
	var jiyeon_path: Array[String] = CORE_LOOP.available_offer_ids(4)
	_expect(jiyeon_path.has("jiyeon_bus_stop_reunion") \
			and not jiyeon_path.has("daeun_player_return") \
			and not jiyeon_path.has("daeun_return_after_distance"),
		"Jiyeon's actual B meeting did not open only her C reunion path")

func _check_hanbit_visibility_and_deadline() -> void:
	var interview_copy := CORE_LOOP.bundle("m4_hanbit_interview")
	_expect(str(interview_copy.get("decline_ko", "")).find("참석") >= 0 \
			and str(interview_copy.get("decline_ko", "")).find("잡지") < 0 \
			and str(interview_copy.get("decline_en", "")).find(
				"attended") >= 0 \
			and str(interview_copy.get("decline_en", "")).find(
				"scheduled") >= 0,
		"Hanbit decline copy contradicted its already scheduled interview")
	_fresh_at(14)
	_expect(not CORE_LOOP.available_offer_ids(4).has(
			"m4_hanbit_interview"),
		"Hanbit interview appeared without an application")

	_fresh_at(14)
	_set_application_status("hanbit_ops_2026q1", "submitted")
	_expect(not CORE_LOOP.available_offer_ids(4).has(
			"m4_hanbit_interview"),
		"Hanbit status without the actual producer opened an interview")

	_fresh_at(14)
	_mark_completed("m3_hanbit_application", 9)
	_set_application_status("hanbit_ops_2026q1", "")
	_expect(not CORE_LOOP.available_offer_ids(4).has(
			"m4_hanbit_interview"),
		"Hanbit producer without submitted status opened an interview")

	_fresh_at(14)
	_unlock_hanbit_interview()
	var submitted: Array[String] = CORE_LOOP.available_offer_ids(4)
	_expect(submitted.has("m4_hanbit_interview") \
			and not submitted.has("m4_dodam_application"),
		"submitted Hanbit application did not replace the competing "
		+ "Week 13 application with its interview")
	for week in [13, 15, 16]:
		_expect(not CORE_LOOP.bundle_allowed_in_week(
				"m4_hanbit_interview", week),
			"Hanbit interview escaped its Week 14 appointment")
	_expect(CORE_LOOP.bundle_allowed_in_week(
			"m4_hanbit_interview", 14),
		"Hanbit interview is not schedulable in Week 14")

	var wrong_week := CORE_LOOP.validate_plan(4, {
		"13": "m4_hanbit_interview",
		"14": "m4_certificate_session",
		"15": "m4_logistics_shift",
		"16": "m4_health_check_day",
	}, _growth_routines())
	_expect(not bool(wrong_week.get("ok", false)) \
			and str(wrong_week.get("error", "")) == "deadline_missed" \
			and str(wrong_week.get("bundle", "")) \
				== "m4_hanbit_interview",
		"Month Four accepted the Hanbit interview outside Week 14")
	var legal_week := CORE_LOOP.validate_plan(4, {
		"13": "m4_certificate_session",
		"14": "m4_hanbit_interview",
		"15": "m4_logistics_shift",
		"16": "m4_health_check_day",
	}, _growth_routines())
	_expect(bool(legal_week.get("ok", false)),
		"Month Four rejected a legal Week 14 Hanbit interview plan")

	_set_application_status("hanbit_ops_2026q1", "interviewed")
	_expect(not CORE_LOOP.available_offer_ids(4).has(
			"m4_hanbit_interview"),
		"an already interviewed application reopened the Hanbit interview")

func _check_hanbit_application_choices() -> void:
	var interview := CORE_LOOP.bundle("m4_hanbit_interview")
	var outcomes: Variant = interview.get("application_outcomes", [])
	_expect(outcomes is Array and (outcomes as Array).size() == 1,
		"Hanbit interview does not own one application transition contract")
	if not outcomes is Array or (outcomes as Array).is_empty():
		return
	var outcome: Dictionary = (
		(outcomes as Array)[0] as Dictionary
		if (outcomes as Array)[0] is Dictionary else {}
	)
	var outcome_choices: Array = (
		outcome.get("choices", []) as Array
		if outcome.get("choices", []) is Array else []
	)
	_expect(str(outcome.get("event_id", "")) == "v2_hanbit_interview" \
			and str(outcome.get("application_id", "")) \
				== "hanbit_ops_2026q1" \
			and str(outcome.get("from", "")) == "submitted" \
			and str(outcome.get("to", "")) == "interviewed" \
			and outcome_choices.size() == 2 \
			and int(outcome_choices[0]) == 0 \
			and int(outcome_choices[1]) == 1,
		"Hanbit interview choices drifted from submitted→interviewed")
	for raw_choice in outcome_choices:
		_check_hanbit_application_choice(int(raw_choice))

func _check_hanbit_application_choice(choice_index: int) -> void:
	_fresh_at(14)
	_unlock_hanbit_interview()
	_expect(CORE_LOOP.available_offer_ids(4).has(
			"m4_hanbit_interview"),
		"Hanbit choice fixture was not causally available")
	_expect(not CORE_LOOP.note_story_choice(
			"v2_hanbit_interview", choice_index),
		"Hanbit choice was accepted without an active owner")
	_expect(CORE_LOOP.begin_bundle(
			"m4_hanbit_interview", "schedule"),
		"Hanbit interview could not begin in Week 14")
	_expect(CORE_LOOP.complete_active_bundle().is_empty(),
		"Hanbit interview completed before its visible choice")
	var income_before := float(GameState.monthly_income)
	var job_before: Dictionary = GameState.current_job.duplicate(true)
	var event: Dictionary = DataRegistry.find_event(
		"v2_hanbit_interview")
	var choices: Array = (
		event.get("choices", []) as Array
		if event.get("choices", []) is Array else []
	)
	if choice_index >= 0 and choice_index < choices.size():
		GameState.apply_choice(event, choices[choice_index])
	_expect(CORE_LOOP.note_story_choice(
			"v2_hanbit_interview", choice_index),
		"Hanbit choice %d did not produce a transition receipt" \
			% choice_index)
	var receipts: Dictionary = GameState.core_loop_v2_state.get(
		"application_transition_receipts", {})
	var receipt_count := receipts.size()
	_expect(receipt_count == 1 \
			and CORE_LOOP.application_status(
				"hanbit_ops_2026q1") == "interviewed",
		"Hanbit choice %d did not transition submitted→interviewed" \
			% choice_index)
	_expect(CORE_LOOP.note_story_choice(
			"v2_hanbit_interview", choice_index) \
			and (
				GameState.core_loop_v2_state.get(
					"application_transition_receipts", {}) as Dictionary
			).size() == receipt_count,
		"Hanbit choice %d created a duplicate transition receipt" \
			% choice_index)
	_expect(GameState.current_job == job_before \
			and is_equal_approx(
				float(GameState.monthly_income), income_before),
		"Hanbit interview choice hired the player or changed income")
	_expect(CORE_LOOP.complete_active_bundle() \
			== "m4_hanbit_interview" \
			and CORE_LOOP.complete_active_bundle().is_empty(),
		"Hanbit interview did not complete exactly once")

	var saved: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	CORE_LOOP.initialize_for_run()
	_expect(CORE_LOOP.application_status(
			"hanbit_ops_2026q1") == "interviewed" \
			and (
				GameState.core_loop_v2_state.get(
					"application_transition_receipts", {}) as Dictionary
			).size() == receipt_count \
			and GameState.current_job == job_before \
			and is_equal_approx(
				float(GameState.monthly_income), income_before),
		"Hanbit interview transition did not survive save/load exactly once")

func _check_hanbit_decline_transition() -> void:
	_fresh_at(13)
	_unlock_hanbit_interview()
	_unlock_daeun_named_path()
	var schedule := {
		"13": "m4_logistics_shift",
		"14": "m4_health_check_day",
		"15": "m4_certificate_session",
		"16": "daeun_player_return",
	}
	var committed := CORE_LOOP.commit_plan(
		4, schedule, _growth_routines())
	_expect(bool(committed.get("ok", false)),
		"Hanbit decline fixture could not commit a legal Month Four plan")
	if not bool(committed.get("ok", false)):
		return
	var pending: Array = GameState.core_loop_v2_state.get(
		"pending_declines", [])
	_expect(_records_with_id(
			pending, "hanbit_interview_not_attended").size() == 1,
		"unchosen Hanbit interview did not create one decline consumer")

	GameState.turn = 17
	var consumed := CORE_LOOP.process_due_decline_outcomes(4)
	var transition_receipts: Dictionary = (
		GameState.core_loop_v2_state.get(
			"application_transition_receipts", {}) as Dictionary
	)
	_expect(_records_with_id(
			consumed, "hanbit_interview_not_attended").size() == 1 \
			and CORE_LOOP.application_status(
				"hanbit_ops_2026q1") == "not_attended" \
			and transition_receipts.size() == 1,
		"Hanbit interview decline did not transition "
		+ "submitted→not_attended exactly once")
	_expect(CORE_LOOP.process_due_decline_outcomes(4).is_empty() \
			and (
				GameState.core_loop_v2_state.get(
					"application_transition_receipts", {}) as Dictionary
			).size() == 1,
		"Hanbit interview decline was consumed more than once")

	var saved: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	CORE_LOOP.initialize_for_run()
	_expect(CORE_LOOP.application_status(
			"hanbit_ops_2026q1") == "not_attended" \
			and _records_with_id(
				CORE_LOOP.decline_receipts_for_month(5),
				"hanbit_interview_not_attended").size() == 1 \
			and CORE_LOOP.process_due_decline_outcomes(4).is_empty() \
			and (
				GameState.core_loop_v2_state.get(
					"application_transition_receipts", {}) as Dictionary
			).size() == 1,
		"Hanbit decline transition or receipt replayed after save/load")

func _check_daeun_paths_and_choices() -> void:
	_fresh_at(15)
	_unlock_daeun_named_path()
	var named_path: Array[String] = CORE_LOOP.available_offer_ids(4)
	_expect(named_path.has("daeun_player_return") \
			and not named_path.has("daeun_return_after_distance"),
		"Daeun's name-exchange path did not expose only its authored return")

	_fresh_at(15)
	_unlock_daeun_distance_path()
	var distance_path: Array[String] = CORE_LOOP.available_offer_ids(4)
	_expect(distance_path.has("daeun_return_after_distance") \
			and not distance_path.has("daeun_player_return"),
		"Daeun's guarded B path did not expose only its authored return")

	_check_relationship_mapping(
		"daeun_player_return", "v2_daeun_return_named", 0,
		"daeun", "opening", "player_reached_out", "player",
		"daeun_returned_using_her_name", 15)
	_check_relationship_mapping(
		"daeun_player_return", "v2_daeun_return_named", 1,
		"daeun", "opening", "player_reached_out", "player",
		"daeun_returned_to_thank_her", 15)
	_check_relationship_mapping(
		"daeun_return_after_distance",
		"v2_daeun_return_after_distance", 0,
		"daeun", "met", "opening", "player",
		"daeun_names_exchanged_on_return", 15)
	_check_relationship_mapping(
		"daeun_return_after_distance",
		"v2_daeun_return_after_distance", 1,
		"daeun", "met", "opening", "player",
		"daeun_thanks_reopened_conversation", 15)

func _check_jiyeon_choices() -> void:
	_check_relationship_mapping(
		"jiyeon_bus_stop_reunion", "arc_jiyeon_02_store", 0,
		"jiyeon", "met", "opening", "reciprocal",
		"jiyeon_name_offered_after_silence", 15)
	_check_relationship_mapping(
		"jiyeon_bus_stop_reunion", "arc_jiyeon_02_store", 1,
		"jiyeon", "met", "opening", "player",
		"jiyeon_name_exchanged_after_player_spoke", 15)

func _check_one_relationship_step_per_month() -> void:
	_fresh_at(15)
	_unlock_daeun_distance_path()
	_expect(CORE_LOOP.begin_bundle(
			"daeun_return_after_distance", "schedule") \
			and CORE_LOOP.note_story_choice(
				"v2_daeun_return_after_distance", 0) \
			and CORE_LOOP.complete_active_bundle() \
				== "daeun_return_after_distance" \
			and CORE_LOOP.relationship_stage("daeun") == "opening",
		"Daeun one-step fixture could not complete its first C transition")
	var history_before := (
		GameState.core_loop_v2_state.get(
			"relationship_history", []) as Array
	).size()
	_set_relationship_memory(
		"daeun", "daeun_name_exchanged",
		"daeun_world_meet", 11)
	GameState.turn = 16
	_expect(CORE_LOOP._bundle_requirement_met(
			CORE_LOOP.bundle("daeun_player_return")) \
			and not CORE_LOOP._bundle_requirement_met(
				CORE_LOOP.bundle("daeun_return_after_distance")),
		"exact relationship-stage predicates did not switch Daeun's "
		+ "eligible variant at opening")
	_expect(CORE_LOOP.begin_bundle(
			"daeun_player_return", "schedule"),
		"Daeun second-step guard fixture could not begin its owner")
	_expect(not CORE_LOOP.note_story_choice(
			"v2_daeun_return_named", 0) \
			and CORE_LOOP.relationship_stage("daeun") == "opening" \
			and (
				GameState.core_loop_v2_state.get(
					"relationship_history", []) as Array
			).size() == history_before,
		"Daeun advanced twice during Month Four")
	CORE_LOOP.cancel_active_bundle()

	_set_relationship_stage("daeun", "player_reached_out")
	_expect(not CORE_LOOP._bundle_requirement_met({
			"prerequisites": {"all": [{
				"kind": "relationship_stage_is",
				"character": "daeun",
				"stage": "opening",
			}]},
		}), "relationship_stage_is accepted a later stage")

func _check_money_entry_prerequisites_and_exclusivity() -> void:
	var sangchul_producer := _completed_bundle_prerequisite_id(
		"sangchul_world_meet")
	var jaehyuk_producer := _completed_bundle_prerequisite_id(
		"jaehyuk_world_meet")
	_expect(not sangchul_producer.is_empty() \
			and not jaehyuk_producer.is_empty() \
			and sangchul_producer != jaehyuk_producer,
		"money entries do not require two distinct prior routes")

	_fresh_at(13)
	var base: Array[String] = CORE_LOOP.available_offer_ids(4)
	_expect(not base.has("sangchul_world_meet") \
			and not base.has("jaehyuk_world_meet"),
		"money entries appeared without their prior routes")

	if not sangchul_producer.is_empty():
		_mark_completed(sangchul_producer, 7)
	var sangchul_only: Array[String] = CORE_LOOP.available_offer_ids(4)
	_expect(sangchul_only.has("sangchul_world_meet") \
			and not sangchul_only.has("jaehyuk_world_meet"),
		"Sangchul's route did not open only Sangchul")

	_fresh_at(13)
	if not jaehyuk_producer.is_empty():
		_mark_completed(jaehyuk_producer, 8)
	var jaehyuk_only: Array[String] = CORE_LOOP.available_offer_ids(4)
	_expect(jaehyuk_only.has("jaehyuk_world_meet") \
			and not jaehyuk_only.has("sangchul_world_meet"),
		"Jaehyuk's route did not open only Jaehyuk")

	_fresh_at(13)
	if not sangchul_producer.is_empty():
		_mark_completed(sangchul_producer, 7)
	if not jaehyuk_producer.is_empty():
		_mark_completed(jaehyuk_producer, 8)
	var both_visible: Array[String] = CORE_LOOP.available_offer_ids(4)
	_expect(both_visible.has("sangchul_world_meet") \
			and both_visible.has("jaehyuk_world_meet"),
		"two valid prior routes did not expose both money-entry choices")
	var schedule := _schedule_for_bundles([
		"sangchul_world_meet",
		"jaehyuk_world_meet",
		"m4_certificate_session",
		"m4_health_check_day",
	], [13, 14, 15, 16])
	_expect(schedule.size() == 4,
		"money-entry exclusivity fixture could not assign legal weeks")
	if schedule.size() == 4:
		var exclusive := CORE_LOOP.validate_plan(
			4, schedule, _growth_routines())
		_expect(not bool(exclusive.get("ok", false)) \
				and str(exclusive.get("error", "")) == "exclusive_group" \
				and str(exclusive.get("group", "")) \
					== "money_mentor_entry",
			"Month Four allowed both Sangchul and Jaehyuk in one plan")

	_check_relationship_mapping(
		"sangchul_world_meet", "arc_sangchul_01_answer", 0,
		"sangchul", "unmet", "met", "world",
		"sangchul_spoke_of_father", 13)
	_check_relationship_mapping(
		"sangchul_world_meet", "arc_sangchul_01_answer", 1,
		"sangchul", "unmet", "met", "world",
		"sangchul_kept_goal_plain", 13)
	_check_relationship_mapping(
		"sangchul_world_meet", "arc_sangchul_01_answer", 2,
		"sangchul", "unmet", "met", "world",
		"sangchul_named_city_pride", 13)
	_check_relationship_mapping(
		"jaehyuk_world_meet", "v2_jaehyuk_message", 0,
		"jaehyuk", "unmet", "met", "reciprocal",
		"jaehyuk_message_welcomed", 13)
	_check_relationship_mapping(
		"jaehyuk_world_meet", "v2_jaehyuk_message", 1,
		"jaehyuk", "unmet", "met", "reciprocal",
		"jaehyuk_message_guarded", 13)

func _check_story_entry_roots_and_terminal_outcomes() -> void:
	for raw_bundle_id in C_STORY_ROOTS:
		var bundle_id := str(raw_bundle_id)
		var outcome_field := (
			"application_outcomes"
			if bundle_id == "m4_hanbit_interview"
			else "relationship_outcomes"
		)
		_check_story_bundle_graph(
			bundle_id,
			C_STORY_ROOTS[raw_bundle_id] as Array,
			outcome_field)

func _check_story_bundle_graph(
		bundle_id: String, expected_roots: Array,
		outcome_field: String) -> void:
	var roots: Array = CORE_LOOP.resolved_event_roots(bundle_id)
	_expect(roots == expected_roots and roots.size() == 1,
		"%s does not expose only its authored entry root: %s" % [
			bundle_id, str(roots)])
	if roots.is_empty():
		return
	var graph := _event_graph(roots)
	var reachable: Dictionary = graph.get("reachable", {})
	var terminal_keys: Array = graph.get("terminal_keys", [])
	var follow_up_targets: Dictionary = graph.get("follow_up_targets", {})
	_expect(not terminal_keys.is_empty(),
		"%s has no reachable terminal choice" % bundle_id)
	for raw_root in roots:
		_expect(not follow_up_targets.has(str(raw_root)),
			"%s lists a downstream or cyclic event as an entry root" \
				% bundle_id)

	var raw_outcomes: Variant = CORE_LOOP.bundle(
		bundle_id).get(outcome_field, [])
	_expect(raw_outcomes is Array \
			and not (raw_outcomes as Array).is_empty(),
		"%s has no %s" % [bundle_id, outcome_field])
	if not raw_outcomes is Array:
		return
	var mapped_counts: Dictionary = {}
	for raw_outcome in raw_outcomes:
		if not raw_outcome is Dictionary:
			_expect(false,
				"%s has a malformed outcome row" % bundle_id)
			continue
		var outcome: Dictionary = raw_outcome
		var event_id := str(outcome.get("event_id", "")).strip_edges()
		_expect(reachable.has(event_id),
			"%s maps an outcome event unreachable from its entry root: %s" % [
				bundle_id, event_id])
		var event: Dictionary = DataRegistry.find_event(event_id)
		var choices: Array = (
			event.get("choices", []) as Array
			if event.get("choices", []) is Array else []
		)
		var raw_choices: Variant = outcome.get("choices", [])
		_expect(raw_choices is Array \
				and not (raw_choices as Array).is_empty(),
			"%s has an outcome without terminal choice indexes" % bundle_id)
		if not raw_choices is Array:
			continue
		for raw_choice_index in raw_choices:
			var choice_index := int(raw_choice_index)
			var key := "%s:%d" % [event_id, choice_index]
			_expect(choice_index >= 0 and choice_index < choices.size(),
				"%s maps missing choice %s" % [bundle_id, key])
			mapped_counts[key] = int(mapped_counts.get(key, 0)) + 1
	for raw_terminal_key in terminal_keys:
		var terminal_key := str(raw_terminal_key)
		_expect(int(mapped_counts.get(terminal_key, 0)) == 1,
			"%s terminal choice %s is not owned by exactly one outcome" % [
				bundle_id, terminal_key])

func _event_graph(entry_roots: Array) -> Dictionary:
	var reachable: Dictionary = {}
	var follow_up_targets: Dictionary = {}
	var terminal_keys: Array[String] = []
	var queue: Array = entry_roots.duplicate()
	var safety := 0
	while not queue.is_empty() and safety < 96:
		safety += 1
		var event_id := str(queue.pop_front()).strip_edges()
		if event_id.is_empty() or reachable.has(event_id):
			continue
		var event: Dictionary = DataRegistry.find_event(event_id)
		_expect(not event.is_empty(),
			"event graph could not load %s" % event_id)
		if event.is_empty():
			continue
		reachable[event_id] = true
		var raw_choices: Variant = event.get("choices", [])
		_expect(raw_choices is Array \
				and not (raw_choices as Array).is_empty(),
			"story event %s has no choices" % event_id)
		if not raw_choices is Array:
			continue
		for choice_index in range((raw_choices as Array).size()):
			var raw_choice: Variant = (raw_choices as Array)[choice_index]
			if not raw_choice is Dictionary:
				_expect(false,
					"story event %s has a malformed choice" % event_id)
				continue
			var follow_up := str(
				(raw_choice as Dictionary).get(
					"follow_up_event", "")).strip_edges()
			if follow_up.is_empty():
				terminal_keys.append("%s:%d" % [
					event_id, choice_index])
			else:
				follow_up_targets[follow_up] = true
				queue.append(follow_up)
	_expect(safety < 96,
		"event graph exceeded its cycle guard")
	terminal_keys.sort()
	return {
		"reachable": reachable,
		"follow_up_targets": follow_up_targets,
		"terminal_keys": terminal_keys,
	}

func _check_c_action_contracts_and_roundtrips() -> void:
	var result_titles: Dictionary = {}
	var result_bodies: Dictionary = {}
	for raw_bundle_id in C_ACTIONS:
		var bundle_id := str(raw_bundle_id)
		var scene_bundle := CORE_LOOP.bundle(bundle_id)
		var expected_story_owned := (
			bundle_id == "m4_housing_welfare_consultation")
		var config: Dictionary = (
			(scene_bundle.get("action_config", {}) as Dictionary)
				.duplicate(true)
			if scene_bundle.get("action_config", {}) is Dictionary else {}
		)
		var raw_allowed: Variant = scene_bundle.get("allowed_weeks", [])
		_expect(str(scene_bundle.get("action_id", "")) \
				== str(C_ACTIONS[raw_bundle_id]),
			"%s has the wrong C action id" % bundle_id)
		_expect(CORE_LOOP.story_owns_action_result(bundle_id) \
				== expected_story_owned \
				and str(scene_bundle.get(
					"action_result_presentation", "")) \
					== ("story_owned" if expected_story_owned else ""),
			"%s escaped the exact Month-Four story-owned result opt-in"
				% bundle_id)
		_expect(raw_allowed is Array \
				and not (raw_allowed as Array).is_empty(),
			"%s has no machine-readable C deadline" % bundle_id)
		if raw_allowed is Array:
			for raw_week in raw_allowed:
				_expect(int(raw_week) >= 13 and int(raw_week) <= 16,
					"%s escaped the weeks 13–16 window" % bundle_id)
		var execution := str(config.get("execution", ""))
		_expect(execution in ["application", "instant_effect", "rest"],
			"%s has no executable C action config" % bundle_id)
		if execution == "instant_effect":
			_expect(config.get("effects", {}) is Dictionary \
					and not (config.get("effects", {}) as Dictionary).is_empty() \
					and str(config.get("axis", "")) in ["money", "human"] \
					and not str(config.get(
						"place_id", "")).strip_edges().is_empty(),
				"%s instant result lacks effects, axis, or place" % bundle_id)
		if execution == "application":
			_expect(not str(config.get(
					"application_id", "")).strip_edges().is_empty() \
					and str(config.get("status", "")) == "submitted",
				"%s application lacks its submitted receipt contract" \
					% bundle_id)
		for result_key in [
			"result_title_ko", "result_title_en",
			"result_body_ko", "result_body_en",
		]:
			_expect(not str(config.get(
					result_key, "")).strip_edges().is_empty(),
				"%s lacks %s" % [bundle_id, result_key])
		var title_key := "%s|%s" % [
			str(config.get("result_title_ko", "")),
			str(config.get("result_title_en", "")),
		]
		var body_key := "%s|%s" % [
			str(config.get("result_body_ko", "")),
			str(config.get("result_body_en", "")),
		]
		_expect(not result_titles.has(title_key) \
				and not result_bodies.has(body_key),
			"%s reused another C action's result copy" % bundle_id)
		result_titles[title_key] = true
		result_bodies[body_key] = true

		var action_turn := 13
		if raw_allowed is Array and not (raw_allowed as Array).is_empty():
			action_turn = int((raw_allowed as Array)[0])
		_check_atomic_action_roundtrip(bundle_id, action_turn)

func _check_atomic_action_roundtrip(
		bundle_id: String, action_turn: int) -> void:
	_fresh_at(action_turn)
	GameState.money = 2_000_000.0
	GameState.health = 50
	GameState.mental = 50
	GameState.intelligence = 50
	var scene_bundle := CORE_LOOP.bundle(bundle_id)
	var action_id := str(scene_bundle.get("action_id", ""))
	var expected_story_owned := (
		bundle_id == "m4_housing_welfare_consultation")
	var config: Dictionary = (
		(scene_bundle.get("action_config", {}) as Dictionary).duplicate(true)
		if scene_bundle.get("action_config", {}) is Dictionary else {}
	)
	var execution := str(config.get("execution", ""))
	var effects: Dictionary = (
		(config.get("effects", {}) as Dictionary).duplicate(true)
		if config.get("effects", {}) is Dictionary else {}
	)
	var details := {"execution": execution}
	if execution == "application":
		details["application_id"] = str(config.get("application_id", ""))
		details["status"] = str(config.get("status", "submitted"))
		var job_id := str(config.get("job_id", "")).strip_edges()
		if not job_id.is_empty():
			details["job_id"] = job_id
	else:
		details["effects"] = effects.duplicate(true)
	var axis := str(config.get(
		"axis", "human" if execution == "rest" else "money"))
	var place_id := str(config.get(
		"place_id", "home" if execution == "rest" else "work"))
	if execution == "instant_effect":
		details["axis"] = axis
		details["place_id"] = place_id

	var before_values := _effect_values(effects)
	_expect(CORE_LOOP.begin_bundle(bundle_id, "schedule") \
			and CORE_LOOP.story_owns_action_result() \
				== expected_story_owned \
			and GameState.arm_weekly_commitment({
				"turn": action_turn,
				"pressure_id": bundle_id,
				"pressure_family": "qa_c",
				"choice_id": action_id,
				"forgone_ids": [],
			}), "%s atomic fixture could not arm" % bundle_id)
	var transaction := GameState.finalize_weekly_effect_action(
		action_id, effects, axis, place_id, "", details)
	_expect(bool(transaction.get("ok", false)),
		"%s atomic transaction failed: %s" % [
			bundle_id, str(transaction.get("error", "unknown"))])
	var receipt := CORE_LOOP.action_receipt(bundle_id)
	_expect(GameState.action_points == 0 \
			and GameState.weekly_commitments.size() == 1 \
			and int(GameState.action_axis_this_week.get(axis, 0)) == 1 \
			and CORE_LOOP.action_result_ready() \
			and not receipt.is_empty() \
			and str(receipt.get("action_id", "")) == action_id \
			and str((receipt.get("config", {}) as Dictionary).get(
				"execution", "")) == execution,
		"%s did not atomically finalize AP, axis, commitment, and receipt" \
			% bundle_id)
	_expect(_effects_applied_once(before_values, effects),
		"%s did not apply its authored effects exactly once" % bundle_id)
	var after_values := _effect_values(effects)
	if execution == "application":
		_expect(CORE_LOOP.application_status(
				str(config.get("application_id", ""))) == "submitted",
			"%s did not store its submitted application receipt" % bundle_id)
	var receipt_count := (
		GameState.core_loop_v2_state.get(
			"action_receipts", {}) as Dictionary
	).size()
	var finalized_record := GameState.get_weekly_commitment_for_turn(
		action_turn)
	_expect(CORE_LOOP.note_action_commitment(finalized_record) \
			and (
				GameState.core_loop_v2_state.get(
					"action_receipts", {}) as Dictionary
			).size() == receipt_count,
		"%s duplicate action finalization created another receipt" \
			% bundle_id)

	var saved: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	CORE_LOOP.initialize_for_run()
	var loaded_state: Dictionary = GameState.serialize().duplicate(true)
	var recovered := CORE_LOOP.recover_action_result()
	var recovered_again := CORE_LOOP.recover_action_result()
	_expect(not recovered.is_empty() \
			and recovered == recovered_again \
			and GameState.serialize() == loaded_state \
			and _effect_values(effects) == after_values \
			and GameState.weekly_commitments.size() == 1 \
			and (
				GameState.core_loop_v2_state.get(
					"action_receipts", {}) as Dictionary
			).size() == receipt_count,
		"%s result recovery mutated state or lost its receipt" % bundle_id)
	_expect(_complete_action_or_story_bundle(bundle_id) \
			and CORE_LOOP.turn_completed(action_turn) \
			and not CORE_LOOP.action_result_ready(),
		"%s result/story bridge did not complete exactly once" % bundle_id)

func _complete_action_or_story_bundle(bundle_id: String) -> bool:
	if CORE_LOOP.action_story_stage(bundle_id) == "story":
		if not CORE_LOOP.complete_active_bundle().is_empty():
			return false
		if CORE_LOOP.action_result_ready() \
				and not CORE_LOOP.acknowledge_action_story_result(bundle_id):
			return false
		var roots := CORE_LOOP.resolved_event_roots(bundle_id)
		if roots.is_empty():
			return false
		var root := str(roots[0])
		var event: Dictionary = DataRegistry.find_event(root)
		var choices: Array = event.get("choices", []) \
			if event.get("choices", []) is Array else []
		if choices.is_empty() or not choices[0] is Dictionary:
			return false
		GameState.apply_choice(event, choices[0])
		if not CORE_LOOP.note_story_choice(root, 0):
			return false
	return CORE_LOOP.complete_active_bundle() == bundle_id \
		and CORE_LOOP.complete_active_bundle().is_empty()

func _check_sixteen_week_continuation_boundary() -> void:
	_fresh_at(16)
	GameState.money = 2_000_000.0
	var packed := load("res://scenes/MainGame.tscn") as PackedScene
	_expect(packed != null,
		"week-16 continuation QA could not load MainGame")
	if packed == null:
		return
	var main_game = packed.instantiate()
	add_child(main_game)
	await get_tree().process_frame
	await get_tree().process_frame

	GameState.turn = 16
	GameState.month = 4
	GameState.week_of_month = 4
	var state: Dictionary = GameState.core_loop_v2_state
	state["completed_turns"] = range(1, 17)
	state["completed_through_week"] = 12
	state["development_cap_week"] = 24
	state["prototype_complete"] = false
	state["prototype_completed_at_turn"] = 0
	state["completed_at_turn"] = 0
	state["active_bundle"] = ""
	state["active_kind"] = ""
	state["active_turn"] = 0
	GameState.core_loop_v2_state = state

	_captured_boundary_saves.clear()
	var callback := Callable(self, "_capture_terminal_boundary_save")
	if not SaveManager.save_completed.is_connected(callback):
		SaveManager.save_completed.connect(callback)
	main_game._core_loop_v2_advance_completed_week()
	if SaveManager.save_completed.is_connected(callback):
		SaveManager.save_completed.disconnect(callback)
	await get_tree().process_frame

	_expect(_captured_boundary_saves.size() == 1,
		"week-16 rollover wrote an intermediate or duplicate autosave")
	if _captured_boundary_saves.size() == 1:
		var saved_state: Dictionary = _captured_boundary_saves[0]
		var saved_v2: Dictionary = saved_state.get(
			"core_loop_v2_state", {})
		_expect(int(saved_state.get("turn", 0)) == 17 \
				and (saved_v2.get(
					"completed_turns", []) as Array).has(16) \
				and int(saved_v2.get(
					"completed_through_week", 0)) == 12 \
				and int(saved_v2.get(
					"development_cap_week", 0)) == 24 \
				and not bool(saved_v2.get("prototype_complete", true)) \
				and int(saved_v2.get("completed_at_turn", 0)) == 0 \
				and (saved_v2.get(
					"month_summaries", {}) as Dictionary).has("4"),
			"the week-16 autosave was not one resumable turn-17 snapshot")

	var boundary_loaded := SaveManager.load_game(SaveManager.AUTOSAVE_SLOT)
	var boundary_initialized := boundary_loaded \
		and CORE_LOOP.initialize_for_run()
	var loaded_completed_turns: Array = (
		GameState.core_loop_v2_state.get(
			"completed_turns", []) as Array)
	var loaded_completed_sixteen := loaded_completed_turns.any(
		func(raw_turn): return int(raw_turn) == 16)
	_expect(boundary_initialized \
			and GameState.turn == 17 \
			and not CORE_LOOP.is_prototype_complete() \
			and CORE_LOOP.is_active() \
			and CORE_LOOP.needs_plan(5) \
			and loaded_completed_sixteen \
			and not GameState.is_game_over,
		"durable week-16 completion did not reload into the Month Five window: "
		+ "loaded=%s initialized=%s turn=%d active=%s complete=%s "
		% [
			str(boundary_loaded), str(boundary_initialized),
			GameState.turn, str(CORE_LOOP.is_active()),
			str(CORE_LOOP.is_prototype_complete()),
		]
		+ "needs_plan=%s completed16=%s game_over=%s" % [
			str(CORE_LOOP.needs_plan(5)),
			str(loaded_completed_sixteen),
			str(GameState.is_game_over),
		])
	main_game._core_loop_v2_route_week()
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(str(main_game._modal_kind) == "core_loop_v2_month_summary" \
			and bool(main_game.modal_layer.get_meta(
				"core_loop_v2_month_summary", false)) \
			and int(main_game.modal_layer.get_meta(
				"core_loop_v2_month", 0)) == 4 \
			and not main_game.modal_close_button.visible \
			and GameState.turn == 17 \
			and CORE_LOOP.is_active() \
			and not CORE_LOOP.is_prototype_complete() \
			and bool(GameState.core_loop_v2_state.get(
				"enabled", false)),
		"turn 17 did not preserve the Month Four notebook before Month Five")
	var done_button := _find_meta_node(
		main_game.modal_layer, "core_loop_v2_recap_done")
	_expect(not is_instance_valid(done_button),
		"turn 17 exposed the terminal recap or a legacy fallback")
	var month_confirm := _find_meta_node(
		main_game.modal_layer, "core_loop_v2_month_confirm")
	_expect(is_instance_valid(month_confirm),
		"turn 17 continuation lost its Month Five planning CTA")
	if is_instance_valid(month_confirm):
		main_game._core_loop_v2_acknowledge_month_summary(4)
		await get_tree().process_frame
		await get_tree().process_frame
		var planner = main_game._core_loop_planner
		_expect(is_instance_valid(planner) \
				and planner.visible \
				and int(planner._month_index) == 5 \
				and CORE_LOOP.needs_plan(5) \
				and CORE_LOOP.is_active() \
				and not CORE_LOOP.is_prototype_complete(),
			"the week-16 continuation could not open the Month Five planner")

	main_game.free()
	packed = null
	await get_tree().process_frame

func _check_relationship_mapping(
		bundle_id: String, event_id: String, choice_index: int,
		character: String, from_stage: String, to_stage: String,
		initiative: String, memory: String, action_turn: int) -> void:
	_fresh_at(action_turn)
	if from_stage != "unmet":
		_set_relationship_stage(character, from_stage)
	var event: Dictionary = DataRegistry.find_event(event_id)
	var choices: Array = (
		event.get("choices", []) as Array
		if event.get("choices", []) is Array else []
	)
	_expect(not event.is_empty() \
			and choice_index >= 0 and choice_index < choices.size(),
		"%s choice %d is not a real event terminal" % [
			bundle_id, choice_index])
	_expect(RELATIONSHIP_STAGES.find(to_stage) \
			- RELATIONSHIP_STAGES.find(from_stage) == 1,
		"%s choice %d advances more than one relationship stage" % [
			bundle_id, choice_index])
	_expect(not CORE_LOOP.note_story_choice(event_id, choice_index),
		"%s choice was accepted without an active owner" % bundle_id)
	_expect(CORE_LOOP.begin_bundle(bundle_id, "schedule"),
		"%s could not begin" % bundle_id)
	_expect(CORE_LOOP.complete_active_bundle().is_empty(),
		"%s completed without a relationship choice receipt" % bundle_id)
	if choice_index >= 0 and choice_index < choices.size():
		GameState.apply_choice(event, choices[choice_index])
	_expect(CORE_LOOP.note_story_choice(event_id, choice_index),
		"%s choice %d did not produce a relationship receipt" % [
			bundle_id, choice_index])
	var receipt := _relationship_receipt(
		bundle_id, event_id, choice_index, action_turn)
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
	var initiated_count := (
		GameState.core_loop_v2_state.get(
			"player_initiated", []) as Array
	).size()
	_expect(str(receipt.get("character", "")) == character \
			and str(receipt.get("from", "")) == from_stage \
			and str(receipt.get("to", "")) == to_stage \
			and str(receipt.get("initiative", "")) == initiative \
			and str(receipt.get("memory", "")) == memory,
		"%s choice %d drifted from its exact stage/memory mapping" % [
			bundle_id, choice_index])
	_expect(CORE_LOOP.relationship_stage(character) == to_stage \
			and CORE_LOOP.has_relationship_memory(character, memory),
		"%s choice %d did not apply its stage and memory" % [
			bundle_id, choice_index])
	if initiative == "player":
		_expect(CORE_LOOP.was_player_initiated(character) \
				and initiated_count == 1,
			"%s choice %d did not record player initiative once" % [
				bundle_id, choice_index])
	else:
		_expect(not CORE_LOOP.was_player_initiated(character) \
				and initiated_count == 0,
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
			).size() == memory_count \
			and (
				GameState.core_loop_v2_state.get(
					"player_initiated", []) as Array
			).size() == initiated_count,
		"%s choice %d replayed a relationship effect" % [
			bundle_id, choice_index])
	_expect(CORE_LOOP.complete_active_bundle() == bundle_id \
			and CORE_LOOP.complete_active_bundle().is_empty(),
		"%s did not complete exactly once after its choice" % bundle_id)

	var saved: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	CORE_LOOP.initialize_for_run()
	_expect(CORE_LOOP.relationship_stage(character) == to_stage \
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

func _completed_bundle_prerequisite_id(bundle_id: String) -> String:
	var prerequisites: Variant = CORE_LOOP.bundle(
		bundle_id).get("prerequisites", {})
	if not prerequisites is Dictionary:
		return ""
	for group_key in ["all", "any"]:
		var raw_group: Variant = (
			prerequisites as Dictionary).get(group_key, [])
		if not raw_group is Array:
			continue
		for raw_predicate in raw_group:
			if raw_predicate is Dictionary \
					and str((raw_predicate as Dictionary).get(
						"kind", "")) == "completed_bundle":
				return str((raw_predicate as Dictionary).get(
					"bundle_id", "")).strip_edges()
	return ""

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
			"appearance", "investment_skill", "luck":
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
			"appearance", "investment_skill", "luck":
				if int(GameState.get(key)) \
						!= clampi(int(before) + int(delta), 0, 100):
					return false
	return true

func _unlock_hanbit_interview() -> void:
	_mark_completed("m3_hanbit_application", 9)
	_set_application_status("hanbit_ops_2026q1", "submitted")

func _unlock_daeun_named_path() -> void:
	_mark_completed("daeun_world_meet", 11)
	_set_relationship_stage("daeun", "opening")
	_set_relationship_memory(
		"daeun", "daeun_name_exchanged",
		"daeun_world_meet", 11)

func _unlock_daeun_distance_path() -> void:
	_mark_completed("daeun_world_meet", 11)
	_set_relationship_stage("daeun", "met")
	_set_relationship_memory(
		"daeun", "daeun_kept_distance",
		"daeun_world_meet", 11)

func _fresh_at(target_turn: int = 13) -> void:
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
	if status.is_empty():
		statuses.erase(application_id)
	else:
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
	for raw_memory in memories:
		if raw_memory is Dictionary \
				and str((raw_memory as Dictionary).get(
					"character", "")) == character \
				and str((raw_memory as Dictionary).get(
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

func _capture_v2_action_receipt(record: Dictionary) -> void:
	if CORE_LOOP.is_active():
		CORE_LOOP.note_action_commitment(record)

func _capture_terminal_boundary_save(
		success: bool, slot: int) -> void:
	if success and slot == SaveManager.AUTOSAVE_SLOT:
		_captured_boundary_saves.append(
			GameState.serialize().duplicate(true))

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
