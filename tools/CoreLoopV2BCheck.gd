extends Node
## ORDER-57 B: weeks 9–12 state migration, typed causality, receipts, and gates.

const CORE_LOOP := preload("res://systems/DemoCoreLoopV2.gd")
const STORY_MODE := preload("res://scenes/StoryMode.gd")
const FULL_ROUTE_CHECK := preload("res://tools/CoreLoopV2ECheck.gd")
const ORDER101_FIXTURES := preload("res://tools/CoreLoopV2CycleCheck.gd")
const FATHER_MEMORY_READER_SPECS := [
	{
		"memory": "father_gangnam_words_held_back",
		"producer_bundle": "father_quiet_call",
		"producer_event": "arc_father_quiet_call",
		"producer_choice": 0,
		"producer_turn": 12,
		"reader_event": "v2_father_health_signal",
	},
	{
		"memory": "father_quiet_call_ended",
		"producer_bundle": "father_quiet_call",
		"producer_event": "arc_father_quiet_call",
		"producer_choice": 1,
		"producer_turn": 12,
		"reader_event": "v2_father_health_signal",
	},
	{
		"memory": "father_asked_more",
		"producer_bundle": "father_quiet_call",
		"producer_event": "arc_father_quiet_call",
		"producer_choice": 2,
		"producer_turn": 12,
		"reader_event": "v2_father_health_signal",
	},
	{
		"memory": "father_neighbor_detail_checked",
		"producer_bundle": "father_health_signal",
		"producer_event": "v2_father_health_signal",
		"producer_choice": 0,
		"producer_turn": 21,
		"reader_event": "v2_demo_first_bill_opening",
	},
	{
		"memory": "father_called_again_that_evening",
		"producer_bundle": "father_health_signal",
		"producer_event": "v2_father_health_signal",
		"producer_choice": 1,
		"producer_turn": 21,
		"reader_event": "v2_demo_first_bill_opening",
	},
	{
		"memory": "father_health_warning_postponed",
		"producer_bundle": "father_health_signal",
		"producer_event": "v2_father_health_signal",
		"producer_choice": 2,
		"producer_turn": 21,
		"reader_event": "v2_demo_first_bill_opening",
	},
]

var _failures: Array[String] = []
var _inject_late_commitment := false
var _captured_boundary_saves: Array[Dictionary] = []

func _ready() -> void:
	var original_sfx_enabled := AudioManager.sfx_enabled
	AudioManager.sfx_enabled = false
	var action_callback := Callable(self, "_capture_v2_action_receipt")
	if not GameState.weekly_commitment_finalized.is_connected(action_callback):
		GameState.weekly_commitment_finalized.connect(action_callback)
	_check_contract_and_legacy_boundary()
	_check_twelve_week_boundary_continuation()
	_check_month_opening_snapshot()
	_check_typed_visibility()
	_check_allowed_weeks_and_exclusive_entry()
	_check_sparse_fallback_and_named_cap()
	_check_persistent_named_cap()
	_check_relationship_choice_receipts()
	_check_relationship_memory_description_variants()
	_check_legacy_callback_resolution()
	_check_scheduled_prelude_ownership()
	_check_application_transition_chain()
	_check_action_receipt_once()
	_check_activity_task_contract()
	_check_activity_task_long_horizon_envelope()
	_check_atomic_action_roundtrips()
	_check_partial_schema_two_action_result_rejected()
	_check_missing_action_receipt_lazy_recovery()
	_check_invalid_action_result_recovery()
	_check_atomic_action_rollback()
	_check_matching_decline_and_fallback()
	_check_cash_shortfall_receipts()
	_check_initial_subsidy_once_across_five_years()
	_check_twelve_week_routine_units()
	await _check_month_autosave_boundary()
	await _check_month_three_autosave_boundary()
	await _check_action_result_system_overlay()
	await _check_unfinalized_action_resume()
	AudioManager.sfx_enabled = original_sfx_enabled
	if _failures.is_empty():
		print(
			"CORE_LOOP_V2_B_CHECK_OK schema=3 cap=24 migration=8_and_12_to_24 "
			+ "continuation=week12_to_13/roundtrip prerequisites=typed/closed_safe "
			+ "entries=daeun_jiyeon_father_hyunsu exclusive=romance_entry "
			+ "relationship=from_to/current_turn_receipt/no_regression "
			+ "memory=reader_variants/father6_ko_en/exact_wrong/schema2_partial_rejected "
			+ "application=submitted/interviewed/no_offer "
			+ "callback=receipt_superseded/mindset3/v1_truthful/long_preserved "
			+ "prelude=scheduled_owner/interview+math/story_action/save_once "
			+ "action=atomic/save_result_once/story_bridge/schema2_partial_rejected/rollback "
			+ "activity_task=3_requirements/3_pairs/overreach/save/once/readers/"
			+ "W24_48_240_survival_cash "
			+ "boundary_save=single/month3_nonterminal "
			+ "month_delta=opening_to_close/save_roundtrip "
			+ "overlay=result_resume pending=minigame_restart "
			+ "decline=next_matching_once/fallback deadlines=weeks9_12 "
			+ "routines=24_units/once fallback=sparse5_only named_cap=3/global4 "
			+ "arrears=310000/inventory_zero subsidy=opening_once/240w")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("CORE_LOOP_V2_B_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)

func _check_contract_and_legacy_boundary() -> void:
	_expect(int(CORE_LOOP.contract().get("schema_version", 0)) == 3,
		"B runtime contract is not schema 3")
	_expect(CORE_LOOP.development_cap_week() == 24,
		"B regression did not inherit the week-24 development cap")
	var legacy := ORDER101_FIXTURES._order101_legacy_040746_save(6, 9, 8)
	var raw_state: Dictionary = legacy.get("core_loop_v2_state", {})
	_expect(CORE_LOOP._legacy_040746_core_state_valid(raw_state, 9, {}) \
		and CORE_LOOP._legacy_040746_weekly_witnesses_valid(
			legacy.get("weekly_commitments", []), raw_state, 9),
		"B legacy boundary fixture was not a strict 040746 Week-Nine save")
	GameState.start_new_game()
	GameState.load_from_dict(legacy)
	_expect(CORE_LOOP.initialize_for_run(),
		"strict 040746 legacy save did not initialize")
	var migrated: Dictionary = GameState.core_loop_v2_state
	_expect(int(migrated.get("schema", 0)) == 3 \
			and not CORE_LOOP.legacy_origin_receipt().is_empty() \
			and int(migrated.get("completed_through_week", 0)) == 8 \
			and int(migrated.get("development_cap_week", 0)) == 24,
		"strict schema-two completion did not migrate through week 8")
	var migrated_opening_receipt: Variant = (
		migrated.get("consequence_receipts", {}) as Dictionary
	).get("opening_interview_math", {})
	var migrated_temptation_receipt: Variant = (
		migrated.get("consequence_receipts", {}) as Dictionary
	).get("temptation_consequence", {})
	_expect((migrated.get(
			"relationship_stages", {}) as Dictionary).is_empty() \
			and (migrated.get(
				"relationship_choice_receipts", {}) as Dictionary).is_empty() \
			and (migrated.get("relationship_memories", []) as Array).is_empty() \
			and (migrated.get("player_initiated", []) as Array).is_empty() \
			and migrated_opening_receipt is Dictionary \
			and str((migrated_opening_receipt as Dictionary).get(
				"status", "")) == "consumed" \
			and (migrated_opening_receipt as Dictionary).get(
				"roots", []) == ["arc_intro_01_meal"] \
			and migrated_temptation_receipt is Dictionary \
			and str((migrated_temptation_receipt as Dictionary).get(
				"status", "")) == "consumed",
		"strict schema-two migration changed frozen shown/relationship history")
	_expect(CORE_LOOP.is_active(),
		"migrated strict save did not continue into week 9")
	_expect(not CORE_LOOP.is_prototype_complete(),
		"migrated strict save was mistaken for a completed 24-week build")
	var saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	CORE_LOOP.initialize_for_run()
	_expect(CORE_LOOP.is_active() \
			and not CORE_LOOP.legacy_origin_receipt().is_empty() \
			and int(GameState.core_loop_v2_state.get(
				"completed_through_week", 0)) == 8,
		"week-9 migration did not survive save/load")

func _check_twelve_week_boundary_continuation() -> void:
	_fresh()
	var state: Dictionary = GameState.core_loop_v2_state
	state["completed_turns"] = range(1, 13)
	state["completed_through_week"] = 12
	state["development_cap_week"] = 12
	state["prototype_complete"] = true
	state["prototype_completed_at_turn"] = 13
	state["completed_at_turn"] = 13
	GameState.core_loop_v2_state = state
	GameState.turn = 12
	_expect(CORE_LOOP.is_active(),
		"week 12 was outside the B development window")
	GameState.turn = 13
	_expect(CORE_LOOP.initialize_for_run(),
		"week-12 completion did not initialize under the week-24 cap")
	_expect(int(GameState.core_loop_v2_state.get(
			"development_cap_week", 0)) == 24,
		"week-12 completion did not migrate its development cap to week 24")
	_expect(not CORE_LOOP.is_prototype_complete(),
		"week 12 was mistaken for the extended build boundary")
	_expect(not CORE_LOOP.mark_prototype_complete(),
		"turn 13 incorrectly closed the week-24 development build")
	_expect(CORE_LOOP.is_active(),
		"the B slice did not continue into week 13")
	var saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	CORE_LOOP.initialize_for_run()
	_expect(not CORE_LOOP.is_prototype_complete() \
			and CORE_LOOP.is_active() \
			and int(GameState.core_loop_v2_state.get(
				"completed_through_week", 0)) == 12 \
			and int(GameState.core_loop_v2_state.get(
				"development_cap_week", 0)) == 24 \
			and (GameState.core_loop_v2_state.get(
				"completed_turns", []) as Array).has(12),
		"week-12 continuation did not survive save/load")

func _check_month_opening_snapshot() -> void:
	_fresh()
	GameState.money = 500_000.0
	GameState.health = 77
	GameState.mental = 66
	_expect(bool(CORE_LOOP.commit_plan(
			1, _month_one_schedule(), _growth_routines()).get("ok", false)),
		"month-opening fixture could not commit its first plan")
	var opening := CORE_LOOP.month_opening_snapshot(1)
	_expect(is_equal_approx(float(opening.get("money", 0.0)), 500_000.0) \
			and int(opening.get("health", 0)) == 77 \
			and int(opening.get("mental", 0)) == 66,
		"monthly ledger did not capture the economy before Week 1 actions")
	GameState.money = 860_000.0
	GameState.health = 70
	GameState.mental = 59
	var after_actions := CORE_LOOP.month_opening_snapshot(1)
	_expect(is_equal_approx(
			float(after_actions.get("money", 0.0)), 500_000.0),
		"weekly actions rewrote the month-opening economy snapshot")
	var saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	var reloaded := CORE_LOOP.month_opening_snapshot(1)
	_expect(is_equal_approx(float(reloaded.get("money", 0.0)), 500_000.0) \
			and int(reloaded.get("health", 0)) == 77 \
			and int(reloaded.get("mental", 0)) == 66,
		"month-opening economy snapshot did not survive save/load")

func _check_month_autosave_boundary() -> void:
	_fresh()
	var packed := load("res://scenes/MainGame.tscn") as PackedScene
	_expect(packed != null,
		"month-autosave QA could not load MainGame")
	if packed == null:
		return
	var main_game = packed.instantiate()
	add_child(main_game)
	await get_tree().process_frame
	await get_tree().process_frame

	GameState.turn = 4
	GameState.month = 1
	GameState.week_of_month = 4
	var state: Dictionary = GameState.core_loop_v2_state
	state["completed_turns"] = range(1, 5)
	state["completed_through_week"] = 0
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
		"week-4 rollover wrote more than one durable month-boundary save")
	if _captured_boundary_saves.size() == 1:
		var saved_state: Dictionary = _captured_boundary_saves[0]
		var saved_v2: Dictionary = saved_state.get(
			"core_loop_v2_state", {})
		_expect(int(saved_state.get("turn", 0)) == 5 \
				and not bool(saved_v2.get("prototype_complete", true)) \
				and (saved_v2.get(
					"month_summaries", {}) as Dictionary).has("1"),
			"the only week-4 boundary save did not include its month summary")
	_expect(SaveManager.load_game(SaveManager.AUTOSAVE_SLOT) \
			and CORE_LOOP.initialize_for_run() \
			and GameState.turn == 5 \
			and CORE_LOOP.is_active() \
			and not CORE_LOOP.pending_month_summary().is_empty(),
		"the durable week-4 boundary did not reload into its month notebook")

	main_game.free()
	packed = null
	await get_tree().process_frame

func _check_month_three_autosave_boundary() -> void:
	_fresh()
	var packed := load("res://scenes/MainGame.tscn") as PackedScene
	_expect(packed != null,
		"terminal-autosave QA could not load MainGame")
	if packed == null:
		return
	var main_game = packed.instantiate()
	add_child(main_game)
	await get_tree().process_frame
	await get_tree().process_frame

	GameState.turn = 12
	GameState.month = 3
	GameState.week_of_month = 4
	var state: Dictionary = GameState.core_loop_v2_state
	state["completed_turns"] = range(1, 13)
	state["completed_through_week"] = 8
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
		"week-12 rollover did not write exactly one month-three autosave")
	if _captured_boundary_saves.size() == 1:
		var saved_state: Dictionary = _captured_boundary_saves[0]
		var saved_v2: Dictionary = saved_state.get(
			"core_loop_v2_state", {})
		_expect(int(saved_state.get("turn", 0)) == 13 \
				and int(saved_v2.get("completed_through_week", 0)) == 8 \
				and (saved_v2.get("completed_turns", []) as Array).has(12) \
				and not bool(saved_v2.get("prototype_complete", true)) \
				and (saved_v2.get(
					"month_summaries", {}) as Dictionary).has("3"),
			"the week-12 boundary autosave was not a resumable month-three "
			+ "snapshot")
	_expect(SaveManager.load_game(SaveManager.AUTOSAVE_SLOT) \
				and CORE_LOOP.initialize_for_run() \
				and GameState.turn == 13 \
				and not CORE_LOOP.is_prototype_complete() \
				and CORE_LOOP.is_active(),
			"the durable week-12 boundary did not reload into month four")

	main_game.free()
	packed = null
	await get_tree().process_frame

func _capture_terminal_boundary_save(success: bool, slot: int) -> void:
	if success and slot == SaveManager.AUTOSAVE_SLOT:
		_captured_boundary_saves.append(
			GameState.serialize().duplicate(true))

