extends Node
## The prologue must remain a continuous dramatic scene. System teaching belongs to the AP hub.

const STORY_MODE_PATH := "res://scenes/StoryMode.tscn"

var _failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	var story_source := FileAccess.get_file_as_string("res://scenes/StoryMode.gd")
	_expect(not story_source.contains("_maybe_show_tutorial_popup"),
		"StoryMode regained a per-choice tutorial trigger")
	_expect(not story_source.contains("var _tutorial_popup"),
		"StoryMode regained a tutorial modal surface")

	LocaleManager.set_language("ko")
	# This gate validates presentation order, not the audio mix. Keeping one-shot
	# SFX silent avoids quitting while the forced choice sting is still decoding.
	AudioManager.sfx_enabled = false
	GameState.start_new_game()
	GameState.pending_story_queue = ["story_knee_witness"]
	GameState.story_return_scene = "res://scenes/MainGame.tscn"

	var packed: PackedScene = load(STORY_MODE_PATH)
	var story := packed.instantiate()
	add_child(story)
	await get_tree().process_frame
	await get_tree().process_frame

	_expect(str(story.get("_current").get("id", "")) == "story_knee_witness",
		"prologue fixture did not open")
	await _advance_until_choices(story)
	_expect(bool(story.get("_showing_choices")),
		"forced prologue advance did not reach its button (%s)" % _story_state(story))
	var choice_box: VBoxContainer = story.get("_choice_box")
	_expect(choice_box != null and choice_box.get_child_count() == 1,
		"prologue fixture is no longer a single forced advance")

	var mental_before: int = GameState.mental
	story.call("_on_choice", 0)
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(GameState.mental == mental_before - 2, "forced result did not apply its mental cost")
	_expect(bool(story.get("_pending_after_result")), "forced result text did not begin")
	_expect(str(story.get("_type_full")).contains("아버지의 손바닥"),
		"forced result paragraph was hidden or replaced")
	_expect(not _tree_contains_text(story, "능력치와 자원"),
		"stats tutorial interrupted the prologue result")

	await _advance_until_event(story, "story_knee_choice")
	_expect(str(story.get("_current").get("id", "")) == "story_knee_choice",
		"forced result did not continue to its authored follow-up")
	_expect(not _tree_contains_text(story, "능력치와 자원"),
		"stats tutorial survived into the follow-up scene")

	var slides: Array = TutorialOverlay._get_slides("main_game")
	var dashboard_copy := ""
	for slide_value in slides:
		var slide: Dictionary = slide_value
		if str(slide.get("title", "")) == "대시보드 읽는 법":
			dashboard_copy = str(slide.get("body", ""))
	_expect(not dashboard_copy.is_empty(), "first AP tutorial lost its dashboard slide")
	_expect(dashboard_copy.contains("자산") and dashboard_copy.contains("건강") \
		and dashboard_copy.contains("정신력"),
		"first AP tutorial no longer explains the three visible resources")

	story.free()
	await get_tree().process_frame
	for player_value in AudioManager.get("_pool"):
		var player := player_value as AudioStreamPlayer
		if player != null:
			player.stop()
			player.stream = null
	BGMPlayer.stop()
	await get_tree().process_frame
	if _failures.is_empty():
		print("STORY_TUTORIAL_PLACEMENT_CHECK_OK forced_choice=1 result_visible=1 popup=0 follow_up=1 ap_tutorial=1")
		call_deferred("_quit", 0)
		return
	for failure in _failures:
		push_error("STORY_TUTORIAL_PLACEMENT_CHECK_FAIL: %s" % failure)
	call_deferred("_quit", 1)

func _quit(exit_code: int) -> void:
	await get_tree().process_frame
	get_tree().quit(exit_code)

func _advance_until_choices(story: Control) -> void:
	# The authored 1.2-second silence before the button is part of this fixture.
	for _step in range(240):
		if bool(story.get("_showing_choices")):
			return
		if bool(story.get("_typing")):
			story.call("_complete_typing")
		else:
			story.call("_on_advance")
		await get_tree().process_frame

func _advance_until_event(story: Control, event_id: String) -> void:
	for _step in range(32):
		if str(story.get("_current").get("id", "")) == event_id:
			return
		if bool(story.get("_typing")):
			story.call("_complete_typing")
		elif not bool(story.get("_showing_choices")):
			story.call("_on_advance")
		await get_tree().process_frame

func _tree_contains_text(root: Node, needle: String) -> bool:
	for node in root.find_children("*", "Label", true, false):
		if str(node.get("text")).contains(needle):
			return true
	for node in root.find_children("*", "RichTextLabel", true, false):
		if str(node.get("text")).contains(needle):
			return true
	return false

func _story_state(story: Control) -> String:
	return "id=%s typing=%s para=%s/%s hold=%s rem=%.2f transitioning=%s" % [
		str(story.get("_current").get("id", "")),
		str(story.get("_typing")),
		str(story.get("_para_index")),
		str(story.get("_paragraphs").size()),
		str(story.get("_direction_hold_active")),
		float(story.get("_direction_hold_remaining")),
		str(story.get("_transitioning")),
	]

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
