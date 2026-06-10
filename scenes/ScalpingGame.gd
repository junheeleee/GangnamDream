extends Control
## ScalpingGame — 주식 스캘핑 아케이드 미니게임.
## 60초 실시간 캔들 차트. 클릭 타이밍이 수익을 결정한다.
## 투자감각이 높을수록 노이즈↓, 추세 힌트 해금.
## MainGame이 overlay로 붙이고 open()으로 표시.

signal closed

const GAME_DURATION  := 60.0   # 게임 시간 (초)
const TICK_INTERVAL  := 0.35   # 가격 업데이트 간격
const CHART_BARS     := 55     # 차트에 표시할 틱 수
const VALID_STAKES   := [100_000, 500_000, 1_000_000, 3_000_000]

enum Phase { SETUP, PLAYING, RESULT }

var _phase: int = Phase.SETUP
var _timer: float = GAME_DURATION
var _tick_acc: float = 0.0
var _price: float = 100.0
var _momentum: float = 0.0
var _price_history: Array = []   # float 리스트 (최신이 마지막)
var _in_position: bool = false
var _entry_price: float = 0.0
var _stake: int = 500_000
var _realized: float = 0.0      # 확정 수익
var _trades: int = 0
var _rng := RandomNumberGenerator.new()
var _skill_level: int = 0       # GameState.investment_skill 캐시

# UI 노드
var _chart_node: Control        # 차트 그리기 전담 노드
var _timer_lbl: Label
var _price_lbl: Label
var _pnl_lbl: Label
var _position_lbl: Label
var _hint_lbl: Label
var _buy_btn: Button
var _sell_btn: Button
var _font: FontFile
var _font_bold: FontFile

func _ready() -> void:
	_rng.randomize()
	_load_fonts()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)  # 오프셋까지 0 — 루트 0x0 collapse 방지
	_build_ui()
	visible = false
	set_process(false)

func _load_fonts() -> void:
	_font      = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile

func _f(n: Control, bold := false) -> void:
	var ft = _font_bold if bold else _font
	if ft and n: n.add_theme_font_override("font", ft)

# ── 진입 ──────────────────────────────────────────────────────────
func open() -> void:
	_skill_level = GameState.investment_skill
	# 마스터리 등급에 따라 힌트 해금 임계치 하향
	var mastery: int = MetaProgression.get_mastery("scalping")
	if mastery >= 1 and _skill_level < 30: _skill_level = 30  # 숙련: 투자감각 보정
	if mastery >= 2: _skill_level = maxi(_skill_level, 50)     # 고급: 힌트 항상 표시
	_phase = Phase.SETUP
	set_process(false)
	_rebuild()
	visible = true

func _start_game() -> void:
	_timer = GAME_DURATION
	_tick_acc = 0.0
	_price = 100.0
	_momentum = 0.0
	_price_history = [_price]
	_in_position = false
	_entry_price = 0.0
	_realized = 0.0
	_trades = 0
	_phase = Phase.PLAYING
	set_process(true)
	_rebuild()

func _end_game() -> void:
	set_process(false)
	if _in_position:
		# 강제 청산
		_realized += _stake * (_price - _entry_price) / _entry_price
		_in_position = false
	_phase = Phase.RESULT
	_apply_result()
	_rebuild()

# ── 메인 루프 ─────────────────────────────────────────────────────
func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_end_game()
		return

	_tick_acc += delta
	if _tick_acc >= TICK_INTERVAL:
		_tick_acc = 0.0
		_tick_price()
		_refresh_ui()

func _tick_price() -> void:
	# 가격 시뮬: 랜덤워크 + 모멘텀
	var noise_scale: float = lerpf(0.6, 0.25, clampf(float(_skill_level) / 80.0, 0.0, 1.0))
	var raw: float = _rng.randf_range(-noise_scale, noise_scale)
	_momentum = _momentum * 0.85 + raw * 0.4
	# 평균 회귀 (가격이 100에서 너무 멀면 당김)
	_momentum += (_price - 100.0) * -0.015
	_price = maxf(_price + _momentum, 1.0)
	_price_history.append(_price)
	if _price_history.size() > CHART_BARS + 10:
		_price_history.pop_front()
	if is_instance_valid(_chart_node):
		_chart_node.queue_redraw()