func _check_typed_visibility() -> void:
	_fresh()
	GameState.turn = 9
	var base := CORE_LOOP.available_offer_ids(3)
	for gated_id in [
		"daeun_world_meet", "jiyeon_world_meet",
		"father_quiet_call", "hyunsu_study_followup",
	]:
		_expect(not base.has(gated_id),
			"%s appeared without its typed history" % gated_id)

	var state: Dictionary = GameState.core_loop_v2_state
	state["plans"] = {
		"1": {"routines": {"primary": "livelihood", "secondary": "growth"}},
	}
	GameState.core_loop_v2_state = state
	_expect(CORE_LOOP.available_offer_ids(3).has("daeun_world_meet"),
		"Daeun did not open from a committed livelihood route")

	_fresh()
	GameState.turn = 9
	_install_legacy_delivery_completion(6)
	_expect(CORE_LOOP.available_offer_ids(3).has("jiyeon_world_meet"),
		"Jiyeon did not preserve the schema-two delivery fallback")

	_fresh()
	GameState.turn = 9
	_mark_completed("father_first_call", 2)
	_set_relationship_stage("father", "opening")
	_set_relationship_memory(
		"father", "father_wellbeing_returned", "father_first_call", 2)
	_expect(CORE_LOOP.available_offer_ids(3).has("father_quiet_call"),
		"Father's follow-up did not open from his actual first call")

	_fresh()
	GameState.turn = 9
	_mark_completed("hyunsu_player_reachout", 5)
	_set_relationship_stage("hyunsu", "player_reached_out")
	_expect(not CORE_LOOP.available_offer_ids(3).has("hyunsu_study_followup"),
		"Hyunsu follow-up ignored the player-initiative predicate")
	var initiated: Dictionary = GameState.core_loop_v2_state
	initiated["player_initiated"] = ["hyunsu"]
	initiated["relationship_memories"] = [{
		"character": "hyunsu",
		"memory": "hyunsu_resume_shared",
		"bundle_id": "hyunsu_player_reachout",
		"turn": 5,
	}]
	GameState.core_loop_v2_state = initiated
	_expect(CORE_LOOP.available_offer_ids(3).has("hyunsu_study_followup"),
		"Hyunsu follow-up stayed closed after the player reached out")

	GameState.current_job = {"id": "qa_b_job"}
	_expect(CORE_LOOP._bundle_requirement_met({
		"prerequisites": {"all": [{
			"kind": "current_job_id", "job_id": "qa_b_job",
		}]},
	}), "typed current-job predicate did not read the live job")
	_expect(not CORE_LOOP._bundle_requirement_met({
		"prerequisites": {"all": [{"kind": "unknown_future_rule"}]},
	}), "unknown typed prerequisite failed open")
	_expect(not CORE_LOOP._bundle_requirement_met({
		"prerequisites": {"all": [{"kind": "completed_bundle"}]},
	}), "malformed typed prerequisite failed open")
	GameState.current_job = {}

	var closed_state: Dictionary = GameState.core_loop_v2_state
	closed_state["relationship_stages"] = {"daeun": "closed"}
	closed_state["relationship_memories"] = [{
		"character": "daeun",
		"memory": "daeun_name_exchanged",
	}]
	GameState.core_loop_v2_state = closed_state
	_expect(not CORE_LOOP._bundle_requirement_met({
		"prerequisites": {"all": [{
			"kind": "relationship_at_least",
			"character": "daeun",
			"stage": "met",
		}]},
	}), "closed relationship passed an earlier at-least predicate")
	_expect(CORE_LOOP._bundle_requirement_met({
		"prerequisites": {"all": [{
			"kind": "relationship_memory",
			"character": "daeun",
			"memory": "daeun_name_exchanged",
		}]},
	}), "typed relationship memory did not read the exact receipt pair")
	_expect(not CORE_LOOP._bundle_requirement_met({
		"prerequisites": {"all": [{
			"kind": "relationship_memory",
			"character": "jiyeon",
			"memory": "daeun_name_exchanged",
		}]},
	}), "relationship memory matched the right memory on the wrong person")
	_expect(not CORE_LOOP._bundle_requirement_met({
		"prerequisites": {"all": [{
			"kind": "relationship_memory",
			"character": "daeun",
			"memory": "daeun_kept_distance",
		}]},
	}), "relationship memory matched the right person with the wrong memory")

func _check_allowed_weeks_and_exclusive_entry() -> void:
	_fresh()
	GameState.turn = 9
	_unlock_all_b_entries()
	for bundle_id in [
		"m3_hanbit_application", "m3_inventory_shift", "m3_empty_saturday",
		"father_quiet_call", "hyunsu_study_followup",
		"daeun_world_meet", "jiyeon_world_meet",
	]:
		var allowed: Variant = CORE_LOOP.bundle(bundle_id).get(
			"allowed_weeks", [])
		_expect(allowed is Array and not (allowed as Array).is_empty(),
			"%s has no machine-readable B deadline" % bundle_id)
		if allowed is Array:
			for raw_week in allowed:
				_expect(int(raw_week) >= 9 and int(raw_week) <= 12,
					"%s escaped the weeks 9–12 window" % bundle_id)
	_expect(CORE_LOOP.bundle_allowed_in_week(
			"m3_hanbit_application", 9) \
			and not CORE_LOOP.bundle_allowed_in_week(
				"m3_hanbit_application", 10),
		"Hanbit's week-9 deadline is not enforced")
	var deadline_result := CORE_LOOP.validate_plan(3, {
		"9": "m3_inventory_shift",
		"10": "m3_hanbit_application",
		"11": "daeun_world_meet",
		"12": "father_quiet_call",
	}, _growth_routines())
	_expect(not bool(deadline_result.get("ok", false)) \
			and str(deadline_result.get("error", "")) == "deadline_missed" \
			and str(deadline_result.get("bundle", "")) \
				== "m3_hanbit_application",
		"month-three validation accepted a late Hanbit application")
	var exclusive_result := CORE_LOOP.validate_plan(3, {
		"9": "m3_hanbit_application",
		"10": "daeun_world_meet",
		"11": "jiyeon_world_meet",
		"12": "father_quiet_call",
	}, _growth_routines())
	_expect(not bool(exclusive_result.get("ok", false)) \
			and str(exclusive_result.get("error", "")) == "exclusive_group" \
			and str(exclusive_result.get("group", "")) == "romance_entry",
		"month three allowed both heroine entrances in one plan")
	_expect(bool(CORE_LOOP.validate_plan(
		3, _month_three_schedule(), _growth_routines()).get("ok", false)),
		"a legal month-three schedule was rejected")

func _check_sparse_fallback_and_named_cap() -> void:
	_fresh()
	GameState.turn = 9
	var sparse := CORE_LOOP.available_offer_ids(3)
	_expect(sparse.size() == 5 \
			and sparse.has("m3_room_ledger") \
			and sparse.has("m3_library_job_board"),
		"sparse month three did not fill the five-offer surface contract")

	_fresh()
	GameState.turn = 9
	_unlock_all_b_entries()
	var rich := CORE_LOOP.available_offer_ids(3)
	_expect(rich.size() == 7 \
			and not rich.has("m3_room_ledger") \
			and not rich.has("m3_library_job_board"),
		"rich month three exposed its sparse-only fallback or lost an offer")
	var rich_plan := {
		"9": "m3_hanbit_application",
		"10": "daeun_world_meet",
		"11": "father_quiet_call",
		"12": "hyunsu_study_followup",
	}
	var allowed_result := CORE_LOOP.validate_plan(
		3, rich_plan, _growth_routines())
	_expect(bool(allowed_result.get("ok", false)),
		"month three rejected a three-character plan at its authored cap")
	var committed := CORE_LOOP.commit_plan(
		3, rich_plan, _growth_routines())
	var fallback_forgone := false
	for raw_record in CORE_LOOP.forgone_for_month(3):
		if raw_record is Dictionary \
				and str((raw_record as Dictionary).get(
					"bundle_id", "")) in [
						"m3_room_ledger", "m3_library_job_board",
					]:
			fallback_forgone = true
			break
	_expect(bool(committed.get("ok", false)) and not fallback_forgone,
		"an unexposed sparse fallback was recorded as a forgone choice")

	_fresh()
	GameState.turn = 9
	_unlock_all_b_entries()
	var over_cap := CORE_LOOP._validate_named_character_cap(
		{"active_named_characters_max": 3}, [
			"father_quiet_call",
			"hyunsu_study_followup",
			"daeun_world_meet",
			"sangchul_world_meet",
		])
	_expect(not over_cap.is_empty() \
			and str(over_cap.get("error", "")) \
				== "active_named_characters_cap" \
			and int(over_cap.get("maximum", 0)) == 3,
		"month three accepted four named characters above its cap")

func _check_persistent_named_cap() -> void:
	_fresh()
	GameState.turn = 13
	var state: Dictionary = GameState.core_loop_v2_state
	state["relationship_stages"] = {
		"father": "opening",
		"hyunsu": "shared_commitment",
		"daeun": "player_reached_out",
	}
	GameState.core_loop_v2_state = state
	var month_four_spec := {"active_named_characters_max": 4}
	var fourth_thread := CORE_LOOP._validate_named_character_cap(
		month_four_spec, ["sangchul_world_meet"])
	_expect(fourth_thread.is_empty(),
		"three persistent people plus one month-four mentor did not fit "
		+ "the global four-thread cap")

	state = GameState.core_loop_v2_state
	state["relationship_stages"]["jiyeon"] = "opening"
	GameState.core_loop_v2_state = state
	var fifth_thread := CORE_LOOP._validate_named_character_cap(
		month_four_spec, ["sangchul_world_meet"])
	_expect(not fifth_thread.is_empty() \
			and str(fifth_thread.get("error", "")) \
				== "active_named_characters_cap" \
			and int(fifth_thread.get("maximum", 0)) == 4 \
			and (fifth_thread.get("characters", []) as Array).size() == 5,
		"four persistent people plus a fifth mentor escaped the global cap")

	state = GameState.core_loop_v2_state
	state["relationship_stages"]["jiyeon"] = "closed"
	GameState.core_loop_v2_state = state
	var closed_thread := CORE_LOOP._validate_named_character_cap(
		month_four_spec, ["sangchul_world_meet"])
	_expect(closed_thread.is_empty(),
		"a closed relationship incorrectly occupied an active named thread")

func _check_relationship_choice_receipts() -> void:
	_fresh()
	GameState.turn = 10
	_expect(CORE_LOOP.begin_bundle("daeun_world_meet", "schedule"),
		"Daeun's first-meeting bundle could not begin")
	_expect(CORE_LOOP.complete_active_bundle().is_empty(),
		"relationship bundle completed without a scene choice receipt")
	_expect(not CORE_LOOP.has_completed_bundle("daeun_world_meet") \
			and not CORE_LOOP.turn_completed(10),
		"receipt-less relationship bundle mutated completion state")
	_expect(CORE_LOOP.note_story_choice("arc_daeun_01_meet", 0),
		"Daeun's name-exchange choice did not produce a receipt")
	_expect(CORE_LOOP.relationship_stage("daeun") == "opening" \
			and not CORE_LOOP.was_player_initiated("daeun"),
		"chance meeting produced the wrong stage or player initiative")
	var receipts: Dictionary = GameState.core_loop_v2_state.get(
		"relationship_choice_receipts", {})
	var memories: Array = GameState.core_loop_v2_state.get(
		"relationship_memories", [])
	_expect(receipts.size() == 1 and memories.size() == 1 \
			and str((memories[0] as Dictionary).get("memory", "")) \
				== "daeun_name_exchanged",
		"relationship receipt did not preserve its authored memory")
	_expect(CORE_LOOP.complete_active_bundle() == "daeun_world_meet" \
			and CORE_LOOP.turn_completed(10),
		"current-turn relationship receipt did not authorize completion")
	GameState.turn = 11
	CORE_LOOP.begin_bundle("daeun_world_meet", "schedule")
	_expect(not CORE_LOOP.note_story_choice("arc_daeun_01_meet", 1),
		"an unmet→met choice was allowed to regress Daeun from opening")
	_expect(CORE_LOOP.relationship_stage("daeun") == "opening",
		"relationship stage regressed after replaying an earlier choice")
	CORE_LOOP.cancel_active_bundle()

	_fresh()
	GameState.turn = 10
	CORE_LOOP.begin_bundle("daeun_world_meet", "schedule")
	_expect(CORE_LOOP.note_story_choice("arc_daeun_01_meet", 1) \
			and CORE_LOOP.relationship_stage("daeun") == "met",
		"Daeun's guarded choice did not map to the met stage")
	_expect(CORE_LOOP.complete_active_bundle() == "daeun_world_meet",
		"Daeun's second valid result could not complete its bundle")

	_check_relationship_mapping(
		"jiyeon_world_meet", "arc_jiyeon_01_crash", 1,
		"jiyeon", "unmet", "met", "world",
		"jiyeon_repair_cost_taken", false)
	_check_relationship_mapping(
		"father_quiet_call", "arc_father_quiet_call", 2,
		"father", "opening", "opening", "player",
		"father_asked_more", false)
	_check_relationship_mapping(
		"hyunsu_study_followup", "v2_hyunsu_study_followup", 1,
		"hyunsu", "player_reached_out", "shared_commitment", "reciprocal",
		"hyunsu_one_problem_each_agreed", true)
	_check_fresh_father_return_mapping()


func _check_fresh_father_return_mapping() -> void:
	# An old planned V2 run can own the newly extended interview+math receipt
	# without having gone through the new pre-plan Send scene. Receipt roots
	# alone therefore must not rewrite its incoming call as player-led.
	_fresh()
	GameState.turn = 2
	var state: Dictionary = GameState.core_loop_v2_state
	state["shown_consequences"] = ["opening_interview_math"]
	state["shown_consequence_turns"] = {"opening_interview_math": 1}
	state["consequence_receipts"] = {
		"opening_interview_math": {
			"consequence_id": "opening_interview_math",
			"status": "consumed",
			"roots": ["arc_intro_01_meal", "v2_opening_return_math"],
			"presented_turn": 1,
			"consumed_turn": 1,
		},
	}
	GameState.core_loop_v2_state = state
	_expect(not bool(GameState.flags.get(
			"opening_preplan_application_sent", false)) \
			and CORE_LOOP.consequence_receipt_has_root(
				"opening_interview_math", "v2_opening_return_math") \
			and CORE_LOOP.begin_bundle("father_first_call", "schedule") \
			and CORE_LOOP.note_story_choice("arc_father_01_call", 0),
		"old planned V2 Father call fixture could not produce its receipt")
	var old_planned_receipt: Dictionary = (
		GameState.core_loop_v2_state.get(
			"relationship_choice_receipts", {}) as Dictionary
	).get("father_first_call:arc_father_01_call:0:2", {})
	_expect(str(old_planned_receipt.get("initiative", "")) == "reciprocal" \
			and not CORE_LOOP.was_player_initiated("father"),
		"old planned V2 receipt roots rewrote Father's incoming call as a "
		+ "player callback")
	CORE_LOOP.cancel_active_bundle()

	_fresh()
	GameState.turn = 2
	state = GameState.core_loop_v2_state
	state["shown_consequences"] = ["opening_interview_math"]
	state["shown_consequence_turns"] = {"opening_interview_math": 1}
	state["consequence_receipts"] = {
		"opening_interview_math": {
			"consequence_id": "opening_interview_math",
			"status": "consumed",
			"roots": ["arc_intro_01_meal", "v2_opening_return_math"],
			"presented_turn": 1,
			"consumed_turn": 1,
		},
	}
	GameState.core_loop_v2_state = state
	GameState.flags["opening_preplan_application_sent"] = true
	_expect(CORE_LOOP.begin_bundle("father_first_call", "schedule") \
			and CORE_LOOP.note_story_choice("arc_father_01_call", 0),
		"fresh post-calculation Father callback did not produce a receipt")
	var receipt: Dictionary = (
		GameState.core_loop_v2_state.get(
			"relationship_choice_receipts", {}) as Dictionary
	).get("father_first_call:arc_father_01_call:0:2", {})
	_expect(str(receipt.get("initiative", "")) == "player" \
			and str(receipt.get("memory", "")) \
				== "father_wellbeing_returned" \
			and CORE_LOOP.consequence_receipt_has_root(
				"opening_interview_math", "v2_opening_return_math") \
			and CORE_LOOP.was_player_initiated("father"),
		"fresh pre-plan Send flag did not make Father's scene a truthful "
		+ "player callback")
	CORE_LOOP.cancel_active_bundle()

