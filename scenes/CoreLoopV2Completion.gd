extends Control
class_name CoreLoopV2Completion
## Core Loop V2 24-week completion surface.
##
## This component is presentation-only. The caller owns the durable completion
## snapshot and autosave boundary, then passes already-localized copy to open().

signal finish_requested
signal retry_requested

const MAX_MONTHS := 60
const MAX_MONTH_EVENTS := 8

const COLOR_DIM := Color(0.006, 0.007, 0.009, 0.88)
const COLOR_PANEL := Color("#111216")
const COLOR_RAISED := Color("#181a20fa")
const COLOR_DEEP := Color("#0d0d10")
const COLOR_BORDER := Color("#30343a")
const COLOR_BORDER_SOFT := Color("#30343ab8")
const COLOR_TEXT := Color("#e6e8ec")
const COLOR_TEXT_SECONDARY := Color("#9aa1a8")
const COLOR_TEXT_MUTED := Color("#6f757c")
const COLOR_FOCUS := Color("#f4f7fb")
const COLOR_SELECTED := Color("#91a6a2")
const COLOR_DEFERRED := Color("#8e7f84")
const COLOR_EXPIRED := Color("#a98b88")

var _built := false
var _model: Dictionary = {}
var _detail_page := 0
var _selected_row := 0
var _selected_rows_by_page: Dictionary = {}
var _detail_entries: Array[Dictionary] = []
var _owns_playtest_marker_context := false
var _terminal_action_in_flight := false

var _font_regular: Font = null
var _font_semibold: Font = null
var _font_bold: Font = null

var _summary_root: VBoxContainer = null
var _details_root: VBoxContainer = null
var _finish_button: Button = null
var _details_button: Button = null
var _boundary_label: Label = null
var _detail_page_host: HBoxContainer = null
var _detail_readout: VBoxContainer = null
var _detail_hint: Label = null
var _detail_page_title: Label = null
var _detail_page_counter: Label = null
var _page_prev_button: Button = null
var _page_next_button: Button = null
var _detail_rows: Array[Button] = []


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 400
	z_as_relative = false
	set_process_input(true)
	set_process_unhandled_input(true)
	_ensure_built()
	visible = false


func open(model: Dictionary) -> bool:
	if not _validate_model(model):
		return false
	_ensure_built()
	_model = model.duplicate(true)
	_terminal_action_in_flight = false
	_detail_page = 0
	_selected_row = 0
	_selected_rows_by_page.clear()
	_render_summary()
	_show_summary(false)
	visible = true
	SceneTransition.set_playtest_marker_context(
		SceneTransition.PLAYTEST_MARKER_CONTEXT_PLANNER)
	_owns_playtest_marker_context = true
	set_meta("core_loop_v2_playtest_marker_context",
		SceneTransition.PLAYTEST_MARKER_CONTEXT_PLANNER)
	set_meta("core_loop_v2_playtest_marker_hidden", true)
	move_to_front()
	call_deferred("_focus_summary_cta")
	call_deferred("_stabilize_open_layout")
	return true


func _stabilize_open_layout() -> void:
	# Rebuilding wrapped labels while hidden can briefly report a very tall
	# minimum size. Control then expands its full-rect offsets, but does not
	# shrink them again after the text receives its real width. Reapply the
	# viewport contract on two settled frames so repeated normal/legacy opens
	# cannot leave the expandable spacer thousands of pixels tall.
	await get_tree().process_frame
	_apply_full_rect_after_rebuild()
	await get_tree().process_frame
	_apply_full_rect_after_rebuild()


func _apply_full_rect_after_rebuild() -> void:
	if not is_open():
		return
	reset_size()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0.0
	offset_top = 0.0
	offset_right = 0.0
	offset_bottom = 0.0
	if is_instance_valid(_summary_root):
		_summary_root.queue_sort()
	if is_instance_valid(_details_root):
		_details_root.queue_sort()


func close() -> void:
	if is_instance_valid(get_viewport().gui_get_focus_owner()):
		var owner := get_viewport().gui_get_focus_owner()
		if is_ancestor_of(owner):
			owner.release_focus()
	visible = false
	_restore_playtest_marker_context()
	_model.clear()
	_detail_page = 0
	_selected_row = 0
	_selected_rows_by_page.clear()
	_terminal_action_in_flight = false


func _exit_tree() -> void:
	_restore_playtest_marker_context()


func _restore_playtest_marker_context() -> void:
	if not _owns_playtest_marker_context:
		return
	SceneTransition.set_playtest_marker_context(
		SceneTransition.PLAYTEST_MARKER_CONTEXT_DEFAULT)
	_owns_playtest_marker_context = false
	set_meta("core_loop_v2_playtest_marker_context",
		SceneTransition.PLAYTEST_MARKER_CONTEXT_DEFAULT)
	set_meta("core_loop_v2_playtest_marker_hidden", false)


func is_open() -> bool:
	return visible and not _model.is_empty()


func summary_visible() -> bool:
	return is_open() and is_instance_valid(_summary_root) and _summary_root.visible


func details_visible() -> bool:
	return is_open() and is_instance_valid(_details_root) and _details_root.visible


func current_page() -> int:
	return _detail_page if details_visible() else 0


