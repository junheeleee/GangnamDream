extends Control

var _transitioning: bool = false

var _bg_img:     TextureRect
var _logo_img:   TextureRect
var _publisher_logo: Control
var _title_lbl:  Label
var _sub_lbl:    Label
var _line_rect:  ColorRect
var _tagline_lbl: Label
var _context_lbl: Label
var _press_lbl:  Label

var _font: FontFile
var _font_bold: FontFile

func _load_fonts():
	_font      = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile
	FontKit.attach_emoji_fallback(_font)
	FontKit.attach_emoji_fallback(_font_bold)

func _apply_font(lbl: Label, bold: bool = false):
	var f = _font_bold if bold else _font
	if f:
		lbl.add_theme_font_override("font", f)

func _ready():
	_load_fonts()
	_build_ui()
	BGMPlayer.start()
	SceneTransition.fade_in()
	_run_sequence()

# ── UI 구성 ──────────────────────────────────────────────────────────────
func _build_ui():
	# 1. 검정 베이스
	var bg = ColorRect.new()
	bg.color = Color("#000000")
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# 2. 키아트 배경 (시작 시 투명)
	_bg_img = TextureRect.new()
	_bg_img.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg_img.stretch_mode = TextureRect.STRETCH_SCALE
	_bg_img.expand_mode  = TextureRect.EXPAND_IGNORE_SIZE
	_bg_img.modulate     = Color(1, 1, 1, 0.0)
	_bg_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var keyart = load("res://assets/keyart/gangnam_dream_keyart_rooftop.png")
	if keyart:
		_bg_img.texture = keyart
	add_child(_bg_img)

	# 3. 어두운 그라데이션 오버레이
	var overlay = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color        = Color(0.0, 0.0, 0.0, 0.72)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

	# 4. 중앙 세로 레이아웃
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(vbox)

	# ── 퍼블리셔 로고: JUNPAC GAMES ──
	_publisher_logo = _build_junpac_logo()
	vbox.add_child(_publisher_logo)

	# ── 로고 이미지 ──
	_logo_img = TextureRect.new()
	_logo_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_logo_img.expand_mode  = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_logo_img.custom_minimum_size = Vector2(0, 6)
	_logo_img.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_logo_img.modulate = Color(1, 1, 1, 0.0)
	_logo_img.visible = false
	vbox.add_child(_logo_img)

	# ── 한글 타이틀 ──
	_title_lbl = Label.new()
	_title_lbl.text = LocaleManager.ui("강남드림", "Gangnam Dream")
	_title_lbl.add_theme_font_size_override("font_size", 64)
	_title_lbl.add_theme_color_override("font_color", Color("#f0f4ff"))
	_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_lbl.modulate = Color(1, 1, 1, 0.0)
	_apply_font(_title_lbl, true)
	vbox.add_child(_title_lbl)

	# ── 영문 부제 ──
	_sub_lbl = Label.new()
	_sub_lbl.text = LocaleManager.ui("KOREAN LIFE SIM", "SEOUL STATUS LIFE SIM")
	_sub_lbl.add_theme_font_size_override("font_size", 16)
	_sub_lbl.add_theme_color_override("font_color", Color("#aab2bc"))
	_sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub_lbl.modulate = Color(1, 1, 1, 0.0)
	_apply_font(_sub_lbl)
	vbox.add_child(_sub_lbl)

	# ── 구분선 ──
	_line_rect = ColorRect.new()
	_line_rect.custom_minimum_size      = Vector2(260, 1)
	_line_rect.color                    = Color("#4b5566")
	_line_rect.size_flags_horizontal    = Control.SIZE_SHRINK_CENTER
	_line_rect.modulate = Color(1, 1, 1, 0.0)
	vbox.add_child(_line_rect)

	# ── 태그라인 ──
	_tagline_lbl = Label.new()
	_tagline_lbl.text = LocaleManager.ui("50만원에서 30억까지", "KRW 500K to KRW 3B")
	_tagline_lbl.add_theme_font_size_override("font_size", 19)
	_tagline_lbl.add_theme_color_override("font_color", Color("#8892a4"))
	_tagline_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tagline_lbl.modulate = Color(1, 1, 1, 0.0)
	_apply_font(_tagline_lbl, true)
	vbox.add_child(_tagline_lbl)

	# ── 배경 설명 ──
	_context_lbl = Label.new()
	_context_lbl.text = LocaleManager.ui("― 2026년 서울. 5년. 정답도 보장도 없다. ―", "Seoul, 2026. Gangnam means wealth, status, arrival.")
	_context_lbl.add_theme_font_size_override("font_size", 13)
	_context_lbl.add_theme_color_override("font_color", Color("#5f6b7a"))
	_context_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_context_lbl.modulate = Color(1, 1, 1, 0.0)
	_apply_font(_context_lbl)
	vbox.add_child(_context_lbl)

	# _press_lbl 는 더 이상 사용하지 않음 (컷신에서 처리)
	_press_lbl = Label.new()

func _build_junpac_logo() -> Control:
	var group = Control.new()
	group.custom_minimum_size = Vector2(430, 430)
	group.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	group.modulate = Color(1, 1, 1, 0.0)

	var logo = TextureRect.new()
	logo.position = Vector2.ZERO
	logo.custom_minimum_size = Vector2(430, 430)
	logo.size = Vector2(430, 430)
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo.texture = load("res://assets/logos/junpac_games_logo.jpg")
	group.add_child(logo)
	return group

# ── 애니메이션 시퀀스 ──────────────────────────────────────────────────
func _run_sequence():
	# 퍼블리셔 프리롤: 첨부된 JUNPAC GAMES 브랜드 보드의 검정/amber/red 톤을 사용한다.
	_fade_in(_publisher_logo, 0.5)
	await get_tree().create_timer(0.85).timeout
	_fade_out(_publisher_logo, 0.35)
	await get_tree().create_timer(0.35).timeout

	# 배경 먼저 서서히 등장
	_fade_in(_bg_img, 1.0, 0.38)

	await get_tree().create_timer(0.4).timeout
	_fade_in(_title_lbl, 0.65)

	await get_tree().create_timer(0.4).timeout
	_fade_in(_sub_lbl, 0.5)
	_fade_in(_line_rect, 0.6)

	await get_tree().create_timer(0.5).timeout
	_fade_in(_tagline_lbl, 0.55)

	await get_tree().create_timer(0.35).timeout
	_fade_in(_context_lbl, 0.55)

	# 로고 완성 후 잠시 대기 → 컷신으로 자동 전환
	await get_tree().create_timer(1.5).timeout
	_go_to_start()

func _fade_in(node: Control, duration: float, target_alpha: float = 1.0):
	var tw = create_tween()
	tw.tween_property(node, "modulate", Color(1, 1, 1, target_alpha), duration)

func _fade_out(node: Control, duration: float):
	var tw = create_tween()
	tw.tween_property(node, "modulate", Color(1, 1, 1, 0.0), duration)

# ── 전환 ─────────────────────────────────────────────────────────────────
func _go_to_start():
	if _transitioning:
		return
	_transitioning = true
	SceneTransition.go("res://scenes/OpeningCinematic.tscn")

func _input(event):
	if _transitioning:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		_go_to_start()
	elif event is InputEventMouseButton and event.pressed:
		_go_to_start()
	elif event is InputEventJoypadButton and event.pressed:
		_go_to_start()
