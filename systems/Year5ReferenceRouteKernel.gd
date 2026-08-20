extends RefCounted
class_name Year5ReferenceRouteKernel

## Deterministic, caller-configured reducer for an inactive story segment.
## It owns no files, dispatchers, saves, global state, or product effects.

const SCHEMA_VERSION := 1
const EXPECTED_ROOT_COUNT := 9
const EXPECTED_CHOICE_COUNT := 25
const EXPECTED_BLOCKER_COUNT := 2
const NEXT_KINDS := ["root", "external_blocker", "terminal", "awaiting_r2"]
const STEP_KINDS := ["root", "external_blocker"]
const FLOWS := ["continuation", "terminal"]
const RULE_SOURCES := [
	"entry_snapshot", "m48_receipt", "explicit_route_lock", "receipt",
	"step_evidence", "facts", "consumed", "role_handles", "scene_evidence",
]
const RULE_OPERATORS := [
	"exists", "absent", "equals", "not_equals", "in", "not_in",
	"truthy", "falsy", "equals_path", "unconsumed",
]

var _contract: Dictionary = {}


func configure(contract: Dictionary) -> Dictionary:
	_contract.clear()
	var checked := _validate_contract(contract)
	if not checked.is_empty():
		return checked
	_contract = contract.duplicate(true)
	return _ok({"contract_id": str(_contract.get("contract_id", ""))})


func initial_state() -> Dictionary:
	if not _configured():
		return _fail("kernel_unconfigured", "The injected contract is not configured.")
	return _state_result(_empty_state())


func begin_route(
	state: Dictionary,
	entry_snapshot: Dictionary,
	m48_receipt: Dictionary,
	explicit_route_lock: Variant,
) -> Dictionary:
	var canonical := _canonical_state(state)
	if not bool(canonical.get("ok", false)):
		return canonical
	var current: Dictionary = canonical["state"]
	if bool(current.get("started", false)):
		var last := _last_history_row(current)
		if (
			str(last.get("kind", "")) == "begin"
			and _same(last.get("entry_snapshot"), entry_snapshot)
			and _same(last.get("m48_receipt"), m48_receipt)
			and _same(last.get("explicit_route_lock"), explicit_route_lock)
		):
			return _mutation_result(current, [], true)
		return _fail_with_state(
			"route_already_started", "The route was already started with different input.", current)

	var context := _context(current, entry_snapshot, m48_receipt, explicit_route_lock, {})
	var entry: Dictionary = _contract["entry"]
	var gate := _check_rules(entry["requirements"], context)
	if not bool(gate.get("ok", false)):
		return _fail_with_state("entry_invalid", str(gate.get("error", "Entry evidence is invalid.")), current)
	var actors_result := _resolve_actors(entry["actor_bindings"], entry["same_actor_groups"], context)
	if not bool(actors_result.get("ok", false)):
		return _fail_with_state(
			str(actors_result.get("error_code", "entry_invalid")),
			str(actors_result.get("error", "Actor evidence is invalid.")), current)
	current["role_handles"] = (actors_result["actors"] as Dictionary).duplicate(true)
	context["role_handles"] = current["role_handles"]
	var writes_result := _resolve_writes(entry["writes"], context)
	if not bool(writes_result.get("ok", false)):
		return _fail_with_state(
			str(writes_result.get("error_code", "entry_invalid")),
			str(writes_result.get("error", "Entry writes are invalid.")), current)
	var emitted: Array = writes_result["writes"]
	var applied := _apply_writes(current, emitted)
	if not bool(applied.get("ok", false)):
		return applied
	current = applied["state"]
	current["started"] = true
	current["entry_snapshot"] = entry_snapshot.duplicate(true)
	current["m48_receipt"] = m48_receipt.duplicate(true)
	current["explicit_route_lock"] = _copy(explicit_route_lock)
	current["history"].append({
		"kind": "begin",
		"sequence": 0,
		"entry_snapshot": entry_snapshot.duplicate(true),
		"m48_receipt": m48_receipt.duplicate(true),
		"explicit_route_lock": _copy(explicit_route_lock),
		"role_handles": current["role_handles"].duplicate(true),
		"emitted_receipts": emitted.duplicate(true),
	})
	return _mutation_result(current, emitted, false)


func next_step(state: Dictionary) -> Dictionary:
	var canonical := _canonical_state(state)
	if not bool(canonical.get("ok", false)):
		return canonical
	var current: Dictionary = canonical["state"]
	if not bool(current.get("started", false)):
		return _fail_with_state("route_not_started", "The route has not started.", current)
	return _ok({"state": current.duplicate(true), "next": _next_descriptor(current)})


