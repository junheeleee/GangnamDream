extends Control

var investment_system: Node
var job_system: Node
var relationship_system: Node
var inventory_system: Node

var top_labels: Dictionary = {}
var stat_labels: Dictionary = {}
var rival_label: Label
var event_title: Label
var event_body: RichTextLabel
var choice_box: VBoxContainer
var news_box: VBoxContainer
var ticker_rtl: RichTextLabel
var relationship_box: VBoxContainer
var inventory_box: VBoxContainer
var log_box: RichTextLabel
var modal_layer: ColorRect
var modal_scroll: ScrollContainer
var modal_panel: PanelContainer
var modal_body: VBoxContainer
var modal_title_label: Label
var next_button: Button
var shop_button: Button
var _toast_container: VBoxContainer
var event_bg: TextureRect
var character_portrait: TextureRect
var info_panel: Control
var info_tabs: TabContainer
var player_name_label: Label
var title_label: Label

const BG_PATHS = {
	"gosiwon":   "res://assets/backgrounds/goshiwon_room.png",
	"oneroom":   "res://assets/backgrounds/oneroom_apartment.png",
	"apartment": "res://assets/backgrounds/gangnam_apartment.png",
}
const BG_DEFAULT   = "res://assets/backgrounds/seoul_rainy_street.png"
const BG_OFFICE    = "res://assets/backgrounds/office_desk.png"
const BG_SUBWAY    = "res://assets/backgrounds/seoul_subway.png"

const PORTRAIT_NEUTRAL    = "res://assets/characters/main_character_neutral_goshiwon.png"
const PORTRAIT_TIRED      = "res://assets/characters/main_character_tired.png"
const PORTRAIT_DETERMINED = "res://assets/characters/main_character_determined.png"
const PORTRAIT_HAPPY      = "res://assets/characters/main_character_happy.png"

var current_event: Dictionary = {}
var prev_prices: Dictionary = {}
var pending_result_text: String = ""
var turn_action_log: Array = []
var _pending_month_summary: bool = false

func _ready():
	_init_systems()
	_build_ui()
	_connect_signals()
	if GameState.action_log.is_empty():
		GameState.new_game()
	investment_system.initialize()
	_begin_month()
	_refresh_all()
	BGMPlayer.start()
	SceneTransition.fade_in()
	# 첫 게임에만 튜토리얼 팝업 표시
	if not GameState.flags.get("tutorial_shown", false):
		GameState.flags["tutorial_shown"] = true
		_show_tutorial_intro()

func _init_systems():
	investment_system = load("res://systems/InvestmentSystem.gd").new()
	job_system = load("res://systems/JobSystem.gd").new()
	relationship_system = load("res://systems/RelationshipSystem.gd").new()
	inventory_system = load("res://systems/InventorySystem.gd").new()
	add_child(investment_system)
	add_child(job_system)
	add_child(relationship_system)
	add_child(inventory_system)

func _connect_signals():
	GameState.stats_changed.connect(_refresh_all)
	GameState.game_over.connect(_show_ending)
	RivalSystem.rival_message.connect(_on_rival_message)
	job_system.promoted.connect(_on_promoted)
	GameState.stat_threshold_crossed.connect(_on_stat_threshold_crossed)

func _build_ui():
	# ── 1. 최하단: 단색 배경 ──
	var bg = ColorRect.new()
	bg.color = Color("#0c0c10")
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# ── 2. 전체화면 배경 이미지 (이벤트별로 전환됨) ──
	event_bg = TextureRect.new()
	event_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	event_bg.stretch_mode = TextureRect.STRETCH_SCALE
	event_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	event_bg.modulate = Color(1, 1, 1, 0.25)
	event_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(event_bg)

	# ── 3. 어두운 오버레이 ──
	var dark_overlay = ColorRect.new()
	dark_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	dark_overlay.color = Color(0.05, 0.05, 0.07, 0.76)
	dark_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dark_overlay)

	# ── 4. 메인 레이아웃 ──
	var root = VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	add_child(root)

	_build_top_bar(root)

	var main = HBoxContainer.new()
	main.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_theme_constant_override("separation", 0)
	root.add_child(main)

	_build_portrait_panel(main)
	_build_story_panel(main)

	_build_bottom_bar(root)

	# ── 5. 우측 슬라이드 정보 패널 (기본 숨김) ──
	_build_info_panel()

	_build_modal()
	_build_toast_layer()

func _build_top_bar(parent):
	var panel = _panel("#0d0d14", "#1a1a28")
	panel.custom_minimum_size = Vector2(0, 48)
	parent.add_child(panel)
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 14)
	panel.add_child(row)

	var title = _label("강남드림", 17, "#5b9cf6")
	title.custom_minimum_size = Vector2(88, 0)
	row.add_child(title)

	row.add_child(_label("│", 13, "#2a2a3a"))

	var date_lbl = _label("", 13, "#8892a4")
	top_labels["date"] = date_lbl
	row.add_child(date_lbl)

	var ap_lbl = _label("", 15, "#f0b429")
	ap_lbl.custom_minimum_size = Vector2(90, 0)
	top_labels["ap"] = ap_lbl
	row.add_child(ap_lbl)

	var money_lbl = _label("", 13, "#00c896")
	money_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	money_lbl.clip_text = false
	top_labels["money"] = money_lbl
	row.add_child(money_lbl)

	var info_btn = _small_button("📋 정보", "#1e2a3a")
	info_btn.custom_minimum_size = Vector2(82, 36)
	info_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	info_btn.pressed.connect(_toggle_info_panel)
	row.add_child(info_btn)

	var save_btn = _small_button("💾", "#1e2a3a")
	save_btn.custom_minimum_size = Vector2(40, 36)
	save_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	save_btn.pressed.connect(Callable(self, "_on_save_pressed"))
	row.add_child(save_btn)

	var menu_btn = _small_button("≡", "#1e2a3a")
	menu_btn.custom_minimum_size = Vector2(40, 36)
	menu_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	menu_btn.pressed.connect(_open_system_menu)
	row.add_child(menu_btn)

func _build_portrait_panel(parent):
	# 왼쪽 고정 초상화 패널 (180px 너비, 전체 높이)
	var panel = _panel("#0d0d14", "#1a1a28")
	panel.custom_minimum_size = Vector2(180, 0)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	panel.add_child(vbox)

	# 초상화 — 세로 가득 채움
	character_portrait = TextureRect.new()
	character_portrait.size_flags_vertical = Control.SIZE_EXPAND_FILL
	character_portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	character_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	character_portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	var portrait_tex = load(PORTRAIT_NEUTRAL)
	if portrait_tex:
		character_portrait.texture = portrait_tex
	vbox.add_child(character_portrait)

	# 이름/직업 영역 — 초상화 아래 고정 높이
	var name_panel = PanelContainer.new()
	var name_style = StyleBoxFlat.new()
	name_style.bg_color = Color(0, 0, 0, 0.72)
	name_style.set_border_width_all(0)
	name_style.content_margin_top = 7
	name_style.content_margin_bottom = 7
	name_style.content_margin_left = 8
	name_style.content_margin_right = 8
	name_panel.add_theme_stylebox_override("panel", name_style)
	vbox.add_child(name_panel)

	player_name_label = _label("", 12, "#8892a4")
	player_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	player_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	player_name_label.clip_text = false
	name_panel.add_child(player_name_label)

	title_label = _label("서울 상경 초보", 11, "#f0b429")
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.clip_text = false
	vbox.add_child(title_label)

func _build_story_panel(parent):
	# 스토리 메인 영역 — 이벤트 제목/본문/선택지
	var container = Control.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(container)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 20)
	container.add_child(margin)

	var layout = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 16)
	margin.add_child(layout)

	event_title = _label("이벤트 대기 중", 30, "#e8eaf0")
	event_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_title.clip_text = false
	layout.add_child(event_title)

	event_body = RichTextLabel.new()
	event_body.bbcode_enabled = false
	event_body.fit_content = false
	event_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	event_body.add_theme_font_size_override("normal_font_size", 18)
	event_body.add_theme_color_override("default_color", Color("#c8d0df"))
	layout.add_child(event_body)

	choice_box = VBoxContainer.new()
	choice_box.add_theme_constant_override("separation", 10)
	layout.add_child(choice_box)

func _build_info_panel():
	# ── 우측 슬라이드 통합 정보 패널 (340px, 기본 숨김) ──
	info_panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.08, 0.97)
	style.border_color = Color("#252535")
	style.set_border_width_all(0)
	style.border_width_left = 1
	style.content_margin_left = 0
	style.content_margin_right = 0
	style.content_margin_top = 0
	style.content_margin_bottom = 0
	info_panel.add_theme_stylebox_override("panel", style)
	info_panel.set_anchor(SIDE_LEFT, 1.0)
	info_panel.set_anchor(SIDE_TOP, 0.0)
	info_panel.set_anchor(SIDE_RIGHT, 1.0)
	info_panel.set_anchor(SIDE_BOTTOM, 1.0)
	info_panel.offset_left = -340
	info_panel.offset_top = 48
	info_panel.offset_right = 0
	info_panel.offset_bottom = 0
	info_panel.visible = false
	add_child(info_panel)

	# ── VBox로 감싸서 헤더(닫기 버튼) + TabContainer 배치 ──
	var panel_vbox = VBoxContainer.new()
	panel_vbox.add_theme_constant_override("separation", 0)
	info_panel.add_child(panel_vbox)

	# 헤더: 패널 타이틀 + 닫기(X) 버튼
	var panel_header = HBoxContainer.new()
	panel_header.custom_minimum_size = Vector2(0, 36)
	var ph_style = StyleBoxFlat.new()
	ph_style.bg_color = Color("#0a0a12")
	ph_style.border_color = Color("#1e1e2a")
	ph_style.border_width_bottom = 1
	ph_style.content_margin_left = 10
	ph_style.content_margin_right = 6
	ph_style.content_margin_top = 4
	ph_style.content_margin_bottom = 4
	panel_header.add_theme_stylebox_override("panel", ph_style)
	panel_vbox.add_child(panel_header)

	var panel_title = _label("📋 정보", 13, "#8892a4")
	panel_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_header.add_child(panel_title)

	var panel_close = _small_button("✕", "#2a2a3a")
	panel_close.custom_minimum_size = Vector2(32, 28)
	panel_close.pressed.connect(_toggle_info_panel)
	panel_header.add_child(panel_close)

	# ── TabContainer: 스탯 / 시황 / 관계 ──
	info_tabs = TabContainer.new()
	var tabs = info_tabs
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var tab_sel = StyleBoxFlat.new()
	tab_sel.bg_color = Color("#13131f")
	tab_sel.border_color = Color("#5b9cf6")
	tab_sel.border_width_bottom = 2
	tab_sel.content_margin_left = 10
	tab_sel.content_margin_right = 10
	tab_sel.content_margin_top = 6
	tab_sel.content_margin_bottom = 6
	var tab_unsel = StyleBoxFlat.new()
	tab_unsel.bg_color = Color("#0a0a12")
	tab_unsel.border_color = Color("#1e1e2a")
	tab_unsel.set_border_width_all(0)
	tab_unsel.content_margin_left = 10
	tab_unsel.content_margin_right = 10
	tab_unsel.content_margin_top = 6
	tab_unsel.content_margin_bottom = 6
	var tab_panel_style = StyleBoxFlat.new()
	tab_panel_style.bg_color = Color("#0c0c14")
	tab_panel_style.set_border_width_all(0)
	tabs.add_theme_stylebox_override("tab_selected", tab_sel)
	tabs.add_theme_stylebox_override("tab_unselected", tab_unsel)
	tabs.add_theme_stylebox_override("panel", tab_panel_style)
	tabs.add_theme_color_override("font_selected_color", Color("#e8eaf0"))
	tabs.add_theme_color_override("font_unselected_color", Color("#5a6075"))
	tabs.add_theme_font_size_override("font_size", 13)
	tabs.tab_changed.connect(func(idx): GameState.flags["_last_info_tab"] = idx)
	panel_vbox.add_child(tabs)

	# ── Tab 0: 📊 스탯 ──
	var stat_scroll = ScrollContainer.new()
	stat_scroll.name = "📊 스탯"
	stat_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tabs.add_child(stat_scroll)
	var stat_box = VBoxContainer.new()
	stat_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stat_box.add_theme_constant_override("separation", 5)
	var stat_margin = MarginContainer.new()
	stat_margin.add_theme_constant_override("margin_left", 14)
	stat_margin.add_theme_constant_override("margin_right", 14)
	stat_margin.add_theme_constant_override("margin_top", 10)
	stat_margin.add_theme_constant_override("margin_bottom", 10)
	stat_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stat_margin.add_child(stat_box)
	stat_scroll.add_child(stat_margin)

	# ── 배경 / 트레이트 표시 ──
	var bg_trait_row = HBoxContainer.new()
	bg_trait_row.add_theme_constant_override("separation", 6)
	stat_box.add_child(bg_trait_row)
	var bg_lbl = _label("배경", 10, "#5a6075")
	bg_lbl.custom_minimum_size = Vector2(28, 0)
	bg_trait_row.add_child(bg_lbl)
	var bg_map = {"지방_상경": "지방 상경", "명문대_중퇴": "명문대 중퇴", "금수저": "금수저"}
	var bg_name = bg_map.get(GameState.player_background, GameState.player_background)
	var bg_val = _label(bg_name, 10, "#a0aec0")
	bg_val.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bg_trait_row.add_child(bg_val)
	var trait_lbl = _label("트레이트", 10, "#5a6075")
	bg_trait_row.add_child(trait_lbl)
	var trait_val = _label(GameState.current_trait, 10, "#f6c90e")
	bg_trait_row.add_child(trait_val)

	var sep_line = HSeparator.new()
	sep_line.modulate = Color("#2a2a3a")
	stat_box.add_child(sep_line)

	stat_box.add_child(_label("PLAYER", 13, "#5b9cf6"))
	for key in ["housing", "job", "health", "mental", "stress", "intelligence", "social_skill", "appearance", "investment_skill", "luck", "reputation", "asset"]:
		var stat_row = HBoxContainer.new()
		stat_box.add_child(stat_row)
		var name_label = _label(_stat_name(key), 12, "#5a6075")
		name_label.custom_minimum_size = Vector2(70, 0)
		stat_row.add_child(name_label)
		var value = _label("", 12, "#e8eaf0")
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stat_labels[key] = value
		stat_row.add_child(value)

	stat_box.add_child(_label("RIVAL", 13, "#ff4444"))
	rival_label = _label("—", 11, "#5a6075")
	rival_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rival_label.clip_text = false
	rival_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stat_box.add_child(rival_label)

	stat_box.add_child(_label("LOG", 13, "#5b9cf6"))
	log_box = RichTextLabel.new()
	log_box.bbcode_enabled = true
	log_box.fit_content = true
	log_box.add_theme_font_size_override("normal_font_size", 11)
	log_box.add_theme_color_override("default_color", Color("#5a6075"))
	stat_box.add_child(log_box)

	# ── Tab 1: 📰 시황 ──
	var news_scroll = ScrollContainer.new()
	news_scroll.name = "📰 시황"
	news_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tabs.add_child(news_scroll)
	var news_outer = VBoxContainer.new()
	news_outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	news_outer.add_theme_constant_override("separation", 6)
	var news_margin = MarginContainer.new()
	news_margin.add_theme_constant_override("margin_left", 14)
	news_margin.add_theme_constant_override("margin_right", 14)
	news_margin.add_theme_constant_override("margin_top", 10)
	news_margin.add_theme_constant_override("margin_bottom", 10)
	news_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	news_margin.add_child(news_outer)
	news_scroll.add_child(news_margin)

	news_box = VBoxContainer.new()
	news_box.add_theme_constant_override("separation", 4)
	news_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	news_outer.add_child(news_box)

	ticker_rtl = RichTextLabel.new()
	ticker_rtl.bbcode_enabled = true
	ticker_rtl.fit_content = true
	ticker_rtl.scroll_active = false
	ticker_rtl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ticker_rtl.add_theme_font_size_override("normal_font_size", 12)
	ticker_rtl.add_theme_color_override("default_color", Color("#8892a4"))
	news_outer.add_child(ticker_rtl)

	# ── Tab 2: 👥 관계 ──
	var social_scroll = ScrollContainer.new()
	social_scroll.name = "👥 관계"
	social_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tabs.add_child(social_scroll)
	var social_outer = VBoxContainer.new()
	social_outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	social_outer.add_theme_constant_override("separation", 6)
	var social_margin = MarginContainer.new()
	social_margin.add_theme_constant_override("margin_left", 14)
	social_margin.add_theme_constant_override("margin_right", 14)
	social_margin.add_theme_constant_override("margin_top", 10)
	social_margin.add_theme_constant_override("margin_bottom", 10)
	social_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	social_margin.add_child(social_outer)
	social_scroll.add_child(social_margin)

	relationship_box = VBoxContainer.new()
	relationship_box.add_theme_constant_override("separation", 4)
	relationship_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	social_outer.add_child(relationship_box)

	inventory_box = VBoxContainer.new()
	inventory_box.add_theme_constant_override("separation", 4)
	inventory_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	social_outer.add_child(inventory_box)

