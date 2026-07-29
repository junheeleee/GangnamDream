extends Control
## ORDER-57: 월초 휴대폰 일정. 네 주의 약속을 한 화면에서 배치한다.

signal plan_committed(month_index: int, schedule: Dictionary, routines: Dictionary)
signal phone_closed

const CORE_LOOP := preload("res://systems/DemoCoreLoopV2.gd")
const PHONE_SYSTEM := preload("res://systems/PhoneSystem.gd")
const COLOR_SCREEN := Color("#0d1117")
const COLOR_PANEL := Color("#10141a", 0.96)
const COLOR_PANEL_ALT := Color("#171c23", 0.96)
const COLOR_BORDER := Color("#4e5865")
const COLOR_TEXT := Color("#e7ebf0")
const COLOR_DIM := Color("#929ba7")
const COLOR_ACCENT := Color("#d8c38d")
const COLOR_DANGER := Color("#b66b6b")
const COLOR_SUCCESS := Color("#8db9a3")
const LEGACY_APP_IDS := ["messages", "calendar", "contacts", "summary"]
const PHONE_FRAME_STARTER := preload(
	"res://assets/ui/phone/phone_frame_starter.png")
const PHONE_FRAME_REFURBISHED := preload(
	"res://assets/ui/phone/phone_frame_refurbished.png")
const PHONE_FRAME_FLAGSHIP := preload(
	"res://assets/ui/phone/phone_frame_flagship.png")
const PHONE_MAX_WIDTH := 1180.0
const PHONE_EDGE_GAP := 24.0
const STARTER_FRAME_SIZE := Vector2(1672.0, 940.0)
const STARTER_SCREEN_RECT := Rect2(289.0, 130.0, 1094.0, 680.0)
const STARTER_LCD_LETTERBOX_PX := 32.0

var _month_index := 1
var _month_data: Dictionary = {}
var _schedule: Dictionary = {}
var _routines: Dictionary = {}
var _locked_by_week: Dictionary = {}
var _selected_week := 1
var _selected_offer_id := ""
var _active_tab := 1
var _review_pending := false
var _screen_mode := "home"
var _active_app_id := ""
var _pending_device_id := ""
var _device_feedback := ""
var _opened_once := false
var _last_opened_month := -1
var _read_only_plan := false
var _closed_phone_focus_key := ""
var _pending_phone_focus_key := ""
var _message_thread_title := ""
var _message_thread_body := ""
var _message_thread_bundle_id := ""
var _message_thread_key := ""
var _message_thread_kind := ""

var _font: FontFile
var _font_bold: FontFile
var _phone_frame: PanelContainer
var _phone_screen: VBoxContainer
var _status_date_label: Label
var _status_balance_label: Label
var _app_header: HBoxContainer
var _app_title_label: Label
var _page_label: Label
var _home_button: Button
var _back_button: Button
var _home_surface: GridContainer
var _app_scroll: ScrollContainer
var _app_surface: VBoxContainer
var _title_label: Label
var _month_label: Label
var _tab_buttons: Array[Button] = []
var _calendar_surface: HBoxContainer
var _read_only_surface: VBoxContainer
var _offer_list: VBoxContainer
var _slot_list: GridContainer
var _calendar_heading_label: Label
var _offer_buttons: Dictionary = {}
var _slot_buttons: Dictionary = {}
var _routine_buttons: Dictionary = {}
var _status_label: Label
var _detail_label: Label
var _hint_label: Label
var _confirm_button: Button
var _app_buttons: Dictionary = {}
var _device_buttons: Dictionary = {}
var _device_confirm_button: Button
var _favorite_cycle_button: Button
var _phone_open_tween: Tween
var _phone_animating := false
var _phone_rest_position := Vector2.ZERO
var _phone_frame_texture: TextureRect
var _phone_screen_inset: MarginContainer
var _phone_screen_mat: PanelContainer
var _phone_lcd_inset: MarginContainer
var _phone_lcd_clip: Control
var _phone_display_panel: PanelContainer
var _phone_content_margin: MarginContainer
var _phone_wallpaper: TextureRect
var _phone_wallpaper_photo: TextureRect
var _phone_lcd_haze: ColorRect
var _status_network_label: Label
var _phone_gesture_bar: PanelContainer
var _phone_legacy_nav: Control
var _phone_device_id := "starter"
var _phone_frame_aspect := STARTER_FRAME_SIZE.x / STARTER_FRAME_SIZE.y
var _phone_inset_ratio := Vector4(
	STARTER_SCREEN_RECT.position.x / STARTER_FRAME_SIZE.x,
	STARTER_SCREEN_RECT.position.y / STARTER_FRAME_SIZE.y,
	(STARTER_FRAME_SIZE.x - STARTER_SCREEN_RECT.end.x) / STARTER_FRAME_SIZE.x,
	(STARTER_FRAME_SIZE.y - STARTER_SCREEN_RECT.end.y) / STARTER_FRAME_SIZE.y)

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 96
	mouse_filter = Control.MOUSE_FILTER_STOP
	_font = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile
	_build_ui()
	resized.connect(_update_phone_geometry)
	LocaleManager.language_changed.connect(_on_language_changed)
	visible = false

func open(month_index: int, read_only: bool = false) -> bool:
	PHONE_SYSTEM.ensure_state()
	var reopen_same_month := _opened_once and _last_opened_month == month_index
	var previous_screen_mode := _screen_mode
	var previous_app_id := _active_app_id
	var previous_active_tab := _active_tab
	_month_index = month_index
	_month_data = CORE_LOOP.month_spec(month_index)
	var committed_plan := CORE_LOOP.plan_for_month(month_index)
	if read_only and committed_plan.is_empty():
		visible = false
		return false
	if read_only:
		_read_only_plan = true
		_schedule = (
			(committed_plan.get("schedule", {}) as Dictionary).duplicate(true)
			if committed_plan.get("schedule", {}) is Dictionary else {}
		)
		_routines = (
			(committed_plan.get("routines", {}) as Dictionary).duplicate(true)
			if committed_plan.get("routines", {}) is Dictionary
			else CORE_LOOP.default_routines()
		)
		_locked_by_week = {}
		for raw_lock in _month_data.get("locked", []):
			if raw_lock is Dictionary:
				var lock: Dictionary = raw_lock
				var week := int(lock.get("week", 0))
				var bundle_id := str(lock.get("bundle", ""))
				if week > 0 and not bundle_id.is_empty():
					_locked_by_week[str(week)] = bundle_id
		_review_pending = false
		_pending_device_id = ""
		if reopen_same_month and previous_screen_mode == "app" \
				and PHONE_SYSTEM.visible_app_ids().has(previous_app_id):
			_screen_mode = "app"
			_active_app_id = previous_app_id
			_active_tab = 3 if previous_app_id == "calendar" \
				else previous_active_tab
		else:
			_active_tab = 3
			_screen_mode = "home"
			_active_app_id = ""
		var saved_weeks: Array = _month_data.get("weeks", [1, 4])
		_selected_week = int(saved_weeks[0])
		_last_opened_month = month_index
		_opened_once = true
	elif not reopen_same_month or _read_only_plan:
		_read_only_plan = false
		_schedule = {}
		_routines = CORE_LOOP.default_routines()
		if not GameState.current_job.is_empty():
			_routines["primary"] = "livelihood"
		_locked_by_week = {}
		_review_pending = false
		_pending_device_id = ""
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
		_screen_mode = "home"
		_active_app_id = ""
		_last_opened_month = month_index
		_opened_once = true
	_pending_phone_focus_key = _closed_phone_focus_key \
		if reopen_same_month else ""
	visible = true
	_refresh_phone_material()
	_update_phone_geometry()
	_rebuild()
	_play_phone_open_animation(read_only)
	return true

func close() -> void:
	var was_visible := visible
	if was_visible:
		_closed_phone_focus_key = _current_phone_focus_key()
	if is_instance_valid(_phone_open_tween):
		_phone_open_tween.kill()
	_phone_animating = false
	_phone_frame.rotation = 0.0
	_phone_frame.scale = Vector2.ONE
	_phone_frame.position = _phone_rest_position
	_phone_frame.modulate = Color.WHITE
	visible = false
	if was_visible:
		AudioManager.play_ui_close(-11.0)
		phone_closed.emit()

func schedule_snapshot() -> Dictionary:
	return _schedule.duplicate(true)

func routine_snapshot() -> Dictionary:
	return _routines.duplicate(true)

func review_pending() -> bool:
	return _review_pending

func read_only_plan() -> bool:
	return _read_only_plan

func assign_offer_to_week(bundle_id: String, week: int) -> bool:
	if _read_only_plan:
		return false
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
	_review_pending = false
	_rebuild()
	var focus_key := "%s:%s" % [slot, routine_id]
	var focus_button: Button = _routine_buttons.get(focus_key)
	if is_instance_valid(focus_button):
		focus_button.call_deferred("grab_focus")
	return true

func unassign_week(week: int) -> bool:
	if _read_only_plan:
		return false
	var week_key := str(week)
	if _locked_by_week.has(week_key) or not _schedule.has(week_key):
		return false
	_review_pending = false
	_schedule.erase(week_key)
	_refresh_calendar()
	return true

