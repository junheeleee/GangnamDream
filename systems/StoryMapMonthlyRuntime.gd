extends RefCounted
class_name StoryMapMonthlyRuntime

## Small, deterministic M01..M06 strategy runtime.
##
## It intentionally does not touch GameState or SaveManager.  The playtest owns
## a separate JSON file and stores only this canonical state.

const SCHEMA_VERSION := 1
const FIRST_MONTH := 1
const LAST_MONTH := 6
const STORY_MAP_PATH := "res://content/meta/story_map.json"
const AXES := ["cash", "health", "trust"]
const RECEIPT_STATES := ["completed", "deferred", "expired"]

var _story_map: Dictionary = {}
var _months: Dictionary = {}
var _cards: Dictionary = {}
var _card_months: Dictionary = {}


func load_story_map(path: String = STORY_MAP_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return _failure("map_missing", "Story map file is missing.")
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		return _failure("map_invalid_json", "Story map is not a JSON object.")
	return configure(parsed)


func configure(data: Dictionary) -> Dictionary:
	_story_map = data.duplicate(true)
	_months.clear()
	_cards.clear()
	_card_months.clear()
	var chapters: Variant = _story_map.get("chapters")
	if not chapters is Array:
		return _clear_and_fail("map_missing_chapters", "Story map has no chapters.")
	for raw_chapter in chapters:
		if not raw_chapter is Dictionary:
			continue
		for raw_month in (raw_chapter as Dictionary).get("months", []):
			if not raw_month is Dictionary:
				continue
			var month_number := int((raw_month as Dictionary).get("month", 0))
			if month_number < FIRST_MONTH or month_number > LAST_MONTH:
				continue
			if _months.has(month_number):
				return _clear_and_fail("map_duplicate_month", "Duplicate month in story map.")
			var month: Dictionary = (raw_month as Dictionary).duplicate(true)
			var raw_cards: Variant = month.get("commitments")
			if not raw_cards is Array or raw_cards.size() < 2 or raw_cards.size() > 4:
				return _clear_and_fail("map_invalid_cards", "Each month needs two to four commitments.")
			_months[month_number] = month
			for raw_card in raw_cards:
				if not raw_card is Dictionary:
					return _clear_and_fail("map_invalid_card", "A commitment is not an object.")
				var card: Dictionary = raw_card
				var card_id := str(card.get("id", "")).strip_edges()
				var axis := str(card.get("axis", ""))
				if card_id.is_empty() or _cards.has(card_id) or axis not in AXES:
					return _clear_and_fail("map_invalid_card", "A commitment id or axis is invalid.")
				if str(card.get("miss", "")) not in ["deferred", "expired"]:
					return _clear_and_fail("map_invalid_miss", "A commitment miss state is invalid.")
				_cards[card_id] = card.duplicate(true)
				_card_months[card_id] = month_number
	for month_number in range(FIRST_MONTH, LAST_MONTH + 1):
		if not _months.has(month_number):
			return _clear_and_fail("map_missing_month", "Story map is missing an early month.")
	return {"ok": true, "error_code": "", "error": "", "map": _story_map.duplicate(true)}


func initial_state() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"next_month": FIRST_MONTH,
		"margin_axis": "",
		"receipts": {},
		"gains": [],
		"costs": [],
		"open_debts": [],
		"plans": [],
		"finished": false,
	}


