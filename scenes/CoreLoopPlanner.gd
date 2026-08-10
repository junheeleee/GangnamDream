extends Control
## ORDER-76: 월간 계획판. 연락용 휴대폰과 분리해 네 주를 넓은 화면에서 정한다.

signal plan_committed(month_index: int, schedule: Dictionary, routines: Dictionary)
signal planner_closed
signal communication_requested(bundle_id: String)

const CORE_LOOP := preload("res://systems/DemoCoreLoopV2.gd")
const COLOR_BG := Color("#07090c", 1.0)
const COLOR_PANEL := Color("#10141a", 0.96)
const COLOR_PANEL_ALT := Color("#171c23", 0.96)
const COLOR_BORDER := Color("#4e5865")
const COLOR_TEXT := Color("#e7ebf0")
const COLOR_DIM := Color("#929ba7")
const COLOR_ACCENT := Color("#d8c38d")
const COLOR_CAREER := Color("#6ea8d8")
const COLOR_LIVELIHOOD := Color("#d5a45f")
const COLOR_GROWTH := Color("#78b99a")
const COLOR_RECOVERY := Color("#a58ad1")
const COLOR_RELATIONSHIP := Color("#d58b91")
const REVIEW_CONFIRM_DELAY_MSEC := 350

var _month_index := 1
var _month_data: Dictionary = {}
var _schedule: Dictionary = {}
var _routines: Dictionary = {}
var _locked_by_week: Dictionary = {}
var _selected_week := 1
var _selected_offer_id := ""
var _armed_offer_id := ""
var _placement_error := ""
var _detail_week := -1
var _active_tab := 1
var _workflow_step := 0
var _review_pending := false
var _read_only_plan := false
var _opened_once := false
var _last_opened_month := -1
var _pending_focus_offer_id := ""
var _pending_focus_routine_key := ""
var _last_focus_key := ""
var _focus_restore_generation := 0
var _compact_layout := false
var _review_confirm_release_required := false
var _review_confirm_not_before_msec := 0
var _using_recommended_routines := false
var _confirm_activation_from_mouse := false
var _review_mouse_double_click_blocked := false
var _review_mouse_single_click_armed := false

var _font: FontFile
var _font_bold: FontFile
var _page_margin: MarginContainer
var _page: VBoxContainer
var _title_label: Label
var _month_label: Label
var _step_buttons: Array[Button] = []
var _overview_button: Button
var _people_button: Button
var _communication_button: Button
var _close_button: Button
var _calendar_surface: HBoxContainer
var _calendar_right_column: VBoxContainer
var _calendar_column: VBoxContainer
var _offer_scroll: ScrollContainer
var _calendar_scroll: ScrollContainer
var _read_only_scroll: ScrollContainer
var _read_only_surface: VBoxContainer
var _offer_list: VBoxContainer
var _slot_list: VBoxContainer
var _offers_title_label: Label
var _weeks_title_label: Label
var _offer_buttons: Dictionary = {}
var _slot_buttons: Dictionary = {}
var _routine_buttons: Dictionary = {}
var _routine_focus_rows: Array = []
var _read_only_focus_controls: Array[Control] = []
var _routine_strip: PanelContainer
var _routine_summary_label: Label
var _routine_edit_button: Button
var _status_panel: PanelContainer
var _status_label: Label
var _detail_label: Label
var _hint_label: Label
var _edit_button: Button
var _confirm_button: Button

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	set_meta("core_loop_v2_planner", true)
	set_meta("core_loop_v2_month", _month_index)
	set_meta("core_loop_v2_review_pending", false)
	set_meta("core_loop_v2_armed_offer_id", "")
	z_index = 96
	mouse_filter = Control.MOUSE_FILTER_STOP
	_font = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile
	_build_ui()
	resized.connect(_apply_responsive_layout)
	LocaleManager.language_changed.connect(_on_language_changed)
	visible = false

func open(month_index: int, read_only: bool = false) -> bool:
	var reopen_same_month := _opened_once and _last_opened_month == month_index
	var was_read_only := _read_only_plan
	_month_index = month_index
	_month_data = CORE_LOOP.month_spec(month_index)
	_review_confirm_release_required = false
	_confirm_activation_from_mouse = false
	_review_mouse_double_click_blocked = false
	_review_mouse_single_click_armed = false
	# Reopening may preserve the draft schedule, but never a hidden final-review
	# state from before the phone or another overlay took ownership.
	_review_pending = false
	_clear_placement_intent()
	_detail_week = -1
	var committed_plan := CORE_LOOP.plan_for_month(month_index)
	if read_only and committed_plan.is_empty():
		visible = false
		return false
	_read_only_plan = read_only
	_locked_by_week = {}
	for raw_lock in _month_data.get("locked", []):
		if raw_lock is Dictionary:
			var lock: Dictionary = raw_lock
			var week := int(lock.get("week", 0))
			var bundle_id := str(lock.get("bundle", ""))
			if week > 0 and not bundle_id.is_empty():
				_locked_by_week[str(week)] = bundle_id
	if read_only:
		_schedule = _dictionary_copy(committed_plan.get("schedule", {}))
		_routines = _dictionary_copy(committed_plan.get("routines", {}))
		if _routines.is_empty():
			_routines = CORE_LOOP.default_routines()
		_using_recommended_routines = false
		_review_pending = false
	elif not reopen_same_month or was_read_only:
		_schedule = {}
		_routines = CORE_LOOP.default_routines()
		if not GameState.current_job.is_empty():
			_routines["primary"] = "livelihood"
		_using_recommended_routines = true
		_review_pending = false
		for week_key in _locked_by_week:
			_schedule[str(week_key)] = str(_locked_by_week[week_key])
	var weeks: Array = _month_data.get("weeks", [1, 4])
	_selected_week = int(weeks[0])
	for week in range(int(weeks[0]), int(weeks[1]) + 1):
		if not _locked_by_week.has(str(week)):
			_selected_week = week
			break
	_active_tab = 1
	_workflow_step = 0
	if not reopen_same_month or was_read_only or read_only:
		_last_focus_key = ""
	_last_opened_month = month_index
	_opened_once = true
	set_meta("core_loop_v2_month", _month_index)
	_pending_focus_offer_id = ""
	_pending_focus_routine_key = ""
	visible = true
	SceneTransition.set_playtest_marker_context(
		SceneTransition.PLAYTEST_MARKER_CONTEXT_PLANNER)
	_apply_responsive_layout()
	_rebuild()
	# The planner is a full-screen decision surface. Fading the whole node from
	# transparent exposed MainGame for a frame and made it look like a modal had
	# opened and immediately disappeared.
	modulate.a = 1.0
	return true
func close() -> void:
	var was_visible := visible
	if was_visible:
		_last_focus_key = _current_focus_key()
	visible = false
	_review_confirm_release_required = false
	_confirm_activation_from_mouse = false
	_review_mouse_double_click_blocked = false
	_review_mouse_single_click_armed = false
	if was_visible:
		SceneTransition.set_playtest_marker_context(
			SceneTransition.PLAYTEST_MARKER_CONTEXT_DEFAULT)
		AudioManager.play_ui_close(-11.0)
		planner_closed.emit()


func _process(_delta: float) -> void:
	if not _review_pending or not _review_confirm_release_required:
		return
	if Time.get_ticks_msec() < _review_confirm_not_before_msec:
		return
	if Input.is_action_pressed("ui_accept") \
			or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return
	_review_confirm_release_required = false
	_refresh_footer()

func schedule_snapshot() -> Dictionary:
	return _schedule.duplicate(true)

func routine_snapshot() -> Dictionary:
	return _routines.duplicate(true)

func review_pending() -> bool:
	return _review_pending

func read_only_plan() -> bool:
	return _read_only_plan

func armed_offer_id() -> String:
	return _armed_offer_id

func placement_error() -> String:
	return _placement_error

func focus_offer(bundle_id: String) -> bool:
	if not CORE_LOOP.available_offer_ids(_month_index).has(bundle_id):
		return false
	_review_pending = false
	_review_confirm_release_required = false
	_clear_placement_intent()
	_selected_offer_id = bundle_id
	_detail_week = -1
	_active_tab = 1
	_workflow_step = 0
	_pending_focus_offer_id = bundle_id
	if visible:
		_rebuild()
	return true

func _dictionary_copy(value: Variant) -> Dictionary:
	return (value as Dictionary).duplicate(true) if value is Dictionary else {}

func assign_offer_to_week(bundle_id: String, week: int) -> bool:
	if _read_only_plan:
		return false
	if not CORE_LOOP.available_offer_ids(_month_index).has(bundle_id):
		return false
	if not CORE_LOOP.bundle_allowed_in_week(bundle_id, week):
		return false
	if _locked_by_week.has(str(week)):
		return false
	var target_bundle := str(_schedule.get(str(week), ""))
	if not target_bundle.is_empty() and target_bundle != bundle_id:
		return false
	_review_pending = false
	_review_confirm_release_required = false
	for raw_week in _schedule.keys():
		if str(_schedule.get(raw_week, "")) == bundle_id:
			_schedule.erase(raw_week)
	_schedule[str(week)] = bundle_id
	_selected_offer_id = bundle_id
	_selected_week = week
	_detail_week = week
	_refresh_calendar()
	return true

func select_routine(slot: String, routine_id: String) -> bool:
	if _read_only_plan:
		return false
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
	_using_recommended_routines = false
	_review_pending = false
	_review_confirm_release_required = false
	var focus_key := "%s:%s" % [slot, routine_id]
	_pending_focus_routine_key = focus_key
	_rebuild()
	return true

