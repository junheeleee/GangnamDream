extends Node

const MANIFEST_PATH := "res://content/meta/year5_reference_routes.json"
const KERNEL_PATH := "res://systems/Year5ReferenceRouteKernel.gd"
const Year5ReferenceRouteKernel := preload(KERNEL_PATH)

const CAREER_ROUTE := "career_reference_v1"
const STARTUP_ROUTE := "startup_acquisition_reference_v1"

var _manifest: Dictionary = {}
var _failures: Array[String] = []
var _checks := 0


func _ready() -> void:
	_manifest = _read_manifest()
	_expect(not _manifest.is_empty(), "manifest loads")
	if not _manifest.is_empty():
		_run_route_trace(CAREER_ROUTE)
		_run_route_trace(STARTUP_ROUTE)
		_run_terminal_contract()
		_run_entry_rejections()
		_run_kernel_rejections()
	if _failures.is_empty():
		print("YEAR5_REFERENCE_ROUTE_R1_CHECK_OK checks=%d routes=2 roots=18 choices=50 dispatch=0" % _checks)
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("YEAR5_REFERENCE_ROUTE_R1_CHECK_FAIL: " + failure)
	print("YEAR5_REFERENCE_ROUTE_R1_CHECK_FAIL count=%d checks=%d" % [_failures.size(), _checks])
	get_tree().quit(1)


func _read_manifest() -> Dictionary:
	if not FileAccess.file_exists(MANIFEST_PATH):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
	return (parsed as Dictionary).duplicate(true) if parsed is Dictionary else {}