func commit_choice(
	state: Dictionary,
	root_id: String,
	choice_index: Variant,
	step_evidence: Dictionary = {},
) -> Dictionary:
	var canonical := _canonical_state(state)
	if not bool(canonical.get("ok", false)):
		return canonical
	var current: Dictionary = canonical["state"]
	if not _is_exact_int(choice_index):
		return _fail_with_state("choice_invalid", "The choice index must be a canonical integer.", current)
	var canonical_choice_index: int = choice_index
	if not bool(current.get("started", false)):
		return _fail_with_state("route_not_started", "The route has not started.", current)
	var replay := _choice_replay(current, root_id, canonical_choice_index, step_evidence)
	if not replay.is_empty():
		return replay
	if not (current.get("terminal", {}) as Dictionary).is_empty():
		return _fail_with_state("terminal_reached", "A terminal choice already closed the route.", current)
	var step := _current_step(current)
	if str(step.get("kind", "")) != "root" or str(step.get("id", "")) != root_id:
		return _fail_with_state("step_mismatch", "The choice does not match the current root.", current)
	var choices: Array = step["choices"]
	if canonical_choice_index < 0 or canonical_choice_index >= choices.size():
		return _fail_with_state("choice_invalid", "The choice index is outside the contract.", current)
	var choice: Dictionary = choices[canonical_choice_index]
	if not _is_exact_int(choice.get("index")) or choice["index"] != canonical_choice_index:
		return _fail_with_state("choice_invalid", "The choice index is not canonical.", current)
	var evidence_result := _check_exact_schema(step_evidence, step["evidence_schema"])
	if not bool(evidence_result.get("ok", false)):
		return _fail_with_state("evidence_schema", str(evidence_result.get("error", "Step evidence is invalid.")), current)
	var context := _state_context(current)
	context["step_evidence"] = step_evidence.duplicate(true)
	var root_gate := _check_rules(step["requirements"], context)
	if not bool(root_gate.get("ok", false)):
		return _fail_with_state("requirements_unmet", str(root_gate.get("error", "Root requirements are unmet.")), current)
	var choice_gate := _check_rules(choice["requirements"], context)
	if not bool(choice_gate.get("ok", false)):
		return _fail_with_state("requirements_unmet", str(choice_gate.get("error", "Choice requirements are unmet.")), current)
	var common_result := _resolve_writes(step["common_writes"], context)
	if not bool(common_result.get("ok", false)):
		return _fail_with_state(str(common_result.get("error_code", "write_conflict")), str(common_result.get("error", "Common writes are invalid.")), current)
	var choice_result := _resolve_writes(choice["writes"], context)
	if not bool(choice_result.get("ok", false)):
		return _fail_with_state(str(choice_result.get("error_code", "write_conflict")), str(choice_result.get("error", "Choice writes are invalid.")), current)
	var emitted: Array = (common_result["writes"] as Array).duplicate(true)
	emitted.append_array((choice_result["writes"] as Array).duplicate(true))
	var applied := _apply_writes(current, emitted)
	if not bool(applied.get("ok", false)):
		return applied
	current = applied["state"]
	current["cursor"] = current["cursor"] + 1
	current["scene_evidence"][root_id] = step_evidence.duplicate(true)
	if str(choice.get("flow", "")) == "terminal":
		current["terminal"] = {
			"root_id": root_id,
			"choice_index": canonical_choice_index,
			"outcome_id": str(choice.get("outcome_id", "")),
		}
	current["history"].append({
		"kind": "choice",
		"sequence": (current["history"] as Array).size(),
		"root_id": root_id,
		"choice_index": canonical_choice_index,
		"step_evidence": step_evidence.duplicate(true),
		"outcome_id": str(choice.get("outcome_id", "")),
		"emitted_receipts": emitted.duplicate(true),
	})
	return _mutation_result(current, emitted, false)


func commit_external_receipt(
	state: Dictionary,
	blocker_id: String,
	receipt: Dictionary,
) -> Dictionary:
	var canonical := _canonical_state(state)
	if not bool(canonical.get("ok", false)):
		return canonical
	var current: Dictionary = canonical["state"]
	if not bool(current.get("started", false)):
		return _fail_with_state("route_not_started", "The route has not started.", current)
	if not (current.get("terminal", {}) as Dictionary).is_empty():
		return _fail_with_state("terminal_reached", "A terminal choice already closed the route.", current)
	var replay := _external_replay(current, blocker_id, receipt)
	if not replay.is_empty():
		return replay
	var step := _current_step(current)
	if str(step.get("kind", "")) != "external_blocker" or str(step.get("id", "")) != blocker_id:
		return _fail_with_state("step_mismatch", "The receipt does not match the current blocker.", current)
	if not bool(step.get("synthetic_fixture_only", false)):
		return _fail_with_state("receipt_schema", "The blocker is not declared as a synthetic fixture.", current)
	if str(receipt.get("source_kind", "")) != str(step.get("source", "")):
		return _fail_with_state("receipt_source", "The receipt source does not match the blocker.", current)
	var schema_result := _check_exact_schema(receipt, step["receipt_schema"])
	if not bool(schema_result.get("ok", false)):
		return _fail_with_state("receipt_schema", str(schema_result.get("error", "The receipt schema is invalid.")), current)
	var context := _state_context(current)
	context["receipt"] = receipt.duplicate(true)
	var gate := _check_rules(step["requirements"], context)
	if not bool(gate.get("ok", false)):
		return _fail_with_state("requirements_unmet", str(gate.get("error", "Blocker requirements are unmet.")), current)
	var writes_result := _resolve_writes(step["writes"], context)
	if not bool(writes_result.get("ok", false)):
		return _fail_with_state(str(writes_result.get("error_code", "write_conflict")), str(writes_result.get("error", "Receipt writes are invalid.")), current)
	var emitted: Array = writes_result["writes"]
	var applied := _apply_writes(current, emitted)
	if not bool(applied.get("ok", false)):
		return applied
	current = applied["state"]
	current["cursor"] = current["cursor"] + 1
	current["history"].append({
		"kind": "external",
		"sequence": (current["history"] as Array).size(),
		"blocker_id": blocker_id,
		"receipt": receipt.duplicate(true),
		"emitted_receipts": emitted.duplicate(true),
	})
	return _mutation_result(current, emitted, false)