func _toggle_info_panel():
	if info_panel:
		info_panel.visible = not info_panel.visible
		if info_panel.visible and info_tabs:
			var last = GameState.flags.get("_last_info_tab", 0)
			info_tabs.current_tab = clampi(last, 0, info_tabs.get_tab_count() - 1)

func _build_bottom_bar(parent):
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 180)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 10)
	parent.add_child(margin)
	var row = HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 48)
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)
	next_button = _button("다음 달 ▶", "#1f4f8a")
	next_button.pressed.connect(_on_next_month)
	row.add_child(next_button)
	shop_button = _button("🛍 상점", "#4a1d7a")
	shop_button.pressed.connect(_open_shop)
	row.add_child(shop_button)
	var title_btn = _button("🏆 도감", "#1a3a2a")
	title_btn.pressed.connect(_open_title_collection)
	row.add_child(title_btn)

func _build_modal():
	modal_layer = ColorRect.new()
	modal_layer.color = Color(0, 0, 0, 0.70)
	modal_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	modal_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_layer.visible = false
	add_child(modal_layer)

	modal_panel = _panel("#13131a", "#252535")
	modal_panel.custom_minimum_size = Vector2(640, 560)
	modal_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	# 명시적 anchor로 화면 정중앙 고정
	modal_panel.anchor_left   = 0.5
	modal_panel.anchor_right  = 0.5
	modal_panel.anchor_top    = 0.5
	modal_panel.anchor_bottom = 0.5
	modal_panel.offset_left   = -320
	modal_panel.offset_right  =  320
	modal_panel.offset_top    = -280
	modal_panel.offset_bottom =  280
	modal_layer.add_child(modal_panel)
	var panel = modal_panel

	var outer = VBoxContainer.new()
	outer.add_theme_constant_override("separation", 8)
	panel.add_child(outer)

	# Header row with title + close button
	var header = HBoxContainer.new()
	outer.add_child(header)
	modal_title_label = _label("", 22, "#e8eaf0")
	modal_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(modal_title_label)
	var close_x = _small_button("✕", "#da3633")
	close_x.custom_minimum_size = Vector2(36, 36)
	close_x.pressed.connect(_close_modal)
	header.add_child(close_x)

	# Scrollable content area
	modal_scroll = ScrollContainer.new()
	modal_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	modal_scroll.custom_minimum_size = Vector2(0, 420)
	outer.add_child(modal_scroll)

	modal_body = VBoxContainer.new()
	modal_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	modal_body.add_theme_constant_override("separation", 8)
	modal_scroll.add_child(modal_body)

func _build_toast_layer():
	_toast_container = VBoxContainer.new()
	_toast_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_container.add_theme_constant_override("separation", 6)
	_toast_container.set_anchor(SIDE_LEFT, 1.0)
	_toast_container.set_anchor(SIDE_TOP, 0.0)
	_toast_container.set_anchor(SIDE_RIGHT, 1.0)
	_toast_container.set_anchor(SIDE_BOTTOM, 1.0)
	_toast_container.offset_left = -280
	_toast_container.offset_top = 70
	_toast_container.offset_right = -10
	_toast_container.offset_bottom = -70
	add_child(_toast_container)

func _show_toast(message: String, color: Color = Color("#8892a4")):
	var toast = load("res://ui_components/NotificationToast.gd").new()
	_toast_container.add_child(toast)
	toast.show_message(message, color)

func _begin_month():
	GameState.restore_ap()
	turn_action_log.clear()
	prev_prices = GameState.market_prices.duplicate()
	# ── 로그라이크: 월별 위기/호재 롤 (튜토리얼 이후) ──
	if GameState.turn > 3:
		var crisis = _roll_monthly_crisis()
		if not crisis.is_empty():
			_apply_monthly_event(crisis)
	if GameState.news_log.is_empty() or GameState.turn > 1:
		var news = NewsManager.generate_monthly_news()
		investment_system.process_month(news)
	# ── 스토리 이벤트 트리거 ─────────────────────────
	# 턴 1: 프롤로그 (배경별 맞춤 story_arrival → story_pressure 체인)
	if GameState.turn == 1 and GameState.tutorial_step >= 3:
		var arrival_id = "story_arrival"
		match GameState.player_background:
			"명문대_중퇴": arrival_id = "story_arrival_elite"
			"금수저":      arrival_id = "story_arrival_rich"
		# 배경별 이벤트가 없으면 기본으로 폴백
		if DataRegistry.find_event(arrival_id).is_empty():
			arrival_id = "story_arrival"
		EventManager.trigger_event_by_id(arrival_id)
		current_event = EventManager.get_next_event()
		_render_event()
		return
	# 마일스톤 이벤트
	_check_story_triggers()
	EventManager.process_month_events()
	current_event = EventManager.get_next_event()
	_render_event()

func _check_story_triggers():
	var t = GameState.turn
	var f = GameState.flags
	# 첫 출근 (직업 생긴 직후 턴)
	if not GameState.current_job.is_empty() and not f.get("story_first_workday_seen", false):
		EventManager.trigger_event_by_id("story_first_workday")
		return
	# 첫 월급 감정 이벤트
	if f.get("has_received_paycheck", false) and not f.get("story_first_paycheck_seen", false):
		EventManager.trigger_event_by_id("story_first_paycheck_feel")
		return
	# 첫 저축 마일스톤 — 통장 300만원 돌파
	if GameState.money >= 3_000_000 and not f.get("story_first_savings_seen", false):
		EventManager.trigger_event_by_id("story_first_savings_milestone")
		return
	# 반년
	if t == 6 and not f.get("story_six_months_seen", false):
		EventManager.trigger_event_by_id("story_six_months")
	# 1년
	elif t == 12 and not f.get("story_one_year_seen", false):
		EventManager.trigger_event_by_id("story_one_year")
	# 1년 반
	elif t == 18 and not f.get("story_one_half_year_seen", false):
		EventManager.trigger_event_by_id("story_one_half_year")
	# 2년
	elif t == 24 and not f.get("story_two_year_seen", false):
		EventManager.trigger_event_by_id("story_two_year")
	# 3년
	elif t == 36 and not f.get("story_three_year_seen", false):
		EventManager.trigger_event_by_id("story_three_year")
	# 4년
	elif t == 48 and not f.get("story_four_year_seen", false):
		EventManager.trigger_event_by_id("story_four_year")
	# 5년
	elif t == 60 and not f.get("story_five_year_seen", false):
		EventManager.trigger_event_by_id("story_five_year")
	# 10년 (30대 진입)
	elif t == 120 and not f.get("30s_reflection_done", false):
		EventManager.trigger_event_by_id("midlife_30s_reflection")
	# 35세
	elif t == 180 and not f.get("age_35_reflected", false):
		EventManager.trigger_event_by_id("age_35_checkpoint")
	# 40세
	elif t == 240 and not f.get("age_40_reflected", false):
		EventManager.trigger_event_by_id("age_40_threshold")
	# 은퇴 준비 (45세)
	elif t == 300 and not f.get("retirement_strategy_set", false):
		EventManager.trigger_event_by_id("pre_retirement_decision")
	# 50세
	elif t == 360 and not f.get("age_50_reflected", false):
		EventManager.trigger_event_by_id("age_50_milestone")
	# 55세
	elif t == 420 and not f.get("age_55_reflected", false):
		EventManager.trigger_event_by_id("age_55_milestone")
	# 60세
	elif t == 480 and not f.get("age_60_reflected", false):
		EventManager.trigger_event_by_id("age_60_milestone")

# ── 로그라이크: 월별 위기/호재 시스템 ─────────────────────────────────

func _roll_monthly_crisis() -> Dictionary:
	var roll = randf()
	# 6% 호재 달
	if roll < 0.06:
		var bonus_type = randi() % 3
		match bonus_type:
			0:
				return {"type": "bonus_ap", "title": "⚡ 탄력 받은 달",
					"desc": "컨디션이 최고다. 이번 달 행동력 +1 보너스!", "color": "#00c896"}
			1:
				var amt = float(randi_range(200_000, 600_000))
				return {"type": "bonus_income", "title": "💸 뜻밖의 수입",
					"desc": "예상치 못한 %s이 들어왔다." % GameState.format_money(amt), "amount": amt, "color": "#00c896"}
			_:
				return {"type": "market_boom", "title": "📈 시장 급등 신호",
					"desc": "이번 달 시장 전반에 강세 신호가 감지됐다. 투자 기회!", "color": "#3fb950"}
	# 18% 위기 달
	if roll < 0.24:
		var crisis_type = randf()
		if crisis_type < 0.30:
			var amt = float(randi_range(150_000, 700_000))
			return {"type": "emergency_expense", "title": "🚨 긴급 지출",
				"desc": "갑작스럽게 %s이 빠져나갔다." % GameState.format_money(amt), "amount": amt, "color": "#ff4444"}
		elif crisis_type < 0.55:
			return {"type": "ap_penalty", "title": "😩 여유 없는 달",
				"desc": "갑작스러운 사정으로 이번 달 행동력이 1 줄어든다.", "color": "#f0b429"}
		elif crisis_type < 0.75:
			return {"type": "market_shock", "title": "📉 시장 충격",
				"desc": "외부 충격으로 시장이 흔들렸다. 이번 달 투자 위험 대폭 상승.", "color": "#ff4444"}
		else:
			var hp_dmg = randi_range(8, 18)
			return {"type": "health_crisis", "title": "🏥 건강 위기",
				"desc": "갑자기 몸이 안 좋아졌다. 건강 -%d, 스트레스 +12." % hp_dmg, "hp": hp_dmg, "color": "#ef4444"}
	return {}

func _apply_monthly_event(ev: Dictionary):
	var t = ev.get("type", "")
	var title = ev.get("title", "")
	var desc = ev.get("desc", "")
	var color = Color(ev.get("color", "#8892a4"))
	match t:
		"bonus_ap":
			GameState.action_points = min(GameState.action_points + 1, GameState.max_action_points + 1)
			_show_toast("%s — %s" % [title, desc], color)
			GameState.add_log(desc, "system")
		"bonus_income":
			var amt = float(ev.get("amount", 300_000.0))
			GameState.add_money(amt)
			_show_toast("%s — %s" % [title, desc], color)
			GameState.add_log(desc, "system")
			AudioManager.play("money_gain")
		"market_boom":
			investment_system.apply_market_shock()  # opposite: boost
			GameState.market_context["fear_greed"] = min(90, int(GameState.market_context.get("fear_greed", 50)) + 20)
			GameState.market_context["cycle"] = "bull"
			GameState.market_context["crash_risk"] = 0.02
			_show_toast("%s — %s" % [title, desc], color)
			GameState.add_log(desc, "market")
		"emergency_expense":
			var amt = float(ev.get("amount", 300_000.0))
			GameState.add_money(-amt)
			GameState.modify_hidden_stat("stress", 10)
			_show_toast("%s — %s" % [title, desc], color)
			GameState.add_log(desc, "system")
		"ap_penalty":
			GameState.action_points = max(1, GameState.action_points - 1)
			_show_toast("%s — %s" % [title, desc], color)
			GameState.add_log(desc, "system")
		"market_shock":
			investment_system.apply_market_shock()
			_show_toast("%s — %s" % [title, desc], color)
			GameState.add_log(desc, "market")
		"health_crisis":
			var hp_dmg = int(ev.get("hp", 10))
			GameState.modify_stat("health", -hp_dmg)
			GameState.modify_hidden_stat("stress", 12)
			_show_toast("%s — %s" % [title, desc], color)
			GameState.add_log(desc, "system")

# ── RPG: 스탯 임계값 해금 알림 ──────────────────────────────────────────

func _on_stat_threshold_crossed(stat_name: String, threshold: int):
	var unlock_msgs = {
		"investment_skill": {
			30: "📊 레버리지 투자 해금! 2배 포지션으로 고수익을 노릴 수 있다.",
			50: "🔭 시장 분석(무료 행동) 해금! 매달 시장 방향을 미리 읽어라.",
			70: "⚡ 선물 매매 해금! 극한의 투자가가 되었다.",
		},
		"intelligence": {
			30: "📖 심화 독서 해금! 독서 효과가 2배로 강화된다.",
			50: "🔬 재무제표 분석 해금! 투자 결정에 정확도가 올라간다.",
			70: "🧠 데이터 드리븐 투자 해금! 시장 예측 정확도 최고 수준.",
		},
		"social_skill": {
			30: "🤝 관계 강화 효과 상승! 인맥활동 보너스가 커진다.",
			50: "👔 VIP 인맥 해금! 사회성 3배 상승, 대형 관계 이벤트 접근 가능.",
			70: "🎩 엘리트 서클 해금! 최상위 직군 이벤트와 네트워크에 접근한다.",
		},
	}
	var stat_msg = unlock_msgs.get(stat_name, {})
	if stat_msg.has(threshold):
		var msg = stat_msg[threshold]
		_show_toast("🔓 " + msg, Color("#f0b429"))
		GameState.add_log("✨ " + msg, "system")
		AudioManager.play("housing_up")

