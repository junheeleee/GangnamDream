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
var modal_body: VBoxContainer
var modal_title_label: Label
var next_button: Button
var shop_button: Button
var _toast_container: VBoxContainer
var event_bg: TextureRect
var character_portrait: TextureRect

const BG_PATHS = {
	"gosiwon":   "res://assets/backgrounds/goshiwon_room.png",
	"oneroom":   "res://assets/backgrounds/oneroom_apartment.png",
	"apartment": "res://assets/backgrounds/gangnam_apartment.png",
}
const BG_DEFAULT = "res://assets/backgrounds/seoul_rainy_street.png"
const PORTRAIT_NEUTRAL = "res://assets/characters/main_character_neutral_goshiwon.png"

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

func _build_ui():
	var bg = ColorRect.new()
	bg.color = Color("#0c0c10")
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var root = VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 10
	root.offset_top = 10
	root.offset_right = -10
	root.offset_bottom = -10
	root.add_theme_constant_override("separation", 8)
	add_child(root)

	_build_top_bar(root)

	var main = HBoxContainer.new()
	main.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_theme_constant_override("separation", 8)
	root.add_child(main)
	_build_left_panel(main)
	_build_center_panel(main)
	_build_right_panel(main)
	_build_bottom_bar(root)
	_build_modal()
	_build_toast_layer()

func _build_top_bar(parent):
	var panel = _panel("#13131a", "#252535")
	panel.custom_minimum_size = Vector2(0, 52)
	parent.add_child(panel)
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 18)
	panel.add_child(row)
	var title = _label("강남드림", 22, "#e8eaf0")
	title.custom_minimum_size = Vector2(120, 0)
	row.add_child(title)
	for key in ["date", "age", "money", "asset", "progress", "market"]:
		var label = _label("", 14, "#8892a4")
		label.custom_minimum_size = Vector2(72, 0)
		label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		if key == "progress":
			label.custom_minimum_size = Vector2(180, 0)
			label.add_theme_color_override("font_color", Color("#3fb950"))
		if key == "market":
			label.custom_minimum_size = Vector2(160, 0)
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		top_labels[key] = label
		row.add_child(label)

func _build_left_panel(parent):
	var panel = _panel("#13131a", "#252535")
	panel.custom_minimum_size = Vector2(250, 0)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	# ── 캐릭터 초상화 ──
	character_portrait = TextureRect.new()
	character_portrait.custom_minimum_size = Vector2(0, 160)
	character_portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	character_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	character_portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	var portrait_tex = load(PORTRAIT_NEUTRAL)
	if portrait_tex:
		character_portrait.texture = portrait_tex
	box.add_child(character_portrait)

	box.add_child(_label("PLAYER", 15, "#5b9cf6"))
	for key in ["housing", "job", "health", "mental", "stress", "intelligence", "social_skill", "appearance", "investment_skill", "luck", "reputation", "asset"]:
		var row = HBoxContainer.new()
		box.add_child(row)
		var name_label = _label(_stat_name(key), 13, "#5a6075")
		name_label.custom_minimum_size = Vector2(86, 0)
		row.add_child(name_label)
		var value = _label("", 13, "#e8eaf0")
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value.custom_minimum_size = Vector2(120, 0)
		value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stat_labels[key] = value
		row.add_child(value)
	# ── 라이벌 섹션 ──
	box.add_child(_label("RIVAL", 15, "#ff4444"))
	rival_label = _label("—", 12, "#5a6075")
	rival_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rival_label.clip_text = false
	rival_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(rival_label)

	box.add_child(_label("LOG", 15, "#5b9cf6"))
	log_box = RichTextLabel.new()
	log_box.bbcode_enabled = true
	log_box.fit_content = false
	log_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_box.add_theme_font_size_override("normal_font_size", 12)
	log_box.add_theme_color_override("default_color", Color("#5a6075"))
	box.add_child(log_box)

