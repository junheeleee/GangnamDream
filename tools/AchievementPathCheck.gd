extends Node
## 15개 업적의 카탈로그·번역·실제 해금 경로를 실행한다.

const MainGameScript = preload("res://scenes/MainGame.gd")
const EXPECTED_IDS: Array[String] = [
	"beat_addiction",
	"dawn_people",
	"drawer_truth",
	"first_billion",
	"five_lives",
	"four_seasons",
	"gangnam_dream",
	"investment_master",
	"kept_evidence",
	"political_fix",
	"reputation_legend",
	"stable_life",
	"startup_exit",
	"survived_burnout",
	"ten_lives",
]
const HIDDEN_IDS: Array[String] = [
	"four_seasons",
	"kept_evidence",
	"drawer_truth",
	"dawn_people",
]

var _failures: Array[String] = []
var _original_language := "en"
var _had_meta_file := false
var _original_meta_text := ""

func _ready() -> void:
	_had_meta_file = FileAccess.file_exists(MetaProgression.META_SAVE_PATH)
	if _had_meta_file:
		_original_meta_text = FileAccess.get_file_as_string(MetaProgression.META_SAVE_PATH)
	_original_language = LocaleManager.language
	_check_catalog_contract()
	_check_unknown_and_legacy_ids()
	_check_summary_paths()
	_check_flag_paths()
	_check_direct_hidden_paths()
	_restore_meta_file()
	LocaleManager.language = _original_language
	DataRegistry.reload()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("ACHIEVEMENT_PATH_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("ACHIEVEMENT_PATH_CHECK_OK catalog=15 paths=15 hidden=4")
	get_tree().quit(0)

func _restore_meta_file() -> void:
	if _had_meta_file:
		var file := FileAccess.open(MetaProgression.META_SAVE_PATH, FileAccess.WRITE)
		if file == null:
			_fail("could not restore the pre-check meta file")
			return
		file.store_string(_original_meta_text)
		file.close()
		var restored = JSON.parse_string(_original_meta_text)
		if restored is Dictionary:
			MetaProgression.data = restored
		return
	var absolute_path := ProjectSettings.globalize_path(MetaProgression.META_SAVE_PATH)
	if FileAccess.file_exists(MetaProgression.META_SAVE_PATH):
		DirAccess.remove_absolute(absolute_path)
	MetaProgression.data = DataRegistry.default_meta.duplicate(true)

func _check_catalog_contract() -> void:
	var catalog_ids: Array[String] = []
	for achievement in DataRegistry.achievements:
		var achievement_id := str(achievement.get("id", ""))
		if achievement_id.is_empty():
			_fail("catalog contains an empty id")
			continue
		if catalog_ids.has(achievement_id):
			_fail("catalog contains duplicate id %s" % achievement_id)
		catalog_ids.append(achievement_id)
		for field in ["name", "description", "hint"]:
			if str(achievement.get(field, "")).strip_edges().is_empty():
				_fail("catalog %s has empty %s" % [achievement_id, field])
	_assert_id_set("catalog", catalog_ids, EXPECTED_IDS)

	var indexed_ids: Array[String] = []
	for raw_id in DataRegistry.achievements_by_id.keys():
		indexed_ids.append(str(raw_id))
	_assert_id_set("catalog index", indexed_ids, EXPECTED_IDS)

	var english_ids: Array[String] = []
	for raw_id in DataRegistry.ACHIEVEMENT_TEXT_EN.keys():
		var achievement_id := str(raw_id)
		english_ids.append(achievement_id)
		var text: Dictionary = DataRegistry.ACHIEVEMENT_TEXT_EN[raw_id]
		for field in ["name", "description", "hint"]:
			if str(text.get(field, "")).strip_edges().is_empty():
				_fail("English dictionary %s has empty %s" % [achievement_id, field])
	_assert_id_set("English dictionary", english_ids, EXPECTED_IDS)
	_assert_id_set("hidden achievement contract", HIDDEN_IDS, ["four_seasons", "kept_evidence", "drawer_truth", "dawn_people"])

	var game = MainGameScript.new()
	for lang in ["ko", "en"]:
		LocaleManager.language = lang
		DataRegistry.reload()
		for achievement_id in EXPECTED_IDS:
			var catalog: Dictionary = DataRegistry.get_achievement(achievement_id)
			var displayed := game._achievement_display_name(achievement_id)
			if displayed != str(catalog.get("name", "")) or displayed == achievement_id:
				_fail("%s ending nameplate diverges for %s" % [lang, achievement_id])
			if lang == "en":
				var expected_en := str(DataRegistry.ACHIEVEMENT_TEXT_EN[achievement_id].get("name", ""))
				if displayed != expected_en:
					_fail("English nameplate is not sourced from dictionary for %s" % achievement_id)
	game.free()
	LocaleManager.language = _original_language
	DataRegistry.reload()

func _check_unknown_and_legacy_ids() -> void:
	_reset_progression()
	if MetaProgression.unlock_achievement("white_gangnam"):
		_fail("unknown legacy id white_gangnam was accepted")
	if not MetaProgression.get_unlocked_achievements().is_empty():
		_fail("unknown achievement polluted the collection")

	var stale := DataRegistry.default_meta.duplicate(true)
	stale["achievements"] = ["white_gangnam", "five_lives", "clean_gangnam", "five_lives", "future_unknown"]
	var file := FileAccess.open(MetaProgression.META_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		_fail("could not create legacy meta fixture")
		return
	file.store_string(JSON.stringify(stale))
	file.close()
	MetaProgression.load_meta()
	_assert_id_set("migrated meta", _string_array(MetaProgression.get_unlocked_achievements()), ["five_lives"])

func _check_summary_paths() -> void:
	_assert_record_run("first_billion", {"total_assets": 100_000_000.0}, ["first_billion"])
	_assert_record_run("stable_life/stable_success", {"ending_id": "stable_success"}, ["stable_life"])
	_assert_record_run("stable_life/ordinary_life", {"ending_id": "ordinary_life"}, ["stable_life"])
	_assert_record_run("gangnam_dream", {"ending_id": "gangnam_dream"}, ["gangnam_dream"])
	_assert_record_run("gangnam_dream_white", {"ending_id": "gangnam_dream_white"}, ["gangnam_dream"])
	_assert_record_run("survived_burnout/burnout", {"ending_id": "burnout"}, ["survived_burnout"])
	_assert_record_run("survived_burnout/mental_break", {"ending_id": "mental_break"}, ["survived_burnout"])
	_assert_record_run("startup_exit", {"ending_id": "startup_exit"}, ["startup_exit"])
	_assert_record_run("political_fix", {"ending_id": "political_fix"}, ["political_fix"])
	_assert_record_run("investment_master", {"ending_id": "investment_master"}, ["investment_master"])
	_assert_record_run("reputation_legend", {"ending_id": "reputation_legend"}, ["reputation_legend"])
	_assert_record_run("five_lives", {}, ["five_lives"], 4)
	_assert_record_run("ten_lives", {}, ["five_lives", "ten_lives"], 9)

func _check_flag_paths() -> void:
	_reset_progression()
	GameState.flags["beat_addiction"] = true
	MetaProgression.record_run({})
	_assert_id_set("beat_addiction flags", _unlocked_ids(), ["beat_addiction"])

	_reset_progression()
	var game = MainGameScript.new()
	var season_cases := [
		{"month": 4, "event": "arc_season_cherry_daeun"},
		{"month": 7, "event": "arc_season_sea_daeun"},
		{"month": 9, "event": "arc_season_fireworks_daeun"},
		{"month": 12, "event": "arc_season_snow_daeun"},
	]
	for season in season_cases:
		GameState.month = int(season["month"])
		var event_id: String = game._season_date_id("daeun")
		if event_id != str(season["event"]):
			_fail("season producer returned %s instead of %s" % [event_id, season["event"]])
	var serialized_flags: Dictionary = GameState.serialize().get("flags", {})
	for flag in ["last_cherry_date_year", "last_sea_date_year", "last_fireworks_date_year", "last_snow_date_year"]:
		if int(serialized_flags.get(flag, 0)) <= 0:
			_fail("season flag %s did not survive serialization" % flag)
	MetaProgression.record_run({})
	_assert_id_set("four_seasons flags", _unlocked_ids(), ["four_seasons"])
	game.free()

	var evidence_sources := _events_with_choice_flag("presented_artifact_correct")
	if evidence_sources.size() < 3:
		_fail("presented_artifact_correct has only %d event choice sources" % evidence_sources.size())
	_reset_progression()
	GameState.flags["presented_artifact_correct"] = true
	if not bool(GameState.serialize().get("flags", {}).get("presented_artifact_correct", false)):
		_fail("presented_artifact_correct did not survive serialization")
	MetaProgression.record_run({})
	_assert_id_set("kept_evidence flags", _unlocked_ids(), ["kept_evidence"])

func _check_direct_hidden_paths() -> void:
	_reset_progression()
	var game = MainGameScript.new()
	for _i in range(4):
		game._daeun_dawn_line()
	if MetaProgression.is_achievement_unlocked("dawn_people"):
		_fail("dawn_people unlocked before the fifth meeting")
	game._daeun_dawn_line()
	_assert_id_set("dawn_people direct path", _unlocked_ids(), ["dawn_people"])
	if int(GameState.flags.get("daeun_dawn_meetings", 0)) != 5 or not GameState.flags.get("daeun_dawn_deep_seen", false):
		_fail("dawn_people flags did not reach their terminal state")

	_reset_progression()
	game._unlock_drawer_truth_achievement()
	_assert_id_set("drawer_truth direct path", _unlocked_ids(), ["drawer_truth"])
	game.free()

func _assert_record_run(label: String, summary: Dictionary, expected: Array, initial_runs: int = 0) -> void:
	_reset_progression(initial_runs)
	MetaProgression.record_run(summary)
	_assert_id_set(label, _unlocked_ids(), expected)

func _reset_progression(total_runs: int = 0) -> void:
	GameState.start_new_game()
	MetaProgression.data = DataRegistry.default_meta.duplicate(true)
	MetaProgression.data["total_runs"] = total_runs
	MetaProgression._new_this_run = {"achievements": []}

func _events_with_choice_flag(flag: String) -> Array[String]:
	var event_ids: Array[String] = []
	for event in DataRegistry.events:
		for choice in event.get("choices", []):
			var flags: Array = choice.get("flags", [])
			if flags.has(flag):
				var event_id := str(event.get("id", ""))
				if not event_ids.has(event_id):
					event_ids.append(event_id)
	return event_ids

func _unlocked_ids() -> Array[String]:
	return _string_array(MetaProgression.get_unlocked_achievements())

func _string_array(values: Array) -> Array[String]:
	var out: Array[String] = []
	for value in values:
		out.append(str(value))
	return out

func _assert_id_set(label: String, actual_values: Array, expected_values: Array) -> void:
	var actual := _string_array(actual_values)
	var expected := _string_array(expected_values)
	actual.sort()
	expected.sort()
	if actual != expected:
		_fail("%s expected=%s actual=%s" % [label, expected, actual])

func _fail(message: String) -> void:
	_failures.append(message)
