extends RefCounted
class_name Chapter5FinaleRoute

## Locale-neutral, save-safe reducer for authored Chapter 5 finales.
## The reducer records authored paper/person choices only. It never applies
## money, asset, debt, stat, flag, or ending effects itself.

const SCHEMA_VERSION := 1
const LEDGER_PATH := "res://content/meta/chapter5_finale_ledger.json"
const LEDGER_ID := "chapter5_m56_m60_safe_finale_v1"
const ROUTE_ID := "chapter5_safe_finale"
const PROFILE_ID := "investment_safe_no_execution"
const SOURCE_ROUTE_ID := "investment_property"
const ENTRY_TURN := 221
const LEGACY_FRESH_THROUGH_TURN := 220
const EXPECTED_ROOT_COUNT := 11
const EXPECTED_ACTIVE_ROOT_COUNT := 9
const EXPECTED_CHOICE_COUNT := 30
const EXPECTED_ACTIVE_CHOICE_COUNT := 24

const GENERAL_LEDGER_PATH := \
	"res://content/meta/chapter5_general_finale_ledger.json"
const GENERAL_LEDGER_ID := "chapter5_general_near_goal_passed_finale_v2"
const GENERAL_PROFILE_ID := "general_near_goal_father_passed"
const GENERAL_SOURCE_ROUTE_ID := "general_story"
const GENERAL_ENTRY_TURN := 224
const GENERAL_EXPECTED_ROOT_COUNT := 8
const GENERAL_EXPECTED_ACTIVE_ROOT_COUNT := 6
const GENERAL_EXPECTED_CHOICE_COUNT := 17
const GENERAL_EXPECTED_ACTIVE_CHOICE_COUNT := 13

const STAGES: Array[String] = [
	"father_trace",
	"custody",
	"filing",
	"verdict",
	"nontransaction",
	"guarantee_return",
	"father_answer",
	"signature",
	"outbound",
]
const OWNED_EVENT_IDS: Array[String] = [
	"arc_y5_father_trace_alive_exact",
	"arc_y5_father_trace_passed_exact",
	"arc_y5_father_trace_custody",
	"arc_y5_name_on_line_daeun_routed",
	"arc_y5_people_verdict_daeun_exact",
	"arc_y5_property_not_executed_notice",
	"arc_y5_remaining_jaehyuk_or_self",
	"arc_y5_final_father_answer_alive",
	"arc_y5_final_father_answer_passed",
	"arc_final_countdown_property_not_executed",
	"arc_y5_final_week_daeun_outbound",
]
const OWNED_TURNS: Array[int] = [
	221, 221, 224, 227, 230, 235, 238, 239, 239, 240, 240,
]
const ROOT_CHOICE_COUNTS: Array[int] = [3, 3, 2, 4, 3, 1, 2, 3, 3, 3, 3]
const SOURCE_CHOICE_KEYS: Array[String] = [
	"m55_decision", "w212_guarantee", "w215_final_door",
]
const FATHER_KEYS: Array[String] = ["life", "contact_mode"]
const FATHER_LIFE_VALUES: Array[String] = ["alive", "passed"]
const FATHER_CONTACT_VALUES: Array[String] = [
	"present", "called", "missed", "records_only",
]
const ACTORS := {
	"chooser": "player",
	"father": "father",
	"protected_person": "daeun",
	"guarantee_party": "jaehyuk",
	"reviewer": "sangchul",
	"proposer": "sangchul",
	"cost_witness": "minseo",
}
const ROOT_ACTORS := {
	"arc_y5_father_trace_alive_exact": {
		"chooser": "player", "father": "father",
	},
	"arc_y5_father_trace_passed_exact": {
		"chooser": "player", "father": "father",
	},
	"arc_y5_father_trace_custody": {
		"chooser": "player", "protected_person": "daeun",
	},
	"arc_y5_name_on_line_daeun_routed": {
		"chooser": "player", "protected_person": "daeun",
	},
	"arc_y5_people_verdict_daeun_exact": {
		"chooser": "player", "protected_person": "daeun",
		"cost_witness": "minseo",
	},
	"arc_y5_property_not_executed_notice": {"chooser": "player"},
	"arc_y5_remaining_jaehyuk_or_self": {
		"chooser": "player", "guarantee_party": "jaehyuk",
	},
	"arc_y5_final_father_answer_alive": {
		"chooser": "player", "father": "father",
	},
	"arc_y5_final_father_answer_passed": {
		"chooser": "player", "father": "father",
	},
	"arc_final_countdown_property_not_executed": {"chooser": "player"},
	"arc_y5_final_week_daeun_outbound": {
		"chooser": "player", "protected_person": "daeun",
	},
}
const READ_SOURCES := {
	"arc_y5_father_trace_alive_exact": [
		{"kind": "causal_event", "id": "arc_y5_three_in_room_decision"},
		{"kind": "entry_value", "path": "father.contact_mode", "values": [
			"present", "called", "missed", "records_only",
		]},
	],
	"arc_y5_father_trace_passed_exact": [
		{"kind": "causal_event", "id": "arc_y5_three_in_room_decision"},
		{"kind": "entry_value", "path": "father.contact_mode", "values": [
			"present", "called", "missed", "records_only",
		]},
	],
	"arc_y5_father_trace_custody": [
		{"kind": "finale_stage", "id": "father_trace"},
	],
	"arc_y5_name_on_line_daeun_routed": [
		{"kind": "causal_event", "id": "arc_y5_three_in_room_decision"},
		{"kind": "finale_stage", "id": "custody"},
	],
	"arc_y5_people_verdict_daeun_exact": [
		{"kind": "finale_stage", "id": "custody"},
		{"kind": "finale_stage", "id": "filing"},
	],
	"arc_y5_property_not_executed_notice": [
		{"kind": "finale_stage", "id": "filing"},
		{"kind": "finale_stage", "id": "verdict"},
	],
	"arc_y5_remaining_jaehyuk_or_self": [
		{
			"kind": "causal_event",
			"id": "arc_y5_jaehyuk_guarantee_decision_reference",
		},
		{"kind": "finale_stage", "id": "nontransaction"},
	],
	"arc_y5_final_father_answer_alive": [
		{"kind": "finale_stage", "id": "father_trace"},
		{"kind": "finale_stage", "id": "nontransaction"},
	],
	"arc_y5_final_father_answer_passed": [
		{"kind": "finale_stage", "id": "father_trace"},
		{"kind": "finale_stage", "id": "nontransaction"},
	],
	"arc_final_countdown_property_not_executed": [
		{"kind": "finale_stage", "id": "filing"},
		{"kind": "finale_stage", "id": "verdict"},
		{"kind": "finale_stage", "id": "nontransaction"},
		{"kind": "finale_stage", "id": "father_answer"},
	],
	"arc_y5_final_week_daeun_outbound": [
		{"kind": "finale_stage", "id": "custody"},
		{"kind": "finale_stage", "id": "signature"},
	],
}
const GENERAL_STAGES: Array[String] = [
	"father_legacy",
	"debt_memory_consequence",
	"summit",
	"record_disposition",
	"sacrifice",
	"outbound",
]
const GENERAL_OWNED_EVENT_IDS: Array[String] = [
	"arc_y5_general_father_legacy_voice_exact",
	"arc_y5_general_father_legacy_cafe_exact",
	"arc_y5_general_debt_memory_voice_exact",
	"arc_y5_general_debt_memory_cafe_exact",
	"arc_y5_general_pre_ending_summit_exact",
	"arc_y5_general_final_record_seal",
	"arc_final_countdown_general_near_goal_passed",
	"arc_y5_final_week_general_people_outbound",
]
const GENERAL_OWNED_TURNS: Array[int] = [224, 224, 229, 229, 234, 237, 240, 240]
const GENERAL_ROOT_CHOICE_COUNTS: Array[int] = [2, 2, 2, 2, 2, 2, 2, 3]
const GENERAL_SOURCE_CHOICE_KEYS: Array[String] = [
	"m51_minseo_arrival",
	"w211_name_boundary",
	"w220_debt_memory_reconnect",
]
const GENERAL_ACTORS := {
	"chooser": "player",
	"father": "father",
	"cost_witness": "minseo",
}
const GENERAL_ROOT_ACTORS := {
	"arc_y5_general_father_legacy_voice_exact": {
		"chooser": "player", "father": "father",
	},
	"arc_y5_general_father_legacy_cafe_exact": {
		"chooser": "player", "father": "father",
	},
	"arc_y5_general_debt_memory_voice_exact": {"chooser": "player"},
	"arc_y5_general_debt_memory_cafe_exact": {"chooser": "player"},
	"arc_y5_general_pre_ending_summit_exact": {
		"chooser": "player", "father": "father",
	},
	"arc_y5_general_final_record_seal": {
		"chooser": "player", "father": "father", "cost_witness": "minseo",
	},
	"arc_final_countdown_general_near_goal_passed": {
		"chooser": "player", "father": "father",
	},
	"arc_y5_final_week_general_people_outbound": {
		"chooser": "player", "father": "father", "cost_witness": "minseo",
	},
}
const GENERAL_READ_SOURCES := {
	"arc_y5_general_father_legacy_voice_exact": [
		{
			"kind": "entry_value",
			"path": "source_choices.w220_debt_memory_reconnect",
			"values": [0.0, 1.0],
		},
	],
	"arc_y5_general_father_legacy_cafe_exact": [
		{
			"kind": "entry_value",
			"path": "source_choices.w220_debt_memory_reconnect",
			"values": [0.0, 1.0],
		},
	],
	"arc_y5_general_debt_memory_voice_exact": [
		{"kind": "finale_stage", "id": "father_legacy"},
	],
	"arc_y5_general_debt_memory_cafe_exact": [
		{"kind": "finale_stage", "id": "father_legacy"},
	],
	"arc_y5_general_pre_ending_summit_exact": [
		{"kind": "finale_stage", "id": "debt_memory_consequence"},
	],
	"arc_y5_general_final_record_seal": [
		{"kind": "finale_stage", "id": "father_legacy"},
		{"kind": "finale_stage", "id": "debt_memory_consequence"},
		{"kind": "finale_stage", "id": "summit"},
	],
	"arc_final_countdown_general_near_goal_passed": [
		{"kind": "finale_stage", "id": "record_disposition"},
	],
	"arc_y5_final_week_general_people_outbound": [
		{"kind": "finale_stage", "id": "sacrifice"},
		{
			"kind": "entry_value",
			"path": "source_choices.m51_minseo_arrival",
			"values": [0.0, 1.0],
		},
		{"kind": "finale_stage", "id": "father_legacy"},
	],
}
const GENERAL_BRANCH_VARIANTS := {
	"arc_y5_general_father_legacy_voice_exact": 0,
	"arc_y5_general_father_legacy_cafe_exact": 1,
	"arc_y5_general_debt_memory_voice_exact": 0,
	"arc_y5_general_debt_memory_cafe_exact": 1,
}
const INLINE_SLOT_READ_EVENT_IDS: Array[String] = [
	"arc_final_countdown_property_not_executed",
	"arc_y5_general_father_legacy_voice_exact",
	"arc_y5_general_father_legacy_cafe_exact",
	"arc_y5_general_debt_memory_voice_exact",
	"arc_y5_general_debt_memory_cafe_exact",
	"arc_y5_general_pre_ending_summit_exact",
	"arc_y5_general_final_record_seal",
]
const NO_EXECUTABLE_CONTRACT_OUTCOME := {
	"kind": "none",
	"reason": "no_executable_contract",
	"cash_delta_krw": 0,
	"asset_delta_krw": 0,
	"debt_delta_krw": 0,
}
const CLOSE_REASON_READ_SURFACE_INVALID := "read_surface_invalid"
const STATE_KEYS: Array[String] = [
	"schema_version", "ledger_id", "status", "closed_reason", "entry",
	"receipts", "order", "ending_check",
]
const ENTRY_KEYS: Array[String] = [
	"route_id", "turn", "profile_id", "source_route_id", "source_choices",
	"father", "actor_bindings",
]
const RECEIPT_KEYS: Array[String] = [
	"stage", "event_id", "turn", "choice_index", "actors",
	"receipt_ids", "document_ids", "economic_outcome",
]
const CLOSE_REASONS: Array[String] = [
	CLOSE_REASON_READ_SURFACE_INVALID,
	"source_route_invalid",
	"entry_context_invalid",
]

