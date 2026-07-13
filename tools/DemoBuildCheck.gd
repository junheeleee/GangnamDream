extends Node

const EXPECTED_CHAIN := {
	1: "chapter_card_33",
	2: "arc_intro_01_meal",
	3: "arc_intro_02_dad_call",
	4: "arc_temptation_01",
	5: "arc_intro_03_sns",
	6: "cafe_00",
	7: "arc_intro_04_hyunsu",
	8: "arc_chapter1_close",
}
const CHOICE_OVERRIDES := {
	"cafe_listen_01": 2,
}
const REQUIRED_FULL_PRESETS := ["Windows", "macOS", "Linux / Steam Deck"]
const REQUIRED_DEMO_PRESETS := ["Windows Demo", "macOS Demo", "Linux / Steam Deck Demo"]

var _failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	_check_build_flavor()
	_check_export_presets()
	_check_first_eight_weeks()
	_check_demo_cutoff()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("DEMO_BUILD_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("DEMO_BUILD_CHECK_OK feature=%s cutoff=%d chain=%d presets=%d" % [
		GameState.DEMO_FEATURE,
		GameState.DEMO_TURN_LIMIT,
		EXPECTED_CHAIN.size(),
		REQUIRED_FULL_PRESETS.size() + REQUIRED_DEMO_PRESETS.size(),
	])
	get_tree().quit(0)

func _check_build_flavor() -> void:
	_expect(GameState.is_demo_build(), "The demo test flag did not activate demo mode.")
	_expect(GameState.DEMO_TURN_LIMIT == 24, "Demo cutoff must remain at week 24.")
	var main_scene := str(ProjectSettings.get_setting("application/run/main_scene", ""))
	if main_scene.begins_with("uid://"):
		main_scene = ResourceUID.get_id_path(ResourceUID.text_to_id(main_scene))
	_expect(main_scene == "res://scenes/SplashScreen.tscn", "Boot scene must be SplashScreen, got %s." % main_scene)

func _check_export_presets() -> void:
	var config := ConfigFile.new()
	var error := config.load("res://export_presets.cfg")
	if error != OK:
		_failures.append("Could not read export_presets.cfg (error %d)." % error)
		return
	var flavors := {}
	for section in config.get_sections():
		if not section.begins_with("preset.") or section.ends_with(".options"):
			continue
		var name := str(config.get_value(section, "name", ""))
		var features := str(config.get_value(section, "custom_features", ""))
		flavors[name] = features.split(",", false)
	for preset_name in REQUIRED_FULL_PRESETS:
		_expect(flavors.has(preset_name), "Missing full export preset: %s." % preset_name)
		if flavors.has(preset_name):
			_expect(not flavors[preset_name].has(GameState.DEMO_FEATURE), "Full preset %s carries the demo feature." % preset_name)
	for preset_name in REQUIRED_DEMO_PRESETS:
		_expect(flavors.has(preset_name), "Missing demo export preset: %s." % preset_name)
		if flavors.has(preset_name):
			_expect(flavors[preset_name].has(GameState.DEMO_FEATURE), "Demo preset %s lacks %s." % [preset_name, GameState.DEMO_FEATURE])

func _check_first_eight_weeks() -> void:
	GameState.start_new_game("김민준", "지방_상경", "직장형", "백수", "자유런", "현실")
	GameState.flags["prologue_done"] = true
	GameState.flags["story_flashforward_seen"] = true
	var packed := load("res://scenes/MainGame.tscn") as PackedScene
	if packed == null:
		_failures.append("MainGame.tscn failed to load.")
		return
	var main_game := packed.instantiate()
	for week in range(1, EXPECTED_CHAIN.size() + 1):
		GameState.turn = int(week)
		var expected_id := str(EXPECTED_CHAIN[week])
		var actual_id := str(main_game.call("_next_arc_id"))
		_expect(actual_id == expected_id, "Week %d expected %s, got %s." % [week, expected_id, actual_id])
		if actual_id != expected_id:
			break
		_resolve_story_chain(actual_id)
	main_game.free()
	_expect(bool(GameState.flags.get("chapter1_closed", false)), "The week-8 chapter close was not resolved.")

func _resolve_story_chain(event_id: String) -> void:
	var next_id := event_id
	var guard := 0
	while not next_id.is_empty() and guard < 12:
		guard += 1
		var event: Dictionary = DataRegistry.find_event(next_id)
		if event.is_empty():
			_failures.append("Missing early-flow event: %s." % next_id)
			return
		var choices: Array = event.get("choices", [])
		if choices.is_empty():
			_failures.append("Early-flow event has no choice: %s." % next_id)
			return
		var choice_index := int(CHOICE_OVERRIDES.get(next_id, 0))
		if choice_index < 0 or choice_index >= choices.size():
			_failures.append("Invalid smoke choice %d for %s." % [choice_index, next_id])
			return
		var choice: Dictionary = choices[choice_index]
		GameState.apply_choice(event, choice)
		next_id = str(choice.get("follow_up_event", ""))
	if guard >= 12 and not next_id.is_empty():
		_failures.append("Early-flow follow-up chain exceeded the safety limit at %s." % next_id)

func _check_demo_cutoff() -> void:
	GameState.turn = GameState.DEMO_TURN_LIMIT
	_expect(not GameState.has_reached_demo_limit(), "Demo ended before week 24 was completed.")
	GameState.turn = GameState.DEMO_TURN_LIMIT + 1
	_expect(GameState.has_reached_demo_limit(), "Demo did not stop before week 25.")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
