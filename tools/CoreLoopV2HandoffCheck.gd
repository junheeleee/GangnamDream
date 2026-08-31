extends Node
## ORDER-57: Week-24 V2 receipts must rejoin the real Chapter-One scheduler.

const CORE_LOOP := preload("res://systems/DemoCoreLoopV2.gd")
const FULL_ROUTE_CHECK := preload("res://tools/CoreLoopV2ECheck.gd")
const MAIN_GAME_SCRIPT := preload("res://scenes/MainGame.gd")
const PHONE_SYSTEM := preload("res://systems/PhoneSystem.gd")

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

const ACTUAL_CARRYOVER_PATHS := [
	"clean_unemployed_low",
	"clean_hired_recovery_high",
	"dirty_return_recovery_low",
	"dirty_deeper_growth",
]

const DIRTY_RECEIPT_PATHS := {
	"dirty_return_recovery_low": {
		"source": "callback_escaped_dirty_trace",
		"root": "v2_dirty_trace_initial_call",
		"synthetic": false,
	},
	"dirty_deeper_growth": {
		"source": "fell_to_darkness",
		"root": "v2_dirty_recruiter_week24",
		"synthetic": true,
	},
}

# JobSystem uses Godot's global RNG for monthly stat/performance rolls. These
# fixed seeds make the exact component ledger reproducible without pretending
# that the production UI chose a random vignette outcome.
const ACTUAL_CARRYOVER_RNG_SEEDS := {
	"clean_unemployed_low": 69_101,
	"clean_hired_recovery_high": 69_102,
	"dirty_return_recovery_low": 69_103,
	"dirty_deeper_growth": 69_104,
}

const ACTUAL_RESCUE_JOB_WEEKS := {
	"clean_unemployed_low": 32,
	"dirty_return_recovery_low": 30,
	"dirty_deeper_growth": 30,
}

const ACTUAL_WEEK_24_SNAPSHOTS := {
	"clean_unemployed_low": [-769_500, 26, 64, false],
	"clean_hired_recovery_high": [3_580_500, 40, 93, true],
	"dirty_return_recovery_low": [-1_949_500, 67, 71, false],
	"dirty_deeper_growth": [4_510_500, 21, 48, false],
}

const ACTUAL_CARRYOVER_EXPECTED := {
	"clean_unemployed_low": {
		"final": [1_900_500.0, 26, 51],
		"floor": [24, 38],
		"recovery_turns": [29, 33, 41, 45],
		"months": [
			[-1_419_500.0, 24, 41, false],
			[-749_500.0, 25, 43, true],
			[-79_500.0, 26, 48, true],
			[560_500.0, 24, 38, true],
			[1_230_500.0, 25, 50, true],
			[1_900_500.0, 26, 51, true],
		],
	},
	"clean_hired_recovery_high": {
		"final": [12_105_862.0, 28, 56],
		"floor": [28, 47],
		"recovery_turns": [],
		"months": [
			[4_185_862.0, 38, 76, true],
			[5_775_862.0, 36, 71, true],
			[7_335_862.0, 34, 64, true],
			[8_925_862.0, 32, 58, true],
			[10_515_862.0, 30, 49, true],
			[12_105_862.0, 28, 56, true],
		],
	},
	"dirty_return_recovery_low": {
		"final": [720_500.0, 61, 47],
		"floor": [59, 20],
		"recovery_turns": [41, 46],
		"months": [
			[-2_599_500.0, 65, 48, false],
			[-1_929_500.0, 63, 44, true],
			[-1_289_500.0, 61, 43, true],
			[-619_500.0, 59, 20, true],
			[50_500.0, 60, 31, true],
			[720_500.0, 61, 47, true],
		],
	},
	"dirty_deeper_growth": {
		"final": [5_940_112.0, 24, 58],
		"floor": [21, 39],
		"recovery_turns": [25, 29, 37, 41],
		"months": [
			[2_620_112.0, 25, 39, false],
			[3_290_112.0, 26, 52, true],
			[3_960_112.0, 24, 51, true],
			[4_600_112.0, 25, 55, true],
			[5_270_112.0, 26, 69, true],
			[5_940_112.0, 24, 58, true],
		],
	},
}

var _failures: Array[String] = []
var _autosave_backup: Dictionary = {}
var _main_game: Node = null
var _carryover_evidence: Array[String] = []
var _carryover_route_evidence: Array[String] = []


func _ready() -> void:
	_backup_autosave()
	var original_sfx_enabled := AudioManager.sfx_enabled
	AudioManager.sfx_enabled = false

	_check_hyunsu_min_turn_and_legacy_timing()
	_check_father_signal_replaces_skipped_first_call()
	_check_lent_account_flag_migration()
	_check_phone_purchase_retirement_migration()
	_check_durable_legacy_replacements()
	_check_identity_retirement_boundaries()
	_check_v1_dirty_receipt_non_inference()
	_check_actual_snapshot_carryover()
	_check_v2_week_24_handoff()
	await _check_side_shift_identity_boundaries()

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
			+ "v2_result=week25_26_hidden/week27_fail/week31_aftermath/"
			+ "week36_drift/week42_new_path "
			+ "legacy=week25_26_fail/week29_30_aftermath/"
			+ "week34_35_drift/week40_41_new_path "
			+ "city=week28/no_offer/save_load "
			+ "father=week21_replaces_skipped_first_call "
			+ "migration=clean_preserved/dirty_preserved/legacy_pollution_removed "
			+ "phone_retirement=valid_refund_once/forged_zero "
			+ "legacy_replacements=durable_receipts/suppression_cleared "
			+ "identity_retirement=week24_48_240/save_load/legacy_values_preserved "
			+ "dirty_receipt=week24_48_240/exact/no_generic/v1_no_inference "
			+ "side_shift_identity=v2_week25_48_240_zero/v1_founder_preserved "
			+ "carryover=component_runtime/e_component_snapshots4/"
			+ "autosave_roundtrip4/week25_48/weekly_actions24/"
			+ "deterministic_authored_vignette_index1/monthly_pressure6/"
			+ "scheduler_claim_once/same_week_followups/"
			+ "cafe_affordability_policy_nonpositive_cash/"
			+ "calendar_advances24/no_date_teleport/"
			+ "post_cap_routine_attempts24_per_route_blocked/"
			+ "choice0_safety_net_W30_32_unemployed3/whole_won_cash/"
			+ "year1_close/natural_chapter34 evidence=%s "
				% ",".join(_carryover_evidence)
			+ "routes=%s " % ",".join(_carryover_route_evidence)
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


func _check_v1_dirty_receipt_non_inference() -> void:
	GameState.start_new_game()
	GameState.flags["escaped_dirty_money"] = true
	GameState.flags["fell_to_darkness"] = true
	for boundary in [24, 48, 240]:
		_set_turn_date(boundary)
		var snapshot: Dictionary = GameState.serialize().duplicate(true)
		GameState.start_new_game()
		GameState.load_from_dict(snapshot)
		var v1_state_before: Dictionary = \
			GameState.core_loop_v2_state.duplicate(true)
		var initialized := CORE_LOOP.initialize_for_run()
		var raw_deferred: Variant = GameState.core_loop_v2_state.get(
			"deferred_callback_receipts", {})
		_expect(not initialized \
				and GameState.core_loop_v2_state == v1_state_before \
				and (not raw_deferred is Dictionary \
					or (raw_deferred as Dictionary).is_empty()) \
				and _dirty_generic_story_receipt_count() == 0,
			"V1 dirty flags inferred a V2 choice receipt at Week %d" % boundary)


