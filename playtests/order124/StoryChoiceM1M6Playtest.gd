extends Control
## M01-M06 story-choice demo. The ORDER-124 QA namespace remains available,
## while the public story demo uses its own app identity and save namespace.

signal screen_changed(screen_name: String)

const PROFILE := "order124_m1m6_story_choice"
const BUILD_ID := "2026.08.24.3"
const SAVE_SCHEMA := 1
const SAVE_PATH := "user://story_choice_m1m6_playtest_save.json"
const STORY_SCENE := "res://scenes/StoryMode.tscn"
const SELF_SCENE := "res://playtests/order124/StoryChoiceM1M6Playtest.tscn"
const CUSTOM_USER_DIR := "GangnamDream_ORDER124_StoryChoice_v1"
const PUBLIC_PROFILE := "story_demo_rc"
const PUBLIC_BUILD_ID := "2026.08.25.1"
const PUBLIC_SAVE_PATH := "user://story_demo_save.json"
const PUBLIC_CUSTOM_USER_DIR := "GangnamDream_StoryDemo_v1"
const PUBLIC_LANGUAGES: Array[String] = ["ko", "en", "ja", "zh-CN", "zh-TW"]
const LEGACY_LANGUAGES: Array[String] = ["ko", "en"]
const PUBLIC_RUNTIME_QA_PREFIX := "GangnamDream_StoryDemo_RuntimeQA_"
const PUBLIC_RUNTIME_QA_ARG := "--story-demo-runtime-qa"
const PUBLIC_REAL_FLOW_ARG := "--story-demo-real-flow-smoke"
const PUBLIC_REAL_FLOW_CHOICE_ARG := "--story-demo-real-flow-choice="
const M6_EVENT_ID := "order124_m6_first_bill"
const M6_SOURCE_EVENT_ID := "v2_demo_first_bill"
const M6_SOURCE_CHOICES: Array[int] = [3, 4, 5, 6, 7]
const M4_ROOT_EVENT_ID := "arc_sangchul_01_meet"
const M4_MEASURE_EVENT_ID := "arc_sangchul_01_measure"
const M4_COFFEE_EVENT_ID := "arc_sangchul_01_coffee"
const M4_ANSWER_EVENT_ID := "arc_sangchul_01_answer"
const START_DIFFICULTY := "드라마"
const START_PROFILE := "알바"
const START_HEALTH_FLOOR := 70
const START_MENTAL_FLOOR := 72
const MONTHLY_RECOVERY_HEALTH := 1
const MONTHLY_RECOVERY_MENTAL := 2
const MONTH_EVENTS := {
	1: ["arc_temptation_01"],
	3: ["arc_daeun_01_meet", "arc_jiyeon_01_crash"],
	4: ["arc_sangchul_01_meet"],
	5: ["arc_jaehyuk_01_reunion"],
	6: [M6_EVENT_ID],
}
const RUNTIME_RECEIPT_EVENT_IDS: Array[String] = [
	"arc_temptation_01",
	"arc_temptation_clean",
	"arc_temptation_fallout",
	"arc_daeun_01_meet",
	"arc_jiyeon_01_crash",
	M4_ROOT_EVENT_ID,
	M4_MEASURE_EVENT_ID,
	M4_COFFEE_EVENT_ID,
	M4_ANSWER_EVENT_ID,
	"arc_jaehyuk_01_reunion",
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

const C_BG := Color("#090b10")
const C_PANEL := Color("#121722")
const C_PANEL_ALT := Color("#191f2c")
const C_BORDER := Color("#566377")
const C_TEXT := Color("#eef1f6")
const C_DIM := Color("#a2adbd")
const C_ACCENT := Color("#89a9d8")
const C_GOOD := Color("#86c7a0")
const C_WARN := Color("#d8b276")

var _session: Dictionary = {}
var _screen := "home"
var _compact := false
var _restart_armed := false
var _story_return_pending := false
var _screenshot_path := ""
var _screenshot_screen := "home"
var _screenshot_exit := false
var _auto_launch_enabled := true
var _transition_serial := 0
var _public_demo := false
var _language_gate_required := false
var _story_screenshot_instance: Node = null

var _page: MarginContainer
var _title: Label
var _subtitle: Label
var _home_button: Button
var _language_button: Button
var _body: Control
var _footer: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	set_process_unhandled_input(true)
	set_meta("order124_story_choice_playtest", true)
	_bootstrap_public_qa_namespace()
	_public_demo = _public_user_data_configured()
	set_meta("story_demo_public", _public_demo)
	if not _isolated_user_data_configured():
		push_error("STORY_DEMO_ISOLATION_FAIL: run only with an approved staged custom user-data namespace")
		get_tree().quit(1)
		return
	var args := OS.get_cmdline_user_args()
	var requested_language := _argument_value(
		args, "--story-demo-language=" if _public_demo else "--order124-language=")
	var has_saved_settings := FileAccess.file_exists(SaveManager.settings_path())
	if not _public_demo and requested_language.is_empty() and get_tree().current_scene == self \
			and not FileAccess.file_exists(SaveManager.settings_path()):
		requested_language = "ko"
	if requested_language in _available_languages():
		LocaleManager.set_language(requested_language)
	_language_gate_required = _public_demo and requested_language.is_empty() \
		and not has_saved_settings
	_compact = get_viewport_rect().size.y <= 650.0
	_build_shell()
	resized.connect(_on_resized)
	if not LocaleManager.language_changed.is_connected(_on_language_changed):
		LocaleManager.language_changed.connect(_on_language_changed)
	_install_runtime_events()
	var marker := "%s profile=%s build=%s scene=%s custom_user_dir=%s language=%s path=%s" % [
		"STORY_DEMO_NATIVE_ENTRY_OK" if _public_demo else "ORDER124_NATIVE_ENTRY_OK",
		_active_profile(), _active_build_id(), SELF_SCENE, _active_custom_user_dir(),
		LocaleManager.language, OS.get_user_data_dir()]
	print(marker)
	var native_probe_path := OS.get_environment(
		"STORY_DEMO_NATIVE_PROBE_PATH" if _public_demo else "ORDER124_NATIVE_PROBE_PATH")
	if native_probe_path.is_absolute_path():
		var native_probe := FileAccess.open(native_probe_path, FileAccess.WRITE)
		if native_probe != null:
			native_probe.store_line(marker)
	_auto_launch_enabled = not args.has(
		"--story-demo-smoke" if _public_demo else "--order124-smoke")
	_screenshot_path = _argument_value(args,
		"--story-demo-screenshot=" if _public_demo else "--order124-screenshot=")
	_screenshot_screen = _argument_value(
		args, "--story-demo-screenshot-screen=" if _public_demo \
		else "--order124-screenshot-screen=")
	if _screenshot_screen.is_empty():
		_screenshot_screen = "home"
	_screenshot_exit = args.has(
		"--story-demo-screenshot-exit" if _public_demo else "--order124-screenshot-exit")
	var returning_from_story := GameState.returning_from_story
	_story_return_pending = returning_from_story and _saved_phase() == "story"
	if returning_from_story:
		GameState.returning_from_story = false
		if _story_return_pending and _load_session(false):
			_session.erase("story_resume_slot")
			# The in-memory GameState owns the just-completed StoryMode choices.
			_collect_current_month_choices()
			var close_result := _close_month(int(_session.get("current_month", 1)))
			if not bool(close_result.get("closed", false)):
				_recover_failed_story_return(close_result)
		else:
			_show_home(_t(
				"돌아온 장면의 데모 기록을 열 수 없습니다.",
				"The returning scene's demo save could not be opened."))
		# StoryMode returns behind SceneTransition's fully opaque cover. This
		# candidate owns the destination scene, so it must also uncover it.
		SceneTransition.fade_in()
	elif _language_gate_required:
		_show_language_gate()
	else:
		_show_home()
	if args.has("--story-demo-return-smoke" if _public_demo else "--order124-return-smoke"):
		call_deferred("_run_return_smoke")
	elif _public_demo and args.has(PUBLIC_REAL_FLOW_ARG):
		call_deferred("_run_real_flow_smoke")
	elif args.has("--story-demo-resume-smoke" if _public_demo else "--order124-resume-smoke"):
		call_deferred("_run_resume_smoke")
	elif args.has("--story-demo-smoke" if _public_demo else "--order124-smoke"):
		call_deferred("_run_smoke")
	elif not _screenshot_path.is_empty():
		call_deferred("_capture_requested_screen")


func qa_start_new_run() -> bool:
	return _start_new_run()


func qa_continue_run() -> bool:
	return _continue_run()


func qa_screen() -> String:
	return _screen


func qa_current_month() -> int:
	return int(_session.get("current_month", 0))


func qa_autosave_path() -> String:
	return _active_save_path()


func qa_session_snapshot() -> Dictionary:
	var snapshot := _session.duplicate(true)
	snapshot["screen"] = _screen
	snapshot["game_state"] = GameState.serialize().duplicate(true)
	return snapshot


func qa_schedule() -> Dictionary:
	var months := {}
	for month in range(1, 7):
		months[str(month)] = _event_ids_for_month(month)
	return {
		"story_scene": STORY_SCENE,
		"current_month": qa_current_month(),
		"current_event_ids": _remaining_event_ids(qa_current_month()),
		"months": months,
		"m02_route": _m02_route(),
		"start_contract": qa_start_contract(),
	}


func qa_inject_m6() -> Dictionary:
	return _install_m6_event().duplicate(true)


func qa_m6_event() -> Dictionary:
	return qa_inject_m6()


func qa_choose_current(choice_index: int) -> Dictionary:
	var remaining := _remaining_event_ids(qa_current_month())
	if remaining.is_empty():
		return _choice_failure("", choice_index, "month_complete")
	return qa_choose_event(str(remaining.front()), choice_index)


func qa_choose_event(event_id: String, choice_index: int) -> Dictionary:
	var month := qa_current_month()
	if month < 1 or month > 6:
		return _choice_failure(event_id, choice_index, "no_active_month")
	_install_runtime_events()
	if event_id in _completed_event_ids():
		return _choice_failure(event_id, choice_index, "already_applied")
	var remaining := _remaining_event_ids(month)
	if event_id not in remaining:
		return _choice_failure(event_id, choice_index, "not_scheduled")
	var event: Dictionary = DataRegistry.find_event(event_id)
	var choices: Array = event.get("choices", [])
	if choice_index < 0 or choice_index >= choices.size():
		return _choice_failure(event_id, choice_index, "choice_out_of_range")
	var choice: Dictionary = choices[choice_index]
	var before: Dictionary = GameState.serialize().duplicate(true)
	var session_before := _session.duplicate(true)
	if not GameState.choice_available(event, choice):
		return _choice_failure(event_id, choice_index, "choice_unavailable")
	if not GameState.apply_choice(event, choice):
		return _choice_failure(event_id, choice_index, "apply_failed")
	var record := _choice_record(event, choice, choice_index)
	var records: Array = _session.get("choices", [])
	records.append(record)
	_session["choices"] = records
	var completed := _completed_event_ids()
	completed.append(event_id)
	_session["completed_event_ids"] = completed
	_session["phase"] = "transition"
	_session["game_state"] = GameState.serialize().duplicate(true)
	if not _save_session():
		GameState.load_from_dict(before)
		_session = session_before
		return _choice_failure(event_id, choice_index, "save_failed")
	return {
		"accepted": true,
		"applied": true,
		"event_id": event_id,
		"choice_index": choice_index,
		"current_month": month,
		"next_event_id": str(_remaining_event_ids(month).front()) \
			if not _remaining_event_ids(month).is_empty() else "",
		"before": before,
		"game_state": GameState.serialize().duplicate(true),
	}


func qa_simulate_month_close_and_save(expected_month: int = -1) -> Dictionary:
	var month := qa_current_month() if expected_month < 0 else expected_month
	return _close_month(month)


func qa_close_month(month: int) -> Dictionary:
	return _close_month(month)


func qa_repeat_last_close() -> Dictionary:
	return _close_month(int(_session.get("last_closed_month", 0)))


func qa_monthly_action_receipt_count() -> int:
	var receipt_count := 0
	var ledger := qa_action_ledger_snapshot()
	for key in ACTION_LEDGER_KEYS:
		var value: Variant = ledger.get(key)
		if value is Array:
			receipt_count += (value as Array).size()
		elif value is Dictionary:
			for nested in (value as Dictionary).values():
				if nested is int or nested is float:
					receipt_count += absi(int(nested))
				else:
					receipt_count += 1
		elif value is int or value is float:
			receipt_count += absi(int(value))
	return receipt_count


func qa_action_ledger_snapshot() -> Dictionary:
	return _action_ledger_snapshot()


func qa_session_writer_fault(fault: String) -> Dictionary:
	if not _public_demo or not _public_runtime_qa_allowed() \
			or fault not in ["corrupt_temporary", "corrupt_primary"]:
		return {"allowed": false}
	var path := _active_save_path()
	var before := FileAccess.get_file_as_bytes(path)
	var candidate := _session.duplicate(true)
	candidate["qa_writer_probe"] = fault
	var accepted := _write_verified_session(
		path, candidate, _active_profile(), fault)
	var after := FileAccess.get_file_as_bytes(path)
	return {
		"allowed": true,
		"accepted": accepted,
		"primary_preserved": not before.is_empty() and after == before,
		"readable": not _read_session().is_empty(),
		"temporary_absent": not FileAccess.file_exists("%s.tmp" % path),
		"recovery_absent": not FileAccess.file_exists("%s.recovery.tmp" % path),
	}


func qa_set_language(language: String) -> bool:
	var normalized := LocaleManager.normalize_language(language)
	if normalized not in _available_languages():
		return false
	var changed := LocaleManager.language != normalized
	# set_language also persists the selection. This must run even when the
	# engine default already equals the player's first choice (English).
	LocaleManager.set_language(normalized)
	if not changed:
		LocaleManager.sync_player_name_for_current_language()
		DataRegistry.reload()
	_install_runtime_events()
	_refresh_screen()
	return true


func qa_visible_text() -> String:
	var lines := PackedStringArray()
	_collect_visible_text(self, lines)
	return "\n".join(lines)


func qa_start_contract() -> Dictionary:
	return {
		"difficulty": START_DIFFICULTY,
		"profile": START_PROFILE,
		"run_theme": "자유런",
		"run_theme_categories": [],
		"health_floor": START_HEALTH_FLOOR,
		"mental_floor": START_MENTAL_FLOOR,
		"monthly_recovery_health": MONTHLY_RECOVERY_HEALTH,
		"monthly_recovery_mental": MONTHLY_RECOVERY_MENTAL,
		"creates_monthly_action_receipts": false,
	}


func qa_user_data_contract() -> Dictionary:
	return {
		"enabled": bool(ProjectSettings.get_setting(
			"application/config/use_custom_user_dir", false)),
		"configured_name": str(ProjectSettings.get_setting(
			"application/config/custom_user_dir_name", "")),
		"resolved_path": OS.get_user_data_dir(),
		"isolated": _isolated_user_data_configured(),
	}


func qa_transition_overlay_state() -> Dictionary:
	var overlay: Variant = SceneTransition.get("_overlay")
	return {
		"alpha": float(SceneTransition.get("_transition_alpha")),
		"blocks_input": overlay is Control \
			and (overlay as Control).mouse_filter == Control.MOUSE_FILTER_STOP,
	}


func qa_prepare_story_return(choice_index: int) -> bool:
	# Reproduce StoryMode's ownership boundary for focused checks: the checkpoint
	# stays in phase=story while the applied choice lives in GameState memory.
	if _session.is_empty() or str(_session.get("phase", "")) != "transition":
		return false
	var story_checkpoint := _session.duplicate(true)
	story_checkpoint["phase"] = "story"
	var result := qa_choose_current(choice_index)
	if not bool(result.get("applied", false)):
		return false
	_session = story_checkpoint
	if not _save_session():
		return false
	GameState.returning_from_story = true
	return true


func qa_set_auto_launch(enabled: bool) -> bool:
	_auto_launch_enabled = enabled
	if not enabled:
		_cancel_transition_auto_launch()
	return true


func _start_new_run() -> bool:
	GameState.start_new_game(
		"김민준", "지방_상경", "직장형", START_PROFILE, "자유런", START_DIFFICULTY)
	# This candidate schedules every story scene explicitly. Remove the random
	# free-run category hint so the product's legacy-save inference cannot
	# reinterpret a legitimate "자유런" save as a themed run on reload.
	GameState.run_theme = "자유런"
	GameState.run_theme_categories = []
	GameState.health = maxi(GameState.health, START_HEALTH_FLOOR)
	GameState.mental = maxi(GameState.mental, START_MENTAL_FLOOR)
	GameState.flags["order124_story_playtest_contract"] = true
	GameState.returning_from_story = false
	GameState.pending_story_queue.clear()
	GameState.story_return_scene = ""
	_session = {
		"schema_version": SAVE_SCHEMA,
		"profile": _active_profile(),
		"current_month": 1,
		"phase": "transition",
		"elapsed_weeks": 0,
		"monthly_pressure_count": 0,
		"choices": [],
		"settlements": [],
		"completed_event_ids": [],
		"closed_months": [],
		"last_closed_month": 0,
		"start_contract": qa_start_contract(),
		"game_state": GameState.serialize().duplicate(true),
	}
	_restart_armed = false
	if not _save_session():
		return false
	_show_transition()
	return true


func _continue_run() -> bool:
	if not _load_session(true):
		_show_home(_t("저장된 데모 기록을 열 수 없습니다.", "The saved demo session could not be opened."))
		return false
	if str(_session.get("phase", "")) == "story" \
			and _session.has("story_resume_slot"):
		if _resume_story_from_manual_slot():
			return true
		_show_transition(_t(
			"끝나지 않은 장면부터 다시 이어갑니다.",
			"Continuing from the unfinished scene."))
		return true
	match str(_session.get("phase", "transition")):
		"recap": _show_recap()
		_: _show_transition()
	return true


func _resume_story_from_manual_slot() -> bool:
	if not _public_demo:
		return false
	var slot_value: Variant = _session.get("story_resume_slot", null)
	if not _story_resume_slot_value_is_valid(slot_value):
		_session.erase("story_resume_slot")
		_save_session()
		return false
	var slot := int(slot_value)
	var controller_state: Dictionary = GameState.serialize().duplicate(true)
	var controller_session: Dictionary = _session.duplicate(true)
	if not SaveManager.load_game(slot):
		GameState.load_from_dict(controller_state)
		_session = controller_session
		_session.erase("story_resume_slot")
		_save_session()
		return false
	var context := SaveManager.peek_loaded_resume_context()
	if str(context.get("kind", "")) != "story" \
			or str(context.get("scene", "")) != STORY_SCENE \
			or str(context.get("return_scene", "")) != SELF_SCENE:
		SaveManager.clear_loaded_resume_context()
		GameState.load_from_dict(controller_state)
		_session = controller_session
		_session.erase("story_resume_slot")
		_save_session()
		return false
	_install_runtime_events()
	var reconciled := reconcile_story_demo_session_with_live_receipts(
		context.get("story_demo_controller_session", {}), context)
	if reconciled.is_empty():
		SaveManager.clear_loaded_resume_context()
		GameState.load_from_dict(controller_state)
		_session = controller_session
		_session.erase("story_resume_slot")
		_save_session()
		return false
	reconciled["story_resume_slot"] = slot
	_session = reconciled
	if not _save_session():
		SaveManager.clear_loaded_resume_context()
		GameState.load_from_dict(controller_state)
		_session = controller_session
		return false
	GameState.story_return_scene = SELF_SCENE
	GameState.story_replay_mode = false
	SceneTransition.go(STORY_SCENE)
	return true


func _recover_failed_story_return(result: Dictionary) -> void:
	var reason := str(result.get("reason", "unknown"))
	match reason:
		"awaiting_choices":
			# A partial/older checkpoint can safely re-enter only the still-missing
			# authored scene. Persist collected receipts before showing it.
			_session["phase"] = "transition"
			if _save_session():
				_show_transition(_t(
					"끝나지 않은 장면부터 다시 이어갑니다.",
					"Continuing from the unfinished scene."))
			else:
				_show_home(_t(
					"장면 복귀 기록을 저장하지 못했습니다.",
					"The returning scene record could not be saved."))
		"already_closed":
			if qa_current_month() > 6 or str(_session.get("phase", "")) == "recap":
				_show_recap()
			else:
				_show_transition()
		_:
			_show_home(_t(
				"장면 뒤 달을 넘기지 못했습니다. 저장 기록은 유지되었습니다.",
				"The month could not advance after the scene. The saved record was kept."))


func _launch_story() -> void:
	_cancel_transition_auto_launch()
	var month := qa_current_month()
	if month < 1 or month > 6:
		_show_recap()
		return
	_install_runtime_events()
	var queue := _remaining_event_ids(month)
	if queue.is_empty():
		_close_month(month)
		return
	_session.erase("story_resume_slot")
	_session["phase"] = "story"
	_session["game_state"] = GameState.serialize().duplicate(true)
	if not _save_session():
		_show_home(_t("저장하지 못해 장면을 시작하지 않았습니다.", "The scene was not started because the checkpoint could not be saved."))
		return
	GameState.pending_story_queue = queue.duplicate()
	GameState.story_return_scene = SELF_SCENE
	GameState.story_replay_mode = false
	SceneTransition.go(STORY_SCENE)


func _close_month(month: int) -> Dictionary:
	var result := {
		"closed": false,
		"month_closed": month,
		"current_month": qa_current_month(),
		"weeks_elapsed": int(_session.get("elapsed_weeks", 0)),
		"settlement_count": int(_session.get("monthly_pressure_count", 0)),
	}
	if month < 1 or month > 6:
		result["reason"] = "invalid_month"
		return result
	var closed := _closed_months()
	if str(month) in closed:
		result["reason"] = "already_closed"
		return result
	if month != qa_current_month():
		result["reason"] = "not_current_month"
		return result
	var remaining := _remaining_event_ids(month)
	if not remaining.is_empty():
		result["reason"] = "awaiting_choices"
		result["remaining_event_ids"] = remaining
		return result
	var close_snapshot: Dictionary = GameState.serialize().duplicate(true)
	var session_snapshot := _session.duplicate(true)
	var before := _state_summary()
	# This isolated six-scene sample assumes a continuing part-time baseline and
	# a minimum of sleep/meals between scenes. It is automatic candidate context,
	# never a player choice or ledger receipt, and keeps every authored route live.
	GameState.modify_stat("health", MONTHLY_RECOVERY_HEALTH)
	GameState.modify_stat("mental", MONTHLY_RECOVERY_MENTAL)
	for _week in range(4):
		var turn_before_advance: int = int(GameState.turn)
		var action_ledger_before := _action_ledger_snapshot()
		GameState.advance_calendar()
		_restore_action_ledger(action_ledger_before)
		if GameState.turn != turn_before_advance + 1:
			GameState.load_from_dict(close_snapshot)
			result["reason"] = "calendar_stopped"
			result["game_state"] = GameState.serialize().duplicate(true)
			return result
	GameState.apply_monthly_pressure()
	if GameState.is_game_over:
		GameState.load_from_dict(close_snapshot)
		result["reason"] = "candidate_game_over"
		result["game_state"] = GameState.serialize().duplicate(true)
		return result
	var after := _state_summary()
	var settlement := {
		"month": month,
		"cash_before": before["money"],
		"cash_after": after["money"],
		"health_before": before["health"],
		"health_after": after["health"],
		"mental_before": before["mental"],
		"mental_after": after["mental"],
		"turn_before": before["turn"],
		"turn_after": after["turn"],
		"automatic_recovery_health": MONTHLY_RECOVERY_HEALTH,
		"automatic_recovery_mental": MONTHLY_RECOVERY_MENTAL,
	}
	var settlements: Array = _session.get("settlements", [])
	settlements.append(settlement)
	_session["settlements"] = settlements
	closed.append(str(month))
	_session["closed_months"] = closed
	_session["last_closed_month"] = month
	_session["elapsed_weeks"] = int(_session.get("elapsed_weeks", 0)) + 4
	_session["monthly_pressure_count"] = int(_session.get("monthly_pressure_count", 0)) + 1
	_session["current_month"] = month + 1
	_session["completed_event_ids"] = []
	_session.erase("story_resume_slot")
	_session["phase"] = "recap" if month == 6 else "transition"
	_session["game_state"] = GameState.serialize().duplicate(true)
	if not _save_session():
		GameState.load_from_dict(close_snapshot)
		_session = session_snapshot
		result["reason"] = "save_failed"
		result["game_state"] = GameState.serialize().duplicate(true)
		_show_home(_t(
			"정산을 저장하지 못해 이번 달을 넘기지 않았습니다.",
			"The month did not advance because its settlement could not be saved."))
		return result
	if month == 6:
		_show_recap()
	else:
		_show_transition()
	result = {
		"closed": true,
		"month_closed": month,
		"current_month": qa_current_month(),
		"weeks_elapsed": int(_session.get("elapsed_weeks", 0)),
		"settlement_count": int(_session.get("monthly_pressure_count", 0)),
		"settlement": settlement,
		"game_state": GameState.serialize().duplicate(true),
	}
	return result


func _action_ledger_snapshot() -> Dictionary:
	var snapshot := {}
	for key in ACTION_LEDGER_KEYS:
		var value: Variant = GameState.get(key)
		if value is Dictionary:
			snapshot[key] = (value as Dictionary).duplicate(true)
		elif value is Array:
			snapshot[key] = (value as Array).duplicate(true)
		else:
			snapshot[key] = value
	return snapshot


func _restore_action_ledger(snapshot: Dictionary) -> void:
	for key in ACTION_LEDGER_KEYS:
		if not snapshot.has(key):
			continue
		var value: Variant = snapshot[key]
		if value is Dictionary:
			GameState.set(key, (value as Dictionary).duplicate(true))
		elif value is Array:
			GameState.set(key, (value as Array).duplicate(true))
		else:
			GameState.set(key, value)


func _collect_current_month_choices() -> void:
	var month := qa_current_month()
	var completed := _completed_event_ids()
	var records: Array = _session.get("choices", [])
	for event_id_variant in _receipt_event_ids_for_month(month):
		var event_id := str(event_id_variant)
		if event_id in completed:
			continue
		var event: Dictionary = DataRegistry.find_event(event_id)
		var choices: Array = event.get("choices", [])
		for choice_index in range(choices.size()):
			var receipt := _choice_receipt_flag(event_id, choice_index)
			if bool(GameState.flags.get(receipt, false)):
				records.append(_choice_record(event, choices[choice_index], choice_index))
				completed.append(event_id)
				break
	_session["choices"] = records
	_session["completed_event_ids"] = completed


func _event_ids_for_month(month: int) -> Array:
	if month == 2:
		return ["arc_temptation_fallout"] if _m02_route() == "fallout" else ["arc_temptation_clean"]
	return (MONTH_EVENTS.get(month, []) as Array).duplicate()


func _m02_route() -> String:
	return "fallout" if bool(GameState.flags.get("lent_account", false)) else "clean"


func _m4_branch_event_id() -> String:
	if bool(GameState.flags.get(
			_choice_receipt_flag(M4_ROOT_EVENT_ID, 0), false)):
		return M4_MEASURE_EVENT_ID
	if bool(GameState.flags.get(
			_choice_receipt_flag(M4_ROOT_EVENT_ID, 1), false)):
		return M4_COFFEE_EVENT_ID
	return ""


func _injectable_event_ids_for_month(month: int) -> Array:
	var event_ids := _event_ids_for_month(month)
	if month == 4:
		event_ids.append(M4_MEASURE_EVENT_ID)
		event_ids.append(M4_COFFEE_EVENT_ID)
		event_ids.append(M4_ANSWER_EVENT_ID)
	return event_ids


func _receipt_event_ids_for_month(month: int) -> Array:
	if month != 4:
		return _event_ids_for_month(month)
	var event_ids: Array = [M4_ROOT_EVENT_ID]
	var branch_id := _m4_branch_event_id()
	if not branch_id.is_empty():
		event_ids.append(branch_id)
	event_ids.append(M4_ANSWER_EVENT_ID)
	return event_ids


func _remaining_event_ids(month: int) -> Array:
	var completed := _completed_event_ids()
	var remaining: Array = []
	if month == 4:
		if M4_ROOT_EVENT_ID not in completed:
			return [M4_ROOT_EVENT_ID]
		var branch_id := _m4_branch_event_id()
		if not branch_id.is_empty() and branch_id not in completed:
			return [branch_id]
		if M4_ANSWER_EVENT_ID not in completed:
			return [M4_ANSWER_EVENT_ID]
		return []
	for event_id in _event_ids_for_month(month):
		if str(event_id) not in completed:
			remaining.append(str(event_id))
	return remaining


func _completed_event_ids() -> Array:
	var value: Variant = _session.get("completed_event_ids", [])
	return (value as Array).duplicate() if value is Array else []


func _closed_months() -> Array:
	var value: Variant = _session.get("closed_months", [])
	return (value as Array).duplicate() if value is Array else []


func _install_runtime_events() -> void:
	install_story_demo_runtime_events()


## LocaleManager reloads DataRegistry whenever a player changes language.
## Rebuild the exact receipt-bearing demo overlays after that reload so a
## mid-scene language change cannot erase completion facts or the synthetic M6.
static func install_story_demo_runtime_events() -> void:
	for event_id in RUNTIME_RECEIPT_EVENT_IDS:
		_install_runtime_choice_receipts(event_id)
	_install_story_demo_m6_event()


func _inject_choice_receipts(event_id: String) -> Dictionary:
	return _install_runtime_choice_receipts(event_id)


static func _install_runtime_choice_receipts(event_id: String) -> Dictionary:
	var source: Dictionary = DataRegistry.find_event(event_id)
	if source.is_empty():
		return {}
	var event := source.duplicate(true)
	var choices: Array = event.get("choices", [])
	for choice_index in range(choices.size()):
		var choice: Dictionary = choices[choice_index]
		var flags: Array = choice.get("flags", []).duplicate()
		var receipt := _runtime_choice_receipt_flag(event_id, choice_index)
		if receipt not in flags:
			flags.append(receipt)
		choice["flags"] = flags
		choices[choice_index] = choice
	event["choices"] = choices
	DataRegistry.events_by_id[event_id] = event
	return event


func _install_m6_event() -> Dictionary:
	return _install_story_demo_m6_event()


static func _install_story_demo_m6_event() -> Dictionary:
	var source: Dictionary = DataRegistry.find_event(M6_SOURCE_EVENT_ID)
	if source.is_empty():
		return {}
	var event := source.duplicate(true)
	event["id"] = M6_EVENT_ID
	event["weight"] = 0
	event["hidden"] = true
	event["conditions"] = {"min_turn": 9999}
	event["description"] = LocaleManager.ui(
		"6월 마지막 금요일 저녁. 민준은 고시원 책상 위에 통장 잔액, 오늘 끝낼 수 있는 일, 쉬지 못한 몸의 신호를 한 장에 적었다. 편의점의 다은, 포장마차의 재혁, 부동산 사무실의 상철에게 먼저 건넬 말도 그 옆에 놓였다. 지금 한 가지를 끝내는 동안 나머지는 오늘 밤을 지나간다. 민준은 실제로 움직일 한 줄에만 동그라미를 친다.",
		"On the final Friday evening of June, Minjun writes his balance, one piece of work he can finish tonight, and the warning from his unrested body on a single page. Beside them are the words he could initiate with Daeun from the convenience store, Jaehyuk from the pojangmacha, and Sangchul from the real-estate office. While he completes one thing, the others will pass beyond tonight. Minjun circles the one line he will actually act on.")
	var source_choices: Array = source.get("choices", [])
	var choices: Array = []
	for source_index in M6_SOURCE_CHOICES:
		if source_index < 0 or source_index >= source_choices.size():
			continue
		var choice: Dictionary = (source_choices[source_index] as Dictionary).duplicate(true)
		for key_variant in choice.keys().duplicate():
			var key := str(key_variant)
			if key.begins_with("v2_") or key in ["follow_up_event", "deferred_follow_up", "deferred_delay"]:
				choice.erase(key_variant)
		var flags: Array = choice.get("flags", []).duplicate()
		flags.append(_runtime_choice_receipt_flag(M6_EVENT_ID, choices.size()))
		choice["flags"] = flags
		choices.append(choice)
	event["choices"] = choices
	DataRegistry.events_by_id[M6_EVENT_ID] = event
	DataRegistry.notify_content_override()
	return event


static func _runtime_choice_receipt_flag(
		event_id: String, choice_index: int) -> String:
	return "order124_choice__%s__%d" % [event_id, choice_index]


## Manual StoryMode saves carry both the exact prose position and a controller
## checkpoint. Reconcile that checkpoint from the live, choice-owned flags so a
## load followed by an immediate app restart cannot apply the same choice twice.
static func reconcile_story_demo_session_with_live_receipts(
		raw_session: Variant, resume_context: Dictionary = {}) -> Dictionary:
	if not raw_session is Dictionary:
		return {}
	var session: Dictionary = (raw_session as Dictionary).duplicate(true)
	if int(session.get("schema_version", 0)) != SAVE_SCHEMA \
			or str(session.get("profile", "")) != PUBLIC_PROFILE \
			or str(session.get("phase", "")) != "story":
		return {}
	var month := int(session.get("current_month", 0))
	var elapsed_weeks := int(session.get("elapsed_weeks", -1))
	var settlement_count := int(session.get("monthly_pressure_count", -1))
	if month < 1 or month > 6 \
			or elapsed_weeks != (month - 1) * 4 \
			or settlement_count != month - 1 \
			or int(GameState.turn) != elapsed_weeks + 1:
		return {}
	for key in ["choices", "settlements", "completed_event_ids", "closed_months"]:
		if not session.get(key, null) is Array:
			return {}

	var contract := _live_story_receipt_contract(month)
	if not bool(contract.get("valid", false)):
		return {}
	var scheduled: Array[String] = contract.get("scheduled", [])
	var alternatives: Array[String] = contract.get("alternatives", [])
	var receipt_indices: Dictionary = contract.get("receipt_indices", {})
	var completed: Array = (session.get("completed_event_ids", []) as Array).duplicate()
	var completed_seen: Array[String] = []
	for raw_event_id in completed:
		if not raw_event_id is String:
			return {}
		var completed_id := str(raw_event_id)
		if completed_id not in scheduled or completed_id in completed_seen:
			return {}
		completed_seen.append(completed_id)
	var records: Array = (session.get("choices", []) as Array).duplicate(true)
	var current_records := {}
	for record_variant in records:
		if not record_variant is Dictionary:
			return {}
		var record: Dictionary = record_variant
		if int(record.get("month", 0)) != month:
			continue
		var record_event_id := str(record.get("event_id", ""))
		if record_event_id not in scheduled or current_records.has(record_event_id):
			return {}
		current_records[record_event_id] = int(record.get("choice_index", -1))

	var prefix_count := 0
	var found_gap := false
	for event_id in scheduled:
		var raw_indices: Variant = receipt_indices.get(event_id, [])
		if not raw_indices is Array:
			return {}
		var indices: Array = raw_indices
		if indices.size() > 1:
			return {}
		var has_receipt := indices.size() == 1
		if has_receipt and found_gap:
			return {}
		if not has_receipt:
			found_gap = true
		var was_completed := event_id in completed_seen
		var has_record := current_records.has(event_id)
		if not has_receipt:
			if was_completed or has_record:
				return {}
			continue
		var choice_index := int(indices[0])
		if was_completed != has_record:
			return {}
		if was_completed:
			if int(current_records[event_id]) != choice_index:
				return {}
		else:
			completed.append(event_id)
			completed_seen.append(event_id)
			records.append({
				"month": month,
				"event_id": event_id,
				"choice_index": choice_index,
			})
			current_records[event_id] = choice_index
		prefix_count += 1

	# A receipt on an unselected M02/M04 alternative is always corruption.
	for alternative_id in alternatives:
		if alternative_id in scheduled:
			continue
		var alternative_indices: Variant = receipt_indices.get(alternative_id, [])
		if alternative_indices is Array \
				and not (alternative_indices as Array).is_empty():
			return {}

	if not resume_context.is_empty():
		var resume_event_id := str(resume_context.get("event_id", ""))
		var resume_phase := str(resume_context.get("phase", ""))
		var resume_index := scheduled.find(resume_event_id)
		if resume_index < 0:
			return {}
		if resume_phase == "result":
			if resume_index != prefix_count - 1 \
					or int(resume_context.get(
						"pending_result_choice_index", -1)) \
						!= int(current_records.get(resume_event_id, -2)):
				return {}
		elif resume_phase in ["chapter", "prose", "choices"]:
			if resume_index != prefix_count:
				return {}
		else:
			return {}
		var raw_queue: Variant = resume_context.get("queue", null)
		if not raw_queue is Array:
			return {}
		var queue: Array[String] = []
		for queued_event_id in raw_queue as Array:
			if not queued_event_id is String:
				return {}
			queue.append(str(queued_event_id))
		var expected_queue: Array[String] = []
		if month == 3 and resume_event_id == "arc_daeun_01_meet":
			expected_queue = ["arc_jiyeon_01_crash"]
		if queue != expected_queue:
			return {}
		var expected_follow_up := ""
		if resume_phase == "result":
			if resume_event_id == M4_ROOT_EVENT_ID and scheduled.size() >= 2:
				expected_follow_up = scheduled[1]
			elif resume_event_id in [M4_MEASURE_EVENT_ID, M4_COFFEE_EVENT_ID]:
				expected_follow_up = M4_ANSWER_EVENT_ID
		if str(resume_context.get("pending_follow_up", "")) \
				!= expected_follow_up:
			return {}

	session["choices"] = records
	session["completed_event_ids"] = completed
	session["game_state"] = GameState.serialize().duplicate(true)
	return session


static func _live_story_receipt_contract(month: int) -> Dictionary:
	var scheduled: Array[String] = []
	var alternatives: Array[String] = []
	match month:
		1:
			scheduled = ["arc_temptation_01"]
		2:
			scheduled = [
				"arc_temptation_fallout" if bool(
					GameState.flags.get("lent_account", false)) \
				else "arc_temptation_clean"]
			alternatives = ["arc_temptation_clean", "arc_temptation_fallout"]
		3:
			scheduled = ["arc_daeun_01_meet", "arc_jiyeon_01_crash"]
		4:
			alternatives = [
				M4_ROOT_EVENT_ID, M4_MEASURE_EVENT_ID,
				M4_COFFEE_EVENT_ID, M4_ANSWER_EVENT_ID,
			]
			var root_indices := _live_choice_receipt_indices(M4_ROOT_EVENT_ID)
			if root_indices.size() > 1:
				return {"valid": false}
			scheduled = [M4_ROOT_EVENT_ID]
			if root_indices.size() == 1:
				var branch_id := M4_MEASURE_EVENT_ID \
					if int(root_indices[0]) == 0 else M4_COFFEE_EVENT_ID
				scheduled.append(branch_id)
				scheduled.append(M4_ANSWER_EVENT_ID)
		5:
			scheduled = ["arc_jaehyuk_01_reunion"]
		6:
			scheduled = [M6_EVENT_ID]
		_:
			return {"valid": false}
	if alternatives.is_empty():
		alternatives = scheduled.duplicate()
	var receipt_indices := {}
	for event_id in alternatives:
		var indices := _live_choice_receipt_indices(event_id)
		if indices.size() > 1:
			return {"valid": false}
		receipt_indices[event_id] = indices
	return {
		"valid": true,
		"scheduled": scheduled,
		"alternatives": alternatives,
		"receipt_indices": receipt_indices,
	}


static func _live_choice_receipt_indices(event_id: String) -> Array[int]:
	var event: Dictionary = DataRegistry.find_event(event_id)
	var choices: Variant = event.get("choices", null)
	if event.is_empty() or not choices is Array:
		return [-1, -1]
	var indices: Array[int] = []
	for choice_index in range((choices as Array).size()):
		if bool(GameState.flags.get(
				_runtime_choice_receipt_flag(event_id, choice_index), false)):
			indices.append(choice_index)
	return indices


func _choice_receipt_flag(event_id: String, choice_index: int) -> String:
	return "order124_choice__%s__%d" % [event_id, choice_index]


func _choice_record(event: Dictionary, _choice: Dictionary, choice_index: int) -> Dictionary:
	return {
		"month": qa_current_month(),
		"event_id": str(event.get("id", "")),
		"choice_index": choice_index,
	}


func _choice_failure(event_id: String, choice_index: int, reason: String) -> Dictionary:
	return {
		"accepted": false,
		"applied": false,
		"event_id": event_id,
		"choice_index": choice_index,
		"reason": reason,
		"current_month": qa_current_month(),
		"game_state": GameState.serialize().duplicate(true),
	}


func _save_session() -> bool:
	if _session.is_empty():
		return false
	_session["game_state"] = GameState.serialize().duplicate(true)
	return _write_verified_session(
		_active_save_path(), _session, _active_profile())


static func write_verified_story_demo_session(session: Dictionary) -> bool:
	return _write_verified_session(PUBLIC_SAVE_PATH, session, PUBLIC_PROFILE)


static func _write_verified_session(
		user_path: String, session: Dictionary, expected_profile: String,
		qa_fault: String = "") -> bool:
	var path := ProjectSettings.globalize_path(user_path)
	var temp_path := "%s.tmp" % path
	var backup_path := "%s.bak" % path
	var serialized_bytes := JSON.stringify(session, "  ").to_utf8_buffer()
	if not _session_bytes_are_valid(serialized_bytes, expected_profile):
		return false
	if _write_exact_bytes(temp_path, serialized_bytes) != OK:
		_remove_file_if_present(temp_path)
		return false
	if qa_fault == "corrupt_temporary":
		var corrupt_temp := FileAccess.open(temp_path, FileAccess.WRITE)
		if corrupt_temp != null:
			corrupt_temp.store_string("{")
			corrupt_temp.close()
	if FileAccess.get_file_as_bytes(temp_path) != serialized_bytes \
			or not _session_bytes_are_valid(
				FileAccess.get_file_as_bytes(temp_path), expected_profile):
		_remove_file_if_present(temp_path)
		return false

	var primary_bytes := FileAccess.get_file_as_bytes(path) \
		if FileAccess.file_exists(path) else PackedByteArray()
	var backup_bytes := FileAccess.get_file_as_bytes(backup_path) \
		if FileAccess.file_exists(backup_path) else PackedByteArray()
	var primary_valid := _session_bytes_are_valid(
		primary_bytes, expected_profile)
	var backup_valid := _session_bytes_are_valid(
		backup_bytes, expected_profile)
	if primary_valid:
		if not _prepare_verified_session_backup(
				backup_path, primary_bytes, expected_profile):
			_remove_file_if_present(temp_path)
			return false
		backup_bytes = primary_bytes
		backup_valid = true

	var replace_error := DirAccess.rename_absolute(temp_path, path)
	if replace_error != OK:
		_remove_file_if_present(temp_path)
		if backup_valid:
			_restore_primary_session(path, backup_bytes, expected_profile)
		return false
	if qa_fault == "corrupt_primary":
		var corrupt_primary := FileAccess.open(path, FileAccess.WRITE)
		if corrupt_primary != null:
			corrupt_primary.store_string("{")
			corrupt_primary.close()
	var final_bytes := FileAccess.get_file_as_bytes(path)
	if final_bytes != serialized_bytes \
			or not _session_bytes_are_valid(final_bytes, expected_profile):
		if backup_valid:
			_restore_primary_session(path, backup_bytes, expected_profile)
		return false
	return true


static func _write_exact_bytes(path: String, bytes: PackedByteArray) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var wrote_all := file.store_buffer(bytes)
	file.flush()
	var write_error := file.get_error()
	file.close()
	if not wrote_all and write_error == OK:
		write_error = ERR_FILE_CANT_WRITE
	if write_error != OK:
		return write_error
	return OK if FileAccess.get_file_as_bytes(path) == bytes \
		else ERR_FILE_CORRUPT


static func _prepare_verified_session_backup(
		backup_path: String, bytes: PackedByteArray,
		expected_profile: String) -> bool:
	if FileAccess.file_exists(backup_path):
		var existing := FileAccess.get_file_as_bytes(backup_path)
		if existing == bytes \
				and _session_bytes_are_valid(existing, expected_profile):
			return true
	var backup_temp_path := "%s.tmp" % backup_path
	if _write_exact_bytes(backup_temp_path, bytes) != OK \
			or not _session_bytes_are_valid(
				FileAccess.get_file_as_bytes(backup_temp_path), expected_profile):
		_remove_file_if_present(backup_temp_path)
		return false
	if DirAccess.rename_absolute(backup_temp_path, backup_path) != OK:
		_remove_file_if_present(backup_temp_path)
		return false
	var installed := FileAccess.get_file_as_bytes(backup_path)
	return installed == bytes \
		and _session_bytes_are_valid(installed, expected_profile)


static func _restore_primary_session(
		path: String, backup_bytes: PackedByteArray,
		expected_profile: String) -> bool:
	if not _session_bytes_are_valid(backup_bytes, expected_profile):
		return false
	var recovery_path := "%s.recovery.tmp" % path
	if _write_exact_bytes(recovery_path, backup_bytes) != OK:
		_remove_file_if_present(recovery_path)
		return false
	if DirAccess.rename_absolute(recovery_path, path) != OK:
		_remove_file_if_present(recovery_path)
		return false
	var restored := FileAccess.get_file_as_bytes(path)
	return restored == backup_bytes \
		and _session_bytes_are_valid(restored, expected_profile)


static func _session_bytes_are_valid(
		bytes: PackedByteArray, expected_profile: String) -> bool:
	if bytes.is_empty():
		return false
	var parser := JSON.new()
	if parser.parse(bytes.get_string_from_utf8()) != OK \
			or not parser.data is Dictionary:
		return false
	return _session_dictionary_is_valid(parser.data, expected_profile)


static func _session_dictionary_is_valid(
		data: Dictionary, expected_profile: String) -> bool:
	if int(data.get("schema_version", 0)) != SAVE_SCHEMA \
			or str(data.get("profile", "")) != expected_profile \
			or not data.get("game_state", null) is Dictionary:
		return false
	var phase := str(data.get("phase", ""))
	var month := int(data.get("current_month", 0))
	var elapsed_weeks := int(data.get("elapsed_weeks", -1))
	var settlement_count := int(data.get("monthly_pressure_count", -1))
	if phase not in ["transition", "story", "recap"] \
			or month < 1 or month > 7 \
			or elapsed_weeks != (month - 1) * 4 \
			or settlement_count != month - 1 \
			or (phase == "recap") != (month == 7) \
			or (phase == "story" and month > 6):
		return false
	for key in ["choices", "settlements", "completed_event_ids", "closed_months"]:
		if not data.get(key, null) is Array:
			return false
	var settlements: Array = data.get("settlements", [])
	var closed_months: Array = data.get("closed_months", [])
	if settlements.size() != settlement_count \
			or closed_months.size() != settlement_count:
		return false
	for closed_index in range(closed_months.size()):
		if not closed_months[closed_index] is String \
				or str(closed_months[closed_index]) != str(closed_index + 1):
			return false
	var completed_seen: Array[String] = []
	for event_id in data.get("completed_event_ids", []):
		if not event_id is String or str(event_id).is_empty() \
				or str(event_id) in completed_seen:
			return false
		completed_seen.append(str(event_id))
	for record_variant in data.get("choices", []):
		if not record_variant is Dictionary:
			return false
		var record: Dictionary = record_variant
		if int(record.get("month", 0)) < 1 \
				or int(record.get("month", 0)) > 6 \
				or str(record.get("event_id", "")).is_empty() \
				or int(record.get("choice_index", -1)) < 0:
			return false
	var game_state: Dictionary = data.get("game_state", {})
	if not _game_state_payload_shape_is_valid(game_state) \
			or int(game_state.get("turn", -1)) != elapsed_weeks + 1:
		return false
	var state_flags: Dictionary = game_state.get("flags", {})
	var receipt_records_seen: Array[String] = []
	for record_variant in data.get("choices", []):
		var record: Dictionary = record_variant
		var receipt_event_id := str(record.get("event_id", ""))
		var receipt_choice_index := int(record.get("choice_index", -1))
		if receipt_event_id in receipt_records_seen \
				or not bool(state_flags.get(_runtime_choice_receipt_flag(
					receipt_event_id, receipt_choice_index), false)):
			return false
		receipt_records_seen.append(receipt_event_id)
	if data.has("story_resume_slot"):
		if phase != "story" \
				or not _story_resume_slot_value_is_valid(
					data.get("story_resume_slot")):
			return false
	return true


static func _game_state_payload_shape_is_valid(state: Dictionary) -> bool:
	var baseline: Dictionary = GameState.serialize()
	for key in baseline:
		if not state.has(key) \
				or not _json_value_matches_runtime_shape(state[key], baseline[key]):
			return false
	return true


static func _json_value_matches_runtime_shape(
		value: Variant, baseline: Variant) -> bool:
	if baseline is bool:
		return value is bool
	if baseline is int or baseline is float:
		return (value is int or value is float) and is_finite(float(value))
	if baseline is String or baseline is StringName:
		return value is String or value is StringName
	if baseline is Dictionary:
		return value is Dictionary
	if baseline is Array \
			or baseline is PackedByteArray \
			or baseline is PackedInt32Array \
			or baseline is PackedInt64Array \
			or baseline is PackedFloat32Array \
			or baseline is PackedFloat64Array \
			or baseline is PackedStringArray:
		return value is Array \
			or value is PackedByteArray \
			or value is PackedInt32Array \
			or value is PackedInt64Array \
			or value is PackedFloat32Array \
			or value is PackedFloat64Array \
			or value is PackedStringArray
	return baseline == null or typeof(value) == typeof(baseline)


static func _story_resume_slot_value_is_valid(value: Variant) -> bool:
	if value is int:
		return int(value) >= 1 and int(value) <= SaveManager.SLOT_COUNT
	if not value is float or not is_finite(float(value)) \
			or float(value) != float(int(value)):
		return false
	return int(value) >= 1 and int(value) <= SaveManager.SLOT_COUNT


static func _remove_file_if_present(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _load_session(load_game_state: bool) -> bool:
	var loaded := _read_session()
	if loaded.is_empty():
		return false
	_session = loaded
	if load_game_state:
		var state: Variant = _session.get("game_state", {})
		if not state is Dictionary:
			return false
		GameState.load_from_dict(state)
	_install_runtime_events()
	return true


func _read_session() -> Dictionary:
	var save_path := _active_save_path()
	for candidate_path in [save_path, "%s.tmp" % save_path, "%s.bak" % save_path]:
		var candidate := _read_session_candidate(candidate_path)
		if not candidate.is_empty():
			return candidate
	return {}


func _read_session_candidate(candidate_path: String) -> Dictionary:
	if not FileAccess.file_exists(candidate_path):
		return {}
	var file := FileAccess.open(candidate_path, FileAccess.READ)
	if file == null:
		return {}
	var parser := JSON.new()
	var parse_error := parser.parse(file.get_as_text())
	file.close()
	if parse_error != OK:
		return {}
	var parsed: Variant = parser.data
	if not parsed is Dictionary:
		return {}
	var data: Dictionary = parsed
	if not _session_dictionary_is_valid(data, _active_profile()):
		return {}
	return data


func _saved_phase() -> String:
	return str(_read_session().get("phase", ""))


func _state_summary() -> Dictionary:
	return {
		"turn": GameState.turn,
		"money": float(GameState.money),
		"health": int(GameState.health),
		"mental": int(GameState.mental),
	}


func _build_shell() -> void:
	var background := ColorRect.new()
	background.color = C_BG
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	_page = MarginContainer.new()
	_page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_page)
	_apply_margins()
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10 if _compact else 14)
	_page.add_child(column)

	var header := HBoxContainer.new()
	header.custom_minimum_size.y = 42 if _compact else 52
	header.add_theme_constant_override("separation", 8)
	column.add_child(header)
	var heading := VBoxContainer.new()
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_theme_constant_override("separation", 0)
	header.add_child(heading)
	_title = _label("", 20 if _compact else 24, C_TEXT, true)
	heading.add_child(_title)
	_subtitle = _label("", 12 if _compact else 14, C_DIM)
	heading.add_child(_subtitle)
	_home_button = _button(_t("처음 화면", "Home"), false)
	_home_button.visible = false
	_home_button.pressed.connect(_show_home)
	header.add_child(_home_button)
	_language_button = _button("", false)
	_language_button.pressed.connect(_on_language_button_pressed)
	header.add_child(_language_button)
	var rule := HSeparator.new()
	rule.modulate = C_BORDER
	column.add_child(rule)
	_body = Control.new()
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_body)
	_footer = _label("", 11 if _compact else 13, C_DIM)
	_footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(_footer)


