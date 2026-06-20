extends Control
## RouletteTable — 유럽식 룰렛 테이블.
## Roulette 수학 모델 위에 베팅·스핀·히스토리 UI 구현.
## MainGame이 overlay로 붙이고 open()으로 호출. 닫으면 closed 시그널.

signal closed

const ROULETTE := preload("res://systems/Roulette.gd")

enum Phase { IDLE, SPINNING, RESULT }

const STAKE_OPTIONS := [10_000, 50_000, 100_000, 500_000, 1_000_000]
const CHIP_TEX_BY_STAKE := {
	10_000: preload("res://assets/ui/chips/chip_10k.svg"),
	50_000: preload("res://assets/ui/chips/chip_50k.svg"),
	100_000: preload("res://assets/ui/chips/chip_100k.svg"),
	500_000: preload("res://assets/ui/chips/chip_500k.svg"),
	1_000_000: preload("res://assets/ui/chips/chip_1m.svg"),
}
const WHEEL_NUMBERS := [
	0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10,
	5, 24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26
]

# 스핀 감속 단계 정의: [인터벌(초), 반복횟수]
# 단계1: 0.05s × 24회 = 1.2초 (빠른 사이클)
# 단계2: 0.12s × 7회 = 0.84초 (느린 사이클)
# 단계3: 0.25s × 3회 = 0.75초 (마지막 3개 숫자)
const SPIN_PHASES := [
	{"interval": 0.05, "count": 24},
	{"interval": 0.12, "count": 7},
	{"interval": 0.25, "count": 3},
]
# tick SFX 재생 간격 (0.15초마다)
const SFX_TICK_INTERVAL := 0.15

# ── 상태 ──────────────────────────────────────────────────────
var _roulette: Roulette
var _rng := RandomNumberGenerator.new()

var _phase: int         = Phase.IDLE
var _bet_type: int      = -1
var _chosen_number: int = 0
var _stake: int         = 50_000
var _bet_amount: int    = 0

var _history: Array     = []   # 최근 15개 결과 (int)
var _last_result: int   = -1

var _rounds: int        = 0
var _net: float         = 0.0
var _wins: int          = 0
var _losses: int        = 0

# 스핀 애니메이션 (단계 기반)
var _spin_phase_idx: int    = 0   # SPIN_PHASES 인덱스
var _spin_phase_count: int  = 0   # 현재 단계 남은 횟수
var _spin_total_count: int  = 0   # 전체 사이클 횟수(감속 판별용)
var _display_number: int    = 0
var _result_number: int     = -1
var _spin_timer: float      = 0.0 # 현재 단계 인터벌 카운터
var _sfx_tick_timer: float  = 0.0 # tick SFX 카운터
var _wheel_angle: float     = 0.0
var _ball_angle: float      = -PI * 0.5

# UI
var _font: FontFile
var _font_bold: FontFile

var _content_root: Control
var _msg_lbl: Label
var _hud_lbl: RichTextLabel

var _number_display_lbl: Label       # 중앙 대형 숫자
var _number_panel_style: StyleBoxFlat # 숫자 패널 배경 (색상 변경용)
var _wheel_display: Control          # 룰렛 휠/볼 드로잉
var _number_picker_grid: GridContainer
var _history_box: HBoxContainer
var _bet_info_lbl: Label
var _balance_lbl: Label
var _spin_btn: Button
var _bet_btn_refs: Array = []        # 10개 베팅 타입 버튼
var _stake_btns: Array = []          # Array of {btn, amount}

# ── 초기화 ────────────────────────────────────────────────────
func _ready() -> void:
	_rng.randomize()
	_roulette = ROULETTE.new()
	_load_fonts()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 100
	_build_ui()
	visible = false
	set_process(false)

func _load_fonts() -> void:
	_font      = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile

func _f(n: Object, bold: bool = false) -> void:
	var ft: FontFile = _font_bold if bold else _font
	if ft and n:
		n.add_theme_font_override("font", ft)
		if n is RichTextLabel:
			n.add_theme_font_override("normal_font", ft)
			n.add_theme_font_override("bold_font", _font_bold if _font_bold else ft)

# ── 진입/종료 ──────────────────────────────────────────────────
func open() -> void:
	_phase        = Phase.IDLE
	_bet_type     = -1
	_chosen_number = 0
	_bet_amount   = 0
	_last_result  = -1
	_rounds = 0; _net = 0.0; _wins = 0; _losses = 0
	set_process(false)
	visible = true
	TutorialOverlay.maybe_show("roulette", self)
	_refresh()

func _on_exit() -> void:
	MetaProgression.record_minigame_play("roulette")
	set_process(false)
	visible = false
	closed.emit()

