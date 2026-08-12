extends Node
## The prologue must remain a continuous dramatic scene. System teaching belongs to the AP hub.

const STORY_MODE_PATH := "res://scenes/StoryMode.tscn"
const CORE_LOOP := preload("res://systems/DemoCoreLoopV2.gd")

var _failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	var story_source := FileAccess.get_file_as_string("res://scenes/StoryMode.gd")
	_expect(not story_source.contains("_maybe_show_tutorial_popup"),
		"StoryMode regained a per-choice tutorial trigger")
	_expect(not story_source.contains("var _tutorial_popup"),
		"StoryMode regained a tutorial modal surface")

	LocaleManager.set_language("ko")
	# This gate validates presentation order, not the audio mix. Keeping one-shot
	# SFX silent avoids quitting while the direct-action sting is still decoding.
	AudioManager.sfx_enabled = false
	GameState.start_new_game()
	GameState.pending_story_queue = ["story_knee_witness"]
	GameState.story_return_scene = "res://scenes/MainGame.tscn"

	var packed: PackedScene = load(STORY_MODE_PATH)
	var story := packed.instantiate()
	add_child(story)
	await get_tree().process_frame
	await get_tree().process_frame

	_expect(str(story.get("_current").get("id", "")) == "story_knee_witness",
		"prologue fixture did not open")
	_expect(str(story.get("_current").get("portrait", "")) == "father_past",
		"the six-years-earlier scene did not select the younger father")
	var father_portrait := story.get("_portrait") as TextureRect
	_expect(father_portrait != null and father_portrait.visible and father_portrait.texture != null,
		"the kneeling-father scene did not render the younger canonical father")
	var expected_past_portrait := ImageRegistry.get_portrait("father_past")
	_expect(father_portrait.texture != null \
		and father_portrait.texture.resource_path == expected_past_portrait,
		"the six-years-earlier scene rendered the wrong father texture")
	await _advance_until_direct_action(story)
	_expect(int(story.call("_direct_continue_choice_index")) == 0,
		"prologue did not reach its direct authored action (%s)" % _story_state(story))
	_expect(not bool(story.get("_showing_choices")),
		"single authored action reopened the obsolete choice rail")
	var choice_box: VBoxContainer = story.get("_choice_box")
	_expect(choice_box != null and not choice_box.visible and choice_box.get_child_count() == 0,
		"single authored action left choice controls on screen")
	var continue_hint: Label = story.get("_continue_hint")
	var direct_action := str(story.call("_direct_continue_action_text"))
	_expect(direct_action == "아버지가 다시 입을 여는 걸 본다",
		"direct action lost its authored Korean copy")
	_expect(continue_hint != null and continue_hint.visible \
		and continue_hint.text.contains(direct_action),
		"direct action was not visible before commitment")

	var mental_before: int = GameState.mental
	story.call("_on_advance")
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(GameState.mental == mental_before - 2, "direct action did not apply its mental cost once")
	_expect(bool(story.get("_pending_after_result")), "direct-action result text did not begin")
	_expect(str(story.get("_type_full")).contains("아버지의 손바닥"),
		"direct-action result paragraph was hidden or replaced")
	_expect(not _tree_contains_text(story, "능력치와 자원"),
		"stats tutorial interrupted the prologue result")

	await _advance_until_event(story, "story_knee_choice")
	_expect(str(story.get("_current").get("id", "")) == "story_knee_choice",
		"direct-action result did not continue to its authored follow-up")
	_expect(str(story.get("_current").get("portrait", "")) == "father_past",
		"the younger father disappeared before the prologue's defining choice")
	_expect(not _tree_contains_text(story, "능력치와 자원"),
		"stats tutorial survived into the follow-up scene")

	var slides: Array = TutorialOverlay._get_slides("main_game")
	var dashboard_copy := ""
	for slide_value in slides:
		var slide: Dictionary = slide_value
		if str(slide.get("title", "")) == "대시보드 읽는 법":
			dashboard_copy = str(slide.get("body", ""))
	_expect(not dashboard_copy.is_empty(), "first AP tutorial lost its dashboard slide")
	_expect(dashboard_copy.contains("자산") and dashboard_copy.contains("건강") \
		and dashboard_copy.contains("정신력"),
		"first AP tutorial no longer explains the three visible resources")
	var weekly_copy := ""
	for slide_value in slides:
		var slide: Dictionary = slide_value
		if str(slide.get("title", "")) == "한 주의 흐름":
			weekly_copy = str(slide.get("body", ""))
	_expect(weekly_copy.contains("세 가지 길") and weekly_copy.contains("하나를 확정"),
		"first AP tutorial does not teach the current one-commitment week")
	_expect(not weekly_copy.contains("AP가 남아도") and not weekly_copy.contains("행동 포인트(AP)를 써서"),
		"first AP tutorial still teaches the retired multi-spend AP loop")

	story.free()
	await get_tree().process_frame
	await _check_v2_preplan_tutorial_gate()
	for player_value in AudioManager.get("_pool"):
		var player := player_value as AudioStreamPlayer
		if player != null:
			player.stop()
			player.stream = null
	BGMPlayer.stop()
	# BGMPlayer.stop() stops playback but intentionally keeps the cached streams
	# for the running game. This one-shot checker exits immediately, so release
	# those references as well; otherwise the family track from the prologue is
	# still owned while Godot tears down the test process.
	for child in BGMPlayer.get_children():
		if child is AudioStreamPlayer:
			(child as AudioStreamPlayer).stop()
			(child as AudioStreamPlayer).stream = null
	for _frame in range(4):
		await get_tree().process_frame
	if _failures.is_empty():
		print("STORY_TUTORIAL_PLACEMENT_CHECK_OK direct_action=1 rail=0 result_visible=1 popup=0 follow_up=1 ap_tutorial=1 v2_guided_board=1 legacy_preplan=1")
		call_deferred("_quit", 0)
		return
	for failure in _failures:
		push_error("STORY_TUTORIAL_PLACEMENT_CHECK_FAIL: %s" % failure)
	call_deferred("_quit", 1)