func _validate_model(model: Dictionary) -> bool:
	for key in [
		"title", "intro", "hero_title", "hero_body", "initiative",
		"boundary",
	]:
		if typeof(model.get(key)) != TYPE_STRING:
			return false
	if typeof(model.get("autosave_ok")) != TYPE_BOOL:
		return false
	for key in ["outcome_rows", "metrics", "traces", "months", "unresolved"]:
		if not model.get(key) is Array:
			return false

	var outcome_rows: Array = model.get("outcome_rows", [])
	if outcome_rows.is_empty() or outcome_rows.size() > 4:
		return false
	for raw_row in outcome_rows:
		if not raw_row is Dictionary:
			return false
		var row: Dictionary = raw_row
		if typeof(row.get("kind")) != TYPE_STRING \
				or typeof(row.get("label")) != TYPE_STRING \
				or not row.get("values") is Array \
				or not _is_string_array(row.get("values", [])):
			return false

	var metrics: Array = model.get("metrics", [])
	if metrics.is_empty() or metrics.size() > 6:
		return false
	for raw_metric in metrics:
		if not raw_metric is Dictionary:
			return false
		var metric: Dictionary = raw_metric
		for key in ["label", "value", "note", "accent"]:
			if typeof(metric.get(key)) != TYPE_STRING:
				return false

	var traces: Array = model.get("traces", [])
	if traces.size() > 4:
		return false
	for raw_trace in traces:
		if not raw_trace is Dictionary:
			return false
		var trace: Dictionary = raw_trace
		if typeof(trace.get("label")) != TYPE_STRING \
				or typeof(trace.get("text")) != TYPE_STRING:
			return false

	var months: Array = model.get("months", [])
	if months.is_empty() or months.size() > MAX_MONTHS:
		return false
	for raw_month in months:
		if not raw_month is Dictionary:
			return false
		var month: Dictionary = raw_month
		if typeof(month.get("month")) != TYPE_INT \
				or typeof(month.get("title")) != TYPE_STRING:
			return false
		for key in ["allocations", "outcomes", "missed"]:
			if not month.get(key) is Array \
					or not _is_string_array(month.get(key, [])):
				return false
		if (month.get("allocations", []) as Array).size() != 4 \
				or (month.get("outcomes", []) as Array).size() > 4:
			return false
		if month.has("events"):
			if not month.get("events") is Array \
					or not _is_string_array(month.get("events", [])) \
					or (month.get("events", []) as Array).size() \
						> MAX_MONTH_EVENTS:
				return false

	var unresolved: Array = model.get("unresolved", [])
	if unresolved.size() > 12 or not _is_string_array(unresolved):
		return false
	return not model.has("background_path") \
			or typeof(model.get("background_path")) == TYPE_STRING


func _is_string_array(values: Array) -> bool:
	for value in values:
		if typeof(value) != TYPE_STRING:
			return false
	return true


func _ensure_built() -> void:
	if _built:
		return
	_built = true
	set_meta("core_loop_v2_completion_surface", true)
	_load_fonts()

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = COLOR_DIM
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.set_meta("core_loop_v2_completion_dim", true)
	add_child(dim)

	var safe := MarginContainer.new()
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	UIStyle.override_constant(safe, "margin_left", 32)
	UIStyle.override_constant(safe, "margin_right", 32)
	UIStyle.override_constant(safe, "margin_top", 20)
	UIStyle.override_constant(safe, "margin_bottom", 20)
	safe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	safe.set_meta("core_loop_v2_completion_safe_area", true)
	add_child(safe)

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	UIStyle.override_stylebox(panel,
		"panel", _panel_style(COLOR_PANEL, COLOR_BORDER, 9, 20, 16))
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.set_meta("core_loop_v2_completion_panel", true)
	safe.add_child(panel)

	var surface := VBoxContainer.new()
	surface.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	surface.size_flags_vertical = Control.SIZE_EXPAND_FILL
	UIStyle.override_constant(surface, "separation", 0)
	panel.add_child(surface)

	_summary_root = VBoxContainer.new()
	_summary_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_summary_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	UIStyle.override_constant(_summary_root, "separation", 7)
	_summary_root.set_meta("core_loop_v2_summary", true)
	surface.add_child(_summary_root)

	_details_root = VBoxContainer.new()
	_details_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	UIStyle.override_constant(_details_root, "separation", 8)
	_details_root.visible = false
	_details_root.set_meta("core_loop_v2_details", true)
	surface.add_child(_details_root)

	if not ControllerHints.input_mode_changed.is_connected(
			_on_input_mode_changed):
		ControllerHints.input_mode_changed.connect(_on_input_mode_changed)


func _load_fonts() -> void:
	_font_regular = UIStyle.font_regular
	_font_semibold = UIStyle.font_semibold
	_font_bold = UIStyle.font_bold
	if _font_regular == null:
		_font_regular = FontKit.ui_regular()
	if _font_semibold == null:
		_font_semibold = FontKit.ui_semibold()
	if _font_bold == null:
		_font_bold = FontKit.ui_bold()
	FontKit.attach_emoji_fallback(_font_regular)
	FontKit.attach_emoji_fallback(_font_semibold)
	FontKit.attach_emoji_fallback(_font_bold)


