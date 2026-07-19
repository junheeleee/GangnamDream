extends Node

var _story: Control

func _ready() -> void:
	if not await _check_accept_hold_boundary():
		return
	_story.queue_free()
	await get_tree().process_frame
	if not await _spawn_story_fixture():
		return

	_story.call("_set_auto_mode", true, false)
	for _step in range(12):
		if bool(_story.get("_showing_choices")):
			break
		if bool(_story.get("_typing")):
			_story.call("_complete_typing")
		_story.set("_auto_wait", 0.0)
		await get_tree().process_frame
		await get_tree().process_frame

	if not bool(_story.get("_showing_choices")):
		_fail("auto playback did not stop at the choice")
		return
	var event_id := str((_story.get("_current") as Dictionary).get("id", ""))
	await get_tree().create_timer(0.12).timeout
	if not bool(_story.get("_showing_choices")) or str((_story.get("_current") as Dictionary).get("id", "")) != event_id:
		_fail("auto playback selected or skipped a choice")
		return

	var toggle := InputEventKey.new()
	toggle.keycode = KEY_A
	toggle.pressed = true
	Input.parse_input_event(toggle)
	await get_tree().process_frame
	if bool(_story.get("_auto_mode")):
		_fail("keyboard auto toggle did not turn playback off")
		return
	if not _check_covered_story_handoff():
		return

	print("STORY_PLAYBACK_CHECK_OK hold=prose_only choice_commit=0")
	get_tree().quit(0)

func _spawn_story_fixture() -> bool:
	GameState.pending_story_queue = ["story_arrival"]
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	await get_tree().process_frame
	await get_tree().process_frame
	if str((_story.get("_current") as Dictionary).get("id", "")) != "story_arrival":
		_fail("story fixture did not load")
		return false
	_story.call("_set_auto_mode", false, false)
	return true

func _check_accept_hold_boundary() -> bool:
	if not await _spawn_story_fixture():
		return false
	var paragraphs: Array = _story.get("_paragraphs")
	if paragraphs.size() < 3:
		_fail("story fixture needs at least three prose paragraphs")
		return false
	_story.call("_complete_typing")
	var event_id := str((_story.get("_current") as Dictionary).get("id", ""))
	await _send_accept_action(true)
	for _step in range(16):
		_story.call("_process", 0.20)
		if not bool(_story.get("_advance_hold_active")):
			break
	var final_index := paragraphs.size() - 1
	if int(_story.get("_para_index")) != final_index or bool(_story.get("_typing")):
		_fail("one held accept did not flow to the final prose paragraph")
		return false
	if bool(_story.get("_showing_choices")) \
			or str((_story.get("_current") as Dictionary).get("id", "")) != event_id:
		_fail("held accept crossed the prose boundary")
		return false
	await _send_accept_action(false)
	await _send_accept_action(true)
	if not bool(_story.get("_showing_choices")):
		_fail("a fresh accept did not open the choice after held prose")
		return false
	_story.call("_process", 1.0)
	if not bool(_story.get("_showing_choices")) \
			or str((_story.get("_current") as Dictionary).get("id", "")) != event_id:
		_fail("held prose input selected a choice or crossed events")
		return false
	await _send_accept_action(false)
	return true

func _send_accept_action(pressed: bool) -> void:
	var action := InputEventAction.new()
	action.action = "ui_accept"
	action.pressed = pressed
	Input.parse_input_event(action)
	await get_tree().process_frame

func _check_covered_story_handoff() -> bool:
	GameState.turn = 3
	GameState.housing = "gosiwon"
	GameState.flags = {
		"prologue_done": true,
		"chapter_33_seen": true,
		"arc_intro_meal_seen": true,
	}
	GameState.pending_story_queue.clear()
	var active_tween := SceneTransition.get("_tween") as Tween
	if active_tween != null:
		active_tween.kill()
	SceneTransition.set("_tween", null)
	SceneTransition.call("_set_transition_alpha", 1.0)

	var main_script := load("res://scenes/MainGame.gd") as GDScript
	var main: Node = main_script.new()
	main.call("_continue_after_story")
	var queued_id := str(GameState.pending_story_queue[0]) if not GameState.pending_story_queue.is_empty() else ""
	if queued_id != "arc_intro_02_dad_call":
		main.free()
		_fail("story return did not queue the next due arc behind the cover")
		return false
	if SceneTransition.get("_tween") != null or float(SceneTransition.get("_transition_alpha")) < 0.99:
		main.free()
		_fail("story return began revealing MainGame before the next arc")
		return false
	main.free()
	return true

func _fail(message: String) -> void:
	push_error("STORY_PLAYBACK_CHECK_FAIL: %s" % message)
	get_tree().quit(1)
