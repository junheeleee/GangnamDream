extends Node
## 언어 설정 관리자. 출시 언어와 번역 준비 언어를 분리하고, 준비 언어의
## 미번역 표면은 영어로 안전하게 폴백한다.

var language: String = "en"

const SUPPORTED_LANGUAGES: Array[String] = ["ko", "en", "ja", "zh-CN", "zh-TW"]
const SHIPPING_LANGUAGES: Array[String] = ["ko", "en"]
const UI_TABLE_PATH := "res://locale/ui_%s.json"
const UI_FORMAT_ERROR := "[I18N FORMAT ERROR]"
const UI_FORMAT_MAX_WIDTH := 64
const UI_FORMAT_MAX_PRECISION := 12

var _builtin_ui_tables: Dictionary = {}
var _community_ui_tables: Dictionary = {}
var _ui_misses: Dictionary = {}
var _ui_format_errors: Dictionary = {}

# 주인공 기본 이름 — 언어 전환 시 다른 언어 기본값으로 동기화 (커스텀 이름은 보존)
const DEFAULT_NAME_KO := "김민준"
const DEFAULT_NAME_EN := "Kim Minjun"

signal language_changed(lang: String)

func _ready() -> void:
	# SaveManager는 오토로드 순서상 뒤에 로드 — 첫 프레임 후 안전하게 읽는다.
	call_deferred("_load_saved_language")

func _load_saved_language() -> void:
	var sm = get_node_or_null("/root/SaveManager")
	if sm == null:
		return
	var saved = sm.get_setting("language", "en")
	var lang := normalize_language(str(saved))
	if not is_supported(lang):
		lang = "en"
	var changed := lang != language
	language = lang
	_sync_player_name()
	if changed:
		language_changed.emit(lang)
		DataRegistry.reload()

func set_language(lang: String) -> void:
	var normalized := normalize_language(lang)
	if not is_supported(normalized):
		return
	var changed := normalized != language
	language = normalized
	SaveManager.set_setting("language", normalized)
	_sync_player_name()
	if changed:
		language_changed.emit(normalized)
		DataRegistry.reload()

func normalize_language(raw_language: String) -> String:
	var normalized := raw_language.strip_edges().replace("_", "-")
	match normalized.to_lower():
		"ko", "ko-kr", "kr":
			return "ko"
		"en", "en-us", "en-gb":
			return "en"
		"ja", "ja-jp", "jp":
			return "ja"
		"zh", "zh-cn", "zh-hans", "cn":
			return "zh-CN"
		"zh-tw", "zh-hant", "tw":
			return "zh-TW"
	return normalized

func is_supported(lang: String) -> bool:
	var normalized := normalize_language(lang)
	return normalized in SUPPORTED_LANGUAGES or ModLoader.has_language_pack(normalized)

func is_shipping_language(lang: String) -> bool:
	return normalize_language(lang) in SHIPPING_LANGUAGES

func get_selectable_languages() -> Array[String]:
	var result: Array[String] = SHIPPING_LANGUAGES.duplicate()
	for code in ModLoader.discover_language_codes():
		if code not in result:
			result.append(code)
	return result

func get_language_display_name(lang: String) -> String:
	var normalized := normalize_language(lang)
	match normalized:
		"ko":
			return "한국어"
		"en":
			return "English"
		"ja":
			return "日本語"
		"zh-CN":
			return "简体中文"
		"zh-TW":
			return "繁體中文"
	if ModLoader.has_language_pack(normalized):
		var info := ModLoader.language_pack_info(normalized)
		return str(info.get("native_name", info.get("name", normalized)))
	return normalized

## 주인공 이름이 기본값이면 새 언어 기본값으로 교체 (유저가 직접 지은 이름은 건드리지 않음)
func _sync_player_name() -> void:
	var gs = get_node_or_null("/root/GameState")
	if gs == null:
		return
	var cur := str(gs.player_name)
	if _is_default_player_name(cur):
		gs.player_name = ui(DEFAULT_NAME_KO, DEFAULT_NAME_EN)

func sync_player_name_for_current_language() -> void:
	_sync_player_name()

func localize_player_name(raw_name: String) -> String:
	if _is_default_player_name(raw_name):
		return ui(DEFAULT_NAME_KO, DEFAULT_NAME_EN)
	return raw_name

