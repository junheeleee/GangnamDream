extends Control
## Standalone M01-M06 monthly-promise playtest.
## This scene intentionally has no dependency on project autoloads or existing game saves.

signal screen_changed(screen_name: String)
signal selection_changed(selection: Dictionary)
signal month_committed(result: Dictionary)

const MONTHLY_RUNTIME := preload("res://systems/StoryMapMonthlyRuntime.gd")
const STORY_MAP_PATH := "res://content/meta/story_map.json"
const EN_OVERLAY_PATH := "res://content/meta/story_map_m1m6_en.json"
const AUTOSAVE_PATH := "user://story_map_m1m6_playtest_autosave.json"
const SAVE_SCHEMA_VERSION := 1
const WORLD_BACKGROUND_PATH := "res://assets/backgrounds/goshiwon_room.png"
const WORLD_GRADE_SHADER_PATH := "res://assets/shaders/background_grade.gdshader"
const PAPER_SFX_PATH := "res://assets/audio/sfx_paper_handle.wav"
const STAMP_SFX_PATH := "res://assets/audio/sfx_document_stamp.wav"

const COLOR_BG := Color("#07090c")
const COLOR_PANEL := Color("#10141a")
const COLOR_PANEL_ALT := Color("#171c23")
const COLOR_BORDER := Color("#4e5865")
const COLOR_TEXT := Color("#e7ebf0")
const COLOR_DIM := Color("#929ba7")
const COLOR_ACCENT := Color("#d8c38d")
const COLOR_CASH := Color("#d5a45f")
const COLOR_HEALTH := Color("#78b99a")
const COLOR_TRUST := Color("#d58b91")
const COLOR_DANGER := Color("#c97878")
const COLOR_OK := Color("#78b99a")
const COLOR_PAPER := Color("#d7d0c1")
const COLOR_PAPER_FOCUS := Color("#eee7d8")
const COLOR_PAPER_INK := Color("#20242a")
const COLOR_PAPER_DIM := Color("#60656c")
const COLOR_PAPER_EDGE := Color("#80796d")

var _runtime: Variant
var _runtime_state: Dictionary = {}
var _draft_selection := {"protected": "", "optional_second": ""}
var _overlay: Dictionary = {}
var _snapshot: Dictionary = {}
var _result: Dictionary = {}
var _recap: Dictionary = {}
var _language := "ko"
var _screen := "home"
var _focused_commitment_id := ""
var _status_key := ""
var _status_fallback := ""
var _restart_armed := false
var _compact := false
var _resize_refresh_queued := false
var _runtime_error := ""

var _page: MarginContainer
var _header_title: Label
var _header_subtitle: Label
var _language_button: Button
var _home_button: Button
var _restart_button: Button
var _body: Control
var _footer: Label
var _card_buttons: Dictionary = {}
var _protected_button: Button
var _optional_button: Button
var _confirm_button: Button
var _undo_button: Button
var _detail_label: Label
var _role_notice_label: Label
var _selection_label: Label
var _fx_layer: Control
var _paper_player: AudioStreamPlayer
var _stamp_player: AudioStreamPlayer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	set_process_unhandled_input(true)
	set_meta("story_map_m1m6_playtest", true)
	_overlay = _read_json_dictionary(EN_OVERLAY_PATH)
	_compact = _is_compact_layout()
	_build_shell()
	resized.connect(_on_resized)
	if not _initialize_runtime():
		_runtime_error = "월간 체험 런타임을 열 수 없습니다."
	_show_home()


func _exit_tree() -> void:
	_release_feedback_player(_paper_player)
	_release_feedback_player(_stamp_player)


func qa_start_new_run() -> bool:
	return _start_new_run(true)


func qa_continue_run() -> bool:
	return _continue_run()


func qa_focus_commitment(commitment_id: String) -> bool:
	if _card_from_id(commitment_id).is_empty():
		return false
	_focused_commitment_id = commitment_id
	_refresh_selection_screen()
	return true


func qa_set_role(slot: String, commitment_id: String) -> bool:
	if slot not in ["protected", "optional_second"]:
		return false
	if _card_from_id(commitment_id).is_empty():
		return false
	_focused_commitment_id = commitment_id
	return _set_role(slot, commitment_id, false)


func qa_clear_role(slot: String) -> bool:
	if slot not in ["protected", "optional_second"]:
		return false
	return _clear_role(slot, false)


func qa_commit_month() -> Dictionary:
	return _commit_current_month(false)


func qa_advance() -> bool:
	return _advance_from_result()


func qa_snapshot() -> Dictionary:
	return _snapshot.duplicate(true)


func qa_screen() -> String:
	return _screen


func qa_autosave_path() -> String:
	return AUTOSAVE_PATH


func qa_set_language(language: String) -> bool:
	if language not in ["ko", "en"]:
		return false
	_language = language
	_refresh_current_screen()
	return true


func qa_visible_text() -> String:
	var lines := PackedStringArray()
	_collect_visible_text(self, lines)
	return "\n".join(lines)


func qa_visual_contract() -> Dictionary:
	var note_ids: Array[String] = []
	var note_rects: Dictionary = {}
	for commitment_id in _card_buttons:
		var button: Button = _card_buttons[commitment_id]
		if is_instance_valid(button) and button.has_meta("m1m6_commitment_id"):
			var note_id := str(button.get_meta("m1m6_commitment_id"))
			note_ids.append(note_id)
			note_rects[note_id] = _control_rect_array(button)
	note_ids.sort()
	var role_slots: Array[String] = []
	var role_rects: Dictionary = {}
	for button in [_protected_button, _optional_button]:
		if is_instance_valid(button) and button.has_meta("m1m6_role_slot"):
			var slot := str(button.get_meta("m1m6_role_slot"))
			role_slots.append(slot)
			role_rects[slot] = _control_rect_array(button)
	role_slots.sort()
	return {
		"mode": str(get_meta("story_map_m1m6_visual_mode", "")),
		"world_background": _count_meta_nodes(self, "m1m6_world_background"),
		"note_ids": note_ids,
		"note_rects": note_rects,
		"role_slots": role_slots,
		"role_rects": role_rects,
		"scroll_containers": _count_class_nodes(self, "ScrollContainer"),
		"legacy_inspectors": _count_meta_nodes(self, "m1m6_legacy_inspector"),
		"detail_ribbons": _count_named_nodes(self, "PromiseMemoRibbon"),
		"confirm_present": is_instance_valid(_confirm_button) \
			and bool(_confirm_button.get_meta("m1m6_commit", false)),
		"confirm_rect": _control_rect_array(_confirm_button),
		"restart_armed": _restart_armed,
		"restart_text": _restart_button.text if is_instance_valid(_restart_button) else "",
		"restart_warning_in_footer": is_instance_valid(_footer) \
			and _footer.text == _t("ui.home.restart_confirm", "한 번 더 눌러 처음부터"),
		"focus_role_slot": _focused_meta_value("m1m6_role_slot"),
		"focus_commitment_id": _focused_meta_value("m1m6_commitment_id"),
		"viewport_size": [get_viewport_rect().size.x, get_viewport_rect().size.y],
	}


func _initialize_runtime() -> bool:
	_runtime = MONTHLY_RUNTIME.new()
	if _runtime == null:
		return false
	if not _runtime.has_method("load_story_map"):
		return false
	var response: Variant = _runtime.call("load_story_map", STORY_MAP_PATH)
	if not response is Dictionary:
		return false
	if not bool((response as Dictionary).get("ok", false)):
		_runtime_error = str((response as Dictionary).get("error", "월간 체험 데이터를 열 수 없습니다."))
		return false
	_runtime_state = _runtime.call("initial_state")
	return not _runtime_state.is_empty()


func _build_shell() -> void:
	set_meta("story_map_m1m6_visual_mode", "desk_promises_v1")
	var background := TextureRect.new()
	background.name = "GoshiwonWorld"
	background.set_meta("m1m6_world_background", true)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	var source_texture: Texture2D = load(WORLD_BACKGROUND_PATH)
	if source_texture != null:
		var crop := AtlasTexture.new()
		crop.atlas = source_texture
		crop.region = Rect2(427, 267, 853, 533)
		background.texture = crop
	var grade_shader: Shader = load(WORLD_GRADE_SHADER_PATH)
	if grade_shader != null:
		var grade := ShaderMaterial.new()
		grade.shader = grade_shader
		grade.set_shader_parameter("desaturation", 0.58)
		grade.set_shader_parameter("brightness", 0.78)
		grade.set_shader_parameter("contrast", 0.98)
		grade.set_shader_parameter("grain_amount", 0.018)
		grade.set_shader_parameter("ink_bleed", 0.045)
		grade.set_shader_parameter("paper_fade", 0.018)
		grade.set_shader_parameter("edge_burn", 0.10)
		background.material = grade
	add_child(background)

	var veil := ColorRect.new()
	veil.name = "WorldVeil"
	veil.color = Color("#05070a9c")
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(veil)

	_page = MarginContainer.new()
	_page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_page)
	_apply_page_margins()

	var page_column := VBoxContainer.new()
	page_column.add_theme_constant_override("separation", 10 if _compact else 14)
	_page.add_child(page_column)

	var header := HBoxContainer.new()
	header.custom_minimum_size.y = 48 if _compact else 58
	header.add_theme_constant_override("separation", 8)
	page_column.add_child(header)

	var title_column := VBoxContainer.new()
	title_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_column.add_theme_constant_override("separation", 0)
	header.add_child(title_column)
	_header_title = _label("", 19 if _compact else 23, COLOR_TEXT, true)
	title_column.add_child(_header_title)
	_header_subtitle = _label("", 12 if _compact else 14, COLOR_DIM)
	title_column.add_child(_header_subtitle)

	_home_button = _button("", false)
	_home_button.visible = false
	_home_button.pressed.connect(_show_home)
	header.add_child(_home_button)
	_restart_button = _button("", false)
	_restart_button.visible = false
	_restart_button.set_meta("m1m6_restart", true)
	_restart_button.pressed.connect(_on_restart_pressed)
	header.add_child(_restart_button)
	_language_button = _button("", false)
	_language_button.pressed.connect(_toggle_language)
	header.add_child(_language_button)

	var separator := HSeparator.new()
	separator.modulate = COLOR_BORDER
	page_column.add_child(separator)

	_body = Control.new()
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_column.add_child(_body)

	_footer = _label("", 12 if _compact else 14, COLOR_DIM)
	_footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_footer.custom_minimum_size.y = 20
	page_column.add_child(_footer)

	_fx_layer = Control.new()
	_fx_layer.name = "PromiseFX"
	_fx_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fx_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_fx_layer)

	_paper_player = AudioStreamPlayer.new()
	_paper_player.name = "PaperHandlePlayer"
	_paper_player.stream = load(PAPER_SFX_PATH)
	_paper_player.volume_db = -8.0
	add_child(_paper_player)
	_stamp_player = AudioStreamPlayer.new()
	_stamp_player.name = "PromiseStampPlayer"
	_stamp_player.stream = load(STAMP_SFX_PATH)
	_stamp_player.volume_db = -7.0
	add_child(_stamp_player)


