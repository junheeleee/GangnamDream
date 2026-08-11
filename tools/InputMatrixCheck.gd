extends Node
## InputMatrixCheck — release-facing display, accessibility, glyph, and input contract.

const STEAM_ACTIONS_PATH := "res://steam_input/game_actions_gangnam_dream.vdf"
const DIRECT_INPUT_SCENES: Array[String] = [
	"res://scenes/BlackjackTable.gd",
	"res://scenes/BaccaratTable.gd",
	"res://scenes/SlotMachineGame.gd",
	"res://scenes/RouletteTable.gd",
	"res://scenes/BigWheelGame.gd",
	"res://scenes/DaiSaiTable.gd",
	"res://scenes/HoldemClub.gd",
	"res://scenes/RaceTrack.gd",
	"res://scenes/JeongseonCasino.gd",
]
const DIRECT_INPUT_CASES: Array[Dictionary] = [
	{"path": "res://scenes/BlackjackTable.gd", "state": "_stake"},
	{"path": "res://scenes/BaccaratTable.gd", "state": "_active_stake"},
	{"path": "res://scenes/SlotMachineGame.gd", "state": "_active_stake"},
	{"path": "res://scenes/RouletteTable.gd", "state": "_stake"},
	{"path": "res://scenes/BigWheelGame.gd", "state": "_stake"},
	{"path": "res://scenes/DaiSaiTable.gd", "state": "_stake"},
	{"path": "res://scenes/HoldemClub.gd", "state": "_buy_in"},
	{"path": "res://scenes/RaceTrack.gd", "state": "_pad_stake_idx"},
	{"path": "res://scenes/JeongseonCasino.gd", "state": "_glossary_overlay"},
]
const MAJOR_INPUT_CASES: Array[Dictionary] = [
	{"path": "res://scenes/BlackjackTable.gd", "tutorial": "blackjack", "state": "_stake", "options": "STAKE_OPTIONS", "counter": "_rounds"},
	{"path": "res://scenes/BaccaratTable.gd", "tutorial": "baccarat", "state": "_active_stake", "options": "STAKE_OPTIONS", "counter": "_rounds"},
	{"path": "res://scenes/SlotMachineGame.gd", "tutorial": "slot", "state": "_active_stake", "options": "STAKE_OPTIONS", "counter": "_rounds"},
	{"path": "res://scenes/RouletteTable.gd", "tutorial": "roulette", "state": "_stake", "options": "STAKE_OPTIONS", "counter": "_rounds"},
	{"path": "res://scenes/BigWheelGame.gd", "tutorial": "bigwheel", "state": "_stake", "options": "STAKE_OPTIONS", "counter": "_rounds"},
	{"path": "res://scenes/DaiSaiTable.gd", "tutorial": "daisai", "state": "_stake", "options": "STAKE_OPTIONS", "counter": "_rounds"},
	{"path": "res://scenes/HoldemClub.gd", "tutorial": "holdem", "state": "_buy_in", "options": "VALID_BUYINS", "counter": "_hands_played"},
	{"path": "res://scenes/RaceTrack.gd", "tutorial": "racetrack", "state": "_pad_stake_idx", "options": "STAKE_OPTIONS", "counter": "_completed_races", "index_state": true},
]

