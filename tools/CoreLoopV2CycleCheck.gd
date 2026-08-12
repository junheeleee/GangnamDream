extends Node
## ORDER-94 Batch A pure/runtime contract check.
## Run:
##   godot --headless --path . res://tools/CoreLoopV2CycleCheck.tscn

const CORE := preload("res://systems/DemoCoreLoopV2.gd")
const BUILD_FLAVOR := preload("res://systems/BuildFlavor.gd")
const MAIN_GAME_SCRIPT := preload("res://scenes/MainGame.gd")
const MAIN_GAME_SCENE := preload("res://scenes/MainGame.tscn")
const FATHER_EVENT := "arc_father_01_call"
const HYUNSU_EVENT := "arc_intro_04_hyunsu"
const TEMPTATION_EVENT := "arc_temptation_01"

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	_check_contract_and_determinism()
	_check_order101_fresh_w1_application_contract()
	await _check_order101_main_result_committed_double_reload()
	_check_run_generation_provenance()
	_check_completion_boundary_trust()
	await _check_durable_save_retry_boundaries()
	_check_plan_mode_compatibility()
	_check_conditional_trigger_roundtrip()
	_check_city_world_presentation_proof()
	_check_cycle_routine_and_livelihood()
	_check_four_week_cycle()
	_check_later_month_world_receipt_idempotency()
	_check_external_stalled_save_fixture()
	await _check_external_stalled_slot_e2e()
	if _failures.is_empty():
		print(
			"CORE_LOOP_V2_CYCLE_CHECK_OK "
			+ "mode=seoul_cycle_v1 fresh_only=1 provenance=new/save/no_inference "
			+ "old_episode=preserved "
			+ "legacy=preserved capacity=4/deterministic/no_reroll "
			+ "fresh_w1=actual_capacity/effective1/authored3/quality0..3 "
			+ "application=typed_receipt/nested_followup/post_result_restore "
				+ "legacy_resume=minigame+missing_execution/no_application "
				+ "main_result_reload=begin+route/double/frozen/continue_gated "
				+ "w1_handoff=atomic/collision_rollback/retry "
				+ "father_provenance=typed+legacy/free_status_closed "
			+ "progress=1/2/3 trigger=father/receipt "
			+ "world=w3_hyunsu+w4_temptation/exactly_once "
			+ "world_save=pending_float/canonical+legacy_recovery/collision_closed "
			+ "world_idempotency=month2/local_week/full_proof "
			+ "external_stalled_save=optional/non_destructive "
			+ "external_slot=optional/isolated_guard/load/notebook/month2/reload "
			+ "turn=atomic deadline=node+featured_expiry echo=actual_receipt "
			+ "routine=absorbed/zero/idempotent livelihood=allocated_70000 "
			+ "livelihood_trigger=resolved/no_expiry/w4_repeat "
			+ "conditional_trigger=initialize/normalize/save_roundtrip/m6_daeun+hyunsu "
			+ "city_world_proof=valid/malformed_excluded "
			+ "durability=init/allocation/week/month-summary/month-ack/frozen-retry "
			+ "completion_boundary=fresh_exact/turn25_legacy_receipt_exact/save_roundtrip "
			+ "decline_boundary=legacy_turn25_in/turn26_out/cycle_expiry_separate "
			+ "summary=4_allocations/node_states save=roundtrip "
			+ "horizon=24/48/240")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("CORE_LOOP_V2_CYCLE_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)


func _check_external_stalled_save_fixture() -> void:
	var fixture_path := ""
	for raw_arg in OS.get_cmdline_user_args():
		var arg := str(raw_arg)
		if arg.begins_with("--stalled-save-fixture="):
			fixture_path = arg.trim_prefix("--stalled-save-fixture=")
			break
	if fixture_path.is_empty():
		return
	_expect(FileAccess.file_exists(fixture_path),
		"external stalled-save fixture does not exist")
	if not FileAccess.file_exists(fixture_path):
		return
	var parsed: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(fixture_path))
	_expect(parsed is Dictionary,
		"external stalled-save fixture is not a JSON dictionary")
	if not parsed is Dictionary:
		return
	var raw_state: Variant = (parsed as Dictionary).get("state", {})
	_expect(raw_state is Dictionary,
		"external stalled-save fixture has no state dictionary")
	if not raw_state is Dictionary:
		return
	var state: Dictionary = raw_state
	var raw_v2: Variant = state.get("core_loop_v2_state", {})
	var raw_cycle: Variant = (
		(raw_v2 as Dictionary).get("seoul_cycle", {})
		if raw_v2 is Dictionary else {})
	var raw_world: Variant = (
		(raw_cycle as Dictionary).get("world_receipts", {})
		if raw_cycle is Dictionary else {})
	_expect(raw_world is Dictionary \
		and (raw_world as Dictionary).has("4.0") \
		and not (raw_world as Dictionary).has("4"),
		"external fixture is not the exact BUILD 2026.08.11.2 stalled shape")
	if not raw_world is Dictionary \
			or not (raw_world as Dictionary).has("4.0") \
			or (raw_world as Dictionary).has("4"):
		return
	var expected_money := float(state.get("money", 0.0))
	var expected_health := int(state.get("health", 0))
	var expected_mental := int(state.get("mental", 0))
	GameState.start_new_game()
	GameState.load_from_dict(state.duplicate(true))
	CORE.initialize_for_run(true)
	var recovered := CORE.seoul_cycle_snapshot(1)
	var recovered_world: Dictionary = recovered.get("world_receipts", {})
	_expect(int(GameState.turn) == 4 \
		and recovered_world.has("4") \
		and not recovered_world.has("4.0") \
		and bool(recovered.get("turn_ready", false)) \
		and float(GameState.money) == expected_money \
		and int(GameState.health) == expected_health \
		and int(GameState.mental) == expected_mental,
		"external stalled save did not recover in memory without replaying effects")
	var completion := CORE.complete_seoul_cycle_turn(1)
	_expect(bool(completion.get("ok", false)) \
		and CORE.turn_completed(4) \
		and int(completion.get("next_turn", 0)) == 5,
		"external stalled save could not close Week 4 exactly once in memory")
	var completed_frozen: Dictionary = GameState.serialize().duplicate(true)
	var duplicate_completion := CORE.complete_seoul_cycle_turn(1)
	_expect(not bool(duplicate_completion.get("ok", true)) \
		and str(duplicate_completion.get("error", "")) \
			== "cycle_turn_already_completed" \
		and GameState.serialize() == completed_frozen,
		"external stalled save applied its Week 4 completion twice")


func _check_external_stalled_slot_e2e() -> void:
	if not OS.get_cmdline_user_args().has("--stalled-save-slot-e2e"):
		return
	var isolated_root := BUILD_FLAVOR.qa_isolated_user_root().simplify_path()
	var isolated_prefix := isolated_root.trim_suffix("/") + "/"
	var slot_path := SaveManager.slot_path(
		SaveManager.AUTOSAVE_SLOT).simplify_path()
	_expect(not isolated_root.is_empty() \
		and slot_path.is_absolute_path() \
		and slot_path.begins_with(isolated_prefix),
		"external stalled-slot E2E requires an isolated playtest user root")
	if isolated_root.is_empty() \
			or not slot_path.is_absolute_path() \
			or not slot_path.begins_with(isolated_prefix):
		return
	var loaded_slot := SaveManager.load_game(0)
	_expect(loaded_slot,
		"isolated stalled autosave was rejected by SaveManager")
	if not loaded_slot:
		return
	CORE.initialize_for_run(true)
	var loaded := CORE.seoul_cycle_snapshot(1)
	var loaded_world: Dictionary = loaded.get("world_receipts", {})
	var temptation_choice_key := \
		"first_temptation_boss:arc_temptation_01:0:4"
	_expect(int(GameState.turn) == 4 \
		and loaded_world.has("4") and not loaded_world.has("4.0") \
		and bool(loaded.get("turn_ready", false)) \
		and float(GameState.money) == 675000.0 \
		and int(GameState.health) == 56 \
		and int(GameState.mental) == 52 \
		and (loaded.get("capacities", []) as Array).size() == 4 \
		and (loaded.get("allocation_receipts", {}) as Dictionary).size() == 4 \
		and (GameState.core_loop_v2_state.get(
			"story_choice_receipts", {}) as Dictionary).has(
				temptation_choice_key) \
		and _weekly_followup_count(4, "first_temptation_boss") == 1,
		"SaveManager load did not recover the exact stalled player state")

	var main_game: Control = MAIN_GAME_SCENE.instantiate()
	main_game.set_meta("_screenshot_qa_static_surface", true)
	add_child(main_game)
	await get_tree().process_frame
	await get_tree().process_frame
	main_game.call("_core_loop_v2_continue_seoul_cycle_week", 1, loaded)
	for _frame in range(6):
		await get_tree().process_frame
	var month_one_summary := CORE.month_summary(1)
	_expect(int(GameState.turn) == 5 \
		and int(GameState.month) == 2 \
		and int(GameState.week_of_month) == 1 \
		and str(main_game.get("_modal_kind")) \
			== "core_loop_v2_month_summary" \
		and not bool(month_one_summary.get("acknowledged", true)) \
		and (month_one_summary.get(
			"allocation_receipts", []) as Array).size() == 4 \
		and _weekly_followup_count(4, "first_temptation_boss") == 1,
		"recovered Week 4 did not reach the Month 1 notebook exactly once")
	if not SaveManager.autosave():
		_expect(false, "isolated recovered notebook could not be saved")
	_dispose_durable_gate_main(main_game)
	await get_tree().process_frame
	_expect(SaveManager.load_game(0),
		"isolated recovered notebook could not be reloaded")
	CORE.initialize_for_run(true)
	var reloaded_summary := CORE.month_summary(1)
	_expect(int(GameState.turn) == 5 \
		and not bool(reloaded_summary.get("acknowledged", true)) \
		and (reloaded_summary.get(
			"allocation_receipts", []) as Array).size() == 4 \
		and (GameState.core_loop_v2_state.get(
			"story_choice_receipts", {}) as Dictionary).has(
				temptation_choice_key) \
		and _weekly_followup_count(4, "first_temptation_boss") == 1,
		"durable notebook reload lost or duplicated the player's W4 facts")

	var resumed_main: Control = MAIN_GAME_SCENE.instantiate()
	resumed_main.set_meta("_screenshot_qa_static_surface", true)
	add_child(resumed_main)
	await get_tree().process_frame
	await get_tree().process_frame
	resumed_main.call("_core_loop_v2_show_month_summary", reloaded_summary, false)
	await get_tree().process_frame
	resumed_main.call("_core_loop_v2_acknowledge_month_summary", 1)
	for _frame in range(8):
		await get_tree().process_frame
	var month_two := CORE.seoul_cycle_snapshot(2)
	var month_two_board := resumed_main.get("_seoul_cycle_board") as Control
	_expect(bool(CORE.month_summary(1).get("acknowledged", false)) \
		and int(GameState.turn) == 5 \
		and int(month_two.get("month", 0)) == 2 \
		and bool(month_two.get("active", false)) \
		and is_instance_valid(month_two_board) and month_two_board.visible \
		and _weekly_followup_count(4, "first_temptation_boss") == 1,
		"notebook confirmation did not enter the Month 2 board exactly once")
	var month_two_money := float(GameState.money)
	var month_two_health := int(GameState.health)
	var month_two_mental := int(GameState.mental)
	_expect(SaveManager.autosave(),
		"isolated Month 2 board could not be saved")
	_dispose_durable_gate_main(resumed_main)
	await get_tree().process_frame
	var reloaded_month_two := SaveManager.load_game(0)
	_expect(reloaded_month_two,
		"isolated Month 2 board could not be reloaded")
	if reloaded_month_two:
		CORE.initialize_for_run(true)
		var durable_month_two := CORE.seoul_cycle_snapshot(2)
		_expect(bool(CORE.month_summary(1).get("acknowledged", false)) \
			and int(GameState.turn) == 5 \
			and int(durable_month_two.get("month", 0)) == 2 \
			and bool(durable_month_two.get("active", false)) \
			and float(GameState.money) == month_two_money \
			and int(GameState.health) == month_two_health \
			and int(GameState.mental) == month_two_mental \
			and (GameState.core_loop_v2_state.get(
				"story_choice_receipts", {}) as Dictionary).has(
					temptation_choice_key) \
			and _weekly_followup_count(4, "first_temptation_boss") == 1,
			"durable Month 2 reload lost or duplicated the recovered run")
	await _stop_durable_gate_audio()


func _weekly_followup_count(turn: int, bundle_id: String) -> int:
	var count := 0
	for raw_record in GameState.weekly_commitments:
		if not raw_record is Dictionary \
				or int((raw_record as Dictionary).get("turn", 0)) != turn:
			continue
		var details: Dictionary = (raw_record as Dictionary).get("details", {})
		for raw_followup in details.get("followups", []):
			if raw_followup is Dictionary \
					and str((raw_followup as Dictionary).get(
						"bundle_id", "")) == bundle_id:
				count += 1
	return count


func _check_later_month_world_receipt_idempotency() -> void:
	_prepare_fresh_cycle_gate()
	_expect(bool(CORE.initialize_seoul_cycle(1).get("ok", false)),
		"Month 2 world-receipt fixture could not seed Month 1 ownership")
	GameState.turn = 5
	GameState.month = 2
	GameState.week_of_month = 1
	var initialized := CORE.initialize_seoul_cycle(2)
	_expect(bool(initialized.get("ok", false)),
		"Month 2 world-receipt fixture could not initialize")
	if not bool(initialized.get("ok", false)):
		return
	GameState.turn = 8
	GameState.month = 2
	GameState.week_of_month = 4
	GameState.weekly_commitments = [{
		"turn": 8,
		"source": "seoul_cycle",
		"choice_id": "m2_world_idempotency_fixture",
		"details": {
			"execution": "seoul_cycle",
			"week_baseline": {"money": float(GameState.money)},
			"followups": [],
		},
	}]
	var state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	var cycle: Dictionary = state.get("seoul_cycle", {})
	cycle["pending_world"] = {
		"kind": "consequence",
		"node_id": "",
		"bundle_id": "temptation_consequence",
		"turn": 8,
		"week_index": 4,
		"status": "claimed",
		"claimed_turn": 8,
	}
	state["seoul_cycle"] = cycle
	state["completed_bundle_turns"]["temptation_consequence"] = 8
	if not (state["completed_bundles"] as Array).has("temptation_consequence"):
		state["completed_bundles"].append("temptation_consequence")
	GameState.core_loop_v2_state = state
	var first := CORE.resolve_seoul_cycle_world("temptation_consequence")
	var serialized: Variant = JSON.parse_string(
		JSON.stringify(GameState.serialize()))
	_expect(first and serialized is Dictionary,
		"Month 2 world receipt did not resolve before JSON reload")
	if not first or not serialized is Dictionary:
		return
	GameState.start_new_game()
	GameState.load_from_dict(serialized as Dictionary)
	CORE.initialize_for_run(true)
	var second := CORE.resolve_seoul_cycle_world("temptation_consequence")
	var snapshot := CORE.seoul_cycle_snapshot(2)
	var world: Dictionary = snapshot.get("world_receipts", {})
	var followup_count := 0
	for raw_record in GameState.weekly_commitments:
		if not raw_record is Dictionary \
				or int((raw_record as Dictionary).get("turn", 0)) != 8:
			continue
		var details: Dictionary = (raw_record as Dictionary).get("details", {})
		for raw_followup in details.get("followups", []):
			if raw_followup is Dictionary \
					and str((raw_followup as Dictionary).get(
						"bundle_id", "")) == "temptation_consequence":
				followup_count += 1
	_expect(second \
		and world.has("4") and not world.has("8") \
		and followup_count == 1,
		"Month 2 world resolve was not idempotent under its local-week key")


