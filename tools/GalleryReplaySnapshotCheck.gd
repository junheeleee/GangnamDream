extends Node
## ORDER-132: gallery replay must be a frozen record, never a reconstruction
## from whichever live run happens to be loaded later.

const CORE_LOOP := preload("res://systems/DemoCoreLoopV2.gd")
const START_MENU_SCRIPT := preload("res://scenes/StartMenu.gd")
const STORY_MODE_SCRIPT := preload("res://scenes/StoryMode.gd")
const STORY_MODE_SCENE := preload("res://scenes/StoryMode.tscn")

const FIRST_BILL_ROOT := "v2_demo_first_bill_opening"
const FROZEN_SURFACE_ROOT := "arc_daeun_first_night"
const FROZEN_SELECTOR_ROOT := "arc_jiyeon_narrow_room_1"
const FROZEN_SELECTOR_ID := "arc_y3_jiyeon_departure_seen"
const HYUNSU_ECHO_ID := "v2_hyunsu_exam_morning_echo"
const EXPECTED_GENERIC_EVENTS := 48

var _failures: Array[String] = []
var _meta_backup: Dictionary = {}
var _meta_new_backup: Dictionary = {}
var _game_backup: Dictionary = {}
var _language_backup := "ko"
var _meta_file_existed := false
var _meta_file_copy := ""
var _first_bill_fixture: Dictionary = {}


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	_backup_state()
	LocaleManager.set_language("ko")
	_check_catalog_and_authored_closure()
	_check_first_bill_m3_and_runtime_max()
	_check_pair_persistence_and_fail_closed()
	await _check_frozen_runtime_surfaces()
	await _finish()


func _check_catalog_and_authored_closure() -> void:
	var roots: Array[String] = MetaProgression.GALLERY_REPLAY_ROOT_IDS.duplicate()
	var menu_roots: Array[String] = START_MENU_SCRIPT.ARCHIVE_SCENE_IDS.duplicate()
	_expect(roots == menu_roots, "Meta and StartMenu gallery catalogs diverged")
	_expect(roots.size() == 20 and roots.count(FIRST_BILL_ROOT) == 1,
		"gallery root inventory is not exact 20 with one First Bill root")

	var authored_closure := 0
	var generic_events := 0
	var name_events := 0
	var portrait_events := 0
	var housing_events := 0
	var selector_events := 0
	var choice_count := 0
	for root_id in roots:
		var closure: Array[String] = MetaProgression.gallery_replay_closure_ids(
			root_id)
		_expect(not closure.is_empty() and closure.front() == root_id,
			"gallery closure is empty or lost its root: %s" % root_id)
		authored_closure += closure.size()
		if root_id == FIRST_BILL_ROOT:
			_expect(closure == [
				FIRST_BILL_ROOT, CORE_LOOP.FIRST_BILL_DECISION_ID,
				CORE_LOOP.FIRST_BILL_LEDGER_ID,
			], "First Bill authored closure drifted: %s" % str(closure))
			continue
		for event_id in closure:
			var event: Dictionary = DataRegistry.find_event(event_id)
			var choices: Variant = event.get("choices", null)
			_expect(not event.is_empty() and choices is Array,
				"gallery closure has a malformed event: %s" % event_id)
			if event.is_empty() or not choices is Array:
				continue
			generic_events += 1
			choice_count += (choices as Array).size()
			if _variant_contains_string(event, "{name}"):
				name_events += 1
			if _event_has_temporal_portrait(event):
				portrait_events += 1
			if str(event.get("background", "")) == "current_housing" \
					or _variant_contains_exact_string(
						event.get("paragraph_backgrounds", []), "current_housing"):
				housing_events += 1
			if _event_has_gallery_selector(event):
				selector_events += 1

	_expect(authored_closure == 51,
		"gallery authored closure is not exact 51: %d" % authored_closure)
	_expect(generic_events == EXPECTED_GENERIC_EVENTS,
		"ordinary gallery closure is not exact 48: %d" % generic_events)
	_expect(name_events == 44, "frozen-name event count drifted: %d" % name_events)
	_expect(portrait_events == 12,
		"turn-dependent portrait event count drifted: %d" % portrait_events)
	_expect(housing_events == 4,
		"current-housing event count drifted: %d" % housing_events)
	_expect(selector_events == 6,
		"selector-bearing event count drifted: %d" % selector_events)
	_expect(choice_count == 86,
		"ordinary gallery authored choice count drifted: %d" % choice_count)


