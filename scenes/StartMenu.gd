extends Control

# ── 배경 데이터 ──────────────────────────────────────────────────
const BACKGROUNDS = [
	{
		"id": "지방_상경",
		"emoji": "🚂",
		"name": "지방 상경",
		"tagline": "아무것도 없이 시작한다. 잃을 것도 없다.",
		"desc": "지방 출신. 연고 없음. 100만원.\n가장 어렵지만 가장 자유로운 출발.",
		"bonuses": "기본 스탯 / 패널티 없음",
		"color": "#5b9cf6",
	},
	{
		"id": "명문대_중퇴",
		"emoji": "📚",
		"name": "명문대 중퇴",
		"tagline": "머리는 있는데 길을 잃었다.",
		"desc": "학벌과 지력은 있지만 학자금 빚이 남아 있다.\n지식으로 앞서가되 빚을 갚아야 한다.",
		"bonuses": "지력 +15  평판 +8  사회성 +5\n시작 자금 -50만원  스트레스 +10",
		"color": "#a78bfa",
	},
	{
		"id": "금수저",
		"emoji": "💎",
		"name": "금수저",
		"tagline": "돈은 있다. 그런데 그게 다가 아니다.",
		"desc": "풍족하게 자랐다. 시작 자금이 넉넉하지만\n생존 감각이 부족해 투자감각이 낮다.",
		"bonuses": "시작 자금 +150만원  사회성 +8  외모 +5\n투자감각 -5",
		"color": "#f0b429",
	},
]

var name_input: LineEdit
var selected_bg_index: int = 0
var bg_cards: Array = []
var trait_option: OptionButton
var trait_desc_label: Label

func _ready():
	_build_ui()
	BGMPlayer.start()

func _build_ui():
	# ── 배경 ──
	var bg = ColorRect.new()
	bg.color = Color("#0c0c10")
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var scene_bg = TextureRect.new()
	scene_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	scene_bg.stretch_mode = TextureRect.STRETCH_SCALE
	scene_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	scene_bg.modulate = Color(1, 1, 1, 0.18)
	scene_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg_tex = load("res://assets/backgrounds/goshiwon_room.png")
	if bg_tex:
		scene_bg.texture = bg_tex
	add_child(scene_bg)

	# ── 메인 레이아웃 (스크롤 없음) ──
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	add_child(margin)

	var root = VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	# ── 타이틀 행 ──
	var title_row = HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 12)
	root.add_child(title_row)
	var title_lbl = _label("강남드림", 40, "#f0b429", HORIZONTAL_ALIGNMENT_LEFT)
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title_lbl)
	title_row.add_child(_label("KOREAN LIFE ROGUELIKE", 12, "#3a3a5a", HORIZONTAL_ALIGNMENT_RIGHT))

	root.add_child(_sep())

	# ── 본문: 왼쪽(새 게임) + 오른쪽(불러오기) ──
	var cols = HBoxContainer.new()
	cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cols.add_theme_constant_override("separation", 24)
	root.add_child(cols)

	# ── 왼쪽 컬럼: 새 게임 설정 ──
	var left = VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 10)
	cols.add_child(left)

	# 이름
	var name_row = HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 10)
	left.add_child(name_row)
	name_row.add_child(_label("이름", 13, "#5a6075", HORIZONTAL_ALIGNMENT_LEFT))
	name_input = LineEdit.new()
	name_input.placeholder_text = "이름"
	name_input.text = "김민준"
	name_input.custom_minimum_size = Vector2(0, 40)
	name_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var input_style = StyleBoxFlat.new()
	input_style.bg_color = Color("#1e1e2a")
	input_style.border_color = Color("#3a3a5a")
	input_style.set_border_width_all(1)
	input_style.set_corner_radius_all(6)
	input_style.content_margin_left = 12
	input_style.content_margin_right = 12
	name_input.add_theme_stylebox_override("normal", input_style)
	name_input.add_theme_stylebox_override("focus", input_style)
	name_input.add_theme_color_override("font_color", Color("#e8eaf0"))
	name_input.add_theme_color_override("font_placeholder_color", Color("#5a6075"))
	name_input.add_theme_font_size_override("font_size", 15)
	name_row.add_child(name_input)

	# 배경 선택
	left.add_child(_label("출신 배경", 13, "#5a6075", HORIZONTAL_ALIGNMENT_LEFT))
	var bg_grid = VBoxContainer.new()
	bg_grid.add_theme_constant_override("separation", 6)
	left.add_child(bg_grid)
	for i in BACKGROUNDS.size():
		var card = _bg_card(i)
		bg_grid.add_child(card)
		bg_cards.append(card)
	_update_bg_selection()

	# 트레이트
	left.add_child(_label("시작 특성  (플레이 실적에 따라 해금)", 13, "#5a6075", HORIZONTAL_ALIGNMENT_LEFT))
	trait_option = OptionButton.new()
	trait_option.custom_minimum_size = Vector2(0, 40)
	trait_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for trait_name in MetaProgression.get_unlocked_traits():
		trait_option.add_item(trait_name)
	trait_option.item_selected.connect(_on_trait_selected)
	left.add_child(trait_option)
	trait_desc_label = _label("", 11, "#5a6075", HORIZONTAL_ALIGNMENT_LEFT)
	trait_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left.add_child(trait_desc_label)
	_on_trait_selected(0)

	# 스페이서
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(spacer)

	# 시작 버튼
	var new_game = _button("새 런 시작  ▶", "#00c896")
	new_game.pressed.connect(_start_new_run)
	left.add_child(new_game)

	# ── 구분선 ──
	var vsep = VSeparator.new()
	vsep.add_theme_color_override("color", Color("#1e1e2a"))
	cols.add_child(vsep)

	# ── 오른쪽 컬럼: 불러오기 ──
	var right = VBoxContainer.new()
	right.custom_minimum_size = Vector2(240, 0)
	right.add_theme_constant_override("separation", 8)
	cols.add_child(right)

	right.add_child(_label("불러오기", 14, "#5b9cf6", HORIZONTAL_ALIGNMENT_LEFT))

	for slot in range(0, 4):
		var info = SaveManager.get_save_info(slot)
		var top_line = "자동저장" if slot == 0 else "슬롯 %d" % slot
		var sub_line = ""
		if info.get("empty", true):
			sub_line = "비어 있음"
		else:
			sub_line = "%d년 %d월  ·  %s" % [
				info.get("year", 2026), info.get("month", 1),
				_format_money(info.get("total_assets", 0))
			]
		var slot_btn = _slot_button(top_line, sub_line, not info.get("empty", true))
		if not info.get("empty", true):
			slot_btn.pressed.connect(Callable(self, "_load_slot").bind(slot))
		right.add_child(slot_btn)

	var right_spacer = Control.new()
	right_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(right_spacer)

	var meta = MetaProgression.data
	right.add_child(_label(
		"누적 %d런\n최고 자산 %s" % [meta.get("total_runs", 0), _format_money(meta.get("best_asset", 0))],
		11, "#3a3a5a", HORIZONTAL_ALIGNMENT_LEFT))

