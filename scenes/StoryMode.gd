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

const _SM_STAT_EMOJI = {
	"health": "❤", "mental": "🧠", "money": "💰",
	"intelligence": "📖", "social_skill": "🤝",
	"investment_skill": "📈", "luck": "🍀",
	"appearance": "✨", "reputation": "⭐",
}

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
var _portrait_frame: PanelContainer
var _name_panel: PanelContainer
var _name_tag: Label
var _title_lbl: Label
var _body_lbl: RichTextLabel
var _continue_hint: Label
var _choice_box: VBoxContainer
var _toast_layer: VBoxContainer
var _hud_label: Label   # 얇은 상단 HUD — 자산/돈/컨디션/시간

var _font: FontFile
var _font_bold: FontFile

const TYPE_SPEED := 0.018   # 글자당 초

func _ready():
	_load_fonts()
	_build_ui()
	_refresh_hud()
	GameState.stats_changed.connect(_refresh_hud)
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

# ── UI 구성 ───────────────────────────────────────────────────
func _build_ui():
	# 1. 배경 이미지 (이벤트별 전환)
	_bg_img = TextureRect.new()
	_bg_img.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
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

	# 4. 인물 초상화 — 우측 하단, 배경 위에 직접 표시.
	_portrait_frame = PanelContainer.new()
	_portrait_frame.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_portrait_frame.offset_left = -316
	_portrait_frame.offset_right = -48
	_portrait_frame.offset_top = -726
	_portrait_frame.offset_bottom = -256
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
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait_frame.add_child(_portrait)

	# 5. 이름표 — 텍스트 박스(상단 -250) 위에 완전히 올림
	var name_panel = PanelContainer.new()
	name_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	name_panel.offset_left = 64
	name_panel.offset_top = -294
	name_panel.offset_bottom = -256
	name_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var name_style = StyleBoxFlat.new()
	name_style.bg_color = Color(0.10, 0.16, 0.30, 0.96)
	name_style.set_corner_radius_all(7)
	name_style.content_margin_left = 18
	name_style.content_margin_right = 18
	name_style.content_margin_top = 5
	name_style.content_margin_bottom = 5
	name_panel.add_theme_stylebox_override("panel", name_style)
	add_child(name_panel)
	_name_tag = Label.new()
	_name_tag.add_theme_font_size_override("font_size", 18)
	_name_tag.add_theme_color_override("font_color", Color("#cfe0ff"))
	_apply_font(_name_tag, true)
	name_panel.add_child(_name_tag)
	_name_panel = name_panel
	name_panel.visible = false

	# 6. 하단 텍스트 박스 — 고정 높이 (타이핑해도 흔들리지 않음)
	# PanelContainer(자식 크기 추종) 대신 고정 Panel + 절대 배치 사용.
	var text_panel = Panel.new()
	text_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	text_panel.offset_left = 50
	text_panel.offset_right = -50
	text_panel.offset_top = -250
	text_panel.offset_bottom = -40
	text_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.03, 0.03, 0.06, 0.90)
	panel_style.border_color = Color("#2a3450")
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(10)
	text_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(text_panel)

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
	_continue_hint.text = "▼  클릭하여 계속"
	_continue_hint.add_theme_font_size_override("font_size", 12)
	_continue_hint.add_theme_color_override("font_color", Color("#4a5468"))
	_continue_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_continue_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_font(_continue_hint)
	_continue_hint.visible = false
	text_panel.add_child(_continue_hint)

	# 7. 선택지 박스 — 텍스트 박스(높이250) 위에 띄움. 겹치지 않게 -270부터.
	_choice_box = VBoxContainer.new()
	_choice_box.anchor_left = 0.5
	_choice_box.anchor_right = 0.5
	_choice_box.anchor_top = 1.0
	_choice_box.anchor_bottom = 1.0
	_choice_box.offset_left = -440
	_choice_box.offset_right = 440
	_choice_box.offset_top = -620
	_choice_box.offset_bottom = -270
	_choice_box.add_theme_constant_override("separation", 10)
	_choice_box.alignment = BoxContainer.ALIGNMENT_END
	_choice_box.visible = false
	add_child(_choice_box)

	# 8. 토스트 레이어 (스탯/관계 변화 노출) — 우측 상단 (HUD 아래로)
	_toast_layer = VBoxContainer.new()
	_toast_layer.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_toast_layer.offset_left = -340
	_toast_layer.offset_top = 50
	_toast_layer.offset_right = -24
	_toast_layer.add_theme_constant_override("separation", 6)
	_toast_layer.alignment = BoxContainer.ALIGNMENT_END
	_toast_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_toast_layer)

	# 9. 얇은 상단 HUD — 드라마 모드의 스테이크(자산/30억·돈·컨디션·시간) 상시 표시
	var hud_panel = Panel.new()
	hud_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hud_panel.offset_top = 0
	hud_panel.offset_bottom = 38
	hud_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hud_style = StyleBoxFlat.new()
	hud_style.bg_color = Color(0.02, 0.02, 0.05, 0.82)
	hud_style.border_color = Color("#1e2438")
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