func unassign_week(week: int) -> bool:
	if _read_only_plan:
		return false
	var week_key := str(week)
	if _locked_by_week.has(week_key) or not _schedule.has(week_key):
		return false
	_review_pending = false
	_review_confirm_release_required = false
	_schedule.erase(week_key)
	_placement_error = ""
	if _armed_offer_id.is_empty():
		_detail_week = week
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
	background_image.modulate = Color(0.34, 0.37, 0.43, 0.34)
	background_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background_image)

	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color("#07090c", 0.66)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	_page_margin = MarginContainer.new()
	_page_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_page_margin)

	_page = VBoxContainer.new()
	_page.add_theme_constant_override("separation", 14)
	_page_margin.add_child(_page)

	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 54)
	header.add_theme_constant_override("separation", 12)
	_page.add_child(header)
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titles.add_theme_constant_override("separation", 1)
	header.add_child(titles)
	_title_label = _label("", 28, COLOR_TEXT, true)
	_title_label.clip_text = true
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	titles.add_child(_title_label)
	_month_label = _label("", 14, COLOR_DIM)
	_month_label.clip_text = true
	_month_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_month_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	titles.add_child(_month_label)

	var header_actions := HBoxContainer.new()
	header_actions.add_theme_constant_override("separation", 6)
	header.add_child(header_actions)
	_overview_button = _button("", false)
	_overview_button.name = "PlannerOverviewButton"
	_overview_button.custom_minimum_size = Vector2(108, 42)
	_overview_button.pressed.connect(_open_info_view.bind(0))
	_overview_button.mouse_entered.connect(
		_focus_on_hover.bind(_overview_button))
	header_actions.add_child(_overview_button)
	_people_button = _button("", false)
	_people_button.name = "PlannerPeopleButton"
	_people_button.custom_minimum_size = Vector2(108, 42)
	_people_button.pressed.connect(_open_info_view.bind(2))
	_people_button.mouse_entered.connect(_focus_on_hover.bind(_people_button))
	header_actions.add_child(_people_button)
	_communication_button = _button("", false)
	_communication_button.name = "CommunicationButton"
	_communication_button.custom_minimum_size = Vector2(124, 42)
	_communication_button.tooltip_text = LocaleManager.ui(
		"문자와 통화 기록, 연락처를 연다.",
		"Open messages, call history, and contacts.")
	_communication_button.pressed.connect(_request_communication)
	_communication_button.mouse_entered.connect(
		_focus_on_hover.bind(_communication_button))
	header_actions.add_child(_communication_button)
	_close_button = _button("", false)
	_close_button.name = "PlannerCloseButton"
	_close_button.custom_minimum_size = Vector2(92, 42)
	_close_button.pressed.connect(close)
	_close_button.mouse_entered.connect(_focus_on_hover.bind(_close_button))
	header_actions.add_child(_close_button)

	var step_rail := HBoxContainer.new()
	step_rail.name = "PlannerStepRail"
	step_rail.custom_minimum_size = Vector2(0, 38)
	step_rail.add_theme_constant_override("separation", 8)
	_page.add_child(step_rail)
	for index in range(3):
		var step_button := _button("", false)
		step_button.name = "PlannerStep%d" % (index + 1)
		step_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		step_button.custom_minimum_size = Vector2(0, 38)
		step_button.set_meta("core_loop_v2_workflow_step", index)
		step_button.pressed.connect(_switch_workflow_step.bind(index))
		step_button.mouse_entered.connect(_focus_on_hover.bind(step_button))
		step_rail.add_child(step_button)
		_step_buttons.append(step_button)

	var divider := HSeparator.new()
	divider.add_theme_color_override("color", Color("#343b45"))
	_page.add_child(divider)

	_calendar_surface = HBoxContainer.new()
	_calendar_surface.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_calendar_surface.add_theme_constant_override("separation", 22)
	_page.add_child(_calendar_surface)

	var offers_column := VBoxContainer.new()
	offers_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	offers_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	offers_column.add_theme_constant_override("separation", 8)
	_calendar_surface.add_child(offers_column)
	_offers_title_label = _section_title("")
	offers_column.add_child(_offers_title_label)
	_offer_scroll = ScrollContainer.new()
	_offer_scroll.name = "OfferScroll"
	_offer_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_offer_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_offer_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_offer_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_offer_scroll.follow_focus = true
	offers_column.add_child(_offer_scroll)
	_offer_list = VBoxContainer.new()
	_offer_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_offer_list.add_theme_constant_override("separation", 7)
	_offer_scroll.add_child(_offer_list)

	_calendar_right_column = VBoxContainer.new()
	_calendar_right_column.custom_minimum_size = Vector2(420, 0)
	_calendar_right_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_calendar_right_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_calendar_right_column.add_theme_constant_override("separation", 8)
	_calendar_surface.add_child(_calendar_right_column)

	_calendar_scroll = ScrollContainer.new()
	_calendar_scroll.name = "FourWeekScroll"
	_calendar_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_calendar_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_calendar_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_calendar_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_calendar_scroll.follow_focus = true
	_calendar_right_column.add_child(_calendar_scroll)
	_calendar_column = VBoxContainer.new()
	_calendar_column.custom_minimum_size = Vector2(400, 0)
	_calendar_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_calendar_column.add_theme_constant_override("separation", 8)
	_calendar_scroll.add_child(_calendar_column)
	_weeks_title_label = _section_title("")
	_calendar_column.add_child(_weeks_title_label)
	_slot_list = VBoxContainer.new()
	_slot_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_slot_list.add_theme_constant_override("separation", 7)
	_calendar_column.add_child(_slot_list)
	_detail_label = _label("", 14, COLOR_DIM)
	_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_label.custom_minimum_size = Vector2(0, 58)
	_calendar_column.add_child(_detail_label)
	_status_panel = PanelContainer.new()
	_status_panel.name = "PlannerStatusPanel"
	_status_panel.add_theme_stylebox_override(
		"panel", _panel_style(Color("#15191f", 0.98), COLOR_ACCENT, 1))
	_calendar_column.add_child(_status_panel)
	var status_margin := MarginContainer.new()
	status_margin.add_theme_constant_override("margin_left", 12)
	status_margin.add_theme_constant_override("margin_right", 12)
	status_margin.add_theme_constant_override("margin_top", 8)
	status_margin.add_theme_constant_override("margin_bottom", 8)
	_status_panel.add_child(status_margin)
	_status_label = _label("", 14, COLOR_ACCENT, true)
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_margin.add_child(_status_label)
	# Keep the actionable placement state above the optional detail prose so it
	# remains visible at the 960x600 fallback resolution.
	_calendar_column.move_child(_status_panel, _detail_label.get_index())

	_routine_strip = PanelContainer.new()
	_routine_strip.name = "PlannerRoutineStrip"
	_routine_strip.add_theme_stylebox_override(
		"panel", _panel_style(Color("#111821", 0.98), COLOR_GROWTH, 1))
	_calendar_right_column.add_child(_routine_strip)
	var routine_margin := MarginContainer.new()
	routine_margin.add_theme_constant_override("margin_left", 12)
	routine_margin.add_theme_constant_override("margin_right", 10)
	routine_margin.add_theme_constant_override("margin_top", 7)
	routine_margin.add_theme_constant_override("margin_bottom", 7)
	_routine_strip.add_child(routine_margin)
	var routine_row := HBoxContainer.new()
	routine_row.add_theme_constant_override("separation", 10)
	routine_margin.add_child(routine_row)
	_routine_summary_label = _label("", 14, COLOR_TEXT, true)
	_routine_summary_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_routine_summary_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_routine_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	routine_row.add_child(_routine_summary_label)
	_routine_edit_button = _button("", false)
	_routine_edit_button.name = "PlannerRoutineEditButton"
	_routine_edit_button.custom_minimum_size = Vector2(96, 46)
	_routine_edit_button.pressed.connect(_open_routine_editor)
	_routine_edit_button.mouse_entered.connect(
		_focus_on_hover.bind(_routine_edit_button))
	routine_row.add_child(_routine_edit_button)

	_read_only_scroll = ScrollContainer.new()
	_read_only_scroll.name = "PlannerReadOnlyScroll"
	_read_only_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_read_only_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_read_only_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_read_only_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_read_only_scroll.follow_focus = true
	_page.add_child(_read_only_scroll)
	_read_only_surface = VBoxContainer.new()
	_read_only_surface.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_read_only_surface.add_theme_constant_override("separation", 12)
	_read_only_scroll.add_child(_read_only_surface)

	var footer := HBoxContainer.new()
	footer.custom_minimum_size = Vector2(0, 52)
	footer.add_theme_constant_override("separation", 14)
	_page.add_child(footer)
	_hint_label = _label("", 14, COLOR_DIM)
	_hint_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footer.add_child(_hint_label)
	_edit_button = _button("", false)
	_edit_button.name = "PlannerReviewEditButton"
	_edit_button.set_meta("core_loop_v2_review_edit", true)
	_edit_button.custom_minimum_size = Vector2(150, 48)
	_edit_button.pressed.connect(_cancel_commit_review)
	_edit_button.mouse_entered.connect(_focus_on_hover.bind(_edit_button))
	footer.add_child(_edit_button)
	_confirm_button = _button("", true)
	_confirm_button.set_meta("core_loop_v2_plan_confirm", true)
	_confirm_button.custom_minimum_size = Vector2(330, 48)
	_confirm_button.pressed.connect(_commit_plan)
	_confirm_button.gui_input.connect(_on_confirm_gui_input)
	_confirm_button.mouse_entered.connect(_focus_on_hover.bind(_confirm_button))
	footer.add_child(_confirm_button)
	_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	if not is_instance_valid(_page_margin):
		return
	var layout_size := size
	var visible_size := get_viewport().get_visible_rect().size
	if visible_size.x > 0.0 and visible_size.y > 0.0:
		layout_size.x = minf(layout_size.x, visible_size.x)
		layout_size.y = minf(layout_size.y, visible_size.y)
	_compact_layout = layout_size.x < 1100.0 or layout_size.y < 690.0
	var side_margin := 24 if _compact_layout else 42
	var top_margin := 18 if _compact_layout else 24
	var bottom_margin := 16 if _compact_layout else 22
	_page_margin.add_theme_constant_override("margin_left", side_margin)
	_page_margin.add_theme_constant_override("margin_right", side_margin)
	_page_margin.add_theme_constant_override("margin_top", top_margin)
	_page_margin.add_theme_constant_override("margin_bottom", bottom_margin)
	_page.add_theme_constant_override("separation", 10 if _compact_layout else 14)
	_calendar_surface.add_theme_constant_override(
		"separation", 14 if _compact_layout else 22)
	_calendar_right_column.custom_minimum_size = Vector2(
		340 if _compact_layout else 420, 0)
	_calendar_column.custom_minimum_size = Vector2(
		320 if _compact_layout else 400, 0)
	_title_label.add_theme_font_size_override(
		"font_size", 26 if _compact_layout else 28)
	for info_button in [_overview_button, _people_button]:
		info_button.custom_minimum_size = Vector2(
			80 if _compact_layout else 108,
			40 if _compact_layout else 42)
		info_button.add_theme_font_size_override("font_size", 15)
	_communication_button.custom_minimum_size = Vector2(
		104 if _compact_layout else 124,
		40 if _compact_layout else 42)
	_close_button.custom_minimum_size = Vector2(
		70 if _compact_layout else 92,
		40 if _compact_layout else 42)
	for step_button in _step_buttons:
		step_button.custom_minimum_size.y = 46
		step_button.add_theme_font_size_override(
			"font_size", 14 if _compact_layout else 15)
	_edit_button.custom_minimum_size = Vector2(
		118 if _compact_layout else 150,
		46 if _compact_layout else 48)
	_confirm_button.custom_minimum_size = Vector2(
		260 if _compact_layout else 330,
		46 if _compact_layout else 48)
	_routine_edit_button.custom_minimum_size = Vector2(
		82 if _compact_layout else 96, 46)
	_detail_label.custom_minimum_size = Vector2(
		0, 40 if _compact_layout else 58)
	for raw_button in _offer_buttons.values():
		if raw_button is Button:
			(raw_button as Button).custom_minimum_size = Vector2(
				0, 58 if _compact_layout else 62)
	for raw_button in _slot_buttons.values():
		if raw_button is Button:
			(raw_button as Button).custom_minimum_size = Vector2(
				0, 56 if _compact_layout else 76)


func _request_communication() -> void:
	communication_requested.emit(_selected_offer_id)


func _open_routine_editor() -> void:
	_clear_placement_intent()
	_review_pending = false
	_review_confirm_release_required = false
	_active_tab = 3
	_workflow_step = 1
	var primary_id := str(_routines.get("primary", ""))
	_pending_focus_routine_key = "primary:%s" % primary_id
	_last_focus_key = ""
	_rebuild()


func _rebuild() -> void:
	set_meta("core_loop_v2_review_pending", _review_pending)
	_title_label.text = LocaleManager.ui(
		"%d월 · %s", "MONTH %d · %s") % [
			_month_index,
			_localized(_month_data, "title"),
		]
	if _read_only_plan:
		_month_label.text = LocaleManager.ui(
			"확정한 일정과 매주 할 일을 확인한다. 이달 계획은 바꿀 수 없다.",
			"Review the confirmed schedule and weekly routines. This plan is locked.")
	elif _review_pending:
		_month_label.text = LocaleManager.ui(
			"이번 달에 할 일과 고르지 않은 제안을 확인한 뒤 확정한다.",
			"Review what you scheduled and which options you left out, then confirm.")
	else:
		_month_label.text = LocaleManager.ui(
			"이번 달 제안을 네 주에 나눠 넣고, 매주 이어 갈 일을 정한다.",
			"Place this month's options across four weeks and choose what to keep doing weekly.")
	_overview_button.text = LocaleManager.ui("현황", "OVERVIEW")
	_people_button.text = LocaleManager.ui("사람", "PEOPLE")
	_apply_button_style(_overview_button, _active_tab == 0, false)
	_apply_button_style(_people_button, _active_tab == 2, false)
	var badge_count := _communication_badge_count()
	_communication_button.text = LocaleManager.ui(
		"휴대폰%s" % (" · %d" % badge_count if badge_count > 0 else ""),
		"PHONE%s" % (" · %d" % badge_count if badge_count > 0 else ""))
	_communication_button.tooltip_text = LocaleManager.ui(
		"문자와 통화 기록, 연락처를 연다.",
		"Open messages, call history, and contacts.")
	_close_button.text = LocaleManager.ui("닫기", "CLOSE")
	_close_button.visible = _read_only_plan
	_edit_button.text = LocaleManager.ui("일정 수정", "EDIT PLAN")
	_edit_button.visible = _review_pending and not _read_only_plan
	_refresh_step_rail()
	_calendar_surface.visible = _active_tab == 1
	_read_only_scroll.visible = _active_tab != 1
	if _active_tab == 1:
		_rebuild_calendar()
	else:
		_rebuild_read_only_surface()
		_connect_non_calendar_focus_neighbors()
	# Keep the persistent schedule summary truthful even while its surface is
	# hidden behind the weekly-activity or review step.
	_refresh_routine_strip()
	_connect_header_focus_neighbors()
	_apply_responsive_layout()
	_refresh_footer()
	_focus_restore_generation += 1
	call_deferred(
		"_restore_focus_after_rebuild", _focus_restore_generation)


func _connect_non_calendar_focus_neighbors() -> void:
	var active_navigation := _active_navigation_control()
	if not is_instance_valid(active_navigation):
		return
	if _active_tab == 3 or not _read_only_focus_controls.is_empty():
		_connect_read_only_focus_neighbors(active_navigation)
		return
	var footer_top: Control = active_navigation
	if _review_pending and is_instance_valid(_edit_button):
		_edit_button.focus_neighbor_top = _edit_button.get_path_to(active_navigation)
		_edit_button.focus_neighbor_right = _edit_button.get_path_to(_confirm_button)
		_confirm_button.focus_neighbor_left = _confirm_button.get_path_to(_edit_button)
		footer_top = _edit_button
	_confirm_button.focus_neighbor_top = _confirm_button.get_path_to(active_navigation)
	_confirm_button.focus_neighbor_bottom = _confirm_button.get_path_to(
		_confirm_button)
	active_navigation.focus_neighbor_bottom = active_navigation.get_path_to(footer_top)


