extends Node
## ORDER-94 Seoul Cycle numeric gate.
##
## This is intentionally not a branch-only or routine simulator. Every normal
## route spends the four saved capacities in each of Months 1..6 through the
## production Seoul-cycle transaction, resolves the resulting threshold/world
## owners through authored GameState choices, and runs the production month-end
## order. The fatal route drives the same surfaces with their authored costly
## outcomes until GameState resolves an actual failure ending.
##
## Run in an isolated playtest namespace:
##   GANGNAM_QA_USER_DIR=/absolute/temp/dir godot --headless --path . \
##     res://tools/CoreLoopV2CycleBalanceCheck.tscn -- \
##     --core-loop-v2-playtest-build --qa-isolated-user-data

const CORE := preload("res://systems/DemoCoreLoopV2.gd")
const ARUBA := preload("res://scenes/ArubaGame.gd")
const JOB_HUNT := preload("res://scenes/JobHuntMiniGame.gd")
const JOB_SYSTEM := preload("res://systems/JobSystem.gd")
const RELATIONSHIP_SYSTEM := preload("res://systems/RelationshipSystem.gd")
const INVENTORY_SYSTEM := preload("res://systems/InventorySystem.gd")

const NORMAL_ROUTE_IDS: Array[String] = [
	"livelihood", "advancement", "people", "recovery",
]
const ALL_ROUTE_IDS: Array[String] = [
	"livelihood", "advancement", "people", "recovery", "fatal_cost",
]
const ROUTE_LABELS := {
	"livelihood": "생계 우선",
	"advancement": "앞날 우선",
	"people": "사람 우선",
	"recovery": "회복 우선",
	"fatal_cost": "고비용 사망",
}
const ROUTE_ROLE_ORDER := {
	"livelihood": ["livelihood", "recovery", "advancement", "people"],
	"advancement": ["advancement", "livelihood", "recovery", "people"],
	"people": ["people", "recovery", "livelihood", "advancement"],
	"recovery": ["recovery", "livelihood", "advancement", "people"],
	"fatal_cost": ["livelihood", "advancement", "people"],
}
const ROUTE_SEEDS := {
	"livelihood": 94101,
	"advancement": 94102,
	"people": 94103,
	"recovery": 94104,
	"fatal_cost": 94105,
}

# Locked after this runner has traversed all production surfaces. Keeping the
# complete six-month rows here makes every printed money/body/mind/employment
# value an assertion, rather than a smoke-test observation. Populate only from
# this runner's output; legacy routine simulations are not a valid source.
const EXPECTED_MONTHS: Dictionary = {
	"livelihood": [
		{"month": 1, "money": 388000, "health": 59, "mental": 55,
			"employed": false, "employment_id": ""},
		{"month": 2, "money": 73500, "health": 49, "mental": 58,
			"employed": false, "employment_id": ""},
		{"month": 3, "money": -76500, "health": 40, "mental": 45,
			"employed": false, "employment_id": ""},
		{"month": 4, "money": -136500, "health": 31, "mental": 30,
			"employed": false, "employment_id": ""},
		{"month": 5, "money": -646500, "health": 33, "mental": 25,
			"employed": false, "employment_id": ""},
		{"month": 6, "money": -475500, "health": 21, "mental": 10,
			"employed": false, "employment_id": ""},
	],
	"advancement": [
		{"month": 1, "money": 290000, "health": 62, "mental": 60,
			"employed": false, "employment_id": ""},
		{"month": 2, "money": -220000, "health": 61, "mental": 65,
			"employed": false, "employment_id": ""},
		{"month": 3, "money": -730000, "health": 58, "mental": 52,
			"employed": false, "employment_id": ""},
		{"month": 4, "money": -1240000, "health": 54, "mental": 40,
			"employed": false, "employment_id": ""},
		{"month": 5, "money": -70000, "health": 55, "mental": 38,
			"employed": true, "employment_id": "job_03"},
		{"month": 6, "money": 1651000, "health": 56, "mental": 32,
			"employed": true, "employment_id": "job_03"},
	],
	"people": [
		{"month": 1, "money": 247000, "health": 62, "mental": 61,
			"employed": false, "employment_id": ""},
		{"month": 2, "money": -207500, "health": 55, "mental": 67,
			"employed": false, "employment_id": ""},
		{"month": 3, "money": -497500, "health": 48, "mental": 53,
			"employed": false, "employment_id": ""},
		{"month": 4, "money": -1077500, "health": 45, "mental": 39,
			"employed": false, "employment_id": ""},
		{"month": 5, "money": -1657500, "health": 47, "mental": 34,
			"employed": false, "employment_id": ""},
		{"month": 6, "money": -2246500, "health": 51, "mental": 34,
			"employed": false, "employment_id": ""},
	],
	"recovery": [
		{"month": 1, "money": 150000, "health": 68, "mental": 66,
			"employed": false, "employment_id": ""},
		{"month": 2, "money": -500000, "health": 72, "mental": 80,
			"employed": false, "employment_id": ""},
		{"month": 3, "money": -1150000, "health": 74, "mental": 78,
			"employed": false, "employment_id": ""},
		{"month": 4, "money": -1800000, "health": 75, "mental": 75,
			"employed": false, "employment_id": ""},
		{"month": 5, "money": -2450000, "health": 81, "mental": 78,
			"employed": false, "employment_id": ""},
		{"month": 6, "money": -3109000, "health": 89, "mental": 85,
			"employed": false, "employment_id": ""},
	],
	"fatal_cost": [
		{"month": 1, "money": 2450000, "health": 57, "mental": 19,
			"employed": false, "employment_id": ""},
		{"month": 2, "money": 705500, "health": 39, "mental": 0,
			"employed": false, "employment_id": ""},
	],
}
const EXPECTED_MINIMA: Dictionary = {
	"livelihood": {
		"min_money": -646500, "min_health": 21, "min_mental": 10,
		"death_week": 0, "ending": "",
	},
	"advancement": {
		"min_money": -1240000, "min_health": 54, "min_mental": 32,
		"death_week": 0, "ending": "",
	},
	"people": {
		"min_money": -2246500, "min_health": 44, "min_mental": 33,
		"death_week": 0, "ending": "",
	},
	"recovery": {
		"min_money": -3109000, "min_health": 65, "min_mental": 65,
		"death_week": 0, "ending": "",
	},
	"fatal_cost": {
		"min_money": 500000, "min_health": 39, "min_mental": 0,
		"death_week": 8, "ending": "mental_break",
	},
}