func _check_contract_and_determinism() -> void:
	var spec := CORE.seoul_cycle_spec()
	_expect(int(spec.get("schema_version", 0)) == 1 \
		and str(spec.get("planning_mode", "")) == CORE.SEOUL_CYCLE_MODE,
		"Seoul Cycle contract identity is missing")
	var capacity: Dictionary = spec.get("capacity", {})
	_expect(int(capacity.get("count", 0)) == 4 \
		and int(capacity.get("minimum", 0)) == 1 \
		and int(capacity.get("maximum", 0)) == 6,
		"capacity contract is not four saved values in the 1..6 range")
	var progress_values: Array[int] = []
	for value in range(1, 7):
		progress_values.append(CORE._seoul_cycle_progress_for_capacity(value))
	_expect(progress_values == [1, 1, 2, 2, 3, 3],
		"capacity values do not map to exact 1/2/3 progress bands")
	var background_routines: Dictionary = spec.get("background_routines", {})
	_expect(str(background_routines.get("policy", "")) \
		== "absorbed_by_nodes" \
		and not bool(background_routines.get("automatic_effects", true)) \
		and bool(background_routines.get(
			"durable_suppressed_receipt", false)),
		"Seoul Cycle does not explicitly absorb legacy background routines")
	var nodes: Dictionary = spec.get("nodes", {})
	_expect(_sorted_strings(nodes.keys()) \
		== ["convenience", "father", "recovery", "resume"],
		"Month One does not declare the four exact Seoul nodes")
	_expect(str((nodes.get("convenience", {}) as Dictionary).get(
		"trigger_bundle", "")) == "m1_convenience_trial_shift" \
		and str((nodes.get("resume", {}) as Dictionary).get(
			"trigger_bundle", "")) == "m1_youth_center_resume_clinic" \
		and str((nodes.get("father", {}) as Dictionary).get(
			"trigger_bundle", "")) == "father_first_call" \
		and str((nodes.get("recovery", {}) as Dictionary).get(
			"trigger_bundle", "")).is_empty(),
		"node trigger ownership does not match existing Month-One surfaces")
	var convenience_effects: Dictionary = (
		nodes.get("convenience", {}) as Dictionary).get(
			"allocation_effects", {})
	_expect(float(convenience_effects.get("money", 0.0)) == 70000.0 \
		and int(convenience_effects.get("health", 0)) == -1 \
		and int(convenience_effects.get("mental", 0)) == -1,
		"convenience allocation does not own the provisional KRW 70K tradeoff")
	var world: Dictionary = spec.get("world_clock", {})
	var events: Array = world.get("events", [])
	_expect(events.size() == 2 \
		and int((events[0] as Dictionary).get("week_index", 0)) == 3 \
		and str((events[0] as Dictionary).get("bundle_id", "")) \
			== "hyunsu_first_meet" \
		and int((events[1] as Dictionary).get("week_index", 0)) == 4 \
		and str((events[1] as Dictionary).get("bundle_id", "")) \
			== "first_temptation_boss",
		"W3/W4 world arrivals are not contract-owned")

	var same_a: Array = CORE._generated_seoul_cycle_capacities(
		1, 65, 60, "김민준")
	var same_b: Array = CORE._generated_seoul_cycle_capacities(
		1, 65, 60, "김민준")
	var depleted: Array = CORE._generated_seoul_cycle_capacities(
		1, 25, 25, "김민준")
	var ready: Array = CORE._generated_seoul_cycle_capacities(
		1, 95, 95, "김민준")
	_expect(same_a == same_b,
		"same public state generated different capacities")
	_expect(_capacity_values(depleted) != _capacity_values(ready) \
		and _capacity_sum(depleted) < _capacity_sum(ready),
		"different body/mind bands did not change capacity quality")
	_expect(CORE._generated_seoul_cycle_capacities(
		1, 65, 60, "김민준") != CORE._generated_seoul_cycle_capacities(
		2, 65, 60, "김민준"),
		"month is not part of deterministic capacity identity")


func _check_order101_fresh_w1_application_contract() -> void:
	var typed_father_initiative := ""
	for quality in range(4):
		_prepare_base_v2()
		_expect(CORE.begin_fresh_w1_onboarding(),
			"quality %d fixture could not create the fresh W1 owner" % quality)
		GameState.flags["prologue_done"] = true
		var initialized := CORE.initialize_seoul_cycle(1)
		var cycle: Dictionary = CORE.seoul_cycle_snapshot(1)
		var capacities: Array = cycle.get("capacities", [])
		_expect(bool(initialized.get("ok", false)) and capacities.size() == 4 \
			and CORE.fresh_w1_onboarding_phase() == "board",
			"quality %d fixture did not enter the four-capacity W1 board" % quality)
		if capacities.size() != 4:
			continue
		# Rotate through the generated pieces. The contract may not assume a
		# particular slot or an ideal capacity value.
		var selected: Dictionary = capacities[quality % capacities.size()]
		var capacity_id := str(selected.get("id", ""))
		var capacity_value := int(selected.get("value", 0))
		var before_wrong_node: Dictionary = GameState.serialize().duplicate(true)
		var wrong_node := CORE.preview_seoul_cycle_allocation(
			capacity_id, "father", 1)
		_expect(not bool(wrong_node.get("ok", true)) \
			and str(wrong_node.get("error", "")) \
				== "onboarding_resume_required" \
			and GameState.serialize() == before_wrong_node,
			"fresh W1 accepted a non-resume node or changed state during preview")
		var preview := CORE.preview_seoul_cycle_allocation(
			capacity_id, "resume", 1)
		_expect(bool(preview.get("ok", false)) \
			and int(preview.get("threshold", 0)) == 1 \
			and int(preview.get("authored_threshold", 0)) == 3 \
			and bool(preview.get("onboarding_completion_override", false)) \
			and bool(preview.get("completed_now", false)) \
			and str(preview.get("capacity_id", "")) == capacity_id \
			and int(preview.get("capacity_value", 0)) == capacity_value,
			"fresh W1 did not complete resume with the selected capacity while " \
			+ "preserving authored threshold 3")
		var allocation := CORE.commit_seoul_cycle_allocation(
			capacity_id, "resume", 1)
		var allocation_receipt: Dictionary = allocation.get("receipt", {})
		var onboarding := CORE.fresh_w1_onboarding_snapshot()
		_expect(bool(allocation.get("ok", false)) \
			and bool(allocation_receipt.get(
				"onboarding_completion_override", false)) \
			and int(allocation_receipt.get("threshold", 0)) == 1 \
			and int(allocation_receipt.get("authored_threshold", 0)) == 3 \
			and str(allocation_receipt.get("capacity_id", "")) == capacity_id \
			and int(allocation_receipt.get("capacity_value", 0)) == capacity_value \
			and str(onboarding.get("selected_capacity_id", "")) == capacity_id \
			and int(onboarding.get("selected_capacity_value", 0)) == capacity_value \
			and CORE.application_status("mirae_industrial_tech").is_empty() \
			and CORE.action_receipt(
				"m1_youth_center_resume_clinic").is_empty(),
			"allocation wrote an application/result or lost the actual capacity")
		if not bool(allocation.get("ok", false)):
			continue

		var claimed := CORE.claim_seoul_cycle_trigger()
		var began := bool(claimed.get("ok", false)) \
			and CORE.begin_seoul_cycle_trigger(
				"m1_youth_center_resume_clinic")
		var armed := began and GameState.arm_weekly_commitment({
			"turn": int(GameState.turn),
			"pressure_id": "m1_youth_center_resume_clinic",
			"pressure_family": "growth",
			"choice_id": "resume",
			"forgone_ids": [],
			"supplemental_to_seoul_cycle": true,
		})
		var restarted := armed and CORE.restart_fresh_w1_minigame()
		_expect(bool(claimed.get("ok", false)) and began and armed and restarted \
			and CORE.fresh_w1_onboarding_phase() == "minigame",
			"fresh W1 could not enter the restartable resume minigame")
		if not restarted:
			continue

		# A pre-result save carries only allocation and owner. It must not persist
		# answers or quality; load restarts the same minigame from its beginning.
		var pre_result_save: Dictionary = GameState.serialize().duplicate(true)
		GameState.start_new_game()
		GameState.load_from_dict(pre_result_save)
		CORE.initialize_for_run(true)
		onboarding = CORE.fresh_w1_onboarding_snapshot()
		_expect(CORE.fresh_w1_onboarding_phase() == "minigame" \
			and int(onboarding.get("quality", -1)) == -1 \
			and str(onboarding.get("selected_capacity_id", "")) == capacity_id \
			and CORE.application_status("mirae_industrial_tech").is_empty() \
			and CORE.action_receipt(
				"m1_youth_center_resume_clinic").is_empty(),
			"pre-result reload restored a draft score/application instead of " \
			+ "restarting the minigame")

		var invalid_pre_state: Dictionary = GameState.serialize().duplicate(true)
		var invalid_quality := CORE.finalize_fresh_w1_application(1, 4)
		_expect(not bool(invalid_quality.get("ok", true)) \
			and GameState.serialize() == invalid_pre_state,
			"out-of-range quality changed part of the fresh application transaction")
		var finalized := CORE.finalize_fresh_w1_application(quality + 1, quality)
		var receipt := CORE.action_receipt(
			"m1_youth_center_resume_clinic")
		var details: Dictionary = receipt.get("result_details", {})
		var commitment := GameState.get_weekly_commitment_for_turn(1)
		var followups: Array = (
			(commitment.get("details", {}) as Dictionary).get(
				"action_followups", [])
			if commitment.get("details", {}) is Dictionary else [])
		var matching_followups := 0
		for raw_followup in followups:
			if raw_followup is Dictionary \
					and str((raw_followup as Dictionary).get(
						"bundle_id", "")) \
						== "m1_youth_center_resume_clinic":
				matching_followups += 1
		_expect(bool(finalized.get("ok", false)) \
			and CORE.fresh_w1_onboarding_phase() == "result_committed" \
			and str(receipt.get("application_id", "")) \
				== "mirae_industrial_tech" \
			and str(receipt.get("application_status", "")) == "submitted" \
			and str(details.get("execution", "")) == "job_hunt_application" \
			and int(details.get("quality", -1)) == quality \
			and str(details.get("capacity_id", "")) == capacity_id \
			and int(details.get("capacity_value", 0)) == capacity_value \
			and CORE.application_status("mirae_industrial_tech") == "submitted" \
			and matching_followups == 1,
			(
				"quality %d did not fail-forward through one typed nested "
				+ "job_hunt_application receipt"
			) % quality)
		var recovered := CORE.recover_action_result()
		_expect(str(recovered.get("bundle_id", "")) \
			== "m1_youth_center_resume_clinic" \
			and int((recovered.get("result_details", {}) as Dictionary).get(
				"quality", -1)) == quality,
			"quality %d result could not recover from the nested cycle followup" \
				% quality)

		var post_result_save: Dictionary = GameState.serialize().duplicate(true)
		GameState.start_new_game()
		GameState.load_from_dict(post_result_save)
		CORE.initialize_for_run(true)
		var restored := CORE.recover_action_result()
		_expect(str(restored.get("bundle_id", "")) \
			== "m1_youth_center_resume_clinic" \
			and int((restored.get("result_details", {}) as Dictionary).get(
				"quality", -1)) == quality \
			and CORE.application_status("mirae_industrial_tech") == "submitted" \
			and CORE.fresh_w1_onboarding_phase() == "result_committed",
			"quality %d post-result reload reran or lost the durable Send" % quality)

		var completed := CORE.complete_active_bundle()
		var claimed_interview := completed \
			== "m1_youth_center_resume_clinic" \
			and CORE.claim_fresh_w1_opening_interview()
		_expect(claimed_interview \
			and CORE.fresh_w1_onboarding_phase() == "consequence_presented" \
			and CORE.active_bundle_id() == "opening_interview_math" \
			and CORE.active_kind() == "consequence",
			"quality %d Send did not hand off to the same-week interview" % quality)
		if quality == 3 and claimed_interview:
			var typed_father := CORE._relationship_outcome_for_choice(
				"father_first_call", FATHER_EVENT, 0)
			typed_father_initiative = str(typed_father.get(
				"initiative", ""))
			_expect(CORE.opening_application_provenance_valid() \
					and typed_father_initiative == "player",
				"typed W1 receipt did not prove Father's player-led callback")

			# A free-floating status/flag pair is not provenance. Keep every
			# tempting compatibility value while deleting the only typed producer;
			# the relationship must fail closed to the historical incoming call.
			var forged_state: Dictionary = (
				GameState.core_loop_v2_state as Dictionary).duplicate(true)
			(forged_state.get("action_receipts", {}) as Dictionary).erase(
				"m1_youth_center_resume_clinic")
			GameState.core_loop_v2_state = forged_state
			GameState.flags["story_job_unlocked"] = true
			GameState.flags["opening_interview_application_sent"] = true
			GameState.flags["opening_preplan_application_sent"] = true
			var forged_father := CORE._relationship_outcome_for_choice(
				"father_first_call", FATHER_EVENT, 0)
			_expect(not CORE.opening_application_provenance_valid() \
					and CORE.application_status(
						"mirae_industrial_tech") == "submitted" \
					and str(forged_father.get("initiative", "")) \
						== "reciprocal",
				"free application status/flags impersonated the typed W1 producer")

	# A real legacy Send remains authoritative by its preserved flag and yields
	# the same player-led Father callback as the new typed action receipt.
	_prepare_base_v2()
	GameState.flags["prologue_done"] = true
	GameState.flags["story_job_unlocked"] = true
	GameState.flags["opening_interview_application_sent"] = true
	GameState.flags["opening_preplan_application_sent"] = true
	var legacy_provenance_state: Dictionary = (
		GameState.core_loop_v2_state as Dictionary).duplicate(true)
	legacy_provenance_state["application_statuses"][
		"mirae_industrial_tech"] = "submitted"
	GameState.core_loop_v2_state = legacy_provenance_state
	var legacy_father := CORE._relationship_outcome_for_choice(
		"father_first_call", FATHER_EVENT, 0)
	_expect(CORE.opening_application_provenance_valid() \
			and typed_father_initiative == "player" \
			and str(legacy_father.get("initiative", "")) \
				== typed_father_initiative,
		"typed and preserved legacy Send disagreed on Father-call provenance")

	# The exception is fresh-only. The established non-onboarding cycle retains
	# the authored threshold and normal 1/2/3 progress bands.
	_prepare_fresh_cycle_gate()
	var normal_init := CORE.initialize_seoul_cycle(1)
	var normal_cycle := CORE.seoul_cycle_snapshot(1)
	var normal_capacities: Array = normal_cycle.get("capacities", [])
	if bool(normal_init.get("ok", false)) and not normal_capacities.is_empty():
		var normal_capacity: Dictionary = normal_capacities[0]
		var normal_preview := CORE.preview_seoul_cycle_allocation(
			str(normal_capacity.get("id", "")), "resume", 1)
		_expect(bool(normal_preview.get("ok", false)) \
			and int(normal_preview.get("threshold", 0)) == 3 \
			and not bool(normal_preview.get(
				"onboarding_completion_override", true)),
			"legacy/later resume entry did not preserve authored threshold 3")

	# The same bundle has a fresh-only application config, but a non-onboarding
	# legacy threshold completion must still produce an ordinary resume receipt.
	# It may never inherit Mirae identity from current content data.
	_prepare_base_v2()
	GameState.flags["prologue_done"] = true
	var legacy_began := CORE.begin_bundle(
		"m1_youth_center_resume_clinic", "schedule")
	var legacy_armed := legacy_began and GameState.arm_weekly_commitment({
		"turn": 1,
		"pressure_id": "m1_youth_center_resume_clinic",
		"pressure_family": "growth",
		"choice_id": "resume",
		"forgone_ids": [],
	})
	var legacy_transaction: Dictionary = {}
	if legacy_armed:
		legacy_transaction = GameState.finalize_weekly_effect_action(
			"resume", {"stress": 1}, "money", "work", "", {
				"execution": "job_hunt_minigame",
				"quality": 2,
				"effects": {"stress": 1},
			}, {"resume_polished": true})
	var legacy_noted := bool(legacy_transaction.get("ok", false)) \
		and CORE.note_action_commitment(
			legacy_transaction.get("record", {}) as Dictionary)
	var legacy_receipt := CORE.action_receipt(
		"m1_youth_center_resume_clinic")
	var legacy_details: Dictionary = legacy_receipt.get("result_details", {})
	var legacy_config: Dictionary = legacy_receipt.get("config", {})
	_expect(legacy_began and legacy_armed \
		and bool(legacy_transaction.get("ok", false)) and legacy_noted \
		and str(legacy_details.get("execution", "")) \
			== "job_hunt_minigame" \
		and legacy_config == {"execution": "job_hunt_minigame"} \
		and int(legacy_details.get("quality", -1)) == 2 \
		and str(legacy_receipt.get("application_id", "")).is_empty() \
		and str(legacy_receipt.get("application_status", "")).is_empty() \
		and CORE.application_status("mirae_industrial_tech").is_empty() \
		and CORE.fresh_w1_onboarding_snapshot().is_empty(),
		"nonfresh resume inherited Mirae application ownership from action_config")

	# Older finalized records may predate the execution discriminator entirely.
	# Current fresh-only action_config must not relabel or reject that proven
	# ordinary resume; its receipt keeps no executor/application config at all.
	_prepare_base_v2()
	GameState.flags["prologue_done"] = true
	var no_execution_began := CORE.begin_bundle(
		"m1_youth_center_resume_clinic", "schedule")
	var no_execution_armed := no_execution_began \
		and GameState.arm_weekly_commitment({
			"turn": 1,
			"pressure_id": "m1_youth_center_resume_clinic",
			"pressure_family": "growth",
			"choice_id": "resume",
			"forgone_ids": [],
		})
	var no_execution_transaction: Dictionary = {}
	if no_execution_armed:
		no_execution_transaction = GameState.finalize_weekly_effect_action(
			"resume", {"stress": 1}, "money", "work", "", {
				"quality": 1,
				"effects": {"stress": 1},
			}, {})
	var no_execution_record: Dictionary = no_execution_transaction.get(
		"record", {})
	var no_execution_record_details: Dictionary = no_execution_record.get(
		"details", {}) if no_execution_record.get(
		"details", {}) is Dictionary else {}
	var no_execution_noted := bool(no_execution_transaction.get("ok", false)) \
		and not no_execution_record_details.has("execution") \
		and CORE.note_action_commitment(no_execution_record)
	var no_execution_receipt := CORE.action_receipt(
		"m1_youth_center_resume_clinic")
	var no_execution_details: Dictionary = no_execution_receipt.get(
		"result_details", {})
	_expect(no_execution_began and no_execution_armed \
			and bool(no_execution_transaction.get("ok", false)) \
			and no_execution_noted \
			and not no_execution_details.has("execution") \
			and (no_execution_receipt.get("config", {}) as Dictionary).is_empty() \
			and str(no_execution_receipt.get(
				"application_id", "")).is_empty() \
			and str(no_execution_receipt.get(
				"application_status", "")).is_empty() \
			and CORE.application_status(
				"mirae_industrial_tech").is_empty() \
			and (GameState.core_loop_v2_state.get(
				"application_transition_receipts", {}) as Dictionary).is_empty() \
			and CORE.fresh_w1_onboarding_snapshot().is_empty(),
		"execution-less legacy resume inherited or was rejected by fresh action_config")


