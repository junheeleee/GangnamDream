extends Node

const TARGET_LANGUAGES: Array[String] = ["ja", "zh-CN", "zh-TW"]
const REPRESENTATIVE_EVENT := "arc_intro_01_meal"
const REPRESENTATIVE_TRANSLATED_EVENT := "story_prologue_goal"
const REPRESENTATIVE_ENDING := "gangnam_dream"
const REPRESENTATIVE_JA_JOB := "コンビニ夜勤スタッフ"
const FONT_PATH := "res://assets/fonts/Pretendard-Regular.ttf"
const ZH_FONT_SAMPLES := {
	"zh-CN": [0x6C49, 0x8BED, 0x94B1, 0x95E8, 0x540E, 0x3002], # 汉语钱门后。
	"zh-TW": [0x6F22, 0x8A9E, 0x9322, 0x9580, 0x5F8C, 0x3002], # 漢語錢門後。
}

var _failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	var original_language := LocaleManager.language
	_check_language_codes()
	_check_existing_translated_overlay()
	var english_event := _localized_event_text("en", REPRESENTATIVE_EVENT)
	var english_ending := _localized_ending_text("en", REPRESENTATIVE_ENDING)
	var english_job := _localized_job_name("en", "job_01")
	for lang in TARGET_LANGUAGES:
		_check_target_language(lang, english_event, english_ending, english_job)
	_check_font_coverage()
	_check_chinese_font_routes()
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

func _check_existing_translated_overlay() -> void:
	var expected := _locale_event_overlay_text(
		"ja", REPRESENTATIVE_TRANSLATED_EVENT, "description")
	var english := _localized_event_text("en", REPRESENTATIVE_TRANSLATED_EVENT)
	var localized := _localized_event_text("ja", REPRESENTATIVE_TRANSLATED_EVENT)
	_expect(not expected.is_empty(),
		"Japanese translated-overlay runtime fixture is missing.")
	_expect(localized == expected and localized != english,
		"Existing Japanese event overlay did not win over English fallback.")
	_expect(not _contains_hangul(localized),
		"Existing Japanese event overlay contains Korean.")

