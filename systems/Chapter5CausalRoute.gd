extends RefCounted
class_name Chapter5CausalRoute

## Typed, locale-neutral receipt reducer for the product-owned M49-M55 route.
## It never changes AP, stats, money, transactions, or ending state. Callers
## may only present the next exact-week root and commit its authored choice.

const SCHEMA_VERSION := 1
const LEDGER_PATH := "res://content/meta/chapter5_causal_ledger.json"
const LEDGER_ID := "chapter5_m49_m55_causal_route_v1"
const EXPECTED_ROOT_COUNT := 19
const EXPECTED_CHOICE_COUNT := 47
const ENTRY_PLAYER_ROUTE := "투자형"
const ENTRY_MIN_TOTAL_ASSETS := 2_000_000_000.0
const ENTRY_TURN := 195
const ENTRY_ROUTE_ID := "investment_property"
const ENTRY_ECONOMIC_ROUTE := "investment"
const ENTRY_ASSET_BAND := "at_least_2b"
const ENTRY_ACTOR_BINDINGS := {
	"chooser": "player",
	"proposer": "sangchul",
	"reviewer": "sangchul",
	"protected_person": "daeun",
	"guarantee_party": "jaehyuk",
	"cost_witness": "minseo",
}
const CLOSE_REASON_READ_SURFACE_INVALID := "read_surface_invalid"
const ROUTE_CLOSE_REASONS: Array[String] = [
	CLOSE_REASON_READ_SURFACE_INVALID,
]
const OWNED_EVENT_IDS: Array[String] = [
	"arc_y5_contract_cover_investment",
	"arc_y5_contract_reviewer_delivery_sangchul",
	"arc_y5_final_push_deadline_investment",
	"arc_y5_protection_boundary_daeun",
	"arc_y5_burnout_check_reference",
	"arc_y5_minseo_goal_cost_reference",
	"arc_y5_after_goal_daeun",
	"arc_y5_final_offer",
	"arc_y5_final_offer_reference_delivery",
	"arc_y5_jaehyuk_guarantee_request_reference",
	"arc_y5_jaehyuk_return_call_reference",
	"arc_y5_jaehyuk_father_document_reference",
	"arc_y5_guarantee_protected_show_daeun",
	"arc_y5_jaehyuk_guarantee_decision_reference",
	"arc_sangchul_final_door",
	"arc_y5_sangchul_review_receipt",
	"arc_y5_three_in_room",
	"arc_y5_three_in_room_decision",
	"arc_y5_room_consent_receipt",
]
const OWNED_TURNS: Array[int] = [
	195, 196, 197, 200, 201, 203, 204, 207, 208, 209,
	210, 210, 211, 212, 215, 216, 217, 219, 220,
]
const CAUSAL_READ_SOURCES := {
	"arc_y5_contract_reviewer_delivery_sangchul": {
		"source_event_ids": ["arc_y5_contract_cover_investment"],
		"optional_source_event_ids": [],
	},
	"arc_y5_final_push_deadline_investment": {
		"source_event_ids": ["arc_y5_contract_reviewer_delivery_sangchul"],
		"optional_source_event_ids": [],
	},
	"arc_y5_protection_boundary_daeun": {
		"source_event_ids": ["arc_y5_final_push_deadline_investment"],
		"optional_source_event_ids": [],
	},
	"arc_y5_burnout_check_reference": {
		"source_event_ids": ["arc_y5_protection_boundary_daeun"],
		"optional_source_event_ids": [],
	},
	"arc_y5_minseo_goal_cost_reference": {
		"source_event_ids": ["arc_y5_burnout_check_reference"],
		"optional_source_event_ids": [],
	},
	"arc_y5_after_goal_daeun": {
		"source_event_ids": ["arc_y5_minseo_goal_cost_reference"],
		"optional_source_event_ids": [],
	},
	"arc_y5_final_offer": {
		"source_event_ids": ["arc_y5_after_goal_daeun"],
		"optional_source_event_ids": [],
	},
	"arc_y5_final_offer_reference_delivery": {
		"source_event_ids": ["arc_y5_final_offer"],
		"optional_source_event_ids": [],
	},
	"arc_y5_jaehyuk_guarantee_request_reference": {
		"source_event_ids": ["arc_y5_final_offer_reference_delivery"],
		"optional_source_event_ids": [],
	},
	"arc_y5_jaehyuk_return_call_reference": {
		"source_event_ids": ["arc_y5_jaehyuk_guarantee_request_reference"],
		"optional_source_event_ids": [],
	},
	"arc_y5_jaehyuk_father_document_reference": {
		"source_event_ids": ["arc_y5_jaehyuk_return_call_reference"],
		"optional_source_event_ids": [],
	},
	"arc_y5_guarantee_protected_show_daeun": {
		"source_event_ids": ["arc_y5_jaehyuk_father_document_reference"],
		"optional_source_event_ids": [],
	},
	"arc_y5_jaehyuk_guarantee_decision_reference": {
		"source_event_ids": ["arc_y5_guarantee_protected_show_daeun"],
		"optional_source_event_ids": [],
	},
	"arc_sangchul_final_door": {
		"source_event_ids": ["arc_y5_jaehyuk_guarantee_decision_reference"],
		"optional_source_event_ids": [],
	},
	"arc_y5_three_in_room": {
		"source_event_ids": [
			"arc_y5_jaehyuk_guarantee_decision_reference",
			"arc_sangchul_final_door",
			"arc_y5_sangchul_review_receipt",
		],
		"optional_source_event_ids": ["arc_y5_sangchul_review_receipt"],
	},
	"arc_y5_three_in_room_decision": {
		"source_event_ids": ["arc_y5_three_in_room"],
		"optional_source_event_ids": [],
	},
}
const STATE_KEYS: Array[String] = [
	"schema_version", "ledger_id", "status", "closed_reason", "entry",
	"receipts", "order",
]
const ENTRY_KEYS: Array[String] = [
	"route_id", "turn", "economic_route", "asset_band", "actor_bindings",
]
const RECEIPT_KEYS: Array[String] = [
	"sequence", "event_id", "turn", "choice_index", "actor_bindings", "receipts",
]