var _failures: Array[String] = []
var _original_vibration_enabled: bool
var _original_vibration_intensity: float

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	_original_vibration_enabled = AudioManager.vibration_enabled()
	_original_vibration_intensity = AudioManager.vibration_intensity()
	_check_display_contract()
	_check_controller_glyphs()
	_check_input_actions()
	_check_accessibility_and_haptics()
	await _check_settings_surface()
	await _check_story_vibration_settings()
	_check_direct_input_scenes()
	await _check_direct_input_runtime()
	await _check_major_stake_routes()
	await _check_minigame_keyboard_tasks()
	_check_steam_input_template()
	_restore_settings()
	ControllerHints.clear_qa_override()
	if _failures.is_empty():
		print("INPUT_MATRIX_CHECK_OK modes=3 resolutions=8 brands=3 direct_scenes=9 direct_routes=18 major_routes=8 modal_routes=8 boundary_routes=16 invalid_routes=8 keyboard_tasks=10 action_sets=4")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("INPUT_MATRIX_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)

func _check_display_contract() -> void:
	_expect(DisplayManager.WINDOW_MODES == ["windowed", "borderless", "fullscreen"],
		"display modes are not windowed/borderless/fullscreen")
	var expected: Array[Vector2i] = [
		Vector2i(960, 600), Vector2i(1280, 720), Vector2i(1280, 800),
		Vector2i(1600, 900), Vector2i(1920, 1080), Vector2i(2560, 1440),
		Vector2i(3440, 1440), Vector2i(3840, 2160),
	]
	_expect(DisplayManager.WINDOW_RESOLUTIONS.size() == expected.size(), "window resolution count changed")
	for index in range(expected.size()):
		_expect(DisplayManager.WINDOW_RESOLUTIONS[index] == expected[index],
			"window resolution %d changed" % index)
	_expect(DisplayManager.has_method("set_window_mode_index"), "display mode selector API missing")
	_expect(DisplayManager.has_method("set_resolution_index"), "resolution selector API missing")
	var snapshot := DisplayManager.settings_snapshot()
	for key in ["window_mode", "fullscreen", "width", "height"]:
		_expect(snapshot.has(key), "display snapshot missing %s" % key)
	var safe := DisplayManager.tv_safe_rect(Vector2(1920, 1080))
	_expect(safe.position.x >= 16.0 and safe.position.y >= 16.0,
		"TV safe area has no protected edge")
	_expect(safe.end.x < 1920.0 and safe.end.y < 1080.0,
		"TV safe area reaches the physical edge")

func _check_controller_glyphs() -> void:
	var cases: Array = [
		[ControllerHints.Brand.XBOX, ["A", "B", "X", "Y", "RB", "Menu", "LB", "LT", "RT"]],
		[ControllerHints.Brand.PLAYSTATION, ["✕", "○", "□", "△", "R1", "Options", "L1", "L2", "R2"]],
		[ControllerHints.Brand.NINTENDO, ["B", "A", "Y", "X", "R", "+", "L", "ZL", "ZR"]],
	]
	for data in cases:
		ControllerHints.force_brand_for_qa(data[0])
		var actual: Array[String] = [
			ControllerHints.south(), ControllerHints.east(), ControllerHints.west(),
			ControllerHints.north(), ControllerHints.shoulder_r(),
			ControllerHints.start_btn(), ControllerHints.shoulder_l(),
			ControllerHints.trigger_l(), ControllerHints.trigger_r(),
		]
		_expect(actual == data[1], "%s glyph layout is %s" % [ControllerHints.brand_name(), actual])
	_expect(ControllerHints.brand_from_device_name("DualSense Wireless Controller") \
		== ControllerHints.Brand.PLAYSTATION, "DualSense detection failed")
	_expect(ControllerHints.brand_from_device_name("Nintendo Switch Pro Controller") \
		== ControllerHints.Brand.NINTENDO, "Switch Pro detection failed")
	_expect(ControllerHints.brand_from_device_name("Steam Deck") \
		== ControllerHints.Brand.XBOX, "Steam Deck physical layout detection failed")
	ControllerHints.clear_qa_override()
	if Input.get_connected_joypads().is_empty():
		_expect(ControllerHints.trigger_l() == "PageUp" \
				and ControllerHints.trigger_r() == "PageDown",
			"keyboard trigger hints do not match PageUp/PageDown")

func _check_input_actions() -> void:
	for action in [
		"ui_accept", "ui_cancel", "ui_up", "ui_down", "ui_left", "ui_right",
		"gd_next_month", "gd_menu", "gd_tab_next", "gd_tab_prev",
		"gd_major_prev", "gd_major_next", "gd_secondary", "gd_details",
	]:
		_expect(InputMap.has_action(action), "InputMap action missing: %s" % action)
	var keyboard_contract := {
		"gd_tab_prev": KEY_Q,
		"gd_tab_next": KEY_E,
		"gd_major_prev": KEY_PAGEUP,
		"gd_major_next": KEY_PAGEDOWN,
		"gd_secondary": KEY_X,
		"gd_details": KEY_Y,
		"gd_menu": KEY_F10,
		"gd_next_month": KEY_N,
	}
	for action_name in keyboard_contract:
		var expected_key := int(keyboard_contract[action_name])
		var found := false
		for mapped_event in InputMap.action_get_events(action_name):
			if mapped_event is InputEventKey:
				var mapped_key := mapped_event as InputEventKey
				if int(mapped_key.keycode) == expected_key \
						or int(mapped_key.physical_keycode) == expected_key:
					found = true
					break
		_expect(found, "%s has no keyboard binding for %s" % [
			action_name, OS.get_keycode_string(expected_key)])
	var trigger_contract := {
		"gd_major_prev": JOY_AXIS_TRIGGER_LEFT,
		"gd_major_next": JOY_AXIS_TRIGGER_RIGHT,
	}
	for action_name in trigger_contract:
		var expected_axis := int(trigger_contract[action_name])
		var found_axis := false
		for mapped_event in InputMap.action_get_events(action_name):
			if mapped_event is InputEventJoypadMotion:
				var motion := mapped_event as InputEventJoypadMotion
				if int(motion.axis) == expected_axis and motion.axis_value > 0.0:
					found_axis = true
					break
		_expect(found_axis, "%s has no physical trigger-axis binding" % action_name)
		_expect(is_equal_approx(InputMap.action_get_deadzone(action_name), 0.55),
			"%s trigger threshold is not 0.55" % action_name)

func _check_accessibility_and_haptics() -> void:
	var reduced := LivingSceneLayer.build_profile(
		{"id": "kx_monsoon", "background": "street_rainy"},
		"street_rainy", "", {"channel": "in_person", "portrait_role": "present"},
		0.0, false, true)
	_expect(str(reduced.get("camera", "missing")) == "none", "Reduce Motion kept camera travel")
	_expect(float(reduced.get("portrait_breath", 1.0)) == 0.0, "Reduce Motion kept portrait breathing")
	AudioManager.set_vibration_enabled(false)
	_expect(AudioManager.vibration_profile(0.5, 0.8) == Vector2.ZERO, "disabled vibration still pulses")
	AudioManager.set_vibration_enabled(true)
	AudioManager.set_vibration_intensity(0.5)
	var profile := AudioManager.vibration_profile(0.4, 0.8)
	_expect(profile.is_equal_approx(Vector2(0.2, 0.4)), "vibration intensity scaling is %s" % profile)

func _check_settings_surface() -> void:
	var packed := load("res://scenes/StartMenu.tscn") as PackedScene
	_expect(packed != null, "StartMenu settings surface could not be loaded")
	if packed == null:
		return
	var menu := packed.instantiate()
	add_child(menu)
	await get_tree().process_frame
	if menu.has_method("_dismiss_splash"):
		menu.call("_dismiss_splash")
	await get_tree().create_timer(0.35).timeout
	var title_focus_before := get_viewport().gui_get_focus_owner() as Control
	await _press_key(KEY_DOWN)
	var title_focus_after_down := get_viewport().gui_get_focus_owner() as Control
	_expect(
		is_instance_valid(title_focus_before)
		and is_instance_valid(title_focus_after_down)
		and title_focus_after_down != title_focus_before,
		"StartMenu Down arrow did not move title focus")
	await _press_key(KEY_UP)
	_expect(
		get_viewport().gui_get_focus_owner() == title_focus_before,
		"StartMenu Up arrow did not restore title focus")
	menu.call("_open_settings_popup")
	await get_tree().process_frame
	await get_tree().process_frame
	var overlay := menu.get("_settings_overlay") as Control
	_expect(is_instance_valid(overlay), "StartMenu settings overlay did not open")
	if is_instance_valid(overlay):
		var expected_meta := [
			"display_mode_control", "resolution_control", "reduce_motion_control",
			"vibration_control", "vibration_intensity_control",
		]
		for key in expected_meta:
			var matches: Array[Control] = []
			_collect_meta_controls(overlay, key, matches)
			_expect(matches.size() == 1, "settings expected one %s, found %d" % [key, matches.size()])
		var vibration_controls: Array[Control] = []
		var strength_controls: Array[Control] = []
		_collect_meta_controls(overlay, "vibration_control", vibration_controls)
		_collect_meta_controls(overlay, "vibration_intensity_control", strength_controls)
		if vibration_controls.size() == 1 and strength_controls.size() == 1:
			var vibration_toggle := vibration_controls[0] as CheckButton
			var vibration_slider := strength_controls[0] as HSlider
			if not vibration_toggle.button_pressed:
				vibration_toggle.button_pressed = true
				vibration_toggle.toggled.emit(true)
			vibration_toggle.grab_focus()
			await get_tree().process_frame
			await _press_key(KEY_ENTER)
			_expect(not AudioManager.vibration_enabled() \
					and vibration_slider.focus_mode == Control.FOCUS_NONE,
				"StartMenu vibration off left its strength in the focus rail")
			await _press_key(KEY_ENTER)
			_expect(AudioManager.vibration_enabled() \
					and vibration_slider.focus_mode == Control.FOCUS_ALL,
				"StartMenu vibration on did not restore its strength control")
		var resolution_controls: Array[Control] = []
		_collect_meta_controls(overlay, "resolution_control", resolution_controls)
		if resolution_controls.size() == 1 and resolution_controls[0] is OptionButton:
			var resolution_selector := resolution_controls[0] as OptionButton
			_expect(resolution_selector.item_count == DisplayManager.WINDOW_RESOLUTIONS.size(),
				"settings resolution selector is out of sync with DisplayManager")
			_expect(resolution_selector.get_item_text(0).contains("960 × 600"),
				"settings resolution selector does not expose the minimum window size")
			_expect(resolution_selector.get_item_text(resolution_selector.item_count - 2).contains("3440 × 1440"),
				"settings resolution selector does not expose ultrawide")
		var panel := _find_first_panel(overlay)
		_expect(panel != null, "settings panel is missing")
		if panel != null:
			var viewport_size := get_viewport().get_visible_rect().size
			var safe_rect := DisplayManager.tv_safe_rect(viewport_size)
			var rect := panel.get_global_rect()
			_expect(safe_rect.encloses(rect), "settings panel exceeds TV safe area: %s / %s" % [rect, safe_rect])
		var focused := get_viewport().gui_get_focus_owner()
		_expect(focused != null and overlay.is_ancestor_of(focused),
			"settings overlay did not assign controller/keyboard focus")
	menu.call("_close_settings_popup")
	await get_tree().process_frame
	menu.queue_free()
	await get_tree().process_frame

func _collect_meta_controls(root: Node, key: String, output: Array[Control]) -> void:
	if root is Control and bool((root as Control).get_meta(key, false)):
		output.append(root as Control)
	for child in root.get_children():
		_collect_meta_controls(child, key, output)

func _find_first_panel(root: Node) -> PanelContainer:
	if root is PanelContainer:
		return root as PanelContainer
	for child in root.get_children():
		var found := _find_first_panel(child)
		if found != null:
			return found
	return null

func _check_story_vibration_settings() -> void:
	var game_state_snapshot: Dictionary = GameState.serialize().duplicate(true)
	var pending_story_snapshot: Array = GameState.pending_story_queue.duplicate(true)
	var return_scene_snapshot: String = GameState.story_return_scene
	AudioManager.set_vibration_enabled(true)
	AudioManager.set_vibration_intensity(0.60)
	GameState.start_new_game()
	GameState.pending_story_queue = ["story_prologue_dad"]
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	var packed := load("res://scenes/StoryMode.tscn") as PackedScene
	_expect(packed != null, "StoryMode settings surface could not be loaded")
	if packed == null:
		GameState.load_from_dict(game_state_snapshot)
		GameState.pending_story_queue = pending_story_snapshot
		GameState.story_return_scene = return_scene_snapshot
		return
	var story := packed.instantiate() as Control
	add_child(story)
	await get_tree().process_frame
	await get_tree().process_frame
	await _press_key(KEY_F10)
	await get_tree().process_frame
	var overlay := story.get("_audio_settings_popup") as Control
	_expect(is_instance_valid(overlay), "StoryMode Menu input did not open scene settings")
	if is_instance_valid(overlay):
		var vibration_controls: Array[Control] = []
		var strength_controls: Array[Control] = []
		var motion_controls: Array[Control] = []
		_collect_meta_controls(overlay, "vibration_control", vibration_controls)
		_collect_meta_controls(overlay, "vibration_intensity_control", strength_controls)
		_collect_meta_controls(overlay, "reduce_motion_control", motion_controls)
		_expect(vibration_controls.size() == 1,
			"StoryMode expected one vibration toggle, found %d" % vibration_controls.size())
		_expect(strength_controls.size() == 1,
			"StoryMode expected one vibration strength, found %d" % strength_controls.size())
		var panel := _find_first_panel(overlay)
		_expect(panel != null, "StoryMode scene settings panel is missing")
		if panel != null and panel.get_child_count() > 0:
			var column := panel.get_child(0) as Control
			_expect(column.get_combined_minimum_size().y <= column.size.y + 0.5,
				"StoryMode scene settings content overflows the 960x600-safe panel")
		if vibration_controls.size() == 1 and strength_controls.size() == 1 \
				and motion_controls.size() == 1:
			var toggle := vibration_controls[0] as CheckButton
			var slider := strength_controls[0] as HSlider
			var motion := motion_controls[0]
			_expect(toggle.focus_neighbor_bottom == slider.get_path() \
					and slider.focus_neighbor_bottom == motion.get_path(),
				"StoryMode vibration controls are outside the settings focus order")
			var stop_serial_before_off := int(AudioManager.get("_vibration_stop_serial"))
			toggle.grab_focus()
			await get_tree().process_frame
			await _press_key(KEY_ENTER)
			_expect(not AudioManager.vibration_enabled(),
				"StoryMode vibration toggle did not disable output immediately")
			_expect(int(AudioManager.get("_vibration_stop_serial")) \
					== stop_serial_before_off + 1,
				"StoryMode vibration off did not stop an active pulse immediately")
			_expect(slider.focus_mode == Control.FOCUS_NONE \
					and toggle.focus_neighbor_bottom == motion.get_path(),
				"StoryMode disabled vibration strength stayed in the focus rail")
			_expect(AudioManager.vibration_profile(0.5, 0.8) == Vector2.ZERO,
				"StoryMode vibration off did not produce a silent profile")
			await _press_key(KEY_ENTER)
			_expect(AudioManager.vibration_enabled() \
					and slider.focus_mode == Control.FOCUS_ALL,
				"StoryMode vibration toggle did not restore strength control")
			var stop_serial_before_zero := int(AudioManager.get("_vibration_stop_serial"))
			slider.value = 0.0
			await get_tree().process_frame
			_expect(is_zero_approx(AudioManager.vibration_intensity()) \
					and AudioManager.vibration_profile(0.5, 0.8) == Vector2.ZERO,
				"StoryMode zero vibration strength did not stay silent")
			_expect(int(AudioManager.get("_vibration_stop_serial")) \
					== stop_serial_before_zero + 1,
				"StoryMode zero vibration strength did not stop an active pulse immediately")
	story.call("_close_audio_settings")
	await get_tree().process_frame
	await _press_key(KEY_F10)
	await get_tree().process_frame
	var reopened_toggle := story.get("_audio_vibration_toggle") as CheckButton
	var reopened_slider := story.get("_audio_vibration_slider") as HSlider
	_expect(is_instance_valid(reopened_toggle) and reopened_toggle.button_pressed,
		"StoryMode vibration enabled setting did not survive popup rebuild")
	_expect(is_instance_valid(reopened_slider) and is_zero_approx(reopened_slider.value),
		"StoryMode vibration strength did not survive popup rebuild")
	story.call("_close_audio_settings")
	await get_tree().process_frame
	story.queue_free()
	await get_tree().process_frame
	GameState.load_from_dict(game_state_snapshot)
	GameState.pending_story_queue = pending_story_snapshot
	GameState.story_return_scene = return_scene_snapshot
	BGMPlayer.update_idle_ambience()

func _check_direct_input_scenes() -> void:
	for path in DIRECT_INPUT_SCENES:
		_expect(FileAccess.file_exists(path), "direct-input scene missing: %s" % path)
		if not FileAccess.file_exists(path):
			continue
		var source := FileAccess.get_file_as_string(path)
		_expect(source.contains("ControllerHints"), "%s has no controller glyph contract" % path)
		_expect(source.contains("func _unhandled_input"), "%s has no direct input state machine" % path)
		_expect(source.contains("ControllerHints.secondary_pressed(event)"),
			"%s does not share the keyboard/gamepad secondary action" % path)
		_expect(source.contains("ControllerHints.details_pressed(event)"),
			"%s does not share the keyboard/gamepad details action" % path)

func _check_direct_input_runtime() -> void:
	var original_money: float = float(GameState.money)
	var original_flags := GameState.flags.duplicate(true)
	GameState.money = 100_000_000.0
	ControllerHints.clear_qa_override()
	for test_case in DIRECT_INPUT_CASES:
		for input_mode in ["keyboard", "gamepad"]:
			await _exercise_secondary_route(test_case, input_mode)
	GameState.money = original_money
	GameState.flags = original_flags
	BGMPlayer.update_idle_ambience()

func _check_major_stake_routes() -> void:
	var original_money := float(GameState.money)
	var original_flags := GameState.flags.duplicate(true)
	var tutorial_snapshot := TutorialOverlay._seen.duplicate(true)
	GameState.money = 100_000_000.0
	for test_case in MAJOR_INPUT_CASES:
		await _exercise_major_stake_route(test_case)
	GameState.money = original_money
	GameState.flags = original_flags
	TutorialOverlay._seen.clear()
	TutorialOverlay._seen.merge(tutorial_snapshot, true)
	BGMPlayer.update_idle_ambience()

func _exercise_major_stake_route(test_case: Dictionary) -> void:
	var path := str(test_case.get("path", ""))
	var state_name := str(test_case.get("state", ""))
	var counter_name := str(test_case.get("counter", ""))
	var script := load(path) as Script
	_expect(script != null, "major route could not load %s" % path)
	if script == null:
		return
	var constants := script.get_script_constant_map()
	var options_variant: Variant = constants.get(str(test_case.get("options", "")), [])
	_expect(options_variant is Array and (options_variant as Array).size() >= 2,
		"major route has no reversible option set: %s" % path)
	if not options_variant is Array or (options_variant as Array).size() < 2:
		return
	var options := options_variant as Array
	var surface := script.new() as Control
	_expect(surface != null, "major route could not instantiate %s" % path)
	if surface == null:
		return
	add_child(surface)
	await get_tree().process_frame
	var tutorial_id := str(test_case.get("tutorial", ""))
	TutorialOverlay._seen.erase(tutorial_id)
	surface.call("open")
	await get_tree().process_frame
	var tutorial: TutorialOverlay = null
	for child in surface.get_children():
		if child is TutorialOverlay:
			tutorial = child as TutorialOverlay
			break
	_expect(is_instance_valid(tutorial), "%s did not open its trigger-capture tutorial" % path)
	if is_instance_valid(tutorial):
		var modal_value := int(surface.get(state_name))
		var modal_money := float(GameState.money)
		var modal_counter := int(surface.get(counter_name))
		var modal_phase := int(surface.get("_phase"))
		var modal_focus := get_viewport().gui_get_focus_owner()
		ControllerHints.reset_major_input_state()
		await _major_axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.62)
		await _major_axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.83)
		await _major_axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.0)
		await _major_axis_value(JOY_AXIS_TRIGGER_LEFT, 0.62)
		await _major_axis_value(JOY_AXIS_TRIGGER_LEFT, 0.0)
		_expect(int(surface.get(state_name)) == modal_value \
				and is_equal_approx(float(GameState.money), modal_money) \
				and int(surface.get(counter_name)) == modal_counter \
				and int(surface.get("_phase")) == modal_phase \
				and surface.visible,
			"%s tutorial leaked trigger input into hidden game state" % path)
		_expect(get_viewport().gui_get_focus_owner() == modal_focus \
				and tutorial.is_ancestor_of(modal_focus),
			"%s tutorial trigger moved focus behind the modal" % path)
		tutorial.call("_dismiss", false)
		await get_tree().process_frame
		await get_tree().process_frame
	var initial_value := int(surface.get(state_name))
	var initial_index := initial_value if bool(test_case.get("index_state", false)) \
			else options.find(initial_value)
	_expect(initial_index >= 0, "%s initial major value is outside its option set" % path)
	if initial_index < 0:
		await _dispose_keyboard_surface(surface)
		return
	var before_index := clampi(int(options.size() / 2), 0, options.size() - 2)
	var before := before_index if bool(test_case.get("index_state", false)) \
			else int(options[before_index])
	surface.set(state_name, before)
	ControllerHints.reset_major_input_state()
	await _major_axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.62)
	var expected_next_index := clampi(before_index + 1, 0, options.size() - 1)
	var expected_next := expected_next_index \
		if bool(test_case.get("index_state", false)) \
		else int(options[expected_next_index])
	var after_next := int(surface.get(state_name))
	_expect(after_next == expected_next,
		"%s R2 moved %s to %d instead of next %d" % [path, state_name, after_next, expected_next])
	await _major_axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.83)
	_expect(int(surface.get(state_name)) == after_next,
		"%s held R2 repeated its major value" % path)
	await _major_axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.0)
	await _major_axis_value(JOY_AXIS_TRIGGER_LEFT, 0.62)
	await _major_axis_value(JOY_AXIS_TRIGGER_LEFT, 0.0)
	_expect(int(surface.get(state_name)) == before,
		"%s L2 did not reverse the R2 value change" % path)

	# L2/R2 are decrease/increase, not circular selectors. At either endpoint
	# the outward trigger must be a raw-input no-op instead of wrapping direction.
	var min_value := 0 if bool(test_case.get("index_state", false)) else int(options[0])
	var max_value := options.size() - 1 if bool(test_case.get("index_state", false)) \
			else int(options[-1])
	surface.set(state_name, min_value)
	var boundary_money := float(GameState.money)
	var boundary_counter := int(surface.get(counter_name))
	var boundary_phase := int(surface.get("_phase"))
	var boundary_focus := get_viewport().gui_get_focus_owner()
	ControllerHints.reset_major_input_state()
	await _major_axis_value(JOY_AXIS_TRIGGER_LEFT, 0.62)
	await _major_axis_value(JOY_AXIS_TRIGGER_LEFT, 0.83)
	await _major_axis_value(JOY_AXIS_TRIGGER_LEFT, 0.0)
	_expect(int(surface.get(state_name)) == min_value,
		"%s L2 wrapped the minimum major value" % path)
	_expect(is_equal_approx(float(GameState.money), boundary_money) \
			and int(surface.get(counter_name)) == boundary_counter \
			and int(surface.get("_phase")) == boundary_phase \
			and get_viewport().gui_get_focus_owner() == boundary_focus \
			and surface.visible,
		"%s minimum L2 boundary mutated game/focus state" % path)

	surface.set(state_name, max_value)
	boundary_money = float(GameState.money)
	boundary_counter = int(surface.get(counter_name))
	boundary_phase = int(surface.get("_phase"))
	boundary_focus = get_viewport().gui_get_focus_owner()
	ControllerHints.reset_major_input_state()
	await _major_axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.62)
	await _major_axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.83)
	await _major_axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.0)
	_expect(int(surface.get(state_name)) == max_value,
		"%s R2 wrapped the maximum major value" % path)
	_expect(is_equal_approx(float(GameState.money), boundary_money) \
			and int(surface.get(counter_name)) == boundary_counter \
			and int(surface.get("_phase")) == boundary_phase \
			and get_viewport().gui_get_focus_owner() == boundary_focus \
			and surface.visible,
		"%s maximum R2 boundary mutated game/focus state" % path)

	# Phase 1 is an in-flight/result phase on all eight direct games. Triggers
	# must be captured without changing value, money, round count, or focus.
	surface.set_process(false)
	surface.set("_phase", 1)
	var invalid_value := int(surface.get(state_name))
	var invalid_money := float(GameState.money)
	var invalid_counter := int(surface.get(counter_name))
	var invalid_focus := get_viewport().gui_get_focus_owner()
	ControllerHints.reset_major_input_state()
	await _major_axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.62)
	await _major_axis_value(JOY_AXIS_TRIGGER_RIGHT, 0.0)
	_expect(int(surface.get(state_name)) == invalid_value,
		"%s invalid phase changed %s" % [path, state_name])
	_expect(is_equal_approx(float(GameState.money), invalid_money),
		"%s invalid phase changed money" % path)
	_expect(int(surface.get(counter_name)) == invalid_counter,
		"%s invalid phase changed round/session count" % path)
	_expect(get_viewport().gui_get_focus_owner() == invalid_focus,
		"%s invalid phase stole focus" % path)
	_expect(int(surface.get("_phase")) == 1 and surface.visible,
		"%s invalid trigger changed phase or exited" % path)
	await _dispose_keyboard_surface(surface)