func _build_center_panel(parent):
	var center = VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_theme_constant_override("separation", 8)
	parent.add_child(center)

	var news_panel = _panel("#0f0f14", "#252535")
	news_panel.custom_minimum_size = Vector2(0, 130)
	center.add_child(news_panel)
	news_box = VBoxContainer.new()
	news_box.add_theme_constant_override("separation", 4)
	news_panel.add_child(news_box)

	# ── 이벤트 패널 (레이어드: 배경 이미지 + 어두운 오버레이 + 콘텐츠) ──
	var event_area = Control.new()
	event_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	event_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_child(event_area)

	event_bg = TextureRect.new()
	event_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	event_bg.stretch_mode = TextureRect.STRETCH_SCALE
	event_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	event_bg.modulate = Color(1, 1, 1, 0.13)
	event_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	event_area.add_child(event_bg)

	var dark_overlay = ColorRect.new()
	dark_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	dark_overlay.color = Color("#13131a")
	dark_overlay.self_modulate = Color(1, 1, 1, 0.86)
	dark_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	event_area.add_child(dark_overlay)

	var border_panel = Panel.new()
	border_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	border_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var border_style = StyleBoxFlat.new()
	border_style.bg_color = Color(0, 0, 0, 0)
	border_style.border_color = Color("#252535")
	border_style.set_border_width_all(1)
	border_style.set_corner_radius_all(4)
	border_panel.add_theme_stylebox_override("panel", border_style)
	event_area.add_child(border_panel)

	var event_margin = MarginContainer.new()
	event_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	event_margin.add_theme_constant_override("margin_left", 12)
	event_margin.add_theme_constant_override("margin_right", 12)
	event_margin.add_theme_constant_override("margin_top", 12)
	event_margin.add_theme_constant_override("margin_bottom", 12)
	event_area.add_child(event_margin)

	var event_layout = VBoxContainer.new()
	event_layout.add_theme_constant_override("separation", 10)
	event_margin.add_child(event_layout)
	event_title = _label("이벤트 대기 중", 22, "#e8eaf0")
	event_layout.add_child(event_title)
	event_body = RichTextLabel.new()
	event_body.bbcode_enabled = false
	event_body.fit_content = true
	event_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	event_body.add_theme_font_size_override("normal_font_size", 16)
	event_body.add_theme_color_override("default_color", Color("#8892a4"))
	event_layout.add_child(event_body)
	choice_box = VBoxContainer.new()
	choice_box.add_theme_constant_override("separation", 8)
	event_layout.add_child(choice_box)

func _build_right_panel(parent):
	var col = VBoxContainer.new()
	col.custom_minimum_size = Vector2(320, 0)
	col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 6)
	parent.add_child(col)

	# ── 시세 패널: PanelContainer → RichTextLabel 직결 (중간 컨테이너 없음) ──
	var ticker_panel = _panel("#0f0f14", "#252535")
	ticker_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ticker_panel.custom_minimum_size = Vector2(0, 200)
	col.add_child(ticker_panel)
	ticker_rtl = RichTextLabel.new()
	ticker_rtl.bbcode_enabled = true
	ticker_rtl.fit_content = false
	ticker_rtl.scroll_active = false
	ticker_rtl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ticker_rtl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ticker_rtl.add_theme_font_size_override("normal_font_size", 12)
	ticker_rtl.add_theme_color_override("default_color", Color("#8892a4"))
	ticker_panel.add_child(ticker_rtl)

	# ── 다크 테마 탭 (관계 / 아이템) ──
	var tabs = TabContainer.new()
	tabs.custom_minimum_size = Vector2(0, 200)
	tabs.size_flags_vertical = Control.SIZE_SHRINK_END
	col.add_child(tabs)

	# 탭 다크 스타일
	var tab_sel = StyleBoxFlat.new()
	tab_sel.bg_color    = Color("#1e1e2a")
	tab_sel.border_color = Color("#5b9cf6")
	tab_sel.set_border_width_all(1)
	tab_sel.content_margin_left  = 10
	tab_sel.content_margin_right = 10
	tab_sel.content_margin_top   = 5
	tab_sel.content_margin_bottom = 5
	var tab_unsel = StyleBoxFlat.new()
	tab_unsel.bg_color    = Color("#13131a")
	tab_unsel.border_color = Color("#252535")
	tab_unsel.set_border_width_all(1)
	tab_unsel.content_margin_left  = 10
	tab_unsel.content_margin_right = 10
	tab_unsel.content_margin_top   = 5
	tab_unsel.content_margin_bottom = 5
	var tab_panel = StyleBoxFlat.new()
	tab_panel.bg_color    = Color("#13131a")
	tab_panel.border_color = Color("#252535")
	tab_panel.set_border_width_all(1)
	tabs.add_theme_stylebox_override("tab_selected",   tab_sel)
	tabs.add_theme_stylebox_override("tab_unselected", tab_unsel)
	tabs.add_theme_stylebox_override("panel",          tab_panel)
	tabs.add_theme_color_override("font_selected_color",   Color("#e8eaf0"))
	tabs.add_theme_color_override("font_unselected_color", Color("#5a6075"))
	tabs.add_theme_font_size_override("font_size", 13)

	relationship_box = _tab_box(tabs, "관계")
	inventory_box    = _tab_box(tabs, "아이템")

