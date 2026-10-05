extends Node
## Prepared resolver test: no rendered Main, natural play or human observation.
const LOCALES := ["ko", "en", "ja", "zh-CN", "zh-TW"]
const MAIN = preload("res://scenes/MainGame.gd")
# Only the final recording side effect is replaced. The real inherited
# check_game_over, asset calculation, precedence and >= branches all execute.
# This off-tree prepared state is not a natural route or a recorded run.
class EndingSelectionProbe extends "res://autoloads/GameState.gd":
	var selected_ending := ""

	func finish_run(ending_id):
		selected_ending = str(ending_id)
		is_game_over = true

const THRESHOLD_ENDINGS := ["stable_success", "orthodox_pinnacle", "unorthodox_legend"]
const THRESHOLD_VARIANTS := {
	"stable_success": [],
	"orthodox_pinnacle": ["salary_raised", "salary_denied", "credit_asserted",
		"credit_recognized", "jobswitch_reconnected", "declined_golf", "extreme_frugal",
		"frugal_quiet", "skipped_staycation", "ignored_mystery_info", "orthodox_wavered"],
	"unorthodox_legend": ["cafe_double_jackpot", "coin_second_win", "holdem_high_stakes_win",
		"own_path_solidified", "investigating_gray_contact", "gray_tip_debt_paid"],
}
const INCLUSIVE_PHRASES := {
	"ko": ["10억 이상", "10억 이상", "5억 이상"],
	"en": ["at least one billion won", "at least one billion won", "at least five hundred million won"],
	"ja": ["10億ウォン以上", "10億ウォン以上", "5億ウォン以上"],
	"zh-CN": ["至少10亿韩元", "至少有10亿韩元", "至少5亿韩元"],
	"zh-TW": ["至少10億韓元", "至少有10億韓元", "至少5億韓元"],
}
var failures: Array[String] = []
var cases := 0
var boundary_cases := 0
var inclusive_leaves := 0

func _ready() -> void:
	call_deferred("_run")

func _check(game: Node, ending: Dictionary, locale: String, life: String,
		known: String, expected: String) -> void:
	GameState.flags = {} if known.is_empty() else {known: true}
	GameState.cast = {"father": {"stage": "distant", "affinity": 40, "met": true, "flags": {}}}
	if life == "father_passed" or life == "arc_father_passing_seen":
		GameState.flags[life] = true
	elif life == "cast_passed":
		GameState.cast["father"]["stage"] = "passed"
	var before_flags: Dictionary = GameState.flags.duplicate(true)
	var before_cast: Dictionary = GameState.cast.duplicate(true)
	var result: String = game.call("_resolved_ending_description", ending)
	var passed: bool = result == expected and not result.is_empty() \
		and before_flags == GameState.flags and before_cast == GameState.cast
	cases += 1
	if not passed:
		failures.append("%s/%s/%s/%s" % [locale, ending.get("id"), life, known])
	print("PR31_ENDING_CASE=" + JSON.stringify({"locale": locale, "ending": ending.get("id"),
		"life": life, "known": known, "passed": passed, "state_unchanged":
		before_flags == GameState.flags and before_cast == GameState.cast}))

func _check_thresholds(game: Node, locale: String) -> void:
	for index in range(THRESHOLD_ENDINGS.size()):
		var ending_id: String = THRESHOLD_ENDINGS[index]
		var threshold := 500_000_000.0 if ending_id == "unorthodox_legend" else 1_000_000_000.0
		for scenario: Array in [[38, -1], [38, 0], [38, 1], [37, 0]]:
			var probe := EndingSelectionProbe.new()
			probe.age = int(scenario[0])
			probe.turn = 240 if probe.age == 38 else 239
			probe.money = threshold + float(scenario[1])
			probe.peak_asset = probe.money
			probe.portfolio = {}
			probe.loans = {"bank": 0.0, "second": 0.0}
			probe.flags = {}
			probe.cast = {}
			probe.relationships = []
			probe.health = 50
			probe.mental = 50
			probe.reputation = 10
			probe.investment_skill = 12
			# A real catalog job excludes early_retirement without inventing one.
			if DataRegistry.jobs.is_empty():
				failures.append(locale + "/boundary missing job catalog")
			else:
				probe.current_job = DataRegistry.jobs[0].duplicate(true)
			probe.route_orthodox = 15 if ending_id == "orthodox_pinnacle" else 0
			probe.route_unorthodox = 15 if ending_id == "unorthodox_legend" else 0
			var actual_assets: float = probe.get_total_asset_value()
			var expected := "" if probe.age == 37 else (
				"ordinary_life" if int(scenario[1]) < 0 else ending_id)
			probe.check_game_over()
			var passed: bool = probe.selected_ending == expected \
				and probe.is_game_over == (not expected.is_empty()) \
				and actual_assets == threshold + float(scenario[1])
			boundary_cases += 1
			if not passed:
				failures.append("%s/%s/age%d/delta%d/selected=%s" % [locale, ending_id,
					probe.age, int(scenario[1]), probe.selected_ending])
			print("PR31_ENDING_BOUNDARY_CASE=" + JSON.stringify({"locale": locale,
				"ending": ending_id, "age": probe.age, "assets": actual_assets,
				"delta": scenario[1], "expected": expected,
				"selected": probe.selected_ending, "passed": passed}))
			probe.free()
		var ending: Dictionary = DataRegistry.get_ending(ending_id)
		var variants: Dictionary = ending.get("description_if_known", {})
		var expected_flags: Array = THRESHOLD_VARIANTS[ending_id]
		if ending_id != "stable_success":
			var actual_flags: Array = variants.keys()
			var sorted_expected := expected_flags.duplicate()
			actual_flags.sort()
			sorted_expected.sort()
			if actual_flags != sorted_expected:
				failures.append(locale + "/" + ending_id + "/variant population differs")
		for known in [""] + expected_flags:
			var text: String = str(ending.get("description", "")) if str(known).is_empty() \
				else str(variants.get(str(known), ""))
			var phrase: String = INCLUSIVE_PHRASES[locale][index]
			if text.to_lower().count(phrase.to_lower()) != 1:
				failures.append(locale + "/" + ending_id + "/" + str(known) + "/inclusive amount missing")
			_check(game, ending, locale, "alive", str(known), text)
			inclusive_leaves += 1

