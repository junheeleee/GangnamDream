extends Control
## JeongseonCasino — 정선 카지노 허브 씬.
## 6개 카지노 게임(바카라·블랙잭·슬롯·룰렛·빅휠·다이사이)을 한 장소에서 진입.
## MainGame이 overlay로 붙이고 open()으로 호출. 닫으면 closed 시그널.

signal closed

const COLOR_BG     := Color(0.04, 0.03, 0.08, 0.97)
const COLOR_HEADER := Color(0.10, 0.08, 0.20, 1.0)
const COLOR_GOLD   := Color(0.95, 0.80, 0.20, 1.0)
const COLOR_ACCENT := Color(0.30, 0.20, 0.60, 1.0)
const CASINO_BG_TEX := preload("res://assets/backgrounds/casino_interior.png")
const JOY_BUTTON_WEST := 2
const JOY_BUTTON_NORTH := 3

# 하위 미니게임 씬들 (MainGame이 주입)
var baccarat_table
var blackjack_table
var slot_machine_game
var roulette_table
var big_wheel_game
var dai_sai_table

var _font: FontFile
var _font_bold: FontFile

var _balance_lbl: Label
var _session_lbl: Label
var _msg_lbl: Label
var _entry_balance: int = 0
var _pad_navigation_active: bool = false
var _pad_game_idx: int = 0
var _game_cards: Array = []
var _game_entries: Array = []
var _pad_hint_lbl: Label
var _glossary_overlay: Control

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

func _tr(ko: String, en: String) -> String:
	return LocaleManager.ui(ko, en)

func open() -> void:
	visible = true
	_pad_navigation_active = false
	_pad_game_idx = clampi(_pad_game_idx, 0, maxi(_game_entries.size() - 1, 0))
	_refresh_pad_cursor()
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.25).set_trans(Tween.TRANS_SINE)
	AudioManager.play("open_modal")
	_entry_balance = GameState.money
	# 이번 세션 임시 플래그 초기화 (새 방문 시 리셋)
	GameState.flags["jeongseon_session_loss"] = false
	GameState.flags["jeongseon_session_win"]  = false
	# 첫 방문 플래그 설정 + 환영 메시지
	if not GameState.flags.get("jeongseon_first_visit", false):
		GameState.flags["jeongseon_first_visit"] = true
		if _msg_lbl:
			_msg_lbl.text = _tr(
				"처음 왔군요.\n화려한 조명과 기계음이 섞인 공간 — 이곳이 정선 카지노입니다.",
				"First time here.\nLights, machine noise, and felt tables — this is Jeongseon Casino."
			)
	_refresh_balance()
	_refresh_pad_cursor()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey:
		var key := event as InputEventKey
		if key.echo:
			return

	var pad_navigation_event := event.is_action_pressed("gd_tab_prev") \
			or event.is_action_pressed("gd_tab_next") \
			or event.is_action_pressed("ui_up") \
			or event.is_action_pressed("ui_down") \
			or event.is_action_pressed("ui_left") \
			or event.is_action_pressed("ui_right") \
			or event.is_action_pressed("ui_accept") \
			or event.is_action_pressed("ui_cancel") \
			or _joy_button_pressed(event, JOY_BUTTON_WEST) \
			or _joy_button_pressed(event, JOY_BUTTON_NORTH)
	if pad_navigation_event:
		_pad_navigation_active = true

	var handled := false
	if is_instance_valid(_glossary_overlay):
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
			_glossary_overlay.queue_free()
			_glossary_overlay = null
			handled = true
	elif event.is_action_pressed("ui_up"):
		handled = _pad_move_game(-2)
	elif event.is_action_pressed("ui_down"):
		handled = _pad_move_game(2)
	elif event.is_action_pressed("gd_tab_prev") or event.is_action_pressed("ui_left"):
		handled = _pad_move_game(-1)
	elif event.is_action_pressed("gd_tab_next") or event.is_action_pressed("ui_right"):
		handled = _pad_move_game(1)
	elif event.is_action_pressed("ui_accept"):
		handled = _pad_launch_selected_game()
	elif event.is_action_pressed("ui_cancel"):
		_close()
		handled = true
	elif _joy_button_pressed(event, JOY_BUTTON_NORTH):
		handled = _pad_show_selected_rules()
	elif _joy_button_pressed(event, JOY_BUTTON_WEST):
		_show_casino_glossary()
		handled = true

	if handled:
		get_viewport().set_input_as_handled()

func _joy_button_pressed(event: InputEvent, button_index: int) -> bool:
	if not (event is InputEventJoypadButton):
		return false
	var joy := event as InputEventJoypadButton
	return joy.pressed and int(joy.button_index) == button_index

func _should_show_pad_cursor() -> bool:
	return _pad_navigation_active or ControllerHints.is_pad_active()