func _build_bottom_bar(parent):
	var row = HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 54)
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	next_button = _button("다음 달 ▶", "#5b9cf6")
	next_button.pressed.connect(_on_next_month)
	row.add_child(next_button)
	shop_button = _button("🛍 상점", "#7c3aed")
	shop_button.pressed.connect(_open_shop)
	row.add_child(shop_button)
	var save_button = _button("저장", "#64748b")
	save_button.pressed.connect(Callable(self, "_on_save_pressed"))
	row.add_child(save_button)
	var menu_button = _button("메뉴", "#8892a4")
	menu_button.pressed.connect(_go_to_menu)
	row.add_child(menu_button)

func _build_modal():
	modal_layer = ColorRect.new()
	modal_layer.color = Color(0, 0, 0, 0.70)
	modal_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	modal_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_layer.visible = false
	add_child(modal_layer)

	var panel = _panel("#13131a", "#252535")
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(640, 560)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	modal_layer.add_child(panel)

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
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 420)
	outer.add_child(scroll)

	modal_body = VBoxContainer.new()
	modal_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	modal_body.add_theme_constant_override("separation", 8)
	scroll.add_child(modal_body)

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
	event_body.text = result_text
	var confirm_btn = _button("확인", "#1f6feb")
	confirm_btn.pressed.connect(_on_result_confirmed)
	choice_box.add_child(confirm_btn)
	next_button.disabled = true

func _on_result_confirmed():
	pending_result_text = ""
	_render_event()

func _render_event():
	for child in choice_box.get_children():
		child.queue_free()
	if current_event.is_empty():
		next_button.disabled = false
		_render_ap_actions()
		return
	next_button.disabled = true
	event_title.text = current_event.get("title", "이벤트")
	event_body.text = current_event.get("description", "")
	var choices: Array = current_event.get("choices", [])
	for i in range(choices.size()):
		var choice: Dictionary = choices[i]
		var button = _button("%d. %s" % [i + 1, choice.get("text", "선택")], "#5b9cf6")
		button.pressed.connect(Callable(self, "_choose").bind(i))
		choice_box.add_child(button)