# ── 스핀 애니메이션 (단계별 감속) ──────────────────────────────
func _process(delta: float) -> void:
	if _phase != Phase.SPINNING:
		return

	_spin_timer    += delta
	_sfx_tick_timer += delta
	_wheel_angle = fmod(_wheel_angle + delta * 1.8, TAU)
	_ball_angle = fmod(_ball_angle - delta * 10.0, TAU)
	if is_instance_valid(_wheel_display):
		_wheel_display.queue_redraw()

	# tick SFX: 0.15초마다
	if _sfx_tick_timer >= SFX_TICK_INTERVAL:
		_sfx_tick_timer = 0.0
		AudioManager.play("casino_coin")

	# 현재 단계 인터벌 도달 시 숫자 교체
	var cur_interval: float = SPIN_PHASES[_spin_phase_idx]["interval"]
	if _spin_timer >= cur_interval:
		_spin_timer = 0.0
		_spin_phase_count -= 1
		_display_number = _rng.randi_range(0, 36)
		_update_number_display(_display_number, true)

		# 현재 단계 소진 → 다음 단계로
		if _spin_phase_count <= 0:
			_spin_phase_idx += 1
			if _spin_phase_idx >= SPIN_PHASES.size():
				# 모든 단계 완료 → 스핀 종료
				set_process(false)
				_finish_spin()
				return
			_spin_phase_count = SPIN_PHASES[_spin_phase_idx]["count"]

# ── 베팅 ──────────────────────────────────────────────────────
func _select_bet_type(t: int) -> void:
	if _phase != Phase.IDLE:
		return
	_bet_type = t
	AudioManager.play("casino_bet")
	_refresh()

func _select_number(n: int) -> void:
	_chosen_number = n
	AudioManager.play("casino_bet")
	_refresh()

func _select_stake(s: int) -> void:
	_stake = s
	AudioManager.play("casino_coin")
	_refresh()

func _do_bet() -> void:
	if _phase != Phase.IDLE:
		return
	if _bet_type < 0:
		_flash("베팅 유형을 선택해 주세요", "#e8c45d"); return
	if _bet_type == 0 and _chosen_number < 0:
		_flash("숫자를 선택해 주세요", "#e8c45d"); return
	if int(GameState.money) < _stake:
		_flash("현금이 부족합니다", "#e85d5d"); return
	_bet_amount = _stake
	AudioManager.play("casino_bet")
	_refresh()

func _do_spin() -> void:
	if _phase != Phase.IDLE:
		return
	if _bet_amount <= 0:
		_flash("먼저 BET 버튼을 눌러주세요", "#e8c45d"); return
	if _bet_type < 0:
		_flash("베팅 유형을 선택해 주세요", "#e8c45d"); return
	if int(GameState.money) < _bet_amount:
		_flash("현금이 부족합니다", "#e85d5d"); return

	GameState.add_money(-float(_bet_amount))
	_result_number    = _roulette.spin(_rng)
	_phase            = Phase.SPINNING

	# 감속 단계 초기화
	_spin_phase_idx   = 0
	_spin_phase_count = SPIN_PHASES[0]["count"]
	_spin_timer       = 0.0
	_sfx_tick_timer   = 0.0
	_display_number   = _rng.randi_range(0, 36)

	# 스핀 시작 SFX
	AudioManager.play("casino_spin")

	# 베팅 버튼 반투명 (스핀 중 잠금 시각화)
	_set_bet_btns_alpha(0.4)

	set_process(true)
	_refresh()

func _finish_spin() -> void:
	var result: int       = _result_number
	var won: bool         = _roulette.check_win(_bet_type, _chosen_number, result)
	var multiplier: float = _roulette.payout_multiplier(_bet_type)
	var wagered: int      = _bet_amount

	if won:
		var gain: float = float(wagered) + float(wagered) * multiplier
		GameState.add_money(gain)
		_net  += float(wagered) * multiplier
		_wins += 1
		AudioManager.play("casino_win")
		GameState.modify_hidden_stat("gambling_tendency", 2)
	else:
		_net    -= float(wagered)
		_losses += 1
		AudioManager.play("casino_lose")
		GameState.modify_hidden_stat("addiction_tendency", 2)

	_rounds     += 1
	_last_result = result
	_history.append(result)
	if _history.size() > 15:
		_history.pop_front()

	MetaProgression.record_minigame_play("roulette")
	GameState.stats_changed.emit()

	_phase      = Phase.RESULT
	_bet_amount = 0
	set_process(false)

	# 베팅 버튼 alpha 복원
	_set_bet_btns_alpha(1.0)

	# 당첨 숫자 색상으로 패널 배경 변경 + 폰트 크기 72px 확대 후 복귀
	_ball_angle = _angle_for_result(result)
	_update_number_display(result, false)
	_apply_result_highlight(result)
	if is_instance_valid(_wheel_display):
		_wheel_display.queue_redraw()

	_refresh()

	# 숫자 펄스 + 복귀 애니메이션
	if is_instance_valid(_number_display_lbl):
		var tw := create_tween()
		tw.tween_property(_number_display_lbl, "scale", Vector2(1.3, 1.3), 0.12).set_trans(Tween.TRANS_BACK)
		tw.tween_property(_number_display_lbl, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BOUNCE)

	# 결과 플래시
	if won:
		_flash("당첨!  +" + GameState.format_money(float(wagered) * multiplier), "#3de87a")
	else:
		_flash("꽝  결과: %d" % result, "#e85d5d")

	# 2.2초 후 IDLE 복귀 + 패널 배경 원래 색으로 리셋
	get_tree().create_timer(2.2).timeout.connect(func():
		if is_instance_valid(self) and _phase == Phase.RESULT:
			_phase = Phase.IDLE
			_reset_number_panel()
			_number_display_lbl.add_theme_font_size_override("font_size", 46)
			_refresh())