func _exercise_secondary_route(test_case: Dictionary, input_mode: String) -> void:
	var path := str(test_case.get("path", ""))
	var state_name := str(test_case.get("state", ""))
	var script := load(path) as Script
	_expect(script != null, "runtime input route could not load %s" % path)
	if script == null:
		return
	var surface := script.new() as Control
	_expect(surface != null, "runtime input route could not instantiate %s" % path)
	if surface == null:
		return
	add_child(surface)
	await get_tree().process_frame
	_expect(surface.has_method("open"), "runtime input route has no open(): %s" % path)
	if not surface.has_method("open"):
		surface.queue_free()
		await get_tree().process_frame
		return
	surface.call("open")
	await get_tree().process_frame
	_expect(surface.visible, "runtime input route did not open %s" % path)
	var before = surface.get(state_name)
	surface.call("_unhandled_input", _secondary_input_event(input_mode))
	await get_tree().process_frame
	var after = surface.get(state_name)
	if state_name == "_glossary_overlay":
		_expect(is_instance_valid(after), "%s secondary route did not open the glossary in %s" % [
			path, input_mode])
	else:
		_expect(after != before, "%s secondary route did not change %s in %s" % [
			path, state_name, input_mode])
	surface.queue_free()
	await get_tree().process_frame

func _secondary_input_event(input_mode: String) -> InputEvent:
	if input_mode == "keyboard":
		var key := InputEventKey.new()
		key.physical_keycode = KEY_X
		key.pressed = true
		return key
	var button := InputEventJoypadButton.new()
	button.button_index = JOY_BUTTON_X
	button.pressed = true
	return button