func _refresh_all():
	if not is_inside_tree():
		return
	top_labels["date"].text = GameState.get_date_string()
	top_labels["age"].text = "%d세" % GameState.age
	top_labels["money"].text = "현금 %s" % GameState.format_money(GameState.money)
	var total_asset = GameState.get_total_asset_value()
	top_labels["asset"].text = "총자산 %s" % GameState.format_money(total_asset)
	# 강남드림까지 진행률
	var goal: float = 2_000_000_000.0
	var pct: int = int(clamp(total_asset / goal * 100.0, 0.0, 100.0))
	var bar_filled: int = int(pct / 10)
	var bar = "█".repeat(bar_filled) + "░".repeat(10 - bar_filled)
	top_labels["progress"].text = "강남 %d%%  %s" % [pct, bar]
	var fg = int(GameState.market_context.get("fear_greed", 50))
	var cycle = str(GameState.market_context.get("cycle", "neutral"))
	var cycle_kr = {"bull": "📈상승장", "bear": "📉하락장", "neutral": "횡보"}.get(cycle, cycle)
	top_labels["market"].text = "탐욕 %d  %s" % [fg, cycle_kr]

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

	# 배경 이미지 업데이트
	_update_event_bg()

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
	label.text = str(value)
	if low_is_bad:
		if value <= danger_thresh:
			label.add_theme_color_override("font_color", Color("#ff4444"))
		elif value <= warn_thresh:
			label.add_theme_color_override("font_color", Color("#f0b429"))
		else:
			label.add_theme_color_override("font_color", Color("#e8eaf0"))
	else:
		if value >= danger_thresh:
			label.add_theme_color_override("font_color", Color("#ff4444"))
		elif value >= warn_thresh:
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
	event_title.text = "%s %d월  %s  %d / %d AP" % [
		str(GameState.year), GameState.month, ap_dots, ap, GameState.max_action_points
	]

	# ── 상황판 ──────────────────────────────────────
	var net = GameState.monthly_income - GameState.get_housing_expense()
	var total = GameState.get_total_asset_value()
	var lines: PackedStringArray = PackedStringArray()

	if not turn_action_log.is_empty():
		for entry in turn_action_log:
			lines.append(entry)
		lines.append("──────────────────")

	# 재정 요약
	var net_sign = "+" if net >= 0 else ""
	var net_flag = "  ← 매달 적자 주의!" if net < 0 else ""
	lines.append("이번 달 예상 순이익  %s%s%s" % [net_sign, GameState.format_money(net), net_flag])

	# 목표 진행
	var ms_hint = _next_milestone_hint(total)
	if not ms_hint.is_empty():
		lines.append(ms_hint)

	# 긴급 경고
	if GameState.current_job.is_empty():
		lines.append("⚠  직업 없음  — 수입 0원. 구직활동을 먼저 하세요!")
	if GameState.health <= 45:
		lines.append("🚨  건강 %d / 100  — 위험! 운동이 필요합니다." % GameState.health)
	if GameState.mental <= 45:
		lines.append("🚨  정신력 %d / 100  — 위험! 명상으로 회복하세요." % GameState.mental)
	if GameState.stress >= 72 and GameState.health > 45 and GameState.mental > 45:
		lines.append("⚠  스트레스 %d  — 건강/정신에 영향을 줍니다." % GameState.stress)
	if GameState.money < 0:
		lines.append("🚨  잔고 마이너스  %s  — 빚이 생겼습니다!" % GameState.format_money(GameState.money))

	event_body.text = "\n".join(lines)

	# ── 튜토리얼 힌트 ──────────────────────────────
	var hint_text = ""
	var job_story_done: bool = GameState.flags.get("story_job_unlocked", false)
	if GameState.tutorial_step == 2 and not job_story_done:
		hint_text = "📌 스토리를 따라가며 서울 생활을 시작해보세요.\n    이번 달엔 자기계발과 인맥활동을 해볼 수 있어요."
	elif GameState.tutorial_step == 2 and job_story_done and GameState.current_job.is_empty():
		hint_text = "📌 구직활동이 열렸습니다! 먼저 취업부터 해서 월급을 만들어보세요."
	elif GameState.tutorial_step == 1:
		hint_text = "📌 직업이 생겼어요! ⚡ 행동력 3개를 모두 써보세요.\n    자기계발(스탯 성장)이나 투자(자산 성장)를 골고루 해보세요."
	elif GameState.tutorial_step == 0 and GameState.turn == 3:
		hint_text = "📌 이제 자유롭게 플레이하세요!\n    매달 행동력 3개 → 65세까지 → 자산 20억 = 강남드림 달성!"
	if not hint_text.is_empty():
		var hint = _wrap_label(hint_text, 13, "#f0b429")
		hint.add_theme_stylebox_override("normal", _hint_box())
		choice_box.add_child(hint)

	# ── 행동력 소진 안내 ────────────────────────────
	var disabled = (ap <= 0)
	if disabled:
		var done = _wrap_label("✅  이번 달 행동 완료!  아래 '다음 달 ▶' 버튼으로 결산하세요.", 13, "#00c896")
		done.add_theme_stylebox_override("normal", _hint_box())
		choice_box.add_child(done)

	# ── 컨텍스트 인식 행동 버튼 ───────────────────────
	var no_job     = GameState.current_job.is_empty()
	var warn_body  = GameState.health <= 45 or GameState.mental <= 45
	var job_story_unlocked: bool = GameState.flags.get("story_job_unlocked", false)
	var job_label  = "💼 구직활동  — 직업 목록 열람"
	var job_color  = "#b45309"
	var job_locked = false
	if not job_story_unlocked:
		job_label = "💼 구직활동  🔒 스토리 진행 후 해금"
		job_color  = "#2d3748"
		job_locked = true
	elif no_job:
		job_label = "💼 구직활동  ⚠  지금 무직 — 취업 필수!"
		job_color  = "#dc2626"
	var study_label = "📚 자기계발  — 독서 / 운동 / 명상"
	if warn_body:
		study_label = "📚 자기계발  🚨 체력·정신 회복 필요"
	var has_paycheck: bool = GameState.flags.get("has_received_paycheck", false)
	var invest_label: String
	var invest_color: String
	var invest_locked: bool
	if has_paycheck:
		invest_label = "📈 투자  — 매수 · 매도  (투자감각 %d)" % GameState.investment_skill
		invest_color = "#059669"
		invest_locked = false
	else:
		invest_label = "📈 투자  🔒 첫 월급 수령 후 해금"
		invest_color = "#2d3748"
		invest_locked = true

	var ap_actions = [
		{"label": study_label,  "color": "#5b9cf6",  "fn": "_ap_study",    "locked": false},
		{"label": invest_label, "color": invest_color, "fn": "_ap_invest",  "locked": invest_locked},
		{"label": "🤝 인맥활동  — 사회성 +1, 관계 친밀도 상승", "color": "#7c3aed", "fn": "_ap_network", "locked": false},
		{"label": job_label,    "color": job_color,  "fn": "_ap_job_hunt", "locked": job_locked},
	]
	# 단기 알바는 직업 없을 때만 표시 — 본업 있으면 어색해서 숨김
	if no_job:
		ap_actions.append({"label": "💰 단기 알바  — 오늘 당장 40만원 (건강 -5, 스트레스 +6)", "color": "#0369a1", "fn": "_ap_side_job", "locked": false})
	for action in ap_actions:
		var action_locked: bool = action.get("locked", false)
		var color = action["color"] if not disabled else "#1e1e2a"
		var btn = _button(action["label"], color)
		btn.disabled = disabled or action_locked
		btn.pressed.connect(Callable(self, action["fn"]))
		choice_box.add_child(btn)

	# ── 상점 버튼 상태 갱신 — 첫 월급 전에는 잠금 ─────────
	if shop_button:
		if has_paycheck:
			shop_button.text = "🛍 상점"
			shop_button.disabled = false
		else:
			shop_button.text = "🛍 상점 🔒"
			shop_button.disabled = true

	# ── 이사 버튼 — 조건 충족 시에만 표시 ──────────────
	if GameState.can_upgrade_housing():
		var next_id = str(GameState.get_housing_info().get("next", ""))
		var next_info = GameState.HOUSING_DATA.get(next_id, {})
		var move_btn = _button(
			"🏠 이사  — %s %s  (월 %s / 보증금 %s)" % [
				next_info.get("emoji",""), next_info.get("name",""),
				GameState.format_money(float(next_info.get("expense", 0.0))),
				GameState.format_money(float(next_info.get("deposit", 0.0)))
			],
			"#f0b429" if not disabled else "#1e1e2a"
		)
		move_btn.disabled = disabled
		move_btn.pressed.connect(_ap_move_housing)
		choice_box.add_child(move_btn)

