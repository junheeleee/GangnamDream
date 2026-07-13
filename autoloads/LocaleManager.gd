extends Node
## 언어 설정 관리자. 출시 언어와 번역 준비 언어를 분리하고, 준비 언어의
## 미번역 표면은 영어로 안전하게 폴백한다.

var language: String = "en"

const SUPPORTED_LANGUAGES: Array[String] = ["ko", "en", "ja", "zh-CN", "zh-TW"]
const SHIPPING_LANGUAGES: Array[String] = ["ko", "en"]
const UI_TABLE_PATH := "res://locale/ui_%s.json"

var _ui_tables: Dictionary = {}
var _ui_misses: Dictionary = {}

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
	_sync_player_name(lang)
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
	_sync_player_name(normalized)
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
	return normalize_language(lang) in SUPPORTED_LANGUAGES

func is_shipping_language(lang: String) -> bool:
	return normalize_language(lang) in SHIPPING_LANGUAGES

## 주인공 이름이 기본값이면 새 언어 기본값으로 교체 (유저가 직접 지은 이름은 건드리지 않음)
func _sync_player_name(lang: String) -> void:
	var gs = get_node_or_null("/root/GameState")
	if gs == null:
		return
	var cur := str(gs.player_name)
	if cur == DEFAULT_NAME_KO or cur == DEFAULT_NAME_EN:
		gs.player_name = DEFAULT_NAME_KO if normalize_language(lang) == "ko" else DEFAULT_NAME_EN

func sync_player_name_for_current_language() -> void:
	_sync_player_name(language)

func localize_player_name(raw_name: String) -> String:
	if raw_name in [DEFAULT_NAME_KO, DEFAULT_NAME_EN]:
		return DEFAULT_NAME_KO if is_korean() else DEFAULT_NAME_EN
	return raw_name

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
	var table := _get_ui_table(language)
	if table.has(ko_text):
		return str(table[ko_text])
	_record_ui_miss(language, ko_text)
	return en_text

func _get_ui_table(lang: String) -> Dictionary:
	if _ui_tables.has(lang):
		return _ui_tables[lang]
	var table: Dictionary = {}
	var path := UI_TABLE_PATH % lang
	if FileAccess.file_exists(path):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
		if parsed is Dictionary:
			table = parsed
		else:
			push_warning("Invalid UI locale dictionary: %s" % path)
	_ui_tables[lang] = table
	return table

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
