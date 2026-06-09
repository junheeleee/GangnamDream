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

# 노드
var _hud: RichTextLabel
var _chart: Control
var _chart_head: RichTextLabel
var _list_box: VBoxContainer
var _trade_label: Label
var _buy_row: HBoxContainer
var _sell_row: HBoxContainer
var _toast: Label

func setup(investment_system) -> void:
	inv = investment_system

# ── 폰트 ──────────────────────────────────────────────────────
func _load_fonts() -> void:
	_font      = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile
	FontKit.attach_emoji_fallback(_font)
	FontKit.attach_emoji_fallback(_font_bold)

func _font_for(lbl, bold: bool = false) -> void:
	var f = _font_bold if bold else _font
	if f:
		lbl.add_theme_font_override("font", f)
		if lbl is RichTextLabel:
			lbl.add_theme_font_override("normal_font", f)

# ── 구성 ──────────────────────────────────────────────────────
func _ready() -> void:
	_load_fonts()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)  # 오프셋까지 0 — 루트 0x0 collapse 방지
	_build_ui()
	visible = false

func _build_ui() -> void:
	# 배경
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#070a10")
	add_child(bg)

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
	_chart.offset_bottom = 300
	_chart.draw.connect(_draw_chart)
	add_child(_chart)

	# ── 거래 컨트롤 ──
	_trade_label = Label.new()
	_trade_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_trade_label.offset_left = 24
	_trade_label.offset_top = 312
	_trade_label.offset_right = -24
	_font_for(_trade_label)
	_trade_label.add_theme_font_size_override("font_size", 13)
	_trade_label.add_theme_color_override("font_color", Color("#9aa4b8"))
	add_child(_trade_label)

	_buy_row = HBoxContainer.new()
	_buy_row.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_buy_row.offset_left = 24
	_buy_row.offset_top = 338
	_buy_row.offset_right = -24
	_buy_row.add_theme_constant_override("separation", 8)
	add_child(_buy_row)

	_sell_row = HBoxContainer.new()
	_sell_row.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_sell_row.offset_left = 24
	_sell_row.offset_top = 382
	_sell_row.offset_right = -24
	_sell_row.add_theme_constant_override("separation", 8)
	add_child(_sell_row)

	# ── 자산 목록 (스크롤) ──
	var list_head := Label.new()
	list_head.text = "──  종목  ──  (눌러서 선택)"
	list_head.set_anchors_preset(Control.PRESET_TOP_WIDE)
	list_head.offset_left = 24
	list_head.offset_top = 430
	_font_for(list_head)
	list_head.add_theme_font_size_override("font_size", 12)
	list_head.add_theme_color_override("font_color", Color("#5a6478"))
	add_child(list_head)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 18
	scroll.offset_top = 452
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
	_toast.add_theme_font_size_override("font_size", 15)
	_toast.visible = false
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
	_hud.text = "[b]💰 현금 %s[/b]    📊 총자산 [b]%s[/b] / 30억 (%d%%)    %s  공포·탐욕 %d    ⚡%d" % [
		GameState.format_money(cash), GameState.format_money(assets), pct, cyc_kr, fg, ap]

	# 차트 헤더
	var price: float = float(GameState.market_prices.get(_selected, 0.0))
	var ch: float = _change_pct(_selected)
	var ch_col: String = "#00c896" if ch >= 0 else "#ff5252"
	var owned: Dictionary = GameState.portfolio.get(_selected, {})
	var qty: float = float(owned.get("quantity", 0.0))
	var hold_val: float = qty * price
	var avg: float = float(owned.get("avg_price", 0.0))
	var pl_str: String = ""
	if qty > 0 and avg > 0:
		var pl: float = (price - avg) / avg * 100.0
		var pl_col: String = "#00c896" if pl >= 0 else "#ff5252"
		pl_str = "   보유 %s [color=%s](%+.1f%%)[/color]" % [GameState.format_money(hold_val), pl_col, pl]
	_chart_head.text = "[b]%s[/b]   %s   [color=%s]%+.1f%%[/color]%s" % [
		_name_of(_selected), GameState.format_money(price), ch_col, ch, pl_str]
	_chart.queue_redraw()

	# 거래 컨트롤
	_build_trade_controls(cash, qty, price, ap)

	# 자산 목록
	for c in _list_box.get_children():
		c.queue_free()
	for aid in _asset_ids():
		_list_box.add_child(_make_asset_row(str(aid)))