var _failures: Array[String] = []
var _results: Dictionary = {}
var _meta_snapshot: Dictionary = {}
var _last_ending_id := ""
var _original_sfx_enabled := true


func _ready() -> void:
	if not GameState.game_over.is_connected(_capture_ending):
		GameState.game_over.connect(_capture_ending)
	call_deferred("_run")


func _capture_ending(ending_id: String) -> void:
	_last_ending_id = ending_id


func _run() -> void:
	_meta_snapshot = MetaProgression.data.duplicate(true)
	_original_sfx_enabled = AudioManager.sfx_enabled
	AudioManager.sfx_enabled = false
	for route_id in ALL_ROUTE_IDS:
		var result: Dictionary = await _run_route(route_id)
		_results[route_id] = result
		_print_route(result)
	_assert_route_contracts()
	_assert_locked_numbers()
	MetaProgression.data = _meta_snapshot.duplicate(true)
	await _stop_test_audio()
	AudioManager.sfx_enabled = _original_sfx_enabled
	if _failures.is_empty():
		print(
			"CORE_LOOP_V2_CYCLE_BALANCE_OK "
			+ "weeks=24 months=6 routes=livelihood/advancement/people/recovery "
			+ "fatal=actual_game_over allocation=production trigger=production "
			+ "world=production month_end=production")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("CORE_LOOP_V2_CYCLE_BALANCE_FAIL: %s" % failure)
	get_tree().quit(1)


func _run_route(route_id: String) -> Dictionary:
	_prepare_fresh_cycle(route_id)
	var result := {
		"route": route_id,
		"label": str(ROUTE_LABELS.get(route_id, route_id)),
		"months": [],
		"allocations": 0,
		"trigger_receipts": 0,
		"world_receipts": 0,
		"month_summaries": 0,
		"role_allocations": {
			"livelihood": 0,
			"advancement": 0,
			"people": 0,
			"recovery": 0,
		},
		"death_week": 0,
		"ending": "",
		"min_money": float(GameState.money),
		"min_health": int(GameState.health),
		"min_mental": int(GameState.mental),
		"max_money": float(GameState.money),
		"max_health": int(GameState.health),
		"max_mental": int(GameState.mental),
	}
	_track_minima(result)

	for month_index in range(1, 7):
		if GameState.is_game_over:
			break
		var expected_turn := ((month_index - 1) * 4) + 1
		_expect(int(GameState.turn) == expected_turn,
			"%s entered Month %d on Week %d, expected Week %d" % [
				route_id, month_index, int(GameState.turn), expected_turn])
		var initialized := CORE.initialize_seoul_cycle(month_index)
		if not bool(initialized.get("ok", false)):
			_expect(false, "%s could not initialize Month %d: %s" % [
				route_id, month_index,
				str(initialized.get("error", "unknown"))])
			break

		for _week_index in range(1, 5):
			if GameState.is_game_over:
				break
			var routine := CORE.apply_background_routines_for_turn(
				int(GameState.turn))
			_expect(bool(routine.get("ok", false)) \
					and bool(routine.get("suppressed", false)) \
					and not bool(routine.get("applied", true)),
				"%s Week %d did not use the zero-effect Seoul routine receipt" % [
					route_id, int(GameState.turn)])
			var picked := _pick_allocation(route_id, month_index)
			if picked.is_empty():
				_expect(false, "%s Week %d had no legal production allocation" % [
					route_id, int(GameState.turn)])
				break
			var committed := CORE.commit_seoul_cycle_allocation(
				str(picked.get("capacity_id", "")),
				str(picked.get("node_id", "")), month_index)
			if not bool(committed.get("ok", false)):
				_expect(false, "%s Week %d allocation failed: %s" % [
					route_id, int(GameState.turn),
					str(committed.get("error", "unknown"))])
				break
			result["allocations"] = int(result["allocations"]) + 1
			var allocation_role := str(picked.get("role", ""))
			var route_counts: Dictionary = result["role_allocations"]
			route_counts[allocation_role] = int(
				route_counts.get(allocation_role, 0)) + 1
			result["role_allocations"] = route_counts
			if OS.has_environment("GANGNAM_CYCLE_TRACE"):
				var picked_preview: Dictionary = picked.get("preview", {})
				print("CYCLE_BALANCE_WEEK route=%s week=%d node=%s role=%s capacity=%d progress=%d effects=%s" % [
					route_id, int(GameState.turn),
					str(picked.get("node_id", "")), allocation_role,
					int(picked_preview.get("capacity_value", 0)),
					int(picked_preview.get("progress_gain", 0)),
					str(picked_preview.get("immediate_effects", {}))])
			_track_minima(result)

			if not await _resolve_cycle_entries(route_id):
				break
			_track_minima(result)
			var completed := CORE.complete_seoul_cycle_turn(month_index)
			if not bool(completed.get("ok", false)):
				_expect(false, "%s Week %d could not close atomically: %s" % [
					route_id, int(GameState.turn),
					str(completed.get("error", "unknown"))])
				break
			_track_minima(result)

			if int(GameState.week_of_month) < 4:
				var before_turn := int(GameState.turn)
				_expect(not GameState.advance_calendar() \
						and int(GameState.turn) == before_turn + 1,
					"%s Week %d used the wrong non-month calendar edge" % [
						route_id, before_turn])
				_track_minima(result)

		if GameState.is_game_over:
			break
		if int(GameState.week_of_month) != 4:
			break
		var closing_snapshot := CORE.seoul_cycle_snapshot(month_index)
		result["trigger_receipts"] = int(result["trigger_receipts"]) \
			+ (closing_snapshot.get("trigger_receipts", {}) as Dictionary).size()
		result["world_receipts"] = int(result["world_receipts"]) \
			+ (closing_snapshot.get("world_receipts", {}) as Dictionary).size()
		var before_month := CORE.month_opening_snapshot(month_index)
		_run_production_month_end(month_index)
		_track_minima(result)
		var month_row := _month_row(month_index)
		(result["months"] as Array).append(month_row)
		if GameState.is_game_over:
			result["death_week"] = month_index * 4
			result["ending"] = _last_ending_id
			break
		CORE.process_due_decline_outcomes(month_index)
		GameState.check_game_over()
		_track_minima(result)
		if GameState.is_game_over:
			result["death_week"] = month_index * 4
			result["ending"] = _last_ending_id
			break
		var after_month := _economy_snapshot()
		var summary := CORE.record_month_summary(
			month_index, before_month, after_month)
		_expect(str(summary.get("planning_mode", "")) \
				== CORE.SEOUL_CYCLE_MODE \
				and (summary.get("allocation_receipts", []) as Array).size() == 4,
			"%s Month %d summary did not retain four cycle allocations" % [
				route_id, month_index])
		result["month_summaries"] = int(result["month_summaries"]) + 1
		_expect(CORE.acknowledge_month_summary(month_index),
			"%s Month %d summary could not be acknowledged" % [
				route_id, month_index])

	result["final_money"] = float(GameState.money)
	result["final_health"] = int(GameState.health)
	result["final_mental"] = int(GameState.mental)
	result["final_turn"] = int(GameState.turn)
	result["employed"] = not GameState.current_job.is_empty()
	result["employment_id"] = str(GameState.current_job.get("id", ""))
	result["relationship_receipts"] = (
		GameState.core_loop_v2_state.get(
			"relationship_choice_receipts", {}) as Dictionary).size()
	if GameState.is_game_over and int(result["death_week"]) == 0:
		result["death_week"] = int(GameState.turn)
		result["ending"] = _last_ending_id
	return result