func _run_route_trace(route_id: String) -> void:
	var contract := _normalized_contract(route_id)
	var kernel = Year5ReferenceRouteKernel.new()
	_expect_ok(kernel.configure(contract), route_id + " configure")
	var initial := kernel.initial_state()
	_expect_ok(initial, route_id + " initial state")
	if not bool(initial.get("ok", false)):
		return
	var state: Dictionary = (initial.get("state", {}) as Dictionary).duplicate(true)
	var fixture := _entry_fixture(route_id)
	var begun: Dictionary = kernel.begin_route(
		state, fixture["entry_snapshot"], fixture["m48_receipt"], fixture["route_lock"])
	_expect_ok(begun, route_id + " begin")
	if not bool(begun.get("ok", false)):
		return
	state = (begun["state"] as Dictionary).duplicate(true)
	_expect_next(begun, "root", _root_ids(route_id)[0], route_id + " first root")

	var replay_begin: Dictionary = kernel.begin_route(
		state, fixture["entry_snapshot"], fixture["m48_receipt"], fixture["route_lock"])
	_expect_ok(replay_begin, route_id + " exact begin replay")
	_expect(bool(replay_begin.get("replayed", false)), route_id + " begin replay is no-op")
	_expect((replay_begin.get("emitted_receipts", []) as Array).is_empty(), route_id + " begin replay emits nothing")
	var conflicting_lock: Dictionary = (fixture["route_lock"] as Dictionary).duplicate(true)
	conflicting_lock["route_id"] = "conflicting_route"
	_expect_code(kernel.begin_route(
		state, fixture["entry_snapshot"], fixture["m48_receipt"], conflicting_lock),
		"route_already_started", route_id + " conflicting begin")

	var roots := _root_ids(route_id)
	var first_root_id := str(roots[0])
	var first_evidence := _step_evidence(route_id, first_root_id)
	for invalid_index in [false, 0.0, "0"]:
		_expect_code(kernel.commit_choice(state, first_root_id, invalid_index, first_evidence),
			"choice_invalid", route_id + " rejects non-integer choice index " + str(invalid_index))
	for index in range(6):
		var root_id := str(roots[index])
		var evidence := _step_evidence(route_id, root_id)
		if route_id == CAREER_ROUTE and index == 0:
			var changed_job := evidence.duplicate(true)
			changed_job["current_job_id"] = "job_04"
			_expect_code(kernel.commit_choice(state, root_id, 0, changed_job),
				"requirements_unmet", "career bound job change invalidates")
		if index == 0:
			var invented_scene_actor := evidence.duplicate(true)
			invented_scene_actor["scene_actor_bindings"] = {"proposer":
				"boss" if route_id == CAREER_ROUTE else "acquirer_lead"}
			_expect_code(kernel.commit_choice(state, root_id, 0, invented_scene_actor),
				"evidence_schema", route_id + " M49 has no physical proposer")
		if index == 5:
			var wrong_scene_actor := evidence.duplicate(true)
			wrong_scene_actor["scene_actor_bindings"] = (evidence["scene_actor_bindings"] as Dictionary).duplicate(true)
			wrong_scene_actor["scene_actor_bindings"]["proposer"] = "wrong_actor"
			_expect_code(kernel.commit_choice(state, root_id, 0, wrong_scene_actor),
				"evidence_schema", route_id + " M52 actor confirmation")
		var chosen: Dictionary = kernel.commit_choice(state, root_id, 0, evidence)
		_expect_ok(chosen, "%s root %d" % [route_id, index])
		if not bool(chosen.get("ok", false)):
			return
		state = (chosen["state"] as Dictionary).duplicate(true)
		_expect_dispatch_off(chosen, "%s root %d" % [route_id, index])
		if index == 0:
			var replay_choice: Dictionary = kernel.commit_choice(state, root_id, 0, evidence)
			_expect_ok(replay_choice, route_id + " exact choice replay")
			_expect(bool(replay_choice.get("replayed", false)), route_id + " choice replay is no-op")
			var changed_evidence := evidence.duplicate(true)
			changed_evidence["scene_actor_bindings"] = {"forged": "actor"}
			_expect_code(kernel.commit_choice(state, root_id, 0, changed_evidence),
				"callback_conflict", route_id + " changed evidence replay")
			_expect_code(kernel.commit_choice(state, root_id, 1, evidence),
				"callback_conflict", route_id + " changed choice replay")

	var next_at_m53: Dictionary = kernel.next_step(state)
	_expect_next(next_at_m53, "external_blocker", _blocker_id(route_id, "m53"), route_id + " stops at M53")
	_expect(_has_unconsumed_fact(state, "margin:m52_cash"), route_id + " M53 does not invent cash expiry")
	_expect_code(kernel.commit_choice(state, str(roots[6]), 0),
		"step_mismatch", route_id + " cannot skip M53")

	var m53_receipt := _external_receipt(route_id, "m53")
	var forged_m53 := m53_receipt.duplicate(true)
	forged_m53["outcome_writes"] = ["forged_guarantee"]
	_expect_code(kernel.commit_external_receipt(
		state, _blocker_id(route_id, "m53"), forged_m53),
		"receipt_schema", route_id + " forged M53 outcome")
	var m53_result: Dictionary = kernel.commit_external_receipt(
		state, _blocker_id(route_id, "m53"), m53_receipt)
	_expect_ok(m53_result, route_id + " synthetic M53 handoff")
	if not bool(m53_result.get("ok", false)):
		return
	state = (m53_result["state"] as Dictionary).duplicate(true)
	_expect_next(m53_result, "external_blocker", _blocker_id(route_id, "m54"), route_id + " custody blocker")
	var replay_external: Dictionary = kernel.commit_external_receipt(
		state, _blocker_id(route_id, "m53"), m53_receipt)
	_expect_ok(replay_external, route_id + " exact external replay")
	_expect(bool(replay_external.get("replayed", false)), route_id + " external replay is no-op")
	var changed_external := m53_receipt.duplicate(true)
	changed_external["month"] = 99
	_expect_code(kernel.commit_external_receipt(
		state, _blocker_id(route_id, "m53"), changed_external),
		"callback_conflict", route_id + " changed external replay")

	var custody := _external_receipt(route_id, "m54")
	var wrong_holder := custody.duplicate(true)
	wrong_holder["from_holder"] = "wrong_holder"
	_expect_code(kernel.commit_external_receipt(
		state, _blocker_id(route_id, "m54"), wrong_holder),
		"receipt_schema", route_id + " wrong custody holder")
	var custody_result: Dictionary = kernel.commit_external_receipt(
		state, _blocker_id(route_id, "m54"), custody)
	_expect_ok(custody_result, route_id + " synthetic reviewer custody")
	if not bool(custody_result.get("ok", false)):
		return
	state = (custody_result["state"] as Dictionary).duplicate(true)

	for index in range(6, 9):
		var root_id := str(roots[index])
		var chosen: Dictionary = kernel.commit_choice(
			state, root_id, 0, _step_evidence(route_id, root_id))
		_expect_ok(chosen, "%s resumed root %d" % [route_id, index])
		if not bool(chosen.get("ok", false)):
			return
		state = (chosen["state"] as Dictionary).duplicate(true)
		_expect_dispatch_off(chosen, "%s resumed root %d" % [route_id, index])
	_expect_next(kernel.next_step(state), "awaiting_r2", "", route_id + " awaits R2")
	_expect((state.get("history", []) as Array).size() == 12, route_id + " immutable history row count")

	var normalized: Dictionary = kernel.normalize_state(state["history"])
	_expect_ok(normalized, route_id + " history normalization")
	for invalid_sequence in [false, 0.0, "0"]:
		var typed_history: Array = (state["history"] as Array).duplicate(true)
		var begin_row: Dictionary = (typed_history[0] as Dictionary).duplicate(true)
		begin_row["sequence"] = invalid_sequence
		typed_history[0] = begin_row
		_expect_code(kernel.normalize_state(typed_history),
			"history_tampered", route_id + " sequence type " + str(invalid_sequence))
	for invalid_choice_index in [false, 0.0, "0"]:
		var typed_history: Array = (state["history"] as Array).duplicate(true)
		var first_choice_row: Dictionary = (typed_history[1] as Dictionary).duplicate(true)
		first_choice_row["choice_index"] = invalid_choice_index
		typed_history[1] = first_choice_row
		_expect_code(kernel.normalize_state(typed_history),
			"history_tampered", route_id + " history choice type " + str(invalid_choice_index))
	var duplicate_history: Array = (state["history"] as Array).duplicate(true)
	var duplicate_row: Dictionary = (duplicate_history.back() as Dictionary).duplicate(true)
	duplicate_row["sequence"] = duplicate_history.size()
	duplicate_history.append(duplicate_row)
	_expect_code(kernel.normalize_state(duplicate_history),
		"history_duplicate", route_id + " persisted duplicate row")
	var partial_history: Array = (state["history"] as Array).duplicate(true)
	var choice_row: Dictionary = (partial_history[1] as Dictionary).duplicate(true)
	var emitted: Array = (choice_row["emitted_receipts"] as Array).duplicate(true)
	if not emitted.is_empty():
		emitted.pop_back()
	choice_row["emitted_receipts"] = emitted
	partial_history[1] = choice_row
	_expect_code(kernel.normalize_state(partial_history),
		"history_tampered", route_id + " partial atomic history")
	var tampered_state := state.duplicate(true)
	(tampered_state["facts"] as Dictionary)["forged"] = {"kind": "flag", "value": true}
	_expect_code(kernel.snapshot(tampered_state), "state_tampered", route_id + " derived state tamper")