# ── 당첨 강조 헬퍼 ─────────────────────────────────────────────
func _apply_result_highlight(n: int) -> void:
	if not is_instance_valid(_number_display_lbl):
		return
	var col_str: String = _roulette.number_color(n)
	var panel_col: Color
	var font_col: Color
	match col_str:
		"red":
			panel_col = Color("#7a1010")
			font_col  = Color("#ff6b6b")
		"black":
			panel_col = Color("#1a1a1a")
			font_col  = Color("#e0e0e0")
		_:
			panel_col = Color("#0a4a1a")
			font_col  = Color("#27ae60")

	# 패널 배경색 변경
	if _number_panel_style != null:
		_number_panel_style.bg_color = panel_col

	# 폰트 확대 (0.3초 후 복귀는 IDLE 복귀 시 46px로 리셋)
	_number_display_lbl.add_theme_font_size_override("font_size", 58)
	_number_display_lbl.add_theme_color_override("font_color", font_col)

	# 0.3초 후 60px로 복귀 (배경은 IDLE 복귀 때까지 유지)
	get_tree().create_timer(0.3).timeout.connect(func():
		if is_instance_valid(_number_display_lbl):
			_number_display_lbl.add_theme_font_size_override("font_size", 46))

func _reset_number_panel() -> void:
	if _number_panel_style != null:
		_number_panel_style.bg_color = Color("#050907")
	if is_instance_valid(_wheel_display):
		_wheel_display.queue_redraw()

# ── 베팅 버튼 alpha 일괄 설정 ──────────────────────────────────
func _set_bet_btns_alpha(alpha: float) -> void:
	for entry in _bet_btn_refs:
		var btn = entry["btn"]
		if is_instance_valid(btn):
			btn.modulate.a = alpha

# ── 룰렛 휠 드로잉 ─────────────────────────────────────────────
func _angle_for_result(n: int) -> float:
	var idx: int = WHEEL_NUMBERS.find(n)
	if idx < 0:
		idx = 0
	return _wheel_angle + ((float(idx) + 0.5) / float(WHEEL_NUMBERS.size())) * TAU

