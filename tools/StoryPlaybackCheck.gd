extends Node

const CORE_LOOP := preload("res://systems/DemoCoreLoopV2.gd")
const STORY_MODE_SCRIPT := preload("res://scenes/StoryMode.gd")
const AUTO_REPLAY_ROOT := "arc_date_park_daeun"
const DIRECT_CONTINUE_EVENTS := [
	"story_flashforward",
	"story_arrival",
	"story_knee_door",
	"story_knee_witness",
	"story_last_payment_wait",
	"story_last_payment_exit",
	"story_pressure",
	"v2_opening_application_send",
]
const DEMO_SAME_LOCATION_EDGES := [
	["story_knee_door", "story_knee_witness"],
	["story_knee_witness", "story_knee_choice"],
	["story_last_payment_wait", "story_last_payment_word"],
]
const DEMO_REMOTE_EDGES := [
	["story_last_payment_exit", "story_prologue_dad"],
]
const DEMO_CLASSIFIED_TRANSITION_EDGES := {
	"memory_cut": ["story_arrival", "story_knee_door"],
	"time_cut": ["story_knee_choice", "story_last_payment_wait"],
	"explicit_move": ["story_prologue_dad", "story_prologue_goal"],
}
const DEMO_QUEUE_ONLY_EDGES := [
	["story_prologue_meal", "v2_opening_application_send", "time_cut"],
	["v2_opening_application_send", "arc_intro_01_meal", "explicit_move"],
	["arc_intro_01_meal", "v2_opening_return_math", "time_cut"],
]

var _story: Control

func _ready() -> void:
	if not await _check_default_auto_contract():
		return
	await _free_story_fixture()
	if not await _check_story_text_pagination():
		return
	await _free_story_fixture()
	if not await _check_accept_hold_boundary():
		return
	await _free_story_fixture()
	if not await _spawn_story_fixture():
		return

	_story.call("_set_auto_mode", true, false)
	for _step in range(12):
		if bool(_story.get("_showing_choices")):
			break
		if bool(_story.get("_typing")):
			_story.call("_complete_typing")
		_story.set("_auto_wait", 0.0)
		await get_tree().process_frame
		await get_tree().process_frame

	if not bool(_story.get("_showing_choices")):
		_fail("auto playback did not stop at the choice")
		return
	var event_id := str((_story.get("_current") as Dictionary).get("id", ""))
	await get_tree().create_timer(0.12).timeout
	if not bool(_story.get("_showing_choices")) or str((_story.get("_current") as Dictionary).get("id", "")) != event_id:
		_fail("auto playback selected or skipped a choice")
		return

	var toggle := InputEventKey.new()
	toggle.keycode = KEY_A
	toggle.pressed = true
	Input.parse_input_event(toggle)
	await get_tree().process_frame
	if bool(_story.get("_auto_mode")):
		_fail("keyboard auto toggle did not turn playback off")
		return
	await _free_story_fixture()
	if not await _check_direct_continue_contract():
		return
	await _free_story_fixture()
	if not await _check_classified_scene_transitions():
		return
	await _free_story_fixture()
	if not _check_queue_only_transition_contracts():
		return
	if not await _check_v2_fresh_guided_handoff():
		return
	await _free_story_fixture()
	if not await _check_same_location_handoff():
		return
	await _free_story_fixture()
	await _stop_test_audio()
	# Covered handoff fixtures intentionally leave a deferred scene replacement
	# pending until quit. Keep their transition click silent so that final frame
	# does not strand a one-shot stream while still avoiding a scene flash.
	AudioManager.sfx_enabled = false
	if not _check_covered_story_handoff():
		return
	if not _check_v2_covered_preplan_handoff():
		return

	print(
		"STORY_PLAYBACK_CHECK_OK auto=manual_default/session_opt_in replay=manual direct=%d classified=%d queue_only=%d same_location=%d " % [
			DIRECT_CONTINUE_EVENTS.size(), DEMO_CLASSIFIED_TRANSITION_EDGES.size(),
			DEMO_QUEUE_ONLY_EDGES.size(), DEMO_SAME_LOCATION_EDGES.size()
		]
		+ "direct_commit=1 hints=ko_en_xbox_ps_nintendo choice_commit=0 "
		+ "fresh_guided=1 story_send_writes=0 legacy_paused_send=1 "
		+ "legacy_covered=1 typed_w1_covered=1"
	)
	get_tree().quit(0)