func _show_language_gate() -> void:
	_cancel_transition_auto_launch()
	_set_screen("language")
	_clear_body()
	_title.text = "언어 · Language · 言語 · 语言 · 語言"
	_subtitle.text = "나중에 변경 가능 · Change later · 後で変更可 · 稍后可改 · 稍後可改"
	_home_button.visible = not _language_gate_required
	_home_button.text = _t("돌아가기", "Back")
	_language_button.visible = false
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_body.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(600 if _compact else 700, 350 if _compact else 410)
	panel.add_theme_stylebox_override("panel", _panel_style(C_PANEL, C_BORDER))
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_%s" % side, 18 if _compact else 28)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14 if _compact else 18)
	margin.add_child(column)
	var prompt := _label(
		"플레이할 언어를 선택하세요\nChoose your language\nプレイする言語を選んでください\n请选择游戏语言\n請選擇遊戲語言",
		18 if _compact else 22, C_TEXT, true)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(prompt)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(grid)
	var first_button: Button = null
	for language in PUBLIC_LANGUAGES:
		var language_button := _button(
			LocaleManager.get_language_display_name(language),
			language == LocaleManager.language)
		language_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		language_button.custom_minimum_size.y = 48 if _compact else 56
		language_button.pressed.connect(_select_language.bind(language))
		grid.add_child(language_button)
		if first_button == null:
			first_button = language_button
	_footer.text = "한국어 · English · 日本語 · 简体中文 · 繁體中文"
	_focus_later(first_button)


