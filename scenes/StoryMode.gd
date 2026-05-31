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
var _portrait: TextureRect
var _name_tag: Label
var _title_lbl: Label
var _body_lbl: RichTextLabel
var _continue_hint: Label
var _choice_box: VBoxContainer
var _toast_layer: VBoxContainer

var _font: FontFile
var _font_bold: FontFile

const TYPE_SPEED := 0.018   # 글자당 초

func _ready():
	_load_fonts()
	_build_ui()
	SceneTransition.fade_in()
	# 큐 가져오기
	_queue = GameState.pending_story_queue.duplicate()
	GameState.pending_story_queue.clear()
	if _queue.is_empty():
		_finish_all()
		return
	_load_next_event()

func _load_fonts():
	_font = FontFile.new()
	if _font.load_dynamic_font("res://assets/fonts/Pretendard-Regular.ttf") != OK:
		_font = null
	_font_bold = FontFile.new()
	if _font_bold.load_dynamic_font("res://assets/fonts/Pretendard-Bold.ttf") != OK:
		_font_bold = null

# ── UI 구성 ───────────────────────────────────────────────────
func _build_ui():
	# 1. 배경 이미지 (이벤트별 전환)
	_bg_img = TextureRect.new()
	_bg_img.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg_img.stretch_mode = TextureRect.STRETCH_SCALE
	_bg_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bg_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg_img)

	# 2. 어두운 오버레이 (텍스트 가독성)
	_bg_dim = ColorRect.new()
	_bg_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg_dim.color = Color(0.04, 0.04, 0.07, 0.62)
	_bg_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg_dim)

	# 3. 클릭 받는 전체 버튼 (타이핑 스킵/다음)
	var click_catcher = Button.new()
	click_catcher.flat = true
	click_catcher.set_anchors_preset(Control.PRESET_FULL_RECT)
	click_catcher.focus_mode = Control.FOCUS_NONE
	click_catcher.pressed.connect(_on_advance)
	add_child(click_catcher)

	# 4. 인물 초상화 — 좌측 하단, 크게
	_portrait = TextureRect.new()
	_portrait.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_portrait.position = Vector2(40, -460)
	_portrait.custom_minimum_size = Vector2(320, 440)
	_portrait.size = Vector2(320, 440)
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_portrait.modulate = Color(1, 1, 1, 0)
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_portrait)

	# 5. 하단 텍스트 박스
	var text_panel = PanelContainer.new()
	text_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	text_panel.offset_left = 60
	text_panel.offset_right = -60
	text_panel.offset_top = -300
	text_panel.offset_bottom = -50
	text_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.03, 0.03, 0.06, 0.86)
	panel_style.border_color = Color("#2a3450")
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(10)
	panel_style.content_margin_left = 32
	panel_style.content_margin_right = 32
	panel_style.content_margin_top = 20
	panel_style.content_margin_bottom = 20
	text_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(text_panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_panel.add_child(vbox)

	# 이름표
	_name_tag = Label.new()
	_name_tag.add_theme_font_size_override("font_size", 18)
	_name_tag.add_theme_color_override("font_color", Color("#5b9cf6"))
	_apply_font(_name_tag, true)
	_name_tag.visible = false
	vbox.add_child(_name_tag)

	# 제목 (이벤트 타이틀, 작게)
	_title_lbl = Label.new()
	_title_lbl.add_theme_font_size_override("font_size", 13)
	_title_lbl.add_theme_color_override("font_color", Color(C_DIM))
	_apply_font(_title_lbl)
	vbox.add_child(_title_lbl)

	# 본문 (타이핑)
	_body_lbl = RichTextLabel.new()
	_body_lbl.bbcode_enabled = true
	_body_lbl.fit_content = true
	_body_lbl.scroll_active = false
	_body_lbl.custom_minimum_size = Vector2(0, 120)
	_body_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body_lbl.add_theme_font_size_override("normal_font_size", 20)
	_body_lbl.add_theme_color_override("default_color", Color(C_NARRATION))
	if _font:
		_body_lbl.add_theme_font_override("normal_font", _font)
	_body_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_body_lbl)

	# 계속 힌트
	_continue_hint = Label.new()
	_continue_hint.text = "▼  클릭하여 계속"
	_continue_hint.add_theme_font_size_override("font_size", 12)
	_continue_hint.add_theme_color_override("font_color", Color("#4a5468"))
	_continue_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_apply_font(_continue_hint)
	_continue_hint.visible = false
	vbox.add_child(_continue_hint)

	# 6. 선택지 박스 (텍스트 박스 위에 겹침)
	_choice_box = VBoxContainer.new()
	_choice_box.set_anchors_preset(Control.PRESET_CENTER)
	_choice_box.anchor_top = 0.30
	_choice_box.anchor_bottom = 0.30
	_choice_box.offset_left = -360
	_choice_box.offset_right = 360
	_choice_box.add_theme_constant_override("separation", 12)
	_choice_box.visible = false
	add_child(_choice_box)

	# 7. 토스트 레이어 (스탯/관계 변화 노출)
	_toast_layer = VBoxContainer.new()
	_toast_layer.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_toast_layer.offset_left = -320
	_toast_layer.offset_top = 30
	_toast_layer.offset_right = -24
	_toast_layer.add_theme_constant_override("separation", 6)
	_toast_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_toast_layer)

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
	_showing_choices = false
	_choice_box.visible = false
	for c in _choice_box.get_children():
		c.queue_free()

	# 배경
	var bg_id = str(_current.get("background", ""))
	if bg_id != "":
		var bp = ImageRegistry.get_background(bg_id)
		if bp != "" and ResourceLoader.exists(bp):
			_bg_img.texture = load(bp)

	# 초상화
	var pid = str(_current.get("portrait", ""))
	if pid != "":
		_show_portrait(pid)
	else:
		_portrait.modulate = Color(1, 1, 1, 0)
		_name_tag.visible = false

	# 제목
	_title_lbl.text = "— %s —" % _fmt(str(_current.get("title", "")))

	# 본문 문단 분할 (\n\n 기준)
	var desc = _fmt(str(_current.get("description", "")))
	_paragraphs = []
	for para in desc.split("\n\n"):
		var p = str(para).strip_edges()
		if p != "":
			_paragraphs.append(p)
	if _paragraphs.is_empty():
		_paragraphs = [""]
	_para_index = 0
	_start_typing(_paragraphs[0])