func _check_target_language(lang: String, english_event: String, english_ending: String, english_job: String) -> void:
	_set_language_without_persisting(lang)
	LocaleManager.clear_ui_misses(lang)
	var fallback := LocaleManager.ui("다국어 폴백 검사", "English fallback")
	_expect(fallback == "English fallback", "%s UI miss did not fall back to English." % lang)
	_expect(LocaleManager.get_ui_miss_count(lang) == 1, "%s UI miss was not recorded exactly once." % lang)
	LocaleManager.ui("다국어 폴백 검사", "English fallback")
	_expect(LocaleManager.get_ui_miss_count(lang) == 1, "%s duplicate UI miss was logged twice." % lang)

	var localized_event := _localized_event_text(lang, REPRESENTATIVE_EVENT)
	var expected_event := _locale_event_overlay_text(
		lang, REPRESENTATIVE_EVENT, "description")
	if expected_event.is_empty():
		_expect(localized_event == english_event,
			"%s event skeleton did not inherit the English overlay." % lang)
	else:
		_expect(localized_event == expected_event,
			"%s event translation did not win over the English overlay." % lang)
		_expect(not _contains_hangul(localized_event),
			"%s translated event contains Korean." % lang)
	var localized_ending := _localized_ending_text(lang, REPRESENTATIVE_ENDING)
	var expected_ending := _locale_ending_overlay_text(
		lang, REPRESENTATIVE_ENDING, "description")
	if expected_ending.is_empty():
		_expect(localized_ending == english_ending,
			"%s ending skeleton did not inherit the English overlay." % lang)
	else:
		_expect(localized_ending == expected_ending,
			"%s ending translation did not win over the English overlay." % lang)
		_expect(not _contains_hangul(localized_ending),
			"%s translated ending contains Korean." % lang)
	var localized_job := _localized_job_name(lang, "job_01")
	var expected_job := _locale_catalog_overlay_text(
		lang, "jobs", "job_01", "name")
	if not expected_job.is_empty():
		_expect(localized_job == expected_job,
			"%s catalog translation did not win over the English overlay." % lang)
		_expect(localized_job != english_job and not _contains_hangul(localized_job),
			"%s catalog representative job fell back to English or Korean." % lang)
		if lang == "ja":
			_expect(localized_job == REPRESENTATIVE_JA_JOB,
				"Japanese representative job changed outside its locked translation.")
	else:
		_expect(localized_job == english_job,
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

func _locale_event_overlay_text(
	lang: String, event_id: String, field: String,
) -> String:
	var directory_path := "res://content/events_%s" % lang
	var directory := DirAccess.open(directory_path)
	if directory == null:
		return ""
	directory.list_dir_begin()
	var filename := directory.get_next()
	while not filename.is_empty():
		if filename.ends_with(".json"):
			var parsed: Variant = JSON.parse_string(
				FileAccess.get_file_as_string(directory_path.path_join(filename)))
			if parsed is Array:
				for raw_event in parsed:
					if raw_event is Dictionary and str(raw_event.get("id", "")) == event_id:
						return str(raw_event.get(field, ""))
		filename = directory.get_next()
	directory.list_dir_end()
	return ""

func _locale_ending_overlay_text(
	lang: String, ending_id: String, field: String,
) -> String:
	var path := "res://content/endings_%s.json" % lang
	if not FileAccess.file_exists(path):
		return ""
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Array:
		return ""
	for raw_ending in parsed:
		if raw_ending is Dictionary and str(raw_ending.get("id", "")) == ending_id:
			return str(raw_ending.get(field, ""))
	return ""

func _locale_catalog_overlay_text(
	lang: String, section: String, row_id: String, field: String,
) -> String:
	var path := "res://locale/catalog_%s.json" % lang
	if not FileAccess.file_exists(path):
		return ""
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		return ""
	var rows: Variant = parsed.get(section, {})
	if not rows is Dictionary:
		return ""
	var row: Variant = rows.get(row_id, {})
	if not row is Dictionary:
		return ""
	return str(row.get(field, ""))

func _set_language_without_persisting(lang: String) -> void:
	LocaleManager.language = LocaleManager.normalize_language(lang)
	DataRegistry.reload()

func _check_font_coverage() -> void:
	var font = load(FONT_PATH)
	if not font is Font:
		_failures.append("Pretendard font could not be loaded for CJK coverage inspection.")
		return
	FontKit.attach_locale_fallbacks(font)
	var samples := {
		"ja_hiragana": 0x3042,
		"ja_katakana": 0x30AA,
		"ja_kanji": 0x6F22,
		"ja_punctuation": 0x300C,
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
	var jp_ready := ["ja_hiragana", "ja_katakana", "ja_kanji", "ja_punctuation"].all(
		func(label): return label in covered)
	print("I18N_FONT_COVERAGE base=Pretendard fallback=NotoSansJP covered=%s missing=%s ja_ready=%s" % [
		str(covered), str(missing), str(jp_ready)
	])
	_expect(jp_ready, "Bundled Japanese fallback is missing required glyph classes.")

func _check_chinese_font_routes() -> void:
	for lang in ["zh-CN", "zh-TW"]:
		var path := FontKit.dedicated_locale_font_path(lang)
		var primary: Font = null
		if not path.is_empty() and ResourceLoader.exists(path):
			primary = load(path)
		var covered := 0
		var required: int = ZH_FONT_SAMPLES[lang].size()
		if primary != null:
			for codepoint in ZH_FONT_SAMPLES[lang]:
				if primary.has_char(int(codepoint)):
					covered += 1
		var jp_first := FontKit.shared_han_jp_first(lang)
		var ready := primary != null and covered == required and not jp_first
		print("ZH_FONT_ROUTE lang=%s primary=%s shared_han_jp_first=%d glyphs=%d/%d status=%s" % [
			lang,
			path if not path.is_empty() else "missing",
			1 if jp_first else 0,
			covered,
			required,
			"ready" if ready else "blocked",
		])
		if not ready:
			_expect(not LocaleManager.is_shipping_language(lang),
				"%s is shipping without a dedicated Chinese font route." % lang)

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
