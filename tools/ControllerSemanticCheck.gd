extends Node
## ControllerSemanticCheck — raw trigger edges and full-screen semantic page ownership.

const SUCCESS_MARKER := (
	"CONTROLLER_SEMANTIC_CHECK_OK surfaces=4 major_actions=2 raw_routes=8 "
	+ "trigger_gate=1 reconnect_gate=2 modal_leaks=0 vibration=1")

class MajorProbe extends Node:
	var directions: Array[int] = []

	func _unhandled_input(event: InputEvent) -> void:
		var direction := ControllerHints.major_direction(event)
		if direction == 0:
			return
		directions.append(direction)
		get_viewport().set_input_as_handled()

var _failures: Array[String] = []
var _original_vibration_enabled: bool
var _original_vibration_intensity: float
var _game_state_snapshot: Dictionary
var _pending_story_snapshot: Array
var _story_return_snapshot: String


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	_original_vibration_enabled = AudioManager.vibration_enabled()
	_original_vibration_intensity = AudioManager.vibration_intensity()
	_game_state_snapshot = GameState.serialize().duplicate(true)
	_pending_story_snapshot = GameState.pending_story_queue.duplicate(true)
	_story_return_snapshot = GameState.story_return_scene
	await _check_raw_trigger_gate()
	await _check_start_menu_pages()
	await _check_story_surface()
	await _check_completion_pages()
	await _check_main_game_pages()
	await _restore_state()
	ControllerHints.reset_major_input_state()
	ControllerHints.clear_qa_override()
	if _failures.is_empty():
		print(SUCCESS_MARKER)
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("CONTROLLER_SEMANTIC_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)


func _check_raw_trigger_gate() -> void:
	_expect(InputMap.has_action("gd_major_prev"), "gd_major_prev action is missing")
	_expect(InputMap.has_action("gd_major_next"), "gd_major_next action is missing")
	var probe := MajorProbe.new()
	add_child(probe)
	ControllerHints.reset_major_input_state()
	await _axis_value(JOY_AXIS_TRIGGER_LEFT, 0.60)
	await _axis_value(JOY_AXIS_TRIGGER_LEFT, 0.82)
	await _axis_value(JOY_AXIS_TRIGGER_LEFT, 0.50)
	await _axis_value(JOY_AXIS_TRIGGER_LEFT, 0.58)
	_expect(probe.directions == [-1],
		"held/jittering L2 repeated before release: %s" % [probe.directions])
	await _axis_value(JOY_AXIS_TRIGGER_LEFT, 0.34)
	await _axis_value(JOY_AXIS_TRIGGER_LEFT, 0.56)
	_expect(probe.directions == [-1, -1],
		"L2 did not re-arm after the 0.35 release gate: %s" % [probe.directions])
	await _axis_value(JOY_AXIS_TRIGGER_LEFT, 0.0)
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.56)
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.78)
	_expect(probe.directions == [-1, -1, 1],
		"held R2 repeated before release: %s" % [probe.directions])
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.0)
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.56)
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.0)
	await _press_key(KEY_PAGEUP)
	await _press_key(KEY_PAGEDOWN)
	_expect(probe.directions == [-1, -1, 1, 1, -1, 1],
		"raw trigger/key direction sequence drifted: %s" % [probe.directions])

	# Godot has no synthetic hardware connect InputEvent, so seed the same pure
	# connection state that the callback reads from Input.get_joy_axis(). A held
	# reconnect stays suppressed until release, while a neutral reconnect must
	# not swallow its first intentional press.
	ControllerHints.reset_major_input_state()
	ControllerHints.call("_seed_major_trigger_connection_state", 0, 0.0, 0.82)
	var reconnect_before := probe.directions.duplicate()
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.82)
	_expect(probe.directions == reconnect_before,
		"reconnected held R2 was consumed as a fresh press: %s" % [probe.directions])
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.0)
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.62)
	_expect(probe.directions.size() == reconnect_before.size() + 1 \
			and probe.directions[-1] == 1,
		"reconnected R2 did not route once after release: %s" % [probe.directions])
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.0)
	ControllerHints.reset_major_input_state()
	ControllerHints.call("_seed_major_trigger_connection_state", 0, 0.0, 0.0)
	var neutral_before := probe.directions.size()
	await _axis_value(JOY_AXIS_TRIGGER_LEFT, 0.62)
	_expect(probe.directions.size() == neutral_before + 1 \
			and probe.directions[-1] == -1,
		"neutral reconnect swallowed the first intentional L2 press: %s" \
				% [probe.directions])
	await _axis_value(JOY_AXIS_TRIGGER_LEFT, 0.0)
	probe.queue_free()
	await get_tree().process_frame