func _build_ui() -> void:
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color("#05080c", 0.68)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	_phone_frame = PanelContainer.new()
	_phone_frame.name = "LandscapePhoneFrame"
	_phone_frame.clip_contents = false
	_phone_frame.add_theme_stylebox_override(
		"panel", _rounded_panel_style(Color.TRANSPARENT, Color.TRANSPARENT, 0, 34))
	add_child(_phone_frame)

	# The generated frame is a real transparent material layer. Live UI sits
	# behind its glass opening; the frame itself never catches pointer input.
	var frame_clip := Control.new()
	frame_clip.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame_clip.clip_contents = false
	_phone_frame.add_child(frame_clip)

	_phone_screen_inset = MarginContainer.new()
	_phone_screen_inset.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame_clip.add_child(_phone_screen_inset)

	# The starter handset has a 16:10-ish glass opening. A black inner mat and
	# smaller 16:9 LCD keep it from reading like a current edge-to-edge panel.
	_phone_screen_mat = PanelContainer.new()
	_phone_screen_mat.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_phone_screen_mat.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_phone_screen_mat.clip_contents = true
	_phone_screen_mat.add_theme_stylebox_override(
		"panel", _phone_screen_mat_style(7))
	_phone_screen_inset.add_child(_phone_screen_mat)
	_phone_lcd_inset = MarginContainer.new()
	_phone_lcd_inset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_phone_lcd_inset.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_phone_screen_mat.add_child(_phone_lcd_inset)
	_phone_lcd_clip = Control.new()
	_phone_lcd_clip.name = "FixedLcdViewport"
	_phone_lcd_clip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_phone_lcd_clip.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_phone_lcd_clip.clip_contents = true
	_phone_lcd_inset.add_child(_phone_lcd_clip)

	_phone_display_panel = PanelContainer.new()
	_phone_display_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_phone_display_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_phone_display_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_phone_display_panel.clip_contents = true
	_phone_display_panel.add_theme_stylebox_override(
		"panel", _rounded_panel_style(COLOR_SCREEN, Color("#252c35"), 1, 28))
	_phone_lcd_clip.add_child(_phone_display_panel)

	_phone_wallpaper = TextureRect.new()
	_phone_wallpaper.name = "PhoneWallpaper"
	_phone_wallpaper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_phone_wallpaper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_phone_wallpaper.stretch_mode = TextureRect.STRETCH_SCALE
	_phone_wallpaper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var wallpaper_gradient := Gradient.new()
	wallpaper_gradient.offsets = PackedFloat32Array([0.0, 0.46, 1.0])
	wallpaper_gradient.colors = PackedColorArray([
		Color("#182232"), Color("#101721"), Color("#080b11")])
	var wallpaper_texture := GradientTexture2D.new()
	wallpaper_texture.width = 1024
	wallpaper_texture.height = 512
	wallpaper_texture.fill_from = Vector2(0.0, 0.0)
	wallpaper_texture.fill_to = Vector2(1.0, 1.0)
	wallpaper_texture.gradient = wallpaper_gradient
	_phone_wallpaper.texture = wallpaper_texture
	_phone_display_panel.add_child(_phone_wallpaper)
	_phone_wallpaper_photo = TextureRect.new()
	_phone_wallpaper_photo.name = "PhoneWallpaperPhoto"
	_phone_wallpaper_photo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_phone_wallpaper_photo.texture = load(
		"res://assets/backgrounds/gangnam_night_street.png")
	_phone_wallpaper_photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_phone_wallpaper_photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_phone_wallpaper_photo.modulate = Color(0.32, 0.38, 0.46, 0.22)
	_phone_wallpaper_photo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_phone_display_panel.add_child(_phone_wallpaper_photo)

	_phone_content_margin = MarginContainer.new()
	_phone_content_margin.add_theme_constant_override("margin_left", 46)
	_phone_content_margin.add_theme_constant_override("margin_right", 20)
	_phone_content_margin.add_theme_constant_override("margin_top", 6)
	_phone_content_margin.add_theme_constant_override("margin_bottom", 6)
	_phone_display_panel.add_child(_phone_content_margin)

	_phone_screen = VBoxContainer.new()
	_phone_screen.add_theme_constant_override("separation", 4)
	_phone_content_margin.add_child(_phone_screen)

	_phone_lcd_haze = ColorRect.new()
	_phone_lcd_haze.name = "StarterLcdHaze"
	_phone_lcd_haze.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_phone_lcd_haze.color = Color.TRANSPARENT
	_phone_lcd_haze.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_phone_lcd_haze.z_index = 10
	_phone_display_panel.add_child(_phone_lcd_haze)

	var status_bar := HBoxContainer.new()
	status_bar.custom_minimum_size = Vector2(0, 22)
	status_bar.add_theme_constant_override("separation", 12)
	_phone_screen.add_child(status_bar)
	_status_network_label = _label("LTE", 12, COLOR_TEXT, true)
	_status_network_label.custom_minimum_size = Vector2(82, 0)
	status_bar.add_child(_status_network_label)
	_status_date_label = _label("", 12, COLOR_DIM, true)
	_status_date_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_status_date_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_bar.add_child(_status_date_label)
	_status_balance_label = _label("", 12, COLOR_TEXT, true)
	_status_balance_label.custom_minimum_size = Vector2(110, 0)
	_status_balance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status_bar.add_child(_status_balance_label)

	var status_divider := HSeparator.new()
	status_divider.add_theme_color_override("color", Color("#ffffff", 0.09))
	_phone_screen.add_child(status_divider)

	_app_header = HBoxContainer.new()
	_app_header.custom_minimum_size = Vector2(0, 34)
	_app_header.add_theme_constant_override("separation", 8)
	_phone_screen.add_child(_app_header)
	_home_button = _phone_nav_button("⌂")
	_home_button.pressed.connect(_show_home)
	_home_button.mouse_entered.connect(_home_button.grab_focus)
	_app_header.add_child(_home_button)
	_back_button = _phone_nav_button("‹")
	_back_button.pressed.connect(_go_back_one_level)
	_back_button.mouse_entered.connect(_back_button.grab_focus)
	_app_header.add_child(_back_button)
	_app_title_label = _label("", 17, COLOR_TEXT, true)
	_app_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_app_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_app_header.add_child(_app_title_label)
	_page_label = _label("", 12, COLOR_ACCENT, true)
	_page_label.custom_minimum_size = Vector2(164, 0)
	_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_page_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_app_header.add_child(_page_label)

	_title_label = _label("", 1, Color.TRANSPARENT)
	_title_label.visible = false
	_phone_screen.add_child(_title_label)
	_month_label = _label("", 1, Color.TRANSPARENT)
	_month_label.visible = false
	_phone_screen.add_child(_month_label)

	_home_surface = GridContainer.new()
	_home_surface.columns = 4
	_home_surface.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_home_surface.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_home_surface.add_theme_constant_override("h_separation", 8)
	_home_surface.add_theme_constant_override("v_separation", 4)
	_phone_screen.add_child(_home_surface)

	_app_scroll = ScrollContainer.new()
	_app_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_app_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_app_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_app_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_app_scroll.follow_focus = true
	_phone_screen.add_child(_app_scroll)

	_app_surface = VBoxContainer.new()
	_app_surface.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_app_surface.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_app_surface.add_theme_constant_override("separation", 6)
	_app_scroll.add_child(_app_surface)

	# Kept as public compatibility controls for targeted QA and legacy callers.
	# App navigation itself is owned by the phone home screen.
	for index in range(4):
		var compatibility_tab := Button.new()
		compatibility_tab.visible = false
		compatibility_tab.pressed.connect(_switch_tab.bind(index))
		_app_header.add_child(compatibility_tab)
		_tab_buttons.append(compatibility_tab)

	_calendar_surface = HBoxContainer.new()
	_calendar_surface.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_calendar_surface.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_calendar_surface.add_theme_constant_override("separation", 14)
	_app_surface.add_child(_calendar_surface)

	var offers_column := VBoxContainer.new()
	offers_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	offers_column.add_theme_constant_override("separation", 5)
	_calendar_surface.add_child(offers_column)
	offers_column.add_child(_section_title(
		LocaleManager.ui("이번 달 온 제안", "OFFERS THIS MONTH")))
	_offer_list = VBoxContainer.new()
	_offer_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_offer_list.add_theme_constant_override("separation", 3)
	offers_column.add_child(_offer_list)

	var calendar_column := VBoxContainer.new()
	calendar_column.custom_minimum_size = Vector2(372, 0)
	calendar_column.add_theme_constant_override("separation", 5)
	_calendar_surface.add_child(calendar_column)
	_calendar_heading_label = _section_title("")
	calendar_column.add_child(_calendar_heading_label)
	_slot_list = GridContainer.new()
	_slot_list.columns = 2
	_slot_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_slot_list.add_theme_constant_override("h_separation", 6)
	_slot_list.add_theme_constant_override("v_separation", 6)
	calendar_column.add_child(_slot_list)
	_detail_label = _label("", 13, COLOR_DIM)
	_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_label.custom_minimum_size = Vector2(0, 44)
	_detail_label.max_lines_visible = 3
	_detail_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	calendar_column.add_child(_detail_label)
	_status_label = _label("", 13, COLOR_ACCENT, true)
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_label.max_lines_visible = 2
	calendar_column.add_child(_status_label)

	_read_only_surface = VBoxContainer.new()
	_read_only_surface.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_read_only_surface.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_read_only_surface.add_theme_constant_override("separation", 7)
	_app_surface.add_child(_read_only_surface)

	var footer := HBoxContainer.new()
	footer.custom_minimum_size = Vector2(0, 34)
	footer.add_theme_constant_override("separation", 10)
	_phone_screen.add_child(footer)
	var footer_spacer := Control.new()
	footer_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(footer_spacer)
	_hint_label = _label("", 12, COLOR_DIM)
	_hint_label.anchor_left = 0.5
	_hint_label.anchor_top = 1.0
	_hint_label.anchor_right = 0.5
	_hint_label.anchor_bottom = 1.0
	_hint_label.offset_left = -380.0
	_hint_label.offset_top = -38.0
	_hint_label.offset_right = 380.0
	_hint_label.offset_bottom = -10.0
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_label.max_lines_visible = 2
	_hint_label.z_index = 40
	add_child(_hint_label)
	_confirm_button = _button(LocaleManager.ui(
		"이 일정으로 첫 주를 시작한다",
		"Begin the First Week with This Plan"), true)
	_confirm_button.custom_minimum_size = Vector2(266, 34)
	_confirm_button.pressed.connect(_commit_plan)
	_confirm_button.mouse_entered.connect(_confirm_button.grab_focus)
	footer.add_child(_confirm_button)

	var gesture_layer := Control.new()
	gesture_layer.name = "PhoneGestureLayer"
	gesture_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gesture_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gesture_layer.z_index = 20
	_phone_display_panel.add_child(gesture_layer)
	_phone_gesture_bar = PanelContainer.new()
	_phone_gesture_bar.name = "PhoneGestureBar"
	_phone_gesture_bar.anchor_left = 0.5
	_phone_gesture_bar.anchor_top = 1.0
	_phone_gesture_bar.anchor_right = 0.5
	_phone_gesture_bar.anchor_bottom = 1.0
	_phone_gesture_bar.offset_left = -44.0
	_phone_gesture_bar.offset_top = -7.0
	_phone_gesture_bar.offset_right = 44.0
	_phone_gesture_bar.offset_bottom = -3.0
	_phone_gesture_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var gesture_style := StyleBoxFlat.new()
	gesture_style.bg_color = Color("#e7ebf0", 0.72)
	gesture_style.set_corner_radius_all(4)
	_phone_gesture_bar.add_theme_stylebox_override("panel", gesture_style)
	gesture_layer.add_child(_phone_gesture_bar)
	# The starter's navigation symbols and home key are part of the generated
	# shell. Keep only invisible hit areas over the physical controls.
	_phone_legacy_nav = Control.new()
	_phone_legacy_nav.name = "LegacyAndroidNavigation"
	_phone_legacy_nav.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_phone_legacy_nav.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_phone_legacy_nav.z_index = 40
	frame_clip.add_child(_phone_legacy_nav)
	for nav_spec in [
		[Rect2(1415.0, 195.0, 155.0, 125.0), "_show_home", "menu"],
		[Rect2(1405.0, 340.0, 170.0, 240.0), "_show_home", "home"],
		[Rect2(1415.0, 620.0, 155.0, 135.0), "_go_back_one_level", "back"],
	]:
		var nav_button := Button.new()
		var key_rect: Rect2 = nav_spec[0]
		nav_button.text = ""
		nav_button.flat = true
		nav_button.focus_mode = Control.FOCUS_NONE
		nav_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		nav_button.set_meta("physical_key", str(nav_spec[2]))
		nav_button.anchor_left = key_rect.position.x / STARTER_FRAME_SIZE.x
		nav_button.anchor_top = key_rect.position.y / STARTER_FRAME_SIZE.y
		nav_button.anchor_right = key_rect.end.x / STARTER_FRAME_SIZE.x
		nav_button.anchor_bottom = key_rect.end.y / STARTER_FRAME_SIZE.y
		for state in ["normal", "hover", "pressed", "focus", "disabled"]:
			nav_button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
		nav_button.pressed.connect(Callable(self, str(nav_spec[1])))
		_phone_legacy_nav.add_child(nav_button)

	_phone_frame_texture = TextureRect.new()
	_phone_frame_texture.name = "PhysicalPhoneMaterial"
	_phone_frame_texture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_phone_frame_texture.texture = PHONE_FRAME_STARTER
	_phone_frame_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_phone_frame_texture.stretch_mode = TextureRect.STRETCH_SCALE
	_phone_frame_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_phone_frame_texture.z_index = 30
	frame_clip.add_child(_phone_frame_texture)
	_update_phone_geometry()

func _rebuild() -> void:
	_refresh_phone_material()
	_update_phone_geometry()
	_title_label.text = LocaleManager.ui(
		"%d월 · %s" % [_month_index, str(_month_data.get("title_ko", ""))],
		"MONTH %d · %s" % [_month_index, str(_month_data.get("title_en", ""))])
	if _read_only_plan:
		_month_label.text = LocaleManager.ui(
			"확정한 네 주와 매주 할 일을 확인한다. 이달 일정은 바꿀 수 없다.",
			"Review the four confirmed weeks and weekly routines. This month's plan is locked.")
	elif _review_pending:
		_month_label.text = LocaleManager.ui(
			"이번 달에 할 일과 하지 않을 일을 확인한 뒤 계획을 확정한다.",
			"Review what you will and will not do this month, then confirm the plan.")
	else:
		_month_label.text = LocaleManager.ui(
			"이번 달 소식과 기회를 살펴보고, 네 주에 무엇을 할지 정한다.",
			"Review this month's updates and opportunities, then decide what to do each week.")
	_refresh_status_bar()
	_home_button.text = "⌂"
	_back_button.text = "‹"
	_home_surface.visible = _screen_mode == "home"
	_app_surface.visible = _screen_mode != "home"
	_app_scroll.visible = _screen_mode != "home"
	_phone_wallpaper_photo.visible = (
		_screen_mode == "home" and _phone_device_id != "starter")
	_app_header.visible = true
	_home_button.visible = false
	_back_button.visible = _screen_mode != "home"
	_confirm_button.visible = false
	if _screen_mode == "home":
		_app_title_label.text = ""
		_page_label.text = GameState.format_money(GameState.money)
		# Keep the public calendar dictionaries populated even while the
		# phone home owns the visible surface.
		_rebuild_calendar()
		_rebuild_home()
	else:
		_rebuild_active_app()
	_refresh_footer()
	# Rebuilding an app frees the focused home tile. Read-only apps do not
	# create their own action button, so restore a visible controller target
	# after queued frees and the calendar's own deferred focus have settled.
	call_deferred("_restore_phone_focus")

func _restore_phone_focus() -> void:
	if not visible:
		return
	if not _pending_phone_focus_key.is_empty():
		var pending_key := _pending_phone_focus_key
		_pending_phone_focus_key = ""
		if _restore_phone_focus_key(pending_key):
			return
	var owner := get_viewport().gui_get_focus_owner()
	if owner is Control and is_ancestor_of(owner) \
			and (owner as Control).is_visible_in_tree():
		return
	if _screen_mode == "home":
		if not _app_buttons.is_empty():
			var first_app: Button = _app_buttons.values()[0]
			if is_instance_valid(first_app) and not first_app.disabled:
				first_app.grab_focus()
		return
	if _screen_mode == "device_confirm" \
			and is_instance_valid(_device_confirm_button) \
			and not _device_confirm_button.disabled:
		_device_confirm_button.grab_focus()
		return
	# Calendar rebuild paths already restore the exact offer, week, routine, or
	# confirmation target that initiated the rebuild. A generic fallback here
	# would steal that focus one deferred call later.
	if _active_app_id == "calendar" and not _read_only_plan:
		return
	if is_instance_valid(_back_button) and _back_button.visible \
			and not _back_button.disabled:
		_back_button.grab_focus()

func _current_phone_focus_key() -> String:
	var owner := get_viewport().gui_get_focus_owner()
	if not owner is Control or not is_ancestor_of(owner):
		return ""
	if owner == _home_button:
		return "nav:home"
	if owner == _back_button:
		return "nav:back"
	if owner == _device_confirm_button:
		return "device:confirm"
	if owner == _favorite_cycle_button:
		return "device:favorite"
	if owner == _confirm_button:
		return "calendar:confirm"
	for app_id in _app_buttons:
		if owner == _app_buttons.get(app_id):
			return "home:%s" % str(app_id)
	for device_id in _device_buttons:
		if owner == _device_buttons.get(device_id):
			return "device:%s" % str(device_id)
	for bundle_id in _offer_buttons:
		if owner == _offer_buttons.get(bundle_id):
			return "calendar:offer:%s" % str(bundle_id)
	for week in _slot_buttons:
		if owner == _slot_buttons.get(week):
			return "calendar:slot:%s" % str(week)
	for routine_key in _routine_buttons:
		if owner == _routine_buttons.get(routine_key):
			return "calendar:routine:%s" % str(routine_key)
	return ""

