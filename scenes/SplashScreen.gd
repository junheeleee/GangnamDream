extends Control

const GangnamWordmarkScript := preload("res://scenes/ui/GangnamWordmark.gd")
const LivingSceneLayerScript := preload("res://scenes/ui/LivingSceneLayer.gd")

const NEXT_SCENE := "res://scenes/StartMenu.tscn"
const BRAND_SEQUENCE_SECONDS := 3.1
const LAUNCH_REQUIRED_INPUT_GATES := 0
const JUNPAC_LOGO_PATH := "res://assets/logos/junpac_games_logo_v2.png"
const JUNPAC_LOGO_REGION := Rect2(132.0, 300.0, 760.0, 360.0)
const JUNPAC_LOGO_DISPLAY_SIZE := Vector2(560.0, 265.0)

var _transitioning: bool = false
var _language_gate: Control = null
var _language_gate_active: bool = false
var _language_choice_locked: bool = false
var _language_buttons: Dictionary = {}
var _community_language_selector: OptionButton = null
var _force_language_gate_for_qa: bool = false
var _qa_disable_auto_transition: bool = false
var _qa_disable_auto_advance: bool = false
var _sequence_generation: int = 0
var _transition_request_count: int = 0

var _bg_img:     TextureRect
var _publisher_backdrop: ColorRect
var _publisher_logo: Control
var _wordmark: VBoxContainer
var _tagline_lbl: Label
var _context_lbl: Label
var _press_lbl:  Label
var _living_scene: LivingSceneLayer

var _font: FontFile
var _font_bold: FontFile

func _load_fonts():
	_font      = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile
	FontKit.attach_emoji_fallback(_font)
	FontKit.attach_emoji_fallback(_font_bold)

func _apply_font(lbl: Label, bold: bool = false):
	var f = _font_bold if bold else _font
	if f:
		lbl.add_theme_font_override("font", f)

func _ready():
	_load_fonts()
	var saved_language := str(SaveManager.get_setting("language", ""))
	if saved_language in LocaleManager.get_selectable_languages():
		LocaleManager.set_language(saved_language)
	SceneTransition.fade_in()
	if _force_language_gate_for_qa or saved_language not in LocaleManager.get_selectable_languages() \
			or not bool(SaveManager.get_setting("language_gate_seen", false)):
		_build_language_gate(saved_language)
		return
	_begin_brand_sequence()

func _begin_brand_sequence() -> void:
	_build_ui()
	set_meta("launch_stage", "publisher")
	set_meta("launch_required_input_gates", LAUNCH_REQUIRED_INPUT_GATES)
	set_meta("launch_next_scene", NEXT_SCENE)
	_run_sequence()