func _check_order101_main_result_committed_double_reload() -> void:
	var frozen := _order101_fresh_w1_result_committed_save()
	if frozen.is_empty():
		return
	var frozen_v2: Dictionary = frozen.get("core_loop_v2_state", {})
	var frozen_cycle: Dictionary = frozen_v2.get("seoul_cycle", {})
	var frozen_receipt: Dictionary = (frozen_v2.get(
		"action_receipts", {}) as Dictionary).get(
			"m1_youth_center_resume_clinic", {})
	var frozen_transitions: Dictionary = frozen_v2.get(
		"application_transition_receipts", {})
	var frozen_capacities: Array = frozen_cycle.get("capacities", [])
	var frozen_allocations: Dictionary = frozen_cycle.get(
		"allocation_receipts", {})
	var frozen_weekly: Array = frozen.get("weekly_commitments", [])
	var frozen_action_points := int(frozen.get("action_points", -1))
	var frozen_money := float(frozen.get("money", 0.0))
	var frozen_health := int(frozen.get("health", 0))
	var frozen_mental := int(frozen.get("mental", 0))
	var frozen_intelligence := int(frozen.get("intelligence", 0))
	_expect(frozen_action_points == 0 \
		and (frozen_cycle.get("allocation_receipts", {}) as Dictionary).size() == 1 \
		and (frozen_v2.get("action_receipts", {}) as Dictionary).size() == 1 \
		and frozen_transitions.size() == 1 \
		and (frozen.get("weekly_commitments", []) as Array).size() == 1,
		"actual MainGame result-reload fixture lost its atomic result baseline")
	_check_order101_w1_handoff_collision_rollback(frozen)

	for entrypoint in ["_begin_month", "_core_loop_v2_route_week"]:
		for reload_index in range(2):
			GameState.start_new_game()
			GameState.pending_story_queue = []
			GameState.load_from_dict(frozen.duplicate(true))
			CORE.initialize_for_run(true)
			var main_game: Control = await _spawn_durable_gate_main(true)
			main_game.call(entrypoint)
			await get_tree().process_frame
			await get_tree().process_frame

			var routed_v2: Dictionary = GameState.core_loop_v2_state
			var routed_cycle: Dictionary = routed_v2.get("seoul_cycle", {})
			var board := main_game.get("_seoul_cycle_board") as Control
			var planner := main_game.get("_core_loop_planner") as Control
			var job_hunt := main_game.get("job_hunt_game") as Control
			var choice_box := main_game.get("choice_box") as Node
			var result_surface_count := _meta_node_count(
				choice_box, "ap_result_confirm")
			var route_label := "%s reload %d" % [entrypoint, reload_index + 1]
			_expect(int(GameState.action_points) == frozen_action_points \
				and float(GameState.money) == frozen_money \
				and int(GameState.health) == frozen_health \
				and int(GameState.mental) == frozen_mental \
				and int(GameState.intelligence) == frozen_intelligence \
				and routed_cycle.get("capacities", []) == frozen_capacities \
				and routed_cycle.get(
					"allocation_receipts", {}) == frozen_allocations \
				and GameState.weekly_commitments == frozen_weekly \
				and CORE.action_receipt(
					"m1_youth_center_resume_clinic") == frozen_receipt \
				and routed_v2.get(
					"application_transition_receipts", {}) == frozen_transitions,
				"%s changed AP/capacity/effects/action/application state" % route_label)
			_expect(result_surface_count == 1 \
				and CORE.action_result_ready() \
				and CORE.active_bundle_id() == "m1_youth_center_resume_clinic" \
				and CORE.fresh_w1_onboarding_phase() == "result_committed" \
				and GameState.pending_story_queue.is_empty() \
				and (not is_instance_valid(board) or not board.visible) \
				and (not is_instance_valid(planner) or not planner.visible) \
				and (not is_instance_valid(job_hunt) or not job_hunt.visible) \
				and not bool(main_game.get("_minigame_overlay_active")),
				"%s did not keep one result surface ahead of interview/cycle routing" \
					% route_label)

			# Continue is the sole consumer. One confirmation may complete Send and
			# hand the exact same-week interview roots to Story; reload itself may not.
			main_game.call("_on_result_confirmed")
			var interview_roots := CORE.resolved_event_roots(
				CORE.OPENING_INTERVIEW_BUNDLE_ID)
			var completed_after_continue: Array = GameState.core_loop_v2_state.get(
				"completed_bundles", [])
			_expect(CORE.fresh_w1_onboarding_phase() == "consequence_presented" \
				and CORE.active_bundle_id() == CORE.OPENING_INTERVIEW_BUNDLE_ID \
				and CORE.active_kind() == "consequence" \
				and GameState.pending_story_queue == interview_roots \
				and completed_after_continue.count(
					"m1_youth_center_resume_clinic") == 1,
				"%s Continue did not consume exactly once into the opening interview" \
					% route_label)
			SceneTransition.fade_in()
			_dispose_durable_gate_main(main_game)
			await get_tree().process_frame


func _check_order101_w1_handoff_collision_rollback(
		frozen: Dictionary) -> void:
	GameState.start_new_game()
	GameState.pending_story_queue = []
	GameState.load_from_dict(frozen.duplicate(true))
	CORE.initialize_for_run(true)
	var before_missing_roots: Dictionary = GameState.serialize().duplicate(true)
	var contract_snapshot: Dictionary = DataRegistry.demo_core_loop_v2.duplicate(true)
	var rootless_contract: Dictionary = contract_snapshot.duplicate(true)
	var rootless_bundles: Dictionary = rootless_contract.get(
		"scene_bundles", {})
	var rootless_interview: Dictionary = rootless_bundles.get(
		CORE.OPENING_INTERVIEW_BUNDLE_ID, {})
	rootless_interview["existing_roots"] = []
	rootless_bundles[CORE.OPENING_INTERVIEW_BUNDLE_ID] = rootless_interview
	rootless_contract["scene_bundles"] = rootless_bundles
	DataRegistry.demo_core_loop_v2 = rootless_contract
	var missing_roots := CORE.complete_fresh_w1_action_and_claim_interview()
	DataRegistry.demo_core_loop_v2 = contract_snapshot
	_expect(not bool(missing_roots.get("ok", true)) \
		and bool(missing_roots.get("rolled_back", false)) \
		and str(missing_roots.get("error", "")) \
			== "fresh_w1_interview_roots_missing" \
		and GameState.serialize() == before_missing_roots \
		and CORE.fresh_w1_onboarding_phase() == "result_committed" \
		and CORE.action_result_ready() \
		and CORE.active_bundle_id() == CORE.W1_ONBOARDING_BUNDLE_ID,
		"fresh W1 missing interview roots did not preserve result_committed")

	GameState.start_new_game()
	GameState.pending_story_queue = []
	GameState.load_from_dict(frozen.duplicate(true))
	CORE.initialize_for_run(true)
	var colliding_state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	colliding_state["consequence_receipts"][CORE.OPENING_INTERVIEW_BUNDLE_ID] = {
		"consequence_id": CORE.OPENING_INTERVIEW_BUNDLE_ID,
		"turn": 1,
		"status": "presented",
		"roots": ["qa_collision"],
	}
	GameState.core_loop_v2_state = colliding_state
	var before_collision: Dictionary = GameState.serialize().duplicate(true)
	var failed := CORE.complete_fresh_w1_action_and_claim_interview()
	_expect(not bool(failed.get("ok", true)) \
		and bool(failed.get("rolled_back", false)) \
		and str(failed.get("error", "")) == "fresh_w1_interview_claim_failed" \
		and GameState.serialize() == before_collision \
		and CORE.fresh_w1_onboarding_phase() == "result_committed" \
		and CORE.action_result_ready() \
		and CORE.active_bundle_id() == CORE.W1_ONBOARDING_BUNDLE_ID \
		and CORE.active_kind() == "schedule",
		"fresh W1 interview collision did not exactly restore result_committed")
	var repaired_state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	repaired_state["consequence_receipts"].erase(
		CORE.OPENING_INTERVIEW_BUNDLE_ID)
	GameState.core_loop_v2_state = repaired_state
	var retry := CORE.complete_fresh_w1_action_and_claim_interview()
	_expect(bool(retry.get("ok", false)) \
		and CORE.fresh_w1_onboarding_phase() == "consequence_presented" \
		and CORE.active_bundle_id() == CORE.OPENING_INTERVIEW_BUNDLE_ID \
		and CORE.active_kind() == "consequence" \
		and not CORE.action_result_ready() \
		and (GameState.core_loop_v2_state.get(
			"completed_bundles", []) as Array).count(
				CORE.W1_ONBOARDING_BUNDLE_ID) == 1,
		"fresh W1 exact rollback could not retry the same Continue successfully")


func _order101_fresh_w1_result_committed_save() -> Dictionary:
	_prepare_base_v2()
	var began_onboarding := CORE.begin_fresh_w1_onboarding()
	GameState.flags["prologue_done"] = true
	var initialized := CORE.initialize_seoul_cycle(1)
	var capacities: Array = CORE.seoul_cycle_snapshot(1).get("capacities", [])
	if not began_onboarding or not bool(initialized.get("ok", false)) \
			or capacities.is_empty():
		_expect(false, "actual MainGame result-reload fixture could not open W1")
		return {}
	var capacity_id := str((capacities[0] as Dictionary).get("id", ""))
	var allocation := CORE.commit_seoul_cycle_allocation(
		capacity_id, "resume", 1)
	var claimed := CORE.claim_seoul_cycle_trigger()
	var began_trigger := bool(claimed.get("ok", false)) \
		and CORE.begin_seoul_cycle_trigger("m1_youth_center_resume_clinic")
	var armed := began_trigger and GameState.arm_weekly_commitment({
		"turn": 1,
		"pressure_id": "m1_youth_center_resume_clinic",
		"pressure_family": "growth",
		"choice_id": "resume",
		"forgone_ids": [],
		"supplemental_to_seoul_cycle": true,
	})
	var restarted := armed and CORE.restart_fresh_w1_minigame()
	var before_send: Dictionary = GameState.serialize().duplicate(true)
	var finalized: Dictionary = (
		CORE.finalize_fresh_w1_application(2, 2) if restarted else {})
	var after_send: Dictionary = GameState.serialize().duplicate(true)
	_expect(bool(allocation.get("ok", false)) and began_trigger and armed \
		and restarted and bool(finalized.get("ok", false)) \
		and float(after_send.get("money", 0.0)) \
			== float(before_send.get("money", 0.0)) \
		and int(after_send.get("health", 0)) \
			== int(before_send.get("health", 0)) \
		and int(after_send.get("mental", 0)) \
			== clampi(int(before_send.get("mental", 0)) - 2, 0, 100) \
		and int(after_send.get("intelligence", 0)) \
			== int(before_send.get("intelligence", 0)) + 1 \
		and CORE.action_result_ready() \
		and CORE.fresh_w1_onboarding_phase() == "result_committed",
		"actual MainGame result-reload fixture could not commit Send")
	if not bool(finalized.get("ok", false)):
		return {}
	return GameState.serialize().duplicate(true)


func _check_run_generation_provenance() -> void:
	_prepare_base_v2()
	var marker := GameState.CORE_LOOP_V2_ELIGIBLE_RUN_GENERATION
	_expect(str(GameState.core_loop_v2_state.get(
		"run_generation", "")) == marker,
		"start_new_game did not create the exact Seoul Cycle provenance marker")
	var fresh_serialized: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(fresh_serialized)
	CORE.initialize_for_run(true)
	_expect(str(GameState.core_loop_v2_state.get(
		"run_generation", "")) == marker,
		"fresh Seoul Cycle provenance changed on save roundtrip")

	var old_serialized: Dictionary = fresh_serialized.duplicate(true)
	var old_state: Dictionary = old_serialized.get(
		"core_loop_v2_state", {}).duplicate(true)
	old_state.erase("run_generation")
	old_state["plans"] = {}
	old_state["seoul_cycle"] = {}
	old_serialized["core_loop_v2_state"] = old_state
	GameState.start_new_game()
	GameState.load_from_dict(old_serialized)
	CORE.initialize_for_run(true)
	GameState.flags["prologue_done"] = true
	var loaded_old_state: Dictionary = GameState.core_loop_v2_state.duplicate(
		true)
	loaded_old_state["application_statuses"][
		"mirae_industrial_tech"] = "interviewed"
	GameState.core_loop_v2_state = loaded_old_state
	var old_roundtrip: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(old_roundtrip)
	CORE.initialize_for_run(true)
	_expect(not GameState.core_loop_v2_state.has("run_generation") \
		and (GameState.core_loop_v2_state.get(
			"plans", {}) as Dictionary).is_empty() \
		and (GameState.core_loop_v2_state.get(
			"seoul_cycle", {}) as Dictionary).is_empty() \
		and not CORE.seoul_cycle_available(1) \
		and not bool(CORE.initialize_seoul_cycle(1).get("ok", false)),
		"an unplanned old Month-One save roundtrip invented fresh provenance or enrolled Seoul Cycle")


