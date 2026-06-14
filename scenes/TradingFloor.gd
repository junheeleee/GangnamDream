extends Control
## TradingFloor — 강남드림 속 '또 하나의 게임': 시각적 자산 운용 미니게임.
## 매월 [투자]를 열면 전체화면 트레이딩 보드가 뜬다. 차트를 보고 사고팔며
## 30억을 직접 굴려 만든다. 백엔드(InvestmentSystem/시장)는 기존 것을 재사용.
##
## MainGame이 인스턴스해서 child로 붙이고, setup(inv) 주입 후 open()으로 표시.

signal closed

var inv                              # InvestmentSystem (MainGame 주입)
var _selected: String = ""
var _font: FontFile
var _font_bold: FontFile

# 보드에 노출할 대표 자산 (+ 보유 중인 자산은 동적으로 추가)
const FEATURED := ["samsung", "kospi_etf", "sp500", "nvidia", "ai_chip",
	"bitcoin", "ethereum", "meme_coin", "gangnam_share", "reits", "officetel", "kospi_3x"]

const MA_FAST := 5
const MA_SLOW := 20
const CANDLE_GROUP := 2   # 가격 N개 → 캔들 1개

# 노드
var _hud: RichTextLabel
var _chart: Control
var _chart_head: RichTextLabel
var _list_box: VBoxContainer
var _trade_label: Label
var _buy_row: HBoxContainer
var _sell_row: HBoxContainer
var _toast: Label
var _flash_rect: ColorRect

# 차트 내부 상태 (드로우 시 사용)
var _chart_candles: Array = []   # [{o,h,l,c}]
var _chart_ma_fast: Array = []
var _chart_ma_slow: Array = []

# _draw_chart() 중 헬퍼에 넘기는 레이아웃 파라미터
var _dc_lo: float = 0.0
var _dc_hi: float = 1.0
var _dc_pad_t: float = 0.0
var _dc_chart_h: float = 0.0
var _dc_pad_l: float = 0.0
var _dc_chart_w: float = 0.0
var _dc_n: int = 1

func setup(investment_system) -> void:
	inv = investment_system

# ── 폰트 ──────────────────────────────────────────────────────
func _load_fonts() -> void:
	_font      = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile
	FontKit.attach_emoji_fallback(_font)
	FontKit.attach_emoji_fallback(_font_bold)

func _font_for(lbl: Object, bold: bool = false) -> void:
	var f: FontFile = _font_bold if bold else _font
	if f and lbl:
		lbl.add_theme_font_override("font", f)
		if lbl is RichTextLabel:
			lbl.add_theme_font_override("normal_font", f)
			lbl.add_theme_font_override("bold_font", _font_bold if _font_bold else f)

# ── 구성 ──────────────────────────────────────────────────────
func _ready() -> void:
	_load_fonts()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	visible = false

