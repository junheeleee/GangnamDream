extends Control
## ORDER-76: communication-only portrait phone drawer.
##
## This surface deliberately owns no calendar, finance, device, reward, or
## save state. It reads authored contact history and emits an existing monthly
## offer id so the wide planner can decide what to do with it.

signal closed
signal offer_requested(bundle_id: String)

const CORE_LOOP := preload("res://systems/DemoCoreLoopV2.gd")
const FLAGSHIP_FRAME := preload(
	"res://assets/ui/phone/phone_frame_flagship.png")

const COLOR_SCREEN := Color("#0b1017")
const COLOR_PANEL := Color("#121923", 0.98)
const COLOR_PANEL_ALT := Color("#182230", 0.98)
const COLOR_BORDER := Color("#4f5d6c")
const COLOR_TEXT := Color("#edf1f5")
const COLOR_DIM := Color("#9aa5b2")
const COLOR_ACCENT := Color("#d8c38d")
const COLOR_MESSAGE := Color("#e8edf2")
const COLOR_CALL := Color("#253449")

const DRAWER_WIDE := 392.0
const DRAWER_COMPACT := 320.0
const DRAWER_EDGE := 16.0
const DRAWER_VERTICAL_WIDE := 24.0
const DRAWER_VERTICAL_COMPACT := 16.0
const FLAGSHIP_LANDSCAPE_SIZE := Vector2(1512.0, 720.0)
const FLAGSHIP_PORTRAIT_ASPECT := (
	FLAGSHIP_LANDSCAPE_SIZE.y / FLAGSHIP_LANDSCAPE_SIZE.x)
const ACTUAL_CONTACT_METHODS := ["phone", "kakao", "business_card"]

var _month_index := 1
var _active_tab := 0
var _screen_mode := "list"
var _thread_title := ""
var _thread_body := ""
var _thread_bundle_id := ""
var _thread_kind := ""
var _return_focus_key := ""

var _font: FontFile
var _font_bold: FontFile
var _shade: ColorRect
var _drawer: Control
var _phone_holder: Control
var _display_panel: PanelContainer
var _frame_texture: TextureRect
var _content_margin: MarginContainer
var _header_title: Label
var _back_button: Button
var _close_button: Button
var _tab_buttons: Array[Button] = []
var _body_scroll: ScrollContainer
var _body: VBoxContainer
var _footer_hint: Label
var _open_tween: Tween
var _drawer_rest_position := Vector2.ZERO


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 110
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS
	_font = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile
	_build_ui()
	resized.connect(_update_geometry)
	LocaleManager.language_changed.connect(_on_language_changed)
	visible = false


func open(month_index: int) -> bool:
	if CORE_LOOP.month_spec(month_index).is_empty():
		return false
	_month_index = month_index
	_active_tab = clampi(_active_tab, 0, 1)
	_screen_mode = "list"
	_clear_thread()
	visible = true
	move_to_front()
	_update_geometry()
	_rebuild()
	_play_open_reveal()
	call_deferred("_focus_after_rebuild")
	return true


func close() -> void:
	if not visible:
		return
	if is_instance_valid(_open_tween):
		_open_tween.kill()
	var focused := get_viewport().gui_get_focus_owner()
	if focused is Control and is_ancestor_of(focused):
		(focused as Control).release_focus()
	visible = false
	closed.emit()


func is_open() -> bool:
	return visible