func _check_durable_save_retry_boundaries() -> void:
	_prepare_fresh_cycle_gate()
	var main_game: Node = MAIN_GAME_SCRIPT.new()
	main_game.set_meta("_qa_core_loop_v2_autosave_result", false)
	var before_initialization: Dictionary = GameState.serialize().duplicate(true)
	var failed_initialization: Dictionary = main_game.call(
		"_core_loop_v2_initialize_seoul_cycle_durably", 1)
	var initialized_frozen: Dictionary = GameState.serialize().duplicate(true)
	var initialized_cycle: Dictionary = CORE.seoul_cycle_snapshot(1)
	_expect(not bool(failed_initialization.get("ok", true)) \
		and str(failed_initialization.get("error", "")) == "autosave_failed" \
		and bool(failed_initialization.get("state_committed", false)) \
		and initialized_frozen != before_initialization \
		and bool(initialized_cycle.get("active", false)) \
		and (initialized_cycle.get("capacities", []) as Array).size() == 4,
		"failed initialization save did not freeze one generated month")
	_expect(not bool(main_game.call(
		"_core_loop_v2_autosave_durable_state")) \
		and GameState.serialize() == initialized_frozen,
		"failed initialization retry regenerated or mutated its month")
	main_game.set_meta("_qa_core_loop_v2_autosave_result", true)
	_expect(bool(main_game.call("_core_loop_v2_autosave_durable_state")) \
		and GameState.serialize() == initialized_frozen,
		"successful initialization retry did not preserve the frozen month")
	var first_suppression: Dictionary = CORE.apply_background_routines_for_turn(1)
	var after_suppression: Dictionary = GameState.serialize().duplicate(true)
	var second_suppression: Dictionary = CORE.apply_background_routines_for_turn(1)
	var suppression_receipts: Dictionary = GameState.core_loop_v2_state.get(
		"routine_receipts", {})
	_expect(bool(first_suppression.get("ok", false)) \
		and bool(first_suppression.get("suppressed", false)) \
		and bool(second_suppression.get("ok", false)) \
		and bool(second_suppression.get("suppressed", false)) \
		and GameState.serialize() == after_suppression \
		and suppression_receipts.size() == 1,
		"initialization retry continuation lost or duplicated its suppressed routine receipt")

	var capacity_id := _unused_capacity(initialized_cycle, 0, false)
	var allocation_preview: Dictionary = CORE.preview_seoul_cycle_allocation(
		capacity_id, "recovery", 1)
	var money_before := float(GameState.money)
	var health_before := int(GameState.health)
	var mental_before := int(GameState.mental)
	main_game.set_meta("_qa_core_loop_v2_autosave_result", false)
	var failed_allocation: Dictionary = main_game.call(
		"_core_loop_v2_commit_seoul_cycle_allocation_durably",
		capacity_id, "recovery")
	var allocation_frozen: Dictionary = GameState.serialize().duplicate(true)
	var allocation_cycle: Dictionary = CORE.seoul_cycle_snapshot(1)
	var allocation_receipts: Dictionary = allocation_cycle.get(
		"allocation_receipts", {})
	_expect(not bool(failed_allocation.get("ok", true)) \
		and str(failed_allocation.get("error", "")) == "autosave_failed" \
		and bool(failed_allocation.get("state_committed", false)) \
		and int(GameState.turn) == 1 \
		and not CORE.turn_completed() \
		and CORE.active_bundle_id().is_empty() \
		and allocation_receipts.size() == 1 \
		and float(GameState.money) == money_before \
			+ float((allocation_preview.get(
				"immediate_effects", {}) as Dictionary).get("money", 0.0)) \
		and int(GameState.health) == health_before \
			+ int((allocation_preview.get(
				"immediate_effects", {}) as Dictionary).get("health", 0)) \
		and int(GameState.mental) == mental_before \
			+ int((allocation_preview.get(
				"immediate_effects", {}) as Dictionary).get("mental", 0)),
		"failed allocation save did not freeze one receipt and one effect set")
	_expect(not bool(main_game.call(
		"_core_loop_v2_autosave_durable_state")) \
		and not bool(main_game.call(
			"_core_loop_v2_autosave_durable_state")) \
		and GameState.serialize() == allocation_frozen \
		and (CORE.seoul_cycle_snapshot(1).get(
			"allocation_receipts", {}) as Dictionary).size() == 1,
		"allocation save retries reapplied effects or consumed another capacity")
	main_game.set_meta("_qa_core_loop_v2_autosave_result", true)
	_expect(bool(main_game.call("_core_loop_v2_autosave_durable_state")) \
		and GameState.serialize() == allocation_frozen,
		"successful allocation retry changed the frozen transaction")

	_expect(bool(CORE.complete_seoul_cycle_turn(1).get("ok", false)),
		"durability fixture could not close its effect-only allocation")
	var turn_before_advance := int(GameState.turn)
	GameState.advance_calendar()
	var advanced_frozen: Dictionary = GameState.serialize().duplicate(true)
	main_game.set_meta("_qa_core_loop_v2_autosave_result", false)
	_expect(not bool(main_game.call(
		"_core_loop_v2_autosave_durable_state")) \
		and GameState.serialize() == advanced_frozen \
		and int(GameState.turn) == turn_before_advance + 1,
		"failed week-boundary save repeated or reverted calendar advance")
	main_game.set_meta("_qa_core_loop_v2_autosave_result", true)
	_expect(bool(main_game.call("_core_loop_v2_autosave_durable_state")) \
		and GameState.serialize() == advanced_frozen,
		"successful week-boundary retry changed the frozen next week")

	var month_before := CORE.month_opening_snapshot(1)
	var month_after := {
		"money": float(GameState.money),
		"monthly_income": float(GameState.monthly_income),
		"health": int(GameState.health),
		"mental": int(GameState.mental),
	}
	var summary: Dictionary = CORE.record_month_summary(
		1, month_before, month_after)
	var summary_frozen: Dictionary = GameState.serialize().duplicate(true)
	main_game.set_meta("_qa_core_loop_v2_autosave_result", false)
	_expect(not summary.is_empty() \
		and not bool(main_game.call(
			"_core_loop_v2_autosave_durable_state")) \
		and GameState.serialize() == summary_frozen \
		and not bool(CORE.month_summary(1).get("acknowledged", true)),
		"failed month-summary save lost or advanced its frozen notebook")
	main_game.set_meta("_qa_core_loop_v2_autosave_result", true)
	_expect(bool(main_game.call("_core_loop_v2_autosave_durable_state")) \
		and GameState.serialize() == summary_frozen,
		"successful month-summary retry changed the frozen notebook")

	_expect(CORE.acknowledge_month_summary(1),
		"durability fixture could not acknowledge its notebook once")
	var acknowledged_frozen: Dictionary = GameState.serialize().duplicate(true)
	main_game.set_meta("_qa_core_loop_v2_autosave_result", false)
	_expect(not bool(main_game.call(
		"_core_loop_v2_autosave_durable_state")) \
		and GameState.serialize() == acknowledged_frozen \
		and bool(CORE.month_summary(1).get("acknowledged", false)),
		"failed notebook-confirm save reopened or duplicated acknowledgement")
	main_game.set_meta("_qa_core_loop_v2_autosave_result", true)
	_expect(bool(main_game.call("_core_loop_v2_autosave_durable_state")) \
		and GameState.serialize() == acknowledged_frozen,
		"successful notebook-confirm retry changed the frozen acknowledgement")
	main_game.free()
	_check_durable_retry_source_contract()
	await _check_durable_save_retry_ui_gate()


func _check_durable_retry_source_contract() -> void:
	var source := FileAccess.get_file_as_string("res://scenes/MainGame.gd")
	var retry_start := source.find(
		"func _core_loop_v2_retry_seoul_cycle_autosave() -> void:")
	var retry_end := source.find("\nfunc ", retry_start + 1)
	var retry_body := source.substr(retry_start, retry_end - retry_start) \
		if retry_start >= 0 and retry_end > retry_start else ""
	_expect(not retry_body.is_empty() \
		and retry_body.count("_core_loop_v2_autosave_durable_state()") == 1,
		"durable retry action does not own exactly one autosave attempt")
	for forbidden_call in [
		"initialize_seoul_cycle", "commit_seoul_cycle_allocation",
		"advance_calendar", "claim_seoul_cycle_trigger", "claim_seoul_cycle_world",
	]:
		_expect(forbidden_call not in retry_body,
			"durable retry action can repeat forbidden transition: %s" \
			% forbidden_call)
	var resume_start := source.find(
		"func _core_loop_v2_resume_after_seoul_cycle_save_retry(")
	var resume_end := source.find("\nfunc ", resume_start + 1)
	var resume_body := source.substr(resume_start, resume_end - resume_start) \
		if resume_start >= 0 and resume_end > resume_start else ""
	_expect("_core_loop_v2_continue_seoul_cycle_week(" in resume_body \
		and "_core_loop_v2_initialize_seoul_cycle_durably" not in resume_body,
		"initialization retry does not share the post-init routine continuation")


func _check_durable_save_retry_ui_gate() -> void:
	# Initialization failure owns a real, non-cancelable modal before any routine,
	# owner claim, or editable board can run. A successful retry resumes only the
	# shared post-init tail and writes one suppressed-routine receipt.
	_prepare_fresh_cycle_gate()
	GameState.flags["chapter_33_seen"] = true
	GameState.flags["tutorial_shown"] = true
	var init_main: Control = await _spawn_durable_gate_main(false)
	init_main.call("_core_loop_v2_route_seoul_cycle_week", 1)
	await get_tree().process_frame
	var init_frozen: Dictionary = GameState.serialize().duplicate(true)
	_expect(_durable_gate_is_locked(init_main, "initialization") \
		and (CORE.seoul_cycle_snapshot(1).get("capacities", []) as Array).size() == 4 \
		and (GameState.core_loop_v2_state.get(
			"routine_receipts", {}) as Dictionary).is_empty(),
		"initialization save failure did not own the locked full-screen gate")
	init_main.call("_core_loop_v2_retry_seoul_cycle_autosave")
	await get_tree().process_frame
	_expect(_durable_gate_is_locked(init_main, "initialization") \
		and GameState.serialize() == init_frozen \
		and int(init_main.get_meta(
			"_qa_core_loop_v2_autosave_call_count", 0)) == 2,
		"failed initialization retry mutated state or escaped its gate")
	init_main.set_meta("_qa_core_loop_v2_autosave_result", true)
	init_main.call("_core_loop_v2_retry_seoul_cycle_autosave")
	for _frame in range(4):
		await get_tree().process_frame
	var init_board := init_main.get("_seoul_cycle_board") as Control
	var init_receipts: Dictionary = GameState.core_loop_v2_state.get(
		"routine_receipts", {})
	_expect(is_instance_valid(init_board) and init_board.visible \
		and str(init_main.get("_seoul_cycle_save_retry_phase")).is_empty() \
		and init_receipts.size() == 1 \
		and str((init_receipts.get("1", {}) as Dictionary).get(
			"status", "")) == "suppressed" \
		and int(init_main.get_meta(
			"_qa_core_loop_v2_autosave_call_count", 0)) == 3,
		"initialization retry did not resume the normal routine/board tail once")

	# Choose a capacity that completes Father's node so the failed allocation has
	# a concrete pending trigger. The gate must leave it pending (not claimed),
	# keep the calendar fixed, and retain exactly one allocation/effect receipt.
	var trigger_capacity := ""
	var initialized_snapshot: Dictionary = CORE.seoul_cycle_snapshot(1)
	for raw_capacity in initialized_snapshot.get("capacities", []):
		if not raw_capacity is Dictionary:
			continue
		var capacity_id := str((raw_capacity as Dictionary).get("id", ""))
		var preview: Dictionary = CORE.preview_seoul_cycle_allocation(
			capacity_id, "father", 1)
		if bool(preview.get("ok", false)) \
				and bool(preview.get("completed_now", false)):
			trigger_capacity = capacity_id
			break
	_expect(not trigger_capacity.is_empty(),
		"durable gate fixture has no capacity that can arm Father's trigger")
	if not trigger_capacity.is_empty():
		init_main.set_meta("_qa_core_loop_v2_autosave_result", false)
		init_main.call(
			"_on_seoul_cycle_allocation_requested", trigger_capacity, "father")
		await get_tree().process_frame
		var allocation_frozen: Dictionary = GameState.serialize().duplicate(true)
		var pending_trigger: Dictionary = CORE.pending_seoul_cycle_trigger()
		var frozen_cycle: Dictionary = CORE.seoul_cycle_snapshot(1)
		_expect(_durable_gate_is_locked(init_main, "allocation") \
			and int(GameState.turn) == 1 and not CORE.turn_completed() \
			and CORE.active_bundle_id().is_empty() \
			and str(pending_trigger.get("status", "")) == "pending" \
			and (frozen_cycle.get(
				"allocation_receipts", {}) as Dictionary).size() == 1,
			"allocation save failure claimed its trigger, advanced, or duplicated its receipt")
		init_main.call("_core_loop_v2_retry_seoul_cycle_autosave")
		await get_tree().process_frame
		_expect(_durable_gate_is_locked(init_main, "allocation") \
			and GameState.serialize() == allocation_frozen \
			and str(CORE.pending_seoul_cycle_trigger().get(
				"status", "")) == "pending",
			"failed allocation retry consumed capacity/effects or claimed its trigger")
	_dispose_durable_gate_main(init_main)
	await get_tree().process_frame

	await _check_durable_week_gate_ui()
	await _check_durable_month_gates_ui()
	await _stop_durable_gate_audio()


func _check_durable_week_gate_ui() -> void:
	_prepare_fresh_cycle_gate()
	GameState.flags["chapter_33_seen"] = true
	GameState.flags["tutorial_shown"] = true
	GameState.turn = 2
	GameState.week_of_month = 2
	var main_game: Control = await _spawn_durable_gate_main(false)
	main_game.call("_core_loop_v2_open_seoul_cycle_save_retry_gate",
		"week_advance", 1)
	var week_frozen: Dictionary = GameState.serialize().duplicate(true)
	main_game.call("_core_loop_v2_retry_seoul_cycle_autosave")
	await get_tree().process_frame
	_expect(_durable_gate_is_locked(main_game, "week_advance") \
		and GameState.serialize() == week_frozen \
		and int(main_game.get_meta(
			"_qa_core_loop_v2_begin_month_call_count", 0)) == 0,
		"failed week-boundary retry opened or mutated the next week")
	main_game.set_meta("_qa_core_loop_v2_autosave_result", true)
	main_game.call("_core_loop_v2_retry_seoul_cycle_autosave")
	for _frame in range(4):
		await get_tree().process_frame
	_expect(int(main_game.get_meta(
			"_qa_core_loop_v2_begin_month_call_count", 0)) == 1 \
		and str(main_game.get("_seoul_cycle_save_retry_phase")).is_empty(),
		"successful week-boundary retry did not resume next-week setup once")
	var after_week_resume: Dictionary = GameState.serialize().duplicate(true)
	main_game.call("_core_loop_v2_retry_seoul_cycle_autosave")
	await get_tree().process_frame
	_expect(int(main_game.get_meta(
			"_qa_core_loop_v2_begin_month_call_count", 0)) == 1 \
		and GameState.serialize() == after_week_resume,
		"cleared week-boundary retry repeated next-week setup")
	_dispose_durable_gate_main(main_game)
	await get_tree().process_frame