func _draw_roulette_wheel() -> void:
	if not is_instance_valid(_wheel_display):
		return
	var sz: Vector2 = _wheel_display.size
	if sz.x < 80.0 or sz.y < 80.0:
		return
	var center: Vector2 = sz * 0.5
	var radius: float = minf(sz.x, sz.y) * 0.43
	var inner_radius: float = radius * 0.48
	var label_radius: float = radius * 0.78
	var count: int = WHEEL_NUMBERS.size()
	var font: Font = _font if _font else ThemeDB.fallback_font

	_wheel_display.draw_circle(center, radius + 10.0, Color("#2a1708"))
	_wheel_display.draw_circle(center, radius + 6.0, Color("#c58f36"))
	_wheel_display.draw_circle(center, radius + 1.0, Color("#080d09"))

	for i in range(count):
		var n: int = int(WHEEL_NUMBERS[i])
		var a0: float = _wheel_angle + float(i) / float(count) * TAU
		var a1: float = _wheel_angle + float(i + 1) / float(count) * TAU
		var mid: float = (a0 + a1) * 0.5
		var col_str: String = _roulette.number_color(n)
		var wedge_color: Color
		match col_str:
			"red":
				wedge_color = Color("#8f1515")
			"black":
				wedge_color = Color("#101010")
			_:
				wedge_color = Color("#087033")

		var points := PackedVector2Array()
		points.append(center)
		for step in range(7):
			var t: float = float(step) / 6.0
			var a: float = lerpf(a0, a1, t)
			points.append(center + Vector2(cos(a), sin(a)) * radius)
		_wheel_display.draw_colored_polygon(points, wedge_color)
		_wheel_display.draw_line(
			center + Vector2(cos(a0), sin(a0)) * inner_radius,
			center + Vector2(cos(a0), sin(a0)) * radius,
			Color(1, 1, 1, 0.10), 1.0)

		var label_pos: Vector2 = center + Vector2(cos(mid), sin(mid)) * label_radius + Vector2(-9.0, 4.0)
		_wheel_display.draw_string(font, label_pos, str(n), HORIZONTAL_ALIGNMENT_CENTER, 18.0, 9, Color("#f5f1e8"))

	_wheel_display.draw_circle(center, inner_radius, Color("#050906"))
	_wheel_display.draw_arc(center, inner_radius, 0.0, TAU, 96, Color("#c58f36"), 2.0)
	_wheel_display.draw_circle(center, inner_radius * 0.55, Color("#101b12"))
	_wheel_display.draw_arc(center, radius * 0.72, 0.0, TAU, 128, Color(1, 1, 1, 0.16), 1.0)

	var ball_pos: Vector2 = center + Vector2(cos(_ball_angle), sin(_ball_angle)) * (radius * 0.70)
	_wheel_display.draw_circle(ball_pos + Vector2(2.0, 2.0), 7.0, Color(0, 0, 0, 0.45))
	_wheel_display.draw_circle(ball_pos, 6.5, Color("#f4f2e8"))
	_wheel_display.draw_circle(ball_pos + Vector2(-2.0, -2.0), 2.0, Color(1, 1, 1, 0.9))