func normalize_state(raw_history: Variant) -> Dictionary:
	if not _configured():
		return _fail("kernel_unconfigured", "The injected contract is not configured.")
	if not raw_history is Array:
		return _fail("state_schema", "History must be an array.")
	var history: Array = (raw_history as Array).duplicate(true)
	var state := _empty_state()
	var identities: Dictionary = {}
	for index in range(history.size()):
		var raw_row: Variant = history[index]
		if not raw_row is Dictionary:
			return _fail("history_tampered", "A history row is not an object.")
		var row: Dictionary = raw_row
		if not _is_exact_int(row.get("sequence")) or row["sequence"] != index:
			return _fail("history_tampered", "History sequence is not contiguous.")
		var identity := _history_identity(row)
		if identity.is_empty():
			return _fail("history_tampered", "History row kind is invalid.")
		if identities.has(identity):
			return _fail("history_duplicate", "Persisted history contains a duplicate callback.")
		identities[identity] = true
		var replayed := _replay_row(state, row)
		if not bool(replayed.get("ok", false)):
			return replayed
		state = replayed["state"]
	return _state_result(state)


func snapshot(state: Dictionary) -> Dictionary:
	var canonical := _canonical_state(state)
	if not bool(canonical.get("ok", false)):
		return canonical
	var current: Dictionary = canonical["state"]
	return _ok({
		"state": current.duplicate(true),
		"history": (current["history"] as Array).duplicate(true),
		"next": _next_descriptor(current) if bool(current.get("started", false)) else {},
	})


func _validate_contract(contract: Dictionary) -> Dictionary:
	if not _has_exact_keys(contract, ["schema_version", "contract_id", "entry", "steps"]):
		return _fail("contract_schema", "The contract top-level keys are invalid.")
	if not _is_exact_int(contract.get("schema_version")) or contract["schema_version"] != SCHEMA_VERSION:
		return _fail("contract_schema", "The contract schema version is unsupported.")
	if str(contract.get("contract_id", "")).is_empty():
		return _fail("contract_schema", "The contract id is empty.")
	if not contract.get("entry") is Dictionary or not contract.get("steps") is Array:
		return _fail("contract_schema", "The contract entry or steps have an invalid type.")
	var entry: Dictionary = contract["entry"]
	if not _has_exact_keys(entry, ["requirements", "writes", "actor_bindings", "same_actor_groups"]):
		return _fail("contract_schema", "The entry keys are invalid.")
	if not entry["requirements"] is Array or not entry["writes"] is Array:
		return _fail("contract_schema", "Entry rules and writes must be arrays.")
	if not entry["actor_bindings"] is Dictionary or not entry["same_actor_groups"] is Array:
		return _fail("contract_schema", "Entry actor bindings are invalid.")
	if (entry["actor_bindings"] as Dictionary).is_empty() or (entry["same_actor_groups"] as Array).is_empty():
		return _fail("contract_schema", "Entry actor bindings cannot be empty.")
	var rules_check := _validate_rules(entry["requirements"])
	if not rules_check.is_empty():
		return rules_check
	var writes_check := _validate_writes(entry["writes"])
	if not writes_check.is_empty():
		return writes_check
	var ids: Dictionary = {}
	var previous_month := -1
	var previous_order := -1
	var root_count := 0
	var choice_count := 0
	var blocker_count := 0
	var steps: Array = contract["steps"]
	if steps.is_empty():
		return _fail("contract_schema", "The contract has no steps.")
	for raw_step in steps:
		if not raw_step is Dictionary:
			return _fail("contract_schema", "A step is not an object.")
		var step: Dictionary = raw_step
		var kind := str(step.get("kind", ""))
		var step_id := str(step.get("id", ""))
		if kind not in STEP_KINDS or step_id.is_empty() or ids.has(step_id):
			return _fail("contract_schema", "A step kind or id is invalid.")
		ids[step_id] = true
		if not _is_exact_int(step.get("month")):
			return _fail("contract_schema", "A step month must be a canonical integer.")
		var month: int = step["month"]
		if month > previous_month:
			previous_order = -1
		var order := 0
		if kind == "root":
			if not _is_exact_int(step.get("order")):
				return _fail("contract_schema", "A root order must be a canonical integer.")
			order = step["order"]
		if month <= 0 or month < previous_month or (month == previous_month and kind == "root" and order <= previous_order):
			return _fail("contract_schema", "Step chronology is invalid.")
		previous_month = month
		previous_order = order if kind == "root" else previous_order
		var step_check := _validate_root(step) if kind == "root" else _validate_blocker(step)
		if not step_check.is_empty():
			return step_check
		if kind == "root":
			root_count += 1
			choice_count += (step["choices"] as Array).size()
		else:
			blocker_count += 1
	if root_count != EXPECTED_ROOT_COUNT or choice_count != EXPECTED_CHOICE_COUNT or blocker_count != EXPECTED_BLOCKER_COUNT:
		return _fail("contract_schema", "The segment root, choice, or blocker count is invalid.")
	for index in range(steps.size()):
		var expected_kind := "external_blocker" if index in [6, 7] else "root"
		if str((steps[index] as Dictionary).get("kind", "")) != expected_kind:
			return _fail("contract_schema", "External handoffs are not at the canonical segment boundary.")
	return {}