static var _ledger_cache: Dictionary = {}
static var _ledger_checked := false
static var _general_ledger_cache: Dictionary = {}
static var _general_ledger_checked := false


static func default_state() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"ledger_id": LEDGER_ID,
		"status": "open",
		"closed_reason": "",
		"entry": {},
		"receipts": {},
		"order": [],
		"ending_check": "pending",
	}


static func ledger_id_for_profile(profile_id: String) -> String:
	if profile_id == PROFILE_ID:
		return LEDGER_ID
	if profile_id == GENERAL_PROFILE_ID:
		return GENERAL_LEDGER_ID
	return ""


static func ledger_path_for_profile(profile_id: String) -> String:
	if profile_id == PROFILE_ID:
		return LEDGER_PATH
	if profile_id == GENERAL_PROFILE_ID:
		return GENERAL_LEDGER_PATH
	return ""


static func profile_for_ledger_id(ledger_id: String) -> String:
	if ledger_id == LEDGER_ID:
		return PROFILE_ID
	if ledger_id == GENERAL_LEDGER_ID:
		return GENERAL_PROFILE_ID
	return ""


static func profile_for_event(event_id: String) -> String:
	if event_id in OWNED_EVENT_IDS:
		return PROFILE_ID
	if event_id in GENERAL_OWNED_EVENT_IDS:
		return GENERAL_PROFILE_ID
	return ""


static func stages_for_profile(profile_id: String) -> Array[String]:
	if profile_id == PROFILE_ID:
		return STAGES.duplicate()
	if profile_id == GENERAL_PROFILE_ID:
		return GENERAL_STAGES.duplicate()
	return []


