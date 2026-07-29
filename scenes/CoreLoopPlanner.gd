extends Control
## ORDER-57: 월초 휴대폰 일정. 네 주의 약속을 한 화면에서 배치한다.

signal plan_committed(month_index: int, schedule: Dictionary, routines: Dictionary)

const CORE_LOOP := preload("res://systems/DemoCoreLoopV2.gd")
const COLOR_BG := Color("#07090c", 1.0)
const COLOR_PANEL := Color("#10141a", 0.96)
const COLOR_PANEL_ALT := Color("#171c23", 0.96)
const COLOR_BORDER := Color("#4e5865")
const COLOR_TEXT := Color("#e7ebf0")
const COLOR_DIM := Color("#929ba7")
const COLOR_ACCENT := Color("#d8c38d")
const COLOR_DANGER := Color("#b66b6b")

var _month_index := 1
var _month_data: Dictionary = {}
var _schedule: Dictionary = {}
var _routines: Dictionary = {}
var _locked_by_week: Dictionary = {}
var _selected_week := 1
var _selected_offer_id := ""
var _active_tab := 1
var _review_pending := false

var _font: FontFile
var _font_bold: FontFile
var _title_label: Label
var _month_label: Label
var _tab_buttons: Array[Button] = []
var _calendar_surface: HBoxContainer
var _read_only_surface: VBoxContainer
var _offer_list: VBoxContainer
var _slot_list: VBoxContainer
var _offer_buttons: Dictionary = {}
var _slot_buttons: Dictionary = {}
var _routine_buttons: Dictionary = {}
var _status_label: Label
var _detail_label: Label
var _hint_label: Label
var _confirm_button: Button

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 96
	mouse_filter = Control.MOUSE_FILTER_STOP
	_font = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile
	_build_ui()
	visible = false

func open(month_index: int) -> void:
	_month_index = month_index
	_month_data = CORE_LOOP.month_spec(month_index)
	_schedule = {}
	_routines = CORE_LOOP.default_routines()
	if not GameState.current_job.is_empty():
		_routines["primary"] = "livelihood"
	_locked_by_week = {}
	_review_pending = false
	for raw_lock in _month_data.get("locked", []):
		if not raw_lock is Dictionary:
			continue
		var lock: Dictionary = raw_lock
		var week := int(lock.get("week", 0))
		var bundle_id := str(lock.get("bundle", ""))
		if week > 0 and not bundle_id.is_empty():
			_locked_by_week[str(week)] = bundle_id
			_schedule[str(week)] = bundle_id
	var weeks: Array = _month_data.get("weeks", [1, 4])
	_selected_week = int(weeks[0])
	for week in range(int(weeks[0]), int(weeks[1]) + 1):
		if not _locked_by_week.has(str(week)):
			_selected_week = week
			break
	_active_tab = 1
	visible = true
	_rebuild()
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.22).set_trans(Tween.TRANS_SINE)

func close() -> void:
	visible = false

func schedule_snapshot() -> Dictionary:
	return _schedule.duplicate(true)

func routine_snapshot() -> Dictionary:
	return _routines.duplicate(true)

func review_pending() -> bool:
	return _review_pending

func assign_offer_to_week(bundle_id: String, week: int) -> bool:
	if not CORE_LOOP.available_offer_ids(_month_index).has(bundle_id):
		return false
	if not CORE_LOOP.bundle_allowed_in_week(bundle_id, week):
		return false
	if _locked_by_week.has(str(week)):
		return false
	_review_pending = false
	for raw_week in _schedule.keys():
		if str(_schedule.get(raw_week, "")) == bundle_id:
			_schedule.erase(raw_week)
	_schedule[str(week)] = bundle_id
	_selected_offer_id = bundle_id
	_selected_week = week
	_refresh_calendar()
	return true

func select_routine(slot: String, routine_id: String) -> bool:
	if slot not in ["primary", "secondary"] \
			or not CORE_LOOP.routine_options().has(routine_id):
		return false
	if slot == "primary" and not GameState.current_job.is_empty() \
			and routine_id != "livelihood":
		return false
	var other_slot := "secondary" if slot == "primary" else "primary"
	var previous := str(_routines.get(slot, ""))
	if str(_routines.get(other_slot, "")) == routine_id:
		if other_slot == "primary" and not GameState.current_job.is_empty():
			return false
		_routines[other_slot] = previous
	_routines[slot] = routine_id
	_review_pending = false
	_rebuild()
	var focus_key := "%s:%s" % [slot, routine_id]
	var focus_button: Button = _routine_buttons.get(focus_key)
	if is_instance_valid(focus_button):
		focus_button.call_deferred("grab_focus")
	return true