func _on_next_month():
	if not current_event.is_empty():
		return
	if not pending_result_text.is_empty():
		pending_result_text = ""
		return
	if GameState.tutorial_step > 0:
		GameState.tutorial_step -= 1
	job_system.process_monthly_job()
	relationship_system.process_monthly_relationships()
	inventory_system.process_monthly_items()

	# 초반 난이도 완화: 튜토리얼 3턴 동안 정착 지원금 30만원
	var subsidy_applied = GameState.turn <= 3
	if subsidy_applied:
		GameState.add_money(300_000.0)
		GameState.add_log("초기 정착 지원금 30만원 수령", "system")

	# 결산 전 스냅샷
	var snap = {
		"date": GameState.get_date_string(),
		"money_before": GameState.money,
		"monthly_income": GameState.monthly_income,
		"fixed_expense": GameState.get_housing_expense(),
		"assets_before": GameState.get_total_asset_value(),
		"health_before": GameState.health,
		"mental_before": GameState.mental,
		"stress_before": GameState.stress,
		"actions": turn_action_log.duplicate(),
		"subsidy": subsidy_applied,
	}

	var had_paycheck_before: bool = GameState.flags.get("has_received_paycheck", false)
	GameState.apply_monthly_pressure()
	GameState.advance_calendar()
	_refresh_all()
	# 첫 월급 수령 시 투자·상점 잠금 해제 축하 토스트
	if not had_paycheck_before and GameState.flags.get("has_received_paycheck", false):
		_show_toast("💳 첫 월급 수령! 투자·상점이 열렸습니다", Color("#00c896"))

	if GameState.is_game_over:
		return
	SaveManager.autosave()
	_check_title_unlocks()
	_show_month_summary(snap)

func _choose(index):
	var choices: Array = current_event.get("choices", [])
	var result_text = ""
	if index >= 0 and index < choices.size():
		result_text = str(choices[index].get("result_text", "")).strip_edges()
	EventManager.resolve_current_event(index)
	current_event = EventManager.get_next_event()
	if not result_text.is_empty() and current_event.is_empty():
		_show_result(result_text)
	else:
		_render_event()
	_refresh_all()

func _show_result(result_text: String):
	for child in choice_box.get_children():
		child.queue_free()
	pending_result_text = result_text
	event_title.text = "결과"
	event_body.text = _fmt(result_text)
	var confirm_btn = _button("확인", "#1f6feb")
	confirm_btn.pressed.connect(_on_result_confirmed)
	choice_box.add_child(confirm_btn)
	next_button.disabled = true

func _on_result_confirmed():
	pending_result_text = ""
	_render_event()

func _fmt(text: String) -> String:
	# 이벤트 텍스트 안의 플레이스홀더를 실제 값으로 치환
	var job_name = GameState.current_job.get("name", "무직")
	var housing_info = GameState.get_housing_info()
	return text \
		.replace("{name}", GameState.player_name) \
		.replace("{job}", job_name) \
		.replace("{housing}", housing_info.get("name", "고시원")) \
		.replace("{month}", str(GameState.month)) \
		.replace("{year}", str(GameState.year)) \
		.replace("{money}", GameState.format_money(GameState.money))

func _render_event():
	for child in choice_box.get_children():
		child.queue_free()
	if current_event.is_empty():
		next_button.disabled = false
		_render_ap_actions()
		return
	next_button.disabled = true
	event_title.text = _fmt(current_event.get("title", "이벤트"))
	event_body.text = _fmt(current_event.get("description", ""))
	# 이벤트에 맞는 배경 즉시 전환
	_update_event_bg()
	var choices: Array = current_event.get("choices", [])
	var btn_colors = ["#1d4ed8", "#7c3aed", "#0f766e"]
	for i in range(choices.size()):
		var choice: Dictionary = choices[i]
		var col = btn_colors[i % btn_colors.size()]
		var button = _button("  %d.  %s" % [i + 1, _fmt(choice.get("text", "선택"))], col)
		button.pressed.connect(Callable(self, "_choose").bind(i))
		choice_box.add_child(button)

func _refresh_all():
	if not is_inside_tree():
		return
	top_labels["date"].text = GameState.get_date_string()
	var total_assets = GameState.get_total_asset_value()
	var cash_str = GameState.format_money(GameState.money)
	var asset_str = GameState.format_money(total_assets)
	if abs(total_assets - GameState.money) > 10000:
		top_labels["money"].text = "💰 %s  │  📊 %s" % [cash_str, asset_str]
	else:
		top_labels["money"].text = "💰 %s" % cash_str
	# AP 도트 (이벤트 없을 때만 표시, _render_ap_actions에서도 갱신)
	var ap = GameState.action_points
	top_labels["ap"].text = "⚡".repeat(ap) + "○".repeat(max(0, GameState.max_action_points - ap))
	# 초상화 하단 플레이어 정보
	if player_name_label:
		var job_name = GameState.current_job.get("name", "무직")
		player_name_label.text = "%s\n%s" % [GameState.player_name, job_name]
	if title_label:
		title_label.text = "「%s」" % GameState.get_current_title()

	stat_labels["job"].text = GameState.current_job.get("name", "무직")
	_set_stat_value("health", GameState.health, true, 50, 30)
	_set_stat_value("mental", GameState.mental, true, 50, 30)
	_set_stat_value("stress", GameState.stress, false, 60, 80)
	stat_labels["intelligence"].text = str(GameState.intelligence)
	stat_labels["social_skill"].text = str(GameState.social_skill)
	stat_labels["appearance"].text = str(GameState.appearance)
	stat_labels["investment_skill"].text = str(GameState.investment_skill)
	stat_labels["luck"].text = str(GameState.luck)
	stat_labels["reputation"].text = str(GameState.reputation)
	stat_labels["asset"].text = GameState.format_money(GameState.get_total_asset_value())
	var h = GameState.get_housing_info()
	stat_labels["housing"].text = "%s %s" % [h.get("emoji",""), h.get("name","")]

	# 배경 + 초상화 업데이트
	_update_event_bg()
	_update_portrait()

	# 라이벌 표시
	if rival_label:
		var rival = RivalSystem.get_rival()
		if not rival.is_empty():
			var r_housing = GameState.HOUSING_DATA.get(rival.get("housing","gosiwon"),{})
			var r_assets  = GameState.format_money(float(rival.get("total_assets", 0.0)))
			var player_a  = GameState.get_total_asset_value()
			var rival_a   = float(rival.get("total_assets", 0.0))
			var diff      = player_a - rival_a
			var sign      = "▲" if diff >= 0 else "▼"
			rival_label.text = "%s  %s  %s\n나 %s%s" % [
				rival["name"], r_housing.get("name","고시원"), r_assets, sign, GameState.format_money(abs(diff))
			]

	# 자산 마일스톤 체크
	_check_milestones()

	_render_news()
	_render_sidebars()
	_render_log()

func _set_stat_value(key: String, value: int, low_is_bad: bool, warn_thresh: int, danger_thresh: int):
	var label = stat_labels[key]
	var filled = clamp(int(value / 10.0), 0, 10)
	var bar = "█".repeat(filled) + "░".repeat(10 - filled)
	label.text = "%s %d" % [bar, value]
	var is_danger: bool
	var is_warn: bool
	if low_is_bad:
		is_danger = value <= danger_thresh
		is_warn   = value <= warn_thresh and not is_danger
	else:
		is_danger = value >= danger_thresh
		is_warn   = value >= warn_thresh and not is_danger
	if is_danger:
		label.add_theme_color_override("font_color", Color("#ff4444"))
	elif is_warn:
		label.add_theme_color_override("font_color", Color("#f0b429"))
	else:
		label.add_theme_color_override("font_color", Color("#e8eaf0"))

func _render_news():
	for child in news_box.get_children():
		child.queue_free()
	news_box.add_child(_label("▸ BREAKING NEWS", 14, "#f97316"))
	var items = GameState.news_log.slice(max(0, GameState.news_log.size() - 4))
	for news in items:
		var text = str(news.get("headline", "")).format({"topic": _random_topic(news)})
		var misleading = bool(news.get("misleading", false))
		var effect: Dictionary = news.get("market_effect", news.get("market_effects", {}))
		var power = float(effect.get("power", 0.0))
		var color = "#8892a4"
		var prefix = ""
		if misleading:
			color = "#5a6075"
			prefix = "⚠ [루머] "
		elif power >= 0.04:
			color = "#00c896"
			prefix = "📈 "
		elif power >= 0.01:
			color = "#6ee7b7"
			prefix = "▲ "
		elif power <= -0.04:
			color = "#ff6b6b"
			prefix = "📉 "
		elif power <= -0.01:
			color = "#fca5a5"
			prefix = "▼ "
		news_box.add_child(_wrap_label(prefix + text, 13, color))

func _render_sidebars():
	# ── 시세 패널: RichTextLabel 단일 업데이트 ──
	if ticker_rtl:
		var lines: PackedStringArray = PackedStringArray()
		lines.append("[color=#3fb950][b]▸ MARKET TICKER[/b][/color]")
		for row in investment_system.get_asset_rows().slice(0, 12):
			var asset_id = row["id"]
			var price = float(row["price"])
			var old_price = float(prev_prices.get(asset_id, price))
			var change_pct = 0.0
			if old_price > 0.0:
				change_pct = (price - old_price) / old_price * 100.0
			var pct_str = ""
			var color = "#8892a4"
			if change_pct > 0.05:
				pct_str = " +%.1f%%" % change_pct
				color = "#00c896"
			elif change_pct < -0.05:
				pct_str = " %.1f%%" % change_pct
				color = "#ff4444"
			var owned_str = ""
			if float(row["owned_value"]) > 0:
				owned_str = "  [color=#5b9cf6]▶%s[/color]" % GameState.format_money(row["owned_value"])
			var risk_dots = "●".repeat(int(row.get("risk_level", 1))) + "○".repeat(5 - int(row.get("risk_level", 1)))
			lines.append("[color=%s]%s  %s%s%s  %s[/color]" % [color, row["name"], GameState.format_money(price), pct_str, owned_str, risk_dots])
		ticker_rtl.clear()
		ticker_rtl.append_text("\n".join(lines))

	_clear_box(relationship_box)
	relationship_box.add_child(_label("▸ RELATIONSHIPS", 14, "#d8b4fe"))
	if GameState.relationships.is_empty():
		relationship_box.add_child(_label("아직 중요한 인연이 없다.", 12, "#5a6075"))
	for rel in GameState.relationships:
		var affection = int(rel.get("affection", 40))
		var trust = int(rel.get("trust", 40))
		var type_str = str(rel.get("type", "friends"))
		var type_kr = {"romantic": "연인", "mentor": "멘토", "business": "비즈니스", "family": "가족", "friends": "친구"}.get(type_str, "인연")
		var affinity = relationship_system.get_affinity_label(affection)
		relationship_box.add_child(_label("%s  [%s]  %s (%d/%d)" % [rel.get("name", "?"), type_kr, affinity, affection, trust], 12, "#8892a4"))
		# 관계 효과 힌트
		if affection >= 45:
			var effect_hint = _rel_effect_hint(type_str, affection, trust)
			if not effect_hint.is_empty():
				relationship_box.add_child(_wrap_label("  ▸ " + effect_hint, 11, "#64748b"))

	_clear_box(inventory_box)
	inventory_box.add_child(_label("▸ INVENTORY", 14, "#fbbf24"))
	if GameState.inventory.is_empty():
		inventory_box.add_child(_label("비어 있음", 12, "#5a6075"))
	for item in GameState.inventory:
		var item_row = HBoxContainer.new()
		item_row.add_theme_constant_override("separation", 6)
		var item_label = _label("%s %s x%d" % [item.get("icon", ""), item.get("name", "아이템"), item.get("quantity", 1)], 12, "#8892a4")
		item_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		item_row.add_child(item_label)
		var use_btn = _small_button("사용", "#0f766e")
		use_btn.pressed.connect(Callable(self, "_on_use_item").bind(item.get("id", "")))
		item_row.add_child(use_btn)
		inventory_box.add_child(item_row)

func _render_log():
	var lines: Array = []
	var type_colors = {
		"event": "#93c5fd",
		"trade": "#00c896",
		"job": "#fbbf24",
		"item": "#d8b4fe",
		"market": "#5a6075",
		"relationship": "#f9a8d4",
		"system": "#64748b",
	}
	for entry in GameState.action_log.slice(max(0, GameState.action_log.size() - 16)):
		var t = entry.get("type", "system")
		var color = type_colors.get(t, "#5a6075")
		var date_str = entry.get("date", "")
		var msg = entry.get("message", "")
		lines.append("[color=%s][%s] %s[/color]" % [color, date_str, msg])
	log_box.text = "\n".join(lines)

