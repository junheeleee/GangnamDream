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
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=romance-cg
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=romance-portraits
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=ap-en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=ap-act-en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=endings-en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=demo-end-en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=title-en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=tutorial-en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=job-en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=aruba-en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=scalping-en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=invest-en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=racetrack-en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=tendency-en
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
const QA_SCOPE_ROMANCE_CG := "romance_cg"
const QA_SCOPE_ROMANCE_PORTRAITS := "romance_portraits"
const QA_SCOPE_AP_EN := "ap_en"
const QA_SCOPE_AP_ACT_EN := "ap_act_en"
const QA_SCOPE_ENDINGS_EN := "endings_en"
const QA_SCOPE_DEMO_END_EN := "demo_end_en"
const QA_SCOPE_TITLE_EN := "title_en"
const QA_SCOPE_TUTORIAL_EN := "tutorial_en"
const QA_SCOPE_JOB_EN := "job_en"
const QA_SCOPE_ARUBA_EN := "aruba_en"
const QA_SCOPE_SCALPING_EN := "scalping_en"
const QA_SCOPE_INVEST_EN := "invest_en"
const QA_SCOPE_RACETRACK_EN := "racetrack_en"
const QA_SCOPE_TENDENCY_EN := "tendency_en"
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
	if scope == QA_SCOPE_ROMANCE_CG:
		var lang := _qa_language("en")
		await _shot_romance_cg_tints(lang, "romance_cg_en_" if lang == "en" else "romance_cg_ko_")
		print("SCREENSHOT_QA_DONE scope=romance-cg lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_ROMANCE_PORTRAITS:
		var lang := _qa_language("en")
		await _shot_romance_portrait_surfaces(lang, "romance_portrait_en_" if lang == "en" else "romance_portrait_ko_")
		print("SCREENSHOT_QA_DONE scope=romance-portraits lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_AP_EN:
		var lang := _qa_language("en")
		await _shot_ap_shell_surfaces(lang, "ap_en_" if lang == "en" else "ap_ko_")
		print("SCREENSHOT_QA_DONE scope=ap-en lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_AP_ACT_EN:
		var lang := _qa_language("en")
		await _shot_ap_act_surfaces(lang, "ap_act_en_" if lang == "en" else "ap_act_ko_")
		print("SCREENSHOT_QA_DONE scope=ap-act-en lang=%s dir=%s" % [lang, OUT_DIR])
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
	if scope == QA_SCOPE_TUTORIAL_EN:
		var lang := _qa_language("en")
		await _shot_tutorial_surfaces(lang, "tutorial_en_" if lang == "en" else "tutorial_ko_")
		print("SCREENSHOT_QA_DONE scope=tutorial-en lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_JOB_EN:
		var lang := _qa_language("en")
		await _shot_job_hunt_surfaces(lang, "job_en_" if lang == "en" else "job_ko_")
		print("SCREENSHOT_QA_DONE scope=job-en lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_ARUBA_EN:
		var lang := _qa_language("en")
		await _shot_aruba_surfaces(lang, "aruba_en_" if lang == "en" else "aruba_ko_")
		print("SCREENSHOT_QA_DONE scope=aruba-en lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_SCALPING_EN:
		var lang := _qa_language("en")
		await _shot_scalping_surfaces(lang, "scalping_en_" if lang == "en" else "scalping_ko_")
		print("SCREENSHOT_QA_DONE scope=scalping-en lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_INVEST_EN:
		var lang := _qa_language("en")
		await _shot_invest_surfaces(lang, "invest_en_" if lang == "en" else "invest_ko_")
		print("SCREENSHOT_QA_DONE scope=invest-en lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_RACETRACK_EN:
		var lang := _qa_language("en")
		_set_qa_language(lang)
		_prepare_main_game_state()
		await _boot_main_game()
		await _shot_racetrack("racetrack_en_" if lang == "en" else "racetrack_ko_")
		print("SCREENSHOT_QA_DONE scope=racetrack-en lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_TENDENCY_EN:
		var lang := _qa_language("en")
		await _shot_tendency_surface(lang, "tendency_en_" if lang == "en" else "tendency_ko_")
		print("SCREENSHOT_QA_DONE scope=tendency-en lang=%s dir=%s" % [lang, OUT_DIR])
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
		if arg in ["romance-cg", "romance_cg", "--romance-cg", "--romance_cg",
				"qa=romance-cg", "--qa=romance-cg", "qa=romance_cg", "--qa=romance_cg",
				"scope=romance-cg", "--scope=romance-cg", "scope=romance_cg", "--scope=romance_cg"]:
			return QA_SCOPE_ROMANCE_CG
		if arg in ["romance-portraits", "romance_portraits", "--romance-portraits", "--romance_portraits",
				"qa=romance-portraits", "--qa=romance-portraits", "qa=romance_portraits", "--qa=romance_portraits",
				"scope=romance-portraits", "--scope=romance-portraits"]:
			return QA_SCOPE_ROMANCE_PORTRAITS
		if arg in ["ap-en", "ap_en", "main-en", "main_en", "--ap-en", "--ap_en",
				"qa=ap-en", "--qa=ap-en", "qa=ap_en", "--qa=ap_en",
				"qa=main-en", "--qa=main-en", "scope=ap-en", "--scope=ap-en"]:
			return QA_SCOPE_AP_EN
		if arg in ["ap-act-en", "ap_act_en", "ap-acts-en", "ap_acts_en", "--ap-act-en", "--ap_act_en",
				"qa=ap-act-en", "--qa=ap-act-en", "qa=ap_act_en", "--qa=ap_act_en",
				"scope=ap-act-en", "--scope=ap-act-en", "scope=ap_act_en", "--scope=ap_act_en"]:
			return QA_SCOPE_AP_ACT_EN
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
		if arg in ["tutorial-en", "tutorial_en", "tutorial", "--tutorial-en", "--tutorial_en",
				"qa=tutorial-en", "--qa=tutorial-en", "qa=tutorial_en", "--qa=tutorial_en",
				"scope=tutorial-en", "--scope=tutorial-en", "scope=tutorial_en", "--scope=tutorial_en"]:
			return QA_SCOPE_TUTORIAL_EN
		if arg in ["job-en", "job_en", "jobs-en", "jobs_en", "--job-en", "--job_en",
				"qa=job-en", "--qa=job-en", "qa=job_en", "--qa=job_en",
				"scope=job-en", "--scope=job-en", "scope=job_en", "--scope=job_en"]:
			return QA_SCOPE_JOB_EN
		if arg in ["aruba-en", "aruba_en", "gig-en", "gig_en", "sidejob-en", "sidejob_en",
				"--aruba-en", "--aruba_en", "qa=aruba-en", "--qa=aruba-en",
				"qa=aruba_en", "--qa=aruba_en", "scope=aruba-en", "--scope=aruba-en"]:
			return QA_SCOPE_ARUBA_EN
		if arg in ["scalping-en", "scalping_en", "scalp-en", "scalp_en", "--scalping-en",
				"--scalping_en", "qa=scalping-en", "--qa=scalping-en",
				"qa=scalping_en", "--qa=scalping_en", "scope=scalping-en", "--scope=scalping-en"]:
			return QA_SCOPE_SCALPING_EN
		if arg in ["invest-en", "invest_en", "investment-en", "investment_en", "--invest-en",
				"--invest_en", "qa=invest-en", "--qa=invest-en", "qa=invest_en",
				"--qa=invest_en", "scope=invest-en", "--scope=invest-en"]:
			return QA_SCOPE_INVEST_EN
		if arg in ["racetrack-en", "racetrack_en", "race-en", "race_en", "--racetrack-en",
				"--racetrack_en", "qa=racetrack-en", "--qa=racetrack-en",
				"qa=racetrack_en", "--qa=racetrack_en", "scope=racetrack-en", "--scope=racetrack-en"]:
			return QA_SCOPE_RACETRACK_EN
		if arg in ["tendency-en", "tendency_en", "pattern-en", "pattern_en", "--tendency-en",
				"--tendency_en", "qa=tendency-en", "--qa=tendency-en", "qa=tendency_en",
				"--qa=tendency_en", "scope=tendency-en", "--scope=tendency-en"]:
			return QA_SCOPE_TENDENCY_EN
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
	await _settle(0.85)
	await _save(shot_name + "_publisher", 0.0)
	await _settle(1.9)
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

func _shot_story_event(event_id: String, shot_name: String, lang: String = "", settle_time: float = 1.1, finish_first_paragraph: bool = false, show_choices: bool = false, select_choice: int = -1, advance_paragraphs: int = 0, suppress_cg: bool = false) -> void:
	if not lang.is_empty():
		_set_qa_language(lang)
		_prepare_main_game_state()
	var overridden_event: Dictionary = {}
	var original_cg: Variant = null
	var had_cg := false
	if suppress_cg:
		overridden_event = DataRegistry.find_event(event_id)
		had_cg = overridden_event.has("cg")
		original_cg = overridden_event.get("cg")
		overridden_event.erase("cg")
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
	for _paragraph in range(advance_paragraphs):
		if story.has_method("_on_advance"):
			story._on_advance()
			await _settle(0.12)
			if bool(story.get("_typing")):
				story._on_advance()
				await _settle(0.12)
	if show_choices and not event_id.begins_with("chapter_card_") and story.has_method("_on_advance"):
		for _step in range(30):
			if bool(story.get("_showing_choices")):
				break
			story._on_advance()
			await _settle(0.16)
	if select_choice >= 0 and bool(story.get("_showing_choices")) and story.has_method("_on_choice"):
		GameState.flags["tut_stat_shown"] = true
		GameState.flags["tut_cast_shown"] = true
		story._on_choice(select_choice)
		await _settle(0.35)
		if bool(story.get("_typing")) and story.has_method("_on_advance"):
			story._on_advance()
			await _settle(0.25)
	await _save(shot_name)
	_remove_nodes_by_script("res://scenes/StoryMode.gd")
	if suppress_cg and had_cg:
		overridden_event["cg"] = original_cg
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
	# 플래시포워드 콜드오픈(신규) — 프롤로그보다 앞서 재생되는 5년 뒤 씬.
	await _shot_story_event("story_flashforward", prefix + "00_flashforward", lang, 1.0, true)
	await _shot_story_event("story_arrival", prefix + "00b_arrival_reset", lang, 0.45, true)
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
	await _shot_story_event("arc_intro_02_dad_call", prefix + "02c_story_result", lang, 0.45, true, true, 0)
	await _shot_story_event("arc_sangchul_confrontation", prefix + "03_direction_confrontation", lang, 1.0, true)
	await _shot_story_event("arc_daeun_proposal", prefix + "04_direction_proposal", lang, 1.2, true)
	await _shot_story_event("arc_season_sea_daeun", prefix + "05a_romance_sea_daeun_train", lang, 0.65, true)
	await _shot_story_event("arc_season_sea_daeun", prefix + "05b_romance_sea_daeun_reveal", lang, 0.45, true, false, -1, 2)
	await _shot_story_event("arc_season_sea_jiyeon", prefix + "06_romance_sea_jiyeon", lang, 0.65, true)
	await _shot_story_event("arc_season_fireworks_daeun", prefix + "07_romance_fireworks_daeun", lang, 0.65, true)
	await _shot_story_event("arc_season_fireworks_jiyeon", prefix + "08_romance_fireworks_jiyeon", lang, 0.65, true)
	await _shot_story_event("arc_season_cherry_daeun", prefix + "09_romance_cherry_daeun", lang, 0.65, true)
	await _shot_story_event("arc_season_cherry_jiyeon", prefix + "10_romance_cherry_jiyeon", lang, 0.65, true)
	await _shot_story_event("arc_daeun_first_kiss", prefix + "11_romance_first_kiss_daeun", lang, 0.65, true)
	await _shot_story_event("arc_jiyeon_first_kiss", prefix + "12_romance_first_kiss_jiyeon", lang, 0.65, true)

func _shot_romance_cg_tints(lang: String = "en", prefix: String = "romance_cg_en_") -> void:
	_set_qa_language(lang)
	var cases := [
		[-80.0, "black"],
		[0.0, "gray"],
		[80.0, "white"],
	]
	for data in cases:
		_prepare_main_game_state()
		GameState.moral_tint = float(data[0])
		await _shot_story_event("arc_season_cherry_daeun", prefix + str(data[1]), "", 0.55, true)
	GameState.moral_tint = 0.0

func _shot_romance_portrait_surfaces(lang: String = "en", prefix: String = "romance_portrait_en_") -> void:
	_set_qa_language(lang)
	var cases := [
		["arc_season_sea_daeun", "01_daeun_sea"],
		["arc_season_fireworks_daeun", "02_daeun_fireworks"],
		["arc_season_cherry_daeun", "03_daeun_cherry"],
		["arc_season_sea_jiyeon", "04_jiyeon_sea"],
		["arc_season_fireworks_jiyeon", "05_jiyeon_fireworks"],
		["arc_season_cherry_jiyeon", "06_jiyeon_cherry"],
		["arc_daeun_first_kiss", "07_daeun_first_kiss_reuse"],
		["arc_jiyeon_first_kiss", "08_jiyeon_first_kiss_reuse"],
	]
	for data in cases:
		await _shot_story_event(str(data[0]), prefix + str(data[1]), lang, 0.45, true, false, -1, 0, true)

func _shot_ap_shell_surfaces(lang: String = "en", prefix: String = "ap_en_") -> void:
	_set_qa_language(lang)
	_prepare_main_game_state()
	_seed_portfolio()
	_seed_info_panel_state(lang)
	await _boot_main_game()
	_mg.current_event = {}
	_seed_ap_action_log_surface_samples(lang)
	GameState.action_places_this_week = {
		"work": {"count": 1, "money": 1, "human": 0},
		"expedition": {"count": 1, "money": 1, "human": 0},
	}
	GameState.recent_action_places = ["home", "store", "work", "city", "expedition"]
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	await _settle(0.8)
	await _save(prefix + "03_ap_actions")
	var _old_grind_streak: int = GameState.grind_streak_weeks
	var _old_axis: Dictionary = GameState.action_axis_this_week.duplicate(true)
	var _old_ap: int = GameState.action_points
	GameState.grind_streak_weeks = 4
	GameState.action_axis_this_week = {"money": 1, "human": 0}
	GameState.action_points = GameState.max_action_points
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	await _settle(0.45)
	await _save(prefix + "03h_people_pressure_grind")
	GameState.action_points = 0
	GameState.action_axis_this_week = {"money": 2, "human": 0}
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	await _settle(0.45)
	await _save(prefix + "03i_money_only_closed")
	GameState.grind_streak_weeks = _old_grind_streak
	GameState.action_axis_this_week = _old_axis
	GameState.action_points = _old_ap
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	await _settle(0.2)
	# 연애 중 전용 '데이트' 카드가 레일에 뜨는지 확인 (다은 로맨스 시드)
	var _had_daeun_romance = GameState.flags.get("daeun_romance_started", false)
	GameState.flags["daeun_romance_started"] = true
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	await _settle(0.5)
	await _save(prefix + "03e_ap_date_card")
	GameState.flags["daeun_romance_started"] = _had_daeun_romance
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	await _settle(0.3)
	if _mg.has_method("_open_routine_modal"):
		GameState.action_points = GameState.max_action_points
		GameState.week_routine = ["study", "save"]
		_mg.call("_open_routine_modal")
		await _settle(0.55)
		await _save(prefix + "03f_routine_modal")
		_close_modal()
		await _settle(0.25)
	if _mg.has_method("_show_montage_card"):
		var assets_before: float = float(GameState.get_total_asset_value()) - 420_000.0
		_mg.call("_show_montage_card", 3, assets_before, GameState.health + 2, GameState.mental + 3, 2, 1, "arc")
		await _settle(0.55)
		await _save(prefix + "03g_time_record")
		_close_modal()
		await _settle(0.25)
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	await _settle(0.2)
	if _mg.has_method("_show_vignette"):
		_mg.call("_show_vignette",
			_tr("자기계발", "Self-Dev"),
			_tr("도서관에서 마감 직전까지 앉아 있었다. 창이 어두워질 때쯤 뭔가 연결이 됐다.",
				"Sat at the library until closing. By the time the windows darkened, something clicked."),
			{"intelligence": 4, "mental": 2, "money": -30000},
			"#5a6ea8")
		if _mg.has_method("_finish_typing"):
			_mg._finish_typing()
		await _settle(0.5)
		await _save(prefix + "03b_ap_vignette")
	if _mg.has_method("_show_result"):
		_mg.call("_show_result",
			_tr("그 선택은 조용히 장부에 남았다. 누군가는 너를 다르게 보기 시작했고, 너도 그 시선을 알아챘다.",
				"The choice stayed in the ledger. Someone began to see you differently, and you noticed the shift."),
			{"reputation": -3, "mental": -4, "money": -150000},
			{"cast_effects": {"father": {"affinity": -3}}})
		if _mg.has_method("_finish_typing"):
			_mg._finish_typing()
		await _settle(0.5)
		await _save(prefix + "03d_choice_result")
	_mg.current_event = {}
	_mg.set("_transient_bg_active", false)
	if _mg.has_method("_spawn_coin_burst"):
		_mg.call("_spawn_coin_burst")
		await _settle(0.12)
		await _save(prefix + "03c_money_burst")
	GameState.current_job = {}
	GameState.monthly_income = 0.0
	GameState.mental = 42
	GameState.health = 44
	GameState.money = -250_000.0
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	await _settle(0.5)
	await _save(prefix + "03a_ap_warnings")
	GameState.current_job = {"name":("Office Worker" if LocaleManager.is_english() else "사무직"), "base_salary":2_240_000.0, "tier":2}
	GameState.monthly_income = 2_240_000.0
	GameState.mental = 58
	GameState.health = 62
	GameState.money = 3_500_000.0
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	await _settle(0.2)
	await _shot_action_category_modal("_open_cat_money", prefix + "04_money_modal")
	if _mg.has_method("_open_investments"):
		_mg.call("_open_investments")
		await _settle(0.7)
		await _save(prefix + "04a_investment_modal")
		_close_modal()
		await _settle(0.3)
	await _shot_action_category_modal("_open_cat_people", prefix + "05_people_modal")
	await _shot_action_category_modal("_open_cat_life", prefix + "06_life_modal")
	await _shot_gift_picker(prefix)
	await _shot_info_panel_tabs(lang, prefix)
	await _shot_people(prefix)
	await _assert_ap_next_week_unlocked()

func _shot_ap_act_surfaces(lang: String = "en", prefix: String = "ap_act_en_") -> void:
	_set_qa_language(lang)
	_prepare_main_game_state()
	_seed_portfolio()
	_seed_info_panel_state(lang)
	await _boot_main_game()
	for act in range(1, 6):
		_seed_ap_act_state(act, lang)
		_mg.current_event = {}
		_mg.set("pending_result_text", "")
		if _mg.has_method("_render_ap_actions"):
			_mg.call("_render_ap_actions")
		if _mg.has_method("_refresh_all"):
			_mg.call("_refresh_all")
		if _mg.has_method("_finish_typing"):
			_mg.call("_finish_typing")
		await _settle(0.45)
		await _save("%s%02d_act%d" % [prefix, act, act])
		if act == 4 and _mg.has_method("_open_cat_people"):
			_mg.call("_open_cat_people")
			await _settle(0.45)
			await _save("%s%02da_act%d_people_modal" % [prefix, act, act])
			_close_modal()
			await _settle(0.2)

func _seed_ap_act_state(act: int, lang: String = "en") -> void:
	GameState.action_points = GameState.max_action_points
	GameState.action_axis_this_week = {"money": 0, "human": 0}
	GameState.action_places_this_week = {}
	GameState.recent_action_places = ["home"]
	GameState.player_name = LocaleManager.DEFAULT_NAME_EN if lang == "en" else LocaleManager.DEFAULT_NAME_KO
	GameState.current_job = {"name":("Office Worker" if lang == "en" else "사무직"), "base_salary":2_240_000.0, "tier":2}
	GameState.monthly_income = 2_240_000.0
	GameState.health = 64
	GameState.mental = 58
	GameState.money = 3_500_000.0
	GameState.investment_skill = 35
	GameState.flags["has_received_paycheck"] = true
	GameState.flags["arc_invest_guidance_seen"] = true
	GameState.flags["entered_network"] = act >= 2
	GameState.flags["racetrack_guide_met"] = act >= 3
	GameState.flags["racetrack_visited"] = act >= 3
	GameState.flags["casino_club_introduced"] = act >= 3
	GameState.flags["scalping_introduced"] = act >= 3
	GameState.flags["in_recovery_started"] = false
	GameState.flags["recovery_holding"] = false
	GameState.flags["beat_addiction"] = false
	GameState.flags["relapsed"] = false
	GameState.milestones_reached = {
		"10m": true,
		"50m": true,
		"100m": true,
		"500m": true,
		"1b": true,
		"2b": true,
	}
	match act:
		1:
			GameState.year = 2026
			GameState.month = 1
			GameState.week_of_month = 1
			GameState.turn = 8
			GameState.current_job = {}
			GameState.monthly_income = 0.0
			GameState.money = 900_000.0
			GameState.health = 60
			GameState.mental = 54
			GameState.flags["has_received_paycheck"] = false
			GameState.flags["arc_invest_guidance_seen"] = false
			GameState.action_axis_this_week = {"money": 0, "human": 0}
		2:
			GameState.year = 2027
			GameState.month = 3
			GameState.week_of_month = 2
			GameState.turn = 60
			GameState.money = 8_600_000.0
			GameState.investment_skill = 42
			GameState.action_axis_this_week = {"money": 1, "human": 0}
			GameState.action_places_this_week = {"work": {"count": 1, "money": 1, "human": 0}}
			GameState.recent_action_places = ["home", "store", "work"]
		3:
			GameState.year = 2028
			GameState.month = 6
			GameState.week_of_month = 3
			GameState.turn = 112
			GameState.money = 42_000_000.0
			GameState.investment_skill = 58
			GameState.mental = 49
			GameState.action_axis_this_week = {"money": 2, "human": 0}
			GameState.action_places_this_week = {"underground": {"count": 2, "money": 2, "human": 0}}
			GameState.recent_action_places = ["home", "work", "city", "underground"]
		4:
			GameState.year = 2029
			GameState.month = 8
			GameState.week_of_month = 2
			GameState.turn = 162
			GameState.money = 96_000_000.0
			GameState.investment_skill = 63
			GameState.mental = 44
			GameState.action_axis_this_week = {"money": 1, "human": 0}
			GameState.action_places_this_week = {"city": {"count": 1, "money": 1, "human": 0}}
			GameState.recent_action_places = ["work", "city", "underground", "expedition", "city"]
			_set_cast_relation_for_qa("father", 34)
			_set_cast_relation_for_qa("sangchul", 54)
			_set_cast_relation_for_qa("jiyeon", 58)
			_set_cast_relation_for_qa("daeun", 38)
			_set_cast_relation_for_qa("jaehyuk", 41)
		_:
			GameState.year = 2030
			GameState.month = 11
			GameState.week_of_month = 4
			GameState.turn = 220
			GameState.current_job = {"name":("Major Corporation Manager" if lang == "en" else "대기업 관리자"), "base_salary":7_200_000.0, "tier":4}
			GameState.monthly_income = 7_200_000.0
			GameState.money = 360_000_000.0
			GameState.investment_skill = 72
			GameState.health = 52
			GameState.mental = 39
			GameState.action_axis_this_week = {"money": 1, "human": 1}
			GameState.action_places_this_week = {
				"work": {"count": 1, "money": 1, "human": 0},
				"store": {"count": 1, "money": 0, "human": 1},
			}
			GameState.recent_action_places = ["underground", "work", "city", "store"]
			_set_cast_relation_for_qa("father", 18)
			_set_cast_relation_for_qa("sangchul", 49)
			_set_cast_relation_for_qa("jiyeon", 52)
			_set_cast_relation_for_qa("daeun", 28)
			_set_cast_relation_for_qa("jaehyuk", 33)
	if _mg != null and _mg.has_method("_seed_surface_background"):
		_mg.call("_seed_surface_background")

func _assert_ap_next_week_unlocked() -> void:
	if _mg == null:
		_fail("MainGame instance is unavailable for AP next-week regression.")
		return
	GameState.action_points = 0
	GameState.month = 1
	GameState.week_of_month = 2
	GameState.turn = 2
	_mg.current_event = {}
	_mg.set("pending_result_text", "")
	if _mg.has_method("_render_ap_actions"):
		_mg.call("_render_ap_actions")
	await _settle(0.15)
	var next_btn := _mg.get("next_button") as Button
	if next_btn == null:
		_fail("MainGame next_button is unavailable on AP shell.")
		return
	if next_btn.disabled:
		_fail("AP shell leaves next-week button disabled when AP is 0.")
		return
	if _mg.has_method("_on_next_month"):
		_mg.call("_on_next_month")
	await _settle(0.15)
	if GameState.week_of_month != 3:
		_fail("AP next-week action did not advance from week 2 to week 3.")
		return

func _shot_invest_surfaces(lang: String = "en", prefix: String = "invest_en_") -> void:
	_set_qa_language(lang)
	_prepare_main_game_state()
	_seed_portfolio()
	GameState.money = 5_000_000.0
	GameState.action_points = 2
	await _boot_main_game()
	_mg.current_event = {}
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	if _mg.has_method("_open_investments"):
		_mg.call("_open_investments")
		await _settle(0.7)
		await _save(prefix + "00_trade_page")
		if _mg.has_method("_set_invest_page"):
			for page_info in [[1, "01_holdings_page"], [2, "02_market_page"], [3, "03_bank_page"]]:
				_mg.call("_set_invest_page", int(page_info[0]))
				await _settle(0.45)
				await _save(prefix + str(page_info[1]))
			_mg.call("_set_invest_page", 0)
			await _settle(0.25)
	if _mg.has_method("_on_buy_asset"):
		_mg.call("_on_buy_asset", "samsung", 100_000)
		if _mg.has_method("_finish_typing"):
			_mg.call("_finish_typing")
		await _settle(0.55)
		await _save(prefix + "04_buy_toast")

func _shot_tendency_surface(lang: String = "en", prefix: String = "tendency_en_") -> void:
	_set_qa_language(lang)
	_prepare_main_game_state()
	await _boot_main_game()
	_mg.current_event = {}
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	GameState.tendency_realized = "invest"
	if _mg.has_method("_present_tendency_realization"):
		_mg.call("_present_tendency_realization", "invest")
	await _settle(0.7)
	await _save(prefix + "00_pattern_modal")

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

func _shot_tutorial_surfaces(lang: String = "en", prefix: String = "tutorial_en_") -> void:
	_set_qa_language(lang)
	_prepare_main_game_state()
	await _boot_main_game()
	_mg.current_event = {}
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	await _settle(0.4)

	var parent_control := _mg as Control
	if parent_control == null:
		print("SKIP tutorial surface (MainGame is not Control)")
		return

	await _capture_tutorial(parent_control, "main_game", [0, 1, 2], [
		prefix + "01_main_goal",
		prefix + "02_main_status",
		prefix + "03_main_actions",
	])
	await _capture_tutorial(parent_control, "baccarat", [0], [prefix + "04_baccarat"])
	await _capture_tutorial(parent_control, "slot", [0], [prefix + "05_slot"])

func _capture_tutorial(parent_control: Control, game_id: String, slide_indices: Array, shot_names: Array) -> void:
	_remove_nodes_by_script("res://scenes/TutorialOverlay.gd")
	TutorialOverlay.force_show(game_id, parent_control)
	await _settle(0.3)
	var overlay := _find_tutorial_overlay()
	if overlay == null:
		print("SKIP tutorial %s (overlay missing)" % game_id)
		return
	for i in range(min(slide_indices.size(), shot_names.size())):
		if overlay.has_method("_show_slide"):
			overlay.call("_show_slide", int(slide_indices[i]))
		await _settle(0.2)
		await _save(str(shot_names[i]), 0.1)
	_remove_nodes_by_script("res://scenes/TutorialOverlay.gd")
	await _settle(0.2)

func _find_tutorial_overlay() -> Node:
	var targets: Array[Node] = []
	_collect_nodes_by_script(get_tree().root, "res://scenes/TutorialOverlay.gd", targets)
	return targets[0] if not targets.is_empty() else null

func _shot_job_hunt_surfaces(lang: String = "en", prefix: String = "job_en_") -> void:
	_set_qa_language(lang)
	_prepare_main_game_state()
	await _boot_main_game()
	_mg.current_event = {}
	GameState.current_job = {}
	GameState.monthly_income = 0.0
	GameState.flags["resume_polished"] = false
	GameState.flags["interview_practiced"] = false
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	await _settle(0.4)

	if _mg.has_method("_open_cat_work"):
		_mg.call("_open_cat_work")
		await _settle(0.5)
		await _save(prefix + "00_work_category")
		_close_modal()
		await _settle(0.2)
	if _mg.has_method("_open_jobs"):
		_mg.call("_open_jobs")
		await _settle(0.5)
		await _save(prefix + "00a_jobs_missing_resume")
		_close_modal()
		await _settle(0.2)
		GameState.flags["resume_polished"] = true
		GameState.flags["interview_practiced"] = true
		_mg.call("_open_jobs")
		await _settle(0.5)
		await _save(prefix + "00b_jobs_ready")
		if _mg.has_method("_set_job_page"):
			_mg.call("_set_job_page", 1)
			await _settle(0.3)
			await _save(prefix + "00b_jobs_ready_tier2")
		_close_modal()
		await _settle(0.2)
	if _mg.has_method("_open_cat_work"):
		GameState.current_job = {
			"name": ("Office Worker" if LocaleManager.is_english() else "사무직"),
			"base_salary": 2_240_000.0,
			"tier": 2,
			"promotion_threshold": 12,
			"promotion_count": 0,
			"max_promotions": 3,
		}
		GameState.monthly_income = 2_240_000.0
		GameState.job_tenure = 10
		GameState.work_performance = 57
		_mg.call("_open_cat_work")
		await _settle(0.5)
		await _save(prefix + "00c_work_employed")
		_close_modal()
		await _settle(0.2)
		GameState.current_job = {}
		GameState.monthly_income = 0.0

	var node = _mg.get("job_hunt_game")
	if node == null or not node.has_method("open"):
		print("SKIP job hunt surface (no job_hunt_game)")
		return

	await _open_job_hunt_for_qa(node, 0)
	await _save(prefix + "01_resume_question")
	if node.has_method("_on_choose"):
		node.call("_on_choose", 0)
		await _settle(0.25)
		await _save(prefix + "02_resume_feedback")
		await _answer_job_hunt_remaining(node)
		await _settle(0.9)
		await _save(prefix + "03_resume_result")
	_hide_job_hunt_for_qa(node)

	await _open_job_hunt_for_qa(node, 1)
	await _save(prefix + "04_interview_question")
	if _force_job_hunt_pressure_question(node):
		await _settle(0.2)
		await _save(prefix + "04a_interview_pressure")
	if node.has_method("_on_choose"):
		node.call("_on_choose", 0)
		await _settle(0.25)
		await _save(prefix + "05_interview_feedback")
	_hide_job_hunt_for_qa(node)

func _open_job_hunt_for_qa(node: Node, mode: int) -> void:
	if _mg.has_method("_enter_minigame_overlay"):
		_mg.call("_enter_minigame_overlay", node)
	node.open(mode)
	await _settle(0.6)

func _answer_job_hunt_remaining(node: Node) -> void:
	for _i in range(8):
		await _settle(0.92)
		var questions: Array = node.get("_active_questions")
		var q_idx := int(node.get("_q_idx"))
		if q_idx >= questions.size():
			return
		if node.has_method("_on_choose"):
			node.call("_on_choose", 0)

func _force_job_hunt_pressure_question(node: Node) -> bool:
	var questions: Array = node.get("_active_questions")
	for i in range(questions.size()):
		var q = questions[i]
		if q is Dictionary and bool(q.get("surprise", false)):
			node.set("_q_idx", i)
			if node.has_method("_show_question"):
				node.call("_show_question")
			return true
	return false

func _shot_aruba_surfaces(lang: String = "en", prefix: String = "aruba_en_") -> void:
	_set_qa_language(lang)
	_prepare_main_game_state()
	await _boot_main_game()
	var node = _mg.get("aruba_game")
	if node == null or not node.has_method("open"):
		print("SKIP aruba surface (no aruba_game)")
		return

	GameState.current_job = {
		"id": "job_03",
		"name": ("Office Worker" if LocaleManager.is_english() else "사무직"),
		"base_salary": 2_240_000.0,
		"tier": 2,
	}
	await _open_aruba_for_qa(node)
	await _save(prefix + "00_cards_shift")
	_hide_aruba_for_qa(node)

	GameState.current_job = {
		"id": "job_01",
		"name": ("Convenience Store Clerk" if LocaleManager.is_english() else "편의점 알바"),
		"base_salary": 900_000.0,
		"tier": 1,
	}
	await _open_aruba_for_qa(node)
	await _save(prefix + "01_convenience_slots")
	if node.has_method("_conv_click_slot"):
		node.call("_conv_click_slot", 0)
		await _settle(0.25)
		await _save(prefix + "01a_convenience_actions")
	if node.has_method("_conv_handle"):
		node.call("_conv_handle", 0, 0)
		await _settle(0.25)
		await _save(prefix + "01b_convenience_result")
	_hide_aruba_for_qa(node)

	GameState.current_job = {
		"id": "job_02",
		"name": ("Delivery Rider" if LocaleManager.is_english() else "배달 라이더"),
		"base_salary": 1_300_000.0,
		"tier": 1,
	}
	await _open_aruba_for_qa(node)
	await _save(prefix + "02_delivery_route")
	_hide_aruba_for_qa(node)

func _open_aruba_for_qa(node: Node) -> void:
	if _mg.has_method("_enter_minigame_overlay"):
		_mg.call("_enter_minigame_overlay", node)
	node.open()
	await _settle(0.6)

func _hide_aruba_for_qa(node: Node) -> void:
	if "visible" in node:
		node.visible = false

func _shot_scalping_surfaces(lang: String = "en", prefix: String = "scalping_en_") -> void:
	_set_qa_language(lang)
	_prepare_main_game_state()
	GameState.money = 5_000_000.0
	GameState.investment_skill = 50
	await _boot_main_game()
	var node = _mg.get("scalping_game")
	if node == null or not node.has_method("open"):
		print("SKIP scalping surface (no scalping_game)")
		return
	if _mg.has_method("_enter_minigame_overlay"):
		_mg.call("_enter_minigame_overlay", node)
	node.open()
	await _settle(0.6)
	await _save(prefix + "00_setup")
	if node.has_method("_start_game"):
		node.call("_start_game")
		await _settle(1.2)
		await _save(prefix + "01_live")
	if node.has_method("_on_buy"):
		node.call("_on_buy")
		await _settle(0.35)
		await _save(prefix + "02_position_open")
	node.set("_in_position", false)
	node.set("_realized", 120_000.0)
	node.set("_trades", 2)
	if node.has_method("_end_game"):
		node.call("_end_game")
		await _settle(0.6)
		await _save(prefix + "03_result")
	if "visible" in node:
		node.visible = false

func _hide_job_hunt_for_qa(node: Node) -> void:
	if "visible" in node:
		node.visible = false
	if _mg.has_method("_exit_minigame_overlay"):
		_mg.call("_exit_minigame_overlay")

func _shot_ending_suite(lang: String = "en", prefix: String = "ending_en_") -> void:
	_set_qa_language(lang)
	_prepare_main_game_state()
	_seed_portfolio()
	await _boot_main_game()
	await _shot_ending("gangnam_dream", prefix + "13_ending_gangnam_win")
	await _shot_ending("gangnam_dream_white", prefix + "13b_ending_gangnam_white")
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
	await _shot_ending("gangnam_dream_white", prefix + "13b_ending_gangnam_white")
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
	GameState.money_weeks_total = 16
	GameState.human_weeks_total = 6
	GameState.grind_streak_weeks = 3
	GameState.contact_counts = {"daeun": 2}
	GameState.last_contact_turn = {"daeun": 18}
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
	if await _focus_modal_qa_surface("time_ledger"):
		await _save(prefix + "05_demo_time_ledger")

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
	if GameState.market_prices.is_empty():
		for asset in DataRegistry.assets:
			var asset_id: String = str(asset.get("id", ""))
			if asset_id.is_empty():
				continue
			GameState.market_prices[asset_id] = float(asset.get("initial_price", asset.get("base_price", 10_000.0)))
	GameState.market_prices["samsung"] = 72800.0
	GameState.market_prices["nvidia"] = 892000.0
	GameState.market_prices["bitcoin"] = 74_800_000.0
	GameState.market_prices["kospi_etf"] = 35_900.0
	GameState.price_history["samsung"] = [68000.0, 69400.0, 70400.0, 69800.0, 71300.0, 72800.0]
	GameState.price_history["nvidia"] = [820000.0, 798000.0, 838000.0, 866000.0, 884000.0, 892000.0]
	GameState.price_history["bitcoin"] = [80_000_000.0, 83_400_000.0, 78_200_000.0, 76_900_000.0, 73_500_000.0, 74_800_000.0]
	GameState.price_history["kospi_etf"] = [35000.0, 35120.0, 35080.0, 35400.0, 35620.0, 35900.0]
	GameState.news_log.append({
		"headline": "AI export orders lifted chip names overnight.",
		"market_effect": {"category": "us_stock", "power": 0.052},
	})
	NewsManager.last_news = [GameState.news_log[-1]]
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
		await _save("02_investment_trade_page")
		if _mg.has_method("_set_invest_page"):
			for page_info in [[1, "02a_investment_holdings_page"], [2, "02b_investment_market_page"], [3, "02c_investment_bank_page"]]:
				_mg.call("_set_invest_page", int(page_info[0]))
				await _settle(0.45)
				await _save(str(page_info[1]))
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
		if _mg.has_method("_set_internal_transition_progress_for_qa"):
			_mg._set_internal_transition_progress_for_qa(0.56, "event")
		if SceneTransition.has_method("_set_transition_alpha"):
			SceneTransition._set_transition_alpha(0.72)
		await _settle(0.2)
		await _save(str(data[1]), 0.05)
	if SceneTransition.has_method("_set_transition_alpha"):
		SceneTransition._set_transition_alpha(0.0)
	if _mg.has_method("_set_internal_transition_progress_for_qa"):
		_mg._set_internal_transition_progress_for_qa(0.0, "event")
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

func _shot_gift_picker(prefix: String) -> void:
	# 선물하기 선택 모달 — 인연에게 선물 보유 시 열린다.
	if not is_instance_valid(_mg) or not _mg.has_method("_open_gift_picker"):
		print("SKIP gift_picker (no _open_gift_picker)")
		return
	GameState.apply_cast_effect("daeun", {"met": true, "affinity": 24})
	GameState.add_item("gift_scarf", 1)
	GameState.add_item("gift_exhibit_catalog", 1)
	GameState.add_item("gift_can_coffee", 2)
	if GameState.action_points <= 0:
		GameState.action_points = 2
	_mg.call("_open_gift_picker", "daeun")
	await _settle(0.6)
	await _save(prefix + "06b_gift_picker")
	_close_modal()
	await _settle(0.3)

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
	if method_name == "_open_cat_people" and _mg.has_method("_set_people_page"):
		_mg.call("_set_people_page", 1)
		await _settle(0.35)
		await _save(shot_name + "_network")
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

func _seed_ap_action_log_surface_samples(_lang: String = "ko") -> void:
	if not is_instance_valid(_mg):
		return
	var samples := [
		_tr("✓ 💼 알바 시프트 — 피곤하지만 버텼다", "✓ 💼 Gig shift — held it together"),
		_tr("✓ 📈 투자 → KOSPI ETF 매수", "✓ 📈 Invest → bought KOSPI ETF"),
		_tr("✓ 🎰 정선 카지노", "✓ 🎰 Jeongseon Casino"),
	]
	_mg.set("turn_action_log", samples)

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
	for artifact_id in [
		"artifact_sangchul_card",
		"artifact_daeun_note",
		"artifact_father_call",
		"artifact_jiyeon_text",
		"artifact_jaehyuk_photo",
		"artifact_hyunsu_card",
	]:
		GameState.add_item(str(artifact_id), 1)
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
	if not bool(GameState.flags.get("_qa_surface_logs_seeded", false)):
		GameState.flags["_qa_surface_logs_seeded"] = true
		GameState.add_log(_tr("💼 알바 시프트 수입 8만원 (건강 62→58, 정신력 -3)", "💼 Gig shift income KRW 80K [urgent] (Health 62→58, Mental -3)"), "event")
		GameState.add_log(_tr("📈 투자 → KOSPI ETF 매수 50만원", "📈 Invest → bought KOSPI ETF KRW 500K"), "trade")
		GameState.add_log(_tr("습관이 굳어진다 — 버티는 사람", "A pattern emerges — steady climber"), "system")

func _seed_cast_state() -> void:
	for data in [
		["father", 62],
		["sangchul", 56],
		["jiyeon", 44],
		["daeun", 48],
		["jaehyuk", 38],
	]:
		_set_cast_relation_for_qa(str(data[0]), int(data[1]))

func _set_cast_relation_for_qa(person_id: String, affinity: int, met: bool = true) -> void:
	if not GameState.cast.has(person_id):
		GameState.cast[person_id] = {"stage": "unknown", "affinity": 0, "met": false, "flags": {}}
	var entry: Dictionary = GameState.cast[person_id]
	entry["affinity"] = clampi(affinity, -100, 100)
	entry["met"] = met
	if not entry.has("flags"):
		entry["flags"] = {}
	GameState.cast[person_id] = entry

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
	if node.has_method("_render"):
		node.call("_render")
	await _settle(0.3)
	await _save(_shot_name(prefix, "07c_racetrack_pick_badge"))
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
		if await _focus_modal_qa_surface("time_ledger"):
			await _save(shot_name + "_time_ledger")
		await _settle(0.3)

func _focus_modal_qa_surface(surface_id: String) -> bool:
	if not is_instance_valid(_mg):
		return false
	var target: Control = _find_qa_surface(_mg, surface_id)
	var scroll: ScrollContainer = _mg.get("modal_scroll") as ScrollContainer
	if target == null or not is_instance_valid(scroll):
		return false
	scroll.ensure_control_visible(target)
	await get_tree().process_frame
	await _settle(0.35)
	return true

func _find_qa_surface(node: Node, surface_id: String) -> Control:
	if node is Control and node.has_meta("qa_surface") and str(node.get_meta("qa_surface")) == surface_id:
		return node as Control
	for child in node.get_children():
		var found: Control = _find_qa_surface(child, surface_id)
		if found != null:
			return found
	return null

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
	GameState.money_weeks_total = 142
	GameState.human_weeks_total = 70
	GameState.grind_streak_weeks = 2
	GameState.contact_counts = {"daeun": 7}
	GameState.last_contact_turn = {"daeun": 217}
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
			GameState.money_weeks_total = 146
			GameState.human_weeks_total = 88
			GameState.contact_counts = {"daeun": 19}
			GameState.last_contact_turn = {"daeun": 239}
		"empty_house", "jaehyuk_way", "lonely_rich":
			GameState.money = 3_050_000_000.0
			GameState.housing = "gangnam"
			GameState.health = 48
			GameState.mental = 34
			GameState.reputation = 70
			GameState.route_orthodox = 5
			GameState.route_unorthodox = 24
			GameState.moral_tint = -72.0
			GameState.money_weeks_total = 211
			GameState.human_weeks_total = 15
			GameState.grind_streak_weeks = 11
			GameState.contact_counts = {"daeun": 0}
			GameState.last_contact_turn = {"daeun": 106}
		"bankruptcy", "debt_spiral":
			GameState.money = -118_000_000.0
			GameState.housing = "gosiwon"
			GameState.health = 31
			GameState.mental = 22
			GameState.reputation = 4
			GameState.route_orthodox = 4
			GameState.route_unorthodox = 16
			GameState.moral_tint = -34.0
			GameState.money_weeks_total = 196
			GameState.human_weeks_total = 22
			GameState.contact_counts = {"daeun": 1}
			GameState.last_contact_turn = {"daeun": 81}
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
			GameState.money_weeks_total = 224
			GameState.human_weeks_total = 8
			GameState.grind_streak_weeks = 18
			GameState.contact_counts = {"daeun": 0}
			GameState.last_contact_turn = {"daeun": 52}
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
