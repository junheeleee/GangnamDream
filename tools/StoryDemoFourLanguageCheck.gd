extends Node
## Product-level contract for the public KO/EN/JA/zh-CN/zh-TW M01-M06 demo.

const CONTROLLER_SCENE := preload(
	"res://playtests/order124/StoryChoiceM1M6Playtest.tscn")
const STORY_SCENE := preload("res://scenes/StoryMode.tscn")
const PUBLIC_SAVE_PATH := "user://story_demo_save.json"
const PUBLIC_PROFILE := "story_demo_rc"
const PUBLIC_BUILD_ID := "2026.08.31.1"
const PUBLIC_LANGUAGES: Array[String] = ["ko", "en", "ja", "zh-CN", "zh-TW"]
const RUNTIME_QA_ARG := "--story-demo-runtime-qa"
const RUNTIME_QA_ARG_DIR := "GangnamDream_StoryDemo_RuntimeQA_audit"
const M6_EVENT_ID := "order124_m6_first_bill"
const M6_LEDGER_EVENT_ID := "v2_demo_first_bill_ledger"
const M6_RESTITUTION_EVENT_ID := "v2_dirty_trace_initial_call"
const M6_ESCALATION_EVENT_ID := "v2_dirty_recruiter_week24"
const EVENT_IDS: Array[String] = [
	"arc_temptation_01",
	"arc_temptation_clean",
	"arc_temptation_fallout",
	"arc_daeun_01_meet",
	"arc_jiyeon_01_crash",
	"arc_sangchul_01_meet",
	"arc_sangchul_01_measure",
	"arc_sangchul_01_coffee",
	"arc_sangchul_01_answer",
	"arc_jaehyuk_01_reunion",
	M6_RESTITUTION_EVENT_ID,
	M6_ESCALATION_EVENT_ID,
	"v2_demo_first_bill",
	M6_LEDGER_EVENT_ID,
]
const LOCALE_ROUTES: Array[Dictionary] = [
	{
		"route": "clean", "coffee": false, "daeun": 0, "jiyeon": 0,
		"answer": 0, "jaehyuk": 0, "dirty_root": 0, "m6": 0,
	},
	{
		"route": "restitution", "coffee": true, "daeun": 1, "jiyeon": 1,
		"answer": 1, "jaehyuk": 1, "dirty_root": 0, "m6": 0,
	},
	{
		"route": "escalation", "coffee": false, "daeun": 0, "jiyeon": 2,
		"answer": 2, "jaehyuk": 0, "dirty_root": 1, "m6": 1,
	},
	{
		"route": "restitution", "coffee": true, "daeun": 1, "jiyeon": 0,
		"answer": 0, "jaehyuk": 1, "dirty_root": 1, "m6": 2,
	},
	{
		"route": "escalation", "coffee": true, "daeun": 0, "jiyeon": 1,
		"answer": 2, "jaehyuk": 0, "dirty_root": 0, "m6": 3,
	},
]
const FORBIDDEN_SURFACE: Array[String] = [
	"주력", "함께", "여력", "행동판", "행동 카드", "월간 행동", "확인 제출",
	"primary", "alongside", "margin", "action board", "action card",
	"monthly action", "submit selection",
]
const ACTION_LEDGER_KEYS: Array[String] = [
	"grind_streak_weeks",
	"money_weeks_total",
	"human_weeks_total",
	"money_only_weeks_total",
	"human_only_weeks_total",
	"both_axes_weeks_total",
	"unmarked_weeks_total",
	"classified_weeks_total",
	"loop_tint_spent",
	"month_money_weeks",
	"month_human_weeks",
	"last_month_money_weeks",
	"last_month_human_weeks",
	"action_axis_this_week",
	"action_places_this_week",
	"action_records_this_week",
	"recent_action_places",
	"recent_action_weeks",
	"pending_weekly_commitment",
	"weekly_commitments",
	"forgone_path_debts",
]
const CHINESE_SAMPLE := "汉语門裡"

var _failures: Array[String] = []
var _months_checked := 0
var _weeks_checked := 0
var _settlements_checked := 0
var _save_roundtrips := 0
var _story_surfaces_checked := 0
var _storymode_semantic_backup_recoveries := 0
var _observed_route_counts := {
	"arc_temptation_clean": 0,
	"arc_temptation_fallout": 0,
	M6_RESTITUTION_EVENT_ID: 0,
	M6_ESCALATION_EVENT_ID: 0,
	"arc_sangchul_01_measure": 0,
	"arc_sangchul_01_coffee": 0,
}


func _ready() -> void:
	var bootstrap_name := OS.get_environment("STORY_DEMO_QA_BOOTSTRAP_NAME")
	if OS.get_cmdline_user_args().has(RUNTIME_QA_ARG):
		bootstrap_name = RUNTIME_QA_ARG_DIR
	if bootstrap_name.begins_with("GangnamDream_StoryDemo_RuntimeQA_"):
		ProjectSettings.set_setting(
			"application/config/use_custom_user_dir", true)
		ProjectSettings.set_setting(
			"application/config/custom_user_dir_name", bootstrap_name)
	call_deferred("_run")