func _render_summary() -> void:
	_clear_children(_summary_root)

	var title: Label = _label(str(_model.get("title", "")), 28, COLOR_TEXT, "bold")
	title.set_meta("core_loop_v2_summary_title", true)
	_summary_root.add_child(title)

	var intro_text := str(_model.get("intro", "")).strip_edges()
	if not intro_text.is_empty():
		var intro := _label(intro_text, 14, COLOR_TEXT_SECONDARY)
		intro.set_meta("core_loop_v2_summary_intro", true)
		_summary_root.add_child(intro)

	_summary_root.add_child(_build_hero())

	_summary_root.add_child(_build_outcome_receipt())
	_summary_root.add_child(_build_metric_strip())

	var traces: Array = _model.get("traces", [])
	if not traces.is_empty():
		_summary_root.add_child(_build_trace_strip(traces))

	var initiative_text := str(_model.get("initiative", "")).strip_edges()
	if not initiative_text.is_empty():
		var initiative := PanelContainer.new()
		UIStyle.override_stylebox(initiative,
			"panel", _panel_style(COLOR_DEEP, COLOR_BORDER_SOFT, 5, 14, 8))
		initiative.set_meta("core_loop_v2_initiative", true)
		var initiative_row := HBoxContainer.new()
		UIStyle.override_constant(initiative_row, "separation", 12)
		initiative.add_child(initiative_row)
		var initiative_key := _label(
			_tr("먼저 건 연락", "I Reached Out First"),
			14, COLOR_SELECTED, "semibold")
		initiative_key.custom_minimum_size.x = 150
		initiative_row.add_child(initiative_key)
		var initiative_value := _label(
			initiative_text, 14, COLOR_TEXT_SECONDARY)
		initiative_value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		initiative_row.add_child(initiative_value)
		_summary_root.add_child(initiative)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_summary_root.add_child(spacer)
	_summary_root.add_child(_build_summary_footer())


func _build_hero() -> Control:
	var hero := PanelContainer.new()
	hero.custom_minimum_size.y = 100
	hero.clip_contents = true
	UIStyle.override_stylebox(hero,
		"panel", _panel_style(COLOR_DEEP, COLOR_BORDER_SOFT, 6, 0, 0))
	hero.set_meta("core_loop_v2_summary_hero", true)

	var background_path := str(_model.get("background_path", "")).strip_edges()
	if not background_path.is_empty() and ResourceLoader.exists(background_path):
		var texture := load(background_path) as Texture2D
		if texture != null:
			var scene_strip := TextureRect.new()
			scene_strip.texture = texture
			scene_strip.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			scene_strip.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			scene_strip.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			scene_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
			scene_strip.set_meta("core_loop_v2_hero_scene_strip", background_path)
			hero.add_child(scene_strip)
			var scrim := ColorRect.new()
			scrim.color = Color(0.004, 0.005, 0.007, 0.68)
			scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
			scrim.set_meta("core_loop_v2_hero_scrim", true)
			hero.add_child(scrim)

	var hero_margin := MarginContainer.new()
	UIStyle.override_constant(hero_margin, "margin_left", 16)
	UIStyle.override_constant(hero_margin, "margin_right", 16)
	UIStyle.override_constant(hero_margin, "margin_top", 10)
	UIStyle.override_constant(hero_margin, "margin_bottom", 10)
	hero.add_child(hero_margin)
	var hero_box := VBoxContainer.new()
	UIStyle.override_constant(hero_box, "separation", 4)
	hero_margin.add_child(hero_box)
	var hero_title := _label(
		str(_model.get("hero_title", "")), 20, COLOR_TEXT, "bold")
	hero_title.set_meta("core_loop_v2_hero_title", true)
	hero_box.add_child(hero_title)
	var hero_body_text := str(_model.get("hero_body", "")).strip_edges()
	if not hero_body_text.is_empty():
		var hero_body := _label(hero_body_text, 15, COLOR_TEXT_SECONDARY)
		hero_body.set_meta("core_loop_v2_hero_body", true)
		hero_box.add_child(hero_body)
	return hero


func _build_outcome_receipt() -> Control:
	var receipt := PanelContainer.new()
	UIStyle.override_stylebox(receipt,
		"panel", _panel_style(COLOR_RAISED, COLOR_BORDER, 6, 12, 6))
	receipt.set_meta("core_loop_v2_outcome_receipt", true)
	var rows := VBoxContainer.new()
	UIStyle.override_constant(rows, "separation", 0)
	receipt.add_child(rows)

	var outcome_rows: Array = _model.get("outcome_rows", [])
	for index in range(outcome_rows.size()):
		var row: Dictionary = outcome_rows[index]
		var line := HBoxContainer.new()
		UIStyle.override_constant(line, "separation", 12)
		line.set_meta("core_loop_v2_outcome_kind", str(row.get("kind", "")))
		var marker := ColorRect.new()
		marker.custom_minimum_size = Vector2(4, 30)
		marker.size_flags_vertical = Control.SIZE_EXPAND_FILL
		marker.color = _outcome_color(str(row.get("kind", "")))
		marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.add_child(marker)
		var key := _label(
			str(row.get("label", "")), 14,
			_outcome_color(str(row.get("kind", ""))), "semibold")
		key.custom_minimum_size.x = 150
		key.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		line.add_child(key)
		var values: Array = row.get("values", [])
		var value_text := "  ·  ".join(values) if not values.is_empty() else "—"
		var value := _label(value_text, 14, COLOR_TEXT)
		value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		value.set_meta("core_loop_v2_outcome_values", values.duplicate())
		line.add_child(value)
		rows.add_child(line)
		if index < outcome_rows.size() - 1:
			rows.add_child(_separator())
	return receipt


