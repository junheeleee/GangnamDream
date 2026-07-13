extends Node
## CGRuntimeCheck — verifies that event/endings "cg" keys reach runtime UI.
##
## Run:
##   /Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot --headless res://tools/CGRuntimeCheck.tscn

var _failures: Array[String] = []

func _ready() -> void:
	await _check_story_mode_cg()
	_check_date_milestone_season_contract()
	_check_first_snow_season_contract()
	_check_special_story_season_contract()
	_check_wedding_night_reachability_contract()
	_check_transport_background_contract()
	_check_divorce_ending_route_contract()
	_check_gambling_recovery_chain_contract()
	await _check_ending_cg()
	if _failures.is_empty():
		print("CG_RUNTIME_CHECK_OK")
		get_tree().quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		get_tree().quit(1)

func _check_story_mode_cg() -> void:
	await _check_story_event_cg("arc_intro_01_meal", "cg_demo_first_interview")
	await _check_story_event_cg("arc_jiyeon_01_crash", "cg_jiyeon_crash")
	await _check_story_event_cg("arc_daeun_01_meet", "cg_demo_daeun_first_kindness")
	await _check_story_event_cg("arc_father_01_call", "cg_demo_father_first_call")
	await _check_story_event_cg("arc_season_sea_daeun", "cg_romance_sea_daeun")
	await _check_story_event_cg("arc_season_sea_jiyeon", "cg_romance_sea_jiyeon")
	await _check_story_event_cg("arc_season_fireworks_daeun", "cg_romance_fireworks_daeun")
	await _check_story_event_cg("arc_season_fireworks_jiyeon", "cg_romance_fireworks_jiyeon")
	await _check_story_event_cg("arc_season_cherry_daeun", "cg_romance_cherry_daeun")
	await _check_story_event_cg("arc_season_cherry_jiyeon", "cg_romance_cherry_jiyeon")
	await _check_story_event_cg("arc_season_snow_daeun", "cg_romance_first_snow_daeun")
	await _check_story_event_cg("arc_season_snow_jiyeon", "cg_romance_first_snow_jiyeon")
	await _check_story_event_cg("arc_daeun_first_kiss", "cg_romance_first_kiss_daeun")
	await _check_story_event_cg("arc_jiyeon_first_kiss", "cg_romance_first_kiss_jiyeon")
	await _check_story_event_cg("arc_date_namsan_lock_daeun", "cg_romance_namsan_lock_daeun")
	await _check_story_event_cg("arc_date_namsan_lock_jiyeon", "cg_romance_namsan_lock_jiyeon")
	await _check_story_event_cg("arc_date_park_daeun", "cg_romance_amusement_lost_child_daeun")
	await _check_story_event_cg("arc_jiyeon_narrow_room_2", "cg_romance_narrow_room_jiyeon")
	await _check_story_event_paragraph_backgrounds("arc_date_namsan_daeun", [
		"namsan_cable_car",
		"namsan_tonkatsu_restaurant",
		"namsan_observation_deck",
		"namsan_observation_deck",
	])
	await _check_story_event_paragraph_backgrounds("arc_date_park_jiyeon", [
		"amusement_roller_coaster",
		"amusement_photo_booth",
	])
	await _check_story_choice_result_visual(
		"arc_date_park_jiyeon", 0, "cg_romance_amusement_photo_strip_jiyeon", true)
	await _check_story_choice_result_visual(
		"arc_date_park_jiyeon", 1, "amusement_roller_coaster", false)
	await _check_story_choice_result_visual(
		"arc_date_park_daeun", 1, "amusement_roller_coaster", false)
	await _check_story_shared_result_cg(
			"arc_daeun_hometown_2", 0, "daeun_mother_home_dining",
			"cg_romance_hometown_night_bus_daeun", 1)
	await _check_story_shared_result_cg(
			"arc_daeun_wedding_night", 0, "daeun_newlywed_home",
			"cg_romance_wedding_morning_daeun", 1)
	await _check_story_shared_result_cg(
			"arc_jiyeon_wedding_night", 0, "jiyeon_newlywed_home",
			"cg_romance_wedding_morning_jiyeon", 1)
	await _check_story_event_portrait_reveal("arc_jiyeon_narrow_room_1", "jiyeon_narrow_door", 2)
	await _check_story_event_prelude_visual(
		"arc_season_snow_daeun", "convenience_first_snow_exterior", "daeun_first_snow")
	await _check_story_event_prelude_visual(
		"arc_season_snow_jiyeon", "jiyeon_sedan_first_snow", "jiyeon_first_snow")
	_check_all_story_cg_contracts()
	_check_romance_visual_manifest()