func _connect_read_only_focus_neighbors(active_navigation: Control) -> void:
	_reset_footer_focus_neighbors()
	var validation := CORE_LOOP.validate_plan(
		_month_index, _schedule, _routines)
	var plan_ready := _read_only_plan or (
		bool(validation.get("ok", false)) and _armed_offer_id.is_empty())
	var footer_target: Control = active_navigation
	if _review_pending:
		footer_target = _edit_button
	elif plan_ready:
		footer_target = _confirm_button
	var first_content: Control = null
	var last_routine: Control = null

	for row_index in range(_routine_focus_rows.size()):
		var row: Array = _routine_focus_rows[row_index]
		if row.is_empty():
			continue
		if not is_instance_valid(first_content):
			first_content = row[0] as Control
		var prior_row: Array = _routine_focus_rows[row_index - 1] \
			if row_index > 0 else []
		var next_row: Array = _routine_focus_rows[row_index + 1] \
			if row_index + 1 < _routine_focus_rows.size() else []
		for column_index in range(row.size()):
			var button := row[column_index] as Control
			var left_target: Control = row[maxi(column_index - 1, 0)] as Control
			var right_target: Control = row[mini(
				column_index + 1, row.size() - 1)] as Control
			var top_target: Control = active_navigation
			if not prior_row.is_empty():
				top_target = prior_row[mini(
					column_index, prior_row.size() - 1)] as Control
			var bottom_target: Control = null
			if not next_row.is_empty():
				bottom_target = next_row[mini(
					column_index, next_row.size() - 1)] as Control
			elif not _read_only_focus_controls.is_empty():
				bottom_target = _read_only_focus_controls[0]
			else:
				bottom_target = footer_target
			button.focus_neighbor_left = button.get_path_to(left_target)
			button.focus_neighbor_right = button.get_path_to(right_target)
			button.focus_neighbor_top = button.get_path_to(top_target)
			button.focus_neighbor_bottom = button.get_path_to(bottom_target)
		last_routine = row[0] as Control

	var prior_content: Control = last_routine \
		if is_instance_valid(last_routine) else active_navigation
	for index in range(_read_only_focus_controls.size()):
		var control := _read_only_focus_controls[index]
		if not is_instance_valid(first_content):
			first_content = control
		var next_content: Control = null
		if index + 1 < _read_only_focus_controls.size():
			next_content = _read_only_focus_controls[index + 1]
		else:
			next_content = footer_target
		control.focus_neighbor_left = control.get_path_to(control)
		control.focus_neighbor_right = control.get_path_to(control)
		control.focus_neighbor_top = control.get_path_to(prior_content)
		control.focus_neighbor_bottom = control.get_path_to(next_content)
		prior_content = control

	if not is_instance_valid(first_content):
		first_content = footer_target
	active_navigation.focus_neighbor_bottom = active_navigation.get_path_to(first_content)
	var last_content: Control = prior_content \
		if prior_content != active_navigation else first_content
	if _review_pending:
		_edit_button.focus_neighbor_top = _edit_button.get_path_to(last_content)
		_edit_button.focus_neighbor_right = _edit_button.get_path_to(_confirm_button)
		_confirm_button.focus_neighbor_left = _confirm_button.get_path_to(_edit_button)
	_confirm_button.focus_neighbor_top = _confirm_button.get_path_to(
		last_content if plan_ready or _review_pending else active_navigation)
	_confirm_button.focus_neighbor_bottom = _confirm_button.get_path_to(
		_confirm_button)


func _refresh_step_rail() -> void:
	if _step_buttons.size() != 3:
		return
	var week_count := _filled_week_count()
	var week_remaining := maxi(4 - week_count, 0)
	var routine_count := _routine_choice_count()
	var routine_valid := _read_only_plan or _routine_choices_valid()
	var validation := CORE_LOOP.validate_plan(_month_index, _schedule, _routines)
	# A confirmed plan is a historical record. Current availability may change
	# after its weeks execute, but that must not rewrite a once-valid 4/4 record
	# as CHECK when the player reopens it.
	var schedule_valid := (_read_only_plan and week_count == 4) \
		or _schedule_choices_valid(validation)
	var final_ready := bool(validation.get("ok", false)) \
		and _armed_offer_id.is_empty()
	var labels := [
		LocaleManager.ui(
			("1단계 · 주차 {done}/4 · 완료" if schedule_valid
			else "1단계 · 주차 {done}/4 · 확인 필요") if week_remaining == 0
			else "1단계 · 주차 {done}/4 · {left}개 남음",
			("STEP 1 · WEEKS {done}/4 · DONE" if schedule_valid
			else "STEP 1 · WEEKS {done}/4 · CHECK") if week_remaining == 0
			else "STEP 1 · WEEKS {done}/4 · {left} LEFT").format({
				"done": week_count,
				"left": week_remaining,
			}),
		LocaleManager.ui(
			"2단계 · 매주 할 일 {done}/2 · 완료" if routine_valid
			else (
				"2단계 · 매주 할 일 {done}/2 · 확인 필요" if routine_count >= 2
				else "2단계 · 매주 할 일 {done}/2 · {left}개 남음"),
			"STEP 2 · ROUTINES {done}/2 · DONE" if routine_valid
			else (
				"STEP 2 · ROUTINES {done}/2 · CHECK" if routine_count >= 2
				else "STEP 2 · ROUTINES {done}/2 · {left} LEFT")).format({
				"done": routine_count,
				"left": maxi(2 - routine_count, 0),
			}),
		LocaleManager.ui(
			"3단계 · 최종 확인 · 확정됨" if _read_only_plan else (
				"3단계 · 최종 확인 · 준비됨" if final_ready
				else "3단계 · 최종 확인 · %s" % _plan_blocker_short(validation)),
			"STEP 3 · FINAL REVIEW · CONFIRMED" if _read_only_plan else (
				"STEP 3 · FINAL REVIEW · READY" if final_ready
				else "STEP 3 · FINAL REVIEW · %s" % _plan_blocker_short(validation))),
	]
	for index in range(3):
		var completed := (
			(index == 0 and schedule_valid)
			or (index == 1 and routine_valid)
			or (index == 2 and (_read_only_plan or final_ready))
		)
		var active := _active_tab not in [0, 2] and index == _workflow_step
		var step_button := _step_buttons[index]
		step_button.text = labels[index]
		step_button.set_meta("core_loop_v2_progress_complete", completed)
		_apply_button_style(step_button, active, completed)


func _schedule_choices_valid(validation: Dictionary) -> bool:
	if _filled_week_count() != 4:
		return false
	return str(validation.get("error", "")) in [
		"", "choose_two_routines", "routines_must_be_distinct",
		"unknown_routine", "job_requires_primary_livelihood",
	]


func _filled_week_count() -> int:
	var count := 0
	var weeks: Array = _month_data.get("weeks", [1, 4])
	for week in range(int(weeks[0]), int(weeks[1]) + 1):
		if not str(_schedule.get(str(week), "")).is_empty():
			count += 1
	return count


func _routine_choice_count() -> int:
	var options := CORE_LOOP.routine_options()
	var counted: Array[String] = []
	for slot in ["primary", "secondary"]:
		var routine_id := str(_routines.get(slot, "")).strip_edges()
		if routine_id.is_empty() or not options.has(routine_id) \
				or counted.has(routine_id):
			continue
		counted.append(routine_id)
	return counted.size()


func _routine_choices_valid() -> bool:
	return bool(CORE_LOOP.validate_routines(_routines).get("ok", false))


func _plan_blocker_short(validation: Dictionary) -> String:
	if not _armed_offer_id.is_empty():
		return LocaleManager.ui(
			"제안 배치 또는 취소", "PLACE/CANCEL OFFER")
	var error := str(validation.get("error", ""))
	match error:
		"fill_four_weeks", "empty_week":
			var weeks_left := maxi(4 - _filled_week_count(), 0)
			return LocaleManager.ui(
				"주차 %d개 남음" % weeks_left,
				"%d %s LEFT" % [weeks_left, "WEEK" if weeks_left == 1 else "WEEKS"])
		"choose_two_routines":
			var routines_left := maxi(2 - _routine_choice_count(), 0)
			return LocaleManager.ui(
				"매주 할 일 %d개 남음" % routines_left,
				"%d %s LEFT" % [routines_left, "ROUTINE" if routines_left == 1 else "ROUTINES"])
		"routines_must_be_distinct":
			return LocaleManager.ui(
				"서로 다른 2개 필요", "CHOOSE 2 DIFFERENT")
		"unknown_routine":
			return LocaleManager.ui(
				"고를 수 없는 항목", "ROUTINE UNAVAILABLE")
		"job_requires_primary_livelihood":
			return LocaleManager.ui(
				"본업을 주 루틴으로 선택", "CHOOSE JOB AS PRIMARY")
		"deadline_missed":
			return LocaleManager.ui("기한 지난 주차", "DEADLINE MISSED")
		"exclusive_group":
			return LocaleManager.ui("겹치는 만남", "MEETINGS OVERLAP")
		"active_named_characters_cap":
			return LocaleManager.ui("사람 약속 줄이기", "REDUCE MEETUPS")
		"unavailable_bundle":
			return LocaleManager.ui("제안 다시 선택", "RESELECT OFFER")
		"locked_week_changed":
			return LocaleManager.ui("고정 일정 복원", "RESTORE FIXED EVENT")
		"duplicate_bundle":
			return LocaleManager.ui("중복 일정 제거", "REMOVE DUPLICATE")
		"":
			return LocaleManager.ui("확인 필요", "CHECK")
	return LocaleManager.ui("일정 수정", "FIX SCHEDULE")


func _active_navigation_control() -> Control:
	if _active_tab == 0:
		return _overview_button
	if _active_tab == 2:
		return _people_button
	if _workflow_step >= 0 and _workflow_step < _step_buttons.size():
		return _step_buttons[_workflow_step]
	return null


func _connect_header_focus_neighbors() -> void:
	var active_navigation := _active_navigation_control()
	var header_controls: Array[Control] = [
		_overview_button, _people_button, _communication_button,
	]
	if _close_button.visible:
		header_controls.append(_close_button)
	for index in range(header_controls.size()):
		var control := header_controls[index]
		var left := header_controls[maxi(index - 1, 0)]
		var right := header_controls[mini(index + 1, header_controls.size() - 1)]
		control.focus_neighbor_left = control.get_path_to(left)
		control.focus_neighbor_right = control.get_path_to(right)
		control.focus_neighbor_top = control.get_path_to(control)
		if control != active_navigation:
			control.focus_neighbor_bottom = control.get_path_to(_step_buttons[0])
	for index in range(_step_buttons.size()):
		var step_button := _step_buttons[index]
		step_button.focus_neighbor_left = step_button.get_path_to(
			_step_buttons[maxi(index - 1, 0)])
		step_button.focus_neighbor_right = step_button.get_path_to(
			_step_buttons[mini(index + 1, _step_buttons.size() - 1)])
		step_button.focus_neighbor_top = step_button.get_path_to(_overview_button)
		if step_button != active_navigation:
			step_button.focus_neighbor_bottom = step_button.get_path_to(step_button)


func _communication_badge_count() -> int:
	var ids: Array[String] = []
	for bundle_id in CORE_LOOP.available_offer_ids(_month_index):
		var offer := CORE_LOOP.bundle(bundle_id)
		if str(offer.get("phone_surface", "")) in ["inbound_message", "call_log"]:
			ids.append(bundle_id)
	for bundle_id in CORE_LOOP.received_phone_consequence_ids(_month_index):
		if not ids.has(bundle_id):
			ids.append(bundle_id)
	return ids.size()


func _rebuild_calendar() -> void:
	_clear_children(_offer_list)
	_clear_children(_slot_list)
	_offer_buttons.clear()
	_slot_buttons.clear()
	var available := CORE_LOOP.available_offer_ids(_month_index)
	if not available.has(_selected_offer_id):
		_selected_offer_id = str(available[0]) if not available.is_empty() else ""
	for bundle_id in available:
		var offer := CORE_LOOP.bundle(bundle_id)
		var text := "%s · %s\n%s" % [
			_offer_kind_label(str(offer.get("kind", ""))),
			_localized(offer, "offer"),
			_localized(offer, "deadline"),
		]
		var offer_button := _button(text, false)
		offer_button.set_meta("core_loop_v2_offer_id", bundle_id)
		offer_button.name = "Offer_%s" % bundle_id
		offer_button.custom_minimum_size = Vector2(
			0, 58 if _compact_layout else 62)
		offer_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		offer_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		offer_button.icon = _offer_kind_icon(str(offer.get("kind", "")))
		offer_button.expand_icon = false
		offer_button.pressed.connect(_assign_offer.bind(bundle_id))
		offer_button.focus_entered.connect(_offer_focused.bind(bundle_id))
		offer_button.mouse_entered.connect(_focus_on_hover.bind(offer_button))
		_offer_list.add_child(offer_button)
		_offer_buttons[bundle_id] = offer_button

	var weeks: Array = _month_data.get("weeks", [1, 4])
	for week in range(int(weeks[0]), int(weeks[1]) + 1):
		var slot_button := _button("", false)
		slot_button.set_meta("core_loop_v2_week", week)
		slot_button.name = "Week_%d" % week
		slot_button.custom_minimum_size = Vector2(
			0, 68 if _compact_layout else 76)
		slot_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		slot_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		slot_button.pressed.connect(_select_week.bind(week))
		slot_button.focus_entered.connect(_week_focused.bind(week))
		slot_button.mouse_entered.connect(_focus_on_hover.bind(slot_button))
		_slot_list.add_child(slot_button)
		_slot_buttons[str(week)] = slot_button
	_refresh_calendar()


