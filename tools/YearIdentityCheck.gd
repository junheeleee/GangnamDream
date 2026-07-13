extends Node
## 다섯 연차의 이름, 실제 장면 큐레이션, 시그니처 시스템을 런타임으로 검증한다.

const MainGameScript = preload("res://scenes/MainGame.gd")
const StoryModeScript = preload("res://scenes/StoryMode.gd")

const SCENE_SAMPLE: Array[String] = [
	"arc_temptation_01",
	"cafe_listen_01",
	"arc_daeun_01_meet",
	"arc_sangchul_01_meet",
	"arc_job_first_rejection",
]

var _failures: Array[String] = []
var _original_language := "ko"

func _ready() -> void:
	_original_language = LocaleManager.language
	_check_chapter_identity()
	_check_year_scene_curation()
	_check_signature_spotlights()
	LocaleManager.language = _original_language
	DataRegistry.reload()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("YEAR_IDENTITY_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("YEAR_IDENTITY_CHECK_OK chapters=5 curated=5 choices=4 localized=2 timed=3 y2=3 y4_cap=3 y5_weeks=48 serialized=1")
	get_tree().quit(0)

func _check_chapter_identity() -> void:
	var expected := {
		"ko": ["생존", "확장", "진실", "무게", "결산"],
		"en": ["Survival", "Expansion", "Truth", "Weight", "Reckoning"],
	}
	for language in ["ko", "en"]:
		LocaleManager.language = language
		DataRegistry.reload()
		for year_index in range(1, 6):
			var event: Dictionary = DataRegistry.find_event("chapter_card_%d" % (32 + year_index))
			var first_line := str(event.get("description", "")).split("\n", false)[0]
			if first_line != expected[language][year_index - 1]:
				_fail("%s chapter %d identity expected=%s actual=%s" % [
					language, year_index, expected[language][year_index - 1], first_line])

func _check_year_scene_curation() -> void:
	LocaleManager.language = "ko"
	DataRegistry.reload()
	GameState.start_new_game()
	var game = MainGameScript.new()
	var selected_ids: Array[String] = []
	for year_index in range(1, 6):
		GameState.turn = (year_index - 1) * 48 + 12
		for scene_id in SCENE_SAMPLE:
			GameState.record_run_scene_seen(scene_id)
		GameState.record_run_scene_seen("chapter_card_%d" % (32 + year_index))
		if year_index <= 4:
			GameState.record_run_scene_seen("arc_year%d_close" % year_index)
		var candidates := GameState.get_year_scene_candidates(year_index, 4)
		if candidates.size() != 4:
			_fail("year %d candidate count expected=4 actual=%d" % [year_index, candidates.size()])
			continue
		for row in candidates:
			if not SCENE_SAMPLE.has(str(row.get("id", ""))):
				_fail("year %d included an unseen or presentation scene: %s" % [year_index, row])
		var expected_curation := "arc_year%d_scene" % year_index
		if game._year_scene_curation_id(year_index) != expected_curation:
			_fail("year %d curation scheduler did not return %s" % [year_index, expected_curation])
		var choices := GameState.build_year_scene_choices(year_index)
		if choices.size() != 4:
			_fail("year %d dynamic choice count expected=4 actual=%d" % [year_index, choices.size()])
			continue
		var chosen: Dictionary = choices[(year_index - 1) % choices.size()]
		var selection: Dictionary = chosen.get("year_scene", {})
		var selected_id := str(selection.get("scene_id", ""))
		var curation_event: Dictionary = DataRegistry.find_event(expected_curation)
		GameState.apply_choice(curation_event, chosen)
		if GameState.get_year_scene_selection(year_index) != selected_id:
			_fail("year %d selected scene was not recorded" % year_index)
		if game._year_scene_curation_id(year_index) != "":
			_fail("year %d curation retriggered after selection" % year_index)
		selected_ids.append(selected_id)

	var saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	for year_index in range(1, 6):
		if GameState.get_year_scene_selection(year_index) != selected_ids[year_index - 1]:
			_fail("year %d selection did not survive serialization" % year_index)
		if GameState.get_year_scene_candidates(year_index, 4).size() != 4:
			_fail("year %d run scene history did not survive serialization" % year_index)

	LocaleManager.language = "en"
	DataRegistry.reload()
	var localized := GameState.get_selected_year_scenes()
	if localized.size() != 5:
		_fail("English selected-scene recap expected=5 actual=%d" % localized.size())
	for row in localized:
		var title := str(row.get("title", ""))
		if title.is_empty() or _contains_hangul(title):
			_fail("English selected-scene title was not localized: %s" % title)
	var recap: Control = game._year_scene_recap_surface()
	if recap == null or str(recap.get_meta("qa_surface", "")) != "year_scene_recap":
		_fail("ending recap surface did not render the five selected scenes")
	elif recap != null:
		recap.free()
	game.free()

func _check_signature_spotlights() -> void:
	LocaleManager.language = "ko"
	DataRegistry.reload()
	var timed_defaults := {
		"arc_temptation_01": 0,
		"cafe_listen_01": 2,
		"arc_rescue_job": 1,
	}
	for event_id in timed_defaults:
		var event: Dictionary = DataRegistry.find_event(event_id)
		if not bool(event.get("timed", false)) or int(event.get("timer_seconds", 0)) < 10:
			_fail("%s is not a readable Y1 timed event" % event_id)
		if int(event.get("timer_default_choice", 0)) != int(timed_defaults[event_id]):
			_fail("%s timeout default is not canonical" % event_id)

	var story = StoryModeScript.new()
	story._current = DataRegistry.find_event("cafe_listen_01")
	story._choice_box = VBoxContainer.new()
	story._start_story_choice_countdown(12, 2)
	if story._choice_countdown_default_index != 2:
		_fail("StoryMode did not preserve the authored timeout default")
	if story._choice_box.get_node_or_null("StoryChoiceCountdown") == null:
		_fail("StoryMode did not build a visible countdown row")
	story._stop_story_choice_countdown()
	story._choice_box.free()
	story.free()

	for event_id in ["inv_real_estate_bubble_fear", "inv_crypto_mania", "inv_ipo_hot_tip"]:
		var event: Dictionary = DataRegistry.find_event(event_id)
		var conditions: Dictionary = event.get("conditions", {})
		if int(conditions.get("min_turn", 0)) != 49 or int(conditions.get("max_turn", 0)) != 96:
			_fail("%s is not locked to the Y2 expansion window" % event_id)

	var game = MainGameScript.new()
	GameState.turn = 145
	if game._montage_week_cap() != 3:
		_fail("Y4 montage cap is not three weeks")
	if not str(game._montage_offer_copy().get("title", "")).contains("접히기"):
		_fail("Y4 montage offer lacks the folding-time identity")
	var y4_ticks: Control = game._montage_week_ticks(3, 3)
	if y4_ticks.get_child_count() != 3:
		_fail("Y4 montage result did not render exactly three week ticks")
	if not game._montage_reason_line("cap", 3).contains("3주"):
		_fail("Y4 montage result still describes a four-week cap")
	y4_ticks.free()
	GameState.turn = 100
	if game._montage_week_cap() != 4:
		_fail("non-Y4 montage cap changed from four weeks")
	GameState.turn = 193
	GameState.age = 37
	GameState.month = 1
	var time_ko: Dictionary = game._goal_time_display()
	if not str(time_ko.get("text", "")).contains("48주"):
		_fail("Korean Y5 HUD did not switch to 48 weeks: %s" % time_ko)
	GameState.flags = {}
	GameState.current_job = {}
	GameState.mental = 70
	GameState.money = 5_000_000.0
	GameState.addiction_tendency = 0
	if game._get_month_narrative().is_empty():
		_fail("Y5 month close has no calendar narration fallback")
	LocaleManager.language = "en"
	DataRegistry.reload()
	var time_en: Dictionary = game._goal_time_display()
	if str(time_en.get("text", "")) != "48 wk left":
		_fail("English Y5 HUD did not localize the week countdown: %s" % time_en)
	game.free()

func _contains_hangul(text: String) -> bool:
	var regex := RegEx.new()
	regex.compile("[가-힣]")
	return regex.search(text) != null

func _fail(message: String) -> void:
	_failures.append(message)