static var _ledger_cache: Dictionary = {}
static var _ledger_checked: bool = false


static func default_state() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"ledger_id": LEDGER_ID,
		"status": "open",
		"closed_reason": "",
		"entry": {},
		"receipts": {},
		"order": [],
	}


static func product_path_available(
		state: Dictionary, player_route: String,
		investment_identity_ready: bool, participants_ready: bool,
		total_assets: float) -> bool:
	# The fixed 2.58-billion-won property package is the investment/near-goal
	# vertical, not a universal Chapter 5 premise. The exact entry lock keeps the
	# route alive after entry even if the market later falls below the threshold;
	# otherwise the story would disappear halfway through the signed paper trail.
	var checked := _canonical_state(state)
	if not bool(checked.get("ok", false)):
		return false
	var current: Dictionary = checked["state"]
	if str(current.get("status", "")) != "open":
		return false
	if not (current.get("entry", {}) as Dictionary).is_empty():
		return true
	return _entry_conditions_met(
		player_route, investment_identity_ready, participants_ready, total_assets)


static func lock_entry(
		state: Dictionary, turn: int, player_route: String,
		investment_identity_ready: bool, participants_ready: bool,
		total_assets: float) -> Dictionary:
	# The product path is bound once, before W195 is shown. Later asset movement,
	# relationship callbacks, or save/reload cannot silently swap its economic
	# route or cast. An already-bound context is an exact idempotent replay.
	var checked := _canonical_state(state)
	if not bool(checked.get("ok", false)):
		return _failure(str(checked.get("error", "state_schema")), state)
	var current: Dictionary = checked["state"]
	if str(current.get("status", "")) != "open":
		return _failure("state_closed", current)
	var entry: Dictionary = current["entry"]
	if not entry.is_empty():
		return _success(current, true)
	if turn != ENTRY_TURN:
		return _failure("entry_turn_mismatch", current)
	if not _entry_conditions_met(
			player_route, investment_identity_ready, participants_ready,
			total_assets):
		return _failure("product_path_unavailable", current)
	var next_state := current.duplicate(true)
	next_state["entry"] = _canonical_entry()
	return _success(next_state, false)


