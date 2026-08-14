extends Node
## Focused runtime/UI contract for the isolated M01-M06 play sample.
##
## This check intentionally does not preload MainGame, DemoCoreLoopV2,
## GameState, SaveManager, or any Week-24 fixture.  The play sample owns a
## separate state file and this scene must remain a sub-five-second check.

const RUNTIME_PATH := "res://systems/StoryMapMonthlyRuntime.gd"
const PLAYTEST_SCRIPT_PATH := "res://tools/StoryMapM1M6Playtest.gd"
const PLAYTEST_SCENE_PATH := "res://tools/StoryMapM1M6Playtest.tscn"
const STORY_MAP_PATH := "res://content/meta/story_map.json"
const EN_OVERLAY_PATH := "res://content/meta/story_map_m1m6_en.json"
const AUDIT_SCOPE_PATH := "res://tools/audit_scope.json"
const RUNTIME_SCRIPT := preload("res://systems/StoryMapMonthlyRuntime.gd")
const PLAYTEST_SCENE := preload("res://tools/StoryMapM1M6Playtest.tscn")

const FORBIDDEN_RUNTIME_TOKENS := [
	"SaveManager.save",
	"SaveManager.load",
	"GameState.",
	"DemoCoreLoopV2.gd",
	"MainGame.gd",
	"StoryMode.gd",
	"core_loop_v2_playtest",
	"savegame",
	"save_slot",
	"user://save",
]

const DEDICATED_SAVE_PREFIX := "user://story_map_m1m6"
const EXPECTED_LANE_TOOLS := [
	"tools/story_map_audit.py",
	"tools/story_map_strategy_sim.py --self-test",
	"tools/StoryMapM1M6Check.tscn",
]
const PROTECTED_PRODUCT_PATHS := [
	"project.godot",
	"autoloads/GameState.gd",
	"autoloads/SaveManager.gd",
	"systems/DemoCoreLoopV2.gd",
	"scenes/MainGame.gd",
	"scenes/StoryMode.gd",
	"scenes/CoreLoopV2Completion.gd",
]

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	_check_owned_resources_exist()
	_check_isolated_save_surface()
	_check_scope_isolation()
	_check_runtime_contracts()
	await _check_ui_flow()
	if _failures.is_empty():
		print("STORY_MAP_M1M6_CHECK_OK months=6 margin=4 deferred=2 actor=2 save=2 ui=1")
	else:
		for failure in _failures:
			push_error("STORY_MAP_M1M6_CHECK: %s" % failure)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_owned_resources_exist() -> void:
	for path in [RUNTIME_PATH, PLAYTEST_SCRIPT_PATH, PLAYTEST_SCENE_PATH,
			STORY_MAP_PATH, EN_OVERLAY_PATH]:
		_expect(ResourceLoader.exists(path) or FileAccess.file_exists(path),
			"missing owned resource: %s" % path)


func _check_isolated_save_surface() -> void:
	var combined_source := ""
	for path in [RUNTIME_PATH, PLAYTEST_SCRIPT_PATH]:
		var source := _read_text(path)
		if source.is_empty():
			continue
		combined_source += "\n" + source
		for token in FORBIDDEN_RUNTIME_TOKENS:
			_expect(token not in source,
				"%s reaches forbidden retail/V2 save token %s" % [path, token])
	if not combined_source.is_empty():
		_expect(DEDICATED_SAVE_PREFIX in combined_source,
			"play sample does not declare its dedicated autosave path")


func _check_scope_isolation() -> void:
	var parsed: Variant = JSON.parse_string(_read_text(AUDIT_SCOPE_PATH))
	_expect(parsed is Dictionary, "audit_scope.json did not parse")
	if not parsed is Dictionary:
		return
	var raw_lanes: Variant = (parsed as Dictionary).get("fast_lanes", [])
	_expect(raw_lanes is Array, "audit_scope fast_lanes is not an array")
	if not raw_lanes is Array:
		return
	var lane: Dictionary = {}
	for raw_lane in raw_lanes as Array:
		if raw_lane is Dictionary \
				and str((raw_lane as Dictionary).get("id", "")) \
					== "story-map-m1m6-runtime":
			lane = (raw_lane as Dictionary).duplicate(true)
			break
	_expect(not lane.is_empty(), "story-map-m1m6-runtime lane is missing")
	if lane.is_empty():
		return
	_expect(lane.get("tools", []) == EXPECTED_LANE_TOOLS,
		"runtime lane selected a broad or stale check set")
	var owned: Array = lane.get("owned_paths", []) \
		if lane.get("owned_paths", []) is Array else []
	for protected_path in PROTECTED_PRODUCT_PATHS:
		_expect(not owned.has(protected_path),
			"runtime lane owns protected product file %s" % protected_path)


