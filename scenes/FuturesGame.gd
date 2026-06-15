extends Control
## FuturesGame — 선물 레버리지 트레이딩 미니게임
## 레버리지·방향·금액을 선택 → 5틱 가격 변동 → 청산 or 마진콜.
## 레버리지가 높을수록 수익도 크고 마진콜 위험도 크다.
## 결과는 GameState.money에 직접 반영.

signal closed

const TICK_COUNT:   int   = 5
const TICK_PAUSE:   float = 2.4   # 틱 사이 대기 (자동 진행)
const MARGIN_RATIO: float = 1.0   # 마진콜: 레버 역수만큼 손실 시 강제 청산
                                  # (1x→100%, 2x→50%, 5x→20%, 10x→10%)

enum Phase { SETUP, TRADING, RESULT }

var _phase:     int   = Phase.SETUP
var _leverage:  int   = 1
var _direction: String = "long"   # "long" / "short"
var _amount:    int   = 500_000
var _price:     float = 100.0
var _entry:     float = 100.0
var _ticks_done: int  = 0
var _tick_timer: float = 0.0
var _pnl:       float = 0.0
var _margin_called: bool = false
var _closed_early:  bool = false
var _price_history: Array = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

# UI
var _header_lbl:  Label
var _phase_lbl:   Label
var _chart_lbl:   RichTextLabel
var _price_lbl:   Label
var _pnl_lbl:     Label
var _margin_bar:  ProgressBar
var _margin_lbl:  Label
var _result_lbl:  RichTextLabel
var _btn_a:       Button
var _btn_b:       Button
var _btn_c:       Button
var _btn_close:   Button
var _margin_fill: StyleBoxFlat

var _font:      FontFile
var _font_bold: FontFile

# ── 초기화 ─────────────────────────────────────────────────────────
func _ready() -> void:
	_rng.randomize()
	_font      = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile
	_build_ui()
	visible = false
	set_process(false)

func _af(n: Control, bold := false) -> void:
	var ft = _font_bold if bold else _font
	if ft and n: n.add_theme_font_override("font", ft)

func open() -> void:
	_rng.randomize()
	_phase        = Phase.SETUP
	_leverage     = 1
	_direction    = "long"
	_amount       = 500_000
	_ticks_done   = 0
	_margin_called = false
	_closed_early  = false
	_price_history.clear()
	visible = true
	set_process(false)
	_rebuild()

# ── 프로세스 (TRADING 단계만) ──────────────────────────────────────
func _process(delta: float) -> void:
	if _phase != Phase.TRADING:
		return
	_tick_timer -= delta
	if _tick_timer <= 0.0:
		_do_tick()

# ── 버튼 핸들러 ────────────────────────────────────────────────────
func _on_btn_a() -> void:
	match _phase:
		Phase.SETUP:
			if _header_lbl.text.contains("방향"):
				_direction = "long"
				_show_amount_selection()
			elif _header_lbl.text.contains("금액"):
				_amount = 300_000
				_start_trading()
			else:
				_leverage = 1
				_show_direction_selection()
		Phase.TRADING:
			_close_position_early()
		Phase.RESULT:
			_close_game()

func _on_btn_b() -> void:
	match _phase:
		Phase.SETUP:
			if _header_lbl.text.contains("방향"):
				_direction = "short"
				_show_amount_selection()
			elif _header_lbl.text.contains("금액"):
				_amount = 700_000
				_start_trading()
			else:
				_leverage = 3
				_show_direction_selection()
		Phase.TRADING:
			pass  # 홀드 — 아무것도 안 함

func _on_btn_c() -> void:
	match _phase:
		Phase.SETUP:
			if _header_lbl.text.contains("방향"):
				pass  # 방향 화면엔 버튼C 없음
			elif _header_lbl.text.contains("금액"):
				_amount = 1_500_000
				_start_trading()
			else:
				_leverage = 10
				_show_direction_selection()

