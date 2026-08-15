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

# The player overlay deliberately no longer owns these author-only English
# strings.  Keep the rejected surface here as a regression fixture so moving
# the same copy under a new UI key cannot bypass the structural overlay check.
const LEGACY_EN_PRECHOICE_FORBIDDEN := [
	"The borrowed-account offer in W4 can only be answered this month",
	"500,000 won in cash and surviving the first month",
	"The first application and an entry into legitimate work",
	"Do not turn Dad's and Hyunsu's arrival into schedule filler",
	"The world event in W8 returns only once before month-end",
	"The result of the first choice and the cost of staying afloat",
	"A second attempt to reach out to Hyunsu first",
	"Do not bury rejection and acceptance under the same sentence",
	"The first meeting can happen only along this month's route through the city",
	"Finding time to seek people out while earning money",
	"The first real crossing with Daeun or Jiyeon",
	"After a chance meeting, progress opens only when the player spends time",
	"The first meeting opens only on the actual room-viewing route",
	"Rent and a job result arrive at the same time",
	"Sangchul's first coffee and a door to money",
	"Sangchul must not look like a villain at the first meeting",
	"Anyone not sought out again this month leaves a cost to re-enter",
	"A work decision and someone met earlier demand the same time",
	"An ordinary reunion with Jaehyuk or a second crossing with an existing connection",
	"Jaehyuk is not offering an investment or guarantee yet",
	"After Friday of W24, none of these deadlines can move to next week",
	"Work, people, and family deadlines collide on one Friday",
	"Choose one promise to keep",
	"Even unchosen promises retain their source and expiry",
	"Secure this month's survival floor and prepare a cash choice for next month.",
	"A cash gap for next month's rent and food remains as pressure.",
	"Open the hiring result in M04 and a path into legitimate work.",
	"This posting and its hiring-result window close.",
	"Keep the early family contact and prepare a trust choice for next month.",
	"It returns once in M02 as a call-back debt; miss it again and the early contact cools.",
	"Seal the account risk. If this month repays the prior cash gap, it creates no new margin.",
	"A financial scar and cash pressure remain for next month.",
	"Open the first shared-study path with Hyunsu, one not built on money.",
	"Hyunsu's early path closes; only a later reunion remains.",
	"Repay last month's call-back debt, but create no new margin from it.",
	"Missing him a second time lets the early family contact go cold.",
	"Secure a housing floor. If this repairs last month's financial scar, it creates no new margin.",
	"Emergency lodging and more expensive housing pressure arrive in M04.",
	"Open Daeun's immediate entry scene and the relationship path that follows.",
	"Daeun's immediate entry door closes this time.",
	"Open Jiyeon's immediate entry scene and the relationship path that follows.",
	"This window to answer Jiyeon directly closes.",
	"Confirm the first legitimate workday and a stable-income path.",
	"This hiring result and first-day window close.",
	"Get an independent housing quote. If this repairs last month's housing pressure, it creates no new margin.",
	"The booked listing and its quote window close.",
	"Open the warmer early path where Sangchul is a person before he is a deal.",
	"The warm first meeting closes; his M06 contact comes only as a cold field deal.",
	"Confirm a current livelihood line that does not duplicate the M04 hiring result.",
	"The current livelihood line breaks, making the cash choice in M06 more urgent.",
	"Preserve the plain friendship with Jaehyuk from before money entered it.",
	"The ordinary reunion closes; a later meeting will sit closer to a transaction.",
	"Make an M06 date with the person protected in M03 and advance that relationship.",
	"The M06 date with that same person returns once as a relationship debt.",
	"Meet this work deadline, first repairing any livelihood break carried from last month.",
	"The current legitimate-work door and the next income opportunity close.",
	"Answer this money and field offer, whether or not the earlier connection was warm.",
	"This field invitation and the introducer's door close.",
	"Hear Dad's health warning in time and open a path to family care.",
	"Lose the right to know in time and this family-health window.",
	"Keep the date with the person chosen in M05 and establish the early relationship stage.",
	"This date and the early relationship stage with that person close.",
]

