extends Control

# ── 컷신 카드 정의 ─────────────────────────────────────────────
# 각 카드: { text, sub (선택), hold (초), size (폰트), align }
const CARDS = [
	{
		"text": "2026년, 서울.",
		"sub": "",
		"hold": 2.2,
		"size": 38,
	},
	{
		"text": "강남구 아파트 평균 매매가,\n30억을 돌파했다.",
		"sub": "최저시급으로 한 푼도 안 쓰고 모아야 하는 시간 — 82년.",
		"hold": 3.5,
		"size": 30,
	},
	{
		"text": "그래도 사람들은 서울로 온다.",
		"sub": "고시원 방 1평 반에 짐을 풀고,\n처음으로 혼자 월세를 낸다.\n\n언젠가는 저기 살 수 있을 것 같아서.",
		"hold": 4.0,
		"size": 28,
	},
	{
		"text": "강남드림.",
		"sub": "그곳은 주소가 아니라,\n도착했다는 증명처럼 불린다.",
		"hold": 2.8,
		"size": 52,
	},
	{
		"text": "남은 시간: 5년.",
		"sub": "통장 잔액: 50만원.\n월세: 65만원.\n\n강남까지는 — 30억이 필요하다.",
		"hold": 4.0,
		"size": 34,
	},
	{
		"text": "어떤 선택이 강남을 만드는지,\n아무도 가르쳐준 적 없다.",
		"sub": "당신이 직접 알아내야 한다.",
		"hold": 3.0,
		"size": 26,
	},
	{
		"text": "이제, 당신의 5년이 시작된다.",
		"sub": "50만원으로 시작해 30억까지.\n정답은 없다. 다음 선택부터 시작하면 된다.",
		"hold": -1,
		"size": 32,
		"stats": [
			["START", "50만원"],
			["GOAL", "30억"],
			["TIME", "5년"],
		],
	},
]

const CARDS_EN = [
	{
		"text": "2026. Seoul.",
		"sub": "",
		"hold": 2.2,
		"size": 38,
	},
	{
		"text": "The average Gangnam apartment\nhas crossed KRW 3 billion.",
		"sub": "Gangnam is Seoul's shorthand for wealth, status, and arrival.\nAt minimum wage, saving every won would take 82 years.",
		"hold": 3.5,
		"size": 30,
	},
	{
		"text": "Still, people come to Seoul.",
		"sub": "They unpack in a 1.5-pyeong goshiwon,\nand pay rent alone for the first time.\n\nBecause one day, maybe, they could live over there.",
		"hold": 4.0,
		"size": 28,
	},
	{
		"text": "Gangnam Dream.",
		"sub": "Not just a place.\nProof that you made it.",
		"hold": 2.8,
		"size": 52,
	},
	{
		"text": "Time left: 5 years.",
		"sub": "Bank balance: KRW 500K.\nRent: KRW 650K a month.\n\nTo reach Gangnam — you need KRW 3 billion.",
		"hold": 4.0,
		"size": 34,
	},
	{
		"text": "No one teaches you\nwhich choices get you there.",
		"sub": "You have to figure it out yourself.",
		"hold": 3.0,
		"size": 26,
	},
	{
		"text": "Your next five years begin now.",
		"sub": "Start with KRW 500K. Reach Seoul's status district before 38.\nNo guide. Start with the next choice.",
		"hold": -1,
		"size": 32,
		"stats": [
			["START", "KRW 500K"],
			["GOAL", "KRW 3B"],
			["TIME", "5 YEARS"],
		],
	},
]

const FADE_IN  := 0.9
const FADE_OUT := 0.7

var _transitioning := false
var _card_index    := 0
var _waiting_input := false

var _bg:       ColorRect
var _main_lbl: Label
var _sub_lbl:  Label
var _stats_row: HBoxContainer
var _hint_lbl: Label
var _font:     FontFile
var _font_bold: FontFile

# ── 초기화 ───────────────────────────────────────────────────
func _ready():
	_load_fonts()
	_build_ui()
	SceneTransition.fade_in()
	_play_card(0)

func _load_fonts():
	_font      = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile
	FontKit.attach_emoji_fallback(_font)
	FontKit.attach_emoji_fallback(_font_bold)

