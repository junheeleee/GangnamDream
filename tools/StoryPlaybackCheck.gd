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

	print("STORY_PLAYBACK_CHECK_OK")
	get_tree().quit(0)

func _fail(message: String) -> void:
	push_error("STORY_PLAYBACK_CHECK_FAIL: %s" % message)
	get_tree().quit(1)