func _run_terminal_contract() -> void:
	var contract := _normalized_contract(STARTUP_ROUTE)
	var kernel = Year5ReferenceRouteKernel.new()
	_expect_ok(kernel.configure(contract), "startup terminal configure")
	var state: Dictionary = kernel.initial_state()["state"]
	var fixture := _entry_fixture(STARTUP_ROUTE)
	var begun: Dictionary = kernel.begin_route(
		state, fixture["entry_snapshot"], fixture["m48_receipt"], fixture["route_lock"])
	_expect_ok(begun, "startup terminal begin")
	state = begun["state"]
	var roots := _root_ids(STARTUP_ROUTE)
	for index in range(5):
		var root_id := str(roots[index])
		var chosen: Dictionary = kernel.commit_choice(
			state, root_id, 0, _step_evidence(STARTUP_ROUTE, root_id))
		_expect_ok(chosen, "startup terminal prefix %d" % index)
		if not bool(chosen.get("ok", false)):
			return
		state = chosen["state"]
	var terminal_root := str(roots[5])
	var terminal_evidence := _step_evidence(STARTUP_ROUTE, terminal_root)
	var terminal: Dictionary = kernel.commit_choice(state, terminal_root, 3, terminal_evidence)
	_expect_ok(terminal, "startup M52 C4 terminal")
	if not bool(terminal.get("ok", false)):
		return
	state = terminal["state"]
	_expect_next(terminal, "terminal", "startup_m52_offer_terminal", "startup M52 terminal next")
	_expect(not _has_source_token(state, "document:h1:91B4"), "startup terminal has no h1")
	_expect(not _has_source_token(state, "document_holder:h1:acquirer_lead"), "startup terminal has no h1 custody")
	var replay_terminal: Dictionary = kernel.commit_choice(state, terminal_root, 3, terminal_evidence)
	_expect_ok(replay_terminal, "startup terminal exact replay")
	_expect(bool(replay_terminal.get("replayed", false)), "startup terminal replay is no-op")
	_expect((replay_terminal.get("emitted_receipts", []) as Array).is_empty(), "startup terminal replay emits nothing")
	_expect_next(replay_terminal, "terminal", "startup_m52_offer_terminal", "startup terminal replay next")
	_expect_code(kernel.commit_choice(
		state, str(roots[6]), 0, _step_evidence(STARTUP_ROUTE, str(roots[6]))),
		"terminal_reached", "startup terminal has no downstream")


func _run_entry_rejections() -> void:
	for route_id in [CAREER_ROUTE, STARTUP_ROUTE]:
		var contract := _normalized_contract(route_id)
		var fixture := _entry_fixture(route_id)
		_expect_begin_rejected(contract, fixture, null, "entry_invalid", route_id + " explicit lock required")
		var wrong_axis := fixture.duplicate(true)
		wrong_axis["m48_receipt"] = (fixture["m48_receipt"] as Dictionary).duplicate(true)
		wrong_axis["m48_receipt"]["axis"] = "cash"
		_expect_begin_rejected(contract, wrong_axis, fixture["route_lock"], "entry_invalid", route_id + " M48 axis")
		var wrong_expiry := fixture.duplicate(true)
		wrong_expiry["m48_receipt"] = (fixture["m48_receipt"] as Dictionary).duplicate(true)
		wrong_expiry["m48_receipt"]["expires_after_month"] = 50
		_expect_begin_rejected(contract, wrong_expiry, fixture["route_lock"], "entry_invalid", route_id + " M48 expiry")
		var wrong_actor := fixture.duplicate(true)
		wrong_actor["m48_receipt"] = (fixture["m48_receipt"] as Dictionary).duplicate(true)
		wrong_actor["m48_receipt"]["actor_id"] = "minseo"
		_expect_begin_rejected(contract, wrong_actor, fixture["route_lock"], "entry_invalid", route_id + " M48 actor")
		var extra_m48 := fixture.duplicate(true)
		extra_m48["m48_receipt"] = (fixture["m48_receipt"] as Dictionary).duplicate(true)
		extra_m48["m48_receipt"]["forged"] = true
		_expect_begin_rejected(contract, extra_m48, fixture["route_lock"], "entry_invalid", route_id + " M48 exact keys")
		var wrong_m48_type := fixture.duplicate(true)
		wrong_m48_type["m48_receipt"] = (fixture["m48_receipt"] as Dictionary).duplicate(true)
		wrong_m48_type["m48_receipt"]["producer_month"] = "48"
		_expect_begin_rejected(contract, wrong_m48_type, fixture["route_lock"], "entry_invalid", route_id + " M48 value type")
		var extra_partner := fixture.duplicate(true)
		extra_partner["entry_snapshot"] = (fixture["entry_snapshot"] as Dictionary).duplicate(true)
		extra_partner["entry_snapshot"]["partner_receipt"] = (fixture["entry_snapshot"]["partner_receipt"] as Dictionary).duplicate(true)
		extra_partner["entry_snapshot"]["partner_receipt"]["forged"] = true
		_expect_begin_rejected(contract, extra_partner, fixture["route_lock"], "entry_invalid", route_id + " partner exact keys")
		var wrong_partner_type := fixture.duplicate(true)
		wrong_partner_type["entry_snapshot"] = (fixture["entry_snapshot"] as Dictionary).duplicate(true)
		wrong_partner_type["entry_snapshot"]["partner_receipt"] = "none"
		_expect_begin_rejected(contract, wrong_partner_type, fixture["route_lock"], "entry_invalid", route_id + " partner receipt type")
		var wrong_path := fixture.duplicate(true)
		wrong_path["entry_snapshot"] = (fixture["entry_snapshot"] as Dictionary).duplicate(true)
		wrong_path["entry_snapshot"]["economic_path"] = "startup" if route_id == CAREER_ROUTE else "career"
		_expect_begin_rejected(contract, wrong_path, fixture["route_lock"], "entry_invalid", route_id + " economic path")
		var extra_lock: Dictionary = (fixture["route_lock"] as Dictionary).duplicate(true)
		extra_lock["forged"] = true
		_expect_begin_rejected(contract, fixture, extra_lock, "entry_invalid", route_id + " route lock exact keys")
		_expect_begin_rejected(contract, fixture, route_id, "entry_invalid", route_id + " route lock wrong type")

	var career_contract := _normalized_contract(CAREER_ROUTE)
	var career := _entry_fixture(CAREER_ROUTE)
	var no_job := career.duplicate(true)
	no_job["entry_snapshot"] = (career["entry_snapshot"] as Dictionary).duplicate(true)
	no_job["entry_snapshot"]["flags"] = {"has_job": false}
	_expect_begin_rejected(career_contract, no_job, career["route_lock"], "entry_invalid", "career has_job")
	var numeric_has_job := career.duplicate(true)
	numeric_has_job["entry_snapshot"] = (career["entry_snapshot"] as Dictionary).duplicate(true)
	numeric_has_job["entry_snapshot"]["flags"] = (career["entry_snapshot"]["flags"] as Dictionary).duplicate(true)
	numeric_has_job["entry_snapshot"]["flags"]["has_job"] = 1
	_expect_begin_rejected(career_contract, numeric_has_job, career["route_lock"], "entry_invalid", "career has_job type")
	var wrong_job := career.duplicate(true)
	wrong_job["entry_snapshot"] = (career["entry_snapshot"] as Dictionary).duplicate(true)
	wrong_job["entry_snapshot"]["current_job"] = {"id": "job_01"}
	_expect_begin_rejected(career_contract, wrong_job, career["route_lock"], "entry_invalid", "career compatible job")

	var startup_contract := _normalized_contract(STARTUP_ROUTE)
	var startup := _entry_fixture(STARTUP_ROUTE)
	var missing_cofounder := startup.duplicate(true)
	missing_cofounder["entry_snapshot"] = (startup["entry_snapshot"] as Dictionary).duplicate(true)
	missing_cofounder["entry_snapshot"].erase("startup_founding")
	_expect_begin_rejected(startup_contract, missing_cofounder, startup["route_lock"], "entry_invalid", "startup founding receipt")
	var extra_founding := startup.duplicate(true)
	extra_founding["entry_snapshot"] = (startup["entry_snapshot"] as Dictionary).duplicate(true)
	extra_founding["entry_snapshot"]["startup_founding"] = (startup["entry_snapshot"]["startup_founding"] as Dictionary).duplicate(true)
	extra_founding["entry_snapshot"]["startup_founding"]["forged"] = true
	_expect_begin_rejected(startup_contract, extra_founding, startup["route_lock"], "entry_invalid", "startup founding exact keys")
	var wrong_founding_type := startup.duplicate(true)
	wrong_founding_type["entry_snapshot"] = (startup["entry_snapshot"] as Dictionary).duplicate(true)
	wrong_founding_type["entry_snapshot"]["startup_founding"] = []
	_expect_begin_rejected(startup_contract, wrong_founding_type, startup["route_lock"], "entry_invalid", "startup founding type")
	var legacy_collision := startup.duplicate(true)
	legacy_collision["entry_snapshot"] = (startup["entry_snapshot"] as Dictionary).duplicate(true)
	legacy_collision["entry_snapshot"]["legacy_acquisition_consumed"] = true
	_expect_begin_rejected(startup_contract, legacy_collision, startup["route_lock"], "entry_invalid", "startup legacy collision")
	var numeric_absent_flag := startup.duplicate(true)
	numeric_absent_flag["entry_snapshot"] = (startup["entry_snapshot"] as Dictionary).duplicate(true)
	numeric_absent_flag["entry_snapshot"]["flags"] = (startup["entry_snapshot"]["flags"] as Dictionary).duplicate(true)
	numeric_absent_flag["entry_snapshot"]["flags"]["startup_exit"] = 0
	_expect_begin_rejected(startup_contract, numeric_absent_flag, startup["route_lock"], "entry_invalid", "startup absent flag type")
	var string_legacy_flag := startup.duplicate(true)
	string_legacy_flag["entry_snapshot"] = (startup["entry_snapshot"] as Dictionary).duplicate(true)
	string_legacy_flag["entry_snapshot"]["legacy_acquisition_consumed"] = ""
	_expect_begin_rejected(startup_contract, string_legacy_flag, startup["route_lock"], "entry_invalid", "startup legacy flag type")


