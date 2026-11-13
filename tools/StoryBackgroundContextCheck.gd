extends Node
## L2 only: exercise the real StoryMode node for exact authored
## location moves. This is deterministic regression evidence, never a
## substitute for the required normal-speed human M49-M60 replays.

const QA_PREFIX := "GangnamDream_StoryNameplateQA_"
const CHAPTER5_ROUTE := preload("res://systems/Chapter5CausalRoute.gd")
const BURNOUT_PRIOR_CHOICES := [2, 1, 0, 1]
const W202_EVENT := "callback_daeun_committed_gangnam_eve"
const W8_EVENT := "arc_temptation_fallout"
const W8_QA_SLOT := 9
const W8_BANK := "bank_service_counter_rainy_day"
const W8_BANK_EXIT := "bank_exterior_wet_day"
const W8_LOCKERS := "subway_station_coin_lockers"
const M14_BANK := "arc_y2_bank_limit_review"
const M14_COUNTER := "bank_loan_counter_day"
const M14_EXIT := "bank_loan_exit_day"
const M14_EXIT_LINE := {
	"ko": "문을 나설 때", "en": "He left with a document", "ja": "外へ出るとき",
	"zh-CN": "走出门时", "zh-TW": "走出銀行時",
}
const W8_ARRIVAL_TEXT := {
	"ko": ["은행을 나서자", "사흘 뒤"],
	"en": ["Outside the bank,", "Three days later,"],
	"ja": ["銀行を出ると、", "三日後、"],
	"zh-CN": ["走出银行时，", "三天后，"],
	"zh-TW": ["走出銀行時，", "三天後，"],
}
const CASES := [
	{
		"id": "arc_y5_burnout_check_reference",
		"root": "hospital_clinic_day",
		"root_ambience": "hospital",
		"results": ["hospital_clinic_day", "hospital_clinic_day", "hospital_clinic_day"],
		"result_ambience": ["hospital", "hospital", "hospital"],
	},
	{
		"id": "rare_wallet_executive",
		"root": "subway_station_stairs",
		"root_ambience": "subway",
		"results": ["subway_station_lost_found", "subway_station_stairs"],
		"result_ambience": ["subway", "subway"],
	},
	{
		"id": "chain_exec_meal_arrival",
		"root": "hanjeongsik_restaurant_day",
		"root_ambience": "cafe",
		"results": ["hanjeongsik_restaurant_day", "hanjeongsik_restaurant_day"],
		"result_ambience": ["cafe", "cafe"],
	},
	{
		"id": "arc_jiyeon_year5_news",
		"root": "hanjeongsik_restaurant_day",
		"root_ambience": "cafe",
		"results": ["hanjeongsik_restaurant_day", "street"],
		"result_ambience": ["cafe", "street"],
	},
	{
		"id": "yolo_spend_moment",
		"root": "convenience_store",
		"root_ambience": "convenience",
		"results": ["concert_hall_night", "convenience_store", "concert_hall_night"],
		"result_ambience": ["amusement", "convenience", "amusement"],
	},
	{
		"id": "chain_envelope_owner_return",
		"root": "convenience_night",
		"root_ambience": "convenience",
		"results": ["villa_renovation_day", "convenience_night"],
		"result_ambience": ["street", "convenience"],
	},
	{
		"id": "hidden_gangnam_open_house",
		"root": "gangnam_apartment",
		"root_ambience": "apartment",
		"results": ["current_housing", "subway"],
		"result_ambience": ["apartment", "subway"],
	},
	{
		"id": W202_EVENT, "turn": 202,
		"root": "current_housing",
		"root_ambience": "oneroom",
		"results": ["gukbap_restaurant_night", "current_housing"],
		"result_ambience": ["", "oneroom"],
	},
	{
		"id": "cafe_00", "turn": 6,
		"root": "cafe", "root_ambience": "cafe",
		"results": ["cafe", "cafe", "street_rainy"],
		"result_ambience": ["cafe", "cafe", "rain"],
	},
	{
		"id": "cafe_bluff_caught", "turn": 6,
		"auto_single_choice": true,
		"root": "cafe", "root_ambience": "cafe",
		"results": ["street_rainy"], "result_ambience": ["rain"],
	},
	{
		"id": "cafe_mind_01", "turn": 6,
		"root": "cafe", "root_ambience": "cafe",
		"results": ["cafe", "street_rainy"], "result_ambience": ["cafe", "rain"],
	},
]