# ── SETUP 단계 ─────────────────────────────────────────────────────
func _show_leverage_selection() -> void:
	_header_lbl.text = "⚙  레버리지 선택"
	_phase_lbl.text  = "레버리지가 높을수록 수익·손실 모두 배수로 커집니다.\n마진 소진 시 강제 청산(마진콜)됩니다."
	_chart_lbl.text  = ""
	_price_lbl.text  = ""
	_pnl_lbl.text    = ""
	_margin_bar.visible = false
	_result_lbl.text = ""

	_btn_a.text = "1x  —  안전 (마진 소진 없음)"
	_btn_b.text = "3x  —  적정 (마진 33% 손실 시 청산)"
	_btn_c.text = "10x —  고위험 (마진 10% 손실 시 청산)"
	for b in [_btn_a, _btn_b, _btn_c]: b.visible = true; b.disabled = false

func _show_direction_selection() -> void:
	_header_lbl.text = "⚙  방향 선택"
	var risk_text: String
	match _leverage:
		1: risk_text = "레버리지 1x (안전)"
		3: risk_text = "레버리지 3x (마진 33% 시 청산)"
		_: risk_text = "레버리지 10x ⚠ 고위험"
	_phase_lbl.text = risk_text + "\n롱: 가격 상승에 베팅 / 숏: 가격 하락에 베팅"
	_btn_a.text = "📈  롱  (상승 베팅)"
	_btn_b.text = "📉  숏  (하락 베팅)"
	_btn_c.visible = false
	for b in [_btn_a, _btn_b]: b.disabled = false

func _show_amount_selection() -> void:
	_header_lbl.text = "⚙  투자 금액"
	var lev_kr: String = "%dx" % _leverage
	var dir_kr: String = "📈 롱" if _direction == "long" else "📉 숏"
	_phase_lbl.text = "%s %s — 금액을 선택하세요." % [lev_kr, dir_kr]
	_btn_a.text = "소액  ₩300,000"
	_btn_b.text = "표준  ₩700,000"
	_btn_c.text = "공격  ₩1,500,000"
	_btn_c.visible = true
	for b in [_btn_a, _btn_b, _btn_c]: b.disabled = false

# ── TRADING 단계 ───────────────────────────────────────────────────
func _start_trading() -> void:
	# 충분한 돈 없으면 레버 없이 제한
	if GameState.money < _amount:
		_amount = int(GameState.money * 0.8)
		_amount = maxi(_amount, 100_000)
	_phase     = Phase.TRADING
	_price     = 100.0
	_entry     = 100.0
	_ticks_done = 0
	_tick_timer = TICK_PAUSE
	_price_history = [_price]
	_pnl       = 0.0
	set_process(true)
	_draw_trading()

func _do_tick() -> void:
	_ticks_done += 1
	# 가격 이동: ±2~9% per tick
	var move: float = _rng.randf_range(-0.09, 0.09)
	_price = maxf(_price * (1.0 + move), 1.0)
	_price_history.append(_price)

	# P&L 계산
	var raw_move: float = (_price - _entry) / _entry
	var dir_mult: float = 1.0 if _direction == "long" else -1.0
	_pnl = float(_amount) * raw_move * float(_leverage) * dir_mult

	# 마진콜 체크
	var margin_threshold: float = -float(_amount) * (1.0 / float(_leverage))
	if _pnl <= margin_threshold:
		_margin_called = true
		_finish_trading()
		return

	if _ticks_done >= TICK_COUNT:
		_finish_trading()
		return

	_tick_timer = TICK_PAUSE
	_draw_trading()

func _close_position_early() -> void:
	if _phase != Phase.TRADING:
		return
	set_process(false)
	_closed_early = true
	_finish_trading()

func _finish_trading() -> void:
	set_process(false)
	_phase = Phase.RESULT
	_apply_result()
	_draw_result()

func _apply_result() -> void:
	var profit: int = int(_pnl)
	if profit != 0:
		GameState.add_money(float(profit))
	if profit > 0:
		GameState.add_log("📊 선물거래 +%s (레버 %dx)" % [GameState.format_money(profit), _leverage], "invest")
		GameState.investment_skill = mini(GameState.investment_skill + 1, 100)
	elif profit < 0:
		GameState.add_log("📊 선물거래 %s (레버 %dx%s)" % [
			GameState.format_money(profit), _leverage,
			" 마진콜" if _margin_called else ""], "invest")
		if _margin_called:
			GameState.modify_hidden_stat("stress", 8)

