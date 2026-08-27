extends Node
## Focused contract for ORDER-124's isolated story-choice M01-M06 sample.
##
## The check drives only the playtest controller's public qa_* surface. It does
## not enter StoryMode, any monthly-action runtime, or the 24/240-week fixtures.

const PLAYTEST_SCENE_PATH := \
	"res://playtests/order124/StoryChoiceM1M6Playtest.tscn"
const PLAYTEST_SCENE := preload(
	"res://playtests/order124/StoryChoiceM1M6Playtest.tscn")
const BUILD_FLAVOR := preload("res://systems/BuildFlavor.gd")
const AUDIT_SCOPE_PATH := "res://tools/audit_scope.json"
const EXPECTED_STORY_SCENE := "res://scenes/StoryMode.tscn"
const EXPECTED_SAVE_PATH := \
	"user://story_choice_m1m6_playtest_save.json"
const EXPECTED_CUSTOM_USER_DIR := "GangnamDream_ORDER124_StoryChoice_v1"
const M6_SOURCE_EVENT_ID := "v2_demo_first_bill"
const M6_EVENT_ID := "order124_m6_first_bill"
const M6_SOURCE_CHOICES: Array[int] = [3, 4, 5, 6, 7]
const EXPECTED_MONTHS_CLEAN := {
	"1": ["arc_temptation_01"],
	"2": ["arc_temptation_clean"],
	"3": ["arc_daeun_01_meet", "arc_jiyeon_01_crash"],
	"4": ["arc_sangchul_01_meet"],
	"5": ["arc_jaehyuk_01_reunion"],
	"6": [M6_EVENT_ID],
}
const EXPECTED_MONTHS_FALLOUT := {
	"1": ["arc_temptation_01"],
	"2": ["arc_temptation_fallout"],
	"3": ["arc_daeun_01_meet", "arc_jiyeon_01_crash"],
	"4": ["arc_sangchul_01_meet"],
	"5": ["arc_jaehyuk_01_reunion"],
	"6": [M6_EVENT_ID],
}
const EXPECTED_HOSTILE_CHOICE_RECORDS := [
	"arc_temptation_01",
	"arc_temptation_fallout",
	"arc_daeun_01_meet",
	"arc_jiyeon_01_crash",
	"arc_sangchul_01_meet",
	"arc_sangchul_01_measure",
	"arc_sangchul_01_answer",
	"arc_jaehyuk_01_reunion",
	M6_EVENT_ID,
]
const EXPECTED_HOSTILE_CHOICE_INDICES := [1, 0, 1, 0, 0, 0, 1, 1, 3]
const REQUIRED_QA_METHODS := [
	"qa_start_new_run",
	"qa_continue_run",
	"qa_schedule",
	"qa_current_month",
	"qa_screen",
	"qa_session_snapshot",
	"qa_start_contract",
	"qa_user_data_contract",
	"qa_autosave_path",
	"qa_m6_event",
	"qa_choose_current",
	"qa_choose_event",
	"qa_close_month",
	"qa_repeat_last_close",
	"qa_prepare_story_return",
	"qa_transition_overlay_state",
	"qa_set_auto_launch",
	"qa_set_language",
	"qa_visible_text",
	"qa_monthly_action_receipt_count",
]
const FORBIDDEN_SURFACE_TERMS := [
	"주력",
	"함께",
	"여력",
	"행동판",
	"행동 카드",
	"월간 행동",
	"월간 후보",
	"확인 제출",
	"primary",
	"alongside",
	"margin",
	"action board",
	"action card",
	"monthly action",
	"monthly candidate",
	"submit selection",
]
const FORBIDDEN_M6_KEYS := [
	"follow_up_event",
	"deferred_follow_up",
	"deferred_delay",
]
const EXPECTED_LANE_PATHS := [
	"playtests/order124/StoryChoiceM1M6Playtest.gd",
	"playtests/order124/StoryChoiceM1M6Playtest.gd.uid",
	"playtests/order124/StoryChoiceM1M6Playtest.tscn",
	"tools/StoryChoiceM1M6Check.gd",
	"tools/StoryChoiceM1M6Check.gd.uid",
	"tools/StoryChoiceM1M6Check.tscn",
	"tools/audit_scope.json",
]