func _render_ap_actions():
	for child in choice_box.get_children():
		child.queue_free()
	var ap = GameState.action_points
	var ap_dots = "⚡".repeat(ap) + "○".repeat(max(0, GameState.max_action_points - ap))
	if top_labels.has("ap"):
		top_labels["ap"].text = "%s  %d/%d" % [ap_dots, ap, GameState.max_action_points]
	event_title.text = "%d년 %d월" % [GameState.year, GameState.month]

	# ── 상황판 ────────────────────────────────────────────────────
	var net = GameState.monthly_income - GameState.get_housing_expense()
	var total = GameState.get_total_asset_value()
	var lines: PackedStringArray = PackedStringArray()
	if not turn_action_log.is_empty():
		for entry in turn_action_log:
			lines.append(entry)
		lines.append("──────────────────")
	var net_sign = "+" if net >= 0 else ""
	var net_flag = "  ← 매달 적자 주의!" if net < 0 else ""
	lines.append("이번 달 예상 순이익  %s%s%s" % [net_sign, GameState.format_money(net), net_flag])
	var ms_hint = _next_milestone_hint(total)
	if not ms_hint.is_empty():
		lines.append(ms_hint)
	if GameState.current_job.is_empty():
		lines.append("⚠  직업 없음  — 수입 0원. 구직활동을 먼저 하세요!")
	if GameState.health <= 45:
		lines.append("🚨  건강 %d / 100  — 위험!" % GameState.health)
	if GameState.mental <= 45:
		lines.append("🚨  정신력 %d / 100  — 위험!" % GameState.mental)
	if GameState.stress >= 72 and GameState.health > 45 and GameState.mental > 45:
		lines.append("⚠  스트레스 %d  — 건강/정신에 영향을 줍니다." % GameState.stress)
	if GameState.money < 0:
		lines.append("🚨  잔고 마이너스  %s  — 빚이 생겼습니다!" % GameState.format_money(GameState.money))
	event_body.text = "\n".join(lines)

	var disabled = (ap <= 0)
	var has_paycheck: bool = GameState.flags.get("has_received_paycheck", false)
	var no_job = GameState.current_job.is_empty()
	var job_story_unlocked: bool = GameState.flags.get("story_job_unlocked", false)
	var warn_body = GameState.health <= 45 or GameState.mental <= 45

	# ── 행동력 소진 안내 + 버튼 강조 ──────────────────────
	if disabled:
		var done = _wrap_label("✅  이번 달 행동 완료!", 13, "#00c896")
		done.add_theme_stylebox_override("normal", _hint_box())
		choice_box.add_child(done)
		next_button.text = "▶▶ 다음 달로!"
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color("#065f46")
		btn_style.border_color = Color("#00c896")
		btn_style.set_border_width_all(2)
		btn_style.corner_radius_top_left = 6
		btn_style.corner_radius_top_right = 6
		btn_style.corner_radius_bottom_left = 6
		btn_style.corner_radius_bottom_right = 6
		btn_style.content_margin_left = 20
		btn_style.content_margin_right = 20
		btn_style.content_margin_top = 10
		btn_style.content_margin_bottom = 10
		next_button.add_theme_stylebox_override("normal", btn_style)
		next_button.add_theme_color_override("font_color", Color("#00c896"))
	else:
		next_button.text = "다음 달 ▶"
		next_button.remove_theme_stylebox_override("normal")
		next_button.remove_theme_color_override("font_color")

	# ── 이번 달 방향 / 루트 성향 ────────────────────────
	var route_total = GameState.route_orthodox + GameState.route_unorthodox
	if route_total > 0:
		var route_color = "#5b9cf6" if GameState.route_orthodox >= GameState.route_unorthodox else "#f97316"
		choice_box.add_child(_wrap_label(GameState.get_route_label(), 12, route_color))
	if not GameState.month_focus.is_empty():
		choice_box.add_child(_wrap_label("이번 달 집중: %s" % GameState.month_focus, 12, "#f0b429"))

	# ── 튜토리얼 힌트 ──────────────────────────────────
	var hint_text = ""
	var hint_color = "#f0b429"
	var job_story_done: bool = GameState.flags.get("story_job_unlocked", false)
	var just_got_paycheck = GameState.flags.get("has_received_paycheck", false) \
		and not GameState.flags.get("invest_hint_shown", false)

	# 첫 달 AP 꽉 찬 상태 — 아직 아무것도 안 한 경우
	if GameState.turn == 1 and ap == GameState.max_action_points and turn_action_log.is_empty():
		hint_text = "👋 첫 달이에요! ⚡AP 3개로 행동을 골라 쓰세요.\n지금 당장은 '💼 구직활동'이 가장 중요합니다."
		hint_color = "#00c896"
	# 구직 스토리 해금 전
	elif GameState.tutorial_step >= 2 and not job_story_done:
		hint_text = "📌 이벤트 선택지를 고르며 스토리를 진행하세요."
	# 구직 가능하지만 아직 무직
	elif GameState.tutorial_step >= 1 and job_story_done and no_job:
		hint_text = "⚠ 수입이 0원입니다! 아래 '💼 구직활동' 버튼으로 지금 바로 취업하세요.\n취업 안 하면 2달 안에 파산해요."
		hint_color = "#ef4444"
	# 취업 완료, 튜토리얼 2단계
	elif GameState.tutorial_step == 2 and not no_job:
		hint_text = "✅ 취업했어요! 남은 ⚡AP로 스펙 쌓기나 인맥 관리를 해보세요.\nAP를 다 쓰면 '다음 달 ▶' 버튼이 나타납니다."
	# 첫 월급 직후 — 투자 안내
	elif just_got_paycheck:
		GameState.flags["invest_hint_shown"] = true
		hint_text = "💳 첫 월급! 이제 아래 '📈 비정석 루트'에서 투자도 가능해요.\n하지만 무리한 투자는 금물 — 먼저 생활비부터 확보하세요."
		hint_color = "#00c896"
	# 1단계: 다음 달로 버튼 안내
	elif GameState.tutorial_step == 1:
		hint_text = "📌 AP를 다 쓰면 '✅ 이번 달 행동 완료' 안내가 나타나요.\n그때 '다음 달 ▶' 버튼으로 진행하세요."
	# 튜토리얼 완료
	elif GameState.tutorial_step == 0 and GameState.turn <= 4:
		hint_text = "🎯 이제 혼자예요. 자산 20억 달성이 목표입니다. 65세까지 버텨보세요!"
		hint_color = "#00c896"

	if not hint_text.is_empty():
		var hint = _wrap_label(hint_text, 13, hint_color)
		hint.add_theme_stylebox_override("normal", _hint_box())
		choice_box.add_child(hint)

	# ══════════════════════════════════════════════════════
	# 📘 정석 루트  —  사회가 기대하는 방향
	# ══════════════════════════════════════════════════════
	_add_action_section_header(choice_box, "📘 정석 루트  —  사회가 기대하는 방향", "#0f2040")

	var orthodox: Array = []

	# 스펙/공부
	var study_label = "📚 스펙 쌓기  —  독서·운동·명상 선택"
	if warn_body: study_label = "📚 자기계발  🚨 체력·정신 회복 필요"
	orthodox.append({"label": study_label, "color": "#5b9cf6", "fn": "_ap_study", "route": "orthodox", "focus": "스펙 쌓기"})

	if GameState.intelligence >= 30:
		orthodox.append({"label": "📖 심화 독서  —  지력 +8", "color": "#1d4ed8", "fn": "_ap_deep_study", "route": "orthodox", "focus": "심화 공부"})

	# 취업/직장
	if not job_story_unlocked:
		orthodox.append({"label": "💼 구직활동  🔒 스토리 진행 후 해금", "color": "#2d3748", "fn": "_ap_job_hunt", "route": "orthodox", "focus": "취업 준비", "locked": true})
	elif no_job:
		orthodox.append({"label": "💼 구직활동  ⚠  지금 무직 — 취업 필수!", "color": "#dc2626", "fn": "_ap_job_hunt", "route": "orthodox", "focus": "취업 준비"})
	else:
		orthodox.append({"label": "💼 직장 생활  —  커리어 관리·승진 준비", "color": "#b45309", "fn": "_ap_job_hunt", "route": "orthodox", "focus": "커리어 관리"})

	orthodox.append({"label": "🤝 인맥 관리  —  사회성+1, 직장·학교 관계", "color": "#7c3aed", "fn": "_ap_network", "route": "orthodox", "focus": "인맥 관리"})
	orthodox.append({"label": "💰 저축/절약  —  스트레스 -4, 절약 마인드", "color": "#0369a1", "fn": "_ap_save_money", "route": "orthodox", "focus": "저축 집중"})

	if GameState.social_skill >= 50:
		orthodox.append({"label": "👔 VIP 인맥  —  사회성+3, 모든 관계 친밀도+15", "color": "#4c1d95", "fn": "_ap_vip_network", "route": "orthodox", "focus": "고급 인맥"})

	_add_action_buttons(choice_box, orthodox, disabled)

	# ══════════════════════════════════════════════════════
	# 🔥 비정석 루트  —  나만의 길
	# ══════════════════════════════════════════════════════
	_add_action_section_header(choice_box, "🔥 비정석 루트  —  나만의 길", "#2a0a0a")

	var unorthodox: Array = []

	if has_paycheck:
		unorthodox.append({"label": "📈 투자 집중  —  매수·매도 (투자감각 %d)" % GameState.investment_skill, "color": "#059669", "fn": "_ap_invest", "route": "unorthodox", "focus": "투자"})
	else:
		unorthodox.append({"label": "📈 투자  🔒 첫 월급 수령 후 해금", "color": "#2d3748", "fn": "_ap_invest", "route": "unorthodox", "focus": "투자", "locked": true})

	if GameState.investment_skill >= 30 and has_paycheck:
		unorthodox.append({"label": "⚡ 레버리지 투자  —  2배 포지션 (고위험)", "color": "#7f1d1d", "fn": "_ap_leverage_invest", "route": "unorthodox", "focus": "고위험 투자"})

	var side_label = "💰 단기 알바  —  +40만원 (건강-5, 스트레스+6)" if no_job else "🎨 부업/사이드  —  추가 수입 도전 (건강-5)"
	unorthodox.append({"label": side_label, "color": "#0369a1", "fn": "_ap_side_job", "route": "unorthodox", "focus": "부업"})

	unorthodox.append({"label": "❤️ 연애/관계  —  정신력+8, 스트레스-5, 인연", "color": "#db2777", "fn": "_ap_romance", "route": "unorthodox", "focus": "연애"})
	unorthodox.append({"label": "🌊 자유시간  —  한강·편의점·산책 (정신력+10)", "color": "#0891b2", "fn": "_ap_free_time", "route": "unorthodox", "focus": "자유시간"})

	if GameState.intelligence >= 50 and has_paycheck:
		var forecast = investment_system.get_market_forecast()
		unorthodox.append({"label": "🔭 시장 분석 [무료] — %s" % forecast, "color": "#1e3a5f", "fn": "_ap_market_analysis", "route": "unorthodox", "focus": "시장 분석", "free": true})

	_add_action_buttons(choice_box, unorthodox, disabled)

	# ── 창업/크리에이터 전용 행동 ─────────────────────────
	var startup_active: bool = GameState.flags.get("startup_launched", false) and not GameState.flags.get("startup_exit", false)
	var creator_active: bool = GameState.flags.get("creator_started", false) and not GameState.flags.get("creator_success_unlocked", false)
	if startup_active or creator_active:
		_add_action_section_header(choice_box, "🚀 내 사업  —  비정석 루트 진행 중", "#1a0a2a")
		var biz_actions: Array = []
		if startup_active:
			var startup_stage = "아이디어" if not GameState.flags.get("startup_team", false) else ("런칭" if not GameState.flags.get("startup_pivoted", false) else "성장")
			biz_actions.append({"label": "🚀 창업 업무  —  %s 단계 (명성+2, 지력+1, 스트레스+5)" % startup_stage, "color": "#3b1a5c", "fn": "_ap_startup_work", "route": "unorthodox", "focus": "창업"})
		if creator_active:
			var creator_stage = "시작" if not GameState.flags.get("creator_viral", false) else ("성장 중" if not GameState.flags.get("creator_monetized", false) else "수익화")
			biz_actions.append({"label": "🎬 콘텐츠 제작  —  %s (명성+1, 정신+5)" % creator_stage, "color": "#1a2a0a", "fn": "_ap_create_content", "route": "unorthodox", "focus": "부업"})
		_add_action_buttons(choice_box, biz_actions, disabled)

	# ── 취업 준비 특화 행동 (무직일 때만) ──────────────────
	if no_job and job_story_unlocked:
		_add_action_section_header(choice_box, "📋 취업 준비  —  전문 스펙 쌓기", "#0a1a2a")
		var job_seeker: Array = []
		job_seeker.append({
			"label": "🖊 자소서 작성  —  지력 +3, 스트레스 +4",
			"color": "#0f4c5c", "fn": "_ap_write_resume",
			"route": "orthodox", "focus": "취업 준비"
		})
		if GameState.social_skill >= 20:
			job_seeker.append({
				"label": "🎯 모의 면접  —  사회성 +2, 운 +1",
				"color": "#0f3a5c", "fn": "_ap_interview_prep",
				"route": "orthodox", "focus": "취업 준비"
			})
		_add_action_buttons(choice_box, job_seeker, disabled)

	# ── 이사 버튼 — AP 불필요 ────────────────────────────
	if GameState.can_upgrade_housing():
		_add_action_section_header(choice_box, "🏠 주거 업그레이드", "#1a2a1a")
		var next_id = str(GameState.get_housing_info().get("next", ""))
		var next_info = GameState.HOUSING_DATA.get(next_id, {})
		var move_btn = _button(
			"🏠 이사  —  %s%s  (월 %s / 보증금 %s)" % [
				next_info.get("emoji",""), next_info.get("name",""),
				GameState.format_money(float(next_info.get("expense", 0.0))),
				GameState.format_money(float(next_info.get("deposit", 0.0)))
			], "#f0b429")
		move_btn.disabled = false
		move_btn.pressed.connect(_ap_move_housing)
		choice_box.add_child(move_btn)

	# ── 상점 버튼 ───────────────────────────────────────
	if shop_button:
		shop_button.text = "🛍 상점" if has_paycheck else "🛍 상점 🔒"
		shop_button.disabled = not has_paycheck

func _add_action_section_header(parent: Control, title: String, bg_hex: String):
	var lbl = _label("  " + title, 11, "#8892a4")
	var style = StyleBoxFlat.new()
	style.bg_color = Color(bg_hex)
	style.set_corner_radius_all(3)
	style.content_margin_left = 6
	style.content_margin_top = 3
	style.content_margin_bottom = 3
	lbl.add_theme_stylebox_override("normal", style)
	parent.add_child(lbl)

func _add_action_buttons(parent: Control, actions: Array, disabled: bool):
	for action in actions:
		var action_locked: bool = action.get("locked", false)
		var is_free: bool = action.get("free", false)
		var route_type: String = action.get("route", "")
		var focus_label: String = action.get("focus", "")
		var btn_color: String = action["color"]
		if action_locked or (disabled and not is_free):
			btn_color = "#1e1e2a"
		var btn = _button(action["label"], btn_color)
		btn.disabled = (disabled and not is_free) or action_locked
		var fn_name: String = action["fn"]
		btn.pressed.connect(func():
			if not route_type.is_empty():
				GameState.add_route_point(route_type, focus_label)
			call(fn_name)
		)
		parent.add_child(btn)

func _ap_study():
	if GameState.action_points <= 0:
		_show_toast("⚡ 행동력이 없습니다", Color("#ff4444"))
		return
	_open_modal("📚 자기계발")
	modal_body.add_child(_wrap_label(
		"현재  건강 %d  |  정신 %d  |  지력 %d  |  투자감각 %d  |  스트레스 %d" % [
			GameState.health, GameState.mental, GameState.intelligence,
			GameState.investment_skill, GameState.stress
		], 13, "#5a6075"))
	var sep = HSeparator.new()
	sep.add_theme_color_override("color", Color("#252535"))
	modal_body.add_child(sep)
	var options = [
		{"label": "📖 독서  — 지력 +4  (현재 %d → %d)" % [GameState.intelligence, GameState.intelligence + 4],
			"effects": {"intelligence": 4}},
		{"label": "🏃 운동  — 건강 +10, 스트레스 -6  (건강 %d → %d)" % [GameState.health, min(100, GameState.health + 10)],
			"effects": {"health": 10, "stress": -6}},
		{"label": "🧘 명상  — 정신력 +10, 스트레스 -8  (정신 %d → %d)" % [GameState.mental, min(100, GameState.mental + 10)],
			"effects": {"mental": 10, "stress": -8}},
		{"label": "📊 재테크 공부  — 투자감각 +3  (현재 %d → %d)" % [GameState.investment_skill, min(100, GameState.investment_skill + 3)],
			"effects": {"investment_skill": 3}},
	]
	for opt in options:
		var btn = _button(opt["label"], "#5b9cf6")
		btn.pressed.connect(Callable(self, "_on_study_chosen").bind(opt["effects"]))
		modal_body.add_child(btn)

