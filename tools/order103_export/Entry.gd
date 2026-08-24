extends Control
## Staging-only entry for the ORDER-103 native macOS candidate.

const PROFILE := "order103_m1m6_playtest"
const BUILD_ID := "2026.08.24.1"
const BUILD_FLAVOR := "story_map_m1m6_playtest"
const SAVE_NAMESPACE := "story_map_m1m6_playtest_v1"
const SAVE_SCHEMA := 1
const MAIN_SCENE := "res://tools/StoryMapM1M6Playtest.tscn"
const AUTOSAVE_PATH := "user://story_map_m1m6_playtest_autosave.json"
const PLAYTEST_SCENE := preload(MAIN_SCENE)

var _playtest: Control
var _marker: PanelContainer
var _failures: Array[String] = []


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ensure_candidate_gamepad_map()
	get_window().title = "Gangnam Dream · ORDER-103 · M01–M06 · BUILD %s" % BUILD_ID
	_mount_playtest()
	_build_marker()
	var native_marker := "ORDER103_NATIVE_ENTRY_OK profile=%s build=%s scene=%s custom_user_dir=%s path=%s" % [
		PROFILE,
		BUILD_ID,
		MAIN_SCENE,
		"GangnamDream_ORDER103_M01M06_v1",
		OS.get_user_data_dir(),
	]
	print(native_marker)
	var native_probe_path := OS.get_environment("ORDER103_NATIVE_PROBE_PATH")
	if native_probe_path.is_absolute_path():
		var probe := FileAccess.open(native_probe_path, FileAccess.WRITE)
		if probe != null:
			probe.store_line(native_marker)
	var args := OS.get_cmdline_user_args()
	if args.has("--order103-smoke"):
		call_deferred("_run_package_smoke")
	else:
		var screenshot_path := _argument_value(args, "--order103-screenshot=")
		if not screenshot_path.is_empty():
			call_deferred("_capture_home", screenshot_path, args.has("--order103-screenshot-exit"))


func _mount_playtest() -> void:
	_playtest = PLAYTEST_SCENE.instantiate() as Control
	if _playtest == null:
		_fail("could not instantiate %s" % MAIN_SCENE)
		return
	_playtest.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_playtest)


func _remount_playtest() -> void:
	if is_instance_valid(_playtest):
		remove_child(_playtest)
		_playtest.free()
	_mount_playtest()


func _build_marker() -> void:
	_marker = PanelContainer.new()
	_marker.name = "Order103BuildMarker"
	_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_marker.z_index = 100
	_marker.anchor_left = 1.0
	_marker.anchor_top = 1.0
	_marker.anchor_right = 1.0
	_marker.anchor_bottom = 1.0
	_marker.offset_left = -310.0
	_marker.offset_top = -31.0
	_marker.offset_right = -8.0
	_marker.offset_bottom = -7.0
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.03, 0.03, 0.05, 0.82)
	panel.border_color = Color(UIStyle.C_BORDER_ACCENT, 0.84)
	panel.set_border_width_all(1)
	panel.set_corner_radius_all(4)
	panel.content_margin_left = 8
	panel.content_margin_right = 8
	panel.content_margin_top = 2
	panel.content_margin_bottom = 2
	_marker.add_theme_stylebox_override("panel", panel)
	var label := Label.new()
	label.text = "ORDER-103 · M01–M06 · BUILD %s" % BUILD_ID
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.add_theme_color_override("font_color", Color(UIStyle.C_TEXT_SECONDARY))
	label.add_theme_font_size_override("font_size", 11)
	if UIStyle.font_semibold != null:
		label.add_theme_font_override("font", UIStyle.font_semibold)
	_marker.add_child(label)
	add_child(_marker)


