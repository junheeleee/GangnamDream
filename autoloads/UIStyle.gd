extends Node
## UIStyle — 강남드림 전역 UI 스타일 시스템
##
## Pretendard 폰트 + 색상 팔레트 + 스타일박스 헬퍼를 중앙 관리.
## MainGame, StartMenu 등 모든 씬에서 UIStyle.font_regular 등으로 접근.

# ── 폰트 preload (autoload 레벨 → export 시 반드시 PCK 포함) ─────────
const _PRELOAD_REGULAR  := preload("res://assets/fonts/Pretendard-Regular.ttf")
const _PRELOAD_SEMIBOLD := preload("res://assets/fonts/Pretendard-SemiBold.ttf")
const _PRELOAD_BOLD     := preload("res://assets/fonts/Pretendard-Bold.ttf")

# ── 색상 팔레트 ──────────────────────────────────────────────────
const C_BG_BASE       := "#0c0c10"
const C_BG_PANEL      := "#0d0d14"
const C_BG_PANEL_ALT  := "#13131f"
const C_BORDER        := "#1e1e2e"
const C_BORDER_SUBTLE := "#252535"
const C_BORDER_ACCENT := "#2e2e4a"

const C_TEXT_PRIMARY   := "#e8eaf0"
const C_TEXT_SECONDARY := "#a0aec0"
const C_TEXT_MUTED     := "#5a6075"
const C_TEXT_DISABLED  := "#3a3a50"

const C_ACCENT_BLUE    := "#c9a227"   # 앤틱 골드 (포커스/하이라이트)
const C_ACCENT_GREEN   := "#00c896"
const C_ACCENT_GOLD    := "#f0b429"
const C_ACCENT_PURPLE  := "#a78bfa"
const C_ACCENT_RED     := "#ff4444"
const C_ACCENT_ORANGE  := "#f97316"

const C_BTN_PRIMARY    := "#2a1e05"   # 다음 달 (어두운 골드)
const C_BTN_ACTION     := "#3a2c0a"   # 선택지 (골드 다크)
const C_BTN_DANGER     := "#dc2626"   # 위험
const C_BTN_DISABLED   := "#1a1a28"

# ── Gangnam Ink 타이포·재질 토큰 ──────────────────────────────
# 본문을 선명하게 두고, 의미 있는 표면에만 최대 2px의 물성을 준다.
const INK_TEXT_DEPTH_PX := 1
const INK_SURFACE_DEPTH_MAX_PX := 2
const INK_SURFACE_OFFSET_MAX_PX := 1
const MATERIAL_PRESS_TRAVEL_PX := 1
const MATERIAL_PRESS_DURATION_SEC := 0.055

# ── 폰트 레퍼런스 (로드 후 할당) ──────────────────────────────────
var font_regular:  FontFile = null
var font_semibold: FontFile = null
var font_bold:     FontFile = null

# ── 초기화 ───────────────────────────────────────────────────────
func _ready():
	_load_fonts()

func _load_fonts():
	font_regular  = _PRELOAD_REGULAR
	font_semibold = _PRELOAD_SEMIBOLD
	font_bold     = _PRELOAD_BOLD
	FontKit.attach_emoji_fallback(font_regular)
	FontKit.attach_emoji_fallback(font_semibold)
	FontKit.attach_emoji_fallback(font_bold)
	# 전역 fallback 설정 → 폰트 오버라이드 없는 라벨도 한국어 표시
	if font_regular:
		ThemeDB.fallback_font      = font_regular
		ThemeDB.fallback_font_size = 15

# ── 스타일박스 헬퍼 ──────────────────────────────────────────────
func panel_style(bg: String, border: String = C_BORDER, radius: int = 8) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color(bg)
	s.border_color = Color(border)
	s.set_border_width_all(1)
	s.set_corner_radius_all(radius)
	s.content_margin_left   = 14
	s.content_margin_right  = 14
	s.content_margin_top    = 10
	s.content_margin_bottom = 10
	return s

func btn_style(bg: String, radius: int = 6) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color(bg)
	s.set_corner_radius_all(radius)
	s.content_margin_left   = 14
	s.content_margin_right  = 14
	s.content_margin_top    = 8
	s.content_margin_bottom = 8
	return s

func btn_disabled_style() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color(C_BTN_DISABLED)
	s.border_color = Color("#252535")
	s.set_border_width_all(1)
	s.set_corner_radius_all(6)
	s.content_margin_left   = 14
	s.content_margin_right  = 14
	s.content_margin_top    = 8
	s.content_margin_bottom = 8
	return s

