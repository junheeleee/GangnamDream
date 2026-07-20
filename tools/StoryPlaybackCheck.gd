extends Node

const DIRECT_CONTINUE_EVENTS := [
	"story_flashforward",
	"story_arrival",
	"story_knee_door",
	"story_knee_witness",
	"story_last_payment_wait",
	"story_last_payment_exit",
	"story_pressure",
]
const DEMO_SAME_LOCATION_EDGES := [
	["story_knee_door", "story_knee_witness"],
	["story_knee_witness", "story_knee_choice"],
	["story_last_payment_wait", "story_last_payment_word"],
	["story_last_payment_exit", "story_prologue_dad"],
]

var _story: Control

func _ready() -> void:
	if not await _check_default_auto_contract():
		return
	await _free_story_fixture()
	if not await _check_accept_hold_boundary():
		return
	await _free_story_fixture()
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
	await _free_story_fixture()
	if not await _check_direct_continue_contract():
		return
	await _free_story_fixture()
	if not await _check_same_location_handoff():
		return
	await _free_story_fixture()
	if not _check_covered_story_handoff():
		return

	print(
		"STORY_PLAYBACK_CHECK_OK auto=story_default replay=manual direct=%d same_location=%d " % [
			DIRECT_CONTINUE_EVENTS.size(), DEMO_SAME_LOCATION_EDGES.size()
		]
		+ "direct_commit=1 hints=ko_en_xbox_ps_nintendo choice_commit=0"
	)
	get_tree().quit(0)

func _spawn_story_fixture(
		event_id: String = "story_prologue_dad",
		disable_auto: bool = true,
		replay_mode: bool = false) -> bool:
	GameState.story_replay_mode = replay_mode
	GameState.pending_story_queue = [event_id]
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	await get_tree().process_frame
	await get_tree().process_frame
	if str((_story.get("_current") as Dictionary).get("id", "")) != event_id:
		_fail("story fixture did not load %s" % event_id)
		return false
	if disable_auto:
		_story.call("_set_auto_mode", false, false, false)
	return true

func _free_story_fixture() -> void:
	if is_instance_valid(_story):
		_story.queue_free()
		await get_tree().process_frame
	_story = null

func _check_default_auto_contract() -> bool:
	var original_replay_mode := GameState.story_replay_mode
	if not await _spawn_story_fixture("story_prologue_dad", false, false):
		return false
	if not bool(_story.get("_auto_mode")):
		_fail("normal story playback did not default to auto")
		return false
	await _free_story_fixture()

	if not await _spawn_story_fixture("story_prologue_dad", false, true):
		return false
	if bool(_story.get("_auto_mode")):
		_fail("read-only replay did not default to manual playback")
		return false
	await _free_story_fixture()

	if not await _spawn_story_fixture("story_prologue_dad", false, false):
		return false
	if not bool(_story.get("_auto_mode")):
		_fail("read-only replay overwrote the normal-session auto preference")
		return false
	GameState.story_replay_mode = original_replay_mode
	return true

func _check_accept_hold_boundary() -> bool:
	var original_language := LocaleManager.language
	LocaleManager.set_language("en")
	ControllerHints.force_brand_for_qa(ControllerHints.Brand.XBOX)
	if not await _spawn_story_fixture():
		return false
	var paragraphs: Array = _story.get("_paragraphs")
	if paragraphs.size() < 3:
		_fail("story fixture needs at least three prose paragraphs")
		return false
	_story.call("_complete_typing")
	var continue_hint := _story.get("_continue_hint") as Label
	if not is_instance_valid(continue_hint):
		_fail("story continue hint is missing")
		return false
	for hint_fixture in [
			[ControllerHints.Brand.XBOX, "A"],
			[ControllerHints.Brand.PLAYSTATION, "✕"],
			[ControllerHints.Brand.NINTENDO, "B"],
	]:
		ControllerHints.force_brand_for_qa(hint_fixture[0])
		var south_label := str(hint_fixture[1])
		LocaleManager.set_language("en")
		_story.call("_refresh_continue_hint_text")
		if continue_hint.text != "[%s] Advance · Hold to read" % south_label:
			_fail("English gamepad hold hint is missing or mislabeled for %s" % south_label)
			return false
		if not _hint_fits(continue_hint):
			_fail("English gamepad hold hint overflows for %s" % south_label)
			return false
		LocaleManager.set_language("ko")
		_story.call("_refresh_continue_hint_text")
		if continue_hint.text != "[%s] 진행 · 길게 읽기" % south_label:
			_fail("Korean gamepad hold hint is missing or mislabeled for %s" % south_label)
			return false
		if not _hint_fits(continue_hint):
			_fail("Korean gamepad hold hint overflows for %s" % south_label)
			return false
	ControllerHints.force_brand_for_qa(ControllerHints.Brand.XBOX)
	LocaleManager.set_language("en")
	_story.call("_refresh_continue_hint_text")
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
	_story.call("_refresh_continue_hint_text")
	if continue_hint.text != "[A] Advance":
		_fail("final paragraph still advertises a hold that cannot cross the boundary")
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
	ControllerHints.clear_qa_override()
	LocaleManager.set_language(original_language)
	return true