# ── UI 빌드 ──────────────────────────────────────────────────
func _build_ui() -> void:
	# 배경
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.06, 0.04, 0.96)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# HUD 상단 바
	var hud_panel := Panel.new()
	hud_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hud_panel.offset_bottom = 44
	var hs := StyleBoxFlat.new()
	hs.bg_color = Color("#080d08")
	hs.border_color = Color("#1a2e1a")
	hs.border_width_bottom = 1
	hud_panel.add_theme_stylebox_override("panel", hs)
	add_child(hud_panel)

	_hud_lbl = RichTextLabel.new()
	_hud_lbl.bbcode_enabled = true
	_hud_lbl.fit_content = true
	_hud_lbl.scroll_active = false
	_hud_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hud_lbl.offset_left = 16
	_hud_lbl.offset_top = 10
	_hud_lbl.offset_right = -16
	_f(_hud_lbl)
	_hud_lbl.add_theme_font_size_override("normal_font_size", 13)
	hud_panel.add_child(_hud_lbl)

	# 스크롤 컨테이너 (HUD 아래 전체)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 50
	scroll.offset_bottom = -10
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	_content_root = VBoxContainer.new()
	_content_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_root.add_theme_constant_override("separation", 10)
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	margin.add_child(_content_root)
	scroll.add_child(margin)

	# ── 중앙 룰렛 휠 / 숫자 디스플레이 ──
	var num_panel := PanelContainer.new()
	num_panel.custom_minimum_size = Vector2(0, 220)
	_number_panel_style = StyleBoxFlat.new()
	_number_panel_style.bg_color = Color("#050907")
	_number_panel_style.border_color = Color("#2a6a2a")
	_number_panel_style.set_border_width_all(2)
	_number_panel_style.set_corner_radius_all(12)
	num_panel.add_theme_stylebox_override("panel", _number_panel_style)
	_content_root.add_child(num_panel)

	_wheel_display = Control.new()
	_wheel_display.set_anchors_preset(Control.PRESET_FULL_RECT)
	_wheel_display.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_wheel_display.draw.connect(_draw_roulette_wheel)
	num_panel.add_child(_wheel_display)

	_number_display_lbl = Label.new()
	_number_display_lbl.text = "—"
	_number_display_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_number_display_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_number_display_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	_number_display_lbl.add_theme_font_size_override("font_size", 46)
	_number_display_lbl.add_theme_color_override("font_color", Color("#27ae60"))
	if _font_bold:
		_number_display_lbl.add_theme_font_override("font", _font_bold)
	num_panel.add_child(_number_display_lbl)

	# ── 히스토리 스트립 ──
	var hist_label := Label.new()
	hist_label.text = "최근 결과"
	hist_label.add_theme_font_size_override("font_size", 11)
	hist_label.add_theme_color_override("font_color", Color("#3a5a3a"))
	_f(hist_label)
	_content_root.add_child(hist_label)

	_history_box = HBoxContainer.new()
	_history_box.add_theme_constant_override("separation", 4)
	_content_root.add_child(_history_box)

	# ── 베팅 타입 버튼 (2행) ──
	var bet_lbl := Label.new()
	bet_lbl.text = "베팅 유형 선택"
	bet_lbl.add_theme_font_size_override("font_size", 11)
	bet_lbl.add_theme_color_override("font_color", Color("#4a7a4a"))
	_f(bet_lbl)
	_content_root.add_child(bet_lbl)

	_bet_btn_refs.clear()

	var row1 := HBoxContainer.new()
	row1.add_theme_constant_override("separation", 5)
	_content_root.add_child(row1)
	_build_bet_btn(row1, "단일숫자\n(35:1)",  0)
	_build_bet_btn(row1, "빨강\n(1:1)",       1)
	_build_bet_btn(row1, "검정\n(1:1)",       2)
	_build_bet_btn(row1, "홀수\n(1:1)",       3)
	_build_bet_btn(row1, "짝수\n(1:1)",       4)

	var row2 := HBoxContainer.new()
	row2.add_theme_constant_override("separation", 5)
	_content_root.add_child(row2)
	_build_bet_btn(row2, "낮음 1-18\n(1:1)",   5)
	_build_bet_btn(row2, "높음 19-36\n(1:1)",  6)
	_build_bet_btn(row2, "1묶음 1-12\n(2:1)",  7)
	_build_bet_btn(row2, "2묶음 13-24\n(2:1)", 8)
	_build_bet_btn(row2, "3묶음 25-36\n(2:1)", 9)

	# ── 숫자 선택 그리드 ──
	_number_picker_grid = GridContainer.new()
	_number_picker_grid.columns = 10
	_number_picker_grid.add_theme_constant_override("h_separation", 3)
	_number_picker_grid.add_theme_constant_override("v_separation", 3)
	_number_picker_grid.visible = false
	_content_root.add_child(_number_picker_grid)

	# 0번
	var b0 := _make_number_btn(0)
	_number_picker_grid.add_child(b0)
	# 1~36
	for n in range(1, 37):
		var bn := _make_number_btn(n)
		_number_picker_grid.add_child(bn)
	# 빈 칸 3개 (총 37개 → 4행×10열 = 40 – 37 = 3 패딩)
	for _p in range(3):
		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(32, 28)
		_number_picker_grid.add_child(spacer)

	# ── 스테이크 버튼 ──
	var stake_lbl := Label.new()
	stake_lbl.text = "베팅 금액"
	stake_lbl.add_theme_font_size_override("font_size", 11)
	stake_lbl.add_theme_color_override("font_color", Color("#4a7a4a"))
	_f(stake_lbl)
	_content_root.add_child(stake_lbl)

	var stake_row := HBoxContainer.new()
	stake_row.add_theme_constant_override("separation", 5)
	_content_root.add_child(stake_row)
	_stake_btns.clear()
	for s in STAKE_OPTIONS:
		var captured_s: int = s
		var sb := _make_btn(GameState.format_money(float(s)),
			func(): _select_stake(captured_s),
			"#1a2e1a" if s == _stake else "#0e140e",
			"#3de87a" if s == _stake else "#2a3a2a")
		_apply_chip_icon(sb, captured_s, 20)
		sb.custom_minimum_size = Vector2(94, 34)
		_f(sb)
		_stake_btns.append({"btn": sb, "amount": captured_s})
		stake_row.add_child(sb)

	# ── 액션 버튼 ──
	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 8)
	_content_root.add_child(action_row)

	var bet_action_btn := _make_btn("BET", _do_bet, "#1a2e0a", "#f39c12")
	bet_action_btn.custom_minimum_size = Vector2(0, 46)
	bet_action_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if _font_bold: bet_action_btn.add_theme_font_override("font", _font_bold)
	bet_action_btn.add_theme_font_size_override("font_size", 16)
	action_row.add_child(bet_action_btn)

	_spin_btn = _make_btn("SPIN", _do_spin, "#0a2a0a", "#27ae60")
	_spin_btn.custom_minimum_size = Vector2(0, 46)
	_spin_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if _font_bold: _spin_btn.add_theme_font_override("font", _font_bold)
	_spin_btn.add_theme_font_size_override("font_size", 16)
	action_row.add_child(_spin_btn)

	var help_btn := _make_btn("규칙", func(): TutorialOverlay.force_show("roulette", self), "#0a0a1a", "#5a4510")
	help_btn.custom_minimum_size = Vector2(60, 46)
	_f(help_btn)
	action_row.add_child(help_btn)

	var exit_btn := _make_btn("나가기", _on_exit, "#1a0e0e", "#5a2a2a")
	exit_btn.custom_minimum_size = Vector2(90, 46)
	_f(exit_btn)
	action_row.add_child(exit_btn)

	# ── 현재 베팅 정보 ──
	_bet_info_lbl = Label.new()
	_bet_info_lbl.text = ""
	_bet_info_lbl.add_theme_font_size_override("font_size", 13)
	_bet_info_lbl.add_theme_color_override("font_color", Color("#8aba8a"))
	_bet_info_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_f(_bet_info_lbl)
	_content_root.add_child(_bet_info_lbl)

	# ── 잔액 표시 ──
	_balance_lbl = Label.new()
	_balance_lbl.text = ""
	_balance_lbl.add_theme_font_size_override("font_size", 14)
	_balance_lbl.add_theme_color_override("font_color", Color("#f0b429"))
	_balance_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if _font_bold: _balance_lbl.add_theme_font_override("font", _font_bold)
	_content_root.add_child(_balance_lbl)

	# ── 플래시 메시지 ──
	_msg_lbl = Label.new()
	_msg_lbl.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_msg_lbl.offset_top = -36
	_msg_lbl.offset_bottom = -8
	_msg_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if _font_bold: _msg_lbl.add_theme_font_override("font", _font_bold)
	_msg_lbl.add_theme_font_size_override("font_size", 16)
	_msg_lbl.visible = false
	add_child(_msg_lbl)

