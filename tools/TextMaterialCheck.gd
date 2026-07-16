extends Node
## Locks the restrained Gangnam Ink hierarchy: body copy stays crisp while
## titles, choices, money and state changes receive only shallow material depth.

const STORY_MODE_PATH := "res://scenes/StoryMode.tscn"
const MAIN_GAME_PATH := "res://scenes/MainGame.tscn"

var _failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	_check_shared_tokens()
	_check_main_game_materials()
	await _check_story_materials()
	await _stop_audio()
	if _failures.is_empty():
		print("TEXT_MATERIAL_CHECK_OK text_depth=1 surface_depth=2 body_shadow=0 press_travel=1 motion_ms=55")
		call_deferred("_quit", 0)
		return
	for failure in _failures:
		push_error("TEXT_MATERIAL_CHECK_FAIL: %s" % failure)
	call_deferred("_quit", 1)

func _check_shared_tokens() -> void:
	_expect(UIStyle.INK_TEXT_DEPTH_PX == 1, "display text depth is no longer 1px")
	_expect(UIStyle.INK_SURFACE_DEPTH_MAX_PX == 2, "surface depth exceeds the 2px ceiling")
	_expect(UIStyle.INK_SURFACE_OFFSET_MAX_PX == 1, "surface offset exceeds the 1px ceiling")
	_expect(UIStyle.MATERIAL_PRESS_TRAVEL_PX == 1, "pressed surface travel is no longer 1px")
	_expect(is_equal_approx(UIStyle.MATERIAL_PRESS_DURATION_SEC, 0.055),
		"material press motion is no longer 55ms")

	var display := Label.new()
	UIStyle.apply_ink_text_depth(display, "display")
	_expect(_text_shadow_y(display) == 1, "display token lost its 1px vertical shadow")
	_expect(_text_shadow_outline(display) == 0, "display token gained a blurred outline")
	var body := RichTextLabel.new()
	UIStyle.clear_ink_text_depth(body)
	_expect(_is_body_shadow_clear(body), "body token inherited a visible shadow")
	display.free()
	body.free()

func _check_main_game_materials() -> void:
	var main_source := FileAccess.get_file_as_string("res://scenes/MainGame.gd")
	_expect(main_source.contains("btn.set_meta(\"demo_decision_card\", true)") \
		and main_source.contains("_apply_demo_decision_material(button, accent, palette)"),
		"demo AP pressure cards are not routed through the material pass")
	var packed := load(MAIN_GAME_PATH) as PackedScene
	_expect(packed != null, "MainGame fixture could not load")
	if packed == null:
		return
	var main := packed.instantiate()
	main.set("_moral_norm", 0.0)
	main.set("_moral_stage", 0)
	var palette: Dictionary = main.call("_moral_ui_palette")

	var choice := Button.new()
	main.call("_apply_moral_button_box", choice, Color("#a7adb5"), palette, true)
	_check_button_depth(choice, "MainGame choice")

	var choice_title := Label.new()
	choice_title.set_meta("moral_role", "choice_title")
	main.call("_apply_moral_control_style", choice_title, palette)
	_expect(_text_shadow_y(choice_title) == 1 and _text_shadow_outline(choice_title) == 0,
		"AP choice title lost its crisp 1px ink depth")

	var choice_body := Label.new()
	choice_body.set_meta("moral_role", "choice_subtitle")
	main.call("_apply_moral_control_style", choice_body, palette)
	_expect(_is_body_shadow_clear(choice_body), "AP choice explanation gained a shadow")

	var money := Label.new()
	main.call("_apply_money_label_style", money, Color.WHITE, Color(0, 0, 0, 0), 0)
	_expect(str(money.get_meta("ink_text_role", "")) == "money" and _text_shadow_y(money) == 1,
		"neutral money label lost its shallow material signal")
	main.call("_apply_money_label_style", money, Color("#ffd45a"), Color(1.0, 0.68, 0.12, 0.32), 2)
	_expect(str(money.get_meta("ink_text_role", "")) == "money_glow" \
		and _text_shadow_outline(money) == 1 and _text_shadow_y(money) == 0,
		"Deep Black money glow escaped the crisp 1px metallic treatment")

	var demo_card := _demo_material_fixture()
	main.call("_apply_moral_button_box", demo_card, Color("#a7adb5"), palette, true)
	_check_button_depth(demo_card, "Demo AP pressure card")
	demo_card.free()

	choice.free()
	choice_title.free()
	choice_body.free()
	money.free()
	main.free()

