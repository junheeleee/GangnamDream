extends Control
## StoryMode — 전체화면 비주얼노벨 화면
##
## 스토리/아크 이벤트를 소설처럼 보여준다. 타이핑 효과, 배경, 인물 초상화,
## 선택지, 스탯/관계 변화 노출. 시뮬레이션 UI(스탯바/AP/버튼)는 전부 숨김.
##
## 사용법:
##   StoryMode.play_sequence([event_id1, event_id2, ...], return_scene)
##   또는 StoryMode.play_event(event_dict, on_done_callable)
##
## 전역 진입점: GameState.pending_story_queue 에 이벤트 ID 배열을 넣고
##   SceneTransition.go("res://scenes/StoryMode.tscn") 로 진입.

# ── 노출 색상 ─────────────────────────────────────────────────
const C_NARRATION := "#d8dce8"
const C_DIM       := "#8892a4"
const C_CHOICE    := "#c8d0e0"

# ── 상태 ──────────────────────────────────────────────────────
var _queue: Array = []          # 재생할 이벤트 ID 목록
var _current: Dictionary = {}   # 현재 이벤트
var _paragraphs: Array = []     # 현재 이벤트 본문 문단들
var _para_index: int = 0
var _typing: bool = false
var _type_full: String = ""     # 현재 문단 전체 텍스트
var _type_pos: int = 0
var _showing_choices: bool = false
var _transitioning: bool = false
var _pending_after_result: bool = false
var _pending_follow_up: String = ""

# ── 노드 ──────────────────────────────────────────────────────
var _bg_img: TextureRect
var _bg_dim: ColorRect
var _story_surface_overlay: ColorRect = null
var _story_surface_material: ShaderMaterial = null
var _story_bg_material: ShaderMaterial = null
var _story_portrait_material: ShaderMaterial = null
var _portrait: TextureRect
var _portrait_frame: PanelContainer
var _name_panel: PanelContainer
var _name_tag: Label
var _title_lbl: Label
var _body_lbl: RichTextLabel
var _continue_hint: Label
var _text_rule: ColorRect
var _choice_box: VBoxContainer
var _toast_layer: VBoxContainer
var _hud_panel: Panel      # 챕터 카드 시 전체 HUD 바를 숨기기 위한 상단 패널 참조
var _hud_label: Label   # 얇은 상단 HUD — 자산/돈/컨디션/시간
var _text_panel: Panel           # 하단 텍스트 박스 (챕터 카드 시 숨김)
var _result_record_card: Control = null
var _chapter_overlay: Control = null  # 챕터 카드 전용 오버레이
var _is_chapter_card: bool = false    # 챕터 카드 모드 플래그
var _current_uses_cg: bool = false
var _story_moral_norm: float = 0.0
var _story_moral_stage: int = 0
var _story_ink_transition_layer: Control = null
var _story_ink_transition_tween: Tween = null
var _story_ink_transition_progress: float = 0.0
var _story_ink_transition_kind: String = "scene"

var _font: FontFile
var _font_bold: FontFile

const TYPE_SPEED := 0.018   # 글자당 초
const PORTRAIT_OFFSET_LEFT := -430
const PORTRAIT_OFFSET_RIGHT := -28
const PORTRAIT_OFFSET_TOP := -690
const PORTRAIT_OFFSET_BOTTOM := -40
const PORTRAIT_CHOICE_SHIFT_X := 72

func _ready():
	_load_fonts()
	_build_ui()
	_refresh_hud()
	GameState.stats_changed.connect(_refresh_hud)
	if not GameState.moral_tint_changed.is_connected(_on_story_moral_tint_changed):
		GameState.moral_tint_changed.connect(_on_story_moral_tint_changed)
	SceneTransition.fade_in()
	# 큐 가져오기
	_queue = GameState.pending_story_queue.duplicate()
	GameState.pending_story_queue.clear()
	if _queue.is_empty():
		_finish_all()
		return
	_load_next_event()

func _load_fonts():
	_font      = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile
	FontKit.attach_emoji_fallback(_font)
	FontKit.attach_emoji_fallback(_font_bold)

# ── Gangnam Ink 표면 팔레트 ───────────────────────────────────
func _on_story_moral_tint_changed(norm: float, stage: int) -> void:
	_story_moral_norm = clampf(norm, -1.0, 1.0)
	_story_moral_stage = stage
	_apply_story_surface_palette(_current_uses_cg)
	_pulse_story_moral_echo(norm, stage)

func _story_palette() -> Dictionary:
	var black := clampf(-_story_moral_norm, 0.0, 1.0)
	var white := clampf(_story_moral_norm, 0.0, 1.0)
	var ui_black := black * 0.24
	var ui_white := white * 0.18
	return {
		"panel_bg": Color("#0d0d10", 0.92).lerp(Color("#050706", 0.95), ui_black).lerp(Color("#111820", 0.90), ui_white),
		"panel_border": Color("#30343a", 0.92).lerp(Color("#202824", 0.95), ui_black).lerp(Color("#637483", 0.96), ui_white),
		"hud_bg": Color("#0b0c10", 0.86).lerp(Color("#040605", 0.91), ui_black).lerp(Color("#111820", 0.84), ui_white),
		"choice_bg": Color("#111216", 0.96).lerp(Color("#060807", 0.98), ui_black).lerp(Color("#131d24", 0.95), ui_white),
		"choice_hover": Color("#181a20", 0.98).lerp(Color("#0a100d", 0.99), ui_black).lerp(Color("#1a2a34", 0.97), ui_white),
		"text": Color("#e6e8ec").lerp(Color("#a0aaa4"), ui_black * 0.55).lerp(Color("#f3f7ff"), ui_white * 0.65),
		"dim": Color("#9aa1a8").lerp(Color("#66706a"), ui_black * 0.55).lerp(Color("#c1ced8"), ui_white * 0.58),
		"dead": Color("#5f656b").lerp(Color("#3f4742"), ui_black * 0.5).lerp(Color("#87949d"), ui_white * 0.45),
		"focus": Color("#d7dbe2").lerp(Color("#89938d"), ui_black * 0.60).lerp(Color("#f8fbff"), ui_white * 0.75),
		"line": Color("#30343a", 0.72).lerp(Color("#1d2521", 0.85), ui_black).lerp(Color("#6b7c89", 0.72), ui_white),
		"black": ui_black,
		"white": ui_white,
		"moral_black": black,
		"moral_white": white,
	}

func _story_panel_style(bg: Color, border: Color, radius: int, h_margin: int = 0, v_margin: int = 0, left_border: int = 0) -> StyleBoxFlat:
	var st := StyleBoxFlat.new()
	st.bg_color = bg
	st.border_color = border
	st.set_border_width_all(1)
	if left_border > 0:
		st.border_width_left = left_border
	st.set_corner_radius_all(radius)
	st.content_margin_left = h_margin
	st.content_margin_right = h_margin
	st.content_margin_top = v_margin
	st.content_margin_bottom = v_margin
	return st

func _story_dim_color(has_cg: bool) -> Color:
	var black := clampf(-_story_moral_norm, 0.0, 1.0)
	var white := clampf(_story_moral_norm, 0.0, 1.0)
	var base := Color("#050609", 0.58)
	if has_cg:
		base = Color("#040508", 0.38)
	base = base.lerp(Color("#010202", 0.72 if not has_cg else 0.54), black)
	base = base.lerp(Color("#dfefff", 0.12 if not has_cg else 0.08), white)
	return base