func _check_minigame_keyboard_tasks() -> void:
	var game_state_snapshot: Dictionary = GameState.serialize().duplicate(true)
	var tutorial_snapshot: Dictionary = TutorialOverlay._seen.duplicate(true)
	for tutorial_id in [
		"blackjack", "baccarat", "slot", "roulette", "bigwheel",
		"daisai", "holdem", "racetrack",
	]:
		TutorialOverlay._seen[tutorial_id] = true
	ControllerHints.clear_qa_override()

	await _check_blackjack_keyboard()
	await _check_baccarat_keyboard()
	await _check_slot_keyboard()
	await _check_roulette_keyboard()
	await _check_bigwheel_keyboard()
	await _check_daisai_keyboard()
	await _check_holdem_keyboard()
	await _check_racetrack_keyboard()
	await _check_casino_hub_keyboard()
	await _check_job_hunt_keyboard()
	await _check_job_hunt_ap_return()

	GameState.load_from_dict(game_state_snapshot)
	TutorialOverlay._seen.clear()
	TutorialOverlay._seen.merge(tutorial_snapshot, true)
	BGMPlayer.update_idle_ambience()

func _check_blackjack_keyboard() -> void:
	var table := await _open_keyboard_surface("res://scenes/BlackjackTable.gd")
	if table == null:
		return
	var first_stake := int(table.get("_stake"))
	await _press_key(KEY_X)
	_expect(int(table.get("_stake")) != first_stake, "blackjack X did not change stake")
	await _press_key(KEY_ENTER)
	_expect(int(table.get("_rounds")) == 1, "blackjack Enter did not deal a hand")
	await _dispose_keyboard_surface(table)