func _run() -> void:
	# The route sweep advances thirty settlements in a few frames. It validates
	# state, not audio mixing, so do not leave active WAV playbacks at process exit.
	AudioManager.sfx_enabled = false
	if not _public_qa_namespace_isolated():
		_failures.append(
			"check refused to touch anything outside a StoryDemo RuntimeQA namespace")
		_finish()
		return
	var user_dir_error := DirAccess.make_dir_recursive_absolute(OS.get_user_data_dir())
	if user_dir_error != OK and user_dir_error != ERR_ALREADY_EXISTS:
		_failures.append("could not create isolated RuntimeQA user directory")
		_finish()
		return
	_remove_candidate_files()
	_remove_settings_file()
	_check_story_language_contract()
	await _check_failed_story_return_uncover()
	_remove_candidate_files()

	var controller := _new_controller()
	if controller == null:
		_finish()
		return
	_expect(str(controller.call("qa_screen")) == "language",
		"first public launch did not open the five-language gate")
	_expect(str(controller.call("qa_autosave_path")) == PUBLIC_SAVE_PATH,
		"public demo autosave path drifted")
	var data_contract: Dictionary = controller.call("qa_user_data_contract")
	_expect(bool(data_contract.get("isolated", false)),
		"controller did not recognize the public QA namespace as isolated")
	_expect(bool(controller.call("qa_set_language", "en")),
		"first-launch English selection failed")
	_expect(FileAccess.file_exists(SaveManager.settings_path()) \
			and str(SaveManager.get_setting("language", "")) == "en",
		"selecting default English did not persist the first-launch language gate")

	for locale_index in range(PUBLIC_LANGUAGES.size()):
		var language := PUBLIC_LANGUAGES[locale_index]
		var route_config: Dictionary = LOCALE_ROUTES[locale_index]
		if not await _run_locale(controller, language, route_config):
			break
		_check_controller_backup_recovery(controller, language)
		_free_controller(controller)
		controller = _new_controller()
		if controller == null:
			break
		_expect(bool(controller.call("qa_continue_run")),
			"%s completed save could not resume" % language)
		_expect(str(controller.call("qa_screen")) == "recap",
			"%s completed save did not resume to recap" % language)
		var resumed: Dictionary = controller.call("qa_session_snapshot")
		_expect(int(resumed.get("elapsed_weeks", -1)) == 24,
			"%s resumed save changed elapsed weeks" % language)
		_expect(int(resumed.get("monthly_pressure_count", -1)) == 6,
			"%s resumed save changed settlement count" % language)
		_check_action_ledger(controller, language, "resumed recap")
		_save_roundtrips += 1
		_free_controller(controller)
		_remove_candidate_files()
		controller = _new_controller()
		if controller == null:
			break

	if is_instance_valid(controller):
		await controller.call("qa_cleanup_transient_story_runtime")
	_free_controller(controller)
	_expect(int(_observed_route_counts["arc_temptation_clean"]) > 0 \
			and int(_observed_route_counts["arc_temptation_fallout"]) > 0,
		"five-locale sweep did not cover both M02 routes")
	_expect(int(_observed_route_counts[M6_RESTITUTION_EVENT_ID]) > 0 \
			and int(_observed_route_counts[M6_ESCALATION_EVENT_ID]) > 0,
		"five-locale sweep did not cover both dirty M6 consequence roots")
	_expect(int(_observed_route_counts["arc_sangchul_01_measure"]) > 0 \
			and int(_observed_route_counts["arc_sangchul_01_coffee"]) > 0,
		"five-locale sweep did not cover both M04 routes")
	_expect(_storymode_semantic_backup_recoveries == 1,
		"five-locale sweep did not prove StoryMode semantic .bak recovery")
	_finish()


func _check_failed_story_return_uncover() -> void:
	GameState.returning_from_story = true
	SceneTransition.call("_set_transition_alpha", 1.0)
	var overlay_node := SceneTransition.get("_overlay") as ColorRect
	if is_instance_valid(overlay_node):
		overlay_node.mouse_filter = Control.MOUSE_FILTER_STOP
	var controller := CONTROLLER_SCENE.instantiate()
	add_child(controller)
	controller.call("qa_set_auto_launch", false)
	await get_tree().create_timer(0.6).timeout
	# Let the home screen's deferred focus handoff finish before this temporary
	# controller is freed. Otherwise a passing recovery check can leave a false
	# engine error when the deferred call sees an already-freed control.
	await get_tree().process_frame
	await get_tree().process_frame
	var overlay: Dictionary = controller.call("qa_transition_overlay_state")
	_expect(str(controller.call("qa_screen")) == "home",
		"damaged/missing story return did not recover to the demo home")
	_expect(not GameState.returning_from_story,
		"damaged/missing story return flag was not cleared")
	_expect(float(overlay.get("alpha", 1.0)) <= 0.01,
		"damaged/missing story return left a black cover")
	_expect(not bool(overlay.get("blocks_input", true)),
		"damaged/missing story return kept input blocked")
	_free_controller(controller)


func _check_controller_backup_recovery(
		controller: Node, language: String) -> void:
	var primary_bytes := FileAccess.get_file_as_bytes(PUBLIC_SAVE_PATH)
	_expect(not primary_bytes.is_empty(),
		"%s backup recovery fixture lacks a primary save" % language)
	if primary_bytes.is_empty():
		return
	var backup := FileAccess.open("%s.bak" % PUBLIC_SAVE_PATH, FileAccess.WRITE)
	_expect(backup != null,
		"%s could not stage the backup recovery fixture" % language)
	if backup == null:
		return
	backup.store_buffer(primary_bytes)
	backup.close()
	var corrupt_primary := FileAccess.open(PUBLIC_SAVE_PATH, FileAccess.WRITE)
	_expect(corrupt_primary != null,
		"%s could not corrupt the primary recovery fixture" % language)
	if corrupt_primary == null:
		return
	var semantic_corruption: Dictionary = controller.call("qa_session_snapshot")
	var coherent_turn := int((semantic_corruption.get(
		"game_state", {}) as Dictionary).get("turn", -1))
	semantic_corruption["game_state"] = {"turn": coherent_turn}
	corrupt_primary.store_string(JSON.stringify(semantic_corruption))
	corrupt_primary.close()
	_expect(bool(controller.call("qa_continue_run")),
		"%s did not recover its controller session from .bak" % language)
	_expect(str(controller.call("qa_screen")) == "recap",
		"%s backup recovery did not preserve the finished recap" % language)