const EXACT_PATHS := {
	"hospital_clinic_day": "res://assets/backgrounds/hospital_clinic_day.png",
	"subway_station_stairs": "res://assets/backgrounds/subway_station_stairs.png",
	"subway_station_lost_found": "res://assets/backgrounds/subway_station_lost_found.png",
	"hanjeongsik_restaurant_day": "res://assets/backgrounds/hanjeongsik_restaurant_day.png",
	"concert_hall_night": "res://assets/backgrounds/concert_hall_night.png",
	"villa_renovation_day": "res://assets/backgrounds/villa_renovation_day.png",
	"convenience_store": "res://assets/backgrounds/convenience_store_night_v2.png",
	"convenience_night": "res://assets/backgrounds/convenience_store_night_v2.png",
	"street": "res://assets/backgrounds/street_seoul_day.png",
	"street_rainy": "res://assets/backgrounds/seoul_rainy_street.png",
	W8_BANK: "res://assets/backgrounds/bank_service_counter_rainy_day.png",
	W8_BANK_EXIT: "res://assets/backgrounds/bank_exterior_wet_day.png",
	W8_LOCKERS: "res://assets/backgrounds/subway_station_coin_lockers.png",
	M14_COUNTER: "res://assets/backgrounds/bank_loan_counter_day.png",
	M14_EXIT: "res://assets/backgrounds/bank_loan_exit_day.png",
	"cafe": "res://assets/backgrounds/cafe_seoul.png",
	"gangnam_apartment": "res://assets/backgrounds/gangnam_apartment.png",
	"apartment": "res://assets/backgrounds/oneroom_apartment.png",
	"gukbap_restaurant_night": "res://assets/backgrounds/gukbap_restaurant_night.png",
	"subway": "res://assets/backgrounds/seoul_subway.png",
}

var _story: Control
var _failures := 0
var _cases := 0
var _intro_pages := 0
var _result_pages := 0
var _w8_cases := 0
var _w8_pages := 0
var _m14_cases := 0
var _m14_capture_dir := ""
var _w8_reloads := 0
var _w8_language_switches := 0
var _w202_silent_results := 0
var _context := "bootstrap"
var _w8_capture_dir := ""
var _w8_capture_start_msec := 0
var _w8_capture_shots := 0

func _ready() -> void:
	Engine.max_fps = 60
	var bootstrap_script := get_tree().get_script() as Script
	if bootstrap_script == null \
			or bootstrap_script.resource_path != "res://tools/StoryNameplateBootstrap.gd":
		_fail("exact pre-autoload isolation bootstrap required")
		get_tree().quit(1)
		return
	var qa_namespace := str(ProjectSettings.get_setting(
		"application/config/custom_user_dir_name", ""))
	if not bool(ProjectSettings.get_setting(
			"application/config/use_custom_user_dir", false)) \
			or not qa_namespace.begins_with(QA_PREFIX) \
			or not OS.get_user_data_dir().ends_with(qa_namespace):
		_fail("isolated QA user directory was not selected before autoloads")
		get_tree().quit(1)
		return
	print("STORY_NAMEPLATE_QA_USER_DIR=%s" % OS.get_user_data_dir())
	print("STORY_BACKGROUND_CONTEXT_SOURCE=%s" % ProjectSettings.globalize_path("res://"))
	await get_tree().process_frame
	SaveManager.set_setting("story_text_size", "standard")
	if OS.has_environment("GANGNAM_W8_CAPTURE_DIR"):
		await _capture_w8()
		return
	if OS.has_environment("GANGNAM_M14_BANK_CAPTURE_DIR"):
		await _capture_m14_bank()
		return
	for language in ["ko", "en"]:
		LocaleManager.set_language(language)
		for fixture_variant in CASES:
			var fixture: Dictionary = fixture_variant
			var results: Array = fixture["results"]
			for choice_index in range(results.size()):
				await _play_case(language, fixture, choice_index)
	for language in W8_ARRIVAL_TEXT:
		LocaleManager.set_language(language)
		for choice_index in range(2):
			await _play_w8_case(language, choice_index)
		for choice_index in range(3):
			await _play_m14_bank_case(language, choice_index)
	await _remove_story()
	await _stop_audio()
	if _cases != 48 or _intro_pages < 48 or _result_pages < 48:
		_fail("fixture inventory incomplete cases=%d intro_pages=%d result_pages=%d" % [
			_cases, _intro_pages, _result_pages])
	if _w8_cases != 10 or _w8_pages < 30 or _w8_reloads != 10 \
			or _w8_language_switches != 8:
		_fail("W8 fixture inventory incomplete cases=%d pages=%d reloads=%d language_switches=%d" % [
			_w8_cases, _w8_pages, _w8_reloads, _w8_language_switches])
	if _w202_silent_results != 2:
		_fail("W202 quiet result inventory incomplete: %d" % _w202_silent_results)
	if _m14_cases != 15:
		_fail("M14 bank branch inventory incomplete: %d" % _m14_cases)
	if _failures > 0:
		print("STORY_BACKGROUND_CONTEXT_CHECK_FAIL failures=%d cases=%d intro_pages=%d result_pages=%d" % [
			_failures, _cases, _intro_pages, _result_pages])
		get_tree().quit(1)
		return
	print("STORY_BACKGROUND_CONTEXT_W8_OK cases=%d pages=%d cold_cut_reloads=%d language_switches=%d" % [
		_w8_cases, _w8_pages, _w8_reloads, _w8_language_switches])
	print("STORY_BACKGROUND_CONTEXT_W202_OK silent_results=%d shared_profile_unchanged=1" % _w202_silent_results)
	print("STORY_BACKGROUND_CONTEXT_M14_OK cases=%d exact_exit=1 clean_beds=1" % _m14_cases)
	print("STORY_BACKGROUND_CONTEXT_CHECK_OK cases=%d intro_pages=%d result_pages=%d ko_en=1 choices=all live_storymode=1 settled_texture=1 ambience=1 human_gate=OPEN" % [
		_cases, _intro_pages, _result_pages])
	get_tree().quit(0)