func _check_start_menu_pages() -> void:
	var packed := load("res://scenes/StartMenu.tscn") as PackedScene
	_expect(packed != null, "StartMenu scene could not be loaded")
	if packed == null:
		return
	var menu := packed.instantiate() as Control
	add_child(menu)
	await get_tree().process_frame
	menu.call("_dismiss_splash")
	await get_tree().create_timer(0.30).timeout
	menu.call("_open_load_overlay")
	await get_tree().process_frame
	await get_tree().process_frame
	var load_overlay := menu.get("_load_overlay") as Control
	var load_focus := get_viewport().gui_get_focus_owner()
	_expect(is_instance_valid(load_overlay) and is_instance_valid(load_focus) \
			and load_overlay.is_ancestor_of(load_focus),
		"StartMenu load modal left focus on a hidden title control")
	ControllerHints.reset_major_input_state()
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.62)
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.79)
	_expect(int(menu.get("_load_slot_page")) == 1,
		"StartMenu R2 did not move load slots exactly one page")
	load_focus = get_viewport().gui_get_focus_owner()
	_expect(is_instance_valid(load_focus) and load_overlay.is_ancestor_of(load_focus),
		"StartMenu page trigger moved focus behind the load modal")
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.0)
	await _axis_value(JOY_AXIS_TRIGGER_LEFT, 0.62)
	_expect(int(menu.get("_load_slot_page")) == 0,
		"StartMenu L2 did not return to load slots 1-5")
	await _axis_value(JOY_AXIS_TRIGGER_LEFT, 0.0)
	menu.call("_close_load_overlay")
	await get_tree().process_frame

	menu.call("_open_archive_overlay")
	await get_tree().process_frame
	var page_count := int(menu.call("_archive_page_count"))
	_expect(page_count > 1, "archive fixture has no second page")
	ControllerHints.reset_major_input_state()
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.62)
	var archive_page := int(menu.get("_archive_page"))
	_expect(archive_page == 1, "StartMenu R2 did not move the archive one page")
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.84)
	_expect(int(menu.get("_archive_page")) == archive_page,
		"StartMenu held R2 repeated the archive page")
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.0)

	var preview := ColorRect.new()
	preview.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.add_child(preview)
	menu.set("_archive_preview_layer", preview)
	var tab_before := int(menu.get("_archive_tab"))
	var page_before := int(menu.get("_archive_page"))
	await _axis_value(JOY_AXIS_TRIGGER_LEFT, 0.62)
	await _axis_value(JOY_AXIS_TRIGGER_LEFT, 0.0)
	await _press_joy(JOY_BUTTON_RIGHT_SHOULDER)
	_expect(int(menu.get("_archive_page")) == page_before \
			and int(menu.get("_archive_tab")) == tab_before,
		"archive preview leaked trigger/shoulder input to the hidden archive")
	menu.set("_archive_preview_layer", null)
	preview.queue_free()
	await get_tree().process_frame
	menu.call("_close_archive_overlay")
	menu.queue_free()
	await get_tree().process_frame