func _refresh_hud():
	if _hud_label == null:
		return
	var assets: float = GameState.get_total_asset_value()
	var pct: int = clampi(int(assets / 3_000_000_000.0 * 100.0), 0, 100)
	var yrs_left: int = max(0, 38 - GameState.age)
	_hud_label.text = "자산 %s / 30억 (%d%%)      현금 %s      건강 %d  정신 %d      남은 %d년" % [
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
	_showing_choices = false
	_choice_box.visible = false
	for c in _choice_box.get_children():
		c.queue_free()

	var cg_path := ""
	var cg_id := str(_current.get("cg", ""))
	if cg_id != "":
		cg_path = ImageRegistry.get_cg(cg_id)

	# CG가 있는 장면은 CG를 최우선 전체화면 배경으로 사용한다.
	# 없을 때만 명시 background / 태그 추론 배경으로 폴백한다.
	if cg_path != "" and ResourceLoader.exists(cg_path):
		_bg_img.texture = load(cg_path)
		_bg_dim.color = Color(0.03, 0.03, 0.05, 0.42)
	else:
		_bg_dim.color = Color(0.04, 0.04, 0.07, 0.62)
		var bg_id = str(_current.get("background", ""))
		if bg_id == "":
			bg_id = ImageRegistry.infer_background_id(_current, GameState.housing)
		if bg_id != "":
			var bp = ImageRegistry.get_background(bg_id)
			if bp != "" and ResourceLoader.exists(bp):
				_bg_img.texture = load(bp)

	# 초상화 + 이름표 — bg_focus:true 장면은 배경만(초상화 생략)
	var pid = str(_current.get("portrait", ""))
	var bg_only := bool(_current.get("bg_focus", false)) or cg_path != ""
	_show_portrait(pid, bg_only)

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
		_continue_hint.text = "[%s] 또는 클릭" % ControllerHints.south() \
				if ControllerHints.is_pad_active() else "▼  클릭하여 계속"
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
	var priority := ["money", "health", "mental", "intelligence",
		"social_skill", "investment_skill", "reputation", "luck"]
	var parts: Array = []
	for key in priority:
		if not merged.has(key):
			continue
		var val: int = int(merged[key])
		if val == 0:
			continue
		var emoji: String = _SM_STAT_EMOJI.get(key, "")
		var sign: String = "+" if val > 0 else ""
		if key == "money":
			parts.append("%s%s%s" % [emoji, sign, GameState.format_money(float(val))])
		else:
			parts.append("%s%s%d" % [emoji, sign, val])
		if parts.size() >= 4:
			break
	return "  ".join(parts)

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
		# 버튼+미리보기를 묶어 그룹 컨테이너에 넣기
		var group := VBoxContainer.new()
		group.add_theme_constant_override("separation", 3)
		group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_choice_box.add_child(group)
		var btn = _make_choice_button(_fmt(str(ch.get("text", "선택"))), i)
		group.add_child(btn)
		var preview_str := _choice_effect_preview(ch)
		if not preview_str.is_empty():
			var lbl := Label.new()
			lbl.text = "  " + preview_str
			lbl.add_theme_font_size_override("font_size", 12)
			lbl.add_theme_color_override("font_color", Color("#5a6a80"))
			if _font:
				lbl.add_theme_font_override("font", _font)
			lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			group.add_child(lbl)
	# 컨트롤러: 첫 번째 그룹의 버튼에 포커스 (A 버튼으로 즉시 선택 가능)
	if _choice_box.get_child_count() > 0:
		var first_group = _choice_box.get_child(0)
		if first_group.get_child_count() > 0:
			first_group.get_child(0).grab_focus()

func _make_choice_button(text: String, idx: int) -> Button:
	var btn = Button.new()
	btn.text = "  " + text
	btn.custom_minimum_size = Vector2(0, 52)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(0.07, 0.06, 0.04, 0.94)
	normal.set_border_width_all(0)
	normal.border_width_left = 3
	normal.border_color = Color("#c9a227")
	normal.set_corner_radius_all(5)
	normal.content_margin_left = 18
	normal.content_margin_right = 14
	var hover = normal.duplicate()
	hover.bg_color = Color(0.14, 0.11, 0.05, 0.98)
	hover.border_color = Color("#e8c46a")
	var focus = normal.duplicate()
	focus.bg_color = Color(0.18, 0.14, 0.06, 0.98)
	focus.border_color = Color("#e8c46a")
	focus.border_width_left = 4
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)
	btn.add_theme_stylebox_override("focus", focus)
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

	# 변화 스냅샷 (노출용) — 스탯 + 인물 관계
	var before = _snapshot_stats()
	var cast_before := {}
	for pid in choice.get("cast_effects", {}):
		cast_before[str(pid)] = GameState.get_cast_affinity(str(pid))
	# 실제 적용
	GameState.apply_choice(_current, choice)
	# 첫 변화에는 팝업 설명 먼저 (떴으면 토스트는 팝업 닫힌 뒤 자연스럽게 남음)
	_maybe_show_tutorial_popup(before, cast_before)
	# 변화 토스트 (스탯 → 관계 순)
	_show_change_toasts(before)
	_show_cast_toasts(cast_before)

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
		"intelligence": GameState.intelligence,
		"social_skill": GameState.social_skill,
		"investment_skill": GameState.investment_skill,
		"luck": GameState.luck,
	}