func _capture_w8() -> void:
	_w8_capture_dir = OS.get_environment("GANGNAM_W8_CAPTURE_DIR")
	var language := OS.get_environment("GANGNAM_W8_CAPTURE_LANGUAGE")
	var output := DirAccess.open(_w8_capture_dir) if _w8_capture_dir.is_absolute_path() else null
	if output == null or not output.get_files().is_empty() or not output.get_directories().is_empty() \
			or language not in ["ko", "en"] or DisplayServer.get_name() == "headless":
		_fail("W8 capture requires a fresh absolute output, KO/EN and a real display")
		get_tree().quit(1)
		return
	OS.low_processor_usage_mode = false
	LocaleManager.set_language(language)
	var master_bus := AudioServer.get_bus_index("Master")
	# Godot 4.6.2's recorder exposes only its last effect instance. On a
	# surround bus this may be a silent rear pair, not the game's stereo mix.
	if master_bus < 0 or AudioServer.get_speaker_mode() != AudioServer.SPEAKER_MODE_STEREO:
		_fail("W8 recorder requires a stereo engine bus, got %s/%s" % [
			AudioServer.get_driver_name(), AudioServer.get_speaker_mode()])
		get_tree().quit(1)
		return
	for choice_index in range(2):
		await _remove_story()
		await _stop_audio()
		var record := AudioEffectRecord.new()
		var effect_index := AudioServer.get_bus_effect_count(master_bus)
		AudioServer.add_bus_effect(master_bus, record)
		_w8_capture_start_msec = Time.get_ticks_msec()
		record.set_recording_active(true)
		var previous_shots := _w8_capture_shots
		await _play_w8_case(language, choice_index)
		record.set_recording_active(false)
		var wav := record.get_recording()
		AudioServer.remove_bus_effect(master_bus, effect_index)
		var prefix := "%s_c%d" % [language, choice_index]
		if wav == null or wav.get_length() < 5.0 or not _w8_has_nonzero_pcm(wav.get_data()) \
				or wav.save_to_wav(_w8_capture_dir.path_join(prefix + "_master.wav")) != OK:
			_fail("W8 Master bus recording empty, short or unwritable: " + prefix)
		if _w8_capture_shots - previous_shots < 4:
			_fail("W8 capture missed a rendered boundary: " + prefix)
		for label in ["01_rain_call", "02_choices", "04_before_move", "05_after_move"]:
			if not FileAccess.file_exists(_w8_capture_dir.path_join("%s_%s.png" % [prefix, label])):
				_fail("W8 capture missed %s: %s" % [label, prefix])
		if _failures > 0:
			break
	await _remove_story()
	await _stop_audio()
	if _w8_cases != 2 or _w8_reloads != 0 or _w8_language_switches != 0:
		_fail("W8 capture must render two uninterrupted choices")
	if _failures == 0:
		print("W8_VIEWPORT_CAPTURE_OK language=%s paths=%d frames=%d audio=Master driver=%s" % [
			language, _w8_cases, _w8_capture_shots, AudioServer.get_driver_name()])
	get_tree().quit(0 if _failures == 0 else 1)

func _w8_has_nonzero_pcm(bytes: PackedByteArray) -> bool:
	for value in bytes:
		if value != 0:
			return true
	return false

func _mark_w8_capture(label: String) -> void:
	print("W8_CAPTURE %s t=%.3f %s" % [
		_context, float(Time.get_ticks_msec() - _w8_capture_start_msec) / 1000.0, label])

func _save_w8_capture(language: String, choice_index: int, label: String) -> void:
	var path := _w8_capture_dir.path_join("%s_c%d_%s.png" % [language, choice_index, label])
	if not await _save_viewport_frame(path):
		return
	_w8_capture_shots += 1
	_mark_w8_capture(label)

func _save_viewport_frame(path: String) -> bool:
	# Wait for the real post-draw buffer and discard the first OpenGL readback.
	for _draw in range(4):
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
	var texture := get_viewport().get_texture()
	if texture == null:
		_fail("viewport has no render texture")
		return false
	var _prime_readback := texture.get_image()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var frame := texture.get_image()
	if frame == null or frame.is_empty() or frame.save_png(path) != OK:
		_fail("viewport capture failed: " + path)
		return false
	return true