func _on_study_chosen(effects):
	if not GameState.spend_ap():
		_show_toast("⚡ 행동력이 없습니다", Color("#ff4444"))
		_close_modal()
		return
	# before snapshot
	var before = {
		"intelligence": GameState.intelligence, "health": GameState.health,
		"mental": GameState.mental, "stress": GameState.stress,
		"investment_skill": GameState.investment_skill,
	}
	GameState.apply_effects(effects)
	AudioManager.play("stat_up")
	_close_modal()
	var parts: Array = []
	var toast_main = ""
	for k in effects:
		var v = int(effects[k])
		var sign = "+" if v >= 0 else ""
		var old_val = int(before.get(k, 0))
		match k:
			"intelligence":
				parts.append("지력 %d→%d" % [old_val, GameState.intelligence])
				toast_main = "📖 독서  지력 %d → %d" % [old_val, GameState.intelligence]
			"health":
				parts.append("건강 %d→%d" % [old_val, GameState.health])
				toast_main = "🏃 운동  건강 %d → %d" % [old_val, GameState.health]
			"mental":
				parts.append("정신 %d→%d" % [old_val, GameState.mental])
				if toast_main.is_empty():
					toast_main = "🧘 명상  정신 %d → %d" % [old_val, GameState.mental]
			"stress":
				parts.append("스트레스 %s%d" % [sign, v])
			"investment_skill":
				parts.append("투자감각 %d→%d" % [old_val, GameState.investment_skill])
				toast_main = "📊 재테크 공부  투자감각 %d → %d" % [old_val, GameState.investment_skill]
	turn_action_log.append("✓ 📚 자기계발 → %s" % ", ".join(parts))
	if toast_main.is_empty():
		toast_main = "📚 자기계발 완료"
	_show_toast(toast_main, Color("#5b9cf6"))
	_refresh_all()

func _ap_invest():
	if GameState.action_points <= 0:
		_show_toast("⚡ 행동력이 없습니다", Color("#ff4444"))
		return
	_open_investments()

func _ap_job_hunt():
	if not GameState.spend_ap():
		return
	turn_action_log.append("✓ 💼 구직활동 — 직업 목록 열람")
	_open_jobs()

func _ap_network():
	if not GameState.spend_ap():
		return
	var social_before = GameState.social_skill
	GameState.modify_stat("social_skill", 1)
	var result_parts: Array = ["사회성 %d→%d" % [social_before, GameState.social_skill]]
	var toast_extra = ""
	if not GameState.relationships.is_empty():
		var rel = GameState.relationships[randi() % GameState.relationships.size()]
		var aff_before = int(rel.get("affection", 40))
		rel["affection"] = clamp(aff_before + 6, 0, 100)
		var rel_name_str = str(rel.get("name", "인연"))
		result_parts.append("%s 친밀도 %d→%d" % [rel_name_str, aff_before, rel["affection"]])
		toast_extra = "  (%s 친밀도 ↑)" % rel_name_str
	GameState.add_log("인맥활동: %s" % ", ".join(result_parts), "relationship")
	turn_action_log.append("✓ 🤝 인맥활동 → %s" % ", ".join(result_parts))
	_show_toast("🤝 인맥활동 완료%s" % toast_extra, Color("#d8b4fe"))
	GameState.stats_changed.emit()
	_render_ap_actions()
	_refresh_all()

func _ap_side_job():
	if not GameState.spend_ap():
		return
	var income = 400_000.0
	var health_before = GameState.health
	GameState.add_money(income)
	GameState.modify_stat("health", -5)
	GameState.modify_hidden_stat("stress", 6)
	GameState.add_log("알바 추가 수입 %s (건강 %d→%d, 스트레스 +6)" % [
		GameState.format_money(income), health_before, GameState.health], "job")
	turn_action_log.append("✓ 💰 알바 추가 → +%s  건강 %d→%d" % [
		GameState.format_money(income), health_before, GameState.health])
	AudioManager.play("money_gain")
	_show_toast("💰 알바 수입 +%s  (건강 %d→%d)" % [
		GameState.format_money(income), health_before, GameState.health], Color("#00c896"))
	_render_ap_actions()
	_refresh_all()

func _ap_save_money():
	if not GameState.spend_ap():
		return
	GameState.modify_hidden_stat("stress", -4)
	GameState.modify_stat("mental", 2)
	var savings_bonus = 0.0
	if GameState.money > 500_000:
		savings_bonus = min(GameState.money * 0.005, 80_000.0)
		GameState.add_money(savings_bonus)
	var msg = "💰 저축/절약 — 스트레스 -4, 정신력 +2"
	if savings_bonus > 0:
		msg += ", 절약 보너스 +%s" % GameState.format_money(savings_bonus)
	GameState.add_log(msg, "job")
	turn_action_log.append("✓ " + msg)
	_show_toast(msg, Color("#0369a1"))
	_render_ap_actions()
	_refresh_all()

func _ap_romance():
	if not GameState.spend_ap():
		return
	var mental_before = GameState.mental
	GameState.modify_stat("mental", 8)
	GameState.modify_hidden_stat("stress", -5)
	var rel_result = ""
	if not GameState.relationships.is_empty():
		var rel: Dictionary = GameState.relationships[randi() % GameState.relationships.size()]
		var aff_before = int(rel.get("affection", 40))
		rel["affection"] = clamp(aff_before + 10, 0, 100)
		rel_result = "  (%s 친밀도 ↑)" % str(rel.get("name", "인연"))
	elif randf() < 0.35:
		var names = ["이수민", "박지훈", "김나연", "이준호", "최서연"]
		GameState.apply_relationship_effect({
			"id": "romance_new_%d" % GameState.turn,
			"name": names[randi() % names.size()],
			"type": "romantic",
			"affection": 20,
			"trust": 15,
		})
		rel_result = "  (새 인연!)"
	var msg = "❤️ 연애/관계 — 정신 %d→%d%s" % [mental_before, GameState.mental, rel_result]
	GameState.add_log(msg, "relationship")
	turn_action_log.append("✓ " + msg)
	_show_toast(msg, Color("#db2777"))
	GameState.stats_changed.emit()
	_render_ap_actions()
	_refresh_all()

func _ap_free_time():
	if not GameState.spend_ap():
		return
	var mental_before = GameState.mental
	GameState.modify_stat("mental", 10)
	GameState.modify_hidden_stat("stress", -8)
	GameState.flags["had_free_time_recently"] = true
	GameState.flags["free_time_count"] = GameState.flags.get("free_time_count", 0) + 1
	var luck_msg = ""
	var roll = randf()
	if roll < 0.12:
		var windfall = float(randi_range(30_000, 150_000))
		GameState.add_money(windfall)
		GameState.modify_stat("luck", 1)
		luck_msg = "  💸 뜻밖의 행운 +%s!" % GameState.format_money(windfall)
		AudioManager.play("money_gain")
	elif roll < 0.30:
		GameState.modify_stat("luck", 1)
		luck_msg = "  ✨ 흥미로운 만남의 예감"
	var msg = "🌊 자유시간 — 정신 %d→%d, 스트레스 -8%s" % [mental_before, GameState.mental, luck_msg]
	GameState.add_log(msg, "event")
	turn_action_log.append("✓ " + msg)
	_show_toast("🌊 자유시간%s" % luck_msg, Color("#0891b2"))
	GameState.stats_changed.emit()
	_render_ap_actions()
	_refresh_all()

func _ap_startup_work():
	if not GameState.spend_ap():
		return
	var rep_before = GameState.reputation
	GameState.modify_hidden_stat("reputation", 2)
	GameState.modify_stat("intelligence", 1)
	GameState.modify_hidden_stat("stress", 5)
	var stage = "아이디어" if not GameState.flags.get("startup_launched", false) else "운영"
	turn_action_log.append("✓ 🚀 창업 업무[%s] → 명성+2, 지력+1, 스트레스+5" % stage)
	_show_toast("🚀 창업 업무 — 명성 %d → %d" % [rep_before, GameState.reputation], Color("#7c3aed"))
	_render_ap_actions()
	_refresh_all()

func _ap_create_content():
	if not GameState.spend_ap():
		return
	var rep_before = GameState.reputation
	var mental_before = GameState.mental
	GameState.modify_hidden_stat("reputation", 1)
	GameState.modify_stat("mental", 5)
	GameState.modify_stat("luck", 1)
	if GameState.flags.get("creator_monetized", false):
		var content_income = float(randi_range(50_000, 200_000))
		GameState.add_money(content_income)
		turn_action_log.append("✓ 🎬 콘텐츠 제작 → 명성+1, 정신+5, 수익 +%s" % GameState.format_money(content_income))
		_show_toast("🎬 콘텐츠 제작 완료  명성+1  수익 +%s" % GameState.format_money(content_income), Color("#3fb950"))
	else:
		turn_action_log.append("✓ 🎬 콘텐츠 제작 → 명성+1, 정신 %d→%d" % [mental_before, GameState.mental])
		_show_toast("🎬 콘텐츠 제작 완료  정신 %d→%d" % [mental_before, GameState.mental], Color("#3fb950"))
	_render_ap_actions()
	_refresh_all()

func _ap_write_resume():
	if not GameState.spend_ap():
		return
	var int_before = GameState.intelligence
	GameState.modify_stat("intelligence", 3)
	GameState.modify_hidden_stat("stress", 4)
	GameState.flags["resume_polished"] = true
	turn_action_log.append("✓ 🖊 자소서 작성 → 지력 %d→%d, 스트레스 +4" % [int_before, GameState.intelligence])
	_show_toast("🖊 자소서 완성 — 지력 %d → %d" % [int_before, GameState.intelligence], Color("#0f4c5c"))
	_render_ap_actions()
	_refresh_all()

func _ap_interview_prep():
	if not GameState.spend_ap():
		return
	var soc_before = GameState.social_skill
	GameState.modify_stat("social_skill", 2)
	GameState.modify_stat("luck", 1)
	GameState.flags["interview_practiced"] = true
	turn_action_log.append("✓ 🎯 모의 면접 준비 → 사회성 %d→%d" % [soc_before, GameState.social_skill])
	_show_toast("🎯 면접 준비 완료 — 사회성 %d → %d" % [soc_before, GameState.social_skill], Color("#0f3a5c"))
	_render_ap_actions()
	_refresh_all()

func _ap_move_housing():
	# AP 소비 없음 — 이사는 자금으로 하는 결정
	var result = GameState.upgrade_housing()
	if result["success"]:
		var info = result["housing"]
		var housing_name = info.get("name", "새 집")
		var expense = GameState.format_money(float(info.get("expense", 0.0)))
		turn_action_log.append("✓ 🏠 이사 → %s (월 %s)" % [housing_name, expense])
		AudioManager.play("housing_up")
		_show_toast("🏠 %s 이사 완료!" % housing_name, Color("#f0b429"))
	else:
		AudioManager.play("stat_down")
		_show_toast(result.get("message", "이사 실패"), Color("#ff4444"))
	_render_ap_actions()
	_refresh_all()

# ── RPG 해금 행동 함수들 ───────────────────────────────────────────────

func _ap_deep_study():
	if not GameState.spend_ap():
		return
	var int_before = GameState.intelligence
	GameState.modify_stat("intelligence", 8)
	AudioManager.play("stat_up")
	turn_action_log.append("✓ 📖 심화 독서 → 지력 %d→%d" % [int_before, GameState.intelligence])
	_show_toast("📖 심화 독서 — 지력 %d → %d" % [int_before, GameState.intelligence], Color("#1d4ed8"))
	_render_ap_actions()
	_refresh_all()

func _ap_market_analysis():
	# 무료 행동 — AP 소비 없음
	var forecast = investment_system.get_market_forecast()
	var cycle = str(GameState.market_context.get("cycle", "neutral"))
	var fg = int(GameState.market_context.get("fear_greed", 50))
	var crash_risk = float(GameState.market_context.get("crash_risk", 0.05))
	_open_modal("🔭 시장 분석")
	modal_body.add_child(_wrap_label("[행동력 소비 없음 — 이 행동은 무료입니다]", 12, "#00c896"))
	var sep = HSeparator.new(); sep.add_theme_color_override("color", Color("#252535")); modal_body.add_child(sep)
	modal_body.add_child(_label("📊 현재 시장 상황", 16, "#e8eaf0"))
	var cycle_kr = {"bull": "🟢 상승장", "bear": "🔴 하락장", "neutral": "⚪ 횡보"}.get(cycle, cycle)
	modal_body.add_child(_wrap_label("시장 국면: %s  |  공포/탐욕: %d/100  |  폭락 위험도: %.0f%%" % [cycle_kr, fg, crash_risk * 100.0], 14, "#f0b429"))
	var sep2 = HSeparator.new(); sep2.add_theme_color_override("color", Color("#252535")); modal_body.add_child(sep2)
	modal_body.add_child(_label("🔭 다음 달 예측", 15, "#5b9cf6"))
	modal_body.add_child(_wrap_label(forecast, 15, "#e8eaf0"))
	if crash_risk > 0.08:
		modal_body.add_child(_wrap_label("⚠ 폭락 경보: 레버리지 포지션 청산 검토. 현금 비중을 높이세요.", 13, "#ff4444"))
	var ok_btn = _button("확인", "#1e3a5f")
	ok_btn.pressed.connect(_close_modal)
	modal_body.add_child(ok_btn)
	GameState.add_log("🔭 시장 분석 — %s" % forecast, "market")

func _ap_leverage_invest():
	if GameState.action_points <= 0:
		_show_toast("⚡ 행동력이 없습니다", Color("#ff4444"))
		return
	_open_leverage_investments()

func _open_leverage_investments():
	_open_modal("⚡ 레버리지 투자")
	var ap_now = GameState.action_points
	modal_body.add_child(_wrap_label(
		"⚠ 고위험! 같은 자금으로 2배 포지션. 수익도 2배, 손실도 2배.\n    포지션 가치가 원금의 35% 이하 하락 시 강제 청산됩니다.",
		13, "#ef4444"))
	modal_body.add_child(_wrap_label("⚡ 행동력 %d/%d — 매수 실행 시 1 소비" % [ap_now, GameState.max_action_points],
		12, "#00c896" if ap_now > 0 else "#ff4444"))
	var sep = HSeparator.new(); sep.add_theme_color_override("color", Color("#252535")); modal_body.add_child(sep)
	for row in investment_system.get_asset_rows():
		var asset_id = row["id"]
		var price = float(row["price"])
		var hist: Array = GameState.price_history.get(asset_id, [])
		var sparkline = _price_sparkline(hist)
		var last_color = "#8892a4"
		if hist.size() >= 2:
			last_color = "#00c896" if float(hist[-1]) >= float(hist[-2]) else "#ff4444"
		var leveraged = GameState.portfolio.get(asset_id, {}).get("leveraged_amount", 0.0) > 0
		var lev_tag = " [⚡레버리지]" if leveraged else ""
		modal_body.add_child(_label("%s  %s  %s%s" % [row["name"], GameState.format_money(price), sparkline, lev_tag], 14, last_color))
		var buy_row = HBoxContainer.new()
		buy_row.add_theme_constant_override("separation", 6)
		for amount in [200_000, 500_000, 1_000_000]:
			var can_afford = GameState.money >= float(amount)
			var btn = _small_button("⚡%s×2" % GameState.format_money(amount), "#7f1d1d" if can_afford else "#64748b")
			btn.disabled = not can_afford
			btn.pressed.connect(Callable(self, "_on_leverage_buy").bind(asset_id, float(amount)))
			buy_row.add_child(btn)
		modal_body.add_child(buy_row)
		var sep2 = HSeparator.new(); sep2.add_theme_color_override("color", Color("#252535")); modal_body.add_child(sep2)