static func owned_event_ids_for_profile(profile_id: String) -> Array[String]:
	if profile_id == PROFILE_ID:
		return OWNED_EVENT_IDS.duplicate()
	if profile_id == GENERAL_PROFILE_ID:
		return GENERAL_OWNED_EVENT_IDS.duplicate()
	return []


static func entry_turn_for_profile(profile_id: String) -> int:
	if profile_id == PROFILE_ID:
		return ENTRY_TURN
	if profile_id == GENERAL_PROFILE_ID:
		return GENERAL_ENTRY_TURN
	return -1


static func is_entry_turn(turn: int, profile_id: String = "") -> bool:
	if profile_id.is_empty():
		return turn == ENTRY_TURN or turn == GENERAL_ENTRY_TURN
	return turn == entry_turn_for_profile(profile_id)


static func state_from_save(
		raw_state: Variant, was_present: bool, current_turn: int) -> Dictionary:
	# A save made before W221 has not missed any authored finale fact, so it may
	# enter normally. Once W221 has passed, inventing the entry and its actors from
	# a legacy save would fabricate the whole final paper trail.
	if not was_present:
		return default_state() if current_turn <= LEGACY_FRESH_THROUGH_TURN \
			else _closed_state("legacy_missing")
	if not raw_state is Dictionary:
		return _closed_state("state_schema")
	var normalized := _normalize_saved_exact_ints(raw_state as Dictionary)
	var checked := _canonical_state(normalized)
	if not bool(checked.get("ok", false)):
		return _closed_state(str(checked.get("error", "state_schema")))
	return (checked["state"] as Dictionary).duplicate(true)


static func lock_entry(
		state: Dictionary, turn: int, route_id: String, profile_id: String,
		source_choices: Dictionary, father: Dictionary,
		actors: Dictionary) -> Dictionary:
	var checked := _canonical_state(state)
	if not bool(checked.get("ok", false)):
		return _failure(str(checked.get("error", "state_schema")), state)
	var current: Dictionary = checked["state"]
	if str(current.get("status", "")) != "open":
		return _failure("state_closed", current)
	var candidate := _canonical_entry(
		route_id, profile_id, source_choices, father, actors)
	if candidate.is_empty():
		return _failure("entry_context_invalid", current)
	var existing: Dictionary = current["entry"]
	if not existing.is_empty():
		if _same(existing, candidate):
			return _success(current, true)
		return _failure("entry_conflict", current)
	if not is_entry_turn(turn, profile_id):
		return _failure("entry_turn_mismatch", current)
	var next_state := current.duplicate(true)
	next_state["ledger_id"] = ledger_id_for_profile(profile_id)
	next_state["entry"] = candidate
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


static func is_owned_event(event_id: String) -> bool:
	# Keep ownership closed even if the external ledger cannot be parsed.
	return not profile_for_event(event_id).is_empty()


static func expected_read_contract(event_id: String) -> Dictionary:
	var profile_id := profile_for_event(event_id)
	var ledger := _ledger_for_profile(profile_id)
	if profile_id.is_empty() or ledger.is_empty():
		return {}
	var root := _root_by_id(ledger, event_id)
	if root.is_empty():
		return {}
	return {
		"sources": (root["read_sources"] as Array).duplicate(true),
		"mode": str(root.get("read_mode", "")),
	}


static func next_event_for_turn(state: Dictionary, turn: int) -> String:
	var checked := _canonical_state(state)
	if not bool(checked.get("ok", false)):
		return ""
	var current: Dictionary = checked["state"]
	if str(current.get("status", "")) != "open" \
			or (current.get("entry", {}) as Dictionary).is_empty() \
			or str(current.get("ending_check", "")) == "consumed":
		return ""
	var root := _next_active_root(
		_ledger_for_state(current), current["entry"] as Dictionary,
		current["receipts"] as Dictionary)
	if root.is_empty() or int(root.get("turn", -1)) != turn:
		return ""
	return str(root.get("event_id", ""))


static func ingress_available(
		state: Dictionary, event_id: String, turn: int) -> bool:
	return is_owned_event(event_id) \
		and next_event_for_turn(state, turn) == event_id


static func choice_commit_available(
		state: Dictionary, event_id: String, choice_index: int,
		turn: int) -> bool:
	if not is_owned_event(event_id) or choice_index < 0:
		return false
	var checked := _canonical_state(state)
	if not bool(checked.get("ok", false)):
		return false
	var current: Dictionary = checked["state"]
	if str(current.get("status", "")) != "open" \
			or (current.get("entry", {}) as Dictionary).is_empty():
		return false
	var ledger := _ledger_for_state(current)
	var root := _root_by_id(ledger, event_id)
	if root.is_empty() or int(root.get("turn", -1)) != turn \
			or not _root_active_for_entry(root, current["entry"] as Dictionary):
		return false
	var choice := _choice_by_index(root, choice_index)
	if choice.is_empty():
		return false
	var expected_receipt := _receipt_for_choice(root, choice_index)
	var receipts: Dictionary = current["receipts"]
	if receipts.has(event_id):
		return _same(receipts[event_id], expected_receipt)
	if str(current.get("ending_check", "")) == "consumed":
		return false
	return str(_next_active_root(
		ledger, current["entry"] as Dictionary, receipts
	).get("event_id", "")) == event_id


static func commit_choice(
		state: Dictionary, event_id: String, choice_index: int,
		turn: int) -> Dictionary:
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
	var ledger := _ledger_for_state(current)
	var root := _root_by_id(ledger, event_id)
	if root.is_empty() or int(root.get("turn", -1)) != turn:
		return _failure("turn_mismatch", current)
	if not _root_active_for_entry(root, current["entry"] as Dictionary):
		return _failure("root_variant_inactive", current)
	var choice := _choice_by_index(root, choice_index)
	if choice.is_empty():
		return _failure("choice_invalid", current)
	var receipt := _receipt_for_choice(root, choice_index)
	var receipts: Dictionary = current["receipts"]
	if receipts.has(event_id):
		if _same(receipts[event_id], receipt):
			return _success(current, true)
		return _failure("callback_conflict", current)
	if str(current.get("ending_check", "")) == "consumed":
		return _failure("ending_consumed", current)
	var expected := _next_active_root(
		ledger, current["entry"] as Dictionary, receipts)
	if str(expected.get("event_id", "")) != event_id:
		return _failure("root_order", current)
	var next_state := current.duplicate(true)
	var next_receipts: Dictionary = next_state["receipts"]
	var next_order: Array = next_state["order"]
	next_receipts[event_id] = receipt
	next_order.append(event_id)
	next_state["receipts"] = next_receipts
	next_state["order"] = next_order
	if str(root.get("stage", "")) == "outbound":
		next_state["ending_check"] = "ready"
	return _success(next_state, false)


static func receipt_matches(
		state: Dictionary, event_id: String, choice_index: int,
		turn: int) -> bool:
	if not is_owned_event(event_id):
		return false
	var checked := _canonical_state(state)
	if not bool(checked.get("ok", false)):
		return false
	var current: Dictionary = checked["state"]
	var root := _root_by_id(_ledger_for_state(current), event_id)
	if root.is_empty() or int(root.get("turn", -1)) != turn \
			or not _root_active_for_entry(root, current["entry"] as Dictionary) \
			or _choice_by_index(root, choice_index).is_empty():
		return false
	var receipts: Dictionary = current["receipts"]
	return receipts.has(event_id) \
		and _same(receipts[event_id], _receipt_for_choice(root, choice_index))