func _run_locale(
		controller: Node, language: String,
		route_config: Dictionary) -> bool:
	var before_failures := _failures.size()
	var route := str(route_config.get("route", ""))
	var fallout := route != "clean"
	var coffee := bool(route_config.get("coffee", false))
	_expect(route in ["clean", "restitution", "escalation"],
		"%s has an invalid QA route: %s" % [language, route])
	_expect(bool(controller.call("qa_set_language", language)),
		"%s could not be selected" % language)
	controller.call("_show_home")
	_check_visible_surface(controller, language, "home")
	await _check_story_surface(controller, language)
	_expect(bool(controller.call("qa_start_new_run")),
		"%s could not start a new run" % language)
	var initial: Dictionary = controller.call("qa_session_snapshot")
	_expect(str(initial.get("profile", "")) == PUBLIC_PROFILE,
		"%s session profile drifted" % language)
	_expect(str(initial.get("phase", "")) == "transition",
		"%s did not start at the first transition" % language)
	_check_action_ledger(controller, language, "new run")
	_check_restart_confirmation_scope(controller, language)
	if language == "ko":
		for fault in ["corrupt_temporary", "corrupt_primary"]:
			var writer_result: Dictionary = controller.call(
				"qa_session_writer_fault", fault)
			_expect(bool(writer_result.get("allowed", false)) \
					and not bool(writer_result.get("accepted", true)) \
					and bool(writer_result.get("primary_preserved", false)) \
					and bool(writer_result.get("readable", false)) \
					and bool(writer_result.get("temporary_absent", false)) \
					and bool(writer_result.get("recovery_absent", false)),
				"verified controller writer failed %s rollback: %s" % [
					fault, writer_result])

	for month in range(1, 7):
		_expect(int(controller.call("qa_current_month")) == month,
			"%s reached wrong month before M%02d" % [language, month])
		_check_visible_surface(controller, language, "M%02d transition" % month)
		if month == 6:
			var prepared: Dictionary = controller.call(
				"qa_prepare_m6_route_context")
			_expect(bool(prepared.get("ok", false)) \
					and bool(prepared.get("saved", false)),
				"%s M06 route context did not commit: %s" % [
					language, prepared])
		var observed_ids: Array[String] = []
		var guard := 0
		while guard < 8:
			var schedule: Dictionary = controller.call("qa_schedule")
			var remaining: Array = schedule.get("current_event_ids", [])
			if remaining.is_empty():
				break
			var event_id := str(remaining.front())
			_check_localized_event(language, event_id)
			if event_id == M6_EVENT_ID:
				_check_m6_history_surface(language, route_config)
			var choice_index := _choice_index(event_id, route_config)
			var choice: Dictionary = controller.call(
				"qa_choose_event", event_id, choice_index)
			_expect(bool(choice.get("accepted", false))
					and bool(choice.get("applied", false)),
				"%s M%02d %s choice %d failed: %s" % [
					language, month, event_id, choice_index,
					str(choice.get("reason", "")),
				])
			if not bool(choice.get("applied", false)):
				return false
			observed_ids.append(event_id)
			_record_observed_route(event_id)
			_check_action_ledger(
				controller, language, "M%02d %s choice" % [month, event_id])
			guard += 1
		_expect(guard < 8, "%s M%02d story chain did not terminate" % [language, month])
		if month == 2:
			var expected_m02 := "arc_temptation_fallout" \
				if fallout else "arc_temptation_clean"
			_expect(observed_ids == [expected_m02],
				"%s M02 observed %s instead of the %s route" % [
					language, observed_ids, expected_m02])
		elif month == 4:
			var expected_m04_branch := "arc_sangchul_01_coffee" \
				if coffee else "arc_sangchul_01_measure"
			var expected_m04: Array[String] = [
				"arc_sangchul_01_meet",
				expected_m04_branch,
				"arc_sangchul_01_answer",
			]
			_expect(observed_ids == expected_m04,
				"%s M04 observed %s instead of root -> %s -> answer" % [
					language, observed_ids, expected_m04_branch])
		elif month == 6:
			var expected_m06: Array[String] = [M6_EVENT_ID]
			if route == "restitution":
				expected_m06.push_front(M6_RESTITUTION_EVENT_ID)
			elif route == "escalation":
				expected_m06.push_front(M6_ESCALATION_EVENT_ID)
			_expect(observed_ids == expected_m06,
				"%s M06 observed %s instead of %s" % [
					language, observed_ids, expected_m06])
			var context: Dictionary = controller.call("qa_m6_route_context")
			var expected_root := ""
			if route == "restitution":
				expected_root = M6_RESTITUTION_EVENT_ID
			elif route == "escalation":
				expected_root = M6_ESCALATION_EVENT_ID
			_expect(str(context.get("root", "")) == expected_root,
				"%s M06 route context root drifted: %s" % [language, context])
			if route == "restitution":
				_expect(_deferred_event_count(
						GameState.deferred_events,
						"callback_escaped_dirty_trace") == 0,
					"%s restitution route left the claimed callback queued" % language)
			await _check_m6_ledger_surface(
				controller, language, int(route_config.get("m6", 0)))
			if route != "clean" and _storymode_semantic_backup_recoveries == 0:
				_check_storymode_semantic_backup_recovery(
					controller, language, expected_root)
		var closed: Dictionary = controller.call("qa_close_month", month)
		_expect(bool(closed.get("closed", false)),
			"%s M%02d did not close: %s" % [language, month, closed])
		_expect(int(closed.get("weeks_elapsed", -1)) == month * 4,
			"%s M%02d did not advance exactly four weeks" % [language, month])
		_expect(int(closed.get("settlement_count", -1)) == month,
			"%s M%02d did not settle exactly once" % [language, month])
		_check_action_ledger(controller, language, "M%02d settlement" % month)
		_months_checked += 1
		_weeks_checked += 4
		_settlements_checked += 1

	var snapshot: Dictionary = controller.call("qa_session_snapshot")
	_expect(int(snapshot.get("current_month", 0)) == 7,
		"%s did not finish after M06" % language)
	_expect(str(snapshot.get("phase", "")) == "recap",
		"%s did not finish on recap" % language)
	_expect((snapshot.get("settlements", []) as Array).size() == 6,
		"%s recap lacks six settlement receipts" % language)
	var expected_receipts := 9 if route == "clean" else 10
	_expect((snapshot.get("choices", []) as Array).size() == expected_receipts,
		"%s recap lacks the %d authored choice receipts" % [
			language, expected_receipts])
	var state: Dictionary = snapshot.get("game_state", {})
	_expect((state.get("weekly_commitments", []) as Array).is_empty(),
		"%s story demo wrote a weekly commitment" % language)
	_expect((state.get("pending_weekly_commitment", {}) as Dictionary).is_empty(),
		"%s story demo wrote a pending commitment" % language)
	_check_action_ledger(controller, language, "finished recap")
	_check_visible_surface(controller, language, "recap")
	_expect(FileAccess.file_exists(PUBLIC_SAVE_PATH),
		"%s did not write its isolated autosave" % language)
	return _failures.size() == before_failures