func _select_language(language: String) -> void:
	if not qa_set_language(language):
		return
	_language_gate_required = false
	_show_home()


func _show_home(notice: String = "") -> void:
	# Rebuilding the home view replaces the confirmation button, including on a
	# compact-layout resize. A newly rendered button must never inherit an arm.
	_restart_armed = false
	_cancel_transition_auto_launch()
	_set_screen("home")
	_clear_body()
	_title.text = _t("여섯 달의 선택", "Six Months of Choices")
	_subtitle.text = _t("장면에서 고르고, 다음 달에 그 대가를 삽니다.", "Choose in the scene. Live with it next month.")
	_home_button.visible = false
	_language_button.visible = true
	_language_button.text = "Language / 言語 / 语言 / 語言" if _public_demo \
		else ("ENGLISH" if LocaleManager.language == "ko" else "한국어")
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_body.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(620 if _compact else 720, 330 if _compact else 380)
	panel.add_theme_stylebox_override("panel", _panel_style(C_PANEL, C_BORDER))
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_%s" % side, 18 if _compact else 26)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12 if _compact else 16)
	margin.add_child(column)
	column.add_child(_label(
		_t("공개 데모 · 1월—6월", "Public demo · January—June") if _public_demo \
		else _t("독립 체험판 · 1월—6월", "Isolated playtest · January—June"),
		13, C_ACCENT, true))
	var hero := _label(_t("누구에게 시간을 쓰고, 무엇을 놓칠 것인가.", "Who gets your time—and what will you let go?"), 24 if _compact else 29, C_TEXT, true)
	hero.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(hero)
	var copy := _label(_t(
		"선택은 모두 실제 이야기 장면 안에서 이루어집니다. 장면이 끝나면 네 주의 생활비와 몸·마음의 압박이 자동으로 흐르고, 다음 장면이 남은 상태를 이어받습니다.",
		"Every choice happens inside an actual story scene. When it ends, four weeks of living costs and physical and mental pressure pass automatically, and the next scene inherits what remains."), 14 if _compact else 16, C_TEXT)
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.custom_minimum_size.y = 62 if _compact else 76
	column.add_child(copy)
	var baseline_text := _t(
		"편의점 야간 수입과 장면 사이의 잠·식사는 자동으로 이어집니다. 당신은 민준이 누구에게 다가가고, 무엇을 포기할지만 결정합니다.",
		"Night-shift income, sleep, and meals continue automatically between scenes. You decide whom Minjun approaches—and what he gives up.") if _public_demo else _t(
		"이 표본에서는 편의점 야간 수입과 장면 사이 최소한의 잠·식사를 자동 전제로 둡니다. 어떤 선택을 해도 여섯 번째 장면까지 확인하기 위한 체험 조건입니다.",
		"This sample assumes night-shift income and a minimum of sleep and meals between scenes. It is a playtest condition so every choice path can reach the sixth scene.")
	var baseline := _label(baseline_text, 12 if _compact else 13, C_DIM)
	baseline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	baseline.custom_minimum_size.y = 42 if _compact else 50
	column.add_child(baseline)
	if not notice.is_empty():
		var notice_label := _label(notice, 13, C_WARN, true)
		notice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(notice_label)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	column.add_child(actions)
	var continue_button := _button(_t("이어하기", "Continue"), true)
	continue_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	continue_button.disabled = _read_session().is_empty()
	continue_button.focus_mode = Control.FOCUS_NONE if continue_button.disabled else Control.FOCUS_ALL
	continue_button.pressed.connect(_continue_run)
	actions.add_child(continue_button)
	var start_button := _button(_t("처음부터", "Start new"), false)
	start_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	start_button.pressed.connect(_on_start_pressed.bind(start_button))
	actions.add_child(start_button)
	_footer.text = _t("방향키 / D패드 · 이동    Enter / 남쪽 버튼 · 확인", "Arrows / D-pad · Move    Enter / South button · Confirm")
	_focus_later(continue_button if not continue_button.disabled else start_button)


