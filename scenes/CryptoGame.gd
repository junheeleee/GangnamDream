extends Control
## CryptoGame — 코인 변동성 단타 미니게임
## 3라운드. 캔들 흐름을 보고 롱/숏/패스 판단.
## 투자감각이 높을수록 추세 힌트가 해금된다.
## 결과는 GameState.money에 직접 반영 후 signal closed 발생.

signal closed

const ROUNDS:       int   = 3
const ROUND_TIMER:  float = 12.0
const RESULT_PAUSE: float = 2.8
const CANDLE_COUNT: int   = 5

enum Phase { SETUP, ANALYSIS, REVEAL, FINAL }

var _phase:         int   = Phase.SETUP
var _round:         int   = 0
var _timer:         float = 0.0
var _stake:         int   = 500_000
var _total_profit:  int   = 0
var _round_results: Array = []   # [{choice, move, profit}]
var _candles:       Array = []   # [float] 5개 이전 캔들 등락률
var _actual_move:   float = 0.0  # 이번 라운드 실제 등락률
var _player_choice: String = ""
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

# UI
var _header_lbl:  Label
var _timer_bar:   ProgressBar
var _timer_lbl:   Label
var _round_lbl:   Label
var _stake_lbl:   Label
var _candle_lbl:  RichTextLabel
var _hint_lbl:    Label
var _result_lbl:  RichTextLabel
var _total_lbl:   Label
var _btn_long:    Button
var _btn_short:   Button
var _btn_pass:    Button
var _timer_style: StyleBoxFlat

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

# ── 진입 ───────────────────────────────────────────────────────────
func open() -> void:
	_rng.randomize()
	_phase        = Phase.SETUP
	_round        = 0
	_total_profit = 0
	_stake        = 500_000
	_round_results.clear()
	visible = true
	set_process(false)
	_rebuild()

# ── 메인 루프 ──────────────────────────────────────────────────────
func _process(delta: float) -> void:
	if _phase == Phase.ANALYSIS:
		_timer -= delta
		_refresh_timer_bar()
		if _timer <= 0.0:
			_make_choice("pass")
	elif _phase == Phase.REVEAL:
		_timer -= delta
		if _timer <= 0.0:
			_advance_round()

# ── 버튼 핸들러 (연결은 _build_ui에서 1회만) ──────────────────────
func _on_btn_long() -> void:
	if _phase == Phase.SETUP:
		_start_game(200_000)
	elif _phase == Phase.ANALYSIS:
		_make_choice("long")

func _on_btn_short() -> void:
	if _phase == Phase.SETUP:
		_start_game(500_000)
	elif _phase == Phase.ANALYSIS:
		_make_choice("short")

func _on_btn_pass() -> void:
	if _phase == Phase.SETUP:
		_start_game(1_000_000)
	elif _phase == Phase.ANALYSIS:
		_make_choice("pass")
	elif _phase == Phase.FINAL:
		_close_game()

# ── 선택 처리 ──────────────────────────────────────────────────────
func _make_choice(choice: String) -> void:
	if _phase != Phase.ANALYSIS:
		return
	_player_choice = choice
	_phase = Phase.REVEAL
	_timer = RESULT_PAUSE
	_btn_long.disabled  = true
	_btn_short.disabled = true
	_btn_pass.disabled  = true

	var profit: int = 0
	if choice == "long":
		profit = int(float(_stake) * _actual_move)
	elif choice == "short":
		profit = int(float(_stake) * -_actual_move)

	_total_profit += profit
	_round_results.append({"choice": choice, "move": _actual_move, "profit": profit})
	_show_round_result(profit)

func _advance_round() -> void:
	_round += 1
	if _round >= ROUNDS:
		_phase = Phase.FINAL
		_apply_result()
		_rebuild()
	else:
		_phase = Phase.ANALYSIS
		_generate_candles()
		_timer = ROUND_TIMER
		_rebuild()

# ── 캔들 생성 ──────────────────────────────────────────────────────
func _generate_candles() -> void:
	_candles.clear()
	var bias: float = _rng.randf_range(-0.04, 0.04)
	for _i in range(CANDLE_COUNT):
		_candles.append(bias + _rng.randf_range(-0.07, 0.07))
	var momentum: float = 0.0
	for c in _candles:
		momentum += c
	momentum /= float(_candles.size())
	_actual_move = momentum * 0.4 + _rng.randf_range(-0.18, 0.18)
	_actual_move = clampf(_actual_move, -0.25, 0.25)

