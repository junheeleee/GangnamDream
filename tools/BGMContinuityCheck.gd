extends Node
## BGMContinuityCheck — 같은 컨텍스트 재진입 시 BGM이 0초로 재시작하지 않는지 확인.

func _ready() -> void:
	AudioManager.bgm_volume = 0.25
	GameState.start_new_game()
	GameState.age = 33
	GameState.month = 1
	GameState.health = 80
	GameState.mental = 80
	GameState.current_job = {}

	BGMPlayer.start()
	await get_tree().create_timer(0.35).timeout
	var first_key := BGMPlayer._current_key
	var first_pos := BGMPlayer._player_a.get_playback_position()
	BGMPlayer.start()
	await get_tree().process_frame
	var second_pos := BGMPlayer._player_a.get_playback_position()
	if first_key != "early":
		_fail("expected early track, got %s" % first_key)
		return
	if second_pos + 0.05 < first_pos:
		_fail("main BGM restarted: %.3f -> %.3f" % [first_pos, second_pos])
		return

	GameState.age = 36
	BGMPlayer.update_context()
	await get_tree().create_timer(0.18).timeout
	var fade_key := BGMPlayer._fade_target_key
	var fade_pos := BGMPlayer._player_b.get_playback_position()
	BGMPlayer.update_context()
	await get_tree().process_frame
	var repeated_fade_pos := BGMPlayer._player_b.get_playback_position()
	if fade_key != "late_tense":
		_fail("expected late_tense fade target, got %s" % fade_key)
		return
	if repeated_fade_pos + 0.05 < fade_pos:
		_fail("crossfade target restarted: %.3f -> %.3f" % [fade_pos, repeated_fade_pos])
		return

	GameState.age = 33
	BGMPlayer.update_context()
	await get_tree().process_frame
	if BGMPlayer._current_key != "early" or BGMPlayer._fade_target_key != "":
		_fail("returning to active track during fade should keep early, got current=%s target=%s" % [
			BGMPlayer._current_key, BGMPlayer._fade_target_key])
		return

	BGMPlayer.start_menu()
	await get_tree().create_timer(0.15).timeout
	BGMPlayer.start_menu()
	if BGMPlayer._current_key != "menu":
		_fail("expected menu track after start_menu, got %s" % BGMPlayer._current_key)
		return
	if not (BGMPlayer._player_a.playing or BGMPlayer._player_b.playing):
		_fail("menu BGM stopped during repeated start_menu")
		return

	print("BGM_CONTINUITY_OK main_pos=%.3f repeated_pos=%.3f key=%s" % [
		first_pos, second_pos, BGMPlayer._current_key])
	get_tree().quit(0)

func _fail(msg: String) -> void:
	push_error("BGM_CONTINUITY_FAIL " + msg)
	get_tree().quit(1)
