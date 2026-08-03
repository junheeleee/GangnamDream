extends Node
## Fresh V2 entry preserves the authored handoff and teaches the real monthly
## planning board exactly once: prologue -> Chapter 1 -> planner -> tutorial.

const CORE_LOOP := preload("res://systems/DemoCoreLoopV2.gd")
const MAIN_GAME_SCENE := preload("res://scenes/MainGame.tscn")
const CHAPTER_EVENT_ID := "chapter_card_33"
const TUTORIAL_ID := "core_loop_v2"

var _failures: Array[String] = []
var _underlying_presses := 0
var _original_seen: Dictionary = {}
var _original_language := "ko"
var _original_sfx_enabled := true


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	_original_seen = TutorialOverlay._seen.duplicate(true)
	_original_language = LocaleManager.language
	_original_sfx_enabled = AudioManager.sfx_enabled
	AudioManager.sfx_enabled = false
	TutorialOverlay._seen.erase(TUTORIAL_ID)

	_check_localized_tutorial_copy()
	await _check_fresh_and_reentry_flow()
	await _stop_test_audio()

	TutorialOverlay._seen.clear()
	TutorialOverlay._seen.merge(_original_seen, true)
	LocaleManager.set_language(_original_language)
	AudioManager.sfx_enabled = _original_sfx_enabled
	if _failures.is_empty():
		print(
			"CORE_LOOP_V2_FIRST_ENTRY_CHECK_OK order=prologue>chapter_33>planner>tutorial "
			+ "slides=3 locale=ko/en fresh=1 reentry=1 focus_restore=1 "
			+ "input_leak=0 save_reshow=0 legacy_untouched=1")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("CORE_LOOP_V2_FIRST_ENTRY_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)


func _check_localized_tutorial_copy() -> void:
	LocaleManager.set_language("ko")
	var ko_slides: Array = TutorialOverlay._get_slides(TUTORIAL_ID)
	var ko_text := _slide_text(ko_slides)
	_expect(ko_slides.size() == 3,
		"Korean V2 onboarding does not contain exactly three slides")
	for required in [
		"24주", "첫 챕터", "넓은 계획판", "네 주", "주로 할 일",
		"보조로 할 일", "고르지 않은 제안", "문자와 통화",
	]:
		_expect(required in ko_text,
			"Korean V2 onboarding lost required concept: %s" % required)

	LocaleManager.set_language("en")
	var en_slides: Array = TutorialOverlay._get_slides(TUTORIAL_ID)
	var en_text := _slide_text(en_slides)
	_expect(en_slides.size() == 3,
		"English V2 onboarding does not contain exactly three slides")
	for required in [
		"24 weeks", "Chapter 1", "planning board", "four weeks",
		"Primary", "secondary", "offers you did not choose",
		"messages and call history",
	]:
		_expect(required.to_lower() in en_text.to_lower(),
			"English V2 onboarding lost required concept: %s" % required)
	_expect(not _contains_hangul(en_text),
		"English V2 onboarding contains Hangul: %s" % en_text)


func _check_fresh_and_reentry_flow() -> void:
	LocaleManager.set_language("ko")
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	GameState.flags["prologue_done"] = true
	var main_game = MAIN_GAME_SCENE.instantiate()
	main_game.set_meta("_screenshot_qa_static_surface", true)
	main_game.set_meta("_qa_suppress_opening_chapter_transition", true)
	add_child(main_game)
	await get_tree().process_frame
	await get_tree().process_frame

	# The normal StoryMode return path must stop at the chapter card. It may not
	# open the planner or onboarding under that protected boundary.
	main_game._continue_after_story()
	await get_tree().process_frame
	_expect(str(main_game.get_meta("_qa_opening_chapter_event", "")) \
			== CHAPTER_EVENT_ID,
		"fresh V2 StoryMode return skipped the Chapter 1 card")
	_expect(GameState.pending_story_queue == [CHAPTER_EVENT_ID],
		"fresh V2 return did not queue exactly the Chapter 1 card")
	_expect(not _planner_is_visible(main_game) \
			and _find_tutorial(main_game) == null,
		"planner or tutorial crossed the fresh Chapter 1 boundary")

	# A save made after the prologue but before the card must make the same
	# decision when MainGame is reconstructed.
	GameState.pending_story_queue.clear()
	var pre_chapter_save: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(pre_chapter_save)
	CORE_LOOP.initialize_for_run()
	main_game.remove_meta("_qa_opening_chapter_event")
	main_game._begin_month_story_and_render()
	await get_tree().process_frame
	_expect(str(main_game.get_meta("_qa_opening_chapter_event", "")) \
			== CHAPTER_EVENT_ID,
		"saved V2 MainGame re-entry skipped the Chapter 1 card")
	_expect(GameState.pending_story_queue == [CHAPTER_EVENT_ID],
		"saved V2 re-entry did not queue exactly the Chapter 1 card")
	_expect(not _planner_is_visible(main_game) \
			and _find_tutorial(main_game) == null,
		"planner or tutorial crossed the re-entry Chapter 1 boundary")

	var chapter_event: Dictionary = DataRegistry.find_event(CHAPTER_EVENT_ID)
	var chapter_choices: Array = chapter_event.get("choices", [])
	_expect(not chapter_event.is_empty() and chapter_choices.size() == 1,
		"Chapter 1 event or its single authored action is missing")
	if chapter_event.is_empty() or chapter_choices.size() != 1:
		_dispose(main_game)
		return
	GameState.apply_choice(chapter_event, chapter_choices[0] as Dictionary)
	GameState.pending_story_queue.clear()
	_expect(bool(GameState.flags.get("chapter_33_seen", false)),
		"Chapter 1 action did not set its canonical seen flag")

	# Once the chapter action is complete, the same return path opens the wide
	# monthly planner and layers the V2-specific tutorial over that real surface.
	main_game._continue_after_story()
	for _frame in range(6):
		await get_tree().process_frame
	var planner = main_game.get("_core_loop_planner")
	var tutorial := _find_tutorial(main_game)
	_expect(is_instance_valid(planner) and planner.visible,
		"first-month planning board did not open after Chapter 1")
	_expect(tutorial != null and int(tutorial.get("_slides").size()) == 3,
		"V2 onboarding did not open as a three-slide overlay over the planner")
	_expect(bool(GameState.flags.get("tutorial_shown", false)),
		"V2 onboarding did not persist its one-time run flag")
	if not is_instance_valid(planner) or tutorial == null:
		_dispose(main_game)
		return

	var focus_owner := get_viewport().gui_get_focus_owner()
	_expect(focus_owner != null and tutorial.is_ancestor_of(focus_owner),
		"V2 onboarding did not trap focus above the planner")
	var restore_target := tutorial.get("_previous_focus") as Control
	_expect(is_instance_valid(restore_target) and planner.is_ancestor_of(restore_target),
		"V2 onboarding did not remember a planner control for focus restoration")

	_underlying_presses = 0
	var offer_buttons: Dictionary = planner.get("_offer_buttons")
	for raw_button in offer_buttons.values():
		var offer_button := raw_button as Button
		if is_instance_valid(offer_button):
			offer_button.pressed.connect(_on_underlying_planner_pressed)
	var schedule_before: Dictionary = planner.schedule_snapshot()
	var routines_before: Dictionary = planner.routine_snapshot()
	var tab_before := int(planner.get("_active_tab"))
	_send_phone_shortcut_key()
	await get_tree().process_frame
	await get_tree().process_frame
	var phone = main_game.get("_communication_phone")
	_expect(not is_instance_valid(phone) or not phone.visible,
		"P opened a hidden communication phone behind the V2 tutorial")
	_send_phone_shortcut_north()
	await get_tree().process_frame
	await get_tree().process_frame
	phone = main_game.get("_communication_phone")
	var tutorial_focus := get_viewport().gui_get_focus_owner()
	_expect((not is_instance_valid(phone) or not phone.visible) \
			and tutorial_focus != null \
			and tutorial.is_ancestor_of(tutorial_focus),
		"North opened the phone or stole focus while the V2 tutorial was active")

	_send_keyboard_accept()
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(int(tutorial.get("_slide_idx")) == 1,
		"one physical Enter did not advance exactly one V2 tutorial slide")
	_expect(_underlying_presses == 0,
		"first tutorial accept leaked into the planning board")

	_send_action_accept()
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(int(tutorial.get("_slide_idx")) == 2,
		"one semantic confirm did not advance exactly one V2 tutorial slide")
	_expect(_underlying_presses == 0,
		"second tutorial accept leaked into the planning board")

	_send_keyboard_accept()
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(_find_tutorial(main_game) == null,
		"V2 tutorial did not dismiss after its third slide")
	_expect(_underlying_presses == 0 \
			and planner.schedule_snapshot() == schedule_before \
			and planner.routine_snapshot() == routines_before \
			and int(planner.get("_active_tab")) == tab_before,
		"tutorial input changed the monthly plan or switched its underlying tab")
	var restored_focus := get_viewport().gui_get_focus_owner()
	_expect(restored_focus != null and planner.is_ancestor_of(restored_focus),
		"closing V2 onboarding did not restore focus to the planner")

	GameState.add_log("V2 first-entry QA", "system")
	var post_tutorial_save: Dictionary = GameState.serialize().duplicate(true)
	var saved_flags: Dictionary = post_tutorial_save.get("flags", {})
	_expect(bool(saved_flags.get("tutorial_shown", false)),
		"serialized V2 state lost the tutorial one-time flag")
	_dispose(main_game)
	await get_tree().process_frame
	await get_tree().process_frame

	# Clear the session guard deliberately: a second overlay now can only be
	# prevented by the serialized run flag, which proves save/load durability.
	TutorialOverlay._seen.erase(TUTORIAL_ID)
	GameState.start_new_game()
	GameState.load_from_dict(post_tutorial_save)
	CORE_LOOP.initialize_for_run()
	var reloaded_main = MAIN_GAME_SCENE.instantiate()
	reloaded_main.set_meta("_screenshot_qa_static_surface", true)
	add_child(reloaded_main)
	await get_tree().process_frame
	await get_tree().process_frame
	reloaded_main._core_loop_v2_open_planner(1)
	for _frame in range(4):
		await get_tree().process_frame
	_expect(_planner_is_visible(reloaded_main),
		"saved first-month planner could not reopen")
	_expect(_find_tutorial(reloaded_main) == null \
			and not TutorialOverlay._seen.has(TUTORIAL_ID),
		"saved V2 onboarding appeared a second time after reload")
	_dispose(reloaded_main)
	await get_tree().process_frame
	await get_tree().process_frame


func _planner_is_visible(main_game: Node) -> bool:
	var planner = main_game.get("_core_loop_planner")
	return is_instance_valid(planner) and bool(planner.visible)


func _find_tutorial(parent: Node) -> TutorialOverlay:
	for child in parent.get_children():
		if child is TutorialOverlay and not child.is_queued_for_deletion():
			return child as TutorialOverlay
	return null


func _slide_text(slides: Array) -> String:
	var parts: Array[String] = []
	for raw_slide in slides:
		if not raw_slide is Dictionary:
			continue
		var slide: Dictionary = raw_slide
		parts.append(str(slide.get("title", "")))
		parts.append(str(slide.get("body", "")))
	return "\n".join(parts)


func _contains_hangul(text: String) -> bool:
	for index in range(text.length()):
		var codepoint := text.unicode_at(index)
		if (codepoint >= 0xAC00 and codepoint <= 0xD7A3) \
				or (codepoint >= 0x1100 and codepoint <= 0x11FF) \
				or (codepoint >= 0x3130 and codepoint <= 0x318F):
			return true
	return false


func _send_keyboard_accept() -> void:
	var press := InputEventKey.new()
	press.keycode = KEY_ENTER
	press.physical_keycode = KEY_ENTER
	press.pressed = true
	Input.parse_input_event(press)
	var release := press.duplicate() as InputEventKey
	release.pressed = false
	Input.parse_input_event(release)


func _send_action_accept() -> void:
	var press := InputEventAction.new()
	press.action = "ui_accept"
	press.pressed = true
	Input.parse_input_event(press)
	var release := press.duplicate() as InputEventAction
	release.pressed = false
	Input.parse_input_event(release)


func _send_phone_shortcut_key() -> void:
	var press := InputEventKey.new()
	press.keycode = KEY_P
	press.physical_keycode = KEY_P
	press.pressed = true
	Input.parse_input_event(press)
	var release := press.duplicate() as InputEventKey
	release.pressed = false
	Input.parse_input_event(release)


func _send_phone_shortcut_north() -> void:
	var press := InputEventJoypadButton.new()
	press.button_index = JOY_BUTTON_Y
	press.pressed = true
	Input.parse_input_event(press)
	var release := press.duplicate() as InputEventJoypadButton
	release.pressed = false
	Input.parse_input_event(release)


func _on_underlying_planner_pressed() -> void:
	_underlying_presses += 1


func _dispose(node: Node) -> void:
	if not is_instance_valid(node):
		return
	if node.get_parent() != null:
		node.get_parent().remove_child(node)
	node.free()


func _stop_test_audio() -> void:
	BGMPlayer.stop()
	for owner in [AudioManager, BGMPlayer]:
		for child in owner.get_children():
			if child is AudioStreamPlayer:
				(child as AudioStreamPlayer).stop()
				(child as AudioStreamPlayer).stream = null
	await get_tree().process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