func _build_trade_controls(cash: float, qty: float, price: float, ap: int) -> void:
	for c in _buy_row.get_children():
		c.queue_free()
	for c in _sell_row.get_children():
		c.queue_free()
	var can_trade: bool = ap > 0
	_trade_label.text = ("거래 시 시간(⚡) 1 소비" if can_trade else "⚡ 시간이 없다 — 이번 달은 관망만. (닫고 다음 달)")

	var buy_lbl := Label.new()
	buy_lbl.text = "  매수 "
	_font_for(buy_lbl, true)
	buy_lbl.add_theme_color_override("font_color", Color("#00c896"))
	_buy_row.add_child(buy_lbl)
	for amt in [100000, 500000, 2000000]:
		var b := Button.new()
		b.text = GameState.format_money(float(amt))
		_style_btn(b, "#0e2018", "#1e7a52")
		b.disabled = not can_trade or cash < float(amt)
		var a: int = amt
		b.pressed.connect(func(): _do_buy(a))
		_buy_row.add_child(b)
	var allin := Button.new()
	allin.text = "최대"
	_style_btn(allin, "#12281c", "#2aa060")
	allin.disabled = not can_trade or cash < float(GameState.market_prices.get(_selected, 1e9))
	allin.pressed.connect(func(): _do_buy(int(GameState.money)))
	_buy_row.add_child(allin)

	var sell_lbl := Label.new()
	sell_lbl.text = "  매도 "
	_font_for(sell_lbl, true)
	sell_lbl.add_theme_color_override("font_color", Color("#ff6b6b"))
	_sell_row.add_child(sell_lbl)
	var has_hold: bool = qty > 0
	for pair in [["절반", 0.5], ["전량", 1.0]]:
		var b := Button.new()
		b.text = str(pair[0])
		_style_btn(b, "#201012", "#7a2e2e")
		b.disabled = not can_trade or not has_hold
		var r: float = float(pair[1])
		b.pressed.connect(func(): _do_sell(r))
		_sell_row.add_child(b)

func _make_asset_row(aid: String) -> Button:
	var price: float = float(GameState.market_prices.get(aid, 0.0))
	var ch: float = _change_pct(aid)
	var ch_col: String = "#00c896" if ch >= 0 else "#ff5252"
	var owned: Dictionary = GameState.portfolio.get(aid, {})
	var qty: float = float(owned.get("quantity", 0.0))
	var hold: String = ("  ●보유 " + GameState.format_money(qty * price)) if qty > 0 else ""
	var rt := RichTextLabel.new()
	rt.bbcode_enabled = true
	rt.fit_content = true
	rt.scroll_active = false
	rt.custom_minimum_size = Vector2(0, 34)
	rt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_font_for(rt)
	rt.add_theme_font_size_override("normal_font_size", 14)
	var mark: String = "▸ " if aid == _selected else "   "
	rt.text = "%s[b]%s[/b]   %s   [color=%s]%+.1f%%[/color][color=#c8a050]%s[/color]" % [
		mark, _name_of(aid), GameState.format_money(price), ch_col, ch, hold]
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
	_refresh()

# ── 거래 ──────────────────────────────────────────────────────
func _do_buy(krw: int) -> void:
	if GameState.action_points <= 0:
		_flash("⚡ 시간이 없다", "#ff5252"); return
	if GameState.money < float(krw):
		_flash("현금이 부족하다", "#ff5252"); return
	if not GameState.spend_ap():
		return
	AudioManager.play("money_gain")
	inv.buy_asset(_selected, float(krw))
	_flash("📈 %s 매수 %s" % [_name_of(_selected), GameState.format_money(float(krw))], "#00c896")
	GameState.stats_changed.emit()
	_refresh()

