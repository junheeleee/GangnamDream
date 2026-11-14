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
const FULL_STORY_FLOW := preload("res://systems/FullStoryFlow.gd")

var _failures: Array[String] = []
var _shipping_event_count := 0

func _ready() -> void:
	if OS.get_cmdline_user_args().has("--authored-follow-up-variant-only"):
		await _check_authored_follow_up_variant()
		if _failures.is_empty():
			print("AUTHORED_FOLLOW_UP_VARIANT_CHECK_OK alive=1 passed=1 cold=1 foreign=1 wrong_choice=1 no_witness=1 effects_once=1")
			get_tree().quit(0)
		else:
			for failure in _failures:
				push_error("AUTHORED_FOLLOW_UP_VARIANT_CHECK_FAIL: %s" % failure)
			get_tree().quit(1)
		return
	if OS.get_cmdline_user_args().has("--live-root-variant-only"):
		await _check_live_root_variant_resume()
		if _failures.is_empty():
			print("LIVE_ROOT_VARIANT_CHECK_OK fresh_root=exact curation=retained cold_result=closed duplicate=idempotent rejects=4 effects=unchanged prepared_fixture=1 native_play=0")
			get_tree().quit(0)
		else:
			for failure in _failures:
				push_error("LIVE_ROOT_VARIANT_CHECK_FAIL: %s" % failure)
			get_tree().quit(1)
		return
	_check_event_and_edge_registry()
	_check_background_profiles()
	_check_activity_and_ending_contracts()
	_check_runtime_fail_closed()
	_check_activity_runtime_mapping()
	_check_transition_cover_opacity()
	await _check_final_desk_presentation()
	await _check_automatic_terminal_reveal()
	if _failures.is_empty():
		print(
			"SCENE_DIRECTION_CHECK_OK events=%d backgrounds=%d activities=%d endings=%d" % [
				_shipping_event_count,
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
	var shipping_ids := _shipping_event_ids_from_manifest()
	_shipping_event_count = shipping_ids.size()
	var seen_edges := {}
	for event_id_variant in shipping_ids:
		var event_id := str(event_id_variant)
		var event_variant: Variant = DataRegistry.find_event(event_id)
		if not event_variant is Dictionary or (event_variant as Dictionary).is_empty():
			continue
		var event := event_variant as Dictionary
		var intent := DataRegistry.get_scene_direction_event_intent(event_id)
		_expect(intent in INTENTS, "%s has invalid intent %s" % [event_id, intent])
		for choice_variant in event.get("choices", []):
			if not choice_variant is Dictionary:
				continue
			var next_id := str((choice_variant as Dictionary).get(
					"follow_up_event", ""))
			if next_id.is_empty():
				continue
			_check_shipping_edge(event_id, next_id, shipping_ids, seen_edges)
	var raw_edges: Variant = DataRegistry.scene_direction_manifest.get(
			"transition_edges", {})
	_expect(raw_edges is Dictionary, "transition_edges is not a dictionary")
	if raw_edges is Dictionary:
		for edge_id_variant in raw_edges:
			var edge_id := str(edge_id_variant)
			var parts := edge_id.split("->", false, 1)
			_expect(parts.size() == 2, "%s is not a valid transition edge" % edge_id)
			if parts.size() != 2:
				continue
			_check_shipping_edge(
					str(parts[0]), str(parts[1]), shipping_ids, seen_edges)
	var unknown := DataRegistry.get_story_transition(
			"mod_event_not_in_shipping_data", "mod_follow_up")
	_expect(str(unknown.get("mode", "")) == "none",
			"unknown edge inherited a decorative transition")
	_expect(bool(unknown.get("unclassified", false)),
			"unknown edge is not marked for mod diagnostics")


func _shipping_event_ids_from_manifest() -> Dictionary:
	var shipping_ids := {}
	var raw_intents: Variant = DataRegistry.scene_direction_manifest.get(
			"event_intents", {})
	_expect(raw_intents is Dictionary, "event_intents is not a dictionary")
	if not raw_intents is Dictionary:
		return shipping_ids
	var intent_groups := raw_intents as Dictionary
	for intent_variant in intent_groups:
		var intent := str(intent_variant)
		_expect(intent in INTENTS, "event_intents has unknown group %s" % intent)
	for intent_variant in INTENTS:
		var intent := str(intent_variant)
		_expect(intent_groups.has(intent),
				"event_intents is missing group %s" % intent)
		var raw_event_ids: Variant = intent_groups.get(intent, [])
		_expect(raw_event_ids is Array,
				"event_intents.%s is not an array" % intent)
		if not raw_event_ids is Array:
			continue
		for event_id_variant in raw_event_ids:
			var event_id := str(event_id_variant)
			_expect(not event_id.is_empty(),
					"event_intents.%s has an empty ID" % intent)
			if event_id.is_empty():
				continue
			var duplicate := shipping_ids.has(event_id)
			_expect(not duplicate,
					"%s has duplicate event intents" % event_id)
			if duplicate:
				continue
			shipping_ids[event_id] = intent
			var event_variant: Variant = DataRegistry.find_event(event_id)
			var loaded := event_variant is Dictionary \
					and not (event_variant as Dictionary).is_empty()
			_expect(loaded, "%s manifest event did not load" % event_id)
			if not loaded:
				continue
			_expect(str((event_variant as Dictionary).get("id", "")) == event_id,
					"%s manifest event loaded under another ID" % event_id)
			_expect(
					DataRegistry.get_scene_direction_event_intent(event_id) == intent,
					"%s manifest intent did not load as %s" % [event_id, intent])
	return shipping_ids


func _check_shipping_edge(
		source_id: String,
		target_id: String,
		shipping_ids: Dictionary,
		seen_edges: Dictionary,
) -> void:
	var edge_id := "%s->%s" % [source_id, target_id]
	if seen_edges.has(edge_id):
		return
	seen_edges[edge_id] = true
	_expect(shipping_ids.has(source_id),
			"%s has a non-shipping source" % edge_id)
	_expect(shipping_ids.has(target_id),
			"%s has a non-shipping target" % edge_id)
	var contract := DataRegistry.get_story_transition(source_id, target_id)
	_expect(not bool(contract.get("unclassified", false)),
			"%s is not classified" % edge_id)
	_expect(str(contract.get("mode", "")) in INTENTS,
			"%s has invalid mode" % edge_id)
	_expect(not str(contract.get("audio_policy", "")).is_empty(),
			"%s has no audio policy" % edge_id)

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


func _check_authored_follow_up_variant() -> void:
	var qa := OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	if not qa.begins_with("GangnamDream_StoryNameplateQA_") \
			or OS.get_user_data_dir().get_file() != qa:
		_expect(false, "pre-autoload isolation required")
		return
	var first := "arc_daeun_wedding_day"
	var source := "arc_daeun_wedding_groom_side"
	var variant := "arc_daeun_wedding_groom_side_father_passed"
	var walk := "arc_daeun_wedding_walk"
	var aisle := "arc_daeun_wedding_aisle"
	for passed in [false, true]:
		GameState.start_new_game("WeddingFollowUpFixture")
		_expect(FULL_STORY_FLOW.initialize_fresh_run(), "fixture owner refused")
		GameState.flags["father_passed"] = passed
		GameState.mental = 50
		_expect(FULL_STORY_FLOW.begin_chain([first]) and _apply_and_close_test_choice(first),
			"wedding opening did not reserve the groom-side edge")
		var event_id: String = variant if passed else source
		var pending: Dictionary = GameState.serialize().duplicate(true)
		_expect(not FULL_STORY_FLOW.bind_current_live_root("arc_year4_close_father_passed") \
			and GameState.serialize() == pending, "unrelated alias admitted")
		if not passed:
			_expect(not FULL_STORY_FLOW.bind_current_live_root(variant), "living variant admitted")
		else:
			_expect(not FULL_STORY_FLOW.close_result(source, 0), "dead run closed living source")
		_expect(FULL_STORY_FLOW.bind_current_live_root(event_id) \
			and GameState.serialize() == pending, "valid follow-up could not bind read-only")
		_expect(not FULL_STORY_FLOW.close_result(event_id, 0), "missing witness accepted")
		var event: Dictionary = DataRegistry.find_event(event_id)
		_expect(GameState.apply_choice(event, event["choices"][0]), "could not apply exact option")
		var applied: Dictionary = GameState.serialize().duplicate(true)
		# Round-trip the already-applied result through the game's own state serializer.
		GameState.load_from_dict(applied.duplicate(true))
		var cold: Dictionary = GameState.serialize().duplicate(true)
		_expect(not FULL_STORY_FLOW.close_result(event_id, 1) \
			and GameState.serialize() == cold, "wrong receipt accepted")
		if passed:
			SaveManager.set("_loaded_resume_context", {
				"kind": "story", "scene": "res://scenes/StoryMode.tscn",
				"return_scene": "res://scenes/MainGame.tscn", "event_id": event_id,
				"queue": [], "phase": "result", "pending_result_choice_index": 0,
				"pending_follow_up": walk, "paragraph_index": 2,
				"paragraph_was_typing": false,
			})
			GameState.pending_story_queue = [event_id]
			var story: Control = load("res://scenes/StoryMode.tscn").instantiate()
			add_child(story)
			await get_tree().process_frame
			await get_tree().process_frame
			_expect(story.get("_pending_after_result") and story.get("_pending_result_choice_index") == 0,
				"StoryMode did not restore the already-applied result")
			story.set("_typing", false)
			story.set("_para_index", (story.get("_paragraphs") as Array).size())
			story.call("_after_result")
			_expect(str((story.get("_current") as Dictionary).get("id", "")) == walk \
				and not story.get("_pending_after_result"), "StoryMode did not close into the aisle walk")
			remove_child(story)
			story.free()
			BGMPlayer.stop()
			await get_tree().create_timer(0.2).timeout
		else:
			_expect(FULL_STORY_FLOW.bind_current_live_root(event_id) \
				and FULL_STORY_FLOW.close_result(event_id, 0), "living follow-up failed to close")
		_expect(FULL_STORY_FLOW.valid_session(), "closed edge did not validate")
		var closed: Dictionary = GameState.serialize().duplicate(true)
		_expect(GameState.mental == 52 and GameState.event_log == cold["event_log"] \
			and FULL_STORY_FLOW.close_result(event_id, 0) \
			and GameState.serialize() == closed, "effects or receipt replayed")
		_expect(FULL_STORY_FLOW.snapshot()["chain"]["roots"] == [first] \
			and FULL_STORY_FLOW.snapshot()["chain"]["pending_event_ids"] == [walk] \
			and not FULL_STORY_FLOW.close_chain(), "authored tail was skipped")
		_expect(_apply_and_close_test_choice(walk) and _apply_and_close_test_choice(aisle) \
			and FULL_STORY_FLOW.close_chain() and FULL_STORY_FLOW.valid_session(), "wedding tail failed")
		var receipts: Array = FULL_STORY_FLOW.snapshot()["chain"]["closed_results"]
		_expect(receipts.map(func(row: Dictionary): return row["event_id"]) \
			== [first, event_id, walk, aisle], "actual receipts not in authored order")


func _apply_and_close_test_choice(event_id: String) -> bool:
	var event: Dictionary = DataRegistry.find_event(event_id)
	var choice: Dictionary = event["choices"][0]
	return FULL_STORY_FLOW.bind_current_live_root(event_id) \
		and GameState.apply_choice(event, choice) \
		and FULL_STORY_FLOW.close_result(event_id, 0, GameState.is_expression_choice(choice))


func _check_live_root_variant_resume() -> void:
	var qa := OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	if not qa.begins_with("GangnamDream_StoryNameplateQA_") \
			or OS.get_user_data_dir().get_file() != qa:
		_expect(false, "pre-autoload isolation required")
		return
	# Private copied fixtures, never a path into the user's active namespace.
	var before: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(
		"res://__qa_year4_prechoice.json"))
	var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(
		"res://__qa_year4_result.json"))
	var source := "arc_year4_close"
	var live := "arc_year4_close_father_passed"
	GameState.load_from_dict(before["state"].duplicate(true))
	_expect(GameState.turn == 192 and FULL_STORY_FLOW.valid_session(), "fixture entry invalid")
	var game = load("res://scenes/MainGame.gd").new()
	game.set_meta("_screenshot_qa_static_surface", true)
	game.call("_go_story_mode", [source])
	_expect(GameState.pending_story_queue == [live, "arc_year4_scene"] \
		and FULL_STORY_FLOW.snapshot()["chain"]["roots"] == GameState.pending_story_queue,
		"fresh year root did not reserve exact variant plus curation")
	game.free()
	# Old result contains its one real choice already. Binding must not apply it again.
	GameState.load_from_dict(saved["state"].duplicate(true))
	var original: Dictionary = GameState.serialize().duplicate(true)
	for rejected in ["arc_year1_close_father_passed", "arc_year4_scene"]:
		_expect(not FULL_STORY_FLOW.bind_current_live_root(rejected) \
			and GameState.serialize() == original, "unrelated root rebound")
	GameState.flags.erase("father_passed")
	GameState.flags.erase("arc_father_passing_seen")
	GameState.cast["father"]["stage"] = "unknown"
	var living: Dictionary = GameState.serialize().duplicate(true)
	_expect(not FULL_STORY_FLOW.bind_current_live_root(live) \
		and GameState.serialize() == living, "living father admitted passed variant")
	GameState.load_from_dict(saved["state"].duplicate(true))
	# Keep the retained suffix at 100 so historical truncated receipts remain
	# independently valid; only the current selected tuple is absent.
	GameState.event_log[-1]["choice_index"] = 0
	_expect(FULL_STORY_FLOW.bind_current_live_root(live), "no-receipt fixture root bind failed")
	var no_receipt: Dictionary = GameState.serialize().duplicate(true)
	_expect(not FULL_STORY_FLOW.close_result(live, 1) \
		and GameState.serialize() == no_receipt, "missing applied receipt accepted")
	GameState.load_from_dict(saved["state"].duplicate(true))
	var money_before: float = GameState.money
	var health_before: int = GameState.health
	var mental_before: int = GameState.mental
	var events_before: int = GameState.events_seen
	var log_before: Array = GameState.event_log.duplicate(true)
	SaveManager.set("_loaded_resume_context", saved["resume"].duplicate(true))
	GameState.pending_story_queue = [live, "arc_year4_scene"]
	var story: Control = load("res://scenes/StoryMode.tscn").instantiate()
	add_child(story)
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(story.get("_pending_after_result") and story.get("_pending_result_choice_index") == 1,
		"cold result did not restore its exact selected option")
	story.set("_typing", false)
	story.set("_para_index", (story.get("_paragraphs") as Array).size())
	story.call("_after_result")
	_expect(str((story.get("_current") as Dictionary).get("id", "")) == "arc_year4_scene" \
		and not story.get("_pending_after_result") and FULL_STORY_FLOW.valid_session(),
		"cold result did not close into year curation")
	var closed: Dictionary = GameState.serialize().duplicate(true)
	_expect(FULL_STORY_FLOW.close_result(live, 1) and GameState.serialize() == closed,
		"duplicate result close mutated state")
	_expect(GameState.money == money_before and GameState.health == health_before \
		and GameState.mental == mental_before and GameState.events_seen == events_before \
		and GameState.event_log == log_before, "result resume reapplied choice/economy")
	remove_child(story)
	story.free()
	BGMPlayer.stop()
	await get_tree().create_timer(0.2).timeout