func _check_relationship_memory_description_variants() -> void:
	_fresh()
	var story = STORY_MODE.new()
	var old_planned_state: Dictionary = GameState.core_loop_v2_state
	old_planned_state["consequence_receipts"] = {
		"opening_interview_math": {
			"consequence_id": "opening_interview_math",
			"status": "consumed",
			"roots": ["arc_intro_01_meal", "v2_opening_return_math"],
		},
	}
	GameState.core_loop_v2_state = old_planned_state
	var actual_father_event: Dictionary = DataRegistry.find_event(
		"arc_father_01_call")
	var base_father_description := str(actual_father_event.get(
		"description", ""))
	var callback_descriptions: Dictionary = actual_father_event.get(
		"description_if_known", {})
	var callback_father_description := str(callback_descriptions.get(
		"opening_preplan_application_sent", ""))
	var base_father_resolved := story._resolved_story_description(
		actual_father_event)
	_expect(not base_father_description.is_empty() \
			and not callback_father_description.is_empty() \
			and CORE_LOOP.consequence_receipt_has_root(
				"opening_interview_math", "v2_opening_return_math") \
			and not bool(GameState.flags.get(
				"opening_preplan_application_sent", false)) \
			and base_father_resolved.contains(
				story._fmt(base_father_description)) \
			and not base_father_resolved.contains(
				story._fmt(callback_father_description)),
		"Father's legacy incoming call was rewritten without the dedicated "
		+ "pre-plan Send flag")
	var opening_state: Dictionary = GameState.core_loop_v2_state
	opening_state["consequence_receipts"] = {
		"opening_interview_math": {
			"consequence_id": "opening_interview_math",
			"status": "consumed",
			"roots": ["arc_intro_01_meal", "v2_opening_return_math"],
		},
	}
	GameState.core_loop_v2_state = opening_state
	GameState.flags["opening_preplan_application_sent"] = true
	var callback_father_resolved := story._resolved_story_description(
		actual_father_event)
	_expect(callback_father_resolved.contains(
			story._fmt(callback_father_description)) \
			and not callback_father_resolved.contains(
				story._fmt(base_father_description)),
		"fresh pre-plan Send flag did not select Father's returned-call prose")

	_fresh()
	var father_event := {
		"description": "FATHER_BASE",
		"description_memory_if_known": {
			"relationship_memory:father:father_asked_more":
				"FATHER_MEMORY",
		},
	}
	var hyunsu_event := {
		"description": "HYUNSU_BASE",
		"description_memory_if_known": {
			"relationship_memory:hyunsu:hyunsu_one_problem_each_agreed":
				"HYUNSU_MEMORY",
		},
	}
	_expect(not story._resolved_story_description(
			father_event).contains("FATHER_MEMORY"),
		"father memory prose appeared before its exact V2 receipt")
	_expect(not story._resolved_story_description(
			hyunsu_event).contains("HYUNSU_MEMORY"),
		"Hyunsu memory prose appeared before its exact V2 receipt")

	var state: Dictionary = GameState.core_loop_v2_state
	state["relationship_memories"] = [{
		"character": "father",
		"memory": "father_asked_more",
	}]
	GameState.core_loop_v2_state = state
	_expect(story._resolved_story_description(
			father_event).contains("FATHER_MEMORY"),
		"father memory prose did not read its exact V2 receipt")
	_expect(not story._resolved_story_description(
			hyunsu_event).contains("HYUNSU_MEMORY"),
		"father's V2 receipt unlocked Hyunsu's memory prose")

	state = GameState.core_loop_v2_state
	state["relationship_memories"].append({
		"character": "hyunsu",
		"memory": "hyunsu_one_problem_each_agreed",
	})
	GameState.core_loop_v2_state = state
	_expect(story._resolved_story_description(
			hyunsu_event).contains("HYUNSU_MEMORY"),
		"Hyunsu memory prose did not read its exact V2 receipt")

	var legacy_event := {
		"description": "LEGACY_BASE",
		"description_memory_if_known": {
			"qa_legacy_memory_flag": "LEGACY_MEMORY",
		},
	}
	_expect(not story._resolved_story_description(
			legacy_event).contains("LEGACY_MEMORY"),
		"legacy memory prose appeared before its GameState flag")
	GameState.flags["qa_legacy_memory_flag"] = true
	_expect(story._resolved_story_description(
			legacy_event).contains("LEGACY_MEMORY"),
		"ordinary description_memory_if_known flags lost compatibility")
	story._current_presentation = {"nameplate_role": "hidden"}
	_expect(story._story_nameplate_hidden(),
		"Jiyeon's delayed-name presentation did not hide the nameplate")
	story._current_presentation = {}
	_expect(not story._story_nameplate_hidden(),
		"an ordinary story presentation inherited the hidden nameplate")
	_check_father_small_completion_readers(story)
	story.free()

func _check_father_small_completion_readers(story) -> void:
	var original_language := LocaleManager.language
	var expected_keys_by_event := {
		"v2_father_health_signal": [
			"relationship_memory:father:father_asked_more",
			"relationship_memory:father:father_gangnam_words_held_back",
			"relationship_memory:father:father_quiet_call_ended",
		],
		"v2_demo_first_bill_opening": [
			"relationship_memory:father:father_called_again_that_evening",
			"relationship_memory:father:father_health_warning_postponed",
			"relationship_memory:father:father_neighbor_detail_checked",
		],
	}
	for language in ["ko", "en"]:
		LocaleManager.set_language(language)
		for reader_event_id in expected_keys_by_event:
			var reader_event: Dictionary = DataRegistry.find_event(
				reader_event_id)
			var raw_memory_map: Variant = reader_event.get(
				"description_memory_if_known", {})
			var actual_keys: Array[String] = []
			if raw_memory_map is Dictionary:
				for raw_key in (raw_memory_map as Dictionary):
					actual_keys.append(str(raw_key))
			actual_keys.sort()
			var expected_keys: Array = expected_keys_by_event[
				reader_event_id].duplicate()
			expected_keys.sort()
			_expect(not reader_event.is_empty() \
					and actual_keys == expected_keys,
				"%s %s lost the exact three Father memory readers" % [
					language, reader_event_id])

		for raw_spec in FATHER_MEMORY_READER_SPECS:
			var spec: Dictionary = raw_spec
			var memory_id := str(spec["memory"])
			var reader_event_id := str(spec["reader_event"])
			var condition_key := "relationship_memory:father:%s" % memory_id
			var reader_event: Dictionary = DataRegistry.find_event(
				reader_event_id)
			var memory_map: Dictionary = reader_event.get(
				"description_memory_if_known", {})
			var memory_text := str(memory_map.get(condition_key, ""))
			_expect(not memory_text.strip_edges().is_empty(),
				"%s %s has no prose for %s" % [
					language, reader_event_id, memory_id])

			_fresh()
			var baseline: String = story._resolved_story_description(reader_event)
			_expect(not baseline.contains(story._fmt(memory_text)),
				"%s %s appeared without a typed receipt" % [
					language, memory_id])

			var state: Dictionary = GameState.core_loop_v2_state
			state["relationship_memories"] = [
				{
					"character": "hyunsu",
					"memory": memory_id,
				},
				{
					"character": "father",
					"memory": "%s_wrong" % memory_id,
				},
			]
			GameState.core_loop_v2_state = state
			var wrong_key: String = story._resolved_story_description(reader_event)
			_expect(not wrong_key.contains(story._fmt(memory_text)),
				"%s %s accepted a wrong character or memory key" % [
					language, memory_id])

			state = GameState.core_loop_v2_state
			state["relationship_memories"] = [{
				"character": "father",
				"memory": memory_id,
				"bundle_id": str(spec["producer_bundle"]),
				"event_id": str(spec["producer_event"]),
				"choice_index": int(spec["producer_choice"]),
				"turn": int(spec["producer_turn"]),
			}]
			GameState.core_loop_v2_state = state
			var exact: String = story._resolved_story_description(reader_event)
			_expect(exact.contains(story._fmt(memory_text)),
				"%s %s did not reach %s through its exact typed receipt" % [
					language, memory_id, reader_event_id])

			_seed_partial_schema_two_father_memory(spec)
			var migrated_event: Dictionary = DataRegistry.find_event(
				reader_event_id)
			var migrated: String = story._resolved_story_description(migrated_event)
			_expect(CORE_LOOP.legacy_origin_receipt().is_empty() \
					and not CORE_LOOP.has_relationship_memory("father", memory_id) \
					and not migrated.contains(story._fmt(memory_text)),
				"%s partial schema-2 Father state promoted %s" % [
					language, memory_id])

		_check_father_legacy_flags_do_not_infer_memories(story, language)
	LocaleManager.set_language(original_language)

func _seed_partial_schema_two_father_memory(spec: Dictionary) -> void:
	GameState.start_new_game()
	var producer_turn := int(spec["producer_turn"])
	GameState.turn = mini(24, producer_turn + 1)
	var producer_bundle := str(spec["producer_bundle"])
	var producer_event := str(spec["producer_event"])
	var producer_choice := int(spec["producer_choice"])
	var receipt_key := "%s:%s:%d:%d" % [
		producer_bundle, producer_event, producer_choice, producer_turn]
	var completed_bundles: Array = [producer_bundle]
	if producer_bundle == "father_quiet_call":
		completed_bundles.push_front("father_first_call")
	GameState.core_loop_v2_state = {
		"schema": 2,
		"enabled": true,
		"completed_turns": range(1, GameState.turn),
		"completed_bundles": completed_bundles,
		"relationship_stages": {"father": "opening"},
		"relationship_choice_receipts": {receipt_key: true},
		"relationship_history": [],
		"player_initiated": [],
	}
	_expect(CORE_LOOP.initialize_for_run(),
		"partial schema-2 Father fixture did not initialize for %s" \
			% str(spec["memory"]))

func _check_father_legacy_flags_do_not_infer_memories(
		story, language: String) -> void:
	GameState.start_new_game()
	GameState.flags["asked_father_more"] = true
	GameState.flags["arc_father_quiet_call_seen"] = true
	GameState.flags["arc_father_01_seen"] = true
	GameState.flags["arc_father_02_done"] = true
	for raw_spec in FATHER_MEMORY_READER_SPECS:
		GameState.flags[str((raw_spec as Dictionary)["memory"])] = true
	GameState.core_loop_v2_state = {}
	for reader_event_id in [
		"v2_father_health_signal", "v2_demo_first_bill_opening",
	]:
		var event: Dictionary = DataRegistry.find_event(reader_event_id)
		var memory_map: Dictionary = event.get(
			"description_memory_if_known", {})
		var resolved: String = story._resolved_story_description(event)
		for raw_text in memory_map.values():
			_expect(not resolved.contains(story._fmt(str(raw_text))),
				"%s V1 flags inferred typed Father prose in %s" % [
					language, reader_event_id])

	GameState.turn = 21
	GameState.core_loop_v2_state = {
		"schema": 2,
		"enabled": true,
		"relationship_stages": {"father": "opening"},
		"relationship_choice_receipts": {
			"father_quiet_call:arc_father_quiet_call:99:12": true,
		},
		"relationship_history": [],
		"player_initiated": [],
	}
	_expect(CORE_LOOP.initialize_for_run(),
		"schema-2 wrong-key Father fixture did not initialize")
	for raw_spec in FATHER_MEMORY_READER_SPECS:
		var memory_id := str((raw_spec as Dictionary)["memory"])
		_expect(not CORE_LOOP.has_relationship_memory("father", memory_id),
			"%s schema-2 flags or wrong receipt inferred %s" % [
				language, memory_id])

func _check_legacy_callback_resolution() -> void:
	var mindset_callbacks := [
		"callback_mindset_saver_echo",
		"callback_mindset_investor_echo",
		"callback_mindset_founder_echo",
	]
	var expected_callback_keys: Array = mindset_callbacks.duplicate()
	expected_callback_keys.sort()

	# Every fresh V2 run receives exactly the three contract-owned retirements.
	# They block invented saver/investor/founder memories before any legacy flag
	# can leak in from a hybrid save.
	_fresh()
	var fresh_resolutions: Dictionary = GameState.core_loop_v2_state.get(
		"legacy_callback_resolutions", {})
	var fresh_keys: Array = fresh_resolutions.keys()
	fresh_keys.sort()
	_expect(fresh_keys == expected_callback_keys,
		"fresh V2 initialization did not write exactly the three mindset "
		+ "callback retirements")
	for callback_id in mindset_callbacks:
		var fresh_receipt: Variant = fresh_resolutions.get(callback_id, {})
		_expect(fresh_receipt is Dictionary \
				and str((fresh_receipt as Dictionary).get("policy", "")) \
					== "superseded" \
				and str((fresh_receipt as Dictionary).get("scope", "")) \
					== "core_loop_v2" \
				and bool((fresh_receipt as Dictionary).get(
					"preserve_legacy", false)),
			"fresh V2 retirement receipt is incomplete for %s" % callback_id)

	# A hybrid save may still carry the old declarations and tendency seeds.
	# Initialization must retain them byte-for-byte while adding only the
	# supersession receipts that stop false callbacks.
	GameState.start_new_game()
	GameState.turn = 20
	GameState.flags["mindset_saver"] = true
	GameState.flags["mindset_investor"] = true
	GameState.flags["mindset_founder"] = true
	GameState.flags["had_first_investment"] = true
	GameState.tendency = {"career": 6, "invest": 7, "found": 8}
	GameState.tendency_realized = "invest"
	GameState.core_loop_v2_state = {
		"schema": 3,
		"enabled": true,
		"legacy_callback_resolutions": {},
	}
	var legacy_flags_before := GameState.flags.duplicate(true)
	var legacy_tendency_before := GameState.tendency.duplicate(true)
	_expect(CORE_LOOP.initialize_for_run(),
		"old enabled V2 state did not initialize its callback retirements")
	var old_v2_resolutions: Dictionary = GameState.core_loop_v2_state.get(
		"legacy_callback_resolutions", {})
	var old_v2_keys: Array = old_v2_resolutions.keys()
	old_v2_keys.sort()
	_expect(old_v2_keys == expected_callback_keys \
			and GameState.flags == legacy_flags_before \
			and GameState.tendency == legacy_tendency_before \
			and GameState.tendency_realized == "invest",
		"old V2 migration erased or rewrote its legacy mindset history")
	EventManager.event_cooldowns.clear()
	EventManager.recent_event_ids.clear()
	for callback_id in mindset_callbacks:
		_expect(not EventManager._is_event_eligible(
				DataRegistry.find_event(callback_id), true),
			"V2 retirement did not block %s despite its legacy flags" \
				% callback_id)
	var hybrid_save: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(hybrid_save)
	_expect(CORE_LOOP.initialize_for_run() \
			and GameState.flags == legacy_flags_before \
			and GameState.tendency == legacy_tendency_before \
			and GameState.tendency_realized == "invest",
		"save/load rewrote preserved mindset flags or tendencies")

	# V1 keeps all three historical flag-only callbacks exactly as authored.
	# Tightening those old semantics here would rewrite saves outside this V2
	# retirement order.
	GameState.start_new_game()
	GameState.turn = 20
	GameState.flags["mindset_saver"] = true
	GameState.flags["mindset_investor"] = true
	GameState.flags["mindset_founder"] = true
	EventManager.event_cooldowns.clear()
	EventManager.recent_event_ids.clear()
	_expect(not bool(GameState.core_loop_v2_state.get("enabled", false)) \
			and EventManager._is_event_eligible(DataRegistry.find_event(
				"callback_mindset_saver_echo"), true) \
			and EventManager._is_event_eligible(DataRegistry.find_event(
				"callback_mindset_investor_echo"), true) \
			and EventManager._is_event_eligible(DataRegistry.find_event(
				"callback_mindset_founder_echo"), true),
		"V1 flag-only mindset callbacks lost legacy eligibility")

	_fresh()
	GameState.turn = 4
	_expect(CORE_LOOP.begin_bundle("father_first_call", "schedule") \
			and CORE_LOOP.note_story_choice("arc_father_01_call", 1) \
			and CORE_LOOP.legacy_callback_is_superseded(
				"callback_told_dad_okay_echo"),
		"V2 father choice did not supersede its short legacy echo")
	GameState.flags["told_dad_okay"] = true
	EventManager.event_cooldowns.clear()
	EventManager.recent_event_ids.clear()
	var father_echo: Dictionary = DataRegistry.find_event(
		"callback_told_dad_okay_echo")
	_expect(not EventManager._is_event_eligible(father_echo, true),
		"superseded father callback remained eligible in EventManager")
	CORE_LOOP.cancel_active_bundle()

	_fresh()
	GameState.turn = 4
	GameState.flags["told_dad_okay"] = true
	EventManager.event_cooldowns.clear()
	EventManager.recent_event_ids.clear()
	_expect(EventManager._is_event_eligible(father_echo, true),
		"a legacy flag-only save lost its existing callback without a V2 receipt")

	_fresh()
	GameState.turn = 160
	_expect(CORE_LOOP.begin_bundle("hyunsu_first_meet", "schedule") \
			and CORE_LOOP.note_story_choice("arc_intro_04_hyunsu", 1) \
			and CORE_LOOP.legacy_callback_is_superseded(
				"callback_declared_dream_echo") \
			and not CORE_LOOP.legacy_callback_is_superseded(
				"callback_declared_dream_check"),
		"Hyunsu's short echo and five-year promise were not separated")
	GameState.flags["declared_dream"] = true
	EventManager.event_cooldowns.clear()
	EventManager.recent_event_ids.clear()
	_expect(EventManager._is_event_eligible(
			DataRegistry.find_event("callback_declared_dream_check"), true),
		"the five-year Hyunsu promise callback was incorrectly superseded")
	CORE_LOOP.cancel_active_bundle()