var _failures: Array[String] = []
var _candidate_files_before: Dictionary = {}
var _protected_files_before: Dictionary = {}
var _isolated_shared_files_before: Dictionary = {}
var _original_game_state: Dictionary = {}
var _original_language := ""
var _original_sfx_enabled := true
var _original_use_custom_user_dir: Variant = null
var _original_custom_user_dir_name: Variant = null
var _had_use_custom_user_dir_setting := false
var _had_custom_user_dir_name_setting := false
var _bootstrapped_qa_namespace := false


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	# Resolve the real retail/V2 paths before switching this QA process into its
	# approved custom namespace. Absolute paths keep the protection meaningful.
	_protected_files_before = _capture_files(
		_globalized_paths(_protected_save_paths()))
	_bootstrap_qa_namespace()
	_isolated_shared_files_before = _capture_files(_protected_save_paths())
	_original_game_state = GameState.serialize().duplicate(true)
	_original_language = LocaleManager.language
	_original_sfx_enabled = bool(AudioManager.sfx_enabled)
	AudioManager.sfx_enabled = false
	_check_owned_resources_and_scope()
	if not _project_user_data_isolated():
		_expect(false,
			"refusing to run outside a staged ORDER-124 custom user-data namespace")
		_finish()
		return

	var controller := _new_controller()
	if controller == null:
		_finish()
		return
	var save_path := str(controller.call("qa_autosave_path"))
	_expect(save_path == EXPECTED_SAVE_PATH,
		"candidate autosave path drifted: %s" % save_path)
	_expect(not _protected_save_paths().has(save_path),
		"candidate autosave aliases a retail/V2 save path")
	_candidate_files_before = _capture_files([
		save_path, "%s.bak" % save_path, "%s.tmp" % save_path])

	_check_public_surface(controller)
	_check_start_contract(controller)
	_check_m6_localization_and_contract(controller)
	_expect(bool(controller.call("qa_set_language", "ko")),
		"could not select Korean for the full route")
	_check_visible_surface(controller, "ko home")
	controller = await _check_m1_story_return_overlay(controller)

	if controller != null and _start_and_check_m1_route(controller, 1, "fallout"):
		controller = _check_save_roundtrip(controller)
		if controller != null:
			controller = await _complete_hostile_route(controller)
	if controller != null:
		_expect(bool(controller.call("qa_set_language", "en")),
			"could not select English for recap")
		_check_visible_surface(controller, "en recap")
		_start_and_check_m1_route(controller, 0, "clean")
		_free_controller(controller)

	_finish()


func _bootstrap_qa_namespace() -> void:
	# audit_select runs this QA scene directly from the source project. Give it
	# the same approved isolated namespace as the staged ORDER-124 build before
	# any user:// snapshot is resolved; never borrow the retail directory.
	_had_use_custom_user_dir_setting = ProjectSettings.has_setting(
		"application/config/use_custom_user_dir")
	_had_custom_user_dir_name_setting = ProjectSettings.has_setting(
		"application/config/custom_user_dir_name")
	_original_use_custom_user_dir = ProjectSettings.get_setting(
		"application/config/use_custom_user_dir", null)
	_original_custom_user_dir_name = ProjectSettings.get_setting(
		"application/config/custom_user_dir_name", null)
	if _project_user_data_isolated():
		return
	ProjectSettings.set_setting(
		"application/config/use_custom_user_dir", true)
	ProjectSettings.set_setting(
		"application/config/custom_user_dir_name", EXPECTED_CUSTOM_USER_DIR)
	DirAccess.make_dir_recursive_absolute(OS.get_user_data_dir())
	_bootstrapped_qa_namespace = true


func _restore_project_user_namespace() -> void:
	if not _bootstrapped_qa_namespace:
		return
	ProjectSettings.set_setting(
		"application/config/use_custom_user_dir",
		_original_use_custom_user_dir
		if _had_use_custom_user_dir_setting else null)
	ProjectSettings.set_setting(
		"application/config/custom_user_dir_name",
		_original_custom_user_dir_name
		if _had_custom_user_dir_name_setting else null)
	_bootstrapped_qa_namespace = false


func _new_controller() -> Node:
	var controller: Node = PLAYTEST_SCENE.instantiate()
	add_child(controller)
	if controller.has_method("qa_set_auto_launch"):
		controller.call("qa_set_auto_launch", false)
	for method_name in REQUIRED_QA_METHODS:
		_expect(controller.has_method(method_name),
			"playtest controller lacks %s" % method_name)
	if REQUIRED_QA_METHODS.any(
			func(method_name): return not controller.has_method(method_name)):
		_free_controller(controller)
		return null
	return controller


func _check_public_surface(controller: Node) -> void:
	_expect(ResourceLoader.exists(PLAYTEST_SCENE_PATH),
		"playtest scene is not importable")
	_expect(str(controller.call("qa_screen")) == "home",
		"controller did not open on its isolated home")
	_expect(int(controller.call("qa_monthly_action_receipt_count")) == 0,
		"home reported a monthly action receipt")
	var user_data: Dictionary = controller.call("qa_user_data_contract")
	_expect(bool(user_data.get("enabled", false))
			and bool(user_data.get("isolated", false))
			and not str(user_data.get("configured_name", "")).is_empty(),
		"controller is not running in an isolated custom user-data namespace")
	_expect("/Godot/app_userdata/강남드림" not in str(
		user_data.get("resolved_path", "")).replace("\\", "/"),
		"controller resolved to the retail user-data directory")