func _check_first_bill_m3_and_runtime_max() -> void:
	for memory_id in [
		"m3_ledger_reasons_named", "m3_ledger_totals_only", "",
	]:
		var snapshot := _build_complete_first_bill_snapshot(memory_id, false)
		_expect(not snapshot.is_empty() \
				and str(snapshot.get("m3_ledger_memory", "missing")) == memory_id,
			"First Bill did not freeze M3 memory '%s'" % memory_id)
		if memory_id == "m3_ledger_reasons_named":
			_first_bill_fixture = snapshot.duplicate(true)

	_expect(not _first_bill_fixture.is_empty(),
		"First Bill complete snapshot fixture was not produced")
	if not _first_bill_fixture.is_empty():
		var legacy := _first_bill_fixture.duplicate(true)
		legacy.erase("m3_ledger_memory")
		var normalized := MetaProgression.validate_scene_replay_snapshot(
			FIRST_BILL_ROOT, legacy)
		_expect(not normalized.is_empty() \
				and str(normalized.get("m3_ledger_memory", "missing")) == "",
			"legacy First Bill snapshot did not normalize missing M3 memory")
		for bad_value in [true, 3, "m3_ledger_both"]:
			var corrupt := _first_bill_fixture.duplicate(true)
			corrupt["m3_ledger_memory"] = bad_value
			_expect(MetaProgression.validate_scene_replay_snapshot(
				FIRST_BILL_ROOT, corrupt).is_empty(),
				"First Bill accepted corrupt M3 memory: %s" % str(bad_value))

	var contradictory := _build_complete_first_bill_snapshot(
		"m3_ledger_both", false)
	_expect(contradictory.is_empty(),
		"First Bill captured mutually exclusive M3 memories")
	var runtime_snapshot := _build_complete_first_bill_snapshot("", true)
	var follow_up_roots := CORE_LOOP.first_bill_replay_follow_up_roots(
		runtime_snapshot)
	_expect(not runtime_snapshot.is_empty() and follow_up_roots == [HYUNSU_ECHO_ID],
		"First Bill conditional Hyunsu replay root drifted: %s" \
			% str(follow_up_roots))
	_expect(DataRegistry.find_event(HYUNSU_ECHO_ID).size() > 0 \
			and 51 + follow_up_roots.size() == 52,
		"gallery runtime maximum is not exact 52")


