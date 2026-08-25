extends Node
class_name FontKit
## 폰트 유틸 — locale별 primary와 프로젝트 소유 폴백을 한 체인으로 묶어
## 플랫폼별 OS 폰트 선택 차이를 제거한다. KO/EN은 Pretendard, 일본어와
## 중국어는 Noto Sans JP/SC/TC의 같은 웨이트, 이모지는 Noto Color Emoji를 사용한다.
##
## 문제: Pretendard(.ttf)에는 이모지 글리프가 없다. 폴백을 안 걸면 Godot이 OS
##       폰트를 들쭉날쭉 골라 써서, 어떤 이모지(예: 🤝 U+1F91D, 2016)는 안 나오고
##       플랫폼마다 결과가 달라진다.
## 시도1(실패): SystemFont("Apple Color Emoji" 등) 폴백 → has_char는 true지만
##       런타임 렌더링엔 안 쓰여서 🤝가 여전히 안 나왔다.
## 해결: NotoColorEmoji.ttf 를 직접 번들하고 FontFile 폴백으로 건다. 실제 폰트
##       파일이라 렌더링에 확실히 사용되고, 모든 플랫폼에서 동일하게 보인다.

const EMOJI_FONT_PATH := "res://assets/fonts/NotoColorEmoji.ttf"
const JP_FONT_PATH := "res://assets/fonts/NotoSansJP-Variable.ttf"
const ZH_CN_FONT_PATH := "res://assets/fonts/NotoSansSC-Variable.ttf"
const ZH_TW_FONT_PATH := "res://assets/fonts/NotoSansTC-Variable.ttf"
const PRETENDARD_REGULAR_PATH := "res://assets/fonts/Pretendard-Regular.ttf"
const PRETENDARD_SEMIBOLD_PATH := "res://assets/fonts/Pretendard-SemiBold.ttf"
const PRETENDARD_BOLD_PATH := "res://assets/fonts/Pretendard-Bold.ttf"

const WEIGHT_REGULAR := 400
const WEIGHT_SEMIBOLD := 600
const WEIGHT_BOLD := 700

static var _emoji_font: FontFile = null
static var _jp_font: FontFile = null
static var _locale_fonts: Dictionary = {}
static var _pretendard_fonts: Dictionary = {}
static var _jp_variations: Dictionary = {}
static var _locale_variations: Dictionary = {}
static var _ui_fonts: Dictionary = {}
static var _active_language := "en"

static func _get_emoji_font() -> FontFile:
	if _emoji_font == null and ResourceLoader.exists(EMOJI_FONT_PATH):
		var res = load(EMOJI_FONT_PATH)
		if res is FontFile:
			_emoji_font = res
	return _emoji_font

static func _get_jp_font() -> FontFile:
	if _jp_font == null and ResourceLoader.exists(JP_FONT_PATH):
		var res = load(JP_FONT_PATH)
		if res is FontFile:
			_jp_font = res
	return _jp_font

static func _get_locale_font(language: String) -> FontFile:
	var normalized := _normalize_language(language)
	if normalized == "ja":
		return _get_jp_font()
	if _locale_fonts.has(normalized):
		return _locale_fonts[normalized] as FontFile
	var path := dedicated_locale_font_path(normalized)
	var result: FontFile = null
	if not path.is_empty() and ResourceLoader.exists(path):
		result = load(path) as FontFile
	_locale_fonts[normalized] = result
	return result

static func _get_pretendard_font(weight: int) -> FontFile:
	if _pretendard_fonts.has(weight):
		return _pretendard_fonts[weight] as FontFile
	var path := PRETENDARD_REGULAR_PATH
	match weight:
		WEIGHT_SEMIBOLD:
			path = PRETENDARD_SEMIBOLD_PATH
		WEIGHT_BOLD:
			path = PRETENDARD_BOLD_PATH
	var result: FontFile = null
	if ResourceLoader.exists(path):
		result = load(path) as FontFile
	_pretendard_fonts[weight] = result
	return result

static func _get_jp_variation(weight: int) -> FontVariation:
	if _jp_variations.has(weight):
		return _jp_variations[weight] as FontVariation
	var result := FontVariation.new()
	result.base_font = _get_jp_font()
	var text_server := TextServerManager.get_primary_interface()
	result.variation_opentype = {text_server.name_to_tag("wght"): weight}
	_jp_variations[weight] = result
	return result

static func _get_locale_variation(language: String, weight: int) -> FontVariation:
	var normalized := _normalize_language(language)
	if normalized == "ja":
		return _get_jp_variation(weight)
	var key := "%s:%d" % [normalized, weight]
	if _locale_variations.has(key):
		return _locale_variations[key] as FontVariation
	var result := FontVariation.new()
	result.base_font = _get_locale_font(normalized)
	var text_server := TextServerManager.get_primary_interface()
	result.variation_opentype = {text_server.name_to_tag("wght"): weight}
	_locale_variations[key] = result
	return result