func _check_story_materials() -> void:
	LocaleManager.set_language("ko")
	AudioManager.sfx_enabled = false
	GameState.start_new_game()
	GameState.pending_story_queue = ["story_knee_witness"]
	GameState.story_return_scene = MAIN_GAME_PATH
	var packed := load(STORY_MODE_PATH) as PackedScene
	_expect(packed != null, "StoryMode fixture could not load")
	if packed == null:
		return
	var story := packed.instantiate()
	add_child(story)
	await get_tree().process_frame
	await get_tree().process_frame

	var title := story.get("_title_lbl") as Label
	var body := story.get("_body_lbl") as RichTextLabel
	_expect(title != null and _text_shadow_y(title) == 1 and _text_shadow_outline(title) == 0,
		"StoryMode scene title lost its crisp 1px depth")
	_expect(body != null and _is_body_shadow_clear(body),
		"StoryMode prose gained a shadow")

	var first_choice := story.call("_make_choice_button", "Face what happened", 0, 1) as Button
	_expect(first_choice != null, "StoryMode choice fixture did not expose a button")
	if first_choice != null:
		_check_button_depth(first_choice, "StoryMode choice")
		_expect(_text_shadow_y(first_choice) == 1 and _text_shadow_outline(first_choice) == 0,
			"StoryMode choice label lost its 1px ink depth")
		first_choice.free()

	story.call("_show_story_result_record", {"effects": {"money": 100000}, "cast_effects": {}})
	var result_card := story.get("_result_record_card") as PanelContainer
	_expect(result_card != null, "StoryMode choice result did not create a state card")
	if result_card != null:
		var result_style := result_card.get_theme_stylebox("panel") as StyleBoxFlat
		_expect(result_style != null and result_style.shadow_size == 1 \
			and result_style.shadow_offset == Vector2(0, 1),
			"StoryMode result card escaped the 1px material contract")
		var state_depth_count := 0
		for node in result_card.find_children("*", "Label", true, false):
			if str(node.get_meta("ink_text_role", "")) == "state":
				state_depth_count += 1
		_expect(state_depth_count >= 1, "StoryMode result values lost their state depth role")

	story.free()
	await get_tree().process_frame

func _demo_material_fixture() -> Button:
	var button := Button.new()
	button.set_meta("demo_decision_card", true)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("#0a0b0e")
		style.border_color = Color("#343a44")
		style.set_border_width_all(1)
		style.content_margin_top = 0
		style.content_margin_bottom = 0
		button.add_theme_stylebox_override(state, style)
	return button

func _check_button_depth(button: Button, label: String) -> void:
	var normal := button.get_theme_stylebox("normal") as StyleBoxFlat
	var hover := button.get_theme_stylebox("hover") as StyleBoxFlat
	var focus := button.get_theme_stylebox("focus") as StyleBoxFlat
	var pressed := button.get_theme_stylebox("pressed") as StyleBoxFlat
	for entry in [[normal, "normal"], [hover, "hover"], [focus, "focus"]]:
		var style := entry[0] as StyleBoxFlat
		_expect(style != null and style.shadow_size <= 2 and style.shadow_size > 0,
			"%s %s depth is outside 1..2px" % [label, entry[1]])
		_expect(style != null and style.shadow_offset.y <= 1.0,
			"%s %s shadow offset exceeds 1px" % [label, entry[1]])
	_expect(pressed != null and pressed.shadow_size == 0,
		"%s pressed state retained a floating shadow" % label)
	if normal != null and pressed != null:
		_expect(is_equal_approx(pressed.content_margin_top - normal.content_margin_top, 1.0),
			"%s pressed content does not travel exactly 1px" % label)

func _text_shadow_y(control: Control) -> int:
	return control.get_theme_constant("shadow_offset_y")

func _text_shadow_outline(control: Control) -> int:
	return control.get_theme_constant("shadow_outline_size")

func _is_body_shadow_clear(control: Control) -> bool:
	var color := control.get_theme_color("font_shadow_color")
	return color.a <= 0.001 and _text_shadow_y(control) == 0 \
		and _text_shadow_outline(control) == 0

func _stop_audio() -> void:
	for player_value in AudioManager.get("_pool"):
		var player := player_value as AudioStreamPlayer
		if player != null:
			player.stop()
			player.stream = null
	BGMPlayer.stop()
	for player_key in ["_player_a", "_player_b", "_ambience_player", "_season_player",
			"_human_ambience_player"]:
		var bgm_player := BGMPlayer.get(player_key) as AudioStreamPlayer
		if bgm_player != null:
			bgm_player.stop()
			bgm_player.stream = null
	await get_tree().process_frame
	await get_tree().create_timer(0.08).timeout
func _quit(exit_code: int) -> void:
	await get_tree().process_frame
	get_tree().quit(exit_code)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