func _check_pair_persistence_and_fail_closed() -> void:
	_reset_meta_fixture()
	_prepare_generic_frozen_state()
	var roots: Array[String] = MetaProgression.GALLERY_REPLAY_ROOT_IDS.duplicate()
	var first_snapshots: Dictionary = {}
	var producer := STORY_MODE_SCRIPT.new()
	for root_id in roots:
		var snapshot: Dictionary = _first_bill_fixture.duplicate(true) \
			if root_id == FIRST_BILL_ROOT \
			else _build_generic_snapshot(producer, root_id)
		first_snapshots[root_id] = snapshot.duplicate(true)
		_expect(not snapshot.is_empty() \
				and MetaProgression.record_scene_replay_pair(root_id, snapshot) \
				and MetaProgression.has_valid_scene_replay_pair(root_id),
			"gallery pair did not persist atomically: %s" % root_id)
	producer.free()

	var pair_count := 0
	for root_id in roots:
		if MetaProgression.has_valid_scene_replay_pair(root_id):
			pair_count += 1
	_expect(pair_count == 20, "valid gallery pair count is not 20: %d" % pair_count)
	_expect(_disk_contains_all_pairs(roots),
		"persisted meta file exposed a partial seen/snapshot pair")

	# Every valid pair is permanently write-once, even after the live run changes.
	GameState.player_name = "뒤의런이름"
	GameState.turn = 3
	GameState.moral_tint = 91.0
	GameState.housing = "gosiwon"
	producer = STORY_MODE_SCRIPT.new()
	for root_id in roots:
		var replacement: Dictionary = _first_bill_fixture.duplicate(true) \
			if root_id == FIRST_BILL_ROOT \
			else _build_generic_snapshot(producer, root_id)
		_expect(MetaProgression.record_scene_replay_pair(root_id, replacement) \
				and MetaProgression.get_scene_replay_snapshot(root_id) \
					== first_snapshots[root_id],
			"valid gallery pair was overwritten: %s" % root_id)
	producer.free()

	var menu := START_MENU_SCRIPT.new()
	var guard := STORY_MODE_SCRIPT.new()
	var repair_roots := roots.slice(0, 3)
	for case_index in range(repair_roots.size()):
		var root_id: String = repair_roots[case_index]
		var original: Dictionary = first_snapshots[root_id]
		var seen: Array = MetaProgression.data.get("seen_scenes", []).duplicate()
		var snapshots: Dictionary = MetaProgression.data.get(
			"scene_replay_snapshots", {}).duplicate(true)
		match case_index:
			0: # legacy seen-only
				snapshots.erase(root_id)
			1: # orphan snapshot
				seen.erase(root_id)
			2: # corrupt snapshot
				var corrupt := original.duplicate(true)
				corrupt["schema"] = 999
				snapshots[root_id] = corrupt
		MetaProgression.data["seen_scenes"] = seen
		MetaProgression.data["scene_replay_snapshots"] = snapshots
		guard.set("_queue", [root_id])
		_expect(not MetaProgression.has_valid_scene_replay_pair(root_id) \
				and not bool(menu.call("_archive_scene_has_valid_replay", root_id)) \
				and not bool(guard.call("_prepare_gallery_replay")),
			"damaged gallery record did not fail closed: case=%d root=%s" % [
				case_index, root_id])
		_expect(MetaProgression.record_scene_replay_pair(root_id, original) \
				and MetaProgression.has_valid_scene_replay_pair(root_id),
			"next trusted live encounter did not repair case=%d root=%s" % [
				case_index, root_id])

	var invalid_root: String = repair_roots[0]
	var invalid_copy: Dictionary = first_snapshots[invalid_root].duplicate(true)
	var selector_maps: Dictionary = invalid_copy["selector_matches"].duplicate(true)
	selector_maps[invalid_root] = ["invented_selector"]
	invalid_copy["selector_matches"] = selector_maps
	_expect(MetaProgression.validate_scene_replay_snapshot(
		invalid_root, invalid_copy).is_empty(),
		"generic snapshot accepted an unauthored selector")
	invalid_copy = first_snapshots[invalid_root].duplicate(true)
	var choice_maps: Dictionary = invalid_copy[
		"visible_choice_indices"].duplicate(true)
	choice_maps[invalid_root] = [
		(DataRegistry.find_event(invalid_root).get("choices", []) as Array).size(),
	]
	invalid_copy["visible_choice_indices"] = choice_maps
	_expect(MetaProgression.validate_scene_replay_snapshot(
		invalid_root, invalid_copy).is_empty(),
		"generic snapshot accepted an out-of-range choice index")
	for corrupt_key in ["schema", "scene_id", "turn", "housing"]:
		invalid_copy = first_snapshots[invalid_root].duplicate(true)
		match corrupt_key:
			"schema": invalid_copy[corrupt_key] = 2
			"scene_id": invalid_copy[corrupt_key] = FROZEN_SELECTOR_ROOT
			"turn": invalid_copy[corrupt_key] = 241
			"housing": invalid_copy[corrupt_key] = "penthouse"
		_expect(MetaProgression.validate_scene_replay_snapshot(
			invalid_root, invalid_copy).is_empty(),
			"generic snapshot accepted corrupt %s" % corrupt_key)
	invalid_copy = first_snapshots[invalid_root].duplicate(true)
	invalid_copy["translated_prose"] = "현재 번역문을 저장하면 안 된다"
	_expect(MetaProgression.validate_scene_replay_snapshot(
		invalid_root, invalid_copy).is_empty(),
		"generic snapshot accepted an extra translated-prose field")
	invalid_copy = first_snapshots[invalid_root].duplicate(true)
	invalid_copy["player_name"] = "가".repeat(33_000)
	_expect(MetaProgression.validate_scene_replay_snapshot(
		invalid_root, invalid_copy).is_empty(),
		"generic snapshot accepted an oversized payload")

	var data_before_seen_call := MetaProgression.data.duplicate(true)
	_expect(not MetaProgression.record_scene_seen(FROZEN_SURFACE_ROOT) \
			and MetaProgression.data == data_before_seen_call,
		"gallery root accepted a non-atomic seen-only write")

	# A malformed top-level seen container is locked, normalized on load, and
	# repairable only by the next trusted live pair writer.
	var data_before_bad_seen := MetaProgression.data.duplicate(true)
	MetaProgression.data["seen_scenes"] = "damaged"
	MetaProgression.save_meta()
	MetaProgression.load_meta()
	var repaired_seen_type: Variant = MetaProgression.data.get(
		"seen_scenes", null)
	_expect(repaired_seen_type is Array \
			and not MetaProgression.has_valid_scene_replay_pair(invalid_root) \
			and MetaProgression.record_scene_replay_pair(
				invalid_root, first_snapshots[invalid_root]) \
			and MetaProgression.has_valid_scene_replay_pair(invalid_root),
		"malformed seen container could not recover at a trusted live encounter")
	MetaProgression.data = data_before_bad_seen
	MetaProgression.save_meta()

	# A stale direct request loses replay authority and remains on the menu.
	var snapshots: Dictionary = MetaProgression.data.get(
		"scene_replay_snapshots", {}).duplicate(true)
	var saved_surface_snapshot: Dictionary = snapshots[FROZEN_SURFACE_ROOT]
	snapshots.erase(FROZEN_SURFACE_ROOT)
	MetaProgression.data["scene_replay_snapshots"] = snapshots
	GameState.pending_story_queue = ["poison"]
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	GameState.story_replay_mode = true
	menu.call("_replay_archive_scene", FROZEN_SURFACE_ROOT)
	_expect(GameState.pending_story_queue.is_empty() \
			and GameState.story_return_scene == "res://scenes/StartMenu.tscn" \
			and not GameState.story_replay_mode,
		"invalid direct replay request retained launch authority")
	snapshots[FROZEN_SURFACE_ROOT] = saved_surface_snapshot
	MetaProgression.data["scene_replay_snapshots"] = snapshots
	guard.free()
	menu.free()


