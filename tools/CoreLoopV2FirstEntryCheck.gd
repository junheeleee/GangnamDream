extends Node
## Fresh V2 entry teaches the real Seoul Cycle board, then lets the player's
## W1 resume/application action own Send before interview -> 125 years ->
## Chapter 1. Migrated pre-plan saves retain their original recovery identity.

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
			+ "order=prologue>w1_resume>send>interview>"
			+ "125_years>chapter_33>remaining_board "
			+ "trigger=typed_job_hunt_application "
			+ "fresh_story_material=zero roots=adjacent "
			+ "receipts=presented/consumed/double_reload "
			+ "expression=2/state_free interview=2/typed_identity "
			+ "legacy_before_send=state_free/exact_origin/no_weekly "
			+ "slides=3 locale=ko/en fresh=1 reentry=1 focus_restore=1 "
			+ "cycle=capacity4/nodes4/w1_consumed "
			+ "real_input=keyboard_full+pad_cancel/board>job_hunt4>review>send "
			+ "cancel=exact_state receipts=weekly1/allocation1/action1/application1 "
			+ "story_writes=0 duplicate_send=0 input_leak=0 save_reshow=0 "
			+ "save_editable=1 root_east_guard=1 turn_skip_guard=1 "
			+ "surface_action_guard=tutorial+board "
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
		"주간 여력 네 개", "숫자가 높을수록", "다시 굴리거나",
		"사람·직업·생계·회복", "진전과 대가", "세계의 시간",
		"실제 수행 장면", "대화의 성공", "취소 버튼",
	]:
		_expect(required in ko_text,
			"Korean V2 onboarding lost required concept: %s" % required)
	for retired in [
		"네 가지 약속", "중심 약속", "이달 시작", "제안을 네 주에 놓기",
		"주로 할 일", "보조로 할 일", "최종 확인",
	]:
		_expect(retired not in ko_text,
			"Korean V2 onboarding still teaches retired Month-One work: %s" % retired)

	LocaleManager.set_language("en")
	var en_slides: Array = TutorialOverlay._get_slides(TUTORIAL_ID)
	var en_text := _slide_text(en_slides)
	_expect(en_slides.size() == 3,
		"English V2 onboarding does not contain exactly three slides")
	for required in [
		"four weekly capacity pieces", "higher number", "cannot be rerolled",
		"person, career", "livelihood, or recovery", "exact progress and cost",
		"city's time", "actual performance scene", "relationship succeeds",
		"cancel before commitment",
	]:
		_expect(required.to_lower() in en_text.to_lower(),
			"English V2 onboarding lost required concept: %s" % required)
	for retired in [
		"four promises", "central promise", "Start Month",
		"Place Offers Across Four Weeks", "Primary routines", "final review",
	]:
		_expect(retired.to_lower() not in en_text.to_lower(),
			"English V2 onboarding still teaches retired Month-One work: %s" % retired)
	_expect(not _contains_hangul(en_text),
		"English V2 onboarding contains Hangul: %s" % en_text)


func _check_opening_contracts() -> void:
	await _check_fresh_opening_queue()
	_check_truthful_opening_story_surface()
	_check_legacy_before_send_compatibility()
	_check_fresh_typed_interview_math_receipts()
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
	var expected_queue := ["story_flashforward"]
	_expect(GameState.pending_story_queue == expected_queue,
		"fresh V2 entry queued interview/math/chapter before the W1 action")
	_expect(CORE_LOOP.opening_follow_up_event(
			"story_prologue_meal", PRESSURE_EVENT_ID, expected_queue) \
			== "",
		"fresh V2 did not end the prologue before the guided W1 board")
	_expect(bool(GameState.flags.get("prologue_done", false)) \
			and CORE_LOOP.fresh_w1_onboarding_phase() == "prologue" \
			and CORE_LOOP.active_bundle_id().is_empty() \
			and CORE_LOOP.application_status(
				"mirae_industrial_tech").is_empty() \
			and CORE_LOOP.action_receipt(
				"m1_youth_center_resume_clinic").is_empty() \
			and not (
				GameState.core_loop_v2_state.get(
					"consequence_receipts", {}) as Dictionary
			).has(OPENING_BUNDLE_ID),
		"fresh prologue fabricated application/action/consequence material")
	_cancel_scene_transition()
	_dispose(main_game)
	GameState.pending_story_queue.clear()
	await get_tree().process_frame
	await get_tree().process_frame


func _check_truthful_opening_story_surface() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	_expect(CORE_LOOP.begin_fresh_w1_onboarding(),
		"fresh opening fixture could not create its onboarding owner")
	GameState.flags["prologue_done"] = true
	var legacy_reserved_queue := [
		INTERVIEW_EVENT_ID, MATH_EVENT_ID, CHAPTER_EVENT_ID,
	]
	var before_preview: Dictionary = GameState.serialize().duplicate(true)
	_expect(not CORE_LOOP.claim_preplan_opening_from_trigger(
			APPLICATION_EVENT_ID, 0) \
			and CORE_LOOP.fresh_preplan_opening_roots().is_empty() \
			and not CORE_LOOP.story_choice_commit_available(
				APPLICATION_EVENT_ID, 0, legacy_reserved_queue) \
			and not CORE_LOOP.claim_legacy_preplan_opening_from_send(
				APPLICATION_EVENT_ID, 0, legacy_reserved_queue) \
			and CORE_LOOP.active_bundle_id().is_empty() \
			and GameState.serialize() == before_preview,
		"fresh W1 origin exposed or claimed the retired Story Send")

	var application_event: Dictionary = DataRegistry.find_event(
		APPLICATION_EVENT_ID)
	var application_choices: Array = application_event.get("choices", [])
	_expect(application_choices.size() == 1,
		"V2 opening preview lost its single explanatory choice")
	if application_choices.size() != 1:
		return
	var preview_choice: Dictionary = application_choices[0]
	_expect(not GameState.is_expression_choice(preview_choice) \
			and not preview_choice.has("effects") \
			and not preview_choice.has("flags") \
			and not CORE_LOOP.note_story_choice(
				APPLICATION_EVENT_ID, 0, legacy_reserved_queue) \
			and GameState.serialize() == before_preview \
			and CORE_LOOP.application_status(
				"mirae_industrial_tech").is_empty() \
			and CORE_LOOP.action_receipt(
				"m1_youth_center_resume_clinic").is_empty() \
			and not bool(GameState.flags.get("story_job_unlocked", false)) \
			and not bool(GameState.flags.get(
				"opening_interview_application_sent", false)) \
			and not bool(GameState.flags.get(
				"opening_preplan_application_sent", false)),
		"fresh origin let the absent legacy Story Send write or claim material")


