extends Control

var investment_system: Node
var job_system: Node
var relationship_system: Node
var inventory_system: Node

var top_labels: Dictionary = {}
var stat_labels: Dictionary = {}
var stat_label_nodes: Dictionary = {}
var event_title: Label
var event_body: RichTextLabel
var choice_box: VBoxContainer
var news_box: VBoxContainer
var investment_box: VBoxContainer
var relationship_box: VBoxContainer
var inventory_box: VBoxContainer
var log_box: RichTextLabel
var modal_layer: ColorRect
var modal_body: VBoxContainer
var modal_title_label: Label
var next_button: Button

var current_event: Dictionary = {}
var prev_prices: Dictionary = {}
var pending_result_text: String = ""

func _ready():
	_init_systems()
	_build_ui()
	_connect_signals()
	if GameState.action_log.is_empty():
		GameState.new_game()
	investment_system.initialize()
	_begin_month()
	_refresh_all()

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

func _build_ui():
	var bg = ColorRect.new()
	bg.color = Color("#07111f")
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

func _build_top_bar(parent):
	var panel = _panel("#0d1b2f", "#1f3a5b")
	panel.custom_minimum_size = Vector2(0, 52)
	parent.add_child(panel)
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 18)
	panel.add_child(row)
	var title = _label("강남드림", 22, "#ffd166")
	title.custom_minimum_size = Vector2(120, 0)
	row.add_child(title)
	for key in ["date", "age", "turn", "money", "tier", "market"]:
		var label = _label("", 14, "#dbe7ff")
		label.custom_minimum_size = Vector2(72, 0)
		label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		if key == "market":
			label.custom_minimum_size = Vector2(200, 0)
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		top_labels[key] = label
		row.add_child(label)

func _build_left_panel(parent):
	var panel = _panel("#101820", "#243447")
	panel.custom_minimum_size = Vector2(250, 0)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_label("PLAYER", 15, "#58a6ff"))
	for key in ["job", "health", "mental", "stress", "intelligence", "social_skill", "investment_skill", "luck", "reputation", "asset"]:
		var row = HBoxContainer.new()
		box.add_child(row)
		var name_label = _label(_stat_name(key), 13, "#9fb3c8")
		name_label.custom_minimum_size = Vector2(86, 0)
		row.add_child(name_label)
		var value = _label("", 13, "#ffffff")
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value.custom_minimum_size = Vector2(120, 0)
		value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stat_labels[key] = value
		row.add_child(value)
	box.add_child(_label("LOG", 15, "#58a6ff"))
	log_box = RichTextLabel.new()
	log_box.bbcode_enabled = true
	log_box.fit_content = false
	log_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_box.add_theme_font_size_override("normal_font_size", 12)
	log_box.add_theme_color_override("default_color", Color("#9fb3c8"))
	box.add_child(log_box)

func _build_center_panel(parent):
	var center = VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_theme_constant_override("separation", 8)
	parent.add_child(center)

	var news_panel = _panel("#111827", "#26344d")
	news_panel.custom_minimum_size = Vector2(0, 130)
	center.add_child(news_panel)
	news_box = VBoxContainer.new()
	news_box.add_theme_constant_override("separation", 4)
	news_panel.add_child(news_box)

	var event_panel = _panel("#0f172a", "#334155")
	event_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_child(event_panel)
	var event_layout = VBoxContainer.new()
	event_layout.add_theme_constant_override("separation", 10)
	event_panel.add_child(event_layout)
	event_title = _label("이벤트 대기 중", 22, "#ffd166")
	event_layout.add_child(event_title)
	event_body = RichTextLabel.new()
	event_body.bbcode_enabled = false
	event_body.fit_content = true
	event_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	event_body.add_theme_font_size_override("normal_font_size", 16)
	event_body.add_theme_color_override("default_color", Color("#e5eefc"))
	event_layout.add_child(event_body)
	choice_box = VBoxContainer.new()
	choice_box.add_theme_constant_override("separation", 8)
	event_layout.add_child(choice_box)