static func entry_locked(state: Dictionary) -> bool:
	var checked := _canonical_state(state)
	if not bool(checked.get("ok", false)):
		return false
	var current: Dictionary = checked["state"]
	return str(current.get("status", "")) == "open" \
		and not (current.get("entry", {}) as Dictionary).is_empty()


static func entry_snapshot(state: Dictionary) -> Dictionary:
	if not entry_locked(state):
		return {}
	var checked := _canonical_state(state)
	return ((checked["state"] as Dictionary)["entry"] as Dictionary).duplicate(true)


static func _entry_conditions_met(
		player_route: String, investment_identity_ready: bool,
		participants_ready: bool, total_assets: float) -> bool:
	return player_route == ENTRY_PLAYER_ROUTE \
		and investment_identity_ready \
		and participants_ready \
		and is_finite(total_assets) \
		and total_assets >= ENTRY_MIN_TOTAL_ASSETS


static func _canonical_entry() -> Dictionary:
	return {
		"route_id": ENTRY_ROUTE_ID,
		"turn": ENTRY_TURN,
		"economic_route": ENTRY_ECONOMIC_ROUTE,
		"asset_band": ENTRY_ASSET_BAND,
		"actor_bindings": ENTRY_ACTOR_BINDINGS.duplicate(true),
	}


static func state_from_save(raw_state: Variant, was_present: bool) -> Dictionary:
	# There is no truthful migration source for an old save. It must not acquire
	# a contract, medical sheet, red review circle, or handwritten consent merely
	# because it later reaches the same calendar week.
	if not was_present:
		return _closed_state("legacy_missing")
	if not raw_state is Dictionary:
		return _closed_state("state_schema")
	# SaveManager persists JSON, whose parser materializes nested whole numbers as
	# floats. Normalize only the declared integer slots at this one disk boundary;
	# the canonical runtime state and every newly written receipt remain exact int.
	var normalized := _normalize_saved_exact_ints(raw_state as Dictionary)
	var checked := _canonical_state(normalized)
	if not bool(checked.get("ok", false)):
		return _closed_state(str(checked.get("error", "state_schema")))
	return (checked["state"] as Dictionary).duplicate(true)


static func is_owned_event(event_id: String) -> bool:
	# This safety boundary does not depend on the external ledger parsing. A
	# damaged ledger must fail closed instead of making its roots ordinary events.
	return event_id in OWNED_EVENT_IDS


static func next_event_for_turn(state: Dictionary, turn: int) -> String:
	var checked := _canonical_state(state)
	if not bool(checked.get("ok", false)):
		return ""
	var current: Dictionary = checked["state"]
	if str(current.get("status", "")) != "open":
		return ""
	var ledger := _ledger()
	if ledger.is_empty():
		return ""
	var root := _next_active_root(ledger, current["receipts"] as Dictionary)
	if root.is_empty() or int(root.get("turn", -1)) != turn:
		return ""
	return str(root.get("event_id", ""))


static func ingress_available(
		state: Dictionary, event_id: String, turn: int) -> bool:
	if not is_owned_event(event_id):
		return false
	return next_event_for_turn(state, turn) == event_id


static func choice_commit_available(
		state: Dictionary, event_id: String, choice_index: int, turn: int) -> bool:
	if not is_owned_event(event_id) or choice_index < 0:
		return false
	var checked := _canonical_state(state)
	if not bool(checked.get("ok", false)):
		return false
	var current: Dictionary = checked["state"]
	if str(current.get("status", "")) != "open":
		return false
	var ledger := _ledger()
	if ledger.is_empty():
		return false
	var root := _root_by_id(ledger, event_id)
	if root.is_empty() or int(root.get("turn", -1)) != turn:
		return false
	var choice := _choice_by_index(root, choice_index)
	if choice.is_empty():
		return false
	var receipts: Dictionary = current["receipts"]
	if receipts.has(event_id):
		return _same(
			receipts[event_id], _receipt_for_choice(root, choice_index))
	return str(_next_active_root(ledger, receipts).get("event_id", "")) \
		== event_id