func _check_actual_snapshot_carryover() -> void:
	# This is a component-runtime bridge: real E snapshots, production
	# GameState/system transactions, and MainGame's actual scheduler. The live
	# MainGame completion CTA intentionally still owns the shipped Week-24 UI.
	var meta_data_backup: Dictionary = MetaProgression.data.duplicate(true)
	var raw_new_this_run: Variant = MetaProgression.get("_new_this_run")
	var new_this_run_backup: Dictionary = (
		(raw_new_this_run as Dictionary).duplicate(true)
		if raw_new_this_run is Dictionary else {})
	MetaProgression.data = DataRegistry.default_meta.duplicate(true)
	MetaProgression.set("_new_this_run", {"achievements": []})
	_carryover_evidence.clear()
	_carryover_route_evidence.clear()

	for path_id in ACTUAL_CARRYOVER_PATHS:
		seed(int(ACTUAL_CARRYOVER_RNG_SEEDS[path_id]))
		var route_result := FULL_ROUTE_CHECK.build_full_route_snapshot(path_id)
		_expect(bool(route_result.get("ok", false)),
			"actual carryover source %s failed E runtime: %s" % [
				path_id, str(route_result.get("errors", []))])
		if not bool(route_result.get("ok", false)):
			continue
		var snapshot: Dictionary = route_result.get("snapshot", {})
		var expected_start: Array = ACTUAL_WEEK_24_SNAPSHOTS[path_id]
		if not _roundtrip_actual_week_24_snapshot(
				path_id, snapshot, expected_start):
			continue
		_expect(int(GameState.turn) == 25 \
				and int(GameState.money) == int(expected_start[0]) \
				and int(GameState.health) == int(expected_start[1]) \
				and int(GameState.mental) == int(expected_start[2]) \
				and (not GameState.current_job.is_empty()) == bool(expected_start[3]) \
				and CORE_LOOP.is_prototype_complete() \
				and not CORE_LOOP.is_active(),
			"%s did not load its exact unreset W24→25 snapshot" % path_id)
		var dirty_receipt_spec: Dictionary = {}
		if DIRTY_RECEIPT_PATHS.has(path_id):
			dirty_receipt_spec = (
				DIRTY_RECEIPT_PATHS[path_id] as Dictionary).duplicate(true)
		var dirty_receipt_at_24: Dictionary = {}
		if not dirty_receipt_spec.is_empty():
			dirty_receipt_at_24 = _exact_dirty_deferred_receipt(
				dirty_receipt_spec)
			_expect(not dirty_receipt_at_24.is_empty() \
					and _dirty_generic_story_receipt_count() == 0,
				("%s W24 snapshot did not contain only its exact dirty receipt: "
				+ "deferred=%s generic=%d") % [
					path_id,
					str(GameState.core_loop_v2_state.get(
						"deferred_callback_receipts", {})),
					_dirty_generic_story_receipt_count(),
				])

		var v2_before: Dictionary = GameState.core_loop_v2_state.duplicate(true)
		var routines_before: Dictionary = (
			v2_before.get("routine_receipts", {}) as Dictionary).duplicate(true)
		var routine_units_before := _routine_unit_count(routines_before)
		var completed_before: Array = (
			v2_before.get("completed_turns", []) as Array).duplicate(true)
		var plans_before: Dictionary = (
			v2_before.get("plans", {}) as Dictionary).duplicate(true)
		var summaries_before: Dictionary = (
			v2_before.get("month_summaries", {}) as Dictionary).duplicate(true)
		var declines_before: Array = (
			v2_before.get("decline_receipts", []) as Array).duplicate(true)
		var v2_actions_before: Dictionary = (
			v2_before.get("action_receipts", {}) as Dictionary).duplicate(true)

		_recreate_main_game()
		if not is_instance_valid(_main_game):
			continue
		var job_system: Node = load("res://systems/JobSystem.gd").new()
		var relationship_system: Node = load(
			"res://systems/RelationshipSystem.gd").new()
		var inventory_system: Node = load(
			"res://systems/InventorySystem.gd").new()
		var floors := {
			"health": int(GameState.health),
			"mental": int(GameState.mental),
		}
		var month_checkpoints: Array[String] = []
		var month_checkpoint_values: Array = []
		var routed_by_week: Dictionary = {}
		var routed_chains_by_week: Dictionary = {}
		var routed_trace: Array[String] = []
		var recovery_turns: Array[int] = []
		var pressure_count := 0
		var action_count := 0
		var advance_count := 0
		var post_cap_routine_attempts := 0
		var city_resolution_count := 0
		var month_end_turns: Array[int] = []
		var route_failed := false

		for expected_week in range(25, 49):
			var week_index := expected_week - 1
			var expected_date := [
				2026 + int(week_index / 48),
				int(posmod(week_index, 48) / 4) + 1,
				posmod(week_index, 4) + 1,
				33 + int(week_index / 48),
			]
			if int(GameState.turn) != expected_week \
					or [GameState.year, GameState.month,
						GameState.week_of_month, GameState.age] != expected_date:
				_expect(false,
					"%s calendar drift at Week %d: turn=%d date=%s expected=%s" % [
						path_id, expected_week, int(GameState.turn),
						str([GameState.year, GameState.month,
							GameState.week_of_month, GameState.age]),
						str(expected_date)])
				route_failed = true
				break

			if not _post_cap_routine_attempt_is_inert(
					path_id, expected_week):
				route_failed = true
				break
			post_cap_routine_attempts += 1

			var route_probe := _route_current_carryover_week(
				path_id, expected_week)
			if not bool(route_probe.get("ok", false)):
				route_failed = true
				break
			var routed_id := str(route_probe.get("event_id", ""))
			if not routed_id.is_empty():
				routed_by_week[str(expected_week)] = routed_id
				var applied_chain: Array[String] = []
				var chain_state := {"city_resolutions": 0}
				if not _apply_event_choice_chain(
						routed_id, 0, applied_chain, {}, chain_state):
					route_failed = true
					break
				city_resolution_count += int(chain_state.get(
					"city_resolutions", 0))
				routed_chains_by_week[str(expected_week)] = \
					applied_chain.duplicate()
				if expected_week == 25:
					var should_wait_for_cafe := float(expected_start[0]) <= 0.0
					_expect(
						bool(GameState.flags.get(
							"cafe_honest_patient", false)) == should_wait_for_cafe \
						and bool(GameState.flags.get(
							"cafe_honest_invested", false)) \
							== (not should_wait_for_cafe),
						("%s W25 cafe choice ignored its %.1f balance "
						+ "affordability policy") % [
							path_id, float(expected_start[0])])
				routed_trace.append("%d=%s" % [
					expected_week, ">".join(applied_chain)])
				for chain_event_id in applied_chain:
					if EventManager.narrative_event_owns_commitment(
							chain_event_id, expected_week):
						_expect(false,
							("%s Week %d event %s owns the weekly commitment; "
							+ "the component action must not double-spend it") % [
								path_id, expected_week, chain_event_id])
						route_failed = true
						break
				if route_failed:
					break
				if routed_id == CITY_RESULT:
					_expect(int(chain_state.get("city_resolutions", 0)) == 1,
						"%s Week-28 City result did not resolve exactly once"
							% path_id)
				else:
					_expect(int(chain_state.get("city_resolutions", 0)) == 0,
						"%s Week %d non-City chain resolved a City receipt" % [
							path_id, expected_week])
				_capture_actual_carryover_floors(floors)
				if not _actual_carryover_survives(path_id, expected_week):
					route_failed = true
					break

			var expected_target := _actual_carryover_target(
				path_id, expected_week)
			if not expected_target.is_empty():
				_expect(routed_id == expected_target,
					"%s Week %d routed %s instead of %s" % [
						path_id, expected_week, routed_id, expected_target])
				if routed_id != expected_target:
					route_failed = true
					break

			var action := _apply_actual_carryover_action()
			_expect(bool(action.get("ok", false)),
				"%s Week %d atomic action failed: %s" % [
					path_id, expected_week, str(action)])
			if not bool(action.get("ok", false)):
				route_failed = true
				break
			var current_action_receipt := GameState.get_weekly_commitment_for_turn(
				expected_week)
			_expect(not current_action_receipt.is_empty() \
					and int(current_action_receipt.get("turn", 0)) \
						== expected_week \
					and str(current_action_receipt.get(
						"actual_action_id", "")) == str(action.get(
							"action_id", "")),
				"%s Week %d did not finalize its production action receipt"
					% [path_id, expected_week])
			action_count += 1
			if str(action.get("action_id", "")) == "rest":
				recovery_turns.append(expected_week)
			_capture_actual_carryover_floors(floors)
			if not _actual_carryover_survives(path_id, expected_week):
				route_failed = true
				break

			if expected_week % 4 == 0:
				_capture_actual_carryover_floors(floors)
				job_system.call("process_monthly_job")
				_capture_actual_carryover_floors(floors)
				if not _actual_carryover_survives(path_id, expected_week):
					route_failed = true
					break
				relationship_system.call("process_monthly_relationships")
				_capture_actual_carryover_floors(floors)
				if not _actual_carryover_survives(path_id, expected_week):
					route_failed = true
					break
				inventory_system.call("process_monthly_items")
				_capture_actual_carryover_floors(floors)
				if not _actual_carryover_survives(path_id, expected_week):
					route_failed = true
					break
				if not GameState.current_job.is_empty():
					GameState.add_tendency("career", 1)
				_capture_actual_carryover_floors(floors)
				_expect(not GameState.claim_initial_settlement_subsidy(),
					"%s reclaimed the opening subsidy after Week 24" % path_id)
				_capture_actual_carryover_floors(floors)
				GameState.apply_monthly_pressure()
				pressure_count += 1
				_capture_actual_carryover_floors(floors)
				if not _actual_carryover_survives(path_id, expected_week):
					route_failed = true
					break
				var month_ended := GameState.advance_calendar()
				advance_count += 1
				_expect(month_ended,
					"%s Week %d did not close its fourth calendar week" % [
						path_id, expected_week])
				if month_ended:
					month_end_turns.append(expected_week)
				_capture_actual_carryover_floors(floors)
				month_checkpoints.append("%.1f_%d_%d_%s" % [
					float(GameState.money), int(GameState.health),
					int(GameState.mental),
					"E" if not GameState.current_job.is_empty() else "U",
				])
				month_checkpoint_values.append([
					float(GameState.money), int(GameState.health),
					int(GameState.mental),
					not GameState.current_job.is_empty(),
				])
				if not _actual_carryover_survives(
						path_id, expected_week + 1):
					route_failed = true
					break
			else:
				var non_month_end := GameState.advance_calendar()
				advance_count += 1
				_expect(not non_month_end,
					"%s Week %d unexpectedly closed a month" % [
						path_id, expected_week])
				_capture_actual_carryover_floors(floors)

		job_system.free()
		relationship_system.free()
		inventory_system.free()
		if route_failed:
			continue

		var chapter_probe_before: Dictionary = GameState.serialize().duplicate(true)
		var natural_chapter_two_preview := str(_main_game.call(
			"_next_arc_id", -1, true, false))
		_expect(natural_chapter_two_preview == "chapter_card_34" \
				and _variants_deep_equal(
					GameState.serialize(), chapter_probe_before),
			"%s natural 2027 boundary did not preview Chapter 34 read-only: %s"
				% [path_id, natural_chapter_two_preview])

		var v2_after: Dictionary = GameState.core_loop_v2_state
		var routines_after: Dictionary = v2_after.get("routine_receipts", {})
		var expected_carryover: Dictionary = ACTUAL_CARRYOVER_EXPECTED[path_id]
		_expect(int(GameState.turn) == 49 \
				and [GameState.year, GameState.month,
					GameState.week_of_month, GameState.age] == [2027, 1, 1, 34] \
				and pressure_count == 6 \
				and action_count == 24 \
				and advance_count == 24 \
				and post_cap_routine_attempts == 24 \
				and month_end_turns == [28, 32, 36, 40, 44, 48] \
				and city_resolution_count \
					== (1 if path_id == "clean_unemployed_low" else 0) \
				and not GameState.is_game_over \
				and bool(GameState.flags.get("arc_year1_close_seen", false)),
			"%s did not complete the actual Week25→48 component bridge"
				% path_id)
		_expect(_variants_deep_equal([
				float(GameState.money), int(GameState.health), int(GameState.mental),
			], expected_carryover.get("final", [])) \
				and [int(floors["health"]), int(floors["mental"])] \
					== expected_carryover.get("floor", []) \
				and recovery_turns == expected_carryover.get(
					"recovery_turns", []) \
				and _variants_deep_equal(
					month_checkpoint_values,
					expected_carryover.get("months", [])),
			"%s exact W25→48 cash/H/M/job/recovery ledger drifted: "
				% path_id + "final=%s floor=%s rest=%s months=%s routes=%s" % [
					str([GameState.money, GameState.health, GameState.mental]),
					str(floors), str(recovery_turns),
					str(month_checkpoint_values), str(routed_trace),
				])
		_expect(_v2_post_cap_state_matches(path_id, v2_before, v2_after) \
				and routines_after == routines_before \
				and routines_after.size() == 24 \
				and routine_units_before == 48 \
				and _routine_unit_count(routines_after) == 48 \
				and (v2_after.get("completed_turns", []) as Array) \
					== completed_before \
				and (v2_after.get("plans", {}) as Dictionary) == plans_before \
				and (v2_after.get("month_summaries", {}) as Dictionary) \
					== summaries_before \
				and (v2_after.get("decline_receipts", []) as Array) \
					== declines_before \
				and (v2_after.get("action_receipts", {}) as Dictionary) \
					== v2_actions_before,
			"%s wrote a post-cap V2 routine/effect/plan/summary receipt" % path_id)
		var retained_action_turns: Array[int] = []
		for raw_action_receipt in GameState.weekly_commitments:
			if raw_action_receipt is Dictionary:
				retained_action_turns.append(int(
					(raw_action_receipt as Dictionary).get("turn", 0)))
		_expect(retained_action_turns == range(33, 49),
			"%s rolling action ledger did not retain the exact latest 16 weeks: %s"
				% [path_id, str(retained_action_turns)])
		_expect(str(routed_by_week.get("27", "")) == HYUNSU_RESULT \
				and str(routed_by_week.get("31", "")) == HYUNSU_AFTERMATH \
				and str(routed_by_week.get("36", "")) == HYUNSU_DRIFT \
				and str(routed_by_week.get("42", "")) == HYUNSU_NEW_PATH \
				and str(routed_by_week.get("48", "")) == YEAR_ONE_CLOSE,
			"%s lost the canonical 27/31/36/42/48 bridge events" % path_id)
		_expect(str(routed_by_week.get("25", "")) == "cafe_cb_honest_00" \
				and routed_chains_by_week.get("25", []) == [
					"cafe_cb_honest_00", "cafe_cb_honest_in"],
			("%s component snapshot did not consume the exact same-week "
			+ "W25 cafe callback chain: %s") % [
				path_id, str(routed_chains_by_week.get("25", []))])
		var all_routed_events: Array[String] = []
		for raw_chain in routed_chains_by_week.values():
			if raw_chain is Array:
				for raw_event_id in raw_chain:
					all_routed_events.append(str(raw_event_id))
		_expect(not all_routed_events.has("arc_intro_02_dad_call") \
				and not all_routed_events.has("arc_chapter1_close") \
				and not routed_by_week.values().has("arc_intro_02_dad_call") \
				and not routed_by_week.values().has("arc_chapter1_close"),
			("%s replayed a V2-replaced first-month Dad or 'first two "
			+ "months' chapter scene after the six-month snapshot: %s") % [
				path_id, str(all_routed_events)])
		if path_id == "clean_unemployed_low":
			_expect(str(routed_by_week.get("28", "")) == CITY_RESULT \
					and CORE_LOOP.application_status(
						"city_facility_ops_2026h1") == "no_offer",
				"clean City path lost its actual Week-28 result")
		else:
			_expect(str(routed_by_week.get("28", "")) != CITY_RESULT,
				"%s invented a City result without selecting its work sample"
					% path_id)
		if path_id.begins_with("dirty_"):
			_expect(bool(GameState.flags.get("lent_account", false)) \
					and not bool(GameState.flags.get(
						"kept_clean_hands", false)) \
					and not bool(GameState.flags.get(
						"arc_temptation_clean_seen", false)) \
					and not bool(GameState.flags.get("stayed_clean", false)) \
					and not all_routed_events.has("arc_temptation_clean"),
				("%s replayed the clean-account reward after the concrete "
				+ "lent_account history, or retained mutually exclusive flags")
					% path_id)
		if not bool(expected_start[3]):
			var rescue_week := int(ACTUAL_RESCUE_JOB_WEEKS[path_id])
			_expect(str(routed_by_week.get(str(rescue_week), "")) \
						== "arc_rescue_job" \
					and routed_chains_by_week.get(str(rescue_week), []) == [
						"arc_rescue_job"] \
					and bool(GameState.flags.get("arc_rescue_job_seen", false)) \
					and str(GameState.current_job.get("id", "")) == "job_01" \
					and bool((month_checkpoint_values[1] as Array)[3]),
				("%s did not explicitly accept the choice-0 W%d safety-net job "
				+ "before its second post-cap month checkpoint") % [
					path_id, rescue_week])
		else:
			_expect(str(routed_by_week.get("34", "")) != "arc_rescue_job",
				"%s invented a rescue job for an already-employed snapshot" % path_id)
		if not dirty_receipt_spec.is_empty():
			_expect(_exact_dirty_deferred_receipt(dirty_receipt_spec) \
					== dirty_receipt_at_24 \
					and _dirty_generic_story_receipt_count() == 0,
				"%s W48 handoff changed its exact dirty receipt or added generic state" \
					% path_id)

		_carryover_evidence.append(
			"%s=W48_%.1f_%d_%d/floor_%d_%d/rest_%s/months_%s" % [
				str(FULL_ROUTE_CHECK.FULL_ROUTE_EVIDENCE_NAMES[path_id]),
				float(GameState.money), int(GameState.health),
				int(GameState.mental), int(floors["health"]),
				int(floors["mental"]),
				"none" if recovery_turns.is_empty() else "+".join(
					recovery_turns.map(func(turn: int) -> String: return str(turn))),
				"-".join(month_checkpoints),
			])
		_carryover_route_evidence.append("%s:%s" % [
			str(FULL_ROUTE_CHECK.FULL_ROUTE_EVIDENCE_NAMES[path_id]),
			"|".join(routed_trace),
		])
		if not dirty_receipt_spec.is_empty():
			# Year-One fallback and the five-year boundary consume flags/prose, not
			# a reconstructed generic story receipt. Carry the one Week-24 truth
			# through a real serialization boundary at the run cap.
			_set_turn_date(240)
			var week_240_snapshot: Dictionary = GameState.serialize().duplicate(true)
			GameState.start_new_game()
			GameState.load_from_dict(week_240_snapshot)
			var before_initialize: Dictionary = \
				GameState.core_loop_v2_state.duplicate(true)
			var initialized := CORE_LOOP.initialize_for_run()
			_expect(initialized \
					and GameState.core_loop_v2_state == before_initialize \
					and int(GameState.turn) == 240 \
					and _exact_dirty_deferred_receipt(dirty_receipt_spec) \
						== dirty_receipt_at_24 \
					and _dirty_generic_story_receipt_count() == 0,
				"%s W240 save/load changed or inferred a dirty choice receipt" \
					% path_id)

	MetaProgression.data = meta_data_backup
	MetaProgression.set("_new_this_run", new_this_run_backup)