func _capture_m14_bank() -> void:
	_m14_capture_dir = OS.get_environment("GANGNAM_M14_BANK_CAPTURE_DIR")
	var output := DirAccess.open(_m14_capture_dir) if _m14_capture_dir.is_absolute_path() else null
	var language := OS.get_environment("GANGNAM_M14_BANK_CAPTURE_LANGUAGE")
	if output == null or not output.get_files().is_empty() or not output.get_directories().is_empty() \
			or not M14_EXIT_LINE.has(language) or DisplayServer.get_name() == "headless":
		_fail("M14 capture requires a fresh absolute output, an authored locale and a real display")
		get_tree().quit(1)
		return
	if OS.get_environment("GANGNAM_M14_BANK_CAPTURE_COMPACT") == "1":
		DisplayServer.window_set_size(Vector2i(960, 600))
		await get_tree().process_frame
		if DisplayServer.window_get_size() != Vector2i(960, 600):
			_fail("M14 compact capture did not get a 960x600 window")
			get_tree().quit(1)
			return
	OS.low_processor_usage_mode = false
	LocaleManager.set_language(language)
	for choice_index in range(3):
		await _play_m14_bank_case(language, choice_index)
	await _remove_story()
	await _stop_audio()
	if _m14_cases != 3:
		_fail("one or more M14 branches were not captured")
	if _failures == 0:
		print("M14_BANK_VIEWPORT_OK language=%s paths=%d" % [language, _m14_cases])
	get_tree().quit(0 if _failures == 0 else 1)

func _play_case(language: String, fixture: Dictionary, choice_index: int) -> void:
	await _remove_story()
	var event_id := str(fixture["id"])
	var w202_quiet_choice := event_id == W202_EVENT and choice_index == 0
	_context = "%s/%s/choice%d" % [language, event_id, choice_index]
	if not _seed_story(event_id, int(fixture.get("turn", 220))):
		return
	GameState.pending_story_queue = [event_id]
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	await _wait_stable()
	_story.call("_set_auto_mode", false, false, false)
	if str((_story.get("_current") as Dictionary).get("id", "")) != event_id \
			or bool(_story.get("_read_only_replay")):
		_fail("real StoryMode did not load the requested live root")
		return
	if not await _read_phase(str(fixture["root"]), str(fixture["root_ambience"]), false):
		return
	_story.call("_on_advance")
	await _wait_stable()
	if bool(fixture.get("auto_single_choice", false)):
		if choice_index != 0 or bool(_story.get("_showing_choices")):
			_fail("linear cafe exit did not advance without a redundant choice menu")
			return
	else:
		if not bool(_story.get("_showing_choices")):
			_fail("authored choices were not exposed after sequential intro")
			return
		if not _expect_surface(str(fixture["root"]), str(fixture["root_ambience"]), "choices"):
			return
		var visible: Array = _story.call("_visible_choice_indices", _story.get("_current"))
		if not visible.has(choice_index):
			_fail("target authored choice is not visible")
			return
		var music_key := str(BGMPlayer.get("_current_key"))
		if w202_quiet_choice and not _w202_prime_ambience_layers():
			return
		_story.call("_on_choice", choice_index)
		if w202_quiet_choice:
			if not _expect_no_ambience("W202 accepted result on the choice frame"):
				return
			if str(BGMPlayer.get("_current_key")) != music_key:
				_fail("W202 location silence changed the score")
				return
		await _wait_stable()
	if not bool(_story.get("_pending_after_result")) \
			or int(_story.get("_pending_result_choice_index")) != choice_index:
		_fail("actual choice did not enter its exact result phase")
		return
	var expected_results: Array = fixture["results"]
	var expected_ambiences: Array = fixture["result_ambience"]
	if not await _read_phase(
			str(expected_results[choice_index]),
			str(expected_ambiences[choice_index]), true):
		return
	if w202_quiet_choice:
		if not _expect_no_ambience("W202 accepted result after its final page"):
			return
		_w202_silent_results += 1
	if int(fixture.get("turn", 0)) == 6 and str(expected_results[choice_index]) == "street_rainy":
		var portrait_id := str(_story.call("_resolved_story_surface_portrait_id"))
		var human_layer := str(BGMPlayer.get("_current_human_ambience_key"))
		if portrait_id != "player_tired" or human_layer != "street":
			_fail("cafe exit retained the investor or cafe human layer")
			return
	_cases += 1

func _w202_prime_ambience_layers() -> bool:
	# Exercise the shared profile without changing the real root/defer evidence.
	# All three layers must be live before checking immediate—not faded—silence.
	BGMPlayer.update_event_ambience({}, "", "gukbap_restaurant_night")
	BGMPlayer.set_season_ambience("winter")
	if str(BGMPlayer.get("_current_ambience_key")) != "hoesik" \
			or str(BGMPlayer.get("_current_human_ambience_key")) != "cafe" \
			or str(BGMPlayer.get("_current_season_key")) != "winter":
		_fail("W202 shared restaurant profile or ambience fixture changed")
		return false
	for player_property in ["_ambience_player", "_human_ambience_player", "_season_player"]:
		var player := BGMPlayer.get(player_property) as AudioStreamPlayer
		if not is_instance_valid(player) or not player.playing:
			_fail("W202 did not start %s before the silence test" % player_property)
			return false
	return true