# ── UI 드로우 ──────────────────────────────────────────────────────
func _draw_trading() -> void:
	var dir_kr: String = "📈 롱" if _direction == "long" else "📉 숏"
	_header_lbl.text = "📊 선물 트레이딩  —  %dx %s" % [_leverage, dir_kr]
	_phase_lbl.text  = "틱 %d / %d" % [_ticks_done, TICK_COUNT]
	_price_lbl.text  = "현재가: %.2f  (진입가: %.2f)" % [_price, _entry]

	# 차트 (ASCII 스파크라인)
	var parts: Array = []
	for i in range(_price_history.size()):
		if i == 0:
			parts.append("[color=#8892a4]●[/color]")
		else:
			var diff: float = _price_history[i] - _price_history[i - 1]
			if diff > 0:
				parts.append("[color=#00c896]▲[/color]")
			else:
				parts.append("[color=#ff4444]▼[/color]")
	_chart_lbl.text = "  ".join(parts)

	# P&L
	var pnl_color: String = "#00c896" if _pnl >= 0 else "#ff4444"
	var pnl_sign: String  = "+" if _pnl >= 0 else ""
	_pnl_lbl.text = "평가손익: [color=%s]%s%s[/color]" % [pnl_color, pnl_sign, GameState.format_money(int(_pnl))]
	_pnl_lbl.bbcode_enabled = true

	# 마진 잔여 바
	_margin_bar.visible = _leverage > 1
	if _leverage > 1:
		var max_loss: float = float(_amount) * (1.0 / float(_leverage))
		var cur_loss: float = maxf(-_pnl, 0.0)
		var ratio: float    = 1.0 - clampf(cur_loss / max_loss, 0.0, 1.0)
		_margin_bar.value   = ratio * 100.0
		if   ratio > 0.5: _margin_fill.bg_color = Color("#00c896")
		elif ratio > 0.25: _margin_fill.bg_color = Color("#f0b429")
		else:              _margin_fill.bg_color = Color("#ff4444")
		_margin_bar.add_theme_stylebox_override("fill", _margin_fill)
		_margin_lbl.text = "마진 잔여 %.0f%%" % (ratio * 100.0)

	# 버튼
	_btn_a.text    = "🚪 청산 (지금 확정)"
	_btn_b.text    = "⏳ 홀드 (다음 틱 대기)"
	_btn_c.visible = false
	_btn_a.disabled = false
	_btn_b.disabled = false

func _draw_result() -> void:
	var profit: int = int(_pnl)
	_phase_lbl.text = ""
	_price_lbl.text = ""
	_chart_lbl.text = ""
	_margin_bar.visible = false

	var reason: String
	if _margin_called:    reason = "⚠ 마진콜 — 강제 청산"
	elif _closed_early:   reason = "✋ 조기 청산"
	else:                 reason = "⏱ %d틱 만료" % TICK_COUNT

	var col: String = "#00c896" if profit >= 0 else "#ff4444"
	var sign: String = "+" if profit >= 0 else ""
	_header_lbl.text = "📊 선물거래 결과"
	_result_lbl.text = (
		"[b]%s[/b]\n\n"
		+ "투자금: %s  |  레버리지: %dx\n"
		+ "진입가: %.2f → 청산가: %.2f\n\n"
		+ "[color=%s][b]최종 손익: %s%s[/b][/color]"
	) % [
		reason,
		GameState.format_money(_amount), _leverage,
		_entry, _price,
		col, sign, GameState.format_money(profit)
	]

	if _margin_called:
		_result_lbl.text += "\n\n[color=#ff8888]레버리지 포지션은 마진이 소진되면 전액 손실됩니다.[/color]"

	_btn_a.text    = "확인  ▶"
	_btn_b.visible = false
	_btn_c.visible = false
	_btn_a.disabled = false