func _refresh_calendar() -> void:
	var available := CORE_LOOP.available_offer_ids(_month_index)
	set_meta("core_loop_v2_armed_offer_id", _armed_offer_id)
	_offers_title_label.text = LocaleManager.ui(
		"이번 달 제안 {total}개",
		"{total} OPTIONS THIS MONTH").format({
			"total": available.size(),
		})
	var filled_weeks := _filled_week_count()
	_weeks_title_label.text = LocaleManager.ui(
		"네 주의 일정 · {done}/4",
		"FOUR-WEEK SCHEDULE · {done}/4").format({
			"done": filled_weeks,
		})
	for bundle_id in available:
		var button: Button = _offer_buttons.get(bundle_id)
		if not is_instance_valid(button):
			continue
		var assigned := _schedule.values().has(bundle_id)
		var armed := bundle_id == _armed_offer_id
		var offer := CORE_LOOP.bundle(bundle_id)
		var state_labels: Array[String] = []
		if armed:
			state_labels.append(LocaleManager.ui("선택 중", "SELECTED"))
		if assigned:
			state_labels.append(LocaleManager.ui("일정에 넣음", "SCHEDULED"))
		var state_prefix := ""
		if not state_labels.is_empty():
			state_prefix = "%s · " % " · ".join(state_labels)
		var kind := str(offer.get("kind", ""))
		button.text = "%s%s · %s\n%s" % [
			state_prefix,
			_offer_kind_label(kind),
			_localized(offer, "offer"),
			_localized(offer, "deadline"),
		]
		button.set_meta("core_loop_v2_offer_armed", armed)
		_apply_offer_style(button, kind, armed, assigned)

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
					" · 고정 일정" if locked else "",
					_localized(scene_bundle, "offer"),
				],
				"WEEK %d%s\n%s" % [
					week_in_month,
					" · FIXED EVENT" if locked else "",
					_localized(scene_bundle, "offer"),
				])
		_set_button_disabled(button, locked)
		_apply_week_style(
			button, bundle_id, week == _selected_week, locked)

	_refresh_routine_strip()
	_refresh_calendar_detail()
	_connect_calendar_focus_neighbors()
	_refresh_step_rail()
	_refresh_footer()


func _refresh_calendar_detail() -> void:
	if _armed_offer_id.is_empty() and _detail_week > 0:
		var week_key := str(_detail_week)
		var week_in_month := posmod(_detail_week - 1, 4) + 1
		var week_bundle_id := str(_schedule.get(week_key, ""))
		if week_bundle_id.is_empty():
			_detail_label.text = LocaleManager.ui(
				"%d주차는 비어 있다.\n왼쪽에서 할 일을 고른 뒤 이 주를 눌러 일정에 넣는다." % week_in_month,
				"WEEK %d is open.\nChoose an offer on the left, then press this week to place it." % week_in_month)
			return
		var week_offer := CORE_LOOP.bundle(week_bundle_id)
		_detail_label.text = LocaleManager.ui(
			"%d주차 · %s\n%s" % [
				week_in_month, _localized(week_offer, "offer"),
				_localized(week_offer, "detail"),
			],
			"WEEK %d · %s\n%s" % [
				week_in_month, _localized(week_offer, "offer"),
				_localized(week_offer, "detail"),
			])
		return

	var selected_offer := CORE_LOOP.bundle(_selected_offer_id)
	if selected_offer.is_empty():
		_detail_label.text = LocaleManager.ui(
			"제안을 고르면 장소와 기한, 고르지 않았을 때 생기는 일을 볼 수 있다.",
			"Choose an option to see its place, deadline, and what happens if you leave it out.")
		return
	_detail_label.text = "%s\n%s: %s" % [
		_localized(selected_offer, "detail"),
		LocaleManager.ui("고르지 않으면", "IF LEFT OUT"),
		_localized(selected_offer, "decline"),
	]


func _refresh_routine_strip() -> void:
	if not is_instance_valid(_routine_summary_label):
		return
	var options := CORE_LOOP.routine_options()
	var primary: Dictionary = options.get(str(_routines.get("primary", "")), {})
	var secondary: Dictionary = options.get(str(_routines.get("secondary", "")), {})
	var primary_name := _localized(primary, "label")
	var secondary_name := _localized(secondary, "label")
	var summary_template := LocaleManager.ui(
		"추천 기본값 적용됨\n{primary} + {secondary}",
		"RECOMMENDED DEFAULTS APPLIED\n{primary} + {secondary}") \
		if _using_recommended_routines and not _read_only_plan else \
		LocaleManager.ui(
			"매주 반복\n{primary} + {secondary}",
			"EVERY WEEK\n{primary} + {secondary}")
	_routine_summary_label.text = summary_template.format({
			"primary": primary_name if not primary_name.is_empty() else "—",
			"secondary": secondary_name if not secondary_name.is_empty() else "—",
		})
	_routine_edit_button.text = LocaleManager.ui(
		"전체 보기" if _read_only_plan else "변경",
		"VIEW" if _read_only_plan else "CHANGE")
	_routine_edit_button.tooltip_text = LocaleManager.ui(
		"매주 반복할 두 가지를 확인한다."
			if _read_only_plan else "매주 반복할 두 가지를 바꾼다.",
		"Review the two weekly routines."
			if _read_only_plan else "Change the two weekly routines.")


func _connect_calendar_focus_neighbors() -> void:
	_reset_footer_focus_neighbors()
	var offer_controls: Array[Control] = []
	for bundle_id in CORE_LOOP.available_offer_ids(_month_index):
		var offer_button: Control = _offer_buttons.get(bundle_id) as Control
		if is_instance_valid(offer_button):
			offer_controls.append(offer_button)

	var enabled_week_controls: Array[Control] = []
	var all_week_controls: Array[Control] = []
	var weeks: Array = _month_data.get("weeks", [1, 4])
	for week in range(int(weeks[0]), int(weeks[1]) + 1):
		var week_button: Button = _slot_buttons.get(str(week)) as Button
		if not is_instance_valid(week_button):
			continue
		all_week_controls.append(week_button)
		if not week_button.disabled:
			enabled_week_controls.append(week_button)

	if offer_controls.is_empty() or enabled_week_controls.is_empty():
		return
	var validation := CORE_LOOP.validate_plan(
		_month_index, _schedule, _routines)
	var plan_ready := bool(validation.get("ok", false)) \
		and _armed_offer_id.is_empty()
	var footer_target: Control = _confirm_button \
		if plan_ready else _step_buttons[0]

	var right_target: Button = _slot_buttons.get(str(_selected_week)) as Button
	if not is_instance_valid(right_target) or right_target.disabled:
		right_target = enabled_week_controls[0] as Button
	var left_target: Button = _offer_buttons.get(_armed_offer_id) as Button
	if not is_instance_valid(left_target):
		left_target = _offer_buttons.get(_selected_offer_id) as Button
	if not is_instance_valid(left_target):
		left_target = offer_controls[0] as Button

	for index in range(offer_controls.size()):
		var button := offer_controls[index]
		var top_target: Control = offer_controls[index - 1] \
			if index > 0 else _step_buttons[0]
		var bottom_target: Control = offer_controls[index + 1] \
			if index + 1 < offer_controls.size() else footer_target
		button.focus_neighbor_left = button.get_path_to(button)
		button.focus_neighbor_right = button.get_path_to(right_target)
		button.focus_neighbor_top = button.get_path_to(top_target)
		button.focus_neighbor_bottom = button.get_path_to(bottom_target)

	for index in range(all_week_controls.size()):
		var button := all_week_controls[index]
		var prior_enabled: Control = _step_buttons[0]
		var next_enabled: Control = _routine_edit_button
		for candidate_index in range(enabled_week_controls.size()):
			var candidate := enabled_week_controls[candidate_index]
			if candidate == button:
				if candidate_index > 0:
					prior_enabled = enabled_week_controls[candidate_index - 1]
				if candidate_index + 1 < enabled_week_controls.size():
					next_enabled = enabled_week_controls[candidate_index + 1]
				break
			if candidate.position.y < button.position.y:
				prior_enabled = candidate
			elif candidate.position.y > button.position.y \
					and next_enabled == _routine_edit_button:
				next_enabled = candidate
		button.focus_neighbor_left = button.get_path_to(left_target)
		button.focus_neighbor_right = button.get_path_to(button)
		button.focus_neighbor_top = button.get_path_to(prior_enabled)
		button.focus_neighbor_bottom = button.get_path_to(next_enabled)

	var first_offer := offer_controls[0]
	var last_week := enabled_week_controls[enabled_week_controls.size() - 1]
	_step_buttons[0].focus_neighbor_bottom = _step_buttons[0].get_path_to(first_offer)
	_routine_edit_button.focus_neighbor_top = _routine_edit_button.get_path_to(last_week)
	_routine_edit_button.focus_neighbor_bottom = _routine_edit_button.get_path_to(
		footer_target)
	_routine_edit_button.focus_neighbor_left = _routine_edit_button.get_path_to(
		left_target)
	_confirm_button.focus_neighbor_top = _confirm_button.get_path_to(
		_routine_edit_button if plan_ready else _step_buttons[0])


func _reset_footer_focus_neighbors() -> void:
	# Rebuilds reuse the footer controls. Clear every review-only edge before
	# reconnecting the visible surface so a hidden Edit button can never remain
	# in the Calendar or confirmed-plan focus graph.
	for control in [_edit_button, _confirm_button]:
		if not is_instance_valid(control):
			continue
		var self_path: NodePath = control.get_path_to(control)
		control.focus_neighbor_left = self_path
		control.focus_neighbor_right = self_path
		control.focus_neighbor_top = self_path
		control.focus_neighbor_bottom = self_path


func _rebuild_read_only_surface() -> void:
	_clear_children(_read_only_surface)
	_routine_buttons.clear()
	_routine_focus_rows.clear()
	_read_only_focus_controls.clear()
	_read_only_scroll.scroll_vertical = 0
	match _active_tab:
		0:
			_build_status_surface()
		2:
			_build_people_surface()
		3:
			if _workflow_step == 1 and not _review_pending:
				_build_routine_surface()
			else:
				_build_record_surface()


func _build_status_surface() -> void:
	_read_only_surface.add_child(_section_title(LocaleManager.ui(
		"지금 상태", "CURRENT STATUS")))
	var finance_grid := GridContainer.new()
	finance_grid.columns = 2
	finance_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	finance_grid.add_theme_constant_override("h_separation", 10)
	finance_grid.add_theme_constant_override("v_separation", 8)
	_read_only_surface.add_child(finance_grid)
	var arrears := GameState.get_arrears()
	var loan_total := GameState.get_loan_total()
	finance_grid.add_child(_read_only_row(
		LocaleManager.ui("현재 날짜", "CURRENT DATE"),
		GameState.get_date_string(), 76))
	finance_grid.add_child(_read_only_row(
		LocaleManager.ui("계좌 잔액", "ACCOUNT BALANCE"),
		GameState.format_money(GameState.get_available_cash()), 76))
	finance_grid.add_child(_read_only_row(
		LocaleManager.ui("다음 고정비", "NEXT FIXED COST"),
		GameState.format_money(GameState.get_monthly_required_cash()), 76))
	finance_grid.add_child(_read_only_row(
		LocaleManager.ui("체납", "ARREARS"),
		GameState.format_money(arrears) if arrears > 0.0
			else LocaleManager.ui("없음", "None"), 76))
	finance_grid.add_child(_read_only_row(
		LocaleManager.ui("대출 원금", "LOAN PRINCIPAL"),
		GameState.format_money(loan_total) if loan_total > 0.0
			else LocaleManager.ui("없음", "None"), 76))
	finance_grid.add_child(_read_only_row(
		LocaleManager.ui("월 수입", "MONTHLY INCOME"),
		GameState.format_money(GameState.monthly_income), 76))

	if _investment_unlocked():
		_read_only_surface.add_child(_section_title(LocaleManager.ui(
			"투자 현황", "INVESTMENT STATUS")))
		var investment_grid := GridContainer.new()
		investment_grid.columns = 2
		investment_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		investment_grid.add_theme_constant_override("h_separation", 10)
		investment_grid.add_theme_constant_override("v_separation", 8)
		_read_only_surface.add_child(investment_grid)
		investment_grid.add_child(_read_only_row(
			LocaleManager.ui("보유 내역", "HOLDINGS"),
			_investment_holding_copy(), 88))
		investment_grid.add_child(_read_only_row(
			LocaleManager.ui("현재 시세", "CURRENT PRICES"),
			_investment_market_copy(), 88))

	var places := _discovered_place_names()
	if not places.is_empty():
		_read_only_surface.add_child(_section_title(LocaleManager.ui(
			"발견한 장소", "DISCOVERED PLACES")))
		_read_only_surface.add_child(_read_only_row(
			LocaleManager.ui("알게 된 곳", "PLACES DISCOVERED"),
			" · ".join(places), 76))


func _investment_unlocked() -> bool:
	return (
		bool(GameState.flags.get("has_received_paycheck", false))
		or bool(GameState.flags.get("had_first_investment", false))
		or not GameState.portfolio.is_empty()
	)