func _project_user_data_isolated() -> bool:
	if not bool(ProjectSettings.get_setting(
			"application/config/use_custom_user_dir", false)):
		return false
	var configured_name := str(ProjectSettings.get_setting(
		"application/config/custom_user_dir_name", ""))
	if configured_name == EXPECTED_CUSTOM_USER_DIR:
		return true
	return OS.get_environment("ORDER124_ALLOW_ISOLATED_QA") == "1" \
		and configured_name.begins_with("GangnamDream_ORDER124_RuntimeQA_")


func _check_start_contract(controller: Node) -> void:
	var contract: Dictionary = controller.call("qa_start_contract")
	var expected := {
		"difficulty": "드라마",
		"profile": "알바",
		"run_theme": "자유런",
		"run_theme_categories": [],
		"health_floor": 70,
		"mental_floor": 72,
		"monthly_recovery_health": 1,
		"monthly_recovery_mental": 2,
		"creates_monthly_action_receipts": false,
	}
	_expect(_canonical(contract) == _canonical(expected),
		"hostile-route survival contract drifted: %s" % [contract])
	var schedule: Dictionary = controller.call("qa_schedule")
	_expect(_canonical(schedule.get("start_contract", {}))
			== _canonical(expected),
		"schedule omitted the hostile-route survival contract")


func _start_and_check_m1_route(
		controller: Node, choice_index: int, expected_route: String) -> bool:
	var failure_count := _failures.size()
	_expect(bool(controller.call("qa_start_new_run")),
		"%s route could not start" % expected_route)
	_expect(int(controller.call("qa_current_month")) == 1,
		"%s route did not start at M01" % expected_route)
	_expect(str(controller.call("qa_screen")) == "transition",
		"%s route did not open the M01 transition" % expected_route)
	var started_snapshot: Dictionary = controller.call("qa_session_snapshot")
	_expect(_canonical(started_snapshot.get("start_contract", {}))
			== _canonical(controller.call("qa_start_contract")),
		"%s session did not persist its start contract" % expected_route)
	var started_state: Dictionary = started_snapshot.get("game_state", {})
	_expect(str(started_state.get("difficulty", "")) == "드라마"
			and bool((started_state.get("flags", {}) as Dictionary).get(
				"part_time_worker", false)),
		"%s route did not use the declared Drama + part-time baseline" % expected_route)
	_expect(str(started_state.get("run_theme", "")) == "자유런"
			and (started_state.get("run_theme_categories", []) as Array).is_empty(),
		"%s route did not neutralize random run-theme routing" % expected_route)
	_expect(int(started_state.get("health", 0)) >= 70
			and int(started_state.get("mental", 0)) >= 72,
		"%s route started below its health/mental survival floor" % expected_route)
	_check_schedule(controller, "clean")
	_check_zero_commitments(controller, "%s M01 start" % expected_route)
	_check_visible_surface(controller, "%s M01 transition" % expected_route)

	var before_premature := _canonical(controller.call("qa_session_snapshot"))
	var premature: Dictionary = controller.call("qa_close_month", 1)
	_expect(not bool(premature.get("closed", false))
			and str(premature.get("reason", "")) == "awaiting_choices",
		"%s M01 closed before its story choice" % expected_route)
	_expect(_canonical(controller.call("qa_session_snapshot"))
			== before_premature,
		"rejected premature M01 close mutated the session")

	var before_snapshot: Dictionary = controller.call("qa_session_snapshot")
	var before_state: Dictionary = before_snapshot.get("game_state", {})
	var result: Dictionary = controller.call(
		"qa_choose_event", "arc_temptation_01", choice_index)
	_expect(bool(result.get("accepted", false))
			and bool(result.get("applied", false)),
		"%s M01 choice was not applied" % expected_route)
	var after_state: Dictionary = result.get("game_state", {})
	_check_m1_effect_delta(before_state, after_state, expected_route)
	_check_schedule(controller, expected_route)

	var before_repeat := _canonical(controller.call("qa_session_snapshot"))
	var repeated: Dictionary = controller.call(
		"qa_choose_event", "arc_temptation_01", choice_index)
	_expect(not bool(repeated.get("accepted", true))
			and not bool(repeated.get("applied", true))
			and str(repeated.get("reason", "")) == "already_applied",
		"%s M01 choice was accepted twice" % expected_route)
	_expect(_canonical(controller.call("qa_session_snapshot")) == before_repeat,
		"%s repeated M01 choice mutated state" % expected_route)
	_check_zero_commitments(controller, "%s M01 selected" % expected_route)
	return _failures.size() == failure_count