func _check_legacy_before_send_compatibility() -> void:
	var reserved_queue := [
		INTERVIEW_EVENT_ID, MATH_EVENT_ID, CHAPTER_EVENT_ID,
	]
	var invalid_contracts := [
		{
			"label": "wrong event",
			"event_id": PRESSURE_EVENT_ID,
			"choice_index": 0,
			"queue": reserved_queue,
		},
		{
			"label": "wrong choice",
			"event_id": APPLICATION_EVENT_ID,
			"choice_index": 1,
			"queue": reserved_queue,
		},
		{
			"label": "wrong queue",
			"event_id": APPLICATION_EVENT_ID,
			"choice_index": 0,
			"queue": [
				MATH_EVENT_ID, INTERVIEW_EVENT_ID, CHAPTER_EVENT_ID,
			],
		},
	]
	for invalid in invalid_contracts:
		GameState.start_new_game()
		CORE_LOOP.initialize_for_run(true)
		GameState.flags["prologue_done"] = true
		var before_invalid: Dictionary = GameState.serialize().duplicate(true)
		var event_id := str(invalid.get("event_id", ""))
		var choice_index := int(invalid.get("choice_index", -1))
		var queue: Array = invalid.get("queue", [])
		var application_preflight_rejected := event_id != APPLICATION_EVENT_ID \
			or not CORE_LOOP.story_choice_commit_available(
				event_id, choice_index, queue)
		_expect(application_preflight_rejected \
				and not CORE_LOOP.claim_legacy_preplan_opening_from_send(
					event_id, choice_index, queue) \
				and GameState.serialize() == before_invalid,
			"legacy before-Send %s changed state or passed preflight" \
				% str(invalid.get("label", "invalid origin")))

	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	GameState.flags["prologue_done"] = true
	_expect(CORE_LOOP.fresh_w1_onboarding_snapshot().is_empty() \
			and CORE_LOOP.fresh_preplan_opening_roots() == OPENING_ROOTS,
		"legacy before-Send fixture lost its no-marker adjacent roots")
	var application_event: Dictionary = DataRegistry.find_event(
		APPLICATION_EVENT_ID)
	var application_choices: Array = application_event.get("choices", [])
	_expect(application_choices.size() == 1,
		"legacy before-Send fixture lost its single Send choice")
	if application_choices.size() != 1:
		return
	var send_choice: Dictionary = application_choices[0]
	var before_send: Dictionary = GameState.serialize().duplicate(true)
	var material_before := _opening_story_material_snapshot(before_send)
	var preflight: bool = CORE_LOOP.story_choice_commit_available(
		APPLICATION_EVENT_ID, 0, reserved_queue)
	var applied: bool = GameState.apply_choice(application_event, send_choice)
	var material_after_apply := _opening_story_material_snapshot(
		GameState.serialize())
	var story_choice_state_free: bool = material_after_apply == material_before
	var noted: bool = CORE_LOOP.note_story_choice(
		APPLICATION_EVENT_ID, 0, reserved_queue)
	var transition_key := "%s:%s:0:1" % [
		OPENING_BUNDLE_ID, APPLICATION_EVENT_ID,
	]
	var state: Dictionary = GameState.core_loop_v2_state
	var transition: Dictionary = (
		state.get("application_transition_receipts", {}) as Dictionary
	).get(transition_key, {})
	var consequence: Dictionary = (
		state.get("consequence_receipts", {}) as Dictionary
	).get(OPENING_BUNDLE_ID, {})
	var legacy_checks := {
		"preflight": preflight,
		"applied": applied,
		"story_choice_state_free": story_choice_state_free,
		"noted": noted,
		"no_effects": not send_choice.has("effects"),
		"no_flags": not send_choice.has("flags"),
		"no_onboarding": CORE_LOOP.fresh_w1_onboarding_snapshot().is_empty(),
		"submitted": CORE_LOOP.application_status(
			"mirae_industrial_tech") == "submitted",
		"provenance": CORE_LOOP.opening_application_provenance_valid(),
		"transition_source": str(transition.get(
			"source", "")) == "legacy_story_send",
		"transition_from": str(transition.get("from", "")) == "not_submitted",
		"transition_to": str(transition.get("to", "")) == "submitted",
		"transition_application": str(transition.get(
			"application_id", "")) == "mirae_industrial_tech",
		"consequence_presented": str(consequence.get(
			"status", "")) == "presented",
		"consequence_source": str(consequence.get(
			"claim_source", "")) == "story_choice",
		"consequence_roots": consequence.get("roots", []) == OPENING_ROOTS,
		"active_bundle": CORE_LOOP.active_bundle_id() == OPENING_BUNDLE_ID,
		"active_kind": CORE_LOOP.active_kind() == "consequence",
		"no_pending_weekly": not GameState.has_pending_weekly_commitment(1),
		"no_weekly": not GameState.has_weekly_commitment_for_turn(1),
		"no_resume_action": CORE_LOOP.action_receipt(
			"m1_youth_center_resume_clinic").is_empty(),
		"no_actions": (state.get(
			"action_receipts", {}) as Dictionary).is_empty(),
	}
	var failed_legacy_checks: Array[String] = []
	for check_id in legacy_checks:
		if not bool(legacy_checks[check_id]):
			failed_legacy_checks.append(str(check_id))
	_expect(failed_legacy_checks.is_empty() \
			and not send_choice.has("effects") \
			and not send_choice.has("flags") \
			and CORE_LOOP.fresh_w1_onboarding_snapshot().is_empty() \
			and CORE_LOOP.application_status(
				"mirae_industrial_tech") == "submitted" \
			and CORE_LOOP.opening_application_provenance_valid() \
			and str(transition.get("source", "")) == "legacy_story_send" \
			and str(transition.get("from", "")) == "not_submitted" \
			and str(transition.get("to", "")) == "submitted" \
			and str(transition.get("application_id", "")) \
				== "mirae_industrial_tech" \
			and str(consequence.get("status", "")) == "presented" \
			and str(consequence.get("claim_source", "")) == "story_choice" \
			and consequence.get("roots", []) == OPENING_ROOTS \
			and CORE_LOOP.active_bundle_id() == OPENING_BUNDLE_ID \
			and CORE_LOOP.active_kind() == "consequence" \
			and not GameState.has_pending_weekly_commitment(1) \
			and not GameState.has_weekly_commitment_for_turn(1) \
			and CORE_LOOP.action_receipt(
				"m1_youth_center_resume_clinic").is_empty() \
			and (state.get("action_receipts", {}) as Dictionary).is_empty(),
		"legacy state-free Send lost provenance/consequence or forged a weekly action: %s" \
			% ",".join(failed_legacy_checks))
	var after_send: Dictionary = GameState.serialize().duplicate(true)
	_expect(not CORE_LOOP.claim_legacy_preplan_opening_from_send(
			APPLICATION_EVENT_ID, 0, reserved_queue) \
			and GameState.serialize() == after_send,
		"legacy before-Send compatibility owner could be claimed twice")


