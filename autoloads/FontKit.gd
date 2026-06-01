extends Node
class_name FontKit
## 폰트 유틸 — Pretendard에 번들 이모지 폰트(NotoColorEmoji)를 폴백으로 붙인다.
##
## 문제: Pretendard(.ttf)에는 이모지 글리프가 없다. 폴백을 안 걸면 Godot이 OS
##       폰트를 들쭉날쭉 골라 써서, 어떤 이모지(예: 🤝 U+1F91D, 2016)는 안 나오고
##       플랫폼마다 결과가 달라진다.
## 시도1(실패): SystemFont("Apple Color Emoji" 등) 폴백 → has_char는 true지만
##       런타임 렌더링엔 안 쓰여서 🤝가 여전히 안 나왔다.
## 해결: NotoColorEmoji.ttf 를 직접 번들하고 FontFile 폴백으로 건다. 실제 폰트
##       파일이라 렌더링에 확실히 사용되고, 모든 플랫폼에서 동일하게 보인다.

const EMOJI_FONT_PATH := "res://assets/fonts/NotoColorEmoji.ttf"

static var _emoji_font: FontFile = null

static func _get_emoji_font() -> FontFile:
	if _emoji_font == null and ResourceLoader.exists(EMOJI_FONT_PATH):
		var res = load(EMOJI_FONT_PATH)
		if res is FontFile:
			_emoji_font = res
	return _emoji_font

## FontFile(Pretendard)에 이모지 폴백을 1회 붙인다. null 안전.
static func attach_emoji_fallback(font: FontFile) -> void:
	if font == null:
		return
	var ef := _get_emoji_font()
	if ef == null:
		return
	var fb: Array = font.fallbacks
	if not fb.has(ef):
		fb.append(ef)
		font.fallbacks = fb