func _show_portrait(portrait_id: String):
	var info = ImageRegistry.get_person_info(portrait_id)
	var path = ImageRegistry.get_portrait(portrait_id)
	if path != "" and ResourceLoader.exists(path):
		_portrait.texture = load(path)
	else:
		# 플레이스홀더 — 인물 테마색 단색
		var col = Color(str(info.get("color", "#2a2a3a"))) if not info.is_empty() else Color("#2a2a3a")
		var img = Image.create(3, 4, false, Image.FORMAT_RGB8)
		img.fill(col.darkened(0.5))
		_portrait.texture = ImageTexture.create_from_image(img)
	# 페이드 인
	var tw = create_tween()
	tw.tween_property(_portrait, "modulate", Color(1, 1, 1, 1), 0.4)
	# 이름표
	if not info.is_empty():
		_name_tag.text = str(info.get("name", ""))
		_name_tag.visible = true
	else:
		_name_tag.visible = false

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
		_continue_hint.visible = true
	_body_lbl.text = _type_full.substr(0, _type_pos)

# ── 입력: 클릭하여 진행 ───────────────────────────────────────
func _on_advance():
	if _transitioning or _showing_choices:
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

# ── 선택지 ────────────────────────────────────────────────────
func _show_choices():
	var choices: Array = _current.get("choices", [])
	if choices.is_empty():
		# 선택지 없는 이벤트 → 바로 다음
		_load_next_event()
		return
	_showing_choices = true
	_continue_hint.visible = false
	_choice_box.visible = true
	for i in range(choices.size()):
		var ch: Dictionary = choices[i]
		var btn = _make_choice_button(_fmt(str(ch.get("text", "선택"))), i)
		_choice_box.add_child(btn)

