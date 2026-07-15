extends Node
## StoryAudioSettingsCheck — 장면 안 음량 패널의 입력·연속 재생 계약을 잠근다.

var _story: Control
var _original_bgm: float
var _original_sfx: float

func _ready() -> void:
	_original_bgm = AudioManager.bgm_volume
	_original_sfx = AudioManager.master_volume
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

	var menu_event := InputEventAction.new()
	menu_event.action = "gd_menu"
	menu_event.pressed = true
	_story.call("_unhandled_input", menu_event)
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(_story.get("_audio_settings_popup")):
		_fail("dedicated menu input did not open story audio settings")
		return
	var bgm_slider := _story.get("_audio_bgm_slider") as HSlider
	var sfx_slider := _story.get("_audio_sfx_slider") as HSlider
	if not is_instance_valid(bgm_slider) or not is_instance_valid(sfx_slider):
		_fail("story audio sliders are missing")
		return
	if get_viewport().gui_get_focus_owner() != bgm_slider:
		_fail("story audio popup did not focus the first controller row")
		return

	bgm_slider.value = 0.40
	sfx_slider.value = 0.55
	await get_tree().create_timer(0.12).timeout
	if not is_equal_approx(AudioManager.bgm_volume, 0.40) \
			or not is_equal_approx(AudioManager.master_volume, 0.55):
		_fail("story audio sliders did not apply immediately")
		return
	if BGMPlayer._player_a.stream != music_stream \
			or BGMPlayer._player_a.get_playback_position() + 0.05 < music_pos:
		_fail("changing volume restarted scene music")
		return
	if BGMPlayer._ambience_player.stream != ambience_stream \
			or BGMPlayer._ambience_player.get_playback_position() + 0.05 < ambience_pos:
		_fail("changing volume restarted scene ambience")
		return

	_story.call("_on_advance")
	if int(_story.get("_para_index")) != paragraph_before:
		_fail("story advanced behind the audio popup")
		return
	_story.call("_unhandled_input", menu_event)
	await get_tree().process_frame
	if is_instance_valid(_story.get("_audio_settings_popup")):
		_fail("dedicated menu input did not close story audio settings")
		return

	_story.call("_open_audio_settings")
	await get_tree().process_frame
	var cancel_event := InputEventAction.new()
	cancel_event.action = "ui_cancel"
	cancel_event.pressed = true
	_story.call("_unhandled_input", cancel_event)
	await get_tree().process_frame
	if is_instance_valid(_story.get("_audio_settings_popup")):
		_fail("controller cancel did not close story audio settings")
		return

	_restore_settings()
	print("STORY_AUDIO_SETTINGS_CHECK_OK music_pos=%.3f ambience_pos=%.3f" % [
		music_pos, ambience_pos])
	get_tree().quit(0)

func _restore_settings() -> void:
	AudioManager.set_bgm_volume(_original_bgm)
	AudioManager.set_sfx_volume(_original_sfx)

func _fail(message: String) -> void:
	_restore_settings()
	push_error("STORY_AUDIO_SETTINGS_CHECK_FAIL: %s" % message)
	get_tree().quit(1)