func _build_language_gate(saved_language: String = "") -> void:
	_language_gate_active = true
	_language_choice_locked = false
	_language_buttons.clear()
	_community_language_selector = null

	_language_gate = Control.new()
	_language_gate.set_anchors_preset(Control.PRESET_FULL_RECT)
	_language_gate.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_language_gate)

	var black := ColorRect.new()
	black.set_anchors_preset(Control.PRESET_FULL_RECT)
	black.color = Color("#050608")
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_language_gate.add_child(black)

	var keyart := TextureRect.new()
	keyart.set_anchors_preset(Control.PRESET_FULL_RECT)
	keyart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	keyart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	keyart.modulate = Color(0.34, 0.36, 0.40, 0.14)
	keyart.mouse_filter = Control.MOUSE_FILTER_IGNORE
	keyart.texture = load("res://assets/keyart/gangnam_dream_keyart_cast_v1.png")
	_language_gate.add_child(keyart)

	var shade := ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.0, 0.0, 0.0, 0.58)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_language_gate.add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.offset_left = 32
	center.offset_right = -32
	center.offset_top = 32
	center.offset_bottom = -32
	_language_gate.add_child(center)

	var panel := PanelContainer.new()
	var community_languages := LocaleManager.get_selectable_languages().filter(
		func(code: String): return code not in ["ko", "en"])
	panel.custom_minimum_size = Vector2(670, 420 if not community_languages.is_empty() else 330)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#0a0c11", 0.96)
	panel_style.border_color = Color("#343b46")
	panel_style.set_border_width_all(1)
	panel_style.border_width_top = 3
	panel_style.set_corner_radius_all(6)
	panel_style.content_margin_left = 46
	panel_style.content_margin_right = 46
	panel_style.content_margin_top = 38
	panel_style.content_margin_bottom = 34
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 14)
	panel.add_child(content)

	var eyebrow := Label.new()
	eyebrow.text = "FIRST SETUP"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow.add_theme_font_size_override("font_size", 11)
	eyebrow.add_theme_color_override("font_color", Color("#7c8795"))
	_apply_font(eyebrow, true)
	content.add_child(eyebrow)

	var title := Label.new()
	title.text = "LANGUAGE  /  언어"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("#eef2f6"))
	_apply_font(title, true)
	content.add_child(title)

	var instruction := Label.new()
	instruction.text = "게임에서 사용할 언어를 선택하세요.\nChoose the language used in the game."
	instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instruction.add_theme_font_size_override("font_size", 15)
	instruction.add_theme_color_override("font_color", Color("#a6afbb"))
	instruction.add_theme_constant_override("line_spacing", 5)
	_apply_font(instruction)
	content.add_child(instruction)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 6)
	content.add_child(spacer)

	var choices := HBoxContainer.new()
	choices.alignment = BoxContainer.ALIGNMENT_CENTER
	choices.add_theme_constant_override("separation", 14)
	content.add_child(choices)

	var korean := _language_choice_button("한국어", "KO")
	var english := _language_choice_button("English", "EN")
	korean.pressed.connect(_select_language.bind("ko"))
	english.pressed.connect(_select_language.bind("en"))
	choices.add_child(korean)
	choices.add_child(english)
	_language_buttons = {"ko": korean, "en": english}

	if not community_languages.is_empty():
		var community_row := HBoxContainer.new()
		community_row.alignment = BoxContainer.ALIGNMENT_CENTER
		community_row.add_theme_constant_override("separation", 10)
		content.add_child(community_row)
		var community_label := Label.new()
		community_label.text = "COMMUNITY"
		community_label.add_theme_font_size_override("font_size", 11)
		community_label.add_theme_color_override("font_color", Color("#7c8795"))
		_apply_font(community_label, true)
		community_row.add_child(community_label)
		_community_language_selector = OptionButton.new()
		_community_language_selector.custom_minimum_size = Vector2(230, 42)
		for code in community_languages:
			var index := _community_language_selector.item_count
			_community_language_selector.add_item(LocaleManager.get_language_display_name(code))
			_community_language_selector.set_item_metadata(index, code)
			if code == saved_language:
				_community_language_selector.select(index)
		community_row.add_child(_community_language_selector)
		var use_button := Button.new()
		use_button.text = "USE"
		use_button.custom_minimum_size = Vector2(82, 42)
		use_button.pressed.connect(_select_community_language)
		community_row.add_child(use_button)

	var note := Label.new()
	note.text = "설정에서 언제든 변경할 수 있습니다.  /  You can change this later in Settings."
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.add_theme_font_size_override("font_size", 11)
	note.add_theme_color_override("font_color", Color("#68727f"))
	_apply_font(note)
	content.add_child(note)

	var preferred := saved_language
	if preferred not in LocaleManager.get_selectable_languages():
		preferred = "ko" if TranslationServer.get_locale().to_lower().begins_with("ko") else "en"
	call_deferred("_focus_language_button", preferred)