func _restore_phone_focus_key(key: String) -> bool:
	var target: Control = null
	if key == "nav:home":
		target = _home_button
	elif key == "nav:back":
		target = _back_button
	elif key == "device:confirm":
		target = _device_confirm_button
	elif key == "device:favorite":
		target = _favorite_cycle_button
	elif key == "calendar:confirm":
		target = _confirm_button
	elif key.begins_with("home:"):
		target = _app_buttons.get(key.trim_prefix("home:")) as Control
	elif key.begins_with("device:"):
		target = _device_buttons.get(key.trim_prefix("device:")) as Control
	elif key.begins_with("calendar:offer:"):
		target = _offer_buttons.get(
			key.trim_prefix("calendar:offer:")) as Control
	elif key.begins_with("calendar:slot:"):
		target = _slot_buttons.get(
			key.trim_prefix("calendar:slot:")) as Control
	elif key.begins_with("calendar:routine:"):
		target = _routine_buttons.get(
			key.trim_prefix("calendar:routine:")) as Control
	if not is_instance_valid(target) or not target.is_visible_in_tree() \
			or target.focus_mode == Control.FOCUS_NONE:
		return false
	if target is BaseButton and (target as BaseButton).disabled:
		return false
	target.grab_focus()
	return true

func _update_phone_geometry() -> void:
	if not is_instance_valid(_phone_frame):
		return
	var viewport_size := size
	if viewport_size.x <= 1.0 or viewport_size.y <= 1.0:
		viewport_size = get_viewport_rect().size
	var available := Vector2(
		maxf(480.0, viewport_size.x - PHONE_EDGE_GAP * 2.0),
		maxf(320.0, viewport_size.y - PHONE_EDGE_GAP * 2.0))
	var frame_width := minf(PHONE_MAX_WIDTH, available.x)
	var frame_height := frame_width / _phone_frame_aspect
	if frame_height > available.y:
		frame_height = available.y
		frame_width = frame_height * _phone_frame_aspect
	var frame_size := Vector2(frame_width, frame_height)
	if is_instance_valid(_phone_screen_inset):
		_phone_screen_inset.add_theme_constant_override(
			"margin_left", ceili(frame_size.x * _phone_inset_ratio.x))
		_phone_screen_inset.add_theme_constant_override(
			"margin_top", ceili(frame_size.y * _phone_inset_ratio.y))
		_phone_screen_inset.add_theme_constant_override(
			"margin_right", ceili(frame_size.x * _phone_inset_ratio.z))
		_phone_screen_inset.add_theme_constant_override(
			"margin_bottom", ceili(frame_size.y * _phone_inset_ratio.w))
	if is_instance_valid(_phone_lcd_inset):
		var letterbox := ceili(
			frame_size.y * STARTER_LCD_LETTERBOX_PX / STARTER_FRAME_SIZE.y
		) if _phone_device_id == "starter" else 0
		_phone_lcd_inset.add_theme_constant_override("margin_left", 0)
		_phone_lcd_inset.add_theme_constant_override("margin_top", letterbox)
		_phone_lcd_inset.add_theme_constant_override("margin_right", 0)
		_phone_lcd_inset.add_theme_constant_override("margin_bottom", letterbox)
	_phone_rest_position = (viewport_size - frame_size) * 0.5
	_phone_frame.size = frame_size
	_phone_frame.pivot_offset = frame_size * 0.5
	if not _phone_animating:
		_phone_frame.position = _phone_rest_position

