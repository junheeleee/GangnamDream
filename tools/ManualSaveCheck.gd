extends Node
## ManualSaveCheck — 10슬롯과 StoryMode 중간 재개 계약을 실제 런타임으로 검증한다.

const TEST_SLOT := 1
const LEGACY_SLOT := 9
const CONTRACT_SLOT := 10

var _story: Control = null
var _failures: Array[String] = []
var _backups: Dictionary = {}
var _settings_backup: Dictionary = {}
var _meta_file_backup: Dictionary = {}
var _meta_data_backup: Dictionary = {}
var _meta_new_this_run_backup: Dictionary = {}

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	_backup_settings_file()
	_backup_meta_progression()
	_backup_test_slots()
	GameState.start_new_game()
	_check_slot_and_legacy_contract()
	if not _failures.is_empty():
		await _finish()
		return
	await _check_prose_resume()
	await _check_choice_and_result_resume()
	await _check_timed_choice_resume()
	await _check_cross_locale_resume_rewind()
	await _check_pre_dialogue_history_resume()
	await _check_story_save_surface()
	await _finish()

func _check_slot_and_legacy_contract() -> void:
	_expect(SaveManager.SLOT_COUNT == 10, "manual slot count is not 10")
	GameState.turn = 97
	var context := {
		"kind": "story",
		"scene": "res://scenes/StoryMode.tscn",
		"event_id": "chapter_card_35",
		"queue": [],
		"phase": "chapter",
	}
	_expect(SaveManager.save_game(CONTRACT_SLOT, context, {
		"label": "Chapter 3 QA", "qa_fixture": true,
	}), "slot 10 could not be written")
	var info := SaveManager.get_save_info(CONTRACT_SLOT)
	_expect(int(info.get("chapter", 0)) == 3, "slot metadata chapter is not derived from week 97")
	_expect(str(info.get("event_id", "")) == "chapter_card_35",
		"slot metadata lost the StoryMode event")
	_expect(bool(info.get("qa_fixture", false)), "slot metadata lost the QA marker")
	_expect(SaveManager.load_game(CONTRACT_SLOT), "slot 10 could not be loaded")
	_expect(SaveManager.loaded_scene_path() == "res://scenes/StoryMode.tscn",
		"StoryMode save routes to the wrong scene")
	_expect(str(SaveManager.peek_loaded_resume_context().get("phase", "")) == "chapter",
		"StoryMode resume payload was not retained")
	SaveManager.clear_loaded_resume_context()

	var legacy_payload := {
		"version": 3,
		"narrative_rhythm_version": SaveManager.NARRATIVE_RHYTHM_VERSION,
		"saved_at": "2026-07-24T00:00:00",
		"state": GameState.serialize(),
	}
	var legacy_file := FileAccess.open(SaveManager.slot_path(LEGACY_SLOT), FileAccess.WRITE)
	_expect(legacy_file != null, "legacy fixture could not be opened")
	if legacy_file != null:
		legacy_file.store_string(JSON.stringify(legacy_payload))
		legacy_file.close()
	_expect(SaveManager.load_game(LEGACY_SLOT), "v3 save no longer loads")
	_expect(SaveManager.loaded_scene_path() == "res://scenes/MainGame.tscn",
		"v3 save should fall back to MainGame")
	_expect(SaveManager.peek_loaded_resume_context().is_empty(),
		"v3 save invented a StoryMode resume payload")

