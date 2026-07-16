extends Node
## Runtime contract for the launch sting, single title gate, and new-story
## motion-comic. Visual judgment stays in ScreenshotQA; this gate prevents the
## old three-gate boot chain and presentation-card opening from returning.

const SPLASH_SCENE := preload("res://scenes/SplashScreen.tscn")
const MENU_SCENE := preload("res://scenes/StartMenu.tscn")
const OPENING_SCENE := preload("res://scenes/OpeningCinematic.tscn")

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	SaveManager.set_setting("language", "en")
	SaveManager.set_setting("language_gate_seen", true)
	SaveManager.set_setting("reduce_motion", false)
	LocaleManager.set_language("en")
	await _check_splash()
	await _check_title_menu()
	await _check_pad_title_menu()
	await _check_opening(false, "en")
	await _check_opening(true, "ko")
	_check_static_budget()
	LocaleManager.set_language("en")
	_stop_test_audio()
	await get_tree().create_timer(0.25, true, false, true).timeout
	await get_tree().process_frame
	await get_tree().process_frame
	if not _failures.is_empty():
		for failure in _failures:
			push_error("FIRST_30_SECONDS_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("FIRST_30_SECONDS_CHECK_OK gates=1 beats=3 budget=17.1s logo=vector audio=1 reduced_motion=1 pad=1")
	get_tree().quit(0)


func _check_splash() -> void:
	var splash := SPLASH_SCENE.instantiate()
	splash.set("_qa_disable_auto_advance", true)
	add_child(splash)
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(int(splash.get_meta("launch_required_input_gates", -1)) == 0,
		"Publisher pre-roll introduced an input gate.")
	_expect(str(splash.get_meta("launch_next_scene", "")) == "res://scenes/StartMenu.tscn",
		"Publisher pre-roll does not hand off to StartMenu.")
	_expect(AudioManager.has_sound("publisher_sting"), "Publisher sting was not loaded.")
	var mark := splash.find_child("JunpacMark", true, false)
	_expect(mark != null, "Code-native JUNPAC mark is missing.")
	if mark != null:
		_expect(str(mark.get_meta("publisher_mark_kind", "")) == "code_native",
			"Publisher mark is not tagged as code-native.")
		_expect(bool(mark.get_meta("publisher_mark_transparent", false)),
			"Publisher mark lost its transparent surface contract.")
	_expect(not _tree_uses_texture(splash, "junpac_games_logo.jpg"),
		"Runtime launch tree still references the JPEG publisher board.")
	await get_tree().create_timer(3.25).timeout
	_expect(str(splash.get_meta("launch_stage", "")) == "title_complete",
		"Launch title did not become interactive within the brand budget.")
	_expect(int(splash.get_meta("publisher_sting_play_count", 0)) == 1,
		"Publisher sting must play exactly once.")
	var title_image := splash.get("_bg_img") as TextureRect
	_expect(is_instance_valid(title_image) and title_image.modulate.a >= 0.62,
		"Launch key art remains too dark after the title reveal.")
	splash.call("_go_to_start")
	_expect(int(splash.get_meta("launch_transition_requests", 0)) == 1,
		"Launch skip requested more than one scene transition.")
	_dispose(splash)
	await get_tree().process_frame


func _check_title_menu() -> void:
	LocaleManager.set_language("en")
	var menu := MENU_SCENE.instantiate()
	add_child(menu)
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(int(menu.get_meta("launch_required_input_gates", -1)) == 1,
		"Title must own the launch flow's only required input gate.")
	_expect(str(menu.get_meta("new_story_scene", "")) == "res://scenes/OpeningCinematic.tscn",
		"New Story bypasses the authored motion-comic opening.")
	var visible_text := _collect_text(menu)
	_expect("PRESS ANY KEY" in visible_text, "English title gate is missing its start prompt.")
	_expect(not _contains_hangul(visible_text), "English title gate contains Hangul.")
	menu.call("_dismiss_splash")
	await get_tree().create_timer(0.30).timeout
	_expect(int(menu.get_meta("launch_required_input_gates", -1)) == 0,
		"Title gate did not clear after one input.")
	_expect(bool(menu.get_meta("launch_gate_dismissed", false)),
		"Title did not record its single dismissal.")
	var focused := get_viewport().gui_get_focus_owner()
	_expect(focused is Button, "Title commands did not restore controller focus.")
	_dispose(menu)
	await get_tree().process_frame


func _check_pad_title_menu() -> void:
	ControllerHints.force_brand_for_qa(ControllerHints.Brand.PLAYSTATION)
	LocaleManager.set_language("en")
	var menu := MENU_SCENE.instantiate()
	add_child(menu)
	await get_tree().process_frame
	await get_tree().process_frame
	var visible_text := _collect_text(menu)
	_expect("[%s]  START" % ControllerHints.south() in visible_text,
		"PlayStation title gate does not expose the South-button start prompt.")
	_expect("PRESS ANY KEY" not in visible_text,
		"Pad title gate still asks for a keyboard key.")
	menu.call("_dismiss_splash")
	await get_tree().create_timer(0.30).timeout
	var focused := get_viewport().gui_get_focus_owner()
	_expect(focused is Button, "Pad title dismissal did not restore command focus.")
	_dispose(menu)
	ControllerHints.clear_qa_override()
	await get_tree().process_frame


func _check_opening(reduced_motion: bool, language: String) -> void:
	LocaleManager.set_language(language)
	var opening := OPENING_SCENE.instantiate()
	opening.set("_qa_disable_autoplay", true)
	opening.set("_qa_force_reduced_motion", reduced_motion)
	opening.set("_qa_suppress_transition", true)
	add_child(opening)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(int(opening.get_meta("opening_beat_count", 0)) == 3,
		"Opening must stay at three beats or fewer.")
	_expect(int(opening.get_meta("opening_required_input_gates", -1)) == 0,
		"Opening added a second mandatory input gate.")
	_expect(str(opening.get_meta("opening_skip_target", "")) == "res://scenes/MainGame.tscn",
		"Opening skip does not enter the playable game.")
	_expect(bool(opening.get_meta("opening_reduced_motion", false)) == reduced_motion,
		"Opening did not honor Reduce Motion.")
	_expect(bool(opening.get_meta("opening_camera_motion", true)) != reduced_motion,
		"Opening camera-depth fallback does not match Reduce Motion.")
	var image := opening.get("_current_image") as TextureRect
	_expect(is_instance_valid(image) and image.texture != null,
		"Opening beat is not a full-bleed illustrated frame.")
	if is_instance_valid(image):
		_expect(image.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_COVERED,
			"Opening image is not aspect-covered full bleed.")
		if reduced_motion:
			_expect(image.scale.is_equal_approx(Vector2.ONE),
				"Reduce Motion opening still applies camera scaling.")
	var atmosphere := opening.find_child("OpeningAtmosphere", true, false)
	var profile: Dictionary = atmosphere.get("current_profile") if atmosphere != null else {}
	_expect(str(profile.get("effect", "")) == "city_light",
		"Opening first beat lost its authored city-light layer.")
	if reduced_motion:
		_expect(str(profile.get("camera", "")) == "none",
			"Reduce Motion did not disable the Living Scene camera.")
	else:
		_expect(str(profile.get("camera", "")).begins_with("living_"),
			"Opening lacks a cinematic camera profile.")
		_expect(float(profile.get("motion_scale", 0.0)) > 0.5,
			"Opening atmosphere is configured as static.")
	var text := _collect_text(opening)
	if language == "en":
		_expect("2026. Seoul." in text, "English opening lost its first beat.")
		_expect(not _contains_hangul(text), "English opening contains Hangul.")
	else:
		_expect("2026년, 서울." in text, "Korean opening lost its first beat.")
	opening.call("_finish_opening")
	_expect(int(opening.get_meta("opening_transition_requests", 0)) == 1,
		"Opening skip did not request exactly one transition.")
	_dispose(opening)
	await get_tree().process_frame


func _check_static_budget() -> void:
	var splash_constants: Dictionary = (load("res://scenes/SplashScreen.gd") as Script).get_script_constant_map()
	var opening_constants: Dictionary = (load("res://scenes/OpeningCinematic.gd") as Script).get_script_constant_map()
	var brand_seconds := float(splash_constants.get("BRAND_SEQUENCE_SECONDS", 999.0))
	var opening_seconds := float(opening_constants.get("OPENING_MAX_SECONDS", 999.0))
	_expect(brand_seconds <= 5.0, "Publisher/title pre-roll exceeds five seconds.")
	_expect(opening_seconds <= 14.0, "New-story opening exceeds fourteen seconds.")
	_expect(brand_seconds + opening_seconds <= 20.0,
		"Authored launch motion exceeds the first-30-second interaction budget.")
	_expect(int(splash_constants.get("LAUNCH_REQUIRED_INPUT_GATES", -1))
			+ int((load("res://scenes/StartMenu.gd") as Script).get_script_constant_map().get(
				"LAUNCH_REQUIRED_INPUT_GATES", -1))
			+ int(opening_constants.get("OPENING_REQUIRED_INPUT_GATES", -1)) == 1,
		"Launch flow must contain exactly one required input gate.")


func _tree_uses_texture(node: Node, file_name: String) -> bool:
	if node is TextureRect:
		var texture := (node as TextureRect).texture
		if texture != null and texture.resource_path.ends_with(file_name):
			return true
	for child in node.get_children():
		if _tree_uses_texture(child, file_name):
			return true
	return false


func _collect_text(node: Node) -> String:
	var parts: Array[String] = []
	_collect_text_into(node, parts)
	return "\n".join(parts)


func _collect_text_into(node: Node, parts: Array[String]) -> void:
	if node is Label:
		parts.append((node as Label).text)
	elif node is Button:
		parts.append((node as Button).text)
	elif node is RichTextLabel:
		parts.append((node as RichTextLabel).text)
	for child in node.get_children():
		_collect_text_into(child, parts)


func _contains_hangul(text: String) -> bool:
	for index in range(text.length()):
		var codepoint := text.unicode_at(index)
		if (codepoint >= 0xAC00 and codepoint <= 0xD7A3) \
				or (codepoint >= 0x1100 and codepoint <= 0x11FF) \
				or (codepoint >= 0x3130 and codepoint <= 0x318F):
			return true
	return false


func _dispose(node: Node) -> void:
	if not is_instance_valid(node):
		return
	if node.get_parent() != null:
		node.get_parent().remove_child(node)
	node.free()


func _stop_test_audio() -> void:
	BGMPlayer.stop()
	for owner in [AudioManager, BGMPlayer]:
		for child in owner.get_children():
			if child is AudioStreamPlayer:
				(child as AudioStreamPlayer).stop()
				(child as AudioStreamPlayer).stream = null


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
