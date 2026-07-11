extends Node

var _story: Control

func _ready() -> void:
	GameState.pending_story_queue = ["story_arrival"]
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	await get_tree().process_frame
	await get_tree().process_frame
	if str((_story.get("_current") as Dictionary).get("id", "")) != "story_arrival":
		_fail("story fixture did not load")
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

	print("STORY_PLAYBACK_CHECK_OK")
	get_tree().quit(0)

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