func _pad_move_game(delta: int) -> bool:
	if _game_entries.is_empty():
		return true
	_pad_game_idx = int(posmod(_pad_game_idx + delta, _game_entries.size()))
	_refresh_pad_cursor()
	AudioManager.play("click")
	return true

func _pad_launch_selected_game() -> bool:
	if _game_entries.is_empty():
		return true
	var entry: Dictionary = _game_entries[_pad_game_idx]
	AudioManager.play("casino_bet")
	call(str(entry.get("fn", "")))
	return true

func _pad_show_selected_rules() -> bool:
	if _game_entries.is_empty():
		return true
	var entry: Dictionary = _game_entries[_pad_game_idx]
	var tid := str(entry.get("tutorial_id", ""))
	if tid.is_empty():
		return true
	AudioManager.play_ui_open()
	TutorialOverlay.force_show(tid, self)
	return true

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
		_balance_lbl.text = _tr("잔액: %s", "Balance: %s") % GameState.format_money(float(GameState.money))
	if _session_lbl:
		var delta: int = GameState.money - _entry_balance
		if delta > 0:
			_session_lbl.text = "+%s" % GameState.format_money(float(delta))
			_session_lbl.add_theme_color_override("font_color", Color("#3de87a"))
		elif delta < 0:
			_session_lbl.text = GameState.format_money(float(delta))
			_session_lbl.add_theme_color_override("font_color", Color("#e85d5d"))
		else:
			_session_lbl.text = _tr("±0원", "±KRW 0")
			_session_lbl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.6))

func _refresh_pad_cursor() -> void:
	var show_cursor := _should_show_pad_cursor()
	_pad_game_idx = clampi(_pad_game_idx, 0, maxi(_game_cards.size() - 1, 0))
	for i in range(_game_cards.size()):
		var panel := _game_cards[i] as PanelContainer
		var entry: Dictionary = _game_entries[i]
		var selected := show_cursor and i == _pad_game_idx
		_apply_game_card_style(panel, str(entry.get("bg", "#1a1a1a")), str(entry.get("accent", "#f0b429")), selected)
	if is_instance_valid(_pad_hint_lbl):
		_pad_hint_lbl.visible = show_cursor
		if show_cursor:
			_pad_hint_lbl.text = _tr(
				"[%s] 입장  [D-pad/%s/%s] 게임 선택  [%s] 규칙  [%s] 용어집  [%s] 나가기",
				"[%s] Enter  [D-pad/%s/%s] Select Game  [%s] Rules  [%s] Glossary  [%s] Exit"
			) % [
				ControllerHints.south(),
				ControllerHints.shoulder_l(),
				ControllerHints.shoulder_r(),
				ControllerHints.north(),
				ControllerHints.west(),
				ControllerHints.east(),
			]
	if show_cursor and is_instance_valid(_msg_lbl) and not _game_entries.is_empty():
		var entry: Dictionary = _game_entries[_pad_game_idx]
		_msg_lbl.text = _tr("선택: %s", "Selected: %s") % str(entry.get("name", ""))

func _apply_game_card_style(panel: PanelContainer, bg_hex: String, accent_hex: String, selected: bool) -> void:
	if not is_instance_valid(panel):
		return
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color.html(bg_hex).lightened(0.05) if selected else Color.html(bg_hex)
	ps.border_color = COLOR_GOLD if selected else Color.html(accent_hex)
	ps.set_border_width_all(4 if selected else 2)
	ps.corner_radius_top_left = 8
	ps.corner_radius_top_right = 8
	ps.corner_radius_bottom_left = 8
	ps.corner_radius_bottom_right = 8
	ps.shadow_color = Color(0, 0, 0, 0.46 if selected else 0.38)
	ps.shadow_size = 18 if selected else 10
	ps.shadow_offset = Vector2(0, 6 if selected else 4)
	panel.add_theme_stylebox_override("panel", ps)