func _close_prepared_story_root(event_id: String) -> bool:
	# Synthetic fixture preparation through real choice/receipt APIs, not played weeks.
	if not FULL_STORY_FLOW.begin_chain([event_id]):
		return false
	for _guard in range(32):
		var pending: Array = FULL_STORY_FLOW.snapshot()["chain"]["pending_event_ids"]
		if pending.is_empty():
			return FULL_STORY_FLOW.close_chain()
		var next_id := str(pending[0])
		var event: Dictionary = DataRegistry.find_event(next_id)
		var choices: Array = event.get("choices", [])
		if choices.is_empty() or not GameState.apply_choice(event, choices[0]) \
				or not FULL_STORY_FLOW.close_result(next_id, 0,
						GameState.is_expression_choice(choices[0])):
			return false
	return false


func _check_transition_cover_opacity() -> void:
	var before: float = GameState.moral_tint
	var failures_before := _failures.size()
	for tint in [-100.0, -50.0, 0.0, 50.0, 100.0]:
		GameState.moral_tint = tint
		var covered: Color = SceneTransition._transition_color(1.0)
		for alpha in [-0.1, 0.0, 0.001, 0.5, 0.999, 1.0, 1.1]:
			var actual: Color = SceneTransition._transition_color(alpha)
			_expect(is_equal_approx(actual.a, clampf(alpha, 0.0, 1.0)),
					"transition cover opacity leaked tint=%s alpha=%s" % [tint, alpha])
			_expect(Vector3(actual.r, actual.g, actual.b).is_equal_approx(
					Vector3(covered.r, covered.g, covered.b)), "transition fade changed its tint RGB")
	GameState.moral_tint = before
	if _failures.size() == failures_before:
		print("SCENE_DIRECTION_TRANSITION_COVER_OK tints=5 alpha_boundaries=7 opaque=1")