func _check_story_text_pagination() -> bool:
	var original_size := str(SaveManager.get_setting("story_text_size", "standard"))
	if not await _spawn_story_fixture("arc_sangchul_01_answer"):
		return false
	var choices: Array = (_story.get("_current") as Dictionary).get("choices", [])
	if choices.is_empty():
		_fail("long-result fixture has no choice")
		return false
	var result_text := str((choices[0] as Dictionary).get("result_text", ""))
	for size_level in ["standard", "large"]:
		_story.call("_set_story_text_size", size_level)
		var page_data: Dictionary = _story.call("_story_page_data", result_text)
		var pages: Array = page_data.get("pages", [])
		var source_indices: Array = page_data.get("source_indices", [])
		if pages.size() < 2:
			_fail("%s story text did not paginate the clipped Sangchul result" % size_level)
			return false
		if source_indices.size() != pages.size():
			_fail("%s story pagination lost source paragraph mapping" % size_level)
			return false
		for page_index in range(pages.size()):
			if int(source_indices[page_index]) != 0:
				_fail("%s story pagination changed the authored paragraph index" % size_level)
				return false
			if not bool(_story.call("_story_page_fits", str(pages[page_index]))):
				_fail("%s story page %d still overflows the dialogue panel" % [
					size_level, page_index])
				return false
	_story.call("_show_story_result_record", choices[0])
	if _story.get("_result_record_card") != null:
		_fail("StoryMode recreated a mechanical result card over authored prose")
		return false
	_story.call("_set_story_text_size", original_size)
	return true

func _spawn_story_fixture(
		event_id: String = "story_prologue_dad",
		disable_auto: bool = true,
		replay_mode: bool = false) -> bool:
	GameState.story_replay_mode = replay_mode
	GameState.pending_story_queue = [event_id]
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	await get_tree().process_frame
	await get_tree().process_frame
	if str((_story.get("_current") as Dictionary).get("id", "")) != event_id:
		_fail("story fixture did not load %s: actual=%s replay=%s queue=%s health=%d mental=%d assets=%s addiction=%d fatal=%s" % [
			event_id,
			str((_story.get("_current") as Dictionary).get("id", "")),
			str(GameState.story_replay_mode),
			str(_story.get("_queue")),
			int(GameState.health), int(GameState.mental),
			str(GameState.get_total_asset_value()),
			int(GameState.addiction_tendency),
			str(_story.call("_story_has_pending_fatal_state")),
		])
		return false
	if disable_auto:
		_story.call("_set_auto_mode", false, false, false)
	return true

func _free_story_fixture() -> void:
	if is_instance_valid(_story):
		_story.queue_free()
		await get_tree().process_frame
	_story = null

func _check_default_auto_contract() -> bool:
	var original_replay_mode := GameState.story_replay_mode
	if not await _spawn_story_fixture("story_prologue_dad", false, false):
		return false
	if bool(_story.get("_auto_mode")):
		_fail("fresh story playback enabled auto before player consent")
		return false
	_story.call("_set_auto_mode", true, false, true)
	if not bool(_story.get("_auto_mode")):
		_fail("player could not enable auto for the current app session")
		return false
	await _free_story_fixture()

	if not _seed_gallery_replay_pair(AUTO_REPLAY_ROOT):
		_fail("auto contract could not seed a valid gallery replay pair")
		return false
	if not await _spawn_story_fixture(AUTO_REPLAY_ROOT, false, true):
		return false
	if bool(_story.get("_auto_mode")):
		_fail("read-only replay did not default to manual playback")
		return false
	await _free_story_fixture()

	if not await _spawn_story_fixture("story_prologue_dad", false, false):
		return false
	if not bool(_story.get("_auto_mode")):
		_fail("read-only replay overwrote the player-enabled session preference")
		return false
	GameState.story_replay_mode = original_replay_mode
	return true

func _seed_gallery_replay_pair(root_id: String) -> bool:
	var producer := STORY_MODE_SCRIPT.new()
	var selectors: Dictionary = {}
	var choices: Dictionary = {}
	for event_id in MetaProgression.gallery_replay_closure_ids(root_id):
		var event: Dictionary = DataRegistry.find_event(event_id)
		if event.is_empty():
			producer.free()
			return false
		selectors[event_id] = producer.call(
			"_live_gallery_selector_matches", event)
		choices[event_id] = producer.call(
			"_live_gallery_visible_choice_indices", event)
	producer.free()
	var snapshot := MetaProgression.build_scene_replay_snapshot(
		root_id, selectors, choices)
	if snapshot.is_empty():
		return false
	# This playback check owns only an in-memory fixture. Persistence and atomic
	# pairing are covered by GalleryReplaySnapshotCheck, so a direct developer
	# run must not write a gallery unlock into their real meta save.
	var raw_seen: Variant = MetaProgression.data.get("seen_scenes", [])
	var seen: Array = (raw_seen as Array).duplicate() if raw_seen is Array else []
	if not seen.has(root_id):
		seen.append(root_id)
	var raw_snapshots: Variant = MetaProgression.data.get(
		"scene_replay_snapshots", {})
	var snapshots: Dictionary = (raw_snapshots as Dictionary).duplicate(true) \
		if raw_snapshots is Dictionary else {}
	snapshots[root_id] = snapshot.duplicate(true)
	MetaProgression.data["seen_scenes"] = seen
	MetaProgression.data["scene_replay_snapshots"] = snapshots
	return MetaProgression.has_valid_scene_replay_pair(root_id)