# ── UI 빌드 ──────────────────────────────────────────────────────
func _build_ui() -> void:
	_game_cards = []
	_game_entries = []
	# 배경
	var bg_img := TextureRect.new()
	bg_img.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg_img.texture = CASINO_BG_TEX
	bg_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_img.modulate = Color(0.92, 0.88, 0.96, 1.0)
	bg_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg_img)

	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.025, 0.02, 0.05, 0.52)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	title_lbl.text = _tr("정선 카지노", "Jeongseon Casino")
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

	var exit_btn := _make_btn(_tr("나가기", "Exit"), "#6a6a6a")
	exit_btn.custom_minimum_size = Vector2(90, 44)
	exit_btn.pressed.connect(_close)
	hrow.add_child(exit_btn)

	# ── 메시지 ──
	_msg_lbl = Label.new()
	_msg_lbl.text = _tr("원하는 게임을 선택하세요", "Choose a game")
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

	_add_game_card(grid, "cards", _tr("바카라", "Baccarat"),
		_tr("뱅커 vs 플레이어\n6덱 슈 · 로드맵 · 커미션\n하우스엣지 1.06%~",
			"Banker vs Player\n6-deck shoe · roadmap · commission\nHouse edge from 1.06%"),
		"#1a0f20", "#7a3a8a", "_launch_baccarat", "baccarat", "B")

	_add_game_card(grid, "cards", _tr("블랙잭", "Blackjack"),
		_tr("기본전략 힌트 내장\n더블다운 · 스플릿\n하우스엣지 0.5%~",
			"Basic-strategy hint\nDouble down · split\nHouse edge from 0.5%"),
		"#1a2e1a", "#4aff4a", "_launch_blackjack", "blackjack", "21")

	_add_game_card(grid, "chip", _tr("슬롯머신", "Slot Machine"),
		_tr("777 잭팟 200배\n체리 조합으로 소액 당첨\n이론 RTP 90%",
			"777 jackpot 200x\nCherry hits pay small prizes\nTheoretical RTP 90%"),
		"#2e1a1a", "#ff4a4a", "_launch_slot", "slot", "777")

	_add_game_card(grid, "chip", _tr("룰렛", "Roulette"),
		_tr("유럽식 룰렛 0~36\n단일숫자 35:1 최고배당\n하우스엣지 2.70%",
			"European wheel 0-36\nStraight number pays 35:1\nHouse edge 2.70%"),
		"#1a2e2a", "#4affcc", "_launch_roulette", "roulette", "0-36")

	_add_game_card(grid, "chip", _tr("다이사이", "Dai Sai"),
		_tr("주사위 3개 합계 승부\nBIG·SMALL·페어·트리플\n최고배당 150:1",
			"Three dice, many calls\nBIG · SMALL · pairs · triples\nTop payout 150:1"),
		"#1f1a2e", "#b78cff", "_launch_daisai", "daisai", "3D6")

	_add_game_card(grid, "chip", _tr("빅휠", "Big Wheel"),
		_tr("바늘이 멈춘 구역 배당\n조커 45:1 최고배당\n가장 단순한 카지노 게임",
			"Bet where the pointer stops\nJoker pays 45:1\nThe simplest casino game"),
		"#2e2a1a", "#ffcc4a", "_launch_bigwheel", "bigwheel", "x45")

	# ── 안내 + 용어 버튼 ──
	var bottom_row := HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 12)
	var bottom_margin := MarginContainer.new()
	bottom_margin.add_theme_constant_override("margin_left", 24)
	bottom_margin.add_theme_constant_override("margin_right", 24)
	bottom_margin.add_theme_constant_override("margin_bottom", 12)
	bottom_margin.add_child(bottom_row)
	root.add_child(bottom_margin)
	var tip_lbl := Label.new()
	tip_lbl.text = _tr("도박은 중독성이 있습니다. 적정 한도 내에서 즐기세요.", "Gambling is addictive. Set limits before you play.")
	tip_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	tip_lbl.add_theme_font_size_override("font_size", 11)
	tip_lbl.add_theme_color_override("font_color", Color(0.5, 0.4, 0.4))
	tip_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tip_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_f(tip_lbl)
	bottom_row.add_child(tip_lbl)
	var gloss_btn := _make_btn(_tr("용어 설명", "Glossary"), "#1a1a2a")
	gloss_btn.custom_minimum_size = Vector2(100, 32)
	gloss_btn.pressed.connect(_show_casino_glossary)
	bottom_row.add_child(gloss_btn)

	_pad_hint_lbl = Label.new()
	_pad_hint_lbl.visible = false
	_pad_hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pad_hint_lbl.add_theme_font_size_override("font_size", 11)
	_pad_hint_lbl.add_theme_color_override("font_color", Color("#aeb6ca"))
	_f(_pad_hint_lbl, true)
	root.add_child(_pad_hint_lbl)