func _apply_font(lbl: Label, bold: bool = false):
	var f = _font_bold if bold else _font
	if f:
		lbl.add_theme_font_override("font", f)

func _build_ui():
	# 전체 검정 배경
	_bg = ColorRect.new()
	_bg.color = Color("#08080d")
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg)

	var line_layer := Control.new()
	line_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	line_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(line_layer)
	for x in [0.18, 0.50, 0.82]:
		var vline := ColorRect.new()
		vline.color = Color("#161b26", 0.24)
		vline.anchor_left = x
		vline.anchor_right = x
		vline.anchor_top = 0.12
		vline.anchor_bottom = 0.88
		vline.offset_left = 0
		vline.offset_right = 1
		vline.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line_layer.add_child(vline)
	for y in [0.34, 0.66]:
		var hline := ColorRect.new()
		hline.color = Color("#141824", 0.22)
		hline.anchor_left = 0.16
		hline.anchor_right = 0.84
		hline.anchor_top = y
		hline.anchor_bottom = y
		hline.offset_top = 0
		hline.offset_bottom = 1
		hline.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line_layer.add_child(hline)

	# 중앙 컨테이너
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 24)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(vbox)

	# 메인 텍스트
	_main_lbl = Label.new()
	_main_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_main_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_main_lbl.custom_minimum_size = Vector2(700, 0)
	_main_lbl.add_theme_color_override("font_color", Color("#e8eaf0"))
	_main_lbl.modulate = Color(1, 1, 1, 0.0)
	_apply_font(_main_lbl, true)
	vbox.add_child(_main_lbl)

	# 서브 텍스트 (작은 글씨)
	_sub_lbl = Label.new()
	_sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_sub_lbl.custom_minimum_size = Vector2(640, 0)
	_sub_lbl.add_theme_font_size_override("font_size", 16)
	_sub_lbl.add_theme_color_override("font_color", Color("#6a7590"))
	_sub_lbl.modulate = Color(1, 1, 1, 0.0)
	_apply_font(_sub_lbl)
	vbox.add_child(_sub_lbl)

	_stats_row = HBoxContainer.new()
	_stats_row.add_theme_constant_override("separation", 10)
	_stats_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_stats_row.modulate = Color(1, 1, 1, 0.0)
	_stats_row.visible = false
	_stats_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_stats_row)

	# 하단 힌트 ("아무 키나 눌러 시작")
	_hint_lbl = Label.new()
	_hint_lbl.text = LocaleManager.ui("아무 키나 눌러 시작", "Press any key to begin")
	_hint_lbl.add_theme_font_size_override("font_size", 13)
	_hint_lbl.add_theme_color_override("font_color", Color("#3a4455"))
	_hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_lbl.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_hint_lbl.offset_top    = -44
	_hint_lbl.offset_bottom = 0
	_hint_lbl.modulate = Color(1, 1, 1, 0.0)
	_apply_font(_hint_lbl)
	add_child(_hint_lbl)

# ── 카드 재생 ─────────────────────────────────────────────────
func _play_card(idx: int):
	_card_index    = idx
	_waiting_input = false
	var cards := CARDS_EN if LocaleManager.is_english() else CARDS
	var card = cards[idx]

	_main_lbl.add_theme_font_size_override("font_size", card["size"])
	_main_lbl.text = card["text"]
	_sub_lbl.text  = card["sub"]

	# 서브 텍스트 표시 여부
	_sub_lbl.visible = card["sub"] != ""
	_apply_card_stats(card)

	# 메인 텍스트 페이드인
	_main_lbl.modulate = Color(1, 1, 1, 0.0)
	_sub_lbl.modulate  = Color(1, 1, 1, 0.0)
	_stats_row.modulate = Color(1, 1, 1, 0.0)

	var tw = create_tween()
	tw.tween_property(_main_lbl, "modulate", Color(1, 1, 1, 1.0), FADE_IN)

	if card["sub"] != "":
		tw.parallel().tween_property(_sub_lbl, "modulate", Color(1, 1, 1, 1.0), FADE_IN * 0.8)
	if _stats_row.visible:
		tw.parallel().tween_property(_stats_row, "modulate", Color(1, 1, 1, 1.0), FADE_IN * 0.75)

	# 마지막 카드: 입력 대기 + 힌트 표시
	if card["hold"] < 0:
		await tw.finished
		await get_tree().create_timer(0.3).timeout
		_show_hint()
		_waiting_input = true
		return

	# 일반 카드: hold 후 페이드아웃 → 다음 카드
	await tw.finished
	await get_tree().create_timer(card["hold"]).timeout

	if _transitioning:
		return

	var tw2 = create_tween()
	tw2.tween_property(_main_lbl, "modulate", Color(1, 1, 1, 0.0), FADE_OUT)
	if card["sub"] != "":
		tw2.parallel().tween_property(_sub_lbl, "modulate", Color(1, 1, 1, 0.0), FADE_OUT * 0.9)
	if _stats_row.visible:
		tw2.parallel().tween_property(_stats_row, "modulate", Color(1, 1, 1, 0.0), FADE_OUT * 0.9)
	await tw2.finished

	if _transitioning:
		return

	await get_tree().create_timer(0.25).timeout
	_play_card(idx + 1)

