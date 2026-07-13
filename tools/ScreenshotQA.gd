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
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=gallery --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=year-identity --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=store --lang=en
##       godot --rendering-driver opengl3 --resolution 1920x1080 res://tools/ScreenshotQA.tscn -- --qa=trailer --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=locale-gate
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=i18n-layout --lang=zh-CN
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=story-en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=story-moral --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=romance-cg
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=romance-portraits
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=namsan --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=amusement --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=hometown --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=wedding-morning --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=commitment --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=breakup --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=ending-p1 --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=transport --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=first-snow --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=climate --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=event-visuals --lang=en
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
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=demo-input --lang=en --demo-build
## 헤드리스 더미 렌더러는 빈 텍스처를 주므로 x11+opengl3(xvfb) 필요.
## .tscn 으로 부팅해야 autoload(GameState 등)가 로드된다.

const OUT_DIR := "/tmp/gangnamdream_qa"
const QA_SCOPE_CASINO := "casino"
const QA_SCOPE_CASINO_EN := "casino_en"
const QA_SCOPE_MORAL := "moral"
const QA_SCOPE_DEMO_FLOW := "demo_flow"
const QA_SCOPE_DEMO_BLACKBOX := "demo_blackbox"
const QA_SCOPE_DEMO_INPUT := "demo_input"
const QA_SCOPE_START_EN := "start_en"
const QA_SCOPE_GALLERY := "gallery"
const QA_SCOPE_YEAR_IDENTITY := "year_identity"
const QA_SCOPE_STORE := "store"
const QA_SCOPE_TRAILER := "trailer"
const QA_SCOPE_LOCALE_GATE := "locale_gate"
const QA_SCOPE_I18N_LAYOUT := "i18n_layout"
const QA_SCOPE_STORY_EN := "story_en"
const QA_SCOPE_STORY_MORAL := "story_moral"
const QA_SCOPE_MORAL_ANCHORS := "moral_anchors"
const QA_SCOPE_ROMANCE_CG := "romance_cg"
const QA_SCOPE_ROMANCE_PORTRAITS := "romance_portraits"
const QA_SCOPE_NAMSAN := "namsan"
const QA_SCOPE_AMUSEMENT := "amusement"
const QA_SCOPE_HOMETOWN := "hometown"
const QA_SCOPE_WEDDING_MORNING := "wedding_morning"
const QA_SCOPE_COMMITMENT := "commitment"
const QA_SCOPE_BREAKUP := "breakup"
const QA_SCOPE_FIRST_SNOW := "first_snow"
const QA_SCOPE_CLIMATE := "climate"
const QA_SCOPE_EVENT_VISUALS := "event_visuals"
const QA_SCOPE_AP_EN := "ap_en"
const QA_SCOPE_AP_ACT_EN := "ap_act_en"
const QA_SCOPE_ENDINGS_EN := "endings_en"
const QA_SCOPE_ENDING_P0 := "ending_p0"
const QA_SCOPE_ENDING_P1 := "ending_p1"
const QA_SCOPE_TRANSPORT := "transport"
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
const YEAR_IDENTITY_SCENE_SAMPLE: Array[String] = [
	"arc_temptation_01",
	"cafe_listen_01",
	"arc_daeun_01_meet",
	"arc_sangchul_01_meet",
	"arc_job_first_rejection",
]
var _mg: Node = null

