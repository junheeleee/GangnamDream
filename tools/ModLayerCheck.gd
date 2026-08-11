extends Node

const TEST_CODE := "qx-Test"
const TEST_ROOT := "user://mod_layer_check"
const LANG_ROOT := TEST_ROOT + "/lang"
const MOD_ROOT := TEST_ROOT + "/mods"
const ASSET_ROOT := MOD_ROOT + "/assets"
const SETTINGS_PATH := TEST_ROOT + "/settings.json"

var _failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	_prepare_directories()
	LocaleManager.set_language("en")
	DataRegistry.reload()
	var event_samples := _events_with_choices(3)
	var event_before: Dictionary = event_samples[0]
	var override_before: Dictionary = event_samples[1]
	var collision_before: Dictionary = event_samples[2]
	var ending_before: Dictionary = DataRegistry.endings[0].duplicate(true)
	var job_before: Dictionary = DataRegistry.get_job("job_01").duplicate(true)
	var job_salary_before := int(job_before.get("base_salary", 0))
	var job_tier_before := int(job_before.get("tier", 0))
	var job_social_before := int((job_before.get("stat_gains", {}) as Dictionary).get("social_skill", 0))
	var asset_volatility_before := float(DataRegistry.get_asset("samsung").get("volatility", 0.0))
	_write_language_pack(event_before, ending_before)
	_write_asset_overrides()
	_write_data_mods(override_before, collision_before, job_salary_before, asset_volatility_before)

	ModLoader.configure_test_roots(LANG_ROOT, ASSET_ROOT, MOD_ROOT, SETTINGS_PATH)
	LocaleManager.refresh_community_packs()
	_check_discovery()
	_check_language_overlay(event_before, ending_before)
	_check_context_ui_provenance()
	_check_asset_override()
	_check_data_mods(
		override_before,
		collision_before,
		job_salary_before,
		job_tier_before,
		job_social_before,
		asset_volatility_before)
	_check_save_marker()
	_check_data_mod_toggle(job_salary_before)

	if not _failures.is_empty():
		for failure in _failures:
			push_error("MOD_LAYER_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("MOD_LAYER_CHECK_OK languages=2 event_text_only=1 ending_text_only=1 image=1 audio=1 fallback=1 ui_context_layers=5 ui_context_refresh=1 default_name=1 custom_event=1 override=1 invalid_flag=1 blank_copy=1 presets=2 schema_guard=1 load_order=1 load_order_flip=1 themes=4 toggles=1 save_marker=1 scripts=0")
	get_tree().quit(0)

func _prepare_directories() -> void:
	for path in [
		LANG_ROOT.path_join(TEST_CODE).path_join("events_%s" % TEST_CODE),
		LANG_ROOT.path_join("ja"),
		ASSET_ROOT.path_join("characters"),
		ASSET_ROOT.path_join("audio"),
		MOD_ROOT.path_join("events"),
		MOD_ROOT.path_join("presets"),
		MOD_ROOT.path_join("themes"),
	]:
		var error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))
		if error != OK and error != ERR_ALREADY_EXISTS:
			_fail("could not create test directory: %s (%d)" % [path, error])

