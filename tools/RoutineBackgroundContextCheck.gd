extends Node
## ORDER-156 fail-first: exercise the real MainGame decision card, random
## routine result, final weekly receipt, settled texture, and ambience. This is
## regression evidence only; it does not replace the Chapter 5 human gate.

const QA_PREFIX := "GangnamDream_StoryNameplateQA_"
const MAIN_GAME_SCENE := preload("res://scenes/MainGame.tscn")
const EXACT_PATHS := {
	"street_day": "res://assets/backgrounds/street_seoul_day.png",
	"park_bench_day": "res://assets/backgrounds/park_bench_day.png",
	"goshiwon_shared_kitchen": "res://assets/backgrounds/goshiwon_shared_kitchen.png",
	"goshiwon_room": "res://assets/backgrounds/goshiwon_room.png",
	"convenience_night": "res://assets/backgrounds/convenience_store_night_v2.png",
	"cafe": "res://assets/backgrounds/cafe_seoul.png",
}
const FIXTURES := [
	{
		"id": "property_w202_rest8",
		"turn": 202, "action": "rest", "index": 8, "pressure": "condition",
		"expected_background": "street_day", "expected_ambience": "street",
		"ko": "길에서 꼬깃한 만원짜리를 주웠다. 오늘은 운이 좋다.",
		"en": "Found a crumpled ten-thousand won bill on the street. Today's a lucky day.",
		"property": true,
	},
	{
		"id": "general_w216_rest5",
		"turn": 216, "action": "rest", "index": 5, "pressure": "relationship",
		"expected_background": "park_bench_day", "expected_ambience": "street",
		"ko": "공원 벤치에서 멍하니 사람들을 봤다. 다들 어딘가로 바쁘다.",
		"en": "Sat on a park bench watching people drift by. Everyone seems busy going somewhere.",
	},
	{
		"id": "general_w227_save4",
		"turn": 227, "action": "save", "index": 4, "pressure": "capital",
		"expected_background": "goshiwon_shared_kitchen", "expected_ambience": "goshiwon_hallway",
		"ko": "외식을 참았다. 냉장고를 뒤졌다. 계란 두 개와 묵은 김치가 있었다.",
		"en": "Resisted eating out. Rummaged through the fridge. Two eggs and old kimchi.",
	},
	{
		"id": "general_w238_save4_repeat",
		"turn": 238, "action": "save", "index": 4, "pressure": "final_reckoning",
		"expected_background": "goshiwon_shared_kitchen", "expected_ambience": "goshiwon_hallway",
		"ko": "외식을 참았다. 냉장고를 뒤졌다. 계란 두 개와 묵은 김치가 있었다.",
		"en": "Resisted eating out. Rummaged through the fridge. Two eggs and old kimchi.",
	},
	{
		"id": "general_w230_save0",
		"turn": 230, "action": "save", "index": 0, "pressure": "final_reckoning",
		"expected_background": "goshiwon_shared_kitchen", "expected_ambience": "goshiwon_hallway",
		"ko": "편의점 도시락 대신 집에서 밥을 했다. 재료비 이천 원으로 하루를 버텼다.",
		"en": "Cooked at home instead of a convenience store lunch box. Made it through the day on 2,000 won of ingredients.",
	},
	{
		"id": "general_w239_save1",
		"turn": 239, "action": "save", "index": 1, "pressure": "capital",
		"expected_background": "goshiwon_room", "expected_ambience": "room",
		"ko": "구독 서비스를 정리했다. 쓰지도 않는 것들이 매달 빠져나가고 있었다.",
		"en": "Cleared out subscriptions. Things I didn't even use had been going out every month.",
	},
	{
		"id": "control_w227_save2_walk",
		"turn": 227, "action": "save", "index": 2, "pressure": "capital",
		"expected_background": "street_day", "expected_ambience": "street",
		"ko": "걸어서 한 시간. 교통비 2,800원이 아깝다는 생각을 세 번 했다.",
		"en": "Walked for an hour. Thought three times about whether 2,800 won in transit fare was worth it.",
	},
	{
		"id": "control_w227_save3_convenience",
		"turn": 227, "action": "save", "index": 3, "pressure": "capital",
		"expected_background": "convenience_night", "expected_ambience": "convenience",
		"ko": "커피 대신 편의점 아메리카노. 맛은 다르지만 잔액은 같아진다.",
		"en": "Convenience store americano instead of coffee. Different taste, but the balance ends up the same.",
	},
]