func _check_story_surface() -> void:
	AudioManager.set_vibration_enabled(true)
	AudioManager.set_vibration_intensity(0.70)
	GameState.start_new_game()
	GameState.pending_story_queue = ["story_prologue_dad"]
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	var packed := load("res://scenes/StoryMode.tscn") as PackedScene
	_expect(packed != null, "StoryMode scene could not be loaded")
	if packed == null:
		return
	var story := packed.instantiate() as Control
	add_child(story)
	await get_tree().process_frame
	await get_tree().process_frame
	await _press_key(KEY_F10)
	var popup := story.get("_audio_settings_popup") as Control
	_expect(is_instance_valid(popup), "Story Menu did not open scene settings")
	var vibration_toggle := story.get("_audio_vibration_toggle") as CheckButton
	var vibration_slider := story.get("_audio_vibration_slider") as HSlider
	_expect(is_instance_valid(vibration_toggle) and is_instance_valid(vibration_slider),
		"Story settings omitted vibration toggle/strength")
	if is_instance_valid(vibration_toggle) and is_instance_valid(vibration_slider):
		var stop_serial_before_off := int(AudioManager.get("_vibration_stop_serial"))
		vibration_toggle.grab_focus()
		await get_tree().process_frame
		await _press_key(KEY_ENTER)
		_expect(not AudioManager.vibration_enabled() \
				and vibration_slider.focus_mode == Control.FOCUS_NONE,
			"raw Confirm did not disable Story vibration and skip its strength")
		_expect(int(AudioManager.get("_vibration_stop_serial")) \
				== stop_serial_before_off + 1,
			"Story vibration off did not stop an active pulse immediately")
		await _press_key(KEY_ENTER)
		_expect(AudioManager.vibration_enabled() \
				and vibration_slider.focus_mode == Control.FOCUS_ALL,
			"raw Confirm did not restore Story vibration strength")
		vibration_slider.grab_focus()
		await get_tree().process_frame
		var stop_serial_before_zero := int(AudioManager.get("_vibration_stop_serial"))
		for _step in range(7):
			await _press_key(KEY_LEFT)
		_expect(is_zero_approx(AudioManager.vibration_intensity()) \
				and AudioManager.vibration_profile(0.5, 0.8) == Vector2.ZERO,
			"raw slider input did not preserve Story vibration 0% silence")
		_expect(int(AudioManager.get("_vibration_stop_serial")) \
				== stop_serial_before_zero + 1,
			"Story vibration 0% did not stop an active pulse immediately")
	story.call("_open_story_save_load")
	await get_tree().process_frame
	ControllerHints.reset_major_input_state()
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.62)
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.81)
	_expect(int(story.get("_story_save_page")) == 1,
		"Story R2 did not move save slots exactly one page")
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.0)
	await _axis_value(JOY_AXIS_TRIGGER_LEFT, 0.62)
	_expect(int(story.get("_story_save_page")) == 0,
		"Story L2 did not return to save slots 1-5")
	await _axis_value(JOY_AXIS_TRIGGER_LEFT, 0.0)
	await _press_key(KEY_ESCAPE)
	_expect(not is_instance_valid(story.get("_audio_settings_popup")),
		"Story East did not close the save/settings modal")

	story.set("_typing", false)
	story.set("_auto_mode", false)
	var paragraph_before := int(story.get("_para_index"))
	ControllerHints.reset_major_input_state()
	await _axis_pulse(JOY_AXIS_TRIGGER_RIGHT)
	_expect(int(story.get("_para_index")) == paragraph_before,
		"Story prose treated R2 as advance/commit")
	await _press_key(KEY_X)
	_expect(is_instance_valid(story.get("_dialogue_log_popup")),
		"Story West no longer opens the dialogue log")
	await _press_key(KEY_X)
	await _press_joy(JOY_BUTTON_Y)
	_expect(bool(story.get("_auto_mode")), "Story North no longer toggles AUTO")
	await _press_key(KEY_F10)
	_expect(is_instance_valid(story.get("_audio_settings_popup")),
		"Story Menu no longer opens settings after other semantic inputs")
	story.call("_close_audio_settings")
	story.queue_free()
	await get_tree().process_frame


func _check_completion_pages() -> void:
	var completion := CoreLoopV2Completion.new()
	add_child(completion)
	await get_tree().process_frame
	var months: Array = []
	for month in range(1, 7):
		months.append({
			"month": month,
			"title": "Month %d" % month,
			"allocations": ["A", "B", "C", "D"],
			"outcomes": ["Outcome"],
			"missed": [],
			"events": [],
		})
	var model := {
		"title": "24 Weeks",
		"intro": "QA",
		"hero_title": "QA",
		"hero_body": "QA",
		"initiative": "",
		"boundary": "QA",
		"autosave_ok": true,
		"outcome_rows": [{"kind": "kept", "label": "Kept", "values": ["QA"]}],
		"metrics": [{"label": "Cash", "value": "1", "note": "QA", "accent": "#ffffff"}],
		"traces": [],
		"months": months,
		"unresolved": ["QA"],
	}
	_expect(completion.open(model), "completion fixture did not open")
	await get_tree().process_frame
	await _press_joy(JOY_BUTTON_Y)
	_expect(completion.details_visible() and completion.current_page() == 1,
		"completion North did not open the month ledger")
	ControllerHints.reset_major_input_state()
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.62)
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.84)
	_expect(completion.current_page() == 2,
		"completion held R2 did not produce exactly one page step")
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.0)
	await _press_joy(JOY_BUTTON_RIGHT_SHOULDER)
	_expect(completion.current_page() == 2,
		"completion RB still owns ledger page navigation")
	await _axis_pulse(JOY_AXIS_TRIGGER_LEFT)
	_expect(completion.current_page() == 1, "completion L2 did not move to the previous page")
	await _press_joy(JOY_BUTTON_B)
	var finish_count := {"value": 0}
	completion.finish_requested.connect(func(): finish_count["value"] += 1)
	await _axis_pulse(JOY_AXIS_TRIGGER_RIGHT)
	_expect(completion.summary_visible() and int(finish_count["value"]) == 0,
		"completion summary trigger finished/exited the demo")
	completion.queue_free()
	await get_tree().process_frame