func _play_m14_bank_case(language: String, choice_index: int) -> void:
	await _remove_story()
	_context = "%s/%s/choice%d" % [language, M14_BANK, choice_index]
	_seed_story(M14_BANK, 53)
	GameState.age = 34
	GameState.year = 2027
	GameState.month = 2
	GameState.money = 750_000.0
	GameState.flags["arc_34_money_attracts_seen"] = true
	if not _w202_prime_ambience_layers():
		return
	GameState.pending_story_queue = [M14_BANK]
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	if not _expect_no_ambience("M14 entry on the first frame"):
		return
	await _wait_stable()
	_story.call("_set_auto_mode", false, false, false)
	var current: Dictionary = _story.get("_current")
	if current.get("id") != M14_BANK or current.get("choices", []).size() != 3:
		_fail("M14 exact live bank root and three choices were not exposed")
		return
	for _page in range((_story.get("_paragraphs") as Array).size()):
		await _finish_page()
		if not _m14_expect_surface(false) or not _m14_expect_cues(choice_index, -1):
			return
		_story.call("_on_advance")
		await _wait_stable()
	if not bool(_story.get("_showing_choices")) \
			or not _expect_surface(M14_COUNTER, "", "bank choice dock"):
		_fail("M14 choice dock did not remain at the counter")
		return
	if not _m14_capture_dir.is_empty():
		# The choice group's entrance tween is separate from the ink tween.
		await get_tree().create_timer(0.40).timeout
		if not await _save_viewport_frame(_m14_capture_dir.path_join("c%d_choices.png" % choice_index)):
			return
	var initial_money := float(GameState.money)
	var initial_receipts := GameState.event_log.size()
	_story.call("_on_choice", choice_index)
	await _wait_stable()
	if not bool(_story.get("_pending_after_result")) \
			or not GameState.flags.get("arc_y2_bank_limit_review_seen", false) \
			or not is_equal_approx(GameState.money, initial_money) \
			or GameState.event_log.size() != initial_receipts + 1:
		_fail("M14 choice must create one receipt, no money and retain the outcome flag")
		return
	var pages: Array = _story.get("_paragraphs")
	var saw_exit_line := false
	for page_index in range(pages.size()):
		var source_index := int(_story.call("_story_source_paragraph_index", page_index))
		var exterior := choice_index == 2 and source_index == 1
		if str(pages[page_index]).contains(str(M14_EXIT_LINE[language])):
			if not exterior:
				_fail("M14 departure narration did not own the exit cut")
				return
			saw_exit_line = true
		if not _m14_expect_surface(exterior) or not _m14_expect_cues(choice_index, source_index):
			return
		await _finish_page()
		if not _m14_capture_dir.is_empty() and not await _save_viewport_frame(
				_m14_capture_dir.path_join("c%d_result_%d_%s.png" % [
					choice_index, page_index, "exit" if exterior else "counter"])):
			return
		if page_index < pages.size() - 1:
			_story.call("_on_advance")
			await _wait_stable()
	if saw_exit_line != (choice_index == 2):
		_fail("M14 translated departure line missing or appeared on another choice")
		return
	_m14_cases += 1

func _m14_expect_surface(exterior: bool) -> bool:
	if str(_story.get_meta("living_scene_effect", "")) != "none" \
			or not str(BGMPlayer.get("_current_key")).is_empty():
		_fail("M14 bank scene acquired precipitation or an unrelated score")
		return false
	return _expect_surface(M14_EXIT if exterior else M14_COUNTER, "", "bank surface") \
		and _expect_no_ambience("M14 must not inherit people or weather")

func _m14_expect_cues(choice: int, source: int) -> bool:
	var expected: Array[String] = []
	if choice == 0 and source >= 0:
		expected.append(M14_BANK + "::result:0:0:0:paper_handle")
	elif choice == 1 and source >= 1:
		expected.append(M14_BANK + "::result:1:1:0:paper_handle")
	elif choice == 2 and source >= 0:
		expected.append(M14_BANK + "::result:2:0:0:pen_write")
		if source >= 1:
			expected.append(M14_BANK + "::result:2:1:0:traffic_pass")
	var observed: Array[String] = []
	for raw in AudioManager._story_audio_seen:
		if str(raw).begins_with(M14_BANK + ":"):
			observed.append(str(raw))
	if observed != expected:
		_fail("M14 authored cue order expected=%s actual=%s" % [expected, observed])
		return false
	return true