func _investment_holding_copy() -> String:
	var lines: Array[String] = []
	for raw_asset_id in GameState.portfolio:
		var asset_id := str(raw_asset_id)
		var holding: Dictionary = GameState.portfolio.get(asset_id, {})
		var quantity := float(holding.get("quantity", 0.0))
		if quantity <= 0.0:
			continue
		var price := float(GameState.market_prices.get(
			asset_id, holding.get("avg_price", 0.0)))
		var asset: Dictionary = DataRegistry.get_asset(asset_id)
		lines.append("%s · %s" % [
			str(asset.get("name", asset_id)),
			GameState.format_money(quantity * price),
		])
	if lines.is_empty():
		return LocaleManager.ui("보유 자산 없음", "No holdings")
	return "\n".join(lines.slice(0, 4))


func _investment_market_copy() -> String:
	var lines: Array[String] = []
	for raw_asset in DataRegistry.assets:
		if not raw_asset is Dictionary or lines.size() >= 4:
			continue
		var asset: Dictionary = raw_asset
		var asset_id := str(asset.get("id", ""))
		if asset_id.is_empty() or not GameState.market_prices.has(asset_id):
			continue
		lines.append("%s · %s" % [
			str(asset.get("name", asset_id)),
			GameState.format_money(float(GameState.market_prices[asset_id])),
		])
	return "\n".join(lines) if not lines.is_empty() else LocaleManager.ui(
		"확인할 시세 없음", "No prices available")


func _discovered_place_names() -> Array[String]:
	var places: Array[String] = []
	if bool(GameState.flags.get("racetrack_guide_met", false)) \
			or bool(GameState.flags.get("racetrack_visited", false)):
		places.append(LocaleManager.ui("경마장", "Racecourse"))
	if bool(GameState.flags.get("holdem_visited", false)):
		places.append(LocaleManager.ui("홀덤 클럽", "Hold'em club"))
	if bool(GameState.flags.get("casino_club_introduced", false)):
		places.append(LocaleManager.ui("카지노", "Casino"))
	return places


func _build_people_surface() -> void:
	_read_only_surface.add_child(_section_title(LocaleManager.ui(
		"지금까지 만난 사람", "PEOPLE MET SO FAR")))
	var seen: Array[String] = ["father"]
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
		var relationship := _relationship_copy(character_id)
		var method := _contact_method_copy(
			character_id, _contact_method(character_id))
		_read_only_surface.add_child(_read_only_row(
			_character_name(character_id),
			"%s\n%s" % [relationship, method],
			92))


func _build_record_surface() -> void:
	var section_heading := LocaleManager.ui(
		"확정한 이번 달 계획", "CONFIRMED MONTH PLAN") \
		if _read_only_plan else (
			LocaleManager.ui("계획 확인", "REVIEW PLAN")
			if _review_pending
			else LocaleManager.ui("이번 달 계획", "THIS MONTH'S PLAN")
		)
	_read_only_surface.add_child(_section_title(section_heading))
	if not _read_only_plan and not _review_pending:
		var validation := CORE_LOOP.validate_plan(
			_month_index, _schedule, _routines)
		if not bool(validation.get("ok", false)):
			_read_only_surface.add_child(_read_only_row(
				LocaleManager.ui("확정 전에 고칠 것", "FIX BEFORE CONFIRMING"),
				_plan_error_text(validation),
				76))
	_build_routine_surface()
	_read_only_surface.add_child(_read_only_row(
		LocaleManager.ui("네 주에 할 일", "WHAT YOU WILL DO"),
		"\n".join(_scheduled_commitment_lines()),
		118))

	var self_notes: Array[String] = []
	for bundle_id in CORE_LOOP.available_offer_ids(_month_index):
		var offer := CORE_LOOP.bundle(bundle_id)
		if str(offer.get("phone_surface", "")) == "self_note":
			self_notes.append("• %s — %s" % [
				_localized(offer, "offer"),
				_localized(offer, "detail"),
			])
	if not self_notes.is_empty():
		_read_only_surface.add_child(_read_only_row(
			LocaleManager.ui("내 메모", "MY NOTES"),
			"\n".join(self_notes),
			92))

	_read_only_surface.add_child(_read_only_row(
		LocaleManager.ui("고르지 않은 제안", "OPTIONS LEFT OUT"),
		"\n".join(_unchosen_offer_lines()),
		104))

	var decline_records := CORE_LOOP.decline_receipts_for_month(_month_index)
	if not decline_records.is_empty():
		var decline_lines: Array[String] = []
		for raw_record in decline_records:
			if not raw_record is Dictionary:
				continue
			var record: Dictionary = raw_record
			var producer := CORE_LOOP.bundle(
				str(record.get("producer_bundle", "")))
			var record_title := _localized(producer, "offer")
			var record_body := LocaleManager.ui(
				str(record.get("message_ko", "")),
				str(record.get("message_en", "")))
			if record_body.is_empty():
				record_body = _localized(producer, "decline")
			decline_lines.append("• %s — %s" % [record_title, record_body])
		if not decline_lines.is_empty():
			_read_only_surface.add_child(_read_only_row(
				LocaleManager.ui("지난달에 고르지 않은 제안", "LEFT OUT LAST MONTH"),
				"\n".join(decline_lines),
				92))


func _build_routine_surface() -> void:
	_routine_buttons.clear()
	var employed := not GameState.current_job.is_empty()
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 176)
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
	var heading := LocaleManager.ui(
		"본업은 주 루틴으로 고정됨 · 보조 루틴을 고른다",
		"PRIMARY JOB FIXED · CHOOSE A SECONDARY ROUTINE") \
		if employed and not _read_only_plan else \
		LocaleManager.ui(
			"추천 기본값 적용됨 · 그대로 두거나 변경할 수 있다",
			"RECOMMENDED DEFAULTS APPLIED · KEEP OR CHANGE THEM") \
		if _using_recommended_routines and not _read_only_plan else \
		LocaleManager.ui(
			"이번 달에 매주 계속할 두 가지",
			"TWO THINGS TO KEEP UP EACH WEEK")
	box.add_child(_label(heading, 14, COLOR_TEXT, true))
	var options := CORE_LOOP.routine_options()
	for slot in ["primary", "secondary"]:
		var focus_row: Array[Control] = []
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		box.add_child(row)
		var slot_label := _label(
			LocaleManager.ui("주로 할 일", "PRIMARY")
				if slot == "primary"
				else LocaleManager.ui("보조로 할 일", "SECONDARY"),
			14, COLOR_DIM, true)
		slot_label.custom_minimum_size = Vector2(96, 46)
		slot_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(slot_label)
		for routine_id in options:
			var option: Dictionary = options[routine_id]
			var button := _button(_localized(option, "label"), false)
			button.tooltip_text = _localized(option, "description")
			if employed and slot == "secondary" \
					and str(routine_id) == "livelihood":
				button.tooltip_text = LocaleManager.ui(
					"본업과 같은 생계를 보조 루틴으로 중복 선택할 수 없다.",
					"Income is already your fixed primary job and cannot be selected twice.")
			button.custom_minimum_size = Vector2(0, 46)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_set_button_disabled(button, (
				_read_only_plan
				or (
					employed
					and (
						(slot == "primary" and str(routine_id) != "livelihood")
						or (slot == "secondary" and str(routine_id) == "livelihood")
					)
				)
			))
			button.pressed.connect(select_routine.bind(slot, str(routine_id)))
			button.mouse_entered.connect(_focus_on_hover.bind(button))
			row.add_child(button)
			var key := "%s:%s" % [slot, str(routine_id)]
			_routine_buttons[key] = button
			if not button.disabled:
				focus_row.append(button)
			var selected := str(_routines.get(slot, "")) == str(routine_id)
			button.text = "%s%s" % [
				_localized(option, "label"),
				LocaleManager.ui(" (선택됨)", " (SET)") if selected else "",
			]
			_apply_button_style(button, false, selected)
		if not focus_row.is_empty():
			_routine_focus_rows.append(focus_row)
	var selected_details: Array[String] = []
	for slot in ["primary", "secondary"]:
		var routine_id := str(_routines.get(slot, ""))
		var option: Dictionary = options.get(routine_id, {})
		var label := _localized(option, "label")
		var effects := _routine_effect_copy(option)
		if not label.is_empty() and not effects.is_empty():
			selected_details.append("%s — %s" % [label, effects])
	var detail := _label("  ·  ".join(selected_details), 14, COLOR_DIM)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(detail)
	if _read_only_plan:
		_register_read_only_focus_control(panel)


func _read_only_row(
		title: String, body: String, minimum_height: float = 76.0) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, minimum_height)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override(
		"panel", _panel_style(COLOR_PANEL, COLOR_BORDER, 1))
	_register_read_only_focus_control(panel)
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
	body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(body_label)
	return panel


func _register_read_only_focus_control(control: Control) -> void:
	control.focus_mode = Control.FOCUS_ALL
	control.set_meta("core_loop_v2_review_section", true)
	control.focus_entered.connect(
		_set_read_only_focus_state.bind(control, true))
	control.focus_exited.connect(
		_set_read_only_focus_state.bind(control, false))
	control.mouse_entered.connect(_focus_on_hover.bind(control))
	_read_only_focus_controls.append(control)


func _set_read_only_focus_state(control: Control, focused: bool) -> void:
	if not is_instance_valid(control) or not control is PanelContainer:
		return
	(control as PanelContainer).add_theme_stylebox_override(
		"panel", _panel_style(
			COLOR_PANEL_ALT if focused else COLOR_PANEL,
			COLOR_ACCENT if focused else COLOR_BORDER,
			3 if focused else 1))


func _restore_focus_after_rebuild(generation: int) -> void:
	if not visible or generation != _focus_restore_generation:
		return
	if not _pending_focus_offer_id.is_empty():
		var bundle_id := _pending_focus_offer_id
		_pending_focus_offer_id = ""
		var offer_button: Button = _offer_buttons.get(bundle_id)
		if _active_tab == 1 and is_instance_valid(offer_button) \
				and offer_button.is_visible_in_tree():
			offer_button.grab_focus()
			return
	if not _pending_focus_routine_key.is_empty():
		var routine_key := _pending_focus_routine_key
		_pending_focus_routine_key = ""
		var routine_button: Button = _routine_buttons.get(routine_key)
		if is_instance_valid(routine_button) and not routine_button.disabled:
			routine_button.grab_focus()
			return
	if not _last_focus_key.is_empty() and _restore_focus_key(_last_focus_key):
		_last_focus_key = ""
		return
	if _active_tab == 1 and not _offer_buttons.is_empty():
		var first_offer: Button = _offer_buttons.values()[0]
		if is_instance_valid(first_offer):
			first_offer.grab_focus()
			return
	var active_navigation := _active_navigation_control()
	if is_instance_valid(active_navigation):
		active_navigation.grab_focus()


func _current_focus_key() -> String:
	var owner := get_viewport().gui_get_focus_owner()
	if not owner is Control or not is_ancestor_of(owner):
		return ""
	if owner == _communication_button:
		return "communication"
	if owner == _close_button:
		return "close"
	if owner == _confirm_button:
		return "confirm"
	if owner == _overview_button:
		return "info:overview"
	if owner == _people_button:
		return "info:people"
	for index in range(_step_buttons.size()):
		if owner == _step_buttons[index]:
			return "step:%d" % index
	for bundle_id in _offer_buttons:
		if owner == _offer_buttons[bundle_id]:
			return "offer:%s" % bundle_id
	for week_key in _slot_buttons:
		if owner == _slot_buttons[week_key]:
			return "week:%s" % week_key
	for routine_key in _routine_buttons:
		if owner == _routine_buttons[routine_key]:
			return "routine:%s" % routine_key
	return ""


func _restore_focus_key(key: String) -> bool:
	var target: Control = null
	if key == "communication":
		target = _communication_button
	elif key == "close":
		target = _close_button
	elif key == "confirm":
		target = _confirm_button
	elif key == "info:overview":
		target = _overview_button
	elif key == "info:people":
		target = _people_button
	elif key.begins_with("step:"):
		var index := int(key.trim_prefix("step:"))
		if index >= 0 and index < _step_buttons.size():
			target = _step_buttons[index]
	elif key.begins_with("offer:"):
		target = _offer_buttons.get(key.trim_prefix("offer:")) as Control
	elif key.begins_with("week:"):
		target = _slot_buttons.get(key.trim_prefix("week:")) as Control
	elif key.begins_with("routine:"):
		target = _routine_buttons.get(key.trim_prefix("routine:")) as Control
	if not is_instance_valid(target) or not target.is_visible_in_tree():
		return false
	if target is BaseButton and (target as BaseButton).disabled:
		return false
	target.grab_focus()
	return true


func _assign_offer(bundle_id: String) -> void:
	if _read_only_plan or _review_pending:
		return
	if not CORE_LOOP.available_offer_ids(_month_index).has(bundle_id):
		_placement_error = "unavailable"
		_refresh_calendar()
		return
	_selected_offer_id = bundle_id
	_detail_week = -1
	if _armed_offer_id == bundle_id:
		_clear_placement_intent()
		_refresh_calendar()
		return
	var target_week := _first_open_week_for_bundle(bundle_id)
	if target_week < 0:
		target_week = _scheduled_week_for_bundle(bundle_id)
	if target_week < 0:
		_placement_error = "no_open_week"
		_refresh_calendar()
		return
	_armed_offer_id = bundle_id
	_selected_week = target_week
	_placement_error = ""
	_refresh_calendar()
	call_deferred("_focus_week_button", target_week)