static func commit_choice(
		state: Dictionary, event_id: String, choice_index: int, turn: int) -> Dictionary:
	var checked := _canonical_state(state)
	if not bool(checked.get("ok", false)):
		return _failure(str(checked.get("error", "state_schema")), state)
	var current: Dictionary = checked["state"]
	if str(current.get("status", "")) != "open":
		return _failure("state_closed", current)
	if (current.get("entry", {}) as Dictionary).is_empty():
		return _failure("entry_missing", current)
	if not is_owned_event(event_id):
		return _failure("event_unowned", current)
	var ledger := _ledger()
	if ledger.is_empty():
		return _failure("ledger_invalid", current)
	var root := _root_by_id(ledger, event_id)
	if root.is_empty() or int(root.get("turn", -1)) != turn:
		return _failure("turn_mismatch", current)
	var choice := _choice_by_index(root, choice_index)
	if choice.is_empty():
		return _failure("choice_invalid", current)
	var canonical_receipt := _receipt_for_choice(root, choice_index)
	var receipts: Dictionary = current["receipts"]
	if receipts.has(event_id):
		if _same(receipts[event_id], canonical_receipt):
			return _success(current, true)
		return _failure("callback_conflict", current)
	var expected := _next_active_root(ledger, receipts)
	if str(expected.get("event_id", "")) != event_id:
		return _failure("root_order", current)
	var next_state := current.duplicate(true)
	var next_receipts: Dictionary = next_state["receipts"]
	var next_order: Array = next_state["order"]
	next_receipts[event_id] = canonical_receipt
	next_order.append(event_id)
	next_state["receipts"] = next_receipts
	next_state["order"] = next_order
	return _success(next_state, false)


static func close_route(state: Dictionary, reason: String) -> Dictionary:
	# A live authored read failure must be terminal for this optional route. The
	# canonical closed state deliberately drops every receipt so a partial chain
	# cannot later be mistaken for complete evidence after content is repaired.
	if reason not in ROUTE_CLOSE_REASONS:
		return _failure("close_reason_invalid", state)
	var closed := _closed_state(reason)
	var checked := _canonical_state(state)
	if bool(checked.get("ok", false)) \
			and _same(checked.get("state", {}), closed):
		return _success(closed, true)
	# Closing must remain available even when ledger/state validation is what
	# exposed the malformed read surface; otherwise the caller can loop forever.
	return _success(closed, false)


static func receipt_matches(
		state: Dictionary, event_id: String, choice_index: int, turn: int) -> bool:
	if not is_owned_event(event_id):
		return false
	var checked := _canonical_state(state)
	if not bool(checked.get("ok", false)):
		return false
	var current: Dictionary = checked["state"]
	if str(current.get("status", "")) != "open":
		return false
	var ledger := _ledger()
	var root := _root_by_id(ledger, event_id)
	if root.is_empty() or int(root.get("turn", -1)) != turn:
		return false
	var choice := _choice_by_index(root, choice_index)
	if choice.is_empty():
		return false
	var receipts: Dictionary = current["receipts"]
	return receipts.has(event_id) and _same(
		receipts[event_id], _receipt_for_choice(root, choice_index))


static func selected_choice(state: Dictionary, event_id: String) -> int:
	var receipt := receipt_snapshot(state, event_id)
	return int(receipt.get("choice_index", -1)) if not receipt.is_empty() else -1


static func receipt_snapshot(state: Dictionary, event_id: String) -> Dictionary:
	if not is_owned_event(event_id):
		return {}
	var checked := _canonical_state(state)
	if not bool(checked.get("ok", false)):
		return {}
	var current: Dictionary = checked["state"]
	if str(current.get("status", "")) != "open":
		return {}
	var receipts: Dictionary = current["receipts"]
	var raw_receipt: Variant = receipts.get(event_id, {})
	return (raw_receipt as Dictionary).duplicate(true) \
		if raw_receipt is Dictionary else {}


static func choice_count_for_event(event_id: String) -> int:
	var root := _root_by_id(_ledger(), event_id)
	return (root.get("choices", []) as Array).size() \
		if root.get("choices", []) is Array else 0


static func event_sequence(event_id: String) -> int:
	var root := _root_by_id(_ledger(), event_id)
	return int(root.get("sequence", -1)) if not root.is_empty() else -1


static func expected_read_contract(event_id: String) -> Dictionary:
	var raw_contract: Variant = CAUSAL_READ_SOURCES.get(event_id, {})
	return (raw_contract as Dictionary).duplicate(true) \
		if raw_contract is Dictionary else {}