func _show_transition(notice: String = "") -> void:
	_cancel_transition_auto_launch()
	_set_screen("transition")
	_clear_body()
	var month := qa_current_month()
	_title.text = _tf("%d월", "Month %d", month, month)
	_subtitle.text = _next_scene_title(month)
	_home_button.visible = false
	_language_button.visible = false
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_body.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(650 if _compact else 760, 350 if _compact else 410)
	panel.add_theme_stylebox_override("panel", _panel_style(C_PANEL, C_BORDER))
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_%s" % side, 18 if _compact else 28)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12 if _compact else 16)
	margin.add_child(column)
	column.add_child(_label(_t("시간은 멈추지 않는다", "Time does not stop"), 13, C_ACCENT, true))
	var scene_title := _label(_next_scene_title(month), 25 if _compact else 31, C_TEXT, true)
	scene_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(scene_title)
	var previous: Dictionary = _last_settlement()
	var transition_copy := _t(
		"첫 장면이 기다리고 있습니다. 선택은 장면 안에서만 합니다.",
		"The first scene is waiting. Choices happen only inside it.")
	if not previous.is_empty():
		transition_copy = _t(
			"지난 장면 뒤 네 주가 흘렀습니다. 현금 %s, 몸 %d, 마음 %d. 다음 장면은 이 상태에서 시작합니다.",
			"Four weeks passed after the last scene. Cash %s, body %d, mind %d. The next scene begins from here.") % [
			GameState.format_money(float(previous.get("cash_after", GameState.money))),
			int(previous.get("health_after", GameState.health)),
			int(previous.get("mental_after", GameState.mental))]
	var copy := _label(transition_copy, 15 if _compact else 17, C_TEXT)
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.custom_minimum_size.y = 76
	column.add_child(copy)
	if not notice.is_empty():
		var notice_label := _label(notice, 13, C_WARN, true)
		notice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(notice_label)
	var waiting := _label(_t("잠시 후 다음 장면으로 이어집니다.", "The next scene will begin in a moment."), 14 if _compact else 16, C_ACCENT, true)
	waiting.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(waiting)
	var enter_button := _button(_t("다음 장면", "Enter the next scene"), true)
	enter_button.pressed.connect(_launch_story)
	column.add_child(enter_button)
	_footer.text = _t(
		"잠시 후 자동 이동 · Enter / 남쪽 버튼으로 바로 시작",
		"Continues automatically · Enter / South button to start now")
	_focus_later(enter_button)
	_schedule_transition_auto_launch()


