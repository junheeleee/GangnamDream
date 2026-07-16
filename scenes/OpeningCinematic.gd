extends Control
## Three-beat, full-bleed motion-comic prologue.
## It plays only after New Story, never blocks on a final card, and any input
## skips the complete prologue directly into the first playable week.

const LivingSceneLayerScript := preload("res://scenes/ui/LivingSceneLayer.gd")

const NEXT_SCENE := "res://scenes/MainGame.tscn"
const OPENING_REQUIRED_INPUT_GATES := 0
const OPENING_MAX_SECONDS := 14.0
const FADE_SECONDS := 0.52

const BEATS: Array[Dictionary] = [
	{
		"image": "res://assets/backgrounds/gangnam_night_street.png",
		"effect": "city_light",
		"intensity": 0.14,
		"ambience": "street",
		"hold": 3.10,
		"title_ko": "2026년, 서울.",
		"body_ko": "강남. 부와 지위가 주소가 되는 곳.\n아파트 한 채, 30억원.",
		"title_en": "2026. Seoul.",
		"body_en": "Gangnam. Where wealth becomes status.\nOne apartment: KRW 3 billion.",
		"desaturation": 0.24,
		"brightness": 0.78,
	},
	{
		"image": "res://assets/backgrounds/goshiwon_room.png",
		"effect": "memory",
		"intensity": 0.10,
		"ambience": "room",
		"hold": 3.10,
		"title_ko": "김민준, 서른셋.",
		"body_ko": "통장 50만원. 월세 65만원짜리 고시원.",
		"title_en": "Kim Minjun, 33.",
		"body_en": "Bank balance: KRW 500K.\nA goshiwon room costs KRW 650K a month.",
		"desaturation": 0.34,
		"brightness": 0.74,
	},
	{
		"image": "res://assets/backgrounds/gangnam_apartment.png",
		"effect": "city_light",
		"intensity": 0.09,
		"ambience": "street",
		"hold": 3.00,
		"title_ko": "목표 30억원. 남은 시간은 5년.",
		"body_ko": "첫 주가 시작된다.",
		"title_en": "KRW 3 billion. Five years left.",
		"body_en": "The first week begins.",
		"desaturation": 0.18,
		"brightness": 0.82,
	},
]

var _transitioning := false
var _sequence_generation := 0
var _reduced_motion := false
var _accept_input_after_ms := 0
var _current_image: TextureRect = null
var _visual_frame: Control
var _living_scene: LivingSceneLayer
var _title_label: Label
var _body_label: Label
var _beat_rule: ColorRect
var _font: FontFile
var _font_bold: FontFile

# Runtime check hook: tests may inspect a fully built first beat without timers.
var _qa_disable_autoplay := false
var _qa_force_reduced_motion := false
var _qa_suppress_transition := false
var _transition_request_count := 0

func _ready() -> void:
	_font = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile
	FontKit.attach_emoji_fallback(_font)
	FontKit.attach_emoji_fallback(_font_bold)
	_reduced_motion = _qa_force_reduced_motion or bool(SaveManager.get_setting(
		"reduce_motion", SaveManager.get_setting("reduced_motion", false)))
	_build_ui()
	set_meta("opening_beat_count", BEATS.size())
	set_meta("opening_max_seconds", OPENING_MAX_SECONDS)
	set_meta("opening_required_input_gates", OPENING_REQUIRED_INPUT_GATES)
	set_meta("opening_skip_target", NEXT_SCENE)
	set_meta("opening_reduced_motion", _reduced_motion)
	set_meta("opening_camera_motion", not _reduced_motion)
	set_meta("opening_transition_requests", 0)
	_accept_input_after_ms = Time.get_ticks_msec() + 220
	SceneTransition.fade_in()
	BGMPlayer.enter_ambient_bed(0.55)
	if _qa_disable_autoplay:
		_show_beat(0, false)
		return
	_play_sequence()

func _build_ui() -> void:
	var base := ColorRect.new()
	base.name = "InkBase"
	base.color = Color("#050609")
	base.set_anchors_preset(Control.PRESET_FULL_RECT)
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(base)

	_visual_frame = Control.new()
	_visual_frame.name = "OpeningVisualFrame"
	_visual_frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	_visual_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_visual_frame)

	_living_scene = LivingSceneLayerScript.new()
	_living_scene.name = "OpeningAtmosphere"
	add_child(_living_scene)

	var scrim := TextureRect.new()
	scrim.name = "OpeningScrim"
	scrim.texture = _scrim_texture()
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	scrim.stretch_mode = TextureRect.STRETCH_SCALE
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(scrim)

	var safe_margin := MarginContainer.new()
	safe_margin.name = "OpeningSafeArea"
	safe_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	safe_margin.add_theme_constant_override("margin_left", 72)
	safe_margin.add_theme_constant_override("margin_right", 72)
	safe_margin.add_theme_constant_override("margin_top", 58)
	safe_margin.add_theme_constant_override("margin_bottom", 68)
	safe_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(safe_margin)

	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(610, 0)
	column.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	column.add_theme_constant_override("separation", 12)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	safe_margin.add_child(column)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)

	_beat_rule = ColorRect.new()
	_beat_rule.custom_minimum_size = Vector2(48, 3)
	_beat_rule.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_beat_rule.color = Color("#dce3ea", 0.72)
	_beat_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(_beat_rule)

	_title_label = Label.new()
	_title_label.name = "OpeningTitle"
	_title_label.custom_minimum_size = Vector2(610, 0)
	_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title_label.add_theme_font_size_override("font_size", 36)
	_title_label.add_theme_color_override("font_color", Color("#f1f3f5"))
	if _font_bold:
		_title_label.add_theme_font_override("font", _font_bold)
	column.add_child(_title_label)

	_body_label = Label.new()
	_body_label.name = "OpeningBody"
	_body_label.custom_minimum_size = Vector2(610, 0)
	_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body_label.add_theme_font_size_override("font_size", 19)
	_body_label.add_theme_color_override("font_color", Color("#bcc3cb"))
	_body_label.add_theme_constant_override("line_spacing", 6)
	if _font:
		_body_label.add_theme_font_override("font", _font)
	column.add_child(_body_label)

