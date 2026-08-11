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
	_check_ui_context_contract()
	_check_ui_format_contract()
	_check_exact_whole_won_contract()
	_check_explicit_english_money_contract()
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

func _check_ui_context_contract() -> void:
	var original_language := LocaleManager.language
	LocaleManager.clear_ui_misses()
	var ko_text := "문맥 직접\n%s"
	var en_text := "Direct context\n%s"
	LocaleManager.language = "ko"
	_expect(LocaleManager.ui_context("ui.qa.direct", ko_text, en_text) == ko_text,
		"Korean context lookup changed its source argument.")
	_expect(LocaleManager.get_ui_miss_count("ko") == 0,
		"Korean direct context lookup recorded a miss.")
	LocaleManager.language = "en"
	_expect(LocaleManager.ui_context("ui.qa.direct", ko_text, en_text) == en_text,
		"English context lookup changed its fallback argument.")
	_expect(LocaleManager.get_ui_miss_count("en") == 0,
		"English direct context lookup recorded a miss.")

	LocaleManager.language = "ja"
	_expect(LocaleManager.ui("설정", "Settings") == "設定",
		"Existing legacy UI lookup changed after provenance separation.")
	_expect(LocaleManager.ui_context("연락", "설정", "English context") == "連絡",
		"Built-in context key did not win over its legacy fallback key.")
	_expect(LocaleManager.ui_context(
		"ui.qa.no_context", "설정", "English fallback") == "設定",
		"Missing built-in context did not use the legacy Korean key.")
	_expect(LocaleManager.get_ui_miss_count("ja") == 0,
		"Successful built-in context or legacy lookup recorded a miss.")
	var fallback := LocaleManager.ui_context(
		"ui.qa.missing", "문맥 폴백 없음", "Context English fallback")
	_expect(fallback == "Context English fallback",
		"Missing context and legacy keys did not fall back to English.")
	_expect(LocaleManager.get_ui_misses("ja") == ["context:ui.qa.missing"],
		"Context miss was not keyed by its stable ID.")
	LocaleManager.ui_context(
		"ui.qa.missing", "다른 원문", "Second English fallback")
	_expect(LocaleManager.get_ui_miss_count("ja") == 1,
		"Repeated context ID miss was not deduplicated.")
	LocaleManager.refresh_community_packs()
	_expect(LocaleManager.get_ui_miss_count("ja") == 0,
		"Refreshing UI packs did not clear context misses.")
	LocaleManager.language = original_language

func _check_ui_format_contract() -> void:
	var original_language := LocaleManager.language
	LocaleManager.refresh_community_packs()
	var ko_template := "%d년 %d월"
	var en_template := "%04d / %02d"
	LocaleManager.language = "ko"
	_expect(LocaleManager.ui_format(
		ko_template, en_template, [2026, 1], [2026, 1]) == "2026년 1월",
		"Korean formatted UI changed its exact source bytes.")
	LocaleManager.language = "en"
	_expect(LocaleManager.ui_format(
		ko_template, en_template, [2026, 1], [2026, 1]) == "2026 / 01",
		"English formatted UI lost its authored width or bytes.")
	LocaleManager.language = "ko"
	_expect(LocaleManager.ui_format(
		"주차 %d개 남음", "%d %s LEFT", 3, [3, "WEEKS"]) == "주차 3개 남음",
		"Korean formatted UI rejected its valid language-specific arity.")
	LocaleManager.language = "en"
	_expect(LocaleManager.ui_format(
		"주차 %d개 남음", "%d %s LEFT", 3, [3, "WEEKS"]) == "3 WEEKS LEFT",
		"English formatted UI rejected its valid plural argument.")
	for pair in [
		["값 %d", "値 %02d"],
		["값 %d", "値 %-5d"],
		["값 %+d", "値 %+05d"],
		["비율 %.f", "比率 %.0f"],
		["비율 %.2f", "比率 %64.02f"],
	]:
		_expect(LocaleManager._matching_format_contract_error(
			LocaleManager._printf_contract(str(pair[0])),
			LocaleManager._printf_contract(str(pair[1]))).is_empty(),
			"Valid width/alignment/precision form did not match: %s -> %s" \
					% [str(pair[0]), str(pair[1])])
	for pair in [
		["값 %d", "値 %+05d"],
		["값 %d", "値 %x"],
		["비율 %f", "比率 %.f"],
		["비율 %.2f", "比率 %.1f"],
	]:
		_expect(not LocaleManager._matching_format_contract_error(
			LocaleManager._printf_contract(str(pair[0])),
			LocaleManager._printf_contract(str(pair[1]))).is_empty(),
			"Semantic sign/conversion/precision drift matched: %s -> %s" \
					% [str(pair[0]), str(pair[1])])
	for valid_template in [
		"문자 %s", "문자 %c", "정수 %+05d", "8진 %+05o", "16진 %+05x",
		"16진 %+05X", "실수 %+64.12f", "벡터 %.2v", "진행 %% · %02d",
	]:
		_expect(str(LocaleManager._printf_contract(valid_template).get(
			"error", "")).is_empty(),
			"Valid runtime printf grammar was rejected: %s" % valid_template)
	var default_precision := LocaleManager._printf_contract("비율 %f")
	var implicit_zero_precision := LocaleManager._printf_contract("비율 %.f")
	var explicit_zero_precision := LocaleManager._printf_contract("비율 %.0f")
	_expect(not LocaleManager._matching_format_contract_error(
		default_precision, implicit_zero_precision).is_empty(),
		"Default float precision matched an explicit zero-precision target.")
	_expect(LocaleManager._matching_format_contract_error(
		implicit_zero_precision, explicit_zero_precision).is_empty(),
		"Equivalent explicit zero-precision float forms did not match.")

	LocaleManager.language = "ja"
	_expect(LocaleManager.ui_format(
		"슬롯 %d", "Slot %d", 7, 99) == "スロット 7",
		"Built-in formatted UI did not use the stable template or target args.")
	LocaleManager.clear_ui_misses("ja")
	_expect(LocaleManager.ui_format(
		"없는 포맷 %d", "MISSING FORMAT %d", 3, 41) == "MISSING FORMAT 41",
		"Formatted UI miss did not use the English template and English args.")
	LocaleManager.ui_format(
		"없는 포맷 %d", "MISSING FORMAT %d", 9, 42)
	_expect(LocaleManager.get_ui_misses("ja") == ["없는 포맷 %d"],
		"Formatted UI miss was not deduplicated by its stable template.")
	LocaleManager.refresh_community_packs()
	_expect(LocaleManager.get_ui_miss_count("ja") == 0,
		"Refreshing UI packs did not clear formatted-template misses.")

	LocaleManager.language = "en"
	_expect(LocaleManager.ui_format(
		"잘못된 %d", "BROKEN %s", "one", "one") \
			== LocaleManager.UI_FORMAT_ERROR,
		"Korean placeholder/argument kind mismatch did not fail closed.")
	_expect(LocaleManager.ui_format(
		"순서 %d · %s", "ORDER %d · %s", [1, "A"], ["A", 1]) \
			== LocaleManager.UI_FORMAT_ERROR,
		"English placeholder/argument order mismatch did not fail closed.")
	_expect(LocaleManager.ui_format(
		"깨진 %q", "BROKEN %d", 1, 1) == LocaleManager.UI_FORMAT_ERROR,
		"Unsupported source placeholder did not fail closed.")
	for malformed_template in [
		"위치 %1$d", "대체 %#d", "공백 % d", "문자 %+s",
		"정밀 %.2d", "별표 %*d", "정수 %i", "중복 %--10d",
		"빈 왼쪽정렬 %-d", "과폭 %999d", "과폭 실수 %999.2f",
		"과정밀 %.99f", "벡터 %+v", "끝 퍼센트 %", "문자 퍼센트 %🦊",
	]:
		_expect(LocaleManager.ui_format(
			malformed_template, "BROKEN %d", 1, 1) \
				== LocaleManager.UI_FORMAT_ERROR,
			"Malformed same-kind format reached String percent: %s" \
					% malformed_template)
	for invalid_codepoint in [-1, 0xD800, 0x110000]:
		_expect(LocaleManager.ui_format(
			"문자 %c", "CHAR %c", invalid_codepoint, invalid_codepoint) \
				== LocaleManager.UI_FORMAT_ERROR,
			"Invalid Unicode scalar reached String percent: %d" \
					% invalid_codepoint)
	LocaleManager.refresh_community_packs()
	LocaleManager.language = original_language