func _run_package_smoke() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var args := OS.get_cmdline_user_args()
	var language := _argument_value(args, "--order103-language=")
	if language.is_empty():
		language = "ko"
	_expect(language in ["ko", "en"], "invalid smoke language %s" % language)
	_expect(is_instance_valid(_playtest), "playtest instance missing")
	if not is_instance_valid(_playtest):
		_finish_smoke(language)
		return
	_expect(_playtest.has_meta("story_map_m1m6_playtest"), "wrong no-arg root scene")
	_expect(str(_playtest.call("qa_screen")) == "home", "candidate did not open on dedicated home")
	_expect(str(_playtest.call("qa_autosave_path")) == AUTOSAVE_PATH, "autosave path drifted")
	_expect(bool(_playtest.call("qa_start_new_run")), "could not start run")
	await get_tree().process_frame
	_expect(bool(_playtest.call("qa_set_language", language)), "could not set language")
	var first_snapshot: Dictionary = _playtest.call("qa_snapshot")
	var initial_selection: Dictionary = first_snapshot.get("selection", {})
	_expect(str(initial_selection.get("protected", "")).is_empty(), "run auto-assigned protected role")
	_expect(str(initial_selection.get("optional_second", "")).is_empty(), "run auto-assigned alongside role")
	var cards: Array = first_snapshot.get("cards", [])
	_expect(not cards.is_empty(), "M01 has no cards")
	if not cards.is_empty():
		var first_id := str((cards[0] as Dictionary).get("id", ""))
		var first_note := _find_button_with_meta(_playtest, "m1m6_commitment_id", first_id)
		_expect(is_instance_valid(first_note), "M01 semantic note is missing")
		if is_instance_valid(first_note):
			first_note.emit_signal("mouse_entered")
			await get_tree().process_frame
			_expect(first_note.has_focus(), "mouse hover did not focus note")
			_parse_key(KEY_ENTER, true)
			await get_tree().process_frame
			_parse_key(KEY_ENTER, false)
			await get_tree().process_frame
			var after_first: Dictionary = _playtest.call("qa_snapshot")
			_expect(after_first.get("selection", {}) == initial_selection,
				"keyboard first confirm auto-assigned a role")
			var focus_contract: Dictionary = _playtest.call("qa_visual_contract")
			_expect(str(focus_contract.get("focus_role_slot", "")) == "protected",
				"keyboard first confirm did not move to protected pocket")
			_parse_joy_south(true)
			await get_tree().process_frame
			_parse_joy_south(false)
			await get_tree().process_frame
		var assigned: Dictionary = _playtest.call("qa_snapshot")
		_expect(str((assigned.get("selection", {}) as Dictionary).get("protected", "")) == first_id,
			"gamepad second confirm could not assign protected role")
	_check_selection_geometry(1)
	var first_result: Dictionary = _playtest.call("qa_commit_month")
	_expect(not first_result.is_empty(), "could not commit M01")
	_expect(bool(_playtest.call("qa_advance")), "could not advance to M02")
	_expect(int((_playtest.call("qa_snapshot") as Dictionary).get("month", 0)) == 2,
		"M01 did not advance to M02")
	_remount_playtest()
	await get_tree().process_frame
	_expect(bool(_playtest.call("qa_continue_run")), "M02 save did not resume")
	_expect(bool(_playtest.call("qa_set_language", language)), "M02 resume language drifted")
	_expect(str(_playtest.call("qa_screen")) == "selection", "M02 resume did not open selection")
	_expect(int((_playtest.call("qa_snapshot") as Dictionary).get("month", 0)) == 2,
		"resume did not restore M02")
	await get_tree().process_frame

	for month in range(2, 7):
		await get_tree().process_frame
		_expect(bool(_playtest.call("qa_set_language", language)),
			"language drifted at M%02d" % month)
		await get_tree().process_frame
		_check_selection_geometry(month)
		var snapshot: Dictionary = _playtest.call("qa_snapshot")
		var month_cards: Array = snapshot.get("cards", [])
		_expect(not month_cards.is_empty(), "M%02d has no cards" % month)
		if month_cards.is_empty():
			break
		var commitment_id := str((month_cards[0] as Dictionary).get("id", ""))
		_expect(bool(_playtest.call("qa_set_role", "protected", commitment_id)),
			"M%02d could not assign protected role" % month)
		var result: Dictionary = _playtest.call("qa_commit_month")
		_expect(not result.is_empty(), "M%02d could not commit" % month)
		_expect(bool(_playtest.call("qa_advance")), "M%02d could not advance" % month)
		await get_tree().process_frame

	_expect(str(_playtest.call("qa_screen")) == "recap", "M06 did not open recap")
	_remount_playtest()
	await get_tree().process_frame
	_expect(bool(_playtest.call("qa_continue_run")), "finished save did not resume")
	_expect(bool(_playtest.call("qa_set_language", language)), "recap resume language drifted")
	_expect(str(_playtest.call("qa_screen")) == "recap", "finished resume did not restore recap")
	var save_jsons := _user_json_files()
	_expect(save_jsons == [AUTOSAVE_PATH.get_file()],
		"dedicated user dir contains unexpected save JSON: %s" % [save_jsons])
	_finish_smoke(language)