func _language_choice_button(label_text: String, code: String) -> Button:
	var button := Button.new()
	button.text = "%s\n%s" % [label_text, code]
	button.custom_minimum_size = Vector2(250, 74)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color("#d9dfe7"))
	button.add_theme_color_override("font_hover_color", Color("#ffffff"))
	button.add_theme_color_override("font_focus_color", Color("#ffffff"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#11151c")
	normal.border_color = Color("#303744")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(5)
	var hover := normal.duplicate()
	hover.bg_color = Color("#191f28")
	hover.border_color = Color("#8d99a8")
	var focus := normal.duplicate()
	focus.bg_color = Color("#171c24")
	focus.border_color = Color("#eef2f6")
	focus.set_border_width_all(2)
	var pressed := focus.duplicate()
	pressed.bg_color = Color("#0d1016")
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_stylebox_override("pressed", pressed)
	return button

func _focus_language_button(lang: String) -> void:
	var button: Button = _language_buttons.get(lang) as Button
	if button != null and is_instance_valid(button):
		button.grab_focus()
	elif is_instance_valid(_community_language_selector):
		_community_language_selector.grab_focus()

func _select_community_language() -> void:
	if not is_instance_valid(_community_language_selector) or _community_language_selector.item_count == 0:
		return
	var index := _community_language_selector.selected
	_select_language(str(_community_language_selector.get_item_metadata(index)))

func _select_language(lang: String) -> void:
	if _language_choice_locked or lang not in LocaleManager.get_selectable_languages():
		return
	_language_choice_locked = true
	LocaleManager.set_language(lang)
	SaveManager.set_setting("language_gate_seen", true)
	for raw_button in _language_buttons.values():
		var button := raw_button as Button
		if button != null:
			button.disabled = true
	var tween := create_tween()
	tween.tween_property(_language_gate, "modulate:a", 0.0, 0.22).set_trans(Tween.TRANS_SINE)
	await tween.finished
	if is_instance_valid(_language_gate):
		_language_gate.queue_free()
	await get_tree().process_frame
	_language_gate = null
	_language_gate_active = false
	if _force_language_gate_for_qa:
		return
	_begin_brand_sequence()

# ── UI 구성 ──────────────────────────────────────────────────────────────
func _build_ui():
	# 1. 검정 베이스
	var bg = ColorRect.new()
	bg.color = Color("#000000")
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# 2. 키아트 배경 (시작 시 투명)
	_bg_img = TextureRect.new()
	_bg_img.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg_img.stretch_mode = TextureRect.STRETCH_SCALE
	_bg_img.expand_mode  = TextureRect.EXPAND_IGNORE_SIZE
	_bg_img.modulate     = Color(1, 1, 1, 0.0)
	_bg_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bg_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	var keyart = load("res://assets/keyart/gangnam_dream_keyart_cast_v1.png")
	if keyart:
		_bg_img.texture = keyart
	add_child(_bg_img)

	_living_scene = LivingSceneLayerScript.new()
	_living_scene.name = "LaunchAtmosphere"
	add_child(_living_scene)
	_living_scene.configure(
		{
			"id": "launch_title",
			"living_scene": {"effect": "city_light", "intensity": 0.11},
		},
		"gangnam_night_street",
		"",
		{"channel": "memory", "portrait_role": "none"},
		0.0,
		false,
		_reduced_motion())

	# 3. The painting already owns its left safe area; this only keeps the
	# publisher and wordmark readable without burying the cast.
	var overlay = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color        = Color(0.0, 0.0, 0.0, 0.30)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

	# 4. The approved navy JUNPAC wordmark owns a pure-white publisher card.
	# This must sit above every dark title-grade layer so white stays white.
	_publisher_backdrop = ColorRect.new()
	_publisher_backdrop.name = "PublisherBackdrop"
	_publisher_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	_publisher_backdrop.color = Color("#ffffff")
	_publisher_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_publisher_backdrop)

	# 5. The publisher pre-roll is an overlay, never a layout spacer that moves
	# the title after it fades.
	var publisher_center := CenterContainer.new()
	publisher_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	publisher_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(publisher_center)
	_publisher_logo = _build_junpac_logo()
	publisher_center.add_child(_publisher_logo)

	# 6. Shared poster lockup in the art's reserved left third.
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 58)
	margin.add_theme_constant_override("margin_right", 58)
	margin.add_theme_constant_override("margin_top", 52)
	margin.add_theme_constant_override("margin_bottom", 58)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)

	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(410, 0)
	column.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)

	var upper_spacer := Control.new()
	upper_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(upper_spacer)

	_wordmark = GangnamWordmarkScript.new(68,
		"GANGNAM DREAM" if not LocaleManager.is_english() else "A KOREAN SOCIAL-REALITY DRAMA")
	_wordmark.modulate = Color(1, 1, 1, 0.0)
	column.add_child(_wordmark)

	_tagline_lbl = Label.new()
	_tagline_lbl.text = LocaleManager.ui("통장 50만원. 남은 시간 5년.", "KRW 500K. Five years left.")
	_tagline_lbl.add_theme_font_size_override("font_size", 17)
	_tagline_lbl.add_theme_color_override("font_color", Color("#aab2bc"))
	_tagline_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_tagline_lbl.modulate = Color(1, 1, 1, 0.0)
	_apply_font(_tagline_lbl, true)
	column.add_child(_tagline_lbl)

	_context_lbl = Label.new()
	_context_lbl.text = LocaleManager.ui("서울, 2026. 정답도 보장도 없다.", "Seoul, 2026. No guarantees.")
	_context_lbl.add_theme_font_size_override("font_size", 13)
	_context_lbl.add_theme_color_override("font_color", Color("#687381"))
	_context_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_context_lbl.modulate = Color(1, 1, 1, 0.0)
	_apply_font(_context_lbl)
	column.add_child(_context_lbl)

	var lower_spacer := Control.new()
	lower_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(lower_spacer)

	# The splash has no input prompt. StartMenu owns the launch flow's only gate.
	# Do not allocate a detached Label here; an orphaned Control leaks its font RID.