func _ap_study():
	if not GameState.spend_ap():
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
		{"label": "📖 독서  — 지력 +3  (현재 %d → %d)" % [GameState.intelligence, GameState.intelligence + 3],
			"effects": {"intelligence": 3}},
		{"label": "🏃 운동  — 건강 +4, 스트레스 -4  (건강 %d → %d)" % [GameState.health, min(100, GameState.health + 4)],
			"effects": {"health": 4, "stress": -4}},
		{"label": "🧘 명상  — 정신력 +3, 스트레스 -5  (정신 %d → %d)" % [GameState.mental, min(100, GameState.mental + 3)],
			"effects": {"mental": 3, "stress": -5}},
		{"label": "📊 재테크 공부  — 투자감각 +2  (현재 %d → %d)" % [GameState.investment_skill, min(100, GameState.investment_skill + 2)],
			"effects": {"investment_skill": 2}},
	]
	for opt in options:
		var btn = _button(opt["label"], "#5b9cf6")
		btn.pressed.connect(Callable(self, "_on_study_chosen").bind(opt["effects"]))
		modal_body.add_child(btn)

func _on_study_chosen(effects):
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
	if not GameState.spend_ap():
		return
	turn_action_log.append("✓ 📈 투자 — 매수/매도 진행")
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

func _ap_move_housing():
	if not GameState.spend_ap():
		return
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
	job_system.apply_for_job(job_id)
	var job_name = GameState.current_job.get("name", "직업 변경")
	# 구직 로그 항목 갱신
	for i in range(turn_action_log.size() - 1, -1, -1):
		if turn_action_log[i].begins_with("✓ 💼"):
			turn_action_log[i] = "✓ 💼 구직활동 → %s 취업" % job_name
			break
	_close_modal()
	_refresh_all()
	_show_toast("💼 %s" % job_name, Color("#fbbf24"))

