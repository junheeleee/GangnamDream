extends Node
## MoralAmbienceCheck — the world keeps its machinery while human presence recedes.

var _failures: Array[String] = []

func _ready() -> void:
	AudioManager.bgm_volume = 0.25
	GameState.start_new_game()
	BGMPlayer.start()
	BGMPlayer.set_ambience("cafe")
	await get_tree().create_timer(0.12).timeout

	if BGMPlayer._human_ambience_player.bus != "GangnamDreamHumanAmbience":
		_failures.append("human ambience is not isolated from inert room tone")
	if BGMPlayer._current_human_ambience_key != "cafe" \
			or not BGMPlayer._human_ambience_player.playing:
		_failures.append("cafe did not start its separate human layer")
	if not is_equal_approx(BGMPlayer._moral_human_gain_db, -2.0) \
			or not is_equal_approx(BGMPlayer._moral_human_cutoff_hz, 20500.0):
		_failures.append("neutral human layer does not start clear and restrained")

	var neutral_human_db := BGMPlayer._human_ambience_target_db()
	var neutral_inert_db := BGMPlayer._ambience_target_db()
	var initial_stream := BGMPlayer._human_ambience_player.stream
	var initial_position := BGMPlayer._human_ambience_player.get_playback_position()
	BGMPlayer.set_ambience("cafe")
	await get_tree().process_frame
	if BGMPlayer._human_ambience_player.stream != initial_stream \
			or BGMPlayer._human_ambience_player.get_playback_position() + 0.03 < initial_position:
		_failures.append("same human room layer restarted at an event boundary")

	GameState.shift_moral_tint(-25.0)
	await get_tree().process_frame
	var light_dark_human_db := BGMPlayer._human_ambience_target_db()
	var light_dark_inert_db := BGMPlayer._ambience_target_db()
	if BGMPlayer._last_moral_stage != -1 \
			or not is_equal_approx(BGMPlayer._moral_human_gain_db, -16.0) \
			or not is_equal_approx(BGMPlayer._moral_human_cutoff_hz, 2600.0):
		_failures.append("light Black did not muffle and distance people")
	if light_dark_human_db > neutral_human_db - 12.0:
		_failures.append("light Black human layer did not recede enough")
	if light_dark_inert_db < neutral_inert_db - 3.0:
		_failures.append("light Black removed machinery together with people")

	GameState.shift_moral_tint(-35.0)
	await get_tree().process_frame
	var deep_dark_human_db := BGMPlayer._human_ambience_target_db()
	var deep_dark_inert_db := BGMPlayer._ambience_target_db()
	if BGMPlayer._last_moral_stage != -2 \
			or not is_equal_approx(BGMPlayer._moral_human_gain_db, -48.0) \
			or not is_equal_approx(BGMPlayer._moral_human_cutoff_hz, 780.0):
		_failures.append("deep Black did not leave people nearly absent")
	if deep_dark_human_db > light_dark_human_db - 30.0:
		_failures.append("deep Black human layer is still too present")
	if deep_dark_inert_db < neutral_inert_db - 6.0:
		_failures.append("deep Black erased the physical location")

	GameState.shift_moral_tint(90.0)
	await get_tree().process_frame
	if BGMPlayer._last_moral_stage != 1 \
			or not is_equal_approx(BGMPlayer._moral_human_gain_db, 1.5) \
			or BGMPlayer._human_ambience_target_db() <= neutral_human_db:
		_failures.append("White route did not restore human detail")
	if BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_failures.append("moral ambience transition exposed itself with a music cue")

	BGMPlayer.set_ambience("car")
	await get_tree().process_frame
	if not BGMPlayer._current_human_ambience_key.is_empty():
		_failures.append("private car invented a crowd layer")
	if BGMPlayer._current_ambience_key != "car" or not BGMPlayer._ambience_player.playing:
		_failures.append("private location lost its inert room tone")

	if _failures.is_empty():
		print("MORAL_AMBIENCE_CHECK_OK profiles=%d neutral=%.2f dark=%.2f deep=%.2f" % [
			BGMPlayer.HUMAN_AMBIENCE_TRACKS.size(), neutral_human_db,
			light_dark_human_db, deep_dark_human_db])
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("MORAL_AMBIENCE_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)