func _build_ui() -> void:
	_shade = ColorRect.new()
	_shade.name = "CommunicationPhoneModalShade"
	_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shade.color = Color("#030609", 0.56)
	_shade.mouse_filter = Control.MOUSE_FILTER_STOP
	_shade.gui_input.connect(_on_shade_gui_input)
	add_child(_shade)

	_drawer = Control.new()
	_drawer.name = "PortraitCommunicationDrawer"
	_drawer.set_meta("communication_phone_drawer", true)
	_drawer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_drawer)

	_phone_holder = Control.new()
	_phone_holder.name = "RotatedFlagshipHolder"
	_phone_holder.set_meta("phone_orientation", "portrait")
	_phone_holder.clip_contents = false
	_phone_holder.mouse_filter = Control.MOUSE_FILTER_STOP
	_drawer.add_child(_phone_holder)

	_display_panel = PanelContainer.new()
	_display_panel.name = "FlagshipDisplayOpening"
	_display_panel.set_meta("communication_phone_display", true)
	_display_panel.clip_contents = true
	_display_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_display_panel.add_theme_stylebox_override(
		"panel", _rounded_style(COLOR_SCREEN, Color("#3a4653"), 1, 28))
	_phone_holder.add_child(_display_panel)

	var wallpaper := TextureRect.new()
	wallpaper.name = "CommunicationWallpaper"
	wallpaper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wallpaper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	wallpaper.stretch_mode = TextureRect.STRETCH_SCALE
	wallpaper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.52, 1.0])
	gradient.colors = PackedColorArray([
		Color("#1a2636"), Color("#101823"), Color("#080c12")])
	var gradient_texture := GradientTexture2D.new()
	gradient_texture.width = 512
	gradient_texture.height = 1024
	gradient_texture.fill_from = Vector2(0.0, 0.0)
	gradient_texture.fill_to = Vector2(1.0, 1.0)
	gradient_texture.gradient = gradient
	wallpaper.texture = gradient_texture
	_display_panel.add_child(wallpaper)

	_content_margin = MarginContainer.new()
	_content_margin.name = "CommunicationSafeArea"
	_content_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_content_margin.mouse_filter = Control.MOUSE_FILTER_PASS
	_display_panel.add_child(_content_margin)

	var page := VBoxContainer.new()
	page.name = "CommunicationPhonePage"
	page.add_theme_constant_override("separation", 5)
	_content_margin.add_child(page)

	var status := HBoxContainer.new()
	status.custom_minimum_size = Vector2(0, 20)
	status.add_theme_constant_override("separation", 8)
	page.add_child(status)
	var network := _label("LTE", 10, COLOR_DIM, true)
	network.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status.add_child(network)
	var privacy := _label("78%", 10, COLOR_DIM, true)
	privacy.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status.add_child(privacy)

	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 42)
	header.add_theme_constant_override("separation", 5)
	page.add_child(header)
	_back_button = _icon_button("‹", "back")
	_back_button.visible = false
	_back_button.pressed.connect(_go_back_one_level)
	header.add_child(_back_button)
	_header_title = _label(
		LocaleManager.ui("연락", "CONTACTS"), 17, COLOR_TEXT, true)
	_header_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_header_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_header_title.max_lines_visible = 1
	_header_title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	header.add_child(_header_title)
	_close_button = _icon_button("×", "close")
	_close_button.pressed.connect(close)
	header.add_child(_close_button)

	var tabs := HBoxContainer.new()
	tabs.custom_minimum_size = Vector2(0, 44)
	tabs.add_theme_constant_override("separation", 5)
	page.add_child(tabs)
	for index in range(2):
		var tab := Button.new()
		tab.name = "ConversationTab" if index == 0 else "ContactsTab"
		tab.focus_mode = Control.FOCUS_ALL
		tab.custom_minimum_size = Vector2(0, 42)
		tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		tab.pressed.connect(_switch_tab.bind(index))
		tab.mouse_entered.connect(tab.grab_focus)
		tabs.add_child(tab)
		_tab_buttons.append(tab)

	var divider := HSeparator.new()
	divider.add_theme_color_override("color", Color("#ffffff", 0.10))
	page.add_child(divider)

	_body_scroll = ScrollContainer.new()
	_body_scroll.name = "CommunicationBodyScroll"
	_body_scroll.set_meta("communication_phone_scroll", true)
	_body_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_body_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_body_scroll.follow_focus = true
	page.add_child(_body_scroll)

	_body = VBoxContainer.new()
	_body.name = "CommunicationBody"
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_body.add_theme_constant_override("separation", 7)
	_body_scroll.add_child(_body)

	_footer_hint = _label("", 11, COLOR_DIM)
	_footer_hint.name = "CommunicationInputHint"
	_footer_hint.custom_minimum_size = Vector2(0, 27)
	_footer_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_footer_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_footer_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_footer_hint.max_lines_visible = 2
	page.add_child(_footer_hint)

	_frame_texture = TextureRect.new()
	_frame_texture.name = "RotatedFlagshipPhysicalFrame"
	_frame_texture.set_meta("source_rotation_degrees", 90.0)
	_frame_texture.texture = FLAGSHIP_FRAME
	_frame_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_frame_texture.stretch_mode = TextureRect.STRETCH_SCALE
	_frame_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame_texture.z_index = 20
	_phone_holder.add_child(_frame_texture)