func _opening_story_material_snapshot(serialized: Dictionary) -> Dictionary:
	var state: Dictionary = serialized.get("core_loop_v2_state", {}) \
		if serialized.get("core_loop_v2_state", {}) is Dictionary else {}
	return {
		"money": serialized.get("money"),
		"monthly_income": serialized.get("monthly_income"),
		"health": serialized.get("health"),
		"mental": serialized.get("mental"),
		"intelligence": serialized.get("intelligence"),
		"social_skill": serialized.get("social_skill"),
		"appearance": serialized.get("appearance"),
		"investment_skill": serialized.get("investment_skill"),
		"luck": serialized.get("luck"),
		"reputation": serialized.get("reputation"),
		"action_points": serialized.get("action_points"),
		"tendency": (serialized.get("tendency", {}) as Dictionary).duplicate(true),
		"flags": (serialized.get("flags", {}) as Dictionary).duplicate(true),
		"pending_weekly_commitment": (
			serialized.get("pending_weekly_commitment", {}) as Dictionary
		).duplicate(true),
		"weekly_commitments": (
			serialized.get("weekly_commitments", []) as Array
		).duplicate(true),
		"application_statuses": (
			state.get("application_statuses", {}) as Dictionary
		).duplicate(true),
		"application_transition_receipts": (
			state.get("application_transition_receipts", {}) as Dictionary
		).duplicate(true),
		"action_receipts": (
			state.get("action_receipts", {}) as Dictionary
		).duplicate(true),
		"consequence_receipts": (
			state.get("consequence_receipts", {}) as Dictionary
		).duplicate(true),
		"active_bundle": str(state.get("active_bundle", "")),
		"active_kind": str(state.get("active_kind", "")),
	}


func _check_fresh_typed_interview_math_receipts() -> void:
	var interview_event: Dictionary = DataRegistry.find_event(
		INTERVIEW_EVENT_ID)
	var interview_choices: Array = interview_event.get("choices", [])
	var math_event: Dictionary = DataRegistry.find_event(MATH_EVENT_ID)
	var math_choices: Array = math_event.get("choices", [])
	_expect(interview_choices.size() == 2,
		"opening interview lost its two authored answers")
	_expect(math_choices.size() == 2,
		"125-year calculation does not have exactly two responses")
	if interview_choices.size() != 2 or math_choices.size() != 2:
		return

	for interview_choice_index in range(interview_choices.size()):
		GameState.start_new_game()
		CORE_LOOP.initialize_for_run(true)
		GameState.flags["prologue_done"] = true
		var began := CORE_LOOP.begin_fresh_w1_onboarding()
		var initialized := CORE_LOOP.initialize_seoul_cycle(1)
		var presented := began \
			and bool(initialized.get("ok", false)) \
			and _present_fresh_w1_interview_from_open_board()
		_expect(presented,
			"typed W1 fixture could not present interview choice %d" \
				% interview_choice_index)
		if not presented:
			continue
		var presented_receipt: Dictionary = (
			GameState.core_loop_v2_state.get(
				"consequence_receipts", {}) as Dictionary
		).get(OPENING_BUNDLE_ID, {})
		_expect(CORE_LOOP.application_status(
				"mirae_industrial_tech") == "submitted" \
				and CORE_LOOP.active_bundle_id() == OPENING_BUNDLE_ID \
				and CORE_LOOP.active_kind() == "consequence" \
				and str(presented_receipt.get("status", "")) == "presented" \
				and str(presented_receipt.get("surface_kind", "")) \
					== "fresh_w1_action" \
				and str(presented_receipt.get("claim_source", "")) \
					== "typed_action_receipt" \
				and presented_receipt.get("roots", []) == OPENING_ROOTS \
				and (
					GameState.core_loop_v2_state.get(
						"shown_consequences", []) as Array
				).count(OPENING_BUNDLE_ID) == 1,
			"typed Send did not persist one exact presented two-root receipt")

		var interview_choice: Dictionary = (
			interview_choices[interview_choice_index] as Dictionary)
		_expect(GameState.apply_choice(interview_event, interview_choice) \
				and CORE_LOOP.note_story_choice(
					INTERVIEW_EVENT_ID, interview_choice_index) \
				and CORE_LOOP.application_status(
					"mirae_industrial_tech") == "interviewed",
			"opening interview answer %d did not advance the exact submitted application" \
				% interview_choice_index)

		for math_choice_index in range(math_choices.size()):
			var math_choice: Dictionary = math_choices[math_choice_index]
			var serialized_before: Dictionary = (
				GameState.serialize().duplicate(true))
			var story_state_before: Dictionary = (
				GameState.core_loop_v2_state as Dictionary).duplicate(true)
			var mindset_flags_before := {
				"saver": bool(GameState.flags.get("mindset_saver", false)),
				"investor": bool(GameState.flags.get(
					"mindset_investor", false)),
				"founder": bool(GameState.flags.get("mindset_founder", false)),
			}
			var tendency_before := GameState.tendency.duplicate(true)
			_expect(GameState.is_expression_choice(math_choice) \
					and GameState.apply_choice(math_event, math_choice) \
					and CORE_LOOP.note_story_choice(
						MATH_EVENT_ID, math_choice_index),
				"125-year response %d was not a valid expression choice" \
					% math_choice_index)
			_expect(GameState.serialize() == serialized_before \
					and GameState.core_loop_v2_state == story_state_before \
					and GameState.tendency == tendency_before \
					and bool(GameState.flags.get("mindset_saver", false)) \
						== bool(mindset_flags_before["saver"]) \
					and bool(GameState.flags.get("mindset_investor", false)) \
						== bool(mindset_flags_before["investor"]) \
					and bool(GameState.flags.get("mindset_founder", false)) \
						== bool(mindset_flags_before["founder"]),
				(
					"125-year expression %d changed serialized state, story "
					+ "receipts, mindset flags, or tendencies"
				) % math_choice_index)

		CORE_LOOP.restore_story_bundle_followups()
		_expect(CORE_LOOP.complete_active_bundle() == OPENING_BUNDLE_ID,
			"typed opening consequence could not consume its presented owner")
		var consumed_receipt: Dictionary = (
			GameState.core_loop_v2_state.get(
				"consequence_receipts", {}) as Dictionary
		).get(OPENING_BUNDLE_ID, {})
		_expect(str(consumed_receipt.get("status", "")) == "consumed" \
				and consumed_receipt.get("roots", []) == OPENING_ROOTS \
				and str(consumed_receipt.get("claim_source", "")) \
					== "typed_action_receipt" \
				and CORE_LOOP.fresh_w1_onboarding_phase() == "consumed" \
				and CORE_LOOP.active_bundle_id().is_empty() \
				and not CORE_LOOP.needs_preplan_opening() \
				and not CORE_LOOP.claim_saved_preplan_opening(),
			"consumed typed opening replayed or lost its exact two-root history")

		var consumed_save: Dictionary = GameState.serialize().duplicate(true)
		for reload_index in range(2):
			GameState.start_new_game()
			GameState.load_from_dict(consumed_save)
			CORE_LOOP.initialize_for_run()
			var reloaded_receipt: Dictionary = (
				GameState.core_loop_v2_state.get(
					"consequence_receipts", {}) as Dictionary
			).get(OPENING_BUNDLE_ID, {})
			_expect(str(reloaded_receipt.get("status", "")) == "consumed" \
					and reloaded_receipt.get("roots", []) == OPENING_ROOTS \
					and str(reloaded_receipt.get("claim_source", "")) \
						== "typed_action_receipt" \
					and CORE_LOOP.fresh_w1_onboarding_phase() == "consumed" \
					and CORE_LOOP.application_status(
						"mirae_industrial_tech") == "interviewed" \
					and CORE_LOOP.active_bundle_id().is_empty() \
					and not CORE_LOOP.needs_preplan_opening() \
					and not CORE_LOOP.claim_saved_preplan_opening(),
				"consumed opening replayed after reload %d" % (reload_index + 1))
			consumed_save = GameState.serialize().duplicate(true)