func unassign_week(week: int) -> bool:
	var week_key := str(week)
	if _locked_by_week.has(week_key) or not _schedule.has(week_key):
		return false
	_review_pending = false
	_schedule.erase(week_key)
	_refresh_calendar()
	return true

func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = COLOR_BG
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)

	var background_image := TextureRect.new()
	background_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background_image.texture = load("res://assets/backgrounds/gangnam_night_street.png")
	background_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_image.modulate = Color(0.18, 0.20, 0.23, 0.20)
	background_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background_image)

	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color("#07090c", 0.78)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 42)
	margin.add_theme_constant_override("margin_right", 42)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 22)
	add_child(margin)

	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 14)
	margin.add_child(page)

	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 54)
	header.add_theme_constant_override("separation", 18)
	page.add_child(header)
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titles.add_theme_constant_override("separation", 1)
	header.add_child(titles)
	_title_label = _label("", 28, COLOR_TEXT, true)
	titles.add_child(_title_label)
	_month_label = _label("", 14, COLOR_DIM)
	titles.add_child(_month_label)

	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 6)
	header.add_child(tabs)
	for index in range(4):
		var tab := _button("", false)
		tab.custom_minimum_size = Vector2(116, 42)
		tab.pressed.connect(_switch_tab.bind(index))
		tab.mouse_entered.connect(tab.grab_focus)
		tabs.add_child(tab)
		_tab_buttons.append(tab)

	var divider := HSeparator.new()
	divider.add_theme_color_override("color", Color("#343b45"))
	page.add_child(divider)

	_calendar_surface = HBoxContainer.new()
	_calendar_surface.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_calendar_surface.add_theme_constant_override("separation", 22)
	page.add_child(_calendar_surface)

	var offers_column := VBoxContainer.new()
	offers_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	offers_column.add_theme_constant_override("separation", 8)
	_calendar_surface.add_child(offers_column)
	offers_column.add_child(_section_title(
		LocaleManager.ui("이번 달 선택지", "THIS MONTH'S OPTIONS")))
	_offer_list = VBoxContainer.new()
	_offer_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_offer_list.add_theme_constant_override("separation", 7)
	offers_column.add_child(_offer_list)

	var calendar_column := VBoxContainer.new()
	calendar_column.custom_minimum_size = Vector2(420, 0)
	calendar_column.add_theme_constant_override("separation", 8)
	_calendar_surface.add_child(calendar_column)
	calendar_column.add_child(_section_title(
		LocaleManager.ui("이번 달 네 주", "FOUR WEEKS THIS MONTH")))
	_slot_list = VBoxContainer.new()
	_slot_list.add_theme_constant_override("separation", 7)
	calendar_column.add_child(_slot_list)
	_detail_label = _label("", 14, COLOR_DIM)
	_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_label.custom_minimum_size = Vector2(0, 58)
	calendar_column.add_child(_detail_label)
	_status_label = _label("", 14, COLOR_ACCENT, true)
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	calendar_column.add_child(_status_label)

	_read_only_surface = VBoxContainer.new()
	_read_only_surface.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_read_only_surface.add_theme_constant_override("separation", 12)
	page.add_child(_read_only_surface)

	var footer := HBoxContainer.new()
	footer.custom_minimum_size = Vector2(0, 52)
	footer.add_theme_constant_override("separation", 14)
	page.add_child(footer)
	_hint_label = _label("", 14, COLOR_DIM)
	_hint_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	footer.add_child(_hint_label)
	_confirm_button = _button(LocaleManager.ui(
		"이 일정으로 첫 주를 시작한다",
		"Begin the First Week with This Plan"), true)
	_confirm_button.custom_minimum_size = Vector2(330, 48)
	_confirm_button.pressed.connect(_commit_plan)
	_confirm_button.mouse_entered.connect(_confirm_button.grab_focus)
	footer.add_child(_confirm_button)