func _check_scheduled_prelude_ownership() -> void:
	_check_story_scheduled_prelude()
	_check_action_scheduled_prelude()

func _check_story_scheduled_prelude() -> void:
	_fresh()
	_install_plan(1, _month_one_schedule())
	_mark_completed("m1_mirae_application", 1)
	GameState.turn = 2
	var owner_id := "father_first_call"
	_expect(CORE_LOOP.bundle_id_for_turn() == owner_id \
			and CORE_LOOP.pending_consequence_id() \
				== "opening_interview_math",
		"story-prelude fixture did not expose its earlier application result")
	_expect(CORE_LOOP.begin_bundle(owner_id, "schedule"),
		"story scheduled owner could not begin")
	var claim := CORE_LOOP.claim_scheduled_prelude(owner_id)
	var receipt: Dictionary = claim.get("receipt", {})
	_expect(bool(claim.get("ok", false)) \
			and bool(claim.get("claimed", false)) \
			and str(receipt.get("consequence_id", "")) \
				== "opening_interview_math" \
			and str(receipt.get("scheduled_bundle", "")) == owner_id \
			and str(receipt.get("surface_kind", "")) == "story" \
			and str(receipt.get("status", "")) == "presented" \
			and receipt.get("roots", []) == [
				"arc_intro_01_meal", "v2_opening_return_math"],
		"story consequence was not attached as the schedule's prelude")
	_expect(CORE_LOOP.active_bundle_id() == owner_id \
			and CORE_LOOP.active_kind() == "schedule" \
			and not CORE_LOOP.has_completed_bundle(
				"opening_interview_math") \
			and not CORE_LOOP.turn_completed(),
		"story prelude created a second owner or completed the week")
	var repeated_claim := CORE_LOOP.claim_scheduled_prelude(owner_id)
	_expect(bool(repeated_claim.get("ok", false)) \
			and not bool(repeated_claim.get("claimed", true)) \
			and (
				GameState.core_loop_v2_state.get(
					"consequence_receipts", {}) as Dictionary
			).size() == 1 \
			and (
				GameState.core_loop_v2_state.get(
					"shown_consequences", []) as Array
			).count("opening_interview_math") == 1,
		"story prelude was claimed or receipted more than once")

	var prelude_event: Dictionary = DataRegistry.find_event(
		"arc_intro_01_meal")
	var prelude_choices: Array = prelude_event.get("choices", [])
	CORE_LOOP.prepare_story_bundle("opening_interview_math")
	_expect(prelude_choices.size() == 2 \
			and CORE_LOOP.resolved_event_roots("opening_interview_math") \
				== ["arc_intro_01_meal", "v2_opening_return_math"] \
			and CORE_LOOP.bundle("opening_interview_math").get(
				"suppress_follow_up_events", []) \
				== ["arc_intro_02_dad_call"],
		"scheduled prelude lost its adjacent interview/calculation roots or "
		+ "retired legacy-only suppression")
	for choice_index in range(prelude_choices.size()):
		_expect(str((prelude_choices[choice_index] as Dictionary).get(
				"follow_up_event", "")) == "arc_intro_02_dad_call" \
				and CORE_LOOP.story_follow_up_is_suppressed(
					"arc_intro_01_meal", choice_index,
					"arc_intro_02_dad_call"),
			"scheduled opening choice %d lost legacy follow-up suppression" \
				% choice_index)
	_expect(_apply_and_note_current_story("arc_intro_01_meal", 0) \
			and CORE_LOOP.application_status(
				"mirae_industrial_tech") == "interviewed" \
			and (
				GameState.core_loop_v2_state.get(
					"application_transition_receipts", {}) as Dictionary
			).size() == 1,
		"opening interview did not consume the submitted application exactly once")
	var presented_save: Dictionary = GameState.serialize()
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	var unrelated_slot_save: Dictionary = GameState.serialize()
	# Loading the active StoryMode slot must restore only its receipt. Loading
	# another slot afterward must not leave global DataRegistry content altered.
	GameState.start_new_game()
	GameState.load_from_dict(presented_save)
	CORE_LOOP.initialize_for_run()
	var loaded_receipt := CORE_LOOP.scheduled_prelude_receipt(owner_id)
	_expect(CORE_LOOP.active_bundle_id() == owner_id \
			and CORE_LOOP.active_kind() == "schedule" \
			and str(loaded_receipt.get("status", "")) == "presented" \
			and CORE_LOOP.story_follow_up_is_suppressed(
				"arc_intro_01_meal", 0, "arc_intro_02_dad_call") \
			and str((prelude_choices[0] as Dictionary).get(
				"follow_up_event", "")) == "arc_intro_02_dad_call",
		"mid-story save lost its owner, receipt, or follow-up suppression")
	GameState.load_from_dict(unrelated_slot_save)
	CORE_LOOP.initialize_for_run()
	_expect(not CORE_LOOP.story_follow_up_is_suppressed(
			"arc_intro_01_meal", 0, "arc_intro_02_dad_call") \
			and str((prelude_choices[0] as Dictionary).get(
				"follow_up_event", "")) == "arc_intro_02_dad_call",
		"cross-slot load leaked a V2 follow-up suppression globally")
	GameState.load_from_dict(presented_save)
	CORE_LOOP.initialize_for_run()
	CORE_LOOP.restore_story_bundle_followups()
	_expect(str((prelude_choices[0] as Dictionary).get(
			"follow_up_event", "")) == "arc_intro_02_dad_call" \
			and not CORE_LOOP.story_follow_up_is_suppressed(
				"arc_intro_01_meal", 0, "arc_intro_02_dad_call"),
		"story return did not clear its follow-up suppression receipt")
	var consumed := CORE_LOOP.consume_scheduled_prelude(owner_id)
	var consumed_again := CORE_LOOP.consume_scheduled_prelude(owner_id)
	_expect(bool(consumed.get("ok", false)) \
			and bool(consumed.get("consumed", false)) \
			and bool(consumed_again.get("ok", false)) \
			and not bool(consumed_again.get("consumed", true)) \
			and str((consumed_again.get(
				"receipt", {}) as Dictionary).get(
					"status", "")) == "consumed",
		"story prelude did not consume exactly once after save/load")
	_expect(_apply_and_note_current_story("arc_father_01_call", 0) \
			and CORE_LOOP.complete_active_bundle() == owner_id,
		"combined story did not close its scheduled owner")
	_expect(CORE_LOOP.turn_completed() \
			and CORE_LOOP.has_completed_bundle(owner_id) \
			and not CORE_LOOP.has_completed_bundle(
				"opening_interview_math") \
			and CORE_LOOP.active_bundle_id().is_empty() \
			and CORE_LOOP.pending_consequence_id().is_empty() \
			and not CORE_LOOP.begin_bundle(owner_id, "schedule"),
		"closed story schedule resurrected its prelude or active owner")
	var closed_save: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(closed_save)
	CORE_LOOP.initialize_for_run()
	_expect(CORE_LOOP.active_bundle_id().is_empty() \
			and CORE_LOOP.pending_consequence_id().is_empty() \
			and str(CORE_LOOP.scheduled_prelude_receipt(
				owner_id, 2).get("status", "")) == "consumed",
		"closed story-prelude state did not survive save/load")

func _check_application_transition_chain() -> void:
	_fresh()
	_install_plan(2, _month_two_schedule())
	_mark_completed("m1_mirae_application", 1)
	var state: Dictionary = GameState.core_loop_v2_state
	state["application_statuses"]["mirae_industrial_tech"] = "interviewed"
	GameState.core_loop_v2_state = state
	GameState.turn = 5
	var owner_id := "m2_seorin_application"
	_expect(CORE_LOOP.pending_consequence_id() == "m2_mirae_result_message" \
			and CORE_LOOP.begin_bundle(owner_id, "schedule"),
		"Mirae result did not attach to the first Month Two commitment")
	var claim := CORE_LOOP.claim_scheduled_prelude(owner_id)
	_expect(bool(claim.get("claimed", false)) \
			and not bool(CORE_LOOP.consume_scheduled_prelude(
				owner_id).get("ok", false)),
		"application consequence consumed before its visible choice")
	_expect(_apply_and_note_current_story("v2_mirae_result_message", 0) \
			and CORE_LOOP.application_status(
				"mirae_industrial_tech") == "no_offer",
		"Mirae result did not transition interviewed to no_offer")
	var transition_count := (
		GameState.core_loop_v2_state.get(
			"application_transition_receipts", {}) as Dictionary
	).size()
	_expect(CORE_LOOP.note_story_choice("v2_mirae_result_message", 0) \
			and (
				GameState.core_loop_v2_state.get(
					"application_transition_receipts", {}) as Dictionary
			).size() == transition_count,
		"replaying the Mirae result created another transition receipt")
	var saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	CORE_LOOP.initialize_for_run()
	_expect(CORE_LOOP.application_status(
			"mirae_industrial_tech") == "no_offer" \
			and bool(CORE_LOOP.consume_scheduled_prelude(
				owner_id).get("ok", false)),
		"Mirae transition or its consequence ownership failed save/load")
	CORE_LOOP.cancel_active_bundle()

	_fresh()
	_install_plan(3, _month_three_schedule())
	_expect(_complete_typed_application_action(
		"m2_seorin_application", 5),
		"Seorin result fixture could not produce its typed application receipt")
	GameState.turn = 9
	GameState.month = 3
	GameState.week_of_month = 1
	owner_id = "m3_hanbit_application"
	_expect(CORE_LOOP.pending_consequence_id() == "m3_seorin_result_message" \
			and CORE_LOOP.begin_bundle(owner_id, "schedule") \
			and bool(CORE_LOOP.claim_scheduled_prelude(
				owner_id).get("claimed", false)) \
			and _apply_and_note_current_story(
				"v2_seorin_result_message", 0) \
			and CORE_LOOP.application_status(
				"seorin_contract_2026q1") == "no_offer" \
			and bool(CORE_LOOP.consume_scheduled_prelude(
				owner_id).get("ok", false)),
		"Seorin submitted application did not close through its Week Nine result")
	CORE_LOOP.cancel_active_bundle()

func _check_action_scheduled_prelude() -> void:
	_fresh()
	_install_plan(2, _month_two_schedule())
	_mark_completed("first_temptation_boss", 4)
	var boss_state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	boss_state["active_bundle"] = "first_temptation_boss"
	boss_state["active_kind"] = "schedule"
	boss_state["active_turn"] = 4
	GameState.core_loop_v2_state = boss_state
	GameState.turn = 4
	_expect(_apply_and_note_current_story("arc_temptation_01", 0),
		"action-prelude fixture could not preserve its exact W4 choice")
	CORE_LOOP.cancel_active_bundle()
	GameState.turn = 8
	var owner_id := "m2_sleep_debt_sunday"
	_expect(CORE_LOOP.bundle_id_for_turn() == owner_id \
			and CORE_LOOP.pending_consequence_id() \
				== "temptation_consequence",
		"action-prelude fixture did not expose the one-month boss fallout")
	_expect(CORE_LOOP.begin_bundle(owner_id, "schedule"),
		"action scheduled owner could not begin")
	var claim := CORE_LOOP.claim_scheduled_prelude(owner_id)
	var receipt: Dictionary = claim.get("receipt", {})
	_expect(bool(claim.get("ok", false)) \
			and bool(claim.get("claimed", false)) \
			and str(receipt.get("consequence_id", "")) \
				== "temptation_consequence" \
			and str(receipt.get("surface_kind", "")) == "action" \
			and CORE_LOOP.active_bundle_id() == owner_id \
			and CORE_LOOP.active_kind() == "schedule",
		"action consequence became a separate foreground owner")
	var presented_save: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(presented_save)
	CORE_LOOP.initialize_for_run()
	_expect(str(CORE_LOOP.scheduled_prelude_receipt(
			owner_id).get("status", "")) == "presented",
		"mid-action-prelude save lost its presented receipt")
	var before_unread_consume: Dictionary = GameState.serialize()
	var unread_consume := CORE_LOOP.consume_scheduled_prelude(owner_id)
	_expect(not bool(unread_consume.get("ok", true)) \
			and str(unread_consume.get("error", "")) \
				== "missing_prelude_story_receipt" \
			and GameState.serialize() == before_unread_consume,
		"action prelude consumed before its temptation roots were read")
	for root_id in CORE_LOOP.resolved_event_roots("temptation_consequence"):
		var event: Dictionary = DataRegistry.find_event(root_id)
		var choices: Array = event.get("choices", []) \
			if event.get("choices", []) is Array else []
		_expect(not choices.is_empty() \
				and GameState.apply_choice(event, choices[0] as Dictionary) \
				and CORE_LOOP.note_story_choice(root_id, 0),
			"action prelude root %s did not produce its exact story receipt" \
				% root_id)
	var consumed := CORE_LOOP.consume_scheduled_prelude(owner_id)
	_expect(bool(consumed.get("ok", false)) \
			and bool(consumed.get("consumed", false)) \
			and not bool(CORE_LOOP.consume_scheduled_prelude(
				owner_id).get("consumed", true)),
		"action prelude did not consume exactly once")
	_expect(GameState.arm_weekly_commitment({
			"turn": 8,
			"pressure_id": owner_id,
			"pressure_family": "recovery",
			"choice_id": "rest",
			"forgone_ids": [],
		}), "action owner could not arm after its prelude")
	var transaction := GameState.finalize_weekly_effect_action(
		"rest", {}, "human", "home", "", {
			"execution": "rest",
		})
	_expect(bool(transaction.get("ok", false)) \
			and CORE_LOOP.action_result_ready() \
			and CORE_LOOP.complete_active_bundle() == owner_id \
			and CORE_LOOP.complete_active_bundle().is_empty(),
		"action owner did not finalize exactly once after its prelude")
	_expect(CORE_LOOP.turn_completed() \
			and CORE_LOOP.has_completed_bundle(owner_id) \
			and not CORE_LOOP.has_completed_bundle(
				"temptation_consequence") \
			and CORE_LOOP.active_bundle_id().is_empty() \
			and CORE_LOOP.pending_consequence_id().is_empty() \
			and not CORE_LOOP.begin_bundle(owner_id, "schedule") \
			and (
				GameState.core_loop_v2_state.get(
					"consequence_receipts", {}) as Dictionary
			).size() == 1,
		"closed action schedule replayed or promoted its prelude")

func _check_action_receipt_once() -> void:
	_fresh()
	GameState.turn = 9
	CORE_LOOP.begin_bundle("m3_hanbit_application", "schedule")
	_expect(not CORE_LOOP.note_action_commitment({"choice_id": "apply"}),
		"schema-3 action accepted a non-finalized commitment")
	var config: Dictionary = CORE_LOOP.bundle(
		"m3_hanbit_application").get("action_config", {})
	var application_id := str(config.get("application_id", ""))
	var record := {
		"turn": 9,
		"pressure_id": "m3_hanbit_application",
		"choice_id": "apply",
		"actual_action_id": "apply",
		"outcome": {"money": 0.0},
		"details": {
			"execution": "application",
			"application_id": application_id,
			"status": "submitted",
			"job_id": str(config.get("job_id", "")),
		},
	}
	var wrong_pressure := record.duplicate(true)
	wrong_pressure["pressure_id"] = "m3_inventory_shift"
	_expect(not CORE_LOOP.note_action_commitment(wrong_pressure),
		"schema-3 action accepted another bundle's finalized commitment")
	var wrong_actual := record.duplicate(true)
	wrong_actual["actual_action_id"] = "gamble_casino"
	_expect(not CORE_LOOP.note_action_commitment(wrong_actual),
		"schema-3 action accepted an incompatible actual action")
	_expect(CORE_LOOP.note_action_commitment(record),
		"finalized Hanbit commitment did not create an action receipt")
	var receipt := CORE_LOOP.action_receipt("m3_hanbit_application")
	_expect(str(receipt.get("action_id", "")) == "apply" \
			and str(receipt.get("application_status", "")) == "submitted" \
			and str((receipt.get("config", {}) as Dictionary).get(
				"execution", "")) == "application" \
			and str((receipt.get("result_details", {}) as Dictionary).get(
				"job_id", "")) == str(config.get("job_id", "")),
		"action receipt lost its action, config, or finalized details")
	var receipt_count := (
		GameState.core_loop_v2_state.get("action_receipts", {}) as Dictionary
	).size()
	_expect(CORE_LOOP.note_action_commitment(record) \
			and (
				GameState.core_loop_v2_state.get(
					"action_receipts", {}) as Dictionary
			).size() == receipt_count,
		"duplicate finalization created a second action receipt")
	_expect(CORE_LOOP.application_status(application_id) == "submitted",
		"application-status helper did not read the action receipt")
	_expect(CORE_LOOP._bundle_requirement_met({
		"prerequisites": {"all": [{
			"kind": "application_status",
			"application_id": application_id,
			"status": "submitted",
		}]},
	}), "typed application-status predicate ignored the receipt")
	_expect(CORE_LOOP.complete_active_bundle() \
			== "m3_hanbit_application",
		"action receipt did not authorize scheduled completion")
	var saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	CORE_LOOP.initialize_for_run()
	_expect(CORE_LOOP.application_status(application_id) == "submitted" \
			and not CORE_LOOP.action_receipt(
				"m3_hanbit_application").is_empty(),
		"action receipt did not survive save/load")