func _update_geometry() -> void:
	if not is_instance_valid(_drawer):
		return
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var drawer_width := _drawer_width_for(viewport_size.x)
	var vertical_edge := DRAWER_VERTICAL_COMPACT \
		if viewport_size.x <= 960.5 or viewport_size.y <= 640.0 \
		else DRAWER_VERTICAL_WIDE
	_drawer.position = Vector2(
		viewport_size.x - drawer_width - DRAWER_EDGE, vertical_edge)
	_drawer_rest_position = _drawer.position
	_drawer.size = Vector2(
		drawer_width, maxf(1.0, viewport_size.y - vertical_edge * 2.0))

	var holder_height := maxf(1.0, _drawer.size.y - 8.0)
	var holder_width := minf(
		_drawer.size.x - 8.0, holder_height * FLAGSHIP_PORTRAIT_ASPECT)
	_phone_holder.size = Vector2(holder_width, holder_height)
	_phone_holder.position = (_drawer.size - _phone_holder.size) * 0.5

	# The generated frame's transparent display opening is x=23..1488 and
	# y=31..693 before the clockwise rotation. These conservative ratios keep
	# live controls under the glass while the material masks its curved edge.
	_display_panel.position = Vector2(
		holder_width * 0.045, holder_height * 0.018)
	_display_panel.size = Vector2(
		holder_width * 0.912, holder_height * 0.964)

	var compact := viewport_size.x <= 960.5
	_content_margin.add_theme_constant_override(
		"margin_left", 10 if compact else 12)
	_content_margin.add_theme_constant_override(
		"margin_right", 10 if compact else 12)
	_content_margin.add_theme_constant_override(
		"margin_top", 11 if compact else 13)
	_content_margin.add_theme_constant_override(
		"margin_bottom", 10 if compact else 12)

	# Rotate the approved 1512x720 landscape material around its center. The
	# transformed bounds then match the portrait holder exactly.
	_frame_texture.size = Vector2(holder_height, holder_width)
	_frame_texture.position = (
		_phone_holder.size * 0.5 - _frame_texture.size * 0.5)
	_frame_texture.pivot_offset = _frame_texture.size * 0.5
	_frame_texture.rotation = PI * 0.5


func _drawer_width_for(viewport_width: float) -> float:
	if viewport_width <= 960.0:
		return DRAWER_COMPACT
	if viewport_width >= 1280.0:
		return DRAWER_WIDE
	return roundf(lerpf(
		DRAWER_COMPACT, DRAWER_WIDE,
		(viewport_width - 960.0) / 320.0))


func _rebuild() -> void:
	_clear_children(_body)
	_update_tab_copy_and_style()
	_back_button.visible = _screen_mode == "thread"
	if _screen_mode == "thread":
		_build_thread()
	elif _active_tab == 0:
		_build_conversation_list()
	else:
		_build_contact_list()
	_footer_hint.text = LocaleManager.ui(
		"%s/%s 탭 · %s 뒤로 · P/%s 닫기" % [
			ControllerHints.shoulder_l(), ControllerHints.shoulder_r(),
			ControllerHints.east(), ControllerHints.north()],
		"%s/%s Tabs · %s Back · P/%s Close" % [
			ControllerHints.shoulder_l(), ControllerHints.shoulder_r(),
			ControllerHints.east(), ControllerHints.north()])
	_body_scroll.scroll_vertical = 0
	call_deferred("_refresh_focus_cycle")


