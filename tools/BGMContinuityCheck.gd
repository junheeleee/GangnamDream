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
	if not _check_presentation_home_contract():
		return

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
	var neutral_room_db := BGMPlayer._ambience_target_db()
	var neutral_human_db := BGMPlayer._human_ambience_target_db()
	if neutral_room_db < -12.0 or neutral_room_db > -8.0:
		_fail("default room-tone gain is outside the audible mix window: %.2f dB" % neutral_room_db)
		return
	if neutral_human_db < -10.0 or neutral_human_db > -6.0:
		_fail("default human-presence gain is outside the audible mix window: %.2f dB" % neutral_human_db)
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
	if BGMPlayer._human_ambience_target_db() > neutral_human_db - 12.0:
		_fail("dark moral band did not remove enough human presence")
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

	# 프롤로그의 감정 원점은 창원 집 룸톤 위에서 가족 모티프가 문 뒤의
	# 목소리와 함께 늦게 들어온다. 세 링크 사이에서는 재생 위치를 보존한다.
	var knee_door: Dictionary = DataRegistry.find_event("story_knee_door")
	var knee_witness: Dictionary = DataRegistry.find_event("story_knee_witness")
	var knee_choice: Dictionary = DataRegistry.find_event("story_knee_choice")
	if knee_door.is_empty() or knee_witness.is_empty() or knee_choice.is_empty():
		_fail("prologue knee scene audio fixtures are missing")
		return
	BGMPlayer.update_event_ambience(knee_door)
	BGMPlayer.begin_story_event(knee_door)
	BGMPlayer.play_scene_paragraph_music(knee_door, "", 0)
	await get_tree().process_frame
	if BGMPlayer._current_ambience_key != "family_home" \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail("prologue knee scene did not establish family-home silence first")
		return
	BGMPlayer.play_scene_paragraph_music(knee_door, "", 2)
	await get_tree().create_timer(0.18).timeout
	if BGMPlayer._current_key != "family" or not BGMPlayer._player_a.playing:
		_fail("family motif did not enter behind the prologue doorway")
		return
	var family_pos := BGMPlayer._player_a.get_playback_position()
	for knee_link in [knee_witness, knee_choice]:
		BGMPlayer.update_event_ambience(knee_link)
		BGMPlayer.begin_story_event(knee_link)
		BGMPlayer.play_scene_paragraph_music(knee_link, "", 1)
		await get_tree().process_frame
		if BGMPlayer._current_key != "family" \
				or BGMPlayer._player_a.get_playback_position() + 0.05 < family_pos:
			_fail("family motif restarted across the prologue memory chain")
			return
		family_pos = BGMPlayer._player_a.get_playback_position()

	# 24주 마지막 청구서는 세 개의 구현 링크지만 한 장면이다. 첫 문단의
	# 종이 소리 뒤에 reckoning이 들어오고, 결정과 수첩 링크는 같은 주거
	# 룸톤과 곡의 재생 위치를 이어받는다. 언어 재바인딩은 이미 지난 물리음을
	# 다시 큐에 넣지 않는다.
	BGMPlayer.enter_ambient_bed(0.0)
	GameState.housing = "gosiwon"
	GameState.month = 6
	var first_bill_opening: Dictionary = DataRegistry.find_event(
		"v2_demo_first_bill_opening")
	var first_bill_decision: Dictionary = DataRegistry.find_event(
		"v2_demo_first_bill")
	var first_bill_ledger: Dictionary = DataRegistry.find_event(
		"v2_demo_first_bill_ledger")
	if first_bill_opening.is_empty() or first_bill_decision.is_empty() \
			or first_bill_ledger.is_empty():
		_fail("first-bill continuous-scene audio fixtures are missing")
		return

	BGMPlayer.update_event_ambience(first_bill_opening)
	BGMPlayer.begin_story_event(first_bill_opening)
	AudioManager.begin_story_audio_event("v2_demo_first_bill_opening")
	BGMPlayer.play_scene_paragraph_music(first_bill_opening, "", 0)
	AudioManager.play_scene_paragraph_cues(
		"v2_demo_first_bill_opening", "", 0)
	await get_tree().process_frame
	if BGMPlayer._current_ambience_key != "room" \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail("first-bill opening did not establish the live room before music")
		return
	if _sfx_stream_count("paper_handle") != 1 \
			or AudioManager._story_audio_seen.size() != 1:
		_fail("first-bill opening did not queue exactly one paper handle")
		return
	var paper_cue_token := (
		"v2_demo_first_bill_opening::description:0:0:paper_handle")
	if not AudioManager._story_audio_seen.has(paper_cue_token):
		_fail("first-bill paper cue was not owned by opening paragraph 0")
		return
	var paper_play_ms := int(AudioManager._last_sfx_ms.get(
		"paper_handle", -1))
	var opening_audio_generation := AudioManager._story_audio_generation
	await get_tree().create_timer(0.40).timeout
	var original_audio_language := LocaleManager.language
	var alternate_audio_language := (
		"en" if original_audio_language == "ko" else "ko")
	LocaleManager.set_language(alternate_audio_language)
	var localized_first_bill_opening: Dictionary = DataRegistry.find_event(
		"v2_demo_first_bill_opening")
	AudioManager.play_scene_paragraph_cues(
		"v2_demo_first_bill_opening", "", 0)
	LocaleManager.set_language(original_audio_language)
	if localized_first_bill_opening.is_empty() \
			or str(localized_first_bill_opening.get("id", "")) \
			!= "v2_demo_first_bill_opening":
		_fail("first-bill opening could not rebind across text locales")
		return
	if AudioManager._story_audio_generation != opening_audio_generation \
			or AudioManager._story_audio_seen.size() != 1 \
			or int(AudioManager._last_sfx_ms.get("paper_handle", -1)) \
			!= paper_play_ms \
			or _sfx_stream_count("paper_handle") > 1:
		_fail("locale re-render duplicated the first-bill paper handle")
		return

	BGMPlayer.play_scene_paragraph_music(first_bill_opening, "", 1)
	await get_tree().create_timer(0.18).timeout
	if BGMPlayer._current_key != "reckoning" or not BGMPlayer._player_a.playing:
		_fail("reckoning did not enter on the first-bill opening hook")
		return
	var first_bill_music_pos := BGMPlayer._player_a.get_playback_position()
	var first_bill_room_pos := BGMPlayer._ambience_player.get_playback_position()

	BGMPlayer.update_event_ambience(first_bill_decision)
	BGMPlayer.begin_story_event(first_bill_decision)
	AudioManager.begin_story_audio_event("v2_demo_first_bill")
	BGMPlayer.play_scene_paragraph_music(first_bill_decision, "", 0)
	await get_tree().process_frame
	var decision_music_pos := BGMPlayer._player_a.get_playback_position()
	if BGMPlayer._current_key != "reckoning" \
			or decision_music_pos + 0.05 < first_bill_music_pos:
		_fail("reckoning restarted between the first-bill opening and decision")
		return
	if BGMPlayer._current_ambience_key != "room" \
			or BGMPlayer._ambience_player.get_playback_position() + 0.05 \
			< first_bill_room_pos:
		_fail("live room tone restarted between first-bill opening and decision")
		return

	BGMPlayer.update_event_ambience(first_bill_ledger)
	BGMPlayer.begin_story_event(first_bill_ledger)
	AudioManager.begin_story_audio_event("v2_demo_first_bill_ledger")
	BGMPlayer.play_scene_paragraph_music(first_bill_ledger, "", 0)
	await get_tree().process_frame
	var ledger_music_pos := BGMPlayer._player_a.get_playback_position()
	if BGMPlayer._current_key != "reckoning" \
			or ledger_music_pos + 0.05 < decision_music_pos:
		_fail("reckoning restarted between the first-bill decision and ledger")
		return
	if BGMPlayer._current_ambience_key != "room" \
			or BGMPlayer._ambience_player.get_playback_position() + 0.05 \
			< first_bill_room_pos:
		_fail("live room tone restarted before the first-bill ledger")
		return

	AudioManager.play_scene_result_paragraph_cues(
		"v2_demo_first_bill_ledger", "", 0, 0)
	await get_tree().process_frame
	if _sfx_stream_count("pen_write") != 1 \
			or AudioManager._story_audio_seen.size() != 1:
		_fail("first-bill ledger did not queue exactly one pen write")
		return
	var pen_cue_token := (
		"v2_demo_first_bill_ledger::result:0:0:0:pen_write")
	if not AudioManager._story_audio_seen.has(pen_cue_token):
		_fail("first-bill pen cue was not owned by ledger result paragraph 0")
		return
	var pen_play_ms := int(AudioManager._last_sfx_ms.get("pen_write", -1))
	var ledger_audio_generation := AudioManager._story_audio_generation
	await get_tree().create_timer(0.68).timeout
	original_audio_language = LocaleManager.language
	alternate_audio_language = (
		"en" if original_audio_language == "ko" else "ko")
	LocaleManager.set_language(alternate_audio_language)
	var localized_first_bill_ledger: Dictionary = DataRegistry.find_event(
		"v2_demo_first_bill_ledger")
	AudioManager.play_scene_result_paragraph_cues(
		"v2_demo_first_bill_ledger", "", 0, 0)
	LocaleManager.set_language(original_audio_language)
	if localized_first_bill_ledger.is_empty() \
			or str(localized_first_bill_ledger.get("id", "")) \
			!= "v2_demo_first_bill_ledger":
		_fail("first-bill ledger could not rebind across text locales")
		return
	if AudioManager._story_audio_generation != ledger_audio_generation \
			or AudioManager._story_audio_seen.size() != 1 \
			or int(AudioManager._last_sfx_ms.get("pen_write", -1)) != pen_play_ms \
			or _sfx_stream_count("pen_write") > 1:
		_fail("locale re-render duplicated the first-bill pen write")
		return
	if BGMPlayer._current_key != "reckoning" \
			or BGMPlayer._player_a.get_playback_position() + 0.05 \
			< ledger_music_pos:
		_fail("locale re-render restarted the first-bill reckoning cue")
		return

	# 데모의 마지막 현수 시험 장면은 무음으로 버려두지 않는다. 문과 발소리
	# 뒤에 현수 모티프가 들어오며 다음 결과를 기다리게 해야 한다.
	BGMPlayer.enter_ambient_bed(0.0)
	var exam_day: Dictionary = DataRegistry.find_event("hyunsu_exam_day")
	if exam_day.is_empty():
		_fail("Hyunsu exam-day audio fixture is missing")
		return
	BGMPlayer.update_event_ambience(exam_day)
	BGMPlayer.begin_story_event(exam_day)
	BGMPlayer.play_scene_paragraph_music(exam_day, "", 0)
	await get_tree().process_frame
	if BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail("Hyunsu motif started before the corridor established")
		return
	BGMPlayer.play_scene_paragraph_music(exam_day, "", 1)
	await get_tree().create_timer(0.18).timeout
	if BGMPlayer._current_key != "hyunsu" or not BGMPlayer._player_a.playing:
		_fail("Hyunsu exam-day hook remained unscored")
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
			or not BGMPlayer._current_human_ambience_key.is_empty() \
			or BGMPlayer._human_ambience_player.playing \
			or BGMPlayer._music_mode != "ambient" or not BGMPlayer._current_key.is_empty() \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail("Sangchul first meeting added people or score to the private office room tone")
		return
	var sangchul_office_pos := BGMPlayer._ambience_player.get_playback_position()
	BGMPlayer.update_event_ambience(sangchul_measure)
	BGMPlayer.begin_story_event(sangchul_measure)
	BGMPlayer.play_scene_paragraph_music(sangchul_measure, "", 0)
	await get_tree().process_frame
	if BGMPlayer._current_ambience_key != "office" \
			or not BGMPlayer._current_human_ambience_key.is_empty() \
			or BGMPlayer._human_ambience_player.playing \
			or BGMPlayer._ambience_player.get_playback_position() + 0.05 < sangchul_office_pos:
		_fail("Sangchul first-meeting private office ambience restarted or gained a human layer")
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

	# 카지노 초대는 상철이 방 안에 들어온 대면 장면이 아니라 문자다.
	# 실제 주거 룸톤만 이어지고, 수락 뒤 버스가 도착한 다음에야 거리로 바뀐다.
	BGMPlayer.enter_ambient_bed(0.0)
	var casino_invite: Dictionary = DataRegistry.find_event("arc_sangchul_casino_invite")
	var casino_people: Dictionary = DataRegistry.find_event("arc_sangchul_casino_people")
	var casino_cost: Dictionary = DataRegistry.find_event("arc_sangchul_casino_cost")
	var casino_reply: Dictionary = DataRegistry.find_event("arc_sangchul_casino_decision")
	var casino_arrival: Dictionary = DataRegistry.find_event("arc_sangchul_casino_arrival")
	if casino_invite.is_empty() or casino_people.is_empty() or casino_cost.is_empty() \
			or casino_reply.is_empty() or casino_arrival.is_empty():
		_fail("Sangchul casino invitation audio fixtures are missing")
		return
	GameState.housing = "gosiwon"
	BGMPlayer.update_event_ambience(casino_invite)
	if BGMPlayer._current_ambience_key != "room":
		_fail("Sangchul casino invitation did not resolve goshiwon room tone")
		return
	GameState.housing = "oneroom"
	BGMPlayer.update_event_ambience(casino_invite)
	BGMPlayer.begin_story_event(casino_invite)
	BGMPlayer.play_scene_paragraph_music(casino_invite, "", 0)
	await get_tree().create_timer(0.18).timeout
	if BGMPlayer._current_ambience_key != "oneroom" \
			or BGMPlayer._music_mode != "ambient" or not BGMPlayer._current_key.is_empty() \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail("Sangchul casino text exposed directive music or the wrong home ambience")
		return
	var invite_room_pos := BGMPlayer._ambience_player.get_playback_position()
	for invitation_link in [casino_people, casino_cost, casino_reply]:
		BGMPlayer.update_event_ambience(invitation_link)
		BGMPlayer.begin_story_event(invitation_link)
		BGMPlayer.play_scene_paragraph_music(invitation_link, "", 0)
		await get_tree().process_frame
		if BGMPlayer._current_ambience_key != "oneroom" \
				or BGMPlayer._ambience_player.get_playback_position() + 0.05 < invite_room_pos:
			_fail("Sangchul casino home ambience restarted across the invitation chain")
			return
		if BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
			_fail("Sangchul casino invitation started reckoning before arrival")
			return
		invite_room_pos = BGMPlayer._ambience_player.get_playback_position()
	BGMPlayer.update_event_ambience(casino_arrival)
	BGMPlayer.begin_story_event(casino_arrival)
	BGMPlayer.play_scene_paragraph_music(casino_arrival, "", 0)
	await get_tree().process_frame
	if BGMPlayer._current_ambience_key != "street" \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail("Sangchul casino bus arrival did not switch cleanly to exterior ambience")
		return

	# 현수의 취업 문자는 현재 집에서 조용히 이어지고, 실제 재회에서만 사람 소리와 음악이 열린다.
	BGMPlayer.enter_ambient_bed(0.0)
	var hyunsu_message: Dictionary = DataRegistry.find_event("hyunsu_reunion_later")
	var hyunsu_photo: Dictionary = DataRegistry.find_event("hyunsu_reunion_photo")
	var hyunsu_memory: Dictionary = DataRegistry.find_event("hyunsu_reunion_memory")
	var hyunsu_meet: Dictionary = DataRegistry.find_event("hyunsu_reunion_meet")
	if hyunsu_message.is_empty() or hyunsu_photo.is_empty() or hyunsu_memory.is_empty() \
			or hyunsu_meet.is_empty():
		_fail("Hyunsu reunion audio fixtures are missing")
		return
	GameState.housing = "oneroom"
	BGMPlayer.update_event_ambience(hyunsu_message)
	BGMPlayer.begin_story_event(hyunsu_message)
	BGMPlayer.play_scene_paragraph_music(hyunsu_message, "", 0)
	await get_tree().create_timer(0.18).timeout
	if BGMPlayer._current_ambience_key != "oneroom" \
			or BGMPlayer._music_mode != "ambient" or not BGMPlayer._current_key.is_empty() \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail("Hyunsu employment message exposed music or the wrong home ambience")
		return
	var hyunsu_room_pos := BGMPlayer._ambience_player.get_playback_position()
	for message_link in [hyunsu_photo, hyunsu_memory]:
		BGMPlayer.update_event_ambience(message_link)
		BGMPlayer.begin_story_event(message_link)
		BGMPlayer.play_scene_paragraph_music(message_link, "", 0)
		await get_tree().process_frame
		if BGMPlayer._current_ambience_key != "oneroom" \
				or BGMPlayer._ambience_player.get_playback_position() + 0.05 < hyunsu_room_pos:
			_fail("Hyunsu message chain restarted or replaced the home ambience")
			return
		if BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
			_fail("Hyunsu message chain started intimate music before the meeting")
			return
		hyunsu_room_pos = BGMPlayer._ambience_player.get_playback_position()
	BGMPlayer.update_event_ambience(hyunsu_meet)
	BGMPlayer.begin_story_event(hyunsu_meet)
	BGMPlayer.play_scene_paragraph_music(hyunsu_meet, "", 0)
	await get_tree().create_timer(0.18).timeout
	if BGMPlayer._current_ambience_key != "cafe" \
			or BGMPlayer._current_key != "intimate" \
			or not (BGMPlayer._player_a.playing or BGMPlayer._player_b.playing):
		_fail("Hyunsu physical reunion did not open with human ambience and intimate music")
		return

	# 마지막 상환은 고시원 베드를 끌고 오지 않고 공공 창구로 바뀐다.
	# 호출음은 대기 설명이 아니라 147번이 실제로 불리는 결과 문단에서 한 번만 난다.
	var last_payment_wait: Dictionary = DataRegistry.find_event("story_last_payment_wait")
	if last_payment_wait.is_empty():
		_fail("last-payment queue audio fixture is missing")
		return
	BGMPlayer.set_ambience("room")
	await get_tree().create_timer(0.08).timeout
	var goshiwon_stream: AudioStream = BGMPlayer._ambience_player.stream
	BGMPlayer.update_event_ambience(last_payment_wait)
	await get_tree().create_timer(0.18).timeout
	if BGMPlayer._current_ambience_key != "public_office" \
			or not BGMPlayer._ambience_player.playing \
			or BGMPlayer._ambience_player.stream == goshiwon_stream:
		_fail("last-payment queue retained the goshiwon ambience")
		return
	AudioManager.begin_story_audio_event("story_last_payment_wait")
	AudioManager.play_scene_paragraph_cues("story_last_payment_wait", "", 1)
	await get_tree().process_frame
	if _sfx_stream_count("queue_chime") != 0:
		_fail("queue chime played before number 147 was called")
		return
	AudioManager.play_scene_result_paragraph_cues(
		"story_last_payment_wait", "", 0, 0)
	await get_tree().create_timer(0.30).timeout
	if _sfx_stream_count("queue_chime") != 1:
		_fail("number 147 result did not play exactly one queue chime")
		return
	AudioManager.play_scene_result_paragraph_cues(
		"story_last_payment_wait", "", 0, 0)
	await get_tree().process_frame
	if _sfx_stream_count("queue_chime") != 1:
		_fail("number 147 result replayed its queue chime")
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

	# 번역 본문은 장소 계약이 아니다. 화면 렌더러가 고른 동일 배경 ID가
	# 주어지면 한국어/영어 문구가 달라도 같은 공간음이어야 한다.
	var localized_background_cases := [
		[{
			"id": "qa_localized_meal_ko",
			"title": "첫 끼니",
			"description": "비 오는 밤, 편의점에 들어갔다.",
			"tags": ["night"],
		}, "convenience_night", "convenience"],
		[{
			"id": "qa_localized_meal_en",
			"title": "First Meal",
			"description": "He steps into the store after midnight.",
			"tags": ["night"],
		}, "convenience_night", "convenience"],
		[{
			"id": "qa_localized_call_ko",
			"title": "카페에서 걸려온 전화",
			"description": "그날의 카페를 떠올리며 전화를 받았다.",
			"tags": [],
		}, "goshiwon_room", "room"],
		[{
			"id": "qa_localized_call_en",
			"title": "An Incoming Call",
			"description": "The unknown number lights the phone.",
			"tags": [],
		}, "goshiwon_room", "room"],
		[{
			"id": "qa_localized_gangnam_ko",
			"title": "처음 혼자 간 강남",
			"description": "지하철에서 내려 건물 사이를 걸었다.",
			"tags": [],
		}, "gangnam_day", "street"],
		[{
			"id": "qa_localized_gangnam_en",
			"title": "First Time in Gangnam Alone",
			"description": "He walks between the towers.",
			"tags": [],
		}, "gangnam_day", "street"],
	]
	for case in localized_background_cases:
		var actual := BGMPlayer._pick_ambience(case[0], str(case[1]))
		if actual != str(case[2]):
			_fail("rendered-background ambience mismatch: %s expected %s got %s" % [
				case[0].get("id", ""), case[2], actual])
			return

	print("BGM_CONTINUITY_OK mode=%s key=%s ambience=%s" % [
		BGMPlayer._music_mode, BGMPlayer._current_key, BGMPlayer._current_ambience_key])
	get_tree().quit(0)