func _build_bet_btn(parent: HBoxContainer, label_text: String, t: int) -> void:
	var btn := Button.new()
	btn.text = label_text
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(0, 52)
	_style_bet_btn(btn, t == _bet_type)
	_f(btn)
	btn.add_theme_font_size_override("font_size", 12)
	btn.pressed.connect(func(): _select_bet_type(t))
	_bet_btn_refs.append({"btn": btn, "type": t})
	parent.add_child(btn)

func _style_bet_btn(btn: Button, selected: bool) -> void:
	var bg_col: String  = "#1a3a1a" if selected else "#0e160e"
	var brd_col: String = "#f39c12" if selected else "#2a3a2a"
	var st := StyleBoxFlat.new()
	st.bg_color = Color(bg_col)
	st.border_color = Color(brd_col)
	st.set_border_width_all(2 if selected else 1)
	st.set_corner_radius_all(6)
	st.content_margin_left = 6; st.content_margin_right = 6
	st.content_margin_top = 6; st.content_margin_bottom = 6
	var hov := st.duplicate() as StyleBoxFlat
	hov.bg_color = Color(bg_col).lightened(0.12)
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_stylebox_override("hover", hov)
	btn.add_theme_stylebox_override("pressed", hov)
	btn.add_theme_color_override("font_color", Color("#f39c12") if selected else Color("#9aba9a"))

func _make_number_btn(n: int) -> Button:
	var col_str: String = _roulette.number_color(n)
	var bg: String
	match col_str:
		"red":   bg = "#5a0a0a"
		"black": bg = "#0a0a0a"
		_:       bg = "#0a3a1a"
	var btn := Button.new()
	btn.text = str(n)
	btn.custom_minimum_size = Vector2(32, 28)
	var st := StyleBoxFlat.new()
	st.bg_color = Color(bg)
	st.set_corner_radius_all(4)
	st.content_margin_left = 2; st.content_margin_right = 2
	st.content_margin_top = 2; st.content_margin_bottom = 2
	var sel_brd: bool = (_bet_type == 0 and _chosen_number == n)
	st.border_color = Color("#f39c12") if sel_brd else Color("#2a2a2a")
	st.set_border_width_all(2 if sel_brd else 1)
	var hov := st.duplicate() as StyleBoxFlat
	hov.bg_color = Color(bg).lightened(0.2)
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_stylebox_override("hover", hov)
	btn.add_theme_stylebox_override("pressed", hov)
	var txt_col: String
	match col_str:
		"red":   txt_col = "#ff6b6b"
		"black": txt_col = "#d0d0d0"
		_:       txt_col = "#2ecc71"
	btn.add_theme_color_override("font_color", Color(txt_col))
	btn.add_theme_font_size_override("font_size", 11)
	if _font: btn.add_theme_font_override("font", _font)
	btn.pressed.connect(func(): _select_number(n))
	return btn

# ── 리프레시 ──────────────────────────────────────────────────
func _refresh() -> void:
	_refresh_hud()
	_refresh_history()
	_refresh_bet_btns()
	_refresh_stake_btns()
	_refresh_number_picker()
	_refresh_bet_info()
	_refresh_balance()
	_refresh_spin_btn()

func _refresh_hud() -> void:
	var spinning_str: String = "  [스핀 중...]" if _phase == Phase.SPINNING else ""
	_hud_lbl.text = (
		"[b]유럽식 룰렛[/b]   |   현금 [b]%s[/b]   |   %d라운드   W[color=#3de87a]%d[/color] L[color=#e85d5d]%d[/color]   손익 [b]%s[/b]%s"
		% [
			GameState.format_money(GameState.money),
			_rounds, _wins, _losses,
			("+%s" % GameState.format_money(_net)) if _net >= 0 else GameState.format_money(_net),
			spinning_str
		]
	)