func _play_sequence() -> void:
	_sequence_generation += 1
	var generation := _sequence_generation
	for index in range(BEATS.size()):
		await _show_beat(index, true)
		if _transitioning or generation != _sequence_generation:
			return
		await get_tree().create_timer(float(BEATS[index]["hold"])).timeout
		if _transitioning or generation != _sequence_generation:
			return
	_finish_opening()

func _show_beat(index: int, animate: bool = true) -> void:
	if index < 0 or index >= BEATS.size():
		return
	var beat: Dictionary = BEATS[index]
	set_meta("opening_beat_index", index)
	var next_image := TextureRect.new()
	next_image.name = "OpeningImage%d" % (index + 1)
	next_image.texture = load(str(beat["image"]))
	next_image.set_anchors_preset(Control.PRESET_FULL_RECT)
	next_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	next_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	next_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	next_image.modulate = Color(1, 1, 1, 0.0 if animate else 1.0)
	next_image.material = _grade_material(
		float(beat["desaturation"]), float(beat["brightness"]), float(index + 11))
	_visual_frame.add_child(next_image)
	await get_tree().process_frame
	next_image.pivot_offset = next_image.size * 0.5
	next_image.scale = Vector2.ONE if _reduced_motion else Vector2(1.045, 1.045)

	var old_image := _current_image
	_current_image = next_image
	_title_label.text = _localized(beat, "title")
	_body_label.text = _localized(beat, "body")
	_title_label.modulate.a = 0.0 if animate else 1.0
	_body_label.modulate.a = 0.0 if animate else 1.0
	_beat_rule.modulate.a = 0.0 if animate else 1.0
	BGMPlayer.set_ambience(str(beat["ambience"]))
	_living_scene.configure(
		{
			"id": "opening_beat_%d" % (index + 1),
			"living_scene": {
				"effect": str(beat["effect"]),
				"intensity": float(beat["intensity"]),
			},
		},
		str(beat["image"]).get_file().get_basename(),
		"",
		{"channel": "memory", "portrait_role": "none"},
		0.0,
		false,
		_reduced_motion)

	if not animate:
		return
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(next_image, "modulate:a", 1.0, FADE_SECONDS)
	tween.tween_property(_title_label, "modulate:a", 1.0, FADE_SECONDS * 0.85)
	tween.tween_property(_body_label, "modulate:a", 1.0, FADE_SECONDS)
	tween.tween_property(_beat_rule, "modulate:a", 1.0, FADE_SECONDS * 0.75)
	if not _reduced_motion:
		var camera_tween := next_image.create_tween()
		camera_tween.set_trans(Tween.TRANS_SINE)
		camera_tween.set_ease(Tween.EASE_OUT)
		camera_tween.tween_property(
			next_image, "scale", Vector2.ONE, float(beat["hold"]) + FADE_SECONDS)
	if is_instance_valid(old_image):
		tween.tween_property(old_image, "modulate:a", 0.0, FADE_SECONDS)
	await tween.finished
	if is_instance_valid(old_image):
		old_image.queue_free()

func _localized(beat: Dictionary, field: String) -> String:
	return str(beat["%s_en" % field] if LocaleManager.is_english() else beat["%s_ko" % field])

func _grade_material(desaturation: float, brightness: float, seed: float) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = load("res://assets/shaders/background_grade.gdshader") as Shader
	material.set_shader_parameter("desaturation", desaturation)
	material.set_shader_parameter("brightness", brightness)
	material.set_shader_parameter("contrast", 0.98)
	material.set_shader_parameter("grain_amount", 0.018)
	material.set_shader_parameter("ink_bleed", 0.045)
	material.set_shader_parameter("paper_fade", 0.012)
	material.set_shader_parameter("edge_burn", 0.15)
	material.set_shader_parameter("print_screen", 0.010)
	material.set_shader_parameter("seed", seed)
	return material

func _scrim_texture() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.22, 0.52, 1.0])
	gradient.colors = PackedColorArray([
		Color(0.01, 0.012, 0.016, 0.88),
		Color(0.01, 0.012, 0.016, 0.58),
		Color(0.01, 0.012, 0.016, 0.12),
		Color(0.01, 0.012, 0.016, 0.18),
	])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 1280
	texture.height = 8
	texture.fill_from = Vector2(0.0, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	return texture

func _input(event: InputEvent) -> void:
	if _transitioning or Time.get_ticks_msec() < _accept_input_after_ms:
		return
	var pressed := false
	if event is InputEventKey and event.pressed and not event.echo:
		pressed = true
	elif event is InputEventMouseButton and event.pressed:
		pressed = true
	elif event is InputEventJoypadButton and event.pressed:
		pressed = true
	if pressed:
		get_viewport().set_input_as_handled()
		_finish_opening()

func _finish_opening() -> void:
	if _transitioning:
		return
	_transitioning = true
	_sequence_generation += 1
	_transition_request_count += 1
	set_meta("opening_transition_requests", _transition_request_count)
	if _qa_suppress_transition:
		return
	SceneTransition.go(NEXT_SCENE)