func _show_home() -> void:
	_set_screen("home")
	_restart_armed = false
	_clear_body()
	_header_title.text = _t("ui.title", "여섯 달의 약속")
	_header_subtitle.text = _t("ui.subtitle", "민준이 무엇을 지키고 무엇을 놓칠지 고릅니다.")
	_home_button.visible = false
	_restart_button.visible = false
	_refresh_shell_copy()

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_body.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720 if not _compact else 620, 390 if not _compact else 350)
	panel.add_theme_stylebox_override("panel", _panel_style(COLOR_PANEL, COLOR_BORDER, 1, 12))
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28 if not _compact else 20)
	margin.add_theme_constant_override("margin_right", 28 if not _compact else 20)
	margin.add_theme_constant_override("margin_top", 24 if not _compact else 18)
	margin.add_theme_constant_override("margin_bottom", 24 if not _compact else 18)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14 if not _compact else 10)
	margin.add_child(column)
	column.add_child(_label(_t("ui.home.eyebrow", "독립 체험판 · M01–M06"), 13, COLOR_ACCENT, true))
	var hero := _label(_t("ui.home.title", "여섯 달, 끝까지 놓지 않을 한 약속."), 28 if not _compact else 23, COLOR_TEXT, true)
	hero.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(hero)
	var body_copy := _label(_t(
		"ui.home.body",
		"매달 주력 약속 하나를 고릅니다. 같은 축 여유가 있다면 하나를 함께 지킬 수 있습니다. 선택 전에는 행동·마감·미룸 가능 여부만 알 수 있습니다."
	), 16 if not _compact else 14, COLOR_TEXT)
	body_copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_copy.custom_minimum_size.y = 76 if not _compact else 66
	column.add_child(body_copy)

	var save_exists := _has_valid_autosave()
	var save_copy := _t("ui.home.no_save", "아직 체험판 자동저장이 없습니다.")
	if save_exists:
		var saved_month := _peek_saved_month()
		save_copy = _format(_t("ui.home.saved_month", "자동저장 있음 · {month}개월차"), {"month": saved_month})
	var save_label := _label(save_copy, 14, COLOR_OK if save_exists else COLOR_DIM, true)
	column.add_child(save_label)

	if not _runtime_error.is_empty():
		var error_label := _label(_runtime_error, 14, COLOR_DANGER, true)
		error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(error_label)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	column.add_child(actions)
	var continue_button := _button(_t("ui.home.continue", "이어하기"), true)
	continue_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	continue_button.disabled = not save_exists or not _runtime_error.is_empty()
	continue_button.focus_mode = Control.FOCUS_NONE if continue_button.disabled else Control.FOCUS_ALL
	continue_button.pressed.connect(_continue_run)
	actions.add_child(continue_button)
	var new_button := _button(_t("ui.home.new", "처음부터"), false)
	new_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_button.disabled = not _runtime_error.is_empty()
	new_button.focus_mode = Control.FOCUS_NONE if new_button.disabled else Control.FOCUS_ALL
	new_button.pressed.connect(_on_home_new_pressed.bind(new_button, save_exists))
	actions.add_child(new_button)
	var privacy := _label(_t(
		"ui.home.autosave",
		"이 여섯 달 체험판만 따로 저장합니다. 기존 게임과 24주 저장은 열지 않습니다."
	), 12, COLOR_DIM)
	privacy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	privacy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(privacy)
	_footer.text = _t("ui.controls", "방향키 / D패드 · 이동    Enter / 남쪽 버튼 · 확인    Esc / 동쪽 버튼 · 되돌리기")
	if not continue_button.disabled:
		call_deferred("_safe_grab_focus", continue_button)
	elif not new_button.disabled:
		call_deferred("_safe_grab_focus", new_button)


func _on_home_new_pressed(button: Button, save_exists: bool) -> void:
	if save_exists and not _restart_armed:
		_restart_armed = true
		button.text = _t("ui.home.restart_confirm", "한 번 더 누르면 체험판 저장을 지웁니다")
		_apply_button_style(button, true, COLOR_DANGER)
		return
	_start_new_run(true)


func _on_restart_pressed() -> void:
	if not _restart_armed:
		_restart_armed = true
		_restart_button.text = _t("ui.home.restart", "처음부터")
		_footer.text = _t("ui.home.restart_confirm", "한 번 더 눌러 처음부터")
		_apply_button_style(_restart_button, true, COLOR_DANGER)
		return
	_start_new_run(true)


func _start_new_run(write_initial_save: bool) -> bool:
	_restart_armed = false
	if _runtime == null or not _runtime.has_method("initial_state"):
		_runtime_error = "새 체험을 시작하지 못했습니다."
		_show_home()
		return false
	_runtime_state = _runtime.call("initial_state")
	_draft_selection = {"protected": "", "optional_second": ""}
	_snapshot = _runtime_snapshot()
	_result = {}
	_recap = {}
	_focused_commitment_id = _first_card_id()
	_status_key = ""
	_status_fallback = ""
	if write_initial_save:
		_write_autosave()
	_show_selection()
	return not _snapshot.is_empty()


func _continue_run() -> bool:
	var wrapper := _read_json_dictionary(AUTOSAVE_PATH)
	if int(wrapper.get("schema_version", 0)) != SAVE_SCHEMA_VERSION:
		return false
	var state: Variant = wrapper.get("runtime_state", {})
	if not state is Dictionary:
		return false
	if _runtime == null or not _runtime.has_method("normalize_state"):
		return false
	var response: Variant = _runtime.call("normalize_state", state)
	if not response is Dictionary or not bool((response as Dictionary).get("ok", false)):
		return false
	_runtime_state = ((response as Dictionary).get("state", {}) as Dictionary).duplicate(true)
	_draft_selection = {"protected": "", "optional_second": ""}
	_snapshot = _runtime_snapshot()
	_result = _result_from_last_plan()
	_recap = _build_recap()
	_focused_commitment_id = _first_card_id()
	if bool(_runtime_state.get("finished", false)) or int(_snapshot.get("month", 1)) > 6:
		_show_recap()
	else:
		_show_selection()
	return true


func _show_selection() -> void:
	_snapshot = _runtime_snapshot()
	if _focused_commitment_id.is_empty() or _card_from_id(_focused_commitment_id).is_empty():
		_focused_commitment_id = _first_card_id()
	_set_screen("selection")
	_restart_armed = false
	_rebuild_selection_screen()