func _check_selection_geometry(month: int) -> void:
	var contract: Dictionary = _playtest.call("qa_visual_contract")
	_expect(int(contract.get("scroll_containers", -1)) == 0,
		"M%02d introduced internal scroll" % month)
	_expect(bool(contract.get("confirm_present", false)),
		"M%02d lost commit control" % month)
	var viewport := _vector2_from_array(contract.get("viewport_size", []))
	var rects: Array[Rect2] = []
	for value in (contract.get("note_rects", {}) as Dictionary).values():
		rects.append(_rect2_from_array(value))
	for value in (contract.get("role_rects", {}) as Dictionary).values():
		rects.append(_rect2_from_array(value))
	rects.append(_rect2_from_array(contract.get("confirm_rect", [])))
	for rect in rects:
		_expect(_rect_inside(rect, viewport), "M%02d control clipped" % month)
	for left in range(rects.size()):
		for right in range(left + 1, rects.size()):
			_expect(not rects[left].intersects(rects[right]),
				"M%02d controls overlap" % month)


func _finish_smoke(language: String) -> void:
	var save_absolute := ProjectSettings.globalize_path(AUTOSAVE_PATH)
	if FileAccess.file_exists(save_absolute):
		DirAccess.remove_absolute(save_absolute)
	var remaining_jsons := _user_json_files()
	_expect(remaining_jsons.is_empty(),
		"dedicated user dir retained save JSON after smoke: %s" % [remaining_jsons])
	if _failures.is_empty():
		var window_size := DisplayServer.window_get_size()
		print("ORDER103_WRAPPER_SMOKE_OK language=%s size=%dx%d save_resume=m02,recap clips=0 scroll=0 auto_assign=0" % [
			language,
			window_size.x,
			window_size.y,
		])
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("ORDER103_WRAPPER_SMOKE: %s" % failure)
	get_tree().quit(1)


func _capture_home(path: String, exit_after: bool) -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png(path)
	if error == OK:
		print("ORDER103_SCREENSHOT_OK path=%s" % path)
	else:
		push_error("ORDER103_SCREENSHOT_FAIL path=%s error=%d" % [path, error])
	if exit_after:
		get_tree().quit(0 if error == OK else 1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)


func _fail(message: String) -> void:
	if not message in _failures:
		_failures.append(message)


func _argument_value(args: PackedStringArray, prefix: String) -> String:
	for arg in args:
		if arg.begins_with(prefix):
			return arg.trim_prefix(prefix)
	return ""


func _find_button_with_meta(node: Node, key: StringName, value: String) -> Button:
	if node is Button and node.has_meta(key) and str(node.get_meta(key)) == value:
		return node as Button
	for child in node.get_children():
		var found := _find_button_with_meta(child, key, value)
		if is_instance_valid(found):
			return found
	return null


