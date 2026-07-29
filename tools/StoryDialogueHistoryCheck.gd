extends Node
## StoryDialogueHistoryCheck — 현재 대화 백로그의 노출·입력·저장 경계를 검증한다.

var _story: Control = null

func _ready() -> void:
	if not await _spawn_story():
		return
	if not _check_plain_text_markup_boundary():
		return
	if not await _check_partial_text_and_toggle():
		return
	if not await _reach_choices():
		return
	if not await _check_seen_only_contract():
		return
	if not await _check_timed_choice_focus_restore():
		return
	if not await _check_choice_result_and_resume_payload():
		return
	if not await _check_follow_up_and_session_boundary():
		return
	await _finish_ok()

func _spawn_story() -> bool:
	GameState.story_replay_mode = true
	GameState.pending_story_queue = ["story_prologue_dad"]
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	await get_tree().process_frame
	await get_tree().process_frame
	if str((_story.get("_current") as Dictionary).get("id", "")) \
			!= "story_prologue_dad":
		_fail("fixture did not load the phone conversation")
		return false
	_story.call("_set_auto_mode", false, false, false)
	return true

func _check_plain_text_markup_boundary() -> bool:
	if not _story.has_method("_dialogue_log_plain_text"):
		_fail("Dialogue History has no log-only plain-text sanitizer")
		return false
	var source := "[입금] 급여 [color=#d8c48a]확인[/color] [i]완료[/i]"
	var visible := str(_story.call("_dialogue_log_plain_text", source)).strip_edges()
	if visible != "[입금] 급여 확인 완료":
		_fail("literal brackets were lost or BBCode leaked: %s" % visible)
		return false
	return true

func _check_partial_text_and_toggle() -> bool:
	var log_button := _story.get("_dialogue_log_button") as Button
	if not is_instance_valid(log_button) or log_button.size.y < 40.0 \
			or int(log_button.get_meta("story_font_base_size", 0)) < 14:
		_fail("Dialogue History top button missed the 40px/14px readability floor")
		return false
	var full_text := str(_story.get("_type_full"))
	var prefix_length := mini(24, full_text.length())
	var prefix := full_text.substr(0, prefix_length)
	var expected_prefix := str(
		_story.call("_dialogue_log_plain_text", prefix)).strip_edges()
	_story.set("_type_pos", prefix_length)
	(_story.get("_body_lbl") as RichTextLabel).text = prefix
	var display_entries: Array = _story.call("_dialogue_log_display_entries")
	if display_entries.size() != 1 \
			or str((display_entries[0] as Dictionary).get("text", "")) \
				!= expected_prefix:
		_fail("partial prose was missing or exposed unseen text")
		return false
	var type_pos_before := int(_story.get("_type_pos"))
	var toggle := InputEventAction.new()
	toggle.action = "gd_secondary"
	toggle.pressed = true
	_story.call("_unhandled_input", toggle)
	await get_tree().process_frame
	var popup := _story.get("_dialogue_log_popup") as Control
	if not is_instance_valid(popup):
		_fail("secondary input did not open Dialogue History")
		return false
	var panel := popup.get_node_or_null("DialogueLogPanel") as Control
	if not is_instance_valid(panel) \
			or not get_viewport().get_visible_rect().encloses(panel.get_global_rect()):
		_fail("Dialogue History panel escaped the viewport")
		return false
	_story.call("_process", 1.5)
	if int(_story.get("_type_pos")) != type_pos_before:
		_fail("prose continued typing behind Dialogue History")
		return false
	var cancel := InputEventAction.new()
	cancel.action = "ui_cancel"
	cancel.pressed = true
	_story.call("_unhandled_input", cancel)
	if is_instance_valid(_story.get("_dialogue_log_popup")) \
			or int(_story.get("_type_pos")) != type_pos_before:
		_fail("Dialogue History did not close at the same prose position")
		return false
	await get_tree().process_frame
	return true

func _reach_choices() -> bool:
	for _step in range(80):
		if bool(_story.get("_showing_choices")):
			return true
		if bool(_story.get("_typing")):
			_story.call("_complete_typing")
		elif bool(_story.get("_direction_beat_waiting")):
			_story.call("_finish_direction_beat")
		elif bool(_story.get("_direction_hold_active")):
			_story.set("_direction_hold_remaining", 0.0)
			_story.call("_process", 0.01)
		else:
			_story.call("_on_advance")
		await get_tree().process_frame
	_fail("fixture did not reach its choices")
	return false

