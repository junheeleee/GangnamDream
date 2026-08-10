extends Node
## Fresh V2 entry preserves one causal opening and teaches the real monthly
## planning board exactly once: prologue -> application Send -> interview ->
## 125 years -> Chapter 1 -> planner -> tutorial.

const CORE_LOOP := preload("res://systems/DemoCoreLoopV2.gd")
const MAIN_GAME_SCENE := preload("res://scenes/MainGame.tscn")
const CHAPTER_EVENT_ID := "chapter_card_33"
const PRESSURE_EVENT_ID := "story_pressure"
const APPLICATION_EVENT_ID := "v2_opening_application_send"
const INTERVIEW_EVENT_ID := "arc_intro_01_meal"
const MATH_EVENT_ID := "v2_opening_return_math"
const OPENING_BUNDLE_ID := "opening_interview_math"
const OPENING_ROOTS := [INTERVIEW_EVENT_ID, MATH_EVENT_ID]
const TUTORIAL_ID := "core_loop_v2"

var _failures: Array[String] = []
var _underlying_presses := 0
var _original_seen: Dictionary = {}
var _original_language := "ko"
var _original_sfx_enabled := true


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	_original_seen = TutorialOverlay._seen.duplicate(true)
	_original_language = LocaleManager.language
	_original_sfx_enabled = AudioManager.sfx_enabled
	AudioManager.sfx_enabled = false
	TutorialOverlay._seen.erase(TUTORIAL_ID)

	_check_localized_tutorial_copy()
	await _check_opening_contracts()
	await _check_fresh_and_reentry_flow()
	await _stop_test_audio()

	TutorialOverlay._seen.clear()
	TutorialOverlay._seen.merge(_original_seen, true)
	LocaleManager.set_language(_original_language)
	AudioManager.sfx_enabled = _original_sfx_enabled
	if _failures.is_empty():
		print(
			"CORE_LOOP_V2_FIRST_ENTRY_CHECK_OK "
			+ "order=prologue>application_send>interview>125_years>"
			+ "chapter_33>planner>tutorial "
			+ "trigger=v2_application_send receipts=presented/consumed/no_replay "
			+ "expression=2/state_free roots=adjacent "
			+ "slides=3 locale=ko/en fresh=1 reentry=1 focus_restore=1 "
			+ "episode_promises=2 input_leak=0 save_reshow=0 "
			+ "legacy_untouched=1")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("CORE_LOOP_V2_FIRST_ENTRY_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)


func _check_localized_tutorial_copy() -> void:
	LocaleManager.set_language("ko")
	var ko_slides: Array = TutorialOverlay._get_slides(TUTORIAL_ID)
	var ko_text := _slide_text(ko_slides)
	_expect(ko_slides.size() == 3,
		"Korean V2 onboarding does not contain exactly three slides")
	for required in [
		"첫 달", "네 가지 약속", "두 가지", "중심 약속", "자동으로 편성",
		"예기치 않은", "장면", "이달 시작",
	]:
		_expect(required in ko_text,
			"Korean V2 onboarding lost required concept: %s" % required)
	for retired in ["제안을 네 주에 놓기", "주로 할 일", "보조로 할 일", "최종 확인"]:
		_expect(retired not in ko_text,
			"Korean V2 onboarding still teaches retired Month-One work: %s" % retired)

	LocaleManager.set_language("en")
	var en_slides: Array = TutorialOverlay._get_slides(TUTORIAL_ID)
	var en_text := _slide_text(en_slides)
	_expect(en_slides.size() == 3,
		"English V2 onboarding does not contain exactly three slides")
	for required in [
		"first month", "four promises", "two", "central promise",
		"scheduled automatically", "unexpected", "scene", "Start Month",
	]:
		_expect(required.to_lower() in en_text.to_lower(),
			"English V2 onboarding lost required concept: %s" % required)
	for retired in ["Place Offers Across Four Weeks", "Primary routines", "final review"]:
		_expect(retired.to_lower() not in en_text.to_lower(),
			"English V2 onboarding still teaches retired Month-One work: %s" % retired)
	_expect(not _contains_hangul(en_text),
		"English V2 onboarding contains Hangul: %s" % en_text)


func _check_opening_contracts() -> void:
	await _check_fresh_opening_queue()
	_check_truthful_opening_trigger_and_expression()
	await _check_saved_preplan_recovery()
	await _check_legacy_preplan_untouched()


func _check_fresh_opening_queue() -> void:
	LocaleManager.set_language("ko")
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	var main_game = MAIN_GAME_SCENE.instantiate()
	main_game.set_meta("_screenshot_qa_static_surface", true)
	main_game.set_meta("_qa_suppress_opening_chapter_transition", true)
	add_child(main_game)
	await get_tree().process_frame
	await get_tree().process_frame

	main_game._begin_month_story_and_render()
	var expected_queue := [
		"story_flashforward", INTERVIEW_EVENT_ID, MATH_EVENT_ID,
		CHAPTER_EVENT_ID,
	]
	_expect(GameState.pending_story_queue == expected_queue,
		"fresh V2 entry did not reserve only prologue -> interview -> "
		+ "calculation -> Chapter 1 in one adjacent StoryMode queue")
	_expect(CORE_LOOP.opening_follow_up_event(
			"story_prologue_meal", PRESSURE_EVENT_ID, expected_queue) \
			== APPLICATION_EVENT_ID,
		"fresh V2 did not replace the prologue's legacy app-open follow-up "
		+ "with the actual application Send scene")
	_expect(bool(GameState.flags.get("prologue_done", false)) \
			and CORE_LOOP.active_bundle_id().is_empty() \
			and not (
				GameState.core_loop_v2_state.get(
					"consequence_receipts", {}) as Dictionary
			).has(OPENING_BUNDLE_ID),
		"fresh queue reservation fabricated the application or consequence "
		+ "before the player pressed Send")
	_cancel_scene_transition()
	_dispose(main_game)
	GameState.pending_story_queue.clear()
	await get_tree().process_frame
	await get_tree().process_frame


func _check_truthful_opening_trigger_and_expression() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	GameState.flags["prologue_done"] = true
	var roots := CORE_LOOP.fresh_preplan_opening_roots()
	_expect(roots == OPENING_ROOTS,
		"fresh opening roots are not the adjacent interview and calculation")
	var before_send: Dictionary = GameState.serialize().duplicate(true)
	_expect(not CORE_LOOP.claim_preplan_opening_from_trigger(
			APPLICATION_EVENT_ID, 0) \
			and CORE_LOOP.active_bundle_id().is_empty() \
			and GameState.serialize() == before_send,
		"pre-plan opening claimed ownership before the V2 application scene "
		+ "actually sent the application")

	var application_event: Dictionary = DataRegistry.find_event(
		APPLICATION_EVENT_ID)
	var application_choices: Array = application_event.get("choices", [])
	_expect(application_choices.size() == 1,
		"V2 application scene lost its single Send action")
	if application_choices.size() != 1:
		return
	_expect(GameState.apply_choice(
			application_event, application_choices[0] as Dictionary) \
			and bool(GameState.flags.get("story_job_unlocked", false)) \
			and bool(GameState.flags.get(
				"opening_interview_application_sent", false)) \
			and bool(GameState.flags.get(
				"opening_preplan_application_sent", false)),
		"V2 Send did not create its truthful application flags")
	_expect(CORE_LOOP.note_story_choice(APPLICATION_EVENT_ID, 0) \
			and CORE_LOOP.active_bundle_id() == OPENING_BUNDLE_ID \
			and CORE_LOOP.active_kind() == "consequence" \
			and CORE_LOOP.application_status(
				"mirae_industrial_tech") == "submitted",
		"the real V2 Send did not claim the opening consequence")
	var presented_receipt: Dictionary = (
		GameState.core_loop_v2_state.get(
			"consequence_receipts", {}) as Dictionary
	).get(OPENING_BUNDLE_ID, {})
	_expect(str(presented_receipt.get("status", "")) == "presented" \
			and str(presented_receipt.get("surface_kind", "")) \
				== "preplan_continuous" \
			and presented_receipt.get("roots", []) == OPENING_ROOTS \
			and (
				GameState.core_loop_v2_state.get(
					"shown_consequences", []) as Array
			).count(OPENING_BUNDLE_ID) == 1,
		"pre-plan opening did not persist one presented receipt with both roots")

	CORE_LOOP.prepare_story_bundle(OPENING_BUNDLE_ID)
	var interview_event: Dictionary = DataRegistry.find_event(
		INTERVIEW_EVENT_ID)
	var interview_choices: Array = interview_event.get("choices", [])
	_expect(interview_choices.size() == 2,
		"opening interview lost its two authored answers")
	if interview_choices.size() != 2:
		return
	_expect(GameState.apply_choice(
			interview_event, interview_choices[0] as Dictionary) \
			and CORE_LOOP.note_story_choice(INTERVIEW_EVENT_ID, 0) \
			and CORE_LOOP.application_status(
				"mirae_industrial_tech") == "interviewed",
		"opening interview did not advance the submitted application")

	var math_event: Dictionary = DataRegistry.find_event(MATH_EVENT_ID)
	var math_choices: Array = math_event.get("choices", [])
	_expect(math_choices.size() == 2,
		"125-year calculation does not have exactly two responses")
	if math_choices.size() != 2:
		return
	for choice_index in range(math_choices.size()):
		var math_choice: Dictionary = math_choices[choice_index]
		var serialized_before: Dictionary = GameState.serialize().duplicate(true)
		var story_receipts_before: Dictionary = (
			GameState.core_loop_v2_state as Dictionary).duplicate(true)
		var mindset_flags_before := {
			"saver": bool(GameState.flags.get("mindset_saver", false)),
			"investor": bool(GameState.flags.get("mindset_investor", false)),
			"founder": bool(GameState.flags.get("mindset_founder", false)),
		}
		var tendency_before := GameState.tendency.duplicate(true)
		_expect(GameState.is_expression_choice(math_choice) \
				and GameState.apply_choice(math_event, math_choice) \
				and CORE_LOOP.note_story_choice(MATH_EVENT_ID, choice_index),
			"125-year response %d was not a valid expression choice" \
				% choice_index)
		_expect(GameState.serialize() == serialized_before \
				and GameState.core_loop_v2_state == story_receipts_before \
				and GameState.tendency == tendency_before \
				and bool(GameState.flags.get("mindset_saver", false)) \
					== bool(mindset_flags_before["saver"]) \
				and bool(GameState.flags.get("mindset_investor", false)) \
					== bool(mindset_flags_before["investor"]) \
				and bool(GameState.flags.get("mindset_founder", false)) \
					== bool(mindset_flags_before["founder"]),
			(
				"125-year expression %d changed serialized state, story receipts, "
				+ "mindset flags, or tendencies"
			) % choice_index)

	CORE_LOOP.restore_story_bundle_followups()
	_expect(CORE_LOOP.complete_active_bundle() == OPENING_BUNDLE_ID,
		"pre-plan opening consequence could not consume its presented owner")
	var consumed_receipt: Dictionary = (
		GameState.core_loop_v2_state.get(
			"consequence_receipts", {}) as Dictionary
	).get(OPENING_BUNDLE_ID, {})
	_expect(str(consumed_receipt.get("status", "")) == "consumed" \
			and consumed_receipt.get("roots", []) == OPENING_ROOTS \
			and CORE_LOOP.active_bundle_id().is_empty() \
			and not CORE_LOOP.needs_preplan_opening() \
			and not CORE_LOOP.claim_saved_preplan_opening(),
		"consumed opening receipt replayed or lost its two-root history")
	var consumed_save: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(consumed_save)
	CORE_LOOP.initialize_for_run()
	var reloaded_receipt: Dictionary = (
		GameState.core_loop_v2_state.get(
			"consequence_receipts", {}) as Dictionary
	).get(OPENING_BUNDLE_ID, {})
	_expect(str(reloaded_receipt.get("status", "")) == "consumed" \
			and reloaded_receipt.get("roots", []) == OPENING_ROOTS \
			and not CORE_LOOP.needs_preplan_opening() \
			and not CORE_LOOP.claim_saved_preplan_opening(),
		"save/load resurrected an already consumed opening")


func _check_saved_preplan_recovery() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	GameState.flags["prologue_done"] = true
	var application_event: Dictionary = DataRegistry.find_event(
		APPLICATION_EVENT_ID)
	var application_choices: Array = application_event.get("choices", [])
	if application_choices.size() != 1:
		_expect(false, "saved opening fixture could not find the V2 Send")
		return
	GameState.apply_choice(
		application_event, application_choices[0] as Dictionary)
	var post_prologue_save: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(post_prologue_save)
	CORE_LOOP.initialize_for_run()

	var main_game = MAIN_GAME_SCENE.instantiate()
	main_game.set_meta("_screenshot_qa_static_surface", true)
	main_game.set_meta("_qa_suppress_opening_chapter_transition", true)
	add_child(main_game)
	await get_tree().process_frame
	await get_tree().process_frame
	main_game._begin_month_story_and_render()
	var receipt: Dictionary = (
		GameState.core_loop_v2_state.get(
			"consequence_receipts", {}) as Dictionary
	).get(OPENING_BUNDLE_ID, {})
	_expect(GameState.pending_story_queue == OPENING_ROOTS \
			and CORE_LOOP.active_bundle_id() == OPENING_BUNDLE_ID \
			and str(receipt.get("status", "")) == "presented" \
			and str(receipt.get("claim_source", "")) \
				== "saved_preplan_recovery" \
			and str(main_game.get_meta(
				"_qa_opening_chapter_event", "")).is_empty() \
			and not _planner_is_visible(main_game) \
			and _find_tutorial(main_game) == null,
		"post-prologue save routed Chapter 1, planner, or tutorial before the "
		+ "interview and 125-year calculation")
	_cancel_scene_transition()
	_dispose(main_game)
	GameState.pending_story_queue.clear()
	await get_tree().process_frame
	await get_tree().process_frame


func _check_legacy_preplan_untouched() -> void:
	# An older V2 save could have opened the job app and stopped with a finger
	# above Apply. Loading it must not fabricate the later Send, same-day
	# interview, calculation, or returned-call history.
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	GameState.flags["prologue_done"] = true
	GameState.flags["story_job_unlocked"] = true
	var legacy_save: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(legacy_save)
	CORE_LOOP.initialize_for_run()
	var before_route: Dictionary = GameState.serialize().duplicate(true)
	_expect(not CORE_LOOP.needs_preplan_opening() \
			and not CORE_LOOP.claim_saved_preplan_opening() \
			and not bool(GameState.flags.get(
				"opening_preplan_application_sent", false)) \
			and GameState.serialize() == before_route,
		"legacy app-open-only save was rewritten as a submitted application")
	_expect(CORE_LOOP.opening_follow_up_event(
			"story_prologue_meal", PRESSURE_EVENT_ID, OPENING_ROOTS) \
			== PRESSURE_EVENT_ID,
		"legacy app-open history was replaced by the new Send scene")
	_expect(CORE_LOOP.application_status(
			"mirae_industrial_tech").is_empty() \
			and CORE_LOOP.available_offer_ids(1).has(
				"m1_mirae_application"),
		"legacy app-open-only save lost its still-unsubmitted Month-One offer")

	var main_game = MAIN_GAME_SCENE.instantiate()
	main_game.set_meta("_screenshot_qa_static_surface", true)
	main_game.set_meta("_qa_suppress_opening_chapter_transition", true)
	add_child(main_game)
	await get_tree().process_frame
	await get_tree().process_frame
	main_game._begin_month_story_and_render()
	var receipts_before_chapter: Dictionary = (
		GameState.core_loop_v2_state.get(
			"consequence_receipts", {}) as Dictionary
	)
	_expect(GameState.pending_story_queue == [CHAPTER_EVENT_ID] \
			and not receipts_before_chapter.has(OPENING_BUNDLE_ID) \
			and str(main_game.get_meta(
				"_qa_opening_chapter_event", "")) == CHAPTER_EVENT_ID,
		"legacy app-open-only save did not route straight to Chapter 1")

	var chapter_event: Dictionary = DataRegistry.find_event(CHAPTER_EVENT_ID)
	var chapter_choices: Array = chapter_event.get("choices", [])
	if chapter_choices.size() != 1:
		_expect(false, "legacy pre-plan fixture could not finish Chapter 1")
		_dispose(main_game)
		return
	GameState.apply_choice(chapter_event, chapter_choices[0] as Dictionary)
	GameState.pending_story_queue.clear()
	main_game._continue_after_story()
	for _frame in range(6):
		await get_tree().process_frame
	_expect(_planner_is_visible(main_game) \
			and CORE_LOOP.available_offer_ids(1).has(
				"m1_mirae_application") \
			and not (
				GameState.core_loop_v2_state.get(
					"consequence_receipts", {}) as Dictionary
			).has(OPENING_BUNDLE_ID),
		"legacy app-open-only save did not keep its Month-One planner and "
		+ "unsubmitted application after Chapter 1")
	_dispose(main_game)
	GameState.pending_story_queue.clear()
	await get_tree().process_frame
	await get_tree().process_frame


func _complete_preplan_opening_fixture() -> bool:
	GameState.flags["prologue_done"] = true
	var application_event: Dictionary = DataRegistry.find_event(
		APPLICATION_EVENT_ID)
	var application_choices: Array = application_event.get("choices", [])
	var interview_event: Dictionary = DataRegistry.find_event(
		INTERVIEW_EVENT_ID)
	var interview_choices: Array = interview_event.get("choices", [])
	var math_event: Dictionary = DataRegistry.find_event(MATH_EVENT_ID)
	var math_choices: Array = math_event.get("choices", [])
	if application_choices.size() != 1 or interview_choices.is_empty() \
			or math_choices.is_empty():
		return false
	if not GameState.apply_choice(
			application_event, application_choices[0] as Dictionary) \
			or not CORE_LOOP.note_story_choice(APPLICATION_EVENT_ID, 0):
		return false
	CORE_LOOP.prepare_story_bundle(OPENING_BUNDLE_ID)
	if not GameState.apply_choice(
			interview_event, interview_choices[0] as Dictionary) \
			or not CORE_LOOP.note_story_choice(INTERVIEW_EVENT_ID, 0):
		return false
	if not GameState.apply_choice(math_event, math_choices[0] as Dictionary) \
			or not CORE_LOOP.note_story_choice(MATH_EVENT_ID, 0):
		return false
	CORE_LOOP.restore_story_bundle_followups()
	return CORE_LOOP.complete_active_bundle() == OPENING_BUNDLE_ID


func _check_fresh_and_reentry_flow() -> void:
	LocaleManager.set_language("ko")
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	_expect(_complete_preplan_opening_fixture(),
		"first-entry UI fixture could not finish the interview and calculation")
	var main_game = MAIN_GAME_SCENE.instantiate()
	main_game.set_meta("_screenshot_qa_static_surface", true)
	main_game.set_meta("_qa_suppress_opening_chapter_transition", true)
	add_child(main_game)
	await get_tree().process_frame
	await get_tree().process_frame

	# The normal StoryMode return path must stop at the chapter card. It may not
	# open the planner or onboarding under that protected boundary.
	main_game._continue_after_story()
	await get_tree().process_frame
	_expect(str(main_game.get_meta("_qa_opening_chapter_event", "")) \
			== CHAPTER_EVENT_ID,
		"fresh V2 StoryMode return skipped the Chapter 1 card")
	_expect(GameState.pending_story_queue == [CHAPTER_EVENT_ID],
		"fresh V2 return did not queue exactly the Chapter 1 card")
	_expect(not _planner_is_visible(main_game) \
			and _find_tutorial(main_game) == null,
		"planner or tutorial crossed the fresh Chapter 1 boundary")

	# A save made after the prologue but before the card must make the same
	# decision when MainGame is reconstructed.
	GameState.pending_story_queue.clear()
	var pre_chapter_save: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(pre_chapter_save)
	CORE_LOOP.initialize_for_run()
	main_game.remove_meta("_qa_opening_chapter_event")
	main_game._begin_month_story_and_render()
	await get_tree().process_frame
	_expect(str(main_game.get_meta("_qa_opening_chapter_event", "")) \
			== CHAPTER_EVENT_ID,
		"saved V2 MainGame re-entry skipped the Chapter 1 card")
	_expect(GameState.pending_story_queue == [CHAPTER_EVENT_ID],
		"saved V2 re-entry did not queue exactly the Chapter 1 card")
	_expect(not _planner_is_visible(main_game) \
			and _find_tutorial(main_game) == null,
		"planner or tutorial crossed the re-entry Chapter 1 boundary")

	var chapter_event: Dictionary = DataRegistry.find_event(CHAPTER_EVENT_ID)
	var chapter_choices: Array = chapter_event.get("choices", [])
	_expect(not chapter_event.is_empty() and chapter_choices.size() == 1,
		"Chapter 1 event or its single authored action is missing")
	if chapter_event.is_empty() or chapter_choices.size() != 1:
		_dispose(main_game)
		return
	GameState.apply_choice(chapter_event, chapter_choices[0] as Dictionary)
	GameState.pending_story_queue.clear()
	_expect(bool(GameState.flags.get("chapter_33_seen", false)),
		"Chapter 1 action did not set its canonical seen flag")

	# Once the chapter action is complete, the same return path opens the wide
	# monthly planner and layers the V2-specific tutorial over that real surface.
	main_game._continue_after_story()
	for _frame in range(6):
		await get_tree().process_frame
	var planner = main_game.get("_core_loop_planner")
	var tutorial := _find_tutorial(main_game)
	_expect(is_instance_valid(planner) and planner.visible,
		"first-month planning board did not open after Chapter 1")
	_expect(tutorial != null and int(tutorial.get("_slides").size()) == 3,
		"V2 onboarding did not open as a three-slide overlay over the planner")
	_expect(not bool(GameState.flags.get("tutorial_shown", false)),
		"V2 onboarding persisted its one-time flag before actual completion")
	if not is_instance_valid(planner) or tutorial == null:
		_dispose(main_game)
		return

	var focus_owner := get_viewport().gui_get_focus_owner()
	_expect(focus_owner != null and tutorial.is_ancestor_of(focus_owner),
		"V2 onboarding did not trap focus above the planner")
	var restore_target := tutorial.get("_previous_focus") as Control
	_expect(is_instance_valid(restore_target) and planner.is_ancestor_of(restore_target),
		"V2 onboarding did not remember a planner control for focus restoration")

	_underlying_presses = 0
	var offer_buttons: Dictionary = planner.get("_offer_buttons")
	var expected_episode_offers := [
		"m1_convenience_trial_shift",
		"m1_youth_center_resume_clinic",
		"father_first_call",
		"m1_phone_off_sunday",
	]
	_expect(bool(CORE_LOOP.episode_selection_enabled(1)) \
			and offer_buttons.size() == expected_episode_offers.size(),
		"fresh Month-One planner did not open the four-promise episode surface")
	for offer_id in expected_episode_offers:
		_expect(offer_buttons.has(offer_id),
			"fresh Month-One episode surface lost promise %s" % offer_id)
	for hidden_id in [
		"m1_mirae_application", "hyunsu_first_meet", "first_temptation_boss",
	]:
		_expect(not offer_buttons.has(hidden_id),
			"fresh Month-One episode surface leaked hidden item %s" % hidden_id)
	for raw_button in offer_buttons.values():
		var offer_button := raw_button as Button
		if is_instance_valid(offer_button):
			offer_button.pressed.connect(_on_underlying_planner_pressed)
	var schedule_before: Dictionary = planner.schedule_snapshot()
	var routines_before: Dictionary = planner.routine_snapshot()
	var navigation_before := {
		"active_surface": int(planner.get("_active_tab")),
		"workflow_step": int(planner.get("_workflow_step")),
	}
	_send_phone_shortcut_key()
	await get_tree().process_frame
	await get_tree().process_frame
	var phone = main_game.get("_communication_phone")
	_expect(not is_instance_valid(phone) or not phone.visible,
		"P opened a hidden communication phone behind the V2 tutorial")
	_send_phone_shortcut_north()
	await get_tree().process_frame
	await get_tree().process_frame
	phone = main_game.get("_communication_phone")
	var tutorial_focus := get_viewport().gui_get_focus_owner()
	_expect((not is_instance_valid(phone) or not phone.visible) \
			and tutorial_focus != null \
			and tutorial.is_ancestor_of(tutorial_focus),
		"North opened the phone or stole focus while the V2 tutorial was active")

	_send_tab_key(KEY_E)
	await _expect_tutorial_owns_planner_navigation(
		planner, tutorial, navigation_before, "E")
	_send_tab_key(KEY_Q)
	await _expect_tutorial_owns_planner_navigation(
		planner, tutorial, navigation_before, "Q")
	_send_tab_shoulder(JOY_BUTTON_RIGHT_SHOULDER)
	await _expect_tutorial_owns_planner_navigation(
		planner, tutorial, navigation_before, "right shoulder")
	_send_tab_shoulder(JOY_BUTTON_LEFT_SHOULDER)
	await _expect_tutorial_owns_planner_navigation(
		planner, tutorial, navigation_before, "left shoulder")

	_send_keyboard_accept()
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(int(tutorial.get("_slide_idx")) == 1,
		"one physical Enter did not advance exactly one V2 tutorial slide")
	_expect(_underlying_presses == 0,
		"first tutorial accept leaked into the planning board")

	_send_action_accept()
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(int(tutorial.get("_slide_idx")) == 2,
		"one semantic confirm did not advance exactly one V2 tutorial slide")
	_expect(_underlying_presses == 0,
		"second tutorial accept leaked into the planning board")

	_send_keyboard_accept()
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(_find_tutorial(main_game) == null,
		"V2 tutorial did not dismiss after its third slide")
	_expect(bool(GameState.flags.get("tutorial_shown", false)),
		"completed V2 onboarding did not persist its one-time run flag")
	_expect(_underlying_presses == 0 \
			and planner.schedule_snapshot() == schedule_before \
			and planner.routine_snapshot() == routines_before \
			and int(planner.get("_active_tab")) \
				== int(navigation_before["active_surface"]) \
			and int(planner.get("_workflow_step")) \
				== int(navigation_before["workflow_step"]),
		"tutorial input changed the monthly plan or its underlying navigation")
	var restored_focus := get_viewport().gui_get_focus_owner()
	_expect(restored_focus != null and planner.is_ancestor_of(restored_focus),
		"closing V2 onboarding did not restore focus to the planner")

	GameState.add_log("V2 first-entry QA", "system")
	var post_tutorial_save: Dictionary = GameState.serialize().duplicate(true)
	var saved_flags: Dictionary = post_tutorial_save.get("flags", {})
	_expect(bool(saved_flags.get("tutorial_shown", false)),
		"serialized V2 state lost the tutorial one-time flag")
	_dispose(main_game)
	await get_tree().process_frame
	await get_tree().process_frame

	# Clear the session guard deliberately: a second overlay now can only be
	# prevented by the serialized run flag, which proves save/load durability.
	TutorialOverlay._seen.erase(TUTORIAL_ID)
	GameState.start_new_game()
	GameState.load_from_dict(post_tutorial_save)
	CORE_LOOP.initialize_for_run()
	var reloaded_main = MAIN_GAME_SCENE.instantiate()
	reloaded_main.set_meta("_screenshot_qa_static_surface", true)
	add_child(reloaded_main)
	await get_tree().process_frame
	await get_tree().process_frame
	reloaded_main._core_loop_v2_open_planner(1)
	for _frame in range(4):
		await get_tree().process_frame
	_expect(_planner_is_visible(reloaded_main),
		"saved first-month planner could not reopen")
	_expect(_find_tutorial(reloaded_main) == null \
			and not TutorialOverlay._seen.has(TUTORIAL_ID),
		"saved V2 onboarding appeared a second time after reload")
	_dispose(reloaded_main)
	await get_tree().process_frame
	await get_tree().process_frame


func _planner_is_visible(main_game: Node) -> bool:
	var planner = main_game.get("_core_loop_planner")
	return is_instance_valid(planner) and bool(planner.visible)


func _find_tutorial(parent: Node) -> TutorialOverlay:
	for child in parent.get_children():
		if child is TutorialOverlay and not child.is_queued_for_deletion():
			return child as TutorialOverlay
	return null


func _slide_text(slides: Array) -> String:
	var parts: Array[String] = []
	for raw_slide in slides:
		if not raw_slide is Dictionary:
			continue
		var slide: Dictionary = raw_slide
		parts.append(str(slide.get("title", "")))
		parts.append(str(slide.get("body", "")))
	return "\n".join(parts)


func _contains_hangul(text: String) -> bool:
	for index in range(text.length()):
		var codepoint := text.unicode_at(index)
		if (codepoint >= 0xAC00 and codepoint <= 0xD7A3) \
				or (codepoint >= 0x1100 and codepoint <= 0x11FF) \
				or (codepoint >= 0x3130 and codepoint <= 0x318F):
			return true
	return false


func _send_keyboard_accept() -> void:
	var press := InputEventKey.new()
	press.keycode = KEY_ENTER
	press.physical_keycode = KEY_ENTER
	press.pressed = true
	Input.parse_input_event(press)
	var release := press.duplicate() as InputEventKey
	release.pressed = false
	Input.parse_input_event(release)


func _send_action_accept() -> void:
	var press := InputEventAction.new()
	press.action = "ui_accept"
	press.pressed = true
	Input.parse_input_event(press)
	var release := press.duplicate() as InputEventAction
	release.pressed = false
	Input.parse_input_event(release)


func _send_phone_shortcut_key() -> void:
	var press := InputEventKey.new()
	press.keycode = KEY_P
	press.physical_keycode = KEY_P
	press.pressed = true
	Input.parse_input_event(press)
	var release := press.duplicate() as InputEventKey
	release.pressed = false
	Input.parse_input_event(release)


func _send_phone_shortcut_north() -> void:
	var press := InputEventJoypadButton.new()
	press.button_index = JOY_BUTTON_Y
	press.pressed = true
	Input.parse_input_event(press)
	var release := press.duplicate() as InputEventJoypadButton
	release.pressed = false
	Input.parse_input_event(release)


func _send_tab_key(keycode: Key) -> void:
	var press := InputEventKey.new()
	press.keycode = keycode
	press.physical_keycode = keycode
	press.pressed = true
	Input.parse_input_event(press)
	var release := press.duplicate() as InputEventKey
	release.pressed = false
	Input.parse_input_event(release)


func _send_tab_shoulder(button_index: JoyButton) -> void:
	var press := InputEventJoypadButton.new()
	press.button_index = button_index
	press.pressed = true
	Input.parse_input_event(press)
	var release := press.duplicate() as InputEventJoypadButton
	release.pressed = false
	Input.parse_input_event(release)


func _expect_tutorial_owns_planner_navigation(
		planner: Control, tutorial: TutorialOverlay,
		expected_navigation: Dictionary, input_name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var tutorial_focus := get_viewport().gui_get_focus_owner()
	_expect(int(planner.get("_active_tab")) \
			== int(expected_navigation.get("active_surface", -1)) \
			and int(planner.get("_workflow_step")) \
				== int(expected_navigation.get("workflow_step", -1)) \
			and tutorial_focus != null \
			and tutorial.is_ancestor_of(tutorial_focus),
		"%s switched the planner or stole focus behind V2 onboarding" \
				% input_name)


func _on_underlying_planner_pressed() -> void:
	_underlying_presses += 1


func _cancel_scene_transition() -> void:
	var active_tween := SceneTransition.get("_tween") as Tween
	if is_instance_valid(active_tween):
		active_tween.kill()
	SceneTransition.set("_tween", null)
	SceneTransition._set_transition_alpha(0.0)
	var overlay := SceneTransition.get("_overlay") as Control
	if is_instance_valid(overlay):
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE


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
	await get_tree().process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