func _check_durable_month_gates_ui() -> void:
	_prepare_fresh_cycle_gate()
	GameState.flags["chapter_33_seen"] = true
	GameState.flags["tutorial_shown"] = true
	_expect(bool(CORE.initialize_seoul_cycle(1).get("ok", false)),
		"month gate fixture could not initialize Seoul Cycle")
	var before: Dictionary = CORE.month_opening_snapshot(1)
	var after := {
		"money": float(GameState.money),
		"health": int(GameState.health),
		"mental": int(GameState.mental),
	}
	var summary: Dictionary = CORE.record_month_summary(1, before, after)
	var main_game: Control = await _spawn_durable_gate_main(false)
	main_game.call("_core_loop_v2_show_month_summary", summary)
	await get_tree().process_frame
	var summary_frozen: Dictionary = GameState.serialize().duplicate(true)
	_expect(_durable_gate_is_locked(main_game, "month_summary") \
		and not bool(CORE.month_summary(1).get("acknowledged", true)),
		"month-summary save failure did not replace confirmation with its gate")
	main_game.call("_core_loop_v2_retry_seoul_cycle_autosave")
	await get_tree().process_frame
	_expect(_durable_gate_is_locked(main_game, "month_summary") \
		and GameState.serialize() == summary_frozen,
		"failed month-summary retry changed or acknowledged the notebook")
	main_game.set_meta("_qa_core_loop_v2_autosave_result", true)
	main_game.call("_core_loop_v2_retry_seoul_cycle_autosave")
	for _frame in range(4):
		await get_tree().process_frame
	_expect(str(main_game.get("_modal_kind")) \
			== "core_loop_v2_month_summary" \
		and int(main_game.get_meta(
			"_qa_core_loop_v2_autosave_call_count", 0)) == 3 \
		and not bool(CORE.month_summary(1).get("acknowledged", true)),
		"month-summary retry did not reopen the same notebook without another save")

	main_game.set_meta("_qa_core_loop_v2_autosave_result", false)
	main_game.call("_core_loop_v2_acknowledge_month_summary", 1)
	await get_tree().process_frame
	var acknowledged_frozen: Dictionary = GameState.serialize().duplicate(true)
	_expect(_durable_gate_is_locked(main_game, "month_acknowledged") \
		and bool(CORE.month_summary(1).get("acknowledged", false)) \
		and int(main_game.get_meta(
			"_qa_core_loop_v2_begin_month_call_count", 0)) == 0,
		"notebook acknowledgement save failure entered the next month")
	main_game.call("_core_loop_v2_retry_seoul_cycle_autosave")
	await get_tree().process_frame
	_expect(_durable_gate_is_locked(main_game, "month_acknowledged") \
		and GameState.serialize() == acknowledged_frozen \
		and int(main_game.get_meta(
			"_qa_core_loop_v2_begin_month_call_count", 0)) == 0,
		"failed notebook acknowledgement retry duplicated or reopened state")
	main_game.set_meta("_qa_core_loop_v2_autosave_result", true)
	main_game.call("_core_loop_v2_retry_seoul_cycle_autosave")
	for _frame in range(4):
		await get_tree().process_frame
	_expect(int(main_game.get_meta(
			"_qa_core_loop_v2_begin_month_call_count", 0)) == 1 \
		and str(main_game.get("_seoul_cycle_save_retry_phase")).is_empty(),
		"successful notebook acknowledgement retry did not resume once")
	_dispose_durable_gate_main(main_game)
	await get_tree().process_frame


func _spawn_durable_gate_main(autosave_result: bool) -> Control:
	var main_game: Control = MAIN_GAME_SCENE.instantiate()
	main_game.set_meta("_screenshot_qa_static_surface", true)
	main_game.set_meta("_qa_core_loop_v2_autosave_result", autosave_result)
	main_game.set_meta("_qa_core_loop_v2_autosave_call_count", 0)
	main_game.set_meta("_qa_core_loop_v2_begin_month_call_count", 0)
	add_child(main_game)
	await get_tree().process_frame
	await get_tree().process_frame
	return main_game


func _durable_gate_is_locked(main_game: Control, phase: String) -> bool:
	var modal := main_game.get("modal_layer") as Control
	var close_button := main_game.get("modal_close_button") as Button
	var main_root := main_game.get("_main_ui_root") as Control
	var board := main_game.get("_seoul_cycle_board") as Control
	return is_instance_valid(modal) and modal.visible \
		and str(main_game.get("_modal_kind")) == "seoul_cycle_save_retry" \
		and bool(modal.get_meta("seoul_cycle_save_retry", false)) \
		and str(modal.get_meta("seoul_cycle_save_retry_phase", "")) == phase \
		and is_instance_valid(close_button) and not close_button.visible \
		and (not is_instance_valid(main_root) or not main_root.visible) \
		and (not is_instance_valid(board) or not board.visible)


func _dispose_durable_gate_main(main_game: Node) -> void:
	if not is_instance_valid(main_game):
		return
	if main_game.get_parent() != null:
		main_game.get_parent().remove_child(main_game)
	main_game.free()


func _stop_durable_gate_audio() -> void:
	BGMPlayer.stop()
	for owner in [AudioManager, BGMPlayer]:
		for child in owner.get_children():
			if child is AudioStreamPlayer:
				(child as AudioStreamPlayer).stop()
				(child as AudioStreamPlayer).stream = null
	await get_tree().process_frame


func _check_completion_boundary_trust() -> void:
	var expected_closing := _prepare_completion_boundary_fixture(true)
	_expect(CORE.mark_development_complete(),
		"loaded turn-25 legacy boundary could not be marked complete")
	var legacy_snapshot: Dictionary = CORE.completion_snapshot()
	var legacy_frozen: Variant = (
		GameState.core_loop_v2_state.get(
			"completion_snapshots", {}) as Dictionary).get("24", {})
	var legacy_closing: Dictionary = legacy_snapshot.get("closing_state", {})
	var legacy_closing_exact := true
	for key in ["money", "fixed_expense", "health", "mental"]:
		if not legacy_closing.has(key) \
				or legacy_closing.get(key) != expected_closing.get(key):
			legacy_closing_exact = false
	var legacy_untrusted_empty := true
	for key in [
		"player_initiated",
		"relationship_stages", "relationship_memories",
		"application_statuses", "application_transition_receipts",
		"legacy_callback_resolutions", "future_story_receipts",
		"future_application_receipts", "action_receipts",
		"action_story_acknowledgements", "consequence_receipts",
		"story_choice_receipts", "obligation_receipts",
		"deferred_callback_receipts", "demo_collision_context",
	]:
		var value: Variant = legacy_snapshot.get(key)
		if (value is Dictionary and not (value as Dictionary).is_empty()) \
				or (value is Array and not (value as Array).is_empty()) \
				or not (value is Dictionary or value is Array):
			legacy_untrusted_empty = false
	_expect(bool(legacy_snapshot.get(
		"legacy_boundary_incomplete", false)) \
		and legacy_closing_exact \
		and legacy_untrusted_empty \
		and legacy_frozen is Dictionary \
		and (legacy_frozen as Dictionary) == legacy_snapshot,
		"loaded turn-25 boundary lost its M6 receipt or trusted later relationship/callback maps: %s expected_closing=%s" % [
			str(legacy_snapshot), str(expected_closing)])
	var legacy_serialized: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(legacy_serialized)
	var legacy_roundtrip: Dictionary = CORE.completion_snapshot()
	_expect(legacy_roundtrip == legacy_snapshot \
		and bool(legacy_roundtrip.get(
			"legacy_boundary_incomplete", false)) \
		and (legacy_roundtrip.get(
			"closing_state", {}) as Dictionary) == legacy_closing,
		"loaded turn-25 receipt-backed completion changed on save roundtrip")

	expected_closing = _prepare_completion_boundary_fixture(false)
	var boundary_decline_id := "qa_m6_turn25_legacy_decline"
	var boundary_state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	boundary_state["pending_declines"] = [
		{
			"id": boundary_decline_id,
			"producer_bundle": "m6_no_plans_day",
			"month": 6,
			"visible_month": 6,
			"consumer_kind": "closing_month",
			"message_ko": "여섯 번째 달의 옛 일정이 닫혔다.",
			"message_en": "An older Month-Six plan closed.",
			"effects": {},
		},
	]
	GameState.core_loop_v2_state = boundary_state
	var boundary_resolved: Array = CORE.process_due_decline_outcomes(6)
	_expect(boundary_resolved.size() == 1,
		"legacy Month-Six pending decline did not resolve at turn 25")
	_expect(CORE.mark_development_complete(),
		"fresh Week-24 transaction could not mark the demo complete")
	var fresh_snapshot: Dictionary = CORE.completion_snapshot()
	var fresh_frozen: Variant = (
		GameState.core_loop_v2_state.get(
			"completion_snapshots", {}) as Dictionary).get("24", {})
	var actual_closing: Dictionary = fresh_snapshot.get("closing_state", {})
	var fresh_declines: Array = fresh_snapshot.get("decline_receipts", [])
	var boundary_decline_count := 0
	for raw_decline in fresh_declines:
		if raw_decline is Dictionary \
				and str((raw_decline as Dictionary).get("id", "")) \
					== boundary_decline_id \
				and int((raw_decline as Dictionary).get(
					"visible_month", 0)) == 6 \
				and int((raw_decline as Dictionary).get(
					"consumed_turn", 0)) == 25:
			boundary_decline_count += 1
	var exact_closing := true
	for key in ["money", "fixed_expense", "health", "mental"]:
		if not actual_closing.has(key) \
				or actual_closing.get(key) != expected_closing.get(key):
			exact_closing = false
	_expect(not bool(fresh_snapshot.get(
		"legacy_boundary_incomplete", true)) \
		and exact_closing \
		and boundary_decline_count == 1 \
		and fresh_frozen is Dictionary \
		and (fresh_frozen as Dictionary) == fresh_snapshot,
		"fresh Week-24 boundary did not freeze its exact closing metrics/turn-25 legacy decline: expected=%s actual=%s declines=%s" % [
			str(expected_closing), str(actual_closing), str(fresh_declines)])

	# Cycle expiry receipts remain a distinct ledger. A later legacy decline can
	# exist in live post-demo state, but the already frozen Week-24 notebook must
	# never absorb it.
	GameState.turn = 26
	GameState.month = 7
	GameState.week_of_month = 2
	var post_decline_id := "qa_m6_turn26_post_boundary_decline"
	var post_state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	post_state["pending_declines"] = [
		{
			"id": post_decline_id,
			"producer_bundle": "m6_last_study_group",
			"month": 6,
			"visible_month": 6,
			"consumer_kind": "closing_month",
			"message_ko": "경계 뒤에 닫힌 옛 일정.",
			"message_en": "An older plan closed after the boundary.",
			"effects": {},
		},
	]
	GameState.core_loop_v2_state = post_state
	var post_resolved: Array = CORE.process_due_decline_outcomes(6)
	var live_post_declines: Array = GameState.core_loop_v2_state.get(
		"decline_receipts", [])
	var live_post_count := 0
	for raw_decline in live_post_declines:
		if raw_decline is Dictionary \
				and str((raw_decline as Dictionary).get("id", "")) \
					== post_decline_id \
				and int((raw_decline as Dictionary).get(
					"consumed_turn", 0)) == 26:
			live_post_count += 1
	_expect(post_resolved.size() == 1 and live_post_count == 1 \
		and _persisted_snapshot(CORE.completion_snapshot()) \
			== _persisted_snapshot(fresh_snapshot),
		"turn-26 legacy decline was not consumed live or leaked into the frozen Week-24 snapshot")
	var fresh_serialized: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(fresh_serialized)
	_expect(_persisted_snapshot(CORE.completion_snapshot()) \
		== _persisted_snapshot(fresh_snapshot),
		"fresh trusted completion changed on save roundtrip")


func _prepare_completion_boundary_fixture(
		already_complete: bool) -> Dictionary:
	_prepare_base_v2()
	GameState.turn = 25
	GameState.month = 7
	GameState.week_of_month = 1
	var expected_closing := {
		"money": 654321.0,
		"fixed_expense": 312345.0,
		"health": 57,
		"mental": 43,
		"housing_id": "gosiwon",
		"background_path": "",
		"financial_rung": {
			"kind": "survival",
			"current": 654321.0,
			"target": 1000000.0,
			"remaining": 345679.0,
		},
		"temptation_flags": {
			"lent_account": false,
			"escaped_dirty_money": false,
			"fell_to_darkness": false,
			"kept_clean_hands": true,
		},
	}
	var summaries: Dictionary = {}
	for month_index in range(1, 7):
		summaries[str(month_index)] = {
			"month": month_index,
			"after": expected_closing.duplicate(true) \
				if month_index == 6 else {},
		}
	var state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	state["completed_turns"] = range(1, 25)
	state["completed_through_week"] = 24 if already_complete else 23
	state["development_cap_week"] = 24
	state["prototype_complete"] = already_complete
	state["prototype_completed_at_turn"] = 25 if already_complete else 0
	state["completed_at_turn"] = 25 if already_complete else 0
	state["completion_snapshots"] = {}
	state["month_summaries"] = summaries
	GameState.core_loop_v2_state = state
	return expected_closing


func _persisted_snapshot(snapshot: Dictionary) -> Dictionary:
	var raw_value: Variant = JSON.parse_string(JSON.stringify(snapshot))
	return raw_value as Dictionary if raw_value is Dictionary else {}


func _check_city_world_presentation_proof() -> void:
	_prepare_fresh_cycle_gate()
	var enrolled := true
	for month_index in range(1, 7):
		GameState.turn = ((month_index - 1) * 4) + 1
		GameState.month = month_index
		GameState.week_of_month = 1
		if not bool(CORE.initialize_seoul_cycle(month_index).get("ok", false)):
			enrolled = false
			break
	_expect(enrolled,
		"city world-proof fixture could not enroll the same run through Month Six")
	if not enrolled:
		return

	GameState.turn = 23
	GameState.month = 6
	GameState.week_of_month = 3
	var valid_state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	valid_state["application_statuses"][
		"city_facility_ops_2026h1"] = "submitted"
	var valid_cycle: Dictionary = valid_state.get(
		"seoul_cycle", {}).duplicate(true)
	valid_cycle["world_receipts"] = {
		"3": {
			"kind": "consequence",
			"bundle_id": "m6_city_service_response",
			"turn": 23,
			"week_index": 3,
			"status": "resolved",
			"claimed_turn": 23,
			"resolved_turn": 23,
		},
	}
	valid_state["seoul_cycle"] = valid_cycle
	GameState.core_loop_v2_state = valid_state.duplicate(true)
	_expect(CORE._consequence_was_presented(
		valid_state, "m6_city_service_response") \
		and CORE._demo_collision_candidate_ids(valid_state).has(
			"city_work_sample"),
		"valid Month-Six Week-23 cycle world receipt did not expose the City obligation")

	var malformed_cases: Dictionary = {
		"bundle": {"bundle_id": "m6_gangnam_receipt_walk"},
		"status": {"status": "claimed"},
		"turn": {"turn": 22},
		"claimed_turn": {"claimed_turn": 22},
		"resolved_turn": {"resolved_turn": 22},
		"week": {"week_index": 2},
		# This receipt is internally consistent but places the City response in
		# local W2, where the authored world slot permits only Dodam/Gangnam.
		"authored_slot": {
			"turn": 22,
			"resolved_turn": 22,
			"claimed_turn": 22,
			"week_index": 2,
		},
	}
	for case_name in malformed_cases:
		var malformed_state: Dictionary = valid_state.duplicate(true)
		var malformed_cycle: Dictionary = malformed_state.get(
			"seoul_cycle", {}).duplicate(true)
		var receipt: Dictionary = (malformed_cycle.get(
			"world_receipts", {}) as Dictionary).get(
				"3", {}).duplicate(true)
		for raw_key in (malformed_cases[case_name] as Dictionary):
			receipt[str(raw_key)] = (
				malformed_cases[case_name] as Dictionary)[raw_key]
		malformed_cycle["world_receipts"] = {"3": receipt}
		malformed_state["seoul_cycle"] = malformed_cycle
		GameState.core_loop_v2_state = malformed_state.duplicate(true)
		_expect(not CORE._consequence_was_presented(
			malformed_state, "m6_city_service_response") \
			and not CORE._demo_collision_candidate_ids(
				malformed_state).has("city_work_sample"),
			"malformed City world proof remained eligible: %s" % case_name)
	var wrong_key_state: Dictionary = valid_state.duplicate(true)
	var wrong_key_cycle: Dictionary = wrong_key_state.get(
		"seoul_cycle", {}).duplicate(true)
	var valid_receipt: Dictionary = (wrong_key_cycle.get(
		"world_receipts", {}) as Dictionary).get("3", {}).duplicate(true)
	wrong_key_cycle["world_receipts"] = {"2": valid_receipt}
	wrong_key_state["seoul_cycle"] = wrong_key_cycle
	GameState.core_loop_v2_state = wrong_key_state.duplicate(true)
	_expect(not CORE._consequence_was_presented(
		wrong_key_state, "m6_city_service_response") \
		and not CORE._demo_collision_candidate_ids(
			wrong_key_state).has("city_work_sample"),
		"City world proof accepted a receipt key detached from week_index")
	GameState.core_loop_v2_state = valid_state