static func receipt_snapshot_by_event(
		state: Dictionary, event_id: String) -> Dictionary:
	return receipt_snapshot_for_event(state, event_id)


static func receipt_snapshot_for_event(
		state: Dictionary, event_id: String) -> Dictionary:
	if not is_owned_event(event_id):
		return {}
	var checked := _canonical_state(state)
	if not bool(checked.get("ok", false)):
		return {}
	var current: Dictionary = checked["state"]
	var raw: Variant = (current["receipts"] as Dictionary).get(event_id, {})
	return (raw as Dictionary).duplicate(true) if raw is Dictionary else {}


static func receipt_snapshot_by_stage(
		state: Dictionary, stage: String) -> Dictionary:
	return receipt_snapshot_for_stage(state, stage)


static func receipt_snapshot_for_stage(
		state: Dictionary, stage: String) -> Dictionary:
	var checked := _canonical_state(state)
	if not bool(checked.get("ok", false)):
		return {}
	var current: Dictionary = checked["state"]
	var entry: Dictionary = current["entry"]
	var profile_id := str(entry.get("profile_id", PROFILE_ID))
	if stage not in stages_for_profile(profile_id):
		return {}
	var receipts: Dictionary = current["receipts"]
	for raw_event_id in current["order"] as Array:
		var event_id := str(raw_event_id)
		var raw: Variant = receipts.get(event_id, {})
		if raw is Dictionary and str((raw as Dictionary).get("stage", "")) == stage:
			return (raw as Dictionary).duplicate(true)
	return {}


static func selected_choice_by_event(state: Dictionary, event_id: String) -> int:
	var receipt := receipt_snapshot_for_event(state, event_id)
	return int(receipt.get("choice_index", -1)) if not receipt.is_empty() else -1


static func selected_choice_for_stage(state: Dictionary, stage: String) -> int:
	var receipt := receipt_snapshot_for_stage(state, stage)
	return int(receipt.get("choice_index", -1)) if not receipt.is_empty() else -1


static func choice_count_for_event(event_id: String) -> int:
	var root := _root_by_id(
		_ledger_for_profile(profile_for_event(event_id)), event_id)
	return (root.get("choices", []) as Array).size() \
		if root.get("choices", []) is Array else 0


static func choice_count_for_stage(state: Dictionary, stage: String) -> int:
	var checked := _canonical_state(state)
	if not bool(checked.get("ok", false)):
		return 0
	var current: Dictionary = checked["state"]
	if (current.get("entry", {}) as Dictionary).is_empty():
		return 0
	var root := _active_root_for_stage(
		_ledger_for_state(current), current["entry"] as Dictionary, stage)
	return (root.get("choices", []) as Array).size() \
		if root.get("choices", []) is Array else 0


static func event_stage(event_id: String) -> String:
	var root := _root_by_id(
		_ledger_for_profile(profile_for_event(event_id)), event_id)
	return str(root.get("stage", "")) if not root.is_empty() else ""


static func event_sequence(event_id: String) -> int:
	var root := _root_by_id(
		_ledger_for_profile(profile_for_event(event_id)), event_id)
	return int(root.get("stage_sequence", -1)) if not root.is_empty() else -1


static func week_completed(state: Dictionary, turn: int) -> bool:
	var checked := _canonical_state(state)
	if not bool(checked.get("ok", false)):
		return false
	var current: Dictionary = checked["state"]
	if str(current.get("status", "")) != "open" \
			or (current.get("entry", {}) as Dictionary).is_empty():
		return false
	var entry: Dictionary = current["entry"]
	var ledger := _ledger_for_state(current)
	var receipts: Dictionary = current["receipts"]
	var active_count := 0
	for stage in stages_for_profile(str(entry.get("profile_id", ""))):
		var root := _active_root_for_stage(
			ledger, entry, stage)
		if root.is_empty() or int(root.get("turn", -1)) != turn:
			continue
		active_count += 1
		if not receipts.has(str(root.get("event_id", ""))):
			return false
	return active_count > 0


static func route_complete(state: Dictionary) -> bool:
	var checked := _canonical_state(state)
	if not bool(checked.get("ok", false)):
		return false
	var current: Dictionary = checked["state"]
	return str(current.get("status", "")) == "open" \
		and not (current.get("entry", {}) as Dictionary).is_empty() \
		and _next_active_root(
			_ledger_for_state(current), current["entry"] as Dictionary,
			current["receipts"] as Dictionary).is_empty()


static func holds_ending(state: Dictionary) -> bool:
	var checked := _canonical_state(state)
	if not bool(checked.get("ok", false)):
		return false
	var current: Dictionary = checked["state"]
	return str(current.get("status", "")) == "open" \
		and not (current.get("entry", {}) as Dictionary).is_empty() \
		and str(current.get("ending_check", "")) in ["pending", "ready"]


static func ending_ready(state: Dictionary) -> bool:
	var checked := _canonical_state(state)
	if not bool(checked.get("ok", false)):
		return false
	var current: Dictionary = checked["state"]
	return str(current.get("status", "")) == "open" \
		and str(current.get("ending_check", "")) == "ready" \
		and route_complete(current)


static func consume_ending_check(state: Dictionary) -> Dictionary:
	var checked := _canonical_state(state)
	if not bool(checked.get("ok", false)):
		return _failure(str(checked.get("error", "state_schema")), state)
	var current: Dictionary = checked["state"]
	if str(current.get("status", "")) != "open":
		return _failure("state_closed", current)
	var ending_check := str(current.get("ending_check", ""))
	if ending_check == "consumed":
		return _success(current, true)
	if ending_check != "ready" or not route_complete(current):
		return _failure("ending_not_ready", current)
	var next_state := current.duplicate(true)
	next_state["ending_check"] = "consumed"
	return _success(next_state, false)


static func close_route(state: Dictionary, reason: String) -> Dictionary:
	if reason not in CLOSE_REASONS:
		return _failure("close_reason_invalid", state)
	var closed := _closed_state(reason)
	var checked := _canonical_state(state)
	if bool(checked.get("ok", false)) and _same(checked.get("state", {}), closed):
		return _success(closed, true)
	# Closing is deliberately available when malformed state or content exposed
	# the failure; requiring that malformed input to validate would make it loop.
	return _success(closed, false)


static func _canonical_entry(
		route_id: String, profile_id: String, source_choices: Dictionary,
		father: Dictionary, actors: Dictionary) -> Dictionary:
	var expected_actors := _actors_for_profile(profile_id)
	if route_id != ROUTE_ID or expected_actors.is_empty() \
			or not _valid_source_choices(source_choices, profile_id) \
			or not _valid_father(father, profile_id) \
			or not _same(actors, expected_actors):
		return {}
	return {
		"route_id": ROUTE_ID,
		"turn": entry_turn_for_profile(profile_id),
		"profile_id": profile_id,
		"source_route_id": _source_route_id_for_profile(profile_id),
		"source_choices": source_choices.duplicate(true),
		"father": father.duplicate(true),
		"actor_bindings": expected_actors.duplicate(true),
	}


