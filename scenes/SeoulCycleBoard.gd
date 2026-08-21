extends Control
## ORDER-94: full-screen Seoul cycle allocation board.
##
## This surface is deliberately state-less with regard to the game model. It
## reads a host-owned snapshot, keeps only an uncommitted local selection, and
## emits one allocation request. The host applies the transaction and calls
## refresh() with the resulting snapshot.

signal allocation_requested(
	die_id: String, node_id: String, selected_candidate_id: String)
signal board_closed

const BACKGROUND := preload("res://assets/backgrounds/gangnam_night_street.png")

const COLOR_BASE := Color("#07090c")
const COLOR_PANEL := Color("#101318", 0.94)
const COLOR_PANEL_RAISED := Color("#171b21", 0.96)
const COLOR_ROUTE := Color("#707983", 0.58)
const COLOR_TEXT := Color("#edf1f5")
const COLOR_DIM := Color("#a1a9b2")
const COLOR_MUTED := Color("#68717a")
const COLOR_ACCENT := Color("#d8c38d")
const COLOR_FOCUS := Color("#f4f7fb")
const COLOR_DANGER := Color("#d78b83")
const COLOR_COMPLETE := Color("#9db7a5")
const COLOR_TICKET_INK := Color("#22262b")
const COLOR_TICKET_DIM := Color("#50575e")

const NODE_COUNT := 4
const EFFORT_COUNT := 4
const MAX_TRIGGER_CANDIDATES := 4
const TRIGGER_CANDIDATE_VISIBLE_ROWS := 2
const EFFECT_KEYS := ["money", "health", "mental"]

var _snapshot: Dictionary = {}
var _read_only := false
var _selected_die_id := ""
var _selected_node_id := ""
var _selected_trigger_bundle_id := ""
var _inspected_node_id := ""
var _focused_group := ""
var _focused_id := ""
var _error_text := ""
var _allocation_in_flight := false
var _open_generation := 0

var _font: Font
var _font_bold: Font
var _background: TextureRect
var _shade: TextureRect
var _header_panel: Panel
var _title_label: Label
var _time_label: Label
var _money_label: Label
var _health_label: Label
var _mental_label: Label
var _close_button: Button
var _map_panel: Panel
var _map_title_label: Label
var _map_subtitle_label: Label
var _world_clock_label: Label
var _world_clock_segments: HBoxContainer
var _route_layer: Control
var _node_layer: Control
var _preview_panel: Panel
var _preview_title_label: Label
var _preview_choice_label: Label
var _preview_progress_label: Label
var _preview_effect_label: Label
var _preview_deadline_label: Label
var _trigger_candidate_panel: Panel
var _trigger_candidate_title_label: Label
var _trigger_candidate_scroll: ScrollContainer
var _trigger_candidate_layer: Control
var _error_label: Label
var _commit_button: Button
var _effort_panel: Panel
var _effort_title_label: Label
var _effort_hint_label: Label

var _node_order: Array[String] = []
var _node_buttons: Dictionary = {}
var _node_parts: Dictionary = {}
var _die_order: Array[String] = []
var _die_buttons: Dictionary = {}
var _die_parts: Dictionary = {}
var _trigger_candidate_order: Array[String] = []
var _trigger_candidate_buttons: Dictionary = {}
var _trigger_candidate_records: Dictionary = {}
var _trigger_candidate_signature := ""
var _rebuilding_entities := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 109
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	_font = FontKit.ui_regular()
	_font_bold = FontKit.ui_bold()
	FontKit.attach_emoji_fallback(_font)
	FontKit.attach_emoji_fallback(_font_bold)
	_build_ui()
	set_meta("seoul_cycle_board", true)
	set_meta("seoul_cycle_board_open", false)
	set_meta("seoul_cycle_snapshot_contract", "seoul_cycle_v1")
	set_meta("seoul_cycle_trigger_candidate_max", MAX_TRIGGER_CANDIDATES)
	resized.connect(_apply_geometry)
	LocaleManager.language_changed.connect(_on_language_changed)
	ControllerHints.input_mode_changed.connect(_on_input_mode_changed)
	visible = false


func open(snapshot: Dictionary, read_only := false) -> bool:
	var raw_validation_error := _raw_trigger_candidate_contract_error(snapshot)
	if not raw_validation_error.is_empty():
		set_meta("seoul_cycle_contract_error", raw_validation_error)
		push_warning("SeoulCycleBoard rejected snapshot: %s" % raw_validation_error)
		return false
	var normalized_snapshot := _normalized_snapshot(snapshot)
	var validation_error := _snapshot_validation_error(normalized_snapshot)
	if not validation_error.is_empty():
		set_meta("seoul_cycle_contract_error", validation_error)
		push_warning("SeoulCycleBoard rejected snapshot: %s" % validation_error)
		return false
	_open_generation += 1
	_read_only = read_only
	_error_text = ""
	_allocation_in_flight = false
	_snapshot = normalized_snapshot
	_restore_snapshot_selection(true)
	_rebuild_entities()
	_refresh_surface()
	visible = true
	move_to_front()
	modulate.a = 1.0
	set_meta("seoul_cycle_board_open", true)
	# The board owns the full viewport, including the top-right stat rail. Reuse
	# the planner marker context so the floating playtest badge cannot cover the
	# MIND card at the 960x600 supported floor.
	SceneTransition.set_playtest_marker_context(
		SceneTransition.PLAYTEST_MARKER_CONTEXT_PLANNER)
	_apply_geometry()
	AudioManager.play_ui_open(-10.0)
	call_deferred("_focus_after_open", _open_generation)
	return true


func refresh(snapshot: Dictionary) -> void:
	var raw_validation_error := _raw_trigger_candidate_contract_error(snapshot)
	if not raw_validation_error.is_empty():
		show_error(_tr(
			"서울 보드 상태를 읽지 못했다.",
			"The Seoul board state could not be read."))
		set_meta("seoul_cycle_contract_error", raw_validation_error)
		return
	var normalized_snapshot := _normalized_snapshot(snapshot)
	var validation_error := _snapshot_validation_error(normalized_snapshot)
	if not validation_error.is_empty():
		show_error(_tr(
			"서울 보드 상태를 읽지 못했다.",
			"The Seoul board state could not be read."))
		set_meta("seoul_cycle_contract_error", validation_error)
		return
	var old_focus_group := _focused_group
	var old_focus_id := _focused_id
	var had_explicit_selection := normalized_snapshot.has("selected") \
			or normalized_snapshot.has("selected_die_id") \
			or normalized_snapshot.has("selected_node_id")
	_snapshot = normalized_snapshot
	_error_text = ""
	_allocation_in_flight = false
	if had_explicit_selection:
		_restore_snapshot_selection(true)
	else:
		_restore_snapshot_selection(false)
	_rebuild_entities()
	_refresh_surface()
	_apply_geometry()
	if visible:
		call_deferred(
			"_restore_focus_after_refresh",
			_open_generation,
			old_focus_group,
			old_focus_id)


func show_error(text: String) -> void:
	_error_text = text.strip_edges()
	_allocation_in_flight = false
	set_meta("seoul_cycle_error", _error_text)
	_refresh_preview()
	_refresh_commit_state()
	if visible:
		AudioManager.play_ui_close(-15.0)


func close() -> void:
	if not visible:
		return
	_open_generation += 1
	var focused := get_viewport().gui_get_focus_owner()
	if focused is Control and is_ancestor_of(focused):
		(focused as Control).release_focus()
	visible = false
	_allocation_in_flight = false
	set_meta("seoul_cycle_board_open", false)
	set_meta("seoul_cycle_focus_group", "")
	set_meta("seoul_cycle_focus_id", "")
	set_meta("seoul_cycle_trigger_candidate_focus_id", "")
	SceneTransition.set_playtest_marker_context(
		SceneTransition.PLAYTEST_MARKER_CONTEXT_DEFAULT)
	AudioManager.play_ui_close(-11.0)
	board_closed.emit()


func is_open() -> bool:
	return visible


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	var cancel_pressed := event.is_action_pressed("ui_cancel") \
			or _joy_button_pressed(event, JOY_BUTTON_B)
	if cancel_pressed:
		get_viewport().set_input_as_handled()
		_cancel_or_close()
		return
	# Standard pads normally map South to ui_accept and Button consumes it. The
	# raw fallback keeps virtual-pad QA and unusual Steam Input layouts usable.
	if _joy_button_pressed(event, JOY_BUTTON_A) \
			and not event.is_action_pressed("ui_accept"):
		var focused := get_viewport().gui_get_focus_owner()
		if focused is Button and is_ancestor_of(focused) \
				and not (focused as Button).disabled:
			get_viewport().set_input_as_handled()
			(focused as Button).pressed.emit()


func _build_ui() -> void:
	_background = TextureRect.new()
	_background.name = "SeoulCycleNightBackground"
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background.texture = BACKGROUND
	_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background)

	_shade = TextureRect.new()
	_shade.name = "SeoulCycleInkShade"
	_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_shade.stretch_mode = TextureRect.STRETCH_SCALE
	_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shade_gradient := Gradient.new()
	shade_gradient.offsets = PackedFloat32Array([0.0, 0.48, 1.0])
	shade_gradient.colors = PackedColorArray([
		Color("#05070a", 0.80),
		Color("#080a0d", 0.63),
		Color("#030405", 0.91),
	])
	var shade_texture := GradientTexture2D.new()
	shade_texture.width = 512
	shade_texture.height = 32
	shade_texture.fill_from = Vector2(0.0, 0.5)
	shade_texture.fill_to = Vector2(1.0, 0.5)
	shade_texture.gradient = shade_gradient
	_shade.texture = shade_texture
	add_child(_shade)

	_header_panel = Panel.new()
	_header_panel.name = "SeoulCycleHeader"
	_header_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UIStyle.override_stylebox(_header_panel,
		"panel", _panel_style(Color("#090b0f", 0.93), Color("#4a5159", 0.76), 1, 7))
	add_child(_header_panel)
	_title_label = _label("", 27, COLOR_TEXT, true)
	_title_label.name = "SeoulCycleTitle"
	_header_panel.add_child(_title_label)
	_time_label = _label("", 14, COLOR_DIM)
	_time_label.name = "SeoulCycleTime"
	_header_panel.add_child(_time_label)
	_money_label = _stat_label("SeoulCycleMoney")
	_header_panel.add_child(_money_label)
	_health_label = _stat_label("SeoulCycleHealth")
	_header_panel.add_child(_health_label)
	_mental_label = _stat_label("SeoulCycleMental")
	_header_panel.add_child(_mental_label)
	_close_button = Button.new()
	_close_button.name = "SeoulCycleClose"
	_close_button.text = "×"
	_close_button.focus_mode = Control.FOCUS_NONE
	_close_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_close_button.set_meta("seoul_cycle_close", true)
	_apply_plain_button_style(_close_button)
	_close_button.pressed.connect(close)
	_header_panel.add_child(_close_button)

	_map_panel = Panel.new()
	_map_panel.name = "SeoulCycleRouteBoard"
	_map_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_map_panel.clip_contents = true
	UIStyle.override_stylebox(_map_panel,
		"panel", _panel_style(Color("#0a0d11", 0.69), Color("#3c444d", 0.84), 1, 8))
	add_child(_map_panel)
	_map_title_label = _label("", 18, COLOR_TEXT, true)
	_map_title_label.name = "SeoulCycleMapQuestion"
	_map_panel.add_child(_map_title_label)
	_map_subtitle_label = _label("", 12, COLOR_DIM)
	_map_subtitle_label.name = "SeoulCycleMapInstruction"
	_map_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_map_panel.add_child(_map_subtitle_label)
	_world_clock_label = _label("", 11, COLOR_DIM, true)
	_world_clock_label.name = "SeoulCycleWorldClockLabel"
	_world_clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_map_panel.add_child(_world_clock_label)
	_world_clock_segments = HBoxContainer.new()
	_world_clock_segments.name = "SeoulCycleWorldClockSegments"
	_world_clock_segments.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UIStyle.override_constant(_world_clock_segments, "separation", 3)
	_world_clock_segments.set_meta("seoul_cycle_world_clock_segments", true)
	_map_panel.add_child(_world_clock_segments)
	_route_layer = Control.new()
	_route_layer.name = "SeoulCycleRouteLines"
	_route_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_route_layer.draw.connect(_draw_routes)
	_map_panel.add_child(_route_layer)
	_node_layer = Control.new()
	_node_layer.name = "SeoulCycleLocationNodes"
	_node_layer.mouse_filter = Control.MOUSE_FILTER_PASS
	_map_panel.add_child(_node_layer)

	_preview_panel = Panel.new()
	_preview_panel.name = "SeoulCycleAllocationPreview"
	_preview_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_preview_panel.clip_contents = true
	_preview_panel.set_meta("seoul_cycle_preview", true)
	UIStyle.override_stylebox(_preview_panel,
		"panel", _panel_style(COLOR_PANEL, Color("#5a626b"), 1, 8))
	add_child(_preview_panel)
	_preview_title_label = _label("", 17, COLOR_ACCENT, true)
	_preview_title_label.name = "SeoulCyclePreviewTitle"
	_preview_panel.add_child(_preview_title_label)
	_preview_choice_label = _label("", 17, COLOR_TEXT, true)
	_preview_choice_label.name = "SeoulCyclePreviewChoice"
	_preview_choice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_preview_panel.add_child(_preview_choice_label)
	_preview_progress_label = _label("", 16, COLOR_TEXT, true)
	_preview_progress_label.name = "SeoulCyclePreviewProgress"
	_preview_progress_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_preview_panel.add_child(_preview_progress_label)
	_preview_effect_label = _label("", 14, COLOR_DIM)
	_preview_effect_label.name = "SeoulCyclePreviewEffects"
	_preview_effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_preview_panel.add_child(_preview_effect_label)
	_preview_deadline_label = _label("", 13, COLOR_DIM)
	_preview_deadline_label.name = "SeoulCyclePreviewDeadline"
	_preview_deadline_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_preview_panel.add_child(_preview_deadline_label)
	_trigger_candidate_panel = Panel.new()
	_trigger_candidate_panel.name = "SeoulCycleTriggerCandidates"
	_trigger_candidate_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_trigger_candidate_panel.clip_contents = true
	_trigger_candidate_panel.visible = false
	_trigger_candidate_panel.set_meta("seoul_cycle_trigger_candidate_panel", true)
	UIStyle.override_stylebox(_trigger_candidate_panel,
		"panel", _panel_style(Color("#0c1015", 0.98), Color("#59636d"), 1, 5))
	_preview_panel.add_child(_trigger_candidate_panel)
	_trigger_candidate_title_label = _label("", 11, COLOR_ACCENT, true)
	_trigger_candidate_title_label.name = "SeoulCycleTriggerCandidateTitle"
	_trigger_candidate_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_trigger_candidate_panel.add_child(_trigger_candidate_title_label)
	_trigger_candidate_scroll = ScrollContainer.new()
	_trigger_candidate_scroll.name = "SeoulCycleTriggerCandidateScroll"
	_trigger_candidate_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	_trigger_candidate_scroll.focus_mode = Control.FOCUS_NONE
	_trigger_candidate_scroll.clip_contents = true
	_trigger_candidate_scroll.horizontal_scroll_mode = \
		ScrollContainer.SCROLL_MODE_DISABLED
	_trigger_candidate_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_trigger_candidate_scroll.follow_focus = true
	_trigger_candidate_scroll.set_meta("seoul_cycle_trigger_candidate_scroll", true)
	_trigger_candidate_panel.add_child(_trigger_candidate_scroll)
	_trigger_candidate_layer = Control.new()
	_trigger_candidate_layer.name = "SeoulCycleTriggerCandidateChoices"
	_trigger_candidate_layer.mouse_filter = Control.MOUSE_FILTER_PASS
	_trigger_candidate_scroll.add_child(_trigger_candidate_layer)
	_error_label = _label("", 13, COLOR_DANGER, true)
	_error_label.name = "SeoulCycleError"
	_error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_error_label.visible = false
	_preview_panel.add_child(_error_label)
	_commit_button = Button.new()
	_commit_button.name = "SeoulCycleCommitAllocation"
	_commit_button.focus_mode = Control.FOCUS_ALL
	_commit_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_commit_button.set_meta("seoul_cycle_commit", true)
	_commit_button.set_meta("allocation_commit_button", true)
	_commit_button.pressed.connect(_on_commit_pressed)
	_commit_button.focus_entered.connect(_on_focus_entered.bind("commit", "commit"))
	_commit_button.focus_exited.connect(_on_focus_exited.bind("commit", "commit"))
	_preview_panel.add_child(_commit_button)

	_effort_panel = Panel.new()
	_effort_panel.name = "SeoulCycleWeeklyEffortRail"
	_effort_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_effort_panel.clip_contents = true
	UIStyle.override_stylebox(_effort_panel,
		"panel", _panel_style(Color("#0b0e12", 0.96), Color("#454d56"), 1, 7))
	add_child(_effort_panel)
	_effort_title_label = _label("", 15, COLOR_TEXT, true)
	_effort_title_label.name = "SeoulCycleEffortTitle"
	_effort_panel.add_child(_effort_title_label)
	_effort_hint_label = _label("", 12, COLOR_DIM)
	_effort_hint_label.name = "SeoulCycleControllerHint"
	_effort_hint_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_effort_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_effort_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_effort_panel.add_child(_effort_hint_label)