func _apply_story_surface_palette(has_cg: bool = false, immediate: bool = false) -> void:
	_story_moral_norm = clampf(GameState.moral_tint_norm(), -1.0, 1.0)
	_story_moral_stage = GameState.moral_stage()
	var palette := _story_palette()
	var black: float = float(palette["moral_black"])
	var white: float = float(palette["moral_white"])
	var panel_bg: Color = palette["panel_bg"]
	var panel_border: Color = palette["panel_border"]
	var hud_bg: Color = palette["hud_bg"]
	var text_col: Color = palette["text"]
	var dim_col: Color = palette["dim"]
	var dead_col: Color = palette["dead"]
	var focus_col: Color = palette["focus"]
	var line_col: Color = palette["line"]

	if is_instance_valid(_bg_dim):
		_bg_dim.color = _story_dim_color(has_cg)
	if _story_bg_material:
		_story_bg_material.set_shader_parameter("desaturation", clampf(0.86 + black * 0.14 - white * 0.46, 0.28, 1.0))
		_story_bg_material.set_shader_parameter("brightness", clampf(0.88 - black * 0.26 + white * 0.20, 0.42, 1.20))
		_story_bg_material.set_shader_parameter("contrast", clampf(0.94 - black * 0.08 + white * 0.16, 0.68, 1.24))
		_story_bg_material.set_shader_parameter("tint_amount", clampf(black * 0.12 + white * 0.035, 0.0, 0.18))
		_story_bg_material.set_shader_parameter("tint_color", Color("#020303").lerp(Color("#f7fbff"), white))
		_story_bg_material.set_shader_parameter("grain_amount", clampf(0.020 + black * 0.030 - white * 0.014, 0.0, 0.075))
		_story_bg_material.set_shader_parameter("ink_bleed", clampf(0.060 + black * 0.120 - white * 0.042, 0.0, 0.24))
		_story_bg_material.set_shader_parameter("paper_fade", clampf(0.016 + white * 0.030, 0.0, 0.07))
		_story_bg_material.set_shader_parameter("edge_burn", clampf(0.075 + black * 0.145 - white * 0.065, 0.0, 0.25))
		_story_bg_material.set_shader_parameter("print_screen", clampf(0.011 + black * 0.026 - white * 0.009, 0.002, 0.052))
		_story_bg_material.set_shader_parameter("tone_quantize", clampf(0.018 + black * 0.095 - white * 0.014, 0.0, 0.14))
		_story_bg_material.set_shader_parameter("screen_scale", 620.0 + black * 80.0 - white * 40.0)
		_story_bg_material.set_shader_parameter("seed", float(GameState.turn % 131) + absf(_story_moral_norm) * 19.0)
	if _story_surface_material and is_instance_valid(_story_surface_overlay):
		_story_surface_overlay.visible = black > 0.01 or white > 0.01
		_story_surface_material.set_shader_parameter("black_intensity", black)
		_story_surface_material.set_shader_parameter("white_intensity", white)
		_story_surface_material.set_shader_parameter("print_screen", clampf(black * 0.045 - white * 0.010, 0.0, 0.055))
		_story_surface_material.set_shader_parameter("seed", float(GameState.turn % 97) + absf(_story_moral_norm) * 10.0)
	_apply_story_portrait_surface()
	if is_instance_valid(_text_panel):
		_text_panel.add_theme_stylebox_override("panel", _story_panel_style(panel_bg, panel_border, 8))
	if is_instance_valid(_name_panel):
		_name_panel.add_theme_stylebox_override("panel", _story_panel_style(palette["choice_bg"], panel_border, 6, 18, 5, 3))
	if is_instance_valid(_hud_panel):
		var hud_style := _story_panel_style(hud_bg, line_col, 0)
		hud_style.border_width_top = 0
		hud_style.border_width_left = 0
		hud_style.border_width_right = 0
		hud_style.border_width_bottom = 1
		_hud_panel.add_theme_stylebox_override("panel", hud_style)
	if is_instance_valid(_text_rule):
		_text_rule.color = line_col
	if is_instance_valid(_title_lbl):
		_title_lbl.add_theme_color_override("font_color", dim_col)
	if is_instance_valid(_body_lbl):
		_body_lbl.add_theme_color_override("default_color", text_col)
	if is_instance_valid(_continue_hint):
		_continue_hint.add_theme_color_override("font_color", dead_col)
	if is_instance_valid(_name_tag):
		_name_tag.add_theme_color_override("font_color", focus_col)
	if is_instance_valid(_hud_label):
		_hud_label.add_theme_color_override("font_color", dim_col)

func _apply_story_portrait_surface() -> void:
	if not is_instance_valid(_portrait):
		return
	var black := clampf(-_story_moral_norm, 0.0, 1.0)
	var white := clampf(_story_moral_norm, 0.0, 1.0)
	if _story_portrait_material:
		_story_portrait_material.set_shader_parameter("desaturation", clampf(0.36 + black * 0.54 - white * 0.24, 0.08, 0.96))
		_story_portrait_material.set_shader_parameter("brightness", clampf(0.98 - black * 0.26 + white * 0.10, 0.56, 1.18))
		_story_portrait_material.set_shader_parameter("contrast", clampf(0.98 - black * 0.06 + white * 0.12, 0.70, 1.24))
		_story_portrait_material.set_shader_parameter("tint_amount", clampf(black * 0.14 + white * 0.025, 0.0, 0.16))
		_story_portrait_material.set_shader_parameter("tint_color", Color("#020303").lerp(Color("#f6fbff"), white))
		_story_portrait_material.set_shader_parameter("grain_amount", clampf(0.004 + black * 0.026 - white * 0.004, 0.0, 0.055))
		_story_portrait_material.set_shader_parameter("ink_bleed", clampf(0.010 + black * 0.120 - white * 0.008, 0.0, 0.18))
		_story_portrait_material.set_shader_parameter("paper_fade", clampf(white * 0.022, 0.0, 0.05))
		_story_portrait_material.set_shader_parameter("edge_burn", clampf(0.020 + black * 0.115 - white * 0.020, 0.0, 0.16))
		_story_portrait_material.set_shader_parameter("print_screen", clampf(0.004 + black * 0.014 - white * 0.003, 0.0, 0.025))
		_story_portrait_material.set_shader_parameter("tone_quantize", clampf(black * 0.045 - white * 0.010, 0.0, 0.075))
		_story_portrait_material.set_shader_parameter("screen_scale", 700.0 + black * 90.0)
		_story_portrait_material.set_shader_parameter("seed", float(GameState.turn % 149) + absf(_story_moral_norm) * 23.0)
	_portrait.modulate = Color(1.0 + white * 0.035 - black * 0.045, 1.0 + white * 0.030 - black * 0.055, 1.0 + white * 0.020 - black * 0.060, 1.0)

func _animate_story_text_panel() -> void:
	if not is_instance_valid(_text_panel):
		return
	if not is_inside_tree():
		return
	_text_panel.modulate = Color(1, 1, 1, 0.0)
	var tw := create_tween()
	tw.tween_property(_text_panel, "modulate:a", 1.0, 0.22).set_trans(Tween.TRANS_SINE)

func _pulse_story_moral_echo(_norm: float, _stage: int) -> void:
	if not is_inside_tree() or not is_instance_valid(_text_panel):
		return
	var black := clampf(-_story_moral_norm, 0.0, 1.0)
	var white := clampf(_story_moral_norm, 0.0, 1.0)
	var target := Color("#080909").lerp(Color("#f6fbff"), white)
	target.a = 1.0
	var base := _text_panel.modulate
	var strength := clampf(maxf(black, white), 0.10, 0.32)
	var tw := create_tween()
	tw.tween_property(_text_panel, "modulate", base.lerp(target, strength), 0.12)
	tw.tween_property(_text_panel, "modulate", Color(1, 1, 1, 1), 0.38)

func _pulse_story_choice_commit() -> void:
	if not is_inside_tree() or not is_instance_valid(_text_panel):
		return
	var tw := create_tween()
	tw.tween_property(_text_panel, "modulate", Color(1.07, 1.07, 1.07, 1.0), 0.08)
	tw.tween_property(_text_panel, "modulate", Color(1, 1, 1, 1), 0.20)

func _bind_story_tactile_button(button: Button, strength: float = 1.0) -> void:
	if not is_instance_valid(button) or button.has_meta("_story_tactile_bound"):
		return
	button.set_meta("_story_tactile_bound", true)
	var hover_scale := Vector2.ONE * (1.0 + 0.006 * strength)
	var press_scale := Vector2(1.0 - 0.010 * strength, 1.0 - 0.040 * strength)
	button.mouse_entered.connect(func():
		if not button.disabled:
			_story_tactile_button_to(button, hover_scale, 0.10, Tween.TRANS_QUAD)
	)
	button.focus_entered.connect(func():
		if not button.disabled:
			_story_tactile_button_to(button, hover_scale, 0.10, Tween.TRANS_QUAD)
	)
	button.button_down.connect(func():
		if not button.disabled:
			_story_tactile_button_to(button, press_scale, 0.055, Tween.TRANS_QUAD)
	)
	button.button_up.connect(func():
		if not button.disabled:
			_story_tactile_button_to(button, hover_scale if button.has_focus() else Vector2.ONE, 0.12, Tween.TRANS_BACK)
	)
	button.mouse_exited.connect(func():
		_story_tactile_button_to(button, Vector2.ONE, 0.12, Tween.TRANS_QUAD)
	)
	button.focus_exited.connect(func():
		_story_tactile_button_to(button, Vector2.ONE, 0.12, Tween.TRANS_QUAD)
	)

func _story_tactile_button_to(button: Button, target_scale: Vector2, duration: float, trans: int) -> void:
	if not is_instance_valid(button) or not is_inside_tree():
		return
	button.pivot_offset = button.size * 0.5
	var old: Variant = button.get_meta("_story_tactile_tween") if button.has_meta("_story_tactile_tween") else null
	if old is Tween and (old as Tween).is_running():
		(old as Tween).kill()
	var tw := create_tween()
	tw.bind_node(button)
	tw.tween_property(button, "scale", target_scale, duration).set_trans(trans).set_ease(Tween.EASE_OUT)
	button.set_meta("_story_tactile_tween", tw)