func _play_phone_open_animation(read_only: bool) -> void:
	if is_instance_valid(_phone_open_tween):
		_phone_open_tween.kill()
	_phone_animating = false
	_phone_frame.rotation = 0.0
	_phone_frame.scale = Vector2.ONE
	_phone_frame.position = _phone_rest_position
	_phone_frame.modulate = Color.WHITE
	var reduce_motion := bool(SaveManager.get_setting(
		"reduce_motion", SaveManager.get_setting("reduced_motion", false)))
	if reduce_motion:
		_phone_frame.modulate.a = 0.0
		_phone_open_tween = create_tween()
		_phone_open_tween.tween_property(
			_phone_frame, "modulate:a", 1.0, 0.12).set_trans(Tween.TRANS_SINE)
	else:
		_phone_animating = true
		var viewport_size := size
		if viewport_size.x <= 1.0 or viewport_size.y <= 1.0:
			viewport_size = get_viewport_rect().size
		_phone_frame.position = _phone_rest_position + Vector2(
			viewport_size.x * 0.22, viewport_size.y * 0.42)
		_phone_frame.rotation = PI * 0.5
		_phone_frame.scale = Vector2(0.58, 0.58)
		_phone_frame.modulate = Color(0.82, 0.86, 0.92, 0.0)
		_phone_open_tween = create_tween().set_parallel(true)
		_phone_open_tween.tween_property(
			_phone_frame, "position", _phone_rest_position, 0.46
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_phone_open_tween.tween_property(
			_phone_frame, "rotation", 0.0, 0.42
		).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		_phone_open_tween.tween_property(
			_phone_frame, "scale", Vector2.ONE, 0.44
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_phone_open_tween.tween_property(
			_phone_frame, "modulate", Color.WHITE, 0.18
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		_phone_open_tween.chain().tween_callback(func():
			_phone_animating = false
			_phone_frame.position = _phone_rest_position
			_phone_frame.rotation = 0.0
			_phone_frame.scale = Vector2.ONE)
	if read_only or _phone_message_badge_count() == 0:
		AudioManager.play_ui_open(-11.0)
	else:
		AudioManager.play_varied("phone_vibrate", -8.0, 0.97, 1.02)
		AudioManager.play_delayed("phone_notification", 0.22, -10.0)

func _refresh_phone_material() -> void:
	if not is_instance_valid(_phone_frame_texture):
		return
	var device_id := str(PHONE_SYSTEM.current_device().get("id", "starter"))
	_phone_device_id = device_id
	match device_id:
		"starter":
			_phone_frame_texture.texture = PHONE_FRAME_STARTER
			_phone_frame_aspect = STARTER_FRAME_SIZE.x / STARTER_FRAME_SIZE.y
			_phone_inset_ratio = Vector4(
				STARTER_SCREEN_RECT.position.x / STARTER_FRAME_SIZE.x,
				STARTER_SCREEN_RECT.position.y / STARTER_FRAME_SIZE.y,
				(STARTER_FRAME_SIZE.x - STARTER_SCREEN_RECT.end.x) \
					/ STARTER_FRAME_SIZE.x,
				(STARTER_FRAME_SIZE.y - STARTER_SCREEN_RECT.end.y) \
					/ STARTER_FRAME_SIZE.y)
		"flagship":
			_phone_frame_texture.texture = PHONE_FRAME_FLAGSHIP
			_phone_frame_aspect = 1512.0 / 720.0
			_phone_inset_ratio = Vector4(
				23.0 / 1512.0, 29.0 / 720.0,
				22.0 / 1512.0, 24.0 / 720.0)
		_:
			_phone_frame_texture.texture = PHONE_FRAME_REFURBISHED
			_phone_frame_aspect = 1613.0 / 700.0
			_phone_inset_ratio = Vector4(
				34.0 / 1613.0, 35.0 / 700.0,
				37.0 / 1613.0, 31.0 / 700.0)
	if is_instance_valid(_phone_gesture_bar):
		_phone_gesture_bar.visible = device_id != "starter"
	if is_instance_valid(_phone_legacy_nav):
		_phone_legacy_nav.visible = device_id == "starter"
	if is_instance_valid(_phone_content_margin):
		_phone_content_margin.add_theme_constant_override(
			"margin_left", 12 if device_id == "starter" else 46)
		_phone_content_margin.add_theme_constant_override(
			"margin_right", 12 if device_id == "starter" else 20)
	if is_instance_valid(_phone_screen_mat):
		_phone_screen_mat.add_theme_stylebox_override(
			"panel", _phone_screen_mat_style(
				7 if device_id == "starter" else 28))
	if is_instance_valid(_phone_display_panel):
		_phone_display_panel.add_theme_stylebox_override(
			"panel", _rounded_panel_style(
				Color("#20282d") if device_id == "starter" else COLOR_SCREEN,
				Color("#56636b") if device_id == "starter" \
					else Color("#252c35"),
				1, 5 if device_id == "starter" else 28))
	if is_instance_valid(_phone_wallpaper):
		_phone_wallpaper.texture = _phone_wallpaper_texture(device_id)
	if is_instance_valid(_phone_wallpaper_photo):
		_phone_wallpaper_photo.visible = (
			_screen_mode == "home" and device_id != "starter")
	if is_instance_valid(_phone_lcd_haze):
		_phone_lcd_haze.color = Color(0.46, 0.56, 0.60, 0.09) \
			if device_id == "starter" else Color.TRANSPARENT

func _refresh_status_bar() -> void:
	if not is_instance_valid(_status_date_label):
		return
	_status_date_label.text = GameState.get_date_string()
	_status_network_label.text = "LTE"
	_status_balance_label.text = "87%"

func _phone_wallpaper_texture(device_id: String) -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.48, 1.0])
	gradient.colors = PackedColorArray([
		Color("#354148"), Color("#263137"), Color("#1a2125")
	]) if device_id == "starter" else PackedColorArray([
		Color("#182232"), Color("#101721"), Color("#080b11")
	])
	var texture := GradientTexture2D.new()
	texture.width = 1024
	texture.height = 512
	texture.fill_from = Vector2(0.0, 0.0)
	texture.fill_to = Vector2(1.0, 1.0)
	texture.gradient = gradient
	return texture

func _rebuild_home() -> void:
	_clear_children(_home_surface)
	_app_buttons.clear()
	var visible_apps: Array = PHONE_SYSTEM.home_app_ids()
	var favorite_id := PHONE_SYSTEM.favorite_app_id()
	for raw_app_id in visible_apps:
		var app_id := str(raw_app_id)
		var meta := _app_meta(app_id)
		if meta.is_empty():
			continue
		var tile := _phone_app_tile(
			app_id, meta, app_id == favorite_id)
		tile.name = "PhoneApp_%s" % app_id
		tile.pressed.connect(_open_app.bind(app_id))
		tile.mouse_entered.connect(tile.grab_focus)
		_home_surface.add_child(tile)
		_app_buttons[app_id] = tile
	if not visible_apps.is_empty():
		var first_button: Button = _app_buttons.get(str(visible_apps[0]))
		if is_instance_valid(first_button):
			first_button.call_deferred("grab_focus")

func _app_meta(app_id: String) -> Dictionary:
	match app_id:
		"messages":
			return {
				"label": LocaleManager.ui("메시지", "MESSAGES"),
				"icon": "res://assets/ui/phone/icon_messages.svg",
				"color": Color("#35a86b"),
			}
		"calendar":
			return {
				"label": LocaleManager.ui("일정", "CALENDAR"),
				"icon": "res://assets/ui/phone/icon_calendar.svg",
				"color": Color("#cc4d55"),
			}
		"contacts":
			return {
				"label": LocaleManager.ui("연락처", "CONTACTS"),
				"icon": "res://assets/ui/icons/icon_relationship.svg",
				"color": Color("#397dcc"),
			}
		"bank":
			return {
				"label": LocaleManager.ui("은행", "BANK"),
				"icon": "res://assets/ui/icons/icon_money.svg",
				"color": Color("#1c9b8d"),
			}
		"device":
			return {
				"label": LocaleManager.ui("기기", "DEVICE"),
				"icon": "res://assets/ui/phone/icon_device.svg",
				"color": Color("#687381"),
			}
		"investment":
			return {
				"label": LocaleManager.ui("투자", "INVEST"),
				"icon": "res://assets/ui/icons/icon_invest.svg",
				"color": Color("#4569aa"),
			}
		"leisure":
			return {
				"label": LocaleManager.ui("여가", "LEISURE"),
				"icon": "res://assets/ui/icons/icon_racetrack.svg",
				"color": Color("#b47b35"),
			}
		"games":
			return {
				"label": LocaleManager.ui("게임", "GAMES"),
				"icon": "res://assets/ui/phone/icon_games.svg",
				"color": Color("#7552b8"),
			}
	return {}

func _phone_app_tile(
		app_id: String, meta: Dictionary, favorite: bool) -> Button:
	var legacy_style := _phone_device_id == "starter"
	var icon_size := 56 if legacy_style else 64
	var icon_radius := 8 if legacy_style else 17
	var tile := Button.new()
	tile.text = ""
	tile.focus_mode = Control.FOCUS_ALL
	tile.custom_minimum_size = Vector2(0, 98 if legacy_style else 104)
	tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tile.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	tile.set_meta("phone_generation", "legacy" if legacy_style else "modern")
	tile.set_meta("phone_icon_size", icon_size)
	tile.set_meta("phone_icon_radius", icon_radius)
	for state in ["normal", "hover", "pressed", "focus"]:
		tile.add_theme_stylebox_override(
			state, _rounded_panel_style(
				Color.TRANSPARENT, Color.TRANSPARENT, 0,
				8 if legacy_style else 18))

	var layout := VBoxContainer.new()
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override("separation", 3)
	layout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(layout)

	var icon_center := CenterContainer.new()
	icon_center.custom_minimum_size = Vector2(0, 68 if legacy_style else 70)
	icon_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_child(icon_center)
	var icon_stage := Control.new()
	icon_stage.custom_minimum_size = Vector2(
		64 if legacy_style else 74, 68 if legacy_style else 70)
	icon_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_center.add_child(icon_stage)
	var icon_shell := PanelContainer.new()
	icon_shell.position = Vector2(4, 2) if legacy_style else Vector2(5, 2)
	icon_shell.size = Vector2(icon_size, icon_size)
	icon_shell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon_color: Color = meta.get("color", Color("#687381")) as Color
	if legacy_style:
		icon_color = icon_color.lerp(Color("#69747a"), 0.42).darkened(0.08)
	icon_shell.add_theme_stylebox_override(
		"panel", _rounded_panel_style(
			icon_color,
			Color("#c5cdd1", 0.28) if legacy_style \
				else Color("#ffffff", 0.22),
			1, icon_radius))
	icon_stage.add_child(icon_shell)
	tile.focus_entered.connect(
		_set_phone_app_icon_focus.bind(
			icon_shell, icon_color, icon_radius, true))
	tile.focus_exited.connect(
		_set_phone_app_icon_focus.bind(
			icon_shell, icon_color, icon_radius, false))
	var icon_margin := MarginContainer.new()
	var icon_padding := 14 if legacy_style else 16
	icon_margin.add_theme_constant_override("margin_left", icon_padding)
	icon_margin.add_theme_constant_override("margin_right", icon_padding)
	icon_margin.add_theme_constant_override("margin_top", icon_padding)
	icon_margin.add_theme_constant_override("margin_bottom", icon_padding)
	icon_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_shell.add_child(icon_margin)
	var icon := TextureRect.new()
	icon.texture = load(str(meta.get("icon", "")))
	icon.custom_minimum_size = Vector2(32, 32)
	icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_margin.add_child(icon)

	if app_id == "messages":
		var message_count := _phone_message_badge_count()
		if message_count > 0:
			var badge := PanelContainer.new()
			badge.position = Vector2(45, -1) \
				if legacy_style else Vector2(53, -2)
			badge.size = Vector2(22, 22) \
				if legacy_style else Vector2(24, 24)
			badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			badge.add_theme_stylebox_override(
				"panel", _rounded_panel_style(
					Color("#b94f56") if legacy_style else Color("#d84f59"),
					Color("#f7d5d8"), 1, 7 if legacy_style else 12))
			icon_stage.add_child(badge)
			var count := _label(str(mini(message_count, 99)), 11, Color.WHITE, true)
			count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			count.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			count.mouse_filter = Control.MOUSE_FILTER_IGNORE
			badge.add_child(count)
	if favorite:
		var pin := PanelContainer.new()
		pin.position = Vector2(-1, 42) \
			if legacy_style else Vector2(-1, 49)
		pin.size = Vector2(20, 20) \
			if legacy_style else Vector2(21, 21)
		pin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pin.add_theme_stylebox_override(
			"panel", _rounded_panel_style(
				Color("#b8ab82") if legacy_style else Color("#d8c38d"),
				Color("#fff0bc"), 1, 6 if legacy_style else 11))
		icon_stage.add_child(pin)
		var pin_label := _label("1", 10, Color("#17130a"), true)
		pin_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		pin_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		pin_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pin.add_child(pin_label)

	var app_label: Label = _label(
		str(meta.get("label", app_id)), 12 if legacy_style else 13,
		Color("#d1d7d8") if legacy_style else COLOR_TEXT, true)
	app_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	app_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	app_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_child(app_label)
	return tile

func _set_phone_app_icon_focus(
		icon_shell: PanelContainer, icon_color: Color,
		icon_radius: int, focused: bool) -> void:
	if not is_instance_valid(icon_shell):
		return
	icon_shell.add_theme_stylebox_override(
		"panel", _rounded_panel_style(
			icon_color,
			COLOR_ACCENT if focused else Color("#ffffff", 0.22),
			3 if focused else 1,
			icon_radius))

func _phone_message_badge_count() -> int:
	return _received_phone_offer_ids().size()

func _open_app(app_id: String) -> void:
	if app_id not in PHONE_SYSTEM.visible_app_ids():
		return
	AudioManager.play_ui_click(-9.0)
	_screen_mode = "app"
	_active_app_id = app_id
	_pending_device_id = ""
	match app_id:
		"messages":
			_active_tab = 0
		"calendar":
			_active_tab = 3 if _read_only_plan else 1
		"contacts":
			_active_tab = 2
	_rebuild()
	_app_scroll.scroll_vertical = 0
	_play_app_surface_reveal(_app_surface)

func _show_home() -> void:
	_review_pending = false
	_pending_device_id = ""
	_screen_mode = "home"
	_active_app_id = ""
	_rebuild()
	_play_app_surface_reveal(_home_surface)

func _play_app_surface_reveal(surface: Control) -> void:
	if not is_instance_valid(surface):
		return
	surface.modulate = Color.WHITE
	if bool(SaveManager.get_setting(
			"reduce_motion", SaveManager.get_setting("reduced_motion", false))):
		return
	surface.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(
		surface, "modulate:a", 1.0, 0.16
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _rebuild_active_app() -> void:
	_calendar_surface.visible = false
	_read_only_surface.visible = true
	_clear_children(_read_only_surface)
	_device_buttons.clear()
	_device_confirm_button = null
	_favorite_cycle_button = null
	if _screen_mode == "message_thread":
		_app_title_label.text = LocaleManager.ui("메시지", "MESSAGES")
		_page_label.text = ""
		_build_message_thread_surface()
		return
	if _screen_mode == "device_confirm":
		_app_title_label.text = LocaleManager.ui("기기 구매 확인", "CONFIRM DEVICE PURCHASE")
		_page_label.text = LocaleManager.ui("확정 전", "NOT PURCHASED")
		_build_device_confirmation()
		return
	match _active_app_id:
		"messages":
			_app_title_label.text = LocaleManager.ui("메시지", "MESSAGES")
			_page_label.text = LocaleManager.ui("이번 달", "THIS MONTH")
			_build_messages_surface()
		"calendar":
			if _active_tab == 3:
				_app_title_label.text = LocaleManager.ui(
					"일정 · 이번 달 정리", "CALENDAR · MONTH REVIEW")
				_page_label.text = LocaleManager.ui("정리", "SUMMARY")
				_build_record_surface()
			else:
				_active_tab = 1
				_app_title_label.text = LocaleManager.ui("일정", "CALENDAR")
				_page_label.text = LocaleManager.ui("네 주 계획", "FOUR-WEEK PLAN")
				_calendar_surface.visible = true
				_read_only_surface.visible = false
				_rebuild_calendar()
		"contacts":
			_app_title_label.text = LocaleManager.ui(
				"만난 사람", "PEOPLE MET")
			_page_label.text = LocaleManager.ui(
				"연락수단과 함께한 일", "CONTACT METHODS AND SHARED HISTORY")
			_build_people_surface()
		"bank":
			_app_title_label.text = LocaleManager.ui("은행", "BANK")
			_page_label.text = LocaleManager.ui("잔액 확인", "BALANCE")
			_build_bank_surface()
		"device":
			_app_title_label.text = LocaleManager.ui("기기", "DEVICE")
			_page_label.text = LocaleManager.ui("기기 변경", "DEVICE AND UPGRADES")
			_build_device_surface()
		"investment":
			_app_title_label.text = LocaleManager.ui("투자", "INVEST")
			_page_label.text = LocaleManager.ui("조회만 가능", "VIEW ONLY")
			_build_investment_surface()
		"leisure":
			_app_title_label.text = LocaleManager.ui("여가", "LEISURE")
			_page_label.text = LocaleManager.ui("발견한 장소", "DISCOVERED PLACES")
			_build_leisure_surface()
		"games":
			_app_title_label.text = LocaleManager.ui("게임", "GAMES")
			_page_label.text = LocaleManager.ui("선택형 놀이", "OPTIONAL PLAY")
			_build_games_surface()
		_:
			_show_home()

func _build_bank_surface() -> void:
	var bank: Dictionary = PHONE_SYSTEM.bank_snapshot()
	var balance := float(bank.get("balance", GameState.money))
	var next_fixed := float(bank.get(
		"next_fixed_expense", GameState.get_monthly_required_cash()))
	var arrears: float = maxf(0.0, float(bank.get("arrears", 0.0)))
	var loan_total: float = maxf(0.0, float(bank.get(
		"loan_total", GameState.get_loan_total())))
	_page_label.text = LocaleManager.ui("내 계좌", "MY ACCOUNT")
	var bank_body := HBoxContainer.new()
	bank_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bank_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bank_body.add_theme_constant_override("separation", 10)
	_read_only_surface.add_child(bank_body)

	var account_card := PanelContainer.new()
	account_card.custom_minimum_size = Vector2(430, 0)
	account_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	account_card.add_theme_stylebox_override(
		"panel", _rounded_panel_style(
			Color("#174b4d"), Color("#7cc4b4"), 1, 22))
	bank_body.add_child(account_card)
	var account_margin := MarginContainer.new()
	account_margin.add_theme_constant_override("margin_left", 24)
	account_margin.add_theme_constant_override("margin_right", 24)
	account_margin.add_theme_constant_override("margin_top", 20)
	account_margin.add_theme_constant_override("margin_bottom", 18)
	account_card.add_child(account_margin)
	var account_copy := VBoxContainer.new()
	account_copy.add_theme_constant_override("separation", 7)
	account_margin.add_child(account_copy)
	account_copy.add_child(_label(
		LocaleManager.ui("생활비 통장", "DAILY ACCOUNT"), 14,
		Color("#bfe6dc"), true))
	var account_number := _label("110  ••••  2048", 12, Color("#91bdb4"))
	account_copy.add_child(account_number)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	account_copy.add_child(spacer)
	account_copy.add_child(_label(
		LocaleManager.ui("쓸 수 있는 돈", "AVAILABLE BALANCE"),
		13, Color("#bfe6dc")))
	account_copy.add_child(_label(
		GameState.format_money(balance), 30, Color.WHITE, true))

	var payment_stack := VBoxContainer.new()
	payment_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	payment_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	payment_stack.add_theme_constant_override("separation", 7)
	bank_body.add_child(payment_stack)
	payment_stack.add_child(_label(
		LocaleManager.ui("예정된 납부", "UPCOMING"), 13, COLOR_ACCENT, true))
	payment_stack.add_child(_bank_metric_row(
		LocaleManager.ui("다음 고정비", "Next fixed cost"),
		GameState.format_money(next_fixed), false))
	payment_stack.add_child(_bank_metric_row(
		LocaleManager.ui("체납", "Arrears"),
		GameState.format_money(arrears) if arrears > 0.0 else LocaleManager.ui(
			"없음", "None"), arrears > 0.0))
	payment_stack.add_child(_bank_metric_row(
		LocaleManager.ui("대출 원금", "Loan principal"),
		GameState.format_money(loan_total) if loan_total > 0.0 else LocaleManager.ui(
			"없음", "None"), loan_total > 0.0))
	var as_of := _label(LocaleManager.ui(
		"%s 기준 · 고정비에는 주거비와 대출 이자가 포함된다." % GameState.get_date_string(),
		"As of %s · Fixed cost includes housing and loan interest." % GameState.get_date_string()),
		11, COLOR_DIM)
	as_of.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	as_of.max_lines_visible = 2
	payment_stack.add_child(as_of)

func _bank_metric_row(title: String, value: String, danger: bool) -> Control:
	var row := PanelContainer.new()
	row.custom_minimum_size = Vector2(0, 52)
	row.add_theme_stylebox_override(
		"panel", _rounded_panel_style(
			Color("#141c25", 0.94),
			Color("#c06d72", 0.75) if danger else Color("#ffffff", 0.10),
			1, 12))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 13)
	margin.add_theme_constant_override("margin_right", 13)
	margin.add_theme_constant_override("margin_top", 7)
	margin.add_theme_constant_override("margin_bottom", 7)
	row.add_child(margin)
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 8)
	margin.add_child(line)
	var title_label := _label(title, 13, COLOR_DIM, true)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	line.add_child(title_label)
	var value_label := _label(
		value, 14, COLOR_DANGER if danger else COLOR_TEXT, true)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	line.add_child(value_label)
	return row

func _build_device_surface() -> void:
	var current: Dictionary = PHONE_SYSTEM.current_device()
	_page_label.text = _localized(current, "label")
	_read_only_surface.add_child(_section_title(LocaleManager.ui(
		"기기 둘러보기", "DEVICE STORE")))
	var device_grid := GridContainer.new()
	device_grid.columns = 2
	device_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	device_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	device_grid.add_theme_constant_override("h_separation", 10)
	device_grid.add_theme_constant_override("v_separation", 8)
	_read_only_surface.add_child(device_grid)
	for raw_spec in PHONE_SYSTEM.device_specs():
		if not raw_spec is Dictionary:
			continue
		var spec: Dictionary = raw_spec
		var device_id := str(spec.get("id", ""))
		if not bool(spec.get("runtime_implemented", false)) \
				and device_id != str(current.get("id", "")):
			continue
		if GameState.is_demo_build() \
				and device_id not in ["starter", "refurbished"] \
				and device_id != str(current.get("id", "")):
			continue
		var check: Dictionary = PHONE_SYSTEM.can_purchase_device(device_id)
		var is_current: bool = device_id == str(current.get("id", ""))
		var card := _device_store_card(spec, check, is_current)
		card.disabled = not bool(check.get("ok", false))
		if not card.disabled:
			card.pressed.connect(_begin_device_purchase.bind(device_id))
		card.mouse_entered.connect(card.grab_focus)
		device_grid.add_child(card)
		_device_buttons[device_id] = card
	if PHONE_SYSTEM.can_set_favorite_app("bank").get("reason", "") \
			not in ["device_not_supported"]:
		var favorite_id := PHONE_SYSTEM.favorite_app_id()
		var favorite_label := _phone_app_label(favorite_id)
		_favorite_cycle_button = _button(LocaleManager.ui(
			"홈 첫 칸 · %s\n누르면 다음 앱으로 바뀐다.",
			"HOME FIRST · %s\nPress to choose the next app.") % favorite_label, false)
		_favorite_cycle_button.set_meta("phone_compact", true)
		_favorite_cycle_button.custom_minimum_size = Vector2(0, 48)
		_favorite_cycle_button.add_theme_font_size_override("font_size", 13)
		_favorite_cycle_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_favorite_cycle_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		_favorite_cycle_button.pressed.connect(_cycle_home_favorite)
		_favorite_cycle_button.mouse_entered.connect(
			_favorite_cycle_button.grab_focus)
		_read_only_surface.add_child(_favorite_cycle_button)
	if not _device_feedback.is_empty():
		_read_only_surface.add_child(_label(_device_feedback, 13, COLOR_SUCCESS, true))