func _check_story_event_cg(event_id: String, cg_id: String) -> void:
	var expected_path := ImageRegistry.get_cg(cg_id)
	if expected_path == "":
		_failures.append("missing %s" % cg_id)
		return

	GameState.pending_story_queue = [event_id]
	var story_scene := load("res://scenes/StoryMode.tscn") as PackedScene
	var story: Node = story_scene.instantiate()
	add_child(story)
	await get_tree().process_frame
	await get_tree().process_frame

	var bg_img := story.get("_bg_img") as TextureRect
	var event: Dictionary = DataRegistry.find_event(event_id)
	var reveal_paragraph := int(event.get("cg_reveal_paragraph", 0))
	if reveal_paragraph > 0:
		if bg_img != null and bg_img.texture != null and bg_img.texture.resource_path == expected_path:
			_failures.append("StoryMode revealed %s before paragraph %d" % [event_id, reveal_paragraph])
		for _paragraph in range(reveal_paragraph):
			if bool(story.get("_typing")):
				story.call("_on_advance")
			story.call("_on_advance")
			await get_tree().process_frame
			await get_tree().process_frame

	if bg_img == null or bg_img.texture == null:
		_failures.append("StoryMode did not assign a background texture for %s" % event_id)
	elif bg_img.texture.resource_path != expected_path:
		_failures.append("StoryMode %s cg mismatch: expected %s, got %s" % [event_id, expected_path, bg_img.texture.resource_path])

	var portrait_frame := story.get("_portrait_frame") as Control
	if portrait_frame != null and portrait_frame.visible:
		_failures.append("StoryMode should hide portrait frame when %s cg is active" % event_id)
	var hud_panel := story.get("_hud_panel") as Control
	if hud_panel != null and hud_panel.visible:
		_failures.append("StoryMode should hide HUD when %s cg is active" % event_id)

	remove_child(story)
	story.queue_free()

func _check_story_event_paragraph_backgrounds(event_id: String, expected_ids: Array) -> void:
	GameState.pending_story_queue = [event_id]
	var story_scene := load("res://scenes/StoryMode.tscn") as PackedScene
	var story: Node = story_scene.instantiate()
	add_child(story)
	await get_tree().process_frame
	await get_tree().process_frame

	var bg_img := story.get("_bg_img") as TextureRect
	for index in range(expected_ids.size()):
		if index > 0:
			if bool(story.get("_typing")):
				story.call("_on_advance")
			story.call("_on_advance")
			await get_tree().process_frame
			await get_tree().process_frame
		var background_id := str(expected_ids[index])
		var expected_path := ImageRegistry.get_background(background_id)
		if bg_img == null or bg_img.texture == null:
			_failures.append("StoryMode did not render paragraph background %s[%d]" % [event_id, index])
		elif bg_img.texture.resource_path != expected_path:
			_failures.append("StoryMode %s paragraph %d background mismatch: expected %s, got %s" % [
				event_id,
				index,
				expected_path,
				bg_img.texture.resource_path,
			])

	remove_child(story)
	story.queue_free()

func _check_story_event_portrait_reveal(event_id: String, portrait_id: String, reveal_paragraph: int) -> void:
	var expected_path := ImageRegistry.get_portrait(portrait_id)
	if expected_path.is_empty():
		_failures.append("missing %s" % portrait_id)
		return

	GameState.pending_story_queue = [event_id]
	var story_scene := load("res://scenes/StoryMode.tscn") as PackedScene
	var story: Node = story_scene.instantiate()
	add_child(story)
	await get_tree().process_frame
	await get_tree().process_frame

	var portrait_frame := story.get("_portrait_frame") as Control
	var name_panel := story.get("_name_panel") as Control
	if portrait_frame != null and portrait_frame.visible:
		_failures.append("StoryMode revealed %s portrait before paragraph %d" % [event_id, reveal_paragraph])
	if name_panel != null and name_panel.visible:
		_failures.append("StoryMode revealed %s name before paragraph %d" % [event_id, reveal_paragraph])

	for _paragraph in range(reveal_paragraph):
		if bool(story.get("_typing")):
			story.call("_on_advance")
		story.call("_on_advance")
		await get_tree().process_frame
		await get_tree().process_frame

	var portrait := story.get("_portrait") as TextureRect
	if portrait_frame == null or not portrait_frame.visible:
		_failures.append("StoryMode did not reveal %s portrait at paragraph %d" % [event_id, reveal_paragraph])
	elif portrait == null or portrait.texture == null or portrait.texture.resource_path != expected_path:
		_failures.append("StoryMode %s portrait mismatch after reveal" % event_id)
	if name_panel == null or not name_panel.visible:
		_failures.append("StoryMode did not reveal %s name with its portrait" % event_id)

	remove_child(story)
	story.queue_free()

