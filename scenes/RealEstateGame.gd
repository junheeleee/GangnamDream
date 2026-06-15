extends Control
## RealEstateGame — 부동산 투자 분석 미니게임
## 3개 매물을 분석하고 하나를 골라 투자 or 전량 패스.
## 투자감각이 높을수록 숨겨진 리스크/기회 힌트가 표시된다.
## 결과는 GameState.money에 직접 반영.

signal closed

# 매물 풀 (다양한 지역·유형·리스크)
const PROPERTY_POOL: Array = [
	{
		"name": "노원구 소형 오피스텔",
		"type": "오피스텔",
		"price": 85_000_000,
		"monthly_rent": 380_000,
		"yield_pct": 5.4,
		"risk": 2,
		"tags": ["🏙 역세권", "📊 임대 안정"],
		"pros": "지하철 도보 3분. 공실 위험 낮음.",
		"cons": "노후화된 건물. 관리비 상승 추세.",
		"hidden_good": "도시 재개발 예정 구역 인접",
		"hidden_bad": "인근 오피스텔 공급 과잉 예정",
	},
	{
		"name": "성수동 소형 상가",
		"type": "상가",
		"price": 130_000_000,
		"monthly_rent": 720_000,
		"yield_pct": 6.6,
		"risk": 4,
		"tags": ["🔥 핫플레이스", "📈 시세차익 기대"],
		"pros": "유동인구 많음. 임차 수요 강함.",
		"cons": "권리금 별도. 공실 시 손실 큼.",
		"hidden_good": "대기업 입주 협의 중인 인근 빌딩",
		"hidden_bad": "임차인 계약 만료 6개월 후",
	},
	{
		"name": "인천 빌라 2층",
		"type": "빌라",
		"price": 55_000_000,
		"monthly_rent": 250_000,
		"yield_pct": 5.5,
		"risk": 1,
		"tags": ["💰 소액 진입", "🏠 전세 전환 가능"],
		"pros": "가장 저렴한 진입가. 전세 전환 시 리스크 최소.",
		"cons": "시세 상승 기대 낮음. 인천 외곽.",
		"hidden_good": "GTX 노선 수혜 예상 지역",
		"hidden_bad": "지하 주차장 없음 — 세입자 이탈 위험",
	},
	{
		"name": "강남 꼬마빌딩 지분",
		"type": "빌딩 지분",
		"price": 500_000_000,
		"monthly_rent": 2_800_000,
		"yield_pct": 6.7,
		"risk": 3,
		"tags": ["👑 강남", "💼 법인 공동투자"],
		"pros": "강남 토지 희소성. 장기 시세차익.",
		"cons": "지분 투자라 처분 어려움. 공동 결정 필요.",
		"hidden_good": "공동투자자 중 건설사 연결 가능",
		"hidden_bad": "공동투자자 1인이 매각 압박 중",
	},
	{
		"name": "수원 신축 아파트 청약권",
		"type": "청약권",
		"price": 30_000_000,
		"monthly_rent": 0,
		"yield_pct": 0.0,
		"risk": 5,
		"tags": ["🎲 투기성", "⚡ 단기 시세차익"],
		"pros": "분양가 대비 프리미엄 기대. 전매 제한 없음.",
		"cons": "프리미엄 없으면 분양가에 되팔아야 함.",
		"hidden_good": "이미 분양가 대비 3천만 프리미엄 형성",
		"hidden_bad": "인근 아파트 역전세 발생 중",
	},
	{
		"name": "도봉구 다가구주택",
		"type": "다가구",
		"price": 200_000_000,
		"monthly_rent": 1_100_000,
		"yield_pct": 6.6,
		"risk": 2,
		"tags": ["🏘 다세대 임대", "📊 현금흐름 안정"],
		"pros": "4가구 임대. 공실 분산 효과.",
		"cons": "건물 노후화. 수리비 예측 어려움.",
		"hidden_good": "세입자 4명 전원 장기 거주 의향",
		"hidden_bad": "지붕 방수 공사 필요 (약 800만원 예상)",
	},
]

const PROPERTY_COUNT: int = 3   # 한 세션에 보여줄 매물 수
const INVEST_OPTIONS: Array = [10_000_000, 30_000_000, 80_000_000]
const HOLD_TURNS: int = 3   # 3달 후 결과 반영 (exit_turn에 저장)