func _refresh_history() -> void:
	for c in _history_box.get_children():
		c.queue_free()
	for n in _history:
		var circle := Label.new()
		circle.text = str(n)
		circle.custom_minimum_size = Vector2(28, 28)
		circle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		circle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		circle.add_theme_font_size_override("font_size", 11)
		var col_str: String = _roulette.number_color(n)
		var bg_col: Color
		match col_str:
			"red":   bg_col = Color("#c0392b")
			"black": bg_col = Color("#1a1a1a")
			_:       bg_col = Color("#27ae60")
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(28, 28)
		var st := StyleBoxFlat.new()
		st.bg_color = bg_col
		st.set_corner_radius_all(14)
		st.set_border_width_all(1)
		st.border_color = bg_col.lightened(0.3)
		panel.add_theme_stylebox_override("panel", st)
		circle.add_theme_color_override("font_color", Color.WHITE)
		if _font: circle.add_theme_font_override("font", _font)
		panel.add_child(circle)
		_history_box.add_child(panel)

func _refresh_bet_btns() -> void:
	for entry in _bet_btn_refs:
		var btn: Button = entry["btn"]
		var t: int      = entry["type"]
		if is_instance_valid(btn):
			_style_bet_btn(btn, t == _bet_type)

func _refresh_stake_btns() -> void:
	for entry in _stake_btns:
		var btn: Button = entry["btn"]
		var amount: int = entry["amount"]
		if not is_instance_valid(btn):
			continue
		var selected := (amount == _stake)
		var st := StyleBoxFlat.new()
		st.bg_color = Color("#1a2e1a") if selected else Color("#0e140e")
		st.border_color = Color("#3de87a") if selected else Color("#2a3a2a")
		st.set_border_width_all(2 if selected else 1)
		st.set_corner_radius_all(6)
		st.content_margin_left = 8
		st.content_margin_right = 8
		st.content_margin_top = 6
		st.content_margin_bottom = 6
		var hov := st.duplicate() as StyleBoxFlat
		hov.bg_color = st.bg_color.lightened(0.12)
		btn.add_theme_stylebox_override("normal", st)
		btn.add_theme_stylebox_override("hover", hov)
		btn.add_theme_stylebox_override("pressed", hov)
		btn.add_theme_color_override("font_color", Color("#f0b429") if selected else Color("#c8d8c8"))

func _refresh_number_picker() -> void:
	# 결과 확인 시엔 항상 그리드 표시 (어떤 숫자에 공이 떨어졌는지 시각화)
	_number_picker_grid.visible = (_bet_type == 0 or _phase == Phase.RESULT)
	var idx: int = 0
	for child in _number_picker_grid.get_children():
		if child is Button:
			var n: int = idx
			var col_str: String = _roulette.number_color(n)
			var bg: String
			match col_str:
				"red":   bg = "#5a0a0a"
				"black": bg = "#0a0a0a"
				_:       bg = "#0a3a1a"
			var sel: bool = (_bet_type == 0 and _chosen_number == n)
			var is_result: bool = (_phase == Phase.RESULT and n == _last_result and _last_result >= 0)
			var st := StyleBoxFlat.new()
			if is_result:
				st.bg_color = Color(bg).lightened(0.45)
				st.border_color = Color("#ffffff")
				st.set_border_width_all(3)
			else:
				st.bg_color = Color(bg)
				st.border_color = Color("#f39c12") if sel else Color("#2a2a2a")
				st.set_border_width_all(2 if sel else 1)
			st.set_corner_radius_all(4)
			st.content_margin_left = 2; st.content_margin_right = 2
			st.content_margin_top = 2; st.content_margin_bottom = 2
			var hov := st.duplicate() as StyleBoxFlat
			hov.bg_color = Color(bg).lightened(0.2)
			child.add_theme_stylebox_override("normal", st)
			child.add_theme_stylebox_override("hover", hov)
			child.add_theme_stylebox_override("pressed", hov)
			if is_result:
				child.add_theme_color_override("font_color", Color.WHITE)
			idx += 1

func _refresh_bet_info() -> void:
	if _bet_amount > 0:
		var payout: float = _roulette.payout_multiplier(_bet_type)
		var potential: float = float(_bet_amount) * (1.0 + payout)
		_bet_info_lbl.text = "베팅: %s   |   배당: %.0f:1   |   당첨 시 수령: %s" % [
			GameState.format_money(float(_bet_amount)),
			payout,
			GameState.format_money(potential)
		]
	elif _bet_type >= 0:
		var payout: float = _roulette.payout_multiplier(_bet_type)
		_bet_info_lbl.text = "배당률: %.0f:1   |   베팅 금액: %s   →   BET 버튼 클릭" % [
			payout,
			GameState.format_money(float(_stake))
		]
	else:
		_bet_info_lbl.text = "베팅 유형을 선택하세요"

