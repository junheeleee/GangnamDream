extends Control
## ScalpingGame — 주식 스캘핑 아케이드 미니게임.
## 60초 실시간 캔들 차트. 클릭 타이밍이 수익을 결정한다.
## 투자감각이 높을수록 노이즈↓, 추세 힌트 해금.
## MainGame이 overlay로 붙이고 open()으로 표시.

signal closed

const GAME_DURATION  := 60.0   # 게임 시간 (초)
const TICK_INTERVAL  := 0.35   # 가격 업데이트 간격
const CHART_BARS     := 60     # 차트에 표시할 틱 수
const CANDLE_TICKS   := 3      # 캔들 1개 = 틱 N개
const MA_FAST        := 5      # 빠른 MA
const MA_SLOW        := 20     # 느린 MA
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
var _entry_tick: int = 0         # 매수 시점 틱 인덱스
var _stake: int = 500_000
var _realized: float = 0.0      # 확정 수익
var _trades: int = 0
var _trade_history: Array = []   # [{tick, price, type: "buy"/"sell", pnl}]
var _runs_completed: int = 0
var _session_trades: int = 0
var _entry_balance: float = 0.0
var _rng := RandomNumberGenerator.new()
var _skill_level: int = 0       # GameState.investment_skill 캐시

# UI 노드
var _chart_node: Control        # 차트 그리기 전담 노드
var _flash_layer: ColorRect
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

func _tr(ko_text: String, en_text: String) -> String:
	return LocaleManager.ui(ko_text, en_text)

func _load_fonts() -> void:
	_font      = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile

func _f(n: Control, bold := false) -> void:
	var ft = _font_bold if bold else _font
	if ft and n: n.add_theme_font_override("font", ft)

# ── 진입 ──────────────────────────────────────────────────────────
func open() -> void:
	BGMPlayer.enter_activity_ambience("office")
	_runs_completed = 0
	_session_trades = 0
	_entry_balance = GameState.money
	_skill_level = GameState.investment_skill
	# 마스터리 등급에 따라 힌트 해금 임계치 하향
	var mastery: int = MetaProgression.get_mastery("scalping")
	if mastery >= 1 and _skill_level < 30: _skill_level = 30  # 숙련: 투자감각 보정
	if mastery >= 2: _skill_level = maxi(_skill_level, 50)     # 고급: 힌트 항상 표시
	_phase = Phase.SETUP
	set_process(false)
	_rebuild()
	visible = true
	TutorialOverlay.maybe_show("scalping", self)

func _start_game() -> void:
	_timer = GAME_DURATION
	_warned_10s = false
	_tick_acc = 0.0
	_price = 100.0
	_momentum = 0.0
	_price_history = [_price]
	_in_position = false
	_entry_price = 0.0
	_entry_tick = 0
	_realized = 0.0
	_trades = 0
	_trade_history = []
	_phase = Phase.PLAYING
	set_process(true)
	_clear_phase_overlay()
	_rebuild()
	AudioManager.play("event_new")
	_show_trade_banner("MARKET OPEN", Color("#c9a227"), 0.60)
	_screen_flash(Color("#c9a227"), 0.10, 0.24)

func _end_game() -> void:
	set_process(false)
	if _in_position:
		# 강제 청산
		var forced_pnl: float = float(_stake) * (_price - _entry_price) / _entry_price
		_realized += forced_pnl
		_trade_history.append({"tick": _price_history.size() - 1, "price": _price, "type": "sell", "pnl": forced_pnl})
		_in_position = false
	_phase = Phase.RESULT
	_apply_result()
	_rebuild()

# ── 메인 루프 ─────────────────────────────────────────────────────
var _warned_10s := false