func _on_buy_asset(asset_id, amount):
	AudioManager.play("money_gain")
	investment_system.buy_asset(asset_id, float(amount))
	var asset_name = GameState.market_prices.keys().front() if GameState.market_prices.is_empty() else asset_id
	for data in DataRegistry.assets:
		if data.get("id", "") == asset_id:
			asset_name = data.get("name", asset_id)
			break
	for i in range(turn_action_log.size() - 1, -1, -1):
		if turn_action_log[i].begins_with("✓ 📈"):
			turn_action_log[i] = "✓ 📈 투자 → %s 매수 %s" % [asset_name, GameState.format_money(amount)]
			break
	_close_modal()
	_refresh_all()
	_show_toast("📈 매수 완료 %s" % GameState.format_money(amount), Color("#00c896"))

func _on_sell_asset(asset_id, ratio):
	AudioManager.play("money_loss")
	investment_system.sell_asset(asset_id, float(ratio))
	var asset_name = asset_id
	for data in DataRegistry.assets:
		if data.get("id", "") == asset_id:
			asset_name = data.get("name", asset_id)
			break
	for i in range(turn_action_log.size() - 1, -1, -1):
		if turn_action_log[i].begins_with("✓ 📈"):
			turn_action_log[i] = "✓ 📈 투자 → %s 매도" % asset_name
			break
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

func _go_to_menu():
	SaveManager.autosave()
	get_tree().change_scene_to_file("res://scenes/StartMenu.tscn")