func _prepare_fresh_cycle(route_id: String) -> void:
	_last_ending_id = ""
	seed(int(ROUTE_SEEDS.get(route_id, 94100)))
	MetaProgression.data = DataRegistry.default_meta.duplicate(true)
	GameState.start_new_game(
		"김민준", "지방_상경", "직장형", "백수", "자유런", "현실")
	CORE.initialize_for_run(true)
	GameState.flags["prologue_done"] = true
	var state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	state["application_statuses"]["mirae_industrial_tech"] = "interviewed"
	GameState.core_loop_v2_state = state


func _pick_allocation(route_id: String, month_index: int) -> Dictionary:
	var snapshot := CORE.seoul_cycle_snapshot(month_index)
	var capacities: Array[Dictionary] = []
	for raw_capacity in snapshot.get("capacities", []):
		if raw_capacity is Dictionary \
				and not bool((raw_capacity as Dictionary).get("consumed", false)):
			capacities.append((raw_capacity as Dictionary).duplicate(true))
	var role_order := _allocation_role_order(route_id, snapshot)
	var nodes: Dictionary = snapshot.get("nodes", {})
	for role in role_order:
		var candidates: Array[Dictionary] = []
		for raw_node_id in nodes:
			var node_id := str(raw_node_id)
			var node: Dictionary = nodes.get(node_id, {})
			if _node_role(node_id, node) != str(role):
				continue
			for capacity in capacities:
				var capacity_id := str(capacity.get("id", ""))
				var preview := CORE.preview_seoul_cycle_allocation(
					capacity_id, node_id, month_index)
				if bool(preview.get("ok", false)):
					candidates.append({
						"capacity_id": capacity_id,
						"node_id": node_id,
						"role": role,
						"preview": preview,
					})
		if not candidates.is_empty():
			candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
				return _allocation_candidate_score(a, str(role)) \
					> _allocation_candidate_score(b, str(role)))
			return candidates.front()
	# A fatal path never allocates recovery voluntarily. If the remaining legal
	# contract has only recovery, it is better to report a real dead end than to
	# silently turn the costly route into a recovery route.
	if route_id == "fatal_cost":
		return {}
	for raw_node_id in nodes:
		var node_id := str(raw_node_id)
		for capacity in capacities:
			var capacity_id := str(capacity.get("id", ""))
			var preview := CORE.preview_seoul_cycle_allocation(
				capacity_id, node_id, month_index)
			if bool(preview.get("ok", false)):
				return {
					"capacity_id": capacity_id,
					"node_id": node_id,
					"role": _node_role(node_id, nodes.get(node_id, {})),
					"preview": preview,
				}
	return {}