func _play_w8_case(language: String, choice_index: int) -> void:
	await _remove_story()
	_context = "%s/%s/choice%d" % [language, W8_EVENT, choice_index]
	var capture := not _w8_capture_dir.is_empty()
	_seed_story(W8_EVENT, 8)
	GameState.age = 33
	GameState.month = 2
	GameState.week_of_month = 4
	GameState.housing = "goshiwon"
	GameState.money = 2_500_000.0
	GameState.pending_story_queue = [W8_EVENT]
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	await _wait_stable()
	_story.call("_set_auto_mode", false, false, false)
	var current: Dictionary = _story.get("_current")
	var authored_choices: Array = current.get("choices", [])
	if current.get("id") != W8_EVENT or authored_choices.size() != 2:
		_fail("expected the real W8 event and its two original choices")
		return
	var intro: Array = (_story.get("_paragraphs") as Array).duplicate()
	for page_index in range(intro.size()):
		await _finish_page()
		if not _w8_expect_surface("street_rainy", "rain", "rain", "intro-%d" % page_index):
			return
		if capture and page_index == 0:
			await get_tree().create_timer(1.5).timeout
			await _save_w8_capture(language, choice_index, "01_rain_call")
		_story.call("_on_advance")
		await _wait_stable()
	if not bool(_story.get("_showing_choices")) \
			or not _w8_expect_surface("street_rainy", "rain", "rain", "choice-dock"):
		_fail("a result location appeared before the original choices")
		return
	var before_money := float(GameState.money)
	var before_count := GameState.event_log.size()
	if capture:
		await _save_w8_capture(language, choice_index, "02_choices")
		_mark_w8_capture("choice_commit")
	_story.call("_on_choice", choice_index)
	await _wait_stable()
	if not bool(_story.get("_pending_after_result")) \
			or int(_story.get("_pending_result_choice_index")) != choice_index \
			or GameState.event_log.size() != before_count + 1 \
			or not is_equal_approx(GameState.money, before_money + (
				-1_500_000.0 if choice_index == 0 else 3_000_000.0)):
		_fail("W8 original choice and cash effect were not applied exactly once")
		return
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var cut: int = _w8_expect_cut(language, choice_index, pages)
	if cut < 0:
		return
	for page_index in range(pages.size()):
		if int(_story.get("_para_index")) != page_index:
			_fail("W8 advance skipped a page")
			return
		var after_cut := page_index >= cut
		var result_background := (W8_BANK_EXIT if after_cut else W8_BANK) \
			if choice_index == 0 else (W8_LOCKERS if after_cut else "street_rainy")
		var result_ambience := ("street" if after_cut else "") \
			if choice_index == 0 else ("" if after_cut else "rain")
		var result_weather := "rain" if result_ambience == "rain" else "none"
		if not _w8_expect_surface(result_background, result_ambience, result_weather,
				"result-%d" % page_index):
			return
		if not capture and page_index + 1 == cut and language == "ko" \
				and not await _w8_switch_languages(choice_index, false):
			return
		await _finish_page()
		if capture:
			var shot_label := ""
			if page_index + 1 == cut:
				shot_label = "04_before_move"
			elif page_index == cut:
				shot_label = "05_after_move"
			elif page_index == 0:
				shot_label = "03_first_result"
			elif page_index + 1 == pages.size():
				shot_label = "06_last_result"
			if not shot_label.is_empty():
				await _save_w8_capture(language, choice_index, shot_label)
				await get_tree().create_timer(1.5).timeout
		_w8_pages += 1
		if page_index + 1 < pages.size():
			if capture and page_index + 1 == cut:
				_mark_w8_capture("location_cut")
			_story.call("_on_advance")
			if not capture and page_index + 1 == cut:
				if not await _w8_cold_reload(choice_index, cut):
					return
			await _wait_stable()
			if not capture and page_index + 1 == cut and language == "ko" \
					and not await _w8_switch_languages(choice_index, true):
				return
	_w8_cases += 1

func _w8_expect_cut(language: String, choice_index: int, pages: Array) -> int:
	var prefix: String = W8_ARRIVAL_TEXT[language][choice_index]
	var cut := -1
	for index in range(pages.size()):
		if str(pages[index]).begins_with(prefix):
			if cut >= 0:
				_fail("W8 duplicated the localized cut sentence")
				return -1
			cut = index
	var current: Dictionary = _story.get("_current")
	var choices: Array = current["choices"]
	var authored: String = _story.call("_fmt", str(choices[choice_index].get("result_text", "")))
	var whitespace := RegEx.new()
	whitespace.compile("\\s+")
	var combined := "".join(PackedStringArray(pages))
	if cut < 1 or int(_story.get("_w8_result_cut_page")) != cut \
			or int(_story.call("_story_source_paragraph_count")) != 2 \
			or int(_story.call("_story_source_paragraph_index", cut)) != (1 if choice_index == 0 else 0) \
			or int(_story.call("_story_source_paragraph_index", cut - 1)) != (1 if choice_index == 0 else 0) \
			or whitespace.sub(combined, "", true) != whitespace.sub(authored, "", true):
		_fail("W8 cut did not start at the exact localized sentence with two preserved source paragraphs")
		return -1
	return cut