func _check_story_event_prelude_visual(
		event_id: String, background_id: String, portrait_id: String) -> void:
	GameState.pending_story_queue = [event_id]
	var story_scene := load("res://scenes/StoryMode.tscn") as PackedScene
	var story: Node = story_scene.instantiate()
	add_child(story)
	await get_tree().process_frame
	await get_tree().process_frame

	var expected_background := ImageRegistry.get_background(background_id)
	var bg_img := story.get("_bg_img") as TextureRect
	if bg_img == null or bg_img.texture == null or bg_img.texture.resource_path != expected_background:
		_failures.append("StoryMode %s prelude background mismatch" % event_id)
	var expected_portrait := ImageRegistry.get_portrait(portrait_id)
	var portrait_frame := story.get("_portrait_frame") as Control
	var portrait := story.get("_portrait") as TextureRect
	if portrait_frame == null or not portrait_frame.visible:
		_failures.append("StoryMode %s prelude should show its winter portrait" % event_id)
	elif portrait == null or portrait.texture == null or portrait.texture.resource_path != expected_portrait:
		_failures.append("StoryMode %s prelude portrait mismatch" % event_id)

	remove_child(story)
	story.queue_free()

func _check_story_choice_result_visual(
		event_id: String, choice_index: int, expected_id: String, expect_cg: bool) -> void:
	GameState.pending_story_queue = [event_id]
	var story_scene := load("res://scenes/StoryMode.tscn") as PackedScene
	var story: Node = story_scene.instantiate()
	add_child(story)
	await get_tree().process_frame
	await get_tree().process_frame

	for _step in range(12):
		if bool(story.get("_showing_choices")):
			break
		if bool(story.get("_typing")):
			story.call("_complete_typing")
		story.call("_on_advance")
		await get_tree().process_frame
		await get_tree().process_frame
	if not bool(story.get("_showing_choices")):
		_failures.append("StoryMode did not reach choices for %s" % event_id)
		remove_child(story)
		story.queue_free()
		return

	story.call("_on_choice", choice_index)
	await get_tree().process_frame
	await get_tree().process_frame
	var expected_path := ImageRegistry.get_cg(expected_id) if expect_cg \
		else ImageRegistry.get_background(expected_id)
	var bg_img := story.get("_bg_img") as TextureRect
	if bg_img == null or bg_img.texture == null or bg_img.texture.resource_path != expected_path:
		_failures.append("StoryMode %s choice %d result visual mismatch" % [event_id, choice_index])
	var portrait_frame := story.get("_portrait_frame") as Control
	if expect_cg and portrait_frame != null and portrait_frame.visible:
		_failures.append("StoryMode %s choice %d CG should hide portrait" % [event_id, choice_index])
	if not expect_cg and (portrait_frame == null or not portrait_frame.visible):
		_failures.append("StoryMode %s choice %d background should restore portrait" % [event_id, choice_index])

	remove_child(story)
	story.queue_free()