func _check_final_desk_presentation() -> void:
	var qa_namespace := OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	if not qa_namespace.begins_with("GangnamDream_StoryNameplateQA_") \
			or OS.get_user_data_dir().get_file() != qa_namespace:
		print("SCENE_DIRECTION_FINAL_DESK_NOT_RUN pre_autoload_isolation_required=1")
		return
	var failures_before := _failures.size()
	var original: Dictionary = GameState.serialize().duplicate(true)
	var original_sfx: bool = AudioManager.sfx_enabled
	AudioManager.sfx_enabled = false
	var first := "arc_final_countdown"
	var second := "arc_final_week"
	var room := BGMPlayer._load_ambience("apartment")
	_expect(room != null, "final desk dry room recording failed to load")
	var edge := DataRegistry.get_story_transition(first, second)
	_expect(str(edge.get("mode")) == "same_location" and str(edge.get("audio_policy")) == "continue" \
			and str(edge.get("from_surface")) == "current_housing" \
			and str(edge.get("to_surface")) == "current_housing", "final desk chain lost its same-room direction")
	for fixture in [
			["gosiwon", false, false, "goshiwon_room", "goshiwon_room"],
			["oneroom", false, false, "apartment", "oneroom_apartment"],
			["villa", false, false, "apartment", "oneroom_apartment"],
			["apartment", false, false, "gangnam_apartment", "gangnam_apartment"],
			["gangnam", false, false, "gangnam_apartment", "gangnam_apartment"],
			["gosiwon", true, false, "daeun_newlywed_home", "daeun_newlywed_home_night"],
			["villa", true, true, "apartment", "oneroom_apartment"],
	]:
		GameState.start_new_game("FinalDeskFixture")
		GameState.turn = 240
		GameState.month = 12
		GameState.age = 37
		GameState.housing = str(fixture[0])
		GameState.flags = {"prologue_done": true}
		if fixture[1]:
			GameState.flags["arc_daeun_wedding_day_seen"] = true
		if fixture[2]:
			GameState.flags["daeun_divorced"] = true
		GameState.pending_story_queue = [first]
		var story: Control = load("res://scenes/StoryMode.tscn").instantiate()
		add_child(story)
		await get_tree().process_frame
		var expected_path := "res://assets/backgrounds/%s.png" % str(fixture[4])
		var background := story.get("_bg_img") as TextureRect
		_expect(str((story.get("_current") as Dictionary).get("id")) == first \
				and str(story.get("_event_background_id")) == str(fixture[3]) \
				and is_instance_valid(background) and background.texture != null \
				and background.texture.resource_path == expected_path, "final signature loaded the wrong home: %s" % [fixture])
		_expect(BGMPlayer._ambience_player.stream == room and BGMPlayer._ambience_player.playing \
				and not BGMPlayer._season_player.playing and not BGMPlayer._human_ambience_player.playing \
				and not str(story.get_meta("living_scene_effect")) in ["rain", "snow"] \
				and BGMPlayer._current_key.is_empty(), "final signature introduced outdoor ambience, weather or early score")
		story.call("_play_current_paragraph_audio", 3)
		await get_tree().create_timer(0.15).timeout
		var room_position: float = BGMPlayer._ambience_player.get_playback_position()
		var music_position: float = BGMPlayer._player_a.get_playback_position()
		_expect(BGMPlayer._current_key == "reckoning" and BGMPlayer._player_a.playing,
				"final signature failed to enter reckoning on the authored paragraph")
		story.call("_on_choice", 0)
		_expect(bool(story.get("_pending_after_result")) and str(story.get("_pending_follow_up")) == second,
				"final signature failed to enter the authored result and follow-up")
		story.set("_typing", false)
		story.set("_para_index", (story.get("_paragraphs") as Array).size())
		story.call("_after_result")
		await get_tree().process_frame
		_expect(str((story.get("_current") as Dictionary).get("id")) == second \
				and str(story.get_meta("story_transition_mode")) == "same_location" \
				and background.texture != null and background.texture.resource_path == expected_path \
				and not str(story.get_meta("living_scene_effect")) in ["rain", "snow"],
				"final week did not stay indoors in the same room: %s" % [fixture])
		_expect(BGMPlayer._ambience_player.stream == room \
				and BGMPlayer._ambience_player.get_playback_position() + 0.05 >= room_position \
				and BGMPlayer._current_key == "reckoning" \
				and BGMPlayer._player_a.get_playback_position() + 0.05 >= music_position,
				"same-room handoff restarted the room tone or score")
		remove_child(story)
		story.free()
		BGMPlayer.stop()
		await get_tree().create_timer(0.08).timeout
	var exterior := "arc_final_countdown_property_not_executed"
	var custody := "arc_y5_father_trace_custody"
	for rear_table in ["convenience_rear_comparison", "convenience_rear_table_clear"]:
		var table_texture := ImageRegistry.get_background(rear_table)
		var table_profile: Dictionary = DataRegistry.scene_direction_manifest.get("background_profiles", {}).get(rear_table, {})
		_expect(table_texture == "res://assets/backgrounds/%s_v1.png" % rear_table \
				and ImageRegistry.has_texture(table_texture) and table_profile.get("effect") == "none" \
				and table_profile.get("weather_source") == "none", "W224 rear table asset or weather drifted")
	_expect(DataRegistry.find_event(custody).get("background") == "convenience_rear_comparison" \
			and DataRegistry.get_story_presentation(custody).get("scene_location") == "convenience_store", \
			"W224 should begin at the same store's rear table")
	var intake_id := "arc_y5_name_on_line_daeun_routed"
	var intake_background := "finale_intake_blue_pen"
	var intake_event: Dictionary = DataRegistry.find_event(intake_id)
	var intake_path := ImageRegistry.get_background(intake_background)
	var intake_profile: Dictionary = DataRegistry.scene_direction_manifest.get("background_profiles", {}).get(intake_background, {})
	_expect(intake_event.get("background") == intake_background and not intake_event.has("cg") \
			and intake_path == "res://assets/backgrounds/finale_intake_blue_pen_v1.png" and ImageRegistry.has_texture(intake_path) \
			and intake_profile.get("environment") == "indoor" and intake_profile.get("effect") == "none" \
			and intake_profile.get("weather_source") == "none" \
			and DataRegistry.get_story_presentation(intake_id).get("scene_location") == "office", \
			"W227 needs its own dry counter without changing the logical location")
	BGMPlayer.set_ambience("office")
	BGMPlayer.set_season_ambience("winter")
	_expect(BGMPlayer._ambience_player.playing and BGMPlayer._human_ambience_player.playing \
			and BGMPlayer._season_player.playing, "W227 fixture did not start the unrelated layers")
	BGMPlayer.update_event_ambience(intake_event, "", intake_background)
	_expect(BGMPlayer._current_ambience_key.is_empty() and not BGMPlayer._ambience_player.playing \
			and BGMPlayer._current_human_ambience_key.is_empty() and not BGMPlayer._human_ambience_player.playing \
			and BGMPlayer._current_season_key.is_empty() and not BGMPlayer._season_player.playing, \
			"W227 kept unrelated typing, public interior, or seasonal ambience")
	var outdoor_event: Dictionary = DataRegistry.find_event(exterior)
	var notebook_background := "gangnam_boulevard_final_notebook"
	var notebook_path := "res://assets/backgrounds/gangnam_boulevard_final_notebook_v1.png"
	var profile: Dictionary = DataRegistry.scene_direction_manifest.get("background_profiles", {}).get(notebook_background, {})
	_expect(str(outdoor_event.get("background")) == notebook_background \
			and not outdoor_event.has("cg") and ImageRegistry.get_background(notebook_background) == notebook_path \
			and ImageRegistry.has_texture(notebook_path) and profile.get("environment") == "outdoor" \
			and profile.get("effect") == "none" and profile.get("weather_source") == "none" \
			and DataRegistry.get_story_presentation(exterior).get("scene_location") == "gangnam_night",
			"actual outdoor property variant was incorrectly moved inside")
	var outdoor_to_home: Dictionary = DataRegistry.get_story_transition(exterior, "arc_y5_final_week_daeun_outbound")
	_expect(outdoor_to_home.get("mode") == "time_cut" and outdoor_to_home.get("from_surface") == "gangnam_night" \
			and outdoor_to_home.get("to_surface") == "current_housing" and outdoor_to_home.get("audio_policy") == "crossfade",
			"outdoor signature lost the authored time cut home")
	BGMPlayer.set_ambience("street")
	BGMPlayer.set_season_ambience("winter")
	_expect(BGMPlayer._ambience_player.playing and BGMPlayer._human_ambience_player.playing \
			and BGMPlayer._season_player.playing, "outdoor signature fixture did not start all three layers")
	BGMPlayer.update_event_ambience(outdoor_event, "", notebook_background)
	_expect(BGMPlayer._current_ambience_key.is_empty() and not BGMPlayer._ambience_player.playing \
			and BGMPlayer._current_human_ambience_key.is_empty() and not BGMPlayer._human_ambience_player.playing \
			and BGMPlayer._current_season_key.is_empty() and not BGMPlayer._season_player.playing,
			"outdoor signature kept an unrelated street, crowd, or weather recording")
	GameState.call("_restore_serialized_snapshot_exact", original)
	AudioManager.sfx_enabled = original_sfx
	EventManager.current_event = {}
	if _failures.size() == failures_before:
		print("SCENE_DIRECTION_FINAL_DESK_OK housing_states=7 same_room=7 score_continue=7 outdoor_preserved=1 intake_isolated=1")


