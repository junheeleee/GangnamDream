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
const ORDER101_TERMINAL_SLICE_ROUTES := {
	"m1_resume_completed_q3_to_m2_advancement_ready": {
		"source": {"month": 1, "node": "resume", "terminal": "completed",
			"proof_kind": "typed_action_application",
			"proof_id": "m1_youth_center_resume_clinic:application:1",
			"quality": 3},
		"target": {"month": 2, "node": "m2_advancement",
			"bundle": "m2_seorin_application", "variant_id": "resume_ready"},
		"completion_effects": {"mental": 1},
	},
	"m1_resume_completed_q2_to_m2_advancement_polished": {
		"source": {"month": 1, "node": "resume", "terminal": "completed",
			"proof_kind": "typed_action_application",
			"proof_id": "m1_youth_center_resume_clinic:application:1",
			"quality": 2},
		"target": {"month": 2, "node": "m2_advancement",
			"bundle": "m2_seorin_application", "variant_id": "resume_polished"},
		"completion_effects": {"mental": 0},
	},
	"m1_resume_completed_q1_to_m2_advancement_revised": {
		"source": {"month": 1, "node": "resume", "terminal": "completed",
			"proof_kind": "typed_action_application",
			"proof_id": "m1_youth_center_resume_clinic:application:1",
			"quality": 1},
		"target": {"month": 2, "node": "m2_advancement",
			"bundle": "m2_seorin_application", "variant_id": "resume_revised"},
		"completion_effects": {"mental": -1},
	},
	"m1_resume_completed_q0_to_m2_advancement_rewritten": {
		"source": {"month": 1, "node": "resume", "terminal": "completed",
			"proof_kind": "typed_action_application",
			"proof_id": "m1_youth_center_resume_clinic:application:1",
			"quality": 0},
		"target": {"month": 2, "node": "m2_advancement",
			"bundle": "m2_seorin_application", "variant_id": "resume_rewritten"},
		"completion_effects": {"mental": -2},
	},
	"m1_resume_expired_to_m2_advancement_rebuilt": {
		"source": {"month": 1, "node": "resume", "terminal": "expired",
			"proof_kind": "node_expiry", "proof_id": "m1:resume"},
		"target": {"month": 2, "node": "m2_advancement",
			"bundle": "m2_seorin_application", "variant_id": "resume_rebuilt"},
		"completion_effects": {"mental": -3},
	},
	"m1_father_completed_wellbeing_to_m3_quiet_call": {
		"source": {"month": 1, "node": "father", "terminal": "completed",
			"proof_kind": "relationship_choice",
			"proof_id": "father_first_call:arc_father_01_call:0"},
		"target": {"month": 3, "node": "m3_people",
			"bundle": "father_quiet_call",
			"variant_id": "father_wellbeing_returned"},
		"completion_effects": {},
	},
	"m1_father_completed_future_reassured_to_m3_quiet_call": {
		"source": {"month": 1, "node": "father", "terminal": "completed",
			"proof_kind": "relationship_choice",
			"proof_id": "father_first_call:arc_father_01_call:1"},
		"target": {"month": 3, "node": "m3_people",
			"bundle": "father_quiet_call",
			"variant_id": "father_future_reassured"},
		"completion_effects": {},
	},
	"m1_father_completed_call_ended_quickly_to_m3_quiet_call": {
		"source": {"month": 1, "node": "father", "terminal": "completed",
			"proof_kind": "relationship_choice",
			"proof_id": "father_first_call:arc_father_01_call:2"},
		"target": {"month": 3, "node": "m3_people",
			"bundle": "father_quiet_call",
			"variant_id": "father_call_ended_quickly"},
		"completion_effects": {},
	},
	"m1_father_expired_to_m2_people_open": {
		"source": {"month": 1, "node": "father", "terminal": "expired",
			"proof_kind": "node_expiry", "proof_id": "m1:father"},
		"target": {"month": 2, "node": "m2_people", "bundle": "",
			"variant_id": "father_call_put_off"},
		"completion_effects": {},
	},
	"m2_people_completed_hyunsu_to_m3_followup": {
		"source": {"month": 2, "node": "m2_people", "terminal": "completed",
			"proof_kind": "selected_trigger",
			"proof_id": "m2:m2_people:hyunsu_player_reachout"},
		"target": {"month": 3, "node": "m3_people",
			"bundle": "hyunsu_study_followup", "variant_id": "hyunsu_followup"},
		"completion_effects": {},
	},
	"m2_people_completed_cafe_to_m4_sangchul": {
		"source": {"month": 2, "node": "m2_people", "terminal": "completed",
			"proof_kind": "selected_trigger",
			"proof_id": "m2:m2_people:cafe_world_glimpse"},
		"target": {"month": 4, "node": "m4_people",
			"bundle": "sangchul_world_meet", "variant_id": "cafe_sangchul_lead"},
		"completion_effects": {},
	},
	"m2_people_expired_to_m3_contact_fail_forward": {
		"source": {"month": 2, "node": "m2_people", "terminal": "expired",
			"proof_kind": "node_expiry", "proof_id": "m2:m2_people"},
		"target": {"month": 3, "node": "m3_people", "bundle": "",
			"variant_id": "contact_fail_forward"},
		"completion_effects": {},
	},
}

var _failures: Array[String] = []
var _terminal_source_placeholder_checked := false


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	_check_contract_and_determinism()
	_check_order101_terminal_slice_spec()
	_check_order101_terminal_slice_free_injection_rejected()
	_check_order101_fresh_w1_application_contract()
	_check_order101_resume_terminal_source_receipts()
	_check_order101_resume_terminal_target_initialization()
	_check_order101_resume_terminal_execution()
	_check_order101_father_terminal_source_receipts()
	_check_order101_m2_people_selection_contract()
	_check_order101_m2_people_terminal_source_receipts()
	_check_order101_m2_people_expiry_target_initialization()
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
			+ "terminal_slice=u09_u11_u12_u16/source_receipts_12of12 "
			+ "target_execution=q0_partial+completed/double_reload+ordinary_forgone "
			+ "target_mutations=capacity/full_coupled/fractional/status/axis/"
			+ "resolution/pending/resolved/zero_expiry "
			+ "mutations=capacity/father/selected/expiry/summary "
			+ "retention=w25/w48 "
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
	_expect(CORE._terminal_effects_semantically_equal(
		{"health": -1.0, "mental": 2.0, "money": 70000.0},
		{"health": -1, "mental": 2, "money": 70000}) \
		and CORE._terminal_effects_semantically_equal({}, {}),
		"terminal effect identity rejected exact JSON int/float values")
	_expect(not CORE._terminal_effects_semantically_equal(
			{"mental": 1.0, "money": 0.0}, {"mental": 1}) \
		and not CORE._terminal_effects_semantically_equal(
			{"mental": 1, "luck": 0}, {"mental": 1, "luck": 0}) \
		and not CORE._terminal_effects_semantically_equal(
			{"mental": "1"}, {"mental": 1}) \
		and not CORE._terminal_effects_semantically_equal(
			{"mental": 1.5}, {"mental": 1}) \
		and not CORE._terminal_effects_semantically_equal(
			{"mental": NAN}, {"mental": 0}),
		"terminal effect identity accepted key/type/fraction/non-finite mutation")
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


func _check_order101_terminal_slice_spec() -> void:
	var spec := CORE.seoul_cycle_spec()
	var routes: Dictionary = spec.get("terminal_routes", {})
	_expect(_sorted_strings(routes.keys()) \
		== _sorted_strings(ORDER101_TERMINAL_SLICE_ROUTES.keys()),
		"U09/U11/U12/U16 terminal slice route IDs drifted")
	var resume_results_ko: Array[String] = []
	var resume_results_en: Array[String] = []
	for route_id in ORDER101_TERMINAL_SLICE_ROUTES:
		var expected: Dictionary = ORDER101_TERMINAL_SLICE_ROUTES[route_id]
		var route: Dictionary = routes.get(route_id, {})
		_expect(not route.is_empty(),
			"terminal slice route is missing: %s" % route_id)
		if route.is_empty():
			continue
		var expected_keys: Array[String] = [
			"completion_effects", "detail_en", "detail_ko", "label_en",
			"label_ko", "result_en", "result_ko", "source", "target",
		]
		if route_id.begins_with("m1_resume_"):
			expected_keys.append("balance_status")
			expected_keys.sort()
		_expect(_sorted_strings(route.keys()) == expected_keys,
			"terminal slice route has hidden/unknown fields: %s" % route_id)
		_expect(_dictionary_equal_with_numeric_values(
			route.get("source", {}), expected.get("source", {})) \
			and _dictionary_equal_with_numeric_values(
				route.get("target", {}), expected.get("target", {})) \
			and _dictionary_equal_with_numeric_values(
				route.get("completion_effects", {}),
				expected.get("completion_effects", {})),
			"terminal slice source/target/effect topology drifted: %s" % route_id)
		_expect(
			str(route.get("balance_status", "")) == "first_run_adjustment"
			if route_id.begins_with("m1_resume_")
			else not route.has("balance_status"),
			"terminal slice balance provenance drifted: %s" % route_id)
		for locale_key in [
			"label_ko", "label_en", "detail_ko", "detail_en",
			"result_ko", "result_en",
		]:
			var copy := str(route.get(locale_key, "")).strip_edges()
			_expect(not copy.is_empty(),
				"terminal slice route lost %s: %s" % [locale_key, route_id])
			if locale_key.ends_with("_en"):
				_expect(not _contains_hangul(copy),
					"terminal slice English copy leaks Hangul: %s/%s" % [
						route_id, locale_key])
		if route_id.begins_with("m1_resume_"):
			resume_results_ko.append(str(route.get("result_ko", "")))
			resume_results_en.append(str(route.get("result_en", "")))
	var unique_resume_results_ko := _sorted_strings(resume_results_ko)
	var unique_resume_results_en := _sorted_strings(resume_results_en)
	_expect(resume_results_ko.size() == 5 \
		and unique_resume_results_ko.size() == 5 \
		and _deduplicated_strings(unique_resume_results_ko).size() == 5 \
		and resume_results_en.size() == 5 \
		and unique_resume_results_en.size() == 5 \
		and _deduplicated_strings(unique_resume_results_en).size() == 5,
		"resume q3/q2/q1/q0/expiry lost five visible result variants")
	var month_two := CORE.seoul_cycle_month_spec(2)
	var month_two_advancement: Dictionary = (
		month_two.get("nodes", {}) as Dictionary).get("m2_advancement", {})
	var resume_bundle := CORE.bundle("m2_seorin_application")
	_expect(int(month_two_advancement.get("threshold", 0)) == 2 \
		and _int_values(resume_bundle.get("allowed_weeks", [])) == [5, 6],
		"resume terminal variants changed M2 threshold or W5-W6 availability")


func _check_order101_terminal_slice_free_injection_rejected() -> void:
	_prepare_base_v2()
	GameState.flags["resume_polished"] = true
	var state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	var completed: Array = state.get("completed_bundles", [])
	completed.append("m1_youth_center_resume_clinic")
	state["completed_bundles"] = completed
	GameState.core_loop_v2_state = state
	_expect(CORE.terminal_transition_receipt(
		"m1_resume_completed_q2_to_m2_advancement_polished").is_empty() \
		and CORE.terminal_routes_for_target(2, "m2_advancement").is_empty(),
		"free resume_polished/completed-bundle state minted a terminal route")

	# Even a complete-looking public envelope is not a producer. The nested
	# proof must be an exact copied receipt from the live source month, not a
	# caller-authored dictionary that merely repeats the claimed turn.
	state = GameState.core_loop_v2_state.duplicate(true)
	var q2_spec: Dictionary = (
		CORE.seoul_cycle_spec().get("terminal_routes", {}) as Dictionary).get(
			"m1_resume_completed_q2_to_m2_advancement_polished", {})
	state["terminal_transition_receipts"] = {
		"m1_resume_completed_q2_to_m2_advancement_polished": {
			"schema": CORE.TERMINAL_TRANSITION_SCHEMA,
			"route_id": "m1_resume_completed_q2_to_m2_advancement_polished",
			"status": "derived",
			"source_month": 1,
			"source_node": "resume",
			"source_terminal": "completed",
			"source_turn": 1,
			"proof_kind": "typed_action_application",
			"proof_id": "m1_youth_center_resume_clinic:application:1",
			"source_proof": {"source_turn": 1},
			"target_month": 2,
			"target_node": "m2_advancement",
			"target_bundle": "m2_seorin_application",
			"variant_id": "resume_polished",
			"completion_effects": (
				q2_spec.get("completion_effects", {}) as Dictionary).duplicate(true),
		},
	}
	GameState.core_loop_v2_state = state
	_expect(CORE.terminal_transition_receipt(
		"m1_resume_completed_q2_to_m2_advancement_polished").is_empty() \
		and CORE.terminal_routes_for_target(2, "m2_advancement").is_empty(),
		"direct terminal receipt injection passed without an exact source proof")


func _check_order101_resume_terminal_source_receipts() -> void:
	for quality in range(4):
		var route_id: String = [
			"m1_resume_completed_q0_to_m2_advancement_rewritten",
			"m1_resume_completed_q1_to_m2_advancement_revised",
			"m1_resume_completed_q2_to_m2_advancement_polished",
			"m1_resume_completed_q3_to_m2_advancement_ready",
		][quality]
		var produced := _produce_completed_resume_month(quality)
		if produced.is_empty():
			continue
		var receipt := CORE.terminal_transition_receipt(route_id)
		var proof: Dictionary = receipt.get("source_proof", {})
		var node: Dictionary = proof.get("node_state", {})
		var allocation: Dictionary = proof.get("allocation_receipt", {})
		var trigger: Dictionary = proof.get("trigger_receipt", {})
		var action: Dictionary = proof.get("action_receipt", {})
		var details: Dictionary = action.get("result_details", {})
		var transition: Dictionary = proof.get(
			"application_transition_receipt", {})
		_expect(str(receipt.get("route_id", "")) == route_id \
			and int(receipt.get("source_month", 0)) == 1 \
			and str(receipt.get("source_node", "")) == "resume" \
			and str(receipt.get("source_terminal", "")) == "completed" \
			and int(receipt.get("source_turn", 0)) == 1 \
			and str(receipt.get("proof_kind", "")) \
				== "typed_action_application" \
			and str(receipt.get("proof_id", "")) \
				== "m1_youth_center_resume_clinic:application:1" \
			and int(receipt.get("target_month", 0)) == 2 \
			and str(receipt.get("target_node", "")) == "m2_advancement" \
			and str(receipt.get("target_bundle", "")) \
				== "m2_seorin_application" \
			and str(receipt.get("variant_id", "")) == [
				"resume_rewritten", "resume_revised", "resume_polished",
				"resume_ready"][quality] \
			and int(node.get("completed_turn", 0)) == 1 \
			and str(node.get("status", "")) == "completed" \
			and bool(allocation.get("completed_now", false)) \
			and str(allocation.get("node_id", "")) == "resume" \
			and str(trigger.get("bundle_id", "")) \
				== "m1_youth_center_resume_clinic" \
			and str(trigger.get("status", "")) == "resolved" \
			and str(action.get("bundle_id", "")) \
				== "m1_youth_center_resume_clinic" \
			and int(details.get("quality", -1)) == quality \
			and str(details.get("execution", "")) \
				== "job_hunt_application" \
			and str(transition.get("receipt_key", "")) \
				== "m1_youth_center_resume_clinic:application:1" \
			and int(transition.get("quality", -1)) == quality,
			"quality %d terminal receipt did not copy the exact W1 producer" \
				% quality)
		var frozen_receipt := receipt.duplicate(true)
		var frozen_state: Dictionary = GameState.serialize().duplicate(true)
		var replayed := CORE.record_month_summary(1, {}, {})
		_expect(not replayed.is_empty() \
			and CORE.terminal_transition_receipt(route_id) == frozen_receipt \
			and GameState.serialize() == frozen_state,
			"quality %d repeated month close rewrote its terminal receipt" % quality)
		var saved: Dictionary = GameState.serialize().duplicate(true)
		if quality == 0:
			_check_terminal_source_json_target_roundtrip(
				saved, route_id, frozen_receipt, 2, "m2_advancement")
			_check_terminal_fractional_scalar_rejected(
				saved, route_id, frozen_receipt)
		for reload_index in range(2):
			GameState.start_new_game()
			GameState.load_from_dict(saved.duplicate(true))
			CORE.initialize_for_run(true)
			_expect(CORE.terminal_transition_receipt(route_id) == frozen_receipt,
				"quality %d terminal receipt drifted on reload %d" % [
					quality, reload_index + 1])
			saved = GameState.serialize().duplicate(true)
		_check_terminal_receipt_nested_mutations_rejected(
			saved, route_id, frozen_receipt, quality)
		_check_terminal_receipt_underlying_mutations_rejected(
			saved, route_id, quality)
		if quality == 0:
			_check_terminal_coupled_capacity_mutation_rejected(
				saved, route_id, frozen_receipt)
			_check_terminal_long_horizon_retention(
				saved, route_id, frozen_receipt, 1)
	_check_order101_resume_expiry_source_receipt()


func _check_order101_resume_terminal_target_initialization() -> void:
	var route_id := "m1_resume_completed_q3_to_m2_advancement_ready"
	var father_expiry_route := "m1_father_expired_to_m2_people_open"
	var candidate_id := "terminal:%s" % route_id
	var father_candidate_id := "terminal:%s" % father_expiry_route
	var source_summary := _produce_completed_resume_month(3)
	var receipt := CORE.terminal_transition_receipt(route_id)
	_expect(not source_summary.is_empty() and not receipt.is_empty(),
		"q3 target-init fixture did not produce its exact source receipt")
	if source_summary.is_empty() or receipt.is_empty():
		return
	var before_preinit_query: Dictionary = GameState.serialize().duplicate(true)
	_expect(CORE.terminal_target_candidates(
		2, "m2_advancement").is_empty() \
		and GameState.serialize() == before_preinit_query,
		"target candidates appeared before M2 initialization or mutated source state")
	_advance_to_next_week()
	var advanced_receipt := CORE.terminal_transition_receipt(route_id)
	_expect(advanced_receipt == receipt,
		"q3 source receipt stopped validating at the W4-to-W5 boundary")
	var initialized := CORE.initialize_seoul_cycle(2)
	var snapshot := CORE.seoul_cycle_snapshot(2)
	var node: Dictionary = (snapshot.get("nodes", {}) as Dictionary).get(
		"m2_advancement", {})
	var candidates := CORE.terminal_target_candidates(2, "m2_advancement")
	var route_spec: Dictionary = (
		CORE.seoul_cycle_spec().get("terminal_routes", {}) as Dictionary).get(
			route_id, {})
	var expected_binding := {
		"schema": CORE.TERMINAL_TARGET_BINDING_SCHEMA,
		"route_id": route_id,
		"variant_id": "resume_ready",
		"source_month": 1,
		"source_node": "resume",
		"source_terminal": "completed",
		"source_turn": 1,
		"proof_kind": "typed_action_application",
		"proof_id": "m1_youth_center_resume_clinic:application:1",
		"target_month": 2,
		"target_node": "m2_advancement",
		"target_bundle": "m2_seorin_application",
		"completion_effects": {"mental": 1},
		"label_ko": str(route_spec.get("label_ko", "")),
		"label_en": str(route_spec.get("label_en", "")),
		"detail_ko": str(route_spec.get("detail_ko", "")),
		"detail_en": str(route_spec.get("detail_en", "")),
		"result_ko": str(route_spec.get("result_ko", "")),
		"result_en": str(route_spec.get("result_en", "")),
	}
	var expected_candidate := {
		"id": candidate_id,
		"kind": "terminal",
		"bundle_id": "m2_seorin_application",
		"route_id": route_id,
		"variant_id": "resume_ready",
		"label_ko": str(route_spec.get("label_ko", "")),
		"label_en": str(route_spec.get("label_en", "")),
		"detail_ko": str(route_spec.get("detail_ko", "")),
		"detail_en": str(route_spec.get("detail_en", "")),
		"completion_effects": {"mental": 1},
		"source": {
			"month": 1,
			"node": "resume",
			"terminal": "completed",
			"turn": 1,
			"proof_kind": "typed_action_application",
			"proof_id": "m1_youth_center_resume_clinic:application:1",
		},
	}
	var bindings: Dictionary = node.get("terminal_route_bindings", {})
	var initialized_state: Dictionary = GameState.core_loop_v2_state
	var initialized_cycle: Dictionary = initialized_state.get("seoul_cycle", {})
	var initialized_plan: Dictionary = (
		initialized_state.get("plans", {}) as Dictionary).get("2", {})
	var expected_candidate_set := {
		"ordinary_candidate_ids": [],
		"binding_candidate_ids": [candidate_id],
	}
	var expected_father_candidate_set := {
		"ordinary_candidate_ids": [
			"cafe_world_glimpse", "hyunsu_player_reachout",
		],
		"binding_candidate_ids": [
			"cafe_world_glimpse", "hyunsu_player_reachout",
			father_candidate_id,
		],
	}
	var target_candidate_sets: Dictionary = initialized_plan.get(
		"terminal_binding_candidate_sets", {})
	_expect(bool(initialized.get("ok", false)) \
		and not bool(initialized.get("resumed", true)) \
		and candidates.size() == 1 \
		and _terminal_record_equal_with_numeric_effects(
			candidates[0], expected_candidate) \
		and _sorted_strings(node.get("binding_candidate_ids", [])) \
			== [candidate_id] \
		and _sorted_strings(node.get("eligible_terminal_route_ids", [])) \
			== [route_id] \
		and _sorted_strings(bindings.keys()) == [route_id] \
		and _terminal_record_equal_with_numeric_effects(
			bindings.get(route_id, {}), expected_binding) \
		and str(node.get("selected_trigger_candidate_id", "")) == candidate_id \
		and str(node.get("selected_trigger_bundle_id", "")) \
			== "m2_seorin_application" \
		and str(node.get("selected_terminal_route_id", "")) == route_id \
		and str(node.get("terminal_selection_origin", "")) == "terminal_auto" \
		and str(node.get("trigger_bundle", "")) == "m2_seorin_application" \
		and str(node.get("summary_bundle", "")) == "m2_seorin_application" \
		and int(initialized_cycle.get("terminal_binding_schema", 0)) \
			== CORE.TERMINAL_TARGET_BINDING_SCHEMA \
		and initialized_cycle.get("terminal_bound_node_ids", []) \
			== ["m2_advancement", "m2_people"] \
		and int(initialized_plan.get("terminal_binding_schema", 0)) \
			== CORE.TERMINAL_TARGET_BINDING_SCHEMA \
		and initialized_plan.get("terminal_bound_node_ids", []) \
			== ["m2_advancement", "m2_people"] \
		and target_candidate_sets.get(
			"m2_advancement", {}) == expected_candidate_set \
		and target_candidate_sets.get(
			"m2_people", {}) == expected_father_candidate_set \
		and CORE.terminal_transition_receipt(route_id) == receipt \
		and not CORE.terminal_transition_receipt(
			father_expiry_route).is_empty() \
		and CORE.terminal_transition_resolution(route_id).is_empty(),
		"q3 target initialization did not persist one exact coalesced candidate")
	var initialized_save: Dictionary = GameState.serialize().duplicate(true)
	var before_candidate_query := initialized_save.duplicate(true)
	var reread_candidates := CORE.terminal_target_candidates(
		2, "m2_advancement")
	_expect(reread_candidates.size() == 1 \
		and _terminal_record_equal_with_numeric_effects(
			reread_candidates[0], expected_candidate) \
		and GameState.serialize() == before_candidate_query,
		"target candidate read mutated initialized state")
	var resumed := CORE.initialize_seoul_cycle(2)
	_expect(bool(resumed.get("ok", false)) \
		and bool(resumed.get("resumed", false)) \
		and GameState.serialize() == initialized_save \
		and CORE.terminal_transition_resolution(route_id).is_empty(),
		"repeated target initialization consumed or rewrote its binding")
	var roundtrip := initialized_save.duplicate(true)
	for reload_index in range(2):
		GameState.start_new_game()
		GameState.load_from_dict(roundtrip.duplicate(true))
		CORE.initialize_for_run(true)
		var reloaded_candidates := CORE.terminal_target_candidates(
			2, "m2_advancement")
		_expect(CORE.terminal_transition_receipt(route_id) == receipt \
			and reloaded_candidates.size() == 1 \
			and _terminal_record_equal_with_numeric_effects(
				reloaded_candidates[0], expected_candidate) \
			and CORE.terminal_transition_resolution(route_id).is_empty(),
			"q3 target binding drifted on init-only reload %d" \
				% [reload_index + 1])
		roundtrip = GameState.serialize().duplicate(true)

	var missing_source := initialized_save.duplicate(true)
	var missing_state: Dictionary = missing_source.get("core_loop_v2_state", {})
	(missing_state.get("terminal_transition_receipts", {}) as Dictionary).erase(
		route_id)
	missing_source["core_loop_v2_state"] = missing_state
	GameState.start_new_game()
	GameState.load_from_dict(missing_source)
	CORE.initialize_for_run(true)
	var missing_before: Dictionary = GameState.serialize().duplicate(true)
	var missing_resume := CORE.initialize_seoul_cycle(2)
	_expect(CORE.terminal_transition_receipt(route_id).is_empty() \
		and CORE.terminal_target_candidates(2, "m2_advancement").is_empty() \
		and not bool(missing_resume.get("ok", true)) \
		and str(missing_resume.get("error", "")) \
			== "terminal_binding_conflict" \
		and GameState.serialize() == missing_before,
		"persisted target binding survived deletion of its exact source receipt")
	_check_terminal_target_identity_erasure_rejected(
		initialized_save, route_id, 2, "m2_advancement")
	_check_terminal_target_three_surface_erasure_rejected(
		initialized_save, route_id, 2, "m2_advancement")
	_check_terminal_unallocated_target_full_erasure_rejected(
		initialized_save, route_id, receipt, 2, "m2_advancement")
	_check_terminal_target_witness_lifetime_rejected(
		initialized_save, route_id)


func _check_order101_resume_terminal_execution() -> void:
	var route_id := "m1_resume_completed_q0_to_m2_advancement_rewritten"
	var candidate_id := "terminal:%s" % route_id
	var source_summary := _produce_completed_resume_month(0)
	var source_receipt := CORE.terminal_transition_receipt(route_id)
	_expect(not source_summary.is_empty() and not source_receipt.is_empty(),
		"q0 target-execution fixture did not produce its exact source receipt")
	if source_summary.is_empty() or source_receipt.is_empty():
		return
	_advance_to_next_week()
	var initialized := CORE.initialize_seoul_cycle(2)
	var w5_snapshot := CORE.seoul_cycle_snapshot(2)
	var w5_capacity := _unused_capacity(w5_snapshot, 1, false)
	var w5_node: Dictionary = (
		w5_snapshot.get("nodes", {}) as Dictionary).get("m2_advancement", {})
	var binding: Dictionary = (
		w5_node.get("terminal_route_bindings", {}) as Dictionary).get(
			route_id, {})
	var mental_before := int(GameState.mental)
	var before_preview: Dictionary = GameState.serialize().duplicate(true)
	var partial_preview := CORE.preview_seoul_cycle_allocation(
		w5_capacity, "m2_advancement", 2, candidate_id)
	_expect(bool(initialized.get("ok", false)) \
		and bool(w5_snapshot.get("active", false)) \
		and not w5_capacity.is_empty() \
		and int(partial_preview.get("base_progress", 0)) == 1 \
		and int(partial_preview.get("progress_after", 0)) == 1 \
		and not bool(partial_preview.get("completed_now", true)) \
		and bool(partial_preview.get("terminal_route_required", false)) \
		and not bool(partial_preview.get(
			"terminal_selection_required", true)) \
		and not bool(partial_preview.get("terminal_selection_new", true)) \
		and str(partial_preview.get(
			"selected_trigger_candidate_id", "")) == candidate_id \
		and str(partial_preview.get(
			"selected_trigger_bundle_id", "")) == "m2_seorin_application" \
		and str(partial_preview.get(
			"selected_terminal_route_id", "")) == route_id \
		and str(partial_preview.get("terminal_variant_id", "")) \
			== "resume_rewritten" \
		and _variant_equal_with_numeric_values(
			partial_preview.get("terminal_target_binding", {}), binding) \
		and _variant_equal_with_numeric_values(
			partial_preview.get("terminal_completion_effects", {}),
			{"mental": -2}) \
		and (partial_preview.get("immediate_effects", {}) as Dictionary).is_empty() \
		and str(partial_preview.get("trigger_bundle", "")).is_empty() \
		and GameState.serialize() == before_preview \
		and int(GameState.mental) == mental_before \
		and CORE.terminal_transition_resolution(route_id).is_empty(),
		"q0 W5 preview did not preserve its coalesced terminal identity without effects")
	if not bool(partial_preview.get("ok", false)):
		return
	var partial_commit := CORE.commit_seoul_cycle_allocation(
		w5_capacity, "m2_advancement", 2, candidate_id)
	var partial_receipt: Dictionary = partial_commit.get("receipt", {})
	var partial_weekly: Dictionary = partial_receipt.get(
		"weekly_commitment", {})
	var partial_details: Dictionary = partial_weekly.get("details", {})
	var partial_cycle := CORE.seoul_cycle_snapshot(2)
	var partial_node: Dictionary = (
		partial_cycle.get("nodes", {}) as Dictionary).get("m2_advancement", {})
	_expect(bool(partial_commit.get("ok", false)) \
		and not bool(partial_commit.get("completed_now", true)) \
		and str(partial_node.get(
			"selected_trigger_candidate_id", "")) == candidate_id \
		and str(partial_node.get("selected_terminal_route_id", "")) == route_id \
		and str(partial_receipt.get(
			"selected_trigger_candidate_id", "")) == candidate_id \
		and str(partial_receipt.get(
			"selected_trigger_bundle_id", "")) == "m2_seorin_application" \
		and str(partial_receipt.get(
			"selected_terminal_route_id", "")) == route_id \
		and str(partial_receipt.get("terminal_variant_id", "")) \
			== "resume_rewritten" \
		and _variant_equal_with_numeric_values(
			partial_receipt.get("terminal_target_binding", {}), binding) \
		and _variant_equal_with_numeric_values(
			partial_receipt.get("terminal_completion_effects", {}),
			{"mental": -2}) \
		and str(partial_details.get(
			"selected_trigger_candidate_id", "")) == candidate_id \
		and str(partial_details.get(
			"selected_trigger_bundle_id", "")) == "m2_seorin_application" \
		and str(partial_details.get(
			"selected_terminal_route_id", "")) == route_id \
		and str(partial_details.get("terminal_variant_id", "")) \
			== "resume_rewritten" \
		and _variant_equal_with_numeric_values(
			partial_details.get("terminal_target_binding", {}), binding) \
		and _variant_equal_with_numeric_values(
			partial_details.get("terminal_completion_effects", {}),
			{"mental": -2}) \
		and (partial_commit.get("pending_trigger", {}) as Dictionary).is_empty() \
		and int(GameState.mental) == mental_before \
		and CORE.terminal_transition_resolution(route_id).is_empty(),
		"q0 W5 partial commit lost identity or applied its terminal result early")
	if not bool(partial_commit.get("ok", false)):
		return
	var partial_saved: Dictionary = GameState.serialize().duplicate(true)
	_check_terminal_active_allocation_authority_rejected(
		partial_saved, route_id, candidate_id, binding)
	for reload_index in range(2):
		GameState.start_new_game()
		GameState.load_from_dict(partial_saved.duplicate(true))
		CORE.initialize_for_run(true)
		var reloaded_cycle := CORE.seoul_cycle_snapshot(2)
		var reloaded_node: Dictionary = (
			reloaded_cycle.get("nodes", {}) as Dictionary).get(
				"m2_advancement", {})
		_expect(bool(reloaded_cycle.get("active", false)) \
			and str(reloaded_node.get(
				"selected_trigger_candidate_id", "")) == candidate_id \
			and str(reloaded_node.get(
				"selected_terminal_route_id", "")) == route_id \
			and int(reloaded_node.get("progress", 0)) == 1 \
			and int(GameState.mental) == mental_before \
			and CORE.terminal_transition_resolution(route_id).is_empty(),
			"q0 partial terminal selection replayed on reload %d" \
				% [reload_index + 1])
		partial_saved = GameState.serialize().duplicate(true)
	_check_terminal_selected_partial_expiry_lifetime(
		partial_saved, route_id, candidate_id, binding)
	_check_terminal_completion_autosave_retry(
		partial_saved, route_id, candidate_id, binding)
	GameState.start_new_game()
	GameState.load_from_dict(partial_saved.duplicate(true))
	CORE.initialize_for_run(true)
	var w5_closed := CORE.complete_seoul_cycle_turn(2)
	_expect(bool(w5_closed.get("ok", false)),
		"q0 partial terminal week could not close after reload")
	if not bool(w5_closed.get("ok", false)):
		return
	_advance_to_next_week()
	var w6_snapshot := CORE.seoul_cycle_snapshot(2)
	var w6_capacity := _unused_capacity(w6_snapshot, 1, true)
	var completion_mental_before := int(GameState.mental)
	var before_completion_preview: Dictionary = GameState.serialize().duplicate(true)
	var completion_preview := CORE.preview_seoul_cycle_allocation(
		w6_capacity, "m2_advancement", 2, candidate_id)
	_expect(bool(completion_preview.get("ok", false)) \
		and bool(completion_preview.get("completed_now", false)) \
		and not bool(completion_preview.get("terminal_selection_new", true)) \
		and str(completion_preview.get(
			"selected_trigger_candidate_id", "")) == candidate_id \
		and str(completion_preview.get(
			"selected_terminal_route_id", "")) == route_id \
		and str(completion_preview.get("terminal_variant_id", "")) \
			== "resume_rewritten" \
		and int((completion_preview.get(
			"immediate_effects", {}) as Dictionary).get("mental", 0)) == -2 \
		and GameState.serialize() == before_completion_preview \
		and int(GameState.mental) == completion_mental_before \
		and CORE.terminal_transition_resolution(route_id).is_empty(),
		"q0 W6 completion preview did not expose one deferred terminal result")
	if not bool(completion_preview.get("ok", false)):
		return
	var completion_commit := CORE.commit_seoul_cycle_allocation(
		w6_capacity, "m2_advancement", 2, candidate_id)
	var completion_receipt: Dictionary = completion_commit.get("receipt", {})
	var completion_weekly: Dictionary = completion_receipt.get(
		"weekly_commitment", {})
	var completion_details: Dictionary = completion_weekly.get("details", {})
	var pending: Dictionary = completion_commit.get("pending_trigger", {})
	var resolution := CORE.terminal_transition_resolution(route_id)
	var expected_resolution := {
		"schema": CORE.TERMINAL_TARGET_BINDING_SCHEMA,
		"route_id": route_id,
		"resolution": "completed",
		"binding": binding.duplicate(true),
		"target_month": 2,
		"target_node": "m2_advancement",
		"target_turn": 6,
		"allocation_receipt_id": "seoul_cycle_m2_w2",
		"allocation_receipt_key": "seoul_cycle.allocation_receipts.6",
		"selected_candidate_id": candidate_id,
		"selected_terminal_route_id": route_id,
		"variant_id": "resume_rewritten",
		"effect_applied": true,
		"result_variant": "resume_rewritten",
	}
	_expect(bool(completion_commit.get("ok", false)) \
		and bool(completion_commit.get("completed_now", false)) \
		and int(GameState.mental) == completion_mental_before - 2 \
		and int((completion_receipt.get(
			"effects", {}) as Dictionary).get("mental", 0)) == -2 \
		and str(completion_receipt.get(
			"selected_trigger_candidate_id", "")) == candidate_id \
		and str(completion_receipt.get(
			"selected_terminal_route_id", "")) == route_id \
		and str(completion_receipt.get("terminal_variant_id", "")) \
			== "resume_rewritten" \
		and _variant_equal_with_numeric_values(
			completion_receipt.get("terminal_target_binding", {}), binding) \
		and str(completion_details.get(
			"selected_trigger_candidate_id", "")) == candidate_id \
		and str(completion_details.get(
			"selected_terminal_route_id", "")) == route_id \
		and str(completion_details.get("terminal_variant_id", "")) \
			== "resume_rewritten" \
		and _variant_equal_with_numeric_values(
			completion_details.get("terminal_target_binding", {}), binding) \
		and str(pending.get("bundle_id", "")) == "m2_seorin_application" \
		and str(pending.get(
			"selected_trigger_candidate_id", "")) == candidate_id \
		and str(pending.get("selected_terminal_route_id", "")) == route_id \
		and str(pending.get("terminal_variant_id", "")) \
			== "resume_rewritten" \
		and _variant_equal_with_numeric_values(
			pending.get("terminal_target_binding", {}), binding) \
		and _variant_equal_with_numeric_values(resolution, expected_resolution),
		"q0 completion did not apply and resolve its exact terminal result once")
	if not bool(completion_commit.get("ok", false)):
		return
	var completed_saved: Dictionary = GameState.serialize().duplicate(true)
	var duplicate := CORE.commit_seoul_cycle_allocation(
		w6_capacity, "m2_advancement", 2, candidate_id)
	_expect(not bool(duplicate.get("ok", true)) \
		and int(GameState.mental) == completion_mental_before - 2 \
		and _variant_equal_with_numeric_values(
			CORE.terminal_transition_resolution(route_id), expected_resolution) \
		and GameState.serialize() == completed_saved,
		"q0 duplicate completion replayed its effect or resolution")
	for reload_index in range(2):
		GameState.start_new_game()
		GameState.load_from_dict(completed_saved.duplicate(true))
		CORE.initialize_for_run(true)
		var reloaded_pending := CORE.pending_seoul_cycle_trigger()
		_expect(int(GameState.mental) == completion_mental_before - 2 \
			and str(reloaded_pending.get(
				"selected_trigger_candidate_id", "")) == candidate_id \
			and str(reloaded_pending.get(
				"selected_terminal_route_id", "")) == route_id \
			and _variant_equal_with_numeric_values(
				CORE.terminal_transition_resolution(route_id), expected_resolution),
			"q0 completed terminal result replayed or drifted on reload %d" \
				% [reload_index + 1])
		completed_saved = GameState.serialize().duplicate(true)
	var resolved_completed_save := \
		_check_terminal_completed_target_authority_rejected(
			completed_saved, route_id, candidate_id, binding)
	_check_terminal_completed_historical_resolution(
		resolved_completed_save, route_id, expected_resolution)


func _terminal_expected_expired_resolution(
		route_id: String, binding: Dictionary, target_node: String,
		target_turn: int, selected_candidate_id: String,
		selected_terminal_route_id: String) -> Dictionary:
	var target_month := CORE.month_for_turn(target_turn)
	var week_index := target_turn - ((target_month - 1) * 4)
	return {
		"schema": CORE.TERMINAL_TARGET_BINDING_SCHEMA,
		"route_id": route_id,
		"resolution": "expired",
		"binding": binding.duplicate(true),
		"target_month": target_month,
		"target_node": target_node,
		"target_turn": target_turn,
		"allocation_receipt_id": "seoul_cycle_m%d_w%d" % [
			target_month, week_index],
		"allocation_receipt_key": \
			"seoul_cycle.allocation_receipts.%d" % target_turn,
		"selected_candidate_id": selected_candidate_id,
		"selected_terminal_route_id": selected_terminal_route_id,
		"variant_id": str(binding.get("variant_id", "")),
		"effect_applied": false,
		"result_variant": "",
	}


func _check_terminal_selected_partial_expiry_lifetime(
		partial_saved: Dictionary, route_id: String,
		candidate_id: String, binding: Dictionary) -> void:
	GameState.start_new_game()
	GameState.load_from_dict(partial_saved.duplicate(true))
	CORE.initialize_for_run(true)
	var w5_closed := CORE.complete_seoul_cycle_turn(2)
	_expect(bool(w5_closed.get("ok", false)),
		"q0 selected-partial expiry fixture could not close W5")
	if not bool(w5_closed.get("ok", false)):
		return
	_advance_to_next_week()
	# Remaining q0 capacities can all complete m2_self and arm a rest trigger.
	# Reuse the exact livelihood filler, which resolves its rain trigger when the
	# chosen capacity crosses the threshold, so the closing turn is genuinely
	# ready before the terminal node expires.
	var w6_filler_ok := _commit_m2_terminal_filler()
	var mental_after_allocation := int(GameState.mental)
	_expect(w6_filler_ok \
		and CORE.pending_seoul_cycle_trigger().is_empty(),
		"q0 selected-partial expiry fixture could not commit its W6 closer")
	if not w6_filler_ok:
		return
	var expiry_ready_save: Dictionary = GameState.serialize().duplicate(true)
	_check_terminal_expiry_resolution_placeholder_conflict(
		expiry_ready_save, route_id)
	GameState.start_new_game()
	GameState.load_from_dict(expiry_ready_save.duplicate(true))
	CORE.initialize_for_run(true)
	var w6_closed := CORE.complete_seoul_cycle_turn(2)
	var expired_cycle := CORE.seoul_cycle_snapshot(2)
	var expired_node: Dictionary = (
		expired_cycle.get("nodes", {}) as Dictionary).get(
			"m2_advancement", {})
	var closing_receipt: Dictionary = (
		expired_cycle.get("allocation_receipts", {}) as Dictionary).get("6", {})
	var expected_resolution := _terminal_expected_expired_resolution(
		route_id, binding, "m2_advancement", 6, candidate_id, route_id)
	var resolution := CORE.terminal_transition_resolution(route_id)
	_expect(bool(w6_closed.get("ok", false)) \
		and str(expired_node.get("status", "")) == "expired" \
		and int(expired_node.get("expired_turn", 0)) == 6 \
		and int(expired_node.get("progress", 0)) == 1 \
		and (closing_receipt.get("expired_nodes", []) as Array).count(
			"m2_advancement") == 1 \
		and int(GameState.mental) == mental_after_allocation - 1 \
		and _variant_equal_with_numeric_values(
			resolution, expected_resolution),
		"q0 selected partial target expiry did not mint one exact resolution")
	if not bool(w6_closed.get("ok", false)):
		return
	for turn in range(7, 9):
		_advance_to_next_week()
		if not _commit_m2_terminal_filler():
			return
		if turn == 8 and not _resolve_cycle_story_world(
				"temptation_consequence", "arc_temptation_clean", 0):
			return
		if not bool(CORE.complete_seoul_cycle_turn(2).get("ok", false)):
			_expect(false,
				"q0 selected-partial expiry fixture could not close W%d" % turn)
			return
	var summary := CORE.record_month_summary(2, {}, {})
	var summary_resolutions: Dictionary = summary.get(
		"terminal_transition_resolutions", {})
	_expect(_variant_equal_with_numeric_values(
		summary_resolutions.get(route_id, {}), expected_resolution),
		"q0 expired resolution was not frozen into the closed M2 summary")
	_advance_to_next_week()
	var month_three := CORE.initialize_seoul_cycle(3)
	var historical_save: Dictionary = GameState.serialize().duplicate(true)
	_expect(bool(month_three.get("ok", false)) \
		and _variant_equal_with_numeric_values(
			CORE.terminal_transition_resolution(route_id), expected_resolution),
		"q0 expired resolution did not survive replacement by M3")
	for reload_index in range(2):
		GameState.start_new_game()
		GameState.load_from_dict(historical_save.duplicate(true))
		CORE.initialize_for_run(true)
		_expect(_variant_equal_with_numeric_values(
			CORE.terminal_transition_resolution(route_id), expected_resolution),
			"q0 historical expired resolution drifted on reload %d" \
				% [reload_index + 1])
		historical_save = GameState.serialize().duplicate(true)
	_check_terminal_historical_resolution_mutations(
		historical_save, 2, route_id, expected_resolution)


func _check_terminal_expiry_resolution_placeholder_conflict(
		expiry_ready_save: Dictionary, route_id: String) -> void:
	var baseline_state: Dictionary = expiry_ready_save.get(
		"core_loop_v2_state", {})
	var baseline_cycle: Dictionary = baseline_state.get("seoul_cycle", {})
	var baseline_node: Dictionary = (
		baseline_cycle.get("nodes", {}) as Dictionary).get(
			"m2_advancement", {})
	var baseline_resolutions: Dictionary = baseline_state.get(
		"terminal_transition_resolutions", {})
	var baseline_closing: Dictionary = (
		baseline_cycle.get("allocation_receipts", {}) as Dictionary).get("6", {})
	_expect(not baseline_resolutions.has(route_id) \
		and int(baseline_node.get("progress", 0)) == 1 \
		and str(baseline_node.get("status", "")) == "in_progress" \
		and int(baseline_node.get("deadline_week", 0)) == 2 \
		and str(baseline_closing.get("status", "")) == "allocated" \
		and not (baseline_cycle.get("completed_turns", []) as Array).has(6),
		"expiry placeholder fixture was not immediately before exact W6 expiry")
	if baseline_resolutions.has(route_id) or baseline_closing.is_empty():
		return
	for placeholder in [{}, "terminal_resolution_placeholder"]:
		GameState.start_new_game()
		GameState.load_from_dict(expiry_ready_save.duplicate(true))
		CORE.initialize_for_run(true)
		var state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
		var resolutions: Dictionary = state.get(
			"terminal_transition_resolutions", {})
		resolutions[route_id] = placeholder
		state["terminal_transition_resolutions"] = resolutions
		GameState.core_loop_v2_state = state
		var before_close: Dictionary = GameState.serialize().duplicate(true)
		var mental_before := int(GameState.mental)
		var closed := CORE.complete_seoul_cycle_turn(2)
		var raw_after: Dictionary = GameState.core_loop_v2_state.get(
			"terminal_transition_resolutions", {})
		_expect(not bool(closed.get("ok", true)) \
			and str(closed.get("error", "")) == "terminal_resolution_conflict" \
			and raw_after.has(route_id) \
			and _variant_equal_with_numeric_values(
				raw_after.get(route_id), placeholder) \
			and CORE.terminal_transition_resolution(route_id).is_empty() \
			and int(GameState.mental) == mental_before \
			and GameState.serialize() == before_close,
			"W6 expiry healed or partially committed a %s root placeholder" \
				% ["dictionary" if placeholder is Dictionary else "string"])


func _check_terminal_completion_autosave_retry(
		partial_saved: Dictionary, route_id: String,
		candidate_id: String, binding: Dictionary) -> void:
	GameState.start_new_game()
	GameState.load_from_dict(partial_saved.duplicate(true))
	CORE.initialize_for_run(true)
	if not bool(CORE.complete_seoul_cycle_turn(2).get("ok", false)):
		_expect(false, "q0 durable completion fixture could not close W5")
		return
	_advance_to_next_week()
	var snapshot := CORE.seoul_cycle_snapshot(2)
	var capacity_id := _unused_capacity(snapshot, 1, true)
	var preview := CORE.preview_seoul_cycle_allocation(
		capacity_id, "m2_advancement", 2, candidate_id)
	var before_commit: Dictionary = GameState.serialize().duplicate(true)
	var before_resolutions: Dictionary = (
		before_commit.get("core_loop_v2_state", {}) as Dictionary).get(
			"terminal_transition_resolutions", {})
	var mental_before := int(GameState.mental)
	var main_game: Node = MAIN_GAME_SCRIPT.new()
	main_game.set_meta("_qa_core_loop_v2_autosave_result", false)
	main_game.set_meta("_qa_core_loop_v2_autosave_call_count", 0)
	var failed_commit: Dictionary = main_game.call(
		"_core_loop_v2_commit_seoul_cycle_allocation_durably",
		capacity_id, "m2_advancement", candidate_id)
	var frozen: Dictionary = GameState.serialize().duplicate(true)
	var frozen_state: Dictionary = frozen.get("core_loop_v2_state", {})
	var frozen_resolutions: Dictionary = frozen_state.get(
		"terminal_transition_resolutions", {})
	var expected_resolution := {
		"schema": CORE.TERMINAL_TARGET_BINDING_SCHEMA,
		"route_id": route_id,
		"resolution": "completed",
		"binding": binding.duplicate(true),
		"target_month": 2,
		"target_node": "m2_advancement",
		"target_turn": 6,
		"allocation_receipt_id": "seoul_cycle_m2_w2",
		"allocation_receipt_key": "seoul_cycle.allocation_receipts.6",
		"selected_candidate_id": candidate_id,
		"selected_terminal_route_id": route_id,
		"variant_id": "resume_rewritten",
		"effect_applied": true,
		"result_variant": "resume_rewritten",
	}
	_expect(bool(preview.get("ok", false)) \
		and bool(preview.get("completed_now", false)) \
		and before_resolutions.is_empty() \
		and not bool(failed_commit.get("ok", true)) \
		and str(failed_commit.get("error", "")) == "autosave_failed" \
		and bool(failed_commit.get("state_committed", false)) \
		and frozen_resolutions.size() == 1 \
		and _variant_equal_with_numeric_values(
			frozen_resolutions.get(route_id, {}), expected_resolution) \
		and int(GameState.mental) == mental_before - 2 \
		and int(main_game.get_meta(
			"_qa_core_loop_v2_autosave_call_count", 0)) == 1,
		"q0 autosave failure did not freeze one completion/effect/resolution")
	_expect(not bool(main_game.call("_core_loop_v2_autosave_durable_state")) \
		and not bool(main_game.call("_core_loop_v2_autosave_durable_state")) \
		and GameState.serialize() == frozen \
		and int(GameState.mental) == mental_before - 2 \
		and _variant_equal_with_numeric_values(
			CORE.terminal_transition_resolution(route_id), expected_resolution),
		"failed q0 autosave retries replayed gameplay or resolution state")
	main_game.set_meta("_qa_core_loop_v2_autosave_result", true)
	_expect(bool(main_game.call("_core_loop_v2_autosave_durable_state")) \
		and GameState.serialize() == frozen \
		and int(GameState.mental) == mental_before - 2 \
		and int(main_game.get_meta(
			"_qa_core_loop_v2_autosave_call_count", 0)) == 4,
		"successful q0 autosave retry changed its frozen transaction")
	main_game.free()


func _check_terminal_completed_historical_resolution(
		resolved_save: Dictionary, route_id: String,
		expected_resolution: Dictionary) -> void:
	_expect(not resolved_save.is_empty(),
		"q0 completed historical fixture had no resolved live save")
	if resolved_save.is_empty():
		return
	GameState.start_new_game()
	GameState.load_from_dict(resolved_save.duplicate(true))
	CORE.initialize_for_run(true)
	if not bool(CORE.complete_seoul_cycle_turn(2).get("ok", false)):
		_expect(false, "q0 completed historical fixture could not close W6")
		return
	for turn in range(7, 9):
		_advance_to_next_week()
		if not _commit_m2_terminal_filler():
			return
		if turn == 8 and not _resolve_cycle_story_world(
				"temptation_consequence", "arc_temptation_clean", 0):
			return
		if not bool(CORE.complete_seoul_cycle_turn(2).get("ok", false)):
			_expect(false,
				"q0 completed historical fixture could not close W%d" % turn)
			return
	var summary := CORE.record_month_summary(2, {}, {})
	var summary_resolutions: Dictionary = summary.get(
		"terminal_transition_resolutions", {})
	_expect(_variant_equal_with_numeric_values(
		summary_resolutions.get(route_id, {}), expected_resolution),
		"q0 completed resolution was not frozen into the closed M2 summary")
	_advance_to_next_week()
	var initialized := CORE.initialize_seoul_cycle(3)
	var historical_save: Dictionary = GameState.serialize().duplicate(true)
	_expect(bool(initialized.get("ok", false)) \
		and _variant_equal_with_numeric_values(
			CORE.terminal_transition_resolution(route_id), expected_resolution),
		"q0 completed resolution did not survive closed-target replacement")
	for reload_index in range(2):
		GameState.start_new_game()
		GameState.load_from_dict(historical_save.duplicate(true))
		CORE.initialize_for_run(true)
		_expect(_variant_equal_with_numeric_values(
			CORE.terminal_transition_resolution(route_id), expected_resolution),
			"q0 historical completed resolution drifted on reload %d" \
				% [reload_index + 1])
		historical_save = GameState.serialize().duplicate(true)
	_check_terminal_completed_historical_allocation_identity_rejected(
		historical_save, route_id, expected_resolution)
	_check_terminal_historical_resolution_mutations(
		historical_save, 2, route_id, expected_resolution)


func _check_terminal_historical_resolution_mutations(
		historical_save: Dictionary, target_month: int,
		route_id: String, expected_resolution: Dictionary) -> void:
	var mutations: Array[String] = [
		"root_delete", "summary_delete", "summary_target_turn",
		"summary_planning_mode", "coupled_target_turn",
		"coupled_sibling_injection",
	]
	var resolution_kind := str(expected_resolution.get("resolution", ""))
	if resolution_kind == "completed":
		mutations.append("fractional_completed_turn")
	elif resolution_kind == "expired":
		mutations.append("fractional_expired_turn")
	if int(expected_resolution.get("target_turn", 0)) == 6:
		mutations.append("fractional_allocation_turn")
	for mutation in mutations:
		var malformed := historical_save.duplicate(true)
		var state: Dictionary = malformed.get("core_loop_v2_state", {})
		var root_resolutions: Dictionary = state.get(
			"terminal_transition_resolutions", {})
		var summaries: Dictionary = state.get("month_summaries", {})
		var summary: Dictionary = summaries.get(str(target_month), {})
		var summary_resolutions: Dictionary = summary.get(
			"terminal_transition_resolutions", {})
		_expect(_variant_equal_with_numeric_values(
			root_resolutions.get(route_id, {}), expected_resolution) \
			and _variant_equal_with_numeric_values(
				summary_resolutions.get(route_id, {}), expected_resolution) \
			and str(summary.get("planning_mode", "")) \
				== CORE.SEOUL_CYCLE_MODE,
			"historical resolution mutation fixture lacked exact dual authority")
		match mutation:
			"root_delete":
				root_resolutions.erase(route_id)
			"summary_delete":
				summary_resolutions.erase(route_id)
			"summary_target_turn":
				var changed: Dictionary = summary_resolutions.get(
					route_id, {}).duplicate(true)
				changed["target_turn"] = int(changed.get("target_turn", 0)) - 1
				summary_resolutions[route_id] = changed
			"summary_planning_mode":
				summary["planning_mode"] = CORE.MONTH_ONE_EPISODE_MODE
			"coupled_target_turn":
				for surface in [root_resolutions, summary_resolutions]:
					var changed: Dictionary = surface.get(
						route_id, {}).duplicate(true)
					changed["target_turn"] = int(
						changed.get("target_turn", 0)) - 1
					surface[route_id] = changed
			"coupled_sibling_injection":
				var sibling := expected_resolution.duplicate(true)
				sibling["route_id"] = "terminal_injected_sibling"
				root_resolutions["terminal_injected_sibling"] = sibling.duplicate(true)
				summary_resolutions["terminal_injected_sibling"] = sibling
			"fractional_completed_turn", "fractional_expired_turn":
				var node_states: Dictionary = summary.get("node_states", {})
				var target_node := str(expected_resolution.get("target_node", ""))
				var node: Dictionary = node_states.get(target_node, {})
				var turn_field := "completed_turn" \
					if mutation == "fractional_completed_turn" \
					else "expired_turn"
				node[turn_field] = 6.5
				node_states[target_node] = node
				summary["node_states"] = node_states
			"fractional_allocation_turn":
				var allocations: Array = summary.get("allocation_receipts", [])
				var target_turn := int(expected_resolution.get("target_turn", 0))
				for allocation_index in range(allocations.size()):
					var raw_allocation: Variant = allocations[allocation_index]
					if raw_allocation is Dictionary \
							and int((raw_allocation as Dictionary).get(
								"turn", 0)) == target_turn:
						var allocation: Dictionary = (
							raw_allocation as Dictionary).duplicate(true)
						allocation["turn"] = 6.5
						allocations[allocation_index] = allocation
						break
				summary["allocation_receipts"] = allocations
		summary["terminal_transition_resolutions"] = summary_resolutions
		summaries[str(target_month)] = summary
		state["terminal_transition_resolutions"] = root_resolutions
		state["month_summaries"] = summaries
		malformed["core_loop_v2_state"] = state
		GameState.start_new_game()
		GameState.load_from_dict(malformed)
		CORE.initialize_for_run(true)
		var before_read: Dictionary = GameState.serialize().duplicate(true)
		var reader_empty := CORE.terminal_transition_resolution(route_id).is_empty()
		var month_reader_empty := CORE.month_summary(target_month).is_empty()
		var pending_summary := CORE.pending_month_summary()
		var pending_excludes_target := pending_summary.is_empty() \
			or int(pending_summary.get("month", 0)) != target_month
		var acknowledged := CORE.acknowledge_month_summary(target_month)
		_expect(reader_empty \
			and month_reader_empty \
			and pending_excludes_target \
			and not acknowledged \
			and GameState.serialize() == before_read,
			"historical resolution accepted %s authority mutation" % mutation)


func _check_terminal_completed_historical_allocation_identity_rejected(
		historical_save: Dictionary, route_id: String,
		expected_resolution: Dictionary) -> void:
	var baseline_state: Dictionary = historical_save.get(
		"core_loop_v2_state", {})
	var summaries: Dictionary = baseline_state.get("month_summaries", {})
	var summary: Dictionary = summaries.get("2", {})
	var summary_resolutions: Dictionary = summary.get(
		"terminal_transition_resolutions", {})
	var root_resolutions: Dictionary = baseline_state.get(
		"terminal_transition_resolutions", {})
	var allocations: Array = summary.get("allocation_receipts", [])
	var allocation_index := -1
	var allocation: Dictionary = {}
	for index in range(allocations.size()):
		var raw_allocation: Variant = allocations[index]
		if raw_allocation is Dictionary \
				and int((raw_allocation as Dictionary).get("turn", 0)) == 6 \
				and str((raw_allocation as Dictionary).get(
					"node_id", "")) == "m2_advancement":
			allocation_index = index
			allocation = (raw_allocation as Dictionary).duplicate(true)
			break
	var embedded: Dictionary = allocation.get("weekly_commitment", {})
	var embedded_details: Dictionary = embedded.get("details", {})
	var outer: Array = historical_save.get("weekly_commitments", [])
	var outer_index := -1
	var outer_row: Dictionary = {}
	for index in range(outer.size()):
		var raw_outer: Variant = outer[index]
		if raw_outer is Dictionary \
				and int((raw_outer as Dictionary).get("turn", 0)) == 6:
			outer_index = index
			outer_row = (raw_outer as Dictionary).duplicate(true)
			break
	var outer_details: Dictionary = outer_row.get("details", {})
	var identity_fields: Array[String] = [
		"selected_trigger_candidate_id", "selected_trigger_bundle_id",
		"selected_terminal_route_id", "terminal_variant_id",
		"terminal_target_binding", "terminal_completion_effects",
	]
	var identity_exact := allocation_index >= 0 and outer_index >= 0
	for field in identity_fields:
		identity_exact = identity_exact \
			and allocation.has(field) \
			and _variant_equal_with_numeric_values(
				allocation.get(field), embedded_details.get(field)) \
			and _variant_equal_with_numeric_values(
				allocation.get(field), outer_details.get(field))
	var source_receipt: Dictionary = (
		baseline_state.get("terminal_transition_receipts", {}) as Dictionary).get(
			route_id, {})
	_expect(identity_exact \
		and str(allocation.get("selected_trigger_candidate_id", "")) \
			== "terminal:%s" % route_id \
		and str(allocation.get("selected_trigger_bundle_id", "")) \
			== "m2_seorin_application" \
		and str(allocation.get("selected_terminal_route_id", "")) == route_id \
		and str(allocation.get("terminal_variant_id", "")) \
			== "resume_rewritten" \
		and not source_receipt.is_empty() \
		and _variant_equal_with_numeric_values(
			root_resolutions.get(route_id, {}), expected_resolution) \
		and _variant_equal_with_numeric_values(
			summary_resolutions.get(route_id, {}), expected_resolution),
		"completed historical identity fixture lacked its three exact allocation copies")
	if not identity_exact or source_receipt.is_empty():
		return

	for mutation in ["delete_identity", "coupled_sibling_identity"]:
		var malformed := historical_save.duplicate(true)
		var state: Dictionary = malformed.get("core_loop_v2_state", {})
		var malformed_summaries: Dictionary = state.get("month_summaries", {})
		var malformed_summary: Dictionary = malformed_summaries.get("2", {})
		var malformed_allocations: Array = malformed_summary.get(
			"allocation_receipts", [])
		var changed_allocation: Dictionary = (
			malformed_allocations[allocation_index] as Dictionary).duplicate(true)
		var changed_embedded: Dictionary = changed_allocation.get(
			"weekly_commitment", {}).duplicate(true)
		var changed_embedded_details: Dictionary = changed_embedded.get(
			"details", {}).duplicate(true)
		var malformed_outer: Array = malformed.get(
			"weekly_commitments", []).duplicate(true)
		var changed_outer: Dictionary = (
			malformed_outer[outer_index] as Dictionary).duplicate(true)
		var changed_outer_details: Dictionary = changed_outer.get(
			"details", {}).duplicate(true)
		if mutation == "delete_identity":
			for field in identity_fields:
				changed_allocation.erase(field)
				changed_embedded_details.erase(field)
				changed_outer_details.erase(field)
		else:
			var forged_binding: Dictionary = allocation.get(
				"terminal_target_binding", {}).duplicate(true)
			forged_binding["route_id"] = "terminal_forged_route"
			forged_binding["variant_id"] = "forged_variant"
			forged_binding["target_bundle"] = "m2_hanbit_application"
			var forged_values := {
				"selected_trigger_candidate_id": \
					"terminal:terminal_forged_route",
				"selected_trigger_bundle_id": "m2_hanbit_application",
				"selected_terminal_route_id": "terminal_forged_route",
				"terminal_variant_id": "forged_variant",
				"terminal_target_binding": forged_binding,
				"terminal_completion_effects": {"mental": -1},
			}
			for field in identity_fields:
				var forged_value: Variant = forged_values[field]
				changed_allocation[field] = forged_value.duplicate(true) \
					if forged_value is Dictionary else forged_value
				changed_embedded_details[field] = forged_value.duplicate(true) \
					if forged_value is Dictionary else forged_value
				changed_outer_details[field] = forged_value.duplicate(true) \
					if forged_value is Dictionary else forged_value
		changed_embedded["details"] = changed_embedded_details
		changed_allocation["weekly_commitment"] = changed_embedded
		malformed_allocations[allocation_index] = changed_allocation
		malformed_summary["allocation_receipts"] = malformed_allocations
		malformed_summaries["2"] = malformed_summary
		state["month_summaries"] = malformed_summaries
		malformed["core_loop_v2_state"] = state
		changed_outer["details"] = changed_outer_details
		malformed_outer[outer_index] = changed_outer
		malformed["weekly_commitments"] = malformed_outer
		_expect(_variant_equal_with_numeric_values(
			(state.get("terminal_transition_resolutions", {}) as Dictionary).get(
				route_id, {}), expected_resolution) \
			and _variant_equal_with_numeric_values(
				(malformed_summary.get(
					"terminal_transition_resolutions", {}) as Dictionary).get(
					route_id, {}), expected_resolution),
			"historical allocation identity attack changed its frozen resolution")

		GameState.start_new_game()
		GameState.load_from_dict(malformed)
		CORE.initialize_for_run(true)
		var before_read: Dictionary = GameState.serialize().duplicate(true)
		_expect(not CORE.terminal_transition_receipt(route_id).is_empty() \
			and CORE.terminal_transition_resolution(route_id).is_empty() \
			and GameState.serialize() == before_read,
			"historical resolution accepted %s across three allocation copies" \
				% mutation)


func _check_terminal_active_allocation_authority_rejected(
		partial_saved: Dictionary, route_id: String,
		candidate_id: String, binding: Dictionary) -> void:
	var baseline_state: Dictionary = partial_saved.get("core_loop_v2_state", {})
	var baseline_cycle: Dictionary = baseline_state.get("seoul_cycle", {})
	var baseline_nodes: Dictionary = baseline_cycle.get("nodes", {})
	var baseline_node: Dictionary = baseline_nodes.get("m2_advancement", {})
	var authored_node: Dictionary = (
		CORE.seoul_cycle_month_spec(2).get("nodes", {}) as Dictionary).get(
			"m2_advancement", {})
	var baseline_allocations: Dictionary = baseline_cycle.get(
		"allocation_receipts", {})
	var allocation_key: Variant = null
	var baseline_allocation: Dictionary = {}
	for raw_key in baseline_allocations.keys():
		var raw_allocation: Variant = baseline_allocations.get(raw_key, {})
		if raw_allocation is Dictionary \
				and int((raw_allocation as Dictionary).get("turn", 0)) == 5 \
				and str((raw_allocation as Dictionary).get("node_id", "")) \
					== "m2_advancement":
			allocation_key = raw_key
			baseline_allocation = (
				raw_allocation as Dictionary).duplicate(true)
			break
	var baseline_capacity: Dictionary = {}
	var baseline_capacity_index := -1
	var raw_capacities: Array = baseline_cycle.get("capacities", [])
	for index in range(raw_capacities.size()):
		var raw_capacity: Variant = raw_capacities[index]
		if raw_capacity is Dictionary \
				and str((raw_capacity as Dictionary).get("id", "")) \
					== str(baseline_allocation.get("capacity_id", "")):
			baseline_capacity = (raw_capacity as Dictionary).duplicate(true)
			baseline_capacity_index = index
			break
	var baseline_weekly: Dictionary = baseline_allocation.get(
		"weekly_commitment", {})
	var baseline_details: Dictionary = baseline_weekly.get("details", {})
	var outer_weekly: Array = partial_saved.get("weekly_commitments", [])
	var outer_index := -1
	for index in range(outer_weekly.size()):
		var raw_weekly: Variant = outer_weekly[index]
		if raw_weekly is Dictionary \
				and int((raw_weekly as Dictionary).get("turn", 0)) == 5:
			outer_index = index
			break
	var baseline_outer: Dictionary = (
		outer_weekly[outer_index] as Dictionary) if outer_index >= 0 else {}
	var original_value := int(baseline_capacity.get("value", 0))
	var original_quality := str(baseline_capacity.get("quality", ""))
	_expect(allocation_key != null \
		and not baseline_capacity.is_empty() \
		and bool(baseline_capacity.get("consumed", false)) \
		and int(baseline_capacity.get("consumed_turn", 0)) == 5 \
		and str(baseline_capacity.get("node_id", "")) == "m2_advancement" \
		and original_value in range(1, 7) \
		and original_quality in ["strained", "steady", "strong"] \
		and int(baseline_allocation.get("capacity_value", 0)) == original_value \
		and str(baseline_allocation.get("capacity_quality", "")) \
			== original_quality \
		and str(baseline_allocation.get("id", "")) == "seoul_cycle_m2_w1" \
		and str(baseline_allocation.get("status", "")) == "allocated" \
		and str(baseline_allocation.get("planning_mode", "")) \
			== "seoul_cycle_v1" \
		and int(baseline_allocation.get("month", 0)) == 2 \
		and int(baseline_allocation.get("turn", 0)) == 5 \
		and int(baseline_allocation.get("week_index", 0)) == 1 \
		and int(baseline_allocation.get("progress_before", -1)) == 0 \
		and int(baseline_allocation.get("progress_gain", -1)) == 1 \
		and int(baseline_allocation.get("progress_after", -1)) == 1 \
		and int(baseline_allocation.get("threshold", 0)) == 2 \
		and int(baseline_allocation.get("authored_threshold", 0)) == 2 \
		and baseline_allocation.get("completed_now", null) is bool \
		and baseline_allocation.get("repeat_allocation", null) is bool \
		and baseline_allocation.get("fallback_allocation", null) is bool \
		and not bool(baseline_allocation.get("completed_now", true)) \
		and not authored_node.has("fallback_after_trigger_expiry") \
		and not bool(baseline_node.get("fallback_mode", false)) \
		and int(baseline_node.get("progress", -1)) == 1 \
		and str(baseline_node.get("selected_trigger_candidate_id", "")) \
			== candidate_id \
		and str(baseline_node.get("selected_terminal_route_id", "")) \
			== route_id \
		and int(baseline_details.get("capacity_value", 0)) == original_value \
		and str(baseline_details.get("capacity_quality", "")) \
			== original_quality \
		and int(baseline_details.get("progress_after", -1)) == 1 \
		and not bool(baseline_details.get("completed_now", true)) \
		and outer_index >= 0 \
		and str(baseline_weekly.get("axis", "")) == "human" \
		and str(baseline_outer.get("axis", "")) == "human" \
		and baseline_capacity_index >= 0 \
		and CORE.terminal_transition_resolution(route_id).is_empty(),
		"q0 active-allocation mutation fixture was not one genuine partial commit")
	if allocation_key == null or baseline_capacity.is_empty() \
			or outer_index < 0 or baseline_capacity_index < 0:
		return
	var sibling_value := original_value + 1 if original_value < 6 else 5
	var sibling_quality := "steady" if original_quality != "steady" else "strong"
	for mutation in [
		"receipt_capacity_value", "receipt_capacity_quality",
		"receipt_progress_gain", "node_progress", "weekly_capacity_value",
		"weekly_capacity_quality", "weekly_progress", "weekly_completed_now",
		"receipt_completed_now", "receipt_effects", "completed_resolution",
		"fractional_capacity", "node_status", "node_completed_turn",
		"embedded_axis", "outer_axis", "coupled_axis",
		"fully_coupled_completion",
		"receipt_id", "receipt_status", "receipt_planning_mode",
		"fractional_month", "fractional_turn", "fractional_week_index",
		"fractional_progress_before", "fractional_progress_gain",
		"fractional_progress_after", "fractional_threshold",
		"fractional_authored_threshold", "nonbool_completed",
		"nonbool_repeat", "nonbool_fallback", "coupled_fallback",
	]:
		var malformed := partial_saved.duplicate(true)
		var state: Dictionary = malformed.get("core_loop_v2_state", {})
		var cycle: Dictionary = state.get("seoul_cycle", {})
		var capacities: Array = cycle.get("capacities", [])
		var capacity: Dictionary = (
			capacities[baseline_capacity_index] as Dictionary).duplicate(true)
		var nodes: Dictionary = cycle.get("nodes", {})
		var node: Dictionary = nodes.get("m2_advancement", {})
		var allocations: Dictionary = cycle.get("allocation_receipts", {})
		var allocation: Dictionary = allocations.get(allocation_key, {})
		var weekly: Dictionary = allocation.get("weekly_commitment", {})
		var details: Dictionary = weekly.get("details", {})
		var malformed_outer: Array = malformed.get("weekly_commitments", [])
		var matching_outer: Dictionary = (
			malformed_outer[outer_index] as Dictionary).duplicate(true)
		var outer_details: Dictionary = matching_outer.get("details", {})
		match mutation:
			"receipt_capacity_value":
				allocation["capacity_value"] = sibling_value
			"receipt_capacity_quality":
				allocation["capacity_quality"] = sibling_quality
			"receipt_progress_gain":
				allocation["progress_gain"] = 2
			"node_progress":
				node["progress"] = 2
			"weekly_capacity_value":
				details["capacity_value"] = sibling_value
				outer_details["capacity_value"] = sibling_value
			"weekly_capacity_quality":
				details["capacity_quality"] = sibling_quality
				outer_details["capacity_quality"] = sibling_quality
			"weekly_progress":
				details["progress_after"] = 2
				outer_details["progress_after"] = 2
			"weekly_completed_now":
				details["completed_now"] = true
				outer_details["completed_now"] = true
			"receipt_completed_now":
				allocation["completed_now"] = true
			"receipt_effects":
				var before: Dictionary = allocation.get("before", {})
				var after: Dictionary = before.duplicate(true)
				after["mental"] = int(before.get("mental", 0)) - 2
				allocation["effects"] = {"mental": -2}
				allocation["after"] = after
			"completed_resolution":
				var resolutions: Dictionary = state.get(
					"terminal_transition_resolutions", {})
				resolutions[route_id] = {
					"schema": CORE.TERMINAL_TARGET_BINDING_SCHEMA,
					"route_id": route_id,
					"resolution": "completed",
					"binding": binding.duplicate(true),
					"target_month": 2,
					"target_node": "m2_advancement",
					"target_turn": 5,
					"allocation_receipt_id": "seoul_cycle_m2_w1",
					"allocation_receipt_key": "seoul_cycle.allocation_receipts.5",
					"selected_candidate_id": candidate_id,
					"selected_terminal_route_id": route_id,
					"variant_id": "resume_rewritten",
					"effect_applied": true,
					"result_variant": "resume_rewritten",
				}
				state["terminal_transition_resolutions"] = resolutions
			"fractional_capacity":
				var fractional_value := float(original_value) + 0.5
				capacity["value"] = fractional_value
				allocation["capacity_value"] = fractional_value
				details["capacity_value"] = fractional_value
				outer_details["capacity_value"] = fractional_value
			"node_status":
				node["status"] = "completed"
			"node_completed_turn":
				node["completed_turn"] = 5
			"embedded_axis":
				weekly["axis"] = "money"
			"outer_axis":
				matching_outer["axis"] = "money"
			"coupled_axis":
				weekly["axis"] = "money"
				matching_outer["axis"] = "money"
			"fully_coupled_completion":
				var forged_value := 3
				var forged_quality := "steady"
				capacity["value"] = forged_value
				capacity["quality"] = forged_quality
				allocation["capacity_value"] = forged_value
				allocation["capacity_quality"] = forged_quality
				allocation["progress_gain"] = 2
				allocation["progress_after"] = 2
				allocation["completed_now"] = true
				allocation["trigger_bundle"] = "m2_seorin_application"
				var forged_before: Dictionary = allocation.get("before", {})
				var forged_after: Dictionary = forged_before.duplicate(true)
				forged_after["mental"] = int(
					forged_before.get("mental", 0)) - 2
				allocation["effects"] = {"mental": -2}
				allocation["after"] = forged_after
				for key in [
					"capacity_value", "capacity_quality", "progress_gain",
					"progress_after", "completed_now",
				]:
					details[key] = allocation[key]
					outer_details[key] = allocation[key]
				weekly["outcome"] = {"mental": -2}
				matching_outer["outcome"] = {"mental": -2}
				node["progress"] = 2
				node["status"] = "awaiting_trigger"
				node["completed_turn"] = 5
				node["last_allocation_turn"] = 5
				cycle["pending_trigger"] = {
					"kind": "node_trigger",
					"node_id": "m2_advancement",
					"bundle_id": "m2_seorin_application",
					"selected_trigger_bundle_id": "m2_seorin_application",
					"selected_trigger_candidate_id": candidate_id,
					"selected_terminal_route_id": route_id,
					"terminal_variant_id": "resume_rewritten",
					"terminal_target_binding": binding.duplicate(true),
					"turn": 5,
					"status": "pending",
				}
				var coupled_resolutions: Dictionary = state.get(
					"terminal_transition_resolutions", {})
				coupled_resolutions[route_id] = {
					"schema": CORE.TERMINAL_TARGET_BINDING_SCHEMA,
					"route_id": route_id,
					"resolution": "completed",
					"binding": binding.duplicate(true),
					"target_month": 2,
					"target_node": "m2_advancement",
					"target_turn": 5,
					"allocation_receipt_id": "seoul_cycle_m2_w1",
					"allocation_receipt_key": "seoul_cycle.allocation_receipts.5",
					"selected_candidate_id": candidate_id,
					"selected_terminal_route_id": route_id,
					"variant_id": "resume_rewritten",
					"effect_applied": true,
					"result_variant": "resume_rewritten",
				}
				state["terminal_transition_resolutions"] = coupled_resolutions
				malformed["mental"] = int(malformed.get("mental", 0)) - 2
			"receipt_id":
				allocation["id"] = "seoul_cycle_m2_w2"
			"receipt_status":
				allocation["status"] = "turn_completed"
			"receipt_planning_mode":
				allocation["planning_mode"] = "legacy_plan"
			"fractional_month":
				allocation["month"] = 2.5
			"fractional_turn":
				allocation["turn"] = 5.5
			"fractional_week_index":
				allocation["week_index"] = 1.5
			"fractional_progress_before":
				allocation["progress_before"] = 0.5
			"fractional_progress_gain":
				allocation["progress_gain"] = 1.5
			"fractional_progress_after":
				allocation["progress_after"] = 1.5
			"fractional_threshold":
				allocation["threshold"] = 2.5
			"fractional_authored_threshold":
				allocation["authored_threshold"] = 2.5
			"nonbool_completed":
				allocation["completed_now"] = "false"
			"nonbool_repeat":
				allocation["repeat_allocation"] = "false"
			"nonbool_fallback":
				allocation["fallback_allocation"] = "false"
			"coupled_fallback":
				allocation["progress_gain"] = 0
				allocation["progress_after"] = 0
				allocation["fallback_allocation"] = true
				allocation["effects"] = {}
				allocation["after"] = (
					allocation.get("before", {}) as Dictionary).duplicate(true)
				for key in [
					"progress_gain", "progress_after", "fallback_allocation",
				]:
					details[key] = allocation[key]
					outer_details[key] = allocation[key]
				weekly["outcome"] = {}
				matching_outer["outcome"] = {}
				node["progress"] = 0
				node["status"] = "open"
				node["completed_turn"] = 0
				node["last_allocation_turn"] = 5
		weekly["details"] = details
		allocation["weekly_commitment"] = weekly
		allocations[allocation_key] = allocation
		cycle["allocation_receipts"] = allocations
		capacities[baseline_capacity_index] = capacity
		cycle["capacities"] = capacities
		nodes["m2_advancement"] = node
		cycle["nodes"] = nodes
		state["seoul_cycle"] = cycle
		matching_outer["details"] = outer_details
		malformed_outer[outer_index] = matching_outer
		malformed["weekly_commitments"] = malformed_outer
		malformed["core_loop_v2_state"] = state
		GameState.start_new_game()
		GameState.load_from_dict(malformed)
		CORE.initialize_for_run(true)
		var before_retry: Dictionary = GameState.serialize().duplicate(true)
		var retried := CORE.initialize_seoul_cycle(2)
		_expect(not bool(CORE.seoul_cycle_snapshot(2).get("active", true)) \
			and CORE.terminal_target_candidates(
				2, "m2_advancement").is_empty() \
			and CORE.terminal_transition_resolution(route_id).is_empty() \
			and not bool(retried.get("ok", true)) \
			and str(retried.get("error", "")) == "terminal_binding_conflict" \
			and GameState.serialize() == before_retry,
			"q0 active allocation accepted %s authority mutation" % mutation)


func _check_terminal_completed_target_authority_rejected(
		completed_saved: Dictionary, route_id: String,
		candidate_id: String, binding: Dictionary) -> Dictionary:
	var baseline_state: Dictionary = completed_saved.get("core_loop_v2_state", {})
	var baseline_cycle: Dictionary = baseline_state.get("seoul_cycle", {})
	var baseline_node: Dictionary = (
		baseline_cycle.get("nodes", {}) as Dictionary).get(
			"m2_advancement", {})
	var baseline_pending: Dictionary = baseline_cycle.get("pending_trigger", {})
	var baseline_resolution: Dictionary = (
		baseline_state.get("terminal_transition_resolutions", {}) \
			as Dictionary).get(route_id, {})
	_expect(str(baseline_node.get("status", "")) == "awaiting_trigger" \
		and int(baseline_node.get("progress", 0)) == 2 \
		and int(baseline_node.get("completed_turn", 0)) == 6 \
		and int(baseline_node.get("last_allocation_turn", 0)) == 6 \
		and str(baseline_pending.get("node_id", "")) == "m2_advancement" \
		and str(baseline_pending.get("bundle_id", "")) \
			== "m2_seorin_application" \
		and str(baseline_pending.get("selected_trigger_candidate_id", "")) \
			== candidate_id \
		and str(baseline_resolution.get("resolution", "")) == "completed",
		"q0 completed-target mutation fixture was not awaiting its exact trigger")
	if baseline_pending.is_empty() or baseline_resolution.is_empty():
		return {}
	_check_terminal_live_resolution_binding_erasure_rejected(
		completed_saved, route_id, baseline_resolution)
	for mutation in ["node_status", "node_completed_turn", "pending_deleted"]:
		var malformed := completed_saved.duplicate(true)
		var state: Dictionary = malformed.get("core_loop_v2_state", {})
		var cycle: Dictionary = state.get("seoul_cycle", {})
		var nodes: Dictionary = cycle.get("nodes", {})
		var node: Dictionary = nodes.get("m2_advancement", {})
		match mutation:
			"node_status":
				node["status"] = "completed"
			"node_completed_turn":
				node["completed_turn"] = 5
			"pending_deleted":
				cycle["pending_trigger"] = {}
		nodes["m2_advancement"] = node
		cycle["nodes"] = nodes
		state["seoul_cycle"] = cycle
		malformed["core_loop_v2_state"] = state
		_expect_terminal_active_target_mutation_rejected(
			malformed, route_id, "q0 completed %s" % mutation)

	GameState.start_new_game()
	GameState.load_from_dict(completed_saved.duplicate(true))
	CORE.initialize_for_run(true)
	var claimed := CORE.claim_seoul_cycle_trigger()
	var began := bool(claimed.get("ok", false)) \
		and CORE.begin_seoul_cycle_trigger("m2_seorin_application")
	var armed := began and GameState.arm_weekly_commitment({
		"turn": int(GameState.turn),
		"pressure_id": "m2_seorin_application",
		"pressure_family": "growth",
		"choice_id": "apply",
		"forgone_ids": [],
		"supplemental_to_seoul_cycle": true,
	})
	var transaction: Dictionary = {}
	if armed:
		transaction = GameState.finalize_weekly_effect_action(
			"apply", {}, "money", "work", "", {
				"execution": "application",
				"application_id": "seorin_contract_2026q1",
				"status": "submitted",
			})
	var action_noted := bool(transaction.get("ok", false)) \
		and CORE.note_action_commitment(
			transaction.get("record", {}) as Dictionary)
	var resolved_bundle := CORE.complete_active_bundle() if action_noted else ""
	var resolved_save: Dictionary = GameState.serialize().duplicate(true)
	var resolved_state: Dictionary = resolved_save.get("core_loop_v2_state", {})
	var resolved_cycle: Dictionary = resolved_state.get("seoul_cycle", {})
	var resolved_node: Dictionary = (
		resolved_cycle.get("nodes", {}) as Dictionary).get(
			"m2_advancement", {})
	var trigger_receipts: Dictionary = resolved_cycle.get("trigger_receipts", {})
	_expect(began and armed and action_noted \
		and resolved_bundle == "m2_seorin_application" \
		and str(resolved_node.get("status", "")) == "completed" \
		and (resolved_cycle.get("pending_trigger", {}) as Dictionary).is_empty() \
		and not (trigger_receipts.get(
			"m2_advancement", {}) as Dictionary).is_empty() \
		and _variant_equal_with_numeric_values(
			CORE.terminal_transition_resolution(route_id), baseline_resolution),
		"q0 completed-target fixture could not resolve its actual trigger")
	if resolved_bundle == "m2_seorin_application" \
			and not (trigger_receipts.get(
				"m2_advancement", {}) as Dictionary).is_empty():
		var missing_trigger_save := resolved_save.duplicate(true)
		var missing_state: Dictionary = missing_trigger_save.get(
			"core_loop_v2_state", {})
		var missing_cycle: Dictionary = missing_state.get("seoul_cycle", {})
		var missing_receipts: Dictionary = missing_cycle.get(
			"trigger_receipts", {})
		missing_receipts.erase("m2_advancement")
		missing_cycle["trigger_receipts"] = missing_receipts
		missing_state["seoul_cycle"] = missing_cycle
		missing_trigger_save["core_loop_v2_state"] = missing_state
		_expect_terminal_active_target_mutation_rejected(
			missing_trigger_save, route_id, "q0 resolved trigger deletion")
	return resolved_save


func _check_terminal_live_resolution_binding_erasure_rejected(
		completed_saved: Dictionary, route_id: String,
		expected_resolution: Dictionary) -> void:
	var baseline_state: Dictionary = completed_saved.get(
		"core_loop_v2_state", {})
	var baseline_receipts: Dictionary = baseline_state.get(
		"terminal_transition_receipts", {})
	var source_receipt: Dictionary = baseline_receipts.get(route_id, {})
	var baseline_resolutions: Dictionary = baseline_state.get(
		"terminal_transition_resolutions", {})
	var baseline_cycle: Dictionary = baseline_state.get("seoul_cycle", {})
	var baseline_nodes: Dictionary = baseline_cycle.get("nodes", {})
	var baseline_node: Dictionary = baseline_nodes.get("m2_advancement", {})
	var baseline_plans: Dictionary = baseline_state.get("plans", {})
	var baseline_plan: Dictionary = baseline_plans.get("2", {})
	var baseline_witnesses: Dictionary = baseline_state.get(
		"terminal_target_binding_receipts", {})
	var target_witness: Dictionary = baseline_witnesses.get(
		"2:m2_advancement", {})
	_expect(not source_receipt.is_empty() \
		and _variant_equal_with_numeric_values(
			baseline_resolutions.get(route_id, {}), expected_resolution) \
		and int(baseline_cycle.get("terminal_binding_schema", 0)) \
			== CORE.TERMINAL_TARGET_BINDING_SCHEMA \
		and (baseline_cycle.get("terminal_bound_node_ids", []) as Array).has(
			"m2_advancement") \
		and not (baseline_node.get(
			"terminal_route_bindings", {}) as Dictionary).is_empty() \
		and int(baseline_plan.get("terminal_binding_schema", 0)) \
			== CORE.TERMINAL_TARGET_BINDING_SCHEMA \
		and not (baseline_plan.get(
			"terminal_binding_candidate_sets", {}) as Dictionary).is_empty() \
		and not target_witness.is_empty(),
		"q0 live-resolution erasure fixture lacked exact source/root/binding authority")
	if source_receipt.is_empty() or target_witness.is_empty():
		return

	for mutation in ["node_only", "coupled_legacy_downgrade"]:
		var malformed := completed_saved.duplicate(true)
		var state: Dictionary = malformed.get("core_loop_v2_state", {})
		var cycle: Dictionary = state.get("seoul_cycle", {})
		var nodes: Dictionary = cycle.get("nodes", {})
		if mutation == "node_only":
			var node: Dictionary = nodes.get("m2_advancement", {})
			node.erase("terminal_route_bindings")
			nodes["m2_advancement"] = node
			cycle["nodes"] = nodes
		else:
			cycle.erase("terminal_binding_schema")
			cycle.erase("terminal_bound_node_ids")
			for raw_node_id in nodes.keys():
				var node: Dictionary = nodes.get(raw_node_id, {})
				for field in [
					"binding_candidate_ids", "ordinary_candidate_ids",
					"eligible_terminal_route_ids", "terminal_route_bindings",
					"selected_trigger_candidate_id",
					"selected_terminal_route_id", "terminal_selection_origin",
					"terminal_result_ko", "terminal_result_en",
					"terminal_completion_effects",
				]:
					node.erase(field)
				nodes[raw_node_id] = node
			cycle["nodes"] = nodes
			var plans: Dictionary = state.get("plans", {})
			var plan: Dictionary = plans.get("2", {})
			plan.erase("terminal_binding_schema")
			plan.erase("terminal_bound_node_ids")
			plan.erase("terminal_binding_candidate_sets")
			plans["2"] = plan
			state["plans"] = plans
			var witnesses: Dictionary = state.get(
				"terminal_target_binding_receipts", {})
			for raw_witness_key in witnesses.keys():
				var raw_witness: Variant = witnesses.get(raw_witness_key, {})
				if raw_witness is Dictionary \
						and int((raw_witness as Dictionary).get(
							"target_month", 0)) == 2:
					witnesses.erase(raw_witness_key)
			state["terminal_target_binding_receipts"] = witnesses
		state["seoul_cycle"] = cycle
		malformed["core_loop_v2_state"] = state
		_expect(_variant_equal_with_numeric_values(
			(state.get("terminal_transition_receipts", {}) as Dictionary).get(
				route_id, {}), source_receipt) \
			and _variant_equal_with_numeric_values(
				(state.get("terminal_transition_resolutions", {}) as Dictionary).get(
					route_id, {}), expected_resolution),
			"q0 %s attack changed its retained source receipt/root resolution" \
				% mutation)

		GameState.start_new_game()
		GameState.load_from_dict(malformed)
		CORE.initialize_for_run(true)
		var before_retry: Dictionary = GameState.serialize().duplicate(true)
		var snapshot := CORE.seoul_cycle_snapshot(2)
		var candidates := CORE.terminal_target_candidates(
			2, "m2_advancement")
		var public_source := CORE.terminal_transition_receipt(route_id)
		var public_resolution := CORE.terminal_transition_resolution(route_id)
		var loaded_state: Dictionary = GameState.core_loop_v2_state
		var loaded_resolutions: Dictionary = loaded_state.get(
			"terminal_transition_resolutions", {})
		var retained_resolution: Dictionary = loaded_resolutions.get(
			route_id, {})
		var retried := CORE.initialize_seoul_cycle(2)
		_expect(_variant_equal_with_numeric_values(
			public_source, source_receipt) \
			and _variant_equal_with_numeric_values(
				retained_resolution, expected_resolution) \
			and public_resolution.is_empty() \
			and not bool(snapshot.get("active", true)) \
			and candidates.is_empty() \
			and not bool(retried.get("ok", true)) \
			and str(retried.get("error", "")) == "terminal_binding_conflict" \
			and GameState.serialize() == before_retry,
			"q0 live resolution survived %s terminal-authority erasure" \
				% mutation)


func _expect_terminal_active_target_mutation_rejected(
		malformed: Dictionary, route_id: String, label: String) -> void:
	GameState.start_new_game()
	GameState.load_from_dict(malformed)
	CORE.initialize_for_run(true)
	var before_retry: Dictionary = GameState.serialize().duplicate(true)
	var retried := CORE.initialize_seoul_cycle(2)
	_expect(not bool(CORE.seoul_cycle_snapshot(2).get("active", true)) \
		and CORE.terminal_target_candidates(
			2, "m2_advancement").is_empty() \
		and CORE.terminal_transition_resolution(route_id).is_empty() \
		and not bool(retried.get("ok", true)) \
		and str(retried.get("error", "")) == "terminal_binding_conflict" \
		and GameState.serialize() == before_retry,
		"%s escaped fail-closed target authority" % label)


func _check_terminal_target_identity_erasure_rejected(
		initialized_save: Dictionary, route_id: String,
		target_month: int, target_node: String) -> void:
	var malformed := initialized_save.duplicate(true)
	var state: Dictionary = malformed.get("core_loop_v2_state", {})
	var cycle: Dictionary = state.get("seoul_cycle", {})
	cycle.erase("terminal_binding_schema")
	cycle.erase("terminal_bound_node_ids")
	var nodes: Dictionary = cycle.get("nodes", {})
	for raw_node_id in nodes.keys():
		var node: Dictionary = nodes.get(raw_node_id, {})
		for field in [
			"binding_candidate_ids", "ordinary_candidate_ids",
			"eligible_terminal_route_ids", "terminal_route_bindings",
			"selected_trigger_candidate_id", "selected_terminal_route_id",
			"terminal_selection_origin", "terminal_result_ko",
			"terminal_result_en", "terminal_completion_effects",
		]:
			node.erase(field)
		nodes[raw_node_id] = node
	cycle["nodes"] = nodes
	state["seoul_cycle"] = cycle
	malformed["core_loop_v2_state"] = state
	GameState.start_new_game()
	GameState.load_from_dict(malformed)
	CORE.initialize_for_run(true)
	var before_retry: Dictionary = GameState.serialize().duplicate(true)
	var retried := CORE.initialize_seoul_cycle(target_month)
	_expect(not bool(CORE.seoul_cycle_snapshot(target_month).get(
		"active", true)) \
		and CORE.terminal_target_candidates(
			target_month, target_node).is_empty() \
		and not bool(retried.get("ok", true)) \
		and str(retried.get("error", "")) == "terminal_binding_conflict" \
		and CORE.terminal_transition_resolution(route_id).is_empty() \
		and GameState.serialize() == before_retry,
		"erased target identity downgraded a bound terminal cycle to ordinary")


func _check_terminal_target_three_surface_erasure_rejected(
		initialized_save: Dictionary, route_id: String,
		target_month: int, target_node: String) -> void:
	var malformed := initialized_save.duplicate(true)
	var state: Dictionary = malformed.get("core_loop_v2_state", {})
	var witness_key := "%d:%s" % [target_month, target_node]
	var root_witnesses: Dictionary = state.get(
		"terminal_target_binding_receipts", {})
	_expect(not (root_witnesses.get(witness_key, {}) as Dictionary).is_empty(),
		"three-surface erasure fixture lost its immutable root witness")
	if (root_witnesses.get(witness_key, {}) as Dictionary).is_empty():
		return
	var expected_root_witnesses: Dictionary = root_witnesses.duplicate(true)

	var cycle: Dictionary = state.get("seoul_cycle", {})
	cycle.erase("terminal_binding_schema")
	cycle.erase("terminal_bound_node_ids")
	var nodes: Dictionary = cycle.get("nodes", {})
	for raw_node_id in nodes.keys():
		var node: Dictionary = nodes.get(raw_node_id, {})
		for field in [
			"binding_candidate_ids", "ordinary_candidate_ids",
			"eligible_terminal_route_ids", "terminal_route_bindings",
			"selected_trigger_candidate_id", "selected_terminal_route_id",
			"terminal_selection_origin", "terminal_result_ko",
			"terminal_result_en", "terminal_completion_effects",
		]:
			node.erase(field)
		nodes[raw_node_id] = node
	cycle["nodes"] = nodes
	state["seoul_cycle"] = cycle

	var plans: Dictionary = state.get("plans", {})
	var plan: Dictionary = plans.get(str(target_month), {})
	plan.erase("terminal_binding_schema")
	plan.erase("terminal_bound_node_ids")
	plan.erase("terminal_binding_candidate_sets")
	plans[str(target_month)] = plan
	state["plans"] = plans
	malformed["core_loop_v2_state"] = state

	GameState.start_new_game()
	GameState.load_from_dict(malformed)
	CORE.initialize_for_run(true)
	var before_retry: Dictionary = GameState.serialize().duplicate(true)
	var retried := CORE.initialize_seoul_cycle(target_month)
	var retained_witnesses: Dictionary = GameState.core_loop_v2_state.get(
		"terminal_target_binding_receipts", {})
	_expect(not bool(CORE.seoul_cycle_snapshot(target_month).get(
		"active", true)) \
		and CORE.terminal_target_candidates(
			target_month, target_node).is_empty() \
		and not bool(retried.get("ok", true)) \
		and str(retried.get("error", "")) == "terminal_binding_conflict" \
		and retained_witnesses == expected_root_witnesses \
		and CORE.terminal_transition_resolution(route_id).is_empty() \
		and GameState.serialize() == before_retry,
		"root witness did not stop a three-surface terminal downgrade")


func _check_terminal_unallocated_target_full_erasure_rejected(
		initialized_save: Dictionary, route_id: String,
		source_receipt: Dictionary, target_month: int,
		target_node: String) -> void:
	var baseline_state: Dictionary = initialized_save.get(
		"core_loop_v2_state", {})
	var baseline_cycle: Dictionary = baseline_state.get("seoul_cycle", {})
	var baseline_allocations: Dictionary = baseline_cycle.get(
		"allocation_receipts", {})
	var baseline_witnesses: Dictionary = baseline_state.get(
		"terminal_target_binding_receipts", {})
	var target_month_witness_count := 0
	for raw_witness in baseline_witnesses.values():
		if raw_witness is Dictionary \
				and int((raw_witness as Dictionary).get(
					"target_month", 0)) == target_month:
			target_month_witness_count += 1
	_expect(not source_receipt.is_empty() \
		and _variant_equal_with_numeric_values(
			(baseline_state.get(
				"terminal_transition_receipts", {}) as Dictionary).get(
				route_id, {}), source_receipt) \
		and baseline_allocations.is_empty() \
		and target_month_witness_count > 0,
		"unallocated full-erasure fixture lacked source/no-allocation/witness authority")
	if source_receipt.is_empty() or target_month_witness_count == 0:
		return

	var malformed := initialized_save.duplicate(true)
	var state: Dictionary = malformed.get("core_loop_v2_state", {})
	var cycle: Dictionary = state.get("seoul_cycle", {})
	cycle.erase("terminal_binding_schema")
	cycle.erase("terminal_bound_node_ids")
	var nodes: Dictionary = cycle.get("nodes", {})
	for raw_node_id in nodes.keys():
		var node: Dictionary = nodes.get(raw_node_id, {})
		for field in [
			"binding_candidate_ids", "ordinary_candidate_ids",
			"eligible_terminal_route_ids", "terminal_route_bindings",
			"selected_trigger_candidate_id", "selected_terminal_route_id",
			"terminal_selection_origin", "terminal_result_ko",
			"terminal_result_en", "terminal_completion_effects",
		]:
			node.erase(field)
		nodes[raw_node_id] = node
	cycle["nodes"] = nodes
	state["seoul_cycle"] = cycle
	var plans: Dictionary = state.get("plans", {})
	var plan: Dictionary = plans.get(str(target_month), {})
	plan.erase("terminal_binding_schema")
	plan.erase("terminal_bound_node_ids")
	plan.erase("terminal_binding_candidate_sets")
	plans[str(target_month)] = plan
	state["plans"] = plans
	var witnesses: Dictionary = state.get(
		"terminal_target_binding_receipts", {})
	for raw_witness_key in witnesses.keys():
		var raw_witness: Variant = witnesses.get(raw_witness_key, {})
		if raw_witness is Dictionary \
				and int((raw_witness as Dictionary).get(
					"target_month", 0)) == target_month:
			witnesses.erase(raw_witness_key)
	state["terminal_target_binding_receipts"] = witnesses
	malformed["core_loop_v2_state"] = state
	_expect(_variant_equal_with_numeric_values(
		(state.get("terminal_transition_receipts", {}) as Dictionary).get(
			route_id, {}), source_receipt),
		"unallocated full-erasure attack changed its retained source receipt")

	GameState.start_new_game()
	GameState.load_from_dict(malformed)
	CORE.initialize_for_run(true)
	var before_retry: Dictionary = GameState.serialize().duplicate(true)
	var snapshot := CORE.seoul_cycle_snapshot(target_month)
	var candidates := CORE.terminal_target_candidates(target_month, target_node)
	var public_source := CORE.terminal_transition_receipt(route_id)
	var retried := CORE.initialize_seoul_cycle(target_month)
	_expect(_variant_equal_with_numeric_values(public_source, source_receipt) \
		and not bool(snapshot.get("active", true)) \
		and candidates.is_empty() \
		and CORE.terminal_transition_resolution(route_id).is_empty() \
		and not bool(retried.get("ok", true)) \
		and str(retried.get("error", "")) == "terminal_binding_conflict" \
		and GameState.serialize() == before_retry,
		"unallocated target erased every binding surface and downgraded to legacy")


func _check_terminal_target_witness_lifetime_rejected(
		initialized_save: Dictionary, route_id: String) -> void:
	for mutation in ["future", "past", "missing_current"]:
		var malformed := initialized_save.duplicate(true)
		var state: Dictionary = malformed.get("core_loop_v2_state", {})
		var witnesses: Dictionary = state.get(
			"terminal_target_binding_receipts", {})
		var current_key := "2:m2_advancement"
		var raw_current: Variant = witnesses.get(current_key, {})
		_expect(raw_current is Dictionary \
			and not (raw_current as Dictionary).is_empty(),
			"witness lifetime fixture lost its current-month authority")
		if not raw_current is Dictionary \
				or (raw_current as Dictionary).is_empty():
			return
		if mutation == "missing_current":
			witnesses.erase(current_key)
		else:
			var forged: Dictionary = (raw_current as Dictionary).duplicate(true)
			var forged_month := 3 if mutation == "future" else 1
			var forged_node := "m3_people" if mutation == "future" else "resume"
			forged["target_month"] = forged_month
			forged["target_node"] = forged_node
			witnesses["%d:%s" % [forged_month, forged_node]] = forged
		state["terminal_target_binding_receipts"] = witnesses
		malformed["core_loop_v2_state"] = state
		GameState.start_new_game()
		GameState.load_from_dict(malformed)
		CORE.initialize_for_run(true)
		var before_retry: Dictionary = GameState.serialize().duplicate(true)
		var retried := CORE.initialize_seoul_cycle(2)
		_expect(not bool(CORE.seoul_cycle_snapshot(2).get("active", true)) \
			and CORE.terminal_target_candidates(
				2, "m2_advancement").is_empty() \
			and not bool(retried.get("ok", true)) \
			and str(retried.get("error", "")) == "terminal_binding_conflict" \
			and CORE.terminal_transition_resolution(route_id).is_empty() \
			and GameState.serialize() == before_retry,
			"terminal target accepted a %s root witness set" % mutation)


func _check_order101_resume_expiry_source_receipt() -> void:
	var route_id := "m1_resume_expired_to_m2_advancement_rebuilt"
	_prepare_fresh_cycle_gate()
	var initialized := CORE.initialize_seoul_cycle(1)
	_expect(bool(initialized.get("ok", false)),
		"resume expiry source could not initialize Month One")
	if not bool(initialized.get("ok", false)):
		return
	for turn in range(1, 5):
		var snapshot := CORE.seoul_cycle_snapshot(1)
		var capacity_id := _unused_capacity(snapshot, 0, true)
		var committed := CORE.commit_seoul_cycle_allocation(
			capacity_id, "recovery", 1)
		if not bool(committed.get("ok", false)):
			_expect(false, "resume expiry Week %d recovery commit failed" % turn)
			return
		if turn == 3 and not _resolve_cycle_story_world(
				"hyunsu_first_meet", HYUNSU_EVENT, 0):
			return
		if turn == 4 and not _resolve_cycle_story_world(
				"first_temptation_boss", TEMPTATION_EVENT, 0):
			return
		if not bool(CORE.complete_seoul_cycle_turn(1).get("ok", false)):
			_expect(false, "resume expiry Week %d could not close" % turn)
			return
		if turn < 4:
			_advance_to_next_week()
	var summary := CORE.record_month_summary(1, {}, {})
	var receipt := CORE.terminal_transition_receipt(route_id)
	var proof: Dictionary = receipt.get("source_proof", {})
	var node: Dictionary = proof.get("node_state", {})
	var expiry: Dictionary = proof.get("expiry_receipt", {})
	var expiry_before: Dictionary = expiry.get("before", {})
	var expiry_after: Dictionary = expiry.get("after", {})
	_expect(not summary.is_empty() \
		and str(receipt.get("source_terminal", "")) == "expired" \
		and int(receipt.get("source_turn", 0)) == 3 \
		and str(receipt.get("proof_kind", "")) == "node_expiry" \
		and str(receipt.get("proof_id", "")) == "m1:resume" \
		and str(receipt.get("variant_id", "")) == "resume_rebuilt" \
		and int((receipt.get("completion_effects", {}) as Dictionary).get(
			"mental", 0)) == -3 \
		and str(node.get("id", "")) == "resume" \
		and str(node.get("status", "")) == "expired" \
		and int(node.get("expired_turn", 0)) == 3 \
		and int(node.get("progress", 0)) < int(node.get("threshold", 0)) \
		and str(expiry.get("node_id", "")) == "resume" \
		and str(expiry.get("status", "")) == "consumed" \
		and int(expiry.get("turn", 0)) == 3 \
		and int(expiry.get("week_index", 0)) == 3 \
		and str(expiry.get("consequence_id", "")) \
			== "m1_resume_clinic_window_closed" \
		and int((expiry.get("effects", {}) as Dictionary).get(
			"mental", 0)) == -1 \
		and int(expiry_after.get("mental", 0)) \
			== int(expiry_before.get("mental", 0)) - 1 \
		and (summary.get("expired_nodes", []) as Array).has("resume") \
		and (summary.get("cycle_completed_turns", []) as Array).has(3),
		"resume expiry route did not derive from the exact W3 node expiry")
	var frozen := receipt.duplicate(true)
	var frozen_state: Dictionary = GameState.serialize().duplicate(true)
	_expect(CORE.record_month_summary(1, {}, {}) == summary \
		and CORE.terminal_transition_receipt(route_id) == frozen \
		and GameState.serialize() == frozen_state,
		"resume expiry receipt changed on repeated month close")
	var saved: Dictionary = GameState.serialize().duplicate(true)
	for reload_index in range(2):
		GameState.start_new_game()
		GameState.load_from_dict(saved.duplicate(true))
		CORE.initialize_for_run(true)
		_expect(CORE.terminal_transition_receipt(route_id) == frozen,
			"resume expiry receipt drifted on reload %d" % [reload_index + 1])
		saved = GameState.serialize().duplicate(true)
	for field_path in [
		["source_proof", "node_state", "expired_turn"],
		["source_proof", "expiry_receipt", "node_id"],
		["source_proof", "expiry_receipt", "status"],
		["source_proof", "expiry_receipt", "week_index"],
		["source_proof", "expiry_receipt", "consequence_id"],
		["source_proof", "expiry_receipt", "effects", "mental"],
	]:
		var malformed := saved.duplicate(true)
		var state: Dictionary = malformed.get("core_loop_v2_state", {})
		var receipts: Dictionary = state.get("terminal_transition_receipts", {})
		var bad := frozen.duplicate(true)
		_set_nested_terminal_mutation(bad, field_path, 0)
		receipts[route_id] = bad
		state["terminal_transition_receipts"] = receipts
		malformed["core_loop_v2_state"] = state
		GameState.start_new_game()
		GameState.load_from_dict(malformed)
		CORE.initialize_for_run(true)
		_expect(CORE.terminal_transition_receipt(route_id).is_empty(),
			"resume expiry receipt accepted mutation %s" % str(field_path))


func _check_order101_father_terminal_source_receipts() -> void:
	var route_ids: Array[String] = [
		"m1_father_completed_wellbeing_to_m3_quiet_call",
		"m1_father_completed_future_reassured_to_m3_quiet_call",
		"m1_father_completed_call_ended_quickly_to_m3_quiet_call",
	]
	var memories: Array[String] = [
		"father_wellbeing_returned", "father_future_reassured",
		"father_call_ended_quickly",
	]
	for choice_index in range(3):
		var source := _produce_fresh_father_completed_month(choice_index)
		if source.is_empty():
			continue
		var summary: Dictionary = source.get("summary", {})
		var source_turn := int(source.get("source_turn", 0))
		var route_id := route_ids[choice_index]
		var receipt := CORE.terminal_transition_receipt(route_id)
		var proof: Dictionary = receipt.get("source_proof", {})
		var relationship: Dictionary = proof.get(
			"relationship_receipt", {})
		var expected_key := "father_first_call:arc_father_01_call:%d:%d" \
			% [choice_index, source_turn]
		_expect(not summary.is_empty() \
			and str(receipt.get("source_terminal", "")) == "completed" \
			and int(receipt.get("source_turn", 0)) == source_turn \
			and str(receipt.get("proof_kind", "")) \
				== "relationship_choice" \
			and str(receipt.get("proof_id", "")) \
				== "father_first_call:arc_father_01_call:%d" % choice_index \
			and str(receipt.get("target_node", "")) == "m3_people" \
			and str(receipt.get("target_bundle", "")) \
				== "father_quiet_call" \
			and str(receipt.get("variant_id", "")) == memories[choice_index] \
			and str(proof.get("relationship_receipt_key", "")) \
				== "relationship_choice_receipts.%s" % expected_key \
			and str(proof.get("relationship_memory_key", "")) \
				== "relationship_memories[%s]" % expected_key \
			and str(relationship.get("receipt_key", "")) == expected_key \
			and str(relationship.get("bundle_id", "")) == "father_first_call" \
			and str(relationship.get("event_id", "")) == FATHER_EVENT \
			and int(relationship.get("choice_index", -1)) == choice_index \
			and int(relationship.get("turn", 0)) == source_turn \
			and str(relationship.get("character", "")) == "father" \
			and str(relationship.get("initiative", "")) == "player" \
			and str(relationship.get("memory", "")) == memories[choice_index] \
			and CORE.has_relationship_memory("father", memories[choice_index]),
			("father choice %d terminal proof did not bind its exact fresh " \
				+ "player receipt/memory") % choice_index)
		for sibling_index in range(3):
			if sibling_index == choice_index:
				continue
			_expect(not CORE.has_relationship_memory(
				"father", memories[sibling_index]) \
				and CORE.terminal_transition_receipt(
					route_ids[sibling_index]).is_empty(),
				"father choice %d leaked sibling %d" % [
					choice_index, sibling_index])
		var frozen := receipt.duplicate(true)
		var saved: Dictionary = GameState.serialize().duplicate(true)
		for reload_index in range(2):
			GameState.start_new_game()
			GameState.load_from_dict(saved.duplicate(true))
			CORE.initialize_for_run(true)
			_expect(CORE.terminal_transition_receipt(route_id) == frozen,
				"father choice %d receipt drifted on reload %d" % [
					choice_index, reload_index + 1])
			saved = GameState.serialize().duplicate(true)
		_check_father_terminal_mutations_rejected(
			saved, route_id, frozen, choice_index, source_turn)
		if choice_index == 0:
			_check_father_terminal_no_offer_summary_durability(
				saved, route_id, frozen, source_turn)
	_check_order101_father_expiry_source_receipt()


func _check_father_terminal_mutations_rejected(
		saved: Dictionary, route_id: String, frozen: Dictionary,
		choice_index: int, source_turn: int) -> void:
	for field_path in [
		["source_proof", "relationship_receipt", "choice_index"],
		["source_proof", "relationship_receipt", "memory"],
		["source_proof", "trigger_receipt", "bundle_id"],
	]:
		var malformed := saved.duplicate(true)
		var state: Dictionary = malformed.get("core_loop_v2_state", {})
		var receipts: Dictionary = state.get("terminal_transition_receipts", {})
		var bad := frozen.duplicate(true)
		_set_nested_terminal_mutation(bad, field_path, choice_index)
		receipts[route_id] = bad
		state["terminal_transition_receipts"] = receipts
		malformed["core_loop_v2_state"] = state
		GameState.start_new_game()
		GameState.load_from_dict(malformed)
		CORE.initialize_for_run(true)
		_expect(CORE.terminal_transition_receipt(route_id).is_empty(),
			"father terminal receipt accepted mutation %s" % str(field_path))
	for mutation in [
		"delete_receipt", "delete_memory", "selected_memory_mutation",
		"sibling_receipt_coexist",
	]:
		var malformed := saved.duplicate(true)
		var state: Dictionary = malformed.get("core_loop_v2_state", {})
		var expected_key := "father_first_call:arc_father_01_call:%d:%d" \
			% [choice_index, source_turn]
		if mutation == "delete_receipt":
			(state.get("relationship_choice_receipts", {}) as Dictionary).erase(
				expected_key)
		elif mutation == "delete_memory":
			var memories: Array = state.get("relationship_memories", [])
			for index in range(memories.size() - 1, -1, -1):
				if memories[index] is Dictionary \
						and str((memories[index] as Dictionary).get(
							"receipt_key", "")) == expected_key:
					memories.remove_at(index)
			state["relationship_memories"] = memories
		elif mutation == "selected_memory_mutation":
			var all_receipts: Dictionary = state.get(
				"relationship_choice_receipts", {})
			var relationship: Dictionary = all_receipts.get(expected_key, {})
			relationship["memory"] = "father_sibling_injection"
			all_receipts[expected_key] = relationship
			state["relationship_choice_receipts"] = all_receipts
		else:
			var sibling_index := (choice_index + 1) % 3
			var sibling_memories: Array[String] = [
				"father_wellbeing_returned", "father_future_reassured",
				"father_call_ended_quickly",
			]
			var sibling_key := (
				"father_first_call:arc_father_01_call:%d:%d" \
				% [sibling_index, source_turn])
			var all_receipts: Dictionary = state.get(
				"relationship_choice_receipts", {})
			var sibling_receipt: Dictionary = (
				all_receipts.get(expected_key, {}) as Dictionary).duplicate(true)
			sibling_receipt["receipt_key"] = sibling_key
			sibling_receipt["choice_index"] = sibling_index
			sibling_receipt["memory"] = sibling_memories[sibling_index]
			all_receipts[sibling_key] = sibling_receipt
			state["relationship_choice_receipts"] = all_receipts
			for ledger_key in ["relationship_history", "relationship_memories"]:
				var ledger: Array = state.get(ledger_key, [])
				ledger.append(sibling_receipt.duplicate(true))
				state[ledger_key] = ledger
		malformed["core_loop_v2_state"] = state
		GameState.start_new_game()
		GameState.load_from_dict(malformed)
		CORE.initialize_for_run(true)
		_expect(CORE.terminal_transition_receipt(route_id).is_empty(),
			"father terminal receipt ignored underlying %s" % mutation)


func _check_order101_father_expiry_source_receipt() -> void:
	var route_id := "m1_father_expired_to_m2_people_open"
	if not _prepare_fresh_w1_after_interview():
		return
	if not bool(CORE.complete_seoul_cycle_turn(1).get("ok", false)):
		_expect(false, "father expiry source could not close typed W1")
		return
	for turn in range(2, 5):
		_advance_to_next_week()
		var snapshot := CORE.seoul_cycle_snapshot(1)
		var capacity_id := _unused_capacity(snapshot, 0, true)
		var committed := CORE.commit_seoul_cycle_allocation(
			capacity_id, "recovery", 1)
		if not bool(committed.get("ok", false)):
			_expect(false, "father expiry Week %d recovery commit failed" % turn)
			return
		if turn == 3 and not _resolve_cycle_story_world(
				"hyunsu_first_meet", HYUNSU_EVENT, 0):
			return
		if turn == 4 and not _resolve_cycle_story_world(
				"first_temptation_boss", TEMPTATION_EVENT, 0):
			return
		if not bool(CORE.complete_seoul_cycle_turn(1).get("ok", false)):
			_expect(false, "father expiry Week %d could not close" % turn)
			return
	var summary := CORE.record_month_summary(1, {}, {})
	var receipt := CORE.terminal_transition_receipt(route_id)
	var proof: Dictionary = receipt.get("source_proof", {})
	var node: Dictionary = proof.get("node_state", {})
	var expiry: Dictionary = proof.get("expiry_receipt", {})
	_expect(not summary.is_empty() \
		and str(receipt.get("source_terminal", "")) == "expired" \
		and int(receipt.get("source_turn", 0)) == 3 \
		and str(receipt.get("proof_kind", "")) == "node_expiry" \
		and str(receipt.get("proof_id", "")) == "m1:father" \
		and int(receipt.get("target_month", 0)) == 2 \
		and str(receipt.get("target_node", "")) == "m2_people" \
		and str(receipt.get("target_bundle", "")).is_empty() \
		and str(receipt.get("variant_id", "")) == "father_call_put_off" \
		and str(node.get("status", "")) == "expired" \
		and int(node.get("expired_turn", 0)) == 3 \
		and int(node.get("progress", 0)) < int(node.get("threshold", 0)) \
		and str(expiry.get("node_id", "")) == "father" \
		and int(expiry.get("turn", 0)) == 3 \
		and int(expiry.get("week_index", 0)) == 3 \
		and str(expiry.get("consequence_id", "")) \
			== "m1_father_call_put_off" \
		and int((expiry.get("effects", {}) as Dictionary).get(
			"mental", 0)) == -1 \
		and (summary.get("expired_nodes", []) as Array).has("father") \
		and CORE.terminal_routes_for_target(2, "m2_people").size() == 1,
		"father expiry route did not bind the exact W3 expiry topology")
	var father_expiry_saved: Dictionary = GameState.serialize().duplicate(true)
	_check_terminal_source_json_target_roundtrip(
		father_expiry_saved, route_id, receipt, 2, "m2_people")
	_check_terminal_expiry_forbidden_story_rejected(
		father_expiry_saved, route_id, "father_first_call",
		FATHER_EVENT, 0, 2)
	_check_order101_father_expiry_target_initialization(
		father_expiry_saved, receipt)


func _check_order101_father_expiry_target_initialization(
		source_saved: Dictionary, source_receipt: Dictionary) -> void:
	var route_id := "m1_father_expired_to_m2_people_open"
	var resume_route := "m1_resume_completed_q2_to_m2_advancement_polished"
	var terminal_id := "terminal:%s" % route_id
	var resume_terminal_id := "terminal:%s" % resume_route
	GameState.start_new_game()
	GameState.load_from_dict(source_saved.duplicate(true))
	CORE.initialize_for_run(true)
	_advance_to_next_week()
	var initialized := CORE.initialize_seoul_cycle(2)
	var snapshot := CORE.seoul_cycle_snapshot(2)
	var node: Dictionary = (snapshot.get("nodes", {}) as Dictionary).get(
		"m2_people", {})
	var candidates := CORE.terminal_target_candidates(2, "m2_people")
	var candidate_ids := _m2_candidate_ids(candidates)
	var target_state: Dictionary = GameState.core_loop_v2_state
	var target_cycle: Dictionary = target_state.get("seoul_cycle", {})
	var target_plan: Dictionary = (
		target_state.get("plans", {}) as Dictionary).get("2", {})
	var expected_ordinary := [
		"cafe_world_glimpse", "hyunsu_player_reachout",
	]
	var expected_candidate_set := {
		"ordinary_candidate_ids": expected_ordinary,
		"binding_candidate_ids": candidate_ids,
	}
	var expected_resume_candidate_set := {
		"ordinary_candidate_ids": [],
		"binding_candidate_ids": [resume_terminal_id],
	}
	var target_candidate_sets: Dictionary = target_plan.get(
		"terminal_binding_candidate_sets", {})
	var target_witnesses: Dictionary = target_state.get(
		"terminal_target_binding_receipts", {})
	var people_witness: Dictionary = target_witnesses.get("2:m2_people", {})
	var people_eligibility: Dictionary = people_witness.get(
		"ordinary_eligibility", {})
	var terminal_candidate: Dictionary = {}
	for raw_candidate in candidates:
		if raw_candidate is Dictionary \
				and str((raw_candidate as Dictionary).get("id", "")) \
					== terminal_id:
			terminal_candidate = raw_candidate as Dictionary
			break
	_expect(bool(initialized.get("ok", false)) \
		and not bool(initialized.get("resumed", true)) \
		and bool(snapshot.get("active", false)) \
		and candidate_ids == [
			"cafe_world_glimpse", "hyunsu_player_reachout", terminal_id,
		] \
		and _sorted_strings(node.get("binding_candidate_ids", [])) \
			== candidate_ids \
		and _sorted_strings(node.get("eligible_trigger_bundle_ids", [])) \
			== expected_ordinary \
		and node.get("ordinary_candidate_ids", []) == expected_ordinary \
		and str(node.get("trigger_selection_origin", "")) \
			== "unselected_player" \
		and not bool(node.get("trigger_selection_migrated_legacy", true)) \
		and str(node.get("selected_trigger_candidate_id", "")).is_empty() \
		and str(node.get("selected_trigger_bundle_id", "")).is_empty() \
		and str(node.get("selected_terminal_route_id", "")).is_empty() \
		and str(node.get("terminal_selection_origin", "")) \
			== "unselected_union" \
		and str(node.get("trigger_bundle", "")).is_empty() \
		and str(node.get("summary_bundle", "")).is_empty() \
		and str(node.get("status", "")) == "open" \
		and str(terminal_candidate.get("kind", "")) == "terminal" \
		and str(terminal_candidate.get("bundle_id", "")).is_empty() \
		and str(terminal_candidate.get("route_id", "")) == route_id \
		and str(terminal_candidate.get("variant_id", "")) \
			== "father_call_put_off" \
		and int(target_cycle.get("terminal_binding_schema", 0)) \
			== CORE.TERMINAL_TARGET_BINDING_SCHEMA \
		and target_cycle.get("terminal_bound_node_ids", []) \
			== ["m2_advancement", "m2_people"] \
		and int(target_plan.get("terminal_binding_schema", 0)) \
			== CORE.TERMINAL_TARGET_BINDING_SCHEMA \
		and target_plan.get("terminal_bound_node_ids", []) \
			== ["m2_advancement", "m2_people"] \
		and target_candidate_sets.get(
			"m2_people", {}) == expected_candidate_set \
		and target_candidate_sets.get(
			"m2_advancement", {}) == expected_resume_candidate_set \
		and _sorted_strings(people_witness.keys()) == [
			"binding_candidate_ids", "ordinary_candidate_ids",
			"ordinary_eligibility", "schema", "target_month", "target_node",
			"terminal_route_bindings",
		] \
		and people_eligibility == {
			"schema": CORE.TERMINAL_TARGET_BINDING_SCHEMA,
			"cut_turn": 5,
			"eligible_authored_candidate_ids": expected_ordinary,
		} \
		and CORE.terminal_transition_receipt(route_id) == source_receipt \
		and not CORE.terminal_transition_receipt(resume_route).is_empty() \
		and CORE.terminal_transition_resolution(route_id).is_empty() \
		and (target_state.get(
			"terminal_transition_resolutions", {}) as Dictionary).is_empty(),
		"father expiry did not expose its exact mixed M2 people candidate union")
	var saved: Dictionary = GameState.serialize().duplicate(true)
	for reload_index in range(2):
		GameState.start_new_game()
		GameState.load_from_dict(saved.duplicate(true))
		CORE.initialize_for_run(true)
		var reloaded := CORE.seoul_cycle_snapshot(2)
		var reloaded_node: Dictionary = (
			reloaded.get("nodes", {}) as Dictionary).get("m2_people", {})
		_expect(bool(reloaded.get("active", false)) \
			and _m2_candidate_ids(CORE.terminal_target_candidates(
				2, "m2_people")) == candidate_ids \
			and _sorted_strings(reloaded_node.get(
				"eligible_trigger_bundle_ids", [])) \
				== ["cafe_world_glimpse", "hyunsu_player_reachout"] \
			and str(reloaded_node.get("terminal_selection_origin", "")) \
				== "unselected_union" \
			and CORE.terminal_transition_receipt(route_id) == source_receipt,
			"father expiry mixed target drifted on reload %d" \
				% [reload_index + 1])
		saved = GameState.serialize().duplicate(true)
	_check_terminal_m2_unselected_union_expiry(
		saved, route_id, terminal_id, resume_route, resume_terminal_id)
	_check_terminal_m2_union_ordinary_selection(
		saved, source_receipt, route_id, terminal_id, candidate_ids)
	_check_terminal_m2_coupled_candidate_shrink_rejected(
		saved, route_id, terminal_id)


func _check_terminal_m2_union_ordinary_selection(
		initialized_save: Dictionary, source_receipt: Dictionary,
		route_id: String, terminal_id: String,
		expected_candidate_ids: Array[String]) -> void:
	GameState.start_new_game()
	GameState.load_from_dict(initialized_save.duplicate(true))
	CORE.initialize_for_run(true)
	var snapshot := CORE.seoul_cycle_snapshot(2)
	var node: Dictionary = (
		snapshot.get("nodes", {}) as Dictionary).get("m2_people", {})
	var binding: Dictionary = (
		node.get("terminal_route_bindings", {}) as Dictionary).get(route_id, {})
	var capacity_id := _unused_capacity(snapshot, 2, true)
	var before_missing: Dictionary = GameState.serialize().duplicate(true)
	var missing := CORE.preview_seoul_cycle_allocation(
		capacity_id, "m2_people", 2)
	_expect(not bool(missing.get("ok", true)) \
		and str(missing.get("error", "")) == "trigger_selection_required" \
		and bool(missing.get("trigger_selection_required", false)) \
		and bool(missing.get("terminal_route_required", false)) \
		and bool(missing.get("terminal_selection_required", false)) \
		and _m2_candidate_ids(missing.get("trigger_candidates", [])) \
			== expected_candidate_ids \
		and str(missing.get(
			"selected_trigger_candidate_id", "")).is_empty() \
		and GameState.serialize() == before_missing \
		and CORE.terminal_transition_resolution(route_id).is_empty() \
		and (GameState.core_loop_v2_state.get(
			"terminal_transition_resolutions", {}) as Dictionary).is_empty(),
		"mixed M2 people union did not require one explicit unified candidate")
	var ordinary_id := "hyunsu_player_reachout"
	var before_preview: Dictionary = GameState.serialize().duplicate(true)
	var preview := CORE.preview_seoul_cycle_allocation(
		capacity_id, "m2_people", 2, ordinary_id)
	_expect(bool(preview.get("ok", false)) \
		and bool(preview.get("completed_now", false)) \
		and bool(preview.get("terminal_route_required", false)) \
		and not bool(preview.get("terminal_selection_required", true)) \
		and bool(preview.get("terminal_selection_new", false)) \
		and str(preview.get("selected_trigger_candidate_id", "")) \
			== ordinary_id \
		and str(preview.get("selected_trigger_bundle_id", "")) \
			== ordinary_id \
		and str(preview.get("selected_terminal_route_id", "")).is_empty() \
		and str(preview.get("terminal_variant_id", "")).is_empty() \
		and (preview.get("terminal_target_binding", {}) as Dictionary).is_empty() \
		and (preview.get("terminal_completion_effects", {}) as Dictionary).is_empty() \
		and str(preview.get("trigger_bundle", "")) == ordinary_id \
		and _m2_candidate_ids(preview.get("trigger_candidates", [])) \
			== expected_candidate_ids \
		and GameState.serialize() == before_preview,
		"raw ordinary candidate did not preview through the mixed terminal union")
	if not bool(preview.get("ok", false)):
		return
	var mental_before := int(GameState.mental)
	var committed := CORE.commit_seoul_cycle_allocation(
		capacity_id, "m2_people", 2, ordinary_id)
	var receipt: Dictionary = committed.get("receipt", {})
	var weekly: Dictionary = receipt.get("weekly_commitment", {})
	var details: Dictionary = weekly.get("details", {})
	var pending: Dictionary = committed.get("pending_trigger", {})
	var committed_node: Dictionary = (
		(CORE.seoul_cycle_snapshot(2).get("nodes", {}) as Dictionary).get(
			"m2_people", {}))
	var resolution := CORE.terminal_transition_resolution(route_id)
	var expected_resolution := {
		"schema": CORE.TERMINAL_TARGET_BINDING_SCHEMA,
		"route_id": route_id,
		"resolution": "forgone",
		"binding": binding.duplicate(true),
		"target_month": 2,
		"target_node": "m2_people",
		"target_turn": 5,
		"allocation_receipt_id": "seoul_cycle_m2_w1",
		"allocation_receipt_key": "seoul_cycle.allocation_receipts.5",
		"selected_candidate_id": ordinary_id,
		"selected_terminal_route_id": "",
		"variant_id": "father_call_put_off",
		"effect_applied": false,
		"result_variant": "",
	}
	_expect(bool(committed.get("ok", false)) \
		and bool(committed.get("completed_now", false)) \
		and str(committed_node.get(
			"selected_trigger_candidate_id", "")) == ordinary_id \
		and str(committed_node.get(
			"selected_trigger_bundle_id", "")) == ordinary_id \
		and str(committed_node.get(
			"selected_terminal_route_id", "")).is_empty() \
		and str(committed_node.get("terminal_selection_origin", "")) \
			== "terminal_union_player" \
		and str(receipt.get("selected_trigger_candidate_id", "")) == ordinary_id \
		and str(receipt.get("selected_trigger_bundle_id", "")) == ordinary_id \
		and str(receipt.get("selected_terminal_route_id", "")).is_empty() \
		and str(receipt.get("terminal_variant_id", "")).is_empty() \
		and (receipt.get("terminal_target_binding", {}) as Dictionary).is_empty() \
		and str(details.get("selected_trigger_candidate_id", "")) == ordinary_id \
		and str(details.get("selected_trigger_bundle_id", "")) == ordinary_id \
		and str(details.get("selected_terminal_route_id", "")).is_empty() \
		and str(details.get("terminal_variant_id", "")).is_empty() \
		and (details.get("terminal_target_binding", {}) as Dictionary).is_empty() \
		and str(weekly.get("choice_id", "")) == "contact" \
		and str(weekly.get("axis", "")) == "human" \
		and str(weekly.get("person_id", "")) == "hyunsu" \
		and str(pending.get("bundle_id", "")) == ordinary_id \
		and str(pending.get("selected_trigger_candidate_id", "")) == ordinary_id \
		and str(pending.get("selected_trigger_bundle_id", "")) == ordinary_id \
		and str(pending.get("selected_terminal_route_id", "")).is_empty() \
		and str(pending.get("terminal_variant_id", "")).is_empty() \
		and (pending.get("terminal_target_binding", {}) as Dictionary).is_empty() \
		and _variant_equal_with_numeric_values(resolution, expected_resolution) \
		and CORE.terminal_transition_receipt(route_id) == source_receipt \
		and int(GameState.mental) == mental_before,
		"ordinary union selection did not propagate exactly or forgo the terminal route")
	if not bool(committed.get("ok", false)):
		return
	var committed_save: Dictionary = GameState.serialize().duplicate(true)
	var wrong_branch := CORE.commit_seoul_cycle_allocation(
		capacity_id, "m2_people", 2, terminal_id)
	_expect(not bool(wrong_branch.get("ok", true)) \
		and str(wrong_branch.get("error", "")) \
			== "terminal_branch_change_rejected" \
		and GameState.serialize() == committed_save \
		and _variant_equal_with_numeric_values(
			CORE.terminal_transition_resolution(route_id), expected_resolution),
		"mixed union allowed a stale callback to replace the durable ordinary choice")
	_check_terminal_forgone_historical_resolution(
		committed_save, source_receipt, route_id, expected_resolution)


func _check_terminal_m2_unselected_union_expiry(
		initialized_save: Dictionary, route_id: String,
		terminal_id: String, resume_route: String,
		resume_terminal_id: String) -> void:
	GameState.start_new_game()
	GameState.load_from_dict(initialized_save.duplicate(true))
	CORE.initialize_for_run(true)
	var initial_cycle := CORE.seoul_cycle_snapshot(2)
	var people_node: Dictionary = (
		initial_cycle.get("nodes", {}) as Dictionary).get("m2_people", {})
	var advancement_node: Dictionary = (
		initial_cycle.get("nodes", {}) as Dictionary).get(
			"m2_advancement", {})
	var people_binding: Dictionary = (
		people_node.get("terminal_route_bindings", {}) as Dictionary).get(
			route_id, {})
	var resume_binding: Dictionary = (
		advancement_node.get("terminal_route_bindings", {}) as Dictionary).get(
			resume_route, {})
	_expect(not people_binding.is_empty() and not resume_binding.is_empty() \
		and str(people_node.get(
			"selected_trigger_candidate_id", "")).is_empty() \
		and str(advancement_node.get(
			"selected_trigger_candidate_id", "")) == resume_terminal_id,
		"unselected-union expiry fixture lacked exact mixed/auto bindings")
	if people_binding.is_empty() or resume_binding.is_empty():
		return
	for turn in range(5, 9):
		if not _commit_m2_terminal_filler():
			return
		if turn == 5 and not _resolve_cycle_story_world(
				"m2_mirae_result_message", "v2_mirae_result_message", 0):
			return
		if turn == 8 and not _resolve_cycle_story_world(
				"temptation_consequence", "arc_temptation_clean", 0):
			return
		if not bool(CORE.complete_seoul_cycle_turn(2).get("ok", false)):
			_expect(false,
				"unselected-union expiry fixture could not close W%d" % turn)
			return
		if turn < 8:
			_advance_to_next_week()
	var closed_cycle := CORE.seoul_cycle_snapshot(2)
	var closed_nodes: Dictionary = closed_cycle.get("nodes", {})
	var closed_people: Dictionary = closed_nodes.get("m2_people", {})
	var closed_advancement: Dictionary = closed_nodes.get(
		"m2_advancement", {})
	var allocations: Dictionary = closed_cycle.get("allocation_receipts", {})
	var w6_closing: Dictionary = allocations.get("6", {})
	var w7_closing: Dictionary = allocations.get("7", {})
	var expected_resume := _terminal_expected_expired_resolution(
		resume_route, resume_binding, "m2_advancement", 6,
		resume_terminal_id, resume_route)
	var expected_people := _terminal_expected_expired_resolution(
		route_id, people_binding, "m2_people", 7, "", "")
	var root_resolutions: Dictionary = GameState.core_loop_v2_state.get(
		"terminal_transition_resolutions", {})
	_expect(str(closed_advancement.get("status", "")) == "expired" \
		and int(closed_advancement.get("expired_turn", 0)) == 6 \
		and str(closed_people.get("status", "")) == "expired" \
		and int(closed_people.get("expired_turn", 0)) == 7 \
		and str(closed_people.get(
			"selected_trigger_candidate_id", "")).is_empty() \
		and str(closed_people.get(
			"selected_terminal_route_id", "")).is_empty() \
		and (w6_closing.get("expired_nodes", []) as Array).count(
			"m2_advancement") == 1 \
		and (w7_closing.get("expired_nodes", []) as Array).count(
			"m2_people") == 1 \
		and root_resolutions.size() == 2 \
		and _variant_equal_with_numeric_values(
			root_resolutions.get(resume_route, {}), expected_resume) \
		and _variant_equal_with_numeric_values(
			root_resolutions.get(route_id, {}), expected_people),
		"mixed M2 close did not resolve auto and unselected terminals exactly once")
	var closed_save: Dictionary = GameState.serialize().duplicate(true)
	_check_terminal_incomplete_cycle_summary_not_recorded(closed_save, 2)
	_check_terminal_preinstalled_summary_blocks_boundary(closed_save, 2)
	_check_terminal_reserved_summary_extra_rejected(closed_save, 2)
	GameState.start_new_game()
	GameState.load_from_dict(closed_save.duplicate(true))
	CORE.initialize_for_run(true)
	var summary := CORE.record_month_summary(2, {}, {})
	var summary_resolutions: Dictionary = summary.get(
		"terminal_transition_resolutions", {})
	_expect(summary_resolutions.size() == 2 \
		and _variant_equal_with_numeric_values(
			summary_resolutions.get(resume_route, {}), expected_resume) \
		and _variant_equal_with_numeric_values(
			summary_resolutions.get(route_id, {}), expected_people),
		"mixed M2 terminal expiries were not frozen into exact summary cardinality")
	var frozen: Dictionary = GameState.serialize().duplicate(true)
	var main_game: Node = MAIN_GAME_SCRIPT.new()
	main_game.set_meta("_qa_core_loop_v2_autosave_result", false)
	_expect(not bool(main_game.call("_core_loop_v2_autosave_durable_state")) \
		and not bool(main_game.call("_core_loop_v2_autosave_durable_state")) \
		and GameState.serialize() == frozen \
		and (GameState.core_loop_v2_state.get(
			"terminal_transition_resolutions", {}) as Dictionary).size() == 2,
		"failed expiry-summary autosave retry changed resolution cardinality")
	main_game.set_meta("_qa_core_loop_v2_autosave_result", true)
	_expect(bool(main_game.call("_core_loop_v2_autosave_durable_state")) \
		and GameState.serialize() == frozen,
		"successful expiry-summary autosave retry changed frozen gameplay")
	main_game.free()
	_advance_to_next_week()
	var month_three := CORE.initialize_seoul_cycle(3)
	var historical_save: Dictionary = GameState.serialize().duplicate(true)
	_expect(bool(month_three.get("ok", false)) \
		and _variant_equal_with_numeric_values(
			CORE.terminal_transition_resolution(resume_route), expected_resume) \
		and _variant_equal_with_numeric_values(
			CORE.terminal_transition_resolution(route_id), expected_people),
		"mixed expired resolutions did not survive target-month replacement")
	for reload_index in range(2):
		GameState.start_new_game()
		GameState.load_from_dict(historical_save.duplicate(true))
		CORE.initialize_for_run(true)
		_expect(_variant_equal_with_numeric_values(
			CORE.terminal_transition_resolution(resume_route), expected_resume) \
			and _variant_equal_with_numeric_values(
				CORE.terminal_transition_resolution(route_id), expected_people),
			"mixed historical expiries drifted on reload %d" \
				% [reload_index + 1])
		historical_save = GameState.serialize().duplicate(true)
	_check_terminal_unselected_expiry_selection_forgery_rejected(
		historical_save, route_id, terminal_id, expected_people)
	_check_terminal_historical_resolution_mutations(
		historical_save, 2, route_id, expected_people)


func _check_terminal_incomplete_cycle_summary_not_recorded(
		closed_save: Dictionary, month_index: int) -> void:
	GameState.start_new_game()
	GameState.load_from_dict(closed_save.duplicate(true))
	CORE.initialize_for_run(true)
	var state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	var summaries: Dictionary = state.get("month_summaries", {})
	var cycle: Dictionary = state.get("seoul_cycle", {})
	var allocations: Dictionary = cycle.get("allocation_receipts", {})
	var closing_turn := month_index * 4
	var removed: Dictionary = allocations.get(str(closing_turn), {})
	_expect(not removed.is_empty() \
		and (cycle.get("completed_turns", []) as Array).has(closing_turn) \
		and not summaries.has(str(month_index)),
		"incomplete-summary fixture lacked its closed unsummarized cycle")
	if removed.is_empty() or summaries.has(str(month_index)):
		return
	allocations.erase(str(closing_turn))
	cycle["allocation_receipts"] = allocations
	state["seoul_cycle"] = cycle
	GameState.core_loop_v2_state = state
	var malformed_is_rejected := CORE.normalize_seoul_cycle_state(
		cycle, state).is_empty()
	var before_record: Dictionary = GameState.serialize().duplicate(true)
	var recorded := CORE.record_month_summary(month_index, {}, {})
	var after_state: Dictionary = GameState.core_loop_v2_state
	var after_summaries: Dictionary = after_state.get("month_summaries", {})
	_expect(malformed_is_rejected \
		and recorded.is_empty() \
		and not after_summaries.has(str(month_index)) \
		and GameState.serialize() == before_record,
		"record_month_summary persisted an incomplete or unnormalizable Seoul cycle")
	_check_terminal_incomplete_main_boundary_is_atomic(
		before_record, month_index)


func _check_terminal_incomplete_main_boundary_is_atomic(
		malformed_save: Dictionary, month_index: int) -> void:
	GameState.start_new_game()
	GameState.load_from_dict(malformed_save.duplicate(true))
	CORE.initialize_for_run(true)
	var main_game: Node = MAIN_GAME_SCRIPT.new()
	main_game.set_meta("_screenshot_qa_static_surface", true)
	main_game.set_meta("_qa_core_loop_v2_autosave_result", true)
	var original_pending_events: Array = EventManager.pending_events.duplicate(true)
	EventManager.pending_events = original_pending_events.duplicate(true)
	EventManager.pending_events.append({
		"id": "order101_incomplete_month_boundary_sentinel",
		"month": month_index,
	})
	var boundary_pending_events: Array = EventManager.pending_events.duplicate(true)
	var title_before: Dictionary = _order101_title_publication_snapshot()
	var before_boundary: Dictionary = GameState.serialize().duplicate(true)
	var before_money := float(GameState.money)
	var before_health := int(GameState.health)
	var before_mental := int(GameState.mental)
	var before_declines: Array = GameState.core_loop_v2_state.get(
		"decline_receipts", {}).duplicate(true)
	var can_record := CORE.can_record_month_summary(month_index)
	var print_errors_before := Engine.print_error_messages
	Engine.print_error_messages = false
	main_game.call("_core_loop_v2_advance_completed_week")
	Engine.print_error_messages = print_errors_before
	var after_state: Dictionary = GameState.core_loop_v2_state
	_expect(not can_record \
		and GameState.serialize() == before_boundary \
		and int(GameState.turn) == month_index * 4 \
		and int(GameState.week_of_month) == 4 \
		and float(GameState.money) == before_money \
		and int(GameState.health) == before_health \
		and int(GameState.mental) == before_mental \
		and _variant_equal_with_numeric_values(
			after_state.get("decline_receipts", {}), before_declines) \
		and EventManager.pending_events == boundary_pending_events \
		and _variant_equal_with_numeric_values(
			_order101_title_publication_snapshot(), title_before) \
		and not (after_state.get("month_summaries", {}) as Dictionary).has(
			str(month_index)),
		"MainGame month boundary mutated an incomplete Seoul cycle, pending event, or title meta")
	EventManager.pending_events = original_pending_events
	main_game.free()


func _check_terminal_preinstalled_summary_blocks_boundary(
		closed_save: Dictionary, month_index: int) -> void:
	GameState.start_new_game()
	GameState.load_from_dict(closed_save.duplicate(true))
	CORE.initialize_for_run(true)
	var valid_summary := CORE.record_month_summary(month_index, {}, {})
	_expect(not valid_summary.is_empty() \
		and str(valid_summary.get("planning_mode", "")) \
			== CORE.SEOUL_CYCLE_MODE,
		"preinstalled-summary fixture could not derive one genuine Seoul notebook")
	if valid_summary.is_empty():
		return
	# Preserve the root receipts/witnesses derived by the real writer together
	# with the notebook. Copying only the summary into the pre-write save would
	# manufacture an already-invalid historical row and test the reader instead
	# of the pre-rollover stale-summary guard.
	var preinstalled: Dictionary = GameState.serialize().duplicate(true)
	var preinstalled_state: Dictionary = preinstalled.get(
		"core_loop_v2_state", {})
	var preinstalled_summaries: Dictionary = preinstalled_state.get(
		"month_summaries", {})
	_expect(_variant_equal_with_numeric_values(
		preinstalled_summaries.get(str(month_index), {}), valid_summary) \
		and not (preinstalled_state.get(
			"terminal_transition_receipts", {}) as Dictionary).is_empty(),
		"preinstalled-summary fixture discarded its writer-owned root authority")
	GameState.start_new_game()
	GameState.load_from_dict(preinstalled)
	CORE.initialize_for_run(true)
	var main_game: Node = MAIN_GAME_SCRIPT.new()
	main_game.set_meta("_screenshot_qa_static_surface", true)
	main_game.set_meta("_qa_core_loop_v2_autosave_result", true)
	var original_pending_events: Array = EventManager.pending_events.duplicate(true)
	EventManager.pending_events = original_pending_events.duplicate(true)
	EventManager.pending_events.append({
		"id": "order101_preinstalled_summary_sentinel",
		"month": month_index,
	})
	var boundary_pending_events: Array = EventManager.pending_events.duplicate(true)
	var title_before: Dictionary = _order101_title_publication_snapshot()
	var before_boundary: Dictionary = GameState.serialize().duplicate(true)
	var can_record := CORE.can_record_month_summary(month_index)
	var print_errors_before := Engine.print_error_messages
	Engine.print_error_messages = false
	main_game.call("_core_loop_v2_advance_completed_week")
	Engine.print_error_messages = print_errors_before
	_expect(not can_record \
		and GameState.serialize() == before_boundary \
		and EventManager.pending_events == boundary_pending_events \
		and _variant_equal_with_numeric_values(
			_order101_title_publication_snapshot(), title_before) \
		and _variant_equal_with_numeric_values(
			CORE.month_summary(month_index), valid_summary),
		"MainGame accepted or mutated a preinstalled same-month Seoul notebook")
	EventManager.pending_events = original_pending_events
	main_game.free()


func _check_terminal_reserved_summary_extra_rejected(
		closed_save: Dictionary, month_index: int) -> void:
	var baseline_state: Dictionary = closed_save.get("core_loop_v2_state", {})
	var baseline_plan: Dictionary = (
		baseline_state.get("plans", {}) as Dictionary).get(
			str(month_index), {})
	var baseline_resolutions: Dictionary = baseline_state.get(
		"terminal_transition_resolutions", {})
	var baseline_summaries: Dictionary = baseline_state.get(
		"month_summaries", {})
	_expect(str(baseline_plan.get("planning_mode", "")) \
			== CORE.SEOUL_CYCLE_MODE \
		and not baseline_resolutions.is_empty() \
		and not baseline_summaries.has(str(month_index)),
		"reserved-summary-extra fixture lacked one unsummarized terminal month")
	if baseline_resolutions.is_empty() \
			or baseline_summaries.has(str(month_index)):
		return
	for reserved_key in ["planning_mode", "terminal_transition_resolutions"]:
		GameState.start_new_game()
		GameState.load_from_dict(closed_save.duplicate(true))
		CORE.initialize_for_run(true)
		var before_record: Dictionary = GameState.serialize().duplicate(true)
		var forged_value: Variant = "legacy_monthly_plan" \
			if reserved_key == "planning_mode" else {}
		var extra: Dictionary = {}
		extra[reserved_key] = forged_value
		var recorded := CORE.record_month_summary(
			month_index, {}, {}, extra)
		var after_summaries: Dictionary = GameState.core_loop_v2_state.get(
			"month_summaries", {})
		_expect(recorded.is_empty() \
			and not after_summaries.has(str(month_index)) \
			and GameState.serialize() == before_record,
			"record_month_summary allowed extra to overwrite reserved %s" \
				% reserved_key)


func _check_terminal_unselected_expiry_selection_forgery_rejected(
		historical_save: Dictionary, route_id: String,
		terminal_id: String, expected_resolution: Dictionary) -> void:
	var malformed := historical_save.duplicate(true)
	var state: Dictionary = malformed.get("core_loop_v2_state", {})
	var summaries: Dictionary = state.get("month_summaries", {})
	var summary: Dictionary = summaries.get("2", {})
	var node_states: Dictionary = summary.get("node_states", {})
	var people_node: Dictionary = node_states.get("m2_people", {})
	var allocations: Array = summary.get("allocation_receipts", [])
	var people_allocation_count := 0
	for raw_allocation in allocations:
		if raw_allocation is Dictionary \
				and str((raw_allocation as Dictionary).get(
					"node_id", "")) == "m2_people":
			people_allocation_count += 1
	var root_resolutions: Dictionary = state.get(
		"terminal_transition_resolutions", {})
	var summary_resolutions: Dictionary = summary.get(
		"terminal_transition_resolutions", {})
	_expect(people_allocation_count == 0 \
		and (people_node.get("binding_candidate_ids", []) as Array).size() == 3 \
		and str(people_node.get(
			"selected_trigger_candidate_id", "")).is_empty() \
		and str(people_node.get(
			"selected_terminal_route_id", "")).is_empty() \
		and str(people_node.get("terminal_selection_origin", "")) \
			== "unselected_union" \
		and _variant_equal_with_numeric_values(
			root_resolutions.get(route_id, {}), expected_resolution) \
		and _variant_equal_with_numeric_values(
			summary_resolutions.get(route_id, {}), expected_resolution),
		"unselected-expiry forgery fixture lacked exact zero-allocation authority")
	if people_allocation_count != 0 \
			or str(people_node.get("terminal_selection_origin", "")) \
				!= "unselected_union":
		return
	people_node["selected_trigger_candidate_id"] = terminal_id
	people_node["selected_terminal_route_id"] = route_id
	people_node["terminal_selection_origin"] = "terminal_union_player"
	node_states["m2_people"] = people_node
	summary["node_states"] = node_states
	for surface in [root_resolutions, summary_resolutions]:
		var resolution: Dictionary = surface.get(route_id, {}).duplicate(true)
		resolution["selected_candidate_id"] = terminal_id
		resolution["selected_terminal_route_id"] = route_id
		surface[route_id] = resolution
	summary["terminal_transition_resolutions"] = summary_resolutions
	summaries["2"] = summary
	state["terminal_transition_resolutions"] = root_resolutions
	state["month_summaries"] = summaries
	malformed["core_loop_v2_state"] = state
	_expect(str(people_node.get("selected_trigger_candidate_id", "")) \
			== terminal_id \
		and str(people_node.get("selected_terminal_route_id", "")) == route_id \
		and str(people_node.get("terminal_selection_origin", "")) \
			== "terminal_union_player" \
		and str((root_resolutions.get(route_id, {}) as Dictionary).get(
			"selected_candidate_id", "")) == terminal_id \
		and str((summary_resolutions.get(route_id, {}) as Dictionary).get(
			"selected_terminal_route_id", "")) == route_id,
		"unselected-expiry forgery did not mutate all three selected surfaces")

	GameState.start_new_game()
	GameState.load_from_dict(malformed)
	CORE.initialize_for_run(true)
	var before_read: Dictionary = GameState.serialize().duplicate(true)
	_expect(CORE.terminal_transition_resolution(route_id).is_empty() \
		and GameState.serialize() == before_read,
		"zero-allocation unselected expiry accepted coupled selected-route forgery")


func _check_terminal_forgone_historical_resolution(
		committed_save: Dictionary, source_receipt: Dictionary,
		route_id: String, expected_resolution: Dictionary) -> void:
	GameState.start_new_game()
	GameState.load_from_dict(committed_save.duplicate(true))
	CORE.initialize_for_run(true)
	if not _resolve_m2_people_selected_story("hyunsu_player_reachout", 0):
		return
	if not _resolve_cycle_story_world(
			"m2_mirae_result_message", "v2_mirae_result_message", 0):
		return
	if not bool(CORE.complete_seoul_cycle_turn(2).get("ok", false)):
		_expect(false, "forgone historical fixture could not close W5")
		return
	for turn in range(6, 9):
		_advance_to_next_week()
		if not _commit_m2_terminal_filler():
			return
		if turn == 8 and not _resolve_cycle_story_world(
				"temptation_consequence", "arc_temptation_clean", 0):
			return
		if not bool(CORE.complete_seoul_cycle_turn(2).get("ok", false)):
			_expect(false,
				"forgone historical fixture could not close W%d" % turn)
			return
	var summary := CORE.record_month_summary(2, {}, {})
	var summary_resolutions: Dictionary = summary.get(
		"terminal_transition_resolutions", {})
	_expect(CORE.terminal_transition_receipt(route_id) == source_receipt \
		and _variant_equal_with_numeric_values(
			summary_resolutions.get(route_id, {}), expected_resolution),
		"forgone resolution was not frozen into the closed M2 summary")
	_advance_to_next_week()
	var month_three := CORE.initialize_seoul_cycle(3)
	var historical_save: Dictionary = GameState.serialize().duplicate(true)
	_expect(bool(month_three.get("ok", false)) \
		and _variant_equal_with_numeric_values(
			CORE.terminal_transition_resolution(route_id), expected_resolution),
		"forgone resolution did not survive closed-target replacement")
	for reload_index in range(2):
		GameState.start_new_game()
		GameState.load_from_dict(historical_save.duplicate(true))
		CORE.initialize_for_run(true)
		_expect(_variant_equal_with_numeric_values(
			CORE.terminal_transition_resolution(route_id), expected_resolution),
			"historical forgone resolution drifted on reload %d" \
				% [reload_index + 1])
		historical_save = GameState.serialize().duplicate(true)
	_check_terminal_historical_resolution_mutations(
		historical_save, 2, route_id, expected_resolution)


func _check_terminal_m2_coupled_candidate_shrink_rejected(
		initialized_save: Dictionary, route_id: String,
		terminal_id: String) -> void:
	var malformed := initialized_save.duplicate(true)
	var state: Dictionary = malformed.get("core_loop_v2_state", {})
	var cycle: Dictionary = state.get("seoul_cycle", {})
	var nodes: Dictionary = cycle.get("nodes", {})
	var node: Dictionary = nodes.get("m2_people", {})
	var shrunk_ordinary := ["cafe_world_glimpse"]
	var shrunk_candidates := ["cafe_world_glimpse", terminal_id]
	node["ordinary_candidate_ids"] = shrunk_ordinary
	node["eligible_trigger_bundle_ids"] = shrunk_ordinary
	node["binding_candidate_ids"] = shrunk_candidates
	nodes["m2_people"] = node
	cycle["nodes"] = nodes
	state["seoul_cycle"] = cycle
	var plans: Dictionary = state.get("plans", {})
	var plan: Dictionary = plans.get("2", {})
	var candidate_sets: Dictionary = plan.get(
		"terminal_binding_candidate_sets", {})
	candidate_sets["m2_people"] = {
		"ordinary_candidate_ids": shrunk_ordinary,
		"binding_candidate_ids": shrunk_candidates,
	}
	plan["terminal_binding_candidate_sets"] = candidate_sets
	plans["2"] = plan
	state["plans"] = plans
	var witnesses: Dictionary = state.get(
		"terminal_target_binding_receipts", {})
	var witness: Dictionary = witnesses.get("2:m2_people", {})
	var preserved_eligibility: Dictionary = witness.get(
		"ordinary_eligibility", {})
	_expect(preserved_eligibility == {
		"schema": CORE.TERMINAL_TARGET_BINDING_SCHEMA,
		"cut_turn": 5,
		"eligible_authored_candidate_ids": [
			"cafe_world_glimpse", "hyunsu_player_reachout",
		],
	}, "triple-shrink fixture lost its historical eligibility authority")
	if preserved_eligibility.is_empty():
		return
	witness["ordinary_candidate_ids"] = shrunk_ordinary
	witness["binding_candidate_ids"] = shrunk_candidates
	_expect(witness.get("ordinary_eligibility", {}) == preserved_eligibility,
		"triple-shrink attack accidentally changed eligibility authority")
	witnesses["2:m2_people"] = witness
	state["terminal_target_binding_receipts"] = witnesses
	malformed["core_loop_v2_state"] = state
	GameState.start_new_game()
	GameState.load_from_dict(malformed)
	CORE.initialize_for_run(true)
	var before_retry: Dictionary = GameState.serialize().duplicate(true)
	var retried := CORE.initialize_seoul_cycle(2)
	_expect(not bool(CORE.seoul_cycle_snapshot(2).get("active", true)) \
		and CORE.terminal_target_candidates(2, "m2_people").is_empty() \
		and not bool(retried.get("ok", true)) \
		and str(retried.get("error", "")) == "terminal_binding_conflict" \
		and CORE.terminal_transition_resolution(route_id).is_empty() \
		and GameState.serialize() == before_retry,
		"triple-coupled M2 candidate shrinkage escaped historical eligibility")


func _prepare_fresh_w1_after_interview() -> bool:
	var source := _order101_fresh_w1_result_committed_save(2)
	if source.is_empty():
		return false
	var completed_resume := CORE.complete_active_bundle()
	var claimed_interview := completed_resume \
		== "m1_youth_center_resume_clinic" \
		and CORE.claim_fresh_w1_opening_interview()
	if not claimed_interview:
		_expect(false, "fresh father fixture could not claim W1 interview")
		return false
	_apply_and_note_story("arc_intro_01_meal", 0)
	_apply_and_note_story("v2_opening_return_math", 0)
	var completed_interview := CORE.complete_active_bundle()
	_expect(completed_interview == "opening_interview_math" \
		and CORE.application_status("mirae_industrial_tech") == "interviewed" \
		and CORE.opening_application_provenance_valid(),
		"fresh father fixture did not consume the typed W1 interview")
	return completed_interview == "opening_interview_math"


func _produce_fresh_father_completed_month(choice_index: int) -> Dictionary:
	if not _prepare_fresh_w1_after_interview():
		return {}
	if not bool(CORE.complete_seoul_cycle_turn(1).get("ok", false)):
		_expect(false, "fresh father source could not close typed W1")
		return {}
	_advance_to_next_week()
	var snapshot := CORE.seoul_cycle_snapshot(1)
	var capacity_id := _unused_capacity(snapshot, 3, true)
	var committed := CORE.commit_seoul_cycle_allocation(
		capacity_id, "father", 1)
	var claimed := CORE.claim_seoul_cycle_trigger()
	var began := bool(claimed.get("ok", false)) \
		and CORE.begin_seoul_cycle_trigger("father_first_call")
	if began:
		_apply_and_note_story(FATHER_EVENT, choice_index)
	var completed := CORE.complete_active_bundle() if began else ""
	_expect(bool(committed.get("ok", false)) \
		and bool(committed.get("completed_now", false)) \
		and completed == "father_first_call",
		"father choice %d did not run through actual fresh W2 board/story" \
			% choice_index)
	if completed != "father_first_call" \
			or not bool(CORE.complete_seoul_cycle_turn(1).get("ok", false)):
		return {}
	for turn in range(3, 5):
		_advance_to_next_week()
		var filler_snapshot := CORE.seoul_cycle_snapshot(1)
		var filler_capacity := _unused_capacity(filler_snapshot, 0, true)
		var filler := CORE.commit_seoul_cycle_allocation(
			filler_capacity, "recovery", 1)
		if not bool(filler.get("ok", false)):
			_expect(false, "fresh father source filler failed at W%d" % turn)
			return {}
		if turn == 3 and not _resolve_cycle_story_world(
				"hyunsu_first_meet", HYUNSU_EVENT, 0):
			return {}
		if turn == 4 and not _resolve_cycle_story_world(
				"first_temptation_boss", TEMPTATION_EVENT, 0):
			return {}
		if not bool(CORE.complete_seoul_cycle_turn(1).get("ok", false)):
			_expect(false, "fresh father source could not close W%d" % turn)
			return {}
	var summary := CORE.record_month_summary(1, {}, {})
	return {"summary": summary, "source_turn": 2}


func _check_father_terminal_no_offer_summary_durability(
		saved: Dictionary, route_id: String, frozen: Dictionary,
		source_turn: int) -> void:
	GameState.start_new_game()
	GameState.load_from_dict(saved.duplicate(true))
	CORE.initialize_for_run(true)
	GameState.turn = 5
	GameState.month = 2
	GameState.week_of_month = 1
	var initialized := CORE.initialize_seoul_cycle(2)
	if not bool(initialized.get("ok", false)):
		_expect(false, "father durability could not initialize M2")
		return
	# Use the same exact action-resolving filler as the M2 source fixtures. A
	# threshold-completing self allocation would leave its own rest trigger open
	# while this durability route resolves the fixed Mirae world beat.
	var filler_ok := _commit_m2_terminal_filler()
	var world_claimed := CORE.claim_seoul_cycle_world()
	var world_began := bool(world_claimed.get("ok", false)) \
		and CORE.begin_seoul_cycle_world("m2_mirae_result_message")
	if world_began:
		_apply_and_note_story("v2_mirae_result_message", 0)
	var world_completed := CORE.complete_active_bundle() if world_began else ""
	_expect(filler_ok \
		and world_completed == "m2_mirae_result_message" \
		and CORE.application_status("mirae_industrial_tech") == "no_offer" \
		and CORE.terminal_transition_receipt(route_id) == frozen,
		"father receipt did not survive exact W5 no-offer transition")
	if world_completed != "m2_mirae_result_message":
		return
	var week_five_closed := CORE.complete_seoul_cycle_turn(2)
	_expect(bool(week_five_closed.get("ok", false)),
		"father durability could not close W5")
	if not bool(week_five_closed.get("ok", false)):
		return
	for turn in range(6, 9):
		_advance_to_next_week()
		if not _commit_m2_terminal_filler():
			return
		if turn == 8 and not _resolve_cycle_story_world(
				"temptation_consequence", "arc_temptation_clean", 0):
			return
		if not bool(CORE.complete_seoul_cycle_turn(2).get("ok", false)):
			_expect(false, "father durability could not close W%d" % turn)
			return
	var month_two_closed_save: Dictionary = GameState.serialize().duplicate(true)
	_check_terminal_auto_selected_zero_expiry_authority_rejected(
		month_two_closed_save,
		"m1_resume_completed_q2_to_m2_advancement_polished")
	GameState.start_new_game()
	GameState.load_from_dict(month_two_closed_save.duplicate(true))
	CORE.initialize_for_run(true)
	CORE.record_month_summary(2, {}, {})
	GameState.turn = 9
	GameState.month = 3
	GameState.week_of_month = 1
	var month_three := CORE.initialize_seoul_cycle(3)
	var summary_only_save: Dictionary = GameState.serialize().duplicate(true)
	_expect(bool(month_three.get("ok", false)) \
		and CORE.terminal_transition_receipt(route_id) == frozen,
		"father receipt did not survive M3 summary-only replacement")
	for reload_index in range(2):
		GameState.start_new_game()
		GameState.load_from_dict(summary_only_save.duplicate(true))
		CORE.initialize_for_run(true)
		_expect(CORE.application_status("mirae_industrial_tech") == "no_offer" \
			and CORE.terminal_transition_receipt(route_id) == frozen,
			"father no-offer summary receipt drifted on reload %d" \
				% [reload_index + 1])
		summary_only_save = GameState.serialize().duplicate(true)
	_check_father_summary_only_provenance_mutations(
		summary_only_save, route_id, frozen, source_turn)


func _check_terminal_auto_selected_zero_expiry_authority_rejected(
		closed_save: Dictionary, route_id: String) -> void:
	var baseline_state: Dictionary = closed_save.get("core_loop_v2_state", {})
	var baseline_cycle: Dictionary = baseline_state.get("seoul_cycle", {})
	var nodes: Dictionary = baseline_cycle.get("nodes", {})
	var node: Dictionary = nodes.get("m2_advancement", {})
	var expiries: Dictionary = baseline_cycle.get("expiry_receipts", {})
	var expiry: Dictionary = expiries.get("m2_advancement", {})
	var expired_nodes: Array = baseline_cycle.get("expired_nodes", [])
	var allocations: Dictionary = baseline_cycle.get("allocation_receipts", {})
	var matching_allocations := 0
	for raw_allocation in allocations.values():
		if raw_allocation is Dictionary \
				and str((raw_allocation as Dictionary).get("node_id", "")) \
					== "m2_advancement":
			matching_allocations += 1
	var expiry_turn := int(node.get("expired_turn", 0))
	var closing_allocation: Dictionary = allocations.get(str(expiry_turn), {})
	var closing_expired: Array = closing_allocation.get("expired_nodes", [])
	_expect(str(node.get("status", "")) == "expired" \
		and int(node.get("progress", -1)) == 0 \
		and int(node.get("completed_turn", -1)) == 0 \
		and int(node.get("last_allocation_turn", -1)) == 0 \
		and expiry_turn == 6 \
		and str(node.get("selected_terminal_route_id", "")) == route_id \
		and str(node.get("selected_trigger_candidate_id", "")) \
			== "terminal:%s" % route_id \
		and matching_allocations == 0 \
		and expired_nodes.count("m2_advancement") == 1 \
		and closing_expired.count("m2_advancement") == 1 \
		and str(expiry.get("node_id", "")) == "m2_advancement" \
		and int(expiry.get("turn", 0)) == expiry_turn \
		and int(expiry.get("week_index", 0)) == 2 \
		and str(expiry.get("status", "")) == "consumed" \
		and (baseline_cycle.get("completed_turns", []) as Array).has(expiry_turn),
		"auto-selected zero-allocation terminal expiry fixture was not exact")
	if expiry.is_empty() or closing_allocation.is_empty():
		return
	for mutation in [
		"coupled_delete", "receipt_status", "receipt_turn",
		"expired_nodes_delete", "closing_receipt_delete", "node_expired_turn",
	]:
		var malformed := closed_save.duplicate(true)
		var state: Dictionary = malformed.get("core_loop_v2_state", {})
		var cycle: Dictionary = state.get("seoul_cycle", {})
		var malformed_nodes: Dictionary = cycle.get("nodes", {})
		var malformed_node: Dictionary = malformed_nodes.get(
			"m2_advancement", {})
		var malformed_expiries: Dictionary = cycle.get("expiry_receipts", {})
		var malformed_expiry: Dictionary = malformed_expiries.get(
			"m2_advancement", {})
		var malformed_expired_nodes: Array = cycle.get("expired_nodes", [])
		var malformed_allocations: Dictionary = cycle.get(
			"allocation_receipts", {})
		var malformed_closing: Dictionary = malformed_allocations.get(
			str(expiry_turn), {})
		var malformed_closing_expired: Array = malformed_closing.get(
			"expired_nodes", [])
		match mutation:
			"coupled_delete":
				malformed_expiries.erase("m2_advancement")
				malformed_expired_nodes.erase("m2_advancement")
				malformed_closing_expired.erase("m2_advancement")
				malformed_node["status"] = "open"
				malformed_node["expired_turn"] = 0
			"receipt_status":
				malformed_expiry["status"] = "pending"
			"receipt_turn":
				malformed_expiry["turn"] = 7
			"expired_nodes_delete":
				malformed_expired_nodes.erase("m2_advancement")
			"closing_receipt_delete":
				malformed_closing_expired.erase("m2_advancement")
			"node_expired_turn":
				malformed_node["expired_turn"] = 7
		if mutation == "coupled_delete":
			malformed_expiries.erase("m2_advancement")
		else:
			malformed_expiries["m2_advancement"] = malformed_expiry
		malformed_closing["expired_nodes"] = malformed_closing_expired
		malformed_allocations[str(expiry_turn)] = malformed_closing
		malformed_nodes["m2_advancement"] = malformed_node
		cycle["nodes"] = malformed_nodes
		cycle["expiry_receipts"] = malformed_expiries
		cycle["expired_nodes"] = malformed_expired_nodes
		cycle["allocation_receipts"] = malformed_allocations
		state["seoul_cycle"] = cycle
		malformed["core_loop_v2_state"] = state
		_expect_terminal_active_target_mutation_rejected(
			malformed, route_id, "auto-selected expiry %s" % mutation)


func _check_father_summary_only_provenance_mutations(
		saved: Dictionary, route_id: String, frozen: Dictionary,
		source_turn: int) -> void:
	var expected_key := "father_first_call:arc_father_01_call:0:%d" \
		% source_turn
	for mutation in ["delete_typed_action", "coupled_reciprocal"]:
		var malformed := saved.duplicate(true)
		var state: Dictionary = malformed.get("core_loop_v2_state", {})
		if mutation == "delete_typed_action":
			(state.get("action_receipts", {}) as Dictionary).erase(
				"m1_youth_center_resume_clinic")
		else:
			var receipts: Dictionary = state.get(
				"terminal_transition_receipts", {})
			var bad: Dictionary = frozen.duplicate(true)
			var proof: Dictionary = bad.get("source_proof", {})
			var proof_relationship: Dictionary = proof.get(
				"relationship_receipt", {})
			proof_relationship["initiative"] = "reciprocal"
			proof["relationship_receipt"] = proof_relationship
			bad["source_proof"] = proof
			receipts[route_id] = bad
			state["terminal_transition_receipts"] = receipts
			var relationships: Dictionary = state.get(
				"relationship_choice_receipts", {})
			var relationship: Dictionary = relationships.get(expected_key, {})
			relationship["initiative"] = "reciprocal"
			relationships[expected_key] = relationship
			state["relationship_choice_receipts"] = relationships
			for ledger_key in ["relationship_history", "relationship_memories"]:
				var ledger: Array = state.get(ledger_key, [])
				for index in range(ledger.size()):
					if ledger[index] is Dictionary \
							and str((ledger[index] as Dictionary).get(
								"receipt_key", "")) == expected_key:
						var row: Dictionary = (
							ledger[index] as Dictionary).duplicate(true)
						row["initiative"] = "reciprocal"
						ledger[index] = row
				state[ledger_key] = ledger
		malformed["core_loop_v2_state"] = state
		GameState.start_new_game()
		GameState.load_from_dict(malformed)
		CORE.initialize_for_run(true)
		_expect(CORE.terminal_transition_receipt(route_id).is_empty(),
			"father summary-only receipt accepted %s provenance mutation" \
				% mutation)


func _produce_completed_resume_month(quality: int) -> Dictionary:
	var source_save := _order101_fresh_w1_result_committed_save(quality)
	if source_save.is_empty():
		return {}
	if quality == 0 and not _terminal_source_placeholder_checked:
		_terminal_source_placeholder_checked = true
		_check_terminal_source_receipt_placeholder_not_healed(
			source_save,
			"m1_resume_completed_q0_to_m2_advancement_rewritten")
		GameState.start_new_game()
		GameState.load_from_dict(source_save.duplicate(true))
		CORE.initialize_for_run(true)
	var completed_bundle := CORE.complete_active_bundle()
	_expect(completed_bundle == "m1_youth_center_resume_clinic" \
		and CORE.pending_seoul_cycle_trigger().is_empty(),
		"quality %d source could not resolve its exact resume trigger" % quality)
	if completed_bundle != "m1_youth_center_resume_clinic":
		return {}
	if not _close_order101_source_month_after_w1():
		return {}
	var summary := CORE.record_month_summary(1, {}, {})
	_expect(not summary.is_empty(),
		"quality %d source month did not create its live close receipt" % quality)
	return summary


func _check_terminal_source_receipt_placeholder_not_healed(
		pre_outcome_save: Dictionary, route_id: String) -> void:
	var baseline_state: Dictionary = pre_outcome_save.get(
		"core_loop_v2_state", {})
	var baseline_receipts: Dictionary = baseline_state.get(
		"terminal_transition_receipts", {})
	_expect(not baseline_receipts.has(route_id) \
		and str((baseline_state.get(
			CORE.W1_ONBOARDING_STATE_KEY, {}) as Dictionary).get("phase", "")) \
			== "result_committed",
		"source placeholder fixture was not before the terminal outcome")
	if baseline_receipts.has(route_id):
		return
	for placeholder in [{}, "terminal_receipt_placeholder"]:
		GameState.start_new_game()
		GameState.load_from_dict(pre_outcome_save.duplicate(true))
		CORE.initialize_for_run(true)
		var state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
		var receipts: Dictionary = state.get("terminal_transition_receipts", {})
		receipts[route_id] = placeholder
		state["terminal_transition_receipts"] = receipts
		GameState.core_loop_v2_state = state
		var raw_inserted: Dictionary = GameState.core_loop_v2_state.get(
			"terminal_transition_receipts", {})
		var completed_bundle := CORE.complete_active_bundle()
		var closed := completed_bundle == "m1_youth_center_resume_clinic" \
			and _close_order101_source_month_after_w1()
		_expect(raw_inserted.has(route_id) \
			and _variant_equal_with_numeric_values(
				raw_inserted.get(route_id), placeholder) \
			and completed_bundle == "m1_youth_center_resume_clinic" \
			and closed,
			"source placeholder fixture could not reach its genuine month close")
		if not closed:
			continue
		var before_summary: Dictionary = GameState.serialize().duplicate(true)
		var summary := CORE.record_month_summary(1, {}, {})
		var after_state: Dictionary = GameState.core_loop_v2_state
		var after_receipts: Dictionary = after_state.get(
			"terminal_transition_receipts", {})
		var after_summaries: Dictionary = after_state.get("month_summaries", {})
		_expect(summary.is_empty() \
			and not after_summaries.has("1") \
			and after_receipts.has(route_id) \
			and _variant_equal_with_numeric_values(
				after_receipts.get(route_id), placeholder) \
			and CORE.terminal_transition_receipt(route_id).is_empty() \
			and GameState.serialize() == before_summary,
			"source month summary healed or persisted a %s receipt placeholder" \
				% ["dictionary" if placeholder is Dictionary else "string"])


func _close_order101_source_month_after_w1() -> bool:
	if not bool(CORE.complete_seoul_cycle_turn(1).get("ok", false)):
		_expect(false, "terminal source W1 could not close")
		return false
	for turn in range(2, 5):
		_advance_to_next_week()
		var snapshot := CORE.seoul_cycle_snapshot(1)
		var capacity_id := _unused_capacity(snapshot, 0, true)
		var committed := CORE.commit_seoul_cycle_allocation(
			capacity_id, "recovery", 1)
		if not bool(committed.get("ok", false)):
			_expect(false, "terminal source Week %d recovery commit failed" % turn)
			return false
		if turn == 3 and not _resolve_cycle_story_world(
				"hyunsu_first_meet", HYUNSU_EVENT, 0):
			return false
		if turn == 4 and not _resolve_cycle_story_world(
				"first_temptation_boss", TEMPTATION_EVENT, 0):
			return false
		if not bool(CORE.complete_seoul_cycle_turn(1).get("ok", false)):
			_expect(false, "terminal source Week %d could not close" % turn)
			return false
	return true


func _check_terminal_receipt_nested_mutations_rejected(
		saved: Dictionary, route_id: String, receipt: Dictionary,
		quality: int) -> void:
	for field_path in [
		["source_proof", "node_state", "completed_turn"],
		["source_proof", "allocation_receipt", "node_id"],
		["source_proof", "trigger_receipt", "bundle_id"],
		["source_proof", "action_receipt", "result_details", "quality"],
		["source_proof", "application_transition_receipt", "quality"],
	]:
		var malformed := saved.duplicate(true)
		var state: Dictionary = malformed.get("core_loop_v2_state", {})
		var all_receipts: Dictionary = state.get(
			"terminal_transition_receipts", {})
		var bad: Dictionary = receipt.duplicate(true)
		_set_nested_terminal_mutation(bad, field_path, quality)
		all_receipts[route_id] = bad
		state["terminal_transition_receipts"] = all_receipts
		malformed["core_loop_v2_state"] = state
		GameState.start_new_game()
		GameState.load_from_dict(malformed)
		CORE.initialize_for_run(true)
		_expect(CORE.terminal_transition_receipt(route_id).is_empty(),
			"terminal receipt accepted mutated nested path %s" % str(field_path))


func _check_terminal_receipt_underlying_mutations_rejected(
		saved: Dictionary, route_id: String, quality: int) -> void:
	for mutation in [
		"delete_action", "transition_quality", "live_allocation_node",
		"live_trigger_bundle", "summary_node_turn", "summary_allocation_node",
		"delete_all_source_ledgers",
	]:
		var malformed := saved.duplicate(true)
		var state: Dictionary = malformed.get("core_loop_v2_state", {})
		match mutation:
			"delete_action":
				(state.get("action_receipts", {}) as Dictionary).erase(
					"m1_youth_center_resume_clinic")
			"transition_quality":
				var transitions: Dictionary = state.get(
					"application_transition_receipts", {})
				var transition: Dictionary = transitions.get(
					"m1_youth_center_resume_clinic:application:1", {})
				transition["quality"] = quality + 10
				transitions[
					"m1_youth_center_resume_clinic:application:1"] = transition
			"live_allocation_node":
				var cycle: Dictionary = state.get("seoul_cycle", {})
				var allocations: Dictionary = cycle.get("allocation_receipts", {})
				var allocation: Dictionary = allocations.get("1", {})
				allocation["node_id"] = "father"
				allocations["1"] = allocation
				cycle["allocation_receipts"] = allocations
				state["seoul_cycle"] = cycle
			"live_trigger_bundle":
				var cycle: Dictionary = state.get("seoul_cycle", {})
				var triggers: Dictionary = cycle.get("trigger_receipts", {})
				var trigger: Dictionary = triggers.get("resume", {})
				trigger["bundle_id"] = "father_first_call"
				triggers["resume"] = trigger
				cycle["trigger_receipts"] = triggers
				state["seoul_cycle"] = cycle
			"summary_node_turn":
				var summaries: Dictionary = state.get("month_summaries", {})
				var summary: Dictionary = summaries.get("1", {})
				var nodes: Dictionary = summary.get("node_states", {})
				var node: Dictionary = nodes.get("resume", {})
				node["completed_turn"] = 99
				nodes["resume"] = node
				summary["node_states"] = nodes
				summaries["1"] = summary
				state["month_summaries"] = summaries
			"summary_allocation_node":
				var summaries: Dictionary = state.get("month_summaries", {})
				var summary: Dictionary = summaries.get("1", {})
				var allocations: Array = summary.get("allocation_receipts", [])
				for index in range(allocations.size()):
					if allocations[index] is Dictionary \
							and int((allocations[index] as Dictionary).get(
								"turn", 0)) == 1:
						var allocation: Dictionary = (
							allocations[index] as Dictionary).duplicate(true)
						allocation["node_id"] = "father"
						allocations[index] = allocation
				summary["allocation_receipts"] = allocations
				summaries["1"] = summary
				state["month_summaries"] = summaries
			"delete_all_source_ledgers":
				state["action_receipts"] = {}
				state["application_transition_receipts"] = {}
				state["month_summaries"] = {}
				state["seoul_cycle"] = {}
		malformed["core_loop_v2_state"] = state
		GameState.start_new_game()
		GameState.load_from_dict(malformed)
		CORE.initialize_for_run(true)
		_expect(CORE.terminal_transition_receipt(route_id).is_empty(),
			"terminal receipt ignored mutated underlying source: %s" % mutation)


func _check_terminal_coupled_capacity_mutation_rejected(
		saved: Dictionary, route_id: String,
		frozen_receipt: Dictionary) -> void:
	var malformed := saved.duplicate(true)
	var state: Dictionary = malformed.get("core_loop_v2_state", {})
	var cycle: Dictionary = state.get("seoul_cycle", {})
	var action_receipts: Dictionary = state.get("action_receipts", {})
	var action: Dictionary = action_receipts.get(
		"m1_youth_center_resume_clinic", {})
	var details: Dictionary = action.get("result_details", {})
	var original_capacity_id := str(details.get("capacity_id", ""))
	var sibling_capacity: Dictionary = {}
	for raw_capacity in cycle.get("capacities", []):
		if raw_capacity is Dictionary \
				and str((raw_capacity as Dictionary).get("id", "")) \
					!= original_capacity_id:
			sibling_capacity = (raw_capacity as Dictionary).duplicate(true)
			break
	_expect(not sibling_capacity.is_empty(),
		"q0 capacity mutation fixture has no legal sibling capacity")
	if sibling_capacity.is_empty():
		return
	var sibling_id := str(sibling_capacity.get("id", ""))
	var sibling_value := int(sibling_capacity.get("value", 0))
	details["capacity_id"] = sibling_id
	details["capacity_value"] = sibling_value
	action["result_details"] = details
	action_receipts["m1_youth_center_resume_clinic"] = action
	state["action_receipts"] = action_receipts
	var terminal_receipts: Dictionary = state.get(
		"terminal_transition_receipts", {})
	var forged: Dictionary = frozen_receipt.duplicate(true)
	var proof: Dictionary = forged.get("source_proof", {})
	var proof_action: Dictionary = proof.get("action_receipt", {})
	var proof_details: Dictionary = proof_action.get("result_details", {})
	proof_details["capacity_id"] = sibling_id
	proof_details["capacity_value"] = sibling_value
	proof_action["result_details"] = proof_details
	proof["action_receipt"] = proof_action
	forged["source_proof"] = proof
	terminal_receipts[route_id] = forged
	state["terminal_transition_receipts"] = terminal_receipts
	malformed["core_loop_v2_state"] = state
	GameState.start_new_game()
	GameState.load_from_dict(malformed)
	CORE.initialize_for_run(true)
	_expect(CORE.terminal_transition_receipt(route_id).is_empty(),
		"q0 receipt accepted coupled action/proof sibling capacity while " \
			+ "allocation/onboarding authority stayed unchanged")


func _check_terminal_long_horizon_retention(
		saved: Dictionary, route_id: String, frozen_receipt: Dictionary,
		source_turn: int) -> void:
	var missing_outer := saved.duplicate(true)
	var source_weekly: Array = missing_outer.get("weekly_commitments", [])
	for index in range(source_weekly.size() - 1, -1, -1):
		if source_weekly[index] is Dictionary \
				and int((source_weekly[index] as Dictionary).get(
					"turn", 0)) == source_turn:
			source_weekly.remove_at(index)
	missing_outer["weekly_commitments"] = source_weekly
	GameState.start_new_game()
	GameState.load_from_dict(missing_outer)
	CORE.initialize_for_run(true)
	_expect(CORE.terminal_transition_receipt(route_id).is_empty(),
		"live source cycle accepted a missing source-turn outer weekly row")

	var bad_summary := saved.duplicate(true)
	var summary_state: Dictionary = bad_summary.get("core_loop_v2_state", {})
	var summaries: Dictionary = summary_state.get("month_summaries", {})
	var source_month := CORE.month_for_turn(source_turn)
	var summary: Dictionary = summaries.get(str(source_month), {})
	var allocations: Array = summary.get("allocation_receipts", [])
	for index in range(allocations.size()):
		if allocations[index] is Dictionary \
				and int((allocations[index] as Dictionary).get(
					"turn", 0)) == source_turn:
			var allocation: Dictionary = (
				allocations[index] as Dictionary).duplicate(true)
			var embedded: Dictionary = allocation.get(
				"weekly_commitment", {}).duplicate(true)
			var embedded_details: Dictionary = embedded.get(
				"details", {}).duplicate(true)
			embedded_details["capacity_id"] = "summary_sibling_capacity"
			embedded["details"] = embedded_details
			allocation["weekly_commitment"] = embedded
			allocations[index] = allocation
			break
	summary["allocation_receipts"] = allocations
	summaries[str(source_month)] = summary
	summary_state["month_summaries"] = summaries
	bad_summary["core_loop_v2_state"] = summary_state
	GameState.start_new_game()
	GameState.load_from_dict(bad_summary)
	CORE.initialize_for_run(true)
	_expect(CORE.terminal_transition_receipt(route_id).is_empty(),
		"terminal reader ignored mutated summary-embedded weekly identity")

	for future_turn in [25, 48]:
		var future := saved.duplicate(true)
		future["turn"] = future_turn
		future["month"] = CORE.month_for_turn(future_turn)
		future["week_of_month"] = ((future_turn - 1) % 4) + 1
		var future_state: Dictionary = future.get("core_loop_v2_state", {})
		future_state["seoul_cycle"] = {}
		future["core_loop_v2_state"] = future_state
		var future_weekly: Array = future.get("weekly_commitments", [])
		for ledger_turn in range(future_turn - 16, future_turn):
			future_weekly.append(_terminal_retention_weekly_record(ledger_turn))
		future["weekly_commitments"] = future_weekly
		GameState.start_new_game()
		GameState.load_from_dict(future)
		CORE.initialize_for_run(true)
		_expect(GameState.weekly_commitments.size() == 16 \
			and not GameState.has_weekly_commitment_for_turn(source_turn) \
			and CORE.terminal_transition_receipt(route_id) == frozen_receipt,
			"terminal receipt did not survive legal outer-ledger pruning at W%d" \
				% future_turn)
		var roundtrip: Dictionary = GameState.serialize().duplicate(true)
		for reload_index in range(2):
			GameState.start_new_game()
			GameState.load_from_dict(roundtrip.duplicate(true))
			CORE.initialize_for_run(true)
			_expect(CORE.terminal_transition_receipt(route_id) == frozen_receipt,
				"W%d terminal receipt drifted on retention reload %d" % [
					future_turn, reload_index + 1])
			roundtrip = GameState.serialize().duplicate(true)
		if source_turn == 1:
			_check_terminal_generic_retention_without_source(
				saved, route_id, frozen_receipt, source_turn, future_turn)
		_check_terminal_invalid_long_horizon_reader(
			saved, route_id, source_turn, future_turn, false)
		_check_terminal_invalid_long_horizon_reader(
			saved, route_id, source_turn, future_turn, true)
	if source_turn == 1:
		_check_terminal_invalid_retention_target_init(
			saved, route_id, source_turn, false)
		_check_terminal_invalid_retention_target_init(
			saved, route_id, source_turn, true)


func _check_terminal_generic_retention_without_source(
		saved: Dictionary, route_id: String, frozen_receipt: Dictionary,
		source_turn: int, future_turn: int) -> void:
	var future: Dictionary = saved.duplicate(true)
	future["turn"] = future_turn
	future["month"] = CORE.month_for_turn(future_turn)
	future["week_of_month"] = ((future_turn - 1) % 4) + 1
	var future_state: Dictionary = future.get("core_loop_v2_state", {})
	future_state["seoul_cycle"] = {}
	future["core_loop_v2_state"] = future_state
	var future_weekly: Array = future.get("weekly_commitments", [])
	for ledger_turn in range(future_turn - 16, future_turn):
		future_weekly.append(_terminal_retention_weekly_record(
			ledger_turn, false))
	future["weekly_commitments"] = future_weekly
	GameState.start_new_game()
	GameState.load_from_dict(future)
	CORE.initialize_for_run(true)
	var source_free := true
	for raw_record in GameState.weekly_commitments:
		if not raw_record is Dictionary \
				or not str((raw_record as Dictionary).get(
					"source", "")).is_empty():
			source_free = false
			break
	_expect(GameState.weekly_commitments.size() == 16 \
		and source_free \
		and not GameState.has_weekly_commitment_for_turn(source_turn) \
		and CORE.terminal_transition_receipt(route_id) == frozen_receipt,
		"terminal receipt rejected legal generic source-free eviction at W%d" \
			% future_turn)


func _check_terminal_invalid_long_horizon_reader(
		saved: Dictionary, route_id: String, source_turn: int,
		future_turn: int, stale_sixteen: bool) -> void:
	var malformed: Dictionary = saved.duplicate(true)
	malformed["turn"] = future_turn
	malformed["month"] = CORE.month_for_turn(future_turn)
	malformed["week_of_month"] = ((future_turn - 1) % 4) + 1
	var state: Dictionary = malformed.get("core_loop_v2_state", {})
	state["seoul_cycle"] = {}
	malformed["core_loop_v2_state"] = state
	malformed["weekly_commitments"] = _terminal_invalid_retention_weekly(
		source_turn, stale_sixteen)
	GameState.start_new_game()
	GameState.load_from_dict(malformed)
	CORE.initialize_for_run(true)
	var expected_size := 16 if stale_sixteen else 0
	_expect(GameState.weekly_commitments.size() == expected_size \
		and not GameState.has_weekly_commitment_for_turn(source_turn),
		"invalid W%d retention fixture did not preserve its %s outer ledger" \
			% [future_turn, "stale-16" if stale_sixteen else "empty"])
	var target: Dictionary = ORDER101_TERMINAL_SLICE_ROUTES.get(
		route_id, {}).get("target", {})
	var before_read: Dictionary = GameState.serialize().duplicate(true)
	var receipt: Dictionary = CORE.terminal_transition_receipt(route_id)
	var routes: Array = CORE.terminal_routes_for_target(
		int(target.get("month", 0)), str(target.get("node", "")))
	var resolution: Dictionary = CORE.terminal_transition_resolution(route_id)
	_expect(receipt.is_empty() \
		and routes.is_empty() \
		and resolution.is_empty() \
		and GameState.serialize() == before_read,
		"terminal reader accepted or mutated a W%d %s outer ledger" % [
			future_turn, "stale-16" if stale_sixteen else "empty"])


func _check_terminal_invalid_retention_target_init(
		saved: Dictionary, route_id: String, source_turn: int,
		stale_sixteen: bool) -> void:
	GameState.start_new_game()
	GameState.load_from_dict(saved.duplicate(true))
	CORE.initialize_for_run(true)
	_advance_to_next_week()
	var malformed: Dictionary = GameState.serialize().duplicate(true)
	malformed["weekly_commitments"] = _terminal_invalid_retention_weekly(
		source_turn, stale_sixteen)
	GameState.start_new_game()
	GameState.load_from_dict(malformed)
	CORE.initialize_for_run(true)
	var target: Dictionary = ORDER101_TERMINAL_SLICE_ROUTES.get(
		route_id, {}).get("target", {})
	var target_month := int(target.get("month", 0))
	var target_node := str(target.get("node", ""))
	var before_init: Dictionary = GameState.serialize().duplicate(true)
	var result: Dictionary = CORE.initialize_seoul_cycle(target_month)
	_expect(CORE.terminal_transition_receipt(route_id).is_empty() \
		and CORE.terminal_target_candidates(
			target_month, target_node).is_empty() \
		and not bool(result.get("ok", true)) \
		and str(result.get("error", "")) == "terminal_binding_conflict" \
		and CORE.terminal_transition_resolution(route_id).is_empty() \
		and GameState.serialize() == before_init,
		("target initialization consumed or downgraded a %s outer-ledger " \
			+ "conflict") % ("stale-16" if stale_sixteen else "empty"))


func _terminal_invalid_retention_weekly(
		source_turn: int, stale_sixteen: bool) -> Array:
	var records: Array = []
	if not stale_sixteen:
		return records
	for ledger_turn in range(source_turn - 16, source_turn):
		records.append(_terminal_retention_weekly_record(ledger_turn))
	return records


func _terminal_retention_weekly_record(
		turn: int, include_source: bool = true) -> Dictionary:
	var record := {
		"turn": turn,
		"pressure_id": "story:terminal_retention_%d" % turn,
		"pressure_family": "story",
		"choice_id": "story:terminal_retention_%d:0" % turn,
		"actual_action_id": "story_choice",
		"person_id": "",
		"forgone_ids": [],
		"echoed_turn": -1,
	}
	if include_source:
		record["source"] = "story_event"
	return record


func _set_nested_terminal_mutation(
		receipt: Dictionary, field_path: Array, quality: int) -> void:
	var cursor := receipt
	for index in range(field_path.size() - 1):
		var key := str(field_path[index])
		var child: Dictionary = cursor.get(key, {}).duplicate(true)
		cursor[key] = child
		cursor = child
	var leaf := str(field_path.back())
	cursor[leaf] = (
		quality + 10 if leaf == "quality" \
		else 99 if leaf in ["completed_turn", "expired_turn", "week_index"] \
		else -99 if leaf == "mental" \
		else "sibling_injection")


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


func _check_order101_m2_people_selection_contract() -> void:
	var contract_snapshot: Dictionary = DataRegistry.demo_core_loop_v2.duplicate(true)
	var cycle_spec: Dictionary = contract_snapshot.get("seoul_cycle", {})
	var months: Dictionary = cycle_spec.get("months", {})
	var month_two: Dictionary = months.get("2", {})
	var node_specs: Dictionary = month_two.get("nodes", {})
	var people_spec: Dictionary = node_specs.get("m2_people", {})
	var authored_ids: Array[String] = []
	for raw_id in people_spec.get("trigger_options", []):
		authored_ids.append(str(raw_id))
	var expected_ids: Array[String] = [
		"cafe_world_glimpse", "hyunsu_player_reachout",
	]
	_expect(_sorted_strings(authored_ids) == expected_ids \
		and authored_ids.size() == 2 \
		and str(people_spec.get("trigger_selection_mode", "")) \
			== "player_required" \
		and str(people_spec.get("selection_owner", "")) == "player" \
		and not people_spec.has("fallback_trigger_bundle") \
		and not people_spec.has("summary_bundle"),
		"M2 people authoring did not declare exactly two player-owned choices")

	_check_m2_people_candidate_cardinality(contract_snapshot)
	_check_m2_people_json_order_independence(contract_snapshot)
	_check_m2_people_choice_roundtrip(contract_snapshot)
	_check_m2_people_legacy_resolution(contract_snapshot)
	_check_m2_people_legacy_partial_continuation(contract_snapshot)
	_check_m2_people_chosen_branch(
		contract_snapshot, "hyunsu_player_reachout", 0)
	_check_m2_people_chosen_branch(
		contract_snapshot, "hyunsu_player_reachout", 1)
	_check_m2_people_chosen_branch(
		contract_snapshot, "cafe_world_glimpse", 2)
	DataRegistry.demo_core_loop_v2 = contract_snapshot
	print(
		"ORDER101_M2_PEOPLE_SELECTION_OK "
		+ "eligible=0/1/2 explicit=1 canonical=reversal "
		+ "mutation=fail_closed save=double/normalize legacy=preserved "
		+ "legacy_partial=continued/double_reload "
		+ "branch=three_outcomes/receipt/relationship/next/reload")


func _check_order101_m2_people_terminal_source_receipts() -> void:
	var contract_snapshot: Dictionary = DataRegistry.demo_core_loop_v2.duplicate(
		true)
	_check_m2_people_completed_terminal_source(
		contract_snapshot, "hyunsu_player_reachout", 0)
	_check_m2_people_completed_terminal_source(
		contract_snapshot, "hyunsu_player_reachout", 1)
	var cafe_source_save := _check_m2_people_completed_terminal_source(
		contract_snapshot, "cafe_world_glimpse", 2)
	_check_order101_cafe_jiyeon_m4_union(
		contract_snapshot, cafe_source_save)
	_check_m2_people_expired_terminal_source(contract_snapshot, "")
	_check_m2_people_expired_terminal_source(
		contract_snapshot, "hyunsu_player_reachout")
	_check_m2_people_expired_terminal_source(
		contract_snapshot, "cafe_world_glimpse")
	DataRegistry.demo_core_loop_v2 = contract_snapshot


func _check_order101_m2_people_expiry_target_initialization() -> void:
	var contract_snapshot: Dictionary = DataRegistry.demo_core_loop_v2.duplicate(
		true)
	var route_id := "m2_people_expired_to_m3_contact_fail_forward"
	var terminal_id := "terminal:%s" % route_id
	var initialized := _prepare_m2_people_fixture(
		contract_snapshot,
		["hyunsu_player_reachout", "cafe_world_glimpse"], false)
	if initialized.is_empty():
		DataRegistry.demo_core_loop_v2 = contract_snapshot
		return
	for turn in range(5, 9):
		var snapshot := CORE.seoul_cycle_snapshot(2)
		var node_id := "m2_advancement" if turn == 5 else "m2_self"
		var capacity_id := _unused_capacity(snapshot, 0, turn == 6)
		var committed := CORE.commit_seoul_cycle_allocation(
			capacity_id, node_id, 2)
		var expected_self_completion := turn == 6
		var expected_self_repeat := turn in [7, 8]
		_expect(bool(committed.get("ok", false)) \
			and bool(committed.get("completed_now", false)) \
				== expected_self_completion \
			and bool(committed.get("repeat_allocation", false)) \
				== expected_self_repeat,
			"terminal-only M3 filler ownership drifted at W%d" % turn)
		if not bool(committed.get("ok", false)):
			DataRegistry.demo_core_loop_v2 = contract_snapshot
			return
		if expected_self_completion \
				and not _resolve_cycle_recovery_trigger(
					"m2_sleep_debt_sunday"):
			DataRegistry.demo_core_loop_v2 = contract_snapshot
			return
		var closed := CORE.complete_seoul_cycle_turn(2)
		_expect(bool(closed.get("ok", false)),
			"terminal-only M3 fixture could not close W%d" % turn)
		if not bool(closed.get("ok", false)):
			DataRegistry.demo_core_loop_v2 = contract_snapshot
			return
		if turn < 8:
			_advance_to_next_week()
	var summary := CORE.record_month_summary(2, {}, {})
	var receipt := CORE.terminal_transition_receipt(route_id)
	var state: Dictionary = GameState.core_loop_v2_state
	_expect(not summary.is_empty() and not receipt.is_empty() \
		and not (state.get("completed_bundles", []) as Array).has(
			"m2_rain_delivery_shift") \
		and not (state.get("completed_bundles", []) as Array).has(
			"hyunsu_player_reachout") \
		and not (state.get("completed_bundles", []) as Array).has(
			"cafe_world_glimpse"),
		"terminal-only M3 fixture fabricated an ordinary people prerequisite")
	if summary.is_empty() or receipt.is_empty():
		DataRegistry.demo_core_loop_v2 = contract_snapshot
		return
	_advance_to_next_week()
	var month_three := CORE.initialize_seoul_cycle(3)
	var target_snapshot := CORE.seoul_cycle_snapshot(3)
	var node: Dictionary = (
		target_snapshot.get("nodes", {}) as Dictionary).get("m3_people", {})
	var candidates := CORE.terminal_target_candidates(3, "m3_people")
	var candidate: Dictionary = candidates[0] as Dictionary \
		if candidates.size() == 1 and candidates[0] is Dictionary else {}
	var target_state: Dictionary = GameState.core_loop_v2_state
	var target_cycle: Dictionary = target_state.get("seoul_cycle", {})
	var target_plan: Dictionary = (
		target_state.get("plans", {}) as Dictionary).get("3", {})
	var expected_candidate_set := {
		"ordinary_candidate_ids": [],
		"binding_candidate_ids": [terminal_id],
	}
	var target_witnesses: Dictionary = target_state.get(
		"terminal_target_binding_receipts", {})
	var people_witness: Dictionary = target_witnesses.get("3:m3_people", {})
	var people_eligibility: Dictionary = people_witness.get(
		"ordinary_eligibility", {})
	_expect(bool(month_three.get("ok", false)) \
		and not bool(month_three.get("resumed", true)) \
		and bool(target_snapshot.get("active", false)) \
		and _m2_candidate_ids(candidates) == [terminal_id] \
		and _sorted_strings(node.get("binding_candidate_ids", [])) \
			== [terminal_id] \
		and _sorted_strings(node.get("eligible_terminal_route_ids", [])) \
			== [route_id] \
		and str(node.get("selected_trigger_candidate_id", "")) \
			== terminal_id \
		and str(node.get("selected_terminal_route_id", "")) == route_id \
		and str(node.get("terminal_selection_origin", "")) \
			== "terminal_auto" \
		and str(node.get("selected_trigger_bundle_id", "")).is_empty() \
		and str(node.get("trigger_bundle", "")).is_empty() \
		and str(node.get("summary_bundle", "")).is_empty() \
		and str(node.get("status", "")) == "open" \
		and str(node.get("owner", "")) == "people" \
		and str(node.get("commitment_action_id", "")) == "contact" \
		and str(node.get("axis", "")) == "human" \
		and str(candidate.get("kind", "")) == "terminal" \
		and str(candidate.get("bundle_id", "")).is_empty() \
		and str(candidate.get("route_id", "")) == route_id \
		and str(candidate.get("variant_id", "")) \
			== "contact_fail_forward" \
		and node.get("ordinary_candidate_ids", []) == [] \
		and int(target_cycle.get("terminal_binding_schema", 0)) \
			== CORE.TERMINAL_TARGET_BINDING_SCHEMA \
		and target_cycle.get("terminal_bound_node_ids", []) == ["m3_people"] \
		and int(target_plan.get("terminal_binding_schema", 0)) \
			== CORE.TERMINAL_TARGET_BINDING_SCHEMA \
		and target_plan.get("terminal_bound_node_ids", []) == ["m3_people"] \
		and (target_plan.get(
			"terminal_binding_candidate_sets", {}) as Dictionary).get(
				"m3_people", {}) == expected_candidate_set \
		and _sorted_strings(people_witness.keys()) == [
			"binding_candidate_ids", "ordinary_candidate_ids",
			"ordinary_eligibility", "schema", "target_month", "target_node",
			"terminal_route_bindings",
		] \
		and people_eligibility == {
			"schema": CORE.TERMINAL_TARGET_BINDING_SCHEMA,
			"cut_turn": 9,
			"eligible_authored_candidate_ids": [],
		} \
		and CORE.terminal_transition_receipt(route_id) == receipt \
		and CORE.terminal_transition_resolution(route_id).is_empty(),
		"M2 people expiry did not expose one executable empty M3 target")
	var saved: Dictionary = GameState.serialize().duplicate(true)
	for reload_index in range(2):
		GameState.start_new_game()
		GameState.load_from_dict(saved.duplicate(true))
		CORE.initialize_for_run(true)
		var reloaded := CORE.seoul_cycle_snapshot(3)
		var reloaded_node: Dictionary = (
			reloaded.get("nodes", {}) as Dictionary).get("m3_people", {})
		_expect(bool(reloaded.get("active", false)) \
			and _m2_candidate_ids(CORE.terminal_target_candidates(
				3, "m3_people")) == [terminal_id] \
			and str(reloaded_node.get("selected_trigger_candidate_id", "")) \
				== terminal_id \
			and str(reloaded_node.get("commitment_action_id", "")) \
				== "contact" \
			and str(reloaded_node.get("axis", "")) == "human" \
			and CORE.terminal_transition_receipt(route_id) == receipt,
			"empty M3 target drifted on reload %d" % [reload_index + 1])
		saved = GameState.serialize().duplicate(true)
	_check_terminal_m3_coupled_candidate_add_rejected(
		saved, route_id, terminal_id)
	_check_terminal_m3_fake_routine_authority_rejected(
		saved, receipt, route_id, terminal_id)
	_check_terminal_m3_fake_relationship_authority_rejected(
		saved, receipt, route_id)
	_check_terminal_m3_late_eligibility_does_not_expand(
		saved, receipt, route_id, terminal_id)
	DataRegistry.demo_core_loop_v2 = contract_snapshot


func _check_terminal_m3_coupled_candidate_add_rejected(
		initialized_save: Dictionary, route_id: String,
		terminal_id: String) -> void:
	var malformed := initialized_save.duplicate(true)
	var state: Dictionary = malformed.get("core_loop_v2_state", {})
	var cycle: Dictionary = state.get("seoul_cycle", {})
	var nodes: Dictionary = cycle.get("nodes", {})
	var current_node: Dictionary = nodes.get("m3_people", {})
	var bindings: Dictionary = (
		current_node.get("terminal_route_bindings", {}) as Dictionary).duplicate(
			true)
	var route_ids: Array = (
		current_node.get("eligible_terminal_route_ids", []) as Array).duplicate()
	var node_spec: Dictionary = (
		(CORE.seoul_cycle_month_spec(3).get("nodes", {}) as Dictionary).get(
			"m3_people", {}) as Dictionary).duplicate(true)
	var added_id := "daeun_world_meet"
	var expanded_candidates := [added_id, terminal_id]
	node_spec["id"] = "m3_people"
	node_spec["progress"] = 0
	node_spec["completed_turn"] = 0
	node_spec["last_allocation_turn"] = 0
	node_spec["binding_candidate_ids"] = expanded_candidates
	node_spec["ordinary_candidate_ids"] = [added_id]
	node_spec["eligible_terminal_route_ids"] = route_ids
	node_spec["terminal_route_bindings"] = bindings
	node_spec["trigger_bundle"] = ""
	node_spec["summary_bundle"] = ""
	node_spec["selected_trigger_bundle_id"] = ""
	node_spec["selected_trigger_candidate_id"] = ""
	node_spec["selected_terminal_route_id"] = ""
	node_spec["terminal_selection_origin"] = "unselected_union"
	node_spec["terminal_result_ko"] = ""
	node_spec["terminal_result_en"] = ""
	node_spec["terminal_completion_effects"] = {}
	node_spec["status"] = "open"
	nodes["m3_people"] = node_spec
	cycle["nodes"] = nodes
	state["seoul_cycle"] = cycle

	var plans: Dictionary = state.get("plans", {})
	var plan: Dictionary = plans.get("3", {})
	var candidate_sets: Dictionary = plan.get(
		"terminal_binding_candidate_sets", {})
	candidate_sets["m3_people"] = {
		"ordinary_candidate_ids": [added_id],
		"binding_candidate_ids": expanded_candidates,
	}
	plan["terminal_binding_candidate_sets"] = candidate_sets
	plans["3"] = plan
	state["plans"] = plans
	var witnesses: Dictionary = state.get(
		"terminal_target_binding_receipts", {})
	var witness: Dictionary = witnesses.get("3:m3_people", {})
	var preserved_eligibility: Dictionary = witness.get(
		"ordinary_eligibility", {})
	_expect(preserved_eligibility == {
		"schema": CORE.TERMINAL_TARGET_BINDING_SCHEMA,
		"cut_turn": 9,
		"eligible_authored_candidate_ids": [],
	}, "triple-add fixture was not historically ineligible for Daeun")
	if preserved_eligibility.is_empty():
		return
	witness["ordinary_candidate_ids"] = [added_id]
	witness["binding_candidate_ids"] = expanded_candidates
	_expect(witness.get("ordinary_eligibility", {}) == preserved_eligibility,
		"triple-add attack accidentally changed eligibility authority")
	witnesses["3:m3_people"] = witness
	state["terminal_target_binding_receipts"] = witnesses
	malformed["core_loop_v2_state"] = state

	GameState.start_new_game()
	GameState.load_from_dict(malformed)
	CORE.initialize_for_run(true)
	var before_retry: Dictionary = GameState.serialize().duplicate(true)
	var retried := CORE.initialize_seoul_cycle(3)
	_expect(not bool(CORE.seoul_cycle_snapshot(3).get("active", true)) \
		and CORE.terminal_target_candidates(3, "m3_people").is_empty() \
		and not bool(retried.get("ok", true)) \
		and str(retried.get("error", "")) == "terminal_binding_conflict" \
		and CORE.terminal_transition_resolution(route_id).is_empty() \
		and GameState.serialize() == before_retry,
		"triple-coupled M3 candidate addition escaped historical eligibility")


func _check_terminal_m3_fake_routine_authority_rejected(
		initialized_save: Dictionary, source_receipt: Dictionary,
		route_id: String, terminal_id: String) -> void:
	var malformed := initialized_save.duplicate(true)
	var state: Dictionary = malformed.get("core_loop_v2_state", {})
	var summaries: Dictionary = state.get("month_summaries", {})
	var month_two: Dictionary = summaries.get("2", {})
	var original_summary: Dictionary = month_two.duplicate(true)
	var allocations: Array = month_two.get("allocation_receipts", [])
	var forged_allocation := {"node_id": "m2_livelihood"}
	allocations.append(forged_allocation)
	month_two["allocation_receipts"] = allocations
	summaries["2"] = month_two
	state["month_summaries"] = summaries
	var terminal_receipts: Dictionary = state.get(
		"terminal_transition_receipts", {})
	_expect(terminal_receipts.get(route_id, {}) == source_receipt \
		and (original_summary.get("allocation_receipts", []) as Array).size() + 1 \
			== allocations.size() \
		and allocations.back() == forged_allocation \
		and not (original_summary.get(
			"allocation_receipts", []) as Array).has(forged_allocation),
		"fake-routine attack changed the terminal source or was vacuous")
	var source_only: Dictionary = malformed.duplicate(true)
	source_only["core_loop_v2_state"] = state.duplicate(true)
	_expect_terminal_source_survives_auxiliary_forgery(
		source_only, route_id, source_receipt, "minimal livelihood allocation")

	var cycle: Dictionary = state.get("seoul_cycle", {})
	var nodes: Dictionary = cycle.get("nodes", {})
	var node: Dictionary = nodes.get("m3_people", {})
	var binding_ids: Array[String] = ["daeun_world_meet", terminal_id]
	node["ordinary_candidate_ids"] = ["daeun_world_meet"]
	node["binding_candidate_ids"] = binding_ids
	node["selected_trigger_candidate_id"] = ""
	node["selected_trigger_bundle_id"] = ""
	node["selected_terminal_route_id"] = ""
	node["terminal_selection_origin"] = "unselected_union"
	node["terminal_result_ko"] = ""
	node["terminal_result_en"] = ""
	node["terminal_completion_effects"] = {}
	node["trigger_bundle"] = ""
	node["summary_bundle"] = ""
	node["status"] = "open"
	nodes["m3_people"] = node
	cycle["nodes"] = nodes
	state["seoul_cycle"] = cycle
	var plans: Dictionary = state.get("plans", {})
	var plan: Dictionary = plans.get("3", {})
	var candidate_sets: Dictionary = plan.get(
		"terminal_binding_candidate_sets", {})
	candidate_sets["m3_people"] = {
		"ordinary_candidate_ids": ["daeun_world_meet"],
		"binding_candidate_ids": binding_ids,
	}
	plan["terminal_binding_candidate_sets"] = candidate_sets
	plans["3"] = plan
	state["plans"] = plans
	var witnesses: Dictionary = state.get(
		"terminal_target_binding_receipts", {})
	var witness: Dictionary = witnesses.get("3:m3_people", {})
	witness["ordinary_candidate_ids"] = ["daeun_world_meet"]
	witness["binding_candidate_ids"] = binding_ids
	witness["ordinary_eligibility"] = {
		"schema": CORE.TERMINAL_TARGET_BINDING_SCHEMA,
		"cut_turn": 9,
		"eligible_authored_candidate_ids": ["daeun_world_meet"],
	}
	witnesses["3:m3_people"] = witness
	state["terminal_target_binding_receipts"] = witnesses
	malformed["core_loop_v2_state"] = state

	GameState.start_new_game()
	GameState.load_from_dict(malformed)
	CORE.initialize_for_run(true)
	var before_retry: Dictionary = GameState.serialize().duplicate(true)
	var retried := CORE.initialize_seoul_cycle(3)
	_expect(not bool(CORE.seoul_cycle_snapshot(3).get("active", true)) \
		and CORE.terminal_target_candidates(3, "m3_people").is_empty() \
		and not bool(retried.get("ok", true)) \
		and str(retried.get("error", "")) == "terminal_binding_conflict" \
		and CORE.terminal_transition_resolution(route_id).is_empty() \
		and GameState.serialize() == before_retry,
		"minimal fake livelihood allocation forged historical Daeun eligibility")


func _check_terminal_m3_fake_relationship_authority_rejected(
		initialized_save: Dictionary, source_receipt: Dictionary,
		route_id: String) -> void:
	var malformed := initialized_save.duplicate(true)
	var state: Dictionary = malformed.get("core_loop_v2_state", {})
	var completed: Array = state.get("completed_bundles", [])
	var completed_turns: Dictionary = state.get("completed_bundle_turns", {})
	_expect(not completed.has("father_first_call") \
		and not completed_turns.has("father_first_call") \
		and (state.get("relationship_choice_receipts", {}) as Dictionary) \
			.values().all(func(raw_receipt: Variant) -> bool:
				return not raw_receipt is Dictionary \
					or str((raw_receipt as Dictionary).get(
						"character", "")) != "father"),
		"fake-father fixture already contained an authored father authority")
	completed.append("father_first_call")
	completed_turns["father_first_call"] = 2
	state["completed_bundles"] = completed
	state["completed_bundle_turns"] = completed_turns
	var summaries: Dictionary = state.get("month_summaries", {})
	var month_one: Dictionary = summaries.get("1", {})
	month_one["trigger_receipts"] = {
		"forged_father": {
			"bundle_id": "father_first_call",
			"status": "resolved",
			"turn": 2,
		},
	}
	month_one["world_receipts"] = {}
	summaries["1"] = month_one
	state["month_summaries"] = summaries
	var fake_event := "unauthored_father_call"
	var fake_memory := "unauthored_father_memory"
	var fake_relationship := _terminal_relationship_receipt_fixture(
		"father_first_call", fake_event, 0, 2, "father",
		"unmet", "met", "player", fake_memory)
	var fake_key := str(fake_relationship.get("receipt_key", ""))
	var relationships: Dictionary = state.get(
		"relationship_choice_receipts", {})
	relationships[fake_key] = fake_relationship
	state["relationship_choice_receipts"] = relationships
	for ledger_key in ["relationship_history", "relationship_memories"]:
		var ledger: Array = state.get(ledger_key, [])
		ledger.append(fake_relationship.duplicate(true))
		state[ledger_key] = ledger
	var story_receipts: Dictionary = state.get("story_choice_receipts", {})
	story_receipts[fake_key] = _terminal_story_receipt_fixture(
		"father_first_call", fake_event, 0, 2)
	state["story_choice_receipts"] = story_receipts
	_expect((state.get("terminal_transition_receipts", {}) as Dictionary).get(
		route_id, {}) == source_receipt \
		and relationships.get(fake_key, {}) == fake_relationship \
		and (state.get("relationship_history", []) as Array).count(
			fake_relationship) == 1 \
		and (state.get("relationship_memories", []) as Array).count(
			fake_relationship) == 1 \
		and story_receipts.has(fake_key),
		"fake-father attack changed its terminal source or lacked a full quartet")
	var source_only: Dictionary = malformed.duplicate(true)
	source_only["core_loop_v2_state"] = state.duplicate(true)
	_expect_terminal_source_survives_auxiliary_forgery(
		source_only, route_id, source_receipt,
		"self-consistent unauthored father chain")
	if not _inject_terminal_ordinary_candidate_across_target_surfaces(
			state, 3, "m3_people", "father_quiet_call"):
		_expect(false, "fake-father attack could not expand all target surfaces")
		return
	malformed["core_loop_v2_state"] = state
	GameState.start_new_game()
	GameState.load_from_dict(malformed)
	CORE.initialize_for_run(true)
	var before_retry: Dictionary = GameState.serialize().duplicate(true)
	var retried := CORE.initialize_seoul_cycle(3)
	_expect(not bool(CORE.seoul_cycle_snapshot(3).get("active", true)) \
		and CORE.terminal_target_candidates(3, "m3_people").is_empty() \
		and not bool(retried.get("ok", true)) \
		and str(retried.get("error", "")) == "terminal_binding_conflict" \
		and CORE.terminal_transition_resolution(route_id).is_empty() \
		and GameState.serialize() == before_retry,
		"self-consistent unauthored father chain forged M3 eligibility")


func _inject_terminal_ordinary_candidate_across_target_surfaces(
		state: Dictionary, target_month: int,
		target_node: String, added_id: String) -> bool:
	var cycle: Dictionary = state.get("seoul_cycle", {})
	var nodes: Dictionary = cycle.get("nodes", {})
	var current: Dictionary = nodes.get(target_node, {})
	var raw_bindings: Variant = current.get("terminal_route_bindings", {})
	var raw_routes: Variant = current.get("eligible_terminal_route_ids", [])
	if not raw_bindings is Dictionary or (raw_bindings as Dictionary).is_empty() \
			or not raw_routes is Array or (raw_routes as Array).is_empty():
		return false
	var ordinary_ids: Array[String] = []
	ordinary_ids.assign(current.get("ordinary_candidate_ids", []))
	if ordinary_ids.has(added_id):
		return false
	ordinary_ids.append(added_id)
	ordinary_ids.sort()
	var candidate_ids: Array[String] = ordinary_ids.duplicate()
	for raw_route_id in raw_routes as Array:
		candidate_ids.append("terminal:%s" % str(raw_route_id))
	candidate_ids.sort()
	var raw_node_spec: Variant = (
		CORE.seoul_cycle_month_spec(target_month).get(
			"nodes", {}) as Dictionary).get(target_node, {})
	if not raw_node_spec is Dictionary:
		return false
	var node: Dictionary = (raw_node_spec as Dictionary).duplicate(true)
	node["id"] = target_node
	node["progress"] = 0
	node["completed_turn"] = 0
	node["last_allocation_turn"] = 0
	node["binding_candidate_ids"] = candidate_ids
	node["ordinary_candidate_ids"] = ordinary_ids
	node["eligible_terminal_route_ids"] = (raw_routes as Array).duplicate()
	node["terminal_route_bindings"] = (
		(raw_bindings as Dictionary).duplicate(true))
	node["trigger_bundle"] = ""
	node["summary_bundle"] = ""
	node["selected_trigger_bundle_id"] = ""
	node["selected_trigger_candidate_id"] = ""
	node["selected_terminal_route_id"] = ""
	node["terminal_selection_origin"] = "unselected_union"
	node["terminal_result_ko"] = ""
	node["terminal_result_en"] = ""
	node["terminal_completion_effects"] = {}
	node["status"] = "open"
	nodes[target_node] = node
	cycle["nodes"] = nodes
	state["seoul_cycle"] = cycle
	var plans: Dictionary = state.get("plans", {})
	var plan: Dictionary = plans.get(str(target_month), {})
	var candidate_sets: Dictionary = plan.get(
		"terminal_binding_candidate_sets", {})
	candidate_sets[target_node] = {
		"ordinary_candidate_ids": ordinary_ids.duplicate(),
		"binding_candidate_ids": candidate_ids.duplicate(),
	}
	plan["terminal_binding_candidate_sets"] = candidate_sets
	plans[str(target_month)] = plan
	state["plans"] = plans
	var witnesses: Dictionary = state.get(
		"terminal_target_binding_receipts", {})
	var witness_key := "%d:%s" % [target_month, target_node]
	var witness: Dictionary = witnesses.get(witness_key, {})
	var eligibility: Dictionary = witness.get("ordinary_eligibility", {})
	var eligible_ids: Array[String] = []
	eligible_ids.assign(eligibility.get("eligible_authored_candidate_ids", []))
	if eligible_ids.has(added_id):
		return false
	eligible_ids.append(added_id)
	eligible_ids.sort()
	eligibility["eligible_authored_candidate_ids"] = eligible_ids
	witness["ordinary_candidate_ids"] = ordinary_ids.duplicate()
	witness["binding_candidate_ids"] = candidate_ids.duplicate()
	witness["ordinary_eligibility"] = eligibility
	witnesses[witness_key] = witness
	state["terminal_target_binding_receipts"] = witnesses
	return true


func _expect_terminal_source_survives_auxiliary_forgery(
		source_only_save: Dictionary, route_id: String,
		source_receipt: Dictionary, fixture_name: String) -> void:
	GameState.start_new_game()
	GameState.load_from_dict(source_only_save.duplicate(true))
	CORE.initialize_for_run(true)
	_expect(CORE.terminal_transition_receipt(route_id) == source_receipt,
		"%s unexpectedly invalidated the independent terminal source" \
			% fixture_name)


func _check_terminal_m3_late_eligibility_does_not_expand(
		initialized_save: Dictionary, source_receipt: Dictionary,
		route_id: String, terminal_id: String) -> void:
	GameState.start_new_game()
	GameState.load_from_dict(initialized_save.duplicate(true))
	CORE.initialize_for_run(true)
	var snapshot := CORE.seoul_cycle_snapshot(3)
	var capacity_id := _unused_capacity(snapshot, 0, false)
	var committed := CORE.commit_seoul_cycle_allocation(
		capacity_id, "m3_livelihood", 3)
	_expect(bool(committed.get("ok", false)) \
		and _m2_candidate_ids(CORE.terminal_target_candidates(
			3, "m3_people")) == [terminal_id],
		"same-month livelihood fact expanded a frozen M3 candidate set")
	if not bool(committed.get("ok", false)):
		return
	var saved_after_fact: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(saved_after_fact.duplicate(true))
	CORE.initialize_for_run(true)
	_expect(_m2_candidate_ids(CORE.terminal_target_candidates(
		3, "m3_people")) == [terminal_id] \
		and CORE.terminal_transition_receipt(route_id) == source_receipt \
		and CORE.terminal_transition_resolution(route_id).is_empty(),
		"frozen M3 eligibility expanded after same-month fact reload")


func _check_m2_people_completed_terminal_source(
		contract_snapshot: Dictionary, selected_id: String,
		story_choice_index: int) -> Dictionary:
	var hyunsu_id := "hyunsu_player_reachout"
	var cafe_id := "cafe_world_glimpse"
	var sibling_id := cafe_id if selected_id == hyunsu_id else hyunsu_id
	var route_id := (
		"m2_people_completed_hyunsu_to_m3_followup"
		if selected_id == hyunsu_id
		else "m2_people_completed_cafe_to_m4_sangchul")
	var expected_turn := 5 if selected_id == hyunsu_id else 6
	var initialized := _prepare_m2_people_fixture(
		contract_snapshot, [hyunsu_id, cafe_id], true)
	var selected_commit: Dictionary = {}
	for turn in range(5, 9):
		var snapshot := CORE.seoul_cycle_snapshot(2)
		if turn == expected_turn:
			var capacity_id := _unused_capacity(snapshot, 3, true)
			selected_commit = CORE.commit_seoul_cycle_allocation(
				capacity_id, "m2_people", 2, selected_id)
			_expect(bool(selected_commit.get("ok", false)) \
				and bool(selected_commit.get("completed_now", false)),
				"%s did not complete from actual M2 capacity at W%d" % [
					selected_id, turn])
			if not _resolve_m2_people_selected_story(
					selected_id, story_choice_index):
				return {}
		elif not _commit_m2_terminal_filler():
			return {}
		if not bool(CORE.complete_seoul_cycle_turn(2).get("ok", false)):
			_expect(false, "%s source could not close W%d" % [
				selected_id, turn])
			return {}
		if turn < 8:
			_advance_to_next_week()
	var summary := CORE.record_month_summary(2, {}, {})
	var receipt := CORE.terminal_transition_receipt(route_id)
	var proof: Dictionary = receipt.get("source_proof", {})
	var node: Dictionary = proof.get("node_state", {})
	var allocation: Dictionary = proof.get("allocation_receipt", {})
	var weekly: Dictionary = allocation.get("weekly_commitment", {})
	var weekly_details: Dictionary = weekly.get("details", {})
	var trigger: Dictionary = proof.get("trigger_receipt", {})
	var relationship: Dictionary = proof.get("relationship_receipt", {})
	var expected_memory := (
		"hyunsu_resume_shared" if story_choice_index == 0
		else "hyunsu_problem_set_shared") if selected_id == hyunsu_id else ""
	var sibling_memory := (
		"hyunsu_problem_set_shared" if story_choice_index == 0
		else "hyunsu_resume_shared") if selected_id == hyunsu_id else ""
	var state: Dictionary = GameState.core_loop_v2_state
	var completed: Array = state.get("completed_bundles", [])
	var completed_turns: Dictionary = state.get("completed_bundle_turns", {})
	_expect(not initialized.is_empty() and not summary.is_empty() \
		and str(receipt.get("route_id", "")) == route_id \
		and int(receipt.get("source_month", 0)) == 2 \
		and str(receipt.get("source_node", "")) == "m2_people" \
		and str(receipt.get("source_terminal", "")) == "completed" \
		and int(receipt.get("source_turn", 0)) == expected_turn \
		and str(receipt.get("proof_kind", "")) == "selected_trigger" \
		and str(receipt.get("proof_id", "")) \
			== "m2:m2_people:%s" % selected_id \
		and str(node.get("status", "")) == "completed" \
		and int(node.get("completed_turn", 0)) == expected_turn \
		and str(node.get("selected_trigger_bundle_id", "")) == selected_id \
		and str(node.get("trigger_bundle", "")) == selected_id \
		and str(node.get("summary_bundle", "")) == selected_id \
		and bool(allocation.get("completed_now", false)) \
		and int(allocation.get("turn", 0)) == expected_turn \
		and str(allocation.get("node_id", "")) == "m2_people" \
		and str(allocation.get("selected_trigger_bundle_id", "")) \
			== selected_id \
		and str(allocation.get("trigger_bundle", "")) == selected_id \
		and str(weekly_details.get("selected_trigger_bundle_id", "")) \
			== selected_id \
		and str(trigger.get("status", "")) == "resolved" \
		and str(trigger.get("bundle_id", "")) == selected_id \
		and str(trigger.get("selected_trigger_bundle_id", "")) \
			== selected_id \
		and int(proof.get("completed_bundle_turn", 0)) == expected_turn \
		and completed.count(selected_id) == 1 \
		and not completed.has(sibling_id) \
		and int(completed_turns.get(selected_id, 0)) == expected_turn \
		and not completed_turns.has(sibling_id),
		"%s terminal receipt did not copy its exact selected M2 producer" \
			% selected_id)
	if selected_id == hyunsu_id:
		_expect(str(relationship.get("bundle_id", "")) == selected_id \
			and str(relationship.get("event_id", "")) \
				== "v2_hyunsu_first_study" \
			and int(relationship.get("choice_index", -1)) \
				== story_choice_index \
			and int(relationship.get("turn", 0)) == expected_turn \
			and str(relationship.get("memory", "")) == expected_memory \
			and _m2_relationship_receipt_count(
				selected_id, expected_memory, expected_turn) == 1 \
			and _m2_relationship_receipt_count(
				selected_id, sibling_memory, expected_turn) == 0,
			"Hyunsu outcome %d did not stay exact and exclusive" \
				% story_choice_index)
	else:
		_expect(not proof.has("relationship_receipt") \
			and not proof.has("relationship_receipt_key") \
			and _m2_relationship_bundle_count(hyunsu_id) == 0,
			"Cafe terminal source fabricated a Hyunsu relationship outcome")
	var source_saved: Dictionary = GameState.serialize().duplicate(true)
	_check_m2_terminal_receipt_repeat_and_reload(route_id, receipt, summary)
	_check_m2_selected_terminal_mutations(
		source_saved, route_id, receipt, selected_id,
		expected_turn, story_choice_index)
	if selected_id == hyunsu_id and story_choice_index == 0:
		_check_terminal_long_horizon_retention(
			source_saved, route_id, receipt, expected_turn)
	elif selected_id == cafe_id:
		_check_terminal_m4_fake_completed_authority_rejected(
			source_saved, route_id, receipt)
	return source_saved


func _check_order101_cafe_jiyeon_m4_union(
		contract_snapshot: Dictionary, cafe_source_save: Dictionary) -> void:
	var cafe_route := "m2_people_completed_cafe_to_m4_sangchul"
	var terminal_id := "terminal:%s" % cafe_route
	_expect(not cafe_source_save.is_empty(),
		"Cafe-to-M4 fixture did not preserve its actual M2 source save")
	if cafe_source_save.is_empty():
		return
	DataRegistry.demo_core_loop_v2 = contract_snapshot.duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(cafe_source_save.duplicate(true))
	CORE.initialize_for_run(true)
	var cafe_receipt := CORE.terminal_transition_receipt(cafe_route)
	var source_state: Dictionary = GameState.core_loop_v2_state
	var source_summary: Dictionary = (
		source_state.get("month_summaries", {}) as Dictionary).get("2", {})
	var source_nodes: Dictionary = source_summary.get("node_states", {})
	var source_livelihood: Dictionary = source_nodes.get("m2_livelihood", {})
	_expect(not cafe_receipt.is_empty() \
		and str(source_livelihood.get("status", "")) == "completed" \
		and int(source_livelihood.get("completed_turn", 0)) in range(5, 9) \
		and (source_state.get("completed_bundles", []) as Array).count(
			"m2_rain_delivery_shift") == 1,
		"Cafe-to-M4 fixture lacked its actual M2 livelihood prerequisite")
	if cafe_receipt.is_empty() \
			or str(source_livelihood.get("status", "")) != "completed":
		return

	_advance_to_next_week()
	var month_three := CORE.initialize_seoul_cycle(3)
	var month_three_snapshot := CORE.seoul_cycle_snapshot(3)
	var m3_people: Dictionary = (
		month_three_snapshot.get("nodes", {}) as Dictionary).get(
			"m3_people", {})
	_expect(bool(month_three.get("ok", false)) \
		and bool(month_three_snapshot.get("active", false)) \
		and str(m3_people.get("status", "")) == "open" \
		and str(m3_people.get("trigger_bundle", "")) == "jiyeon_world_meet" \
		and str(m3_people.get("summary_bundle", "")) == "jiyeon_world_meet" \
		and str(m3_people.get("owner", "")) == "jiyeon" \
		and CORE.terminal_transition_receipt(cafe_route) == cafe_receipt,
		"actual M2 livelihood did not auto-resolve the canonical first M3 " \
			+ "people branch")
	if not bool(month_three.get("ok", false)) \
			or str(m3_people.get("trigger_bundle", "")) != "jiyeon_world_meet":
		return

	var w9_capacity := _unused_capacity(month_three_snapshot, 0, false)
	var w9_commit := CORE.commit_seoul_cycle_allocation(
		w9_capacity, "m3_people", 3)
	_expect(bool(w9_commit.get("ok", false)) \
		and not bool(w9_commit.get("completed_now", true)) \
		and int(w9_commit.get("progress_after", 0)) == 1 \
		and str(w9_commit.get("selected_trigger_bundle_id", "")).is_empty() \
		and str(w9_commit.get("trigger_bundle", "")).is_empty(),
		"M3 Jiyeon route did not create its actual pre-window partial allocation")
	if not bool(w9_commit.get("ok", false)) \
			or not bool(CORE.complete_seoul_cycle_turn(3).get("ok", false)):
		_expect(false, "M3 Jiyeon route could not close W9")
		return

	_advance_to_next_week()
	var w10_snapshot := CORE.seoul_cycle_snapshot(3)
	var w10_capacity := _unused_capacity(w10_snapshot, 0, true)
	var w10_commit := CORE.commit_seoul_cycle_allocation(
		w10_capacity, "m3_people", 3)
	var w10_pending: Dictionary = w10_commit.get("pending_trigger", {})
	_expect(bool(w10_commit.get("ok", false)) \
		and bool(w10_commit.get("completed_now", false)) \
		and str(w10_commit.get("selected_trigger_bundle_id", "")).is_empty() \
		and str(w10_commit.get("trigger_bundle", "")) == "jiyeon_world_meet" \
		and str(w10_pending.get("bundle_id", "")) == "jiyeon_world_meet",
		"M3 Jiyeon route did not complete into its authored Story trigger")
	if not bool(w10_commit.get("ok", false)) \
			or not _resolve_order101_jiyeon_world_meet():
		return
	if not bool(CORE.complete_seoul_cycle_turn(3).get("ok", false)):
		_expect(false, "M3 Jiyeon route could not close W10")
		return

	_advance_to_next_week()
	var w11_snapshot := CORE.seoul_cycle_snapshot(3)
	var w11_capacity := _unused_capacity(w11_snapshot, 0, false)
	var w11_commit := CORE.commit_seoul_cycle_allocation(
		w11_capacity, "m3_livelihood", 3)
	_expect(bool(w11_commit.get("ok", false)) \
		and not bool(w11_commit.get("completed_now", true)) \
		and (w11_commit.get("pending_trigger", {}) as Dictionary).is_empty(),
		"M3 union fixture unexpectedly completed its W11 filler")
	if not bool(w11_commit.get("ok", false)) \
			or not bool(CORE.complete_seoul_cycle_turn(3).get("ok", false)):
		_expect(false, "M3 union fixture could not close W11")
		return

	_advance_to_next_week()
	var w12_snapshot := CORE.seoul_cycle_snapshot(3)
	var w12_capacity := _unused_capacity(w12_snapshot, 0, false)
	var w12_commit := CORE.commit_seoul_cycle_allocation(
		w12_capacity, "m3_livelihood", 3)
	_expect(bool(w12_commit.get("ok", false)) \
		and bool(w12_commit.get("fallback_allocation", false)) \
		and (w12_commit.get("pending_trigger", {}) as Dictionary).is_empty(),
		"M3 union fixture did not use the authored livelihood fail-forward at W12")
	if not bool(w12_commit.get("ok", false)) \
			or not bool(CORE.complete_seoul_cycle_turn(3).get("ok", false)):
		_expect(false, "M3 union fixture could not close W12")
		return

	var month_three_summary := CORE.record_month_summary(3, {}, {})
	var completed: Array = GameState.core_loop_v2_state.get(
		"completed_bundles", [])
	var completed_turns: Dictionary = GameState.core_loop_v2_state.get(
		"completed_bundle_turns", {})
	_expect(not month_three_summary.is_empty() \
		and completed.count("jiyeon_world_meet") == 1 \
		and int(completed_turns.get("jiyeon_world_meet", 0)) == 10 \
		and CORE.terminal_transition_receipt(cafe_route) == cafe_receipt,
		"M3 close did not retain exact Jiyeon and delayed Cafe source authority")
	if month_three_summary.is_empty():
		return

	_advance_to_next_week()
	var month_four := CORE.initialize_seoul_cycle(4)
	var m4_snapshot := CORE.seoul_cycle_snapshot(4)
	var m4_people: Dictionary = (
		m4_snapshot.get("nodes", {}) as Dictionary).get("m4_people", {})
	var expected_ids: Array[String] = ["jiyeon_bus_stop_reunion", terminal_id]
	var candidate_ids := _m2_candidate_ids(
		CORE.terminal_target_candidates(4, "m4_people"))
	_expect(bool(month_four.get("ok", false)) \
		and bool(m4_snapshot.get("active", false)) \
		and candidate_ids == expected_ids \
		and m4_people.get("ordinary_candidate_ids", []) \
			== ["jiyeon_bus_stop_reunion"] \
		and _sorted_strings(m4_people.get("binding_candidate_ids", [])) \
			== expected_ids \
		and str(m4_people.get("selected_trigger_candidate_id", "")).is_empty() \
		and str(m4_people.get("selected_terminal_route_id", "")).is_empty() \
		and str(m4_people.get("terminal_selection_origin", "")) \
			== "unselected_union" \
		and str(m4_people.get("trigger_bundle", "")).is_empty() \
		and CORE.terminal_transition_receipt(cafe_route) == cafe_receipt,
		"M4 board did not expose both delayed Sangchul and actual Jiyeon verbs")
	var saved: Dictionary = GameState.serialize().duplicate(true)
	for reload_index in range(2):
		GameState.start_new_game()
		GameState.load_from_dict(saved.duplicate(true))
		CORE.initialize_for_run(true)
		var reloaded_snapshot: Dictionary = CORE.seoul_cycle_snapshot(4)
		var reloaded_ids := _m2_candidate_ids(
			CORE.terminal_target_candidates(4, "m4_people"))
		var reloaded_node: Dictionary = (
			reloaded_snapshot.get("nodes", {}) as Dictionary).get(
				"m4_people", {})
		var reloaded_receipt: Dictionary = CORE.terminal_transition_receipt(
			cafe_route)
		_expect(bool(reloaded_snapshot.get("active", false)) \
			and reloaded_ids == expected_ids \
			and reloaded_node.get("ordinary_candidate_ids", []) \
				== ["jiyeon_bus_stop_reunion"] \
			and str(reloaded_node.get(
				"terminal_selection_origin", "")) == "unselected_union" \
			and reloaded_receipt == cafe_receipt,
			"Cafe+Jiyeon M4 union drifted on reload %d" % [reload_index + 1])
		saved = GameState.serialize().duplicate(true)


func _resolve_order101_jiyeon_world_meet() -> bool:
	var claimed := CORE.claim_seoul_cycle_trigger()
	var began := bool(claimed.get("ok", false)) \
		and CORE.begin_seoul_cycle_trigger("jiyeon_world_meet")
	_expect(began, "M3 Jiyeon Story trigger could not begin")
	if not began:
		return false
	_apply_and_note_story("arc_jiyeon_01_crash", 0)
	var completed := CORE.complete_active_bundle()
	_expect(completed == "jiyeon_world_meet" \
		and CORE.pending_seoul_cycle_trigger().is_empty(),
		"M3 Jiyeon Story did not resolve its exact people branch")
	return completed == "jiyeon_world_meet"


func _check_m2_people_expired_terminal_source(
		contract_snapshot: Dictionary, partial_selected_id: String) -> void:
	var hyunsu_id := "hyunsu_player_reachout"
	var cafe_id := "cafe_world_glimpse"
	var route_id := "m2_people_expired_to_m3_contact_fail_forward"
	var initialized := _prepare_m2_people_fixture(
		contract_snapshot, [hyunsu_id, cafe_id], true)
	var partial_commit: Dictionary = {}
	for turn in range(5, 9):
		var snapshot := CORE.seoul_cycle_snapshot(2)
		if turn == 5 and not partial_selected_id.is_empty():
			var capacity_id := _unused_capacity(snapshot, 1, false)
			partial_commit = CORE.commit_seoul_cycle_allocation(
				capacity_id, "m2_people", 2, partial_selected_id)
			_expect(bool(partial_commit.get("ok", false)) \
				and not bool(partial_commit.get("completed_now", true)) \
				and int(partial_commit.get("progress_after", 0)) == 1,
				"%s expiry fixture did not create one legal partial allocation" \
					% partial_selected_id)
		elif not _commit_m2_terminal_filler():
			return
		if not bool(CORE.complete_seoul_cycle_turn(2).get("ok", false)):
			_expect(false, "M2 people expiry source could not close W%d" % turn)
			return
		if turn < 8:
			_advance_to_next_week()
	var expected_expired_turn := (
		6 if partial_selected_id == hyunsu_id else 7)
	var summary := CORE.record_month_summary(2, {}, {})
	var receipt := CORE.terminal_transition_receipt(route_id)
	var proof: Dictionary = receipt.get("source_proof", {})
	var node: Dictionary = proof.get("node_state", {})
	var expiry: Dictionary = proof.get("expiry_receipt", {})
	var state: Dictionary = GameState.core_loop_v2_state
	var cycle: Dictionary = state.get("seoul_cycle", {})
	var completed: Array = state.get("completed_bundles", [])
	var completed_turns: Dictionary = state.get("completed_bundle_turns", {})
	var selected_allocation_count := 0
	for raw_allocation in (cycle.get("allocation_receipts", {}) \
			as Dictionary).values():
		if raw_allocation is Dictionary \
				and str((raw_allocation as Dictionary).get(
					"node_id", "")) == "m2_people":
			selected_allocation_count += 1
	_expect(not initialized.is_empty() and not summary.is_empty() \
		and str(receipt.get("route_id", "")) == route_id \
		and int(receipt.get("source_month", 0)) == 2 \
		and str(receipt.get("source_node", "")) == "m2_people" \
		and str(receipt.get("source_terminal", "")) == "expired" \
		and int(receipt.get("source_turn", 0)) == expected_expired_turn \
		and str(receipt.get("proof_kind", "")) == "node_expiry" \
		and str(receipt.get("proof_id", "")) == "m2:m2_people" \
		and int(receipt.get("target_month", 0)) == 3 \
		and str(receipt.get("target_node", "")) == "m3_people" \
		and str(receipt.get("target_bundle", "")).is_empty() \
		and str(receipt.get("variant_id", "")) == "contact_fail_forward" \
		and str(node.get("status", "")) == "expired" \
		and int(node.get("expired_turn", 0)) == expected_expired_turn \
		and int(node.get("progress", -1)) \
			== (0 if partial_selected_id.is_empty() else 1) \
		and int(node.get("threshold", 0)) == 2 \
		and str(node.get("selected_trigger_bundle_id", "")) \
			== partial_selected_id \
		and str(node.get("trigger_bundle", "")) == partial_selected_id \
		and str(node.get("summary_bundle", "")) == partial_selected_id \
		and str(expiry.get("node_id", "")) == "m2_people" \
		and str(expiry.get("status", "")) == "consumed" \
		and int(expiry.get("turn", 0)) == expected_expired_turn \
		and int(expiry.get("week_index", 0)) == expected_expired_turn - 4 \
		and str(expiry.get("consequence_id", "")) == "m2_people_expired" \
		and (expiry.get("effects", {}) as Dictionary).is_empty() \
		and selected_allocation_count \
			== (0 if partial_selected_id.is_empty() else 1) \
		and not (cycle.get("trigger_receipts", {}) as Dictionary).has(
			"m2_people") \
		and not completed.has(hyunsu_id) and not completed.has(cafe_id) \
		and not completed_turns.has(hyunsu_id) \
		and not completed_turns.has(cafe_id) \
		and _m2_relationship_bundle_count(hyunsu_id) == 0,
		"M2 people %s expiry invented a completion or lost partial identity" \
			% (partial_selected_id if not partial_selected_id.is_empty() \
				else "zero-allocation"))
	if not partial_selected_id.is_empty():
		var allocation: Dictionary = partial_commit.get("receipt", {})
		var weekly: Dictionary = allocation.get("weekly_commitment", {})
		var details: Dictionary = weekly.get("details", {})
		_expect(not bool(allocation.get("completed_now", true)) \
			and str(allocation.get("selected_trigger_bundle_id", "")) \
				== partial_selected_id \
			and str(allocation.get("trigger_bundle", "")).is_empty() \
			and str(details.get("selected_trigger_bundle_id", "")) \
				== partial_selected_id,
			"partial expiry lost its historical selected allocation identity")
	var source_saved: Dictionary = GameState.serialize().duplicate(true)
	if partial_selected_id.is_empty():
		_check_terminal_source_json_target_roundtrip(
			source_saved, route_id, receipt, 3, "m3_people")
	_check_m2_terminal_receipt_repeat_and_reload(route_id, receipt, summary)
	var forbidden_bundle := (
		partial_selected_id if not partial_selected_id.is_empty()
		else cafe_id)
	var forbidden_event := (
		"v2_hyunsu_first_study"
		if forbidden_bundle == hyunsu_id else "cafe_00")
	_check_terminal_expiry_forbidden_story_rejected(
		source_saved, route_id, forbidden_bundle,
		forbidden_event, 0, 5)
	if partial_selected_id == hyunsu_id:
		_check_m2_summary_only_eligible_mutation(
			source_saved, route_id, receipt, partial_selected_id)
	elif partial_selected_id.is_empty():
		_check_m2_expiry_downgrade_target_conflict(
			source_saved, route_id, receipt)


func _check_m2_expiry_downgrade_target_conflict(
		source_saved: Dictionary, route_id: String,
		frozen_receipt: Dictionary) -> void:
	var malformed: Dictionary = source_saved.duplicate(true)
	var state: Dictionary = malformed.get("core_loop_v2_state", {})
	var cycle: Dictionary = state.get("seoul_cycle", {})
	var cycle_nodes: Dictionary = cycle.get("nodes", {})
	var cycle_node: Dictionary = cycle_nodes.get("m2_people", {})
	var cycle_expiries: Dictionary = cycle.get("expiry_receipts", {})
	var cycle_expired: Array = cycle.get("expired_nodes", [])
	var summaries: Dictionary = state.get("month_summaries", {})
	var summary: Dictionary = summaries.get("2", {})
	var summary_nodes: Dictionary = summary.get("node_states", {})
	var summary_node: Dictionary = summary_nodes.get("m2_people", {})
	var summary_expiries: Dictionary = summary.get("expiry_receipts", {})
	var summary_expired: Array = summary.get("expired_nodes", [])
	_expect(str(cycle_node.get("status", "")) == "expired" \
		and int(cycle_node.get("expired_turn", 0)) == 7 \
		and cycle_expiries.has("m2_people") \
		and cycle_expired.count("m2_people") == 1 \
		and str(summary_node.get("status", "")) == "expired" \
		and int(summary_node.get("expired_turn", 0)) == 7 \
		and summary_expiries.has("m2_people") \
		and summary_expired.count("m2_people") == 1 \
		and (state.get("terminal_transition_receipts", {}) as Dictionary).get(
			route_id, {}) == frozen_receipt,
		"terminal conflict fixture lacked its exact live and summary node expiry")
	cycle_node["status"] = "open"
	cycle_node.erase("expired_turn")
	cycle_nodes["m2_people"] = cycle_node
	cycle_expiries.erase("m2_people")
	while cycle_expired.has("m2_people"):
		cycle_expired.erase("m2_people")
	cycle["nodes"] = cycle_nodes
	cycle["expiry_receipts"] = cycle_expiries
	cycle["expired_nodes"] = cycle_expired
	summary_node["status"] = "open"
	summary_node.erase("expired_turn")
	summary_nodes["m2_people"] = summary_node
	summary_expiries.erase("m2_people")
	while summary_expired.has("m2_people"):
		summary_expired.erase("m2_people")
	var allocations: Array = summary.get("allocation_receipts", [])
	for index in range(allocations.size()):
		if not allocations[index] is Dictionary:
			continue
		var allocation: Dictionary = (
			allocations[index] as Dictionary).duplicate(true)
		var expired_nodes: Array = allocation.get("expired_nodes", [])
		while expired_nodes.has("m2_people"):
			expired_nodes.erase("m2_people")
		allocation["expired_nodes"] = expired_nodes
		allocations[index] = allocation
	summary["node_states"] = summary_nodes
	summary["expiry_receipts"] = summary_expiries
	summary["expired_nodes"] = summary_expired
	summary["allocation_receipts"] = allocations
	summaries["2"] = summary
	state["seoul_cycle"] = cycle
	state["month_summaries"] = summaries
	malformed["core_loop_v2_state"] = state
	GameState.start_new_game()
	GameState.load_from_dict(malformed)
	CORE.initialize_for_run(true)
	_advance_to_next_week()
	var before_init: Dictionary = GameState.serialize().duplicate(true)
	var retried: Dictionary = CORE.initialize_seoul_cycle(3)
	_expect(CORE.terminal_transition_receipt(route_id).is_empty() \
		and CORE.terminal_target_candidates(3, "m3_people").is_empty() \
		and not bool(retried.get("ok", true)) \
		and str(retried.get("error", "")) == "terminal_binding_conflict" \
		and CORE.terminal_transition_resolution(route_id).is_empty() \
		and GameState.serialize() == before_init,
		"coupled source node-expiry downgrade did not fail target init closed")


func _check_terminal_source_json_target_roundtrip(
		source_saved: Dictionary, route_id: String,
		frozen_receipt: Dictionary, target_month: int,
		target_node: String) -> void:
	var parsed: Variant = JSON.parse_string(JSON.stringify(source_saved))
	_expect(parsed is Dictionary,
		"%s source save did not survive whole-save JSON parsing" % route_id)
	if not parsed is Dictionary:
		return
	GameState.start_new_game()
	GameState.load_from_dict(parsed as Dictionary)
	CORE.initialize_for_run(true)
	var json_receipt := CORE.terminal_transition_receipt(route_id)
	var target_turn := (target_month - 1) * 4 + 1
	_expect(int(GameState.turn) == target_turn - 1,
		"%s source calendar drifted on whole-save JSON load" % route_id)
	_expect(not json_receipt.is_empty(),
		"%s source receipt disappeared on whole-save JSON load" % route_id)
	_expect(json_receipt.is_empty() or _variant_equal_with_numeric_values(
		json_receipt, frozen_receipt),
		"%s source receipt fields drifted on whole-save JSON load" % route_id)
	if json_receipt.is_empty() or int(GameState.turn) != target_turn - 1:
		GameState.start_new_game()
		GameState.load_from_dict(source_saved.duplicate(true))
		CORE.initialize_for_run(true)
		return
	_advance_to_next_week()
	var initialized := CORE.initialize_seoul_cycle(target_month)
	var terminal_id := "terminal:%s" % route_id
	var candidates := CORE.terminal_target_candidates(
		target_month, target_node)
	_expect(bool(initialized.get("ok", false)) \
		and bool(CORE.seoul_cycle_snapshot(target_month).get("active", false)) \
		and _m2_candidate_ids(candidates).has(terminal_id) \
		and _variant_equal_with_numeric_values(
			CORE.terminal_transition_receipt(route_id), frozen_receipt) \
		and CORE.terminal_transition_resolution(route_id).is_empty(),
		"%s JSON source did not initialize its actual terminal target" % route_id)
	var target_saved: Dictionary = GameState.serialize().duplicate(true)
	if route_id == "m1_resume_completed_q0_to_m2_advancement_rewritten":
		_check_terminal_summary_only_fractional_turn_rejected(
			target_saved, route_id, target_month, target_node)
		_check_terminal_source_receipt_witness_split_rejected(
			target_saved, route_id, frozen_receipt, target_month, target_node)
	for reload_index in range(2):
		var reload_parsed: Variant = JSON.parse_string(
			JSON.stringify(target_saved))
		_expect(reload_parsed is Dictionary,
			"%s target JSON reload %d could not parse" % [
				route_id, reload_index + 1])
		if not reload_parsed is Dictionary:
			break
		GameState.start_new_game()
		GameState.load_from_dict(reload_parsed as Dictionary)
		CORE.initialize_for_run(true)
		var reload_candidates := CORE.terminal_target_candidates(
			target_month, target_node)
		_expect(bool(CORE.seoul_cycle_snapshot(target_month).get(
			"active", false)) \
			and _m2_candidate_ids(reload_candidates).has(terminal_id) \
			and _variant_equal_with_numeric_values(
				CORE.terminal_transition_receipt(route_id), frozen_receipt) \
			and CORE.terminal_transition_resolution(route_id).is_empty(),
			"%s target drifted on whole-save JSON reload %d" % [
				route_id, reload_index + 1])
		target_saved = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(source_saved.duplicate(true))
	CORE.initialize_for_run(true)


func _check_terminal_source_receipt_witness_split_rejected(
		target_saved: Dictionary, route_id: String,
		frozen_receipt: Dictionary, target_month: int,
		target_node: String) -> void:
	var baseline_state: Dictionary = target_saved.get(
		"core_loop_v2_state", {})
	var baseline_receipts: Dictionary = baseline_state.get(
		"terminal_transition_receipts", {})
	var baseline_summaries: Dictionary = baseline_state.get(
		"month_summaries", {})
	var source_summary: Dictionary = baseline_summaries.get("1", {})
	var source_witnesses: Dictionary = source_summary.get(
		"terminal_source_witnesses", {})
	var frozen_witness: Dictionary = source_witnesses.get(route_id, {})
	_expect(_variant_equal_with_numeric_values(
		baseline_receipts.get(route_id, {}), frozen_receipt) \
		and not frozen_witness.is_empty() \
		and int((baseline_state.get("seoul_cycle", {}) as Dictionary).get(
			"month", 0)) == target_month,
		"source receipt/witness split fixture lacked exact historical authority")
	if frozen_witness.is_empty():
		return
	for mutation in ["root_receipt_delete", "summary_witness_delete"]:
		var malformed := target_saved.duplicate(true)
		var state: Dictionary = malformed.get("core_loop_v2_state", {})
		var receipts: Dictionary = state.get("terminal_transition_receipts", {})
		var summaries: Dictionary = state.get("month_summaries", {})
		var summary: Dictionary = summaries.get("1", {})
		var witnesses: Dictionary = summary.get(
			"terminal_source_witnesses", {})
		if mutation == "root_receipt_delete":
			receipts.erase(route_id)
		else:
			witnesses.erase(route_id)
			summary["terminal_source_witnesses"] = witnesses
			summaries["1"] = summary
		state["terminal_transition_receipts"] = receipts
		state["month_summaries"] = summaries
		malformed["core_loop_v2_state"] = state
		_expect((mutation == "root_receipt_delete" \
				and not receipts.has(route_id) \
				and _variant_equal_with_numeric_values(
					witnesses.get(route_id, {}), frozen_witness)) \
			or (mutation == "summary_witness_delete" \
				and not witnesses.has(route_id) \
				and _variant_equal_with_numeric_values(
					receipts.get(route_id, {}), frozen_receipt)),
			"source receipt/witness split mutation changed both authority copies")

		GameState.start_new_game()
		GameState.load_from_dict(malformed)
		CORE.initialize_for_run(true)
		var before_retry: Dictionary = GameState.serialize().duplicate(true)
		var retried := CORE.initialize_seoul_cycle(target_month)
		_expect(CORE.terminal_transition_receipt(route_id).is_empty() \
			and CORE.terminal_target_candidates(
				target_month, target_node).is_empty() \
			and CORE.terminal_transition_resolution(route_id).is_empty() \
			and not bool(retried.get("ok", true)) \
			and str(retried.get("error", "")) == "terminal_binding_conflict" \
			and GameState.serialize() == before_retry,
			"historical target accepted %s source authority split" % mutation)


func _check_terminal_fractional_scalar_rejected(
		source_saved: Dictionary, route_id: String,
		frozen_receipt: Dictionary) -> void:
	var malformed: Dictionary = source_saved.duplicate(true)
	var state: Dictionary = malformed.get("core_loop_v2_state", {})
	var receipts: Dictionary = state.get("terminal_transition_receipts", {})
	var receipt: Dictionary = receipts.get(route_id, {}).duplicate(true)
	_expect(receipt == frozen_receipt,
		"fractional scalar fixture lost its exact source receipt")
	receipt["source_month"] = 1.5
	receipts[route_id] = receipt
	state["terminal_transition_receipts"] = receipts
	malformed["core_loop_v2_state"] = state
	GameState.start_new_game()
	GameState.load_from_dict(malformed)
	CORE.initialize_for_run(true)
	_expect(CORE.terminal_transition_receipt(route_id).is_empty(),
		"terminal receipt laundered fractional source_month through int coercion")


func _check_terminal_summary_only_fractional_turn_rejected(
		target_saved: Dictionary, route_id: String,
		target_month: int, target_node: String) -> void:
	var malformed: Dictionary = target_saved.duplicate(true)
	var state: Dictionary = malformed.get("core_loop_v2_state", {})
	var cycle: Dictionary = state.get("seoul_cycle", {})
	var receipts: Dictionary = state.get("terminal_transition_receipts", {})
	var receipt: Dictionary = receipts.get(route_id, {}).duplicate(true)
	var receipt_proof: Dictionary = receipt.get("source_proof", {}).duplicate(true)
	var receipt_node: Dictionary = receipt_proof.get(
		"node_state", {}).duplicate(true)
	var summaries: Dictionary = state.get("month_summaries", {})
	var summary: Dictionary = summaries.get("1", {}).duplicate(true)
	var summary_nodes: Dictionary = summary.get("node_states", {}).duplicate(true)
	var summary_node: Dictionary = summary_nodes.get("resume", {}).duplicate(true)
	var witnesses: Dictionary = summary.get(
		"terminal_source_witnesses", {}).duplicate(true)
	var witness: Dictionary = witnesses.get(route_id, {}).duplicate(true)
	var witness_proof: Dictionary = witness.get("source_proof", {}).duplicate(true)
	var witness_node: Dictionary = witness_proof.get(
		"node_state", {}).duplicate(true)
	_expect(int(cycle.get("month", 0)) == target_month \
		and int(receipt_node.get("completed_turn", 0)) == 1 \
		and int(summary_node.get("completed_turn", 0)) == 1 \
		and int(witness_node.get("completed_turn", 0)) == 1,
		"summary-only fractional fixture lacked its three exact completed turns")
	receipt_node["completed_turn"] = 1.5
	receipt_proof["node_state"] = receipt_node
	receipt["source_proof"] = receipt_proof
	receipts[route_id] = receipt
	summary_node["completed_turn"] = 1.5
	summary_nodes["resume"] = summary_node
	summary["node_states"] = summary_nodes
	witness_node["completed_turn"] = 1.5
	witness_proof["node_state"] = witness_node
	witness["source_proof"] = witness_proof
	witnesses[route_id] = witness
	summary["terminal_source_witnesses"] = witnesses
	summaries["1"] = summary
	state["terminal_transition_receipts"] = receipts
	state["month_summaries"] = summaries
	malformed["core_loop_v2_state"] = state
	GameState.start_new_game()
	GameState.load_from_dict(malformed)
	CORE.initialize_for_run(true)
	var before_retry: Dictionary = GameState.serialize().duplicate(true)
	var retried := CORE.initialize_seoul_cycle(target_month)
	_expect(CORE.terminal_transition_receipt(route_id).is_empty() \
		and CORE.terminal_target_candidates(
			target_month, target_node).is_empty() \
		and not bool(retried.get("ok", true)) \
		and str(retried.get("error", "")) == "terminal_binding_conflict" \
		and CORE.terminal_transition_resolution(route_id).is_empty() \
		and GameState.serialize() == before_retry,
		"summary-only coupled fractional completed_turn escaped target conflict")


func _check_terminal_m4_fake_completed_authority_rejected(
		source_saved: Dictionary, route_id: String,
		source_receipt: Dictionary) -> void:
	var initialized_save: Dictionary = source_saved.duplicate(true)
	var source_state: Dictionary = initialized_save.get(
		"core_loop_v2_state", {})
	_expect(not (source_state.get("completed_bundles", []) as Array).has(
		"sns_pressure_night") \
		and not (source_state.get("completed_bundle_turns", {}) as Dictionary).has(
			"sns_pressure_night") \
		and (source_state.get("terminal_transition_receipts", {}) as Dictionary) \
			.get(route_id, {}) == source_receipt,
		"fake-completion fixture already had SNS authority or lost Cafe source")
	GameState.start_new_game()
	GameState.load_from_dict(initialized_save.duplicate(true))
	CORE.initialize_for_run(true)
	GameState.turn = 9
	GameState.month = 3
	GameState.week_of_month = 1
	var month_three := CORE.initialize_seoul_cycle(3)
	_expect(bool(month_three.get("ok", false)),
		"fake-completion fixture could not initialize intervening M3")
	if not bool(month_three.get("ok", false)):
		return
	GameState.turn = 13
	GameState.month = 4
	GameState.week_of_month = 1
	var month_four := CORE.initialize_seoul_cycle(4)
	_expect(bool(month_four.get("ok", false)) \
		and _m2_candidate_ids(CORE.terminal_target_candidates(
			4, "m4_people")).has(
				"terminal:m2_people_completed_cafe_to_m4_sangchul") \
		and not _m2_candidate_ids(CORE.terminal_target_candidates(
			4, "m4_people")).has("jaehyuk_world_meet"),
		"fake-completion fixture did not reach M4 with Jaehyuk absent")
	if not bool(month_four.get("ok", false)):
		return
	var malformed: Dictionary = GameState.serialize().duplicate(true)
	var state: Dictionary = malformed.get("core_loop_v2_state", {})
	var completed: Array = state.get("completed_bundles", [])
	var completed_turns: Dictionary = state.get("completed_bundle_turns", {})
	completed.append("sns_pressure_night")
	completed_turns["sns_pressure_night"] = 6
	state["completed_bundles"] = completed
	state["completed_bundle_turns"] = completed_turns
	var summaries: Dictionary = state.get("month_summaries", {})
	var month_two: Dictionary = summaries.get("2", {})
	var world_receipts: Dictionary = month_two.get("world_receipts", {})
	world_receipts["fake_sns"] = {
		"bundle_id": "sns_pressure_night",
		"status": "resolved",
		"turn": 6,
	}
	month_two["world_receipts"] = world_receipts
	summaries["2"] = month_two
	state["month_summaries"] = summaries
	_expect((state.get("terminal_transition_receipts", {}) as Dictionary).get(
		route_id, {}) == source_receipt \
		and completed.count("sns_pressure_night") == 1 \
		and int(completed_turns.get("sns_pressure_night", 0)) == 6 \
		and world_receipts.has("fake_sns"),
		"fake-completion attack changed Cafe source or lacked forged authority")
	var source_only: Dictionary = malformed.duplicate(true)
	source_only["core_loop_v2_state"] = state.duplicate(true)
	_expect_terminal_source_survives_auxiliary_forgery(
		source_only, route_id, source_receipt, "minimal SNS world completion")
	if not _inject_terminal_ordinary_candidate_across_target_surfaces(
			state, 4, "m4_people", "jaehyuk_world_meet"):
		_expect(false, "fake-completion attack could not expand M4 surfaces")
		return
	malformed["core_loop_v2_state"] = state
	GameState.start_new_game()
	GameState.load_from_dict(malformed)
	CORE.initialize_for_run(true)
	var before_retry: Dictionary = GameState.serialize().duplicate(true)
	var retried := CORE.initialize_seoul_cycle(4)
	_expect(not bool(CORE.seoul_cycle_snapshot(4).get("active", true)) \
		and CORE.terminal_target_candidates(4, "m4_people").is_empty() \
		and not bool(retried.get("ok", true)) \
		and str(retried.get("error", "")) == "terminal_binding_conflict" \
		and CORE.terminal_transition_resolution(route_id).is_empty() \
		and GameState.serialize() == before_retry,
		"minimal fake SNS completion forged historical Jaehyuk eligibility")


func _resolve_m2_people_selected_story(
		selected_id: String, story_choice_index: int) -> bool:
	var claimed := CORE.claim_seoul_cycle_trigger()
	var began := bool(claimed.get("ok", false)) \
		and CORE.begin_seoul_cycle_trigger(selected_id)
	_expect(began, "%s terminal source trigger could not begin" % selected_id)
	if not began:
		return false
	if selected_id == "hyunsu_player_reachout":
		_apply_and_note_story("v2_hyunsu_player_reachout", 0)
		_apply_and_note_story("v2_hyunsu_first_study", story_choice_index)
	else:
		_apply_and_note_story("cafe_00", story_choice_index)
	var completed := CORE.complete_active_bundle()
	_expect(completed == selected_id,
		"%s terminal source Story did not complete exactly" % selected_id)
	return completed == selected_id


func _commit_m2_terminal_filler() -> bool:
	var snapshot := CORE.seoul_cycle_snapshot(2)
	var capacity_id := _unused_capacity(snapshot, 0, true)
	var committed := CORE.commit_seoul_cycle_allocation(
		capacity_id, "m2_livelihood", 2)
	_expect(bool(committed.get("ok", false)),
		"M2 terminal source filler allocation failed")
	if not bool(committed.get("ok", false)):
		return false
	var pending: Dictionary = committed.get("pending_trigger", {})
	if not pending.is_empty():
		_expect(str(pending.get("bundle_id", "")) \
			== "m2_rain_delivery_shift",
			"M2 terminal filler produced an unexpected trigger")
		return _resolve_cycle_side_shift_trigger("m2_rain_delivery_shift")
	return true


func _resolve_cycle_recovery_trigger(bundle_id: String) -> bool:
	var claimed := CORE.claim_seoul_cycle_trigger()
	var began := bool(claimed.get("ok", false)) \
		and CORE.begin_seoul_cycle_trigger(bundle_id)
	var armed := began and GameState.arm_weekly_commitment({
		"turn": int(GameState.turn),
		"pressure_id": bundle_id,
		"pressure_family": "recovery",
		"choice_id": "rest",
		"forgone_ids": [],
		"supplemental_to_seoul_cycle": true,
	})
	var transaction: Dictionary = {}
	if armed:
		transaction = GameState.finalize_weekly_effect_action(
			"rest", {"mental": 10, "health": 3}, "human", "home", "", {
				"execution": "rest",
				"effects": {"mental": 10, "health": 3},
				"diminished_by_recovery_routine": false,
			})
	var action_noted := bool(transaction.get("ok", false)) \
		and CORE.note_action_commitment(
			transaction.get("record", {}) as Dictionary)
	var completed := CORE.complete_active_bundle() if action_noted else ""
	_expect(bool(claimed.get("ok", false)) and began and armed \
		and bool(transaction.get("ok", false)) and action_noted \
		and completed == bundle_id,
		"recovery trigger did not execute its exact supplemental action")
	return completed == bundle_id


func _check_m2_terminal_receipt_repeat_and_reload(
		route_id: String, receipt: Dictionary, summary: Dictionary) -> void:
	var frozen_state: Dictionary = GameState.serialize().duplicate(true)
	_expect(not receipt.is_empty() \
		and CORE.record_month_summary(2, {}, {}) == summary \
		and CORE.terminal_transition_receipt(route_id) == receipt \
		and GameState.serialize() == frozen_state,
		"%s changed on repeated M2 month close" % route_id)
	var saved := frozen_state.duplicate(true)
	for reload_index in range(2):
		GameState.start_new_game()
		GameState.load_from_dict(saved.duplicate(true))
		CORE.initialize_for_run(true)
		_expect(CORE.terminal_transition_receipt(route_id) == receipt,
			"%s drifted on reload %d" % [route_id, reload_index + 1])
		saved = GameState.serialize().duplicate(true)


func _check_m2_selected_terminal_mutations(
		saved: Dictionary, route_id: String, frozen_receipt: Dictionary,
		selected_id: String, source_turn: int,
		story_choice_index: int) -> void:
	var proof: Dictionary = frozen_receipt.get("source_proof", {})
	var story_keys: Array = proof.get("story_choice_receipt_keys", [])
	_expect(not story_keys.is_empty(),
		"%s terminal proof has no canonical Story receipt keys" % selected_id)
	if story_keys.is_empty():
		return
	var missing_own := saved.duplicate(true)
	var missing_state: Dictionary = missing_own.get("core_loop_v2_state", {})
	var own_story_receipts: Dictionary = missing_state.get(
		"story_choice_receipts", {})
	var own_path := str(story_keys.back())
	var own_key := own_path.trim_prefix("story_choice_receipts.")
	own_story_receipts.erase(own_key)
	missing_state["story_choice_receipts"] = own_story_receipts
	missing_own["core_loop_v2_state"] = missing_state
	_assert_terminal_reader_empty_after_load(
		missing_own, route_id,
		"%s terminal receipt survived deletion of its own Story receipt" \
			% selected_id)

	var sibling := saved.duplicate(true)
	var sibling_state: Dictionary = sibling.get("core_loop_v2_state", {})
	var sibling_story: Dictionary = sibling_state.get(
		"story_choice_receipts", {})
	if selected_id == "hyunsu_player_reachout":
		var cafe_story := _terminal_story_receipt_fixture(
			"cafe_world_glimpse", "cafe_00", 0, source_turn)
		sibling_story[str(cafe_story.get("receipt_key", ""))] = cafe_story
	else:
		for event_choice in [
			["v2_hyunsu_player_reachout", 0],
			["v2_hyunsu_first_study", 0],
		]:
			var hyunsu_story := _terminal_story_receipt_fixture(
				"hyunsu_player_reachout", str(event_choice[0]),
				int(event_choice[1]), source_turn)
			sibling_story[str(hyunsu_story.get(
				"receipt_key", ""))] = hyunsu_story
		var sibling_relationship := _terminal_relationship_receipt_fixture(
			"hyunsu_player_reachout", "v2_hyunsu_first_study", 0,
			source_turn, "hyunsu", "opening", "player_reached_out",
			"player", "hyunsu_resume_shared")
		var sibling_relationship_key := str(sibling_relationship.get(
			"receipt_key", ""))
		var relationship_receipts: Dictionary = sibling_state.get(
			"relationship_choice_receipts", {})
		relationship_receipts[sibling_relationship_key] = sibling_relationship
		sibling_state["relationship_choice_receipts"] = relationship_receipts
		for ledger_key in ["relationship_history", "relationship_memories"]:
			var ledger: Array = sibling_state.get(ledger_key, [])
			ledger.append(sibling_relationship.duplicate(true))
			sibling_state[ledger_key] = ledger
	sibling_state["story_choice_receipts"] = sibling_story
	sibling["core_loop_v2_state"] = sibling_state
	_assert_terminal_reader_empty_after_load(
		sibling, route_id,
		"%s terminal receipt accepted a well-shaped sibling Story/relationship " \
			% selected_id + "artifact in the source month")

	if selected_id == "hyunsu_player_reachout":
		_check_hyunsu_coupled_choice_mutation(
			saved, route_id, frozen_receipt, source_turn,
			story_choice_index)


func _check_hyunsu_coupled_choice_mutation(
		saved: Dictionary, route_id: String, frozen_receipt: Dictionary,
		source_turn: int, original_choice: int) -> void:
	var sibling_choice := 1 if original_choice == 0 else 0
	var sibling_memory := (
		"hyunsu_resume_shared" if sibling_choice == 0
		else "hyunsu_problem_set_shared")
	var old_story_key := (
		"hyunsu_player_reachout:v2_hyunsu_first_study:%d:%d" \
		% [original_choice, source_turn])
	var new_story_key := (
		"hyunsu_player_reachout:v2_hyunsu_first_study:%d:%d" \
		% [sibling_choice, source_turn])
	var old_relationship_key := old_story_key
	var new_relationship_key := new_story_key
	var malformed := saved.duplicate(true)
	var state: Dictionary = malformed.get("core_loop_v2_state", {})
	var story_receipts: Dictionary = state.get("story_choice_receipts", {})
	var story: Dictionary = story_receipts.get(old_story_key, {})
	story_receipts.erase(old_story_key)
	story["receipt_key"] = new_story_key
	story["choice_index"] = sibling_choice
	story_receipts[new_story_key] = story
	state["story_choice_receipts"] = story_receipts
	var relationships: Dictionary = state.get(
		"relationship_choice_receipts", {})
	var relationship: Dictionary = relationships.get(old_relationship_key, {})
	relationships.erase(old_relationship_key)
	relationship["receipt_key"] = new_relationship_key
	relationship["choice_index"] = sibling_choice
	relationship["memory"] = sibling_memory
	relationships[new_relationship_key] = relationship
	state["relationship_choice_receipts"] = relationships
	for ledger_key in ["relationship_history", "relationship_memories"]:
		var ledger: Array = state.get(ledger_key, [])
		for index in range(ledger.size()):
			if ledger[index] is Dictionary \
					and str((ledger[index] as Dictionary).get(
						"receipt_key", "")) == old_relationship_key:
				var row: Dictionary = (
					ledger[index] as Dictionary).duplicate(true)
				row["receipt_key"] = new_relationship_key
				row["choice_index"] = sibling_choice
				row["memory"] = sibling_memory
				ledger[index] = row
		state[ledger_key] = ledger
	var terminal_receipts: Dictionary = state.get(
		"terminal_transition_receipts", {})
	var forged := frozen_receipt.duplicate(true)
	var proof: Dictionary = forged.get("source_proof", {})
	var proof_story_keys: Array = proof.get(
		"story_choice_receipt_keys", []).duplicate(true)
	var proof_story_receipts: Array = proof.get(
		"story_choice_receipts", []).duplicate(true)
	for index in range(proof_story_receipts.size()):
		if proof_story_receipts[index] is Dictionary \
				and str((proof_story_receipts[index] as Dictionary).get(
					"event_id", "")) == "v2_hyunsu_first_study":
			var proof_story: Dictionary = (
				proof_story_receipts[index] as Dictionary).duplicate(true)
			proof_story["receipt_key"] = new_story_key
			proof_story["choice_index"] = sibling_choice
			proof_story_receipts[index] = proof_story
			proof_story_keys[index] = "story_choice_receipts.%s" % new_story_key
	proof["story_choice_receipt_keys"] = proof_story_keys
	proof["story_choice_receipts"] = proof_story_receipts
	proof["relationship_receipt_key"] = (
		"relationship_choice_receipts.%s" % new_relationship_key)
	proof["relationship_memory_key"] = (
		"relationship_memories[%s]" % new_relationship_key)
	proof["relationship_receipt"] = relationship.duplicate(true)
	forged["source_proof"] = proof
	terminal_receipts[route_id] = forged
	state["terminal_transition_receipts"] = terminal_receipts
	malformed["core_loop_v2_state"] = state
	_assert_terminal_reader_empty_after_load(
		malformed, route_id,
		"Hyunsu terminal receipt accepted a coupled Story/key/memory choice swap")


func _terminal_story_receipt_fixture(
		bundle_id: String, event_id: String, choice_index: int,
		turn: int) -> Dictionary:
	var receipt_key := "%s:%s:%d:%d" % [
		bundle_id, event_id, choice_index, turn]
	return {
		"receipt_key": receipt_key,
		"bundle_id": bundle_id,
		"active_kind": "schedule",
		"event_id": event_id,
		"choice_index": choice_index,
		"turn": turn,
	}


func _terminal_relationship_receipt_fixture(
		bundle_id: String, event_id: String, choice_index: int, turn: int,
		character: String, from_stage: String, to_stage: String,
		initiative: String, memory: String) -> Dictionary:
	var receipt_key := "%s:%s:%d:%d" % [
		bundle_id, event_id, choice_index, turn]
	return {
		"receipt_key": receipt_key,
		"character": character,
		"from": from_stage,
		"to": to_stage,
		"initiative": initiative,
		"memory": memory,
		"bundle_id": bundle_id,
		"event_id": event_id,
		"choice_index": choice_index,
		"turn": turn,
	}


func _assert_terminal_reader_empty_after_load(
		saved: Dictionary, route_id: String, failure_message: String) -> void:
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	CORE.initialize_for_run(true)
	_expect(CORE.terminal_transition_receipt(route_id).is_empty(),
		failure_message)


func _check_terminal_expiry_forbidden_story_rejected(
		saved: Dictionary, route_id: String, forbidden_bundle: String,
		forbidden_event: String, choice_index: int, turn: int) -> void:
	var malformed := saved.duplicate(true)
	var state: Dictionary = malformed.get("core_loop_v2_state", {})
	var story_receipts: Dictionary = state.get("story_choice_receipts", {})
	var forbidden := _terminal_story_receipt_fixture(
		forbidden_bundle, forbidden_event, choice_index, turn)
	story_receipts[str(forbidden.get("receipt_key", ""))] = forbidden
	state["story_choice_receipts"] = story_receipts
	malformed["core_loop_v2_state"] = state
	_assert_terminal_reader_empty_after_load(
		malformed, route_id,
		"%s expiry receipt accepted forbidden completed-branch Story %s" % [
			route_id, forbidden_bundle])


func _check_m2_summary_only_eligible_mutation(
		saved: Dictionary, route_id: String, frozen_receipt: Dictionary,
		selected_id: String) -> void:
	GameState.start_new_game()
	GameState.load_from_dict(saved.duplicate(true))
	CORE.initialize_for_run(true)
	GameState.turn = 9
	GameState.month = 3
	GameState.week_of_month = 1
	var month_three := CORE.initialize_seoul_cycle(3)
	var summary_only: Dictionary = GameState.serialize().duplicate(true)
	_expect(bool(month_three.get("ok", false)) \
		and int((GameState.core_loop_v2_state.get(
			"seoul_cycle", {}) as Dictionary).get("month", 0)) == 3 \
		and CORE.terminal_transition_receipt(route_id) == frozen_receipt,
		"M2 partial-expiry receipt did not survive actual M3 replacement")
	if not bool(month_three.get("ok", false)):
		return
	for reload_index in range(2):
		GameState.start_new_game()
		GameState.load_from_dict(summary_only.duplicate(true))
		CORE.initialize_for_run(true)
		_expect(CORE.terminal_transition_receipt(route_id) == frozen_receipt,
			"M2 summary-only receipt drifted on reload %d" \
				% [reload_index + 1])
		summary_only = GameState.serialize().duplicate(true)
	var malformed := summary_only.duplicate(true)
	var state: Dictionary = malformed.get("core_loop_v2_state", {})
	var terminal_receipts: Dictionary = state.get(
		"terminal_transition_receipts", {})
	var forged: Dictionary = terminal_receipts.get(route_id, {}).duplicate(true)
	var proof: Dictionary = forged.get("source_proof", {})
	var proof_node: Dictionary = proof.get("node_state", {})
	var original_eligible: Array = proof_node.get(
		"eligible_trigger_bundle_ids", [])
	_expect(original_eligible.size() == 2 \
		and original_eligible.has(selected_id),
		"M2 summary-only fixture did not preserve both authored candidates")
	proof_node["eligible_trigger_bundle_ids"] = [selected_id]
	proof["node_state"] = proof_node
	forged["source_proof"] = proof
	terminal_receipts[route_id] = forged
	state["terminal_transition_receipts"] = terminal_receipts
	var summaries: Dictionary = state.get("month_summaries", {})
	var month_two: Dictionary = summaries.get("2", {})
	var nodes: Dictionary = month_two.get("node_states", {})
	var people: Dictionary = nodes.get("m2_people", {})
	people["eligible_trigger_bundle_ids"] = [selected_id]
	nodes["m2_people"] = people
	month_two["node_states"] = nodes
	summaries["2"] = month_two
	state["month_summaries"] = summaries
	malformed["core_loop_v2_state"] = state
	_assert_terminal_reader_empty_after_load(
		malformed, route_id,
		"M2 summary-only reader accepted coupled proof/summary eligible-set " \
			+ "shrinkage")


func _m2_relationship_receipt_count(
		bundle_id: String, memory: String, turn: int) -> int:
	var count := 0
	for raw_receipt in (GameState.core_loop_v2_state.get(
			"relationship_choice_receipts", {}) as Dictionary).values():
		if raw_receipt is Dictionary \
				and str((raw_receipt as Dictionary).get(
					"bundle_id", "")) == bundle_id \
				and str((raw_receipt as Dictionary).get("memory", "")) == memory \
				and int((raw_receipt as Dictionary).get("turn", 0)) == turn:
			count += 1
	return count


func _m2_relationship_bundle_count(bundle_id: String) -> int:
	var count := 0
	for raw_receipt in (GameState.core_loop_v2_state.get(
			"relationship_choice_receipts", {}) as Dictionary).values():
		if raw_receipt is Dictionary \
				and str((raw_receipt as Dictionary).get(
					"bundle_id", "")) == bundle_id:
			count += 1
	return count


func _check_m2_people_candidate_cardinality(
		contract_snapshot: Dictionary) -> void:
	var hyunsu_id := "hyunsu_player_reachout"
	var cafe_id := "cafe_world_glimpse"

	var zero_snapshot := _prepare_m2_people_fixture(
		contract_snapshot, [hyunsu_id], false)
	var zero_node := _m2_people_node(zero_snapshot)
	var zero_capacity := _unused_capacity(zero_snapshot, 1, true)
	var zero_before: Dictionary = GameState.serialize().duplicate(true)
	var zero_preview := CORE.preview_seoul_cycle_allocation(
		zero_capacity, "m2_people", 2)
	var zero_commit := CORE.commit_seoul_cycle_allocation(
		zero_capacity, "m2_people", 2)
	_expect((zero_node.get("eligible_trigger_bundle_ids", []) as Array).is_empty() \
		and str(zero_node.get("status", "")) == "locked" \
		and not bool(zero_preview.get("ok", true)) \
		and not bool(zero_commit.get("ok", true)) \
		and GameState.serialize() == zero_before,
		"zero-eligible M2 people node unlocked or mutated state")

	var one_snapshot := _prepare_m2_people_fixture(
		contract_snapshot, [hyunsu_id, cafe_id], false)
	var one_node := _m2_people_node(one_snapshot)
	var one_capacity := _unused_capacity(one_snapshot, 1, true)
	var one_before: Dictionary = GameState.serialize().duplicate(true)
	var one_preview := CORE.preview_seoul_cycle_allocation(
		one_capacity, "m2_people", 2)
	var one_commit := CORE.commit_seoul_cycle_allocation(
		one_capacity, "m2_people", 2)
	var one_invalid := CORE.commit_seoul_cycle_allocation(
		one_capacity, "m2_people", 2, hyunsu_id)
	var one_selected_preview := CORE.preview_seoul_cycle_allocation(
		one_capacity, "m2_people", 2, cafe_id)
	var one_candidates: Array = one_preview.get("trigger_candidates", [])
	_expect(one_node.get("eligible_trigger_bundle_ids", []) == [cafe_id] \
		and str(one_node.get("status", "")) == "open" \
		and not bool(one_preview.get("ok", true)) \
		and str(one_preview.get("error", "")) \
			== "trigger_selection_required" \
		and bool(one_preview.get("trigger_selection_required", false)) \
		and _m2_candidate_ids(one_candidates) == [cafe_id] \
		and _m2_candidate_copy_complete(one_candidates) \
		and not bool(one_commit.get("ok", true)) \
		and str(one_commit.get("error", "")) \
			== "trigger_selection_required" \
		and not bool(one_invalid.get("ok", true)) \
		and str(one_invalid.get("error", "")) == "invalid_trigger_selection" \
		and bool(one_selected_preview.get("ok", false)) \
		and str(one_selected_preview.get(
			"selected_trigger_bundle_id", "")) == cafe_id \
		and GameState.serialize() == one_before,
		"one-eligible M2 people choice auto-selected, lacked copy, or mutated")

	var two_snapshot := _prepare_m2_people_fixture(
		contract_snapshot, [hyunsu_id, cafe_id], true)
	var two_node := _m2_people_node(two_snapshot)
	var two_capacity := _unused_capacity(two_snapshot, 1, true)
	var two_before: Dictionary = GameState.serialize().duplicate(true)
	var two_preview := CORE.preview_seoul_cycle_allocation(
		two_capacity, "m2_people", 2)
	var two_commit := CORE.commit_seoul_cycle_allocation(
		two_capacity, "m2_people", 2)
	var two_invalid := CORE.commit_seoul_cycle_allocation(
		two_capacity, "m2_people", 2, "unknown_people_branch")
	var two_candidates: Array = two_preview.get("trigger_candidates", [])
	_expect(two_node.get("eligible_trigger_bundle_ids", []) \
			== [cafe_id, hyunsu_id] \
		and str(two_node.get("selected_trigger_bundle_id", "")).is_empty() \
		and str(two_node.get("trigger_bundle", "")).is_empty() \
		and str(two_node.get("summary_bundle", "")).is_empty() \
		and not bool(two_preview.get("ok", true)) \
		and str(two_preview.get("error", "")) \
			== "trigger_selection_required" \
		and _m2_candidate_ids(two_candidates) == [cafe_id, hyunsu_id] \
		and _m2_candidate_copy_complete(two_candidates) \
		and not bool(two_commit.get("ok", true)) \
		and not bool(two_invalid.get("ok", true)) \
		and str(two_invalid.get("error", "")) \
			== "invalid_trigger_selection" \
		and GameState.serialize() == two_before,
		"two-eligible M2 people choice used a first-candidate fallback or mutated")


func _check_m2_people_json_order_independence(
		contract_snapshot: Dictionary) -> void:
	var hyunsu_id := "hyunsu_player_reachout"
	var cafe_id := "cafe_world_glimpse"
	var forward := _prepare_m2_people_fixture(
		contract_snapshot, [hyunsu_id, cafe_id], true)
	var forward_capacity := _unused_capacity(forward, 1, true)
	var forward_preview := CORE.preview_seoul_cycle_allocation(
		forward_capacity, "m2_people", 2)
	var forward_identity := {
		"eligible": _m2_people_node(forward).get(
			"eligible_trigger_bundle_ids", []),
		"candidates": _m2_candidate_ids(
			forward_preview.get("trigger_candidates", [])),
	}
	var reversed := _prepare_m2_people_fixture(
		contract_snapshot, [cafe_id, hyunsu_id], true)
	var reversed_capacity := _unused_capacity(reversed, 1, true)
	var reversed_preview := CORE.preview_seoul_cycle_allocation(
		reversed_capacity, "m2_people", 2)
	var reversed_identity := {
		"eligible": _m2_people_node(reversed).get(
			"eligible_trigger_bundle_ids", []),
		"candidates": _m2_candidate_ids(
			reversed_preview.get("trigger_candidates", [])),
	}
	var before_choice: Dictionary = GameState.serialize().duplicate(true)
	var second_choice := CORE.preview_seoul_cycle_allocation(
		reversed_capacity, "m2_people", 2, hyunsu_id)
	_expect(forward_identity == reversed_identity \
		and forward_identity.get("eligible", []) == [cafe_id, hyunsu_id] \
		and bool(second_choice.get("ok", false)) \
		and str(second_choice.get(
			"selected_trigger_bundle_id", "")) == hyunsu_id \
		and GameState.serialize() == before_choice,
		"reversing JSON trigger_options changed canonical identity or first-picked")


func _check_m2_people_choice_roundtrip(
		contract_snapshot: Dictionary) -> void:
	var hyunsu_id := "hyunsu_player_reachout"
	var cafe_id := "cafe_world_glimpse"
	var snapshot := _prepare_m2_people_fixture(
		contract_snapshot, [hyunsu_id, cafe_id], true)
	var unselected_cycle: Dictionary = GameState.core_loop_v2_state.get(
		"seoul_cycle", {}).duplicate(true)
	var capacity_id := _unused_capacity(snapshot, 1, false)
	var committed := CORE.commit_seoul_cycle_allocation(
		capacity_id, "m2_people", 2, cafe_id)
	var receipt: Dictionary = committed.get("receipt", {})
	var weekly: Dictionary = receipt.get("weekly_commitment", {})
	var weekly_details: Dictionary = weekly.get("details", {})
	var partial_snapshot := CORE.seoul_cycle_snapshot(2)
	var partial_node := _m2_people_node(partial_snapshot)
	var expected_identity := _m2_people_choice_identity(partial_snapshot)
	_expect(bool(committed.get("ok", false)) \
		and not bool(committed.get("completed_now", true)) \
		and int(committed.get("progress_after", -1)) == 1 \
		and int(committed.get("threshold", 0)) == 2 \
		and str(receipt.get("selected_trigger_bundle_id", "")) == cafe_id \
		and str(receipt.get("trigger_bundle", "")).is_empty() \
		and str(weekly_details.get(
			"selected_trigger_bundle_id", "")) == cafe_id \
		and str(partial_node.get(
			"selected_trigger_bundle_id", "")) == cafe_id \
		and str(partial_node.get("trigger_bundle", "")) == cafe_id \
		and str(partial_node.get("summary_bundle", "")) == cafe_id \
		and str(partial_node.get("trigger_selection_origin", "")) \
			== "player_selection" \
		and (partial_snapshot.get("pending_trigger", {}) as Dictionary).is_empty(),
		"partial M2 people allocation did not pin the exact Cafe choice")

	var raw_cycle: Dictionary = GameState.core_loop_v2_state.get(
		"seoul_cycle", {}).duplicate(true)
	var before_normalize: Dictionary = GameState.serialize().duplicate(true)
	var normalized := CORE.normalize_seoul_cycle_state(raw_cycle)
	_expect(not normalized.is_empty() \
		and _m2_people_choice_identity(normalized) == expected_identity \
		and GameState.serialize() == before_normalize,
		"M2 people normalization changed selection or mutated live state")
	_check_m2_people_selected_shape_rejections(
		unselected_cycle, raw_cycle, cafe_id, hyunsu_id)

	var saved: Dictionary = GameState.serialize().duplicate(true)
	var sibling_weekly_save := saved.duplicate(true)
	var sibling_weekly: Array = sibling_weekly_save.get(
		"weekly_commitments", [])
	if not sibling_weekly.is_empty() and sibling_weekly[0] is Dictionary:
		var sibling_record: Dictionary = (
			sibling_weekly[0] as Dictionary).duplicate(true)
		var sibling_details: Dictionary = sibling_record.get(
			"details", {}).duplicate(true)
		sibling_details["selected_trigger_bundle_id"] = hyunsu_id
		sibling_record["details"] = sibling_details
		sibling_weekly[0] = sibling_record
		sibling_weekly_save["weekly_commitments"] = sibling_weekly
	GameState.start_new_game()
	GameState.load_from_dict(sibling_weekly_save)
	CORE.initialize_for_run(true)
	_expect((GameState.core_loop_v2_state.get(
		"seoul_cycle", {}) as Dictionary).is_empty(),
		"top-level weekly ledger accepted a sibling people branch on load")
	for reload_index in range(2):
		GameState.start_new_game()
		GameState.load_from_dict(saved.duplicate(true))
		CORE.initialize_for_run(true)
		var reloaded := CORE.seoul_cycle_snapshot(2)
		_expect(_m2_people_choice_identity(reloaded) == expected_identity \
			and (reloaded.get("allocation_receipts", {}) as Dictionary).size() == 1 \
			and GameState.weekly_commitments.size() == 1,
			"M2 people choice drifted or duplicated on reload %d" \
				% [reload_index + 1])
		saved = GameState.serialize().duplicate(true)

	_expect(bool(CORE.complete_seoul_cycle_turn(2).get("ok", false)),
		"partial Cafe week could not close after double reload")
	_advance_to_next_week()
	var week_two := CORE.seoul_cycle_snapshot(2)
	var second_capacity := _unused_capacity(week_two, 3, true)
	var before_branch_change: Dictionary = GameState.serialize().duplicate(true)
	var changed := CORE.commit_seoul_cycle_allocation(
		second_capacity, "m2_people", 2, hyunsu_id)
	_expect(not bool(changed.get("ok", true)) \
		and str(changed.get("error", "")) == "trigger_branch_change_rejected" \
		and GameState.serialize() == before_branch_change,
		"a later week changed the already-pinned people branch")
	var completed := CORE.commit_seoul_cycle_allocation(
		second_capacity, "m2_people", 2, cafe_id)
	var pending: Dictionary = completed.get("pending_trigger", {})
	_expect(bool(completed.get("ok", false)) \
		and bool(completed.get("completed_now", false)) \
		and str(pending.get("bundle_id", "")) == cafe_id \
		and str(pending.get("selected_trigger_bundle_id", "")) == cafe_id,
		"the pinned Cafe choice did not own its eventual completion trigger")
	_check_m2_people_pending_shape_rejections(
		GameState.core_loop_v2_state.get("seoul_cycle", {}), hyunsu_id)


func _check_m2_people_legacy_resolution(
		contract_snapshot: Dictionary) -> void:
	var hyunsu_id := "hyunsu_player_reachout"
	var cafe_id := "cafe_world_glimpse"
	var initialized := _prepare_m2_people_fixture(
		contract_snapshot, [hyunsu_id, cafe_id], true)
	var legacy_cycle: Dictionary = GameState.core_loop_v2_state.get(
		"seoul_cycle", {}).duplicate(true)
	var legacy_nodes: Dictionary = legacy_cycle.get("nodes", {})
	var legacy_people: Dictionary = legacy_nodes.get("m2_people", {})
	legacy_people.erase("eligible_trigger_bundle_ids")
	legacy_people.erase("selected_trigger_bundle_id")
	legacy_people.erase("trigger_selection_origin")
	legacy_people.erase("trigger_selection_migrated_legacy")
	legacy_people["trigger_bundle"] = cafe_id
	legacy_people["summary_bundle"] = cafe_id
	legacy_nodes["m2_people"] = legacy_people
	legacy_cycle["nodes"] = legacy_nodes
	var live_before: Dictionary = GameState.serialize().duplicate(true)
	var migrated := CORE.normalize_seoul_cycle_state(legacy_cycle)
	var migrated_node := _m2_people_node(migrated)
	_expect(not migrated.is_empty() \
		and migrated_node.get("eligible_trigger_bundle_ids", []) == [cafe_id] \
		and str(migrated_node.get(
			"selected_trigger_bundle_id", "")) == cafe_id \
		and str(migrated_node.get("trigger_bundle", "")) == cafe_id \
		and str(migrated_node.get("summary_bundle", "")) == cafe_id \
		and str(migrated_node.get("trigger_selection_origin", "")) \
			== "legacy_persisted_trigger" \
		and bool(migrated_node.get(
			"trigger_selection_migrated_legacy", false)) \
		and (migrated.get("allocation_receipts", {}) as Dictionary).is_empty() \
		and (migrated.get("trigger_receipts", {}) as Dictionary).is_empty() \
		and GameState.serialize() == live_before,
		"legacy persisted Cafe trigger was re-evaluated or minted a receipt")

	var state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	state["seoul_cycle"] = legacy_cycle
	GameState.core_loop_v2_state = state
	var legacy_save: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(legacy_save)
	CORE.initialize_for_run(true)
	var loaded := CORE.seoul_cycle_snapshot(2)
	var loaded_node := _m2_people_node(loaded)
	_expect(loaded_node.get("eligible_trigger_bundle_ids", []) == [cafe_id] \
		and str(loaded_node.get("selected_trigger_bundle_id", "")) == cafe_id \
		and str(loaded_node.get("trigger_bundle", "")) == cafe_id \
		and (loaded.get("allocation_receipts", {}) as Dictionary).is_empty() \
		and (loaded.get("trigger_receipts", {}) as Dictionary).is_empty() \
		and GameState.weekly_commitments.is_empty(),
		"legacy people trigger did not survive load exactly once")
	var malformed := migrated.duplicate(true)
	var malformed_nodes: Dictionary = malformed.get("nodes", {})
	var malformed_people: Dictionary = malformed_nodes.get("m2_people", {})
	malformed_people["selected_trigger_bundle_id"] = hyunsu_id
	malformed_nodes["m2_people"] = malformed_people
	malformed["nodes"] = malformed_nodes
	_expect(CORE.normalize_seoul_cycle_state(malformed).is_empty(),
		"mismatched legacy selected/trigger identity did not fail closed")
	_expect(not initialized.is_empty(),
		"legacy fixture failed to initialize its source cycle")


func _check_m2_people_legacy_partial_continuation(
		contract_snapshot: Dictionary) -> void:
	var hyunsu_id := "hyunsu_player_reachout"
	var cafe_id := "cafe_world_glimpse"
	var snapshot := _prepare_m2_people_fixture(
		contract_snapshot, [hyunsu_id, cafe_id], true)
	var first_capacity := _unused_capacity(snapshot, 1, false)
	var first_commit := CORE.commit_seoul_cycle_allocation(
		first_capacity, "m2_people", 2, cafe_id)
	_expect(bool(first_commit.get("ok", false)) \
		and not bool(first_commit.get("completed_now", true)),
		"legacy-partial source fixture did not create Cafe W5 progress")

	# Rebuild the exact pre-player-selection save shape. The node had already
	# persisted its resolved Cafe trigger, while neither duplicated weekly copy
	# nor the allocation receipt knew the later selected-id field yet.
	var legacy_save: Dictionary = GameState.serialize().duplicate(true)
	var legacy_v2: Dictionary = legacy_save.get(
		"core_loop_v2_state", {})
	var legacy_cycle: Dictionary = legacy_v2.get("seoul_cycle", {})
	var legacy_nodes: Dictionary = legacy_cycle.get("nodes", {})
	var legacy_people: Dictionary = legacy_nodes.get("m2_people", {})
	for field in [
		"eligible_trigger_bundle_ids", "selected_trigger_bundle_id",
		"trigger_selection_origin", "trigger_selection_migrated_legacy",
	]:
		legacy_people.erase(field)
	legacy_people["trigger_bundle"] = cafe_id
	legacy_people["summary_bundle"] = cafe_id
	legacy_nodes["m2_people"] = legacy_people
	legacy_cycle["nodes"] = legacy_nodes
	var legacy_receipts: Dictionary = legacy_cycle.get(
		"allocation_receipts", {})
	var legacy_w5: Dictionary = legacy_receipts.get("5", {})
	legacy_w5.erase("selected_trigger_bundle_id")
	var legacy_embedded: Dictionary = legacy_w5.get(
		"weekly_commitment", {})
	var legacy_embedded_details: Dictionary = legacy_embedded.get(
		"details", {})
	legacy_embedded_details.erase("selected_trigger_bundle_id")
	legacy_embedded["details"] = legacy_embedded_details
	legacy_w5["weekly_commitment"] = legacy_embedded
	legacy_receipts["5"] = legacy_w5
	legacy_cycle["allocation_receipts"] = legacy_receipts
	legacy_v2["seoul_cycle"] = legacy_cycle
	legacy_save["core_loop_v2_state"] = legacy_v2
	var legacy_outer: Array = legacy_save.get("weekly_commitments", [])
	for outer_index in range(legacy_outer.size()):
		if not legacy_outer[outer_index] is Dictionary \
				or int((legacy_outer[outer_index] as Dictionary).get(
					"turn", 0)) != 5:
			continue
		var outer: Dictionary = (
			legacy_outer[outer_index] as Dictionary).duplicate(true)
		var outer_details: Dictionary = outer.get("details", {})
		outer_details.erase("selected_trigger_bundle_id")
		outer["details"] = outer_details
		legacy_outer[outer_index] = outer
	legacy_save["weekly_commitments"] = legacy_outer

	GameState.start_new_game()
	GameState.load_from_dict(legacy_save)
	CORE.initialize_for_run(true)
	var migrated := CORE.seoul_cycle_snapshot(2)
	var migrated_node := _m2_people_node(migrated)
	var migrated_receipt: Dictionary = (
		migrated.get("allocation_receipts", {}) as Dictionary).get("5", {})
	var migrated_embedded: Dictionary = migrated_receipt.get(
		"weekly_commitment", {})
	var migrated_embedded_details: Dictionary = migrated_embedded.get(
		"details", {})
	var migrated_outer := GameState.get_weekly_commitment_for_turn(5)
	var migrated_outer_details: Dictionary = migrated_outer.get("details", {})
	_expect(not migrated.is_empty() \
		and migrated_node.get("eligible_trigger_bundle_ids", []) == [cafe_id] \
		and str(migrated_node.get(
			"selected_trigger_bundle_id", "")) == cafe_id \
		and str(migrated_node.get("trigger_selection_origin", "")) \
			== "legacy_persisted_trigger" \
		and bool(migrated_node.get(
			"trigger_selection_migrated_legacy", false)) \
		and not migrated_receipt.has("selected_trigger_bundle_id") \
		and not migrated_embedded_details.has(
			"selected_trigger_bundle_id") \
		and not migrated_outer_details.has("selected_trigger_bundle_id"),
		"prepatch Cafe partial save did not migrate without invented identities")
	_expect(bool(CORE.complete_seoul_cycle_turn(2).get("ok", false)),
		"prepatch Cafe partial W5 could not close after migration")
	var closed_w5: Dictionary = CORE.seoul_cycle_snapshot(2).get(
		"allocation_receipts", {}).get("5", {}).duplicate(true)
	_advance_to_next_week()
	var week_six := CORE.seoul_cycle_snapshot(2)
	var second_capacity := _unused_capacity(week_six, 3, true)
	var before_sibling: Dictionary = GameState.serialize().duplicate(true)
	var sibling_change := CORE.commit_seoul_cycle_allocation(
		second_capacity, "m2_people", 2, hyunsu_id)
	_expect(not bool(sibling_change.get("ok", true)) \
		and str(sibling_change.get("error", "")) \
			== "trigger_branch_change_rejected" \
		and GameState.serialize() == before_sibling,
		"prepatch Cafe partial save allowed a W6 sibling branch change")
	var continued := CORE.commit_seoul_cycle_allocation(
		second_capacity, "m2_people", 2, cafe_id)
	var continued_cycle := CORE.seoul_cycle_snapshot(2)
	var continued_node := _m2_people_node(continued_cycle)
	var continued_receipts: Dictionary = continued_cycle.get(
		"allocation_receipts", {})
	var continued_w5: Dictionary = continued_receipts.get("5", {})
	var continued_w6: Dictionary = continued_receipts.get("6", {})
	var continued_w6_weekly: Dictionary = continued_w6.get(
		"weekly_commitment", {})
	var continued_w6_details: Dictionary = continued_w6_weekly.get(
		"details", {})
	var continued_pending: Dictionary = continued_cycle.get(
		"pending_trigger", {})
	_expect(bool(continued.get("ok", false)) \
		and bool(continued.get("completed_now", false)) \
		and continued_receipts.size() == 2 \
		and continued_w5 == closed_w5 \
		and not continued_w5.has("selected_trigger_bundle_id") \
		and str(continued_w6.get(
			"selected_trigger_bundle_id", "")) == cafe_id \
		and str(continued_w6.get("trigger_bundle", "")) == cafe_id \
		and str(continued_w6_details.get(
			"selected_trigger_bundle_id", "")) == cafe_id \
		and continued_node.get("eligible_trigger_bundle_ids", []) == [cafe_id] \
		and str(continued_node.get(
			"selected_trigger_bundle_id", "")) == cafe_id \
		and str(continued_node.get("trigger_selection_origin", "")) \
			== "legacy_persisted_trigger" \
		and bool(continued_node.get(
			"trigger_selection_migrated_legacy", false)) \
		and str(continued_pending.get("bundle_id", "")) == cafe_id \
		and str(continued_pending.get(
			"selected_trigger_bundle_id", "")) == cafe_id \
		and not (GameState.core_loop_v2_state.get(
			"completed_bundles", []) as Array).has(hyunsu_id),
		"prepatch Cafe partial continuation lost old/new receipts or leaked sibling")
	var normalized := CORE.normalize_seoul_cycle_state(
		GameState.core_loop_v2_state.get("seoul_cycle", {}))
	_expect(not normalized.is_empty() \
		and normalized == GameState.core_loop_v2_state.get("seoul_cycle", {}),
		"continued prepatch Cafe cycle did not normalize exactly")
	var continued_save: Dictionary = GameState.serialize().duplicate(true)
	var expected_cycle: Dictionary = GameState.core_loop_v2_state.get(
		"seoul_cycle", {}).duplicate(true)
	for reload_index in range(2):
		GameState.start_new_game()
		GameState.load_from_dict(continued_save.duplicate(true))
		CORE.initialize_for_run(true)
		var reloaded_cycle: Dictionary = GameState.core_loop_v2_state.get(
			"seoul_cycle", {})
		var reloaded_receipts: Dictionary = reloaded_cycle.get(
			"allocation_receipts", {})
		_expect(reloaded_cycle == expected_cycle \
			and reloaded_receipts.size() == 2 \
			and reloaded_receipts.get("5", {}) == closed_w5 \
			and str((reloaded_receipts.get("6", {}) as Dictionary).get(
				"selected_trigger_bundle_id", "")) == cafe_id \
			and str((reloaded_cycle.get(
				"pending_trigger", {}) as Dictionary).get(
					"bundle_id", "")) == cafe_id \
			and not (GameState.core_loop_v2_state.get(
				"completed_bundles", []) as Array).has(hyunsu_id),
			"prepatch Cafe continuation drifted on reload %d" \
				% [reload_index + 1])
		continued_save = GameState.serialize().duplicate(true)


func _check_m2_people_chosen_branch(
		contract_snapshot: Dictionary, chosen_id: String,
		story_choice_index: int) -> void:
	var hyunsu_id := "hyunsu_player_reachout"
	var cafe_id := "cafe_world_glimpse"
	var sibling_id := cafe_id if chosen_id == hyunsu_id else hyunsu_id
	var snapshot := _prepare_m2_people_fixture(
		contract_snapshot, [hyunsu_id, cafe_id], true)
	if chosen_id == cafe_id:
		GameState.turn = 6
		GameState.month = 2
		GameState.week_of_month = 2
		snapshot = CORE.seoul_cycle_snapshot(2)
	var capacity_id := _unused_capacity(snapshot, 3, true)
	var committed := CORE.commit_seoul_cycle_allocation(
		capacity_id, "m2_people", 2, chosen_id)
	var pending: Dictionary = committed.get("pending_trigger", {})
	var receipt: Dictionary = committed.get("receipt", {})
	var weekly: Dictionary = receipt.get("weekly_commitment", {})
	var weekly_details: Dictionary = weekly.get("details", {})
	_expect(bool(committed.get("ok", false)) \
		and bool(committed.get("completed_now", false)) \
		and str(receipt.get("selected_trigger_bundle_id", "")) == chosen_id \
		and str(receipt.get("trigger_bundle", "")) == chosen_id \
		and str(weekly_details.get(
			"selected_trigger_bundle_id", "")) == chosen_id \
		and str(pending.get("bundle_id", "")) == chosen_id \
		and str(pending.get("selected_trigger_bundle_id", "")) == chosen_id,
		"chosen people branch did not exclusively own allocation/pending receipts")
	var claimed := CORE.claim_seoul_cycle_trigger()
	var began := bool(claimed.get("ok", false)) \
		and CORE.begin_seoul_cycle_trigger(chosen_id)
	_expect(began, "chosen people branch could not be claimed: %s" % chosen_id)
	if began and chosen_id == hyunsu_id:
		_apply_and_note_story("v2_hyunsu_player_reachout", 0)
		_apply_and_note_story("v2_hyunsu_first_study", story_choice_index)
	elif began:
		_apply_and_note_story("cafe_00", story_choice_index)
	var completed_id := CORE.complete_active_bundle() if began else ""
	var completed_save: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(completed_save)
	CORE.initialize_for_run(true)
	var resolved := CORE.seoul_cycle_snapshot(2)
	var trigger_receipt: Dictionary = (
		resolved.get("trigger_receipts", {}) as Dictionary).get(
			"m2_people", {})
	var completed_bundles: Array = GameState.core_loop_v2_state.get(
		"completed_bundles", [])
	var relationship_matches := (
		_has_relationship_receipt(chosen_id, "hyunsu")
		if chosen_id == hyunsu_id
		else not _has_relationship_receipt(hyunsu_id, "hyunsu")
	)
	var month_three_next_ids := CORE.available_offer_ids(3)
	var month_four_next_ids := CORE.available_offer_ids(4)
	var next_surface_matches := (
		month_three_next_ids.has("hyunsu_study_followup") \
			and not month_four_next_ids.has("sangchul_world_meet")
		if chosen_id == hyunsu_id else
		month_four_next_ids.has("sangchul_world_meet") \
			and not month_three_next_ids.has("hyunsu_study_followup")
	)
	var expected_memory := (
		("hyunsu_resume_shared" if story_choice_index == 0 \
		else "hyunsu_problem_set_shared")
		if chosen_id == hyunsu_id else ""
	)
	var sibling_memory := (
		("hyunsu_problem_set_shared" if story_choice_index == 0 \
		else "hyunsu_resume_shared")
		if chosen_id == hyunsu_id else ""
	)
	var memory_matches := chosen_id != hyunsu_id \
		or (CORE.has_relationship_memory("hyunsu", expected_memory) \
			and not CORE.has_relationship_memory("hyunsu", sibling_memory))
	_expect(completed_id == chosen_id \
		and str(trigger_receipt.get("bundle_id", "")) == chosen_id \
		and str(trigger_receipt.get(
			"selected_trigger_bundle_id", "")) == chosen_id \
		and completed_bundles.has(chosen_id) \
		and not completed_bundles.has(sibling_id) \
		and relationship_matches \
		and memory_matches \
		and next_surface_matches,
		"chosen people outcome %d leaked into sibling receipt/memory/next surface" \
			% story_choice_index)
	var resolved_cycle: Dictionary = GameState.core_loop_v2_state.get(
		"seoul_cycle", {}).duplicate(true)
	var malformed_resolved := resolved_cycle.duplicate(true)
	var malformed_trigger_receipts: Dictionary = malformed_resolved.get(
		"trigger_receipts", {})
	var malformed_trigger_receipt: Dictionary = malformed_trigger_receipts.get(
		"m2_people", {})
	malformed_trigger_receipt["selected_trigger_bundle_id"] = sibling_id
	malformed_trigger_receipts["m2_people"] = malformed_trigger_receipt
	malformed_resolved["trigger_receipts"] = malformed_trigger_receipts
	_expect(CORE.normalize_seoul_cycle_state(malformed_resolved).is_empty(),
		"resolved people receipt accepted a sibling selected identity")


func _check_m2_people_selected_shape_rejections(
		unselected_cycle: Dictionary, selected_cycle: Dictionary,
		selected_id: String, sibling_id: String) -> void:
	var no_receipt := unselected_cycle.duplicate(true)
	var no_receipt_nodes: Dictionary = no_receipt.get("nodes", {})
	var selected_node := _m2_people_node(selected_cycle)
	selected_node["progress"] = 0
	selected_node["status"] = "open"
	selected_node["completed_turn"] = 0
	selected_node["last_allocation_turn"] = 0
	no_receipt_nodes["m2_people"] = selected_node
	no_receipt["nodes"] = no_receipt_nodes
	_expect(CORE.normalize_seoul_cycle_state(no_receipt).is_empty(),
		"non-legacy player choice without an allocation receipt was accepted")

	var bad_node := selected_cycle.duplicate(true)
	var bad_node_nodes: Dictionary = bad_node.get("nodes", {})
	var bad_people: Dictionary = bad_node_nodes.get("m2_people", {})
	bad_people["selected_trigger_bundle_id"] = sibling_id
	bad_node_nodes["m2_people"] = bad_people
	bad_node["nodes"] = bad_node_nodes
	_expect(CORE.normalize_seoul_cycle_state(bad_node).is_empty(),
		"selected people node accepted a sibling branch identity")

	var bad_receipt_selection := selected_cycle.duplicate(true)
	var selection_receipts: Dictionary = bad_receipt_selection.get(
		"allocation_receipts", {})
	var selection_receipt: Dictionary = selection_receipts.get("5", {})
	selection_receipt["selected_trigger_bundle_id"] = sibling_id
	selection_receipts["5"] = selection_receipt
	bad_receipt_selection["allocation_receipts"] = selection_receipts
	_expect(CORE.normalize_seoul_cycle_state(
		bad_receipt_selection).is_empty(),
		"allocation receipt accepted a sibling selected identity")

	var bad_receipt_trigger := selected_cycle.duplicate(true)
	var trigger_receipts: Dictionary = bad_receipt_trigger.get(
		"allocation_receipts", {})
	var trigger_receipt: Dictionary = trigger_receipts.get("5", {})
	trigger_receipt["trigger_bundle"] = sibling_id
	trigger_receipts["5"] = trigger_receipt
	bad_receipt_trigger["allocation_receipts"] = trigger_receipts
	_expect(CORE.normalize_seoul_cycle_state(bad_receipt_trigger).is_empty(),
		"partial allocation receipt accepted a sibling trigger identity")

	var bad_weekly := selected_cycle.duplicate(true)
	var weekly_receipts: Dictionary = bad_weekly.get(
		"allocation_receipts", {})
	var weekly_receipt: Dictionary = weekly_receipts.get("5", {})
	var embedded_weekly: Dictionary = weekly_receipt.get(
		"weekly_commitment", {})
	var embedded_details: Dictionary = embedded_weekly.get("details", {})
	embedded_details["selected_trigger_bundle_id"] = sibling_id
	embedded_weekly["details"] = embedded_details
	weekly_receipt["weekly_commitment"] = embedded_weekly
	weekly_receipts["5"] = weekly_receipt
	bad_weekly["allocation_receipts"] = weekly_receipts
	_expect(CORE.normalize_seoul_cycle_state(bad_weekly).is_empty(),
		"nested weekly receipt accepted a sibling selected identity")
	_expect(selected_id != sibling_id,
		"malformed people fixture did not use distinct branch identities")


func _check_m2_people_pending_shape_rejections(
		raw_cycle: Dictionary, sibling_id: String) -> void:
	for pending_field in ["bundle_id", "selected_trigger_bundle_id"]:
		var malformed := raw_cycle.duplicate(true)
		var pending: Dictionary = malformed.get("pending_trigger", {})
		pending[pending_field] = sibling_id
		malformed["pending_trigger"] = pending
		_expect(CORE.normalize_seoul_cycle_state(malformed).is_empty(),
			"pending people trigger accepted sibling %s" % pending_field)


func _prepare_m2_people_fixture(
		contract_snapshot: Dictionary, trigger_options: Array,
		hyunsu_eligible: bool) -> Dictionary:
	DataRegistry.demo_core_loop_v2 = _m2_people_contract_fixture(
		contract_snapshot, trigger_options)
	_prepare_fresh_cycle_gate()
	var month_one := CORE.initialize_seoul_cycle(1)
	_expect(bool(month_one.get("ok", false)),
		"M2 people fixture could not establish Month One cycle provenance")
	var state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	var applications: Dictionary = state.get("application_statuses", {})
	applications.erase("mirae_industrial_tech")
	state["application_statuses"] = applications
	if hyunsu_eligible:
		var completed: Array = state.get("completed_bundles", [])
		if not completed.has("hyunsu_first_meet"):
			completed.append("hyunsu_first_meet")
		state["completed_bundles"] = completed
		var completed_turns: Dictionary = state.get(
			"completed_bundle_turns", {})
		completed_turns["hyunsu_first_meet"] = 3
		state["completed_bundle_turns"] = completed_turns
		var stages: Dictionary = state.get("relationship_stages", {})
		stages["hyunsu"] = "opening"
		state["relationship_stages"] = stages
		var memories: Array = state.get("relationship_memories", [])
		memories.append({
			"character": "hyunsu",
			"memory": "hyunsu_honest_uncertainty",
			"bundle_id": "hyunsu_first_meet",
			"turn": 3,
		})
		state["relationship_memories"] = memories
	GameState.core_loop_v2_state = state
	GameState.turn = 5
	GameState.month = 2
	GameState.week_of_month = 1
	var initialized := CORE.initialize_seoul_cycle(2)
	_expect(bool(initialized.get("ok", false)),
		"M2 people fixture could not initialize Month Two")
	return CORE.seoul_cycle_snapshot(2)


func _m2_people_contract_fixture(
		contract_snapshot: Dictionary, trigger_options: Array) -> Dictionary:
	var fixture := contract_snapshot.duplicate(true)
	var cycle: Dictionary = fixture.get("seoul_cycle", {})
	var months: Dictionary = cycle.get("months", {})
	var month_two: Dictionary = months.get("2", {})
	var nodes: Dictionary = month_two.get("nodes", {})
	var people: Dictionary = nodes.get("m2_people", {})
	people["trigger_options"] = trigger_options.duplicate()
	nodes["m2_people"] = people
	month_two["nodes"] = nodes
	months["2"] = month_two
	cycle["months"] = months
	fixture["seoul_cycle"] = cycle
	return fixture


func _m2_people_node(raw_cycle: Dictionary) -> Dictionary:
	var raw_nodes: Variant = raw_cycle.get("nodes", {})
	if not raw_nodes is Dictionary:
		return {}
	var raw_people: Variant = (raw_nodes as Dictionary).get("m2_people", {})
	return (raw_people as Dictionary).duplicate(true) \
		if raw_people is Dictionary else {}


func _m2_candidate_ids(raw_candidates: Array) -> Array[String]:
	var ids: Array[String] = []
	for raw_candidate in raw_candidates:
		if raw_candidate is Dictionary:
			ids.append(str((raw_candidate as Dictionary).get("id", "")))
	return ids


func _m2_candidate_copy_complete(raw_candidates: Array) -> bool:
	for raw_candidate in raw_candidates:
		if not raw_candidate is Dictionary:
			return false
		for key in ["id", "label_ko", "label_en", "detail_ko", "detail_en"]:
			if str((raw_candidate as Dictionary).get(key, "")).strip_edges().is_empty():
				return false
	return true


func _m2_people_choice_identity(raw_cycle: Dictionary) -> Dictionary:
	var node := _m2_people_node(raw_cycle)
	return {
		"eligible_trigger_bundle_ids": (
			node.get("eligible_trigger_bundle_ids", []) as Array).duplicate(),
		"selected_trigger_bundle_id": str(node.get(
			"selected_trigger_bundle_id", "")),
		"trigger_bundle": str(node.get("trigger_bundle", "")),
		"summary_bundle": str(node.get("summary_bundle", "")),
		"trigger_selection_origin": str(node.get(
			"trigger_selection_origin", "")),
		"trigger_selection_migrated_legacy": bool(node.get(
			"trigger_selection_migrated_legacy", false)),
		"progress": int(node.get("progress", 0)),
		"status": str(node.get("status", "")),
		"allocation_receipts": (
			raw_cycle.get("allocation_receipts", {}) as Dictionary).duplicate(true),
		"pending_trigger": (
			raw_cycle.get("pending_trigger", {}) as Dictionary).duplicate(true),
	}


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


func _order101_fresh_w1_result_committed_save(quality: int = 2) -> Dictionary:
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
		CORE.finalize_fresh_w1_application(2, quality)
		if restarted else {})
	var after_send: Dictionary = GameState.serialize().duplicate(true)
	var expected_intelligence_gain := 2 if quality == 3 else 1 if quality == 2 else 0
	_expect(bool(allocation.get("ok", false)) and began_trigger and armed \
		and restarted and bool(finalized.get("ok", false)) \
		and float(after_send.get("money", 0.0)) \
			== float(before_send.get("money", 0.0)) \
		and int(after_send.get("health", 0)) \
			== int(before_send.get("health", 0)) \
		and int(after_send.get("mental", 0)) \
			== clampi(int(before_send.get("mental", 0)) - 2, 0, 100) \
		and int(after_send.get("intelligence", 0)) \
			== int(before_send.get("intelligence", 0)) \
				+ expected_intelligence_gain \
		and int((CORE.action_receipt(
			"m1_youth_center_resume_clinic").get(
				"result_details", {}) as Dictionary).get("quality", -1)) == quality \
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

	var closed_month_save := _order101_closed_m1_for_durable_summary()
	_expect(not closed_month_save.is_empty(),
		"durability fixture could not produce one actual closed M1")
	if closed_month_save.is_empty():
		main_game.free()
		return
	GameState.start_new_game()
	GameState.load_from_dict(closed_month_save.duplicate(true))
	CORE.initialize_for_run(true)
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


func _order101_closed_m1_for_durable_summary() -> Dictionary:
	var result_committed_save := _order101_fresh_w1_result_committed_save(0)
	if result_committed_save.is_empty():
		return {}
	GameState.start_new_game()
	GameState.load_from_dict(result_committed_save.duplicate(true))
	CORE.initialize_for_run(true)
	if CORE.complete_active_bundle() != "m1_youth_center_resume_clinic" \
			or not CORE.pending_seoul_cycle_trigger().is_empty() \
			or not _close_order101_source_month_after_w1():
		return {}
	var cycle := CORE.seoul_cycle_snapshot(1)
	if int(GameState.turn) != 4 \
			or (cycle.get("completed_turns", []) as Array) != [1, 2, 3, 4] \
			or (cycle.get("allocation_receipts", {}) as Dictionary).size() != 4 \
			or int(cycle.get("world_clock", 0)) != 4 \
			or not CORE.month_summary(1).is_empty():
		return {}
	return GameState.serialize().duplicate(true)


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
	var closed_month_save := _order101_closed_m1_for_durable_summary()
	_expect(not closed_month_save.is_empty(),
		"month gate fixture could not produce its actual closed M1")
	if closed_month_save.is_empty():
		return
	GameState.start_new_game()
	GameState.load_from_dict(closed_month_save.duplicate(true))
	CORE.initialize_for_run(true)
	var closed_cycle := CORE.seoul_cycle_snapshot(1)
	var closed_allocations: Dictionary = closed_cycle.get(
		"allocation_receipts", {})
	var closed_turns: Array = closed_cycle.get("completed_turns", [])
	_expect(int(GameState.turn) == 4 \
		and closed_turns == [1, 2, 3, 4] \
		and closed_allocations.size() == 4 \
		and int(closed_cycle.get("world_clock", 0)) == 4 \
		and CORE.month_summary(1).is_empty(),
		"month gate fixture did not close one exact unsummarized M1 cycle")
	if closed_allocations.size() != 4:
		return
	GameState.flags["chapter_33_seen"] = true
	GameState.flags["tutorial_shown"] = true
	var before: Dictionary = CORE.month_opening_snapshot(1)
	var after := {
		"money": float(GameState.money),
		"health": int(GameState.health),
		"mental": int(GameState.mental),
	}
	var main_game: Control = await _spawn_durable_gate_main(false)
	var summary: Dictionary = CORE.record_month_summary(1, before, after)
	_expect(not before.is_empty() \
		and not summary.is_empty() \
		and (summary.get("allocation_receipts", []) as Array).size() == 4 \
		and (summary.get("cycle_completed_turns", []) as Array) == [1, 2, 3, 4] \
		and not bool(summary.get("acknowledged", true)),
		"month gate fixture did not record one exact closed M1 notebook")
	if summary.is_empty():
		_dispose_durable_gate_main(main_game)
		await get_tree().process_frame
		return
	var title_fixture := _order101_begin_title_publish_fixture()
	var title_baseline: Dictionary = title_fixture.get("baseline", {})
	var title_gameplay_frozen: Dictionary = GameState.serialize().duplicate(true)
	main_game.call("_core_loop_v2_show_month_summary", summary)
	await get_tree().process_frame
	var summary_frozen: Dictionary = GameState.serialize().duplicate(true)
	_expect(_durable_gate_is_locked(main_game, "month_summary") \
		and not bool(CORE.month_summary(1).get("acknowledged", true)) \
		and summary_frozen == title_gameplay_frozen \
		and _variant_equal_with_numeric_values(
			_order101_title_publication_snapshot(), title_baseline),
		"month-summary save failure did not replace confirmation with its gate")
	main_game.call("_core_loop_v2_retry_seoul_cycle_autosave")
	await get_tree().process_frame
	_expect(_durable_gate_is_locked(main_game, "month_summary") \
		and GameState.serialize() == summary_frozen \
		and _variant_equal_with_numeric_values(
			_order101_title_publication_snapshot(), title_baseline),
		"failed month-summary retry changed or acknowledged the notebook")
	main_game.set_meta("_qa_core_loop_v2_autosave_result", true)
	main_game.call("_core_loop_v2_retry_seoul_cycle_autosave")
	for _frame in range(4):
		await get_tree().process_frame
	_expect(str(main_game.get("_modal_kind")) \
			== "core_loop_v2_month_summary" \
		and int(main_game.get_meta(
			"_qa_core_loop_v2_autosave_call_count", 0)) == 3 \
		and not bool(CORE.month_summary(1).get("acknowledged", true)) \
		and GameState.serialize() == summary_frozen \
		and MetaProgression.get_unlocked_titles().count(
			"first_investment") == 1 \
		and not _variant_equal_with_numeric_values(
			_order101_title_publication_snapshot(), title_baseline),
		"month-summary retry did not reopen the same notebook without another save")
	var published_title_snapshot := _order101_title_publication_snapshot()
	main_game.call("_core_loop_v2_retry_seoul_cycle_autosave")
	await get_tree().process_frame
	_expect(GameState.serialize() == summary_frozen \
		and MetaProgression.get_unlocked_titles().count(
			"first_investment") == 1 \
		and _variant_equal_with_numeric_values(
			_order101_title_publication_snapshot(), published_title_snapshot),
		"cleared month-summary retry republished its title or changed gameplay")

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
	_order101_restore_title_publish_fixture(title_fixture)
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


func _order101_title_publication_snapshot() -> Dictionary:
	var path := MetaProgression.meta_save_path()
	var exists := FileAccess.file_exists(path)
	return {
		"data": MetaProgression.data.duplicate(true),
		"path": path,
		"file_exists": exists,
		"file_text": FileAccess.get_file_as_string(path) if exists else "",
	}


func _order101_begin_title_publish_fixture() -> Dictionary:
	var original := _order101_title_publication_snapshot()
	var flag_present := GameState.flags.has("had_first_investment")
	var flag_value: Variant = GameState.flags.get("had_first_investment", null)
	var fixture_data: Dictionary = MetaProgression.data.duplicate(true)
	var unlocked: Array = []
	for raw_title in MetaProgression.ALL_TITLES:
		if not raw_title is Dictionary:
			continue
		var title_id := str((raw_title as Dictionary).get("id", ""))
		if not title_id.is_empty() and title_id != "first_investment":
			unlocked.append(title_id)
	fixture_data["unlocked_titles"] = unlocked
	MetaProgression.data = fixture_data
	GameState.flags["had_first_investment"] = true
	return {
		"original": original,
		"flag_present": flag_present,
		"flag_value": flag_value,
		"baseline": _order101_title_publication_snapshot(),
	}


func _order101_restore_title_publish_fixture(fixture: Dictionary) -> void:
	var original: Dictionary = fixture.get("original", {})
	var original_data: Variant = original.get("data", {})
	if original_data is Dictionary:
		MetaProgression.data = (original_data as Dictionary).duplicate(true)
	var path := str(original.get("path", MetaProgression.meta_save_path()))
	if bool(original.get("file_exists", false)):
		var file := FileAccess.open(path, FileAccess.WRITE)
		if file != null:
			file.store_string(str(original.get("file_text", "")))
	elif FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	if bool(fixture.get("flag_present", false)):
		GameState.flags["had_first_investment"] = fixture.get("flag_value")
	else:
		GameState.flags.erase("had_first_investment")


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
	var completed_summary := CORE.record_month_summary(1, {}, {})
	var completed_saved: Dictionary = GameState.serialize().duplicate(true)
	_expect(not completed_summary.is_empty(),
		"completed trigger expiry-coexistence fixture did not close Month One")
	if not completed_summary.is_empty():
		_check_order101_completed_trigger_expiry_coexistence(completed_saved)


func _check_four_week_cycle() -> void:
	_prepare_fresh_cycle_gate()
	var initialized := CORE.initialize_seoul_cycle(1)
	if not bool(initialized.get("ok", false)):
		_expect(false, "four-week path could not initialize")
		return
	var initial_capacities: Array = CORE.seoul_cycle_snapshot(1).get(
		"capacities", []).duplicate(true)
	var actual_month_opening := CORE.month_opening_snapshot(1)
	_expect(not actual_month_opening.is_empty(),
		"four-week cycle did not persist its actual opening authority")
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
	if not actual_month_opening.is_empty():
		var summary_state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
		var opening_snapshots: Dictionary = summary_state.get(
			"month_opening_snapshots", {})
		opening_snapshots["1"] = actual_month_opening.duplicate(true)
		summary_state["month_opening_snapshots"] = opening_snapshots
		GameState.core_loop_v2_state = summary_state
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
	_check_order101_closed_summary_expiry_authority(saved_run)
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


func _check_order101_closed_summary_expiry_authority(
		closed_saved: Dictionary) -> void:
	GameState.start_new_game()
	GameState.load_from_dict(closed_saved.duplicate(true))
	CORE.initialize_for_run(true)
	GameState.turn = 5
	GameState.month = 2
	GameState.week_of_month = 1
	var baseline_state: Dictionary = GameState.core_loop_v2_state
	var baseline_history: Dictionary = CORE._terminal_historical_cycle_summary(
		baseline_state, 1, 5)
	_expect(LocaleManager.language == "en" \
		and GameState.player_name == LocaleManager.DEFAULT_NAME_EN,
		"KO-produced closed summary did not load with its EN display identity")
	_expect(not baseline_history.is_empty(),
		"KO-produced closed summary lost authority after EN reload")
	_expect(_order101_historical_capacity_authority_exact(
		baseline_state, baseline_history, LocaleManager.DEFAULT_NAME_KO),
		"KO-produced closed summary changed its frozen capacity order after EN reload")
	_check_order101_locale_stable_historical_authority()

	var trigger_downgrade: Dictionary = closed_saved.duplicate(true)
	var trigger_state: Dictionary = trigger_downgrade.get(
		"core_loop_v2_state", {})
	var trigger_summaries: Dictionary = trigger_state.get("month_summaries", {})
	var trigger_summary: Dictionary = trigger_summaries.get("1", {})
	var trigger_expiries: Dictionary = trigger_summary.get("expiry_receipts", {})
	var trigger_nodes: Dictionary = trigger_summary.get("node_states", {})
	var trigger_node: Dictionary = trigger_nodes.get("convenience", {})
	var trigger_allocations: Array = trigger_summary.get("allocation_receipts", [])
	var trigger_kept: Array = trigger_summary.get("kept", [])
	var trigger_allocation_index := _order101_summary_allocation_index(
		trigger_allocations, 4, "convenience")
	_expect(trigger_expiries.has("convenience:trigger") \
		and str(trigger_node.get("featured_status", "")) == "expired" \
		and bool(trigger_node.get("fallback_mode", false)) \
		and str(trigger_node.get("missed_trigger_bundle", "")) \
			== "m1_convenience_trial_shift" \
		and trigger_allocation_index >= 0 \
		and bool((trigger_allocations[trigger_allocation_index] \
			as Dictionary).get("fallback_allocation", false)),
		"trigger-expiry downgrade fixture lacked its actual receipt and fallback")
	if trigger_allocation_index >= 0:
		trigger_expiries.erase("convenience:trigger")
		trigger_node.erase("featured_status")
		trigger_node.erase("missed_trigger_bundle")
		trigger_node.erase("fallback_mode")
		var trigger_allocation: Dictionary = (
			trigger_allocations[trigger_allocation_index] as Dictionary).duplicate(
				true)
		var ordinary_gain := CORE._seoul_cycle_progress_for_capacity(
			int(trigger_allocation.get("capacity_value", 0)))
		trigger_allocation["fallback_allocation"] = false
		trigger_allocation["progress_gain"] = ordinary_gain
		trigger_allocation["progress_after"] = ordinary_gain
		var trigger_weekly: Dictionary = trigger_allocation.get(
			"weekly_commitment", {}).duplicate(true)
		var trigger_details: Dictionary = trigger_weekly.get(
			"details", {}).duplicate(true)
		trigger_details["fallback_allocation"] = false
		trigger_details["progress_gain"] = ordinary_gain
		trigger_details["progress_after"] = ordinary_gain
		trigger_weekly["details"] = trigger_details
		trigger_allocation["weekly_commitment"] = trigger_weekly
		trigger_allocations[trigger_allocation_index] = trigger_allocation
		trigger_node["progress"] = ordinary_gain
		for index in range(trigger_kept.size()):
			if trigger_kept[index] is Dictionary \
					and int((trigger_kept[index] as Dictionary).get(
						"week", 0)) == 4:
				var kept: Dictionary = (trigger_kept[index] as Dictionary).duplicate(
					true)
				kept["fallback_allocation"] = false
				kept["progress_gain"] = ordinary_gain
				trigger_kept[index] = kept
		for index in range((trigger_downgrade.get(
				"weekly_commitments", []) as Array).size()):
			var outer: Variant = (trigger_downgrade.get(
				"weekly_commitments", []) as Array)[index]
			if outer is Dictionary and int((outer as Dictionary).get(
					"turn", 0)) == 4:
				var outer_record: Dictionary = (outer as Dictionary).duplicate(true)
				var outer_details: Dictionary = outer_record.get(
					"details", {}).duplicate(true)
				outer_details["fallback_allocation"] = false
				outer_details["progress_gain"] = ordinary_gain
				outer_details["progress_after"] = ordinary_gain
				outer_record["details"] = outer_details
				(trigger_downgrade["weekly_commitments"] as Array)[index] = \
					outer_record
		trigger_nodes["convenience"] = trigger_node
		trigger_summary["node_states"] = trigger_nodes
		trigger_summary["expiry_receipts"] = trigger_expiries
		trigger_summary["allocation_receipts"] = trigger_allocations
		trigger_summary["kept"] = trigger_kept
		trigger_summaries["1"] = trigger_summary
		trigger_state["month_summaries"] = trigger_summaries
		trigger_downgrade["core_loop_v2_state"] = trigger_state
		_check_order101_historical_expiry_mutation_rejected(
			trigger_downgrade,
			"coupled trigger-expiry marker and fallback downgrade")

	var node_downgrade: Dictionary = closed_saved.duplicate(true)
	var node_state: Dictionary = node_downgrade.get("core_loop_v2_state", {})
	var node_summaries: Dictionary = node_state.get("month_summaries", {})
	var node_summary: Dictionary = node_summaries.get("1", {})
	var node_expiries: Dictionary = node_summary.get("expiry_receipts", {})
	var node_expired: Array = node_summary.get("expired_nodes", [])
	var node_nodes: Dictionary = node_summary.get("node_states", {})
	var resume_node: Dictionary = node_nodes.get("resume", {})
	_expect(node_expiries.has("resume") \
		and node_expired.count("resume") == 1 \
		and str(resume_node.get("status", "")) == "expired" \
		and int(resume_node.get("expired_turn", 0)) == 3,
		"node-expiry downgrade fixture lacked its actual Resume expiry")
	node_expiries.erase("resume")
	while node_expired.has("resume"):
		node_expired.erase("resume")
	resume_node["status"] = "open"
	resume_node.erase("expired_turn")
	node_nodes["resume"] = resume_node
	var node_allocations: Array = node_summary.get("allocation_receipts", [])
	for index in range(node_allocations.size()):
		if not node_allocations[index] is Dictionary:
			continue
		var allocation: Dictionary = (
			node_allocations[index] as Dictionary).duplicate(true)
		var allocation_expired: Array = allocation.get("expired_nodes", [])
		while allocation_expired.has("resume"):
			allocation_expired.erase("resume")
		allocation["expired_nodes"] = allocation_expired
		node_allocations[index] = allocation
	node_summary["expiry_receipts"] = node_expiries
	node_summary["expired_nodes"] = node_expired
	node_summary["node_states"] = node_nodes
	node_summary["allocation_receipts"] = node_allocations
	node_summaries["1"] = node_summary
	node_state["month_summaries"] = node_summaries
	node_downgrade["core_loop_v2_state"] = node_state
	_check_order101_historical_expiry_mutation_rejected(
		node_downgrade, "coupled node-expiry downgrade")

	var post_expiry: Dictionary = closed_saved.duplicate(true)
	var post_state: Dictionary = post_expiry.get("core_loop_v2_state", {})
	var post_summaries: Dictionary = post_state.get("month_summaries", {})
	var post_summary: Dictionary = post_summaries.get("1", {})
	var post_nodes: Dictionary = post_summary.get("node_states", {})
	var post_node: Dictionary = post_nodes.get("convenience", {})
	var post_allocations: Array = post_summary.get("allocation_receipts", [])
	var post_index := _order101_summary_allocation_index(
		post_allocations, 4, "convenience")
	var post_expiries: Dictionary = post_summary.get("expiry_receipts", {})
	var post_receipt: Dictionary = post_expiries.get("convenience", {})
	_expect(post_index >= 0 \
		and int(post_node.get("expired_turn", 0)) == 4 \
		and int(post_node.get("last_allocation_turn", 0)) == 4 \
		and int(post_receipt.get("turn", 0)) == 4,
		"post-expiry allocation fixture lacked its actual W4 boundary")
	if post_index >= 0:
		post_node["expired_turn"] = 3
		post_nodes["convenience"] = post_node
		post_receipt["turn"] = 3
		post_receipt["week_index"] = 3
		post_expiries["convenience"] = post_receipt
		for index in range(post_allocations.size()):
			if not post_allocations[index] is Dictionary:
				continue
			var allocation: Dictionary = (
				post_allocations[index] as Dictionary).duplicate(true)
			var allocation_expired: Array = allocation.get("expired_nodes", [])
			if int(allocation.get("turn", 0)) == 3 \
					and not allocation_expired.has("convenience"):
				allocation_expired.append("convenience")
			if int(allocation.get("turn", 0)) == 4:
				while allocation_expired.has("convenience"):
					allocation_expired.erase("convenience")
			allocation["expired_nodes"] = allocation_expired
			post_allocations[index] = allocation
		post_summary["node_states"] = post_nodes
		post_summary["expiry_receipts"] = post_expiries
		post_summary["allocation_receipts"] = post_allocations
		post_summaries["1"] = post_summary
		post_state["month_summaries"] = post_summaries
		post_expiry["core_loop_v2_state"] = post_state
		_check_order101_historical_expiry_mutation_rejected(
			post_expiry, "allocation after a coupled earlier node expiry")


func _check_order101_completed_trigger_expiry_coexistence(
		completed_saved: Dictionary) -> void:
	GameState.start_new_game()
	GameState.load_from_dict(completed_saved.duplicate(true))
	CORE.initialize_for_run(true)
	GameState.turn = 5
	GameState.month = 2
	GameState.week_of_month = 1
	_expect(not CORE._terminal_historical_cycle_summary(
		GameState.core_loop_v2_state, 1, 5).is_empty(),
		"completed-trigger coexistence fixture lacked genuine historical authority")
	var malformed: Dictionary = completed_saved.duplicate(true)
	var state: Dictionary = malformed.get("core_loop_v2_state", {})
	var summaries: Dictionary = state.get("month_summaries", {})
	var summary: Dictionary = summaries.get("1", {})
	var nodes: Dictionary = summary.get("node_states", {})
	var node: Dictionary = nodes.get("convenience", {})
	var triggers: Dictionary = summary.get("trigger_receipts", {})
	var expiries: Dictionary = summary.get("expiry_receipts", {})
	_expect(str(node.get("status", "")) == "completed" \
		and int(node.get("completed_turn", 0)) == 2 \
		and str((triggers.get("convenience", {}) as Dictionary).get(
			"bundle_id", "")) == "m1_convenience_trial_shift" \
		and not expiries.has("convenience:trigger"),
		"completed-trigger coexistence fixture lacked its exact resolved branch")
	var effect_snapshot := {"health": 50, "mental": 50, "money": 0.0}
	expiries["convenience:trigger"] = {
		"scope": "trigger",
		"node_id": "convenience",
		"trigger_bundle": "m1_convenience_trial_shift",
		"turn": 3,
		"week_index": 3,
		"status": "consumed",
		"consequence_id": "m1_cover_shift_window_closed",
		"effects": {},
		"before": effect_snapshot.duplicate(true),
		"after": effect_snapshot.duplicate(true),
	}
	node["featured_status"] = "expired"
	node["missed_trigger_bundle"] = "m1_convenience_trial_shift"
	node["fallback_mode"] = true
	nodes["convenience"] = node
	summary["node_states"] = nodes
	summary["expiry_receipts"] = expiries
	summaries["1"] = summary
	state["month_summaries"] = summaries
	malformed["core_loop_v2_state"] = state
	_check_order101_historical_expiry_mutation_rejected(
		malformed, "resolved trigger plus canonical sibling trigger expiry")


func _check_order101_locale_stable_historical_authority() -> void:
	var en_to_ko := _order101_produce_locale_closed_cycle(
		"en", "ko", LocaleManager.DEFAULT_NAME_EN)
	if not en_to_ko.is_empty():
		_check_order101_locale_history_accepts(
			en_to_ko, "ko", LocaleManager.DEFAULT_NAME_EN,
			LocaleManager.DEFAULT_NAME_KO, "EN-to-KO default name")

	const CUSTOM_NAME := "하늘고래"
	var custom_to_en := _order101_produce_locale_closed_cycle(
		"ko", "en", CUSTOM_NAME)
	if not custom_to_en.is_empty():
		_check_order101_locale_history_accepts(
			custom_to_en, "en", CUSTOM_NAME, CUSTOM_NAME,
			"custom-name KO-to-EN")

	var default_mismatch := en_to_ko.duplicate(true)
	if not default_mismatch.is_empty():
		default_mismatch["player_name"] = "다른 사용자 이름"
		_check_order101_locale_history_rejects(
			default_mismatch, "ko", "current player name only")

	var signature_mismatch := custom_to_en.duplicate(true)
	if not signature_mismatch.is_empty():
		var mismatch_state: Dictionary = signature_mismatch.get(
			"core_loop_v2_state", {})
		var mismatch_summaries: Dictionary = mismatch_state.get(
			"month_summaries", {})
		var mismatch_summary: Dictionary = mismatch_summaries.get("1", {})
		var mismatch_authority: Dictionary = mismatch_summary.get(
			"historical_cycle_authority", {})
		var source_health := int(mismatch_authority.get("source_health", 0))
		var source_mental := int(mismatch_authority.get("source_mental", 0))
		mismatch_authority["seed_signature"] = CORE._seoul_cycle_seed_signature(
			1, source_health, source_mental, "위조된 이름")
		mismatch_summary["historical_cycle_authority"] = mismatch_authority
		mismatch_summaries["1"] = mismatch_summary
		mismatch_state["month_summaries"] = mismatch_summaries
		signature_mismatch["core_loop_v2_state"] = mismatch_state
		_check_order101_locale_history_rejects(
			signature_mismatch, "en", "seed signature only")


func _order101_produce_locale_closed_cycle(
		source_language: String, target_language: String,
		player_name: String) -> Dictionary:
	LocaleManager.set_language(source_language)
	GameState.start_new_game(
		player_name, "지방_상경", "직장형", "백수", "자유런", "현실")
	CORE.initialize_for_run(true)
	GameState.flags["prologue_done"] = true
	var state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	state["application_statuses"]["mirae_industrial_tech"] = "interviewed"
	GameState.core_loop_v2_state = state
	var initialized := CORE.initialize_seoul_cycle(1)
	_expect(bool(initialized.get("ok", false)) \
		and str(GameState.player_name) == player_name,
		"%s locale authority fixture could not initialize its actual cycle" \
			% source_language)
	if not bool(initialized.get("ok", false)):
		return {}
	for turn in range(1, 5):
		var snapshot := CORE.seoul_cycle_snapshot(1)
		var capacity_id := _unused_capacity(snapshot, 0, true)
		var committed := CORE.commit_seoul_cycle_allocation(
			capacity_id, "recovery", 1)
		if not bool(committed.get("ok", false)):
			_expect(false, "%s locale authority W%d allocation failed" % [
				source_language, turn])
			return {}
		if turn == 3 and not _resolve_cycle_story_world(
				"hyunsu_first_meet", HYUNSU_EVENT, 0):
			return {}
		if turn == 4 and not _resolve_cycle_story_world(
				"first_temptation_boss", TEMPTATION_EVENT, 0):
			return {}
		if not bool(CORE.complete_seoul_cycle_turn(1).get("ok", false)):
			_expect(false, "%s locale authority W%d could not close" % [
				source_language, turn])
			return {}
		if turn < 4:
			_advance_to_next_week()
	var summary := CORE.record_month_summary(1, {}, {})
	_expect(not summary.is_empty(),
		"%s locale authority did not produce a closed summary" \
			% source_language)
	if summary.is_empty():
		return {}
	LocaleManager.set_language(target_language)
	return GameState.serialize().duplicate(true)


func _check_order101_locale_history_accepts(
		saved: Dictionary, target_language: String, frozen_seed_name: String,
		expected_current_name: String, label: String) -> void:
	LocaleManager.set_language(target_language)
	GameState.start_new_game()
	GameState.load_from_dict(saved.duplicate(true))
	CORE.initialize_for_run(true)
	GameState.turn = 5
	GameState.month = 2
	GameState.week_of_month = 1
	var state: Dictionary = GameState.core_loop_v2_state
	var history := CORE._terminal_historical_cycle_summary(state, 1, 5)
	_expect(LocaleManager.language == target_language \
		and str(GameState.player_name) == expected_current_name \
		and _order101_historical_capacity_authority_exact(
			state, history, frozen_seed_name),
		"%s locale transition lost exact historical capacity authority" % label)


func _check_order101_locale_history_rejects(
		saved: Dictionary, target_language: String, label: String) -> void:
	LocaleManager.set_language(target_language)
	GameState.start_new_game()
	GameState.load_from_dict(saved.duplicate(true))
	CORE.initialize_for_run(true)
	GameState.turn = 5
	GameState.month = 2
	GameState.week_of_month = 1
	_expect(CORE._terminal_historical_cycle_summary(
		GameState.core_loop_v2_state, 1, 5).is_empty(),
		"locale history accepted %s mutation" % label)


func _order101_historical_capacity_authority_exact(
		state: Dictionary, history: Dictionary,
		frozen_seed_name: String) -> bool:
	if history.is_empty():
		return false
	var summary: Dictionary = history.get("summary", {})
	var authority: Dictionary = summary.get("historical_cycle_authority", {})
	var source_health := int(authority.get("source_health", -1))
	var source_mental := int(authority.get("source_mental", -1))
	if str(authority.get("seed_signature", "")) \
			!= CORE._seoul_cycle_seed_signature(
				1, source_health, source_mental, frozen_seed_name):
		return false
	var expected := CORE._generated_seoul_cycle_capacities(
		1, source_health, source_mental, frozen_seed_name)
	var actual: Array = authority.get("capacities", [])
	if actual.size() != expected.size() or actual.size() != 4:
		return false
	for index in range(expected.size()):
		if not actual[index] is Dictionary or not expected[index] is Dictionary:
			return false
		for key in ["id", "value", "quality"]:
			if (actual[index] as Dictionary).get(key, null) \
					!= (expected[index] as Dictionary).get(key, null):
				return false
	return not CORE._terminal_historical_capacity_values(
		state, 1, authority).is_empty()


func _check_order101_historical_expiry_mutation_rejected(
		malformed: Dictionary, label: String) -> void:
	GameState.start_new_game()
	GameState.load_from_dict(malformed.duplicate(true))
	CORE.initialize_for_run(true)
	GameState.turn = 5
	GameState.month = 2
	GameState.week_of_month = 1
	_expect(CORE._terminal_historical_cycle_summary(
		GameState.core_loop_v2_state, 1, 5).is_empty(),
		"closed summary accepted %s" % label)


func _order101_summary_allocation_index(
		allocations: Array, turn: int, node_id: String) -> int:
	for index in range(allocations.size()):
		if allocations[index] is Dictionary \
				and int((allocations[index] as Dictionary).get("turn", 0)) == turn \
				and str((allocations[index] as Dictionary).get(
					"node_id", "")) == node_id:
			return index
	return -1


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
	var story_stage := CORE.action_story_stage(bundle_id) if action_noted else ""
	var acknowledged := action_noted
	if story_stage == "story":
		acknowledged = CORE.acknowledge_action_story_result(bundle_id)
	_expect(bool(claimed.get("ok", false)) and began and armed \
		and bool(transaction.get("ok", false)) and action_noted \
		and acknowledged,
		"livelihood trigger did not produce its supplemental action receipt")
	if not acknowledged:
		return false
	if story_stage == "story":
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


func _deduplicated_strings(raw_values: Array[String]) -> Array[String]:
	var result: Array[String] = []
	for raw_value in raw_values:
		if not result.has(raw_value):
			result.append(raw_value)
	return result


func _int_values(raw_values: Array) -> Array[int]:
	var result: Array[int] = []
	for raw_value in raw_values:
		result.append(int(raw_value))
	return result


func _dictionary_equal_with_numeric_values(
		left_raw: Variant, right_raw: Variant) -> bool:
	if not left_raw is Dictionary or not right_raw is Dictionary:
		return false
	var left: Dictionary = left_raw
	var right: Dictionary = right_raw
	if _sorted_strings(left.keys()) != _sorted_strings(right.keys()):
		return false
	for raw_key in left:
		var key := str(raw_key)
		var left_value: Variant = left.get(raw_key)
		var right_value: Variant = right.get(key)
		if left_value is Dictionary or right_value is Dictionary:
			if not _dictionary_equal_with_numeric_values(
					left_value, right_value):
				return false
		elif typeof(left_value) in [TYPE_INT, TYPE_FLOAT] \
				and typeof(right_value) in [TYPE_INT, TYPE_FLOAT]:
			if float(left_value) != float(right_value):
				return false
		elif left_value != right_value:
			return false
	return true


func _variant_equal_with_numeric_values(
		left: Variant, right: Variant) -> bool:
	if left is Dictionary or right is Dictionary:
		if not left is Dictionary or not right is Dictionary:
			return false
		var left_dictionary: Dictionary = left
		var right_dictionary: Dictionary = right
		if _sorted_strings(left_dictionary.keys()) \
				!= _sorted_strings(right_dictionary.keys()):
			return false
		for raw_key in left_dictionary:
			if typeof(raw_key) != TYPE_STRING:
				return false
			var key := str(raw_key)
			if not right_dictionary.has(key):
				return false
			if not _variant_equal_with_numeric_values(
					left_dictionary.get(raw_key), right_dictionary.get(key)):
				return false
		return true
	if left is Array or right is Array:
		if not left is Array or not right is Array \
				or (left as Array).size() != (right as Array).size():
			return false
		for index in range((left as Array).size()):
			if not _variant_equal_with_numeric_values(
					(left as Array)[index], (right as Array)[index]):
				return false
		return true
	if typeof(left) in [TYPE_INT, TYPE_FLOAT] \
			or typeof(right) in [TYPE_INT, TYPE_FLOAT]:
		return typeof(left) in [TYPE_INT, TYPE_FLOAT] \
			and typeof(right) in [TYPE_INT, TYPE_FLOAT] \
			and is_finite(float(left)) and is_finite(float(right)) \
			and float(left) == float(right)
	return left == right


func _terminal_record_equal_with_numeric_effects(
		left_raw: Variant, right_raw: Variant) -> bool:
	if not left_raw is Dictionary or not right_raw is Dictionary:
		return false
	var left: Dictionary = left_raw
	var right: Dictionary = right_raw
	if _sorted_strings(left.keys()) != _sorted_strings(right.keys()):
		return false
	for raw_key in left:
		var key := str(raw_key)
		if key == "completion_effects":
			if not _dictionary_equal_with_numeric_values(
					left.get(raw_key), right.get(key)):
				return false
		elif left.get(raw_key) != right.get(key):
			return false
	return true


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