# ── UI 구성 ───────────────────────────────────────────────────
func _build_ui():
	# 1. 배경 이미지 (이벤트별 전환)
	_bg_img = TextureRect.new()
	_bg_img.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_bg_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	var bg_grade_shader = load("res://assets/shaders/background_grade.gdshader")
	if bg_grade_shader:
		_story_bg_material = ShaderMaterial.new()
		_story_bg_material.shader = bg_grade_shader
		_story_bg_material.set_shader_parameter("desaturation", 0.86)
		_story_bg_material.set_shader_parameter("brightness", 0.88)
		_story_bg_material.set_shader_parameter("contrast", 0.94)
		_story_bg_material.set_shader_parameter("tint_color", Color("#020303"))
		_story_bg_material.set_shader_parameter("tint_amount", 0.0)
		_story_bg_material.set_shader_parameter("grain_amount", 0.020)
		_story_bg_material.set_shader_parameter("ink_bleed", 0.060)
		_story_bg_material.set_shader_parameter("paper_fade", 0.016)
		_story_bg_material.set_shader_parameter("edge_burn", 0.075)
		_story_bg_material.set_shader_parameter("print_screen", 0.011)
		_story_bg_material.set_shader_parameter("tone_quantize", 0.018)
		_story_bg_material.set_shader_parameter("screen_scale", 620.0)
		_story_bg_material.set_shader_parameter("seed", 0.0)
		_bg_img.material = _story_bg_material
	_bg_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg_img)

	# 2. 어두운 오버레이 (텍스트 가독성)
	_bg_dim = ColorRect.new()
	_bg_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg_dim.color = Color(0.04, 0.04, 0.07, 0.62)
	_bg_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg_dim)

	# 3. MORAL_TINT 표면 필름 — 배경만 먼저 통과시켜 UI 가독성을 보존한다.
	_story_surface_overlay = ColorRect.new()
	_story_surface_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_story_surface_overlay.color = Color(1, 1, 1, 1)
	_story_surface_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_story_surface_overlay.visible = false
	var surface_shader = load("res://assets/shaders/moral_surface.gdshader")
	if surface_shader:
		_story_surface_material = ShaderMaterial.new()
		_story_surface_material.shader = surface_shader
		_story_surface_material.set_shader_parameter("black_intensity", 0.0)
		_story_surface_material.set_shader_parameter("white_intensity", 0.0)
		_story_surface_material.set_shader_parameter("print_screen", 0.0)
		_story_surface_material.set_shader_parameter("seed", 0.0)
		_story_surface_overlay.material = _story_surface_material
	add_child(_story_surface_overlay)

	# 4. 클릭 받는 전체 버튼 (타이핑 스킵/다음)
	var click_catcher = Button.new()
	click_catcher.flat = true
	click_catcher.set_anchors_preset(Control.PRESET_FULL_RECT)
	click_catcher.focus_mode = Control.FOCUS_NONE
	click_catcher.pressed.connect(_on_advance)
	add_child(click_catcher)

	# 5. 인물 초상화 — 우측 하단, 배경 위에 직접 표시.
	_portrait_frame = PanelContainer.new()
	_portrait_frame.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_portrait_frame.offset_left = PORTRAIT_OFFSET_LEFT
	_portrait_frame.offset_right = PORTRAIT_OFFSET_RIGHT
	_portrait_frame.offset_top = PORTRAIT_OFFSET_TOP
	_portrait_frame.offset_bottom = PORTRAIT_OFFSET_BOTTOM
	_portrait_frame.clip_contents = true
	_portrait_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait_frame.modulate = Color(1, 1, 1, 0)
	_portrait_frame.visible = false
	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = Color(0, 0, 0, 0)      # 배경 없음
	frame_style.set_border_width_all(0)             # 테두리 없음
	frame_style.shadow_size = 0                     # 그림자 없음
	frame_style.set_corner_radius_all(0)
	frame_style.set_content_margin_all(0)
	_portrait_frame.add_theme_stylebox_override("panel", frame_style)
	add_child(_portrait_frame)

	_portrait = TextureRect.new()
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if bg_grade_shader:
		_story_portrait_material = ShaderMaterial.new()
		_story_portrait_material.shader = bg_grade_shader
		_story_portrait_material.set_shader_parameter("desaturation", 0.36)
		_story_portrait_material.set_shader_parameter("brightness", 0.98)
		_story_portrait_material.set_shader_parameter("contrast", 0.98)
		_story_portrait_material.set_shader_parameter("tint_color", Color("#020303"))
		_story_portrait_material.set_shader_parameter("tint_amount", 0.0)
		_story_portrait_material.set_shader_parameter("grain_amount", 0.004)
		_story_portrait_material.set_shader_parameter("ink_bleed", 0.010)
		_story_portrait_material.set_shader_parameter("paper_fade", 0.0)
		_story_portrait_material.set_shader_parameter("edge_burn", 0.020)
		_story_portrait_material.set_shader_parameter("print_screen", 0.004)
		_story_portrait_material.set_shader_parameter("tone_quantize", 0.0)
		_story_portrait_material.set_shader_parameter("screen_scale", 700.0)
		_story_portrait_material.set_shader_parameter("seed", 0.0)
		_portrait.material = _story_portrait_material
	_portrait_frame.add_child(_portrait)

	# 6. 이름표 — 텍스트 박스(상단 -250) 위에 완전히 올림
	var name_panel = PanelContainer.new()
	name_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	name_panel.offset_left = 64
	name_panel.offset_top = -294
	name_panel.offset_bottom = -256
	name_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var name_style = StyleBoxFlat.new()
	name_style.bg_color = Color("#121318", 0.96)
	name_style.border_color = Color("#343841")
	name_style.set_border_width_all(1)
	name_style.border_width_left = 3
	name_style.set_corner_radius_all(6)
	name_style.content_margin_left = 18
	name_style.content_margin_right = 18
	name_style.content_margin_top = 5
	name_style.content_margin_bottom = 5
	name_panel.add_theme_stylebox_override("panel", name_style)
	add_child(name_panel)
	_name_tag = Label.new()
	_name_tag.add_theme_font_size_override("font_size", 18)
	_name_tag.add_theme_color_override("font_color", Color("#e6e8ec"))
	_apply_font(_name_tag, true)
	name_panel.add_child(_name_tag)
	_name_panel = name_panel
	name_panel.visible = false

	# 7. 하단 텍스트 박스 — 고정 높이 (타이핑해도 흔들리지 않음)
	# PanelContainer(자식 크기 추종) 대신 고정 Panel + 절대 배치 사용.
	var text_panel = Panel.new()
	text_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	text_panel.offset_left = 50
	text_panel.offset_right = -50
	text_panel.offset_top = -250
	text_panel.offset_bottom = -40
	text_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color("#0d0d10", 0.92)
	panel_style.border_color = Color("#30343a")
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(8)
	text_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(text_panel)
	_text_panel = text_panel  # 챕터 카드 시 숨기기 위해 참조 보관

	_text_rule = ColorRect.new()
	_text_rule.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_text_rule.offset_left = 36
	_text_rule.offset_right = -36
	_text_rule.offset_top = 39
	_text_rule.offset_bottom = 40
	_text_rule.color = Color("#30343a", 0.75)
	_text_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_panel.add_child(_text_rule)

	# 제목 (이벤트 타이틀, 작게) — 박스 좌상단 고정
	_title_lbl = Label.new()
	_title_lbl.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_title_lbl.offset_left = 36
	_title_lbl.offset_top = 18
	_title_lbl.offset_right = -36
	_title_lbl.add_theme_font_size_override("font_size", 13)
	_title_lbl.add_theme_color_override("font_color", Color(C_DIM))
	_title_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_font(_title_lbl)
	text_panel.add_child(_title_lbl)

	# 본문 (타이핑) — 박스 안 고정 영역. fit_content 끔 → 높이 불변.
	_body_lbl = RichTextLabel.new()
	_body_lbl.bbcode_enabled = true
	_body_lbl.fit_content = false
	_body_lbl.scroll_active = false
	_body_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	_body_lbl.offset_left = 36
	_body_lbl.offset_top = 44
	_body_lbl.offset_right = -36
	_body_lbl.offset_bottom = -34
	_body_lbl.add_theme_font_size_override("normal_font_size", 20)
	_body_lbl.add_theme_color_override("default_color", Color(C_NARRATION))
	if _font:
		_body_lbl.add_theme_font_override("normal_font", _font)
	_body_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_panel.add_child(_body_lbl)

	# 계속 힌트 — 박스 우하단 고정
	_continue_hint = Label.new()
	_continue_hint.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_continue_hint.offset_left = -240
	_continue_hint.offset_top = -28
	_continue_hint.offset_right = -16
	_continue_hint.offset_bottom = -8
	_continue_hint.text = _tr("▼  클릭하여 계속", "▼  Click to continue")
	_continue_hint.add_theme_font_size_override("font_size", 12)
	_continue_hint.add_theme_color_override("font_color", Color("#4a5468"))
	_continue_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_continue_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_font(_continue_hint)
	_continue_hint.visible = false
	text_panel.add_child(_continue_hint)

	# 8. 선택지 박스 — 텍스트 박스(높이250) 위에 띄움. 겹치지 않게 -270부터.
	_choice_box = VBoxContainer.new()
	_choice_box.anchor_left = 0.08
	_choice_box.anchor_right = 0.74
	_choice_box.anchor_top = 1.0
	_choice_box.anchor_bottom = 1.0
	_choice_box.offset_left = 0
	_choice_box.offset_right = 0
	_choice_box.offset_top = -654
	_choice_box.offset_bottom = -314
	_choice_box.add_theme_constant_override("separation", 10)
	_choice_box.alignment = BoxContainer.ALIGNMENT_END
	_choice_box.visible = false
	add_child(_choice_box)

	# 9. 토스트 레이어 (스탯/관계 변화 노출) — 우측 상단 (HUD 아래로)
	_toast_layer = VBoxContainer.new()
	_toast_layer.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_toast_layer.offset_left = -340
	_toast_layer.offset_top = 50
	_toast_layer.offset_right = -24
	_toast_layer.add_theme_constant_override("separation", 6)
	_toast_layer.alignment = BoxContainer.ALIGNMENT_END
	_toast_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_toast_layer)

	# 10. 얇은 상단 HUD — 드라마 모드의 스테이크(자산/30억·돈·컨디션·시간) 상시 표시
	var hud_panel = Panel.new()
	_hud_panel = hud_panel
	hud_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hud_panel.offset_top = 0
	hud_panel.offset_bottom = 38
	hud_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hud_style = StyleBoxFlat.new()
	hud_style.bg_color = Color("#0b0c10", 0.86)
	hud_style.border_color = Color("#2e3239")
	hud_style.border_width_bottom = 1
	hud_panel.add_theme_stylebox_override("panel", hud_style)
	add_child(hud_panel)
	_hud_label = Label.new()
	_hud_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hud_label.offset_left = 24
	_hud_label.offset_right = -24
	_hud_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hud_label.add_theme_font_size_override("font_size", 14)
	_hud_label.add_theme_color_override("font_color", Color("#aeb6c8"))
	_hud_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_font(_hud_label)
	hud_panel.add_child(_hud_label)
	_apply_story_surface_palette(false, true)
	_build_story_ink_transition_layer()