# ── UI 빌드 (1회) ──────────────────────────────────────────────────
func _rebuild() -> void:
	_show_leverage_selection()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#050c10")
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	add_child(margin)

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	margin.add_child(body)

	# 헤더
	var hdr := HBoxContainer.new()
	hdr.add_theme_constant_override("separation", 8)
	body.add_child(hdr)
	_header_lbl = _lbl("📊 선물 트레이딩", 20, "#5b9cf6", true)
	_header_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(_header_lbl)
	_btn_close = _make_btn("✕", "#2a1818")
	_btn_close.custom_minimum_size = Vector2(32, 32)
	_btn_close.pressed.connect(_force_close)
	hdr.add_child(_btn_close)

	# 단계 설명
	_phase_lbl = _lbl("", 13, "#8892a4")
	_phase_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(_phase_lbl)

	# 차트
	_chart_lbl = RichTextLabel.new()
	_chart_lbl.bbcode_enabled = true
	_chart_lbl.fit_content = true
	_chart_lbl.custom_minimum_size = Vector2(0, 32)
	_af(_chart_lbl)
	body.add_child(_chart_lbl)

	# 현재가
	_price_lbl = _lbl("", 14, "#c8d0df")
	body.add_child(_price_lbl)

	# 손익
	_pnl_lbl = RichTextLabel.new()
	_pnl_lbl.bbcode_enabled = true
	_pnl_lbl.fit_content = true
	_pnl_lbl.custom_minimum_size = Vector2(0, 28)
	_af(_pnl_lbl, true)
	body.add_child(_pnl_lbl)

	# 마진 바
	var margin_row := HBoxContainer.new()
	margin_row.add_theme_constant_override("separation", 8)
	body.add_child(margin_row)
	_margin_bar = ProgressBar.new()
	_margin_bar.min_value = 0.0
	_margin_bar.max_value = 100.0
	_margin_bar.value     = 100.0
	_margin_bar.show_percentage = false
	_margin_bar.custom_minimum_size = Vector2(0, 8)
	_margin_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_margin_fill = StyleBoxFlat.new()
	_margin_fill.bg_color = Color("#00c896")
	_margin_fill.set_corner_radius_all(4)
	_margin_bar.add_theme_stylebox_override("fill", _margin_fill)
	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color = Color("#1a2030")
	bar_bg.set_corner_radius_all(4)
	_margin_bar.add_theme_stylebox_override("background", bar_bg)
	_margin_bar.visible = false
	margin_row.add_child(_margin_bar)
	_margin_lbl = _lbl("", 12, "#8892a4")
	margin_row.add_child(_margin_lbl)

	# 결과
	_result_lbl = RichTextLabel.new()
	_result_lbl.bbcode_enabled = true
	_result_lbl.fit_content = true
	_result_lbl.custom_minimum_size = Vector2(0, 80)
	_af(_result_lbl)
	body.add_child(_result_lbl)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color("#1a2030"))
	body.add_child(sep)

	# 액션 버튼
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 10)
	body.add_child(btn_row)
	_btn_a = _make_btn("", "#0a1a0a"); _btn_a.pressed.connect(_on_btn_a)
	_btn_b = _make_btn("", "#1a1a2a"); _btn_b.pressed.connect(_on_btn_b)
	_btn_c = _make_btn("", "#2a0a0a"); _btn_c.pressed.connect(_on_btn_c)
	for b in [_btn_a, _btn_b, _btn_c]:
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size = Vector2(0, 48)
		btn_row.add_child(b)

# ── 종료 ───────────────────────────────────────────────────────────
func _close_game() -> void:
	visible = false
	emit_signal("closed")

func _force_close() -> void:
	set_process(false)
	if _phase == Phase.TRADING:
		_pnl = 0.0
		GameState.add_log("📊 선물거래 조기 종료", "invest")
	visible = false
	emit_signal("closed")

# ── 위젯 헬퍼 ─────────────────────────────────────────────────────
func _lbl(text: String, size: int, color: String, bold := false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color(color))
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_af(l, bold)
	return l

func _make_btn(text: String, bg: String) -> Button:
	var b := Button.new()
	b.text = text
	var st := StyleBoxFlat.new()
	st.bg_color     = Color(bg)
	st.border_color = Color(bg).lightened(0.25)
	for prop in ["border_width_left", "border_width_right", "border_width_top", "border_width_bottom"]:
		st.set(prop, 2)
	st.set_corner_radius_all(4)
	st.content_margin_left  = 12; st.content_margin_right  = 12
	st.content_margin_top   = 8;  st.content_margin_bottom = 8
	b.add_theme_stylebox_override("normal", st)
	var hov := st.duplicate() as StyleBoxFlat
	hov.bg_color = Color(bg).lightened(0.15)
	b.add_theme_stylebox_override("hover", hov)
	_af(b, true)
	return b
