extends Node
## GameAudioContractCheck — physical SFX loading, variation, and activity ambience ownership.

var _failures: Array[String] = []
var _original_vibration_enabled: bool
var _original_vibration_intensity: float

const HAPTIC_PROFILE_IDS: Array[StringName] = [
	&"commit_choice", &"commit_action", &"commit_wager", &"danger_impact",
	&"physical_card", &"physical_dice_roll",
	&"physical_reel_spin", &"physical_reel_stop",
	&"result_jackpot", &"result_win", &"result_loss", &"result_push",
]
const DIRECT_HAPTIC_SCENES: Array[String] = [
	"res://scenes/BlackjackTable.gd",
	"res://scenes/BaccaratTable.gd",
	"res://scenes/SlotMachineGame.gd",
	"res://scenes/RouletteTable.gd",
	"res://scenes/BigWheelGame.gd",
	"res://scenes/DaiSaiTable.gd",
	"res://scenes/HoldemClub.gd",
	"res://scenes/RaceTrack.gd",
]
const MAJOR_BOUNDARY_FUNCTIONS: Dictionary = {
	"res://scenes/BlackjackTable.gd": "_pad_cycle_stake",
	"res://scenes/BaccaratTable.gd": "_pad_cycle_stake",
	"res://scenes/SlotMachineGame.gd": "_pad_cycle_stake",
	"res://scenes/RouletteTable.gd": "_pad_cycle_stake",
	"res://scenes/BigWheelGame.gd": "_pad_cycle_stake",
	"res://scenes/DaiSaiTable.gd": "_pad_cycle_stake",
	"res://scenes/HoldemClub.gd": "_pad_cycle_buyin",
	"res://scenes/RaceTrack.gd": "_pad_cycle_stake",
}

func _ready() -> void:
	_original_vibration_enabled = AudioManager.vibration_enabled()
	_original_vibration_intensity = AudioManager.vibration_intensity()
	GameState.start_new_game()
	_check_manifest_assets()
	_check_varied_playback()
	_check_haptic_contract()
	await _check_activity_ambience()
	await _check_casino_music()
	_restore_haptic_settings()
	await _release_audio_for_exit()
	if _failures.is_empty():
		print("GAME_AUDIO_RUNTIME_OK physical=32 ambience_roundtrip=3 varied_playback=1 casino_music=1 haptics=12 unused_profiles=0 direct_scene_raw=0 vibration_roundtrip=1 boundary_clamp=8 same_stack=3")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("GAME_AUDIO_RUNTIME_FAIL: %s" % failure)
	get_tree().quit(1)

func _release_audio_for_exit() -> void:
	for raw_tween in get_tree().get_processed_tweens():
		if raw_tween is Tween and (raw_tween as Tween).is_valid():
			(raw_tween as Tween).kill()
	BGMPlayer.stop()
	_detach_audio_streams(get_tree().root)
	for raw_player in AudioManager._pool:
		if raw_player is AudioStreamPlayer:
			(raw_player as AudioStreamPlayer).stop()
			(raw_player as AudioStreamPlayer).stream = null
	AudioManager._sounds.clear()
	await AudioManager.drain_pending_timers_for_exit()
	for _release_frame in range(4):
		await get_tree().process_frame

func _detach_audio_streams(root: Node) -> void:
	if root is AudioStreamPlayer:
		(root as AudioStreamPlayer).stop()
		(root as AudioStreamPlayer).stream = null
	elif root is AudioStreamPlayer2D:
		(root as AudioStreamPlayer2D).stop()
		(root as AudioStreamPlayer2D).stream = null
	for child in root.get_children():
		_detach_audio_streams(child)

func _check_manifest_assets() -> void:
	var parsed: Variant = JSON.parse_string(
		FileAccess.get_file_as_string("res://assets/game_audio_manifest.json"))
	if not (parsed is Dictionary):
		_failures.append("cannot parse game_audio_manifest.json")
		return
	var physical: Variant = parsed.get("physical_sfx", {})
	if not (physical is Dictionary) or physical.size() != 32:
		_failures.append("physical SFX manifest must contain 32 semantic keys")
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

