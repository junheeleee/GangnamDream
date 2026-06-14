extends Control
## JeongseonCasino — 정선 카지노 허브 씬.
## 5개 카지노 게임(바카라·블랙잭·슬롯·룰렛·빅휠)을 한 장소에서 진입.
## MainGame이 overlay로 붙이고 open()으로 호출. 닫으면 closed 시그널.

signal closed

const COLOR_BG     := Color(0.04, 0.03, 0.08, 0.97)
const COLOR_HEADER := Color(0.10, 0.08, 0.20, 1.0)
const COLOR_GOLD   := Color(0.95, 0.80, 0.20, 1.0)
const COLOR_ACCENT := Color(0.30, 0.20, 0.60, 1.0)

# 하위 미니게임 씬들 (MainGame이 주입)
var baccarat_table
var blackjack_table
var slot_machine_game
var roulette_table
var big_wheel_game

var _font: FontFile
var _font_bold: FontFile

var _balance_lbl: Label
var _session_lbl: Label
var _msg_lbl: Label
var _entry_balance: int = 0

# ── 초기화 ─────────────────────────────────────────────────────────
func _ready() -> void:
	_load_fonts()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 90
	visible = false
	_build_ui()

func _load_fonts() -> void:
	_font      = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile

func _f(n: Control, bold: bool = false) -> void:
	if not n:
		return
	var ft: FontFile = _font_bold if bold else _font
	if not ft:
		return
	if n is Label or n is Button or n is RichTextLabel:
		n.add_theme_font_override("font", ft)
		if n is RichTextLabel:
			n.add_theme_font_override("normal_font", ft)

func open() -> void:
	visible = true
	_entry_balance = GameState.money
	# 이번 세션 임시 플래그 초기화 (새 방문 시 리셋)
	GameState.flags["jeongseon_session_loss"] = false
	GameState.flags["jeongseon_session_win"]  = false
	# 첫 방문 플래그 설정 + 환영 메시지
	if not GameState.flags.get("jeongseon_first_visit", false):
		GameState.flags["jeongseon_first_visit"] = true
		if _msg_lbl:
			_msg_lbl.text = "처음 왔군요.\n화려한 조명과 기계음이 섞인 공간 — 이곳이 정선 카지노입니다."
	_refresh_balance()

func _close() -> void:
	# 세션 손익 기록 → 후속 이벤트 플래그
	var delta: int = GameState.money - _entry_balance
	if delta <= -500000:
		GameState.flags["jeongseon_session_loss"] = true
	elif delta >= 1000000:
		GameState.flags["jeongseon_session_win"]  = true
	# 방문 자체가 중독 성향을 조금씩 높인다
	GameState.modify_hidden_stat("addiction_tendency", 3)
	visible = false
	emit_signal("closed")

func _refresh_balance() -> void:
	if _balance_lbl:
		_balance_lbl.text = "잔액: ₩%s" % _fmt(GameState.money)
	if _session_lbl:
		var delta: int = GameState.money - _entry_balance
		if delta > 0:
			_session_lbl.text = "+₩%s" % _fmt(delta)
			_session_lbl.add_theme_color_override("font_color", Color("#3de87a"))
		elif delta < 0:
			_session_lbl.text = "-₩%s" % _fmt(-delta)
			_session_lbl.add_theme_color_override("font_color", Color("#e85d5d"))
		else:
			_session_lbl.text = "±₩0"
			_session_lbl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.6))