func _run_kernel_rejections() -> void:
	var base := _normalized_contract(CAREER_ROUTE)
	var wrong_count := base.duplicate(true)
	(wrong_count["steps"] as Array).pop_back()
	var kernel = Year5ReferenceRouteKernel.new()
	_expect_code(kernel.configure(wrong_count), "contract_schema", "contract root count")

	var wrong_blocker := base.duplicate(true)
	var steps: Array = wrong_blocker["steps"]
	var swap: Variant = steps[5]
	steps[5] = steps[6]
	steps[6] = swap
	_expect_code(Year5ReferenceRouteKernel.new().configure(wrong_blocker),
		"contract_schema", "contract blocker position")

	var wrong_month_type := base.duplicate(true)
	wrong_month_type["steps"][0]["month"] = 49.0
	_expect_code(Year5ReferenceRouteKernel.new().configure(wrong_month_type),
		"contract_schema", "contract month type")
	var wrong_choice_type := base.duplicate(true)
	wrong_choice_type["steps"][0]["choices"][0]["index"] = false
	_expect_code(Year5ReferenceRouteKernel.new().configure(wrong_choice_type),
		"contract_schema", "contract choice index type")

	var duplicate_actor := base.duplicate(true)
	duplicate_actor["entry"]["actor_bindings"]["reviewer"] = {
		"$source": "m48_receipt", "path": ["actor_id"]}
	var duplicate_kernel = Year5ReferenceRouteKernel.new()
	_expect_ok(duplicate_kernel.configure(duplicate_actor), "duplicate actor contract config")
	var fixture := _entry_fixture(CAREER_ROUTE)
	var state: Dictionary = duplicate_kernel.initial_state()["state"]
	_expect_code(duplicate_kernel.begin_route(
		state, fixture["entry_snapshot"], fixture["m48_receipt"], fixture["route_lock"]),
		"actor_duplicate", "actor groups distinct")

	var partial_batch := base.duplicate(true)
	var first_root: Dictionary = partial_batch["steps"][0]
	var marker: Dictionary = (first_root["common_writes"] as Array).back()
	(first_root["choices"][0]["writes"] as Array).append(marker.duplicate(true))
	var partial_kernel = Year5ReferenceRouteKernel.new()
	_expect_ok(partial_kernel.configure(partial_batch), "partial batch contract config")
	state = partial_kernel.initial_state()["state"]
	var begun: Dictionary = partial_kernel.begin_route(
		state, fixture["entry_snapshot"], fixture["m48_receipt"], fixture["route_lock"])
	_expect_ok(begun, "partial batch begin")
	var before_history := (begun["state"]["history"] as Array).size()
	var first_root_id := str(_root_ids(CAREER_ROUTE)[0])
	var failed: Dictionary = partial_kernel.commit_choice(
		begun["state"], first_root_id, 0, _step_evidence(CAREER_ROUTE, first_root_id))
	_expect_code(failed, "write_conflict", "partial atomic write rejected")
	_expect((failed["state"]["history"] as Array).size() == before_history, "partial atomic write rolls back")

	var double_spend := base.duplicate(true)
	var third_root: Dictionary = double_spend["steps"][2]
	(third_root["common_writes"] as Array).append(_consume("margin:m48_trust", "margin", "trust"))
	var spend_kernel = Year5ReferenceRouteKernel.new()
	_expect_ok(spend_kernel.configure(double_spend), "double spend contract config")
	state = spend_kernel.initial_state()["state"]
	begun = spend_kernel.begin_route(
		state, fixture["entry_snapshot"], fixture["m48_receipt"], fixture["route_lock"])
	state = begun["state"]
	for index in range(2):
		var root_id := str(_root_ids(CAREER_ROUTE)[index])
		var chosen: Dictionary = spend_kernel.commit_choice(
			state, root_id, 0, _step_evidence(CAREER_ROUTE, root_id))
		_expect_ok(chosen, "double spend prefix %d" % index)
		state = chosen["state"]
	var third_root_id := str(_root_ids(CAREER_ROUTE)[2])
	_expect_code(spend_kernel.commit_choice(
		state, third_root_id, 0, _step_evidence(CAREER_ROUTE, third_root_id)),
		"fact_consumed", "margin double spend")

	var missing_document := base.duplicate(true)
	var cover_writes: Array = missing_document["steps"][0]["common_writes"]
	for index in range(cover_writes.size() - 1, -1, -1):
		if str((cover_writes[index] as Dictionary).get("value", "")) == "document:C0":
			cover_writes.remove_at(index)
	var causal_kernel = Year5ReferenceRouteKernel.new()
	_expect_ok(causal_kernel.configure(missing_document), "missing document contract config")
	state = causal_kernel.initial_state()["state"]
	begun = causal_kernel.begin_route(
		state, fixture["entry_snapshot"], fixture["m48_receipt"], fixture["route_lock"])
	state = begun["state"]
	first_root_id = str(_root_ids(CAREER_ROUTE)[0])
	var first_choice: Dictionary = causal_kernel.commit_choice(
		state, first_root_id, 0, _step_evidence(CAREER_ROUTE, first_root_id))
	_expect_ok(first_choice, "missing document producer scene")
	state = first_choice["state"]
	var reader_root_id := str(_root_ids(CAREER_ROUTE)[1])
	_expect_code(causal_kernel.commit_choice(
		state, reader_root_id, 0, _step_evidence(CAREER_ROUTE, reader_root_id)),
		"requirements_unmet", "document reader requires prior producer")