func _check_saved_preplan_recovery() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	GameState.flags["prologue_done"] = true
	# This is an authored legacy-before-ORDER-101 submitted save. Preserve its
	# provenance and recovery; never invent a new weekly action receipt for it.
	GameState.flags["story_job_unlocked"] = true
	GameState.flags["opening_interview_application_sent"] = true
	GameState.flags["opening_preplan_application_sent"] = true
	GameState.flags["opening_interview_application_turn"] = 1
	var legacy_state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	legacy_state["application_statuses"][
		"mirae_industrial_tech"] = "submitted"
	GameState.core_loop_v2_state = legacy_state
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
			and CORE_LOOP.action_receipt(
				"m1_youth_center_resume_clinic").is_empty() \
			and CORE_LOOP.fresh_w1_onboarding_snapshot().is_empty() \
			and not _planner_is_visible(main_game) \
			and _find_tutorial(main_game) == null,
		"legacy submitted save lost recovery, fabricated a weekly receipt, or "
		+ "routed past interview/math")
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


func _consume_fresh_w1_consequence_after_actual_send() -> bool:
	if CORE_LOOP.active_bundle_id() != OPENING_BUNDLE_ID \
			or CORE_LOOP.active_kind() != "consequence" \
			or CORE_LOOP.fresh_w1_onboarding_phase() \
				!= "consequence_presented":
		return false
	var interview_event: Dictionary = DataRegistry.find_event(
		INTERVIEW_EVENT_ID)
	var interview_choices: Array = interview_event.get("choices", [])
	var math_event: Dictionary = DataRegistry.find_event(MATH_EVENT_ID)
	var math_choices: Array = math_event.get("choices", [])
	if interview_choices.is_empty() or math_choices.is_empty():
		return false
	if not GameState.apply_choice(
			interview_event, interview_choices[0] as Dictionary) \
			or not CORE_LOOP.note_story_choice(INTERVIEW_EVENT_ID, 0):
		return false
	if not GameState.apply_choice(math_event, math_choices[0] as Dictionary) \
			or not CORE_LOOP.note_story_choice(MATH_EVENT_ID, 0):
		return false
	CORE_LOOP.restore_story_bundle_followups()
	return CORE_LOOP.complete_active_bundle() == OPENING_BUNDLE_ID \
		and CORE_LOOP.fresh_w1_onboarding_phase() == "consumed"


func _present_fresh_w1_interview_from_open_board() -> bool:
	var cycle := CORE_LOOP.seoul_cycle_snapshot(1)
	var capacities: Array = cycle.get("capacities", [])
	if capacities.is_empty() \
			or CORE_LOOP.fresh_w1_onboarding_phase() != "board" \
			or not (cycle.get(
				"allocation_receipts", {}) as Dictionary).is_empty():
		return false
	var selected: Dictionary = capacities[0]
	var capacity_id := str(selected.get("id", ""))
	var allocation := CORE_LOOP.commit_seoul_cycle_allocation(
		capacity_id, "resume", 1)
	if not bool(allocation.get("ok", false)):
		return false
	var claim := CORE_LOOP.claim_seoul_cycle_trigger()
	if not bool(claim.get("ok", false)) \
			or not CORE_LOOP.begin_seoul_cycle_trigger(
				"m1_youth_center_resume_clinic"):
		return false
	if not GameState.arm_weekly_commitment({
		"turn": 1,
		"pressure_id": "m1_youth_center_resume_clinic",
		"pressure_family": "growth",
		"choice_id": "resume",
		"forgone_ids": [],
		"supplemental_to_seoul_cycle": true,
	}) or not CORE_LOOP.restart_fresh_w1_minigame():
		return false
	var transaction := CORE_LOOP.finalize_fresh_w1_application(2, 2)
	return bool(transaction.get("ok", false)) \
		and CORE_LOOP.application_status(
			"mirae_industrial_tech") == "submitted" \
		and CORE_LOOP.complete_active_bundle() \
			== "m1_youth_center_resume_clinic" \
		and CORE_LOOP.claim_fresh_w1_opening_interview()


