extends Node
## ORDER-70 release-flavor contract. This fixture is intentionally read-only:
## it proves that the shipped playtest resolves to a disjoint namespace without
## touching either the player's retail files or their playtest progress.

const BuildFlavorScript := preload("res://systems/BuildFlavor.gd")
const BuildInfoScript := preload("res://systems/BuildInfo.gd")
const DemoCoreLoopV2Script := preload("res://systems/DemoCoreLoopV2.gd")
const StartMenuScript := preload("res://scenes/StartMenu.gd")
const START_MENU := preload("res://scenes/StartMenu.tscn")

const REQUIRED_RETAIL_PRESETS := [
	"Windows", "macOS", "Web", "Linux / Steam Deck",
]
const REQUIRED_DEMO_PRESETS := [
	"Windows Demo", "macOS Demo", "Linux / Steam Deck Demo",
]
const REQUIRED_PLAYTEST_PRESETS := [
	"Windows V2 Playtest",
	"macOS V2 Playtest",
	"Linux / Steam Deck V2 Playtest",
]

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	_check_runtime_flavor()
	_check_export_presets()
	_check_user_data_namespaces()
	_check_build_identity()
	_check_runtime_default_boundary()
	await _check_start_surface()
	_stop_test_audio()
	# StartMenu asks the persistent SceneTransition autoload for a 0.35-second
	# fade. Let that tween release its bound resources before the strict gate
	# inspects shutdown output.
	await get_tree().create_timer(0.5, true, false, true).timeout
	await get_tree().process_frame
	await get_tree().process_frame
	if not _failures.is_empty():
		for failure in _failures:
			push_error("PLAYTEST_FLAVOR_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("PLAYTEST_FLAVOR_CHECK_OK feature=%s entry=1 retail_entry=0 paths=14 collisions=0 presets=10 marker=1 runtime_default=0 cutoff=24" % [
		BuildFlavorScript.PLAYTEST_FEATURE,
	])
	get_tree().quit(0)


func _check_runtime_flavor() -> void:
	_expect(BuildFlavorScript.is_core_loop_v2_playtest_build(),
		"The CI playtest flag did not resolve to the playtest flavor.")
	_expect(GameState.is_demo_build(),
		"The V2 playtest contract must also run with the 24-week demo cutoff.")
	_expect(BuildFlavorScript.build_flavor_id()
			== BuildFlavorScript.PLAYTEST_FLAVOR_ID,
		"The runtime build-flavor ID is not the V2 playtest ID.")
	_expect(BuildFlavorScript.save_namespace_id()
			== BuildFlavorScript.PLAYTEST_SAVE_NAMESPACE,
		"The runtime save namespace is not the versioned playtest namespace.")
	_expect(GameState.DEMO_TURN_LIMIT == 24,
		"The V2 release-candidate cutoff must remain at Week 24.")


func _check_export_presets() -> void:
	var config := ConfigFile.new()
	var error := config.load("res://export_presets.cfg")
	if error != OK:
		_failures.append("Could not read export_presets.cfg (error %d)." % error)
		return
	var presets: Dictionary = {}
	for section in config.get_sections():
		if not section.begins_with("preset.") or section.ends_with(".options"):
			continue
		var name := str(config.get_value(section, "name", ""))
		var features: Array[String] = []
		for raw_feature in str(config.get_value(
				section, "custom_features", "")).split(",", false):
			var feature := str(raw_feature).strip_edges()
			if not feature.is_empty():
				features.append(feature)
		presets[name] = {
			"features": features,
			"path": str(config.get_value(section, "export_path", "")),
		}
	_expect(presets.size() == 10,
		"Expected exactly ten retail/demo/playtest presets, got %d." % presets.size())
	for preset_name in REQUIRED_RETAIL_PRESETS:
		_expect(presets.has(preset_name), "Missing retail preset: %s." % preset_name)
		if presets.has(preset_name):
			var features: Array = presets[preset_name]["features"]
			_expect(not features.has(BuildFlavorScript.PLAYTEST_FEATURE),
				"Retail preset %s carries the playtest feature." % preset_name)
	for preset_name in REQUIRED_DEMO_PRESETS:
		_expect(presets.has(preset_name), "Missing legacy demo preset: %s." % preset_name)
		if presets.has(preset_name):
			var features: Array = presets[preset_name]["features"]
			_expect(features.has(GameState.DEMO_FEATURE),
				"Legacy demo preset %s lost the demo cutoff feature." % preset_name)
			_expect(not features.has(BuildFlavorScript.PLAYTEST_FEATURE),
				"Legacy demo preset %s was silently redefined as V2 playtest." % preset_name)
	for preset_name in REQUIRED_PLAYTEST_PRESETS:
		_expect(presets.has(preset_name), "Missing V2 playtest preset: %s." % preset_name)
		if presets.has(preset_name):
			var entry: Dictionary = presets[preset_name]
			var features: Array = entry["features"]
			_expect(features.has(GameState.DEMO_FEATURE),
				"V2 playtest preset %s lacks the 24-week demo feature." % preset_name)
			_expect(features.has(BuildFlavorScript.PLAYTEST_FEATURE),
				"V2 playtest preset %s lacks the entry/save feature." % preset_name)
			_expect(str(entry["path"]).begins_with("build/playtest/"),
				"V2 playtest preset %s writes outside build/playtest/." % preset_name)