func _rebuild_selection_screen() -> void:
	_clear_body()
	_card_buttons.clear()
	_refresh_shell_copy()
	_home_button.visible = true
	_restart_button.visible = true
	var month := int(_snapshot.get("month", 1))
	_header_title.text = _format(_t("ui.month.eyebrow", "6개월 중 {month}개월차"), {"month": month})
	_header_subtitle.text = _month_label(month)

	var root := VBoxContainer.new()
	root.name = "PromiseDesk"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 7 if _compact else 10)
	_body.add_child(root)

	var month_strip := PanelContainer.new()
	month_strip.name = "MonthPromptSlip"
	month_strip.add_theme_stylebox_override(
		"panel", _panel_style(Color("#0b0e12dc"), Color("#a9976e88"), 1, 2))
	root.add_child(month_strip)
	var month_margin := MarginContainer.new()
	month_margin.add_theme_constant_override("margin_left", 12)
	month_margin.add_theme_constant_override("margin_right", 12)
	month_margin.add_theme_constant_override("margin_top", 7)
	month_margin.add_theme_constant_override("margin_bottom", 7)
	month_strip.add_child(month_margin)
	var month_row := HBoxContainer.new()
	month_row.add_theme_constant_override("separation", 14)
	month_margin.add_child(month_row)
	var prompt_column := VBoxContainer.new()
	prompt_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	month_row.add_child(prompt_column)
	prompt_column.add_child(_label(_t("ui.month.prompt", "이번 달, 무엇을 끝까지 지킬까?"), 18 if not _compact else 16, COLOR_TEXT, true))
	var contract_label := _label(_t(
		"ui.month.known_information",
		"행동·축·마감과 미룸 가능 여부만 미리 알 수 있습니다."
	), 12 if _compact else 14, COLOR_DIM)
	contract_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_column.add_child(contract_label)
	var margin_label := _label(_margin_copy(), 13 if _compact else 14, _axis_color(_margin_axis()), true)
	margin_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	margin_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	margin_label.custom_minimum_size.x = 260 if _compact else 330
	month_row.add_child(margin_label)

	var main_row := HBoxContainer.new()
	main_row.name = "DeskWorkspace"
	main_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_row.add_theme_constant_override("separation", 14 if _compact else 22)
	root.add_child(main_row)

	var card_column := VBoxContainer.new()
	card_column.name = "PromiseNotes"
	card_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_column.size_flags_stretch_ratio = 1.55
	card_column.add_theme_constant_override("separation", 8 if _compact else 10)
	main_row.add_child(card_column)
	var note_rows := VBoxContainer.new()
	note_rows.name = "PromiseNoteRows"
	note_rows.size_flags_vertical = Control.SIZE_EXPAND_FILL
	note_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	note_rows.add_theme_constant_override("separation", 3 if _compact else 5)
	card_column.add_child(note_rows)
	var current_row: HBoxContainer
	var card_index := 0
	var cards := _cards()
	for raw_card in cards:
		if not raw_card is Dictionary:
			continue
		if card_index % 2 == 0:
			current_row = HBoxContainer.new()
			current_row.name = "PromiseNoteRow%d" % (card_index / 2 + 1)
			current_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
			current_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			current_row.add_theme_constant_override("separation", 8 if _compact else 12)
			note_rows.add_child(current_row)
		var card: Dictionary = raw_card
		var card_note := _create_card_button(card)
		current_row.add_child(card_note)
		card_index += 1
	if card_index % 2 == 1 and is_instance_valid(current_row):
		var empty_place := Control.new()
		empty_place.mouse_filter = Control.MOUSE_FILTER_IGNORE
		empty_place.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		current_row.add_child(empty_place)

	var detail_panel := PanelContainer.new()
	detail_panel.name = "PromiseMemoRibbon"
	detail_panel.custom_minimum_size.y = 72 if _compact else 86
	detail_panel.add_theme_stylebox_override(
		"panel", _paper_style(COLOR_PAPER.darkened(0.035), COLOR_PAPER_EDGE, 1, false))
	card_column.add_child(detail_panel)
	var detail_margin := MarginContainer.new()
	detail_margin.add_theme_constant_override("margin_left", 14 if _compact else 18)
	detail_margin.add_theme_constant_override("margin_right", 14 if _compact else 18)
	detail_margin.add_theme_constant_override("margin_top", 8 if _compact else 10)
	detail_margin.add_theme_constant_override("margin_bottom", 8 if _compact else 10)
	detail_panel.add_child(detail_margin)
	_detail_label = _label("", 12 if _compact else 14, COLOR_PAPER_INK)
	_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	detail_margin.add_child(_detail_label)

	var pocket_column := VBoxContainer.new()
	pocket_column.name = "PromisePockets"
	pocket_column.custom_minimum_size.x = 230 if _compact else 300
	pocket_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pocket_column.size_flags_stretch_ratio = 0.78
	pocket_column.add_theme_constant_override("separation", 8 if _compact else 12)
	main_row.add_child(pocket_column)

	_protected_button = _button("", false)
	_protected_button.name = "ProtectedPocket"
	_protected_button.set_meta("m1m6_role_slot", "protected")
	_protected_button.custom_minimum_size.y = 92 if _compact else 114
	_protected_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_protected_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_protected_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_protected_button.pressed.connect(_on_protected_action)
	pocket_column.add_child(_protected_button)
	_optional_button = _button("", false)
	_optional_button.name = "OptionalPocket"
	_optional_button.set_meta("m1m6_role_slot", "optional_second")
	_optional_button.custom_minimum_size.y = 92 if _compact else 114
	_optional_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_optional_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_optional_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_optional_button.pressed.connect(_on_optional_action)
	pocket_column.add_child(_optional_button)

	_role_notice_label = _label("", 12 if _compact else 14, COLOR_TEXT)
	_role_notice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_role_notice_label.custom_minimum_size.y = 58 if _compact else 72
	pocket_column.add_child(_role_notice_label)

	_selection_label = _label("", 12 if _compact else 14, COLOR_TEXT)
	_selection_label.visible = false
	pocket_column.add_child(_selection_label)
	var action_spacer := Control.new()
	action_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	action_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pocket_column.add_child(action_spacer)
	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 8)
	pocket_column.add_child(action_row)
	_undo_button = _button(_t("ui.action.undo", "최근 역할 취소"), false)
	_undo_button.pressed.connect(_undo_latest)
	action_row.add_child(_undo_button)
	_confirm_button = _button("", true)
	_confirm_button.name = "CommitMonth"
	_confirm_button.set_meta("m1m6_commit", true)
	_confirm_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_confirm_button.pressed.connect(_commit_current_month)
	action_row.add_child(_confirm_button)

	_refresh_selection_screen()
	var focus_button: Button = _card_buttons.get(_focused_commitment_id)
	if is_instance_valid(focus_button):
		call_deferred("_safe_grab_focus", focus_button)


func _refresh_selection_screen() -> void:
	if _screen != "selection" or not is_instance_valid(_detail_label):
		return
	_snapshot = _runtime_snapshot()
	for commitment_id in _card_buttons:
		var button: Button = _card_buttons[commitment_id]
		var card := _card_from_id(str(commitment_id))
		_refresh_note_button(button, card)
	var focused := _card_from_id(_focused_commitment_id)
	if focused.is_empty():
		_detail_label.text = _t("ui.detail.empty", "약속에 포커스를 옮기면 자세히 볼 수 있습니다.")
		_set_button_enabled(_protected_button, false)
		_set_button_enabled(_optional_button, false)
	else:
		_detail_label.text = _detail_copy(focused)
		_refresh_role_actions(focused)
	_selection_label.text = _selection_copy()
	var selection := _selection()
	var has_protected := not str(selection.get("protected", "")).is_empty()
	_set_button_enabled(_confirm_button, has_protected)
	_confirm_button.text = _t(
		"ui.action.confirm" if has_protected else "ui.action.confirm_disabled",
		"이 선택으로 이달 시작" if has_protected else "주력 약속을 고르세요"
	)
	var has_any := has_protected or not str(selection.get("optional_second", "")).is_empty()
	_set_button_enabled(_undo_button, has_any)
	_footer.text = _status_copy() if not _status_key.is_empty() else _t(
		"ui.controls",
		"방향키 / D패드 · 이동    Enter / 남쪽 버튼 · 확인    Esc / 동쪽 버튼 · 되돌리기"
	)
	_connect_card_focus_neighbors()
	_update_selection_metadata()


func _create_card_button(card: Dictionary) -> Control:
	var wrapper := MarginContainer.new()
	wrapper.name = "PromiseNoteSlot_%d" % (_card_buttons.size() + 1)
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var note_index := _card_buttons.size()
	var stagger: int = int([0, 6, 5, 0][note_index % 4]) if not _compact else 0
	wrapper.add_theme_constant_override("margin_top", stagger)
	wrapper.add_theme_constant_override("margin_bottom", 6 - stagger if not _compact else 0)

	var button := _button("", false)
	button.name = "PromiseNote_%s" % str(card.get("id", ""))
	button.set_meta("m1m6_commitment_id", str(card.get("id", "")))
	button.custom_minimum_size.y = 122 if _compact else 150
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	wrapper.add_child(button)

	var margin := MarginContainer.new()
	margin.name = "PaperContent"
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 12 if _compact else 15)
	margin.add_theme_constant_override("margin_right", 12 if _compact else 15)
	margin.add_theme_constant_override("margin_top", 9 if _compact else 12)
	margin.add_theme_constant_override("margin_bottom", 9 if _compact else 11)
	button.add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", 4 if _compact else 6)
	margin.add_child(column)
	var tape := ColorRect.new()
	tape.name = "PaperTape"
	tape.color = Color("#b8aa8b70")
	tape.custom_minimum_size.y = 3
	tape.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(tape)
	var header := HBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_theme_constant_override("separation", 6)
	column.add_child(header)
	var icon := TextureRect.new()
	icon.name = "AxisIcon"
	icon.custom_minimum_size = Vector2(18 if _compact else 21, 18 if _compact else 21)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.modulate = COLOR_PAPER_INK
	header.add_child(icon)
	var axis_label := _label("", 12 if _compact else 14, COLOR_PAPER_INK, true)
	axis_label.name = "AxisLabel"
	header.add_child(axis_label)
	var header_spacer := Control.new()
	header_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(header_spacer)
	var due_label := _label("", 12 if _compact else 14, COLOR_PAPER_DIM, true)
	due_label.name = "DueLabel"
	header.add_child(due_label)
	var action_label := _label("", 14 if _compact else 16, COLOR_PAPER_INK, true)
	action_label.name = "ActionLabel"
	action_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	action_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(action_label)
	var rule := HSeparator.new()
	rule.modulate = Color("#6d665a42")
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(rule)
	var bottom := HBoxContainer.new()
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(bottom)
	var window_label := _label("", 12 if _compact else 14, COLOR_PAPER_DIM)
	window_label.name = "WindowLabel"
	window_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	window_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bottom.add_child(window_label)
	var role_badge := _label("", 12 if _compact else 14, COLOR_PAPER_INK, true)
	role_badge.name = "RoleBadge"
	role_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	bottom.add_child(role_badge)
	var commitment_id := str(card.get("id", ""))
	button.focus_entered.connect(_focus_commitment.bind(commitment_id))
	button.pressed.connect(_activate_note.bind(commitment_id))
	_card_buttons[commitment_id] = button
	_refresh_note_button(button, card)
	return wrapper


func _focus_commitment(commitment_id: String) -> void:
	_cancel_restart_arm()
	if _focused_commitment_id == commitment_id:
		return
	_focused_commitment_id = commitment_id
	_refresh_selection_screen()
	_connect_card_focus_neighbors()


func _activate_note(commitment_id: String) -> void:
	_focus_commitment(commitment_id)
	var selection := _selection()
	var protected_id := str(selection.get("protected", ""))
	var optional_id := str(selection.get("optional_second", ""))
	var target := _protected_button
	if optional_id == commitment_id:
		target = _optional_button
	elif not protected_id.is_empty() and protected_id != commitment_id \
			and is_instance_valid(_optional_button) and not _optional_button.disabled:
		target = _optional_button
	_safe_grab_focus(target)


func _on_protected_action() -> void:
	if _focused_commitment_id.is_empty():
		return
	var current := str(_selection().get("protected", ""))
	if current == _focused_commitment_id:
		_clear_role("protected")
	else:
		_set_role("protected", _focused_commitment_id)


func _on_optional_action() -> void:
	if _focused_commitment_id.is_empty():
		return
	var current := str(_selection().get("optional_second", ""))
	if current == _focused_commitment_id:
		_clear_role("optional_second")
	else:
		_set_role("optional_second", _focused_commitment_id)