func _check_baccarat_keyboard() -> void:
	var table := await _open_keyboard_surface("res://scenes/BaccaratTable.gd")
	if table == null:
		return
	var first_stake := int(table.get("_active_stake"))
	await _press_key(KEY_X)
	_expect(int(table.get("_active_stake")) != first_stake, "baccarat X did not change stake")
	await _press_key(KEY_ENTER)
	_expect(int(table.get("_bet_p")) > 0, "baccarat Enter did not place a Player bet")
	await _press_key(KEY_DOWN)
	await _press_key(KEY_DOWN)
	await _press_key(KEY_ENTER)
	_expect(int(table.get("_phase")) == 1, "baccarat keyboard route did not start the deal")
	await _dispose_keyboard_surface(table)

func _check_slot_keyboard() -> void:
	var game := await _open_keyboard_surface("res://scenes/SlotMachineGame.gd")
	if game == null:
		return
	var first_stake := int(game.get("_active_stake"))
	await _press_key(KEY_X)
	_expect(int(game.get("_active_stake")) != first_stake, "slot X did not change stake")
	await _press_key(KEY_ENTER)
	_expect(int(game.get("_phase")) == 1, "slot Enter did not start the reels")
	await _dispose_keyboard_surface(game)

func _check_roulette_keyboard() -> void:
	var table := await _open_keyboard_surface("res://scenes/RouletteTable.gd")
	if table == null:
		return
	var first_stake := int(table.get("_stake"))
	await _press_key(KEY_X)
	_expect(int(table.get("_stake")) != first_stake, "roulette X did not change stake")
	await _press_key(KEY_ENTER)
	_expect(int(table.get("_bet_amount")) > 0, "roulette Enter did not stage a bet")
	await _press_key(KEY_E)
	await _press_key(KEY_E)
	_expect(int(table.get("_pad_mode")) == 2, "roulette E did not reach the action rail")
	await _press_key(KEY_ENTER)
	_expect(int(table.get("_phase")) == 1, "roulette Enter did not spin the wheel")
	await _dispose_keyboard_surface(table)