func _check_prose_resume() -> void:
	GameState.start_new_game()
	if not await _spawn_story("story_knee_choice"):
		return
	_story.call("_set_story_text_size", "large")
	_story.call("_complete_typing")
	_story.call("_on_advance")
	var partial_position := mini(
		7, maxi(1, str(_story.get("_type_full")).length() - 1))
	_story.set("_type_pos", partial_position)
	(_story.get("_body_lbl") as RichTextLabel).text = str(
		_story.get("_type_full")).substr(0, partial_position)
	var saved_prefix := str(_story.call(
		"_dialogue_log_source_text",
		_story.call("_story_source_paragraph_index", int(_story.get("_para_index"))),
		int(_story.get("_para_index")), true))
	var context: Dictionary = _story.call("build_save_resume_context")
	_expect(str(context.get("phase", "")) == "prose", "prose save reported the wrong phase")
	_expect(context.has("source_paragraph_index") and context.has("source_text_progress"),
		"prose save omitted source-based text progress")
	var saved_source_index := int(context.get("source_paragraph_index", -1))
	var saved_source_progress := float(context.get("source_text_progress", -1.0))
	var prose_log: Dictionary = context.get("dialogue_log", {})
	var prose_entries: Array = prose_log.get("entries", [])
	_expect(int(prose_log.get("schema", 0)) == 1 and prose_entries.size() == 1,
		"prose save did not retain the one fully read dialogue block")
	_expect(SaveManager.save_game(TEST_SLOT, context), "prose save failed")
	await _free_story()
	# Pagination is presentation state, not narrative state. Loading under a
	# different text size must return to the same authored source position.
	SaveManager.set_setting("story_text_size", "small")
	_expect(SaveManager.load_game(TEST_SLOT), "prose save could not be reloaded")
	if not await _spawn_loaded_story():
		return
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) == "story_knee_choice",
		"prose resume loaded the wrong event")
	var restored_page := int(_story.get("_para_index"))
	var restored_source_index := int(_story.call(
		"_story_source_paragraph_index", restored_page))
	_expect(restored_source_index == saved_source_index,
		"prose resume crossed into a different authored paragraph")
	_expect(bool(_story.get("_typing")), "partially typed prose did not resume typing")
	var restored_full := str(_story.get("_type_full"))
	var restored_ratio := (
		float(_story.get("_type_pos")) / float(maxi(1, restored_full.length())))
	var restored_source_progress := float(_story.call(
		"_story_source_page_progress", restored_page, restored_ratio))
	_expect(absf(restored_source_progress - saved_source_progress) <= 0.03,
		"text-size change moved the prose resume point")
	var restored_prefix := str(_story.call(
		"_dialogue_log_source_text", restored_source_index, restored_page, true))
	_expect(restored_prefix.length() <= saved_prefix.length() + 2,
		"text-size change exposed prose beyond the saved point")
	_expect((_story.get("_dialogue_log_entries") as Array) == prose_entries,
		"prose resume changed or duplicated Dialogue History")

func _check_choice_and_result_resume() -> void:
	if not is_instance_valid(_story):
		return
	_story.call("_finish_story_scene_transition")
	_story.set("_para_index", (_story.get("_paragraphs") as Array).size() - 1)
	_story.call("_complete_typing")
	_story.call("_show_choices")
	var choice_context: Dictionary = _story.call("build_save_resume_context")
	_expect(str(choice_context.get("phase", "")) == "choices",
		"choice save reported the wrong phase")
	var choice_log_before: Array = (
		(choice_context.get("dialogue_log", {}) as Dictionary).get("entries", []) as Array
	).duplicate(true)
	_expect(SaveManager.save_game(TEST_SLOT, choice_context), "choice save failed")
	await _free_story()
	_expect(SaveManager.load_game(TEST_SLOT), "choice save could not be reloaded")
	if not await _spawn_loaded_story():
		return
	_expect(bool(_story.get("_showing_choices")), "choice resume did not restore the choice rail")
	_expect((_story.get("_dialogue_log_entries") as Array) == choice_log_before,
		"choice resume changed Dialogue History")

	var mental_before := int(GameState.mental)
	_story.call("_on_choice", 0)
	var mental_after := int(GameState.mental)
	_expect(mental_after == mental_before - 2, "fixture choice did not apply its effect once")
	var result_context: Dictionary = _story.call("build_save_resume_context")
	_expect(str(result_context.get("phase", "")) == "result",
		"result save reported the wrong phase")
	var result_log_before: Array = (
		(result_context.get("dialogue_log", {}) as Dictionary).get("entries", []) as Array
	).duplicate(true)
	_expect(_count_dialogue_kind(result_log_before, "choice") == 1,
		"result save omitted or duplicated the chosen option in Dialogue History")
	_expect(SaveManager.save_game(TEST_SLOT, result_context), "result save failed")
	await _free_story()
	_expect(SaveManager.load_game(TEST_SLOT), "result save could not be reloaded")
	if not await _spawn_loaded_story():
		return
	_expect(bool(_story.get("_pending_after_result")), "result resume skipped the result prose")
	_expect(int(_story.get("_pending_result_choice_index")) == 0,
		"result resume lost the selected choice")
	_expect(int(GameState.mental) == mental_after,
		"result resume applied the selected choice a second time")
	_expect(bool(GameState.flags.get("knee_day_faced", false)),
		"result resume lost the selected route flag")
	_expect((_story.get("_dialogue_log_entries") as Array) == result_log_before,
		"result resume changed or duplicated Dialogue History")