func _build_metric_strip() -> Control:
	var strip := PanelContainer.new()
	UIStyle.override_stylebox(strip,
		"panel", _panel_style(COLOR_DEEP, COLOR_BORDER_SOFT, 6, 13, 8))
	strip.set_meta("core_loop_v2_metric_strip", true)
	var grid := GridContainer.new()
	var metrics: Array = _model.get("metrics", [])
	grid.columns = maxi(1, metrics.size())
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UIStyle.override_constant(grid, "h_separation", 14)
	UIStyle.override_constant(grid, "v_separation", 5)
	strip.add_child(grid)
	for raw_metric in metrics:
		var metric: Dictionary = raw_metric
		var cell := VBoxContainer.new()
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		UIStyle.override_constant(cell, "separation", 1)
		cell.set_meta("core_loop_v2_metric", str(metric.get("label", "")))
		var label := _label(
			str(metric.get("label", "")), 14, COLOR_TEXT_MUTED, "semibold")
		cell.add_child(label)
		var accent := Color.from_string(
			str(metric.get("accent", "")), COLOR_TEXT)
		var value := _label(
			str(metric.get("value", "")), 18, accent, "bold")
		cell.add_child(value)
		var note := _label(
			str(metric.get("note", "")), 14, COLOR_TEXT_MUTED)
		cell.add_child(note)
		grid.add_child(cell)
	return strip


func _build_trace_strip(traces: Array) -> Control:
	var strip := PanelContainer.new()
	UIStyle.override_stylebox(strip,
		"panel", _panel_style(COLOR_DEEP, COLOR_BORDER_SOFT, 5, 13, 8))
	strip.set_meta("core_loop_v2_trace_strip", true)
	var grid := GridContainer.new()
	grid.columns = mini(2, maxi(1, traces.size()))
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UIStyle.override_constant(grid, "h_separation", 18)
	UIStyle.override_constant(grid, "v_separation", 8)
	strip.add_child(grid)
	for raw_trace in traces:
		var trace: Dictionary = raw_trace
		var cell := VBoxContainer.new()
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		UIStyle.override_constant(cell, "separation", 2)
		var label := _label(
			str(trace.get("label", "")), 14, COLOR_TEXT_MUTED, "semibold")
		cell.add_child(label)
		var text := _label(
			str(trace.get("text", "")), 14, COLOR_TEXT_SECONDARY)
		cell.add_child(text)
		grid.add_child(cell)
	return strip


func _build_summary_footer() -> Control:
	var footer := PanelContainer.new()
	UIStyle.override_stylebox(footer,
		"panel", _panel_style(COLOR_DEEP, COLOR_BORDER, 6, 12, 7))
	footer.set_meta("core_loop_v2_summary_footer", true)
	var box := VBoxContainer.new()
	UIStyle.override_constant(box, "separation", 5)
	footer.add_child(box)

	_boundary_label = _label(
		str(_model.get("boundary", "")), 14, COLOR_TEXT_SECONDARY)
	_boundary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boundary_label.set_meta("core_loop_v2_boundary", true)
	box.add_child(_boundary_label)

	var actions := HBoxContainer.new()
	UIStyle.override_constant(actions, "separation", 10)
	box.add_child(actions)
	_details_button = _button("", false)
	_details_button.custom_minimum_size.x = 250
	_details_button.focus_mode = Control.FOCUS_NONE
	_details_button.set_meta("core_loop_v2_details_button", true)
	_details_button.pressed.connect(_show_details)
	actions.add_child(_details_button)

	_finish_button = _button("", true)
	_finish_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_finish_button.set_meta("core_loop_v2_finish_button", true)
	_finish_button.set_meta("core_loop_v2_recap_done", true)
	_finish_button.set_meta(
		"core_loop_v2_requires_retry", not bool(_model.get("autosave_ok", false)))
	_finish_button.pressed.connect(_on_finish_pressed)
	actions.add_child(_finish_button)
	_set_self_focus_neighbors(_finish_button)
	_refresh_hints()
	return footer


func _show_summary(play_sound: bool = true) -> void:
	if not is_instance_valid(_summary_root) or not is_instance_valid(_details_root):
		return
	_detail_page = 0
	_summary_root.visible = true
	_details_root.visible = false
	if play_sound:
		AudioManager.play_ui_click(-8.0)
	_refresh_hints()
	call_deferred("_focus_summary_cta")


func _show_details() -> void:
	if not is_open():
		return
	_summary_root.visible = false
	_details_root.visible = true
	_detail_page = 1
	_selected_row = int(_selected_rows_by_page.get(_detail_page, 0))
	_render_detail_page()
	AudioManager.play_ui_open(-9.0)
	call_deferred("_focus_detail_row")