func _check_bigwheel_keyboard() -> void:
	var game := await _open_keyboard_surface("res://scenes/BigWheelGame.gd")
	if game == null:
		return
	var first_stake := int(game.get("_stake"))
	await _press_key(KEY_X)
	_expect(int(game.get("_stake")) != first_stake, "big wheel X did not change stake")
	await _press_key(KEY_ENTER)
	_expect(int(game.get("_bet_segment")) >= 0, "big wheel Enter did not choose a segment")
	await _press_key(KEY_ENTER)
	_expect(int(game.get("_phase")) == 1, "big wheel Enter did not start the wheel")
	await _dispose_keyboard_surface(game)

func _check_daisai_keyboard() -> void:
	var table := await _open_keyboard_surface("res://scenes/DaiSaiTable.gd")
	if table == null:
		return
	var first_stake := int(table.get("_stake"))
	var first_bet_type := int(table.get("_bet_type"))
	await _press_key(KEY_X)
	_expect(int(table.get("_stake")) != first_stake, "dai sai X did not change stake")
	await _press_key(KEY_RIGHT)
	await _press_key(KEY_ENTER)
	_expect(int(table.get("_phase")) == 0 and int(table.get("_bet_type")) != first_bet_type,
		"dai sai Enter did not select the highlighted bet")
	await _press_key(KEY_ENTER)
	_expect(int(table.get("_phase")) == 1, "dai sai Enter did not roll the dice")
	await _dispose_keyboard_surface(table)

func _check_holdem_keyboard() -> void:
	var table := await _open_keyboard_surface("res://scenes/HoldemClub.gd")
	if table == null:
		return
	var first_buyin := int(table.get("_buy_in"))
	await _press_key(KEY_X)
	_expect(int(table.get("_buy_in")) != first_buyin, "holdem X did not change buy-in")
	await _press_key(KEY_ENTER)
	var hole: Array = table.get("_hole")
	_expect(hole.size() == 2 and int(table.get("_phase")) != 0,
		"holdem Enter did not buy in and deal hole cards")
	await _dispose_keyboard_surface(table)

func _check_racetrack_keyboard() -> void:
	var track := await _open_keyboard_surface("res://scenes/RaceTrack.gd", false)
	if track == null:
		return
	track.set("skip_countdown_for_smoke", true)
	track.call("open")
	await get_tree().process_frame
	await _press_key(KEY_X)
	_expect(int(track.get("_pad_stake_idx")) == 1, "racetrack X did not change stake")
	await _press_key(KEY_ENTER)
	var picks: Array = track.get("_picks")
	_expect(picks.size() == 1, "racetrack Enter did not select a horse")
	await _press_key(KEY_ENTER)
	_expect(int(track.get("_phase")) == 1 and float(track.get("_bet_stake")) > 0.0,
		"racetrack Enter did not place the bet and start the race")
	var race: Dictionary = track.get("_race")
	track.set("_finish", (race.get("horses", []) as Array).duplicate())
	track.set("_payout_amt", 0.0)
	track.set("_phase", 2)
	track.call("_render")
	await get_tree().process_frame
	await _press_key(KEY_RIGHT)
	_expect(int(track.get("_pad_result_idx")) == 1,
		"racetrack Right did not highlight Leave on the result screen")
	await _press_key(KEY_ENTER)
	_expect(not bool(track.get("visible")),
		"racetrack Enter did not activate the highlighted Leave action")
	await _dispose_keyboard_surface(track)

