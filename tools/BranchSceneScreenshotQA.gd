extends "res://tools/ScreenshotQA.gd"
## QA 2026-11-27: the scenes PR #44 made reachable (free-week habits, the
## father-passed rock bottom, the eight easter eggs, the years 3-4 investment
## and gambling beats) had passed data checks but no one had seen them on
## screen. Captures each scene's first page and its choices in KO and EN at
## the window size it is run with (Steam Deck: 1280x800).
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x800 \
##     res://tools/BranchSceneScreenshotQA.tscn
## Output: $GANGNAM_QA_OUT or /tmp/gangnamdream_qa, one PNG per shot.

const BRANCH_SCENES := [
	["habit_race_saturday", 60], ["habit_race_regular", 70],
	["habit_holdem_night", 80], ["habit_holdem_regular", 90],
	["habit_casino_trip", 100], ["habit_casino_regular", 110],
	["habit_portfolio_check", 60], ["habit_portfolio_regular", 140],
	["gambling_rock_bottom", 60], ["gambling_rock_bottom_father_passed", 200],
	["egg_deja_vu", 80], ["egg_veteran_return", 120], ["egg_triangle_kimbap", 54],
	["egg_4am_clarity", 90], ["egg_gambling_mirror", 100], ["egg_gosiwon_sage", 136],
	["egg_honest_paradox", 110], ["egg_quiet_rich", 150],
	["market_crash_panic", 120], ["sangchul_tip_warning", 110],
	["unorthodox_gray_zone_tip", 115], ["orthodox_institutional_access", 125],
	["drama_addiction_mirror", 105], ["drama_addiction_warning", 108],
	["race_big_win", 112], ["holdem_big_pot", 118], ["holdem_bad_beat", 122],
	["holdem_losing_streak", 126], ["jeongseon_big_win_urge", 130],
	["jeongseon_big_loss_bus", 134],
]


func _ready() -> void:
	OS.low_processor_usage_mode = false
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	_clear_output_dir()
	for lang in ["ko", "en"]:
		for index in range(BRANCH_SCENES.size()):
			var event_id := str(BRANCH_SCENES[index][0])
			var turn := int(BRANCH_SCENES[index][1])
			var name := "%s_%02d_%s" % [lang, index, event_id]
			_set_qa_language(lang)
			_prepare_branch_state(event_id, turn)
			await _shot_story_event(event_id, name + "_a_page", "", 0.45, true)
			if _qa_failed:
				return
			_set_qa_language(lang)
			_prepare_branch_state(event_id, turn)
			await _shot_story_event(event_id, name + "_b_choices", "", 0.45, true, true)
			if _qa_failed:
				return
	print("BRANCH_SCENE_SCREENSHOT_QA_DONE shots=%d dir=%s" % [BRANCH_SCENES.size() * 4, OUT_DIR])
	get_tree().quit(0)


func _prepare_branch_state(event_id: String, turn: int) -> void:
	_prepare_main_game_state()
	GameState.turn = turn
	GameState.age = 33 + int((turn - 1) / 48)
	GameState.month = ((turn - 1) / 4) % 12 + 1
	GameState.week_of_month = (turn - 1) % 4 + 1
	GameState.current_job = {"id": "office_contract", "name": "사무 계약직"}
	if event_id.ends_with("_father_passed"):
		GameState.flags["father_passed"] = true