func _check_m1_effect_delta(
		before: Dictionary, after: Dictionary, expected_route: String) -> void:
	var expected_money_delta := 0.0 if expected_route == "clean" else 2_000_000.0
	var expected_mental_delta := -8 if expected_route == "clean" else -16
	var expected_tint_delta := 5.0 if expected_route == "clean" else -10.0
	_expect(is_equal_approx(
		float(after.get("money", 0.0)) - float(before.get("money", 0.0)),
		expected_money_delta), "%s M01 money effect drifted" % expected_route)
	_expect(int(after.get("mental", 0)) - int(before.get("mental", 0))
			== expected_mental_delta,
		"%s M01 mental effect drifted" % expected_route)
	_expect(is_equal_approx(
		float(after.get("moral_tint", 0.0))
			- float(before.get("moral_tint", 0.0)), expected_tint_delta),
		"%s M01 moral tint effect drifted" % expected_route)
	var flags: Dictionary = after.get("flags", {})
	if expected_route == "clean":
		_expect(bool(flags.get("kept_clean_hands", false))
				and not bool(flags.get("lent_account", false)),
			"clean M01 did not preserve its authored flags")
		_expect(int(after.get("route_orthodox", 0))
				- int(before.get("route_orthodox", 0)) == 1
				and int(after.get("route_unorthodox", 0))
				== int(before.get("route_unorthodox", 0)),
			"clean M01 did not apply exactly one orthodox route point")
	else:
		_expect(bool(flags.get("lent_account", false))
				and bool(flags.get("crossed_line_early", false)),
			"fallout M01 did not preserve its authored flags")
		_expect(int(after.get("route_unorthodox", 0))
				- int(before.get("route_unorthodox", 0)) == 1
				and int(after.get("route_orthodox", 0))
				== int(before.get("route_orthodox", 0)),
			"fallout M01 did not apply exactly one unorthodox route point")


func _check_save_roundtrip(controller: Node) -> Node:
	var close: Dictionary = controller.call("qa_close_month", 1)
	_check_close_result(close, 1)
	_check_zero_commitments(controller, "M01 close")
	var expected_snapshot: Dictionary = controller.call("qa_session_snapshot")
	var expected := _canonical(expected_snapshot)
	var save_path := str(controller.call("qa_autosave_path"))
	_expect(FileAccess.file_exists(save_path),
		"M01 close did not write the isolated autosave")
	_free_controller(controller)

	var resumed := _new_controller()
	if resumed == null:
		return null
	_expect(bool(resumed.call("qa_continue_run")),
		"isolated M01 autosave did not continue")
	var actual_snapshot: Dictionary = resumed.call("qa_session_snapshot")
	var resumed_snapshot := _canonical(actual_snapshot)
	var roundtrip_differences: Array[String] = []
	if resumed_snapshot != expected:
		_collect_value_differences(
			_normalize_numbers(expected_snapshot),
			_normalize_numbers(actual_snapshot),
			"snapshot", roundtrip_differences)
	_expect(resumed_snapshot == expected,
		"isolated autosave changed the session on roundtrip (expected=%s actual=%s diff=%s)" % [
			expected.sha256_text(), resumed_snapshot.sha256_text(),
			" | ".join(PackedStringArray(roundtrip_differences))])
	var before_repeat := _canonical(resumed.call("qa_session_snapshot"))
	var repeated: Dictionary = resumed.call("qa_repeat_last_close")
	_expect(not bool(repeated.get("closed", true))
			and str(repeated.get("reason", "")) == "already_closed",
		"reloaded M01 accepted a duplicate close")
	_expect(_canonical(resumed.call("qa_session_snapshot")) == before_repeat,
		"duplicate close after reload mutated the session")
	return resumed


func _check_m1_story_return_overlay(controller: Node) -> Node:
	_expect(bool(controller.call("qa_start_new_run")),
		"M01 return regression could not start")
	_expect(bool(controller.call("qa_prepare_story_return", 0)),
		"M01 return regression could not prepare its StoryMode checkpoint")
	controller = await _reload_after_covered_story_return(
		controller, "M01", "transition", 2)
	if controller == null:
		return null
	var snapshot: Dictionary = controller.call("qa_session_snapshot")
	_expect(int(snapshot.get("elapsed_weeks", -1)) == 4
			and int(snapshot.get("monthly_pressure_count", -1)) == 1,
		"M01 return did not settle exactly four weeks and one pressure cycle")
	_expect((snapshot.get("choices", []) as Array).size() == 1,
		"M01 return did not collect exactly one StoryMode receipt")
	return controller