func _events_with_choices(count: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for raw_event in DataRegistry.events:
		if not raw_event is Dictionary:
			continue
		var choices: Array = (raw_event as Dictionary).get("choices", [])
		if choices.is_empty():
			continue
		var has_expression_choice := false
		for raw_choice in choices:
			if raw_choice is Dictionary \
					and str((raw_choice as Dictionary).get("choice_kind", "")) == "expression":
				has_expression_choice = true
				break
		if has_expression_choice:
			continue
		result.append((raw_event as Dictionary).duplicate(true))
		if result.size() >= count:
			return result
	_fail("not enough events with choices were available")
	return result

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
	_write_context_language_pack("QA CONTEXT V1")
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

func _write_context_language_pack(explicit_value: String) -> void:
	_write_json(LANG_ROOT.path_join("ja").path_join("ui_ja.json"), {
		"ui.qa.context": explicit_value,
		"기록": "QA COMMUNITY LEGACY",
		"김민준": "QA MINJUN",
	})

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

func _write_data_mods(
		override_before: Dictionary,
		collision_before: Dictionary,
		job_salary_before: int,
		asset_volatility_before: float) -> void:
	var rewritten_choices: Array = []
	var base_choices: Array = override_before.get("choices", [])
	for index in range(base_choices.size()):
		var choice: Dictionary = (base_choices[index] as Dictionary).duplicate(true)
		choice["text"] = "QA OVERRIDE CHOICE %d" % index
		choice["result_text"] = "QA OVERRIDE RESULT %d" % index
		choice["effects"] = {"mental": index + 1}
		var flags: Array = choice.get("flags", []).duplicate()
		flags.append("mod_qa_override_%d" % index)
		choice["flags"] = flags
		rewritten_choices.append(choice)
	var first_bill: Dictionary = DataRegistry.find_event(
		"v2_demo_first_bill")
	var first_bill_mod_choices: Array = []
	for index in range((first_bill.get("choices", []) as Array).size()):
		var base_choice: Dictionary = (
			first_bill.get("choices", []) as Array)[index]
		first_bill_mod_choices.append({
			"text": "QA FIRST BILL %d" % index,
			"result_text": "QA FIRST BILL RESULT %d" % index,
			"effects": (base_choice.get("effects", {}) as Dictionary).duplicate(true),
		})
	var opening: Dictionary = DataRegistry.find_event(
		"v2_demo_first_bill_opening")
	var malicious_expression_choices: Array = []
	for index in range((opening.get("choices", []) as Array).size()):
		var expression_choice := {
			"text": "QA EXPRESSION %d" % index,
			"result_text": "QA EXPRESSION RESULT %d" % index,
		}
		if index == 0:
			expression_choice["cast_effects"] = {
				"mod_intruder": {"affinity": 99},
			}
		malicious_expression_choices.append(expression_choice)
	_write_json(MOD_ROOT.path_join("events/qa_events.json"), {
		"id": "qa_events",
		"name": "QA Events",
		"version": "1",
		"events": [
			{
				"id": "mod_qa_random",
				"title": "QA RANDOM EVENT",
				"description": "A random event supplied by a data mod.",
				"category": "daily_life",
				"rarity": "common",
				"weight": 1.0,
				"hidden": false,
				"conditions": {},
				"tags": ["daily"],
				"cooldown": 3,
				"choices": [{
					"text": "Keep going",
					"effects": {"mental": 1},
					"flags": ["mod_qa_seen"],
					"result_text": "The custom event resolved.",
				}],
			},
			{
				"id": "mod_qa_bad_flag",
				"title": "QA BAD FLAG",
				"description": "This event must be rejected.",
				"category": "daily_life",
				"rarity": "common",
				"weight": 1.0,
				"hidden": false,
				"conditions": {},
				"tags": ["daily"],
				"cooldown": 3,
				"choices": [{
					"text": "Break canon",
					"effects": {"mental": 1},
					"flags": ["story_intro_completed"],
					"result_text": "This should never load.",
				}],
			},
			{
				"id": "mod_qa_blank_title",
				"title": "",
				"description": "This event must also be rejected.",
				"category": "daily_life",
				"rarity": "common",
				"weight": 1.0,
				"hidden": false,
				"conditions": {},
				"tags": ["daily"],
				"cooldown": 3,
				"choices": [{
					"text": "Continue",
					"effects": {"mental": 1},
					"flags": ["mod_qa_blank_seen"],
					"result_text": "This should never load.",
				}],
			},
			{
				"id": str(collision_before.get("id", "")),
				"title": "QA COLLISION WITHOUT OVERRIDE",
			},
			{
				"id": str(override_before.get("id", "")),
				"override": true,
				"title": "QA STORY REWRITE",
				"description": "The prose and effects changed; the schedule did not.",
				"choices": rewritten_choices,
			},
			{
				"id": "v2_demo_first_bill",
				"override": true,
				"title": "QA FIRST BILL REWRITE",
				"description": "The copy changes while its obligation wiring stays canonical.",
				"choices": first_bill_mod_choices,
			},
			{
				"id": "v2_demo_first_bill_opening",
				"override": true,
				"title": "QA MALICIOUS EXPRESSION REWRITE",
				"description": "This override must be rejected because it mutates cast state.",
				"choices": malicious_expression_choices,
			},
		],
	})
	_write_json(MOD_ROOT.path_join("presets/qa_first.json"), {
		"id": "qa_first",
		"name": "QA First Preset",
		"version": "1",
		"jobs": [{"id": "job_01", "base_salary": job_salary_before + 1}],
		"assets": [{"id": "samsung", "volatility": asset_volatility_before + 0.001}],
	})
	_write_json(MOD_ROOT.path_join("presets/qa_second.json"), {
		"id": "qa_second",
		"name": "QA Second Preset",
		"version": "1",
		"jobs": [{
			"id": "job_01",
			"base_salary": job_salary_before + 2,
			"tier": "broken",
			"stat_gains": {"social_skill": "broken", "mod_new": 99},
		}],
	})
	var theme: Variant = JSON.parse_string(FileAccess.get_file_as_string(
		"res://content/themes/moral_ui_default.json"))
	if theme is Dictionary:
		theme["id"] = "mod_qa"
		theme["name_ko"] = "QA 테마"
		theme["name_en"] = "QA Theme"
		(theme["surfaces"]["main"]["gray"] as Dictionary)["focus"] = "#00ff00ff"
		_write_json(MOD_ROOT.path_join("themes/qa_theme.json"), theme)
	else:
		_fail("could not clone the default moral palette")
	_write_json(SETTINGS_PATH, {
		"moral_palette": "mod_qa",
		"mod_enabled": {
			"assets": true,
			"events:qa_events": true,
			"preset:qa_first": true,
			"preset:qa_second": true,
			"theme:mod_qa": true,
		},
		"mod_load_order": [
			"events:qa_events", "preset:qa_first", "preset:qa_second", "theme:mod_qa", "assets",
		],
	})

func _check_discovery() -> void:
	_expect(TEST_CODE in ModLoader.discover_language_codes(), "community language was not discovered")
	_expect("ja" in ModLoader.discover_language_codes(), "community overlay for a built-in language was not discovered")
	_expect(TEST_CODE in LocaleManager.get_selectable_languages(), "community language was not selectable")
	_expect(LocaleManager.get_language_display_name(TEST_CODE) == "QA Native", "pack native name was not used")
	_expect(
		ModLoader.resolve_asset_override("res://assets/evil.gd") == "res://assets/evil.gd",
		"script file was treated as an asset override")
	var mod_ids: Array[String] = []
	for info in ModLoader.discover_data_mods():
		mod_ids.append(str(info.get("id", "")))
	for expected in ["assets", "events:qa_events", "preset:qa_first", "preset:qa_second", "theme:mod_qa"]:
		_expect(expected in mod_ids, "data mod was not discovered: %s" % expected)

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

func _check_context_ui_provenance() -> void:
	var original_language := LocaleManager.language
	LocaleManager.language = "ja"
	LocaleManager.clear_ui_misses("ja")
	_expect(LocaleManager.localize_player_name("김민준") == "QA MINJUN",
		"community Japanese default player name did not load into the UI cache")
	LocaleManager.language = "en"
	_expect(LocaleManager.localize_player_name("QA MINJUN") == "Kim Minjun",
		"cached community Japanese name was not recognized from English")
	LocaleManager.language = "ko"
	_expect(LocaleManager.localize_player_name("QA MINJUN") == "김민준",
		"cached community Japanese name was not recognized from Korean")
	LocaleManager.language = "ja"
	_expect(LocaleManager.ui_context(
		"ui.qa.context", "기록", "QA EN") == "QA CONTEXT V1",
		"community context ID did not win over its community legacy key")
	_expect(LocaleManager.ui_context(
		"연락", "기록", "QA EN") == "QA COMMUNITY LEGACY",
		"community legacy key did not win over a built-in context key")
	_expect(LocaleManager.ui_context(
		"연락", "설정", "QA EN") == "連絡",
		"built-in context key did not win over its built-in legacy key")
	_expect(LocaleManager.ui_context(
		"ui.qa.no_context", "설정", "QA EN") == "設定",
		"built-in legacy key did not serve a missing context ID")
	_expect(LocaleManager.get_ui_miss_count("ja") == 0,
		"a successful context provenance layer recorded a miss")
	_expect(LocaleManager.ui_context(
		"ui.qa.missing", "문맥 폴백 없음", "QA EN FALLBACK") == "QA EN FALLBACK",
		"missing context and legacy keys did not return English")
	LocaleManager.ui_context(
		"ui.qa.missing", "다른 원문", "SECOND QA EN FALLBACK")
	_expect(LocaleManager.get_ui_misses("ja") == ["context:ui.qa.missing"],
		"community context miss was not deduplicated by stable ID")

	_write_context_language_pack("QA CONTEXT V2")
	_expect(LocaleManager.ui_context(
		"ui.qa.context", "기록", "QA EN") == "QA CONTEXT V1",
		"community context cache changed before refresh")
	LocaleManager.refresh_community_packs()
	_expect(LocaleManager.get_ui_miss_count("ja") == 0,
		"community refresh did not clear context misses")
	_expect(LocaleManager.ui_context(
		"ui.qa.context", "기록", "QA EN") == "QA CONTEXT V2",
		"community context table did not reload after refresh")
	LocaleManager.refresh_community_packs()
	LocaleManager.language = original_language
	_expect(LocaleManager.ui("설정", "Settings") == "QA SETTINGS" \
			and LocaleManager.get_ui_miss_count(original_language) == 0,
		"context fixture did not restore the original language/cache state")

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

func _check_data_mods(
			override_before: Dictionary,
			collision_before: Dictionary,
			job_salary_before: int,
			job_tier_before: int,
			job_social_before: int,
			asset_volatility_before: float) -> void:
	var custom: Dictionary = DataRegistry.find_event("mod_qa_random")
	_expect(not custom.is_empty(), "valid custom random event was not loaded")
	_expect(str(custom.get("rarity", "")) != "story" and float(custom.get("weight", 0.0)) > 0.0,
		"custom event entered a non-random lane")
	_expect(DataRegistry.find_event("mod_qa_bad_flag").is_empty(),
		"event with an unnamespaced flag was loaded")
	_expect(DataRegistry.find_event("mod_qa_blank_title").is_empty(),
		"event with blank display copy was loaded")
	var collision: Dictionary = DataRegistry.find_event(str(collision_before.get("id", "")))
	_expect(str(collision.get("title", "")) == str(collision_before.get("title", "")),
		"built-in event collision replaced canon without override=true")
	var rewritten: Dictionary = DataRegistry.find_event(str(override_before.get("id", "")))
	_expect(str(rewritten.get("title", "")) == "QA STORY REWRITE", "explicit story rewrite did not load")
	_expect(rewritten.get("conditions", {}) == override_before.get("conditions", {}),
		"story rewrite changed the schedule conditions")
	_expect(rewritten.get("choices", []).size() == override_before.get("choices", []).size(),
		"story rewrite changed the choice count")
	for index in range(rewritten.get("choices", []).size()):
		var before_choice: Dictionary = override_before.get("choices", [])[index]
		var after_choice: Dictionary = rewritten.get("choices", [])[index]
		for key in [
			"follow_up_event", "deferred_follow_up", "deferred_delay",
			"choice_kind", "v2_obligation_id",
			"v2_player_initiated_character",
		]:
			_expect(after_choice.get(key) == before_choice.get(key),
				"story rewrite changed schedule key %s" % key)
	var first_bill: Dictionary = DataRegistry.find_event(
		"v2_demo_first_bill")
	var first_bill_choices: Array = first_bill.get("choices", [])
	var expected_obligation_ids := [
		"father_call", "hanbit_month_close", "city_work_sample",
		"daeun_checkin", "jaehyuk_reply", "sangchul_ledger",
		"urgent_paid_shift", "body_rest",
	]
	var expected_initiators := [
		"father", "", "", "daeun", "jaehyuk", "", "", "",
	]
	_expect(str(first_bill.get("title", "")) == "QA FIRST BILL REWRITE" \
			and first_bill_choices.size() == expected_obligation_ids.size(),
		"First Bill text override did not load with its eight choices")
	for index in range(mini(
			first_bill_choices.size(), expected_obligation_ids.size())):
		var mod_choice: Dictionary = first_bill_choices[index]
		_expect(str(mod_choice.get("follow_up_event", "")) \
				== "v2_demo_first_bill_ledger" \
				and str(mod_choice.get("choice_kind", "")) == "decision" \
				and str(mod_choice.get("v2_obligation_id", "")) \
					== expected_obligation_ids[index] \
				and str(mod_choice.get(
					"v2_player_initiated_character", "")) \
					== expected_initiators[index],
			"First Bill mod changed protected choice wiring at %d" % index)
	var expression_opening: Dictionary = DataRegistry.find_event(
		"v2_demo_first_bill_opening")
	var expression_choices: Array = expression_opening.get("choices", [])
	_expect(str(expression_opening.get("title", "")) \
			!= "QA MALICIOUS EXPRESSION REWRITE" \
			and not expression_choices.is_empty() \
			and str((expression_choices[0] as Dictionary).get(
				"choice_kind", "")) == "expression" \
			and not (expression_choices[0] as Dictionary).has("cast_effects"),
		"stateful expression-choice override bypassed the no-state contract")
	_expect(int(DataRegistry.get_job("job_01").get("base_salary", 0)) == job_salary_before + 2,
		"preset load order did not use the later value")
	var modded_job: Dictionary = DataRegistry.get_job("job_01")
	_expect(int(modded_job.get("tier", 0)) == job_tier_before,
		"preset type mismatch changed a catalog field")
	var stat_gains: Dictionary = modded_job.get("stat_gains", {})
	_expect(int(stat_gains.get("social_skill", 0)) == job_social_before and not stat_gains.has("mod_new"),
		"preset changed the nested catalog schema")
	_expect(is_equal_approx(
		float(DataRegistry.get_asset("samsung").get("volatility", 0.0)),
		asset_volatility_before + 0.001), "asset preset did not merge by id")
	_expect(ModLoader.available_theme_infos().size() == 4, "official and external themes were not listed")
	_expect(ModLoader.selected_theme_id() == "mod_qa", "external theme selection did not persist")
	var palette := ModLoader.moral_palette("main", 0.0, 0.0)
	_expect((palette.get("focus", Color.BLACK) as Color).is_equal_approx(Color("#00ff00ff")),
		"external theme color did not load")
	_write_json(SETTINGS_PATH, {
		"moral_palette": "mod_qa",
		"mod_enabled": {
			"assets": true,
			"events:qa_events": true,
			"preset:qa_first": true,
			"preset:qa_second": true,
			"theme:mod_qa": true,
		},
		"mod_load_order": [
			"events:qa_events", "preset:qa_second", "preset:qa_first", "theme:mod_qa", "assets",
		],
	})
	ModLoader.notify_settings_changed()
	DataRegistry.reload()
	_expect(int(DataRegistry.get_job("job_01").get("base_salary", 0)) == job_salary_before + 1,
		"reversing preset load order did not reverse the winning value")

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
		_expect("events:qa_events" in active and "preset:qa_second" in active and "theme:mod_qa" in active,
			"save omitted active data mod labels")

func _check_data_mod_toggle(job_salary_before: int) -> void:
	_write_json(SETTINGS_PATH, {
		"moral_palette": "default",
		"mod_enabled": {
			"assets": false,
			"events:qa_events": false,
			"preset:qa_first": false,
			"preset:qa_second": false,
			"theme:mod_qa": false,
		},
		"mod_load_order": ["preset:qa_second", "preset:qa_first"],
	})
	ModLoader.notify_settings_changed()
	DataRegistry.reload()
	_expect(DataRegistry.find_event("mod_qa_random").is_empty(), "disabled event mod still loaded")
	_expect(int(DataRegistry.get_job("job_01").get("base_salary", 0)) == job_salary_before,
		"disabled preset still changed the catalog")
	_expect(ModLoader.selected_theme_id() == "default", "disabled external theme did not fall back")
	_expect(not ModLoader.has_any_asset_overrides(), "disabled asset layer stayed active")

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