func _build_right_panel(parent):
	var tabs = TabContainer.new()
	tabs.custom_minimum_size = Vector2(330, 0)
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(tabs)

	investment_box = _tab_box(tabs, "투자")
	relationship_box = _tab_box(tabs, "관계")
	inventory_box = _tab_box(tabs, "아이템")

func _build_bottom_bar(parent):
	var row = HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 54)
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	next_button = _button("다음 달 ▶", "#1f6feb")
	next_button.pressed.connect(_on_next_month)
	row.add_child(next_button)
	var job_button = _button("직업", "#9a6700")
	job_button.pressed.connect(_open_jobs)
	row.add_child(job_button)
	var invest_button = _button("투자", "#238636")
	invest_button.pressed.connect(_open_investments)
	row.add_child(invest_button)
	var shop_button = _button("상점", "#8957e5")
	shop_button.pressed.connect(_open_shop)
	row.add_child(shop_button)
	var save_button = _button("저장", "#30363d")
	save_button.pressed.connect(Callable(self, "_on_save_pressed"))
	row.add_child(save_button)
	var menu_button = _button("메뉴", "#1a1a2e")
	menu_button.pressed.connect(_go_to_menu)
	row.add_child(menu_button)

func _build_modal():
	modal_layer = ColorRect.new()
	modal_layer.color = Color(0, 0, 0, 0.70)
	modal_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	modal_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_layer.visible = false
	add_child(modal_layer)

	var panel = _panel("#0f172a", "#64748b")
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
	modal_title_label = _label("", 22, "#ffd166")
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

func _begin_month():
	prev_prices = GameState.market_prices.duplicate()
	if GameState.news_log.is_empty() or GameState.turn > 1:
		var news = NewsManager.generate_monthly_news()
		investment_system.process_month(news)
	EventManager.process_month_events()
	current_event = EventManager.get_next_event()
	_render_event()

func _on_next_month():
	if not current_event.is_empty():
		return
	if not pending_result_text.is_empty():
		pending_result_text = ""
		return
	job_system.process_monthly_job()
	relationship_system.process_monthly_relationships()
	inventory_system.process_monthly_items()
	GameState.apply_monthly_pressure()
	GameState.advance_calendar()
	if not GameState.is_game_over:
		_begin_month()
		SaveManager.autosave()
	_refresh_all()

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
		event_title.text = "이번 달은 조용하다"
		event_body.text = "뉴스와 시장이 움직이는 동안, 당신은 다음 선택을 준비한다."
		next_button.disabled = false
		return
	next_button.disabled = true
	event_title.text = current_event.get("title", "이벤트")
	event_body.text = current_event.get("description", "")
	var choices: Array = current_event.get("choices", [])
	for i in range(choices.size()):
		var choice: Dictionary = choices[i]
		var button = _button("%d. %s" % [i + 1, choice.get("text", "선택")], "#1f3a6e")
		button.pressed.connect(Callable(self, "_choose").bind(i))
		choice_box.add_child(button)