func _check_main_game_pages() -> void:
	GameState.start_new_game()
	GameState.flags["prologue_done"] = true
	GameState.flags["tutorial_shown"] = true
	var packed := load("res://scenes/MainGame.tscn") as PackedScene
	_expect(packed != null, "MainGame scene could not be loaded")
	if packed == null:
		return
	var main := packed.instantiate() as Control
	main.set_meta("_screenshot_qa_static_surface", true)
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame
	main.call("_open_system_menu")
	await get_tree().process_frame
	var vibration_toggle := _find_meta_control(main, "vibration_control") as CheckButton
	var vibration_slider := _find_meta_control(
		main, "vibration_intensity_control") as HSlider
	_expect(is_instance_valid(vibration_toggle) and is_instance_valid(vibration_slider),
		"MainGame system settings omitted vibration controls")
	if is_instance_valid(vibration_toggle) and is_instance_valid(vibration_slider):
		if not vibration_toggle.button_pressed:
			vibration_toggle.button_pressed = true
			vibration_toggle.toggled.emit(true)
		vibration_toggle.grab_focus()
		await get_tree().process_frame
		await _press_key(KEY_ENTER)
		_expect(not AudioManager.vibration_enabled() \
				and vibration_slider.focus_mode == Control.FOCUS_NONE,
			"MainGame vibration off left its strength in the focus rail")
		await _press_key(KEY_ENTER)
		_expect(AudioManager.vibration_enabled() \
				and vibration_slider.focus_mode == Control.FOCUS_ALL,
			"MainGame vibration on did not restore its strength control")
	ControllerHints.reset_major_input_state()
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.62)
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.80)
	_expect(int(main.get("_save_load_page_idx")) == 1,
		"MainGame held R2 did not move save slots exactly one page")
	var system_save_list := main.get("_save_load_slot_list") as Control
	var system_focus := get_viewport().gui_get_focus_owner()
	_expect(is_instance_valid(system_save_list) and is_instance_valid(system_focus) \
			and system_save_list.is_ancestor_of(system_focus),
		"MainGame page trigger focused an unrelated system action: %s" % [
			system_focus.get_path() if is_instance_valid(system_focus) else "<none>"])
	await _axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.0)
	await _axis_pulse(JOY_AXIS_TRIGGER_LEFT)
	_expect(int(main.get("_save_load_page_idx")) == 0,
		"MainGame L2 did not return to save slots 1-5")
	main.call("_close_modal")
	await get_tree().process_frame

	main.set("_ending_id", "ordinary_life")
	main.set("_ending_data", {"title": "QA Ending", "grade": "C"})
	main.set("_ending_finale_beats", ["QA ending beat"])
	main.set("_ending_finale_beat_index", 0)
	main.call("_open_modal", "", false, "ending")
	main.call("_ending_show_page", 0)
	await get_tree().process_frame
	ControllerHints.reset_major_input_state()
	await _axis_pulse(JOY_AXIS_TRIGGER_RIGHT)
	_expect(int(main.get("_ending_page_index")) == 1,
		"MainGame R2 did not advance the ending sequentially")
	await _axis_pulse(JOY_AXIS_TRIGGER_LEFT)
	_expect(int(main.get("_ending_page_index")) == 0,
		"MainGame L2 did not return to the ending finale")
	GameState.flags["final_signature_people"] = true
	main.call("_ending_show_page", 2)
	await get_tree().process_frame
	var people_page := _find_meta_value_control(
		main, "qa_surface", "ending_people")
	_expect(is_instance_valid(people_page),
		"MainGame people page did not expose its semantic surface")
	if is_instance_valid(people_page):
		var coda_count := 0
		var coda_index := -1
		var cast_grid_index := -1
		var coda_text := ""
		for child_index in range(people_page.get_child_count()):
			var child := people_page.get_child(child_index)
			if child.has_meta("ending_signature_coda"):
				coda_count += 1
				coda_index = child_index
				coda_text = _visible_control_text(child)
			if child is GridContainer:
				cast_grid_index = child_index
		_expect(coda_count == 1 \
				and coda_index >= 0 \
				and cast_grid_index > coda_index,
			"MainGame signature coda was not the single first card before the cast grid")
		if coda_index >= 0:
			_expect(str(people_page.get_child(coda_index).get_meta(
					"ending_signature_coda", "")) == "people",
				"MainGame signature coda lost its stable people kind")
		_expect("final_signature" not in coda_text,
			"MainGame signature coda leaked its internal flag name")
	main.call("_ending_show_page", 5)
	await get_tree().process_frame
	await _axis_pulse(JOY_AXIS_TRIGGER_RIGHT)
	_expect(int(main.get("_ending_page_index")) == 5 \
			and main.get("modal_layer").visible,
		"MainGame final ending page let R2 restart/exit/commit")
	main.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


