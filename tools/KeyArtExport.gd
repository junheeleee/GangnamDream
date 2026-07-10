extends Control

const WordmarkScript := preload("res://scenes/ui/GangnamWordmark.gd")
const KEY_ART := preload("res://assets/keyart/gangnam_dream_keyart_cast_v1.png")

const SPECS := {
	"main": {
		"size": Vector2i(616, 353),
		"path": "res://assets/keyart/steam_capsule_main_v2.png",
		"font_size": 27,
		"subtitle": "A KOREAN SOCIAL-REALITY DRAMA",
	},
	"header": {
		"size": Vector2i(460, 215),
		"path": "res://assets/keyart/steam_header_v2.png",
		"font_size": 21,
		"subtitle": "SEOUL SOCIAL-REALITY DRAMA",
	},
	"small": {
		"size": Vector2i(231, 87),
		"path": "res://assets/keyart/steam_capsule_small_v2.png",
		"font_size": 11,
		"subtitle": "",
	},
}


func _ready() -> void:
	LocaleManager.language = "en"
	var spec_id := _read_spec_id()
	if not SPECS.has(spec_id):
		push_error("Unknown key-art export spec: %s" % spec_id)
		get_tree().quit(2)
		return

	var spec: Dictionary = SPECS[spec_id]
	var expected_size: Vector2i = spec["size"]
	var export_viewport := SubViewport.new()
	export_viewport.size = expected_size
	export_viewport.disable_3d = true
	export_viewport.transparent_bg = false
	export_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(export_viewport)

	var surface := Control.new()
	surface.set_anchors_preset(Control.PRESET_FULL_RECT)
	surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	export_viewport.add_child(surface)
	_build_surface(surface, spec, expected_size)
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw

	var image := export_viewport.get_texture().get_image()
	var output_path := ProjectSettings.globalize_path(str(spec["path"]))
	var err := image.save_png(output_path)
	if err != OK:
		push_error("Failed to save key-art export: %s" % output_path)
		get_tree().quit(4)
		return
	print("KEY_ART_EXPORT_OK spec=%s size=%dx%d path=%s" % [
		spec_id, image.get_width(), image.get_height(), output_path])
	get_tree().quit()


func _read_spec_id() -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--spec="):
			return arg.trim_prefix("--spec=")
	return "main"


func _build_surface(parent: Control, spec: Dictionary, output_size: Vector2i) -> void:
	var base := ColorRect.new()
	base.color = Color("#08090c")
	base.set_anchors_preset(Control.PRESET_FULL_RECT)
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(base)

	var art := TextureRect.new()
	art.texture = KEY_ART
	art.set_anchors_preset(Control.PRESET_FULL_RECT)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(art)

	var scrim := TextureRect.new()
	scrim.texture = _scrim_texture()
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	scrim.stretch_mode = TextureRect.STRETCH_SCALE
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(scrim)

	var title_safe := CenterContainer.new()
	title_safe.anchor_left = 0.0
	title_safe.anchor_right = 0.34
	title_safe.anchor_top = 0.0
	title_safe.anchor_bottom = 1.0
	title_safe.offset_left = maxi(6, int(output_size.x * 0.025))
	title_safe.offset_right = -maxi(3, int(output_size.x * 0.012))
	title_safe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(title_safe)

	var wordmark: VBoxContainer = WordmarkScript.new(
		int(spec["font_size"]), str(spec["subtitle"]))
	title_safe.add_child(wordmark)


func _scrim_texture() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.25, 0.42, 1.0])
	gradient.colors = PackedColorArray([
		Color(0.012, 0.014, 0.018, 0.68),
		Color(0.012, 0.014, 0.018, 0.40),
		Color(0.012, 0.014, 0.018, 0.05),
		Color(0.012, 0.014, 0.018, 0.0),
	])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 512
	texture.height = 8
	texture.fill_from = Vector2(0.0, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	return texture