func _is_default_player_name(raw_name: String) -> bool:
	if raw_name in [DEFAULT_NAME_KO, DEFAULT_NAME_EN]:
		return true
	var known_languages: Array[String] = SUPPORTED_LANGUAGES.duplicate()
	for discovered in ModLoader.discover_language_codes():
		if discovered not in known_languages:
			known_languages.append(discovered)
	for lang in known_languages:
		if lang in ["ko", "en"]:
			continue
		var localized_name: Variant = _lookup_legacy_ui(lang, DEFAULT_NAME_KO)
		if localized_name != null and raw_name == str(localized_name):
			return true
	return false

## 레거시 KO/EN 분기를 위한 이름이다. 준비 언어는 번역이 비어 있는 동안
## 반드시 영어 표면을 사용해야 하므로 non-KO 전체를 true로 취급한다.
func is_english() -> bool:
	return language != "ko"

func is_exact_english() -> bool:
	return language == "en"

func is_korean() -> bool:
	return language == "ko"

## 기존 2인자 호출부를 유지한다. 준비 언어는 한국어 원문을 안정적인 키로
## 사용하며, 미스 시 영어를 반환해 한국어가 외국어 플레이에 새지 않게 한다.
func ui(ko_text: String, en_text: String) -> String:
	if language == "ko":
		return ko_text
	if language == "en":
		return en_text
	var localized: Variant = _lookup_legacy_ui(language, ko_text)
	if localized != null:
		return str(localized)
	_record_ui_miss(language, ko_text)
	return en_text

## 다의 source string은 안정 context ID를 먼저 조회한다. community pack의
## 기존 한국어 키가 built-in context보다 앞서야 구형 pack의 override가 보존된다.
func ui_context(context_id: String, ko_text: String, en_text: String) -> String:
	if language == "ko":
		return ko_text
	if language == "en":
		return en_text
	var builtin := _get_builtin_ui_table(language)
	var community := _get_community_ui_table(language)
	if community.has(context_id):
		return str(community[context_id])
	if community.has(ko_text):
		return str(community[ko_text])
	if builtin.has(context_id):
		return str(builtin[context_id])
	if builtin.has(ko_text):
		return str(builtin[ko_text])
	_record_ui_miss(language, "context:%s" % context_id)
	return en_text

## Stable templates must be translated before values are inserted. For a prepared
## language, a translated legacy template uses the target-language arguments
## supplied by the caller; a dictionary miss uses the English template and its
## English arguments. Contract errors never reach String's `%` operator.
func ui_format(
		ko_template: String,
		en_template: String,
		ko_args: Variant,
		en_args: Variant,
	) -> String:
	var ko_contract := _printf_contract(ko_template)
	var en_contract := _printf_contract(en_template)
	var ko_template_error := str(ko_contract.get("error", ""))
	if not ko_template_error.is_empty():
		return _reject_ui_format(
			ko_template, "Korean template: %s" % ko_template_error)
	var en_template_error := str(en_contract.get("error", ""))
	if not en_template_error.is_empty():
		return _reject_ui_format(
			ko_template, "English template: %s" % en_template_error)
	var ko_values := _format_values(ko_args)
	var en_values := _format_values(en_args)
	var ko_args_error := _format_args_error(ko_contract, ko_values)
	if not ko_args_error.is_empty():
		return _reject_ui_format(ko_template, "Korean args: %s" % ko_args_error)
	var en_args_error := _format_args_error(en_contract, en_values)
	if not en_args_error.is_empty():
		return _reject_ui_format(ko_template, "English args: %s" % en_args_error)

	if language == "ko":
		return _apply_checked_format(ko_template, ko_values)
	if language == "en":
		return _apply_checked_format(en_template, en_values)

	var localized: Variant = _lookup_legacy_ui(language, ko_template)
	if localized == null:
		_record_ui_miss(language, ko_template)
		return _apply_checked_format(en_template, en_values)
	var localized_template := str(localized)
	var localized_contract := _printf_contract(localized_template)
	var localized_error := _matching_format_contract_error(
		ko_contract, localized_contract)
	if not localized_error.is_empty():
		return _reject_ui_format(ko_template, "localized %s: %s" % [
			language, localized_error,
		])
	return _apply_checked_format(localized_template, ko_values)