# ── UI 빌드 ──────────────────────────────────────────────────────
func _build_ui() -> void:
	# 배경
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = COLOR_BG
	add_child(bg)

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	add_child(root)

	# ── 헤더 ──
	var header := _make_panel(COLOR_HEADER)
	header.custom_minimum_size = Vector2(0, 72)
	root.add_child(header)
	var hrow := HBoxContainer.new()
	hrow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hrow.add_theme_constant_override("separation", 12)
	header.add_child(hrow)

	var title_lbl := Label.new()
	title_lbl.text = "🎰  정선 카지노"
	title_lbl.add_theme_font_size_override("font_size", 24)
	title_lbl.add_theme_color_override("font_color", COLOR_GOLD)
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_f(title_lbl, true)
	hrow.add_child(title_lbl)

	_balance_lbl = Label.new()
	_balance_lbl.add_theme_font_size_override("font_size", 14)
	_balance_lbl.add_theme_color_override("font_color", Color(0.8, 0.9, 0.8))
	_f(_balance_lbl)
	hrow.add_child(_balance_lbl)

	_session_lbl = Label.new()
	_session_lbl.add_theme_font_size_override("font_size", 13)
	_session_lbl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.6))
	_f(_session_lbl, true)
	hrow.add_child(_session_lbl)

	var exit_btn := _make_btn("나가기", "#6a6a6a")
	exit_btn.custom_minimum_size = Vector2(90, 44)
	exit_btn.pressed.connect(_close)
	hrow.add_child(exit_btn)

	# ── 메시지 ──
	_msg_lbl = Label.new()
	_msg_lbl.text = "원하는 게임을 선택하세요"
	_msg_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_msg_lbl.add_theme_font_size_override("font_size", 14)
	_msg_lbl.add_theme_color_override("font_color", Color(0.7, 0.65, 0.8))
	_msg_lbl.add_theme_constant_override("margin_top", 12)
	_f(_msg_lbl)
	root.add_child(_msg_lbl)

	# ── 게임 목록 (2열 그리드) ──
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 12)
	root.add_child(spacer)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var gm := MarginContainer.new()
	gm.add_theme_constant_override("margin_left", 24)
	gm.add_theme_constant_override("margin_right", 24)
	gm.add_theme_constant_override("margin_top", 8)
	gm.add_theme_constant_override("margin_bottom", 8)
	gm.add_child(grid)
	root.add_child(gm)

	_add_game_card(grid, "🃏", "바카라",
		"뱅커 vs 플레이어\n6덱 슈 · 로드맵 · 커미션\n하우스엣지 1.06%~",
		"#1a1a2e", "#4a4aff", "_launch_baccarat", "baccarat")

	_add_game_card(grid, "🂡", "블랙잭",
		"기본전략 힌트 내장\n더블다운 · 스플릿\n하우스엣지 0.5%~",
		"#1a2e1a", "#4aff4a", "_launch_blackjack", "blackjack")

	_add_game_card(grid, "🎰", "슬롯머신",
		"777 잭팟 200배\n체리 조합으로 소액 당첨\n이론 RTP 90%",
		"#2e1a1a", "#ff4a4a", "_launch_slot", "slot")

	_add_game_card(grid, "🎡", "룰렛",
		"유럽식 룰렛 0~36\n단일숫자 35:1 최고배당\n하우스엣지 2.70%",
		"#1a2e2a", "#4affcc", "_launch_roulette", "roulette")

	_add_game_card(grid, "🎯", "빅휠",
		"바늘이 멈춘 구역 배당\n조커 45:1 최고배당\n가장 단순한 카지노 게임",
		"#2e2a1a", "#ffcc4a", "_launch_bigwheel", "bigwheel")

	# ── 안내 ──
	var tip_lbl := Label.new()
	tip_lbl.text = "⚠ 도박은 중독성이 있습니다. 적정 한도 내에서 즐기세요."
	tip_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip_lbl.add_theme_font_size_override("font_size", 11)
	tip_lbl.add_theme_color_override("font_color", Color(0.5, 0.4, 0.4))
	tip_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(tip_lbl)