func _check_storymode_semantic_backup_recovery(
		controller: Node, language: String, root_event_id: String) -> void:
	var primary_bytes := FileAccess.get_file_as_bytes(PUBLIC_SAVE_PATH)
	var backup_path := "%s.bak" % PUBLIC_SAVE_PATH
	var backup_existed := FileAccess.file_exists(backup_path)
	var backup_before := FileAccess.get_file_as_bytes(backup_path) \
		if backup_existed else PackedByteArray()
	var parser := JSON.new()
	_expect(not primary_bytes.is_empty() \
			and parser.parse(primary_bytes.get_string_from_utf8()) == OK \
			and parser.data is Dictionary,
		"%s semantic backup fixture lacks a valid M06 primary" % language)
	if primary_bytes.is_empty() or not parser.data is Dictionary:
		return
	var valid_story: Dictionary = (parser.data as Dictionary).duplicate(true)
	valid_story["phase"] = "story"
	var valid_bytes := JSON.stringify(valid_story, "  ").to_utf8_buffer()
	var backup := FileAccess.open(backup_path, FileAccess.WRITE)
	_expect(backup != null,
		"%s could not stage the semantic StoryMode backup" % language)
	if backup == null:
		return
	backup.store_buffer(valid_bytes)
	backup.close()

	var corrupted := valid_story.duplicate(true)
	var corrupted_records: Array = []
	for raw_record in corrupted.get("choices", []):
		if raw_record is Dictionary and str((raw_record as Dictionary).get(
				"event_id", "")) == root_event_id:
			continue
		corrupted_records.append(
			(raw_record as Dictionary).duplicate(true) \
			if raw_record is Dictionary else raw_record)
	corrupted["choices"] = corrupted_records
	var corrupted_completed: Array = []
	for raw_event_id in corrupted.get("completed_event_ids", []):
		if str(raw_event_id) != root_event_id:
			corrupted_completed.append(raw_event_id)
	corrupted["completed_event_ids"] = corrupted_completed
	var corrupted_state: Dictionary = corrupted.get("game_state", {}).duplicate(true)
	var corrupted_flags: Dictionary = corrupted_state.get("flags", {}).duplicate(true)
	for choice_index in range(2):
		corrupted_flags.erase(
			"order124_choice__%s__%d" % [root_event_id, choice_index])
	corrupted_state["flags"] = corrupted_flags
	corrupted["game_state"] = corrupted_state
	_expect(not bool(controller.call(
			"qa_session_candidate_is_valid", corrupted)),
		"%s M06 receipt-before-root primary was not semantically corrupt" % language)
	var primary := FileAccess.open(PUBLIC_SAVE_PATH, FileAccess.WRITE)
	_expect(primary != null,
		"%s could not stage the semantic StoryMode primary" % language)
	if primary == null:
		_restore_story_demo_candidate_bytes(
			primary_bytes, backup_existed, backup_before)
		return
	primary.store_string(JSON.stringify(corrupted, "  "))
	primary.close()

	var story := STORY_SCENE.instantiate()
	var recovered: Dictionary = story.call(
		"_story_demo_controller_session_snapshot")
	story.free()
	var recovered_ids: Array = recovered.get("completed_event_ids", [])
	var valid_ids: Array = valid_story.get("completed_event_ids", [])
	_expect(not recovered.is_empty() \
			and JSON.stringify(recovered_ids, "", true) \
				== JSON.stringify(valid_ids, "", true) \
			and bool(controller.call(
				"qa_session_candidate_is_valid", recovered)),
		"%s StoryMode did not skip semantic-invalid primary for valid .bak" % language)
	if not recovered.is_empty():
		_storymode_semantic_backup_recoveries += 1
	_restore_story_demo_candidate_bytes(
		primary_bytes, backup_existed, backup_before)


func _restore_story_demo_candidate_bytes(
		primary_bytes: PackedByteArray, backup_existed: bool,
		backup_bytes: PackedByteArray) -> void:
	var primary := FileAccess.open(PUBLIC_SAVE_PATH, FileAccess.WRITE)
	if primary != null:
		primary.store_buffer(primary_bytes)
		primary.close()
	var backup_path := "%s.bak" % PUBLIC_SAVE_PATH
	if backup_existed:
		var backup := FileAccess.open(backup_path, FileAccess.WRITE)
		if backup != null:
			backup.store_buffer(backup_bytes)
			backup.close()
	elif FileAccess.file_exists(backup_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(backup_path))


func _check_restart_confirmation_scope(controller: Node, language: String) -> void:
	controller.call("_show_home")
	var before := JSON.stringify(
		controller.call("qa_session_snapshot"), "", true)
	var first_button := Button.new()
	controller.call("_on_start_pressed", first_button)
	_expect(bool(controller.get("_restart_armed")),
		"%s restart confirmation did not arm" % language)
	# Rebuild the same screen, as a compact-layout resize does.
	controller.call("_show_home")
	_expect(not bool(controller.get("_restart_armed")),
		"%s restart confirmation survived a rebuilt home button" % language)
	var rebuilt_button := Button.new()
	controller.call("_on_start_pressed", rebuilt_button)
	_expect(bool(controller.get("_restart_armed")) \
			and JSON.stringify(
				controller.call("qa_session_snapshot"), "", true) == before,
		"%s rebuilt start button overwrote the save without reconfirmation" % language)
	controller.set("_restart_armed", false)
	first_button.free()
	rebuilt_button.free()
	controller.call("_show_transition")