func _rebuild_entities() -> void:
	# `free()` emits focus_exited synchronously. Drop every lookup to the old
	# controls before that signal can ask the board to repaint; otherwise a
	# typed Button assignment can receive an already-freed instance while a
	# saved plan is being reopened.
	_rebuilding_entities = true
	_node_order.clear()
	_node_buttons.clear()
	_node_parts.clear()
	_die_order.clear()
	_die_buttons.clear()
	_die_parts.clear()
	_clear_children(_node_layer)
	for child in _effort_panel.get_children():
		if child == _effort_title_label or child == _effort_hint_label:
			continue
		child.free()
	var nodes: Dictionary = _snapshot.get("nodes", {})
	for raw_id in nodes.keys():
		var node_id := str(raw_id)
		_node_order.append(node_id)
	_node_order.sort_custom(_sort_node_ids)
	for node_id in _node_order:
		_create_node_button(node_id, nodes.get(node_id, {}))
	var dice: Array = _snapshot.get("dice", [])
	for raw_die in dice:
		var die: Dictionary = raw_die
		var die_id := str(die.get("id", ""))
		_die_order.append(die_id)
		_create_effort_button(die_id, die)
	_connect_focus_neighbors()
	_rebuilding_entities = false


func _create_node_button(node_id: String, node_data: Dictionary) -> void:
	var button := Button.new()
	button.name = "SeoulNode_%s" % _safe_node_name(node_id)
	button.text = ""
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.clip_contents = true
	button.set_meta("seoul_cycle_node", true)
	button.set_meta("seoul_cycle_node_id", node_id)
	button.set_meta("seoul_cycle_node_progress", int(node_data.get("progress", 0)))
	button.set_meta("seoul_cycle_node_target", int(node_data.get("target", 1)))
	button.set_meta("seoul_cycle_node_deadline_week", int(node_data.get("deadline_week", 0)))
	button.set_meta("seoul_cycle_node_completed", bool(node_data.get("completed", false)))
	button.set_meta("seoul_cycle_node_expired", bool(node_data.get("expired", false)))
	button.set_meta("seoul_cycle_node_locked", bool(node_data.get("locked", false)))
	button.pressed.connect(_on_node_pressed.bind(node_id))
	button.focus_entered.connect(_on_focus_entered.bind("node", node_id))
	button.focus_exited.connect(_on_focus_exited.bind("node", node_id))
	button.mouse_entered.connect(_on_mouse_entered.bind(button))
	_node_layer.add_child(button)

	var place := _label("", 11, COLOR_ACCENT, true)
	place.name = "Place"
	place.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	place.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(place)
	var title := _label("", 18, COLOR_TEXT, true)
	title.name = "Title"
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(title)
	var status := _label("", 12, COLOR_DIM)
	status.name = "Status"
	status.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(status)
	var clock := HBoxContainer.new()
	clock.name = "ProgressClock"
	clock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UIStyle.override_constant(clock, "separation", 4)
	button.add_child(clock)
	var target: int = maxi(1, int(node_data.get("target", 1)))
	var progress: int = clampi(int(node_data.get("progress", 0)), 0, target)
	for segment_index in range(target):
		var segment := Panel.new()
		segment.name = "ClockSegment%02d" % (segment_index + 1)
		segment.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		segment.mouse_filter = Control.MOUSE_FILTER_IGNORE
		segment.set_meta("seoul_cycle_clock_segment", segment_index + 1)
		segment.set_meta("filled", segment_index < progress)
		UIStyle.override_stylebox(segment, "panel", _panel_style(
			COLOR_ACCENT if segment_index < progress else Color("#242a31"),
			COLOR_ACCENT if segment_index < progress else Color("#5c6670"),
			1,
			2))
		clock.add_child(segment)
	var overlay := Control.new()
	overlay.name = "NodeStateOverlay"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.draw.connect(_draw_node_overlay.bind(button, overlay))
	button.add_child(overlay)
	_node_buttons[node_id] = button
	_node_parts[node_id] = {
		"place": place,
		"title": title,
		"status": status,
		"clock": clock,
		"overlay": overlay,
	}
	_refresh_node_content(node_id)


func _create_effort_button(die_id: String, die: Dictionary) -> void:
	var button := Button.new()
	button.name = "EffortTile_%s" % _safe_node_name(die_id)
	button.text = ""
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.clip_contents = true
	button.set_meta("seoul_cycle_effort_tile", true)
	button.set_meta("seoul_cycle_die_id", die_id)
	button.set_meta("seoul_cycle_die_value", int(die.get("value", 0)))
	button.set_meta("seoul_cycle_die_spent", bool(die.get("spent", false)))
	button.pressed.connect(_on_die_pressed.bind(die_id))
	button.focus_entered.connect(_on_focus_entered.bind("die", die_id))
	button.focus_exited.connect(_on_focus_exited.bind("die", die_id))
	button.mouse_entered.connect(_on_mouse_entered.bind(button))
	_effort_panel.add_child(button)
	var week := _label("", 11, COLOR_TICKET_DIM, true)
	week.name = "Week"
	week.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(week)
	var value := _label("", 30, COLOR_TICKET_INK, true)
	value.name = "Value"
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	value.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(value)
	var detail := _label("", 11, COLOR_TICKET_DIM, true)
	detail.name = "Detail"
	detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(detail)
	var overlay := Control.new()
	overlay.name = "EffortTicketMaterial"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.draw.connect(_draw_effort_overlay.bind(button, overlay))
	button.add_child(overlay)
	_die_buttons[die_id] = button
	_die_parts[die_id] = {
		"week": week,
		"value": value,
		"detail": detail,
		"overlay": overlay,
	}
	_refresh_die_content(die_id)


func _refresh_surface() -> void:
	if _snapshot.is_empty():
		return
	# Editing the current week is a mandatory calendar owner. Only the
	# read-only ledger may expose a close affordance; the host closes an edited
	# board after a durable allocation receipt exists.
	_close_button.visible = _read_only
	_title_label.text = _tr("서울의 네 주", "FOUR WEEKS IN SEOUL")
	var year := int(_snapshot.get("year", 2026))
	var calendar_month := int(_snapshot.get(
		"calendar_month", _snapshot.get("month", 1)))
	var week := int(_snapshot.get("week_of_month", 1))
	_time_label.text = LocaleManager.ui_format(
		"%d년 %d월 · %d주차", "%04d.%02d · WEEK %d",
		[year, calendar_month, week], [year, calendar_month, week])
	_money_label.text = _tr("현금  ", "CASH  ") + _format_money(float(_snapshot.get("money", 0)))
	_health_label.text = _tr("몸  %d", "BODY  %d") % int(_snapshot.get("health", 0))
	_mental_label.text = _tr("마음  %d", "MIND  %d") % int(_snapshot.get("mental", 0))
	_map_title_label.text = _tr("이번 주, 어디에 쓸 것인가", "WHERE DOES THIS WEEK GO?")
	_map_subtitle_label.text = _tr(
		"여력 → 장소 → 약속 → 확정",
		"CAPACITY → PLACE → THREAD → COMMIT")
	_refresh_world_clock()
	_effort_title_label.text = LocaleManager.ui_format(
		"이번 달 남은 여력 · %d/4", "MONTHLY CAPACITY LEFT · %d/4",
		_remaining_effort_count(), _remaining_effort_count())
	for node_id in _node_order:
		_refresh_node_content(node_id)
	for die_id in _die_order:
		_refresh_die_content(die_id)
	_refresh_hint()
	_refresh_trigger_candidate_surface()
	_refresh_visual_states()
	_refresh_trigger_candidate_states()
	_refresh_preview()
	_refresh_commit_state()
	_update_root_meta()
	_route_layer.queue_redraw()


func _refresh_node_content(node_id: String) -> void:
	if not _node_parts.has(node_id):
		return
	var nodes: Dictionary = _snapshot.get("nodes", {})
	var node_data: Dictionary = nodes.get(node_id, {})
	var parts: Dictionary = _node_parts[node_id]
	var place: Label = parts.get("place")
	var title: Label = parts.get("title")
	var status: Label = parts.get("status")
	place.text = _localized(node_data, "place")
	title.text = _localized_board_label(node_data)
	var progress := int(node_data.get("progress", 0))
	var target: int = maxi(1, int(node_data.get("target", 1)))
	var deadline := int(node_data.get("deadline_week", 0))
	if str(node_data.get("featured_status", "")) == "expired" \
			and bool(node_data.get("repeatable", false)):
		status.text = _tr(
			"특별 기회 종료 · 일반 행동 가능",
			"FEATURED CHANCE MISSED · REGULAR ACTION OPEN")
		UIStyle.override_color(status, "font_color", COLOR_DANGER)
	elif bool(node_data.get("locked", false)) \
			or _node_has_empty_required_trigger_candidates(node_id):
		status.text = _tr(
			"이번 달 이어진 연락 없음",
			"NO THREAD TO FOLLOW THIS MONTH")
		UIStyle.override_color(status, "font_color", COLOR_MUTED)
	elif bool(node_data.get("expired", false)):
		status.text = _tr("기한 종료 · %d/%d", "EXPIRED · %d/%d") % [progress, target]
		UIStyle.override_color(status, "font_color", COLOR_DANGER)
	elif bool(node_data.get("completed", false)):
		status.text = (
			_tr("완료 · 다시 선택 가능", "COMPLETE · REPEATABLE")
			if bool(node_data.get("repeatable", false)) else
			_tr("완료 · %d/%d", "COMPLETE · %d/%d") % [progress, target]
		)
		UIStyle.override_color(status, "font_color", COLOR_COMPLETE)
	elif deadline > 0:
		status.text = _tr(
			"진행 %d/%d · %d주차까지",
			"CLOCK %d/%d · BY WEEK %d") % [progress, target, deadline]
		UIStyle.override_color(status, "font_color", COLOR_DIM)
	else:
		status.text = _tr("진행 %d/%d", "CLOCK %d/%d") % [progress, target]
		UIStyle.override_color(status, "font_color", COLOR_DIM)


func _refresh_die_content(die_id: String) -> void:
	if not _die_parts.has(die_id):
		return
	var die := _die_data(die_id)
	var parts: Dictionary = _die_parts[die_id]
	var week: Label = parts.get("week")
	var value: Label = parts.get("value")
	var detail: Label = parts.get("detail")
	var die_index := _die_order.find(die_id)
	var spent := bool(die.get("spent", false))
	var amount := int(die.get("value", 0))
	week.text = _tr("여력 %d", "CAPACITY %d") % (die_index + 1)
	value.text = "—" if spent else str(amount)
	detail.text = (
		_tr("사용함", "SPENT")
		if spent else _tr("기본 진전 +%d칸", "BASE +%d CLOCK") % _base_progress(amount))
	UIStyle.override_color(value, "font_color", COLOR_MUTED if spent else COLOR_TICKET_INK)
	UIStyle.override_color(detail, "font_color", COLOR_MUTED if spent else COLOR_TICKET_DIM)