func _check_timed_choice_resume() -> void:
	await _free_story()
	GameState.start_new_game()
	if not await _spawn_story("cafe_listen_01"):
		return
	_story.set("_para_index", (_story.get("_paragraphs") as Array).size() - 1)
	_story.call("_complete_typing")
	_story.call("_show_choices")
	var timer_context: Dictionary = _story.call("build_save_resume_context")
	var remaining := int(timer_context.get("timer_remaining_msec", -1))
	_expect(str(timer_context.get("phase", "")) == "choices",
		"timed choice save reported the wrong phase")
	_expect(remaining > 0 and remaining <= 12000,
		"timed choice save lost its remaining duration")
	_expect(SaveManager.save_game(TEST_SLOT, timer_context), "timed choice save failed")
	await _free_story()
	_expect(SaveManager.load_game(TEST_SLOT), "timed choice save could not be reloaded")
	if not await _spawn_loaded_story():
		return
	_expect(bool(_story.get("_showing_choices")), "timed choice resume hid the choices")
	var deadline := int(_story.get("_choice_countdown_deadline_msec"))
	var restored_remaining := deadline - Time.get_ticks_msec()
	_expect(deadline > 0 and restored_remaining > 0,
		"timed choice resume did not restart the countdown")
	_expect(restored_remaining <= remaining + 250,
		"timed choice resume reset the countdown to its full duration")

func _check_cross_locale_resume_rewind() -> void:
	await _free_story()
	GameState.start_new_game()
	LocaleManager.set_language("en")
	if not await _spawn_story("story_prologue_dad"):
		return
	_story.call("_finish_story_scene_transition")
	var english_source_count := int(_story.call("_story_source_paragraph_count"))
	var late_source_index := 4
	var late_page := int(_story.call(
		"_first_story_page_for_source", late_source_index))
	var paragraphs: Array = _story.get("_paragraphs")
	if english_source_count <= late_source_index \
			or late_page < 0 or late_page >= paragraphs.size():
		_fail("cross-locale fixture has no late English source paragraph")
		return
	var late_text := str(paragraphs[late_page])
	var late_type_pos := clampi(
		int(roundf(float(late_text.length()) * 0.90)), 1,
		maxi(1, late_text.length() - 1))
	_story.set("_para_index", late_page)
	_story.set("_type_full", late_text)
	_story.set("_type_pos", late_type_pos)
	_story.set("_typing", true)
	(_story.get("_body_lbl") as RichTextLabel).text = late_text.substr(
		0, late_type_pos)
	var context: Dictionary = _story.call("build_save_resume_context")
	_expect(str(context.get("story_locale", "")) == "en",
		"cross-locale save omitted its source language")
	_expect(int(context.get("source_paragraph_count", 0)) == english_source_count,
		"cross-locale save omitted its source structure")
	_expect(SaveManager.save_game(TEST_SLOT, context),
		"cross-locale StoryMode save failed")
	await _free_story()

	LocaleManager.set_language("ko")
	_expect(SaveManager.load_game(TEST_SLOT),
		"cross-locale StoryMode save could not be loaded")
	if not await _spawn_loaded_story():
		return
	var korean_source_count := int(_story.call("_story_source_paragraph_count"))
	_expect(korean_source_count != english_source_count,
		"cross-locale fixture no longer exercises a paragraph mismatch")
	var restored_page := int(_story.get("_para_index"))
	_expect(int(_story.call(
		"_story_source_paragraph_index", restored_page)) == 0,
		"cross-locale load mapped into a potentially unseen paragraph")
	_expect(bool(_story.get("_typing")) and int(_story.get("_type_pos")) <= 6,
		"cross-locale load did not rewind the current prose phase")
	var rewind_entries: Array = _story.call("_dialogue_log_display_entries")
	var rewind_is_safe := rewind_entries.size() <= 1
	for raw_entry in rewind_entries:
		if not raw_entry is Dictionary \
				or int((raw_entry as Dictionary).get(
					"source_paragraph_index", -1)) != 0:
			rewind_is_safe = false
	_expect(rewind_is_safe,
		"cross-locale rewind exposed a later source in Dialogue History")