func _select_week(week: int) -> void:
	_selected_week = week
	if _read_only_plan or _review_pending:
		_detail_week = week
		_refresh_calendar()
		return
	if _armed_offer_id.is_empty():
		_placement_error = ""
		_detail_week = week
		var scheduled_offer := str(_schedule.get(str(week), ""))
		if CORE_LOOP.available_offer_ids(_month_index).has(scheduled_offer):
			_selected_offer_id = scheduled_offer
		_refresh_calendar()
		return

	var bundle_id := _armed_offer_id
	_selected_offer_id = bundle_id
	_detail_week = -1
	var week_key := str(week)
	var target_bundle := str(_schedule.get(week_key, ""))
	if target_bundle == bundle_id:
		_clear_placement_intent()
		_detail_week = week
		_refresh_calendar()
		return
	if _locked_by_week.has(week_key):
		_placement_error = "locked"
		_refresh_calendar()
		return
	if not CORE_LOOP.available_offer_ids(_month_index).has(bundle_id):
		_placement_error = "unavailable"
		_refresh_calendar()
		return
	if not CORE_LOOP.bundle_allowed_in_week(bundle_id, week):
		_placement_error = "deadline"
		_refresh_calendar()
		return
	if not target_bundle.is_empty():
		_placement_error = "occupied"
		_refresh_calendar()
		return
	if not assign_offer_to_week(bundle_id, week):
		_placement_error = "unavailable"
		_refresh_calendar()
		return
	_clear_placement_intent()
	_detail_week = week
	_refresh_calendar()
	call_deferred("_focus_next_offer_or_confirm")

func _offer_focused(bundle_id: String) -> void:
	if _active_tab != 1 or not _calendar_surface.is_visible_in_tree():
		return
	_selected_offer_id = bundle_id
	_detail_week = -1
	if _armed_offer_id.is_empty():
		var target_week := _first_open_week_for_bundle(bundle_id)
		if target_week < 0:
			target_week = _scheduled_week_for_bundle(bundle_id)
		if target_week > 0:
			_selected_week = target_week
	_refresh_calendar()

func _week_focused(week: int) -> void:
	if _active_tab != 1 or not _calendar_surface.is_visible_in_tree():
		return
	_selected_week = week
	if _armed_offer_id.is_empty():
		_detail_week = week
		var scheduled_offer := str(_schedule.get(str(week), ""))
		if CORE_LOOP.available_offer_ids(_month_index).has(scheduled_offer):
			_selected_offer_id = scheduled_offer
	_refresh_calendar()

func _clear_placement_intent() -> void:
	_armed_offer_id = ""
	_placement_error = ""
	set_meta("core_loop_v2_armed_offer_id", "")
	for raw_button in _offer_buttons.values():
		if raw_button is Button and is_instance_valid(raw_button):
			(raw_button as Button).set_meta("core_loop_v2_offer_armed", false)


func _focus_week_button(week: int) -> void:
	if not visible or _active_tab != 1:
		return
	var button: Button = _slot_buttons.get(str(week)) as Button
	if is_instance_valid(button) and not button.disabled:
		button.grab_focus()


func _focus_next_offer_or_confirm() -> void:
	if not visible or _active_tab != 1:
		return
	if _filled_week_count() >= 4:
		var validation := CORE_LOOP.validate_plan(
			_month_index, _schedule, _routines)
		if bool(validation.get("ok", false)):
			_confirm_button.grab_focus()
		elif str(validation.get("error", "")) in [
			"choose_two_routines", "routines_must_be_distinct",
			"unknown_routine", "job_requires_primary_livelihood",
		]:
			_switch_workflow_step(1)
		else:
			_switch_workflow_step(2)
		return
	for bundle_id in CORE_LOOP.available_offer_ids(_month_index):
		if _schedule.values().has(bundle_id):
			continue
		var button: Button = _offer_buttons.get(bundle_id) as Button
		if is_instance_valid(button):
			button.grab_focus()
			return


func _cancel_placement_and_restore_focus() -> void:
	if _armed_offer_id.is_empty():
		return
	var offer_id := _armed_offer_id
	_clear_placement_intent()
	_refresh_calendar()
	var offer_button: Button = _offer_buttons.get(offer_id) as Button
	if is_instance_valid(offer_button):
		offer_button.call_deferred("grab_focus")


func _focused_week() -> int:
	var owner := get_viewport().gui_get_focus_owner()
	if owner is Control and is_ancestor_of(owner) \
			and (owner as Control).has_meta("core_loop_v2_week"):
		return int((owner as Control).get_meta("core_loop_v2_week", -1))
	return -1


func _on_confirm_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
			return
		_confirm_activation_from_mouse = true
		if not _review_pending:
			return
		if mouse_event.double_click:
			_review_mouse_double_click_blocked = true
			_review_mouse_single_click_armed = false
			return
		_review_mouse_single_click_armed = true
		return
	if event.is_action_pressed("ui_accept"):
		_confirm_activation_from_mouse = false


func _commit_plan() -> void:
	var mouse_activation := _confirm_activation_from_mouse
	_confirm_activation_from_mouse = false
	if _read_only_plan:
		close()
		return
	if not _armed_offer_id.is_empty():
		_placement_error = "review_blocked"
		_refresh_calendar()
		return
	var validation := CORE_LOOP.validate_plan(_month_index, _schedule, _routines)
	if not bool(validation.get("ok", false)):
		_status_label.text = _plan_error_text(validation)
		_refresh_step_rail()
		return
	if not _review_pending:
		_begin_commit_review()
		return
	if _review_confirm_release_required:
		return
	if mouse_activation and _review_mouse_double_click_blocked:
		if not _review_mouse_single_click_armed:
			return
		_review_mouse_double_click_blocked = false
		_review_mouse_single_click_armed = false
	elif mouse_activation:
		_review_mouse_single_click_armed = false
	emit_signal(
		"plan_committed", _month_index, _schedule.duplicate(true),
		_routines.duplicate(true))

func _switch_tab(index: int) -> void:
	# Compatibility adapter for focused QA and the phone's VIEW PLAN route.
	# The player surface no longer exposes four tabs.
	match clampi(index, 0, 3):
		0:
			_open_info_view(0)
		1:
			_switch_workflow_step(0)
		2:
			_open_info_view(2)
		3:
			_switch_workflow_step(
				2 if _read_only_plan or _review_pending else 1)


func _open_info_view(index: int) -> void:
	if index not in [0, 2]:
		return
	_clear_placement_intent()
	if _review_pending:
		_review_pending = false
		_review_confirm_release_required = false
	_active_tab = index
	_last_focus_key = "info:overview" if index == 0 else "info:people"
	_rebuild()


func _switch_workflow_step(index: int) -> void:
	var target := clampi(index, 0, 2)
	if target != 0:
		_clear_placement_intent()
	if _review_pending and target != 2:
		_review_pending = false
		_review_confirm_release_required = false
	_workflow_step = target
	_active_tab = 1 if target == 0 else 3
	_last_focus_key = "step:%d" % target
	_rebuild()


func _cycle_step(delta: int) -> void:
	_switch_workflow_step(int(posmod(_workflow_step + delta, 3)))
	_step_buttons[_workflow_step].call_deferred("grab_focus")

func _communication_shortcut_pressed(event: InputEvent) -> bool:
	if event is InputEventJoypadButton:
		var joy_event := event as InputEventJoypadButton
		return joy_event.pressed and joy_event.button_index == JOY_BUTTON_Y
	if event is InputEventKey:
		var key_event := event as InputEventKey
		return key_event.pressed and not key_event.echo \
			and (key_event.keycode == KEY_P \
				or key_event.physical_keycode == KEY_P)
	return false

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and (event as InputEventKey).echo:
		get_viewport().set_input_as_handled()
		return
	var handled := false
	if _communication_shortcut_pressed(event):
		_request_communication()
		handled = true
	elif event is InputEventJoypadButton and (event as InputEventJoypadButton).pressed:
		var joy_button := int((event as InputEventJoypadButton).button_index)
		match joy_button:
			JOY_BUTTON_B:
				if _read_only_plan:
					close()
				elif _review_pending:
					_cancel_commit_review()
				elif not _armed_offer_id.is_empty():
					_cancel_placement_and_restore_focus()
				handled = true
			JOY_BUTTON_X:
				if not _read_only_plan and not _review_pending \
						and _active_tab == 1:
					var week := _focused_week()
					if week > 0:
						unassign_week(week)
				handled = true
			JOY_BUTTON_LEFT_SHOULDER:
				_cycle_step(-1)
				handled = true
			JOY_BUTTON_RIGHT_SHOULDER:
				_cycle_step(1)
				handled = true
	if not handled and ControllerHints.secondary_pressed(event):
		if not _read_only_plan and not _review_pending \
				and _active_tab == 1:
			var week := _focused_week()
			if week > 0:
				unassign_week(week)
		handled = true
	elif not handled and event.is_action_pressed("gd_tab_prev"):
		_cycle_step(-1)
		handled = true
	elif not handled and event.is_action_pressed("gd_tab_next"):
		_cycle_step(1)
		handled = true
	elif not handled and event.is_action_pressed("ui_cancel"):
		if _read_only_plan:
			close()
		elif _review_pending:
			_cancel_commit_review()
		elif not _armed_offer_id.is_empty():
			_cancel_placement_and_restore_focus()
		handled = true
	if handled:
		get_viewport().set_input_as_handled()