func _check_user_data_namespaces() -> void:
	var retail: Dictionary = BuildFlavorScript.user_data_paths_for_playtest(false)
	var playtest: Dictionary = BuildFlavorScript.user_data_paths_for_playtest(true)
	_expect(retail.size() == 14 and playtest.size() == 14,
		"Each flavor must expose settings/display/meta/autosave plus ten slots.")
	_expect(str(retail.get("settings", ""))
			== "user://gangnam_dream_settings.json",
		"Retail settings moved away from the legacy path.")
	_expect(str(retail.get("display_settings", ""))
			== "user://gangnam_dream_display.json",
		"Retail display settings moved away from the legacy path.")
	_expect(str(retail.get("meta", ""))
			== "user://gangnam_dream_meta.json",
		"Retail meta progression moved away from the legacy path.")
	_expect(str(retail.get("autosave", ""))
			== "user://gangnam_dream_autosave.json",
		"Retail autosave moved away from the legacy path.")
	for slot in range(1, SaveManager.SLOT_COUNT + 1):
		_expect(str(retail.get("slot_%d" % slot, ""))
				== "user://gangnam_dream_slot_%d.json" % slot,
			"Retail slot %d moved away from the legacy path." % slot)
	var retail_values: Array = retail.values()
	var playtest_values: Array = playtest.values()
	_expect(_unique_count(retail_values) == retail_values.size(),
		"Retail user-data paths contain an internal collision.")
	_expect(_unique_count(playtest_values) == playtest_values.size(),
		"Playtest user-data paths contain an internal collision.")
	var collisions := 0
	for path in playtest_values:
		if retail_values.has(path):
			collisions += 1
	_expect(collisions == 0,
		"Retail/playtest user-data path intersection is %d, expected zero." % collisions)
	_expect(SaveManager.settings_path() == str(playtest["settings"]),
		"SaveManager did not select the playtest settings namespace.")
	_expect(DisplayManager.display_settings_path() == str(playtest["display_settings"]),
		"DisplayManager did not select the playtest display namespace.")
	_expect(MetaProgression.meta_save_path() == str(playtest["meta"]),
		"MetaProgression did not select the playtest meta namespace.")
	_expect(ModLoader.settings_path() == SaveManager.settings_path(),
		"ModLoader and SaveManager disagree on the active settings file.")
	for slot in range(SaveManager.AUTOSAVE_SLOT, SaveManager.SLOT_COUNT + 1):
		var key := "autosave" if slot == SaveManager.AUTOSAVE_SLOT else "slot_%d" % slot
		_expect(SaveManager.slot_path(slot) == str(playtest[key]),
			"SaveManager slot %d escaped the playtest namespace." % slot)
	var identity: Dictionary = SaveManager.save_identity_fields()
	_expect(str(identity.get("build_flavor", ""))
			== BuildFlavorScript.PLAYTEST_FLAVOR_ID,
		"Save payload does not identify the V2 playtest flavor.")
	_expect(str(identity.get("save_namespace", ""))
			== BuildFlavorScript.PLAYTEST_SAVE_NAMESPACE,
		"Save payload does not identify the versioned playtest namespace.")


