extends Node
## BGMContinuityCheck — 기본 베드=장소/계절, 음악=정점 구두점이라는 규칙을 잠근다.

func _ready() -> void:
	AudioManager.bgm_volume = 0.25
	GameState.start_new_game()
	GameState.age = 33
	GameState.month = 1
	GameState.housing = "gosiwon"
	GameState.health = 80
	GameState.mental = 80
	GameState.current_job = {}

	BGMPlayer.start()
	await get_tree().create_timer(0.35).timeout
	if BGMPlayer._player_a.bus != "GangnamDreamBGM" or BGMPlayer._player_b.bus != "GangnamDreamBGM":
		_fail("BGM players are not isolated on the moral audio bus")
		return
	if BGMPlayer._ambience_player.bus != "Master" or BGMPlayer._season_player.bus != "Master":
		_fail("moral BGM bus should not filter lived ambience")
		return
	if BGMPlayer._music_mode != "ambient" or not BGMPlayer._current_key.is_empty():
		_fail("weekly hub started with continuous music instead of ambience")
		return
	if BGMPlayer._current_ambience_key != "room" or BGMPlayer._current_season_key != "winter":
		_fail("January goshiwon did not start with room+winter layers")
		return
	if not BGMPlayer._ambience_player.playing or not BGMPlayer._season_player.playing:
		_fail("weekly ambience layers are not playing")
		return
	var ambience_pos := BGMPlayer._ambience_player.get_playback_position()
	BGMPlayer.start()
	await get_tree().process_frame
	var repeated_ambience_pos := BGMPlayer._ambience_player.get_playback_position()
	if repeated_ambience_pos + 0.05 < ambience_pos:
		_fail("same weekly ambience restarted: %.3f -> %.3f" % [ambience_pos, repeated_ambience_pos])
		return

	# MORAL_TINT는 음악을 강제로 시작하지 않고, 살아 있는 세계의 비중만 바꾼다.
	var moral_transitions_before: int = BGMPlayer._moral_transition_count
	GameState.shift_moral_tint(-25.0)
	await get_tree().process_frame
	if BGMPlayer._last_moral_stage != -1 or not is_equal_approx(BGMPlayer._moral_target_cutoff_hz, 4800.0):
		_fail("dark moral band did not target low-pass stage -1")
		return
	if not is_equal_approx(BGMPlayer._moral_ambience_gain_db, -2.2):
		_fail("dark moral band did not let the lived world recede")
		return
	if BGMPlayer._moral_transition_count != moral_transitions_before + 1:
		_fail("moral band transition was not counted exactly once")
		return
	if BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail("moral shift started music during ambient mode")
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
	if BGMPlayer._last_moral_stage != 1 or not is_equal_approx(BGMPlayer._moral_ambience_gain_db, 1.0):
		_fail("bright moral band did not restore lived ambience")
		return

	# 연차별 로파이 마스터는 메뉴 전용이다. 월말과 일반 허브 호출도
	# 음악을 시작하지 않고 현재 장소 베드로 돌아간다.
	BGMPlayer.play_punctuation("early")
	await get_tree().create_timer(0.18).timeout
	if BGMPlayer._music_mode != "ambient" or not BGMPlayer._current_key.is_empty() \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail("lobby-only early lo-fi entered a story punctuation state")
		return
	GameState.age = 36
	BGMPlayer.update_context()
	await get_tree().create_timer(0.18).timeout
	if BGMPlayer._music_mode != "ambient" or not BGMPlayer._current_key.is_empty() \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail("monthly context started generic lo-fi outside the menu")
		return

	# 정선 카지노만은 장소 전용 모티프를 소유한다. 플로어와 테이블은
	# 같은 위상에서 교차하고, 같은 레이어 재호출은 재생을 되감지 않는다.
	BGMPlayer.enter_activity_ambience("casino")
	BGMPlayer.enter_casino_music("floor")
	await get_tree().create_timer(0.12).timeout
	if BGMPlayer._music_mode != "activity" or BGMPlayer._current_key != "casino_floor":
		_fail("casino floor did not enter its authored activity motif")
		return
	var floor_pos := BGMPlayer._player_a.get_playback_position()
	BGMPlayer.enter_activity_ambience("casino")
	BGMPlayer.enter_casino_music("floor")
	await get_tree().process_frame
	if BGMPlayer._player_a.get_playback_position() + 0.02 < floor_pos \
			or BGMPlayer._fade_tween != null:
		_fail("same casino floor state restarted its motif")
		return
	var phase_before_table := BGMPlayer._player_a.get_playback_position()
	BGMPlayer.enter_casino_music("table")
	await get_tree().process_frame
	if BGMPlayer._current_key != "casino_table" or not BGMPlayer._player_b.playing \
			or BGMPlayer._player_b.get_playback_position() + 0.08 < phase_before_table:
		_fail("casino table variation did not phase-lock its crossfade")
		return
	BGMPlayer.leave_casino_music()
	BGMPlayer.leave_activity_ambience("casino")
	await get_tree().create_timer(0.9).timeout
	if BGMPlayer._music_mode != "ambient" or not BGMPlayer._current_key.is_empty():
		_fail("casino exit did not restore ambience-only context")
		return

	# 주거 사다리와 계절은 서로 독립된 장소 레이어다.
	GameState.housing = "oneroom"
	GameState.month = 4
	BGMPlayer.update_idle_ambience()
	if BGMPlayer._current_ambience_key != "oneroom" or not BGMPlayer._current_season_key.is_empty():
		_fail("spring one-room ambience mapping failed")
		return
	GameState.housing = "apartment"
	GameState.month = 7
	BGMPlayer.update_idle_ambience()
	if BGMPlayer._current_ambience_key != "apartment" or BGMPlayer._current_season_key != "summer":
		_fail("summer apartment ambience mapping failed")
		return
	GameState.housing = "villa"
	GameState.month = 10
	BGMPlayer.update_idle_ambience()
	if BGMPlayer._current_ambience_key != "oneroom" or not BGMPlayer._current_season_key.is_empty():
		_fail("autumn villa ambience mapping failed")
		return

	# 랜덤 사건과 미배정 아크는 모두 앰비언스만 유지한다. 중요도나 ID는
	# 음악 큐가 아니며, scene_audio_manifest의 명시 계약만 스코어를 연다.
	var random_ev := {"id": "qa_random_audio", "category": "daily_life", "rarity": "common", "tags": []}
	BGMPlayer.begin_story_event(random_ev)
	await get_tree().process_frame
	if BGMPlayer._music_mode != "ambient" or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail("ordinary event started directive music")
		return
	var arc_ev := {"id": "arc_qa_audio", "category": "story", "rarity": "story", "tags": ["arc"]}
	BGMPlayer.begin_story_event(arc_ev)
	await get_tree().create_timer(3.45).timeout
	if BGMPlayer._music_mode != "ambient" or not BGMPlayer._current_key.is_empty() \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail("unscored arc inferred generic lo-fi from its story category")
		return

	# 저작된 정점 음악은 지정 문단까지 기다리고, 체인 경계에서 재시작하지 않는다.
	BGMPlayer.enter_ambient_bed(0.0)
	var wedding_ev: Dictionary = DataRegistry.find_event("arc_daeun_wedding_day")
	var wedding_walk_ev: Dictionary = DataRegistry.find_event("arc_daeun_wedding_walk")
	var wedding_aisle_ev: Dictionary = DataRegistry.find_event("arc_daeun_wedding_aisle")
	if wedding_ev.is_empty() or wedding_walk_ev.is_empty() or wedding_aisle_ev.is_empty():
		_fail("wedding scene audio fixtures are missing")
		return
	BGMPlayer.update_event_ambience(wedding_ev, "cg_romance_wedding_daeun_mother_reaction")
	BGMPlayer.begin_story_event(wedding_ev, "cg_romance_wedding_daeun_mother_reaction")
	await get_tree().process_frame
	if BGMPlayer._current_ambience_key != "wedding_hall" or not BGMPlayer._current_season_key.is_empty():
		_fail("wedding CG did not select the authored hall ambience")
		return
	if BGMPlayer._music_mode != "ambient" or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail("wedding reaction shot did not preserve ambience-only silence")
		return
	BGMPlayer.play_scene_paragraph_music(wedding_ev, "cg_romance_wedding_daeun_mother_reaction", 0)
	await get_tree().process_frame
	if BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail("wedding processional started during the parent reaction shot")
		return
	BGMPlayer.begin_story_event(wedding_walk_ev, "cg_romance_wedding_daeun_small")
	BGMPlayer.play_scene_paragraph_music(wedding_walk_ev, "cg_romance_wedding_daeun_small", 0)
	await get_tree().create_timer(0.18).timeout
	if BGMPlayer._current_key != "wedding_processional" or not BGMPlayer._player_a.playing:
		_fail("wedding processional did not start on the bride entrance paragraph")
		return
	var processional_pos: float = BGMPlayer._player_a.get_playback_position()
	BGMPlayer.begin_story_event(wedding_aisle_ev, "cg_romance_wedding_daeun_small_close")
	BGMPlayer.play_scene_paragraph_music(wedding_aisle_ev, "cg_romance_wedding_daeun_small_close", 0)
	await get_tree().process_frame
	var continued_processional_pos: float = BGMPlayer._player_a.get_playback_position()
	if continued_processional_pos + 0.05 < processional_pos:
		_fail("wedding processional restarted across the scene chain: %.3f -> %.3f" % [
			processional_pos, continued_processional_pos])
		return

	# 실제 주거를 배경으로 쓰는 장면도 매니페스트가 명시한 창밖 비를
	# 우선한다. 네 링크 사이에서 같은 룸톤과 친밀한 곡을 되감지 않는다.
	BGMPlayer.enter_ambient_bed(0.0)
	var first_night_ev: Dictionary = DataRegistry.find_event("arc_daeun_first_night")
	var first_night_branch: Dictionary = DataRegistry.find_event("arc_daeun_first_night_silence")
	if first_night_ev.is_empty() or first_night_branch.is_empty():
		_fail("Daeun first-night scene audio fixtures are missing")
		return
	BGMPlayer.update_event_ambience(first_night_ev)
	BGMPlayer.begin_story_event(first_night_ev)
	BGMPlayer.play_scene_paragraph_music(first_night_ev, "", 0)
	await get_tree().create_timer(0.18).timeout
	if BGMPlayer._current_ambience_key != "rain_room" \
			or BGMPlayer._current_key != "intimate" or not BGMPlayer._player_a.playing:
		_fail("Daeun first night did not start the authored rain-room intimate bed")
		return
	var rain_room_pos := BGMPlayer._ambience_player.get_playback_position()
	var intimate_pos := BGMPlayer._player_a.get_playback_position()
	BGMPlayer.update_event_ambience(first_night_branch)
	BGMPlayer.begin_story_event(first_night_branch)
	BGMPlayer.play_scene_paragraph_music(first_night_branch, "", 0)
	await get_tree().process_frame
	if BGMPlayer._current_ambience_key != "rain_room" \
			or BGMPlayer._ambience_player.get_playback_position() + 0.05 < rain_room_pos:
		_fail("Daeun first-night rain room restarted across the scene chain")
		return
	if BGMPlayer._current_key != "intimate" \
			or BGMPlayer._player_a.get_playback_position() + 0.05 < intimate_pos:
		_fail("Daeun first-night music restarted across the scene chain")
		return

	# 상철의 첫 호의는 정체를 미리 규정하지 않는다. 같은 사무실 룸톤만
	# 세 링크에 이어지고, 훗날 대면 장면의 reckoning 곡은 아직 나오지 않는다.
	BGMPlayer.enter_ambient_bed(0.0)
	var sangchul_meet: Dictionary = DataRegistry.find_event("arc_sangchul_01_meet")
	var sangchul_measure: Dictionary = DataRegistry.find_event("arc_sangchul_01_measure")
	if sangchul_meet.is_empty() or sangchul_measure.is_empty():
		_fail("Sangchul first-meeting scene audio fixtures are missing")
		return
	BGMPlayer.update_event_ambience(sangchul_meet)
	BGMPlayer.begin_story_event(sangchul_meet)
	BGMPlayer.play_scene_paragraph_music(sangchul_meet, "", 0)
	await get_tree().create_timer(0.18).timeout
	if BGMPlayer._current_ambience_key != "office" \
			or BGMPlayer._music_mode != "ambient" or not BGMPlayer._current_key.is_empty() \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail("Sangchul first meeting telegraphed a score instead of office room tone")
		return
	var sangchul_office_pos := BGMPlayer._ambience_player.get_playback_position()
	BGMPlayer.update_event_ambience(sangchul_measure)
	BGMPlayer.begin_story_event(sangchul_measure)
	BGMPlayer.play_scene_paragraph_music(sangchul_measure, "", 0)
	await get_tree().process_frame
	if BGMPlayer._current_ambience_key != "office" \
			or BGMPlayer._ambience_player.get_playback_position() + 0.05 < sangchul_office_pos:
		_fail("Sangchul first-meeting office ambience restarted across the chain")
		return
	if BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail("Sangchul first-meeting branch started directive music")
		return

	# 상철의 정체는 조사 도중 음악으로 먼저 폭로하지 않는다. 실제 현재
	# 주거의 룸톤이 이어지다가, 두 기록이 합쳐지는 마지막 판단에서만
	# reckoning이 시작된다.
	BGMPlayer.enter_ambient_bed(0.0)
	var sangchul_deduction: Dictionary = DataRegistry.find_event("arc_sangchul_deduction")
	var sangchul_case: Dictionary = DataRegistry.find_event("arc_sangchul_deduction_case")
	var sangchul_decision: Dictionary = DataRegistry.find_event("arc_sangchul_deduction_decision")
	var whole_picture: Dictionary = DataRegistry.find_event("hidden_whole_picture")
	if sangchul_deduction.is_empty() or sangchul_case.is_empty() \
			or sangchul_decision.is_empty() or whole_picture.is_empty():
		_fail("Sangchul deduction scene audio fixtures are missing")
		return
	GameState.housing = "gosiwon"
	BGMPlayer.update_event_ambience(sangchul_deduction)
	if BGMPlayer._current_ambience_key != "room":
		_fail("Sangchul deduction did not resolve goshiwon room tone")
		return
	GameState.housing = "oneroom"
	BGMPlayer.update_event_ambience(sangchul_deduction)
	BGMPlayer.begin_story_event(sangchul_deduction)
	BGMPlayer.play_scene_paragraph_music(sangchul_deduction, "", 0)
	await get_tree().create_timer(0.18).timeout
	if BGMPlayer._current_ambience_key != "oneroom" \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail("Sangchul deduction prelude exposed music or the wrong home ambience")
		return
	var deduction_room_pos := BGMPlayer._ambience_player.get_playback_position()
	BGMPlayer.update_event_ambience(sangchul_case)
	BGMPlayer.begin_story_event(sangchul_case)
	BGMPlayer.play_scene_paragraph_music(sangchul_case, "", 0)
	await get_tree().process_frame
	if BGMPlayer._current_ambience_key != "oneroom" \
			or BGMPlayer._ambience_player.get_playback_position() + 0.05 < deduction_room_pos:
		_fail("Sangchul deduction home ambience restarted across the evidence chain")
		return
	if BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail("Sangchul evidence branch started reckoning before the final decision")
		return
	var evidence_room_pos := BGMPlayer._ambience_player.get_playback_position()
	BGMPlayer.update_event_ambience(sangchul_decision)
	BGMPlayer.begin_story_event(sangchul_decision)
	BGMPlayer.play_scene_paragraph_music(sangchul_decision, "", 0)
	await get_tree().create_timer(0.18).timeout
	if BGMPlayer._current_key != "reckoning" or not BGMPlayer._player_a.playing:
		_fail("Sangchul final deduction did not punctuate the joined evidence")
		return
	if BGMPlayer._current_ambience_key != "oneroom" \
			or BGMPlayer._ambience_player.get_playback_position() + 0.05 < evidence_room_pos:
		_fail("Sangchul final deduction restarted or replaced the home ambience")
		return
	GameState.housing = "apartment"
	BGMPlayer.update_event_ambience(whole_picture)
	if BGMPlayer._current_ambience_key != "apartment":
		_fail("whole-picture epilogue did not resolve the current apartment ambience")
		return

	# 신부 입장 반응은 장면 진입음이 아니라 해당 문단에서 한 번만 겹친다.
	AudioManager.begin_story_audio_event("arc_daeun_wedding_walk")
	AudioManager.play_scene_paragraph_cues(
		"arc_daeun_wedding_walk", "cg_romance_wedding_daeun_small", 1)
	await get_tree().process_frame
	if not _sfx_stream_playing("wedding_applause"):
		_fail("wedding applause did not start on its authored paragraph")
		return
	await get_tree().create_timer(0.42).timeout
	if not _sfx_stream_playing("wedding_cheer"):
		_fail("wedding cheer did not layer after the applause")
		return

	# 엔딩 CG도 엔딩 음악 아래에 그림의 실제 장소음을 유지한다.
	BGMPlayer.on_ending("with_daeun", "cg_ending_with_daeun")
	await get_tree().process_frame
	if BGMPlayer._current_ambience_key != "oneroom" or not BGMPlayer._ambience_player.playing:
		_fail("ending CG did not apply its authored place ambience")
		return

	BGMPlayer.start_menu()
	await get_tree().create_timer(0.15).timeout
	BGMPlayer.start_menu()
	if BGMPlayer._current_key != "menu" or BGMPlayer._music_mode != "menu":
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

	print("BGM_CONTINUITY_OK mode=%s key=%s ambience=%s" % [
		BGMPlayer._music_mode, BGMPlayer._current_key, BGMPlayer._current_ambience_key])
	get_tree().quit(0)

func _fail(msg: String) -> void:
	push_error("BGM_CONTINUITY_FAIL " + msg)
	get_tree().quit(1)

func _sfx_stream_playing(sound_id: String) -> bool:
	var expected: AudioStream = AudioManager._sounds.get(sound_id)
	if expected == null:
		return false
	for player: AudioStreamPlayer in AudioManager._pool:
		if player.playing and player.stream == expected:
			return true
	return false
