extends Node
## StoryAudioSettingsCheck — 이벤트 중 장면 설정의 접근성·현지화·연속성 계약.

var _story: Control
var _original_bgm: float
var _original_sfx: float
var _original_reduce_motion: bool
var _original_text_size: String
var _original_text_speed: String
var _original_language: String

func _ready() -> void:
	_original_bgm = AudioManager.bgm_volume
	_original_sfx = AudioManager.master_volume
	_original_reduce_motion = bool(SaveManager.get_setting("reduce_motion", false))
	_original_text_size = str(SaveManager.get_setting("story_text_size", "standard"))
	_original_text_speed = str(SaveManager.get_setting("story_text_speed", "standard"))
	_original_language = LocaleManager.language
	LocaleManager.set_language("en")
	SaveManager.set_setting("story_text_size", "standard")
	SaveManager.set_setting("story_text_speed", "standard")
	GameState.start_new_game()
	GameState.pending_story_queue = ["arc_daeun_wedding_walk"]
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	await get_tree().process_frame
	await get_tree().process_frame
	var current: Dictionary = _story.get("_current")
	if str(current.get("id", "")) != "arc_daeun_wedding_walk":
		_fail("wedding story fixture did not load")
		return

	var cg_id := str(_story.get("_event_cg_id"))
	BGMPlayer.play_scene_paragraph_music(current, cg_id, 0)
	await get_tree().create_timer(0.18).timeout
	if not BGMPlayer._player_a.playing:
		_fail("fixture music did not start")
		return
	var music_stream := BGMPlayer._player_a.stream
	var music_pos := BGMPlayer._player_a.get_playback_position()
	var ambience_stream := BGMPlayer._ambience_player.stream
	var ambience_pos := BGMPlayer._ambience_player.get_playback_position()
	var paragraph_before := int(_story.get("_para_index"))
	var type_full_before := str(_story.get("_type_full"))
	var type_ratio_before := float(_story.get("_type_pos")) / float(maxi(1, type_full_before.length()))
	var money_before: float = float(GameState.money)
	var health_before: int = int(GameState.health)
	var mental_before: int = int(GameState.mental)
	var flags_before := GameState.flags.duplicate(true)

	var menu_event := InputEventAction.new()
	menu_event.action = "gd_menu"
	menu_event.pressed = true
	_story.call("_unhandled_input", menu_event)
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(_story.get("_audio_settings_popup")):
		_fail("dedicated menu input did not open scene settings")
		return
	var bgm_slider := _story.get("_audio_bgm_slider") as HSlider
	var sfx_slider := _story.get("_audio_sfx_slider") as HSlider
	var motion_toggle := _story.get("_audio_reduce_motion_toggle") as CheckButton
	var text_buttons: Dictionary = _story.get("_story_text_size_buttons")
	var speed_buttons: Dictionary = _story.get("_story_text_speed_buttons")
	var language_buttons: Dictionary = _story.get("_story_language_buttons")
	var standard_button := text_buttons.get("standard") as Button
	var large_button := text_buttons.get("large") as Button
	var slow_speed_button := speed_buttons.get("slow") as Button
	var standard_speed_button := speed_buttons.get("standard") as Button
	var fast_speed_button := speed_buttons.get("fast") as Button
	var korean_button := language_buttons.get("ko") as Button
	if not is_instance_valid(bgm_slider) or not is_instance_valid(sfx_slider) \
			or not is_instance_valid(motion_toggle) or not is_instance_valid(standard_button) \
			or not is_instance_valid(large_button) or not is_instance_valid(slow_speed_button) \
			or not is_instance_valid(standard_speed_button) \
			or not is_instance_valid(fast_speed_button) \
			or not is_instance_valid(korean_button):
		_fail("scene settings controls are incomplete")
		return
	if get_viewport().gui_get_focus_owner() != standard_button:
		_fail("scene settings did not focus the active text-size segment")
		return
	if standard_button.focus_neighbor_bottom != standard_speed_button.get_path() \
			or standard_speed_button.focus_neighbor_top != standard_button.get_path():
		_fail("text-size and text-speed controller rows are not connected")
		return
	var settings_panel := (_story.get("_audio_settings_popup") as Control).get_child(0) as Control
	var panel_rect := settings_panel.get_global_rect()
	# StoryMode uses a fixed 1280x800 design canvas that Godot scales into the
	# physical window, so global control coordinates must be checked in that
	# canvas rather than against the post-stretch window pixel count.
	var layout_size := _story.size
	if panel_rect.position.x < -0.5 or panel_rect.position.y < -0.5 \
			or panel_rect.end.x > layout_size.x + 0.5 \
			or panel_rect.end.y > layout_size.y + 0.5:
		_fail("scene settings rect %s overflowed layout %s" % [
			str(panel_rect), str(layout_size)])
		return
	var settings_column := settings_panel.get_child(0) as Control
	if settings_column.get_combined_minimum_size().y > settings_column.size.y + 0.5:
		_fail("scene settings content overflowed its 960x600-scaled panel")
		return

	var direction_before: Dictionary = (_story.get("_direction") as Dictionary).duplicate(true)
	_story.set("_direction", {})
	var normal_interval := float(_story.call("_direction_type_interval"))
	slow_speed_button.button_pressed = true
	slow_speed_button.emit_signal("pressed")
	await get_tree().process_frame
	var slow_interval := float(_story.call("_direction_type_interval"))
	if str(SaveManager.get_setting("story_text_speed", "")) != "slow" \
			or absf((slow_interval / normal_interval) - 1.65) > 0.02:
		_fail("slow text speed did not save or apply immediately")
		return
	fast_speed_button.button_pressed = true
	fast_speed_button.emit_signal("pressed")
	await get_tree().process_frame
	var fast_interval := float(_story.call("_direction_type_interval"))
	if str(SaveManager.get_setting("story_text_speed", "")) != "fast" \
			or absf((fast_interval / normal_interval) - 0.50) > 0.02:
		_fail("fast text speed did not save or apply immediately")
		return
	_story.set("_direction", {"pace": "slow"})
	var authored_slow_interval := float(_story.call("_direction_type_interval"))
	if absf((authored_slow_interval / fast_interval) - (1.0 / 0.60)) > 0.02:
		_fail("authored slow pacing did not remain relative to user speed")
		return
	_story.set("_direction", {})
	var auto_sample := (
		"one two three four five six seven eight nine ten ").repeat(3)
	_story.call("_set_story_text_speed", "standard")
	normal_interval = float(_story.call("_direction_type_interval"))
	var normal_auto_total := (
		float(auto_sample.length()) * normal_interval
		+ float(_story.call("_auto_reading_delay", auto_sample)))
	_story.call("_set_story_text_speed", "fast")
	fast_interval = float(_story.call("_direction_type_interval"))
	var fast_auto_total := (
		float(auto_sample.length()) * fast_interval
		+ float(_story.call("_auto_reading_delay", auto_sample)))
	if absf(normal_auto_total - fast_auto_total) > 0.08:
		_fail("AUTO reading duration double-counted the text-speed setting")
		return
	_story.set("_direction", direction_before)

	bgm_slider.value = 0.40
	sfx_slider.value = 0.55
	await get_tree().create_timer(0.12).timeout
	if not is_equal_approx(AudioManager.bgm_volume, 0.40) \
			or not is_equal_approx(AudioManager.master_volume, 0.55):
		_fail("scene audio sliders did not apply immediately")
		return
	_assert_audio_continuity(music_stream, music_pos, ambience_stream, ambience_pos, "volume change")
	if get_tree().root.get_meta("story_settings_failed", false):
		return

	var body := _story.get("_body_lbl") as RichTextLabel
	var standard_font_size := body.get_theme_font_size("normal_font_size")
	large_button.button_pressed = true
	large_button.emit_signal("pressed")
	await get_tree().process_frame
	if str(SaveManager.get_setting("story_text_size", "")) != "large" \
			or body.get_theme_font_size("normal_font_size") <= standard_font_size:
		_fail("large story text did not save and apply immediately")
		return

	korean_button.button_pressed = true
	korean_button.emit_signal("pressed")
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	if LocaleManager.language != "ko":
		_fail("Korean language segment did not apply")
		return
	current = _story.get("_current")
	if str(current.get("id", "")) != "arc_daeun_wedding_walk" \
			or int(_story.get("_para_index")) != paragraph_before:
		_fail("language change moved the current event or paragraph")
		return
	if not _contains_hangul(str(current.get("title", "")) + str(body.text)):
		_fail("Korean event surface did not rebind in place")
		return
	if not is_equal_approx(GameState.money, money_before) or GameState.health != health_before \
			or GameState.mental != mental_before or GameState.flags != flags_before:
		_fail("language change mutated story state")
		return
	_assert_audio_continuity(music_stream, music_pos, ambience_stream, ambience_pos, "Korean switch")
	if get_tree().root.get_meta("story_settings_failed", false):
		return
	var localized_full := str(_story.get("_type_full"))
	var localized_ratio := float(_story.get("_type_pos")) / float(maxi(1, localized_full.length()))
	if absf(localized_ratio - type_ratio_before) > 0.10:
		_fail("language change did not preserve typing progress")
		return
	var rebuilt_language_buttons: Dictionary = _story.get("_story_language_buttons")
	var rebuilt_speed_buttons: Dictionary = _story.get("_story_text_speed_buttons")
	var english_button := rebuilt_language_buttons.get("en") as Button
	var rebuilt_korean_button := rebuilt_language_buttons.get("ko") as Button
	var rebuilt_fast_speed_button := rebuilt_speed_buttons.get("fast") as Button
	if not is_instance_valid(english_button) or not is_instance_valid(rebuilt_korean_button) \
			or not is_instance_valid(rebuilt_fast_speed_button) \
			or not rebuilt_fast_speed_button.button_pressed \
			or get_viewport().gui_get_focus_owner() != rebuilt_korean_button:
		_fail("language rebuild did not preserve controller focus or text speed")
		return
	english_button.button_pressed = true
	english_button.emit_signal("pressed")
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	var popup := _story.get("_audio_settings_popup") as Control
	if LocaleManager.language != "en" or not is_instance_valid(popup):
		_fail("English language segment did not rebuild scene settings")
		return
	var popup_text := _collect_control_text(popup)
	var english_title := str((_story.get("_current") as Dictionary).get("title", ""))
	if _contains_hangul(popup_text) or _contains_hangul(english_title):
		_fail("English surface leaked Hangul: title=%s popup=%s" % [
			english_title, popup_text.replace("\n", " | ").left(320)])
		return
	_assert_audio_continuity(music_stream, music_pos, ambience_stream, ambience_pos, "English switch")
	if get_tree().root.get_meta("story_settings_failed", false):
		return

	motion_toggle = _story.get("_audio_reduce_motion_toggle") as CheckButton
	motion_toggle.button_pressed = false
	await get_tree().process_frame
	motion_toggle.button_pressed = true
	await get_tree().process_frame
	var living_profile: Dictionary = _story.get("_living_profile")
	if not bool(SaveManager.get_setting("reduce_motion", false)) \
			or not bool(living_profile.get("reduced_motion", false)) \
			or str(living_profile.get("camera", "missing")) != "none":
		_fail("Reduce Motion did not apply to the current living scene")
		return

	_story.call("_on_advance")
	if int(_story.get("_para_index")) != paragraph_before:
		_fail("story advanced behind scene settings")
		return
	_story.call("_unhandled_input", menu_event)
	await get_tree().process_frame
	if is_instance_valid(_story.get("_audio_settings_popup")):
		_fail("dedicated menu input did not close scene settings")
		return

	# A timed choice must stop losing time while the player reads settings.
	current = (_story.get("_current") as Dictionary).duplicate(true)
	current["timed"] = true
	current["timer_seconds"] = 12
	current["timer_default_choice"] = 0
	_story.set("_current", current)
	_story.call("_complete_typing")
	_story.call("_show_choices")
	await get_tree().process_frame
	if int(_story.get("_choice_countdown_deadline_msec")) <= Time.get_ticks_msec():
		_fail("timed choice fixture did not start")
		return
	var focused_choice := get_viewport().gui_get_focus_owner() as Button
	if not is_instance_valid(focused_choice) or not focused_choice.has_meta("choice_index"):
		_fail("timed choice fixture did not expose a focused choice")
		return
	_story.call("_open_audio_settings")
	await get_tree().process_frame
	var paused_remaining := int(_story.get("_settings_countdown_remaining_msec"))
	if paused_remaining <= 0 or int(_story.get("_choice_countdown_deadline_msec")) != 0:
		_fail("scene settings did not pause the timed choice")
		return
	if _count_named_nodes(_story.get("_choice_box") as Node, "StoryChoiceCountdown") != 0:
		_fail("paused timed choice left a stale countdown row behind settings")
		return
	await get_tree().create_timer(0.20).timeout
	if int(_story.get("_settings_countdown_remaining_msec")) != paused_remaining \
			or int(_story.get("_pending_result_choice_index")) != -1:
		_fail("timed choice continued or resolved behind scene settings")
		return
	_story.call("_close_audio_settings")
	await get_tree().process_frame
	var resumed_remaining := int(_story.get("_choice_countdown_deadline_msec")) - Time.get_ticks_msec()
	if resumed_remaining <= 0 or abs(resumed_remaining - paused_remaining) > 120:
		_fail("timed choice did not resume from its saved remainder")
		return
	if _count_named_nodes(_story.get("_choice_box") as Node, "StoryChoiceCountdown") != 1:
		_fail("timed choice resumed with a missing or duplicate countdown row")
		return
	if get_viewport().gui_get_focus_owner() != focused_choice:
		_fail("closing scene settings did not restore the focused choice")
		return

	_story.call("_open_audio_settings")
	await get_tree().process_frame
	var cancel_event := InputEventAction.new()
	cancel_event.action = "ui_cancel"
	cancel_event.pressed = true
	_story.call("_unhandled_input", cancel_event)
	await get_tree().process_frame
	if is_instance_valid(_story.get("_audio_settings_popup")):
		_fail("controller cancel did not close scene settings")
		return
	if _count_named_nodes(_story.get("_choice_box") as Node, "StoryChoiceCountdown") != 1 \
			or get_viewport().gui_get_focus_owner() != focused_choice:
		_fail("reopening settings duplicated the timer or lost choice focus")
		return

	# Switching language on a result paragraph must translate in place without
	# applying the choice or scheduling its follow-up a second time.
	_story.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	GameState.start_new_game()
	GameState.player_name = "QA Tester"
	GameState.pending_story_queue = ["cafe_listen_01"]
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	await get_tree().process_frame
	await get_tree().process_frame
	current = _story.get("_current")
	if str(current.get("id", "")) != "cafe_listen_01":
		_fail("timed result fixture did not load")
		return
	if str(_story.get("_story_text_speed")) != "fast":
		_fail("text-speed setting did not persist into a new StoryMode scene")
		return
	_story.call("_complete_typing")
	_story.call("_show_choices")
	await get_tree().process_frame
	var mental_before_result := int(GameState.mental)
	_story.call("_on_choice", 0)
	await get_tree().process_frame
	var mental_after_result := int(GameState.mental)
	var flags_after_result: Dictionary = GameState.flags.duplicate(true)
	var follow_up_after_result := str(_story.get("_pending_follow_up"))
	if mental_after_result != mental_before_result - 6 \
			or follow_up_after_result != "cafe_peek_01" \
			or not bool(_story.get("_pending_after_result")):
		_fail("timed result fixture did not apply exactly once")
		return
	_story.call("_open_audio_settings")
	await get_tree().process_frame
	language_buttons = _story.get("_story_language_buttons")
	korean_button = language_buttons.get("ko") as Button
	korean_button.button_pressed = true
	korean_button.emit_signal("pressed")
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	if int(GameState.mental) != mental_after_result or GameState.flags != flags_after_result \
			or str(_story.get("_pending_follow_up")) != follow_up_after_result \
			or not bool(_story.get("_pending_after_result")) \
			or int(_story.get("_pending_result_choice_index")) != 0:
		_fail("result language switch replayed or lost choice state")
		return
	if not _contains_hangul(str(_story.get("_type_full"))):
		_fail("result paragraph did not rebind to Korean")
		return
	language_buttons = _story.get("_story_language_buttons")
	english_button = language_buttons.get("en") as Button
	english_button.button_pressed = true
	english_button.emit_signal("pressed")
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	if int(GameState.mental) != mental_after_result or GameState.flags != flags_after_result \
			or str(_story.get("_pending_follow_up")) != follow_up_after_result \
			or _contains_hangul(str(_story.get("_type_full"))):
		_fail("English result rebind replayed state or leaked Hangul")
		return
	_story.call("_close_audio_settings")
	await get_tree().process_frame

	_restore_settings()
	print("STORY_AUDIO_SETTINGS_CHECK_OK text=3 speed=3 locale=ko/en timer_pause=%d result_replay=0 music_pos=%.3f ambience_pos=%.3f" % [
		paused_remaining, music_pos, ambience_pos])
	get_tree().quit(0)