static func week_completed(state: Dictionary, turn: int) -> bool:
	var checked := _canonical_state(state)
	if not bool(checked.get("ok", false)):
		return false
	var current: Dictionary = checked["state"]
	if str(current.get("status", "")) != "open":
		return false
	var ledger := _ledger()
	if ledger.is_empty():
		return false
	var receipts: Dictionary = current["receipts"]
	var active_count := 0
	for raw_root in ledger["roots"] as Array:
		var root: Dictionary = raw_root
		if int(root.get("turn", -1)) != turn \
				or not _condition_is_active(root, receipts):
			continue
		active_count += 1
		if not receipts.has(str(root.get("event_id", ""))):
			return false
	return active_count > 0


static func route_complete(state: Dictionary) -> bool:
	## True only after every active M49-M55 root, including any conditional
	## W216/W220 paper receipt, has been durably committed.
	var checked := _canonical_state(state)
	if not bool(checked.get("ok", false)):
		return false
	var current: Dictionary = checked["state"]
	if str(current.get("status", "")) != "open" \
			or (current.get("entry", {}) as Dictionary).is_empty():
		return false
	var ledger := _ledger()
	return not ledger.is_empty() and _next_active_root(
		ledger, current["receipts"] as Dictionary).is_empty()


static func _closed_state(reason: String) -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"ledger_id": LEDGER_ID,
		"status": "closed",
		"closed_reason": reason if not reason.is_empty() else "state_schema",
		"entry": {},
		"receipts": {},
		"order": [],
	}


static func _normalize_saved_exact_ints(state: Dictionary) -> Dictionary:
	var normalized := state.duplicate(true)
	if _is_json_int(normalized.get("schema_version")):
		normalized["schema_version"] = int(normalized["schema_version"])
	var raw_entry: Variant = normalized.get("entry")
	if raw_entry is Dictionary:
		var entry: Dictionary = (raw_entry as Dictionary).duplicate(true)
		if _is_json_int(entry.get("turn")):
			entry["turn"] = int(entry["turn"])
		normalized["entry"] = entry
	var raw_receipts: Variant = normalized.get("receipts")
	if not raw_receipts is Dictionary:
		return normalized
	var receipts: Dictionary = (raw_receipts as Dictionary).duplicate(true)
	for raw_event_id in receipts:
		var raw_receipt: Variant = receipts[raw_event_id]
		if not raw_receipt is Dictionary:
			continue
		var receipt: Dictionary = (raw_receipt as Dictionary).duplicate(true)
		for field in ["sequence", "turn", "choice_index"]:
			if _is_json_int(receipt.get(field)):
				receipt[field] = int(receipt[field])
		receipts[raw_event_id] = receipt
	normalized["receipts"] = receipts
	return normalized


static func _success(state: Dictionary, idempotent: bool) -> Dictionary:
	return {
		"ok": true,
		"state": state.duplicate(true),
		"idempotent": idempotent,
		"error": "",
	}


static func _failure(error: String, state: Dictionary) -> Dictionary:
	return {
		"ok": false,
		"state": state.duplicate(true),
		"idempotent": false,
		"error": error,
	}