func _reload_after_covered_story_return(
		controller: Node, label: String, expected_screen: String,
		expected_month: int) -> Node:
	var active_tween: Variant = SceneTransition.get("_tween")
	if active_tween is Tween:
		(active_tween as Tween).kill()
	SceneTransition.set("_tween", null)
	SceneTransition.call("_set_transition_alpha", 1.0)
	var overlay: Variant = SceneTransition.get("_overlay")
	if overlay is Control:
		(overlay as Control).mouse_filter = Control.MOUSE_FILTER_STOP
	_free_controller(controller)
	var returned := _new_controller()
	if returned == null:
		return null
	await get_tree().create_timer(0.70).timeout
	var overlay_state: Dictionary = returned.call("qa_transition_overlay_state")
	_expect(str(returned.call("qa_screen")) == expected_screen,
		"%s return opened %s instead of %s" % [
			label, str(returned.call("qa_screen")), expected_screen])
	_expect(int(returned.call("qa_current_month")) == expected_month,
		"%s return reached month %d instead of %d" % [
			label, int(returned.call("qa_current_month")), expected_month])
	_expect(float(overlay_state.get("alpha", 1.0)) <= 0.01,
		"%s return remained behind the black transition cover: %s" % [
			label, overlay_state])
	_expect(not bool(overlay_state.get("blocks_input", true)),
		"%s return left the transition cover blocking player input" % label)
	return returned


func _complete_hostile_route(controller: Node) -> Node:
	var low_mental_choices := {
		"arc_temptation_fallout": 0,
		"arc_daeun_01_meet": 1,
		"arc_jiyeon_01_crash": 0,
		"arc_sangchul_01_meet": 0,
		"arc_sangchul_01_measure": 0,
		"arc_sangchul_01_coffee": 0,
		"arc_sangchul_01_answer": 1,
		"arc_jaehyuk_01_reunion": 1,
		M6_EVENT_ID: 3,
	}
	for month in range(2, 7):
		_expect(int(controller.call("qa_current_month")) == month,
			"route reached %s instead of M%02d" % [
				str(controller.call("qa_current_month")), month])
		_check_schedule(controller, "fallout")
		_check_visible_surface(controller, "ko M%02d transition" % month)
		if month == 6:
			_expect(bool(controller.call("qa_prepare_story_return", 3)),
				"M06 return regression could not prepare its StoryMode checkpoint")
			controller = await _reload_after_covered_story_return(
				controller, "M06", "recap", 7)
			if controller == null:
				return null
			_check_zero_commitments(controller, "M06 story return")
			continue
		var choice_guard := 0
		while choice_guard < 8:
			var schedule: Dictionary = controller.call("qa_schedule")
			var current_ids: Array = schedule.get("current_event_ids", [])
			if current_ids.is_empty():
				break
			var event_id := str(current_ids.front())
			var choice_index := int(low_mental_choices.get(event_id, 0))
			var result: Dictionary = controller.call(
				"qa_choose_event", event_id, choice_index)
			_expect(bool(result.get("accepted", false))
					and bool(result.get("applied", false)),
				"M%02d story choice %s was not applied" % [month, event_id])
			if not bool(result.get("applied", false)):
				break
			choice_guard += 1
		_expect(choice_guard < 8,
			"M%02d story follow-up chain did not terminate" % month)
		_check_zero_commitments(controller, "M%02d choices" % month)
		var close: Dictionary = controller.call("qa_close_month", month)
		_check_close_result(close, month)
		_check_zero_commitments(controller, "M%02d close" % month)
	_expect(str(controller.call("qa_screen")) == "recap",
		"sixth close did not open recap")
	var snapshot: Dictionary = controller.call("qa_session_snapshot")
	_expect(int(snapshot.get("elapsed_weeks", -1)) == 24,
		"six-month session did not record 24 weeks")
	_expect(int(snapshot.get("monthly_pressure_count", -1)) == 6,
		"six-month session did not record six pressure settlements")
	var settlements: Variant = snapshot.get("settlements", [])
	_expect(settlements is Array and (settlements as Array).size() == 6,
		"six-month session does not contain six settlement receipts")
	var records: Array = snapshot.get("choices", [])
	var event_ids: Array[String] = []
	var choice_indices: Array[int] = []
	for record_variant in records:
		if record_variant is Dictionary:
			event_ids.append(str((record_variant as Dictionary).get("event_id", "")))
			choice_indices.append(int(
				(record_variant as Dictionary).get("choice_index", -1)))
	_expect(event_ids == EXPECTED_HOSTILE_CHOICE_RECORDS,
		"recap did not retain the exact M01-M06 story choices: %s" % [event_ids])
	_expect(choice_indices == EXPECTED_HOSTILE_CHOICE_INDICES,
		"hostile route did not retain dirty/restitution/low-mental choices: %s" % [
			choice_indices])
	var game_state: Dictionary = snapshot.get("game_state", {})
	var flags: Dictionary = game_state.get("flags", {})
	_expect(bool(flags.get("sangchul_met", false))
			and bool(flags.get("arc_sangchul_met_seen", false)),
		"M04 did not complete Sangchul's final answer choice")
	_check_visible_surface(controller, "ko recap")
	return controller


