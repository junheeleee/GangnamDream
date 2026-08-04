extends Node
class_name FontKit
## 폰트 유틸 — Pretendard에 프로젝트 소유 폴백을 붙여 플랫폼별 OS 폰트
## 선택 차이를 제거한다. 일본어는 Noto Sans JP, 이모지는 Noto Color Emoji다.
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

# 중국어 폰트는 공식 바이너리·OFL·해시를 한 묶음으로 들여오기 전까지 경로를
# 비워 둔다. Noto Sans JP가 일부 한자를 표시하는 것은 SC/TC 전용 자형 체인이
# 아니며, 이 값을 채우지 않은 상태는 출시 준비 완료로 판정할 수 없다.
const ZH_CN_FONT_PATH := ""
const ZH_TW_FONT_PATH := ""

static var _emoji_font: FontFile = null
static var _jp_font: FontFile = null

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

static func _append_fallback(font: FontFile, fallback: FontFile) -> void:
	if fallback == null:
		return
	var fallbacks: Array = font.fallbacks
	if not fallbacks.has(fallback):
		fallbacks.append(fallback)
		font.fallbacks = fallbacks

## 언어별 전용 폰트 경로. 빈 문자열은 OS 폴백에 기대지 않는 명시적 차단 상태다.
static func dedicated_locale_font_path(language: String) -> String:
	match language:
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

## 현재 attach_locale_fallbacks()는 JP 전역 폴백만 소유한다. 중국어 바이너리
## 경로만 채우고 실제 우선 체인을 빼먹어도 ready가 되지 않도록 별도 사실로 둔다.
## 향후 SC/TC를 도입할 때는 언어별 체인 구현과 함께 이 판정을 갱신해야 한다.
static func dedicated_locale_font_precedes_jp(_language: String) -> bool:
	return false

## 현재 전역 체인은 JP를 먼저 붙인다. 중국어 전용 폰트가 없는 동안 공유 한자는
## 일본식 자형이 먼저 선택될 수 있으므로 두 중국어의 글꼴 게이트는 차단된다.
static func shared_han_jp_first(language: String) -> bool:
	return language in ["zh-CN", "zh-TW"] \
		and not dedicated_locale_font_precedes_jp(language) \
		and ResourceLoader.exists(JP_FONT_PATH)

## 일본어 폴백은 언어 전환 뒤에도 같은 FontFile 리소스가 재사용되도록 항상
## 연결한다. 실제 일본어 선택 노출 여부는 LocaleManager allowlist가 결정한다.
static func attach_locale_fallbacks(font: FontFile) -> void:
	if font == null:
		return
	_append_fallback(font, _get_jp_font())

## FontFile(Pretendard)에 이모지 폴백을 1회 붙인다. null 안전.
static func attach_emoji_fallback(font: FontFile) -> void:
	if font == null:
		return
	attach_locale_fallbacks(font)
	_append_fallback(font, _get_emoji_font())