func _w8_cold_reload(choice_index: int, cut: int) -> bool:
	# Settle the already-entered location without processing a typing frame.
	# Manual save correctly stays unavailable while the ink transition runs.
	_story.call("_finish_story_scene_transition")
	var context: Dictionary = _story.call("build_save_resume_context")
	if context.get("phase") != "result" \
			or int(context.get("paragraph_index", -1)) != cut \
			or not bool(context.get("paragraph_was_typing", false)) \
			or not is_zero_approx(float(context.get("paragraph_type_ratio", -1.0))):
		_fail("W8 did not capture a v4 result at the exact 0%-typed cut")
		return false
	var cash := float(GameState.money)
	var health := float(GameState.health)
	var mental := float(GameState.mental)
	var luck := float(GameState.luck)
	var count := GameState.event_log.size()
	if not SaveManager.save_game(W8_QA_SLOT, context, {"qa_fixture": true}):
		_fail("W8 isolated result disk save failed")
		return false
	var disk: Variant = JSON.parse_string(FileAccess.get_file_as_string(SaveManager.slot_path(W8_QA_SLOT)))
	if not disk is Dictionary or int(disk.get("version", -1)) != 4:
		_fail("W8 saved result did not use the unchanged v4 schema")
		return false
	await _remove_story()
	GameState.start_new_game()
	if not SaveManager.load_game(W8_QA_SLOT):
		_fail("W8 isolated result cold load failed")
		return false
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	_story.call("_set_auto_mode", false, false, false)
	if int(_story.get("_para_index")) != cut or int(_story.get("_type_pos")) != 0 \
			or not bool(_story.get("_pending_after_result")) \
			or int(_story.get("_pending_result_choice_index")) != choice_index \
			or GameState.event_log.size() != count \
			or not is_equal_approx(GameState.money, cash) or GameState.health != health \
			or GameState.mental != mental or GameState.luck != luck:
		_fail("W8 cold result moved off the exact cut or reapplied the choice")
		return false
	_w8_reloads += 1
	return true

func _w8_switch_languages(choice_index: int, after_cut: bool) -> bool:
	var expected_background := (W8_BANK_EXIT if after_cut else W8_BANK) \
		if choice_index == 0 else (W8_LOCKERS if after_cut else "street_rainy")
	var expected_ambience := ("street" if after_cut else "") \
		if choice_index == 0 else ("" if after_cut else "rain")
	var expected_weather := "rain" if expected_ambience == "rain" else "none"
	for language in ["en", "ko"]:
		_story.call("_set_story_language", language)
		await _wait_stable()
		var pages: Array = _story.get("_paragraphs")
		var cut := _w8_expect_cut(language, choice_index, pages)
		if LocaleManager.language != language or cut < 0 \
				or (int(_story.get("_para_index")) >= cut) != after_cut \
				or not _w8_expect_surface(expected_background, expected_ambience,
					expected_weather, "switch-%s" % language):
			_fail("W8 language change did not preserve the current place")
			return false
		_w8_language_switches += 1
	return true

func _w8_expect_surface(background: String, ambience: String, weather: String, label: String) -> bool:
	if not _expect_surface(background, ambience, label):
		return false
	if str(_story.get_meta("living_scene_effect", "")) != weather:
		_fail("%s wrong W8 weather: expected %s" % [label, weather])
		return false
	return not ambience.is_empty() or _expect_no_ambience("W8 " + label)

func _expect_no_ambience(label: String) -> bool:
	for layer in [
		["_current_ambience_key", "_ambience_player"],
		["_current_human_ambience_key", "_human_ambience_player"],
		["_current_season_key", "_season_player"],
	]:
		var player := BGMPlayer.get(layer[1]) as AudioStreamPlayer
		if not str(BGMPlayer.get(layer[0])).is_empty() \
				or not is_instance_valid(player) or player.playing:
			_fail("%s retained ambience %s" % [label, layer[1]])
			return false
	return true

func _seed_story(event_id: String, turn: int) -> bool:
	GameState.start_new_game()
	GameState.turn = turn
	GameState.age = 33 if turn == 6 else 37
	GameState.month = 2 if turn == 6 else 7
	GameState.week_of_month = 2 if turn == 6 else 1
	GameState.housing = "oneroom"
	GameState.money = 2_800_000_000.0
	GameState.health = 80
	GameState.mental = 80
	GameState.current_job = {"id": "job_01"}
	GameState.flags = {"prologue_done": true}
	if event_id == W202_EVENT:
		GameState.flags["daeun_romance_started"] = true
	GameState.story_replay_mode = false
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	EventManager.current_event = {}
	if event_id != "arc_y5_burnout_check_reference":
		return true
	var locked: Dictionary = CHAPTER5_ROUTE.lock_entry(
		CHAPTER5_ROUTE.default_state(), 195, "투자형", true, true,
		2_800_000_000.0)
	if not bool(locked.get("ok", false)):
		_fail("burnout prerequisite could not lock the causal route")
		return false
	var state: Dictionary = locked["state"]
	var target_index: int = CHAPTER5_ROUTE.OWNED_EVENT_IDS.find(event_id)
	for index in range(target_index):
		var committed: Dictionary = CHAPTER5_ROUTE.commit_choice(
			state, CHAPTER5_ROUTE.OWNED_EVENT_IDS[index],
			BURNOUT_PRIOR_CHOICES[index], CHAPTER5_ROUTE.OWNED_TURNS[index])
		if not bool(committed.get("ok", false)):
			_fail("burnout prerequisite failed at %s" % CHAPTER5_ROUTE.OWNED_EVENT_IDS[index])
			return false
		state = committed["state"]
	GameState.chapter5_causal_state = state
	GameState.turn = CHAPTER5_ROUTE.OWNED_TURNS[target_index]
	if GameState.chapter5_causal_next_event_for_turn() != event_id:
		_fail("burnout causal route did not admit the exact live root")
		return false
	return true