func _printf_contract(template: String) -> Dictionary:
	var placeholders: Array[String] = []
	var semantic_modifiers: Array[String] = []
	var index := 0
	while index < template.length():
		if template.unicode_at(index) != 0x25: # %
			index += 1
			continue
		if index + 1 < template.length() \
				and template.unicode_at(index + 1) == 0x25:
			index += 2
			continue
		var start := index
		index += 1
		var sign_codepoint := -1
		if index < template.length() \
				and template.unicode_at(index) in [0x2B, 0x2D]: # + -
			sign_codepoint = template.unicode_at(index)
			index += 1
		var width_start := index
		while index < template.length() \
				and _is_ascii_digit(template.unicode_at(index)):
			index += 1
		var has_width := index > width_start
		if has_width and int(template.substr(width_start, index - width_start)) \
				> UI_FORMAT_MAX_WIDTH:
			return {
				"placeholders": placeholders,
				"newlines": template.count("\n"),
				"error": "width exceeds %d at character %d" % [
					UI_FORMAT_MAX_WIDTH, start],
			}
		var has_precision := false
		var precision_start := -1
		var precision_value := -1
		if index < template.length() and template.unicode_at(index) == 0x2E: # .
			has_precision = true
			index += 1
			precision_start = index
			while index < template.length() \
					and _is_ascii_digit(template.unicode_at(index)):
				index += 1
			precision_value = 0 if index == precision_start \
				else int(template.substr(precision_start, index - precision_start))
			if precision_value > UI_FORMAT_MAX_PRECISION:
				return {
					"placeholders": placeholders,
					"newlines": template.count("\n"),
					"error": "precision exceeds %d at character %d" % [
						UI_FORMAT_MAX_PRECISION, start],
				}
		if index >= template.length() \
				or not _is_ascii_letter(template.unicode_at(index)):
			return {
				"placeholders": placeholders,
				"newlines": template.count("\n"),
				"error": "invalid percent sequence at character %d" % start,
			}
		var conversion := template.substr(index, 1)
		if conversion not in ["s", "c", "d", "o", "x", "X", "f", "v"]:
			return {
				"placeholders": placeholders,
				"newlines": template.count("\n"),
				"error": "unsupported conversion %%%s" % conversion,
			}
		if sign_codepoint == 0x2B and conversion not in ["d", "o", "x", "X", "f"]:
			return {
				"placeholders": placeholders,
				"newlines": template.count("\n"),
				"error": "+ modifier is invalid for %%%s" % conversion,
			}
		if sign_codepoint == 0x2D and not has_width:
			return {
				"placeholders": placeholders,
				"newlines": template.count("\n"),
				"error": "- modifier requires a width for %%%s" % conversion,
			}
		if has_precision and conversion not in ["f", "v"]:
			return {
				"placeholders": placeholders,
				"newlines": template.count("\n"),
				"error": "precision is invalid for %%%s" % conversion,
			}
		# KO and EN are validated independently. A localized target may change
		# width/zero-padding, but conversion order, explicit positive sign, and
		# precision remain semantic. Godot treats `%.f` as explicit precision 0.
		placeholders.append(conversion)
		var semantic_sign := "+" if sign_codepoint == 0x2B else ""
		var semantic_precision := ""
		if has_precision:
			semantic_precision = str(precision_value)
		semantic_modifiers.append(
			"%s|%s|%s" % [conversion, semantic_sign, semantic_precision])
		index += 1
	return {
		"placeholders": placeholders,
		"semantic_modifiers": semantic_modifiers,
		"newlines": template.count("\n"),
		"error": "",
	}

func _matching_format_contract_error(
		left: Dictionary,
		right: Dictionary,
	) -> String:
	var left_error := str(left.get("error", ""))
	if not left_error.is_empty():
		return "source %s" % left_error
	var right_error := str(right.get("error", ""))
	if not right_error.is_empty():
		return "target %s" % right_error
	if left.get("placeholders", []) != right.get("placeholders", []):
		return "placeholder signature mismatch %s != %s" % [
			str(left.get("placeholders", [])),
			str(right.get("placeholders", [])),
		]
	if left.get("semantic_modifiers", []) != right.get("semantic_modifiers", []):
		return "placeholder modifier mismatch %s != %s" % [
			str(left.get("semantic_modifiers", [])),
			str(right.get("semantic_modifiers", [])),
		]
	if int(left.get("newlines", 0)) != int(right.get("newlines", 0)):
		return "newline mismatch %d != %d" % [
			int(left.get("newlines", 0)), int(right.get("newlines", 0)),
		]
	return ""

func _format_values(raw_args: Variant) -> Array:
	if raw_args is Array:
		return (raw_args as Array).duplicate()
	return [raw_args]