func _update_tab_copy_and_style() -> void:
	var names := [
		LocaleManager.ui("대화", "CHATS"),
		LocaleManager.ui("연락처", "CONTACTS"),
	]
	for index in range(_tab_buttons.size()):
		var tab := _tab_buttons[index]
		tab.text = names[index]
		_apply_button_style(tab, index == _active_tab, false)
	if _screen_mode == "thread":
		_header_title.text = _thread_title
	else:
		_header_title.text = LocaleManager.ui("연락", "PHONE")


func _build_conversation_list() -> void:
	var ids := _received_contact_offer_ids()
	_body.add_child(_section_title(LocaleManager.ui(
		"이번 달 받은 연락 · %d" % ids.size(),
		"RECEIVED THIS MONTH · %d" % ids.size())))
	for bundle_id in ids:
		var offer := CORE_LOOP.bundle(bundle_id)
		var surface := _contact_surface_kind(offer)
		_body.add_child(_conversation_row(
			_phone_message_sender(offer),
			_phone_message_body(offer),
			bundle_id, surface))
	if ids.is_empty():
		_body.add_child(_empty_card(
			LocaleManager.ui("새로 받은 연락이 없다", "NO NEW CONTACT"),
			LocaleManager.ui(
				"문자나 통화가 아닌 제안은 넓은 계획판에서 확인한다.",
				"Offers that are not messages or calls stay in the wide planner.")))


func _received_contact_offer_ids() -> Array[String]:
	var result: Array[String] = []
	for bundle_id in CORE_LOOP.received_phone_offer_ids(_month_index):
		result.append(bundle_id)
	for bundle_id in CORE_LOOP.received_phone_consequence_ids(_month_index):
		if result.has(bundle_id):
			continue
		var consequence := CORE_LOOP.bundle(bundle_id)
		if _contact_surface_kind(consequence) \
				in ["inbound_message", "call_log"]:
			result.append(bundle_id)
	return result


func _contact_surface_kind(offer: Dictionary) -> String:
	var surface := str(offer.get("phone_surface", "")).strip_edges()
	return surface if surface in ["inbound_message", "call_log"] else ""


func _conversation_row(
		title: String, body: String, bundle_id: String,
		surface: String) -> Button:
	var row := Button.new()
	row.name = "Conversation_%s" % bundle_id
	row.text = ""
	row.focus_mode = Control.FOCUS_ALL
	row.custom_minimum_size = Vector2(0, 68)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	row.set_meta("communication_surface", surface)
	row.set_meta("bundle_id", bundle_id)
	row.set_meta("focus_key", "conversation:%s" % bundle_id)
	_apply_button_style(row, false, true)
	row.pressed.connect(_open_thread.bind(title, body, bundle_id, surface))
	row.mouse_entered.connect(row.grab_focus)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 9)
	margin.add_theme_constant_override("margin_right", 9)
	margin.add_theme_constant_override("margin_top", 7)
	margin.add_theme_constant_override("margin_bottom", 7)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(margin)
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 8)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(line)
	var avatar := _avatar_panel(title)
	line.add_child(avatar)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_theme_constant_override("separation", 2)
	copy.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.add_child(copy)
	var title_label := _label(title, 13, COLOR_TEXT, true)
	title_label.max_lines_visible = 1
	title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	copy.add_child(title_label)
	var preview := _label(body, 12, COLOR_DIM)
	preview.max_lines_visible = 2
	preview.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	copy.add_child(preview)
	var channel := _label(
		LocaleManager.ui("통화", "CALL") if surface == "call_log"
		else LocaleManager.ui("문자", "TEXT"),
		10, COLOR_ACCENT, true)
	channel.custom_minimum_size = Vector2(28, 0)
	channel.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	channel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	channel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.add_child(channel)
	return row


func _open_thread(
		title: String, body: String, bundle_id: String,
		surface: String) -> void:
	_thread_title = title
	_thread_body = body
	_thread_bundle_id = bundle_id
	_thread_kind = surface
	_return_focus_key = "conversation:%s" % bundle_id
	_screen_mode = "thread"
	_rebuild()
	call_deferred("_focus_after_rebuild")