func _check_activity_task_contract() -> void:
	var bundle_id := "m3_inventory_shift"
	var config := CORE_LOOP.activity_task_config(bundle_id)
	var requirements: Array = config.get("requirements", []) \
		if config.get("requirements", []) is Array else []
	var requirement_ids: Array = config.get("requirement_ids", []) \
		if config.get("requirement_ids", []) is Array else []
	var outcomes: Dictionary = config.get("outcomes", {}) \
		if config.get("outcomes", {}) is Dictionary else {}
	var overreach: Dictionary = config.get("overreach", {}) \
		if config.get("overreach", {}) is Dictionary else {}
	var legacy: Dictionary = config.get("legacy_instant_effect", {}) \
		if config.get("legacy_instant_effect", {}) is Dictionary else {}
	var expected_requirements := [
		"confirm_actual_count",
		"trace_discrepancy",
		"write_handoff_note",
	]
	var expected_outcomes := {
		"confirm_actual_count|trace_discrepancy": {
			"outcome_id": "inventory_trace_before_handoff",
			"effects": {"money": 360_000.0, "health": -6.0, "mental": -2.0},
		},
		"confirm_actual_count|write_handoff_note": {
			"outcome_id": "inventory_untraced_handoff",
			"effects": {"money": 360_000.0, "health": -4.0, "mental": -3.0},
		},
		"trace_discrepancy|write_handoff_note": {
			"outcome_id": "inventory_unconfirmed_handoff",
			"effects": {"money": 360_000.0, "health": -2.0, "mental": -4.0},
		},
	}
	_expect(str(config.get("execution", "")) == "activity_task" \
			and str(config.get("task_id", "")) == "inventory_discrepancy" \
			and not str(config.get("task_title_ko", "")).is_empty() \
			and not str(config.get("task_title_en", "")).is_empty() \
			and int(config.get("normal_steps", 0)) == 2 \
			and str(config.get("axis", "")) == "money" \
			and str(config.get("place_id", "")) == "work" \
			and requirement_ids == expected_requirements \
			and requirements.size() == 3 \
			and outcomes.size() == 3 \
			and config.get("effects", {}) \
				== {"money": 360_000.0, "health": -4.0, "mental": -3.0},
		"inventory activity task lost its 3-requirement, 2-step, or legacy baseline contract")
	_expect(str(legacy.get("outcome_id", "")) \
			== "inventory_legacy_count_marked" \
			and legacy.get("requirements", []) == ["confirm_actual_count"] \
			and legacy.get("effects", {}) \
				== {"money": 360_000.0, "health": -4.0, "mental": -3.0},
		"inventory activity task invented a modern pair for a legacy recount")
	var no_legacy_config := config.duplicate(true)
	no_legacy_config.erase("legacy_instant_effect")
	var normalized_no_legacy := CORE_LOOP._normalized_activity_task_config(
		no_legacy_config)
	_expect(not normalized_no_legacy.is_empty() \
			and not normalized_no_legacy.has("legacy_instant_effect"),
		"generic activity-task configs were coupled to an unrelated old save")
	var localized_requirement_count := 0
	var scene_slots: Array = []
	for raw_requirement in requirements:
		if not raw_requirement is Dictionary:
			continue
		var requirement: Dictionary = raw_requirement
		if not str(requirement.get("label_ko", "")).is_empty() \
				and not str(requirement.get("label_en", "")).is_empty() \
				and not str(requirement.get("detail_ko", "")).is_empty() \
				and not str(requirement.get("detail_en", "")).is_empty() \
				and not str(requirement.get("feedback_ko", "")).is_empty() \
				and not str(requirement.get("feedback_en", "")).is_empty():
			localized_requirement_count += 1
		scene_slots.append(str(requirement.get("scene_slot", "")))
	_expect(localized_requirement_count == 3 \
			and scene_slots == ["left", "center", "right"],
		"inventory activity task lost localized copy or its three physical scene slots")
	var observed_outcomes: Dictionary = {}
	for raw_outcome in outcomes.values():
		if not raw_outcome is Dictionary:
			continue
		var outcome: Dictionary = raw_outcome
		var pair: Array = (outcome.get("requirements", []) as Array).duplicate()
		pair.sort()
		observed_outcomes["|".join(pair)] = {
			"outcome_id": str(outcome.get("outcome_id", "")),
			"effects": (outcome.get("effects", {}) as Dictionary).duplicate(true),
		}
	_expect(observed_outcomes == expected_outcomes \
			and str(overreach.get("outcome_id", "")) \
				== "inventory_all_finished" \
			and overreach.get("requirements", []) == expected_requirements \
			and overreach.get("effects", {}) \
				== {"money": 360_000.0, "health": -6.0, "mental": -3.0},
		"inventory activity task lost one of its three pairs or exact overreach result")

	# Invalid counts and duplicate/unknown inputs never touch public stats, AP,
	# or the finalized weekly ledger.
	_expect(_begin_inventory_activity_task(),
		"activity-task invalid-input fixture could not begin")
	var untouched := _activity_task_public_snapshot()
	_expect(not bool(CORE_LOOP.resolve_activity_task(false).get("ok", true)),
		"activity task accepted zero requirements as a normal result")
	_expect(bool(CORE_LOOP.update_activity_task_requirements(
		[expected_requirements[0]]).get("ok", false)) \
			and not bool(CORE_LOOP.resolve_activity_task(false).get("ok", true)),
		"activity task accepted one requirement as a normal result")
	_expect(not bool(CORE_LOOP.select_activity_task_requirement(
		expected_requirements[0]).get("ok", true)),
		"activity task accepted a duplicate requirement")
	_expect(not bool(CORE_LOOP.update_activity_task_requirements(
		expected_requirements).get("ok", true)),
		"activity task accepted all three requirements as a normal selection")
	_expect(not bool(CORE_LOOP.select_activity_task_requirement(
		"qa_unknown_requirement").get("ok", true)) \
			and _activity_task_public_snapshot() == untouched,
		"invalid activity-task input changed public stats, AP, or the weekly ledger")
	CORE_LOOP.cancel_active_bundle()

	# Every order of every legal pair must reach the matching outcome while
	# retaining the order in the single receipt. No click or resolution applies
	# effects before the weekly transaction.
	var selection_orders := [
		[expected_requirements[0], expected_requirements[1]],
		[expected_requirements[1], expected_requirements[0]],
		[expected_requirements[0], expected_requirements[2]],
		[expected_requirements[2], expected_requirements[0]],
		[expected_requirements[1], expected_requirements[2]],
		[expected_requirements[2], expected_requirements[1]],
	]
	for raw_selection in selection_orders:
		var selection: Array = raw_selection
		_expect(_begin_inventory_activity_task(),
			"activity-task pair fixture could not begin")
		var before_selection := _activity_task_public_snapshot()
		var update := CORE_LOOP.update_activity_task_requirements(selection)
		var resolution := CORE_LOOP.resolve_activity_task(false)
		var signature: Array = selection.duplicate()
		signature.sort()
		var expected: Dictionary = expected_outcomes.get(
			"|".join(signature), {})
		_expect(bool(update.get("ok", false)) \
				and int(update.get("remaining_steps", -1)) == 0 \
				and bool(resolution.get("ok", false)) \
				and str(resolution.get("outcome_id", "")) \
					== str(expected.get("outcome_id", "")) \
				and resolution.get("selected_requirements", []) == selection \
				and resolution.get("effects", {}) == expected.get("effects", {}) \
				and not bool(resolution.get("overreached", true)) \
				and _activity_task_public_snapshot() == before_selection,
			"activity-task pair/order resolution drifted for %s" % str(selection))
		var transaction := _finalize_inventory_activity_task(resolution)
		var receipt := CORE_LOOP.activity_task_receipt(bundle_id)
		var skipped: Array = resolution.get("skipped_requirements", [])
		var skipped_id := str(skipped[0]) if skipped.size() == 1 else ""
		_expect(bool(transaction.get("ok", false)) \
				and receipt.get("selected_requirements", []) == selection \
				and receipt.get("skipped_requirements", []) == skipped \
				and CORE_LOOP.activity_task_receipt_outcome_id(bundle_id) \
					== str(expected.get("outcome_id", "")) \
				and CORE_LOOP.activity_task_receipt_has_requirement(
					bundle_id, str(selection[0])) \
				and CORE_LOOP.activity_task_receipt_has_requirement(
					bundle_id, str(selection[1])) \
				and not CORE_LOOP.activity_task_receipt_has_requirement(
					bundle_id, skipped_id) \
				and CORE_LOOP.activity_task_session().is_empty(),
			"activity-task final receipt lost its order, skipped work, or one-time session boundary")
		_check_activity_task_story_reader(
			str(expected.get("outcome_id", "")))

	# The explicit overreach starts from two normal selections, appends the one
	# remaining task, and shows/applies its own exact final effects.
	_expect(_begin_inventory_activity_task(),
		"activity-task overreach fixture could not begin")
	var overreach_before := _activity_task_public_snapshot()
	CORE_LOOP.update_activity_task_requirements([
		expected_requirements[1], expected_requirements[2]])
	var overreach_resolution := CORE_LOOP.resolve_activity_task(true)
	_expect(bool(overreach_resolution.get("ok", false)) \
			and bool(overreach_resolution.get("overreached", false)) \
			and str(overreach_resolution.get("outcome_id", "")) \
				== "inventory_all_finished" \
			and overreach_resolution.get("selected_requirements", []) == [
				expected_requirements[1], expected_requirements[2],
				expected_requirements[0]] \
			and (overreach_resolution.get(
				"skipped_requirements", []) as Array).is_empty() \
			and overreach_resolution.get("effects", {}) \
				== {"money": 360_000.0, "health": -6.0, "mental": -3.0} \
			and _activity_task_public_snapshot() == overreach_before,
		"activity-task overreach lost its all-three order, exact effects, or no-effect boundary")
	var overreach_transaction := _finalize_inventory_activity_task(
		overreach_resolution)
	var overreach_after := _activity_task_public_snapshot()
	var repeated_transaction := _finalize_inventory_activity_task(
		overreach_resolution)
	_expect(bool(overreach_transaction.get("ok", false)) \
			and not bool(repeated_transaction.get("ok", true)) \
			and _activity_task_public_snapshot() == overreach_after \
			and GameState.weekly_commitments.size() == 1 \
			and CORE_LOOP.activity_task_receipt_outcome_id(bundle_id) \
				== "inventory_all_finished",
		"activity-task confirmation applied effects or the weekly commitment more than once")
	_check_activity_task_story_reader("inventory_all_finished")

	# A selecting and a resolved session must both survive normalization. Only
	# finalization clears the transient session and creates the durable receipt.
	_expect(_begin_inventory_activity_task(),
		"activity-task save fixture could not begin")
	var save_before := _activity_task_public_snapshot()
	CORE_LOOP.select_activity_task_requirement(expected_requirements[0])
	var selecting_save: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(selecting_save)
	CORE_LOOP.initialize_for_run()
	var resumed := CORE_LOOP.begin_or_resume_activity_task(bundle_id)
	var selecting_session: Dictionary = resumed.get("session", {})
	_expect(bool(resumed.get("ok", false)) \
			and bool(resumed.get("resumed", false)) \
			and selecting_session.get("selected_requirements", []) \
				== [expected_requirements[0]] \
			and int(selecting_session.get("remaining_steps", -1)) == 1 \
			and _activity_task_public_snapshot() == save_before,
		"activity-task selecting session did not survive save/load exactly")
	CORE_LOOP.select_activity_task_requirement(expected_requirements[2])
	var saved_resolution := CORE_LOOP.resolve_activity_task(false)
	var resolved_save: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(resolved_save)
	CORE_LOOP.initialize_for_run()
	var resolved_session := CORE_LOOP.activity_task_session()
	var resumed_resolution := CORE_LOOP.begin_or_resume_activity_task(bundle_id)
	_expect(str(resolved_session.get("phase", "")) == "resolved" \
			and str(resolved_session.get("outcome_id", "")) \
				== "inventory_untraced_handoff" \
			and resolved_session.get("resolution", {}) == saved_resolution \
			and bool(resumed_resolution.get("ok", false)) \
			and bool(resumed_resolution.get("resumed", false)) \
			and (resumed_resolution.get("session", {}) as Dictionary).get(
				"resolution", {}) == saved_resolution \
			and CORE_LOOP.action_receipt(bundle_id).is_empty() \
			and _activity_task_public_snapshot() == save_before,
		"activity-task resolved session invented effects/receipt or changed across save/load")
	var saved_transaction := _finalize_inventory_activity_task(
		resolved_session.get("resolution", {}) as Dictionary)
	var finalized_save: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(finalized_save)
	CORE_LOOP.initialize_for_run()
	_expect(bool(saved_transaction.get("ok", false)) \
			and CORE_LOOP.activity_task_session().is_empty() \
			and CORE_LOOP.activity_task_receipt_outcome_id(bundle_id) \
				== "inventory_untraced_handoff" \
			and GameState.weekly_commitments.size() == 1,
		"finalized activity-task save lost its single durable outcome receipt")

func _check_activity_task_long_horizon_envelope() -> void:
	# Only the hired release route actually schedules this optional Month-Three
	# shift. Build that real 1→24 route once per outcome, then carry its exact
	# snapshot through the production monthly-pressure transaction. The later
	# policy deliberately spends a stat-only recovery week at a low threshold:
	# this is a conservative survival envelope, not invented Year 2–5 content.
	var outcome_ids := [
		"inventory_trace_before_handoff",
		"inventory_untraced_handoff",
		"inventory_unconfirmed_handoff",
		"inventory_all_finished",
	]
	var expected_cash_by_horizon: Dictionary = {}
	for outcome_id in outcome_ids:
		var route := FULL_ROUTE_CHECK.build_full_route_snapshot(
			"clean_hired_recovery_high", outcome_id)
		_expect(bool(route.get("ok", false)),
			"activity-task %s failed its real Week-1→24 route: %s" % [
				outcome_id, str(route.get("errors", []))])
		if not bool(route.get("ok", false)):
			continue
		var snapshot: Dictionary = route.get("snapshot", {})
		GameState.load_from_dict(snapshot)
		CORE_LOOP.initialize_for_run()
		var checkpoints := {
			"24": {
				"money": float(GameState.money),
				"health": int(GameState.health),
				"mental": int(GameState.mental),
			},
		}
		_expect(int(GameState.turn) == 25 \
				and is_equal_approx(float(GameState.money), 3_580_500.0) \
				and int(GameState.health) > 0 \
				and int(GameState.mental) > 0 \
				and CORE_LOOP.activity_task_receipt_outcome_id(
					"m3_inventory_shift") == outcome_id,
			"activity-task %s broke its exact Week-24 cash/survival/receipt boundary"
				% outcome_id)
		var continuation := _continue_activity_task_horizon(
			snapshot, checkpoints)
		_expect(bool(continuation.get("ok", false)),
			"activity-task %s failed its conservative Week-25→240 envelope: %s"
				% [outcome_id, str(continuation)])
		if not bool(continuation.get("ok", false)):
			continue
		checkpoints = continuation.get("checkpoints", {})
		var cash_by_horizon := {
			"24": float((checkpoints.get("24", {}) as Dictionary).get(
				"money", NAN)),
			"48": float((checkpoints.get("48", {}) as Dictionary).get(
				"money", NAN)),
			"240": float((checkpoints.get("240", {}) as Dictionary).get(
				"money", NAN)),
		}
		if expected_cash_by_horizon.is_empty():
			expected_cash_by_horizon = cash_by_horizon.duplicate(true)
		_expect(cash_by_horizon == expected_cash_by_horizon \
				and float(cash_by_horizon["24"]) == 3_580_500.0 \
				and float(cash_by_horizon["48"]) > 0.0 \
				and float(cash_by_horizon["240"]) > 0.0,
			"activity-task %s changed W24/W48/W240 cash against its equal-pay baseline: %s"
				% [outcome_id, str(cash_by_horizon)])