# ── UI 빌드 ───────────────────────────────────────────────────────
func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#050810")
	add_child(bg)
	# 컨텐츠 마진
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)
	# 헤더
	var hdr_row := HBoxContainer.new()
	root.add_child(hdr_row)
	var title := Label.new()
	title.text = "⚡ 스캘핑 트레이딩"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color("#f0b429"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_f(title, true)
	hdr_row.add_child(title)
	_timer_lbl = Label.new()
	_timer_lbl.add_theme_font_size_override("font_size", 16)
	_timer_lbl.add_theme_color_override("font_color", Color("#5b9cf6"))
	_f(_timer_lbl, true)
	hdr_row.add_child(_timer_lbl)
	var close_btn := _btn("✕", func(): _on_close_pressed(), "#2a1818")
	close_btn.custom_minimum_size = Vector2(34, 34)
	hdr_row.add_child(close_btn)
	# 차트
	_chart_node = Control.new()
	_chart_node.custom_minimum_size = Vector2(0, 200)
	_chart_node.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_chart_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_chart_node.draw.connect(_draw_chart.bind(_chart_node))
	root.add_child(_chart_node)
	# 정보 행
	var info_row := HBoxContainer.new()
	info_row.add_theme_constant_override("separation", 14)
	root.add_child(info_row)
	_price_lbl = Label.new()
	_price_lbl.add_theme_font_size_override("font_size", 13)
	_price_lbl.add_theme_color_override("font_color", Color("#e8eaf0"))
	_f(_price_lbl)
	info_row.add_child(_price_lbl)
	_pnl_lbl = Label.new()
	_pnl_lbl.add_theme_font_size_override("font_size", 13)
	_f(_pnl_lbl, true)
	info_row.add_child(_pnl_lbl)
	_position_lbl = Label.new()
	_position_lbl.add_theme_font_size_override("font_size", 12)
	_position_lbl.add_theme_color_override("font_color", Color("#5a6a8a"))
	_f(_position_lbl)
	info_row.add_child(_position_lbl)
	# 힌트 (투자감각 40+)
	_hint_lbl = Label.new()
	_hint_lbl.add_theme_font_size_override("font_size", 11)
	_hint_lbl.add_theme_color_override("font_color", Color("#4a8a6a"))
	_f(_hint_lbl)
	root.add_child(_hint_lbl)
	# 액션 버튼
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 10)
	root.add_child(btn_row)
	_buy_btn = _btn("▲ BUY", func(): _on_buy(), "#0a3a1a")
	_buy_btn.custom_minimum_size = Vector2(0, 44)
	_buy_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_row.add_child(_buy_btn)
	_sell_btn = _btn("▼ SELL", func(): _on_sell(), "#3a1a0a")
	_sell_btn.custom_minimum_size = Vector2(0, 44)
	_sell_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_row.add_child(_sell_btn)