# 스탯 표시 정보: 이모지 + 한글 이름
const STAT_INFO = {
	"money":            {"icon": "💰", "name": "돈"},
	"health":           {"icon": "❤", "name": "건강"},
	"mental":           {"icon": "🧠", "name": "정신력"},
	"intelligence":     {"icon": "📚", "name": "지력"},
	"social_skill":     {"icon": "🤝", "name": "사회성"},
	"investment_skill": {"icon": "📈", "name": "투자감각"},
	"luck":             {"icon": "🍀", "name": "운"},
}
# 인물 한글 이름 (관계 변화 토스트용)
const CAST_NAME = {
	"father": "아버지", "jiyeon": "한지연", "daeun": "김다은",
	"jaehyuk": "최재혁", "sangchul": "임상철", "hyunsu": "현수",
}

func _show_change_toasts(before: Dictionary):
	for key in before:
		var now = GameState.get(key)
		var diff = now - before[key]
		if abs(diff) < 0.01:
			continue
		var info = STAT_INFO.get(key, {"icon": "·", "name": key})
		var txt = ""
		if key == "money":
			txt = "%s %s  %s%s" % [info["icon"], info["name"], "+" if diff > 0 else "-", GameState.format_money(abs(diff))]
		else:
			txt = "%s %s  %s%d" % [info["icon"], info["name"], "+" if diff > 0 else "", int(diff)]
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
		var nm = CAST_NAME.get(pid, pid)
		var arrow = "▲ 가까워짐" if diff > 0 else "▼ 멀어짐"
		var txt = "❤ %s 호감도 %s%d  (%s)" % [nm, "+" if diff > 0 else "", diff, arrow]
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
			"📊  능력치와 자원",
			"선택에는 대가가 따른다.\n\n돈, 건강, 정신력 — 모든 선택이 이 수치들을 움직인다.\n오른쪽 위에 뜨는 변화를 눈여겨봐라.\n\n무엇을 얻고 무엇을 잃을지, 늘 저울질해야 한다.")
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
			"❤  호감도 — 사람과의 인연",
			"방금 '아버지 호감도'가 변했다.\n\n호감도는 그 사람과 얼마나 가까운지를 나타낸다.\n네 말과 선택이 호감도를 올리거나 내린다.\n\n쌓인 호감도는 언젠가 위기에서 너를 구하거나,\n결정적 기회가 되어 돌아온다.\n\n혼자 강남에 가는 사람은 없다.")

## 화면 중앙 안내 팝업 (클릭하면 닫힘)
func _show_popup(title: String, body: String):
	var overlay = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.55)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var panel = PanelContainer.new()
	panel.anchor_left = 0.5; panel.anchor_right = 0.5
	panel.anchor_top = 0.5; panel.anchor_bottom = 0.5
	panel.offset_left = -300; panel.offset_right = 300
	panel.offset_top = -150; panel.offset_bottom = 150
	var st = StyleBoxFlat.new()
	st.bg_color = Color("#0e1322")
	st.border_color = Color("#3a5a8a")
	st.set_border_width_all(2)
	st.set_corner_radius_all(12)
	st.content_margin_left = 32; st.content_margin_right = 32
	st.content_margin_top = 28; st.content_margin_bottom = 28
	panel.add_theme_stylebox_override("panel", st)
	overlay.add_child(panel)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 16)
	panel.add_child(vb)

	var tl = Label.new()
	tl.text = title
	tl.add_theme_font_size_override("font_size", 22)
	tl.add_theme_color_override("font_color", Color("#c9a227"))
	tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if _font_bold: tl.add_theme_font_override("font", _font_bold)
	vb.add_child(tl)

	var bl = Label.new()
	bl.text = body
	bl.add_theme_font_size_override("font_size", 16)
	bl.add_theme_color_override("font_color", Color("#c8d0e0"))
	bl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if _font: bl.add_theme_font_override("font", _font)
	vb.add_child(bl)

	var hint = Label.new()
	hint.text = "[A] 또는 클릭하여 닫기" if ControllerHints.is_pad_active() else "클릭하여 닫기"
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color("#5a6478"))
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
	# 어두운 배경 칩 + 라벨 (배경에 안 묻히게)
	var chip = PanelContainer.new()
	chip.size_flags_horizontal = Control.SIZE_SHRINK_END
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var st = StyleBoxFlat.new()
	st.bg_color = Color(0.04, 0.05, 0.09, 0.92)
	st.border_color = color
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
