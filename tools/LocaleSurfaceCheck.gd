extends Node
## LocaleSurfaceCheck — start surfaces should react to the saved English setting.

var _failures: Array[String] = []

func _ready() -> void:
	LocaleManager.language = "en"
	await _check_start_menu()
	await _check_opening_cinematic()
	LocaleManager.language = "ko"
	if _failures.is_empty():
		print("LOCALE_SURFACE_CHECK_OK")
		get_tree().quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		get_tree().quit(1)

func _check_start_menu() -> void:
	var packed := load("res://scenes/StartMenu.tscn") as PackedScene
	var menu := packed.instantiate()
	add_child(menu)
	await get_tree().process_frame
	await get_tree().process_frame
	var text := _collect_text(menu)
	for expected in ["Gangnam Dream", "Start New Story", "Continue", "Difficulty", "Run Theme", "Kim Minjun"]:
		if expected not in text:
			_failures.append("StartMenu missing English text: %s" % expected)
	for forbidden in ["새 이야기 시작", "이어하기", "난이도", "런 테마", "김민준, 33세"]:
		if forbidden in text:
			_failures.append("StartMenu still shows Korean text: %s" % forbidden)
	remove_child(menu)
	menu.queue_free()

func _check_opening_cinematic() -> void:
	var packed := load("res://scenes/OpeningCinematic.tscn") as PackedScene
	var scene := packed.instantiate()
	add_child(scene)
	await get_tree().process_frame
	await get_tree().process_frame
	var text := _collect_text(scene)
	if "2026. Seoul." not in text:
		_failures.append("OpeningCinematic first card did not localize to English")
	if "2026년, 서울." in text:
		_failures.append("OpeningCinematic still shows Korean first card")
	remove_child(scene)
	scene.queue_free()

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