static func _valid_entry(entry: Dictionary) -> bool:
	var profile_id := str(entry.get("profile_id", ""))
	var expected_actors := _actors_for_profile(profile_id)
	return _has_exact_keys(entry, ENTRY_KEYS) \
		and str(entry.get("route_id", "")) == ROUTE_ID \
		and _is_exact_int(entry.get("turn")) \
		and int(entry.get("turn", -1)) == entry_turn_for_profile(profile_id) \
		and not expected_actors.is_empty() \
		and str(entry.get("source_route_id", "")) \
			== _source_route_id_for_profile(profile_id) \
		and entry.get("source_choices") is Dictionary \
		and _valid_source_choices(
			entry["source_choices"] as Dictionary, profile_id) \
		and entry.get("father") is Dictionary \
		and _valid_father(entry["father"] as Dictionary, profile_id) \
		and entry.get("actor_bindings") is Dictionary \
		and _same(entry["actor_bindings"], expected_actors)


static func _valid_source_choices(
		source_choices: Dictionary, profile_id: String = PROFILE_ID) -> bool:
	var keys := _source_choice_keys_for_profile(profile_id)
	if keys.is_empty() or not _has_exact_keys(source_choices, keys):
		return false
	for key in keys:
		var max_index := _source_choice_max_for_profile(profile_id, key)
		if not _is_exact_int(source_choices.get(key)) \
				or int(source_choices[key]) < 0 \
				or int(source_choices[key]) > max_index:
			return false
	return true


static func _valid_father(
		father: Dictionary, profile_id: String = PROFILE_ID) -> bool:
	if not _has_exact_keys(father, FATHER_KEYS) \
			or not father.get("life") is String \
			or not father.get("contact_mode") is String:
		return false
	var life := str(father.get("life", ""))
	return life in FATHER_LIFE_VALUES \
		and (profile_id != GENERAL_PROFILE_ID or life == "passed") \
		and father.get("contact_mode") is String \
		and str(father.get("contact_mode", "")) in FATHER_CONTACT_VALUES


static func _source_route_id_for_profile(profile_id: String) -> String:
	if profile_id == PROFILE_ID:
		return SOURCE_ROUTE_ID
	if profile_id == GENERAL_PROFILE_ID:
		return GENERAL_SOURCE_ROUTE_ID
	return ""


static func _source_choice_keys_for_profile(profile_id: String) -> Array[String]:
	if profile_id == PROFILE_ID:
		return SOURCE_CHOICE_KEYS.duplicate()
	if profile_id == GENERAL_PROFILE_ID:
		return GENERAL_SOURCE_CHOICE_KEYS.duplicate()
	return []


static func _source_choice_max_for_profile(
		profile_id: String, key: String) -> int:
	if profile_id == PROFILE_ID and key in SOURCE_CHOICE_KEYS:
		return 2
	if profile_id == GENERAL_PROFILE_ID and key in GENERAL_SOURCE_CHOICE_KEYS:
		return 1
	return -1


static func _actors_for_profile(profile_id: String) -> Dictionary:
	if profile_id == PROFILE_ID:
		return ACTORS.duplicate(true)
	if profile_id == GENERAL_PROFILE_ID:
		return GENERAL_ACTORS.duplicate(true)
	return {}


static func _closed_state(reason: String) -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"ledger_id": LEDGER_ID,
		"status": "closed",
		"closed_reason": reason if not reason.is_empty() else "state_schema",
		"entry": {},
		"receipts": {},
		"order": [],
		"ending_check": "consumed",
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
		var raw_choices: Variant = entry.get("source_choices")
		if raw_choices is Dictionary:
			var choices: Dictionary = (raw_choices as Dictionary).duplicate(true)
			var profile_id := str(entry.get("profile_id", ""))
			for key in _source_choice_keys_for_profile(profile_id):
				if _is_json_int(choices.get(key)):
					choices[key] = int(choices[key])
			entry["source_choices"] = choices
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
		for field in ["turn", "choice_index"]:
			if _is_json_int(receipt.get(field)):
				receipt[field] = int(receipt[field])
		var raw_outcome: Variant = receipt.get("economic_outcome")
		if raw_outcome is Dictionary:
			var outcome: Dictionary = (raw_outcome as Dictionary).duplicate(true)
			for field in ["cash_delta_krw", "asset_delta_krw", "debt_delta_krw"]:
				if _is_json_int(outcome.get(field)):
					outcome[field] = int(outcome[field])
			receipt["economic_outcome"] = outcome
		receipts[raw_event_id] = receipt
	normalized["receipts"] = receipts
	return normalized


static func _canonical_state(state: Dictionary) -> Dictionary:
	if not _has_exact_keys(state, STATE_KEYS) \
			or not _is_exact_int(state.get("schema_version")) \
			or int(state["schema_version"]) != SCHEMA_VERSION \
			or not state.get("status") is String \
			or not state.get("closed_reason") is String \
			or not state.get("entry") is Dictionary \
			or not state.get("receipts") is Dictionary \
			or not state.get("order") is Array \
			or not state.get("ending_check") is String:
		return {"ok": false, "error": "state_schema"}
	var status := str(state.get("status", ""))
	var closed_reason := str(state.get("closed_reason", ""))
	var entry: Dictionary = state["entry"]
	var receipts: Dictionary = state["receipts"]
	var order: Array = state["order"]
	var ending_check := str(state.get("ending_check", ""))
	if status == "closed":
		if str(state.get("ledger_id", "")) != LEDGER_ID \
				or closed_reason.is_empty() or not entry.is_empty() \
				or not receipts.is_empty() or not order.is_empty() \
				or ending_check != "consumed":
			return {"ok": false, "error": "state_schema"}
		return {"ok": true, "state": state.duplicate(true)}
	if status != "open" or not closed_reason.is_empty() \
			or ending_check not in ["pending", "ready", "consumed"] \
			or receipts.size() != order.size():
		return {"ok": false, "error": "state_schema"}
	if entry.is_empty():
		if str(state.get("ledger_id", "")) != LEDGER_ID \
				or not receipts.is_empty() or not order.is_empty() \
				or ending_check != "pending":
			return {"ok": false, "error": "entry_missing"}
		if _ledger().is_empty():
			return {"ok": false, "error": "ledger_invalid"}
		return {"ok": true, "state": state.duplicate(true)}
	if not _valid_entry(entry):
		return {"ok": false, "error": "entry_tampered"}
	var profile_id := str(entry.get("profile_id", ""))
	if str(state.get("ledger_id", "")) != ledger_id_for_profile(profile_id):
		return {"ok": false, "error": "state_schema"}
	var ledger := _ledger_for_profile(profile_id)
	if ledger.is_empty():
		return {"ok": false, "error": "ledger_invalid"}
	if order.size() > _expected_active_root_count_for_profile(profile_id):
		return {"ok": false, "error": "state_schema"}
	var replayed: Dictionary = {}
	var seen: Dictionary = {}
	for raw_event_id in order:
		if not raw_event_id is String:
			return {"ok": false, "error": "order_tampered"}
		var event_id := str(raw_event_id)
		if event_id.is_empty() or seen.has(event_id) or not receipts.has(event_id):
			return {"ok": false, "error": "order_tampered"}
		var expected := _next_active_root(ledger, entry, replayed)
		if str(expected.get("event_id", "")) != event_id:
			return {"ok": false, "error": "order_tampered"}
		var raw_receipt: Variant = receipts[event_id]
		if not raw_receipt is Dictionary \
				or not _valid_receipt(raw_receipt as Dictionary, expected):
			return {"ok": false, "error": "receipt_tampered"}
		seen[event_id] = true
		replayed[event_id] = (raw_receipt as Dictionary).duplicate(true)
	for raw_key in receipts:
		if not raw_key is String or not seen.has(str(raw_key)):
			return {"ok": false, "error": "receipt_tampered"}
	var outbound_seen := not receipt_snapshot_for_stage_unchecked(
		receipts, order, "outbound").is_empty()
	if outbound_seen != (ending_check in ["ready", "consumed"]):
		return {"ok": false, "error": "ending_check_tampered"}
	return {"ok": true, "state": state.duplicate(true)}


