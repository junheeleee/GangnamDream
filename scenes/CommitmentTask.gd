extends Control
## ORDER-92: scene-positioned commitment task overlay.
##
## The host owns persistence and transaction application. This surface only
## presents authored task data, emits selection snapshots, and confirms one of
## the two explicit resolutions.

signal selection_changed(bundle_id: String, selected_ids: Array)
signal resolution_confirmed(bundle_id: String, selected_ids: Array, overreached: bool)

const COLOR_TEXT := Color("#edf1f5")
const COLOR_DIM := Color("#9aa3ad")
const COLOR_MUTED := Color("#6f7882")
const COLOR_ACCENT := Color("#d8c38d")
const COLOR_GOOD := Color("#9ec4a9")
const COLOR_DANGER := Color("#d28b82")
const COLOR_INK := Color("#07090c")
const COLOR_PANEL := Color("#0d1116", 0.94)
const COLOR_PANEL_ALT := Color("#141a20", 0.94)
const VALID_SCENE_SLOTS := ["left", "center", "right"]
const EFFECT_KEYS := ["money", "health", "mental"]
const TARGET_MARKER_NAME := "PhysicalTargetMarker"
const TARGET_SWEEP_NAME := "PhysicalTargetSweep"

var _bundle_id := ""
var _spec: Dictionary = {}
var _selected_ids: Array = []
var _requirements_by_id: Dictionary = {}
var _requirement_order: Array = []
var _normal_steps := 2
var _ambience_key := ""
var _ambience_owned := false
var _resolution_locked := false
var _open_generation := 0
var _feedback_override := ""
var _inspected_requirement_id := ""
var _overreach_requirement_id := ""
var _target_feedback_tweens: Dictionary = {}

var _font: FontFile
var _font_bold: FontFile
var _background: TextureRect
var _header_panel: Panel
var _task_id_label: Label
var _intro_label: Label
var _instruction_label: Label
var _remaining_label: Label
var _progress_blocks: Array[PanelContainer] = []
var _target_layer: Control
var _target_buttons: Dictionary = {}
var _feedback_panel: Panel
var _feedback_label: Label
var _footer_panel: Panel
var _preview_label: Label
var _normal_button: Button
var _overreach_button: Button
var _hint_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	set_meta("core_loop_v2_commitment_task", true)
	set_meta("commitment_task_facet_ids", [])
	z_index = 108
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	_font = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile
	_build_ui()
	resized.connect(_apply_geometry)
	LocaleManager.language_changed.connect(_on_language_changed)
	ControllerHints.input_mode_changed.connect(_on_input_mode_changed)
	visible = false


func open(bundle_id: String, spec: Dictionary, session: Dictionary = {}) -> bool:
	if bundle_id.strip_edges().is_empty() or not _valid_spec(spec):
		return false
	_stop_target_feedback_tweens()
	_release_activity_ambience()
	_open_generation += 1
	_bundle_id = bundle_id
	_spec = spec.duplicate(true)
	_normal_steps = int(_spec.get("normal_steps", 2))
	_ambience_key = str(_spec.get("ambience", ""))
	_requirements_by_id.clear()
	_requirement_order.clear()
	_target_buttons.clear()
	for raw_requirement in _spec.get("requirements", []):
		var requirement: Dictionary = raw_requirement
		var requirement_id := str(requirement.get("id", ""))
		_requirements_by_id[requirement_id] = requirement.duplicate(true)
		_requirement_order.append(requirement_id)
	_selected_ids = _restored_selection(session.get("selected_requirements", []))
	_feedback_override = ""
	_overreach_requirement_id = ""
	_inspected_requirement_id = (
		str(_selected_ids.back())
		if not _selected_ids.is_empty() else str(_requirement_order[0]))
	_resolution_locked = false
	var background_path := str(_spec.get("background_path", ""))
	_background.texture = load(background_path) as Texture2D
	_rebuild_targets()
	_refresh_all()
	visible = true
	move_to_front()
	_apply_geometry()
	if not _ambience_key.is_empty():
		BGMPlayer.enter_activity_ambience(_ambience_key)
		_ambience_owned = true
	AudioManager.play_ui_open(-8.0)
	call_deferred("_focus_initial", _open_generation)
	return true


func close_committed() -> void:
	_open_generation += 1
	_stop_target_feedback_tweens()
	var was_visible := visible
	if was_visible:
		var focused := get_viewport().gui_get_focus_owner()
		if focused is Control and is_ancestor_of(focused):
			(focused as Control).release_focus()
	visible = false
	_resolution_locked = false
	_release_activity_ambience()
	if was_visible:
		AudioManager.play_ui_close(-11.0)
	_bundle_id = ""
	_spec.clear()
	_selected_ids.clear()
	_requirements_by_id.clear()
	_requirement_order.clear()
	_feedback_override = ""
	_inspected_requirement_id = ""
	_overreach_requirement_id = ""


func is_open() -> bool:
	return visible


func _exit_tree() -> void:
	_stop_target_feedback_tweens()
	_release_activity_ambience()


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not event.is_action_pressed("ui_cancel"):
		return
	get_viewport().set_input_as_handled()
	if _resolution_locked:
		return
	_undo_last_selection()


func _undo_last_selection() -> void:
	if not _selected_ids.is_empty():
		_selected_ids.pop_back()
		_inspected_requirement_id = (
			str(_selected_ids.back())
			if not _selected_ids.is_empty() else str(_requirement_order[0]))
		_feedback_override = LocaleManager.ui(
			"마지막 선택을 되돌렸다.",
			"The last selection was undone.")
		AudioManager.play_ui_close(-12.0)
		_refresh_all()
		selection_changed.emit(_bundle_id, _selected_ids.duplicate())
		call_deferred("_ensure_valid_focus", _open_generation)
	else:
		_feedback_override = LocaleManager.ui(
			"이미 맡은 근무다. 일을 마쳐야 나갈 수 있다.",
			"This shift is already yours. Finish the work before leaving.")
		AudioManager.play_ui_close(-15.0)
		_refresh_feedback()