func _build_thread() -> void:
	var sender := HBoxContainer.new()
	sender.add_theme_constant_override("separation", 8)
	_body.add_child(sender)
	sender.add_child(_avatar_panel(_thread_title, 44))
	var sender_copy := VBoxContainer.new()
	sender_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sender.add_child(sender_copy)
	sender_copy.add_child(_label(_thread_title, 14, COLOR_TEXT, true))
	sender_copy.add_child(_label(
		LocaleManager.ui("이번 달 통화 기록", "CALL LOG THIS MONTH")
			if _thread_kind == "call_log"
			else LocaleManager.ui("이번 달 받은 문자", "TEXT RECEIVED THIS MONTH"),
		11, COLOR_DIM))

	var bubble := PanelContainer.new()
	bubble.name = "IncomingCommunicationBubble"
	bubble.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bubble.add_theme_stylebox_override(
		"panel", _rounded_style(
			COLOR_CALL if _thread_kind == "call_log" else COLOR_MESSAGE,
			Color("#5a6979") if _thread_kind == "call_log" else Color.WHITE,
			1, 18))
	_body.add_child(bubble)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 13)
	margin.add_theme_constant_override("margin_right", 13)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	bubble.add_child(margin)
	var message := _label(
		_thread_body, 14,
		COLOR_TEXT if _thread_kind == "call_log" else Color("#20262d"))
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	margin.add_child(message)

	if not _thread_bundle_id.is_empty() \
			and CORE_LOOP.available_offer_ids(_month_index).has(
				_thread_bundle_id):
		var request := _action_button(
			LocaleManager.ui("일정에서 보기", "VIEW IN PLANNER"))
		request.set_meta("offer_request", true)
		request.set_meta("bundle_id", _thread_bundle_id)
		request.set_meta("focus_key", "offer:%s" % _thread_bundle_id)
		request.pressed.connect(_request_offer.bind(_thread_bundle_id))
		_body.add_child(request)
	else:
		_body.add_child(_empty_card(
			LocaleManager.ui(
				"지금은 일정에 넣을 수 없음", "NOT AVAILABLE TO PLAN"),
			LocaleManager.ui(
				"이 대화는 기록으로만 남아 있다.",
				"This conversation remains only as history.")))


func _build_contact_list() -> void:
	var contact_ids := _actual_contact_ids()
	_body.add_child(_section_title(LocaleManager.ui(
		"실제로 연락할 수 있는 사람 · %d" % contact_ids.size(),
		"PEOPLE YOU CAN REACH · %d" % contact_ids.size())))
	for character_id in contact_ids:
		_body.add_child(_contact_row(character_id))
	if contact_ids.is_empty():
		_body.add_child(_empty_card(
			LocaleManager.ui("저장된 연락처가 없다", "NO SAVED CONTACTS"),
			LocaleManager.ui(
				"직접 번호나 대화방을 얻은 사람만 여기에 남는다.",
				"Only people whose number or chat you actually obtained appear here.")))


func _actual_contact_ids() -> Array[String]:
	var result: Array[String] = []
	for character_id in ["father", "hyunsu", "sangchul", "jaehyuk"]:
		if _contact_method(character_id) in ACTUAL_CONTACT_METHODS:
			result.append(character_id)
	return result


