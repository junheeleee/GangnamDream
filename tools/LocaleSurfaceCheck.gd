extends Node
## LocaleSurfaceCheck — start surfaces should react to the saved English setting.

var _failures: Array[String] = []

func _ready() -> void:
	LocaleManager.set_language("en")
	await get_tree().process_frame
	_check_registry_text()
	await _check_start_menu()
	await _check_opening_cinematic()
	LocaleManager.set_language("ko")
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
	_assert_no_hangul("StartMenu visible text", text)
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
	_assert_no_hangul("OpeningCinematic visible text", text)
	remove_child(scene)
	scene.queue_free()

func _check_registry_text() -> void:
	_check_rows("events", DataRegistry.events, [
		"title", "description", "text", "result_text", "subtitle",
		"choice", "condition", "hint", "note", "body",
	])
	_check_rows("endings", DataRegistry.endings, [
		"title", "description", "condition", "description_if_known",
	])
	_check_rows("assets", DataRegistry.assets, ["name", "description", "tags"])
	_check_rows("jobs", DataRegistry.jobs, ["name", "description"])
	_check_rows("items", DataRegistry.items, ["name", "description"])
	_check_rows("achievements", DataRegistry.achievements, ["name", "description", "hint"])
	_check_rows("clues", DataRegistry.clues, ["title", "text"])
	_check_rows("thoughts", DataRegistry.thoughts, ["title", "description", "conclusion"])
	_check_rows("news", DataRegistry.news_templates, ["headline", "topics"])

func _check_rows(label: String, rows: Array, keys: Array[String]) -> void:
	for row in rows:
		if not row is Dictionary:
			continue
		var row_id := str((row as Dictionary).get("id", "?"))
		for key in keys:
			if (row as Dictionary).has(key):
				_check_value("%s:%s:%s" % [label, row_id, key], (row as Dictionary)[key])
		if (row as Dictionary).has("choices"):
			var choices: Array = (row as Dictionary).get("choices", [])
			for i in range(choices.size()):
				if choices[i] is Dictionary:
					for key in ["text", "result_text", "tooltip"]:
						if (choices[i] as Dictionary).has(key):
							_check_value("%s:%s:choice%d:%s" % [label, row_id, i, key], (choices[i] as Dictionary)[key])

func _check_value(label: String, value: Variant) -> void:
	match typeof(value):
		TYPE_STRING:
			_assert_no_hangul(label, str(value))
		TYPE_ARRAY:
			for i in range((value as Array).size()):
				_check_value("%s[%d]" % [label, i], (value as Array)[i])
		TYPE_DICTIONARY:
			for key in (value as Dictionary).keys():
				_check_value("%s.%s" % [label, str(key)], (value as Dictionary)[key])

func _assert_no_hangul(label: String, text: String) -> void:
	if _contains_hangul(text):
		_failures.append("%s contains Hangul: %s" % [label, text.substr(0, 160).replace("\n", "\\n")])

func _contains_hangul(text: String) -> bool:
	for i in range(text.length()):
		var cp := text.unicode_at(i)
		if (cp >= 0xAC00 and cp <= 0xD7A3) or (cp >= 0x1100 and cp <= 0x11FF) or (cp >= 0x3130 and cp <= 0x318F):
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