func _refresh_footer() -> void:
	if not is_instance_valid(_confirm_button):
		return
	if _read_only_plan:
		_edit_button.visible = false
		_confirm_button.visible = true
		_set_button_disabled(_confirm_button, false)
		_confirm_button.text = LocaleManager.ui("계획판 닫기", "CLOSE PLANNER")
		_apply_button_style(_confirm_button, false, true)
		_status_label.text = LocaleManager.ui(
			"확정한 계획이다. 일정과 매주 할 일은 바꿀 수 없다.",
			"This plan is confirmed. The schedule and weekly routines cannot be changed.")
		_fit_status_label_height(52.0)
		_hint_label.text = LocaleManager.ui(
			"위아래로 내용 확인 · %s 닫기 · %s/%s 단계",
			"UP/DOWN Review · %s Close · %s/%s Steps") % [
				ControllerHints.east(),
				ControllerHints.shoulder_l(),
				ControllerHints.shoulder_r(),
			]
		return
	_confirm_button.visible = true
	var validation := CORE_LOOP.validate_plan(_month_index, _schedule, _routines)
	var ready := bool(validation.get("ok", false)) \
		and _armed_offer_id.is_empty()
	_set_button_disabled(
		_confirm_button,
		not ready or (_review_pending and _review_confirm_release_required))
	_apply_button_style(
		_confirm_button, false,
		ready and not _review_confirm_release_required)
	if _review_pending:
		_confirm_button.text = LocaleManager.ui(
			"이대로 확정하고 첫 주를 시작한다",
			"Confirm Plan and Begin Week One")
		_hint_label.text = LocaleManager.ui(
			"위아래로 내용 확인 · %s 일정 수정 · %s 새로 눌러 확정",
			"UP/DOWN Review · %s Edit · Fresh %s to Confirm") % [
				ControllerHints.east(),
				ControllerHints.south(),
			]
		return
	var routine_count := _routine_choice_count()
	_confirm_button.text = LocaleManager.ui(
		"일정 {weeks}/4 · 루틴 {routines}/2 — 계획 확인",
		"WEEKS {weeks}/4 · ROUTINES {routines}/2 — REVIEW").format({
			"weeks": _filled_week_count(),
			"routines": routine_count,
		})
	if not ready and _active_tab != 1:
		if _active_tab == 3 and _workflow_step == 1:
			_hint_label.text = LocaleManager.ui(
				"좌우·위아래 매주 할 일 이동 · %s 선택 · %s/%s 단계",
				"D-pad Weekly Activities · %s Select · %s/%s Steps") % [
					ControllerHints.south(),
					ControllerHints.shoulder_l(),
					ControllerHints.shoulder_r(),
				]
		elif _active_tab == 3 and _workflow_step == 2:
			_status_label.text = _plan_error_text(validation)
			_fit_status_label_height(72.0)
			_hint_label.text = LocaleManager.ui(
				"위아래로 계획 확인 · %s/%s 단계에서 남은 항목 수정",
				"UP/DOWN Review · %s/%s Steps to finish missing items") % [
					ControllerHints.shoulder_l(),
					ControllerHints.shoulder_r(),
				]
		else:
			_hint_label.text = LocaleManager.ui(
				"위아래로 내용 확인 · %s/%s 단계 · 1단계에서 계획 계속",
				"UP/DOWN Review · %s/%s Steps · Continue in Step 1") % [
					ControllerHints.shoulder_l(),
					ControllerHints.shoulder_r(),
				]
		return
	if ready:
		_status_label.text = LocaleManager.ui(
			"네 주와 매주 할 일이 정해졌다. 계획 확인에서 고른 일과 놓칠 제안을 살핀다.",
			"All four weeks and weekly routines are set. Review what you chose and what you will leave out.")
		_fit_status_label_height(52.0)
		if _active_tab == 1:
			_hint_label.text = LocaleManager.ui(
				"다음 · %s 계획 확인 · %s 주차에서 빼기 · %s/%s 단계" % [
					ControllerHints.south(), ControllerHints.west(),
					ControllerHints.shoulder_l(), ControllerHints.shoulder_r(),
				],
				"NEXT · %s Review Plan · %s Remove on Week · %s/%s Steps" % [
					ControllerHints.south(), ControllerHints.west(),
					ControllerHints.shoulder_l(), ControllerHints.shoulder_r(),
				])
		else:
			_hint_label.text = LocaleManager.ui(
				"위아래로 내용 확인 · %s 계획 확인 · %s/%s 단계",
				"UP/DOWN Review · %s Review Plan · %s/%s Steps") % [
					ControllerHints.south(),
					ControllerHints.shoulder_l(),
					ControllerHints.shoulder_r(),
				]
		return
	if not _armed_offer_id.is_empty():
		var armed_prompt := LocaleManager.ui(
			"이 일을 어느 주에 넣을까?",
			"WHICH WEEK SHOULD THIS GO IN?")
		var error_text := _placement_error_text(_placement_error)
		_status_label.text = armed_prompt if error_text.is_empty() else error_text
		_fit_status_label_height(52.0)
		_hint_label.text = LocaleManager.ui(
			"2/2 주차 선택 · %s 주에 넣기 · %s 선택 취소 · %s 일정 빼기" % [
				ControllerHints.south(), ControllerHints.east(),
				ControllerHints.west(),
			],
			"STEP 2/2 · %s Place in Week · %s Cancel · %s Remove" % [
				ControllerHints.south(), ControllerHints.east(),
				ControllerHints.west(),
			])
		return
	if not _placement_error.is_empty():
		_status_label.text = _placement_error_text(_placement_error)
		_fit_status_label_height(72.0)
		_hint_label.text = LocaleManager.ui(
			"할 일 선택 · %s 선택 · %s 주차에서만 빼기 · %s/%s 단계" % [
				ControllerHints.south(), ControllerHints.west(),
				ControllerHints.shoulder_l(), ControllerHints.shoulder_r(),
			],
			"CHOOSE · %s Select · %s Remove on Week · %s/%s Steps" % [
				ControllerHints.south(), ControllerHints.west(),
				ControllerHints.shoulder_l(), ControllerHints.shoulder_r(),
			])
		return
	var missed_count := maxi(
		CORE_LOOP.available_offer_ids(_month_index).size()
			- _selected_offer_count(), 0)
	_status_label.text = LocaleManager.ui(
		"네 주를 모두 정하면, 남은 제안 {count}개는 이번 달에 고르지 않는다.",
		"Fill all four weeks. {count} other options will be left out this month."
	).format({"count": missed_count})
	_fit_status_label_height(52.0)
	_hint_label.text = LocaleManager.ui(
		"할 일 선택 · %s 선택 · %s 주차에서만 빼기 · %s/%s 단계" % [
			ControllerHints.south(),
			ControllerHints.west(),
			ControllerHints.shoulder_l(),
			ControllerHints.shoulder_r(),
		],
		"CHOOSE · %s Select · %s Remove on Week · %s/%s Steps" % [
			ControllerHints.south(),
			ControllerHints.west(),
			ControllerHints.shoulder_l(),
			ControllerHints.shoulder_r(),
		])

func _fit_status_label_height(minimum_height: float) -> void:
	if not is_instance_valid(_status_label):
		return
	_status_label.custom_minimum_size.y = 0.0
	if is_instance_valid(_status_panel):
		_status_panel.custom_minimum_size.y = minimum_height

func _placement_error_text(error: String) -> String:
	match error:
		"occupied":
			return LocaleManager.ui(
				"그 주에는 이미 다른 약속이 있다. 먼저 그 약속을 빼야 한다.",
				"That week already has a commitment. Remove it first.")
		"deadline":
			return LocaleManager.ui(
				"그 주까지 미루면 늦는다. 더 이른 주를 골라야 한다.",
				"That week is too late. Choose an earlier one.")
		"locked":
			return LocaleManager.ui(
				"이미 확정된 일정이라 옮길 수 없다.",
				"That commitment is fixed and cannot be moved.")
		"unavailable":
			return LocaleManager.ui(
				"이번 달에는 이 제안을 일정에 넣을 수 없다.",
				"This offer is not available for this month's schedule.")
		"review_blocked":
			return LocaleManager.ui(
				"먼저 넣을 주를 고른다. 취소하려면 뒤로 버튼을 누른다.",
				"Choose a week first. Press Back to cancel.")
		"no_open_week":
			return LocaleManager.ui(
				"넣을 수 있는 빈 주가 없다. 주차 카드로 이동해 일정 하나를 먼저 뺀다.",
				"No valid week is open. Move to a week card and remove a schedule first.")
	return ""

func _plan_error_text(validation: Dictionary) -> String:
	match str(validation.get("error", "")):
		"fill_four_weeks", "empty_week":
			return LocaleManager.ui(
				"네 주의 일정을 모두 채운다.",
				"Fill all four weeks of the schedule.")
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
		"unknown_routine":
			return LocaleManager.ui(
				"매주 할 일 중 지금은 고를 수 없는 항목이 있다.",
				"One weekly activity is no longer available.")
		"job_requires_primary_livelihood":
			return LocaleManager.ui(
				"취업 중에는 본업을 매주 해야 한다.",
				"While employed, your job must remain a weekly activity.")
		"exclusive_group":
			return LocaleManager.ui(
				"서로 겹치는 두 만남은 같은 달에 함께 고를 수 없다.",
				"These two meetings cannot both be chosen in the same month.")
		"active_named_characters_cap":
			return LocaleManager.ui(
				"이번 달에 사람과 잡은 약속이 너무 많다. 한 약속을 다른 일로 바꾼다.",
				"Too many personal commitments overlap this month. Replace one with another kind of work.")
		"unavailable_bundle", "locked_week_changed", "duplicate_bundle":
			return LocaleManager.ui(
				"일정에 지금 넣을 수 없는 약속이 있다. 네 주를 다시 확인한다.",
				"One commitment no longer fits this schedule. Review all four weeks.")
	return LocaleManager.ui(
		"네 주에 할 일과 매주 계속할 두 가지를 모두 정해야 한다.",
		"Fill all four weeks and choose both weekly activities.")

func _begin_commit_review() -> void:
	if _read_only_plan:
		return
	_clear_placement_intent()
	_review_pending = true
	_review_confirm_release_required = true
	_review_mouse_double_click_blocked = false
	_review_mouse_single_click_armed = false
	_review_confirm_not_before_msec = Time.get_ticks_msec() \
		+ REVIEW_CONFIRM_DELAY_MSEC
	_active_tab = 3
	_workflow_step = 2
	_rebuild()
	_edit_button.call_deferred("grab_focus")

func _cancel_commit_review() -> void:
	_review_pending = false
	_review_confirm_release_required = false
	_confirm_activation_from_mouse = false
	_review_mouse_double_click_blocked = false
	_review_mouse_single_click_armed = false
	_active_tab = 1
	_workflow_step = 0
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


func _scheduled_week_for_bundle(bundle_id: String) -> int:
	for raw_week in _schedule:
		if str(_schedule.get(raw_week, "")) == bundle_id:
			return int(raw_week)
	return -1

func _first_open_week_for_bundle(bundle_id: String) -> int:
	var weeks: Array = _month_data.get("weeks", [1, 4])
	for week in range(int(weeks[0]), int(weeks[1]) + 1):
		if not _schedule.has(str(week)) \
				and not _locked_by_week.has(str(week)) \
				and CORE_LOOP.bundle_allowed_in_week(bundle_id, week):
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
	var ko_text := str(data.get("%s_ko" % stem, ""))
	var en_text := str(data.get("%s_en" % stem, ko_text))
	return LocaleManager.ui(ko_text, en_text)

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

func _contact_method(character_id: String) -> String:
	match character_id:
		"father":
			return "phone"
		"hyunsu":
			return "kakao" if _bundle_completed("hyunsu_first_meet") else "none"
		"daeun":
			return "known_place" \
				if CORE_LOOP.relationship_stage(character_id) != "unmet" else "none"
		"jiyeon":
			return "none"
		"sangchul":
			if CORE_LOOP.relationship_stage(character_id) != "unmet" \
					and (
						GameState.has_item("artifact_sangchul_card")
						or bool(GameState.flags.get(
							"artifact_sangchul_card", false))
					):
				return "business_card"
		"jaehyuk":
			if _has_relationship_memory(character_id, [
				"jaehyuk_message_welcomed",
				"jaehyuk_message_guarded",
			]):
				return "kakao"
	return "none"


func _contact_method_copy(character_id: String, method: String) -> String:
	match method:
		"phone":
			return LocaleManager.ui(
				"연락수단 · 저장된 전화번호",
				"CONTACT · SAVED PHONE NUMBER")
		"kakao":
			return LocaleManager.ui(
				"연락수단 · 카카오톡 대화",
				"CONTACT · KAKAOTALK THREAD")
		"business_card":
			return LocaleManager.ui(
				"연락수단 · 받은 명함의 번호",
				"CONTACT · NUMBER ON HIS BUSINESS CARD")
		"known_place":
			return LocaleManager.ui(
				"연락처 없음 · 찾아갈 편의점만 알고 있다",
				"NO CONTACT DETAILS · ONLY THE STORE IS KNOWN")
	if character_id == "jiyeon":
		return LocaleManager.ui(
			"연락수단 없음 · 전화번호나 메시지를 주고받지 않았다",
			"NO CONTACT METHOD · NO NUMBER OR MESSAGES EXCHANGED")
	return LocaleManager.ui(
		"연락수단 없음", "NO CONTACT METHOD")


func _bundle_completed(bundle_id: String) -> bool:
	var completed: Variant = GameState.core_loop_v2_state.get(
		"completed_bundles", [])
	return completed is Array and (completed as Array).has(bundle_id)

func _has_relationship_memory(
		character_id: String, memory_ids: Array) -> bool:
	for raw_memory_id in memory_ids:
		var memory_id := str(raw_memory_id).strip_edges()
		if memory_id.is_empty():
			continue
		if CORE_LOOP.has_relationship_memory(character_id, memory_id) \
				or bool(GameState.flags.get(memory_id, false)):
			return true
	return false

func _daeun_name_known() -> bool:
	return _has_relationship_memory("daeun", [
		"daeun_name_exchanged",
		"daeun_returned_using_her_name",
		"daeun_returned_to_thank_her",
		"daeun_names_exchanged_on_return",
		"daeun_thanks_reopened_conversation",
	])

func _jiyeon_name_known() -> bool:
	return _has_relationship_memory("jiyeon", [
		"jiyeon_name_offered_after_silence",
		"jiyeon_name_exchanged_after_player_spoke",
	])