func _allocation_role_order(
		route_id: String, snapshot: Dictionary) -> Array:
	var counts := {
		"livelihood": 0,
		"advancement": 0,
		"people": 0,
		"recovery": 0,
	}
	var nodes: Dictionary = snapshot.get("nodes", {})
	for raw_receipt in (snapshot.get(
			"allocation_receipts", {}) as Dictionary).values():
		if not raw_receipt is Dictionary:
			continue
		var node_id := str((raw_receipt as Dictionary).get("node_id", ""))
		var role := _node_role(node_id, nodes.get(node_id, {}))
		counts[role] = int(counts.get(role, 0)) + 1
	match route_id:
		"livelihood":
			# A livelihood-first support run still has to react to the crisis bands
			# visible on the production board. It keeps three paid weeks while stable,
			# two when either meter is strained, and one at the explicit danger band.
			# The fatal comparison route below is the deliberate no-recovery policy.
			var livelihood_target := 3
			if int(GameState.health) <= 20 or int(GameState.mental) <= 15:
				livelihood_target = 1
			elif int(GameState.health) <= 35 or int(GameState.mental) <= 30:
				livelihood_target = 2
			if int(counts["livelihood"]) < livelihood_target:
				return ["livelihood", "recovery", "advancement", "people"]
			return ["recovery", "livelihood", "advancement", "people"]
		"advancement":
			if _role_has_legal_allocation("advancement", snapshot):
				return ["advancement", "recovery", "livelihood", "people"]
			if int(counts["recovery"]) < 1:
				return ["recovery", "livelihood", "people", "advancement"]
			return ["livelihood", "recovery", "people", "advancement"]
		"people":
			if _role_has_legal_allocation("people", snapshot):
				return ["people", "recovery", "livelihood", "advancement"]
			if int(counts["livelihood"]) < 1:
				return ["livelihood", "recovery", "advancement", "people"]
			return ["recovery", "livelihood", "advancement", "people"]
		"recovery":
			return ["recovery", "livelihood", "advancement", "people"]
		_:
			return (ROUTE_ROLE_ORDER.get(route_id, []) as Array).duplicate()


func _role_has_legal_allocation(role: String, snapshot: Dictionary) -> bool:
	var nodes: Dictionary = snapshot.get("nodes", {})
	for raw_node_id in nodes:
		var node_id := str(raw_node_id)
		if _node_role(node_id, nodes.get(node_id, {})) != role:
			continue
		for raw_capacity in snapshot.get("capacities", []):
			if not raw_capacity is Dictionary \
					or bool((raw_capacity as Dictionary).get("consumed", false)):
				continue
			var preview := CORE.preview_seoul_cycle_allocation(
				str((raw_capacity as Dictionary).get("id", "")),
				node_id, int(snapshot.get("month", 0)))
			if bool(preview.get("ok", false)):
				return true
	return false


func _allocation_candidate_score(candidate: Dictionary, role: String) -> int:
	var preview: Dictionary = candidate.get("preview", {})
	var capacity_value := int(preview.get("capacity_value", 0))
	var progress_gain := int(preview.get("progress_gain", 0))
	if role == "recovery":
		# Recovery is the one repeatable node whose public benefit scales with
		# capacity. Preserve strong capacity for it instead of wasting it on a
		# repeat shift whose authored cost/pay is flat.
		return progress_gain * 10_000 + capacity_value
	if bool(preview.get("repeat_allocation", false)) \
			or bool(preview.get("fallback_allocation", false)):
		return -capacity_value
	var completed_bonus := 1_000_000 \
		if bool(preview.get("completed_now", false)) else 0
	# Before a scene's allowed week, reach the legal ceiling with the smallest
	# sufficient capacity. This preserves stronger capacity for the support
	# allocation without missing the authored deadline.
	return completed_bonus + progress_gain * 10_000 - capacity_value


func _node_role(node_id: String, node: Dictionary) -> String:
	var owner := str(node.get("owner", "")).strip_edges().to_lower()
	if owner == "livelihood" or "livelihood" in node_id:
		return "livelihood"
	if owner in ["career", "growth"] \
			or "advancement" in node_id or "resume" in node_id:
		return "advancement"
	if owner in ["self", "recovery"] \
			or "recovery" in node_id or "self" in node_id:
		return "recovery"
	return "people"


func _resolve_cycle_entries(route_id: String) -> bool:
	for pending_kind in ["trigger", "world"]:
		var pending: Dictionary = (
			CORE.pending_seoul_cycle_trigger()
			if pending_kind == "trigger"
			else CORE.pending_seoul_cycle_world())
		if pending.is_empty():
			continue
		var claim: Dictionary = (
			CORE.claim_seoul_cycle_trigger()
			if pending_kind == "trigger"
			else CORE.claim_seoul_cycle_world())
		var bundle_id := str(pending.get("bundle_id", ""))
		var began := bool(claim.get("ok", false)) and (
			CORE.begin_seoul_cycle_trigger(bundle_id)
			if pending_kind == "trigger"
			else CORE.begin_seoul_cycle_world(bundle_id))
		if not began:
			_expect(false, "%s Week %d could not begin %s %s" % [
				route_id, int(GameState.turn), pending_kind, bundle_id])
			return false
		if bundle_id == "demo_collision":
			var prepared := CORE.prepare_demo_collision()
			if not bool(prepared.get("ok", false)):
				_expect(false, "%s could not prepare First Bill: %s" % [
					route_id, str(prepared.get("error", "unknown"))])
				return false
		var scene_bundle := CORE.bundle(bundle_id)
		if not str(scene_bundle.get("action_id", "")).is_empty():
			if not await _execute_active_action(bundle_id, scene_bundle, route_id):
				return false
		else:
			if not _play_active_story(bundle_id, route_id):
				return false
		if CORE.complete_active_bundle() != bundle_id:
			_expect(false, "%s Week %d could not complete %s %s" % [
				route_id, int(GameState.turn), pending_kind, bundle_id])
			return false
	return true


