extends Node
## CGRuntimeCheck — verifies that event/endings "cg" keys reach runtime UI.
##
## Run:
##   /Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot --headless res://tools/CGRuntimeCheck.tscn

var _failures: Array[String] = []

func _ready() -> void:
	await _check_story_mode_cg()
	await _check_ending_cg()
	if _failures.is_empty():
		print("CG_RUNTIME_CHECK_OK")
		get_tree().quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		get_tree().quit(1)

func _check_story_mode_cg() -> void:
	var expected_path := ImageRegistry.get_cg("cg_jiyeon_crash")
	if expected_path == "":
		_failures.append("missing cg_jiyeon_crash")
		return

	GameState.pending_story_queue = ["arc_jiyeon_01_crash"]
	var story_scene := load("res://scenes/StoryMode.tscn") as PackedScene
	var story: Node = story_scene.instantiate()
	add_child(story)
	await get_tree().process_frame
	await get_tree().process_frame

	var bg_img := story.get("_bg_img") as TextureRect
	if bg_img == null or bg_img.texture == null:
		_failures.append("StoryMode did not assign a background texture for cg event")
	elif bg_img.texture.resource_path != expected_path:
		_failures.append("StoryMode cg mismatch: expected %s, got %s" % [expected_path, bg_img.texture.resource_path])

	var portrait_frame := story.get("_portrait_frame") as Control
	if portrait_frame != null and portrait_frame.visible:
		_failures.append("StoryMode should hide portrait frame when a cg is active")

	remove_child(story)
	story.queue_free()

func _check_ending_cg() -> void:
	var synthetic_path := ImageRegistry.get_cg("cg_ending_father")
	if synthetic_path == "":
		_failures.append("missing cg_ending_father")
		return

	var main_script: GDScript = load("res://scenes/MainGame.gd") as GDScript
	var main: Node = main_script.new()
	var grade_material := ShaderMaterial.new()
	grade_material.shader = load("res://assets/shaders/background_grade.gdshader") as Shader
	main.set("_moral_bg_material", grade_material)
	var actual_path := str(main.call("_get_ending_cg_path", {"cg": "cg_ending_father"}))
	if actual_path != synthetic_path:
		_failures.append("MainGame synthetic ending cg path mismatch: expected %s, got %s" % [synthetic_path, actual_path])

	_check_ending_cg_path(main, "gangnam_dream", "cg_ending_gangnam_dream")
	_check_ending_cg_path(main, "empty_house", "cg_ending_empty_house")
	_check_ending_cg_path(main, "crypto_ghost", "cg_ending_crypto_ghost")
	_check_all_ending_cg_contracts(main)

	var preview_parent := VBoxContainer.new()
	add_child(preview_parent)
	main.call("_add_ending_cg_preview", preview_parent, synthetic_path)
	await get_tree().process_frame
	await get_tree().process_frame

	var preview := _find_texture_rect_with_path(preview_parent, synthetic_path)
	if preview == null:
		_failures.append("MainGame ending modal did not include cg preview TextureRect")
	elif not preview.material is ShaderMaterial:
		_failures.append("MainGame ending preview did not receive Gangnam Ink grading")
	else:
		var preview_material := preview.material as ShaderMaterial
		if preview_material.shader == null or preview_material.shader.resource_path != "res://assets/shaders/background_grade.gdshader":
			_failures.append("MainGame ending preview uses the wrong grading shader")

	remove_child(preview_parent)
	preview_parent.queue_free()
	main.queue_free()

func _check_ending_cg_path(main: Node, ending_id: String, cg_id: String) -> void:
	var expected_path := ImageRegistry.get_cg(cg_id)
	if expected_path == "":
		_failures.append("missing %s" % cg_id)
		return

	var ending: Dictionary = EndingSystem.get_ending(ending_id)
	if ending.is_empty():
		_failures.append("missing ending: %s" % ending_id)
		return

	var actual_path := str(main.call("_get_ending_cg_path", ending))
	if actual_path != expected_path:
		_failures.append("%s cg mismatch: expected %s, got %s" % [ending_id, expected_path, actual_path])

func _check_all_ending_cg_contracts(main: Node) -> void:
	var owners: Dictionary = {}
	for raw_ending in DataRegistry.endings:
		var ending: Dictionary = raw_ending
		var ending_id: String = str(ending.get("id", ""))
		var cg_id: String = str(ending.get("cg", ""))
		if cg_id.is_empty():
			continue
		if owners.has(cg_id):
			_failures.append("ending cg %s is shared by %s and %s" % [cg_id, str(owners[cg_id]), ending_id])
		else:
			owners[cg_id] = ending_id
		var path: String = str(main.call("_get_ending_cg_path", ending))
		if path.is_empty() or not ResourceLoader.exists(path):
			_failures.append("%s references missing ending cg %s" % [ending_id, cg_id])
			continue
		var texture := load(path) as Texture2D
		if texture == null or texture.get_width() < 1280 or texture.get_height() < 720:
			_failures.append("%s ending cg must be at least 1280x720: %s" % [ending_id, path])
	var white_ending: Dictionary = EndingSystem.get_ending("gangnam_dream_white")
	if not str(white_ending.get("cg", "")).is_empty():
		_failures.append("gangnam_dream_white must use its own future cg, never a shared placeholder")

func _find_texture_rect_with_path(node: Node, path: String) -> TextureRect:
	if node is TextureRect:
		var tr := node as TextureRect
		if tr.texture != null and tr.texture.resource_path == path:
			return tr
	for child in node.get_children():
		var found := _find_texture_rect_with_path(child, path)
		if found != null:
			return found
	return null
