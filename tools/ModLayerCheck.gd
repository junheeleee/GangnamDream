extends Node

const TEST_CODE := "qx-Test"
const TEST_ROOT := "user://mod_layer_check"
const LANG_ROOT := TEST_ROOT + "/lang"
const ASSET_ROOT := TEST_ROOT + "/mods/assets"

var _failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	_prepare_directories()
	LocaleManager.set_language("en")
	DataRegistry.reload()
	var event_before := _first_event_with_choices()
	var ending_before: Dictionary = DataRegistry.endings[0].duplicate(true)
	_write_language_pack(event_before, ending_before)
	_write_asset_overrides()

	ModLoader.configure_test_roots(LANG_ROOT, ASSET_ROOT)
	LocaleManager.refresh_community_packs()
	_check_discovery()
	_check_language_overlay(event_before, ending_before)
	_check_asset_override()
	_check_save_marker()

	if not _failures.is_empty():
		for failure in _failures:
			push_error("MOD_LAYER_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("MOD_LAYER_CHECK_OK languages=1 event_text_only=1 ending_text_only=1 image=1 audio=1 fallback=1 save_marker=1 scripts=0")
	get_tree().quit(0)

func _prepare_directories() -> void:
	for path in [
		LANG_ROOT.path_join(TEST_CODE).path_join("events_%s" % TEST_CODE),
		ASSET_ROOT.path_join("characters"),
		ASSET_ROOT.path_join("audio"),
	]:
		var error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))
		if error != OK and error != ERR_ALREADY_EXISTS:
			_fail("could not create test directory: %s (%d)" % [path, error])

func _first_event_with_choices() -> Dictionary:
	for raw_event in DataRegistry.events:
		if raw_event is Dictionary and not (raw_event as Dictionary).get("choices", []).is_empty():
			return (raw_event as Dictionary).duplicate(true)
	_fail("no event with choices was available")
	return {}

func _write_language_pack(event_before: Dictionary, ending_before: Dictionary) -> void:
	var root := LANG_ROOT.path_join(TEST_CODE)
	_write_json(root.path_join("pack.json"), {
		"name": "QA Language",
		"native_name": "QA Native",
		"author": "Codex",
		"version": "1",
	})
	_write_json(root.path_join("ui_%s.json" % TEST_CODE), {
		"설정": "QA SETTINGS",
		"잘못된 값": 77,
	})
	var choices: Array = event_before.get("choices", [])
	_write_json(root.path_join("events_%s" % TEST_CODE).path_join("qa.json"), [{
		"id": str(event_before.get("id", "")),
		"title": "QA EVENT TITLE",
		"description": "QA EVENT BODY",
		"background": "casino",
		"conditions": {"money_min": 9_999_999_999},
		"effects": {"money": 9_999_999_999},
		"choices": [{
			"text": "QA CHOICE",
			"result_text": "QA RESULT",
			"effects": {"money": 9_999_999_999},
		}] if not choices.is_empty() else [],
	}])
	_write_json(root.path_join("endings_%s.json" % TEST_CODE), [{
		"id": str(ending_before.get("id", "")),
		"title": "QA ENDING",
		"description": "QA ENDING BODY",
		"grade": "BROKEN",
		"cg": "cg_start",
	}])

func _write_asset_overrides() -> void:
	var portrait_path := ASSET_ROOT.path_join("characters/main_character_unemployed.png")
	var image := Image.create(3, 2, false, Image.FORMAT_RGBA8)
	image.fill(Color(1.0, 0.0, 0.75, 1.0))
	var error := image.save_png(ProjectSettings.globalize_path(portrait_path))
	if error != OK:
		_fail("could not write image override: %d" % error)
	var source_audio := "res://assets/audio/sfx_close.wav"
	var audio_bytes := FileAccess.get_file_as_bytes(source_audio)
	var audio_file := FileAccess.open(ASSET_ROOT.path_join("audio/sfx_click.wav"), FileAccess.WRITE)
	if audio_file == null:
		_fail("could not open audio override")
	else:
		audio_file.store_buffer(audio_bytes)
		audio_file.close()
	var script_file := FileAccess.open(ASSET_ROOT.path_join("evil.gd"), FileAccess.WRITE)
	if script_file != null:
		script_file.store_string("extends Node\n")
		script_file.close()