func _check_fresh_and_reentry_flow() -> void:
	LocaleManager.set_language("ko")
	# Prior legacy fixtures may legitimately visit a Month-One planning surface.
	# Isolate the fresh-flow overlay so this check owns its one-time session bit.
	TutorialOverlay._seen.erase(TUTORIAL_ID)
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	GameState.flags["prologue_done"] = true
	_expect(CORE_LOOP.begin_fresh_w1_onboarding(),
		"first-entry UI fixture could not create the fresh W1 owner")
	var main_game = MAIN_GAME_SCENE.instantiate()
	main_game.set_meta("_screenshot_qa_static_surface", true)
	main_game.set_meta("_qa_suppress_opening_chapter_transition", true)
	main_game.set_meta("_qa_core_loop_v2_autosave_result", true)
	add_child(main_game)
	await get_tree().process_frame
	await get_tree().process_frame

	# The fresh prologue hands directly to the generated W1 board. Onboarding
	# belongs above that real, still-unallocated board; Chapter 1 remains gated
	# until the player's typed application and its consequence are consumed.
	main_game._continue_after_story()
	for _frame in range(8):
		await get_tree().process_frame
	var board = main_game.get("_seoul_cycle_board")
	var tutorial := _find_tutorial(main_game)
	_expect(is_instance_valid(board) and board.visible,
		"fresh prologue did not route to the W1 Seoul Cycle board")
	_expect(tutorial != null and int(tutorial.get("_slides").size()) == 3,
		"V2 onboarding did not open as a three-slide overlay over the Seoul board")
	_expect(not bool(GameState.flags.get("tutorial_shown", false)),
		"V2 onboarding persisted its one-time flag before actual completion")
	_expect(str(main_game.get_meta("_qa_opening_chapter_event", "")).is_empty() \
			and GameState.pending_story_queue.is_empty(),
		"fresh W1 board routed Chapter 1 before the application result")
	if not is_instance_valid(board) or tutorial == null:
		_dispose(main_game)
		return

	var focus_owner := get_viewport().gui_get_focus_owner()
	_expect(focus_owner != null and tutorial.is_ancestor_of(focus_owner),
		"V2 onboarding did not trap focus above the Seoul board")
	var restore_target := tutorial.get("_previous_focus") as Control
	_expect(is_instance_valid(restore_target) and board.is_ancestor_of(restore_target),
		"V2 onboarding did not remember a Seoul-board control for focus restoration")

	_underlying_presses = 0
	var node_buttons: Dictionary = board.get("_node_buttons")
	var capacity_buttons: Dictionary = board.get("_die_buttons")
	var snapshot := CORE_LOOP.seoul_cycle_snapshot(1)
	var plan := CORE_LOOP.plan_for_month(1)
	_expect(CORE_LOOP.plan_uses_seoul_cycle(plan) \
			and not CORE_LOOP.plan_uses_episode_selection(plan) \
			and node_buttons.size() == 4 and capacity_buttons.size() == 4 \
			and (snapshot.get(
				"allocation_receipts", {}) as Dictionary).is_empty() \
			and CORE_LOOP.fresh_w1_onboarding_phase() == "board" \
			and CORE_LOOP.application_status(
				"mirae_industrial_tech").is_empty() \
			and CORE_LOOP.action_receipt(
				"m1_youth_center_resume_clinic").is_empty(),
		"guided W1 board fabricated an allocation or application before input")
	for node_id in ["convenience", "resume", "father", "recovery"]:
		_expect(node_buttons.has(node_id),
			"fresh Seoul board lost node %s" % node_id)
	for raw_button in node_buttons.values() + capacity_buttons.values():
		var offer_button := raw_button as Button
		if is_instance_valid(offer_button):
			offer_button.pressed.connect(_on_underlying_planner_pressed)
	var cycle_before: Dictionary = GameState.core_loop_v2_state.get(
		"seoul_cycle", {}).duplicate(true)
	var navigation_before := {
		"focus_group": str(board.get_meta("seoul_cycle_focus_group", "")),
		"focus_id": str(board.get_meta("seoul_cycle_focus_id", "")),
		"selected_capacity": str(board.get_meta(
			"seoul_cycle_selected_die_id", "")),
		"selected_node": str(board.get_meta(
			"seoul_cycle_selected_node_id", "")),
	}
	var tutorial_guard_turn := int(GameState.turn)
	var tutorial_guard_modal_visible := bool(main_game.modal_layer.visible)
	var tutorial_guard_modal_kind := str(main_game._modal_kind)
	var tutorial_guard_focus := get_viewport().gui_get_focus_owner()
	var tutorial_guard_ap := int(GameState.action_points)
	GameState.action_points = 0
	_send_semantic_action("gd_menu")
	await get_tree().process_frame
	await get_tree().process_frame
	_send_semantic_action("gd_next_month")
	await get_tree().process_frame
	await get_tree().process_frame
	GameState.action_points = tutorial_guard_ap
	_expect(GameState.turn == tutorial_guard_turn \
			and bool(main_game.modal_layer.visible) \
				== tutorial_guard_modal_visible \
			and str(main_game._modal_kind) == tutorial_guard_modal_kind \
			and GameState.core_loop_v2_state.get("seoul_cycle", {}) \
				== cycle_before \
			and _find_tutorial(main_game) == tutorial \
			and get_viewport().gui_get_focus_owner() == tutorial_guard_focus,
		"gd_menu or gd_next_month changed modal, turn, cycle, or focus behind V2 onboarding")
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
	await _expect_tutorial_owns_cycle_navigation(
		board, tutorial, navigation_before, "E")
	_send_tab_key(KEY_Q)
	await _expect_tutorial_owns_cycle_navigation(
		board, tutorial, navigation_before, "Q")
	_send_tab_shoulder(JOY_BUTTON_RIGHT_SHOULDER)
	await _expect_tutorial_owns_cycle_navigation(
		board, tutorial, navigation_before, "right shoulder")
	_send_tab_shoulder(JOY_BUTTON_LEFT_SHOULDER)
	await _expect_tutorial_owns_cycle_navigation(
		board, tutorial, navigation_before, "left shoulder")

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
			and GameState.core_loop_v2_state.get("seoul_cycle", {}) \
				== cycle_before \
			and str(board.get_meta("seoul_cycle_selected_die_id", "")) \
				== str(navigation_before["selected_capacity"]) \
			and str(board.get_meta("seoul_cycle_selected_node_id", "")) \
				== str(navigation_before["selected_node"]),
		"tutorial input changed the Seoul Cycle allocation or selection")
	var restored_focus := get_viewport().gui_get_focus_owner()
	_expect(restored_focus != null and board.is_ancestor_of(restored_focus),
		"closing V2 onboarding did not restore focus to the Seoul board")

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
	reloaded_main.set_meta("_qa_core_loop_v2_autosave_result", true)
	reloaded_main.set_meta("_qa_core_loop_v2_autosave_call_count", 0)
	add_child(reloaded_main)
	await get_tree().process_frame
	await get_tree().process_frame
	var reopened_saved_plan := bool(
		reloaded_main._core_loop_v2_open_saved_plan())
	for _frame in range(4):
		await get_tree().process_frame
	var reloaded_board = reloaded_main.get("_seoul_cycle_board")
	_expect(reopened_saved_plan \
			and _board_is_visible(reloaded_main) \
			and not bool(reloaded_board.get_meta(
				"seoul_cycle_read_only", true)) \
			and CORE_LOOP.plan_uses_seoul_cycle(CORE_LOOP.plan_for_month(1)),
		"saved current-week Seoul board did not reopen editable")
	var reloaded_close_button = reloaded_board.get("_close_button")
	_expect(is_instance_valid(reloaded_close_button) \
			and not bool(reloaded_close_button.visible),
		"editable Seoul board exposed a close button before allocation")
	_expect(str(reloaded_board.get_meta(
			"seoul_cycle_selected_die_id", "")).is_empty() \
			and str(reloaded_board.get_meta(
				"seoul_cycle_selected_node_id", "")).is_empty(),
		"saved unallocated Seoul board did not reopen at its root")

	var east_guard_turn: int = int(GameState.turn)
	var east_guard_week: int = int(GameState.week_of_month)
	var east_guard_cycle: Dictionary = GameState.core_loop_v2_state.get(
		"seoul_cycle", {}).duplicate(true)
	_send_gamepad_east()
	for _frame in range(3):
		await get_tree().process_frame
	_expect(_board_is_visible(reloaded_main) \
			and not bool(reloaded_board.get_meta(
				"seoul_cycle_read_only", true)) \
			and GameState.turn == east_guard_turn \
			and GameState.week_of_month == east_guard_week \
			and GameState.core_loop_v2_state.get("seoul_cycle", {}) \
				== east_guard_cycle \
			and str(reloaded_board.get_meta(
				"seoul_cycle_selected_die_id", "")).is_empty() \
			and str(reloaded_board.get_meta(
				"seoul_cycle_selected_node_id", "")).is_empty(),
			"root East closed or changed an unallocated Seoul cycle week")
	var board_guard_modal_visible := bool(reloaded_main.modal_layer.visible)
	var board_guard_modal_kind := str(reloaded_main._modal_kind)
	var board_guard_focus := get_viewport().gui_get_focus_owner()
	var board_guard_ap := int(GameState.action_points)
	GameState.action_points = 0
	_send_semantic_action("gd_menu")
	await get_tree().process_frame
	await get_tree().process_frame
	_send_semantic_action("gd_next_month")
	await get_tree().process_frame
	await get_tree().process_frame
	GameState.action_points = board_guard_ap
	_expect(GameState.turn == east_guard_turn \
			and GameState.week_of_month == east_guard_week \
			and bool(reloaded_main.modal_layer.visible) \
				== board_guard_modal_visible \
			and str(reloaded_main._modal_kind) == board_guard_modal_kind \
			and GameState.core_loop_v2_state.get("seoul_cycle", {}) \
				== east_guard_cycle \
			and get_viewport().gui_get_focus_owner() == board_guard_focus,
		"gd_menu or gd_next_month changed modal, turn, cycle, or focus behind the Seoul board")

	var advance_guard_state: Dictionary = GameState.serialize().duplicate(true)
	reloaded_main._on_next_month()
	for _frame in range(4):
		await get_tree().process_frame
	_expect(GameState.turn == east_guard_turn \
			and GameState.week_of_month == east_guard_week \
			and GameState.serialize() == advance_guard_state \
			and _board_is_visible(reloaded_main) \
			and not bool(reloaded_board.get_meta(
				"seoul_cycle_read_only", true)),
		"generic Next Week advanced or changed an unallocated Seoul cycle week")
	_expect(_find_tutorial(reloaded_main) == null \
			and not TutorialOverlay._seen.has(TUTORIAL_ID),
		"saved V2 onboarding appeared a second time after reload")
	# Continue the same generated board after the tutorial/reload boundary with
	# real controls. The evidence below may inspect CORE state, but it may not
	# finalize or claim the product transaction directly: board commit,
	# JobHunt answers, Review, and Send all arrive through MainGame input.
	var real_input_result: Dictionary = await _play_fresh_w1_through_main_input(
		reloaded_main, reloaded_board)
	if real_input_result.is_empty():
		_dispose(reloaded_main)
		return
	_expect(_consume_fresh_w1_consequence_after_actual_send(),
		"actual W1 Send reached interview but its fixture could not consume "
		+ "interview and calculation")
	var completed_application := CORE_LOOP.action_receipt(
		"m1_youth_center_resume_clinic")
	var completed_cycle := CORE_LOOP.seoul_cycle_snapshot(1)
	_expect(CORE_LOOP.fresh_w1_onboarding_phase() == "consumed" \
			and CORE_LOOP.application_status(
				"mirae_industrial_tech") == "interviewed" \
			and str(completed_application.get("application_id", "")) \
				== "mirae_industrial_tech" \
			and str(completed_application.get("application_status", "")) \
				== "submitted" \
			and str((completed_application.get(
				"result_details", {}) as Dictionary).get("execution", "")) \
				== "job_hunt_application" \
			and (completed_cycle.get(
				"allocation_receipts", {}) as Dictionary).size() == 1,
		"guided W1 completion lost its typed application or allocation owner")
	_dispose(reloaded_main)
	GameState.pending_story_queue.clear()
	await get_tree().process_frame
	await get_tree().process_frame

	var chapter_main = MAIN_GAME_SCENE.instantiate()
	chapter_main.set_meta("_screenshot_qa_static_surface", true)
	chapter_main.set_meta("_qa_suppress_opening_chapter_transition", true)
	chapter_main.set_meta("_qa_core_loop_v2_autosave_result", true)
	add_child(chapter_main)
	await get_tree().process_frame
	await get_tree().process_frame
	chapter_main._continue_after_story()
	for _frame in range(3):
		await get_tree().process_frame
	_expect(str(chapter_main.get_meta(
			"_qa_opening_chapter_event", "")) == CHAPTER_EVENT_ID \
			and GameState.pending_story_queue == [CHAPTER_EVENT_ID] \
			and not _board_is_visible(chapter_main) \
			and _find_tutorial(chapter_main) == null,
		"completed W1 did not stop at Chapter 1 before the remaining board")

	var chapter_event: Dictionary = DataRegistry.find_event(CHAPTER_EVENT_ID)
	var chapter_choices: Array = chapter_event.get("choices", [])
	_expect(not chapter_event.is_empty() and chapter_choices.size() == 1,
		"Chapter 1 event or its single authored action is missing")
	if chapter_event.is_empty() or chapter_choices.size() != 1:
		_dispose(chapter_main)
		return
	GameState.apply_choice(chapter_event, chapter_choices[0] as Dictionary)
	GameState.pending_story_queue.clear()
	_expect(bool(GameState.flags.get("chapter_33_seen", false)),
		"Chapter 1 action did not set its canonical seen flag")
	chapter_main._continue_after_story()
	for _frame in range(10):
		await get_tree().process_frame
	var remaining_board = chapter_main.get("_seoul_cycle_board")
	var remaining_cycle := CORE_LOOP.seoul_cycle_snapshot(1)
	_expect(GameState.turn == 2 and GameState.week_of_month == 2 \
			and is_instance_valid(remaining_board) and remaining_board.visible \
			and not bool(remaining_board.get_meta(
				"seoul_cycle_read_only", true)) \
			and _find_tutorial(chapter_main) == null \
			and bool(GameState.flags.get("tutorial_shown", false)) \
			and CORE_LOOP.action_receipt(
				"m1_youth_center_resume_clinic") == completed_application \
			and (remaining_cycle.get(
				"allocation_receipts", {}) as Dictionary).size() == 1,
		"Chapter 1 return did not reach the editable W2 board exactly once")
	_dispose(chapter_main)
	await get_tree().process_frame
	await get_tree().process_frame