func _rebuild() -> void:
	_title_label.text = LocaleManager.ui(
		"%d월 · %s" % [_month_index, str(_month_data.get("title_ko", ""))],
		"MONTH %d · %s" % [_month_index, str(_month_data.get("title_en", ""))])
	if _review_pending:
		_month_label.text = LocaleManager.ui(
			"이번 달에 할 일과 하지 않을 일을 확인한 뒤 계획을 확정한다.",
			"Review what you will and will not do this month, then confirm the plan.")
	else:
		_month_label.text = LocaleManager.ui(
			"이번 달 소식과 기회를 살펴보고, 네 주에 무엇을 할지 정한다.",
			"Review this month's updates and opportunities, then decide what to do each week.")
	var tab_names := [
		LocaleManager.ui("소식·기회", "UPDATES"),
		LocaleManager.ui("일정", "CALENDAR"),
		LocaleManager.ui("인연", "PEOPLE"),
		LocaleManager.ui("기록", "RECORD"),
	]
	for index in range(_tab_buttons.size()):
		_tab_buttons[index].text = tab_names[index]
		_apply_button_style(_tab_buttons[index], index == _active_tab, false)
	_calendar_surface.visible = _active_tab == 1
	_read_only_surface.visible = _active_tab != 1
	if _active_tab == 1:
		_rebuild_calendar()
	else:
		_rebuild_read_only_surface()
	_refresh_footer()

func _rebuild_calendar() -> void:
	_clear_children(_offer_list)
	_clear_children(_slot_list)
	_offer_buttons.clear()
	_slot_buttons.clear()
	var available := CORE_LOOP.available_offer_ids(_month_index)
	for bundle_id in available:
		var offer := CORE_LOOP.bundle(bundle_id)
		var text := "%s\n%s" % [
			_localized(offer, "offer"),
			_localized(offer, "deadline"),
		]
		var offer_button := _button(text, false)
		offer_button.custom_minimum_size = Vector2(0, 62)
		offer_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		offer_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		offer_button.pressed.connect(_assign_offer.bind(bundle_id))
		offer_button.focus_entered.connect(_offer_focused.bind(bundle_id))
		offer_button.mouse_entered.connect(offer_button.grab_focus)
		_offer_list.add_child(offer_button)
		_offer_buttons[bundle_id] = offer_button

	var weeks: Array = _month_data.get("weeks", [1, 4])
	for week in range(int(weeks[0]), int(weeks[1]) + 1):
		var slot_button := _button("", false)
		slot_button.custom_minimum_size = Vector2(0, 76)
		slot_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		slot_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		slot_button.pressed.connect(_select_week.bind(week))
		slot_button.focus_entered.connect(_week_focused.bind(week))
		slot_button.mouse_entered.connect(slot_button.grab_focus)
		_slot_list.add_child(slot_button)
		_slot_buttons[str(week)] = slot_button
	_refresh_calendar()
	if not available.is_empty():
		var first_button: Button = _offer_buttons.get(available[0])
		if is_instance_valid(first_button):
			first_button.call_deferred("grab_focus")

func _refresh_calendar() -> void:
	var available := CORE_LOOP.available_offer_ids(_month_index)
	for bundle_id in available:
		var button: Button = _offer_buttons.get(bundle_id)
		if not is_instance_valid(button):
			continue
		var assigned := _schedule.values().has(bundle_id)
		var offer := CORE_LOOP.bundle(bundle_id)
		button.text = "%s%s\n%s" % [
			LocaleManager.ui("배치됨 · ", "SCHEDULED · ") if assigned else "",
			_localized(offer, "offer"),
			_localized(offer, "deadline"),
		]
		_apply_button_style(button, bundle_id == _selected_offer_id, assigned)

	for week_key in _slot_buttons:
		var week := int(week_key)
		var button: Button = _slot_buttons[week_key]
		var bundle_id := str(_schedule.get(week_key, ""))
		var locked := _locked_by_week.has(week_key)
		var week_in_month := posmod(week - 1, 4) + 1
		if bundle_id.is_empty():
			button.text = LocaleManager.ui(
				"%d주차\n비어 있음" % week_in_month,
				"WEEK %d\nOpen" % week_in_month)
		else:
			var scene_bundle := CORE_LOOP.bundle(bundle_id)
			button.text = LocaleManager.ui(
				"%d주차%s\n%s" % [
					week_in_month,
					" · 고정" if locked else "",
					_localized(scene_bundle, "offer"),
				],
				"WEEK %d%s\n%s" % [
					week_in_month,
					" · FIXED" if locked else "",
					_localized(scene_bundle, "offer"),
				])
		button.disabled = locked
		_apply_button_style(button, week == _selected_week, not bundle_id.is_empty())

	var selected_offer := CORE_LOOP.bundle(_selected_offer_id)
	if selected_offer.is_empty():
		_detail_label.text = LocaleManager.ui(
			"제안을 고르면 장소와 기한, 고르지 않았을 때 달라지는 일을 볼 수 있다.",
			"Choose an option to see its place, deadline, and what changes if you pass.")
	else:
		_detail_label.text = "%s\n%s: %s" % [
			_localized(selected_offer, "detail"),
			LocaleManager.ui("고르지 않으면", "IF NOT CHOSEN"),
			_localized(selected_offer, "decline"),
		]
	_refresh_footer()