func _check_frozen_runtime_surfaces() -> void:
	var snapshot := MetaProgression.get_scene_replay_snapshot(
		FROZEN_SURFACE_ROOT)
	var selector_snapshot := MetaProgression.get_scene_replay_snapshot(
		FROZEN_SELECTOR_ROOT)
	_expect(not snapshot.is_empty() and not selector_snapshot.is_empty(),
		"frozen runtime fixtures are missing")
	if snapshot.is_empty() or selector_snapshot.is_empty():
		return

	# Invert every live value after the first pair was stored.
	GameState.player_name = "현재런이름"
	GameState.turn = 1
	GameState.year = 1
	GameState.month = 8
	GameState.week_of_month = 1
	GameState.moral_tint = 88.0
	GameState.housing = "gosiwon"
	GameState.flags.erase(FROZEN_SELECTOR_ID)
	var live_state_before: Dictionary = GameState.serialize().duplicate(true)
	var meta_before: Dictionary = MetaProgression.data.duplicate(true)
	var archive_menu := START_MENU_SCRIPT.new()
	var archive_preview_path := str(archive_menu.call(
		"_archive_event_visual_path",
		DataRegistry.find_event(FROZEN_SURFACE_ROOT), FROZEN_SURFACE_ROOT))
	_expect(archive_preview_path == ImageRegistry.get_background(
			"gangnam_apartment"),
		"archive card preview read the inverted live housing")
	archive_menu.free()

	GameState.pending_story_queue = [FROZEN_SURFACE_ROOT]
	GameState.story_return_scene = "res://scenes/StartMenu.tscn"
	GameState.story_replay_mode = true
	var story := STORY_MODE_SCENE.instantiate() as Control
	add_child(story)
	await get_tree().process_frame
	await get_tree().process_frame
	var current: Dictionary = story.get("_current")
	var frozen_turn := int(snapshot["turn"])
	var frozen_housing := str(snapshot["housing"])
	var expected_month := posmod(floori(float(frozen_turn - 1) / 4.0), 12) + 1
	var expected_portrait := ImageRegistry.get_portrait_for_turn(
		str(current.get("portrait", "")), frozen_turn)
	var portrait := story.get("_portrait") as TextureRect
	var actual_portrait := portrait.texture.resource_path \
		if is_instance_valid(portrait) and portrait.texture != null else ""
	var hud := story.get("_hud_panel") as Control
	_expect(bool(story.get("_read_only_replay")) \
			and str(current.get("id", "")) == FROZEN_SURFACE_ROOT,
		"valid gallery pair did not open in read-only StoryMode")
	_expect(str(story.call("_fmt", "{name}")) == str(snapshot["player_name"]),
		"gallery replay read the live player name")
	_expect(int(story.call("_story_visual_turn")) == frozen_turn \
			and actual_portrait == expected_portrait,
		"gallery replay portrait did not use the frozen turn")
	_expect(is_equal_approx(float(story.get("_story_moral_norm")),
		float(snapshot["moral_tint"]) / 100.0),
		"gallery replay moral palette read the live run")
	_expect(frozen_housing == "gangnam" \
			and str(story.get("_event_background_id")) == "gangnam_apartment" \
			and str(story.call(
				"_resolve_story_background_id", "current_housing")) \
				== "gangnam_apartment",
		"gallery replay background did not use frozen housing")
	_expect(str(BGMPlayer.call("_active_housing_id")) == frozen_housing \
			and int(BGMPlayer.call("_active_calendar_month")) == expected_month,
		"gallery replay ambience/season clock read the live run")
	_expect(is_instance_valid(hud) and not hud.visible,
		"gallery replay exposed the live HUD")

	# Selector and visible-choice readers are also snapshot-only. A deliberately
	# reduced, still-valid inventory proves the consumer cannot recompute it.
	var selector_story := STORY_MODE_SCRIPT.new()
	selector_story.set("_read_only_replay", true)
	selector_story.set("_gallery_replay_snapshot", selector_snapshot)
	var selector_event: Dictionary = DataRegistry.find_event(FROZEN_SELECTOR_ROOT)
	selector_story.set("_current", selector_event)
	var resolved := str(selector_story.call(
		"_resolved_story_description", selector_event))
	var frozen_variant := str((selector_event.get(
		"description_if_known", {}) as Dictionary).get(FROZEN_SELECTOR_ID, ""))
	_expect((selector_snapshot.get("selector_matches", {}) as Dictionary).get(
			FROZEN_SELECTOR_ROOT, []).has(FROZEN_SELECTOR_ID) \
			and resolved == str(selector_story.call("_fmt", frozen_variant)),
		"gallery replay selector fell back to the inverted live flag")
	selector_story.free()

	var choice_snapshot := snapshot.duplicate(true)
	var visible_maps: Dictionary = choice_snapshot[
		"visible_choice_indices"].duplicate(true)
	visible_maps[FROZEN_SURFACE_ROOT] = [1]
	choice_snapshot["visible_choice_indices"] = visible_maps
	choice_snapshot = MetaProgression.validate_scene_replay_snapshot(
		FROZEN_SURFACE_ROOT, choice_snapshot)
	var choice_story := STORY_MODE_SCRIPT.new()
	choice_story.set("_read_only_replay", true)
	choice_story.set("_gallery_replay_snapshot", choice_snapshot)
	choice_story.set("_current", DataRegistry.find_event(FROZEN_SURFACE_ROOT))
	var frozen_visible: Variant = choice_story.call(
		"_visible_choice_indices", DataRegistry.find_event(FROZEN_SURFACE_ROOT))
	_expect(not choice_snapshot.is_empty() \
			and frozen_visible == [1],
		"gallery replay recomputed visible choices from live state: " \
			+ "snapshot=%s actual=%s" % [str(choice_snapshot), str(frozen_visible)])
	choice_story.free()

	# Enter a real result phase and prove HUD/state/meta stay unchanged there too.
	story.call("_set_auto_mode", false, false, false)
	story.call("_finish_story_scene_transition")
	var paragraphs: Array = story.get("_paragraphs")
	story.set("_para_index", maxi(0, paragraphs.size() - 1))
	story.call("_complete_typing")
	story.call("_show_choices")
	story.call("_on_choice", 0)
	await get_tree().process_frame
	hud = story.get("_hud_panel") as Control
	_expect(is_instance_valid(hud) and not hud.visible \
			and story.get("_result_record_card") == null,
		"gallery result phase exposed HUD or a mechanical result card")
	_expect(GameState.serialize() == live_state_before,
		"gallery replay mutated serialized GameState")
	_expect(MetaProgression.data == meta_before,
		"gallery replay mutated persistent meta data")
	story.queue_free()
	await get_tree().process_frame
	BGMPlayer.end_gallery_replay()