func _validate_root(step: Dictionary) -> Dictionary:
	if not _has_exact_keys(step, ["kind", "id", "month", "order", "evidence_schema", "requirements", "common_writes", "choices"]):
		return _fail("contract_schema", "A root step has invalid keys.")
	if (
		not _is_exact_int(step.get("order"))
		or step["order"] <= 0
		or not step["evidence_schema"] is Dictionary
		or not step["requirements"] is Array
		or not step["common_writes"] is Array
		or not step["choices"] is Array
	):
		return _fail("contract_schema", "A root step has invalid fields.")
	var schema_checked := _validate_exact_schema(step["evidence_schema"])
	if not schema_checked.is_empty():
		return schema_checked
	var checked := _validate_rules(step["requirements"])
	if not checked.is_empty():
		return checked
	checked = _validate_writes(step["common_writes"])
	if not checked.is_empty():
		return checked
	var choices: Array = step["choices"]
	if choices.is_empty():
		return _fail("contract_schema", "A root has no choices.")
	for index in range(choices.size()):
		if not choices[index] is Dictionary:
			return _fail("contract_schema", "A choice is not an object.")
		var choice: Dictionary = choices[index]
		if not _has_exact_keys(choice, ["index", "outcome_id", "flow", "requirements", "writes"]):
			return _fail("contract_schema", "A choice has invalid keys.")
		if not _is_exact_int(choice.get("index")) or choice["index"] != index or str(choice.get("outcome_id", "")).is_empty() or str(choice.get("flow", "")) not in FLOWS:
			return _fail("contract_schema", "A choice identity or flow is invalid.")
		if not choice["requirements"] is Array or not choice["writes"] is Array:
			return _fail("contract_schema", "Choice rules and writes must be arrays.")
		checked = _validate_rules(choice["requirements"])
		if not checked.is_empty():
			return checked
		checked = _validate_writes(choice["writes"])
		if not checked.is_empty():
			return checked
	return {}


func _validate_blocker(step: Dictionary) -> Dictionary:
	if not _has_exact_keys(step, ["kind", "id", "month", "source", "synthetic_fixture_only", "receipt_schema", "requirements", "writes"]):
		return _fail("contract_schema", "An external blocker has invalid keys.")
	if str(step.get("source", "")).is_empty() or typeof(step.get("synthetic_fixture_only")) != TYPE_BOOL or not step["synthetic_fixture_only"]:
		return _fail("contract_schema", "An external blocker must be synthetic and sourced.")
	if not step["receipt_schema"] is Dictionary or not step["requirements"] is Array or not step["writes"] is Array:
		return _fail("contract_schema", "An external blocker has invalid fields.")
	var schema: Dictionary = step["receipt_schema"]
	var schema_checked := _validate_exact_schema(schema)
	if not schema_checked.is_empty():
		return schema_checked
	var checked := _validate_rules(step["requirements"])
	if not checked.is_empty():
		return checked
	return _validate_writes(step["writes"])


func _validate_exact_schema(schema: Dictionary) -> Dictionary:
	if not _has_allowed_keys(schema, ["exact_keys", "constants", "allowed_values"]):
		return _fail("contract_schema", "An evidence schema has invalid keys.")
	if not schema.get("exact_keys") is Array:
		return _fail("contract_schema", "An evidence schema needs exact keys.")
	if schema.has("constants") and not schema["constants"] is Dictionary:
		return _fail("contract_schema", "Evidence constants are invalid.")
	if schema.has("allowed_values") and not schema["allowed_values"] is Dictionary:
		return _fail("contract_schema", "Evidence allowed values are invalid.")
	var exact_keys: Array = schema["exact_keys"]
	var seen: Dictionary = {}
	for raw_key in exact_keys:
		if not raw_key is String or str(raw_key).is_empty() or seen.has(raw_key):
			return _fail("contract_schema", "Evidence keys must be unique nonempty strings.")
		seen[raw_key] = true
	for key in (schema.get("constants", {}) as Dictionary):
		if not seen.has(key):
			return _fail("contract_schema", "An evidence constant is outside exact keys.")
		if _is_integer_key(str(key)) and not _is_exact_int((schema["constants"] as Dictionary)[key]):
			return _fail("contract_schema", "An evidence integer constant is not canonical.")
	for key in (schema.get("allowed_values", {}) as Dictionary):
		if not seen.has(key) or not (schema["allowed_values"] as Dictionary)[key] is Array:
			return _fail("contract_schema", "Evidence allowed values are outside exact keys.")
		if _is_integer_key(str(key)):
			for value in (schema["allowed_values"] as Dictionary)[key]:
				if not _is_exact_int(value):
					return _fail("contract_schema", "An evidence allowed integer is not canonical.")
	return {}


func _validate_rules(rules: Array) -> Dictionary:
	for raw_rule in rules:
		if not raw_rule is Dictionary:
			return _fail("contract_schema", "A requirement is not an object.")
		var rule: Dictionary = raw_rule
		if not _has_allowed_keys(rule, ["source", "path", "op", "value", "values", "other_source", "other_path", "error"]):
			return _fail("contract_schema", "A requirement has invalid keys.")
		if str(rule.get("source", "")) not in RULE_SOURCES or str(rule.get("op", "")) not in RULE_OPERATORS or not rule.get("path") is Array:
			return _fail("contract_schema", "A requirement source, path, or operator is invalid.")
		if str(rule.get("op", "")) in ["in", "not_in"] and not rule.get("values") is Array:
			return _fail("contract_schema", "A set requirement has no values.")
		if str(rule.get("op", "")) == "equals_path":
			if str(rule.get("other_source", "")) not in RULE_SOURCES or not rule.get("other_path") is Array:
				return _fail("contract_schema", "A cross-source requirement is invalid.")
	return {}


func _validate_writes(writes: Array) -> Dictionary:
	for raw_write in writes:
		if not raw_write is Dictionary:
			return _fail("contract_schema", "A write is not an object.")
		var write: Dictionary = raw_write
		if not _has_exact_keys(write, ["op", "key", "kind", "value"]):
			return _fail("contract_schema", "A write has invalid keys.")
		if str(write.get("op", "")) not in ["emit", "consume"] or str(write.get("key", "")).is_empty() or str(write.get("kind", "")).is_empty():
			return _fail("contract_schema", "A write operation is invalid.")
	return {}