func _build_story_ink_transition_layer() -> void:
	_story_ink_transition_layer = Control.new()
	_story_ink_transition_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_story_ink_transition_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_story_ink_transition_layer.visible = false
	_story_ink_transition_layer.z_index = 86
	_story_ink_transition_layer.draw.connect(_draw_story_ink_transition)
	add_child(_story_ink_transition_layer)

func _play_story_ink_transition(kind: String = "scene", strength: float = 1.0) -> void:
	if not is_instance_valid(_story_ink_transition_layer) or not is_inside_tree():
		return
	if _story_ink_transition_tween and _story_ink_transition_tween.is_running():
		_story_ink_transition_tween.kill()
	_story_ink_transition_kind = kind
	_story_ink_transition_progress = 0.0
	_story_ink_transition_layer.visible = true
	_story_ink_transition_layer.queue_redraw()
	var duration := clampf(0.30 + strength * 0.10, 0.24, 0.48)
	_story_ink_transition_tween = create_tween()
	_story_ink_transition_tween.tween_method(_set_story_ink_transition_progress, 0.0, 1.0, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_story_ink_transition_tween.tween_callback(func():
		_story_ink_transition_progress = 0.0
		if is_instance_valid(_story_ink_transition_layer):
			_story_ink_transition_layer.visible = false
			_story_ink_transition_layer.queue_redraw()
		_story_ink_transition_tween = null
	)

func _set_story_ink_transition_progress(value: float) -> void:
	_story_ink_transition_progress = clampf(value, 0.0, 1.0)
	if is_instance_valid(_story_ink_transition_layer):
		_story_ink_transition_layer.queue_redraw()

func _draw_story_ink_transition() -> void:
	if not is_instance_valid(_story_ink_transition_layer) or _story_ink_transition_progress <= 0.01:
		return
	var size := _story_ink_transition_layer.size
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var pulse := sin(_story_ink_transition_progress * PI)
	var black := clampf(-_story_moral_norm, 0.0, 1.0)
	var white := clampf(_story_moral_norm, 0.0, 1.0)
	var base := Color("#08090c").lerp(Color("#020303"), black * 0.60).lerp(Color("#eef6ff"), white * 0.32)
	if _story_ink_transition_kind == "choice":
		base = base.lerp(Color("#111216"), 0.25)
	_story_ink_transition_layer.draw_rect(Rect2(Vector2.ZERO, size), Color(base.r, base.g, base.b, pulse * (0.075 + black * 0.070 + white * 0.035)), true)

	if black > 0.01:
		var burn := Color("#000000", pulse * (0.065 + black * 0.11))
		_story_ink_transition_layer.draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, 18.0 + black * 16.0)), burn, true)
		_story_ink_transition_layer.draw_rect(Rect2(Vector2(0.0, size.y - 18.0 - black * 16.0), Vector2(size.x, 18.0 + black * 16.0)), burn, true)
	if white > 0.01:
		_story_ink_transition_layer.draw_rect(Rect2(Vector2.ZERO, size), Color("#ffffff", pulse * white * 0.026), true)

func _refresh_hud():
	if _hud_label == null:
		return
	var assets: float = GameState.get_total_asset_value()
	var pct: int = clampi(int(assets / 3_000_000_000.0 * 100.0), 0, 100)
	var yrs_left: int = max(0, 38 - GameState.age)
	_hud_label.text = _tr("자산 %s / 30억 (%d%%)      현금 %s      건강 %d  정신 %d      남은 %d년", "Assets %s / 3B (%d%%)      Cash %s      Health %d  Mental %d      %d yrs left") % [
		GameState.format_money(assets), pct,
		GameState.format_money(GameState.money),
		GameState.health, GameState.mental, yrs_left]

func _apply_font(lbl: Label, bold: bool = false):
	var f = _font_bold if bold else _font
	if f:
		lbl.add_theme_font_override("font", f)

# ── 이벤트 로딩 ───────────────────────────────────────────────
func _load_next_event():
	if _queue.is_empty():
		_finish_all()
		return
	var event_id = str(_queue.pop_front())
	_current = DataRegistry.find_event(event_id)
	if _current.is_empty():
		_load_next_event()
		return
	EventManager.current_event = _current
	_render_current()

func _render_current():
	_play_story_ink_transition("scene", 0.80)
	_showing_choices = false
	_clear_result_record_card()
	_current_uses_cg = false
	_choice_box.visible = false
	for c in _choice_box.get_children():
		c.queue_free()

	# 챕터 카드 오버레이 정리 + 일반 UI 복원
	_is_chapter_card = false
	if _chapter_overlay != null and is_instance_valid(_chapter_overlay):
		_chapter_overlay.queue_free()
		_chapter_overlay = null
	if _text_panel != null:
		_text_panel.visible = true
	if _hud_panel != null and is_instance_valid(_hud_panel):
		_hud_panel.visible = true

	# 챕터 카드 전용 시네마틱 연출
	if str(_current.get("id", "")).begins_with("chapter_card_"):
		_is_chapter_card = true
		_render_chapter_card_cinematic()
		return

	var cg_path := ""
	var cg_id := str(_current.get("cg", ""))
	if cg_id != "":
		cg_path = ImageRegistry.get_cg(cg_id)

	# CG가 있는 장면은 CG를 최우선 전체화면 배경으로 사용한다.
	# 없을 때만 명시 background / 태그 추론 배경으로 폴백한다.
	if cg_path != "" and ResourceLoader.exists(cg_path):
		_bg_img.texture = load(cg_path)
		_current_uses_cg = true
	else:
		var bg_id = str(_current.get("background", ""))
		if bg_id == "":
			bg_id = ImageRegistry.infer_background_id(_current, GameState.housing)
		if bg_id != "":
			var bp = ImageRegistry.get_background(bg_id)
			if bp != "" and ResourceLoader.exists(bp):
				_bg_img.texture = load(bp)
	_apply_story_surface_palette(_current_uses_cg)
	BGMPlayer.update_event_ambience(_current)
	AudioManager.play_event_cue(_current)

	# 초상화 + 이름표 — bg_focus:true 장면은 배경만(초상화 생략)
	var pid = str(_current.get("portrait", ""))
	var bg_only := bool(_current.get("bg_focus", false)) or cg_path != ""
	_show_portrait(pid, bg_only)

	# 제목
	_title_lbl.text = "— %s —" % _fmt(str(_current.get("title", "")))
	_animate_story_text_panel()

	# 본문 문단 분할 (\n\n 기준)
	# 루트·상태별 대체 description: description_orthodox / description_unorthodox /
	# description_low_mental / description_long_gosiwon 우선 적용
	var desc_raw: String = str(_current.get("description", ""))
	var ortho: int  = int(GameState.route_orthodox)
	var unorth: int = int(GameState.route_unorthodox)
	var mental: int = int(GameState.mental)
	var housing: String = str(GameState.housing)
	var housing_months: int = int(GameState.housing_months.get(housing, 0))
	# 지식 반응형 (DE식 발견): 플레이어가 어떤 진실을 '알게 된' 뒤에는
	# 같은 장면이 다르게 읽힌다. description_if_known = { 플래그: 대체본문 }.
	# 가진 진실 중 첫 일치를 최우선 적용 — 아는 것이 이야기를 다시 쓴다.
	var know_variant: String = ""
	var know_map = _current.get("description_if_known", null)
	if know_map is Dictionary:
		for fl in know_map.keys():
			if GameState.flags.get(str(fl), false):
				know_variant = str(know_map[fl])
				break
	if know_variant == "":
		var held_map = _current.get("description_if_held", null)
		if held_map is Dictionary:
			for item_id in held_map.keys():
				if GameState.has_item(str(item_id)):
					know_variant = str(held_map[item_id])
					break
	if know_variant != "":
		desc_raw = know_variant
	elif mental <= 20 and _current.has("description_low_mental"):
		desc_raw = str(_current["description_low_mental"])
	elif housing == "gosiwon" and housing_months >= 6 and _current.has("description_long_gosiwon"):
		desc_raw = str(_current["description_long_gosiwon"])
	elif ortho > unorth + 15 and _current.has("description_orthodox"):
		desc_raw = str(_current["description_orthodox"])
	elif unorth > ortho + 15 and _current.has("description_unorthodox"):
		desc_raw = str(_current["description_unorthodox"])
	var desc = _fmt(desc_raw)
	_paragraphs = []
	for para in desc.split("\n\n"):
		var p = str(para).strip_edges()
		if p != "":
			_paragraphs.append(p)
	if _paragraphs.is_empty():
		_paragraphs = [""]
	_para_index = 0
	_start_typing(_paragraphs[0])