func btn_focus_style() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color(0, 0, 0, 0)          # 투명
	s.border_color = Color(C_ACCENT_BLUE)
	s.set_border_width_all(2)
	s.set_corner_radius_all(6)
	return s

## 제목·선택·핵심 값에만 사용하는 1px 잉크 음영.
## 아웃라인을 늘리지 않아 720p와 4K 스케일에서 이중상을 막는다.
func apply_ink_text_depth(control: Control, role: String = "display") -> void:
	if not is_instance_valid(control):
		return
	var alpha := 0.70
	match role:
		"choice":
			alpha = 0.64
		"money", "state":
			alpha = 0.68
		"nameplate":
			alpha = 0.58
	control.add_theme_color_override("font_shadow_color", Color(0.01, 0.012, 0.015, alpha))
	control.add_theme_constant_override("shadow_offset_x", 0)
	control.add_theme_constant_override("shadow_offset_y", INK_TEXT_DEPTH_PX)
	control.add_theme_constant_override("shadow_outline_size", 0)
	control.set_meta("ink_text_role", role)
	control.set_meta("ink_text_depth_px", INK_TEXT_DEPTH_PX)

## 본문·보조 설명은 상위 테마와 무관하게 무음영으로 잠근다.
func clear_ink_text_depth(control: Control) -> void:
	if not is_instance_valid(control):
		return
	control.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
	control.add_theme_constant_override("shadow_offset_x", 0)
	control.add_theme_constant_override("shadow_offset_y", 0)
	control.add_theme_constant_override("shadow_outline_size", 0)
	control.set_meta("ink_text_role", "body")
	control.set_meta("ink_text_depth_px", 0)

## 지면에 붙은 카드를 들어 올리는 번짐 없는 직각 음영.
func apply_ink_surface_depth(style: StyleBoxFlat, depth_px: int = 2,
		alpha: float = 0.32, offset_y: int = 1) -> StyleBoxFlat:
	if style == null:
		return style
	var depth := clampi(depth_px, 0, INK_SURFACE_DEPTH_MAX_PX)
	var y_offset := clampi(offset_y, 0, INK_SURFACE_OFFSET_MAX_PX) if depth > 0 else 0
	style.shadow_color = Color(0.008, 0.010, 0.012,
		clampf(alpha, 0.0, 0.48) if depth > 0 else 0.0)
	style.shadow_size = depth
	style.shadow_offset = Vector2(0, y_offset)
	style.set_meta("ink_surface_depth", depth)
	style.set_meta("ink_surface_offset_y", y_offset)
	return style

## 누른 표면은 음영을 접고 내용만 1px 아래로 이동한다.
func apply_ink_pressed_depth(style: StyleBoxFlat,
		travel_px: int = MATERIAL_PRESS_TRAVEL_PX) -> StyleBoxFlat:
	if style == null:
		return style
	var travel := clampi(travel_px, 0, MATERIAL_PRESS_TRAVEL_PX)
	var previous_travel := int(style.get_meta("material_press_travel", 0))
	var margin_delta := travel - previous_travel
	style.shadow_color = Color(0, 0, 0, 0)
	style.shadow_size = 0
	style.shadow_offset = Vector2.ZERO
	style.content_margin_top += margin_delta
	style.content_margin_bottom = maxf(0.0, style.content_margin_bottom - margin_delta)
	style.set_meta("ink_surface_depth", 0)
	style.set_meta("ink_surface_offset_y", 0)
	style.set_meta("material_press_travel", travel)
	return style