func _play_fresh_w1_through_main_input(
		main_game: Node, board: Control) -> Dictionary:
	var cycle_before := CORE_LOOP.seoul_cycle_snapshot(1)
	var capacities: Array = cycle_before.get("capacities", [])
	var capacity_id := ""
	for raw_capacity in capacities:
		if raw_capacity is Dictionary \
				and not bool((raw_capacity as Dictionary).get(
					"consumed", false)):
			capacity_id = str((raw_capacity as Dictionary).get("id", ""))
			break
	var capacity_buttons: Dictionary = board.get("_die_buttons")
	var node_buttons: Dictionary = board.get("_node_buttons")
	var capacity_button := capacity_buttons.get(capacity_id) as Button
	var resume_button := node_buttons.get("resume") as Button
	var commit_button := board.get("_commit_button") as Button
	_expect(not capacity_id.is_empty() \
			and is_instance_valid(capacity_button) \
			and is_instance_valid(resume_button) \
			and is_instance_valid(commit_button),
		"actual W1 input fixture could not find capacity, resume, or Commit")
	if capacity_id.is_empty() \
			or not is_instance_valid(capacity_button) \
			or not is_instance_valid(resume_button) \
			or not is_instance_valid(commit_button):
		return {}

	# Capacity selection is only a preview. Keyboard Back and pad East must
	# undo it without touching any serialized gameplay state.
	var root_state: Dictionary = GameState.serialize().duplicate(true)
	await _activate_button_from_input(capacity_button, false)
	_expect(str(board.get_meta(
			"seoul_cycle_selected_die_id", "")) == capacity_id \
			and GameState.serialize() == root_state,
		"keyboard capacity preview changed state before Commit")
	_send_keyboard_cancel()
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(str(board.get_meta(
			"seoul_cycle_selected_die_id", "")).is_empty() \
			and str(board.get_meta(
				"seoul_cycle_selected_node_id", "")).is_empty() \
			and GameState.serialize() == root_state,
		"keyboard Back did not restore the exact unallocated prestate")

	await _activate_button_from_input(capacity_button, true)
	_expect(str(board.get_meta(
			"seoul_cycle_selected_die_id", "")) == capacity_id \
			and GameState.serialize() == root_state,
		"pad South did not use the capacity-selection input path")
	_send_gamepad_east()
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(str(board.get_meta(
			"seoul_cycle_selected_die_id", "")).is_empty() \
			and GameState.serialize() == root_state,
		"pad East did not cancel capacity selection with exact state")

	# Re-select on keyboard, inspect the guided resume node, cancel that stage,
	# then repeat it and commit through the real Board signal bridge.
	await _activate_button_from_input(capacity_button, false)
	await _activate_button_from_input(resume_button, false)
	_expect(str(board.get_meta(
			"seoul_cycle_selected_die_id", "")) == capacity_id \
			and str(board.get_meta(
				"seoul_cycle_selected_node_id", "")) == "resume" \
			and GameState.serialize() == root_state,
		"keyboard resume preview changed state before Commit")
	_send_keyboard_cancel()
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(str(board.get_meta(
			"seoul_cycle_selected_die_id", "")) == capacity_id \
			and str(board.get_meta(
				"seoul_cycle_selected_node_id", "")).is_empty() \
			and GameState.serialize() == root_state,
		"keyboard Back did not undo only the node stage with exact state")

	var input_counts := {
		"allocation": 0,
		"job_hunt_closed": 0,
		"send": 0,
	}
	board.allocation_requested.connect(func(
			_capacity_id: String, _node_id: String,
			_selected_bundle_id: String = "") -> void:
		input_counts["allocation"] = int(input_counts["allocation"]) + 1
	)
	await _activate_button_from_input(resume_button, false)
	_expect(not commit_button.disabled,
		"actual W1 resume preview did not enable Commit")
	if commit_button.disabled:
		return {}
	await _activate_button_from_input(commit_button, false)
	await get_tree().create_timer(0.75).timeout
	for _frame in range(5):
		await get_tree().process_frame

	var job_hunt = main_game.get("job_hunt_game")
	var active_questions: Array = job_hunt.get("_active_questions") \
		if is_instance_valid(job_hunt) else []
	_expect(is_instance_valid(job_hunt) and bool(job_hunt.visible) \
			and int(job_hunt.get("current_mode")) == 0 \
			and bool(job_hunt.get("application_submission_mode")) \
			and active_questions.size() == 4 \
			and CORE_LOOP.fresh_w1_onboarding_phase() == "minigame" \
			and int(input_counts["allocation"]) == 1,
		"Board Commit did not open the four-question application JobHunt once")
	if not is_instance_valid(job_hunt) or not bool(job_hunt.visible) \
			or active_questions.size() != 4:
		return {}

	job_hunt.closed.connect(func(
			_stress_delta: int, _quality: int) -> void:
		input_counts["job_hunt_closed"] = int(
			input_counts["job_hunt_closed"]) + 1
	)
	var answer_inputs := 0
	for question_index in range(4):
		var choice_box := job_hunt.get("_choice_vb") as Control
		var choice_button := _first_enabled_button(choice_box)
		_expect(is_instance_valid(choice_button),
			"JobHunt question %d had no focused answer" % (question_index + 1))
		if not is_instance_valid(choice_button):
			return {}
		await _activate_button_from_input(choice_button, false)
		answer_inputs += 1
		await get_tree().create_timer(0.92).timeout
		await get_tree().process_frame
		await get_tree().process_frame

	var result_button := _first_enabled_button(
		job_hunt.get("_content_vb") as Control)
	_expect(answer_inputs == 4 \
			and int(job_hunt.get("_q_idx")) == 4 \
			and is_instance_valid(result_button) \
			and (
				"지원서 검토" in result_button.text \
				or "Review Application" in result_button.text
			),
		"four actual JobHunt answers did not reach Review Application")
	if not is_instance_valid(result_button):
		return {}
	await _activate_button_from_input(result_button, false)
	await get_tree().process_frame
	await get_tree().process_frame

	var pre_send: Dictionary = GameState.serialize().duplicate(true)
	var pre_send_state: Dictionary = GameState.core_loop_v2_state
	var pre_send_cycle := CORE_LOOP.seoul_cycle_snapshot(1)
	var application_event: Dictionary = DataRegistry.find_event(
		APPLICATION_EVENT_ID)
	var application_choices: Array = application_event.get("choices", [])
	var story_choice_writes_zero := application_choices.size() == 1 \
		and not (application_choices[0] as Dictionary).has("effects") \
		and not (application_choices[0] as Dictionary).has("flags")
	var send_button := _find_button_with_meta(
		main_game.get("modal_body") as Node,
		"fresh_w1_application_send_button")
	_expect(not bool(job_hunt.visible) \
			and int(input_counts["job_hunt_closed"]) == 1 \
			and bool(main_game.modal_layer.visible) \
			and bool(main_game.modal_layer.get_meta(
				"fresh_w1_application_send", false)) \
			and is_instance_valid(send_button) \
			and story_choice_writes_zero \
			and GameState.has_pending_weekly_commitment(1) \
			and GameState.weekly_commitments.size() == 1 \
			and (pre_send_cycle.get(
				"allocation_receipts", {}) as Dictionary).size() == 1 \
			and (pre_send_state.get(
				"action_receipts", {}) as Dictionary).is_empty() \
			and (pre_send_state.get(
				"application_transition_receipts", {}) as Dictionary).is_empty() \
			and CORE_LOOP.application_status(
				"mirae_industrial_tech").is_empty(),
		"Review surface bypassed draft ownership or wrote Send material early")
	if not is_instance_valid(send_button):
		return {}

	send_button.pressed.connect(func() -> void:
		input_counts["send"] = int(input_counts["send"]) + 1
	)
	send_button.grab_focus()
	await get_tree().process_frame
	_send_keyboard_accept()
	await get_tree().process_frame
	await get_tree().process_frame
	_cancel_scene_transition()
	var after_first_send: Dictionary = GameState.serialize().duplicate(true)
	# A rapid second physical Enter still targets the disabled/closing review.
	# It may not create another application transaction or autosave.
	_send_keyboard_accept()
	_cancel_scene_transition()
	await get_tree().process_frame
	await get_tree().process_frame
	var after_duplicate_send: Dictionary = GameState.serialize().duplicate(true)

	var state: Dictionary = GameState.core_loop_v2_state
	var allocation_receipts: Dictionary = (
		CORE_LOOP.seoul_cycle_snapshot(1).get(
			"allocation_receipts", {}) as Dictionary)
	var action_receipts: Dictionary = state.get("action_receipts", {})
	var application_receipts: Dictionary = state.get(
		"application_transition_receipts", {})
	var consequence_receipts: Dictionary = state.get(
		"consequence_receipts", {})
	var action_receipt: Dictionary = action_receipts.get(
		"m1_youth_center_resume_clinic", {})
	var application_receipt: Dictionary = application_receipts.get(
		"m1_youth_center_resume_clinic:application:1", {})
	var consequence_receipt: Dictionary = consequence_receipts.get(
		OPENING_BUNDLE_ID, {})
	var weekly_receipt := GameState.get_weekly_commitment_for_turn(1)
	var weekly_details: Dictionary = weekly_receipt.get("details", {}) \
		if weekly_receipt.get("details", {}) is Dictionary else {}
	var action_followups: Array = weekly_details.get(
		"action_followups", []) \
		if weekly_details.get("action_followups", []) is Array else []
	var quality := int((action_receipt.get(
		"result_details", {}) as Dictionary).get("quality", -1))
	var story_material_writes := 0
	for flag_id in [
		"story_job_unlocked",
		"opening_interview_application_sent",
		"opening_preplan_application_sent",
	]:
		if bool(GameState.flags.get(flag_id, false)):
			story_material_writes += 1
	if not story_choice_writes_zero \
			or not str(application_receipt.get("event_id", "")).is_empty() \
			or int(application_receipt.get("choice_index", -1)) != -1:
		story_material_writes += 1

	var followup_bundle := str((action_followups[0] as Dictionary).get(
		"bundle_id", "")) if not action_followups.is_empty() else ""
	var allocation_receipt: Dictionary = allocation_receipts.get("1", {})
	var receipt_checks := {
		"duplicate_state": after_duplicate_send == after_first_send,
		"send_once": int(input_counts["send"]) == 1,
		"allocation_signal_once": int(input_counts["allocation"]) == 1,
		"autosave_allocation_and_send": int(main_game.get_meta(
			"_qa_core_loop_v2_autosave_call_count", -1)) == 2,
		"pending_weekly_cleared": not GameState.has_pending_weekly_commitment(1),
		"weekly_once": GameState.weekly_commitments.size() == 1,
		"weekly_present": not weekly_receipt.is_empty(),
		"weekly_cycle_owner": str(weekly_receipt.get(
			"source", "")) == "seoul_cycle",
		"weekly_followup_once": action_followups.size() == 1,
		"weekly_followup_identity": followup_bundle \
			== "m1_youth_center_resume_clinic",
		"allocation_once": allocation_receipts.size() == 1,
		"allocation_capacity": str(allocation_receipt.get(
			"capacity_id", "")) == capacity_id,
		"allocation_node": str(allocation_receipt.get(
			"node_id", "")) == "resume",
		"action_once": action_receipts.size() == 1,
		"action_application": str(action_receipt.get(
			"application_id", "")) == "mirae_industrial_tech",
		"action_status": str(action_receipt.get(
			"application_status", "")) == "submitted",
		"action_quality": quality in range(0, 4),
		"application_once": application_receipts.size() == 1,
		"application_typed": str(application_receipt.get(
			"source", "")) == "typed_action_receipt",
		"application_identity": str(application_receipt.get(
			"application_id", "")) == "mirae_industrial_tech",
		"story_writes_zero": story_material_writes == 0,
		"consequence_once": consequence_receipts.size() == 1,
		"consequence_presented": str(consequence_receipt.get(
			"status", "")) == "presented",
		"consequence_typed": str(consequence_receipt.get(
			"claim_source", "")) == "typed_action_receipt",
		"consequence_roots": consequence_receipt.get(
			"roots", []) == OPENING_ROOTS,
		"active_interview": CORE_LOOP.active_bundle_id() == OPENING_BUNDLE_ID \
			and CORE_LOOP.active_kind() == "consequence",
		"onboarding_handoff": CORE_LOOP.fresh_w1_onboarding_phase() \
			== "consequence_presented",
	}
	var failed_receipt_checks: Array[String] = []
	for check_id in receipt_checks:
		if not bool(receipt_checks[check_id]):
			failed_receipt_checks.append(str(check_id))
	_expect(failed_receipt_checks.is_empty(),
		"actual Board→JobHunt→Review→Send path failed: %s" \
			% ",".join(failed_receipt_checks))
	return {
		"action_receipt": action_receipt.duplicate(true),
		"quality": quality,
		"pre_send": pre_send,
	}