func _contact_row(character_id: String) -> Control:
	var method := _contact_method(character_id)
	var topic_bundle := _contact_topic_bundle(character_id)
	var can_request := (
		method in ACTUAL_CONTACT_METHODS
		and not topic_bundle.is_empty()
		and CORE_LOOP.available_offer_ids(_month_index).has(topic_bundle)
	)
	var panel: Control
	if can_request:
		var button := Button.new()
		button.name = "Contact_%s" % character_id
		button.text = ""
		button.focus_mode = Control.FOCUS_ALL
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.set_meta("offer_request", true)
		button.set_meta("bundle_id", topic_bundle)
		button.set_meta("focus_key", "contact:%s" % character_id)
		button.pressed.connect(_request_offer.bind(topic_bundle))
		button.mouse_entered.connect(button.grab_focus)
		_apply_button_style(button, false, true)
		panel = button
	else:
		var static_panel := PanelContainer.new()
		static_panel.add_theme_stylebox_override(
			"panel", _rounded_style(COLOR_PANEL, COLOR_BORDER, 1, 14))
		panel = static_panel
	panel.custom_minimum_size = Vector2(0, 78)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.set_meta("contact_id", character_id)
	panel.set_meta("contact_method", method)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 9)
	margin.add_theme_constant_override("margin_right", 9)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(margin)
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 8)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(line)
	line.add_child(_avatar_panel(_character_name(character_id)))
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_theme_constant_override("separation", 3)
	copy.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.add_child(copy)
	copy.add_child(_label(_character_name(character_id), 13, COLOR_TEXT, true))
	var method_label := _label(_contact_method_copy(method), 12, COLOR_DIM)
	method_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	method_label.max_lines_visible = 2
	method_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	copy.add_child(method_label)
	var state := _label(
		_contact_action_copy(method) if can_request else LocaleManager.ui(
			"이번 달 연락 일정 없음", "NO CONTACT PLAN THIS MONTH"),
		10, COLOR_ACCENT if can_request else COLOR_DIM, true)
	state.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	state.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	state.custom_minimum_size = Vector2(54, 0)
	state.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	state.max_lines_visible = 3
	line.add_child(state)
	return panel


func _contact_method(character_id: String) -> String:
	match character_id:
		"father":
			return "phone"
		"hyunsu":
			return "kakao" if _bundle_completed("hyunsu_first_meet") else "none"
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


func _contact_topic_bundle(character_id: String) -> String:
	var candidates: Array[String] = []
	match character_id:
		"father":
			candidates = ["father_first_call", "father_quiet_call"]
		"hyunsu":
			candidates = ["hyunsu_player_reachout"]
		"sangchul":
			candidates = ["sangchul_second_coffee"]
		"jaehyuk":
			candidates = ["jaehyuk_plain_reunion_echo"]
	var available := CORE_LOOP.available_offer_ids(_month_index)
	for bundle_id in candidates:
		if available.has(bundle_id):
			return bundle_id
	return ""


func _contact_method_copy(method: String) -> String:
	match method:
		"phone":
			return LocaleManager.ui("저장된 전화번호", "SAVED PHONE NUMBER")
		"kakao":
			return LocaleManager.ui("카카오톡 대화방", "KAKAOTALK THREAD")
		"business_card":
			return LocaleManager.ui("받은 명함의 번호", "NUMBER ON A BUSINESS CARD")
	return LocaleManager.ui("연락수단 없음", "NO CONTACT METHOD")


func _contact_action_copy(method: String) -> String:
	if method not in ACTUAL_CONTACT_METHODS:
		return ""
	return LocaleManager.ui("일정 보기", "VIEW PLAN")


func _request_offer(bundle_id: String) -> void:
	if bundle_id.is_empty() \
			or not CORE_LOOP.available_offer_ids(_month_index).has(bundle_id):
		return
	offer_requested.emit(bundle_id)


func _switch_tab(index: int) -> void:
	_active_tab = clampi(index, 0, 1)
	_screen_mode = "list"
	_clear_thread()
	_rebuild()
	call_deferred("_focus_after_rebuild")


func _cycle_tab(delta: int) -> void:
	_switch_tab(posmod(_active_tab + delta, 2))


func _go_back_one_level() -> void:
	if _screen_mode == "thread":
		_screen_mode = "list"
		_clear_thread(false)
		_rebuild()
		call_deferred("_restore_return_focus")
		return
	close()


func _clear_thread(clear_return: bool = true) -> void:
	_thread_title = ""
	_thread_body = ""
	_thread_bundle_id = ""
	_thread_kind = ""
	if clear_return:
		_return_focus_key = ""


func _focus_after_rebuild() -> void:
	if not visible:
		return
	var preferred: Control = null
	if _screen_mode == "thread":
		preferred = _find_meta_control("offer_request", true)
	if not is_instance_valid(preferred):
		preferred = _first_body_button()
	if not is_instance_valid(preferred):
		preferred = _tab_buttons[_active_tab]
	if is_instance_valid(preferred):
		preferred.grab_focus()


