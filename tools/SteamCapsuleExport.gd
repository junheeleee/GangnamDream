extends Control
## Tool-only native layout. The wrapper owns clean source, storage and admission.
## Reuse the approved master/wordmark; never overwrite legacy asset proofs.

const WordmarkScript := preload("res://scenes/ui/GangnamWordmark.gd")
const CONTRACT_PATH := "res://tools/steam_capsules.json"


func _ready() -> void:
	var namespace := OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	var pattern := RegEx.new()
	if pattern.compile("^GangnamDream_StoryNameplateQA_[0-9a-f]{32}$") != OK \
			or pattern.search(namespace) == null \
			or OS.get_user_data_dir().get_file() != namespace:
		_fail("pre-autoload isolated namespace required")
		return
	var output := OS.get_environment("GANGNAM_QA_OUT")
	if not output.is_absolute_path() or output.simplify_path() != output \
			or output.begins_with(ProjectSettings.globalize_path("res://")) \
			or not DirAccess.dir_exists_absolute(output):
		_fail("fresh external output directory required")
		return
	var contract: Variant = JSON.parse_string(FileAccess.get_file_as_string(CONTRACT_PATH))
	if typeof(contract) != TYPE_DICTIONARY or contract.get("schema_version") != 1 \
			or typeof(contract.get("capsules")) != TYPE_ARRAY \
			or contract["capsules"].size() != 4:
		_fail("capsule contract refused")
		return
	var master_path := "res://" + str(contract["master"]["file"])
	if FileAccess.get_sha256(master_path) != str(contract["master"]["sha256"]):
		_fail("approved master hash mismatch")
		return
	var master := load(master_path) as Texture2D
	if master == null or master.get_size() != Vector2(1920, 1080):
		_fail("approved master texture missing or wrong size")
		return
	LocaleManager.language = "en"
	var ids := ["main", "header", "small", "vertical"]
	var dimensions := [Vector2i(1232, 706), Vector2i(920, 430),
		Vector2i(462, 174), Vector2i(748, 896)]
	for index in ids.size():
		var spec: Dictionary = contract["capsules"][index]
		var expected: Vector2i = dimensions[index]
		var file := str(spec.get("file", ""))
		var target := output.path_join(file)
		if str(spec.get("id")) != ids[index] or file.get_file() != file \
				or not file.ends_with(".png") or FileAccess.file_exists(target) \
				or Vector2i(int(spec["size"][0]), int(spec["size"][1])) != expected:
			_fail("capsule output contract mismatch or existing file")
			return
		var viewport := SubViewport.new()
		viewport.size = expected
		viewport.disable_3d = true
		viewport.transparent_bg = false
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		add_child(viewport)
		var surface := Control.new()
		surface.size = Vector2(expected)
		surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
		viewport.add_child(surface)
		_build_surface(surface, master, spec, expected)
		await get_tree().process_frame
		await get_tree().process_frame
		var title := surface.get_node("CapsuleTitle") as CenterContainer
		var wordmark := title.get_child(0) as Control
		var required := wordmark.get_combined_minimum_size()
		var declared := _rect(spec["title_rect"]).size
		if required.x > declared.x or required.y > declared.y:
			_fail("title overflows declared face-safe rectangle: " + ids[index])
			return
		await RenderingServer.frame_post_draw
		var image := viewport.get_texture().get_image()
		if image == null or image.get_size() != expected or image.save_png(target) != OK:
			_fail("capsule render/save failed: " + ids[index])
			return
		viewport.queue_free()
		await get_tree().process_frame
	print("STEAM_CAPSULE_EXPORT_DONE count=4 dir=%s" % output)
	get_tree().quit(0)


func _rect(values: Array) -> Rect2:
	return Rect2(float(values[0]), float(values[1]), float(values[2]), float(values[3]))


func _build_surface(parent: Control, master: Texture2D, spec: Dictionary,
		output_size: Vector2i) -> void:
	var base := ColorRect.new()
	base.color = Color("#08090c")
	base.size = Vector2(output_size)
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(base)
	var region := AtlasTexture.new()
	region.atlas = master
	region.region = _rect(spec["source_crop"])
	var art := TextureRect.new()
	art.texture = region
	art.position = _rect(spec["art_rect"]).position
	art.size = _rect(spec["art_rect"]).size
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(art)
	if str(spec["id"]) in ["main", "header"]:
		var scrim := TextureRect.new()
		scrim.texture = _scrim_texture()
		scrim.size = Vector2(output_size)
		scrim.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		scrim.stretch_mode = TextureRect.STRETCH_SCALE
		scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(scrim)
	var title_safe := CenterContainer.new()
	title_safe.name = "CapsuleTitle"
	title_safe.position = _rect(spec["title_rect"]).position
	title_safe.size = _rect(spec["title_rect"]).size
	title_safe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(title_safe)
	# Empty subtitle is intentional: Steam capsules contain the game title only.
	var wordmark: VBoxContainer = WordmarkScript.new(int(spec["font_size"]), "")
	title_safe.add_child(wordmark)


func _scrim_texture() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.25, 0.42, 1.0])
	gradient.colors = PackedColorArray([
		Color(0.012, 0.014, 0.018, 0.68), Color(0.012, 0.014, 0.018, 0.40),
		Color(0.012, 0.014, 0.018, 0.05), Color(0.012, 0.014, 0.018, 0.0),
	])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 512
	texture.height = 8
	texture.fill_from = Vector2(0.0, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	return texture


func _fail(message: String) -> void:
	push_error("STEAM_CAPSULE_EXPORT_FAIL " + message)
	get_tree().quit(2)