func _render_detail_page() -> void:
	_clear_children(_details_root)
	_detail_rows.clear()
	_detail_entries.clear()
	_detail_readout = null

	var title_guard := MarginContainer.new()
	UIStyle.override_constant(title_guard, "margin_top", 8)
	title_guard.set_meta("core_loop_v2_details_top_guard", true)
	var title: Label = _label(str(_model.get("title", "")), 28, COLOR_TEXT, "bold")
	title.set_meta("core_loop_v2_details_title", true)
	title_guard.add_child(title)
	_details_root.add_child(title_guard)

	var nav := HBoxContainer.new()
	UIStyle.override_constant(nav, "separation", 10)
	nav.set_meta("core_loop_v2_page_navigation", true)
	_details_root.add_child(nav)
	_page_prev_button = _button("‹", false)
	_page_prev_button.custom_minimum_size = Vector2(52, 48)
	_page_prev_button.focus_mode = Control.FOCUS_NONE
	_page_prev_button.set_meta("core_loop_v2_page_prev", true)
	_page_prev_button.pressed.connect(_change_detail_page.bind(-1))
	nav.add_child(_page_prev_button)

	var page_heading := VBoxContainer.new()
	page_heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UIStyle.override_constant(page_heading, "separation", 0)
	nav.add_child(page_heading)
	_detail_page_title = _label(_page_title(), 20, COLOR_TEXT, "semibold")
	_detail_page_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_page_title.set_meta("core_loop_v2_page_title", true)
	page_heading.add_child(_detail_page_title)
	_detail_page_counter = _label(
		"%d / %d" % [_detail_page, _detail_page_count()],
		14, COLOR_TEXT_MUTED)
	_detail_page_counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_page_counter.set_meta("core_loop_v2_page_counter", true)
	page_heading.add_child(_detail_page_counter)

	_page_next_button = _button("›", false)
	_page_next_button.custom_minimum_size = Vector2(52, 48)
	_page_next_button.focus_mode = Control.FOCUS_NONE
	_page_next_button.set_meta("core_loop_v2_page_next", true)
	_page_next_button.pressed.connect(_change_detail_page.bind(1))
	nav.add_child(_page_next_button)

	_detail_page_host = HBoxContainer.new()
	_detail_page_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_page_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	UIStyle.override_constant(_detail_page_host, "separation", 12)
	_detail_page_host.set_meta("core_loop_v2_detail_page", true)
	_detail_page_host.set_meta("core_loop_v2_page_index", _detail_page)
	_details_root.add_child(_detail_page_host)

	_build_detail_rail()
	_build_detail_readout()
	_link_detail_focus_neighbors()
	_selected_row = clampi(
		int(_selected_rows_by_page.get(_detail_page, _selected_row)),
		0, maxi(0, _detail_rows.size() - 1))
	_selected_rows_by_page[_detail_page] = _selected_row
	_render_detail_readout(_selected_row)
	_refresh_detail_cursor()

	_detail_hint = _label("", 14, COLOR_TEXT_SECONDARY)
	_detail_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_hint.set_meta("core_loop_v2_detail_hint", true)
	_details_root.add_child(_detail_hint)
	_refresh_hints()


func _build_detail_rail() -> void:
	var rail := PanelContainer.new()
	rail.custom_minimum_size.x = 350
	rail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	UIStyle.override_stylebox(rail,
		"panel", _panel_style(COLOR_DEEP, COLOR_BORDER_SOFT, 6, 10, 4))
	rail.set_meta("core_loop_v2_detail_rail", true)
	_detail_page_host.add_child(rail)
	var rows := VBoxContainer.new()
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.size_flags_vertical = Control.SIZE_EXPAND_FILL
	UIStyle.override_constant(rows, "separation", 4)
	UIStyle.override_constant(rows, "v_separation", 4)
	rail.add_child(rows)

	if _detail_page <= _month_count():
		var month: Dictionary = (_model.get("months", []) as Array)[_detail_page - 1]
		var allocations: Array = month.get("allocations", [])
		var month_number: int = maxi(1, int(month.get("month", _detail_page)))
		for index in range(4):
			var allocation := str(allocations[index]).strip_edges()
			if allocation.is_empty():
				allocation = "—"
			var global_week := (month_number - 1) * 4 + index + 1
			_add_detail_entry(rows, {
				"kind": "allocation",
				"label": _tr(
					"%d주차 배치", "WEEK %d ALLOCATION") % global_week,
				"text": allocation,
				"source_index": index,
			})
		var outcomes: Array = month.get("outcomes", [])
		for index in range(outcomes.size()):
			_add_detail_entry(rows, {
				"kind": "outcome",
				"label": _tr("갈래 결과 %d", "NODE OUTCOME %d") % (index + 1),
				"text": str(outcomes[index]),
				"source_index": index,
			})
		var events: Array = month.get("events", [])
		if not events.is_empty():
			_add_detail_entry(rows, {
				"kind": "events",
				"label": _tr(
					"그 달에 열린 장면", "SCENES THAT OPENED"),
				"text": _joined_lines(events),
				"source_index": 0,
			})
		var missed: Array = month.get("missed", [])
		var missed_text := _joined_lines(missed)
		if missed_text.is_empty():
			missed_text = _tr("놓친 일이 없다.", "Nothing was missed.")
		_add_detail_entry(rows, {
			"kind": "missed",
			"label": _tr("놓친 일", "MISSED"),
			"text": missed_text,
			"source_index": 0,
		})
	else:
		var unresolved: Array = _model.get("unresolved", [])
		if unresolved.is_empty():
			_add_detail_entry(rows, {
				"kind": "unresolved",
				"label": _tr("미결 항목 없음", "NO OPEN THREADS"),
				"text": _tr(
					"남아 있는 미결 항목이 없다.", "No open threads remain."),
				"source_index": 0,
			})
		else:
			for index in range(unresolved.size()):
				_add_detail_entry(rows, {
					"kind": "unresolved",
					"label": _tr(
						"미결 %02d", "OPEN THREAD %02d") % (index + 1),
					"text": str(unresolved[index]),
					"source_index": index,
				})