func _axis_value(axis: JoyAxis, value: float) -> void:
	var event := InputEventJoypadMotion.new()
	event.device = 0
	event.axis = axis
	event.axis_value = value
	Input.parse_input_event(event)
	await get_tree().process_frame


func _find_meta_control(root: Node, key: String) -> Control:
	if root is Control and bool((root as Control).get_meta(key, false)):
		return root as Control
	for child in root.get_children():
		var found := _find_meta_control(child, key)
		if found != null:
			return found
	return null


func _find_meta_value_control(root: Node, key: String, value: Variant) -> Control:
	if root is Control and root.has_meta(key) and root.get_meta(key) == value:
		return root as Control
	for child in root.get_children():
		var found := _find_meta_value_control(child, key, value)
		if found != null:
			return found
	return null


func _visible_control_text(root: Node) -> String:
	var parts: PackedStringArray = []
	if root is Label:
		parts.append((root as Label).text)
	elif root is RichTextLabel:
		parts.append((root as RichTextLabel).text)
	for child in root.get_children():
		parts.append(_visible_control_text(child))
	return "\n".join(parts)


func _axis_pulse(axis: JoyAxis) -> void:
	await _axis_value(axis, 0.62)
	await _axis_value(axis, 0.0)


func _press_key(keycode: Key) -> void:
	var press := InputEventKey.new()
	press.keycode = keycode
	press.physical_keycode = keycode
	press.pressed = true
	Input.parse_input_event(press)
	await get_tree().process_frame
	var release := press.duplicate() as InputEventKey
	release.pressed = false
	Input.parse_input_event(release)
	await get_tree().process_frame


func _press_joy(button_index: JoyButton) -> void:
	var press := InputEventJoypadButton.new()
	press.device = 0
	press.button_index = button_index
	press.pressed = true
	press.pressure = 1.0
	Input.parse_input_event(press)
	await get_tree().process_frame
	var release := press.duplicate() as InputEventJoypadButton
	release.pressed = false
	release.pressure = 0.0
	Input.parse_input_event(release)
	await get_tree().process_frame


func _restore_state() -> void:
	# Menu open/close sounds can still own playback resources when the short
	# headless route quits. Stop only the shared QA SFX pool before teardown so
	# the strict audit cannot hide a late resource error behind the OK marker.
	for player: AudioStreamPlayer in AudioManager._pool:
		player.stop()
		player.stream = null
	AudioManager.set_vibration_intensity(_original_vibration_intensity)
	AudioManager.set_vibration_enabled(_original_vibration_enabled)
	GameState.load_from_dict(_game_state_snapshot)
	GameState.pending_story_queue = _pending_story_snapshot.duplicate(true)
	GameState.story_return_scene = _story_return_snapshot
	BGMPlayer.update_idle_ambience()
	await get_tree().create_timer(0.20).timeout


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