func _canonical_state(state: Dictionary) -> Dictionary:
	if not _configured():
		return _fail("kernel_unconfigured", "The injected contract is not configured.")
	if not _is_exact_int(state.get("schema_version")) or state["schema_version"] != SCHEMA_VERSION:
		return _fail("state_schema", "State schema must be a canonical integer.")
	if not _is_exact_int(state.get("cursor")) or state["cursor"] < 0:
		return _fail("state_schema", "State cursor must be a canonical integer.")
	if typeof(state.get("started")) != TYPE_BOOL:
		return _fail("state_schema", "State started must be a canonical boolean.")
	if not state.get("history") is Array:
		return _fail("state_schema", "State history is missing.")
	var normalized := normalize_state(state["history"])
	if not bool(normalized.get("ok", false)):
		return normalized
	var rebuilt: Dictionary = normalized["state"]
	if not _same(state, rebuilt):
		return _fail("state_tampered", "Derived state does not match immutable history.")
	return normalized


func _replay_row(state: Dictionary, row: Dictionary) -> Dictionary:
	var kind := str(row.get("kind", ""))
	if kind != "begin" and not bool(state.get("started", false)):
		return _fail("history_tampered", "History cannot skip the begin callback.")
	if kind != "begin" and not (state.get("terminal", {}) as Dictionary).is_empty():
		return _fail("history_tampered", "History cannot continue after a terminal choice.")
	if kind == "begin":
		if not _has_exact_keys(row, ["kind", "sequence", "entry_snapshot", "m48_receipt", "explicit_route_lock", "role_handles", "emitted_receipts"]):
			return _fail("history_tampered", "The begin row shape is invalid.")
		if bool(state.get("started", false)) or not row["entry_snapshot"] is Dictionary or not row["m48_receipt"] is Dictionary or not row["role_handles"] is Dictionary or not row["emitted_receipts"] is Array:
			return _fail("history_tampered", "The begin row payload is invalid.")
		var context := _context(state, row["entry_snapshot"], row["m48_receipt"], row["explicit_route_lock"], {})
		var entry: Dictionary = _contract["entry"]
		var gate := _check_rules(entry["requirements"], context)
		if not bool(gate.get("ok", false)):
			return _fail("history_tampered", "Saved entry evidence no longer matches the contract.")
		var actors_result := _resolve_actors(entry["actor_bindings"], entry["same_actor_groups"], context)
		if not bool(actors_result.get("ok", false)) or not _same(row["role_handles"], actors_result.get("actors", {})):
			return _fail("history_tampered", "Saved actor bindings are not canonical.")
		state["role_handles"] = (actors_result["actors"] as Dictionary).duplicate(true)
		context["role_handles"] = state["role_handles"]
		var writes_result := _resolve_writes(entry["writes"], context)
		if not bool(writes_result.get("ok", false)) or not _same(row["emitted_receipts"], writes_result.get("writes", [])):
			return _fail("history_tampered", "Saved entry writes are not canonical.")
		var applied := _apply_writes(state, writes_result["writes"])
		if not bool(applied.get("ok", false)):
			return _fail("history_tampered", str(applied.get("error", "Saved entry writes conflict.")))
		state = applied["state"]
		state["started"] = true
		state["entry_snapshot"] = (row["entry_snapshot"] as Dictionary).duplicate(true)
		state["m48_receipt"] = (row["m48_receipt"] as Dictionary).duplicate(true)
		state["explicit_route_lock"] = _copy(row["explicit_route_lock"])
	elif kind == "choice":
		if not _has_exact_keys(row, ["kind", "sequence", "root_id", "choice_index", "step_evidence", "outcome_id", "emitted_receipts"]):
			return _fail("history_tampered", "A choice row shape is invalid.")
		var step := _current_step(state)
		if not _is_exact_int(row.get("choice_index")) or not row["step_evidence"] is Dictionary:
			return _fail("history_tampered", "A saved choice index or evidence is not canonical.")
		var choice_index: int = row["choice_index"]
		if str(step.get("kind", "")) != "root" or str(step.get("id", "")) != str(row.get("root_id", "")) or choice_index < 0 or choice_index >= (step.get("choices", []) as Array).size():
			return _fail("history_tampered", "A saved choice is out of order.")
		var choice: Dictionary = (step["choices"] as Array)[choice_index]
		if str(row.get("outcome_id", "")) != str(choice.get("outcome_id", "")):
			return _fail("history_tampered", "A saved choice outcome is not canonical.")
		if not bool(_check_exact_schema(row["step_evidence"], step["evidence_schema"]).get("ok", false)):
			return _fail("history_tampered", "Saved step evidence is not canonical.")
		var context := _state_context(state)
		context["step_evidence"] = (row["step_evidence"] as Dictionary).duplicate(true)
		if not bool(_check_rules(step["requirements"], context).get("ok", false)) or not bool(_check_rules(choice["requirements"], context).get("ok", false)):
			return _fail("history_tampered", "A saved choice no longer meets its requirements.")
		var first := _resolve_writes(step["common_writes"], context)
		var second := _resolve_writes(choice["writes"], context)
		if not bool(first.get("ok", false)) or not bool(second.get("ok", false)):
			return _fail("history_tampered", "A saved choice write cannot be resolved.")
		var emitted: Array = (first["writes"] as Array).duplicate(true)
		emitted.append_array((second["writes"] as Array).duplicate(true))
		if not row["emitted_receipts"] is Array or not _same(row["emitted_receipts"], emitted):
			return _fail("history_tampered", "Saved choice writes are partial or altered.")
		var applied := _apply_writes(state, emitted)
		if not bool(applied.get("ok", false)):
			return _fail("history_tampered", str(applied.get("error", "Saved choice writes conflict.")))
		state = applied["state"]
		state["cursor"] = state["cursor"] + 1
		state["scene_evidence"][str(row["root_id"])] = (row["step_evidence"] as Dictionary).duplicate(true)
		if str(choice.get("flow", "")) == "terminal":
			state["terminal"] = {"root_id": str(row["root_id"]), "choice_index": choice_index, "outcome_id": str(row["outcome_id"])}
	elif kind == "external":
		if not _has_exact_keys(row, ["kind", "sequence", "blocker_id", "receipt", "emitted_receipts"]):
			return _fail("history_tampered", "An external row shape is invalid.")
		var step := _current_step(state)
		if str(step.get("kind", "")) != "external_blocker" or str(step.get("id", "")) != str(row.get("blocker_id", "")) or not row["receipt"] is Dictionary:
			return _fail("history_tampered", "A saved external receipt is out of order.")
		var receipt: Dictionary = row["receipt"]
		if str(receipt.get("source_kind", "")) != str(step.get("source", "")) or not bool(_check_exact_schema(receipt, step["receipt_schema"]).get("ok", false)):
			return _fail("history_tampered", "A saved external receipt is not canonical.")
		var context := _state_context(state)
		context["receipt"] = receipt.duplicate(true)
		if not bool(_check_rules(step["requirements"], context).get("ok", false)):
			return _fail("history_tampered", "A saved external receipt no longer meets its requirements.")
		var writes_result := _resolve_writes(step["writes"], context)
		if not bool(writes_result.get("ok", false)) or not row["emitted_receipts"] is Array or not _same(row["emitted_receipts"], writes_result.get("writes", [])):
			return _fail("history_tampered", "Saved external writes are partial or altered.")
		var applied := _apply_writes(state, writes_result["writes"])
		if not bool(applied.get("ok", false)):
			return _fail("history_tampered", str(applied.get("error", "Saved external writes conflict.")))
		state = applied["state"]
		state["cursor"] = state["cursor"] + 1
	else:
		return _fail("history_tampered", "History row kind is invalid.")
	state["history"].append(row.duplicate(true))
	return _ok({"state": state})