# ── 게임 시작 ──────────────────────────────────────────────────────
func _start_game(stake: int) -> void:
	_stake = stake
	_round = 0
	_total_profit = 0
	_round_results.clear()
	_phase = Phase.ANALYSIS
	_generate_candles()
	_timer = ROUND_TIMER
	set_process(true)
	_rebuild()

# ── UI 빌드 ────────────────────────────────────────────────────────
func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#080c14")
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	add_child(margin)

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	margin.add_child(body)

	# 헤더 행
	var hdr := HBoxContainer.new()
	hdr.add_theme_constant_override("separation", 8)
	body.add_child(hdr)
	_header_lbl = _lbl("🪙 코인 단타", 20, "#f0b429", true)
	_header_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(_header_lbl)
	_timer_lbl = _lbl("", 14, "#5b9cf6", true)
	hdr.add_child(_timer_lbl)
	var close_btn := _make_btn("✕", "#2a1818")
	close_btn.custom_minimum_size = Vector2(32, 32)
	close_btn.pressed.connect(_force_close)
	hdr.add_child(close_btn)

	# 타이머 바
	_timer_bar = ProgressBar.new()
	_timer_bar.min_value = 0.0
	_timer_bar.max_value = ROUND_TIMER
	_timer_bar.value = ROUND_TIMER
	_timer_bar.show_percentage = false
	_timer_bar.custom_minimum_size = Vector2(0, 6)
	_timer_style = StyleBoxFlat.new()
	_timer_style.bg_color = Color("#00c896")
	_timer_style.set_corner_radius_all(3)
	_timer_bar.add_theme_stylebox_override("fill", _timer_style)
	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color = Color("#1a2030")
	bar_bg.set_corner_radius_all(3)
	_timer_bar.add_theme_stylebox_override("background", bar_bg)
	body.add_child(_timer_bar)

	# 라운드 / 베팅금 행
	var info_row := HBoxContainer.new()
	info_row.add_theme_constant_override("separation", 12)
	body.add_child(info_row)
	_round_lbl = _lbl("", 13, "#8892a4")
	_round_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_row.add_child(_round_lbl)
	_stake_lbl = _lbl("", 13, "#c8a060")
	info_row.add_child(_stake_lbl)

	# 캔들 디스플레이
	_candle_lbl = RichTextLabel.new()
	_candle_lbl.bbcode_enabled = true
	_candle_lbl.fit_content = true
	_candle_lbl.custom_minimum_size = Vector2(0, 48)
	_candle_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_af(_candle_lbl)
	body.add_child(_candle_lbl)

	# 힌트
	_hint_lbl = _lbl("", 13, "#f0b429")
	_hint_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(_hint_lbl)

	# 라운드 결과
	_result_lbl = RichTextLabel.new()
	_result_lbl.bbcode_enabled = true
	_result_lbl.fit_content = true
	_result_lbl.custom_minimum_size = Vector2(0, 44)
	_af(_result_lbl)
	body.add_child(_result_lbl)

	# 누적 수익
	_total_lbl = _lbl("", 14, "#c8d0df", true)
	body.add_child(_total_lbl)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color("#1a2030"))
	body.add_child(sep)

	# 선택 버튼 행 (연결은 1회만)
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 10)
	body.add_child(btn_row)
	_btn_long  = _make_btn("", "#0a2a0a"); _btn_long.pressed.connect(_on_btn_long)
	_btn_short = _make_btn("", "#2a0a0a"); _btn_short.pressed.connect(_on_btn_short)
	_btn_pass  = _make_btn("", "#1a1a2a"); _btn_pass.pressed.connect(_on_btn_pass)
	for b in [_btn_long, _btn_short, _btn_pass]:
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size = Vector2(0, 48)
		btn_row.add_child(b)

# ── 화면별 갱신 ────────────────────────────────────────────────────
func _rebuild() -> void:
	match _phase:
		Phase.SETUP:    _draw_setup()
		Phase.ANALYSIS: _draw_analysis()
		Phase.FINAL:    _draw_final()