enum Phase { BROWSE, DETAIL, INVEST_AMOUNT, RESULT }

var _phase:     int   = Phase.BROWSE
var _properties: Array = []   # 이번 세션 매물 3개
var _selected:  Dictionary = {}
var _invest_amount: int = 0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

# UI
var _header_lbl:  Label
var _body_lbl:    RichTextLabel
var _hint_lbl:    Label
var _btn_a:       Button
var _btn_b:       Button
var _btn_c:       Button
var _btn_pass:    Button
var _btn_close:   Button

var _font:      FontFile
var _font_bold: FontFile

# ── 초기화 ─────────────────────────────────────────────────────────
func _ready() -> void:
	_rng.randomize()
	_font      = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile
	_build_ui()
	visible = false

func _af(n: Control, bold := false) -> void:
	var ft = _font_bold if bold else _font
	if ft and n: n.add_theme_font_override("font", ft)

func open() -> void:
	_rng.randomize()
	_phase = Phase.BROWSE
	_selected = {}
	_invest_amount = 0
	_pick_properties()
	visible = true
	_draw_browse()

# ── 매물 추첨 ──────────────────────────────────────────────────────
func _pick_properties() -> void:
	var pool: Array = PROPERTY_POOL.duplicate()
	pool.shuffle()
	# 플레이어 자금 범위에 맞는 것만 (진입가 이하만 필터 — 강남 꼬마빌딩 예외 항상 포함)
	var affordable: Array = pool.filter(func(p): return int(p.get("price", 0)) <= GameState.money * 50)
	if affordable.size() < PROPERTY_COUNT:
		affordable = pool  # 돈 없어도 구경은 가능
	affordable.shuffle()
	_properties = affordable.slice(0, PROPERTY_COUNT)

# ── BROWSE: 목록 보기 ──────────────────────────────────────────────
func _draw_browse() -> void:
	_phase = Phase.BROWSE
	_header_lbl.text = "🏠 부동산 매물 분석"
	_hint_lbl.text   = "투자감각이 높을수록 숨겨진 리스크/기회 정보가 보입니다."
	_hint_lbl.add_theme_color_override("font_color", Color("#4a5a72"))

	var lines: Array = ["[b]이번 달 추천 매물[/b]\n"]
	for i in range(_properties.size()):
		var p: Dictionary = _properties[i]
		var risk_str: String = "●".repeat(int(p.get("risk", 1))) + "○".repeat(5 - int(p.get("risk", 1)))
		var rent: int = int(p.get("monthly_rent", 0))
		var rent_str: String = "임대수익 없음" if rent == 0 else "월 %s" % GameState.format_money(rent)
		lines.append(
			"[color=#f0b429][b]%d. %s[/b][/color]  [color=#4a5a72](%s)[/color]\n"
			+ "   가격 %s  |  수익률 %.1f%%  |  위험도 %s\n"
			+ "   %s  |  %s\n"
			% [
				i + 1, str(p.get("name", "")), str(p.get("type", "")),
				GameState.format_money(int(p.get("price", 0))),
				float(p.get("yield_pct", 0.0)),
				risk_str,
				rent_str,
				"  ".join(p.get("tags", []) as Array),
			]
		)
	_body_lbl.text = "\n".join(lines)

	_btn_a.text = "1️⃣  %s 상세 보기" % str(_properties[0].get("name", ""))
	_btn_b.text = "2️⃣  %s 상세 보기" % str(_properties[1].get("name", ""))
	_btn_c.text = "3️⃣  %s 상세 보기" % (str(_properties[2].get("name", "")) if _properties.size() > 2 else "없음")
	_btn_pass.text    = "이번엔 패스"
	_btn_pass.visible = true
	for b in [_btn_a, _btn_b, _btn_c, _btn_pass]: b.disabled = false
	_btn_c.visible = _properties.size() > 2

