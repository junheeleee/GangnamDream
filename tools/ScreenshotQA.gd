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
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=first-30 --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=first-30 --lang=ko --pad=playstation --reduce-motion
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=gallery --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=year-identity --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=store --lang=en
##       godot --rendering-driver opengl3 --resolution 1920x1080 res://tools/ScreenshotQA.tscn -- --qa=trailer --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=locale-gate
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=i18n-layout --lang=zh-CN
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=story-en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=story-presence --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=story-audio --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=story-moral --lang=en
##       godot --rendering-driver opengl3 --resolution 1920x1080 res://tools/ScreenshotQA.tscn -- --qa=living-scene --lang=en
##       godot --rendering-driver opengl3 --resolution 1920x1080 res://tools/ScreenshotQA.tscn -- --qa=display-matrix --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=text-material --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=romance-cg
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=romance-portraits
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=namsan --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=amusement --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=hometown --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=home-peaks --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=wedding-morning --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=commitment --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=breakup --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=sangchul-first-meet --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=sangchul-deduction --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=sangchul-casino --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=sangchul-confrontation --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=father-ktx --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=season-peaks --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=ending-p1 --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=transport --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=first-snow --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=climate --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=event-visuals --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=ap-en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=ap-act-en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=immersion-loop --lang=en
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=motivation-imprint --lang=en
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
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=demo-gamepad --lang=en --pad=xbox --demo-build
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=demo-keyboard --lang=en --demo-build
##       godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=demo-mouse --lang=en --demo-build
## 헤드리스 더미 렌더러는 빈 텍스처를 주므로 x11+opengl3(xvfb) 필요.
## .tscn 으로 부팅해야 autoload(GameState 등)가 로드된다.

const StoryModeScript = preload("res://scenes/StoryMode.gd")

# Parallel matrix jobs must not erase one another's screenshots. Set
# GANGNAM_QA_OUT per process when durable, isolated evidence is required.
var OUT_DIR := OS.get_environment("GANGNAM_QA_OUT") \
		if not OS.get_environment("GANGNAM_QA_OUT").strip_edges().is_empty() \
		else "/tmp/gangnamdream_qa"
const QA_SCOPE_CASINO := "casino"
const QA_SCOPE_CASINO_EN := "casino_en"
const QA_SCOPE_MORAL := "moral"
const QA_SCOPE_DEMO_FLOW := "demo_flow"
const QA_SCOPE_DEMO_BLACKBOX := "demo_blackbox"
const QA_SCOPE_DEMO_INPUT := "demo_input"
const QA_SCOPE_DEMO_GAMEPAD := "demo_gamepad"
const QA_SCOPE_DEMO_KEYBOARD := "demo_keyboard"
const QA_SCOPE_DEMO_MOUSE := "demo_mouse"
const QA_SCOPE_START_EN := "start_en"
const QA_SCOPE_FIRST_30 := "first_30"
const QA_SCOPE_GALLERY := "gallery"
const QA_SCOPE_YEAR_IDENTITY := "year_identity"
const QA_SCOPE_STORE := "store"
const QA_SCOPE_TRAILER := "trailer"
const QA_SCOPE_LOCALE_GATE := "locale_gate"
const QA_SCOPE_I18N_LAYOUT := "i18n_layout"
const QA_SCOPE_STORY_EN := "story_en"
const QA_SCOPE_STORY_PRESENCE := "story_presence"
const QA_SCOPE_STORY_AUDIO := "story_audio"
const QA_SCOPE_STORY_MORAL := "story_moral"
const QA_SCOPE_LIVING_SCENE := "living_scene"
const QA_SCOPE_DISPLAY_MATRIX := "display_matrix"
const QA_SCOPE_TEXT_MATERIAL := "text_material"
const QA_SCOPE_MORAL_ANCHORS := "moral_anchors"
const QA_SCOPE_ROMANCE_CG := "romance_cg"
const QA_SCOPE_ROMANCE_PORTRAITS := "romance_portraits"
const QA_SCOPE_NAMSAN := "namsan"
const QA_SCOPE_AMUSEMENT := "amusement"
const QA_SCOPE_HOMETOWN := "hometown"
const QA_SCOPE_HOME_PEAKS := "home_peaks"
const QA_SCOPE_WEDDING_MORNING := "wedding_morning"
const QA_SCOPE_COMMITMENT := "commitment"
const QA_SCOPE_BREAKUP := "breakup"
const QA_SCOPE_SANGCHUL_FIRST_MEET := "sangchul_first_meet"
const QA_SCOPE_SANGCHUL_DEDUCTION := "sangchul_deduction"
const QA_SCOPE_SANGCHUL_CASINO := "sangchul_casino"
const QA_SCOPE_HYUNSU_REUNION := "hyunsu_reunion"
const QA_SCOPE_SANGCHUL_CONFRONTATION := "sangchul_confrontation"
const QA_SCOPE_FATHER_PEAKS := "father_peaks"
const QA_SCOPE_FATHER_KTX := "father_ktx"
const QA_SCOPE_FIRST_KISS := "first_kiss"
const QA_SCOPE_DAEUN_FIRST_NIGHT := "daeun_first_night"
const QA_SCOPE_SEASON_PEAKS := "season_peaks"
const QA_SCOPE_JAEHYUK_PEAKS := "jaehyuk_peaks"
const QA_SCOPE_FIRST_SNOW := "first_snow"
const QA_SCOPE_CLIMATE := "climate"
const QA_SCOPE_EVENT_VISUALS := "event_visuals"
const QA_SCOPE_AP_EN := "ap_en"
const QA_SCOPE_AP_ACT_EN := "ap_act_en"
const QA_SCOPE_IMMERSION_LOOP := "immersion_loop"
const QA_SCOPE_MOTIVATION_IMPRINT := "motivation_imprint"
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
var _qa_failed := false
var _route_keyboard_events := 0
var _route_mouse_events := 0
var _route_gamepad_events := 0