func _make_choice_button(text: String, idx: int) -> Button:
	var btn = Button.new()
	btn.text = "  " + text
	btn.custom_minimum_size = Vector2(0, 52)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(0.06, 0.07, 0.12, 0.94)
	normal.set_border_width_all(0)
	normal.border_width_left = 3
	normal.border_color = Color("#5b9cf6")
	normal.set_corner_radius_all(5)
	normal.content_margin_left = 18
	normal.content_margin_right = 14
	var hover = normal.duplicate()
	hover.bg_color = Color(0.12, 0.15, 0.24, 0.98)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)
	btn.add_theme_stylebox_override("focus", normal)
	btn.add_theme_color_override("font_color", Color(C_CHOICE))
	btn.add_theme_font_size_override("font_size", 17)
	if _font:
		btn.add_theme_font_override("font", _font)
	btn.pressed.connect(_on_choice.bind(idx))
	return btn

func _on_choice(idx: int):
	if _transitioning:
		return
	var choices: Array = _current.get("choices", [])
	if idx < 0 or idx >= choices.size():
		return
	var choice: Dictionary = choices[idx]
	AudioManager.play("choice_made")

	# follow_up_event를 직접 읽어 큐에 이어붙임 (StoryMode는 자체 큐 사용)
	_pending_follow_up = str(choice.get("follow_up_event", ""))

	# 변화 스냅샷 (노출용)
	var before = _snapshot_stats()
	# 실제 적용
	GameState.apply_choice(_current, choice)
	# 변화 토스트
	_show_change_toasts(before)

	# 결과 텍스트 표시
	_showing_choices = false
	_choice_box.visible = false
	for c in _choice_box.get_children():
		c.queue_free()

	var result = _fmt(str(choice.get("result_text", "")))
	if result != "":
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
	# 선택의 follow_up_event가 있으면 큐 맨 앞에 끼워 이어서 재생
	if _pending_follow_up != "" and not DataRegistry.find_event(_pending_follow_up).is_empty():
		_queue.push_front(_pending_follow_up)
	_pending_follow_up = ""
	# EventManager가 중복으로 쌓아둔 follow_up은 비워준다 (apply_choice 경유 안 함)
	_load_next_event()

# ── 스탯 변화 노출 ────────────────────────────────────────────
func _snapshot_stats() -> Dictionary:
	return {
		"money": GameState.money,
		"health": GameState.health,
		"mental": GameState.mental,
		"stress": GameState.stress,
		"intelligence": GameState.intelligence,
		"social_skill": GameState.social_skill,
		"investment_skill": GameState.investment_skill,
		"luck": GameState.luck,
	}

func _show_change_toasts(before: Dictionary):
	var labels = {
		"money": "💰", "health": "❤", "mental": "🧠", "stress": "😰",
		"intelligence": "📚", "social_skill": "🤝", "investment_skill": "📈", "luck": "🍀",
	}
	for key in before:
		var now = GameState.get(key)
		var diff = now - before[key]
		if abs(diff) < 0.01:
			continue
		var txt = ""
		if key == "money":
			txt = "%s %s%s" % [labels[key], "+" if diff > 0 else "-", GameState.format_money(abs(diff))]
		else:
			txt = "%s %s%d" % [labels[key], "+" if diff > 0 else "", int(diff)]
		# 스트레스는 +가 나쁨
		var good = diff > 0
		if key == "stress":
			good = diff < 0
		_spawn_toast(txt, Color("#00c896") if good else Color("#ff6b6b"))

func _spawn_toast(text: String, color: Color):
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 15)
	lbl.add_theme_color_override("font_color", color)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if _font_bold:
		lbl.add_theme_font_override("font", _font_bold)
	_toast_layer.add_child(lbl)
	var tw = create_tween()
	lbl.modulate.a = 0
	tw.tween_property(lbl, "modulate:a", 1.0, 0.2)
	tw.tween_interval(1.8)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.5)
	tw.tween_callback(lbl.queue_free)

# ── 종료 ──────────────────────────────────────────────────────
func _finish_all():
	if _transitioning:
		return
	_transitioning = true
	EventManager.current_event = {}
	# MainGame이 '달을 다시 시작하지 않도록' 복귀 플래그 설정
	GameState.returning_from_story = true
	# 복귀 대상 (기본: MainGame)
	var ret = GameState.story_return_scene
	if ret == "":
		ret = "res://scenes/MainGame.tscn"
	GameState.story_return_scene = ""
	SceneTransition.go(ret)

func _fmt(s: String) -> String:
	return s.replace("{name}", GameState.player_name)