func _execute_active_action(
		bundle_id: String, scene_bundle: Dictionary,
		route_id: String) -> bool:
	var action_id := str(scene_bundle.get("action_id", "")).strip_edges()
	var commitment := {
		"turn": int(GameState.turn),
		"pressure_id": bundle_id,
		"pressure_family": str(scene_bundle.get("kind", "routine")),
		"choice_id": action_id,
		"forgone_ids": [],
		"supplemental_to_seoul_cycle": true,
	}
	if not GameState.arm_weekly_commitment(commitment):
		_expect(false, "%s could not arm action %s" % [route_id, bundle_id])
		return false

	var config: Dictionary = (
		(scene_bundle.get("action_config", {}) as Dictionary).duplicate(true)
		if scene_bundle.get("action_config", {}) is Dictionary else {})
	var execution := str(config.get("execution", "")).strip_edges()
	var effects: Dictionary = {}
	var details: Dictionary = {}
	var flag_updates: Dictionary = {}
	var axis := str(config.get(
		"axis", "human" if execution == "rest" else "money"))
	var place_id := str(config.get(
		"place_id", "home" if execution == "rest" else "work"))
	match execution:
		"application":
			details = {
				"execution": "application",
				"application_id": str(config.get("application_id", "")),
				"status": str(config.get("status", "submitted")),
			}
			if not str(config.get("job_id", "")).is_empty():
				details["job_id"] = str(config.get("job_id", ""))
		"activity_task":
			var resolution := _activity_task_result(
				bundle_id, route_id == "fatal_cost")
			if not bool(resolution.get("ok", false)):
				_expect(false, "%s activity task failed: %s" % [
					bundle_id, str(resolution.get("error", "unknown"))])
				return false
			details = resolution.duplicate(true)
			details.erase("ok")
			effects = (details.get("effects", {}) as Dictionary).duplicate(true)
			axis = str(details.get("axis", axis))
			place_id = str(details.get("place_id", place_id))
		"instant_effect":
			effects = (config.get("effects", {}) as Dictionary).duplicate(true)
			details = {
				"execution": "instant_effect",
				"axis": axis,
				"place_id": place_id,
				"effects": effects.duplicate(true),
			}
		"rest":
			effects = (config.get("effects", {}) as Dictionary).duplicate(true)
			details = {
				"execution": "rest",
				"effects": effects.duplicate(true),
				"diminished_by_recovery_routine": false,
			}
		_:
			match action_id:
				"side_shift":
					var shift := await _play_side_shift(
						bundle_id, route_id == "fatal_cost")
					effects = (shift.get("effects", {}) as Dictionary).duplicate(true)
					details = (shift.get("details", {}) as Dictionary).duplicate(true)
					axis = "money"
					place_id = "work"
				"resume", "interview":
					var hunt := await _play_job_hunt(
						action_id, route_id == "fatal_cost")
					effects = (hunt.get("effects", {}) as Dictionary).duplicate(true)
					details = (hunt.get("details", {}) as Dictionary).duplicate(true)
					flag_updates = (
						(hunt.get("flags", {}) as Dictionary).duplicate(true))
					axis = "money"
					place_id = "work"
				"rest":
					# This is the controller's declared fallback when a legacy action
					# bundle has no action_config. It still travels through the same
					# atomic GameState transaction and is never a background routine.
					effects = {"mental": 10, "health": 3}
					details = {
						"execution": "rest",
						"effects": effects.duplicate(true),
						"diminished_by_recovery_routine": false,
					}
					axis = "human"
					place_id = "home"
				_:
					_expect(false, "%s has unsupported production action %s" % [
						bundle_id, action_id])
					return false

	var transaction := GameState.finalize_weekly_effect_action(
		action_id, effects, axis, place_id, "", details, flag_updates)
	if not bool(transaction.get("ok", false)):
		_expect(false, "%s action transaction failed: %s" % [
			bundle_id, str(transaction.get("error", "unknown"))])
		return false
	var raw_record: Variant = transaction.get("record", {})
	if not raw_record is Dictionary \
			or not CORE.note_action_commitment(raw_record as Dictionary):
		_expect(false, "%s did not produce its V2 action receipt" % bundle_id)
		return false
	if CORE.action_story_stage(bundle_id) == "story":
		if not CORE.acknowledge_action_story_result(bundle_id):
			_expect(false, "%s could not acknowledge its story-owned result" \
				% bundle_id)
			return false
		return _play_active_story(bundle_id, route_id)
	return true


func _activity_task_result(bundle_id: String, overreach: bool) -> Dictionary:
	var begun := CORE.begin_or_resume_activity_task(bundle_id)
	if not bool(begun.get("ok", false)):
		return begun
	var config: Dictionary = begun.get("config", {})
	var requirement_ids: Array = config.get("requirement_ids", [])
	var normal_steps := int(config.get("normal_steps", 0))
	if normal_steps < 1 or requirement_ids.size() <= normal_steps:
		return {"ok": false, "error": "invalid_activity_task_contract"}
	var selected: Array = requirement_ids.slice(0, normal_steps)
	var updated := CORE.update_activity_task_requirements(selected)
	if not bool(updated.get("ok", false)):
		return updated
	return CORE.resolve_activity_task(overreach)


func _play_side_shift(bundle_id: String, costly: bool) -> Dictionary:
	var game := ARUBA.new()
	add_child(game)
	await get_tree().process_frame
	var saved_job: Dictionary = GameState.current_job.duplicate(true)
	GameState.current_job = {
		"id": "job_02" if bundle_id == "m2_rain_delivery_shift" else "job_01",
	}
	var context := {
		"weather": "rain",
		"surge_pay": true,
	} if bundle_id == "m2_rain_delivery_shift" else {}
	game.open(context)
	GameState.current_job = saved_job

	if bundle_id == "m2_rain_delivery_shift":
		var picked_orders := _delivery_subset(costly)
		for order_index in picked_orders:
			game.call("_del_toggle", int(order_index))
		game.call("_del_confirm")
	else:
		while int(game.get("_conv_served")) < int(ARUBA.CONV_TOTAL):
			var slots: Array = game.get("_conv_slots")
			var slot_index := -1
			for index in range(slots.size()):
				if slots[index] != null:
					slot_index = index
					break
			if slot_index < 0:
				break
			if costly:
				game.call("_conv_timeout", slot_index)
			else:
				var customer: Dictionary = slots[slot_index]
				var choice_index := _best_convenience_choice(
					customer.get("actions", []))
				game.call("_conv_handle", slot_index, choice_index)
			game.call("_conv_free_slot", slot_index)

	var earned := int(game.get("_earned"))
	var stress := int(game.get("_stress_delta"))
	var health_delta := int(ARUBA.BASE_SHIFT_HEALTH_DELTA) \
		+ int(game.get("_health_delta"))
	var shift_receipt: Dictionary = game.get_last_shift_receipt()
	BGMPlayer.leave_activity_ambience()
	game.queue_free()
	await get_tree().process_frame
	var effects := {
		"money": earned,
		"stress": stress,
		"health": health_delta,
	}
	var details := {
		"execution": "side_shift",
		"axis": "money",
		"place_id": "work",
		"effects": effects.duplicate(true),
		"earned": earned,
		"health_delta": health_delta,
		"mental_delta": -stress,
	}
	if not shift_receipt.is_empty():
		details["shift"] = shift_receipt.duplicate(true)
	return {"effects": effects, "details": details}