func _check_plan_mode_compatibility() -> void:
	_prepare_fresh_cycle_gate()
	_expect(CORE.seoul_cycle_available(1),
		"fresh post-opening Month One was not cycle-eligible")
	_expect(not CORE.episode_selection_enabled(1),
		"fresh cycle-eligible Month One still opened the retired episode picker")
	var initialized := CORE.initialize_seoul_cycle(1)
	_expect(bool(initialized.get("ok", false)) \
		and not bool(initialized.get("resumed", true)),
		"fresh cycle did not initialize once")
	var first_capacities: Array = CORE.seoul_cycle_snapshot(1).get(
		"capacities", []).duplicate(true)
	var resumed := CORE.initialize_seoul_cycle(1)
	_expect(bool(resumed.get("ok", false)) \
		and bool(resumed.get("resumed", false)) \
		and CORE.seoul_cycle_snapshot(1).get("capacities", []) \
			== first_capacities,
		"cycle resume rerolled or replaced the four saved capacities")
	var serialized: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(serialized)
	CORE.initialize_for_run(true)
	_expect(CORE.seoul_cycle_snapshot(1).get("capacities", []) \
		== first_capacities,
		"save/load changed the generated capacity values")
	var normalized := CORE.normalize_seoul_cycle_state(
		GameState.core_loop_v2_state.get("seoul_cycle", {}))
	_expect(not normalized.is_empty() \
		and normalized.get("capacities", []) == first_capacities,
		"public cycle normalization is not save-stable")
	var malformed: Dictionary = normalized.duplicate(true)
	malformed["capacities"] = []
	_expect(CORE.normalize_seoul_cycle_state(malformed).is_empty(),
		"normalization regenerated missing capacities and enabled rerolling")

	_prepare_base_v2()
	var episode_plan := {
		"planning_mode": CORE.MONTH_ONE_EPISODE_MODE,
		"player_commitments": ["father_first_call", "m1_phone_off_sunday"],
		"schedule": {
			"1": "father_first_call",
			"2": "m1_phone_off_sunday",
			"3": "hyunsu_first_meet",
			"4": "first_temptation_boss",
		},
		"selected": [
			"father_first_call", "m1_phone_off_sunday",
			"hyunsu_first_meet", "first_temptation_boss",
		],
		"routines": CORE.default_routines(),
	}
	GameState.core_loop_v2_state["plans"] = {"1": episode_plan}
	CORE.initialize_for_run(true)
	_expect(CORE.plan_uses_episode_selection(CORE.plan_for_month(1)) \
		and not CORE.plan_uses_seoul_cycle(CORE.plan_for_month(1)) \
		and not CORE.seoul_cycle_available(1) \
		and CORE.episode_selection_enabled(1),
		"old month_one_episode_v1 save was relabelled as Seoul Cycle")
	_expect_legacy_routine_effects("old episode", 1)

	_prepare_base_v2()
	var legacy_plan := {
		"schedule": {
			"1": "m1_convenience_trial_shift",
			"2": "father_first_call",
			"3": "hyunsu_first_meet",
			"4": "first_temptation_boss",
		},
		"selected": [
			"m1_convenience_trial_shift", "father_first_call",
			"hyunsu_first_meet", "first_temptation_boss",
		],
		"routines": CORE.default_routines(),
	}
	GameState.core_loop_v2_state["plans"] = {"1": legacy_plan}
	CORE.initialize_for_run(true)
	_expect(not CORE.plan_uses_seoul_cycle(CORE.plan_for_month(1)) \
		and not CORE.plan_uses_episode_selection(CORE.plan_for_month(1)) \
		and not CORE.seoul_cycle_available(1),
		"legacy Month-One plan was reinterpreted")
	_expect_legacy_routine_effects("legacy Month One", 1)

	# Later months continue using the established routine path even when the
	# first-month prototype exists elsewhere in the contract.
	_prepare_base_v2()
	GameState.turn = 5
	GameState.month = 2
	GameState.week_of_month = 1
	var month_two_state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	month_two_state["plans"]["2"] = {
		"schedule": {},
		"selected": [],
		"routines": CORE.default_routines(),
		"forgone": [],
		"planned_turn": 5,
	}
	GameState.core_loop_v2_state = month_two_state
	_expect_legacy_routine_effects("Month Two fallback", 2)
	_expect(CORE.month_for_turn(24) == 6 \
		and CORE.month_for_turn(48) == 12 \
		and CORE.month_for_turn(240) == 60,
		"24/48/240 horizon mapping changed")
	for future_turn in [24, 48, 240]:
		GameState.turn = future_turn
		_expect(not CORE.seoul_cycle_available(1),
			"Seoul Cycle leaked outside fresh Month One at turn %d" % future_turn)


func _check_conditional_trigger_roundtrip() -> void:
	_prepare_fresh_cycle_gate()
	var month_one := CORE.initialize_seoul_cycle(1)
	if not bool(month_one.get("ok", false)):
		_expect(false, "conditional-trigger fixture could not enroll Month One")
		return
	var audited := 0
	var specialized_owner_seen := false
	var threshold_override_seen := false
	for month_index in range(2, 5):
		GameState.turn = ((month_index - 1) * 4) + 1
		GameState.month = month_index
		GameState.week_of_month = 1
		if month_index == 4:
			# A real M2 cafe observation unlocks Sangchul's M4 encounter. Seed its
			# durable completed-bundle fact so this normalization fixture covers a
			# conditional people node whose generic owner becomes a named person.
			var causal_state: Dictionary = GameState.core_loop_v2_state.duplicate(
				true)
			if not (causal_state.get(
					"completed_bundles", []) as Array).has("cafe_world_glimpse"):
				causal_state["completed_bundles"].append("cafe_world_glimpse")
			causal_state["completed_bundle_turns"]["cafe_world_glimpse"] = 7
			GameState.core_loop_v2_state = causal_state
		var initialized := CORE.initialize_seoul_cycle(month_index)
		if not bool(initialized.get("ok", false)):
			_expect(false,
				"conditional-trigger fixture could not enroll Month %d" % month_index)
			return
		var snapshot := CORE.seoul_cycle_snapshot(month_index)
		var month_spec := CORE.seoul_cycle_month_spec(month_index)
		for raw_node_id in (month_spec.get("nodes", {}) as Dictionary):
			var node_id := str(raw_node_id)
			var authored_node: Dictionary = (month_spec.get(
				"nodes", {}) as Dictionary).get(node_id, {})
			if not authored_node.get("trigger_options", []) is Array \
					or (authored_node.get("trigger_options", []) as Array).is_empty():
				continue
			var runtime_node: Dictionary = (snapshot.get(
				"nodes", {}) as Dictionary).get(node_id, {})
			if str(runtime_node.get("trigger_bundle", "")).is_empty():
				continue
			var expected_identity := _conditional_trigger_identity(runtime_node)
			var serialized: Dictionary = GameState.serialize().duplicate(true)
			var serialized_v2: Dictionary = serialized.get(
				"core_loop_v2_state", {})
			var normalized_cycle := CORE.normalize_seoul_cycle_state(
				serialized_v2.get("seoul_cycle", {}))
			var normalized_node: Dictionary = (normalized_cycle.get(
				"nodes", {}) as Dictionary).get(node_id, {})
			_expect(_conditional_trigger_identity(normalized_node) \
					== expected_identity,
				"Month %d node %s normalization changed its resolved trigger identity" % [
					month_index, node_id])
			GameState.start_new_game()
			GameState.load_from_dict(serialized)
			CORE.initialize_for_run(true)
			var reloaded_node: Dictionary = (CORE.seoul_cycle_snapshot(
				month_index).get("nodes", {}) as Dictionary).get(node_id, {})
			_expect(_conditional_trigger_identity(reloaded_node) \
					== expected_identity,
				"Month %d node %s save roundtrip changed its resolved trigger identity" % [
					month_index, node_id])
			snapshot = CORE.seoul_cycle_snapshot(month_index)
			audited += 1
			specialized_owner_seen = specialized_owner_seen \
				or str(runtime_node.get("owner", "")) \
					!= str(authored_node.get("owner", ""))
			threshold_override_seen = threshold_override_seen \
				or int(runtime_node.get("threshold", 0)) \
					!= int(authored_node.get("threshold", 0))
	_expect(audited >= 2 and specialized_owner_seen and threshold_override_seen,
		"conditional-trigger roundtrip coverage missing: audited=%d owner=%s threshold=%s" % [
			audited, str(specialized_owner_seen), str(threshold_override_seen)])
	_check_m6_people_trigger_roundtrip(
		"m6_daeun_tuesday_followthrough", "daeun")
	_check_m6_people_trigger_roundtrip("hyunsu_exam_eve", "hyunsu")


func _check_m6_people_trigger_roundtrip(
		expected_bundle: String, expected_owner: String) -> void:
	_prepare_fresh_cycle_gate()
	for month_index in range(1, 6):
		GameState.turn = ((month_index - 1) * 4) + 1
		GameState.month = month_index
		GameState.week_of_month = 1
		var initialized := CORE.initialize_seoul_cycle(month_index)
		if not bool(initialized.get("ok", false)):
			_expect(false,
				"M6 %s fixture could not enroll Month %d" % [
					expected_owner, month_index])
			return
	var causal_state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	var completed: Array = causal_state.get("completed_bundles", [])
	var completed_turns: Dictionary = causal_state.get(
		"completed_bundle_turns", {})
	var stages: Dictionary = causal_state.get("relationship_stages", {})
	if expected_owner == "daeun":
		if not completed.has("daeun_shared_dream"):
			completed.append("daeun_shared_dream")
		completed_turns["daeun_shared_dream"] = 20
		stages["daeun"] = "shared_commitment"
		var memories: Array = causal_state.get("relationship_memories", [])
		memories.append({
			"character": "daeun",
			"memory": "daeun_same_tuesday_promised",
			"bundle_id": "daeun_shared_dream",
			"turn": 20,
		})
		causal_state["relationship_memories"] = memories
	else:
		if not completed.has("hyunsu_study_followup"):
			completed.append("hyunsu_study_followup")
		completed_turns["hyunsu_study_followup"] = 11
		stages["hyunsu"] = "shared_commitment"
	causal_state["completed_bundles"] = completed
	causal_state["completed_bundle_turns"] = completed_turns
	causal_state["relationship_stages"] = stages
	GameState.core_loop_v2_state = causal_state
	GameState.turn = 21
	GameState.month = 6
	GameState.week_of_month = 1
	var initialized_m6 := CORE.initialize_seoul_cycle(6)
	if not bool(initialized_m6.get("ok", false)):
		_expect(false, "M6 %s conditional people fixture could not enroll" % [
			expected_owner])
		return
	var runtime_node: Dictionary = (CORE.seoul_cycle_snapshot(
		6).get("nodes", {}) as Dictionary).get("m6_people", {})
	var expected_identity := _conditional_trigger_identity(runtime_node)
	_expect(str(runtime_node.get("trigger_bundle", "")) == expected_bundle \
		and str(runtime_node.get("owner", "")) == expected_owner \
		and str(runtime_node.get("commitment_action_id", "")) == "contact" \
		and str(runtime_node.get("axis", "")) == "human" \
		and int(runtime_node.get("trigger_min_week", 0)) \
			in range(1, 5) \
		and int(runtime_node.get("trigger_deadline_week", 0)) \
			in range(1, 5),
		"M6 %s conditional people trigger did not resolve to its authored identity: %s" % [
			expected_owner, str(runtime_node)])
	var trigger_week := int(runtime_node.get("trigger_min_week", 0))
	GameState.turn = 20 + trigger_week
	GameState.month = 6
	GameState.week_of_month = trigger_week
	var trigger_snapshot := CORE.seoul_cycle_snapshot(6)
	var trigger_capacities: Array = trigger_snapshot.get("capacities", [])
	var capacity_id := str((trigger_capacities[0] as Dictionary).get(
		"id", "")) if not trigger_capacities.is_empty() else ""
	var preview: Dictionary = CORE.preview_seoul_cycle_allocation(
		capacity_id, "m6_people", 6)
	var payload: Dictionary = CORE._seoul_cycle_commitment_payload(
		trigger_snapshot, "m6_people", capacity_id, preview)
	_expect(bool(preview.get("ok", false)) \
		and str(payload.get("choice_id", "")) == "contact" \
		and str(payload.get("person_id", "")) == expected_owner \
		and str(payload.get("axis", "")) == "human" \
		and str((payload.get("details", {}) as Dictionary).get(
			"node_id", "")) == "m6_people",
		"M6 %s conditional contact payload lost its authored person/axis: %s / %s" % [
			expected_owner, str(preview), str(payload)])
	var serialized: Dictionary = GameState.serialize().duplicate(true)
	var serialized_v2: Dictionary = serialized.get("core_loop_v2_state", {})
	var normalized_cycle := CORE.normalize_seoul_cycle_state(
		serialized_v2.get("seoul_cycle", {}))
	var normalized_node: Dictionary = (normalized_cycle.get(
		"nodes", {}) as Dictionary).get("m6_people", {})
	_expect(_conditional_trigger_identity(normalized_node) == expected_identity,
		"M6 %s normalization changed its conditional people identity" % [
			expected_owner])
	GameState.start_new_game()
	GameState.load_from_dict(serialized)
	CORE.initialize_for_run(true)
	var reloaded_node: Dictionary = (CORE.seoul_cycle_snapshot(
		6).get("nodes", {}) as Dictionary).get("m6_people", {})
	_expect(_conditional_trigger_identity(reloaded_node) == expected_identity,
		"M6 %s save roundtrip changed its conditional people identity" % [
			expected_owner])


func _conditional_trigger_identity(node: Dictionary) -> Dictionary:
	var identity: Dictionary = {}
	for key in [
		"trigger_bundle", "summary_bundle", "threshold", "deadline_week",
		"trigger_min_week", "trigger_deadline_week", "owner",
		"commitment_action_id", "axis", "label_ko", "label_en",
	]:
		identity[key] = node.get(key, null)
	return identity