# ── 위젯 헬퍼 ────────────────────────────────────────────────────
## 라벨 생성 — 폰트 자동 적용
func make_label(text: String, size: int, color: String,
		bold: bool = false, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var lbl = Label.new()
	lbl.text = text
	lbl.horizontal_alignment = align
	lbl.autowrap_mode = TextServer.AUTOWRAP_OFF
	lbl.clip_text = true
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", Color(color))
	_apply_font(lbl, bold)
	return lbl

## 줄바꿈 라벨 생성
func make_wrap_label(text: String, size: int, color: String, bold: bool = false) -> Label:
	var lbl = make_label(text, size, color, bold)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.clip_text = false
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return lbl

## 버튼 생성 (표준 사이즈)
func make_button(text: String, bg_color: String, font_size: int = 14) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(0, 44)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var normal_s = btn_style(bg_color)
	var hover_s  = normal_s.duplicate()
	hover_s.bg_color = Color(bg_color).lightened(0.15)
	hover_s.border_color = Color(bg_color).lightened(0.35)
	hover_s.set_border_width_all(1)
	var pressed_s = normal_s.duplicate()
	pressed_s.bg_color = Color(bg_color).darkened(0.12)

	btn.add_theme_stylebox_override("normal",   normal_s)
	btn.add_theme_stylebox_override("hover",    hover_s)
	btn.add_theme_stylebox_override("pressed",  pressed_s)
	btn.add_theme_stylebox_override("disabled", btn_disabled_style())
	btn.add_theme_stylebox_override("focus",    btn_focus_style())
	btn.add_theme_color_override("font_color",          Color(C_TEXT_PRIMARY))
	btn.add_theme_color_override("font_disabled_color", Color(C_TEXT_DISABLED))
	btn.add_theme_font_size_override("font_size", font_size)
	_apply_font(btn, false)
	btn.pressed.connect(AudioManager.play_ui_click)
	return btn

## 소형 버튼 생성
func make_small_button(text: String, bg_color: String) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(0, 34)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var normal_s = StyleBoxFlat.new()
	normal_s.bg_color = Color(bg_color)
	normal_s.set_corner_radius_all(5)
	normal_s.content_margin_left   = 10
	normal_s.content_margin_right  = 10
	normal_s.content_margin_top    = 5
	normal_s.content_margin_bottom = 5
	var hover_s = normal_s.duplicate()
	hover_s.bg_color = Color(bg_color).lightened(0.15)
	hover_s.border_color = Color(bg_color).lightened(0.4)
	hover_s.set_border_width_all(1)
	var pressed_s = normal_s.duplicate()
	pressed_s.bg_color = Color(bg_color).darkened(0.12)
	var disabled_s = StyleBoxFlat.new()
	disabled_s.bg_color = Color(C_BTN_DISABLED)
	disabled_s.set_corner_radius_all(5)

	btn.add_theme_stylebox_override("normal",   normal_s)
	btn.add_theme_stylebox_override("hover",    hover_s)
	btn.add_theme_stylebox_override("pressed",  pressed_s)
	btn.add_theme_stylebox_override("disabled", disabled_s)
	btn.add_theme_stylebox_override("focus",    btn_focus_style())
	btn.add_theme_color_override("font_color",          Color(C_TEXT_PRIMARY))
	btn.add_theme_color_override("font_disabled_color", Color(C_TEXT_DISABLED))
	btn.add_theme_font_size_override("font_size", 13)
	_apply_font(btn, false)
	btn.pressed.connect(AudioManager.play_ui_click)
	return btn

## 패널 컨테이너 생성
func make_panel(bg: String, border: String = C_BORDER) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", panel_style(bg, border))
	return panel

## LineEdit (입력 필드) 생성
func make_lineedit(placeholder: String = "", font_size: int = 15) -> LineEdit:
	var le = LineEdit.new()
	le.placeholder_text = placeholder
	le.custom_minimum_size = Vector2(0, 40)
	le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#1e1e2a")
	s.border_color = Color("#3a3a5a")
	s.set_border_width_all(1)
	s.set_corner_radius_all(6)
	s.content_margin_left   = 12
	s.content_margin_right  = 12
	s.content_margin_top    = 8
	s.content_margin_bottom = 8
	var focus_s = s.duplicate()
	focus_s.border_color = Color(C_ACCENT_BLUE)
	le.add_theme_stylebox_override("normal", s)
	le.add_theme_stylebox_override("focus",  focus_s)
	le.add_theme_color_override("font_color",             Color(C_TEXT_PRIMARY))
	le.add_theme_color_override("font_placeholder_color", Color(C_TEXT_MUTED))
	le.add_theme_font_size_override("font_size", font_size)
	if font_regular:
		le.add_theme_font_override("font", font_regular)
	return le

## 구분선 생성
func make_separator(alpha: float = 0.25) -> HSeparator:
	var sep = HSeparator.new()
	var sep_style = StyleBoxLine.new()
	sep_style.color = Color(C_BORDER_SUBTLE, alpha)
	sep_style.thickness = 1
	sep.add_theme_stylebox_override("separator", sep_style)
	return sep

# ── 폰트 적용 유틸 ───────────────────────────────────────────────
## 범용 폰트 적용 — Label, Button, LineEdit, RichTextLabel 모두 지원
func apply_font(node: Control, bold: bool = false):
	var f: FontFile = font_bold if bold and font_bold \
		else (font_semibold if bold and font_semibold else font_regular)
	if not f:
		return
	if node is RichTextLabel:
		node.add_theme_font_override("normal_font", f)
		if font_bold:
			node.add_theme_font_override("bold_font", font_bold)
	else:
		node.add_theme_font_override("font", f)

func _apply_font(node: Control, bold: bool = false):
	apply_font(node, bold)