func _add_game_card(parent: Control, _icon_kind: String, name_kr: String,
		desc: String, bg_hex: String, accent_hex: String, fn: String,
		tutorial_id: String = "", mark: String = "") -> void:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = Vector2(0, 150)
	_apply_game_card_style(panel, bg_hex, accent_hex, false)
	parent.add_child(panel)
	_game_cards.append(panel)
	_game_entries.append({
		"name": name_kr,
		"fn": fn,
		"tutorial_id": tutorial_id,
		"bg": bg_hex,
		"accent": accent_hex,
	})

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	var mc := MarginContainer.new()
	mc.add_theme_constant_override("margin_left", 14)
	mc.add_theme_constant_override("margin_right", 14)
	mc.add_theme_constant_override("margin_top", 12)
	mc.add_theme_constant_override("margin_bottom", 12)
	mc.add_child(vbox)
	panel.add_child(mc)

	var art_frame := PanelContainer.new()
	art_frame.custom_minimum_size = Vector2(0, 48)
	var art_st := StyleBoxFlat.new()
	art_st.bg_color = Color(0, 0, 0, 0.32)
	art_st.border_color = Color.html(accent_hex).darkened(0.2)
	art_st.set_border_width_all(1)
	art_st.set_corner_radius_all(6)
	art_frame.add_theme_stylebox_override("panel", art_st)
	vbox.add_child(art_frame)

	var art := _make_game_card_art(tutorial_id, mark, Color.html(accent_hex))
	art_frame.add_child(art)

	var title_l := Label.new()
	title_l.text = name_kr
	title_l.add_theme_font_size_override("font_size", 18)
	title_l.add_theme_color_override("font_color", Color.html(accent_hex))
	title_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_f(title_l, true)
	vbox.add_child(title_l)

	var type_l := Label.new()
	type_l.text = _game_card_type(tutorial_id)
	type_l.add_theme_font_size_override("font_size", 9)
	type_l.add_theme_color_override("font_color", Color.html(accent_hex).lightened(0.20))
	type_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_f(type_l, true)
	vbox.add_child(type_l)

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
		help_btn.text = _tr("규칙", "Rules")
		help_btn.focus_mode = Control.FOCUS_NONE
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
		help_btn.pressed.connect(func():
			AudioManager.play("click")
			TutorialOverlay.force_show(tid, self)
		)
		btn_row.add_child(help_btn)

	var btn := Button.new()
	btn.text = _tr("입장", "Enter")
	btn.focus_mode = Control.FOCUS_NONE
	btn.add_theme_font_size_override("font_size", 13)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var bs := StyleBoxFlat.new()
	bs.bg_color = Color.html(accent_hex).darkened(0.05)
	bs.border_color = Color(1, 1, 1, 0.26)
	bs.set_border_width_all(1)
	bs.corner_radius_top_left     = 4
	bs.corner_radius_top_right    = 4
	bs.corner_radius_bottom_left  = 4
	bs.corner_radius_bottom_right = 4
	btn.add_theme_stylebox_override("normal", bs)
	var bsh := bs.duplicate() as StyleBoxFlat
	bsh.bg_color = Color.html(accent_hex).lightened(0.10)
	btn.add_theme_stylebox_override("hover", bsh)
	btn.add_theme_stylebox_override("pressed", bsh)
	btn.add_theme_color_override("font_color", Color(0.05, 0.05, 0.05))
	_f(btn, true)
	btn.pressed.connect(func():
		AudioManager.play("casino_bet")
		self.call(fn)
	)
	btn_row.add_child(btn)

func _game_card_type(game_id: String) -> String:
	match game_id:
		"baccarat", "blackjack":
			return "TABLE GAME"
		"slot":
			return "MACHINE"
		"roulette", "bigwheel":
			return "WHEEL"
		"daisai":
			return "DICE TABLE"
		_:
			return "CASINO"

func _make_game_card_art(game_id: String, mark: String, accent: Color) -> Control:
	var art := Control.new()
	art.custom_minimum_size = Vector2(0, 56)
	art.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.draw.connect(func(): _draw_game_card_art(art, game_id, mark, accent))
	return art

func _draw_game_card_art(ctrl: Control, game_id: String, mark: String, accent: Color) -> void:
	var sz: Vector2 = ctrl.size
	if sz.x <= 4.0 or sz.y <= 4.0:
		return
	var font: Font = _font_bold if _font_bold else ThemeDB.fallback_font
	ctrl.draw_rect(Rect2(Vector2.ZERO, sz), Color(0.0, 0.0, 0.0, 0.10), true)
	ctrl.draw_line(Vector2(10.0, sz.y - 7.0), Vector2(sz.x - 10.0, sz.y - 7.0), Color(accent.r, accent.g, accent.b, 0.18), 1.0)
	match game_id:
		"baccarat":
			_draw_baccarat_art(ctrl, sz, font, accent)
		"blackjack":
			_draw_blackjack_art(ctrl, sz, font, accent)
		"slot":
			_draw_slot_art(ctrl, sz, font, accent)
		"roulette":
			_draw_roulette_art(ctrl, sz, font, accent)
		"daisai":
			_draw_daisai_art(ctrl, sz, font, accent)
		"bigwheel":
			_draw_bigwheel_art(ctrl, sz, font, accent)
		_:
			ctrl.draw_string(font, Vector2(sz.x * 0.5 - 16.0, sz.y * 0.58), mark,
				HORIZONTAL_ALIGNMENT_CENTER, 32.0, 18, accent)