func _check_accept_hold_boundary() -> bool:
	var original_language := LocaleManager.language
	LocaleManager.set_language("en")
	ControllerHints.force_brand_for_qa(ControllerHints.Brand.XBOX)
	if not await _spawn_story_fixture():
		return false
	var paragraphs: Array = _story.get("_paragraphs")
	if paragraphs.size() < 3:
		_fail("story fixture needs at least three prose paragraphs")
		return false
	_story.call("_complete_typing")
	var continue_hint := _story.get("_continue_hint") as Label
	if not is_instance_valid(continue_hint):
		_fail("story continue hint is missing")
		return false
	for hint_fixture in [
			[ControllerHints.Brand.XBOX, "A"],
			[ControllerHints.Brand.PLAYSTATION, "✕"],
			[ControllerHints.Brand.NINTENDO, "B"],
	]:
		ControllerHints.force_brand_for_qa(hint_fixture[0])
		var south_label := str(hint_fixture[1])
		LocaleManager.set_language("en")
		_story.call("_refresh_continue_hint_text")
		if continue_hint.text != "[%s] Advance · Hold to read" % south_label:
			_fail("English gamepad hold hint is missing or mislabeled for %s" % south_label)
			return false
		if not _hint_fits(continue_hint):
			_fail("English gamepad hold hint overflows for %s" % south_label)
			return false
		LocaleManager.set_language("ko")
		_story.call("_refresh_continue_hint_text")
		if continue_hint.text != "[%s] 진행 · 길게 읽기" % south_label:
			_fail("Korean gamepad hold hint is missing or mislabeled for %s" % south_label)
			return false
		if not _hint_fits(continue_hint):
			_fail("Korean gamepad hold hint overflows for %s" % south_label)
			return false
	ControllerHints.force_brand_for_qa(ControllerHints.Brand.XBOX)
	LocaleManager.set_language("en")
	_story.call("_refresh_continue_hint_text")
	var event_id := str((_story.get("_current") as Dictionary).get("id", ""))
	await _send_accept_action(true)
	for _step in range(16):
		_story.call("_process", 0.20)
		if not bool(_story.get("_advance_hold_active")):
			break
	var final_index := paragraphs.size() - 1
	if int(_story.get("_para_index")) != final_index or bool(_story.get("_typing")):
		_fail("one held accept did not flow to the final prose paragraph")
		return false
	if bool(_story.get("_showing_choices")) \
			or str((_story.get("_current") as Dictionary).get("id", "")) != event_id:
		_fail("held accept crossed the prose boundary")
		return false
	_story.call("_refresh_continue_hint_text")
	if continue_hint.text != "[A] Advance":
		_fail("final paragraph still advertises a hold that cannot cross the boundary")
		return false
	await _send_accept_action(false)
	await _send_accept_action(true)
	if not bool(_story.get("_showing_choices")):
		_fail("a fresh accept did not open the choice after held prose")
		return false
	_story.call("_process", 1.0)
	if not bool(_story.get("_showing_choices")) \
			or str((_story.get("_current") as Dictionary).get("id", "")) != event_id:
		_fail("held prose input selected a choice or crossed events")
		return false
	await _send_accept_action(false)
	ControllerHints.clear_qa_override()
	LocaleManager.set_language(original_language)
	return true