func _normalized_contract(route_id: String) -> Dictionary:
	var source_route := _source_route(route_id)
	var root_ids := _root_ids(route_id)
	var root_by_id: Dictionary = {}
	for raw_root in (source_route.get("roots", []) as Array):
		var root: Dictionary = raw_root
		root_by_id[str(root.get("id", ""))] = root
	var steps: Array = []
	for index in range(6):
		steps.append(_normalized_root(root_by_id[str(root_ids[index])], index, route_id))
	steps.append(_normalized_blocker(route_id, "m53", str(root_ids[5])))
	steps.append(_normalized_blocker(route_id, "m54", _blocker_id(route_id, "m53")))
	for index in range(6, 9):
		steps.append(_normalized_root(root_by_id[str(root_ids[index])], index, route_id))
	return {
		"schema_version": 1,
		"contract_id": route_id + ":r1a",
		"entry": _normalized_entry(route_id),
		"steps": steps,
	}


func _normalized_entry(route_id: String) -> Dictionary:
	var partner_receipt := _ingress_constants("partner_none")
	var route_lock_receipt := _route_lock_receipt(route_id)
	var m48_receipts := _m48_receipts(route_id)
	var requirements: Array = [
		_rule("explicit_route_lock", [], "equals", route_lock_receipt),
		_rule("entry_snapshot", ["economic_path"], "equals",
			str(_source_route(route_id)["entry"]["required_economic_path"])),
		_rule("entry_snapshot", ["partner_receipt"], "equals", partner_receipt),
		_rule("entry_snapshot", ["route_role_handles", "proposer"], "equals",
			"boss" if route_id == CAREER_ROUTE else "acquirer_lead"),
		_rule("m48_receipt", [], "in", m48_receipts),
	]
	if route_id == CAREER_ROUTE:
		requirements.append(_rule("entry_snapshot", ["flags", "has_job"], "equals", true))
		requirements.append(_rule("entry_snapshot", ["current_job", "id"], "in",
			_source_route(route_id)["entry"]["compatible_job_ids"]))
	else:
		for flag_id in ["startup_exit", "startup_partial_exit", "startup_going_solo", "joined_startup"]:
			requirements.append(_rule("entry_snapshot", ["flags", flag_id], "equals", false))
		requirements.append(_rule("entry_snapshot", ["legacy_acquisition_consumed"], "equals", false))
		requirements.append(_rule("entry_snapshot", ["legacy_acquisition_declined"], "equals", false))
		requirements.append(_rule("entry_snapshot", ["startup_founding"], "equals",
			_ingress_constants("startup_founding")))
	var proposer_value := {"$source": "entry_snapshot", "path": ["route_role_handles", "proposer"]}
	var protected_value := {"$source": "m48_receipt", "path": ["actor_id"]}
	var writes: Array = [
		_emit("route_lock", "route_lock", {
			"$source": "explicit_route_lock", "path": []}),
		_emit("partner_none", "relationship", {
			"$source": "entry_snapshot", "path": ["partner_receipt"]}),
		_emit("margin:m48_trust", "margin", "trust"),
	]
	if route_id == CAREER_ROUTE:
		writes.append(_emit("bound_job_id", "job_binding", {
			"$source": "entry_snapshot", "path": ["current_job", "id"]}))
	else:
		writes.append(_emit("startup_founding", "origin", {
			"$source": "entry_snapshot", "path": ["startup_founding"]}))
	return {
		"requirements": requirements,
		"writes": writes,
		"actor_bindings": {
			"proposer_role": proposer_value,
			"counterparty_role": proposer_value,
			"reviewer": "minseo",
			"protected": protected_value,
			"affected": protected_value,
			"primary_witness": protected_value,
		},
		"same_actor_groups": [
			["proposer_role", "counterparty_role"],
			["reviewer"],
			["protected", "affected", "primary_witness"],
		],
	}