func normalize_state(raw_state: Dictionary) -> Dictionary:
	if not _configured():
		return _failure("runtime_unconfigured", "Story map was not loaded.")
	if int(raw_state.get("schema_version", 0)) != SCHEMA_VERSION:
		return _failure("state_schema", "Playtest save has an unsupported schema.")
	var raw_plans: Variant = raw_state.get("plans")
	if not raw_plans is Array or raw_plans.size() > LAST_MONTH:
		return _failure("state_plans", "Playtest save has an invalid plan list.")
	var rebuilt := initial_state()
	for index in range(raw_plans.size()):
		var raw_plan: Variant = raw_plans[index]
		if not raw_plan is Dictionary:
			return _failure("state_plan", "Playtest save contains an invalid plan.")
		var plan: Dictionary = raw_plan
		if int(plan.get("month", 0)) != index + FIRST_MONTH:
			return _failure("state_plan_order", "Playtest months are not contiguous.")
		var resolved := resolve_month(
			rebuilt,
			str(plan.get("primary_id", "")),
			str(plan.get("optional_id", "")),
		)
		if not bool(resolved.get("ok", false)):
			return _failure("state_replay", str(resolved.get("error", "Saved plan is no longer legal.")))
		rebuilt = (resolved.get("state", {}) as Dictionary).duplicate(true)
		var rebuilt_plan: Dictionary = (rebuilt.get("plans", []) as Array)[index]
		for key in ["margin_before", "margin_after", "focus_actor"]:
			if plan.has(key) and str(plan.get(key, "")) != str(rebuilt_plan.get(key, "")):
				return _failure("state_plan_mismatch", "Saved plan evidence does not match its choices.")
	return {"ok": true, "error_code": "", "error": "", "state": rebuilt}


func snapshot(state: Dictionary) -> Dictionary:
	if not _configured():
		return _failure("runtime_unconfigured", "Story map was not loaded.")
	var month_number := int(state.get("next_month", 0))
	var finished := bool(state.get("finished", false))
	if finished:
		return {
			"ok": true,
			"error_code": "",
			"error": "",
			"finished": true,
			"month": LAST_MONTH + 1,
			"margin_axis": "",
			"cards": [],
			"plans": (state.get("plans", []) as Array).duplicate(true),
			"receipts": (state.get("receipts", {}) as Dictionary).duplicate(true),
			"gains": (state.get("gains", []) as Array).duplicate(),
			"costs": (state.get("costs", []) as Array).duplicate(),
		}
	if month_number < FIRST_MONTH or month_number > LAST_MONTH:
		return _failure("state_month", "Playtest state has an invalid month.")
	return {
		"ok": true,
		"error_code": "",
		"error": "",
		"finished": false,
		"month": month_number,
		"margin_axis": str(state.get("margin_axis", "")),
		"month_data": month_data(month_number),
		"cards": available_commitments(state),
		"plans": (state.get("plans", []) as Array).duplicate(true),
		"receipts": (state.get("receipts", {}) as Dictionary).duplicate(true),
		"gains": (state.get("gains", []) as Array).duplicate(),
		"costs": (state.get("costs", []) as Array).duplicate(),
		"open_debts": (state.get("open_debts", []) as Array).duplicate(),
	}


func month_data(month_number: int) -> Dictionary:
	return (_months.get(month_number, {}) as Dictionary).duplicate(true)


func card_data(card_id: String) -> Dictionary:
	return (_cards.get(card_id, {}) as Dictionary).duplicate(true)