func _check_direct_continue_contract() -> bool:
	var original_language := LocaleManager.language
	var original_state: Dictionary = GameState.serialize().duplicate(true)
	LocaleManager.set_language("en")
	ControllerHints.force_brand_for_qa(ControllerHints.Brand.XBOX)
	if not await _spawn_story_fixture("story_pressure"):
		return false

	var continue_hint := _story.get("_continue_hint") as Label
	for language in ["ko", "en"]:
		LocaleManager.set_language(language)
		for event_id in DIRECT_CONTINUE_EVENTS:
			var localized: Dictionary = DataRegistry.find_event(event_id)
			if localized.is_empty():
				_fail("direct-continue event is missing: %s" % event_id)
				return false
			_set_direct_fixture_state(localized)
			for hint_fixture in [
				[ControllerHints.Brand.XBOX, "A"],
				[ControllerHints.Brand.PLAYSTATION, "✕"],
				[ControllerHints.Brand.NINTENDO, "B"],
			]:
				ControllerHints.force_brand_for_qa(hint_fixture[0])
				_story.call("_refresh_continue_hint_text")
				var action_text := str(_story.call("_direct_continue_action_text"))
				var expected := "[%s] %s" % [hint_fixture[1], action_text]
				if continue_hint.text != expected:
					_fail("direct action hint drifted for %s/%s" % [language, event_id])
					return false
				if not _hint_fits(continue_hint):
					_fail("direct action hint overflows for %s/%s" % [language, event_id])
					return false

	LocaleManager.set_language("en")
	ControllerHints.force_brand_for_qa(ControllerHints.Brand.XBOX)
	_set_direct_fixture_state(DataRegistry.find_event("story_flashforward"))
	_story.call("_set_auto_mode", true, false, false)
	_story.call("_complete_typing")
	if not bool(_story.get("_direction_hold_active")):
		_fail("cinematic direct action did not begin its authored hold")
		return false
	_story.call("_process", 2.1)
	if float(_story.get("_auto_wait")) < 0.0:
		_fail("cinematic hold did not return a direct action to auto playback")
		return false

	_set_direct_fixture_state(DataRegistry.find_event("story_pressure"))
	_story.call("_set_auto_mode", true, false, false)
	_story.call("_refresh_continue_hint_text")
	if continue_hint.text != "[A] Open a job app. Survival comes first.":
		_fail("legacy direct action no longer describes opening the job app")
		return false

	# This direct action survives only for an old save paused on the former Send
	# screen. Its exact adjacent queue is the provenance required by StoryMode.
	GameState.start_new_game()
	if not CORE_LOOP.initialize_for_run(true):
		_fail("legacy paused-Send fixture could not initialize")
		return false
	GameState.turn = 1
	GameState.flags["prologue_done"] = true
	var legacy_roots: Array = CORE_LOOP.fresh_preplan_opening_roots()
	if legacy_roots != ["arc_intro_01_meal", "v2_opening_return_math"] \
			or not CORE_LOOP.fresh_w1_onboarding_snapshot().is_empty():
		_fail("legacy paused-Send fixture lost its no-marker adjacent queue")
		return false
	_story.set("_queue", legacy_roots.duplicate())
	_set_direct_fixture_state(DataRegistry.find_event(
		CORE_LOOP.OPENING_APPLICATION_EVENT_ID))
	_story.call("_set_auto_mode", true, false, false)
	_story.call("_refresh_continue_hint_text")
	if continue_hint.text != "[A] Send an application to Mirae Industrial Tech":
		_fail("V2 direct action does not state the committed Send")
		return false

	var legacy_before: Dictionary = GameState.serialize().duplicate(true)
	var events_before: int = GameState.events_seen
	_story.call("_arm_auto_advance", "final")
	_story.set("_auto_wait", 0.0)
	_story.call("_process", 0.01)
	if bool(_story.get("_showing_choices")) or not bool(_story.get("_pending_after_result")):
		_fail("auto direct action opened a fake choice rail or skipped its result")
		return false
	if GameState.intelligence != int(legacy_before.get("intelligence", 0)) \
			or GameState.events_seen != events_before + 1 \
			or not bool(GameState.flags.get("story_job_unlocked", false)) \
			or not bool(GameState.flags.get(
				"opening_interview_application_sent", false)) \
			or CORE_LOOP.application_status(
				"mirae_industrial_tech") != "submitted" \
			or CORE_LOOP.active_bundle_id() \
				!= CORE_LOOP.OPENING_INTERVIEW_BUNDLE_ID \
			or not CORE_LOOP.action_receipt(
				CORE_LOOP.W1_ONBOARDING_BUNDLE_ID).is_empty() \
			or GameState.has_weekly_commitment_for_turn(1):
		_fail("legacy direct Send lost its exact non-weekly application provenance")
		return false
	var legacy_after: Dictionary = GameState.serialize().duplicate(true)
	for _step in range(4):
		_story.call("_process", 0.40)
	if GameState.serialize() != legacy_after:
		_fail("held legacy Send applied its transaction more than once")
		return false

	GameState.call("_restore_serialized_snapshot_exact", original_state)
	ControllerHints.clear_qa_override()
	LocaleManager.set_language(original_language)
	return true