static func _valid_receipt(receipt: Dictionary, root: Dictionary) -> bool:
	if not _has_exact_keys(receipt, RECEIPT_KEYS) \
			or not receipt.get("stage") is String \
			or not receipt.get("event_id") is String \
			or not _is_exact_int(receipt.get("turn")) \
			or not _is_exact_int(receipt.get("choice_index")) \
			or not receipt.get("actors") is Dictionary \
			or not receipt.get("receipt_ids") is Array \
			or not receipt.get("document_ids") is Array \
			or not receipt.get("economic_outcome") is Dictionary:
		return false
	var choice_index: int = receipt["choice_index"]
	if str(receipt.get("stage", "")) != str(root.get("stage", "")) \
			or str(receipt.get("event_id", "")) != str(root.get("event_id", "")) \
			or int(receipt["turn"]) != int(root.get("turn", -1)) \
			or _choice_by_index(root, choice_index).is_empty():
		return false
	return _same(receipt, _receipt_for_choice(root, choice_index))


static func _receipt_for_choice(root: Dictionary, choice_index: int) -> Dictionary:
	var choice := _choice_by_index(root, choice_index)
	if choice.is_empty():
		return {}
	var stage := str(root.get("stage", ""))
	return {
		"stage": stage,
		"event_id": str(root.get("event_id", "")),
		"turn": int(root.get("turn", -1)),
		"choice_index": choice_index,
		"actors": (root["actors"] as Dictionary).duplicate(true),
		"receipt_ids": (choice["receipt_ids"] as Array).duplicate(true),
		"document_ids": (choice["document_ids"] as Array).duplicate(true),
		"economic_outcome": NO_EXECUTABLE_CONTRACT_OUTCOME.duplicate(true) \
			if stage == "nontransaction" else {},
	}


static func receipt_snapshot_for_stage_unchecked(
		receipts: Dictionary, order: Array, stage: String) -> Dictionary:
	for raw_event_id in order:
		var raw: Variant = receipts.get(str(raw_event_id), {})
		if raw is Dictionary and str((raw as Dictionary).get("stage", "")) == stage:
			return raw as Dictionary
	return {}


static func _next_active_root(
		ledger: Dictionary, entry: Dictionary, receipts: Dictionary) -> Dictionary:
	if ledger.is_empty() or entry.is_empty():
		return {}
	for raw_stage in ledger.get("stages", []) as Array:
		var stage := str(raw_stage)
		var root := _active_root_for_stage(ledger, entry, stage)
		if root.is_empty():
			return {}
		if not receipts.has(str(root.get("event_id", ""))):
			return root
	return {}


static func _active_root_for_stage(
		ledger: Dictionary, entry: Dictionary, stage: String) -> Dictionary:
	var matched: Dictionary = {}
	for raw_root in ledger.get("roots", []) as Array:
		if not raw_root is Dictionary:
			continue
		var root: Dictionary = raw_root
		if str(root.get("stage", "")) != stage \
				or not _root_active_for_entry(root, entry):
			continue
		if not matched.is_empty():
			return {}
		matched = root
	return matched


static func _root_active_for_entry(root: Dictionary, entry: Dictionary) -> bool:
	var condition: Variant = root.get("active_when")
	if condition == null:
		return true
	if not condition is Dictionary \
			or not _has_exact_keys(condition as Dictionary, [
				"entry_path", "equals",
			]):
		return false
	return _entry_value(entry, str((condition as Dictionary).get(
		"entry_path", ""))) == (condition as Dictionary).get("equals")


static func _entry_value(entry: Dictionary, path: String) -> Variant:
	var current: Variant = entry
	for component in path.split(".", false):
		if not current is Dictionary or not (current as Dictionary).has(component):
			return null
		current = (current as Dictionary)[component]
	return current


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
	return _ledger_for_profile(PROFILE_ID)


static func _ledger_for_profile(profile_id: String) -> Dictionary:
	if profile_id == GENERAL_PROFILE_ID:
		if _general_ledger_checked:
			return _general_ledger_cache
		_general_ledger_checked = true
		_general_ledger_cache = {}
		if not FileAccess.file_exists(GENERAL_LEDGER_PATH):
			return _general_ledger_cache
		var general_parsed: Variant = JSON.parse_string(
			FileAccess.get_file_as_string(GENERAL_LEDGER_PATH))
		if not general_parsed is Dictionary \
				or not _valid_ledger(
					general_parsed as Dictionary, GENERAL_PROFILE_ID):
			return _general_ledger_cache
		_general_ledger_cache = (general_parsed as Dictionary).duplicate(true)
		return _general_ledger_cache
	if profile_id != PROFILE_ID:
		return {}
	if _ledger_checked:
		return _ledger_cache
	_ledger_checked = true
	_ledger_cache = {}
	if not FileAccess.file_exists(LEDGER_PATH):
		return _ledger_cache
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LEDGER_PATH))
	if not parsed is Dictionary \
			or not _valid_ledger(parsed as Dictionary, PROFILE_ID):
		return _ledger_cache
	_ledger_cache = (parsed as Dictionary).duplicate(true)
	return _ledger_cache


static func _ledger_for_state(state: Dictionary) -> Dictionary:
	var raw_entry: Variant = state.get("entry", {})
	if raw_entry is Dictionary and not (raw_entry as Dictionary).is_empty():
		return _ledger_for_profile(str((raw_entry as Dictionary).get(
			"profile_id", "")))
	return _ledger_for_profile(profile_for_ledger_id(str(state.get(
		"ledger_id", ""))))


static func _expected_root_count_for_profile(profile_id: String) -> int:
	return GENERAL_EXPECTED_ROOT_COUNT \
		if profile_id == GENERAL_PROFILE_ID else EXPECTED_ROOT_COUNT


static func _expected_active_root_count_for_profile(profile_id: String) -> int:
	return GENERAL_EXPECTED_ACTIVE_ROOT_COUNT \
		if profile_id == GENERAL_PROFILE_ID else EXPECTED_ACTIVE_ROOT_COUNT