func _refresh_all():
	if not is_inside_tree():
		return
	top_labels["date"].text = GameState.get_date_string()
	top_labels["age"].text = "%d세" % GameState.age
	top_labels["turn"].text = "%d턴" % GameState.turn
	top_labels["money"].text = GameState.format_money(GameState.money)
	top_labels["tier"].text = GameState.get_wealth_tier()
	var fg = int(GameState.market_context.get("fear_greed", 50))
	var cycle = str(GameState.market_context.get("cycle", "neutral"))
	var cycle_kr = {"bull": "상승장", "bear": "하락장", "neutral": "횡보"}.get(cycle, cycle)
	top_labels["market"].text = "공포/탐욕 %d  |  %s" % [fg, cycle_kr]

	stat_labels["job"].text = GameState.current_job.get("name", "무직")
	_set_stat_value("health", GameState.health, true, 50, 30)
	_set_stat_value("mental", GameState.mental, true, 50, 30)
	_set_stat_value("stress", GameState.stress, false, 60, 80)
	stat_labels["intelligence"].text = str(GameState.intelligence)
	stat_labels["social_skill"].text = str(GameState.social_skill)
	stat_labels["investment_skill"].text = str(GameState.investment_skill)
	stat_labels["luck"].text = str(GameState.luck)
	stat_labels["reputation"].text = str(GameState.reputation)
	stat_labels["asset"].text = GameState.format_money(GameState.get_total_asset_value())
	_render_news()
	_render_sidebars()
	_render_log()

func _set_stat_value(key: String, value: int, low_is_bad: bool, warn_thresh: int, danger_thresh: int):
	var label = stat_labels[key]
	label.text = str(value)
	if low_is_bad:
		if value <= danger_thresh:
			label.add_theme_color_override("font_color", Color("#ef4444"))
		elif value <= warn_thresh:
			label.add_theme_color_override("font_color", Color("#f59e0b"))
		else:
			label.add_theme_color_override("font_color", Color("#ffffff"))
	else:
		if value >= danger_thresh:
			label.add_theme_color_override("font_color", Color("#ef4444"))
		elif value >= warn_thresh:
			label.add_theme_color_override("font_color", Color("#f59e0b"))
		else:
			label.add_theme_color_override("font_color", Color("#ffffff"))

func _render_news():
	for child in news_box.get_children():
		child.queue_free()
	news_box.add_child(_label("▸ BREAKING NEWS", 14, "#f97316"))
	var items = GameState.news_log.slice(max(0, GameState.news_log.size() - 4))
	for news in items:
		var text = str(news.get("headline", "")).format({"topic": _random_topic(news)})
		var misleading = bool(news.get("misleading", false))
		var color = "#c4c4c4" if misleading else "#dbe7ff"
		var prefix = "[루머] " if misleading else ""
		news_box.add_child(_wrap_label(prefix + text, 13, color))

func _render_sidebars():
	_clear_box(investment_box)
	investment_box.add_child(_label("▸ MARKET TICKER", 14, "#3fb950"))
	for row in investment_system.get_asset_rows().slice(0, 12):
		var asset_id = row["id"]
		var price = float(row["price"])
		var old_price = float(prev_prices.get(asset_id, price))
		var change_pct = 0.0
		if old_price > 0.0:
			change_pct = (price - old_price) / old_price * 100.0
		var pct_str = ""
		var color = "#dbe7ff"
		if change_pct > 0.05:
			pct_str = " +%.1f%%" % change_pct
			color = "#4ade80"
		elif change_pct < -0.05:
			pct_str = " %.1f%%" % change_pct
			color = "#f87171"
		var owned_str = ""
		if float(row["owned_value"]) > 0:
			owned_str = "  ▶ %s" % GameState.format_money(row["owned_value"])
		var risk_dots = "●" .repeat(int(row.get("risk_level", 1))) + "○".repeat(5 - int(row.get("risk_level", 1)))
		investment_box.add_child(_label("%s  %s%s%s  %s" % [row["name"], GameState.format_money(price), pct_str, owned_str, risk_dots], 12, color))

	_clear_box(relationship_box)
	relationship_box.add_child(_label("▸ RELATIONSHIPS", 14, "#d8b4fe"))
	if GameState.relationships.is_empty():
		relationship_box.add_child(_label("아직 중요한 인연이 없다.", 12, "#9fb3c8"))
	for rel in GameState.relationships:
		var affection = int(rel.get("affection", 40))
		var type_kr = {"romantic": "연인", "mentor": "멘토", "business": "비즈니스", "family": "가족", "friends": "친구"}.get(str(rel.get("type", "friends")), "인연")
		var affinity = relationship_system.get_affinity_label(affection)
		relationship_box.add_child(_label("%s  [%s]  %s (%d)" % [rel.get("name", "?"), type_kr, affinity, affection], 12, "#dbe7ff"))

	_clear_box(inventory_box)
	inventory_box.add_child(_label("▸ INVENTORY", 14, "#fbbf24"))
	if GameState.inventory.is_empty():
		inventory_box.add_child(_label("비어 있음", 12, "#9fb3c8"))
	for item in GameState.inventory:
		var item_row = HBoxContainer.new()
		item_row.add_theme_constant_override("separation", 6)
		var item_label = _label("%s %s x%d" % [item.get("icon", ""), item.get("name", "아이템"), item.get("quantity", 1)], 12, "#dbe7ff")
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
		"trade": "#4ade80",
		"job": "#fbbf24",
		"item": "#d8b4fe",
		"market": "#94a3b8",
		"relationship": "#f9a8d4",
		"system": "#64748b",
	}
	for entry in GameState.action_log.slice(max(0, GameState.action_log.size() - 16)):
		var t = entry.get("type", "system")
		var color = type_colors.get(t, "#9fb3c8")
		var date_str = entry.get("date", "")
		var msg = entry.get("message", "")
		lines.append("[color=%s][%s] %s[/color]" % [color, date_str, msg])
	log_box.text = "\n".join(lines)