func _set_direct_fixture_state(event: Dictionary) -> void:
	_story.set("_current", event)
	_story.set("_paragraphs", ["final"])
	_story.set("_para_index", 0)
	_story.set("_type_full", "final")
	_story.set("_type_pos", 5)
	_story.set("_typing", false)
	_story.set("_pending_after_result", false)
	_story.set("_showing_choices", false)
	_story.set("_is_chapter_card", false)
	_story.set("_direction_hold_active", false)
	_story.set("_direction_hold_consumed", false)
	_story.set("_direction_hold_remaining", 0.0)
	_story.set("_direction", event.get("direction", {}))

func _check_same_location_handoff() -> bool:
	for edge in DEMO_SAME_LOCATION_EDGES:
		var contract := DataRegistry.get_story_transition(str(edge[0]), str(edge[1]))
		if str(contract.get("mode", "")) != "same_location":
			_fail("same-location transition contract is missing: %s->%s" % edge)
			return false
	for edge in DEMO_REMOTE_EDGES:
		var contract := DataRegistry.get_story_transition(str(edge[0]), str(edge[1]))
		if str(contract.get("mode", "")) != "remote":
			_fail("remote no-wipe transition contract is missing: %s->%s" % edge)
			return false

	if not await _spawn_story_fixture("story_knee_door"):
		return false
	var paragraphs: Array = _story.get("_paragraphs")
	_story.set("_para_index", paragraphs.size() - 1)
	_story.call("_start_typing", str(paragraphs[-1]))
	_story.call("_complete_typing")
	_story.call("_on_advance")
	if not bool(_story.get("_pending_after_result")):
		_fail("same-location source did not expose its result before handoff")
		return false
	var result_paragraphs: Array = _story.get("_paragraphs")
	_story.set("_para_index", result_paragraphs.size() - 1)
	_story.call("_start_typing", str(result_paragraphs[-1]))
	_story.call("_complete_typing")
	var ink_tween := _story.get("_story_ink_transition_tween") as Tween
	if ink_tween != null:
		ink_tween.kill()
	_story.set("_story_ink_transition_tween", null)
	var ink_layer := _story.get("_story_ink_transition_layer") as Control
	ink_layer.visible = false
	_story.call("_on_advance")
	if str((_story.get("_current") as Dictionary).get("id", "")) != "story_knee_witness":
		_fail("same-location follow-up did not load")
		return false
	if str(_story.get("_current_transition_mode")) != "same_location":
		_fail("same-location mode was not consumed by the follow-up")
		return false
	if _story.get("_story_ink_transition_tween") != null or ink_layer.visible:
		_fail("same-location follow-up replayed the full scene ink transition")
		return false
	var background_snapshot := _story.get("_story_transition_snapshot") as TextureRect
	if bool(_story.get("_story_scene_transition_active")) \
			or (is_instance_valid(background_snapshot) and background_snapshot.visible):
		_fail("same-location follow-up captured a redundant scene snapshot")
		return false
	var text_panel := _story.get("_text_panel") as Control
	if not is_equal_approx(text_panel.modulate.a, 1.0):
		_fail("same-location follow-up replayed the text-panel fade")
		return false
	return true