func _quit(exit_code: int) -> void:
	await get_tree().process_frame
	get_tree().quit(exit_code)

func _advance_until_direct_action(story: Control) -> void:
	# The authored 1.2-second silence remains part of the scene, but it now yields
	# to visible action copy instead of manufacturing a one-option choice rail.
	for _step in range(48):
		if int(story.call("_direct_continue_choice_index")) >= 0 \
				and not bool(story.get("_typing")) \
				and not bool(story.get("_direction_hold_active")) \
				and not bool(story.get("_transitioning")) \
				and int(story.get("_para_index")) == (story.get("_paragraphs") as Array).size() - 1:
			return
		if bool(story.get("_transitioning")):
			await get_tree().create_timer(0.1).timeout
			continue
		if bool(story.get("_direction_hold_active")):
			story.call("_process", 2.1)
		elif bool(story.get("_typing")):
			story.call("_complete_typing")
		elif bool(story.get("_direction_beat_waiting")):
			story.call("_finish_direction_beat")
		else:
			story.call("_on_advance")
		await get_tree().process_frame

func _advance_until_event(story: Control, event_id: String) -> void:
	for _step in range(48):
		if str(story.get("_current").get("id", "")) == event_id:
			return
		if bool(story.get("_transitioning")):
			await get_tree().create_timer(0.1).timeout
			continue
		if bool(story.get("_typing")):
			story.call("_complete_typing")
		elif not bool(story.get("_showing_choices")):
			story.call("_on_advance")
		await get_tree().process_frame

func _tree_contains_text(root: Node, needle: String) -> bool:
	for node in root.find_children("*", "Label", true, false):
		if str(node.get("text")).contains(needle):
			return true
	for node in root.find_children("*", "RichTextLabel", true, false):
		if str(node.get("text")).contains(needle):
			return true
	return false