func _best_convenience_choice(raw_actions: Variant) -> int:
	if not raw_actions is Array or (raw_actions as Array).is_empty():
		return 0
	var best_index := 0
	var best_score := -999999
	for index in range((raw_actions as Array).size()):
		var action: Dictionary = (raw_actions as Array)[index]
		var score := -int(action.get("stress", 0)) * 1000 \
			+ int(action.get("bonus", 0)) \
			+ int(action.get("health", 0)) * 1000
		if score > best_score:
			best_score = score
			best_index = index
	return best_index


func _delivery_subset(costly: bool) -> Array[int]:
	var orders: Array = ARUBA.DEL_ORDERS_DATA
	var best: Array[int] = []
	var best_primary := -1
	var best_secondary := -1
	for mask in range(1, 1 << orders.size()):
		var picked: Array[int] = []
		var minutes := 0
		var payout := 0
		for index in range(orders.size()):
			if (mask & (1 << index)) == 0:
				continue
			picked.append(index)
			minutes += int((orders[index] as Dictionary).get("time", 0))
			payout += int((orders[index] as Dictionary).get("tip", 0)) \
				+ int(ARUBA.DEL_BASE_BONUS) \
				+ int(ARUBA.DEL_RAIN_SURGE_PER_ORDER)
		if minutes > int(ARUBA.DEL_TIME_BUDGET):
			continue
		var primary := picked.size() if costly else payout
		var secondary := payout if costly else -picked.size()
		if primary > best_primary \
				or (primary == best_primary and secondary > best_secondary):
			best = picked
			best_primary = primary
			best_secondary = secondary
	return best


func _play_job_hunt(action_id: String, costly: bool) -> Dictionary:
	var game := JOB_HUNT.new()
	add_child(game)
	await get_tree().process_frame
	var mode := JOB_HUNT.Mode.RESUME \
		if action_id == "resume" else JOB_HUNT.Mode.INTERVIEW
	game.open(mode)
	var questions: Array = game.call("_get_questions")
	for question_index in range(questions.size()):
		game.set("_q_idx", question_index)
		game.set("_waiting", false)
		var choices: Array = game.call("_choices_for_question", question_index)
		var chosen_index := 0
		var chosen_score := 999 if costly else -999
		for index in range(choices.size()):
			var score := int((choices[index] as Dictionary).get("score", 0))
			if (costly and score < chosen_score) \
					or (not costly and score > chosen_score):
				chosen_index = index
				chosen_score = score
		game.call("_on_choose", chosen_index)
	var total_score := int(game.get("_total_score"))
	var maximum := maxi(1, questions.size() * 3)
	var ratio := float(total_score) / float(maximum)
	var quality := 3 if ratio >= 0.85 else 2 if ratio >= 0.6 \
		else 1 if ratio >= 0.35 else 0
	var stress := int(game.call("_final_stress_delta", quality))
	BGMPlayer.leave_activity_ambience("office")
	game.queue_free()
	await get_tree().process_frame
	var effects := {"stress": stress}
	var flags: Dictionary = {}
	if action_id == "resume":
		if quality == 3:
			effects["intelligence"] = 2
			flags["resume_polished"] = true
		elif quality == 2:
			effects["intelligence"] = 1
			flags["resume_polished"] = true
	else:
		if quality == 3:
			effects["social_skill"] = 2
			effects["luck"] = 1
			flags["interview_practiced"] = true
		elif quality == 2:
			effects["social_skill"] = 1
			flags["interview_practiced"] = true
		elif quality == 1:
			effects["luck"] = 1
	return {
		"effects": effects,
		"flags": flags,
		"details": {
			"execution": "job_hunt_minigame",
			"quality": quality,
			"effects": effects.duplicate(true),
		},
	}


func _play_active_story(bundle_id: String, route_id: String) -> bool:
	CORE.prepare_story_bundle(bundle_id)
	var pending: Array = CORE.resolved_event_roots(bundle_id)
	var visited := 0
	while not pending.is_empty():
		visited += 1
		if visited > 32:
			_expect(false, "%s story chain exceeded 32 fragments" % bundle_id)
			return false
		var event_id := str(pending.pop_front()).strip_edges()
		var event: Dictionary = DataRegistry.find_event(event_id)
		if event.is_empty():
			_expect(false, "%s lost authored story event %s" % [
				bundle_id, event_id])
			return false
		var choices: Array = event.get("choices", [])
		if choices.is_empty():
			continue
		var choice_index := _story_choice_index(
			bundle_id, event_id, choices, route_id)
		if choice_index < 0:
			_expect(false, "%s/%s had no available authored choice" % [
				bundle_id, event_id])
			return false
		var choice: Dictionary = choices[choice_index]
		if not GameState.apply_choice(event, choice):
			_expect(false, "%s/%s choice %d was rejected by GameState" % [
				bundle_id, event_id, choice_index])
			return false
		if not CORE.note_story_choice(event_id, choice_index):
			_expect(false, "%s/%s choice %d lost its V2 receipt" % [
				bundle_id, event_id, choice_index])
			return false
		var follow_up := str(choice.get("follow_up_event", "")).strip_edges()
		if not follow_up.is_empty() \
				and not CORE.story_follow_up_is_suppressed(
					event_id, choice_index, follow_up):
			pending.push_front(follow_up)
	return true