func _check_lent_account_flag_migration() -> void:
	GameState.start_new_game()
	var clean_snapshot: Dictionary = GameState.serialize().duplicate(true)
	var clean_flags: Dictionary = (
		clean_snapshot.get("flags", {}) as Dictionary).duplicate(true)
	for flag_id in [
		"kept_clean_hands", "arc_temptation_clean_seen", "stayed_clean"]:
		clean_flags[flag_id] = true
	clean_flags.erase("lent_account")
	clean_snapshot["flags"] = clean_flags
	GameState.load_from_dict(clean_snapshot)
	_expect(bool(GameState.flags.get("kept_clean_hands", false)) \
			and bool(GameState.flags.get("arc_temptation_clean_seen", false)) \
			and bool(GameState.flags.get("stayed_clean", false)) \
			and not bool(GameState.flags.get("lent_account", false)),
		"clean-only save lost its legitimate temptation history on load")

	var dirty_snapshot: Dictionary = clean_snapshot.duplicate(true)
	var dirty_flags: Dictionary = (
		dirty_snapshot.get("flags", {}) as Dictionary).duplicate(true)
	dirty_flags["lent_account"] = true
	dirty_flags.erase("kept_clean_hands")
	dirty_flags.erase("arc_temptation_clean_seen")
	dirty_flags.erase("stayed_clean")
	dirty_snapshot["flags"] = dirty_flags
	GameState.load_from_dict(dirty_snapshot)
	_expect(bool(GameState.flags.get("lent_account", false)) \
			and not bool(GameState.flags.get("kept_clean_hands", false)) \
			and not bool(GameState.flags.get(
				"arc_temptation_clean_seen", false)) \
			and not bool(GameState.flags.get("stayed_clean", false)),
		"dirty-only save lost its concrete account history or invented clean flags")

	var polluted_snapshot: Dictionary = clean_snapshot.duplicate(true)
	var polluted_flags: Dictionary = (
		polluted_snapshot.get("flags", {}) as Dictionary).duplicate(true)
	polluted_flags["lent_account"] = true
	polluted_flags["cafe_honest_invested"] = true
	polluted_flags["kept_clean_hands"] = true
	polluted_flags["arc_temptation_clean_seen"] = true
	polluted_flags["stayed_clean"] = true
	polluted_snapshot["flags"] = polluted_flags
	GameState.load_from_dict(polluted_snapshot)
	_expect(bool(GameState.flags.get("lent_account", false)) \
			and bool(GameState.flags.get("cafe_honest_invested", false)) \
			and not bool(GameState.flags.get("kept_clean_hands", false)) \
			and not bool(GameState.flags.get(
				"arc_temptation_clean_seen", false)) \
			and not bool(GameState.flags.get("stayed_clean", false)),
		"legacy both-flags save did not preserve concrete dirty/cafe history "
		+ "while removing polluted clean derivatives")