func _rebuild_read_only_surface() -> void:
	_clear_children(_read_only_surface)
	match _active_tab:
		0:
			_build_messages_surface()
		2:
			_build_people_surface()
		3:
			_build_record_surface()

func _build_messages_surface() -> void:
	_read_only_surface.add_child(_section_title(LocaleManager.ui(
		"이번 달 소식과 기회", "UPDATES AND OPTIONS THIS MONTH")))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 8)
	_read_only_surface.add_child(grid)
	for raw_record in CORE_LOOP.decline_receipts_for_month(_month_index):
		if not raw_record is Dictionary:
			continue
		var record: Dictionary = raw_record
		var producer: Dictionary = CORE_LOOP.bundle(
			str(record.get("producer_bundle", "")))
		grid.add_child(_compact_message_row(
			LocaleManager.ui("고르지 않은 일 · ", "NOT CHOSEN · ")
				+ _localized(producer, "offer"),
			str(record.get(
				"message_en" if LocaleManager.is_english() else "message_ko", ""))))
	for bundle_id in CORE_LOOP.available_offer_ids(_month_index):
		var offer := CORE_LOOP.bundle(bundle_id)
		grid.add_child(_compact_message_row(
			_localized(offer, "offer"),
			"%s · %s" % [_localized(offer, "detail"), _localized(offer, "deadline")]))

func _build_people_surface() -> void:
	_read_only_surface.add_child(_section_title(LocaleManager.ui(
		"지금까지 만난 사람", "PEOPLE MET SO FAR")))
	var seen: Array[String] = []
	var raw_stages: Variant = GameState.core_loop_v2_state.get(
		"relationship_stages", {})
	if raw_stages is Dictionary:
		for raw_character in (raw_stages as Dictionary).keys():
			var character_id := str(raw_character).strip_edges()
			var stage := str((raw_stages as Dictionary).get(
				raw_character, "unmet"))
			if character_id.is_empty() or stage == "unmet" \
					or seen.has(character_id):
				continue
			seen.append(character_id)
	for character_id in seen:
		_read_only_surface.add_child(_read_only_row(
			_character_name(character_id),
			_relationship_copy(character_id)))
	if seen.is_empty():
		_read_only_surface.add_child(_read_only_row(
			LocaleManager.ui(
				"아직 기록된 연락이나 만남이 없다",
				"No calls or meetings recorded yet"),
			LocaleManager.ui(
				"통화하거나 새 사람을 만나면 다음 달에도 이곳에 남는다.",
				"Calls and new meetings remain here in later months.")))

func _build_record_surface() -> void:
	var section_heading := LocaleManager.ui(
		"계획 확인", "REVIEW PLAN") if _review_pending else LocaleManager.ui(
		"이번 달 계획", "THIS MONTH'S PLAN")
	_read_only_surface.add_child(_section_title(section_heading))
	_build_routine_surface()
	var scheduled_lines := _scheduled_commitment_lines()
	_read_only_surface.add_child(_read_only_row(
		LocaleManager.ui("네 주에 할 일", "WHAT YOU WILL DO"),
		"\n".join(scheduled_lines),
		118))
	var unchosen_lines := _unchosen_offer_lines()
	_read_only_surface.add_child(_read_only_row(
		LocaleManager.ui("이번 달에 고르지 않은 일", "NOT CHOSEN THIS MONTH"),
		"\n".join(unchosen_lines),
		104))