func _build_ui() -> void:
	# 배경
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#070a10")
	add_child(bg)

	# 플래시 레이어 (매매 타격감)
	_flash_rect = ColorRect.new()
	_flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash_rect.color = Color(0, 0, 0, 0)
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash_rect.z_index = 50
	add_child(_flash_rect)

	# 상단 HUD
	var hud_panel := Panel.new()
	hud_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hud_panel.offset_bottom = 46
	var hs := StyleBoxFlat.new()
	hs.bg_color = Color("#0e1420")
	hs.border_color = Color("#1e2840")
	hs.border_width_bottom = 1
	hud_panel.add_theme_stylebox_override("panel", hs)
	add_child(hud_panel)
	_hud = RichTextLabel.new()
	_hud.bbcode_enabled = true
	_hud.fit_content = true
	_hud.scroll_active = false
	_hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hud.offset_left = 22
	_hud.offset_top = 12
	_hud.offset_right = -180
	_font_for(_hud)
	_hud.add_theme_font_size_override("normal_font_size", 15)
	hud_panel.add_child(_hud)
	# 닫기
	var close_btn := Button.new()
	close_btn.text = "✕  닫기"
	close_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	close_btn.offset_left = -150
	close_btn.offset_top = 8
	close_btn.offset_right = -16
	close_btn.offset_bottom = 38
	_style_btn(close_btn, "#2a1518", "#a04040")
	close_btn.pressed.connect(_on_close)
	add_child(close_btn)

	# ── 차트 영역 (상단) ──
	var chart_title := RichTextLabel.new()
	chart_title.bbcode_enabled = true
	chart_title.fit_content = true
	chart_title.scroll_active = false
	chart_title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	chart_title.offset_left = 24
	chart_title.offset_top = 58
	chart_title.offset_right = -24
	chart_title.offset_bottom = 92
	_font_for(chart_title)
	chart_title.add_theme_font_size_override("normal_font_size", 18)
	add_child(chart_title)
	_chart_head = chart_title

	_chart = Control.new()
	_chart.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_chart.offset_left = 24
	_chart.offset_top = 98
	_chart.offset_right = -24
	_chart.offset_bottom = 310
	_chart.draw.connect(_draw_chart)
	add_child(_chart)

	# ── 거래 컨트롤 ──
	_trade_label = Label.new()
	_trade_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_trade_label.offset_left = 24
	_trade_label.offset_top = 322
	_trade_label.offset_right = -24
	_font_for(_trade_label)
	_trade_label.add_theme_font_size_override("font_size", 12)
	_trade_label.add_theme_color_override("font_color", Color("#9aa4b8"))
	add_child(_trade_label)

	_buy_row = HBoxContainer.new()
	_buy_row.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_buy_row.offset_left = 24
	_buy_row.offset_top = 346
	_buy_row.offset_right = -24
	_buy_row.add_theme_constant_override("separation", 6)
	add_child(_buy_row)

	_sell_row = HBoxContainer.new()
	_sell_row.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_sell_row.offset_left = 24
	_sell_row.offset_top = 388
	_sell_row.offset_right = -24
	_sell_row.add_theme_constant_override("separation", 6)
	add_child(_sell_row)

	# ── 자산 목록 (스크롤) ──
	var list_head := Label.new()
	list_head.text = "──  종목  ──  (눌러서 선택)"
	list_head.set_anchors_preset(Control.PRESET_TOP_WIDE)
	list_head.offset_left = 24
	list_head.offset_top = 436
	_font_for(list_head)
	list_head.add_theme_font_size_override("font_size", 12)
	list_head.add_theme_color_override("font_color", Color("#5a6478"))
	add_child(list_head)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 18
	scroll.offset_top = 458
	scroll.offset_right = -18
	scroll.offset_bottom = -48
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	_list_box = VBoxContainer.new()
	_list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list_box.add_theme_constant_override("separation", 4)
	scroll.add_child(_list_box)

	# 토스트
	_toast = Label.new()
	_toast.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_toast.offset_top = -40
	_toast.offset_bottom = -10
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_font_for(_toast)
	_toast.add_theme_font_size_override("font_size", 16)
	_toast.visible = false
	_toast.z_index = 60
	add_child(_toast)

# ── 진입/종료 ─────────────────────────────────────────────────
func open() -> void:
	if _selected == "":
		_selected = _pick_default()
	visible = true
	_refresh()

func _pick_default() -> String:
	for aid in GameState.portfolio:
		return str(aid)
	return FEATURED[0]

func _on_close() -> void:
	visible = false
	closed.emit()

# ── 갱신 ──────────────────────────────────────────────────────
func _asset_ids() -> Array:
	var ids: Array = FEATURED.duplicate()
	for aid in GameState.portfolio:
		if not ids.has(str(aid)):
			ids.append(str(aid))
	return ids

func _name_of(aid: String) -> String:
	for a in DataRegistry.assets:
		if str(a.get("id", "")) == aid:
			return str(a.get("name", aid))
	return aid