func _refresh_trigger_candidate_surface() -> void:
	var preview := _preview_for(_selected_die_id, _selected_node_id)
	var required := _trigger_selection_required(preview)
	var candidates := _trigger_candidates(preview)
	var next_records: Dictionary = {}
	var next_order: Array[String] = []
	for candidate in candidates:
		var candidate_id := str(candidate.get("id", ""))
		if candidate_id.is_empty():
			continue
		next_order.append(candidate_id)
		next_records[candidate_id] = candidate
	var signature := JSON.stringify(candidates)
	var next_visible := required and not next_order.is_empty() \
			and not _selected_die_id.is_empty() \
			and not _selected_node_id.is_empty()
	if signature != _trigger_candidate_signature:
		_rebuilding_entities = true
		_trigger_candidate_order.clear()
		_trigger_candidate_buttons.clear()
		_trigger_candidate_records.clear()
		_clear_children(_trigger_candidate_layer)
		_trigger_candidate_signature = signature
		_trigger_candidate_order = next_order
		_trigger_candidate_records = next_records
		for candidate_id in _trigger_candidate_order:
			_create_trigger_candidate_button(candidate_id)
		_trigger_candidate_scroll.scroll_vertical = 0
		_rebuilding_entities = false
	else:
		_trigger_candidate_order = next_order
		_trigger_candidate_records = next_records
	if not required or (not _selected_trigger_bundle_id.is_empty() \
			and not _trigger_candidate_records.has(_selected_trigger_bundle_id)):
		_selected_trigger_bundle_id = ""
	_trigger_candidate_panel.visible = next_visible
	_trigger_candidate_title_label.text = _tr(
		"이어갈 약속 · 직접 선택",
		"THREAD TO FOLLOW · CHOOSE ONE")
	# Candidate availability changes the node/commit routes even when the
	# records are byte-for-byte unchanged (for example after East undo).
	_connect_focus_neighbors()


func _create_trigger_candidate_button(candidate_id: String) -> void:
	var button := Button.new()
	button.name = "TriggerCandidate_%s" % _safe_node_name(candidate_id)
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	button.add_theme_font_override("font", _font_bold)
	button.set_meta("seoul_cycle_trigger_candidate", true)
	button.set_meta("seoul_cycle_trigger_candidate_id", candidate_id)
	button.pressed.connect(_on_trigger_candidate_pressed.bind(candidate_id))
	button.focus_entered.connect(_on_focus_entered.bind("candidate", candidate_id))
	button.focus_exited.connect(_on_focus_exited.bind("candidate", candidate_id))
	button.mouse_entered.connect(_on_mouse_entered.bind(button))
	_trigger_candidate_layer.add_child(button)
	_trigger_candidate_buttons[candidate_id] = button


func _refresh_trigger_candidate_states() -> void:
	for candidate_id in _trigger_candidate_order:
		var button: Button = _trigger_candidate_buttons.get(candidate_id)
		if not is_instance_valid(button):
			continue
		var candidate: Dictionary = _trigger_candidate_records.get(candidate_id, {})
		var selected := candidate_id == _selected_trigger_bundle_id
		var focused := button.has_focus()
		button.text = _localized(candidate, "label")
		button.tooltip_text = _localized(candidate, "detail")
		button.disabled = _read_only
		button.focus_mode = Control.FOCUS_NONE if _read_only else Control.FOCUS_ALL
		UIStyle.override_font_size(button, "font_size", 11 if size.x < 1100.0 else 12)
		UIStyle.override_color(button, "font_color", COLOR_TEXT)
		UIStyle.override_color(button, "font_hover_color", COLOR_TEXT)
		UIStyle.override_color(button, "font_pressed_color", COLOR_TEXT)
		UIStyle.override_color(button, "font_focus_color", COLOR_TEXT)
		var base_background := Color("#222a32", 0.98) if selected else Color("#141a20", 0.98)
		var base_border := COLOR_ACCENT if selected else Color("#4b5660")
		UIStyle.override_stylebox(button,
			"normal", _panel_style(base_background, base_border, 2 if selected else 1, 4))
		UIStyle.override_stylebox(button,
			"hover", _panel_style(Color("#26313a", 0.99), COLOR_FOCUS, 2, 4))
		UIStyle.override_stylebox(button,
			"pressed", _panel_style(Color("#0b0f13", 0.99), COLOR_ACCENT, 3, 4))
		UIStyle.override_stylebox(button,
			"focus", _panel_style(Color.TRANSPARENT, COLOR_FOCUS, 3, 4))
		UIStyle.override_stylebox(button,
			"disabled", _panel_style(Color("#11161b", 0.90), Color("#394149"), 1, 4))
		button.set_meta("seoul_cycle_trigger_candidate_selected", selected)
		button.set_meta("seoul_cycle_trigger_candidate_focused", focused)
		button.set_meta("seoul_cycle_visual_state",
			_visual_state(selected, focused, button.disabled))


func _refresh_visual_states() -> void:
	var nodes: Dictionary = _snapshot.get("nodes", {})
	for node_id in _node_order:
		var button: Button = _node_buttons.get(node_id)
		if not is_instance_valid(button):
			continue
		var node_data: Dictionary = nodes.get(node_id, {})
		var unavailable := _node_unavailable_by_id(node_id)
		var interactive_unavailable := unavailable and not _read_only
		button.disabled = interactive_unavailable
		button.focus_mode = (
			Control.FOCUS_NONE if interactive_unavailable else Control.FOCUS_ALL)
		var selected := node_id == _selected_node_id
		var base_background := COLOR_PANEL_RAISED if selected else Color("#11161c", 0.93)
		var base_border := COLOR_ACCENT if selected else Color("#5a646e")
		UIStyle.override_stylebox(button,
			"normal", _panel_style(base_background, base_border, 2 if selected else 1, 6))
		UIStyle.override_stylebox(button,
			"hover", _panel_style(Color("#1e252c", 0.97), COLOR_FOCUS, 2, 6))
		UIStyle.override_stylebox(button,
			"pressed", _panel_style(Color("#0c1014", 0.98), COLOR_ACCENT, 3, 6))
		UIStyle.override_stylebox(button,
			"focus", _panel_style(Color.TRANSPARENT, COLOR_FOCUS, 3, 6))
		UIStyle.override_stylebox(button,
			"disabled", _panel_style(Color("#0c0f13", 0.88), Color("#343a40"), 1, 6))
		button.set_meta("seoul_cycle_selected", selected)
		button.set_meta("seoul_cycle_focused", button.has_focus())
		button.set_meta("seoul_cycle_visual_state", _visual_state(selected, button.has_focus(), unavailable))
		var node_preview := _preview_for(_selected_die_id, node_id)
		button.set_meta("seoul_cycle_trigger_selection_required",
			_trigger_selection_required(node_preview))
		button.set_meta("seoul_cycle_trigger_candidate_count",
			_trigger_candidates(node_preview).size())
		var overlay: Control = (_node_parts[node_id] as Dictionary).get("overlay")
		if is_instance_valid(overlay):
			overlay.queue_redraw()
	for die_id in _die_order:
		var button: Button = _die_buttons.get(die_id)
		if not is_instance_valid(button):
			continue
		var die := _die_data(die_id)
		var spent := bool(die.get("spent", false))
		var selected := die_id == _selected_die_id
		button.disabled = spent or _read_only
		var base_background := Color("#e1ded5", 0.96) if selected else Color("#c8c5bd", 0.91)
		var base_border := COLOR_ACCENT if selected else Color("#777870")
		UIStyle.override_stylebox(button,
			"normal", _panel_style(base_background, base_border, 3 if selected else 1, 4))
		UIStyle.override_stylebox(button,
			"hover", _panel_style(Color("#ece9e1", 0.98), COLOR_FOCUS, 2, 4))
		UIStyle.override_stylebox(button,
			"pressed", _panel_style(Color("#b8b4aa", 0.98), COLOR_ACCENT, 3, 4))
		UIStyle.override_stylebox(button,
			"focus", _panel_style(Color.TRANSPARENT, COLOR_FOCUS, 3, 4))
		UIStyle.override_stylebox(button,
			"disabled", _panel_style(Color("#4b4d4d", 0.75), Color("#64676a"), 1, 4))
		button.set_meta("seoul_cycle_selected", selected)
		button.set_meta("seoul_cycle_focused", button.has_focus())
		button.set_meta("seoul_cycle_visual_state", _visual_state(selected, button.has_focus(), spent))
		var parts: Dictionary = _die_parts[die_id]
		var overlay: Control = parts.get("overlay")
		if is_instance_valid(overlay):
			overlay.queue_redraw()


func _refresh_preview() -> void:
	var preview_node_id := _preview_node_id()
	var nodes: Dictionary = _snapshot.get("nodes", {})
	var node_data: Dictionary = nodes.get(preview_node_id, {})
	_error_label.visible = not _error_text.is_empty()
	_error_label.text = _error_text
	_preview_title_label.text = _tr("배치 미리보기", "ALLOCATION PREVIEW")
	if preview_node_id.is_empty() or node_data.is_empty():
		_preview_choice_label.text = _tr(
			"아래에서 이번 주 여력을 고른다.",
			"Choose this week's capacity below.")
		_preview_progress_label.text = _tr(
			"서울의 네 곳이 같은 시간을 기다린다.",
			"Four places are competing for the same week.")
		_preview_effect_label.text = _tr(
			"포커스를 옮겨도 선택은 바뀌지 않는다.",
			"Moving focus does not change your selection.")
		_preview_deadline_label.text = ""
		set_meta("seoul_cycle_preview_progress_delta", 0)
		set_meta("seoul_cycle_preview_node_id", "")
		_refresh_preview_geometry_if_ready()
		return
	var node_label := _localized(node_data, "label")
	var place_label := _localized(node_data, "place")
	if _selected_die_id.is_empty():
		_preview_choice_label.text = "%s\n%s" % [place_label, node_label]
		_preview_progress_label.text = _tr(
			"현재 클록 %d/%d",
			"CURRENT CLOCK %d/%d") % [
			int(node_data.get("progress", 0)),
			int(node_data.get("target", 1)),
		]
		_preview_effect_label.text = _tr(
			"여력을 먼저 고르면 정확한 진전과 대가가 열린다.",
			"Choose capacity to reveal the exact progress and cost.")
		_preview_deadline_label.text = _deadline_line(node_data, {})
		set_meta("seoul_cycle_preview_progress_delta", 0)
		set_meta("seoul_cycle_preview_node_id", preview_node_id)
		_refresh_preview_geometry_if_ready()
		return
	var die := _die_data(_selected_die_id)
	var preview := _preview_for(_selected_die_id, preview_node_id)
	var progress_delta := int(preview.get(
		"progress_delta",
		preview.get("progress", _base_progress(int(die.get("value", 0))))))
	var current_progress := int(preview.get(
		"progress_before", node_data.get("progress", 0)))
	var target: int = maxi(1, int(preview.get(
		"threshold", node_data.get("target", 1))))
	var after_progress: int = clampi(int(preview.get(
		"progress_after", current_progress + progress_delta)), 0, target)
	var pending_marker := "" if preview_node_id == _selected_node_id else _tr(
		" · 대상 확인 전",
		" · TARGET NOT LOCKED")
	_preview_choice_label.text = "%s %s → %s\n%s%s" % [
		_tr("여력", "CAPACITY"),
		str(int(die.get("value", 0))),
		place_label,
		node_label,
		pending_marker,
	]
	if bool(preview.get("fallback_allocation", false)):
		_preview_progress_label.text = _tr(
			"특별 기회를 놓친 뒤 일반 실행 · 클록 %d/%d 유지",
			"REGULAR ACTION AFTER MISSED CHANCE · CLOCK HOLDS %d/%d") % [
			current_progress, target]
	elif bool(preview.get("repeat_allocation", false)):
		_preview_progress_label.text = _tr(
			"완료 뒤 추가 실행 · 클록 %d/%d 유지",
			"ADDITIONAL RUN AFTER COMPLETION · CLOCK HOLDS %d/%d") % [
			current_progress, target]
	else:
		_preview_progress_label.text = _tr(
			"진전 +%d칸  ·  %d/%d → %d/%d",
			"+%d CLOCK  ·  %d/%d → %d/%d") % [
			progress_delta,
			current_progress,
			target,
			after_progress,
			target,
		]
	var summary := _localized(preview, "summary")
	var effect_line: String = _effect_line(preview.get("effects", node_data.get("effects", {})))
	_preview_effect_label.text = effect_line if summary.is_empty() else "%s\n%s" % [summary, effect_line]
	_preview_deadline_label.text = _deadline_line(node_data, preview)
	if _trigger_selection_required(preview):
		var candidate := _trigger_candidate_record_for_preview()
		var candidate_label := _localized(candidate, "label")
		var candidate_detail := _localized(candidate, "detail")
		if not candidate_label.is_empty():
			_preview_effect_label.text = "%s · %s\n%s" % [
				_tr("약속 설명", "THREAD DETAIL"),
				candidate_label,
				candidate_detail if not candidate_detail.is_empty() else effect_line,
			]
		# A rejection owns the scarce compact preview space until the player
		# retries; the focused candidate still exposes its detail as a tooltip.
		if _error_label.visible:
			_preview_effect_label.text = ""
		_preview_deadline_label.text = ""
	set_meta("seoul_cycle_preview_progress_delta", progress_delta)
	set_meta("seoul_cycle_preview_node_id", preview_node_id)
	set_meta("seoul_cycle_preview_after_progress", after_progress)
	set_meta("seoul_cycle_preview_deadline_week",
		int(preview.get("deadline_week", node_data.get("deadline_week", 0))))
	set_meta("seoul_cycle_preview_completed_now",
		bool(preview.get("completed_now", false)))
	set_meta("seoul_cycle_preview_selected_trigger_bundle_id",
		str(preview.get("selected_trigger_bundle_id", "")))
	set_meta("seoul_cycle_preview_selected_trigger_candidate_id",
		_trigger_preview_selected_candidate_id(preview))
	_refresh_preview_geometry_if_ready()


