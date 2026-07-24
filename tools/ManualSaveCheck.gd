extends Node
## ManualSaveCheck — 10슬롯과 StoryMode 중간 재개 계약을 실제 런타임으로 검증한다.

const TEST_SLOT := 1
const LEGACY_SLOT := 9
const CONTRACT_SLOT := 10

var _story: Control = null
var _failures: Array[String] = []
var _backups: Dictionary = {}

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	_backup_test_slots()
	GameState.start_new_game()
	_check_slot_and_legacy_contract()
	if not _failures.is_empty():
		await _finish()
		return
	await _check_prose_resume()
	await _check_choice_and_result_resume()
	await _check_timed_choice_resume()
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
	_story.call("_complete_typing")
	_story.call("_on_advance")
	_story.set("_type_pos", 7)
	(_story.get("_body_lbl") as RichTextLabel).text = str(
		_story.get("_type_full")).substr(0, 7)
	var context: Dictionary = _story.call("build_save_resume_context")
	_expect(str(context.get("phase", "")) == "prose", "prose save reported the wrong phase")
	_expect(int(context.get("paragraph_index", -1)) == 1, "prose save lost the paragraph index")
	_expect(SaveManager.save_game(TEST_SLOT, context), "prose save failed")
	await _free_story()
	_expect(SaveManager.load_game(TEST_SLOT), "prose save could not be reloaded")
	if not await _spawn_loaded_story():
		return
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) == "story_knee_choice",
		"prose resume loaded the wrong event")
	_expect(int(_story.get("_para_index")) == 1, "prose resume loaded the wrong paragraph")
	_expect(bool(_story.get("_typing")), "partially typed prose did not resume typing")
	_expect(int(_story.get("_type_pos")) == 7, "partially typed prose lost its character position")

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
	_expect(SaveManager.save_game(TEST_SLOT, choice_context), "choice save failed")
	await _free_story()
	_expect(SaveManager.load_game(TEST_SLOT), "choice save could not be reloaded")
	if not await _spawn_loaded_story():
		return
	_expect(bool(_story.get("_showing_choices")), "choice resume did not restore the choice rail")

	var mental_before := int(GameState.mental)
	_story.call("_on_choice", 0)
	var mental_after := int(GameState.mental)
	_expect(mental_after == mental_before - 2, "fixture choice did not apply its effect once")
	var result_context: Dictionary = _story.call("build_save_resume_context")
	_expect(str(result_context.get("phase", "")) == "result",
		"result save reported the wrong phase")
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
	SaveManager.clear_loaded_resume_context()
	await get_tree().process_frame
	await get_tree().process_frame
	if _failures.is_empty():
		print("MANUAL_SAVE_CHECK_OK slots=10 legacy=v3 prose=1 choices=1 result_once=1 timer=1 pages=2")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("MANUAL_SAVE_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)

func _exit_tree() -> void:
	_restore_test_slots()