func _draw_setup() -> void:
	_timer_bar.visible = false
	_timer_lbl.text    = ""
	_round_lbl.text    = "베팅금 선택"
	_stake_lbl.text    = ""
	_candle_lbl.text   = ""
	_result_lbl.text   = ""
	_total_lbl.text    = ""
	_hint_lbl.text     = "캔들 5개 흐름을 보고 방향을 맞히면 수익, 틀리면 손실.\n투자감각이 높을수록 추세 힌트가 보입니다."
	_hint_lbl.add_theme_color_override("font_color", Color("#4a5a72"))
	_btn_long.text  = "소액  ₩200,000"
	_btn_short.text = "표준  ₩500,000"
	_btn_pass.text  = "공격  ₩1,000,000"
	for b in [_btn_long, _btn_short, _btn_pass]: b.disabled = false
	_btn_long.visible = true; _btn_short.visible = true; _btn_pass.visible = true

func _draw_analysis() -> void:
	_timer_bar.visible = true
	_round_lbl.text = "라운드 %d / %d" % [_round + 1, ROUNDS]
	_stake_lbl.text = "베팅금 %s" % GameState.format_money(_stake)
	_result_lbl.text = ""
	_draw_total_label()

	# 캔들 텍스트
	var parts: Array = []
	for c in _candles:
		var pct: float = c * 100.0
		if pct >= 0:
			parts.append("[color=#00c896]▲%+.1f%%[/color]" % pct)
		else:
			parts.append("[color=#ff4444]▼%.1f%%[/color]" % absf(pct))
	_candle_lbl.text = "최근 5캔들:  " + "   ".join(parts)

	# 힌트 (투자감각 기반)
	var skill: int = GameState.investment_skill
	var up_count: int = _candles.filter(func(c): return c > 0.0).size()
	if skill >= 20:
		var hint_text: String
		var hint_color: String
		if up_count >= 4:
			hint_text = "📊 추세: 강한 상승흐름"; hint_color = "#00c896"
		elif up_count <= 1:
			hint_text = "📊 추세: 강한 하락흐름"; hint_color = "#ff4444"
		elif up_count >= 3:
			hint_text = "📊 추세: 약한 상승" + (" / 변동 주의" if skill < 40 else ""); hint_color = "#a8d0a0"
		else:
			hint_text = "📊 추세: 약한 하락"; hint_color = "#d0a0a0"
		if skill >= 60:
			var dir_kr: String = "상승" if _actual_move > 0 else "하락"
			hint_text += "  |  ⚡ 직감: %s" % dir_kr
		_hint_lbl.text = hint_text
		_hint_lbl.add_theme_color_override("font_color", Color(hint_color))
	else:
		_hint_lbl.text = "💡 투자감각 20 이상이면 추세 힌트가 보입니다"
		_hint_lbl.add_theme_color_override("font_color", Color("#4a5a72"))

	_btn_long.text  = "📈  롱  (상승 베팅)"
	_btn_short.text = "📉  숏  (하락 베팅)"
	_btn_pass.text  = "⏸  패스"
	_btn_long.visible = true; _btn_short.visible = true; _btn_pass.visible = true
	for b in [_btn_long, _btn_short, _btn_pass]: b.disabled = false
	_refresh_timer_bar()

func _show_round_result(profit: int) -> void:
	var move_pct: float = _actual_move * 100.0
	var dir: String = "상승 ▲%.1f%%" % move_pct if _actual_move > 0 else "하락 ▼%.1f%%" % absf(move_pct)
	var choice_kr := {"long": "📈 롱", "short": "📉 숏", "pass": "⏸ 패스"}
	var cs: String = choice_kr.get(_player_choice, _player_choice)
	var text: String
	var col: String
	if _player_choice == "pass":
		col = "#8892a4"; text = "패스 — 시장은 %s 이었다." % dir
	elif profit > 0:
		col = "#00c896"; text = "✅ %s 정답!  시장 %s → [b]+%s[/b]" % [cs, dir, GameState.format_money(profit)]
	else:
		col = "#ff4444"; text = "❌ %s 틀림.  시장 %s → [b]%s[/b]" % [cs, dir, GameState.format_money(profit)]
	_result_lbl.text = "[color=%s]%s[/color]" % [col, text]
	_draw_total_label()
	_timer_lbl.text    = "다음 라운드..."
	_timer_bar.visible = false