func _build_ui() -> void:
	_background = TextureRect.new()
	_background.name = "CommitmentTaskWarehouseBackground"
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background)

	var scene_tint := TextureRect.new()
	scene_tint.name = "CommitmentTaskSceneTint"
	scene_tint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene_tint.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	scene_tint.stretch_mode = TextureRect.STRETCH_SCALE
	scene_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tint_gradient := Gradient.new()
	tint_gradient.offsets = PackedFloat32Array([0.0, 0.38, 0.7, 1.0])
	tint_gradient.colors = PackedColorArray([
		Color("#020407", 0.78),
		Color("#05080b", 0.24),
		Color("#05080b", 0.34),
		Color("#020407", 0.90),
	])
	var tint_texture := GradientTexture2D.new()
	tint_texture.width = 32
	tint_texture.height = 512
	tint_texture.fill_from = Vector2(0.5, 0.0)
	tint_texture.fill_to = Vector2(0.5, 1.0)
	tint_texture.gradient = tint_gradient
	scene_tint.texture = tint_texture
	add_child(scene_tint)

	_header_panel = Panel.new()
	_header_panel.name = "CommitmentTaskHeader"
	_header_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_header_panel.clip_contents = true
	_header_panel.add_theme_stylebox_override(
		"panel", _panel_style(Color("#080b0f", 0.88), Color("#39414a", 0.72), 1, 3))
	add_child(_header_panel)
	_task_id_label = _label("", 11, COLOR_ACCENT, true)
	_task_id_label.name = "CommitmentTaskTitle"
	_header_panel.add_child(_task_id_label)
	_intro_label = _label("", 20, COLOR_TEXT, true)
	_intro_label.name = "CommitmentTaskIntro"
	_intro_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_header_panel.add_child(_intro_label)
	_instruction_label = _label("", 13, COLOR_DIM)
	_instruction_label.name = "CommitmentTaskInstruction"
	_instruction_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_header_panel.add_child(_instruction_label)
	_remaining_label = _label("", 13, COLOR_TEXT, true)
	_remaining_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_header_panel.add_child(_remaining_label)
	for index in range(2):
		var block := PanelContainer.new()
		block.name = "RemainingUnit%d" % (index + 1)
		block.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var unit_label := _label(str(index + 1), 12, COLOR_INK, true)
		unit_label.name = "HandoffTimeUnitLabel"
		unit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		unit_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		block.add_child(unit_label)
		_header_panel.add_child(block)
		_progress_blocks.append(block)

	_target_layer = Control.new()
	_target_layer.name = "WarehousePhysicalTargets"
	_target_layer.mouse_filter = Control.MOUSE_FILTER_PASS
	_target_layer.clip_contents = true
	add_child(_target_layer)

	_feedback_panel = Panel.new()
	_feedback_panel.name = "CommitmentTaskWorkFeedback"
	_feedback_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_feedback_panel.clip_contents = true
	_feedback_panel.add_theme_stylebox_override(
		"panel", _panel_style(Color("#0a0d10", 0.88), Color("#343c45", 0.78), 1, 2))
	add_child(_feedback_panel)
	_feedback_label = _label("", 12, COLOR_DIM)
	_feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feedback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_feedback_panel.add_child(_feedback_label)

	_footer_panel = Panel.new()
	_footer_panel.name = "CommitmentTaskResolutionBench"
	_footer_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_footer_panel.clip_contents = true
	_footer_panel.add_theme_stylebox_override(
		"panel", _panel_style(COLOR_PANEL, Color("#4a535d"), 1, 3))
	add_child(_footer_panel)
	_preview_label = _label("", 13, COLOR_TEXT)
	_preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_preview_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_footer_panel.add_child(_preview_label)
	_normal_button = _resolution_button("CommitmentTaskNormalConfirm", false)
	_normal_button.set_meta("commitment_task_normal_confirm", true)
	_normal_button.set_meta("core_loop_v2_commitment_task_normal_confirm", true)
	_normal_button.pressed.connect(_on_resolution_pressed.bind(false))
	_footer_panel.add_child(_normal_button)
	_overreach_button = _resolution_button("CommitmentTaskOverreachConfirm", true)
	_overreach_button.set_meta("commitment_task_overreach_confirm", true)
	_overreach_button.set_meta("core_loop_v2_commitment_task_overreach_confirm", true)
	_overreach_button.pressed.connect(_on_resolution_pressed.bind(true))
	_footer_panel.add_child(_overreach_button)
	_hint_label = _label("", 11, COLOR_DIM)
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_footer_panel.add_child(_hint_label)


func _rebuild_targets() -> void:
	for child in _target_layer.get_children():
		_target_layer.remove_child(child)
		child.queue_free()
	_target_buttons.clear()
	for raw_id in _requirement_order:
		var requirement_id := str(raw_id)
		var requirement: Dictionary = _requirements_by_id.get(requirement_id, {})
		var button := Button.new()
		button.name = "WorkTarget_%s" % requirement_id
		button.focus_mode = Control.FOCUS_ALL
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		button.add_theme_font_override("font", _font_bold)
		button.add_theme_color_override("font_outline_color", Color("#020305", 0.98))
		button.add_theme_constant_override("outline_size", 4)
		button.set_meta("commitment_task_facet_id", requirement_id)
		button.set_meta("core_loop_v2_commitment_task_facet_id", requirement_id)
		button.set_meta("action_requirement_id", requirement_id)
		button.set_meta("scene_slot", str(requirement.get("scene_slot", "")))
		button.pressed.connect(_on_requirement_pressed.bind(requirement_id))
		button.mouse_entered.connect(_on_target_mouse_entered.bind(button))
		button.focus_entered.connect(_on_target_focus_entered.bind(requirement_id))
		button.focus_exited.connect(_on_target_focus_exited.bind(button))
		var marker := Control.new()
		marker.name = TARGET_MARKER_NAME
		marker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
		marker.draw.connect(_draw_target_marker.bind(button, marker))
		button.add_child(marker)
		var sweep := ColorRect.new()
		sweep.name = TARGET_SWEEP_NAME
		sweep.color = Color(COLOR_ACCENT, 0.72)
		sweep.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sweep.visible = false
		button.add_child(sweep)
		_target_layer.add_child(button)
		_target_buttons[requirement_id] = button
	_connect_focus_neighbors()