func _normalized_root(source: Dictionary, source_index: int, route_id: String) -> Dictionary:
	var root_id := str(source["id"])
	var requirements: Array = _root_causal_requirements(source, source_index, route_id)
	var previous_key := _previous_marker(route_id, source_index)
	if not previous_key.is_empty():
		requirements.push_front(_rule("facts", [previous_key], "exists"))
	var evidence_schema := _step_evidence_schema(route_id, root_id)
	var common_writes: Array = []
	var common_source_writes: Array = source.get("common_writes", [])
	for token_index in range(common_source_writes.size()):
		common_writes.append(_source_emit(
			str(common_source_writes[token_index]),
			root_id))
	if source_index == 1:
		common_writes.append(_consume("margin:m48_trust", "margin", "trust"))
	elif source_index == 2:
		common_writes.append(_emit("margin:m50_trust", "margin", "trust"))
	elif source_index == 4:
		common_writes.append(_consume("margin:m50_trust", "margin", "trust"))
	elif source_index == 5:
		common_writes.append(_emit("margin:m52_cash", "margin", "cash"))
	elif source_index == 6:
		common_writes.append(_emit("margin:m54_trust", "margin", "trust"))
	elif source_index == 8:
		common_writes.append(_consume("margin:m54_trust", "margin", "trust"))
	if source_index == 5:
		common_writes.append(_emit("confirmed_actor:proposer", "actor_confirmation", {
			"$source": "step_evidence", "path": ["scene_actor_bindings", "proposer"]}))
		common_writes.append(_emit("confirmed_actor:counterparty", "actor_confirmation", {
			"$source": "step_evidence", "path": ["scene_actor_bindings", "counterparty"]}))
	common_writes.append(_emit("step:" + root_id, "step", root_id))
	var choices: Array = []
	for raw_choice in (source.get("choices", []) as Array):
		var choice: Dictionary = raw_choice
		var writes: Array = []
		var choice_source_writes: Array = choice.get("writes", [])
		for token_index in range(choice_source_writes.size()):
			writes.append(_source_emit(
				str(choice_source_writes[token_index]),
				root_id))
		choices.append({
			"index": int(choice["index"]),
			"outcome_id": str(choice["outcome_id"]),
			"flow": str(choice["flow"]),
			"requirements": [],
			"writes": writes,
		})
	return {
		"kind": "root",
		"id": root_id,
		"month": int(source["month"]),
		"order": int(source["order"]),
		"evidence_schema": evidence_schema,
		"requirements": requirements,
		"common_writes": common_writes,
		"choices": choices,
	}


func _normalized_blocker(route_id: String, slot: String, previous_id: String) -> Dictionary:
	var blocker_id := _blocker_id(route_id, slot)
	var source: Dictionary = _manifest["r1a_contract"]["external_blockers"][blocker_id]
	var schema := _canonicalize_exact_schema(source["receipt_schema"])
	var constants: Dictionary = schema["constants"]
	var writes: Array = [
		_emit("external:" + blocker_id, "external_receipt", {
			"$source": "receipt", "path": []}),
		_emit("step:" + blocker_id, "step", blocker_id),
	]
	if str(constants.get("receipt_type", "")) == "document_custody_handoff":
		writes.append(_emit(
			"custody:" + str(constants.get("document_version", "")) + ":minseo",
			"document_custody", "minseo"))
	return {
		"kind": "external_blocker",
		"id": blocker_id,
		"month": 53 if slot == "m53" else 54,
		"source": str(constants["source_kind"]),
		"synthetic_fixture_only": true,
		"receipt_schema": schema,
		"requirements": [_rule("facts", ["step:" + previous_id], "exists")],
		"writes": writes,
	}


func _previous_marker(route_id: String, source_index: int) -> String:
	var roots := _root_ids(route_id)
	if source_index == 0:
		return "route_lock"
	if source_index == 6:
		return "step:" + _blocker_id(route_id, "m54")
	return "step:" + str(roots[source_index - 1])


func _source_emit(token: String, producer_scope: String) -> Dictionary:
	var kind := token.get_slice(":", 0)
	return _emit("source:%s:%s" % [producer_scope, token], kind, token)