func _device_store_card(
		spec: Dictionary, check: Dictionary, is_current: bool) -> Button:
	var device_id := str(spec.get("id", ""))
	var price := float(spec.get("price", 0.0))
	var card := Button.new()
	card.text = ""
	card.focus_mode = Control.FOCUS_ALL
	card.custom_minimum_size = Vector2(0, 108)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override(
		"normal", _rounded_panel_style(
			Color("#121922", 0.94), Color("#ffffff", 0.10), 1, 16))
	card.add_theme_stylebox_override(
		"hover", _rounded_panel_style(
			Color("#1a2531"), Color("#ffffff", 0.25), 1, 16))
	card.add_theme_stylebox_override(
		"focus", _rounded_panel_style(
			Color("#1a2531"), COLOR_ACCENT, 2, 16))
	card.add_theme_stylebox_override(
		"pressed", _rounded_panel_style(
			Color("#223040"), COLOR_ACCENT, 2, 16))
	card.add_theme_stylebox_override(
		"disabled", _rounded_panel_style(
			Color("#10151c", 0.91),
			Color("#7cc4b4", 0.50) if is_current else Color("#ffffff", 0.06),
			1, 16))
	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 14)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(row)
	var product_stage := CenterContainer.new()
	product_stage.custom_minimum_size = Vector2(76, 0)
	product_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(product_stage)
	var handset := PanelContainer.new()
	handset.custom_minimum_size = Vector2(38, 72)
	handset.mouse_filter = Control.MOUSE_FILTER_IGNORE
	handset.add_theme_stylebox_override(
		"panel", _rounded_panel_style(
			_device_shell_color(device_id), Color("#cbd2da", 0.70), 2, 10))
	product_stage.add_child(handset)
	var handset_margin := MarginContainer.new()
	handset_margin.add_theme_constant_override("margin_left", 4)
	handset_margin.add_theme_constant_override("margin_right", 4)
	handset_margin.add_theme_constant_override("margin_top", 7)
	handset_margin.add_theme_constant_override("margin_bottom", 6)
	handset_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	handset.add_child(handset_margin)
	var handset_screen := PanelContainer.new()
	handset_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	handset_screen.add_theme_stylebox_override(
		"panel", _rounded_panel_style(
			Color("#172535"), Color("#ffffff", 0.08), 1, 6))
	handset_margin.add_child(handset_screen)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.alignment = BoxContainer.ALIGNMENT_CENTER
	copy.add_theme_constant_override("separation", 4)
	copy.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(copy)
	copy.add_child(_label(
		(LocaleManager.ui("사용 중 · ", "IN USE · ") if is_current else "")
			+ _localized(spec, "label"),
		15, COLOR_TEXT, true))
	copy.add_child(_label(
		"%s  ·  %s" % [
			GameState.format_money(price),
			_device_purchase_state_copy(check, is_current),
		], 12, COLOR_ACCENT if bool(check.get("ok", false)) else COLOR_DIM, true))
	var feature := _label(_device_feature_copy(spec), 12, COLOR_DIM)
	feature.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feature.max_lines_visible = 2
	feature.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	copy.add_child(feature)
	return card

func _device_shell_color(device_id: String) -> Color:
	match device_id:
		"starter":
			return Color("#4b5159")
		"refurbished":
			return Color("#8b9097")
		"midrange":
			return Color("#466783")
		"flagship":
			return Color("#a89161")
	return Color("#555d66")

func _device_feature_copy(spec: Dictionary) -> String:
	var device_id := str(spec.get("id", ""))
	match device_id:
		"starter":
			return LocaleManager.ui(
				"필수 앱 · 전화 · 접근성", "Essential apps · calls · accessibility")
		"refurbished":
			return LocaleManager.ui(
				"자주 쓰는 앱 1개를 홈 첫 칸에 고정",
				"Pin one favorite app to the first home slot")
		"midrange":
			return LocaleManager.ui(
				"바로가기 · 가격 알림 · 기록 검색", "Shortcuts · price alerts · record search")
		"flagship":
			return LocaleManager.ui(
				"사진·음성 기록 · 고급 게임", "Photo and voice notes · premium games")
	var features: Variant = spec.get("features", [])
	if features is Array:
		var parts: Array[String] = []
		for feature in features:
			parts.append(str(feature))
		return " · ".join(parts)
	return ""

func _device_purchase_state_copy(check: Dictionary, is_current: bool) -> String:
	if is_current:
		return LocaleManager.ui("지금 사용 중", "Currently in use")
	match str(check.get("reason", "")):
		"ok":
			return LocaleManager.ui("구매 가능", "Available")
		"not_yet_available":
			return LocaleManager.ui(
				"%d주부터 구매 가능" % int(check.get("available_from_week", 13)),
				"Available from week %d" % int(check.get("available_from_week", 13)))
		"insufficient_funds":
			return LocaleManager.ui("잔액 부족", "Insufficient balance")
		"already_owned":
			return LocaleManager.ui("이미 보유", "Already owned")
		"downgrade_blocked":
			return LocaleManager.ui("낮은 등급으로 바꿀 수 없음", "Downgrade unavailable")
		"not_purchasable_in_demo":
			return LocaleManager.ui("데모 이후", "After the demo")
		"not_implemented":
			return LocaleManager.ui("아직 판매하지 않음", "Not yet for sale")
	return LocaleManager.ui("구매할 수 없음", "Unavailable")

func _begin_device_purchase(device_id: String) -> void:
	var check: Dictionary = PHONE_SYSTEM.can_purchase_device(device_id)
	if not bool(check.get("ok", false)):
		_device_feedback = _device_purchase_state_copy(check, false)
		_rebuild()
		return
	_pending_device_id = device_id
	_device_feedback = ""
	_screen_mode = "device_confirm"
	_rebuild()
	if is_instance_valid(_device_confirm_button):
		_device_confirm_button.call_deferred("grab_focus")

func _build_device_confirmation() -> void:
	var check: Dictionary = PHONE_SYSTEM.can_purchase_device(_pending_device_id)
	var spec: Dictionary = check.get("device", {})
	if spec.is_empty() or not bool(check.get("ok", false)):
		_screen_mode = "app"
		_active_app_id = "device"
		_pending_device_id = ""
		_device_feedback = _device_purchase_state_copy(check, false)
		_rebuild_active_app()
		return
	var balance_before := float(check.get("balance_before", GameState.money))
	var price := float(check.get("price", spec.get("price", 0.0)))
	var balance_after := float(check.get("balance_after", balance_before - price))
	var bank: Dictionary = PHONE_SYSTEM.bank_snapshot()
	var fixed_cost := float(bank.get(
		"next_fixed_expense", GameState.get_monthly_required_cash()))
	_read_only_surface.add_child(_section_title(LocaleManager.ui(
		"결제 전 확인", "REVIEW BEFORE PAYMENT")))
	_read_only_surface.add_child(_read_only_row(
		_localized(spec, "label"),
		_device_feature_copy(spec), 72))
	var numbers := GridContainer.new()
	numbers.columns = 3
	numbers.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	numbers.add_theme_constant_override("h_separation", 8)
	_read_only_surface.add_child(numbers)
	numbers.add_child(_read_only_row(
		LocaleManager.ui("현재 잔액", "CURRENT BALANCE"),
		GameState.format_money(balance_before), 76))
	numbers.add_child(_read_only_row(
		LocaleManager.ui("기기 가격", "DEVICE PRICE"),
		"-%s" % GameState.format_money(price), 76))
	numbers.add_child(_read_only_row(
		LocaleManager.ui("구매 후 잔액", "BALANCE AFTER"),
		GameState.format_money(balance_after), 76))
	_read_only_surface.add_child(_read_only_row(
		LocaleManager.ui("다음 고정비", "NEXT FIXED COST"),
		LocaleManager.ui(
			"%s · 구매 후에도 따로 납부해야 한다." % GameState.format_money(fixed_cost),
			"%s · This remains due after the purchase." % GameState.format_money(fixed_cost)),
		68))
	_device_confirm_button = _button(LocaleManager.ui(
		"%s 결제하고 바꾸기" % GameState.format_money(price),
		"Pay %s and Switch" % GameState.format_money(price)), true)
	_device_confirm_button.custom_minimum_size = Vector2(0, 46)
	_device_confirm_button.pressed.connect(_confirm_device_purchase)
	_device_confirm_button.mouse_entered.connect(_device_confirm_button.grab_focus)
	_read_only_surface.add_child(_device_confirm_button)

func _confirm_device_purchase() -> void:
	if _pending_device_id.is_empty():
		return
	var result: Dictionary = PHONE_SYSTEM.purchase_device(_pending_device_id)
	if bool(result.get("ok", false)):
		var device: Dictionary = result.get("device", {})
		_device_feedback = LocaleManager.ui(
			"기기 변경 완료 · %s\n계좌 잔액 %s",
			"DEVICE CHANGED · %s\nAccount balance %s") % [
				_localized(device, "label"),
				GameState.format_money(float(result.get("balance_after", GameState.money))),
			]
	else:
		_device_feedback = _device_purchase_state_copy(result, false)
	_pending_device_id = ""
	_screen_mode = "app"
	_active_app_id = "device"
	_refresh_phone_material()
	_update_phone_geometry()
	if bool(SaveManager.get_setting(
			"reduce_motion", SaveManager.get_setting("reduced_motion", false))):
		_phone_frame_texture.modulate = Color.WHITE
	else:
		_phone_frame_texture.modulate = Color(1.0, 1.0, 1.0, 0.0)
		var shell_tween := create_tween()
		shell_tween.tween_property(
			_phone_frame_texture, "modulate:a", 1.0, 0.28
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_refresh_status_bar()
	_rebuild()
	var current_id := str(PHONE_SYSTEM.current_device().get("id", ""))
	var current_button: Button = _device_buttons.get(current_id)
	if is_instance_valid(current_button):
		current_button.call_deferred("grab_focus")

func _cycle_home_favorite() -> void:
	var candidates := PHONE_SYSTEM.favorite_app_candidates()
	if candidates.is_empty():
		return
	var current_id := PHONE_SYSTEM.favorite_app_id()
	var current_index := candidates.find(current_id)
	var next_id := str(candidates[posmod(current_index + 1, candidates.size())])
	var result := PHONE_SYSTEM.set_favorite_app(next_id)
	if bool(result.get("ok", false)):
		_device_feedback = LocaleManager.ui(
			"%s 앱을 홈 첫 칸에 고정했다.",
			"%s is pinned to the first home slot.") % _phone_app_label(next_id)
	else:
		_device_feedback = LocaleManager.ui(
			"지금은 이 앱을 고정할 수 없다.",
			"This app cannot be pinned right now.")
	_rebuild()
	if is_instance_valid(_favorite_cycle_button):
		_favorite_cycle_button.call_deferred("grab_focus")

func _phone_app_label(app_id: String) -> String:
	var meta := _app_meta(app_id)
	return str(meta.get(
		"label", LocaleManager.ui("선택 안 함", "Not set")))

func _build_investment_surface() -> void:
	_read_only_surface.add_child(_section_title(LocaleManager.ui(
		"시세와 보유 내역", "PRICES AND HOLDINGS")))
	var portfolio_value := 0.0
	var holding_lines: Array[String] = []
	for raw_asset_id in GameState.portfolio:
		var asset_id := str(raw_asset_id)
		var holding: Dictionary = GameState.portfolio.get(asset_id, {})
		var quantity := float(holding.get("quantity", 0.0))
		if quantity <= 0.0:
			continue
		var price := float(GameState.market_prices.get(
			asset_id, holding.get("avg_price", 0.0)))
		var value := quantity * price
		portfolio_value += value
		var asset: Dictionary = DataRegistry.get_asset(asset_id)
		holding_lines.append("%s · %s" % [
			str(asset.get("name", asset_id)),
			GameState.format_money(value),
		])
	if holding_lines.is_empty():
		holding_lines.append(LocaleManager.ui("보유 자산 없음", "No holdings"))
	var market_lines: Array[String] = []
	for raw_asset in DataRegistry.assets:
		if not raw_asset is Dictionary or market_lines.size() >= 3:
			continue
		var asset: Dictionary = raw_asset
		var asset_id := str(asset.get("id", ""))
		if asset_id.is_empty() or not GameState.market_prices.has(asset_id):
			continue
		market_lines.append("%s  %s" % [
			str(asset.get("name", asset_id)),
			GameState.format_money(float(GameState.market_prices[asset_id])),
		])
	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 8)
	_read_only_surface.add_child(grid)
	grid.add_child(_read_only_row(
		LocaleManager.ui("투자 가능 현금", "AVAILABLE CASH"),
		GameState.format_money(GameState.money), 94))
	grid.add_child(_read_only_row(
		LocaleManager.ui("보유 자산 현재가", "HOLDINGS VALUE"),
		GameState.format_money(portfolio_value), 94))
	grid.add_child(_read_only_row(
		LocaleManager.ui("보유 내역", "HOLDINGS"),
		"\n".join(holding_lines.slice(0, 3)), 104))
	grid.add_child(_read_only_row(
		LocaleManager.ui("현재 시세", "CURRENT PRICES"),
		"\n".join(market_lines) if not market_lines.is_empty() else LocaleManager.ui(
			"시세 없음", "No prices available"), 104))
	_read_only_surface.add_child(_read_only_row(
		LocaleManager.ui("집중 매매", "ACTIVE TRADING"),
		LocaleManager.ui(
			"한 주가 드는 집중 매매는 이번 달 일정에 넣는다.",
			"Trading that takes a week is scheduled in this month's calendar."),
		72))