func _refresh_all() -> void:
	if _spec.is_empty():
		return
	_task_id_label.text = _task_title()
	_intro_label.text = _localized(_spec, "intro")
	_instruction_label.text = _localized(_spec, "instruction")
	set_meta("commitment_task_bundle_id", _bundle_id)
	set_meta("commitment_task_selected_ids", _selected_ids.duplicate())
	set_meta("commitment_task_remaining_count", maxi(0, _normal_steps - _selected_ids.size()))
	set_meta("commitment_task_facet_ids", _requirement_order.duplicate())
	_refresh_progress()
	_refresh_targets()
	_refresh_feedback()
	_refresh_resolution()
	_refresh_hint()
	_queue_geometry_refresh()


func _refresh_progress() -> void:
	var remaining := maxi(0, _normal_steps - _selected_ids.size())
	_remaining_label.text = LocaleManager.ui(
		"교대 전 더 할 수 있는 일 %d개",
		"%d MORE BEFORE HANDOFF") % remaining
	for index in range(_progress_blocks.size()):
		var spent := index < _selected_ids.size()
		var block: PanelContainer = _progress_blocks[index]
		block.add_theme_stylebox_override("panel", _panel_style(
			COLOR_ACCENT if spent else Color("#151b21", 0.96),
			COLOR_ACCENT if spent else Color("#69737d"),
			2 if spent else 1,
			1))
		var unit_label := block.get_node_or_null("HandoffTimeUnitLabel") as Label
		if is_instance_valid(unit_label):
			unit_label.add_theme_color_override(
				"font_color", COLOR_INK if spent else COLOR_TEXT)


func _refresh_targets() -> void:
	for raw_id in _requirement_order:
		var requirement_id := str(raw_id)
		var button: Button = _target_buttons.get(requirement_id)
		if not is_instance_valid(button):
			continue
		var requirement: Dictionary = _requirements_by_id.get(requirement_id, {})
		var selected_index := _selected_ids.find(requirement_id)
		var display_order := selected_index + 1
		if selected_index < 0 and requirement_id == _overreach_requirement_id:
			display_order = _normal_steps + 1
		var prefix := "--"
		if display_order > 0:
			prefix = "%02d" % display_order
		button.text = "%s  %s\n%s" % [
			prefix,
			_target_station_label(requirement),
			_target_short_label(requirement),
		]
		button.set_meta("selected_order", display_order)
		_apply_target_style(button, display_order > 0)
		var marker := button.get_node_or_null(TARGET_MARKER_NAME) as Control
		if is_instance_valid(marker):
			marker.queue_redraw()


func _refresh_feedback() -> void:
	if not _feedback_override.is_empty():
		_feedback_label.text = _feedback_override
		return
	if _inspected_requirement_id.is_empty() \
			or not _requirements_by_id.has(_inspected_requirement_id):
		_feedback_label.text = LocaleManager.ui(
			"창고 안의 작업 지점을 골라 직접 처리한다.",
			"Choose a work target in the warehouse and handle it directly.")
		return
	var requirement: Dictionary = _requirements_by_id.get(
		_inspected_requirement_id, {})
	var selected_index := _selected_ids.find(_inspected_requirement_id)
	if selected_index >= 0:
		_feedback_label.text = "%s %02d · %s" % [
			LocaleManager.ui("처리 완료", "COMPLETED"),
			selected_index + 1,
			_localized(requirement, "feedback"),
		]
	else:
		_feedback_label.text = "%s · %s" % [
			LocaleManager.ui("작업 확인", "INSPECT"),
			_localized(requirement, "detail"),
		]


func _refresh_resolution() -> void:
	var outcome := _selected_normal_outcome()
	var ready := _selected_ids.size() == _normal_steps and not outcome.is_empty()
	_normal_button.disabled = not ready or _resolution_locked
	_overreach_button.disabled = not ready or _resolution_locked
	if not ready:
		_preview_label.text = LocaleManager.ui(
			"두 작업을 고르면 일반 완료와 무리하기의 최종 결과를 비교할 수 있다.",
			"Choose two tasks to compare the final results of finishing normally or overreaching.")
		_normal_button.text = LocaleManager.ui(
			"이대로 마친다",
			"FINISH NORMALLY")
		_overreach_button.text = LocaleManager.ui(
			"남은 일까지 무리해서 처리한다",
			"HANDLE ALL THREE")
		return
	var normal_effects: Dictionary = outcome.get("effects", {})
	var overreach: Dictionary = _spec.get("overreach", {})
	var overreach_effects: Dictionary = overreach.get("effects", {})
	var omitted_id := _omitted_requirement_id()
	var omitted: Dictionary = _requirements_by_id.get(omitted_id, {})
	_preview_label.text = "%s · %s\n%s" % [
		LocaleManager.ui("남겨 둔 작업", "TASK LEFT") + ": " + _localized(omitted, "label"),
		_effect_line(normal_effects),
		_localized(outcome, "preview"),
	]
	_normal_button.text = "%s\n%s · %s" % [
		LocaleManager.ui("이대로 마친다", "FINISH NORMALLY"),
		LocaleManager.ui("최종 결과", "FINAL"),
		_effect_line(normal_effects),
	]
	_overreach_button.text = "%s\n%s · %s" % [
		_overreach_prompt(overreach),
		LocaleManager.ui("무리하기 최종 결과", "OVERREACH FINAL"),
		_effect_line(overreach_effects),
	]


func _refresh_hint() -> void:
	var movement_hint := LocaleManager.ui(
		"방향 이동",
		"D-PAD MOVE" if ControllerHints.is_pad_active() else "ARROWS MOVE")
	_hint_label.text = LocaleManager.ui(
		"%s  ·  %s 선택/완료  ·  %s 마지막 선택 취소",
		"%s  ·  %s SELECT/FINISH  ·  %s UNDO LAST") % [
		movement_hint,
		ControllerHints.south(),
		ControllerHints.east(),
	]