func _set_role(slot: String, commitment_id: String, play_feedback: bool = true) -> bool:
	_cancel_restart_arm()
	if slot == "optional_second":
		var reason := _optional_block_reason(_card_from_id(commitment_id))
		if not reason.is_empty():
			_status_key = "ui.status.invalid"
			_status_fallback = "이 약속에는 그 역할을 지정할 수 없습니다."
			_refresh_selection_screen()
			return false
	var before := _selection()
	var proposed := before.duplicate(true)
	proposed[slot] = commitment_id
	if slot == "protected" and str(proposed.get("optional_second", "")) == commitment_id:
		proposed["optional_second"] = ""
	var gate: Variant = _runtime.call(
		"preflight",
		_runtime_state,
		str(proposed.get("protected", "")),
		str(proposed.get("optional_second", "")),
	)
	if not gate is Dictionary or not bool((gate as Dictionary).get("ok", false)):
		_status_key = "ui.status.invalid"
		_status_fallback = "이 약속에는 그 역할을 지정할 수 없습니다."
		_refresh_selection_screen()
		return false
	_draft_selection = proposed
	_snapshot = _runtime_snapshot()
	var after := _selection()
	if str(after.get(slot, "")) != commitment_id:
		return false
	if slot == "protected":
		_status_key = "ui.status.primary_replaced" if not str(before.get("protected", "")).is_empty() else "ui.status.primary_set"
		_status_fallback = "주력 약속을 명시적으로 바꿨습니다." if not str(before.get("protected", "")).is_empty() else "주력 약속을 정했습니다. 이제 가능한 함께 약속을 살펴볼 수 있습니다."
	else:
		_status_key = "ui.status.optional_set"
		_status_fallback = "함께 약속을 정했습니다. 확인하면 이번 달 여유를 씁니다."
	selection_changed.emit(after.duplicate(true))
	_refresh_selection_screen()
	if play_feedback:
		_play_paper_feedback()
		_animate_note_to_slot(commitment_id, slot)
	return true


func _clear_role(slot: String, play_feedback: bool = true) -> bool:
	_cancel_restart_arm()
	var before := _selection()
	if str(before.get(slot, "")).is_empty():
		return false
	_draft_selection[slot] = ""
	if slot == "protected":
		_draft_selection["optional_second"] = ""
	_snapshot = _runtime_snapshot()
	_status_key = "ui.status.primary_removed" if slot == "protected" else "ui.status.optional_removed"
	_status_fallback = "주력을 지웠고 함께 약속도 같이 비웠습니다." if slot == "protected" else "함께 약속을 지웠습니다. 확인 전까지 여유는 남아 있습니다."
	selection_changed.emit(_selection().duplicate(true))
	_refresh_selection_screen()
	if play_feedback:
		_play_paper_feedback()
	return true


func _undo_latest() -> void:
	_cancel_restart_arm()
	var selection := _selection()
	if not str(selection.get("optional_second", "")).is_empty():
		_clear_role("optional_second")
	elif not str(selection.get("protected", "")).is_empty():
		_clear_role("protected")


func _commit_current_month(play_feedback: bool = true) -> Dictionary:
	_cancel_restart_arm()
	if str(_selection().get("protected", "")).is_empty():
		return {}
	var selection := _selection()
	var response: Variant = _runtime.call(
		"resolve_month",
		_runtime_state,
		str(selection.get("protected", "")),
		str(selection.get("optional_second", "")),
	)
	if not response is Dictionary or not bool((response as Dictionary).get("ok", false)):
		_status_key = "ui.status.invalid"
		_status_fallback = "이 선택으로는 이달을 시작할 수 없습니다."
		_refresh_selection_screen()
		return {}
	var response_dict := response as Dictionary
	_runtime_state = (response_dict.get("state", {}) as Dictionary).duplicate(true)
	_result = (response_dict.get("result", {}) as Dictionary).duplicate(true)
	_snapshot = _runtime_snapshot()
	_write_autosave()
	if play_feedback:
		_play_stamp_feedback()
	month_committed.emit(_result.duplicate(true))
	_show_result()
	return _result.duplicate(true)


func _show_result() -> void:
	_set_screen("result")
	_restart_armed = false
	_clear_body()
	_refresh_shell_copy()
	_home_button.visible = true
	_restart_button.visible = true
	var month := int(_result.get("month", _snapshot.get("last_closed_month", _snapshot.get("month", 1))))
	_header_title.text = _format(_t("ui.result.eyebrow", "{month}개월차 마감"), {"month": month})
	_header_subtitle.text = _month_label(month)

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 10)
	_body.add_child(root)
	var title_row := HBoxContainer.new()
	root.add_child(title_row)
	var title := _label(_t("ui.result.title", "지킨 것, 그리고 나를 지나간 것"), 20 if _compact else 24, COLOR_TEXT, true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title)
	title_row.add_child(_label(_t("ui.result.autosaved", "자동저장됨 · 여섯 달 체험판 전용"), 12, COLOR_OK, true))

	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 10 if _compact else 14)
	root.add_child(columns)
	var kept_panel := _result_panel(_t("ui.result.completed", "지킴"), COLOR_OK)
	kept_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(kept_panel)
	var kept_column: VBoxContainer = kept_panel.get_meta("content")
	_add_result_role(kept_column, "protected", _result_role_id("protected"))
	_add_result_role(kept_column, "optional_second", _result_role_id("optional_second"))

	var missed_panel := _result_panel(_t("ui.result.missed", "놓침"), COLOR_DANGER)
	missed_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(missed_panel)
	var missed_column: VBoxContainer = missed_panel.get_meta("content")
	var missed_items := _result_missed_items()
	if missed_items.is_empty():
		missed_column.add_child(_label(_t("ui.result.none", "없음"), 14, COLOR_DIM))
	for item in missed_items:
		if item is Dictionary:
			_add_missed_result(missed_column, item)

	var next_panel := _result_panel(_t("ui.result.margin", "다음 달 여유"), _axis_color(_result_next_margin()))
	next_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(next_panel)
	var next_column: VBoxContainer = next_panel.get_meta("content")
	var next_margin := _result_next_margin()
	if next_margin.is_empty():
		next_column.add_child(_label(_t("ui.result.margin.none", "다음 달로 넘어가는 여유가 없습니다."), 14, COLOR_DIM))
	elif month >= 6:
		var complete_margin := _label(_format(
			_t(
				"ui.result.margin.run_complete",
				"여섯 달 체험 완료 · {axis} 여유는 기록되지만 이 체험에는 다음 달이 없습니다."
			),
			{"axis": _axis_label(next_margin)}
		), 14, _axis_color(next_margin), true)
		complete_margin.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		next_column.add_child(complete_margin)
	else:
		next_column.add_child(_label(_format(
			_t("ui.result.margin.axis", "다음 달에 {axis} 여유가 넘어갑니다."),
			{"axis": _axis_label(next_margin)}
		), 15, _axis_color(next_margin), true))
	var burden_title := _label(_t("ui.result.burdens", "다음 달로 간 부담"), 12, COLOR_ACCENT, true)
	next_column.add_child(burden_title)
	var deferred := _result_ids_by_state("deferred")
	if deferred.is_empty():
		next_column.add_child(_label(_t("ui.result.none", "없음"), 13, COLOR_DIM))
	else:
		for commitment_id in deferred:
			next_column.add_child(_label(_format(
				_t("ui.result.deferred", "다음 달 한 번 돌아옴 · {label}"),
				{"label": _commitment_label(str(commitment_id))}
			), 13, COLOR_TEXT))

	var action_row := HBoxContainer.new()
	action_row.alignment = BoxContainer.ALIGNMENT_END
	root.add_child(action_row)
	var next_month := _result_next_month()
	var next_button: Button
	if month >= 6 or next_month > 6 or next_month <= 0:
		next_button = _button(_t("ui.result.recap", "여섯 달 회고 보기"), true)
	else:
		next_button = _button(_format(_t("ui.result.next", "{month}개월차로"), {"month": next_month}), true)
	next_button.custom_minimum_size.x = 260
	next_button.pressed.connect(_advance_from_result)
	action_row.add_child(next_button)
	_footer.text = _t("ui.controls", "방향키 / D패드 · 이동    Enter / 남쪽 버튼 · 확인    Esc / 동쪽 버튼 · 되돌리기")
	call_deferred("_safe_grab_focus", next_button)


func _advance_from_result() -> bool:
	var month := int(_result.get("month", 0))
	_snapshot = _runtime_snapshot()
	if month >= 6 or int(_snapshot.get("month", 7)) > 6 or bool(_runtime_state.get("finished", false)):
		_show_recap()
	else:
		_result = {}
		_draft_selection = {"protected": "", "optional_second": ""}
		_focused_commitment_id = _first_card_id()
		_status_key = ""
		_status_fallback = ""
		_write_autosave()
		_show_selection()
	return true


func _show_recap() -> void:
	_set_screen("recap")
	_restart_armed = false
	_snapshot = _runtime_snapshot()
	_recap = _build_recap()
	_write_autosave()
	_clear_body()
	_refresh_shell_copy()
	_home_button.visible = true
	_restart_button.visible = true
	_header_title.text = _t("ui.recap.eyebrow", "M01–M06 완료")
	_header_subtitle.text = _t("ui.recap.title", "여섯 달의 선택")

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 8 if _compact else 12)
	_body.add_child(root)
	var body_copy := _label(_t(
		"ui.recap.body",
		"점수가 아닙니다. 무엇을 주력으로 지켰고, 어떤 여유로 하나를 더 들었으며, 어느 문을 닫게 두었는지가 만든 경로입니다."
	), 14 if _compact else 16, COLOR_TEXT)
	body_copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(body_copy)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8 if _compact else 10)
	grid.add_theme_constant_override("v_separation", 8 if _compact else 10)
	root.add_child(grid)
	var entries := _recap_entries()
	for month in range(1, 7):
		var entry := _recap_entry(entries, month)
		grid.add_child(_recap_card(month, entry))

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_END
	actions.add_theme_constant_override("separation", 10)
	root.add_child(actions)
	var home_button := _button(_t("ui.recap.home", "처음 화면으로"), false)
	home_button.pressed.connect(_show_home)
	actions.add_child(home_button)
	var restart_button := _button(_t("ui.recap.restart", "다른 경로로 다시"), true)
	restart_button.pressed.connect(_on_recap_restart.bind(restart_button))
	actions.add_child(restart_button)
	_footer.text = _t("ui.controls", "방향키 / D패드 · 이동    Enter / 남쪽 버튼 · 확인    Esc / 동쪽 버튼 · 되돌리기")
	call_deferred("_safe_grab_focus", restart_button)