func _restore_return_focus() -> void:
	if not visible:
		return
	var target := _find_meta_control("focus_key", _return_focus_key)
	if is_instance_valid(target):
		target.grab_focus()
	else:
		_focus_after_rebuild()
	_return_focus_key = ""


func _refresh_focus_cycle() -> void:
	if not visible:
		return
	var controls: Array[Control] = []
	_collect_focusable_controls(_display_panel, controls)
	if controls.is_empty():
		return
	for index in range(controls.size()):
		var current := controls[index]
		var previous := controls[posmod(index - 1, controls.size())]
		var following := controls[(index + 1) % controls.size()]
		current.focus_neighbor_top = current.get_path_to(previous)
		current.focus_neighbor_bottom = current.get_path_to(following)
		current.focus_neighbor_left = current.get_path_to(current)
		current.focus_neighbor_right = current.get_path_to(current)
		current.focus_previous = current.get_path_to(previous)
		current.focus_next = current.get_path_to(following)


func _collect_focusable_controls(root: Node, output: Array[Control]) -> void:
	for child in root.get_children():
		if child is Control:
			var control := child as Control
			if control.visible and control.focus_mode != Control.FOCUS_NONE \
					and not (control is BaseButton and (control as BaseButton).disabled):
				output.append(control)
		_collect_focusable_controls(child, output)


func _first_body_button() -> Control:
	for child in _body.get_children():
		if child is BaseButton and not (child as BaseButton).disabled:
			return child as Control
	return null


func _find_meta_control(key: String, value: Variant) -> Control:
	var candidates := find_children("*", "Control", true, false)
	for candidate in candidates:
		if candidate is Control and candidate.has_meta(key) \
				and candidate.get_meta(key) == value \
				and (candidate as Control).is_visible_in_tree():
			return candidate as Control
	return null


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	var handled := false
	if _phone_shortcut_pressed(event):
		close()
		handled = true
	elif event is InputEventJoypadButton \
			and (event as InputEventJoypadButton).pressed:
		match int((event as InputEventJoypadButton).button_index):
			JOY_BUTTON_B:
				_go_back_one_level()
				handled = true
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
		_go_back_one_level()
		handled = true
	if handled:
		get_viewport().set_input_as_handled()


func _phone_shortcut_pressed(event: InputEvent) -> bool:
	if event is InputEventJoypadButton:
		var joy := event as InputEventJoypadButton
		return joy.pressed and joy.button_index == JOY_BUTTON_Y
	if event is InputEventKey:
		var key := event as InputEventKey
		return key.pressed and not key.echo \
			and (key.keycode == KEY_P or key.physical_keycode == KEY_P)
	return false


func _on_shade_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and (event as InputEventMouseButton).pressed \
			and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		close()
		get_viewport().set_input_as_handled()


func _play_open_reveal() -> void:
	if is_instance_valid(_open_tween):
		_open_tween.kill()
	_drawer.position = _drawer_rest_position
	if bool(SaveManager.get_setting("reduce_motion", false)):
		_drawer.modulate.a = 1.0
		return
	_drawer.position += Vector2(minf(64.0, _drawer.size.x * 0.18), 0.0)
	_drawer.modulate.a = 0.0
	_open_tween = create_tween()
	_open_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_open_tween.tween_property(
		_drawer, "position", _drawer_rest_position, 0.18) \
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	_open_tween.parallel().tween_property(_drawer, "modulate:a", 1.0, 0.14) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_language_changed(_language: String) -> void:
	if visible:
		_rebuild()
		call_deferred("_focus_after_rebuild")


func _optional_phone_copy(offer: Dictionary, stem: String) -> String:
	var suffix := "en" if LocaleManager.is_english() else "ko"
	return str(offer.get("%s_%s" % [stem, suffix], "")).strip_edges()


func _phone_message_sender(offer: Dictionary) -> String:
	var sender := _optional_phone_copy(offer, "message_sender")
	if not sender.is_empty():
		return sender
	var fallback := _localized(offer, "offer").strip_edges()
	return fallback if not fallback.is_empty() else LocaleManager.ui(
		"알 수 없는 발신자", "UNKNOWN SENDER")


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