func _activate_button_from_input(button: Button, gamepad: bool) -> void:
	button.grab_focus()
	await get_tree().process_frame
	if gamepad:
		_send_gamepad_south()
	else:
		_send_keyboard_accept()
	await get_tree().process_frame
	await get_tree().process_frame


func _first_enabled_button(root: Node) -> Button:
	if not is_instance_valid(root):
		return null
	for child in root.get_children():
		if child.is_queued_for_deletion():
			continue
		if child is Button and child.visible and not child.disabled:
			return child as Button
		var nested := _first_enabled_button(child)
		if is_instance_valid(nested):
			return nested
	return null


func _find_button_with_meta(root: Node, meta_key: String) -> Button:
	if not is_instance_valid(root):
		return null
	for child in root.get_children():
		if child.is_queued_for_deletion():
			continue
		if child is Button and child.has_meta(meta_key):
			return child as Button
		var nested := _find_button_with_meta(child, meta_key)
		if is_instance_valid(nested):
			return nested
	return null


func _planner_is_visible(main_game: Node) -> bool:
	var planner = main_game.get("_core_loop_planner")
	return is_instance_valid(planner) and bool(planner.visible)


func _board_is_visible(main_game: Node) -> bool:
	var board = main_game.get("_seoul_cycle_board")
	return is_instance_valid(board) and bool(board.visible)


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