func _check_discovery() -> void:
	_expect(TEST_CODE in ModLoader.discover_language_codes(), "community language was not discovered")
	_expect(TEST_CODE in LocaleManager.get_selectable_languages(), "community language was not selectable")
	_expect(LocaleManager.get_language_display_name(TEST_CODE) == "QA Native", "pack native name was not used")
	_expect(
		ModLoader.resolve_asset_override("res://assets/evil.gd") == "res://assets/evil.gd",
		"script file was treated as an asset override")

func _check_language_overlay(event_before: Dictionary, ending_before: Dictionary) -> void:
	LocaleManager.set_language(TEST_CODE)
	DataRegistry.reload()
	_expect(LocaleManager.ui("설정", "Settings") == "QA SETTINGS", "community UI text did not load")
	var event_after: Dictionary = DataRegistry.find_event(str(event_before.get("id", "")))
	_expect(str(event_after.get("title", "")) == "QA EVENT TITLE", "event title did not overlay")
	_expect(str(event_after.get("description", "")) == "QA EVENT BODY", "event body did not overlay")
	_expect(event_after.get("effects", {}) == event_before.get("effects", {}), "external event changed gameplay effects")
	_expect(event_after.get("conditions", {}) == event_before.get("conditions", {}), "external event changed conditions")
	_expect(str(event_after.get("background", "")) == str(event_before.get("background", "")),
		"external event changed background routing")
	var choices_after: Array = event_after.get("choices", [])
	var choices_before: Array = event_before.get("choices", [])
	if not choices_after.is_empty() and not choices_before.is_empty():
		_expect(str((choices_after[0] as Dictionary).get("text", "")) == "QA CHOICE", "choice text did not overlay")
		_expect((choices_after[0] as Dictionary).get("effects", {}) == (choices_before[0] as Dictionary).get("effects", {}),
			"external choice changed gameplay effects")
	var ending_after: Dictionary = DataRegistry.get_ending(str(ending_before.get("id", "")))
	_expect(str(ending_after.get("title", "")) == "QA ENDING", "ending title did not overlay")
	_expect(str(ending_after.get("grade", "")) == str(ending_before.get("grade", "")),
		"external ending changed grade")
	_expect(str(ending_after.get("cg", "")) == str(ending_before.get("cg", "")),
		"external ending changed CG routing")

func _check_asset_override() -> void:
	var portrait_path := "res://assets/characters/main_character_unemployed.png"
	_expect(ModLoader.has_asset_override(portrait_path), "portrait override was not resolved")
	var texture := ImageRegistry.load_texture(portrait_path)
	_expect(texture != null and texture.get_width() == 3 and texture.get_height() == 2,
		"external portrait texture was not loaded")
	var audio_path := "res://assets/audio/sfx_click.wav"
	_expect(ModLoader.has_asset_override(audio_path), "audio override was not resolved")
	_expect(ModLoader.load_audio(audio_path) != null, "external audio stream was not loaded")

	var override_path := ASSET_ROOT.path_join("characters/main_character_unemployed.png")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(override_path))
	ModLoader.clear_caches()
	var fallback := ImageRegistry.load_texture(portrait_path)
	_expect(fallback != null and (fallback.get_width() != 3 or fallback.get_height() != 2),
		"missing image override did not fall back to built-in")

func _check_save_marker() -> void:
	_expect(ModLoader.is_active(LocaleManager.language), "active mod state was false")
	_expect(SaveManager.save_game(3), "modded save could not be written")
	var save_path := "user://gangnam_dream_slot_3.json"
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(save_path))
	_expect(parsed is Dictionary, "modded save was not valid JSON")
	if parsed is Dictionary:
		_expect(bool((parsed as Dictionary).get("mod_active", false)), "save omitted mod_active")
		var active: Array = (parsed as Dictionary).get("active_mods", [])
		_expect("lang:%s" % TEST_CODE in active and "assets" in active, "save omitted active mod labels")

func _write_json(path: String, value: Variant) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_fail("could not write JSON: %s" % path)
		return
	file.store_string(JSON.stringify(value, "\t"))
	file.close()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)

func _fail(message: String) -> void:
	_failures.append(message)