func _check_casino_hub_keyboard() -> void:
	GameState.money = 100_000_000.0
	var child_paths := [
		"res://scenes/BaccaratTable.gd", "res://scenes/BlackjackTable.gd",
		"res://scenes/SlotMachineGame.gd", "res://scenes/RouletteTable.gd",
		"res://scenes/BigWheelGame.gd", "res://scenes/DaiSaiTable.gd",
	]
	var children: Array[Control] = []
	for path in child_paths:
		var child := await _make_keyboard_surface(path)
		if child == null:
			for created in children:
				await _dispose_keyboard_surface(created)
			return
		children.append(child)
	var hub := await _make_keyboard_surface("res://scenes/JeongseonCasino.gd")
	if hub == null:
		for child in children:
			await _dispose_keyboard_surface(child)
		return
	hub.set("baccarat_table", children[0])
	hub.set("blackjack_table", children[1])
	hub.set("slot_machine_game", children[2])
	hub.set("roulette_table", children[3])
	hub.set("big_wheel_game", children[4])
	hub.set("dai_sai_table", children[5])
	hub.call("open")
	await get_tree().process_frame
	await _press_key(KEY_RIGHT)
	_expect(int(hub.get("_pad_game_idx")) == 1, "casino hub Right did not select Blackjack")
	await _press_key(KEY_ENTER)
	_expect(not hub.visible and children[1].visible,
		"casino hub Enter did not launch the selected game")
	await _dispose_keyboard_surface(hub)
	for child in children:
		await _dispose_keyboard_surface(child)

func _check_job_hunt_keyboard() -> void:
	var game := await _make_keyboard_surface("res://scenes/JobHuntMiniGame.gd")
	if game == null:
		return

	game.call("open", 0)
	await get_tree().process_frame
	await get_tree().process_frame
	var layouts: Array = game.get("_choice_layouts")
	_expect(layouts.size() == 4, "resume session did not prepare four choice layouts")
	var best_slots := {}
	var top_score := 0
	for layout_variant in layouts:
		var layout: Array = layout_variant
		if layout.is_empty():
			continue
		var best_slot := 0
		var best_score := -1
		for choice_index in range(layout.size()):
			var score := int((layout[choice_index] as Dictionary).get("score", 0))
			if score > best_score:
				best_score = score
				best_slot = choice_index
		top_score += int((layout[0] as Dictionary).get("score", 0))
		best_slots[best_slot] = true
	_expect(best_slots.size() == 3,
		"resume best answers were not distributed across all three positions: %s" \
			% [best_slots.keys()])
	_expect(top_score < layouts.size() * 3 * 0.85,
		"pressing only the top resume answer can still earn Grade A")

	var first_focus := get_viewport().gui_get_focus_owner()
	_expect(is_instance_valid(first_focus) and game.is_ancestor_of(first_focus),
		"resume question did not assign keyboard/controller focus")
	await _press_key(KEY_RIGHT)
	var second_focus := get_viewport().gui_get_focus_owner()
	_expect(is_instance_valid(second_focus) and second_focus != first_focus \
			and game.is_ancestor_of(second_focus),
		"resume Right did not move to the next answer card")
	await _press_key(KEY_ENTER)
	_expect(bool(game.get("_waiting")), "resume Enter did not select the focused answer")

	game.call("open", 0)
	await get_tree().process_frame
	await get_tree().process_frame
	var result := {"quality": -1}
	game.connect("closed", func(_stress_delta: int, quality: int) -> void:
		result["quality"] = quality
	, CONNECT_ONE_SHOT)
	var question_count := int((game.get("_active_questions") as Array).size())
	for question_index in range(question_count):
		game.set("_q_idx", question_index)
		game.set("_waiting", false)
		game.call("_on_choose", 0)
	game.set("_waiting", false)
	game.call("_show_result")
	await get_tree().process_frame
	await get_tree().process_frame
	var confirm_focus := get_viewport().gui_get_focus_owner()
	_expect(is_instance_valid(confirm_focus) and game.is_ancestor_of(confirm_focus),
		"resume result did not focus Confirm")
	await _press_key(KEY_ENTER)
	_expect(int(result.get("quality", -1)) < 3,
		"top-only resume answers still produced Grade A")

	game.call("open", 0)
	await get_tree().process_frame
	await get_tree().process_frame
	var pad_first_focus := get_viewport().gui_get_focus_owner()
	await _press_joy(JOY_BUTTON_DPAD_RIGHT)
	var pad_second_focus := get_viewport().gui_get_focus_owner()
	_expect(is_instance_valid(pad_second_focus) and pad_second_focus != pad_first_focus \
			and game.is_ancestor_of(pad_second_focus),
		"resume gamepad Right did not move to the next answer card")
	await _press_joy(JOY_BUTTON_A)
	_expect(bool(game.get("_waiting")), "resume gamepad South did not select the focused answer")
	await _dispose_keyboard_surface(game)