func _refresh_preview_geometry_if_ready() -> void:
	if not is_instance_valid(_preview_panel) \
			or _preview_panel.size.x <= 0.0 or _preview_panel.size.y <= 0.0:
		return
	_apply_preview_geometry(size.x < 1100.0 or size.y < 700.0)


func _refresh_commit_state() -> void:
	var preview := _preview_for(_selected_die_id, _selected_node_id)
	var trigger_required := _trigger_selection_required(preview)
	var trigger_selected := not trigger_required \
			or _selected_trigger_candidate_is_valid()
	var preview_valid := bool(preview.get("valid", true)) \
			or (str(preview.get("error", "")) == "trigger_selection_required" \
			and trigger_selected)
	var ready := not _read_only \
			and not _allocation_in_flight \
			and not _selected_die_id.is_empty() \
			and not _selected_node_id.is_empty() \
			and not bool(_die_data(_selected_die_id).get("spent", true)) \
			and _node_available_by_id(_selected_node_id) \
			and preview_valid \
			and trigger_selected
	_commit_button.disabled = not ready
	if _read_only:
		_commit_button.text = _tr("보기 전용", "READ ONLY")
	elif _allocation_in_flight:
		_commit_button.text = _tr("배치 적용 중…", "APPLYING…")
	elif _selected_die_id.is_empty():
		_commit_button.text = _tr("여력을 먼저 고른다", "CHOOSE CAPACITY FIRST")
	elif _selected_node_id.is_empty():
		_commit_button.text = _tr("장소를 선택한다", "CHOOSE A PLACE")
	elif trigger_required and _trigger_candidates(preview).is_empty():
		_commit_button.text = _tr("이어갈 약속이 없다", "NO THREAD TO FOLLOW")
	elif trigger_required and not trigger_selected:
		_commit_button.text = _tr("이어갈 약속을 고른다", "CHOOSE A THREAD")
	elif not preview_valid:
		_commit_button.text = _localized(preview, "reason")
	else:
		_commit_button.text = _tr("이번 주를 여기에 쓴다", "COMMIT THIS WEEK HERE")
	_apply_commit_style(ready)
	_commit_button.set_meta("seoul_cycle_commit_enabled", ready)
	set_meta("seoul_cycle_commit_enabled", ready)
	set_meta("seoul_cycle_allocation_in_flight", _allocation_in_flight)


func _refresh_world_clock() -> void:
	var current: int = maxi(0, int(_snapshot.get("world_clock", 0)))
	var maximum: int = maxi(1, int(_snapshot.get("world_clock_max", 4)))
	current = mini(current, maximum)
	_world_clock_label.text = _tr(
		"도시 시간 %d/%d",
		"CITY CLOCK %d/%d") % [current, maximum]
	for child in _world_clock_segments.get_children():
		child.free()
	for segment_index in range(maximum):
		var segment := Panel.new()
		segment.name = "WorldClockSegment%02d" % (segment_index + 1)
		segment.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		segment.mouse_filter = Control.MOUSE_FILTER_IGNORE
		segment.set_meta("seoul_cycle_world_clock_segment", segment_index + 1)
		segment.set_meta("filled", segment_index < current)
		UIStyle.override_stylebox(segment, "panel", _panel_style(
			COLOR_ACCENT if segment_index < current else Color("#252b31"),
			COLOR_ACCENT if segment_index < current else Color("#5b646d"),
			1,
			1))
		_world_clock_segments.add_child(segment)
	set_meta("seoul_cycle_world_clock", current)
	set_meta("seoul_cycle_world_clock_max", maximum)


func _refresh_hint() -> void:
	_effort_hint_label.text = (
		_tr(
			"방향키/스틱 이동\n[%s] 선택·확정\n[%s] 닫기",
			"D-PAD / STICK MOVE\n[%s] SELECT / COMMIT\n[%s] CLOSE")
		if _read_only else
		_tr(
			"방향키/스틱 이동\n[%s] 선택·확정\n[%s] 선택 해제",
			"D-PAD / STICK MOVE\n[%s] SELECT / COMMIT\n[%s] UNDO SELECTION")
	) % [ControllerHints.south(), ControllerHints.east()]


func _on_die_pressed(die_id: String) -> void:
	if _read_only or _allocation_in_flight:
		return
	var die := _die_data(die_id)
	if die.is_empty() or bool(die.get("spent", true)):
		return
	_error_text = ""
	if _selected_die_id == die_id:
		_selected_die_id = ""
		_selected_node_id = ""
		_selected_trigger_bundle_id = ""
		AudioManager.play_ui_close(-13.0)
	else:
		_selected_die_id = die_id
		_selected_node_id = ""
		_selected_trigger_bundle_id = ""
		AudioManager.play("click", -10.0)
	_refresh_surface()
	_focus_first_available_node()


func _on_node_pressed(node_id: String) -> void:
	if _allocation_in_flight or not _node_buttons.has(node_id):
		return
	_inspected_node_id = node_id
	if _read_only:
		_refresh_preview()
		return
	if _selected_die_id.is_empty():
		_error_text = _tr(
			"아래에서 이번 주 여력을 먼저 고른다.",
			"Choose this week's capacity below first.")
		AudioManager.play_ui_close(-15.0)
		_refresh_preview()
		_refresh_commit_state()
		_focus_first_available_die()
		return
	if not _node_available_by_id(node_id):
		return
	_error_text = ""
	if _selected_node_id == node_id:
		_selected_node_id = ""
	else:
		_selected_node_id = node_id
	_selected_trigger_bundle_id = ""
	AudioManager.play("click", -10.0)
	_refresh_surface()
	if _selected_node_requires_trigger_choice():
		_focus_first_trigger_candidate()
	elif not _selected_node_id.is_empty() and not _commit_button.disabled:
		_commit_button.grab_focus()


func _on_trigger_candidate_pressed(candidate_id: String) -> void:
	if _read_only or _allocation_in_flight \
			or not _trigger_candidate_panel.visible \
			or not _trigger_candidate_records.has(candidate_id):
		return
	_error_text = ""
	_selected_trigger_bundle_id = candidate_id
	AudioManager.play("click", -10.0)
	_refresh_surface()
	if not _commit_button.disabled:
		_commit_button.grab_focus()


func _on_commit_pressed() -> void:
	if _commit_button.disabled or _allocation_in_flight:
		return
	var preview := _preview_for(_selected_die_id, _selected_node_id)
	var preview_valid := bool(preview.get("valid", true)) \
			or (str(preview.get("error", "")) == "trigger_selection_required" \
			and _selected_trigger_candidate_is_valid())
	if not preview_valid or (_trigger_selection_required(preview) \
			and not _selected_trigger_candidate_is_valid()):
		return
	_allocation_in_flight = true
	_error_text = ""
	_refresh_commit_state()
	AudioManager.play("choice_made", -7.0)
	allocation_requested.emit(
		_selected_die_id, _selected_node_id, _selected_trigger_bundle_id)


func _cancel_or_close() -> void:
	if _allocation_in_flight:
		return
	if not _selected_trigger_bundle_id.is_empty():
		var return_candidate := _selected_trigger_bundle_id
		_selected_trigger_bundle_id = ""
		_error_text = ""
		AudioManager.play_ui_close(-13.0)
		_refresh_surface()
		var candidate_button: Button = _trigger_candidate_buttons.get(return_candidate)
		if is_instance_valid(candidate_button) and not candidate_button.disabled:
			candidate_button.grab_focus()
		return
	if not _selected_node_id.is_empty():
		var return_node := _selected_node_id
		_selected_node_id = ""
		_selected_trigger_bundle_id = ""
		_error_text = ""
		AudioManager.play_ui_close(-13.0)
		_refresh_surface()
		var node_button: Button = _node_buttons.get(return_node)
		if is_instance_valid(node_button) and not node_button.disabled:
			node_button.grab_focus()
		return
	if not _selected_die_id.is_empty():
		var return_die := _selected_die_id
		_selected_die_id = ""
		_selected_trigger_bundle_id = ""
		_error_text = ""
		AudioManager.play_ui_close(-13.0)
		_refresh_surface()
		var die_button: Button = _die_buttons.get(return_die)
		if is_instance_valid(die_button) and not die_button.disabled:
			die_button.grab_focus()
		return
	if _read_only:
		close()
		return
	# An uncommitted week cannot be dismissed into the ordinary HUD, where the
	# generic Next Week command could otherwise bypass its calendar owner.
	_error_text = _tr(
		"이번 주를 어디에 쓸지 먼저 정해야 한다.",
		"Choose where this week goes before leaving.")
	set_meta("seoul_cycle_close_blocked", true)
	AudioManager.play_ui_close(-15.0)
	_refresh_preview()
	_focus_first_available_die()


func _on_focus_entered(group: String, item_id: String) -> void:
	_focused_group = group
	_focused_id = item_id
	if group == "node":
		_inspected_node_id = item_id
	set_meta("seoul_cycle_focus_group", group)
	set_meta("seoul_cycle_focus_id", item_id)
	set_meta("seoul_cycle_trigger_candidate_focus_id",
		item_id if group == "candidate" else "")
	_refresh_visual_states()
	_refresh_trigger_candidate_states()
	_refresh_preview()
	if group == "candidate":
		call_deferred("_ensure_trigger_candidate_visible", item_id)


func _on_focus_exited(group: String, item_id: String) -> void:
	if _rebuilding_entities:
		return
	if _focused_group == group and _focused_id == item_id:
		_focused_group = ""
		_focused_id = ""
		set_meta("seoul_cycle_focus_group", "")
		set_meta("seoul_cycle_focus_id", "")
		set_meta("seoul_cycle_trigger_candidate_focus_id", "")
	_refresh_visual_states()
	_refresh_trigger_candidate_states()


func _on_mouse_entered(button: Button) -> void:
	if visible and not button.disabled:
		button.grab_focus()


func _on_language_changed(_language: String = "") -> void:
	if visible:
		_refresh_surface()
		_apply_geometry()


func _on_input_mode_changed(_mode: int, _brand: int) -> void:
	if visible:
		_refresh_hint()


func _focus_after_open(generation: int) -> void:
	if generation != _open_generation or not visible:
		return
	if _selected_node_requires_trigger_choice() \
			and not _selected_trigger_candidate_is_valid():
		_focus_first_trigger_candidate()
	elif not _selected_node_id.is_empty() and not _commit_button.disabled:
		_commit_button.grab_focus()
	elif not _selected_die_id.is_empty():
		_focus_first_available_node()
	else:
		_focus_first_available_die()


func _restore_focus_after_refresh(
		generation: int,
		group: String,
		item_id: String) -> void:
	if generation != _open_generation or not visible:
		return
	var target: Button
	match group:
		"die":
			target = _die_buttons.get(item_id)
		"node":
			target = _node_buttons.get(item_id)
		"candidate":
			target = _trigger_candidate_buttons.get(item_id)
		"commit":
			target = _commit_button
	if is_instance_valid(target) and not target.disabled:
		target.grab_focus()
	else:
		_focus_after_open(generation)


func _focus_first_available_die() -> void:
	for die_id in _die_order:
		var button: Button = _die_buttons.get(die_id)
		if is_instance_valid(button) and not button.disabled:
			button.grab_focus()
			return
	_focus_first_available_node()


func _focus_first_available_node() -> void:
	for node_id in _node_order:
		var button: Button = _node_buttons.get(node_id)
		if is_instance_valid(button) and not button.disabled:
			button.grab_focus()
			return
	if not _commit_button.disabled:
		_commit_button.grab_focus()


func _focus_first_trigger_candidate() -> void:
	for candidate_id in _trigger_candidate_order:
		var button: Button = _trigger_candidate_buttons.get(candidate_id)
		if is_instance_valid(button) and not button.disabled and button.visible:
			button.grab_focus()
			return


func _ensure_trigger_candidate_visible(candidate_id: String) -> void:
	if not visible or not is_instance_valid(_trigger_candidate_scroll) \
			or not _trigger_candidate_panel.visible:
		return
	var button: Button = _trigger_candidate_buttons.get(candidate_id)
	if not is_instance_valid(button) or not button.has_focus():
		return
	_trigger_candidate_scroll.ensure_control_visible(button)
	set_meta("seoul_cycle_trigger_candidate_scroll_offset",
		_trigger_candidate_scroll.scroll_vertical)