func _refresh_balance() -> void:
	_balance_lbl.text = "잔액: %s" % GameState.format_money(GameState.money)

func _refresh_spin_btn() -> void:
	if not is_instance_valid(_spin_btn):
		return
	var can_spin: bool = (_phase == Phase.IDLE and _bet_amount > 0)
	_spin_btn.disabled = not can_spin
	var st := StyleBoxFlat.new()
	if can_spin:
		st.bg_color = Color("#0a3a0a")
		st.border_color = Color("#27ae60")
	else:
		st.bg_color = Color("#0e140e")
		st.border_color = Color("#1a2a1a")
	st.set_border_width_all(2)
	st.set_corner_radius_all(6)
	st.content_margin_left = 12; st.content_margin_right = 12
	st.content_margin_top = 8; st.content_margin_bottom = 8
	var hov := st.duplicate() as StyleBoxFlat
	hov.bg_color = Color("#0a3a0a").lightened(0.15)
	_spin_btn.add_theme_stylebox_override("normal", st)
	_spin_btn.add_theme_stylebox_override("hover", hov)
	_spin_btn.add_theme_stylebox_override("pressed", hov)
	var dis := StyleBoxFlat.new()
	dis.bg_color = Color("#0e140e"); dis.border_color = Color("#1a2a1a")
	dis.set_border_width_all(1); dis.set_corner_radius_all(6)
	dis.content_margin_left = 12; dis.content_margin_right = 12
	dis.content_margin_top = 8; dis.content_margin_bottom = 8
	_spin_btn.add_theme_stylebox_override("disabled", dis)

# 스핀 중 숫자 디스플레이 업데이트
func _update_number_display(n: int, cycling: bool) -> void:
	if not is_instance_valid(_number_display_lbl):
		return
	_number_display_lbl.text = str(n)
	var col_str: String = _roulette.number_color(n)
	var col: Color
	match col_str:
		"red":   col = Color("#c0392b")
		"black": col = Color("#e0e0e0")
		_:       col = Color("#27ae60")
	_number_display_lbl.add_theme_color_override("font_color", col)
	if cycling:
		# 순간적으로 밝게 표시
		_number_display_lbl.modulate = Color(1.2, 1.2, 1.2, 1.0)
	else:
		_number_display_lbl.modulate = Color.WHITE

# ── UI 헬퍼 ──────────────────────────────────────────────────
func _apply_chip_icon(btn: Button, stake: int, max_width: int) -> void:
	if not CHIP_TEX_BY_STAKE.has(stake):
		return
	btn.icon = CHIP_TEX_BY_STAKE[stake]
	btn.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.expand_icon = false
	btn.add_theme_constant_override("h_separation", 6)
	btn.add_theme_constant_override("icon_max_width", max_width)

func _make_btn(label_text: String, cb: Callable, bg: String, border: String) -> Button:
	var btn := Button.new()
	btn.text = label_text
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color(bg)
	st.border_color = Color(border)
	st.set_border_width_all(1)
	st.set_corner_radius_all(6)
	st.content_margin_left = 12; st.content_margin_right = 12
	st.content_margin_top = 8; st.content_margin_bottom = 8
	var hov := st.duplicate() as StyleBoxFlat
	hov.bg_color = Color(bg).lightened(0.12)
	var dis := StyleBoxFlat.new()
	dis.bg_color = Color("#0e0e14"); dis.border_color = Color("#1a1a22")
	dis.set_border_width_all(1); dis.set_corner_radius_all(6)
	dis.content_margin_left = 12; dis.content_margin_right = 12
	dis.content_margin_top = 8; dis.content_margin_bottom = 8
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_stylebox_override("hover", hov)
	btn.add_theme_stylebox_override("pressed", hov)
	btn.add_theme_stylebox_override("disabled", dis)
	btn.add_theme_color_override("font_color", Color("#dce4f0"))
	btn.add_theme_color_override("font_disabled_color", Color("#3a3a48"))
	btn.add_theme_font_size_override("font_size", 14)
	if _font: btn.add_theme_font_override("font", _font)
	btn.pressed.connect(cb)
	return btn

func _flash(msg: String, color: String) -> void:
	_msg_lbl.text = msg
	_msg_lbl.add_theme_color_override("font_color", Color(color))
	_msg_lbl.visible = true
	get_tree().create_timer(1.8).timeout.connect(func():
		if is_instance_valid(_msg_lbl): _msg_lbl.visible = false)