func _check_direct_continue_contract() -> bool:
	var original_language := LocaleManager.language
	var original_intelligence: int = int(GameState.intelligence)
	var had_unlock_flag := GameState.flags.has("story_job_unlocked")
	var unlock_flag_value: Variant = GameState.flags.get("story_job_unlocked", null)
	LocaleManager.set_language("en")
	ControllerHints.force_brand_for_qa(ControllerHints.Brand.XBOX)
	if not await _spawn_story_fixture("story_pressure"):
		return false

	var continue_hint := _story.get("_continue_hint") as Label
	for language in ["ko", "en"]:
		LocaleManager.set_language(language)
		for event_id in DIRECT_CONTINUE_EVENTS:
			var localized: Dictionary = DataRegistry.find_event(event_id)
			if localized.is_empty():
				_fail("direct-continue event is missing: %s" % event_id)
				return false
			_set_direct_fixture_state(localized)
			for hint_fixture in [
				[ControllerHints.Brand.XBOX, "A"],
				[ControllerHints.Brand.PLAYSTATION, "✕"],
				[ControllerHints.Brand.NINTENDO, "B"],
			]:
				ControllerHints.force_brand_for_qa(hint_fixture[0])
				_story.call("_refresh_continue_hint_text")
				var action_text := str(_story.call("_direct_continue_action_text"))
				var expected := "[%s] %s" % [hint_fixture[1], action_text]
				if continue_hint.text != expected:
					_fail("direct action hint drifted for %s/%s" % [language, event_id])
					return false
				if not _hint_fits(continue_hint):
					_fail("direct action hint overflows for %s/%s" % [language, event_id])
					return false

	LocaleManager.set_language("en")
	ControllerHints.force_brand_for_qa(ControllerHints.Brand.XBOX)
	_set_direct_fixture_state(DataRegistry.find_event("story_flashforward"))
	_story.call("_set_auto_mode", true, false, false)
	_story.call("_complete_typing")
	if not bool(_story.get("_direction_hold_active")):
		_fail("cinematic direct action did not begin its authored hold")
		return false
	_story.call("_process", 2.1)
	if float(_story.get("_auto_wait")) < 0.0:
		_fail("cinematic hold did not return a direct action to auto playback")
		return false

	_set_direct_fixture_state(DataRegistry.find_event("story_pressure"))
	_story.call("_set_auto_mode", true, false, false)
	_story.call("_refresh_continue_hint_text")
	if continue_hint.text != "[A] Open a job app. Survival comes first.":
		_fail("English direct action does not state the committed action")
		return false

	_story.call("_arm_auto_advance", "final")
	_story.set("_auto_wait", 0.0)
	_story.call("_process", 0.01)
	if bool(_story.get("_showing_choices")) or not bool(_story.get("_pending_after_result")):
		_fail("auto direct action opened a fake choice rail or skipped its result")
		return false
	if GameState.intelligence != original_intelligence + 2 \
			or not bool(GameState.flags.get("story_job_unlocked", false)):
		_fail("auto direct action did not apply its effects and flag exactly once")
		return false
	for _step in range(4):
		_story.call("_process", 0.40)
	if GameState.intelligence != original_intelligence + 2:
		_fail("held direct action applied its effect more than once")
		return false

	GameState.intelligence = original_intelligence
	if had_unlock_flag:
		GameState.flags["story_job_unlocked"] = unlock_flag_value
	else:
		GameState.flags.erase("story_job_unlocked")
	ControllerHints.clear_qa_override()
	LocaleManager.set_language(original_language)
	return true

func _set_direct_fixture_state(event: Dictionary) -> void:
	_story.set("_current", event)
	_story.set("_paragraphs", ["final"])
	_story.set("_para_index", 0)
	_story.set("_type_full", "final")
	_story.set("_type_pos", 5)
	_story.set("_typing", false)
	_story.set("_pending_after_result", false)
	_story.set("_showing_choices", false)
	_story.set("_is_chapter_card", false)
	_story.set("_direction_hold_active", false)
	_story.set("_direction_hold_consumed", false)
	_story.set("_direction_hold_remaining", 0.0)
	_story.set("_direction", event.get("direction", {}))

func _check_same_location_handoff() -> bool:
	for edge in DEMO_SAME_LOCATION_EDGES:
		var contract := DataRegistry.get_story_transition(str(edge[0]), str(edge[1]))
		if str(contract.get("mode", "")) != "same_location":
			_fail("same-location transition contract is missing: %s->%s" % edge)
			return false

	if not await _spawn_story_fixture("story_knee_door"):
		return false
	var paragraphs: Array = _story.get("_paragraphs")
	_story.set("_para_index", paragraphs.size() - 1)
	_story.call("_start_typing", str(paragraphs[-1]))
	_story.call("_complete_typing")
	_story.call("_on_advance")
	if not bool(_story.get("_pending_after_result")):
		_fail("same-location source did not expose its result before handoff")
		return false
	var result_paragraphs: Array = _story.get("_paragraphs")
	_story.set("_para_index", result_paragraphs.size() - 1)
	_story.call("_start_typing", str(result_paragraphs[-1]))
	_story.call("_complete_typing")
	var ink_tween := _story.get("_story_ink_transition_tween") as Tween
	if ink_tween != null:
		ink_tween.kill()
	_story.set("_story_ink_transition_tween", null)
	var ink_layer := _story.get("_story_ink_transition_layer") as Control
	ink_layer.visible = false
	_story.call("_on_advance")
	if str((_story.get("_current") as Dictionary).get("id", "")) != "story_knee_witness":
		_fail("same-location follow-up did not load")
		return false
	if str(_story.get("_current_transition_mode")) != "same_location":
		_fail("same-location mode was not consumed by the follow-up")
		return false
	if _story.get("_story_ink_transition_tween") != null or ink_layer.visible:
		_fail("same-location follow-up replayed the full scene ink transition")
		return false
	var text_panel := _story.get("_text_panel") as Control
	if not is_equal_approx(text_panel.modulate.a, 1.0):
		_fail("same-location follow-up replayed the text-panel fade")
		return false
	return true

func _hint_fits(hint: Label) -> bool:
	var font := hint.get_theme_font("font")
	var font_size := hint.get_theme_font_size("font_size")
	var text_width := font.get_string_size(
		hint.text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
	return text_width <= hint.size.x

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