func _add_detail_entry(parent: Container, entry: Dictionary) -> void:
	var index := _detail_entries.size()
	_detail_entries.append(entry)
	var button: Button = _button(str(entry.get("label", "")), false)
	button.custom_minimum_size.y = 40
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	button.set_meta("core_loop_v2_detail_row", true)
	button.set_meta("core_loop_v2_detail_row_index", index)
	button.set_meta("core_loop_v2_detail_entry_kind", str(entry.get("kind", "")))
	button.set_meta(
		"core_loop_v2_detail_source_index", int(entry.get("source_index", 0)))
	button.focus_entered.connect(_select_detail_row.bind(index, false))
	button.pressed.connect(_select_detail_row.bind(index, true))
	parent.add_child(button)
	_detail_rows.append(button)


func _build_detail_readout() -> void:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	UIStyle.override_stylebox(panel,
		"panel", _panel_style(COLOR_RAISED, COLOR_BORDER, 6, 18, 14))
	panel.set_meta("core_loop_v2_detail_readout", true)
	_detail_page_host.add_child(panel)
	_detail_readout = VBoxContainer.new()
	_detail_readout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_readout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	UIStyle.override_constant(_detail_readout, "separation", 7)
	panel.add_child(_detail_readout)


func _render_detail_readout(index: int) -> void:
	if not is_instance_valid(_detail_readout):
		return
	_clear_children(_detail_readout)
	if _detail_entries.is_empty():
		return
	var safe_index := clampi(index, 0, _detail_entries.size() - 1)
	var entry: Dictionary = _detail_entries[safe_index]
	var overline: Label = _label(str(entry.get("label", "")),
		14, COLOR_TEXT_MUTED, "semibold")
	_detail_readout.add_child(overline)
	_detail_readout.add_child(_separator())
	var text := str(entry.get("text", "")).strip_edges()
	if text.is_empty():
		text = "—"
	var body := _label(text, 15, COLOR_TEXT_SECONDARY)
	body.set_meta("core_loop_v2_detail_entry_index", safe_index)
	body.set_meta("core_loop_v2_detail_entry_text", text)
	_detail_readout.add_child(body)


func _change_detail_page(delta: int) -> void:
	if not details_visible():
		return
	_selected_rows_by_page[_detail_page] = _selected_row
	_detail_page = int(posmod(
		_detail_page - 1 + delta, _detail_page_count())) + 1
	_selected_row = int(_selected_rows_by_page.get(_detail_page, 0))
	_render_detail_page()
	AudioManager.play_ui_click(-8.0)
	call_deferred("_focus_detail_row")


func _select_detail_row(index: int, play_sound: bool = false) -> void:
	if not details_visible() or _detail_rows.is_empty():
		return
	_selected_row = clampi(index, 0, _detail_rows.size() - 1)
	_selected_rows_by_page[_detail_page] = _selected_row
	_render_detail_readout(_selected_row)
	_refresh_detail_cursor()
	if play_sound:
		_detail_rows[_selected_row].grab_focus()
		AudioManager.play_ui_click(-9.0)


func _move_detail_row(delta: int) -> bool:
	if _detail_rows.is_empty():
		return true
	_selected_row = clampi(
		_selected_row + delta, 0, _detail_rows.size() - 1)
	_selected_rows_by_page[_detail_page] = _selected_row
	_detail_rows[_selected_row].grab_focus()
	_render_detail_readout(_selected_row)
	_refresh_detail_cursor()
	AudioManager.play_ui_click(-10.0)
	return true


func _refresh_detail_cursor() -> void:
	for index in range(_detail_rows.size()):
		var button := _detail_rows[index]
		button.set_meta("core_loop_v2_detail_selected", index == _selected_row)
		UIStyle.override_stylebox(button,
			"normal", _button_style(
				COLOR_RAISED if index == _selected_row else COLOR_DEEP,
				COLOR_SELECTED if index == _selected_row else COLOR_BORDER_SOFT,
				2 if index == _selected_row else 1))