func _show_recap() -> void:
	_cancel_transition_auto_launch()
	_set_screen("recap")
	_clear_body()
	_title.text = _t("여섯 달의 흔적", "What Six Months Left")
	_subtitle.text = _t("실제로 고른 장면과 남은 상태", "The scenes you chose and the state that remains")
	_home_button.visible = true
	_home_button.text = _t("처음 화면", "Home")
	_language_button.visible = true
	_language_button.text = "Language / 言語 / 语言 / 語言" if _public_demo \
		else ("ENGLISH" if LocaleManager.language == "ko" else "한국어")
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_stylebox_override("panel", _panel_style(C_PANEL, C_BORDER))
	_body.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_%s" % side, 12 if _compact else 20)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 5 if _compact else 8)
	margin.add_child(column)
	var summary := _label(_t(
		"24주 · 정산 6회 · 현금 %s · 몸 %d · 마음 %d",
		"24 weeks · 6 settlements · Cash %s · Body %d · Mind %d") % [
		GameState.format_money(GameState.money), GameState.health, GameState.mental],
		15 if _compact else 17, C_GOOD, true)
	column.add_child(summary)
	var records: Array = _session.get("choices", [])
	for record_variant in records:
		if not record_variant is Dictionary:
			continue
		var record: Dictionary = record_variant
		var event: Dictionary = DataRegistry.find_event(str(record.get("event_id", "")))
		var choice_index := int(record.get("choice_index", -1))
		var choices: Array = event.get("choices", [])
		var choice_text := str((choices[choice_index] as Dictionary).get("text", "")) \
			if choice_index >= 0 and choice_index < choices.size() else ""
		var record_month := int(record.get("month", 0))
		var row := _label(_tf(
			"%d월", "Month %d", record_month, record_month) \
			+ "  ·  " + str(event.get("title", record.get("event_id", ""))) \
			+ "  —  " + choice_text,
			11 if _compact else 13, C_TEXT)
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		row.custom_minimum_size.y = 24 if _compact else 30
		column.add_child(row)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)
	var done := _button(_t("처음 화면으로", "Return home"), true)
	done.pressed.connect(_show_home)
	column.add_child(done)
	_footer.text = _t(
		"이 기록은 이 데모 전용 저장에만 남습니다.",
		"This record stays only in this demo's dedicated save.") if _public_demo else _t(
		"이 기록은 이 체험판의 전용 JSON에만 저장됩니다.",
		"This record is stored only in this playtest's dedicated JSON file.")
	_focus_later(done)