func _check_story_shared_result_cg(
		event_id: String, choice_index: int, initial_background_id: String,
		cg_id: String, reveal_paragraph: int) -> void:
	GameState.pending_story_queue = [event_id]
	var story_scene := load("res://scenes/StoryMode.tscn") as PackedScene
	var story: Node = story_scene.instantiate()
	add_child(story)
	await get_tree().process_frame
	await get_tree().process_frame

	for _step in range(30):
		if bool(story.get("_showing_choices")):
			break
		if bool(story.get("_typing")):
			story.call("_complete_typing")
		story.call("_on_advance")
		await get_tree().process_frame
		await get_tree().process_frame
	if not bool(story.get("_showing_choices")):
		_failures.append("StoryMode did not reach shared-result choices for %s" % event_id)
		remove_child(story)
		story.queue_free()
		return

	GameState.flags["tut_stat_shown"] = true
	GameState.flags["tut_cast_shown"] = true
	story.call("_on_choice", choice_index)
	await get_tree().process_frame
	await get_tree().process_frame
	var bg_img := story.get("_bg_img") as TextureRect
	var initial_path := ImageRegistry.get_background(initial_background_id)
	if bg_img == null or bg_img.texture == null or bg_img.texture.resource_path != initial_path:
		_failures.append("StoryMode %s replaced its dinner scene before result paragraph %d" % [
			event_id, reveal_paragraph,
		])
	var portrait_frame := story.get("_portrait_frame") as Control
	if portrait_frame == null or not portrait_frame.visible:
		_failures.append("StoryMode %s should retain its portrait before delayed result CG" % event_id)

	for _paragraph in range(reveal_paragraph):
		if bool(story.get("_typing")):
			story.call("_complete_typing")
		story.call("_on_advance")
		await get_tree().process_frame
		await get_tree().process_frame
	var expected_path := ImageRegistry.get_cg(cg_id)
	if bg_img == null or bg_img.texture == null or bg_img.texture.resource_path != expected_path:
		_failures.append("StoryMode %s did not reveal shared result CG at paragraph %d" % [
			event_id, reveal_paragraph,
		])
	if portrait_frame != null and portrait_frame.visible:
		_failures.append("StoryMode %s delayed result CG should hide portrait" % event_id)
	var hud_panel := story.get("_hud_panel") as Control
	if hud_panel != null and hud_panel.visible:
		_failures.append("StoryMode %s delayed result CG should hide HUD" % event_id)

	remove_child(story)
	story.queue_free()

func _check_date_milestone_season_contract() -> void:
	var saved_month: int = int(GameState.month)
	var saved_flags: Dictionary = GameState.flags.duplicate(true)
	var main_script := load("res://scenes/MainGame.gd") as GDScript
	var main: Node = main_script.new()
	GameState.flags = {}
	GameState.month = 1
	if str(main.call("_date_milestone_id", "daeun", 6)) != "":
		_failures.append("date milestone outerwear must not fire in January")
	GameState.month = 4
	if str(main.call("_date_milestone_id", "daeun", 6)) != "arc_date_namsan_daeun":
		_failures.append("deferred Namsan milestone did not resume in mild weather")
	GameState.flags["arc_date_namsan_daeun_seen"] = true
	if str(main.call("_date_milestone_id", "daeun", 6)) != "arc_date_park_daeun":
		_failures.append("amusement milestone did not follow Namsan in mild weather")
	GameState.month = 7
	if str(main.call("_date_milestone_id", "daeun", 8)) != "":
		_failures.append("date milestone outerwear must not fire in July")
	GameState.month = 10
	if str(main.call("_date_milestone_id", "daeun", 8)) != "arc_date_park_daeun":
		_failures.append("deferred amusement milestone did not resume in mild weather")
	main.free()
	GameState.month = saved_month
	GameState.flags = saved_flags

func _check_first_snow_season_contract() -> void:
	var saved_month: int = int(GameState.month)
	var saved_year: int = int(GameState.year)
	var saved_flags: Dictionary = GameState.flags.duplicate(true)
	var main_script := load("res://scenes/MainGame.gd") as GDScript
	var main: Node = main_script.new()
	GameState.year = 2028
	GameState.flags = {}
	GameState.month = 11
	if str(main.call("_season_date_id", "daeun")) != "":
		_failures.append("first-snow date must not fire before December")
	GameState.month = 12
	if str(main.call("_season_date_id", "daeun")) != "arc_season_snow_daeun":
		_failures.append("Daeun first-snow date did not fire in December")
	GameState.flags = {}
	if str(main.call("_season_date_id", "jiyeon")) != "arc_season_snow_jiyeon":
		_failures.append("Jiyeon first-snow date did not fire in December")
	main.free()
	GameState.month = saved_month
	GameState.year = saved_year
	GameState.flags = saved_flags

