extends Node

const TARGET_LANGUAGES: Array[String] = ["ja", "zh-CN", "zh-TW"]
const REPRESENTATIVE_EVENT := "arc_intro_01_meal"
const REPRESENTATIVE_ENDING := "gangnam_dream"
const FONT_PATH := "res://assets/fonts/Pretendard-Regular.ttf"

var _failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	var original_language := LocaleManager.language
	_check_language_codes()
	var english_event := _localized_event_text("en", REPRESENTATIVE_EVENT)
	var english_ending := _localized_ending_text("en", REPRESENTATIVE_ENDING)
	var english_job := _localized_job_name("en", "job_01")
	for lang in TARGET_LANGUAGES:
		_check_target_language(lang, english_event, english_ending, english_job)
	_check_font_coverage()
	LocaleManager.language = original_language
	DataRegistry.reload()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("I18N_INFRASTRUCTURE_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("I18N_INFRASTRUCTURE_CHECK_OK targets=%d ui_fallback=en content_fallback=en" % TARGET_LANGUAGES.size())
	get_tree().quit(0)

func _check_language_codes() -> void:
	_expect(LocaleManager.normalize_language("ja_JP") == "ja", "ja_JP alias did not normalize.")
	_expect(LocaleManager.normalize_language("zh_hans") == "zh-CN", "zh_hans alias did not normalize.")
	_expect(LocaleManager.normalize_language("zh_hant") == "zh-TW", "zh_hant alias did not normalize.")
	for lang in TARGET_LANGUAGES:
		_expect(LocaleManager.is_supported(lang), "%s is not registered as supported." % lang)
		_expect(not LocaleManager.is_shipping_language(lang), "%s became selectable before translation freeze." % lang)

func _check_target_language(lang: String, english_event: String, english_ending: String, english_job: String) -> void:
	_set_language_without_persisting(lang)
	LocaleManager.clear_ui_misses(lang)
	var fallback := LocaleManager.ui("다국어 폴백 검사", "English fallback")
	_expect(fallback == "English fallback", "%s UI miss did not fall back to English." % lang)
	_expect(LocaleManager.get_ui_miss_count(lang) == 1, "%s UI miss was not recorded exactly once." % lang)
	LocaleManager.ui("다국어 폴백 검사", "English fallback")
	_expect(LocaleManager.get_ui_miss_count(lang) == 1, "%s duplicate UI miss was logged twice." % lang)

	_expect(_localized_event_text(lang, REPRESENTATIVE_EVENT) == english_event,
		"%s event skeleton did not inherit the English overlay." % lang)
	_expect(_localized_ending_text(lang, REPRESENTATIVE_ENDING) == english_ending,
		"%s ending skeleton did not inherit the English overlay." % lang)
	_expect(_localized_job_name(lang, "job_01") == english_job,
		"%s catalog skeleton did not inherit the English catalog." % lang)
	_expect(not _contains_hangul(GameState.get_date_string()), "%s date fell back to Korean." % lang)
	_expect(not _contains_hangul(GameState.get_housing_display_name("gosiwon")), "%s housing label fell back to Korean." % lang)
	var money: String = str(GameState.format_money(123_450_000.0))
	_expect(not _contains_hangul(money), "%s money label contains Korean: %s" % [lang, money])
	_expect(not money.contains("¥"), "%s relabeled Korean won as yen/yuan: %s" % [lang, money])

func _localized_event_text(lang: String, event_id: String) -> String:
	_set_language_without_persisting(lang)
	return str(DataRegistry.find_event(event_id).get("description", ""))

func _localized_ending_text(lang: String, ending_id: String) -> String:
	_set_language_without_persisting(lang)
	return str(DataRegistry.get_ending(ending_id).get("description", ""))

func _localized_job_name(lang: String, job_id: String) -> String:
	_set_language_without_persisting(lang)
	return str(DataRegistry.get_job(job_id).get("name", ""))

func _set_language_without_persisting(lang: String) -> void:
	LocaleManager.language = LocaleManager.normalize_language(lang)
	DataRegistry.reload()

func _check_font_coverage() -> void:
	var font = load(FONT_PATH)
	if not font is Font:
		_failures.append("Pretendard font could not be loaded for CJK coverage inspection.")
		return
	var samples := {
		"ja_hiragana": 0x3042,
		"zh_simplified": 0x6C49,
		"zh_traditional": 0x6F22,
	}
	var covered: Array[String] = []
	var missing: Array[String] = []
	for label in samples:
		if font.has_char(int(samples[label])):
			covered.append(str(label))
		else:
			missing.append(str(label))
	print("I18N_FONT_COVERAGE font=Pretendard covered=%s missing=%s shipping_ready=%s" % [
		str(covered), str(missing), str(missing.is_empty())
	])

func _contains_hangul(text: String) -> bool:
	for index in range(text.length()):
		var codepoint := text.unicode_at(index)
		if (codepoint >= 0xAC00 and codepoint <= 0xD7A3) \
				or (codepoint >= 0x1100 and codepoint <= 0x11FF) \
				or (codepoint >= 0x3130 and codepoint <= 0x318F):
			return true
	return false

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