func _format_args_error(contract: Dictionary, values: Array) -> String:
	var placeholders: Array = contract.get("placeholders", [])
	if placeholders.size() != values.size():
		return "placeholder/argument count %d != %d" % [
			placeholders.size(), values.size(),
		]
	for index in range(placeholders.size()):
		var conversion := str(placeholders[index])
		var value: Variant = values[index]
		if conversion in ["d", "o", "x", "X"] \
				and typeof(value) not in [TYPE_INT, TYPE_FLOAT]:
			return "%%%s requires a number at %d" % [conversion, index]
		if conversion == "c":
			if typeof(value) == TYPE_INT:
				var codepoint := int(value)
				if codepoint < 0 or codepoint > 0x10FFFF \
						or (codepoint >= 0xD800 and codepoint <= 0xDFFF):
					return "%%c requires a Unicode scalar at %d" % index
			elif typeof(value) != TYPE_STRING or str(value).length() != 1:
				return "%%c requires an int or one-character String at %d" % index
		if conversion == "f" and typeof(value) not in [TYPE_INT, TYPE_FLOAT]:
			return "%%%s requires number at %d" % [conversion, index]
		if conversion == "v" and typeof(value) not in [
				TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_VECTOR3I,
				TYPE_VECTOR4, TYPE_VECTOR4I,
			]:
			return "%%v requires a vector at %d" % index
	return ""

func _apply_checked_format(template: String, values: Array) -> String:
	if values.is_empty():
		return template.replace("%%", "%")
	if values.size() == 1:
		return template % values[0]
	return template % values

func _reject_ui_format(ko_template: String, reason: String) -> String:
	var diagnostic_key := "%s\u001f%s\u001f%s" % [language, ko_template, reason]
	if not _ui_format_errors.has(diagnostic_key):
		_ui_format_errors[diagnostic_key] = true
		push_warning("I18N_UI_FORMAT_REJECT lang=%s key=%s reason=%s" % [
			language, ko_template, reason,
		])
	return UI_FORMAT_ERROR

func _is_ascii_digit(codepoint: int) -> bool:
	return codepoint >= 0x30 and codepoint <= 0x39

func _is_ascii_letter(codepoint: int) -> bool:
	return (codepoint >= 0x41 and codepoint <= 0x5A) \
		or (codepoint >= 0x61 and codepoint <= 0x7A)

func _lookup_legacy_ui(lang: String, source_text: String) -> Variant:
	var builtin := _get_builtin_ui_table(lang)
	var community := _get_community_ui_table(lang)
	if community.has(source_text):
		return str(community[source_text])
	if builtin.has(source_text):
		return str(builtin[source_text])
	return null

func _get_builtin_ui_table(lang: String) -> Dictionary:
	if _builtin_ui_tables.has(lang):
		return _builtin_ui_tables[lang]
	var table: Dictionary = {}
	var path := UI_TABLE_PATH % lang
	if FileAccess.file_exists(path):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
		if parsed is Dictionary:
			table = parsed
		else:
			push_warning("Invalid UI locale dictionary: %s" % path)
	_builtin_ui_tables[lang] = table
	return table

func _get_community_ui_table(lang: String) -> Dictionary:
	if _community_ui_tables.has(lang):
		return _community_ui_tables[lang]
	var table: Dictionary = {}
	var community_path := ModLoader.language_ui_path(lang)
	if not community_path.is_empty() and FileAccess.file_exists(community_path):
		var community: Variant = JSON.parse_string(FileAccess.get_file_as_string(community_path))
		if community is Dictionary:
			for key in (community as Dictionary).keys():
				var value: Variant = (community as Dictionary)[key]
				if key is String and value is String:
					table[str(key)] = str(value)
		else:
			push_warning("Invalid community UI locale dictionary: %s" % community_path)
	_community_ui_tables[lang] = table
	return table

func refresh_community_packs() -> void:
	_builtin_ui_tables.clear()
	_community_ui_tables.clear()
	_ui_misses.clear()
	_ui_format_errors.clear()

func _record_ui_miss(lang: String, source_text: String) -> void:
	if not _ui_misses.has(lang):
		_ui_misses[lang] = {}
	var misses: Dictionary = _ui_misses[lang]
	if misses.has(source_text):
		return
	misses[source_text] = true
	print_verbose("I18N_UI_MISS lang=%s key=%s" % [lang, source_text])