func _check_seen_only_contract() -> bool:
	var entries: Array = _story.get("_dialogue_log_entries")
	var prose_count := 0
	var combined := ""
	for raw_entry in entries:
		var entry := raw_entry as Dictionary
		if str(entry.get("kind", "")) == "prose":
			prose_count += 1
		combined += "\n" + str(entry.get("text", ""))
	var source_indices: Array = _story.get("_paragraph_source_indices")
	var unique_sources: Dictionary = {}
	for source_index in source_indices:
		unique_sources[int(source_index)] = true
	if prose_count != unique_sources.size():
		_fail("completed prose was duplicated or omitted")
		return false
	var choices: Array = (_story.get("_current") as Dictionary).get("choices", [])
	for choice in choices:
		var choice_text := str((choice as Dictionary).get("text", ""))
		if not choice_text.is_empty() and choice_text in combined:
			_fail("an unchosen option leaked into Dialogue History")
			return false
	return true

func _check_timed_choice_focus_restore() -> bool:
	var choice_box := _story.get("_choice_box") as VBoxContainer
	if choice_box.get_child_count() < 2:
		_fail("fixture has fewer than two visible choices")
		return false
	var second_choice := choice_box.get_child(1).get_child(0) as Button
	var timed_current: Dictionary = (_story.get("_current") as Dictionary).duplicate(true)
	timed_current["timed"] = true
	_story.set("_current", timed_current)
	_story.call("_start_story_choice_countdown", 12, 0)
	second_choice.grab_focus()
	await get_tree().process_frame
	var remaining_before := int(_story.get("_choice_countdown_deadline_msec")) \
			- Time.get_ticks_msec()
	_story.call("_open_dialogue_log")
	await get_tree().process_frame
	var paused_remaining := int(_story.get("_settings_countdown_remaining_msec"))
	if paused_remaining <= 0 \
			or int(_story.get("_choice_countdown_deadline_msec")) != 0:
		_fail("Dialogue History did not pause the timed choice")
		return false
	var scroll := _story.get("_dialogue_log_scroll") as ScrollContainer
	if get_viewport().gui_get_focus_owner() != scroll:
		_fail("Dialogue History did not expose one controller scroll focus")
		return false
	if not scroll.has_theme_stylebox_override("focus"):
		_fail("Dialogue History scroll focus has no visible style")
		return false
	var scroll_bar := scroll.get_v_scroll_bar()
	if is_instance_valid(scroll_bar):
		scroll.scroll_vertical = int(scroll_bar.max_value)
	var down := InputEventAction.new()
	down.action = "ui_down"
	down.pressed = true
	_story.call("_on_dialogue_log_scroll_input", down)
	await get_tree().process_frame
	var close_button := _story.get("_dialogue_log_close_button") as Button
	if not is_instance_valid(close_button) \
			or get_viewport().gui_get_focus_owner() != close_button:
		_fail("Dialogue History bottom Down did not focus Close")
		return false
	_story.call("_process", 2.0)
	if int(_story.get("_settings_countdown_remaining_msec")) != paused_remaining \
			or int(_story.get("_pending_result_choice_index")) != -1:
		_fail("timed choice advanced behind Dialogue History")
		return false
	_story.call("_close_dialogue_log")
	await get_tree().process_frame
	var resumed_remaining := int(_story.get("_choice_countdown_deadline_msec")) \
			- Time.get_ticks_msec()
	if abs(resumed_remaining - paused_remaining) > 250 \
			or resumed_remaining > remaining_before + 250:
		_fail("timed choice did not resume from its exact remainder")
		return false
	if get_viewport().gui_get_focus_owner() != second_choice:
		_fail("Dialogue History did not restore the same focused choice")
		return false
	if _count_named_nodes(choice_box, "StoryChoiceCountdown") != 1:
		_fail("Dialogue History resumed a missing or duplicate timer row")
		return false
	return true