func _prepare_generic_frozen_state() -> void:
	GameState.start_new_game()
	GameState.player_name = "최초기록이름"
	GameState.turn = 200
	GameState.year = 5
	GameState.month = 2
	GameState.week_of_month = 4
	GameState.moral_tint = -72.0
	GameState.housing = "gangnam"
	GameState.flags[FROZEN_SELECTOR_ID] = true


func _build_generic_snapshot(producer: Control, root_id: String) -> Dictionary:
	var selectors: Dictionary = {}
	var choices: Dictionary = {}
	for event_id in MetaProgression.gallery_replay_closure_ids(root_id):
		var event: Dictionary = DataRegistry.find_event(event_id)
		selectors[event_id] = producer.call(
			"_live_gallery_selector_matches", event)
		choices[event_id] = producer.call(
			"_live_gallery_visible_choice_indices", event)
	return MetaProgression.build_scene_replay_snapshot(
		root_id, selectors, choices)


func _build_complete_first_bill_snapshot(
		memory_id: String, include_hyunsu: bool) -> Dictionary:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	GameState.turn = 24
	GameState.year = 1
	GameState.month = 6
	GameState.week_of_month = 4
	GameState.player_name = "첫청구서기록"
	GameState.housing = "oneroom"
	if memory_id == "m3_ledger_both":
		GameState.flags["m3_ledger_reasons_named"] = true
		GameState.flags["m3_ledger_totals_only"] = true
	elif not memory_id.is_empty():
		GameState.flags[memory_id] = true
	if include_hyunsu:
		var state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
		var completed: Array = state.get("completed_bundles", []).duplicate()
		if not completed.has("hyunsu_study_followup"):
			completed.append("hyunsu_study_followup")
		state["completed_bundles"] = completed
		var stages: Dictionary = state.get("relationship_stages", {}).duplicate(true)
		stages["hyunsu"] = "shared_commitment"
		state["relationship_stages"] = stages
		GameState.core_loop_v2_state = state
	if not CORE_LOOP.begin_bundle("demo_collision", "schedule"):
		return {}
	var prepared := CORE_LOOP.prepare_demo_collision()
	if not bool(prepared.get("ok", false)):
		return {}
	var prechoice := CORE_LOOP.build_first_bill_replay_snapshot()
	if prechoice.is_empty():
		return {}
	var decision: Dictionary = DataRegistry.find_event(
		CORE_LOOP.FIRST_BILL_DECISION_ID)
	for choice_index in range((decision.get("choices", []) as Array).size()):
		var complete := CORE_LOOP.first_bill_replay_snapshot_with_choice(
			prechoice, choice_index)
		if not complete.is_empty():
			return MetaProgression.validate_scene_replay_snapshot(
				FIRST_BILL_ROOT, complete)
	return {}