func _add_game_card(parent: Control, icon: String, name_kr: String,
		desc: String, bg_hex: String, accent_hex: String, fn: String,
		tutorial_id: String = "") -> void:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = Vector2(0, 150)
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color.html(bg_hex)
	ps.border_color = Color.html(accent_hex)
	ps.border_width_left   = 2
	ps.border_width_right  = 2
	ps.border_width_top    = 2
	ps.border_width_bottom = 2
	ps.corner_radius_top_left     = 8
	ps.corner_radius_top_right    = 8
	ps.corner_radius_bottom_left  = 8
	ps.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", ps)
	parent.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	var mc := MarginContainer.new()
	mc.add_theme_constant_override("margin_left", 14)
	mc.add_theme_constant_override("margin_right", 14)
	mc.add_theme_constant_override("margin_top", 12)
	mc.add_theme_constant_override("margin_bottom", 12)
	mc.add_child(vbox)
	panel.add_child(mc)

	var icon_lbl := Label.new()
	icon_lbl.text = icon
	icon_lbl.add_theme_font_size_override("font_size", 36)
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(icon_lbl)

	var title_l := Label.new()
	title_l.text = name_kr
	title_l.add_theme_font_size_override("font_size", 18)
	title_l.add_theme_color_override("font_color", Color.html(accent_hex))
	title_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_f(title_l, true)
	vbox.add_child(title_l)

	var desc_l := Label.new()
	desc_l.text = desc
	desc_l.add_theme_font_size_override("font_size", 11)
	desc_l.add_theme_color_override("font_color", Color(0.65, 0.65, 0.7))
	desc_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_f(desc_l)
	vbox.add_child(desc_l)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 6)
	vbox.add_child(btn_row)

	if tutorial_id != "":
		var help_btn := Button.new()
		help_btn.text = "❓ 규칙"
		help_btn.add_theme_font_size_override("font_size", 11)
		var hbs := StyleBoxFlat.new()
		hbs.bg_color = Color(0.0, 0.0, 0.0, 0.0)
		hbs.border_color = Color.html(accent_hex)
		hbs.border_width_left   = 1
		hbs.border_width_right  = 1
		hbs.border_width_top    = 1
		hbs.border_width_bottom = 1
		hbs.corner_radius_top_left     = 4
		hbs.corner_radius_top_right    = 4
		hbs.corner_radius_bottom_left  = 4
		hbs.corner_radius_bottom_right = 4
		help_btn.add_theme_stylebox_override("normal", hbs)
		help_btn.add_theme_color_override("font_color", Color.html(accent_hex))
		help_btn.custom_minimum_size = Vector2(70, 0)
		_f(help_btn)
		var tid := tutorial_id
		help_btn.pressed.connect(func(): TutorialOverlay.force_show(tid, self))
		btn_row.add_child(help_btn)

	var btn := Button.new()
	btn.text = "▶  입장"
	btn.add_theme_font_size_override("font_size", 13)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var bs := StyleBoxFlat.new()
	bs.bg_color = Color.html(accent_hex)
	bs.corner_radius_top_left     = 4
	bs.corner_radius_top_right    = 4
	bs.corner_radius_bottom_left  = 4
	bs.corner_radius_bottom_right = 4
	btn.add_theme_stylebox_override("normal", bs)
	btn.add_theme_color_override("font_color", Color(0.05, 0.05, 0.05))
	_f(btn, true)
	btn.pressed.connect(func(): self.call(fn))
	btn_row.add_child(btn)

# ── 게임 런처 ─────────────────────────────────────────────────
func _launch_baccarat() -> void:
	if not baccarat_table:
		_msg_lbl.text = "바카라 테이블을 불러올 수 없습니다."
		return
	visible = false
	baccarat_table.open()
	if not baccarat_table.closed.is_connected(_on_sub_game_closed):
		baccarat_table.closed.connect(_on_sub_game_closed)

func _launch_blackjack() -> void:
	if not blackjack_table:
		_msg_lbl.text = "블랙잭 테이블을 불러올 수 없습니다."
		return
	visible = false
	blackjack_table.open()
	if not blackjack_table.closed.is_connected(_on_sub_game_closed):
		blackjack_table.closed.connect(_on_sub_game_closed)

func _launch_slot() -> void:
	if not slot_machine_game:
		_msg_lbl.text = "슬롯머신을 불러올 수 없습니다."
		return
	visible = false
	slot_machine_game.open()
	if not slot_machine_game.closed.is_connected(_on_sub_game_closed):
		slot_machine_game.closed.connect(_on_sub_game_closed)

func _launch_roulette() -> void:
	if not roulette_table:
		_msg_lbl.text = "룰렛 테이블을 불러올 수 없습니다."
		return
	visible = false
	roulette_table.open()
	if not roulette_table.closed.is_connected(_on_sub_game_closed):
		roulette_table.closed.connect(_on_sub_game_closed)

func _launch_bigwheel() -> void:
	if not big_wheel_game:
		_msg_lbl.text = "빅휠을 불러올 수 없습니다."
		return
	visible = false
	big_wheel_game.open()
	if not big_wheel_game.closed.is_connected(_on_sub_game_closed):
		big_wheel_game.closed.connect(_on_sub_game_closed)

func _on_sub_game_closed() -> void:
	# 하위 게임이 닫히면 허브로 복귀
	visible = true
	_refresh_balance()

# ── 헬퍼 ──────────────────────────────────────────────────────
func _make_panel(col: Color) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	p.add_theme_stylebox_override("panel", sb)
	return p

func _make_btn(text: String, hex: String) -> Button:
	var b := Button.new()
	b.text = text
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color.html(hex)
	sb.corner_radius_top_left     = 4
	sb.corner_radius_top_right    = 4
	sb.corner_radius_bottom_left  = 4
	sb.corner_radius_bottom_right = 4
	b.add_theme_stylebox_override("normal", sb)
	_f(b)
	return b

func _fmt(n: int) -> String:
	var s := str(abs(n))
	var result: String = ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	return ("-" if n < 0 else "") + result