func _check_build_identity() -> void:
	var label := BuildInfoScript.identity_label(false)
	var title_ko := BuildInfoScript.window_title(false, false)
	var title_en := BuildInfoScript.window_title(false, true)
	for value in [label, title_ko, title_en]:
		_expect("CORE LOOP V2" in value and "PLAYTEST" in value,
			"A playtest build-identity surface lost its flavor marker: %s." % value)
	_expect(StartMenuScript.release_v2_entry_count(true) == 1,
		"Playtest release policy must expose exactly one V2 entry.")
	_expect(StartMenuScript.release_v2_entry_count(false) == 0,
		"Retail release policy exposed a V2 entry before human GO.")


func _check_runtime_default_boundary() -> void:
	_expect(not bool(DemoCoreLoopV2Script.contract().get("runtime_default", true)),
		"Retail runtime_default changed before the human gate.")
	GameState.core_loop_v2_state["enabled"] = false
	_expect(not DemoCoreLoopV2Script.requested(),
		"The playtest feature silently enabled V2 outside its dedicated entry.")


func _check_start_surface() -> void:
	var marker := SceneTransition.find_child(
		"CoreLoopV2PlaytestMarker", true, false)
	_expect(is_instance_valid(marker),
		"The persistent playtest marker is missing from the global overlay.")
	if is_instance_valid(marker):
		_expect(str(marker.get_meta("build_flavor", ""))
				== BuildFlavorScript.PLAYTEST_FLAVOR_ID,
			"The persistent marker has no machine-readable flavor identity.")
		_expect(str(marker.get_meta("save_namespace", ""))
				== BuildFlavorScript.PLAYTEST_SAVE_NAMESPACE,
			"The persistent marker does not disclose the isolated namespace.")
		var marker_text := marker.find_child("PlaytestMarkerText", true, false) as Label
		_expect(is_instance_valid(marker_text) and "V2" in marker_text.text
				and ("TEST" in marker_text.text.to_upper()
					or "테스트" in marker_text.text),
			"The persistent marker is not visibly identifiable as a V2 test build.")
	var menu := START_MENU.instantiate()
	add_child(menu)
	await get_tree().process_frame
	await get_tree().process_frame
	var playtest_entries := 0
	var legacy_entries := 0
	for node in menu.find_children("*", "Button", true, false):
		var entry_kind := str(node.get_meta("build_entry_kind", ""))
		if entry_kind == BuildFlavorScript.PLAYTEST_FLAVOR_ID:
			playtest_entries += 1
		elif entry_kind == "legacy":
			legacy_entries += 1
	_expect(playtest_entries == 1,
		"Playtest StartMenu exposed %d V2 entries, expected one." % playtest_entries)
	_expect(legacy_entries == 0,
		"Playtest StartMenu still exposed the legacy New Story entry.")
	_expect(str(menu.get_meta("build_flavor", ""))
			== BuildFlavorScript.PLAYTEST_FLAVOR_ID,
		"StartMenu did not expose its playtest flavor metadata.")
	_expect(int(menu.get_meta("release_v2_entry_count", -1)) == 1,
		"StartMenu release-entry metadata is not exactly one.")
	var identity := menu.find_child("BuildIdentity", true, false) as Label
	_expect(is_instance_valid(identity)
			and identity.text == BuildInfoScript.identity_label(false),
		"StartMenu identity does not show the active playtest flavor.")
	_dispose(menu)


func _unique_count(values: Array) -> int:
	var seen: Dictionary = {}
	for value in values:
		seen[str(value)] = true
	return seen.size()


func _dispose(node: Node) -> void:
	if not is_instance_valid(node):
		return
	if node.get_parent() != null:
		node.get_parent().remove_child(node)
	node.free()


func _stop_test_audio() -> void:
	BGMPlayer.stop()
	for owner in [AudioManager, BGMPlayer]:
		for child in owner.get_children():
			if child is AudioStreamPlayer:
				(child as AudioStreamPlayer).stop()
				(child as AudioStreamPlayer).stream = null


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