func _on_leverage_buy(asset_id: String, amount: float):
	if not GameState.spend_ap():
		_show_toast("⚡ 행동력이 없습니다. 이번 달 거래 불가", Color("#ff4444"))
		_close_modal()
		return
	AudioManager.play("money_gain")
	var result = investment_system.buy_asset_leveraged(asset_id, amount)
	if result.get("success", false):
		var asset_name = asset_id
		for data in DataRegistry.assets:
			if data.get("id", "") == asset_id:
				asset_name = data.get("name", asset_id)
				break
		turn_action_log.append("✓ ⚡ 레버리지 → %s ×2배  %s" % [asset_name, GameState.format_money(amount)])
		_close_modal()
		_refresh_all()
		_show_toast("⚡ 레버리지 매수 — %s ×2배 포지션 확보" % GameState.format_money(amount * 2.0), Color("#ef4444"))
	else:
		_show_toast(result.get("message", "오류"), Color("#ff4444"))

func _ap_vip_network():
	if not GameState.spend_ap():
		return
	var soc_before = GameState.social_skill
	var rep_before = GameState.reputation
	GameState.modify_stat("social_skill", 3)
	GameState.modify_hidden_stat("reputation", 2)
	var rel_names: Array = []
	for rel in GameState.relationships:
		var aff_before = int(rel.get("affection", 40))
		rel["affection"] = clamp(aff_before + 15, 0, 100)
		rel["trust"] = clamp(int(rel.get("trust", 30)) + 8, 0, 100)
		rel_names.append(str(rel.get("name", "?")))
	var rel_str = " · ".join(rel_names.slice(0, 3)) if not rel_names.is_empty() else "인맥 없음"
	GameState.add_log("VIP 인맥: 사회성 %d→%d, 평판 %d→%d (%s)" % [soc_before, GameState.social_skill, rep_before, GameState.reputation, rel_str], "relationship")
	turn_action_log.append("✓ 👔 VIP 인맥 → 사회성 %d→%d, 평판+2" % [soc_before, GameState.social_skill])
	_show_toast("👔 VIP 인맥 — 사회성 %d→%d, 모든 관계 친밀도 +15" % [soc_before, GameState.social_skill], Color("#a855f7"))
	GameState.stats_changed.emit()
	_render_ap_actions()
	_refresh_all()

func _open_jobs():
	_open_modal("💼 직업 선택")
	var current_job_id = GameState.current_job.get("id", "")
	# 경력 경로 안내
	var tier_labels = {1: "입문", 2: "성장", 3: "전문가", 4: "상위"}
	var current_tier = int(GameState.current_job.get("tier", 0))
	if current_tier > 0:
		var promo_count = int(GameState.current_job.get("promotion_count", 0))
		var max_promo = int(GameState.current_job.get("max_promotions", 3))
		modal_body.add_child(_wrap_label("현재: %s  Tier %d  승진 %d/%d회" % [GameState.current_job.get("name",""), current_tier, promo_count, max_promo], 13, "#f0b429"))
	modal_body.add_child(_wrap_label("지력 %d  |  사회성 %d  |  외모 %d" % [GameState.intelligence, GameState.social_skill, GameState.appearance], 12, "#5a6075"))
	# 취업 준비도 패널 (무직일 때만 표시)
	if GameState.current_job.is_empty():
		var resume_ok: bool = GameState.flags.get("resume_polished", false)
		var interview_ok: bool = GameState.flags.get("interview_practiced", false)
		var bonus_wp = (10 if resume_ok else 0) + (7 if interview_ok else 0)
		var resume_str = "✅ 이력서 완성 (+10)" if resume_ok else "✗ 이력서 미완성"
		var interview_str = "✅ 면접 연습 완료 (+7)" if interview_ok else "✗ 면접 연습 필요"
		var prep_color = "#00c896" if (resume_ok or interview_ok) else "#64748b"
		var prep_line = "📋 준비도  %s  |  %s" % [resume_str, interview_str]
		if bonus_wp > 0:
			prep_line += "  →  취업 후 업무능력 +%d 보너스" % bonus_wp
		modal_body.add_child(_wrap_label(prep_line, 12, prep_color))
	var sep = HSeparator.new()
	sep.add_theme_color_override("color", Color("#252535"))
	modal_body.add_child(sep)
	var prev_tier = 0
	for job in job_system.get_available_jobs():
		var tier = int(job.get("tier", 1))
		if tier != prev_tier:
			var tier_label = tier_labels.get(tier, "Tier %d" % tier)
			modal_body.add_child(_label("── Tier %d  %s ──" % [tier, tier_label], 12, "#5a6075"))
			prev_tier = tier

		# 잠긴 티어: 경력 조건 미충족
		if job.get("locked", false):
			var lock_btn = _button("🔒  %s" % job.get("name", ""), "#1e1e2e")
			lock_btn.disabled = true
			modal_body.add_child(lock_btn)
			modal_body.add_child(_wrap_label("  %s" % job.get("lock_reason", "경력 조건 미충족"), 11, "#3a3a5a"))
			continue

		var is_current = job.get("id", "") == current_job_id
		var eligible = job.get("eligible", false)
		var button_color = "#64748b"
		if is_current: button_color = "#0f5132"
		elif eligible: button_color = "#9a6700"
		var stress_val = int(job.get("stress_per_month", 5))
		var req = job.get("requirements", {})
		var req_parts: Array = []
		for k in req:
			match k:
				"min_intelligence": req_parts.append("지력 %d" % req[k])
				"min_appearance": req_parts.append("외모 %d" % req[k])
				"min_social_skill", "min_social": req_parts.append("사회성 %d" % req[k])
		var req_str = " · ".join(req_parts) if not req_parts.is_empty() else "제한 없음"
		var label = "%s  %s/월  스트레스 %d/월" % [job.get("name", ""), GameState.format_money(job.get("base_salary", 0)), stress_val]
		if is_current: label += "  ✓현재"
		var button = _button(label, button_color)
		button.disabled = not eligible and not is_current
		button.pressed.connect(Callable(self, "_on_job_selected").bind(job.get("id", "")))
		modal_body.add_child(button)
		var detail_color = "#00c896" if eligible else "#64748b"
		modal_body.add_child(_wrap_label("  조건: %s" % req_str, 11, detail_color))
		if not job.get("description", "").is_empty():
			modal_body.add_child(_wrap_label("  %s" % job.get("description", ""), 11, "#5a6075"))

func _open_investments():
	_open_modal("📈 투자 / 매수·매도")
	# 행동력 안내: 조회는 무료, 거래 시 소비
	var ap_now = GameState.action_points
	var ap_hint_color = "#00c896" if ap_now > 0 else "#ff4444"
	var ap_hint_text = "⚡ 행동력 %d/%d — 매수·매도 실행 시 1 소비 (조회는 무료)" % [ap_now, GameState.max_action_points]
	if ap_now <= 0:
		ap_hint_text = "⚡ 행동력 없음 — 이번 달 거래 불가. 다음 달에 다시 오세요."
	modal_body.add_child(_wrap_label(ap_hint_text, 12, ap_hint_color))
	# 초보자 가이드
	if GameState.investment_skill < 25:
		modal_body.add_child(_wrap_label(
			"💡 투자 입문  투자감각이 낮을수록 거래 수수료가 높아집니다.\n    리스크 ●●○○○ 이하 자산부터 소액(10만원)으로 시작해보세요.",
			13, "#f0b429"))
		var guide_sep = HSeparator.new()
		guide_sep.add_theme_color_override("color", Color("#252535"))
		modal_body.add_child(guide_sep)
	# 시장 분위기 표시
	var fg = int(GameState.market_context.get("fear_greed", 50))
	var cycle = str(GameState.market_context.get("cycle", "neutral"))
	var cycle_kr = {"bull": "🟢 상승장", "bear": "🔴 하락장", "neutral": "⚪ 횡보"}.get(cycle, cycle)
	var fg_color = "#ff4444" if fg < 30 else ("#00c896" if fg > 70 else "#f0b429")
	var filled = int(float(fg) / 10.0)
	var gauge = "█".repeat(filled) + "░".repeat(10 - filled)
	modal_body.add_child(_label("📊 시장 분위기 — %s  |  공포/탐욕: %d  [%s]" % [cycle_kr, fg, gauge], 14, fg_color))
	var sep_top = HSeparator.new()
	sep_top.add_theme_color_override("color", Color("#252535"))
	modal_body.add_child(sep_top)
	for row in investment_system.get_asset_rows():
		var asset_id = row["id"]
		var price = float(row["price"])
		var risk_str = "리스크 %d/5" % int(row.get("risk_level", 1))
		var hist: Array = GameState.price_history.get(asset_id, [])
		var sparkline = _price_sparkline(hist)
		var last_color = "#8892a4"
		if hist.size() >= 2:
			last_color = "#00c896" if float(hist[-1]) >= float(hist[-2]) else "#ff4444"
		modal_body.add_child(_label("%s  (%s)  현재가 %s  %s" % [row["name"], risk_str, GameState.format_money(price), sparkline], 14, last_color))
		var buy_row = HBoxContainer.new()
		buy_row.add_theme_constant_override("separation", 6)
		for amount in [100_000, 500_000, 1_000_000]:
			var can_afford = GameState.money >= amount
			var btn_color = "#00c896" if can_afford else "#64748b"
			var buy_btn = _small_button("+%s" % GameState.format_money(amount), btn_color)
			buy_btn.disabled = not can_afford
			buy_btn.pressed.connect(Callable(self, "_on_buy_asset").bind(asset_id, amount))
			buy_row.add_child(buy_btn)
		modal_body.add_child(buy_row)
		if GameState.portfolio.has(asset_id):
			var holding: Dictionary = GameState.portfolio[asset_id]
			var owned_val = float(holding.get("quantity", 0.0)) * price
			var avg_price = float(holding.get("avg_price", price))
			var profit_pct = (price - avg_price) / max(avg_price, 0.01) * 100.0
			var profit_color = "#00c896" if profit_pct >= 0 else "#ff4444"
			modal_body.add_child(_label("  보유 평가액 %s  |  평단 %s  |  수익률 %+.1f%%" % [GameState.format_money(owned_val), GameState.format_money(avg_price), profit_pct], 12, profit_color))
			var sell_row = HBoxContainer.new()
			sell_row.add_theme_constant_override("separation", 6)
			for sell_info in [["25%", 0.25], ["50%", 0.5], ["전량", 1.0]]:
				var sell_btn = _small_button("매도 %s" % sell_info[0], "#ff4444")
				sell_btn.pressed.connect(Callable(self, "_on_sell_asset").bind(asset_id, sell_info[1]))
				sell_row.add_child(sell_btn)
			modal_body.add_child(sell_row)
		var sep = HSeparator.new()
		sep.add_theme_color_override("color", Color("#252535"))
		modal_body.add_child(sep)

func _open_shop():
	_open_modal("🛍 상점")
	for item in inventory_system.get_shop_items():
		var price = float(item.get("price", 0))
		var can_buy = GameState.money >= price
		var btn_color = "#7c3aed" if can_buy else "#64748b"
		var icon = item.get("icon", "")
		var btn = _button("%s %s  —  %s" % [icon, item.get("name", ""), GameState.format_money(price)], btn_color)
		btn.disabled = not can_buy
		btn.pressed.connect(Callable(self, "_on_shop_item").bind(item.get("id", "")))
		modal_body.add_child(btn)
		# 효과 요약 표시
		var effect_parts: Array = []
		for k in item.get("effects", {}):
			var v = int(item["effects"][k])
			var sign = "+" if v >= 0 else ""
			effect_parts.append("%s %s%d" % [_stat_name(k), sign, v])
		for k in item.get("passive_effects", {}):
			var v = int(item["passive_effects"][k])
			var sign = "+" if v >= 0 else ""
			effect_parts.append("매달 %s %s%d" % [_stat_name(k), sign, v])
		var one_time = bool(item.get("one_time", true))
		var use_type = "사용 시 소모" if one_time else "보유 지속 효과"
		if not effect_parts.is_empty():
			modal_body.add_child(_wrap_label("  ▸ %s  [%s]" % [", ".join(effect_parts), use_type], 12, "#00c896"))
		if not item.get("description", "").is_empty():
			modal_body.add_child(_wrap_label("  %s" % item.get("description", ""), 12, "#5a6075"))

func _on_save_pressed():
	SaveManager.save_game(1)
	GameState.add_log("게임 저장 완료", "system")
	_show_toast("💾 저장 완료", Color("#00c896"))

func _on_job_selected(job_id):
	var had_resume = GameState.flags.get("resume_polished", false)
	var had_interview = GameState.flags.get("interview_practiced", false)
	job_system.apply_for_job(job_id)
	var job_name = GameState.current_job.get("name", "직업 변경")
	var prep_bonus = (10 if had_resume else 0) + (7 if had_interview else 0)
	var prep_note = ("  (준비 보너스 +%d 업무능력)" % prep_bonus) if prep_bonus > 0 else ""
	# 구직 로그 항목 갱신
	for i in range(turn_action_log.size() - 1, -1, -1):
		if turn_action_log[i].begins_with("✓ 💼"):
			turn_action_log[i] = "✓ 💼 구직활동 → %s 취업%s" % [job_name, prep_note]
			break
	_close_modal()
	_refresh_all()
	var toast_msg = "💼 취업! %s%s" % [job_name, prep_note]
	_show_toast(toast_msg, Color("#fbbf24"))

func _on_buy_asset(asset_id, amount):
	if not GameState.spend_ap():
		_show_toast("⚡ 행동력이 없습니다. 이번 달 거래 불가", Color("#ff4444"))
		_close_modal()
		return
	AudioManager.play("money_gain")
	investment_system.buy_asset(asset_id, float(amount))
	var asset_name = asset_id
	for data in DataRegistry.assets:
		if data.get("id", "") == asset_id:
			asset_name = data.get("name", asset_id)
			break
	turn_action_log.append("✓ 📈 투자 → %s 매수 %s" % [asset_name, GameState.format_money(amount)])
	_close_modal()
	_refresh_all()
	_show_toast("📈 매수 완료 %s" % GameState.format_money(amount), Color("#00c896"))

func _on_sell_asset(asset_id, ratio):
	if not GameState.spend_ap():
		_show_toast("⚡ 행동력이 없습니다. 이번 달 거래 불가", Color("#ff4444"))
		_close_modal()
		return
	AudioManager.play("money_loss")
	investment_system.sell_asset(asset_id, float(ratio))
	var asset_name = asset_id
	for data in DataRegistry.assets:
		if data.get("id", "") == asset_id:
			asset_name = data.get("name", asset_id)
			break
	turn_action_log.append("✓ 📈 투자 → %s 매도" % asset_name)
	_close_modal()
	_refresh_all()
	_show_toast("📉 매도 완료", Color("#ff4444"))

func _on_shop_item(item_id):
	inventory_system.purchase_item(item_id)
	_close_modal()
	_refresh_all()
	_show_toast("🛒 아이템 구매 완료", Color("#d8b4fe"))

func _on_use_item(item_id):
	inventory_system.use_item(item_id)
	_refresh_all()
	_show_toast("✨ 아이템 사용", Color("#fbbf24"))