# ── 차트 그리기 (custom _draw) ────────────────────────────────────
func _draw_chart(canvas: Control) -> void:
	if _price_history.size() < 2:
		return
	var w: float = canvas.size.x
	var h: float = canvas.size.y
	if w <= 0 or h <= 0:
		return

	# 범위 계산
	var history: Array = _price_history.slice(maxi(0, _price_history.size() - CHART_BARS))
	var lo: float = history[0]
	var hi: float = history[0]
	for v in history:
		lo = minf(lo, v)
		hi = maxf(hi, v)
	var range_y: float = maxf(hi - lo, 0.5)
	lo -= range_y * 0.08
	hi += range_y * 0.08
	range_y = hi - lo

	# 그리드 배경
	canvas.draw_rect(Rect2(0, 0, w, h), Color("#0a0e18"))
	for gi in range(4):
		var gy: float = h * float(gi) / 3.0
		canvas.draw_line(Vector2(0, gy), Vector2(w, gy), Color("#161e2c"), 1)

	# 진입가 수평선
	if _in_position and _entry_price > 0.0:
		var ey: float = h - ((_entry_price - lo) / range_y) * h
		canvas.draw_line(Vector2(0, ey), Vector2(w, ey), Color("#3a7a5a80"), 1)
		canvas.draw_string(_font if _font else ThemeDB.fallback_font,
			Vector2(4, ey - 2), "진입 %.2f" % _entry_price, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#3a9a6a"))

	# 가격 라인
	var n: int = history.size()
	var prev_pt := Vector2.ZERO
	for i in range(n):
		var x: float = w * float(i) / float(CHART_BARS - 1)
		var y: float = h - ((float(history[i]) - lo) / range_y) * h
		var pt := Vector2(x, y)
		if i > 0:
			var up: bool = float(history[i]) >= float(history[i - 1])
			var col: Color = Color("#3dba6a") if up else Color("#e85d5d")
			canvas.draw_line(prev_pt, pt, col, 1.5)
		prev_pt = pt

	# 현재가 점
	var last_x: float = w * float(n - 1) / float(CHART_BARS - 1)
	var last_y: float = h - ((_price - lo) / range_y) * h
	canvas.draw_circle(Vector2(last_x, last_y), 4.0, Color("#f0b429"))

# ── UI 갱신 ───────────────────────────────────────────────────────
func _refresh_ui() -> void:
	if _phase != Phase.PLAYING: return
	if is_instance_valid(_timer_lbl):
		_timer_lbl.text = "⏱ %.0f초" % ceilf(_timer)
	if is_instance_valid(_price_lbl):
		_price_lbl.text = "가격  %.2f" % _price
	var total_pnl: float = _realized
	if _in_position:
		total_pnl += float(_stake) * (_price - _entry_price) / _entry_price
	if is_instance_valid(_pnl_lbl):
		var pnl_str := ("%+.0f원" % total_pnl)
		_pnl_lbl.text = "P&L  " + pnl_str
		_pnl_lbl.add_theme_color_override("font_color", Color("#3dba6a") if total_pnl >= 0 else Color("#e85d5d"))
	if is_instance_valid(_position_lbl):
		_position_lbl.text = "포지션: 보유중 (%s)" % _fmt(_stake) if _in_position else "포지션: 없음"
	# 힌트 (투자감각 40+)
	if is_instance_valid(_hint_lbl) and _skill_level >= 40:
		var recent: Array = _price_history.slice(maxi(0, _price_history.size() - 5))
		if recent.size() >= 3:
			var trend: float = float(recent[-1]) - float(recent[0])
			if absf(trend) > 0.3:
				_hint_lbl.text = "📈 추세 감지: %s" % ("상승" if trend > 0 else "하락")
			else:
				_hint_lbl.text = ""
	if is_instance_valid(_buy_btn):
		_buy_btn.disabled = _in_position
	if is_instance_valid(_sell_btn):
		_sell_btn.disabled = not _in_position

# ── 재빌드 (Setup/Result 화면 전환 포함) ─────────────────────────
func _rebuild() -> void:
	# 기존 UI 제거 후 재구성은 비용 큼 → 단순히 페이즈별 상태 처리
	match _phase:
		Phase.SETUP:
			_show_setup()
		Phase.RESULT:
			_show_result()
		_:
			_refresh_ui()

func _show_setup() -> void:
	# 새 오버레이 패널로 설정 화면 표시
	if has_node("setup_overlay"):
		get_node("setup_overlay").queue_free()
	var overlay := ColorRect.new()
	overlay.name = "setup_overlay"
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color("#070a10ee")
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	vb.custom_minimum_size = Vector2(340, 0)
	center.add_child(vb)
	var t := Label.new()
	t.text = "⚡ 스캘핑 트레이딩"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 22)
	t.add_theme_color_override("font_color", Color("#f0b429"))
	_f(t, true)
	vb.add_child(t)
	var desc := Label.new()
	desc.text = "60초 안에 저점 매수 → 고점 매도\n투자감각 %d  ( %s )" % [_skill_level,
		"노이즈 낮음 · 추세 힌트 있음" if _skill_level >= 40 else "노이즈 높음"]
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.add_theme_font_size_override("font_size", 12)
	desc.add_theme_color_override("font_color", Color("#8a9ab0"))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_f(desc)
	vb.add_child(desc)
	var sep := HSeparator.new()
	sep.modulate = Color("#1a2030")
	vb.add_child(sep)
	var stake_lbl := Label.new()
	stake_lbl.text = "판돈 선택"
	stake_lbl.add_theme_font_size_override("font_size", 13)
	stake_lbl.add_theme_color_override("font_color", Color("#c0c8d0"))
	_f(stake_lbl, true)
	vb.add_child(stake_lbl)
	var btn_grid := GridContainer.new()
	btn_grid.columns = 2
	btn_grid.add_theme_constant_override("h_separation", 8)
	btn_grid.add_theme_constant_override("v_separation", 8)
	vb.add_child(btn_grid)
	for si in VALID_STAKES:
		var can: bool = GameState.money >= float(si)
		var sb := _btn(_fmt(si), func(): _stake = si; _start_game(), "#1a3a2a" if can else "#1a1a1a")
		sb.disabled = not can
		sb.custom_minimum_size = Vector2(140, 38)
		_f(sb)
		btn_grid.add_child(sb)
	vb.add_child(_sep())
	var leave_btn := _btn("나가기", func(): _on_close_pressed(), "#2a1818")
	vb.add_child(leave_btn)