func _reset_meta_fixture() -> void:
	MetaProgression.data = DataRegistry.default_meta.duplicate(true)
	MetaProgression.data["seen_scenes"] = []
	MetaProgression.data["scene_replay_snapshots"] = {}
	MetaProgression.save_meta()


func _disk_contains_all_pairs(roots: Array[String]) -> bool:
	var path := MetaProgression.meta_save_path()
	if not FileAccess.file_exists(path):
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		return false
	var seen: Variant = (parsed as Dictionary).get("seen_scenes", null)
	var snapshots: Variant = (parsed as Dictionary).get(
		"scene_replay_snapshots", null)
	if not seen is Array or not snapshots is Dictionary:
		return false
	for root_id in roots:
		if not (seen as Array).has(root_id) \
				or not (snapshots as Dictionary).has(root_id):
			return false
	return true


func _event_has_gallery_selector(event: Dictionary) -> bool:
	for map_key in [
		"portrait_if_known", "cg_if_known", "description_if_known",
		"description_if_held", "description_memory_if_known",
	]:
		var value: Variant = event.get(map_key, {})
		if value is Dictionary and not (value as Dictionary).is_empty():
			return true
	for field_key in [
		"description_low_mental", "description_long_gosiwon",
		"description_orthodox", "description_unorthodox",
	]:
		if event.has(field_key):
			return true
	for raw_choice in event.get("choices", []):
		if raw_choice is Dictionary \
				and not (raw_choice as Dictionary).get(
					"follow_up_requires_flags", []).is_empty():
			return true
	return false