func _open_jobs():
	_open_modal("직업 선택")
	var current_job_id = GameState.current_job.get("id", "")
	for job in job_system.get_available_jobs():
		var is_current = job.get("id", "") == current_job_id
		var button_color = "#30363d"
		if is_current:
			button_color = "#0f5132"
		elif job.get("eligible", false):
			button_color = "#9a6700"
		var stress_icon = "⚡" * clamp(int(job.get("stress_per_month", 5)) / 5, 1, 5)
		var label = "%s  |  %s/월  %s" % [job.get("name", ""), GameState.format_money(job.get("base_salary", 0)), stress_icon]
		if is_current:
			label += "  [현재]"
		var button = _button(label, button_color)
		button.disabled = not job.get("eligible", false) and not is_current
		button.pressed.connect(Callable(self, "_on_job_selected").bind(job.get("id", "")))
		modal_body.add_child(button)
		if not job.get("description", "").is_empty():
			modal_body.add_child(_wrap_label(job.get("description", ""), 12, "#94a3b8"))

func _open_investments():
	_open_modal("투자 / 매수·매도")
	for row in investment_system.get_asset_rows():
		var asset_id = row["id"]
		var price = float(row["price"])
		var risk_str = "리스크 %d/5" % int(row.get("risk_level", 1))
		modal_body.add_child(_label("%s  (%s)  현재가 %s" % [row["name"], risk_str, GameState.format_money(price)], 14, "#ffd166"))
		var buy_row = HBoxContainer.new()
		buy_row.add_theme_constant_override("separation", 6)
		for amount in [100_000, 500_000, 1_000_000]:
			var can_afford = GameState.money >= amount
			var btn_color = "#1a4731" if can_afford else "#30363d"
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
			var profit_color = "#4ade80" if profit_pct >= 0 else "#f87171"
			modal_body.add_child(_label("  보유 평가액 %s  |  평단 %s  |  수익률 %+.1f%%" % [GameState.format_money(owned_val), GameState.format_money(avg_price), profit_pct], 12, profit_color))
			var sell_row = HBoxContainer.new()
			sell_row.add_theme_constant_override("separation", 6)
			for sell_info in [["25%", 0.25], ["50%", 0.5], ["전량", 1.0]]:
				var sell_btn = _small_button("매도 %s" % sell_info[0], "#7f1d1d")
				sell_btn.pressed.connect(Callable(self, "_on_sell_asset").bind(asset_id, sell_info[1]))
				sell_row.add_child(sell_btn)
			modal_body.add_child(sell_row)
		var sep = HSeparator.new()
		sep.add_theme_color_override("color", Color("#1e293b"))
		modal_body.add_child(sep)

