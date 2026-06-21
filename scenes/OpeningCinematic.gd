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
		"sub": "",
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
		"text": "이것은, 당신의 이야기다.",
		"sub": "",
		"hold": -1,
		"size": 32,
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
		"sub": "At minimum wage, saving every won would take 82 years.",
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
		"sub": "",
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
		"text": "This is your story.",
		"sub": "",
		"hold": -1,
		"size": 32,
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

	# 메인 텍스트 페이드인
	_main_lbl.modulate = Color(1, 1, 1, 0.0)
	_sub_lbl.modulate  = Color(1, 1, 1, 0.0)

	var tw = create_tween()
	tw.tween_property(_main_lbl, "modulate", Color(1, 1, 1, 1.0), FADE_IN)

	if card["sub"] != "":
		tw.tween_property(_sub_lbl, "modulate", Color(1, 1, 1, 1.0), FADE_IN * 0.8)

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
		tw2.tween_property(_sub_lbl, "modulate", Color(1, 1, 1, 0.0), FADE_OUT * 0.9)
	await tw2.finished

	if _transitioning:
		return

	await get_tree().create_timer(0.25).timeout
	_play_card(idx + 1)

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