func _show_result() -> void:
	if has_node("setup_overlay"):
		get_node("setup_overlay").queue_free()
	var overlay := ColorRect.new()
	overlay.name = "setup_overlay"
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color("#070a10ee")
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	vb.custom_minimum_size = Vector2(300, 0)
	center.add_child(vb)
	var t := Label.new()
	t.text = "⚡ 세션 종료"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 20)
	t.add_theme_color_override("font_color", Color("#f0b429"))
	_f(t, true)
	vb.add_child(t)
	var trades_lbl := Label.new()
	trades_lbl.text = "거래 %d회" % _trades
	trades_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	trades_lbl.add_theme_font_size_override("font_size", 12)
	trades_lbl.add_theme_color_override("font_color", Color("#5a6a8a"))
	_f(trades_lbl)
	vb.add_child(trades_lbl)
	var pnl_lbl := Label.new()
	pnl_lbl.text = ("%+.0f원" % _realized)
	pnl_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pnl_lbl.add_theme_font_size_override("font_size", 26)
	pnl_lbl.add_theme_color_override("font_color", Color("#3dba6a") if _realized >= 0 else Color("#e85d5d"))
	_f(pnl_lbl, true)
	vb.add_child(pnl_lbl)
	vb.add_child(_sep())
	# 다시하기 / 나가기
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)
	vb.add_child(btn_row)
	var again_btn := _btn("다시하기", func():
		overlay.queue_free()
		_phase = Phase.SETUP
		_show_setup()
	, "#1a3a2a")
	again_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_f(again_btn)
	btn_row.add_child(again_btn)
	var leave_btn := _btn("나가기", func(): _on_close_pressed(), "#2a1818")
	leave_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_f(leave_btn)
	btn_row.add_child(leave_btn)

# ── 매매 ─────────────────────────────────────────────────────────
func _on_buy() -> void:
	if _in_position: return
	_in_position = true
	_entry_price = _price
	AudioManager.play("buy")
	_refresh_ui()

func _on_sell() -> void:
	if not _in_position: return
	var trade_pnl: float = float(_stake) * (_price - _entry_price) / _entry_price
	_realized += trade_pnl
	_in_position = false
	_entry_price = 0.0
	_trades += 1
	AudioManager.play("sell")
	_refresh_ui()

# ── 결과 적용 ─────────────────────────────────────────────────────
func _apply_result() -> void:
	GameState.money += _realized
	if _realized > 0:
		GameState.add_log("⚡ 스캘핑으로 %s 벌었다. (%d회 거래)" % [_fmt(_realized), _trades], "money")
		GameState.modify_stat("investment_skill", 1)
		GameState.modify_hidden_stat("gambling_tendency", 2)
		AudioManager.play("money_big" if _realized >= 1_000_000.0 else "money_gain")
	elif _realized < 0:
		GameState.add_log("⚡ 스캘핑에서 %s 잃었다." % _fmt(-_realized), "money")
		GameState.modify_hidden_stat("stress", 4)
		AudioManager.play("money_loss")
	# 많이 할수록 중독성
	if _trades >= 5:
		GameState.modify_hidden_stat("addiction_tendency", 2)
	# 마스터리 기록
	var new_mastery: int = MetaProgression.record_minigame_play("scalping")
	var prev: int = MetaProgression.get_mastery("scalping")
	if new_mastery > prev - 1:  # 등급 업 체크는 간이로 — 로그만 남김
		pass  # MainGame 토스트는 _on_scalping_closed에서

func _on_close_pressed() -> void:
	if _phase == Phase.PLAYING:
		_end_game()
		return
	set_process(false)
	visible = false
	AudioManager.play("click")
	closed.emit()

# ── 헬퍼 ─────────────────────────────────────────────────────────
func _btn(text: String, cb: Callable, bg: String) -> Button:
	var b := Button.new()
	b.text = text
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color(bg)
	st.set_corner_radius_all(6)
	var hov := st.duplicate()
	hov.bg_color = Color(bg).lightened(0.15)
	var focus_st := st.duplicate()
	focus_st.border_color = Color("#f0b429")
	focus_st.set_border_width_all(2)
	b.add_theme_stylebox_override("normal", st)
	b.add_theme_stylebox_override("hover", hov)
	b.add_theme_stylebox_override("pressed", hov)
	b.add_theme_stylebox_override("focus", focus_st)
	b.add_theme_color_override("font_color", Color("#e8eaf0"))
	b.add_theme_font_size_override("font_size", 13)
	if _font: b.add_theme_font_override("font", _font)
	b.pressed.connect(cb)
	return b

func _sep() -> HSeparator:
	var s := HSeparator.new()
	s.add_theme_color_override("color", Color("#1a2030"))
	return s

func _fmt(v) -> String:
	var a := int(v)
	if abs(a) >= 100_000_000: return "%.1f억" % (float(a) / 100_000_000.0)
	if abs(a) >= 10_000:      return "%+d만" % (a / 10_000)
	return "%+d원" % a