func _story_choice_index(
		_bundle_id: String, event_id: String, choices: Array,
		route_id: String) -> int:
	var available: Array[int] = []
	for index in range(choices.size()):
		var choice: Dictionary = choices[index]
		if not GameState.choice_available(
				DataRegistry.find_event(event_id), choice):
			continue
		if event_id == "v2_demo_first_bill":
			var obligation_id := str(
				choice.get("v2_obligation_id", "")).strip_edges()
			if obligation_id.is_empty() \
					or not CORE.story_choice_available(event_id, obligation_id):
				continue
		available.append(index)
	if available.is_empty():
		return -1
	if event_id == "v2_demo_first_bill":
		var preferred: Array = ({
			"livelihood": ["urgent_paid_shift", "hanbit_month_close"],
			"advancement": ["city_work_sample", "hanbit_month_close"],
			"people": ["daeun_checkin", "father_call", "jaehyuk_reply"],
			"recovery": ["body_rest"],
			"fatal_cost": ["urgent_paid_shift"],
		}.get(route_id, []) as Array)
		for obligation_id in preferred:
			for index in available:
				if str((choices[index] as Dictionary).get(
						"v2_obligation_id", "")) == str(obligation_id):
					return index
	if route_id == "fatal_cost":
		var worst_index := available[0]
		var worst_cost := 999999.0
		for index in available:
			var effects: Dictionary = (choices[index] as Dictionary).get(
				"effects", {}) if (choices[index] as Dictionary).get(
					"effects", {}) is Dictionary else {}
			var score := float(effects.get("health", 0.0)) \
				+ float(effects.get("mental", 0.0)) \
				- float(effects.get("stress", 0.0))
			if score < worst_cost:
				worst_cost = score
				worst_index = index
		return worst_index
	return available[0]


func _run_production_month_end(closing_month: int) -> void:
	var job_system := JOB_SYSTEM.new()
	var relationship_system := RELATIONSHIP_SYSTEM.new()
	var inventory_system := INVENTORY_SYSTEM.new()
	job_system.process_monthly_job()
	relationship_system.process_monthly_relationships()
	inventory_system.process_monthly_items()
	if not GameState.current_job.is_empty():
		GameState.add_tendency("career", 1)
	GameState.claim_initial_settlement_subsidy()
	GameState.apply_monthly_pressure()
	var month_ended := GameState.advance_calendar()
	_expect(month_ended or GameState.is_game_over,
		"Month %d neither crossed the production calendar edge nor ended the run" \
		% closing_month)
	GameState.check_game_over()
	job_system.free()
	relationship_system.free()
	inventory_system.free()


func _economy_snapshot() -> Dictionary:
	return {
		"turn": int(GameState.turn),
		"date": GameState.get_date_string(),
		"money": float(GameState.money),
		"cash_shortfall": CORE.cash_shortfall_for_money(float(GameState.money)),
		"monthly_income": float(GameState.monthly_income),
		"fixed_expense": float(GameState.get_monthly_required_cash()),
		"health": int(GameState.health),
		"mental": int(GameState.mental),
	}


func _month_row(month_index: int) -> Dictionary:
	return {
		"month": month_index,
		"money": int(round(float(GameState.money))),
		"health": int(GameState.health),
		"mental": int(GameState.mental),
		"employed": not GameState.current_job.is_empty(),
		"employment_id": str(GameState.current_job.get("id", "")),
	}


func _track_minima(result: Dictionary) -> void:
	result["min_money"] = minf(
		float(result.get("min_money", GameState.money)), float(GameState.money))
	result["min_health"] = mini(
		int(result.get("min_health", GameState.health)), int(GameState.health))
	result["min_mental"] = mini(
		int(result.get("min_mental", GameState.mental)), int(GameState.mental))
	result["max_money"] = maxf(
		float(result.get("max_money", GameState.money)), float(GameState.money))
	result["max_health"] = maxi(
		int(result.get("max_health", GameState.health)), int(GameState.health))
	result["max_mental"] = maxi(
		int(result.get("max_mental", GameState.mental)), int(GameState.mental))


func _print_route(result: Dictionary) -> void:
	var route_id := str(result.get("route", ""))
	for raw_month in result.get("months", []):
		var month: Dictionary = raw_month
		print("CYCLE_BALANCE_MONTH route=%s label=%s month=%d money=%d health=%d mental=%d employment=%s job=%s" % [
			route_id, str(result.get("label", "")), int(month.get("month", 0)),
			int(month.get("money", 0)), int(month.get("health", 0)),
			int(month.get("mental", 0)),
			"employed" if bool(month.get("employed", false)) else "unemployed",
			str(month.get("employment_id", "-"))])
	print("CYCLE_BALANCE_RUN route=%s survived=%d death_week=%d ending=%s allocations=%d summaries=%d trigger_receipts=%d world_receipts=%d roles=%s min_money=%d min_health=%d min_mental=%d final_money=%d final_health=%d final_mental=%d final_employment=%s" % [
		route_id, 0 if int(result.get("death_week", 0)) > 0 else 1,
		int(result.get("death_week", 0)), str(result.get("ending", "-")),
		int(result.get("allocations", 0)), int(result.get("month_summaries", 0)),
		int(result.get("trigger_receipts", 0)), int(result.get("world_receipts", 0)),
		str(result.get("role_allocations", {})),
		int(round(float(result.get("min_money", 0.0)))),
		int(result.get("min_health", 0)), int(result.get("min_mental", 0)),
		int(round(float(result.get("final_money", 0.0)))),
		int(result.get("final_health", 0)), int(result.get("final_mental", 0)),
		str(result.get("employment_id", "-"))])