func _check_runtime_contracts() -> void:
	var runtime = RUNTIME_SCRIPT.new()
	var loaded: Dictionary = runtime.load_story_map()
	_expect(bool(loaded.get("ok", false)), "runtime could not load story_map")
	if not bool(loaded.get("ok", false)):
		return

	var initial: Dictionary = runtime.initial_state()
	var before := _stable(initial)
	var rejected: Dictionary = runtime.resolve_month(
		initial, "m01_survival_shift", "m01_legal_application")
	_expect(not bool(rejected.get("ok", false)), "M01 accepted an optional promise without margin")
	_expect(_stable(rejected.get("state", {})) == before,
		"rejected M01 optional choice mutated state")

	var m01_cash := _resolve(runtime, initial, "m01_survival_shift")
	_expect(str(m01_cash.get("margin_axis", "")) == "cash",
		"M01 cash primary did not create M02 cash margin")
	var mismatch: Dictionary = runtime.preflight(
		m01_cash, "m02_close_account_risk", "m02_hyunsu_first_promise")
	_expect(str(mismatch.get("error_code", "")) == "margin_axis_mismatch",
		"cash margin accepted a trust optional promise")
	var m02_double := _resolve(
		runtime, m01_cash, "m02_hyunsu_first_promise", "m02_close_account_risk")
	_expect(str(m02_double.get("margin_axis", "")) == "",
		"two-promise month incorrectly refunded margin")

	var m01_pressure := _resolve(runtime, initial, "m01_legal_application")
	_expect((m01_pressure.get("costs", []) as Array).has("pressure.m02_cash_shortfall"),
		"M01 survival miss did not carry its pressure")
	var m02_repaid := _resolve(runtime, m01_pressure, "m02_close_account_risk")
	_expect(str(m02_repaid.get("margin_axis", "")) == "",
		"pressure repayment incorrectly created fresh margin")
	_expect(not (m02_repaid.get("costs", []) as Array).has("pressure.m02_cash_shortfall"),
		"pressure repayment left the old burden active")

	var father_deferred: Dictionary = (m01_cash.get("receipts", {}) as Dictionary).get(
		"m01_father_call", {})
	_expect(str(father_deferred.get("state", "")) == "deferred",
		"M01 father miss was not deferred")
	var m02_father_expired := _resolve(runtime, m01_cash, "m02_close_account_risk")
	var father_return: Dictionary = (m02_father_expired.get("receipts", {}) as Dictionary).get(
		"m02_return_father_call", {})
	_expect(str(father_return.get("state", "")) == "expired",
		"second father miss did not expire")
	_expect(not _ids(runtime.available_commitments(m02_father_expired)).has(
		"m02_return_father_call"), "father debt returned more than once")

	var daeun_path := _actor_path(runtime, true)
	var jiyeon_path := _actor_path(runtime, false)
	_expect(str(daeun_path.get("actor", "")) == "daeun",
		"M03 Daeun protected role did not reach M05/M06")
	_expect(str(jiyeon_path.get("actor", "")) == "jiyeon",
		"M03 Jiyeon protected role did not reach M05/M06")
	var actor_prefix := _actor_prefix(runtime, true)
	var optional_focus: Dictionary = runtime.resolve_month(
		actor_prefix, "m05_job_result", "m05_second_crossing")
	_expect(str((optional_focus.get("result", {}) as Dictionary).get("focus_actor", ""))
		== "daeun", "optional M05 focus actor was lost from the result")
	var deferred_focus: Dictionary = runtime.resolve_month(
		actor_prefix, "m05_job_result")
	_expect(str((deferred_focus.get("result", {}) as Dictionary).get("focus_actor", ""))
		== "daeun", "deferred M05 focus actor was lost from the result")

	var roundtrip_raw: Variant = JSON.parse_string(JSON.stringify(daeun_path.get("state", {})))
	_expect(roundtrip_raw is Dictionary, "runtime state JSON roundtrip did not parse")
	if roundtrip_raw is Dictionary:
		var normalized: Dictionary = runtime.normalize_state(roundtrip_raw)
		_expect(bool(normalized.get("ok", false)), "runtime rejected its own JSON roundtrip")
		_expect(_stable(normalized.get("state", {})) == _stable(daeun_path.get("state", {})),
			"runtime JSON roundtrip changed canonical state")
	var repeated: Dictionary = runtime.resolve_month(
		daeun_path.get("state", {}), "m05_second_crossing")
	_expect(not bool(repeated.get("ok", false)), "resolved month could be applied twice")
	_expect(_stable(repeated.get("state", {})) == _stable(daeun_path.get("state", {})),
		"repeated resolve mutated state")