func _build_junpac_logo() -> Control:
	var mark := TextureRect.new()
	mark.name = "JunpacLogo"
	mark.custom_minimum_size = JUNPAC_LOGO_DISPLAY_SIZE
	mark.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	mark.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	mark.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mark.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var source := load(JUNPAC_LOGO_PATH) as Texture2D
	if source != null:
		var crop := AtlasTexture.new()
		crop.atlas = source
		crop.region = JUNPAC_LOGO_REGION
		mark.texture = crop
	mark.set_meta("publisher_mark_kind", "image_asset")
	mark.set_meta("publisher_mark_transparent", true)
	mark.set_meta("publisher_mark_source", JUNPAC_LOGO_PATH)
	mark.modulate = Color(1, 1, 1, 0.0)
	return mark

# ── 애니메이션 시퀀스 ──────────────────────────────────────────────────
func _run_sequence():
	_sequence_generation += 1
	var generation := _sequence_generation
	# A quiet owned sting and the approved transparent wordmark open the game.
	AudioManager.play("publisher_sting")
	set_meta("publisher_sting_play_count", 1)
	_fade_in(_publisher_logo, 0.42)
	await get_tree().create_timer(1.15).timeout
	if generation != _sequence_generation or _transitioning:
		return
	_fade_out(_publisher_logo, 0.28)
	_fade_out(_publisher_backdrop, 0.28)
	await get_tree().create_timer(0.28).timeout
	if generation != _sequence_generation or _transitioning:
		return

	set_meta("launch_stage", "title")
	_fade_in(_bg_img, 0.55, 0.68)

	await get_tree().create_timer(0.18).timeout
	if generation != _sequence_generation or _transitioning:
		return
	_fade_in(_wordmark, 0.45)

	await get_tree().create_timer(0.30).timeout
	if generation != _sequence_generation or _transitioning:
		return
	_fade_in(_tagline_lbl, 0.35)

	await get_tree().create_timer(0.25).timeout
	if generation != _sequence_generation or _transitioning:
		return
	_fade_in(_context_lbl, 0.35)

	await get_tree().create_timer(0.65).timeout
	if generation != _sequence_generation or _transitioning:
		return
	set_meta("launch_stage", "title_complete")
	if _qa_disable_auto_advance:
		return
	_go_to_start()

func _fade_in(node: Control, duration: float, target_alpha: float = 1.0):
	var tw = create_tween()
	tw.tween_property(node, "modulate", Color(1, 1, 1, target_alpha), duration)

func _fade_out(node: Control, duration: float):
	var tw = create_tween()
	tw.tween_property(node, "modulate", Color(1, 1, 1, 0.0), duration)

# ── 전환 ─────────────────────────────────────────────────────────────────
func _go_to_start():
	if _transitioning:
		return
	if _qa_disable_auto_transition:
		return
	_transitioning = true
	_sequence_generation += 1
	_transition_request_count += 1
	set_meta("launch_stage", "leaving")
	set_meta("launch_transition_requests", _transition_request_count)
	if _qa_disable_auto_advance:
		return
	SceneTransition.go(NEXT_SCENE)

func _reduced_motion() -> bool:
	return bool(SaveManager.get_setting(
		"reduce_motion", SaveManager.get_setting("reduced_motion", false)))

func _input(event):
	if _transitioning:
		return
	if _language_gate_active:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		_go_to_start()
	elif event is InputEventMouseButton and event.pressed:
		_go_to_start()
	elif event is InputEventJoypadButton and event.pressed:
		_go_to_start()