# ── DETAIL: 매물 상세 ──────────────────────────────────────────────
func _draw_detail(prop: Dictionary) -> void:
	_phase    = Phase.DETAIL
	_selected = prop
	var skill: int = GameState.investment_skill
	_header_lbl.text = "🏠 %s" % str(prop.get("name", ""))

	var lines: Array = [
		"[b]%s[/b]  [color=#4a5a72]%s[/color]\n" % [str(prop.get("name", "")), str(prop.get("type", ""))],
		"💰 매입가: [b]%s[/b]" % GameState.format_money(int(prop.get("price", 0))),
	]
	var rent: int = int(prop.get("monthly_rent", 0))
	if rent > 0:
		lines.append("📅 월 임대수익: %s  (연 수익률 %.1f%%)" % [GameState.format_money(rent), float(prop.get("yield_pct", 0.0))])
	else:
		lines.append("📅 임대수익 없음 — 시세차익 목적")
	var risk: int = int(prop.get("risk", 1))
	lines.append("⚠  위험도: %s (%d/5)" % ["●".repeat(risk) + "○".repeat(5 - risk), risk])
	lines.append("")
	lines.append("[color=#4a5a72]특성: %s[/color]" % "  ".join(prop.get("tags", []) as Array))
	lines.append("")
	lines.append("[color=#00c896]✅ 장점[/color]  %s" % str(prop.get("pros", "")))
	lines.append("[color=#ff4444]❌ 단점[/color]  %s" % str(prop.get("cons", "")))

	# 힌트: 투자감각 기반
	if skill >= 25:
		lines.append("")
		lines.append("[color=#f0b429]💡 %s[/color]" % str(prop.get("hidden_good", "")))
	if skill >= 45:
		lines.append("[color=#ff8888]⚠  %s[/color]" % str(prop.get("hidden_bad", "")))

	_body_lbl.text = "\n".join(lines)

	if skill < 25:
		_hint_lbl.text = "💡 투자감각 25 이상이면 숨겨진 정보가 보입니다"
	elif skill < 45:
		_hint_lbl.text = "💡 투자감각 45 이상이면 리스크 정보도 보입니다"
	else:
		_hint_lbl.text = "⚡ 모든 정보가 표시됩니다"
	_hint_lbl.add_theme_color_override("font_color", Color("#4a5a72"))

	_btn_a.text    = "💸 투자하기"
	_btn_b.text    = "← 목록으로"
	_btn_c.visible = false
	_btn_pass.visible = false
	for b in [_btn_a, _btn_b]: b.disabled = false

# ── INVEST_AMOUNT: 금액 선택 ───────────────────────────────────────
func _draw_invest_amount() -> void:
	_phase = Phase.INVEST_AMOUNT
	_header_lbl.text = "💸 투자 금액 선택"
	_body_lbl.text   = (
		"[b]%s[/b]\n\n"
		+ "매입가: %s\n"
		+ "지분 투자 — 지분에 비례한 임대수익 + 시세차익 3개월 후 정산"
	) % [str(_selected.get("name", "")), GameState.format_money(int(_selected.get("price", 0)))]
	_hint_lbl.text = ""

	var opts: Array = [10_000_000, 30_000_000, 80_000_000]
	_btn_a.text = "소액  %s" % GameState.format_money(opts[0])
	_btn_b.text = "중간  %s" % GameState.format_money(opts[1])
	_btn_c.text = "대형  %s" % GameState.format_money(opts[2])
	_btn_c.visible = true
	_btn_pass.text    = "← 취소"
	_btn_pass.visible = true
	# 잔고 부족 시 비활성
	for i in range(3):
		var arr: Array = [_btn_a, _btn_b, _btn_c]
		arr[i].disabled = GameState.money < opts[i]
	_btn_pass.disabled = false