func _on_recap_restart(button: Button) -> void:
	if not _restart_armed:
		_restart_armed = true
		button.text = _t("ui.home.restart_confirm", "한 번 더 누르면 체험판 저장을 지웁니다")
		_apply_button_style(button, true, COLOR_DANGER)
		return
	_start_new_run(true)


func _recap_card(month: int, entry: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size.y = 92 if _compact else 112
	panel.add_theme_stylebox_override("panel", _panel_style(COLOR_PANEL, COLOR_BORDER, 1, 7))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	margin.add_child(column)
	column.add_child(_label(_format(
		_t("ui.recap.month", "M{month} · {label}"),
		{"month": month, "label": _month_label(month)}
	), 13 if _compact else 14, COLOR_ACCENT, true))
	var protected_id := str(entry.get("protected", ""))
	var optional_id := str(entry.get("optional_second", ""))
	var protected_line := _label(_format(
		_t("ui.recap.protected", "주력 · {label}"),
		{"label": _commitment_label(protected_id)}
	), 12 if _compact else 13, COLOR_TEXT)
	protected_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(protected_line)
	if optional_id.is_empty():
		column.add_child(_label(_t("ui.recap.no_optional", "함께 · 없음"), 12 if _compact else 13, COLOR_DIM))
	else:
		var optional_line := _label(_format(
			_t("ui.recap.optional", "함께 · {label}"),
			{"label": _commitment_label(optional_id)}
		), 12 if _compact else 13, COLOR_TEXT)
		optional_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(optional_line)
	var deferred := _string_array(entry.get("deferred", []))
	var expired := _string_array(entry.get("expired", entry.get("closed", [])))
	if not deferred.is_empty():
		var deferred_line := _label(_format(
			_t("ui.recap.deferred", "한 번 미룸 · {labels}"),
			{"labels": _joined_commitment_labels(deferred)}
		), 11 if _compact else 12, COLOR_CASH)
		deferred_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(deferred_line)
	if not expired.is_empty():
		var expired_line := _label(_format(
			_t("ui.recap.closed", "닫힘 · {labels}"),
			{"labels": _joined_commitment_labels(expired)}
		), 11 if _compact else 12, COLOR_DIM)
		expired_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(expired_line)
	return panel


func _refresh_role_actions(card: Dictionary) -> void:
	var commitment_id := str(card.get("id", ""))
	var selection := _selection()
	var is_protected := str(selection.get("protected", "")) == commitment_id
	var is_optional := str(selection.get("optional_second", "")) == commitment_id
	var protected_id := str(selection.get("protected", ""))
	var optional_id := str(selection.get("optional_second", ""))
	var protected_line := _format(_t(
		"ui.month.selection.protected",
		"주력 · {label}"
	), {"label": _commitment_label(protected_id)})
	var optional_line := _format(_t(
		"ui.month.selection.optional",
		"함께 · {label}"
	), {"label": _commitment_label(optional_id)})
	var protected_action := _t(
		"ui.detail.protected_remove" if is_protected else "ui.detail.protected_action",
		"주력에서 빼기" if is_protected else "주력으로 지키기"
	)
	var optional_action := _t(
		"ui.detail.optional_remove" if is_optional else "ui.detail.optional_action",
		"함께에서 빼기" if is_optional else "함께 지키기"
	)
	_protected_button.text = "%s\n%s" % [protected_line, protected_action]
	_optional_button.text = "%s\n%s" % [optional_line, optional_action]
	_set_button_enabled(_protected_button, true)
	var block_reason := "" if is_optional else _optional_block_reason(card)
	_set_button_enabled(_optional_button, is_optional or block_reason.is_empty())
	_apply_pocket_style(_protected_button, not protected_id.is_empty(), true)
	_apply_pocket_style(_optional_button, not optional_id.is_empty(), false)
	_role_notice_label.text = _role_notice(card, block_reason)
	_role_notice_label.add_theme_color_override(
		"font_color",
		COLOR_DANGER if not block_reason.is_empty() else _axis_color(str(card.get("axis", "")))
	)


func _optional_block_reason(card: Dictionary) -> String:
	if card.is_empty():
		return "empty"
	var selection := _selection()
	var protected_id := str(selection.get("protected", ""))
	if protected_id.is_empty():
		return "no_primary"
	if protected_id == str(card.get("id", "")):
		return "same_card"
	var margin := _margin_axis()
	if margin.is_empty():
		return "no_margin"
	if margin != str(card.get("axis", "")):
		return "mismatch"
	return ""


func _role_notice(card: Dictionary, block_reason: String) -> String:
	match block_reason:
		"no_primary":
			return _t("ui.detail.optional_no_primary", "먼저 주력 약속을 고르세요.")
		"same_card":
			return _t("ui.detail.optional_same_card", "같은 약속을 두 역할에 놓을 수 없습니다.")
		"no_margin":
			return _t("ui.detail.optional_no_margin", "이번 달에는 지난달에서 온 여유가 없습니다.")
		"mismatch":
			return _format(_t(
				"ui.detail.optional_mismatch",
				"{margin} 여유로는 {card_axis} 약속을 함께 지킬 수 없습니다."
			), {
				"margin": _axis_label(_margin_axis()),
				"card_axis": _axis_label(str(card.get("axis", "")))
			})
	var selection := _selection()
	if str(selection.get("optional_second", "")) == str(card.get("id", "")):
		return _format(_t(
			"ui.detail.optional_spends",
			"확인하면 이번 달 {axis_lower} 여유를 쓰며 되돌려 받지 않습니다."
		), {"axis_lower": _axis_lower(str(card.get("axis", "")))})
	var repay_kind := _card_repay_kind(card)
	if repay_kind == "pressure":
		return _t("ui.detail.repay_pressure", "지키면 지난달 압력을 갚습니다. 새 여유는 생기지 않습니다.")
	if repay_kind == "deferred":
		return _t("ui.detail.repay_deferred", "지키면 지난달 미룬 약속을 갚습니다. 새 여유는 생기지 않습니다.")
	return _format(_t(
		"ui.detail.single_margin",
		"이 주력 하나만 지키면 다음 달 {axis_lower} 여유가 생길 수 있습니다."
	), {"axis_lower": _axis_lower(str(card.get("axis", "")))})


func _detail_copy(card: Dictionary) -> String:
	var commitment_id := str(card.get("id", ""))
	var lines := PackedStringArray()
	lines.append("%s · %s · %s" % [
		_axis_label(str(card.get("axis", ""))),
		_source_label(str(card.get("source", ""))),
		_format(_t("ui.card.due", "마감 · {week}주차"), {"week": int(card.get("due_week", 0))}),
	])
	lines.append(_commitment_label(commitment_id))
	lines.append(_choice_window_detail(card))
	return "\n".join(lines)


func _card_button_text(card: Dictionary) -> String:
	var commitment_id := str(card.get("id", ""))
	var badge := ""
	var selection := _selection()
	if str(selection.get("protected", "")) == commitment_id:
		badge = "[%s] " % _t("ui.card.protected_badge", "주력")
	elif str(selection.get("optional_second", "")) == commitment_id:
		badge = "[%s] " % _t("ui.card.optional_badge", "함께")
	return "%s%s · %s\n%s\n%s" % [
		badge,
		_axis_label(str(card.get("axis", ""))),
		_format(_t("ui.card.due", "마감 · {week}주차"), {"week": int(card.get("due_week", 0))}),
		_commitment_label(commitment_id),
		_choice_window_badge(card)
	]


func _refresh_note_button(button: Button, card: Dictionary) -> void:
	if not is_instance_valid(button) or card.is_empty():
		return
	var axis := str(card.get("axis", ""))
	var commitment_id := str(card.get("id", ""))
	var icon := button.find_child("AxisIcon", true, false) as TextureRect
	if is_instance_valid(icon):
		icon.texture = load(_axis_icon_path(axis))
		icon.modulate = COLOR_PAPER_INK
	var axis_label := button.find_child("AxisLabel", true, false) as Label
	if is_instance_valid(axis_label):
		axis_label.text = _axis_label(axis)
	var due_label := button.find_child("DueLabel", true, false) as Label
	if is_instance_valid(due_label):
		due_label.text = _format(
			_t("ui.card.due", "마감 · {week}주차"),
			{"week": int(card.get("due_week", 0))}
		)
	var action_label := button.find_child("ActionLabel", true, false) as Label
	if is_instance_valid(action_label):
		action_label.text = _commitment_label(commitment_id)
	var window_label := button.find_child("WindowLabel", true, false) as Label
	if is_instance_valid(window_label):
		window_label.text = _choice_window_badge(card)
	var role_badge := button.find_child("RoleBadge", true, false) as Label
	if is_instance_valid(role_badge):
		var selection := _selection()
		if str(selection.get("protected", "")) == commitment_id:
			role_badge.text = _t("ui.card.protected_badge", "주력")
		elif str(selection.get("optional_second", "")) == commitment_id:
			role_badge.text = _t("ui.card.optional_badge", "함께")
		else:
			role_badge.text = ""
	_apply_note_style(button, _is_selected(commitment_id))


func _axis_icon_path(axis: String) -> String:
	match axis:
		"cash": return "res://assets/ui/icons/icon_money.svg"
		"health": return "res://assets/ui/icons/icon_health.svg"
		"trust": return "res://assets/ui/icons/icon_relationship.svg"
	return "res://assets/ui/icons/icon_info.svg"


func _choice_window_badge(card: Dictionary) -> String:
	if str(card.get("miss", "expired")) == "deferred":
		return _t("ui.card.window.deferred", "미룸 · 다음 달 한 번")
	return _t("ui.card.window.expired", "기한 · 이번 달에 끝남")


func _choice_window_detail(card: Dictionary) -> String:
	if str(card.get("miss", "expired")) == "deferred":
		return _t(
			"ui.detail.window.deferred",
			"미룸 · 놓치면 다음 달 선택으로 한 번 돌아옵니다."
		)
	return _t(
		"ui.detail.window.expired",
		"기한 · 이번 달이 지나면 이 약속은 되돌릴 수 없습니다."
	)


func _selection_copy() -> String:
	var selection := _selection()
	var protected_id := str(selection.get("protected", ""))
	var optional_id := str(selection.get("optional_second", ""))
	if protected_id.is_empty():
		return _t("ui.month.selection.none", "주력 약속을 아직 고르지 않았습니다.")
	var lines := PackedStringArray()
	lines.append(_format(
		_t("ui.month.selection.protected", "주력 · {label}"),
		{"label": _commitment_label(protected_id)}
	))
	if not optional_id.is_empty():
		lines.append(_format(
			_t("ui.month.selection.optional", "함께 · {label}"),
			{"label": _commitment_label(optional_id)}
		))
	return "\n".join(lines)


func _margin_copy() -> String:
	var margin := _margin_axis()
	if margin.is_empty():
		return _t("ui.month.margin.none", "지난달에서 온 여유 없음 · 이번 달은 주력 하나")
	return _format(_t(
		"ui.month.margin.available",
		"{axis} 여유 있음 · {axis_lower} 약속 하나를 함께 지킬 수 있음"
	), {"axis": _axis_label(margin), "axis_lower": _axis_lower(margin)})


func _status_copy() -> String:
	return _t(_status_key, _status_fallback)


func _add_result_role(column: VBoxContainer, slot: String, commitment_id: String) -> void:
	if commitment_id.is_empty():
		if slot == "optional_second":
			column.add_child(_label(_t("ui.recap.no_optional", "함께 · 없음"), 13, COLOR_DIM))
		return
	var title_key := "ui.result.protected" if slot == "protected" else "ui.result.optional"
	var title_fallback := "주력" if slot == "protected" else "함께"
	column.add_child(_label(_t(title_key, title_fallback), 12, COLOR_ACCENT, true))
	var label := _label(_commitment_label(commitment_id), 14 if _compact else 15, COLOR_TEXT, true)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(label)


func _add_missed_result(column: VBoxContainer, item: Dictionary) -> void:
	var commitment_id := str(item.get("id", item.get("commitment_id", "")))
	var state := str(item.get("state", "expired"))
	var color := COLOR_CASH if state == "deferred" else COLOR_DIM
	var badge := _t(
		"ui.result.deferred_status",
		"다음 달 선택으로 한 번 돌아옵니다."
	) if state == "deferred" else _t(
		"ui.result.expired_status",
		"이번 약속은 지나갔습니다."
	)
	var copy := "%s\n%s" % [
		_commitment_label(commitment_id),
		badge
	]
	var label := _label(copy, 12 if _compact else 13, color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(label)


func _result_panel(title: String, color: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style(COLOR_PANEL, color.darkened(0.28), 1, 8))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)
	column.add_child(_label(title, 13, color, true))
	panel.set_meta("content", column)
	return panel


func _connect_card_focus_neighbors() -> void:
	var ids := _card_id_order()
	for index in range(ids.size()):
		var button: Button = _card_buttons.get(ids[index])
		if not is_instance_valid(button):
			continue
		var row := index / 2
		var col := index % 2
		var up_index := index - 2
		var down_index := index + 2
		var left_index := index - 1 if col == 1 else -1
		var right_index := index + 1 if col == 0 and index + 1 < ids.size() else -1
		if up_index >= 0:
			_set_focus_neighbor(button, SIDE_TOP, _card_buttons.get(ids[up_index]))
		if down_index < ids.size():
			_set_focus_neighbor(button, SIDE_BOTTOM, _card_buttons.get(ids[down_index]))
		if left_index >= 0:
			_set_focus_neighbor(button, SIDE_LEFT, _card_buttons.get(ids[left_index]))
		if right_index >= 0:
			_set_focus_neighbor(button, SIDE_RIGHT, _card_buttons.get(ids[right_index]))
		elif is_instance_valid(_protected_button):
			_set_focus_neighbor(button, SIDE_RIGHT, _protected_button)
	var focused_button: Button = _card_buttons.get(_focused_commitment_id)
	if is_instance_valid(focused_button) and is_instance_valid(_protected_button):
		_set_focus_neighbor(_protected_button, SIDE_LEFT, focused_button)
		_set_focus_neighbor(_optional_button, SIDE_LEFT, focused_button)
	if is_instance_valid(_optional_button) and _optional_button.focus_mode != Control.FOCUS_NONE:
		_set_focus_neighbor(_protected_button, SIDE_BOTTOM, _optional_button)
		_set_focus_neighbor(_optional_button, SIDE_TOP, _protected_button)
		_set_focus_neighbor(_optional_button, SIDE_BOTTOM, _confirm_button)
		_set_focus_neighbor(_confirm_button, SIDE_TOP, _optional_button)
	else:
		_set_focus_neighbor(_protected_button, SIDE_BOTTOM, _confirm_button)
		_set_focus_neighbor(_confirm_button, SIDE_TOP, _protected_button)
	_set_focus_neighbor(_confirm_button, SIDE_LEFT, _undo_button)
	_set_focus_neighbor(_undo_button, SIDE_RIGHT, _confirm_button)


func _animate_note_to_slot(commitment_id: String, slot: String) -> void:
	if not is_instance_valid(_fx_layer) or _screen != "selection":
		return
	var source: Button = _card_buttons.get(commitment_id)
	var target: Button = _protected_button if slot == "protected" else _optional_button
	if not is_instance_valid(source) or not is_instance_valid(target):
		return
	var ghost := Panel.new()
	ghost.name = "MovingPromisePaper"
	ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost.position = source.global_position
	ghost.size = source.size
	ghost.modulate = Color(1, 1, 1, 0.88)
	ghost.add_theme_stylebox_override(
		"panel", _paper_style(COLOR_PAPER_FOCUS, COLOR_ACCENT, 2, true))
	_fx_layer.add_child(ghost)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(ghost, "position", target.global_position, 0.17)
	tween.tween_property(ghost, "size", target.size, 0.17)
	tween.tween_property(ghost, "modulate:a", 0.0, 0.17)
	tween.chain().tween_callback(ghost.queue_free)


func _play_paper_feedback() -> void:
	if is_instance_valid(_paper_player) and _paper_player.stream != null:
		_paper_player.play()


func _play_stamp_feedback() -> void:
	if is_instance_valid(_stamp_player) and _stamp_player.stream != null:
		_stamp_player.play()


func _release_feedback_player(player: AudioStreamPlayer) -> void:
	if not is_instance_valid(player):
		return
	player.stop()
	player.stream = null


func _cancel_restart_arm() -> void:
	if not _restart_armed:
		return
	_restart_armed = false
	if is_instance_valid(_restart_button):
		_restart_button.text = _t("ui.home.restart", "처음부터")
		_apply_button_style(_restart_button, false, COLOR_BORDER)
	if _screen == "selection" and is_instance_valid(_footer):
		_footer.text = _status_copy() if not _status_key.is_empty() else _t(
			"ui.controls",
			"방향키 / D패드 · 이동    Enter / 남쪽 버튼 · 확인    Esc / 동쪽 버튼 · 되돌리기"
		)


func _set_focus_neighbor(from: Control, side: Side, to: Control) -> void:
	if not is_instance_valid(from) or not is_instance_valid(to):
		return
	var path := from.get_path_to(to)
	match side:
		SIDE_LEFT: from.focus_neighbor_left = path
		SIDE_TOP: from.focus_neighbor_top = path
		SIDE_RIGHT: from.focus_neighbor_right = path
		SIDE_BOTTOM: from.focus_neighbor_bottom = path


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if _screen == "selection":
		_undo_latest()
		get_viewport().set_input_as_handled()
	elif _screen in ["result", "recap"]:
		_show_home()
		get_viewport().set_input_as_handled()


func _toggle_language() -> void:
	_language = "en" if _language == "ko" else "ko"
	_restart_armed = false
	_refresh_current_screen()


func _refresh_current_screen() -> void:
	match _screen:
		"selection": _rebuild_selection_screen()
		"result": _show_result()
		"recap": _show_recap()
		_: _show_home()


func _refresh_shell_copy() -> void:
	_language_button.text = _t("ui.language_toggle", "ENGLISH")
	_home_button.text = _t("ui.action.back_home", "처음 화면")
	_restart_button.text = _t("ui.home.restart", "처음부터")
	_apply_button_style(_restart_button, false, COLOR_BORDER)


func _set_screen(screen_name: String) -> void:
	_screen = screen_name
	set_meta("story_map_m1m6_screen", _screen)
	screen_changed.emit(_screen)


func _update_selection_metadata() -> void:
	var selection := _selection()
	set_meta("story_map_m1m6_month", int(_snapshot.get("month", 1)))
	set_meta("story_map_m1m6_protected", str(selection.get("protected", "")))
	set_meta("story_map_m1m6_optional_second", str(selection.get("optional_second", "")))
	set_meta("story_map_m1m6_margin_axis", _margin_axis())


func _runtime_snapshot() -> Dictionary:
	if _runtime == null or not _runtime.has_method("snapshot"):
		return {}
	var value: Variant = _runtime.call("snapshot", _runtime_state)
	if value is Dictionary:
		var result := (value as Dictionary).duplicate(true)
		result["selection"] = _draft_selection.duplicate(true)
		var month_data: Variant = result.get("month_data", {})
		if month_data is Dictionary:
			result["design_label"] = str((month_data as Dictionary).get("design_label", ""))
			result["contract"] = (month_data as Dictionary).get("contract", {}).duplicate(true)
		if not _result.is_empty():
			result["last_result"] = _result.duplicate(true)
		return result
	return {}


func _selection() -> Dictionary:
	return _draft_selection.duplicate(true)


func _cards() -> Array:
	var value: Variant = _snapshot.get("cards", _snapshot.get("commitments", []))
	return value if value is Array else []


func _card_from_id(commitment_id: String) -> Dictionary:
	for raw_card in _cards():
		if raw_card is Dictionary and str((raw_card as Dictionary).get("id", "")) == commitment_id:
			return (raw_card as Dictionary).duplicate(true)
	return {}


func _card_from_anywhere(commitment_id: String) -> Dictionary:
	var card := _card_from_id(commitment_id)
	if not card.is_empty():
		return card
	var result_cards: Variant = _result.get("cards", _result.get("commitments", []))
	if result_cards is Array:
		for raw_card in result_cards:
			if raw_card is Dictionary and str((raw_card as Dictionary).get("id", "")) == commitment_id:
				return (raw_card as Dictionary).duplicate(true)
	if _runtime != null and _runtime.has_method("card_data"):
		var runtime_card: Variant = _runtime.call("card_data", commitment_id)
		if runtime_card is Dictionary:
			return (runtime_card as Dictionary).duplicate(true)
	return {"id": commitment_id}


func _first_card_id() -> String:
	for raw_card in _cards():
		if raw_card is Dictionary:
			return str((raw_card as Dictionary).get("id", ""))
	return ""


func _card_id_order() -> Array[String]:
	var ids: Array[String] = []
	for raw_card in _cards():
		if raw_card is Dictionary:
			ids.append(str((raw_card as Dictionary).get("id", "")))
	return ids


func _is_selected(commitment_id: String) -> bool:
	var selection := _selection()
	return commitment_id == str(selection.get("protected", "")) or commitment_id == str(selection.get("optional_second", ""))


func _margin_axis() -> String:
	var value: Variant = _snapshot.get("margin_axis", _snapshot.get("carried_margin", ""))
	if value == null:
		return ""
	if value is Dictionary:
		return str((value as Dictionary).get("axis", ""))
	return str(value)


func _card_repay_kind(card: Dictionary) -> String:
	if bool(card.get("repays_active_pressure", card.get("repays_pressure", false))):
		return "pressure"
	if bool(card.get("repays_active_deferred", card.get("repays_deferred", false))):
		return "deferred"
	var strategy: Variant = card.get("strategy", {})
	if strategy is Dictionary:
		var active_costs: Array = _runtime_state.get("costs", [])
		for pressure in _array_value(strategy, ["repays_pressure"], []):
			if str(pressure) in active_costs:
				return "pressure"
		var open_debts: Array = _runtime_state.get("open_debts", [])
		for source_id in _array_value(strategy, ["repays_deferred"], []):
			if str(source_id) in open_debts:
				return "deferred"
	return ""


func _result_role_id(slot: String) -> String:
	var selection: Variant = _result.get("selection", {})
	if selection is Dictionary and (selection as Dictionary).has(slot):
		return str((selection as Dictionary).get(slot, ""))
	if slot == "protected":
		return str(_result.get("primary_id", _result.get(slot, "")))
	return str(_result.get("optional_id", _result.get(slot, "")))


func _result_missed_items() -> Array:
	var value: Variant = _result.get("missed", _result.get("missed_receipts", []))
	return value if value is Array else []


func _result_ids_by_state(state: String) -> Array[String]:
	var ids: Array[String] = []
	for item in _result_missed_items():
		if not item is Dictionary:
			continue
		if str((item as Dictionary).get("state", "expired")) == state:
			ids.append(str((item as Dictionary).get("id", (item as Dictionary).get("commitment_id", ""))))
	return ids


func _result_next_margin() -> String:
	var value: Variant = _result.get("margin_after", _result.get("next_margin_axis", _snapshot.get("margin_axis", "")))
	return "" if value == null else str(value)


func _result_next_month() -> int:
	return int(_runtime_state.get("next_month", int(_result.get("month", 0)) + 1))


func _result_from_last_plan() -> Dictionary:
	var plans: Array = _runtime_state.get("plans", [])
	if plans.is_empty() or not plans[-1] is Dictionary:
		return {}
	var plan: Dictionary = (plans[-1] as Dictionary).duplicate(true)
	var month := int(plan.get("month", 0))
	var month_data: Dictionary = _runtime.call("month_data", month)
	var receipts: Dictionary = _runtime_state.get("receipts", {})
	var completed: Array[String] = []
	var missed: Array[Dictionary] = []
	for raw_card in month_data.get("commitments", []):
		if not raw_card is Dictionary:
			continue
		var commitment_id := str((raw_card as Dictionary).get("id", ""))
		if not receipts.has(commitment_id):
			continue
		var receipt: Dictionary = receipts[commitment_id]
		if int(receipt.get("resolved_month", 0)) != month:
			continue
		var state_name := str(receipt.get("state", ""))
		if state_name == "completed":
			completed.append(commitment_id)
		else:
			var strategy: Dictionary = (raw_card as Dictionary).get("strategy", {})
			var missed_data: Dictionary = strategy.get("missed", {})
			missed.append({
				"id": commitment_id,
				"state": state_name,
				"costs": (missed_data.get("costs", []) as Array).duplicate(),
			})
	return {
		"month": month,
		"primary_id": str(plan.get("primary_id", "")),
		"optional_id": str(plan.get("optional_id", "")),
		"completed": completed,
		"missed": missed,
		"margin_before": str(plan.get("margin_before", "")),
		"margin_after": str(plan.get("margin_after", "")),
		"focus_actor": str(plan.get("focus_actor", "")),
		"cards": (month_data.get("commitments", []) as Array).duplicate(true),
	}


func _build_recap() -> Dictionary:
	var entries: Array[Dictionary] = []
	for raw_plan in _runtime_state.get("plans", []):
		if not raw_plan is Dictionary:
			continue
		var plan: Dictionary = (raw_plan as Dictionary).duplicate(true)
		var month := int(plan.get("month", 0))
		var states := _missed_states_for_month(month)
		entries.append({
			"month": month,
			"protected": str(plan.get("primary_id", "")),
			"optional_second": str(plan.get("optional_id", "")),
			"deferred": states.get("deferred", []),
			"expired": states.get("expired", []),
			"focus_actor": str(plan.get("focus_actor", "")),
		})
	return {"months": entries}


func _missed_states_for_month(month: int) -> Dictionary:
	var result := {"deferred": [], "expired": []}
	var receipts: Dictionary = _runtime_state.get("receipts", {})
	for commitment_id in receipts:
		var receipt: Variant = receipts[commitment_id]
		if not receipt is Dictionary or int((receipt as Dictionary).get("resolved_month", 0)) != month:
			continue
		var state_name := str((receipt as Dictionary).get("state", ""))
		if state_name in ["deferred", "expired"]:
			(result[state_name] as Array).append(str(commitment_id))
	return result


func _recap_entries() -> Array:
	var value: Variant = _recap.get("months", _recap.get("entries", _recap.get("history", [])))
	if value is Array:
		return value
	var plans: Variant = _runtime_state.get("plans", [])
	return plans if plans is Array else []


func _recap_entry(entries: Array, month: int) -> Dictionary:
	for raw_entry in entries:
		if raw_entry is Dictionary and int((raw_entry as Dictionary).get("month", 0)) == month:
			var entry := (raw_entry as Dictionary).duplicate(true)
			if not entry.has("protected"):
				entry["protected"] = str(entry.get("primary_id", ""))
			if not entry.has("optional_second"):
				entry["optional_second"] = str(entry.get("optional_id", ""))
			var states := _missed_states_for_month(month)
			entry["deferred"] = states.get("deferred", [])
			entry["expired"] = states.get("expired", [])
			return entry
	return {"month": month, "protected": "", "optional_second": "", "deferred": [], "expired": []}


func _month_label(month: int) -> String:
	if _language == "en":
		var entry: Variant = _overlay.get("month_copy", {}).get("M%02d" % month, {})
		if entry is Dictionary:
			return str((entry as Dictionary).get("design_label", "M%02d" % month))
	if _runtime != null and _runtime.has_method("month_data"):
		var month_data: Variant = _runtime.call("month_data", month)
		if month_data is Dictionary:
			return str((month_data as Dictionary).get("design_label", "M%02d" % month))
	return "M%02d" % month


func _commitment_label(commitment_id: String) -> String:
	if commitment_id.is_empty():
		return _t("ui.result.none", "없음")
	var focus_actor := _focus_actor_for_commitment(commitment_id)
	if _language == "en":
		var entry: Variant = _overlay.get("commitment_copy", {}).get(commitment_id, {})
		if entry is Dictionary:
			var actor_variants: Variant = (entry as Dictionary).get("label_by_actor", {})
			if actor_variants is Dictionary and not focus_actor.is_empty() and (actor_variants as Dictionary).has(focus_actor):
				return str((actor_variants as Dictionary).get(focus_actor, ""))
			return str((entry as Dictionary).get("label", commitment_id))
	if commitment_id == "m05_second_crossing":
		if focus_actor == "daeun":
			return "다은에게 먼저 연락해 두 번째 만남을 잡는다"
		if focus_actor == "jiyeon":
			return "지연에게 먼저 연락해 두 번째 만남을 잡는다"
	if commitment_id == "m06_person_date":
		if focus_actor == "daeun":
			return "M05에 다은과 정한 금요일 데이트에 나간다"
		if focus_actor == "jiyeon":
			return "M05에 지연과 정한 금요일 데이트에 나간다"
	var card := _card_from_anywhere(commitment_id)
	return str(card.get("label", commitment_id))


func _focus_actor_for_commitment(commitment_id: String) -> String:
	if commitment_id == "m05_second_crossing":
		for raw_plan in _runtime_state.get("plans", []):
			if not raw_plan is Dictionary or int((raw_plan as Dictionary).get("month", 0)) != 3:
				continue
			var primary_id := str((raw_plan as Dictionary).get("primary_id", ""))
			var optional_id := str((raw_plan as Dictionary).get("optional_id", ""))
			for selected_id in [primary_id, optional_id]:
				if selected_id == "m03_daeun_return":
					return "daeun"
				if selected_id == "m03_jiyeon_answer":
					return "jiyeon"
	if commitment_id == "m06_person_date":
		var receipts: Dictionary = _runtime_state.get("receipts", {})
		var receipt: Variant = receipts.get("m05_second_crossing", {})
		if receipt is Dictionary:
			var actors: Variant = (receipt as Dictionary).get("actors", {})
			if actors is Dictionary:
				return str((actors as Dictionary).get("person", ""))
	return ""


func _axis_label(axis: String) -> String:
	if _language == "en":
		var entry: Variant = _overlay.get("axis_copy", {}).get(axis, {})
		if entry is Dictionary:
			return str((entry as Dictionary).get("label", axis.to_upper()))
	match axis:
		"cash": return "현금"
		"health": return "몸"
		"trust": return "관계"
	return axis


func _axis_lower(axis: String) -> String:
	if _language == "en":
		var entry: Variant = _overlay.get("axis_copy", {}).get(axis, {})
		if entry is Dictionary:
			return str((entry as Dictionary).get("lower", axis))
	return _axis_label(axis)


func _source_label(source: String) -> String:
	if _language == "en":
		return str(_overlay.get("source_copy", {}).get(source, source.to_upper()))
	match source:
		"pressure": return "압력"
		"opportunity": return "기회"
		"person_promise": return "사람 약속"
	return source


func _axis_color(axis: String) -> Color:
	match axis:
		"cash": return COLOR_CASH
		"health": return COLOR_HEALTH
		"trust": return COLOR_TRUST
	return COLOR_BORDER


func _t(copy_id: String, korean_fallback: String) -> String:
	if _language == "en":
		return str(_overlay.get("ui_copy", {}).get(copy_id, copy_id))
	return korean_fallback


func _format(template: String, values: Dictionary) -> String:
	return template.format(values)


func _joined_commitment_labels(ids: Array[String]) -> String:
	var labels := PackedStringArray()
	for commitment_id in ids:
		labels.append(_commitment_label(commitment_id))
	return ", ".join(labels)


func _write_autosave() -> bool:
	if _runtime_state.is_empty():
		return false
	var wrapper := {
		"schema_version": SAVE_SCHEMA_VERSION,
		"runtime_state": _runtime_state.duplicate(true),
	}
	var file := FileAccess.open(AUTOSAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(wrapper, "\t"))
	file.close()
	return true


func _has_valid_autosave() -> bool:
	if not FileAccess.file_exists(AUTOSAVE_PATH):
		return false
	var wrapper := _read_json_dictionary(AUTOSAVE_PATH)
	return int(wrapper.get("schema_version", 0)) == SAVE_SCHEMA_VERSION and wrapper.get("runtime_state", null) is Dictionary


func _peek_saved_month() -> int:
	var wrapper := _read_json_dictionary(AUTOSAVE_PATH)
	var state: Variant = wrapper.get("runtime_state", {})
	if state is Dictionary:
		return int((state as Dictionary).get("next_month", 1))
	return 1


func _read_json_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed if parsed is Dictionary else {}


func _dictionary_value(source: Dictionary, keys: Array, fallback: Dictionary) -> Dictionary:
	for raw_key in keys:
		var value: Variant = source.get(str(raw_key), null)
		if value is Dictionary:
			return (value as Dictionary).duplicate(true)
	return fallback.duplicate(true)


func _array_value(source: Dictionary, keys: Array, fallback: Array) -> Array:
	for raw_key in keys:
		var value: Variant = source.get(str(raw_key), null)
		if value is Array:
			return (value as Array).duplicate(true)
	return fallback.duplicate(true)


func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item in value:
			if item is Dictionary:
				result.append(str((item as Dictionary).get("id", (item as Dictionary).get("commitment_id", ""))))
			else:
				result.append(str(item))
	return result


func _clear_body() -> void:
	for child in _body.get_children():
		_body.remove_child(child)
		child.queue_free()
	if is_instance_valid(_fx_layer):
		for child in _fx_layer.get_children():
			_fx_layer.remove_child(child)
			child.queue_free()


func _collect_visible_text(node: Node, lines: PackedStringArray) -> void:
	if node is Label and (node as Label).is_visible_in_tree():
		lines.append((node as Label).text)
	elif node is Button and (node as Button).is_visible_in_tree():
		lines.append((node as Button).text)
	for child in node.get_children():
		_collect_visible_text(child, lines)


func _count_meta_nodes(node: Node, meta_key: String) -> int:
	var count := 1 if node.has_meta(meta_key) else 0
	for child in node.get_children():
		count += _count_meta_nodes(child, meta_key)
	return count


func _count_class_nodes(node: Node, class_name_value: String) -> int:
	var count := 1 if node.is_class(class_name_value) else 0
	for child in node.get_children():
		count += _count_class_nodes(child, class_name_value)
	return count


func _count_named_nodes(node: Node, node_name: String) -> int:
	var count := 1 if str(node.name) == node_name else 0
	for child in node.get_children():
		count += _count_named_nodes(child, node_name)
	return count


func _control_rect_array(control: Control) -> Array[float]:
	if not is_instance_valid(control):
		return []
	return [
		control.global_position.x,
		control.global_position.y,
		control.size.x,
		control.size.y,
	]


func _focused_meta_value(meta_key: StringName) -> String:
	var owner := get_viewport().gui_get_focus_owner()
	if not is_instance_valid(owner) or not owner.has_meta(meta_key):
		return ""
	return str(owner.get_meta(meta_key))


func _label(text_value: String, font_size: int, color: Color, bold: bool = false) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	if bold:
		label.add_theme_constant_override("outline_size", 1)
		label.add_theme_color_override("font_outline_color", Color("#00000066"))
	return label


func _button(text_value: String, filled: bool) -> Button:
	var button := Button.new()
	button.text = text_value
	button.focus_mode = Control.FOCUS_ALL
	button.custom_minimum_size.y = 46
	button.add_theme_font_size_override("font_size", 13 if _compact else 15)
	button.mouse_entered.connect(_focus_control.bind(button))
	_apply_button_style(button, filled, COLOR_ACCENT if filled else COLOR_BORDER)
	return button


func _set_button_enabled(button: Button, enabled: bool) -> void:
	if not is_instance_valid(button):
		return
	button.disabled = not enabled
	button.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE


func _focus_control(control: Control) -> void:
	if not is_instance_valid(control) or not control.is_visible_in_tree() or control.focus_mode == Control.FOCUS_NONE:
		return
	if control is BaseButton and (control as BaseButton).disabled:
		return
	control.grab_focus()


func _safe_grab_focus(control: Control) -> void:
	if not is_instance_valid(control) or not control.is_inside_tree():
		return
	_focus_control(control)


func _apply_button_style(button: Button, filled: bool, border: Color) -> void:
	if not is_instance_valid(button):
		return
	var bg := COLOR_PANEL_ALT if filled else COLOR_PANEL
	button.add_theme_stylebox_override("normal", _panel_style(bg, border, 2 if filled else 1, 6))
	button.add_theme_stylebox_override("hover", _panel_style(bg.lightened(0.06), COLOR_ACCENT, 2, 6))
	button.add_theme_stylebox_override("focus", _panel_style(bg.lightened(0.08), COLOR_ACCENT, 3, 6))
	button.add_theme_stylebox_override("pressed", _panel_style(bg.lightened(0.10), COLOR_ACCENT, 3, 6))
	button.add_theme_stylebox_override("disabled", _panel_style(Color("#0e1217"), Color("#343b45"), 1, 6))
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", COLOR_TEXT)
	button.add_theme_color_override("font_focus_color", COLOR_TEXT)
	button.add_theme_color_override("font_pressed_color", COLOR_TEXT)
	button.add_theme_color_override("font_disabled_color", Color("#737b86"))


func _apply_note_style(button: Button, selected: bool) -> void:
	if not is_instance_valid(button):
		return
	var paper := COLOR_PAPER_FOCUS if selected else COLOR_PAPER
	button.add_theme_stylebox_override(
		"normal", _paper_style(paper, COLOR_ACCENT if selected else COLOR_PAPER_EDGE, 2 if selected else 1, true))
	button.add_theme_stylebox_override(
		"hover", _paper_style(COLOR_PAPER_FOCUS, COLOR_ACCENT, 2, true))
	button.add_theme_stylebox_override(
		"focus", _paper_style(COLOR_PAPER_FOCUS, COLOR_ACCENT, 3, true))
	button.add_theme_stylebox_override(
		"pressed", _paper_style(COLOR_PAPER.darkened(0.05), COLOR_ACCENT, 3, true))
	button.add_theme_stylebox_override(
		"disabled", _paper_style(COLOR_PAPER.darkened(0.20), COLOR_PAPER_EDGE.darkened(0.2), 1, false))
	for color_name in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color"]:
		button.add_theme_color_override(color_name, Color.TRANSPARENT)


func _apply_pocket_style(button: Button, occupied: bool, protected_slot: bool) -> void:
	if not is_instance_valid(button):
		return
	var edge := COLOR_ACCENT if protected_slot else Color("#aaa49a")
	var base := Color("#171611e8") if occupied else Color("#0d0e0fd4")
	button.add_theme_stylebox_override("normal", _panel_style(base, edge.darkened(0.18), 2, 2))
	button.add_theme_stylebox_override("hover", _panel_style(base.lightened(0.05), edge, 2, 2))
	button.add_theme_stylebox_override("focus", _panel_style(base.lightened(0.07), COLOR_ACCENT, 3, 2))
	button.add_theme_stylebox_override("pressed", _panel_style(base.lightened(0.10), COLOR_ACCENT, 3, 2))
	button.add_theme_stylebox_override(
		"disabled", _panel_style(Color("#0b0c0dd0"), Color("#6d6b6680"), 1, 2))
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", COLOR_TEXT)
	button.add_theme_color_override("font_focus_color", COLOR_TEXT)
	button.add_theme_color_override("font_pressed_color", COLOR_TEXT)
	button.add_theme_color_override("font_disabled_color", Color("#9a9b98"))
	button.add_theme_font_size_override("font_size", 13 if _compact else 15)


func _paper_style(
	bg: Color,
	border: Color,
	border_width: int,
	with_shadow: bool,
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(2)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 7
	style.content_margin_bottom = 7
	if with_shadow:
		style.shadow_color = Color("#02030347")
		style.shadow_size = 6
		style.shadow_offset = Vector2(0, 5)
	return style


func _panel_style(bg: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _on_resized() -> void:
	var next_compact := _is_compact_layout()
	if next_compact == _compact or _resize_refresh_queued:
		return
	_compact = next_compact
	_resize_refresh_queued = true
	call_deferred("_apply_responsive_refresh")


func _apply_responsive_refresh() -> void:
	_resize_refresh_queued = false
	_apply_page_margins()
	_refresh_current_screen()


func _apply_page_margins() -> void:
	if not is_instance_valid(_page):
		return
	var horizontal := 14 if _compact else 24
	var vertical := 10 if _compact else 18
	_page.add_theme_constant_override("margin_left", horizontal)
	_page.add_theme_constant_override("margin_right", horizontal)
	_page.add_theme_constant_override("margin_top", vertical)
	_page.add_theme_constant_override("margin_bottom", vertical)


func _is_compact_layout() -> bool:
	return size.x < 1100.0 or size.y < 700.0