func _resolve_actors(bindings: Dictionary, groups: Array, context: Dictionary) -> Dictionary:
	var actors: Dictionary = {}
	for role_value in bindings:
		var role := str(role_value)
		if role.is_empty():
			return _fail("entry_invalid", "An actor role is empty.")
		var resolved := _resolve_template(bindings[role], context)
		if not resolved.get("ok", false) or not resolved.get("value") is String or str(resolved.get("value", "")).is_empty():
			return _fail("entry_invalid", "An actor binding cannot be resolved.")
		actors[role] = str(resolved["value"])
	var seen_actors: Dictionary = {}
	var seen_roles: Dictionary = {}
	for raw_group in groups:
		if not raw_group is Array or (raw_group as Array).is_empty():
			return _fail("entry_invalid", "An actor group is invalid.")
		var actor_id := ""
		for raw_role in raw_group:
			var role := str(raw_role)
			if seen_roles.has(role) or not actors.has(role):
				return _fail("entry_invalid", "Actor groups are incomplete or overlap.")
			seen_roles[role] = true
			if actor_id.is_empty():
				actor_id = str(actors[role])
			elif actor_id != str(actors[role]):
				return _fail("actor_group_mismatch", "Roles in one actor group resolve differently.")
		if seen_actors.has(actor_id):
			return _fail("actor_duplicate", "Distinct actor groups resolve to one actor.")
		seen_actors[actor_id] = true
	if seen_roles.size() != actors.size():
		return _fail("entry_invalid", "Every actor binding must belong to exactly one group.")
	return _ok({"actors": actors})


func _check_rules(rules: Array, context: Dictionary) -> Dictionary:
	for raw_rule in rules:
		var rule: Dictionary = raw_rule
		var found := _lookup(context.get(str(rule["source"])), rule["path"])
		var op := str(rule["op"])
		var passed := false
		if op == "exists":
			passed = bool(found["found"])
		elif op == "absent":
			passed = not bool(found["found"])
		elif op == "equals":
			passed = bool(found["found"]) and _same(found["value"], rule.get("value"))
		elif op == "not_equals":
			passed = bool(found["found"]) and not _same(found["value"], rule.get("value"))
		elif op == "in":
			passed = bool(found["found"]) and _array_has_exact(rule["values"], found["value"])
		elif op == "not_in":
			passed = bool(found["found"]) and not _array_has_exact(rule["values"], found["value"])
		elif op == "truthy":
			passed = bool(found["found"]) and bool(found["value"])
		elif op == "falsy":
			passed = bool(found["found"]) and not bool(found["value"])
		elif op == "equals_path":
			var other := _lookup(context.get(str(rule["other_source"])), rule["other_path"])
			passed = bool(found["found"]) and bool(other["found"]) and _same(found["value"], other["value"])
		elif op == "unconsumed":
			var rule_path: Array = rule["path"]
			var key := str(rule_path[0]) if rule_path.size() == 1 else ""
			passed = (
				bool(found["found"])
				and not key.is_empty()
				and not (context.get("consumed", {}) as Dictionary).has(key)
			)
		if not passed:
			return _fail("requirements_unmet", str(rule.get("error", "A contract requirement is unmet.")))
	return _ok()


func _resolve_writes(writes: Array, context: Dictionary) -> Dictionary:
	var resolved_writes: Array = []
	var keys: Dictionary = {}
	for raw_write in writes:
		var write: Dictionary = raw_write
		var resolved_value := _resolve_template(write["value"], context)
		if not bool(resolved_value.get("ok", false)):
			return _fail("write_conflict", "A write template cannot be resolved.")
		var resolved := {
			"op": str(write["op"]),
			"key": str(write["key"]),
			"kind": str(write["kind"]),
			"value": _copy(resolved_value["value"]),
		}
		if keys.has(resolved["key"]):
			return _fail("write_conflict", "One atomic batch writes the same key twice.")
		keys[resolved["key"]] = true
		resolved_writes.append(resolved)
	return _ok({"writes": resolved_writes})


