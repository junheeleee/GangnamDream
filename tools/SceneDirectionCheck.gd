extends Node
## Runtime contract check for exhaustive scene direction and fail-closed motion.

const INTENTS := [
	"none", "same_location", "time_cut", "explicit_move", "memory_cut",
	"remote", "activity_enter_return", "finale",
]
const ACTIVITY_IDS := [
	"investment", "job_hunt", "delivery", "racetrack", "holdem", "scalping",
	"casino",
]

var _failures: Array[String] = []

func _ready() -> void:
	_check_event_and_edge_registry()
	_check_background_profiles()
	_check_activity_and_ending_contracts()
	_check_runtime_fail_closed()
	_check_activity_runtime_mapping()
	if _failures.is_empty():
		print(
			"SCENE_DIRECTION_CHECK_OK events=%d backgrounds=%d activities=%d endings=%d" % [
				DataRegistry.get_all_events().size(),
				DataRegistry.scene_direction_manifest.get(
						"background_profiles", {}).size(),
				ACTIVITY_IDS.size(),
				DataRegistry.endings.size(),
			])
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("SCENE_DIRECTION_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)

func _check_event_and_edge_registry() -> void:
	var seen_edges := {}
	for event_variant in DataRegistry.get_all_events():
		if not event_variant is Dictionary:
			continue
		var event := event_variant as Dictionary
		var event_id := str(event.get("id", ""))
		var intent := DataRegistry.get_scene_direction_event_intent(event_id)
		_expect(intent in INTENTS, "%s has invalid intent %s" % [event_id, intent])
		for choice_variant in event.get("choices", []):
			if not choice_variant is Dictionary:
				continue
			var next_id := str((choice_variant as Dictionary).get(
					"follow_up_event", ""))
			if next_id.is_empty():
				continue
			var edge_id := "%s->%s" % [event_id, next_id]
			if seen_edges.has(edge_id):
				continue
			seen_edges[edge_id] = true
			var contract := DataRegistry.get_story_transition(event_id, next_id)
			_expect(not bool(contract.get("unclassified", false)),
					"%s is not classified" % edge_id)
			_expect(str(contract.get("mode", "")) in INTENTS,
					"%s has invalid mode" % edge_id)
			_expect(not str(contract.get("audio_policy", "")).is_empty(),
					"%s has no audio policy" % edge_id)
	var unknown := DataRegistry.get_story_transition(
			"mod_event_not_in_shipping_data", "mod_follow_up")
	_expect(str(unknown.get("mode", "")) == "none",
			"unknown edge inherited a decorative transition")
	_expect(bool(unknown.get("unclassified", false)),
			"unknown edge is not marked for mod diagnostics")

func _check_background_profiles() -> void:
	var office := DataRegistry.get_scene_direction_background_profile("office")
	var rain := DataRegistry.get_scene_direction_background_profile("street_rainy")
	var snow := DataRegistry.get_scene_direction_background_profile(
			"convenience_first_snow_exterior")
	_expect(str(office.get("environment", "")) == "indoor",
			"office is not classified as indoor")
	_expect(str(office.get("effect", "")) == "none",
			"office invents weather")
	_expect(str(rain.get("effect", "")) == "rain",
			"rainy street lost rain")
	_expect(str(rain.get("weather_source", "")) != "none",
			"rainy street has no authored weather source")
	_expect(str(snow.get("effect", "")) == "snow",
			"first-snow exterior lost snow")
	for background_id_variant in DataRegistry.scene_direction_manifest.get(
			"background_profiles", {}):
		var background_id := str(background_id_variant)
		var profile := DataRegistry.get_scene_direction_background_profile(
				background_id)
		_expect(not profile.is_empty(), "%s profile did not load" % background_id)
		if str(profile.get("environment", "")) == "indoor":
			_expect(str(profile.get("effect", "")) not in [
				"rain", "snow", "fog", "fireworks",
			], "%s has an indoor weather effect" % background_id)

func _check_activity_and_ending_contracts() -> void:
	for activity_id in ACTIVITY_IDS:
		var contract := DataRegistry.get_scene_direction_activity_contract(
				activity_id)
		_expect(str(contract.get("mode", "")) == "activity_enter_return",
				"%s lacks activity enter/return mode" % activity_id)
		_expect(not str(contract.get("entry", "")).is_empty(),
				"%s lacks entry treatment" % activity_id)
		_expect(not str(contract.get("return", "")).is_empty(),
				"%s lacks return treatment" % activity_id)
		_expect(not str(contract.get("ambience", "")).is_empty(),
				"%s lacks ambience ownership" % activity_id)
	for ending_variant in DataRegistry.endings:
		if not ending_variant is Dictionary:
			continue
		var ending_id := str((ending_variant as Dictionary).get("id", ""))
		var contract := DataRegistry.get_scene_direction_ending_contract(ending_id)
		_expect(str(contract.get("mode", "")) == "finale",
				"%s lacks finale direction" % ending_id)
		_expect(float(contract.get("reveal_seconds", 0.0)) > 0.0,
				"%s has no reveal duration" % ending_id)
		_expect(str(contract.get("reduced_motion", "")) == "static_fade",
				"%s lacks reduced-motion finale" % ending_id)

func _check_runtime_fail_closed() -> void:
	var story = load("res://scenes/StoryMode.gd").new()
	_expect(story._normalized_story_scene_transition("same_location") == "same_location",
			"same-location runtime normalization changed its meaning")
	_expect(story._normalized_story_scene_transition("legacy_wipe") == "none",
			"unknown runtime transition did not fail closed")
	_expect(story._story_scene_transition_seconds("same_location") == 0.0,
			"same-location runtime still animates a scene wipe")
	story.free()

	var reduced := LivingSceneLayer.build_profile(
			DataRegistry.find_event("arc_season_fireworks_jiyeon_decision"),
			"hangang_riverside", "cg_romance_fireworks_jiyeon",
			{"channel": "in_person", "portrait_role": "present"},
			0.0, true, true)
	_expect(str(reduced.get("camera", "")) == "none",
			"Reduce Motion kept camera travel")
	_expect(float(reduced.get("portrait_breath", 1.0)) == 0.0,
			"Reduce Motion kept portrait breathing")
	_expect(float(reduced.get("motion_scale", 1.0)) <= 0.11,
			"Reduce Motion kept full atmospheric speed")

func _check_activity_runtime_mapping() -> void:
	var game = load("res://scenes/MainGame.gd").new()
	var overlays := {}
	for activity_id in ["racetrack", "holdem", "scalping", "casino", "job_hunt", "delivery"]:
		var overlay := Node.new()
		overlays[activity_id] = overlay
	game.racetrack = overlays["racetrack"]
	game.holdem_club = overlays["holdem"]
	game.scalping_game = overlays["scalping"]
	game.jeongseon_casino = overlays["casino"]
	game.job_hunt_game = overlays["job_hunt"]
	game.aruba_game = overlays["delivery"]
	for activity_id in overlays:
		_expect(game._activity_direction_id(overlays[activity_id]) == activity_id,
				"%s overlay maps to the wrong direction contract" % activity_id)
	for overlay in overlays.values():
		overlay.free()
	game.free()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