static func _expected_choice_count_for_profile(profile_id: String) -> int:
	return GENERAL_EXPECTED_CHOICE_COUNT \
		if profile_id == GENERAL_PROFILE_ID else EXPECTED_CHOICE_COUNT


static func _expected_active_choice_count_for_profile(profile_id: String) -> int:
	return GENERAL_EXPECTED_ACTIVE_CHOICE_COUNT \
		if profile_id == GENERAL_PROFILE_ID else EXPECTED_ACTIVE_CHOICE_COUNT


static func _owned_turns_for_profile(profile_id: String) -> Array[int]:
	if profile_id == PROFILE_ID:
		return OWNED_TURNS.duplicate()
	if profile_id == GENERAL_PROFILE_ID:
		return GENERAL_OWNED_TURNS.duplicate()
	return []


static func _root_choice_counts_for_profile(profile_id: String) -> Array[int]:
	if profile_id == PROFILE_ID:
		return ROOT_CHOICE_COUNTS.duplicate()
	if profile_id == GENERAL_PROFILE_ID:
		return GENERAL_ROOT_CHOICE_COUNTS.duplicate()
	return []


static func _root_actors_for_profile(profile_id: String) -> Dictionary:
	if profile_id == PROFILE_ID:
		return ROOT_ACTORS.duplicate(true)
	if profile_id == GENERAL_PROFILE_ID:
		return GENERAL_ROOT_ACTORS.duplicate(true)
	return {}


static func _read_sources_for_profile(profile_id: String) -> Dictionary:
	if profile_id == PROFILE_ID:
		return READ_SOURCES.duplicate(true)
	if profile_id == GENERAL_PROFILE_ID:
		return GENERAL_READ_SOURCES.duplicate(true)
	return {}


static func _valid_ledger(
		ledger: Dictionary, profile_id: String = PROFILE_ID) -> bool:
	var stages := stages_for_profile(profile_id)
	var expected_roots := _expected_root_count_for_profile(profile_id)
	var expected_active_roots := _expected_active_root_count_for_profile(profile_id)
	var expected_choices := _expected_choice_count_for_profile(profile_id)
	var expected_active_choices := \
		_expected_active_choice_count_for_profile(profile_id)
	if stages.is_empty() or ledger_id_for_profile(profile_id).is_empty():
		return false
	if not _has_exact_keys(ledger, [
			"schema_version", "ledger_id", "choice_index_base",
			"expected_root_count", "expected_active_root_count",
			"expected_choice_count", "expected_active_choice_count",
			"entry_contract", "stages", "roots",
		]) \
			or not _json_int_equals(ledger.get("schema_version"), SCHEMA_VERSION) \
			or str(ledger.get("ledger_id", "")) \
				!= ledger_id_for_profile(profile_id) \
			or not _json_int_equals(ledger.get("choice_index_base"), 0) \
			or not _json_int_equals(ledger.get("expected_root_count"),
				expected_roots) \
			or not _json_int_equals(ledger.get("expected_active_root_count"),
				expected_active_roots) \
			or not _json_int_equals(ledger.get("expected_choice_count"),
				expected_choices) \
			or not _json_int_equals(ledger.get("expected_active_choice_count"),
				expected_active_choices) \
			or not ledger.get("entry_contract") is Dictionary \
			or not ledger.get("stages") is Array \
			or not _same(ledger["stages"], stages) \
			or not ledger.get("roots") is Array:
		return false
	if not _valid_ledger_entry_contract(
			ledger["entry_contract"] as Dictionary, profile_id):
		return false
	var roots: Array = ledger["roots"]
	if roots.size() != expected_roots:
		return false
	var choice_total := 0
	var receipt_ids: Dictionary = {}
	var stage_variant_counts: Dictionary = {}
	for index in range(roots.size()):
		var raw_root: Variant = roots[index]
		if not raw_root is Dictionary:
			return false
		var root: Dictionary = raw_root
		if not _valid_ledger_root(root, index, receipt_ids, profile_id):
			return false
		choice_total += (root["choices"] as Array).size()
		var stage := str(root["stage"])
		stage_variant_counts[stage] = int(stage_variant_counts.get(stage, 0)) + 1
	if choice_total != expected_choices:
		return false
	for stage in stages:
		var expected_variants := 1
		if profile_id == PROFILE_ID \
				and stage in ["father_trace", "father_answer"]:
			expected_variants = 2
		elif profile_id == GENERAL_PROFILE_ID \
				and stage in ["father_legacy", "debt_memory_consequence"]:
			expected_variants = 2
		if int(stage_variant_counts.get(stage, 0)) != expected_variants:
			return false
	var sample_lives: Array[String] = ["passed"]
	if profile_id == PROFILE_ID:
		sample_lives = FATHER_LIFE_VALUES.duplicate()
	var source_samples: Array[Dictionary] = []
	var base_source_choices: Dictionary = {}
	for source_key in _source_choice_keys_for_profile(profile_id):
		base_source_choices[source_key] = 0
	if profile_id == GENERAL_PROFILE_ID:
		for branch_choice in [0, 1]:
			var branch_sources := base_source_choices.duplicate(true)
			branch_sources["w220_debt_memory_reconnect"] = branch_choice
			source_samples.append(branch_sources)
	else:
		source_samples.append(base_source_choices)
	var sampled_active_roots: Dictionary = {}
	for life in sample_lives:
		for sample_source_choices in source_samples:
			var entry := {
				"route_id": ROUTE_ID,
				"turn": entry_turn_for_profile(profile_id),
				"profile_id": profile_id,
				"source_route_id": _source_route_id_for_profile(profile_id),
				"source_choices": sample_source_choices.duplicate(true),
				"father": {"life": life, "contact_mode": "records_only"},
				"actor_bindings": _actors_for_profile(profile_id),
			}
			var active_choices := 0
			var active_roots := 0
			for stage in stages:
				var active := _active_root_for_stage(ledger, entry, stage)
				if active.is_empty():
					return false
				active_roots += 1
				active_choices += (active["choices"] as Array).size()
				sampled_active_roots[str(active.get("event_id", ""))] = true
			if active_roots != expected_active_roots \
					or active_choices != expected_active_choices:
				return false
	if sampled_active_roots.size() != expected_roots:
		return false
	return true