func _check_haptic_contract() -> void:
	_expect(AudioManager.HAPTIC_PROFILES.size() == HAPTIC_PROFILE_IDS.size(),
		"central haptic profile count changed")
	for profile_id in HAPTIC_PROFILE_IDS:
		var profile := AudioManager.haptic_profile(profile_id)
		_expect(profile.x > 0.0 and profile.x <= 1.0,
			"%s weak motor is invalid: %s" % [profile_id, profile])
		_expect(profile.y > 0.0 and profile.y <= 1.0,
			"%s strong motor is invalid: %s" % [profile_id, profile])
		_expect(profile.z > 0.0,
			"%s duration is invalid: %s" % [profile_id, profile])
	_expect(AudioManager.haptic_profile(&"unknown_profile") == Vector3.ZERO,
		"unknown haptic profile did not resolve to zero")

	var audio_source := FileAccess.get_file_as_string("res://autoloads/AudioManager.gd")
	var haptic_callsite_source := audio_source \
			+ FileAccess.get_file_as_string("res://scenes/MainGame.gd") \
			+ FileAccess.get_file_as_string("res://scenes/StoryMode.gd")
	for wrapper_name in ["play_ui_click", "play_ui_open", "play_ui_close"]:
		var wrapper_body := _function_source(audio_source, wrapper_name)
		_expect(not wrapper_body.contains("pulse_gamepad(") \
				and not wrapper_body.contains("play_haptic("),
			"ordinary UI wrapper %s still owns vibration" % wrapper_name)

	var profile_pattern := RegEx.new()
	profile_pattern.compile("play_haptic\\(&\"([^\"]+)\"\\)")
	for scene_path in DIRECT_HAPTIC_SCENES:
		var source := FileAccess.get_file_as_string(scene_path)
		haptic_callsite_source += source
		_expect(not source.contains("pulse_gamepad("),
			"%s still owns raw haptic numbers" % scene_path)
		_expect(source.contains("ControllerHints.major_direction(event)"),
			"%s does not route major triggers semantically" % scene_path)
		_expect(source.contains("ControllerHints.trigger_l()") \
				and source.contains("ControllerHints.trigger_r()"),
			"%s does not disclose both trigger glyphs" % scene_path)
		for raw_line in source.split("\n"):
			var line := str(raw_line)
			if not line.contains("AudioManager.play_haptic("):
				continue
			var match_result := profile_pattern.search(line)
			_expect(match_result != null,
				"%s has a non-literal haptic profile: %s" % [scene_path, line.strip_edges()])
			if match_result != null:
				var scene_profile := StringName(match_result.get_string(1))
				_expect(HAPTIC_PROFILE_IDS.has(scene_profile),
					"%s uses unknown haptic profile %s" % [scene_path, scene_profile])
	for profile_id in HAPTIC_PROFILE_IDS:
		_expect(haptic_callsite_source.contains("play_haptic(&\"%s\")" % profile_id),
			"central haptic profile has no callsite: %s" % profile_id)
	_check_major_boundary_contract()
	_check_same_stack_haptic_sparsity()

	var stop_serial := int(AudioManager._vibration_stop_serial)
	AudioManager.set_vibration_enabled(false)
	_expect(int(AudioManager._vibration_stop_serial) == stop_serial + 1,
		"disabling vibration did not stop an in-flight pulse")
	_expect(AudioManager.vibration_profile(0.5, 0.8) == Vector2.ZERO,
		"disabled vibration produced non-zero motor output")
	_expect(not AudioManager.play_haptic(&"commit_choice"),
		"disabled named haptic reported a pulse")
	_expect(_stored_setting("vibration_enabled", true) == false,
		"disabled vibration did not persist")

	AudioManager.set_vibration_enabled(true)
	stop_serial = int(AudioManager._vibration_stop_serial)
	AudioManager.set_vibration_intensity(0.0)
	_expect(int(AudioManager._vibration_stop_serial) == stop_serial + 1,
		"setting vibration to zero did not stop an in-flight pulse")
	_expect(AudioManager.vibration_profile(0.5, 0.8) == Vector2.ZERO,
		"zero-percent vibration produced non-zero motor output")
	_expect(not AudioManager.play_haptic(&"commit_action"),
		"zero-percent named haptic reported a pulse")
	_expect(is_zero_approx(float(_stored_setting("vibration_intensity", -1.0))),
		"zero-percent vibration did not persist")

	AudioManager.set_vibration_intensity(0.5)
	_expect(AudioManager.vibration_profile(0.4, 0.8).is_equal_approx(Vector2(0.2, 0.4)),
		"vibration intensity scaling changed")
	_expect(is_equal_approx(float(_stored_setting("vibration_intensity", -1.0)), 0.5),
		"vibration intensity did not persist")