func _run() -> void:
	var qa_namespace468 := OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	if not qa_namespace468.begins_with("GangnamDream_StoryNameplateQA_") \
		or OS.get_user_data_dir().get_file() != qa_namespace468:
		push_error("PR31_ENDING_CHECK_FAIL pre-autoload isolation missing")
		get_tree().quit(1)
		return
	print("STORY_NAMEPLATE_QA_USER_DIR=" + OS.get_user_data_dir())
	var old_language: String = LocaleManager.language
	var old_flags: Dictionary = GameState.flags
	var old_cast: Dictionary = GameState.cast
	var old_state: Dictionary = GameState.serialize().duplicate(true)
	var old_meta: Dictionary = MetaProgression.data.duplicate(true)
	var game: Node = MAIN.new()
	var expected_cases := 0
	for locale: String in LOCALES:
		LocaleManager.set_language(locale)
		var empty: Dictionary = DataRegistry.get_ending("empty_house")
		var variants: Dictionary = empty.get("description_if_known", {})
		if variants.is_empty() or str(empty.get("description", "")).is_empty():
			failures.append(locale + "/empty_house missing authored text")
		for life: String in ["alive", "father_passed", "arc_father_passing_seen", "cast_passed"]:
			for known in [""] + variants.keys():
				# A true death flag is terminal evidence, never an alive case.
				if life == "alive" and str(known) in ["father_passed", "arc_father_passing_seen"]:
					continue
				var expected: String = str(empty.get("description", ""))
				if life != "alive":
					for flag in variants:
						if str(flag) == str(known) or str(flag) == life:
							expected = str(variants[flag])
							break
				_check(game, empty, locale, life, str(known), expected)
				expected_cases += 1
		# All other authored reconciliation endings retain their previous policy:
		# live Father may call/visit, any terminal evidence suppresses that variant.
		for ending: Dictionary in DataRegistry.endings:
			if str(ending.get("id", "")) == "empty_house":
				continue
			var known: Dictionary = ending.get("description_if_known", {})
			if not known.has("father_reconciled"):
				continue
			for life: String in ["alive", "father_passed", "arc_father_passing_seen", "cast_passed"]:
				_check(game, ending, locale, life, "father_reconciled",
					str(known["father_reconciled"]) if life == "alive" else str(ending.get("description", "")))
				expected_cases += 1
		_check_thresholds(game, locale)
		expected_cases += 20
	game.free()
	GameState.flags = old_flags
	GameState.cast = old_cast
	LocaleManager.set_language(old_language)
	if GameState.serialize() != old_state or MetaProgression.data != old_meta:
		failures.append("singleton GameState/MetaProgression changed by prepared fixture")
	await get_tree().process_frame
	if not failures.is_empty() or cases != expected_cases or cases < 100 \
		or boundary_cases != 60 or inclusive_leaves != 100:
		for failure: String in failures:
			push_error("PR31_ENDING_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("PR31_ENDING_CHECK_OK locales=5 prepared_component_only=true")
	print("PR31_ENDING_BOUNDARY_CHECK_OK locales=5 selector_cases=60 authored_leaves=100 prepared_component_only=true")
	print("PR31_ENDING_CASE_COUNT=" + str(cases))
	get_tree().quit(0)