func _root_causal_requirements(source: Dictionary, source_index: int, route_id: String) -> Array:
	var requirements: Array = []
	var root_id := str(source["id"])
	var route_contract: Dictionary = _manifest["r1a_contract"]["routes"][route_id]
	for role_value in (route_contract["required_route_roles"][root_id] as Array):
		var role := str(role_value)
		var actor_key := role + "_role" if role in ["proposer", "counterparty"] else role
		requirements.append(_rule("role_handles", [actor_key], "exists"))
	if route_id == CAREER_ROUTE:
		requirements.append(_rule("step_evidence", ["flags_has_job"], "equals", true))
		requirements.append(_equals_path_rule(
			"step_evidence", ["current_job_id"], "facts", ["bound_job_id", "value"]))
	for role_value in (route_contract["scene_actor_roles"][root_id] as Array):
		var role := str(role_value)
		var actor_key := role + "_role" if role in ["proposer", "counterparty"] else role
		requirements.append(_equals_path_rule(
			"step_evidence", ["scene_actor_bindings", role], "role_handles", [actor_key]))
	for document_value in (source.get("document_reads", []) as Array):
		var document_version := str(document_value)
		var document_token := _latest_document_token(route_id, source_index, document_version)
		if not document_token.is_empty():
			requirements.append(_rule("facts", [_source_fact_key(
				_latest_source_root(route_id, source_index, document_token), document_token)], "exists"))
	if source_index == 6:
		var blocker_constants := _external_receipt(route_id, "m54")
		requirements.append(_rule("facts", [
			"custody:%s:minseo" % str(blocker_constants["document_version"])], "exists"))
	if source_index >= 7:
		requirements.append(_rule("facts", ["confirmed_actor:proposer"], "exists"))
	for requirement_value in (source.get("requirements", []) as Array):
		var token := str(requirement_value)
		if token in ["career entry valid", "startup entry valid", "future M48 actor+trust-margin receipt"] \
		or token.begins_with("m49 route lock=") or token.begins_with("actor:") \
		or token.begins_with("actors:"):
			continue
		if token == "margin:m50_draw_name_boundary:trust":
			requirements.append(_rule("facts", ["margin:m50_trust"], "unconsumed"))
			continue
		if token.begins_with("external_receipt:"):
			requirements.append(_rule("facts", ["external:" + token.trim_prefix("external_receipt:")], "exists"))
			continue
		if "|" in token:
			var alternative_root := _alternative_producer_root(route_id, source_index, token)
			if not alternative_root.is_empty():
				requirements.append(_rule("facts", ["step:" + alternative_root], "exists"))
			continue
		var producer_root := _latest_source_root(route_id, source_index, token)
		if not producer_root.is_empty():
			requirements.append(_rule("facts", [_source_fact_key(producer_root, token)], "exists"))
	return requirements


func _step_evidence_schema(route_id: String, root_id: String) -> Dictionary:
	var route_contract: Dictionary = _manifest["r1a_contract"]["routes"][route_id]
	var scene_bindings: Dictionary = {}
	for role_value in (route_contract["scene_actor_roles"][root_id] as Array):
		var role := str(role_value)
		scene_bindings[role] = str(_manifest["actor_registry"][route_id]["bindings"][role]["actor_id"])
	var exact_keys: Array = ["scene_actor_bindings"]
	var constants := {"scene_actor_bindings": scene_bindings}
	var schema := {"exact_keys": exact_keys, "constants": constants}
	if route_id == CAREER_ROUTE:
		exact_keys.append("current_job_id")
		exact_keys.append("flags_has_job")
		constants["flags_has_job"] = true
		schema["allowed_values"] = {
			"current_job_id": (_source_route(route_id)["entry"]["compatible_job_ids"] as Array).duplicate(true)}
	return schema


func _step_evidence(route_id: String, root_id: String) -> Dictionary:
	var schema := _step_evidence_schema(route_id, root_id)
	var evidence: Dictionary = (schema["constants"] as Dictionary).duplicate(true)
	if route_id == CAREER_ROUTE:
		evidence["current_job_id"] = "job_03"
	return evidence


func _source_fact_key(root_id: String, token: String) -> String:
	return "source:%s:%s" % [root_id, token]


func _latest_document_token(route_id: String, before_index: int, document_version: String) -> String:
	for index in range(before_index - 1, -1, -1):
		var root := _source_root(route_id, index)
		for token_value in _all_source_writes(root):
			var token := str(token_value)
			if token.begins_with("document:" + document_version):
				return token
	return ""


func _latest_source_root(route_id: String, before_index: int, token: String) -> String:
	for index in range(before_index - 1, -1, -1):
		var root := _source_root(route_id, index)
		if token in _all_source_writes(root):
			return str(root["id"])
	return ""


func _alternative_producer_root(route_id: String, before_index: int, token: String) -> String:
	var prefix := token.get_slice(":", 0) + ":"
	var alternatives := token.trim_prefix(prefix).split("|")
	var producer := ""
	for alternative_value in alternatives:
		var candidate := _latest_source_root(route_id, before_index, prefix + str(alternative_value))
		if candidate.is_empty() or (not producer.is_empty() and candidate != producer):
			return ""
		producer = candidate
	return producer


func _source_root(route_id: String, index: int) -> Dictionary:
	var wanted_id := str(_root_ids(route_id)[index])
	for raw_root in (_source_route(route_id)["roots"] as Array):
		var root: Dictionary = raw_root
		if str(root["id"]) == wanted_id:
			return root
	return {}


func _all_source_writes(root: Dictionary) -> Array:
	var writes: Array = (root.get("common_writes", []) as Array).duplicate(true)
	for raw_choice in (root.get("choices", []) as Array):
		writes.append_array(((raw_choice as Dictionary).get("writes", []) as Array).duplicate(true))
	return writes


func _has_source_token(state: Dictionary, token: String) -> bool:
	for raw_fact in (state.get("facts", {}) as Dictionary).values():
		if raw_fact is Dictionary and str((raw_fact as Dictionary).get("value", "")) == token:
			return true
	return false


func _emit(key: String, kind: String, value: Variant) -> Dictionary:
	return {"op": "emit", "key": key, "kind": kind, "value": value}


func _consume(key: String, kind: String, value: Variant) -> Dictionary:
	return {"op": "consume", "key": key, "kind": kind, "value": value}


func _rule(source: String, path: Array, op: String, value: Variant = null) -> Dictionary:
	var result := {"source": source, "path": path.duplicate(true), "op": op}
	if op in ["in", "not_in"]:
		result["values"] = (value as Array).duplicate(true)
	elif op not in ["exists", "absent", "truthy", "falsy", "unconsumed"]:
		result["value"] = value
	return result


func _equals_path_rule(
	source: String,
	path: Array,
	other_source: String,
	other_path: Array,
) -> Dictionary:
	return {
		"source": source,
		"path": path.duplicate(true),
		"op": "equals_path",
		"other_source": other_source,
		"other_path": other_path.duplicate(true),
	}