func _show_portrait(portrait_id: String, bg_only: bool = false):
	var info := {}
	var path := ""
	# bg_only 장면(배경이 주연)에선 초상화 id가 있어도 인물 정보만 쓰고 그림은 띄우지 않는다.
	if portrait_id != "":
		info = ImageRegistry.get_person_info(portrait_id)
		if not bg_only:
			path = ImageRegistry.get_portrait(portrait_id)

	# 초상화 이미지가 실제로 있을 때만 액자 표시. 없으면(배경전용/플레이스홀더) 프레임 통째로 숨김.
	if path != "" and ResourceLoader.exists(path):
		_portrait.texture = load(path)
		_apply_story_portrait_surface()
		_portrait_frame.visible = true
		_portrait_frame.modulate = Color(1, 1, 1, 0)
		var tw = create_tween()
		tw.tween_property(_portrait_frame, "modulate", Color(1, 1, 1, 1), 0.4)
	else:
		_portrait.texture = null
		_portrait_frame.visible = false

	# 이름표 — 인물 정보가 있으면 표시 (이미지 없어도 누구 대사인지 알려줌)
	if not info.is_empty() and str(info.get("name", "")) != "":
		_name_tag.text = str(info.get("name", ""))
		if _name_panel:
			_name_panel.visible = true
	else:
		if _name_panel:
			_name_panel.visible = false

func _set_portrait_choice_focus(choices_visible: bool) -> void:
	if not is_inside_tree() or not is_instance_valid(_portrait_frame) or not _portrait_frame.visible:
		return
	var target_alpha := 0.46 if choices_visible else 1.0
	var target_shift := PORTRAIT_CHOICE_SHIFT_X if choices_visible else 0
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_portrait_frame, "modulate:a", target_alpha, 0.18).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_portrait_frame, "offset_left", PORTRAIT_OFFSET_LEFT + target_shift, 0.22).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_portrait_frame, "offset_right", PORTRAIT_OFFSET_RIGHT + target_shift, 0.22).set_trans(Tween.TRANS_SINE)

# ── 타이핑 효과 ───────────────────────────────────────────────
var _type_accum: float = 0.0

func _start_typing(full_text: String):
	_type_full = full_text
	_type_pos = 0
	_type_accum = 0.0
	_typing = true
	_body_lbl.text = ""
	_continue_hint.visible = false

func _process(delta):
	if not _typing:
		return
	_type_accum += delta
	while _type_accum >= TYPE_SPEED and _type_pos < _type_full.length():
		_type_accum -= TYPE_SPEED
		_type_pos += 1
	if _type_pos >= _type_full.length():
		_type_pos = _type_full.length()
		_typing = false
		_continue_hint.text = _tr("[%s] 또는 클릭", "[%s] or click") % ControllerHints.south() \
				if ControllerHints.is_pad_active() else _tr("▼  클릭하여 계속", "▼  Click to continue")
		_continue_hint.visible = true
	_body_lbl.text = _type_full.substr(0, _type_pos)

# ── 입력: 클릭하여 진행 ───────────────────────────────────────
func _on_advance():
	if _transitioning or _showing_choices:
		return
	# 챕터 카드 모드 — 클릭하면 첫 번째 선택지 자동 적용 후 진행
	if _is_chapter_card:
		_chapter_card_advance()
		return
	# 타이핑 중이면 즉시 완성
	if _typing:
		_typing = false
		_type_pos = _type_full.length()
		_body_lbl.text = _type_full
		_continue_hint.visible = true
		return
	# 다음 문단
	_para_index += 1
	if _para_index < _paragraphs.size():
		_start_typing(_paragraphs[_para_index])
		return
	# 문단 끝에 도달
	if _pending_after_result:
		# 결과 텍스트를 다 읽음 → 다음 이벤트로
		_after_result()
	else:
		# 본문 끝 → 선택지
		_show_choices()

# ── 컨트롤러 입력 ─────────────────────────────────────────────
func _unhandled_input(event: InputEvent):
	if _transitioning:
		return
	if event.is_action_pressed("ui_accept"):
		if _showing_choices:
			return  # 포커스된 선택지 버튼이 직접 처리
		_on_advance()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		# B/○/East: 이야기 도중엔 뒤로 가지 않음 (실수 방지)
		get_viewport().set_input_as_handled()

# ── 선택지 ────────────────────────────────────────────────────
func _clear_result_record_card() -> void:
	if _result_record_card != null and is_instance_valid(_result_record_card):
		_result_record_card.queue_free()
	_result_record_card = null