func _assert_audio_continuity(
		music_stream: AudioStream,
		music_pos: float,
		ambience_stream: AudioStream,
		ambience_pos: float,
		stage: String) -> void:
	if BGMPlayer._player_a.stream != music_stream \
			or BGMPlayer._player_a.get_playback_position() + 0.05 < music_pos:
		_fail("%s restarted scene music" % stage)
		return
	if BGMPlayer._ambience_player.stream != ambience_stream \
			or BGMPlayer._ambience_player.get_playback_position() + 0.05 < ambience_pos:
		_fail("%s restarted scene ambience" % stage)

func _collect_control_text(node: Node) -> String:
	var parts: Array[String] = []
	if node is Label:
		parts.append((node as Label).text)
	elif node is RichTextLabel:
		parts.append((node as RichTextLabel).text)
	elif node is BaseButton:
		parts.append((node as BaseButton).text)
	for child in node.get_children():
		parts.append(_collect_control_text(child))
	return "\n".join(parts)

func _contains_hangul(text: String) -> bool:
	for character in text:
		var code := character.unicode_at(0)
		if (code >= 0xAC00 and code <= 0xD7A3) or (code >= 0x3130 and code <= 0x318F):
			return true
	return false

func _count_named_nodes(node: Node, node_name: String) -> int:
	if not is_instance_valid(node):
		return 0
	var count := 1 if node.name == node_name else 0
	for child in node.get_children():
		count += _count_named_nodes(child, node_name)
	return count

func _restore_settings() -> void:
	AudioManager.set_bgm_volume(_original_bgm)
	AudioManager.set_sfx_volume(_original_sfx)
	SaveManager.set_setting("reduce_motion", _original_reduce_motion)
	SaveManager.set_setting("story_text_size", _original_text_size)
	SaveManager.set_setting("story_text_speed", _original_text_speed)
	LocaleManager.set_language(_original_language)

func _fail(message: String) -> void:
	get_tree().root.set_meta("story_settings_failed", true)
	_restore_settings()
	push_error("STORY_AUDIO_SETTINGS_CHECK_FAIL: %s" % message)
	get_tree().quit(1)