func _connect_focus_neighbors() -> void:
	if _node_order.size() != NODE_COUNT or _die_order.size() != EFFORT_COUNT:
		return
	var node_buttons: Array[Button] = []
	for node_id in _node_order:
		node_buttons.append(_node_buttons.get(node_id) as Button)
	var die_buttons: Array[Button] = []
	for die_id in _die_order:
		die_buttons.append(_die_buttons.get(die_id) as Button)
	# Spatial 2x2 node board. Bottom nodes lead directly to the matching half
	# of the physical effort rail; the upper-right path reaches commit.
	_set_neighbors(node_buttons[0], node_buttons[0], node_buttons[1], node_buttons[0], node_buttons[2])
	_set_neighbors(node_buttons[1], node_buttons[0], _commit_button, node_buttons[1], node_buttons[3])
	_set_neighbors(node_buttons[2], node_buttons[2], node_buttons[3], node_buttons[0], die_buttons[0])
	_set_neighbors(node_buttons[3], node_buttons[2], _commit_button, node_buttons[1], die_buttons[3])
	_set_neighbors(die_buttons[0], die_buttons[0], die_buttons[1], node_buttons[2], die_buttons[0])
	_set_neighbors(die_buttons[1], die_buttons[0], die_buttons[2], node_buttons[2], die_buttons[1])
	_set_neighbors(die_buttons[2], die_buttons[1], die_buttons[3], node_buttons[3], die_buttons[2])
	_set_neighbors(die_buttons[3], die_buttons[2], die_buttons[3], node_buttons[3], die_buttons[3])
	_set_neighbors(_commit_button, node_buttons[1], _commit_button, node_buttons[1], node_buttons[3])
	var candidate_buttons: Array[Button] = []
	if _trigger_candidate_panel.visible:
		for candidate_id in _trigger_candidate_order:
			var candidate_button: Button = _trigger_candidate_buttons.get(candidate_id)
			if is_instance_valid(candidate_button):
				candidate_buttons.append(candidate_button)
	if not candidate_buttons.is_empty():
		var source_node: Button = _node_buttons.get(_selected_node_id)
		if not is_instance_valid(source_node):
			source_node = node_buttons[1]
		for candidate_index in range(candidate_buttons.size()):
			var candidate_button := candidate_buttons[candidate_index]
			var previous_button: Button = (
				source_node if candidate_index == 0 else candidate_buttons[candidate_index - 1])
			var next_button: Button = (
				_commit_button if candidate_index == candidate_buttons.size() - 1
				else candidate_buttons[candidate_index + 1])
			_set_neighbors(
				candidate_button,
				source_node,
				_commit_button,
				previous_button,
				next_button)
			candidate_button.focus_previous = candidate_button.get_path_to(
				previous_button)
			candidate_button.focus_next = candidate_button.get_path_to(next_button)
		source_node.focus_neighbor_right = source_node.get_path_to(candidate_buttons[0])
		source_node.focus_next = source_node.get_path_to(candidate_buttons[0])
		_commit_button.focus_neighbor_left = _commit_button.get_path_to(candidate_buttons[-1])
		_commit_button.focus_neighbor_top = _commit_button.get_path_to(candidate_buttons[-1])
		_commit_button.focus_previous = _commit_button.get_path_to(candidate_buttons[-1])
	var neighbor_meta: Dictionary = {}
	for button in node_buttons + die_buttons + candidate_buttons + [_commit_button]:
		neighbor_meta[button.name] = {
			"left": str(button.focus_neighbor_left),
			"right": str(button.focus_neighbor_right),
			"up": str(button.focus_neighbor_top),
			"down": str(button.focus_neighbor_bottom),
		}
	set_meta("seoul_cycle_focus_neighbors", neighbor_meta)


func _set_neighbors(
		button: Button,
		left: Button,
		right: Button,
		up: Button,
		down: Button) -> void:
	button.focus_neighbor_left = button.get_path_to(left)
	button.focus_neighbor_right = button.get_path_to(right)
	button.focus_neighbor_top = button.get_path_to(up)
	button.focus_neighbor_bottom = button.get_path_to(down)
	button.focus_next = button.get_path_to(right)
	button.focus_previous = button.get_path_to(left)


func _apply_geometry() -> void:
	if not is_instance_valid(_header_panel):
		return
	set_meta("seoul_cycle_viewport_size", Vector2i(roundi(size.x), roundi(size.y)))
	var compact := size.x < 1100.0 or size.y < 700.0
	var margin := 12.0 if compact else 22.0
	var gap := 10.0 if compact else 14.0
	var header_height := 74.0 if compact else 90.0
	var effort_height := 124.0 if compact else 146.0
	# Candidate detail is a player-owned promise, not a tooltip-only appendix.
	# Keep enough width for the longest authored EN line at the 960x600 floor.
	var preview_width := 340.0
	_header_panel.position = Vector2(margin, margin)
	_header_panel.size = Vector2(maxf(0.0, size.x - margin * 2.0), header_height)
	_effort_panel.position = Vector2(margin, size.y - margin - effort_height)
	_effort_panel.size = Vector2(maxf(0.0, size.x - margin * 2.0), effort_height)
	var content_top := margin + header_height + gap
	var content_bottom := _effort_panel.position.y - gap
	var content_height := maxf(0.0, content_bottom - content_top)
	_preview_panel.position = Vector2(size.x - margin - preview_width, content_top)
	_preview_panel.size = Vector2(preview_width, content_height)
	_map_panel.position = Vector2(margin, content_top)
	_map_panel.size = Vector2(
		maxf(0.0, _preview_panel.position.x - gap - margin),
		content_height)
	_apply_header_geometry(compact)
	_apply_map_geometry(compact)
	_apply_preview_geometry(compact)
	_apply_effort_geometry(compact)
	_route_layer.queue_redraw()


func _apply_header_geometry(compact: bool) -> void:
	var panel_width := _header_panel.size.x
	var stats_start := 306.0 if compact else 430.0
	var close_width := 42.0
	var stat_gap := 7.0
	var available_stats := maxf(0.0, panel_width - stats_start - close_width - 28.0)
	var stat_width := maxf(92.0, (available_stats - stat_gap * 2.0) / 3.0)
	_title_label.position = Vector2(16.0, 7.0)
	_title_label.size = Vector2(stats_start - 24.0, 34.0)
	UIStyle.override_font_size(_title_label, "font_size", 23 if compact else 28)
	_time_label.position = Vector2(17.0, 40.0 if compact else 48.0)
	_time_label.size = Vector2(stats_start - 24.0, 23.0)
	UIStyle.override_font_size(_time_label, "font_size", 13 if compact else 14)
	for index in range(3):
		var label: Label = [_money_label, _health_label, _mental_label][index]
		label.position = Vector2(stats_start + index * (stat_width + stat_gap), 17.0)
		label.size = Vector2(stat_width, _header_height_for_label(compact))
		UIStyle.override_font_size(label, "font_size", 13 if compact else 15)
	_close_button.position = Vector2(panel_width - close_width - 7.0, 6.0)
	_close_button.size = Vector2(close_width, close_width)
	UIStyle.override_font_size(_close_button, "font_size", 28)


func _header_height_for_label(compact: bool) -> float:
	return 42.0 if compact else 50.0


func _apply_map_geometry(compact: bool) -> void:
	var inner_margin := 12.0 if compact else 17.0
	_map_title_label.position = Vector2(inner_margin, 8.0)
	_map_title_label.size = Vector2(_map_panel.size.x * 0.55, 26.0)
	UIStyle.override_font_size(_map_title_label, "font_size", 16 if compact else 19)
	_map_subtitle_label.position = Vector2(_map_panel.size.x * 0.48, 10.0)
	_map_subtitle_label.size = Vector2(
		maxf(0.0, _map_panel.size.x * 0.31 - inner_margin),
		22.0)
	UIStyle.override_font_size(_map_subtitle_label, "font_size", 11 if compact else 12)
	_world_clock_label.position = Vector2(_map_panel.size.x - 170.0, 7.0)
	_world_clock_label.size = Vector2(153.0, 18.0)
	UIStyle.override_font_size(_world_clock_label, "font_size", 11)
	_world_clock_segments.position = Vector2(_map_panel.size.x - 151.0, 26.0)
	_world_clock_segments.size = Vector2(134.0, 7.0)
	var layer_top := 37.0 if compact else 42.0
	_route_layer.position = Vector2(inner_margin, layer_top)
	_route_layer.size = Vector2(
		maxf(0.0, _map_panel.size.x - inner_margin * 2.0),
		maxf(0.0, _map_panel.size.y - layer_top - inner_margin))
	_node_layer.position = _route_layer.position
	_node_layer.size = _route_layer.size
	var node_width := clampf(_node_layer.size.x * 0.36, 184.0, 270.0)
	var node_height := 108.0 if compact else 126.0
	var left_x := 8.0
	var right_x := maxf(left_x, _node_layer.size.x - node_width - 8.0)
	var top_y := 9.0
	var bottom_y := maxf(top_y, _node_layer.size.y - node_height - 9.0)
	var positions := [
		Vector2(left_x, top_y + (12.0 if not compact else 7.0)),
		Vector2(right_x, top_y),
		Vector2(left_x + _node_layer.size.x * 0.08, bottom_y),
		Vector2(right_x - _node_layer.size.x * 0.04, bottom_y - (10.0 if not compact else 5.0)),
	]
	for index in range(_node_order.size()):
		var node_id := _node_order[index]
		var button: Button = _node_buttons.get(node_id)
		if not is_instance_valid(button):
			continue
		button.position = positions[index]
		button.size = Vector2(node_width, node_height)
		var parts: Dictionary = _node_parts[node_id]
		var place: Label = parts.get("place")
		var title: Label = parts.get("title")
		var status: Label = parts.get("status")
		var clock: HBoxContainer = parts.get("clock")
		place.position = Vector2(15.0, 10.0)
		place.size = Vector2(node_width - 30.0, 18.0)
		UIStyle.override_font_size(place, "font_size", 11)
		title.position = Vector2(15.0, 29.0)
		title.size = Vector2(node_width - 30.0, 27.0)
		UIStyle.override_font_size(title, "font_size", 16 if compact else 18)
		status.position = Vector2(15.0, 57.0)
		status.size = Vector2(node_width - 30.0, 20.0)
		UIStyle.override_font_size(status, "font_size", 11 if compact else 12)
		clock.position = Vector2(15.0, node_height - 24.0)
		clock.size = Vector2(node_width - 30.0, 10.0)


func _apply_preview_geometry(compact: bool) -> void:
	var width := _preview_panel.size.x
	var height := _preview_panel.size.y
	var pad := 15.0 if compact else 18.0
	var inner_width := maxf(0.0, width - pad * 2.0)
	_preview_title_label.position = Vector2(pad, 12.0)
	_preview_title_label.size = Vector2(inner_width, 25.0)
	UIStyle.override_font_size(_preview_title_label, "font_size", 15 if compact else 17)
	var commit_height := 54.0 if compact else 62.0
	_commit_button.position = Vector2(pad, height - pad - commit_height)
	_commit_button.size = Vector2(inner_width, commit_height)
	UIStyle.override_font_size(_commit_button, "font_size", 14 if compact else 15)

	UIStyle.override_font_size(_preview_choice_label, "font_size", 15 if compact else 17)
	UIStyle.override_font_size(_preview_progress_label, "font_size", 14 if compact else 16)
	UIStyle.override_font_size(_preview_effect_label, "font_size", 12 if compact else 14)
	UIStyle.override_font_size(_preview_deadline_label, "font_size", 12 if compact else 13)
	UIStyle.override_font_size(_error_label, "font_size", 12 if compact else 13)
	UIStyle.override_font_size(_trigger_candidate_title_label, "font_size", 10 if compact else 11)
	for label in [
		_preview_choice_label,
		_preview_progress_label,
		_preview_effect_label,
		_preview_deadline_label,
		_error_label,
	]:
		label.size = Vector2(inner_width, 1.0)

	var row_gap := 4.0 if compact else 7.0
	var error_height := 0.0
	var content_bottom := _commit_button.position.y - row_gap
	if _error_label.visible and not _error_label.text.is_empty():
		error_height = _preview_label_required_height(_error_label, 30.0)
		_error_label.position = Vector2(
			pad, _commit_button.position.y - row_gap - error_height)
		_error_label.size = Vector2(inner_width, error_height)
		content_bottom = _error_label.position.y - row_gap
	else:
		_error_label.position = Vector2(pad, _commit_button.position.y)
		_error_label.size = Vector2(inner_width, 0.0)

	var leading_rows: Array[Label] = [
		_preview_choice_label,
		_preview_progress_label,
	]
	var trailing_rows: Array[Label] = [
		_preview_effect_label,
		_preview_deadline_label,
	]
	var leading_minimums := [30.0, 22.0]
	var trailing_minimums := [30.0, 18.0]
	var cursor_y := 44.0
	var visible_row_count := 0
	for index in range(leading_rows.size()):
		var label := leading_rows[index]
		var row_height := _preview_label_required_height(
			label, leading_minimums[index])
		if row_height <= 0.0:
			label.position = Vector2(pad, cursor_y)
			label.size = Vector2(inner_width, 0.0)
			continue
		if visible_row_count > 0:
			cursor_y += row_gap
		label.position = Vector2(pad, cursor_y)
		label.size = Vector2(inner_width, row_height)
		cursor_y += row_height
		visible_row_count += 1

	var candidate_panel_height := 0.0
	var candidate_button_height := 36.0 if compact else 42.0
	var candidate_gap := 3.0 if compact else 4.0
	var candidate_visible_rows := 0
	var candidate_content_height := 0.0
	if _trigger_candidate_panel.visible and not _trigger_candidate_order.is_empty():
		if visible_row_count > 0:
			cursor_y += maxf(3.0, row_gap - 2.0)
		var candidate_panel_pad := 4.0
		var candidate_title_height := 16.0
		var candidate_title_gap := 3.0
		# The decision prose and Commit stay fixed below the chooser. Wider output
		# adds breathing room, not extra rows that push either surface out of view.
		candidate_visible_rows = mini(
			_trigger_candidate_order.size(),
			TRIGGER_CANDIDATE_VISIBLE_ROWS)
		candidate_content_height = candidate_button_height \
				* _trigger_candidate_order.size() \
				+ candidate_gap * maxi(0, _trigger_candidate_order.size() - 1)
		var candidate_viewport_height := candidate_button_height \
				* candidate_visible_rows \
				+ candidate_gap * maxi(0, candidate_visible_rows - 1)
		candidate_panel_height = candidate_panel_pad + candidate_title_height \
				+ candidate_title_gap \
				+ candidate_viewport_height \
				+ candidate_panel_pad
		_trigger_candidate_panel.position = Vector2(pad, cursor_y)
		_trigger_candidate_panel.size = Vector2(inner_width, candidate_panel_height)
		_trigger_candidate_title_label.position = Vector2(7.0, 3.0)
		_trigger_candidate_title_label.size = Vector2(
			maxf(0.0, inner_width - 14.0), candidate_title_height)
		_trigger_candidate_scroll.position = Vector2(
			7.0, candidate_panel_pad + candidate_title_height \
				+ candidate_title_gap)
		_trigger_candidate_scroll.size = Vector2(
			maxf(0.0, inner_width - 14.0), candidate_viewport_height)
		var scrollbar_width := 0.0
		if _trigger_candidate_order.size() > candidate_visible_rows:
			scrollbar_width = ceilf(
				_trigger_candidate_scroll.get_v_scroll_bar() \
					.get_combined_minimum_size().x)
		var candidate_content_width := maxf(
			0.0, _trigger_candidate_scroll.size.x - scrollbar_width)
		_trigger_candidate_layer.custom_minimum_size = Vector2(
			candidate_content_width, candidate_content_height)
		_trigger_candidate_layer.size = _trigger_candidate_layer.custom_minimum_size
		for candidate_index in range(_trigger_candidate_order.size()):
			var candidate_id := _trigger_candidate_order[candidate_index]
			var candidate_button: Button = _trigger_candidate_buttons.get(candidate_id)
			if not is_instance_valid(candidate_button):
				continue
			candidate_button.position = Vector2(
				0.0, candidate_index * (candidate_button_height + candidate_gap))
			candidate_button.size = Vector2(
				candidate_content_width, candidate_button_height)
			UIStyle.override_font_size(
				candidate_button, "font_size", 11 if compact else 12)
		cursor_y += candidate_panel_height
		visible_row_count += 1
	else:
		_trigger_candidate_panel.position = Vector2(pad, cursor_y)
		_trigger_candidate_panel.size = Vector2(inner_width, 0.0)
		_trigger_candidate_scroll.position = Vector2.ZERO
		_trigger_candidate_scroll.size = Vector2.ZERO
		_trigger_candidate_layer.custom_minimum_size = Vector2.ZERO
		_trigger_candidate_layer.size = Vector2.ZERO

	for index in range(trailing_rows.size()):
		var label := trailing_rows[index]
		var row_height := _preview_label_required_height(
			label, trailing_minimums[index])
		if row_height <= 0.0:
			label.position = Vector2(pad, cursor_y)
			label.size = Vector2(inner_width, 0.0)
			continue
		if visible_row_count > 0:
			cursor_y += row_gap
		label.position = Vector2(pad, cursor_y)
		label.size = Vector2(inner_width, row_height)
		cursor_y += row_height
		visible_row_count += 1
	set_meta("seoul_cycle_preview_layout_clearance", content_bottom - cursor_y)
	set_meta("seoul_cycle_trigger_candidate_panel_height", candidate_panel_height)
	set_meta("seoul_cycle_trigger_candidate_visible_rows", candidate_visible_rows)
	set_meta("seoul_cycle_trigger_candidate_scroll_viewport_rect",
		Rect2(_trigger_candidate_scroll.global_position,
			_trigger_candidate_scroll.size))
	set_meta("seoul_cycle_trigger_candidate_content_height", candidate_content_height)
	set_meta("seoul_cycle_trigger_candidate_scroll_vertical",
		candidate_content_height > _trigger_candidate_scroll.size.y)
	set_meta("seoul_cycle_trigger_candidate_scroll_offset",
		_trigger_candidate_scroll.scroll_vertical)
	set_meta("seoul_cycle_preview_choice_font_size",
		_preview_choice_label.get_theme_font_size("font_size"))
	set_meta("seoul_cycle_preview_error_height", error_height)