func _do_sell(ratio: float) -> void:
	if GameState.action_points <= 0:
		_flash("⚡ 시간이 없다", "#ff5252"); return
	var owned: Dictionary = GameState.portfolio.get(_selected, {})
	if float(owned.get("quantity", 0.0)) <= 0:
		_flash("보유 수량이 없다", "#ff5252"); return
	if not GameState.spend_ap():
		return
	AudioManager.play("money_loss")
	inv.sell_asset(_selected, ratio)
	_flash("📉 %s 매도 (%d%%)" % [_name_of(_selected), int(ratio * 100)], "#ffb86b")
	GameState.stats_changed.emit()
	_refresh()

func _flash(msg: String, color: String) -> void:
	_toast.text = msg
	_toast.add_theme_color_override("font_color", Color(color))
	_toast.visible = true
	var t := get_tree().create_timer(1.6)
	t.timeout.connect(func():
		if is_instance_valid(_toast):
			_toast.visible = false
	)

# ── 차트 그리기 ───────────────────────────────────────────────
func _draw_chart() -> void:
	var sz: Vector2 = _chart.size
	if sz.x < 20.0 or sz.y < 20.0:
		return
	_chart.draw_rect(Rect2(Vector2.ZERO, sz), Color("#0a0e16"))
	var hist: Array = GameState.price_history.get(_selected, [])
	var pad: float = 14.0
	# 그리드
	for g in range(4):
		var gy: float = pad + (sz.y - 2.0 * pad) * float(g) / 3.0
		_chart.draw_line(Vector2(pad, gy), Vector2(sz.x - pad, gy), Color(1, 1, 1, 0.05), 1.0)
	if hist.size() < 2:
		var f := ThemeDB.fallback_font
		_chart.draw_string(f, Vector2(pad + 6, sz.y / 2.0), "거래가 쌓이면 차트가 그려집니다",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#5a6478"))
		return
	var lo: float = INF
	var hi: float = -INF
	for p in hist:
		lo = min(lo, float(p))
		hi = max(hi, float(p))
	if hi <= lo:
		hi = lo + 1.0
	var n: int = hist.size()
	var pts: PackedVector2Array = PackedVector2Array()
	for i in range(n):
		var x: float = pad + (sz.x - 2.0 * pad) * float(i) / float(n - 1)
		var norm: float = (float(hist[i]) - lo) / (hi - lo)
		var y: float = (sz.y - pad) - (sz.y - 2.0 * pad) * norm
		pts.append(Vector2(x, y))
	var up: bool = float(hist[-1]) >= float(hist[0])
	var col: Color = Color("#00c896") if up else Color("#ff5252")
	# 영역 채우기 (라인 아래)
	var fill_pts: PackedVector2Array = pts.duplicate()
	fill_pts.append(Vector2(pts[-1].x, sz.y - pad))
	fill_pts.append(Vector2(pts[0].x, sz.y - pad))
	var fcol: Color = col
	fcol.a = 0.10
	_chart.draw_colored_polygon(fill_pts, fcol)
	_chart.draw_polyline(pts, col, 2.5, true)
	_chart.draw_circle(pts[-1], 4.0, col)

# ── 버튼 스타일 ───────────────────────────────────────────────
func _style_btn(b: Button, bg: String, border: String) -> void:
	var st := StyleBoxFlat.new()
	st.bg_color = Color(bg)
	st.border_color = Color(border)
	st.set_border_width_all(1)
	st.set_corner_radius_all(5)
	st.content_margin_left = 14
	st.content_margin_right = 14
	st.content_margin_top = 7
	st.content_margin_bottom = 7
	var hov := st.duplicate()
	hov.bg_color = Color(bg).lightened(0.08)
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