func _check_phone_purchase_retirement_migration() -> void:
	# A Week-20 handoff may contain the only device purchase that the retired
	# prototype could create. Return that exact KRW 180,000 expense once, then
	# require the schema-3 snapshot to roundtrip without another credit.
	GameState.start_new_game()
	var legacy_snapshot: Dictionary = GameState.serialize().duplicate(true)
	legacy_snapshot["turn"] = 20
	legacy_snapshot["money"] = 210_000.0
	legacy_snapshot["phone_state"] = {
		"schema": 2,
		"current_device_id": "refurbished",
		"owned_device_ids": ["starter", "refurbished"],
		"purchase_receipts": [{
			"device_id": "refurbished",
			"previous_device_id": "starter",
			"price": 180_000.0,
			"turn": 16,
			"balance_before": 390_000.0,
			"balance_after": 210_000.0,
		}],
		"favorite_app_id": "calendar",
	}
	GameState.load_from_dict(legacy_snapshot)
	_expect(is_equal_approx(float(GameState.money), 390_000.0) \
			and GameState.phone_state == {
				"schema": 3,
				"device_purchase_retired": true,
				"legacy_refund_applied": true,
				"legacy_refund_amount": 180_000.0,
			},
		"valid Week-20 retired purchase did not refund exactly once at handoff")

	var settled_snapshot: Dictionary = GameState.serialize().duplicate(true)
	GameState.money = -999_999.0
	GameState.phone_state = {}
	GameState.load_from_dict(settled_snapshot)
	_expect(is_equal_approx(float(GameState.money), 390_000.0) \
			and GameState.phone_state == settled_snapshot.get("phone_state", {}),
		"settled phone refund changed on the next handoff load")

	var forged_snapshot: Dictionary = legacy_snapshot.duplicate(true)
	forged_snapshot["money"] = 210_000.0
	var forged_phone: Dictionary = (
		forged_snapshot.get("phone_state", {}) as Dictionary).duplicate(true)
	var forged_receipts: Array = (
		forged_phone.get("purchase_receipts", []) as Array).duplicate(true)
	var forged_receipt: Dictionary = (
		forged_receipts[0] as Dictionary).duplicate(true)
	forged_receipt["price"] = 179_999.0
	forged_receipts[0] = forged_receipt
	forged_phone["purchase_receipts"] = forged_receipts
	forged_snapshot["phone_state"] = forged_phone
	GameState.load_from_dict(forged_snapshot)
	_expect(is_equal_approx(float(GameState.money), 210_000.0) \
			and GameState.phone_state == PHONE_SYSTEM.default_state(),
		"forged retired-device receipt produced money at handoff")