func _preview_label_required_height(label: Label, minimum_height: float) -> float:
	if not is_instance_valid(label) or label.text.is_empty():
		return 0.0
	return maxf(minimum_height, ceilf(label.get_combined_minimum_size().y))


func _apply_effort_geometry(compact: bool) -> void:
	var width := _effort_panel.size.x
	var height := _effort_panel.size.y
	var pad := 13.0 if compact else 17.0
	var hint_width := 236.0 if compact else 286.0
	var tile_gap := 7.0 if compact else 10.0
	var tile_area_width := maxf(0.0, width - pad * 3.0 - hint_width)
	var tile_width := maxf(0.0, (tile_area_width - tile_gap * 3.0) / 4.0)
	_effort_title_label.position = Vector2(pad, 7.0)
	_effort_title_label.size = Vector2(tile_area_width, 23.0)
	UIStyle.override_font_size(_effort_title_label, "font_size", 13 if compact else 15)
	var tile_top := 33.0 if compact else 38.0
	var tile_height := height - tile_top - pad
	for index in range(_die_order.size()):
		var die_id := _die_order[index]
		var button: Button = _die_buttons.get(die_id)
		if not is_instance_valid(button):
			continue
		button.position = Vector2(pad + index * (tile_width + tile_gap), tile_top)
		button.size = Vector2(tile_width, tile_height)
		var parts: Dictionary = _die_parts[die_id]
		var week: Label = parts.get("week")
		var value: Label = parts.get("value")
		var detail: Label = parts.get("detail")
		week.position = Vector2(12.0, 7.0)
		week.size = Vector2(maxf(0.0, tile_width - 24.0), 17.0)
		UIStyle.override_font_size(week, "font_size", 11)
		value.position = Vector2(9.0, 18.0)
		value.size = Vector2(48.0, tile_height - 22.0)
		UIStyle.override_font_size(value, "font_size", 25 if compact else 31)
		detail.position = Vector2(57.0, 27.0)
		detail.size = Vector2(maxf(0.0, tile_width - 66.0), 25.0)
		UIStyle.override_font_size(detail, "font_size", 11)
	_effort_hint_label.position = Vector2(width - pad - hint_width, 26.0)
	_effort_hint_label.size = Vector2(hint_width, height - 40.0)
	UIStyle.override_font_size(_effort_hint_label, "font_size", 11 if compact else 12)


func _draw_routes() -> void:
	if _node_order.size() != NODE_COUNT:
		return
	var centers := PackedVector2Array()
	for node_id in _node_order:
		var button: Button = _node_buttons.get(node_id)
		if not is_instance_valid(button):
			return
		centers.append(button.position + button.size * 0.5)
	var hub := (centers[0] + centers[1] + centers[2] + centers[3]) * 0.25
	for point in centers:
		_route_layer.draw_line(point, hub, Color("#020304", 0.88), 8.0, true)
		_route_layer.draw_line(point, hub, COLOR_ROUTE, 2.0, true)
		_route_layer.draw_circle(point, 7.0, Color("#0a0d11"))
		_route_layer.draw_arc(point, 7.0, 0.0, TAU, 24, COLOR_ACCENT, 2.0, true)
	_route_layer.draw_circle(hub, 10.0, Color("#0a0d11"))
	_route_layer.draw_arc(hub, 10.0, 0.0, TAU, 28, COLOR_ROUTE, 2.0, true)
	if not _selected_node_id.is_empty() and _node_buttons.has(_selected_node_id):
		var selected_button: Button = _node_buttons[_selected_node_id]
		var selected_point := selected_button.position + selected_button.size * 0.5
		_route_layer.draw_line(hub, selected_point, COLOR_ACCENT, 4.0, true)


func _draw_node_overlay(button: Button, overlay: Control) -> void:
	var selected := bool(button.get_meta("seoul_cycle_selected", false))
	var focused := button.has_focus()
	if selected:
		overlay.draw_rect(Rect2(7.0, 7.0, 4.0, maxf(0.0, overlay.size.y - 14.0)), COLOR_ACCENT)
	if focused:
		var corner := 12.0
		var inset := 5.0
		var right := overlay.size.x - inset
		var bottom := overlay.size.y - inset
		for pair in [
			[Vector2(inset, inset + corner), Vector2(inset, inset), Vector2(inset + corner, inset)],
			[Vector2(right - corner, inset), Vector2(right, inset), Vector2(right, inset + corner)],
			[Vector2(inset, bottom - corner), Vector2(inset, bottom), Vector2(inset + corner, bottom)],
			[Vector2(right - corner, bottom), Vector2(right, bottom), Vector2(right, bottom - corner)],
		]:
			var points := PackedVector2Array(pair)
			overlay.draw_polyline(points, COLOR_FOCUS, 2.0, true)


func _draw_effort_overlay(button: Button, overlay: Control) -> void:
	var spent := bool(button.get_meta("seoul_cycle_die_spent", false))
	var selected := bool(button.get_meta("seoul_cycle_selected", false))
	var notch_color := Color("#0b0e12")
	overlay.draw_circle(Vector2(0.0, overlay.size.y * 0.5), 5.0, notch_color)
	overlay.draw_circle(Vector2(overlay.size.x, overlay.size.y * 0.5), 5.0, notch_color)
	var dash_x := 51.0
	var y := 9.0
	while y < overlay.size.y - 8.0:
		overlay.draw_line(Vector2(dash_x, y), Vector2(dash_x, minf(y + 4.0, overlay.size.y - 8.0)), Color("#666860", 0.78), 1.0)
		y += 8.0
	if selected:
		overlay.draw_rect(Rect2(6.0, 6.0, 3.0, maxf(0.0, overlay.size.y - 12.0)), COLOR_ACCENT)
	if spent:
		overlay.draw_line(
			Vector2(8.0, overlay.size.y * 0.5),
			Vector2(overlay.size.x - 8.0, overlay.size.y * 0.5),
			Color("#9aa0a4", 0.62),
			2.0,
			true)


func _restore_snapshot_selection(force_clear: bool) -> void:
	var old_die := _selected_die_id
	var old_node := _selected_node_id
	if force_clear:
		_selected_die_id = ""
		_selected_node_id = ""
		_selected_trigger_bundle_id = ""
	var raw_selected: Variant = _snapshot.get("selected", {})
	if raw_selected is Dictionary:
		var selected: Dictionary = raw_selected
		_selected_die_id = str(selected.get(
			"die_id",
			selected.get("capacity_id", selected.get("die", _selected_die_id))))
		_selected_node_id = str(selected.get("node_id", selected.get("node", _selected_node_id)))
	elif raw_selected is String:
		_selected_die_id = str(raw_selected)
	_selected_die_id = str(_snapshot.get("selected_die_id", _selected_die_id))
	_selected_node_id = str(_snapshot.get("selected_node_id", _selected_node_id))
	if not force_clear and _selected_die_id.is_empty():
		_selected_die_id = old_die
	if not force_clear and _selected_node_id.is_empty():
		_selected_node_id = old_node
	if _die_data(_selected_die_id).is_empty() \
			or bool(_die_data(_selected_die_id).get("spent", true)):
		_selected_die_id = ""
		_selected_node_id = ""
		_selected_trigger_bundle_id = ""
	if not _node_available_by_id(_selected_node_id):
		_selected_node_id = ""
		_selected_trigger_bundle_id = ""
	var restored_preview := _preview_for(_selected_die_id, _selected_node_id)
	var restored_candidate_ids: Array[String] = []
	for candidate in _trigger_candidates(restored_preview):
		restored_candidate_ids.append(str(candidate.get("id", "")))
	if not _trigger_selection_required(restored_preview) \
			or not restored_candidate_ids.has(_selected_trigger_bundle_id):
		_selected_trigger_bundle_id = ""
	_inspected_node_id = _selected_node_id


func _preview_for(die_id: String, node_id: String) -> Dictionary:
	if die_id.is_empty() or node_id.is_empty():
		return {}
	var raw_previews: Variant = _snapshot.get("previews", {})
	if raw_previews is Dictionary:
		var matrix: Dictionary = raw_previews
		var raw_row: Variant = matrix.get(die_id, {})
		if raw_row is Dictionary:
			var raw_matrix_preview: Variant = (raw_row as Dictionary).get(node_id, {})
			if raw_matrix_preview is Dictionary and not (raw_matrix_preview as Dictionary).is_empty():
				return _selected_trigger_preview(
					raw_matrix_preview as Dictionary, die_id, node_id)
	var raw_preview: Variant = _snapshot.get("preview", {})
	if raw_preview is Dictionary:
		var preview: Dictionary = raw_preview
		if preview.has("die_id") or preview.has("node_id"):
			if str(preview.get("die_id", die_id)) == die_id \
					and str(preview.get("node_id", node_id)) == node_id:
				return _normalized_preview(preview, die_id, node_id)
		elif preview.has(node_id) and preview[node_id] is Dictionary:
			var node_preview: Dictionary = preview[node_id]
			if node_preview.has(die_id) and node_preview[die_id] is Dictionary:
				return _normalized_preview(
					node_preview[die_id] as Dictionary, die_id, node_id)
			return _normalized_preview(node_preview, die_id, node_id)
		elif preview.has(die_id) and preview[die_id] is Dictionary:
			var die_preview: Dictionary = preview[die_id]
			if die_preview.has(node_id) and die_preview[node_id] is Dictionary:
				return _normalized_preview(
					die_preview[node_id] as Dictionary, die_id, node_id)
			return _normalized_preview(die_preview, die_id, node_id)
		elif not preview.is_empty():
			return _normalized_preview(preview, die_id, node_id)
	var nodes: Dictionary = _snapshot.get("nodes", {})
	var node_data: Dictionary = nodes.get(node_id, {})
	var node_preview: Variant = node_data.get("preview", {})
	if node_preview is Dictionary:
		return _normalized_preview(node_preview, die_id, node_id)
	return {}


func _selected_trigger_preview(
		base_preview: Dictionary, die_id: String, node_id: String) -> Dictionary:
	var normalized_base := _normalized_preview(base_preview, die_id, node_id)
	if _selected_trigger_bundle_id.is_empty() \
			or not bool(normalized_base.get(
				"trigger_selection_required", false)):
		return normalized_base
	var raw_variants: Variant = base_preview.get(
		"trigger_candidate_previews", {})
	if raw_variants is Dictionary:
		var raw_variant: Variant = (raw_variants as Dictionary).get(
			_selected_trigger_bundle_id, {})
		if raw_variant is Dictionary \
				and not (raw_variant as Dictionary).is_empty():
			var variant := _normalized_preview(
				raw_variant as Dictionary, die_id, node_id)
			if bool(variant.get("valid", false)) \
					and _trigger_preview_matches_selected_candidate(variant):
				# The runtime variant owns progress, effects, deadline, and copy.
				# The base preview still owns the chooser surface so East can undo
				# the local selection before the allocation transaction exists.
				variant["trigger_selection_required"] = true
				variant["trigger_candidates"] = normalized_base.get(
					"trigger_candidates", []).duplicate(true)
				variant["trigger_candidate_previews"] = (
					raw_variants as Dictionary).duplicate(true)
				return variant
	var rejected := normalized_base.duplicate(true)
	rejected["ok"] = false
	rejected["valid"] = false
	rejected["error"] = "invalid_trigger_selection"
	rejected["reason_ko"] = _preview_error_text(
		"invalid_trigger_selection", true)
	rejected["reason_en"] = _preview_error_text(
		"invalid_trigger_selection", false)
	return rejected


