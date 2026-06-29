extends Node
## ScreenshotQA — 실제 렌더러로 MainGame UI를 캡처해 폴리싱 연출을 눈으로 검증.
## 실행: xvfb-run -a godot --display-driver x11 --rendering-driver opengl3 \
##         --resolution 1280x800 res://tools/ScreenshotQA.tscn
## 카지노만 빠르게 확인:
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=casino
## 영어 카지노만 빠르게 확인:
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=casino-en
## 수정 부위별 빠른 확인:
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=start-en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=story-en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=ap-en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=endings-en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=demo-end-en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=title-en
## Steam Deck 영어 표면 회귀:
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=surface-en
## MORAL_TINT 필터만 빠르게 확인:
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=moral
## 전환 레이어만 빠르게 확인:
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=transition
## 헤드리스 더미 렌더러는 빈 텍스처를 주므로 x11+opengl3(xvfb) 필요.
## .tscn 으로 부팅해야 autoload(GameState 등)가 로드된다.

const OUT_DIR := "/tmp/gangnamdream_qa"
const QA_SCOPE_CASINO := "casino"
const QA_SCOPE_CASINO_EN := "casino_en"
const QA_SCOPE_MORAL := "moral"
const QA_SCOPE_DEMO_FLOW := "demo_flow"
const QA_SCOPE_DEMO_BLACKBOX := "demo_blackbox"
const QA_SCOPE_START_EN := "start_en"
const QA_SCOPE_STORY_EN := "story_en"
const QA_SCOPE_AP_EN := "ap_en"
const QA_SCOPE_ENDINGS_EN := "endings_en"
const QA_SCOPE_DEMO_END_EN := "demo_end_en"
const QA_SCOPE_TITLE_EN := "title_en"
const QA_SCOPE_SURFACE_EN := "surface_en"
const QA_SCOPE_TRANSITION := "transition"
var _mg: Node = null