func _build_leisure_surface() -> void:
	var places: Array[String] = []
	if bool(GameState.flags.get("racetrack_guide_met", false)) \
			or bool(GameState.flags.get("racetrack_visited", false)):
		places.append(LocaleManager.ui("경마장", "Racecourse"))
	if bool(GameState.flags.get("holdem_visited", false)):
		places.append(LocaleManager.ui("홀덤 클럽", "Hold'em club"))
	if bool(GameState.flags.get("casino_club_introduced", false)):
		places.append(LocaleManager.ui("카지노", "Casino"))
	_read_only_surface.add_child(_section_title(LocaleManager.ui(
		"직접 발견한 여가 장소", "LEISURE PLACES YOU DISCOVERED")))
	_read_only_surface.add_child(_read_only_row(
		LocaleManager.ui("발견한 장소", "DISCOVERED"),
		" · ".join(places) if not places.is_empty() else LocaleManager.ui(
			"아직 없음", "None yet"), 82))
	_read_only_surface.add_child(_read_only_row(
		LocaleManager.ui("방문", "VISITS"),
		LocaleManager.ui(
			"규칙을 확인하고, 직접 가려면 이번 달 일정에 방문을 넣는다.",
			"Review each place and its rules. To go there, schedule a visit in this month's calendar."),
		88))

func _build_games_surface() -> void:
	var current := PHONE_SYSTEM.current_device()
	_read_only_surface.add_child(_section_title(LocaleManager.ui(
		"기기에서 즐기는 선택형 게임", "OPTIONAL GAMES ON THIS DEVICE")))
	_read_only_surface.add_child(_read_only_row(
		_localized(current, "label"),
		LocaleManager.ui(
			"현재 이 기기에서 실행할 수 있는 게임이 없다.",
			"There are no games available on this device right now."),
		92))

func _rebuild_calendar() -> void:
	_calendar_heading_label.text = LocaleManager.ui(
		"%d월 일정" % _month_index, "MONTH %d CALENDAR" % _month_index)
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
		offer_button.set_meta("phone_compact", true)
		offer_button.custom_minimum_size = Vector2(0, 39)
		offer_button.add_theme_font_size_override("font_size", 13)
		offer_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		offer_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		offer_button.pressed.connect(_assign_offer.bind(bundle_id))
		offer_button.focus_entered.connect(_offer_focused.bind(bundle_id))
		offer_button.mouse_entered.connect(offer_button.grab_focus)
		_apply_calendar_offer_style(offer_button, false, false)
		_offer_list.add_child(offer_button)
		_offer_buttons[bundle_id] = offer_button

	var weeks: Array = _month_data.get("weeks", [1, 4])
	for week in range(int(weeks[0]), int(weeks[1]) + 1):
		var slot_button := _button("", false)
		slot_button.set_meta("phone_compact", true)
		slot_button.custom_minimum_size = Vector2(178, 67)
		slot_button.add_theme_font_size_override("font_size", 14)
		slot_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		slot_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		slot_button.pressed.connect(_select_week.bind(week))
		slot_button.focus_entered.connect(_week_focused.bind(week))
		slot_button.mouse_entered.connect(slot_button.grab_focus)
		_apply_calendar_day_style(slot_button, false, false, false)
		_slot_list.add_child(slot_button)
		_slot_buttons[str(week)] = slot_button
	_refresh_calendar()
	if not _read_only_plan and not available.is_empty():
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
		_apply_calendar_offer_style(
			button, bundle_id == _selected_offer_id, assigned)

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
		button.disabled = locked or _read_only_plan
		_apply_calendar_day_style(
			button, week == _selected_week, not bundle_id.is_empty(), locked)
	for raw_button in _offer_buttons.values():
		if raw_button is Button:
			(raw_button as Button).disabled = _read_only_plan

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

func _phone_surface_kind(offer: Dictionary) -> String:
	var phone_surface := str(offer.get("phone_surface", "")).strip_edges()
	if phone_surface in [
		"inbound_message", "call_log", "self_note", "world_encounter",
	]:
		return phone_surface
	# Missing or unknown data must never turn a self-authored plan into an
	# incoming message.
	return ""

func _received_phone_offer_ids() -> Array[String]:
	var result: Array[String] = []
	for bundle_id in CORE_LOOP.available_offer_ids(_month_index):
		var offer := CORE_LOOP.bundle(bundle_id)
		if _phone_surface_kind(offer) in ["inbound_message", "call_log"]:
			result.append(bundle_id)
	for bundle_id in CORE_LOOP.received_phone_consequence_ids(_month_index):
		if result.has(bundle_id):
			continue
		var consequence := CORE_LOOP.bundle(bundle_id)
		if _phone_surface_kind(consequence) \
				in ["inbound_message", "call_log"]:
			result.append(bundle_id)
	return result

func _optional_phone_copy(offer: Dictionary, stem: String) -> String:
	var suffix := "en" if LocaleManager.is_english() else "ko"
	return str(offer.get("%s_%s" % [stem, suffix], "")).strip_edges()

func _phone_message_sender(offer: Dictionary) -> String:
	var sender := _optional_phone_copy(offer, "message_sender")
	if not sender.is_empty():
		return sender
	return _localized(offer, "offer")

func _phone_message_body(offer: Dictionary) -> String:
	var body := _optional_phone_copy(offer, "message_body")
	if not body.is_empty():
		return body.replace(
			"{name}",
			LocaleManager.localize_player_name(str(GameState.player_name)))
	var detail := _localized(offer, "detail").strip_edges()
	var deadline := _localized(offer, "deadline").strip_edges()
	if deadline.is_empty():
		return detail
	return "%s · %s" % [detail, deadline]

func _build_messages_surface() -> void:
	var received_offer_ids := _received_phone_offer_ids()
	var decline_records := CORE_LOOP.decline_receipts_for_month(_month_index)
	_page_label.text = LocaleManager.ui(
		"받은 연락 %d · 기록 %d" % [
			received_offer_ids.size(), decline_records.size()],
		"%d RECEIVED · %d RECORDS" % [
			received_offer_ids.size(), decline_records.size()])
	_read_only_surface.add_child(_section_title(LocaleManager.ui(
		"받은 연락", "RECEIVED CONTACT")))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 5)
	_read_only_surface.add_child(grid)
	for bundle_id in received_offer_ids:
		var offer := CORE_LOOP.bundle(bundle_id)
		var phone_surface := _phone_surface_kind(offer)
		grid.add_child(_compact_message_row(
			_phone_message_sender(offer),
			_phone_message_body(offer),
			bundle_id,
			"offer:%s" % bundle_id,
			phone_surface))
	if received_offer_ids.is_empty():
		grid.add_child(_read_only_row(
			LocaleManager.ui("새로 받은 연락 없음", "NO NEW CONTACT"),
			LocaleManager.ui(
				"이번 달 일정은 메시지가 아닌 일정 앱에서 직접 고를 수 있다.",
				"Plans that are not messages remain available directly in Calendar."),
			58))

	if decline_records.is_empty():
		return
	_read_only_surface.add_child(_section_title(LocaleManager.ui(
		"지난달 기록", "SYSTEM RECORDS")))
	var record_grid := GridContainer.new()
	record_grid.columns = 2
	record_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	record_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	record_grid.add_theme_constant_override("h_separation", 8)
	record_grid.add_theme_constant_override("v_separation", 5)
	_read_only_surface.add_child(record_grid)
	for raw_record in decline_records:
		if not raw_record is Dictionary:
			continue
		var record: Dictionary = raw_record
		var producer: Dictionary = CORE_LOOP.bundle(
			str(record.get("producer_bundle", "")))
		var receipt_key: String = "receipt:%s" % str(record.get(
			"producer_bundle", record_grid.get_child_count()))
		var record_title := _localized(producer, "offer").strip_edges()
		if record_title.is_empty():
			record_title = LocaleManager.ui("지난달 일정 기록", "LAST MONTH'S RECORD")
		var record_body := str(record.get(
			"message_en" if LocaleManager.is_english() else "message_ko", "")
		).strip_edges()
		if record_body.is_empty():
			record_body = _localized(producer, "decline")
		record_grid.add_child(_compact_message_row(
			LocaleManager.ui("지난달에 잡지 않은 제안 · ", "NOT SCHEDULED LAST MONTH · ")
				+ record_title,
			record_body,
			"",
			receipt_key,
			"system_record"))

func _build_message_thread_surface() -> void:
	if _message_thread_kind == "system_record":
		_build_system_record_thread_surface()
		return
	if _message_thread_kind == "call_log":
		_app_title_label.text = LocaleManager.ui("통화 기록", "CALL LOG")
	var thread := VBoxContainer.new()
	thread.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	thread.add_theme_constant_override("separation", 10)
	_read_only_surface.add_child(thread)
	var sender_line := HBoxContainer.new()
	sender_line.add_theme_constant_override("separation", 9)
	thread.add_child(sender_line)
	var avatar := PanelContainer.new()
	avatar.custom_minimum_size = Vector2(42, 42)
	avatar.add_theme_stylebox_override(
		"panel", _rounded_panel_style(
			_message_avatar_color(_message_thread_title),
			Color("#ffffff", 0.18), 1, 21))
	sender_line.add_child(avatar)
	var avatar_mark := _label(
		_message_avatar_mark(_message_thread_title), 14, Color.WHITE, true)
	avatar_mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	avatar_mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	avatar.add_child(avatar_mark)
	var sender_copy := VBoxContainer.new()
	sender_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sender_line.add_child(sender_copy)
	sender_copy.add_child(_label(_message_thread_title, 15, COLOR_TEXT, true))
	sender_copy.add_child(_label(
		LocaleManager.ui("이번 달 통화 기록", "Call logged this month")
			if _message_thread_kind == "call_log"
			else LocaleManager.ui("이번 달 받은 메시지", "Received this month"),
		11, COLOR_DIM))

	var bubble_row := HBoxContainer.new()
	bubble_row.add_theme_constant_override("separation", 10)
	thread.add_child(bubble_row)
	var incoming_bubble := PanelContainer.new()
	incoming_bubble.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	incoming_bubble.size_flags_stretch_ratio = 0.70
	var bubble_background := Color("#18212b") \
		if _message_thread_kind == "call_log" else Color("#e9edf1")
	var bubble_border := Color("#465361") \
		if _message_thread_kind == "call_log" else Color("#ffffff")
	incoming_bubble.add_theme_stylebox_override(
		"panel", _rounded_panel_style(
			bubble_background, bubble_border, 1, 18))
	bubble_row.add_child(incoming_bubble)
	var bubble_margin := MarginContainer.new()
	bubble_margin.add_theme_constant_override("margin_left", 18)
	bubble_margin.add_theme_constant_override("margin_right", 18)
	bubble_margin.add_theme_constant_override("margin_top", 14)
	bubble_margin.add_theme_constant_override("margin_bottom", 14)
	incoming_bubble.add_child(bubble_margin)
	var message_copy := _label(
		_message_thread_body, 14,
		COLOR_TEXT if _message_thread_kind == "call_log" else Color("#20262d"))
	message_copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bubble_margin.add_child(message_copy)
	var bubble_space := Control.new()
	bubble_space.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bubble_space.size_flags_stretch_ratio = 0.30
	bubble_row.add_child(bubble_space)

	if not _message_thread_bundle_id.is_empty() \
			and CORE_LOOP.available_offer_ids(_month_index).has(
				_message_thread_bundle_id):
		var action_text := LocaleManager.ui(
			"일정에서 확인하기", "VIEW IN CALENDAR")
		if not _read_only_plan:
			action_text = LocaleManager.ui(
				"일정에 넣기", "ADD TO CALENDAR")
		var action := _button(action_text, true)
		action.custom_minimum_size = Vector2(260, 42)
		action.size_flags_horizontal = Control.SIZE_SHRINK_END
		_apply_contact_action_style(action)
		action.pressed.connect(
			_open_calendar_from_message.bind(_message_thread_bundle_id))
		action.mouse_entered.connect(action.grab_focus)
		thread.add_child(action)
		action.call_deferred("grab_focus")
	else:
		thread.add_child(_label(LocaleManager.ui(
			"이 연락은 지금 일정에 넣을 수 없다.",
			"This contact can no longer be scheduled."),
			12, COLOR_DIM))

