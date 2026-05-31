extends Node
class_name FontKit
## 폰트 유틸 — Pretendard에 OS 이모지 폰트를 폴백으로 붙인다.
##
## 문제: Pretendard(.ttf)에는 일부 이모지 글리프가 없다(예: 🤝 U+1F91D는 없고
##       🌊 U+1F30A는 있음). 폴백을 명시하지 않으면 Godot이 OS 폰트를 들쭉날쭉
##       골라 써서, 어떤 이모지는 안 나오고(두부) 플랫폼마다 결과가 달라진다.
## 해결: 각 OS의 표준 이모지 폰트를 "이름"으로 지정한 SystemFont를 폴백으로 붙인다.
##       파일을 번들하지 않고 플레이어 PC의 폰트를 쓰므로 라이선스/용량 문제 없음.

## OS별 컬러 이모지 폰트 후보 (위에서부터 우선)
const EMOJI_FONT_NAMES := [
	"Apple Color Emoji",   # macOS
	"Segoe UI Emoji",      # Windows 10/11
	"Noto Color Emoji",    # Linux (대부분 배포판)
	"Noto Emoji",          # Linux 흑백 폴백
	"Twemoji Mozilla",     # 기타
]

static func make_emoji_font() -> SystemFont:
	var f := SystemFont.new()
	f.font_names = PackedStringArray(EMOJI_FONT_NAMES)
	f.allow_system_fallback = true
	return f

## FontFile(Pretendard)에 이모지 폴백을 1회 붙인다. null 안전.
static func attach_emoji_fallback(font: FontFile) -> void:
	if font == null:
		return
	var fb: Array = font.fallbacks
	fb.append(make_emoji_font())
	font.fallbacks = fb