func _build_routine_surface() -> void:
	_routine_buttons.clear()
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 116)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override(
		"panel", _panel_style(COLOR_PANEL, COLOR_BORDER, 1))
	_read_only_surface.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	margin.add_child(box)
	var title := LocaleManager.ui(
		"이번 달에 매주 계속할 두 가지",
		"TWO THINGS TO KEEP UP EACH WEEK")
	box.add_child(_label(title, 14, COLOR_TEXT, true))
	var options := CORE_LOOP.routine_options()
	for slot in ["primary", "secondary"]:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		box.add_child(row)
		var slot_label := _label(
			LocaleManager.ui("주로 할 일", "PRIMARY")
				if slot == "primary" else LocaleManager.ui("보조로 할 일", "SECONDARY"),
			12, COLOR_DIM, true)
		slot_label.custom_minimum_size = Vector2(86, 34)
		slot_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(slot_label)
		for routine_id in options:
			var option: Dictionary = options[routine_id]
			var button := _button(_localized(option, "label"), false)
			button.tooltip_text = _localized(option, "description")
			button.custom_minimum_size = Vector2(0, 34)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.disabled = (
				slot == "primary"
				and not GameState.current_job.is_empty()
				and str(routine_id) != "livelihood"
			)
			button.pressed.connect(select_routine.bind(slot, str(routine_id)))
			button.mouse_entered.connect(button.grab_focus)
			row.add_child(button)
			var key := "%s:%s" % [slot, str(routine_id)]
			_routine_buttons[key] = button
			var selected := str(_routines.get(slot, "")) == str(routine_id)
			button.text = ("%s%s" % [
				_localized(option, "label"),
				LocaleManager.ui(" (선택됨)", " (SET)") if selected else "",
			])
			_apply_button_style(button, false, selected)
	var selected_details: Array[String] = []
	for slot in ["primary", "secondary"]:
		var routine_id := str(_routines.get(slot, ""))
		var option: Dictionary = options.get(routine_id, {})
		var label := _localized(option, "label")
		var effects := _routine_effect_copy(option)
		if not label.is_empty() and not effects.is_empty():
			selected_details.append("%s — %s" % [label, effects])
	var detail := _label("  ·  ".join(selected_details), 12, COLOR_DIM)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.max_lines_visible = 2
	box.add_child(detail)

func _read_only_row(title: String, body: String, minimum_height: float = 76.0) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, minimum_height)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _panel_style(COLOR_PANEL, COLOR_BORDER, 1))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	margin.add_child(box)
	box.add_child(_label(title, 16, COLOR_TEXT, true))
	var body_label := _label(body, 14, COLOR_DIM)
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(body_label)
	return panel

func _compact_message_row(title: String, body: String) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 68)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style := _panel_style(COLOR_PANEL, COLOR_BORDER, 1)
	style.content_margin_left = 0
	style.content_margin_right = 0
	style.content_margin_top = 0
	style.content_margin_bottom = 0
	panel.add_theme_stylebox_override("panel", style)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 13)
	margin.add_theme_constant_override("margin_right", 13)
	margin.add_theme_constant_override("margin_top", 7)
	margin.add_theme_constant_override("margin_bottom", 7)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	margin.add_child(box)
	var title_label := _label(title, 14, COLOR_TEXT, true)
	title_label.max_lines_visible = 1
	title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	box.add_child(title_label)
	var body_label := _label(body, 12, COLOR_DIM)
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.max_lines_visible = 2
	body_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	box.add_child(body_label)
	return panel

func _assign_offer(bundle_id: String) -> void:
	var target_week := _selected_week
	if _locked_by_week.has(str(target_week)) \
			or not CORE_LOOP.bundle_allowed_in_week(bundle_id, target_week):
		target_week = _first_open_week_for_bundle(bundle_id)
	if target_week <= 0:
		target_week = _first_replaceable_week_for_bundle(bundle_id)
	if target_week <= 0:
		return
	assign_offer_to_week(bundle_id, target_week)
	var next_week := _first_open_week()
	if next_week > 0:
		_selected_week = next_week
	_refresh_calendar()

func _select_week(week: int) -> void:
	_selected_week = week
	_refresh_calendar()

func _offer_focused(bundle_id: String) -> void:
	_selected_offer_id = bundle_id
	_refresh_calendar()

func _week_focused(week: int) -> void:
	_selected_week = week
	_refresh_calendar()

func _commit_plan() -> void:
	if _schedule.size() != 4:
		return
	var validation := CORE_LOOP.validate_plan(_month_index, _schedule, _routines)
	if not bool(validation.get("ok", false)):
		_status_label.text = _plan_error_text(validation)
		return
	if not _review_pending:
		_begin_commit_review()
		return
	emit_signal(
		"plan_committed", _month_index, _schedule.duplicate(true),
		_routines.duplicate(true))