func _apply_writes(state: Dictionary, writes: Array) -> Dictionary:
	var next_state := state.duplicate(true)
	var facts: Dictionary = next_state["facts"]
	var consumed: Dictionary = next_state["consumed"]
	for raw_write in writes:
		var write: Dictionary = raw_write
		var key := str(write["key"])
		if str(write["op"]) == "emit":
			if facts.has(key):
				return _fail_with_state("write_conflict", "A fact key was already written.", state)
			facts[key] = {"kind": str(write["kind"]), "value": _copy(write["value"])}
		else:
			if not facts.has(key):
				return _fail_with_state("fact_missing", "A consumed fact does not exist.", state)
			if consumed.has(key):
				return _fail_with_state("fact_consumed", "A fact cannot be consumed twice.", state)
			if not _same((facts[key] as Dictionary).get("value"), write["value"]):
				return _fail_with_state("write_conflict", "A consume operation changed the fact value.", state)
			consumed[key] = (next_state["history"] as Array).size()
	next_state["facts"] = facts
	next_state["consumed"] = consumed
	return _ok({"state": next_state})


func _check_exact_schema(value: Dictionary, schema: Dictionary) -> Dictionary:
	var exact_keys: Array = schema["exact_keys"]
	if not _has_exact_keys(value, exact_keys):
		return _fail("schema_mismatch", "Evidence keys are not exact.")
	for raw_key in exact_keys:
		if _is_integer_key(str(raw_key)) and not _is_exact_int(value[raw_key]):
			return _fail("schema_mismatch", "An evidence integer is not canonical.")
	var constants: Dictionary = schema.get("constants", {})
	for key in constants:
		if _is_integer_key(str(key)) and (not value.has(key) or not _is_exact_int(value[key])):
			return _fail("schema_mismatch", "An evidence integer is not canonical.")
		if not value.has(key) or not _same(value[key], constants[key]):
			return _fail("schema_mismatch", "An evidence constant is wrong.")
	var allowed: Dictionary = schema.get("allowed_values", {})
	for key in allowed:
		if _is_integer_key(str(key)) and (not value.has(key) or not _is_exact_int(value[key])):
			return _fail("schema_mismatch", "An allowed evidence integer is not canonical.")
		if not value.has(key) or not _array_has_exact(allowed[key], value[key]):
			return _fail("schema_mismatch", "An evidence value is outside the allowed set.")
	return _ok()


func _resolve_template(value: Variant, context: Dictionary) -> Dictionary:
	if value is Dictionary:
		var source: Dictionary = value
		if _has_exact_keys(source, ["$source", "path"]):
			if str(source["$source"]) not in RULE_SOURCES or not source["path"] is Array:
				return _fail("write_conflict", "A write source is invalid.")
			var found := _lookup(context.get(str(source["$source"])), source["path"])
			if not bool(found["found"]):
				return _fail("write_conflict", "A write source value is missing.")
			return _ok({"value": _copy(found["value"])})
		var result: Dictionary = {}
		for key in source:
			var child := _resolve_template(source[key], context)
			if not bool(child.get("ok", false)):
				return child
			result[key] = _copy(child["value"])
		return _ok({"value": result})
	if value is Array:
		var result: Array = []
		for item in value:
			var child := _resolve_template(item, context)
			if not bool(child.get("ok", false)):
				return child
			result.append(_copy(child["value"]))
		return _ok({"value": result})
	return _ok({"value": value})


func _choice_replay(
	state: Dictionary,
	root_id: String,
	choice_index: int,
	step_evidence: Dictionary,
) -> Dictionary:
	var last := _last_history_row(state)
	if str(last.get("kind", "")) == "choice" and str(last.get("root_id", "")) == root_id:
		if (
			_is_exact_int(last.get("choice_index"))
			and last["choice_index"] == choice_index
			and _same(last.get("step_evidence"), step_evidence)
		):
			return _mutation_result(state, [], true)
		return _fail_with_state("callback_conflict", "The same root callback changed choice or evidence.", state)
	for row in state["history"]:
		if str((row as Dictionary).get("kind", "")) == "choice" and str((row as Dictionary).get("root_id", "")) == root_id:
			return _fail_with_state("callback_order", "An older choice callback cannot be replayed.", state)
	return {}


func _external_replay(state: Dictionary, blocker_id: String, receipt: Dictionary) -> Dictionary:
	var last := _last_history_row(state)
	if str(last.get("kind", "")) == "external" and str(last.get("blocker_id", "")) == blocker_id:
		if _same(last.get("receipt"), receipt):
			return _mutation_result(state, [], true)
		return _fail_with_state("callback_conflict", "The same blocker callback changed payload.", state)
	for row in state["history"]:
		if str((row as Dictionary).get("kind", "")) == "external" and str((row as Dictionary).get("blocker_id", "")) == blocker_id:
			return _fail_with_state("callback_order", "An older blocker callback cannot be replayed.", state)
	return {}


func _current_step(state: Dictionary) -> Dictionary:
	if not _is_exact_int(state.get("cursor")):
		return {}
	var cursor: int = state["cursor"]
	var steps: Array = _contract.get("steps", [])
	if cursor < 0 or cursor >= steps.size():
		return {}
	return (steps[cursor] as Dictionary).duplicate(true)