func _open_modal(title):
	_clear_box(modal_body)
	modal_title_label.text = title
	modal_layer.visible = true
	modal_layer.mouse_filter = Control.MOUSE_FILTER_STOP
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

	# 확인 버튼을 맨 위에 (항상 보임)
	var confirm_btn = _button("다음 달 시작 →", "#1f6feb")
	confirm_btn.pressed.connect(func():
		_close_modal()
	)
	modal_body.add_child(confirm_btn)
	var top_sep = HSeparator.new()
	top_sep.add_theme_color_override("color", Color("#252535"))
	modal_body.add_child(top_sep)

	# ── 이달 등급 ──────────────────────────────────
	var grade = _calc_month_grade(snap)
	var grade_row = HBoxContainer.new()
	grade_row.add_theme_constant_override("separation", 14)
	modal_body.add_child(grade_row)
	grade_row.add_child(_label(grade["emoji"], 34, "#ffffff"))
	var grade_text_col = VBoxContainer.new()
	grade_text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grade_row.add_child(grade_text_col)
	grade_text_col.add_child(_label(grade["title"], 18, grade["color"]))
	grade_text_col.add_child(_wrap_label(grade["msg"], 12, "#5a6075"))
	var grade_sep = HSeparator.new()
	grade_sep.add_theme_color_override("color", Color("#252535"))
	modal_body.add_child(grade_sep)

	# 수입/지출 섹션
	var income = float(snap["monthly_income"])
	var expense = float(snap["fixed_expense"])
	var net = income - expense
	var net_color = "#00c896" if net >= 0 else "#ff4444"

	modal_body.add_child(_label("💰 수입 / 지출", 16, "#f0b429"))
	var income_row = _summary_row("월급 수입", GameState.format_money(income), "#00c896")
	modal_body.add_child(income_row)
	if bool(snap.get("subsidy", false)):
		modal_body.add_child(_summary_row("정착 지원금", "+30만원", "#5b9cf6"))
	var expense_row = _summary_row("고정 지출", "-%s" % GameState.format_money(expense), "#ff4444")
	modal_body.add_child(expense_row)
	var sep1 = HSeparator.new()
	sep1.add_theme_color_override("color", Color("#252535"))
	modal_body.add_child(sep1)
	modal_body.add_child(_summary_row("이번 달 순이익", GameState.format_money(net), net_color))

	# 자산 변화
	var assets_now = GameState.get_total_asset_value()
	var asset_delta = assets_now - float(snap["assets_before"])
	var asset_color = "#00c896" if asset_delta >= 0 else "#ff4444"
	var asset_sign = "+" if asset_delta >= 0 else ""
	modal_body.add_child(_summary_row("총 자산 변화", "%s%s" % [asset_sign, GameState.format_money(asset_delta)], asset_color))
	modal_body.add_child(_summary_row("현재 총 자산", GameState.format_money(assets_now), "#8892a4"))

	# 행동 요약
	if not snap["actions"].is_empty():
		var sep2 = HSeparator.new()
		sep2.add_theme_color_override("color", Color("#252535"))
		modal_body.add_child(sep2)
		modal_body.add_child(_label("⚡ 이번 달 행동", 16, "#f0b429"))
		for entry in snap["actions"]:
			modal_body.add_child(_wrap_label(entry, 13, "#8892a4"))

	# 스탯 변화 (변화 있을 때만)
	var stat_changes: Array = []
	if GameState.health != int(snap["health_before"]):
		var d = GameState.health - int(snap["health_before"])
		stat_changes.append("건강 %s%d" % ["+" if d > 0 else "", d])
	if GameState.mental != int(snap["mental_before"]):
		var d = GameState.mental - int(snap["mental_before"])
		stat_changes.append("정신력 %s%d" % ["+" if d > 0 else "", d])
	if GameState.stress != int(snap["stress_before"]):
		var d = GameState.stress - int(snap["stress_before"])
		stat_changes.append("스트레스 %s%d" % ["+" if d > 0 else "", d])
	if not stat_changes.is_empty():
		modal_body.add_child(_wrap_label("스탯 변화: " + ", ".join(stat_changes), 13, "#5a6075"))

	# ── 다음 달 조언 ────────────────────────────────
	var advice = _get_month_advice()
	if not advice.is_empty():
		var adv_sep = HSeparator.new()
		adv_sep.add_theme_color_override("color", Color("#252535"))
		modal_body.add_child(adv_sep)
		modal_body.add_child(_label("💡 다음 달 조언", 15, "#f0b429"))
		modal_body.add_child(_wrap_label(advice, 13, "#8892a4"))

	# ── 목표 진행 ────────────────────────────────────
	var total_now = GameState.get_total_asset_value()
	var ms = _next_milestone_hint(total_now)
	if not ms.is_empty():
		modal_body.add_child(_wrap_label(ms, 13, "#3fb950"))


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
		[10_000_000.0,    "자산 1천만원"],
		[30_000_000.0,    "원룸 이사 (보증금)"],
		[50_000_000.0,    "자산 5천만원"],
		[100_000_000.0,   "자산 1억 돌파"],
		[350_000_000.0,   "아파트 이사 (보증금)"],
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
	if asset_delta >= 10_000_000.0:
		return {"emoji": "🏆", "title": "대박 달!", "msg": "자산이 크게 늘었습니다. 이 흐름을 유지하세요.", "color": "#fbbf24"}
	elif asset_delta >= 2_000_000.0 and net >= 0.0:
		return {"emoji": "✨", "title": "잘 했습니다", "msg": "흑자에 자산 성장까지. 좋은 한 달이었습니다.", "color": "#00c896"}
	elif net >= 0.0:
		return {"emoji": "📊", "title": "평범한 달", "msg": "적자는 아니지만 자산 성장이 아쉽습니다.", "color": "#8892a4"}
	elif GameState.health > 55 and GameState.mental > 55:
		return {"emoji": "💪", "title": "힘든 달", "msg": "재정은 적자지만 건강하게 버텼습니다. 곧 나아질 거예요.", "color": "#f0b429"}
	else:
		return {"emoji": "😰", "title": "위기 상황", "msg": "재정과 체력 모두 위험합니다. 전략을 바꾸세요.", "color": "#ff4444"}