func _next_scene_title(month: int) -> String:
	var titles := PackedStringArray()
	for event_id in _event_ids_for_month(month):
		var event: Dictionary = DataRegistry.find_event(str(event_id))
		titles.append(str(event.get("title", event_id)))
	return " · ".join(titles)


func _last_settlement() -> Dictionary:
	var settlements: Array = _session.get("settlements", [])
	return settlements.back() if not settlements.is_empty() and settlements.back() is Dictionary else {}


func _on_start_pressed(button: Button) -> void:
	if not _read_session().is_empty() and not _restart_armed:
		_restart_armed = true
		button.text = _t("한 번 더 누르면 새로 시작", "Press again to start over")
		return
	_start_new_run()


func _on_language_button_pressed() -> void:
	if _public_demo:
		_show_language_gate()
	else:
		_toggle_language()


func _toggle_language() -> void:
	LocaleManager.set_language("en" if LocaleManager.language == "ko" else "ko")
	_install_runtime_events()
	_refresh_screen()


func _on_language_changed(_language: String) -> void:
	call_deferred("_refresh_after_language_reload")


func _refresh_after_language_reload() -> void:
	_install_runtime_events()
	_refresh_screen()


func _refresh_screen() -> void:
	match _screen:
		"language": _show_language_gate()
		"transition": _show_transition()
		"recap": _show_recap()
		_: _show_home()


func _schedule_transition_auto_launch() -> void:
	if not _auto_launch_enabled:
		return
	_transition_serial += 1
	_auto_launch_after_delay(_transition_serial)


func _cancel_transition_auto_launch() -> void:
	_transition_serial += 1


func _auto_launch_after_delay(serial: int) -> void:
	await get_tree().create_timer(3.0).timeout
	if serial != _transition_serial or _screen != "transition" or not _auto_launch_enabled:
		return
	_launch_story()


func _set_screen(value: String) -> void:
	if _screen != value:
		# A destructive restart confirmation belongs only to the exact home view
		# and button that presented it. Navigating away always cancels the arm.
		_restart_armed = false
	_screen = value
	set_meta("order124_screen", value)
	screen_changed.emit(value)


func _clear_body() -> void:
	for child in _body.get_children():
		_body.remove_child(child)
		child.queue_free()


func _label(text_value: String, size: int, color: Color, bold: bool = false) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	var font := FontKit.ui_bold() if bold else FontKit.ui_regular()
	FontKit.attach_emoji_fallback(font)
	label.add_theme_font_override("font", font)
	return label


func _button(text_value: String, primary: bool) -> Button:
	var button := Button.new()
	button.text = text_value
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", FontKit.ui_bold())
	button.add_theme_font_size_override("font_size", 14 if _compact else 16)
	button.add_theme_color_override("font_color", C_BG if primary else C_TEXT)
	button.add_theme_color_override("font_hover_color", C_BG if primary else C_TEXT)
	button.add_theme_color_override("font_focus_color", C_BG if primary else C_TEXT)
	var normal := _panel_style(C_ACCENT if primary else C_PANEL_ALT, C_ACCENT if primary else C_BORDER, 8)
	var hover := _panel_style((C_ACCENT.lightened(0.08) if primary else C_PANEL_ALT.lightened(0.08)), C_TEXT, 8)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.mouse_entered.connect(_focus_control.bind(button))
	return button


func _panel_style(color: Color, border: Color, radius: int = 10) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _focus_control(control: Control) -> void:
	if is_instance_valid(control) and control.is_inside_tree() \
			and control.focus_mode != Control.FOCUS_NONE:
		control.grab_focus()


func _focus_later(control: Control) -> void:
	call_deferred("_focus_control", control)


func _apply_margins() -> void:
	if not is_instance_valid(_page):
		return
	var margin := 12 if _compact else 20
	for side in ["left", "right", "top", "bottom"]:
		_page.add_theme_constant_override("margin_%s" % side, margin)


func _on_resized() -> void:
	var next_compact := get_viewport_rect().size.y <= 650.0
	if next_compact == _compact:
		return
	_compact = next_compact
	_apply_margins()
	_refresh_screen()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _screen == "recap":
		_show_home()
		get_viewport().set_input_as_handled()