# ── 배경 카드 생성 ──────────────────────────────────────────────
func _bg_card(index: int) -> PanelContainer:
	var bg_data = BACKGROUNDS[index]
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 80)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.mouse_filter = Control.MOUSE_FILTER_STOP

	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color("#1a1a26")
	card_style.border_color = Color("#2a2a40")
	card_style.set_border_width_all(2)
	card_style.set_corner_radius_all(8)
	card_style.content_margin_left = 14
	card_style.content_margin_right = 14
	card_style.content_margin_top = 10
	card_style.content_margin_bottom = 10
	card.add_theme_stylebox_override("panel", card_style)
	card.set_meta("style", card_style)
	card.set_meta("index", index)

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	card.add_child(row)

	# 이모지
	var emoji_lbl = Label.new()
	emoji_lbl.text = bg_data["emoji"]
	emoji_lbl.add_theme_font_size_override("font_size", 28)
	emoji_lbl.custom_minimum_size = Vector2(38, 0)
	emoji_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(emoji_lbl)

	# 텍스트
	var text_col = VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.add_theme_constant_override("separation", 2)
	row.add_child(text_col)

	var name_row = HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 8)
	text_col.add_child(name_row)
	var name_lbl = Label.new()
	name_lbl.text = "%s  %s" % [bg_data["name"], bg_data["tagline"]]
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", Color("#e8eaf0"))
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_row.add_child(name_lbl)

	var bonus_lbl = Label.new()
	bonus_lbl.text = bg_data["bonuses"]
	bonus_lbl.add_theme_font_size_override("font_size", 11)
	bonus_lbl.add_theme_color_override("font_color", Color(bg_data["color"]))
	bonus_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bonus_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.add_child(bonus_lbl)

	# 클릭 가능하게
	var btn_overlay = Button.new()
	btn_overlay.flat = true
	btn_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn_overlay.pressed.connect(Callable(self, "_select_background").bind(index))
	card.add_child(btn_overlay)

	return card

func _select_background(index: int):
	selected_bg_index = index
	_update_bg_selection()