func _open_shop():
	_open_modal("상점")
	for item in inventory_system.get_shop_items():
		var price = float(item.get("price", 0))
		var can_buy = GameState.money >= price
		var btn_color = "#4c1d95" if can_buy else "#30363d"
		var icon = item.get("icon", "")
		var btn = _button("%s %s  —  %s" % [icon, item.get("name", ""), GameState.format_money(price)], btn_color)
		btn.disabled = not can_buy
		btn.pressed.connect(Callable(self, "_on_shop_item").bind(item.get("id", "")))
		modal_body.add_child(btn)
		if not item.get("description", "").is_empty():
			modal_body.add_child(_wrap_label(item.get("description", ""), 12, "#94a3b8"))

func _on_save_pressed():
	SaveManager.save_game(1)
	GameState.add_log("게임 저장 완료", "system")

func _on_job_selected(job_id):
	var result = job_system.apply_for_job(job_id)
	_close_modal()
	_refresh_all()

func _on_buy_asset(asset_id, amount):
	investment_system.buy_asset(asset_id, float(amount))
	_close_modal()
	_refresh_all()

func _on_sell_asset(asset_id, ratio):
	investment_system.sell_asset(asset_id, float(ratio))
	_close_modal()
	_refresh_all()

func _on_shop_item(item_id):
	inventory_system.purchase_item(item_id)
	_close_modal()
	_refresh_all()

func _on_use_item(item_id):
	inventory_system.use_item(item_id)
	_refresh_all()

func _go_to_menu():
	SaveManager.autosave()
	get_tree().change_scene_to_file("res://scenes/StartMenu.tscn")

func _open_modal(title):
	_clear_box(modal_body)
	modal_title_label.text = title
	modal_layer.visible = true
	modal_layer.mouse_filter = Control.MOUSE_FILTER_STOP

func _close_modal():
	modal_layer.visible = false
	modal_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _show_ending(ending_id):
	_open_modal("엔딩")
	var ending = EndingSystem.get_ending(ending_id)
	var grade = ending.get("grade", "?")
	var grade_colors = {"S": "#ffd166", "A": "#34d399", "B": "#60a5fa", "C": "#94a3b8", "F": "#f87171"}
	var grade_color = grade_colors.get(grade, "#ffffff")
	modal_body.add_child(_label("%s" % ending.get("title", "엔딩"), 26, "#ffd166"))
	modal_body.add_child(_label("등급: %s" % grade, 20, grade_color))
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
	body.add_theme_color_override("default_color", Color("#dbe7ff"))
	body.add_theme_font_size_override("normal_font_size", 15)
	modal_body.add_child(body)
	var restart_btn = _button("새 런 시작", "#238636")
	restart_btn.pressed.connect(_restart_run)
	modal_body.add_child(restart_btn)
	var menu_btn = _button("메인 메뉴", "#30363d")
	menu_btn.pressed.connect(_go_to_menu)
	modal_body.add_child(menu_btn)

func _restart_run():
	_close_modal()
	GameState.new_game()
	investment_system.initialize()
	_begin_month()
	_refresh_all()

func _tab_box(tabs, title):
	var scroll = ScrollContainer.new()
	scroll.name = title
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
		"job": "직업",
		"health": "건강",
		"mental": "정신",
		"stress": "스트레스",
		"intelligence": "지능",
		"social_skill": "사회성",
		"investment_skill": "투자감각",
		"luck": "운",
		"reputation": "평판",
		"asset": "총자산",
	}.get(key, key)

func _random_topic(news):
	var topics: Array = news.get("topics", ["시장"])
	if topics.is_empty():
		return "시장"
	return topics.pick_random()