func _send_keyboard_cancel() -> void:
	var press := InputEventKey.new()
	press.keycode = KEY_ESCAPE
	press.physical_keycode = KEY_ESCAPE
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


func _send_gamepad_east() -> void:
	var press := InputEventJoypadButton.new()
	press.device = 0
	press.button_index = JOY_BUTTON_B
	press.pressed = true
	press.pressure = 1.0
	Input.parse_input_event(press)
	var release := press.duplicate() as InputEventJoypadButton
	release.pressed = false
	release.pressure = 0.0
	Input.parse_input_event(release)


func _send_gamepad_south() -> void:
	var press := InputEventJoypadButton.new()
	press.device = 0
	press.button_index = JOY_BUTTON_A
	press.pressed = true
	press.pressure = 1.0
	Input.parse_input_event(press)
	var release := press.duplicate() as InputEventJoypadButton
	release.pressed = false
	release.pressure = 0.0
	Input.parse_input_event(release)


func _send_semantic_action(action: String) -> void:
	var press := InputEventAction.new()
	press.action = action
	press.pressed = true
	Input.parse_input_event(press)
	var release := press.duplicate() as InputEventAction
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


func _expect_tutorial_owns_cycle_navigation(
		board: Control, tutorial: TutorialOverlay,
		expected_navigation: Dictionary, input_name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var tutorial_focus := get_viewport().gui_get_focus_owner()
	_expect(str(board.get_meta("seoul_cycle_selected_die_id", "")) \
			== str(expected_navigation.get("selected_capacity", "")) \
			and str(board.get_meta("seoul_cycle_selected_node_id", "")) \
				== str(expected_navigation.get("selected_node", "")) \
			and tutorial_focus != null \
			and tutorial.is_ancestor_of(tutorial_focus),
		"%s changed the Seoul board or stole focus behind V2 onboarding" \
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