func _update_bg_selection():
	for i in bg_cards.size():
		var card = bg_cards[i]
		var card_style: StyleBoxFlat = card.get_meta("style")
		if i == selected_bg_index:
			card_style.bg_color = Color("#1e2040")
			card_style.border_color = Color(BACKGROUNDS[i]["color"])
			card_style.border_width_left = 3
			card_style.border_width_top = 3
			card_style.border_width_right = 3
			card_style.border_width_bottom = 3
		else:
			card_style.bg_color = Color("#1a1a26")
			card_style.border_color = Color("#2a2a40")
			card_style.border_width_left = 2
			card_style.border_width_top = 2
			card_style.border_width_right = 2
			card_style.border_width_bottom = 2
		card.add_theme_stylebox_override("panel", card_style)

# ── 트레이트 선택 ───────────────────────────────────────────────
func _on_trait_selected(index):
	if trait_desc_label == null:
		return
	var unlocked = MetaProgression.get_unlocked_traits()
	if index < 0 or index >= unlocked.size():
		trait_desc_label.text = ""
		return
	var trait_name = unlocked[index]
	var desc = ""
	var hint = ""
	for tr in DataRegistry.traits:
		if tr.get("id", "") == trait_name:
			desc = tr.get("description", "")
			var bonus = tr.get("bonus", {})
			if not bonus.is_empty():
				var parts: Array = []
				for k in bonus:
					var v = int(bonus[k])
					var sign = "+" if v >= 0 else ""
					var lbl = k
					match k:
						"money": lbl = "시작 자금 %s%d원" % [sign, v]
						"health": lbl = "건강 %s%d" % [sign, v]
						"mental": lbl = "정신력 %s%d" % [sign, v]
						"intelligence": lbl = "지력 %s%d" % [sign, v]
						"social_skill": lbl = "사회성 %s%d" % [sign, v]
						"appearance": lbl = "외모 %s%d" % [sign, v]
						"investment_skill": lbl = "투자 %s%d" % [sign, v]
						"luck": lbl = "행운 %s%d" % [sign, v]
						"stress": lbl = "스트레스 %s%d" % [sign, v]
						_: lbl = "%s %s%d" % [k, sign, v]
					parts.append(lbl)
				hint = "  [" + "  ".join(parts) + "]"
			break
	trait_desc_label.text = desc + hint

# ── 시작 / 로드 ─────────────────────────────────────────────────
func _start_new_run():
	var chosen_name = name_input.text.strip_edges()
	var chosen_bg = BACKGROUNDS[selected_bg_index]["id"]
	var selected_trait = "흙수저 생존본능"
	if trait_option.get_item_count() > 0:
		selected_trait = trait_option.get_item_text(trait_option.selected)
	GameState.start_new_game(selected_trait, chosen_name, chosen_bg)
	get_tree().change_scene_to_file("res://scenes/MainGame.tscn")

func _load_slot(slot):
	if SaveManager.load_game(slot):
		get_tree().change_scene_to_file("res://scenes/MainGame.tscn")

# ── UI 헬퍼 ────────────────────────────────────────────────────
func _label(text, size, color, align) -> Label:
	var lbl = Label.new()
	lbl.text = text
	lbl.horizontal_alignment = align
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", Color(color))
	return lbl

func _sep() -> HSeparator:
	var s = HSeparator.new()
	s.add_theme_color_override("color", Color("#1e1e2a"))
	return s

func _button(text, color) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 48)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(color)
	normal.set_corner_radius_all(6)
	var hover = normal.duplicate()
	hover.bg_color = Color(color).lightened(0.12)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_color_override("font_color", Color("#ffffff"))
	button.add_theme_font_size_override("font_size", 15)
	return button

func _slot_button(top_line: String, sub_line: String, enabled: bool) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(0, 56)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.disabled = not enabled
	var st = StyleBoxFlat.new()
	st.bg_color = Color("#1a1a26") if enabled else Color("#111118")
	st.border_color = Color("#3a3a5a") if enabled else Color("#1e1e2a")
	st.set_border_width_all(1)
	st.set_corner_radius_all(6)
	st.content_margin_left = 14
	st.content_margin_right = 14
	st.content_margin_top = 8
	st.content_margin_bottom = 8
	var st_hover = st.duplicate()
	st_hover.bg_color = Color("#222236")
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_stylebox_override("hover", st_hover)
	btn.add_theme_stylebox_override("disabled", st)
	# Build label text manually (two-line style)
	btn.text = "%s\n%s" % [top_line, sub_line]
	btn.add_theme_font_size_override("font_size", 12)
	var fc = Color("#e8eaf0") if enabled else Color("#3a3a5a")
	btn.add_theme_color_override("font_color", fc)
	btn.add_theme_color_override("font_color_disabled", Color("#3a3a5a"))
	return btn

func _format_money(amount) -> String:
	if abs(amount) >= 100_000_000:
		return "%.1f억원" % (amount / 100_000_000.0)
	if abs(amount) >= 10_000:
		return "%.0f만원" % (amount / 10_000.0)
	return "%.0f원" % amount