static func _canonical_state(state: Dictionary) -> Dictionary:
	var ledger := _ledger()
	if ledger.is_empty():
		return {"ok": false, "error": "ledger_invalid"}
	if not _has_exact_keys(state, STATE_KEYS):
		return {"ok": false, "error": "state_schema"}
	if not _is_exact_int(state.get("schema_version")) \
			or int(state["schema_version"]) != SCHEMA_VERSION \
			or str(state.get("ledger_id", "")) != LEDGER_ID \
			or not state.get("closed_reason") is String \
			or not state.get("entry") is Dictionary \
			or not state.get("receipts") is Dictionary \
			or not state.get("order") is Array:
		return {"ok": false, "error": "state_schema"}
	var status := str(state.get("status", ""))
	var entry: Dictionary = state["entry"]
	var receipts: Dictionary = state["receipts"]
	var order: Array = state["order"]
	if status == "closed":
		if str(state.get("closed_reason", "")).is_empty() \
				or not entry.is_empty() or not receipts.is_empty() \
				or not order.is_empty():
			return {"ok": false, "error": "state_schema"}
		return {"ok": true, "state": state.duplicate(true)}
	if status != "open" or not str(state.get("closed_reason", "")).is_empty() \
			or receipts.size() != order.size() \
			or order.size() > EXPECTED_ROOT_COUNT:
		return {"ok": false, "error": "state_schema"}
	if entry.is_empty():
		if not receipts.is_empty() or not order.is_empty():
			return {"ok": false, "error": "entry_missing"}
	elif not _has_exact_keys(entry, ENTRY_KEYS) \
			or not _is_exact_int(entry.get("turn")) \
			or not entry.get("actor_bindings") is Dictionary \
			or not _same(entry, _canonical_entry()):
		return {"ok": false, "error": "entry_tampered"}
	var replayed: Dictionary = {}
	var identities: Dictionary = {}
	for raw_event_id in order:
		if not raw_event_id is String:
			return {"ok": false, "error": "order_tampered"}
		var event_id := str(raw_event_id)
		if event_id.is_empty() or identities.has(event_id) \
				or not receipts.has(event_id):
			return {"ok": false, "error": "order_tampered"}
		var expected := _next_active_root(ledger, replayed)
		if str(expected.get("event_id", "")) != event_id:
			return {"ok": false, "error": "order_tampered"}
		var raw_receipt: Variant = receipts[event_id]
		if not raw_receipt is Dictionary \
				or not _valid_receipt(raw_receipt as Dictionary, expected):
			return {"ok": false, "error": "receipt_tampered"}
		identities[event_id] = true
		replayed[event_id] = (raw_receipt as Dictionary).duplicate(true)
	for raw_key in receipts:
		if not raw_key is String or not identities.has(str(raw_key)):
			return {"ok": false, "error": "receipt_tampered"}
	return {"ok": true, "state": state.duplicate(true)}


static func _valid_receipt(receipt: Dictionary, root: Dictionary) -> bool:
	if not _has_exact_keys(receipt, RECEIPT_KEYS) \
			or not _is_exact_int(receipt.get("sequence")) \
			or not _is_exact_int(receipt.get("turn")) \
			or not _is_exact_int(receipt.get("choice_index")) \
			or not receipt.get("actor_bindings") is Dictionary \
			or not receipt.get("receipts") is Array:
		return false
	var choice_index: int = receipt["choice_index"]
	if int(receipt["sequence"]) != int(root.get("sequence", -1)) \
			or str(receipt.get("event_id", "")) != str(root.get("event_id", "")) \
			or int(receipt["turn"]) != int(root.get("turn", -1)) \
			or _choice_by_index(root, choice_index).is_empty():
		return false
	return _same(receipt, _receipt_for_choice(root, choice_index))


static func _receipt_for_choice(root: Dictionary, choice_index: int) -> Dictionary:
	var choice := _choice_by_index(root, choice_index)
	if choice.is_empty():
		return {}
	return {
		"sequence": int(root.get("sequence", -1)),
		"event_id": str(root.get("event_id", "")),
		"turn": int(root.get("turn", -1)),
		"choice_index": choice_index,
		"actor_bindings": (root["actor_bindings"] as Dictionary).duplicate(true),
		"receipts": (choice["receipts"] as Array).duplicate(true),
	}


static func _next_active_root(
		ledger: Dictionary, receipts: Dictionary) -> Dictionary:
	for raw_root in ledger.get("roots", []) as Array:
		var root: Dictionary = raw_root
		var event_id := str(root.get("event_id", ""))
		if receipts.has(event_id):
			continue
		if not _condition_is_active(root, receipts):
			continue
		return root
	return {}


static func _condition_is_active(root: Dictionary, receipts: Dictionary) -> bool:
	var condition: Variant = root.get("condition")
	if condition == null:
		return true
	if not condition is Dictionary:
		return false
	var source_id := str((condition as Dictionary).get("event_id", ""))
	if not receipts.has(source_id) or not receipts[source_id] is Dictionary:
		# The normal prefix scan reaches the missing producer first. A direct
		# query must not manufacture the conditional evidence in its absence.
		return false
	return int((receipts[source_id] as Dictionary).get("choice_index", -1)) \
		== int((condition as Dictionary).get("choice_index", -2))