func _open_system_menu():
	_open_modal("≡ 시스템")

	_build_volume_sliders(modal_body)

	var sep = HSeparator.new()
	sep.modulate = Color("#2a2a3a")
	modal_body.add_child(sep)

	var menu_btn2 = _button("🏠  메인 메뉴로", "#1e3a5f")
	menu_btn2.pressed.connect(_go_to_menu)
	modal_body.add_child(menu_btn2)

	var quit_btn = _button("🚪  게임 종료", "#5a1a1a")
	quit_btn.pressed.connect(func():
		SaveManager.autosave()
		get_tree().quit()
	)
	modal_body.add_child(quit_btn)

	var cancel_btn = _button("✕  취소", "#2a2a3a")
	cancel_btn.pressed.connect(_close_modal)
	modal_body.add_child(cancel_btn)

func _build_volume_sliders(parent: Control):
	var _make_row = func(label_text: String, init_val: float, on_change: Callable):
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		parent.add_child(row)
		var lbl = Label.new()
		lbl.text = label_text
		lbl.add_theme_font_size_override("font_size", 13)
		lbl.add_theme_color_override("font_color", Color("#8892a4"))
		lbl.custom_minimum_size = Vector2(48, 0)
		row.add_child(lbl)
		var slider = HSlider.new()
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.05
		slider.value = init_val
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.custom_minimum_size = Vector2(0, 24)
		slider.value_changed.connect(on_change)
		row.add_child(slider)
		var pct = Label.new()
		pct.text = "%d%%" % int(init_val * 100)
		pct.add_theme_font_size_override("font_size", 12)
		pct.add_theme_color_override("font_color", Color("#5a6075"))
		pct.custom_minimum_size = Vector2(36, 0)
		pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(pct)
		slider.value_changed.connect(func(v): pct.text = "%d%%" % int(v * 100))

	_make_row.call("🎵 BGM", AudioManager.bgm_volume, func(v): AudioManager.set_bgm_volume(v))
	_make_row.call("🔊 SFX", AudioManager.master_volume, func(v): AudioManager.set_sfx_volume(v))

func _go_to_menu():
	SaveManager.autosave()
	SceneTransition.go("res://scenes/StartMenu.tscn")

func _open_modal(title):
	_clear_box(modal_body)
	modal_title_label.text = title
	modal_layer.visible = true
	modal_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	# 스크롤/크기/위치 기본값 복원
	if modal_scroll:
		modal_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		modal_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		modal_scroll.custom_minimum_size = Vector2(0, 420)
	if modal_panel:
		modal_panel.custom_minimum_size = Vector2(640, 560)
		modal_panel.offset_left   = -320
		modal_panel.offset_right  =  320
		modal_panel.offset_top    = -280
		modal_panel.offset_bottom =  280
	AudioManager.play("open_modal")

func _close_modal():
	modal_layer.visible = false
	modal_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioManager.play("close")
	if _pending_month_summary:
		_pending_month_summary = false
		_begin_month()
		_refresh_all()
		return
	if current_event.is_empty() and not GameState.is_game_over:
		_render_ap_actions()

func _show_ending(ending_id):
	_open_modal("🏁 엔딩")
	var ending = EndingSystem.get_ending(ending_id)
	var grade = ending.get("grade", "?")
	var grade_colors = {"S": "#f0b429", "A": "#34d399", "B": "#5b9cf6", "C": "#8892a4", "F": "#ff4444"}
	var grade_emojis = {"S": "🏆", "A": "🌟", "B": "✨", "C": "📋", "F": "💀"}
	var grade_color = grade_colors.get(grade, "#ffffff")
	var grade_emoji = grade_emojis.get(grade, "")
	# 등급 헤더 행
	var ending_row = HBoxContainer.new()
	ending_row.add_theme_constant_override("separation", 14)
	modal_body.add_child(ending_row)
	ending_row.add_child(_label(grade_emoji, 40, "#ffffff"))
	var ending_text_col = VBoxContainer.new()
	ending_text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ending_row.add_child(ending_text_col)
	ending_text_col.add_child(_label(ending.get("title", "엔딩"), 24, "#f0b429"))
	ending_text_col.add_child(_label("등급  %s" % grade, 16, grade_color))
	var ending_sep = HSeparator.new()
	ending_sep.add_theme_color_override("color", Color("#252535"))
	modal_body.add_child(ending_sep)
	var body = RichTextLabel.new()
	body.bbcode_enabled = false
	body.text = "%s\n\n최종 자산: %s\n최종 나이: %d세\n총 턴: %d\n점수: %d" % [
		ending.get("description", ""),
		GameState.format_money(GameState.get_total_asset_value()),
		GameState.age,
		GameState.turn,
		EndingSystem.get_score()
	]
	body.custom_minimum_size = Vector2(560, 200)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_color_override("default_color", Color("#8892a4"))
	body.add_theme_font_size_override("normal_font_size", 15)
	modal_body.add_child(body)
	var restart_btn = _button("새 런 시작", "#00c896")
	restart_btn.pressed.connect(_restart_run)
	modal_body.add_child(restart_btn)
	var menu_btn = _button("메인 메뉴", "#64748b")
	menu_btn.pressed.connect(_go_to_menu)
	modal_body.add_child(menu_btn)

func _show_month_summary(snap: Dictionary):
	_pending_month_summary = true
	_open_modal("📊 %s 결산" % snap["date"])
	# 결산: 스크롤바만 숨김 (넘치면 마우스 휠로 접근)
	if modal_scroll:
		modal_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	# 결산은 가운데 모달, 크기를 약간 더 넉넉하게
	if modal_panel:
		modal_panel.custom_minimum_size = Vector2(660, 580)
		modal_panel.offset_left   = -330
		modal_panel.offset_right  =  330
		modal_panel.offset_top    = -290
		modal_panel.offset_bottom =  290

	# ── 이달 등급 (한 줄) ──────────────────────────
	var grade = _calc_month_grade(snap)
	var grade_row = HBoxContainer.new()
	grade_row.add_theme_constant_override("separation", 10)
	modal_body.add_child(grade_row)
	var emoji_lbl = Label.new()
	emoji_lbl.text = grade["emoji"]
	emoji_lbl.add_theme_font_size_override("font_size", 26)
	grade_row.add_child(emoji_lbl)
	var grade_col = VBoxContainer.new()
	grade_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grade_col.add_theme_constant_override("separation", 2)
	grade_row.add_child(grade_col)
	var grade_title = Label.new()
	grade_title.text = grade["title"]
	grade_title.add_theme_font_size_override("font_size", 15)
	grade_title.add_theme_color_override("font_color", Color(grade["color"]))
	grade_col.add_child(grade_title)
	var grade_msg = Label.new()
	grade_msg.text = grade["msg"]
	grade_msg.add_theme_font_size_override("font_size", 11)
	grade_msg.add_theme_color_override("font_color", Color("#5a6075"))
	grade_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	grade_msg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grade_col.add_child(grade_msg)

	var div = HSeparator.new()
	div.add_theme_color_override("color", Color("#252535"))
	modal_body.add_child(div)

	# ── 재정 요약 (2행 그리드) ─────────────────────
	var income  = float(snap["monthly_income"])
	var expense = float(snap["fixed_expense"])
	var net     = income - expense
	var net_color  = "#00c896" if net >= 0 else "#ff4444"
	var assets_now = GameState.get_total_asset_value()
	var asset_delta = assets_now - float(snap["assets_before"])
	var asset_color = "#00c896" if asset_delta >= 0 else "#ff4444"
	var asset_sign  = "+" if asset_delta >= 0 else ""

	# 행1: 수입 / 지출 / 순이익
	var fin_row1 = HBoxContainer.new()
	fin_row1.add_theme_constant_override("separation", 0)
	modal_body.add_child(fin_row1)
	var _fc = func(label: String, value: String, color: String):
		var cell = VBoxContainer.new()
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.add_theme_constant_override("separation", 1)
		var lbl = Label.new()
		lbl.text = label
		lbl.add_theme_font_size_override("font_size", 10)
		lbl.add_theme_color_override("font_color", Color("#4a5568"))
		cell.add_child(lbl)
		var val = Label.new()
		val.text = value
		val.add_theme_font_size_override("font_size", 14)
		val.add_theme_color_override("font_color", Color(color))
		cell.add_child(val)
		return cell
	fin_row1.add_child(_fc.call("월급 수입", GameState.format_money(income), "#00c896"))
	if bool(snap.get("subsidy", false)):
		fin_row1.add_child(_fc.call("지원금", "+30만원", "#5b9cf6"))
	fin_row1.add_child(_fc.call("고정 지출", "-%s" % GameState.format_money(expense), "#ff6b6b"))
	fin_row1.add_child(_fc.call("순이익", GameState.format_money(net), net_color))

	# 행2: 자산변화 / 총자산
	var fin_row2 = HBoxContainer.new()
	fin_row2.add_theme_constant_override("separation", 0)
	modal_body.add_child(fin_row2)
	fin_row2.add_child(_fc.call("자산 변화", "%s%s" % [asset_sign, GameState.format_money(asset_delta)], asset_color))
	fin_row2.add_child(_fc.call("현재 총자산", GameState.format_money(assets_now), "#8892a4"))

	# ── 행동 요약 ─────────────────────────────────
	if not snap["actions"].is_empty():
		var div2 = HSeparator.new()
		div2.add_theme_color_override("color", Color("#252535"))
		modal_body.add_child(div2)
		for entry in snap["actions"]:
			modal_body.add_child(_wrap_label(entry, 12, "#8892a4"))

	# ── 스탯 변화 (한 줄) ─────────────────────────
	var stat_parts: Array = []
	var stat_map = [["health", "건강"], ["mental", "정신력"], ["stress", "스트레스"]]
	for pair in stat_map:
		if GameState.get(pair[0]) != int(snap.get(pair[0] + "_before", GameState.get(pair[0]))):
			var d = GameState.get(pair[0]) - int(snap[pair[0] + "_before"])
			stat_parts.append("%s %s%d" % [pair[1], "+" if d > 0 else "", d])
	if not stat_parts.is_empty():
		modal_body.add_child(_wrap_label("스탯  " + "  ".join(stat_parts), 12, "#5a6075"))

	# ── 조언 ──────────────────────────────────────
	var advice = _get_month_advice()
	if not advice.is_empty():
		var div3 = HSeparator.new()
		div3.add_theme_color_override("color", Color("#252535"))
		modal_body.add_child(div3)
		modal_body.add_child(_wrap_label(advice, 12, "#8892a4"))

	# ── 강남드림 달성률 진행 바 ──────────────────────
	var goal = 2_000_000_000.0
	var pct = clamp(assets_now / goal, 0.0, 1.0)
	var filled_blocks = int(pct * 20)
	var bar_str = "█".repeat(filled_blocks) + "░".repeat(20 - filled_blocks)
	var pct_disp = "%.1f%%" % (pct * 100.0)
	var bar_color = "#00c896" if pct >= 0.5 else ("#f0b429" if pct >= 0.2 else "#5b9cf6")
	modal_body.add_child(_wrap_label(
		"🎯 강남드림  %s  %s  (%s)" % [bar_str, GameState.format_money(assets_now), pct_disp],
		11, bar_color))

	# ── 목표 힌트 ─────────────────────────────────
	var ms = _next_milestone_hint(assets_now)
	if not ms.is_empty():
		modal_body.add_child(_wrap_label(ms, 11, "#3fb950"))

	# ── 확인 버튼 (하단) ──────────────────────────
	var div4 = HSeparator.new()
	div4.add_theme_color_override("color", Color("#252535"))
	modal_body.add_child(div4)
	var confirm_btn = _button("다음 달 시작 →", "#1f6feb")
	confirm_btn.pressed.connect(_close_modal)
	modal_body.add_child(confirm_btn)


func _check_milestones():
	var total = GameState.get_total_asset_value()
	var milestones = [
		{"id": "10m",  "amount": 10_000_000.0,    "msg": "💰 자산 1천만원 돌파!",  "color": "#fbbf24"},
		{"id": "50m",  "amount": 50_000_000.0,    "msg": "💰 자산 5천만원 돌파!",  "color": "#fbbf24"},
		{"id": "100m", "amount": 100_000_000.0,   "msg": "🏆 자산 1억 돌파! 진짜 시작이다.", "color": "#f0b429"},
		{"id": "500m", "amount": 500_000_000.0,   "msg": "🔥 자산 5억! 강남이 보인다.",      "color": "#f0b429"},
		{"id": "1b",   "amount": 1_000_000_000.0, "msg": "⚡ 자산 10억! 부자의 문턱.",       "color": "#00c896"},
	]
	for m in milestones:
		if total >= m["amount"] and not GameState.milestones_reached.has(m["id"]):
			GameState.milestones_reached[m["id"]] = true
			GameState.add_log(m["msg"], "system")
			_show_toast(m["msg"], Color(m["color"]))
			AudioManager.play("money_big")
			# 기쁜 표정 2초간 표시
			GameState.flags["just_hit_milestone"] = true
			_update_portrait()
			await get_tree().create_timer(2.0).timeout
			GameState.flags["just_hit_milestone"] = false
			_update_portrait()

func _on_rival_message(message: String, color: String):
	_show_toast(message, Color(color))
	GameState.add_log(message, "system")

func _on_promoted(job: Dictionary, bonus: float):
	var msg = "⬆ 승진! %s  월급 +%s" % [job.get("name",""), GameState.format_money(bonus)]
	_show_toast(msg, Color("#fbbf24"))
	AudioManager.play("housing_up")

func _summary_row(label_text: String, value_text: String, value_color: String) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var lbl = _label(label_text, 13, "#5a6075")
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl)
	var val = _label(value_text, 13, value_color)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(val)
	return row

func _price_sparkline(history: Array) -> String:
	if history.size() < 2:
		return "——"
	var min_p = history.min()
	var max_p = history.max()
	var range_p = max_p - min_p
	if range_p < 0.001:
		return "━━━━━━"
	var blocks = ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"]
	var result = ""
	for p in history:
		var idx = int((float(p) - min_p) / range_p * 7.0)
		idx = clamp(idx, 0, 7)
		result += blocks[idx]
	return result

func _restart_run():
	_close_modal()
	GameState.new_game()
	investment_system.initialize()
	_begin_month()
	_refresh_all()

func _tab_box(tabs, title):
	var scroll = ScrollContainer.new()
	scroll.name = title
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tabs.add_child(scroll)
	var box = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 6)
	scroll.add_child(box)
	return box

func _clear_box(box):
	for child in box.get_children():
		child.queue_free()

func _panel(bg, border):
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(bg)
	style.border_color = Color(border)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", style)
	return panel

func _label(text, size, color):
	var label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.clip_text = true
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color(color))
	return label

func _wrap_label(text, size, color):
	var label = _label(text, size, color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = false
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

func _button(text, color):
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 42)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(color)
	normal.set_corner_radius_all(5)
	var hover = normal.duplicate()
	hover.bg_color = Color(color).lightened(0.14)
	var pressed_style = normal.duplicate()
	pressed_style.bg_color = Color(color).darkened(0.1)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_color_override("font_color", Color("#ffffff"))
	button.pressed.connect(func(): AudioManager.play("click"))
	return button