func _check_classified_scene_transitions() -> bool:
	for mode in DEMO_CLASSIFIED_TRANSITION_EDGES:
		var edge: Array = DEMO_CLASSIFIED_TRANSITION_EDGES[mode]
		var contract := DataRegistry.get_story_transition(str(edge[0]), str(edge[1]))
		if str(contract.get("mode", "")) != mode:
			_fail("classified transition contract drifted: %s->%s" % edge)
			return false
		if not await _check_runtime_transition_handoff(
				str(edge[0]), str(edge[1]), str(mode)):
			return false

	if not await _spawn_story_fixture("story_arrival"):
		return false
	var original_reduce_motion := bool(SaveManager.get_setting("reduce_motion", false))
	SaveManager.set_setting("reduce_motion", false)
	var failure := ""
	var expected_seconds := {
		"memory_cut": 0.78,
		"time_cut": 0.86,
		"explicit_move": 0.54,
	}
	for mode in ["memory_cut", "time_cut", "explicit_move"]:
		var type_pos_before := int(_story.get("_type_pos"))
		_story.call("_begin_story_scene_transition", mode)
		var snapshot := _story.get("_story_transition_snapshot") as TextureRect
		var portrait_snapshot := _story.get("_story_transition_portrait_snapshot") as TextureRect
		if not bool(_story.get("_story_scene_transition_active")) \
				or not is_instance_valid(snapshot) or not snapshot.visible \
				or snapshot.texture == null:
			failure = "%s did not preserve the outgoing scene" % mode
			break
		if str(_story.get_meta("story_transition_mode", "")) != mode:
			failure = "%s did not reach the runtime transition grammar" % mode
			break
		var duration := float(_story.get_meta("story_transition_duration", 0.0))
		if not is_equal_approx(duration, float(expected_seconds[mode])):
			failure = "%s transition duration drifted" % mode
			break
		_story.call("_process", 0.50)
		if int(_story.get("_type_pos")) != type_pos_before:
			failure = "%s advanced prose behind the scene transition" % mode
			break
		_story.call("_set_story_ink_transition_progress", 0.50)
		if snapshot.modulate.a >= 1.0 or snapshot.modulate.a <= 0.0:
			failure = "%s did not cross-dissolve the outgoing background" % mode
			break
		if is_instance_valid(portrait_snapshot) and portrait_snapshot.visible \
				and portrait_snapshot.modulate.a != snapshot.modulate.a:
			failure = "%s desynchronized the outgoing portrait and background" % mode
			break
		_story.call("_finish_story_scene_transition")

	if failure.is_empty():
		SaveManager.set_setting("reduce_motion", true)
		_story.call("_begin_story_scene_transition", "memory_cut")
		var reduced_snapshot := _story.get("_story_transition_snapshot") as TextureRect
		var reduced_scale := reduced_snapshot.scale
		_story.call("_set_story_ink_transition_progress", 0.50)
		if float(_story.get_meta("story_transition_duration", 1.0)) > 0.25:
			failure = "Reduce Motion did not shorten the scene transition"
		elif reduced_snapshot.scale != reduced_scale:
			failure = "Reduce Motion left camera scaling in the scene transition"
		_story.call("_finish_story_scene_transition")

	SaveManager.set_setting("reduce_motion", original_reduce_motion)
	if not failure.is_empty():
		_fail(failure)
		return false
	return true

func _check_queue_only_transition_contracts() -> bool:
	var authored_contracts: Dictionary = DataRegistry.story_rules.get(
		"transition_contracts", {})
	for edge in DEMO_QUEUE_ONLY_EDGES:
		var edge_key := "%s->%s" % [edge[0], edge[1]]
		var contract := DataRegistry.get_story_transition(
			str(edge[0]), str(edge[1]))
		var authored: Dictionary = authored_contracts.get(edge_key, {})
		var expected_mode := str(edge[2])
		if str(contract.get("mode", "")) != expected_mode \
				or not bool(authored.get("queue_only", false)):
			_fail(
				"V2 opening transition is not queue-only mode %s: %s->%s" % [
					expected_mode, edge[0], edge[1],
				]
			)
			return false
		var legacy_send_edge := str(edge[0]) \
			== CORE_LOOP.OPENING_APPLICATION_EVENT_ID \
			or str(edge[1]) == CORE_LOOP.OPENING_APPLICATION_EVENT_ID
		if legacy_send_edge \
				and not bool(authored.get("legacy_only", false)):
			_fail("a retired Story Send edge is no longer legacy-only: %s" % [
				edge_key,
			])
			return false
	return true

func _check_v2_fresh_guided_handoff() -> bool:
	GameState.start_new_game()
	if not CORE_LOOP.initialize_for_run(true):
		_fail("fresh guided-W1 fixture could not initialize")
		return false
	GameState.turn = 1
	if not CORE_LOOP.begin_fresh_w1_onboarding():
		_fail("fresh guided-W1 fixture could not create its owner")
		return false
	GameState.flags["prologue_done"] = true
	var roots: Array = CORE_LOOP.fresh_preplan_opening_roots()
	if not roots.is_empty():
		_fail("fresh V2 queue reserved material before the W1 action")
		return false
	GameState.pending_story_queue = ["story_prologue_meal"]
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	await get_tree().process_frame
	await get_tree().process_frame
	var current: Dictionary = _story.get("_current")
	var reserved_queue: Array = _story.get("_queue")
	if str(current.get("id", "")) != "story_prologue_meal" \
			or not reserved_queue.is_empty():
		_fail("fresh StoryMode queued Send/interview/math/chapter before W1")
		return false
	var choices: Array = current.get("choices", [])
	if choices.size() != 2:
		_fail("prologue meal fixture lost its two authored choices")
		return false
	var before_follow_up: Dictionary = GameState.serialize().duplicate(true)
	var follow_up := str(_story.call(
		"_choice_follow_up_id", choices[0] as Dictionary,
		"story_prologue_meal", 0))
	if not follow_up.is_empty() \
			or CORE_LOOP.story_choice_commit_available(
				CORE_LOOP.OPENING_APPLICATION_EVENT_ID, 0, []) \
			or CORE_LOOP.note_story_choice(
				CORE_LOOP.OPENING_APPLICATION_EVENT_ID, 0, []) \
			or GameState.serialize() != before_follow_up:
		_fail("fresh prologue did not stop cleanly before the guided board")
		return false
	var before_choice: Dictionary = GameState.serialize().duplicate(true)
	_story.call("_on_choice", 0)
	var state_after_choice: Dictionary = GameState.core_loop_v2_state
	if not bool(_story.get("_pending_after_result")) \
			or GameState.serialize() == before_choice \
			or not (
				state_after_choice.get(
					"story_choice_receipts", {}) as Dictionary
			).is_empty():
		_fail("fresh prologue choice was blocked or minted a V2 owner receipt")
		return false
	var initialized := CORE_LOOP.initialize_seoul_cycle(1)
	if not bool(initialized.get("ok", false)) \
			or CORE_LOOP.fresh_w1_onboarding_phase() != "board" \
			or CORE_LOOP.application_status(
				"mirae_industrial_tech") != "" \
			or not CORE_LOOP.action_receipt(
				CORE_LOOP.W1_ONBOARDING_BUNDLE_ID).is_empty():
		_fail("fresh prologue did not hand off to an unallocated guided W1 board")
		return false
	return true