func clear_ui_misses(lang: String = "") -> void:
	if lang.is_empty():
		_ui_misses.clear()
	else:
		_ui_misses.erase(normalize_language(lang))

func get_ui_misses(lang: String = "") -> Array[String]:
	var target := language if lang.is_empty() else normalize_language(lang)
	var result: Array[String] = []
	var misses: Dictionary = _ui_misses.get(target, {})
	for key in misses.keys():
		result.append(str(key))
	result.sort()
	return result

func get_ui_miss_count(lang: String = "") -> int:
	return get_ui_misses(lang).size()

## Exact decision-surface formatter. Callers settle their own whole-won rounding
## before entry; the two legacy surfaces differ only in positive-sign and English
## prefix policy. Every language keeps Korean-won identity and exact commas.
func format_whole_won(
		amount: int,
		show_positive_sign: bool = false,
		english_krw_prefix: bool = false,
	) -> String:
	var sign_text := "-" if amount < 0 else ("+" if show_positive_sign and amount > 0 else "")
	var digits := str(absi(amount))
	var insert_at := digits.length() - 3
	while insert_at > 0:
		digits = digits.insert(insert_at, ",")
		insert_at -= 3
	match language:
		"ko":
			return "%s%s원" % [sign_text, digits]
		"ja":
			return "%s%sウォン" % [sign_text, digits]
		"zh-CN":
			return "%s%s韩元" % [sign_text, digits]
		"zh-TW":
			return "%s%s韓元" % [sign_text, digits]
	if english_krw_prefix:
		return "%sKRW %s" % [sign_text, digits]
	return "%s%s won" % [sign_text, digits]

## 게임 경제는 모든 언어에서 한국 원화다. 엔/위안 기호로 단순 치환하면
## 금액의 실질 가치가 바뀌므로, 현지 큰수 단위를 쓰되 원화 정체성을 보존한다.
func format_money(amount: float, compact: bool = false) -> String:
	var sign := "-" if amount < 0.0 else ""
	var value := absf(amount)
	match language:
		"ko":
			if value >= 100_000_000.0:
				return "%s%.1f억원" % [sign, value / 100_000_000.0]
			if value >= 10_000.0:
				return "%s%.0f만원" % [sign, value / 10_000.0]
			return "%s%.0f원" % [sign, value]
		"ja":
			if value >= 100_000_000.0:
				return "%s%.1f億ウォン" % [sign, value / 100_000_000.0]
			if value >= 10_000.0:
				return "%s%.0f万ウォン" % [sign, value / 10_000.0]
			return "%s%.0fウォン" % [sign, value]
		"zh-CN":
			if value >= 100_000_000.0:
				return "%s%.1f亿韩元" % [sign, value / 100_000_000.0]
			if value >= 10_000.0:
				return "%s%.0f万韩元" % [sign, value / 10_000.0]
			return "%s%.0f韩元" % [sign, value]
		"zh-TW":
			if value >= 100_000_000.0:
				return "%s%.1f億韓元" % [sign, value / 100_000_000.0]
			if value >= 10_000.0:
				return "%s%.0f萬韓元" % [sign, value / 10_000.0]
			return "%s%.0f韓元" % [sign, value]
	return _format_money_english_value(sign, value, compact)

## Builds an English money argument without mutating the active language. This
## is for ui_format()'s English fallback args when the active locale is prepared.
func format_money_english(amount: float, compact: bool = false) -> String:
	var sign := "-" if amount < 0.0 else ""
	return _format_money_english_value(sign, absf(amount), compact)

func _format_money_english_value(
		sign: String,
		value: float,
		compact: bool,
	) -> String:
	if compact:
		if value >= 1_000_000_000.0:
			return "%s%.1fB won" % [sign, value / 1_000_000_000.0]
		if value >= 1_000_000.0:
			return "%s%.1fM won" % [sign, value / 1_000_000.0]
		if value >= 1_000.0:
			return "%s%.0fK won" % [sign, value / 1_000.0]
		return "%s%.0f won" % [sign, value]
	if value >= 1_000_000_000.0:
		return "%s%.1f billion won" % [sign, value / 1_000_000_000.0]
	if value >= 1_000_000.0:
		return "%s%.1f million won" % [sign, value / 1_000_000.0]
	if value >= 1_000.0:
		return "%s%.0f thousand won" % [sign, value / 1_000.0]
	return "%s%.0f won" % [sign, value]