# ── RESULT ─────────────────────────────────────────────────────────
func _draw_result(invest: int) -> void:
	_phase = Phase.RESULT
	_invest_amount = invest

	# 임대수익 즉시 반영 (1개월치)
	var price: float   = float(_selected.get("price", 1.0))
	var rent: int      = int(_selected.get("monthly_rent", 0))
	var share: float   = float(invest) / price
	var monthly_cut: int = int(float(rent) * share)

	if monthly_cut > 0:
		GameState.add_money(float(monthly_cut))

	# 시세차익은 3개월 후 이벤트(플래그)로 처리 — 여기선 플래그만 세팅
	var exit_turn: int = GameState.turn + HOLD_TURNS
	GameState.flags["realestate_invest_turn"]  = exit_turn
	GameState.flags["realestate_invest_amount"] = invest
	GameState.flags["realestate_invest_risk"]  = int(_selected.get("risk", 1))
	GameState.flags["realestate_invest_name"]  = str(_selected.get("name", ""))

	GameState.add_log("🏠 부동산 투자: %s — %s 지분 투자" % [
		str(_selected.get("name", "")), GameState.format_money(invest)], "invest")
	GameState.investment_skill = mini(GameState.investment_skill + 1, 100)

	_header_lbl.text = "🏠 투자 완료"
	var rent_str: String = ("이번 달 임대수익 +%s 즉시 입금" % GameState.format_money(monthly_cut)) if monthly_cut > 0 else "임대수익 없음 (시세차익 기대)"
	_body_lbl.text = (
		"[b]%s[/b]\n\n"
		+ "투자금: %s  (지분 %.1f%%)\n"
		+ "%s\n\n"
		+ "[color=#f0b429]%d개월 후 시세 결과가 이벤트로 통보됩니다.[/color]"
	) % [
		str(_selected.get("name", "")),
		GameState.format_money(invest),
		share * 100.0,
		rent_str,
		HOLD_TURNS,
	]
	_hint_lbl.text = ""
	_btn_a.text    = "확인  ▶"
	_btn_b.visible = false
	_btn_c.visible = false
	_btn_pass.visible = false
	_btn_a.disabled = false

# ── 버튼 핸들러 ────────────────────────────────────────────────────
func _on_btn_a() -> void:
	match _phase:
		Phase.BROWSE:    _draw_detail(_properties[0])
		Phase.DETAIL:    _draw_invest_amount()
		Phase.INVEST_AMOUNT: _draw_result(10_000_000)
		Phase.RESULT:    _close_game()

func _on_btn_b() -> void:
	match _phase:
		Phase.BROWSE:    _draw_detail(_properties[1])
		Phase.DETAIL:    _draw_browse()
		Phase.INVEST_AMOUNT: _draw_result(30_000_000)

func _on_btn_c() -> void:
	match _phase:
		Phase.BROWSE:
			if _properties.size() > 2:
				_draw_detail(_properties[2])
		Phase.INVEST_AMOUNT: _draw_result(80_000_000)

func _on_btn_pass() -> void:
	match _phase:
		Phase.BROWSE:    _close_game()
		Phase.INVEST_AMOUNT: _draw_detail(_selected)

# ── UI 빌드 ────────────────────────────────────────────────────────
func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#060a08")
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	add_child(margin)

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 10)
	margin.add_child(body)

	var hdr := HBoxContainer.new()
	hdr.add_theme_constant_override("separation", 8)
	body.add_child(hdr)
	_header_lbl = _lbl("🏠 부동산 매물 분석", 20, "#34d399", true)
	_header_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(_header_lbl)
	_btn_close = _make_btn("✕", "#2a1818")
	_btn_close.custom_minimum_size = Vector2(32, 32)
	_btn_close.pressed.connect(_force_close)
	hdr.add_child(_btn_close)

	_hint_lbl = _lbl("", 12, "#4a5a72")
	_hint_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(_hint_lbl)

	_body_lbl = RichTextLabel.new()
	_body_lbl.bbcode_enabled = true
	_body_lbl.fit_content = false
	_body_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_af(_body_lbl)
	body.add_child(_body_lbl)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color("#1a2030"))
	body.add_child(sep)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)
	body.add_child(btn_row)
	_btn_a = _make_btn("", "#0a1a10"); _btn_a.pressed.connect(_on_btn_a)
	_btn_b = _make_btn("", "#1a1a2a"); _btn_b.pressed.connect(_on_btn_b)
	_btn_c = _make_btn("", "#1a1a2a"); _btn_c.pressed.connect(_on_btn_c)
	for b in [_btn_a, _btn_b, _btn_c]:
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size = Vector2(0, 44)
		btn_row.add_child(b)

	_btn_pass = _make_btn("이번엔 패스", "#2a1a0a")
	_btn_pass.custom_minimum_size = Vector2(0, 36)
	_btn_pass.pressed.connect(_on_btn_pass)
	body.add_child(_btn_pass)

func _close_game() -> void:
	visible = false
	emit_signal("closed")

func _force_close() -> void:
	visible = false
	emit_signal("closed")

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