func _check_story_surface(controller: Node, language: String) -> void:
	var pending_before := GameState.pending_story_queue.duplicate()
	var return_before := GameState.story_return_scene
	var replay_before := GameState.story_replay_mode
	var controller_language_callback := Callable(
		controller, "_on_language_changed")
	var controller_callback_was_connected := \
		LocaleManager.language_changed.is_connected(controller_language_callback)
	if controller_callback_was_connected:
		# A real scene change frees the controller before StoryMode opens. Keep it
		# disconnected here so this test cannot accidentally mask a lost runtime
		# overlay by letting the off-screen controller reinstall it.
		LocaleManager.language_changed.disconnect(controller_language_callback)
	GameState.pending_story_queue = ["arc_temptation_01"]
	GameState.story_return_scene = \
		"res://playtests/order124/StoryChoiceM1M6Playtest.tscn"
	GameState.story_replay_mode = false
	var story := STORY_SCENE.instantiate()
	add_child(story)
	await get_tree().process_frame
	if story.has_method("_complete_typing"):
		story.call("_complete_typing")
	await get_tree().process_frame
	var visible := _visible_text(story)
	var event: Dictionary = DataRegistry.find_event("arc_temptation_01")
	var title := str(event.get("title", ""))
	_expect(not title.is_empty() and title in visible,
		"%s StoryMode did not render the localized M01 title" % language)
	if language != "ko":
		_expect(not _contains_hangul(visible),
			"%s StoryMode leaked Hangul: %s" % [
				language, visible.replace("\n", " | ")])
	if language not in ["ko", "en"]:
		_expect(_has_target_script(language, visible),
			"%s StoryMode did not render target-script prose" % language)
	story.call("_create_story_settings_popup", "language:%s" % language, false)
	await get_tree().process_frame
	await get_tree().process_frame
	_check_story_language_focus_graph(story, language)
	var switch_index := (PUBLIC_LANGUAGES.find(language) + 1) \
		% PUBLIC_LANGUAGES.size()
	var switched_language := PUBLIC_LANGUAGES[switch_index]
	story.call("_set_story_language", switched_language)
	await get_tree().process_frame
	await get_tree().process_frame
	_check_runtime_overlay_after_story_language_change(
		story, switched_language, "%s -> %s" % [language, switched_language])
	story.call("_set_story_language", language)
	await get_tree().process_frame
	await get_tree().process_frame
	_check_runtime_overlay_after_story_language_change(
		story, language, "%s -> %s" % [switched_language, language])
	_story_surfaces_checked += 1
	story.call("_close_audio_settings")
	await get_tree().process_frame
	if story.get_parent() != null:
		story.get_parent().remove_child(story)
	story.free()
	if controller_callback_was_connected:
		LocaleManager.language_changed.connect(controller_language_callback)
	GameState.pending_story_queue = pending_before
	GameState.story_return_scene = return_before
	GameState.story_replay_mode = replay_before


func _check_m6_history_surface(
		language: String, route_config: Dictionary) -> void:
	var m6: Dictionary = DataRegistry.find_event(M6_EVENT_ID)
	_expect(not m6.is_empty(), "%s M06 runtime event is missing" % language)
	if m6.is_empty():
		return
	var description := str(m6.get("description", ""))
	var m6_choices: Array = m6.get("choices", [])
	_expect(m6_choices.size() == 5,
		"%s M06 runtime event lost its five choices" % language)
	for choice_index in range(m6_choices.size()):
		_expect(str((m6_choices[choice_index] as Dictionary).get(
			"follow_up_event", "")) == M6_LEDGER_EVENT_ID,
			"%s M06 choice %d lost the ledger follow-up" % [
				language, choice_index])
	if not m6_choices.is_empty():
		var daeun_copy := "%s\n%s" % [
			str((m6_choices[0] as Dictionary).get("text", "")),
			str((m6_choices[0] as Dictionary).get("result_text", "")),
		]
		if int(route_config.get("daeun", 0)) == 1:
			var localized_name: String = str({
				"ko": "다은", "en": "Daeun", "ja": "ダウン",
				"zh-CN": "Daeun", "zh-TW": "Daeun",
			}.get(language, "Daeun"))
			_expect(localized_name not in daeun_copy,
				"%s M06 unknown-clerk route invented Daeun's name" % language)
		else:
			var source: Dictionary = DataRegistry.find_event("v2_demo_first_bill")
			var source_choices: Array = source.get("choices", [])
			if source_choices.size() > 3:
				var known_copy := "%s\n%s" % [
					str((source_choices[3] as Dictionary).get("text", "")),
					str((source_choices[3] as Dictionary).get("result_text", "")),
				]
				_expect(daeun_copy == known_copy,
					"%s M06 known-Daeun route changed its exact copy" % language)
	var expected_history: Array[Dictionary] = [
		{"event_id": "arc_daeun_01_meet", "choice": int(
			route_config.get("daeun", 0))},
		{"event_id": "arc_jiyeon_01_crash", "choice": int(
			route_config.get("jiyeon", 0))},
		{"event_id": "arc_sangchul_01_meet", "choice": 1 if bool(
			route_config.get("coffee", false)) else 0},
		{"event_id": "arc_sangchul_01_answer", "choice": int(
			route_config.get("answer", 0))},
		{"event_id": "arc_jaehyuk_01_reunion", "choice": int(
			route_config.get("jaehyuk", 0))},
	]
	for expected in expected_history:
		var event_id := str(expected.get("event_id", ""))
		var source: Dictionary = DataRegistry.find_event(event_id)
		var choices: Array = source.get("choices", [])
		var choice_index := int(expected.get("choice", -1))
		_expect(choice_index >= 0 and choice_index < choices.size(),
			"%s M06 history source is invalid: %s[%d]" % [
				language, event_id, choice_index])
		if choice_index < 0 or choice_index >= choices.size():
			continue
		var exact_text := str((choices[choice_index] as Dictionary).get(
			"text", "")).strip_edges()
		_expect(not exact_text.is_empty() and exact_text in description,
			"%s M06 did not read the exact selected %s[%d] copy: %s" % [
				language, event_id, choice_index, exact_text])