func _assert_route_contracts() -> void:
	for route_id in NORMAL_ROUTE_IDS:
		var result: Dictionary = _results.get(route_id, {})
		_expect(not result.is_empty(), "%s produced no balance result" % route_id)
		_expect(int(result.get("allocations", 0)) == 24,
			"%s executed %d actual allocations instead of 24" % [
				route_id, int(result.get("allocations", 0))])
		_expect((result.get("months", []) as Array).size() == 6 \
				and int(result.get("month_summaries", 0)) == 6,
			"%s did not produce six actual month-end rows/summaries" % route_id)
		_expect(int(result.get("death_week", 0)) == 0 \
				and int(result.get("final_turn", 0)) == 25 \
				and int(result.get("min_health", 0)) > 0 \
				and int(result.get("min_mental", 0)) > 0,
			"%s did not survive the 24-week demo" % route_id)
		_expect(int(result.get("world_receipts", 0)) >= 5,
			"%s bypassed authored world-clock receipts" % route_id)

	var advancement: Dictionary = _results.get("advancement", {})
	_expect(bool(advancement.get("employed", false)) \
			and str(advancement.get("employment_id", "")) == "job_03",
		"advancement route did not earn Hanbit employment through its receipts")
	var livelihood: Dictionary = _results.get("livelihood", {})
	var recovery: Dictionary = _results.get("recovery", {})
	var people: Dictionary = _results.get("people", {})
	var livelihood_roles: Dictionary = livelihood.get("role_allocations", {})
	_expect(int(livelihood_roles.get("livelihood", 0)) \
			> int(livelihood_roles.get("recovery", 0)) \
			and int(livelihood_roles.get("recovery", 0)) > 0,
		"livelihood route did not remain livelihood-first while using its visible recovery escape")
	var advancement_roles: Dictionary = advancement.get(
		"role_allocations", {})
	_expect(int(advancement_roles.get("advancement", 0)) >= 6 \
			and int(advancement_roles.get("recovery", 0)) >= 6,
		"advancement route did not complete each month's future node with a support allocation")
	var people_roles: Dictionary = people.get("role_allocations", {})
	_expect(int(people_roles.get("people", 0)) >= 6,
		"people route did not spend capacity on a named people node in every month")
	var recovery_roles: Dictionary = recovery.get("role_allocations", {})
	_expect(int(recovery_roles.get("recovery", 0)) == 24,
		"recovery route did not spend all 24 actual capacities on recovery")
	_expect(float(livelihood.get("final_money", -INF)) \
			> float(recovery.get("final_money", INF)),
		"livelihood route did not finish with more cash than recovery")
	_expect(int(recovery.get("min_health", -1)) \
			> int(livelihood.get("min_health", 101)) \
			and int(recovery.get("min_mental", -1)) \
			> int(livelihood.get("min_mental", 101)),
		"recovery route did not protect both body and mind minima")
	_expect(int(people.get("relationship_receipts", 0)) \
			> int(livelihood.get("relationship_receipts", 999)),
		"people route did not produce more relationship receipts than livelihood")

	var fatal: Dictionary = _results.get("fatal_cost", {})
	var fatal_roles: Dictionary = fatal.get("role_allocations", {})
	_expect(int(fatal.get("death_week", 0)) in [4, 8, 12, 16, 20, 24] \
			and str(fatal.get("ending", "")) in ["burnout", "mental_break"] \
			and int(fatal_roles.get("recovery", 0)) == 0 \
			and (int(fatal.get("min_health", 1)) == 0 \
				or int(fatal.get("min_mental", 1)) == 0),
		"costly route did not resolve an actual body/mind GameState ending")


func _assert_locked_numbers() -> void:
	if EXPECTED_MONTHS.is_empty() or EXPECTED_MINIMA.is_empty():
		_expect(false,
			"cycle balance baselines are not locked; copy only this runner's "
			+ "production rows into EXPECTED_MONTHS/EXPECTED_MINIMA")
		return
	for route_id in ALL_ROUTE_IDS:
		var result: Dictionary = _results.get(route_id, {})
		_expect(result.get("months", []) == EXPECTED_MONTHS.get(route_id, []),
			"%s monthly money/health/mental/employment baseline drifted" % route_id)
		var actual_minima := {
			"min_money": int(round(float(result.get("min_money", 0.0)))),
			"min_health": int(result.get("min_health", 0)),
			"min_mental": int(result.get("min_mental", 0)),
			"death_week": int(result.get("death_week", 0)),
			"ending": str(result.get("ending", "")),
		}
		_expect(actual_minima == EXPECTED_MINIMA.get(route_id, {}),
			"%s run-minimum/death baseline drifted: %s" % [
				route_id, str(actual_minima)])


func _stop_test_audio() -> void:
	for player_value in AudioManager.get("_pool"):
		var player := player_value as AudioStreamPlayer
		if player != null:
			player.stop()
			player.stream = null
	BGMPlayer.stop()
	for player_key in [
		"_player_a", "_player_b", "_ambience_player", "_season_player",
		"_human_ambience_player",
	]:
		var bgm_player := BGMPlayer.get(player_key) as AudioStreamPlayer
		if bgm_player != null:
			bgm_player.stop()
			bgm_player.stream = null
	await get_tree().process_frame
	# The headless audio mixer releases playback references asynchronously.
	# Drain more than one mixer interval so a successful numeric gate cannot
	# leave a misleading ObjectDB leak warning in its CI log.
	await get_tree().create_timer(0.25).timeout


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