static func _choice_by_index(root: Dictionary, choice_index: int) -> Dictionary:
	var raw_choices: Variant = root.get("choices", [])
	if not raw_choices is Array or choice_index < 0 \
			or choice_index >= (raw_choices as Array).size():
		return {}
	var raw_choice: Variant = (raw_choices as Array)[choice_index]
	if not raw_choice is Dictionary \
			or int((raw_choice as Dictionary).get("index", -1)) != choice_index:
		return {}
	return raw_choice as Dictionary


static func _root_by_id(ledger: Dictionary, event_id: String) -> Dictionary:
	for raw_root in ledger.get("roots", []) as Array:
		if raw_root is Dictionary \
				and str((raw_root as Dictionary).get("event_id", "")) == event_id:
			return raw_root as Dictionary
	return {}


static func _ledger() -> Dictionary:
	if _ledger_checked:
		return _ledger_cache
	_ledger_checked = true
	_ledger_cache = {}
	if not FileAccess.file_exists(LEDGER_PATH):
		return _ledger_cache
	var parsed: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(LEDGER_PATH))
	if not parsed is Dictionary or not _valid_ledger(parsed as Dictionary):
		return _ledger_cache
	_ledger_cache = (parsed as Dictionary).duplicate(true)
	return _ledger_cache


static func _valid_ledger(ledger: Dictionary) -> bool:
	if not _has_exact_keys(ledger, [
			"schema_version", "ledger_id", "choice_index_base",
			"expected_root_count", "expected_choice_count", "entry_contract",
			"roots",
		]) \
			or not _is_json_int(ledger.get("schema_version")) \
			or int(ledger["schema_version"]) != SCHEMA_VERSION \
			or str(ledger.get("ledger_id", "")) != LEDGER_ID \
			or not _is_json_int(ledger.get("choice_index_base")) \
			or int(ledger["choice_index_base"]) != 0 \
			or not _is_json_int(ledger.get("expected_root_count")) \
			or int(ledger["expected_root_count"]) != EXPECTED_ROOT_COUNT \
			or not _is_json_int(ledger.get("expected_choice_count")) \
			or int(ledger["expected_choice_count"]) != EXPECTED_CHOICE_COUNT \
			or not ledger.get("entry_contract") is Dictionary \
			or not _same(_normalized_ledger_entry(
				ledger["entry_contract"] as Dictionary), _canonical_entry()) \
			or not ledger.get("roots") is Array:
		return false
	var roots: Array = ledger["roots"]
	if roots.size() != EXPECTED_ROOT_COUNT:
		return false
	var choice_count := 0
	var seen_receipt_ids: Dictionary = {}
	for index in range(roots.size()):
		var raw_root: Variant = roots[index]
		if not raw_root is Dictionary:
			return false
		var root: Dictionary = raw_root
		if not _has_exact_keys(root, [
				"sequence", "month", "turn", "week", "event_id", "root_id",
				"choice_count", "tier", "actor_bindings", "condition",
				"requires_choice", "choices",
			]) \
				or not _is_json_int(root.get("sequence")) \
				or int(root["sequence"]) != index + 1 \
				or not _is_json_int(root.get("month")) \
				or not _is_json_int(root.get("turn")) \
				or int(root["turn"]) != OWNED_TURNS[index] \
				or not _is_json_int(root.get("week")) \
				or int(root["week"]) != int(root["turn"]) \
				or int(root["month"]) != floori((int(root["turn"]) - 1) / 4.0) + 1 \
				or str(root.get("event_id", "")) != OWNED_EVENT_IDS[index] \
				or str(root.get("root_id", "")) != str(root["event_id"]) \
				or not _is_json_int(root.get("choice_count")) \
				or str(root.get("tier", "")) != "T2" \
				or not _valid_actor_bindings(root.get("actor_bindings")) \
				or not root.get("choices") is Array:
			return false
		var choices: Array = root["choices"]
		if choices.is_empty() or int(root["choice_count"]) != choices.size():
			return false
		for choice_index in range(choices.size()):
			var raw_choice: Variant = choices[choice_index]
			if not raw_choice is Dictionary:
				return false
			var choice: Dictionary = raw_choice
			if not _has_exact_keys(choice, ["index", "receipts"]) \
					or not _is_json_int(choice.get("index")) \
					or int(choice["index"]) != choice_index \
					or not choice.get("receipts") is Array \
					or (choice["receipts"] as Array).is_empty():
				return false
			for raw_receipt in choice["receipts"] as Array:
				if not _valid_evidence_receipt(raw_receipt, seen_receipt_ids):
					return false
		choice_count += choices.size()
		var condition: Variant = root.get("condition")
		if not _same(condition, root.get("requires_choice")):
			return false
		if condition != null:
			if not condition is Dictionary \
					or not _has_exact_keys(condition as Dictionary, [
						"event_id", "choice_index",
				]) \
					or not _is_json_int((condition as Dictionary).get(
						"choice_index")):
				return false
			var source_id := str((condition as Dictionary).get("event_id", ""))
			var source_root := _root_by_id(ledger, source_id)
			if source_root.is_empty() \
					or int(source_root.get("sequence", 999)) >= index + 1 \
					or _choice_by_index(source_root, int(
						(condition as Dictionary)["choice_index"])).is_empty():
				return false
		var should_have_condition := index in [15, 18]
		if should_have_condition != (condition != null):
			return false
	if choice_count != EXPECTED_CHOICE_COUNT:
		return false
	var review_condition: Dictionary = roots[15]["condition"]
	var consent_condition: Dictionary = roots[18]["condition"]
	return str(review_condition.get("event_id", "")) \
			== "arc_sangchul_final_door" \
		and int(review_condition.get("choice_index", -1)) == 0 \
		and str(consent_condition.get("event_id", "")) \
			== "arc_y5_three_in_room_decision" \
		and int(consent_condition.get("choice_index", -1)) == 1


