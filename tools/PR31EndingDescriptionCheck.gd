extends Node
## Prepared resolver test: no rendered Main, natural play or human observation.
const LOCALES := ["ko", "en", "ja", "zh-CN", "zh-TW"]
const MAIN = preload("res://scenes/MainGame.gd")
var failures: Array[String] = []
var cases := 0

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

func _run() -> void:
	var qa_namespace468 := OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	if not qa_namespace468.begins_with("GangnamDream_StoryNameplateQA_") \
		or OS.get_user_data_dir().get_file() != qa_namespace468:
		push_error("PR31_ENDING_CHECK_FAIL pre-autoload isolation missing")
		get_tree().quit(1)
		return
	print("STORY_NAMEPLATE_QA_USER_DIR=" + OS.get_user_data_dir())
	var old_language: String = LocaleManager.language
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
	game.free()
	LocaleManager.set_language(old_language)
	await get_tree().process_frame
	if not failures.is_empty() or cases != expected_cases or cases < 100:
		for failure: String in failures:
			push_error("PR31_ENDING_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("PR31_ENDING_CHECK_OK locales=5 prepared_component_only=true")
	print("PR31_ENDING_CASE_COUNT=" + str(cases))
	get_tree().quit(0)