func _check_close_result(result: Dictionary, month: int) -> void:
	_expect(bool(result.get("closed", false)),
		"M%02d did not close" % month)
	_expect(int(result.get("month_closed", -1)) == month,
		"M%02d close reported the wrong month" % month)
	_expect(int(result.get("weeks_elapsed", -1)) == month * 4,
		"M%02d close did not total %d weeks" % [month, month * 4])
	_expect(int(result.get("settlement_count", -1)) == month,
		"M%02d close did not total %d settlements" % [month, month])
	var game_state: Dictionary = result.get("game_state", {})
	_expect(int(game_state.get("turn", -1)) == 1 + month * 4,
		"M%02d close claimed elapsed weeks without reaching turn %d" % [
			month, 1 + month * 4])
	_expect(not bool(game_state.get("is_game_over", true)),
		"hostile default route ended before reaching M06 at M%02d" % month)
	var settlement: Dictionary = result.get("settlement", {})
	_expect(int(settlement.get("automatic_recovery_health", -1)) == 1
			and int(settlement.get("automatic_recovery_mental", -1)) == 2,
		"M%02d did not apply the declared automatic survival context" % month)


func _check_schedule(controller: Node, expected_route: String) -> void:
	var schedule: Dictionary = controller.call("qa_schedule")
	_expect(str(schedule.get("story_scene", "")) == EXPECTED_STORY_SCENE,
		"schedule no longer enters the canonical StoryMode scene")
	_expect(str(schedule.get("m02_route", "")) == expected_route,
		"M02 route expected %s, got %s" % [
			expected_route, str(schedule.get("m02_route", ""))])
	var months: Variant = schedule.get("months", {})
	_expect(months is Dictionary, "schedule months are not a dictionary")
	if not months is Dictionary:
		return
	var expected: Dictionary = EXPECTED_MONTHS_FALLOUT \
		if expected_route == "fallout" else EXPECTED_MONTHS_CLEAN
	_expect((months as Dictionary).size() == 6,
		"schedule does not contain exactly M01-M06")
	for month_id in expected:
		_expect(_string_array((months as Dictionary).get(month_id, []))
				== _string_array(expected[month_id]),
			"%s schedule drifted: %s" % [
				month_id, (months as Dictionary).get(month_id, [])])


func _check_m6_localization_and_contract(controller: Node) -> void:
	var localized_choices := {}
	for language in ["ko", "en"]:
		_expect(bool(controller.call("qa_set_language", language)),
			"M6 could not switch to %s" % language)
		var source: Dictionary = DataRegistry.find_event(M6_SOURCE_EVENT_ID)
		var clone: Dictionary = controller.call("qa_m6_event")
		_expect(not source.is_empty(), "%s M6 source event is missing" % language)
		_expect(str(clone.get("id", "")) == M6_EVENT_ID,
			"%s M6 clone id drifted" % language)
		var source_choices: Array = source.get("choices", [])
		var clone_choices: Array = clone.get("choices", [])
		_expect(clone_choices.size() == M6_SOURCE_CHOICES.size(),
			"%s M6 clone does not expose exactly five choices" % language)
		var texts: Array[String] = []
		for clone_index in range(mini(
				clone_choices.size(), M6_SOURCE_CHOICES.size())):
			var source_index := M6_SOURCE_CHOICES[clone_index]
			_expect(source_index < source_choices.size(),
				"%s M6 source choice %d is missing" % [language, source_index])
			if source_index >= source_choices.size():
				continue
			var source_choice: Dictionary = source_choices[source_index]
			var clone_choice: Dictionary = clone_choices[clone_index]
			for prose_key in ["text", "result_text"]:
				_expect(str(clone_choice.get(prose_key, ""))
						== str(source_choice.get(prose_key, "")),
					"%s M6 choice %d changed localized %s" % [
						language, clone_index, prose_key])
			texts.append(str(clone_choice.get("text", "")))
		localized_choices[language] = texts
		var forbidden_paths: Array[String] = []
		_collect_forbidden_m6_keys(clone, "event", forbidden_paths)
		_expect(forbidden_paths.is_empty(),
			"%s M6 clone retained V2 obligation/follow-up keys: %s" % [
				language, forbidden_paths])
	var ko_text := "\n".join(PackedStringArray(localized_choices.get("ko", [])))
	var en_text := "\n".join(PackedStringArray(localized_choices.get("en", [])))
	for name in ["다은", "재혁", "상철"]:
		_expect(name in ko_text, "Korean M6 choices lost %s" % name)
	for name in ["Daeun", "Jaehyuk", "Sangchul"]:
		_expect(name in en_text, "English M6 choices lost %s" % name)


func _collect_forbidden_m6_keys(
		value: Variant, path: String, found: Array[String]) -> void:
	if value is Dictionary:
		for raw_key in (value as Dictionary):
			var key := str(raw_key)
			var child_path := "%s.%s" % [path, key]
			if key.begins_with("v2_") or key in FORBIDDEN_M6_KEYS:
				found.append(child_path)
			_collect_forbidden_m6_keys(
				(value as Dictionary)[raw_key], child_path, found)
	elif value is Array:
		for index in range((value as Array).size()):
			_collect_forbidden_m6_keys(
				(value as Array)[index], "%s[%d]" % [path, index], found)