static func _valid_ledger_entry_contract(
		contract: Dictionary, profile_id: String = PROFILE_ID) -> bool:
	var source_keys := _source_choice_keys_for_profile(profile_id)
	var actors := _actors_for_profile(profile_id)
	if not _has_exact_keys(contract, [
			"route_id", "turn", "profile_id", "source_route_id",
			"source_choice_keys", "father", "actor_bindings",
		]) \
			or str(contract.get("route_id", "")) != ROUTE_ID \
			or not _json_int_equals(contract.get("turn"),
				entry_turn_for_profile(profile_id)) \
			or str(contract.get("profile_id", "")) != profile_id \
			or str(contract.get("source_route_id", "")) \
				!= _source_route_id_for_profile(profile_id) \
			or not contract.get("source_choice_keys") is Dictionary \
			or not contract.get("father") is Dictionary \
			or not contract.get("actor_bindings") is Dictionary \
			or not _same(contract["actor_bindings"], actors):
		return false
	var choice_contract: Dictionary = contract["source_choice_keys"]
	if not _has_exact_keys(choice_contract, source_keys):
		return false
	for key in source_keys:
		var raw_values: Variant = choice_contract.get(key)
		var choice_count := _source_choice_max_for_profile(profile_id, key) + 1
		if not raw_values is Array \
				or (raw_values as Array).size() != choice_count:
			return false
		for index in range(choice_count):
			if not _json_int_equals((raw_values as Array)[index], index):
				return false
	var father_contract: Dictionary = contract["father"]
	var expected_lives: Array[String] = ["passed"]
	if profile_id == PROFILE_ID:
		expected_lives = FATHER_LIFE_VALUES.duplicate()
	return _has_exact_keys(father_contract, FATHER_KEYS) \
		and _same(father_contract.get("life", []), expected_lives) \
		and _same(father_contract.get("contact_mode", []), FATHER_CONTACT_VALUES)


static func _valid_ledger_root(
		root: Dictionary, index: int, seen_receipt_ids: Dictionary,
		profile_id: String = PROFILE_ID) -> bool:
	var turns := _owned_turns_for_profile(profile_id)
	var event_ids := owned_event_ids_for_profile(profile_id)
	var choice_counts := _root_choice_counts_for_profile(profile_id)
	var stages := stages_for_profile(profile_id)
	var root_actors := _root_actors_for_profile(profile_id)
	var read_sources := _read_sources_for_profile(profile_id)
	if index < 0 or index >= event_ids.size():
		return false
	var expected_event_id := event_ids[index]
	if not _has_exact_keys(root, [
			"stage_sequence", "variant_sequence", "month", "turn", "week",
			"event_id", "root_id", "choice_count", "tier", "stage",
			"active_when", "actors", "read_sources", "read_mode", "choices",
		]) \
			or not _json_int_equals(root.get("turn"), turns[index]) \
			or not _json_int_equals(root.get("week"), turns[index]) \
			or not _is_json_int(root.get("month")) \
			or int(root["month"]) != floori((turns[index] - 1) / 4.0) + 1 \
			or str(root.get("event_id", "")) != expected_event_id \
			or str(root.get("root_id", "")) != expected_event_id \
			or not _json_int_equals(root.get("choice_count"),
				choice_counts[index]) \
			or str(root.get("tier", "")) not in ["T1", "T2"] \
			or str(root.get("stage", "")) not in stages \
			or not _is_json_int(root.get("stage_sequence")) \
			or int(root["stage_sequence"]) != stages.find(str(root["stage"])) + 1 \
			or not _is_json_int(root.get("variant_sequence")) \
			or not root.get("actors") is Dictionary \
			or not _same(root["actors"], root_actors[expected_event_id]) \
			or not root.get("read_sources") is Array \
			or not _same(root["read_sources"], read_sources[expected_event_id]) \
			or str(root.get("read_mode", "")) \
				!= _expected_read_mode(expected_event_id) \
			or not root.get("choices") is Array:
		return false
	var is_father_variant := profile_id == PROFILE_ID \
		and str(root["stage"]) in ["father_trace", "father_answer"]
	var is_general_branch_variant := profile_id == GENERAL_PROFILE_ID \
		and GENERAL_BRANCH_VARIANTS.has(expected_event_id)
	var expected_variant := 1
	var expected_life := ""
	if is_father_variant:
		expected_life = "passed" if "passed" in str(root["event_id"]) else "alive"
		expected_variant = 2 if expected_life == "passed" else 1
		if not root.get("active_when") is Dictionary \
				or not _same(root["active_when"], {
					"entry_path": "father.life", "equals": expected_life,
				}):
			return false
	elif is_general_branch_variant:
		var branch_choice := int(GENERAL_BRANCH_VARIANTS[expected_event_id])
		expected_variant = branch_choice + 1
		if not root.get("active_when") is Dictionary:
			return false
		var active_when: Dictionary = root["active_when"]
		if not _has_exact_keys(active_when, ["entry_path", "equals"]) \
				or str(active_when.get("entry_path", "")) \
					!= "source_choices.w220_debt_memory_reconnect" \
				or not _json_int_equals(
					active_when.get("equals"), branch_choice):
			return false
	elif root.get("active_when") != null:
		return false
	if int(root["variant_sequence"]) != expected_variant:
		return false
	var choices: Array = root["choices"]
	if choices.size() != choice_counts[index]:
		return false
	for choice_index in range(choices.size()):
		var raw_choice: Variant = choices[choice_index]
		if not raw_choice is Dictionary:
			return false
		var choice: Dictionary = raw_choice
		if not _has_exact_keys(choice, [
				"index", "receipt_ids", "document_ids", "economic_outcome",
			]) \
				or not _json_int_equals(choice.get("index"), choice_index) \
				or not _valid_string_array(choice.get("receipt_ids"), false) \
				or not _valid_string_array(choice.get("document_ids"), false) \
				or not choice.get("economic_outcome") is Dictionary:
			return false
		for raw_receipt_id in choice["receipt_ids"] as Array:
			var receipt_id := str(raw_receipt_id)
			if seen_receipt_ids.has(receipt_id):
				return false
			seen_receipt_ids[receipt_id] = true
		if profile_id == PROFILE_ID \
				and str(root["stage"]) == "nontransaction":
			if not _valid_no_execution_outcome(choice["economic_outcome"] as Dictionary):
				return false
		elif not (choice["economic_outcome"] as Dictionary).is_empty():
			return false
	return true


static func _expected_read_mode(event_id: String) -> String:
	return "inline_slots" if event_id in INLINE_SLOT_READ_EVENT_IDS else "prepend"


static func _valid_no_execution_outcome(outcome: Dictionary) -> bool:
	if not _has_exact_keys(outcome, [
			"kind", "reason", "cash_delta_krw", "asset_delta_krw",
			"debt_delta_krw",
		]) \
			or str(outcome.get("kind", "")) != "none" \
			or str(outcome.get("reason", "")) != "no_executable_contract":
		return false
	for key in ["cash_delta_krw", "asset_delta_krw", "debt_delta_krw"]:
		if not _json_int_equals(outcome.get(key), 0):
			return false
	return true


static func _valid_string_array(raw_values: Variant, allow_empty: bool) -> bool:
	if not raw_values is Array \
			or (not allow_empty and (raw_values as Array).is_empty()):
		return false
	for raw_value in raw_values as Array:
		if not raw_value is String or str(raw_value).is_empty():
			return false
	return true


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
	return typeof(value) == TYPE_INT or (
		typeof(value) == TYPE_FLOAT and is_finite(float(value))
		and float(value) == floor(float(value)))


static func _json_int_equals(value: Variant, expected: int) -> bool:
	return _is_json_int(value) and int(value) == expected


static func _same(left: Variant, right: Variant) -> bool:
	return JSON.stringify(left, "", true) == JSON.stringify(right, "", true)