func _small_button(text, color):
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 32)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(color)
	normal.set_corner_radius_all(4)
	var hover = normal.duplicate()
	hover.bg_color = Color(color).lightened(0.15)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_color_override("font_color", Color("#ffffff"))
	button.add_theme_font_size_override("font_size", 13)
	return button

func _stat_name(key):
	return {
		"housing": "주거",
		"job": "직업",
		"health": "건강",
		"mental": "정신",
		"stress": "스트레스",
		"intelligence": "지능",
		"social_skill": "사회성",
		"appearance": "외모",
		"investment_skill": "투자감각",
		"luck": "운",
		"reputation": "평판",
		"asset": "총자산",
	}.get(key, key)

func _rel_effect_hint(type_str: String, affection: int, trust: int) -> String:
	match type_str:
		"romantic":
			if affection >= 80: return "매달 정신력 +2, 스트레스 -4, 생활비 분담 기회"
			elif affection >= 60: return "매달 정신력 +1, 스트레스 -2"
			else: return "매달 스트레스 -1"
		"mentor":
			if affection >= 75 and trust >= 60: return "매달 투자감각 +1, 지력 +1, 투자 인사이트 수익"
			elif affection >= 55: return "매달 투자감각/지력 성장 기회"
			else: return "매달 지력 성장 기회"
		"business":
			if affection >= 75 and trust >= 70: return "매달 평판 +2, 수익 공유 기회"
			elif affection >= 55: return "매달 평판 +1, 소액 수익 기회"
			else: return "매달 평판 성장 기회"
		"family":
			if affection >= 70: return "매달 정신력 +2, 스트레스 -2, 위기 시 지원금"
			elif affection >= 50: return "매달 정신력 +1, 스트레스 -1"
		"friends":
			if affection >= 70: return "매달 스트레스 -3, 사회성 성장 기회"
			elif affection >= 50: return "매달 스트레스 -1, 사회성 성장 기회"
	return ""

func _hint_box() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#1a2a0a")
	s.border_color = Color("#4a7a1a")
	s.set_border_width_all(1)
	s.set_corner_radius_all(5)
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s

func _random_topic(news):
	var topics: Array = news.get("topics", ["시장"])
	if topics.is_empty():
		return "시장"
	return topics.pick_random()

# ── 다음 마일스톤 힌트 ────────────────────────────────
func _next_milestone_hint(total: float) -> String:
	var milestones: Array = [
		[5_000_000.0,     "첫 500만원"],
		[8_000_000.0,     "🏠 원룸 이사 구간 — 현금 700만 있으면 이사 가능"],
		[10_000_000.0,    "자산 1천만원"],
		[35_000_000.0,    "🏢 아파트 이사 구간 — 현금 3500만 있으면 이사 가능"],
		[50_000_000.0,    "자산 5천만원"],
		[100_000_000.0,   "자산 1억 돌파"],
		[120_000_000.0,   "🏙 강남 이사 구간 — 현금 1.2억 있으면 이사 가능"],
		[500_000_000.0,   "자산 5억"],
		[1_000_000_000.0, "자산 10억"],
		[2_000_000_000.0, "🏙 강남드림 달성!"],
	]
	for m in milestones:
		var target: float = float(m[0])
		if total < target:
			var needed = target - total
			var pct: int = int(total / target * 100.0)
			return "🎯  %s  까지  %s 남음  [%d%%]" % [str(m[1]), GameState.format_money(needed), pct]
	return ""

# ── 월 등급 계산 ─────────────────────────────────────
func _calc_month_grade(snap: Dictionary) -> Dictionary:
	var net = float(snap["monthly_income"]) - float(snap["fixed_expense"])
	var asset_delta = GameState.get_total_asset_value() - float(snap["assets_before"])
	var total = GameState.get_total_asset_value()
	var t = GameState.turn
	if asset_delta >= 10_000_000.0:
		var big_msgs = [
			"자산이 %s 늘었습니다. 이 흐름을 유지하세요." % GameState.format_money(asset_delta),
			"투자가 빛을 발하고 있습니다. 포지션을 점검하세요.",
			"이런 달이 쌓이면 강남드림이 가까워집니다.",
		]
		return {"emoji": "🏆", "title": "대박 달!", "msg": big_msgs[t % big_msgs.size()], "color": "#fbbf24"}
	elif asset_delta >= 2_000_000.0 and net >= 0.0:
		var good_msgs = [
			"흑자에 자산 성장까지. 좋은 한 달이었습니다.",
			"수입과 투자 모두 순조롭습니다.",
			"꾸준히 이 방향으로 가면 됩니다.",
		]
		return {"emoji": "✨", "title": "잘 했습니다", "msg": good_msgs[t % good_msgs.size()], "color": "#00c896"}
	elif net >= 0.0:
		if total < 5_000_000.0:
			return {"emoji": "📊", "title": "버티는 달", "msg": "아직 초반입니다. 취업과 저축이 최우선입니다.", "color": "#8892a4"}
		return {"emoji": "📊", "title": "평범한 달", "msg": "흑자 유지 중. 투자로 자산을 늘릴 타이밍을 찾아보세요.", "color": "#8892a4"}
	elif GameState.health > 55 and GameState.mental > 55:
		var tough_msgs = [
			"재정은 적자지만 건강하게 버텼습니다. 곧 나아질 거예요.",
			"어려운 달이었지만 쓰러지지 않았습니다.",
			"이 경험이 더 단단하게 만들어줄 겁니다.",
		]
		return {"emoji": "💪", "title": "힘든 달", "msg": tough_msgs[t % tough_msgs.size()], "color": "#f0b429"}
	else:
		var crisis_msgs = [
			"재정과 체력 모두 위험합니다. 전략을 바꾸세요.",
			"지금 방향을 바꾸지 않으면 무너집니다.",
			"운동이나 명상으로 정신력부터 회복하세요.",
		]
		return {"emoji": "😰", "title": "위기 상황", "msg": crisis_msgs[t % crisis_msgs.size()], "color": "#ff4444"}

# ── 다음 달 조언 ─────────────────────────────────────
func _update_event_bg():
	if not event_bg:
		return
	var bg_path = _get_bg_for_event(current_event)
	var tex = load(bg_path)
	if tex:
		event_bg.texture = tex

func _get_bg_for_event(ev: Dictionary) -> String:
	# 이벤트 태그 기반 배경 결정
	var tags = ev.get("tags", [])
	if "job" in tags or "work" in tags or "office" in tags:
		return BG_OFFICE
	if "social" in tags or "commute" in tags or "subway" in tags:
		return BG_SUBWAY
	if "night" in tags or "city" in tags or "stress" in tags:
		return BG_DEFAULT  # seoul_rainy_street
	# 이벤트 없을 때는 주거 기반
	return BG_PATHS.get(GameState.housing, BG_DEFAULT)

func _update_portrait():
	if not character_portrait:
		return
	var portrait_path = _get_portrait_path()
	var tex = load(portrait_path)
	if tex:
		character_portrait.texture = tex

func _get_portrait_path() -> String:
	# 자산 마일스톤 달성 직후 — 기쁨
	if GameState.flags.get("just_hit_milestone", false):
		return PORTRAIT_HAPPY
	# 스트레스 높거나 건강/정신 위험 — 피로
	if GameState.stress >= 65 or GameState.health <= 35 or GameState.mental <= 35:
		return PORTRAIT_TIRED
	# 직장 있고 안정적 — 결의
	if not GameState.current_job.is_empty() and GameState.stress < 45 and GameState.health >= 60:
		return PORTRAIT_DETERMINED
	return PORTRAIT_NEUTRAL

func _get_month_advice() -> String:
	if GameState.health <= 40:
		return "⚠ 건강 %d — 위험합니다. 당장 [운동]을 하세요. 건강이 0이 되면 '과로 엔딩'으로 종료됩니다." % GameState.health
	if GameState.mental <= 40:
		return "⚠ 정신력 %d — 위험합니다. [명상]으로 회복하세요. 0이 되면 '정신 붕괴 엔딩'입니다." % GameState.mental
	if GameState.stress >= 60:
		return "스트레스 %d — 60 이상이면 건강과 정신이 매달 깎입니다. [운동]이나 [명상]으로 낮추세요." % GameState.stress
	if GameState.money < 500_000:
		return "💸 잔고 %s — 위험 수위입니다. 알바나 투자로 당장 수입을 늘리세요." % GameState.format_money(GameState.money)
	if GameState.current_job.is_empty():
		return "직업이 없으면 매달 수입이 0원입니다. 생활비만큼 계속 줄어들어요. [구직활동]을 최우선으로 하세요."
	if GameState.money < 0:
		return "잔고가 마이너스입니다 (%s). 알바나 투자 수익으로 메우세요. 빚이 3천만원을 넘으면 파산 엔딩입니다." % GameState.format_money(GameState.money)
	if GameState.can_upgrade_housing() and GameState.housing == "gosiwon":
		var next_id = str(GameState.get_housing_info().get("next", ""))
		var next_info = GameState.HOUSING_DATA.get(next_id, {})
		return "🏠 %s으로 이사할 자금이 생겼습니다 (현금 %s). 이사하면 스트레스·정신력 패시브가 개선돼요!" % [
			next_info.get("name", "원룸"), GameState.format_money(GameState.money)]
	if GameState.investment_skill < 20 and GameState.get_total_asset_value() > 2_000_000.0 and GameState.turn > 4:
		return "투자감각이 아직 낮습니다 (%d). [재테크 공부]로 올리면 투자 수익률이 올라갑니다." % GameState.investment_skill
	if not GameState.current_job.is_empty():
		var tenure = GameState.job_tenure
		var promo_count = int(GameState.current_job.get("promotion_count", 0))
		var max_promo = int(GameState.current_job.get("max_promotions", 3))
		if tenure >= 5 and promo_count < max_promo and GameState.work_performance >= 55:
			return "근속 %d개월, 업무 성과 %d입니다. 승진 기회가 다가오고 있어요. 꾸준히 유지하세요." % [tenure, GameState.work_performance]
	return ""

func _check_title_unlocks():
	var newly = MetaProgression.check_and_unlock_titles()
	var rare_colors = {"common": "#8892a4", "uncommon": "#5b9cf6", "rare": "#f0b429", "legendary": "#f97316"}
	for t in newly:
		var color = rare_colors.get(t.get("rare", "common"), "#8892a4")
		_show_toast("🏆 칭호 해금! 「%s」" % t.get("name", ""), Color(color))
		GameState.add_log("🏆 칭호 해금: %s" % t.get("name", ""), "system")

func _open_title_collection():
	_open_modal("🏆 칭호 도감")
	if modal_panel:
		modal_panel.custom_minimum_size = Vector2(680, 600)
		modal_panel.offset_left  = -340
		modal_panel.offset_right =  340
		modal_panel.offset_top   = -300
		modal_panel.offset_bottom =  300

	var unlocked = MetaProgression.get_unlocked_titles()
	var total = MetaProgression.ALL_TITLES.size()
	modal_body.add_child(_wrap_label(
		"해금 %d / %d  —  플레이를 거듭할수록 칭호가 늘어납니다." % [unlocked.size(), total],
		13, "#8892a4"))

	var rare_colors = {"common": "#8892a4", "uncommon": "#5b9cf6", "rare": "#f0b429", "legendary": "#f97316"}
	var rare_labels = {"common": "일반", "uncommon": "희귀", "rare": "레어", "legendary": "전설"}

	for cat in ["주거", "직업", "투자", "성향", "관계", "생활", "자산", "메타"]:
		var cat_titles: Array = []
		for t in MetaProgression.ALL_TITLES:
			if t.get("cat", "") == cat:
				cat_titles.append(t)
		if cat_titles.is_empty():
			continue
		var sep = HSeparator.new()
		sep.add_theme_color_override("color", Color("#252535"))
		modal_body.add_child(sep)
		modal_body.add_child(_label("── %s ──" % cat, 12, "#5a6075"))
		for t in cat_titles:
			var tid: String = t["id"]
			var is_unlocked: bool = unlocked.has(tid)
			var rare: String = t.get("rare", "common")
			var color = rare_colors.get(rare, "#8892a4") if is_unlocked else "#3a3a4a"
			var name_text: String = t.get("name", tid) if is_unlocked else "???"
			var row = HBoxContainer.new()
			row.add_theme_constant_override("separation", 6)
			var icon = "🏆" if is_unlocked else "🔒"
			var lbl = _label("%s  %s  [%s]" % [icon, name_text, rare_labels.get(rare, rare)], 13, color)
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(lbl)
			modal_body.add_child(row)
			if is_unlocked:
				modal_body.add_child(_wrap_label("    %s" % t.get("desc", ""), 11, "#5a6075"))

	var sep_end = HSeparator.new()
	sep_end.add_theme_color_override("color", Color("#252535"))
	modal_body.add_child(sep_end)
	var close_btn = _button("닫기", "#2a2a3a")
	close_btn.pressed.connect(_close_modal)
	modal_body.add_child(close_btn)

func _show_tutorial_intro():
	_open_modal("🏙 강남드림에 오신 걸 환영해요")

	modal_body.add_child(_wrap_label(
		"서울 고시원, 통장 100만원.\n65세까지 자산 20억을 만드는 게임입니다.",
		15, "#e8eaf0"))

	var sep0 = HSeparator.new()
	sep0.add_theme_color_override("color", Color("#252535"))
	modal_body.add_child(sep0)

	# 한 달의 흐름
	modal_body.add_child(_label("📅  한 달의 흐름", 13, "#f0b429"))
	modal_body.add_child(_wrap_label(
		"⚡ AP 3개 사용해 행동 선택  →  ▶ 다음 달로  →  이벤트 발생  →  반복",
		12, "#8892a4"))

	var sep1 = HSeparator.new()
	sep1.add_theme_color_override("color", Color("#252535"))
	modal_body.add_child(sep1)

	# 생존 법칙
	modal_body.add_child(_label("⚠  생존 법칙", 13, "#f0b429"))
	var rules = [
		["💼 취업이 먼저", "수입 없이는 2개월 안에 파산해요. 첫 달에 꼭 취업하세요."],
		["❤️ 건강·정신 = 0", "어느 하나라도 0이 되면 즉시 게임오버입니다."],
		["📈 투자는 취업 후", "첫 월급을 받으면 투자·상점이 열려요. 그 전엔 불가능해요."],
		["🏠 이사로 버프", "자산이 쌓이면 고시원→원룸→아파트→강남으로 이사하세요."],
	]
	for rule in rules:
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		modal_body.add_child(row)
		var key_lbl = _label(rule[0], 12, "#cbd5e1")
		key_lbl.custom_minimum_size = Vector2(120, 0)
		row.add_child(key_lbl)
		row.add_child(_wrap_label(rule[1], 12, "#64748b"))

	var sep2 = HSeparator.new()
	sep2.add_theme_color_override("color", Color("#252535"))
	modal_body.add_child(sep2)

	modal_body.add_child(_wrap_label(
		"🎯  목표: 총자산 20억 = 강남드림 달성!\n    65세(턴 540)까지 버텨보세요.",
		13, "#00c896"))

	var start_btn = _button("서울 생활 시작 →", "#1f6feb")
	start_btn.pressed.connect(_close_modal)
	modal_body.add_child(start_btn)