func _trigger_preview_selected_candidate_id(preview: Dictionary) -> String:
	var terminal_candidate_id := str(preview.get(
		"selected_trigger_candidate_id", "")).strip_edges()
	if not terminal_candidate_id.is_empty():
		return terminal_candidate_id
	return str(preview.get("selected_trigger_bundle_id", "")).strip_edges()


func _trigger_preview_matches_selected_candidate(preview: Dictionary) -> bool:
	var candidate_id := _trigger_preview_selected_candidate_id(preview)
	if candidate_id != _selected_trigger_bundle_id \
			or not _trigger_candidate_records.has(candidate_id):
		return false
	var candidate: Dictionary = _trigger_candidate_records.get(candidate_id, {})
	var expected_bundle_id := str(candidate.get(
		"bundle_id", candidate_id)).strip_edges()
	var expected_route_id := str(candidate.get("route_id", "")).strip_edges()
	var expected_variant_id := str(candidate.get("variant_id", "")).strip_edges()
	return str(preview.get("selected_trigger_bundle_id", "")).strip_edges() \
			== expected_bundle_id \
		and str(preview.get("selected_terminal_route_id", "")).strip_edges() \
			== expected_route_id \
		and str(preview.get("terminal_variant_id", "")).strip_edges() \
			== expected_variant_id


func _preview_node_id() -> String:
	if not _selected_node_id.is_empty():
		return _selected_node_id
	if _focused_group == "node" and _node_buttons.has(_focused_id):
		return _focused_id
	if not _inspected_node_id.is_empty() and _node_buttons.has(_inspected_node_id):
		return _inspected_node_id
	return ""


func _effect_line(raw_effects: Variant) -> String:
	if not (raw_effects is Dictionary):
		return _tr("즉시 변화 없음", "NO IMMEDIATE CHANGE")
	var effects: Dictionary = raw_effects
	var parts: Array[String] = []
	for key in EFFECT_KEYS:
		var value := int(effects.get(key, 0))
		if value == 0:
			continue
		match key:
			"money":
				parts.append(_tr("현금", "CASH") + " " + _signed_money(value))
			"health":
				parts.append(_tr("몸", "BODY") + " %s%d" % ["+" if value > 0 else "", value])
			"mental":
				parts.append(_tr("마음", "MIND") + " %s%d" % ["+" if value > 0 else "", value])
	if parts.is_empty():
		return _tr("즉시 변화 없음", "NO IMMEDIATE CHANGE")
	return " · ".join(parts)


func _deadline_line(node_data: Dictionary, preview: Dictionary) -> String:
	var custom := _localized(preview, "deadline")
	if not custom.is_empty():
		return custom
	var deadline := int(preview.get(
		"deadline_week", node_data.get("deadline_week", 0)))
	if bool(node_data.get("locked", false)):
		return _tr(
			"앞선 선택 때문에 이번 달에는 이어진 연락이 없다.",
			"Earlier choices left no relationship thread to follow this month.")
	if bool(node_data.get("expired", false)):
		return _tr("기한이 지나 더 배치할 수 없다.", "The deadline has passed; this node is closed.")
	if bool(node_data.get("completed", false)) and not bool(node_data.get("repeatable", false)):
		return _tr("완료한 일이다.", "This node is complete.")
	if deadline <= 0:
		return _tr("기한 없음", "NO DEADLINE")
	var closes := bool(preview.get(
		"deadline_closes",
		int(_snapshot.get("week_of_month", 1)) >= deadline))
	if closes:
		return _tr(
			"기한 %d주차 · 이번 배치 뒤 닫힌다",
			"DEADLINE WEEK %d · CLOSES AFTER THIS") % deadline
	return _tr("기한 %d주차", "DEADLINE WEEK %d") % deadline


func _trigger_selection_required(preview: Dictionary) -> bool:
	return bool(preview.get("trigger_selection_required", false))


func _trigger_candidates(preview: Dictionary) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	var raw_candidates: Variant = preview.get("trigger_candidates", [])
	if not (raw_candidates is Array):
		return candidates
	for raw_candidate in raw_candidates:
		if raw_candidate is Dictionary:
			candidates.append(raw_candidate as Dictionary)
	return candidates


func _selected_node_requires_trigger_choice() -> bool:
	if _selected_die_id.is_empty() or _selected_node_id.is_empty():
		return false
	var preview := _preview_for(_selected_die_id, _selected_node_id)
	return _trigger_selection_required(preview) \
			and not _trigger_candidates(preview).is_empty()


func _selected_trigger_candidate_is_valid() -> bool:
	return not _selected_trigger_bundle_id.is_empty() \
			and _trigger_candidate_records.has(_selected_trigger_bundle_id)


func _trigger_candidate_record_for_preview() -> Dictionary:
	if _focused_group == "candidate" \
			and _trigger_candidate_records.has(_focused_id):
		return _trigger_candidate_records.get(_focused_id, {})
	if _trigger_candidate_records.has(_selected_trigger_bundle_id):
		return _trigger_candidate_records.get(_selected_trigger_bundle_id, {})
	if not _trigger_candidate_order.is_empty():
		return _trigger_candidate_records.get(_trigger_candidate_order[0], {})
	return {}


func _node_has_empty_required_trigger_candidates(node_id: String) -> bool:
	if _selected_die_id.is_empty() or node_id.is_empty():
		return false
	var preview := _preview_for(_selected_die_id, node_id)
	return _trigger_selection_required(preview) \
			and _trigger_candidates(preview).is_empty()


func _node_unavailable_by_id(node_id: String) -> bool:
	if node_id.is_empty():
		return true
	var nodes: Dictionary = _snapshot.get("nodes", {})
	if not nodes.has(node_id) or not (nodes[node_id] is Dictionary):
		return true
	return _node_unavailable(nodes[node_id]) \
			or _node_has_empty_required_trigger_candidates(node_id)


func _node_available_by_id(node_id: String) -> bool:
	return not _node_unavailable_by_id(node_id)


func _node_unavailable(node_data: Dictionary) -> bool:
	if bool(node_data.get("expired", false)) \
			or bool(node_data.get("locked", false)):
		return true
	return bool(node_data.get("completed", false)) \
			and not bool(node_data.get("repeatable", false))


func _die_data(die_id: String) -> Dictionary:
	if die_id.is_empty():
		return {}
	for raw_die in _snapshot.get("dice", []):
		if raw_die is Dictionary and str(raw_die.get("id", "")) == die_id:
			return raw_die
	return {}


func _remaining_effort_count() -> int:
	var remaining := 0
	for raw_die in _snapshot.get("dice", []):
		if raw_die is Dictionary and not bool(raw_die.get("spent", false)):
			remaining += 1
	return remaining


func _base_progress(value: int) -> int:
	if value <= 2:
		return 1
	if value <= 4:
		return 2
	return 3


func _update_root_meta() -> void:
	var selected_preview := _preview_for(_selected_die_id, _selected_node_id)
	set_meta("seoul_cycle_read_only", _read_only)
	set_meta("seoul_cycle_month", int(_snapshot.get("month", 0)))
	set_meta("seoul_cycle_turn", int(_snapshot.get("turn", 0)))
	set_meta("seoul_cycle_week_of_month", int(_snapshot.get("week_of_month", 0)))
	set_meta("seoul_cycle_die_ids", _die_order.duplicate())
	set_meta("seoul_cycle_node_ids", _node_order.duplicate())
	set_meta("seoul_cycle_selected_die_id", _selected_die_id)
	set_meta("seoul_cycle_selected_node_id", _selected_node_id)
	set_meta("seoul_cycle_selected_trigger_bundle_id", _selected_trigger_bundle_id)
	set_meta("seoul_cycle_trigger_candidate_ids", _trigger_candidate_order.duplicate())
	set_meta("seoul_cycle_trigger_candidate_count", _trigger_candidate_order.size())
	set_meta("seoul_cycle_trigger_selection_required",
		_trigger_selection_required(selected_preview))
	set_meta("seoul_cycle_trigger_candidate_panel_visible",
		_trigger_candidate_panel.visible)
	set_meta("seoul_cycle_trigger_candidate_focus_id",
		_focused_id if _focused_group == "candidate" else "")
	set_meta("seoul_cycle_selection_stage", _selection_stage())
	set_meta("seoul_cycle_remaining_effort_count", _remaining_effort_count())
	set_meta("seoul_cycle_error", _error_text)
	set_meta("seoul_cycle_viewport_size", Vector2i(roundi(size.x), roundi(size.y)))


func _selection_stage() -> String:
	if _selected_die_id.is_empty():
		return "capacity"
	if _selected_node_id.is_empty():
		return "node"
	if _selected_node_requires_trigger_choice() \
			and not _selected_trigger_candidate_is_valid():
		return "candidate"
	return "commit"


func _normalized_snapshot(raw_snapshot: Dictionary) -> Dictionary:
	var snapshot := raw_snapshot.duplicate(true)
	if not snapshot.has("week_of_month") and snapshot.has("week_index"):
		snapshot["week_of_month"] = int(snapshot.get("week_index", 1))
	if not snapshot.has("dice") and snapshot.get("capacities", null) is Array:
		var normalized_dice: Array = []
		for raw_capacity in snapshot.get("capacities", []):
			if not (raw_capacity is Dictionary):
				normalized_dice.append(raw_capacity)
				continue
			var capacity: Dictionary = (raw_capacity as Dictionary).duplicate(true)
			capacity["spent"] = bool(capacity.get(
				"spent", capacity.get("consumed", false)))
			normalized_dice.append(capacity)
		snapshot["dice"] = normalized_dice
	if snapshot.get("nodes", null) is Dictionary:
		var normalized_nodes: Dictionary = {}
		var source_nodes: Dictionary = snapshot.get("nodes", {})
		var board_order := 0
		for raw_node_id in source_nodes.keys():
			var node_id := str(raw_node_id)
			var raw_node: Variant = source_nodes.get(raw_node_id, {})
			if not (raw_node is Dictionary):
				normalized_nodes[node_id] = raw_node
				continue
			var node: Dictionary = (raw_node as Dictionary).duplicate(true)
			node["target"] = int(node.get("target", node.get("threshold", 0)))
			var status := str(node.get("status", "open"))
			node["completed"] = bool(node.get("completed", false)) \
				or status in ["completed", "awaiting_trigger"]
			node["expired"] = bool(node.get("expired", false)) \
				or status == "expired"
			node["locked"] = bool(node.get("locked", false)) \
				or status == "locked"
			node["repeatable"] = bool(node.get(
				"repeatable", node.get("repeatable_after_completion", false)))
			if not node.has("board_order"):
				node["board_order"] = board_order
			normalized_nodes[node_id] = node
			board_order += 1
		snapshot["nodes"] = normalized_nodes
	if snapshot.get("preview", null) is Dictionary:
		snapshot["preview"] = _normalized_preview(
			snapshot.get("preview", {}), "", "")
	if snapshot.get("previews", null) is Dictionary:
		var normalized_matrix: Dictionary = {}
		var raw_matrix: Dictionary = snapshot.get("previews", {})
		for raw_capacity_id in raw_matrix.keys():
			var capacity_id := str(raw_capacity_id)
			var raw_row: Variant = raw_matrix.get(raw_capacity_id, {})
			if not (raw_row is Dictionary):
				normalized_matrix[capacity_id] = raw_row
				continue
			var normalized_row: Dictionary = {}
			for raw_node_id in (raw_row as Dictionary).keys():
				var node_id := str(raw_node_id)
				var raw_preview: Variant = (raw_row as Dictionary).get(raw_node_id, {})
				if raw_preview is Dictionary:
					normalized_row[node_id] = _normalized_preview(
						raw_preview as Dictionary, capacity_id, node_id)
				else:
					normalized_row[node_id] = raw_preview
			normalized_matrix[capacity_id] = normalized_row
		snapshot["previews"] = normalized_matrix
	if not snapshot.has("selected_die_id") and snapshot.has("selected_capacity_id"):
		snapshot["selected_die_id"] = str(snapshot.get("selected_capacity_id", ""))
	return snapshot


func _normalized_preview(
		raw_preview: Dictionary,
		fallback_capacity_id: String,
		fallback_node_id: String) -> Dictionary:
	var preview := raw_preview.duplicate(true)
	preview["die_id"] = str(preview.get(
		"die_id", preview.get("capacity_id", fallback_capacity_id)))
	preview["node_id"] = str(preview.get("node_id", fallback_node_id))
	preview["progress_delta"] = int(preview.get(
		"progress_delta", preview.get("progress_gain", preview.get("progress", 0))))
	preview["effects"] = preview.get(
		"effects", preview.get("immediate_effects", {}))
	preview["deadline_closes"] = bool(preview.get(
		"deadline_closes", preview.get("will_expire", false)))
	preview["trigger_selection_required"] = bool(preview.get(
		"trigger_selection_required", false))
	preview["trigger_candidates"] = _normalized_trigger_candidates(
		preview.get("trigger_candidates", []))
	preview["valid"] = bool(preview.get("valid", preview.get("ok", true)))
	if not preview.has("reason_ko") and not preview.has("reason_en"):
		var error_code := str(preview.get("error", ""))
		if not error_code.is_empty():
			preview["reason_ko"] = _preview_error_text(error_code, true)
			preview["reason_en"] = _preview_error_text(error_code, false)
	return preview