func _draw_baccarat_art(ctrl: Control, sz: Vector2, font: Font, accent: Color) -> void:
	var table := Rect2(Vector2(18.0, 10.0), Vector2(sz.x - 36.0, sz.y - 18.0))
	ctrl.draw_rect(table, Color("#061e12"), true)
	ctrl.draw_rect(table, Color(accent.r, accent.g, accent.b, 0.45), false, 1.2)
	ctrl.draw_string(font, Vector2(table.position.x + 14.0, table.position.y + 18.0), "PLAYER",
		HORIZONTAL_ALIGNMENT_LEFT, 80.0, 8, Color(1, 1, 1, 0.36))
	ctrl.draw_string(font, Vector2(table.end.x - 84.0, table.position.y + 18.0), "BANKER",
		HORIZONTAL_ALIGNMENT_LEFT, 80.0, 8, Color(1, 1, 1, 0.36))
	_draw_mini_card(ctrl, Vector2(sz.x * 0.38, 19.0), false, "8", Color("#f3f6fb"))
	_draw_mini_card(ctrl, Vector2(sz.x * 0.46, 17.0), true, "", accent)
	_draw_mini_card(ctrl, Vector2(sz.x * 0.56, 17.0), true, "", accent)
	_draw_mini_card(ctrl, Vector2(sz.x * 0.64, 19.0), false, "9", Color("#f3f6fb"))
	_draw_mini_chip(ctrl, Vector2(sz.x * 0.50, sz.y - 17.0), Color("#d33a35"))

func _draw_blackjack_art(ctrl: Control, sz: Vector2, font: Font, accent: Color) -> void:
	var table := Rect2(Vector2(18.0, 10.0), Vector2(sz.x - 36.0, sz.y - 18.0))
	ctrl.draw_rect(table, Color("#082513"), true)
	ctrl.draw_rect(table, Color(accent.r, accent.g, accent.b, 0.55), false, 1.4)
	ctrl.draw_line(table.position + Vector2(18.0, table.size.y - 8.0), table.end - Vector2(18.0, 8.0), Color(1, 1, 1, 0.14), 1.0)
	_draw_mini_card(ctrl, Vector2(sz.x * 0.40, 14.0), false, "A", Color("#f3f6fb"))
	_draw_mini_card(ctrl, Vector2(sz.x * 0.50, 18.0), false, "K", Color("#f3f6fb"))
	ctrl.draw_string(font, Vector2(sz.x * 0.62, 34.0), "21",
		HORIZONTAL_ALIGNMENT_LEFT, 60.0, 22, Color("#e8f6e8"))
	_draw_mini_chip(ctrl, Vector2(sz.x * 0.32, sz.y - 17.0), Color("#1e63d7"))

func _draw_slot_art(ctrl: Control, sz: Vector2, font: Font, accent: Color) -> void:
	var cab := Rect2(Vector2(sz.x * 0.24, 7.0), Vector2(sz.x * 0.52, sz.y - 12.0))
	ctrl.draw_rect(Rect2(cab.position + Vector2(0, 4), cab.size), Color(0, 0, 0, 0.35), true)
	ctrl.draw_rect(cab, Color("#210b0b"), true)
	ctrl.draw_rect(cab, Color(accent.r, accent.g, accent.b, 0.75), false, 2.0)
	var reel_w: float = cab.size.x / 3.0 - 6.0
	for i in range(3):
		var r := Rect2(cab.position + Vector2(7.0 + float(i) * (reel_w + 2.0), 12.0), Vector2(reel_w, 28.0))
		ctrl.draw_rect(r, Color("#f6f0df"), true)
		ctrl.draw_rect(r, Color("#351313"), false, 1.0)
		ctrl.draw_string(font, r.position + Vector2(0, 21.0), "7",
			HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 20, accent)
	ctrl.draw_circle(Vector2(cab.end.x + 13.0, cab.position.y + 14.0), 5.0, Color("#ffcf4f"))
	ctrl.draw_line(Vector2(cab.end.x + 13.0, cab.position.y + 18.0), Vector2(cab.end.x + 13.0, cab.position.y + 42.0), Color("#ddd6c5"), 2.0)

func _draw_roulette_art(ctrl: Control, sz: Vector2, font: Font, accent: Color) -> void:
	var center := Vector2(sz.x * 0.44, sz.y * 0.52)
	var radius: float = minf(sz.x, sz.y) * 0.38
	var colors := [Color("#087033"), Color("#951b1b"), Color("#111111")]
	for i in range(18):
		var a0: float = -PI * 0.5 + float(i) / 18.0 * TAU
		var a1: float = -PI * 0.5 + float(i + 1) / 18.0 * TAU
		var points := PackedVector2Array([center])
		for s in range(5):
			var a: float = lerpf(a0, a1, float(s) / 4.0)
			points.append(center + Vector2(cos(a), sin(a)) * radius)
		ctrl.draw_colored_polygon(points, colors[i % colors.size()])
	ctrl.draw_arc(center, radius, 0.0, TAU, 48, Color("#d1a34b"), 3.0)
	ctrl.draw_circle(center, radius * 0.38, Color("#071009"))
	ctrl.draw_circle(center, 7.0, accent)
	ctrl.draw_circle(center + Vector2(radius * 0.46, -radius * 0.32), 4.0, Color("#f5f2e8"))
	ctrl.draw_string(font, Vector2(sz.x * 0.62, sz.y * 0.58), "0-36",
		HORIZONTAL_ALIGNMENT_LEFT, 70.0, 16, Color("#e8f6f6"))