func available_commitments(state: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var month_number := int(state.get("next_month", 0))
	if not _months.has(month_number):
		return result
	var receipts: Dictionary = state.get("receipts", {})
	for raw_card in (_months[month_number] as Dictionary).get("commitments", []):
		var card: Dictionary = raw_card
		if _card_is_available(card, receipts):
			result.append(card.duplicate(true))
	return result


func preflight(
	state: Dictionary,
	primary_id: String,
	optional_id: String = "",
) -> Dictionary:
	if not _configured():
		return _failure("runtime_unconfigured", "Story map was not loaded.")
	if bool(state.get("finished", false)):
		return _failure("run_finished", "The six-month playtest is already complete.")
	var available := available_commitments(state)
	var available_by_id: Dictionary = {}
	for card in available:
		available_by_id[str(card.get("id", ""))] = card
	if not available_by_id.has(primary_id):
		return _failure("primary_unavailable", "Choose an available protected promise.")
	if optional_id.is_empty():
		return {"ok": true, "error_code": "", "error": ""}
	if optional_id == primary_id:
		return _failure("roles_duplicate", "One promise cannot fill both roles.")
	if not available_by_id.has(optional_id):
		return _failure("optional_unavailable", "The alongside promise is unavailable.")
	var margin_axis := str(state.get("margin_axis", ""))
	if margin_axis.is_empty():
		return _failure("margin_missing", "No carried margin is available.")
	var optional_card: Dictionary = available_by_id[optional_id]
	if str(optional_card.get("axis", "")) != margin_axis:
		return _failure("margin_axis_mismatch", "Carried margin must match the alongside promise.")
	return {"ok": true, "error_code": "", "error": ""}


func resolve_month(
	state: Dictionary,
	primary_id: String,
	optional_id: String = "",
) -> Dictionary:
	var gate := preflight(state, primary_id, optional_id)
	if not bool(gate.get("ok", false)):
		gate["state"] = state.duplicate(true)
		return gate
	var month_number := int(state.get("next_month", 0))
	var available := available_commitments(state)
	var selected_ids := {primary_id: "protected"}
	if not optional_id.is_empty():
		selected_ids[optional_id] = "optional_second"

	var next_state := state.duplicate(true)
	var receipts: Dictionary = (state.get("receipts", {}) as Dictionary).duplicate(true)
	var gains: Array = (state.get("gains", []) as Array).duplicate()
	var costs: Array = (state.get("costs", []) as Array).duplicate()
	var open_debts: Array = (state.get("open_debts", []) as Array).duplicate()
	var completed: Array[String] = []
	var missed: Array[Dictionary] = []
	var repaid: Array[String] = []
	var primary_card: Dictionary = _cards[primary_id]
	var primary_repaid_burden := false
	var focus_actor := ""

	for card in available:
		var card_id := str(card.get("id", ""))
		var strategy: Dictionary = card.get("strategy", {})
		var actors := _focus_actors(card, state)
		if not actors.is_empty():
			var candidate_actor := str(actors.values()[0])
			if focus_actor.is_empty():
				focus_actor = candidate_actor
			elif focus_actor != candidate_actor:
				var failed := _failure(
					"focus_actor_conflict", "One month resolved two different focus actors.")
				failed["state"] = state.duplicate(true)
				return failed
		if selected_ids.has(card_id):
			completed.append(card_id)
			var completed_data: Dictionary = strategy.get("completed", {})
			for gain in completed_data.get("gains", []):
				_add_unique(gains, str(gain))
			for source_id in strategy.get("repays_deferred", []):
				var source := str(source_id)
				if source in open_debts:
					open_debts.erase(source)
					_remove_missed_costs(costs, source, "debt.")
					_add_unique(repaid, source)
					if card_id == primary_id:
						primary_repaid_burden = true
			for pressure_value in strategy.get("repays_pressure", []):
				var pressure := str(pressure_value)
				if pressure in costs:
					costs.erase(pressure)
					_add_unique(repaid, pressure)
					if card_id == primary_id:
						primary_repaid_burden = true
			receipts[card_id] = _receipt_row(
				"completed", month_number, str(selected_ids[card_id]), actors)
		else:
			var missed_data: Dictionary = strategy.get("missed", {})
			var miss_state := str(card.get("miss", "expired"))
			var card_costs: Array[String] = []
			for cost_value in missed_data.get("costs", []):
				var cost := str(cost_value)
				_add_unique(costs, cost)
				card_costs.append(cost)
			if miss_state == "deferred":
				_add_unique(open_debts, card_id)
			else:
				for source_id in strategy.get("repays_deferred", []):
					var source := str(source_id)
					if source in open_debts:
						open_debts.erase(source)
						_remove_missed_costs(costs, source, "debt.")
			receipts[card_id] = _receipt_row(miss_state, month_number, "", actors)
			missed.append({"id": card_id, "state": miss_state, "costs": card_costs})

	var margin_before := str(state.get("margin_axis", ""))
	var margin_after := ""
	if optional_id.is_empty() and not primary_repaid_burden:
		margin_after = str(primary_card.get("axis", ""))
	var plan := {
		"month": month_number,
		"primary_id": primary_id,
		"optional_id": optional_id,
		"margin_before": margin_before,
		"margin_after": margin_after,
		"focus_actor": focus_actor,
	}
	var plans: Array = (state.get("plans", []) as Array).duplicate(true)
	plans.append(plan)
	var next_month := month_number + 1
	next_state["next_month"] = next_month
	next_state["margin_axis"] = margin_after
	next_state["receipts"] = receipts
	next_state["gains"] = _sorted_strings(gains)
	next_state["costs"] = _sorted_strings(costs)
	next_state["open_debts"] = _sorted_strings(open_debts)
	next_state["plans"] = plans
	next_state["finished"] = next_month > LAST_MONTH
	return {
		"ok": true,
		"error_code": "",
		"error": "",
		"state": next_state,
		"result": {
			"month": month_number,
			"primary_id": primary_id,
			"optional_id": optional_id,
			"completed": completed,
			"missed": missed,
			"repaid": repaid,
			"margin_before": margin_before,
			"margin_after": margin_after,
			"focus_actor": focus_actor,
		},
	}


func _card_is_available(card: Dictionary, receipts: Dictionary) -> bool:
	var strategy: Dictionary = card.get("strategy", {})
	var availability: Variant = strategy.get("availability")
	if not availability is Dictionary:
		return true
	var conditions: Variant = (availability as Dictionary).get("receipts_any")
	if not conditions is Array or conditions.is_empty():
		return false
	for raw_condition in conditions:
		if not raw_condition is Dictionary:
			continue
		var condition: Dictionary = raw_condition
		var source_id := str(condition.get("id", ""))
		if not receipts.has(source_id):
			continue
		var row: Dictionary = receipts[source_id]
		if str(row.get("state", "")) in condition.get("states", []):
			return true
	return false


func _focus_actors(card: Dictionary, state: Dictionary) -> Dictionary:
	var strategy: Dictionary = card.get("strategy", {})
	var focus: Variant = strategy.get("focus")
	if not focus is Dictionary:
		return {}
	var focus_data: Dictionary = focus
	var slot := str(focus_data.get("actor_slot", ""))
	if slot.is_empty():
		return {}
	if str(focus_data.get("kind", "")) == "receipt_actor":
		var source_id := str(focus_data.get("source_receipt_id", ""))
		var source_row: Dictionary = (state.get("receipts", {}) as Dictionary).get(source_id, {})
		var source_actors: Dictionary = source_row.get("actors", {})
		var actor := str(source_actors.get(slot, ""))
		return {} if actor.is_empty() else {slot: actor}
	if str(focus_data.get("kind", "")) != "selection_focus":
		return {}
	var source_to_actor: Dictionary = {}
	var source_month := 0
	for raw_source in focus_data.get("sources", []):
		if not raw_source is Dictionary:
			continue
		var source: Dictionary = raw_source
		var source_id := str(source.get("commitment_id", ""))
		source_to_actor[source_id] = str(source.get("actor_id", ""))
		source_month = int(_card_months.get(source_id, 0))
	for raw_plan in state.get("plans", []):
		if not raw_plan is Dictionary or int((raw_plan as Dictionary).get("month", 0)) != source_month:
			continue
		var plan: Dictionary = raw_plan
		for selected_id in [str(plan.get("primary_id", "")), str(plan.get("optional_id", ""))]:
			if source_to_actor.has(selected_id):
				return {slot: str(source_to_actor[selected_id])}
	return {}


func _receipt_row(
	state_name: String,
	month_number: int,
	selection_slot: String,
	actors: Dictionary,
) -> Dictionary:
	return {
		"state": state_name,
		"resolved_month": month_number,
		"selection_slot": selection_slot,
		"actors": actors.duplicate(true),
	}


func _remove_missed_costs(costs: Array, source_id: String, prefix: String) -> void:
	var source_card: Dictionary = _cards.get(source_id, {})
	var strategy: Dictionary = source_card.get("strategy", {})
	var missed: Dictionary = strategy.get("missed", {})
	for raw_cost in missed.get("costs", []):
		var cost := str(raw_cost)
		if cost.begins_with(prefix):
			costs.erase(cost)


func _add_unique(values: Array, value: String) -> void:
	if not value in values:
		values.append(value)


func _sorted_strings(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		var text := str(value)
		if not text in result:
			result.append(text)
	result.sort()
	return result


func _configured() -> bool:
	return _months.size() == LAST_MONTH and not _cards.is_empty()


func _clear_and_fail(code: String, message: String) -> Dictionary:
	_story_map.clear()
	_months.clear()
	_cards.clear()
	_card_months.clear()
	return _failure(code, message)


func _failure(code: String, message: String) -> Dictionary:
	return {"ok": false, "error_code": code, "error": message}