func _collect_visible_text(node: Node, lines: PackedStringArray) -> void:
	if node is CanvasItem and not (node as CanvasItem).visible:
		return
	if node is Label:
		lines.append((node as Label).text)
	elif node is Button:
		lines.append((node as Button).text)
	for child in node.get_children():
		_collect_visible_text(child, lines)


func _t(ko: String, en: String) -> String:
	return LocaleManager.ui(ko, en)


func _tf(
		ko_template: String, en_template: String,
		ko_args: Variant, en_args: Variant) -> String:
	return LocaleManager.ui_format(
		ko_template, en_template, ko_args, en_args)


func _available_languages() -> Array[String]:
	return PUBLIC_LANGUAGES if _public_demo else LEGACY_LANGUAGES


func _active_profile() -> String:
	return PUBLIC_PROFILE if _public_demo else PROFILE


func _active_build_id() -> String:
	return PUBLIC_BUILD_ID if _public_demo else BUILD_ID


func _active_save_path() -> String:
	return PUBLIC_SAVE_PATH if _public_demo else SAVE_PATH


func _active_custom_user_dir() -> String:
	return PUBLIC_CUSTOM_USER_DIR if _public_demo else CUSTOM_USER_DIR


func _argument_value(args: PackedStringArray, prefix: String) -> String:
	for argument in args:
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""


func _isolated_user_data_configured() -> bool:
	if not bool(ProjectSettings.get_setting(
			"application/config/use_custom_user_dir", false)):
		return false
	var configured_name := str(ProjectSettings.get_setting(
		"application/config/custom_user_dir_name", ""))
	if configured_name in [CUSTOM_USER_DIR, PUBLIC_CUSTOM_USER_DIR]:
		return true
	return (OS.get_environment("ORDER124_ALLOW_ISOLATED_QA") == "1" \
		and configured_name.begins_with("GangnamDream_ORDER124_RuntimeQA_")) \
		or (_public_runtime_qa_allowed() \
		and configured_name.begins_with(PUBLIC_RUNTIME_QA_PREFIX))


func _public_user_data_configured() -> bool:
	if not bool(ProjectSettings.get_setting(
		"application/config/use_custom_user_dir", false)):
		return false
	var configured_name := str(ProjectSettings.get_setting(
		"application/config/custom_user_dir_name", ""))
	return configured_name == PUBLIC_CUSTOM_USER_DIR \
		or (_public_runtime_qa_allowed() \
		and configured_name.begins_with(PUBLIC_RUNTIME_QA_PREFIX))


func _bootstrap_public_qa_namespace() -> void:
	if OS.get_environment("STORY_DEMO_ALLOW_ISOLATED_QA") != "1":
		return
	var bootstrap_name := OS.get_environment("STORY_DEMO_QA_BOOTSTRAP_NAME")
	if not bootstrap_name.begins_with(PUBLIC_RUNTIME_QA_PREFIX):
		return
	ProjectSettings.set_setting("application/config/use_custom_user_dir", true)
	ProjectSettings.set_setting(
		"application/config/custom_user_dir_name", bootstrap_name)
	# The QA namespace is selected after Godot has initialized its ordinary
	# project path, so a brand-new namespace is not created automatically.
	# Create only this validated RuntimeQA directory before the first autosave.
	DirAccess.make_dir_recursive_absolute(OS.get_user_data_dir())


func _public_runtime_qa_allowed() -> bool:
	return OS.get_environment("STORY_DEMO_ALLOW_ISOLATED_QA") == "1" \
		or OS.get_cmdline_user_args().has(PUBLIC_RUNTIME_QA_ARG)


func _run_real_flow_smoke() -> void:
	_auto_launch_enabled = false
	_cancel_transition_auto_launch()
	AudioManager.sfx_enabled = false
	var tree := get_tree()
	var verify_key := "story_demo_real_flow_verify"
	var raw_choice := _argument_value(
		OS.get_cmdline_user_args(), PUBLIC_REAL_FLOW_CHOICE_ARG)
	if raw_choice not in ["0", "1"]:
		push_error("STORY_DEMO_REAL_FLOW_SMOKE: invalid setup")
		get_tree().quit(1)
		return
	var expected_choice := int(raw_choice)
	var expected_route := "fallout" if expected_choice == 1 else "clean"
	if tree.has_meta(verify_key):
		var raw_state: Variant = tree.get_meta(verify_key)
		if not raw_state is Dictionary:
			push_error("STORY_DEMO_REAL_FLOW_SMOKE: invalid retained state")
			tree.remove_meta(verify_key)
			get_tree().quit(1)
			return
		var flow_state: Dictionary = (raw_state as Dictionary).duplicate(true)
		if int(flow_state.get("choice", -1)) != expected_choice:
			push_error("STORY_DEMO_REAL_FLOW_SMOKE: retained route drift")
			tree.remove_meta(verify_key)
			get_tree().quit(1)
			return
		if bool(flow_state.get("manual_restart_pending", false)):
			flow_state["manual_restart_pending"] = false
			flow_state["manual_restart_resumed"] = true
			tree.set_meta(verify_key, flow_state)
			if not qa_continue_run():
				push_error("STORY_DEMO_REAL_FLOW_SMOKE: manual cold resume failed")
				tree.remove_meta(verify_key)
				get_tree().quit(1)
				return
			flow_state["resume_state_fingerprint"] = \
				real_flow_resume_state_fingerprint()
			tree.set_meta(verify_key, flow_state)
			return
		await tree.create_timer(0.85).timeout
		var failures: Array[String] = []
		var snapshot := qa_session_snapshot()
		var choices: Array = snapshot.get("choices", [])
		var expected_records := _real_flow_expected_records(expected_choice)
		if choices.is_empty() or choices.size() > expected_records.size() \
				or not _real_flow_choice_prefix_matches(choices, expected_records):
			failures.append("choice_receipt")
		var progress := _real_flow_progress_after_receipts(choices.size())
		if progress.is_empty():
			failures.append("receipt_progress")
		else:
			var expected_month := int(progress.get("month", -1))
			var expected_settlements := int(progress.get("settlements", -1))
			if qa_current_month() != expected_month:
				failures.append("month")
			if int(snapshot.get("elapsed_weeks", -1)) \
					!= expected_settlements * 4:
				failures.append("weeks")
			if int(snapshot.get("monthly_pressure_count", -1)) \
					!= expected_settlements:
				failures.append("settlement")
			var expected_screen := "recap" if choices.size() == 9 else "transition"
			if qa_screen() != expected_screen:
				failures.append("screen")
		if choices.size() >= 1 \
				and str(qa_schedule().get("m02_route", "")) != expected_route:
			failures.append("m02_route")
		if qa_monthly_action_receipt_count() != 0:
			failures.append("ap_ledger")
		if not bool(flow_state.get("manual_save", false)):
			failures.append("manual_save")
		var overlay := qa_transition_overlay_state()
		if float(overlay.get("alpha", 1.0)) > 0.01:
			failures.append("overlay")
		if bool(overlay.get("blocks_input", true)):
			failures.append("input")
		if not failures.is_empty():
			for failure in failures:
				push_error("STORY_DEMO_REAL_FLOW_SMOKE: %s" % failure)
			tree.remove_meta(verify_key)
			await _stop_smoke_audio()
			get_tree().quit(1)
			return
		if choices.size() == 9:
			if not bool(flow_state.get("manual_restart_resumed", false)):
				push_error("STORY_DEMO_REAL_FLOW_SMOKE: cold restart was not resumed")
				tree.remove_meta(verify_key)
				get_tree().quit(1)
				return
			if not bool(flow_state.get("exact_result_phase_verified", false)):
				push_error("STORY_DEMO_REAL_FLOW_SMOKE: exact result resume was not verified")
				tree.remove_meta(verify_key)
				get_tree().quit(1)
				return
			tree.remove_meta(verify_key)
			print("STORY_DEMO_REAL_FLOW_SMOKE_OK build=%s language=%s choice=%d m02=%s months=6 weeks=24 settlements=6 receipts=9 story=real manual_save=1 cold_restart=1 exact_resume=1 overlay=clear input=clear ap_ledger=0" % [
				_active_build_id(), LocaleManager.language, expected_choice,
				expected_route])
			await _stop_smoke_audio()
			get_tree().quit(0)
			return
		tree.set_meta(verify_key, flow_state)
		_launch_story()
		return

	if not qa_start_new_run():
		push_error("STORY_DEMO_REAL_FLOW_SMOKE: invalid setup")
		get_tree().quit(1)
		return
	tree.set_meta(verify_key, {
		"choice": expected_choice,
		"manual_save": false,
		"manual_restart_pending": false,
		"manual_restart_resumed": false,
		"exact_result_phase_verified": false,
	})
	_launch_story()


func _real_flow_expected_records(route_choice: int) -> Array[Dictionary]:
	var m02_event := "arc_temptation_fallout" \
		if route_choice == 1 else "arc_temptation_clean"
	var m04_branch := M4_COFFEE_EVENT_ID \
		if route_choice == 1 else M4_MEASURE_EVENT_ID
	var event_ids: Array[String] = [
		"arc_temptation_01", m02_event,
		"arc_daeun_01_meet", "arc_jiyeon_01_crash",
		M4_ROOT_EVENT_ID, m04_branch, M4_ANSWER_EVENT_ID,
		"arc_jaehyuk_01_reunion", M6_EVENT_ID,
	]
	var choice_indices: Array[int] = [
		route_choice, 0, route_choice, 0,
		route_choice, 0, route_choice,
		route_choice, 3 if route_choice == 1 else 0,
	]
	var records: Array[Dictionary] = []
	for index in range(event_ids.size()):
		records.append({
			"event_id": event_ids[index],
			"choice_index": choice_indices[index],
		})
	return records


static func real_flow_resume_state_fingerprint() -> String:
	var serialized: Dictionary = GameState.serialize()
	var fingerprint := {}
	for key in [
		"turn", "year", "month", "week_of_month",
		"money", "health", "mental", "flags",
	]:
		var value: Variant = serialized.get(key)
		fingerprint[key] = (value as Dictionary).duplicate(true) \
			if value is Dictionary else value
	for key in ACTION_LEDGER_KEYS:
		var ledger_value: Variant = serialized.get(key)
		if ledger_value is Dictionary:
			fingerprint[key] = (ledger_value as Dictionary).duplicate(true)
		elif ledger_value is Array:
			fingerprint[key] = (ledger_value as Array).duplicate(true)
		else:
			fingerprint[key] = ledger_value
	return JSON.stringify(fingerprint, "", true)


func _real_flow_choice_prefix_matches(
		actual: Array, expected: Array[Dictionary]) -> bool:
	for index in range(actual.size()):
		if not actual[index] is Dictionary:
			return false
		var record: Dictionary = actual[index]
		if str(record.get("event_id", "")) \
				!= str(expected[index].get("event_id", "")) \
				or int(record.get("choice_index", -1)) \
				!= int(expected[index].get("choice_index", -2)):
			return false
	return true


func _real_flow_progress_after_receipts(receipt_count: int) -> Dictionary:
	match receipt_count:
		1: return {"month": 2, "settlements": 1}
		2: return {"month": 3, "settlements": 2}
		3: return {"month": 3, "settlements": 2}
		4: return {"month": 4, "settlements": 3}
		5, 6: return {"month": 4, "settlements": 3}
		7: return {"month": 5, "settlements": 4}
		8: return {"month": 6, "settlements": 5}
		9: return {"month": 7, "settlements": 6}
	return {}