func _check_durable_legacy_replacements() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	_set_turn_date(25)
	_seed_scheduler_baseline()
	GameState.flags["arc_intro_meal_seen"] = true
	GameState.flags.erase("arc_intro_dad_seen")
	GameState.flags["chapter1_closed"] = true
	var state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	state["suppressed_followups"] = {}
	state["consequence_receipts"] = {}
	state["completed_bundles"] = []
	GameState.core_loop_v2_state = state
	_recreate_main_game()
	if not is_instance_valid(_main_game):
		return
	var dad_control := str(_main_game.call(
		"_next_arc_id", -1, true, false))
	_expect(dad_control == "arc_intro_02_dad_call",
		"legacy Dad fallback control no longer routes without its V2 receipt")
	state = GameState.core_loop_v2_state.duplicate(true)
	state["suppressed_followups"] = {}
	state["consequence_receipts"] = {
		"opening_interview_math": {
			"consequence_id": "opening_interview_math",
			"status": "consumed",
			"presented_turn": 2,
			"consumed_turn": 2,
		},
	}
	GameState.core_loop_v2_state = state
	var dad_replaced := str(_main_game.call(
		"_next_arc_id", -1, true, false))
	_expect(dad_replaced != "arc_intro_02_dad_call" \
			and (GameState.core_loop_v2_state.get(
				"suppressed_followups", {}) as Dictionary).is_empty(),
		"consumed interview consequence did not replace Dad after suppression clear")

	GameState.flags["arc_intro_dad_seen"] = true
	GameState.flags["arc_intro_hyunsu_seen"] = true
	GameState.flags.erase("chapter1_closed")
	state = GameState.core_loop_v2_state.duplicate(true)
	state["completed_bundles"] = []
	state["suppressed_followups"] = {}
	GameState.core_loop_v2_state = state
	var chapter_control := str(_main_game.call(
		"_next_arc_id", -1, true, false))
	_expect(chapter_control == "arc_chapter1_close",
		"legacy Chapter-One close control no longer routes without its V2 bundle")
	state = GameState.core_loop_v2_state.duplicate(true)
	state["completed_bundles"] = ["hyunsu_first_meet"]
	state["suppressed_followups"] = {}
	GameState.core_loop_v2_state = state
	var chapter_replaced := str(_main_game.call(
		"_next_arc_id", -1, true, false))
	_expect(chapter_replaced != "arc_chapter1_close" \
			and (GameState.core_loop_v2_state.get(
				"suppressed_followups", {}) as Dictionary).is_empty(),
		"completed Hyunsu V2 bundle did not replace close after suppression clear")


func _check_identity_retirement_boundaries() -> void:
	# The V2 opening no longer asks the player to declare an economic identity.
	# Hybrid saves may still contain those old facts, so prove both halves of the
	# contract at the demo cap, Year-One close, and the five-year run cap: values
	# roundtrip unchanged, while their invented callback scenes remain retired.
	var callback_ids := [
		"callback_mindset_saver_echo",
		"callback_mindset_investor_echo",
		"callback_mindset_founder_echo",
	]
	GameState.start_new_game()
	GameState.flags["mindset_saver"] = true
	GameState.flags["mindset_investor"] = true
	GameState.flags["mindset_founder"] = true
	GameState.flags["had_first_investment"] = true
	GameState.tendency = {"career": 6, "invest": 12, "found": 8}
	GameState.tendency_realized = "invest"
	GameState.player_route = "투자형"
	GameState.flags["route_invest"] = true
	var expected_flags: Dictionary = GameState.flags.duplicate(true)
	var expected_tendency: Dictionary = GameState.tendency.duplicate(true)
	_expect(CORE_LOOP.initialize_for_run(true),
		"identity-retirement fixture could not initialize V2")

	for boundary in [24, 48, 240]:
		_set_turn_date(boundary)
		EventManager.event_cooldowns.clear()
		EventManager.recent_event_ids.clear()
		var blocked := true
		for callback_id in callback_ids:
			blocked = blocked \
				and CORE_LOOP.legacy_callback_is_superseded(callback_id) \
				and not EventManager._is_event_eligible(
					DataRegistry.find_event(callback_id), true)
		_expect(blocked,
			"V2 identity callback retirement leaked at Week %d" % boundary)
		var snapshot: Dictionary = GameState.serialize().duplicate(true)
		GameState.start_new_game()
		GameState.load_from_dict(snapshot)
		_expect(CORE_LOOP.initialize_for_run() \
				and GameState.flags == expected_flags \
				and GameState.tendency == expected_tendency \
				and GameState.tendency_realized == "invest" \
				and int(GameState.turn) == boundary,
			"Week-%d identity history changed across save/load" % boundary)