func _check_zero_commitments(controller: Node, context: String) -> void:
	_expect(int(controller.call("qa_monthly_action_receipt_count")) == 0,
		"%s reported a monthly action receipt" % context)
	var snapshot: Dictionary = controller.call("qa_session_snapshot")
	for forbidden_key in ["commitments", "monthly_actions", "action_board"]:
		_expect(not snapshot.has(forbidden_key),
			"%s session restored %s" % [context, forbidden_key])
	var game_state: Dictionary = snapshot.get("game_state", {})
	var pending: Variant = game_state.get("pending_weekly_commitment", {})
	var weekly: Variant = game_state.get("weekly_commitments", [])
	_expect(pending is Dictionary and (pending as Dictionary).is_empty(),
		"%s created a pending monthly/weekly commitment" % context)
	_expect(weekly is Array and (weekly as Array).is_empty(),
		"%s created a commitment receipt" % context)


func _check_visible_surface(controller: Node, context: String) -> void:
	var visible := str(controller.call("qa_visible_text"))
	var folded := visible.to_lower()
	for term in FORBIDDEN_SURFACE_TERMS:
		_expect(term.to_lower() not in folded,
			"%s exposed removed monthly-action term %s" % [context, term])
	if context.begins_with("en"):
		_expect(not _contains_hangul(visible.replace("한국어", "")),
			"%s leaked Korean choice or settlement text: %s" % [
				context, visible.replace("\n", " | ")])


func _contains_hangul(value: String) -> bool:
	for character in value:
		var code := character.unicode_at(0)
		if (code >= 0x1100 and code <= 0x11FF) \
				or (code >= 0x3130 and code <= 0x318F) \
				or (code >= 0xAC00 and code <= 0xD7A3):
			return true
	return false


func _check_owned_resources_and_scope() -> void:
	for path in [
		PLAYTEST_SCENE_PATH,
		"res://playtests/order124/StoryChoiceM1M6Playtest.gd",
		"res://tools/StoryChoiceM1M6Check.tscn",
		AUDIT_SCOPE_PATH,
	]:
		_expect(ResourceLoader.exists(path) or FileAccess.file_exists(path),
			"missing ORDER-124 focused resource: %s" % path)
	var parsed: Variant = JSON.parse_string(_read_text(AUDIT_SCOPE_PATH))
	_expect(parsed is Dictionary, "audit_scope.json did not parse")
	if not parsed is Dictionary:
		return
	var lane: Dictionary = {}
	for raw_lane in (parsed as Dictionary).get("fast_lanes", []):
		if raw_lane is Dictionary and str(
				(raw_lane as Dictionary).get("id", "")) \
				== "story-choice-m1m6-runtime":
			lane = (raw_lane as Dictionary).duplicate(true)
			break
	_expect(not lane.is_empty(), "story-choice-m1m6-runtime lane is missing")
	if lane.is_empty():
		return
	_expect(_string_array(lane.get("paths", []))
			== _string_array(EXPECTED_LANE_PATHS),
		"ORDER-124 runtime lane paths are broad or incomplete")
	_expect(lane.get("tools", []) == ["tools/StoryChoiceM1M6Check.tscn"],
		"ORDER-124 runtime lane selected a broad check set")
	var owned: Array = lane.get("owned_paths", [])
	for product_path in [
		"project.godot",
		"export_presets.cfg",
		"autoloads/GameState.gd",
		"autoloads/SaveManager.gd",
		"scenes/StoryMode.gd",
		"systems/DemoCoreLoopV2.gd",
	]:
		_expect(product_path not in owned,
			"ORDER-124 runtime lane owns protected product file %s" % product_path)


func _protected_save_paths() -> Array:
	var paths: Array = []
	for playtest in [false, true]:
		var namespace_paths: Dictionary = \
			BUILD_FLAVOR.user_data_paths_for_playtest(playtest)
		for raw_path in namespace_paths.values():
			var path := str(raw_path)
			for candidate in [path, "%s.bak" % path, "%s.tmp" % path]:
				if candidate not in paths:
					paths.append(candidate)
	return paths


func _globalized_paths(paths: Array) -> Array:
	var result: Array = []
	for raw_path in paths:
		var absolute := ProjectSettings.globalize_path(str(raw_path))
		if absolute not in result:
			result.append(absolute)
	return result


func _capture_files(paths: Array) -> Dictionary:
	var captured := {}
	for raw_path in paths:
		var path := str(raw_path)
		captured[path] = {
			"exists": FileAccess.file_exists(path),
			"bytes": FileAccess.get_file_as_bytes(path)
				if FileAccess.file_exists(path) else PackedByteArray(),
		}
	return captured