func _check_special_story_season_contract() -> void:
	var saved_month: int = int(GameState.month)
	var saved_flags: Dictionary = GameState.flags.duplicate(true)
	var main_script := load("res://scenes/MainGame.gd") as GDScript
	var main: Node = main_script.new()

	var hometown_flags := {"daeun_romance_started": true}
	GameState.month = 7
	if str(main.call("_hometown_special_arc_id", 99, hometown_flags)) != "":
		_failures.append("Daeun hometown story must not fire before Year 3")
	GameState.month = 5
	if str(main.call("_hometown_special_arc_id", 100, hometown_flags)) != "":
		_failures.append("Daeun summer hometown outfit must not fire in May")
	GameState.month = 7
	if str(main.call("_hometown_special_arc_id", 180, hometown_flags)) != "arc_daeun_hometown_1":
		_failures.append("Daeun hometown story did not defer to a later summer")
	hometown_flags["arc_daeun_hometown_1_seen"] = true
	GameState.month = 9
	if str(main.call("_hometown_special_arc_id", 181, hometown_flags)) != "arc_daeun_hometown_2":
		_failures.append("Daeun hometown continuation must finish after its summer start")

	var narrow_flags := {
		"jiyeon_romance_started": true,
		"arc_jiyeon_father_records_seen": true,
	}
	GameState.month = 7
	if str(main.call("_jiyeon_narrow_room_arc_id", 150, narrow_flags)) != "":
		_failures.append("Jiyeon long-coat prelude must not fire in July")
	GameState.month = 10
	if str(main.call("_jiyeon_narrow_room_arc_id", 180, narrow_flags)) != "arc_jiyeon_narrow_room_1":
		_failures.append("Jiyeon narrow-room story did not defer to cool weather")
	narrow_flags["arc_jiyeon_narrow_room_1_seen"] = true
	GameState.month = 7
	if str(main.call("_jiyeon_narrow_room_arc_id", 181, narrow_flags)) != "arc_jiyeon_narrow_room_2":
		_failures.append("Jiyeon narrow-room continuation must finish after its cool-weather start")

	main.free()
	GameState.month = saved_month
	GameState.flags = saved_flags

func _check_wedding_night_reachability_contract() -> void:
	var main_script := load("res://scenes/MainGame.gd") as GDScript
	var main: Node = main_script.new()
	if str(main.call("_wedding_night_arc_id", "daeun", {})) != "":
		_failures.append("Daeun wedding night must wait for the wedding day")
	var daeun_flags := {"arc_daeun_wedding_day_seen": true}
	if str(main.call("_wedding_night_arc_id", "daeun", daeun_flags)) != "arc_daeun_wedding_night":
		_failures.append("Daeun wedding night is unreachable after the wedding day")
	daeun_flags["arc_daeun_wedding_night_seen"] = true
	if str(main.call("_wedding_night_arc_id", "daeun", daeun_flags)) != "":
		_failures.append("Daeun wedding night repeats after completion")

	if str(main.call("_wedding_night_arc_id", "jiyeon", {})) != "":
		_failures.append("Jiyeon wedding night must wait for the wedding gap scene")
	var jiyeon_flags := {"arc_jiyeon_wedding_gap_seen": true}
	if str(main.call("_wedding_night_arc_id", "jiyeon", jiyeon_flags)) != "arc_jiyeon_wedding_night":
		_failures.append("Jiyeon wedding night is unreachable after the wedding gap scene")
	jiyeon_flags["arc_jiyeon_wedding_night_seen"] = true
	if str(main.call("_wedding_night_arc_id", "jiyeon", jiyeon_flags)) != "":
		_failures.append("Jiyeon wedding night repeats after completion")
	main.free()

func _check_transport_background_contract() -> void:
	var ktx_path := ImageRegistry.get_background("ktx_window")
	if ktx_path != "res://assets/backgrounds/regional_train_window_summer.png":
		_failures.append("ktx_window must resolve to the train interior, got %s" % ktx_path)
	var station_path := ImageRegistry.get_background("hometown_train_station")
	if station_path != "res://assets/backgrounds/hometown_train_station.png":
		_failures.append("hometown_train_station must keep the provincial platform, got %s" % station_path)

func _check_divorce_ending_route_contract() -> void:
	var shortfall_id := str(GameState.call("_divorce_ending_for_assets", 2_999_999_999.0))
	if shortfall_id != "ordinary_life":
		_failures.append("Daeun divorce below Gangnam target must resolve to ordinary_life, got %s" % shortfall_id)
	var gangnam_id := str(GameState.call("_divorce_ending_for_assets", 3_000_000_000.0))
	if gangnam_id != "lonely_rich":
		_failures.append("Daeun divorce at Gangnam target must resolve to lonely_rich, got %s" % gangnam_id)