func _check_side_shift_identity_boundaries() -> void:
	# The monthly V2 scheduler stops after Week 24, but the run's semantic origin
	# does not. A survival shift at any later boundary must remain work rather
	# than silently turning into a founder declaration. V1 keeps its historical
	# tendency behavior for save compatibility.
	GameState.start_new_game()
	GameState.add_log("side-shift identity fixture", "system")
	_expect(CORE_LOOP.initialize_for_run(true),
		"side-shift identity fixture could not initialize V2")
	_recreate_main_game()
	if not is_instance_valid(_main_game):
		return
	_main_game.set_meta("_screenshot_qa_static_surface", true)
	add_child(_main_game)
	await get_tree().process_frame
	await get_tree().process_frame

	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	GameState.tendency["found"] = 7
	for boundary in [25, 48, 240]:
		_set_turn_date(boundary)
		GameState.action_points = 2
		var found_before := int(GameState.tendency.get("found", 0))
		_main_game.call("_on_aruba_closed", 0, 0, 0)
		_expect(not CORE_LOOP.is_active() \
				and bool(GameState.core_loop_v2_state.get("enabled", false)) \
				and int(GameState.tendency.get("found", 0)) == found_before,
			"V2-origin side shift invented founder tendency at Week %d" \
				% boundary)

	GameState.start_new_game()
	_set_turn_date(25)
	GameState.action_points = 2
	var legacy_found_before := int(GameState.tendency.get("found", 0))
	_main_game.call("_on_aruba_closed", 0, 0, 0)
	_expect(not bool(GameState.core_loop_v2_state.get("enabled", false)) \
			and int(GameState.tendency.get("found", 0)) \
				== legacy_found_before + 1,
		"V1 side shift lost its historical founder-tendency behavior")

	remove_child(_main_game)
	_main_game.free()
	_main_game = null


func _roundtrip_actual_week_24_snapshot(
		path_id: String, snapshot: Dictionary,
		expected_start: Array) -> bool:
	# E's builder is a bounded component snapshot, not a claim that MainGame's
	# prologue/UI path produced the save. First prove its in-memory serialization
	# restores exactly and that the V2 initializer is inert at the completed cap.
	var expected_serialized := snapshot.duplicate(true)
	GameState.load_from_dict(expected_serialized)
	var restored_serialized: Dictionary = GameState.serialize().duplicate(true)
	var direct_exact: bool = restored_serialized == expected_serialized
	var direct_drift_keys: Array[String] = []
	if not direct_exact:
		for raw_key in expected_serialized:
			var key := str(raw_key)
			if not restored_serialized.has(key) \
					or not _variants_deep_equal(
						restored_serialized.get(key),
						expected_serialized.get(key)):
				direct_drift_keys.append(key)
		for raw_key in restored_serialized:
			var restored_key := str(raw_key)
			if not expected_serialized.has(restored_key) \
					and not direct_drift_keys.has(restored_key):
				direct_drift_keys.append(restored_key)
	_expect(direct_exact,
		"%s E component snapshot drifted on direct GameState restore; keys=%s" \
			% [path_id, str(direct_drift_keys)])
	if not direct_exact:
		return false
	var before_initialize := restored_serialized.duplicate(true)
	CORE_LOOP.initialize_for_run()
	var initialize_inert: bool = GameState.serialize() == before_initialize
	_expect(initialize_inert,
		"%s completed E snapshot mutated during initialize_for_run" % path_id)
	if not initialize_inert:
		return false
	var canonical_core_before_save: Dictionary = \
		GameState.core_loop_v2_state.duplicate(true)

	var saved: bool = SaveManager.save_game(
		SaveManager.AUTOSAVE_SLOT, {}, {
			"label": "core-loop-v2-actual-carryover-%s" % path_id,
			"qa_fixture": true,
		})
	_expect(saved, "%s could not write its real autosave roundtrip" % path_id)
	if not saved:
		return false
	var disk_payload: Variant = JSON.parse_string(FileAccess.get_file_as_string(
		SaveManager.slot_path(SaveManager.AUTOSAVE_SLOT)))
	var expected_disk_state: Dictionary = (
		(disk_payload as Dictionary).get("state", {}) as Dictionary
	).duplicate(true) if disk_payload is Dictionary else {}
	_expect(not expected_disk_state.is_empty(),
		"%s autosave payload did not contain a state dictionary" % path_id)
	if expected_disk_state.is_empty():
		return false
	# GameState's documented load contract canonicalizes the retired-phone
	# settlement ledger even for current saves. Compare against that normalized
	# payload while keeping every other serialized key byte-for-byte structural.
	expected_disk_state["phone_state"] = PHONE_SYSTEM.normalized_state(
		expected_disk_state.get("phone_state", {}))

	# Deliberately corrupt every boundary field before loading the disk payload;
	# a serialize-helper-only false positive cannot survive this roundtrip.
	GameState.turn = 2
	GameState.year = 1999
	GameState.month = 2
	GameState.week_of_month = 2
	GameState.age = 99
	GameState.money = -987_654_321.0
	GameState.health = 1
	GameState.mental = 2
	GameState.current_job = {"id": "qa_state_disturbance"}
	GameState.core_loop_v2_state = {"qa_state_disturbance": true}
	var loaded: bool = SaveManager.load_game(SaveManager.AUTOSAVE_SLOT)
	_expect(loaded, "%s could not reload its real autosave" % path_id)
	if not loaded:
		return false

	var loaded_serialized: Dictionary = GameState.serialize().duplicate(true)
	var disk_full_exact: bool = false
	var disk_drift_keys: Array[String] = []
	for raw_key in expected_disk_state:
		var key := str(raw_key)
		if not loaded_serialized.has(key) \
				or not _variants_deep_equal(
					loaded_serialized.get(key), expected_disk_state.get(key)):
			disk_drift_keys.append(key)
	for raw_key in loaded_serialized:
		var loaded_key := str(raw_key)
		if not expected_disk_state.has(loaded_key) \
				and not disk_drift_keys.has(loaded_key):
			disk_drift_keys.append(loaded_key)
	disk_full_exact = disk_drift_keys.is_empty() \
		and loaded_serialized.size() == expected_disk_state.size()
	_expect(disk_full_exact,
		"%s loaded GameState did not exactly match autosave payload.state; keys=%s"
			% [path_id, str(disk_drift_keys)])
	var exact_boundary: bool = disk_full_exact \
		and int(GameState.turn) == 25 \
		and int(GameState.money) == int(expected_start[0]) \
		and int(GameState.health) == int(expected_start[1]) \
		and int(GameState.mental) == int(expected_start[2]) \
		and _variants_deep_equal(
			loaded_serialized.get("current_job", {}),
			expected_disk_state.get("current_job", {})) \
		and _variants_deep_equal(
			loaded_serialized.get("core_loop_v2_state", {}),
			expected_disk_state.get("core_loop_v2_state", {}))
	_expect(exact_boundary,
		("%s autosave did not restore exact W24→25 cash/H/M/job/V2 state: "
		+ "turn=%d cash=%d H%d/M%d job=%s") % [
			path_id, int(GameState.turn), int(GameState.money),
			int(GameState.health), int(GameState.mental),
			str(GameState.current_job)])
	if not exact_boundary:
		return false
	var after_load_before_initialize: Dictionary = \
		GameState.serialize().duplicate(true)
	CORE_LOOP.initialize_for_run()
	var after_load_initialize: Dictionary = GameState.serialize().duplicate(true)
	var load_initialize_drift_keys: Array[String] = []
	for raw_key in after_load_before_initialize:
		var init_key := str(raw_key)
		if not _variants_deep_equal(
				after_load_before_initialize.get(init_key),
				after_load_initialize.get(init_key)):
			load_initialize_drift_keys.append(init_key)
	# JSON numbers inside the V2 dictionary are canonicalized back to the typed
	# schema on first initialization. The direct E snapshot above proved a
	# completed typed state is fully inert; disk loading may change only this one
	# container's representation, never another GameState field or its meaning.
	var first_initialize_safe: bool = (
		load_initialize_drift_keys.is_empty() \
		or load_initialize_drift_keys == ["core_loop_v2_state"]
	) and int(GameState.turn) == 25 \
		and int(GameState.money) == int(expected_start[0]) \
		and int(GameState.health) == int(expected_start[1]) \
		and int(GameState.mental) == int(expected_start[2]) \
		and _variants_deep_equal(
			GameState.core_loop_v2_state, canonical_core_before_save) \
		and CORE_LOOP.is_prototype_complete() \
		and not CORE_LOOP.is_active()
	_expect(first_initialize_safe,
		"%s autosave initialization drifted outside V2 canonicalization: %s"
			% [path_id, str(load_initialize_drift_keys)])
	var canonicalized_once: Dictionary = GameState.serialize().duplicate(true)
	CORE_LOOP.initialize_for_run()
	var second_initialize_inert: bool = _variants_deep_equal(
		GameState.serialize(), canonicalized_once)
	_expect(second_initialize_inert,
		"%s autosave V2 state changed on its second initialization" % path_id)
	return first_initialize_safe and second_initialize_inert