func _read_phase(expected_background: String, expected_ambience: String, result: bool) -> bool:
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	if pages.is_empty() or int(_story.get("_para_index")) != 0:
		_fail("phase did not start at decoded page zero")
		return false
	for page_index in range(pages.size()):
		if int(_story.get("_para_index")) != page_index \
				or bool(_story.get("_pending_after_result")) != result:
			_fail("normal advance skipped a page or crossed the phase boundary")
			return false
		await _finish_page()
		if not _expect_surface(expected_background, expected_ambience,
				("result" if result else "intro") + "-page%d" % page_index):
			return false
		if result:
			_result_pages += 1
		else:
			_intro_pages += 1
		if page_index + 1 < pages.size():
			_story.call("_on_advance")
			await _wait_stable()
	return true

func _expect_surface(raw_background: String, expected_ambience: String, label: String) -> bool:
	var resolved_background := ImageRegistry.resolve_contextual_background_id(raw_background)
	var expected_path := str(EXACT_PATHS.get(resolved_background, ""))
	var background := _story.get("_bg_img") as TextureRect
	var actual_path := "" if not is_instance_valid(background) \
			or background.texture == null else background.texture.resource_path
	var actual_id := str(_story.get("_event_background_id"))
	var actual_ambience := str(BGMPlayer.get("_current_ambience_key"))
	if expected_path.is_empty() or not FileAccess.file_exists(expected_path):
		_fail("%s expected authored asset is missing: %s" % [label, expected_path])
		return false
	if ImageRegistry.get_background(resolved_background) != expected_path:
		_fail("%s registry does not own exact path %s" % [label, expected_path])
		return false
	if actual_id != resolved_background or actual_path != expected_path:
		_fail("%s wrong settled background expected=%s/%s actual=%s/%s" % [
			label, resolved_background, expected_path, actual_id, actual_path])
		return false
	if actual_ambience != expected_ambience:
		_fail("%s wrong settled ambience expected=%s actual=%s" % [
			label, expected_ambience, actual_ambience])
		return false
	return true

func _finish_page() -> void:
	if bool(_story.get("_direction_beat_waiting")):
		_story.call("_on_advance")
	_story.call("_complete_typing")
	await _wait_stable()

func _wait_stable() -> void:
	for _frame in range(240):
		await get_tree().process_frame
		if not is_instance_valid(_story):
			return
		var raw_ink_tween: Variant = _story.get("_story_ink_transition_tween")
		var raw_text_tween: Variant = _story.get("_story_text_panel_tween")
		var ink_layer := _story.get("_story_ink_transition_layer") as Control
		var transition_busy := bool(_story.get("_story_scene_transition_active")) \
				or bool(_story.get("_direction_hold_active")) \
				or (raw_ink_tween is Tween and (raw_ink_tween as Tween).is_running()) \
				or (raw_text_tween is Tween and (raw_text_tween as Tween).is_running()) \
				or (is_instance_valid(ink_layer) and ink_layer.visible)
		if not transition_busy:
			await get_tree().process_frame
			return
		if not _w8_capture_dir.is_empty() or not _m14_capture_dir.is_empty():
			continue
		if raw_ink_tween is Tween and (raw_ink_tween as Tween).is_running():
			(raw_ink_tween as Tween).custom_step(10.0)
		if raw_text_tween is Tween and (raw_text_tween as Tween).is_running():
			(raw_text_tween as Tween).custom_step(10.0)
	_fail("StoryMode surface never settled")

func _diagnostic() -> Dictionary:
	var data := {"context": _context, "language": LocaleManager.language}
	if not is_instance_valid(_story):
		return data
	var background := _story.get("_bg_img") as TextureRect
	data.merge({
		"event": str((_story.get("_current") as Dictionary).get("id", "")),
		"phase": _story.call("_story_resume_phase"),
		"page": int(_story.get("_para_index")),
		"background_id": str(_story.get("_event_background_id")),
		"background_path": "" if not is_instance_valid(background) \
				or background.texture == null else background.texture.resource_path,
		"ambience": str(BGMPlayer.get("_current_ambience_key")),
	})
	return data

func _fail(message: String) -> void:
	_failures += 1
	print("STORY_BACKGROUND_CONTEXT_CHECK_FAIL %s %s" % [
		message, JSON.stringify(_diagnostic())])

func _remove_story() -> void:
	if is_instance_valid(_story):
		_story.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame
	_story = null
	GameState.pending_story_queue.clear()
	EventManager.current_event = {}

func _stop_audio() -> void:
	await AudioManager.drain_pending_timers_for_exit()
	BGMPlayer.stop()
	for owner in [AudioManager, BGMPlayer]:
		for child in owner.get_children():
			if child is AudioStreamPlayer:
				(child as AudioStreamPlayer).stop()
				(child as AudioStreamPlayer).stream = null
	for _frame in range(4):
		await get_tree().process_frame