func _on_requirement_pressed(requirement_id: String) -> void:
	if _resolution_locked or not _requirements_by_id.has(requirement_id):
		return
	_feedback_override = ""
	_inspected_requirement_id = requirement_id
	var newly_selected := false
	var selected_index := _selected_ids.find(requirement_id)
	if selected_index >= 0:
		_selected_ids.remove_at(selected_index)
		AudioManager.play_ui_close(-12.0)
	elif _selected_ids.size() < _normal_steps:
		_selected_ids.append(requirement_id)
		newly_selected = true
	else:
		_feedback_override = LocaleManager.ui(
			"두 가지를 이미 골랐다. 마지막 선택을 취소한 뒤 바꿀 수 있다.",
			"Two tasks are already chosen. Undo the last selection to change one.")
		AudioManager.play_ui_close(-15.0)
		_refresh_feedback()
		_queue_geometry_refresh()
		return
	_refresh_all()
	if newly_selected:
		_play_requirement_feedback(requirement_id)
	selection_changed.emit(_bundle_id, _selected_ids.duplicate())


func _on_resolution_pressed(overreached: bool) -> void:
	if _resolution_locked or _selected_ids.size() != _normal_steps:
		return
	var outcome := _selected_normal_outcome()
	if outcome.is_empty():
		return
	_resolution_locked = true
	var generation := _open_generation
	if overreached:
		_overreach_requirement_id = _omitted_requirement_id()
		_inspected_requirement_id = _overreach_requirement_id
		var omitted: Dictionary = _requirements_by_id.get(
			_overreach_requirement_id, {})
		_feedback_override = "%s 03 · %s" % [
			LocaleManager.ui("남은 일 처리", "HANDLING LAST TASK"),
			_localized(omitted, "feedback"),
		]
	else:
		_feedback_override = _localized(outcome, "finish")
	_refresh_all()
	_queue_geometry_refresh()
	if overreached:
		_play_requirement_feedback(_overreach_requirement_id)
		await get_tree().create_timer(0.32, true, false, true).timeout
		if generation != _open_generation or not visible:
			return
	else:
		AudioManager.play("choice_made", -7.0)
	resolution_confirmed.emit(_bundle_id, _selected_ids.duplicate(), overreached)
	call_deferred("_release_resolution_guard", generation)


func _release_resolution_guard(generation: int) -> void:
	if generation != _open_generation or not visible:
		return
	# A successful host transaction closes this surface synchronously. If the
	# host rejects it, restore controls on the next frame instead of trapping the
	# player without requiring another public callback.
	_resolution_locked = false
	_overreach_requirement_id = ""
	_feedback_override = ""
	_inspected_requirement_id = (
		str(_selected_ids.back())
		if not _selected_ids.is_empty() else str(_requirement_order[0]))
	_refresh_all()


func _on_target_mouse_entered(button: Button) -> void:
	if visible and not button.disabled:
		button.grab_focus()


func _on_target_focus_entered(requirement_id: String) -> void:
	if not visible or not _requirements_by_id.has(requirement_id):
		return
	_inspected_requirement_id = requirement_id
	_feedback_override = ""
	_refresh_feedback()
	_refresh_target_markers()


func _on_target_focus_exited(button: Button) -> void:
	var marker := button.get_node_or_null(TARGET_MARKER_NAME) as Control
	if is_instance_valid(marker):
		marker.queue_redraw()


func _on_language_changed(_language: String = "") -> void:
	if visible:
		_feedback_override = ""
		_refresh_all()


func _on_input_mode_changed(_mode: int, _brand: int) -> void:
	if visible:
		_refresh_hint()


func _focus_initial(generation: int) -> void:
	if generation != _open_generation or not visible or _requirement_order.is_empty():
		return
	if _selected_ids.size() == _normal_steps \
			and is_instance_valid(_normal_button) and not _normal_button.disabled:
		_normal_button.grab_focus()
		return
	for raw_id in _requirement_order:
		var requirement_id := str(raw_id)
		if requirement_id in _selected_ids:
			continue
		var next_button: Button = _target_buttons.get(requirement_id)
		if is_instance_valid(next_button):
			next_button.grab_focus()
			return
	var first_button: Button = _target_buttons.get(str(_requirement_order[0]))
	if is_instance_valid(first_button):
		first_button.grab_focus()


func _ensure_valid_focus(generation: int) -> void:
	if generation != _open_generation or not visible:
		return
	var focused := get_viewport().gui_get_focus_owner()
	if focused is Control and is_ancestor_of(focused) and not (focused as Control).is_focus_owner():
		focused = null
	if focused is Button and not (focused as Button).disabled:
		return
	if not _selected_ids.is_empty():
		var selected_button: Button = _target_buttons.get(str(_selected_ids.back()))
		if is_instance_valid(selected_button):
			selected_button.grab_focus()
			return
	_focus_initial(generation)


func _queue_geometry_refresh() -> void:
	if is_inside_tree():
		call_deferred("_apply_geometry_for_generation", _open_generation)


func _apply_geometry_for_generation(generation: int) -> void:
	if generation == _open_generation and visible:
		_apply_geometry()


func _connect_focus_neighbors() -> void:
	if _requirement_order.size() != 3:
		return
	var left_button := _button_for_slot("left")
	var center_button := _button_for_slot("center")
	var right_button := _button_for_slot("right")
	if not is_instance_valid(left_button) or not is_instance_valid(center_button) \
			or not is_instance_valid(right_button):
		return
	left_button.focus_neighbor_left = left_button.get_path_to(left_button)
	left_button.focus_neighbor_right = left_button.get_path_to(center_button)
	left_button.focus_neighbor_top = left_button.get_path_to(left_button)
	left_button.focus_neighbor_bottom = left_button.get_path_to(_normal_button)
	center_button.focus_neighbor_left = center_button.get_path_to(left_button)
	center_button.focus_neighbor_right = center_button.get_path_to(right_button)
	center_button.focus_neighbor_top = center_button.get_path_to(center_button)
	center_button.focus_neighbor_bottom = center_button.get_path_to(_normal_button)
	right_button.focus_neighbor_left = right_button.get_path_to(center_button)
	right_button.focus_neighbor_right = right_button.get_path_to(right_button)
	right_button.focus_neighbor_top = right_button.get_path_to(right_button)
	right_button.focus_neighbor_bottom = right_button.get_path_to(_overreach_button)
	_normal_button.focus_neighbor_left = _normal_button.get_path_to(_normal_button)
	_normal_button.focus_neighbor_right = _normal_button.get_path_to(_overreach_button)
	_normal_button.focus_neighbor_top = _normal_button.get_path_to(center_button)
	_normal_button.focus_neighbor_bottom = _normal_button.get_path_to(_normal_button)
	_overreach_button.focus_neighbor_left = _overreach_button.get_path_to(_normal_button)
	_overreach_button.focus_neighbor_right = _overreach_button.get_path_to(_overreach_button)
	_overreach_button.focus_neighbor_top = _overreach_button.get_path_to(right_button)
	_overreach_button.focus_neighbor_bottom = _overreach_button.get_path_to(_overreach_button)