func _check_gambling_recovery_chain_contract() -> void:
	_check_deferred_choice("gambling_rock_bottom", "sought_help", "recovery_first_week", 1)
	_check_deferred_choice("gambling_rock_bottom", "told_family_addiction", "recovery_first_week", 1)
	var first_week: Dictionary = DataRegistry.find_event("recovery_first_week")
	var first_week_choices: Array = first_week.get("choices", [])
	if first_week_choices.size() != 2:
		_failures.append("recovery_first_week must keep exactly two coping choices")
	for raw_choice in first_week_choices:
		var choice: Dictionary = raw_choice
		if str(choice.get("deferred_follow_up", "")) != "recovery_relapse_test" \
				or int(choice.get("deferred_delay", -1)) != 3:
			_failures.append("every recovery_first_week choice must defer the temptation test by three weeks")
	_check_deferred_choice("recovery_relapse_test", "recovery_proven", "recovery_one_month_clean", 1)
	var relapse_event: Dictionary = DataRegistry.find_event("recovery_relapse_test")
	for raw_choice in relapse_event.get("choices", []):
		var choice: Dictionary = raw_choice
		if (choice.get("flags", []) as Array).has("relapsed") and choice.has("deferred_follow_up"):
			_failures.append("the relapse choice must not schedule the clean-month payoff")
	for event_id in ["recovery_first_week", "recovery_relapse_test", "recovery_one_month_clean"]:
		var event: Dictionary = DataRegistry.find_event(event_id)
		if float(event.get("weight", -1.0)) != 0.0 or not bool(event.get("hidden", false)):
			_failures.append("%s must be deferred-only (weight 0, hidden)" % event_id)

func _check_deferred_choice(event_id: String, flag_id: String, target_id: String, delay: int) -> void:
	var event: Dictionary = DataRegistry.find_event(event_id)
	for raw_choice in event.get("choices", []):
		var choice: Dictionary = raw_choice
		if not (choice.get("flags", []) as Array).has(flag_id):
			continue
		if str(choice.get("deferred_follow_up", "")) != target_id \
				or int(choice.get("deferred_delay", -1)) != delay:
			_failures.append("%s choice %s must defer %s by %d weeks" % [event_id, flag_id, target_id, delay])
		return
	_failures.append("%s is missing choice flag %s" % [event_id, flag_id])

func _check_all_story_cg_contracts() -> void:
	var owners: Dictionary = {}
	for raw_event in DataRegistry.events:
		var event: Dictionary = raw_event
		var event_id: String = str(event.get("id", ""))
		var refs: Array[Dictionary] = []
		var event_cg_id := str(event.get("cg", ""))
		if not event_cg_id.is_empty():
			refs.append({"owner": event_id, "cg": event_cg_id})
		var event_result_cg_id := str(event.get("result_cg", ""))
		if not event_result_cg_id.is_empty():
			refs.append({"owner": "%s#result" % event_id, "cg": event_result_cg_id})
		var choices: Array = event.get("choices", [])
		for choice_index in range(choices.size()):
			var choice: Dictionary = choices[choice_index]
			var result_cg_id := str(choice.get("result_cg", ""))
			if not result_cg_id.is_empty():
				refs.append({"owner": "%s#choice%d" % [event_id, choice_index], "cg": result_cg_id})
		for ref in refs:
			var owner := str(ref["owner"])
			var cg_id := str(ref["cg"])
			if owners.has(cg_id):
				_failures.append("story cg %s is shared by %s and %s" % [cg_id, str(owners[cg_id]), owner])
			else:
				owners[cg_id] = owner
			var path := ImageRegistry.get_cg(cg_id)
			if path.is_empty() or not ResourceLoader.exists(path):
				_failures.append("%s references missing story cg %s" % [owner, cg_id])
				continue
			var texture := load(path) as Texture2D
			if texture == null or texture.get_width() < 1280 or texture.get_height() < 720:
				_failures.append("%s story cg must be at least 1280x720: %s" % [owner, path])
			elif cg_id.begins_with("cg_romance_") and (texture.get_width() != 1280 or texture.get_height() != 800):
				_failures.append("%s romance cg must be exactly 1280x800: %s" % [owner, path])