func _check_m6_ledger_surface(
		controller: Node, language: String, selected_index: int) -> void:
	_check_localized_event(language, M6_LEDGER_EVENT_ID)
	var m6: Dictionary = DataRegistry.find_event(M6_EVENT_ID)
	var m6_choices: Array = m6.get("choices", [])
	_expect(selected_index >= 0 and selected_index < m6_choices.size(),
		"%s M06 ledger received an invalid selected index %d" % [
			language, selected_index])
	if selected_index < 0 or selected_index >= m6_choices.size():
		return
	var ledger: Dictionary = DataRegistry.find_event(M6_LEDGER_EVENT_ID)
	var ledger_choices: Array = ledger.get("choices", [])
	_expect(ledger_choices.size() == 1,
		"%s M06 ledger must expose exactly one closing expression" % language)
	if ledger_choices.size() != 1:
		return
	_expect(GameState.is_expression_choice(ledger_choices[0] as Dictionary),
		"%s M06 ledger closing choice is not state-free expression" % language)

	var pending_before := GameState.pending_story_queue.duplicate(true)
	var return_before := GameState.story_return_scene
	var replay_before := GameState.story_replay_mode
	var returning_before := GameState.returning_from_story
	var state_before: Dictionary = GameState.serialize().duplicate(true)
	var controller_receipts_before := (
		(controller.call("qa_session_snapshot") as Dictionary).get(
			"choices", []) as Array).duplicate(true)
	GameState.pending_story_queue = [M6_LEDGER_EVENT_ID]
	GameState.story_return_scene = \
		"res://playtests/order124/StoryChoiceM1M6Playtest.tscn"
	GameState.story_replay_mode = false
	GameState.returning_from_story = false
	var story := STORY_SCENE.instantiate()
	add_child(story)
	await get_tree().process_frame
	await get_tree().process_frame
	var current: Dictionary = story.get("_current")
	_expect(str(current.get("id", "")) == M6_LEDGER_EVENT_ID,
		"%s StoryMode did not open the M06 consequence ledger" % language)
	var resolved := str(story.call("_current_story_phase_text"))
	for choice_index in range(m6_choices.size()):
		var exact_text := str((m6_choices[choice_index] as Dictionary).get(
			"text", "")).strip_edges()
		_expect(not exact_text.is_empty() and exact_text in resolved,
			"%s M06 ledger omitted %s choice %d: %s" % [
				language,
				"selected" if choice_index == selected_index else "forgone",
				choice_index, exact_text])
	if language != "ko":
		_expect(not _contains_hangul(resolved),
			"%s M06 ledger leaked Hangul: %s" % [
				language, resolved.replace("\n", " | ")])
	if language not in ["ko", "en"]:
		_expect(_has_target_script(language, resolved),
			"%s M06 ledger did not render target-script prose" % language)

	story.call("_on_choice", 0)
	var state_after: Dictionary = GameState.serialize().duplicate(true)
	var controller_receipts_after := (
		(controller.call("qa_session_snapshot") as Dictionary).get(
			"choices", []) as Array).duplicate(true)
	_expect(JSON.stringify(state_after, "", true) \
			== JSON.stringify(state_before, "", true),
		"%s M06 ledger expression mutated serialized GameState" % language)
	_expect(controller_receipts_after == controller_receipts_before,
		"%s M06 ledger expression created a controller receipt" % language)
	_story_surfaces_checked += 1
	if story.get_parent() != null:
		story.get_parent().remove_child(story)
	story.free()
	GameState.load_from_dict(state_before)
	GameState.pending_story_queue = pending_before
	GameState.story_return_scene = return_before
	GameState.story_replay_mode = replay_before
	GameState.returning_from_story = returning_before


static func _deferred_event_count(raw_events: Variant, event_id: String) -> int:
	if not raw_events is Array:
		return 0
	var count := 0
	for raw_event in raw_events as Array:
		if raw_event is Dictionary \
				and str((raw_event as Dictionary).get("event_id", "")) == event_id:
			count += 1
	return count


func _check_runtime_overlay_after_story_language_change(
		story: Node, language: String, context: String) -> void:
	var current: Dictionary = story.get("_current")
	var choices: Array = current.get("choices", [])
	var expected_receipt := "order124_choice__arc_temptation_01__0"
	_expect(not choices.is_empty() \
		and expected_receipt in (choices[0] as Dictionary).get("flags", []),
		"%s erased the active choice receipt overlay" % context)
	var m6: Dictionary = DataRegistry.find_event(M6_EVENT_ID)
	_expect(not m6.is_empty() and (m6.get("choices", []) as Array).size() == 5,
		"%s erased the synthetic M6 event" % context)
	var title := str(current.get("title", ""))
	var visible := _visible_text(story)
	_expect(not title.is_empty() and title in visible,
		"%s did not refresh active StoryMode prose" % context)
	if language != "ko":
		_expect(not _contains_hangul(visible),
			"%s left Hangul on the refreshed StoryMode surface: %s" % [
				context, visible.replace("\n", " | ")])
	var save_label := str(story.call("_story_save_primary_text", {
		"event_id": "arc_temptation_01",
		"chapter": 1,
		"turn": 1,
		"label": "챕터 1 · 오래된 한국어 제목",
	}))
	if language != "ko":
		_expect(not _contains_hangul(save_label),
			"%s reused a stale-locale manual-save label: %s" % [
				context, save_label])