func _event_has_temporal_portrait(event: Dictionary) -> bool:
	var portrait_ids: Array[String] = []
	var portrait_id := str(event.get("portrait", "")).strip_edges()
	if not portrait_id.is_empty():
		portrait_ids.append(portrait_id)
	var known: Variant = event.get("portrait_if_known", {})
	if known is Dictionary:
		for raw_id in (known as Dictionary).values():
			var known_id := str(raw_id).strip_edges()
			if not known_id.is_empty() and not portrait_ids.has(known_id):
				portrait_ids.append(known_id)
	for candidate_id in portrait_ids:
		if ImageRegistry.resolve_temporal_portrait_id(candidate_id, 1) \
				!= ImageRegistry.resolve_temporal_portrait_id(candidate_id, 240):
			return true
	return false


func _variant_contains_string(value: Variant, fragment: String) -> bool:
	if value is String:
		return str(value).contains(fragment)
	if value is Array:
		for item in value as Array:
			if _variant_contains_string(item, fragment):
				return true
	elif value is Dictionary:
		for item in (value as Dictionary).values():
			if _variant_contains_string(item, fragment):
				return true
	return false


func _variant_contains_exact_string(value: Variant, expected: String) -> bool:
	if value is String:
		return str(value) == expected
	if value is Array:
		for item in value as Array:
			if _variant_contains_exact_string(item, expected):
				return true
	elif value is Dictionary:
		for item in (value as Dictionary).values():
			if _variant_contains_exact_string(item, expected):
				return true
	return false


func _backup_state() -> void:
	_meta_backup = MetaProgression.data.duplicate(true)
	_meta_new_backup = MetaProgression._new_this_run.duplicate(true)
	_game_backup = GameState.serialize().duplicate(true)
	_language_backup = LocaleManager.language
	var path := MetaProgression.meta_save_path()
	_meta_file_existed = FileAccess.file_exists(path)
	if _meta_file_existed:
		_meta_file_copy = FileAccess.get_file_as_string(path)


func _restore_state() -> void:
	GameState.pending_story_queue.clear()
	GameState.story_replay_mode = false
	BGMPlayer.end_gallery_replay()
	GameState.load_from_dict(_game_backup)
	MetaProgression.data = _meta_backup.duplicate(true)
	MetaProgression._new_this_run = _meta_new_backup.duplicate(true)
	LocaleManager.set_language(_language_backup)
	DataRegistry.reload()
	var path := MetaProgression.meta_save_path()
	if _meta_file_existed:
		var file := FileAccess.open(path, FileAccess.WRITE)
		if file != null:
			file.store_string(_meta_file_copy)
			file.close()
	elif FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	await _stop_test_audio()
	_restore_state()
	if not _failures.is_empty():
		for message in _failures:
			push_error("GALLERY_REPLAY_SNAPSHOT_CHECK_FAIL: %s" % message)
		get_tree().quit(1)
		return
	print(
		"GALLERY_REPLAY_SNAPSHOT_CHECK_OK "
		+ "roots=20 authored_closure=51 runtime_max=52 "
		+ "name=44 portraits=12 moral=48 housing=4 selectors=6 choices=86 "
		+ "write_once=20 fail_closed=seen_only+orphan+corrupt+direct "
		+ "frozen=7 hud=0 mutation=0 m3=3+legacy")
	get_tree().quit(0)


func _stop_test_audio() -> void:
	BGMPlayer.stop()
	for owner in [AudioManager, BGMPlayer]:
		for child in owner.get_children():
			if child is AudioStreamPlayer:
				(child as AudioStreamPlayer).stop()
				(child as AudioStreamPlayer).stream = null
	for _frame in range(4):
		await get_tree().process_frame