func _link_detail_focus_neighbors() -> void:
	if _detail_rows.is_empty():
		return
	for index in range(_detail_rows.size()):
		var button := _detail_rows[index]
		var own_path := button.get_path()
		var top_path := _detail_rows[maxi(0, index - 1)].get_path()
		var bottom_path := _detail_rows[mini(
			_detail_rows.size() - 1, index + 1)].get_path()
		button.focus_neighbor_top = top_path
		button.focus_neighbor_bottom = bottom_path
		button.focus_neighbor_left = own_path
		button.focus_neighbor_right = own_path
		button.focus_next = bottom_path
		button.focus_previous = top_path


func _focus_summary_cta() -> void:
	if summary_visible() and is_instance_valid(_finish_button):
		_finish_button.grab_focus()


func _focus_detail_row() -> void:
	if details_visible() and not _detail_rows.is_empty():
		_selected_row = clampi(_selected_row, 0, _detail_rows.size() - 1)
		_detail_rows[_selected_row].grab_focus()


func _on_finish_pressed() -> void:
	if not summary_visible() or _terminal_action_in_flight:
		return
	_terminal_action_in_flight = true
	if is_instance_valid(_finish_button):
		_finish_button.disabled = true
		_finish_button.focus_mode = Control.FOCUS_NONE
	if bool(_model.get("autosave_ok", false)):
		finish_requested.emit()
	else:
		retry_requested.emit()


func _on_input_mode_changed(
		_mode: ControllerHints.InputMode, _brand: ControllerHints.Brand) -> void:
	if is_open():
		_refresh_hints()


func _refresh_hints() -> void:
	if is_instance_valid(_details_button):
		_details_button.text = _tr(
			"[%s] %d개월 기록 보기", "[%s] View %d-Month Record") \
			% [ControllerHints.north(), _month_count()]
	if is_instance_valid(_finish_button):
		_finish_button.text = (
			_tr("[%s] 자동 저장 다시 시도", "[%s] Retry Autosave")
			% ControllerHints.south()
			if not bool(_model.get("autosave_ok", false)) else
			_tr(
				"[%s] 데모를 마치고 시작 화면으로",
				"[%s] Finish Demo · Return to Title")
			% ControllerHints.south()
		)
	if is_instance_valid(_detail_hint):
		_detail_hint.text = _tr(
			"[%s/%s] 페이지 이동  ·  ↑↓ 기록 선택  ·  [%s] 결산으로",
			"[%s/%s] Change Page  ·  ↑↓ Select Record  ·  [%s] Recap"
		) % [
			ControllerHints.shoulder_l(),
			ControllerHints.shoulder_r(),
			ControllerHints.east(),
			]


func _input(event: InputEvent) -> void:
	if not is_open() or not event is InputEventJoypadButton:
		return
	var joy := event as InputEventJoypadButton
	if not joy.pressed:
		return
	var handled := false
	if details_visible():
		match joy.button_index:
			JOY_BUTTON_B:
				_show_summary()
				handled = true
			JOY_BUTTON_LEFT_SHOULDER:
				_change_detail_page(-1)
				handled = true
			JOY_BUTTON_RIGHT_SHOULDER:
				_change_detail_page(1)
				handled = true
			JOY_BUTTON_DPAD_UP:
				handled = _move_detail_row(-1)
			JOY_BUTTON_DPAD_DOWN:
				handled = _move_detail_row(1)
			JOY_BUTTON_A, JOY_BUTTON_Y:
				# The ledger is read-only. South/North cannot commit or exit it.
				handled = true
	else:
		match joy.button_index:
			JOY_BUTTON_Y:
				_show_details()
				handled = true
			JOY_BUTTON_A:
				_on_finish_pressed()
				handled = true
			JOY_BUTTON_B, JOY_BUTTON_LEFT_SHOULDER, \
					JOY_BUTTON_RIGHT_SHOULDER:
				# The terminal recap is flow-protected.
				handled = true
	if handled:
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if not is_open():
		return
	if event is InputEventKey and (event as InputEventKey).echo:
		return

	var handled := false
	if details_visible():
		if event.is_action_pressed("ui_cancel") \
				or _joy_button_pressed(event, JOY_BUTTON_B):
			_show_summary()
			handled = true
		elif event.is_action_pressed("gd_tab_prev") \
				or _joy_button_pressed(event, JOY_BUTTON_LEFT_SHOULDER):
			_change_detail_page(-1)
			handled = true
		elif event.is_action_pressed("gd_tab_next") \
				or _joy_button_pressed(event, JOY_BUTTON_RIGHT_SHOULDER):
			_change_detail_page(1)
			handled = true
		elif event.is_action_pressed("ui_up") \
				or _joy_button_pressed(event, JOY_BUTTON_DPAD_UP):
			handled = _move_detail_row(-1)
		elif event.is_action_pressed("ui_down") \
				or _joy_button_pressed(event, JOY_BUTTON_DPAD_DOWN):
			handled = _move_detail_row(1)
		elif event.is_action_pressed("ui_accept") \
				or _joy_button_pressed(event, JOY_BUTTON_A) \
				or ControllerHints.details_pressed(event):
			# Details are read-only. South never commits or exits from this layer.
			handled = true
	else:
		if ControllerHints.details_pressed(event):
			_show_details()
			handled = true
		elif event.is_action_pressed("ui_accept") \
				or _joy_button_pressed(event, JOY_BUTTON_A):
			_on_finish_pressed()
			handled = true
		elif event.is_action_pressed("ui_cancel") \
				or _joy_button_pressed(event, JOY_BUTTON_B) \
				or event.is_action_pressed("gd_tab_prev") \
				or event.is_action_pressed("gd_tab_next"):
			# The terminal recap is flow-protected. East cannot dismiss it.
			handled = true

	if handled:
		get_viewport().set_input_as_handled()