static func _append_fallback(font: Font, fallback: Font) -> void:
	if fallback == null:
		return
	var fallbacks: Array[Font] = font.fallbacks
	if not fallbacks.has(fallback):
		fallbacks.append(fallback)
		font.fallbacks = fallbacks

static func _normalize_language(language: String) -> String:
	var normalized := language.strip_edges().replace("_", "-").to_lower()
	if normalized in ["ja", "ja-jp", "jp"]:
		return "ja"
	if normalized in ["ko", "ko-kr", "kr"]:
		return "ko"
	if normalized in ["en", "en-us", "en-gb"]:
		return "en"
	if normalized in ["zh", "zh-cn", "zh-hans", "cn"]:
		return "zh-CN"
	if normalized in ["zh-tw", "zh-hant", "tw"]:
		return "zh-TW"
	return language

static func _ensure_ui_fonts() -> void:
	if not _ui_fonts.is_empty():
		return
	for weight in [WEIGHT_REGULAR, WEIGHT_SEMIBOLD, WEIGHT_BOLD]:
		_ui_fonts[weight] = FontVariation.new()
	configure_language(_active_language)

## Stable role resources are shared by every scene. Their internals change when
## the locale changes, so already-built Controls and custom drawing code switch
## together instead of retaining the font selected at construction time.
static func configure_language(language: String) -> void:
	_active_language = _normalize_language(language)
	if _ui_fonts.is_empty():
		for weight in [WEIGHT_REGULAR, WEIGHT_SEMIBOLD, WEIGHT_BOLD]:
			_ui_fonts[weight] = FontVariation.new()
	var locale_primary := _active_language in ["ja", "zh-CN", "zh-TW"]
	var text_server := TextServerManager.get_primary_interface()
	var weight_tag := text_server.name_to_tag("wght")
	for weight in [WEIGHT_REGULAR, WEIGHT_SEMIBOLD, WEIGHT_BOLD]:
		var role := _ui_fonts[weight] as FontVariation
		var pretendard := _get_pretendard_font(weight)
		var fallbacks: Array[Font] = []
		if locale_primary:
			role.base_font = _get_locale_font(_active_language)
			role.variation_opentype = {weight_tag: weight}
			if pretendard != null:
				fallbacks.append(pretendard)
			if _active_language != "ja":
				fallbacks.append(_get_jp_variation(weight))
		else:
			role.base_font = pretendard
			role.variation_opentype = {}
			fallbacks.append(_get_jp_variation(weight))
		var emoji := _get_emoji_font()
		if emoji != null:
			fallbacks.append(emoji)
		role.fallbacks = fallbacks

static func active_language() -> String:
	return _active_language

static func ui_regular() -> Font:
	_ensure_ui_fonts()
	return _ui_fonts[WEIGHT_REGULAR] as Font

static func ui_semibold() -> Font:
	_ensure_ui_fonts()
	return _ui_fonts[WEIGHT_SEMIBOLD] as Font

static func ui_bold() -> Font:
	_ensure_ui_fonts()
	return _ui_fonts[WEIGHT_BOLD] as Font

## 언어별 전용 폰트 경로. 빈 문자열은 OS 폴백에 기대지 않는 명시적 차단 상태다.
static func dedicated_locale_font_path(language: String) -> String:
	match _normalize_language(language):
		"ja":
			return JP_FONT_PATH
		"zh-CN":
			return ZH_CN_FONT_PATH
		"zh-TW":
			return ZH_TW_FONT_PATH
	return ""

static func has_dedicated_locale_font(language: String) -> bool:
	var path := dedicated_locale_font_path(language)
	return not path.is_empty() and ResourceLoader.exists(path)

## 중국어에서는 SC/TC 전용 자형이 JP 폴백보다 먼저 선택된다.
static func dedicated_locale_font_precedes_jp(language: String) -> bool:
	var normalized := _normalize_language(language)
	return normalized in ["zh-CN", "zh-TW"] \
		and has_dedicated_locale_font(normalized)

## 전용 자형이 없거나 체인 순서가 틀릴 때만 JP-first 위험으로 판정한다.
static func shared_han_jp_first(language: String) -> bool:
	var normalized := _normalize_language(language)
	return normalized in ["zh-CN", "zh-TW"] \
		and not dedicated_locale_font_precedes_jp(language) \
		and ResourceLoader.exists(JP_FONT_PATH)

## 일본어 폴백은 언어 전환 뒤에도 같은 FontFile 리소스가 재사용되도록 항상
## 연결한다. 실제 일본어 선택 노출 여부는 LocaleManager allowlist가 결정한다.
static func attach_locale_fallbacks(font: Font) -> void:
	if font == null:
		return
	_ensure_ui_fonts()
	if font in _ui_fonts.values():
		return
	_append_fallback(font, _get_jp_variation(WEIGHT_REGULAR))

## FontFile(Pretendard)에 이모지 폴백을 1회 붙인다. null 안전.
static func attach_emoji_fallback(font: Font) -> void:
	if font == null:
		return
	_ensure_ui_fonts()
	if font in _ui_fonts.values():
		return
	attach_locale_fallbacks(font)
	_append_fallback(font, _get_emoji_font())