func _visible_text(root: Node) -> String:
	var lines := PackedStringArray()
	_collect_visible_text(root, lines)
	return "\n".join(lines)


func _collect_visible_text(node: Node, lines: PackedStringArray) -> void:
	if node is CanvasItem and not (node as CanvasItem).is_visible_in_tree():
		return
	var text := ""
	if node is RichTextLabel:
		text = (node as RichTextLabel).get_parsed_text()
	elif node is Label:
		text = (node as Label).text
	elif node is Button:
		text = (node as Button).text
	if not text.strip_edges().is_empty():
		lines.append(text)
	for child in node.get_children():
		_collect_visible_text(child, lines)


func _choice_index(event_id: String, route_config: Dictionary) -> int:
	var route := str(route_config.get("route", ""))
	match event_id:
		"arc_temptation_01":
			return 0 if route == "clean" else 1
		"arc_temptation_fallout":
			return 0 if route == "restitution" else 1
		"arc_temptation_clean": return 0
		"arc_daeun_01_meet": return int(route_config.get("daeun", 0))
		"arc_jiyeon_01_crash": return int(route_config.get("jiyeon", 0))
		"arc_sangchul_01_meet":
			return 1 if bool(route_config.get("coffee", false)) else 0
		"arc_sangchul_01_answer": return int(route_config.get("answer", 0))
		"arc_jaehyuk_01_reunion": return int(route_config.get("jaehyuk", 0))
		M6_RESTITUTION_EVENT_ID, M6_ESCALATION_EVENT_ID:
			return int(route_config.get("dirty_root", 0))
		M6_EVENT_ID: return int(route_config.get("m6", 0))
	return 0


func _record_observed_route(event_id: String) -> void:
	if _observed_route_counts.has(event_id):
		_observed_route_counts[event_id] = \
			int(_observed_route_counts[event_id]) + 1


func _check_action_ledger(
		controller: Node, language: String, context: String) -> void:
	var raw_ledger: Variant = controller.call("qa_action_ledger_snapshot")
	_expect(raw_ledger is Dictionary,
		"%s %s did not expose the real action ledger" % [language, context])
	if not raw_ledger is Dictionary:
		return
	var ledger := raw_ledger as Dictionary
	_expect(ledger.size() == ACTION_LEDGER_KEYS.size(),
		"%s %s action ledger key count drifted: %s" % [
			language, context, ledger.keys()])
	for key in ACTION_LEDGER_KEYS:
		_expect(ledger.has(key),
			"%s %s action ledger omitted %s" % [language, context, key])
		if ledger.has(key):
			_expect(_action_ledger_value_is_zero(ledger[key]),
				"%s %s action ledger %s is not empty/zero: %s" % [
					language, context, key, ledger[key]])


func _action_ledger_value_is_zero(value: Variant) -> bool:
	if value == null:
		return true
	if value is bool:
		return not bool(value)
	if value is int or value is float:
		return is_zero_approx(float(value))
	if value is String or value is StringName:
		return str(value).is_empty()
	if value is Array:
		return (value as Array).is_empty()
	if value is Dictionary:
		for nested in (value as Dictionary).values():
			if not _action_ledger_value_is_zero(nested):
				return false
		return true
	return false


func _check_story_language_focus_graph(story: Node, language: String) -> void:
	var raw_buttons: Variant = story.get("_story_language_buttons")
	_expect(raw_buttons is Dictionary,
		"%s StoryMode settings did not expose language buttons" % language)
	if not raw_buttons is Dictionary:
		return
	var buttons := raw_buttons as Dictionary
	var button_codes: Array[String] = []
	for raw_code in buttons.keys():
		button_codes.append(str(raw_code))
	_expect(button_codes == PUBLIC_LANGUAGES,
		"%s StoryMode settings language buttons are not exact/in order: %s" % [
			language, button_codes])
	var language_nodes: Dictionary = {}
	for code in PUBLIC_LANGUAGES:
		var button := buttons.get(code) as Button
		_expect(is_instance_valid(button),
			"%s StoryMode settings lacks the %s language button" % [language, code])
		if is_instance_valid(button):
			language_nodes[button] = code
	if language_nodes.size() != PUBLIC_LANGUAGES.size():
		return
	var first := buttons.get(PUBLIC_LANGUAGES.front()) as Button
	var last := buttons.get(PUBLIC_LANGUAGES.back()) as Button
	var right_walk := _walk_language_focus(first, "focus_neighbor_right", language_nodes)
	var left_walk := _walk_language_focus(last, "focus_neighbor_left", language_nodes)
	var reversed_languages := PUBLIC_LANGUAGES.duplicate()
	reversed_languages.reverse()
	_expect(right_walk == PUBLIC_LANGUAGES,
		"%s StoryMode right focus rail does not traverse all five languages: %s" % [
			language, right_walk])
	_expect(left_walk == reversed_languages,
		"%s StoryMode left focus rail does not traverse all five languages: %s" % [
			language, left_walk])
	var focused := get_viewport().gui_get_focus_owner()
	_expect(focused == buttons.get(language),
		"%s StoryMode settings did not focus the active language" % language)


func _walk_language_focus(
		start: Button, neighbor_property: StringName,
		language_nodes: Dictionary) -> Array[String]:
	var visited: Array[String] = []
	var current := start
	while is_instance_valid(current) and visited.size() < PUBLIC_LANGUAGES.size():
		if not language_nodes.has(current):
			break
		var code := str(language_nodes[current])
		if code in visited:
			break
		visited.append(code)
		var neighbor_path: NodePath = current.get(neighbor_property)
		var next := current.get_node_or_null(neighbor_path) as Button
		if not is_instance_valid(next):
			break
		current = next
	return visited