func _check_pre_dialogue_history_resume() -> void:
	await _free_story()
	GameState.start_new_game()
	if not await _spawn_story("story_knee_choice"):
		return
	_story.call("_complete_typing")
	var old_context: Dictionary = _story.call("build_save_resume_context")
	old_context.erase("dialogue_log")
	# This is the exact shape of a v4 StoryMode save created before the
	# Dialogue History payload was introduced.
	_expect(SaveManager.save_game(TEST_SLOT, old_context, {
		"label": "Pre-Dialogue-History v4 QA",
		"qa_fixture": true,
	}), "pre-Dialogue-History v4 fixture could not be written")
	await _free_story()
	_expect(SaveManager.load_game(TEST_SLOT),
		"pre-Dialogue-History v4 fixture could not be loaded")
	if not await _spawn_loaded_story():
		return
	_expect(bool(_story.get("_dialogue_log_resume_history_unavailable")),
		"old StoryMode save silently presented an empty complete history")
	_story.call("_open_dialogue_log")
	await get_tree().process_frame
	var popup := _story.get("_dialogue_log_popup") as Control
	_expect(is_instance_valid(popup),
		"Dialogue History did not open for an old StoryMode save")
	if is_instance_valid(popup):
		var notice_found := false
		for label in popup.find_children("*", "Label", true, false):
			if label is Label:
				var notice_text := (label as Label).text
				if "불러온 시점 이전" in notice_text \
						or "before the loaded point" in notice_text:
					notice_found = true
					break
		_expect(notice_found,
			"old StoryMode save did not explain that earlier history is unavailable")
		_story.call("_close_dialogue_log")
		await get_tree().process_frame

func _check_story_save_surface() -> void:
	if not is_instance_valid(_story):
		return
	_story.call("_open_audio_settings")
	await get_tree().process_frame
	_story.call("_open_story_save_load")
	await get_tree().process_frame
	var popup := _story.get("_audio_settings_popup") as Control
	_expect(is_instance_valid(popup), "StoryMode save popup did not open")
	if not is_instance_valid(popup):
		return
	var save_controls := _find_meta_buttons(popup, "story_save_control")
	var load_controls := _find_meta_buttons(popup, "story_load_control")
	_expect(save_controls.size() == 5 and load_controls.size() == 5,
		"StoryMode save page is not a five-row no-scroll surface")
	var panel := _find_panel(popup)
	if panel != null:
		_expect(panel.size.x <= 900.0 and panel.size.y <= 570.0,
			"StoryMode save panel does not fit the 960x600 contract")
	_story.call("_set_story_save_page", 1)
	await get_tree().process_frame
	popup = _story.get("_audio_settings_popup") as Control
	save_controls = _find_meta_buttons(popup, "story_save_control")
	_expect(save_controls.size() == 5, "StoryMode second page does not expose slots 6-10")

func _spawn_story(event_id: String) -> bool:
	SaveManager.clear_loaded_resume_context()
	GameState.pending_story_queue = [event_id]
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(_story):
		_fail("StoryMode fixture could not be instantiated")
		return false
	_story.call("_set_auto_mode", false, false, false)
	_story.call("_finish_story_scene_transition")
	var actual := str((_story.get("_current") as Dictionary).get("id", ""))
	if actual != event_id:
		_fail("StoryMode fixture loaded %s instead of %s" % [actual, event_id])
		return false
	return true

func _spawn_loaded_story() -> bool:
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(_story):
		_fail("loaded StoryMode fixture could not be instantiated")
		return false
	_story.call("_set_auto_mode", false, false, false)
	_story.call("_finish_story_scene_transition")
	return true