func _run_return_smoke() -> void:
	_auto_launch_enabled = false
	_cancel_transition_auto_launch()
	AudioManager.sfx_enabled = false
	if get_tree().has_meta("order124_return_smoke_verify"):
		get_tree().remove_meta("order124_return_smoke_verify")
		await get_tree().create_timer(0.70).timeout
		var overlay := qa_transition_overlay_state()
		var snapshot := qa_session_snapshot()
		var choices: Array = snapshot.get("choices", [])
		var settlements: Array = snapshot.get("settlements", [])
		var passed := qa_screen() == "transition" \
			and qa_current_month() == 2 \
			and int(snapshot.get("elapsed_weeks", -1)) == 4 \
			and int(snapshot.get("monthly_pressure_count", -1)) == 1 \
			and choices.size() == 1 and settlements.size() == 1 \
			and float(overlay.get("alpha", 1.0)) <= 0.01 \
			and not bool(overlay.get("blocks_input", true))
		var return_prefix := "STORY_DEMO_RETURN_SMOKE" if _public_demo \
			else "ORDER124_RETURN_SMOKE"
		if passed:
			print("%s_OK build=%s screen=transition month=2 overlay=clear input=clear choices=1 settlements=1" % [
				return_prefix, _active_build_id()])
			await _stop_smoke_audio()
			get_tree().quit(0)
			return
		push_error("%s: return contract failed screen=%s month=%d snapshot=%s overlay=%s" % [return_prefix,
			qa_screen(), qa_current_month(), snapshot, overlay])
		await _stop_smoke_audio()
		get_tree().quit(1)
		return

	if not qa_start_new_run() or not qa_prepare_story_return(0):
		push_error("%s: could not prepare M01 story return" % [
			"STORY_DEMO_RETURN_SMOKE" if _public_demo else "ORDER124_RETURN_SMOKE"])
		await _stop_smoke_audio()
		get_tree().quit(1)
		return
	get_tree().set_meta("order124_return_smoke_verify", true)
	# Use the real fade-out and scene reload so the packaged check covers the
	# exact contract that produced BUILD .2's black screen.
	SceneTransition.go(SELF_SCENE)


func _run_resume_smoke() -> void:
	_auto_launch_enabled = false
	_cancel_transition_auto_launch()
	AudioManager.sfx_enabled = false
	var saved := _read_session()
	var saved_canonical := JSON.stringify(saved, "", true)
	var failures: Array[String] = []
	if saved.is_empty():
		failures.append("missing_save")
	var saved_phase := str(saved.get("phase", ""))
	if saved_phase not in ["story", "transition", "recap"]:
		failures.append("phase")
	if not qa_continue_run():
		failures.append("continue")
	var snapshot := qa_session_snapshot()
	var settlements: Array = snapshot.get("settlements", [])
	var choices: Array = snapshot.get("choices", [])
	var closed: Array = snapshot.get("closed_months", [])
	var month := int(snapshot.get("current_month", 0))
	var weeks := int(snapshot.get("elapsed_weeks", -1))
	var settlement_count := int(snapshot.get("monthly_pressure_count", -1))
	var expected_screen := "recap" if saved_phase == "recap" else "transition"
	if month < 1 or month > 7: failures.append("month")
	if weeks != closed.size() * 4: failures.append("weeks")
	if settlement_count != closed.size() or settlements.size() != closed.size():
		failures.append("settlements")
	if qa_screen() != expected_screen: failures.append("screen")
	if JSON.stringify(_read_session(), "", true) != saved_canonical:
		failures.append("save_mutated")
	var overlay := qa_transition_overlay_state()
	if float(overlay.get("alpha", 1.0)) > 0.01:
		failures.append("overlay")
	if bool(overlay.get("blocks_input", true)):
		failures.append("input")
	var resume_prefix := "STORY_DEMO_RESUME_SMOKE" if _public_demo \
		else "ORDER124_RESUME_SMOKE"
	if failures.is_empty():
		print("%s_OK build=%s month=%d weeks=%d settlements=%d choices=%d phase=%s screen=%s overlay=clear input=clear" % [
			resume_prefix, _active_build_id(), month, weeks, settlement_count, choices.size(),
			saved_phase, qa_screen()])
		await _stop_smoke_audio()
		get_tree().quit(0)
		return
	for failure in failures:
		push_error("%s: %s" % [resume_prefix, failure])
	await _stop_smoke_audio()
	get_tree().quit(1)


func _run_smoke() -> void:
	await get_tree().process_frame
	# Automated settlement should not leave a short SFX playback alive at process exit.
	AudioManager.sfx_enabled = false
	var failures: Array[String] = []
	var requested_language := _argument_value(OS.get_cmdline_user_args(),
		"--story-demo-language=" if _public_demo else "--order124-language=")
	if requested_language.is_empty():
		requested_language = "ko"
	if requested_language not in _available_languages() \
			or not qa_set_language(requested_language):
		failures.append("language")
	if not qa_start_new_run(): failures.append("start")
	if qa_screen() != "transition": failures.append("home_to_transition")
	var first := qa_choose_current(0)
	if not bool(first.get("applied", false)): failures.append("choice")
	var close := qa_simulate_month_close_and_save(1)
	if not bool(close.get("closed", false)): failures.append("close")
	if not qa_continue_run(): failures.append("continue")
	if qa_current_month() != 2: failures.append("resume_month")
	if int(_session.get("elapsed_weeks", -1)) != 4: failures.append("weeks")
	if int(_session.get("monthly_pressure_count", -1)) != 1: failures.append("settlement")
	if failures.is_empty():
		var size := DisplayServer.window_get_size()
		print("%s language=%s size=%dx%d start=1 save=1 continue=1 month=m02 weeks=4 settlement=1" % [
			"STORY_DEMO_WRAPPER_SMOKE_OK" if _public_demo else "ORDER124_WRAPPER_SMOKE_OK",
			LocaleManager.language, size.x, size.y])
		await _stop_smoke_audio()
		await get_tree().process_frame
		await get_tree().process_frame
		get_tree().quit(0)
		return
	for failure in failures:
		push_error("%s: %s" % [
			"STORY_DEMO_WRAPPER_SMOKE" if _public_demo else "ORDER124_WRAPPER_SMOKE",
			failure])
	await _stop_smoke_audio()
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().quit(1)


func _stop_smoke_audio() -> void:
	# The graphical release runner owns a real CoreAudio mixer. Stop every
	# autoload player, sever its stream references, and give the mixer one
	# interval to release playback objects before quitting. Merely stopping the
	# SFX pool leaves each StoryMode BGM playback alive in the resource cache and
	# turns a successful packaged M01-M06 run into a false release-gate failure.
	AudioManager.begin_story_audio_event("story_demo_smoke_cleanup")
	AudioManager.stop_gamepad_vibration()
	var players: Variant = AudioManager.get("_pool")
	if players is Array:
		for player_variant in players:
			if player_variant is AudioStreamPlayer:
				var player := player_variant as AudioStreamPlayer
				player.stop()
				player.stream = null
				player.queue_free()
		(players as Array).clear()
	var sounds: Variant = AudioManager.get("_sounds")
	if sounds is Dictionary:
		(sounds as Dictionary).clear()
	BGMPlayer.stop()
	for tween_key in [
		"_fade_tween", "_ambience_tween", "_season_tween",
		"_human_ambience_tween", "_moral_human_tween",
		"_moral_filter_tween",
	]:
		var tween_value: Variant = BGMPlayer.get(tween_key)
		if tween_value is Tween and (tween_value as Tween).is_running():
			(tween_value as Tween).kill()
		BGMPlayer.set(tween_key, null)
	for player_key in [
		"_player_a", "_player_b", "_ambience_player", "_season_player",
		"_human_ambience_player",
	]:
		var player_value: Variant = BGMPlayer.get(player_key)
		if player_value is AudioStreamPlayer:
			var player := player_value as AudioStreamPlayer
			player.stop()
			player.stream = null
			player.queue_free()
			BGMPlayer.set(player_key, null)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.35).timeout


func _capture_requested_screen() -> void:
	_auto_launch_enabled = false
	_cancel_transition_auto_launch()
	AudioManager.sfx_enabled = false
	match _screenshot_screen:
		"home": _show_home()
		"transition":
			if not qa_start_new_run():
				_screenshot_fail("transition_setup")
				return
		"recap":
			if not _prepare_recap_screenshot():
				_screenshot_fail("recap_setup")
				return
		"story":
			if not _prepare_story_screenshot():
				_screenshot_fail("story_setup")
				return
		_:
			_screenshot_fail("unknown_screen")
			return
	await get_tree().process_frame
	if is_instance_valid(_story_screenshot_instance) \
			and _story_screenshot_instance.has_method("_complete_typing"):
		_story_screenshot_instance.call("_complete_typing")
	# Newly selected CJK variable fonts can finish shaping one or two frames
	# after the controls are built. Capture only after the container graph has
	# settled, otherwise parallel QA launches can record a transient wide layout.
	for _settle_frame in range(8):
		await get_tree().process_frame
	if DisplayServer.get_name() == "headless":
		_screenshot_fail("headless_display")
		return
	var image := get_viewport().get_texture().get_image()
	if image == null:
		_screenshot_fail("no_viewport_image")
		return
	var window_size := DisplayServer.window_get_size()
	if window_size.x > 0 and window_size.y > 0 \
			and image.get_size() != window_size:
		image.resize(window_size.x, window_size.y, Image.INTERPOLATE_LANCZOS)
	var error := image.save_png(_screenshot_path)
	var screenshot_prefix := "STORY_DEMO_SCREENSHOT" if _public_demo \
		else "ORDER124_SCREENSHOT"
	if error == OK:
		print("%s_OK screen=%s path=%s" % [
			screenshot_prefix, _screenshot_screen, _screenshot_path])
	else:
		push_error("%s_FAIL path=%s error=%d" % [
			screenshot_prefix, _screenshot_path, error])
	if _screenshot_exit:
		get_tree().quit(0 if error == OK else 1)


func _prepare_recap_screenshot() -> bool:
	if not qa_start_new_run():
		return false
	for month in range(1, 7):
		var choice_guard := 0
		while not _remaining_event_ids(month).is_empty() and choice_guard < 8:
			var choice: Dictionary = qa_choose_current(0)
			if not bool(choice.get("applied", false)):
				return false
			choice_guard += 1
		if choice_guard >= 8:
			return false
		var close: Dictionary = qa_close_month(month)
		if not bool(close.get("closed", false)):
			return false
	return _screen == "recap"


func _prepare_story_screenshot() -> bool:
	if not qa_start_new_run():
		return false
	var queue := _remaining_event_ids(1)
	if queue.is_empty():
		return false
	GameState.pending_story_queue = queue.duplicate()
	GameState.story_return_scene = SELF_SCENE
	GameState.story_replay_mode = false
	var packed := load(STORY_SCENE) as PackedScene
	if packed == null:
		return false
	_story_screenshot_instance = packed.instantiate()
	get_tree().root.add_child(_story_screenshot_instance)
	visible = false
	return true


func _screenshot_fail(reason: String) -> void:
	push_error("%s_FAIL screen=%s path=%s error=%s" % [
		"STORY_DEMO_SCREENSHOT" if _public_demo else "ORDER124_SCREENSHOT",
		_screenshot_screen, _screenshot_path, reason])
	if _screenshot_exit:
		get_tree().quit(1)