func _change_pct(aid: String) -> float:
	var hist: Array = GameState.price_history.get(aid, [])
	if hist.size() < 2:
		return 0.0
	return (float(hist[-1]) - float(hist[-2])) / max(float(hist[-2]), 0.01) * 100.0

func _refresh() -> void:
	if not visible:
		return

	# HUD
	var cash: float = GameState.money
	var assets: float = GameState.get_total_asset_value()
	var pct: int = clampi(int(assets / 3_000_000_000.0 * 100.0), 0, 100)
	var fg: int = int(GameState.market_context.get("fear_greed", 50))
	var cyc: String = str(GameState.market_context.get("cycle", "neutral"))
	var cyc_kr: String = {"bull": "🟢 상승장", "bear": "🔴 하락장", "neutral": "⚪ 횡보"}.get(cyc, "⚪ 횡보")
	var ap: int = GameState.action_points
	var ap_col: String = "#4adfaa" if ap > 0 else "#ff6060"
	_hud.text = "[b]💰 현금 %s[/b]    📊 총자산 [b]%s[/b] / 30억 [color=#aaa](%d%%)[/color]    %s  공포·탐욕 %d    [color=%s]⚡%d[/color]" % [
		GameState.format_money(cash), GameState.format_money(assets), pct, cyc_kr, fg, ap_col, ap]

	# 차트 헤더 — 현재가 + 변동 + 포지션 P&L
	var price: float = float(GameState.market_prices.get(_selected, 0.0))
	var ch: float = _change_pct(_selected)
	var ch_col: String = "#00c896" if ch >= 0 else "#ff5252"
	var ch_arrow: String = "▲" if ch >= 0 else "▼"
	var owned: Dictionary = GameState.portfolio.get(_selected, {})
	var qty: float = float(owned.get("quantity", 0.0))
	var hold_val: float = qty * price
	var avg: float = float(owned.get("avg_price", 0.0))
	var pl_str: String = ""
	if qty > 0 and avg > 0:
		var pl: float = (price - avg) / avg * 100.0
		var pl_abs: float = (price - avg) * qty
		var pl_col: String = "#00c896" if pl >= 0 else "#ff5252"
		var pl_arrow: String = "▲" if pl >= 0 else "▼"
		pl_str = "   [color=#c8a050]보유 %s[/color]  [color=%s]%s %+.1f%%  %+s원[/color]" % [
			GameState.format_money(hold_val), pl_col, pl_arrow, pl, GameState.format_money(pl_abs)]
	_chart_head.text = "[b]%s[/b]   [b]%s[/b]   [color=%s]%s %+.1f%%[/color]%s" % [
		_name_of(_selected), GameState.format_money(price), ch_col, ch_arrow, ch, pl_str]

	# 캔들 & MA 데이터 계산
	_prepare_chart_data()
	_chart.queue_redraw()

	# 거래 컨트롤
	_build_trade_controls(cash, qty, price, ap)

	# 자산 목록
	for c in _list_box.get_children():
		c.queue_free()
	for aid in _asset_ids():
		_list_box.add_child(_make_asset_row(str(aid)))

func _prepare_chart_data() -> void:
	var hist: Array = GameState.price_history.get(_selected, [])
	_chart_candles = []
	_chart_ma_fast = []
	_chart_ma_slow = []
	if hist.size() < 2:
		return

	# 캔들 생성: CANDLE_GROUP 가격씩 묶어 OHLC 시뮬레이션
	var i := 0
	while i < hist.size():
		var group_end: int = min(i + CANDLE_GROUP, hist.size())
		var slice: Array = hist.slice(i, group_end)
		var o: float = float(slice[0])
		var c: float = float(slice[-1])
		var h: float = o
		var l: float = o
		for p in slice:
			h = max(h, float(p))
			l = min(l, float(p))
		# 캔들 위크 시뮬레이션: 실제 범위 ±1.5%
		var body_size: float = abs(c - o)
		var wick_ext: float = body_size * 0.6 + (h - l) * 0.2
		h = max(h, max(o, c) + wick_ext * 0.5)
		l = min(l, min(o, c) - wick_ext * 0.5)
		if l < 1.0:
			l = 1.0
		_chart_candles.append({"o": o, "h": h, "l": l, "c": c})
		i += CANDLE_GROUP

	# MA 계산 (캔들 close 기준)
	var closes: Array = []
	for candle in _chart_candles:
		closes.append(float(candle["c"]))

	_chart_ma_fast = _calc_ma(closes, MA_FAST)
	_chart_ma_slow = _calc_ma(closes, MA_SLOW)