func _entry_fixture(route_id: String) -> Dictionary:
	var entry_snapshot := {
		"economic_path": str(_source_route(route_id)["entry"]["required_economic_path"]),
		"partner_receipt": _ingress_constants("partner_none"),
		"route_role_handles": {"proposer": "boss" if route_id == CAREER_ROUTE else "acquirer_lead"},
		"flags": {"has_job": route_id == CAREER_ROUTE, "startup_exit": false, "startup_partial_exit": false, "startup_going_solo": false, "joined_startup": false},
		"current_job": {"id": "job_03"},
		"legacy_acquisition_consumed": false,
		"legacy_acquisition_declined": false,
	}
	if route_id == STARTUP_ROUTE:
		entry_snapshot["startup_founding"] = _ingress_constants("startup_founding")
	return {
		"entry_snapshot": entry_snapshot,
		"m48_receipt": (_m48_receipts(route_id)[0] as Dictionary).duplicate(true),
		"route_lock": _route_lock_receipt(route_id),
	}


func _ingress_constants(receipt_id: String) -> Dictionary:
	var schema := _canonicalize_exact_schema(
		_manifest["r1a_contract"]["ingress_receipts"][receipt_id]["receipt_schema"])
	return (schema["constants"] as Dictionary).duplicate(true)


func _route_lock_receipt(route_id: String) -> Dictionary:
	var receipt := _ingress_constants("route_lock")
	receipt["route_id"] = route_id
	return receipt


func _m48_receipts(route_id: String) -> Array:
	var schema := _canonicalize_exact_schema(
		_manifest["r1a_contract"]["ingress_receipts"]["m48_actor_trust"]["receipt_schema"])
	var actor_id := str(schema["route_constants"][route_id]["actor_id"])
	var receipts: Array = []
	for choice_index in (schema["allowed_values"]["producer_choice_index"] as Array):
		var receipt: Dictionary = (schema["constants"] as Dictionary).duplicate(true)
		receipt["route_id"] = route_id
		receipt["producer_choice_index"] = int(choice_index)
		receipt["actor_id"] = actor_id
		receipts.append(receipt)
	return receipts


func _canonicalize_exact_schema(raw_schema: Variant) -> Dictionary:
	var schema: Dictionary = (raw_schema as Dictionary).duplicate(true)
	var constants: Dictionary = schema.get("constants", {})
	for key in constants:
		if _integer_field(str(key)):
			constants[key] = int(constants[key])
	var allowed: Dictionary = schema.get("allowed_values", {})
	for key in allowed:
		if _integer_field(str(key)):
			var values: Array = allowed[key]
			for index in range(values.size()):
				values[index] = int(values[index])
	return schema


func _integer_field(key: String) -> bool:
	return (
		key in ["index", "month", "order", "cursor", "sequence"]
		or key.ends_with("_index")
		or key.ends_with("_month")
		or key.ends_with("_months")
		or key.ends_with("_days")
		or key.ends_with("_krw")
		or key.ends_with("_basis_points")
	)


func _external_receipt(route_id: String, slot: String) -> Dictionary:
	var blocker_id := _blocker_id(route_id, slot)
	var schema := _canonicalize_exact_schema(
		_manifest["r1a_contract"]["external_blockers"][blocker_id]["receipt_schema"])
	return (schema["constants"] as Dictionary).duplicate(true)


func _blocker_id(route_id: String, slot: String) -> String:
	var contract_route: Dictionary = _manifest["r1a_contract"]["routes"][route_id]
	return str(contract_route["m53_blocker_id"] if slot == "m53" else contract_route["m54_blocker_id"])


func _source_route(route_id: String) -> Dictionary:
	for raw_route in (_manifest.get("routes", []) as Array):
		var route: Dictionary = raw_route
		if str(route.get("route_id", "")) == route_id:
			return route
	return {}


func _root_ids(route_id: String) -> Array:
	return (_manifest["r1a_contract"]["routes"][route_id]["root_ids"] as Array).duplicate(true)


func _has_unconsumed_fact(state: Dictionary, key: String) -> bool:
	return (state.get("facts", {}) as Dictionary).has(key) \
		and not (state.get("consumed", {}) as Dictionary).has(key)


func _expect_begin_rejected(
	contract: Dictionary,
	fixture: Dictionary,
	lock_value: Variant,
	code: String,
	label: String,
) -> void:
	var kernel = Year5ReferenceRouteKernel.new()
	_expect_ok(kernel.configure(contract), label + " config")
	var initial: Dictionary = kernel.initial_state()
	if not bool(initial.get("ok", false)):
		_expect(false, label + " initial")
		return
	_expect_code(kernel.begin_route(
		initial["state"], fixture["entry_snapshot"], fixture["m48_receipt"], lock_value),
		code, label)


func _expect_next(result: Dictionary, kind: String, id: String, label: String) -> void:
	_expect_ok(result, label + " result")
	if not bool(result.get("ok", false)):
		return
	var next: Dictionary = result.get("next", {})
	_expect(str(next.get("kind", "")) == kind, label + " kind")
	if not id.is_empty():
		_expect(str(next.get("id", "")) == id, label + " id")
	_expect(next.get("dispatch_allowed", true) == false, label + " dispatch off")


func _expect_dispatch_off(result: Dictionary, label: String) -> void:
	var next: Dictionary = result.get("next", {})
	_expect(next.get("dispatch_allowed", true) == false, label + " dispatch off")


func _expect_ok(result: Dictionary, label: String) -> void:
	_expect(bool(result.get("ok", false)), "%s (%s: %s)" % [
		label, str(result.get("error_code", "")), str(result.get("error", ""))])


func _expect_code(result: Dictionary, code: String, label: String) -> void:
	_expect(not bool(result.get("ok", false)) and str(result.get("error_code", "")) == code,
		"%s expected=%s actual=%s error=%s" % [label, code,
			str(result.get("error_code", "")), str(result.get("error", ""))])


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(label)
