extends Node
## L2 only: exercise the real StoryMode node for ORDER-155's exact authored
## location moves. This is deterministic regression evidence, never a
## substitute for the required normal-speed human M49-M60 replays.

const QA_PREFIX := "GangnamDream_StoryNameplateQA_"
const CHAPTER5_ROUTE := preload("res://systems/Chapter5CausalRoute.gd")
const BURNOUT_PRIOR_CHOICES := [2, 1, 0, 1]
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
	"gangnam_apartment": "res://assets/backgrounds/gangnam_apartment.png",
	"apartment": "res://assets/backgrounds/oneroom_apartment.png",
	"subway": "res://assets/backgrounds/seoul_subway.png",
}

var _story: Control
var _failures := 0
var _cases := 0
var _intro_pages := 0
var _result_pages := 0
var _context := "bootstrap"

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
	for language in ["ko", "en"]:
		LocaleManager.set_language(language)
		for fixture_variant in CASES:
			var fixture: Dictionary = fixture_variant
			var results: Array = fixture["results"]
			for choice_index in range(results.size()):
				await _play_case(language, fixture, choice_index)
	await _remove_story()
	await _stop_audio()
	if _cases != 32 or _intro_pages < 32 or _result_pages < 32:
		_fail("fixture inventory incomplete cases=%d intro_pages=%d result_pages=%d" % [
			_cases, _intro_pages, _result_pages])
	if _failures > 0:
		print("STORY_BACKGROUND_CONTEXT_CHECK_FAIL failures=%d cases=%d intro_pages=%d result_pages=%d" % [
			_failures, _cases, _intro_pages, _result_pages])
		get_tree().quit(1)
		return
	print("STORY_BACKGROUND_CONTEXT_CHECK_OK cases=%d intro_pages=%d result_pages=%d ko_en=1 choices=all live_storymode=1 settled_texture=1 ambience=1 human_gate=OPEN" % [
		_cases, _intro_pages, _result_pages])
	get_tree().quit(0)

func _play_case(language: String, fixture: Dictionary, choice_index: int) -> void:
	await _remove_story()
	var event_id := str(fixture["id"])
	_context = "%s/%s/choice%d" % [language, event_id, choice_index]
	if not _seed_story(event_id):
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
	if not bool(_story.get("_showing_choices")):
		_fail("authored choices were not exposed after sequential intro")
		return
	if not _expect_surface(str(fixture["root"]), str(fixture["root_ambience"]), "choices"):
		return
	var visible: Array = _story.call("_visible_choice_indices", _story.get("_current"))
	if not visible.has(choice_index):
		_fail("target authored choice is not visible")
		return
	_story.call("_on_choice", choice_index)
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
	_cases += 1

func _seed_story(event_id: String) -> bool:
	GameState.start_new_game()
	GameState.turn = 220
	GameState.age = 37
	GameState.month = 7
	GameState.week_of_month = 1
	GameState.housing = "oneroom"
	GameState.money = 2_800_000_000.0
	GameState.health = 80
	GameState.mental = 80
	GameState.current_job = {"id": "job_01"}
	GameState.flags = {"prologue_done": true}
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