func _build_system_record_thread_surface() -> void:
	_app_title_label.text = LocaleManager.ui("지난달 기록", "SYSTEM RECORDS")
	_page_label.text = LocaleManager.ui("일정 원장", "CALENDAR LEDGER")
	_read_only_surface.add_child(_section_title(LocaleManager.ui(
		"사람이 보낸 메시지가 아닌 지난 일정의 기록",
		"A RECORD FROM THE CALENDAR, NOT A MESSAGE")))
	_read_only_surface.add_child(_read_only_row(
		_message_thread_title, _message_thread_body, 110))
	_read_only_surface.add_child(_label(LocaleManager.ui(
		"지난달 일정에 넣지 않은 제안에서 남은 결과다. 답장할 상대는 없다.",
		"This was left by an offer not scheduled last month. There is no sender to reply to."),
		12, COLOR_DIM))

func _open_calendar_from_message(bundle_id: String) -> void:
	if not CORE_LOOP.available_offer_ids(_month_index).has(bundle_id):
		return
	_selected_offer_id = bundle_id
	_active_tab = 1
	_screen_mode = "app"
	_active_app_id = "calendar"
	_rebuild()
	var offer_button: Button = _offer_buttons.get(bundle_id)
	if is_instance_valid(offer_button):
		offer_button.call_deferred("grab_focus")

func _build_people_surface() -> void:
	_read_only_surface.add_child(_section_title(LocaleManager.ui(
		"만난 사람과 연락수단", "PEOPLE MET AND WAYS TO REACH THEM")))
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
		_read_only_surface.add_child(_contact_row(character_id))

func _contact_row(character_id: String) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 104)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override(
		"panel", _panel_style(COLOR_PANEL, COLOR_BORDER, 1))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)
	var avatar := PanelContainer.new()
	avatar.custom_minimum_size = Vector2(52, 52)
	avatar.add_theme_stylebox_override(
		"panel", _rounded_panel_style(
			_message_avatar_color(character_id), Color("#ffffff", 0.20), 1, 26))
	row.add_child(avatar)
	var avatar_mark := _label(
		_character_avatar_mark(character_id), 18, Color.WHITE, true)
	avatar_mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	avatar_mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	avatar.add_child(avatar_mark)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_theme_constant_override("separation", 3)
	row.add_child(copy)
	copy.add_child(_label(_character_name(character_id), 15, COLOR_TEXT, true))
	var history := _label(_relationship_copy(character_id), 13, COLOR_DIM)
	history.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	history.max_lines_visible = 2
	history.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	copy.add_child(history)

	var channel := _contact_method(character_id)
	var topic_bundle := _contact_topic_bundle(character_id)
	var can_schedule := (
		not topic_bundle.is_empty()
		and _contact_method_allows_bundle(
			character_id, channel, topic_bundle)
	)
	var controls := VBoxContainer.new()
	controls.custom_minimum_size = Vector2(270, 0)
	controls.add_theme_constant_override("separation", 4)
	row.add_child(controls)
	var channel_label := _label(
		_contact_method_copy(character_id, channel), 12, COLOR_DIM, true)
	channel_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	channel_label.max_lines_visible = 2
	channel_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	controls.add_child(channel_label)
	if can_schedule and _read_only_plan:
		var scheduled := _schedule.values().has(topic_bundle)
		var topic := CORE_LOOP.bundle(topic_bundle)
		var confirmed_copy := LocaleManager.ui(
			"확정 일정에 있음 · %s",
			"IN CONFIRMED CALENDAR · %s") % _localized(topic, "offer") \
			if scheduled else LocaleManager.ui(
				"이번 달에는 일정에 넣지 않음 · %s",
				"NOT SCHEDULED THIS MONTH · %s") % _localized(topic, "offer")
		var confirmed_state := _label(
			confirmed_copy, 11, COLOR_DIM)
		confirmed_state.custom_minimum_size = Vector2(270, 28)
		confirmed_state.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		confirmed_state.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		controls.add_child(confirmed_state)
	elif can_schedule:
		var topic := CORE_LOOP.bundle(topic_bundle)
		var action_label := _contact_action_copy(
			character_id, channel, topic_bundle)
		var contact_button := _button(
			"%s\n%s" % [action_label, _localized(topic, "offer")], false)
		contact_button.set_meta("phone_compact", true)
		contact_button.custom_minimum_size = Vector2(270, 44)
		contact_button.add_theme_font_size_override("font_size", 12)
		contact_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		contact_button.pressed.connect(_focus_contact_offer.bind(topic_bundle))
		contact_button.mouse_entered.connect(contact_button.grab_focus)
		_apply_contact_action_style(contact_button)
		controls.add_child(contact_button)
	return panel

func _character_avatar_mark(character_id: String) -> String:
	if character_id == "daeun" and not _daeun_name_known():
		return LocaleManager.ui("편", "C")
	if character_id == "jiyeon" and not _jiyeon_name_known():
		return LocaleManager.ui("차", "D")
	return _character_name(character_id).left(1).to_upper()

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
			# The crash and bus-stop scenes do not exchange a number or create
			# a message thread.
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

func _contact_number_known(character_id: String) -> bool:
	return _contact_method(character_id) in [
		"phone", "kakao", "business_card",
	]

func _contact_method_allows_bundle(
		character_id: String, method: String, bundle_id: String) -> bool:
	if character_id == "daeun" and bundle_id in [
		"daeun_player_return", "daeun_return_after_distance",
		"daeun_shared_dream", "daeun_third_greeting",
	]:
		return method == "known_place"
	return method in ["phone", "kakao", "business_card"]

func _contact_action_copy(
		character_id: String, method: String, bundle_id: String) -> String:
	if character_id == "daeun" and bundle_id in [
		"daeun_player_return", "daeun_return_after_distance",
		"daeun_shared_dream", "daeun_third_greeting",
	]:
		return LocaleManager.ui(
			"직접 찾아갈 시간 잡기",
			"MAKE TIME TO VISIT IN PERSON")
	if bundle_id == "hyunsu_player_reachout":
		return LocaleManager.ui(
			"먼저 연락할 시간 잡기",
			"MAKE TIME TO REACH OUT")
	if bundle_id == "father_first_call":
		return LocaleManager.ui(
			"이번 달 통화로 잡기",
			"MAKE TIME FOR THIS CALL")
	if method == "kakao":
		return LocaleManager.ui(
			"카카오톡으로 연락할 시간 잡기",
			"MAKE TIME TO MESSAGE")
	if method == "business_card":
		return LocaleManager.ui(
			"명함의 번호로 연락할 시간 잡기",
			"MAKE TIME TO USE THE CARD")
	return LocaleManager.ui(
		"전화할 시간 잡기",
		"SCHEDULE TIME TO CALL")

func _contact_topic_bundle(character_id: String) -> String:
	var candidates: Array[String] = []
	match character_id:
		"father":
			candidates = ["father_first_call", "father_quiet_call"]
		"hyunsu":
			candidates = ["hyunsu_player_reachout"]
		"daeun":
			candidates = [
				"daeun_player_return",
				"daeun_return_after_distance",
				"daeun_shared_dream",
				"daeun_third_greeting",
			]
		"sangchul":
			candidates = ["sangchul_second_coffee"]
		"jaehyuk":
			candidates = ["jaehyuk_plain_reunion_echo"]
	var available := CORE_LOOP.available_offer_ids(_month_index)
	for bundle_id in candidates:
		if available.has(bundle_id):
			return bundle_id
	return ""

func _focus_contact_offer(bundle_id: String) -> void:
	if not CORE_LOOP.available_offer_ids(_month_index).has(bundle_id):
		return
	_selected_offer_id = bundle_id
	_active_tab = 1
	_screen_mode = "app"
	_active_app_id = "calendar"
	_rebuild()
	var button: Button = _offer_buttons.get(bundle_id)
	if is_instance_valid(button):
		button.call_deferred("grab_focus")

func _build_record_surface() -> void:
	var section_heading := LocaleManager.ui(
		"확정한 이번 달 계획", "CONFIRMED MONTH PLAN") \
		if _read_only_plan else (
			LocaleManager.ui("계획 확인", "REVIEW PLAN")
			if _review_pending
			else LocaleManager.ui("이번 달 계획", "THIS MONTH'S PLAN")
		)
	_read_only_surface.add_child(_section_title(section_heading))
	_build_routine_surface()
	var scheduled_lines := _scheduled_commitment_lines()
	_read_only_surface.add_child(_read_only_row(
		LocaleManager.ui("네 주에 할 일", "WHAT YOU WILL DO"),
		"\n".join(scheduled_lines),
		118))
	var unchosen_lines := _unchosen_offer_lines()
	_read_only_surface.add_child(_read_only_row(
		LocaleManager.ui("이번 달에 잡지 않은 제안", "NOT SCHEDULED THIS MONTH"),
		"\n".join(unchosen_lines),
		104))

func _build_routine_surface() -> void:
	_routine_buttons.clear()
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 142)
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
			button.set_meta("phone_compact", true)
			button.tooltip_text = _localized(option, "description")
			button.custom_minimum_size = Vector2(0, 36)
			button.add_theme_font_size_override("font_size", 13)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.disabled = (
				_read_only_plan
				or (
					slot == "primary"
					and not GameState.current_job.is_empty()
					and str(routine_id) != "livelihood"
				)
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
	var detail := RichTextLabel.new()
	detail.text = "  ·  ".join(selected_details)
	detail.fit_content = false
	detail.scroll_active = false
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.custom_minimum_size = Vector2(0, 22)
	detail.add_theme_font_size_override("normal_font_size", 12)
	detail.add_theme_color_override("default_color", COLOR_DIM)
	if _font:
		detail.add_theme_font_override("normal_font", _font)
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
	var body_label := RichTextLabel.new()
	body_label.text = body
	body_label.fit_content = false
	body_label.scroll_active = false
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.custom_minimum_size = Vector2(
		0, maxf(24.0, minimum_height - 52.0))
	body_label.add_theme_font_size_override("normal_font_size", 14)
	body_label.add_theme_color_override("default_color", COLOR_DIM)
	if _font:
		body_label.add_theme_font_override("normal_font", _font)
	box.add_child(body_label)
	return panel

func _compact_message_row(
		title: String, body: String, bundle_id: String,
		thread_key: String, thread_kind: String) -> Button:
	var is_system_record := thread_kind == "system_record"
	var is_call_log := thread_kind == "call_log"
	var panel := Button.new()
	panel.text = ""
	panel.set_meta("phone_thread_kind", thread_kind)
	panel.focus_mode = Control.FOCUS_ALL
	panel.custom_minimum_size = Vector2(0, 58)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var normal := _rounded_panel_style(
		Color("#12151a", 0.90) if is_system_record else Color("#0b1017", 0.82),
		Color("#68717c", 0.32) if is_system_record else Color("#ffffff", 0.10),
		1, 8 if is_system_record else 14)
	var hover := _rounded_panel_style(
		Color("#1d2229", 0.96) if is_system_record else Color("#17212c", 0.96),
		Color("#8d98a5", 0.48) if is_system_record else Color("#ffffff", 0.25),
		1, 8 if is_system_record else 14)
	var focused := _rounded_panel_style(
		Color("#222831", 0.98) if is_system_record else Color("#17212c", 0.98),
		COLOR_ACCENT, 2, 8 if is_system_record else 14)
	for style in [normal, hover, focused]:
		style.content_margin_left = 0
		style.content_margin_right = 0
		style.content_margin_top = 0
		style.content_margin_bottom = 0
	panel.add_theme_stylebox_override("normal", normal)
	panel.add_theme_stylebox_override("hover", hover)
	panel.add_theme_stylebox_override("focus", focused)
	panel.add_theme_stylebox_override("pressed", focused)
	panel.pressed.connect(
		_open_message_thread.bind(
			title, body, bundle_id, thread_key, thread_kind))
	panel.mouse_entered.connect(panel.grab_focus)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_bottom", 5)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(row)
	var avatar := PanelContainer.new()
	avatar.custom_minimum_size = Vector2(38, 38)
	avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar.add_theme_stylebox_override(
		"panel", _rounded_panel_style(
			Color("#343b44") if is_system_record
				else _message_avatar_color(title),
			Color("#7b8794") if is_system_record else Color("#ffffff", 0.22),
			1, 7 if is_system_record else 19))
	row.add_child(avatar)
	var avatar_label := _label(
		LocaleManager.ui("기록", "LOG") if is_system_record
			else _message_avatar_mark(title),
		9 if is_system_record else 13, Color.WHITE, true)
	avatar_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	avatar_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	avatar_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar.add_child(avatar_label)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 2)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(box)
	var title_label := _label(title, 12, COLOR_TEXT, true)
	title_label.max_lines_visible = 1
	title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(title_label)
	var bubble := PanelContainer.new()
	bubble.custom_minimum_size = Vector2(0, 25)
	bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bubble.add_theme_stylebox_override(
		"panel", _rounded_panel_style(
			Color("#242a32") if is_system_record \
				else Color("#18212b") if is_call_log else Color("#e7eaee"),
			Color("#59636f") if is_system_record \
				else Color("#465361") if is_call_log else Color("#ffffff"),
			1, 5 if is_system_record or is_call_log else 11))
	box.add_child(bubble)
	var body_label := _label(
		body, 11,
		COLOR_DIM if is_system_record \
			else COLOR_TEXT if is_call_log else Color("#252a31"))
	body_label.max_lines_visible = 1
	body_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	body_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bubble.add_child(body_label)
	return panel

func _open_message_thread(
		title: String, body: String, bundle_id: String,
		thread_key: String, thread_kind: String) -> void:
	_message_thread_title = title
	_message_thread_body = body
	_message_thread_bundle_id = bundle_id
	_message_thread_key = thread_key
	_message_thread_kind = thread_kind
	_screen_mode = "message_thread"
	_active_app_id = "messages"
	_rebuild()
	_app_scroll.scroll_vertical = 0
	_play_app_surface_reveal(_app_surface)