func _check_romance_visual_manifest() -> void:
	const MANIFEST_PATH := "res://assets/romance_visual_manifest.json"
	if not FileAccess.file_exists(MANIFEST_PATH):
		_failures.append("missing romance visual manifest")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
	if not parsed is Dictionary:
		_failures.append("romance visual manifest root must be a dictionary")
		return
	var root: Dictionary = parsed
	var rows_value: Variant = root.get("t0", [])
	if not rows_value is Array:
		_failures.append("romance visual manifest t0 must be an array")
		return
	var rows: Array = rows_value
	if rows.size() != 10:
		_failures.append("romance visual manifest must own exactly 10 T0 events")
	var t1_value: Variant = root.get("t1", [])
	if not t1_value is Array:
		_failures.append("romance visual manifest t1 must be an array")
		return
	rows = rows.duplicate()
	rows.append_array(t1_value as Array)
	var t2_value: Variant = root.get("t2", [])
	if not t2_value is Array:
		_failures.append("romance visual manifest t2 must be an array")
		return
	if (t2_value as Array).size() != 2:
		_failures.append("romance visual manifest must own exactly 2 T2 breakup events")
	rows.append_array(t2_value as Array)

	var player_value: Variant = root.get("player_outfit", {})
	if not player_value is Dictionary:
		_failures.append("romance visual manifest player_outfit must be a dictionary")
		return
	var player_spec: Dictionary = player_value
	var player_portrait_id: String = str(player_spec.get("portrait", ""))
	_check_romance_portrait(player_portrait_id, "T0 Minjun")

	var owners: Dictionary = {}
	for raw_row in rows:
		if not raw_row is Dictionary:
			_failures.append("romance visual manifest row must be a dictionary")
			continue
		var row: Dictionary = raw_row
		var event_id: String = str(row.get("event_id", ""))
		var cg_id: String = str(row.get("cg", ""))
		var portrait_id: String = str(row.get("heroine_portrait", ""))
		if event_id.is_empty() or owners.has(event_id):
			_failures.append("romance visual manifest has empty or duplicate event: %s" % event_id)
			continue
		owners[event_id] = true
		var event: Dictionary = DataRegistry.find_event(event_id)
		if event.is_empty():
			_failures.append("romance visual manifest event is missing: %s" % event_id)
			continue
		var placement := str(row.get("cg_placement", "choice_result" if row.has("choice_index") else "event"))
		var actual_cg_id := str(event.get("cg", ""))
		if placement == "event_result":
			actual_cg_id = str(event.get("result_cg", ""))
		elif placement == "choice_result":
			var choice_index := int(row.get("choice_index", -1))
			var choices: Array = event.get("choices", [])
			if choice_index < 0 or choice_index >= choices.size():
				_failures.append("%s has invalid romance result choice index" % event_id)
				actual_cg_id = ""
			else:
				var result_choice: Dictionary = choices[choice_index]
				actual_cg_id = str(result_choice.get("result_cg", ""))
		elif placement != "event":
			_failures.append("%s has invalid romance CG placement" % event_id)
			actual_cg_id = ""
		if actual_cg_id != cg_id:
			_failures.append("%s cg drifted from romance visual manifest" % event_id)
		if str(event.get("portrait", "")) != portrait_id:
			_failures.append("%s portrait outfit drifted from romance visual manifest" % event_id)
		if str(row.get("heroine_outfit", "")).is_empty():
			_failures.append("%s has no heroine outfit contract" % event_id)
		if str(row.get("eye_line", "")).is_empty():
			_failures.append("%s has no gaze target contract" % event_id)
		if str(row.get("player_visibility", "")) not in ["pov", "cropped_left", "visible_left", "visible_right"]:
			_failures.append("%s has invalid player visibility" % event_id)
		if row.has("season_months"):
			var season_months: Array = row.get("season_months", [])
			if season_months.is_empty():
				_failures.append("%s has an empty season month contract" % event_id)
			for raw_month in season_months:
				var month := int(raw_month)
				if month < 1 or month > 12:
					_failures.append("%s has an invalid season month" % event_id)
		var portrait_visibility := str(row.get("portrait_visibility", "visible"))
		if portrait_id.is_empty():
			if portrait_visibility != "hidden_before_reveal":
				_failures.append("%s empty romance portrait must be hidden before reveal" % event_id)
		else:
			_check_romance_portrait(portrait_id, event_id)
		var prelude_event_id: String = str(row.get("prelude_event_id", ""))
		if not prelude_event_id.is_empty():
			var prelude_event: Dictionary = DataRegistry.find_event(prelude_event_id)
			var prelude_portrait: String = str(row.get("prelude_portrait", ""))
			if prelude_event.is_empty():
				_failures.append("romance visual manifest prelude is missing: %s" % prelude_event_id)
			elif str(prelude_event.get("portrait", "")) != prelude_portrait:
				_failures.append("%s portrait drifted from romance visual manifest" % prelude_event_id)
			if str(row.get("prelude_outfit", "")).is_empty():
				_failures.append("%s has no prelude outfit contract" % prelude_event_id)
			_check_romance_portrait(prelude_portrait, prelude_event_id)