func _localized(data: Dictionary, stem: String) -> String:
	var ko_text := str(data.get("%s_ko" % stem, ""))
	var en_text := str(data.get("%s_en" % stem, ko_text))
	return LocaleManager.ui(ko_text, en_text)


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


func _character_name(character_id: String) -> String:
	match character_id:
		"father":
			return LocaleManager.ui("아버지", "Father")
		"hyunsu":
			return LocaleManager.ui("현수", "Hyunsu")
		"sangchul":
			return LocaleManager.ui("임상철", "Im Sangchul")
		"jaehyuk":
			return LocaleManager.ui("최재혁", "Choi Jaehyuk")
	return character_id


func _avatar_panel(title: String, diameter: int = 40) -> PanelContainer:
	var avatar := PanelContainer.new()
	avatar.custom_minimum_size = Vector2(diameter, diameter)
	avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar.add_theme_stylebox_override(
		"panel", _rounded_style(
			_avatar_color(title), Color("#ffffff", 0.20), 1,
			diameter / 2))
	var mark := _label(
		title.strip_edges().left(1).to_upper() if not title.strip_edges().is_empty()
		else "?",
		13, Color.WHITE, true)
	mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar.add_child(mark)
	return avatar


func _avatar_color(title: String) -> Color:
	var colors: Array[Color] = [
		Color("#337f73"), Color("#416ba0"), Color("#8b5d83"),
		Color("#9a633d"), Color("#586a8c"),
	]
	return colors[absi(title.hash()) % colors.size()]


func _section_title(text: String) -> Label:
	var result := _label(text, 12, COLOR_ACCENT, true)
	result.custom_minimum_size = Vector2(0, 24)
	result.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return result


func _empty_card(title: String, body: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 88)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override(
		"panel", _rounded_style(COLOR_PANEL, COLOR_BORDER, 1, 14))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)
	var copy := VBoxContainer.new()
	copy.add_theme_constant_override("separation", 4)
	margin.add_child(copy)
	copy.add_child(_label(title, 13, COLOR_TEXT, true))
	var body_label := _label(body, 12, COLOR_DIM)
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.add_child(body_label)
	return panel


func _action_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_ALL
	button.custom_minimum_size = Vector2(0, 46)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.mouse_entered.connect(button.grab_focus)
	_apply_button_style(button, true, false)
	return button


func _icon_button(text: String, role: String) -> Button:
	var button := Button.new()
	button.name = "%sButton" % role.capitalize()
	button.text = text
	button.focus_mode = Control.FOCUS_ALL
	button.custom_minimum_size = Vector2(42, 42)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.mouse_entered.connect(button.grab_focus)
	button.set_meta("communication_nav", role)
	_apply_button_style(button, false, false)
	return button


func _apply_button_style(
		button: Button, selected: bool, card: bool) -> void:
	var radius := 14 if card else 10
	var normal_bg := COLOR_PANEL_ALT if selected else COLOR_PANEL
	var border := COLOR_ACCENT if selected else COLOR_BORDER
	button.add_theme_stylebox_override(
		"normal", _rounded_style(normal_bg, border, 2 if selected else 1, radius))
	button.add_theme_stylebox_override(
		"hover", _rounded_style(Color("#223044"), COLOR_ACCENT, 1, radius))
	button.add_theme_stylebox_override(
		"pressed", _rounded_style(Color("#26364c"), COLOR_ACCENT, 2, radius))
	button.add_theme_stylebox_override(
		"focus", _rounded_style(Color("#223044"), COLOR_ACCENT, 2, radius))
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_focus_color", Color.WHITE)
	button.add_theme_font_size_override("font_size", 12)
	if _font_bold:
		button.add_theme_font_override("font", _font_bold)


func _label(
		text: String, font_size: int, color: Color,
		bold: bool = false) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	if bold and _font_bold:
		label.add_theme_font_override("font", _font_bold)
	elif _font:
		label.add_theme_font_override("font", _font)
	return label


func _rounded_style(
		background: Color, border: Color, width: int,
		radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