func _actor_path(runtime: RefCounted, daeun_primary: bool) -> Dictionary:
	var state := _actor_prefix(runtime, daeun_primary)
	state = _resolve(runtime, state, "m05_second_crossing")
	var m05_receipt: Dictionary = (state.get("receipts", {}) as Dictionary).get(
		"m05_second_crossing", {})
	var actor := str((m05_receipt.get("actors", {}) as Dictionary).get("person", ""))
	var m06_cards := _ids(runtime.available_commitments(state))
	_expect(m06_cards.has("m06_person_date"), "M06 person date is missing after M05")
	var m06_result: Dictionary = runtime.resolve_month(state, "m06_person_date")
	_expect(bool(m06_result.get("ok", false)), "M06 person date did not resolve")
	if bool(m06_result.get("ok", false)):
		var result_actor := str((m06_result.get("result", {}) as Dictionary).get(
			"focus_actor", ""))
		_expect(result_actor == actor, "M06 changed the focused M05 actor")
	return {"actor": actor, "state": state}


func _actor_prefix(runtime: RefCounted, daeun_primary: bool) -> Dictionary:
	var state: Dictionary = runtime.initial_state()
	state = _resolve(runtime, state, "m01_father_call")
	state = _resolve(runtime, state, "m02_hyunsu_first_promise")
	state = _resolve(
		runtime,
		state,
		"m03_daeun_return" if daeun_primary else "m03_jiyeon_answer",
		"m03_jiyeon_answer" if daeun_primary else "m03_daeun_return",
	)
	state = _resolve(runtime, state, "m04_sangchul_office_coffee")
	return state


func _check_ui_flow() -> void:
	var playtest: Node = PLAYTEST_SCENE.instantiate()
	add_child(playtest)
	await get_tree().process_frame
	_expect(playtest.has_method("qa_start_new_run"), "playtest has no QA surface")
	if not playtest.has_method("qa_start_new_run"):
		playtest.queue_free()
		return
	var save_path := str(playtest.call("qa_autosave_path"))
	_expect(save_path == "user://story_map_m1m6_playtest_autosave.json",
		"playtest autosave path is not isolated")
	_remove_file(save_path)
	_expect(bool(playtest.call("qa_start_new_run")), "UI could not start a new run")
	_expect(not bool(playtest.call(
		"qa_set_role", "optional_second", "m01_legal_application")),
		"UI accepted M01 alongside before protected")
	var months := [
		["m01_father_call", ""],
		["m02_hyunsu_first_promise", ""],
		["m03_daeun_return", "m03_jiyeon_answer"],
		["m04_sangchul_office_coffee", ""],
		["m05_second_crossing", ""],
		["m06_person_date", ""],
	]
	for index in range(months.size()):
		var row: Array = months[index]
		_expect(bool(playtest.call("qa_set_role", "protected", row[0])),
			"UI could not set protected role in M%02d" % (index + 1))
		if not str(row[1]).is_empty():
			_expect(bool(playtest.call("qa_set_role", "optional_second", row[1])),
				"UI could not set alongside role in M%02d" % (index + 1))
		var result: Dictionary = playtest.call("qa_commit_month")
		_expect(not result.is_empty(), "UI could not commit M%02d" % (index + 1))
		if index == 4:
			_expect(str(result.get("focus_actor", "")) == "daeun",
				"UI M05 did not show the protected M03 actor")
		if index < months.size() - 1:
			_expect(bool(playtest.call("qa_advance")),
				"UI could not advance after M%02d" % (index + 1))
	_expect(bool(playtest.call("qa_advance")), "UI could not open recap")
	_expect(str(playtest.call("qa_screen")) == "recap", "UI did not finish on recap")
	var wrapper: Variant = JSON.parse_string(_read_text(save_path))
	var wrapper_keys: Array = (wrapper as Dictionary).keys() if wrapper is Dictionary else []
	wrapper_keys.sort()
	_expect(wrapper is Dictionary and wrapper_keys == ["runtime_state", "schema_version"],
		"autosave wrapper does not have the exact two fields")
	_expect(bool(playtest.call("qa_continue_run")), "finished autosave did not continue")
	_expect(str(playtest.call("qa_screen")) == "recap", "finished continue did not restore recap")
	_remove_file(save_path)
	playtest.queue_free()


func _resolve(
	runtime: RefCounted,
	state: Dictionary,
	primary_id: String,
	optional_id: String = "",
) -> Dictionary:
	var response: Dictionary = runtime.call(
		"resolve_month", state, primary_id, optional_id)
	_expect(bool(response.get("ok", false)),
		"runtime resolve failed for %s/%s: %s" % [
			primary_id, optional_id, response.get("error_code", "unknown")])
	return (response.get("state", state) as Dictionary).duplicate(true)


func _ids(cards: Array) -> Array[String]:
	var result: Array[String] = []
	for raw_card in cards:
		if raw_card is Dictionary:
			result.append(str((raw_card as Dictionary).get("id", "")))
	return result


func _stable(value: Variant) -> String:
	return JSON.stringify(value, "", true)


func _remove_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _read_text(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var handle := FileAccess.open(path, FileAccess.READ)
	if handle == null:
		_expect(false, "could not read %s" % path)
		return ""
	return handle.get_as_text()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
