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
	var expected_path := ImageRegistry.get_cg("cg_ending_father")
	if expected_path == "":
		_failures.append("missing cg_ending_father")
		return

	var main_script: GDScript = load("res://scenes/MainGame.gd") as GDScript
	var main: Node = main_script.new()
	var actual_path := str(main.call("_get_ending_cg_path", {"cg": "cg_ending_father"}))
	if actual_path != expected_path:
		_failures.append("MainGame synthetic ending cg path mismatch: expected %s, got %s" % [expected_path, actual_path])

	var gangnam_ending: Dictionary = EndingSystem.get_ending("gangnam_dream")
	var gangnam_path := str(main.call("_get_ending_cg_path", gangnam_ending))
	if gangnam_path != "":
		_failures.append("gangnam_dream should not reuse hospital father CG; got %s" % gangnam_path)

	var preview_parent := VBoxContainer.new()
	add_child(preview_parent)
	main.call("_add_ending_cg_preview", preview_parent, expected_path)
	await get_tree().process_frame
	await get_tree().process_frame

	if not _has_texture_rect_with_path(preview_parent, expected_path):
		_failures.append("MainGame ending modal did not include cg preview TextureRect")

	remove_child(preview_parent)
	preview_parent.queue_free()
	main.queue_free()

func _has_texture_rect_with_path(node: Node, path: String) -> bool:
	if node is TextureRect:
		var tr := node as TextureRect
		if tr.texture != null and tr.texture.resource_path == path:
			return true
	for child in node.get_children():
		if _has_texture_rect_with_path(child, path):
			return true
	return false