func _tr(ko: String, en: String) -> String:
	return LocaleManager.ui(ko, en)

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	_clear_output_dir()
	var scope: String = _qa_scope()
	if scope in [QA_SCOPE_CASINO, QA_SCOPE_CASINO_EN]:
		var lang := _qa_language("en" if scope == QA_SCOPE_CASINO_EN else "ko")
		var prefix := "en_" if lang == "en" else ""
		_set_qa_language(lang)
		_prepare_main_game_state()
		await _boot_main_game()
		await _shot_casino_suite(prefix)
		print("SCREENSHOT_QA_DONE scope=casino lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_MORAL:
		_set_qa_language(_qa_language("ko"))
		_prepare_main_game_state()
		_seed_portfolio()
		await _boot_main_game()
		await _shot_moral_tint_states()
		print("SCREENSHOT_QA_DONE scope=moral dir=%s" % OUT_DIR)
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_TRANSITION:
		_set_qa_language(_qa_language("en"))
		_prepare_main_game_state()
		_seed_portfolio()
		await _boot_main_game()
		await _shot_transition_states()
		print("SCREENSHOT_QA_DONE scope=transition dir=%s" % OUT_DIR)
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_DEMO_FLOW:
		var lang := _qa_language("en")
		await _shot_demo_flow(lang)
		print("SCREENSHOT_QA_DONE scope=demo-flow lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_DEMO_BLACKBOX:
		var lang := _qa_language("en")
		await _shot_demo_blackbox(lang)
		print("SCREENSHOT_QA_DONE scope=demo-blackbox lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_START_EN:
		var lang := _qa_language("en")
		await _shot_start_surfaces(lang, "start_en_" if lang == "en" else "start_ko_")
		print("SCREENSHOT_QA_DONE scope=start-en lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_STORY_EN:
		var lang := _qa_language("en")
		await _shot_story_surfaces(lang, "story_en_" if lang == "en" else "story_ko_")
		print("SCREENSHOT_QA_DONE scope=story-en lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_AP_EN:
		var lang := _qa_language("en")
		await _shot_ap_shell_surfaces(lang, "ap_en_" if lang == "en" else "ap_ko_")
		print("SCREENSHOT_QA_DONE scope=ap-en lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_ENDINGS_EN:
		var lang := _qa_language("en")
		await _shot_ending_suite(lang, "ending_en_" if lang == "en" else "ending_ko_")
		print("SCREENSHOT_QA_DONE scope=endings-en lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_DEMO_END_EN:
		var lang := _qa_language("en")
		await _shot_demo_end_surfaces(lang, "demo_end_en_" if lang == "en" else "demo_end_ko_")
		print("SCREENSHOT_QA_DONE scope=demo-end-en lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_TITLE_EN:
		var lang := _qa_language("en")
		await _shot_title_collection_surface(lang, "title_en_" if lang == "en" else "title_ko_")
		print("SCREENSHOT_QA_DONE scope=title-en lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_SURFACE_EN:
		await _shot_surface_en()
		print("SCREENSHOT_QA_DONE scope=surface-en lang=en dir=%s" % OUT_DIR)
		get_tree().quit(0)
		return

	await _shot_start_menu("ko", "00_start_menu")
	await _shot_start_menu("en", "00b_start_menu_en")
	await _shot_story_event("arc_intro_01_meal", "00h_en_story_intro", "en")
	await _shot_english_main_flow()
	_set_qa_language("ko")
	_prepare_main_game_state()
	_seed_portfolio()
	await _shot_story_event("arc_intro_01_meal", "00a_story_interview")

	await _boot_main_game()

	await _shot_event_gambling()
	await _shot_investment()
	await _shot_support_modals()
	await _shot_crisis_vignette()
	await _shot_ap_actions()
	await _shot_action_category_modals()
	await _shot_info_panel_tabs()
	await _shot_people()
	await _shot_holdem_club()
	await _shot_racetrack()
	await _shot_casino_suite()
	await _shot_ending("gangnam_dream", "13_ending_gangnam_win")
	await _shot_ending("empty_house", "13a_ending_empty_house")
	await _shot_ending("bankruptcy", "14_ending_bankruptcy")
	await _shot_ending("stable_success", "15_ending_stable_success")
	await _shot_ending("crypto_ghost", "16_ending_crypto_ghost")
	await _shot_ending("orthodox_pinnacle", "17_ending_orthodox_pinnacle")

	print("SCREENSHOT_QA_DONE dir=%s" % OUT_DIR)
	get_tree().quit(0)

func _qa_scope() -> String:
	var args: Array[String] = []
	for raw in OS.get_cmdline_user_args():
		args.append(str(raw))
	for raw in OS.get_cmdline_args():
		args.append(str(raw))
	for raw in args:
		var arg := raw.strip_edges().to_lower()
		if arg in ["moral", "moral-tint", "moral_tint", "--moral", "--moral-tint", "--moral_tint",
				"qa=moral", "--qa=moral", "qa=moral-tint", "--qa=moral-tint",
				"scope=moral", "--scope=moral", "scope=moral-tint", "--scope=moral-tint"]:
			return QA_SCOPE_MORAL
		if arg in ["transition", "transitions", "scene-transition", "scene_transition",
				"--transition", "--transitions", "--scene-transition", "--scene_transition",
				"qa=transition", "--qa=transition", "qa=scene-transition", "--qa=scene-transition",
				"scope=transition", "--scope=transition", "scope=scene-transition", "--scope=scene-transition"]:
			return QA_SCOPE_TRANSITION
		if arg in ["demo-flow", "demo_flow", "demo", "--demo-flow", "--demo_flow", "--demo",
				"qa=demo-flow", "--qa=demo-flow", "qa=demo_flow", "--qa=demo_flow",
				"scope=demo-flow", "--scope=demo-flow", "scope=demo_flow", "--scope=demo_flow"]:
			return QA_SCOPE_DEMO_FLOW
		if arg in ["demo-blackbox", "demo_blackbox", "--demo-blackbox", "--demo_blackbox",
				"qa=demo-blackbox", "--qa=demo-blackbox", "qa=demo_blackbox", "--qa=demo_blackbox",
				"scope=demo-blackbox", "--scope=demo-blackbox", "scope=demo_blackbox", "--scope=demo_blackbox"]:
			return QA_SCOPE_DEMO_BLACKBOX
		if arg in ["start-en", "start_en", "start", "--start-en", "--start_en",
				"qa=start-en", "--qa=start-en", "qa=start_en", "--qa=start_en",
				"scope=start-en", "--scope=start-en", "scope=start_en", "--scope=start_en"]:
			return QA_SCOPE_START_EN
		if arg in ["story-en", "story_en", "story", "--story-en", "--story_en",
				"qa=story-en", "--qa=story-en", "qa=story_en", "--qa=story_en",
				"scope=story-en", "--scope=story-en", "scope=story_en", "--scope=story_en"]:
			return QA_SCOPE_STORY_EN
		if arg in ["ap-en", "ap_en", "main-en", "main_en", "--ap-en", "--ap_en",
				"qa=ap-en", "--qa=ap-en", "qa=ap_en", "--qa=ap_en",
				"qa=main-en", "--qa=main-en", "scope=ap-en", "--scope=ap-en"]:
			return QA_SCOPE_AP_EN
		if arg in ["endings-en", "endings_en", "ending-en", "ending_en", "--endings-en", "--ending-en",
				"qa=endings-en", "--qa=endings-en", "qa=endings_en", "--qa=endings_en",
				"qa=ending-en", "--qa=ending-en", "scope=endings-en", "--scope=endings-en"]:
			return QA_SCOPE_ENDINGS_EN
		if arg in ["demo-end-en", "demo_end_en", "demo-ending-en", "demo_ending_en", "--demo-end-en",
				"qa=demo-end-en", "--qa=demo-end-en", "qa=demo_end_en", "--qa=demo_end_en",
				"scope=demo-end-en", "--scope=demo-end-en"]:
			return QA_SCOPE_DEMO_END_EN
		if arg in ["title-en", "title_en", "titles-en", "titles_en", "--title-en", "--title_en",
				"qa=title-en", "--qa=title-en", "qa=title_en", "--qa=title_en",
				"scope=title-en", "--scope=title-en", "scope=title_en", "--scope=title_en"]:
			return QA_SCOPE_TITLE_EN
		if arg in ["surface-en", "surface_en", "deck-en", "deck_en", "steamdeck-en", "steamdeck_en",
				"--surface-en", "--surface_en", "--deck-en", "--deck_en",
				"qa=surface-en", "--qa=surface-en", "qa=surface_en", "--qa=surface_en",
				"scope=surface-en", "--scope=surface-en", "scope=surface_en", "--scope=surface_en"]:
			return QA_SCOPE_SURFACE_EN
		if arg in ["casino-en", "casino_en", "--casino-en", "--casino_en",
				"qa=casino-en", "--qa=casino-en", "qa=casino_en", "--qa=casino_en",
				"scope=casino-en", "--scope=casino-en", "scope=casino_en", "--scope=casino_en"]:
			return QA_SCOPE_CASINO_EN
		if arg in ["casino", "casino-only", "--casino", "--casino-only",
				"qa=casino", "--qa=casino", "scope=casino", "--scope=casino"]:
			return QA_SCOPE_CASINO
	return "full"

func _qa_language(default_lang: String = "ko") -> String:
	var args: Array[String] = []
	for raw in OS.get_cmdline_user_args():
		args.append(str(raw))
	for raw in OS.get_cmdline_args():
		args.append(str(raw))
	for raw in args:
		var arg := raw.strip_edges().to_lower()
		if arg in ["en", "--en", "lang=en", "--lang=en", "language=en", "--language=en"]:
			return "en"
		if arg in ["ko", "--ko", "lang=ko", "--lang=ko", "language=ko", "--language=ko"]:
			return "ko"
	return default_lang

func _set_qa_language(lang: String) -> void:
	if SaveManager.has_method("set_setting"):
		SaveManager.set_setting("language", lang)
	if LocaleManager.has_method("set_language"):
		LocaleManager.set_language(lang)
	else:
		LocaleManager.language = lang
	if LocaleManager.language != lang:
		LocaleManager.language = lang
	DataRegistry.reload()

func _prepare_main_game_state() -> void:
	GameState.start_new_game()
	GameState.flags["prologue_done"] = true
	for c in ["chapter_33_seen","chapter_34_seen","chapter_35_seen","chapter_36_seen","chapter_37_seen"]:
		GameState.flags[c] = true
	GameState.age = 33
	GameState.turn = 14
	GameState.money = 3_500_000.0
	GameState.monthly_income = 2_240_000.0
	GameState.player_name = LocaleManager.DEFAULT_NAME_EN if LocaleManager.is_english() else LocaleManager.DEFAULT_NAME_KO
	GameState.current_job = {"name":("Office Worker" if LocaleManager.is_english() else "사무직"),"base_salary":2_240_000.0,"tier":2}
	GameState.health = 62
	GameState.mental = 58
	GameState.investment_skill = 35
	GameState.flags["has_received_paycheck"] = true
	GameState.flags["arc_invest_guidance_seen"] = true
	_seed_cast_state()
	_suppress_tutorial_overlays()

func _boot_main_game() -> void:
	# MainGame._ready 의 _begin_month 가 StoryMode 로 change_scene 하는 것을 막는다:
	# returning_from_story=true 로 진입점을 우회하고, 직후 전환 트윈을 매 프레임 죽인다.
	GameState.returning_from_story = true

	var packed: PackedScene = load("res://scenes/MainGame.tscn")
	_mg = packed.instantiate()
	get_tree().root.add_child.call_deferred(_mg)

	# 0.35s 전환 트윈이 change_scene 을 쏘기 전에 계속 죽인다 (현재 씬=QA 보호)
	for _i in range(40):
		_kill_transition()
		await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	_kill_transition()

func _shot_casino_suite(prefix: String = "") -> void:
	await _shot_minigame("jeongseon_casino", _shot_name(prefix, "08_jeongseon_casino"))
	await _shot_casino_table("baccarat_table", _shot_name(prefix, "09_baccarat_table"), prefix)
	await _shot_casino_table("blackjack_table", _shot_name(prefix, "10_blackjack_table"), prefix)
	await _shot_casino_table("slot_machine_game", _shot_name(prefix, "11_slot_machine"), prefix)
	await _shot_casino_table("roulette_table", _shot_name(prefix, "12_roulette_table"), prefix)
	await _shot_casino_table("big_wheel_game", _shot_name(prefix, "12a_bigwheel"), prefix)
	await _shot_casino_table("dai_sai_table", _shot_name(prefix, "12b_daisai_table"), prefix)

func _shot_name(prefix: String, base: String) -> String:
	return "%s%s" % [prefix, base] if not prefix.is_empty() else base

func _clear_output_dir() -> void:
	var dir := DirAccess.open(OUT_DIR)
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".png"):
			dir.remove(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

func _shot_start_menu(lang: String, shot_name: String) -> void:
	_set_qa_language(lang)
	_seed_start_menu_meta_progress()
	var packed: PackedScene = load("res://scenes/StartMenu.tscn")
	var menu := packed.instantiate()
	get_tree().root.add_child.call_deferred(menu)
	await get_tree().process_frame
	await _settle(0.8)
	if menu.has_method("_dismiss_splash"):
		menu._dismiss_splash()
	await _settle(0.6)
	await _save(shot_name)
	if is_instance_valid(menu):
		var parent := menu.get_parent()
		if parent != null:
			parent.remove_child(menu)
		menu.free()
	_remove_start_menu_nodes()
	await _settle(0.4)

func _shot_splash_screen(lang: String, shot_name: String) -> void:
	_set_qa_language(lang)
	var packed: PackedScene = load("res://scenes/SplashScreen.tscn")
	var splash := packed.instantiate()
	get_tree().root.add_child.call_deferred(splash)
	await get_tree().process_frame
	await _settle(2.75)
	await _save(shot_name)
	_remove_nodes_by_script("res://scenes/SplashScreen.gd")
	await _settle(0.25)

func _shot_start_menu_notice(lang: String, prefix: String) -> void:
	_set_qa_language(lang)
	MetaProgression.data["content_warning_seen"] = false
	_seed_start_menu_meta_progress()
	var packed: PackedScene = load("res://scenes/StartMenu.tscn")
	var menu := packed.instantiate()
	get_tree().root.add_child.call_deferred(menu)
	await get_tree().process_frame
	await _settle(0.8)
	await _save(prefix + "02a_start_menu_press_any_key")
	if menu.has_method("_dismiss_splash"):
		menu._dismiss_splash()
	await _settle(0.5)
	await _save(prefix + "02_start_menu")
	if menu.has_method("_show_content_warning"):
		menu._show_content_warning()
		await _settle(0.4)
		await _save(prefix + "03_content_notice")
	MetaProgression.data["content_warning_seen"] = true
	_remove_start_menu_nodes()
	await _settle(0.35)

func _remove_start_menu_nodes() -> void:
	var targets: Array[Node] = []
	_collect_start_menu_nodes(get_tree().root, targets)
	for node in targets:
		var parent := node.get_parent()
		if parent != null:
			parent.remove_child(node)
		node.free()

func _collect_start_menu_nodes(node: Node, targets: Array[Node]) -> void:
	var script_path := "res://scenes/StartMenu.gd"
	for child in node.get_children():
		if child == self:
			continue
		var script: Script = child.get_script()
		var is_start_menu := child.name == "StartMenu" or (script != null and script.resource_path == script_path)
		if is_start_menu:
			targets.append(child)
		else:
			_collect_start_menu_nodes(child, targets)

func _shot_story_event(event_id: String, shot_name: String, lang: String = "", settle_time: float = 1.1, finish_first_paragraph: bool = false, show_choices: bool = false) -> void:
	if not lang.is_empty():
		_set_qa_language(lang)
		_prepare_main_game_state()
	GameState.pending_story_queue = [event_id]
	var packed: PackedScene = load("res://scenes/StoryMode.tscn")
	var story := packed.instantiate()
	get_tree().root.add_child.call_deferred(story)
	await get_tree().process_frame
	await _settle(settle_time)
	if finish_first_paragraph and not event_id.begins_with("chapter_card_") \
			and bool(story.get("_typing")) and story.has_method("_on_advance"):
		story._on_advance()
		await _settle(0.2)
	if show_choices and not event_id.begins_with("chapter_card_") and story.has_method("_on_advance"):
		for _step in range(30):
			if bool(story.get("_showing_choices")):
				break
			story._on_advance()
			await _settle(0.16)
	await _save(shot_name)
	_remove_nodes_by_script("res://scenes/StoryMode.gd")
	GameState.pending_story_queue.clear()
	await _settle(0.3)

func _shot_opening_cinematic(lang: String, prefix: String) -> void:
	_set_qa_language(lang)
	var packed: PackedScene = load("res://scenes/OpeningCinematic.tscn")
	var cinema := packed.instantiate()
	get_tree().root.add_child.call_deferred(cinema)
	await get_tree().process_frame
	await _settle(1.2)
	await _save(prefix + "00_opening_first")
	if cinema.has_method("_skip_to_last"):
		cinema._skip_to_last()
		await _settle(1.35)
		await _save(prefix + "00_opening_final")
	_remove_nodes_by_script("res://scenes/OpeningCinematic.gd")
	await _settle(0.3)

func _shot_demo_flow(lang: String = "en") -> void:
	var prefix := "demo_en_" if lang == "en" else "demo_ko_"
	await _shot_opening_cinematic(lang, prefix)
	await _shot_story_event("chapter_card_33", prefix + "01_chapter_card_33", lang, 2.7)
	for event_id in [
		"arc_intro_01_meal",
		"arc_intro_02_dad_call",
		"arc_intro_03_sns",
		"arc_intro_04_hyunsu",
		"arc_chapter1_close",
	]:
		await _shot_story_event(event_id, prefix + event_id, lang, 0.45, true)
	await _shot_demo_loop_surfaces(lang, prefix)

func _shot_demo_blackbox(lang: String = "en") -> void:
	var prefix := "demo_en_blackbox_" if lang == "en" else "demo_ko_blackbox_"
	await _shot_splash_screen(lang, prefix + "00_splash")
	await _shot_opening_cinematic(lang, prefix)
	await _shot_start_menu_notice(lang, prefix)
	await _shot_story_event("chapter_card_33", prefix + "04_chapter_card_33", lang, 2.7)
	for event_id in [
		"arc_intro_01_meal",
		"arc_intro_02_dad_call",
		"arc_intro_03_sns",
		"arc_intro_04_hyunsu",
		"arc_chapter1_close",
	]:
		await _shot_story_event(event_id, prefix + event_id, lang, 0.45, true)
	await _shot_demo_loop_surfaces(lang, prefix)

func _shot_start_surfaces(lang: String = "en", prefix: String = "start_en_") -> void:
	await _shot_splash_screen(lang, prefix + "00_splash")
	await _shot_opening_cinematic(lang, prefix)
	await _shot_start_menu_notice(lang, prefix)

func _shot_story_surfaces(lang: String = "en", prefix: String = "story_en_") -> void:
	await _shot_story_event("chapter_card_33", prefix + "01_chapter_card_33", lang, 2.7)
	for event_id in [
		"arc_intro_01_meal",
		"arc_intro_02_dad_call",
		"arc_intro_03_sns",
		"arc_intro_04_hyunsu",
		"arc_chapter1_close",
	]:
		await _shot_story_event(event_id, prefix + event_id, lang, 0.45, true)
	await _shot_story_event("arc_intro_02_dad_call", prefix + "02b_story_choices", lang, 0.45, true, true)

func _shot_ap_shell_surfaces(lang: String = "en", prefix: String = "ap_en_") -> void:
	_set_qa_language(lang)
	_prepare_main_game_state()
	_seed_portfolio()
	_seed_info_panel_state(lang)
	await _boot_main_game()
	_mg.current_event = {}
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	await _settle(0.8)
	await _save(prefix + "03_ap_actions")
	await _shot_action_category_modal("_open_cat_money", prefix + "04_money_modal")
	await _shot_action_category_modal("_open_cat_people", prefix + "05_people_modal")
	await _shot_action_category_modal("_open_cat_life", prefix + "06_life_modal")
	await _shot_info_panel_tabs(lang, prefix)
	await _shot_people(prefix)

func _shot_demo_end_surfaces(lang: String = "en", prefix: String = "demo_end_en_") -> void:
	await _shot_demo_loop_surfaces(lang, prefix)

func _shot_title_collection_surface(lang: String = "en", prefix: String = "title_en_") -> void:
	_set_qa_language(lang)
	_prepare_main_game_state()
	_seed_portfolio()
	MetaProgression.data["unlocked_titles"] = [
		"gosiwon_survivor",
		"first_move",
		"apartment_life",
		"first_paycheck",
		"first_investment",
		"steady_youth",
		"father_peace_title",
	]
	await _boot_main_game()
	_mg.current_event = {}
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	if _mg.has_method("_open_title_collection"):
		_mg._open_title_collection()
		await _settle(0.8)
		await _save(prefix + "01_title_collection")
	else:
		print("SKIP title collection (no _open_title_collection)")

func _shot_ending_suite(lang: String = "en", prefix: String = "ending_en_") -> void:
	_set_qa_language(lang)
	_prepare_main_game_state()
	_seed_portfolio()
	await _boot_main_game()
	await _shot_ending("gangnam_dream", prefix + "13_ending_gangnam_win")
	await _shot_ending("empty_house", prefix + "13a_ending_empty_house")
	await _shot_ending("bankruptcy", prefix + "14_ending_bankruptcy")
	await _shot_ending("stable_success", prefix + "15_ending_stable_success")
	await _shot_ending("crypto_ghost", prefix + "16_ending_crypto_ghost")
	await _shot_ending("orthodox_pinnacle", prefix + "17_ending_orthodox_pinnacle")

func _shot_surface_en() -> void:
	var prefix := "surface_en_"
	await _shot_splash_screen("en", prefix + "00_splash")
	await _shot_start_menu("en", prefix + "01_start_menu")
	await _shot_story_event("arc_intro_01_meal", prefix + "02_story_intro", "en")
	await _shot_story_event("arc_intro_02_dad_call", prefix + "02b_story_choices", "en", 0.45, true, true)

	_set_qa_language("en")
	_prepare_main_game_state()
	_seed_portfolio()
	_seed_info_panel_state("en")
	await _boot_main_game()
	_mg.current_event = {}
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	await _settle(0.8)
	await _save(prefix + "03_ap_actions")
	await _shot_action_category_modal("_open_cat_money", prefix + "04_money_modal")
	await _shot_action_category_modal("_open_cat_people", prefix + "05_people_modal")
	await _shot_info_panel_tabs("en", prefix)
	await _shot_people(prefix)
	await _shot_holdem_club(prefix)
	await _shot_racetrack(prefix)
	await _shot_casino_suite(prefix)
	await _shot_ending("gangnam_dream", prefix + "13_ending_gangnam_win")
	await _shot_ending("empty_house", prefix + "13a_ending_empty_house")
	await _shot_ending("bankruptcy", prefix + "14_ending_bankruptcy")
	await _shot_ending("stable_success", prefix + "15_ending_stable_success")
	await _shot_ending("crypto_ghost", prefix + "16_ending_crypto_ghost")
	await _shot_ending("orthodox_pinnacle", prefix + "17_ending_orthodox_pinnacle")

func _shot_demo_loop_surfaces(lang: String, prefix: String) -> void:
	_set_qa_language(lang)
	_prepare_main_game_state()
	GameState.turn = 9
	GameState.month = 3
	GameState.week_of_month = 1
	await _boot_main_game()
	_mg.current_event = {}
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	await _settle(0.8)
	await _save(prefix + "02_ap_loop")

	GameState.turn = GameState.DEMO_TURN_LIMIT + 1
	GameState.month = 7
	GameState.week_of_month = 1
	var snap := {
		"date": GameState.get_date_string(),
		"money_before": GameState.money,
		"monthly_income": GameState.monthly_income,
		"fixed_expense": GameState.get_housing_expense(),
		"assets_before": GameState.get_total_asset_value(),
		"health_before": GameState.health,
		"mental_before": GameState.mental,
		"mental_before_pressure": GameState.mental,
		"actions": [
			_tr("✓ 💼 구직활동 → 사무직 취업", "✓ 💼 Job Hunt → hired as Office Worker"),
			_tr("✓ 📈 투자 → 첫 포트폴리오 구성", "✓ 📈 Invest → built first portfolio"),
		],
		"subsidy": false,
	}
	if _mg.has_method("_show_month_summary"):
		_mg._show_month_summary(snap)
	await _settle(0.9)
	await _save(prefix + "03_demo_complete_summary")
	if _mg.has_method("_show_demo_ending"):
		_mg._show_demo_ending()
	await _settle(0.9)
	await _save(prefix + "04_demo_ending_cta")

func _remove_nodes_by_script(script_path: String) -> void:
	var targets: Array[Node] = []
	_collect_nodes_by_script(get_tree().root, script_path, targets)
	for node in targets:
		var parent := node.get_parent()
		if parent != null:
			parent.remove_child(node)
		node.free()

func _collect_nodes_by_script(node: Node, script_path: String, targets: Array[Node]) -> void:
	for child in node.get_children():
		if child == self:
			continue
		var script: Script = child.get_script()
		if script != null and script.resource_path == script_path:
			targets.append(child)
		else:
			_collect_nodes_by_script(child, script_path, targets)

func _seed_portfolio() -> void:
	if not (GameState.portfolio is Dictionary):
		return
	GameState.portfolio["samsung"] = {"quantity": 30.0, "avg_price": 68000.0}
	GameState.portfolio["nvidia"] = {"quantity": 2.0, "avg_price": 820000.0}

func _seed_start_menu_meta_progress() -> void:
	MetaProgression.data["total_runs"] = 3
	MetaProgression.data["best_asset"] = 1_240_000_000.0
	MetaProgression.data["discovered_endings"] = [
		"ordinary_life",
		"stable_success",
		"bankruptcy",
		"crypto_ghost",
		"gangnam_dream",
	]

func _suppress_tutorial_overlays() -> void:
	for id in ["main_game", "holdem", "racetrack", "baccarat", "blackjack",
			"slot", "roulette", "bigwheel", "daisai", "scalping", "trading", "invest"]:
		TutorialOverlay._seen[id] = true

func _kill_transition() -> void:
	var st = get_tree().root.get_node_or_null("SceneTransition")
	if st and st.has_method("fade_in"):
		st.fade_in()

func _settle(t: float = 0.6) -> void:
	await get_tree().create_timer(t).timeout
	await get_tree().process_frame

func _save(shot_name: String, settle_time: float = 0.3) -> void:
	await _settle(settle_time)
	RenderingServer.force_draw()
	await get_tree().process_frame
	var viewport_texture := get_viewport().get_texture()
	if viewport_texture == null:
		_fail("Viewport texture is unavailable. Run ScreenshotQA with a real rendering driver.")
		return
	var img: Image = viewport_texture.get_image()
	if img == null or img.is_empty():
		_fail("Viewport image is empty. Run ScreenshotQA with a real rendering driver.")
		return
	var path := "%s/%s.png" % [OUT_DIR, shot_name]
	img.save_png(path)
	print("SHOT %s" % path)

func _fail(msg: String) -> void:
	push_error("SCREENSHOT_QA_FAIL " + msg)
	get_tree().quit(1)

func _force_event(ev: Dictionary) -> void:
	_mg.current_event = ev
	_mg._render_event()
	await _settle(0.4)
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	await _settle(0.5)

func _shot_event_gambling() -> void:
	await _force_event({
		"id": "qa_gambling",
		"title": "도박장 뒷골목",
		"description": "상철이 어깨를 짚는다. \"딱 한 판이면 돼...\" 심장이 빠르게 뛴다. 카드가 눈앞에서 흔들린다...",
		"tags": ["gambling", "stress"],
		"choices": [
			{"text": "판에 들어간다", "effects": {"money": -500000, "stress": 8}, "result_text": "칩을 밀었다."},
			{"text": "돌아선다", "effects": {"mental": 4}, "result_text": "문을 나섰다."},
		],
	})
	await _save("01_event_gambling_wave")

func _shot_investment() -> void:
	if _mg.has_method("_open_investments"):
		_mg._open_investments()
		await _settle(0.8)
		await _save("02_investment_portfolio_chart")
		var scroll: ScrollContainer = _mg.get("modal_scroll") as ScrollContainer
		if is_instance_valid(scroll):
			var bar: VScrollBar = scroll.get_v_scroll_bar()
			scroll.scroll_vertical = int(bar.max_value * 0.62)
			await _settle(0.4)
			await _save("02d_investment_asset_cards")
		_close_modal()
		await _settle(0.4)

func _shot_support_modals() -> void:
	if _mg.has_method("_open_bank"):
		_mg._open_bank()
		await _settle(0.7)
		await _save("02a_bank_modal")
		_close_modal()
		await _settle(0.3)
	if _mg.has_method("_open_shop"):
		_mg._open_shop()
		await _settle(0.7)
		await _save("02b_shop_modal")
		_close_modal()
		await _settle(0.3)
	if _mg.has_method("_open_system_menu"):
		_mg._open_system_menu()
		await _settle(0.7)
		await _save("02c_system_menu")
		_close_modal()
		await _settle(0.3)

func _shot_crisis_vignette() -> void:
	GameState.mental = 9
	GameState.health = 22
	if _mg.has_method("_update_vignette"):
		_mg._update_vignette()
	await _force_event({
		"id": "qa_crisis",
		"title": "벼랑 끝",
		"description": "통장은 비었고, 잠이 오지 않는다. 천장만 본다... 이대로 무너지는 걸까...",
		"tags": ["stress", "anxiety"],
		"choices": [
			{"text": "버틴다", "effects": {"mental": 2}, "result_text": "버텼다."},
		],
	})
	await _save("03_crisis_vignette")
	GameState.mental = 58
	GameState.health = 62
	if _mg.has_method("_update_vignette"):
		_mg._update_vignette()

func _shot_ap_actions() -> void:
	_mg.current_event = {}
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	await _settle(0.8)
	await _save("04_ap_actions_dashboard")

func _shot_moral_tint_states() -> void:
	var cases := [
		[-80.0, "03b_moral_black"],
		[0.0, "03c_moral_gray"],
		[80.0, "03d_moral_white"],
	]
	for data in cases:
		GameState.moral_tint = float(data[0])
		if _mg.has_method("_apply_moral_visuals"):
			_mg._apply_moral_visuals(GameState.moral_tint_norm(), GameState.moral_stage(), true)
		_mg.current_event = {}
		if _mg.has_method("_render_ap_actions"):
			_mg._render_ap_actions()
		await _settle(0.7)
		await _save(str(data[1]))
	GameState.moral_tint = 0.0
	if _mg.has_method("_apply_moral_visuals"):
		_mg._apply_moral_visuals(GameState.moral_tint_norm(), GameState.moral_stage(), true)
	await _shot_moral_choice_echo(-25.0, "03e_moral_black_choice_echo")
	await _shot_moral_choice_echo(25.0, "03f_moral_white_choice_echo")
	GameState.pending_tint_vignette = {}
	GameState.moral_tint = 0.0
	if _mg.has_method("_apply_moral_visuals"):
		_mg._apply_moral_visuals(GameState.moral_tint_norm(), GameState.moral_stage(), true)

func _shot_transition_states() -> void:
	var cases := [
		[-80.0, "transition_black"],
		[0.0, "transition_gray"],
		[80.0, "transition_white"],
	]
	_mg.current_event = {}
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	await _settle(0.5)
	for data in cases:
		GameState.moral_tint = float(data[0])
		if _mg.has_method("_apply_moral_visuals"):
			_mg._apply_moral_visuals(GameState.moral_tint_norm(), GameState.moral_stage(), true)
		if SceneTransition.has_method("_set_transition_alpha"):
			SceneTransition._set_transition_alpha(0.72)
		await _settle(0.2)
		await _save(str(data[1]), 0.05)
	if SceneTransition.has_method("_set_transition_alpha"):
		SceneTransition._set_transition_alpha(0.0)
	GameState.moral_tint = 0.0
	if _mg.has_method("_apply_moral_visuals"):
		_mg._apply_moral_visuals(GameState.moral_tint_norm(), GameState.moral_stage(), true)

func _shot_moral_choice_echo(delta: float, shot_name: String) -> void:
	GameState.pending_tint_vignette = {}
	GameState.moral_tint = 0.0
	if _mg.has_method("_apply_moral_visuals"):
		_mg._apply_moral_visuals(GameState.moral_tint_norm(), GameState.moral_stage(), true)
	_mg.current_event = {}
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	await _settle(0.2)
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	await get_tree().process_frame
	GameState.shift_moral_tint(delta)
	await _settle(0.04)
	await _save(shot_name, 0.02)

func _shot_english_main_flow() -> void:
	_set_qa_language("en")
	_prepare_main_game_state()
	_seed_portfolio()
	_seed_info_panel_state("en")
	await _boot_main_game()
	_mg.current_event = {}
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	await _settle(0.8)
	await _save("00c_en_ap_actions")
	await _shot_action_category_modal("_open_cat_money", "00d_en_money_modal")
	await _shot_action_category_modal("_open_cat_people", "00e_en_people_modal")
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	if _mg.has_method("_render_sidebars"):
		_mg._render_sidebars()
	if _mg.has_method("_toggle_info_panel"):
		_mg._toggle_info_panel()
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	await _settle(0.5)
	await _save("00f_en_info_stats")
	var tabs: TabContainer = _mg.get("info_tabs") as TabContainer
	if is_instance_valid(tabs):
		tabs.current_tab = 2
		GameState.flags["_last_info_tab"] = 2
		await _settle(0.35)
		await _save("00g_en_info_relations")
	if _mg.has_method("_toggle_info_panel"):
		_mg._toggle_info_panel()
	_remove_nodes_by_script("res://scenes/MainGame.gd")
	_mg = null
	await _settle(0.4)

func _shot_action_category_modals() -> void:
	await _shot_action_category_modal("_open_cat_money", "04g_action_money_modal")
	await _shot_action_category_modal("_open_cat_people", "04h_action_people_modal")
	await _shot_action_category_modal("_open_cat_life", "04i_action_life_modal")

func _shot_action_category_modal(method_name: String, shot_name: String) -> void:
	if not is_instance_valid(_mg) or not _mg.has_method(method_name):
		print("SKIP %s (no %s)" % [shot_name, method_name])
		return
	_mg.call(method_name)
	await _settle(0.7)
	await _save(shot_name)
	_close_modal()
	await _settle(0.3)

func _shot_info_panel_tabs(lang: String = "ko", prefix: String = "") -> void:
	_seed_info_panel_state(lang)
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	if _mg.has_method("_render_sidebars"):
		_mg._render_sidebars()
	if _mg.has_method("_toggle_info_panel"):
		_mg._toggle_info_panel()
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	await _settle(0.5)
	await _save(_shot_name(prefix, "04b_info_stats"))
	var tabs: TabContainer = _mg.get("info_tabs") as TabContainer
	if is_instance_valid(tabs):
		var shots := {
			1: "04c_info_market",
			2: "04d_info_relations",
			3: "04e_info_items",
			4: "04f_info_story",
		}
		for idx in shots.keys():
			tabs.current_tab = int(idx)
			GameState.flags["_last_info_tab"] = int(idx)
			await _settle(0.35)
			await _save(_shot_name(prefix, str(shots[idx])))
	if _mg.has_method("_toggle_info_panel"):
		_mg._toggle_info_panel()
	await _settle(0.3)

func _seed_info_panel_state(lang: String = "ko") -> void:
	if lang == "en":
		GameState.relationships = [
			{"id": "father", "name": "Father", "type": "family", "affection": 62, "trust": 58},
			{"id": "sangchul", "name": "Lim Sangchul", "type": "mentor", "affection": 56, "trust": 45},
			{"id": "daeun", "name": "Kim Daeun", "type": "friends", "affection": 48, "trust": 36},
		]
	else:
		GameState.relationships = [
			{"id": "father", "name": "아버지", "type": "family", "affection": 62, "trust": 58},
			{"id": "sangchul", "name": "임상철", "type": "mentor", "affection": 56, "trust": 45},
			{"id": "daeun", "name": "김다은", "type": "friends", "affection": 48, "trust": 36},
		]
	GameState.inventory.clear()
	GameState.add_item("item_vitamins", 1)
	GameState.add_item("item_meditation_app", 1)
	GameState.flags["arc_intro_hyunsu_seen"] = true
	GameState.flags["arc_sangchul_met_seen"] = true
	GameState.flags["arc_invest_guidance_seen"] = true
	GameState.flags["arc_sangchul_02_seen"] = true
	GameState.flags["arc_father_01_seen"] = true
	GameState.flags["arc_father_02_done"] = true
	GameState.flags["met_daeun"] = true
	GameState.flags["arc_daeun_01_seen"] = true
	GameState.run_theme = "steady_climb"

func _seed_cast_state() -> void:
	for data in [
		["father", 62],
		["sangchul", 56],
		["jiyeon", 44],
		["daeun", 48],
		["jaehyuk", 38],
	]:
		GameState.apply_cast_effect(str(data[0]), {"met": true, "affinity": int(data[1])})

func _close_modal() -> void:
	for m in ["_close_modal","_close_overlay","_dismiss_modal"]:
		if _mg.has_method(m):
			_mg.call(m)
			return

func _shot_people(prefix: String = "") -> void:
	# 인맥 카테고리 모달 — 캐스트 관계 상태
	GameState.flags["entered_network"] = true
	if _mg.has_method("_open_cat_people"):
		_mg._open_cat_people()
		await _settle(0.7)
		await _save(_shot_name(prefix, "05_people_relationships"))
		_close_modal()
		await _settle(0.4)

func _shot_minigame(node_name: String, shot_name: String) -> void:
	# 미니게임은 AP 우회하고 오버레이를 직접 open()
	GameState.flags["entered_network"] = true
	GameState.money = 5_000_000.0
	var node = _mg.get(node_name)
	if node == null or not node.has_method("open"):
		print("SKIP %s (no node)" % shot_name)
		return
	node.open()
	if node_name == "holdem_club" and node.has_method("_start_hand"):
		await _settle(0.4)
		node._buy_in = 100_000
		node._start_hand()
	await _settle(1.0)
	await _save(shot_name)
	# 오버레이 숨김 (다음 케이스 방해 방지)
	if "visible" in node:
		node.visible = false
	await _settle(0.3)

func _shot_holdem_club(prefix: String = "") -> void:
	GameState.flags["entered_network"] = true
	GameState.money = 5_000_000.0
	var node = _mg.get("holdem_club")
	if node == null or not node.has_method("open"):
		print("SKIP 06_holdem_club (no node)")
		return
	node.open()
	await _settle(0.4)
	node._buy_in = 100_000
	node._start_hand()
	await _settle(1.0)
	await _save(_shot_name(prefix, "06_holdem_club"))
	while node._community.size() < 5 and node._deck.size() > 0:
		node._community.append(node._deck.pop_back())
	node._do_showdown()
	await _settle(1.0)
	await _save(_shot_name(prefix, "06a_holdem_showdown"))
	if "visible" in node:
		node.visible = false
	await _settle(0.3)

func _shot_racetrack(prefix: String = "") -> void:
	GameState.flags["entered_network"] = true
	GameState.money = 5_000_000.0
	var node = _mg.get("racetrack")
	if node == null or not node.has_method("open"):
		print("SKIP 07_racetrack (no node)")
		return
	node.open()
	await _settle(0.8)
	await _save(_shot_name(prefix, "07_racetrack_betting"))
	node.skip_countdown_for_smoke = true
	node._bet_type = 1
	node._picks = [0]
	node._place_bet(10_000.0)
	await _settle(1.2)
	await _save(_shot_name(prefix, "07a_racetrack_race"))
	await _settle(4.2)
	await _save(_shot_name(prefix, "07b_racetrack_result"))
	node.skip_countdown_for_smoke = false
	if "visible" in node:
		node.visible = false
	await _settle(0.3)

func _shot_casino_table(node_name: String, shot_name: String, prefix: String = "") -> void:
	GameState.money = 10_000_000.0
	var node = _mg.get(node_name)
	if node == null or not node.has_method("open"):
		print("SKIP %s (no node)" % shot_name)
		return
	node.open()
	await _settle(0.4)
	match node_name:
		"baccarat_table":
			await _save(_shot_name(prefix, "09a_baccarat_betting"))
			node._set_stake(10_000)
			node._add_bet("B")
			node._deal()
			await _settle(3.2)
		"blackjack_table":
			await _save(_shot_name(prefix, "10a_blackjack_betting"))
			node._set_stake_and_deal(10_000)
			await _settle(0.8)
		"slot_machine_game":
			node._start_spin()
			node._pending_result = {
				"reels": [2, 2, 4],
				"multiplier": 3.0,
				"is_win": true,
				"win_type": LocaleManager.ui("체리 2개", "2 Cherries"),
				"symbols": ["CHERRY", "CHERRY", "LEMON"],
				"emojis": ["", "", ""],
			}
			await _settle(1.8)
		"roulette_table":
			node._select_bet_type(1)
			node._select_stake(10_000)
			node._do_bet()
			node._do_spin()
			await _settle(1.6)
			await _save(_shot_name(prefix, "12_roulette_spin"))
			await _settle(1.7)
		"big_wheel_game":
			node._select_segment(0)
			node._select_stake(10_000)
			node._do_spin()
			node._result_seg = 0
			node._target_angle = node._compute_target(0)
			await _settle(1.8)
			await _save(_shot_name(prefix, "12a_bigwheel_spin"))
			await _settle(1.7)
		"dai_sai_table":
			node._select_bet(0, -1)
			node._select_stake(10_000)
			node._do_roll()
			await _settle(1.7)
	await _save(shot_name)
	if "visible" in node:
		node.visible = false
	await _settle(0.3)

func _shot_ending(ending_id: String, shot_name: String) -> void:
	if _mg.has_method("_show_ending"):
		_seed_ending_state(ending_id)
		_mg._show_ending(ending_id)
		await _settle(1.0)
		await _save(shot_name)
		await _settle(0.3)

func _seed_ending_state(ending_id: String) -> void:
	GameState.age = 38
	GameState.year = 2031
	GameState.month = 1
	GameState.week_of_month = 1
	GameState.turn = 240
	GameState.portfolio.clear()
	GameState.loans = {"bank": 0.0, "second": 0.0}
	GameState.monthly_income = 0.0
	GameState.health = 62
	GameState.mental = 58
	GameState.reputation = 42
	GameState.route_orthodox = 8
	GameState.route_unorthodox = 8
	GameState.moral_tint = 0.0
	GameState.housing = "apartment"
	GameState.current_job = {"name":("Office Worker" if LocaleManager.is_english() else "사무직"), "base_salary": 2_240_000.0, "tier": 2}
	match ending_id:
		"gangnam_dream", "gangnam_dream_white", "full_circle":
			GameState.money = 3_180_000_000.0
			GameState.housing = "gangnam"
			GameState.health = 76
			GameState.mental = 74
			GameState.reputation = 88
			GameState.route_orthodox = 18
			GameState.route_unorthodox = 9
			GameState.moral_tint = 72.0 if ending_id == "gangnam_dream_white" else 24.0
		"empty_house", "jaehyuk_way", "lonely_rich":
			GameState.money = 3_050_000_000.0
			GameState.housing = "gangnam"
			GameState.health = 48
			GameState.mental = 34
			GameState.reputation = 70
			GameState.route_orthodox = 5
			GameState.route_unorthodox = 24
			GameState.moral_tint = -72.0
		"bankruptcy", "debt_spiral":
			GameState.money = -118_000_000.0
			GameState.housing = "gosiwon"
			GameState.health = 31
			GameState.mental = 22
			GameState.reputation = 4
			GameState.route_orthodox = 4
			GameState.route_unorthodox = 16
			GameState.moral_tint = -34.0
		"burnout", "mental_break", "career_burnout":
			GameState.money = 18_000_000.0
			GameState.health = 12 if ending_id == "burnout" else 28
			GameState.mental = 9 if ending_id == "mental_break" else 24
			GameState.reputation = 22
			GameState.moral_tint = -18.0
		"crypto_ghost":
			GameState.money = -42_000_000.0
			GameState.housing = "gosiwon"
			GameState.health = 26
			GameState.mental = 12
			GameState.reputation = 6
			GameState.route_orthodox = 2
			GameState.route_unorthodox = 26
			GameState.moral_tint = -86.0
		"stable_success":
			GameState.money = 1_050_000_000.0
			GameState.health = 70
			GameState.mental = 68
			GameState.reputation = 52
			GameState.route_orthodox = 14
			GameState.route_unorthodox = 10
			GameState.moral_tint = 6.0
		"orthodox_pinnacle", "career_climber":
			GameState.money = 1_240_000_000.0
			GameState.health = 58
			GameState.mental = 46
			GameState.reputation = 78
			GameState.route_orthodox = 28
			GameState.route_unorthodox = 4
			GameState.moral_tint = -4.0
			GameState.current_job = {"name":("Major Corporation Manager" if LocaleManager.is_english() else "대기업 관리자"), "base_salary": 7_200_000.0, "tier": 4}
		_:
			GameState.money = 180_000_000.0
	if is_instance_valid(_mg) and _mg.has_method("_apply_moral_visuals"):
		_mg._apply_moral_visuals(GameState.moral_tint_norm(), GameState.moral_stage(), true)
	if is_instance_valid(_mg) and _mg.has_method("_render_sidebars"):
		_mg._render_sidebars()