func _continue_activity_task_horizon(
		snapshot: Dictionary,
		initial_checkpoints: Dictionary) -> Dictionary:
	GameState.load_from_dict(snapshot)
	CORE_LOOP.initialize_for_run()
	var checkpoints: Dictionary = initial_checkpoints.duplicate(true)
	var floors := {
		"health": int(GameState.health),
		"mental": int(GameState.mental),
	}
	for expected_week in range(25, 241):
		if int(GameState.turn) != expected_week:
			return {"ok": false, "error": "calendar_drift",
				"expected_week": expected_week, "turn": int(GameState.turn)}
		# Same recovery unit used by the five-year policy probe. Acting before a
		# fatal threshold makes this stricter than relying on a later story rescue.
		if int(GameState.health) <= 12 or int(GameState.mental) <= 35:
			GameState.modify_stat("health", 5)
			GameState.modify_stat("mental", 10)
		if expected_week % 4 == 0:
			GameState.apply_monthly_pressure()
		floors["health"] = mini(
			int(floors["health"]), int(GameState.health))
		floors["mental"] = mini(
			int(floors["mental"]), int(GameState.mental))
		if int(GameState.health) <= 0 or int(GameState.mental) <= 0:
			return {"ok": false, "error": "fatal_stat",
				"week": expected_week, "floors": floors}
		if expected_week in [48, 240]:
			checkpoints[str(expected_week)] = {
				"money": float(GameState.money),
				"health": int(GameState.health),
				"mental": int(GameState.mental),
			}
		if expected_week < 240:
			GameState.advance_calendar()
	return {"ok": true, "checkpoints": checkpoints, "floors": floors}

func _begin_inventory_activity_task() -> bool:
	_fresh()
	GameState.turn = 10
	var bundle_id := "m3_inventory_shift"
	var scene_bundle := CORE_LOOP.bundle(bundle_id)
	var action_id := str(scene_bundle.get("action_id", ""))
	if not CORE_LOOP.begin_bundle(bundle_id, "schedule") \
			or not GameState.arm_weekly_commitment({
				"turn": 10,
				"pressure_id": bundle_id,
				"pressure_family": "livelihood",
				"choice_id": action_id,
				"forgone_ids": [],
			}):
		return false
	return bool(CORE_LOOP.begin_or_resume_activity_task(
		bundle_id).get("ok", false))

func _finalize_inventory_activity_task(resolution: Dictionary) -> Dictionary:
	var details := resolution.duplicate(true)
	details.erase("ok")
	var effects: Dictionary = (
		(details.get("effects", {}) as Dictionary).duplicate(true)
		if details.get("effects", {}) is Dictionary else {}
	)
	return GameState.finalize_weekly_effect_action(
		"side_shift", effects,
		str(details.get("axis", "money")),
		str(details.get("place_id", "work")), "", details)

func _activity_task_public_snapshot() -> Dictionary:
	return {
		"money": float(GameState.money),
		"health": int(GameState.health),
		"mental": int(GameState.mental),
		"action_points": int(GameState.action_points),
		"weekly_commitments": GameState.weekly_commitments.duplicate(true),
		"axis": GameState.action_axis_this_week.duplicate(true),
	}

func _check_activity_task_story_reader(outcome_id: String) -> void:
	var story = STORY_MODE.new()
	var condition_key := "activity_task_outcome:m3_inventory_shift:%s" \
		% outcome_id
	for event_id in [
		"v2_inventory_count_nights", "v2_logistics_class_session"]:
		var event: Dictionary = DataRegistry.find_event(event_id)
		var variants: Dictionary = event.get(
			"description_memory_if_known", {})
		var expected_copy := str(variants.get(condition_key, ""))
		var resolved_copy := story._resolved_story_description(event)
		_expect(not expected_copy.is_empty() \
				and resolved_copy.contains(story._fmt(expected_copy)),
			"%s did not read activity-task outcome %s" % [
				event_id, outcome_id])
	story.free()

func _check_activity_task_story_reader_absent(outcome_id: String) -> void:
	var story = STORY_MODE.new()
	var condition_key := "activity_task_outcome:m3_inventory_shift:%s" \
		% outcome_id
	for event_id in [
		"v2_inventory_count_nights", "v2_logistics_class_session"]:
		var event: Dictionary = DataRegistry.find_event(event_id)
		var variants: Dictionary = event.get(
			"description_memory_if_known", {})
		var guarded_copy := str(variants.get(condition_key, ""))
		var resolved_copy := story._resolved_story_description(event)
		_expect(not guarded_copy.is_empty() \
				and not resolved_copy.contains(story._fmt(guarded_copy)),
			"%s read rejected partial schema-2 activity outcome %s" % [
				event_id, outcome_id])
	story.free()

func _check_atomic_action_roundtrips() -> void:
	_check_atomic_action_roundtrip("m3_hanbit_application", 9)
	_check_atomic_action_roundtrip("m3_inventory_shift", 10)
	_check_atomic_action_roundtrip("m3_empty_saturday", 11)
	_check_atomic_action_roundtrip("m3_room_ledger", 12)
	_check_atomic_action_roundtrip("m3_library_job_board", 12)

func _check_atomic_action_roundtrip(
		bundle_id: String, action_turn: int) -> void:
	_fresh()
	GameState.turn = action_turn
	var scene_bundle := CORE_LOOP.bundle(bundle_id)
	var action_id := str(scene_bundle.get("action_id", ""))
	var expected_story_owned := bundle_id in [
		"m3_inventory_shift", "m3_room_ledger"]
	_expect(CORE_LOOP.story_owns_action_result(bundle_id) \
			== expected_story_owned,
		"%s did not preserve the exact Month-Three story-owned opt-in"
			% bundle_id)
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
	var money_before := float(GameState.money)
	var health_before := int(GameState.health)
	var mental_before := int(GameState.mental)
	_expect(CORE_LOOP.begin_bundle(bundle_id, "schedule") \
			and CORE_LOOP.story_owns_action_result() \
				== expected_story_owned \
			and GameState.arm_weekly_commitment({
				"turn": action_turn,
				"pressure_id": bundle_id,
				"pressure_family": "qa",
				"choice_id": action_id,
				"forgone_ids": [],
			}), "%s atomic fixture could not arm" % bundle_id)
	if execution == "activity_task":
		var activity_begin := CORE_LOOP.begin_or_resume_activity_task(bundle_id)
		var requirement_ids: Array = config.get("requirement_ids", []) \
			if config.get("requirement_ids", []) is Array else []
		if requirement_ids.is_empty():
			requirement_ids = CORE_LOOP.activity_task_config(
				bundle_id).get("requirement_ids", [])
		var activity_update := CORE_LOOP.update_activity_task_requirements(
			requirement_ids.slice(0, int(config.get("normal_steps", 2))))
		var activity_resolution := CORE_LOOP.resolve_activity_task(false)
		_expect(bool(activity_begin.get("ok", false)) \
				and bool(activity_update.get("ok", false)) \
				and bool(activity_resolution.get("ok", false)),
			"%s activity task could not resolve before its atomic transaction"
				% bundle_id)
		details = activity_resolution.duplicate(true)
		details.erase("ok")
		effects = (details.get("effects", {}) as Dictionary).duplicate(true)
		axis = str(details.get("axis", axis))
		place_id = str(details.get("place_id", place_id))
	var transaction := GameState.finalize_weekly_effect_action(
		action_id, effects, axis, place_id, "", details)
	_expect(bool(transaction.get("ok", false)),
		"%s atomic transaction failed: %s" % [
			bundle_id, str(transaction.get("error", "unknown"))])
	_expect(GameState.action_points == 0 \
			and GameState.weekly_commitments.size() == 1 \
			and int(GameState.action_axis_this_week.get(axis, 0)) == 1 \
			and CORE_LOOP.action_result_ready() \
			and not CORE_LOOP.action_receipt(bundle_id).is_empty(),
		"%s did not atomically finalize AP, axis, commitment, and receipt" \
			% bundle_id)
	if execution in ["instant_effect", "activity_task"]:
		var finalized_record := GameState.get_weekly_commitment_for_turn(
			action_turn)
		var finalized_details: Dictionary = finalized_record.get("details", {})
		_expect(str(finalized_details.get("axis", "")) == axis \
				and str(finalized_details.get("place_id", "")) == place_id,
			"%s lost its authored action axis or place" % bundle_id)
	_expect(is_equal_approx(
			float(GameState.money),
			money_before + float(effects.get("money", 0.0))) \
			and int(GameState.health) == clampi(
				health_before + int(effects.get("health", 0)), 0, 100) \
			and int(GameState.mental) == clampi(
				mental_before + int(effects.get("mental", 0)), 0, 100),
		"%s authored effects were not applied exactly once" % bundle_id)

	var saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	CORE_LOOP.initialize_for_run()
	var loaded_state: Dictionary = GameState.serialize().duplicate(true)
	var recovered := CORE_LOOP.recover_action_result()
	var recovered_again := CORE_LOOP.recover_action_result()
	_expect(not recovered.is_empty() and recovered == recovered_again \
			and GameState.serialize() == loaded_state,
		"%s result recovery changed state or lost its durable receipt" \
			% bundle_id)
	_expect(float(GameState.money) == float(saved.get("money", 0.0)) \
			and int(GameState.health) == int(saved.get("health", 0)) \
			and int(GameState.mental) == int(saved.get("mental", 0)) \
			and GameState.action_points == 0 \
			and GameState.weekly_commitments.size() == 1,
		"%s save/load reapplied an effect, AP, or weekly commitment" \
			% bundle_id)
	_expect(_complete_action_or_story_bundle(bundle_id) \
			and CORE_LOOP.turn_completed(action_turn) \
			and not CORE_LOOP.action_result_ready(),
		"%s Continue/story bridge did not complete the bundle exactly once" \
			% bundle_id)

func _complete_action_or_story_bundle(bundle_id: String) -> bool:
	if CORE_LOOP.action_story_stage(bundle_id) == "story":
		# A dual-surface livelihood action must remain incomplete until the
		# result is acknowledged and its authored follow-up choice is recorded.
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

func _check_partial_schema_two_action_result_rejected() -> void:
	_fresh()
	GameState.turn = 10
	var bundle_id := "m3_inventory_shift"
	var scene_bundle := CORE_LOOP.bundle(bundle_id)
	var config: Dictionary = scene_bundle.get("action_config", {})
	var effects: Dictionary = (
		(config.get("effects", {}) as Dictionary).duplicate(true)
		if config.get("effects", {}) is Dictionary else {}
	)
	_expect(CORE_LOOP.begin_bundle(bundle_id, "schedule") \
			and GameState.arm_weekly_commitment({
				"turn": 10,
				"pressure_id": bundle_id,
				"pressure_family": "qa",
				"choice_id": "side_shift",
				"forgone_ids": [],
			}), "schema-2 action fixture could not arm")
	var transaction := GameState.finalize_weekly_effect_action(
		"side_shift", effects, "money", "work", "", {
			"execution": "instant_effect",
			"effects": effects.duplicate(true),
		})
	_expect(bool(transaction.get("ok", false)) \
			and CORE_LOOP.action_result_ready(),
		"schema-2 action fixture could not finalize")
	var money_after := float(GameState.money)
	var health_after := int(GameState.health)
	var mental_after := int(GameState.mental)
	var old_state: Dictionary = GameState.core_loop_v2_state
	old_state["schema"] = 2
	old_state.erase("action_receipts")
	old_state.erase("application_statuses")
	GameState.core_loop_v2_state = old_state
	var old_save: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(old_save)
	CORE_LOOP.initialize_for_run()
	var recovered := CORE_LOOP.recover_action_result()
	_expect(CORE_LOOP.legacy_origin_receipt().is_empty() \
			and recovered.is_empty() \
			and CORE_LOOP.action_receipt(bundle_id).is_empty() \
			and CORE_LOOP.activity_task_receipt(bundle_id).is_empty() \
			and CORE_LOOP.activity_task_receipt_outcome_id(bundle_id).is_empty(),
		"partial schema-2 action state minted current action authority")
	_check_activity_task_story_reader_absent(
		"inventory_legacy_count_marked")
	_expect(is_equal_approx(float(GameState.money), money_after) \
			and int(GameState.health) == health_after \
			and int(GameState.mental) == mental_after \
			and GameState.weekly_commitments.size() == 1,
		"schema-2 migration reapplied effects or duplicated its commitment")
	_expect(not _complete_action_or_story_bundle(bundle_id),
		"partial schema-2 action state completed without admitted origin")

func _check_missing_action_receipt_lazy_recovery() -> void:
	_fresh()
	GameState.turn = 10
	var bundle_id := "m3_inventory_shift"
	var scene_bundle := CORE_LOOP.bundle(bundle_id)
	var config: Dictionary = scene_bundle.get("action_config", {})
	var effects: Dictionary = (
		(config.get("effects", {}) as Dictionary).duplicate(true)
		if config.get("effects", {}) is Dictionary else {}
	)
	_expect(CORE_LOOP.begin_bundle(bundle_id, "schedule") \
			and GameState.arm_weekly_commitment({
				"turn": 10,
				"pressure_id": bundle_id,
				"pressure_family": "livelihood",
				"choice_id": "side_shift",
				"forgone_ids": [],
			}), "missing-receipt fixture could not arm")
	var callback := Callable(self, "_capture_v2_action_receipt")
	var callback_was_connected := (
		GameState.weekly_commitment_finalized.is_connected(callback))
	if callback_was_connected:
		GameState.weekly_commitment_finalized.disconnect(callback)
	var transaction := GameState.finalize_weekly_effect_action(
		"side_shift", effects, "money", "work", "", {
			"execution": "instant_effect",
			"effects": effects.duplicate(true),
		})
	if callback_was_connected \
			and not GameState.weekly_commitment_finalized.is_connected(callback):
		GameState.weekly_commitment_finalized.connect(callback)
	var raw_state: Dictionary = GameState.core_loop_v2_state
	_expect(bool(transaction.get("ok", false)) \
			and (raw_state.get("action_receipts", {}) as Dictionary).is_empty() \
			and not bool(raw_state.get("action_result_ready", false)),
		"disconnected signal unexpectedly produced an action receipt")
	var money_after := float(GameState.money)
	var health_after := int(GameState.health)
	var mental_after := int(GameState.mental)
	var commitment_count := GameState.weekly_commitments.size()
	var missing_receipt_save: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(missing_receipt_save)
	CORE_LOOP.initialize_for_run()
	var recovered := CORE_LOOP.recover_action_result()
	_expect(not recovered.is_empty() \
			and str(recovered.get("bundle_id", "")) == bundle_id \
			and str(recovered.get("action_id", "")) == "side_shift" \
			and CORE_LOOP.action_result_ready() \
			and (
				GameState.core_loop_v2_state.get(
					"action_receipts", {}) as Dictionary
			).size() == 1,
		"same-turn finalized commitment did not lazily recover its receipt")
	_expect(is_equal_approx(float(GameState.money), money_after) \
			and int(GameState.health) == health_after \
			and int(GameState.mental) == mental_after \
			and GameState.action_points == 0 \
			and GameState.weekly_commitments.size() == commitment_count,
		"lazy receipt recovery replayed AP, effects, or commitment")
	var recovered_state: Dictionary = GameState.serialize().duplicate(true)
	CORE_LOOP.initialize_for_run()
	var recovered_again := CORE_LOOP.recover_action_result()
	_expect(recovered_again == recovered \
			and GameState.serialize() == recovered_state \
			and (
				GameState.core_loop_v2_state.get(
					"action_receipts", {}) as Dictionary
			).size() == 1,
		"repeated lazy normalization duplicated or changed its receipt")
	_expect(_complete_action_or_story_bundle(bundle_id) \
			and CORE_LOOP.turn_completed(10),
		"lazy-recovered result/story bridge did not complete exactly once")