func _check_major_boundary_contract() -> void:
	for scene_path in MAJOR_BOUNDARY_FUNCTIONS:
		var source := FileAccess.get_file_as_string(scene_path)
		var function_name := str(MAJOR_BOUNDARY_FUNCTIONS[scene_path])
		var body := _function_source(source, function_name)
		_expect(body.contains("clampi("),
			"%s.%s does not clamp its coarse-value boundary" % [scene_path, function_name])
		_expect(not body.contains("posmod("),
			"%s.%s still wraps min/max coarse values" % [scene_path, function_name])
		_expect(body.contains("if next_idx =="),
			"%s.%s does not make a boundary press inert" % [scene_path, function_name])

func _check_same_stack_haptic_sparsity() -> void:
	var blackjack_source := FileAccess.get_file_as_string(
		"res://scenes/BlackjackTable.gd")
	var blackjack_dealer := _function_source(
		blackjack_source, "_dealer_play_and_resolve")
	var blackjack_hit := _function_source(blackjack_source, "_hit")
	var blackjack_deal := _function_source(blackjack_source, "_deal")
	var blackjack_double := _function_source(blackjack_source, "_double_down")
	_expect(not blackjack_dealer.contains("play_haptic("),
		"Blackjack dealer reveal starts a pulse immediately replaced by its result")
	_expect(blackjack_hit.contains("resolves_now") \
			and blackjack_hit.find("if not resolves_now:") \
			< blackjack_hit.find("play_haptic(&\"physical_card\")"),
		"Blackjack terminal hit does not reserve the final result haptic")
	_expect(blackjack_deal.find("_resolve_hand()") \
			< blackjack_deal.find("play_haptic(&\"commit_wager\")"),
		"Blackjack natural deal starts a wager pulse before its immediate result")
	_expect(blackjack_double.find("if _split_active and not _split.is_empty():") \
			< blackjack_double.find("play_haptic(&\"commit_wager\")"),
		"Blackjack terminal double-down does not reserve the final result haptic")

	var slot_bump := _function_source(FileAccess.get_file_as_string(
		"res://scenes/SlotMachineGame.gd"), "_bump_reel")
	_expect(slot_bump.contains("if index < _reel_panels.size() - 1:") \
			and slot_bump.find("if index < _reel_panels.size() - 1:") \
			< slot_bump.find("play_haptic(&\"physical_reel_stop\")"),
		"Slot final reel stop is not suppressed before the immediate result")

	var holdem_advance := _function_source(FileAccess.get_file_as_string(
		"res://scenes/HoldemClub.gd"), "_advance_phase")
	_expect(not holdem_advance.contains("play_haptic("),
		"Holdem recursive phase reveal can overwrite the same-stack result haptic")

func _function_source(source: String, function_name: String) -> String:
	var start := source.find("func %s(" % function_name)
	if start < 0:
		return ""
	var finish := source.find("\nfunc ", start + 1)
	if finish < 0:
		finish = source.length()
	return source.substr(start, finish - start)

func _stored_setting(key: String, default_value: Variant) -> Variant:
	var path := SaveManager.settings_path()
	if not FileAccess.file_exists(path):
		return default_value
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary):
		return default_value
	return parsed.get(key, default_value)

func _restore_haptic_settings() -> void:
	AudioManager.set_vibration_intensity(_original_vibration_intensity)
	AudioManager.set_vibration_enabled(_original_vibration_enabled)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)

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