func _check_runtime_transition_handoff(
		source_id: String, target_id: String, expected_mode: String) -> bool:
	await _free_story_fixture()
	# Non-gallery events can no longer borrow the public replay flag as a
	# mutation-free fixture. Exercise the real live handoff, then restore the
	# exact run/meta snapshot after the transition assertion.
	var state_before: Dictionary = GameState.serialize().duplicate(true)
	var meta_before: Dictionary = MetaProgression.data.duplicate(true)
	if not await _spawn_story_fixture(source_id, true, false):
		return false
	var choices: Array = (_story.get("_current") as Dictionary).get("choices", [])
	if choices.is_empty():
		_fail("classified transition source has no authored continuation: %s" % source_id)
		return false
	_story.call("_on_choice", 0)
	if bool(_story.get("_pending_after_result")):
		var result_paragraphs: Array = _story.get("_paragraphs")
		_story.set("_para_index", result_paragraphs.size() - 1)
		_story.call("_start_typing", str(result_paragraphs[-1]))
		_story.call("_complete_typing")
		_story.call("_on_advance")
	var current_id := str((_story.get("_current") as Dictionary).get("id", ""))
	if current_id != target_id:
		_fail("classified transition did not load %s from %s" % [target_id, source_id])
		return false
	if str(_story.get("_current_transition_mode")) != expected_mode \
			or str(_story.get_meta("story_transition_mode", "")) != expected_mode:
		_fail("classified transition mode was not consumed: %s->%s" % [source_id, target_id])
		return false
	var snapshot := _story.get("_story_transition_snapshot") as TextureRect
	if not bool(_story.get("_story_scene_transition_active")) \
			or not is_instance_valid(snapshot) or not snapshot.visible \
			or snapshot.texture == null:
		_fail("classified handoff hard-cut without an outgoing snapshot: %s" % expected_mode)
		return false
	_story.call("_finish_story_scene_transition")
	await _free_story_fixture()
	GameState.call("_restore_serialized_snapshot_exact", state_before)
	MetaProgression.data = meta_before
	return true