func _parse_key(keycode: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	event.pressed = pressed
	Input.parse_input_event(event)


func _parse_joy_south(pressed: bool) -> void:
	_expect(_action_has_joy_button(&"ui_accept", JOY_BUTTON_A),
		"ui_accept lost the gamepad south-button mapping")
	_expect(_action_has_joy_button(&"ui_cancel", JOY_BUTTON_B),
		"ui_cancel lost the gamepad east-button mapping")
	for mapping in [
		[&"ui_up", JOY_BUTTON_DPAD_UP],
		[&"ui_down", JOY_BUTTON_DPAD_DOWN],
		[&"ui_left", JOY_BUTTON_DPAD_LEFT],
		[&"ui_right", JOY_BUTTON_DPAD_RIGHT],
	]:
		_expect(_action_has_joy_button(mapping[0], mapping[1]),
			"%s lost its D-pad mapping" % mapping[0])
	var event := InputEventAction.new()
	event.action = &"ui_accept"
	event.device = 42
	event.pressed = pressed
	event.strength = 1.0 if pressed else 0.0
	Input.parse_input_event(event)


func _action_has_joy_button(action: StringName, button_index: JoyButton) -> bool:
	for mapped in InputMap.action_get_events(action):
		if mapped is InputEventJoypadButton \
				and (mapped as InputEventJoypadButton).button_index == button_index:
			return true
	return false


func _ensure_candidate_gamepad_map() -> void:
	for mapping in [
		[&"ui_accept", JOY_BUTTON_A],
		[&"ui_cancel", JOY_BUTTON_B],
		[&"ui_up", JOY_BUTTON_DPAD_UP],
		[&"ui_down", JOY_BUTTON_DPAD_DOWN],
		[&"ui_left", JOY_BUTTON_DPAD_LEFT],
		[&"ui_right", JOY_BUTTON_DPAD_RIGHT],
	]:
		var action: StringName = mapping[0]
		var button_index: JoyButton = mapping[1]
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		if _action_has_joy_button(action, button_index):
			continue
		var event := InputEventJoypadButton.new()
		event.device = -1
		event.button_index = button_index
		InputMap.action_add_event(action, event)


func _user_json_files() -> Array[String]:
	var result: Array[String] = []
	_collect_json_files(ProjectSettings.globalize_path("user://"), "", result)
	result.sort()
	return result


func _collect_json_files(directory_path: String, prefix: String, result: Array[String]) -> void:
	var directory := DirAccess.open(directory_path)
	if directory == null:
		return
	directory.list_dir_begin()
	var name := directory.get_next()
	while not name.is_empty():
		if name not in [".", ".."]:
			var relative := prefix.path_join(name) if not prefix.is_empty() else name
			if directory.current_is_dir():
				_collect_json_files(directory_path.path_join(name), relative, result)
			elif name.to_lower().ends_with(".json"):
				result.append(relative)
		name = directory.get_next()
	directory.list_dir_end()


func _vector2_from_array(value: Variant) -> Vector2:
	if not value is Array or (value as Array).size() != 2:
		return Vector2.ZERO
	return Vector2(float((value as Array)[0]), float((value as Array)[1]))


func _rect2_from_array(value: Variant) -> Rect2:
	if not value is Array or (value as Array).size() != 4:
		return Rect2()
	return Rect2(
		float((value as Array)[0]),
		float((value as Array)[1]),
		float((value as Array)[2]),
		float((value as Array)[3]),
	)


func _rect_inside(rect: Rect2, viewport: Vector2) -> bool:
	return rect.size.x >= 40.0 and rect.size.y >= 40.0 \
		and rect.position.x >= -0.5 and rect.position.y >= -0.5 \
		and rect.end.x <= viewport.x + 0.5 and rect.end.y <= viewport.y + 0.5