func _draw_final() -> void:
	set_process(false)
	_timer_bar.visible = false
	_timer_lbl.text    = ""
	_round_lbl.text    = "세션 종료"
	_stake_lbl.text    = ""
	_hint_lbl.text     = ""
	_candle_lbl.text   = ""

	var lines: Array = ["[b]결과 요약[/b]\n"]
	for i in range(_round_results.size()):
		var r: Dictionary  = _round_results[i]
		var m: float = float(r.get("move", 0.0)) * 100.0
		var p: int   = int(r.get("profit", 0))
		var c_kr := {"long": "롱", "short": "숏", "pass": "패스"}
		var cs: String = c_kr.get(str(r.get("choice", "")), "?")
		var ps: String = ("+%s" % GameState.format_money(p)) if p > 0 else GameState.format_money(p)
		var col: String = "#00c896" if p > 0 else ("#ff4444" if p < 0 else "#8892a4")
		var dir: String  = "▲%.1f%%" % m if m > 0 else "▼%.1f%%" % absf(m)
		lines.append("R%d  %s  시장%s  [color=%s]%s[/color]" % [i + 1, cs, dir, col, ps])
	_result_lbl.text = "\n".join(lines)
	_draw_total_label()

	_btn_long.visible  = false
	_btn_short.visible = false
	_btn_pass.text     = "확인  ▶"
	_btn_pass.visible  = true
	_btn_pass.disabled = false

func _draw_total_label() -> void:
	var sign: String = "+" if _total_profit > 0 else ""
	_total_lbl.text = "누적: %s%s" % [sign, GameState.format_money(_total_profit)]
	var col: Color = Color("#00c896") if _total_profit > 0 else (Color("#ff4444") if _total_profit < 0 else Color("#8892a4"))
	_total_lbl.add_theme_color_override("font_color", col)

func _refresh_timer_bar() -> void:
	if not is_instance_valid(_timer_bar): return
	_timer_bar.value = maxf(_timer, 0.0)
	_timer_lbl.text  = "⏱ %.0fs" % maxf(_timer, 0.0)
	var ratio: float = _timer / ROUND_TIMER
	if   ratio > 0.5: _timer_style.bg_color = Color("#00c896")
	elif ratio > 0.25: _timer_style.bg_color = Color("#f0b429")
	else:              _timer_style.bg_color = Color("#ff4444")
	_timer_bar.add_theme_stylebox_override("fill", _timer_style)

# ── 결과 적용 + 종료 ───────────────────────────────────────────────
func _apply_result() -> void:
	if _total_profit != 0:
		GameState.add_money(float(_total_profit))
	var correct: int = _round_results.filter(func(r): return int(r.get("profit", 0)) > 0).size()
	if correct >= 2:
		GameState.investment_skill = mini(GameState.investment_skill + 1, 100)
	if _total_profit > 0:
		GameState.add_log("🪙 코인 단타 +%s 수익" % GameState.format_money(_total_profit), "invest")
	elif _total_profit < 0:
		GameState.add_log("🪙 코인 단타 %s 손실" % GameState.format_money(_total_profit), "invest")
	else:
		GameState.add_log("🪙 코인 단타 세션 종료 (0원)", "invest")

func _close_game() -> void:
	visible = false
	emit_signal("closed")

func _force_close() -> void:
	set_process(false)
	if _phase in [Phase.ANALYSIS, Phase.REVEAL]:
		GameState.add_log("🪙 코인 단타 조기 종료", "invest")
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
	st.bg_color    = Color(bg)
	st.border_color = Color(bg).lightened(0.25)
	for w in ["border_width_left", "border_width_right", "border_width_top", "border_width_bottom"]:
		st.set(w, 2)
	st.set_corner_radius_all(4)
	st.content_margin_left  = 12; st.content_margin_right  = 12
	st.content_margin_top   = 8;  st.content_margin_bottom = 8
	b.add_theme_stylebox_override("normal", st)
	var hov := st.duplicate() as StyleBoxFlat
	hov.bg_color = Color(bg).lightened(0.15)
	b.add_theme_stylebox_override("hover", hov)
	_af(b, true)
	return b