func _switch_tab(index: int) -> void:
	var target := clampi(index, 0, 3)
	if _review_pending and target != 3:
		_review_pending = false
	_active_tab = target
	_rebuild()

func _cycle_tab(delta: int) -> void:
	_switch_tab(int(posmod(_active_tab + delta, 4)))
	_tab_buttons[_active_tab].call_deferred("grab_focus")

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	var handled := false
	if event is InputEventJoypadButton and (event as InputEventJoypadButton).pressed:
		var joy_button := int((event as InputEventJoypadButton).button_index)
		match joy_button:
			JOY_BUTTON_A:
				var focused := get_viewport().gui_get_focus_owner()
				if focused is Button and is_ancestor_of(focused) \
						and not (focused as Button).disabled:
					(focused as Button).pressed.emit()
					handled = true
			JOY_BUTTON_B:
				if _review_pending:
					_cancel_commit_review()
					handled = true
				elif _active_tab == 1:
					handled = unassign_week(_selected_week)
			JOY_BUTTON_LEFT_SHOULDER:
				_cycle_tab(-1)
				handled = true
			JOY_BUTTON_RIGHT_SHOULDER:
				_cycle_tab(1)
				handled = true
	if not handled and event.is_action_pressed("gd_tab_prev"):
		_cycle_tab(-1)
		handled = true
	elif not handled and event.is_action_pressed("gd_tab_next"):
		_cycle_tab(1)
		handled = true
	elif not handled and event.is_action_pressed("ui_cancel"):
		if _review_pending:
			_cancel_commit_review()
			handled = true
		elif _active_tab == 1:
			handled = unassign_week(_selected_week)
	if handled:
		get_viewport().set_input_as_handled()

func _refresh_footer() -> void:
	if not is_instance_valid(_confirm_button):
		return
	var validation := CORE_LOOP.validate_plan(_month_index, _schedule, _routines)
	var ready := bool(validation.get("ok", false))
	_confirm_button.disabled = not ready
	_apply_button_style(_confirm_button, false, ready)
	if _review_pending:
		_confirm_button.text = LocaleManager.ui(
			"이대로 확정하고 첫 주를 시작한다",
			"Confirm Plan and Begin Week One")
		_hint_label.text = LocaleManager.ui(
			"%s 일정 수정 · %s 최종 확정",
			"%s Edit Schedule · %s Confirm Plan") % [
				ControllerHints.east(),
				ControllerHints.south(),
			]
		return
	_confirm_button.text = LocaleManager.ui(
		"이번 달 계획을 확인한다",
		"Review This Month's Plan")
	var missed_count := maxi(
		CORE_LOOP.available_offer_ids(_month_index).size()
			- _selected_offer_count(), 0)
	_status_label.text = LocaleManager.ui(
		"네 주를 모두 정하면, 남은 제안 {count}개는 이번 달에 고르지 않는다.",
		"Fill all four weeks. You will pass on {count} other options this month."
	).format({"count": missed_count})
	_hint_label.text = LocaleManager.ui(
		"방향키 이동 · %s 배치 · %s 배치 취소 · %s/%s 탭" % [
			ControllerHints.south(),
			ControllerHints.east(),
			ControllerHints.shoulder_l(),
			ControllerHints.shoulder_r(),
		],
		"D-pad Navigate · %s Schedule · %s Remove · %s/%s Tabs" % [
			ControllerHints.south(),
			ControllerHints.east(),
			ControllerHints.shoulder_l(),
			ControllerHints.shoulder_r(),
		])

func _plan_error_text(validation: Dictionary) -> String:
	match str(validation.get("error", "")):
		"deadline_missed":
			return LocaleManager.ui(
				"그 주에는 이미 기한이 지났다. 더 이른 주로 옮겨야 한다.",
				"The deadline has already passed by that week. Move it earlier.")
		"choose_two_routines":
			return LocaleManager.ui(
				"이번 달에 매주 계속할 두 가지를 고른다.",
				"Choose two things to keep up each week this month.")
		"routines_must_be_distinct":
			return LocaleManager.ui(
				"서로 다른 두 가지를 골라야 한다.",
				"Choose two different things.")
		"job_requires_primary_livelihood":
			return LocaleManager.ui(
				"취업 중에는 본업을 매주 해야 한다.",
				"While employed, your job must remain a weekly activity.")
		"exclusive_group":
			return LocaleManager.ui(
				"서로 겹치는 두 만남은 같은 달에 함께 고를 수 없다.",
				"These two meetings cannot both be chosen in the same month.")
	return LocaleManager.ui(
		"네 주에 할 일과 매주 계속할 두 가지를 모두 정해야 한다.",
		"Fill all four weeks and choose both weekly activities.")