func _joy_button_pressed(event: InputEvent, button_index: JoyButton) -> bool:
	if not event is InputEventJoypadButton:
		return false
	var joy := event as InputEventJoypadButton
	return joy.pressed and int(joy.button_index) == int(button_index)


func _page_title() -> String:
	if _detail_page <= _month_count():
		var month: Dictionary = (_model.get("months", []) as Array)[_detail_page - 1]
		var title := str(month.get("title", "")).strip_edges()
		if not title.is_empty():
			return title
		return _tr("%d개월째", "Month %d") % int(month.get("month", _detail_page))
	return _tr("아직 풀리지 않은 일", "Still Unresolved")


func _month_count() -> int:
	return (_model.get("months", []) as Array).size()


func _detail_page_count() -> int:
	return _month_count() + 1


func _outcome_color(kind: String) -> Color:
	match kind:
		"selected", "completed", "finished", "kept":
			return COLOR_SELECTED
		"expired", "deadline":
			return COLOR_EXPIRED
		_:
			return COLOR_DEFERRED


func _joined_lines(values: Array) -> String:
	var lines: Array[String] = []
	for value in values:
		var text := str(value).strip_edges()
		if not text.is_empty():
			lines.append("— %s" % text)
	return "\n".join(lines)


func _tr(ko: String, en: String) -> String:
	return LocaleManager.ui(ko, en)


func _label(
		text: String, font_size: int, color: Color,
		weight: String = "regular") -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	label.clip_text = false
	UIStyle.override_font_size(label, "font_size", font_size)
	UIStyle.override_color(label, "font_color", color)
	UIStyle.override_color(label, "font_shadow_color", Color(0, 0, 0, 0))
	UIStyle.override_constant(label, "shadow_offset_x", 0)
	UIStyle.override_constant(label, "shadow_offset_y", 0)
	UIStyle.override_constant(label, "shadow_outline_size", 0)
	match weight:
		"bold":
			if _font_bold:
				label.add_theme_font_override("font", _font_bold)
		"semibold":
			if _font_semibold:
				label.add_theme_font_override("font", _font_semibold)
		_:
			if _font_regular:
				label.add_theme_font_override("font", _font_regular)
	return label


func _button(text: String, primary: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 48
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	UIStyle.override_font_size(button, "font_size", 15)
	UIStyle.override_color(button, "font_color", COLOR_TEXT)
	UIStyle.override_color(button, "font_hover_color", COLOR_TEXT)
	UIStyle.override_color(button, "font_pressed_color", COLOR_TEXT)
	UIStyle.override_color(button, "font_focus_color", COLOR_TEXT)
	if _font_semibold:
		button.add_theme_font_override("font", _font_semibold)
	var normal_bg := COLOR_RAISED if primary else COLOR_DEEP
	var normal_border := COLOR_SELECTED if primary else COLOR_BORDER
	UIStyle.override_stylebox(button,
		"normal", _button_style(normal_bg, normal_border, 1))
	UIStyle.override_stylebox(button,
		"hover", _button_style(Color("#24272c"), COLOR_TEXT_MUTED, 2))
	UIStyle.override_stylebox(button,
		"pressed", _button_style(Color("#0b0c0e"), COLOR_TEXT_SECONDARY, 1))
	UIStyle.override_stylebox(button,
		"focus", _focus_style())
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	return button


func _set_self_focus_neighbors(button: Button) -> void:
	var path := NodePath(".")
	button.focus_neighbor_top = path
	button.focus_neighbor_bottom = path
	button.focus_neighbor_left = path
	button.focus_neighbor_right = path
	button.focus_next = path
	button.focus_previous = path


func _panel_style(
		background: Color, border: Color, radius: int,
		horizontal_margin: int, vertical_margin: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = UIStyle.panel_style(
		background.to_html(), border.to_html(), radius)
	style.content_margin_left = horizontal_margin
	style.content_margin_right = horizontal_margin
	style.content_margin_top = vertical_margin
	style.content_margin_bottom = vertical_margin
	return style


func _button_style(
		background: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = UIStyle.panel_style(
		background.to_html(), border.to_html(), 6)
	style.set_border_width_all(border_width)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _focus_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = UIStyle.panel_style(
		Color.TRANSPARENT.to_html(), COLOR_FOCUS.to_html(), 6)
	style.set_border_width_all(3)
	# Focus is an outline only; keep the former unset content margins.
	style.content_margin_left = -1.0
	style.content_margin_right = -1.0
	style.content_margin_top = -1.0
	style.content_margin_bottom = -1.0
	return style


func _separator() -> HSeparator:
	var separator := HSeparator.new()
	UIStyle.override_color(separator, "separator", COLOR_BORDER_SOFT)
	separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return separator


func _clear_children(parent: Node) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()