func _calc_ma(prices: Array, period: int) -> Array:
	var result: Array = []
	for i in range(prices.size()):
		if i < period - 1:
			result.append(NAN)
			continue
		var sum := 0.0
		for j in range(period):
			sum += float(prices[i - j])
		result.append(sum / float(period))
	return result

func _build_trade_controls(cash: float, qty: float, price: float, ap: int) -> void:
	for c in _buy_row.get_children():
		c.queue_free()
	for c in _sell_row.get_children():
		c.queue_free()
	var can_trade: bool = ap > 0
	_trade_label.text = ("매수/매도 시 시간(⚡) 1 소비  |  캔들 MA5=5개월 MA20=20개월 평균" if can_trade
		else "⚡ 시간이 없다 — 이번 달은 관망만. (닫고 다음 달)")

	# ── 매수 ──
	var buy_lbl := Label.new()
	buy_lbl.text = "  매수 "
	_font_for(buy_lbl, true)
	buy_lbl.add_theme_color_override("font_color", Color("#00c896"))
	_buy_row.add_child(buy_lbl)

	# 현금 비율 기반 버튼
	for pair in [["10%", 0.10], ["25%", 0.25], ["50%", 0.50], ["전량", 1.0]]:
		var b := Button.new()
		b.text = str(pair[0])
		_style_btn(b, "#0e2018", "#1e7a52")
		var ratio: float = float(pair[1])
		var amt: int = int(cash * ratio)
		b.disabled = not can_trade or cash < price or amt < int(price)
		b.pressed.connect(func(): _do_buy(int(cash * ratio)))
		_buy_row.add_child(b)

	# 고정 금액 추가 (단, 잔고 충분한 것만)
	for fixed_amt in [100_000, 1_000_000, 10_000_000]:
		if float(fixed_amt) <= cash:
			var b := Button.new()
			b.text = GameState.format_money(float(fixed_amt))
			_style_btn(b, "#0a1c14", "#166642")
			b.disabled = not can_trade
			var a: int = fixed_amt
			b.pressed.connect(func(): _do_buy(a))
			_buy_row.add_child(b)

	# ── 매도 ──
	var sell_lbl := Label.new()
	sell_lbl.text = "  매도 "
	_font_for(sell_lbl, true)
	sell_lbl.add_theme_color_override("font_color", Color("#ff6b6b"))
	_sell_row.add_child(sell_lbl)
	var has_hold: bool = qty > 0
	for pair in [["25%", 0.25], ["50%", 0.50], ["75%", 0.75], ["전량", 1.0]]:
		var b := Button.new()
		b.text = str(pair[0])
		_style_btn(b, "#201012", "#7a2e2e")
		b.disabled = not can_trade or not has_hold
		var r: float = float(pair[1])
		b.pressed.connect(func(): _do_sell(r))
		_sell_row.add_child(b)

	# 보유 P&L 요약
	if has_hold and float(GameState.portfolio.get(_selected, {}).get("avg_price", 0.0)) > 0:
		var avg: float = float(GameState.portfolio.get(_selected, {}).get("avg_price", 0.0))
		var cur: float = float(GameState.market_prices.get(_selected, 0.0))
		var pl_pct: float = (cur - avg) / avg * 100.0
		var pl_color: String = "#00c896" if pl_pct >= 0 else "#ff5252"
		var pl_lbl := Label.new()
		pl_lbl.text = "  (%+.1f%%)" % pl_pct
		pl_lbl.add_theme_font_size_override("font_size", 14)
		pl_lbl.add_theme_color_override("font_color", Color(pl_color))
		_font_for(pl_lbl, true)
		_sell_row.add_child(pl_lbl)