func _draw_daisai_art(ctrl: Control, sz: Vector2, font: Font, accent: Color) -> void:
	var tray := Rect2(Vector2(sz.x * 0.22, 9.0), Vector2(sz.x * 0.56, sz.y - 16.0))
	ctrl.draw_rect(Rect2(tray.position + Vector2(0, 4), tray.size), Color(0, 0, 0, 0.32), true)
	ctrl.draw_rect(tray, Color("#0a1110"), true)
	ctrl.draw_rect(tray, Color(accent.r, accent.g, accent.b, 0.66), false, 1.5)
	_draw_mini_die(ctrl, Vector2(sz.x * 0.34, 18.0), 22.0, 3)
	_draw_mini_die(ctrl, Vector2(sz.x * 0.47, 15.0), 22.0, 5)
	_draw_mini_die(ctrl, Vector2(sz.x * 0.60, 18.0), 22.0, 6)
	ctrl.draw_string(font, Vector2(sz.x * 0.72, 33.0), "BIG",
		HORIZONTAL_ALIGNMENT_LEFT, 48.0, 13, accent)

func _draw_bigwheel_art(ctrl: Control, sz: Vector2, font: Font, accent: Color) -> void:
	var center := Vector2(sz.x * 0.45, sz.y * 0.54)
	var radius: float = minf(sz.x, sz.y) * 0.39
	var cols := [Color("#e0a32d"), Color("#173f7a"), Color("#7b1f1f"), Color("#1d6b45"), Color("#3c245d")]
	for i in range(16):
		var a0: float = float(i) / 16.0 * TAU
		var a1: float = float(i + 1) / 16.0 * TAU
		var points := PackedVector2Array([center])
		for s in range(5):
			var a: float = lerpf(a0, a1, float(s) / 4.0)
			points.append(center + Vector2(cos(a), sin(a)) * radius)
		ctrl.draw_colored_polygon(points, cols[i % cols.size()])
	ctrl.draw_arc(center, radius, 0.0, TAU, 48, Color("#f0b429"), 3.0)
	ctrl.draw_circle(center, 8.0, Color("#0a0804"))
	var pointer := PackedVector2Array([
		center + Vector2(0.0, -radius - 7.0),
		center + Vector2(-8.0, -radius + 8.0),
		center + Vector2(8.0, -radius + 8.0),
	])
	ctrl.draw_colored_polygon(pointer, Color("#e74c3c"))
	ctrl.draw_string(font, Vector2(sz.x * 0.64, 34.0), "x45",
		HORIZONTAL_ALIGNMENT_LEFT, 60.0, 16, Color("#fff1b8"))

func _draw_mini_card(ctrl: Control, pos: Vector2, back: bool, label: String, accent: Color) -> void:
	var rect := Rect2(pos, Vector2(24.0, 34.0))
	ctrl.draw_rect(Rect2(rect.position + Vector2(2, 2), rect.size), Color(0, 0, 0, 0.28), true)
	ctrl.draw_rect(rect, Color("#13213a") if back else Color("#f4f0e8"), true)
	ctrl.draw_rect(rect, Color("#d8caa8") if back else Color("#d5c8b8"), false, 1.2)
	if back:
		ctrl.draw_line(rect.position + Vector2(5, 7), rect.end - Vector2(5, 7), Color(1, 1, 1, 0.24), 1.0)
		ctrl.draw_line(Vector2(rect.end.x - 5, rect.position.y + 7), Vector2(rect.position.x + 5, rect.end.y - 7), Color(1, 1, 1, 0.24), 1.0)
	else:
		var font: Font = _font_bold if _font_bold else ThemeDB.fallback_font
		ctrl.draw_string(font, rect.position + Vector2(0, 23), label,
			HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 16, Color("#1a1a22"))
		ctrl.draw_circle(rect.position + Vector2(rect.size.x * 0.5, rect.size.y - 7.0), 2.0, accent)

func _draw_mini_chip(ctrl: Control, center: Vector2, col: Color) -> void:
	ctrl.draw_circle(center + Vector2(0, 2), 9.0, Color(0, 0, 0, 0.25))
	ctrl.draw_circle(center, 9.0, col)
	ctrl.draw_arc(center, 7.0, 0.0, TAU, 24, Color("#f7f2df"), 2.0)
	ctrl.draw_circle(center, 4.0, col.darkened(0.18))