var _failures: Array[String] = []
var _disclosure_coverage: Dictionary = {}


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	_check_owned_resources_exist()
	_check_isolated_save_surface()
	_check_scope_isolation()
	_check_player_overlay_boundary()
	_check_runtime_contracts()
	await _check_ui_flow()
	if _failures.is_empty():
		print("STORY_MAP_M1M6_CHECK_OK months=6 margin=4 deferred=2 actor=2 save=2 ui=1 disclosure=2")
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


func _check_player_overlay_boundary() -> void:
	var raw_overlay: Variant = JSON.parse_string(_read_text(EN_OVERLAY_PATH))
	_expect(raw_overlay is Dictionary, "English player overlay did not parse")
	if not raw_overlay is Dictionary:
		return
	var overlay := raw_overlay as Dictionary
	var month_copy: Variant = overlay.get("month_copy", {})
	_expect(month_copy is Dictionary, "English month copy is not a dictionary")
	if month_copy is Dictionary:
		for month_id in (month_copy as Dictionary):
			var entry: Variant = (month_copy as Dictionary).get(month_id, {})
			if not entry is Dictionary:
				_expect(false, "English month %s copy is not a dictionary" % month_id)
				continue
			var keys: Array = (entry as Dictionary).keys()
			keys.sort()
			_expect(keys == ["design_label"],
				"English month %s exposes author contract or future deadline" % month_id)
	var commitment_copy: Variant = overlay.get("commitment_copy", {})
	_expect(commitment_copy is Dictionary, "English commitment copy is not a dictionary")
	if commitment_copy is Dictionary:
		for commitment_id in (commitment_copy as Dictionary):
			var entry: Variant = (commitment_copy as Dictionary).get(commitment_id, {})
			if not entry is Dictionary:
				_expect(false, "English commitment %s copy is not a dictionary" % commitment_id)
				continue
			for key in (entry as Dictionary).keys():
				_expect(str(key) in ["label", "label_by_actor"],
					"English commitment %s exposes prewritten outcome %s" % [commitment_id, key])
	var ui_copy: Variant = overlay.get("ui_copy", {})
	_expect(ui_copy is Dictionary, "English UI copy is not a dictionary")
	if ui_copy is Dictionary:
		for stale_key in ["ui.card.keep", "ui.card.miss", "ui.month.deadline"]:
			_expect(not (ui_copy as Dictionary).has(stale_key),
				"English UI restored exact pre-choice outcome key %s" % stale_key)


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
		_check_prechoice_disclosure(playtest, index + 1)
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
	await get_tree().process_frame
	await _check_conditional_disclosure_routes()
	_check_disclosure_coverage()


func _check_prechoice_disclosure(playtest: Node, month: int) -> void:
	_expect(str(playtest.call("qa_screen")) == "selection",
		"M%02d disclosure check did not start on selection" % month)
	var raw_map: Variant = JSON.parse_string(_read_text(STORY_MAP_PATH))
	_expect(raw_map is Dictionary, "story_map did not parse for disclosure check")
	if not raw_map is Dictionary:
		return
	var month_data := _story_month(raw_map as Dictionary, month)
	_expect(not month_data.is_empty(), "M%02d is missing from story_map" % month)
	if month_data.is_empty():
		return
	for language in ["ko", "en"]:
		_expect(bool(playtest.call("qa_set_language", language)),
			"UI could not switch to %s for M%02d" % [language, month])
		for raw_card in month_data.get("commitments", []):
			if not raw_card is Dictionary:
				continue
			var card := raw_card as Dictionary
			var commitment_id := str(card.get("id", ""))
			if not bool(playtest.call("qa_focus_commitment", commitment_id)):
				continue
			_assert_prechoice_copy_boundary(
				playtest, month_data, month, language, commitment_id, "unassigned")
			_mark_disclosure_coverage(commitment_id, language, "unassigned")
			_expect(bool(playtest.call("qa_set_role", "protected", commitment_id)),
				"M%02d %s could not protect %s for disclosure check" % [
					month, language, commitment_id])
			_assert_prechoice_copy_boundary(
				playtest, month_data, month, language, commitment_id, "protected")
			_mark_disclosure_coverage(commitment_id, language, "protected")
			_expect(bool(playtest.call("qa_clear_role", "protected")),
				"M%02d %s could not clear protected %s" % [
					month, language, commitment_id])
			var optional_primary := _optional_primary_for(playtest, month_data, card)
			if not optional_primary.is_empty():
				_expect(bool(playtest.call("qa_set_role", "protected", optional_primary)),
					"M%02d %s could not prepare optional check for %s" % [
						month, language, commitment_id])
				_expect(bool(playtest.call("qa_set_role", "optional_second", commitment_id)),
					"M%02d %s could not add optional %s" % [
						month, language, commitment_id])
				_assert_prechoice_copy_boundary(
					playtest, month_data, month, language, commitment_id, "optional_second")
				_mark_disclosure_coverage(commitment_id, language, "optional_second")
				_expect(bool(playtest.call("qa_clear_role", "protected")),
					"M%02d %s could not clear optional setup for %s" % [
						month, language, commitment_id])
	_expect(bool(playtest.call("qa_set_language", "ko")),
		"UI could not restore Korean after M%02d disclosure check" % month)