func _check_v2_preplan_tutorial_gate() -> void:
	var main_source := FileAccess.get_file_as_string(
		"res://scenes/MainGame.gd")
	var typed_handoff_index := main_source.find(
		"if DEMO_CORE_LOOP_V2.fresh_w1_onboarding_phase() == \"action_completed\":")
	var preplan_index := main_source.find(
		"if _core_loop_v2_route_preplan_opening_if_pending():",
		typed_handoff_index)
	var chapter_index := main_source.find(
		"if _route_opening_chapter_if_pending():", preplan_index)
	var cycle_index := main_source.find(
		"if DEMO_CORE_LOOP_V2.seoul_cycle_available(month_index):",
		chapter_index)
	var planner_index := main_source.find(
		"if DEMO_CORE_LOOP_V2.needs_plan(month_index):", cycle_index)
	_expect(typed_handoff_index >= 0 \
			and preplan_index > typed_handoff_index \
			and chapter_index > preplan_index \
			and cycle_index > chapter_index \
			and planner_index > cycle_index,
		"V2 route no longer orders typed interview, legacy recovery, Chapter 1, cycle, and planner")
	# Fresh Seoul Cycle runs enter the cycle board directly, while compatible
	# legacy V2 plans still enter the planner. The single tutorial gate therefore
	# has exactly two callers (plus its definition), one on each planning surface.
	_expect(main_source.count(
		"_maybe_show_core_loop_v2_tutorial(") == 3 \
			and main_source.contains(
				"if not read_only:\n\t\t_maybe_show_core_loop_v2_tutorial(month_index)") \
			and main_source.contains(
				"if not read_only:\n\t\t_maybe_show_core_loop_v2_tutorial(\n\t\t\tDEMO_CORE_LOOP_V2.month_for_turn(GameState.turn))"),
		"V2 tutorial is not owned solely by the planner and Seoul Cycle board openers")

	var seen_before: Dictionary = TutorialOverlay._seen.duplicate(true)
	TutorialOverlay._seen.erase("core_loop_v2")
	GameState.start_new_game()
	_expect(CORE_LOOP.initialize_for_run(true),
		"fresh tutorial fixture could not initialize")
	GameState.turn = 1
	_expect(CORE_LOOP.begin_fresh_w1_onboarding(),
		"fresh tutorial fixture could not create its W1 owner")
	GameState.flags["prologue_done"] = true
	_expect(CORE_LOOP.fresh_preplan_opening_roots().is_empty() \
			and CORE_LOOP.opening_follow_up_event(
				"story_prologue_meal", "story_pressure", []).is_empty(),
		"fresh prologue did not stop before an empty guided-W1 handoff")
	_expect(not TutorialOverlay._seen.has("core_loop_v2"),
		"V2 tutorial appeared during the fresh prologue")
	var initialized := CORE_LOOP.initialize_seoul_cycle(1)
	_expect(bool(initialized.get("ok", false)) \
			and CORE_LOOP.fresh_w1_onboarding_phase() == "board" \
			and CORE_LOOP.application_status(
				"mirae_industrial_tech").is_empty() \
			and CORE_LOOP.action_receipt(
				CORE_LOOP.W1_ONBOARDING_BUNDLE_ID).is_empty(),
		"fresh prologue fabricated material instead of opening the W1 board")

	var packed := load("res://scenes/MainGame.tscn") as PackedScene
	if packed == null:
		_expect(false, "MainGame fixture could not load for the guided tutorial")
	else:
		var main_game = packed.instantiate()
		main_game.set_meta("_screenshot_qa_static_surface", true)
		main_game.set_meta("_qa_suppress_opening_chapter_transition", true)
		main_game.set_meta("_qa_core_loop_v2_autosave_result", true)
		add_child(main_game)
		await get_tree().process_frame
		await get_tree().process_frame
		var board = main_game.get("_seoul_cycle_board")
		if not is_instance_valid(board) or not bool(board.visible):
			main_game.call("_core_loop_v2_open_seoul_cycle_board", false)
			await get_tree().process_frame
			board = main_game.get("_seoul_cycle_board")
		var board_visible := is_instance_valid(board) and bool(board.visible)
		var tutorial_seen := TutorialOverlay._seen.has("core_loop_v2")
		var cycle_plan := CORE_LOOP.plan_uses_seoul_cycle(
			CORE_LOOP.plan_for_month(1))
		_expect(board_visible and tutorial_seen and cycle_plan,
			"first V2 tutorial did not appear on the real guided W1 board "
			+ "(board=%s seen=%s cycle_plan=%s tutorial_flag=%s)" % [
				str(board_visible), str(tutorial_seen), str(cycle_plan),
				str(GameState.flags.get("tutorial_shown", null)),
			])
		main_game.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame

	# Separate compatibility fixture: an old save paused on the former Send
	# screen has no fresh marker and retains the exact adjacent roots. Its click
	# may recover the pre-plan consequence, but never a fresh weekly action.
	TutorialOverlay._seen.erase("core_loop_v2")
	GameState.start_new_game()
	_expect(CORE_LOOP.initialize_for_run(true),
		"legacy tutorial fixture could not initialize")
	GameState.turn = 1
	GameState.flags["prologue_done"] = true
	var roots: Array = CORE_LOOP.fresh_preplan_opening_roots()
	var send_event: Dictionary = DataRegistry.find_event(
		CORE_LOOP.OPENING_APPLICATION_EVENT_ID)
	var choices: Array = send_event.get("choices", [])
	var sent := roots == ["arc_intro_01_meal", "v2_opening_return_math"] \
		and CORE_LOOP.fresh_w1_onboarding_snapshot().is_empty() \
		and choices.size() == 1 \
		and CORE_LOOP.story_choice_commit_available(
			CORE_LOOP.OPENING_APPLICATION_EVENT_ID, 0, roots) \
		and GameState.apply_choice(send_event, choices[0] as Dictionary) \
		and CORE_LOOP.note_story_choice(
			CORE_LOOP.OPENING_APPLICATION_EVENT_ID, 0, roots)
	_expect(sent,
		"the exact legacy paused-Send action could not recover its consequence")
	_expect(not TutorialOverlay._seen.has("core_loop_v2"),
		"V2 tutorial appeared during the legacy paused-Send action")
	var receipt: Dictionary = (
		GameState.core_loop_v2_state.get(
			"consequence_receipts", {}) as Dictionary
	).get(CORE_LOOP.OPENING_INTERVIEW_BUNDLE_ID, {})
	_expect(str(receipt.get("status", "")) == "presented" \
			and str(receipt.get("claim_source", "")) == "story_choice" \
			and receipt.get("roots", []) == roots \
			and CORE_LOOP.plan_for_month(1).is_empty() \
			and CORE_LOOP.action_receipt(
				CORE_LOOP.W1_ONBOARDING_BUNDLE_ID).is_empty() \
			and not GameState.has_weekly_commitment_for_turn(1),
		"legacy pre-plan recovery fabricated a fresh weekly action")
	_expect(not TutorialOverlay._seen.has("core_loop_v2"),
		"V2 tutorial interrupted the legacy interview/calculation consequence")
	TutorialOverlay._seen.clear()
	TutorialOverlay._seen.merge(seen_before, true)

func _story_state(story: Control) -> String:
	return "id=%s typing=%s para=%s/%s hold=%s rem=%.2f transitioning=%s" % [
		str(story.get("_current").get("id", "")),
		str(story.get("_typing")),
		str(story.get("_para_index")),
		str(story.get("_paragraphs").size()),
		str(story.get("_direction_hold_active")),
		float(story.get("_direction_hold_remaining")),
		str(story.get("_transitioning")),
	]

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