func _draw_mini_die(ctrl: Control, pos: Vector2, size: float, value: int) -> void:
	var rect := Rect2(pos, Vector2(size, size))
	ctrl.draw_rect(Rect2(rect.position + Vector2(2, 3), rect.size), Color(0, 0, 0, 0.26), true)
	ctrl.draw_rect(rect, Color("#f1f3f8"), true)
	ctrl.draw_rect(rect, Color("#a9b1c2"), false, 1.4)
	var pip := Color("#171923")
	var spots := {
		1: [Vector2(0.5, 0.5)],
		2: [Vector2(0.28, 0.28), Vector2(0.72, 0.72)],
		3: [Vector2(0.28, 0.28), Vector2(0.5, 0.5), Vector2(0.72, 0.72)],
		4: [Vector2(0.28, 0.28), Vector2(0.72, 0.28), Vector2(0.28, 0.72), Vector2(0.72, 0.72)],
		5: [Vector2(0.28, 0.28), Vector2(0.72, 0.28), Vector2(0.5, 0.5), Vector2(0.28, 0.72), Vector2(0.72, 0.72)],
		6: [Vector2(0.28, 0.24), Vector2(0.72, 0.24), Vector2(0.28, 0.5), Vector2(0.72, 0.5), Vector2(0.28, 0.76), Vector2(0.72, 0.76)]
	}
	for rel in spots.get(value, []):
		var rel_pos: Vector2 = rel
		ctrl.draw_circle(rect.position + Vector2(rel_pos.x * size, rel_pos.y * size), size * 0.07, pip)

# ── 게임 런처 ─────────────────────────────────────────────────
func _launch_baccarat() -> void:
	if not baccarat_table:
		_msg_lbl.text = _tr("바카라 테이블을 불러올 수 없습니다.", "Baccarat table is unavailable.")
		return
	visible = false
	baccarat_table.open()
	if not baccarat_table.closed.is_connected(_on_sub_game_closed):
		baccarat_table.closed.connect(_on_sub_game_closed)

func _launch_blackjack() -> void:
	if not blackjack_table:
		_msg_lbl.text = _tr("블랙잭 테이블을 불러올 수 없습니다.", "Blackjack table is unavailable.")
		return
	visible = false
	blackjack_table.open()
	if not blackjack_table.closed.is_connected(_on_sub_game_closed):
		blackjack_table.closed.connect(_on_sub_game_closed)

func _launch_slot() -> void:
	if not slot_machine_game:
		_msg_lbl.text = _tr("슬롯머신을 불러올 수 없습니다.", "Slot machine is unavailable.")
		return
	visible = false
	slot_machine_game.open()
	if not slot_machine_game.closed.is_connected(_on_sub_game_closed):
		slot_machine_game.closed.connect(_on_sub_game_closed)

func _launch_roulette() -> void:
	if not roulette_table:
		_msg_lbl.text = _tr("룰렛 테이블을 불러올 수 없습니다.", "Roulette table is unavailable.")
		return
	visible = false
	roulette_table.open()
	if not roulette_table.closed.is_connected(_on_sub_game_closed):
		roulette_table.closed.connect(_on_sub_game_closed)

func _launch_bigwheel() -> void:
	if not big_wheel_game:
		_msg_lbl.text = _tr("빅휠을 불러올 수 없습니다.", "Big Wheel is unavailable.")
		return
	visible = false
	big_wheel_game.open()
	if not big_wheel_game.closed.is_connected(_on_sub_game_closed):
		big_wheel_game.closed.connect(_on_sub_game_closed)

func _launch_daisai() -> void:
	if not dai_sai_table:
		_msg_lbl.text = _tr("다이사이 테이블을 불러올 수 없습니다.", "Dai Sai table is unavailable.")
		return
	visible = false
	dai_sai_table.open()
	if not dai_sai_table.closed.is_connected(_on_sub_game_closed):
		dai_sai_table.closed.connect(_on_sub_game_closed)

func _on_sub_game_closed() -> void:
	# 하위 게임이 닫히면 허브로 복귀
	visible = true
	_refresh_balance()

# ── 헬퍼 ──────────────────────────────────────────────────────
func _make_panel(col: Color) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.content_margin_left = 24
	sb.content_margin_right = 24
	sb.content_margin_top = 0
	sb.content_margin_bottom = 0
	p.add_theme_stylebox_override("panel", sb)
	return p

func _make_btn(text: String, hex: String) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color.html(hex)
	sb.corner_radius_top_left     = 4
	sb.corner_radius_top_right    = 4
	sb.corner_radius_bottom_left  = 4
	sb.corner_radius_bottom_right = 4
	var hover := sb.duplicate()
	hover.bg_color = Color.html(hex).lightened(0.14)
	var pressed := sb.duplicate()
	pressed.bg_color = Color.html(hex).darkened(0.12)
	var focus := sb.duplicate()
	focus.border_color = COLOR_GOLD
	focus.set_border_width_all(2)
	b.add_theme_stylebox_override("normal", sb)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_stylebox_override("focus", focus)
	b.pressed.connect(func(): AudioManager.play("click"))
	_f(b)
	return b