func _make_asset_row(aid: String) -> Button:
	var price: float = float(GameState.market_prices.get(aid, 0.0))
	var ch: float = _change_pct(aid)
	var ch_col: String = "#00c896" if ch >= 0 else "#ff5252"
	var ch_arrow: String = "▲" if ch >= 0 else "▼"
	var owned: Dictionary = GameState.portfolio.get(aid, {})
	var qty: float = float(owned.get("quantity", 0.0))
	var avg: float = float(owned.get("avg_price", 0.0))
	var hold_str: String = ""
	if qty > 0 and avg > 0:
		var pl_pct: float = (price - avg) / avg * 100.0
		var pl_col: String = "#00c896" if pl_pct >= 0 else "#ff5252"
		hold_str = "  [color=#c8a050]● %s[/color]  [color=%s]%+.1f%%[/color]" % [
			GameState.format_money(qty * price), pl_col, pl_pct]
	var rt := RichTextLabel.new()
	rt.bbcode_enabled = true
	rt.fit_content = true
	rt.scroll_active = false
	rt.custom_minimum_size = Vector2(0, 34)
	rt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_font_for(rt)
	rt.add_theme_font_size_override("normal_font_size", 13)
	var mark: String = "▸ " if aid == _selected else "   "
	rt.text = "%s[b]%s[/b]   %s   [color=%s]%s %+.1f%%[/color]%s" % [
		mark, _name_of(aid), GameState.format_money(price), ch_col, ch_arrow, ch, hold_str]
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(0, 36)
	btn.flat = true
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#11161f") if aid == _selected else Color("#0b0f16")
	st.border_color = Color("#3a4a6a") if aid == _selected else Color("#161c28")
	st.border_width_left = 3
	st.set_corner_radius_all(4)
	st.content_margin_left = 10
	btn.add_theme_stylebox_override("normal", st)
	var hov := st.duplicate()
	hov.bg_color = Color("#161d2a")
	btn.add_theme_stylebox_override("hover", hov)
	btn.add_theme_stylebox_override("pressed", st)
	var cap: String = aid
	btn.pressed.connect(func(): _select(cap))
	btn.add_child(rt)
	rt.set_anchors_preset(Control.PRESET_FULL_RECT)
	rt.offset_left = 12
	rt.offset_top = 7
	return btn

func _select(aid: String) -> void:
	_selected = aid
	AudioManager.play("click", -6.0)
	_pulse_node(_chart, 1.01, 0.16)
	_refresh()

# ── 거래 ──────────────────────────────────────────────────────
func _do_buy(krw: int) -> void:
	if GameState.action_points <= 0:
		_flash("⚡ 시간이 없다", "#ff5252"); return
	if GameState.money < float(krw) or krw <= 0:
		_flash("현금이 부족하다", "#ff5252"); return
	var price: float = float(GameState.market_prices.get(_selected, 0.0))
	if price <= 0:
		_flash("가격 데이터 없음", "#ff5252"); return
	if not GameState.spend_ap():
		return
	AudioManager.play("buy")
	inv.buy_asset(_selected, float(krw))
	_flash("📈 [b]%s[/b] 매수  %s" % [_name_of(_selected), GameState.format_money(float(krw))], "#00c896")
	_trade_burst("BUY", Color("#00c896"))
	_screen_flash(Color("#00c896"), 0.10, 0.22)
	_pulse_node(_chart, 1.018, 0.20)
	GameState.stats_changed.emit()
	_refresh()