func _hint_fits(hint: Label) -> bool:
	var font := hint.get_theme_font("font")
	var font_size := hint.get_theme_font_size("font_size")
	var text_width := font.get_string_size(
		hint.text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
	return text_width <= hint.size.x

func _send_accept_action(pressed: bool) -> void:
	var action := InputEventAction.new()
	action.action = "ui_accept"
	action.pressed = pressed
	Input.parse_input_event(action)
	await get_tree().process_frame

func _check_covered_story_handoff() -> bool:
	# The preceding guided-W1 fixture deliberately enables V2. Reset to a
	# genuine legacy run so this handoff proves compatibility rather than
	# inheriting the new router through shared autoload state.
	GameState.start_new_game()
	GameState.turn = 3
	GameState.housing = "gosiwon"
	GameState.flags = {
		"prologue_done": true,
		"chapter_33_seen": true,
		"arc_intro_meal_seen": true,
	}
	GameState.pending_story_queue.clear()
	var active_tween := SceneTransition.get("_tween") as Tween
	if active_tween != null:
		active_tween.kill()
	SceneTransition.set("_tween", null)
	SceneTransition.call("_set_transition_alpha", 1.0)

	var main_script := load("res://scenes/MainGame.gd") as GDScript
	var main: Node = main_script.new()
	main.set_meta("_screenshot_qa_static_surface", true)
	main.call("_continue_after_story")
	var queued_id := str(GameState.pending_story_queue[0]) if not GameState.pending_story_queue.is_empty() else ""
	if queued_id != "arc_intro_02_dad_call":
		main.free()
		_fail("story return did not queue the next due arc behind the cover")
		return false
	if SceneTransition.get("_tween") != null or float(SceneTransition.get("_transition_alpha")) < 0.99:
		main.free()
		_fail("story return began revealing MainGame before the next arc")
		return false
	main.free()
	return true

func _check_v2_covered_preplan_handoff() -> bool:
	if not _prepare_fresh_w1_action_completed():
		_fail("typed W1 covered handoff fixture could not finish its action")
		return false
	GameState.pending_story_queue.clear()
	var active_tween := SceneTransition.get("_tween") as Tween
	if active_tween != null:
		active_tween.kill()
	SceneTransition.set("_tween", null)
	SceneTransition.call("_set_transition_alpha", 1.0)

	var main_script := load("res://scenes/MainGame.gd") as GDScript
	var main: Node = main_script.new()
	main.set_meta("_screenshot_qa_static_surface", true)
	main.call("_core_loop_v2_route_week")
	var receipt: Dictionary = (
		GameState.core_loop_v2_state.get(
			"consequence_receipts", {}) as Dictionary
	).get(CORE_LOOP.OPENING_INTERVIEW_BUNDLE_ID, {})
	var expected_queue := ["arc_intro_01_meal", "v2_opening_return_math"]
	var queue_is_exact := GameState.pending_story_queue == expected_queue
	var remained_covered := float(
		SceneTransition.get("_transition_alpha")) >= 0.99
	active_tween = SceneTransition.get("_tween") as Tween
	if active_tween != null:
		active_tween.kill()
	SceneTransition.set("_tween", null)
	main.free()
	if not queue_is_exact or not remained_covered \
			or CORE_LOOP.active_bundle_id() \
				!= CORE_LOOP.OPENING_INTERVIEW_BUNDLE_ID \
			or str(receipt.get("status", "")) != "presented" \
			or receipt.get("roots", []) != expected_queue \
			or str(receipt.get("claim_source", "")) \
				!= "typed_action_receipt":
		_fail(
			"Typed W1 Send did not queue exactly interview -> calculation "
			+ "behind the opaque cover")
		return false
	return true

func _prepare_fresh_w1_action_completed() -> bool:
	GameState.start_new_game()
	if not CORE_LOOP.initialize_for_run(true):
		return false
	GameState.turn = 1
	GameState.flags["prologue_done"] = true
	if not CORE_LOOP.begin_fresh_w1_onboarding():
		return false
	var initialized := CORE_LOOP.initialize_seoul_cycle(1)
	var capacities: Array = CORE_LOOP.seoul_cycle_snapshot(1).get(
		"capacities", [])
	if not bool(initialized.get("ok", false)) or capacities.is_empty():
		return false
	var capacity: Dictionary = capacities[0]
	var allocation := CORE_LOOP.commit_seoul_cycle_allocation(
		str(capacity.get("id", "")), CORE_LOOP.W1_ONBOARDING_NODE_ID, 1)
	if not bool(allocation.get("ok", false)):
		return false
	var claim := CORE_LOOP.claim_seoul_cycle_trigger()
	if not bool(claim.get("ok", false)) \
			or not CORE_LOOP.begin_seoul_cycle_trigger(
				CORE_LOOP.W1_ONBOARDING_BUNDLE_ID) \
			or not GameState.arm_weekly_commitment({
				"turn": 1,
				"pressure_id": CORE_LOOP.W1_ONBOARDING_BUNDLE_ID,
				"pressure_family": "growth",
				"choice_id": "resume",
				"forgone_ids": [],
				"supplemental_to_seoul_cycle": true,
			}) \
			or not CORE_LOOP.restart_fresh_w1_minigame():
		return false
	var transaction := CORE_LOOP.finalize_fresh_w1_application(2, 2)
	return bool(transaction.get("ok", false)) \
		and CORE_LOOP.complete_active_bundle() \
			== CORE_LOOP.W1_ONBOARDING_BUNDLE_ID \
		and CORE_LOOP.fresh_w1_onboarding_phase() == "action_completed"

func _stop_test_audio() -> void:
	BGMPlayer.stop()
	for owner in [AudioManager, BGMPlayer]:
		for child in owner.get_children():
			if child is AudioStreamPlayer:
				(child as AudioStreamPlayer).stop()
				(child as AudioStreamPlayer).stream = null
	for _frame in range(4):
		await get_tree().process_frame

func _fail(message: String) -> void:
	push_error("STORY_PLAYBACK_CHECK_FAIL: %s" % message)
	get_tree().quit(1)