func _check_invalid_action_result_recovery() -> void:
	for schema in [3, 2]:
		for invalid_field in ["pressure_id", "actual_action_id"]:
			_fresh()
			GameState.turn = 10
			var bundle_id := "m3_inventory_shift"
			var scene_bundle := CORE_LOOP.bundle(bundle_id)
			var config: Dictionary = scene_bundle.get("action_config", {})
			var effects: Dictionary = (
				(config.get("effects", {}) as Dictionary).duplicate(true)
				if config.get("effects", {}) is Dictionary else {}
			)
			_expect(CORE_LOOP.begin_bundle(bundle_id, "schedule") \
					and GameState.arm_weekly_commitment({
						"turn": 10,
						"pressure_id": bundle_id,
						"pressure_family": "livelihood",
						"choice_id": "side_shift",
						"forgone_ids": [],
					}),
				"invalid-recovery schema-%d fixture could not arm" % schema)
			var transaction := GameState.finalize_weekly_effect_action(
				"side_shift", effects, "money", "work", "", {
					"execution": "instant_effect",
					"effects": effects.duplicate(true),
				})
			_expect(bool(transaction.get("ok", false)),
				"invalid-recovery schema-%d fixture could not finalize" \
					% schema)
			var invalid_record: Dictionary = (
				GameState.weekly_commitments[0] as Dictionary
			).duplicate(true)
			if invalid_field == "pressure_id":
				invalid_record["pressure_id"] = "m3_empty_saturday"
			else:
				invalid_record["actual_action_id"] = "rest"
			GameState.weekly_commitments[0] = invalid_record
			if schema == 2:
				var old_state: Dictionary = (
					GameState.core_loop_v2_state as Dictionary
				).duplicate(true)
				old_state["schema"] = 2
				old_state.erase("action_receipts")
				old_state.erase("application_statuses")
				old_state["action_result_ready"] = true
				GameState.core_loop_v2_state = old_state
			var invalid_save: Dictionary = GameState.serialize()
			GameState.start_new_game()
			GameState.load_from_dict(invalid_save)
			CORE_LOOP.initialize_for_run()
			_expect(CORE_LOOP.recover_action_result().is_empty(),
				"schema-%d recovery accepted a finalized record with wrong %s"
				% [schema, invalid_field])
			if schema == 2:
				# Preserve the explicit result-ready error boundary rather than
				# re-running an already-finalized action. The only forbidden
				# behavior here is manufacturing a valid receipt.
				_expect(CORE_LOOP.action_receipt(bundle_id).is_empty(),
					"schema-2 migration backfilled an invalid %s receipt"
					% invalid_field)

func _check_action_result_system_overlay() -> void:
	_fresh()
	GameState.turn = 14
	var bundle_id := "m4_certificate_session"
	var scene_bundle := CORE_LOOP.bundle(bundle_id)
	var config: Dictionary = scene_bundle.get("action_config", {})
	var action_id := str(scene_bundle.get("action_id", ""))
	var axis := str(config.get("axis", "human"))
	var place_id := str(config.get("place_id", "city"))
	var effects: Dictionary = (
		(config.get("effects", {}) as Dictionary).duplicate(true)
		if config.get("effects", {}) is Dictionary else {}
	)
	_expect(CORE_LOOP.begin_bundle(bundle_id, "schedule") \
			and GameState.arm_weekly_commitment({
				"turn": 14,
				"pressure_id": bundle_id,
				"pressure_family": "growth",
				"choice_id": action_id,
				"forgone_ids": [],
			}), "system-overlay result fixture could not arm")
	var transaction := GameState.finalize_weekly_effect_action(
		action_id, effects, axis, place_id, "", {
			"execution": "instant_effect",
			"axis": axis,
			"place_id": place_id,
			"effects": effects.duplicate(true),
		})
	_expect(bool(transaction.get("ok", false)) \
			and CORE_LOOP.action_result_ready(),
		"system-overlay result fixture could not finalize")

	var packed := load("res://scenes/MainGame.tscn") as PackedScene
	_expect(packed != null, "system-overlay QA could not load MainGame")
	if packed == null:
		return
	var main_game = packed.instantiate()
	main_game.set_meta("_screenshot_qa_static_surface", true)
	add_child(main_game)
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(main_game._core_loop_v2_restore_action_result(),
		"finalized result could not render before opening System")
	await get_tree().process_frame
	var durable_result: Dictionary = GameState.serialize().duplicate(true)
	_expect(is_instance_valid(_find_meta_node(
			main_game.choice_box, "ap_result_confirm")),
		"finalized action result omitted its Continue control")

	main_game._open_system_menu()
	_expect(main_game.modal_layer.visible \
			and str(main_game._modal_kind) == "system",
		"System overlay did not identify itself above the result")
	main_game._cancel_modal()
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(not main_game.modal_layer.visible \
			and CORE_LOOP.active_bundle_id() == bundle_id \
			and CORE_LOOP.action_result_ready() \
			and GameState.serialize() == durable_result \
			and is_instance_valid(_find_meta_node(
				main_game.choice_box, "ap_result_confirm")),
		"System East/X destroyed or changed the durable action result")

	main_game._open_system_menu()
	main_game._close_modal()
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(CORE_LOOP.active_bundle_id() == bundle_id \
			and CORE_LOOP.action_result_ready() \
			and GameState.serialize() == durable_result,
		"System Cancel destroyed or changed the durable action result")

	main_game._on_result_confirmed()
	var expected_roots := CORE_LOOP.resolved_event_roots(bundle_id)
	_expect(CORE_LOOP.active_bundle_id() == bundle_id \
			and not CORE_LOOP.action_result_ready() \
			and CORE_LOOP.action_story_stage(bundle_id) == "story" \
			and GameState.pending_story_queue == expected_roots \
			and CORE_LOOP.complete_active_bundle().is_empty(),
		"Continue after System did not route the same owner into its story")
	_expect(_complete_action_or_story_bundle(bundle_id),
		"the post-action story did not complete the owner exactly once")
	SceneTransition.fade_in()
	var completed: Array = GameState.core_loop_v2_state.get(
		"completed_bundles", [])
	_expect(completed.count(bundle_id) == 1 \
			and CORE_LOOP.active_bundle_id().is_empty() \
			and not CORE_LOOP.action_result_ready(),
		"the System-overlay bridge lost or duplicated its completion receipt")
	main_game._on_result_confirmed()
	await get_tree().process_frame
	completed = GameState.core_loop_v2_state.get("completed_bundles", [])
	_expect(completed.count(bundle_id) == 1 \
			and CORE_LOOP.complete_active_bundle().is_empty(),
		"repeated result confirmation completed the owner twice")
	main_game.free()
	packed = null
	await get_tree().process_frame

func _check_unfinalized_action_resume() -> void:
	_fresh()
	GameState.turn = 6
	var bundle_id := "m2_rain_delivery_shift"
	var scene_bundle := CORE_LOOP.bundle(bundle_id)
	var action_id := str(scene_bundle.get("action_id", ""))
	_expect(CORE_LOOP.begin_bundle(bundle_id, "schedule") \
			and GameState.arm_weekly_commitment({
				"turn": 6,
				"pressure_id": bundle_id,
				"pressure_family": str(scene_bundle.get(
					"kind", "livelihood")),
				"choice_id": action_id,
				"forgone_ids": [],
			}), "unfinalized mini-game fixture could not arm")
	var saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	CORE_LOOP.initialize_for_run()
	var money_before := float(GameState.money)
	var health_before := int(GameState.health)
	var mental_before := int(GameState.mental)
	var ap_before := int(GameState.action_points)

	var packed := load("res://scenes/MainGame.tscn") as PackedScene
	_expect(packed != null, "mini-game resume QA could not load MainGame")
	if packed == null:
		return
	var main_game = packed.instantiate()
	main_game.set_meta("_screenshot_qa_static_surface", true)
	add_child(main_game)
	await get_tree().process_frame
	await get_tree().process_frame
	main_game._core_loop_v2_begin_action_bundle(bundle_id, scene_bundle)
	await get_tree().process_frame
	var pending: Dictionary = GameState.pending_weekly_commitment
	_expect(main_game._minigame_overlay_active \
			and CORE_LOOP.active_bundle_id() == bundle_id \
			and CORE_LOOP.active_kind() == "schedule" \
			and int(pending.get("turn", -1)) == 6 \
			and str(pending.get("pressure_id", "")) == bundle_id \
			and str(pending.get("choice_id", "")) == action_id \
			and GameState.weekly_commitments.is_empty() \
			and GameState.action_points == ap_before \
			and is_equal_approx(float(GameState.money), money_before) \
			and int(GameState.health) == health_before \
			and int(GameState.mental) == mental_before,
		"saved unfinalized mini-game did not restart under the same owner "
		+ "without applying AP or effects")
	var menu_event := InputEventAction.new()
	menu_event.action = "gd_menu"
	menu_event.pressed = true
	main_game._unhandled_input(menu_event)
	_expect(not main_game.modal_layer.visible \
			and str(main_game._modal_kind).is_empty(),
		"global System menu opened while the mini-game owned input")
	main_game._exit_minigame_overlay()
	GameState.cancel_pending_weekly_commitment(GameState.turn)
	CORE_LOOP.cancel_active_bundle()
	main_game.free()
	packed = null
	await get_tree().process_frame

func _check_atomic_action_rollback() -> void:
	_check_atomic_action_rollback_case(
		"m3_hanbit_application", 9, "apply",
		{"money": 123456, "health": -5}, "application")
	_check_atomic_action_rollback_case(
		"m1_youth_center_resume_clinic", 2, "resume",
		{"stress": 2, "intelligence": 2}, "job_hunt_minigame")
	_check_atomic_action_rollback_case(
		"m2_youth_center_mock_interview", 7, "interview",
		{"stress": 2, "social_skill": 2, "luck": 1},
		"job_hunt_minigame")
	_check_atomic_action_rollback_case(
		"m1_convenience_trial_shift", 1, "side_shift",
		{"money": 90000, "stress": 3, "health": -4}, "side_shift")
	_check_atomic_action_rollback_case(
		"m2_rain_delivery_shift", 6, "side_shift",
		{"money": 120000, "stress": 4, "health": -5}, "side_shift")

func _check_atomic_action_rollback_case(
		bundle_id: String, action_turn: int, action_id: String,
		effects: Dictionary, execution: String) -> void:
	_fresh()
	GameState.turn = action_turn
	_expect(CORE_LOOP.begin_bundle(bundle_id, "schedule") \
			and GameState.arm_weekly_commitment({
				"turn": action_turn,
				"pressure_id": bundle_id,
				"pressure_family": "qa",
				"choice_id": action_id,
				"forgone_ids": [],
			}), "%s rollback fixture could not arm" % bundle_id)
	var before: Dictionary = GameState.serialize().duplicate(true)
	var injection_callback := Callable(
		self, "_inject_commitment_after_ap_spend")
	if not GameState.stats_changed.is_connected(injection_callback):
		GameState.stats_changed.connect(injection_callback)
	_inject_late_commitment = true
	var transaction := GameState.finalize_weekly_effect_action(
		action_id, effects, "money", "work", "", {
			"execution": execution,
			"application_id": "qa_rollback" if action_id == "apply" else "",
			"status": "submitted" if action_id == "apply" else "",
			"effects": effects.duplicate(true),
		}, {
			"qa_atomic_should_rollback": true,
		})
	_inject_late_commitment = false
	if GameState.stats_changed.is_connected(injection_callback):
		GameState.stats_changed.disconnect(injection_callback)
	_expect(not bool(transaction.get("ok", true)) \
			and bool(transaction.get("rolled_back", false)) \
			and GameState.serialize() == before,
		"%s late finalization failure did not restore the serialized snapshot"
		% bundle_id)
	_expect(not GameState.flags.has("qa_atomic_should_rollback") \
			and GameState.weekly_commitments.is_empty() \
			and CORE_LOOP.action_receipt(bundle_id).is_empty() \
			and not CORE_LOOP.action_result_ready(),
		"%s rollback leaked a flag, commitment, receipt, or result-ready state"
		% bundle_id)

func _check_matching_decline_and_fallback() -> void:
	_fresh()
	GameState.turn = 9
	_unlock_all_b_entries()
	_expect(bool(CORE_LOOP.commit_plan(
		3, _month_three_schedule(), _growth_routines()).get("ok", false)),
		"matching-decline fixture could not commit month three")
	var health_before := int(GameState.health)
	var mental_before := int(GameState.mental)
	_expect(CORE_LOOP.process_declines_before_bundle(
			"m3_inventory_shift").is_empty(),
		"encounter fatigue was consumed by a livelihood bundle")
	var matched := CORE_LOOP.process_declines_before_bundle(
		"daeun_world_meet")
	_expect(matched.size() == 1 \
			and str((matched[0] as Dictionary).get("id", "")) \
				== "strain_carries_into_romance_entry" \
			and str((matched[0] as Dictionary).get("dispatch", "")) \
				== "before_bundle",
		"missed recovery did not dispatch before the next encounter")
	_expect(int(GameState.health) == health_before - 2 \
			and int(GameState.mental) == mental_before - 2,
		"matching decline did not apply its authored effects once")
	_expect(CORE_LOOP.process_declines_before_bundle(
			"daeun_world_meet").is_empty(),
		"matching decline was consumed twice")

	_fresh()
	GameState.turn = 9
	_unlock_all_b_entries()
	CORE_LOOP.commit_plan(3, _month_three_schedule(), _growth_routines())
	GameState.turn = 13
	var fallback_health := int(GameState.health)
	var fallback_mental := int(GameState.mental)
	var early := CORE_LOOP.process_due_decline_outcomes(2)
	_expect(_records_with_id(
			early, "strain_carries_into_romance_entry").is_empty(),
		"next-matching decline fell back before its authored closing month")
	var closed := CORE_LOOP.process_due_decline_outcomes(3)
	var fallback_records := _records_with_id(
		closed, "strain_carries_into_romance_entry")
	_expect(fallback_records.size() == 1 \
			and str((fallback_records[0] as Dictionary).get(
				"dispatch", "")) == "closing_month_fallback",
		"unmatched decline did not use its closing-month fallback")
	_expect(int(GameState.health) == fallback_health - 2 \
			and int(GameState.mental) == fallback_mental - 2,
		"closing fallback did not apply the missed-recovery cost once")
	_expect(_records_with_id(
			CORE_LOOP.process_due_decline_outcomes(3),
			"strain_carries_into_romance_entry").is_empty(),
		"closing fallback was consumed twice")