func _post_cap_routine_attempt_is_inert(
		path_id: String, week: int) -> bool:
	var before: Dictionary = GameState.serialize().duplicate(true)
	var result := CORE_LOOP.apply_background_routines_for_turn(week)
	var after: Dictionary = GameState.serialize().duplicate(true)
	var inert: bool = not bool(result.get("ok", true)) \
		and not bool(result.get("applied", false)) \
		and str(result.get("error", "")) == "missing_plan" \
		and after == before
	_expect(inert,
		"%s Week %d post-cap V2 routine attempt was not an inert missing_plan: %s"
			% [path_id, week, str(result)])
	return inert


func _route_current_carryover_week(
		path_id: String, week: int) -> Dictionary:
	if not is_instance_valid(_main_game):
		_expect(false, "%s Week %d has no MainGame scheduler" % [path_id, week])
		return {"ok": false, "event_id": ""}
	# MainGame's foreground boundary makes exactly one resolving call. A preview
	# deliberately skips deferred bridges, so it cannot be compared with or used
	# to choose the production result on due-deferred weeks.
	var claimed_id := str(_main_game.call(
		"_next_arc_id", -1, false, true))
	return {
		"ok": true,
		"event_id": claimed_id,
	}


func _apply_event_choice_chain(
		event_id: String, choice_index: int, applied_ids: Array[String],
		visited: Dictionary, chain_state: Dictionary) -> bool:
	if event_id.is_empty():
		return true
	if visited.has(event_id):
		_expect(false, "immediate follow-up cycle reached %s: %s" % [
			event_id, str(applied_ids)])
		return false
	visited[event_id] = true
	var event: Dictionary = DataRegistry.find_event(event_id)
	var choices: Array = (
		event.get("choices", []) as Array
		if event.get("choices", []) is Array else [])
	# The carryover uses choice 0 by default, but must not manufacture an
	# investment from a non-positive balance. The authored patient choice is the
	# exact affordable sibling and keeps the relationship without fake capital.
	if event_id == "cafe_cb_honest_in" and float(GameState.money) <= 0.0:
		choice_index = 1
	if event.is_empty() or choice_index < 0 or choice_index >= choices.size():
		_expect(false, "%s immediate-chain choice %d is missing" % [
			event_id, choice_index])
		return false
	var choice: Dictionary = choices[choice_index]
	# StoryMode resolves immediate follow-up eligibility before applying the
	# current choice, then puts that child at the front of the same scene queue.
	var follow_up_id := _immediate_follow_up_before_choice(
		choice, event_id, choice_index)
	GameState.record_run_scene_seen(event_id)
	GameState.apply_choice(event, choice)
	if CORE_LOOP.is_active():
		CORE_LOOP.note_story_choice(event_id, choice_index)
	if CORE_LOOP.note_post_demo_application_result(event_id, choice_index):
		chain_state["city_resolutions"] = int(chain_state.get(
			"city_resolutions", 0)) + 1
	applied_ids.append(event_id)
	if follow_up_id.is_empty():
		return true
	if DataRegistry.find_event(follow_up_id).is_empty():
		_expect(false, "%s choice %d points to missing immediate follow-up %s" % [
			event_id, choice_index, follow_up_id])
		return false
	return _apply_event_choice_chain(
		follow_up_id, 0, applied_ids, visited, chain_state)


func _immediate_follow_up_before_choice(
		choice: Dictionary, event_id: String,
		choice_index: int) -> String:
	var follow_up_id := str(choice.get("follow_up_event", ""))
	var raw_required_flags: Variant = choice.get(
		"follow_up_requires_flags", [])
	if not raw_required_flags is Array:
		return ""
	for raw_flag in raw_required_flags as Array:
		var flag_id := str(raw_flag).strip_edges()
		if flag_id.is_empty() \
				or not bool(GameState.flags.get(flag_id, false)):
			return ""
	if CORE_LOOP.is_active() \
			and CORE_LOOP.story_follow_up_is_suppressed(
				event_id, choice_index, follow_up_id):
		return ""
	return follow_up_id


func _routine_unit_count(receipts: Dictionary) -> int:
	var total := 0
	for raw_receipt in receipts.values():
		if raw_receipt is Dictionary:
			var raw_units: Variant = (raw_receipt as Dictionary).get("units", [])
			if raw_units is Array:
				total += (raw_units as Array).size()
	return total