func _apply_card_stats(card: Dictionary) -> void:
	for child in _stats_row.get_children():
		child.queue_free()
	var stats: Array = card.get("stats", [])
	_stats_row.visible = not stats.is_empty()
	if stats.is_empty():
		return
	for entry in stats:
		if not entry is Array or entry.size() < 2:
			continue
		_stats_row.add_child(_make_stat_chip(str(entry[0]), str(entry[1])))

func _make_stat_chip(label_text: String, value_text: String) -> PanelContainer:
	var chip := PanelContainer.new()
	chip.custom_minimum_size = Vector2(132, 56)
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#10121a", 0.94)
	st.border_color = Color("#596273", 0.86)
	st.set_border_width_all(1)
	st.set_corner_radius_all(6)
	st.content_margin_left = 14
	st.content_margin_right = 14
	st.content_margin_top = 9
	st.content_margin_bottom = 9
	chip.add_theme_stylebox_override("panel", st)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 3)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_child(box)

	var small := Label.new()
	small.text = label_text
	small.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	small.add_theme_font_size_override("font_size", 10)
	small.add_theme_color_override("font_color", Color("#747f92"))
	_apply_font(small)
	box.add_child(small)

	var value := Label.new()
	value.text = value_text
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value.add_theme_font_size_override("font_size", 16)
	value.add_theme_color_override("font_color", Color("#e9edf4"))
	_apply_font(value, true)
	box.add_child(value)
	return chip

func _show_hint():
	var tw = create_tween()
	tw.tween_property(_hint_lbl, "modulate", Color(1, 1, 1, 1.0), 0.8)
	# 깜빡임
	await tw.finished
	var blink = create_tween().set_loops(999)
	blink.tween_property(_hint_lbl, "modulate:a", 0.3, 0.7)
	blink.tween_property(_hint_lbl, "modulate:a", 1.0, 0.7)

# ── 입력 처리 ─────────────────────────────────────────────────
func _input(event: InputEvent):
	if _transitioning:
		return
	var pressed := false
	if event is InputEventKey and event.pressed and not event.echo:
		pressed = true
	elif event is InputEventMouseButton and event.pressed:
		pressed = true
	elif event is InputEventJoypadButton and event.pressed:
		pressed = true

	if not pressed:
		return

	# 카드 진행 중: 현재 카드 스킵 → 마지막 카드로 점프
	if not _waiting_input:
		_skip_to_last()
	else:
		_go_to_menu()

func _skip_to_last():
	# 현재 텍스트 숨기고 마지막 카드로 점프
	_main_lbl.modulate = Color(1, 1, 1, 0.0)
	_sub_lbl.modulate  = Color(1, 1, 1, 0.0)
	_hint_lbl.modulate = Color(1, 1, 1, 0.0)
	var cards := CARDS_EN if LocaleManager.is_english() else CARDS
	_card_index = cards.size() - 1
	_play_card(_card_index)

func _go_to_menu():
	if _transitioning:
		return
	_transitioning = true
	SceneTransition.go("res://scenes/StartMenu.tscn")