func _check_job_hunt_ap_return() -> void:
	var packed := load("res://scenes/MainGame.tscn") as PackedScene
	_expect(packed != null, "MainGame could not load for resume return focus")
	if packed == null:
		return
	GameState.start_new_game("김민준", "지방_상경", "직장형", "백수", "자유런", "현실")
	GameState.turn = 2
	GameState.action_points = 2
	GameState.current_job = {}
	GameState.flags["prologue_done"] = true
	GameState.flags["tutorial_shown"] = true
	GameState.add_log("InputMatrix resume fixture", "system")
	TutorialOverlay._seen["main_game"] = true
	var main_game := packed.instantiate()
	main_game.set_meta("_screenshot_qa_static_surface", true)
	add_child(main_game)
	await get_tree().process_frame
	await get_tree().process_frame
	main_game.call("_render_ap_actions")
	await get_tree().process_frame
	await get_tree().process_frame

	var resume_card: Button = null
	for card_variant in main_game.get("_ap_grid_cards"):
		var card := card_variant as Button
		if card != null and str(card.get_meta("ap_action_fn", "")) == "_ap_write_resume":
			resume_card = card
			break
	_expect(is_instance_valid(resume_card), "week-two AP board did not expose Resume Writing")
	if not is_instance_valid(resume_card):
		main_game.queue_free()
		await get_tree().process_frame
		return
	resume_card.pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	var game = main_game.get("job_hunt_game")
	_expect(is_instance_valid(game) and game.visible,
		"resume AP card did not open the job hunt assessment")
	if not is_instance_valid(game):
		main_game.queue_free()
		await get_tree().process_frame
		return
	game.call("_on_finish", 2)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	var focus_owner := get_viewport().gui_get_focus_owner()
	var main_root := main_game.get("_main_ui_root") as Control
	_expect(is_instance_valid(main_root) and main_root.visible,
		"AP surface stayed hidden after resume completion")
	_expect(is_instance_valid(focus_owner) and is_instance_valid(main_root) \
			and main_root.is_ancestor_of(focus_owner),
		"resume completion did not return focus to the AP surface")
	var completed_turn: int = int(GameState.turn)
	await _press_key(KEY_ENTER)
	_expect(int(main_game.get_meta("_qa_scene_first_advance_requested", -1)) == completed_turn,
		"AP surface ignored keyboard Confirm after resume completion")
	main_game.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame

func _open_keyboard_surface(path: String, call_open: bool = true) -> Control:
	GameState.money = 100_000_000.0
	var surface := await _make_keyboard_surface(path)
	if surface == null:
		return null
	if call_open:
		surface.call("open")
		await get_tree().process_frame
		_expect(surface.visible, "keyboard task did not open %s" % path)
	return surface

func _make_keyboard_surface(path: String) -> Control:
	var script := load(path) as Script
	_expect(script != null, "keyboard task could not load %s" % path)
	if script == null:
		return null
	var surface := script.new() as Control
	_expect(surface != null, "keyboard task could not instantiate %s" % path)
	if surface == null:
		return null
	add_child(surface)
	await get_tree().process_frame
	return surface

func _dispose_keyboard_surface(surface: Control) -> void:
	if not is_instance_valid(surface):
		return
	surface.visible = false
	surface.set_process(false)
	surface.queue_free()
	await get_tree().process_frame

func _press_key(keycode: Key) -> void:
	var press := InputEventKey.new()
	press.keycode = keycode
	press.physical_keycode = keycode
	press.pressed = true
	Input.parse_input_event(press)
	await get_tree().process_frame
	var release := InputEventKey.new()
	release.keycode = keycode
	release.physical_keycode = keycode
	release.pressed = false
	Input.parse_input_event(release)
	await get_tree().process_frame

func _press_joy(button_index: JoyButton) -> void:
	var press := InputEventJoypadButton.new()
	press.button_index = button_index
	press.pressed = true
	Input.parse_input_event(press)
	await get_tree().process_frame
	var release := InputEventJoypadButton.new()
	release.button_index = button_index
	release.pressed = false
	Input.parse_input_event(release)
	await get_tree().process_frame

func _major_axis_value(axis: JoyAxis, value: float) -> void:
	var motion := InputEventJoypadMotion.new()
	motion.device = 0
	motion.axis = axis
	motion.axis_value = value
	Input.parse_input_event(motion)
	await get_tree().process_frame

func _check_steam_input_template() -> void:
	_expect(FileAccess.file_exists(STEAM_ACTIONS_PATH), "Steam Input action template missing")
	if not FileAccess.file_exists(STEAM_ACTIONS_PATH):
		return
	var source := FileAccess.get_file_as_string(STEAM_ACTIONS_PATH)
	for token in [
		"\"In Game Actions\"", "\"Menu\"", "\"Story\"", "\"Life\"", "\"Minigame\"",
		"\"Confirm\"", "\"Back\"", "\"AdvanceWeek\"", "\"SystemMenu\"",
		"\"english\"", "\"koreana\"",
	]:
		_expect(source.contains(token), "Steam Input template missing %s" % token)
	for action_set in ["Menu", "Story", "Life", "Minigame"]:
		var action_set_body := _vdf_named_block(source, action_set)
		_expect(not action_set_body.is_empty(),
			"Steam Input template could not parse %s action set" % action_set)
		_expect(action_set_body.count("\"MajorPrevious\"") == 1,
			"Steam Input %s set must declare MajorPrevious exactly once" % action_set)
		_expect(action_set_body.count("\"MajorNext\"") == 1,
			"Steam Input %s set must declare MajorNext exactly once" % action_set)
	_expect(source.count("\"MajorPrevious\"") == 4,
		"Steam Input MajorPrevious action declaration count is not four")
	_expect(source.count("\"MajorNext\"") == 4,
		"Steam Input MajorNext action declaration count is not four")
	for localized_title in [
		"\"#Action_MajorPrevious\"\t\"Previous Page / Decrease\"",
		"\"#Action_MajorNext\"\t\"Next Page / Increase\"",
		"\"#Action_MajorPrevious\"\t\"이전 페이지 / 감소\"",
		"\"#Action_MajorNext\"\t\"다음 페이지 / 증가\"",
	]:
		_expect(source.contains(localized_title),
			"Steam Input template missing localized major title %s" % localized_title)
	_expect(source.count("\"#Action_MajorPrevious\"") == 6,
		"Steam Input MajorPrevious title reference/localization count is not six")
	_expect(source.count("\"#Action_MajorNext\"") == 6,
		"Steam Input MajorNext title reference/localization count is not six")

func _vdf_named_block(source: String, block_name: String) -> String:
	var marker := "\"%s\"" % block_name
	var marker_index := source.find(marker)
	if marker_index < 0:
		return ""
	var open_index := source.find("{", marker_index + marker.length())
	if open_index < 0:
		return ""
	var depth := 0
	for index in range(open_index, source.length()):
		var character := source.substr(index, 1)
		if character == "{":
			depth += 1
		elif character == "}":
			depth -= 1
			if depth == 0:
				return source.substr(open_index + 1, index - open_index - 1)
	return ""

func _restore_settings() -> void:
	AudioManager.set_vibration_intensity(_original_vibration_intensity)
	AudioManager.set_vibration_enabled(_original_vibration_enabled)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
