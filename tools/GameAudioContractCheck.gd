extends Node
## GameAudioContractCheck — physical SFX loading, variation, and activity ambience ownership.

var _failures: Array[String] = []

func _ready() -> void:
	GameState.start_new_game()
	_check_manifest_assets()
	_check_varied_playback()
	await _check_activity_ambience()
	await _check_casino_music()
	if _failures.is_empty():
		print("GAME_AUDIO_RUNTIME_OK physical=17 ambience_roundtrip=3 varied_playback=1 casino_music=1")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("GAME_AUDIO_RUNTIME_FAIL: %s" % failure)
	get_tree().quit(1)

func _check_manifest_assets() -> void:
	var parsed: Variant = JSON.parse_string(
		FileAccess.get_file_as_string("res://assets/game_audio_manifest.json"))
	if not (parsed is Dictionary):
		_failures.append("cannot parse game_audio_manifest.json")
		return
	var physical: Variant = parsed.get("physical_sfx", {})
	if not (physical is Dictionary) or physical.size() != 17:
		_failures.append("physical SFX manifest must contain 17 semantic keys")
		return
	for raw_key in physical.keys():
		var key := str(raw_key)
		var path := str(physical[key])
		if not AudioManager.has_sound(key):
			_failures.append("AudioManager did not load %s" % key)
			continue
		if not ResourceLoader.exists(path):
			_failures.append("resource missing for %s" % key)
			continue
		var stream := load(path) as AudioStream
		if stream == null or stream.get_length() <= 0.04:
			_failures.append("invalid or silent-length stream for %s" % key)
	var activity_music: Variant = parsed.get("activity_music", {})
	var casino: Variant = activity_music.get("jeongseon_casino", {}) if activity_music is Dictionary else {}
	if not (casino is Dictionary):
		_failures.append("Jeongseon activity music contract is missing")
		return
	var floor_stream := load(str(casino.get("floor_path", ""))) as AudioStream
	var table_stream := load(str(casino.get("table_path", ""))) as AudioStream
	if floor_stream == null or table_stream == null:
		_failures.append("casino floor/table music could not load")
	elif floor_stream.get_length() <= 10.0 \
			or absf(floor_stream.get_length() - table_stream.get_length()) > 0.05:
		_failures.append("casino variations must be substantial and phase-compatible")

func _check_varied_playback() -> void:
	AudioManager.play_varied("card_deal", 0.0, 0.88, 0.88)
	var found := false
	for player in AudioManager._pool:
		if player.playing and player.stream == AudioManager._sounds.get("card_deal"):
			found = true
			if not is_equal_approx(player.pitch_scale, 0.88):
				_failures.append("play_varied did not apply requested pitch")
			break
	if not found:
		_failures.append("play_varied did not start a physical SFX player")

func _check_activity_ambience() -> void:
	BGMPlayer.start()
	BGMPlayer.enter_activity_ambience("casino")
	await get_tree().create_timer(0.08).timeout
	if BGMPlayer.activity_ambience_key() != "casino" \
			or BGMPlayer._current_ambience_key != "casino" \
			or not BGMPlayer._ambience_player.playing:
		_failures.append("casino activity ambience did not start")
		return
	var stream := BGMPlayer._ambience_player.stream
	var position := BGMPlayer._ambience_player.get_playback_position()
	BGMPlayer.enter_activity_ambience("casino")
	await get_tree().create_timer(0.08).timeout
	if BGMPlayer._ambience_player.stream != stream \
			or BGMPlayer._ambience_player.get_playback_position() + 0.02 < position:
		_failures.append("re-entering the same activity restarted ambience")

	BGMPlayer.enter_activity_ambience("racetrack")
	await get_tree().process_frame
	BGMPlayer.leave_activity_ambience("casino")
	if BGMPlayer.activity_ambience_key() != "racetrack":
		_failures.append("a stale activity owner cleared the active ambience")
	BGMPlayer.leave_activity_ambience("racetrack")
	await get_tree().process_frame
	if not BGMPlayer.activity_ambience_key().is_empty():
		_failures.append("activity ambience owner did not clear")
	if BGMPlayer._current_ambience_key != "room":
		_failures.append("leaving activity did not restore housing ambience")

func _check_casino_music() -> void:
	BGMPlayer.enter_activity_ambience("casino")
	BGMPlayer.enter_casino_music("floor")
	await get_tree().create_timer(0.12).timeout
	if BGMPlayer._music_mode != "activity" or BGMPlayer._current_key != "casino_floor" \
			or not BGMPlayer._player_a.playing:
		_failures.append("casino floor motif did not start")
		return
	var floor_stream: AudioStream = BGMPlayer._player_a.stream
	var floor_position := BGMPlayer._player_a.get_playback_position()
	BGMPlayer.enter_activity_ambience("casino")
	BGMPlayer.enter_casino_music("floor")
	await get_tree().process_frame
	if BGMPlayer._player_a.stream != floor_stream \
			or BGMPlayer._player_a.get_playback_position() + 0.02 < floor_position \
			or BGMPlayer._fade_tween != null:
		_failures.append("re-entering casino floor restarted its motif")
		return

	var phase_before_table := BGMPlayer._player_a.get_playback_position()
	BGMPlayer.enter_casino_music("table")
	await get_tree().process_frame
	if BGMPlayer._current_key != "casino_table" or not BGMPlayer._player_b.playing:
		_failures.append("casino table variation did not crossfade")
		return
	if BGMPlayer._player_b.get_playback_position() + 0.08 < phase_before_table:
		_failures.append("casino table variation did not inherit motif phase")
		return

	await get_tree().create_timer(BGMPlayer._FADE_TIME + 0.12).timeout
	var phase_before_floor := BGMPlayer._player_a.get_playback_position()
	BGMPlayer.enter_casino_music("floor")
	await get_tree().process_frame
	if BGMPlayer._current_key != "casino_floor" or not BGMPlayer._player_b.playing:
		_failures.append("casino floor return did not crossfade")
		return
	if BGMPlayer._player_b.get_playback_position() + 0.08 < phase_before_floor:
		_failures.append("casino floor return did not inherit motif phase")
		return

	BGMPlayer.leave_casino_music()
	BGMPlayer.leave_activity_ambience("casino")
	await get_tree().create_timer(0.9).timeout
	if BGMPlayer._music_mode != "ambient" or not BGMPlayer._current_key.is_empty() \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_failures.append("leaving Jeongseon did not restore the ambience-only hub")