func _message_avatar_mark(title: String) -> String:
	var trimmed := title.strip_edges()
	if trimmed.is_empty():
		return "?"
	if trimmed.begins_with(LocaleManager.ui(
			"지난달에 잡지 않은 제안", "NOT SCHEDULED LAST MONTH")):
		return "!"
	return trimmed.left(1).to_upper()

func _message_avatar_color(title: String) -> Color:
	var seed: int = absi(title.hash())
	var colors: Array[Color] = [
		Color("#337f73"), Color("#416ba0"), Color("#8b5d83"),
		Color("#9a633d"), Color("#586a8c"),
	]
	return colors[seed % colors.size()]

func _assign_offer(bundle_id: String) -> void:
	if _read_only_plan:
		return
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
	if _read_only_plan:
		return
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
	_screen_mode = "app"
	_active_app_id = "calendar" if target in [1, 3] else str(LEGACY_APP_IDS[target])
	_pending_device_id = ""
	_rebuild()

func _cycle_tab(delta: int) -> void:
	if _screen_mode != "app" or _active_app_id != "calendar":
		return
	_switch_tab(3 if _active_tab == 1 else 1)
	_focus_current_surface()

func _focus_current_surface() -> void:
	if _active_tab == 1:
		var selected_slot: Button = _slot_buttons.get(str(_selected_week))
		if is_instance_valid(selected_slot) and not selected_slot.disabled:
			selected_slot.call_deferred("grab_focus")
			return
		if not _offer_buttons.is_empty():
			var first_offer: Button = _offer_buttons.values()[0]
			if is_instance_valid(first_offer):
				first_offer.call_deferred("grab_focus")
				return
	if _active_tab == 3 and is_instance_valid(_confirm_button) \
			and _confirm_button.visible and not _confirm_button.disabled:
		_confirm_button.call_deferred("grab_focus")
		return
	var focusables := find_children("*", "Button", true, false)
	for candidate in focusables:
		if candidate is Button and (candidate as Button).visible \
				and not (candidate as Button).disabled:
			(candidate as Button).call_deferred("grab_focus")
			return

func _go_back_one_level() -> void:
	if _screen_mode == "message_thread":
		_screen_mode = "app"
		_active_app_id = "messages"
		_rebuild()
		return
	if _screen_mode == "device_confirm":
		_pending_device_id = ""
		_screen_mode = "app"
		_active_app_id = "device"
		_rebuild()
		var current_button: Button = _device_buttons.get(
			str(PHONE_SYSTEM.current_device().get("id", "")))
		if is_instance_valid(current_button):
			current_button.call_deferred("grab_focus")
		return
	if _review_pending:
		_cancel_commit_review()
		return
	if _screen_mode == "app":
		_show_home()
		return
	if not CORE_LOOP.plan_for_month(_month_index).is_empty():
		close()
		return
	_hint_label.text = LocaleManager.ui(
		"이번 달 네 주를 확정하기 전에는 휴대폰을 내려놓을 수 없다.",
		"Finish the four-week plan before putting the phone away.")
	if not _app_buttons.is_empty():
		var calendar_button: Button = _app_buttons.get("calendar")
		if is_instance_valid(calendar_button):
			calendar_button.call_deferred("grab_focus")

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
				_go_back_one_level()
				handled = true
			JOY_BUTTON_X:
				if _screen_mode == "app" and _active_app_id == "calendar" \
						and _active_tab == 1:
					handled = unassign_week(_selected_week)
			JOY_BUTTON_LEFT_SHOULDER:
				if _screen_mode == "app" and _active_app_id == "calendar":
					_cycle_tab(-1)
					handled = true
			JOY_BUTTON_RIGHT_SHOULDER:
				if _screen_mode == "app" and _active_app_id == "calendar":
					_cycle_tab(1)
					handled = true
	if not handled and ControllerHints.secondary_pressed(event):
		if _screen_mode == "app" and _active_app_id == "calendar" \
				and _active_tab == 1:
			handled = unassign_week(_selected_week)
	elif not handled and event.is_action_pressed("gd_tab_prev"):
		if _screen_mode == "app" and _active_app_id == "calendar":
			_cycle_tab(-1)
			handled = true
	elif not handled and event.is_action_pressed("gd_tab_next"):
		if _screen_mode == "app" and _active_app_id == "calendar":
			_cycle_tab(1)
			handled = true
	elif not handled and _screen_mode != "home" \
			and event.is_action_pressed("ui_down"):
		handled = _scroll_phone_body(72)
	elif not handled and _screen_mode != "home" \
			and event.is_action_pressed("ui_up"):
		handled = _scroll_phone_body(-72)
	elif not handled and event.is_action_pressed("ui_cancel"):
		_go_back_one_level()
		handled = true
	if handled:
		get_viewport().set_input_as_handled()

func _scroll_phone_body(delta: int) -> bool:
	if not is_instance_valid(_app_scroll) or not _app_scroll.visible:
		return false
	var bar := _app_scroll.get_v_scroll_bar()
	if not is_instance_valid(bar) or bar.max_value <= bar.page + 0.5:
		return false
	var before := _app_scroll.scroll_vertical
	_app_scroll.scroll_vertical = clampi(
		before + delta, 0, maxi(0, int(bar.max_value - bar.page)))
	return _app_scroll.scroll_vertical != before

func _refresh_footer() -> void:
	if not is_instance_valid(_confirm_button):
		return
	_confirm_button.visible = false
	if _screen_mode == "home":
		_hint_label.text = LocaleManager.ui(
			"방향키 앱 이동 · %s 열기 · %s 뒤로" % [
				ControllerHints.south(), ControllerHints.east()],
			"D-pad Move · %s Open · %s Back" % [
				ControllerHints.south(), ControllerHints.east()])
		return
	if _screen_mode == "device_confirm":
		_hint_label.text = LocaleManager.ui(
			"%s 구매 확정 · %s 기기 화면으로" % [
				ControllerHints.south(), ControllerHints.east()],
			"%s Confirm Purchase · %s Back to Device" % [
				ControllerHints.south(), ControllerHints.east()])
		return
	if _active_app_id != "calendar":
		_hint_label.text = LocaleManager.ui(
			"방향키 이동 · %s 선택 · %s 홈" % [
				ControllerHints.south(),
				ControllerHints.east(),
			],
			"D-pad Move · %s Select · %s Home" % [
				ControllerHints.south(),
				ControllerHints.east(),
			])
		return
	if _read_only_plan:
		_confirm_button.visible = false
		_status_label.text = LocaleManager.ui(
			"이번 달 계획은 이미 확정됐다. 일정과 매주 할 일은 조회만 할 수 있다.",
			"This month's plan is confirmed. The schedule and weekly routines are view only.")
		_hint_label.text = LocaleManager.ui(
			"방향키 이동 · %s 홈 · %s/%s 계획/정리" % [
				ControllerHints.east(),
				ControllerHints.shoulder_l(),
				ControllerHints.shoulder_r(),
			],
			"D-pad Navigate · %s Home · %s/%s Plan/Summary" % [
				ControllerHints.east(),
				ControllerHints.shoulder_l(),
				ControllerHints.shoulder_r(),
			])
		return
	_confirm_button.visible = true
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
		"네 주를 모두 정하면, 남은 제안 {count}개는 이번 달 일정에 잡지 않는다.",
		"Fill all four weeks. {count} other offers will remain off this month's calendar."
	).format({"count": missed_count})
	_hint_label.text = LocaleManager.ui(
		"방향키 이동 · %s 배치 · %s 일정에서 빼기 · %s 홈 · %s/%s 계획/정리" % [
			ControllerHints.south(),
			ControllerHints.west(),
			ControllerHints.east(),
			ControllerHints.shoulder_l(),
			ControllerHints.shoulder_r(),
		],
		"D-pad Navigate · %s Schedule · %s Remove · %s Home · %s/%s Plan/Summary" % [
			ControllerHints.south(),
			ControllerHints.west(),
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
	if _read_only_plan:
		return
	_review_pending = true
	_active_tab = 3
	_screen_mode = "app"
	_active_app_id = "calendar"
	_rebuild()
	_confirm_button.call_deferred("grab_focus")

func _cancel_commit_review() -> void:
	_review_pending = false
	_active_tab = 1
	_screen_mode = "app"
	_active_app_id = "calendar"
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
		var fixed := LocaleManager.ui(" · 고정 일정", " · FIXED EVENT") \
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
			"이번 달에 잡지 않은 제안 없음",
			"No offers left unscheduled this month"))
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

func _label(text: String, size: int, color: Color, bold: bool = false) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	var target_font := _font_bold if bold else _font
	if target_font:
		label.add_theme_font_override("font", target_font)
	return label

func _phone_nav_button(glyph: String) -> Button:
	var button := Button.new()
	button.text = glyph
	button.focus_mode = Control.FOCUS_ALL
	button.custom_minimum_size = Vector2(34, 34)
	button.add_theme_font_size_override("font_size", 22)
	if _font_bold:
		button.add_theme_font_override("font", _font_bold)
	button.add_theme_stylebox_override(
		"normal", _rounded_panel_style(
			Color("#ffffff", 0.05), Color("#ffffff", 0.10), 1, 17))
	button.add_theme_stylebox_override(
		"hover", _rounded_panel_style(
			Color("#ffffff", 0.11), Color("#ffffff", 0.22), 1, 17))
	button.add_theme_stylebox_override(
		"focus", _rounded_panel_style(
			Color("#ffffff", 0.12), COLOR_ACCENT, 2, 17))
	button.add_theme_stylebox_override(
		"pressed", _rounded_panel_style(
			Color("#ffffff", 0.18), COLOR_ACCENT, 2, 17))
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_focus_color", Color.WHITE)
	return button

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
	if bool(button.get_meta("phone_compact", false)):
		for style in [normal, hover, pressed, disabled]:
			style.content_margin_left = 9
			style.content_margin_right = 9
			style.content_margin_top = 3
			style.content_margin_bottom = 3
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", pressed)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", COLOR_TEXT)
	button.add_theme_color_override("font_focus_color", COLOR_TEXT)
	button.add_theme_color_override("font_disabled_color", Color("#aeb5be"))

func _apply_calendar_offer_style(
		button: Button, selected: bool, scheduled: bool) -> void:
	if not is_instance_valid(button):
		return
	var bg := Color("#25303d", 0.94) if scheduled else Color("#151c25", 0.88)
	var border := COLOR_ACCENT if selected else Color("#ffffff", 0.08)
	var normal := _rounded_panel_style(bg, border, 2 if selected else 1, 11)
	var hover := _rounded_panel_style(
		bg.lightened(0.08), Color("#ffffff", 0.24), 1, 11)
	var focused := _rounded_panel_style(
		bg.lightened(0.08), COLOR_ACCENT, 2, 11)
	var disabled := _rounded_panel_style(
		Color("#10151c", 0.90), Color("#ffffff", 0.05), 1, 11)
	for style in [normal, hover, focused, disabled]:
		style.content_margin_left = 10
		style.content_margin_right = 9
		style.content_margin_top = 3
		style.content_margin_bottom = 3
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", focused)
	button.add_theme_stylebox_override("pressed", focused)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_focus_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color("#8f98a4"))

func _apply_calendar_day_style(
		button: Button, selected: bool, filled: bool, locked: bool) -> void:
	if not is_instance_valid(button):
		return
	var bg := Color("#243345", 0.97) if filled else Color("#0f151d", 0.94)
	if locked:
		bg = Color("#382f26", 0.96)
	var border := COLOR_ACCENT if selected else Color("#ffffff", 0.13)
	var normal := _rounded_panel_style(bg, border, 2 if selected else 1, 13)
	var hover := _rounded_panel_style(
		bg.lightened(0.08), Color("#ffffff", 0.28), 1, 13)
	var focused := _rounded_panel_style(
		bg.lightened(0.10), COLOR_ACCENT, 2, 13)
	var disabled := _rounded_panel_style(
		bg.darkened(0.08), Color("#ffffff", 0.08), 1, 13)
	for style in [normal, hover, focused, disabled]:
		style.content_margin_left = 10
		style.content_margin_right = 10
		style.content_margin_top = 7
		style.content_margin_bottom = 7
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", focused)
	button.add_theme_stylebox_override("pressed", focused)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_focus_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color("#bac0c8"))

func _apply_contact_action_style(button: Button) -> void:
	var normal := _rounded_panel_style(
		Color("#23775e"), Color("#74c7a8"), 1, 18)
	var hover := _rounded_panel_style(
		Color("#2c8e70"), Color("#b1ead4"), 1, 18)
	var focused := _rounded_panel_style(
		Color("#2c8e70"), Color.WHITE, 2, 18)
	for style in [normal, hover, focused]:
		style.content_margin_left = 14
		style.content_margin_right = 14
		style.content_margin_top = 5
		style.content_margin_bottom = 5
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", focused)
	button.add_theme_stylebox_override("pressed", focused)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_focus_color", Color.WHITE)

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

func _phone_screen_mat_style(radius: int) -> StyleBoxFlat:
	var style := _rounded_panel_style(
		Color("#020304"), Color("#11161a"), 1, radius)
	style.content_margin_left = 0
	style.content_margin_top = 0
	style.content_margin_right = 0
	style.content_margin_bottom = 0
	return style

func _rounded_panel_style(
		bg: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := _panel_style(bg, border, width)
	style.set_corner_radius_all(radius)
	return style

func _on_language_changed(_language: String) -> void:
	if visible:
		_rebuild()

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		if child is CanvasItem:
			(child as CanvasItem).visible = false
		child.queue_free()