func _apply_geometry() -> void:
	if not is_instance_valid(_header_panel):
		return
	var compact := size.x < 1100.0 or size.y < 700.0
	var reduced_output := _physical_output_scale() < 0.9
	var margin_x := 22.0 if compact else 32.0
	var top_margin := 18.0 if compact else 24.0
	var bottom_margin := 18.0 if compact else 24.0
	var header_height := 176.0 if reduced_output else (166.0 if compact else 148.0)
	var footer_height := 210.0 if compact else 218.0
	var feedback_height := 82.0
	_header_panel.position = Vector2(margin_x, top_margin)
	_header_panel.size = Vector2(maxf(0.0, size.x - margin_x * 2.0), header_height)
	var header_inner_width := maxf(0.0, _header_panel.size.x - 32.0)
	_task_id_label.position = Vector2(16.0, 8.0)
	_task_id_label.size = Vector2(maxf(0.0, header_inner_width - 360.0), 25.0)
	_remaining_label.position = Vector2(
		maxf(16.0, _header_panel.size.x - 360.0), 8.0)
	_remaining_label.size = Vector2(236.0, 25.0)
	for index in range(_progress_blocks.size()):
		var block: PanelContainer = _progress_blocks[index]
		block.position = Vector2(
			_header_panel.size.x - 112.0 + index * 50.0,
			11.0)
		block.size = Vector2(42.0, 18.0)
		var unit_label := block.get_node_or_null("HandoffTimeUnitLabel") as Label
		if is_instance_valid(unit_label):
			unit_label.add_theme_font_size_override(
				"font_size", _readable_font_size(11, 10))
	_intro_label.position = Vector2(16.0, 37.0)
	_intro_label.size = Vector2(
		header_inner_width,
		70.0 if reduced_output else (54.0 if compact else 50.0))
	_instruction_label.position = Vector2(
		16.0,
		112.0 if reduced_output else (98.0 if compact else 92.0))
	_instruction_label.size = Vector2(
		header_inner_width,
		56.0 if reduced_output else (58.0 if compact else 47.0))
	_footer_panel.position = Vector2(
		margin_x,
		maxf(header_height + top_margin + 20.0, size.y - bottom_margin - footer_height))
	_footer_panel.size = Vector2(maxf(0.0, size.x - margin_x * 2.0), footer_height)
	var footer_inner_width := maxf(0.0, _footer_panel.size.x - 32.0)
	var preview_height := 68.0
	var action_top := 72.0
	var action_height := 88.0
	var action_gap := 10.0
	var action_width := maxf(0.0, (footer_inner_width - action_gap) / 2.0)
	_preview_label.position = Vector2(16.0, 3.0)
	_preview_label.size = Vector2(footer_inner_width, preview_height)
	_normal_button.position = Vector2(16.0, action_top)
	_normal_button.size = Vector2(action_width, action_height)
	_overreach_button.position = Vector2(16.0 + action_width + action_gap, action_top)
	_overreach_button.size = Vector2(action_width, action_height)
	_hint_label.position = Vector2(16.0, footer_height - 35.0)
	_hint_label.size = Vector2(footer_inner_width, 28.0)
	_feedback_panel.position = Vector2(
		margin_x,
		_footer_panel.position.y - feedback_height - 8.0)
	_feedback_panel.size = Vector2(maxf(0.0, size.x - margin_x * 2.0), feedback_height)
	_feedback_label.position = Vector2(18.0, 6.0)
	_feedback_label.size = Vector2(
		maxf(0.0, _feedback_panel.size.x - 36.0), feedback_height - 12.0)
	var target_top := _header_panel.position.y + _header_panel.size.y + 8.0
	var target_bottom := _feedback_panel.position.y - 8.0
	_target_layer.position = Vector2(margin_x, target_top)
	_target_layer.size = Vector2(
		maxf(0.0, size.x - margin_x * 2.0),
		maxf(0.0, target_bottom - target_top))
	for raw_id in _requirement_order:
		var requirement_id := str(raw_id)
		var button: Button = _target_buttons.get(requirement_id)
		if not is_instance_valid(button):
			continue
		var requirement: Dictionary = _requirements_by_id.get(requirement_id, {})
		var slot := str(requirement.get("scene_slot", "center"))
		var target_rect := _target_marker_rect(slot, compact)
		button.position = Vector2(
			target_rect.position.x * _target_layer.size.x,
			target_rect.position.y * _target_layer.size.y)
		button.size = Vector2(
			target_rect.size.x * _target_layer.size.x,
			target_rect.size.y * _target_layer.size.y)
		button.add_theme_font_size_override(
			"font_size", _readable_font_size(16, 15))
		var sweep := button.get_node_or_null(TARGET_SWEEP_NAME) as ColorRect
		if is_instance_valid(sweep):
			sweep.position = Vector2(8.0, 8.0)
			sweep.size = Vector2(3.0, maxf(0.0, button.size.y - 16.0))
		var marker := button.get_node_or_null(TARGET_MARKER_NAME) as Control
		if is_instance_valid(marker):
			marker.queue_redraw()
	_task_id_label.add_theme_font_size_override(
		"font_size", _readable_font_size(16, 15))
	_remaining_label.add_theme_font_size_override(
		"font_size", _readable_font_size(14, 14))
	_intro_label.add_theme_font_size_override(
		"font_size", _readable_font_size(20 if not compact else 18, 17))
	_instruction_label.add_theme_font_size_override(
		"font_size", _readable_font_size(15, 14))
	_preview_label.add_theme_font_size_override(
		"font_size", _readable_font_size(14, 14))
	_feedback_label.add_theme_font_size_override(
		"font_size", _readable_font_size(14, 14))
	_normal_button.add_theme_font_size_override(
		"font_size", _readable_font_size(15, 15))
	_overreach_button.add_theme_font_size_override(
		"font_size", _readable_font_size(15, 15))
	_hint_label.add_theme_font_size_override(
		"font_size", _readable_font_size(11, 11))
	set_meta("commitment_task_output_scale", _physical_output_scale())
	set_meta(
		"commitment_task_effective_body_px",
		float(_feedback_label.get_theme_font_size("font_size")) \
			* _physical_output_scale())