var _game: Control
var _story: Control
var _failures := 0
var _attempts := 0
var _echo_attempts := 0
var _context := "bootstrap"

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	Engine.max_fps = 60
	if not _validate_isolation():
		get_tree().quit(1)
		return
	print("ROUTINE_BACKGROUND_CONTEXT_SOURCE=%s" % ProjectSettings.globalize_path("res://"))
	await get_tree().process_frame
	SaveManager.set_setting("story_text_size", "standard")
	for language in ["ko", "en"]:
		LocaleManager.set_language(language)
		for raw_fixture in FIXTURES:
			await _play_fixture(language, raw_fixture as Dictionary)
		for choice_index in [0, 1]:
			await _play_w220_echo_fixture(language, choice_index)
	await _remove_game()
	await _remove_story()
	await _stop_audio()
	if _attempts != 16:
		_fail("fixture inventory incomplete attempts=%d expected=16" % _attempts)
	if _echo_attempts != 4:
		_fail("W220 echo inventory incomplete attempts=%d expected=4" % _echo_attempts)
	if _failures > 0:
		print("ROUTINE_BACKGROUND_CONTEXT_CHECK_FAIL failures=%d attempts=%d echo_attempts=%d routine_cases=16 observed=12 controls=4 w220_cases=4 ko_en=1 live_maingame=1 live_storymode=1" % [_failures, _attempts, _echo_attempts])
		get_tree().quit(1)
		return
	print("ROUTINE_BACKGROUND_CONTEXT_CHECK_OK attempts=16 echo_attempts=4 routine_cases=16 observed=12 controls=4 w220_cases=4 ko_en=1 action_selection=1 random_result=1 story_choice=1 save_load=1 original_location_echo=1 settled_texture=1 ambience=1 human_gate=OPEN")
	get_tree().quit(0)

func _validate_isolation() -> bool:
	var bootstrap_script := get_tree().get_script() as Script
	if bootstrap_script == null \
			or bootstrap_script.resource_path != "res://tools/StoryNameplateBootstrap.gd":
		_fail("exact pre-autoload isolation bootstrap required")
		return false
	var qa_namespace := str(ProjectSettings.get_setting(
		"application/config/custom_user_dir_name", ""))
	if not bool(ProjectSettings.get_setting(
			"application/config/use_custom_user_dir", false)) \
			or not qa_namespace.begins_with(QA_PREFIX) \
			or not OS.get_user_data_dir().ends_with(qa_namespace):
		_fail("isolated QA user directory was not selected before autoloads")
		return false
	print("STORY_NAMEPLATE_QA_USER_DIR=%s" % OS.get_user_data_dir())
	return true