func _tr(ko: String, en: String) -> String:
	return LocaleManager.ui(ko, en)

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	_clear_output_dir()
	var scope: String = _qa_scope()
	if scope in [QA_SCOPE_DEMO_FLOW, QA_SCOPE_DEMO_BLACKBOX, QA_SCOPE_DEMO_INPUT] and not GameState.is_demo_build():
		_fail("Demo QA requires the explicit --demo-build test flag.")
		return
	if scope in [QA_SCOPE_CASINO, QA_SCOPE_CASINO_EN]:
		var lang := _qa_language("en" if scope == QA_SCOPE_CASINO_EN else "ko")
		var prefix := "en_" if lang == "en" else ""
		_set_qa_language(lang)
		_prepare_main_game_state()
		await _boot_main_game()
		await _shot_casino_suite(prefix)
		await _dispose_main_game()
		print("SCREENSHOT_QA_DONE scope=casino lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_MORAL:
		_set_qa_language(_qa_language("ko"))
		_prepare_main_game_state()
		_seed_portfolio()
		await _boot_main_game()
		await _shot_moral_tint_states()
		await _dispose_main_game()
		print("SCREENSHOT_QA_DONE scope=moral dir=%s" % OUT_DIR)
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_TRANSITION:
		_set_qa_language(_qa_language("en"))
		_prepare_main_game_state()
		_seed_portfolio()
		await _boot_main_game()
		await _shot_transition_states()
		await _dispose_main_game()
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
	if scope == QA_SCOPE_DEMO_INPUT:
		var lang := _qa_language("en")
		await _run_demo_input_route(lang)
		return
	if scope == QA_SCOPE_START_EN:
		var lang := _qa_language("en")
		await _shot_start_surfaces(lang, "start_en_" if lang == "en" else "start_ko_")
		print("SCREENSHOT_QA_DONE scope=start-en lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_GALLERY:
		var lang := _qa_language("en")
		await _shot_archive_surfaces(lang, "archive_en_" if lang == "en" else "archive_ko_")
		print("SCREENSHOT_QA_DONE scope=gallery lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_YEAR_IDENTITY:
		var lang := _qa_language("en")
		await _shot_year_identity_surfaces(lang, "year_en_" if lang == "en" else "year_ko_")
		print("SCREENSHOT_QA_DONE scope=year-identity lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_STORE:
		var lang := _qa_language("en")
		await _shot_store_surfaces(lang, "store_en_" if lang == "en" else "store_ko_")
		print("SCREENSHOT_QA_DONE scope=store lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_TRAILER:
		var lang := _qa_language("en")
		await _shot_trailer_surfaces(lang)
		print("SCREENSHOT_QA_DONE scope=trailer lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_LOCALE_GATE:
		await _shot_language_gate()
		print("SCREENSHOT_QA_DONE scope=locale-gate dir=%s" % OUT_DIR)
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_I18N_LAYOUT:
		var lang := _qa_language("zh-CN")
		await _shot_i18n_layout(lang)
		print("SCREENSHOT_QA_DONE scope=i18n-layout lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_STORY_EN:
		var lang := _qa_language("en")
		await _shot_story_surfaces(lang, "story_en_" if lang == "en" else "story_ko_")
		print("SCREENSHOT_QA_DONE scope=story-en lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_STORY_MORAL:
		var lang := _qa_language("en")
		await _shot_story_moral_surfaces(lang, "story_moral_en_" if lang == "en" else "story_moral_ko_")
		print("SCREENSHOT_QA_DONE scope=story-moral lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_MORAL_ANCHORS:
		var lang := _qa_language("en")
		await _shot_moral_anchor_surfaces(lang, "moral_anchors_en_" if lang == "en" else "moral_anchors_ko_")
		print("SCREENSHOT_QA_DONE scope=moral-anchors lang=%s dir=%s" % [lang, OUT_DIR])
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
	if scope == QA_SCOPE_NAMSAN:
		var lang := _qa_language("en")
		await _shot_namsan_surfaces(lang, "namsan_en_" if lang == "en" else "namsan_ko_")
		print("SCREENSHOT_QA_DONE scope=namsan lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_AMUSEMENT:
		var lang := _qa_language("en")
		await _shot_amusement_surfaces(lang, "amusement_en_" if lang == "en" else "amusement_ko_")
		print("SCREENSHOT_QA_DONE scope=amusement lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_HOMETOWN:
		var lang := _qa_language("en")
		await _shot_hometown_surfaces(lang, "hometown_en_" if lang == "en" else "hometown_ko_")
		print("SCREENSHOT_QA_DONE scope=hometown lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_WEDDING_MORNING:
		var lang := _qa_language("en")
		await _shot_wedding_morning_surfaces(lang, "wedding_morning_en_" if lang == "en" else "wedding_morning_ko_")
		print("SCREENSHOT_QA_DONE scope=wedding-morning lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_COMMITMENT:
		var lang := _qa_language("en")
		await _shot_commitment_surfaces(lang, "commitment_en_" if lang == "en" else "commitment_ko_")
		print("SCREENSHOT_QA_DONE scope=commitment lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_BREAKUP:
		var lang := _qa_language("en")
		await _shot_breakup_surfaces(lang, "breakup_en_" if lang == "en" else "breakup_ko_")
		print("SCREENSHOT_QA_DONE scope=breakup lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_FIRST_SNOW:
		var lang := _qa_language("en")
		await _shot_first_snow_surfaces(lang, "first_snow_en_" if lang == "en" else "first_snow_ko_")
		print("SCREENSHOT_QA_DONE scope=first-snow lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_CLIMATE:
		var lang := _qa_language("en")
		await _shot_climate_surfaces(lang, "climate_en_" if lang == "en" else "climate_ko_")
		print("SCREENSHOT_QA_DONE scope=climate lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_EVENT_VISUALS:
		var lang := _qa_language("en")
		await _shot_event_visual_surfaces(lang, "event_visual_en_" if lang == "en" else "event_visual_ko_")
		print("SCREENSHOT_QA_DONE scope=event-visuals lang=%s dir=%s" % [lang, OUT_DIR])
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
	if scope == QA_SCOPE_ENDING_P0:
		var lang := _qa_language("en")
		await _shot_ending_p0_surfaces(lang, "ending_p0_en_" if lang == "en" else "ending_p0_ko_")
		print("SCREENSHOT_QA_DONE scope=ending-p0 lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_ENDING_P1:
		var lang := _qa_language("en")
		await _shot_ending_p1_surfaces(lang, "ending_p1_en_" if lang == "en" else "ending_p1_ko_")
		print("SCREENSHOT_QA_DONE scope=ending-p1 lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_TRANSPORT:
		var lang := _qa_language("en")
		await _shot_transport_surfaces(lang, "transport_en_" if lang == "en" else "transport_ko_")
		print("SCREENSHOT_QA_DONE scope=transport lang=%s dir=%s" % [lang, OUT_DIR])
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
		if arg in ["demo-input", "demo_input", "--demo-input", "--demo_input",
				"qa=demo-input", "--qa=demo-input", "qa=demo_input", "--qa=demo_input",
				"scope=demo-input", "--scope=demo-input", "scope=demo_input", "--scope=demo_input"]:
			return QA_SCOPE_DEMO_INPUT
		if arg in ["start-en", "start_en", "start", "--start-en", "--start_en",
				"qa=start-en", "--qa=start-en", "qa=start_en", "--qa=start_en",
				"scope=start-en", "--scope=start-en", "scope=start_en", "--scope=start_en"]:
			return QA_SCOPE_START_EN
		if arg in ["gallery", "archive", "replay-gallery", "replay_gallery",
				"--gallery", "--archive", "qa=gallery", "--qa=gallery",
				"qa=archive", "--qa=archive", "scope=gallery", "--scope=gallery"]:
			return QA_SCOPE_GALLERY
		if arg in ["year-identity", "year_identity", "year-scenes", "year_scenes",
				"--year-identity", "--year_identity", "qa=year-identity", "--qa=year-identity",
				"qa=year_identity", "--qa=year_identity", "scope=year-identity", "--scope=year-identity"]:
			return QA_SCOPE_YEAR_IDENTITY
		if arg in ["store", "store-shots", "store_shots", "steam-store", "steam_store",
				"--store", "--store-shots", "--store_shots", "qa=store", "--qa=store",
				"scope=store", "--scope=store"]:
			return QA_SCOPE_STORE
		if arg in ["trailer", "store-trailer", "store_trailer", "--trailer",
				"qa=trailer", "--qa=trailer", "scope=trailer", "--scope=trailer"]:
			return QA_SCOPE_TRAILER
		if arg in ["locale-gate", "locale_gate", "language-gate", "language_gate",
				"--locale-gate", "--locale_gate", "qa=locale-gate", "--qa=locale-gate",
				"qa=locale_gate", "--qa=locale_gate", "scope=locale-gate", "--scope=locale-gate"]:
			return QA_SCOPE_LOCALE_GATE
		if arg in ["i18n-layout", "i18n_layout", "cjk-layout", "cjk_layout",
				"--i18n-layout", "--i18n_layout", "qa=i18n-layout", "--qa=i18n-layout",
				"qa=i18n_layout", "--qa=i18n_layout", "scope=i18n-layout", "--scope=i18n-layout"]:
			return QA_SCOPE_I18N_LAYOUT
		if arg in ["story-en", "story_en", "story", "--story-en", "--story_en",
				"qa=story-en", "--qa=story-en", "qa=story_en", "--qa=story_en",
				"scope=story-en", "--scope=story-en", "scope=story_en", "--scope=story_en"]:
			return QA_SCOPE_STORY_EN
		if arg in ["story-moral", "story_moral", "vn-moral", "vn_moral",
				"--story-moral", "--story_moral", "qa=story-moral", "--qa=story-moral",
				"qa=story_moral", "--qa=story_moral", "scope=story-moral", "--scope=story-moral"]:
			return QA_SCOPE_STORY_MORAL
		if arg in ["moral-anchors", "moral_anchors", "perception-anchors", "perception_anchors",
				"--moral-anchors", "--moral_anchors", "qa=moral-anchors", "--qa=moral-anchors",
				"qa=moral_anchors", "--qa=moral_anchors", "scope=moral-anchors", "--scope=moral-anchors"]:
			return QA_SCOPE_MORAL_ANCHORS
		if arg in ["romance-cg", "romance_cg", "--romance-cg", "--romance_cg",
				"qa=romance-cg", "--qa=romance-cg", "qa=romance_cg", "--qa=romance_cg",
				"scope=romance-cg", "--scope=romance-cg", "scope=romance_cg", "--scope=romance_cg"]:
			return QA_SCOPE_ROMANCE_CG
		if arg in ["romance-portraits", "romance_portraits", "--romance-portraits", "--romance_portraits",
				"qa=romance-portraits", "--qa=romance-portraits", "qa=romance_portraits", "--qa=romance_portraits",
				"scope=romance-portraits", "--scope=romance-portraits"]:
			return QA_SCOPE_ROMANCE_PORTRAITS
		if arg in ["namsan", "namsan-romance", "namsan_romance", "--namsan",
				"qa=namsan", "--qa=namsan", "scope=namsan", "--scope=namsan"]:
			return QA_SCOPE_NAMSAN
		if arg in ["amusement", "amusement-park", "amusement_park", "--amusement",
				"qa=amusement", "--qa=amusement", "scope=amusement", "--scope=amusement"]:
			return QA_SCOPE_AMUSEMENT
		if arg in ["hometown", "hometown-romance", "hometown_romance", "--hometown",
				"qa=hometown", "--qa=hometown", "scope=hometown", "--scope=hometown"]:
			return QA_SCOPE_HOMETOWN
		if arg in ["wedding-morning", "wedding_morning", "first-morning", "first_morning",
				"--wedding-morning", "--wedding_morning", "qa=wedding-morning", "--qa=wedding-morning",
				"qa=wedding_morning", "--qa=wedding_morning", "scope=wedding-morning", "--scope=wedding-morning"]:
			return QA_SCOPE_WEDDING_MORNING
		if arg in ["commitment", "proposal-wedding", "proposal_wedding", "--commitment",
				"qa=commitment", "--qa=commitment", "scope=commitment", "--scope=commitment"]:
			return QA_SCOPE_COMMITMENT
		if arg in ["breakup", "break-up", "romance-breakup", "romance_breakup", "--breakup",
				"qa=breakup", "--qa=breakup", "scope=breakup", "--scope=breakup"]:
			return QA_SCOPE_BREAKUP
		if arg in ["first-snow", "first_snow", "snow-romance", "snow_romance",
				"--first-snow", "--first_snow", "qa=first-snow", "--qa=first-snow",
				"qa=first_snow", "--qa=first_snow", "scope=first-snow", "--scope=first-snow"]:
			return QA_SCOPE_FIRST_SNOW
		if arg in ["climate", "weather", "season-weather", "season_weather",
				"--climate", "--weather", "qa=climate", "--qa=climate",
				"qa=weather", "--qa=weather", "scope=climate", "--scope=climate"]:
			return QA_SCOPE_CLIMATE
		if arg in ["event-visuals", "event_visuals", "seasonal-visuals", "seasonal_visuals",
				"--event-visuals", "--event_visuals", "qa=event-visuals", "--qa=event-visuals",
				"qa=event_visuals", "--qa=event_visuals", "scope=event-visuals", "--scope=event-visuals"]:
			return QA_SCOPE_EVENT_VISUALS
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
		if arg in ["ending-p0", "ending_p0", "endings-p0", "endings_p0", "--ending-p0", "--ending_p0",
				"qa=ending-p0", "--qa=ending-p0", "qa=ending_p0", "--qa=ending_p0",
				"scope=ending-p0", "--scope=ending-p0", "scope=ending_p0", "--scope=ending_p0"]:
			return QA_SCOPE_ENDING_P0
		if arg in ["ending-p1", "ending_p1", "endings-p1", "endings_p1", "--ending-p1", "--ending_p1",
				"qa=ending-p1", "--qa=ending-p1", "qa=ending_p1", "--qa=ending_p1",
				"scope=ending-p1", "--scope=ending-p1", "scope=ending_p1", "--scope=ending_p1"]:
			return QA_SCOPE_ENDING_P1
		if arg in ["transport", "rail", "train", "--transport", "qa=transport", "--qa=transport",
				"scope=transport", "--scope=transport"]:
			return QA_SCOPE_TRANSPORT
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
		if arg in ["ja", "--ja", "lang=ja", "--lang=ja", "language=ja", "--language=ja"]:
			return "ja"
		if arg in ["zh-cn", "--zh-cn", "lang=zh-cn", "--lang=zh-cn", "language=zh-cn", "--language=zh-cn"]:
			return "zh-CN"
		if arg in ["zh-tw", "--zh-tw", "lang=zh-tw", "--lang=zh-tw", "language=zh-tw", "--language=zh-tw"]:
			return "zh-TW"
	return default_lang

func _set_qa_language(lang: String) -> void:
	if SaveManager.has_method("set_setting"):
		SaveManager.set_setting("language", lang)
		SaveManager.set_setting("language_gate_seen", true)
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
	GameState.flags.erase("route_career")
	GameState.flags.erase("route_invest")
	GameState.flags.erase("route_startup")
	_seed_cast_state()
	_suppress_tutorial_overlays()

func _prepare_story_event_fixture(event_id: String) -> void:
	match event_id:
		"arc_first_job_week_convenience":
			GameState.current_job = {
				"id": "job_01", "name": "Convenience Store Night Shift",
				"category": "survival", "base_salary": 1_320_000.0, "tier": 1,
			}
		"arc_first_job_week_delivery":
			GameState.current_job = {
				"id": "job_02", "name": "Delivery Rider",
				"category": "survival", "base_salary": 1_760_000.0, "tier": 1,
			}
		"arc_spec_career":
			GameState.current_job = {
				"id": "job_06", "name": "Large Company Employee",
				"category": "office", "base_salary": 4_400_000.0, "tier": 3,
			}
			GameState.flags["career_months_total"] = 12

func _boot_main_game() -> void:
	# MainGame._ready 의 _begin_month 가 StoryMode 로 change_scene 하는 것을 막는다:
	# returning_from_story=true 로 진입점을 우회하고, 직후 전환 트윈을 매 프레임 죽인다.
	GameState.returning_from_story = true

	var packed: PackedScene = load("res://scenes/MainGame.tscn")
	_mg = packed.instantiate()
	_mg.set_meta("_screenshot_qa_static_surface", true)
	get_tree().root.add_child.call_deferred(_mg)

	# 남아 있을 수 있는 전환 덮개를 걷어 실제 표면만 캡처한다.
	for _i in range(40):
		_kill_transition()
		await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	_kill_transition()

func _dispose_main_game() -> void:
	if is_instance_valid(_mg):
		_mg.queue_free()
		_mg = null
		await get_tree().process_frame
		await get_tree().process_frame

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

func _shot_language_gate() -> void:
	var packed := load("res://scenes/SplashScreen.tscn") as PackedScene
	var splash := packed.instantiate()
	splash.set("_force_language_gate_for_qa", true)
	get_tree().root.add_child.call_deferred(splash)
	await get_tree().process_frame
	await _settle(0.7)
	await _save("locale_00_first_language_choice")
	_remove_nodes_by_script("res://scenes/SplashScreen.gd")
	await _settle(0.25)

	# 같은 한국어를 다시 선택하는 경로에서도 기본 영문 이름이 남지 않아야 한다.
	_set_qa_language("ko")
	GameState.player_name = LocaleManager.DEFAULT_NAME_EN
	LocaleManager.set_language("ko")
	await _shot_start_menu("ko", "locale_01_korean_start_menu")
	await _shot_story_event("arc_jiyeon_narrow_room_1", "locale_02_korean_jiyeon_name", "ko", 0.45, true, false, -1, 2, true)

func _shot_i18n_layout(lang: String) -> void:
	_set_qa_language(lang)
	var canvas := ColorRect.new()
	canvas.color = Color("111318")
	canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child.call_deferred(canvas)
	await get_tree().process_frame

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(820.0, 540.0)
	var viewport_size := get_viewport().get_visible_rect().size
	panel.position = (viewport_size - panel.custom_minimum_size) * 0.5
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("171a20")
	panel_style.border_color = Color("7d828d")
	panel_style.set_border_width_all(1)
	panel_style.corner_radius_top_left = 4
	panel_style.corner_radius_top_right = 4
	panel_style.corner_radius_bottom_left = 4
	panel_style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", panel_style)
	canvas.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 52)
	margin.add_theme_constant_override("margin_right", 52)
	margin.add_theme_constant_override("margin_top", 44)
	margin.add_theme_constant_override("margin_bottom", 44)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 20)
	margin.add_child(column)
	var ui_font = load("res://assets/fonts/Pretendard-Regular.ttf") as Font

	var title := Label.new()
	title.text = "CJK LINE-WRAP QA  /  %s" % lang
	if ui_font != null:
		title.add_theme_font_override("font", ui_font)
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("f2c45c"))
	column.add_child(title)

	var rule := HSeparator.new()
	rule.modulate = Color("8b909a")
	column.add_child(rule)

	var samples := {
		"ja": "これは翻訳そのものではなく、長い日本語の文章が狭い画面でも文字単位で自然に折り返され、選択肢や重要な金額を隠さないことを確認するためのレイアウト検証文です。五年間の選択が、同じ街と同じ人を少しずつ違って見せていきます。",
		"zh-CN": "这不是正式翻译，而是一段专门用于界面测试的长文本。它用来确认中文在较窄的屏幕上能够自然换行，不会遮挡选项、金额或继续提示。五年里的每一次选择，都会让同一座城市和同一个人呈现出不同的样子。",
		"zh-TW": "這不是正式翻譯，而是一段專門用於介面測試的長文字。它用來確認中文在較窄的螢幕上能夠自然換行，不會遮擋選項、金額或繼續提示。五年裡的每一次選擇，都會讓同一座城市和同一個人呈現出不同的樣子。",
	}
	var body := Label.new()
	body.text = str(samples.get(lang, samples["zh-CN"]))
	if ui_font != null:
		body.add_theme_font_override("font", ui_font)
	body.custom_minimum_size = Vector2(716.0, 270.0)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	body.add_theme_font_size_override("font_size", 30)
	body.add_theme_color_override("font_color", Color("e7e8eb"))
	column.add_child(body)

	var footer := Label.new()
	footer.text = "KRW 123,450,000  |  1280 x 800 safe area  |  prepared locale, not shipping"
	if ui_font != null:
		footer.add_theme_font_override("font", ui_font)
	footer.add_theme_font_size_override("font_size", 17)
	footer.add_theme_color_override("font_color", Color("9ea3ad"))
	column.add_child(footer)

	await _settle(0.4)
	if body.get_line_count() < 3:
		_fail("CJK sample did not wrap across at least three lines for %s." % lang)
		return
	await _save("i18n_layout_%s" % lang.replace("-", "_"), 0.0)
	canvas.queue_free()
	await get_tree().process_frame

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
	if menu.has_method("_open_load_overlay"):
		menu._open_load_overlay()
		await _settle(0.35)
		await _save(prefix + "02b_load_game")
		if menu.has_method("_close_load_overlay"):
			menu._close_load_overlay()
		await _settle(0.25)
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

func _shot_story_event(event_id: String, shot_name: String, lang: String = "", settle_time: float = 1.1, finish_first_paragraph: bool = false, show_choices: bool = false, select_choice: int = -1, advance_paragraphs: int = 0, suppress_cg: bool = false, advance_result_paragraphs: int = 0, expected_result_first: String = "", expected_result_last: String = "") -> void:
	if not lang.is_empty():
		_set_qa_language(lang)
		_prepare_main_game_state()
	_prepare_story_event_fixture(event_id)
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
	# Screenshot scopes own advancement explicitly; persisted AUTO would race the requested frame.
	if story.has_method("_set_auto_mode"):
		story._set_auto_mode(false, false)
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
		if bool(story.get("_showing_choices")):
			await _settle(0.4)
	if select_choice >= 0 and bool(story.get("_showing_choices")) and story.has_method("_on_choice"):
		GameState.flags["tut_stat_shown"] = true
		GameState.flags["tut_cast_shown"] = true
		story._on_choice(select_choice)
		await _settle(0.35)
		if bool(story.get("_typing")) and story.has_method("_on_advance"):
			if story.has_method("_complete_typing"):
				story._complete_typing()
			else:
				story._on_advance()
			await _settle(0.25)
		for _result_paragraph in range(advance_result_paragraphs):
			if story.has_method("_on_advance"):
				story._on_advance()
				await _settle(0.16)
				if bool(story.get("_typing")):
					if story.has_method("_complete_typing"):
						story._complete_typing()
					else:
						story._on_advance()
					await _settle(0.16)
	if not expected_result_first.is_empty():
		_assert_story_result_attention(story, expected_result_first, expected_result_last)
	var expected_event_ambience := {
		"amb_wallet_00": "rain",
		"kx_street_food": "street",
		"kx_seollal_sebae": "room",
		"arc_year2_close": "street",
		"arc_year3_close": "hangang",
		"arc_year4_close": "street",
		"arc_sangchul_03_network": "cafe",
	}
	if expected_event_ambience.has(event_id):
		var expected_ambience := str(expected_event_ambience[event_id])
		var actual_ambience := str(BGMPlayer.get("_current_ambience_key"))
		if actual_ambience != expected_ambience:
			_fail("%s ambience expected %s, got %s." % [event_id, expected_ambience, actual_ambience])
	_assert_hyunsu_visual_state(story, event_id, select_choice)
	_assert_cafe_visual_state(story, event_id)
	_assert_resolved_visual_debt_state(story, event_id)
	_assert_commitment_visual_state(story, event_id, select_choice)
	_assert_breakup_visual_state(story, event_id, select_choice)
	_assert_transport_visual_state(story, event_id)
	await _save(shot_name)
	_remove_nodes_by_script("res://scenes/StoryMode.gd")
	if suppress_cg and had_cg:
		overridden_event["cg"] = original_cg
	GameState.pending_story_queue.clear()
	await _settle(0.3)

func _assert_hyunsu_visual_state(story: Node, event_id: String, selected_choice: int) -> void:
	var expected_portrait_id := ""
	match event_id:
		"arc_y2_hyunsu_night_bus":
			expected_portrait_id = "hyunsu"
		"hyunsu_reunion_later":
			expected_portrait_id = "hyunsu_accounting"
		"hyunsu_year4_echo", "hyunsu_year5_call":
			expected_portrait_id = "hyunsu_civil_service" if GameState.flags.get("hyunsu_passed", false) else "hyunsu_accounting"
	if not expected_portrait_id.is_empty():
		var portrait := story.get("_portrait") as TextureRect
		var actual_portrait_path := ""
		if is_instance_valid(portrait) and portrait.texture != null:
			actual_portrait_path = portrait.texture.resource_path
		var expected_portrait_path := ImageRegistry.get_portrait(expected_portrait_id)
		if actual_portrait_path != expected_portrait_path:
			_fail("%s portrait expected %s, got %s." % [event_id, expected_portrait_path, actual_portrait_path])
	if event_id == "arc_y2_hyunsu_night_bus" and selected_choice == 0:
		var actual_background := str(story.get("_event_background_id"))
		if actual_background != "seoul_bus_terminal_night":
			_fail("Hyunsu send-off result expected bus terminal, got %s." % actual_background)
		var actual_ambience := str(BGMPlayer.get("_current_ambience_key"))
		if actual_ambience != "highway":
			_fail("Hyunsu send-off result expected highway ambience, got %s." % actual_ambience)

func _assert_cafe_visual_state(story: Node, event_id: String) -> void:
	var investor_events := [
		"cafe_00", "cafe_peek_01", "cafe_caught_honest", "cafe_talk_01",
		"cafe_humble", "cafe_bluff_01", "cafe_bluff_caught", "cafe_bluff_recover",
		"cafe_cb_honest_in", "cafe_cb_humiliated_00",
		"callback_cafe_honest_win_deeper", "callback_cafe_honest_trust_return",
	]
	var broker_events := [
		"cafe_cb_stole_call", "cafe_cb_stole_smart",
		"callback_cafe_jackpot_greed", "callback_cafe_smart_win_mentor",
	]
	var expected_portrait_id := ""
	if event_id == "cafe_cb_honest_00":
		expected_portrait_id = "player_tired"
	elif event_id in investor_events:
		expected_portrait_id = "cafe_investor"
	elif event_id in broker_events:
		expected_portrait_id = "cafe_broker_kim"
	else:
		return
	var portrait_frame := story.get("_portrait_frame") as Control
	if event_id == "cafe_peek_01" and not bool(story.get("_event_portrait_revealed")):
		if is_instance_valid(portrait_frame) and portrait_frame.visible:
			_fail("cafe_peek_01 revealed the folder owner before paragraph 1.")
		return
	if not is_instance_valid(portrait_frame) or not portrait_frame.visible:
		_fail("%s expected a visible %s portrait." % [event_id, expected_portrait_id])
		return
	var portrait := story.get("_portrait") as TextureRect
	var actual_portrait_path := ""
	if is_instance_valid(portrait) and portrait.texture != null:
		actual_portrait_path = portrait.texture.resource_path
	var expected_portrait_path := ImageRegistry.get_portrait(expected_portrait_id)
	if actual_portrait_path != expected_portrait_path:
		_fail("%s portrait expected %s, got %s." % [event_id, expected_portrait_path, actual_portrait_path])
	var name_tag := story.get("_name_tag") as Label
	var expected_name := str(ImageRegistry.get_person_info(expected_portrait_id).get("name", ""))
	if not is_instance_valid(name_tag) or name_tag.text != expected_name:
		_fail("%s name tag expected %s, got %s." % [event_id, expected_name, name_tag.text if is_instance_valid(name_tag) else "<missing>"])

func _assert_resolved_visual_debt_state(story: Node, event_id: String) -> void:
	var expected_background_id := ""
	match event_id:
		"amb_wallet_00":
			expected_background_id = "street_rainy_bus_stop_wallet"
		"kx_street_food":
			expected_background_id = "winter_street_bungeoppang"
		"kx_seollal_sebae":
			var expected_cg_path := ImageRegistry.get_cg("cg_seollal_sebae_family")
			if not bool(story.get("_current_uses_cg")):
				_fail("kx_seollal_sebae expected its dedicated CG to be active.")
			if str(story.get("_event_cg_path")) != expected_cg_path:
				_fail("kx_seollal_sebae CG expected %s, got %s." % [expected_cg_path, story.get("_event_cg_path")])
			var portrait_frame := story.get("_portrait_frame") as Control
			if is_instance_valid(portrait_frame) and portrait_frame.visible:
				_fail("kx_seollal_sebae portrait frame should be hidden behind the full-scene CG.")
			return
		_:
			return
	var actual_background_id := str(story.get("_event_background_id"))
	if actual_background_id != expected_background_id:
		_fail("%s background expected %s, got %s." % [event_id, expected_background_id, actual_background_id])
	var bg_img := story.get("_bg_img") as TextureRect
	var actual_background_path := ""
	if is_instance_valid(bg_img) and bg_img.texture != null:
		actual_background_path = bg_img.texture.resource_path
	var expected_background_path := ImageRegistry.get_background(expected_background_id)
	if actual_background_path != expected_background_path:
		_fail("%s background path expected %s, got %s." % [event_id, expected_background_path, actual_background_path])

func _assert_commitment_visual_state(story: Node, event_id: String, selected_choice: int) -> void:
	if event_id == "arc_daeun_proposal":
		var paragraph_index := int(story.get("_para_index"))
		var should_show_cg := selected_choice == 0 and paragraph_index >= 1
		var cg_active := bool(story.get("_current_uses_cg"))
		if cg_active != should_show_cg:
			_fail("Daeun proposal CG state expected %s at choice=%d paragraph=%d, got %s." % [
				should_show_cg, selected_choice, paragraph_index, cg_active])
			return
		if should_show_cg:
			_assert_story_cg(story, "cg_romance_proposal_daeun", event_id)
			return
		var background_id := str(story.get("_event_background_id"))
		if background_id != "cafe":
			_fail("Daeun proposal pre-result expected cafe background, got %s." % background_id)
			return
		var portrait := story.get("_portrait") as TextureRect
		var portrait_path := portrait.texture.resource_path if is_instance_valid(portrait) and portrait.texture != null else ""
		var expected_portrait := ImageRegistry.get_portrait("daeun_proposal")
		if portrait_path != expected_portrait:
			_fail("Daeun proposal portrait expected %s, got %s." % [expected_portrait, portrait_path])
		return
	if event_id == "arc_daeun_wedding_day":
		var expected_id := "cg_romance_wedding_daeun_full" if GameState.flags.get("daeun_wedding_full", false) else "cg_romance_wedding_daeun_small"
		_assert_story_cg(story, expected_id, event_id)
		return
	if event_id == "arc_jiyeon_wedding_gap":
		_assert_story_cg(story, "cg_romance_wedding_gap_jiyeon", event_id)

func _assert_breakup_visual_state(story: Node, event_id: String, selected_choice: int) -> void:
	if event_id not in ["arc_daeun_final_choice", "arc_jiyeon_verdict"]:
		return
	var paragraph_index := int(story.get("_para_index"))
	var reveal_paragraph := 3 if event_id == "arc_daeun_final_choice" else 2
	var expected_cg_id := "cg_romance_breakup_daeun" if event_id == "arc_daeun_final_choice" else "cg_romance_breakup_jiyeon"
	var should_show_cg := selected_choice == 1 and paragraph_index >= reveal_paragraph
	var cg_active := bool(story.get("_current_uses_cg"))
	if cg_active != should_show_cg:
		_fail("%s breakup CG expected %s at choice=%d paragraph=%d, got %s." % [
			event_id, should_show_cg, selected_choice, paragraph_index, cg_active])
		return
	if should_show_cg:
		_assert_story_cg(story, expected_cg_id, event_id)
		return
	var expected_background := "daeun_newlywed_home" if event_id == "arc_daeun_final_choice" else "jiyeon_newlywed_home"
	var actual_background := str(story.get("_event_background_id"))
	if actual_background != expected_background:
		_fail("%s pre-reveal background expected %s, got %s." % [event_id, expected_background, actual_background])
		return
	var portrait_frame := story.get("_portrait_frame") as Control
	if event_id == "arc_daeun_final_choice":
		if is_instance_valid(portrait_frame) and portrait_frame.visible:
			_fail("Daeun final choice must keep her portrait hidden while prose places her in the adjacent room.")
		return
	var portrait := story.get("_portrait") as TextureRect
	var actual_portrait := portrait.texture.resource_path if is_instance_valid(portrait) and portrait.texture != null else ""
	var expected_portrait := ImageRegistry.get_portrait("jiyeon_cold")
	if actual_portrait != expected_portrait:
		_fail("Jiyeon verdict portrait expected %s, got %s." % [expected_portrait, actual_portrait])

func _assert_transport_visual_state(story: Node, event_id: String) -> void:
	var expected_ids := {
		"arc_season_sea_daeun": "ktx_window",
		"arc_season_sea_jiyeon": "ktx_window",
		"arc_father_call_on_ktx": "ktx_window",
		"amb_holiday_00": "hometown_train_station",
	}
	if not expected_ids.has(event_id):
		return
	# Sea events deliberately replace the train backdrop with a full-scene CG later.
	# The transport contract only governs the pre-reveal frame.
	if bool(story.get("_current_uses_cg")):
		return
	var expected_id := str(expected_ids[event_id])
	var actual_id := str(story.get("_event_background_id"))
	if actual_id != expected_id:
		_fail("%s transport background expected %s, got %s." % [event_id, expected_id, actual_id])
		return
	var bg_img := story.get("_bg_img") as TextureRect
	var expected_path := ImageRegistry.get_background(expected_id)
	var actual_path := bg_img.texture.resource_path if is_instance_valid(bg_img) and bg_img.texture != null else ""
	if actual_path != expected_path:
		_fail("%s transport texture expected %s, got %s." % [event_id, expected_path, actual_path])

func _assert_story_cg(story: Node, expected_cg_id: String, context: String) -> void:
	var expected_path := ImageRegistry.get_cg(expected_cg_id)
	if not bool(story.get("_current_uses_cg")):
		_fail("%s expected active CG %s." % [context, expected_cg_id])
		return
	if str(story.get("_event_cg_path")) != expected_path:
		_fail("%s CG path expected %s, got %s." % [context, expected_path, story.get("_event_cg_path")])
		return
	var bg_img := story.get("_bg_img") as TextureRect
	var actual_path := bg_img.texture.resource_path if is_instance_valid(bg_img) and bg_img.texture != null else ""
	if actual_path != expected_path:
		_fail("%s rendered texture expected %s, got %s." % [context, expected_path, actual_path])
		return
	var portrait_frame := story.get("_portrait_frame") as Control
	if is_instance_valid(portrait_frame) and portrait_frame.visible:
		_fail("%s portrait frame should be hidden while full-scene CG is active." % context)
		return
	if story.find_child("StoryResultRecord", true, false) != null:
		_fail("%s delayed CG should clear the result record from its focal frame." % context)

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
		var generation_after_skip := int(cinema.get("_play_generation"))
		var rapid_click := InputEventMouseButton.new()
		rapid_click.button_index = MOUSE_BUTTON_LEFT
		rapid_click.pressed = true
		cinema._input(rapid_click)
		if int(cinema.get("_play_generation")) != generation_after_skip:
			_fail("Opening final card restarted when clicked before its prompt appeared.")
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
	for regression_event_id in [
		"arc_first_job_week_convenience",
		"arc_first_job_week_delivery",
		"arc_spec_career",
		"cafe_cb_honest_00",
	]:
		await _shot_story_event(regression_event_id, prefix + "regression_" + regression_event_id, lang, 0.45, true)
	await _shot_demo_loop_surfaces(lang, prefix)

func _run_demo_input_route(lang: String = "en") -> void:
	_set_qa_language(lang)
	seed(20260713)
	var original_meta := MetaProgression.data.duplicate(true)
	GameState.start_new_game(
		LocaleManager.DEFAULT_NAME_EN if lang == "en" else LocaleManager.DEFAULT_NAME_KO,
		"지방_상경", "직장형", "알바", "자유런", "현실")
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	GameState.returning_from_story = false
	GameState.pending_story_queue.clear()
	_suppress_tutorial_overlays()

	var packed := load("res://scenes/MainGame.tscn") as PackedScene
	if packed == null:
		MetaProgression.data = original_meta
		_fail("Demo input run could not load MainGame.tscn.")
		return
	var main := packed.instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().process_frame
	get_tree().current_scene = main

	var seen_events: Array[String] = []
	var input_count := 0
	var last_signature := ""
	var stagnant_steps := 0
	var completed := false
	var last_reported_turn := 0
	for _step in range(7000):
		await get_tree().create_timer(0.015).timeout
		var scene := get_tree().current_scene
		if not is_instance_valid(scene):
			continue
		var scene_script := scene.get_script() as Script
		var script_path := scene_script.resource_path if scene_script != null else ""
		var signature := script_path

		if script_path == "res://scenes/StoryMode.gd":
			var current: Dictionary = scene.get("_current")
			var event_id := str(current.get("id", ""))
			if not event_id.is_empty() and not seen_events.has(event_id):
				seen_events.append(event_id)
			signature += ":%s:%d:%s:%s:%s" % [
				event_id,
				int(scene.get("_para_index")),
				str(scene.get("_typing")),
				str(scene.get("_showing_choices")),
				str(scene.get("_pending_after_result")),
			]
			if bool(scene.get("_transitioning")) or event_id.is_empty():
				pass
			else:
				var tutorial_popup := scene.get("_tutorial_popup") as Control
				if is_instance_valid(tutorial_popup):
					await _press_qa_action("ui_accept")
					input_count += 1
				elif bool(scene.get("_showing_choices")):
					var focused := get_viewport().gui_get_focus_owner()
					if focused == null or not scene.is_ancestor_of(focused):
						var first_choice := _find_first_enabled_button(scene)
						if first_choice != null:
							first_choice.grab_focus()
							await get_tree().process_frame
					await _press_qa_action("ui_accept")
					input_count += 1
				else:
					await _press_qa_action("ui_accept")
					input_count += 1
		elif script_path == "res://scenes/MainGame.gd":
			if GameState.turn != last_reported_turn:
				last_reported_turn = GameState.turn
				print("DEMO_INPUT_PROGRESS week=%d ap=%d events=%d" % [
					GameState.turn, GameState.action_points, seen_events.size()])
			var modal := scene.get("modal_layer") as Control
			var modal_visible := is_instance_valid(modal) and modal.visible
			var modal_kind := str(scene.get("_modal_kind"))
			var cards: Array = scene.get("_ap_grid_cards")
			signature += ":%d:%d:%s:%s:%d:%s" % [
				GameState.turn,
				GameState.action_points,
				str(modal_visible),
				modal_kind,
				cards.size(),
				str(scene.get("pending_result_text")),
			]
			if _qa_scene_transition_active():
				pass
			elif modal_visible:
				var modal_text := _collect_control_text(modal)
				var wishlist_copy := "Add to Steam Wishlist" if lang == "en" else "Steam 위시리스트에 추가"
				if modal_kind == "demo_ending":
					if GameState.turn != GameState.DEMO_TURN_LIMIT + 1:
						MetaProgression.data = original_meta
						_fail("Demo CTA appeared at week %d instead of week 25." % GameState.turn)
						return
					if not GameState.has_reached_demo_limit():
						MetaProgression.data = original_meta
						_fail("Demo CTA appeared without the demo cutoff being active.")
						return
					var continuation_copy := "This record is not over" if lang == "en" else "이 기록은 끝난 게 아니라"
					if not modal_text.contains(wishlist_copy):
						MetaProgression.data = original_meta
						_fail("Demo ending is missing its Steam wishlist CTA.")
						return
					if not modal_text.contains(continuation_copy):
						MetaProgression.data = original_meta
						_fail("Demo ending is missing the full-version continuation promise.")
						return
					var commit_layer := scene.get("_ap_commit_layer") as Control
					if is_instance_valid(commit_layer) and commit_layer.visible:
						MetaProgression.data = original_meta
						_fail("Demo ending retained the previous AP commit overlay.")
						return
					var toast_layer := scene.get("_toast_container") as Control
					if is_instance_valid(toast_layer) and toast_layer.get_child_count() > 0:
						MetaProgression.data = original_meta
						_fail("Demo ending retained transient notification toasts.")
						return
					await _save("demo_%s_input_run_final" % lang)
					completed = true
					break
				var modal_body_node := scene.get("modal_body") as Control
				var modal_button := _find_first_enabled_button(modal_body_node) if is_instance_valid(modal_body_node) else null
				if modal_button != null:
					signature += ":focus=%s" % modal_button.text
					modal_button.grab_focus()
					await get_tree().process_frame
					await _press_qa_action("ui_accept")
					input_count += 1
			elif GameState.has_reached_demo_limit():
				pass
			else:
				var focused := get_viewport().gui_get_focus_owner()
				if bool(scene.get("_transient_bg_active")):
					var choice_surface := scene.get("choice_box") as Control
					var confirm := _find_first_enabled_button(choice_surface) if is_instance_valid(choice_surface) else null
					if confirm != null:
						confirm.grab_focus()
						await get_tree().process_frame
						await _press_qa_action("ui_accept")
						input_count += 1
				elif focused is Button and scene.is_ancestor_of(focused) \
						and focused != scene.get("next_button") and cards.find(focused) < 0:
					await _press_qa_action("ui_accept")
					input_count += 1
				elif GameState.action_points > 0 and cards.size() >= 4:
					var rest_candidate: Variant = cards[3]
					if not is_instance_valid(rest_candidate) or not rest_candidate is Button:
						continue
					var rest_card := rest_candidate as Button
					if rest_card.disabled:
						MetaProgression.data = original_meta
						_fail("Demo input run could not focus the Rest action at week %d." % GameState.turn)
						return
					rest_card.grab_focus()
					await get_tree().process_frame
					await _press_qa_action("ui_accept")
					input_count += 1
				elif GameState.action_points <= 0:
					var next_week := scene.get("next_button") as Button
					if is_instance_valid(next_week) and not next_week.disabled:
						next_week.grab_focus()
						await get_tree().process_frame
						await _press_qa_action("ui_accept")
						input_count += 1

		if signature == last_signature:
			stagnant_steps += 1
		else:
			last_signature = signature
			stagnant_steps = 0
		if stagnant_steps > 550:
			MetaProgression.data = original_meta
			_fail("Demo input run stalled at %s." % signature)
			return

	if not completed:
		MetaProgression.data = original_meta
		_fail("Demo input run did not reach the week-24 CTA within the safety limit: %s inputs=%d events=%d." % [
			last_signature, input_count, seen_events.size()])
		return
	for required_id in ["story_flashforward", "story_arrival", "chapter_card_33", "arc_chapter1_close"]:
		if not seen_events.has(required_id):
			MetaProgression.data = original_meta
			_fail("Demo input run never reached required story event %s." % required_id)
			return
	for forbidden_id in ["story_first_workday", "arc_spec_career"]:
		if seen_events.has(forbidden_id):
			MetaProgression.data = original_meta
			_fail("Demo input run reached contradictory event %s." % forbidden_id)
			return
	if str(GameState.current_job.get("id", "")) != "job_01":
		MetaProgression.data = original_meta
		_fail("Convenience-worker demo route lost its declared starting job.")
		return
	MetaProgression.data = original_meta
	print("DEMO_INPUT_RUN_OK weeks=24 inputs=%d events=%d job=job_01 cutoff=cta" % [
		input_count, seen_events.size()])
	get_tree().quit(0)

func _find_first_enabled_button(root: Node) -> Button:
	if root is Button and root.visible and not root.disabled and root.focus_mode != Control.FOCUS_NONE:
		return root as Button
	for child in root.get_children():
		var found := _find_first_enabled_button(child)
		if found != null:
			return found
	return null

func _press_qa_action(action_name: String) -> void:
	var pressed := InputEventAction.new()
	pressed.action = action_name
	pressed.pressed = true
	Input.parse_input_event(pressed)
	await get_tree().process_frame
	var released := InputEventAction.new()
	released.action = action_name
	released.pressed = false
	Input.parse_input_event(released)
	await get_tree().process_frame

func _qa_scene_transition_active() -> bool:
	var tween := SceneTransition.get("_tween") as Tween
	return tween != null and tween.is_running()

func _shot_start_surfaces(lang: String = "en", prefix: String = "start_en_") -> void:
	await _shot_splash_screen(lang, prefix + "00_splash")
	await _shot_opening_cinematic(lang, prefix)
	await _shot_start_menu_notice(lang, prefix)

func _shot_archive_surfaces(lang: String = "en", prefix: String = "archive_en_") -> void:
	_set_qa_language(lang)
	var original_meta := MetaProgression.data.duplicate(true)
	var cg_ids: Array = ImageRegistry.CG.keys()
	MetaProgression.data["unlocked_cgs"] = [str(cg_ids[0]), str(cg_ids[2]), str(cg_ids[3])]
	MetaProgression.data["seen_scenes"] = [
		"arc_date_namsan_daeun", "arc_date_park_jiyeon",
		"arc_season_sea_daeun", "arc_daeun_first_kiss",
	]
	MetaProgression.data["achievements"] = ["four_seasons"]

	var packed := load("res://scenes/StartMenu.tscn") as PackedScene
	var menu := packed.instantiate()
	get_tree().root.add_child.call_deferred(menu)
	await get_tree().process_frame
	await _settle(0.75)
	if menu.has_method("_dismiss_splash"):
		menu._dismiss_splash()
	await _settle(0.35)
	menu._open_archive_overlay()
	await _settle(0.45)
	_assert_archive_surface(menu, "CG gallery")
	await _save(prefix + "01_cg_gallery")

	var first_cg_id := str(cg_ids[0])
	menu._open_archive_cg_preview(first_cg_id, menu._archive_cg_title(first_cg_id, 0))
	await _settle(0.3)
	await _save(prefix + "02_cg_preview")
	menu._close_archive_cg_preview()
	menu._set_archive_tab(1)
	await _settle(0.35)
	_assert_archive_surface(menu, "scene replay")
	await _save(prefix + "03_scene_replay")

	menu._set_archive_tab(2)
	await _settle(0.35)
	_assert_archive_surface(menu, "hidden records")
	_assert_locked_hidden_names_absent(menu)
	await _save(prefix + "04_hidden_records")
	_remove_start_menu_nodes()
	await _settle(0.25)

	# Read-only replay contract: a choice may advance prose and reveal its CG,
	# but no serialized run state or achievement collection is allowed to move.
	_prepare_main_game_state()
	MetaProgression.data["seen_scenes"] = ["arc_daeun_first_kiss"]
	MetaProgression.data["unlocked_cgs"] = ["cg_romance_first_kiss_daeun"]
	var state_before: Dictionary = GameState.serialize().duplicate(true)
	var meta_before: Dictionary = MetaProgression.data.duplicate(true)
	GameState.pending_story_queue = ["arc_daeun_first_kiss"]
	GameState.story_return_scene = "res://scenes/StartMenu.tscn"
	GameState.story_replay_mode = true
	var story_packed := load("res://scenes/StoryMode.tscn") as PackedScene
	var story := story_packed.instantiate()
	get_tree().root.add_child.call_deferred(story)
	await get_tree().process_frame
	await _settle(0.35)
	story._on_choice(0)
	await _settle(0.35)
	var state_after: Dictionary = GameState.serialize().duplicate(true)
	if state_before != state_after:
		_fail("Archive replay mutated serialized GameState")
		return
	if meta_before != MetaProgression.data:
		_fail("Archive replay mutated persistent MetaProgression data")
		return
	if story.find_child("StoryResultRecord", true, false) != null:
		_fail("Archive replay exposed a mechanical choice result card")
		return
	await _save(prefix + "05_read_only_result")
	_remove_nodes_by_script("res://scenes/StoryMode.gd")
	MetaProgression.data = original_meta
	await _settle(0.25)

func _seed_year_scene_history(select_each_year: bool) -> void:
	GameState.run_seen_scenes_by_year = {}
	GameState.year_scenes = {}
	for year_index in range(1, 6):
		GameState.turn = (year_index - 1) * 48 + 12
		var target_scene := YEAR_IDENTITY_SCENE_SAMPLE[year_index - 1]
		var scene_sample: Array[String] = YEAR_IDENTITY_SCENE_SAMPLE.duplicate()
		if select_each_year:
			while scene_sample.size() > 4:
				var remove_index := scene_sample.size() - 1
				if scene_sample[remove_index] == target_scene:
					remove_index -= 1
				scene_sample.remove_at(remove_index)
		for scene_id in scene_sample:
			GameState.record_run_scene_seen(scene_id)
		if select_each_year:
			var candidates := GameState.get_year_scene_candidates(year_index, 4)
			if candidates.size() != 4:
				_fail("Year %d ending recap seed expected four candidates, got %d" % [year_index, candidates.size()])
				return
			if not GameState.record_year_scene(year_index, target_scene):
				_fail("Year %d ending recap seed could not record its selected scene" % year_index)
				return

func _shot_year_identity_surfaces(lang: String = "en", prefix: String = "year_en_") -> void:
	_set_qa_language(lang)
	for year_index in range(1, 6):
		_prepare_main_game_state()
		await _shot_story_event(
			"chapter_card_%d" % (32 + year_index),
			"%s%02d_chapter_year_%d" % [prefix, year_index, year_index],
			"", 2.7)

	_prepare_main_game_state()
	_seed_year_scene_history(false)
	GameState.turn = 47
	await _shot_story_event(
		"arc_year1_scene", prefix + "06_year_scene_choices", "", 0.45, true, true)

	_prepare_main_game_state()
	GameState.turn = 12
	await _shot_story_event(
		"cafe_listen_01", prefix + "07_timed_choice", "", 0.45, true, true)

	_prepare_main_game_state()
	GameState.turn = 145
	GameState.age = 36
	GameState.year = 2029
	GameState.month = 1
	GameState.week_of_month = 1
	await _boot_main_game()
	_mg._show_montage_card(
		3, GameState.get_total_asset_value(), GameState.health, GameState.mental, 2, 1, "cap", 3)
	await _settle(0.45)
	var montage_text := _collect_control_text(_mg)
	var expected_montage := "3 weeks passed." if lang == "en" else "3주가 흘렀다."
	if expected_montage not in montage_text:
		_fail("Y4 montage result did not show its localized three-week cap")
		return
	await _save(prefix + "08_y4_three_week_montage")
	await _dispose_main_game()

	_prepare_main_game_state()
	GameState.turn = 193
	GameState.age = 37
	GameState.year = 2030
	GameState.month = 1
	GameState.week_of_month = 1
	await _boot_main_game()
	if _mg.has_method("_refresh_goal_bar"):
		_mg._refresh_goal_bar()
	var goal_time := _mg.get("_goal_time_lbl") as Label
	var expected_countdown := "48 wk left" if lang == "en" else "남은 48주"
	if not is_instance_valid(goal_time) or goal_time.text != expected_countdown:
		_fail("Y5 HUD expected '%s', got '%s'" % [
			expected_countdown, goal_time.text if is_instance_valid(goal_time) else "<missing>"])
		return
	await _save(prefix + "09_y5_week_countdown")
	await _dispose_main_game()

	_prepare_main_game_state()
	_seed_year_scene_history(true)
	await _boot_main_game()
	await _shot_ending("stable_success", prefix + "10_ending_recap")
	var recap := _find_qa_surface(_mg, "year_scene_recap")
	var expected_heading := "FIVE YEARS, FIVE SCENES" if lang == "en" else "5년, 다섯 장면"
	if recap == null:
		_fail("Ending time ledger did not render the five-scene recap")
		return
	if expected_heading not in _collect_control_text(recap):
		_fail("Ending recap did not show localized heading '%s'" % expected_heading)
		return
	await _dispose_main_game()

func _shot_store_surfaces(lang: String = "en", prefix: String = "store_en_") -> void:
	_set_qa_language(lang)

	_prepare_main_game_state()
	GameState.moral_tint = 0.0
	await _shot_story_event(
		"story_flashforward", prefix + "01_cold_open", "", 0.9, true)

	_prepare_main_game_state()
	GameState.turn = 4
	await _shot_story_event(
		"arc_temptation_01", prefix + "02_money_mule_timer", "", 0.35, true, true)

	_prepare_main_game_state()
	GameState.turn = 145
	GameState.age = 36
	GameState.year = 2029
	GameState.month = 1
	GameState.week_of_month = 1
	await _boot_main_game()
	var assets_before := float(GameState.get_total_asset_value()) - 420_000.0
	_mg.call(
		"_show_montage_card", 3, assets_before, GameState.health + 2,
		GameState.mental + 3, 2, 1, "cap", 3)
	await _settle(0.55)
	var montage_text := _collect_control_text(_mg)
	var expected_montage := "3 weeks passed." if lang == "en" else "3주가 흘렀다."
	if expected_montage not in montage_text:
		_fail("Store montage shot did not show '%s'" % expected_montage)
		return
	await _save(prefix + "03_montage_card")
	await _dispose_main_game()

	_prepare_main_game_state()
	await _boot_main_game()
	_seed_ending_state("stable_success")
	GameState.year_scenes = {}
	_mg.call("_show_ending", "stable_success")
	await _settle(1.0)
	var ledger_focused := await _focus_modal_qa_surface("time_ledger")
	if not ledger_focused:
		_fail("Store time-ledger shot could not find the ending ledger")
		return
	await _save(prefix + "04_time_ledger")
	await _dispose_main_game()

	for moral_case in [
		[80.0, "05_moral_bright"],
		[-80.0, "06_moral_dark"],
	]:
		_prepare_main_game_state()
		GameState.turn = 72
		GameState.age = 34
		GameState.moral_tint = float(moral_case[0])
		await _shot_story_event(
			"arc_y2_worn_face", prefix + str(moral_case[1]), "", 0.55, true, true)

	_prepare_main_game_state()
	GameState.turn = 64
	GameState.age = 34
	GameState.month = 4
	GameState.flags["daeun_romance_started"] = true
	GameState.moral_tint = 32.0
	await _shot_story_event(
		"arc_season_cherry_daeun", prefix + "07_season_date_cg", "", 0.55, true, true)

	_prepare_main_game_state()
	_seed_year_scene_history(true)
	await _boot_main_game()
	_seed_ending_state("stable_success")
	_mg.call("_show_ending", "stable_success")
	await _settle(1.0)
	var recap_focused := await _focus_modal_qa_surface("year_scene_recap")
	if not recap_focused:
		_fail("Store ending-recap shot could not find the five-scene recap")
		return
	var recap := _find_qa_surface(_mg, "year_scene_recap")
	var expected_heading := "FIVE YEARS, FIVE SCENES" if lang == "en" else "5년, 다섯 장면"
	if recap == null or expected_heading not in _collect_control_text(recap):
		_fail("Store ending recap did not show '%s'" % expected_heading)
		return
	await _save(prefix + "08_ending_recap")
	await _dispose_main_game()

func _shot_trailer_surfaces(lang: String = "en") -> void:
	_set_qa_language(lang)

	_prepare_main_game_state()
	GameState.moral_tint = 0.0
	await _shot_story_event("story_flashforward", "trailer_01_cold_open", "", 0.9, true)
	await _shot_trailer_goal_dashboard()
	await _shot_trailer_timer_sequence()

	for moral_case in [
		[80.0, "trailer_06_tint_bright"],
		[0.0, "trailer_07_tint_gray"],
		[-80.0, "trailer_08_tint_dark"],
	]:
		_prepare_main_game_state()
		GameState.turn = 72
		GameState.age = 34
		GameState.moral_tint = float(moral_case[0])
		await _shot_story_event(
			"arc_y2_worn_face", str(moral_case[1]), "", 0.45, true, true)

	_prepare_main_game_state()
	GameState.flags["daeun_romance_started"] = true
	GameState.moral_tint = 32.0
	await _shot_story_event("arc_season_cherry_daeun", "trailer_09_romance_cherry", "", 0.45, true)
	_prepare_main_game_state()
	GameState.flags["daeun_romance_started"] = true
	GameState.moral_tint = 32.0
	await _shot_story_event(
		"arc_season_sea_daeun", "trailer_10_romance_sea", "", 0.35, true, false, -1, 2)
	_prepare_main_game_state()
	GameState.flags["daeun_romance_started"] = true
	GameState.moral_tint = 32.0
	await _shot_story_event("arc_season_fireworks_daeun", "trailer_11_romance_fireworks", "", 0.45, true)
	_prepare_wedding_morning_qa_state("daeun")
	GameState.moral_tint = 32.0
	await _shot_story_event(
		"arc_daeun_wedding_night", "trailer_12_romance_morning", "", 0.35,
		true, true, 0, 0, false, 1)

	_prepare_breakup_qa_state("daeun")
	await _shot_story_event(
		"arc_daeun_final_choice", "trailer_13_divorce_seal", "", 0.35,
		true, true, 1, 0, false, 3)
	_prepare_breakup_qa_state("jiyeon")
	await _shot_story_event(
		"arc_jiyeon_verdict", "trailer_14_departure", "", 0.35,
		true, true, 1, 0, false, 2)

	_prepare_main_game_state()
	await _boot_main_game()
	_seed_ending_state("lonely_rich")
	_mg.call("_show_ending", "lonely_rich")
	await _settle(0.8)
	var empty_table_preview := _find_ending_art_preview(_mg)
	var empty_table_path := ImageRegistry.get_cg("cg_ending_lonely_rich")
	if empty_table_preview == null or empty_table_preview.texture == null \
			or empty_table_preview.texture.resource_path != empty_table_path:
		_fail("Trailer catastrophe shot did not render the lonely-rich table CG.")
		return
	await _save("trailer_15_empty_table")
	await _dispose_main_game()

	await _shot_trailer_extended_surfaces()
	GameState.moral_tint = 0.0

func _shot_trailer_goal_dashboard() -> void:
	_prepare_main_game_state()
	GameState.turn = 1
	GameState.year = 2026
	GameState.month = 1
	GameState.week_of_month = 1
	GameState.money = 500_000.0
	GameState.monthly_income = 0.0
	GameState.current_job = {}
	GameState.action_points = 2
	GameState.flags.erase("has_received_paycheck")
	GameState.flags.erase("is_employed")
	await _boot_main_game()
	_mg.set("current_event", {})
	if _mg.has_method("_render_ap_actions"):
		_mg.call("_render_ap_actions")
	if _mg.has_method("_finish_typing"):
		_mg.call("_finish_typing")
	await _settle(0.55)
	await _save("trailer_02_goal_dashboard")
	await _dispose_main_game()

func _shot_trailer_timer_sequence() -> void:
	_prepare_main_game_state()
	GameState.turn = 4
	GameState.money = 500_000.0
	GameState.monthly_income = 0.0
	GameState.current_job = {}
	GameState.flags.erase("has_received_paycheck")
	GameState.flags.erase("is_employed")
	GameState.pending_story_queue = ["arc_temptation_01"]
	var packed := load("res://scenes/StoryMode.tscn") as PackedScene
	var story := packed.instantiate()
	get_tree().root.add_child.call_deferred(story)
	await get_tree().process_frame
	if story.has_method("_set_auto_mode"):
		story.call("_set_auto_mode", false, false)
	await _settle(0.2)
	for _step in range(80):
		if bool(story.get("_showing_choices")):
			break
		if bool(story.get("_typing")) and story.has_method("_complete_typing"):
			story.call("_complete_typing")
		elif story.has_method("_on_advance"):
			story.call("_on_advance")
		await _settle(0.025)
	if not bool(story.get("_showing_choices")):
		_fail("Trailer timer fixture could not reach the actual timed choices.")
		return
	# Let the real choice-entry tween finish before freezing the countdown frames.
	await _settle(0.4)
	for timer_case in [
		[12, "trailer_03_timer_12"],
		[7, "trailer_04_timer_07"],
		[3, "trailer_05_timer_03"],
	]:
		var seconds_left := int(timer_case[0])
		story.set("_choice_countdown_deadline_msec", Time.get_ticks_msec() + seconds_left * 1000)
		story.call("_tick_story_choice_countdown")
		await get_tree().process_frame
		var timer_label := story.get("_choice_countdown_label") as Label
		var expected := _tr("남은 시간  %d", "TIME LEFT  %d") % seconds_left
		if timer_label == null or timer_label.text != expected:
			_fail("Trailer timer expected '%s'." % expected)
			return
		await _save(str(timer_case[1]), 0.02)
	_remove_nodes_by_script("res://scenes/StoryMode.gd")
	GameState.pending_story_queue.clear()
	await _settle(0.2)

func _shot_trailer_extended_surfaces() -> void:
	_prepare_main_game_state()
	GameState.turn = 145
	GameState.age = 36
	GameState.year = 2029
	GameState.month = 1
	GameState.week_of_month = 1
	await _boot_main_game()
	var assets_before := float(GameState.get_total_asset_value()) - 420_000.0
	_mg.call(
		"_show_montage_card", 3, assets_before, GameState.health + 2,
		GameState.mental + 3, 2, 1, "cap", 3)
	await _settle(0.45)
	await _save("trailer_16_montage")
	await _dispose_main_game()

	_prepare_main_game_state()
	_seed_year_scene_history(true)
	await _boot_main_game()
	_seed_ending_state("stable_success")
	_mg.call("_show_ending", "stable_success")
	await _settle(0.8)
	if not await _focus_modal_qa_surface("time_ledger"):
		_fail("Trailer could not focus the time ledger.")
		return
	await _save("trailer_17_time_ledger")
	if not await _focus_modal_qa_surface("year_scene_recap"):
		_fail("Trailer could not focus the five-scene recap.")
		return
	await _save("trailer_18_ending_recap")
	await _dispose_main_game()

	_prepare_main_game_state()
	_seed_portfolio()
	GameState.money = 10_000_000.0
	await _boot_main_game()
	if not _mg.has_method("_open_investments"):
		_fail("Trailer investment surface is unavailable.")
		return
	_mg.call("_open_investments")
	await _settle(0.65)
	await _save("trailer_19_investment")
	_close_modal()
	await _settle(0.25)

	var racetrack = _mg.get("racetrack")
	if racetrack == null or not racetrack.has_method("open"):
		_fail("Trailer racetrack surface is unavailable.")
		return
	racetrack.call("open")
	racetrack.set("skip_countdown_for_smoke", true)
	racetrack.set("_bet_type", 1)
	racetrack.set("_picks", [0])
	racetrack.call("_render")
	racetrack.call("_place_bet", 10_000.0)
	await _settle(1.2)
	await _save("trailer_20_racetrack")
	racetrack.set("skip_countdown_for_smoke", false)
	racetrack.set("visible", false)
	if _mg.has_method("_exit_minigame_overlay"):
		_mg.call("_exit_minigame_overlay")
	await _settle(0.25)

	var blackjack = _mg.get("blackjack_table")
	if blackjack == null or not blackjack.has_method("open"):
		_fail("Trailer blackjack surface is unavailable.")
		return
	blackjack.call("open")
	blackjack.call("_set_stake_and_deal", 10_000)
	await _settle(0.8)
	await _save("trailer_21_blackjack")
	blackjack.set("visible", false)
	if _mg.has_method("_exit_minigame_overlay"):
		_mg.call("_exit_minigame_overlay")
	await _settle(0.25)

	var roulette = _mg.get("roulette_table")
	if roulette == null or not roulette.has_method("open"):
		_fail("Trailer roulette surface is unavailable.")
		return
	roulette.call("open")
	roulette.call("_select_bet_type", 1)
	roulette.call("_select_stake", 10_000)
	roulette.call("_do_bet")
	roulette.call("_do_spin")
	await _settle(1.55)
	await _save("trailer_22_roulette")
	roulette.set("visible", false)
	if _mg.has_method("_exit_minigame_overlay"):
		_mg.call("_exit_minigame_overlay")
	await _dispose_main_game()

func _assert_archive_surface(menu: Control, context: String) -> void:
	var overlay := menu.get("_archive_overlay") as Control
	if not is_instance_valid(overlay):
		_fail("%s overlay missing" % context)
		return
	if not overlay.find_children("*", "ScrollContainer", true, false).is_empty():
		_fail("%s contains a ScrollContainer" % context)
		return
	var viewport_rect := get_viewport().get_visible_rect()
	for node in overlay.find_children("*", "Button", true, false):
		var button := node as Button
		if not button.visible:
			continue
		var rect := button.get_global_rect()
		if rect.position.x < -1.0 or rect.position.y < -1.0 \
				or rect.end.x > viewport_rect.end.x + 1.0 or rect.end.y > viewport_rect.end.y + 1.0:
			_fail("%s button leaves viewport: %s %s" % [context, button.name, rect])
			return

func _assert_locked_hidden_names_absent(menu: Control) -> void:
	var overlay := menu.get("_archive_overlay") as Control
	var surface_text := _collect_control_text(overlay)
	for achievement_id in ["kept_evidence", "drawer_truth", "dawn_people"]:
		var info: Dictionary = DataRegistry.achievements_by_id.get(achievement_id, {})
		var locked_name := str(info.get("name", ""))
		if locked_name != "" and locked_name in surface_text:
			_fail("Locked hidden achievement name leaked: %s" % achievement_id)
			return

func _collect_control_text(node: Node) -> String:
	var result := ""
	if node is Label:
		result += (node as Label).text + "\n"
	elif node is Button:
		result += (node as Button).text + "\n"
	for child in node.get_children():
		result += _collect_control_text(child)
	return result

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
	await _shot_story_event("arc_intro_01_meal", prefix + "01a_first_interview_choices", lang, 0.45, true, true)
	await _shot_story_event("arc_intro_01_meal", prefix + "01b_first_interview_truth_result", lang, 0.45, true, true, 0)
	await _shot_story_event("arc_intro_02_dad_call", prefix + "02b_story_choices", lang, 0.45, true, true)
	await _shot_story_event("arc_intro_02_dad_call", prefix + "02c_story_result", lang, 0.45, true, true, 0)
	await _shot_story_event("arc_father_03_hospital", prefix + "02d_four_choice_dock", lang, 0.45, true, true)
	await _shot_story_event("arc_daeun_01_meet", prefix + "02d_demo_daeun_first_kindness", lang, 0.65, true)
	await _shot_story_event("arc_father_01_call", prefix + "02e_demo_father_first_call", lang, 0.65, true)
	await _shot_story_event("arc_jiyeon_01_crash", prefix + "02f_demo_jiyeon_crash", lang, 0.65, true)
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
	await _shot_story_event("arc_jiyeon_narrow_room_1", prefix + "13a0_romance_jiyeon_before_knock", lang, 0.45, true, false, -1, 0, true)
	await _shot_story_event("arc_jiyeon_narrow_room_1", prefix + "13a1_romance_jiyeon_narrow_door", lang, 0.45, true, false, -1, 2, true)
	await _shot_story_event("arc_jiyeon_narrow_room_2", prefix + "13b_romance_jiyeon_narrow_room", lang, 0.65, true)
	await _shot_story_event("arc_jiyeon_narrow_room_2", prefix + "13c_romance_jiyeon_narrow_choices", lang, 0.45, true, true)

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

func _shot_story_moral_surfaces(lang: String = "en", prefix: String = "story_moral_en_") -> void:
	_set_qa_language(lang)
	_prepare_main_game_state()
	await _shot_story_event("story_flashforward", prefix + "00_black_future", "", 1.0, true)
	for data in [
		[-80.0, "01_black"],
		[0.0, "02_gray"],
		[80.0, "03_white"],
	]:
		_prepare_main_game_state()
		GameState.moral_tint = float(data[0])
		await _shot_story_event("kx_heatwave", prefix + str(data[1]), "", 0.55, true)
	for data in [
		[-80.0, "black"],
		[0.0, "gray"],
		[80.0, "white"],
	]:
		_prepare_main_game_state()
		GameState.moral_tint = float(data[0])
		await _shot_story_event("arc_y2_worn_face", prefix + "04_perception_" + str(data[1]), "", 0.55, true)
		_prepare_main_game_state()
		GameState.moral_tint = float(data[0])
		await _shot_story_event("arc_y2_worn_face", prefix + "05_choices_" + str(data[1]), "", 0.45, true, true)
	for data in [
		[-80.0, "06_result_black", "money", "cast:sangchul"],
		[0.0, "07_result_gray", "money", "mental"],
		[80.0, "08_result_white", "cast:sangchul", "money"],
	]:
		_prepare_main_game_state()
		GameState.moral_tint = float(data[0])
		await _shot_story_event(
			"arc_sangchul_known_offer", prefix + str(data[1]), "", 0.45,
			true, true, 0, 0, false, 0, str(data[2]), str(data[3]))
	GameState.moral_tint = 0.0

func _assert_story_result_attention(story: Node, expected_first: String, expected_last: String) -> void:
	var card := story.find_child("StoryResultRecord", true, false)
	if card == null:
		_fail("Story result attention QA could not find StoryResultRecord.")
		return
	var grid := card.find_child("StoryResultGrid", true, false)
	if grid == null or grid.get_child_count() == 0:
		_fail("Story result attention QA could not find populated StoryResultGrid.")
		return
	var first_badge := grid.get_child(0) as Control
	var last_badge := grid.get_child(grid.get_child_count() - 1) as Control
	var actual_first := str(first_badge.get_meta("attention_key", ""))
	var actual_last := str(last_badge.get_meta("attention_key", ""))
	if actual_first != expected_first:
		_fail("Story result attention expected first '%s', got '%s'." % [expected_first, actual_first])
	if not expected_last.is_empty() and actual_last != expected_last:
		_fail("Story result attention expected last '%s', got '%s'." % [expected_last, actual_last])
	if GameState.moral_stage() != 0 and first_badge.modulate.a <= last_badge.modulate.a:
		_fail("Story result attention did not keep the first-noticed consequence visually dominant.")
	if GameState.moral_stage() < 0:
		_assert_story_result_counterweight_reserve(story)

func _assert_story_result_counterweight_reserve(story: Node) -> void:
	var dense_disp := {
		"money": 2_000_000,
		"monthly_income": 300_000,
		"investment_skill": 4,
		"work_performance": 5,
		"reputation": 3,
		"mental": -9,
	}
	var cast_items := [{"id": "father", "affinity": -6}]
	var black_items: Array = story._story_result_visible_items(
		story._story_result_ordered_items(dense_disp, cast_items, -2), -2, 4)
	var white_items: Array = story._story_result_visible_items(
		story._story_result_ordered_items(dense_disp, cast_items, 2), 2, 4)
	if not black_items.any(func(item): return str(item.get("attention_kind", "")) == "human"):
		_fail("Black result hierarchy erased every human consequence from a dense result.")
	if not white_items.any(func(item): return str(item.get("attention_kind", "")) == "economic"):
		_fail("White result hierarchy erased every economic consequence from a dense result.")

func _shot_moral_anchor_surfaces(lang: String = "en", prefix: String = "moral_anchors_en_") -> void:
	_set_qa_language(lang)
	var anchors := [
		["arc_sangchul_mirror", "01_sangchul_mirror", 0],
		["arc_why_gangnam_real", "02_why_gangnam", 1],
		["arc_father_passing", "03_father_passing", 0],
		["arc_final_countdown", "04_final_countdown", 0],
	]
	var moral_cases := [
		[-80.0, "black"],
		[0.0, "gray"],
		[80.0, "white"],
	]
	for anchor in anchors:
		var event_id := str(anchor[0])
		var label := str(anchor[1])
		var advance_paragraphs := int(anchor[2])
		for moral_case in moral_cases:
			var tint := float(moral_case[0])
			var band := str(moral_case[1])
			_prepare_main_game_state()
			_seed_moral_anchor_context(event_id)
			GameState.moral_tint = tint
			await _shot_story_event(
				event_id, prefix + label + "_" + band + "_prose", "", 0.55,
				true, false, -1, advance_paragraphs)
			_prepare_main_game_state()
			_seed_moral_anchor_context(event_id)
			GameState.moral_tint = tint
			await _shot_story_event(
				event_id, prefix + label + "_" + band + "_choices", "", 0.45,
				true, true)
	GameState.moral_tint = 0.0

func _seed_moral_anchor_context(event_id: String) -> void:
	match event_id:
		"arc_sangchul_mirror":
			GameState.turn = 60
			GameState.age = 34
			GameState.month = 4
			GameState.money = 85_000_000.0
		"arc_why_gangnam_real":
			GameState.turn = 120
			GameState.age = 35
			GameState.month = 7
			GameState.money = 320_000_000.0
		"arc_father_passing":
			GameState.turn = 150
			GameState.age = 36
			GameState.month = 2
			GameState.money = 800_000_000.0
		"arc_final_countdown":
			GameState.turn = 232
			GameState.age = 37
			GameState.month = 11
			GameState.money = 2_100_000_000.0

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

func _shot_namsan_surfaces(lang: String = "en", prefix: String = "namsan_en_") -> void:
	for route in [
		["daeun", "arc_date_namsan_daeun", "arc_date_namsan_lock_daeun"],
		["jiyeon", "arc_date_namsan_jiyeon", "arc_date_namsan_lock_jiyeon"],
	]:
		var label := str(route[0])
		var prelude_id := str(route[1])
		var lock_id := str(route[2])
		await _shot_story_event(prelude_id, prefix + label + "_00_cable_car", lang, 0.45, true)
		await _shot_story_event(prelude_id, prefix + label + "_01_tonkatsu", lang, 0.45, true, false, -1, 1)
		await _shot_story_event(prelude_id, prefix + label + "_02_observation_deck", lang, 0.45, true, false, -1, 2)
		await _shot_story_event(lock_id, prefix + label + "_03_lock_intro", lang, 0.55, true)
		await _shot_story_event(lock_id, prefix + label + "_04_lock_choices", lang, 0.55, true, true)

func _shot_amusement_surfaces(lang: String = "en", prefix: String = "amusement_en_") -> void:
	await _shot_story_event("arc_date_park_daeun", prefix + "daeun_00_parade", lang, 0.45, true)
	await _shot_story_event("arc_date_park_daeun", prefix + "daeun_01_helping_cg", lang, 0.45, true, false, -1, 1)
	await _shot_story_event("arc_date_park_daeun", prefix + "daeun_02_choices", lang, 0.45, true, true)
	await _shot_story_event("arc_date_park_daeun", prefix + "daeun_03_stay_result", lang, 0.45, true, true, 0)
	await _shot_story_event("arc_date_park_daeun", prefix + "daeun_04_rides_result", lang, 0.45, true, true, 1)
	await _shot_story_event("arc_date_park_jiyeon", prefix + "jiyeon_00_coaster", lang, 0.45, true)
	await _shot_story_event("arc_date_park_jiyeon", prefix + "jiyeon_01_booth", lang, 0.45, true, false, -1, 1)
	await _shot_story_event("arc_date_park_jiyeon", prefix + "jiyeon_02_choices", lang, 0.45, true, true)
	await _shot_story_event("arc_date_park_jiyeon", prefix + "jiyeon_03_photo_result", lang, 0.45, true, true, 0)
	await _shot_story_event("arc_date_park_jiyeon", prefix + "jiyeon_04_ride_result", lang, 0.45, true, true, 1)

func _shot_hometown_surfaces(lang: String = "en", prefix: String = "hometown_en_") -> void:
	await _shot_story_event("arc_daeun_hometown_1", prefix + "00_train_intro", lang, 0.45, true)
	await _shot_story_event("arc_daeun_hometown_1", prefix + "01_train_choices", lang, 0.45, true, true)
	await _shot_story_event("arc_daeun_hometown_1", prefix + "02_train_result", lang, 0.45, true, true, 0)
	await _shot_story_event("arc_daeun_hometown_2", prefix + "03_mother_table_intro", lang, 0.45, true)
	await _shot_story_event("arc_daeun_hometown_2", prefix + "04_mother_table_choices", lang, 0.45, true, true)
	await _shot_story_event("arc_daeun_hometown_2", prefix + "05_dinner_result", lang, 0.45, true, true, 0)
	await _shot_story_event("arc_daeun_hometown_2", prefix + "06_night_bus_result", lang, 0.45, true, true, 0, 0, false, 1)

func _shot_wedding_morning_surfaces(lang: String = "en", prefix: String = "wedding_morning_en_") -> void:
	_set_qa_language(lang)
	for route in [
		["daeun", "arc_daeun_wedding_night"],
		["jiyeon", "arc_jiyeon_wedding_night"],
	]:
		var label := str(route[0])
		var event_id := str(route[1])
		_prepare_wedding_morning_qa_state(label)
		await _shot_story_event(event_id, prefix + label + "_00_night_intro", "", 0.45, true)
		_prepare_wedding_morning_qa_state(label)
		await _shot_story_event(event_id, prefix + label + "_01_choices", "", 0.45, true, true)
		_prepare_wedding_morning_qa_state(label)
		await _shot_story_event(event_id, prefix + label + "_02_night_result", "", 0.45, true, true, 0)
		_prepare_wedding_morning_qa_state(label)
		await _shot_story_event(event_id, prefix + label + "_03_morning_result", "", 0.45, true, true, 0, 0, false, 1)
		_prepare_wedding_morning_qa_state(label)
		await _shot_story_event(event_id, prefix + label + "_04_morning_alt", "", 0.45, true, true, 1, 0, false, 1)

func _shot_first_snow_surfaces(lang: String = "en", prefix: String = "first_snow_en_") -> void:
	_set_qa_language(lang)
	for route in [
		["daeun", "arc_season_snow_daeun"],
		["jiyeon", "arc_season_snow_jiyeon"],
	]:
		var label := str(route[0])
		var event_id := str(route[1])
		_prepare_first_snow_qa_state(label)
		await _shot_story_event(event_id, prefix + label + "_00_winter_prelude", "", 0.45, true, false, -1, 0, true)
		_prepare_first_snow_qa_state(label)
		await _shot_story_event(event_id, prefix + label + "_01_cg_reveal", "", 0.45, true, false, -1, 1)
		_prepare_first_snow_qa_state(label)
		await _shot_story_event(event_id, prefix + label + "_02_choices", "", 0.45, true, true)
		_prepare_first_snow_qa_state(label)
		await _shot_story_event(event_id, prefix + label + "_03_result", "", 0.45, true, true, 0)

func _prepare_first_snow_qa_state(person_id: String) -> void:
	_prepare_main_game_state()
	GameState.age = 34
	GameState.turn = 95
	GameState.year = 2027
	GameState.month = 12
	GameState.week_of_month = 4
	if person_id == "daeun":
		GameState.flags["daeun_romance_started"] = true
	else:
		GameState.flags["jiyeon_romance_started"] = true

func _shot_climate_surfaces(lang: String = "en", prefix: String = "climate_en_") -> void:
	for data in [
		["kx_monsoon", "01_monsoon"],
		["kx_heatwave", "02_heatwave"],
		["kx_cold_snap", "03_cold_snap"],
	]:
		var event_id := str(data[0])
		var label := str(data[1])
		await _shot_story_event(event_id, prefix + label + "_intro", lang, 0.45, true)
		await _shot_story_event(event_id, prefix + label + "_choices", lang, 0.45, true, true)

func _shot_event_visual_surfaces(lang: String = "en", prefix: String = "event_visual_en_") -> void:
	_set_qa_language(lang)
	var cases := [
		["drama_summer_heat", "01_summer_heat"],
		["drama_winter_cold", "02_winter_cold"],
		["rainy_day_umbrella", "03_rain_umbrella"],
		["season_rainy_commute", "04_rain_commute"],
		["story_rainy_night", "05_rain_room"],
		["callback_gig_grinder_echo", "06_rain_delivery_memory"],
		["amb_wallet_00", "06a_bus_stop_wallet"],
		["kx_street_food", "07_winter_street_food"],
		["kx_seollal_sebae", "08_seollal_home"],
		["arc_year1_close", "09_year1_room"],
		["arc_year2_close", "10_year2_winter_street"],
		["arc_year3_close", "10a_year3_winter_hangang"],
		["arc_year4_close", "10b_year4_winter_rooftop"],
		["arc_father_medication", "11_father_medication_room"],
		["callback_called_about_medication_echo", "12_father_callback_room"],
		["arc_sangchul_03_network", "13_sangchul_restaurant"],
		["arc_daeun_the_test", "14_daeun_test_cafe"],
		["cafe_00", "14a_cafe_investor_intro"],
		["cafe_caught_honest", "14b_cafe_investor_card"],
		["cafe_bluff_caught", "14c_cafe_investor_bluff"],
		["cafe_cb_stole_call", "15_broker_call_room"],
		["cafe_cb_stole_verify", "16_broker_research_phone"],
		["cafe_cb_stole_smart", "17_broker_smart_cafe"],
		["cafe_cb_honest_00", "17a_investor_honest_call_room"],
		["cafe_cb_honest_in", "18_investor_honest_cafe"],
		["cafe_cb_humiliated_00", "18a_investor_humiliated_cafe"],
		["callback_cafe_jackpot_greed", "18b_broker_return_call"],
		["callback_cafe_honest_win_deeper", "18c_investor_network_call"],
		["arc_y2_hyunsu_night_bus", "19_hyunsu_phone_room"],
		["hyunsu_reunion_later", "20_hyunsu_accounting_reunion"],
		["hyunsu_year4_echo", "21_hyunsu_accounting_year4"],
		["hyunsu_year5_call", "22_hyunsu_accounting_year5"],
	]
	for data in cases:
		var event_id := str(data[0])
		_prepare_event_visual_qa_state(event_id)
		await _shot_story_event(event_id, prefix + str(data[1]), "", 0.45, true)
		if event_id == "arc_sangchul_03_network":
			_prepare_event_visual_qa_state(event_id)
			await _shot_story_event(event_id, prefix + str(data[1]) + "_choices", "", 0.45, true, true)
		if event_id in ["amb_wallet_00", "kx_street_food", "kx_seollal_sebae"]:
			_prepare_event_visual_qa_state(event_id)
			await _shot_story_event(event_id, prefix + str(data[1]) + "_choices", "", 0.45, true, true)
	_prepare_event_visual_qa_state("cafe_peek_01")
	await _shot_story_event("cafe_peek_01", prefix + "14d_cafe_folder_owner_hidden", "", 0.45, true)
	_prepare_event_visual_qa_state("cafe_peek_01")
	await _shot_story_event("cafe_peek_01", prefix + "14e_cafe_folder_owner_reveal", "", 0.45, true, false, -1, 1)
	_prepare_event_visual_qa_state("arc_y2_hyunsu_night_bus")
	await _shot_story_event("arc_y2_hyunsu_night_bus", prefix + "19a_hyunsu_terminal_result", "", 0.45, true, true, 0)
	_prepare_event_visual_qa_state("hyunsu_year4_echo")
	GameState.flags.erase("hyunsu_pivoted")
	GameState.flags["hyunsu_passed"] = true
	await _shot_story_event("hyunsu_year4_echo", prefix + "21a_hyunsu_civil_year4", "", 0.45, true)
	_prepare_event_visual_qa_state("hyunsu_year5_call")
	GameState.flags.erase("hyunsu_pivoted")
	GameState.flags["hyunsu_passed"] = true
	await _shot_story_event("hyunsu_year5_call", prefix + "22a_hyunsu_civil_year5", "", 0.45, true)

func _prepare_event_visual_qa_state(event_id: String) -> void:
	_prepare_main_game_state()
	GameState.turn = 72
	GameState.age = 34
	GameState.year = 2027
	GameState.month = 7
	GameState.week_of_month = 2
	match event_id:
		"drama_summer_heat":
			GameState.month = 8
		"drama_winter_cold", "kx_street_food":
			GameState.month = 12
			GameState.week_of_month = 4
		"kx_seollal_sebae":
			GameState.month = 2
			GameState.week_of_month = 1
		"arc_year1_close":
			GameState.turn = 48
			GameState.age = 33
			GameState.year = 2026
			GameState.month = 12
			GameState.week_of_month = 4
		"arc_year2_close":
			GameState.turn = 96
			GameState.age = 34
			GameState.year = 2027
			GameState.month = 12
			GameState.week_of_month = 4
		"arc_year3_close":
			GameState.turn = 144
			GameState.age = 35
			GameState.year = 2028
			GameState.month = 12
			GameState.week_of_month = 4
		"arc_year4_close":
			GameState.turn = 192
			GameState.age = 36
			GameState.year = 2029
			GameState.month = 12
			GameState.week_of_month = 4
		"arc_father_medication", "callback_called_about_medication_echo":
			GameState.month = 5
		"arc_sangchul_03_network":
			GameState.turn = 62
			GameState.month = 4
		"arc_daeun_the_test":
			GameState.turn = 142
			GameState.age = 35
			GameState.year = 2028
			GameState.month = 12
		"cafe_cb_stole_call", "cafe_cb_stole_verify", "cafe_cb_stole_smart", "cafe_cb_honest_in":
			GameState.month = 10
		"arc_y2_hyunsu_night_bus":
			GameState.turn = 82
			GameState.month = 9
			GameState.flags["arc_intro_hyunsu_seen"] = true
		"hyunsu_reunion_later":
			GameState.turn = 96
			GameState.month = 12
			GameState.flags["hyunsu_pivoted"] = true
		"hyunsu_year4_echo":
			GameState.turn = 160
			GameState.age = 36
			GameState.year = 2029
			GameState.month = 4
			GameState.flags["hyunsu_pivoted"] = true
		"hyunsu_year5_call":
			GameState.turn = 208
			GameState.age = 37
			GameState.year = 2030
			GameState.month = 4
			GameState.flags["hyunsu_pivoted"] = true

func _prepare_wedding_morning_qa_state(person_id: String) -> void:
	_prepare_main_game_state()
	GameState.age = 37
	GameState.year = 2030
	GameState.money = 350_000_000.0
	if person_id == "daeun":
		GameState.turn = 200
		GameState.month = 2
		GameState.week_of_month = 4
		GameState.flags["daeun_married"] = true
		GameState.flags["arc_daeun_wedding_day_seen"] = true
	else:
		GameState.turn = 205
		GameState.month = 4
		GameState.week_of_month = 1
		GameState.flags["jiyeon_romance_started"] = true
		GameState.flags["arc_jiyeon_wedding_gap_seen"] = true

func _prepare_commitment_qa_state(route: String = "daeun") -> void:
	_prepare_main_game_state()
	GameState.age = 37
	GameState.turn = 220
	GameState.year = 2030
	GameState.month = 7
	GameState.week_of_month = 1
	GameState.money = 380_000_000.0
	if route == "daeun":
		GameState.flags["daeun_romance_started"] = true
		GameState.flags["daeun_first_night"] = true
		_set_cast_relation_for_qa("daeun", 92)
	else:
		GameState.flags["jiyeon_romance_started"] = true
		GameState.flags["jiyeon_narrow_room"] = true
		_set_cast_relation_for_qa("jiyeon", 88)

func _prepare_breakup_qa_state(route: String) -> void:
	_prepare_main_game_state()
	GameState.age = 37
	GameState.turn = 238
	GameState.year = 2030
	GameState.month = 12
	GameState.week_of_month = 2
	GameState.money = 2_650_000_000.0 if route == "daeun" else 420_000_000.0
	if route == "daeun":
		GameState.moral_tint = -48.0
		GameState.flags["daeun_romance_started"] = true
		GameState.flags["daeun_married"] = true
		GameState.flags["namsan_lock_daeun"] = true
		_set_cast_relation_for_qa("daeun", 84)
	else:
		GameState.moral_tint = 18.0
		GameState.flags["jiyeon_romance_started"] = true
		GameState.flags["jiyeon_narrow_room"] = true
		GameState.flags["namsan_lock_jiyeon"] = true
		_set_cast_relation_for_qa("jiyeon", 82)

func _shot_commitment_surfaces(lang: String = "en", prefix: String = "commitment_en_") -> void:
	_set_qa_language(lang)

	_prepare_commitment_qa_state("daeun")
	await _shot_story_event("arc_daeun_proposal", prefix + "01_proposal_intro", "", 0.55, true)
	_prepare_commitment_qa_state("daeun")
	await _shot_story_event("arc_daeun_proposal", prefix + "02_proposal_choices", "", 0.45, true, true)
	_prepare_commitment_qa_state("daeun")
	await _shot_story_event("arc_daeun_proposal", prefix + "03_proposal_accept_reaction", "", 0.45, true, true, 0)
	_prepare_commitment_qa_state("daeun")
	await _shot_story_event("arc_daeun_proposal", prefix + "04_proposal_accept_cg", "", 0.45, true, true, 0, 0, false, 1)
	_prepare_commitment_qa_state("daeun")
	await _shot_story_event("arc_daeun_proposal", prefix + "05_proposal_delay_no_cg", "", 0.45, true, true, 1, 0, false, 1)

	_prepare_commitment_qa_state("daeun")
	await _shot_story_event("arc_daeun_wedding_prep", prefix + "06_wedding_small_choice", "", 0.45, true, true, 0)
	if not GameState.flags.get("daeun_wedding_small", false) or GameState.flags.get("daeun_wedding_full", false):
		_fail("Daeun small-wedding choice did not preserve an exclusive small route flag.")
		return
	await _shot_story_event("arc_daeun_wedding_day", prefix + "07_wedding_small_cg", "", 0.45, true)

	_prepare_commitment_qa_state("daeun")
	await _shot_story_event("arc_daeun_wedding_prep", prefix + "08_wedding_full_choice", "", 0.45, true, true, 1)
	if not GameState.flags.get("daeun_wedding_full", false) or GameState.flags.get("daeun_wedding_small", false):
		_fail("Daeun full-package choice did not preserve an exclusive full route flag.")
		return
	await _shot_story_event("arc_daeun_wedding_day", prefix + "09_wedding_full_cg", "", 0.45, true)

	_prepare_commitment_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_wedding_gap", prefix + "10_jiyeon_gap_intro", "", 0.55, true)
	_prepare_commitment_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_wedding_gap", prefix + "11_jiyeon_gap_choices", "", 0.45, true, true)

func _shot_breakup_surfaces(lang: String = "en", prefix: String = "breakup_en_") -> void:
	_set_qa_language(lang)

	_prepare_breakup_qa_state("daeun")
	await _shot_story_event("arc_daeun_final_choice", prefix + "01_daeun_intro", "", 0.55, true)
	_prepare_breakup_qa_state("daeun")
	await _shot_story_event("arc_daeun_final_choice", prefix + "02_daeun_choices", "", 0.45, true, true)
	_prepare_breakup_qa_state("daeun")
	await _shot_story_event("arc_daeun_final_choice", prefix + "03_daeun_stays_no_cg", "", 0.45, true, true, 0, 0, false, 1)
	_prepare_breakup_qa_state("daeun")
	await _shot_story_event("arc_daeun_final_choice", prefix + "04_daeun_betrayal_before_cg", "", 0.45, true, true, 1, 0, false, 2)
	_prepare_breakup_qa_state("daeun")
	await _shot_story_event("arc_daeun_final_choice", prefix + "05_daeun_seal_cg", "", 0.45, true, true, 1, 0, false, 3)

	_prepare_breakup_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_verdict", prefix + "06_jiyeon_intro", "", 0.55, true)
	_prepare_breakup_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_verdict", prefix + "07_jiyeon_choices", "", 0.45, true, true)
	_prepare_breakup_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_verdict", prefix + "08_jiyeon_stays_no_cg", "", 0.45, true, true, 0, 0, false, 2)
	_prepare_breakup_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_verdict", prefix + "09_jiyeon_farewell_before_cg", "", 0.45, true, true, 1, 0, false, 1)
	_prepare_breakup_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_verdict", prefix + "10_jiyeon_departure_cg", "", 0.45, true, true, 1, 0, false, 2)

func _shot_transport_surfaces(lang: String = "en", prefix: String = "transport_en_") -> void:
	_set_qa_language(lang)
	_prepare_main_game_state()
	GameState.month = 7
	await _shot_story_event("arc_season_sea_daeun", prefix + "01_summer_ktx_interior", "", 0.55, true)
	_prepare_main_game_state()
	GameState.month = 10
	await _shot_story_event("arc_father_call_on_ktx", prefix + "02_father_ktx_interior", "", 0.55, true)
	_prepare_main_game_state()
	GameState.month = 1
	await _shot_story_event("amb_holiday_00", prefix + "03_holiday_station_choices", "", 0.45, true, true)

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
	_assert_core_action_illustrations()
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
	var qa_job: Dictionary = GameState.current_job.duplicate(true)
	var qa_income: float = GameState.monthly_income
	GameState.current_job = {}
	GameState.monthly_income = 0.0
	await _shot_action_category_modal("_open_cat_work", prefix + "04g_work_modal")
	GameState.current_job = qa_job
	GameState.monthly_income = qa_income
	GameState.investment_skill = 55
	await _shot_action_category_modal("_open_cat_money", prefix + "04_money_modal")
	GameState.action_points = GameState.max_action_points
	await _shot_action_category_modal("_ap_study", prefix + "04h_study_modal")
	if _mg.has_method("_open_investments"):
		_mg.call("_open_investments")
		await _settle(0.7)
		await _save(prefix + "04a_investment_modal")
		_close_modal()
		await _settle(0.3)
	await _shot_action_category_modal("_open_cat_people", prefix + "05_people_modal")
	GameState.flags["racetrack_guide_met"] = true
	GameState.flags["entered_network"] = true
	GameState.flags["scalping_introduced"] = true
	GameState.flags["casino_club_introduced"] = true
	GameState.investment_skill = maxi(GameState.investment_skill, 50)
	GameState.money = maxf(GameState.money, 5_000_000.0)
	await _shot_action_category_modal("_open_cat_gambling", prefix + "05a_gambling_modal")
	var qa_money: float = GameState.money
	GameState.money = 100_000_000.0
	await _shot_action_category_modal("_open_cat_life", prefix + "06_life_modal")
	GameState.money = qa_money
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
		if act == 1 and _mg.find_child("FirstMonthHorizon", true, false) == null:
			_fail("Act 1 AP surface is missing the first-month horizon.")
			return
		if act == 2 and _mg.find_child("SeoulMapStrip", true, false) == null:
			_fail("Post-onboarding AP surface did not restore Seoul Trace.")
			return
		await _save("%s%02d_act%d" % [prefix, act, act])
		if act == 1:
			GameState.flags["arc_intro_meal_seen"] = true
			if _mg.has_method("_render_ap_actions"):
				_mg.call("_render_ap_actions")
			if _mg.has_method("_finish_typing"):
				_mg.call("_finish_typing")
			await _settle(0.35)
			await _save("%s01b_after_first_interview" % prefix)
			if _mg.has_method("_show_ap_action_commit"):
				_mg.call("_show_ap_action_commit", _tr("지원 계속", "Keep Applying"), "job", "#dc6a2a", false, null)
				await _settle(0.14)
				await _save("%s01c_action_commit" % prefix)
				if _mg.has_method("_hide_ap_action_commit"):
					_mg.call("_hide_ap_action_commit")
			GameState.flags.erase("arc_intro_meal_seen")
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
			GameState.turn = 1
			GameState.current_job = {}
			GameState.monthly_income = 0.0
			GameState.money = 500_000.0
			GameState.health = 60
			GameState.mental = 54
			GameState.flags["has_received_paycheck"] = false
			GameState.flags["arc_invest_guidance_seen"] = false
			GameState.action_axis_this_week = {"money": 0, "human": 0}
			GameState.portfolio = {}
			GameState.loans = {"bank": 0.0, "second": 0.0}
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

func _assert_core_action_illustrations() -> void:
	_assert_action_scene_paths([
		"res://assets/backgrounds/office_interview_day.png",
		"res://assets/backgrounds/investment_phone.png",
		"res://assets/backgrounds/library.png",
		"res://assets/backgrounds/goshiwon_room.png",
	], "AP shell")

func _assert_action_scene_paths(expected_paths: Array[String], context: String) -> void:
	if _mg == null:
		_fail("MainGame instance is unavailable for %s action-art regression." % context)
		return
	var loaded_paths := {}
	for node in _mg.find_children("*", "TextureRect", true, false):
		var texture_rect := node as TextureRect
		if texture_rect == null or not (texture_rect.texture is AtlasTexture):
			continue
		var atlas_texture := texture_rect.texture as AtlasTexture
		if atlas_texture.atlas != null:
			loaded_paths[atlas_texture.atlas.resource_path] = true
	var missing: Array[String] = []
	for path in expected_paths:
		if not loaded_paths.has(path):
			missing.append(path)
	if not missing.is_empty():
		_fail("%s is missing action scene stills: %s" % [context, ", ".join(missing)])

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

func _shot_ending_p0_surfaces(lang: String, prefix: String) -> void:
	_set_qa_language(lang)
	_prepare_main_game_state()
	_seed_portfolio()
	await _boot_main_game()
	var targets := [
		["full_circle", "cg_ending_full_circle", "01_full_circle"],
		["gangnam_dream_white", "cg_ending_gangnam_dream_white", "02_gangnam_white"],
		["with_daeun", "cg_ending_with_daeun", "03_with_daeun"],
		["second_love", "cg_ending_second_love", "04_second_love"],
		["jiyeon_man", "cg_ending_jiyeon_man", "05_jiyeon_man"],
		["guardian", "cg_ending_guardian", "06_guardian"],
		["jaehyuk_way", "cg_ending_jaehyuk_way", "07_jaehyuk_way"],
		["sangchul_reckoning", "cg_ending_sangchul_reckoning", "08_sangchul_reckoning"],
	]
	for target in targets:
		await _shot_exact_ending_cg(str(target[0]), str(target[1]), prefix + str(target[2]))

func _shot_ending_p1_surfaces(lang: String, prefix: String) -> void:
	_set_qa_language(lang)
	_prepare_main_game_state()
	_seed_portfolio()
	await _boot_main_game()
	await _shot_exact_ending_cg("late_call", "cg_ending_late_call", prefix + "01_late_call")
	await _shot_exact_ending_cg(
			"late_call", "cg_ending_late_call", prefix + "02_late_call_jaehyuk_memory",
			["jaehyuk_trusted_fully"])
	await _shot_exact_ending_cg("lonely_rich", "cg_ending_lonely_rich", prefix + "03_lonely_rich")
	await _shot_exact_ending_cg(
			"lonely_rich", "cg_ending_lonely_rich", prefix + "04_lonely_rich_divorce",
			["daeun_divorced"])
	await _shot_ending_without_cg(
			"ordinary_life", "cg_ending_lonely_rich", prefix + "05_divorce_shortfall",
			["daeun_divorced"])
	await _shot_exact_ending_cg(
			"gambling_recovery", "cg_ending_gambling_recovery", prefix + "06_gambling_recovery")
	await _shot_exact_ending_cg(
			"gambling_recovery", "cg_ending_gambling_recovery", prefix + "07_gambling_recovery_father",
			["father_reconciled"])
	await _shot_exact_ending_cg(
			"bankruptcy", "cg_ending_bankruptcy", prefix + "08_bankruptcy")
	await _shot_exact_ending_cg(
			"bankruptcy", "cg_ending_bankruptcy", prefix + "09_bankruptcy_cafe_memory",
			["cafe_greed_burned"])
	await _shot_exact_ending_cg(
			"debt_spiral", "cg_ending_debt_spiral", prefix + "10_debt_spiral")
	await _shot_exact_ending_cg(
			"debt_spiral", "cg_ending_debt_spiral", prefix + "11_debt_spiral_margin_memory",
			["accepted_margin_call"])
	await _shot_exact_ending_cg(
			"debt_spiral", "cg_ending_debt_spiral", prefix + "12_debt_spiral_lender_memory",
			["credit_second_tier_loan"])
	await _shot_exact_ending_cg(
			"startup_exit", "cg_ending_startup_exit", prefix + "13_startup_exit")
	await _shot_exact_ending_cg(
			"startup_exit", "cg_ending_startup_exit", prefix + "14_startup_exit_first_user",
			["first_user_connected"])
	await _shot_exact_ending_cg(
			"instant_legend", "cg_ending_instant_legend", prefix + "15_instant_legend")

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
	_assert_ap_cards_inside_viewport()
	await _save(prefix + "02_ap_loop")
	GameState.action_points = GameState.max_action_points + 1
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	await _settle(0.35)
	_assert_ap_cards_inside_viewport()
	await _save(prefix + "02b_ap_bonus")
	GameState.action_points = GameState.max_action_points

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
	_assert_modal_no_vertical_overflow("demo ending")
	_assert_demo_ending_boundary_copy()
	await _save(prefix + "04_demo_ending_cta")

func _assert_demo_ending_boundary_copy() -> void:
	var modal := _mg.get("modal_body") as Control
	if not is_instance_valid(modal):
		_fail("Demo ending boundary assertion has no modal body.")
		return
	var surface_text := _collect_control_text(modal)
	var expected := _tr("24주차", "WEEK 24")
	var forbidden := _tr("25주차", "WEEK 25")
	if expected not in surface_text:
		_fail("Demo ending does not identify the final playable week: %s." % expected)
		return
	if forbidden in surface_text:
		_fail("Demo ending leaks blocked week 25 copy: %s." % forbidden)

func _assert_ap_cards_inside_viewport() -> void:
	if not is_instance_valid(_mg):
		_fail("AP viewport assertion has no MainGame instance.")
		return
	var viewport_size := get_viewport().get_visible_rect().size
	for card_variant in _mg.get("_ap_grid_cards"):
		var card := card_variant as Control
		if not is_instance_valid(card) or not card.visible:
			continue
		var rect := card.get_global_rect()
		if rect.position.x < -0.5 or rect.end.x > viewport_size.x + 0.5:
			_fail("AP card exceeds viewport at %.1f..%.1f of %.1f px." % [
				rect.position.x, rect.end.x, viewport_size.x])
			return

func _assert_modal_no_vertical_overflow(context: String) -> void:
	var scroll := _mg.get("modal_scroll") as ScrollContainer
	if not is_instance_valid(scroll):
		push_error("SCREENSHOT_QA_ASSERT: %s modal scroll missing" % context)
		get_tree().quit(1)
		return
	var bar := scroll.get_v_scroll_bar()
	if bar.max_value > bar.page + 2.0:
		push_error("SCREENSHOT_QA_ASSERT: %s requires vertical scrolling (%.1f > %.1f)" % [context, bar.max_value, bar.page])
		get_tree().quit(1)

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
		if _mg.has_method("_refresh_all"):
			_mg._refresh_all()
		if _mg.has_method("_render_ap_actions"):
			_mg._render_ap_actions()
		await _settle(0.7)
		await _save(str(data[1]))
	await _shot_moral_attention_lines()
	GameState.moral_tint = 0.0
	if _mg.has_method("_apply_moral_visuals"):
		_mg._apply_moral_visuals(GameState.moral_tint_norm(), GameState.moral_stage(), true)
	await _shot_moral_choice_echo(-25.0, "03e_moral_black_choice_echo")
	await _shot_moral_choice_echo(25.0, "03f_moral_white_choice_echo")
	await _shot_moral_beat_surfaces()
	GameState.pending_tint_vignette = {}
	GameState.moral_tint = 0.0
	if _mg.has_method("_apply_moral_visuals"):
		_mg._apply_moral_visuals(GameState.moral_tint_norm(), GameState.moral_stage(), true)

func _shot_moral_attention_lines() -> void:
	var original_turn: int = int(GameState.turn)
	var original_month: int = int(GameState.month)
	var original_week: int = int(GameState.week_of_month)
	GameState.turn = 32
	GameState.month = 8
	GameState.week_of_month = 4
	var cases := [
		[-80.0, "03d1_moral_attention_black", _tr("잔액은 두 번 확인했다", "balance was checked twice")],
		[80.0, "03d2_moral_attention_white", _tr("계좌를 열기 전에", "Before opening the account")],
	]
	for data in cases:
		GameState.moral_tint = float(data[0])
		if _mg.has_method("_apply_moral_visuals"):
			_mg._apply_moral_visuals(GameState.moral_tint_norm(), GameState.moral_stage(), true)
		_mg.current_event = {}
		if _mg.has_method("_refresh_all"):
			_mg._refresh_all()
		if _mg.has_method("_render_ap_actions"):
			_mg._render_ap_actions()
		if _mg.has_method("_finish_typing"):
			_mg._finish_typing()
		await _settle(0.6)
		var body := _mg.get("event_body") as RichTextLabel
		var expected := str(data[2])
		if not is_instance_valid(body) or not body.text.contains(expected):
			_fail("Moral attention line missing expected fragment: %s" % expected)
		await _save(str(data[1]))
	GameState.turn = original_turn
	GameState.month = original_month
	GameState.week_of_month = original_week

func _shot_moral_beat_surfaces() -> void:
	var cases := [
		[-80.0, -1, -2, "03g_moral_beat_deep_black"],
		[-35.0, 0, -1, "03h_moral_beat_light_black"],
		[0.0, -1, 0, "03i_moral_beat_gray"],
		[35.0, 0, 1, "03j_moral_beat_light_white"],
		[80.0, 1, 2, "03k_moral_beat_deep_white"],
	]
	for data in cases:
		GameState.moral_tint = float(data[0])
		if _mg.has_method("_apply_moral_visuals"):
			_mg._apply_moral_visuals(GameState.moral_tint_norm(), GameState.moral_stage(), true)
		_mg.current_event = {}
		if _mg.has_method("_show_moral_beat"):
			_mg._show_moral_beat(int(data[1]), int(data[2]))
		if _mg.has_method("_finish_typing"):
			_mg._finish_typing()
		await _settle(1.35)
		await _save(str(data[3]))

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
	GameState.flags["racetrack_guide_met"] = true
	GameState.flags["entered_network"] = true
	GameState.flags["scalping_introduced"] = true
	GameState.flags["casino_club_introduced"] = true
	GameState.investment_skill = maxi(GameState.investment_skill, 50)
	GameState.money = maxf(GameState.money, 5_000_000.0)
	await _shot_action_category_modal("_open_cat_gambling", "04j_action_gambling_modal")
	await _shot_action_category_modal("_open_cat_life", "04i_action_life_modal")

func _shot_action_category_modal(method_name: String, shot_name: String) -> void:
	if not is_instance_valid(_mg) or not _mg.has_method(method_name):
		print("SKIP %s (no %s)" % [shot_name, method_name])
		return
	_mg.call(method_name)
	await _settle(0.7)
	match method_name:
		"_open_cat_work":
			_assert_action_scene_paths([
				"res://assets/backgrounds/office_interview_day.png",
				"res://assets/backgrounds/office_desk.png",
			], "Work modal")
		"_open_cat_money":
			_assert_action_scene_paths([
				"res://assets/backgrounds/investment_phone.png",
				"res://assets/backgrounds/trading_screen_night.png",
				"res://assets/backgrounds/aruba_delivery_street.png",
				"res://assets/backgrounds/convenience_store_night_v2.png",
			], "Money modal")
		"_ap_study":
			_assert_action_scene_paths([
				"res://assets/backgrounds/library.png",
				"res://assets/backgrounds/gym_interior.png",
				"res://assets/backgrounds/hangang_riverside_walk.png",
				"res://assets/backgrounds/investment_phone.png",
			], "Self-Dev modal")
		"_open_cat_life":
			_assert_action_scene_paths([
				"res://assets/backgrounds/oneroom_apartment.png",
			], "Life modal")
		"_open_cat_gambling":
			_assert_action_scene_paths([
				"res://assets/backgrounds/racetrack_track_view.png",
				"res://assets/backgrounds/holdem_club_interior.png",
				"res://assets/backgrounds/scalping_trading_room.png",
				"res://assets/backgrounds/jeongseon_casino_entrance.png",
			], "Gambling modal")
	await _save(shot_name)
	if method_name == "_open_cat_people" and _mg.has_method("_set_people_page"):
		_mg.call("_set_people_page", 1)
		await _settle(0.35)
		_assert_action_scene_paths([
			"res://assets/backgrounds/cafe_seoul.png",
		], "People network page")
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

func _shot_exact_ending_cg(
		ending_id: String, cg_id: String, shot_name: String, extra_flags: Array = []) -> void:
	if not _mg.has_method("_show_ending"):
		_fail("MainGame cannot show ending CG %s" % ending_id)
		return
	_seed_ending_state(ending_id)
	for flag in extra_flags:
		GameState.flags[str(flag)] = true
	_mg._show_ending(ending_id)
	await _settle(1.0)
	var expected_path := ImageRegistry.get_cg(cg_id)
	var preview := _find_ending_art_preview(_mg)
	if expected_path.is_empty():
		_fail("Ending %s references missing CG id %s" % [ending_id, cg_id])
		return
	if preview == null or preview.texture == null:
		_fail("Ending %s has no ending_art_preview texture" % ending_id)
		return
	if preview.texture.resource_path != expected_path:
		_fail("Ending %s preview mismatch: expected %s, got %s" % [
			ending_id, expected_path, preview.texture.resource_path])
		return
	if preview.custom_minimum_size.y < 430.0:
		_fail("Ending %s preview crop contract fell below 430px" % ending_id)
		return
	var ending: Dictionary = EndingSystem.get_ending(ending_id)
	var expected_focus := float(ending.get("cg_preview_focus_y", 0.5))
	var actual_focus := float(preview.get_meta("ending_preview_focus_y", 0.5))
	if not is_equal_approx(actual_focus, expected_focus):
		_fail("Ending %s preview focus expected %.2f, got %.2f" % [
				ending_id, expected_focus, actual_focus])
		return
	await _save(shot_name)
	await _settle(0.3)

func _shot_ending_without_cg(
		ending_id: String, forbidden_cg_id: String, shot_name: String, extra_flags: Array = []) -> void:
	if not _mg.has_method("_show_ending"):
		_fail("MainGame cannot show ending %s" % ending_id)
		return
	_seed_ending_state(ending_id)
	for flag in extra_flags:
		GameState.flags[str(flag)] = true
	_mg._show_ending(ending_id)
	await _settle(1.0)
	var preview := _find_ending_art_preview(_mg)
	var forbidden_path := ImageRegistry.get_cg(forbidden_cg_id)
	if preview != null and preview.texture != null and preview.texture.resource_path == forbidden_path:
		_fail("Ending %s leaked forbidden CG %s" % [ending_id, forbidden_cg_id])
		return
	await _save(shot_name)
	await _settle(0.3)

func _find_ending_art_preview(node: Node) -> TextureRect:
	if node is TextureRect and node.has_meta("ending_art_preview"):
		return node as TextureRect
	for child in node.get_children():
		var found := _find_ending_art_preview(child)
		if found != null:
			return found
	return null

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
	GameState.money = 74_000_000.0
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
	for flag in ["daeun_romance_started", "daeun_married", "daeun_final_together",
			"daeun_divorced", "felt_1b_loneliness", "calculated_bihon",
			"beat_addiction",
			"jiyeon_romance_started", "jiyeon_kept_by_diminishing", "crossed_line",
			"sangchul_used_fully", "sangchul_reported", "cleared_father_debt_from_sangchul",
			"sangchul_network_finally_cut", "sangchul_truth_known", "jaehyuk_trusted_fully",
			"made_time_for_father", "delayed_father_visit", "brief_father_meeting",
			"promise_changed", "sent_parents_money", "parent_debt_acknowledged",
			"father_reconciled", "father_passed"]:
		GameState.flags.erase(flag)
	match ending_id:
		"gangnam_dream", "gangnam_dream_white", "full_circle":
			GameState.money = 3_180_000_000.0
			GameState.housing = "gangnam"
			GameState.health = 76
			GameState.mental = 74
			GameState.reputation = 88
			GameState.route_orthodox = 18
			GameState.route_unorthodox = 9
			GameState.moral_tint = 72.0 if ending_id == "gangnam_dream_white" else (48.0 if ending_id == "full_circle" else 24.0)
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
		"with_daeun":
			GameState.money = 180_000_000.0
			GameState.housing = "villa"
			GameState.health = 68
			GameState.mental = 76
			GameState.reputation = 46
			GameState.moral_tint = 34.0
			GameState.money_weeks_total = 123
			GameState.human_weeks_total = 105
			GameState.contact_counts = {"daeun": 28}
			GameState.last_contact_turn = {"daeun": 240}
		"second_love":
			GameState.money = 1_350_000_000.0
			GameState.housing = "gangnam"
			GameState.health = 73
			GameState.mental = 79
			GameState.reputation = 70
			GameState.moral_tint = 46.0
			GameState.money_weeks_total = 139
			GameState.human_weeks_total = 101
			GameState.contact_counts = {"daeun": 31}
			GameState.last_contact_turn = {"daeun": 240}
		"jiyeon_man":
			GameState.money = 3_050_000_000.0
			GameState.housing = "gangnam"
			GameState.health = 58
			GameState.mental = 43
			GameState.reputation = 82
			GameState.moral_tint = -42.0
			GameState.money_weeks_total = 181
			GameState.human_weeks_total = 45
			GameState.contact_counts = {"jiyeon": 30}
			GameState.last_contact_turn = {"jiyeon": 240}
		"guardian":
			GameState.money = 240_000_000.0
			GameState.health = 78
			GameState.mental = 82
			GameState.reputation = 57
			GameState.moral_tint = 52.0
			GameState.money_weeks_total = 112
			GameState.human_weeks_total = 118
			GameState.contact_counts = {"father": 26}
			GameState.last_contact_turn = {"father": 240}
		"sangchul_reckoning":
			GameState.money = 180_000_000.0
			GameState.health = 64
			GameState.mental = 71
			GameState.reputation = 60
			GameState.moral_tint = 38.0
			GameState.money_weeks_total = 132
			GameState.human_weeks_total = 92
			GameState.contact_counts = {"father": 18}
			GameState.last_contact_turn = {"father": 239}
		"late_call":
			GameState.money = 74_000_000.0
			GameState.housing = "oneroom"
			GameState.health = 66
			GameState.mental = 72
			GameState.reputation = 44
			GameState.moral_tint = 32.0
			GameState.money_weeks_total = 136
			GameState.human_weeks_total = 94
			GameState.contact_counts = {"father": 19}
			GameState.last_contact_turn = {"father": 240}
			GameState.flags["father_reconciled"] = true
		"gambling_recovery":
			GameState.money = 18_000_000.0
			GameState.housing = "gosiwon"
			GameState.health = 69
			GameState.mental = 78
			GameState.reputation = 39
			GameState.moral_tint = 46.0
			GameState.money_weeks_total = 102
			GameState.human_weeks_total = 116
			GameState.grind_streak_weeks = 0
			GameState.contact_counts = {"father": 12}
			GameState.last_contact_turn = {"father": 235}
		"bankruptcy":
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
		"debt_spiral":
			GameState.money = -218_000_000.0
			GameState.housing = "gosiwon"
			GameState.health = 24
			GameState.mental = 14
			GameState.reputation = 2
			GameState.route_orthodox = 2
			GameState.route_unorthodox = 24
			GameState.moral_tint = -58.0
			GameState.money_weeks_total = 218
			GameState.human_weeks_total = 12
			GameState.grind_streak_weeks = 11
			GameState.contact_counts = {"daeun": 0}
			GameState.last_contact_turn = {"daeun": 57}
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
	match ending_id:
		"full_circle":
			GameState.flags["cleared_father_debt_from_sangchul"] = true
			GameState.flags["father_reconciled"] = true
		"with_daeun":
			GameState.flags["daeun_romance_started"] = true
			GameState.flags["daeun_married"] = true
		"second_love":
			GameState.flags["daeun_romance_started"] = true
			GameState.flags["daeun_final_together"] = true
		"jiyeon_man":
			GameState.flags["jiyeon_romance_started"] = true
			GameState.flags["jiyeon_kept_by_diminishing"] = true
		"guardian":
			GameState.flags["father_reconciled"] = true
		"jaehyuk_way":
			GameState.flags["crossed_line"] = true
			GameState.flags["sangchul_used_fully"] = true
		"sangchul_reckoning":
			GameState.flags["sangchul_reported"] = true
			GameState.flags["father_reconciled"] = true
		"gambling_recovery":
			GameState.flags["beat_addiction"] = true
	if is_instance_valid(_mg) and _mg.has_method("_apply_moral_visuals"):
		_mg._apply_moral_visuals(GameState.moral_tint_norm(), GameState.moral_stage(), true)
	if is_instance_valid(_mg) and _mg.has_method("_render_sidebars"):
		_mg._render_sidebars()