func _fail(msg: String) -> void:
	push_error("BGM_CONTINUITY_FAIL " + msg)
	get_tree().quit(1)

func _check_presentation_home_contract() -> bool:
	var original_housing := GameState.housing
	var original_flags := GameState.flags.duplicate(true)
	var original_state := JSON.stringify(GameState.serialize())

	# 제안/약혼만으로는 실제 신혼집을 앞당기지 않는다.
	GameState.flags = {
		"daeun_married": true,
		"arc_daeun_proposal_seen": true,
	}
	if GameState.uses_daeun_shared_home_presentation() \
			or not GameState.get_presentation_home_background_id().is_empty() \
			or ImageRegistry.resolve_contextual_background_id("current_housing") \
			!= "goshiwon_room" \
			or GameState.get_presentation_home_ambience_housing_id() != "gosiwon" \
			or BGMPlayer._resolve_dynamic_ambience_key("current_housing") != "room":
		_fail("proposal-only state entered Daeun's shared-home presentation")
		return false

	# 실제 결혼 뒤에만 같은 파생 사실을 배경과 생활음이 함께 읽는다.
	GameState.flags = {"arc_daeun_wedding_day_seen": true}
	var economic_before := _presentation_home_economic_bytes()
	if not GameState.uses_daeun_shared_home_presentation() \
			or GameState.get_presentation_home_background_id() \
			!= "daeun_newlywed_home" \
			or ImageRegistry.resolve_contextual_background_id("current_housing") \
			!= "daeun_newlywed_home" \
			or GameState.get_presentation_home_ambience_housing_id() != "oneroom" \
			or BGMPlayer._active_housing_id() != "oneroom" \
			or BGMPlayer._resolve_dynamic_ambience_key("current_housing") != "oneroom":
		_fail("completed Daeun wedding did not resolve one shared presentation home")
		return false
	if _presentation_home_economic_bytes() != economic_before:
		_fail("presentation-home resolution mutated economic state")
		return false

	# raw apartment를 가진 경로도 표현 전환 때문에 월세·자산·소유 상태를 바꾸지 않는다.
	GameState.housing = "apartment"
	economic_before = _presentation_home_economic_bytes()
	ImageRegistry.resolve_contextual_background_id("current_housing")
	BGMPlayer._resolve_dynamic_ambience_key("current_housing")
	if _presentation_home_economic_bytes() != economic_before \
			or GameState.housing != "apartment" \
			or ImageRegistry.resolve_contextual_background_id("current_housing") \
			!= "daeun_newlywed_home":
		_fail("Daeun presentation home rewrote apartment economics")
		return false

	# 이혼과 지연 경로는 원래 raw housing 해석으로 돌아간다.
	GameState.housing = "gosiwon"
	GameState.flags = {
		"arc_daeun_wedding_day_seen": true,
		"daeun_divorced": true,
	}
	if GameState.uses_daeun_shared_home_presentation() \
			or ImageRegistry.resolve_contextual_background_id("current_housing") \
			!= "goshiwon_room" \
			or BGMPlayer._resolve_dynamic_ambience_key("current_housing") != "room":
		_fail("Daeun divorce kept the shared-home presentation active")
		return false
	GameState.flags = {
		"jiyeon_romance_started": true,
		"arc_jiyeon_wedding_gap_seen": true,
		"arc_jiyeon_wedding_night_seen": true,
	}
	if GameState.uses_daeun_shared_home_presentation() \
			or ImageRegistry.resolve_contextual_background_id("current_housing") \
			!= "goshiwon_room" \
			or BGMPlayer._resolve_dynamic_ambience_key("current_housing") != "room":
		_fail("Jiyeon route borrowed Daeun's shared-home presentation")
		return false

	# 갤러리는 저장 당시 raw housing을 계속 고정한다.
	GameState.flags = {"arc_daeun_wedding_day_seen": true}
	if not BGMPlayer.begin_gallery_replay({
		"turn": 240,
		"housing": "gangnam",
		"moral_tint": 0.0,
	}):
		_fail("valid gallery housing snapshot was rejected")
		return false
	if BGMPlayer._active_housing_id() != "gangnam":
		_fail("gallery snapshot borrowed the live Daeun presentation home")
		return false
	BGMPlayer.end_gallery_replay()
	if BGMPlayer._active_housing_id() != "oneroom":
		_fail("live Daeun presentation home did not resume after gallery replay")
		return false

	GameState.housing = original_housing
	GameState.flags = original_flags
	if JSON.stringify(GameState.serialize()) != original_state:
		_fail("presentation-home contract did not restore its test fixture")
		return false
	return true

func _presentation_home_economic_bytes() -> String:
	return JSON.stringify({
		"housing": GameState.housing,
		"housing_expense": GameState.get_housing_expense(),
		"fixed_expense": GameState.fixed_expense,
		"money": GameState.money,
		"monthly_income": GameState.monthly_income,
		"loans": GameState.loans,
		"portfolio": GameState.portfolio,
		"inventory": GameState.inventory,
		"market_prices": GameState.market_prices,
		"price_history": GameState.price_history,
		"total_assets": GameState.get_total_asset_value(),
	})

func _sfx_stream_playing(sound_id: String) -> bool:
	var expected: AudioStream = AudioManager._sounds.get(sound_id)
	if expected == null:
		return false
	for player: AudioStreamPlayer in AudioManager._pool:
		if player.playing and player.stream == expected:
			return true
	return false

func _sfx_stream_count(sound_id: String) -> int:
	var expected: AudioStream = AudioManager._sounds.get(sound_id)
	if expected == null:
		return 0
	var count := 0
	for player: AudioStreamPlayer in AudioManager._pool:
		if player.playing and player.stream == expected:
			count += 1
	return count