func _do_sell(ratio: float) -> void:
	if GameState.action_points <= 0:
		_flash("⚡ 시간이 없다", "#ff5252"); return
	var owned: Dictionary = GameState.portfolio.get(_selected, {})
	if float(owned.get("quantity", 0.0)) <= 0:
		_flash("보유 수량이 없다", "#ff5252"); return
	var price: float = float(GameState.market_prices.get(_selected, 0.0))
	var qty: float = float(owned.get("quantity", 0.0))
	var avg: float = float(owned.get("avg_price", 0.0))
	var pl_pct: float = (price - avg) / avg * 100.0 if avg > 0 else 0.0
	var sell_val: float = qty * ratio * price
	var est_pnl: float = sell_val * ((price - avg) / maxf(avg, 0.01)) if avg > 0.0 else 0.0
	if not GameState.spend_ap():
		return
	AudioManager.play("money_gain" if est_pnl >= 0.0 else "money_loss")
	inv.sell_asset(_selected, ratio)
	if pl_pct >= 0:
		_screen_flash(Color("#00c896"), 0.12, 0.24)
		_flash("📉 %s 매도  +%s  (%+.1f%%)" % [_name_of(_selected),
			GameState.format_money(sell_val), pl_pct], "#00c896")
	else:
		_screen_flash(Color("#ff5252"), 0.12, 0.24)
		_flash("📉 %s 매도  %s  (%+.1f%%)" % [_name_of(_selected),
			GameState.format_money(sell_val), pl_pct], "#ff6b6b")
	_trade_burst(("TAKE PROFIT" if est_pnl >= 0.0 else "CUT LOSS"), Color("#00c896") if est_pnl >= 0.0 else Color("#ff5252"))
	if est_pnl < 0.0:
		_shake_node(_chart, 5.0, 0.18)
	else:
		_pulse_node(_chart, 1.018, 0.20)
	GameState.stats_changed.emit()
	_refresh()

func _flash(msg: String, color: String) -> void:
	if not is_instance_valid(_toast):
		return
	_toast.text = msg
	_toast.add_theme_color_override("font_color", Color(color))
	_toast.visible = true
	get_tree().create_timer(2.0).timeout.connect(func():
		if is_instance_valid(_toast):
			_toast.visible = false
	)

func _screen_flash(col: Color, alpha: float = 0.16, duration: float = 0.3) -> void:
	if not is_instance_valid(_flash_rect):
		return
	_flash_rect.color = Color(col.r, col.g, col.b, 0.0)
	var tw := create_tween()
	tw.tween_property(_flash_rect, "color:a", alpha, duration * 0.22)
	tw.tween_property(_flash_rect, "color:a", 0.0, duration * 0.78)