func _check_exact_whole_won_contract() -> void:
	var original_language := LocaleManager.language
	var expected := {
		"ko": ["123,456원", "-123,456원", "+123,456원", "-123,456원", "0원"],
		"en": ["123,456 won", "-123,456 won", "+KRW 123,456", "-KRW 123,456", "KRW 0"],
		"ja": ["123,456ウォン", "-123,456ウォン", "+123,456ウォン", "-123,456ウォン", "0ウォン"],
		"zh-CN": ["123,456韩元", "-123,456韩元", "+123,456韩元", "-123,456韩元", "0韩元"],
		"zh-TW": ["123,456韓元", "-123,456韓元", "+123,456韓元", "-123,456韓元", "0韓元"],
	}
	for lang in expected:
		LocaleManager.language = str(lang)
		var rows: Array = expected[lang]
		_expect(LocaleManager.format_whole_won(123_456) == rows[0],
			"%s exact whole-won board bytes changed." % lang)
		_expect(LocaleManager.format_whole_won(-123_456) == rows[1],
			"%s exact whole-won board negative bytes changed." % lang)
		_expect(LocaleManager.format_whole_won(123_456, true, true) == rows[2],
			"%s exact whole-won positive-sign bytes changed." % lang)
		_expect(LocaleManager.format_whole_won(-123_456, true, true) == rows[3],
			"%s exact whole-won negative-sign bytes changed." % lang)
		_expect(LocaleManager.format_whole_won(0, true, true) == rows[4],
			"%s exact whole-won zero bytes changed." % lang)
	LocaleManager.language = original_language

func _check_explicit_english_money_contract() -> void:
	var original_language := LocaleManager.language
	var fixtures := [
		[123_450_000.0, false, "123.5 million won"],
		[-1_500.0, false, "-2 thousand won"],
		[123_450_000.0, true, "123.5M won"],
		[999.0, true, "999 won"],
	]
	LocaleManager.language = "en"
	for fixture in fixtures:
		var amount := float(fixture[0])
		var compact := bool(fixture[1])
		var expected := str(fixture[2])
		_expect(LocaleManager.format_money(amount, compact) == expected,
			"Existing English money bytes drifted for %s." % str(amount))
		_expect(LocaleManager.format_money_english(amount, compact) == expected,
			"Explicit English money bytes differ for %s." % str(amount))
	for lang in ["ja", "zh-CN", "zh-TW"]:
		LocaleManager.language = lang
		_expect(LocaleManager.format_money_english(123_450_000.0) \
				== "123.5 million won",
			"%s active locale leaked into an explicit English money arg." % lang)
	LocaleManager.language = original_language

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