func _free_story() -> void:
	if is_instance_valid(_story):
		_story.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame
	_story = null

func _find_meta_buttons(root: Control, key: String) -> Array[Button]:
	var buttons: Array[Button] = []
	for node in root.find_children("*", "Button", true, false):
		if node is Button and bool((node as Button).get_meta(key, false)):
			buttons.append(node as Button)
	return buttons

func _find_panel(root: Control) -> PanelContainer:
	for node in root.find_children("*", "PanelContainer", true, false):
		if node is PanelContainer:
			return node as PanelContainer
	return null

func _count_dialogue_kind(entries: Array, kind: String) -> int:
	var count := 0
	for raw_entry in entries:
		if raw_entry is Dictionary \
				and str((raw_entry as Dictionary).get("kind", "")) == kind:
			count += 1
	return count

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)

func _fail(message: String) -> void:
	_failures.append(message)

func _backup_test_slots() -> void:
	for slot in [TEST_SLOT, LEGACY_SLOT, CONTRACT_SLOT]:
		var path := SaveManager.slot_path(slot)
		_backups[slot] = {
			"existed": FileAccess.file_exists(path),
			"bytes": FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) \
					else PackedByteArray(),
		}

func _backup_settings_file() -> void:
	var path := SaveManager.SETTINGS_PATH
	_settings_backup = {
		"existed": FileAccess.file_exists(path),
		"bytes": FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) \
				else PackedByteArray(),
	}

func _backup_meta_progression() -> void:
	var path := MetaProgression.META_SAVE_PATH
	_meta_file_backup = {
		"existed": FileAccess.file_exists(path),
		"bytes": FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) \
				else PackedByteArray(),
	}
	_meta_data_backup = MetaProgression.data.duplicate(true)
	var new_this_run: Variant = MetaProgression.get("_new_this_run")
	_meta_new_this_run_backup = (
		(new_this_run as Dictionary).duplicate(true)
		if new_this_run is Dictionary else {"achievements": []})

func _restore_meta_progression() -> void:
	if _meta_file_backup.is_empty():
		return
	var path := MetaProgression.META_SAVE_PATH
	if bool(_meta_file_backup.get("existed", false)):
		var file := FileAccess.open(path, FileAccess.WRITE)
		if file != null:
			file.store_buffer(_meta_file_backup.get("bytes", PackedByteArray()))
			file.close()
	elif FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	MetaProgression.data = _meta_data_backup.duplicate(true)
	MetaProgression.set(
		"_new_this_run", _meta_new_this_run_backup.duplicate(true))
	_meta_file_backup.clear()
	_meta_data_backup.clear()
	_meta_new_this_run_backup.clear()

func _restore_settings_file() -> void:
	if _settings_backup.is_empty():
		return
	var path := SaveManager.SETTINGS_PATH
	if bool(_settings_backup.get("existed", false)):
		var file := FileAccess.open(path, FileAccess.WRITE)
		if file != null:
			file.store_buffer(_settings_backup.get("bytes", PackedByteArray()))
			file.close()
	elif FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	_settings_backup.clear()

func _restore_test_slots() -> void:
	for slot in _backups:
		var path := SaveManager.slot_path(int(slot))
		var backup: Dictionary = _backups[slot]
		if bool(backup.get("existed", false)):
			var file := FileAccess.open(path, FileAccess.WRITE)
			if file != null:
				file.store_buffer(backup.get("bytes", PackedByteArray()))
				file.close()
		elif FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	_backups.clear()

func _finish() -> void:
	await _free_story()
	_restore_test_slots()
	_restore_settings_file()
	_restore_meta_progression()
	SaveManager.clear_loaded_resume_context()
	await get_tree().process_frame
	await get_tree().process_frame
	if _failures.is_empty():
		print("MANUAL_SAVE_CHECK_OK slots=10 legacy=v3/v4 prose=source_progress locale_mismatch=rewind choices=1 result_once=1 timer=1 pages=2 dialogue_history=prose/choice/result/legacy_notice meta=restored")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("MANUAL_SAVE_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)

func _exit_tree() -> void:
	_restore_test_slots()
	_restore_settings_file()
	_restore_meta_progression()