func _check_full_story_shell(prepared_state: Dictionary) -> void:
	var failures_before := _failures.size()
	# Non-owner compatibility UI remains visible, including ordinary activity return.
	GameState.start_new_game("LegacyShellFixture")
	var legacy: Control = load("res://scenes/MainGame.tscn").instantiate()
	legacy.set_meta("_screenshot_qa_static_surface", true)
	add_child(legacy)
	var legacy_root: Control = legacy.get("_main_ui_root")
	_expect(not FULL_STORY_FLOW.owns_session() and legacy_root.visible,
			"non-owner legacy shell disappeared during construction")
	legacy.call("_enter_minigame_overlay", legacy.get("racetrack"))
	legacy.call("_exit_minigame_overlay")
	_expect(legacy_root.visible, "non-owner legacy activity return lost its shell")
	remove_child(legacy)
	legacy.free()
	BGMPlayer.stop()
	await get_tree().create_timer(0.1).timeout
	GameState.call("_restore_serialized_snapshot_exact", prepared_state)
	GameState.health = 100
	GameState.mental = 100
	var game: Control = load("res://scenes/MainGame.tscn").instantiate()
	game.set_meta("_screenshot_qa_static_surface", true)
	add_child(game)
	var shell: Control = game.get("_main_ui_root")
	var modal: Control = game.get("modal_layer")
	_expect(not shell.visible, "full-owner legacy shell visible in first ready frame")
	_expect(not shell.is_ancestor_of(modal), "full-owner modal was hidden inside legacy shell")
	# Direct activity panels remain siblings and do not restore AP on return.
	var activity: Control = game.get("racetrack")
	game.call("_enter_minigame_overlay", activity)
	activity.visible = true
	_expect(activity.is_visible_in_tree() and not shell.visible,
			"hiding legacy shell concealed the legitimate direct activity")
	activity.visible = false
	game.call("_exit_minigame_overlay")
	_expect(not shell.visible, "full-owner activity return exposed the legacy shell")
	game.call("_on_core_loop_v2_planner_closed")
	_expect(not shell.visible, "late planner callback exposed the full-owner legacy shell")
	await get_tree().process_frame
	_expect(not shell.visible, "deferred planner focus restored the full-owner legacy shell")
	# Exercise the real routine/calendar/summary and confirmation handoff. Static
	# ownership suppresses only actual scene replacement, not these production APIs.
	game.call("_full_story_continue_week", 4)
	_expect(GameState.turn == 5 and not GameState.is_game_over \
			and game.get("_modal_kind") == "full_story_month_cash" and modal.visible,
			"full-owner automatic week did not retain its legitimate month summary")
	_expect(not shell.visible, "full-owner automatic week exposed the legacy shell")
	game.call("_confirm_full_story_month_cash", 4)
	_expect(not shell.visible and not modal.visible and not GameState.pending_story_queue.is_empty(),
			"month summary confirmation exposed AP before the next story handoff")
	await get_tree().process_frame
	_expect(not shell.visible, "full-owner legacy shell returned on a deferred frame")
	remove_child(game)
	game.free()
	BGMPlayer.stop()
	await get_tree().create_timer(0.1).timeout
	GameState.call("_restore_serialized_snapshot_exact", prepared_state)
	if _failures.size() == failures_before:
		print("SCENE_DIRECTION_FULL_OWNER_SHELL_OK first_frame=hidden automatic_week=hidden summary_handoff=hidden activity_return=hidden nonowner=visible prepared_fixture=1 native_play=0")