func _assert_prechoice_copy_boundary(
	playtest: Node,
	month_data: Dictionary,
	month: int,
	language: String,
	commitment_id: String,
	role_state: String,
) -> void:
	var visible := str(playtest.call("qa_visible_text"))
	var contract: Variant = month_data.get("contract", {})
	if contract is Dictionary:
		for field in ["deadline", "pressure", "opportunity", "person_promise"]:
			var author_copy := str((contract as Dictionary).get(field, ""))
			_expect(author_copy.is_empty() or not visible.contains(author_copy),
				"M%02d %s %s/%s exposed author contract %s" % [
					month, language, commitment_id, role_state, field])
	for raw_card in month_data.get("commitments", []):
		if not raw_card is Dictionary:
			continue
		var author_id := str((raw_card as Dictionary).get("id", ""))
		var strategy: Variant = (raw_card as Dictionary).get("strategy", {})
		if not strategy is Dictionary:
			continue
		for outcome in ["completed", "missed"]:
			var outcome_data: Variant = (strategy as Dictionary).get(outcome, {})
			var preview := str((outcome_data as Dictionary).get("preview", "")) \
				if outcome_data is Dictionary else ""
			_expect(preview.is_empty() or not visible.contains(preview),
				"M%02d %s %s/%s exposed %s outcome for %s" % [
					month, language, commitment_id, role_state, outcome, author_id])
	if language == "en":
		for forbidden_copy in LEGACY_EN_PRECHOICE_FORBIDDEN:
			_expect(not visible.contains(str(forbidden_copy)),
				"M%02d EN %s/%s restored rejected author/outcome copy" % [
					month, commitment_id, role_state])
	var focused := _story_card(month_data, commitment_id)
	var safe_copy := ""
	if language == "ko":
		safe_copy = "미룸 · 다음 달 한 번" \
			if str(focused.get("miss", "expired")) == "deferred" \
			else "기한 · 이번 달에 끝남"
	else:
		safe_copy = "DEFER · MAY RETURN ONCE" \
			if str(focused.get("miss", "expired")) == "deferred" \
			else "WINDOW · ENDS THIS MONTH"
	_expect(visible.contains(safe_copy),
		"M%02d %s %s/%s omitted its safe deadline rule" % [
			month, language, commitment_id, role_state])


func _optional_primary_for(
	playtest: Node,
	month_data: Dictionary,
	optional_card: Dictionary,
) -> String:
	var snapshot: Variant = playtest.call("qa_snapshot")
	if not snapshot is Dictionary:
		return ""
	var margin_axis := str((snapshot as Dictionary).get("margin_axis", ""))
	if margin_axis.is_empty() or margin_axis != str(optional_card.get("axis", "")):
		return ""
	var optional_id := str(optional_card.get("id", ""))
	for raw_card in month_data.get("commitments", []):
		if not raw_card is Dictionary:
			continue
		var candidate_id := str((raw_card as Dictionary).get("id", ""))
		if candidate_id != optional_id \
				and bool(playtest.call("qa_focus_commitment", candidate_id)):
			return candidate_id
	return ""


func _story_card(month_data: Dictionary, commitment_id: String) -> Dictionary:
	for raw_card in month_data.get("commitments", []):
		if raw_card is Dictionary \
				and str((raw_card as Dictionary).get("id", "")) == commitment_id:
			return (raw_card as Dictionary).duplicate(true)
	return {}