func _check_localized_event(language: String, event_id: String) -> void:
	var event: Dictionary = DataRegistry.find_event(event_id)
	_expect(not event.is_empty(), "%s event is missing: %s" % [language, event_id])
	if event.is_empty():
		return
	var visible_parts: Array[String] = [
		str(event.get("title", "")), str(event.get("description", "")),
	]
	for variant_key in ["description_if_known", "description_memory_if_known"]:
		var raw_variants: Variant = event.get(variant_key, {})
		if raw_variants is Dictionary:
			for variant_text in (raw_variants as Dictionary).values():
				visible_parts.append(str(variant_text))
	for choice_variant in event.get("choices", []):
		if choice_variant is Dictionary:
			visible_parts.append(str((choice_variant as Dictionary).get("text", "")))
			visible_parts.append(str((choice_variant as Dictionary).get("result_text", "")))
	for text in visible_parts:
		_expect(not text.strip_edges().is_empty(),
			"%s %s has an empty localized text leaf" % [language, event_id])
		if language not in ["ko", "en"]:
			_expect(not _contains_hangul(text),
				"%s %s leaked Hangul: %s" % [language, event_id, text])
			_expect(_has_target_script(language, text) or text in ["1+1", "1＋1"],
				"%s %s fell back to non-target prose: %s" % [language, event_id, text])


func _check_visible_surface(controller: Node, language: String, context: String) -> void:
	var visible := str(controller.call("qa_visible_text"))
	var folded := visible.to_lower()
	for term in FORBIDDEN_SURFACE:
		_expect(term.to_lower() not in folded,
			"%s %s exposed retired AP-board term %s" % [language, context, term])
	if language not in ["ko", "en"]:
		_expect(not _contains_hangul(visible),
			"%s %s leaked Hangul: %s" % [language, context, visible.replace("\n", " | ")])


func _check_story_language_contract() -> void:
	var story := STORY_SCENE.instantiate()
	var options: Array = story.call("_story_language_options")
	var codes: Array[String] = []
	for option_variant in options:
		if option_variant is Dictionary:
			codes.append(str((option_variant as Dictionary).get("key", "")))
	_expect(codes == PUBLIC_LANGUAGES,
		"StoryMode language selector is not the exact public locale list: %s" % [codes])
	var original_language := LocaleManager.language
	LocaleManager.language = "zh-CN"
	var cn_wait := float(story.call("_auto_reading_delay", CHINESE_SAMPLE))
	LocaleManager.language = "en"
	var en_wait := float(story.call("_auto_reading_delay", "one two three four"))
	LocaleManager.language = original_language
	_expect(cn_wait > 0.0 and en_wait > 0.0,
		"StoryMode auto-reading timing rejected a shipping script")
	story.free()


func _new_controller() -> Node:
	GameState.returning_from_story = false
	GameState.pending_story_queue.clear()
	GameState.story_return_scene = ""
	var controller := CONTROLLER_SCENE.instantiate()
	add_child(controller)
	if not controller.has_method("qa_start_new_run"):
		_failures.append("public controller QA surface is missing")
		controller.queue_free()
		return null
	controller.call("qa_set_auto_launch", false)
	return controller


func _free_controller(controller: Node) -> void:
	if not is_instance_valid(controller):
		return
	if controller.get_parent() != null:
		controller.get_parent().remove_child(controller)
	controller.free()


func _public_qa_namespace_isolated() -> bool:
	var configured_name := str(ProjectSettings.get_setting(
		"application/config/custom_user_dir_name", ""))
	return bool(ProjectSettings.get_setting(
		"application/config/use_custom_user_dir", false)) \
		and (OS.get_environment("STORY_DEMO_ALLOW_ISOLATED_QA") == "1" \
			or OS.get_cmdline_user_args().has(RUNTIME_QA_ARG)) \
		and configured_name.begins_with("GangnamDream_StoryDemo_RuntimeQA_")


func _remove_candidate_files() -> void:
	for path in [
		PUBLIC_SAVE_PATH,
		"%s.bak" % PUBLIC_SAVE_PATH,
		"%s.tmp" % PUBLIC_SAVE_PATH,
		"%s.bak.tmp" % PUBLIC_SAVE_PATH,
		"%s.recovery.tmp" % PUBLIC_SAVE_PATH,
	]:
		var absolute := ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(absolute):
			DirAccess.remove_absolute(absolute)


func _remove_settings_file() -> void:
	var settings_path := SaveManager.settings_path()
	for path in [settings_path, "%s.tmp" % settings_path, "%s.bak" % settings_path]:
		var absolute := ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(absolute):
			DirAccess.remove_absolute(absolute)


func _contains_hangul(text: String) -> bool:
	for index in range(text.length()):
		var codepoint := text.unicode_at(index)
		if codepoint >= 0x1100 and codepoint <= 0x11FF \
				or codepoint >= 0x3130 and codepoint <= 0x318F \
				or codepoint >= 0xAC00 and codepoint <= 0xD7A3:
			return true
	return false


func _has_target_script(language: String, text: String) -> bool:
	for index in range(text.length()):
		var codepoint := text.unicode_at(index)
		if language == "ja" and (codepoint >= 0x3040 and codepoint <= 0x30FF):
			return true
		if codepoint >= 0x3400 and codepoint <= 0x9FFF:
			return true
	return false


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	_remove_candidate_files()
	_stop_audio()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("STORY_DEMO_FOUR_LANGUAGE_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("STORY_DEMO_FOUR_LANGUAGE_CHECK_OK locales=5 routes=5 months=%d weeks=%d settlements=%d ap_surface=0 save=%d story=%d build=%s" % [
		_months_checked, _weeks_checked, _settlements_checked,
		_save_roundtrips, _story_surfaces_checked, PUBLIC_BUILD_ID,
	])
	get_tree().quit(0)


func _stop_audio() -> void:
	var players: Variant = AudioManager.get("_pool")
	if not players is Array:
		return
	for player_variant in players:
		if player_variant is AudioStreamPlayer:
			var player := player_variant as AudioStreamPlayer
			player.stop()
			player.stream = null