func _show_story_result_record(choice: Dictionary) -> void:
	_clear_result_record_card()
	var disp: Dictionary = _story_result_display_effects(choice.get("effects", {}))
	var cast_items: Array = _story_result_visible_cast_effects(choice.get("cast_effects", {}))
	if disp.is_empty() and cast_items.is_empty():
		return
	var palette := _story_palette()
	var panel_bg: Color = palette["choice_bg"]
	var panel_border: Color = palette["panel_border"]
	var focus_col: Color = palette["focus"]
	var dim_col: Color = palette["dim"]

	var card := PanelContainer.new()
	card.name = "StoryResultRecord"
	card.anchor_left = 0.20
	card.anchor_right = 0.76
	card.anchor_top = 1.0
	card.anchor_bottom = 1.0
	card.offset_left = 0
	card.offset_right = 0
	card.offset_top = -342
	card.offset_bottom = -260
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var st := _story_panel_style(panel_bg, panel_border, 6, 12, 9, 4)
	st.border_color = panel_border.lerp(focus_col, 0.16)
	card.add_theme_stylebox_override("panel", st)
	add_child(card)
	_result_record_card = card

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	card.add_child(row)

	var head := VBoxContainer.new()
	head.custom_minimum_size = Vector2(132, 0)
	head.add_theme_constant_override("separation", 2)
	row.add_child(head)
	head.add_child(_story_record_label(_tr("선택 기록", "CHOICE RESULT"), 10, dim_col, false))
	var tone := _story_result_tone_label(disp)
	head.add_child(_story_record_label(str(tone["label"]), 13, tone["color"], true))

	var grid := GridContainer.new()
	grid.columns = 4
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 7)
	grid.add_theme_constant_override("v_separation", 5)
	row.add_child(grid)

	var added := 0
	for key in _story_result_effect_order(disp):
		var val := int(disp.get(key, 0))
		if val == 0:
			continue
		grid.add_child(_story_result_badge(str(_stat_display_name(key, str(STAT_INFO.get(key, {}).get("name", key)))).to_upper(),
				_story_result_value_text(key, val), _story_result_effect_color(key, val)))
		added += 1
		if added >= 4:
			break
	for cast_item in cast_items:
		if added >= 4:
			break
		var cast_name := _cast_display_name(str(cast_item["id"])).to_upper()
		var aff := int(cast_item["affinity"])
		var sign := "+" if aff > 0 else ""
		grid.add_child(_story_result_badge(cast_name, _tr("호감도 ", "Affinity ") + "%s%d" % [sign, aff],
				Color("#c9b6df") if aff > 0 else Color("#d99494")))
		added += 1
	if added == 0:
		grid.add_child(_story_result_badge(_tr("기록", "LOG"), _tr("변화 없음", "No visible change"), dim_col))

	card.modulate = Color(1, 1, 1, 0)
	card.scale = Vector2(0.992, 0.992)
	var tw := create_tween()
	tw.tween_interval(0.08)
	tw.tween_property(card, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(card, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _story_choice_has_visible_result(choice: Dictionary) -> bool:
	var disp: Dictionary = _story_result_display_effects(choice.get("effects", {}))
	if not disp.is_empty():
		return true
	var cast_items: Array = _story_result_visible_cast_effects(choice.get("cast_effects", {}))
	return not cast_items.is_empty()

func _story_record_label(text: String, size: int, color: Color, bold: bool = false) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	lbl.clip_text = true
	lbl.autowrap_mode = TextServer.AUTOWRAP_OFF
	_apply_font(lbl, bold)
	return lbl

func _story_result_badge(label_text: String, value_text: String, accent: Color) -> Control:
	var badge := PanelContainer.new()
	badge.custom_minimum_size = Vector2(0, 46)
	badge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var palette := _story_palette()
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#0a0c11", 0.72).lerp(palette["choice_bg"], 0.30)
	st.border_color = accent.lerp(palette["panel_border"], 0.58)
	st.set_border_width_all(1)
	st.set_corner_radius_all(5)
	st.content_margin_left = 9
	st.content_margin_right = 9
	st.content_margin_top = 6
	st.content_margin_bottom = 6
	badge.add_theme_stylebox_override("panel", st)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 1)
	badge.add_child(box)
	box.add_child(_story_record_label(label_text, 9, palette["dead"], false))
	box.add_child(_story_record_label(value_text, 13, accent, true))
	return badge

func _story_result_display_effects(eff: Dictionary) -> Dictionary:
	var disp: Dictionary = {}
	for raw_key in eff:
		var key := str(raw_key)
		if not _story_result_effect_visible(key):
			continue
		if typeof(eff[raw_key]) != TYPE_INT and typeof(eff[raw_key]) != TYPE_FLOAT:
			continue
		var val := int(eff[raw_key])
		if key == "stress":
			disp["mental"] = int(disp.get("mental", 0)) - val
		elif key == "mental":
			disp["mental"] = int(disp.get("mental", 0)) + val
		else:
			disp[key] = int(disp.get(key, 0)) + val
	return disp

func _story_result_effect_visible(key: String) -> bool:
	return key not in ["tint", "route_orthodox", "route_unorthodox"]

func _story_result_visible_cast_effects(cast_effects: Dictionary) -> Array:
	var visible: Array = []
	for pid in cast_effects:
		var item = cast_effects[pid]
		if not (item is Dictionary):
			continue
		var val := int(item.get("affinity", 0))
		if val == 0:
			continue
		visible.append({"id": str(pid), "affinity": val})
	return visible

func _story_result_effect_order(disp: Dictionary) -> Array[String]:
	var order: Array[String] = [
		"money", "health", "mental", "reputation", "intelligence",
		"investment_skill", "social_skill", "appearance", "luck",
		"addiction_tendency", "gambling_tendency", "work_performance", "monthly_income"
	]
	for key in disp.keys():
		var key_str := str(key)
		if not order.has(key_str):
			order.append(key_str)
	return order

func _story_result_tone_label(disp: Dictionary) -> Dictionary:
	var positive := 0
	var negative := 0
	for key in disp:
		var val := int(disp[key])
		if key in ["addiction_tendency", "gambling_tendency"]:
			val = -val
		if val > 0:
			positive += 1
		elif val < 0:
			negative += 1
	if positive > 0 and negative > 0:
		return {"label": _tr("대가 있음", "TRADE-OFF"), "color": Color("#c8d0df")}
	if negative > 0:
		return {"label": _tr("손실", "COST"), "color": Color("#d99494")}
	if positive > 0:
		return {"label": _tr("성장", "GAIN"), "color": Color("#a9d8c1")}
	return {"label": _tr("기록", "LOG"), "color": Color("#8f98aa")}

func _story_result_effect_color(key: String, val: int) -> Color:
	if key in ["addiction_tendency", "gambling_tendency"]:
		return Color("#d99494") if val > 0 else Color("#a9d8c1")
	if val < 0:
		return Color("#d99494")
	if key == "money" or key == "monthly_income":
		return Color("#d8c48a")
	if key == "reputation":
		return Color("#b8c7d9")
	return Color("#a9d8c1")

func _story_result_value_text(key: String, val: int) -> String:
	if key == "money" or key == "monthly_income":
		if val >= 0:
			return "+%s" % GameState.format_money(float(val))
		return "-%s" % GameState.format_money(absf(float(val)))
	var sign := "+" if val > 0 else ""
	return "%s%d" % [sign, val]

func _choice_effect_preview(choice: Dictionary) -> String:
	var eff: Dictionary = choice.get("effects", {})
	if eff.is_empty():
		return ""
	var merged: Dictionary = {}
	for k in eff:
		if k == "stress":
			merged["mental"] = int(merged.get("mental", 0)) - int(eff[k])
		elif k == "mental":
			merged["mental"] = int(merged.get("mental", 0)) + int(eff[k])
		else:
			merged[k] = eff[k]
	# 즉각적으로 느껴지는 것만 표시 — 관계/스킬/평판은 숨김
	var priority := ["money", "health", "mental"]
	var parts: Array = []
	for key in priority:
		if not merged.has(key):
			continue
		var val: int = int(merged[key])
		if val == 0:
			continue
		var stat_name: String = _stat_display_name(key, str(STAT_INFO.get(key, {}).get("name", key)))
		var sign: String = "+" if val > 0 else ""
		if key == "money":
			parts.append("%s %s%s" % [stat_name, sign, GameState.format_money(float(val))])
		else:
			parts.append("%s %s%d" % [stat_name, sign, val])
		if parts.size() >= 4:
			break
	return "  ".join(parts)

func _show_choices():
	_clear_result_record_card()
	var choices: Array = _current.get("choices", [])
	if choices.is_empty():
		# 선택지 없는 이벤트 → 바로 다음
		_load_next_event()
		return
	_apply_story_surface_palette(_current_uses_cg)
	_showing_choices = true
	_continue_hint.visible = false
	_choice_box.visible = true
	_choice_box.modulate = Color(1, 1, 1, 0)
	_set_portrait_choice_focus(true)
	for i in range(choices.size()):
		var ch: Dictionary = choices[i]
		# 버튼+미리보기를 묶어 그룹 컨테이너에 넣기
		var group := VBoxContainer.new()
		group.add_theme_constant_override("separation", 3)
		group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		group.modulate = Color(1, 1, 1, 0)
		group.scale = Vector2(0.986, 0.986)
		_choice_box.add_child(group)
		var btn = _make_choice_button(_fmt(str(ch.get("text", _tr("선택", "Choose")))), i)
		group.add_child(btn)
	var tw := create_tween()
	tw.tween_property(_choice_box, "modulate:a", 1.0, 0.12)
	for i in range(_choice_box.get_child_count()):
		var group_node := _choice_box.get_child(i)
		tw.parallel().tween_property(group_node, "modulate:a", 1.0, 0.20).set_delay(0.04 * float(i))
		tw.parallel().tween_property(group_node, "scale", Vector2.ONE, 0.24).set_delay(0.04 * float(i)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# 컨트롤러: 첫 번째 그룹의 버튼에 포커스 (A 버튼으로 즉시 선택 가능)
	if _choice_box.get_child_count() > 0:
		var first_group = _choice_box.get_child(0)
		if first_group.get_child_count() > 0:
			first_group.get_child(0).grab_focus()

func _make_choice_button(text: String, idx: int) -> Button:
	var btn = Button.new()
	btn.text = "  %02d  %s" % [idx + 1, text]
	btn.custom_minimum_size = Vector2(0, 60)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var palette := _story_palette()
	var choice_bg: Color = palette["choice_bg"]
	var choice_hover: Color = palette["choice_hover"]
	var panel_border: Color = palette["panel_border"]
	var focus_col: Color = palette["focus"]
	var text_col: Color = palette["text"]
	var normal = _story_panel_style(choice_bg, panel_border, 6, 18, 9, 3)
	var hover = normal.duplicate()
	hover.bg_color = choice_hover
	hover.border_color = focus_col
	var focus = normal.duplicate()
	focus.bg_color = choice_hover.lightened(0.05)
	focus.border_color = focus_col
	focus.border_width_left = 4
	focus.set_border_width_all(2)
	var pressed = normal.duplicate()
	pressed.bg_color = choice_bg.darkened(0.14)
	pressed.border_color = focus_col.darkened(0.12)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", focus)
	btn.add_theme_color_override("font_color", text_col)
	btn.add_theme_color_override("font_hover_color", focus_col)
	btn.add_theme_color_override("font_focus_color", focus_col)
	btn.add_theme_font_size_override("font_size", 18)
	if _font:
		btn.add_theme_font_override("font", _font)
	btn.pressed.connect(_on_choice.bind(idx))
	_bind_story_tactile_button(btn, 1.0)
	return btn

func _on_choice(idx: int):
	if _transitioning:
		return
	var choices: Array = _current.get("choices", [])
	if idx < 0 or idx >= choices.size():
		return
	var choice: Dictionary = choices[idx]
	AudioManager.play("choice_made")
	AudioManager.pulse_gamepad(0.035, 0.070, 0.055)
	_play_story_ink_transition("choice", 0.65)
	_pulse_story_choice_commit()

	# follow_up_event를 직접 읽어 큐에 이어붙임 (StoryMode는 자체 큐 사용)
	_pending_follow_up = str(choice.get("follow_up_event", ""))
	var result: String = _fmt(str(choice.get("result_text", "")))
	var has_result_record: bool = result != "" and _story_choice_has_visible_result(choice)

	# 변화 스냅샷 (노출용) — 스탯 + 인물 관계
	var before = _snapshot_stats()
	var cast_before := {}
	for pid in choice.get("cast_effects", {}):
		cast_before[str(pid)] = GameState.get_cast_affinity(str(pid))
	# 실제 적용
	GameState.apply_choice(_current, choice)
	# 첫 변화에는 팝업 설명 먼저 (떴으면 토스트는 팝업 닫힌 뒤 자연스럽게 남음)
	_maybe_show_tutorial_popup(before, cast_before)
	# 결과 기록판이 있는 선택은 같은 변화를 우측 토스트로 반복 노출하지 않는다.
	if not has_result_record:
		_show_change_toasts(before)
		_show_cast_toasts(cast_before)

	# 결과 텍스트 표시
	_showing_choices = false
	_choice_box.visible = false
	_set_portrait_choice_focus(false)
	for c in _choice_box.get_children():
		c.queue_free()

	if result != "":
		_show_story_result_record(choice)
		_paragraphs = []
		for para in result.split("\n\n"):
			var p = str(para).strip_edges()
			if p != "":
				_paragraphs.append(p)
		if _paragraphs.is_empty():
			_paragraphs = [result]
		_para_index = 0
		_pending_after_result = true
		_start_typing(_paragraphs[0])
	else:
		_after_result()

func _after_result():
	_pending_after_result = false
	_clear_result_record_card()
	# 선택의 follow_up_event가 있으면 큐 맨 앞에 끼워 이어서 재생
	if _pending_follow_up != "" and not DataRegistry.find_event(_pending_follow_up).is_empty():
		_queue.push_front(_pending_follow_up)
	_pending_follow_up = ""
	# EventManager가 중복으로 쌓아둔 follow_up은 비워준다 (apply_choice 경유 안 함)
	_load_next_event()

func _chapter_card_advance():
	AudioManager.play("choice_made")
	var choices: Array = _current.get("choices", [])
	if choices.size() > 0:
		GameState.apply_choice(_current, choices[0])
	_load_next_event()

func _add_chapter_ink_frame(ov: Control, palette: Dictionary) -> void:
	var black: float = float(palette["black"])
	var white: float = float(palette["white"])
	var line_col: Color = palette["line"]
	var text_col: Color = palette["dim"]
	var rule_col := Color(line_col.r, line_col.g, line_col.b, 0.055 + black * 0.035 + white * 0.030)
	for x in [0.18, 0.50, 0.82]:
		var rule := ColorRect.new()
		rule.color = rule_col
		rule.anchor_left = x
		rule.anchor_right = x
		rule.anchor_top = 0.12
		rule.anchor_bottom = 0.88
		rule.offset_left = -0.5
		rule.offset_right = 0.5
		rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ov.add_child(rule)
	for y in [0.18, 0.34, 0.66, 0.82]:
		var rule := ColorRect.new()
		rule.color = rule_col
		rule.anchor_left = 0.16
		rule.anchor_right = 0.84
		rule.anchor_top = y
		rule.anchor_bottom = y
		rule.offset_top = -0.5
		rule.offset_bottom = 0.5
		rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ov.add_child(rule)

	var file_box := VBoxContainer.new()
	file_box.anchor_left = 0.08
	file_box.anchor_right = 0.32
	file_box.anchor_top = 0.12
	file_box.anchor_bottom = 0.24
	file_box.add_theme_constant_override("separation", 5)
	file_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ov.add_child(file_box)

	var case_lbl := Label.new()
	case_lbl.text = _tr("기록 번호", "CASE FILE")
	case_lbl.add_theme_font_size_override("font_size", 11)
	case_lbl.add_theme_color_override("font_color", text_col)
	case_lbl.modulate.a = 0.42
	_apply_font(case_lbl)
	file_box.add_child(case_lbl)

	var run_lbl := Label.new()
	run_lbl.text = _tr("50만원 / 30억 / 5년", "KRW 500K / KRW 3B / 5 YEARS")
	run_lbl.add_theme_font_size_override("font_size", 13)
	run_lbl.add_theme_color_override("font_color", Color("#d7dce5").lerp(Color("#f8fbff"), white * 0.45))
	run_lbl.modulate.a = 0.48
	_apply_font(run_lbl, true)
	file_box.add_child(run_lbl)

func _render_chapter_card_cinematic():
	_apply_story_surface_palette(false, true)
	var palette := _story_palette()
	var black: float = float(palette["black"])
	var white: float = float(palette["white"])
	var focus_col: Color = palette["focus"]
	var text_col: Color = palette["text"]
	var dim_col: Color = palette["dim"]
	var line_col: Color = palette["line"]
	# 배경: Gangnam Ink 챕터 카드
	_bg_img.texture = null
	_bg_dim.color = Color("#030405", 0.98).lerp(Color("#000000", 0.99), black).lerp(Color("#101820", 0.96), white)
	# 일반 UI 숨김
	_portrait_frame.visible = false
	_name_panel.visible = false
	_text_panel.visible = false
	_continue_hint.visible = false
	if _hud_panel != null and is_instance_valid(_hud_panel):
		_hud_panel.visible = false
	BGMPlayer.update_event_ambience(_current)

	# 오버레이 컨테이너
	var ov := Control.new()
	ov.set_anchors_preset(Control.PRESET_FULL_RECT)
	ov.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ov)
	_chapter_overlay = ov
	_add_chapter_ink_frame(ov, palette)

	# 중앙 VBox
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.anchor_left = 0.12
	vbox.anchor_right = 0.88
	vbox.anchor_top = 0.22
	vbox.anchor_bottom = 0.78
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 28)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ov.add_child(vbox)

	# ① 챕터 번호 — 작게, 차갑게
	var num_lbl := Label.new()
	num_lbl.text = _fmt(str(_current.get("title", "")))
	num_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num_lbl.add_theme_font_size_override("font_size", 15)
	num_lbl.add_theme_color_override("font_color", focus_col)
	num_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_font(num_lbl)
	num_lbl.modulate.a = 0.0
	vbox.add_child(num_lbl)

	# ② 구분선
	var sep := HSeparator.new()
	var sep_style := StyleBoxFlat.new()
	sep_style.bg_color = line_col
	sep_style.set_content_margin_all(0)
	sep.add_theme_stylebox_override("separator", sep_style)
	sep.custom_minimum_size.y = 1
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sep.modulate.a = 0.0
	vbox.add_child(sep)

	# ③ 본문 파싱 — 첫 줄 = 부제(크게), 나머지 = 설명(작게)
	var desc: String = _fmt(str(_current.get("description", "")))
	var all_lines: PackedStringArray = desc.split("\n")
	var subtitle: String = all_lines[0].strip_edges() if all_lines.size() > 0 else ""
	var body_parts: Array = []
	for i in range(1, all_lines.size()):
		var l: String = all_lines[i].strip_edges()
		if l != "":
			body_parts.append(l)
	var body_text: String = "\n".join(body_parts)

	# 부제 레이블 (크게)
	var sub_lbl := Label.new()
	sub_lbl.text = subtitle
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub_lbl.add_theme_font_size_override("font_size", 52)
	sub_lbl.add_theme_color_override("font_color", text_col)
	sub_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_font(sub_lbl, true)
	sub_lbl.modulate.a = 0.0
	vbox.add_child(sub_lbl)

	# 설명 레이블 (작게)
	var desc_lbl: RichTextLabel = null
	if body_text != "":
		desc_lbl = RichTextLabel.new()
		desc_lbl.bbcode_enabled = true
		desc_lbl.fit_content = true
		desc_lbl.scroll_active = false
		desc_lbl.text = "[center]" + body_text + "[/center]"
		desc_lbl.add_theme_font_size_override("normal_font_size", 19)
		desc_lbl.add_theme_color_override("default_color", dim_col)
		if _font:
			desc_lbl.add_theme_font_override("normal_font", _font)
		desc_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		desc_lbl.modulate.a = 0.0
		vbox.add_child(desc_lbl)

	# 클릭 힌트 — 하단 고정
	var hint := Label.new()
	hint.text = _tr("▼  클릭하여 계속", "▼  Click to continue")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", palette["dead"])
	_apply_font(hint)
	hint.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hint.offset_bottom = -32
	hint.offset_top = -64
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.modulate.a = 0.0
	ov.add_child(hint)

	# 순차 페이드인 애니메이션
	var tw := create_tween()
	tw.tween_interval(0.15)
	tw.tween_property(num_lbl, "modulate:a", 1.0, 0.55).set_trans(Tween.TRANS_SINE)
	tw.tween_property(sep, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE)
	tw.tween_interval(0.1)
	tw.tween_property(sub_lbl, "modulate:a", 1.0, 0.75).set_trans(Tween.TRANS_SINE)
	if desc_lbl != null:
		tw.tween_interval(0.3)
		tw.tween_property(desc_lbl, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)
	tw.tween_interval(0.5)
	tw.tween_property(hint, "modulate:a", 0.55, 0.4).set_trans(Tween.TRANS_SINE)