func _play_fixture(language: String, fixture: Dictionary) -> void:
	await _remove_game()
	_context = "%s/%s" % [language, str(fixture["id"])]
	_seed_state(fixture)
	_game = MAIN_GAME_SCENE.instantiate() as Control
	_game.set_meta("_screenshot_qa_static_surface", true)
	add_child(_game)
	await _wait_frames(5)
	_game.call("_render_ap_actions")
	await _wait_frames(4)
	var pressure: Dictionary = _game.call("_demo_week_pressure")
	_expect(str(pressure.get("id", "")) == str(fixture["pressure"]),
		"wrong pressure expected=%s actual=%s" % [fixture["pressure"], pressure.get("id", "")])
	var card := _find_action_card(str(fixture["action"]))
	if not is_instance_valid(card):
		_fail("real decision board did not expose target action")
		_attempts += 1
		return
	var roll_seed := _find_roll_seed(str(fixture["action"]), int(fixture["index"]))
	if roll_seed < 0:
		_fail("could not find deterministic random seed")
		_attempts += 1
		return
	card.grab_focus()
	await get_tree().process_frame
	seed(roll_seed)
	(card as Button).pressed.emit()
	await _settle_game_background()
	var record := GameState.get_weekly_commitment_for_turn(int(fixture["turn"]))
	_expect(not record.is_empty(), "action did not create its weekly receipt")
	_expect(str(record.get("choice_id", "")) == str(fixture["action"]),
		"weekly receipt action identity changed")
	var details: Dictionary = record.get("details", {}) if record.get("details", {}) is Dictionary else {}
	_expect(str(details.get("receipt_prose_ko", "")) == str(fixture["ko"]),
		"random result did not retain exact Korean source index")
	_expect(str(details.get("receipt_prose_en", "")) == str(fixture["en"]),
		"random result did not retain exact English source index")
	_expect(GameState.action_points == 0, "decision did not close the week's AP")
	_expect(GameState.turn == int(fixture["turn"]), "routine action advanced the calendar")
	_expect_surface(str(fixture["expected_background"]), str(fixture["expected_ambience"]))
	_attempts += 1

func _seed_state(fixture: Dictionary) -> void:
	GameState.start_new_game("김민준", "지방_상경", "none", "알바", "자유런", "현실")
	var fixture_turn := int(fixture["turn"])
	GameState.turn = fixture_turn
	GameState.year = 2026 + int((fixture_turn - 1) / 48)
	GameState.month = int((fixture_turn - 1) / 4) % 12 + 1
	GameState.week_of_month = (fixture_turn - 1) % 4 + 1
	GameState.age = 33 + int((fixture_turn - 1) / 48)
	GameState.housing = "gosiwon"
	GameState.money = 100_000_000.0
	GameState.monthly_income = 2_000_000.0
	GameState.health = 80
	GameState.mental = 80
	GameState.action_points = 1
	GameState.max_action_points = 1
	GameState.grind_streak_weeks = 0
	GameState.pending_weekly_commitment = {}
	GameState.weekly_commitments = []
	GameState.flags["prologue_done"] = true
	GameState.flags["story_flashforward_seen"] = true
	GameState.flags["tutorial_shown"] = true
	GameState.flags["father_passed"] = true
	GameState.flags["arc_father_passing_seen"] = true
	GameState.flags.erase("demo_director_kind_turn")
	GameState.flags.erase("demo_director_locked_kind")
	GameState.flags.erase("demo_director_crisis_turn")
	GameState.flags.erase("arc_invest_guidance_seen")
	GameState.apply_cast_effect("father", {"stage": "passed"})
	if bool(fixture.get("property", false)):
		GameState.health = 32
		GameState.flags["daeun_married"] = true
		GameState.flags["arc_daeun_wedding_day_seen"] = true
	elif str(fixture["pressure"]) == "relationship":
		GameState.apply_cast_effect("jiyeon", {"met": true, "affinity": 20})
		GameState.grind_streak_weeks = 2
	elif str(fixture["pressure"]) == "capital":
		GameState.flags["arc_invest_guidance_seen"] = true
	EventManager.current_event = {}
	EventManager.narrative_bridge_results.clear()