func _check_cycle_routine_and_livelihood() -> void:
	_prepare_fresh_cycle_gate()
	var initialized := CORE.initialize_seoul_cycle(1)
	if not bool(initialized.get("ok", false)):
		_expect(false, "routine/livelihood path could not initialize")
		return
	_expect(CORE.routine_selection_for_month(1).is_empty(),
		"fresh Seoul Cycle exposed legacy default routines")
	var before_routine: Dictionary = GameState.serialize().duplicate(true)
	var first_suppression := CORE.apply_background_routines_for_turn(1)
	var after_first_suppression: Dictionary = GameState.serialize().duplicate(true)
	var second_suppression := CORE.apply_background_routines_for_turn(1)
	var suppressed_receipts: Dictionary = GameState.core_loop_v2_state.get(
		"routine_receipts", {})
	_expect(bool(first_suppression.get("ok", false)) \
		and not bool(first_suppression.get("applied", true)) \
		and bool(first_suppression.get("suppressed", false)) \
		and bool(second_suppression.get("suppressed", false)) \
		and (first_suppression.get("receipt", {}) as Dictionary).get(
			"effects", {}) == {} \
		and (first_suppression.get("receipt", {}) as Dictionary).get(
			"units", []) == [] \
		and float(before_routine.get("money", 0.0)) \
			== float(after_first_suppression.get("money", -1.0)) \
		and int(before_routine.get("health", 0)) \
			== int(after_first_suppression.get("health", -1)) \
		and int(before_routine.get("mental", 0)) \
			== int(after_first_suppression.get("mental", -1)) \
		and GameState.serialize() == after_first_suppression \
		and suppressed_receipts.size() == 1,
		"fresh cycle routine suppression changed stats or duplicated its receipt")

	var snapshot := CORE.seoul_cycle_snapshot(1)
	var low_capacity := _unused_capacity(snapshot, 0, false)
	var money_before := float(GameState.money)
	var health_before := int(GameState.health)
	var mental_before := int(GameState.mental)
	var preview := CORE.preview_seoul_cycle_allocation(
		low_capacity, "convenience", 1)
	var allocation := CORE.commit_seoul_cycle_allocation(
		low_capacity, "convenience", 1)
	var allocation_receipt: Dictionary = allocation.get("receipt", {})
	var allocation_effects: Dictionary = allocation_receipt.get("effects", {})
	_expect(bool(preview.get("ok", false)) \
		and float((preview.get("immediate_effects", {}) as Dictionary).get(
			"money", 0.0)) == 70000.0 \
		and bool(allocation.get("ok", false)) \
		and float(GameState.money) == money_before + 70000.0 \
		and int(GameState.health) == health_before - 1 \
		and int(GameState.mental) == mental_before - 1 \
		and float(allocation_effects.get("money", 0.0)) == 70000.0,
		"a convenience allocation did not own exactly KRW 70K and its costs")
	# This KRW 70K is the existing unemployed livelihood baseline moved onto
	# the visible node. It is explicitly provisional until first-run balance QA.
	var after_allocation: Dictionary = GameState.serialize().duplicate(true)
	var duplicate := CORE.commit_seoul_cycle_allocation(
		low_capacity, "convenience", 1)
	_expect(not bool(duplicate.get("ok", false)) \
		and GameState.serialize() == after_allocation,
		"convenience allocation paid the provisional KRW 70K twice")
	var saved: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	CORE.initialize_for_run(true)
	_expect(float(GameState.money) == money_before + 70000.0 \
		and (GameState.core_loop_v2_state.get(
			"routine_receipts", {}) as Dictionary).size() == 1,
		"livelihood allocation or suppressed receipt changed on save roundtrip")
	_expect(bool(CORE.complete_seoul_cycle_turn(1).get("ok", false)),
		"W1 livelihood allocation could not close after save roundtrip")
	_advance_to_next_week()

	# Resolve the featured W2 cover shift through its real supplemental action
	# and story receipts. W3/W4 must then remain available as ordinary repeat
	# livelihood allocations without manufacturing a trigger-expiry receipt.
	_expect_cycle_routine_suppressed(2)
	snapshot = CORE.seoul_cycle_snapshot(1)
	var completion_capacity := _unused_capacity(snapshot, 3, true)
	var completion_preview := CORE.preview_seoul_cycle_allocation(
		completion_capacity, "convenience", 1)
	var completion_commit := CORE.commit_seoul_cycle_allocation(
		completion_capacity, "convenience", 1)
	_expect(bool(completion_preview.get("ok", false)) \
		and bool(completion_preview.get("completed_now", false)) \
		and str(completion_preview.get("trigger_bundle", "")) \
			== "m1_convenience_trial_shift" \
		and bool(completion_commit.get("ok", false)),
		"W2 livelihood focus did not complete its featured cover shift")
	if not _resolve_cycle_side_shift_trigger("m1_convenience_trial_shift"):
		return
	_expect(bool(CORE.complete_seoul_cycle_turn(1).get("ok", false)),
		"resolved W2 livelihood trigger did not close")
	_advance_to_next_week()

	_expect_cycle_routine_suppressed(3)
	snapshot = CORE.seoul_cycle_snapshot(1)
	var w3_capacity := _unused_capacity(snapshot, 0, false)
	var w3_commit := CORE.commit_seoul_cycle_allocation(
		w3_capacity, "convenience", 1)
	_expect(bool(w3_commit.get("ok", false)) \
		and bool(w3_commit.get("repeat_allocation", false)) \
		and str((w3_commit.get("pending_world", {}) as Dictionary).get(
			"bundle_id", "")) == "hyunsu_first_meet",
		"resolved livelihood node was not repeatable when W3 world arrived")
	if not _resolve_cycle_story_world("hyunsu_first_meet", HYUNSU_EVENT, 0):
		return
	_expect(bool(CORE.complete_seoul_cycle_turn(1).get("ok", false)),
		"W3 repeated livelihood allocation could not close")
	_advance_to_next_week()

	_expect_cycle_routine_suppressed(4)
	snapshot = CORE.seoul_cycle_snapshot(1)
	var w4_capacity := _unused_capacity(snapshot, 0, false)
	var w4_commit := CORE.commit_seoul_cycle_allocation(
		w4_capacity, "convenience", 1)
	_expect(bool(w4_commit.get("ok", false)) \
		and bool(w4_commit.get("repeat_allocation", false)) \
		and str((w4_commit.get("receipt", {}) as Dictionary).get(
			"node_id", "")) == "convenience" \
		and str((w4_commit.get("pending_world", {}) as Dictionary).get(
			"bundle_id", "")) == "first_temptation_boss",
		"W4 did not accept the fourth real livelihood allocation")
	if not _resolve_cycle_story_world(
			"first_temptation_boss", TEMPTATION_EVENT, 0):
		return
	_expect(bool(CORE.complete_seoul_cycle_turn(1).get("ok", false)),
		"W4 repeated livelihood allocation could not close")
	var livelihood_final := CORE.seoul_cycle_snapshot(1)
	var livelihood_trigger: Dictionary = (
		livelihood_final.get("trigger_receipts", {}) as Dictionary).get(
			"convenience", {})
	_expect(str(livelihood_trigger.get("status", "")) == "resolved" \
		and str(livelihood_trigger.get("bundle_id", "")) \
			== "m1_convenience_trial_shift" \
		and int(livelihood_trigger.get("turn", 0)) == 2 \
		and not (livelihood_final.get(
			"expiry_receipts", {}) as Dictionary).has("convenience:trigger") \
		and bool(((livelihood_final.get(
			"allocation_receipts", {}) as Dictionary).get(
				"4", {}) as Dictionary).get("repeat_allocation", false)),
		"resolved livelihood route expired its trigger or lost its W4 repeat receipt")


func _check_four_week_cycle() -> void:
	_prepare_fresh_cycle_gate()
	var initialized := CORE.initialize_seoul_cycle(1)
	if not bool(initialized.get("ok", false)):
		_expect(false, "four-week path could not initialize")
		return
	var initial_capacities: Array = CORE.seoul_cycle_snapshot(1).get(
		"capacities", []).duplicate(true)
	_expect_cycle_routine_suppressed(1)

	# W1: spend a medium/strong value on Father, prove relationship receipt,
	# and prove the bundle cannot close the week before the cycle transaction.
	var snapshot := CORE.seoul_cycle_snapshot(1)
	var father_capacity := _unused_capacity(snapshot, 3, true)
	var father_preview := CORE.preview_seoul_cycle_allocation(
		father_capacity, "father", 1)
	_expect(bool(father_preview.get("ok", false)) \
		and int(father_preview.get("progress_gain", 0)) >= 2 \
		and bool(father_preview.get("completed_now", false)) \
		and str(father_preview.get("trigger_bundle", "")) \
			== "father_first_call",
		"W1 Father preview did not show exact progress and trigger")
	var father_commit := CORE.commit_seoul_cycle_allocation(
		father_capacity, "father", 1)
	var after_father_commit: Dictionary = GameState.serialize().duplicate(true)
	var duplicate_commit := CORE.commit_seoul_cycle_allocation(
		father_capacity, "father", 1)
	_expect(bool(father_commit.get("ok", false)) \
		and not bool(duplicate_commit.get("ok", false)) \
		and str(duplicate_commit.get("error", "")) \
			== "allocation_already_committed" \
		and GameState.serialize() == after_father_commit,
		"duplicate W1 commit consumed effects or capacity twice")
	var father_claim := CORE.claim_seoul_cycle_trigger()
	var father_reclaim := CORE.claim_seoul_cycle_trigger()
	_expect(bool(father_claim.get("ok", false)) \
		and not bool(father_claim.get("resumed", true)) \
		and bool(father_reclaim.get("ok", false)) \
		and bool(father_reclaim.get("resumed", false)),
		"node trigger claim was not idempotent across resume")
	_expect(CORE.begin_seoul_cycle_trigger("father_first_call") \
		and CORE.active_bundle_is_seoul_cycle_trigger(),
		"Father trigger did not enter the existing schedule receipt path")
	_apply_and_note_story(FATHER_EVENT, 0)
	_expect(_has_relationship_receipt("father_first_call", "father"),
		"Father choice did not create the existing relationship receipt")
	var father_completed_bundle := CORE.complete_active_bundle()
	var father_resolved_again := CORE.resolve_seoul_cycle_trigger("father_first_call")
	_expect(father_completed_bundle == "father_first_call" \
		and not CORE.turn_completed(1) \
		and CORE.pending_seoul_cycle_trigger().is_empty() \
		and father_resolved_again,
		"Father surface closed the week early or did not resolve exactly once")
	_expect(bool(CORE.complete_seoul_cycle_turn(1).get("ok", false)) \
		and CORE.turn_completed(1),
		"W1 cycle transaction did not atomically close the week")
	_advance_to_next_week()

	# W2: complete recovery without inventing a second surface.
	_expect_cycle_routine_suppressed(2)
	snapshot = CORE.seoul_cycle_snapshot(1)
	var recovery_capacity := _unused_capacity(snapshot, 0, true)
	var recovery_commit := CORE.commit_seoul_cycle_allocation(
		recovery_capacity, "recovery", 1)
	_expect(bool(recovery_commit.get("ok", false)) \
		and (recovery_commit.get("pending_trigger", {}) as Dictionary).is_empty() \
		and bool(recovery_commit.get("turn_ready", false)),
		"recovery did not resolve as an immediate no-minigame allocation")
	_expect(bool(CORE.complete_seoul_cycle_turn(1).get("ok", false)),
		"W2 recovery could not close")
	_advance_to_next_week()

	# W3: the player allocation happens first, then Hyunsu arrives once.
	_expect_cycle_routine_suppressed(3)
	snapshot = CORE.seoul_cycle_snapshot(1)
	var w3_capacity := _unused_capacity(snapshot, 0, false)
	var w3_commit := CORE.commit_seoul_cycle_allocation(
		w3_capacity, "recovery", 1)
	_expect(bool(w3_commit.get("ok", false)) \
		and str((w3_commit.get("pending_world", {}) as Dictionary).get(
			"bundle_id", "")) == "hyunsu_first_meet" \
		and not bool(w3_commit.get("turn_ready", true)),
		"W3 Hyunsu did not arrive after the allocation")
	var hyunsu_claim := CORE.claim_seoul_cycle_world()
	var hyunsu_reclaim := CORE.claim_seoul_cycle_world()
	_expect(bool(hyunsu_claim.get("ok", false)) \
		and bool(hyunsu_reclaim.get("resumed", false)) \
		and CORE.begin_seoul_cycle_world("hyunsu_first_meet") \
		and CORE.active_bundle_is_seoul_cycle_world(),
		"W3 world claim/begin was not exactly-once resumable")
	_apply_and_note_story(HYUNSU_EVENT, 0)
	_expect(_has_relationship_receipt("hyunsu_first_meet", "hyunsu"),
		"Hyunsu choice did not create the existing relationship receipt")
	var hyunsu_completed_bundle := CORE.complete_active_bundle()
	var hyunsu_resolved_again := CORE.resolve_seoul_cycle_world("hyunsu_first_meet")
	_expect(hyunsu_completed_bundle == "hyunsu_first_meet" \
		and not CORE.turn_completed(3) \
		and CORE.pending_seoul_cycle_world().is_empty() \
		and not bool(CORE.claim_seoul_cycle_world().get("ok", false)) \
		and hyunsu_resolved_again,
		"W3 world replayed or completed the calendar before cycle close")
	var w3_close := CORE.complete_seoul_cycle_turn(1)
	var w3_snapshot := CORE.seoul_cycle_snapshot(1)
	var w3_nodes: Dictionary = w3_snapshot.get("nodes", {})
	var w3_convenience: Dictionary = w3_nodes.get("convenience", {})
	var w3_trigger_expiry: Dictionary = (
		w3_snapshot.get("expiry_receipts", {}) as Dictionary).get(
			"convenience:trigger", {})
	_expect(bool(w3_close.get("ok", false)) \
		and not (w3_close.get("expired_nodes", []) as Array).has(
			"convenience") \
		and (w3_close.get("expired_nodes", []) as Array).has("resume") \
		and not (w3_snapshot.get("expired_nodes", []) as Array).has(
			"convenience") \
		and (w3_snapshot.get("expired_nodes", []) as Array).has("resume") \
		and str(w3_convenience.get("status", "")) == "open" \
		and int(w3_convenience.get("progress", -1)) == 0 \
		and bool(w3_convenience.get(
			"repeatable_after_completion", false)) \
		and str(w3_convenience.get("featured_status", "")) == "expired" \
		and bool(w3_convenience.get("fallback_mode", false)) \
		and str(w3_convenience.get("missed_trigger_bundle", "")) \
			== "m1_convenience_trial_shift" \
		and str(w3_trigger_expiry.get("scope", "")) == "trigger" \
		and str(w3_trigger_expiry.get("status", "")) == "consumed" \
		and str(w3_trigger_expiry.get("node_id", "")) == "convenience" \
		and str(w3_trigger_expiry.get("trigger_bundle", "")) \
			== "m1_convenience_trial_shift" \
		and int(w3_trigger_expiry.get("turn", 0)) == 3 \
		and int(w3_trigger_expiry.get("week_index", 0)) == 3,
		"W3 featured expiry forged progress instead of opening the generic livelihood fallback")
	_advance_to_next_week()

	# W4: the missed featured shift has become a generic livelihood fallback.
	# It pays the ordinary weekly effects without forging clock progress, then
	# the fixed temptation reads that actual latest receipt.
	_expect_cycle_routine_suppressed(4)
	snapshot = CORE.seoul_cycle_snapshot(1)
	var w4_capacity := _unused_capacity(snapshot, 0, false)
	var w4_commit := CORE.commit_seoul_cycle_allocation(
		w4_capacity, "convenience", 1)
	_expect(bool(w4_commit.get("ok", false)) \
		and bool(w4_commit.get("fallback_allocation", false)) \
		and not bool(w4_commit.get("repeat_allocation", true)) \
		and not bool(w4_commit.get("completed_now", true)) \
		and int(w4_commit.get("progress_gain", -1)) == 0 \
		and float(((w4_commit.get("receipt", {}) as Dictionary).get(
			"effects", {}) as Dictionary).get("money", 0.0)) == 70000.0 \
		and str((w4_commit.get("pending_world", {}) as Dictionary).get(
			"bundle_id", "")) == "first_temptation_boss",
		"W4 generic livelihood fallback forged progress or lost its ordinary pay")
	# Reproduce the real BUILD 2026.08.11.2 boundary: autosave while the W4
	# world beat is pending, JSON reload (all numbers become floats), then the
	# story resolves. The receipt key must still be the canonical integer week.
	var w4_money_before_reload := float(GameState.money)
	var w4_health_before_reload := int(GameState.health)
	var w4_mental_before_reload := int(GameState.mental)
	var w4_pending_json: Variant = JSON.parse_string(
		JSON.stringify(GameState.serialize()))
	_expect(w4_pending_json is Dictionary,
		"W4 pending-world JSON fixture could not be parsed")
	if not w4_pending_json is Dictionary:
		return
	GameState.start_new_game()
	GameState.load_from_dict(w4_pending_json as Dictionary)
	CORE.initialize_for_run(true)
	_expect(str(CORE.pending_seoul_cycle_world().get(
		"bundle_id", "")) == "first_temptation_boss" \
		and float(GameState.money) == w4_money_before_reload \
		and int(GameState.health) == w4_health_before_reload \
		and int(GameState.mental) == w4_mental_before_reload,
		"W4 pending-world JSON reload changed the allocation or lost its owner")
	_expect(bool(CORE.claim_seoul_cycle_world().get("ok", false)) \
		and CORE.begin_seoul_cycle_world("first_temptation_boss"),
		"W4 temptation could not enter the existing story surface")
	_apply_and_note_story(TEMPTATION_EVENT, 0)
	LocaleManager.set_language("ko")
	var ko_echo := CORE.month_one_episode_echo()
	LocaleManager.set_language("en")
	var en_echo := CORE.month_one_episode_echo()
	_expect("영수증" in ko_echo and "receipt" in en_echo.to_lower() \
		and not _contains_hangul(en_echo),
		"W4 echo did not read the actual latest livelihood receipt in KO/EN")
	var temptation_completed_bundle := CORE.complete_active_bundle()
	var temptation_resolved_again := CORE.resolve_seoul_cycle_world("first_temptation_boss")
	var canonical_w4_snapshot := CORE.seoul_cycle_snapshot(1)
	var canonical_w4_world: Dictionary = canonical_w4_snapshot.get(
		"world_receipts", {})
	var w4_money_after_resolution := float(GameState.money)
	var w4_health_after_resolution := int(GameState.health)
	var w4_mental_after_resolution := int(GameState.mental)
	_expect(temptation_completed_bundle == "first_temptation_boss" \
		and not CORE.turn_completed(4) \
		and temptation_resolved_again \
		and canonical_w4_world.has("4") \
		and not canonical_w4_world.has("4.0") \
		and bool(canonical_w4_snapshot.get("turn_ready", false)),
		"W4 world completed early or wrote a non-canonical receipt after JSON reload")

	# Existing user saves may already contain the exact legacy alias `"4.0"`.
	# Load that shape and prove it recovers without replaying effects or story.
	var collision_cycle: Dictionary = (GameState.core_loop_v2_state.get(
		"seoul_cycle", {}) as Dictionary).duplicate(true)
	var collision_world: Dictionary = collision_cycle.get(
		"world_receipts", {})
	collision_world["4.0"] = (collision_world.get(
		"4", {}) as Dictionary).duplicate(true)
	collision_cycle["world_receipts"] = collision_world
	_expect(CORE.normalize_seoul_cycle_state(collision_cycle).is_empty(),
		"world receipt canonical/legacy key collision did not fail closed")
	var raw_collision_cycle: Dictionary = collision_cycle.duplicate(true)
	var raw_collision_world: Dictionary = raw_collision_cycle.get(
		"world_receipts", {})
	raw_collision_world["4"] = "corrupt canonical receipt"
	raw_collision_cycle["world_receipts"] = raw_collision_world
	_expect(CORE.normalize_seoul_cycle_state(raw_collision_cycle).is_empty(),
		"non-dictionary canonical key hid a legacy-alias collision")
	var malformed_alias_cycle: Dictionary = collision_cycle.duplicate(true)
	var malformed_alias_world: Dictionary = malformed_alias_cycle.get(
		"world_receipts", {})
	malformed_alias_world.erase("4")
	var malformed_alias: Dictionary = malformed_alias_world.get(
		"4.0", {})
	malformed_alias["resolved_turn"] = 3
	malformed_alias_world["4.0"] = malformed_alias
	malformed_alias_cycle["world_receipts"] = malformed_alias_world
	var malformed_normalized := CORE.normalize_seoul_cycle_state(
		malformed_alias_cycle)
	_expect(not malformed_normalized.is_empty() \
		and not (malformed_normalized.get(
			"world_receipts", {}) as Dictionary).has("4") \
		and not CORE._seoul_cycle_turn_ready(malformed_normalized, 4),
		"malformed legacy alias was promoted into a closable Week 4 receipt")

	var legacy_alias_save: Dictionary = GameState.serialize().duplicate(true)
	var legacy_v2: Dictionary = legacy_alias_save.get(
		"core_loop_v2_state", {})
	var legacy_cycle: Dictionary = legacy_v2.get(
		"seoul_cycle", {})
	var legacy_world: Dictionary = legacy_cycle.get("world_receipts", {})
	legacy_world["4.0"] = (legacy_world.get(
		"4", {}) as Dictionary).duplicate(true)
	legacy_world.erase("4")
	legacy_cycle["world_receipts"] = legacy_world
	legacy_v2["seoul_cycle"] = legacy_cycle
	legacy_alias_save["core_loop_v2_state"] = legacy_v2
	var legacy_alias_json: Variant = JSON.parse_string(
		JSON.stringify(legacy_alias_save))
	_expect(legacy_alias_json is Dictionary,
		"legacy W4 world-receipt JSON fixture could not be parsed")
	if not legacy_alias_json is Dictionary:
		return
	GameState.start_new_game()
	GameState.load_from_dict(legacy_alias_json as Dictionary)
	CORE.initialize_for_run(true)
	var recovered_w4_snapshot := CORE.seoul_cycle_snapshot(1)
	var recovered_w4_world: Dictionary = recovered_w4_snapshot.get(
		"world_receipts", {})
	_expect(recovered_w4_world.has("4") \
		and not recovered_w4_world.has("4.0") \
		and bool(recovered_w4_snapshot.get("turn_ready", false)) \
		and float(GameState.money) == w4_money_after_resolution \
		and int(GameState.health) == w4_health_after_resolution \
		and int(GameState.mental) == w4_mental_after_resolution,
		"legacy W4 receipt alias did not recover the user's exact stalled state")
	_expect(bool(CORE.complete_seoul_cycle_turn(1).get("ok", false)) \
		and CORE.turn_completed(4),
		"W4 cycle transaction did not close exactly once")

	var final_snapshot := CORE.seoul_cycle_snapshot(1)
	var consumed_ids: Array[String] = []
	for raw_capacity in final_snapshot.get("capacities", []):
		if raw_capacity is Dictionary \
				and bool((raw_capacity as Dictionary).get("consumed", false)):
			consumed_ids.append(str((raw_capacity as Dictionary).get("id", "")))
	_expect(consumed_ids.size() == 4 \
		and _sorted_strings(consumed_ids) \
			== _sorted_strings(_capacity_ids(initial_capacities)) \
		and int(final_snapshot.get("world_clock", 0)) == 4 \
		and (final_snapshot.get("completed_turns", []) as Array) \
			== [1, 2, 3, 4] \
		and (final_snapshot.get("allocation_receipts", {}) as Dictionary).size() \
			== 4 \
		and (final_snapshot.get("world_receipts", {}) as Dictionary).size() == 2,
		"four values/receipts/world ticks were not consumed exactly once")
	var month_before := CORE.month_opening_snapshot(1)
	var month_after := {
		"money": float(GameState.money),
		"monthly_income": float(GameState.monthly_income),
		"health": int(GameState.health),
		"mental": int(GameState.mental),
	}
	var summary := CORE.record_month_summary(1, month_before, month_after)
	var summary_nodes: Dictionary = summary.get("node_states", {})
	_expect(str(summary.get("planning_mode", "")) \
		== CORE.SEOUL_CYCLE_MODE \
		and (summary.get("allocation_receipts", []) as Array).size() == 4 \
		and (summary.get("kept", []) as Array).size() == 4 \
		and summary.get("routines", {}) == {} \
		and summary.get("decline_receipts", []) is Array \
		and str((summary_nodes.get("father", {}) as Dictionary).get(
			"status", "")) == "completed" \
		and str((summary_nodes.get("recovery", {}) as Dictionary).get(
			"status", "")) == "completed" \
		and str((summary_nodes.get("convenience", {}) as Dictionary).get(
			"status", "")) == "expired" \
		and str((summary_nodes.get("resume", {}) as Dictionary).get(
			"status", "")) == "expired" \
		and (summary.get("expired_nodes", []) as Array).has("convenience") \
		and (summary.get("expired_nodes", []) as Array).has("resume") \
		and str(((summary.get("expiry_receipts", {}) as Dictionary).get(
			"convenience:trigger", {}) as Dictionary).get(
				"scope", "")) == "trigger" \
		and str(((summary.get("expiry_receipts", {}) as Dictionary).get(
			"convenience:trigger", {}) as Dictionary).get(
				"status", "")) == "consumed" \
		and (GameState.core_loop_v2_state.get(
			"routine_receipts", {}) as Dictionary).size() == 4,
		"cycle month summary did not preserve four allocations and final nodes")
	_expect(CORE.record_month_summary(1, {}, {}) == summary,
		"cycle month summary was not idempotent")
	var saved_cycle: Dictionary = GameState.core_loop_v2_state.get(
		"seoul_cycle", {}).duplicate(true)
	var saved_summary: Dictionary = summary.duplicate(true)
	var saved_run: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(saved_run)
	CORE.initialize_for_run(true)
	_expect(GameState.core_loop_v2_state.get("seoul_cycle", {}) \
		== saved_cycle \
		and CORE.month_summary(1) == saved_summary,
		"mid/final cycle save changed after normalization")
	for future_turn in [24, 48, 240]:
		GameState.turn = future_turn
		_expect(not CORE.seoul_cycle_snapshot(1).get("active", true) \
			and not CORE.seoul_cycle_available(1),
			"completed Month-One cycle leaked into turn %d" % future_turn)


