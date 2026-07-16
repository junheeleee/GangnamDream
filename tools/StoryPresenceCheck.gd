extends Node
## StoryPresenceCheck - remote dialogue must not read as physical co-presence.

var _story: Node = null
var _original_language := "en"

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	_original_language = LocaleManager.language
	GameState.start_new_game()
	GameState.flags["prologue_done"] = true

	LocaleManager.language = "ko"
	DataRegistry.reload()
	if not await _check_remote_phone_ko():
		return
	if not await _check_local_message_ko():
		return
	if not await _check_memory_inset_ko():
		return
	if not await _check_in_person_reset():
		return

	LocaleManager.language = "en"
	DataRegistry.reload()
	if not await _check_remote_phone_en():
		return

	LocaleManager.language = _original_language
	DataRegistry.reload()
	print("STORY_PRESENCE_CHECK_OK phone=remote message=local memory=inset in_person=full en=clean")
	get_tree().quit(0)

func _check_remote_phone_ko() -> bool:
	_story = await _boot_story("story_prologue_dad")
	if _story == null:
		return false
	var presentation: Dictionary = _story.get("_current_presentation")
	var frame := _story.get("_portrait_frame") as Control
	var badge := _story.get("_communication_badge") as Control
	var badge_label := _story.get("_communication_label") as Label
	var name_label := _story.get("_name_tag") as Label
	var background := _story.get("_bg_img") as TextureRect
	if str(presentation.get("channel", "")) != "phone":
		return _fail("prologue father channel is not phone")
	if str(presentation.get("scene_location", "")) != "street_rainy_bus_stop_wallet":
		return _fail("prologue father call left the rainy bus stop in its presentation contract")
	var expected_background := ImageRegistry.get_background("street_rainy_bus_stop_wallet")
	if not is_instance_valid(background) or background.texture == null \
			or background.texture.resource_path != expected_background:
		return _fail("prologue father call rendered outside the rainy bus stop")
	if BGMPlayer._current_ambience_key != "rain":
		return _fail("prologue father call lost its rain ambience")
	if not bool(_story.get("_portrait_remote_inset")):
		return _fail("father portrait still uses in-person full-body placement")
	if not is_instance_valid(frame) or not frame.visible or frame.size.x > 330.0 or frame.size.y > 410.0:
		return _fail("remote father inset geometry is not compact")
	if not is_instance_valid(badge) or not badge.visible or badge_label.text != "통화 중":
		return _fail("Korean voice-call badge is missing")
	if "전화 너머" not in name_label.text:
		return _fail("remote father name tag lacks channel context")
	await _remove_story()
	return true

func _check_local_message_ko() -> bool:
	_story = await _boot_story("arc_father_02_signal")
	if _story == null:
		return false
	var badge := _story.get("_communication_badge") as Control
	var badge_label := _story.get("_communication_label") as Label
	if bool(_story.get("_portrait_remote_inset")):
		return _fail("local player portrait was incorrectly framed as the remote sender")
	if not is_instance_valid(badge) or not badge.visible or badge_label.text != "메시지":
		return _fail("message channel badge is missing")
	await _remove_story()
	return true

func _check_memory_inset_ko() -> bool:
	_story = await _boot_story("callback_sangchul_personal_echo")
	if _story == null:
		return false
	var badge_label := _story.get("_communication_label") as Label
	if not bool(_story.get("_portrait_remote_inset")) or badge_label.text != "기억":
		return _fail("remembered Sangchul is not separated from physical presence")
	if not is_equal_approx(float(_story.get("_portrait_target_alpha")), 0.80):
		return _fail("memory portrait does not use the quieter opacity")
	await _remove_story()
	return true

func _check_in_person_reset() -> bool:
	_story = await _boot_story("arc_sangchul_confrontation")
	if _story == null:
		return false
	var frame := _story.get("_portrait_frame") as Control
	var badge := _story.get("_communication_badge") as Control
	if bool(_story.get("_portrait_remote_inset")):
		return _fail("in-person Sangchul inherited the remote inset")
	if not is_instance_valid(frame) or frame.offset_left != _story.PORTRAIT_OFFSET_LEFT \
			or frame.offset_right != _story.PORTRAIT_OFFSET_RIGHT:
		return _fail("in-person portrait did not restore its full placement")
	if not frame.visible:
		return _fail("in-person portrait baseline is not visible")
	if is_instance_valid(badge) and badge.visible:
		return _fail("in-person scene still shows a communication badge")
	await _remove_story()
	return true

func _check_remote_phone_en() -> bool:
	_story = await _boot_story("arc_father_quiet_call")
	if _story == null:
		return false
	var badge_label := _story.get("_communication_label") as Label
	var name_label := _story.get("_name_tag") as Label
	if badge_label.text != "VOICE CALL" or "Voice call" not in name_label.text:
		return _fail("English remote-call labels are incomplete")
	if _contains_hangul(badge_label.text + name_label.text):
		return _fail("Hangul leaked into the English communication surface")
	await _remove_story()
	return true

func _boot_story(event_id: String) -> Node:
	GameState.pending_story_queue = [event_id]
	var packed := load("res://scenes/StoryMode.tscn") as PackedScene
	var story := packed.instantiate()
	get_tree().root.add_child(story)
	await get_tree().process_frame
	await get_tree().create_timer(0.30).timeout
	if not is_instance_valid(story):
		_fail("StoryMode failed to boot for %s" % event_id)
		return null
	return story

func _remove_story() -> void:
	if is_instance_valid(_story):
		_story.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	_story = null
	GameState.pending_story_queue.clear()

func _contains_hangul(text: String) -> bool:
	for index in range(text.length()):
		var codepoint := text.unicode_at(index)
		if (codepoint >= 0xAC00 and codepoint <= 0xD7A3) \
				or (codepoint >= 0x3130 and codepoint <= 0x318F) \
				or (codepoint >= 0x1100 and codepoint <= 0x11FF):
			return true
	return false

func _fail(message: String) -> bool:
	push_error("STORY_PRESENCE_CHECK_FAIL " + message)
	LocaleManager.language = _original_language
	DataRegistry.reload()
	get_tree().quit(1)
	return false