func _next_descriptor(state: Dictionary) -> Dictionary:
	var terminal: Dictionary = state.get("terminal", {})
	if not terminal.is_empty():
		return {"kind": "terminal", "id": str(terminal.get("outcome_id", "")), "dispatch_allowed": false}
	var step := _current_step(state)
	if step.is_empty():
		return {"kind": "awaiting_r2", "id": "", "dispatch_allowed": false}
	var descriptor := {"kind": str(step["kind"]), "id": str(step["id"]), "month": step["month"], "dispatch_allowed": false}
	if str(step["kind"]) == "root":
		descriptor["order"] = step["order"]
	return descriptor


func _state_context(state: Dictionary) -> Dictionary:
	return _context(state, state.get("entry_snapshot", {}), state.get("m48_receipt", {}), state.get("explicit_route_lock"), {})


func _context(state: Dictionary, entry_snapshot: Variant, m48_receipt: Variant, explicit_route_lock: Variant, receipt: Variant) -> Dictionary:
	return {
		"entry_snapshot": _copy(entry_snapshot),
		"m48_receipt": _copy(m48_receipt),
		"explicit_route_lock": _copy(explicit_route_lock),
		"receipt": _copy(receipt),
		"step_evidence": {},
		"facts": (state.get("facts", {}) as Dictionary).duplicate(true),
		"consumed": (state.get("consumed", {}) as Dictionary).duplicate(true),
		"role_handles": (state.get("role_handles", {}) as Dictionary).duplicate(true),
		"scene_evidence": (state.get("scene_evidence", {}) as Dictionary).duplicate(true),
	}


func _empty_state() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"contract_id": str(_contract.get("contract_id", "")),
		"started": false,
		"cursor": 0,
		"entry_snapshot": {},
		"m48_receipt": {},
		"explicit_route_lock": null,
		"role_handles": {},
		"scene_evidence": {},
		"facts": {},
		"consumed": {},
		"terminal": {},
		"history": [],
	}


func _history_identity(row: Dictionary) -> String:
	var kind := str(row.get("kind", ""))
	if kind == "begin":
		return "begin"
	if kind == "choice":
		return "choice:" + str(row.get("root_id", ""))
	if kind == "external":
		return "external:" + str(row.get("blocker_id", ""))
	return ""


func _last_history_row(state: Dictionary) -> Dictionary:
	var history: Array = state.get("history", [])
	return (history.back() as Dictionary).duplicate(true) if not history.is_empty() else {}


func _lookup(origin: Variant, path: Array) -> Dictionary:
	var current: Variant = origin
	for raw_key in path:
		if current is Dictionary:
			var dictionary: Dictionary = current
			if not dictionary.has(raw_key):
				return {"found": false, "value": null}
			current = dictionary[raw_key]
		elif current is Array and _is_exact_int(raw_key):
			var array: Array = current
			var array_index: int = raw_key
			if array_index < 0 or array_index >= array.size():
				return {"found": false, "value": null}
			current = array[array_index]
		else:
			return {"found": false, "value": null}
	return {"found": true, "value": current}


func _array_has_exact(values: Variant, target: Variant) -> bool:
	if not values is Array:
		return false
	for value in values:
		if _same(value, target):
			return true
	return false


func _same(left: Variant, right: Variant) -> bool:
	if typeof(left) != typeof(right):
		return false
	if left is Dictionary:
		var left_dictionary: Dictionary = left
		var right_dictionary: Dictionary = right
		if left_dictionary.size() != right_dictionary.size():
			return false
		for key in left_dictionary:
			if not right_dictionary.has(key) or not _same(left_dictionary[key], right_dictionary[key]):
				return false
		return true
	if left is Array:
		var left_array: Array = left
		var right_array: Array = right
		if left_array.size() != right_array.size():
			return false
		for index in range(left_array.size()):
			if not _same(left_array[index], right_array[index]):
				return false
		return true
	return left == right


func _copy(value: Variant) -> Variant:
	return value.duplicate(true) if value is Dictionary or value is Array else value


func _has_exact_keys(value: Dictionary, expected: Array) -> bool:
	if value.size() != expected.size():
		return false
	for key in expected:
		if not value.has(key):
			return false
	return true


func _has_allowed_keys(value: Dictionary, allowed: Array) -> bool:
	for key in value:
		if key not in allowed:
			return false
	return true


func _is_exact_int(value: Variant) -> bool:
	return typeof(value) == TYPE_INT


func _is_integer_key(key: String) -> bool:
	return (
		key in ["index", "month", "order", "cursor", "sequence"]
		or key.ends_with("_index")
		or key.ends_with("_month")
		or key.ends_with("_months")
		or key.ends_with("_days")
		or key.ends_with("_krw")
		or key.ends_with("_basis_points")
	)


func _configured() -> bool:
	return not _contract.is_empty()


func _mutation_result(state: Dictionary, emitted: Array, replayed: bool) -> Dictionary:
	return _ok({
		"state": state.duplicate(true),
		"emitted_receipts": emitted.duplicate(true),
		"next": _next_descriptor(state),
		"replayed": replayed,
	})


func _state_result(state: Dictionary) -> Dictionary:
	return _ok({"state": state.duplicate(true)})


func _fail_with_state(code: String, message: String, state: Dictionary) -> Dictionary:
	var failed := _fail(code, message)
	failed["state"] = state.duplicate(true)
	failed["emitted_receipts"] = []
	failed["next"] = _next_descriptor(state) if bool(state.get("started", false)) else {}
	return failed


func _ok(extra: Dictionary = {}) -> Dictionary:
	var result := {"ok": true, "error_code": "", "error": ""}
	for key in extra:
		result[key] = extra[key]
	return result


func _fail(code: String, message: String) -> Dictionary:
	return {"ok": false, "error_code": code, "error": message}