func _check_choice_result_and_resume_payload() -> bool:
	var choices: Array = (_story.get("_current") as Dictionary).get("choices", [])
	if choices.size() <= 1:
		_fail("fixture has no second choice to verify")
		return false
	var selected_choice := choices[1] as Dictionary
	var expected_choice_text := str(_story.call(
		"_moral_perception_text",
		selected_choice.get("text_if_moral", {}),
		str(selected_choice.get("text", ""))))
	expected_choice_text = str(_story.call("_fmt", expected_choice_text)).strip_edges()
	_story.call("_on_choice", 1)
	var entries: Array = _story.get("_dialogue_log_entries")
	if entries.is_empty():
		_fail("chosen option was not recorded")
		return false
	var chosen := entries[-1] as Dictionary
	if str(chosen.get("kind", "")) != "choice" \
			or int(chosen.get("choice_index", -1)) != 1 \
			or str(chosen.get("text", "")).strip_edges() != expected_choice_text:
		_fail("Dialogue History did not preserve the visible chosen wording")
		return false
	var choice_count := _count_kind(entries, "choice")
	for _step in range(80):
		if _count_kind(_story.get("_dialogue_log_entries"), "result") > 0:
			break
		if bool(_story.get("_typing")):
			_story.call("_complete_typing")
		else:
			_story.call("_on_advance")
		await get_tree().process_frame
	if _count_kind(_story.get("_dialogue_log_entries"), "result") != 1:
		_fail("completed result prose was not recorded exactly once")
		return false
	if _count_kind(_story.get("_dialogue_log_entries"), "choice") != choice_count:
		_fail("result prose duplicated the chosen option")
		return false

	_story.set("_read_only_replay", false)
	var context: Dictionary = _story.call("build_save_resume_context")
	# 저장 페이로드 직렬화만 검사한다. 다음 프레임이나 사건 전환 전에 곧바로
	# 회상 모드로 돌려 MetaProgression·실제 런 상태를 절대 기록하지 않는다.
	_story.set("_read_only_replay", true)
	var log_payload: Variant = context.get("dialogue_log", {})
	if not log_payload is Dictionary \
			or int((log_payload as Dictionary).get("schema", 0)) != 1:
		_fail("manual-save resume payload omitted Dialogue History")
		return false
	var saved_entries: Array = (
		(log_payload as Dictionary).get("entries", []) as Array).duplicate(true)
	_story.set("_dialogue_log_entries", [])
	_story.call("_restore_dialogue_log_state", context)
	if (_story.get("_dialogue_log_entries") as Array) != saved_entries:
		_fail("Dialogue History did not round-trip through the resume payload")
		return false
	_story.call("_restore_dialogue_log_state", {
		"dialogue_log": {
			"schema": 1,
			"entries": [7, {}, {"kind": "future", "text": "spoiler"}],
		},
	})
	if not (_story.get("_dialogue_log_entries") as Array).is_empty():
		_fail("malformed resume history was not rejected safely")
		return false
	_story.call("_restore_dialogue_log_state", context)
	return true

func _check_follow_up_and_session_boundary() -> bool:
	if not bool(_story.get("_read_only_replay")):
		_fail("Dialogue History check left replay mode before its follow-up")
		return false
	var current_id := str((_story.get("_current") as Dictionary).get("id", ""))
	var history_before: Array = (_story.get("_dialogue_log_entries") as Array).duplicate(true)
	var serial_before := int(_story.get("_dialogue_log_event_serial"))
	for _step in range(100):
		if str((_story.get("_current") as Dictionary).get("id", "")) != current_id:
			break
		if bool(_story.get("_typing")):
			_story.call("_complete_typing")
		elif bool(_story.get("_pending_after_result")):
			_story.call("_on_advance")
		else:
			break
		await get_tree().process_frame
	if str((_story.get("_current") as Dictionary).get("id", "")) \
			!= "story_prologue_goal":
		_fail("fixture did not reach its immediate follow-up")
		return false
	var history_after: Array = _story.get("_dialogue_log_entries")
	if history_after.size() < history_before.size() \
			or int(_story.get("_dialogue_log_event_serial")) <= serial_before:
		_fail("immediate follow-up reset the current conversation history")
		return false

	_story.queue_free()
	await get_tree().process_frame
	if not await _spawn_story():
		return false
	if not (_story.get("_dialogue_log_entries") as Array).is_empty():
		_fail("a fresh StoryMode session inherited an older conversation")
		return false
	return true

func _count_kind(entries: Array, kind: String) -> int:
	var count := 0
	for raw_entry in entries:
		if raw_entry is Dictionary \
				and str((raw_entry as Dictionary).get("kind", "")) == kind:
			count += 1
	return count

func _count_named_nodes(root: Node, node_name: String) -> int:
	var count := 1 if root.name == node_name else 0
	for child in root.get_children():
		count += _count_named_nodes(child, node_name)
	return count

func _finish_ok() -> void:
	if is_instance_valid(_story):
		_story.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame
	_story = null
	print(
		"STORY_DIALOGUE_HISTORY_CHECK_OK "
		+ "seen_only=prose+choice+result no_future=1 partial=transient "
		+ "brackets=literal bbcode=stripped timer=paused focus=exact "
		+ "save=resume_schema1 replay=read_only follow_up=kept fresh=empty")
	get_tree().quit(0)

func _fail(message: String) -> void:
	push_error("STORY_DIALOGUE_HISTORY_CHECK_FAIL: %s" % message)
	get_tree().quit(1)