func _check_cash_shortfall_receipts() -> void:
	_fresh()
	GameState.turn = 13
	GameState.money = -310000.0
	var arrears_summary := CORE_LOOP.record_month_summary(3, {
		"money": 340000.0,
		"monthly_income": 0.0,
		"fixed_expense": 650000.0,
	}, {
		"money": -310000.0,
		"health": 72,
		"mental": 68,
	}, {"route": "no_inventory_shift"})
	_expect(is_equal_approx(
			float(arrears_summary.get("cash_shortfall", 0.0)), 310000.0),
		"negative month close did not record KRW 310,000 arrears")
	var completion := CORE_LOOP.completion_snapshot()
	var diagnostic_summaries: Dictionary = completion.get(
		"month_summaries", {})
	var diagnostic_month_three: Dictionary = diagnostic_summaries.get(
		"3", {})
	_expect(is_zero_approx(float(completion.get(
			"cash_shortfall", -1.0))) \
			and is_equal_approx(float(diagnostic_month_three.get(
				"cash_shortfall", 0.0)), 310000.0),
		"mid-run completion diagnostic relabeled Month-Three arrears as the final month")
	var saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	CORE_LOOP.initialize_for_run()
	_expect(is_equal_approx(float(
			CORE_LOOP.month_summary(3).get("cash_shortfall", 0.0)),
			310000.0),
		"arrears receipt did not survive save/load")
	var legacy_state: Dictionary = GameState.core_loop_v2_state
	var legacy_summary: Dictionary = (
		legacy_state.get("month_summaries", {}) as Dictionary
	).get("3", {})
	legacy_summary.erase("cash_shortfall")
	(legacy_state.get("month_summaries", {}) as Dictionary)["3"] = legacy_summary
	GameState.core_loop_v2_state = legacy_state
	var legacy_save: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(legacy_save)
	CORE_LOOP.initialize_for_run()
	_expect(is_equal_approx(float(
			CORE_LOOP.month_summary(3).get("cash_shortfall", 0.0)),
			310000.0),
		"pre-receipt save did not derive arrears from its closing balance")

	_fresh()
	GameState.turn = 13
	GameState.money = 50000.0
	var inventory_summary := CORE_LOOP.record_month_summary(3, {
		"money": 700000.0,
		"monthly_income": 0.0,
		"fixed_expense": 650000.0,
	}, {
		"money": 50000.0,
		"health": 67,
		"mental": 64,
	}, {"route": "inventory_shift"})
	_expect(is_zero_approx(float(
			inventory_summary.get("cash_shortfall", -1.0))) \
			and is_zero_approx(float(
				CORE_LOOP.completion_snapshot().get(
					"cash_shortfall", -1.0))),
		"inventory-shift close recorded arrears despite KRW 50,000 cash")

func _check_initial_subsidy_once_across_five_years() -> void:
	GameState.start_new_game()
	GameState.turn = 4
	var money_before := float(GameState.money)
	_expect(GameState.claim_initial_settlement_subsidy() \
			and is_equal_approx(
				float(GameState.money),
				money_before + GameState.INITIAL_SETTLEMENT_SUBSIDY),
		"opening month did not receive exactly one settlement subsidy")
	_expect(not GameState.claim_initial_settlement_subsidy() \
			and is_equal_approx(
				float(GameState.money),
				money_before + GameState.INITIAL_SETTLEMENT_SUBSIDY),
		"same opening month received the settlement subsidy twice")
	var saved: Dictionary = GameState.serialize()
	for rollover_turn in [48, 96, 144, 192, 240]:
		GameState.load_from_dict(saved)
		GameState.turn = rollover_turn
		GameState.month = 1
		var rollover_money := float(GameState.money)
		_expect(not GameState.claim_initial_settlement_subsidy() \
				and is_equal_approx(float(GameState.money), rollover_money),
			"settlement subsidy repeated at the %d-week year boundary"
			% rollover_turn)
	GameState.start_new_game()
	GameState.turn = 48
	GameState.month = 1
	var legacy_money := float(GameState.money)
	_expect(not GameState.claim_initial_settlement_subsidy() \
			and is_equal_approx(float(GameState.money), legacy_money),
		"pre-receipt legacy save received a new subsidy after Week 4")

func _check_twelve_week_routine_units() -> void:
	_fresh()
	GameState.turn = 1
	_expect(bool(CORE_LOOP.commit_plan(
		1, _month_one_schedule(), _growth_routines()).get("ok", false)),
		"12-week routine fixture could not commit month one")
	GameState.turn = 5
	_expect(bool(CORE_LOOP.commit_plan(
		2, _month_two_schedule(), _growth_routines()).get("ok", false)),
		"12-week routine fixture could not commit month two")
	GameState.turn = 9
	_unlock_all_b_entries()
	_expect(bool(CORE_LOOP.commit_plan(
		3, _month_three_schedule(), _growth_routines()).get("ok", false)),
		"12-week routine fixture could not commit month three")
	for week in range(1, 13):
		GameState.turn = week
		var applied := CORE_LOOP.apply_background_routines_for_turn()
		_expect(bool(applied.get("ok", false)) \
				and bool(applied.get("applied", false)),
			"week %d did not apply its background routines" % week)
		var repeated := CORE_LOOP.apply_background_routines_for_turn()
		_expect(bool(repeated.get("ok", false)) \
				and not bool(repeated.get("applied", true)),
			"week %d applied its routines more than once" % week)
	var receipts: Dictionary = GameState.core_loop_v2_state.get(
		"routine_receipts", {})
	var total_units := 0
	for raw_receipt in receipts.values():
		if raw_receipt is Dictionary:
			total_units += ((raw_receipt as Dictionary).get(
				"units", []) as Array).size()
	_expect(receipts.size() == 12 and total_units == 24,
		"twelve weeks did not produce exactly 24 durable routine units")
	var saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	CORE_LOOP.initialize_for_run()
	var repeat_after_load := CORE_LOOP.apply_background_routines_for_turn(12)
	_expect(not bool(repeat_after_load.get("applied", true)) \
			and (
				GameState.core_loop_v2_state.get(
					"routine_receipts", {}) as Dictionary
			).size() == 12,
		"save/load resurrected a consumed week-12 routine unit")

func _fresh() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)

func _mark_completed(bundle_id: String, turn: int) -> void:
	var state: Dictionary = GameState.core_loop_v2_state
	var completed: Array = state.get("completed_bundles", [])
	if not completed.has(bundle_id):
		completed.append(bundle_id)
	state["completed_bundles"] = completed
	var turns: Dictionary = state.get("completed_bundle_turns", {})
	turns[bundle_id] = turn
	state["completed_bundle_turns"] = turns
	var application_statuses: Dictionary = state.get(
		"application_statuses", {})
	match bundle_id:
		"m1_mirae_application":
			application_statuses["mirae_industrial_tech"] = "submitted"
		"m2_seorin_application":
			application_statuses["seorin_contract_2026q1"] = "submitted"
		"m3_hanbit_application":
			application_statuses["hanbit_ops_2026q1"] = "submitted"
	state["application_statuses"] = application_statuses
	GameState.core_loop_v2_state = state

func _install_legacy_delivery_completion(completed_turn: int) -> void:
	var legacy := ORDER101_FIXTURES._order101_legacy_040746_save(
		completed_turn, completed_turn, completed_turn)
	GameState.start_new_game()
	GameState.load_from_dict(legacy)
	CORE_LOOP.initialize_for_run(true)
	var state: Dictionary = GameState.core_loop_v2_state
	var fallbacks: Dictionary = state.get("legacy_action_fallbacks", {})
	var migrations: Dictionary = state.get("legacy_migration_receipts", {})
	_expect(not CORE_LOOP.legacy_origin_receipt().is_empty() \
		and not (fallbacks.get(
			"m2_rain_delivery_shift", {}) as Dictionary).is_empty() \
		and not (migrations.get(
			"m2_rain_delivery_shift", {}) as Dictionary).is_empty(),
		"strict 040746 delivery fixture did not mint its origin authority")
	# Keep the admitted strict save intact. Copying these ledgers into an
	# unrelated fresh continuation would split their frozen plan identity and
	# correctly make the authority fail closed on the next normalization.

func _complete_typed_application_action(
		bundle_id: String, action_turn: int) -> bool:
	var scene_bundle := CORE_LOOP.bundle(bundle_id)
	var config: Dictionary = scene_bundle.get("action_config", {}) \
		if scene_bundle.get("action_config", {}) is Dictionary else {}
	var action_id := str(scene_bundle.get("action_id", ""))
	GameState.turn = action_turn
	GameState.month = CORE_LOOP.month_for_turn(action_turn)
	GameState.week_of_month = ((action_turn - 1) % 4) + 1
	if action_id.is_empty() \
			or not CORE_LOOP.begin_bundle(bundle_id, "schedule") \
			or not GameState.arm_weekly_commitment({
				"turn": action_turn,
				"pressure_id": bundle_id,
				"pressure_family": str(scene_bundle.get("kind", "career")),
				"choice_id": action_id,
				"forgone_ids": [],
			}):
		return false
	var transaction := GameState.finalize_weekly_effect_action(
		action_id, {}, "money", "youth_center", "", {
			"execution": str(config.get("execution", "application")),
			"application_id": str(config.get("application_id", "")),
			"status": str(config.get("status", "submitted")),
		})
	return bool(transaction.get("ok", false)) \
		and not CORE_LOOP.action_receipt(bundle_id).is_empty() \
		and CORE_LOOP.complete_active_bundle() == bundle_id


func _complete_typed_delivery_action(action_turn: int) -> bool:
	var prior_turn := int(GameState.turn)
	var prior_month := int(GameState.month)
	var prior_week := int(GameState.week_of_month)
	var prior_ap := int(GameState.action_points)
	var bundle_id := "m2_rain_delivery_shift"
	var scene_bundle := CORE_LOOP.bundle(bundle_id)
	GameState.turn = action_turn
	GameState.month = CORE_LOOP.month_for_turn(action_turn)
	GameState.week_of_month = ((action_turn - 1) % 4) + 1
	var began := CORE_LOOP.begin_bundle(bundle_id, "schedule")
	var armed := began and GameState.arm_weekly_commitment({
		"turn": action_turn,
		"pressure_id": bundle_id,
		"pressure_family": str(scene_bundle.get("kind", "livelihood")),
		"choice_id": "side_shift",
		"forgone_ids": [],
	})
	var transaction := GameState.finalize_weekly_effect_action(
		"side_shift", {"money": 100500, "health": -4},
		"money", "work", "", {
			"earned": 100500,
			"health_delta": -4,
			"mental_delta": 0,
		}) if armed else {}
	var completed := bool(transaction.get("ok", false)) \
		and not CORE_LOOP.action_receipt(bundle_id).is_empty() \
		and CORE_LOOP.complete_active_bundle() == bundle_id
	GameState.turn = prior_turn
	GameState.month = prior_month
	GameState.week_of_month = prior_week
	GameState.action_points = prior_ap
	return completed


func _set_relationship_stage(character: String, stage: String) -> void:
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

func _install_plan(month_index: int, schedule: Dictionary) -> void:
	var state: Dictionary = GameState.core_loop_v2_state
	var plans: Dictionary = state.get("plans", {})
	plans[str(month_index)] = {
		"schedule": schedule.duplicate(true),
		"selected": schedule.values().duplicate(),
		"routines": _growth_routines(),
		"forgone": [],
		"planned_turn": int(GameState.turn),
	}
	state["plans"] = plans
	GameState.core_loop_v2_state = state

func _unlock_all_b_entries() -> void:
	_mark_completed("m1_convenience_trial_shift", 2)
	_expect(_complete_typed_delivery_action(6),
		"rich B fixture could not produce its typed delivery receipt")
	_mark_completed("father_first_call", 2)
	_mark_completed("hyunsu_player_reachout", 5)
	_set_relationship_stage("father", "opening")
	_set_relationship_stage("hyunsu", "player_reached_out")
	var state: Dictionary = GameState.core_loop_v2_state
	var plans: Dictionary = state.get("plans", {})
	plans["1"] = {
		"routines": {"primary": "livelihood", "secondary": "growth"},
	}
	state["plans"] = plans
	state["player_initiated"] = ["hyunsu"]
	state["relationship_memories"] = [
		{
			"character": "father",
			"memory": "father_wellbeing_returned",
			"bundle_id": "father_first_call",
			"turn": 2,
		},
		{
			"character": "hyunsu",
			"memory": "hyunsu_resume_shared",
			"bundle_id": "hyunsu_player_reachout",
			"turn": 5,
		},
	]
	GameState.core_loop_v2_state = state

func _apply_and_note_current_story(
		event_id: String, choice_index: int) -> bool:
	var event: Dictionary = DataRegistry.find_event(event_id)
	var choices: Array = event.get("choices", []) \
		if event.get("choices", []) is Array else []
	return not event.is_empty() \
		and choice_index >= 0 and choice_index < choices.size() \
		and GameState.apply_choice(
			event, choices[choice_index] as Dictionary) \
		and CORE_LOOP.note_story_choice(event_id, choice_index)


func _check_relationship_mapping(
		bundle_id: String, event_id: String, choice_index: int,
		character: String, from_stage: String, to_stage: String,
		initiative: String, memory: String, already_player_initiated: bool) -> void:
	_fresh()
	GameState.turn = 10
	if from_stage != "unmet":
		_set_relationship_stage(character, from_stage)
	if already_player_initiated:
		var pre_state: Dictionary = GameState.core_loop_v2_state
		pre_state["player_initiated"] = [character]
		GameState.core_loop_v2_state = pre_state
	var initiated_before := (
		GameState.core_loop_v2_state.get("player_initiated", []) as Array
	).size()
	_expect(CORE_LOOP.begin_bundle(bundle_id, "schedule"),
		"%s could not begin" % bundle_id)
	_expect(CORE_LOOP.note_story_choice(event_id, choice_index),
		"%s choice %d did not produce a receipt" % [
			bundle_id, choice_index])
	var mapped_receipt: Dictionary = {}
	for raw_receipt in (
			GameState.core_loop_v2_state.get(
				"relationship_choice_receipts", {}) as Dictionary
		).values():
		if raw_receipt is Dictionary:
			mapped_receipt = (raw_receipt as Dictionary).duplicate(true)
			break
	_expect(str(mapped_receipt.get("character", "")) == character \
			and str(mapped_receipt.get("from", "")) == from_stage \
			and str(mapped_receipt.get("to", "")) == to_stage \
			and str(mapped_receipt.get("initiative", "")) == initiative \
			and str(mapped_receipt.get("memory", "")) == memory,
		"%s receipt drifted from its from→to/initiative/memory mapping" \
			% bundle_id)
	var initiated_after := (
		GameState.core_loop_v2_state.get("player_initiated", []) as Array
	).size()
	if initiative == "player":
		_expect(CORE_LOOP.was_player_initiated(character) \
				and initiated_after == initiated_before + 1,
			"%s did not record its player initiative exactly once" % bundle_id)
	else:
		_expect(initiated_after == initiated_before,
			"%s incorrectly created player initiative" % bundle_id)
	_expect(CORE_LOOP.relationship_stage(character) == to_stage \
			and CORE_LOOP.complete_active_bundle() == bundle_id,
		"%s receipt did not authorize its mapped completion" % bundle_id)
	GameState.turn = 11
	CORE_LOOP.begin_bundle(bundle_id, "schedule")
	var replayed := CORE_LOOP.note_story_choice(event_id, choice_index)
	_expect(CORE_LOOP.relationship_stage(character) == to_stage \
			and (replayed if to_stage == from_stage else not replayed),
		"%s changed or regressed its mapped stage on replay" % bundle_id)
	CORE_LOOP.cancel_active_bundle()

func _month_one_schedule() -> Dictionary:
	return {
		"1": "m1_mirae_application",
		"2": "father_first_call",
		"3": "hyunsu_first_meet",
		"4": "first_temptation_boss",
	}

func _month_two_schedule() -> Dictionary:
	return {
		"5": "m2_seorin_application",
		"6": "m2_rain_delivery_shift",
		"7": "m2_youth_center_mock_interview",
		"8": "m2_sleep_debt_sunday",
	}

func _month_three_schedule() -> Dictionary:
	return {
		"9": "m3_hanbit_application",
		"10": "m3_inventory_shift",
		"11": "daeun_world_meet",
		"12": "father_quiet_call",
	}

func _growth_routines() -> Dictionary:
	return {"primary": "growth", "secondary": "livelihood"}

func _records_with_id(records: Array, record_id: String) -> Array:
	var result: Array = []
	for raw_record in records:
		if raw_record is Dictionary \
				and str((raw_record as Dictionary).get("id", "")) == record_id:
			result.append((raw_record as Dictionary).duplicate(true))
	return result

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

func _capture_v2_action_receipt(record: Dictionary) -> void:
	if CORE_LOOP.is_active():
		CORE_LOOP.note_action_commitment(record)

func _inject_commitment_after_ap_spend() -> void:
	if not _inject_late_commitment \
			or GameState.action_points >= GameState.max_action_points:
		return
	_inject_late_commitment = false
	GameState.weekly_commitments.append({
		"turn": GameState.turn,
		"choice_id": "qa_late_conflict",
		"actual_action_id": "qa_late_conflict",
		"outcome": {},
	})

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