func _character_name(character_id: String) -> String:
	match character_id:
		"father":
			return LocaleManager.ui("아버지", "Father")
		"hyunsu":
			return LocaleManager.ui("현수", "Hyunsu")
		"daeun":
			return LocaleManager.ui("김다은", "Kim Daeun") \
				if _daeun_name_known() else LocaleManager.ui(
					"24시간 편의점 야간 직원",
					"24-Hour Store Night Clerk")
		"jiyeon":
			return LocaleManager.ui("한지연", "Han Jiyeon") \
				if _jiyeon_name_known() else LocaleManager.ui(
					"검은 세단 운전자",
					"Black-Sedan Driver")
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
	if character_id == "hyunsu":
		if _has_relationship_memory(character_id, [
			"hyunsu_same_hour_confirmed",
			"hyunsu_one_problem_each_agreed",
		]):
			return LocaleManager.ui(
				"현수가 먼저 다시 공부하자고 했고, 같은 시간을 함께 쓰기로 했다.",
				"Hyunsu asked to study again, and you agreed to share the same hour.")
		if _has_relationship_memory(character_id, [
			"hyunsu_resume_shared",
			"hyunsu_problem_set_shared",
		]):
			return LocaleManager.ui(
				"공용 주방에서 만난 현수에게 내가 먼저 카카오톡을 보내 함께 공부할 날을 잡았다.",
				"I messaged Hyunsu first after meeting in the shared kitchen and set a day to study.")
		if _has_relationship_memory(character_id, [
			"hyunsu_honest_uncertainty",
			"hyunsu_declared_dream",
		]):
			return LocaleManager.ui(
				"공용 주방에서 처음 이야기를 나눴다. 아직 함께할 약속은 없다.",
				"You first spoke in the shared kitchen. There is no plan together yet.")
	if character_id == "daeun":
		if _has_relationship_memory(character_id, [
			"daeun_same_tuesday_promised",
		]):
			return LocaleManager.ui(
				"내가 다시 찾아간 뒤, 다음 화요일에도 서로의 한 주를 묻기로 했다.",
				"After I returned, we agreed to ask about each other's week again next Tuesday.")
		if _has_relationship_memory(character_id, [
			"daeun_late_meal_promised",
		]):
			return LocaleManager.ui(
				"내가 다시 찾아간 뒤, 다음에는 서로 늦은 끼니를 거르지 않았는지 확인하기로 했다.",
				"After I returned, we agreed to check next time that neither of us had skipped a late meal.")
		if _has_relationship_memory(character_id, [
			"daeun_third_greeting_started",
		]):
			return LocaleManager.ui(
				"이름을 안 뒤 다시 편의점에 찾아가, 내가 먼저 세 번째 대화를 시작했다.",
				"After learning her name, I returned to the store and began our third conversation.")
		if _has_relationship_memory(character_id, [
			"daeun_shift_question_asked",
		]):
			return LocaleManager.ui(
				"이름을 안 뒤 다시 편의점에 찾아가, 내가 먼저 다은의 야간 근무를 물었다.",
				"After learning her name, I returned and asked Daeun about her night shift first.")
		if _has_relationship_memory(character_id, [
			"daeun_returned_using_her_name",
		]):
			return LocaleManager.ui(
				"내가 다시 편의점에 찾아가, 다은의 이름을 불러 말을 걸었다.",
				"I returned to the store, said Daeun's name, and spoke first.")
		if _has_relationship_memory(character_id, [
			"daeun_returned_to_thank_her",
		]):
			return LocaleManager.ui(
				"내가 다시 편의점에 찾아가, 다은에게 지난번 일을 고맙다고 말했다.",
				"I returned to the store and thanked Daeun for the other night.")
		if _has_relationship_memory(character_id, [
			"daeun_names_exchanged_on_return",
		]):
			return LocaleManager.ui(
				"내가 편의점에 다시 찾아가 먼저 인사했고, 이번에는 서로 이름을 알았다.",
				"I returned to the store, greeted her first, and this time we learned each other's names.")
		if _has_relationship_memory(character_id, [
			"daeun_thanks_reopened_conversation",
		]):
			return LocaleManager.ui(
				"내가 편의점에 다시 찾아가, 그날 못 한 고맙다는 말을 먼저 건넸다.",
				"I returned to the store and began with the thank-you I had left unsaid.")
		if _has_relationship_memory(character_id, ["daeun_name_exchanged"]):
			return LocaleManager.ui(
				"새벽 편의점에서 이름을 들었다. 다시 찾아갈지는 아직 정하지 않았다.",
				"You learned her name at the store before dawn. You have not decided whether to return.")
		if _has_relationship_memory(character_id, ["daeun_kept_distance"]):
			return LocaleManager.ui(
				"새벽 편의점에서 인사만 나눴다. 이름은 아직 모른다.",
				"You exchanged only a greeting at the store before dawn. You still do not know her name.")
	if character_id == "jiyeon":
		if _has_relationship_memory(character_id, [
			"jiyeon_neighborhood_coffee_accepted",
		]):
			return LocaleManager.ui(
				"큰길에서 다시 마주친 지연과 가까운 카페에 들어가 대화를 이어 갔다.",
				"After meeting Jiyeon again on the main road, we continued talking at a nearby café.")
		if _has_relationship_memory(character_id, [
			"jiyeon_talk_without_debt_requested",
		]):
			return LocaleManager.ui(
				"큰길에서 다시 마주친 지연에게 보상 말고 서로의 이야기를 하자고 먼저 말했다.",
				"After meeting Jiyeon again, I asked to talk about each other rather than compensation.")
		if _has_relationship_memory(character_id, [
			"jiyeon_coffee_fully_refused",
		]):
			return LocaleManager.ui(
				"큰길에서 다시 마주쳤지만, 지연의 커피 제안을 받지 않고 돌아섰다.",
				"We met again on the main road, but I declined Jiyeon's coffee invitation and left.")
		if _has_relationship_memory(character_id, [
			"jiyeon_name_exchanged_after_player_spoke",
		]):
			return LocaleManager.ui(
				"정류장에서 다시 마주쳤을 때 내가 먼저 사고 이야기를 꺼내 서로 이름을 알았다.",
				"When we crossed paths again at the bus stop, I brought up the accident first and we learned each other's names.")
		if _has_relationship_memory(character_id, [
			"jiyeon_name_offered_after_silence",
		]):
			return LocaleManager.ui(
				"정류장에서 우연히 다시 마주쳤고, 지연이 먼저 자전거 안부와 이름을 건넸다.",
				"We crossed paths again by chance at the bus stop. Jiyeon asked about the bicycle and gave her name first.")
		if _has_relationship_memory(character_id, [
			"jiyeon_walked_away",
			"jiyeon_repair_cost_taken",
			"jiyeon_driver_confronted",
		]):
			return LocaleManager.ui(
				"신촌 골목의 사고로 한 번 마주쳤다. 연락처도 이름도 모른다.",
				"You met once in a Sinchon side-street accident. You know neither her name nor contact details.")
	if character_id == "sangchul":
		if _has_relationship_memory(character_id, [
			"sangchul_own_pace_stated",
		]):
			return LocaleManager.ui(
				"명함의 번호로 먼저 연락해 다시 만났고, 내 속도로 배우겠다고 말했다.",
				"I called the number on his card, met him again, and said I would learn at my own pace.")
		if _has_relationship_memory(character_id, [
			"sangchul_numbers_first_recorded",
		]):
			return LocaleManager.ui(
				"명함의 번호로 먼저 연락해 다시 만났고, 월세와 생활비부터 적어 보기로 했다.",
				"I called the number on his card, met him again, and decided to start by recording rent and living costs.")
		if _has_relationship_memory(character_id, [
			"sangchul_spoke_of_father",
		]):
			return LocaleManager.ui(
				"원룸 시세를 묻다 상철을 만났고, 아버지에게 보여드리고 싶은 이유를 말한 뒤 명함을 받았다.",
				"You met Sangchul while asking about studio rents, told him you wanted to show Father one day, and took his card.")
		if _has_relationship_memory(character_id, [
			"sangchul_kept_goal_plain",
		]):
			return LocaleManager.ui(
				"원룸 시세를 묻다 상철을 만났고, 강남이 목표라는 말을 남긴 뒤 명함을 받았다.",
				"You met Sangchul while asking about studio rents, said Gangnam was the goal, and took his card.")
		if _has_relationship_memory(character_id, [
			"sangchul_named_city_pride",
		]):
			return LocaleManager.ui(
				"원룸 시세를 묻다 상철을 만났고, 도시에 지기 싫다는 이유를 말한 뒤 명함을 받았다.",
				"You met Sangchul while asking about studio rents, said you refused to lose to the city, and took his card.")
		if GameState.has_item("artifact_sangchul_card"):
			return LocaleManager.ui(
				"원룸 시세를 묻다 만났고, 그가 건넨 명함을 가지고 있다.",
				"You met while asking about studio rents and still have the card he gave you.")
	if character_id == "jaehyuk":
		if _has_relationship_memory(character_id, [
			"jaehyuk_reunion_warm",
		]):
			return LocaleManager.ui(
				"카카오톡 답장 뒤 포장마차에서 재혁을 만나, 십 년 만의 사진을 새로 남겼다.",
				"After replying in KakaoTalk, I met Jaehyuk at a pojangmacha and took our first new photo in ten years.")
		if _has_relationship_memory(character_id, [
			"jaehyuk_reunion_guarded",
		]):
			return LocaleManager.ui(
				"카카오톡 답장 뒤 포장마차에서 재혁을 만났지만, 서두르지 않고 거리를 남겼다.",
				"After replying in KakaoTalk, I met Jaehyuk at a pojangmacha but kept some distance.")
		if _has_relationship_memory(character_id, [
			"jaehyuk_message_welcomed",
		]):
			return LocaleManager.ui(
				"10년 만에 온 재혁의 카카오톡을 반갑게 받아 답장했다.",
				"You welcomed Jaehyuk's KakaoTalk message after ten years and replied.")
		if _has_relationship_memory(character_id, [
			"jaehyuk_message_guarded",
		]):
			return LocaleManager.ui(
				"10년 만에 온 재혁의 카카오톡에 조심스럽게 답장했다.",
				"You replied cautiously to Jaehyuk's KakaoTalk message after ten years.")
	var stage := CORE_LOOP.relationship_stage(character_id)
	match stage:
		"met":
			return LocaleManager.ui(
				"한 번 마주쳤다. 다시 만날 약속은 없다.",
				"You met once. Nothing has promised a second meeting.")
		"opening":
			return LocaleManager.ui(
				"한 번 더 말을 걸어도 어색하지 않은 사이다.",
				"Another conversation would not feel out of place.")
		"player_reached_out", "shared_commitment":
			return LocaleManager.ui(
				"직접 고른 다음 행동이 함께한 일의 기록에 남아 있다.",
				"The next action you chose is preserved in your shared history.")
	return LocaleManager.ui(
		"아직 서로 아는 사이가 아니다.",
		"You have not entered each other's time yet.")

func _section_title(text: String) -> Label:
	var label := _label(text, 15, COLOR_ACCENT, true)
	label.custom_minimum_size = Vector2(0, 24)
	return label


func _offer_kind_label(kind: String) -> String:
	match kind:
		"career", "boss":
			return LocaleManager.ui("진로", "CAREER")
		"livelihood":
			return LocaleManager.ui("생계", "INCOME")
		"growth", "reflection":
			return LocaleManager.ui("성장", "GROWTH")
		"recovery":
			return LocaleManager.ui("회복", "RECOVERY")
		"care":
			return LocaleManager.ui("돌봄", "CARE")
		"encounter", "pursuit":
			return LocaleManager.ui("관계", "PEOPLE")
		"temptation":
			return LocaleManager.ui("유혹", "TEMPTATION")
	return LocaleManager.ui("선택", "OPTION")


func _offer_kind_color(kind: String) -> Color:
	match kind:
		"career", "boss":
			return COLOR_CAREER
		"livelihood":
			return COLOR_LIVELIHOOD
		"growth", "reflection":
			return COLOR_GROWTH
		"recovery":
			return COLOR_RECOVERY
		"care", "encounter", "pursuit", "temptation":
			return COLOR_RELATIONSHIP
	return COLOR_BORDER


func _offer_kind_icon(kind: String) -> Texture2D:
	var path := "res://assets/ui/icons/icon_goal.svg"
	match kind:
		"career", "boss":
			path = "res://assets/ui/icons/icon_job.svg"
		"livelihood":
			path = "res://assets/ui/icons/icon_aruba.svg"
		"growth", "reflection":
			path = "res://assets/ui/icons/icon_study.svg"
		"recovery":
			path = "res://assets/ui/icons/icon_rest.svg"
		"care", "encounter", "pursuit", "temptation":
			path = "res://assets/ui/icons/icon_relationship.svg"
	return load(path) as Texture2D


func _apply_offer_style(
		button: Button, kind: String, armed: bool, assigned: bool) -> void:
	var kind_color := _offer_kind_color(kind)
	var bg := Color("#182029", 0.99) if assigned else Color("#10151b", 0.97)
	if assigned:
		bg = bg.lerp(kind_color, 0.08)
	var border := COLOR_ACCENT if armed else kind_color.darkened(0.12)
	var normal := _panel_style(bg, border, 3 if armed else 1)
	var hover := _panel_style(bg.lightened(0.06), kind_color, 2)
	var focus := _panel_style(bg.lightened(0.08), COLOR_ACCENT, 3)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_stylebox_override("pressed", focus)
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", COLOR_TEXT)
	button.add_theme_color_override("font_focus_color", COLOR_TEXT)


func _apply_week_style(
		button: Button, bundle_id: String, selected: bool, locked: bool) -> void:
	var filled := not bundle_id.is_empty()
	var kind := str(CORE_LOOP.bundle(bundle_id).get("kind", "")) if filled else ""
	var kind_color := _offer_kind_color(kind) if filled else COLOR_BORDER
	var bg := Color("#182029", 0.99) if filled else Color("#0d1218", 0.96)
	var border := COLOR_ACCENT if selected else kind_color.darkened(0.12)
	var normal := _panel_style(bg, border, 3 if selected else 1)
	var focus := _panel_style(bg.lightened(0.08), COLOR_ACCENT, 3)
	var disabled := _panel_style(
		Color("#161b22", 0.98), kind_color.darkened(0.30), 2 if locked else 1)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", focus)
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_stylebox_override("pressed", focus)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", COLOR_TEXT)
	button.add_theme_color_override("font_focus_color", COLOR_TEXT)
	button.add_theme_color_override("font_disabled_color", Color("#b9c0c9"))

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


func _set_button_disabled(button: BaseButton, disabled: bool) -> void:
	button.disabled = disabled
	button.focus_mode = Control.FOCUS_NONE if disabled else Control.FOCUS_ALL


func _focus_on_hover(control: Control) -> void:
	if not is_instance_valid(control) or not control.is_visible_in_tree() \
			or control.focus_mode == Control.FOCUS_NONE:
		return
	if control is BaseButton and (control as BaseButton).disabled:
		return
	control.grab_focus()

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

func _on_language_changed(_language: String) -> void:
	if visible:
		_rebuild()