func _begin_commit_review() -> void:
	_review_pending = true
	_active_tab = 3
	_rebuild()
	_confirm_button.call_deferred("grab_focus")

func _cancel_commit_review() -> void:
	_review_pending = false
	_active_tab = 1
	_rebuild()

func _scheduled_commitment_lines() -> Array[String]:
	var lines: Array[String] = []
	var weeks: Array = _month_data.get("weeks", [1, 4])
	for week in range(int(weeks[0]), int(weeks[1]) + 1):
		var week_key := str(week)
		var bundle_id := str(_schedule.get(week_key, ""))
		var offer_name := LocaleManager.ui(
			"아직 배치하지 않음", "Not scheduled yet")
		if not bundle_id.is_empty():
			offer_name = _localized(CORE_LOOP.bundle(bundle_id), "offer")
		var fixed := LocaleManager.ui(" · 고정", " · FIXED") \
			if _locked_by_week.has(week_key) else ""
		lines.append(LocaleManager.ui(
			"{week}주차 · {offer}{fixed}",
			"WEEK {week} · {offer}{fixed}").format({
				"week": posmod(week - 1, 4) + 1,
				"offer": offer_name,
				"fixed": fixed,
			}))
	return lines

func _unchosen_offer_ids() -> Array[String]:
	var result: Array[String] = []
	for bundle_id in CORE_LOOP.available_offer_ids(_month_index):
		if not _schedule.values().has(bundle_id):
			result.append(bundle_id)
	return result

func _unchosen_offer_lines() -> Array[String]:
	var lines: Array[String] = []
	for bundle_id in _unchosen_offer_ids():
		lines.append("• %s" % _localized(CORE_LOOP.bundle(bundle_id), "offer"))
	if lines.is_empty():
		lines.append(LocaleManager.ui(
			"이번 달에 고르지 않은 일 없음",
			"Nothing is left unchosen this month"))
	return lines

func _selected_offer_count() -> int:
	var count := 0
	for bundle_id in _schedule.values():
		if CORE_LOOP.available_offer_ids(_month_index).has(str(bundle_id)):
			count += 1
	return count

func _first_open_week() -> int:
	var weeks: Array = _month_data.get("weeks", [1, 4])
	for week in range(int(weeks[0]), int(weeks[1]) + 1):
		if not _schedule.has(str(week)) and not _locked_by_week.has(str(week)):
			return week
	return -1

func _first_open_week_for_bundle(bundle_id: String) -> int:
	var weeks: Array = _month_data.get("weeks", [1, 4])
	for week in range(int(weeks[0]), int(weeks[1]) + 1):
		if not _schedule.has(str(week)) \
				and not _locked_by_week.has(str(week)) \
				and CORE_LOOP.bundle_allowed_in_week(bundle_id, week):
			return week
	return -1

func _first_replaceable_week() -> int:
	var weeks: Array = _month_data.get("weeks", [1, 4])
	for week in range(int(weeks[0]), int(weeks[1]) + 1):
		if not _locked_by_week.has(str(week)):
			return week
	return -1

func _first_replaceable_week_for_bundle(bundle_id: String) -> int:
	var weeks: Array = _month_data.get("weeks", [1, 4])
	for week in range(int(weeks[0]), int(weeks[1]) + 1):
		if not _locked_by_week.has(str(week)) \
				and CORE_LOOP.bundle_allowed_in_week(bundle_id, week):
			return week
	return -1

func _localized(data: Dictionary, stem: String) -> String:
	var key := "%s_%s" % [stem, "en" if LocaleManager.is_english() else "ko"]
	return str(data.get(key, ""))