# ── 다음 달 조언 ─────────────────────────────────────
func _update_event_bg():
	if not event_bg:
		return
	var bg_path = BG_PATHS.get(GameState.housing, BG_DEFAULT)
	var tex = load(bg_path)
	if tex:
		event_bg.texture = tex

func _get_month_advice() -> String:
	if GameState.health <= 40:
		return "⚠ 건강 %d — 위험합니다. 다음 달 [운동]을 반드시 선택하세요. 건강이 0이 되면 '과로 엔딩'으로 종료됩니다." % GameState.health
	if GameState.mental <= 40:
		return "⚠ 정신력 %d — 위험합니다. [명상]이나 인맥활동으로 회복하세요. 0이 되면 '정신 붕괴 엔딩'입니다." % GameState.mental
	if GameState.stress >= 75:
		return "스트레스 %d — 70 이상이면 매달 건강과 정신에 피해를 줍니다. [운동]이나 [명상]으로 낮추세요." % GameState.stress
	if GameState.current_job.is_empty():
		return "직업이 없으면 매달 수입이 0원입니다. 생활비만큼 계속 줄어들어요. [구직활동]을 최우선으로 하세요."
	if GameState.money < 0:
		return "잔고가 마이너스입니다 (%s). 알바나 투자 수익으로 메우세요. 빚이 3천만원을 넘으면 파산 엔딩입니다." % GameState.format_money(GameState.money)
	if GameState.investment_skill < 20 and GameState.get_total_asset_value() > 2_000_000.0 and GameState.turn > 4:
		return "투자감각이 아직 낮습니다 (%d). [재테크 공부]로 올리면 투자 수익률이 올라갑니다." % GameState.investment_skill
	if not GameState.current_job.is_empty():
		var tenure = GameState.job_tenure
		var promo_count = int(GameState.current_job.get("promotion_count", 0))
		var max_promo = int(GameState.current_job.get("max_promotions", 3))
		if tenure >= 5 and promo_count < max_promo and GameState.work_performance >= 55:
			return "근속 %d개월, 업무 성과 %d입니다. 승진 기회가 다가오고 있어요. 꾸준히 유지하세요." % [tenure, GameState.work_performance]
	return ""