# ── 스탯 변화 노출 ────────────────────────────────────────────
func _snapshot_stats() -> Dictionary:
	return {
		"money": GameState.money,
		"health": GameState.health,
		"mental": GameState.mental,
		"intelligence": GameState.intelligence,
		"social_skill": GameState.social_skill,
		"investment_skill": GameState.investment_skill,
		"luck": GameState.luck,
	}

# 스탯 표시 정보: 한글/영문 이름
const STAT_INFO = {
	"money":            {"name": "돈", "name_en": "Money"},
	"health":           {"name": "건강", "name_en": "Health"},
	"mental":           {"name": "정신력", "name_en": "Mental"},
	"intelligence":     {"name": "지력", "name_en": "Intelligence"},
	"social_skill":     {"name": "사회성", "name_en": "Social"},
	"investment_skill": {"name": "투자감각", "name_en": "Investing"},
	"luck":             {"name": "운", "name_en": "Luck"},
	"reputation":       {"name": "평판", "name_en": "Reputation"},
	"appearance":       {"name": "외모", "name_en": "Appearance"},
	"addiction_tendency": {"name": "중독도", "name_en": "Addiction"},
	"gambling_tendency": {"name": "도박충동", "name_en": "Gambling Urge"},
	"work_performance": {"name": "업무성과", "name_en": "Performance"},
	"monthly_income":   {"name": "월수입", "name_en": "Monthly Income"},
}
const CAST_NAME_EN = {
	"father": "Father", "jiyeon": "Han Jiyeon", "daeun": "Kim Daeun",
	"jaehyuk": "Choi Jaehyuk", "sangchul": "Im Sangchul", "hyunsu": "Hyunsu",
}