## A-4: 카지노 용어 설명 오버레이
func _show_casino_glossary() -> void:
	if is_instance_valid(_glossary_overlay):
		return
	var overlay := PanelContainer.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("#0d0d18")
	overlay.add_theme_stylebox_override("panel", sb)
	overlay.z_index = 50
	add_child(overlay)
	_glossary_overlay = overlay

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	var mc := MarginContainer.new()
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		mc.add_theme_constant_override(side, 32)
	mc.add_child(vbox)
	overlay.add_child(mc)

	var title_lbl := Label.new()
	title_lbl.text = _tr("카지노 용어 설명", "Casino Glossary")
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", Color("#f0b429"))
	_f(title_lbl, true)
	vbox.add_child(title_lbl)

	var TERMS := [
		[_tr("하우스엣지", "House Edge"), _tr("카지노가 장기적으로 가져가는 수익 비율. 바카라 뱅커 1.06%, 블랙잭 기본전략 0.5%, 룰렛 2.70%. 오래 할수록 이 비율만큼 잃는 게 수학적 법칙이다.", "The long-term percentage the casino keeps. Banker baccarat is about 1.06%, basic-strategy blackjack about 0.5%, roulette 2.70%. The longer you play, the more the math asserts itself.")],
		[_tr("RTP", "RTP"), _tr("Return To Player. 100만원 투입 시 장기적으로 돌아오는 금액 비율. 슬롯 RTP 90%면 이론상 90만원 반환. 단기에선 크게 벗어날 수 있다.", "Return To Player. If a slot has 90% RTP, KRW 1,000,000 wagered returns KRW 900,000 in theory over the long run. Short-term results can swing wildly.")],
		[_tr("배당률", "Payout"), _tr("배팅 금액 대비 당첨 시 받는 배수. 룰렛 단일 숫자 35:1, 빅휠 조커 45:1, 블랙잭 내추럴 1.5:1.", "The multiplier paid when a bet wins. Roulette straight number pays 35:1, Big Wheel joker 45:1, blackjack natural 1.5:1.")],
		[_tr("내추럴 (바카라)", "Natural (Baccarat)"), _tr("처음 두 장의 합이 8 또는 9인 경우. 추가 카드 없이 즉시 결판. 뱅커·플레이어 모두 내추럴이면 무승부.", "A first two-card total of 8 or 9. No more cards are drawn. If both Banker and Player have naturals, compare totals or tie.")],
		[_tr("커미션 (바카라)", "Commission (Baccarat)"), _tr("뱅커 승리 시 카지노가 가져가는 수수료, 통상 5%. 뱅커 배당률이 0.95:1인 이유.", "The fee the casino takes on Banker wins, usually 5%. This is why Banker pays 0.95:1 instead of even money.")],
		[_tr("더블다운 (블랙잭)", "Double Down (Blackjack)"), _tr("첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.", "After the first two cards, double your bet and take exactly one more card. Often strong on totals of 10 or 11.")],
		[_tr("다이사이", "Dai Sai"), _tr("세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.", "A casino dice game using three dice. BIG/SMALL is easy to understand; triples and exact totals pay more because they are much rarer.")],
		[_tr("빅/스몰 (다이사이)", "BIG/SMALL (Dai Sai)"), _tr("주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.", "Totals 11-17 are BIG, 4-10 are SMALL. But if all three dice match, BIG/SMALL bets lose.")],
		[_tr("마틴게일", "Martingale"), _tr("질 때마다 배팅액을 2배로 늘리는 전략. 이론상 한 번 이기면 원금 회복. 자금이 바닥나거나 한도에 걸리면 전액 손실.", "A strategy that doubles the bet after each loss. One win recovers the sequence in theory, but table limits or a cash shortage can wipe you out.")],
	]
	for pair in TERMS:
		var term_vbox := VBoxContainer.new()
		term_vbox.add_theme_constant_override("separation", 2)
		vbox.add_child(term_vbox)
		var term_lbl := Label.new()
		term_lbl.text = pair[0]
		term_lbl.add_theme_font_size_override("font_size", 13)
		term_lbl.add_theme_color_override("font_color", Color("#f0b429"))
		_f(term_lbl, true)
		term_vbox.add_child(term_lbl)
		var def_lbl := Label.new()
		def_lbl.text = pair[1]
		def_lbl.add_theme_font_size_override("font_size", 12)
		def_lbl.add_theme_color_override("font_color", Color("#8892a4"))
		def_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_f(def_lbl)
		term_vbox.add_child(def_lbl)

	var close_btn := _make_btn(_tr("카지노 허브로", "Back to Casino"), "#1a1a2e")
	close_btn.pressed.connect(func():
		overlay.queue_free()
		_glossary_overlay = null)
	vbox.add_child(close_btn)


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