static func _normalized_ledger_entry(raw_entry: Dictionary) -> Dictionary:
	var entry := raw_entry.duplicate(true)
	if _is_json_int(entry.get("turn")):
		entry["turn"] = int(entry["turn"])
	return entry


static func _valid_actor_bindings(raw_bindings: Variant) -> bool:
	if not raw_bindings is Dictionary or (raw_bindings as Dictionary).is_empty():
		return false
	for raw_role in raw_bindings as Dictionary:
		if not raw_role is String or str(raw_role).is_empty() \
				or not (raw_bindings as Dictionary)[raw_role] is String \
				or str((raw_bindings as Dictionary)[raw_role]).is_empty():
			return false
	return true


static func _valid_evidence_receipt(
		raw_receipt: Variant, seen_receipt_ids: Dictionary) -> bool:
	if not raw_receipt is Dictionary:
		return false
	var receipt: Dictionary = raw_receipt
	if not _has_exact_keys(receipt, [
			"receipt_type", "receipt_id", "document_ids",
		]) \
			or not receipt.get("receipt_type") is String \
			or str(receipt.get("receipt_type", "")).is_empty() \
			or not receipt.get("receipt_id") is String \
			or str(receipt.get("receipt_id", "")).is_empty() \
			or seen_receipt_ids.has(str(receipt.get("receipt_id", ""))) \
			or not receipt.get("document_ids") is Array \
			or (receipt["document_ids"] as Array).is_empty():
		return false
	for raw_document_id in receipt["document_ids"] as Array:
		if not raw_document_id is String or str(raw_document_id).is_empty():
			return false
	seen_receipt_ids[str(receipt["receipt_id"])] = true
	return true


static func _has_exact_keys(data: Dictionary, expected: Array[String]) -> bool:
	if data.size() != expected.size():
		return false
	for key in expected:
		if not data.has(key):
			return false
	return true


static func _is_exact_int(value: Variant) -> bool:
	return typeof(value) == TYPE_INT


static func _is_json_int(value: Variant) -> bool:
	# Godot's JSON parser materializes numeric tokens as floats. Ledger numbers
	# are immutable contract literals, so accept only finite integral values at
	# this boundary and cast them into exact ints when producing save receipts.
	return typeof(value) == TYPE_INT or (
		typeof(value) == TYPE_FLOAT
		and is_finite(float(value))
		and float(value) == floor(float(value)))


static func _same(left: Variant, right: Variant) -> bool:
	return JSON.stringify(left, "", true) == JSON.stringify(right, "", true)