func _routine_effect_copy(option: Dictionary) -> String:
	var raw_effects: Variant = option.get("weekly_effects", {})
	if not raw_effects is Dictionary:
		return ""
	var effects: Dictionary = raw_effects
	if effects.has("unemployed") or effects.has("employed"):
		var employment_key := "employed" \
			if not GameState.current_job.is_empty() else "unemployed"
		var branch: Variant = effects.get(employment_key, {})
		effects = branch as Dictionary if branch is Dictionary else {}
	var labels := {
		"money": LocaleManager.ui("현금", "Cash"),
		"health": LocaleManager.ui("건강", "Health"),
		"mental": LocaleManager.ui("정신력", "Mental"),
		"intelligence": LocaleManager.ui("지력", "Skill"),
		"work_performance": LocaleManager.ui("업무", "Work"),
	}
	var order := ["money", "health", "mental", "intelligence", "work_performance"]
	var parts: Array[String] = []
	for key in order:
		if not effects.has(key):
			continue
		var value := int(effects[key])
		var shown: String = GameState.format_money(abs(value)) if key == "money" \
			else str(abs(value))
		parts.append("%s %s%s" % [
			str(labels[key]),
			"+" if value >= 0 else "-",
			shown,
		])
	return " / ".join(parts)

func _character_name(character_id: String) -> String:
	match character_id:
		"father":
			return LocaleManager.ui("아버지", "Father")
		"hyunsu":
			return LocaleManager.ui("현수", "Hyunsu")
		"daeun":
			return LocaleManager.ui("김다은", "Kim Daeun")
		"jiyeon":
			return LocaleManager.ui("한지연", "Han Jiyeon")
		"sangchul":
			return LocaleManager.ui("임상철", "Im Sangchul")
		"jaehyuk":
			return LocaleManager.ui("최재혁", "Choi Jaehyuk")
	return character_id

func _relationship_copy(character_id: String) -> String:
	if character_id == "father":
		if CORE_LOOP.relationship_stage(character_id) == "unmet":
			return LocaleManager.ui(
				"연락처는 저장돼 있다. 이번 달에는 아직 통화하지 않았다.",
				"His number is saved. You have not spoken this month.")
		return LocaleManager.ui(
			"짧게 통화했다. 서로의 목소리를 듣고 통화를 마쳤다.",
			"You spoke briefly, heard each other's voices, and ended the call.")
	var stage := CORE_LOOP.relationship_stage(character_id)
	var initiated := CORE_LOOP.was_player_initiated(character_id)
	if initiated:
		return LocaleManager.ui(
			"내가 먼저 연락해 한 번 더 만났다.",
			"You reached out first and met again.")
	match stage:
		"met":
			return LocaleManager.ui(
				"한 번 마주쳤다. 다시 만날 약속은 없다.",
				"You met once. Nothing has promised a second meeting.")
		"opening":
			return LocaleManager.ui(
				"한 번 더 말을 걸어도 어색하지 않은 사이다.",
				"Another conversation would not feel out of place.")
	return LocaleManager.ui(
		"아직 서로 아는 사이가 아니다.",
		"You have not entered each other's time yet.")

func _section_title(text: String) -> Label:
	var label := _label(text, 15, COLOR_ACCENT, true)
	label.custom_minimum_size = Vector2(0, 24)
	return label

func _label(text: String, size: int, color: Color, bold: bool = false) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	var target_font := _font_bold if bold else _font
	if target_font:
		label.add_theme_font_override("font", target_font)
	return label

func _button(text: String, primary: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 15 if not primary else 16)
	if _font_bold:
		button.add_theme_font_override("font", _font_bold)
	_apply_button_style(button, false, primary)
	return button

func _apply_button_style(button: Button, selected: bool, filled: bool) -> void:
	if not is_instance_valid(button):
		return
	var bg := COLOR_PANEL_ALT if filled else COLOR_PANEL
	var border := COLOR_ACCENT if selected else COLOR_BORDER
	var normal := _panel_style(bg, border, 3 if selected else 1)
	var hover := _panel_style(bg.lightened(0.06), COLOR_ACCENT, 2)
	var pressed := _panel_style(bg.lightened(0.10), COLOR_ACCENT, 3)
	var disabled := _panel_style(Color("#0e1217", 0.94), Color("#3b434e"), 1)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", pressed)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", COLOR_TEXT)
	button.add_theme_color_override("font_focus_color", COLOR_TEXT)
	button.add_theme_color_override("font_disabled_color", Color("#aeb5be"))

func _panel_style(bg: Color, border: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(6)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 9
	style.content_margin_bottom = 9
	return style

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