func _tr(ko: String, en: String) -> String:
	return LocaleManager.ui(ko, en)

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	_clear_output_dir()
	var scope: String = _qa_scope()
	if scope in [QA_SCOPE_DEMO_FLOW, QA_SCOPE_DEMO_BLACKBOX, QA_SCOPE_DEMO_INPUT,
			QA_SCOPE_DEMO_GAMEPAD, QA_SCOPE_DEMO_KEYBOARD, QA_SCOPE_DEMO_MOUSE] \
			and not GameState.is_demo_build():
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
	if scope == QA_SCOPE_LIVING_SCENE:
		var lang := _qa_language("en")
		await _shot_living_scene_surfaces(
			lang, "living_en_" if lang == "en" else "living_ko_")
		print("SCREENSHOT_QA_DONE scope=living-scene lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_DISPLAY_MATRIX:
		var lang := _qa_language("en")
		await _shot_display_matrix_surfaces(lang)
		if _qa_failed:
			return
		print("SCREENSHOT_QA_DONE scope=display-matrix lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_TEXT_MATERIAL:
		var lang := _qa_language("en")
		await _shot_text_material_surfaces(lang)
		if _qa_failed:
			return
		print("SCREENSHOT_QA_DONE scope=text-material lang=%s dir=%s" % [lang, OUT_DIR])
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
	if scope == QA_SCOPE_DEMO_GAMEPAD:
		var lang := _qa_language("en")
		var pad_options := _apply_first_30_qa_options()
		if str(pad_options.get("pad", "keyboard")) == "keyboard":
			ControllerHints.force_brand_for_qa(ControllerHints.Brand.XBOX)
		await _run_demo_input_route(lang, "gamepad")
		return
	if scope == QA_SCOPE_DEMO_KEYBOARD:
		var lang := _qa_language("en")
		await _run_demo_input_route(lang, "keyboard")
		return
	if scope == QA_SCOPE_DEMO_MOUSE:
		var lang := _qa_language("en")
		await _run_demo_input_route(lang, "mouse")
		return
	if scope == QA_SCOPE_START_EN:
		var lang := _qa_language("en")
		await _shot_start_surfaces(lang, "start_en_" if lang == "en" else "start_ko_")
		print("SCREENSHOT_QA_DONE scope=start-en lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_FIRST_30:
		var lang := _qa_language("en")
		var first_30_options := _apply_first_30_qa_options()
		await _shot_first_30_surfaces(lang)
		print("SCREENSHOT_QA_DONE scope=first-30 lang=%s pad=%s reduce_motion=%s dir=%s" % [
			lang,
			str(first_30_options.get("pad", "keyboard")),
			str(first_30_options.get("reduce_motion", false)),
			OUT_DIR,
		])
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
	if scope == QA_SCOPE_STORY_PRESENCE:
		var lang := _qa_language("en")
		await _shot_story_presence_surfaces(
				lang, "presence_en_" if lang == "en" else "presence_ko_")
		print("SCREENSHOT_QA_DONE scope=story-presence lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_STORY_AUDIO:
		var lang := _qa_language("en")
		await _shot_story_audio_settings(lang, "story_audio_en_" if lang == "en" else "story_audio_ko_")
		print("SCREENSHOT_QA_DONE scope=story-audio lang=%s dir=%s" % [lang, OUT_DIR])
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
		if _qa_failed:
			get_tree().quit(1)
			return
		print("SCREENSHOT_QA_DONE scope=hometown lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_HOME_PEAKS:
		var lang := _qa_language("en")
		await _shot_home_peak_surfaces(lang, "home_peaks_en_" if lang == "en" else "home_peaks_ko_")
		if _qa_failed:
			get_tree().quit(1)
			return
		print("SCREENSHOT_QA_DONE scope=home-peaks lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_WEDDING_MORNING:
		var lang := _qa_language("en")
		await _shot_wedding_morning_surfaces(lang, "wedding_morning_en_" if lang == "en" else "wedding_morning_ko_")
		if _qa_failed:
			get_tree().quit(1)
			return
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
	if scope == QA_SCOPE_SANGCHUL_FIRST_MEET:
		var lang := _qa_language("en")
		await _shot_sangchul_first_meeting_surfaces(
				lang, "sangchul_meet_en_" if lang == "en" else "sangchul_meet_ko_")
		if _qa_failed:
			get_tree().quit(1)
			return
		print("SCREENSHOT_QA_DONE scope=sangchul-first-meet lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_SANGCHUL_DEDUCTION:
		var lang := _qa_language("en")
		await _shot_sangchul_deduction_surfaces(
				lang, "sangchul_deduction_en_" if lang == "en" else "sangchul_deduction_ko_")
		if _qa_failed:
			get_tree().quit(1)
			return
		print("SCREENSHOT_QA_DONE scope=sangchul-deduction lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_SANGCHUL_CASINO:
		var lang := _qa_language("en")
		await _shot_sangchul_casino_surfaces(
				lang, "sangchul_casino_en_" if lang == "en" else "sangchul_casino_ko_")
		if _qa_failed:
			get_tree().quit(1)
			return
		print("SCREENSHOT_QA_DONE scope=sangchul-casino lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_HYUNSU_REUNION:
		var lang := _qa_language("en")
		await _shot_hyunsu_reunion_surfaces(
				lang, "hyunsu_reunion_en_" if lang == "en" else "hyunsu_reunion_ko_")
		if _qa_failed:
			get_tree().quit(1)
			return
		print("SCREENSHOT_QA_DONE scope=hyunsu-reunion lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_SANGCHUL_CONFRONTATION:
		var lang := _qa_language("en")
		await _shot_sangchul_confrontation_surfaces(
				lang, "sangchul_en_" if lang == "en" else "sangchul_ko_")
		print("SCREENSHOT_QA_DONE scope=sangchul-confrontation lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_FATHER_PEAKS:
		var lang := _qa_language("en")
		await _shot_father_peak_surfaces(
				lang, "father_peaks_en_" if lang == "en" else "father_peaks_ko_")
		if _qa_failed:
			get_tree().quit(1)
			return
		print("SCREENSHOT_QA_DONE scope=father-peaks lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_FATHER_KTX:
		var lang := _qa_language("en")
		await _shot_father_ktx_surfaces(
				lang, "father_ktx_en_" if lang == "en" else "father_ktx_ko_")
		if _qa_failed:
			get_tree().quit(1)
			return
		print("SCREENSHOT_QA_DONE scope=father-ktx lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_FIRST_KISS:
		var lang := _qa_language("en")
		await _shot_first_kiss_surfaces(
				lang, "first_kiss_en_" if lang == "en" else "first_kiss_ko_")
		if _qa_failed:
			get_tree().quit(1)
			return
		print("SCREENSHOT_QA_DONE scope=first-kiss lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_DAEUN_FIRST_NIGHT:
		var lang := _qa_language("en")
		await _shot_daeun_first_night_surfaces(
				lang, "daeun_first_night_en_" if lang == "en" else "daeun_first_night_ko_")
		if _qa_failed:
			get_tree().quit(1)
			return
		print("SCREENSHOT_QA_DONE scope=daeun-first-night lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_SEASON_PEAKS:
		var lang := _qa_language("en")
		await _shot_season_peak_surfaces(
				lang, "season_peaks_en_" if lang == "en" else "season_peaks_ko_")
		if _qa_failed:
			get_tree().quit(1)
			return
		print("SCREENSHOT_QA_DONE scope=season-peaks lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_JAEHYUK_PEAKS:
		var lang := _qa_language("en")
		await _shot_jaehyuk_peak_surfaces(
				lang, "jaehyuk_en_" if lang == "en" else "jaehyuk_ko_")
		if _qa_failed:
			get_tree().quit(1)
			return
		print("SCREENSHOT_QA_DONE scope=jaehyuk-peaks lang=%s dir=%s" % [lang, OUT_DIR])
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
		if _qa_failed:
			return
		print("SCREENSHOT_QA_DONE scope=ap-act-en lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_IMMERSION_LOOP:
		var lang := _qa_language("en")
		await _shot_immersion_loop_surfaces(lang, "immersion_en_" if lang == "en" else "immersion_ko_")
		if _qa_failed:
			get_tree().quit(1)
			return
		print("SCREENSHOT_QA_DONE scope=immersion-loop lang=%s dir=%s" % [lang, OUT_DIR])
		get_tree().quit(0)
		return
	if scope == QA_SCOPE_MOTIVATION_IMPRINT:
		var lang := _qa_language("en")
		await _shot_motivation_imprint_surfaces(lang, "motivation_en_" if lang == "en" else "motivation_ko_")
		if _qa_failed:
			get_tree().quit(1)
			return
		print("SCREENSHOT_QA_DONE scope=motivation-imprint lang=%s dir=%s" % [lang, OUT_DIR])
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
		if arg in ["first-30", "first_30", "launch", "--first-30", "--first_30",
				"qa=first-30", "--qa=first-30", "qa=first_30", "--qa=first_30",
				"scope=first-30", "--scope=first-30"]:
			return QA_SCOPE_FIRST_30
		if arg in ["text-material", "text_material", "typography-material", "typography_material",
				"--text-material", "--text_material", "qa=text-material", "--qa=text-material",
				"qa=text_material", "--qa=text_material", "scope=text-material", "--scope=text-material"]:
			return QA_SCOPE_TEXT_MATERIAL
		if arg in ["display-matrix", "display_matrix", "resolution-matrix", "resolution_matrix",
				"--display-matrix", "--display_matrix", "qa=display-matrix", "--qa=display-matrix",
				"scope=display-matrix", "--scope=display-matrix"]:
			return QA_SCOPE_DISPLAY_MATRIX
		if arg in ["living-scene", "living_scene", "living", "--living-scene", "--living_scene",
				"qa=living-scene", "--qa=living-scene", "qa=living_scene", "--qa=living_scene",
				"scope=living-scene", "--scope=living-scene"]:
			return QA_SCOPE_LIVING_SCENE
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
		if arg in ["demo-gamepad", "demo_gamepad", "--demo-gamepad", "--demo_gamepad",
				"qa=demo-gamepad", "--qa=demo-gamepad", "scope=demo-gamepad", "--scope=demo-gamepad"]:
			return QA_SCOPE_DEMO_GAMEPAD
		if arg in ["demo-keyboard", "demo_keyboard", "--demo-keyboard", "--demo_keyboard",
				"qa=demo-keyboard", "--qa=demo-keyboard", "scope=demo-keyboard", "--scope=demo-keyboard"]:
			return QA_SCOPE_DEMO_KEYBOARD
		if arg in ["demo-mouse", "demo_mouse", "--demo-mouse", "--demo_mouse",
				"qa=demo-mouse", "--qa=demo-mouse", "scope=demo-mouse", "--scope=demo-mouse"]:
			return QA_SCOPE_DEMO_MOUSE
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
		if arg in ["story-presence", "story_presence", "presence", "--story-presence",
				"--story_presence", "qa=story-presence", "--qa=story-presence",
				"qa=story_presence", "--qa=story_presence",
				"scope=story-presence", "--scope=story-presence"]:
			return QA_SCOPE_STORY_PRESENCE
		if arg in ["story-audio", "story_audio", "vn-audio", "vn_audio",
				"--story-audio", "--story_audio", "qa=story-audio", "--qa=story-audio",
				"qa=story_audio", "--qa=story_audio", "scope=story-audio", "--scope=story-audio"]:
			return QA_SCOPE_STORY_AUDIO
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
		if arg in ["home-peaks", "home_peaks", "table-room", "table_room", "--home-peaks",
				"--home_peaks", "qa=home-peaks", "--qa=home-peaks", "qa=home_peaks",
				"--qa=home_peaks", "scope=home-peaks", "--scope=home-peaks"]:
			return QA_SCOPE_HOME_PEAKS
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
		if arg in ["sangchul-first-meet", "sangchul_first_meet", "sangchul-meet",
				"--sangchul-first-meet", "--sangchul_first_meet",
				"qa=sangchul-first-meet", "--qa=sangchul-first-meet",
				"qa=sangchul_first_meet", "--qa=sangchul_first_meet",
				"scope=sangchul-first-meet", "--scope=sangchul-first-meet"]:
			return QA_SCOPE_SANGCHUL_FIRST_MEET
		if arg in ["sangchul-deduction", "sangchul_deduction", "sangchul-truth",
				"--sangchul-deduction", "--sangchul_deduction",
				"qa=sangchul-deduction", "--qa=sangchul-deduction",
				"qa=sangchul_deduction", "--qa=sangchul_deduction",
				"scope=sangchul-deduction", "--scope=sangchul-deduction"]:
			return QA_SCOPE_SANGCHUL_DEDUCTION
		if arg in ["sangchul-casino", "sangchul_casino", "sangchul-invite",
				"--sangchul-casino", "--sangchul_casino",
				"qa=sangchul-casino", "--qa=sangchul-casino",
				"qa=sangchul_casino", "--qa=sangchul_casino",
				"scope=sangchul-casino", "--scope=sangchul-casino"]:
			return QA_SCOPE_SANGCHUL_CASINO
		if arg in ["hyunsu-reunion", "hyunsu_reunion", "hyunsu",
				"--hyunsu-reunion", "--hyunsu_reunion",
				"qa=hyunsu-reunion", "--qa=hyunsu-reunion",
				"qa=hyunsu_reunion", "--qa=hyunsu_reunion",
				"scope=hyunsu-reunion", "--scope=hyunsu-reunion"]:
			return QA_SCOPE_HYUNSU_REUNION
		if arg in ["sangchul", "sangchul-confrontation", "sangchul_confrontation",
				"--sangchul-confrontation", "qa=sangchul-confrontation",
				"--qa=sangchul-confrontation", "scope=sangchul-confrontation"]:
			return QA_SCOPE_SANGCHUL_CONFRONTATION
		if arg in ["father-peaks", "father_peaks", "father-hospital", "father_hospital",
				"--father-peaks", "--father_peaks", "qa=father-peaks", "--qa=father-peaks",
				"qa=father_peaks", "--qa=father_peaks", "scope=father-peaks", "--scope=father-peaks"]:
			return QA_SCOPE_FATHER_PEAKS
		if arg in ["father-ktx", "father_ktx", "--father-ktx", "--father_ktx",
				"qa=father-ktx", "--qa=father-ktx", "qa=father_ktx", "--qa=father_ktx",
				"scope=father-ktx", "--scope=father-ktx"]:
			return QA_SCOPE_FATHER_KTX
		if arg in ["first-kiss", "first_kiss", "romance-kiss", "romance_kiss",
				"--first-kiss", "--first_kiss", "qa=first-kiss", "--qa=first-kiss",
				"qa=first_kiss", "--qa=first_kiss", "scope=first-kiss", "--scope=first-kiss"]:
			return QA_SCOPE_FIRST_KISS
		if arg in ["daeun-first-night", "daeun_first_night", "first-night", "first_night",
				"--daeun-first-night", "--daeun_first_night", "qa=daeun-first-night",
				"--qa=daeun-first-night", "qa=daeun_first_night", "--qa=daeun_first_night",
				"scope=daeun-first-night", "--scope=daeun-first-night"]:
			return QA_SCOPE_DAEUN_FIRST_NIGHT
		if arg in ["season-peaks", "season_peaks", "season-romance", "season_romance",
				"--season-peaks", "--season_peaks", "qa=season-peaks", "--qa=season-peaks",
				"qa=season_peaks", "--qa=season_peaks", "scope=season-peaks", "--scope=season-peaks"]:
			return QA_SCOPE_SEASON_PEAKS
		if arg in ["jaehyuk-peaks", "jaehyuk_peaks", "jaehyuk", "fraud-mirror",
				"--jaehyuk-peaks", "--jaehyuk_peaks", "qa=jaehyuk-peaks",
				"--qa=jaehyuk-peaks", "qa=jaehyuk_peaks", "--qa=jaehyuk_peaks",
				"scope=jaehyuk-peaks", "--scope=jaehyuk-peaks"]:
			return QA_SCOPE_JAEHYUK_PEAKS
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
		if arg in ["immersion-loop", "immersion_loop", "--immersion-loop", "--immersion_loop",
				"qa=immersion-loop", "--qa=immersion-loop", "qa=immersion_loop", "--qa=immersion_loop",
				"scope=immersion-loop", "--scope=immersion-loop"]:
			return QA_SCOPE_IMMERSION_LOOP
		if arg in ["motivation-imprint", "motivation_imprint", "motivation", "--motivation-imprint",
				"--motivation_imprint", "qa=motivation-imprint", "--qa=motivation-imprint",
				"qa=motivation_imprint", "--qa=motivation_imprint",
				"scope=motivation-imprint", "--scope=motivation-imprint"]:
			return QA_SCOPE_MOTIVATION_IMPRINT
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

func _apply_first_30_qa_options() -> Dictionary:
	var pad := "keyboard"
	var reduce_motion := false
	var args: Array[String] = []
	for raw in OS.get_cmdline_user_args():
		args.append(str(raw).strip_edges().to_lower())
	for raw in OS.get_cmdline_args():
		args.append(str(raw).strip_edges().to_lower())
	for arg in args:
		if arg in ["--reduce-motion", "reduce-motion", "--reduce_motion", "reduce_motion"]:
			reduce_motion = true
		elif arg in ["--pad=playstation", "pad=playstation", "--pad=ps", "pad=ps",
				"--pad=dualsense", "pad=dualsense"]:
			pad = "playstation"
		elif arg in ["--pad=xbox", "pad=xbox", "--pad=steamdeck", "pad=steamdeck",
				"--pad=steam-deck", "pad=steam-deck"]:
			pad = "xbox"
		elif arg in ["--pad=nintendo", "pad=nintendo", "--pad=switch", "pad=switch"]:
			pad = "nintendo"
	SaveManager.set_setting("reduce_motion", reduce_motion)
	SaveManager.set_setting("reduced_motion", reduce_motion)
	match pad:
		"playstation":
			ControllerHints.force_brand_for_qa(ControllerHints.Brand.PLAYSTATION)
		"xbox":
			ControllerHints.force_brand_for_qa(ControllerHints.Brand.XBOX)
		"nintendo":
			ControllerHints.force_brand_for_qa(ControllerHints.Brand.NINTENDO)
		_:
			ControllerHints.clear_qa_override()
	return {"pad": pad, "reduce_motion": reduce_motion}

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
	splash.set("_qa_disable_auto_transition", true)
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
				var result_paragraphs: Array = story.get("_paragraphs")
				if bool(story.get("_pending_after_result")) \
						and int(story.get("_para_index")) >= result_paragraphs.size() - 1:
					break
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
		"arc_season_sea_daeun": "train",
		"arc_season_sea_daeun_years": "train",
		"arc_season_sea_daeun_horizon": "train",
		"arc_season_sea_daeun_decision": "seaside",
		"arc_season_sea_jiyeon": "train",
		"arc_season_sea_jiyeon_voice": "train",
		"arc_season_sea_jiyeon_route": "train",
		"arc_season_sea_jiyeon_decision": "seaside",
		"arc_season_fireworks_daeun": "hangang",
		"arc_season_fireworks_daeun_dress": "hangang",
		"arc_season_fireworks_daeun_river": "hangang",
		"arc_season_fireworks_daeun_decision": "hangang",
		"arc_season_fireworks_jiyeon": "hangang",
		"arc_season_fireworks_jiyeon_schedule": "hangang",
		"arc_season_fireworks_jiyeon_pace": "hangang",
		"arc_season_fireworks_jiyeon_decision": "hangang",
		"arc_daeun_first_night": "rain_room",
		"arc_daeun_first_night_silence": "rain_room",
		"arc_daeun_first_night_truth": "rain_room",
		"arc_daeun_first_night_decision": "rain_room",
		"arc_sangchul_01_meet": "office",
		"arc_sangchul_01_measure": "office",
		"arc_sangchul_01_coffee": "office",
		"arc_sangchul_01_answer": "office",
	}
	if expected_event_ambience.has(event_id):
		var expected_ambience := str(expected_event_ambience[event_id])
		var actual_ambience := str(BGMPlayer.get("_current_ambience_key"))
		if actual_ambience != expected_ambience:
			_fail("%s ambience expected %s, got %s." % [event_id, expected_ambience, actual_ambience])
	_assert_hyunsu_visual_state(story, event_id, select_choice)
	_assert_cafe_visual_state(story, event_id)
	_assert_resolved_visual_debt_state(story, event_id)
	_assert_jaehyuk_visual_state(story, event_id)
	_assert_commitment_visual_state(story, event_id, select_choice)
	_assert_breakup_visual_state(story, event_id, select_choice)
	_assert_transport_visual_state(story, event_id)
	_assert_daeun_first_night_visual_state(story, event_id)
	_assert_sangchul_first_meeting_visual_state(story, event_id)
	_assert_sangchul_deduction_visual_state(story, event_id)
	_assert_sangchul_casino_visual_state(story, event_id)
	_assert_living_scene_state(story, event_id)
	if _qa_scope() == QA_SCOPE_TEXT_MATERIAL:
		_assert_story_text_material(story)
	await _save(shot_name)
	_remove_nodes_by_script("res://scenes/StoryMode.gd")
	if suppress_cg and had_cg:
		overridden_event["cg"] = original_cg
	GameState.pending_story_queue.clear()
	await _settle(0.3)

func _shot_living_scene_surfaces(lang: String, prefix: String) -> void:
	await _shot_story_event("kx_monsoon", prefix + "01_rain", lang, 1.5, true)
	await _shot_story_event("arc_season_snow_daeun", prefix + "02_snow", lang, 1.5, true)
	await _shot_story_event("callback_proactive_parent_care_echo", prefix + "03_memory", lang, 1.5, true)
	await _shot_story_event("arc_season_fireworks_daeun_decision", prefix + "04_fireworks", lang, 1.5, true)
	await _shot_story_event("arc_job_first_rejection", prefix + "05_neutral", lang, 1.5, true)
	await _verify_living_scene_motion(lang)

func _shot_text_material_surfaces(lang: String) -> void:
	var resolution := get_window().size
	var supported := [Vector2i(1280, 720), Vector2i(1280, 800), Vector2i(3840, 2160)]
	if not supported.has(resolution):
		_fail("Text material QA requires 1280x720, 1280x800, or 3840x2160; got %s." % resolution)
		return
	var tag := "%dx%d_%s" % [resolution.x, resolution.y, lang]
	_set_qa_language(lang)
	_prepare_main_game_state()
	_seed_portfolio()
	await _boot_main_game()
	_seed_ap_act_state(1, lang)
	_mg.current_event = {}
	_mg.set("pending_result_text", "")
	_mg.call("_render_ap_actions")
	if _mg.has_method("_refresh_all"):
		_mg.call("_refresh_all")
	if _mg.has_method("_finish_typing"):
		_mg.call("_finish_typing")
	await _settle(0.55)
	_assert_ap_text_material(_mg, resolution)
	if _qa_failed:
		return
	await _save(tag + "_01_ap_material")
	await _dispose_main_game()

	await _shot_story_event(
		"story_knee_choice", tag + "_02_story_material", lang, 0.55, true, true)
	if _qa_failed:
		return
	print("TEXT_MATERIAL_RENDER_OK resolution=%dx%d surfaces=2 body_shadow=0 max_depth=2" % [
		resolution.x, resolution.y])

func _assert_ap_text_material(main: Node, resolution: Vector2i) -> void:
	var cards: Array[Button] = []
	for node in main.find_children("*", "Button", true, false):
		if bool(node.get_meta("demo_decision_card", false)):
			cards.append(node as Button)
	if cards.size() != 3:
		_fail("Text material AP fixture expected three demo cards at %s, got %d." % [
			resolution, cards.size()])
		return
	var title_count := 0
	var body_count := 0
	for card in cards:
		_assert_material_button(card, "AP decision")
		for node in card.find_children("*", "Label", true, false):
			var role := str(node.get_meta("ink_text_role", ""))
			if role == "choice":
				title_count += 1
				_assert_text_depth(node, 1, "AP decision title")
			elif role == "body":
				body_count += 1
				_assert_text_depth(node, 0, "AP decision body")
	if title_count < 3 or body_count < 3:
		_fail("Text material AP hierarchy incomplete at %s (titles=%d body=%d)." % [
			resolution, title_count, body_count])

func _assert_story_text_material(story: Node) -> void:
	var title := story.get("_title_lbl") as Label
	var body := story.get("_body_lbl") as RichTextLabel
	_assert_text_depth(title, 1, "StoryMode title")
	_assert_text_depth(body, 0, "StoryMode prose")
	var choice_box := story.get("_choice_box") as VBoxContainer
	var buttons: Array[Button] = []
	if choice_box != null:
		for node in choice_box.find_children("*", "Button", true, false):
			buttons.append(node as Button)
	if buttons.is_empty():
		_fail("Text material StoryMode fixture did not expose choices.")
		return
	for button in buttons:
		_assert_material_button(button, "StoryMode choice")
		_assert_text_depth(button, 1, "StoryMode choice text")

func _assert_material_button(button: Button, label: String) -> void:
	if button == null:
		_fail("%s is missing." % label)
		return
	var normal := button.get_theme_stylebox("normal") as StyleBoxFlat
	var hover := button.get_theme_stylebox("hover") as StyleBoxFlat
	var focus := button.get_theme_stylebox("focus") as StyleBoxFlat
	var pressed := button.get_theme_stylebox("pressed") as StyleBoxFlat
	if normal == null or hover == null or focus == null or pressed == null:
		_fail("%s is missing a material state." % label)
		return
	if normal.shadow_size != 1 or normal.shadow_offset != Vector2(0, 1):
		_fail("%s normal state must be depth 1/offset 1." % label)
	if hover.shadow_size > 2 or focus.shadow_size > 2:
		_fail("%s hover/focus depth exceeds 2px." % label)
	if pressed.shadow_size != 0:
		_fail("%s pressed state retained a floating shadow." % label)
	if not is_equal_approx(pressed.content_margin_top - normal.content_margin_top, 1.0):
		_fail("%s pressed content does not travel exactly 1px." % label)

func _assert_text_depth(control: Control, expected: int, label: String) -> void:
	if control == null:
		_fail("%s is missing." % label)
		return
	var y := control.get_theme_constant("shadow_offset_y")
	var outline := control.get_theme_constant("shadow_outline_size")
	var shadow := control.get_theme_color("font_shadow_color")
	if y != expected or outline != 0:
		_fail("%s depth expected %dpx without outline, got y=%d outline=%d." % [
			label, expected, y, outline])
	if expected == 0 and shadow.a > 0.001:
		_fail("%s body shadow is visible." % label)
	elif expected > 0 and shadow.a <= 0.001:
		_fail("%s ink shadow is missing." % label)

func _shot_display_matrix_surfaces(lang: String) -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var resolution := get_window().size
	var supported := [
		Vector2i(1280, 720), Vector2i(1280, 800),
		Vector2i(1920, 1080), Vector2i(2560, 1440),
		Vector2i(3840, 2160), Vector2i(3440, 1440),
	]
	if not supported.has(resolution):
		_fail("Display matrix requires 1280x720, 1280x800, 1920x1080, 2560x1440, 3840x2160, or 3440x1440; got %s." % resolution)
		return
	var tag := "%dx%d_%s" % [resolution.x, resolution.y, lang]
	await _shot_display_settings_surface(lang, tag + "_01_settings")
	if _qa_failed:
		return

	_set_qa_language(lang)
	_prepare_main_game_state()
	_seed_portfolio()
	await _boot_main_game()
	_seed_ap_act_state(1, lang)
	_mg.current_event = {}
	_mg.set("pending_result_text", "")
	_mg.call("_render_ap_actions")
	if _mg.has_method("_refresh_all"):
		_mg.call("_refresh_all")
	if _mg.has_method("_finish_typing"):
		_mg.call("_finish_typing")
	await _settle(0.55)
	_assert_ap_cards_inside_viewport()
	var pressure := _find_demo_pressure_frame(_mg)
	if pressure == null:
		_fail("Display matrix could not find the demo AP decision frame at %s." % resolution)
		return
	_assert_control_in_tv_safe_area(pressure, "AP decision frame %s" % resolution)
	if _qa_failed:
		return
	await _save(tag + "_02_ap_decision")
	await _dispose_main_game()

	await _shot_story_event(
		"arc_season_snow_daeun", tag + "_03_story_living", lang, 1.15, true, true)
	if _qa_failed:
		return
	if resolution == Vector2i(1920, 1080):
		await _shot_controller_brand_titles(lang, tag)
	ControllerHints.clear_qa_override()
	print("DISPLAY_MATRIX_OK resolution=%dx%d canvas=%dx%d safe_margin=2.5%% surfaces=3" % [
		resolution.x, resolution.y, roundi(viewport_size.x), roundi(viewport_size.y)])

func _shot_display_settings_surface(lang: String, shot_name: String) -> void:
	_set_qa_language(lang)
	var packed := load("res://scenes/StartMenu.tscn") as PackedScene
	if packed == null:
		_fail("Display matrix could not load StartMenu.tscn.")
		return
	var menu := packed.instantiate()
	get_tree().root.add_child.call_deferred(menu)
	await get_tree().process_frame
	await _settle(0.25)
	if menu.has_method("_dismiss_splash"):
		menu.call("_dismiss_splash")
	await _settle(0.4)
	menu.call("_open_settings_popup")
	await _settle(0.35)
	var overlay := menu.get("_settings_overlay") as Control
	if not is_instance_valid(overlay):
		_fail("Display matrix settings overlay did not open.")
		return
	var panel := _find_first_panel_container(overlay)
	if panel == null:
		_fail("Display matrix settings panel is missing.")
		return
	_assert_control_in_tv_safe_area(panel, "title settings")
	var focus_owner := get_viewport().gui_get_focus_owner()
	if focus_owner == null or not overlay.is_ancestor_of(focus_owner):
		_fail("Title settings has no keyboard/controller focus owner.")
		return
	await _save(shot_name)
	menu.call("_close_settings_popup")
	if is_instance_valid(menu):
		menu.queue_free()
	await get_tree().process_frame
	_remove_start_menu_nodes()
	await _settle(0.2)

func _shot_controller_brand_titles(lang: String, prefix: String) -> void:
	var brands := [
		[ControllerHints.Brand.XBOX, "xbox"],
		[ControllerHints.Brand.PLAYSTATION, "playstation"],
		[ControllerHints.Brand.NINTENDO, "nintendo"],
	]
	for entry in brands:
		ControllerHints.force_brand_for_qa(entry[0])
		_set_qa_language(lang)
		var packed := load("res://scenes/StartMenu.tscn") as PackedScene
		var menu := packed.instantiate()
		get_tree().root.add_child.call_deferred(menu)
		await get_tree().process_frame
		if menu.has_method("_dismiss_splash"):
			menu.call("_dismiss_splash")
		await _settle(0.45)
		var expected_hint := "[%s]" % ControllerHints.south()
		if not _collect_control_text(menu).contains(expected_hint):
			_fail("%s title surface is missing its South-button glyph." % ControllerHints.brand_name())
			return
		await _save("%s_04_glyph_%s" % [prefix, str(entry[1])])
		if is_instance_valid(menu):
			menu.queue_free()
		await get_tree().process_frame
		_remove_start_menu_nodes()
		await _settle(0.15)

func _find_first_panel_container(root: Node) -> PanelContainer:
	if root is PanelContainer:
		return root as PanelContainer
	for child in root.get_children():
		var found := _find_first_panel_container(child)
		if found != null:
			return found
	return null

func _assert_control_in_tv_safe_area(control: Control, context: String) -> void:
	if not is_instance_valid(control) or not control.is_visible_in_tree():
		_fail("%s is absent or hidden." % context)
		return
	var safe := DisplayManager.tv_safe_rect(get_viewport().get_visible_rect().size)
	var rect := control.get_global_rect()
	if not safe.encloses(rect):
		_fail("%s exceeds TV safe area: control=%s safe=%s." % [context, rect, safe])

func _verify_living_scene_motion(lang: String) -> void:
	_set_qa_language(lang)
	_prepare_main_game_state()
	_prepare_story_event_fixture("kx_monsoon")
	GameState.pending_story_queue = ["kx_monsoon"]
	var packed: PackedScene = load("res://scenes/StoryMode.tscn")
	var story := packed.instantiate()
	get_tree().root.add_child.call_deferred(story)
	await get_tree().process_frame
	if story.has_method("_set_auto_mode"):
		story._set_auto_mode(false, false)
	await _settle(0.45)
	var probe_bg := story.get("_bg_img") as TextureRect
	var probe_layer := story.get("_living_scene") as LivingSceneLayer
	RenderingServer.force_draw()
	await get_tree().process_frame
	var position_a := probe_bg.position if is_instance_valid(probe_bg) else Vector2.ZERO
	var scale_a := probe_bg.scale if is_instance_valid(probe_bg) else Vector2.ONE
	var first := get_viewport().get_texture().get_image().duplicate() as Image
	first.save_png("%s/living_motion_a.png" % OUT_DIR)
	await _settle(0.85)
	RenderingServer.force_draw()
	await get_tree().process_frame
	var position_b := probe_bg.position if is_instance_valid(probe_bg) else Vector2.ZERO
	var scale_b := probe_bg.scale if is_instance_valid(probe_bg) else Vector2.ONE
	var second := get_viewport().get_texture().get_image().duplicate() as Image
	second.save_png("%s/living_motion_b.png" % OUT_DIR)
	var changed := 0
	var sampled := 0
	var max_delta := 0.0
	var max_x := mini(first.get_width(), 1380)
	var max_y := mini(first.get_height(), 650)
	for y in range(90, max_y, 28):
		for x in range(40, max_x, 28):
			sampled += 1
			var a := first.get_pixel(x, y)
			var b := second.get_pixel(x, y)
			var delta := absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b)
			max_delta = maxf(max_delta, delta)
			if delta > 0.010:
				changed += 1
	print("LIVING_MOTION_STATE effect=%s camera=%s tween=%s pos=%s->%s scale=%s->%s" % [
		str(probe_layer.current_profile.get("effect", "missing")) if is_instance_valid(probe_layer) else "missing",
		str(probe_layer.current_profile.get("camera", "missing")) if is_instance_valid(probe_layer) else "missing",
		str(story.get("_direction_camera_tween") != null), position_a, position_b, scale_a, scale_b])
	if changed < 8:
		_fail("Living Scene motion probe is effectively static (%d/%d samples changed, max=%.4f bg=%s/%s scale=%s/%s layer=%s)." % [
			changed, sampled, max_delta, position_a, position_b, scale_a, scale_b,
			probe_layer.size if is_instance_valid(probe_layer) else Vector2.ZERO])
	else:
		print("LIVING_MOTION_PROBE changed=%d sampled=%d" % [changed, sampled])
	_remove_nodes_by_script("res://scenes/StoryMode.gd")
	GameState.pending_story_queue.clear()
	await _settle(0.25)
	await _verify_rain_fall_direction()

func _verify_rain_fall_direction() -> void:
	var canvas := Control.new()
	canvas.name = "RainDirectionProbe"
	canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(canvas)
	var black := ColorRect.new()
	black.color = Color.BLACK
	black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(black)
	var rain := LivingSceneLayer.new()
	canvas.add_child(rain)
	await get_tree().process_frame
	rain.configure(
		{"id": "qa_rain_direction", "background": "street_rainy"},
		"street_rainy", "", {"channel": "in_person", "portrait_role": "none"},
		0.0, false, false)
	await _settle(0.18)
	RenderingServer.force_draw()
	await get_tree().process_frame
	var first := get_viewport().get_texture().get_image().duplicate() as Image
	await get_tree().create_timer(0.075).timeout
	RenderingServer.force_draw()
	await get_tree().process_frame
	var second := get_viewport().get_texture().get_image().duplicate() as Image
	var height := mini(first.get_height(), second.get_height())
	var max_shift := maxi(42, roundi(float(height) * 0.06))
	var best_dy := 0
	var best_score := -2.0
	for dy in range(-max_shift, max_shift + 1, 2):
		var score := _rain_shift_score(first, second, dy)
		if score > best_score:
			best_score = score
			best_dy = dy
	print("RAIN_DIRECTION_PROBE best_dy=%d score=%.4f expected=down" % [best_dy, best_score])
	if best_dy <= 2:
		_fail("Rain animation travels upward or is static: best_dy=%d score=%.4f." % [
			best_dy, best_score])
	canvas.queue_free()
	await get_tree().process_frame

func _rain_shift_score(first: Image, second: Image, dy: int) -> float:
	var width := mini(first.get_width(), second.get_width())
	var height := mini(first.get_height(), second.get_height())
	var dx := roundi(-0.16 * float(dy) * float(width) / maxf(float(height), 1.0))
	var sum_ab := 0.0
	var sum_aa := 0.0
	var sum_bb := 0.0
	var sample_bottom := roundi(float(height) * 0.56)
	for y in range(24, sample_bottom, 4):
		var by := y + dy
		if by < 0 or by >= height:
			continue
		for x in range(32, width - 32, 4):
			var bx := x + dx
			if bx < 0 or bx >= width:
				continue
			var a_color := first.get_pixel(x, y)
			var b_color := second.get_pixel(bx, by)
			var a := a_color.r * 0.299 + a_color.g * 0.587 + a_color.b * 0.114
			var b := b_color.r * 0.299 + b_color.g * 0.587 + b_color.b * 0.114
			sum_ab += a * b
			sum_aa += a * a
			sum_bb += b * b
	var denom := sqrt(maxf(sum_aa * sum_bb, 0.0000001))
	return sum_ab / denom

func _assert_living_scene_state(story: Node, event_id: String) -> void:
	var expected := {
		"kx_monsoon": "rain",
		"arc_season_snow_daeun": "snow",
		"callback_proactive_parent_care_echo": "memory",
		"arc_season_fireworks_daeun": "none",
		"arc_season_fireworks_jiyeon": "none",
		"arc_season_fireworks_daeun_decision": "fireworks",
		"arc_season_fireworks_jiyeon_decision": "fireworks",
		"arc_daeun_first_night": "city_light",
		"arc_daeun_first_night_silence": "city_light",
		"arc_daeun_first_night_truth": "city_light",
		"arc_daeun_first_night_decision": "city_light",
		"arc_job_first_rejection": "none",
	}
	if not expected.has(event_id):
		return
	var profile: Dictionary = story.get("_living_profile")
	var actual_effect := str(profile.get("effect", "<missing>"))
	if actual_effect != str(expected[event_id]):
		_fail("%s living effect expected %s, got %s." % [event_id, expected[event_id], actual_effect])
		return
	if float(profile.get("blur_px", 99.0)) > 2.0:
		_fail("%s living blur exceeded 2px." % event_id)
		return
	var layer := story.get("_living_scene") as Control
	var portrait := story.get("_portrait_frame") as Control
	var text_panel := story.get("_text_panel") as Control
	if not is_instance_valid(layer) or not is_instance_valid(portrait) or not is_instance_valid(text_panel):
		_fail("%s living layer hierarchy is incomplete." % event_id)
		return
	if layer.get_index() >= portrait.get_index() or layer.get_index() >= text_panel.get_index():
		_fail("%s living particles render above portrait or text." % event_id)
		return
	if actual_effect != "none" and not layer.visible:
		_fail("%s living effect is configured but hidden." % event_id)

func _assert_hyunsu_visual_state(story: Node, event_id: String, selected_choice: int) -> void:
	var expected_portrait_id := ""
	match event_id:
		"arc_y2_hyunsu_night_bus":
			expected_portrait_id = "hyunsu"
		"hyunsu_reunion_later", "hyunsu_reunion_photo", "hyunsu_reunion_memory", "hyunsu_reunion_meet":
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
	var reunion_message_ids := [
		"hyunsu_reunion_later", "hyunsu_reunion_photo", "hyunsu_reunion_memory",
	]
	if event_id in reunion_message_ids:
		var expected_background_id := ImageRegistry.infer_background_id({}, GameState.housing)
		var actual_background_id := str(story.get("_event_background_id"))
		if actual_background_id != expected_background_id:
			_fail("%s expected live housing %s, got %s." % [
				event_id, expected_background_id, actual_background_id])
		var presentation: Dictionary = story.get("_current_presentation")
		var badge := story.get("_communication_badge") as Control
		var badge_label := story.get("_communication_label") as Label
		if str(presentation.get("channel", "")) != "message" \
				or str(presentation.get("scene_location", "")) != "current_housing" \
				or str(presentation.get("remote_actor", "")) != "hyunsu" \
				or str(presentation.get("portrait_role", "")) != "remote" \
				or not bool(story.get("_portrait_remote_inset")):
			_fail("%s does not read as Hyunsu's remote message." % event_id)
		var expected_badge := "MESSAGE" if LocaleManager.is_english() else "메시지"
		if not is_instance_valid(badge) or not badge.visible \
				or not is_instance_valid(badge_label) or badge_label.text != expected_badge:
			_fail("%s is missing its localized message badge." % event_id)
		if _qa_scope() == QA_SCOPE_HYUNSU_REUNION:
			var expected_ambience := "room"
			match str(GameState.housing):
				"gangnam", "apartment":
					expected_ambience = "apartment"
				"villa", "oneroom":
					expected_ambience = "oneroom"
			if str(BGMPlayer._current_ambience_key) != expected_ambience:
				_fail("%s expected %s ambience, got %s." % [
					event_id, expected_ambience, BGMPlayer._current_ambience_key])
			if BGMPlayer._music_mode != "ambient" or not BGMPlayer._current_key.is_empty() \
					or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
				_fail("%s started music before the physical reunion." % event_id)
	elif event_id == "hyunsu_reunion_meet":
		var presentation: Dictionary = story.get("_current_presentation")
		var badge := story.get("_communication_badge") as Control
		if str(story.get("_event_background_id")) != "gukbap_restaurant_night" \
				or str(presentation.get("channel", "")) != "in_person" \
				or str(presentation.get("scene_location", "")) != "gukbap_restaurant_night" \
				or str(presentation.get("portrait_role", "")) != "present" \
				or bool(story.get("_portrait_remote_inset")):
			_fail("Hyunsu reunion did not reset to physical restaurant co-presence.")
		if is_instance_valid(badge) and badge.visible:
			_fail("Hyunsu reunion restaurant retained the message badge.")
		if _qa_scope() == QA_SCOPE_HYUNSU_REUNION:
			if str(BGMPlayer._current_ambience_key) != "cafe" \
					or str(BGMPlayer._current_key) != "intimate" \
					or not (BGMPlayer._player_a.playing or BGMPlayer._player_b.playing):
				_fail("Hyunsu reunion restaurant did not start its human ambience and intimate score.")
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
	var proposal_events := [
		"arc_daeun_proposal",
		"arc_daeun_proposal_last_cup",
		"arc_daeun_proposal_answer",
	]
	if event_id in proposal_events:
		var paragraph_index := int(story.get("_para_index"))
		var is_final_answer := event_id == "arc_daeun_proposal_answer"
		var should_show_cg := is_final_answer and selected_choice == 0 and paragraph_index >= 1
		var cg_active := bool(story.get("_current_uses_cg"))
		if cg_active != should_show_cg:
			_fail("Daeun proposal CG state expected %s at event=%s choice=%d paragraph=%d, got %s." % [
				should_show_cg, event_id, selected_choice, paragraph_index, cg_active])
			return
		if should_show_cg:
			_assert_story_cg(story, "cg_romance_proposal_daeun", event_id)
			return
		var background_id := str(story.get("_event_background_id"))
		if background_id != "cafe":
			_fail("Daeun proposal chain expected cafe background, got %s at %s." % [background_id, event_id])
			return
		var portrait := story.get("_portrait") as TextureRect
		var portrait_path := portrait.texture.resource_path if is_instance_valid(portrait) and portrait.texture != null else ""
		var expected_portrait := ImageRegistry.get_portrait("daeun_proposal")
		if portrait_path != expected_portrait:
			_fail("Daeun proposal portrait expected %s, got %s at %s." % [expected_portrait, portrait_path, event_id])
		return
	var daeun_wedding_events := [
		"arc_daeun_wedding_day",
		"arc_daeun_wedding_groom_side",
		"arc_daeun_wedding_walk",
		"arc_daeun_wedding_aisle",
	]
	if event_id in daeun_wedding_events:
		var is_full: bool = bool(GameState.flags.get("daeun_wedding_full", false))
		var expected_id := ""
		if event_id == "arc_daeun_wedding_day":
			expected_id = "cg_romance_wedding_daeun_mother_reaction"
		elif event_id == "arc_daeun_wedding_groom_side":
			var includes_hyunsu: bool = bool(GameState.flags.get("hyunsu_reconnected", false))
			var father_passed: bool = bool(GameState.flags.get("father_passed", false))
			if father_passed and includes_hyunsu:
				expected_id = "cg_romance_wedding_daeun_father_reaction_passed_hyunsu"
			elif father_passed:
				expected_id = "cg_romance_wedding_daeun_father_reaction_passed"
			elif includes_hyunsu:
				expected_id = "cg_romance_wedding_daeun_father_reaction_hyunsu"
			else:
				expected_id = "cg_romance_wedding_daeun_father_reaction"
		elif event_id == "arc_daeun_wedding_walk":
			expected_id = "cg_romance_wedding_daeun_full" if is_full else "cg_romance_wedding_daeun_small"
		else:
			expected_id = "cg_romance_wedding_daeun_full_close" if is_full else "cg_romance_wedding_daeun_small_close"
		_assert_story_cg(story, expected_id, event_id, true)
		return
	if event_id in [
		"arc_jiyeon_wedding_gap",
		"arc_jiyeon_wedding_guest_list",
		"arc_jiyeon_wedding_gap_decision",
	]:
		_assert_story_cg(story, "cg_romance_wedding_gap_jiyeon", event_id, selected_choice >= 0)

func _assert_breakup_visual_state(story: Node, event_id: String, selected_choice: int) -> void:
	var daeun_chain := event_id in [
		"arc_daeun_final_choice",
		"arc_daeun_final_choice_kitchen",
		"arc_daeun_final_choice_name",
		"arc_daeun_final_choice_decision",
	]
	var jiyeon_chain := event_id in [
		"arc_jiyeon_verdict",
		"arc_jiyeon_verdict_voice",
		"arc_jiyeon_verdict_fear",
		"arc_jiyeon_verdict_decision",
	]
	if not daeun_chain and not jiyeon_chain:
		return
	var paragraph_index := int(story.get("_para_index"))
	var final_event := event_id in [
		"arc_daeun_final_choice_decision", "arc_jiyeon_verdict_decision",
	]
	var reveal_paragraph := 3 if daeun_chain else 2
	var expected_cg_id := "cg_romance_breakup_daeun" if daeun_chain else "cg_romance_breakup_jiyeon"
	var should_show_cg := final_event and selected_choice == 1 and paragraph_index >= reveal_paragraph
	var cg_active := bool(story.get("_current_uses_cg"))
	if cg_active != should_show_cg:
		_fail("%s breakup CG expected %s at choice=%d paragraph=%d, got %s." % [
			event_id, should_show_cg, selected_choice, paragraph_index, cg_active])
		return
	if should_show_cg:
		_assert_story_cg(story, expected_cg_id, event_id)
		return
	var expected_background := "daeun_newlywed_home" if daeun_chain else "jiyeon_newlywed_home"
	var actual_background := str(story.get("_event_background_id"))
	if actual_background != expected_background:
		_fail("%s pre-reveal background expected %s, got %s." % [event_id, expected_background, actual_background])
		return
	var portrait_frame := story.get("_portrait_frame") as Control
	if daeun_chain:
		if is_instance_valid(portrait_frame) and portrait_frame.visible:
			_fail("Daeun final-choice chain must keep her portrait hidden while prose places her in the kitchen.")
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

func _assert_story_cg(story: Node, expected_cg_id: String, context: String, allow_result_record: bool = false) -> void:
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
	if not allow_result_record and story.find_child("StoryResultRecord", true, false) != null:
		_fail("%s delayed CG should clear the result record from its focal frame." % context)

func _shot_opening_cinematic(lang: String, prefix: String) -> void:
	_set_qa_language(lang)
	var packed: PackedScene = load("res://scenes/OpeningCinematic.tscn")
	var cinema := packed.instantiate()
	cinema.set("_qa_disable_autoplay", true)
	get_tree().root.add_child.call_deferred(cinema)
	await get_tree().process_frame
	await _settle(0.35)
	for beat_index in range(3):
		await cinema._show_beat(beat_index, false)
		await _settle(0.22)
		await _save(prefix + "00_opening_beat_%d" % (beat_index + 1), 0.0)
	_remove_nodes_by_script("res://scenes/OpeningCinematic.gd")
	await _settle(0.3)

func _shot_demo_flow(lang: String = "en") -> void:
	var prefix := "demo_en_" if lang == "en" else "demo_ko_"
	await _shot_opening_cinematic(lang, prefix)
	await _shot_story_event("chapter_card_33", prefix + "01_chapter_card_33", lang, 2.7)
	for event_id in [
		"arc_intro_01_meal",
		"arc_intro_02_dad_call",
		"arc_temptation_01",
		"arc_temptation_clean",
		"arc_intro_03_sns",
		"cafe_00",
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
		"arc_temptation_01",
		"arc_temptation_clean",
		"arc_intro_03_sns",
		"cafe_00",
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

func _run_demo_input_route(lang: String = "en", input_mode: String = "keyboard") -> void:
	if input_mode not in ["keyboard", "mouse", "gamepad"]:
		_fail("Demo input route requires keyboard, mouse, or gamepad; got %s." % input_mode)
		return
	_set_qa_language(lang)
	seed(20260713)
	var original_meta := MetaProgression.data.duplicate(true)
	MetaProgression.data["content_warning_seen"] = true
	_route_keyboard_events = 0
	_route_mouse_events = 0
	_route_gamepad_events = 0
	_suppress_tutorial_overlays()
	if not await _boot_demo_from_title(input_mode):
		MetaProgression.data = original_meta
		return
	var starting_job_id := str(GameState.current_job.get("id", ""))
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	GameState.returning_from_story = false

	var seen_events: Array[String] = []
	var input_count := 0
	var last_signature := ""
	var stagnant_steps := 0
	var completed := false
	var last_reported_turn := 0
	var ap_choice_attempts: Dictionary = {}
	var route_input_counts: Dictionary = {}
	var route_week_inputs: Dictionary = {}
	var ap_peak_by_week: Dictionary = {}
	var captured_pressure_weeks: Dictionary = {}
	var pressure_capture_turns := [1, 4, 8, 12, 16, 20, 24]
	var pressure_sequence: Array[String] = []
	var pressure_family_sequence: Array[String] = []
	var pressure_counts: Dictionary = {}
	var pressure_month_counts: Dictionary = {}
	var week_kind_sequence: Array[String] = []
	var week_kind_counts: Dictionary = {}
	var observed_auto_beats: Dictionary = {}
	var captured_auto_kinds: Dictionary = {}
	var action_counts: Dictionary = {}
	var ap_action_week_counts: Dictionary = {}
	var modal_counts: Dictionary = {}
	var counted_modal_keys: Dictionary = {}
	var ap_action_inputs := 0
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
			signature += ":%s:%d:%s:%s:%s:%s:%s" % [
				event_id,
				int(scene.get("_para_index")),
				str(scene.get("_typing")),
				str(scene.get("_showing_choices")),
				str(scene.get("_pending_after_result")),
				str(scene.get("_direction_hold_active")),
				str(scene.get("_direction_beat_waiting")),
			]
			if bool(scene.get("_transitioning")) or bool(scene.get("_direction_hold_active")) \
					or event_id.is_empty():
				pass
			else:
				var tutorial_popup := scene.get("_tutorial_popup") as Control
				if is_instance_valid(tutorial_popup):
					var tutorial_button := _find_first_enabled_button(tutorial_popup)
					if tutorial_button != null:
						await _activate_route_control(tutorial_button, input_mode)
					else:
						await _advance_route_story(scene, input_mode)
					input_count += 1
					_record_demo_route_input(route_input_counts, route_week_inputs, "story:%s" % event_id)
				elif bool(scene.get("_showing_choices")):
					var focused := get_viewport().gui_get_focus_owner()
					if focused == null or not scene.is_ancestor_of(focused):
						var first_choice := _find_first_enabled_button(scene)
						if first_choice != null:
							first_choice.grab_focus()
							await get_tree().process_frame
					var route_choice := get_viewport().gui_get_focus_owner() as Control
					if route_choice != null:
						await _activate_route_control(route_choice, input_mode)
					else:
						await _advance_route_story(scene, input_mode)
					input_count += 1
					_record_demo_route_input(route_input_counts, route_week_inputs, "story:%s" % event_id)
				else:
					await _advance_route_story(scene, input_mode)
					input_count += 1
					_record_demo_route_input(route_input_counts, route_week_inputs, "story:%s" % event_id)
		elif script_path == "res://scenes/MainGame.gd":
			var sampled_turn: int = GameState.turn
			var director_kind := str(scene.call("_demo_director_week_kind"))
			var director_requires_input := bool(scene.call("_demo_director_requires_player_input"))
			if GameState.turn <= GameState.DEMO_TURN_LIMIT and director_requires_input:
				ap_peak_by_week[GameState.turn] = maxi(
					int(ap_peak_by_week.get(GameState.turn, 0)), GameState.action_points)
			var auto_beat := _find_demo_director_beat(scene, GameState.turn)
			if is_instance_valid(auto_beat):
				var beat_turn := int(auto_beat.get_meta("demo_turn", GameState.turn))
				var beat_kind := str(auto_beat.get_meta("demo_week_kind", ""))
				observed_auto_beats[beat_turn] = beat_kind
				signature += ":auto=%d:%s" % [beat_turn, beat_kind]
				if beat_kind in ["quiet", "echo"] and not captured_auto_kinds.has(beat_kind):
					captured_auto_kinds[beat_kind] = beat_turn
					await _save("demo_%s_%s_%s_week_%02d" % [
						lang, input_mode, beat_kind, beat_turn], 0.0)
			if GameState.turn != last_reported_turn:
				last_reported_turn = GameState.turn
				var pressure: Dictionary = scene.call("_demo_week_pressure")
				var pressure_id := str(pressure.get("id", "none"))
				var pressure_family := str(pressure.get("family", pressure_id))
				var pressure_actions: Array[String] = []
				for raw_action_id in pressure.get("action_ids", []):
					pressure_actions.append(str(raw_action_id))
				if GameState.turn <= GameState.DEMO_TURN_LIMIT:
					week_kind_sequence.append(director_kind)
					week_kind_counts[director_kind] = int(week_kind_counts.get(director_kind, 0)) + 1
				if GameState.turn <= GameState.DEMO_TURN_LIMIT and director_requires_input:
					pressure_sequence.append(pressure_id)
					pressure_family_sequence.append(pressure_family)
					pressure_counts[pressure_id] = int(pressure_counts.get(pressure_id, 0)) + 1
					if pressure_id == "capital":
						var capital_month := "%04d-%02d" % [GameState.year, GameState.month]
						pressure_month_counts[capital_month] = int(pressure_month_counts.get(capital_month, 0)) + 1
				print("DEMO_INPUT_PROGRESS week=%d kind=%s ap=%d events=%d pressure=%s actions=%s" % [
					GameState.turn, director_kind, GameState.action_points, seen_events.size(), pressure_id,
					",".join(pressure_actions)])
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
			if pressure_capture_turns.has(GameState.turn) and director_requires_input \
					and not captured_pressure_weeks.has(GameState.turn) \
					and not modal_visible \
					and not _qa_scene_transition_active() \
					and GameState.action_points > 0 \
					and not cards.is_empty() \
					and str(scene.get("pending_result_text")).is_empty():
				await _save("demo_%s_%s_week_%02d_pressure" % [lang, input_mode, GameState.turn], 0.0)
				captured_pressure_weeks[GameState.turn] = true
			# Screenshot settling and focus frames are real runtime frames. If a
			# deferred transition advanced the week, resample its director contract
			# before sending any input rather than carrying the old week's mode over.
			if GameState.turn != sampled_turn:
				continue
			if _qa_scene_transition_active():
				pass
			elif modal_visible:
				var counted_modal_kind := "month_summary" if bool(scene.get("_pending_month_summary")) else modal_kind
				var modal_key := "%d:%s" % [GameState.turn, counted_modal_kind]
				if not counted_modal_keys.has(modal_key):
					counted_modal_keys[modal_key] = true
					modal_counts[counted_modal_kind] = int(modal_counts.get(counted_modal_kind, 0)) + 1
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
					await _save("demo_%s_%s_input_run_final" % [lang, input_mode])
					completed = true
					break
				var modal_body_node := scene.get("modal_body") as Control
				var modal_button := _find_first_enabled_button(modal_body_node) if is_instance_valid(modal_body_node) else null
				if modal_button == null and bool(scene.get("_modal_cancelable")):
					modal_button = _find_first_enabled_button(modal)
				if modal_button != null:
					signature += ":focus=%s" % modal_button.text
					modal_button.grab_focus()
					await get_tree().process_frame
					if is_instance_valid(modal_button) and modal_button.is_inside_tree():
						await _activate_route_control(modal_button, input_mode)
						input_count += 1
						_record_demo_route_input(route_input_counts, route_week_inputs,
							"main:modal:%s" % modal_kind)
			elif GameState.has_reached_demo_limit():
				pass
			else:
				var focused := get_viewport().gui_get_focus_owner()
				var result_confirm := _find_visible_meta_button(scene, "ap_result_confirm")
				if result_confirm != null:
					result_confirm.grab_focus()
					await get_tree().process_frame
					if is_instance_valid(result_confirm) and result_confirm.is_inside_tree():
						await _activate_route_control(result_confirm, input_mode)
						input_count += 1
						_record_demo_route_input(route_input_counts, route_week_inputs, "main:result")
				elif bool(scene.get("_transient_bg_active")):
					var choice_surface := scene.get("choice_box") as Control
					var confirm := _find_first_enabled_button(choice_surface) if is_instance_valid(choice_surface) else null
					if confirm != null:
						confirm.grab_focus()
						await get_tree().process_frame
						if is_instance_valid(confirm) and confirm.is_inside_tree():
							await _activate_route_control(confirm, input_mode)
							input_count += 1
							_record_demo_route_input(route_input_counts, route_week_inputs, "main:transient")
				elif director_requires_input and GameState.action_points > 0 and not cards.is_empty():
					var playable_cards: Array[Button] = []
					for candidate in cards:
						var candidate_fn := str((candidate as Button).get_meta("ap_action_fn", "")) if candidate is Button else ""
						if candidate is Button and is_instance_valid(candidate) \
								and not (candidate as Button).is_queued_for_deletion() \
								and (candidate as Button).is_inside_tree() \
								and (candidate as Button).visible \
								and bool((candidate as Button).get_meta("demo_pressure_primary", false)) \
							and candidate_fn not in ["_ap_side_job", "_ap_write_resume", "_ap_invest"] \
								and not (candidate as Button).disabled:
							playable_cards.append(candidate as Button)
					# Rotate through the three visible responses. This exercises the controller-first
					# decision stage itself instead of opening the legacy full list and always resting.
					var action_card: Button = null
					if not playable_cards.is_empty():
						var used_slots := maxi(0, GameState.max_action_points - GameState.action_points)
						var attempt_key := "%d:%d" % [GameState.turn, GameState.action_points]
						var attempt := int(ap_choice_attempts.get(attempt_key, 0))
						var choice_index := posmod(GameState.turn + used_slots - 1 + attempt, playable_cards.size())
						ap_choice_attempts[attempt_key] = attempt + 1
						action_card = playable_cards[choice_index]
					if action_card == null:
						MetaProgression.data = original_meta
						_fail("Demo input run found no safe primary AP response at week %d; fallback is forbidden." % GameState.turn)
						return
					var action_turn: int = GameState.turn
					action_card.grab_focus()
					await get_tree().process_frame
					# A result/tendency transition may replace the decision week during the
					# focus frame. Never attribute or send that stale confirm to the new week.
					if GameState.turn != action_turn \
							or not bool(scene.call("_demo_director_requires_player_input")):
						continue
					if is_instance_valid(action_card) and action_card.is_inside_tree() \
							and not action_card.disabled:
						var selected_action_id := str(action_card.get_meta("demo_action_id", "fallback"))
						action_counts[selected_action_id] = int(action_counts.get(selected_action_id, 0)) + 1
						ap_action_week_counts[GameState.turn] = int(ap_action_week_counts.get(GameState.turn, 0)) + 1
						print("DEMO_AP_ACTION week=%d ap_before=%d action=%s fn=%s" % [
							GameState.turn, GameState.action_points, selected_action_id,
							str(action_card.get_meta("ap_action_fn", ""))])
						await _activate_route_control(action_card, input_mode)
						input_count += 1
						_record_demo_route_input(route_input_counts, route_week_inputs, "main:ap")
						ap_action_inputs += 1
				elif director_requires_input and GameState.action_points <= 0:
					var next_week := scene.get("next_button") as Button
					if is_instance_valid(next_week) and not next_week.disabled:
						next_week.grab_focus()
						await get_tree().process_frame
						if is_instance_valid(next_week) and next_week.is_inside_tree():
							await _activate_route_control(next_week, input_mode)
							input_count += 1
							_record_demo_route_input(route_input_counts, route_week_inputs, "main:next_week")
				elif focused is Button and scene.is_ancestor_of(focused) \
						and focused != scene.get("next_button") and cards.find(focused) < 0 \
						and focused.is_visible_in_tree() and not focused.disabled:
					await _activate_route_control(focused as Control, input_mode)
					input_count += 1
					_record_demo_route_input(route_input_counts, route_week_inputs, "main:focused")

		if signature == last_signature:
			stagnant_steps += 1
		else:
			last_signature = signature
			stagnant_steps = 0
		if stagnant_steps > 550:
			await _save("demo_%s_%s_stall" % [lang, input_mode], 0.0)
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
	for forbidden_id in ["arc_spec_career"]:
		if seen_events.has(forbidden_id):
			MetaProgression.data = original_meta
			_fail("Demo input run reached contradictory event %s." % forbidden_id)
			return
	if not starting_job_id.is_empty():
		MetaProgression.data = original_meta
		_fail("Title-started demo route did not begin unemployed: %s." % starting_job_id)
		return
	if GameState.money_weeks_total <= 0 or GameState.human_weeks_total <= 0:
		MetaProgression.data = original_meta
		_fail("Demo input route did not record both sides of the time ledger: money=%d people=%d." % [
			GameState.money_weeks_total, GameState.human_weeks_total])
		return
	if input_mode == "keyboard" and _route_mouse_events != 0:
		MetaProgression.data = original_meta
		_fail("Keyboard-only route emitted %d mouse events." % _route_mouse_events)
		return
	if input_mode == "mouse" and _route_keyboard_events != 0:
		MetaProgression.data = original_meta
		_fail("Mouse-only route emitted %d keyboard events." % _route_keyboard_events)
		return
	if input_mode == "gamepad" and (_route_keyboard_events != 0 or _route_mouse_events != 0):
		MetaProgression.data = original_meta
		_fail("Gamepad-only route emitted keyboard=%d mouse=%d events." % [
			_route_keyboard_events, _route_mouse_events])
		return
	if week_kind_sequence.size() != GameState.DEMO_TURN_LIMIT:
		MetaProgression.data = original_meta
		_fail("Demo route sampled %d paced weeks instead of %d." % [
			week_kind_sequence.size(), GameState.DEMO_TURN_LIMIT])
		return
	var direct_decision_weeks := int(week_kind_counts.get("decision", 0)) \
			+ int(week_kind_counts.get("boss", 0))
	if direct_decision_weeks < 8 or direct_decision_weeks > 10:
		MetaProgression.data = original_meta
		_fail("Demo route exposed %d direct decision weeks instead of 8..10." % direct_decision_weeks)
		return
	if int(week_kind_counts.get("boss", 0)) != 2:
		MetaProgression.data = original_meta
		_fail("Demo route exposed %d boss weeks instead of two." % int(week_kind_counts.get("boss", 0)))
		return
	if int(week_kind_counts.get("echo", 0)) < 3 or int(week_kind_counts.get("echo", 0)) > 5:
		MetaProgression.data = original_meta
		_fail("Demo route exposed an invalid echo count: %s." % week_kind_counts)
		return
	if pressure_sequence.size() != direct_decision_weeks:
		MetaProgression.data = original_meta
		_fail("Demo route sampled %d pressure frames for %d direct decision weeks." % [
			pressure_sequence.size(), direct_decision_weeks])
		return
	for paced_week in range(1, GameState.DEMO_TURN_LIMIT + 1):
		var observed_kind := str(week_kind_sequence[paced_week - 1])
		if observed_kind not in ["quiet", "echo"]:
			continue
		if str(observed_auto_beats.get(paced_week, "")) != observed_kind:
			MetaProgression.data = original_meta
			_fail("Demo auto-flow did not render %s at week %d: %s." % [
				observed_kind, paced_week, observed_auto_beats])
			return
	if GameState.current_job.is_empty() or int(action_counts.get("apply", 0)) < 1:
		MetaProgression.data = original_meta
		_fail("Demo route never exercised the primary Job Hunt response and finished unemployed.")
		return
	if int(action_counts.get("fallback", 0)) != 0:
		MetaProgression.data = original_meta
		_fail("Demo route escaped to See Other Actions instead of choosing the pressure cards.")
		return
	for week in range(1, GameState.DEMO_TURN_LIMIT + 1):
		print("DEMO_AP_ACTION_PROFILE week=%d primary=%d" % [
			week, int(ap_action_week_counts.get(week, 0))])
	var available_ap_budget := 0
	for week in range(1, GameState.DEMO_TURN_LIMIT + 1):
		available_ap_budget += int(ap_peak_by_week.get(week, 0))
	if ap_action_inputs != available_ap_budget:
		MetaProgression.data = original_meta
		_fail("Demo route used %d primary AP responses from an available budget of %d." % [
			ap_action_inputs, available_ap_budget])
		return
	for action_week_value in ap_action_week_counts.keys():
		var action_week := int(action_week_value)
		var runtime_kind := str(week_kind_sequence[action_week - 1]) \
				if action_week >= 1 and action_week <= week_kind_sequence.size() else ""
		if runtime_kind not in ["decision", "boss"]:
			MetaProgression.data = original_meta
			_fail("Demo route emitted AP input during %s week %d." % [runtime_kind, action_week])
			return
	if int(modal_counts.get("month_summary", 0)) != 3:
		MetaProgression.data = original_meta
		_fail("Demo route showed %d full month summaries instead of three: %s." % [
			int(modal_counts.get("month_summary", 0)), modal_counts])
		return
	if GameState.turn != GameState.DEMO_TURN_LIMIT + 1 or GameState.month != 7:
		MetaProgression.data = original_meta
		_fail("Demo route did not process all six monthly economies: turn=%d month=%d." % [
			GameState.turn, GameState.month])
		return
	var pressure_streak := _max_consecutive_strings(pressure_sequence)
	if int(pressure_streak.get("count", 0)) > 4:
		MetaProgression.data = original_meta
		_fail("Demo pressure frame %s repeated %d consecutive weeks." % [
			str(pressure_streak.get("value", "none")), int(pressure_streak.get("count", 0))])
		return
	for capital_month in pressure_month_counts:
		if int(pressure_month_counts[capital_month]) > 1:
			MetaProgression.data = original_meta
			_fail("Capital pressure repeated %d times in %s." % [
				int(pressure_month_counts[capital_month]), str(capital_month)])
			return
	if int(pressure_counts.get("capital", 0)) < 1:
		MetaProgression.data = original_meta
		_fail("Demo route never exposed the monthly capital decision window.")
		return
	var family_streak := _max_consecutive_strings(pressure_family_sequence)
	print("DEMO_INPUT_RHYTHM week_kinds=%s kind_counts=%s auto_beats=%s pressure_sequence=%s pressure_counts=%s pressure_months=%s max_frame=%s:%d max_family=%s:%d action_counts=%s modal_counts=%s ap_action_inputs=%d/%d inputs_per_week=%.1f" % [
		">".join(week_kind_sequence), str(week_kind_counts), str(observed_auto_beats),
		">".join(pressure_sequence), str(pressure_counts), str(pressure_month_counts),
		str(pressure_streak.get("value", "none")), int(pressure_streak.get("count", 0)),
		str(family_streak.get("value", "none")), int(family_streak.get("count", 0)),
		str(action_counts), str(modal_counts), ap_action_inputs, available_ap_budget,
		float(input_count) / float(GameState.DEMO_TURN_LIMIT)])
	MetaProgression.data = original_meta
	_print_demo_route_input_profile(route_input_counts, route_week_inputs)
	print("DEMO_INPUT_RUN_OK device=%s weeks=24 inputs=%d events=%d start_job=unemployed end_job=%s axes=%d/%d key_events=%d mouse_events=%d gamepad_events=%d cutoff=cta" % [
		input_mode, input_count, seen_events.size(), str(GameState.current_job.get("id", "unemployed")),
		GameState.money_weeks_total, GameState.human_weeks_total,
		_route_keyboard_events, _route_mouse_events, _route_gamepad_events])
	get_tree().quit(0)

func _record_demo_route_input(counts: Dictionary, week_counts: Dictionary, key: String) -> void:
	counts[key] = int(counts.get(key, 0)) + 1
	var week := clampi(GameState.turn, 1, GameState.DEMO_TURN_LIMIT)
	week_counts[week] = int(week_counts.get(week, 0)) + 1

func _print_demo_route_input_profile(counts: Dictionary, week_counts: Dictionary) -> void:
	var ranked: Array = counts.keys()
	ranked.sort_custom(func(a, b): return int(counts[a]) > int(counts[b]))
	for index in range(mini(12, ranked.size())):
		var key: String = str(ranked[index])
		print("DEMO_INPUT_PROFILE_TOP rank=%d inputs=%d key=%s" % [
			index + 1, int(counts[key]), key])
	for week in range(1, GameState.DEMO_TURN_LIMIT + 1):
		print("DEMO_INPUT_PROFILE_WEEK week=%d inputs=%d" % [
			week, int(week_counts.get(week, 0))])

func _max_consecutive_strings(values: Array[String]) -> Dictionary:
	var best_value := ""
	var best_count := 0
	var current_value := ""
	var current_count := 0
	for value in values:
		if value == current_value:
			current_count += 1
		else:
			current_value = value
			current_count = 1
		if current_count > best_count:
			best_value = current_value
			best_count = current_count
	return {"value": best_value, "count": best_count}

func _boot_demo_from_title(input_mode: String) -> bool:
	var packed := load("res://scenes/StartMenu.tscn") as PackedScene
	if packed == null:
		_fail("Demo input run could not load StartMenu.tscn.")
		return false
	var menu := packed.instantiate()
	get_tree().root.add_child.call_deferred(menu)
	await get_tree().process_frame
	get_tree().current_scene = menu
	await _settle(0.25)
	if input_mode == "gamepad":
		await _send_route_raw_gamepad_button(JOY_BUTTON_A)
	else:
		await _send_route_input(input_mode)
	await _settle(0.45)
	if not is_instance_valid(menu):
		_fail("%s title route consumed the splash and New Story with one input." % input_mode)
		return false
	var new_story := _find_button_with_any_text(menu, ["New Story", "새 이야기"])
	if new_story == null:
		_fail("%s title route could not reach New Story." % input_mode)
		return false
	await _activate_route_control(new_story, input_mode)
	var opening_skip_sent := false
	var last_boot_path := ""
	for _frame in range(900):
		await get_tree().create_timer(0.02).timeout
		var current := get_tree().current_scene
		if is_instance_valid(current) and current != menu:
			var script := current.get_script() as Script
			var path := script.resource_path if script != null else ""
			if path != last_boot_path:
				last_boot_path = path
				print("DEMO_INPUT_BOOT_STAGE device=%s scene=%s" % [input_mode, path])
			if path in ["res://scenes/MainGame.gd", "res://scenes/StoryMode.gd"]:
				print("DEMO_INPUT_TITLE_OK device=%s next=%s" % [input_mode, path])
				return true
			if path == "res://scenes/OpeningCinematic.gd" and not opening_skip_sent \
					and not bool(current.get("_transitioning")):
				await get_tree().create_timer(0.28).timeout
				if input_mode == "gamepad":
					await _send_route_raw_gamepad_button(JOY_BUTTON_A)
				else:
					await _send_route_input(input_mode)
				opening_skip_sent = true
	await _save("demo_boot_%s_stall" % input_mode, 0.0)
	_fail("%s title route did not hand off to the playable demo; last scene=%s." % [
		input_mode, last_boot_path])
	return false

func _find_button_with_any_text(root: Node, candidates: Array[String]) -> Button:
	if root is Button and (root as Button).visible and not (root as Button).disabled:
		for candidate in candidates:
			if (root as Button).text == candidate:
				return root as Button
	for child in root.get_children():
		var found := _find_button_with_any_text(child, candidates)
		if found != null:
			return found
	return null

func _activate_route_control(control: Control, input_mode: String) -> void:
	if not is_instance_valid(control):
		return
	if input_mode == "mouse":
		var rect := control.get_global_rect()
		var viewport_rect := get_viewport().get_visible_rect()
		if not viewport_rect.intersects(rect):
			print("DEMO_MOUSE_TARGET_OFFSCREEN name=%s rect=%s viewport=%s" % [
				control.name, rect, viewport_rect])
		await _send_route_mouse_click(control.get_global_rect().get_center())
		return
	control.grab_focus()
	await get_tree().process_frame
	await _send_route_input(input_mode)

func _advance_route_story(_story: Node, input_mode: String) -> void:
	if input_mode == "mouse":
		await _send_route_mouse_click(get_viewport().get_visible_rect().size * Vector2(0.5, 0.42))
	elif input_mode == "keyboard":
		await _send_route_key(KEY_ENTER)
	else:
		await _send_route_gamepad_button(JOY_BUTTON_A)

func _send_route_input(input_mode: String) -> void:
	match input_mode:
		"mouse":
			await _send_route_mouse_click(get_viewport().get_visible_rect().size * 0.5)
		"gamepad":
			await _send_route_gamepad_button(JOY_BUTTON_A)
		_:
			await _send_route_key(KEY_ENTER)

func _send_route_key(keycode: Key) -> void:
	var pressed := InputEventKey.new()
	pressed.keycode = keycode
	pressed.physical_keycode = keycode
	pressed.pressed = true
	Input.parse_input_event(pressed)
	_route_keyboard_events += 1
	await get_tree().process_frame
	var released := pressed.duplicate() as InputEventKey
	released.pressed = false
	Input.parse_input_event(released)
	_route_keyboard_events += 1
	await get_tree().process_frame

func _send_route_gamepad_button(button_index: JoyButton) -> void:
	if button_index != JOY_BUTTON_A:
		_fail("Demo gamepad route only supports the South/accept button, got %d." % button_index)
		return
	var pressed := InputEventAction.new()
	pressed.action = "ui_accept"
	pressed.pressed = true
	pressed.strength = 1.0
	Input.parse_input_event(pressed)
	_route_gamepad_events += 1
	await get_tree().process_frame
	var released := pressed.duplicate() as InputEventAction
	released.pressed = false
	released.strength = 0.0
	Input.parse_input_event(released)
	_route_gamepad_events += 1
	await get_tree().process_frame

func _send_route_raw_gamepad_button(button_index: JoyButton) -> void:
	var pressed := InputEventJoypadButton.new()
	pressed.device = 0
	pressed.button_index = button_index
	pressed.pressed = true
	pressed.pressure = 1.0
	Input.parse_input_event(pressed)
	_route_gamepad_events += 1
	await get_tree().process_frame
	var released := pressed.duplicate() as InputEventJoypadButton
	released.pressed = false
	released.pressure = 0.0
	Input.parse_input_event(released)
	_route_gamepad_events += 1
	await get_tree().process_frame

func _send_route_mouse_click(position: Vector2) -> void:
	# Push local viewport coordinates directly. Input.parse_input_event() routes via
	# the host-window transform and can miss scaled VN choice buttons on macOS.
	Input.warp_mouse(position)
	await get_tree().process_frame
	var motion := InputEventMouseMotion.new()
	motion.position = position
	motion.global_position = position
	get_viewport().push_input(motion, true)
	_route_mouse_events += 1
	await get_tree().process_frame
	var pressed := InputEventMouseButton.new()
	pressed.button_index = MOUSE_BUTTON_LEFT
	pressed.position = position
	pressed.global_position = position
	pressed.pressed = true
	pressed.button_mask = MOUSE_BUTTON_MASK_LEFT
	get_viewport().push_input(pressed, true)
	_route_mouse_events += 1
	await get_tree().process_frame
	var released := pressed.duplicate() as InputEventMouseButton
	released.pressed = false
	released.button_mask = 0
	get_viewport().push_input(released, true)
	_route_mouse_events += 1
	await get_tree().process_frame

func _find_first_enabled_button(root: Node) -> Button:
	if root is Button and root.visible and not root.disabled and root.focus_mode != Control.FOCUS_NONE:
		return root as Button
	for child in root.get_children():
		var found := _find_first_enabled_button(child)
		if found != null:
			return found
	return null

func _find_visible_meta_button(root: Node, meta_key: String) -> Button:
	if root is Button:
		var button := root as Button
		if button.is_visible_in_tree() and not button.disabled \
				and button.focus_mode != Control.FOCUS_NONE \
				and bool(button.get_meta(meta_key, false)):
			return button
	if root is Control and not (root as Control).is_visible_in_tree():
		return null
	for child in root.get_children():
		var found := _find_visible_meta_button(child, meta_key)
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
	await _shot_start_menu_notice(lang, prefix)
	await _shot_opening_cinematic(lang, prefix)

func _shot_first_30_surfaces(lang: String = "en") -> void:
	var prefix := "launch_en_" if lang == "en" else "launch_ko_"
	await _shot_splash_screen(lang, prefix + "00_publisher")
	await _shot_start_menu_notice(lang, prefix)
	await _shot_opening_cinematic(lang, prefix)

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
		"arc_season_sea_daeun_decision", "trailer_10_romance_sea", "", 0.35, true)
	_prepare_main_game_state()
	GameState.flags["daeun_romance_started"] = true
	GameState.moral_tint = 32.0
	await _shot_story_event("arc_season_fireworks_daeun_decision", "trailer_11_romance_fireworks", "", 0.45, true)
	_prepare_wedding_morning_qa_state("daeun")
	GameState.moral_tint = 32.0
	await _shot_story_event(
		"arc_daeun_wedding_night_choice", "trailer_12_romance_morning", "", 0.35,
		true, true, 0, 0, false, 1)

	_prepare_breakup_qa_state("daeun")
	await _shot_story_event(
		"arc_daeun_final_choice_decision", "trailer_13_divorce_seal", "", 0.35,
		true, true, 1, 0, false, 3)
	_prepare_breakup_qa_state("jiyeon")
	await _shot_story_event(
		"arc_jiyeon_verdict_decision", "trailer_14_departure", "", 0.35,
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
	GameState.flags["investment_first_visited"] = true
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
	elif node is RichTextLabel:
		result += (node as RichTextLabel).text + "\n"
	elif node is Button:
		result += (node as Button).text + "\n"
	for child in node.get_children():
		result += _collect_control_text(child)
	return result

func _contains_hangul(text: String) -> bool:
	for index in range(text.length()):
		var codepoint := text.unicode_at(index)
		if (codepoint >= 0xAC00 and codepoint <= 0xD7A3) \
				or (codepoint >= 0x3130 and codepoint <= 0x318F) \
				or (codepoint >= 0x1100 and codepoint <= 0x11FF):
			return true
	return false

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
	await _shot_story_event("arc_daeun_proposal_answer", prefix + "04_direction_proposal", lang, 1.2, true)
	await _shot_story_event("arc_season_sea_daeun", prefix + "05a_romance_sea_daeun_train", lang, 0.65, true)
	await _shot_story_event("arc_season_sea_daeun_decision", prefix + "05b_romance_sea_daeun_reveal", lang, 0.45, true)
	await _shot_story_event("arc_season_sea_jiyeon_decision", prefix + "06_romance_sea_jiyeon", lang, 0.65, true)
	await _shot_story_event("arc_season_fireworks_daeun_decision", prefix + "07_romance_fireworks_daeun", lang, 0.65, true, false, -1, 2)
	await _shot_story_event("arc_season_fireworks_jiyeon_decision", prefix + "08_romance_fireworks_jiyeon", lang, 0.65, true, false, -1, 2)
	await _shot_story_event("arc_season_cherry_daeun", prefix + "09_romance_cherry_daeun", lang, 0.65, true)
	await _shot_story_event("arc_season_cherry_jiyeon", prefix + "10_romance_cherry_jiyeon", lang, 0.65, true)
	await _shot_story_event("arc_daeun_first_kiss", prefix + "11_romance_first_kiss_daeun", lang, 0.65, true)
	await _shot_story_event("arc_jiyeon_first_kiss", prefix + "12_romance_first_kiss_jiyeon", lang, 0.65, true)
	await _shot_story_event("arc_jiyeon_narrow_room_1", prefix + "13a0_romance_jiyeon_before_knock", lang, 0.45, true, false, -1, 0, true)
	await _shot_story_event("arc_jiyeon_narrow_room_1", prefix + "13a1_romance_jiyeon_narrow_door", lang, 0.45, true, false, -1, 2, true)
	await _shot_story_event("arc_jiyeon_narrow_room_2", prefix + "13b_romance_jiyeon_narrow_room", lang, 0.65, true)
	await _shot_story_event("arc_jiyeon_narrow_room_2", prefix + "13c_romance_jiyeon_narrow_choices", lang, 0.45, true, true)

func _shot_story_presence_surfaces(lang: String = "en", prefix: String = "presence_en_") -> void:
	_set_qa_language(lang)
	_prepare_main_game_state()
	await _shot_story_event("story_prologue_dad", prefix + "01_father_remote_phone", "", 0.55, true)
	await _shot_story_event("arc_father_quiet_call", prefix + "02_father_remote_callback", "", 0.55, true)
	await _shot_story_event("arc_father_02_signal", prefix + "03_local_message", "", 0.55, true)
	await _shot_story_event("callback_sangchul_personal_echo", prefix + "04_memory_inset", "", 0.55, true)
	await _shot_story_event("arc_sangchul_confrontation", prefix + "05_in_person_full_portrait", "", 0.55, true)

func _shot_story_audio_settings(lang: String = "en", prefix: String = "story_audio_en_") -> void:
	_set_qa_language(lang)
	var original_text_size := str(SaveManager.get_setting("story_text_size", "standard"))
	SaveManager.set_setting("story_text_size", "standard")
	_prepare_main_game_state()
	_prepare_story_event_fixture("arc_daeun_wedding_day")
	GameState.flags["daeun_wedding_small"] = true
	GameState.pending_story_queue = ["arc_daeun_wedding_day"]
	var packed := load("res://scenes/StoryMode.tscn") as PackedScene
	var story := packed.instantiate() as Control
	get_tree().root.add_child.call_deferred(story)
	await get_tree().process_frame
	await _settle(0.55)
	story.call("_complete_typing")
	story.call("_open_audio_settings")
	await _settle(0.35)
	var popup := story.get("_audio_settings_popup") as Control
	var bgm_slider := story.get("_audio_bgm_slider") as HSlider
	var sfx_slider := story.get("_audio_sfx_slider") as HSlider
	var text_buttons: Dictionary = story.get("_story_text_size_buttons")
	var language_buttons: Dictionary = story.get("_story_language_buttons")
	var large_button := text_buttons.get("large") as Button
	if not is_instance_valid(popup) or not is_instance_valid(bgm_slider) \
			or not is_instance_valid(sfx_slider) or not is_instance_valid(large_button) \
			or not language_buttons.has("ko") or not language_buttons.has("en"):
		_fail("Story scene settings surface is incomplete.")
		return
	var settings_panel := popup.get_child(0) as Control if popup.get_child_count() > 0 else null
	if not is_instance_valid(settings_panel) \
			or not get_viewport().get_visible_rect().encloses(settings_panel.get_global_rect()):
		_fail("Story scene settings escaped the viewport at %s." % str(get_viewport().get_visible_rect().size))
		return
	if not popup.find_children("*", "ScrollContainer", true, false).is_empty():
		_fail("Story scene settings introduced a controller-hostile scroll surface.")
		return
	large_button.grab_focus()
	large_button.button_pressed = true
	large_button.emit_signal("pressed")
	await _settle(0.15)
	if str(story.get("_story_text_size")) != "large":
		_fail("Story scene settings did not apply large text.")
		return
	if lang == "en" and _contains_hangul(_collect_control_text(popup)):
		_fail("Story scene settings leaked Hangul in English mode.")
		return
	await _save(prefix + "01_wedding_scene_settings_large")
	story.call("_close_audio_settings")
	await _settle(0.18)
	story.call("_complete_typing")
	await _settle(0.10)
	var body := story.get("_body_lbl") as RichTextLabel
	if not is_instance_valid(body) or body.get_content_height() > body.size.y + 1.0:
		_fail("Large story text clipped at %s." % str(get_viewport().get_visible_rect().size))
		return
	if lang == "en" and _contains_hangul(_collect_control_text(story)):
		_fail("Large English story surface leaked Hangul.")
		return
	await _save(prefix + "02_wedding_large_text")
	SaveManager.set_setting("story_text_size", original_text_size)
	_remove_nodes_by_script("res://scenes/StoryMode.gd")
	GameState.pending_story_queue.clear()
	await _settle(0.2)

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
		["arc_36_trust_crack", "04_relationship_bill", 0],
		["arc_final_countdown", "05_final_countdown", 0],
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
			GameState.turn = 176
			GameState.age = 36
			GameState.month = 9
			GameState.money = 800_000_000.0
		"arc_36_trust_crack":
			GameState.turn = 152
			GameState.age = 36
			GameState.month = 3
			GameState.money = 1_050_000_000.0
		"arc_final_countdown":
			GameState.turn = 237
			GameState.age = 37
			GameState.month = 12
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
	_set_qa_language(lang)

	_prepare_home_peak_qa_state("daeun")
	await _shot_story_event("arc_daeun_hometown_1", prefix + "00_train_intro", "", 0.45, true)
	_prepare_home_peak_qa_state("daeun")
	await _shot_story_event("arc_daeun_hometown_1", prefix + "01_train_choices", "", 0.45, true, true)
	_prepare_home_peak_qa_state("daeun")
	await _shot_story_event("arc_daeun_hometown_1", prefix + "02_train_result", "", 0.45, true, true, 0)

	_prepare_home_peak_qa_state("daeun")
	await _shot_story_event("arc_daeun_hometown_2", prefix + "03_table_intro", "", 0.45, true)
	_assert_home_peak_uncommitted("daeun", "table intro")
	_prepare_home_peak_qa_state("daeun")
	await _shot_story_event("arc_daeun_hometown_2", prefix + "04_table_opening_choice", "", 0.45, true, true, 0)
	_assert_home_peak_uncommitted("daeun", "table opening")
	_prepare_home_peak_qa_state("daeun")
	await _shot_story_event("arc_daeun_hometown_table_hands", prefix + "05_table_hands", "", 0.45, true, true, 0)
	_assert_home_peak_uncommitted("daeun", "table hands")
	_prepare_home_peak_qa_state("daeun")
	await _shot_story_event("arc_daeun_hometown_table_daughter", prefix + "06_table_daughter", "", 0.45, true, true, 0)
	_assert_home_peak_uncommitted("daeun", "table daughter")
	_prepare_home_peak_qa_state("daeun")
	await _shot_story_event("arc_daeun_hometown_table_decision", prefix + "07_table_final_choice", "", 0.45, true, true)
	_assert_home_peak_uncommitted("daeun", "table final")
	_prepare_home_peak_qa_state("daeun")
	await _shot_story_event("arc_daeun_hometown_table_decision", prefix + "08_table_empty_bowl", "", 0.45, true, true, 0)
	_assert_home_peak_state("daeun", "empty bowl", 70, 4.0, 58)
	_prepare_home_peak_qa_state("daeun")
	await _shot_story_event("arc_daeun_hometown_table_decision", prefix + "09_table_night_bus", "", 0.45, true, true, 0, 0, false, 1)
	_assert_home_peak_state("daeun", "night bus", 70, 4.0, 58)
	_prepare_home_peak_qa_state("daeun")
	await _shot_story_event("arc_daeun_hometown_table_decision", prefix + "10_table_omelet_result", "", 0.45, true, true, 1, 0, false, 1)
	_assert_home_peak_state("daeun", "omelet", 68, 5.0, 60)
	_prepare_home_peak_qa_state("daeun")
	GameState.flags["father_passed"] = true
	await _shot_story_event("arc_daeun_hometown_2", prefix + "10b_table_father_known", "", 0.5, true)
	_assert_home_peak_uncommitted("daeun", "father-known table")

	_prepare_home_peak_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_narrow_room_1", prefix + "11_narrow_door", "", 0.45, true, false, -1, 2)
	_prepare_home_peak_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_narrow_room_2", prefix + "12_narrow_intro", "", 0.45, true)
	_assert_home_peak_uncommitted("jiyeon", "narrow intro")
	_prepare_home_peak_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_narrow_room_2", prefix + "13_narrow_opening_choice", "", 0.45, true, true, 0)
	_assert_home_peak_uncommitted("jiyeon", "narrow opening")
	_prepare_home_peak_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_narrow_room_silence", prefix + "14_narrow_silence", "", 0.45, true, true, 0)
	_assert_home_peak_uncommitted("jiyeon", "narrow silence")
	_prepare_home_peak_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_narrow_room_truth", prefix + "15_narrow_truth", "", 0.45, true, true, 0)
	_assert_home_peak_uncommitted("jiyeon", "narrow truth")
	_prepare_home_peak_qa_state("jiyeon")
	GameState.flags["told_jiyeon_about_records"] = true
	await _shot_story_event("arc_jiyeon_narrow_room_truth", prefix + "15b_narrow_records_known", "", 0.5, true)
	_assert_home_peak_uncommitted("jiyeon", "records-known truth")
	_prepare_home_peak_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_narrow_room_decision", prefix + "16_narrow_final_choice", "", 0.45, true, true)
	_assert_home_peak_uncommitted("jiyeon", "narrow final")
	_prepare_home_peak_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_narrow_room_decision", prefix + "17_narrow_embrace", "", 0.45, true, true, 0)
	_assert_home_peak_state("jiyeon", "embrace", 68, 4.0, 60)
	_prepare_home_peak_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_narrow_room_decision", prefix + "18_narrow_ramyeon", "", 0.45, true, true, 1)
	_assert_home_peak_state("jiyeon", "ramyeon", 66, 3.0, 58)

func _shot_home_peak_surfaces(lang: String = "en", prefix: String = "home_peaks_en_") -> void:
	await _shot_hometown_surfaces(lang, prefix)

func _prepare_home_peak_qa_state(person_id: String) -> void:
	_prepare_main_game_state()
	GameState.age = 35
	GameState.turn = 181
	GameState.year = 2029
	GameState.month = 9 if person_id == "daeun" else 10
	GameState.week_of_month = 2
	GameState.mental = 60
	GameState.moral_tint = 0.0
	for flag in [
		"arc_daeun_hometown_2_seen", "arc_jiyeon_narrow_room_2_seen",
		"father_passed", "told_jiyeon_about_records",
	]:
		GameState.flags.erase(flag)
	GameState.flags[person_id + "_romance_started"] = true
	if person_id == "daeun":
		GameState.flags["arc_daeun_hometown_1_seen"] = true
		GameState.flags["daeun_hometown_visited"] = true
	else:
		GameState.flags["arc_jiyeon_narrow_room_1_seen"] = true
		GameState.flags["jiyeon_narrow_room"] = true
	_set_cast_relation_for_qa(person_id, 50)
	GameState.cast[person_id]["stage"] = "lover"

func _assert_home_peak_uncommitted(person_id: String, label: String) -> void:
	var completion_flag := "arc_%s_%s_seen" % [
		person_id,
		"hometown_2" if person_id == "daeun" else "narrow_room_2",
	]
	var affinity := int(GameState.cast.get(person_id, {}).get("affinity", -999))
	if int(GameState.mental) != 60 or not is_equal_approx(GameState.moral_tint, 0.0) \
			or affinity != 50:
		_fail("%s home peak %s changed state before the final decision: mental=%s tint=%s affinity=%s." % [
			person_id, label, GameState.mental, GameState.moral_tint, affinity,
		])
	if GameState.flags.get(completion_flag, false):
		_fail("%s home peak %s committed its completion flag early." % [person_id, label])

func _assert_home_peak_state(
		person_id: String, label: String, mental: int, tint: float, affinity: int) -> void:
	var completion_flag := "arc_%s_%s_seen" % [
		person_id,
		"hometown_2" if person_id == "daeun" else "narrow_room_2",
	]
	var actual_affinity := int(GameState.cast.get(person_id, {}).get("affinity", -999))
	if int(GameState.mental) != mental or not is_equal_approx(GameState.moral_tint, tint) \
			or actual_affinity != affinity:
		_fail("%s home peak %s totals changed: mental=%s tint=%s affinity=%s." % [
			person_id, label, GameState.mental, GameState.moral_tint, actual_affinity,
		])
	if not GameState.flags.get(completion_flag, false):
		_fail("%s home peak %s did not commit its completion flag." % [person_id, label])
	var continuity_flag := "daeun_hometown_visited" \
		if person_id == "daeun" else "jiyeon_narrow_room"
	if not GameState.flags.get(continuity_flag, false):
		_fail("%s home peak %s lost its continuity flag." % [person_id, label])

func _shot_wedding_morning_surfaces(lang: String = "en", prefix: String = "wedding_morning_en_") -> void:
	_set_qa_language(lang)
	for route in [
		["daeun", "arc_daeun_wedding_night", "arc_daeun_wedding_night_tea",
			"arc_daeun_wedding_night_honest", "arc_daeun_wedding_night_choice"],
		["jiyeon", "arc_jiyeon_wedding_night", "arc_jiyeon_wedding_night_window",
			"arc_jiyeon_wedding_night_glass", "arc_jiyeon_wedding_night_choice"],
	]:
		var person_id := str(route[0])
		var root_id := str(route[1])
		var branch_a_id := str(route[2])
		var branch_b_id := str(route[3])
		var final_id := str(route[4])

		_prepare_wedding_morning_qa_state(person_id)
		await _shot_story_event(root_id, prefix + person_id + "_01_night_intro", "", 0.45, true)
		_assert_wedding_night_uncommitted(person_id, "night intro")
		_prepare_wedding_morning_qa_state(person_id)
		await _shot_story_event(root_id, prefix + person_id + "_02_opening_choice", "", 0.45, true, true)
		_assert_wedding_night_uncommitted(person_id, "opening choice")

		_prepare_wedding_morning_qa_state(person_id)
		await _shot_story_event(branch_a_id, prefix + person_id + "_03_branch_a", "", 0.45, true, true)
		_assert_wedding_night_uncommitted(person_id, "branch A")
		_prepare_wedding_morning_qa_state(person_id)
		await _shot_story_event(branch_b_id, prefix + person_id + "_04_branch_b", "", 0.45, true, true)
		_assert_wedding_night_uncommitted(person_id, "branch B")

		_prepare_wedding_morning_qa_state(person_id)
		await _shot_story_event(final_id, prefix + person_id + "_05_final_choice", "", 0.55, true, true)
		_assert_wedding_night_uncommitted(person_id, "final choice")
		_prepare_wedding_morning_qa_state(person_id)
		await _shot_story_event(
			final_id, prefix + person_id + "_06_night_result", "", 0.45,
			true, true, 0)
		_assert_wedding_night_state(person_id, "patient night", 68, 4.0, 58)
		_prepare_wedding_morning_qa_state(person_id)
		await _shot_story_event(
			final_id, prefix + person_id + "_07_morning_result", "", 0.45,
			true, true, 0, 0, false, 1)
		_assert_wedding_night_state(person_id, "patient morning", 68, 4.0, 58)
		_prepare_wedding_morning_qa_state(person_id)
		await _shot_story_event(
			final_id, prefix + person_id + "_08_morning_alt", "", 0.45,
			true, true, 1, 0, false, 1)
		_assert_wedding_night_state(person_id, "playful morning", 66, 3.0, 56)

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
	GameState.mental = 60
	GameState.moral_tint = 0.0
	for flag in [
		"arc_daeun_wedding_night_seen", "arc_jiyeon_wedding_night_seen",
	]:
		GameState.flags.erase(flag)
	_set_cast_relation_for_qa(person_id, 50)
	GameState.cast[person_id]["stage"] = "spouse"
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

func _assert_wedding_night_uncommitted(person_id: String, label: String) -> void:
	var completion_flag := "arc_%s_wedding_night_seen" % person_id
	var affinity := int(GameState.cast.get(person_id, {}).get("affinity", -999))
	if int(GameState.mental) != 60 or not is_equal_approx(GameState.moral_tint, 0.0) \
			or affinity != 50:
		_fail("%s wedding-night %s changed state before the final decision: mental=%s tint=%s affinity=%s." % [
			person_id, label, GameState.mental, GameState.moral_tint, affinity,
		])
	if GameState.flags.get(completion_flag, false):
		_fail("%s wedding-night %s committed its completion flag early." % [person_id, label])

func _assert_wedding_night_state(
		person_id: String, label: String, mental: int, tint: float, affinity: int) -> void:
	var completion_flag := "arc_%s_wedding_night_seen" % person_id
	var actual_affinity := int(GameState.cast.get(person_id, {}).get("affinity", -999))
	if int(GameState.mental) != mental or not is_equal_approx(GameState.moral_tint, tint) \
			or actual_affinity != affinity:
		_fail("%s wedding-night %s totals changed: mental=%s tint=%s affinity=%s." % [
			person_id, label, GameState.mental, GameState.moral_tint, actual_affinity,
		])
	if not GameState.flags.get(completion_flag, false):
		_fail("%s wedding-night %s did not commit its completion flag." % [person_id, label])

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
		GameState.flags["arc_daeun_wedding_day_seen"] = true
		GameState.flags["arc_daeun_wedding_night_seen"] = true
		GameState.flags["arc_daeun_test_seen"] = true
		GameState.flags["used_daeun_as_means"] = true
		GameState.flags["crossed_line"] = true
		GameState.flags["namsan_lock_daeun"] = true
		_set_cast_relation_for_qa("daeun", 84)
		GameState.cast["daeun"]["stage"] = "spouse"
	else:
		GameState.moral_tint = 18.0
		GameState.flags["jiyeon_romance_started"] = true
		GameState.flags["arc_jiyeon_wedding_night_seen"] = true
		GameState.flags["jiyeon_narrow_room"] = true
		GameState.flags["namsan_lock_jiyeon"] = true
		_set_cast_relation_for_qa("jiyeon", 82)
		GameState.cast["jiyeon"]["stage"] = "spouse"

func _shot_commitment_surfaces(lang: String = "en", prefix: String = "commitment_en_") -> void:
	_set_qa_language(lang)

	_prepare_commitment_qa_state("daeun")
	await _shot_story_event("arc_daeun_proposal", prefix + "01_proposal_intro", "", 0.55, true)
	_prepare_commitment_qa_state("daeun")
	await _shot_story_event("arc_daeun_proposal", prefix + "02_proposal_choices", "", 0.45, true, true)
	_prepare_commitment_qa_state("daeun")
	await _shot_story_event("arc_daeun_proposal", prefix + "03_proposal_future_reply", "", 0.45, true, true, 0)
	if GameState.flags.get("arc_daeun_proposal_seen", false) or GameState.flags.get("daeun_married", false):
		_fail("Daeun proposal buildup choice committed the final proposal route too early.")
		return
	_prepare_commitment_qa_state("daeun")
	await _shot_story_event("arc_daeun_proposal", prefix + "04_proposal_fear_reply", "", 0.45, true, true, 1)
	if GameState.flags.get("arc_daeun_proposal_seen", false) or GameState.flags.get("daeun_married", false):
		_fail("Daeun proposal honesty choice committed the final proposal route too early.")
		return
	_prepare_commitment_qa_state("daeun")
	await _shot_story_event("arc_daeun_proposal_last_cup", prefix + "05_proposal_last_cup", "", 0.55, true)
	_prepare_commitment_qa_state("daeun")
	await _shot_story_event("arc_daeun_proposal_last_cup", prefix + "06_proposal_call_back", "", 0.45, true, true, 0)
	if GameState.flags.get("arc_daeun_proposal_seen", false) or GameState.flags.get("daeun_married", false):
		_fail("Daeun proposal bridge committed the final proposal route too early.")
		return
	_prepare_commitment_qa_state("daeun")
	await _shot_story_event("arc_daeun_proposal_answer", prefix + "07_proposal_answer_intro", "", 0.55, true)
	_prepare_commitment_qa_state("daeun")
	await _shot_story_event("arc_daeun_proposal_answer", prefix + "08_proposal_answer_choices", "", 0.45, true, true)
	_prepare_commitment_qa_state("daeun")
	await _shot_story_event("arc_daeun_proposal_answer", prefix + "09_proposal_accept_reaction", "", 0.45, true, true, 0)
	if not GameState.flags.get("arc_daeun_proposal_seen", false) or not GameState.flags.get("daeun_married", false):
		_fail("Daeun proposal acceptance did not commit its canonical final flags.")
		return
	_prepare_commitment_qa_state("daeun")
	await _shot_story_event("arc_daeun_proposal_answer", prefix + "10_proposal_accept_cg", "", 0.45, true, true, 0, 0, false, 1)
	_prepare_commitment_qa_state("daeun")
	await _shot_story_event("arc_daeun_proposal_answer", prefix + "11_proposal_delay_no_cg", "", 0.45, true, true, 1, 0, false, 1)
	if not GameState.flags.get("arc_daeun_proposal_seen", false) or GameState.flags.get("daeun_married", false):
		_fail("Daeun proposal defer branch did not preserve its canonical unmarried route.")
		return

	_prepare_commitment_qa_state("daeun")
	await _shot_story_event("arc_daeun_wedding_prep", prefix + "12_wedding_small_choice", "", 0.45, true, true, 0)
	if not GameState.flags.get("daeun_wedding_small", false) or GameState.flags.get("daeun_wedding_full", false):
		_fail("Daeun small-wedding choice did not preserve an exclusive small route flag.")
		return
	await _shot_story_event("arc_daeun_wedding_day", prefix + "13_wedding_mother_reaction", "", 0.45, true)
	await _shot_story_event("arc_daeun_wedding_day", prefix + "14_wedding_mother_continue", "", 0.45, true, true)
	await _shot_story_event("arc_daeun_wedding_day", prefix + "15_wedding_mother_reply", "", 0.45, true, true, 0)
	if GameState.flags.get("arc_daeun_wedding_day_seen", false) \
			or not GameState.flags.get("daeun_wedding_small", false) \
			or GameState.flags.get("daeun_wedding_full", false):
		_fail("Daeun mother reaction changed ceremony route flags or completed the wedding early.")
		return
	await _shot_story_event("arc_daeun_wedding_groom_side", prefix + "16_wedding_father_reaction", "", 0.45, true)
	await _shot_story_event("arc_daeun_wedding_groom_side", prefix + "17_wedding_groom_side_choices", "", 0.45, true, true)
	await _shot_story_event("arc_daeun_wedding_groom_side", prefix + "18_wedding_empty_chairs_reply", "", 0.45, true, true, 0)
	if GameState.flags.get("arc_daeun_wedding_day_seen", false):
		_fail("Daeun groom-side reaction completed the wedding before the bride entrance.")
		return
	await _shot_story_event("arc_daeun_wedding_walk", prefix + "19_wedding_small_walk", "", 0.45, true)
	await _shot_story_event("arc_daeun_wedding_walk", prefix + "20_wedding_small_walk_reply", "", 0.45, true, true, 0)
	if GameState.flags.get("arc_daeun_wedding_day_seen", false):
		_fail("Daeun wedding walk bridge completed the wedding before the aisle decision.")
		return
	await _shot_story_event("arc_daeun_wedding_aisle", prefix + "21_wedding_small_final_choices", "", 0.45, true, true)
	await _shot_story_event("arc_daeun_wedding_aisle", prefix + "22_wedding_small_daeun_result", "", 0.45, true, true, 0)
	if not GameState.flags.get("arc_daeun_wedding_day_seen", false) \
			or not GameState.flags.get("daeun_wedding_small", false) \
			or GameState.flags.get("daeun_wedding_full", false):
		_fail("Daeun small-wedding final choice did not preserve its canonical completion flags.")
		return

	_prepare_commitment_qa_state("daeun")
	await _shot_story_event("arc_daeun_wedding_prep", prefix + "23_wedding_full_choice", "", 0.45, true, true, 1)
	if not GameState.flags.get("daeun_wedding_full", false) or GameState.flags.get("daeun_wedding_small", false):
		_fail("Daeun full-package choice did not preserve an exclusive full route flag.")
		return
	await _shot_story_event("arc_daeun_wedding_walk", prefix + "24_wedding_full_walk", "", 0.45, true)
	await _shot_story_event("arc_daeun_wedding_aisle", prefix + "25_wedding_full_final_choices", "", 0.45, true, true)
	await _shot_story_event("arc_daeun_wedding_aisle", prefix + "26_wedding_full_empty_seat_result", "", 0.45, true, true, 1)
	if not GameState.flags.get("arc_daeun_wedding_day_seen", false) \
			or not GameState.flags.get("daeun_wedding_full", false) \
			or GameState.flags.get("daeun_wedding_small", false):
		_fail("Daeun full-wedding final choice did not preserve its canonical completion flags.")
		return

	_prepare_commitment_qa_state("daeun")
	await _shot_story_event("arc_daeun_wedding_walk", prefix + "27_wedding_legacy_small_fallback", "", 0.45, true)

	_prepare_commitment_qa_state("daeun")
	GameState.flags["hyunsu_reconnected"] = true
	await _shot_story_event("arc_daeun_wedding_groom_side", prefix + "28_wedding_father_hyunsu", "", 0.45, true)
	_prepare_commitment_qa_state("daeun")
	GameState.flags["father_passed"] = true
	await _shot_story_event("arc_daeun_wedding_groom_side", prefix + "29_wedding_father_seat_empty", "", 0.45, true)
	_prepare_commitment_qa_state("daeun")
	GameState.flags["father_passed"] = true
	GameState.flags["hyunsu_reconnected"] = true
	await _shot_story_event("arc_daeun_wedding_groom_side", prefix + "30_wedding_empty_father_hyunsu_alone", "", 0.45, true)
	_prepare_commitment_qa_state("daeun")
	GameState.flags["father_reconciled"] = true
	GameState.flags["hyunsu_reconnected"] = true
	await _shot_story_event("arc_daeun_wedding_groom_side", prefix + "31_wedding_reconciled_father_hyunsu_copy", "", 0.45, true)

	_prepare_commitment_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_wedding_gap", prefix + "32_jiyeon_gap_intro", "", 0.55, true)
	_prepare_commitment_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_wedding_gap", prefix + "33_jiyeon_gap_first_choice", "", 0.45, true, true)
	_prepare_commitment_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_wedding_guest_list", prefix + "34_jiyeon_gap_guest_list", "", 0.55, true)
	_prepare_commitment_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_wedding_guest_list", prefix + "35_jiyeon_gap_guest_choice", "", 0.45, true, true)
	_prepare_commitment_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_wedding_gap_decision", prefix + "36_jiyeon_gap_final_choice", "", 0.45, true, true)
	_prepare_commitment_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_wedding_gap_decision", prefix + "37_jiyeon_gap_debt_result", "", 0.45, true, true, 0, 0, false, 1)
	_prepare_commitment_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_wedding_gap_decision", prefix + "38_jiyeon_gap_means_result", "", 0.45, true, true, 1, 0, false, 1)

func _shot_breakup_surfaces(lang: String = "en", prefix: String = "breakup_en_") -> void:
	_set_qa_language(lang)

	_prepare_breakup_qa_state("daeun")
	GameState.flags.erase("namsan_lock_daeun")
	await _shot_story_event("arc_daeun_final_choice", prefix + "01_daeun_intro", "", 0.55, true)
	_assert_breakup_uncommitted("daeun", "intro")
	_prepare_breakup_qa_state("daeun")
	GameState.flags.erase("namsan_lock_daeun")
	await _shot_story_event("arc_daeun_final_choice", prefix + "02_daeun_choices", "", 0.45, true, true)
	_assert_breakup_uncommitted("daeun", "opening choices")
	_prepare_breakup_qa_state("daeun")
	GameState.flags.erase("namsan_lock_daeun")
	await _shot_story_event("arc_daeun_final_choice", prefix + "03_daeun_kitchen_opening", "", 0.45, true, true, 0)
	_assert_breakup_uncommitted("daeun", "kitchen opening")
	_prepare_breakup_qa_state("daeun")
	await _shot_story_event("arc_daeun_final_choice_kitchen", prefix + "04_daeun_kitchen_reply", "", 0.45, true, true, 0)
	_assert_breakup_uncommitted("daeun", "kitchen reply")
	_prepare_breakup_qa_state("daeun")
	await _shot_story_event("arc_daeun_final_choice_name", prefix + "05_daeun_name_intro", "", 0.45, true)
	_assert_breakup_uncommitted("daeun", "name intro")
	_prepare_breakup_qa_state("daeun")
	await _shot_story_event("arc_daeun_final_choice_name", prefix + "06_daeun_name_reply", "", 0.45, true, true, 0)
	_assert_breakup_uncommitted("daeun", "name reply")
	_prepare_breakup_qa_state("daeun")
	_assert_breakup_choice_count("arc_daeun_final_choice_decision", 2, "Daeun without post-it")
	await _shot_story_event("arc_daeun_final_choice_decision", prefix + "07_daeun_final_two_choices", "", 0.45, true, true)
	_assert_breakup_uncommitted("daeun", "final choices")
	_prepare_breakup_qa_state("daeun")
	GameState.add_item("artifact_daeun_note", 1)
	_assert_breakup_choice_count("arc_daeun_final_choice_decision", 3, "Daeun with post-it")
	await _shot_story_event("arc_daeun_final_choice_decision", prefix + "08_daeun_final_artifact_choice", "", 0.45, true, true)
	_assert_breakup_uncommitted("daeun", "artifact choices")
	_prepare_breakup_qa_state("daeun")
	await _shot_story_event("arc_daeun_final_choice_decision", prefix + "09_daeun_stays_no_cg", "", 0.45, true, true, 0, 0, false, 1)
	_assert_breakup_state("daeun", "refusal", 78, -38.0, 100, "spouse", ["arc_daeun_final_choice_seen", "crossed_line"], ["daeun_divorced", "presented_artifact_correct"])
	_prepare_breakup_qa_state("daeun")
	await _shot_story_event("arc_daeun_final_choice_decision", prefix + "10_daeun_betrayal_before_cg", "", 0.45, true, true, 1, 0, false, 2)
	_assert_breakup_state("daeun", "betrayal pre-reveal", 43, -60.0, 44, "distant", ["arc_daeun_final_choice_seen", "daeun_divorced", "crossed_line"], ["presented_artifact_correct"])
	_prepare_breakup_qa_state("daeun")
	await _shot_story_event("arc_daeun_final_choice_decision", prefix + "11_daeun_seal_cg", "", 0.45, true, true, 1, 0, false, 3)
	_assert_breakup_state("daeun", "betrayal reveal", 43, -60.0, 44, "distant", ["arc_daeun_final_choice_seen", "daeun_divorced", "crossed_line"], ["presented_artifact_correct"])
	_prepare_breakup_qa_state("daeun")
	GameState.add_item("artifact_daeun_note", 1)
	await _shot_story_event("arc_daeun_final_choice_decision", prefix + "12_daeun_post_it_result", "", 0.45, true, true, 2, 0, false, 2)
	_assert_breakup_state("daeun", "post-it", 78, -38.0, 100, "spouse", ["arc_daeun_final_choice_seen", "crossed_line", "presented_artifact_correct"], ["daeun_divorced"])
	_prepare_breakup_qa_state("daeun")
	await _shot_story_event("arc_daeun_final_choice", prefix + "13_daeun_namsan_known", "", 0.5, true)
	_assert_breakup_uncommitted("daeun", "Namsan recall")

	_prepare_breakup_qa_state("jiyeon")
	GameState.flags.erase("jiyeon_narrow_room")
	GameState.flags.erase("namsan_lock_jiyeon")
	await _shot_story_event("arc_jiyeon_verdict", prefix + "14_jiyeon_intro", "", 0.55, true)
	_assert_breakup_uncommitted("jiyeon", "intro")
	_prepare_breakup_qa_state("jiyeon")
	GameState.flags.erase("jiyeon_narrow_room")
	GameState.flags.erase("namsan_lock_jiyeon")
	await _shot_story_event("arc_jiyeon_verdict", prefix + "15_jiyeon_choices", "", 0.45, true, true)
	_assert_breakup_uncommitted("jiyeon", "opening choices")
	_prepare_breakup_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_verdict", prefix + "16_jiyeon_voice_opening", "", 0.45, true, true, 0)
	_assert_breakup_uncommitted("jiyeon", "voice opening")
	_prepare_breakup_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_verdict_voice", prefix + "17_jiyeon_voice_reply", "", 0.45, true, true, 0)
	_assert_breakup_uncommitted("jiyeon", "voice reply")
	_prepare_breakup_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_verdict_fear", prefix + "18_jiyeon_fear_intro", "", 0.45, true)
	_assert_breakup_uncommitted("jiyeon", "fear intro")
	_prepare_breakup_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_verdict_fear", prefix + "19_jiyeon_fear_reply", "", 0.45, true, true, 0)
	_assert_breakup_uncommitted("jiyeon", "fear reply")
	_prepare_breakup_qa_state("jiyeon")
	_assert_breakup_choice_count("arc_jiyeon_verdict_decision", 2, "Jiyeon without first text")
	await _shot_story_event("arc_jiyeon_verdict_decision", prefix + "20_jiyeon_final_two_choices", "", 0.45, true, true)
	_assert_breakup_uncommitted("jiyeon", "final choices")
	_prepare_breakup_qa_state("jiyeon")
	GameState.add_item("artifact_jiyeon_text", 1)
	_assert_breakup_choice_count("arc_jiyeon_verdict_decision", 3, "Jiyeon with first text")
	await _shot_story_event("arc_jiyeon_verdict_decision", prefix + "21_jiyeon_final_artifact_choice", "", 0.45, true, true)
	_assert_breakup_uncommitted("jiyeon", "artifact choices")
	_prepare_breakup_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_verdict_decision", prefix + "22_jiyeon_stays_no_cg", "", 0.45, true, true, 0, 0, false, 2)
	_assert_breakup_state("jiyeon", "diminishing", 46, -20.0, 92, "spouse", ["arc_jiyeon_verdict_seen", "jiyeon_kept_by_diminishing", "crossed_line"], ["jiyeon_left", "jiyeon_stayed_as_selves", "presented_artifact_correct"])
	_prepare_breakup_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_verdict_decision", prefix + "23_jiyeon_farewell_before_cg", "", 0.45, true, true, 1, 0, false, 1)
	_assert_breakup_state("jiyeon", "release pre-reveal", 68, 26.0, 52, "distant", ["arc_jiyeon_verdict_seen", "jiyeon_left"], ["crossed_line", "jiyeon_kept_by_diminishing", "jiyeon_stayed_as_selves", "presented_artifact_correct"])
	_prepare_breakup_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_verdict_decision", prefix + "24_jiyeon_departure_cg", "", 0.45, true, true, 1, 0, false, 2)
	_assert_breakup_state("jiyeon", "release reveal", 68, 26.0, 52, "distant", ["arc_jiyeon_verdict_seen", "jiyeon_left"], ["crossed_line", "jiyeon_kept_by_diminishing", "jiyeon_stayed_as_selves", "presented_artifact_correct"])
	_prepare_breakup_qa_state("jiyeon")
	GameState.add_item("artifact_jiyeon_text", 1)
	await _shot_story_event("arc_jiyeon_verdict_decision", prefix + "25_jiyeon_first_text_result", "", 0.45, true, true, 2, 0, false, 2)
	_assert_breakup_state("jiyeon", "first text", 64, 23.0, 90, "spouse", ["arc_jiyeon_verdict_seen", "jiyeon_stayed_as_selves", "presented_artifact_correct"], ["crossed_line", "jiyeon_left", "jiyeon_kept_by_diminishing"])
	_prepare_breakup_qa_state("jiyeon")
	GameState.flags["told_jiyeon_about_records"] = true
	await _shot_story_event("arc_jiyeon_verdict", prefix + "26_jiyeon_records_known", "", 0.5, true)
	_assert_breakup_uncommitted("jiyeon", "records recall")
	_prepare_breakup_qa_state("jiyeon")
	await _shot_story_event("arc_jiyeon_verdict", prefix + "27_jiyeon_narrow_room_known", "", 0.5, true)
	_assert_breakup_uncommitted("jiyeon", "narrow-room recall")
	_prepare_breakup_qa_state("jiyeon")
	GameState.flags.erase("jiyeon_narrow_room")
	await _shot_story_event("arc_jiyeon_verdict", prefix + "28_jiyeon_namsan_known", "", 0.5, true)
	_assert_breakup_uncommitted("jiyeon", "Namsan recall")

func _assert_breakup_choice_count(event_id: String, expected: int, label: String) -> void:
	var story = StoryModeScript.new()
	var event: Dictionary = DataRegistry.find_event(event_id)
	var actual: int = story._visible_choice_indices(event).size()
	if actual != expected:
		_fail("%s expected %d visible choices, got %d." % [label, expected, actual])
	story.free()

func _assert_breakup_uncommitted(route: String, label: String) -> void:
	var expected_tint := -48.0 if route == "daeun" else 18.0
	var expected_affinity := 84 if route == "daeun" else 82
	var actual_affinity := int(GameState.cast.get(route, {}).get("affinity", -999))
	if int(GameState.mental) != 58 or not is_equal_approx(GameState.moral_tint, expected_tint) \
			or actual_affinity != expected_affinity:
		_fail("%s breakup %s changed state before the final decision: mental=%s tint=%s affinity=%s." % [
			route, label, GameState.mental, GameState.moral_tint, actual_affinity,
		])
	var completion_flag := "arc_daeun_final_choice_seen" if route == "daeun" else "arc_jiyeon_verdict_seen"
	if GameState.flags.get(completion_flag, false) or GameState.flags.get("daeun_divorced", false) \
			or GameState.flags.get("jiyeon_left", false) or GameState.flags.get("presented_artifact_correct", false):
		_fail("%s breakup %s committed a terminal flag early." % [route, label])

func _assert_breakup_state(
		route: String, label: String, mental: int, tint: float, affinity: int,
		stage: String, required_flags: Array, forbidden_flags: Array) -> void:
	var cast_state: Dictionary = GameState.cast.get(route, {})
	var actual_affinity := int(cast_state.get("affinity", -999))
	var actual_stage := str(cast_state.get("stage", ""))
	if int(GameState.mental) != mental or not is_equal_approx(GameState.moral_tint, tint) \
			or actual_affinity != affinity or actual_stage != stage:
		_fail("%s breakup %s totals changed: mental=%s tint=%s affinity=%s stage=%s." % [
			route, label, GameState.mental, GameState.moral_tint, actual_affinity, actual_stage,
		])
	for flag_id in required_flags:
		if not GameState.flags.get(str(flag_id), false):
			_fail("%s breakup %s did not set %s." % [route, label, str(flag_id)])
	for flag_id in forbidden_flags:
		if GameState.flags.get(str(flag_id), false):
			_fail("%s breakup %s incorrectly set %s." % [route, label, str(flag_id)])

func _assert_sangchul_first_meeting_visual_state(story: Node, event_id: String) -> void:
	var expected_portraits := {
		"arc_sangchul_01_meet": "sangchul_normal",
		"arc_sangchul_01_measure": "sangchul_serious",
		"arc_sangchul_01_coffee": "sangchul_normal",
		"arc_sangchul_01_answer": "sangchul_serious",
	}
	if not expected_portraits.has(event_id):
		return
	if str(story.get("_event_background_id")) != "realestate_office":
		_fail("Sangchul first meeting left the real-estate office at %s." % event_id)
		return
	if bool(story.get("_current_uses_cg")):
		_fail("Sangchul first meeting unexpectedly replaced the reusable room with a CG at %s." % event_id)
		return
	var portrait := story.get("_portrait") as TextureRect
	var actual_path := portrait.texture.resource_path \
			if is_instance_valid(portrait) and portrait.texture != null else ""
	var expected_path := ImageRegistry.get_portrait(str(expected_portraits[event_id]))
	if actual_path != expected_path:
		_fail("Sangchul first-meeting portrait expected %s, got %s at %s." % [
			expected_path, actual_path, event_id])
	if _qa_scope() == QA_SCOPE_SANGCHUL_FIRST_MEET:
		if BGMPlayer._music_mode != "ambient" or not BGMPlayer._current_key.is_empty() \
				or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
			_fail("Sangchul first meeting telegraphed directive music at %s." % event_id)

func _shot_sangchul_first_meeting_surfaces(
		lang: String = "en", prefix: String = "sangchul_meet_en_") -> void:
	_set_qa_language(lang)

	_prepare_sangchul_first_meeting_qa_state()
	await _shot_story_event("arc_sangchul_01_meet", prefix + "01_office_intro", "", 0.55, true)
	_prepare_sangchul_first_meeting_qa_state()
	await _shot_story_event("arc_sangchul_01_meet", prefix + "02_opening_choices", "", 0.45, true, true)
	_prepare_sangchul_first_meeting_qa_state()
	await _shot_story_event(
			"arc_sangchul_01_meet", prefix + "03_measure_opening_result", "", 0.45,
			true, true, 0, 0, false, 2)
	_assert_sangchul_first_meeting_uncommitted("measure opening")

	_prepare_sangchul_first_meeting_qa_state()
	await _shot_story_event("arc_sangchul_01_measure", prefix + "04_measure_branch", "", 0.55, true, true)
	_prepare_sangchul_first_meeting_qa_state()
	await _shot_story_event(
			"arc_sangchul_01_measure", prefix + "05_measure_rejoin_result", "", 0.45,
			true, true, 0, 0, false, 2)
	_assert_sangchul_first_meeting_uncommitted("measure rejoin")

	_prepare_sangchul_first_meeting_qa_state()
	await _shot_story_event(
			"arc_sangchul_01_meet", prefix + "06_coffee_opening_result", "", 0.45,
			true, true, 1, 0, false, 1)
	_assert_sangchul_first_meeting_uncommitted("coffee opening")
	_prepare_sangchul_first_meeting_qa_state()
	await _shot_story_event("arc_sangchul_01_coffee", prefix + "07_coffee_branch", "", 0.55, true, true)
	_assert_sangchul_first_meeting_uncommitted("coffee branch")

	_prepare_sangchul_first_meeting_qa_state()
	await _shot_story_event("arc_sangchul_01_answer", prefix + "08_final_question", "", 0.55, true)
	_prepare_sangchul_first_meeting_qa_state()
	await _shot_story_event("arc_sangchul_01_answer", prefix + "09_final_choices", "", 0.45, true, true)
	for outcome in [
		[0, "10_father_result", 66, 43, 5.0, 15, "interested", true, false],
		[1, "11_money_result", 58, 44, 0.0, 6, "watching", false, false],
		[2, "12_pride_result", 67, 42, 3.0, 12, "interested", false, true],
	]:
		_prepare_sangchul_first_meeting_qa_state()
		await _shot_story_event(
				"arc_sangchul_01_answer", prefix + str(outcome[1]), "", 0.45,
				true, true, int(outcome[0]), 0, false, 4)
		_assert_sangchul_first_meeting_state(
				str(outcome[1]), int(outcome[2]), int(outcome[3]), float(outcome[4]),
				int(outcome[5]), str(outcome[6]), bool(outcome[7]), bool(outcome[8]))
	await _verify_sangchul_first_meeting_controller()

func _verify_sangchul_first_meeting_controller() -> void:
	_prepare_sangchul_first_meeting_qa_state()
	GameState.pending_story_queue = ["arc_sangchul_01_meet"]
	var packed := load("res://scenes/StoryMode.tscn") as PackedScene
	var story := packed.instantiate()
	get_tree().root.add_child.call_deferred(story)
	await get_tree().process_frame
	if story.has_method("_set_auto_mode"):
		story._set_auto_mode(false, false)
	await _settle(0.35)
	for _step in range(30):
		if bool(story.get("_showing_choices")):
			break
		await _press_qa_action("ui_accept")
		await _settle(0.10)
	if not bool(story.get("_showing_choices")):
		_fail("Sangchul first meeting could not reach its opening choices by controller input.")
	else:
		var choice_box := story.get("_choice_box") as Control
		var focus := get_viewport().gui_get_focus_owner() as Button
		if not is_instance_valid(focus) or not is_instance_valid(choice_box) \
				or not choice_box.is_ancestor_of(focus):
			_fail("Sangchul first meeting did not focus a controller-selectable opening choice.")
		else:
			await _press_qa_action("ui_accept")
			await _settle(0.25)
			if bool(story.get("_showing_choices")):
				_fail("Sangchul first-meeting controller accept did not select the focused choice.")
			_assert_sangchul_first_meeting_uncommitted("controller opening")
	_remove_nodes_by_script("res://scenes/StoryMode.gd")
	GameState.pending_story_queue.clear()
	await _settle(0.25)

func _prepare_sangchul_first_meeting_qa_state() -> void:
	_prepare_main_game_state()
	GameState.turn = 10
	GameState.month = 3
	GameState.mental = 60
	GameState.intelligence = 40
	GameState.moral_tint = 0.0
	for flag in ["arc_sangchul_met_seen", "pride_motive"]:
		GameState.flags.erase(flag)
	if GameState.has_item("artifact_sangchul_card"):
		GameState.remove_item("artifact_sangchul_card", 99)
	_set_cast_relation_for_qa("sangchul", 0, false)
	GameState.cast["sangchul"]["stage"] = "unknown"
	GameState.cast["sangchul"]["flags"] = {}

func _assert_sangchul_first_meeting_uncommitted(label: String) -> void:
	var sangchul: Dictionary = GameState.cast.get("sangchul", {})
	if int(GameState.mental) != 60 or int(GameState.intelligence) != 40 \
			or not is_equal_approx(GameState.moral_tint, 0.0):
		_fail("Sangchul first meeting %s changed stats before the final why." % label)
	if GameState.flags.get("arc_sangchul_met_seen", false) \
			or GameState.flags.get("pride_motive", false) \
			or GameState.has_item("artifact_sangchul_card"):
		_fail("Sangchul first meeting %s committed a terminal flag or card early." % label)
	if bool(sangchul.get("met", true)) or int(sangchul.get("affinity", -999)) != 0 \
			or str(sangchul.get("stage", "")) != "unknown" \
			or not (sangchul.get("flags", {}) as Dictionary).is_empty():
		_fail("Sangchul first meeting %s changed the relationship before the final why." % label)

func _assert_sangchul_first_meeting_state(
		label: String, mental: int, intelligence: int, tint: float, affinity: int,
		stage: String, knows_dad: bool, pride: bool) -> void:
	var sangchul: Dictionary = GameState.cast.get("sangchul", {})
	var cast_flags: Dictionary = sangchul.get("flags", {}) as Dictionary
	if int(GameState.mental) != mental or int(GameState.intelligence) != intelligence \
			or not is_equal_approx(GameState.moral_tint, tint):
		_fail("Sangchul first meeting %s totals changed: mental=%s intelligence=%s tint=%s." % [
			label, GameState.mental, GameState.intelligence, GameState.moral_tint])
	if not GameState.flags.get("arc_sangchul_met_seen", false) \
			or bool(GameState.flags.get("pride_motive", false)) != pride \
			or not GameState.has_item("artifact_sangchul_card"):
		_fail("Sangchul first meeting %s lost its completion, pride, or card contract." % label)
	if not bool(sangchul.get("met", false)) or int(sangchul.get("affinity", -999)) != affinity \
			or str(sangchul.get("stage", "")) != stage \
			or bool(cast_flags.get("knows_dad_reason", false)) != knows_dad:
		_fail("Sangchul first meeting %s changed cast state: affinity=%s stage=%s flags=%s." % [
			label, sangchul.get("affinity"), sangchul.get("stage"), cast_flags])

func _assert_sangchul_deduction_visual_state(story: Node, event_id: String) -> void:
	var expected_portraits := {
		"hidden_whole_picture": "player_normal",
		"arc_sangchul_deduction": "player_tired",
		"arc_sangchul_deduction_case": "player_tired",
		"arc_sangchul_deduction_career": "player_tired",
		"arc_sangchul_deduction_decision": "player_shocked",
	}
	if not expected_portraits.has(event_id):
		return
	var expected_background := ImageRegistry.infer_background_id({}, GameState.housing)
	var actual_background := str(story.get("_event_background_id"))
	if actual_background != expected_background:
		_fail("%s housing expected %s, got %s." % [
			event_id, expected_background, actual_background])
	if bool(story.get("_current_uses_cg")):
		_fail("Sangchul deduction unexpectedly used a baked CG at %s." % event_id)
	var portrait := story.get("_portrait") as TextureRect
	var actual_path := portrait.texture.resource_path \
			if is_instance_valid(portrait) and portrait.texture != null else ""
	var expected_path := ImageRegistry.get_portrait(str(expected_portraits[event_id]))
	if actual_path != expected_path:
		_fail("%s portrait expected %s, got %s." % [event_id, expected_path, actual_path])
	if _qa_scope() != QA_SCOPE_SANGCHUL_DEDUCTION:
		return
	var expected_ambience := "room"
	match str(GameState.housing):
		"gangnam", "apartment":
			expected_ambience = "apartment"
		"villa", "oneroom":
			expected_ambience = "oneroom"
	if str(BGMPlayer._current_ambience_key) != expected_ambience:
		_fail("%s expected %s ambience, got %s." % [
			event_id, expected_ambience, BGMPlayer._current_ambience_key])
	var scored := event_id in ["hidden_whole_picture", "arc_sangchul_deduction_decision"]
	if scored:
		if BGMPlayer._current_key != "reckoning" \
				or not (BGMPlayer._player_a.playing or BGMPlayer._player_b.playing):
			_fail("%s did not start the authored reckoning punctuation." % event_id)
	elif BGMPlayer._player_a.playing or BGMPlayer._player_b.playing \
			or not BGMPlayer._current_key.is_empty():
		_fail("%s exposed reckoning before the evidence converged." % event_id)
	if event_id == "arc_sangchul_deduction_decision" \
			and bool(story.get("_showing_choices")):
		var timer_row := story.find_child("StoryChoiceCountdown", true, false)
		if timer_row == null or not timer_row.visible:
			_fail("Sangchul deduction final choice did not expose its 15-second countdown.")

func _shot_sangchul_deduction_surfaces(
		lang: String = "en", prefix: String = "sangchul_deduction_en_") -> void:
	_set_qa_language(lang)

	_prepare_sangchul_deduction_qa_state("gosiwon")
	await _shot_story_event(
			"arc_sangchul_deduction", prefix + "01_gosiwon_search", "", 0.55, true)
	_prepare_sangchul_deduction_qa_state("oneroom")
	await _shot_story_event(
			"arc_sangchul_deduction", prefix + "02_oneroom_opening_choices", "",
			0.45, true, true)
	_assert_sangchul_deduction_uncommitted("opening choices")
	_prepare_sangchul_deduction_qa_state("oneroom")
	await _shot_story_event(
			"arc_sangchul_deduction", prefix + "03_case_opening_result", "",
			0.45, true, true, 0, 0, false, 2)
	_assert_sangchul_deduction_uncommitted("case opening")
	_prepare_sangchul_deduction_qa_state("oneroom")
	await _shot_story_event(
			"arc_sangchul_deduction_case", prefix + "04_case_branch", "",
			0.45, true, true)
	_assert_sangchul_deduction_uncommitted("case branch")
	_prepare_sangchul_deduction_qa_state("oneroom")
	await _shot_story_event(
			"arc_sangchul_deduction_case", prefix + "05_case_rejoin_result", "",
			0.45, true, true, 0, 0, false, 2)
	_assert_sangchul_deduction_uncommitted("case rejoin")

	_prepare_sangchul_deduction_qa_state("oneroom")
	await _shot_story_event(
			"arc_sangchul_deduction", prefix + "06_career_opening_result", "",
			0.45, true, true, 1, 0, false, 2)
	_assert_sangchul_deduction_uncommitted("career opening")
	_prepare_sangchul_deduction_qa_state("oneroom")
	await _shot_story_event(
			"arc_sangchul_deduction_career", prefix + "07_career_branch", "",
			0.45, true, true)
	_assert_sangchul_deduction_uncommitted("career branch")

	_prepare_sangchul_deduction_qa_state("oneroom")
	await _shot_story_event(
			"arc_sangchul_deduction_decision", prefix + "08_joined_evidence", "",
			0.55, true)
	_prepare_sangchul_deduction_qa_state("oneroom")
	await _shot_story_event(
			"arc_sangchul_deduction_decision", prefix + "09_timed_choices", "",
			0.45, true, true)
	_assert_sangchul_deduction_uncommitted("timed choices")
	_prepare_sangchul_deduction_qa_state("oneroom")
	await _shot_story_event(
			"arc_sangchul_deduction_decision", prefix + "10_confirm_result", "",
			0.45, true, true, 0, 0, false, 3)
	_assert_sangchul_deduction_state("confirm", true)
	_prepare_sangchul_deduction_qa_state("oneroom")
	await _shot_story_event(
			"arc_sangchul_deduction_decision", prefix + "11_defer_result", "",
			0.45, true, true, 1, 0, false, 2)
	_assert_sangchul_deduction_state("defer", false)
	_prepare_sangchul_deduction_qa_state("apartment")
	GameState.flags["arc_sangchul_deduction_seen"] = true
	GameState.flags["sangchul_truth_known"] = true
	await _shot_story_event(
			"hidden_whole_picture", prefix + "12_apartment_whole_picture", "",
			0.55, true, true)

	await _verify_sangchul_deduction_controller(0, 0, "gosiwon")
	await _verify_sangchul_deduction_controller(1, 1, "oneroom")

func _prepare_sangchul_deduction_qa_state(housing_id: String) -> void:
	_prepare_main_game_state()
	GameState.turn = 30
	GameState.month = 8
	GameState.week_of_month = 2
	GameState.housing = housing_id
	GameState.mental = 60
	GameState.intelligence = 55
	GameState.investment_skill = 20
	GameState.moral_tint = 0.0
	for flag in [
		"arc_sangchul_deduction_seen", "sangchul_truth_known",
		"deduced_sangchul_truth", "sangchul_clue_noted",
	]:
		GameState.flags.erase(flag)
	GameState.flags["arc_sangchul_03_seen"] = true
	GameState.clues.erase("clue_father_broker")

func _assert_sangchul_deduction_uncommitted(label: String) -> void:
	if int(GameState.mental) != 60 or int(GameState.intelligence) != 55 \
			or int(GameState.investment_skill) != 20 \
			or not is_equal_approx(GameState.moral_tint, 0.0):
		_fail("Sangchul deduction %s changed stats before the final decision." % label)
	for flag in [
		"arc_sangchul_deduction_seen", "sangchul_truth_known",
		"deduced_sangchul_truth", "sangchul_clue_noted",
	]:
		if GameState.flags.get(flag, false):
			_fail("Sangchul deduction %s committed %s early." % [label, flag])
	if GameState.has_clue("clue_father_broker"):
		_fail("Sangchul deduction %s granted the broker clue early." % label)

func _assert_sangchul_deduction_state(label: String, confirmed: bool) -> void:
	var expected_mental := 48 if confirmed else 56
	var expected_intelligence := 57 if confirmed else 55
	var expected_skill := 21 if confirmed else 20
	var expected_tint := 3.0 if confirmed else 2.0
	if int(GameState.mental) != expected_mental \
			or int(GameState.intelligence) != expected_intelligence \
			or int(GameState.investment_skill) != expected_skill \
			or not is_equal_approx(GameState.moral_tint, expected_tint):
		_fail("Sangchul deduction %s totals changed: mental=%s intelligence=%s skill=%s tint=%s." % [
			label, GameState.mental, GameState.intelligence,
			GameState.investment_skill, GameState.moral_tint])
	if not GameState.flags.get("arc_sangchul_deduction_seen", false) \
			or not GameState.has_clue("clue_father_broker"):
		_fail("Sangchul deduction %s lost its completion flag or broker clue." % label)
	if bool(GameState.flags.get("sangchul_truth_known", false)) != confirmed \
			or bool(GameState.flags.get("deduced_sangchul_truth", false)) != confirmed \
			or bool(GameState.flags.get("sangchul_clue_noted", false)) == confirmed:
		_fail("Sangchul deduction %s changed its truth/defer flags." % label)

func _verify_sangchul_deduction_controller(
		root_choice: int, final_choice: int, housing_id: String) -> void:
	_prepare_sangchul_deduction_qa_state(housing_id)
	GameState.pending_story_queue = ["arc_sangchul_deduction"]
	var packed := load("res://scenes/StoryMode.tscn") as PackedScene
	var story := packed.instantiate()
	get_tree().root.add_child.call_deferred(story)
	await get_tree().process_frame
	if story.has_method("_set_auto_mode"):
		story._set_auto_mode(false, false)
	await _settle(0.30)
	if not await _drive_story_to_event_choices(story, "arc_sangchul_deduction"):
		return
	if root_choice == 1:
		await _press_qa_action("ui_down")
		await _settle(0.08)
	await _press_qa_action("ui_accept")
	await _settle(0.18)
	_assert_sangchul_deduction_uncommitted("controller opening %d" % root_choice)
	var branch_id := "arc_sangchul_deduction_case" \
			if root_choice == 0 else "arc_sangchul_deduction_career"
	if not await _drive_story_to_event_choices(story, branch_id):
		return
	await _press_qa_action("ui_accept")
	await _settle(0.18)
	_assert_sangchul_deduction_uncommitted("controller branch %d" % root_choice)
	if not await _drive_story_to_event_choices(story, "arc_sangchul_deduction_decision"):
		return
	var timer_row := story.find_child("StoryChoiceCountdown", true, false)
	var choice_box := story.get("_choice_box") as Control
	var focus := get_viewport().gui_get_focus_owner() as Button
	if timer_row == null or not timer_row.visible \
			or not is_instance_valid(focus) or not is_instance_valid(choice_box) \
			or not choice_box.is_ancestor_of(focus):
		_fail("Sangchul deduction controller route lost its timer or focused final choice.")
		return
	if final_choice == 1:
		await _press_qa_action("ui_down")
		await _settle(0.08)
	await _press_qa_action("ui_accept")
	await _settle(0.18)
	_assert_sangchul_deduction_state(
			"controller %d/%d" % [root_choice, final_choice], final_choice == 0)
	_remove_nodes_by_script("res://scenes/StoryMode.gd")
	GameState.pending_story_queue.clear()
	await _settle(0.20)

func _drive_story_to_event_choices(story: Node, event_id: String) -> bool:
	for _step in range(140):
		var current: Dictionary = story.get("_current")
		if str(current.get("id", "")) == event_id and bool(story.get("_showing_choices")):
			return true
		await _press_qa_action("ui_accept")
		await _settle(0.07)
	var current: Dictionary = story.get("_current")
	_fail("Controller route could not reach %s choices; stopped at %s." % [
		event_id, str(current.get("id", ""))])
	return false

func _assert_sangchul_casino_visual_state(story: Node, event_id: String) -> void:
	var expected_portraits := {
		"arc_sangchul_casino_invite": "sangchul_serious",
		"arc_sangchul_casino_people": "sangchul_serious",
		"arc_sangchul_casino_cost": "player_tired",
		"arc_sangchul_casino_decision": "player_tired",
		"arc_sangchul_casino_arrival": "sangchul_normal",
	}
	if not expected_portraits.has(event_id):
		return
	var expected_background := "jeongseon_casino_exterior" \
			if event_id == "arc_sangchul_casino_arrival" \
			else ImageRegistry.infer_background_id({}, GameState.housing)
	var actual_background := str(story.get("_event_background_id"))
	if actual_background != expected_background:
		_fail("%s background expected %s, got %s." % [
			event_id, expected_background, actual_background])
	if bool(story.get("_current_uses_cg")):
		_fail("Sangchul casino invitation unexpectedly used a baked CG at %s." % event_id)
	var portrait := story.get("_portrait") as TextureRect
	var actual_path := portrait.texture.resource_path \
			if is_instance_valid(portrait) and portrait.texture != null else ""
	var expected_path := ImageRegistry.get_portrait(str(expected_portraits[event_id]))
	if actual_path != expected_path:
		_fail("%s portrait expected %s, got %s." % [event_id, expected_path, actual_path])

	var presentation: Dictionary = story.get("_current_presentation")
	var badge := story.get("_communication_badge") as Control
	var badge_label := story.get("_communication_label") as Label
	if event_id in ["arc_sangchul_casino_invite", "arc_sangchul_casino_people"]:
		if str(presentation.get("channel", "")) != "message" \
				or str(presentation.get("scene_location", "")) != "current_housing" \
				or str(presentation.get("remote_actor", "")) != "sangchul" \
				or str(presentation.get("portrait_role", "")) != "remote" \
				or not bool(story.get("_portrait_remote_inset")):
			_fail("%s does not read as Sangchul's remote text message." % event_id)
		var expected_badge := "MESSAGE" if LocaleManager.is_english() else "메시지"
		if not is_instance_valid(badge) or not badge.visible \
				or not is_instance_valid(badge_label) or badge_label.text != expected_badge:
			_fail("%s is missing its localized message badge." % event_id)
	elif event_id in ["arc_sangchul_casino_cost", "arc_sangchul_casino_decision"]:
		if str(presentation.get("channel", "")) != "internal" \
				or str(presentation.get("scene_location", "")) != "current_housing" \
				or str(presentation.get("portrait_role", "")) != "local" \
				or bool(story.get("_portrait_remote_inset")):
			_fail("%s does not read as Minjun's local internal calculation." % event_id)
		if is_instance_valid(badge) and badge.visible:
			_fail("%s incorrectly retained a communication badge." % event_id)
	else:
		if str(presentation.get("channel", "")) != "in_person" \
				or str(presentation.get("scene_location", "")) != "jeongseon_casino_exterior" \
				or str(presentation.get("portrait_role", "")) != "present" \
				or bool(story.get("_portrait_remote_inset")):
			_fail("Sangchul casino arrival does not read as physical co-presence.")
		if is_instance_valid(badge) and badge.visible:
			_fail("Sangchul casino arrival retained the earlier message badge.")

	if _qa_scope() != QA_SCOPE_SANGCHUL_CASINO:
		return
	var expected_ambience := "street"
	if event_id != "arc_sangchul_casino_arrival":
		expected_ambience = "room"
		match str(GameState.housing):
			"gangnam", "apartment":
				expected_ambience = "apartment"
			"villa", "oneroom":
				expected_ambience = "oneroom"
	if str(BGMPlayer._current_ambience_key) != expected_ambience:
		_fail("%s expected %s ambience, got %s." % [
			event_id, expected_ambience, BGMPlayer._current_ambience_key])
	if BGMPlayer._music_mode != "ambient" or not BGMPlayer._current_key.is_empty() \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail("%s started directive music during the casino invitation." % event_id)

func _shot_sangchul_casino_surfaces(
		lang: String = "en", prefix: String = "sangchul_casino_en_") -> void:
	_set_qa_language(lang)

	_prepare_sangchul_casino_qa_state("gosiwon")
	await _shot_story_event(
			"arc_sangchul_casino_invite", prefix + "01_gosiwon_message", "", 0.55, true)
	_prepare_sangchul_casino_qa_state("oneroom")
	await _shot_story_event(
			"arc_sangchul_casino_invite", prefix + "02_oneroom_opening_choices", "",
			0.45, true, true)
	_assert_sangchul_casino_uncommitted("opening choices")
	_prepare_sangchul_casino_qa_state("apartment")
	GameState.flags["sangchul_truth_known"] = true
	await _shot_story_event(
			"arc_sangchul_casino_invite", prefix + "02b_known_apartment_message", "",
			0.55, true, false, -1, 4)
	_assert_sangchul_casino_uncommitted("known-truth message")

	_prepare_sangchul_casino_qa_state("oneroom")
	await _shot_story_event(
			"arc_sangchul_casino_invite", prefix + "03_people_opening_result", "",
			0.45, true, true, 0, 0, false, 2)
	_assert_sangchul_casino_uncommitted("people opening")
	_prepare_sangchul_casino_qa_state("oneroom")
	await _shot_story_event(
			"arc_sangchul_casino_people", prefix + "04_people_branch", "",
			0.45, true, true)
	_assert_sangchul_casino_uncommitted("people branch")
	_prepare_sangchul_casino_qa_state("oneroom")
	await _shot_story_event(
			"arc_sangchul_casino_people", prefix + "05_people_rejoin_result", "",
			0.45, true, true, 0, 0, false, 2)
	_assert_sangchul_casino_uncommitted("people rejoin")

	_prepare_sangchul_casino_qa_state("oneroom")
	await _shot_story_event(
			"arc_sangchul_casino_invite", prefix + "06_cost_opening_result", "",
			0.45, true, true, 1, 0, false, 2)
	_assert_sangchul_casino_uncommitted("cost opening")
	_prepare_sangchul_casino_qa_state("oneroom")
	await _shot_story_event(
			"arc_sangchul_casino_cost", prefix + "07_cost_branch", "",
			0.45, true, true)
	_assert_sangchul_casino_uncommitted("cost branch")

	_prepare_sangchul_casino_qa_state("oneroom")
	await _shot_story_event(
			"arc_sangchul_casino_decision", prefix + "08_reply_intro", "", 0.55, true)
	_prepare_sangchul_casino_qa_state("oneroom")
	await _shot_story_event(
			"arc_sangchul_casino_decision", prefix + "09_reply_choices", "",
			0.45, true, true)
	_assert_sangchul_casino_uncommitted("reply choices")
	_prepare_sangchul_casino_qa_state("oneroom")
	await _shot_story_event(
			"arc_sangchul_casino_decision", prefix + "10_accept_ticket_result", "",
			0.45, true, true, 0, 0, false, 3)
	_assert_sangchul_casino_state("accept", true)

	_prepare_sangchul_casino_accepted_qa_state("oneroom")
	await _shot_story_event(
			"arc_sangchul_casino_arrival", prefix + "11_exterior_arrival_cue", "", 0.55, true)
	_assert_sangchul_casino_state("arrival", true)
	_prepare_sangchul_casino_accepted_qa_state("oneroom")
	await _shot_story_event(
			"arc_sangchul_casino_arrival", prefix + "12_exterior_baccarat_rule", "",
			0.55, true, false, -1, 1)
	_assert_sangchul_casino_state("arrival strategy", true)

	_prepare_sangchul_casino_qa_state("oneroom")
	await _shot_story_event(
			"arc_sangchul_casino_decision", prefix + "13_decline_result", "",
			0.45, true, true, 1, 0, false, 1)
	_assert_sangchul_casino_state("decline", false)

	await _verify_sangchul_casino_controller(0, 0, "gosiwon")
	await _verify_sangchul_casino_controller(1, 1, "oneroom")

func _prepare_sangchul_casino_qa_state(housing_id: String) -> void:
	_prepare_main_game_state()
	GameState.turn = 23
	GameState.month = 6
	GameState.week_of_month = 3
	GameState.housing = housing_id
	GameState.money = 3_500_000.0
	GameState.mental = 60
	GameState.social_skill = 20
	GameState.moral_tint = 0.0
	GameState.flags["arc_sangchul_02_seen"] = true
	GameState.flags.erase("arc_sangchul_casino_seen")
	GameState.flags.erase("casino_club_introduced")
	_set_cast_relation_for_qa("sangchul", 30, true)
	GameState.cast["sangchul"]["stage"] = "mentoring"
	GameState.cast["sangchul"]["flags"] = {}

func _prepare_sangchul_casino_accepted_qa_state(housing_id: String) -> void:
	_prepare_sangchul_casino_qa_state(housing_id)
	GameState.social_skill = 21
	GameState.mental = 58
	GameState.flags["arc_sangchul_casino_seen"] = true
	GameState.flags["casino_club_introduced"] = true
	GameState.cast["sangchul"]["affinity"] = 38

func _assert_sangchul_casino_uncommitted(label: String) -> void:
	var sangchul: Dictionary = GameState.cast.get("sangchul", {})
	if not is_equal_approx(GameState.money, 3_500_000.0) \
			or int(GameState.mental) != 60 or int(GameState.social_skill) != 20 \
			or not is_equal_approx(GameState.moral_tint, 0.0):
		_fail("Sangchul casino %s changed stats before the final reply." % label)
	if GameState.flags.get("arc_sangchul_casino_seen", false) \
			or GameState.flags.get("casino_club_introduced", false):
		_fail("Sangchul casino %s committed a terminal flag early." % label)
	if int(sangchul.get("affinity", -999)) != 30 \
			or str(sangchul.get("stage", "")) != "mentoring":
		_fail("Sangchul casino %s changed the relationship before the final reply." % label)

func _assert_sangchul_casino_state(label: String, accepted: bool) -> void:
	var expected_mental := 58 if accepted else 61
	var expected_social := 21 if accepted else 20
	var expected_affinity := 38 if accepted else 30
	var sangchul: Dictionary = GameState.cast.get("sangchul", {})
	if not is_equal_approx(GameState.money, 3_500_000.0) \
			or int(GameState.mental) != expected_mental \
			or int(GameState.social_skill) != expected_social \
			or int(sangchul.get("affinity", -999)) != expected_affinity \
			or str(sangchul.get("stage", "")) != "mentoring":
		_fail("Sangchul casino %s changed its terminal totals: money=%s mental=%s social=%s affinity=%s stage=%s." % [
			label, GameState.money, GameState.mental, GameState.social_skill,
			sangchul.get("affinity"), sangchul.get("stage")])
	if not GameState.flags.get("arc_sangchul_casino_seen", false) \
			or bool(GameState.flags.get("casino_club_introduced", false)) != accepted:
		_fail("Sangchul casino %s changed its completion or introduction flags." % label)

func _sangchul_casino_choices_focused(story: Node, label: String) -> bool:
	var choice_box := story.get("_choice_box") as Control
	var focus := get_viewport().gui_get_focus_owner() as Button
	if not is_instance_valid(focus) or not is_instance_valid(choice_box) \
			or not choice_box.is_ancestor_of(focus):
		_fail("Sangchul casino %s did not focus a controller-selectable choice." % label)
		return false
	return true

func _verify_sangchul_casino_controller(
		root_choice: int, final_choice: int, housing_id: String) -> void:
	_prepare_sangchul_casino_qa_state(housing_id)
	GameState.pending_story_queue = ["arc_sangchul_casino_invite"]
	var packed := load("res://scenes/StoryMode.tscn") as PackedScene
	var story := packed.instantiate()
	get_tree().root.add_child.call_deferred(story)
	await get_tree().process_frame
	if story.has_method("_set_auto_mode"):
		story._set_auto_mode(false, false)
	await _settle(0.30)
	if not await _drive_story_to_event_choices(story, "arc_sangchul_casino_invite") \
			or not _sangchul_casino_choices_focused(story, "opening"):
		return
	if root_choice == 1:
		await _press_qa_action("ui_down")
		await _settle(0.08)
	await _press_qa_action("ui_accept")
	await _settle(0.18)
	_assert_sangchul_casino_uncommitted("controller opening %d" % root_choice)
	var branch_id := "arc_sangchul_casino_people" \
			if root_choice == 0 else "arc_sangchul_casino_cost"
	if not await _drive_story_to_event_choices(story, branch_id) \
			or not _sangchul_casino_choices_focused(story, "branch"):
		return
	await _press_qa_action("ui_accept")
	await _settle(0.18)
	_assert_sangchul_casino_uncommitted("controller branch %d" % root_choice)
	if not await _drive_story_to_event_choices(story, "arc_sangchul_casino_decision") \
			or not _sangchul_casino_choices_focused(story, "final reply"):
		return
	if final_choice == 1:
		await _press_qa_action("ui_down")
		await _settle(0.08)
	await _press_qa_action("ui_accept")
	await _settle(0.18)
	_assert_sangchul_casino_state(
			"controller %d/%d" % [root_choice, final_choice], final_choice == 0)
	if final_choice == 0:
		if not await _drive_story_to_event_choices(story, "arc_sangchul_casino_arrival") \
				or not _sangchul_casino_choices_focused(story, "arrival threshold"):
			return
		_assert_sangchul_casino_visual_state(story, "arc_sangchul_casino_arrival")
		await _press_qa_action("ui_accept")
		await _settle(0.18)
		_assert_sangchul_casino_state("controller arrival", true)
	_remove_nodes_by_script("res://scenes/StoryMode.gd")
	GameState.pending_story_queue.clear()
	await _settle(0.20)

func _shot_hyunsu_reunion_surfaces(
		lang: String = "en", prefix: String = "hyunsu_reunion_en_") -> void:
	_set_qa_language(lang)

	_prepare_hyunsu_reunion_qa_state("gosiwon", false)
	await _shot_story_event(
			"hyunsu_reunion_later", prefix + "01_gosiwon_message", "", 0.55, true)
	_prepare_hyunsu_reunion_qa_state("oneroom", false)
	await _shot_story_event(
			"hyunsu_reunion_later", prefix + "02_oneroom_opening_choices", "",
			0.45, true, true)
	_assert_hyunsu_reunion_uncommitted("opening choices")

	_prepare_hyunsu_reunion_qa_state("oneroom", false)
	await _shot_story_event(
			"hyunsu_reunion_later", prefix + "03_photo_opening_result", "",
			0.45, true, true, 0, 0, false, 1)
	_assert_hyunsu_reunion_uncommitted("photo opening")
	_prepare_hyunsu_reunion_qa_state("oneroom", false)
	await _shot_story_event(
			"hyunsu_reunion_photo", prefix + "04_photo_branch", "", 0.55, true)
	_assert_hyunsu_reunion_uncommitted("photo branch")
	_prepare_hyunsu_reunion_qa_state("oneroom", false)
	await _shot_story_event(
			"hyunsu_reunion_photo", prefix + "05_photo_meeting_promise", "",
			0.45, true, true, 0, 0, false, 1)
	_assert_hyunsu_reunion_uncommitted("photo promise")

	_prepare_hyunsu_reunion_qa_state("apartment", false)
	await _shot_story_event(
			"hyunsu_reunion_memory", prefix + "06_waited_memory", "", 0.55, true)
	_assert_hyunsu_reunion_uncommitted("waited memory")
	_prepare_hyunsu_reunion_qa_state("apartment", true)
	await _shot_story_event(
			"hyunsu_reunion_memory", prefix + "07_knocked_memory", "", 0.55, true)
	_assert_hyunsu_reunion_uncommitted("knocked memory")
	_prepare_hyunsu_reunion_qa_state("apartment", true)
	await _shot_story_event(
			"hyunsu_reunion_memory", prefix + "08_memory_meeting_promise", "",
			0.45, true, true, 0, 0, false, 1)
	_assert_hyunsu_reunion_uncommitted("memory promise")

	_prepare_hyunsu_reunion_qa_state("oneroom", false)
	await _shot_story_event(
			"hyunsu_reunion_meet", prefix + "09_restaurant_arrival", "", 0.55, true)
	_prepare_hyunsu_reunion_qa_state("oneroom", false)
	await _shot_story_event(
			"hyunsu_reunion_meet", prefix + "10_restaurant_choices", "",
			0.45, true, true)
	_assert_hyunsu_reunion_uncommitted("restaurant choices")
	_prepare_hyunsu_reunion_qa_state("oneroom", false)
	await _shot_story_event(
			"hyunsu_reunion_meet", prefix + "11_endurance_result", "",
			0.45, true, true, 0, 0, false, 2)
	_assert_hyunsu_reunion_state("endurance", 0)
	_prepare_hyunsu_reunion_qa_state("oneroom", true)
	await _shot_story_event(
			"hyunsu_reunion_meet", prefix + "12_call_first_result", "",
			0.45, true, true, 1, 0, false, 2)
	_assert_hyunsu_reunion_state("call first", 1)

	await _verify_hyunsu_reunion_controller(0, 0, "gosiwon", false)
	await _verify_hyunsu_reunion_controller(1, 1, "oneroom", true)

func _prepare_hyunsu_reunion_qa_state(housing_id: String, comforted: bool) -> void:
	_prepare_main_game_state()
	GameState.turn = 96
	GameState.age = 34
	GameState.year = 2027
	GameState.month = 12
	GameState.week_of_month = 4
	GameState.housing = housing_id
	GameState.mental = 60
	GameState.social_skill = 20
	GameState.moral_tint = 0.0
	GameState.inventory.clear()
	GameState.flags["hyunsu_failed"] = true
	GameState.flags["hyunsu_pivoted"] = true
	GameState.flags.erase("hyunsu_reconnected")
	if comforted:
		GameState.flags["hyunsu_comforted"] = true
	else:
		GameState.flags.erase("hyunsu_comforted")
	_set_cast_relation_for_qa("hyunsu", 28, true)
	GameState.cast["hyunsu"]["stage"] = "pivoted"
	GameState.cast["hyunsu"]["flags"] = {}

func _hyunsu_card_count() -> int:
	var count := 0
	for owned in GameState.inventory:
		if owned is Dictionary and str(owned.get("id", "")) == "artifact_hyunsu_card":
			count += int(owned.get("quantity", 1))
	return count

func _assert_hyunsu_reunion_uncommitted(label: String) -> void:
	if int(GameState.mental) != 60 or int(GameState.social_skill) != 20 \
			or not is_equal_approx(GameState.moral_tint, 0.0):
		_fail("Hyunsu reunion %s changed stats before the restaurant response." % label)
	if GameState.flags.get("hyunsu_reconnected", false) or _hyunsu_card_count() != 0:
		_fail("Hyunsu reunion %s granted reconnection or a physical card early." % label)
	var hyunsu: Dictionary = GameState.cast.get("hyunsu", {})
	if int(hyunsu.get("affinity", -999)) != 28 or str(hyunsu.get("stage", "")) != "pivoted":
		_fail("Hyunsu reunion %s changed the relationship before the final response." % label)

func _assert_hyunsu_reunion_state(label: String, final_choice: int) -> void:
	var expected_mental := 64 if final_choice == 0 else 63
	var expected_social := 21 if final_choice == 0 else 22
	var expected_tint := 3.0 if final_choice == 0 else 4.0
	if int(GameState.mental) != expected_mental \
			or int(GameState.social_skill) != expected_social \
			or not is_equal_approx(GameState.moral_tint, expected_tint):
		_fail("Hyunsu reunion %s changed its terminal totals: mental=%s social=%s tint=%s." % [
			label, GameState.mental, GameState.social_skill, GameState.moral_tint])
	if not GameState.flags.get("hyunsu_reconnected", false) or _hyunsu_card_count() != 1:
		_fail("Hyunsu reunion %s did not grant one reconnection flag and physical card." % label)
	var hyunsu: Dictionary = GameState.cast.get("hyunsu", {})
	if int(hyunsu.get("affinity", -999)) != 28 or str(hyunsu.get("stage", "")) != "pivoted":
		_fail("Hyunsu reunion %s changed the canonical cast totals." % label)

func _hyunsu_reunion_choices_focused(story: Node, label: String) -> bool:
	var choice_box := story.get("_choice_box") as Control
	var focus := get_viewport().gui_get_focus_owner() as Button
	if not is_instance_valid(focus) or not is_instance_valid(choice_box) \
			or not choice_box.is_ancestor_of(focus):
		_fail("Hyunsu reunion %s did not focus a controller-selectable choice." % label)
		return false
	return true

func _verify_hyunsu_reunion_controller(
		root_choice: int, final_choice: int, housing_id: String, comforted: bool) -> void:
	_prepare_hyunsu_reunion_qa_state(housing_id, comforted)
	GameState.pending_story_queue = ["hyunsu_reunion_later"]
	var packed := load("res://scenes/StoryMode.tscn") as PackedScene
	var story := packed.instantiate()
	get_tree().root.add_child.call_deferred(story)
	await get_tree().process_frame
	if story.has_method("_set_auto_mode"):
		story._set_auto_mode(false, false)
	await _settle(0.30)
	if not await _drive_story_to_event_choices(story, "hyunsu_reunion_later") \
			or not _hyunsu_reunion_choices_focused(story, "opening"):
		return
	if root_choice == 1:
		await _press_qa_action("ui_down")
		await _settle(0.08)
	await _press_qa_action("ui_accept")
	await _settle(0.18)
	_assert_hyunsu_reunion_uncommitted("controller opening %d" % root_choice)
	var branch_id := "hyunsu_reunion_photo" if root_choice == 0 else "hyunsu_reunion_memory"
	if not await _drive_story_to_event_choices(story, branch_id) \
			or not _hyunsu_reunion_choices_focused(story, "memory branch"):
		return
	_assert_hyunsu_visual_state(story, branch_id, -1)
	await _press_qa_action("ui_accept")
	await _settle(0.18)
	_assert_hyunsu_reunion_uncommitted("controller branch %d" % root_choice)
	if not await _drive_story_to_event_choices(story, "hyunsu_reunion_meet") \
			or not _hyunsu_reunion_choices_focused(story, "restaurant response"):
		return
	_assert_hyunsu_visual_state(story, "hyunsu_reunion_meet", -1)
	if final_choice == 1:
		await _press_qa_action("ui_down")
		await _settle(0.08)
	await _press_qa_action("ui_accept")
	await _settle(0.18)
	_assert_hyunsu_reunion_state(
			"controller %d/%d" % [root_choice, final_choice], final_choice)
	_remove_nodes_by_script("res://scenes/StoryMode.gd")
	GameState.pending_story_queue.clear()
	await _settle(0.20)

func _shot_sangchul_confrontation_surfaces(lang: String = "en", prefix: String = "sangchul_en_") -> void:
	_set_qa_language(lang)

	_prepare_sangchul_confrontation_qa_state()
	await _shot_story_event("arc_sangchul_confrontation", prefix + "01_question_intro", "", 0.55, true)
	_prepare_sangchul_confrontation_qa_state()
	await _shot_story_event("arc_sangchul_confrontation", prefix + "02_question_choices", "", 0.45, true, true)
	_prepare_sangchul_confrontation_qa_state()
	await _shot_story_event("arc_sangchul_confrontation", prefix + "03_wait_result", "", 0.45, true, true, 0, 0, false, 1)
	_assert_sangchul_confrontation_uncommitted("wait opening")
	_prepare_sangchul_confrontation_qa_state()
	await _shot_story_event("arc_sangchul_confrontation", prefix + "04_bury_opening_result", "", 0.45, true, true, 1, 0, false, 1)
	_assert_sangchul_confrontation_uncommitted("bury opening")

	_prepare_sangchul_confrontation_qa_state()
	await _shot_story_event("arc_sangchul_buried_silence", prefix + "05_buried_intro", "", 0.55, true)
	_prepare_sangchul_confrontation_qa_state()
	await _shot_story_event("arc_sangchul_buried_silence", prefix + "06_buried_choices", "", 0.45, true, true)
	_prepare_sangchul_confrontation_qa_state()
	await _shot_story_event("arc_sangchul_buried_silence", prefix + "07_buried_final_result", "", 0.45, true, true, 0, 0, false, 2)
	_assert_sangchul_confrontation_state("buried", 65, 50, 30, -3.0, "sangchul_truth_buried", false)
	_prepare_sangchul_confrontation_qa_state()
	await _shot_story_event("arc_sangchul_buried_silence", prefix + "08_buried_turnback_result", "", 0.45, true, true, 1, 0, false, 1)
	_assert_sangchul_confrontation_uncommitted("bury turnback")

	_prepare_sangchul_confrontation_qa_state()
	await _shot_story_event("arc_sangchul_stairwell", prefix + "09_stairwell_intro", "", 0.55, true)
	_prepare_sangchul_confrontation_qa_state()
	await _shot_story_event("arc_sangchul_stairwell", prefix + "10_stairwell_choices", "", 0.45, true, true)
	_prepare_sangchul_confrontation_qa_state()
	await _shot_story_event("arc_sangchul_stairwell", prefix + "11_leave_final_result", "", 0.45, true, true, 0, 0, false, 2)
	_assert_sangchul_confrontation_state("left", 57, 48, 30, 8.0, "sangchul_quietly_distanced", false)
	_prepare_sangchul_confrontation_qa_state()
	await _shot_story_event("arc_sangchul_stairwell", prefix + "12_stairwell_turnback_result", "", 0.45, true, true, 1, 0, false, 1)
	_assert_sangchul_confrontation_uncommitted("stairwell turnback")

	_prepare_sangchul_confrontation_qa_state()
	await _shot_story_event("arc_sangchul_reckoning", prefix + "13_reckoning_intro", "", 0.55, true)
	_prepare_sangchul_confrontation_qa_state()
	await _shot_story_event("arc_sangchul_reckoning", prefix + "14_reckoning_choices", "", 0.45, true, true)
	for outcome in [
		[0, "15_report_result", 70, 40, 30, 9.0, "sangchul_reported"],
		[1, "16_forgive_result", 63, 50, 30, 6.0, "sangchul_forgiven"],
		[2, "17_leverage_result", 45, 50, 35, -20.0, "sangchul_leveraged"],
		[3, "18_repayment_result", 67, 55, 30, 7.0, "cleared_father_debt_from_sangchul"],
	]:
		_prepare_sangchul_confrontation_qa_state()
		await _shot_story_event(
				"arc_sangchul_reckoning", prefix + str(outcome[1]), "", 0.45,
				true, true, int(outcome[0]), 0, false, 2)
		_assert_sangchul_confrontation_state(
				str(outcome[1]), int(outcome[2]), int(outcome[3]), int(outcome[4]),
				float(outcome[5]), str(outcome[6]), true)

func _prepare_sangchul_confrontation_qa_state() -> void:
	_prepare_main_game_state()
	GameState.mental = 60
	GameState.reputation = 50
	GameState.investment_skill = 30
	GameState.moral_tint = 0.0
	for flag in [
		"arc_sangchul_confrontation_seen", "sangchul_confronted",
		"arc_sangchul_reckoning_seen", "sangchul_truth_buried",
		"sangchul_quietly_distanced", "sangchul_reported", "sangchul_cut_ties",
		"sangchul_forgiven", "sangchul_leveraged", "crossed_line",
		"cleared_father_debt_from_sangchul",
	]:
		GameState.flags.erase(flag)
	_set_cast_relation_for_qa("sangchul", 60)
	GameState.cast["sangchul"]["stage"] = "trusted"

func _assert_sangchul_confrontation_uncommitted(label: String) -> void:
	if GameState.flags.get("arc_sangchul_confrontation_seen", false) \
			or GameState.flags.get("arc_sangchul_reckoning_seen", false):
		_fail("Sangchul %s committed final route flags before the final link." % label)

func _assert_sangchul_confrontation_state(
		label: String, mental: int, reputation: int, investment_skill: int,
		tint: float, route_flag: String, reckoned: bool) -> void:
	if int(GameState.mental) != mental or int(GameState.reputation) != reputation \
			or int(GameState.investment_skill) != investment_skill \
			or not is_equal_approx(GameState.moral_tint, tint):
		_fail(
				"Sangchul %s totals changed: mental=%s reputation=%s skill=%s tint=%s." % [
					label, GameState.mental, GameState.reputation,
					GameState.investment_skill, GameState.moral_tint,
				])
	if not GameState.flags.get("arc_sangchul_confrontation_seen", false) \
			or not GameState.flags.get(route_flag, false):
		_fail("Sangchul %s did not commit its canonical final flags." % label)
	if bool(GameState.flags.get("arc_sangchul_reckoning_seen", false)) != reckoned \
			or bool(GameState.flags.get("sangchul_confronted", false)) != reckoned:
		_fail("Sangchul %s changed the confrontation/reckoning route state." % label)

func _shot_father_peak_surfaces(lang: String = "en", prefix: String = "father_peaks_en_") -> void:
	_set_qa_language(lang)

	_prepare_father_peak_qa_state()
	await _shot_story_event("father_hospital_wait", prefix + "01_hospital_wait_intro", "", 0.55, true)
	_prepare_father_peak_qa_state()
	await _shot_story_event("father_hospital_wait", prefix + "02_hospital_wait_choices", "", 0.45, true, true)
	_prepare_father_peak_qa_state()
	await _shot_story_event("father_hospital_wait", prefix + "03_hospital_water_result", "", 0.45, true, true, 1, 0, false, 2)
	_assert_father_hospital_uncommitted("waiting-room response")

	_prepare_father_peak_qa_state()
	await _shot_story_event("father_hospital_results", prefix + "04_hospital_results_intro", "", 0.55, true)
	_prepare_father_peak_qa_state()
	await _shot_story_event("father_hospital_results", prefix + "05_hospital_results_choices", "", 0.45, true, true)
	_prepare_father_peak_qa_state()
	await _shot_story_event("father_hospital_results", prefix + "06_hospital_avoid_result", "", 0.45, true, true, 0, 0, false, 2)
	_assert_father_hospital_state("avoid results", 51, 40, 53, "normal", false)
	_prepare_father_peak_qa_state()
	await _shot_story_event("father_hospital_results", prefix + "07_hospital_read_result", "", 0.45, true, true, 1, 0, false, 2)
	_assert_father_hospital_state("read together", 61, 42, 56, "hopeful", true)

	_prepare_father_peak_qa_state()
	await _shot_story_event("callback_showed_room_parents_echo", prefix + "08_home_father", "", 0.55, true)
	_prepare_father_peak_qa_state()
	await _shot_story_event("callback_hid_room_parents_echo", prefix + "09_home_mother", "", 0.55, true)
	_prepare_father_peak_qa_state()
	await _shot_story_event("story_prologue_dad", prefix + "10_home_call", "", 0.55, true)
	_prepare_father_peak_qa_state()
	await _shot_story_event("arc_pre_ending_father_call", prefix + "11_home_weak_call", "", 0.55, true)

	_prepare_father_passing_qa_state()
	await _shot_story_event("arc_father_passing", prefix + "12_passing_home_call", "", 0.55, true)
	_prepare_father_passing_qa_state()
	await _shot_story_event("arc_father_passing", prefix + "13_passing_home_choices", "", 0.45, true, true)
	_prepare_father_passing_qa_state()
	await _shot_story_event("arc_father_passing", prefix + "14_passing_ticket_result", "", 0.45, true, true, 0)
	_assert_father_passing_uncommitted("home-call ticket")

	_prepare_father_passing_qa_state()
	await _shot_story_event("arc_father_passing_platform", prefix + "15_passing_platform_choices", "", 0.55, true, true)
	_prepare_father_passing_qa_state()
	await _shot_story_event("arc_father_passing_hospital_room", prefix + "16_passing_empty_room", "", 0.55, true)
	_prepare_father_passing_qa_state()
	await _shot_story_event("arc_father_passing_hospital_room", prefix + "17_passing_ktx_result", "", 0.45, true, true, 0)
	_assert_father_passing_state("KTX", 20, 100_000_000.0, 10.0, "tried_to_go_to_father")

	_prepare_father_passing_qa_state()
	await _shot_story_event("arc_father_passing_deal_room", prefix + "18_passing_deal_choices", "", 0.55, true, true)
	_prepare_father_passing_qa_state()
	await _shot_story_event("arc_father_passing_deal_morning", prefix + "19_passing_deal_morning", "", 0.55, true)
	_prepare_father_passing_qa_state()
	await _shot_story_event("arc_father_passing_deal_morning", prefix + "20_passing_deal_result", "", 0.45, true, true, 0)
	_assert_father_passing_state("deal", 35, 105_000_000.0, -8.0, "chose_money_over_father")

	_prepare_father_peak_qa_state()
	await _shot_story_event("arc_father_04_visit", prefix + "21_visit_door_intro", "", 0.55, true)
	_prepare_father_peak_qa_state()
	await _shot_story_event("arc_father_04_visit", prefix + "22_visit_door_choices", "", 0.45, true, true)
	_prepare_father_peak_qa_state()
	await _shot_story_event("arc_father_04_visit", prefix + "23_visit_deferred_result", "", 0.45, true, true, 3)
	_assert_father_visit_deferred_state()
	_prepare_father_peak_qa_state()
	await _shot_story_event("arc_father_04_visit", prefix + "24_visit_entered_result", "", 0.45, true, true, 0)
	_assert_father_visit_entered_state()

func _prepare_father_peak_qa_state() -> void:
	_prepare_main_game_state()
	GameState.mental = 60
	GameState.intelligence = 40
	GameState.moral_tint = 0.0
	for flag in [
		"saw_father_medical", "father_passed", "visited_father", "father_visit_deferred",
	]:
		GameState.flags.erase(flag)
	GameState.flags["father_visited"] = true
	_set_cast_relation_for_qa("father", 50)
	GameState.cast["father"]["stage"] = "normal"

func _assert_father_visit_deferred_state() -> void:
	var father: Dictionary = GameState.cast.get("father", {})
	if int(GameState.mental) != 42 or not is_equal_approx(GameState.moral_tint, -12.0):
		_fail("Deferred father visit did not preserve its mental/tint consequence.")
	if int(father.get("affinity", 0)) != 35 or str(father.get("stage", "")) != "distant":
		_fail("Deferred father visit did not preserve its relationship consequence.")
	if not GameState.flags.get("father_visit_deferred", false) \
			or GameState.flags.get("visited_father", false):
		_fail("Deferred father visit did not remain on the unvisited KTX route.")

func _assert_father_visit_entered_state() -> void:
	var father: Dictionary = GameState.cast.get("father", {})
	if int(GameState.mental) != 83 or not is_equal_approx(GameState.moral_tint, 9.0):
		_fail("Entered father visit did not preserve its mental/tint consequence.")
	if int(father.get("affinity", 0)) != 75 or str(father.get("stage", "")) != "reconciled":
		_fail("Entered father visit did not preserve its relationship consequence.")
	if not GameState.flags.get("visited_father", false) \
			or GameState.flags.get("father_visit_deferred", false):
		_fail("Entered father visit did not leave the KTX deferral route.")

func _assert_father_hospital_uncommitted(label: String) -> void:
	if int(GameState.mental) != 60 or int(GameState.intelligence) != 40:
		_fail("Father hospital %s changed stats before the final decision." % label)
	if int(GameState.cast["father"].get("affinity", 0)) != 50 \
			or GameState.flags.get("saw_father_medical", false):
		_fail("Father hospital %s committed relationship state before results." % label)

func _assert_father_hospital_state(
		label: String, mental: int, intelligence: int, affinity: int,
		stage: String, saw_results: bool) -> void:
	var father: Dictionary = GameState.cast.get("father", {})
	if int(GameState.mental) != mental or int(GameState.intelligence) != intelligence:
		_fail("Father hospital %s totals changed: mental=%s intelligence=%s." % [
			label, GameState.mental, GameState.intelligence,
		])
	if int(father.get("affinity", 0)) != affinity or str(father.get("stage", "")) != stage:
		_fail("Father hospital %s relation changed: affinity=%s stage=%s." % [
			label, father.get("affinity", 0), father.get("stage", ""),
		])
	if bool(GameState.flags.get("saw_father_medical", false)) != saw_results:
		_fail("Father hospital %s changed the medical-result flag contract." % label)

func _prepare_father_passing_qa_state() -> void:
	_prepare_main_game_state()
	GameState.housing = "oneroom"
	GameState.money = 100_000_000.0
	GameState.mental = 60
	GameState.moral_tint = 0.0
	for flag in [
		"arc_father_passing_seen", "father_passed", "tried_to_go_to_father",
		"chose_money_over_father",
	]:
		GameState.flags.erase(flag)
	_set_cast_relation_for_qa("father", 50)
	GameState.cast["father"]["stage"] = "hospitalized"

func _assert_father_passing_uncommitted(label: String) -> void:
	if int(GameState.mental) != 60 or not is_equal_approx(GameState.money, 100_000_000.0) \
			or not is_equal_approx(GameState.moral_tint, 0.0):
		_fail("Father passing %s changed stats before the terminal scene." % label)
	if str(GameState.cast["father"].get("stage", "")) != "hospitalized" \
			or GameState.flags.get("father_passed", false):
		_fail("Father passing %s committed death state before the terminal scene." % label)

func _assert_father_passing_state(
		label: String, mental: int, money: float, tint: float, route_flag: String) -> void:
	if int(GameState.mental) != mental or not is_equal_approx(GameState.money, money) \
			or not is_equal_approx(GameState.moral_tint, tint):
		_fail("Father passing %s totals changed: mental=%s money=%s tint=%s." % [
			label, GameState.mental, GameState.money, GameState.moral_tint,
		])
	if str(GameState.cast["father"].get("stage", "")) != "passed" \
			or not GameState.flags.get("arc_father_passing_seen", false) \
			or not GameState.flags.get("father_passed", false) \
			or not GameState.flags.get(route_flag, false):
		_fail("Father passing %s did not commit its canonical final route." % label)

func _shot_father_ktx_surfaces(lang: String = "en", prefix: String = "father_ktx_en_") -> void:
	_set_qa_language(lang)

	_prepare_father_ktx_qa_state()
	await _shot_story_event("arc_father_call_on_ktx", prefix + "01_station_passed_intro", "", 0.55, true)
	_prepare_father_ktx_qa_state()
	await _shot_story_event("arc_father_call_on_ktx", prefix + "02_station_passed_choices", "", 0.45, true, true)
	_prepare_father_ktx_qa_state()
	await _shot_story_event("arc_father_call_on_ktx", prefix + "03_open_memory_result", "", 0.45, true, true, 0, 0, false, 1)
	_assert_father_ktx_uncommitted("open memory")

	_prepare_father_ktx_qa_state()
	await _shot_story_event("arc_father_call_on_ktx_memory", prefix + "04_remote_memory", "", 0.55, true)
	_prepare_father_ktx_qa_state()
	await _shot_story_event("arc_father_call_on_ktx_memory", prefix + "05_memory_exit_result", "", 0.45, true, true, 0, 0, false, 1)
	_assert_father_ktx_uncommitted("memory exit")

	_prepare_father_ktx_qa_state()
	await _shot_story_event("arc_father_call_on_ktx_number", prefix + "06_call_decision", "", 0.55, true, true)
	_prepare_father_ktx_qa_state()
	await _shot_story_event("arc_father_call_on_ktx_number", prefix + "07_call_result", "", 0.45, true, true, 0, 0, false, 2)
	_assert_father_ktx_state("call", 55, 15.0, true)
	_prepare_father_ktx_qa_state()
	await _shot_story_event("arc_father_call_on_ktx_number", prefix + "08_silence_result", "", 0.45, true, true, 1, 0, false, 2)
	_assert_father_ktx_state("silence", 50, 3.0, false)

func _prepare_father_ktx_qa_state() -> void:
	_prepare_main_game_state()
	GameState.month = 10
	GameState.money = 100_000_000.0
	GameState.mental = 60
	GameState.moral_tint = 0.0
	for flag in [
		"father_passed", "arc_father_call_on_ktx_seen", "called_father_on_ktx",
	]:
		GameState.flags.erase(flag)
	GameState.flags["arc_father_03_seen"] = true
	GameState.flags["arc_father_medication_seen"] = true
	_set_cast_relation_for_qa("father", 50)
	GameState.cast["father"]["stage"] = "hospitalized"
	if not GameState.has_item("artifact_father_call"):
		GameState.add_item("artifact_father_call", 1)

func _assert_father_ktx_uncommitted(label: String) -> void:
	if int(GameState.mental) != 60 or not is_equal_approx(GameState.moral_tint, 0.0):
		_fail("Father KTX %s changed stats before the final decision." % label)
	if GameState.flags.get("arc_father_call_on_ktx_seen", false) \
			or GameState.flags.get("called_father_on_ktx", false):
		_fail("Father KTX %s committed a route before the final decision." % label)
	if str(GameState.cast["father"].get("stage", "")) != "hospitalized":
		_fail("Father KTX %s changed Father's canonical stage." % label)

func _assert_father_ktx_state(label: String, mental: int, tint: float, called: bool) -> void:
	if int(GameState.mental) != mental or not is_equal_approx(GameState.moral_tint, tint):
		_fail("Father KTX %s totals changed: mental=%s tint=%s." % [
			label, GameState.mental, GameState.moral_tint,
		])
	if not GameState.flags.get("arc_father_call_on_ktx_seen", false) \
			or bool(GameState.flags.get("called_father_on_ktx", false)) != called:
		_fail("Father KTX %s did not preserve the canonical route flags." % label)
	if str(GameState.cast["father"].get("stage", "")) != "hospitalized" \
			or GameState.flags.get("father_passed", false):
		_fail("Father KTX %s changed Father before the passing chain." % label)

func _shot_first_kiss_surfaces(
		lang: String = "en", prefix: String = "first_kiss_en_") -> void:
	_set_qa_language(lang)
	for route in [
		["daeun", "arc_daeun_first_kiss", "arc_daeun_first_kiss_wait",
			"arc_daeun_first_kiss_ask", "arc_daeun_first_kiss_choice"],
		["jiyeon", "arc_jiyeon_first_kiss", "arc_jiyeon_first_kiss_silence",
			"arc_jiyeon_first_kiss_speak", "arc_jiyeon_first_kiss_choice"],
	]:
		var person_id := str(route[0])
		var root_id := str(route[1])
		var branch_a_id := str(route[2])
		var branch_b_id := str(route[3])
		var final_id := str(route[4])

		_prepare_first_kiss_qa_state(person_id)
		await _shot_story_event(root_id, prefix + person_id + "_01_prelude", "", 0.45, true)
		_assert_first_kiss_uncommitted(person_id, "prelude")
		_prepare_first_kiss_qa_state(person_id)
		await _shot_story_event(root_id, prefix + person_id + "_02_opening_choice", "", 0.45, true, true)
		_assert_first_kiss_uncommitted(person_id, "opening choice")

		_prepare_first_kiss_qa_state(person_id)
		await _shot_story_event(branch_a_id, prefix + person_id + "_03_branch_a", "", 0.45, true, true)
		_assert_first_kiss_uncommitted(person_id, "branch A")
		_prepare_first_kiss_qa_state(person_id)
		await _shot_story_event(branch_b_id, prefix + person_id + "_04_branch_b", "", 0.45, true, true)
		_assert_first_kiss_uncommitted(person_id, "branch B")

		_prepare_first_kiss_qa_state(person_id)
		await _shot_story_event(final_id, prefix + person_id + "_05_final_choice", "", 0.55, true, true)
		_assert_first_kiss_uncommitted(person_id, "final choice")
		_prepare_first_kiss_qa_state(person_id)
		await _shot_story_event(
			final_id, prefix + person_id + "_06_kiss_result", "", 0.45,
			true, true, 0, 0, false, 2)
		_assert_first_kiss_state(person_id, "kiss", 70, 2.0, 62)
		_prepare_first_kiss_qa_state(person_id)
		await _shot_story_event(
			final_id, prefix + person_id + "_07_defer_result", "", 0.45,
			true, true, 1, 0, false, 2)
		_assert_first_kiss_state(person_id, "defer", 64, 1.0, 54)

func _prepare_first_kiss_qa_state(person_id: String) -> void:
	_prepare_main_game_state()
	GameState.age = 34
	GameState.turn = 72
	GameState.year = 2027
	GameState.month = 1
	GameState.week_of_month = 2
	GameState.mental = 60
	GameState.moral_tint = 0.0
	for flag in [
		"daeun_romance_started", "jiyeon_romance_started",
		"arc_daeun_first_kiss_seen", "arc_jiyeon_first_kiss_seen",
	]:
		GameState.flags.erase(flag)
	GameState.flags[person_id + "_romance_started"] = true
	GameState.flags["date_count_" + person_id] = 2
	_set_cast_relation_for_qa(person_id, 50)
	GameState.cast[person_id]["stage"] = "lover"

func _assert_first_kiss_uncommitted(person_id: String, label: String) -> void:
	var completion_flag := "arc_%s_first_kiss_seen" % person_id
	var affinity := int(GameState.cast.get(person_id, {}).get("affinity", -999))
	if int(GameState.mental) != 60 or not is_equal_approx(GameState.moral_tint, 0.0) \
			or affinity != 50:
		_fail("%s first-kiss %s changed state before the final decision: mental=%s tint=%s affinity=%s." % [
			person_id, label, GameState.mental, GameState.moral_tint, affinity,
		])
	if GameState.flags.get(completion_flag, false):
		_fail("%s first-kiss %s committed its completion flag early." % [person_id, label])

func _assert_first_kiss_state(
		person_id: String, label: String, mental: int, tint: float, affinity: int) -> void:
	var completion_flag := "arc_%s_first_kiss_seen" % person_id
	var actual_affinity := int(GameState.cast.get(person_id, {}).get("affinity", -999))
	if int(GameState.mental) != mental or not is_equal_approx(GameState.moral_tint, tint) \
			or actual_affinity != affinity:
		_fail("%s first-kiss %s totals changed: mental=%s tint=%s affinity=%s." % [
			person_id, label, GameState.mental, GameState.moral_tint, actual_affinity,
		])
	if not GameState.flags.get(completion_flag, false):
		_fail("%s first-kiss %s did not commit its completion flag." % [person_id, label])

func _shot_daeun_first_night_surfaces(
		lang: String = "en", prefix: String = "daeun_first_night_en_") -> void:
	_set_qa_language(lang)

	_prepare_daeun_first_night_qa_state("gosiwon")
	await _shot_story_event(
		"arc_daeun_first_night", prefix + "01_gosiwon_arrival", "", 0.55, true)
	_assert_daeun_first_night_uncommitted("goshiwon arrival")
	_prepare_daeun_first_night_qa_state("gosiwon")
	await _shot_story_event(
		"arc_daeun_first_night", prefix + "02_gosiwon_opening_choice", "", 0.55, true, true)
	_assert_daeun_first_night_uncommitted("goshiwon opening choice")
	_prepare_daeun_first_night_qa_state("gosiwon")
	await _shot_story_event(
		"arc_daeun_first_night_silence", prefix + "03_gosiwon_silence", "", 0.55, true, true)
	_assert_daeun_first_night_uncommitted("goshiwon silence branch")
	_prepare_daeun_first_night_qa_state("gosiwon")
	await _shot_story_event(
		"arc_daeun_first_night_decision", prefix + "04_gosiwon_final_choice", "", 0.55, true, true)
	_assert_daeun_first_night_uncommitted("goshiwon final choice")
	_prepare_daeun_first_night_qa_state("gosiwon")
	await _shot_story_event(
		"arc_daeun_first_night_decision", prefix + "05_gosiwon_intimacy_result", "", 0.55,
		true, true, 0, 0, false, 3)
	_assert_daeun_first_night_state("intimacy", 74, 3.0, 68, true)

	_prepare_daeun_first_night_qa_state("oneroom")
	await _shot_story_event(
		"arc_daeun_first_night", prefix + "06_oneroom_arrival", "", 0.55, true)
	_assert_daeun_first_night_uncommitted("one-room arrival")
	_prepare_daeun_first_night_qa_state("oneroom")
	await _shot_story_event(
		"arc_daeun_first_night_truth", prefix + "07_oneroom_truth", "", 0.55, true, true)
	_assert_daeun_first_night_uncommitted("one-room truth branch")
	_prepare_daeun_first_night_qa_state("oneroom")
	await _shot_story_event(
		"arc_daeun_first_night_decision", prefix + "08_oneroom_final_choice", "", 0.55, true, true)
	_assert_daeun_first_night_uncommitted("one-room final choice")
	_prepare_daeun_first_night_qa_state("oneroom")
	await _shot_story_event(
		"arc_daeun_first_night_decision", prefix + "09_oneroom_sleep_result", "", 0.55,
		true, true, 1, 0, false, 3)
	_assert_daeun_first_night_state("sleep", 70, 5.0, 64, false)

func _prepare_daeun_first_night_qa_state(housing_id: String) -> void:
	_prepare_main_game_state()
	GameState.age = 34
	GameState.turn = 70
	GameState.year = 2027
	GameState.month = 7
	GameState.week_of_month = 2
	GameState.housing = housing_id
	GameState.mental = 60
	GameState.moral_tint = 0.0
	for flag in [
		"daeun_romance_started", "jiyeon_romance_started",
		"arc_daeun_first_night_seen", "daeun_first_night",
	]:
		GameState.flags.erase(flag)
	GameState.flags["daeun_romance_started"] = true
	_set_cast_relation_for_qa("daeun", 50)
	GameState.cast["daeun"]["stage"] = "lover"

func _assert_daeun_first_night_uncommitted(label: String) -> void:
	var affinity := int(GameState.cast.get("daeun", {}).get("affinity", -999))
	var stage := str(GameState.cast.get("daeun", {}).get("stage", ""))
	if int(GameState.mental) != 60 or not is_equal_approx(GameState.moral_tint, 0.0) \
			or affinity != 50 or stage != "lover":
		_fail("Daeun first-night %s changed state before the final decision: mental=%s tint=%s affinity=%s stage=%s." % [
			label, GameState.mental, GameState.moral_tint, affinity, stage,
		])
	if GameState.flags.get("arc_daeun_first_night_seen", false) \
			or GameState.flags.get("daeun_first_night", false):
		_fail("Daeun first-night %s committed a route before the final decision." % label)

func _assert_daeun_first_night_state(
		label: String, mental: int, tint: float, affinity: int, intimate: bool) -> void:
	var actual_affinity := int(GameState.cast.get("daeun", {}).get("affinity", -999))
	var stage := str(GameState.cast.get("daeun", {}).get("stage", ""))
	if int(GameState.mental) != mental or not is_equal_approx(GameState.moral_tint, tint) \
			or actual_affinity != affinity or stage != "lover":
		_fail("Daeun first-night %s totals changed: mental=%s tint=%s affinity=%s stage=%s." % [
			label, GameState.mental, GameState.moral_tint, actual_affinity, stage,
		])
	if not GameState.flags.get("arc_daeun_first_night_seen", false) \
			or bool(GameState.flags.get("daeun_first_night", false)) != intimate:
		_fail("Daeun first-night %s did not preserve the canonical route flags." % label)

func _assert_daeun_first_night_visual_state(story: Node, event_id: String) -> void:
	var expected_portraits := {
		"arc_daeun_first_night": "daeun_normal",
		"arc_daeun_first_night_silence": "daeun_normal",
		"arc_daeun_first_night_truth": "daeun_sad",
		"arc_daeun_first_night_decision": "daeun_smile",
	}
	if not expected_portraits.has(event_id):
		return
	var expected_background := ImageRegistry.infer_background_id({}, GameState.housing)
	var actual_background := str(story.get("_event_background_id"))
	if actual_background != expected_background:
		_fail("%s housing expected %s, got %s." % [
			event_id, expected_background, actual_background,
		])
	var portrait := story.get("_portrait") as TextureRect
	var actual_portrait_path := ""
	if is_instance_valid(portrait) and portrait.texture != null:
		actual_portrait_path = portrait.texture.resource_path
	var expected_portrait_path := ImageRegistry.get_portrait(str(expected_portraits[event_id]))
	if actual_portrait_path != expected_portrait_path:
		_fail("%s portrait expected %s, got %s." % [
			event_id, expected_portrait_path, actual_portrait_path,
		])

func _shot_season_peak_surfaces(
		lang: String = "en", prefix: String = "season_peaks_en_") -> void:
	_set_qa_language(lang)
	var routes: Array[Dictionary] = [
		{
			"key": "daeun_sea", "person": "daeun",
			"root": "arc_season_sea_daeun",
			"branches": ["arc_season_sea_daeun_years", "arc_season_sea_daeun_horizon"],
			"final": "arc_season_sea_daeun_decision", "flag": "daeun_sea_5years",
			"outcomes": [
				{"choice": 0, "money": 955_000.0, "mental": 68, "tint": 2.0, "affinity": 58},
				{"choice": 1, "money": 955_000.0, "mental": 70, "tint": 1.0, "affinity": 55},
			],
		},
		{
			"key": "jiyeon_sea", "person": "jiyeon",
			"root": "arc_season_sea_jiyeon",
			"branches": ["arc_season_sea_jiyeon_voice", "arc_season_sea_jiyeon_route"],
			"final": "arc_season_sea_jiyeon_decision", "flag": "jiyeon_cant_swim",
			"outcomes": [
				{"choice": 0, "money": 940_000.0, "mental": 66, "tint": 1.0, "affinity": 54},
				{"choice": 1, "money": 940_000.0, "mental": 68, "tint": 2.0, "affinity": 58},
			],
		},
		{
			"key": "daeun_fireworks", "person": "daeun",
			"root": "arc_season_fireworks_daeun",
			"branches": [
				"arc_season_fireworks_daeun_dress",
				"arc_season_fireworks_daeun_river",
			],
			"final": "arc_season_fireworks_daeun_decision", "flag": "",
			"outcomes": [
				{"choice": 0, "money": 1_000_000.0, "mental": 66, "tint": 2.0, "affinity": 58},
				{"choice": 1, "money": 1_000_000.0, "mental": 68, "tint": 2.0, "affinity": 56},
				{"choice": 2, "money": 1_000_000.0, "mental": 65, "tint": 1.0, "affinity": 55},
			],
		},
		{
			"key": "jiyeon_fireworks", "person": "jiyeon",
			"root": "arc_season_fireworks_jiyeon",
			"branches": [
				"arc_season_fireworks_jiyeon_schedule",
				"arc_season_fireworks_jiyeon_pace",
			],
			"final": "arc_season_fireworks_jiyeon_decision", "flag": "",
			"outcomes": [
				{"choice": 0, "money": 1_000_000.0, "mental": 66, "tint": 2.0, "affinity": 58},
				{"choice": 1, "money": 1_000_000.0, "mental": 65, "tint": 1.0, "affinity": 56},
				{"choice": 2, "money": 1_000_000.0, "mental": 68, "tint": 2.0, "affinity": 56},
			],
		},
	]

	for route in routes:
		var key := str(route["key"])
		var person_id := str(route["person"])
		var root_id := str(route["root"])
		var branches: Array = route["branches"]
		var final_id := str(route["final"])

		_prepare_season_peak_qa_state(person_id)
		await _shot_story_event(root_id, prefix + key + "_01_prelude", "", 0.45, true)
		_assert_season_peak_uncommitted(person_id, key + " prelude")
		_prepare_season_peak_qa_state(person_id)
		await _shot_story_event(root_id, prefix + key + "_02_opening_choices", "", 0.45, true, true)
		_assert_season_peak_uncommitted(person_id, key + " opening choices")

		for branch_index in range(branches.size()):
			_prepare_season_peak_qa_state(person_id)
			await _shot_story_event(
					str(branches[branch_index]),
					prefix + key + "_0%d_branch" % [branch_index + 3], "", 0.45, true, true)
			_assert_season_peak_uncommitted(person_id, key + " branch %d" % branch_index)

		_prepare_season_peak_qa_state(person_id)
		await _shot_story_event(final_id, prefix + key + "_05_final_choices", "", 0.55, true, true)
		_assert_season_peak_uncommitted(person_id, key + " final choices")

		var outcomes: Array = route["outcomes"]
		for outcome_index in range(outcomes.size()):
			var outcome: Dictionary = outcomes[outcome_index]
			_prepare_season_peak_qa_state(person_id)
			await _shot_story_event(
					final_id, prefix + key + "_%02d_result" % [outcome_index + 6], "", 0.45,
					true, true, int(outcome["choice"]), 0, false, 2)
			_assert_season_peak_state(
					person_id, key + " outcome %d" % outcome_index,
					float(outcome["money"]), int(outcome["mental"]), float(outcome["tint"]),
					int(outcome["affinity"]), str(route["flag"]))

func _prepare_season_peak_qa_state(person_id: String) -> void:
	_prepare_main_game_state()
	GameState.age = 35
	GameState.turn = 120
	GameState.year = 2028
	GameState.month = 8
	GameState.week_of_month = 2
	GameState.money = 1_000_000.0
	GameState.mental = 60
	GameState.moral_tint = 0.0
	for flag in [
		"daeun_romance_started", "jiyeon_romance_started",
		"daeun_sea_5years", "jiyeon_cant_swim",
	]:
		GameState.flags.erase(flag)
	GameState.flags[person_id + "_romance_started"] = true
	GameState.flags["date_count_" + person_id] = 4
	_set_cast_relation_for_qa(person_id, 50)
	GameState.cast[person_id]["stage"] = "lover"

func _assert_season_peak_uncommitted(person_id: String, label: String) -> void:
	var affinity := int(GameState.cast.get(person_id, {}).get("affinity", -999))
	if not is_equal_approx(GameState.money, 1_000_000.0) or int(GameState.mental) != 60 \
			or not is_equal_approx(GameState.moral_tint, 0.0) or affinity != 50:
		_fail("Season peak %s changed state before the final decision: money=%s mental=%s tint=%s affinity=%s." % [
			label, GameState.money, GameState.mental, GameState.moral_tint, affinity,
		])
	if GameState.flags.get("daeun_sea_5years", false) \
			or GameState.flags.get("jiyeon_cant_swim", false):
		_fail("Season peak %s committed its memory flag early." % label)

func _assert_season_peak_state(
		person_id: String, label: String, money: float, mental: int, tint: float,
		affinity: int, expected_flag: String) -> void:
	var actual_affinity := int(GameState.cast.get(person_id, {}).get("affinity", -999))
	if not is_equal_approx(GameState.money, money) or int(GameState.mental) != mental \
			or not is_equal_approx(GameState.moral_tint, tint) or actual_affinity != affinity:
		_fail("Season peak %s totals changed: money=%s mental=%s tint=%s affinity=%s." % [
			label, GameState.money, GameState.mental, GameState.moral_tint, actual_affinity,
		])
	for flag in ["daeun_sea_5years", "jiyeon_cant_swim"]:
		var should_exist: bool = not expected_flag.is_empty() and flag == expected_flag
		if bool(GameState.flags.get(flag, false)) != should_exist:
			_fail("Season peak %s changed flag %s (expected %s)." % [label, flag, should_exist])

func _shot_jaehyuk_peak_surfaces(
		lang: String = "en", prefix: String = "jaehyuk_en_") -> void:
	_set_qa_language(lang)

	_prepare_jaehyuk_peak_qa_state()
	await _shot_story_event(
		"arc_jaehyuk_03_pitch", prefix + "01_hotel_pitch_cg", "", 0.55, true)

	_prepare_jaehyuk_peak_qa_state()
	await _shot_story_event(
		"arc_jaehyuk_04a_ghost", prefix + "02_ghost_opening_choice", "",
		0.45, true, true)
	_assert_jaehyuk_uncommitted("ghost opening")
	_prepare_jaehyuk_peak_qa_state()
	await _shot_story_event(
		"arc_jaehyuk_ghost_read", prefix + "03_ghost_victim_posts", "",
		0.45, true, true)
	_assert_jaehyuk_uncommitted("ghost victim posts")
	_prepare_jaehyuk_peak_qa_state()
	await _shot_story_event(
		"arc_jaehyuk_ghost_message", prefix + "04_ghost_voice_message", "",
		0.45, true, true)
	_assert_jaehyuk_uncommitted("ghost voice message")

	_prepare_jaehyuk_peak_qa_state()
	await _shot_story_event(
		"arc_jaehyuk_ghost_decision", prefix + "05_ghost_two_choices", "",
		0.45, true, true)
	_assert_jaehyuk_uncommitted("ghost final without artifact")
	_prepare_jaehyuk_peak_qa_state()
	await _shot_story_event(
		"arc_jaehyuk_ghost_decision", prefix + "06_ghost_collapse_result", "",
		0.45, true, true, 0, 0, false, 1)
	_assert_jaehyuk_ghost_state("collapse", 25, 57, 50, 0.0, ["hit_rock_bottom"])
	_prepare_jaehyuk_peak_qa_state()
	await _shot_story_event(
		"arc_jaehyuk_ghost_decision", prefix + "07_ghost_victims_result", "",
		0.45, true, true, 1, 0, false, 1)
	_assert_jaehyuk_ghost_state("victims", 40, 65, 54, 5.0, ["joined_victims"])
	_prepare_jaehyuk_peak_qa_state(true)
	await _shot_story_event(
		"arc_jaehyuk_ghost_decision", prefix + "08_ghost_artifact_choices", "",
		0.45, true, true)
	_assert_jaehyuk_uncommitted("ghost final with artifact")
	_prepare_jaehyuk_peak_qa_state(true)
	await _shot_story_event(
		"arc_jaehyuk_ghost_decision", prefix + "09_ghost_artifact_result", "",
		0.45, true, true, 2, 0, false, 0)
	_assert_jaehyuk_ghost_state(
		"artifact", 42, 65, 50, 3.0, ["presented_artifact_correct"])
	_prepare_jaehyuk_peak_qa_state(true)
	GameState.flags["arc_jaehyuk_ghost_seen"] = true
	GameState.flags["jaehyuk_scammed"] = true
	await _shot_story_event(
		"arc_jaehyuk_photo_in_dark", prefix + "10_photo_after_ghost", "",
		0.45, true, true)

	_prepare_jaehyuk_peak_qa_state()
	await _shot_story_event(
		"arc_jaehyuk_mirror", prefix + "11_mirror_opening_choice", "",
		0.45, true, true)
	_assert_jaehyuk_uncommitted("mirror opening")
	_prepare_jaehyuk_peak_qa_state()
	await _shot_story_event(
		"arc_jaehyuk_mirror_reply", prefix + "12_mirror_reply", "",
		0.45, true, true)
	_assert_jaehyuk_uncommitted("mirror reply")
	_prepare_jaehyuk_peak_qa_state()
	await _shot_story_event(
		"arc_jaehyuk_mirror_father", prefix + "13_mirror_father", "",
		0.45, true, true)
	_assert_jaehyuk_uncommitted("mirror father")
	_prepare_jaehyuk_peak_qa_state()
	await _shot_story_event(
		"arc_jaehyuk_mirror_decision", prefix + "14_mirror_timed_choice", "",
		0.45, true, true)
	_assert_jaehyuk_uncommitted("mirror timed choice")
	for outcome in [
		[0, "15_mirror_refuse_result", "refuse", 52, 7.0,
			["refused_jaehyuk_guarantee"]],
		[1, "16_mirror_vouch_result", "vouch", 45, -20.0,
			["vouched_jaehyuk_guarantee", "crossed_line"]],
		[2, "17_mirror_block_result", "block", 55, -2.0,
			["blocked_jaehyuk_guarantee"]],
	]:
		_prepare_jaehyuk_peak_qa_state()
		await _shot_story_event(
			"arc_jaehyuk_mirror_decision", prefix + str(outcome[1]), "",
			0.45, true, true, int(outcome[0]), 0, false, 0)
		_assert_jaehyuk_mirror_state(
			str(outcome[2]), int(outcome[3]), float(outcome[4]), outcome[5])

func _prepare_jaehyuk_peak_qa_state(with_photo: bool = false) -> void:
	_prepare_main_game_state()
	GameState.age = 35
	GameState.turn = 84
	GameState.year = 2027
	GameState.month = 10
	GameState.week_of_month = 1
	GameState.housing = "oneroom"
	GameState.health = 65
	GameState.mental = 60
	GameState.intelligence = 50
	GameState.moral_tint = 0.0
	for flag in [
		"arc_jaehyuk_ghost_seen", "jaehyuk_scammed", "hit_rock_bottom",
		"joined_victims", "presented_artifact_correct",
		"arc_jaehyuk_photo_in_dark_seen", "jaehyuk_night_was_real",
		"deleted_jaehyuk_photo", "arc_jaehyuk_mirror_seen",
		"refused_jaehyuk_guarantee", "vouched_jaehyuk_guarantee",
		"blocked_jaehyuk_guarantee", "crossed_line",
	]:
		GameState.flags.erase(flag)
	_set_cast_relation_for_qa("jaehyuk", 50)
	GameState.cast["jaehyuk"]["stage"] = "all_in"
	if with_photo:
		GameState.add_item("artifact_jaehyuk_photo", 1)

func _assert_jaehyuk_uncommitted(label: String) -> void:
	var jaehyuk: Dictionary = GameState.cast.get("jaehyuk", {})
	if int(GameState.mental) != 60 or int(GameState.health) != 65 \
			or int(GameState.intelligence) != 50 \
			or not is_equal_approx(GameState.moral_tint, 0.0) \
			or int(jaehyuk.get("affinity", -999)) != 50 \
			or str(jaehyuk.get("stage", "")) != "all_in":
		_fail("Jaehyuk %s changed state before the final decision." % label)
	for flag in ["arc_jaehyuk_ghost_seen", "jaehyuk_scammed", "arc_jaehyuk_mirror_seen"]:
		if GameState.flags.get(flag, false):
			_fail("Jaehyuk %s committed %s before the final decision." % [label, flag])

func _assert_jaehyuk_ghost_state(
		label: String, mental: int, health: int, intelligence: int, tint: float,
		extra_flags: Array) -> void:
	var jaehyuk: Dictionary = GameState.cast.get("jaehyuk", {})
	if int(GameState.mental) != mental or int(GameState.health) != health \
			or int(GameState.intelligence) != intelligence \
			or not is_equal_approx(GameState.moral_tint, tint) \
			or int(jaehyuk.get("affinity", -999)) != -50 \
			or str(jaehyuk.get("stage", "")) != "betrayed":
		_fail("Jaehyuk ghost %s totals or cast state changed." % label)
	for flag in ["arc_jaehyuk_ghost_seen", "jaehyuk_scammed"] + extra_flags:
		if not GameState.flags.get(str(flag), false):
			_fail("Jaehyuk ghost %s did not commit %s." % [label, flag])

func _assert_jaehyuk_mirror_state(
		label: String, mental: int, tint: float, expected_flags: Array) -> void:
	var jaehyuk: Dictionary = GameState.cast.get("jaehyuk", {})
	if int(GameState.mental) != mental or int(GameState.health) != 65 \
			or int(GameState.intelligence) != 50 \
			or not is_equal_approx(GameState.moral_tint, tint) \
			or int(jaehyuk.get("affinity", -999)) != 50 \
			or str(jaehyuk.get("stage", "")) != "all_in":
		_fail("Jaehyuk mirror %s changed: mental=%s health=%s intelligence=%s tint=%s affinity=%s stage=%s." % [
			label, GameState.mental, GameState.health, GameState.intelligence,
			GameState.moral_tint, jaehyuk.get("affinity", -999), jaehyuk.get("stage", ""),
		])
	if not GameState.flags.get("arc_jaehyuk_mirror_seen", false):
		_fail("Jaehyuk mirror %s did not commit its completion flag." % label)
	for flag in expected_flags:
		if not GameState.flags.get(str(flag), false):
			_fail("Jaehyuk mirror %s did not commit %s." % [label, flag])

func _assert_jaehyuk_visual_state(story: Node, event_id: String) -> void:
	if event_id == "arc_jaehyuk_03_pitch":
		_assert_story_cg(story, "cg_jaehyuk_reveal", event_id)
		return
	var housing_events := [
		"arc_jaehyuk_04a_ghost", "arc_jaehyuk_ghost_read",
		"arc_jaehyuk_ghost_message", "arc_jaehyuk_ghost_decision",
		"arc_jaehyuk_photo_in_dark", "arc_jaehyuk_aftermath",
		"arc_jaehyuk_mirror", "arc_jaehyuk_mirror_reply",
		"arc_jaehyuk_mirror_father", "arc_jaehyuk_mirror_decision",
	]
	if event_id not in housing_events:
		return
	var actual_background := str(story.get("_event_background_id"))
	var expected_background := ImageRegistry.infer_background_id({}, GameState.housing)
	if actual_background != expected_background:
		_fail("%s current housing expected %s, got %s." % [
			event_id, expected_background, actual_background])
	if event_id == "arc_jaehyuk_ghost_decision" and bool(story.get("_showing_choices")):
		var expected_choices := 3 if GameState.has_item("artifact_jaehyuk_photo") else 2
		var choice_box := story.get("_choice_box") as VBoxContainer
		var actual_choices := 0
		if is_instance_valid(choice_box):
			actual_choices = choice_box.find_children("*", "Button", true, false).size()
		if actual_choices != expected_choices:
			_fail("Jaehyuk ghost expected %d available choices, got %d." % [
				expected_choices, actual_choices])
	if event_id == "arc_jaehyuk_mirror_decision" and bool(story.get("_showing_choices")):
		var timer_row := story.find_child("StoryChoiceCountdown", true, false)
		if timer_row == null or not timer_row.visible:
			_fail("Jaehyuk mirror final choice did not expose its ten-second countdown.")

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
	_assert_demo_pressure_action_illustrations()
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
		GameState.flags["investment_first_visited"] = true
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
		var week_kind := EventManager.narrative_week_kind(GameState.turn)
		if week_kind not in ["decision", "boss"]:
			_fail("Act %d visual fixture is not a direct narrative week: t%d=%s." % [
				act, GameState.turn, week_kind])
			return
		_mg.current_event = {}
		_mg.set("pending_result_text", "")
		if _mg.has_method("_render_ap_actions"):
			_mg.call("_render_ap_actions")
		if _mg.has_method("_refresh_all"):
			_mg.call("_refresh_all")
		if _mg.has_method("_finish_typing"):
			_mg.call("_finish_typing")
		await _settle(0.45)
		if act == 1:
			if _find_demo_pressure_frame(_mg) == null:
				_fail("Act 1 AP surface is missing the demo weekly pressure frame.")
				return
			var primary_count := _demo_pressure_primary_cards().size()
			if primary_count != 3 or _find_demo_pressure_toggle(_mg, false) == null:
				_fail("Act 1 pressure board expected three responses plus Other Actions, got %d." % primary_count)
				return
			if not _assert_demo_decision_stage():
				return
		if act == 2 and _mg.find_child("SeoulMapStrip", true, false) == null:
			_fail("Post-onboarding AP surface did not restore Seoul Trace.")
			return
		await _save("%s%02d_act%d" % [prefix, act, act])
		if act == 1:
			var other_actions := _find_demo_pressure_toggle(_mg, false)
			other_actions.grab_focus()
			await _press_qa_action("ui_accept")
			await _settle(0.35)
			if _mg.find_child("FirstMonthHorizon", true, false) == null \
					or _find_demo_pressure_toggle(_mg, true) == null:
				_fail("Expanded demo action list lost the first-month horizon or return action.")
				return
			await _save("%s01a_all_actions_expanded" % prefix)
			var pressure_back := _find_demo_pressure_toggle(_mg, true)
			pressure_back.grab_focus()
			await _press_qa_action("ui_accept")
			await _settle(0.35)
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
	await _assert_ap_result_lifecycle(lang, prefix)

func _assert_ap_result_lifecycle(lang: String, prefix: String) -> void:
	_seed_ap_act_state(1, lang)
	GameState.flags["arc_intro_meal_seen"] = true
	_mg.current_event = {}
	_mg.set("pending_result_text", "")
	_mg.call("_render_ap_actions")
	_mg.call("_finish_typing")
	await _settle(0.35)

	var other_actions := _find_demo_pressure_toggle(_mg, false)
	if other_actions == null:
		_fail("AP result lifecycle regression could not find Other Actions.")
		return
	other_actions.grab_focus()
	await _press_qa_action("ui_accept")
	await _settle(0.3)
	var money_card: Button = null
	var survival_label := _tr("생계", "Survival Money")
	for candidate in _mg.get("_ap_grid_cards"):
		if candidate is Button and _collect_control_text(candidate).findn(survival_label) >= 0:
			money_card = candidate as Button
			break
	if money_card == null:
		_fail("AP result lifecycle regression could not find the expanded Survival Money card.")
		return
	var money_grid_index := int(money_card.get_meta("ap_grid_index", -1))
	money_card.grab_focus()
	await _press_qa_action("ui_accept")
	await _settle(0.25)
	var modal_root := _mg.get("modal_body") as Control
	var saving_btn: Button = null
	if modal_root != null:
		var saving_label := _tr("저축/절약", "Save/cut back")
		for candidate in modal_root.find_children("*", "Button", true, false):
			var candidate_btn := candidate as Button
			if candidate_btn != null and not candidate_btn.disabled \
					and _collect_control_text(candidate_btn).findn(saving_label) >= 0:
				saving_btn = candidate_btn
				break
	if saving_btn == null:
		_fail("AP result lifecycle regression could not find the Saving action.")
		return
	saving_btn.grab_focus()
	await _press_qa_action("ui_accept")
	await _settle(0.35)
	if not bool(_mg.get("_transient_bg_active")):
		_fail("Saving action discarded its result surface before player confirmation.")
		return
	var choice_root := _mg.get("choice_box") as Control
	var confirm_btn := _find_first_enabled_button(choice_root) if choice_root != null else null
	if confirm_btn == null or confirm_btn.text != _tr("확인", "OK"):
		_fail("Saving action result is missing its confirmation button in %s." % lang)
		return
	await _save(prefix + "06_saving_result_persists", 0.05)

	_mg.call("_finish_typing")
	confirm_btn.grab_focus()
	await _press_qa_action("ui_accept")
	await _settle(0.45)
	var focus_owner := get_viewport().gui_get_focus_owner() as Button
	if focus_owner == null or int(focus_owner.get_meta("ap_grid_index", -1)) != money_grid_index:
		_fail("AP result confirmation did not return focus to the selected parent card.")
		return
	await _save(prefix + "07_saving_focus_returns", 0.05)

func _find_demo_pressure_frame(node: Node) -> Control:
	if node is Control and bool(node.get_meta("demo_pressure_frame", false)):
		return node as Control
	for child in node.get_children():
		var found := _find_demo_pressure_frame(child)
		if found != null:
			return found
	return null

func _find_demo_director_beat(node: Node, expected_turn: int = -1) -> Control:
	if node is Control and not node.is_queued_for_deletion() \
			and node.has_meta("demo_week_kind") and node.has_meta("demo_turn") \
			and (expected_turn < 0 or int(node.get_meta("demo_turn", -1)) == expected_turn):
		return node as Control
	for child in node.get_children():
		var found := _find_demo_director_beat(child, expected_turn)
		if found != null:
			return found
	return null

func _find_demo_pressure_toggle(node: Node, expanded: bool) -> Button:
	if node is Button and bool(node.get_meta("demo_pressure_fallback", false)) \
			and bool(node.get_meta("demo_pressure_expanded", false)) == expanded:
		return node as Button
	for child in node.get_children():
		var found := _find_demo_pressure_toggle(child, expanded)
		if found != null:
			return found
	return null

func _demo_pressure_primary_cards() -> Array[Button]:
	var cards: Array[Button] = []
	if not is_instance_valid(_mg):
		return cards
	for candidate in _mg.get("_ap_grid_cards"):
		if candidate is Button and bool((candidate as Button).get_meta("demo_pressure_primary", false)):
			cards.append(candidate as Button)
	return cards

func _assert_demo_decision_stage() -> bool:
	var cards := _demo_pressure_primary_cards()
	if cards.size() != 3:
		_fail("Demo decision stage does not contain exactly three primary cards.")
		return false
	var first_y := cards[0].position.y
	var previous_x := -INF
	for card in cards:
		if not bool(card.get_meta("demo_decision_card", false)):
			_fail("Demo primary response fell back to the web-list card treatment.")
			return false
		if absf(card.position.y - first_y) > 4.0:
			_fail("Demo responses are not presented on one left/right decision row.")
			return false
		if card.position.x <= previous_x:
			_fail("Demo response order is not spatially left-to-right.")
			return false
		if card.size.y < 220.0:
			_fail("Demo response lost its scene-led card depth (height %.1f)." % card.size.y)
			return false
		previous_x = card.position.x
	return true

func _shot_immersion_loop_surfaces(lang: String = "en", prefix: String = "immersion_en_") -> void:
	_set_qa_language(lang)
	_prepare_main_game_state()
	GameState.turn = 1
	GameState.month = 1
	GameState.week_of_month = 1
	GameState.housing = "gosiwon"
	GameState.current_job = {}
	GameState.monthly_income = 0.0
	GameState.money = 500_000.0
	GameState.flags["arc_intro_meal_seen"] = true
	GameState.flags.erase("arc_intro_dad_seen")
	GameState.recent_action_weeks = [{
		"turn": 0,
		"money": 1,
		"human": 0,
		"places": {"work": {"count": 1, "money": 1, "human": 0}},
	}]
	await _boot_main_game()
	_mg.current_event = {}
	if _mg.has_method("_render_ap_actions"):
		_mg.call("_render_ap_actions")
	if _mg.has_method("_finish_typing"):
		_mg.call("_finish_typing")
	await _settle(0.55)
	var first_text := _collect_control_text(_mg)
	var expected_season := _tr("겨울", "winter")
	var expected_omen := _tr("창원", "Changwon")
	var expected_rent := _tr("월세 D-3주", "RENT D-3W")
	for expected in [expected_season, expected_omen, expected_rent]:
		if first_text.findn(str(expected)) < 0:
			_fail("Immersion AP opening is missing '%s' in %s." % [expected, lang])
			return
	var pressure_frame := _find_demo_pressure_frame(_mg)
	var primary_count := _demo_pressure_primary_cards().size()
	if pressure_frame == null or str(pressure_frame.get_meta("demo_pressure_id", "")) != "employment" \
			or primary_count != 3 or _find_demo_pressure_toggle(_mg, false) == null:
		_fail("Immersion AP opening lost the employment pressure/three-response contract in %s." % lang)
		return
	if not _assert_demo_decision_stage():
		return
	_assert_ap_cards_inside_viewport()
	await _save(prefix + "01_week_opening_omen")

	GameState.week_of_month = 4
	GameState.current_job = {"id": "job_03", "name": _tr("사무직", "Office Worker"), "tier": 2}
	GameState.monthly_income = 2_240_000.0
	GameState.money = -2_100_000.0
	if _mg.has_method("_render_ap_actions"):
		_mg.call("_render_ap_actions")
	if _mg.has_method("_finish_typing"):
		_mg.call("_finish_typing")
	await _settle(0.4)
	var due_text := _collect_control_text(_mg)
	var due_marker := _tr("월세 이번 주", "RENT DUE")
	if due_text.findn(due_marker) < 0:
		_fail("Immersion AP surface is missing the rent deadline in %s." % lang)
		return
	var rent_frame := _find_demo_pressure_frame(_mg)
	if rent_frame == null or str(rent_frame.get_meta("demo_pressure_id", "")) != "rent":
		_fail("Immersion AP surface did not turn an uncovered due week into the rent pressure in %s." % lang)
		return
	_assert_ap_cards_inside_viewport()
	await _save(prefix + "02_rent_due")
	await _dispose_main_game()

	_prepare_main_game_state()
	GameState.current_job = {}
	GameState.monthly_income = 0.0
	GameState.recent_action_weeks = [{
		"turn": GameState.turn - 1,
		"money": 1,
		"human": 0,
		"places": {"work": {"count": 1, "money": 1, "human": 0}},
	}]
	await _shot_story_event("rare_rejection_then_call", prefix + "03_action_causal_frame", "", 0.55, true)

func _shot_motivation_imprint_surfaces(lang: String = "en", prefix: String = "motivation_en_") -> void:
	_set_qa_language(lang)
	await _shot_story_event(
		"story_knee_choice", prefix + "01_knee_identity_choice", "", 0.45, true, true)
	await _shot_story_event(
		"story_last_payment_word", prefix + "02_last_payment_choice", "", 0.45, true, true)
	await _shot_story_event(
		"story_prologue_goal", prefix + "03_notebook_motive_choice", "", 0.45, true, true)

	_prepare_main_game_state()
	GameState.turn = 13
	GameState.month = 4
	GameState.week_of_month = 1
	GameState.flags["notebook_motive_survival"] = true
	await _boot_main_game()
	if _mg.has_method("_render_ap_actions"):
		_mg.call("_render_ap_actions")
	if _mg.has_method("_finish_typing"):
		_mg.call("_finish_typing")
	if _mg.has_method("_refresh_goal_bar"):
		_mg.call("_refresh_goal_bar")
	await _settle(0.45)
	var expected_motive := _tr(
		"다시는 돈 앞에 무릎 꿇지 않는다",
		"I will never kneel before money again.")
	var ap_text := _collect_control_text(_mg)
	if expected_motive not in ap_text:
		_fail("Motivation goal bar lost the chosen sentence in %s." % lang)
		return
	_assert_ap_cards_inside_viewport()
	await _save(prefix + "04_ap_goal_sentence")

	_mg.call("_open_notebook")
	await _settle(0.4)
	var notebook_text := _collect_control_text(_mg.get("modal_body"))
	if expected_motive not in notebook_text:
		_fail("Notebook modal lost the chosen sentence in %s." % lang)
		return
	var expected_father := _tr(
		"아버지는 먼저 전화를 끊지 않는다.",
		"Dad never hangs up first.")
	if expected_father not in notebook_text:
		_fail("Notebook modal lost the father-state line in %s." % lang)
		return
	_assert_modal_no_vertical_overflow("motivation notebook")
	await _save(prefix + "05_notebook_open")

	_mg.call("_close_modal")
	await _settle(0.25)
	var assets_before := float(GameState.get_total_asset_value()) - 420_000.0
	_mg.call("_show_montage_card", 3, assets_before, GameState.health + 1,
		GameState.mental + 2, 2, 1, "routine", 4)
	await _settle(0.4)
	var montage_text := _collect_control_text(_mg.get("modal_body"))
	if expected_motive not in montage_text:
		_fail("Montage card lost the notebook ritual in %s." % lang)
		return
	_assert_modal_no_vertical_overflow("motivation montage")
	await _save(prefix + "06_montage_ritual")

	_mg.call("_close_modal")
	await _settle(0.25)
	GameState.last_month_money_weeks = 2
	GameState.last_month_human_weeks = 1
	var snap := {
		"date": "2026. 4.",
		"monthly_income": GameState.monthly_income,
		"fixed_expense": GameState.get_housing_expense(),
		"assets_before": GameState.get_total_asset_value() - 350_000.0,
		"actions": [],
		"health_before": GameState.health,
		"mental_before": GameState.mental,
	}
	_mg.call("_show_month_summary", snap)
	await _settle(0.5)
	var month_text := _collect_control_text(_mg.get("modal_body"))
	if expected_motive not in month_text:
		_fail("Month summary lost the notebook ritual in %s." % lang)
		return
	var scroll := _mg.get("modal_scroll") as ScrollContainer
	if is_instance_valid(scroll):
		scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
	await _settle(0.25)
	await _save(prefix + "07_month_end_ritual")
	await _dispose_main_game()

func _seed_ap_act_state(act: int, lang: String = "en") -> void:
	GameState.flags.erase("demo_director_kind_turn")
	GameState.flags.erase("demo_director_locked_kind")
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
			GameState.month = 4
			GameState.week_of_month = 1
			GameState.turn = 61
			GameState.money = 8_600_000.0
			GameState.investment_skill = 42
			GameState.action_axis_this_week = {"money": 1, "human": 0}
			GameState.action_places_this_week = {"work": {"count": 1, "money": 1, "human": 0}}
			GameState.recent_action_places = ["home", "store", "work"]
		3:
			GameState.year = 2028
			GameState.month = 5
			GameState.week_of_month = 2
			GameState.turn = 114
			GameState.money = 42_000_000.0
			GameState.investment_skill = 58
			GameState.mental = 49
			GameState.action_axis_this_week = {"money": 2, "human": 0}
			GameState.action_places_this_week = {"underground": {"count": 2, "money": 2, "human": 0}}
			GameState.recent_action_places = ["home", "work", "city", "underground"]
		4:
			GameState.year = 2029
			GameState.month = 5
			GameState.week_of_month = 1
			GameState.turn = 161
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
			GameState.month = 7
			GameState.week_of_month = 1
			GameState.turn = 217
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

func _assert_demo_pressure_action_illustrations() -> void:
	if _mg == null:
		_fail("MainGame instance is unavailable for contextual AP art regression.")
		return
	var cards := _demo_pressure_primary_cards()
	if cards.size() != 3:
		_fail("Contextual AP art check expected exactly three primary cards, found %d." % cards.size())
		return
	var scene_owners := {}
	for card in cards:
		var card_paths: Array[String] = []
		for node in card.find_children("*", "TextureRect", true, false):
			var texture_rect := node as TextureRect
			if texture_rect == null or not (texture_rect.texture is AtlasTexture):
				continue
			var atlas_texture := texture_rect.texture as AtlasTexture
			if atlas_texture.atlas == null:
				continue
			var path := atlas_texture.atlas.resource_path
			if not path.is_empty() and not card_paths.has(path):
				card_paths.append(path)
		var action_id := str(card.get_meta("demo_action_id", card.name))
		if card_paths.size() != 1:
			_fail("Contextual AP card '%s' must own one scene still, found %d (%s)." % [
				action_id, card_paths.size(), ", ".join(card_paths),
			])
			return
		var scene_path := card_paths[0]
		if scene_owners.has(scene_path):
			_fail("Contextual AP cards '%s' and '%s' reuse the same scene still: %s" % [
				str(scene_owners[scene_path]), action_id, scene_path,
			])
			return
		scene_owners[scene_path] = action_id

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
		GameState.flags.erase("investment_first_visited")
		_mg.call("_open_investments")
		await _settle(0.7)
		await _save(prefix + "00_first_guide")
		_mg.call("_open_investments")
		await _settle(0.45)
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
	var conv_slots: Array = node.get("_conv_slot_panels")
	if conv_slots.size() != 3 or not conv_slots.all(func(slot): return slot is Button):
		_fail("Convenience shift did not expose three focusable customer buttons.")
		return
	var focus := get_viewport().gui_get_focus_owner()
	if focus != conv_slots[0]:
		_fail("Convenience shift did not focus the first customer on entry.")
		return
	await _save(prefix + "01_convenience_slots")
	await _press_qa_action("ui_accept")
	await _settle(0.25)
	var action_surface := node.get("_conv_action_vb") as Control
	focus = get_viewport().gui_get_focus_owner()
	if not is_instance_valid(action_surface) or not (focus is Button) or not action_surface.is_ancestor_of(focus):
		_fail("Convenience shift customer selection did not focus a response button.")
		return
	await _save(prefix + "01a_convenience_actions")
	await _press_qa_action("ui_accept")
	await _settle(0.25)
	if int(node.get("_conv_served")) != 1:
		_fail("Convenience shift response input did not serve the selected customer.")
		return
	await _save(prefix + "01b_convenience_result")
	await _settle(0.65)
	focus = get_viewport().gui_get_focus_owner()
	if not conv_slots.has(focus):
		_fail("Convenience shift did not return focus to the customer queue.")
		return
	_hide_aruba_for_qa(node)

	# 응답 선택 중 다른 손님이 떠나도 새 슬롯이 현재 응답 포커스를 빼앗으면 안 된다.
	await _open_aruba_for_qa(node)
	await _press_qa_action("ui_accept")
	await _settle(0.25)
	action_surface = node.get("_conv_action_vb") as Control
	var response_focus := get_viewport().gui_get_focus_owner()
	var patience: Array = node.get("_conv_slot_patience")
	patience[1] = 0.01
	node.set("_conv_slot_patience", patience)
	await _settle(0.7)
	focus = get_viewport().gui_get_focus_owner()
	if focus != response_focus or not is_instance_valid(action_surface) or not action_surface.is_ancestor_of(focus):
		_fail("Convenience shift stole response focus when another customer timed out.")
		return
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
	await _shot_ending_symbol("ordinary_life", prefix + "15a_ending_ordinary_life")
	await _shot_exact_ending_cg("burnout", "cg_ending_burnout", prefix + "15b_ending_burnout")
	await _shot_ending_symbol("mental_break", prefix + "15c_ending_mental_break")
	await _shot_ending_symbol("stable_success", prefix + "15d_ending_stable_success")
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
	await _shot_exact_ending_cg(
			"orthodox_pinnacle", "cg_ending_orthodox_pinnacle", prefix + "16_orthodox_pinnacle")
	await _shot_exact_ending_cg(
			"orthodox_pinnacle", "cg_ending_orthodox_pinnacle", prefix + "17_orthodox_salary_memory",
			["salary_raised"])
	await _shot_exact_ending_cg(
			"burnout", "cg_ending_burnout", prefix + "18_burnout")
	await _shot_ending_without_cg(
			"mental_break", "cg_ending_burnout", prefix + "19_mental_break_no_burnout_cg")

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
	_assert_modal_no_vertical_overflow("month summary")
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
	if st and st.has_method("_set_transition_alpha"):
		st.call("_set_transition_alpha", 0.0)
	elif st and st.has_method("fade_in"):
		st.fade_in()

func _settle(t: float = 0.6) -> void:
	await get_tree().create_timer(t).timeout
	await get_tree().process_frame

func _save(shot_name: String, settle_time: float = 0.3) -> void:
	await _settle(settle_time)
	# The macOS OpenGL readback can expose one partially uploaded atlas frame after
	# a dense AP rerender. Drain several real draw frames before reading pixels.
	for _draw_pass in range(3):
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
	var expected_size := get_window().size
	if Vector2i(img.get_width(), img.get_height()) != expected_size:
		_fail("Screenshot size mismatch for %s: image=%dx%d viewport=%dx%d." % [
			shot_name, img.get_width(), img.get_height(), expected_size.x, expected_size.y])
		return
	var path := "%s/%s.png" % [OUT_DIR, shot_name]
	img.save_png(path)
	print("SHOT %s" % path)

func _fail(msg: String) -> void:
	_qa_failed = true
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
		GameState.flags.erase("investment_first_visited")
		_mg._open_investments()
		await _settle(0.8)
		await _save("02_investment_first_guide")
		_mg._open_investments()
		await _settle(0.45)
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
			await _send_route_key(KEY_X)
			await _settle(0.2)
			await _save(_shot_name(prefix, "10b_blackjack_keyboard_hint"))
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

func _shot_ending_symbol(ending_id: String, shot_name: String) -> void:
	if not _mg.has_method("_show_ending"):
		_fail("MainGame cannot show ending symbol %s" % ending_id)
		return
	_seed_ending_state(ending_id)
	_mg._show_ending(ending_id)
	await _settle(1.0)
	var symbol := _find_ending_symbol(_mg, ending_id)
	var expected_path := "res://assets/ui/ending_symbols/%s.svg" % ending_id
	if symbol == null or symbol.texture == null:
		_fail("Ending %s has no dedicated ending symbol" % ending_id)
		return
	if symbol.texture.resource_path != expected_path:
		_fail("Ending %s symbol mismatch: expected %s, got %s" % [
				ending_id, expected_path, symbol.texture.resource_path])
		return
	if str(symbol.get_meta("ending_symbol_path", "")) != expected_path:
		_fail("Ending %s symbol metadata is stale" % ending_id)
		return
	await _save(shot_name)
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

func _find_ending_symbol(node: Node, ending_id: String) -> TextureRect:
	if node is TextureRect and str(node.get_meta("ending_symbol_id", "")) == ending_id:
		return node as TextureRect
	for child in node.get_children():
		var found := _find_ending_symbol(child, ending_id)
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
			GameState.housing = "apartment"
			GameState.health = 73
			GameState.mental = 79
			GameState.reputation = 70
			GameState.moral_tint = 46.0
			GameState.money_weeks_total = 139
			GameState.human_weeks_total = 101
			GameState.contact_counts = {"daeun": 31}
			GameState.last_contact_turn = {"daeun": 240}
		"jiyeon_man":
			GameState.money = 1_350_000_000.0
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
