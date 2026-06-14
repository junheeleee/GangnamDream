extends Control
## RouletteTable — 유럽식 룰렛 테이블.
## Roulette 수학 모델 위에 베팅·스핀·히스토리 UI 구현.
## MainGame이 overlay로 붙이고 open()으로 호출. 닫으면 closed 시그널.

signal closed

const ROULETTE := preload("res://systems/Roulette.gd")

enum Phase { IDLE, SPINNING, RESULT }

const STAKE_OPTIONS := [10_000, 50_000, 100_000, 500_000, 1_000_000]
const SPIN_DURATION := 2.0
const CYCLE_RATE    := 0.07   # 초당 숫자 갱신 간격 (스핀 중)

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

# 스핀 애니메이션
var _spin_elapsed: float = 0.0
var _cycle_timer: float  = 0.0
var _display_number: int = 0
var _result_number: int  = -1

# UI
var _font: FontFile
var _font_bold: FontFile

var _content_root: Control
var _msg_lbl: Label
var _hud_lbl: RichTextLabel

var _number_display_lbl: Label       # 중앙 대형 숫자
var _number_picker_grid: GridContainer
var _history_box: HBoxContainer
var _bet_info_lbl: Label
var _balance_lbl: Label
var _spin_btn: Button
var _bet_btn_refs: Array = []        # 10개 베팅 타입 버튼

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

# ── 스핀 애니메이션 ────────────────────────────────────────────
func _process(delta: float) -> void:
	if _phase != Phase.SPINNING:
		return
	_spin_elapsed += delta
	_cycle_timer  += delta

	if _cycle_timer >= CYCLE_RATE:
		_cycle_timer = 0.0
		_display_number = _rng.randi_range(0, 36)
		_update_number_display(_display_number, true)

	if _spin_elapsed >= SPIN_DURATION:
		set_process(false)
		_finish_spin()

# ── 베팅 ──────────────────────────────────────────────────────
func _select_bet_type(t: int) -> void:
	if _phase != Phase.IDLE:
		return
	_bet_type = t
	AudioManager.play_sfx("bet")
	_refresh()

func _select_number(n: int) -> void:
	_chosen_number = n
	AudioManager.play_sfx("bet")
	_refresh()

func _select_stake(s: int) -> void:
	_stake = s
	AudioManager.play_sfx("coin")
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
	AudioManager.play_sfx("bet")
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
	_result_number  = _roulette.spin(_rng)
	_phase          = Phase.SPINNING
	_spin_elapsed   = 0.0
	_cycle_timer    = 0.0
	_display_number = _rng.randi_range(0, 36)
	AudioManager.play_sfx("bet")
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
		AudioManager.play_sfx("win")
		GameState.modify_hidden_stat("gambling_tendency", 2)
	else:
		_net    -= float(wagered)
		_losses += 1
		AudioManager.play_sfx("lose")
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
	_update_number_display(result, false)
	_refresh()
	# 결과 플래시 후 IDLE로 복귀
	if won:
		_flash("🎉 당첨!  +" + GameState.format_money(float(wagered) * multiplier), "#3de87a")
	else:
		_flash("😢 꽝  결과: %d" % result, "#e85d5d")
	get_tree().create_timer(2.2).timeout.connect(func():
		if is_instance_valid(self) and _phase == Phase.RESULT:
			_phase = Phase.IDLE
			_refresh())

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

	# ── 중앙 숫자 디스플레이 ──
	var num_panel := PanelContainer.new()
	num_panel.custom_minimum_size = Vector2(0, 100)
	var num_st := StyleBoxFlat.new()
	num_st.bg_color = Color("#0a160a")
	num_st.border_color = Color("#2a6a2a")
	num_st.set_border_width_all(2)
	num_st.set_corner_radius_all(12)
	num_panel.add_theme_stylebox_override("panel", num_st)
	_content_root.add_child(num_panel)

	_number_display_lbl = Label.new()
	_number_display_lbl.text = "—"
	_number_display_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_number_display_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_number_display_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	_number_display_lbl.add_theme_font_size_override("font_size", 60)
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
	for s in STAKE_OPTIONS:
		var captured_s: int = s
		var sb := _make_btn(GameState.format_money(float(s)),
			func(): _select_stake(captured_s),
			"#1a2e1a" if s == _stake else "#0e140e",
			"#3de87a" if s == _stake else "#2a3a2a")
		sb.custom_minimum_size = Vector2(80, 32)
		_f(sb)
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
	_refresh_number_picker()
	_refresh_bet_info()
	_refresh_balance()
	_refresh_spin_btn()

func _refresh_hud() -> void:
	var spinning_str: String = "  [스핀 중...]" if _phase == Phase.SPINNING else ""
	_hud_lbl.text = (
		"🎡 [b]유럽식 룰렛[/b]   |   💰 [b]%s[/b]   |   %d라운드   W[color=#3de87a]%d[/color] L[color=#e85d5d]%d[/color]   손익 [b]%s[/b]%s"
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

func _refresh_number_picker() -> void:
	_number_picker_grid.visible = (_bet_type == 0)
	# 숫자 버튼 border 재스타일 (선택 표시)
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
			var st := StyleBoxFlat.new()
			st.bg_color = Color(bg)
			st.set_corner_radius_all(4)
			st.content_margin_left = 2; st.content_margin_right = 2
			st.content_margin_top = 2; st.content_margin_bottom = 2
			st.border_color = Color("#f39c12") if sel else Color("#2a2a2a")
			st.set_border_width_all(2 if sel else 1)
			var hov := st.duplicate() as StyleBoxFlat
			hov.bg_color = Color(bg).lightened(0.2)
			child.add_theme_stylebox_override("normal", st)
			child.add_theme_stylebox_override("hover", hov)
			child.add_theme_stylebox_override("pressed", hov)
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
	_balance_lbl.text = "💰 잔액: %s" % GameState.format_money(GameState.money)

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