func _check_automatic_terminal_reveal() -> void:
	# The legacy pure-check lane must not touch ordinary player storage. Only the
	# pre-autoload bootstrap can supply this distinct, fresh user-data namespace.
	var qa_namespace := OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	var pattern := RegEx.new()
	if pattern.compile("^GangnamDream_StoryNameplateQA_[0-9a-f]{32}$") != OK \
			or pattern.search(qa_namespace) == null or OS.get_user_data_dir().get_file() != qa_namespace:
		print("SCENE_DIRECTION_TERMINAL_REVEAL_NOT_RUN pre_autoload_isolation_required=1")
		return
	var failures_before := _failures.size()
	var original: Dictionary = GameState.serialize().duplicate(true)
	var previous_language: String = LocaleManager.language
	var meta_before: Dictionary = MetaProgression.data.duplicate(true)
	var unlocks_before: Dictionary = (MetaProgression.get("_new_this_run") as Dictionary).duplicate(true)
	var sfx_before: bool = AudioManager.sfx_enabled
	AudioManager.sfx_enabled = false # Visual contract only; no retained ending-stinger voices.
	GameState.start_new_game("TerminalRevealFixture")
	LocaleManager.language = "en"
	var prepared := FULL_STORY_FLOW.initialize_fresh_run() \
			and _close_prepared_story_root("story_flashforward")
	if prepared and not FULL_STORY_FLOW.snapshot()["read_receipts"].get("1", []).any(
			func(row: Dictionary) -> bool: return row.get("event_id") == "chapter_card_33"):
		prepared = _close_prepared_story_root("chapter_card_33")
	for prior_turn in range(1, 4):
		if not prepared or not FULL_STORY_FLOW.apply_background_for_turn(prior_turn):
			prepared = false
			break
		GameState.advance_calendar()
		prepared = FULL_STORY_FLOW.complete_turn(prior_turn)
	prepared = prepared and _close_prepared_story_root("arc_temptation_01")
	_expect(prepared and GameState.turn == 4 and FULL_STORY_FLOW.ready_to_advance(),
			"terminal reveal fixture could not prepare the real automatic W4 boundary")
	if prepared:
		await _check_full_story_shell(GameState.serialize().duplicate(true))
		# Start alive. The ordinary W4 routine is health-neutral; the existing
		# month-end pressure then selects burnout. No ending is forced by this test.
		GameState.health = 2
		GameState.mental = 80
		GameState.moral_tint = 100.0
		var game: Control = load("res://scenes/MainGame.tscn").instantiate()
		game.set_meta("_screenshot_qa_static_surface", true)
		add_child(game)
		await get_tree().process_frame
		await get_tree().process_frame
		# Recreate the still-opaque StoryMode return, not the already-fatal branch
		# which had its own fade-in and therefore missed the real regression.
		var transition_tween: Tween = SceneTransition.get("_tween")
		if transition_tween:
			transition_tween.kill()
		SceneTransition._set_transition_alpha(1.0)
		var cover: ColorRect = SceneTransition.get("_overlay")
		cover.mouse_filter = Control.MOUSE_FILTER_STOP
		GameState.flags["foreground_story_turn"] = 4
		game.remove_meta("_screenshot_qa_static_surface")
		_expect(not GameState.is_game_over and GameState.health == 2,
				"automatic terminal fixture entered through an already-fatal shortcut")
		game.call("_continue_after_story")
		await get_tree().process_frame
		await get_tree().process_frame
		_expect(GameState.is_game_over and GameState.health == 0 and GameState.turn == 4 \
				and game.get("_ending_id") == "burnout",
				"automatic month-end path did not select the original burnout ending")
		var terminal: Dictionary = GameState.serialize().duplicate(true)
		await get_tree().create_timer(0.65).timeout
		_expect(float(SceneTransition.get("_transition_alpha")) <= 0.001 \
				and cover.color.a <= 0.001 and cover.mouse_filter == Control.MOUSE_FILTER_IGNORE,
				"automatic terminal ending remained covered or input-blocked")
		var modal: Control = game.get("modal_layer")
		var body: Control = game.get("modal_body")
		_expect(modal.is_visible_in_tree() and game.get("_modal_kind") == "ending" \
				and body.get_child_count() > 0,
				"automatic terminal ending did not retain its visible first page")
		_expect(GameState.serialize() == terminal,
				"terminal reveal tween changed the terminal game/economy/save state")
		await get_tree().create_timer(0.5).timeout # Finish the ending background's own reveal.
		remove_child(game)
		game.free()
		BGMPlayer.stop()
		await get_tree().create_timer(0.2).timeout # Let stopped fixture playback retire.
	GameState.call("_restore_serialized_snapshot_exact", original)
	MetaProgression.data = meta_before
	MetaProgression.set("_new_this_run", unlocks_before)
	AudioManager.sfx_enabled = sfx_before
	LocaleManager.language = previous_language
	if _failures.size() == failures_before:
		print("SCENE_DIRECTION_TERMINAL_REVEAL_OK automatic_month_end=1 cover=0 input=ignore terminal_state=unchanged prepared_fixture=1 native_play=0")
