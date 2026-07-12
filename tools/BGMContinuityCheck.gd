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
	if BGMPlayer._player_a.bus != "GangnamDreamBGM" or BGMPlayer._player_b.bus != "GangnamDreamBGM":
		_fail("BGM players are not isolated on the moral audio bus")
		return
	if BGMPlayer._ambience_player.bus != "Master":
		_fail("moral BGM bus should not filter ambience")
		return
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

	# MORAL_TINT는 재생 위치를 유지하면서 BGM 질감과 생활 앰비언스의 주의 비중만 바꾼다.
	var moral_pos_before: float = BGMPlayer._player_a.get_playback_position()
	var moral_transitions_before: int = BGMPlayer._moral_transition_count
	GameState.shift_moral_tint(-25.0)
	await get_tree().process_frame
	var moral_pos_after: float = BGMPlayer._player_a.get_playback_position()
	if BGMPlayer._last_moral_stage != -1 or not is_equal_approx(BGMPlayer._moral_target_cutoff_hz, 4800.0):
		_fail("dark moral band did not target low-pass stage -1")
		return
	if not is_equal_approx(BGMPlayer._moral_ambience_gain_db, -2.2):
		_fail("dark moral band did not let the lived world recede")
		return
	if BGMPlayer._moral_transition_count != moral_transitions_before + 1:
		_fail("moral band transition was not counted exactly once")
		return
	if moral_pos_after + 0.05 < moral_pos_before or BGMPlayer._current_key != "early":
		_fail("moral audio shift restarted or replaced BGM")
		return
	var same_band_count: int = BGMPlayer._moral_transition_count
	GameState.shift_moral_tint(-5.0)
	await get_tree().process_frame
	if BGMPlayer._moral_transition_count != same_band_count:
		_fail("same moral band retriggered audio transition")
		return
	GameState.shift_moral_tint(-35.0)
	await get_tree().process_frame
	if BGMPlayer._last_moral_stage != -2 or not is_equal_approx(BGMPlayer._moral_target_cutoff_hz, 1450.0):
		_fail("deep dark moral band did not target low-pass stage -2")
		return
	if not is_equal_approx(BGMPlayer._moral_ambience_gain_db, -5.0):
		_fail("deep dark moral band did not suppress lived ambience")
		return
	GameState.shift_moral_tint(90.0)
	await get_tree().process_frame
	if BGMPlayer._last_moral_stage != 1 or not is_equal_approx(BGMPlayer._moral_target_cutoff_hz, 20500.0):
		_fail("bright moral band did not restore full-range BGM")
		return
	if not is_equal_approx(BGMPlayer._moral_ambience_gain_db, 1.0):
		_fail("bright moral band did not restore lived ambience")
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
	if BGMPlayer._last_moral_stage != 0 or not is_equal_approx(BGMPlayer._moral_target_cutoff_hz, 20500.0):
		_fail("menu did not restore neutral BGM texture")
		return
	if not is_zero_approx(BGMPlayer._moral_ambience_gain_db):
		_fail("menu did not restore neutral ambience attention")
		return

	var interview_ev := {
		"id": "qa_interview_audio",
		"title": "Interview",
		"description": "The interviewer points at the chair.",
		"category": "life",
		"tags": [],
	}
	if BGMPlayer._pick_ambience(interview_ev) != "office":
		_fail("inferred interview background should use office ambience")
		return

	var hangang_ev := {
		"id": "qa_hangang_audio",
		"title": "Evening walk",
		"description": "He keeps walking along the riverside promenade.",
		"category": "health",
		"tags": [],
	}
	if BGMPlayer._pick_ambience(hangang_ev) != "hangang":
		_fail("inferred Hangang background should use riverside ambience")
		return

	var ambience_cases := [
		[{
			"id": "qa_racetrack_audio",
			"title": "Betting Hall",
			"description": "The horses break into the final straight.",
			"category": "gambling",
			"tags": [],
		}, "racetrack"],
		[{
			"id": "qa_subway_audio",
			"title": "Commute",
			"description": "The subway doors close before he can breathe.",
			"category": "life",
			"tags": [],
		}, "subway"],
		[{
			"id": "qa_street_audio",
			"title": "Civil Defense Siren",
			"description": "A civil defense siren pauses Seoul for five minutes.",
			"category": "life",
			"background": "street",
			"tags": [],
		}, "street"],
		[{
			"id": "arc_year2_close",
			"title": "34세의 마지막 밤",
			"description": "1년 전과 비교하면 많은 게 달라졌다.",
			"category": "story",
			"background": "year2_winter_street_night",
			"tags": ["story", "arc", "year_close"],
		}, "street"],
		[{
			"id": "arc_year3_close",
			"title": "35세의 마지막 밤",
			"description": "한강이 어두웠다.",
			"category": "story",
			"background": "year3_hangang_winter_night",
			"tags": ["story", "arc", "year_close"],
		}, "hangang"],
		[{
			"id": "arc_year4_close",
			"title": "36세의 마지막 밤",
			"description": "마지막 한 해를 앞둔 밤이었다.",
			"category": "story",
			"background": "year4_winter_rooftop",
			"tags": ["story", "arc", "year_close"],
		}, "street"],
		[{
			"id": "qa_cafe_audio",
			"title": "Coffee",
			"description": "He waits at a cafe table by the window.",
			"category": "social",
			"tags": [],
		}, "cafe"],
		[{
			"id": "arc_sangchul_03_network",
			"title": "강남이 돌아가는 방식",
			"description": "강남 한복판 레스토랑 개인실에서 명함이 오갔다.",
			"category": "story",
			"background": "sangchul_private_dining",
			"tags": ["story", "arc", "sangchul"],
		}, "cafe"],
		[{
			"id": "qa_gym_audio",
			"title": "Workout",
			"description": "At the gym, every machine sounds more certain than he feels.",
			"category": "health",
			"tags": [],
		}, "gym"],
		[{
			"id": "qa_pc_bang_audio",
			"title": "Late Match",
			"description": "The PC bang glows blue at 2 AM.",
			"category": "life",
			"tags": [],
		}, "pc_bang"],
		[{
			"id": "qa_convenience_audio",
			"title": "Night Shift",
			"description": "The convenience store refrigerator keeps humming.",
			"category": "life",
			"tags": [],
		}, "convenience"],
		[{
			"id": "qa_hagwon_audio",
			"title": "Hagwon Street",
			"description": "At 10 PM the Daechi hagwon street empties into the rain.",
			"category": "life",
			"tags": [],
		}, "hagwon"],
		[{
			"id": "qa_cherry_audio",
			"title": "Cherry Blossoms",
			"description": "The cherry blossom petals fall along Seokchon Lake.",
			"category": "life",
			"tags": [],
		}, "cherry"],
		[{
			"id": "qa_saju_audio",
			"title": "Saju Cafe",
			"description": "The fortune-reading cafe feels quieter than the street outside.",
			"category": "life",
			"tags": [],
		}, "saju"],
		[{
			"id": "qa_hoesik_audio",
			"title": "Company Dinner",
			"description": "The hoesik starts at a samgyeopsal restaurant with soju glasses on the table.",
			"category": "social",
			"tags": [],
		}, "hoesik"],
		[{
			"id": "qa_heatwave_audio",
			"title": "Heat Wave",
			"description": "The asphalt heat rises in waves during a Seoul heatwave.",
			"category": "life",
			"tags": [],
		}, "heatwave"],
		[{
			"id": "qa_fine_dust_audio",
			"title": "Fine Dust Warning",
			"description": "The fine dust warning turns the Seoul street into yellow-gray air.",
			"category": "life",
			"tags": [],
		}, "fine_dust"],
		[{
			"id": "qa_chuseok_audio",
			"title": "Chuseok Traffic",
			"description": "The holiday traffic keeps the intercity bus on the highway for hours.",
			"category": "life",
			"tags": [],
		}, "highway"],
		[{
			"id": "qa_bus_terminal_audio",
			"title": "Last Coach",
			"description": "He waits on the platform until the coach departs.",
			"category": "story",
			"background": "seoul_bus_terminal_night",
			"tags": [],
		}, "highway"],
		[{
			"id": "kx_open_chat",
			"title": "Open Chat",
			"description": "An anonymous online investing chat room keeps scrolling on the phone.",
			"category": "social",
			"tags": [],
		}, "open_chat"],
		[{
			"id": "qa_library_audio",
			"title": "Library Seat",
			"description": "The public library reading room is quiet except for books and keyboards.",
			"category": "social",
			"background": "library",
			"tags": [],
		}, "library"],
		[{
			"id": "qa_suneung_audio",
			"title": "CSAT Morning",
			"description": "The exam hall corridor goes quiet before the test begins.",
			"category": "life",
			"tags": [],
		}, "school"],
		[{
			"id": "qa_community_center_audio",
			"title": "Community Center",
			"description": "He pulls a queue ticket at the district office counter.",
			"category": "life",
			"tags": [],
		}, "public_office"],
		[{
			"id": "qa_jjimjilbang_audio",
			"title": "Jjimjilbang",
			"description": "The Korean sauna room hums under warm light.",
			"category": "life",
			"tags": [],
		}, "jjimjilbang"],
		[{
			"id": "qa_military_gate_audio",
			"title": "Reserve Duty",
			"description": "The reserve forces training notice points him toward the gate.",
			"category": "military",
			"tags": [],
		}, "military_gate"],
	]
	for case in ambience_cases:
		var actual := BGMPlayer._pick_ambience(case[0])
		if actual != str(case[1]):
			_fail("inferred ambience mismatch: expected %s got %s" % [case[1], actual])
			return

	print("BGM_CONTINUITY_OK main_pos=%.3f repeated_pos=%.3f key=%s" % [
		first_pos, second_pos, BGMPlayer._current_key])
	get_tree().quit(0)

func _fail(msg: String) -> void:
	push_error("BGM_CONTINUITY_FAIL " + msg)
	get_tree().quit(1)