## 스탯 표시 이름 — 현재 언어에 맞게
func _stat_display_name(key: String, ko_name: String) -> String:
	if LocaleManager.language == "en":
		return str(STAT_INFO.get(key, {}).get("name_en", key))
	return ko_name

## 인물 표시 이름 — 현재 언어에 맞게
func _cast_display_name(pid: String) -> String:
	if LocaleManager.language == "en":
		return str(CAST_NAME_EN.get(pid, pid))
	match pid:
		"father": return _tr("아버지", "Father")
		"jiyeon": return _tr("한지연", "Han Jiyeon")
		"daeun": return _tr("김다은", "Kim Daeun")
		"jaehyuk": return _tr("최재혁", "Choi Jaehyuk")
		"sangchul": return _tr("임상철", "Im Sangchul")
		"hyunsu": return _tr("현수", "Hyunsu")
	return pid

func _show_change_toasts(before: Dictionary):
	for key in before:
		var now = GameState.get(key)
		var diff = now - before[key]
		if abs(diff) < 0.01:
			continue
		var info = STAT_INFO.get(key, {"name": key})
		var disp_name = _stat_display_name(key, str(info["name"]))
		var txt = ""
		if key == "money":
			txt = "%s  %s%s" % [disp_name, "+" if diff > 0 else "-", GameState.format_money(abs(diff))]
		else:
			txt = "%s  %s%d" % [disp_name, "+" if diff > 0 else "", int(diff)]
		# 스트레스는 +가 나쁨
		var good = diff > 0
		if key == "stress":
			good = diff < 0
		_spawn_toast(txt, Color("#00c896") if good else Color("#ff6b6b"))

## 인물 관계(호감도) 변화 토스트
func _show_cast_toasts(before: Dictionary):
	for pid in before:
		var now = GameState.get_cast_affinity(pid)
		var diff = now - int(before[pid])
		if diff == 0:
			continue
		var nm = _cast_display_name(pid)
		var arrow = _tr("▲ 가까워짐", "▲ closer") if diff > 0 else _tr("▼ 멀어짐", "▼ distant")
		var txt = _tr("%s 호감도 %s%d  (%s)", "%s affinity %s%d  (%s)") % [nm, "+" if diff > 0 else "", diff, arrow]
		_spawn_toast(txt, Color("#e8a0c0") if diff > 0 else Color("#ff6b6b"))

## 첫 변화에 1회만 안내 팝업. GameState.flags로 중복 방지.
func _maybe_show_tutorial_popup(stat_before: Dictionary, cast_before: Dictionary):
	# 자원(돈/스탯) 첫 변화
	var stat_changed = false
	for k in stat_before:
		if abs(GameState.get(k) - stat_before[k]) >= 0.01:
			stat_changed = true
			break
	if stat_changed and not GameState.flags.get("tut_stat_shown", false):
		GameState.flags["tut_stat_shown"] = true
		_show_popup(
			_tr("능력치와 자원", "Stats & Resources"),
			_tr("선택에는 대가가 따른다.\n\n돈, 건강, 정신력 — 모든 선택이 이 수치들을 움직인다.\n오른쪽 위에 뜨는 변화를 눈여겨봐라.\n\n무엇을 얻고 무엇을 잃을지, 늘 저울질해야 한다.",
				"Every choice has a cost.\n\nMoney, health, mental — each choice moves these numbers.\nWatch the changes that pop up in the top right.\n\nAlways weigh what you gain against what you lose."))
		return
	# 인물 관계 첫 변화
	var cast_changed = false
	for pid in cast_before:
		if GameState.get_cast_affinity(pid) != int(cast_before[pid]):
			cast_changed = true
			break
	if cast_changed and not GameState.flags.get("tut_cast_shown", false):
		GameState.flags["tut_cast_shown"] = true
		_show_popup(
			_tr("호감도 — 사람과의 인연", "Affinity — Bonds With People"),
			_tr("방금 '아버지 호감도'가 변했다.\n\n호감도는 그 사람과 얼마나 가까운지를 나타낸다.\n네 말과 선택이 호감도를 올리거나 내린다.\n\n쌓인 호감도는 언젠가 위기에서 너를 구하거나,\n결정적 기회가 되어 돌아온다.\n\n혼자 강남에 가는 사람은 없다.",
				"Your father's affinity just changed.\n\nAffinity shows how close you are to someone.\nYour words and choices raise or lower it.\n\nThe affinity you build can save you in a crisis someday,\nor return as a decisive opportunity.\n\nNo one reaches Gangnam alone."))

## 화면 중앙 안내 팝업 (클릭하면 닫힘)
func _show_popup(title: String, body: String):
	_apply_story_surface_palette(_current_uses_cg)
	var palette := _story_palette()
	var panel_bg: Color = palette["panel_bg"]
	var panel_border: Color = palette["panel_border"]
	var text_col: Color = palette["text"]
	var dead_col: Color = palette["dead"]
	var focus_col: Color = palette["focus"]

	var overlay = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.62)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 100
	add_child(overlay)

	var panel = PanelContainer.new()
	panel.anchor_left = 0.5; panel.anchor_right = 0.5
	panel.anchor_top = 0.5; panel.anchor_bottom = 0.5
	panel.offset_left = -300; panel.offset_right = 300
	panel.offset_top = -150; panel.offset_bottom = 150
	var st = _story_panel_style(panel_bg, panel_border, 8, 32, 28, 3)
	panel.add_theme_stylebox_override("panel", st)
	overlay.add_child(panel)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 16)
	panel.add_child(vb)

	var tl = Label.new()
	tl.text = title
	tl.add_theme_font_size_override("font_size", 22)
	tl.add_theme_color_override("font_color", focus_col)
	tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if _font_bold: tl.add_theme_font_override("font", _font_bold)
	vb.add_child(tl)

	var bl = Label.new()
	bl.text = body
	bl.add_theme_font_size_override("font_size", 16)
	bl.add_theme_color_override("font_color", text_col)
	bl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if _font: bl.add_theme_font_override("font", _font)
	vb.add_child(bl)

	var hint = Label.new()
	hint.text = _tr("[%s] 또는 클릭하여 닫기", "[%s] or click to close") % ControllerHints.south() if ControllerHints.is_pad_active() else _tr("클릭하여 닫기", "Click to close")
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", dead_col)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if _font: hint.add_theme_font_override("font", _font)
	vb.add_child(hint)

	# 등장 애니메이션
	overlay.modulate.a = 0
	var tw = create_tween()
	tw.tween_property(overlay, "modulate:a", 1.0, 0.2)
	# 클릭 또는 아무 패드 버튼으로 닫힘.
	# panel(PanelContainer)이 MOUSE_FILTER_STOP이라 overlay까지 이벤트가 안 오므로
	# overlay와 panel 양쪽에 연결한다.
	var _close_fn = func(ev):
		if (ev is InputEventMouseButton and ev.pressed) or \
				(ev is InputEventJoypadButton and ev.pressed):
			overlay.queue_free()
	overlay.gui_input.connect(_close_fn)
	panel.gui_input.connect(_close_fn)

func _spawn_toast(text: String, color: Color):
	var palette := _story_palette()
	var chip_bg: Color = palette["choice_bg"]
	var panel_border: Color = palette["panel_border"]
	# 어두운 배경 칩 + 라벨 (배경에 안 묻히게)
	var chip = PanelContainer.new()
	chip.size_flags_horizontal = Control.SIZE_SHRINK_END
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var st = StyleBoxFlat.new()
	st.bg_color = chip_bg
	st.border_color = color.lerp(panel_border, 0.22)
	st.border_width_left = 3
	st.set_corner_radius_all(5)
	st.content_margin_left = 12
	st.content_margin_right = 14
	st.content_margin_top = 5
	st.content_margin_bottom = 5
	chip.add_theme_stylebox_override("panel", st)

	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 15)
	lbl.add_theme_color_override("font_color", color)
	lbl.autowrap_mode = TextServer.AUTOWRAP_OFF
	if _font_bold:
		lbl.add_theme_font_override("font", _font_bold)
	chip.add_child(lbl)

	_toast_layer.add_child(chip)
	var tw = create_tween()
	chip.modulate.a = 0
	tw.tween_property(chip, "modulate:a", 1.0, 0.2)
	tw.tween_interval(2.0)
	tw.tween_property(chip, "modulate:a", 0.0, 0.5)
	tw.tween_callback(chip.queue_free)

# ── 종료 ──────────────────────────────────────────────────────
func _finish_all():
	if _transitioning:
		return
	_transitioning = true
	EventManager.current_event = {}
	BGMPlayer.update_idle_ambience()
	# MainGame이 '달을 다시 시작하지 않도록' 복귀 플래그 설정
	GameState.returning_from_story = true
	# 복귀 대상 (기본: MainGame)
	var ret = GameState.story_return_scene
	if ret == "":
		ret = "res://scenes/MainGame.tscn"
	GameState.story_return_scene = ""
	SceneTransition.go(ret)

func _fmt(s: String) -> String:
	return GameState.format_event_text(s)

## UI 문자열 번역 헬퍼
func _tr(ko: String, en: String) -> String:
	return LocaleManager.ui(ko, en)