func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_end_game()
		return
	# 10초 경고 1회 pulse
	if not _warned_10s and _timer <= 10.0:
		_warned_10s = true
		if is_instance_valid(_timer_lbl):
			_pulse_node(_timer_lbl, 1.25, 0.18)

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
	title.text = _tr("스캘핑 트레이딩", "Scalping Trading")
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color("#f0b429"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_f(title, true)
	hdr_row.add_child(title)
	_timer_lbl = Label.new()
	_timer_lbl.add_theme_font_size_override("font_size", 16)
	_timer_lbl.add_theme_color_override("font_color", Color("#c9a227"))
	_f(_timer_lbl, true)
	hdr_row.add_child(_timer_lbl)
	var help_btn := _btn("?", func(): TutorialOverlay.force_show("scalping", self), "#0a0a1a")
	help_btn.custom_minimum_size = Vector2(34, 34)
	help_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	hdr_row.add_child(help_btn)

	var close_btn := _btn("X", func(): _on_close_pressed(), "#2a1818")
	close_btn.custom_minimum_size = Vector2(34, 34)
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
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

	_flash_layer = ColorRect.new()
	_flash_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash_layer.color = Color(1, 1, 1, 1)
	_flash_layer.modulate = Color(1, 1, 1, 0.0)
	_flash_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash_layer.z_index = 80
	add_child(_flash_layer)

# ── 차트 그리기 — 캔들스틱 + MA + 매매 마커 ──────────────────────
func _draw_chart(canvas: Control) -> void:
	if _price_history.size() < 2:
		return
	var w: float = canvas.size.x
	var h_total: float = canvas.size.y
	if w <= 0 or h_total <= 0:
		return

	var h: float = h_total  # 캔들 차트 높이 (전체)
	var f := _font if _font else ThemeDB.fallback_font

	# ── 캔들 OHLC 계산 ──────────────────────────────────────────
	var history: Array = _price_history.slice(maxi(0, _price_history.size() - CHART_BARS))
	# 역방향 오프셋 (히스토리 배열 내 시작 인덱스)
	var hist_offset: int = maxi(0, _price_history.size() - CHART_BARS)

	var candles: Array = []   # [{o, h, l, c, tick_start}]
	var i := 0
	while i < history.size():
		var end := mini(i + CANDLE_TICKS, history.size())
		var seg := history.slice(i, end)
		var o: float = seg[0]; var c: float = seg[-1]
		var ch: float = float(seg[0]); var cl: float = float(seg[0])
		for v in seg:
			ch = maxf(ch, v); cl = minf(cl, v)
		candles.append({"o": o, "h": ch, "l": cl, "c": c, "tick_start": i})
		i += CANDLE_TICKS

	# ── 가격 범위 ───────────────────────────────────────────────
	var lo: float = history[0]; var hi: float = history[0]
	for v in history:
		lo = minf(lo, v); hi = maxf(hi, v)
	var range_y: float = maxf(hi - lo, 0.5)
	lo -= range_y * 0.10; hi += range_y * 0.10
	range_y = hi - lo

	# ── 배경 + 그리드 ────────────────────────────────────────────
	canvas.draw_rect(Rect2(0, 0, w, h), Color("#070a12"))
	for gi in range(5):
		var gy: float = h * float(gi) / 4.0
		var pv: float = hi - (float(gi) / 4.0) * range_y
		canvas.draw_line(Vector2(0, gy), Vector2(w, gy), Color("#111926"), 1)
		if gi < 4:
			canvas.draw_string(f, Vector2(4, gy + 11), "%.1f" % pv,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#2a3a4a"))

	# ── 진입가 수평선 ─────────────────────────────────────────────
	if _in_position and _entry_price > 0.0:
		var ey: float = h - ((_entry_price - lo) / range_y) * h
		canvas.draw_line(Vector2(0, ey), Vector2(w, ey), Color(0.15, 0.8, 0.4, 0.55), 1.5)
		canvas.draw_string(f, Vector2(w - 70, ey - 10), _tr("진입 %.2f", "Entry %.2f") % _entry_price,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#3dba6a"))

	# ── 캔들 렌더 ────────────────────────────────────────────────
	var nc: int = candles.size()
	var cw: float = maxf(w / float(maxi(nc, 1)), 3.0)
	var wick_w: float = 1.5

	for ci in range(nc):
		var cnd: Dictionary = candles[ci]
		var cx: float = (float(ci) + 0.5) * cw
		var bull: bool = float(cnd["c"]) >= float(cnd["o"])
		var col: Color = Color("#26a65b") if bull else Color("#e84040")
		var col_dim: Color = Color("#1a6e3d") if bull else Color("#8e2828")

		var body_top: float = h - (maxf(float(cnd["o"]), float(cnd["c"])) - lo) / range_y * h
		var body_bot: float = h - (minf(float(cnd["o"]), float(cnd["c"])) - lo) / range_y * h
		var wick_top: float = h - (float(cnd["h"]) - lo) / range_y * h
		var wick_bot: float = h - (float(cnd["l"]) - lo) / range_y * h

		# 윅
		canvas.draw_line(Vector2(cx, wick_top), Vector2(cx, body_top), col_dim, wick_w)
		canvas.draw_line(Vector2(cx, body_bot), Vector2(cx, wick_bot), col_dim, wick_w)
		# 몸통
		var body_h: float = maxf(body_bot - body_top, 1.5)
		var body_w: float = minf(cw * 0.7, 16.0)
		canvas.draw_rect(Rect2(cx - body_w * 0.5, body_top, body_w, body_h), col)

	# ── 이동평균선 (MA_FAST / MA_SLOW) ───────────────────────────
	var draw_ma := func(period: int, col: Color) -> void:
		var pts: Array = []
		for ti in range(history.size()):
			if ti < period - 1: continue
			var sum: float = 0.0
			for ki in range(period):
				sum += float(history[ti - ki])
			var ma_v: float = sum / float(period)
			# x: 해당 틱이 속한 캔들 cx
			var ci_idx: int = ti / CANDLE_TICKS
			var cx: float = (float(ci_idx) + 0.5 + float(ti % CANDLE_TICKS) / float(CANDLE_TICKS)) * cw
			var y: float = h - (ma_v - lo) / range_y * h
			pts.append(Vector2(cx, y))
		for pi in range(1, pts.size()):
			canvas.draw_line(pts[pi-1], pts[pi], col, 1.2)

	if _skill_level >= 20:
		draw_ma.call(MA_FAST, Color(0.9, 0.8, 0.2, 0.75))   # 노란 빠른MA
	if _skill_level >= 40:
		draw_ma.call(MA_SLOW, Color(0.3, 0.6, 1.0, 0.65))   # 파란 느린MA

	# ── 매매 마커 ────────────────────────────────────────────────
	for trade in _trade_history:
		var t_tick: int = int(trade["tick"]) - hist_offset
		if t_tick < 0: continue
		var ci_idx: int = t_tick / CANDLE_TICKS
		var cx: float = (float(ci_idx) + 0.5) * cw
		var ty: float = h - (float(trade["price"]) - lo) / range_y * h
		if trade["type"] == "buy":
			# 녹색 위삼각형
			var sz: float = 7.0
			canvas.draw_line(Vector2(cx, ty - sz), Vector2(cx - sz, ty + sz * 0.5), Color("#3dff7a"), 2.0)
			canvas.draw_line(Vector2(cx - sz, ty + sz * 0.5), Vector2(cx + sz, ty + sz * 0.5), Color("#3dff7a"), 2.0)
			canvas.draw_line(Vector2(cx + sz, ty + sz * 0.5), Vector2(cx, ty - sz), Color("#3dff7a"), 2.0)
			canvas.draw_string(f, Vector2(cx + sz + 2, ty + 4), "BUY",
				HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#3dff7a"))
		else:
			# 빨간 아래삼각형
			var sz: float = 7.0
			canvas.draw_line(Vector2(cx, ty + sz), Vector2(cx - sz, ty - sz * 0.5), Color("#ff4040"), 2.0)
			canvas.draw_line(Vector2(cx - sz, ty - sz * 0.5), Vector2(cx + sz, ty - sz * 0.5), Color("#ff4040"), 2.0)
			canvas.draw_line(Vector2(cx + sz, ty - sz * 0.5), Vector2(cx, ty + sz), Color("#ff4040"), 2.0)
			var pnl: float = float(trade.get("pnl", 0.0))
			var pnl_str := _signed_money(pnl)
			canvas.draw_string(f, Vector2(cx + sz + 2, ty - 4), "SELL " + pnl_str,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#ff6060"))

	# ── 현재가 도트 ──────────────────────────────────────────────
	var last_ci: int = nc - 1
	var cur_cx: float = (float(last_ci) + 0.5) * cw
	var cur_y:  float = h - ((_price - lo) / range_y) * h
	canvas.draw_circle(Vector2(cur_cx, cur_y), 4.5, Color("#f0b429"))
	canvas.draw_arc(Vector2(cur_cx, cur_y), 7.0, 0, TAU, 12, Color(0.94, 0.7, 0.16, 0.4), 2.0)

	# ── 현재가 우측 레이블 ────────────────────────────────────────
	canvas.draw_string(f, Vector2(w - 62, cur_y + 4), "%.2f" % _price,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#f0b429"))

# ── UI 갱신 ───────────────────────────────────────────────────────
func _refresh_ui() -> void:
	if _phase != Phase.PLAYING: return
	if is_instance_valid(_timer_lbl):
		var sec_left: int = ceili(_timer)
		_timer_lbl.text = _tr("%d초", "%ds") % sec_left
		if _timer <= 10.0:
			_timer_lbl.add_theme_color_override("font_color", Color("#e85d5d"))
		elif _timer <= 20.0:
			_timer_lbl.add_theme_color_override("font_color", Color("#f0b429"))
		else:
			_timer_lbl.add_theme_color_override("font_color", Color("#c9a227"))
	if is_instance_valid(_price_lbl):
		_price_lbl.text = _tr("가격  %.2f", "Price  %.2f") % _price
	var total_pnl: float = _realized
	if _in_position:
		total_pnl += float(_stake) * (_price - _entry_price) / _entry_price
	if is_instance_valid(_pnl_lbl):
		var pnl_str := _signed_money(total_pnl)
		_pnl_lbl.text = "P&L  " + pnl_str
		_pnl_lbl.add_theme_color_override("font_color", Color("#3dba6a") if total_pnl >= 0 else Color("#e85d5d"))
	if is_instance_valid(_position_lbl):
		_position_lbl.text = _tr("포지션: 보유중 (%s)", "Position: Open (%s)") % _fmt(_stake) if _in_position else _tr("포지션: 없음", "Position: None")
	# 힌트 (투자감각 40+)
	if is_instance_valid(_hint_lbl) and _skill_level >= 40:
		var recent: Array = _price_history.slice(maxi(0, _price_history.size() - 5))
		if recent.size() >= 3:
			var trend: float = float(recent[-1]) - float(recent[0])
			if absf(trend) > 0.3:
				_hint_lbl.text = _tr("추세 감지: %s", "Trend detected: %s") % (_tr("상승", "Up") if trend > 0 else _tr("하락", "Down"))
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
			_clear_phase_overlay()
			_refresh_ui()

func _clear_phase_overlay() -> void:
	var overlay := get_node_or_null("setup_overlay")
	if is_instance_valid(overlay) and not overlay.is_queued_for_deletion():
		overlay.queue_free()

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
	t.text = _tr("스캘핑 트레이딩", "Scalping Trading")
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 22)
	t.add_theme_color_override("font_color", Color("#f0b429"))
	_f(t, true)
	vb.add_child(t)
	var desc := Label.new()
	desc.text = _tr("60초 안에 저점 매수 / 고점 매도\n투자감각 %d  ( %s )", "Buy lows / sell highs within 60 seconds\nInvestment Sense %d  ( %s )") % [_skill_level,
		_tr("노이즈 낮음 · 추세 힌트 있음", "Low noise · trend hints enabled") if _skill_level >= 40 else _tr("노이즈 높음", "High noise")]
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
	stake_lbl.text = _tr("판돈 선택", "Choose Stake")
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
	var leave_btn := _btn(_tr("나가기", "Leave"), func(): _on_close_pressed(), "#2a1818")
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
	t.text = _tr("세션 종료", "Session Complete")
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 20)
	t.add_theme_color_override("font_color", Color("#f0b429"))
	_f(t, true)
	vb.add_child(t)
	var trades_lbl := Label.new()
	trades_lbl.text = _tr("거래 %d회", "%d trades") % _trades
	trades_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	trades_lbl.add_theme_font_size_override("font_size", 12)
	trades_lbl.add_theme_color_override("font_color", Color("#5a6a8a"))
	_f(trades_lbl)
	vb.add_child(trades_lbl)
	var pnl_lbl := Label.new()
	pnl_lbl.text = _signed_money(_realized)
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
	var again_btn := _btn(_tr("다시하기", "Retry"), func():
		overlay.queue_free()
		_phase = Phase.SETUP
		_show_setup()
	, "#1a3a2a")
	again_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_f(again_btn)
	btn_row.add_child(again_btn)
	var leave_btn := _btn(_tr("나가기", "Leave"), func(): _on_close_pressed(), "#2a1818")
	leave_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_f(leave_btn)
	btn_row.add_child(leave_btn)

# ── 매매 ─────────────────────────────────────────────────────────
func _on_buy() -> void:
	if _in_position: return
	_in_position = true
	_entry_price = _price
	_entry_tick = _price_history.size() - 1
	_trade_history.append({"tick": _entry_tick, "price": _price, "type": "buy", "pnl": 0.0})
	AudioManager.play("buy")
	_show_trade_banner("BUY  %.2f" % _entry_price, Color("#5de89c"), 0.46)
	_screen_flash(Color("#5de89c"), 0.10, 0.22)
	_pulse_node(_chart_node, 1.015, 0.18)
	if is_instance_valid(_chart_node): _chart_node.queue_redraw()
	_refresh_ui()

func _on_sell() -> void:
	if not _in_position: return
	var trade_pnl: float = float(_stake) * (_price - _entry_price) / _entry_price
	_realized += trade_pnl
	_in_position = false
	_entry_price = 0.0
	_trades += 1
	var sell_tick: int = _price_history.size() - 1
	_trade_history.append({"tick": sell_tick, "price": _price, "type": "sell", "pnl": trade_pnl})
	AudioManager.play("money_gain" if trade_pnl >= 0.0 else "money_loss")
	_show_trade_banner(("PROFIT " if trade_pnl >= 0.0 else "LOSS ") + ("%+.0f" % trade_pnl),
		Color("#5de89c") if trade_pnl >= 0.0 else Color("#e85d5d"), 0.62)
	_screen_flash(Color("#5de89c") if trade_pnl >= 0.0 else Color("#e85d5d"), 0.14, 0.28)
	if trade_pnl < 0.0:
		_shake_node(_chart_node, 5.0, 0.20)
	else:
		_pulse_node(_pnl_lbl, 1.10, 0.28)
	if is_instance_valid(_chart_node): _chart_node.queue_redraw()
	_refresh_ui()

# ── 결과 적용 ─────────────────────────────────────────────────────
func _apply_result() -> void:
	_runs_completed += 1
	_session_trades += _trades
	GameState.add_money(_realized)
	if _realized > 0:
		GameState.add_log(_tr("스캘핑으로 %s 벌었다. (%d회 거래)", "Earned %s from scalping. (%d trades)") % [_fmt(_realized), _trades], "money")
		GameState.modify_stat("investment_skill", 1)
		GameState.modify_hidden_stat("gambling_tendency", 2)
		AudioManager.play("money_big" if _realized >= 1_000_000.0 else "money_gain")
	elif _realized < 0:
		GameState.add_log(_tr("스캘핑에서 %s 잃었다.", "Lost %s from scalping.") % _fmt(-_realized), "money")
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
	BGMPlayer.leave_activity_ambience("office")
	visible = false
	AudioManager.play("click")
	closed.emit()

func get_session_summary() -> Dictionary:
	return {
		"game_id": "scalping",
		"rounds": _runs_completed,
		"trades": _session_trades,
		"net": GameState.money - _entry_balance,
	}

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
	return GameState.format_money(float(v))

func _signed_money(v) -> String:
	var amount := float(v)
	if amount > 0.0:
		return "+%s" % GameState.format_money(amount)
	return GameState.format_money(amount)

func _screen_flash(color: Color, alpha: float = 0.16, duration: float = 0.3) -> void:
	if not is_instance_valid(_flash_layer):
		return
	_flash_layer.color = Color(color.r, color.g, color.b, 1.0)
	_flash_layer.modulate = Color(1, 1, 1, 0.0)
	_flash_layer.visible = true
	var tw := create_tween()
	tw.tween_property(_flash_layer, "modulate:a", alpha, duration * 0.22)
	tw.tween_property(_flash_layer, "modulate:a", 0.0, duration * 0.78)
	tw.tween_callback(func():
		if is_instance_valid(_flash_layer):
			_flash_layer.visible = false
	)

func _show_trade_banner(text: String, color: Color, duration: float = 0.48) -> void:
	var root_size := size
	if root_size.x <= 1.0 or root_size.y <= 1.0:
		root_size = get_viewport_rect().size
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.z_index = 75
	panel.size = Vector2(minf(360.0, root_size.x - 48.0), 48.0)
	panel.position = Vector2((root_size.x - panel.size.x) * 0.5, maxf(82.0, root_size.y * 0.28))
	panel.modulate = Color(1, 1, 1, 0.0)
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.02, 0.03, 0.05, 0.86)
	st.border_color = color
	st.set_border_width_all(2)
	st.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", st)
	add_child(panel)
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 17)
	lbl.add_theme_color_override("font_color", color)
	_f(lbl, true)
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(lbl)
	var tw := create_tween()
	tw.tween_property(panel, "modulate:a", 1.0, 0.08)
	tw.tween_interval(duration)
	tw.tween_property(panel, "modulate:a", 0.0, 0.16)
	tw.tween_callback(panel.queue_free)

func _shake_node(node: Node, amount: float = 6.0, duration: float = 0.25) -> void:
	if not is_instance_valid(node) or not (node is Control):
		return
	var ctrl := node as Control
	var base := ctrl.position
	var tw := create_tween()
	for _i in range(6):
		var offset := Vector2(randf_range(-amount, amount), randf_range(-amount * 0.45, amount * 0.45))
		tw.tween_property(ctrl, "position", base + offset, duration / 6.0)
	tw.tween_property(ctrl, "position", base, 0.04)

func _pulse_node(node: Node, scale_to: float = 1.08, duration: float = 0.28) -> void:
	if not is_instance_valid(node) or not (node is Control):
		return
	var ctrl := node as Control
	var base := ctrl.scale
	ctrl.pivot_offset = ctrl.size * 0.5
	var tw := create_tween()
	tw.tween_property(ctrl, "scale", base * scale_to, duration * 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(ctrl, "scale", base, duration * 0.58).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