func _play_w220_echo_fixture(language: String, choice_index: int) -> void:
	await _remove_game()
	await _remove_story()
	_context = "%s/w220_choice%d_echo" % [language, choice_index]
	_seed_w220_state()
	GameState.pending_story_queue = ["arc_y5_general_debt_memory_reconnect"]
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	await _wait_story_stable()
	_story.call("_set_auto_mode", false, false, false)
	if str((_story.get("_current") as Dictionary).get("id", "")) \
			!= "arc_y5_general_debt_memory_reconnect" \
			or bool(_story.get("_read_only_replay")):
		_fail("real StoryMode did not load the live W220 root")
		_echo_attempts += 1
		return
	var intro_pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	if intro_pages.is_empty():
		_fail("W220 intro had no sequential pages")
		_echo_attempts += 1
		return
	for page_index in range(intro_pages.size()):
		await _finish_story_page()
		if page_index + 1 < intro_pages.size():
			_story.call("_on_advance")
			await _wait_story_stable()
	_story.call("_on_advance")
	await _wait_story_stable()
	if not bool(_story.get("_showing_choices")):
		_fail("W220 authored choices were not exposed after normal intro")
		_echo_attempts += 1
		return
	var visible: Array = _story.call("_visible_choice_indices", _story.get("_current"))
	if not visible.has(choice_index):
		_fail("W220 target choice was not visible")
		_echo_attempts += 1
		return
	_story.call("_on_choice", choice_index)
	await _wait_story_stable()
	var expected_background := "goshiwon_room" if choice_index == 0 else "cafe"
	var expected_ambience := "room" if choice_index == 0 else "cafe"
	_expect(str(_story.get("_event_background_id")) == expected_background,
		"StoryMode result did not settle at its actual choice location")
	var record := GameState.get_weekly_commitment_for_turn(220)
	_expect(not record.is_empty(), "W220 choice did not create a weekly record")
	_expect(str(record.get("story_event_id", "")) \
			== "arc_y5_general_debt_memory_reconnect",
		"W220 weekly record lost its story event identity")
	_expect(int(record.get("story_choice_index", -1)) == choice_index,
		"W220 weekly record lost its choice identity")
	_expect(str(record.get("scene_background_id", "")) == expected_background,
		"W220 weekly record did not freeze its actual choice location")
	var saved: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	record = GameState.get_weekly_commitment_for_turn(220)
	_expect(str(record.get("scene_background_id", "")) == expected_background,
		"W220 frozen location did not survive save/load")
	await _remove_story()
	# A later move must not rewrite where the earlier choice actually happened.
	GameState.turn = 231
	GameState.year = 2030
	GameState.month = 10
	GameState.week_of_month = 3
	GameState.housing = "apartment"
	GameState.flags.erase("arc_daeun_wedding_day_seen")
	var echo_records: Array = GameState.consume_weekly_commitment_echoes(2)
	_expect(echo_records.size() == 1,
		"later MainGame echo consumer did not return the W220 record exactly once")
	if not echo_records.is_empty() and echo_records[0] is Dictionary:
		record = (echo_records[0] as Dictionary).duplicate(true)
	_expect(int(record.get("echoed_turn", -1)) == 231,
		"later MainGame echo did not stamp its actual consumption turn")
	_game = MAIN_GAME_SCENE.instantiate() as Control
	_game.set_meta("_screenshot_qa_static_surface", true)
	add_child(_game)
	await _wait_frames(5)
	_game.call("_render_demo_director_beat", "echo", {}, [], echo_records)
	await _settle_game_background()
	_expect_surface(expected_background, expected_ambience)
	_echo_attempts += 1

func _seed_w220_state() -> void:
	GameState.start_new_game("김민준", "지방_상경", "none", "알바", "자유런", "현실")
	GameState.turn = 220
	GameState.year = 2030
	GameState.month = 7
	GameState.week_of_month = 4
	GameState.age = 37
	GameState.housing = "gosiwon"
	GameState.money = 2_600_000_000.0
	GameState.health = 80
	GameState.mental = 80
	GameState.action_points = 1
	GameState.max_action_points = 1
	GameState.pending_weekly_commitment = {}
	GameState.weekly_commitments = []
	GameState.flags["prologue_done"] = true
	GameState.flags["story_flashforward_seen"] = true
	GameState.flags["tutorial_shown"] = true
	GameState.flags["father_passed"] = true
	GameState.flags["arc_father_passing_seen"] = true
	GameState.apply_cast_effect("father", {"stage": "passed"})
	EventManager.current_event = {}
	EventManager.narrative_bridge_results.clear()

func _finish_story_page() -> void:
	if bool(_story.get("_direction_beat_waiting")):
		_story.call("_on_advance")
	_story.call("_complete_typing")
	await _wait_story_stable()