func _variants_deep_equal(left: Variant, right: Variant) -> bool:
	if left is Dictionary or right is Dictionary:
		if not left is Dictionary or not right is Dictionary:
			return false
		var left_dict: Dictionary = left
		var right_dict: Dictionary = right
		if left_dict.size() != right_dict.size():
			return false
		for raw_key in left_dict:
			if not right_dict.has(raw_key) \
					or not _variants_deep_equal(
						left_dict.get(raw_key), right_dict.get(raw_key)):
				return false
		return true
	if left is Array or right is Array:
		if not left is Array or not right is Array:
			return false
		var left_array: Array = left
		var right_array: Array = right
		if left_array.size() != right_array.size():
			return false
		for index in range(left_array.size()):
			if not _variants_deep_equal(left_array[index], right_array[index]):
				return false
		return true
	if (left is int or left is float) \
			and (right is int or right is float):
		# JSON may restore an integral value as a float, but every canonical cash
		# value in this fixture is below 2^53 and its half-won values are exactly
		# representable. Relative approximate comparison would let an increasingly
		# large cash drift pass, contradicting the exact-ledger contract.
		return float(left) == float(right)
	return left == right


func _v2_post_cap_state_matches(
		path_id: String, before: Dictionary, after: Dictionary) -> bool:
	var expected := before.duplicate(true)
	if path_id == "clean_unemployed_low":
		var application_id := "city_facility_ops_2026h1"
		var receipt_id := "city_facility_ops_2026h1_result"
		var future_receipts: Dictionary = (
			expected.get("future_application_receipts", {}) as Dictionary
		).duplicate(true)
		var receipt: Dictionary = (
			future_receipts.get(receipt_id, {}) as Dictionary).duplicate(true)
		receipt["status"] = "resolved"
		receipt["resolved_turn"] = 28
		receipt["choice_index"] = 0
		future_receipts[receipt_id] = receipt
		expected["future_application_receipts"] = future_receipts
		var application_statuses: Dictionary = (
			expected.get("application_statuses", {}) as Dictionary
		).duplicate(true)
		application_statuses[application_id] = "no_offer"
		expected["application_statuses"] = application_statuses
		var transition_key := "future:%s:0:28" % receipt_id
		var transitions: Dictionary = (
			expected.get("application_transition_receipts", {}) as Dictionary
		).duplicate(true)
		transitions[transition_key] = {
				"receipt_key": transition_key,
				"application_id": application_id,
				"from": "submitted",
				"to": "no_offer",
				"bundle_id": receipt_id,
				"event_id": CITY_RESULT,
				"choice_index": 0,
				"turn": 28,
			}
		expected["application_transition_receipts"] = transitions
	return after == expected


func _actual_carryover_target(path_id: String, week: int) -> String:
	if path_id == "clean_unemployed_low" and week == 28:
		return CITY_RESULT
	return {
		27: HYUNSU_RESULT,
		31: HYUNSU_AFTERMATH,
		36: HYUNSU_DRIFT,
		42: HYUNSU_NEW_PATH,
		48: YEAR_ONE_CLOSE,
	}.get(week, "")


func _apply_actual_carryover_action() -> Dictionary:
	var recovery := int(GameState.health) <= 25 \
		or int(GameState.mental) <= 30
	var action_id := "rest" if recovery else "study"
	var source_pool: Array = (
		MAIN_GAME_SCRIPT.REST_VIGNETTES
		if recovery else MAIN_GAME_SCRIPT.SELFDEV_VIGNETTES)
	var source_index := 1
	var source_vignette: Dictionary = source_pool[source_index]
	var effects: Dictionary = (
		source_vignette.get("e", {}) as Dictionary).duplicate(true)
	GameState.restore_ap()
	if not GameState.arm_weekly_commitment({
		"turn": int(GameState.turn),
		"pressure_id": "year1_carryover_week_%d" % int(GameState.turn),
		"pressure_family": "year1_survival",
		"choice_id": action_id,
		"forgone_ids": ["rest" if action_id == "study" else "study"],
	}):
		return {"ok": false, "error": "commitment_not_armed"}
	var transaction := GameState.finalize_weekly_effect_action(
		action_id, effects, "human", "home", "", {
			"execution": "rest" if recovery else "study",
			"effects": effects.duplicate(true),
			"source_vignette_index": source_index,
			"component_runtime_carryover": true,
		})
	transaction["action_id"] = action_id
	return transaction


func _capture_actual_carryover_floors(floors: Dictionary) -> void:
	floors["health"] = mini(int(floors.get("health", 100)), GameState.health)
	floors["mental"] = mini(int(floors.get("mental", 100)), GameState.mental)


func _actual_carryover_survives(path_id: String, at_week: int) -> bool:
	if int(GameState.health) <= 0 or int(GameState.mental) <= 0 \
			or GameState.get_total_asset_value() < -100_000_000.0:
		_expect(false,
			"%s reached a fatal Week %d state: cash=%d H%d/M%d" % [
				path_id, at_week, int(GameState.money),
				int(GameState.health), int(GameState.mental)])
		return false
	GameState.check_game_over()
	if GameState.is_game_over:
		_expect(false, "%s unexpectedly ended at Week %d" % [
			path_id, at_week])
		return false
	return true


func _check_v2_week_24_handoff() -> void:
	# Focused scheduler/typed-receipt fixture. Release carryover evidence comes
	# from the four component snapshots above; this hand-authored seed exists to
	# isolate City resolution and close→curation queue behavior.
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
	var father_control_route := _route_at(25)
	_expect(
		father_control_route == "arc_father_01_call",
		"Father scheduler control fixture no longer exposes the old root: %s"
			% father_control_route)
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
		"focused synthetic Week-24 scheduler fixture lost its typed receipts")


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
		# Keep user-owned NG+ meta from replacing this control fixture's
		# deliberately unseen legacy Father root.
		"arc_father_ng_seen",
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


func _exact_dirty_deferred_receipt(spec: Dictionary) -> Dictionary:
	var raw_receipts: Variant = GameState.core_loop_v2_state.get(
		"deferred_callback_receipts", {})
	if not raw_receipts is Dictionary:
		return {}
	var source := str(spec.get("source", ""))
	var root := str(spec.get("root", ""))
	var raw_receipt: Variant = (raw_receipts as Dictionary).get(source, {})
	if not raw_receipt is Dictionary:
		return {}
	var receipt: Dictionary = raw_receipt
	var exact := receipt.size() == 9 \
		and str(receipt.get("source", "")) == source \
		and int(receipt.get("trigger_turn", -1)) == 24 \
		and int(receipt.get("claimed_turn", -1)) == 24 \
		and str(receipt.get("root", "")) == root \
		and str(receipt.get("status", "")) == "resolved" \
		and bool(receipt.get("synthetic", not bool(
			spec.get("synthetic", false)))) \
			== bool(spec.get("synthetic", false)) \
		and str(receipt.get("event_id", "")) == root \
		and int(receipt.get("choice_index", -1)) == 0 \
		and int(receipt.get("resolved_turn", -1)) == 24
	return receipt.duplicate(true) if exact else {}


func _dirty_generic_story_receipt_count() -> int:
	var raw_receipts: Variant = GameState.core_loop_v2_state.get(
		"story_choice_receipts", {})
	if not raw_receipts is Dictionary:
		return 0
	var count := 0
	for raw_receipt in (raw_receipts as Dictionary).values():
		if raw_receipt is Dictionary \
				and str((raw_receipt as Dictionary).get("event_id", "")) \
					in [
						"v2_dirty_trace_initial_call",
						"v2_dirty_recruiter_week24",
					]:
			count += 1
	return count


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