func _story_month(root: Dictionary, month: int) -> Dictionary:
	for raw_chapter in root.get("chapters", []):
		if not raw_chapter is Dictionary:
			continue
		for raw_month in (raw_chapter as Dictionary).get("months", []):
			if raw_month is Dictionary and int((raw_month as Dictionary).get("month", 0)) == month:
				return (raw_month as Dictionary).duplicate(true)
	return {}


func _check_conditional_disclosure_routes() -> void:
	await _check_conditional_disclosure_route(
		["m01_survival_shift"], 2, "m02_return_father_call")
	await _check_conditional_disclosure_route(
		["m01_legal_application", "m02_close_account_risk", "m03_cover_deposit_gap"],
		4,
		"m04_answer_job_result",
	)


func _check_conditional_disclosure_route(
	prefix: Array,
	target_month: int,
	required_commitment_id: String,
) -> void:
	var playtest: Node = PLAYTEST_SCENE.instantiate()
	add_child(playtest)
	await get_tree().process_frame
	if not playtest.has_method("qa_start_new_run"):
		_expect(false, "conditional disclosure playtest has no QA surface")
		playtest.queue_free()
		await get_tree().process_frame
		return
	var save_path := str(playtest.call("qa_autosave_path"))
	_remove_file(save_path)
	var route_ok := bool(playtest.call("qa_start_new_run"))
	_expect(route_ok,
		"conditional disclosure route to M%02d could not start" % target_month)
	for commitment_id in prefix:
		if not route_ok:
			break
		route_ok = bool(playtest.call("qa_set_role", "protected", commitment_id))
		_expect(route_ok,
			"conditional disclosure route could not protect %s" % commitment_id)
		if not route_ok:
			break
		var result: Variant = playtest.call("qa_commit_month")
		route_ok = result is Dictionary and not (result as Dictionary).is_empty()
		_expect(route_ok,
			"conditional disclosure route could not commit %s" % commitment_id)
		if not route_ok:
			break
		route_ok = bool(playtest.call("qa_advance"))
		_expect(route_ok,
			"conditional disclosure route could not advance after %s" % commitment_id)
	if route_ok:
		_expect(str(playtest.call("qa_screen")) == "selection",
			"conditional disclosure route did not reach M%02d selection" % target_month)
		_expect(bool(playtest.call("qa_focus_commitment", required_commitment_id)),
			"conditional disclosure route did not expose %s" % required_commitment_id)
		_check_prechoice_disclosure(playtest, target_month)
	_remove_file(save_path)
	playtest.queue_free()
	await get_tree().process_frame


func _mark_disclosure_coverage(
	commitment_id: String,
	language: String,
	role_state: String,
) -> void:
	var key := "%s|%s" % [commitment_id, language]
	var states: Array = _disclosure_coverage.get(key, [])
	if not role_state in states:
		states.append(role_state)
	_disclosure_coverage[key] = states


func _check_disclosure_coverage() -> void:
	var raw_map: Variant = JSON.parse_string(_read_text(STORY_MAP_PATH))
	_expect(raw_map is Dictionary, "story_map did not parse for disclosure coverage")
	if not raw_map is Dictionary:
		return
	var optional_counts := {"ko": 0, "en": 0}
	for month in range(1, 7):
		var month_data := _story_month(raw_map as Dictionary, month)
		for raw_card in month_data.get("commitments", []):
			if not raw_card is Dictionary:
				continue
			var commitment_id := str((raw_card as Dictionary).get("id", ""))
			for language in ["ko", "en"]:
				var states: Array = _disclosure_coverage.get(
					"%s|%s" % [commitment_id, language], [])
				_expect(states.has("unassigned"),
					"%s %s never checked before role assignment" % [
						commitment_id, language])
				_expect(states.has("protected"),
					"%s %s never checked after role assignment" % [
						commitment_id, language])
				if states.has("optional_second"):
					optional_counts[language] = int(optional_counts[language]) + 1
	for language in ["ko", "en"]:
		_expect(int(optional_counts[language]) > 0,
			"%s disclosure never checked after alongside role assignment" % language)


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