func _wait_story_stable() -> void:
	for _frame in range(240):
		await get_tree().process_frame
		if not is_instance_valid(_story):
			return
		var raw_ink_tween: Variant = _story.get("_story_ink_transition_tween")
		var raw_text_tween: Variant = _story.get("_story_text_panel_tween")
		var ink_layer := _story.get("_story_ink_transition_layer") as Control
		var busy := bool(_story.get("_story_scene_transition_active")) \
				or bool(_story.get("_direction_hold_active")) \
				or (raw_ink_tween is Tween and (raw_ink_tween as Tween).is_running()) \
				or (raw_text_tween is Tween and (raw_text_tween as Tween).is_running()) \
				or (is_instance_valid(ink_layer) and ink_layer.visible)
		if not busy:
			await get_tree().process_frame
			return
		if raw_ink_tween is Tween and (raw_ink_tween as Tween).is_running():
			(raw_ink_tween as Tween).custom_step(10.0)
		if raw_text_tween is Tween and (raw_text_tween as Tween).is_running():
			(raw_text_tween as Tween).custom_step(10.0)
	_fail("StoryMode surface never settled")

func _find_action_card(action_id: String) -> Button:
	var cards: Array = _game.get("_ap_grid_cards")
	for raw_card in cards:
		if raw_card is Button and str(raw_card.get_meta("demo_action_id", "")) == action_id:
			return raw_card as Button
	return null

func _find_roll_seed(action_id: String, target_index: int) -> int:
	var pool_size := 10 if action_id == "rest" else 5
	for candidate in range(1, 100000):
		seed(candidate)
		if action_id == "save":
			randi() # saved amount is the first draw; vignette is the second.
		if int(randi() % pool_size) == target_index:
			return candidate
	return -1

func _settle_game_background() -> void:
	for _index in range(30):
		await get_tree().process_frame
		if not is_instance_valid(_game):
			return
		var fade = _game.get("_event_bg_fade_tween")
		if fade is Tween and (fade as Tween).is_valid() and (fade as Tween).is_running():
			(fade as Tween).custom_step(1.0)
	await _wait_frames(3)

func _expect_surface(background_id: String, ambience: String) -> void:
	var expected_path := str(EXACT_PATHS.get(background_id, ""))
	_expect(not expected_path.is_empty(), "fixture has no exact expected path")
	_expect(ResourceLoader.exists(expected_path),
		"expected background asset is missing: %s" % expected_path)
	var background_node = _game.get("event_bg")
	var actual_path := ""
	if background_node is TextureRect and (background_node as TextureRect).texture != null:
		actual_path = (background_node as TextureRect).texture.resource_path
	_expect(actual_path == expected_path,
		"settled texture mismatch expected=%s actual=%s" % [expected_path, actual_path])
	var actual_ambience := str(BGMPlayer.get("_current_ambience_key"))
	_expect(actual_ambience == ambience,
		"settled ambience mismatch expected=%s actual=%s" % [ambience, actual_ambience])

func _remove_game() -> void:
	if is_instance_valid(_game):
		_game.queue_free()
		await _wait_frames(4)
	_game = null

func _remove_story() -> void:
	if is_instance_valid(_story):
		_story.queue_free()
		await _wait_frames(4)
	_story = null
	GameState.pending_story_queue.clear()
	EventManager.current_event = {}

func _wait_frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame

func _stop_audio() -> void:
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
	BGMPlayer.stop()
	_detach_audio_streams(get_tree().root)
	await _wait_frames(8)

func _detach_audio_streams(root: Node) -> void:
	if root is AudioStreamPlayer:
		(root as AudioStreamPlayer).stop()
		(root as AudioStreamPlayer).stream = null
	elif root is AudioStreamPlayer2D:
		(root as AudioStreamPlayer2D).stop()
		(root as AudioStreamPlayer2D).stream = null
	for child in root.get_children():
		_detach_audio_streams(child)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)

func _fail(message: String) -> void:
	_failures += 1
	push_error("ROUTINE_BACKGROUND_CONTEXT_CHECK_FAIL [%s] %s" % [_context, message])