func _apply_target_style(button: Button, selected: bool) -> void:
	button.add_theme_color_override(
		"font_color", COLOR_ACCENT if selected else Color("#e1e6ea"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_focus_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", COLOR_ACCENT)
	button.add_theme_stylebox_override("normal", _target_style(Color.TRANSPARENT))
	button.add_theme_stylebox_override("hover", _target_style(Color("#10151a", 0.16)))
	button.add_theme_stylebox_override("pressed", _target_style(Color("#d8c38d", 0.08)))
	button.add_theme_stylebox_override("focus", _target_style(Color("#07090c", 0.12)))


func _target_style(background_color: Color) -> StyleBoxFlat:
	var style := _new_flat_style()
	style.bg_color = background_color
	style.set_corner_radius_all(0)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style


func _target_marker_rect(slot: String, compact: bool) -> Rect2:
	# These are small field marks pinned to objects in the authored warehouse:
	# shelf/scanner at left, cart/record desk in the center, handoff station at
	# right. They deliberately leave most of the scene uncovered.
	if compact:
		match slot:
			"left":
				return Rect2(0.015, 0.10, 0.25, 0.35)
			"right":
				return Rect2(0.735, 0.10, 0.25, 0.35)
			_:
				return Rect2(0.375, 0.51, 0.25, 0.37)
	match slot:
		"left":
			return Rect2(0.015, 0.12, 0.24, 0.32)
		"right":
			return Rect2(0.755, 0.14, 0.23, 0.32)
		_:
			return Rect2(0.39, 0.52, 0.22, 0.34)


func _draw_target_marker(button: Button, marker: Control) -> void:
	if not is_instance_valid(button) or marker.size.x < 24.0 or marker.size.y < 24.0:
		return
	var selected_order := int(button.get_meta("selected_order", 0))
	var focused := button.has_focus()
	var color := Color("#aab3bc", 0.84)
	if selected_order > 0:
		color = COLOR_ACCENT
	elif focused:
		color = Color.WHITE
	var stroke := 3.0 if focused else (2.5 if selected_order > 0 else 1.5)
	var inset := 3.0
	var left := inset
	var top := inset
	var right := marker.size.x - inset
	var bottom := marker.size.y - inset
	var corner := minf(22.0, minf(marker.size.x, marker.size.y) * 0.27)
	# Four independent corners read as a warehouse scan/inspection target, not
	# as a filled reusable option card.
	marker.draw_line(Vector2(left, top), Vector2(left + corner, top), color, stroke)
	marker.draw_line(Vector2(left, top), Vector2(left, top + corner), color, stroke)
	marker.draw_line(Vector2(right, top), Vector2(right - corner, top), color, stroke)
	marker.draw_line(Vector2(right, top), Vector2(right, top + corner), color, stroke)
	marker.draw_line(Vector2(left, bottom), Vector2(left + corner, bottom), color, stroke)
	marker.draw_line(Vector2(left, bottom), Vector2(left, bottom - corner), color, stroke)
	marker.draw_line(Vector2(right, bottom), Vector2(right - corner, bottom), color, stroke)
	marker.draw_line(Vector2(right, bottom), Vector2(right, bottom - corner), color, stroke)
	if selected_order > 0:
		marker.draw_line(
			Vector2(left + corner + 6.0, bottom),
			Vector2(right - corner - 6.0, bottom),
			Color(COLOR_ACCENT, 0.72), 2.0)
		var check_right := right - 10.0
		var check_y := top + 13.0
		marker.draw_line(
			Vector2(check_right - 12.0, check_y),
			Vector2(check_right - 7.0, check_y + 5.0), COLOR_ACCENT, 2.5)
		marker.draw_line(
			Vector2(check_right - 7.0, check_y + 5.0),
			Vector2(check_right + 2.0, check_y - 6.0), COLOR_ACCENT, 2.5)


func _refresh_target_markers() -> void:
	for raw_button in _target_buttons.values():
		var button := raw_button as Button
		if not is_instance_valid(button):
			continue
		var marker := button.get_node_or_null(TARGET_MARKER_NAME) as Control
		if is_instance_valid(marker):
			marker.queue_redraw()


func _target_station_label(requirement: Dictionary) -> String:
	if _has_localized(requirement, "station"):
		return _localized(requirement, "station")
	match str(requirement.get("scene_slot", "center")):
		"left":
			return LocaleManager.ui("왼쪽 작업 지점", "LEFT WORKPOINT")
		"right":
			return LocaleManager.ui("오른쪽 작업 지점", "RIGHT WORKPOINT")
		_:
			return LocaleManager.ui("가운데 작업 지점", "CENTER WORKPOINT")


func _target_short_label(requirement: Dictionary) -> String:
	if _has_localized(requirement, "short"):
		return _localized(requirement, "short")
	return _localized(requirement, "label")


func _play_requirement_feedback(requirement_id: String) -> void:
	var requirement: Dictionary = _requirements_by_id.get(requirement_id, {})
	var sound_id := str(requirement.get("sfx", "")).strip_edges()
	if not sound_id.is_empty() and AudioManager.has_sound(sound_id):
		AudioManager.play(sound_id, -4.0)
	else:
		AudioManager.play_ui_click(-8.0)
	var button: Button = _target_buttons.get(requirement_id)
	if not is_instance_valid(button):
		return
	var marker := button.get_node_or_null(TARGET_MARKER_NAME) as Control
	if is_instance_valid(marker):
		marker.queue_redraw()
	var sweep := button.get_node_or_null(TARGET_SWEEP_NAME) as ColorRect
	if not is_instance_valid(sweep) \
			or bool(SaveManager.get_setting("reduce_motion", false)):
		return
	var start_position := Vector2(8.0, 8.0)
	var end_position := start_position
	match str(requirement.get("scene_slot", "center")):
		"left":
			sweep.color = Color("#d7edf2", 0.76)
			sweep.size = Vector2(3.0, maxf(0.0, button.size.y - 16.0))
			end_position.x = maxf(8.0, button.size.x - 11.0)
		"center":
			sweep.color = Color("#eef1f5", 0.62)
			sweep.size = Vector2(maxf(0.0, button.size.x - 16.0), 2.0)
			end_position.y = maxf(8.0, button.size.y - 10.0)
		_:
			sweep.color = Color(COLOR_ACCENT, 0.82)
			sweep.size = Vector2(minf(76.0, button.size.x * 0.34), 4.0)
			start_position.x = (button.size.x - sweep.size.x) * 0.5
			end_position = Vector2(start_position.x, maxf(8.0, button.size.y - 14.0))
	sweep.position = start_position
	sweep.modulate = Color(1.0, 1.0, 1.0, 0.0)
	sweep.visible = true
	var feedback_generation := int(sweep.get_meta("feedback_generation", 0)) + 1
	sweep.set_meta("feedback_generation", feedback_generation)
	var previous_tween: Tween = \
		_target_feedback_tweens.get(requirement_id) as Tween
	if previous_tween != null and previous_tween.is_valid():
		previous_tween.kill()
	var tween := create_tween()
	_target_feedback_tweens[requirement_id] = tween
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(sweep, "modulate", Color.WHITE, 0.06)
	tween.parallel().tween_property(sweep, "position", end_position, 0.24) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(sweep, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.12)
	tween.tween_callback(func() -> void:
		if is_instance_valid(sweep) \
				and int(sweep.get_meta("feedback_generation", 0)) == feedback_generation:
			sweep.visible = false
		if _target_feedback_tweens.get(requirement_id) == tween:
			_target_feedback_tweens.erase(requirement_id))


func _stop_target_feedback_tweens() -> void:
	for raw_tween in _target_feedback_tweens.values():
		var tween := raw_tween as Tween
		if tween != null and tween.is_valid():
			tween.kill()
	_target_feedback_tweens.clear()


func _physical_output_scale() -> float:
	if not is_inside_tree():
		return 1.0
	var logical_size := get_viewport().get_visible_rect().size
	var output_size := Vector2(get_window().size)
	if logical_size.x <= 0.0 or logical_size.y <= 0.0 \
			or output_size.x <= 0.0 or output_size.y <= 0.0:
		return 1.0
	return clampf(minf(
		output_size.x / logical_size.x,
		output_size.y / logical_size.y), 0.5, 4.0)


func _readable_font_size(base_size: int, minimum_output_size: int) -> int:
	return maxi(base_size, int(ceil(
		float(minimum_output_size) / _physical_output_scale())))


func _resolution_button(node_name: String, danger: bool) -> Button:
	var button := Button.new()
	button.name = node_name
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(0, 76)
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_font_override("font", _font_bold)
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_focus_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", COLOR_MUTED)
	var normal_border := COLOR_DANGER if danger else COLOR_ACCENT
	var normal_fill := Color("#281918", 0.96) if danger else COLOR_PANEL_ALT
	var hover_fill := Color("#3a201d", 0.98) if danger else Color("#22292f", 0.98)
	button.add_theme_stylebox_override("normal", _panel_style(normal_fill, normal_border, 1, 3))
	button.add_theme_stylebox_override("hover", _panel_style(hover_fill, Color.WHITE, 2, 3))
	button.add_theme_stylebox_override("pressed", _panel_style(COLOR_INK, normal_border, 2, 3))
	button.add_theme_stylebox_override("focus", _panel_style(Color("#11161b", 0.24), COLOR_ACCENT, 3, 3))
	button.add_theme_stylebox_override(
		"disabled", _panel_style(Color("#0b0e11", 0.88), Color("#343a40"), 1, 3))
	button.mouse_entered.connect(_on_target_mouse_entered.bind(button))
	return button


func _label(text_value: String, font_size: int, color: Color, bold: bool = false) -> Label:
	var label := Label.new()
	label.text = text_value
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", _font_bold if bold else _font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _panel_style(
		background_color: Color,
		border_color: Color,
		border_width: int,
		radius: int) -> StyleBoxFlat:
	var style := _new_flat_style()
	style.bg_color = background_color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	return style


## Keep this scene's flat surfaces behind one constructor. Apart from making
## their shared material origin explicit, this prevents each helper from
## becoming another private style factory as the task layer grows.
func _new_flat_style() -> StyleBoxFlat:
	return StyleBoxFlat.new()


func _selected_normal_outcome() -> Dictionary:
	if _selected_ids.size() != _normal_steps:
		return {}
	var outcomes: Dictionary = _spec.get("outcomes", {})
	for raw_outcome_id in outcomes.keys():
		var outcome: Dictionary = outcomes.get(raw_outcome_id, {})
		if _same_id_set(outcome.get("requirements", []), _selected_ids):
			var result := outcome.duplicate(true)
			result["outcome_id"] = str(raw_outcome_id)
			return result
	return {}


func _omitted_requirement_id() -> String:
	for raw_id in _requirement_order:
		var requirement_id := str(raw_id)
		if requirement_id not in _selected_ids:
			return requirement_id
	return ""


func _button_for_slot(slot: String) -> Button:
	for raw_id in _requirement_order:
		var requirement_id := str(raw_id)
		var requirement: Dictionary = _requirements_by_id.get(requirement_id, {})
		if str(requirement.get("scene_slot", "")) == slot:
			return _target_buttons.get(requirement_id) as Button
	return null


func _localized(source: Dictionary, stem: String) -> String:
	return LocaleManager.ui(
		str(source.get("%s_ko" % stem, "")),
		str(source.get("%s_en" % stem, "")))


func _task_title() -> String:
	if _has_localized(_spec, "task_title"):
		return _localized(_spec, "task_title")
	if _has_localized(_spec, "result_title"):
		return _localized(_spec, "result_title")
	return str(_spec.get("task_id", ""))


func _overreach_prompt(overreach: Dictionary) -> String:
	# `prompt_*` is the authored contract. Accept the earlier `confirm_*`
	# spelling only so an in-progress save/config migration cannot strand input.
	if _has_localized(overreach, "prompt"):
		return _localized(overreach, "prompt")
	return _localized(overreach, "confirm")


func _effect_line(effects: Dictionary) -> String:
	return "%s %s  ·  %s %s  ·  %s %s" % [
		LocaleManager.ui("수당", "PAY"),
		_format_money(effects.get("money", 0)),
		LocaleManager.ui("건강", "HEALTH"),
		_format_signed_number(effects.get("health", 0)),
		LocaleManager.ui("마음", "MENTAL"),
		_format_signed_number(effects.get("mental", 0)),
	]


func _format_money(raw_value: Variant) -> String:
	var value := int(raw_value)
	var absolute_digits := str(absi(value))
	var insert_at := absolute_digits.length() - 3
	while insert_at > 0:
		absolute_digits = absolute_digits.insert(insert_at, ",")
		insert_at -= 3
	var sign_text := "+" if value > 0 else ("-" if value < 0 else "")
	return LocaleManager.ui(
		"%s%s원" % [sign_text, absolute_digits],
		"%sKRW %s" % [sign_text, absolute_digits])


func _format_signed_number(raw_value: Variant) -> String:
	var value := int(raw_value)
	return "+%d" % value if value > 0 else str(value)


func _restored_selection(raw_selection: Variant) -> Array:
	var restored: Array = []
	if not raw_selection is Array:
		return restored
	for raw_id in raw_selection:
		var requirement_id := str(raw_id)
		if requirement_id in _requirement_order and requirement_id not in restored:
			restored.append(requirement_id)
			if restored.size() == _normal_steps:
				break
	return restored


func _valid_spec(candidate: Dictionary) -> bool:
	if str(candidate.get("task_id", "")).strip_edges().is_empty():
		return false
	if int(candidate.get("normal_steps", -1)) != 2:
		return false
	var background_path := str(candidate.get("background_path", ""))
	if background_path.is_empty() or not ResourceLoader.exists(background_path):
		return false
	if str(candidate.get("ambience", "")).strip_edges().is_empty():
		return false
	if not _has_localized(candidate, "intro") or not _has_localized(candidate, "instruction"):
		return false
	var raw_requirements: Variant = candidate.get("requirements", [])
	if not raw_requirements is Array or (raw_requirements as Array).size() != 3:
		return false
	var requirement_ids: Array = []
	var scene_slots: Array = []
	for raw_requirement in raw_requirements:
		if not raw_requirement is Dictionary:
			return false
		var requirement: Dictionary = raw_requirement
		var requirement_id := str(requirement.get("id", "")).strip_edges()
		var scene_slot := str(requirement.get("scene_slot", ""))
		if requirement_id.is_empty() or requirement_id in requirement_ids:
			return false
		if scene_slot not in VALID_SCENE_SLOTS or scene_slot in scene_slots:
			return false
		for localized_stem in ["label", "detail", "feedback"]:
			if not _has_localized(requirement, localized_stem):
				return false
		requirement_ids.append(requirement_id)
		scene_slots.append(scene_slot)
	var raw_outcomes: Variant = candidate.get("outcomes", {})
	if not raw_outcomes is Dictionary:
		return false
	var outcomes: Dictionary = raw_outcomes
	if outcomes.size() != 3:
		return false
	var pair_keys: Array = []
	for raw_outcome_id in outcomes.keys():
		if str(raw_outcome_id).strip_edges().is_empty():
			return false
		var raw_outcome: Variant = outcomes[raw_outcome_id]
		if not raw_outcome is Dictionary:
			return false
		var outcome: Dictionary = raw_outcome
		var raw_pair: Variant = outcome.get("requirements", [])
		if not raw_pair is Array or (raw_pair as Array).size() != 2:
			return false
		var pair: Array = raw_pair
		if str(pair[0]) == str(pair[1]):
			return false
		for raw_id in pair:
			if str(raw_id) not in requirement_ids:
				return false
		var pair_key := _canonical_id_key(pair)
		if pair_key in pair_keys:
			return false
		pair_keys.append(pair_key)
		if not _valid_effects(outcome.get("effects", {})) \
				or not _has_localized(outcome, "preview") \
				or not _has_localized(outcome, "finish"):
			return false
	if pair_keys.size() != 3:
		return false
	var raw_overreach: Variant = candidate.get("overreach", {})
	if not raw_overreach is Dictionary:
		return false
	var overreach: Dictionary = raw_overreach
	if str(overreach.get("outcome_id", "")).strip_edges().is_empty():
		return false
	var raw_all_requirements: Variant = overreach.get("requirements", [])
	if not raw_all_requirements is Array \
			or not _same_id_set(raw_all_requirements as Array, requirement_ids):
		return false
	if not _valid_effects(overreach.get("effects", {})):
		return false
	if (not _has_localized(overreach, "prompt") \
			and not _has_localized(overreach, "confirm")) \
			or not _has_localized(overreach, "finish"):
		return false
	return true


func _has_localized(source: Dictionary, stem: String) -> bool:
	return not str(source.get("%s_ko" % stem, "")).strip_edges().is_empty() \
		and not str(source.get("%s_en" % stem, "")).strip_edges().is_empty()


func _valid_effects(raw_effects: Variant) -> bool:
	if not raw_effects is Dictionary:
		return false
	var effects: Dictionary = raw_effects
	for effect_key in EFFECT_KEYS:
		if not effects.has(effect_key):
			return false
		var effect_value: Variant = effects[effect_key]
		if typeof(effect_value) != TYPE_INT and typeof(effect_value) != TYPE_FLOAT:
			return false
	return true


func _same_id_set(raw_left: Variant, raw_right: Variant) -> bool:
	if not raw_left is Array or not raw_right is Array:
		return false
	var left: Array = raw_left
	var right: Array = raw_right
	if left.size() != right.size():
		return false
	return _canonical_id_key(left) == _canonical_id_key(right)


func _canonical_id_key(values: Array) -> String:
	var ids: Array[String] = []
	for raw_value in values:
		ids.append(str(raw_value))
	ids.sort()
	return "|".join(ids)


func _release_activity_ambience() -> void:
	if not _ambience_owned:
		return
	BGMPlayer.leave_activity_ambience(_ambience_key)
	_ambience_owned = false
	_ambience_key = ""