func _check_romance_portrait(portrait_id: String, owner: String) -> void:
	var path: String = ImageRegistry.get_portrait(portrait_id)
	if path.is_empty() or not ResourceLoader.exists(path):
		_failures.append("%s references missing romance portrait %s" % [owner, portrait_id])
		return
	var texture := load(path) as Texture2D
	if texture == null or texture.get_width() != 512 or texture.get_height() != 768:
		_failures.append("%s romance portrait must be exactly 512x768: %s" % [owner, path])
		return
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null or image.is_empty():
		_failures.append("%s romance portrait source could not be read: %s" % [owner, path])
		return
	for corner in [Vector2i(0, 0), Vector2i(image.get_width() - 1, 0), Vector2i(0, image.get_height() - 1), Vector2i(image.get_width() - 1, image.get_height() - 1)]:
		if image.get_pixelv(corner).a > 0.05:
			_failures.append("%s romance portrait must have transparent corners: %s" % [owner, path])
			break

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
	_check_ending_cg_path(main, "full_circle", "cg_ending_full_circle")
	_check_ending_cg_path(main, "gangnam_dream_white", "cg_ending_gangnam_dream_white")
	_check_ending_cg_path(main, "with_daeun", "cg_ending_with_daeun")
	_check_ending_cg_path(main, "second_love", "cg_ending_second_love")
	_check_ending_cg_path(main, "jiyeon_man", "cg_ending_jiyeon_man")
	if ImageRegistry.get_cg("cg_ending_jiyeon_man") != "res://assets/cg/ending_jiyeon_man_v2.png":
		_failures.append("jiyeon_man must use the reflection-only v2 CG")
	_check_ending_cg_path(main, "guardian", "cg_ending_guardian")
	_check_ending_cg_path(main, "jaehyuk_way", "cg_ending_jaehyuk_way")
	_check_ending_cg_path(main, "sangchul_reckoning", "cg_ending_sangchul_reckoning")
	_check_ending_cg_path(main, "late_call", "cg_ending_late_call")
	_check_ending_cg_path(main, "lonely_rich", "cg_ending_lonely_rich")
	_check_ending_cg_path(main, "gambling_recovery", "cg_ending_gambling_recovery")
	if ImageRegistry.get_cg("cg_ending_gambling_recovery") != "res://assets/cg/ending_gambling_recovery_v1.png":
		_failures.append("gambling_recovery must use its dedicated calendar CG")
	_check_ending_cg_path(main, "bankruptcy", "cg_ending_bankruptcy")
	if ImageRegistry.get_cg("cg_ending_bankruptcy") != "res://assets/cg/ending_bankruptcy_v1.png":
		_failures.append("bankruptcy must use its dedicated stopped-calculation CG")
	_check_ending_cg_path(main, "debt_spiral", "cg_ending_debt_spiral")
	if ImageRegistry.get_cg("cg_ending_debt_spiral") != "res://assets/cg/ending_debt_spiral_v1.png":
		_failures.append("debt_spiral must use its dedicated released-calculator CG")
	var debt_spiral: Dictionary = EndingSystem.get_ending("debt_spiral")
	if not is_equal_approx(float(debt_spiral.get("cg_preview_focus_y", 0.5)), 0.9):
		_failures.append("debt_spiral must keep its lower-table ending preview focus")
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
		elif preview_material.get_shader_parameter("mid_gamma") > 0.90:
			_failures.append("MainGame ending CG preview lost its shadow-legibility grade")

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
	if str(white_ending.get("cg", "")) != "cg_ending_gangnam_dream_white":
		_failures.append("gangnam_dream_white must own cg_ending_gangnam_dream_white")

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