func _normalized_trigger_candidates(raw_candidates: Variant) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	if not (raw_candidates is Array):
		return candidates
	for raw_candidate in raw_candidates:
		if not (raw_candidate is Dictionary):
			continue
		var candidate: Dictionary = (raw_candidate as Dictionary).duplicate(true)
		candidate["id"] = str(candidate.get("id", ""))
		candidate["label_ko"] = str(candidate.get(
			"label_ko", candidate.get("title_ko", "")))
		candidate["label_en"] = str(candidate.get(
			"label_en", candidate.get("title_en", "")))
		candidate["detail_ko"] = str(candidate.get(
			"detail_ko", candidate.get(
				"summary_ko", candidate.get("description_ko", ""))))
		candidate["detail_en"] = str(candidate.get(
			"detail_en", candidate.get(
				"summary_en", candidate.get("description_en", ""))))
		candidates.append(candidate)
	candidates.sort_custom(_sort_trigger_candidates)
	return candidates


func _preview_error_text(error_code: String, korean: bool) -> String:
	match error_code:
		"capacity_already_consumed":
			return "이미 사용한 여력" if korean else "CAPACITY ALREADY SPENT"
		"node_closed", "node_deadline_passed":
			return "기한이 닫힌 장소" if korean else "LOCATION CLOSED"
		"no_progress_this_week":
			return "이 주에는 더 진행되지 않음" if korean else "NO FURTHER PROGRESS THIS WEEK"
		"cycle_turn_already_completed", "allocation_already_committed":
			return "이번 주 배치 완료" if korean else "WEEK ALREADY COMMITTED"
		"cycle_entry_unresolved":
			return "먼저 도착한 일을 마친다" if korean else "RESOLVE THE CURRENT EVENT FIRST"
		"trigger_selection_required":
			return "이어갈 약속을 고른다" if korean else "CHOOSE A THREAD"
		"invalid_trigger_selection":
			return "고른 약속을 다시 확인한다" if korean else "CHECK THE SELECTED THREAD"
	return "배치할 수 없음" if korean else "ALLOCATION UNAVAILABLE"


func _raw_trigger_candidate_contract_error(snapshot: Dictionary) -> String:
	var raw_preview: Variant = snapshot.get("preview", null)
	if raw_preview is Dictionary:
		var preview_error := _raw_trigger_candidate_list_error(
			raw_preview as Dictionary, "preview")
		if not preview_error.is_empty():
			return preview_error
	var raw_previews: Variant = snapshot.get("previews", null)
	if not raw_previews is Dictionary:
		return ""
	for raw_capacity_id in (raw_previews as Dictionary).keys():
		var raw_row: Variant = (raw_previews as Dictionary).get(
			raw_capacity_id, {})
		if not raw_row is Dictionary:
			continue
		for raw_node_id in (raw_row as Dictionary).keys():
			var raw_candidate_preview: Variant = (raw_row as Dictionary).get(
				raw_node_id, {})
			if not raw_candidate_preview is Dictionary:
				continue
			var candidate_error := _raw_trigger_candidate_list_error(
				raw_candidate_preview as Dictionary,
				"%s/%s" % [str(raw_capacity_id), str(raw_node_id)])
			if not candidate_error.is_empty():
				return candidate_error
	return ""


func _raw_trigger_candidate_list_error(
		preview: Dictionary, context: String) -> String:
	if not preview.has("trigger_candidates"):
		if bool(preview.get("trigger_selection_required", false)):
			return "trigger_selection_required preview must declare trigger_candidates at %s" % context
		return ""
	var raw_candidates: Variant = preview.get("trigger_candidates", [])
	if not raw_candidates is Array:
		return "trigger_candidates must be an Array at %s" % context
	var candidates: Array = raw_candidates
	if candidates.size() > MAX_TRIGGER_CANDIDATES:
		return "trigger_candidates supports at most %d entries at %s" % [
			MAX_TRIGGER_CANDIDATES, context]
	var seen_ids: Dictionary = {}
	for raw_candidate in candidates:
		if not raw_candidate is Dictionary:
			return "every trigger candidate must be a Dictionary at %s" % context
		var candidate_id := str(
			(raw_candidate as Dictionary).get("id", "")).strip_edges()
		if candidate_id.is_empty() or seen_ids.has(candidate_id):
			return "raw trigger candidate ids must be non-empty and unique at %s" % context
		seen_ids[candidate_id] = true
	return ""


func _snapshot_validation_error(snapshot: Dictionary) -> String:
	if snapshot.is_empty():
		return "snapshot is empty"
	if not (snapshot.get("dice", null) is Array):
		return "dice must be an Array"
	var dice: Array = snapshot.get("dice", [])
	if dice.size() != EFFORT_COUNT:
		return "dice must contain exactly %d entries" % EFFORT_COUNT
	var die_ids: Dictionary = {}
	for raw_die in dice:
		if not (raw_die is Dictionary):
			return "every die must be a Dictionary"
		var die: Dictionary = raw_die
		var die_id := str(die.get("id", "")).strip_edges()
		var value := int(die.get("value", 0))
		if die_id.is_empty() or die_ids.has(die_id):
			return "die ids must be non-empty and unique"
		if value < 1 or value > 6:
			return "die values must stay inside 1..6"
		die_ids[die_id] = true
	if not (snapshot.get("nodes", null) is Dictionary):
		return "nodes must be a Dictionary"
	var nodes: Dictionary = snapshot.get("nodes", {})
	if nodes.size() != NODE_COUNT:
		return "nodes must contain exactly %d entries" % NODE_COUNT
	for raw_id in nodes.keys():
		var node_id := str(raw_id).strip_edges()
		if node_id.is_empty() or not (nodes[raw_id] is Dictionary):
			return "node ids and records must be valid"
		var node_data: Dictionary = nodes[raw_id]
		if not _localized_contract_pair_is_complete(node_data, "label") \
				or not _localized_contract_pair_is_complete(node_data, "place"):
			return "every node requires KO/EN label and place"
		var target := int(node_data.get("target", 0))
		var progress := int(node_data.get("progress", -1))
		if target <= 0 or progress < 0:
			return "node progress/target must be non-negative with target > 0"
	var week := int(snapshot.get("week_of_month", 1))
	if week < 1 or week > 4:
		return "week_of_month must stay inside 1..4"
	var raw_previews: Variant = snapshot.get("previews", {})
	if raw_previews is Dictionary:
		for raw_capacity_id in (raw_previews as Dictionary).keys():
			var raw_row: Variant = (raw_previews as Dictionary).get(raw_capacity_id, {})
			if not (raw_row is Dictionary):
				continue
			for raw_node_id in (raw_row as Dictionary).keys():
				var raw_preview: Variant = (raw_row as Dictionary).get(raw_node_id, {})
				if not (raw_preview is Dictionary):
					continue
				var trigger_error := _trigger_candidate_contract_error(
					raw_preview as Dictionary,
					"%s/%s" % [str(raw_capacity_id), str(raw_node_id)])
				if not trigger_error.is_empty():
					return trigger_error
	return ""


func _trigger_candidate_contract_error(preview: Dictionary, context: String) -> String:
	var raw_candidates: Variant = preview.get("trigger_candidates", [])
	if not (raw_candidates is Array):
		return "trigger_candidates must be an Array at %s" % context
	var candidates: Array = raw_candidates
	if candidates.size() > MAX_TRIGGER_CANDIDATES:
		return "trigger_candidates supports at most %d entries at %s" % [
			MAX_TRIGGER_CANDIDATES, context]
	var seen_ids: Dictionary = {}
	for raw_candidate in candidates:
		if not (raw_candidate is Dictionary):
			return "every trigger candidate must be a Dictionary at %s" % context
		var candidate: Dictionary = raw_candidate
		var candidate_id := str(candidate.get("id", "")).strip_edges()
		if candidate_id.is_empty() or seen_ids.has(candidate_id):
			return "trigger candidate ids must be non-empty and unique at %s" % context
		if not _localized_contract_pair_is_complete(candidate, "label") \
				or not _localized_contract_pair_is_complete(candidate, "detail"):
			return "every trigger candidate requires localized label/detail at %s" % context
		seen_ids[candidate_id] = true
	return ""


func _localized_contract_pair_is_complete(
		data: Dictionary, base_key: String) -> bool:
	var ko := str(data.get(base_key + "_ko", "")).strip_edges()
	var en := str(data.get(base_key + "_en", "")).strip_edges()
	return not ko.is_empty() and not en.is_empty()


func _sort_node_ids(a: String, b: String) -> bool:
	var nodes: Dictionary = _snapshot.get("nodes", {})
	var left: Dictionary = nodes.get(a, {})
	var right: Dictionary = nodes.get(b, {})
	var left_order := int(left.get("board_order", 999))
	var right_order := int(right.get("board_order", 999))
	if left_order == right_order:
		return a < b
	return left_order < right_order


func _sort_trigger_candidates(a: Dictionary, b: Dictionary) -> bool:
	return str(a.get("id", "")) < str(b.get("id", ""))


func _localized(data: Dictionary, base_key: String) -> String:
	var ko := str(data.get(base_key + "_ko", ""))
	var en := str(data.get(base_key + "_en", ""))
	if ko.is_empty() and en.is_empty():
		return ""
	if ko.is_empty():
		ko = en
	if en.is_empty():
		en = ko
	return _tr(ko, en)


func _localized_board_label(data: Dictionary) -> String:
	var ko := str(data.get("board_label_ko", "")).strip_edges()
	var en := str(data.get("board_label_en", "")).strip_edges()
	if ko.is_empty():
		ko = str(data.get("label_ko", "")).strip_edges()
	if en.is_empty():
		en = str(data.get("label_en", "")).strip_edges()
	if ko.is_empty():
		ko = en
	if en.is_empty():
		en = ko
	return _tr(ko, en)


func _format_money(amount: float) -> String:
	# The allocation board is a decision surface: unlike compact HUD copy, it
	# must show the exact won amount before the player commits a week.
	return LocaleManager.format_whole_won(roundi(amount))


func _signed_money(amount: int) -> String:
	var sign := "+" if amount > 0 else "-"
	return sign + _format_money(abs(amount))


func _tr(ko: String, en: String) -> String:
	return LocaleManager.ui(ko, en)


func _safe_node_name(raw_id: String) -> String:
	var result := raw_id
	for character in ["/", ":", ".", " ", "@", "#", "[", "]"]:
		result = result.replace(character, "_")
	return result


func _joy_button_pressed(event: InputEvent, button_index: int) -> bool:
	if not (event is InputEventJoypadButton):
		return false
	var joy := event as InputEventJoypadButton
	return joy.pressed and int(joy.button_index) == button_index


func _visual_state(selected: bool, focused: bool, unavailable: bool) -> String:
	if unavailable:
		return "unavailable"
	if selected and focused:
		return "selected_focused"
	if selected:
		return "selected"
	if focused:
		return "focused"
	return "idle"


func _label(text: String, font_size: int, color: Color, bold := false) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", _font_bold if bold else _font)
	UIStyle.override_font_size(label, "font_size", font_size)
	UIStyle.override_color(label, "font_color", color)
	return label


func _stat_label(name_value: String) -> Label:
	var label := _label("", 14, COLOR_TEXT, true)
	label.name = name_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	UIStyle.override_stylebox(label,
		"normal", _panel_style(Color("#15191e", 0.92), Color("#444c55"), 1, 4))
	return label


func _apply_plain_button_style(button: Button) -> void:
	button.add_theme_font_override("font", _font_bold)
	UIStyle.override_color(button, "font_color", COLOR_TEXT)
	UIStyle.override_color(button, "font_hover_color", COLOR_FOCUS)
	UIStyle.override_stylebox(button,
		"normal", _panel_style(Color("#11151a", 0.82), Color("#4a525b"), 1, 4))
	UIStyle.override_stylebox(button,
		"hover", _panel_style(Color("#20262c", 0.96), COLOR_FOCUS, 2, 4))
	UIStyle.override_stylebox(button,
		"pressed", _panel_style(Color("#090b0e", 0.98), COLOR_ACCENT, 2, 4))


func _apply_commit_style(ready: bool) -> void:
	_commit_button.add_theme_font_override("font", _font_bold)
	UIStyle.override_color(_commit_button, "font_color", COLOR_BASE if ready else COLOR_DIM)
	UIStyle.override_color(_commit_button, "font_hover_color", COLOR_BASE)
	UIStyle.override_color(_commit_button, "font_pressed_color", COLOR_BASE)
	UIStyle.override_color(_commit_button, "font_disabled_color", COLOR_MUTED)
	UIStyle.override_stylebox(_commit_button,
		"normal", _panel_style(COLOR_ACCENT, Color("#f0dfa8"), 2, 5))
	UIStyle.override_stylebox(_commit_button,
		"hover", _panel_style(Color("#ead79e"), COLOR_FOCUS, 3, 5))
	UIStyle.override_stylebox(_commit_button,
		"pressed", _panel_style(Color("#b8a474"), COLOR_FOCUS, 3, 5))
	UIStyle.override_stylebox(_commit_button,
		"focus", _panel_style(Color.TRANSPARENT, COLOR_FOCUS, 3, 5))
	UIStyle.override_stylebox(_commit_button,
		"disabled", _panel_style(Color("#252a30"), Color("#444b53"), 1, 5))


func _panel_style(
		background: Color,
		border: Color,
		border_width: int,
		radius: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = UIStyle.panel_style(
		background.to_html(), border.to_html(), radius)
	style.set_border_width_all(border_width)
	# Preserve the former unset content margins. The shared factory supplies
	# panel padding, but this board positions its own children.
	style.content_margin_left = -1.0
	style.content_margin_right = -1.0
	style.content_margin_top = -1.0
	style.content_margin_bottom = -1.0
	return style


func _clear_children(parent: Node) -> void:
	for child in parent.get_children():
		child.free()