func _expect_legacy_routine_effects(label: String, month_index: int) -> void:
	var expected_routines := CORE.default_routines()
	_expect(CORE.routine_selection_for_month(month_index) == expected_routines,
		"%s routine selection changed" % label)
	var money_before := float(GameState.money)
	var health_before := int(GameState.health)
	var mental_before := int(GameState.mental)
	var first := CORE.apply_background_routines_for_turn(GameState.turn)
	var after_first: Dictionary = GameState.serialize().duplicate(true)
	var second := CORE.apply_background_routines_for_turn(GameState.turn)
	var receipt: Dictionary = first.get("receipt", {})
	_expect(bool(first.get("ok", false)) \
		and bool(first.get("applied", false)) \
		and not bool(first.get("suppressed", false)) \
		and float(GameState.money) == money_before + 70000.0 \
		and int(GameState.health) == health_before \
		and int(GameState.mental) == mental_before + 4 \
		and float((receipt.get("effects", {}) as Dictionary).get(
			"money", 0.0)) == 70000.0 \
		and int((receipt.get("effects", {}) as Dictionary).get(
			"mental", 0)) == 4 \
		and not bool(second.get("applied", true)) \
		and not bool(second.get("suppressed", false)) \
		and GameState.serialize() == after_first,
		"%s legacy background routine effects/idempotence changed" % label)


func _expect_cycle_routine_suppressed(turn: int) -> void:
	var money_before := float(GameState.money)
	var health_before := int(GameState.health)
	var mental_before := int(GameState.mental)
	var result := CORE.apply_background_routines_for_turn(turn)
	var after_first: Dictionary = GameState.serialize().duplicate(true)
	var replay := CORE.apply_background_routines_for_turn(turn)
	var receipt: Dictionary = result.get("receipt", {})
	_expect(bool(result.get("ok", false)) \
		and not bool(result.get("applied", true)) \
		and bool(result.get("suppressed", false)) \
		and bool(replay.get("suppressed", false)) \
		and str(receipt.get("status", "")) == "suppressed" \
		and str(receipt.get("planning_mode", "")) \
			== CORE.SEOUL_CYCLE_MODE \
		and receipt.get("effects", {}) == {} \
		and receipt.get("units", []) == [] \
		and float(GameState.money) == money_before \
		and int(GameState.health) == health_before \
		and int(GameState.mental) == mental_before \
		and GameState.serialize() == after_first,
		"cycle routine suppression failed or duplicated at turn %d" % turn)


func _prepare_base_v2() -> void:
	LocaleManager.set_language("ko")
	GameState.start_new_game()
	CORE.initialize_for_run(true)


func _prepare_fresh_cycle_gate() -> void:
	_prepare_base_v2()
	GameState.flags["prologue_done"] = true
	var state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	state["application_statuses"]["mirae_industrial_tech"] = "interviewed"
	GameState.core_loop_v2_state = state


func _resolve_cycle_side_shift_trigger(bundle_id: String) -> bool:
	var claimed := CORE.claim_seoul_cycle_trigger()
	var began := bool(claimed.get("ok", false)) \
		and CORE.begin_seoul_cycle_trigger(bundle_id)
	var armed := began and GameState.arm_weekly_commitment({
		"turn": int(GameState.turn),
		"pressure_id": bundle_id,
		"pressure_family": "livelihood",
		"choice_id": "side_shift",
		"forgone_ids": [],
		"supplemental_to_seoul_cycle": true,
	})
	var transaction: Dictionary = {}
	if armed:
		transaction = GameState.finalize_weekly_effect_action(
			"side_shift", {}, "money", "work", "", {
				"execution": "side_shift",
				"axis": "money",
				"place_id": "work",
				"effects": {},
			})
	var action_noted := bool(transaction.get("ok", false)) \
		and CORE.note_action_commitment(
			transaction.get("record", {}) as Dictionary)
	var acknowledged := action_noted \
		and CORE.acknowledge_action_story_result(bundle_id)
	_expect(bool(claimed.get("ok", false)) and began and armed \
		and bool(transaction.get("ok", false)) and action_noted \
		and acknowledged,
		"livelihood trigger did not produce its supplemental action receipt")
	if not acknowledged:
		return false
	_apply_and_note_story("v2_convenience_trial_shift", 0)
	var completed := CORE.complete_active_bundle()
	_expect(completed == bundle_id \
		and CORE.pending_seoul_cycle_trigger().is_empty(),
		"livelihood trigger did not resolve its authored story receipt")
	return completed == bundle_id


func _resolve_cycle_story_world(
		bundle_id: String, event_id: String, choice_index: int) -> bool:
	var claimed := CORE.claim_seoul_cycle_world()
	var began := bool(claimed.get("ok", false)) \
		and CORE.begin_seoul_cycle_world(bundle_id)
	_expect(bool(claimed.get("ok", false)) and began,
		"world beat %s could not be claimed and begun" % bundle_id)
	if not began:
		return false
	_apply_and_note_story(event_id, choice_index)
	var completed := CORE.complete_active_bundle()
	_expect(completed == bundle_id \
		and CORE.pending_seoul_cycle_world().is_empty(),
		"world beat %s did not resolve exactly once" % bundle_id)
	return completed == bundle_id


func _apply_and_note_story(event_id: String, choice_index: int) -> void:
	var event: Dictionary = DataRegistry.find_event(event_id)
	var choices: Array = event.get("choices", [])
	_expect(not event.is_empty() and choice_index >= 0 \
		and choice_index < choices.size(),
		"missing story event/choice: %s" % event_id)
	if event.is_empty() or choice_index < 0 or choice_index >= choices.size():
		return
	_expect(GameState.apply_choice(event, choices[choice_index] as Dictionary),
		"GameState rejected authored story choice: %s" % event_id)
	_expect(CORE.note_story_choice(event_id, choice_index),
		"cycle owner rejected story receipt: %s" % event_id)


func _has_relationship_receipt(bundle_id: String, character_id: String) -> bool:
	var receipts: Dictionary = GameState.core_loop_v2_state.get(
		"relationship_choice_receipts", {})
	for raw_receipt in receipts.values():
		if raw_receipt is Dictionary \
				and str((raw_receipt as Dictionary).get("bundle_id", "")) \
					== bundle_id \
				and str((raw_receipt as Dictionary).get("character", "")) \
					== character_id \
				and int((raw_receipt as Dictionary).get("turn", 0)) \
					== int(GameState.turn):
			return true
	return false


func _meta_node_count(root: Node, meta_key: String) -> int:
	if not is_instance_valid(root):
		return 0
	var count := 1 if root.has_meta(meta_key) else 0
	for child in root.get_children():
		count += _meta_node_count(child, meta_key)
	return count


func _unused_capacity(
		snapshot: Dictionary, minimum_value: int,
		prefer_high: bool) -> String:
	var candidates: Array[Dictionary] = []
	for raw_capacity in snapshot.get("capacities", []):
		if raw_capacity is Dictionary \
				and not bool((raw_capacity as Dictionary).get("consumed", false)) \
				and int((raw_capacity as Dictionary).get("value", 0)) \
					>= minimum_value:
			candidates.append((raw_capacity as Dictionary).duplicate(true))
	if candidates.is_empty():
		return ""
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("value", 0)) > int(b.get("value", 0)) \
			if prefer_high else int(a.get("value", 0)) < int(b.get("value", 0)))
	return str(candidates[0].get("id", ""))


func _advance_to_next_week() -> void:
	var before_turn := int(GameState.turn)
	GameState.advance_calendar()
	_expect(int(GameState.turn) == before_turn + 1,
		"calendar did not advance by exactly one week")


func _capacity_values(capacities: Array) -> Array[int]:
	var result: Array[int] = []
	for raw_capacity in capacities:
		if raw_capacity is Dictionary:
			result.append(int((raw_capacity as Dictionary).get("value", 0)))
	result.sort()
	return result


func _capacity_ids(capacities: Array) -> Array[String]:
	var result: Array[String] = []
	for raw_capacity in capacities:
		if raw_capacity is Dictionary:
			result.append(str((raw_capacity as Dictionary).get("id", "")))
	return result


func _capacity_sum(capacities: Array) -> int:
	var total := 0
	for value in _capacity_values(capacities):
		total += value
	return total


func _sorted_strings(raw_values: Array) -> Array[String]:
	var result: Array[String] = []
	for raw_value in raw_values:
		result.append(str(raw_value))
	result.sort()
	return result


func _contains_hangul(text: String) -> bool:
	for index in range(text.length()):
		var code := text.unicode_at(index)
		if (code >= 0xAC00 and code <= 0xD7A3) \
				or (code >= 0x3131 and code <= 0x318E):
			return true
	return false


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