# ── 차트 그리기 ───────────────────────────────────────────────
func _draw_chart() -> void:
	var sz: Vector2 = _chart.size
	if sz.x < 40.0 or sz.y < 40.0:
		return
	_chart.draw_rect(Rect2(Vector2.ZERO, sz), Color("#0a0e16"))

	var pad_l: float = 64.0   # Y축 레이블 공간
	var pad_r: float = 12.0
	var pad_t: float = 12.0
	var pad_b: float = 28.0   # 볼륨 바 공간

	if _chart_candles.is_empty():
		_chart.draw_string(_font if _font else ThemeDB.fallback_font,
			Vector2(pad_l + 8.0, sz.y * 0.5),
			"거래가 쌓이면 캔들 차트가 그려집니다",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#5a6478"))
		return

	# 가격 범위
	var lo: float = INF
	var hi: float = -INF
	for candle in _chart_candles:
		lo = min(lo, float(candle["l"]))
		hi = max(hi, float(candle["h"]))
	if hi <= lo:
		hi = lo + lo * 0.01
	# MA 포함 범위
	for v in _chart_ma_fast:
		if not is_nan(float(v)):
			lo = min(lo, float(v))
			hi = max(hi, float(v))
	for v in _chart_ma_slow:
		if not is_nan(float(v)):
			lo = min(lo, float(v))
			hi = max(hi, float(v))
	var margin: float = (hi - lo) * 0.08
	lo -= margin
	hi += margin

	var chart_w: float = sz.x - pad_l - pad_r
	var chart_h: float = sz.y - pad_t - pad_b
	var vol_h: float = pad_b - 4.0

	var n: int = _chart_candles.size()

	# 드로우 레이아웃 상태 저장 (헬퍼 메서드에서 참조)
	_dc_lo = lo; _dc_hi = hi
	_dc_pad_t = pad_t; _dc_chart_h = chart_h
	_dc_pad_l = pad_l; _dc_chart_w = chart_w
	_dc_n = n

	# ── 그리드 & Y축 ──
	for gi in range(5):
		var price_at: float = lo + (hi - lo) * float(gi) / 4.0
		var gy: float = _dc_px(price_at)
		_chart.draw_line(Vector2(pad_l, gy), Vector2(sz.x - pad_r, gy),
			Color(1, 1, 1, 0.04), 1.0)
		var price_str: String = GameState.format_money(price_at)
		_chart.draw_string(_font if _font else ThemeDB.fallback_font,
			Vector2(2.0, gy + 4.0), price_str,
			HORIZONTAL_ALIGNMENT_LEFT, pad_l - 4.0, 10, Color("#5a7080"))

	# ── 볼륨 배경 ──
	_chart.draw_rect(Rect2(pad_l, sz.y - pad_b, chart_w, vol_h), Color(1, 1, 1, 0.02))

	# ── 캔들 ──
	var candle_w: float = max(chart_w / float(n) * 0.7, 2.0)
	var max_vol_proxy: float = 1.0
	for candle in _chart_candles:
		max_vol_proxy = max(max_vol_proxy, abs(float(candle["c"]) - float(candle["o"])) + 1.0)

	for i in range(n):
		var candle: Dictionary = _chart_candles[i]
		var o: float = float(candle["o"])
		var h: float = float(candle["h"])
		var l: float = float(candle["l"])
		var c: float = float(candle["c"])
		var is_bull: bool = c >= o
		var body_col: Color = Color("#00c896") if is_bull else Color("#ff5252")
		var wick_col: Color = Color(body_col.r, body_col.g, body_col.b, 0.7)

		var cx: float = _dc_cx(i)
		var oy: float = _dc_px(o)
		var cy: float = _dc_px(c)
		var hy: float = _dc_px(h)
		var ly: float = _dc_px(l)

		# 위크
		_chart.draw_line(Vector2(cx, hy), Vector2(cx, ly), wick_col, 1.0)
		# 몸통
		var body_top: float = min(oy, cy)
		var body_bot: float = max(oy, cy)
		var body_height: float = max(body_bot - body_top, 1.5)
		_chart.draw_rect(
			Rect2(cx - candle_w * 0.5, body_top, candle_w, body_height),
			body_col
		)

		# 볼륨 바 (몸통 크기 기반 시뮬레이션)
		var vol_proxy: float = abs(c - o) / max_vol_proxy
		var bar_h: float = vol_h * vol_proxy * 0.9
		var bar_col: Color = Color(body_col.r, body_col.g, body_col.b, 0.35)
		_chart.draw_rect(
			Rect2(cx - candle_w * 0.5, sz.y - pad_b + (vol_h - bar_h), candle_w, bar_h),
			bar_col
		)

	# ── MA 선 ──
	_draw_ma_line(_chart_ma_fast, Color("#f0c040", 0.85), 1.5)
	_draw_ma_line(_chart_ma_slow, Color("#4a90e8", 0.75), 1.5)

	# ── MA 범례 ──
	_chart.draw_string(_font if _font else ThemeDB.fallback_font,
		Vector2(pad_l + 4.0, pad_t + 14.0), "MA%d" % MA_FAST,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#f0c040", 0.85))
	_chart.draw_string(_font if _font else ThemeDB.fallback_font,
		Vector2(pad_l + 46.0, pad_t + 14.0), "MA%d" % MA_SLOW,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#4a90e8", 0.75))

	# ── 현재가 수평선 ──
	if n > 0:
		var last_c: float = float(_chart_candles[-1]["c"])
		var ly_line: float = _dc_px(last_c)
		_chart.draw_dashed_line(
			Vector2(pad_l, ly_line), Vector2(sz.x - pad_r, ly_line),
			Color("#00c896" if float(_chart_candles[-1]["c"]) >= float(_chart_candles[0]["c"]) else "#ff5252", 0.5),
			1.0, 4.0
		)

	# ── 내 평균단가 ──
	var owned: Dictionary = GameState.portfolio.get(_selected, {})
	var qty: float = float(owned.get("quantity", 0.0))
	var avg: float = float(owned.get("avg_price", 0.0))
	if qty > 0.0 and avg > 0.0 and avg >= lo and avg <= hi:
		var avg_y: float = _dc_px(avg)
		_chart.draw_dashed_line(Vector2(pad_l, avg_y), Vector2(sz.x - pad_r, avg_y),
			Color("#f0b429", 0.7), 1.0, 6.0)
		_chart.draw_string(_font if _font else ThemeDB.fallback_font,
			Vector2(pad_l + 4.0, avg_y - 4.0),
			"평단 " + GameState.format_money(avg),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#f0b429"))

func _dc_px(v: float) -> float:
	return _dc_pad_t + _dc_chart_h * (1.0 - (v - _dc_lo) / max(_dc_hi - _dc_lo, 0.001))

func _dc_cx(i: int) -> float:
	return _dc_pad_l + _dc_chart_w * (float(i) + 0.5) / float(max(_dc_n, 1))

func _draw_ma_line(ma: Array, col: Color, width: float) -> void:
	if ma.is_empty():
		return
	var prev_valid: Vector2 = Vector2(-1.0, -1.0)
	for i in range(ma.size()):
		var v = ma[i]
		if v == null or is_nan(float(v)):
			prev_valid = Vector2(-1.0, -1.0)
			continue
		var cx: float = _dc_cx(i)
		var cy: float = _dc_px(float(v))
		if prev_valid.x >= 0.0:
			_chart.draw_line(prev_valid, Vector2(cx, cy), col, width)
		prev_valid = Vector2(cx, cy)

# ── 버튼 스타일 ───────────────────────────────────────────────
func _style_btn(b: Button, bg: String, border: String) -> void:
	var st := StyleBoxFlat.new()
	st.bg_color = Color(bg)
	st.border_color = Color(border)
	st.set_border_width_all(1)
	st.set_corner_radius_all(5)
	st.content_margin_left = 12
	st.content_margin_right = 12
	st.content_margin_top = 7
	st.content_margin_bottom = 7
	var hov := st.duplicate()
	hov.bg_color = Color(bg).lightened(0.10)
	var dis := st.duplicate()
	dis.bg_color = Color("#14141c")
	dis.border_color = Color("#23232e")
	b.add_theme_stylebox_override("normal", st)
	b.add_theme_stylebox_override("hover", hov)
	b.add_theme_stylebox_override("pressed", st)
	b.add_theme_stylebox_override("disabled", dis)
	b.add_theme_color_override("font_color", Color("#dce4f0"))
	b.add_theme_color_override("font_disabled_color", Color("#4a4a58"))
	b.add_theme_font_size_override("font_size", 14)
	_font_for(b)
	b.focus_mode = Control.FOCUS_NONE

func _trade_burst(text: String, color: Color) -> void:
	var root_size := size
	if root_size.x <= 1.0 or root_size.y <= 1.0:
		root_size = get_viewport_rect().size
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.z_index = 75
	panel.size = Vector2(minf(360.0, root_size.x - 48.0), 48.0)
	panel.position = Vector2((root_size.x - panel.size.x) * 0.5, 140.0)
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
	_font_for(lbl, true)
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(lbl)

	var tw := create_tween()
	tw.tween_property(panel, "modulate:a", 1.0, 0.08)
	tw.tween_interval(0.44)
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