func _expect_files_unchanged(before: Dictionary, label: String) -> void:
	for raw_path in before:
		var path := str(raw_path)
		var expected: Dictionary = before[raw_path]
		var exists := FileAccess.file_exists(path)
		_expect(exists == bool(expected.get("exists", false)),
			"%s existence changed: %s" % [label, path])
		if exists and bool(expected.get("exists", false)):
			_expect(FileAccess.get_file_as_bytes(path) == expected.get("bytes"),
				"%s bytes changed: %s" % [label, path])


func _restore_files(before: Dictionary) -> void:
	for raw_path in before:
		var path := str(raw_path)
		var absolute := ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(absolute)
		var snapshot: Dictionary = before[raw_path]
		if bool(snapshot.get("exists", false)):
			var file := FileAccess.open(path, FileAccess.WRITE)
			if file == null:
				_expect(false, "could not restore pre-check file %s" % path)
				continue
			file.store_buffer(snapshot.get("bytes", PackedByteArray()))
			file.close()


func _restore_global_state() -> void:
	LocaleManager.language = _original_language
	DataRegistry.reload()
	GameState.load_from_dict(_original_game_state)
	_stop_audio()
	AudioManager.sfx_enabled = _original_sfx_enabled


func _stop_audio() -> void:
	var players: Variant = AudioManager.get("_pool")
	if not players is Array:
		return
	for player_variant in players:
		if player_variant is AudioStreamPlayer:
			var player := player_variant as AudioStreamPlayer
			player.stop()
			player.stream = null


func _free_controller(controller: Node) -> void:
	if is_instance_valid(controller):
		controller.free()


func _canonical(value: Variant) -> String:
	return JSON.stringify(_normalize_numbers(value), "", true)


func _normalize_numbers(value: Variant) -> Variant:
	if value is Dictionary:
		var normalized := {}
		for raw_key in (value as Dictionary):
			normalized[str(raw_key)] = _normalize_numbers(
				(value as Dictionary)[raw_key])
		return normalized
	if value is Array:
		var normalized: Array = []
		for item in value as Array:
			normalized.append(_normalize_numbers(item))
		return normalized
	if value is float and is_equal_approx(float(value), round(float(value))):
		return int(round(float(value)))
	return value


func _collect_value_differences(
		expected: Variant, actual: Variant, path: String,
		differences: Array[String]) -> void:
	if differences.size() >= 12:
		return
	if typeof(expected) != typeof(actual):
		differences.append("%s type %s != %s" % [
			path, type_string(typeof(expected)), type_string(typeof(actual))])
		return
	if expected is Dictionary:
		var keys: Array = (expected as Dictionary).keys()
		for key in (actual as Dictionary).keys():
			if key not in keys:
				keys.append(key)
		keys.sort_custom(func(a, b): return str(a) < str(b))
		for key in keys:
			if differences.size() >= 12:
				return
			if not (expected as Dictionary).has(key):
				differences.append("%s.%s only_actual=%s" % [
					path, key, str((actual as Dictionary).get(key))])
			elif not (actual as Dictionary).has(key):
				differences.append("%s.%s only_expected=%s" % [
					path, key, str((expected as Dictionary).get(key))])
			else:
				_collect_value_differences(
					(expected as Dictionary)[key], (actual as Dictionary)[key],
					"%s.%s" % [path, key], differences)
		return
	if expected is Array:
		if (expected as Array).size() != (actual as Array).size():
			differences.append("%s size %d != %d" % [
				path, (expected as Array).size(), (actual as Array).size()])
			return
		for index in range((expected as Array).size()):
			_collect_value_differences(
				(expected as Array)[index], (actual as Array)[index],
				"%s[%d]" % [path, index], differences)
		return
	if expected != actual:
		differences.append("%s %s != %s" % [path, str(expected), str(actual)])


func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item in value as Array:
			result.append(str(item))
	return result


func _read_text(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text := file.get_as_text()
	file.close()
	return text


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if not _candidate_files_before.is_empty():
		_restore_files(_candidate_files_before)
	if not _protected_files_before.is_empty():
		_expect_files_unchanged(_protected_files_before,
			"retail/V2 save namespace")
		# A failed hostile route can invoke the product game-over callback. Restore
		# the byte snapshot even on a red gate so a diagnostic cannot contaminate
		# the player's retail or V2 history.
		_restore_files(_protected_files_before)
	if not _original_game_state.is_empty():
		_restore_global_state()
	if not _isolated_shared_files_before.is_empty():
		_restore_files(_isolated_shared_files_before)
	_restore_project_user_namespace()
	if _failures.is_empty():
		print("STORY_CHOICE_M1M6_CHECK_OK months=6 weeks=24 settlements=6 commitments=0 routes=2 save=1 m6=1 returns=2 overlay=1")
	else:
		for failure in _failures:
			push_error("STORY_CHOICE_M1M6_CHECK: %s" % failure)
	get_tree().quit(0 if _failures.is_empty() else 1)
