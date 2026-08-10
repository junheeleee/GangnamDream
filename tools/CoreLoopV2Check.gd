extends Node
## ORDER-57: shared 1–8 week Core Loop V2 regression under the staged demo gate.

const CORE_LOOP := preload("res://systems/DemoCoreLoopV2.gd")
const PLANNER := preload("res://scenes/CoreLoopPlanner.gd")

var _failures: Array[String] = []

func _ready() -> void:
	var original_language := LocaleManager.language
	var original_sfx_enabled := AudioManager.sfx_enabled
	AudioManager.sfx_enabled = false
	_check_explicit_activation()
	_check_deadline_and_routine_validation()
	_check_month_one_plan()
	_check_background_routines_once()
	_check_midmonth_employment_routine_transition()
	_check_decline_consumption_once()
	_check_delayed_consequences_cross_month()
	_check_relationship_initiative()
	_check_month_summary_durability()
	_check_story_followup_suppression()
	_check_branch_resolution()
	_check_prototype_completion_boundary()
	await _check_planner_surface()
	await _stop_test_audio()
	LocaleManager.language = original_language
	AudioManager.sfx_enabled = original_sfx_enabled
	if _failures.is_empty():
		print(
			"CORE_LOOP_V2_CHECK_OK activation=explicit shared_months=2 slots=4 "
			+ "locked=week4 deadlines=machine plan=immutable "
			+ "routines=16_units/once/job_transition "
			+ "forgone=producer_consumer/once delayed=cross_month/one_per_week "
			+ "relationship=choice_only/monotonic summary=ack/save "
			+ "opening=interview+math/legacy_followup_only/old_plan_week2 "
			+ "followup=restored save=roundtrip "
			+ "boundary=week12_continues/week24_cap "
			+ "planner=single_rail/3steps/4weeks/status+people+record/two_step/read_only "
			+ "planner_intent=focus_safe/offer_then_week/toggle/move/invalid_safe "
			+ "planner_focus=explicit_neighbors/raw_dpad_route/all_surfaces_scroll "
			+ "planner_input=east_cancel/west_focus_only/fresh_confirm/double_click_safe/shoulders/p-north "
			+ "planner_job=primary_fixed/duplicate_disabled "
			+ "planner_layout=1280x800/960x600 communication=separate_signal "
			+ "en_hangul=0 hidden_scores=0")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("CORE_LOOP_V2_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)

func _check_explicit_activation() -> void:
	GameState.start_new_game()
	_expect(not CORE_LOOP.is_active(),
		"prototype activated without its explicit runtime flag")
	_expect(CORE_LOOP.initialize_for_run(true),
		"forced prototype activation failed")
	_expect(CORE_LOOP.development_cap_week() == 24,
		"shared regression did not inherit the week-24 development cap")
	_expect(CORE_LOOP.is_active(),
		"prototype did not become active in week one")
	GameState.turn = 9
	_expect(CORE_LOOP.is_active(),
		"prototype did not extend its explicit runtime through week 9")
	GameState.turn = 13
	_expect(CORE_LOOP.is_active(),
		"extended development build did not continue into week 13")
	_expect(not CORE_LOOP.is_prototype_complete(),
		"prototype marked an untouched week-thirteen run complete")
	GameState.turn = 17
	_expect(CORE_LOOP.is_active() and not CORE_LOOP.is_prototype_complete(),
		"extended development build did not continue into week 17")
	GameState.turn = 20
	_expect(CORE_LOOP.is_active() and not CORE_LOOP.is_prototype_complete(),
		"extended development build did not include week 20")
	GameState.turn = 21
	_expect(CORE_LOOP.is_active() and not CORE_LOOP.is_prototype_complete(),
		"extended development build did not continue into week 21")
	GameState.turn = 24
	_expect(CORE_LOOP.is_active() and not CORE_LOOP.is_prototype_complete(),
		"extended development build did not include week 24")
	GameState.turn = 25
	_expect(not CORE_LOOP.is_active() and not CORE_LOOP.is_prototype_complete(),
		"untouched build did not stop safely after its week-24 boundary")

func _check_deadline_and_routine_validation() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	var wrong_deadline := {
		"1": "father_first_call",
		"2": "m1_mirae_application",
		"3": "hyunsu_first_meet",
		"4": "first_temptation_boss",
	}
	var deadline_result := CORE_LOOP.validate_plan(
		1, wrong_deadline, _growth_routines())
	_expect(not bool(deadline_result.get("ok", false)) \
			and str(deadline_result.get("error", "")) == "deadline_missed" \
			and str(deadline_result.get("bundle", "")) == "m1_mirae_application",
		"machine deadline allowed the week-one application in week two")
	var duplicate_routines := {
		"primary": "livelihood",
		"secondary": "livelihood",
	}
	var duplicate_result := CORE_LOOP.validate_plan(
		1, _month_one_schedule(), duplicate_routines)
	_expect(not bool(duplicate_result.get("ok", false)) \
			and str(duplicate_result.get("error", "")) \
				== "routines_must_be_distinct",
		"monthly plan accepted the same routine in both background units")
	var valid_result := CORE_LOOP.validate_plan(
		1, _month_one_schedule(), _growth_routines())
	_expect(bool(valid_result.get("ok", false)),
		"legal week deadlines and two distinct routines were rejected")
	GameState.current_job = {"id": "qa_employed"}
	var employed_result := CORE_LOOP.validate_plan(
		1, _month_one_schedule(), _growth_routines())
	_expect(not bool(employed_result.get("ok", false)) \
			and str(employed_result.get("error", "")) \
				== "job_requires_primary_livelihood",
		"an employed plan displaced its persistent job obligation")
	GameState.current_job = {}

func _check_month_one_plan() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	var available := CORE_LOOP.available_offer_ids(1)
	_expect(available.size() == 6,
		"month one does not expose its six authored opportunities")
	_expect(available.has("m1_mirae_application"),
		"month one lost the causal job application")
	var expected_post_interview: Array = available.duplicate()
	expected_post_interview.erase("m1_mirae_application")
	var interviewed_state: Dictionary = GameState.core_loop_v2_state
	interviewed_state["application_statuses"][
		"mirae_industrial_tech"] = "interviewed"
	GameState.core_loop_v2_state = interviewed_state
	var post_interview := CORE_LOOP.available_offer_ids(1)
	expected_post_interview.sort()
	post_interview.sort()
	_expect(post_interview == expected_post_interview \
			and post_interview.size() == 5 \
			and not post_interview.has("m1_mirae_application"),
		"fresh pre-plan interview did not hide only the now-finished "
		+ "application while preserving the other five Month-1 offers")

	# Old V2 plans and saves may still own the original Week-1 application.
	# Reset to that untouched state before exercising its scheduled-prelude path.
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	available = CORE_LOOP.available_offer_ids(1)
	_expect(available.size() == 6 \
			and available.has("m1_mirae_application"),
		"legacy Month-1 application compatibility disappeared after filtering "
		+ "the fresh pre-plan interview")
	_expect(not CORE_LOOP.available_offer_ids(2).has("hyunsu_player_reachout"),
		"Hyunsu follow-up opened before the first meeting")

	var invalid := {
		"1": "m1_mirae_application",
		"2": "father_first_call",
		"3": "hyunsu_first_meet",
		"4": "m1_phone_off_sunday",
	}
	var invalid_result := CORE_LOOP.validate_plan(1, invalid)
	_expect(not bool(invalid_result.get("ok", false)),
		"week-four boss could be replaced")

	var schedule := _month_one_schedule()
	var committed := CORE_LOOP.commit_plan(1, schedule)
	_expect(bool(committed.get("ok", false)),
		"valid month-one schedule was rejected")
	_expect(CORE_LOOP.bundle_id_for_turn(4) == "first_temptation_boss",
		"week-four boss was not preserved in the committed schedule")
	_expect(CORE_LOOP.forgone_for_month(1).size() == 3,
		"month-one forgone ledger did not record exactly three closed offers")
	var pending_count := (
		GameState.core_loop_v2_state.get("pending_declines", []) as Array
	).size()
	var duplicate_commit := CORE_LOOP.commit_plan(1, schedule)
	_expect(not bool(duplicate_commit.get("ok", false)) \
			and str(duplicate_commit.get("error", "")) \
				== "plan_already_committed",
		"a committed month could be committed a second time")
	_expect(CORE_LOOP.forgone_for_month(1).size() == 3 \
			and (
				GameState.core_loop_v2_state.get("pending_declines", []) as Array
			).size() == pending_count,
		"duplicate plan commit created duplicate decline producers")

	_expect(CORE_LOOP.begin_bundle("m1_mirae_application", "schedule"),
		"application bundle could not begin")
	_expect(CORE_LOOP.note_action_commitment(
			_finalized_action_record("apply", {
				"application_id": "mirae_industrial_tech",
				"status": "submitted",
			})),
		"application result did not match its scheduled action")
	GameState.flags["opening_interview_application_sent"] = true
	GameState.flags["opening_interview_application_turn"] = 1
	CORE_LOOP.complete_active_bundle()
	_expect(CORE_LOOP.pending_consequence_id() == "",
		"interview consequence fired in the same week as the application")
	GameState.turn = 2
	_expect(CORE_LOOP.pending_consequence_id() == "opening_interview_math",
		"interview consequence did not unlock after an actual application")

	var saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	_expect(CORE_LOOP.is_active(),
		"prototype activation did not survive save/load")
	_expect(CORE_LOOP.plan_for_month(1).get("schedule", {}) == schedule,
		"month-one calendar did not survive save/load")
	_expect(CORE_LOOP.has_completed_bundle("m1_mirae_application"),
		"completed application did not survive save/load")

func _check_background_routines_once() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	var starting_money := float(GameState.money)
	var starting_intelligence := int(GameState.intelligence)
	_expect(bool(CORE_LOOP.commit_plan(
		1, _month_one_schedule(), _growth_routines()).get("ok", false)),
		"routine fixture could not commit month one")
	for week in range(1, 5):
		GameState.turn = week
		var first: Dictionary = CORE_LOOP.apply_background_routines_for_turn()
		_expect(bool(first.get("ok", false)) \
				and bool(first.get("applied", false)),
			"week %d did not apply its two background routine units" % week)
		var receipt: Dictionary = first.get("receipt", {})
		_expect((receipt.get("units", []) as Array).size() == 2,
			"week %d did not record exactly two routine units" % week)
		var money_after_first := float(GameState.money)
		var intelligence_after_first := int(GameState.intelligence)
		var repeated: Dictionary = CORE_LOOP.apply_background_routines_for_turn()
		_expect(bool(repeated.get("ok", false)) \
				and not bool(repeated.get("applied", true)),
			"week %d applied background routines more than once" % week)
		_expect(is_equal_approx(float(GameState.money), money_after_first) \
				and int(GameState.intelligence) == intelligence_after_first,
			"week %d duplicate routine call changed state" % week)

	GameState.turn = 5
	_expect(bool(CORE_LOOP.commit_plan(
		2, _month_two_legal_schedule(), _growth_routines()).get("ok", false)),
		"routine fixture could not commit month two")
	for week in range(5, 9):
		GameState.turn = week
		var result: Dictionary = CORE_LOOP.apply_background_routines_for_turn()
		_expect(bool(result.get("ok", false)) \
				and bool(result.get("applied", false)),
			"week %d did not apply its background routine units" % week)
		_expect(((result.get("receipt", {}) as Dictionary).get(
			"units", []) as Array).size() == 2,
			"week %d did not record exactly two routine units" % week)

	var receipts: Dictionary = GameState.core_loop_v2_state.get(
		"routine_receipts", {})
	var total_units := 0
	for raw_receipt in receipts.values():
		if raw_receipt is Dictionary:
			total_units += ((raw_receipt as Dictionary).get("units", []) as Array).size()
	_expect(receipts.size() == 8 and total_units == 16,
		"eight weeks did not produce exactly 16 durable routine units")
	_expect(is_equal_approx(
		float(GameState.money) - starting_money, 8.0 * 70_000.0),
		"livelihood background routine did not pay eight legal weekly units")
	_expect(int(GameState.intelligence) - starting_intelligence == 8,
		"growth background routine did not apply once per week")

	var saved: Dictionary = GameState.serialize()
	var money_before_reload := float(GameState.money)
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	var reloaded_repeat: Dictionary = \
		CORE_LOOP.apply_background_routines_for_turn(8)
	_expect(not bool(reloaded_repeat.get("applied", true)) \
			and is_equal_approx(float(GameState.money), money_before_reload),
		"routine once-only receipt did not survive save/load")

func _check_midmonth_employment_routine_transition() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	var planned := {
		"primary": "growth",
		"secondary": "recovery",
	}
	_expect(bool(CORE_LOOP.commit_plan(
		1, _month_one_schedule(), planned).get("ok", false)),
		"mid-month employment fixture could not commit its unemployed plan")
	GameState.turn = 1
	_expect(bool(CORE_LOOP.apply_background_routines_for_turn().get(
		"applied", false)),
		"pre-employment routines did not apply")
	GameState.current_job = {"id": "qa_midmonth_job"}
	GameState.turn = 2
	var result: Dictionary = CORE_LOOP.apply_background_routines_for_turn()
	var receipt: Dictionary = result.get("receipt", {})
	var units: Array = receipt.get("units", [])
	var applied_ids: Array[String] = []
	for raw_unit in units:
		if raw_unit is Dictionary:
			applied_ids.append(str((raw_unit as Dictionary).get(
				"routine_id", "")))
	_expect(bool(result.get("ok", false)) \
			and bool(result.get("applied", false)),
		"a job accepted mid-month invalidated the existing routine plan")
	_expect(bool(receipt.get("employment_forced", false)) \
			and str(receipt.get("primary", "")) == "livelihood" \
			and str(receipt.get("secondary", "")) == "growth",
		"mid-month employment did not replace the primary with the job obligation")
	_expect(applied_ids == ["livelihood", "growth"],
		"mid-month employment did not preserve the player's planned primary "
		+ "as the support routine")
	GameState.current_job = {}

func _check_decline_consumption_once() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	_expect(bool(CORE_LOOP.commit_plan(
		1, _month_one_schedule(), _growth_routines()).get("ok", false)),
		"decline fixture could not commit month one")
	var state_before: Dictionary = GameState.core_loop_v2_state
	_expect((state_before.get("pending_declines", []) as Array).size() == 3,
		"three unselected month-one offers did not create three decline producers")
	_expect(CORE_LOOP.process_due_decline_outcomes(0).is_empty(),
		"month-one decline outcomes resolved before the month closed")
	GameState.turn = 5
	var health_before := int(GameState.health)
	var mental_before := int(GameState.mental)
	var resolved: Array = CORE_LOOP.process_due_decline_outcomes(1)
	_expect(resolved.size() == 3,
		"month-one decline producers did not reach exactly three consumers")
	_expect(CORE_LOOP.decline_receipts_for_month(2).size() == 3,
		"next-month message ledger did not expose the three resolved outcomes")
	_expect(int(GameState.health) == health_before - 2 \
			and int(GameState.mental) == mental_before - 2,
		"missed recovery consequence did not apply its authored cost once")
	var health_after := int(GameState.health)
	var mental_after := int(GameState.mental)
	_expect(CORE_LOOP.process_due_decline_outcomes(1).is_empty(),
		"resolved decline outcomes were consumed twice")
	_expect(int(GameState.health) == health_after \
			and int(GameState.mental) == mental_after,
		"second decline-consumer pass changed player state")

	var saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	_expect(CORE_LOOP.decline_receipts_for_month(2).size() == 3,
		"decline consumer receipts did not survive save/load")
	_expect(CORE_LOOP.process_due_decline_outcomes(1).is_empty(),
		"save/load resurrected already consumed decline outcomes")

func _check_delayed_consequences_cross_month() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	CORE_LOOP.commit_plan(1, _month_one_schedule())
	GameState.turn = 1
	CORE_LOOP.begin_bundle("m1_mirae_application", "schedule")
	CORE_LOOP.note_action_commitment(_finalized_action_record("apply", {
		"application_id": "mirae_industrial_tech",
		"status": "submitted",
	}))
	GameState.flags["opening_interview_application_sent"] = true
	GameState.flags["opening_interview_application_turn"] = 1
	CORE_LOOP.complete_active_bundle()

	GameState.turn = 2
	_expect(CORE_LOOP.pending_consequence_id() == "opening_interview_math",
		"week-one application did not produce its in-month interview")
	CORE_LOOP.begin_bundle("opening_interview_math", "consequence")
	_expect(CORE_LOOP.note_story_choice("arc_intro_01_meal", 0),
		"opening interview did not advance the application to interviewed")
	CORE_LOOP.complete_active_bundle()
	_expect(CORE_LOOP.pending_consequence_id().is_empty(),
		"two consequence scenes stacked in the same week")

	GameState.turn = 4
	_expect(CORE_LOOP.pending_consequence_id().is_empty(),
		"application consequence displaced the locked week-four boss")
	CORE_LOOP.begin_bundle("first_temptation_boss", "schedule")
	CORE_LOOP.complete_active_bundle()

	GameState.turn = 5
	_expect(CORE_LOOP.pending_consequence_id() == "m2_mirae_result_message",
		"Mirae's interview result did not arrive in Week 5")
	CORE_LOOP.begin_bundle("m2_mirae_result_message", "consequence")
	_expect(CORE_LOOP.note_story_choice("v2_mirae_result_message", 0),
		"Mirae's result did not close the application as no-offer")
	CORE_LOOP.complete_active_bundle()
	_expect(CORE_LOOP.pending_consequence_id().is_empty(),
		"Mirae's result stacked with the later temptation consequence")
	GameState.turn = 7
	_expect(CORE_LOOP.pending_consequence_id().is_empty(),
		"one-month temptation consequence fired before Week 8")
	GameState.turn = 8
	_expect(CORE_LOOP.pending_consequence_id() == "temptation_consequence",
		"one-month temptation consequence did not mature in Week 8")

func _check_relationship_initiative() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	var relationship_contract: Dictionary = CORE_LOOP.contract().get(
		"relationship", {})
	_expect(CORE_LOOP.RELATIONSHIP_STAGE_ORDER \
			== relationship_contract.get("stages", []),
		"runtime relationship order drifted from the canonical monotonic stages")
	_expect(not CORE_LOOP.available_offer_ids(2).has("hyunsu_player_reachout"),
		"relationship pursuit appeared before meeting Hyunsu")
	GameState.turn = 2
	CORE_LOOP.begin_bundle("hyunsu_first_meet", "schedule")
	CORE_LOOP.complete_active_bundle()
	_expect(CORE_LOOP.relationship_stage("hyunsu") == "unmet",
		"bundle completion advanced Hyunsu without an actual scene choice")
	_expect(not CORE_LOOP.available_offer_ids(2).has("hyunsu_player_reachout"),
		"completion-only meeting opened a relationship pursuit")
	CORE_LOOP.begin_bundle("hyunsu_first_meet", "schedule")
	var meeting_choice_noted := CORE_LOOP.note_story_choice(
		"arc_intro_04_hyunsu", 0)
	_expect(meeting_choice_noted,
		"Hyunsu's actual first-meeting choice was not consumed "
		+ "(active=%s outcomes=%s)" % [
			CORE_LOOP.active_bundle_id(),
			CORE_LOOP.bundle("hyunsu_first_meet").get(
				"relationship_outcomes", []),
		])
	CORE_LOOP.complete_active_bundle()
	_expect(CORE_LOOP.relationship_stage("hyunsu") == "opening",
		"first-meeting choice did not persist the authored opening stage")
	_expect(not CORE_LOOP.was_player_initiated("hyunsu"),
		"chance meeting was misrecorded as player initiation")
	_expect(CORE_LOOP.available_offer_ids(2).has("hyunsu_player_reachout"),
		"player follow-up did not open after meeting Hyunsu")
	GameState.turn = 5
	CORE_LOOP.begin_bundle("hyunsu_player_reachout", "schedule")
	CORE_LOOP.complete_active_bundle()
	_expect(CORE_LOOP.relationship_stage("hyunsu") == "opening",
		"follow-up bundle completion advanced the relationship without a choice")
	_expect(not CORE_LOOP.was_player_initiated("hyunsu"),
		"completion-only follow-up was misrecorded as player initiative")
	CORE_LOOP.begin_bundle("hyunsu_player_reachout", "schedule")
	_expect(CORE_LOOP.note_story_choice("v2_hyunsu_first_study", 1),
		"Hyunsu's actual first study choice was not consumed")
	var history_size_after_choice := (
		GameState.core_loop_v2_state.get("relationship_history", []) as Array
	).size()
	_expect(CORE_LOOP.note_story_choice("v2_hyunsu_first_study", 1) \
			and (
				GameState.core_loop_v2_state.get(
					"relationship_history", []) as Array
			).size() == history_size_after_choice,
		"the same story result created duplicate relationship history")
	CORE_LOOP.complete_active_bundle()
	_expect(CORE_LOOP.relationship_stage("hyunsu") == "player_reached_out",
		"proactive message did not advance the relationship stage")
	_expect(CORE_LOOP.was_player_initiated("hyunsu"),
		"proactive message was not recorded as the player's action")
	CORE_LOOP.begin_bundle("hyunsu_first_meet", "schedule")
	_expect(not CORE_LOOP.note_story_choice("arc_intro_04_hyunsu", 0),
		"an earlier relationship choice was allowed to move the stage backward")
	_expect(CORE_LOOP.relationship_stage("hyunsu") == "player_reached_out",
		"relationship stage regressed after replaying an earlier choice")
	CORE_LOOP.cancel_active_bundle()

func _check_month_summary_durability() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	CORE_LOOP.commit_plan(1, _month_one_schedule(), _growth_routines())
	GameState.turn = 5
	var before := {
		"money": 500_000.0,
		"health": 78,
		"mental": 63,
		"fixed_expense": 650_000.0,
		"monthly_income": 0.0,
	}
	var after := {
		"money": 60_000.0,
		"health": 74,
		"mental": 59,
	}
	var summary: Dictionary = CORE_LOOP.record_month_summary(
		1, before, after, {"next_rung": "one_month_buffer"})
	_expect(int(summary.get("month", 0)) == 1 \
			and not bool(summary.get("acknowledged", true)),
		"month summary was not recorded as a pending durable recap")
	_expect(is_equal_approx(float(summary.get("fixed_expense", 0.0)), 650_000.0),
		"month summary lost its fixed-expense evidence")
	var saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	var pending: Dictionary = CORE_LOOP.pending_month_summary()
	_expect(int(pending.get("month", 0)) == 1 \
			and str(pending.get("next_rung", "")) == "one_month_buffer",
		"unacknowledged month summary did not survive save/load")
	_expect(CORE_LOOP.acknowledge_month_summary(1),
		"month summary could not be acknowledged")
	_expect(CORE_LOOP.pending_month_summary().is_empty(),
		"acknowledged month summary reopened immediately")
	var acknowledged_save: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(acknowledged_save)
	_expect(bool(CORE_LOOP.month_summary(1).get("acknowledged", false)) \
			and CORE_LOOP.pending_month_summary().is_empty(),
		"month summary acknowledgment did not survive save/load")

func _check_story_followup_suppression() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	var opening_roots := CORE_LOOP.resolved_event_roots(
		"opening_interview_math")
	var opening_bundle := CORE_LOOP.bundle("opening_interview_math")
	_expect(opening_roots == [
			"arc_intro_01_meal", "v2_opening_return_math"],
		"opening_interview_math no longer owns adjacent interview and "
		+ "calculation roots")
	_expect(opening_bundle.get("suppress_follow_up_events", []) \
			== ["arc_intro_02_dad_call"],
		"opening bundle suppressed something other than the legacy separate "
		+ "125-year card")
	var interview_event: Dictionary = DataRegistry.find_event(
		"arc_intro_01_meal")
	var interview_choices: Array = interview_event.get("choices", [])
	_expect(interview_choices.size() == 2,
		"opening interview lost its two authored responses")
	CORE_LOOP.prepare_story_bundle("opening_interview_math")
	for choice_index in range(interview_choices.size()):
		var interview_choice: Dictionary = interview_choices[choice_index]
		_expect(str(interview_choice.get("follow_up_event", "")) \
				== "arc_intro_02_dad_call" \
				and CORE_LOOP.story_follow_up_is_suppressed(
					"arc_intro_01_meal", choice_index,
					"arc_intro_02_dad_call"),
			"opening choice %d did not suppress only its legacy auto-follow-up" \
				% choice_index)
	CORE_LOOP.restore_story_bundle_followups()
	for choice_index in range(interview_choices.size()):
		_expect(not CORE_LOOP.story_follow_up_is_suppressed(
				"arc_intro_01_meal", choice_index,
				"arc_intro_02_dad_call"),
			"opening suppression receipt %d survived story return" \
				% choice_index)

	var event: Dictionary = DataRegistry.find_event("arc_intro_04_hyunsu")
	var choices: Array = event.get("choices", [])
	_expect(not choices.is_empty(), "Hyunsu first meeting has no choices")
	if choices.is_empty():
		return
	_expect(str((choices[0] as Dictionary).get("follow_up_event", "")) \
			== "arc_chapter1_close",
		"Hyunsu first meeting baseline follow-up drifted")
	CORE_LOOP.prepare_story_bundle("hyunsu_first_meet")
	_expect(str((choices[0] as Dictionary).get("follow_up_event", "")) \
			== "arc_chapter1_close" \
			and CORE_LOOP.story_follow_up_is_suppressed(
				"arc_intro_04_hyunsu", 0, "arc_chapter1_close"),
		"V2 suppression receipt did not block the legacy auto-closing "
		+ "without mutating event data")
	CORE_LOOP.restore_story_bundle_followups()
	_expect(str((choices[0] as Dictionary).get("follow_up_event", "")) \
			== "arc_chapter1_close" \
			and not CORE_LOOP.story_follow_up_is_suppressed(
				"arc_intro_04_hyunsu", 0, "arc_chapter1_close"),
		"V2 follow-up suppression receipt was not cleared after the scene")

func _check_branch_resolution() -> void:
	GameState.start_new_game()
	GameState.flags["lent_account"] = false
	_expect(CORE_LOOP.resolved_event_roots("temptation_consequence") \
			== ["arc_temptation_clean"],
		"clean temptation branch resolved to the wrong scene")
	GameState.flags["lent_account"] = true
	_expect(CORE_LOOP.resolved_event_roots("temptation_consequence") \
			== ["arc_temptation_fallout"],
		"fallen temptation branch resolved to the wrong scene")

func _check_prototype_completion_boundary() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	_expect(bool(CORE_LOOP.commit_plan(1, _month_one_schedule()).get("ok", false)),
		"completion fixture could not commit month one")
	for week in range(1, 5):
		GameState.turn = week
		var bundle_id := CORE_LOOP.bundle_id_for_turn()
		_expect(CORE_LOOP.begin_bundle(bundle_id, "schedule"),
			"completion fixture could not begin week %d" % week)
		if bundle_id == "father_first_call":
			_expect(CORE_LOOP.note_story_choice("arc_father_01_call", 0),
				"completion fixture could not record Father's first call")
		elif bundle_id == "hyunsu_first_meet":
			_expect(CORE_LOOP.note_story_choice("arc_intro_04_hyunsu", 0),
				"completion fixture could not record Hyunsu's meeting choice")
		_expect(_record_fixture_action(bundle_id),
			"completion fixture could not record week %d action" % week)
		_expect(CORE_LOOP.complete_active_bundle() == bundle_id,
			"completion fixture could not complete week %d" % week)

	GameState.turn = 5
	var month_two_schedule := {
		"5": "hyunsu_player_reachout",
		"6": "m2_seorin_application",
		"7": "m2_rain_delivery_shift",
		"8": "m2_sleep_debt_sunday",
	}
	_expect(bool(CORE_LOOP.commit_plan(2, month_two_schedule).get("ok", false)),
		"completion fixture could not commit month two")
	for week in range(5, 9):
		GameState.turn = week
		var bundle_id := CORE_LOOP.bundle_id_for_turn()
		_expect(CORE_LOOP.begin_bundle(bundle_id, "schedule"),
			"completion fixture could not begin week %d" % week)
		if bundle_id == "hyunsu_player_reachout":
			_expect(CORE_LOOP.note_story_choice(
				"v2_hyunsu_first_study", 0),
				"completion fixture could not record Hyunsu's first study choice")
		_expect(_record_fixture_action(bundle_id),
			"completion fixture could not record week %d action" % week)
		_expect(CORE_LOOP.complete_active_bundle() == bundle_id,
			"completion fixture could not complete week %d" % week)

	GameState.turn = 9
	var month_three_schedule := {
		"9": "m3_hanbit_application",
		"10": "m3_inventory_shift",
		"11": "daeun_world_meet",
		"12": "father_quiet_call",
	}
	_expect(bool(CORE_LOOP.commit_plan(
			3, month_three_schedule, _growth_routines()).get("ok", false)),
		"completion fixture could not commit month three")
	for week in range(9, 13):
		GameState.turn = week
		var bundle_id := CORE_LOOP.bundle_id_for_turn()
		_expect(CORE_LOOP.begin_bundle(bundle_id, "schedule"),
			"completion fixture could not begin week %d" % week)
		if bundle_id == "daeun_world_meet":
			_expect(CORE_LOOP.note_story_choice("arc_daeun_01_meet", 0),
				"completion fixture could not record Daeun's first meeting")
		elif bundle_id == "father_quiet_call":
			_expect(CORE_LOOP.note_story_choice("arc_father_quiet_call", 2),
				"completion fixture could not record Father's longer call")
		_expect(_record_fixture_action(bundle_id),
			"completion fixture could not record week %d action" % week)
		_expect(CORE_LOOP.complete_active_bundle() == bundle_id,
			"completion fixture could not complete week %d" % week)

	GameState.flags["lent_account"] = true
	GameState.flags["escaped_dirty_money"] = true
	_expect(not CORE_LOOP.mark_prototype_complete(),
		"prototype closed before the week-twenty-four month-end rollover")
	GameState.turn = 13
	_expect(not CORE_LOOP.mark_prototype_complete(),
		"week 13 incorrectly marked the extended build complete")
	_expect(not CORE_LOOP.is_prototype_complete() and CORE_LOOP.is_active(),
		"completed B commitments did not continue into month four")

	var snapshot := CORE_LOOP.completion_snapshot()
	_expect((snapshot.get("kept", []) as Array).size() == 12,
		"completion recap did not retain all twelve scheduled commitments")
	_expect((snapshot.get("forgone", []) as Array).size() == 9,
		"completion recap did not retain the nine named closed opportunities")
	_expect((snapshot.get("player_initiated", []) as Array).has("hyunsu"),
		"completion recap lost the player's relationship initiative")
	_expect(str(snapshot.get("temptation_branch", "")) == "returned_money",
		"completion recap did not resolve the temptation branch")

	var saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	CORE_LOOP.initialize_for_run()
	_expect(not CORE_LOOP.is_prototype_complete() and CORE_LOOP.is_active(),
		"week-12 continuation did not survive save/load")
	_expect(GameState.turn == 13,
		"week-12 continuation save did not remain at week 13")

func _check_planner_surface() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	LocaleManager.language = "en"
	GameState.money = -310_000.0

	var planner = PLANNER.new()
	var commits: Array[Dictionary] = []
	var communication_requests: Array[String] = []
	var close_receipts: Array[bool] = []
	planner.plan_committed.connect(func(
			month_index: int, schedule: Dictionary,
			routines: Dictionary) -> void:
		commits.append({
			"month": month_index,
			"schedule": schedule.duplicate(true),
			"routines": routines.duplicate(true),
		}))
	planner.communication_requested.connect(func(bundle_id: String) -> void:
		communication_requests.append(bundle_id))
	planner.planner_closed.connect(func() -> void:
		close_receipts.append(true))
	add_child(planner)
	planner.set_anchors_preset(Control.PRESET_TOP_LEFT)
	planner.position = Vector2.ZERO
	planner.size = Vector2(1280, 800)
	_expect(planner.open(1), "wide planner did not open month one")
	await get_tree().create_timer(0.35).timeout
	# LocaleManager loads the saved setting on a deferred first frame. Pin EN
	# after that handoff so a clean QA HOME cannot turn the fixture back to KO.
	LocaleManager.set_language("en")
	await get_tree().process_frame

	_expect(planner.visible and planner._active_tab == 1,
		"wide planner did not start on Calendar")
	_expect(planner._step_buttons.size() == 3 \
			and planner._overview_button.text == "OVERVIEW" \
			and planner._people_button.text == "PEOPLE" \
			and planner._step_buttons[0].text.find("WEEKS 1/4") >= 0 \
			and planner._step_buttons[1].text.find("ROUTINES 2/2") >= 0 \
			and planner._step_buttons[2].text.find("3 WEEKS LEFT") >= 0,
		"wide planner did not expose one truthful three-step workflow rail")
	_expect(planner._slot_buttons.size() == 4 \
			and planner._offer_buttons.size() == 6,
		"wide planner did not expose four weeks and six month-one options")
	_expect(str(planner._routine_summary_label.text).find(
			"RECOMMENDED DEFAULTS APPLIED") >= 0 \
			and planner._routine_edit_button.text == "CHANGE",
		"first month did not disclose its applied routine defaults and Change action")
	planner._routine_edit_button.pressed.emit()
	await get_tree().process_frame
	_expect(planner._active_tab == 3 and planner._workflow_step == 1 \
			and _focused_planner_control(planner) \
				== planner._routine_buttons.get("primary:livelihood"),
		"the visible Change action did not open weekly activities on the current primary routine")
	planner._step_buttons[0].pressed.emit()
	await get_tree().process_frame
	_expect(planner._active_tab == 1 and planner._workflow_step == 0,
		"the real schedule-step action did not return from Change")
	_expect(planner._offer_scroll.follow_focus \
			and planner._calendar_scroll.follow_focus \
			and planner._offer_scroll.horizontal_scroll_mode \
				== ScrollContainer.SCROLL_MODE_DISABLED \
			and planner._calendar_scroll.horizontal_scroll_mode \
				== ScrollContainer.SCROLL_MODE_DISABLED,
		"wide planner lost controller focus-following vertical scroll")
	_expect(planner._page_margin.get_theme_constant("margin_left") == 42 \
			and planner._calendar_right_column.custom_minimum_size.x >= 419.0,
		"1280x800 planner did not preserve its wide margins or four-week column")
	var wide_offer_rect: Rect2 = planner._offer_scroll.get_global_rect()
	var wide_week_rect: Rect2 = planner._calendar_scroll.get_global_rect()
	var wide_planner_rect: Rect2 = planner.get_global_rect()
	var wide_week_end := wide_week_rect.position + wide_week_rect.size
	var wide_planner_end := wide_planner_rect.position + wide_planner_rect.size
	_expect(wide_offer_rect.position.x < wide_week_rect.position.x \
			and wide_week_rect.size.x >= 400.0 \
			and wide_week_end.x <= wide_planner_end.x + 0.5 \
			and wide_week_end.y <= wide_planner_end.y + 0.5,
		"wide planner columns escaped or overlapped the 1280x800 surface")

	var surface_samples: Array[String] = []
	planner._overview_button.pressed.emit()
	await get_tree().process_frame
	var status_text := _collect_surface_text(planner)
	surface_samples.append(status_text)
	_expect(not planner._read_only_focus_controls.is_empty() \
			and _focus_neighbor(planner._overview_button, "focus_neighbor_bottom") \
				== planner._read_only_focus_controls[0] \
			and _focus_neighbor(
				planner._read_only_focus_controls[-1], "focus_neighbor_bottom") \
				== planner._overview_button,
		"incomplete Overview did not loop around its inspectable D-pad path")
	_expect(planner._hint_label.text.find("Continue in Step 1") >= 0 \
			and planner._hint_label.text.find("Remove on Week") < 0,
		"incomplete Overview advertised a Calendar-only action")
	planner._read_only_focus_controls[-1].grab_focus()
	await _press_planner_pad(JOY_BUTTON_DPAD_DOWN)
	_expect(_focused_planner_control(planner) == planner._overview_button,
		"incomplete Overview D-pad path entered the disabled Review button")
	_expect(status_text.find("CURRENT DATE") >= 0 \
			and status_text.find("ACCOUNT BALANCE") >= 0 \
			and status_text.find("NEXT FIXED COST") >= 0 \
			and status_text.find("ARREARS") >= 0 \
			and status_text.find(GameState.format_money(310_000.0)) >= 0,
		"Overview did not expose date, balance, fixed cost, and arrears clearly")
	for retired_label in [
		"DEVICE", "PURCHASE PHONE", "FAVORITE APP", "STARTER PHONE",
		"REFURBISHED PHONE",
	]:
		_expect(status_text.find(retired_label) < 0,
			"Overview leaked retired phone ownership UI: %s" % retired_label)

	planner._people_button.pressed.emit()
	await get_tree().process_frame
	var initial_people := _collect_surface_text(planner)
	surface_samples.append(initial_people)
	_expect(not planner._read_only_focus_controls.is_empty() \
			and _focus_neighbor(planner._people_button, "focus_neighbor_bottom") \
				== planner._read_only_focus_controls[0] \
			and _focus_neighbor(
				planner._read_only_focus_controls[-1], "focus_neighbor_bottom") \
				== planner._people_button,
		"incomplete People did not loop around its inspectable D-pad path")
	_expect(planner._hint_label.text.find("Continue in Step 1") >= 0 \
			and planner._hint_label.text.find("Remove on Week") < 0,
		"incomplete People advertised a Calendar-only action")
	planner._read_only_focus_controls[-1].grab_focus()
	await _press_planner_pad(JOY_BUTTON_DPAD_DOWN)
	_expect(_focused_planner_control(planner) == planner._people_button,
		"incomplete People D-pad path entered the disabled Review button")
	_expect(initial_people.find("Father") >= 0,
		"People did not show Father's already-saved number")
	for hidden_name in ["Hyunsu", "Kim Daeun", "Han Jiyeon"]:
		_expect(initial_people.find(hidden_name) < 0,
			"People revealed an unmet or unnamed person: %s" % hidden_name)

	planner._step_buttons[1].pressed.emit()
	await get_tree().process_frame
	surface_samples.append(_collect_surface_text(planner))
	_expect(planner._hint_label.text.find("D-pad Weekly Activities") >= 0 \
			and planner._hint_label.text.find("Remove on Week") < 0,
		"incomplete Routine advertised a Calendar-only action")
	var last_incomplete_routine_control: Control = (
		planner._read_only_focus_controls[-1]
		if not planner._read_only_focus_controls.is_empty()
		else planner._routine_focus_rows[-1][0] as Control)
	_expect(_focus_neighbor(
			last_incomplete_routine_control, "focus_neighbor_bottom") \
			== planner._step_buttons[1],
		"incomplete Routine path entered the disabled Review button")

	var planning_state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	var state: Dictionary = planning_state.duplicate(true)
	state["completed_bundles"] = ["hyunsu_first_meet"]
	state["relationship_stages"] = {
		"hyunsu": "opening",
		"daeun": "opening",
		"jiyeon": "opening",
	}
	state["relationship_memories"] = [{
		"character": "hyunsu",
		"memory": "hyunsu_honest_uncertainty",
	}]
	GameState.core_loop_v2_state = state
	planner._people_button.pressed.emit()
	await get_tree().process_frame
	var earned_people := _collect_surface_text(planner)
	surface_samples.append(earned_people)
	_expect(earned_people.find("Hyunsu") >= 0 \
			and earned_people.find("KAKAOTALK THREAD") >= 0,
		"People did not preserve Hyunsu's earned contact")
	_expect(earned_people.find("24-Hour Store Night Clerk") >= 0 \
			and earned_people.find("Kim Daeun") < 0 \
			and earned_people.find("Black-Sedan Driver") >= 0 \
			and earned_people.find("Han Jiyeon") < 0,
		"People revealed Daeun or Jiyeon's name before name exchange")
	var memories: Array = state.get("relationship_memories", [])
	memories.append({
		"character": "daeun",
		"memory": "daeun_name_exchanged",
	})
	state["relationship_memories"] = memories
	GameState.core_loop_v2_state = state
	planner._people_button.pressed.emit()
	await get_tree().process_frame
	_expect(_collect_surface_text(planner).find("Kim Daeun") >= 0,
		"People did not remember Daeun's name after the authored exchange")

	GameState.core_loop_v2_state = planning_state
	planner._step_buttons[0].pressed.emit()
	await _check_planner_offer_then_week(planner)
	await _check_planner_controller_regressions(planner, commits)
	_expect(planner.assign_offer_to_week("m1_mirae_application", 1),
		"planner could not schedule the application")
	_expect(planner.assign_offer_to_week("father_first_call", 2),
		"planner could not schedule the father call")
	_expect(planner.assign_offer_to_week("hyunsu_first_meet", 3),
		"planner could not schedule the Hyunsu meeting")
	_expect(not planner.unassign_week(4),
		"planner allowed the fixed week-four event to be removed")
	var schedule_before_east: Dictionary = planner.schedule_snapshot()
	var east_event := InputEventAction.new()
	east_event.action = "ui_cancel"
	east_event.pressed = true
	planner._unhandled_input(east_event)
	_expect(planner.visible \
			and planner.schedule_snapshot() == schedule_before_east,
		"East changed or closed the required editable monthly plan")
	var routines_before_blocker: Dictionary = planner.routine_snapshot()
	planner._routines["secondary"] = ""
	planner._rebuild()
	_expect(str(planner._step_buttons[1].text).find("ROUTINES 1/2") >= 0 \
			and str(planner._step_buttons[2].text).find("1 ROUTINE LEFT") >= 0 \
			and planner._confirm_button.disabled,
		"one missing weekly activity did not appear in the rail or block review")
	planner._routines = routines_before_blocker
	planner._rebuild()

	planner._step_buttons[1].pressed.emit()
	await get_tree().process_frame
	var primary_growth := planner._routine_buttons.get(
		"primary:growth") as Button
	_expect(is_instance_valid(primary_growth),
		"weekly-activity surface lost its primary Growth button")
	if is_instance_valid(primary_growth):
		primary_growth.pressed.emit()
		await get_tree().process_frame
	var secondary_livelihood := planner._routine_buttons.get(
		"secondary:livelihood") as Button
	_expect(is_instance_valid(secondary_livelihood),
		"weekly-activity surface lost its secondary Livelihood button")
	if is_instance_valid(secondary_livelihood):
		secondary_livelihood.pressed.emit()
		await get_tree().process_frame
	_expect(planner.routine_snapshot() == {
			"primary": "growth", "secondary": "livelihood",
		}, "real routine-button wiring did not choose two distinct weekly activities")
	_expect(str(planner._routine_summary_label.text).find(
			"RECOMMENDED DEFAULTS APPLIED") < 0,
		"an intentional routine choice remained mislabeled as an automatic default")
	var schedule: Dictionary = planner.schedule_snapshot()
	_expect(schedule.size() == 4 \
			and str(schedule.get("4", "")) == "first_temptation_boss",
		"planner did not preserve all four weeks and the fixed boss event")
	_expect(str(planner._step_buttons[0].text).find("WEEKS 4/4") >= 0 \
			and str(planner._step_buttons[1].text).find("ROUTINES 2/2") >= 0 \
			and str(planner._step_buttons[2].text).find("READY") >= 0 \
			and not planner._confirm_button.disabled,
		"workflow rail did not match the canonical ready-to-confirm state")

	planner._switch_workflow_step(2)
	await get_tree().process_frame
	var record_text := _collect_surface_text(planner)
	surface_samples.append(record_text)
	_expect(record_text.find("THIS MONTH'S PLAN") >= 0 \
			and record_text.find("TWO THINGS TO KEEP UP EACH WEEK") >= 0 \
			and record_text.find("OPTIONS LEFT OUT") >= 0,
		"Record did not explain routines, scheduled work, and options left out")
	_expect(planner._hint_label.text.find("UP/DOWN Review") >= 0 \
			and planner._hint_label.text.find("Remove on Week") < 0,
		"Record advertised a Calendar-only remove command instead of scroll/review")
	var first_routine_control: Control = planner._routine_focus_rows[0][0]
	var last_routine_row: Array = planner._routine_focus_rows[-1]
	var last_record_control: Control = planner._read_only_focus_controls[-1]
	_expect(_focus_neighbor(planner._step_buttons[2], "focus_neighbor_bottom") \
			== first_routine_control \
			and _focus_neighbor(
				last_routine_row[0] as Control, "focus_neighbor_bottom") \
				== planner._read_only_focus_controls[0] \
			and _focus_neighbor(last_record_control, "focus_neighbor_bottom") \
				== planner._confirm_button \
			and _focus_neighbor(planner._confirm_button, "focus_neighbor_top") \
				== last_record_control,
		"Routine grid, inspectable record, and footer were not one D-pad path")
	planner._step_buttons[0].pressed.emit()
	planner._communication_button.pressed.emit()
	_expect(communication_requests.size() == 1 \
			and communication_requests[0] == planner._selected_offer_id \
			and planner.visible,
		"planner did not request the separate communication phone without closing")
	var p_event := InputEventKey.new()
	p_event.keycode = KEY_P
	p_event.physical_keycode = KEY_P
	p_event.pressed = true
	get_viewport().push_input(p_event)
	await get_tree().process_frame
	var north_event := InputEventJoypadButton.new()
	north_event.button_index = JOY_BUTTON_Y
	north_event.pressed = true
	get_viewport().push_input(north_event)
	await get_tree().process_frame
	_expect(communication_requests.size() == 3 \
			and planner.visible,
		"P/North did not open the separate communication phone from the planner")

	var planner_validation: Dictionary = CORE_LOOP.validate_plan(
		1, planner.schedule_snapshot(), planner.routine_snapshot())
	_expect(bool(planner_validation.get("ok", false)),
		"planner fixture was not valid before review: %s" % planner_validation)
	planner._commit_plan()
	await get_tree().process_frame
	_expect(planner.review_pending() and planner._active_tab == 3 \
			and planner._workflow_step == 2 \
			and commits.is_empty(),
		"first confirmation skipped the explicit review step")
	var review_text := _collect_surface_text(planner)
	surface_samples.append(review_text)
	_expect(review_text.find("REVIEW PLAN") >= 0 \
			and review_text.find("OPTIONS LEFT OUT") >= 0,
		"review step did not disclose the plan and forgone options")
	var last_review_control: Control = planner._read_only_focus_controls[-1]
	_expect(_focus_neighbor(planner._confirm_button, "focus_neighbor_top") \
			== last_review_control \
			and _focus_neighbor(planner._edit_button, "focus_neighbor_top") \
				== last_review_control,
		"review footer did not follow the last inspectable review section")
	var schedule_before_phone_focus: Dictionary = planner.schedule_snapshot()
	_expect(planner.focus_offer("father_first_call") \
			and not planner.review_pending() \
			and planner._active_tab == 1 \
			and planner._workflow_step == 0 \
			and planner.schedule_snapshot() == schedule_before_phone_focus \
			and _planner_armed_offer_id(planner).is_empty(),
		"Phone VIEW PLAN preserved a stale final-confirm state on Calendar")
	planner._commit_plan()
	await get_tree().process_frame
	last_review_control = planner._read_only_focus_controls[-1]
	_expect(planner.review_pending() and planner._active_tab == 3 \
			and planner._workflow_step == 2 \
			and _focus_neighbor(planner._confirm_button, "focus_neighbor_top") \
				== last_review_control,
		"review could not be re-entered safely after Phone VIEW PLAN: pending=%s tab=%s neighbor=%s path=%s expected=%s" % [
			planner.review_pending(), planner._active_tab,
			_focus_neighbor(planner._confirm_button, "focus_neighbor_top"),
			planner._confirm_button.focus_neighbor_top,
			planner._confirm_button.get_path_to(last_review_control),
		])
	planner._commit_plan()
	_expect(commits.is_empty(),
		"review accepted the same confirmation input before a fresh release")
	await get_tree().create_timer(0.42).timeout
	await get_tree().process_frame
	await _click_planner_control(planner._confirm_button, true)
	_expect(commits.is_empty() and planner._review_mouse_double_click_blocked,
		"a 420ms mouse double-click bypassed the review confirmation gate")
	await _click_planner_control(planner._confirm_button)
	_expect(commits.size() == 1 \
			and int(commits[0].get("month", 0)) == 1,
		"a fresh single click after the blocked double-click did not emit one plan")
	if commits.is_empty():
		planner.queue_free()
		await get_tree().process_frame
		return

	var commit_payload: Dictionary = commits[0]
	var committed := CORE_LOOP.commit_plan(
		1,
		commit_payload.get("schedule", {}) as Dictionary,
		commit_payload.get("routines", {}) as Dictionary)
	_expect(bool(committed.get("ok", false)),
		"planner payload could not be committed by its MainGame owner")
	var committed_schedule: Dictionary = (
		CORE_LOOP.plan_for_month(1).get("schedule", {}) as Dictionary
	).duplicate(true)
	var committed_routines: Dictionary = (
		CORE_LOOP.plan_for_month(1).get("routines", {}) as Dictionary
	).duplicate(true)
	var post_commit_state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	post_commit_state["application_statuses"][
		"mirae_industrial_tech"] = "interviewed"
	GameState.core_loop_v2_state = post_commit_state
	planner._cancel_commit_review()
	planner._assign_offer("father_first_call")
	_expect(_planner_armed_offer_id(planner) == "father_first_call",
		"editable planner could not arm an offer before read-only reopen")
	_expect(planner.open(1, true) and planner.read_only_plan() \
			and planner.schedule_snapshot() == committed_schedule \
			and planner.routine_snapshot() == committed_routines \
			and _planner_armed_offer_id(planner).is_empty() \
			and str(planner._step_buttons[0].text).find("WEEKS 4/4 · DONE") >= 0 \
			and str(planner._step_buttons[2].text).find("CONFIRMED") >= 0 \
			and not planner._edit_button.visible \
			and _focus_neighbor(
				planner._confirm_button, "focus_neighbor_left") \
					!= planner._edit_button,
		"confirmed-plan reopen changed its historical progress or focus graph")
	var read_only_before: Dictionary = planner.schedule_snapshot()
	planner._assign_offer("m1_phone_off_sunday")
	planner._select_week(1)
	_expect(not planner.assign_offer_to_week("m1_phone_off_sunday", 1) \
			and not planner.unassign_week(2) \
			and not planner.select_routine("primary", "recovery") \
			and planner.schedule_snapshot() == read_only_before \
			and planner.routine_snapshot() == committed_routines,
		"read-only planner changed an immutable monthly promise")
	_expect(_planner_armed_offer_id(planner).is_empty(),
		"read-only planner armed an offer or retained a stale intent")

	planner.size = Vector2(960, 600)
	planner._apply_responsive_layout()
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(planner._compact_layout \
			and planner._page_margin.get_theme_constant("margin_left") == 24 \
			and planner._calendar_right_column.custom_minimum_size.x >= 339.0 \
			and planner._calendar_right_column.custom_minimum_size.x <= 341.0,
		"960x600 planner did not enter its compact layout")
	var compact_week_rect: Rect2 = planner._calendar_scroll.get_global_rect()
	var compact_planner_rect: Rect2 = planner.get_global_rect()
	var compact_end := compact_week_rect.position + compact_week_rect.size
	var compact_planner_end := compact_planner_rect.position \
		+ compact_planner_rect.size
	var compact_page_rect: Rect2 = planner._page.get_global_rect()
	_expect(compact_week_rect.size.x >= 320.0 \
			and compact_end.x <= compact_planner_end.x + 0.5 \
			and compact_end.y <= compact_planner_end.y + 0.5 \
			and compact_page_rect.position.x \
				>= compact_planner_rect.position.x + 23.5 \
			and compact_page_rect.end.x \
				<= compact_planner_end.x - 23.5,
		"compact planner content escaped its 960x600 safe margins")

	planner._overview_button.pressed.emit()
	await get_tree().process_frame
	surface_samples.append(_collect_surface_text(planner))
	planner._overview_button.grab_focus()
	for _index in range(planner._read_only_focus_controls.size()):
		await _press_planner_pad(JOY_BUTTON_DPAD_DOWN)
	_expect(_focused_planner_control(planner) \
			== planner._read_only_focus_controls[-1] \
			and _focus_neighbor(
				planner._read_only_focus_controls[-1], "focus_neighbor_bottom") \
				== planner._confirm_button,
		"960x600 Overview rows were not traversable by D-pad to the footer")
	planner._people_button.pressed.emit()
	await get_tree().process_frame
	surface_samples.append(_collect_surface_text(planner))
	planner._people_button.grab_focus()
	for _index in range(planner._read_only_focus_controls.size()):
		await _press_planner_pad(JOY_BUTTON_DPAD_DOWN)
	_expect(_focused_planner_control(planner) \
			== planner._read_only_focus_controls[-1] \
			and _focus_neighbor(
				planner._read_only_focus_controls[-1], "focus_neighbor_bottom") \
				== planner._confirm_button,
		"960x600 People rows were not traversable by D-pad to the footer")
	planner._step_buttons[2].pressed.emit()
	await get_tree().process_frame
	surface_samples.append(_collect_surface_text(planner))
	planner._step_buttons[2].grab_focus()
	planner._read_only_scroll.scroll_vertical = 0
	for _index in range(planner._read_only_focus_controls.size()):
		await _press_planner_pad(JOY_BUTTON_DPAD_DOWN)
	var compact_scroll_bar: VScrollBar = planner._read_only_scroll.get_v_scroll_bar()
	_expect(not planner._read_only_focus_controls.is_empty() \
			and _focused_planner_control(planner) \
				== planner._read_only_focus_controls[-1] \
			and compact_scroll_bar.max_value > compact_scroll_bar.page \
			and planner._read_only_scroll.scroll_vertical > 0,
		"960x600 record could not reach and reveal its final section by D-pad")
	var surface_text := "\n".join(surface_samples)
	_expect(not _contains_hangul(surface_text),
		"English planner surface leaked Hangul: %s" % surface_text)
	for forbidden in [
		"ACTION POINT", "AFFINITY", "MORAL", "행동력", "호감도", "도덕",
	]:
		_expect(surface_text.to_upper().find(forbidden.to_upper()) < 0,
			"planner exposed hidden system language: %s" % forbidden)

	planner._step_buttons[2].grab_focus()
	planner._confirm_button.pressed.emit()
	_expect(not planner.visible and close_receipts.size() == 1,
		"read-only planner did not close once and return control")
	_expect(planner.open(1, true),
		"read-only planner did not reopen for focus-reset regression")
	await get_tree().process_frame
	await get_tree().process_frame
	var reopened_focus := _focused_planner_control(planner)
	_expect(planner._active_tab == 1 and planner._workflow_step == 0 \
			and is_instance_valid(reopened_focus) \
			and reopened_focus.has_meta("core_loop_v2_offer_id") \
			and planner._offer_buttons.values().has(reopened_focus),
		"same-month reopen restored Step 3 focus over the active Step 1 surface: key=%s owner=%s" % [
			planner._current_focus_key(),
			str(reopened_focus.name) if is_instance_valid(reopened_focus) else "none",
		])
	planner.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	await _check_employed_planner_routines()
	await _check_planner_exact_blockers()
	await _check_planner_validation_blockers()

func _check_employed_planner_routines() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	LocaleManager.set_language("en")
	GameState.current_job = {"id": "qa_employed"}
	var planner = PLANNER.new()
	add_child(planner)
	planner.set_anchors_preset(Control.PRESET_TOP_LEFT)
	planner.position = Vector2.ZERO
	planner.size = Vector2(960, 600)
	_expect(planner.open(1),
		"employed planner fixture did not open month one")
	await get_tree().process_frame
	planner._step_buttons[1].pressed.emit()
	await get_tree().process_frame
	var primary_income: Button = planner._routine_buttons.get(
		"primary:livelihood") as Button
	var secondary_income: Button = planner._routine_buttons.get(
		"secondary:livelihood") as Button
	var primary_growth: Button = planner._routine_buttons.get(
		"primary:growth") as Button
	var focusable_routines: Array = []
	for row in planner._routine_focus_rows:
		focusable_routines.append_array(row)
	var routine_snapshot: Dictionary = planner.routine_snapshot()
	_expect(is_instance_valid(primary_income) and not primary_income.disabled \
			and primary_income.focus_mode == Control.FOCUS_ALL \
			and is_instance_valid(primary_growth) and primary_growth.disabled \
			and primary_growth.focus_mode == Control.FOCUS_NONE \
			and is_instance_valid(secondary_income) and secondary_income.disabled \
			and secondary_income.focus_mode == Control.FOCUS_NONE \
			and not focusable_routines.has(secondary_income),
		"employed planner exposed an invalid primary job or duplicate secondary income choice")
	_expect(_collect_surface_text(planner).find("PRIMARY JOB FIXED") >= 0 \
			and secondary_income.tooltip_text.find("cannot be selected twice") >= 0,
		"employed Routine did not explain its fixed job and disabled duplicate")
	primary_income.grab_focus()
	secondary_income.mouse_entered.emit()
	await get_tree().process_frame
	_expect(_focused_planner_control(planner) == primary_income,
		"hover moved focus into the disabled duplicate weekly activity")
	for reverse in [false, true]:
		for _tab_index in range(12):
			await _press_planner_tab(reverse)
			var tab_focus := _focused_planner_control(planner)
			_expect(is_instance_valid(tab_focus) \
					and tab_focus.is_visible_in_tree() \
					and tab_focus.focus_mode != Control.FOCUS_NONE \
					and not (tab_focus is BaseButton \
						and (tab_focus as BaseButton).disabled),
				"Tab traversal entered a hidden or disabled employed-planner control")
	_expect(not planner.select_routine("secondary", "livelihood") \
			and planner.routine_snapshot() == routine_snapshot,
		"employed planner accepted duplicate livelihood after disabling its button")
	planner.queue_free()
	await get_tree().process_frame
	GameState.current_job = {}


func _check_planner_exact_blockers() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	LocaleManager.set_language("en")
	var state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	state["plans"] = {
		"1": {
			"schedule": {},
			"routines": {"primary": "livelihood", "secondary": "growth"},
		},
	}
	state["completed_bundles"] = ["m2_rain_delivery_shift"]
	state["completed_bundle_turns"] = {"m2_rain_delivery_shift": 8}
	GameState.core_loop_v2_state = state
	var planner = PLANNER.new()
	add_child(planner)
	planner.set_anchors_preset(Control.PRESET_TOP_LEFT)
	planner.position = Vector2.ZERO
	planner.size = Vector2(960, 600)
	_expect(planner.open(3),
		"exact-blocker planner fixture did not open month three")
	await get_tree().process_frame
	planner._schedule = {
		"9": "m3_hanbit_application",
		"10": "m3_inventory_shift",
		"11": "daeun_world_meet",
		"12": "jiyeon_world_meet",
	}
	planner._routines = CORE_LOOP.default_routines()
	planner._rebuild()
	await get_tree().process_frame
	var validation: Dictionary = CORE_LOOP.validate_plan(
		3, planner.schedule_snapshot(), planner.routine_snapshot())
	_expect(str(validation.get("error", "")) == "exclusive_group" \
			and str(planner._step_buttons[0].text).find("WEEKS 4/4") >= 0 \
			and str(planner._step_buttons[0].text).find("CHECK") >= 0 \
			and str(planner._step_buttons[1].text).find("ROUTINES 2/2") >= 0 \
			and str(planner._step_buttons[2].text).find("MEETINGS OVERLAP") >= 0 \
			and not bool(planner._step_buttons[0].get_meta(
				"core_loop_v2_progress_complete", false)) \
			and not bool(planner._step_buttons[2].get_meta(
				"core_loop_v2_progress_complete", false)) \
			and planner._confirm_button.disabled,
		"4/4 + 2/2 exclusive meetings did not show their exact rail blocker")
	planner._step_buttons[2].pressed.emit()
	await get_tree().process_frame
	var review_text := _collect_surface_text(planner)
	_expect(planner._active_tab == 3 and planner._workflow_step == 2 \
			and review_text.find("FIX BEFORE CONFIRMING") >= 0 \
			and review_text.find("cannot both be chosen") >= 0,
		"final-review step did not expose the full exclusive-meeting reason")

	state = GameState.core_loop_v2_state.duplicate(true)
	state["relationship_stages"] = {
		"father": "met", "hyunsu": "opening", "sangchul": "met",
	}
	GameState.core_loop_v2_state = state
	planner._schedule = {
		"9": "m3_hanbit_application",
		"10": "m3_inventory_shift",
		"11": "m3_empty_saturday",
		"12": "daeun_world_meet",
	}
	planner._workflow_step = 0
	planner._active_tab = 1
	planner._rebuild()
	await get_tree().process_frame
	validation = CORE_LOOP.validate_plan(
		3, planner.schedule_snapshot(), planner.routine_snapshot())
	_expect(str(validation.get("error", "")) == "active_named_characters_cap" \
			and str(planner._step_buttons[0].text).find("CHECK") >= 0 \
			and str(planner._step_buttons[2].text).find("REDUCE MEETUPS") >= 0 \
			and planner._confirm_button.disabled,
		"named-person cap did not show its exact rail blocker")
	planner.queue_free()
	await get_tree().process_frame


func _check_planner_validation_blockers() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	LocaleManager.set_language("en")
	var planner = PLANNER.new()
	add_child(planner)
	planner.set_anchors_preset(Control.PRESET_TOP_LEFT)
	planner.position = Vector2.ZERO
	planner.size = Vector2(960, 600)
	_expect(planner.open(1),
		"validation-blocker planner fixture did not open month one")
	await get_tree().process_frame
	await get_tree().process_frame

	var legal_schedule := _month_one_schedule()
	var surface_cases: Array[Dictionary] = [
		{
			"error": "routines_must_be_distinct",
			"schedule": legal_schedule,
			"routines": {"primary": "livelihood", "secondary": "livelihood"},
			"routine_count": 1,
			"short": "CHOOSE 2 DIFFERENT",
			"full": "Choose two different things.",
		},
		{
			"error": "unknown_routine",
			"schedule": legal_schedule,
			"routines": {"primary": "livelihood", "secondary": "retired_routine"},
			"routine_count": 1,
			"short": "ROUTINE UNAVAILABLE",
			"full": "One weekly activity is no longer available.",
		},
		{
			"error": "job_requires_primary_livelihood",
			"schedule": legal_schedule,
			"routines": {"primary": "growth", "secondary": "recovery"},
			"routine_count": 2,
			"short": "CHOOSE JOB AS PRIMARY",
			"full": "While employed, your job must remain a weekly activity.",
			"employed": true,
		},
		{
			"error": "deadline_missed",
			"schedule": {
				"1": "father_first_call",
				"2": "m1_mirae_application",
				"3": "hyunsu_first_meet",
				"4": "first_temptation_boss",
			},
			"routines": _growth_routines(),
			"routine_count": 2,
			"short": "DEADLINE MISSED",
			"full": "The deadline has already passed by that week. Move it earlier.",
		},
		{
			"error": "unavailable_bundle",
			"schedule": {
				"1": "retired_offer",
				"2": "father_first_call",
				"3": "hyunsu_first_meet",
				"4": "first_temptation_boss",
			},
			"routines": _growth_routines(),
			"routine_count": 2,
			"short": "RESELECT OFFER",
			"full": "One commitment no longer fits this schedule. Review all four weeks.",
		},
		{
			"error": "duplicate_bundle",
			"schedule": {
				"1": "father_first_call",
				"2": "father_first_call",
				"3": "hyunsu_first_meet",
				"4": "first_temptation_boss",
			},
			"routines": _growth_routines(),
			"routine_count": 2,
			"short": "REMOVE DUPLICATE",
			"full": "One commitment no longer fits this schedule. Review all four weeks.",
		},
	]
	for blocker_case in surface_cases:
		GameState.current_job = {"id": "qa_employed"} \
			if bool(blocker_case.get("employed", false)) else {}
		planner._review_pending = false
		planner._review_confirm_release_required = false
		planner._armed_offer_id = ""
		planner._schedule = (
			blocker_case.get("schedule", {}) as Dictionary).duplicate(true)
		planner._routines = (
			blocker_case.get("routines", {}) as Dictionary).duplicate(true)
		planner._active_tab = 1
		planner._workflow_step = 0
		planner._rebuild()
		await get_tree().process_frame
		var validation: Dictionary = CORE_LOOP.validate_plan(
			1, planner.schedule_snapshot(), planner.routine_snapshot())
		var error := str(blocker_case.get("error", ""))
		var expected_routines := int(blocker_case.get("routine_count", -1))
		_expect(str(validation.get("error", "")) == error \
				and str(planner._step_buttons[1].text).find(
					"ROUTINES %d/2" % expected_routines) >= 0 \
				and str(planner._step_buttons[2].text).find(
					str(blocker_case.get("short", ""))) >= 0 \
				and planner._confirm_button.disabled,
			"%s did not expose its exact progress and final-review rail blocker" % error)
		planner._step_buttons[2].pressed.emit()
		await get_tree().process_frame
		_expect(_collect_surface_text(planner).find(
				str(blocker_case.get("full", ""))) >= 0,
			"%s did not expose its full repair instruction in Final Review" % error)
	GameState.current_job = {}

	var copy_cases: Array[Dictionary] = [
		{"error": "routines_must_be_distinct", "ko_short": "서로 다른 2개 필요", "en_short": "CHOOSE 2 DIFFERENT", "ko_full": "서로 다른 두 가지를 골라야 한다.", "en_full": "Choose two different things."},
		{"error": "unknown_routine", "ko_short": "고를 수 없는 항목", "en_short": "ROUTINE UNAVAILABLE", "ko_full": "매주 할 일 중 지금은 고를 수 없는 항목이 있다.", "en_full": "One weekly activity is no longer available."},
		{"error": "job_requires_primary_livelihood", "ko_short": "본업을 주 루틴으로 선택", "en_short": "CHOOSE JOB AS PRIMARY", "ko_full": "취업 중에는 본업을 매주 해야 한다.", "en_full": "While employed, your job must remain a weekly activity."},
		{"error": "deadline_missed", "ko_short": "기한 지난 주차", "en_short": "DEADLINE MISSED", "ko_full": "그 주에는 이미 기한이 지났다. 더 이른 주로 옮겨야 한다.", "en_full": "The deadline has already passed by that week. Move it earlier."},
		{"error": "exclusive_group", "ko_short": "겹치는 만남", "en_short": "MEETINGS OVERLAP", "ko_full": "서로 겹치는 두 만남은 같은 달에 함께 고를 수 없다.", "en_full": "These two meetings cannot both be chosen in the same month."},
		{"error": "active_named_characters_cap", "ko_short": "사람 약속 줄이기", "en_short": "REDUCE MEETUPS", "ko_full": "이번 달에 사람과 잡은 약속이 너무 많다. 한 약속을 다른 일로 바꾼다.", "en_full": "Too many personal commitments overlap this month. Replace one with another kind of work."},
		{"error": "unavailable_bundle", "ko_short": "제안 다시 선택", "en_short": "RESELECT OFFER", "ko_full": "일정에 지금 넣을 수 없는 약속이 있다. 네 주를 다시 확인한다.", "en_full": "One commitment no longer fits this schedule. Review all four weeks."},
		{"error": "locked_week_changed", "ko_short": "고정 일정 복원", "en_short": "RESTORE FIXED EVENT", "ko_full": "일정에 지금 넣을 수 없는 약속이 있다. 네 주를 다시 확인한다.", "en_full": "One commitment no longer fits this schedule. Review all four weeks."},
		{"error": "duplicate_bundle", "ko_short": "중복 일정 제거", "en_short": "REMOVE DUPLICATE", "ko_full": "일정에 지금 넣을 수 없는 약속이 있다. 네 주를 다시 확인한다.", "en_full": "One commitment no longer fits this schedule. Review all four weeks."},
	]
	for language in ["ko", "en"]:
		LocaleManager.set_language(language)
		for copy_case in copy_cases:
			var key_prefix := "%s_" % language
			var error := str(copy_case.get("error", ""))
			_expect(planner._plan_blocker_short({"error": error}) \
					== str(copy_case.get(key_prefix + "short", "")) \
					and planner._plan_error_text({"error": error}) \
						== str(copy_case.get(key_prefix + "full", "")),
				"%s %s blocker copy drifted between rail and full review" % [
					language, error])
	LocaleManager.set_language("en")
	planner.queue_free()
	await get_tree().process_frame


func _check_planner_controller_regressions(
		planner, commits: Array[Dictionary]) -> void:
	commits.clear()
	_expect(planner.open(2),
		"controller fixture could not leave month one before a clean reopen")
	await get_tree().process_frame
	_expect(str(planner._step_buttons[0].text).find("WEEKS 0/4") >= 0,
		"month without a fixed commitment did not begin at truthful 0/4 progress")
	_expect(planner.open(1),
		"controller fixture could not reopen a clean month-one plan")
	await get_tree().process_frame
	await get_tree().process_frame

	var first_offer := "m1_mirae_application"
	_expect(_focused_planner_offer(planner) == first_offer,
		"fresh planner did not focus the first offer for D-pad play")
	var initial_focus := _focused_planner_control(planner)
	planner._confirm_button.mouse_entered.emit()
	await get_tree().process_frame
	var locked_week := planner._slot_buttons.get("4") as Button
	if is_instance_valid(locked_week):
		locked_week.mouse_entered.emit()
		await get_tree().process_frame
	_expect(planner._confirm_button.disabled \
			and planner._confirm_button.focus_mode == Control.FOCUS_NONE \
			and is_instance_valid(locked_week) and locked_week.disabled \
			and locked_week.focus_mode == Control.FOCUS_NONE \
			and _focused_planner_control(planner) == initial_focus,
		"hover moved focus into a disabled confirmation or fixed week")
	for reverse in [false, true]:
		for _tab_index in range(16):
			await _press_planner_tab(reverse)
			var tab_focus := _focused_planner_control(planner)
			_expect(is_instance_valid(tab_focus) \
					and tab_focus.is_visible_in_tree() \
					and tab_focus.focus_mode != Control.FOCUS_NONE \
					and not (tab_focus is BaseButton \
						and (tab_focus as BaseButton).disabled),
				"Tab traversal entered a hidden or disabled schedule control")
	planner._step_buttons[0].grab_focus()
	await _press_planner_pad(JOY_BUTTON_DPAD_UP)
	_expect(_focused_planner_control(planner) == planner._overview_button,
		"schedule step Up did not reach the fixed Overview action")
	await _press_planner_pad(JOY_BUTTON_DPAD_RIGHT)
	_expect(_focused_planner_control(planner) == planner._people_button,
		"Overview Right did not reach the fixed People action")
	await _press_planner_pad(JOY_BUTTON_A)
	_expect(planner._active_tab == 2 \
			and _focused_planner_control(planner) == planner._people_button,
		"South did not open People through its real fixed-action wiring")
	await _press_planner_pad(JOY_BUTTON_DPAD_DOWN)
	_expect(not planner._read_only_focus_controls.is_empty() \
			and _focused_planner_control(planner) \
				== planner._read_only_focus_controls[0],
		"People Down did not enter its first inspectable row")
	await _press_planner_pad(JOY_BUTTON_DPAD_UP)
	await _press_planner_pad(JOY_BUTTON_DPAD_LEFT)
	await _press_planner_pad(JOY_BUTTON_DPAD_DOWN)
	_expect(_focused_planner_control(planner) == planner._step_buttons[0],
		"inactive Overview did not return People inspection to the workflow rail")
	await _press_planner_pad(JOY_BUTTON_A)
	await _press_planner_pad(JOY_BUTTON_DPAD_DOWN)
	_expect(planner._active_tab == 1 and planner._workflow_step == 0 \
			and _focused_planner_offer(planner) == first_offer,
		"South/Down did not re-enter the schedule through its real step wiring")
	planner._step_buttons[1].mouse_entered.emit()
	await get_tree().process_frame
	_expect(_focused_planner_control(planner) == planner._step_buttons[1] \
			and planner._active_tab == 1 and planner._workflow_step == 0,
		"workflow-step hover did not use the same focus without changing state")
	(planner._offer_buttons[first_offer] as Button).mouse_entered.emit()
	await get_tree().process_frame
	_expect(_focused_planner_offer(planner) == first_offer,
		"offer hover did not restore the same GUI focus used by the D-pad")
	await _press_planner_pad(JOY_BUTTON_RIGHT_SHOULDER)
	_expect(planner._active_tab == 3 and planner._workflow_step == 1 \
			and _focused_planner_control(planner) == planner._step_buttons[1],
		"shoulder navigation did not land on the weekly-activity step")
	await _press_planner_pad(JOY_BUTTON_DPAD_DOWN)
	_expect(planner._routine_buttons.values().has(
			_focused_planner_control(planner)),
		"weekly-activity step Down did not enter its first enabled choice")
	await _press_planner_pad(JOY_BUTTON_LEFT_SHOULDER)
	_expect(planner._active_tab == 1 \
			and _focused_planner_control(planner) == planner._step_buttons[0],
		"shoulder navigation did not return to the schedule step")
	await _press_planner_pad(JOY_BUTTON_DPAD_DOWN)
	_expect(_focused_planner_offer(planner) == first_offer,
		"Calendar Down did not restore the first offer after Routine inspection")
	await _place_focused_offer_with_pad(planner, first_offer, 1)

	await _navigate_to_planner_offer(planner, "father_first_call")
	var before_cancel: Dictionary = planner.schedule_snapshot()
	await _press_planner_pad(JOY_BUTTON_A)
	_expect(_planner_armed_offer_id(planner) == "father_first_call" \
			and _focused_planner_week(planner) == 2,
		"South did not arm Father and move focus to the first legal empty week")
	await _press_planner_pad(JOY_BUTTON_B)
	_expect(_planner_armed_offer_id(planner).is_empty() \
			and planner.schedule_snapshot() == before_cancel \
			and planner.visible and planner._active_tab == 1,
		"East did not cancel the armed placement without mutating the plan")

	await _navigate_to_planner_offer(planner, "father_first_call")
	await _place_focused_offer_with_pad(planner, "father_first_call", 2)
	await _navigate_to_planner_offer(planner, "hyunsu_first_meet")
	await _place_focused_offer_with_pad(planner, "hyunsu_first_meet", 3)
	_expect(planner.schedule_snapshot() == _month_one_schedule(),
		"raw D-pad/South route did not build the canonical month-one plan")

	await _navigate_to_planner_offer(planner, "m1_phone_off_sunday")
	var before_offer_west: Dictionary = planner.schedule_snapshot()
	await _press_planner_pad(JOY_BUTTON_X)
	_expect(planner.schedule_snapshot() == before_offer_west \
			and _focused_planner_offer(planner) == "m1_phone_off_sunday",
		"West removed a remembered week while an offer card actually held focus")

	await _navigate_to_planner_week(planner, 2)
	var before_week_west: Dictionary = planner.schedule_snapshot()
	await _press_planner_pad(JOY_BUTTON_X)
	var after_week_west: Dictionary = planner.schedule_snapshot()
	_expect(_dictionary_delta_count(before_week_west, after_week_west) == 1 \
			and not after_week_west.has("2") \
			and str(after_week_west.get("1", "")) \
				== "m1_mirae_application" \
			and str(after_week_west.get("3", "")) == "hyunsu_first_meet" \
			and str(after_week_west.get("4", "")) == "first_temptation_boss",
		"West on an actual week card did not remove exactly that editable week")
	await _navigate_to_planner_offer(planner, "father_first_call")
	await _place_focused_offer_with_pad(planner, "father_first_call", 2)
	_expect(_focused_planner_control(planner) == planner._confirm_button,
		"completing four weeks did not move controller focus to plan review")
	var ready_hint := str(planner._hint_label.text).to_upper()
	_expect(ready_hint.find("NEXT") >= 0 \
			and ready_hint.find("REVIEW PLAN") >= 0 \
			and ready_hint.find("STEP 1/2") < 0,
		"completed plan still advertised Choose instead of the Review action")

	var commits_before_review := commits.size()
	await _press_planner_pad(JOY_BUTTON_A)
	_expect(planner.review_pending() and planner._active_tab == 3 \
			and planner._workflow_step == 2 \
			and commits.size() == commits_before_review,
		"first South confirmation skipped review or committed immediately")
	_expect(_focused_planner_control(planner) == planner._edit_button,
		"review did not move focus to the safe Edit action")
	await _planner_pad_release(JOY_BUTTON_A)
	_expect(commits.size() == commits_before_review,
		"a repeated release committed the plan without a fresh press")
	await get_tree().create_timer(0.42).timeout
	await get_tree().process_frame
	_expect(planner.review_pending() \
			and commits.size() == commits_before_review,
		"review committed while waiting for a fresh confirmation input")
	var schedule_before_edit: Dictionary = planner.schedule_snapshot()
	await _press_planner_pad(JOY_BUTTON_A)
	_expect(not planner.review_pending() and planner._active_tab == 1 \
			and planner._workflow_step == 0 \
			and planner.schedule_snapshot() == schedule_before_edit \
			and commits.size() == commits_before_review \
			and not planner._edit_button.visible \
			and _focus_neighbor(
				planner._confirm_button, "focus_neighbor_left") \
					!= planner._edit_button,
		"the visible Edit Plan action did not return safely or left a hidden focus edge")
	planner._confirm_button.grab_focus()
	await _press_planner_pad(JOY_BUTTON_A)
	_expect(planner.review_pending() and planner._active_tab == 3 \
			and planner._workflow_step == 2 \
			and _focused_planner_control(planner) == planner._edit_button,
		"plan review could not be re-entered through the real confirmation button after Edit")
	await get_tree().create_timer(0.42).timeout
	await get_tree().process_frame
	await _press_planner_pad(JOY_BUTTON_B)
	_expect(not planner.review_pending() and planner._active_tab == 1 \
			and planner._workflow_step == 0 \
			and planner.schedule_snapshot() == schedule_before_edit \
			and commits.size() == commits_before_review,
		"East did not leave final review for the unchanged schedule")
	planner._confirm_button.grab_focus()
	await _press_planner_pad(JOY_BUTTON_A)
	_expect(planner.review_pending() \
			and _focused_planner_control(planner) == planner._edit_button,
		"plan review could not be re-entered after the real East path")
	await get_tree().create_timer(0.42).timeout
	await get_tree().process_frame
	var last_review_control: Control = planner._read_only_focus_controls[-1]
	await _press_planner_pad(JOY_BUTTON_DPAD_UP)
	_expect(_focused_planner_control(planner) == last_review_control,
		"review Edit-Up did not enter the final inspectable review section")
	await _press_planner_pad(JOY_BUTTON_DPAD_DOWN)
	_expect(_focused_planner_control(planner) == planner._edit_button,
		"review section Down did not return to the safe Edit action")
	await _press_planner_pad(JOY_BUTTON_DPAD_RIGHT)
	_expect(_focused_planner_control(planner) == planner._confirm_button,
		"review D-pad could not move from safe Edit focus to final confirmation")
	await _press_planner_pad(JOY_BUTTON_A)
	_expect(commits.size() == commits_before_review + 1,
		"a fresh South press after release did not commit exactly once")

	commits.clear()
	_expect(planner.open(2),
		"controller fixture could not reset after its review regression")
	await get_tree().process_frame
	_expect(planner.open(1),
		"controller fixture could not restore month one after review regression")
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(planner.schedule_snapshot().size() == 1 \
			and str(planner.schedule_snapshot().get("4", "")) \
				== "first_temptation_boss" \
			and _planner_armed_offer_id(planner).is_empty(),
		"controller regression did not leave a clean planner fixture")


func _place_focused_offer_with_pad(
		planner, offer_id: String, expected_week: int) -> void:
	_expect(_focused_planner_offer(planner) == offer_id,
		"D-pad route reached the wrong offer before placement: %s" % offer_id)
	await _press_planner_pad(JOY_BUTTON_A)
	_expect(_planner_armed_offer_id(planner) == offer_id \
			and _focused_planner_week(planner) == expected_week,
		"offer %s did not move focus to legal empty week %d" % [
			offer_id, expected_week,
		])
	await _press_planner_pad(JOY_BUTTON_A)
	_expect(str(planner.schedule_snapshot().get(str(expected_week), "")) \
			== offer_id \
			and _planner_armed_offer_id(planner).is_empty(),
		"South did not place %s in week %d" % [offer_id, expected_week])


func _navigate_to_planner_offer(planner, target_offer_id: String) -> void:
	var owner := _focused_planner_control(planner)
	if owner == planner._confirm_button:
		await _press_planner_pad(JOY_BUTTON_DPAD_UP)
	owner = _focused_planner_control(planner)
	if owner == planner._routine_edit_button:
		await _press_planner_pad(JOY_BUTTON_DPAD_UP)
	if _focused_planner_week(planner) > 0:
		await _press_planner_pad(JOY_BUTTON_DPAD_LEFT)
	var current_offer_id := _focused_planner_offer(planner)
	var available: Array[String] = CORE_LOOP.available_offer_ids(1)
	var current_index := available.find(current_offer_id)
	var target_index := available.find(target_offer_id)
	_expect(current_index >= 0 and target_index >= 0,
		"D-pad offer navigation began or ended outside the authored offer list")
	if current_index < 0 or target_index < 0:
		return
	var button := JOY_BUTTON_DPAD_DOWN \
		if target_index > current_index else JOY_BUTTON_DPAD_UP
	for _step in range(absi(target_index - current_index)):
		await _press_planner_pad(button)
	_expect(_focused_planner_offer(planner) == target_offer_id,
		"D-pad could not reach offer %s without direct focus" % target_offer_id)


func _navigate_to_planner_week(planner, target_week: int) -> void:
	if not _focused_planner_offer(planner).is_empty():
		await _press_planner_pad(JOY_BUTTON_DPAD_RIGHT)
	var current_week := _focused_planner_week(planner)
	_expect(current_week > 0,
		"D-pad could not enter the week column from an offer")
	if current_week <= 0:
		return
	var button := JOY_BUTTON_DPAD_DOWN \
		if target_week > current_week else JOY_BUTTON_DPAD_UP
	for _step in range(absi(target_week - current_week)):
		await _press_planner_pad(button)
	_expect(_focused_planner_week(planner) == target_week,
		"D-pad could not reach week %d without direct focus" % target_week)


func _focused_planner_control(planner) -> Control:
	var owner := get_viewport().gui_get_focus_owner()
	if owner is Control and planner.is_ancestor_of(owner):
		return owner as Control
	return null


func _focused_planner_offer(planner) -> String:
	var owner := _focused_planner_control(planner)
	if is_instance_valid(owner) and owner.has_meta("core_loop_v2_offer_id"):
		return str(owner.get_meta("core_loop_v2_offer_id", ""))
	return ""


func _focused_planner_week(planner) -> int:
	var owner := _focused_planner_control(planner)
	if is_instance_valid(owner) and owner.has_meta("core_loop_v2_week"):
		return int(owner.get_meta("core_loop_v2_week", -1))
	return -1


func _press_planner_pad(button_index: JoyButton) -> void:
	await _planner_pad_press(button_index)
	await _planner_pad_release(button_index)
	await get_tree().process_frame


func _press_planner_tab(reverse: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = KEY_TAB
	event.physical_keycode = KEY_TAB
	event.shift_pressed = reverse
	event.pressed = true
	Input.parse_input_event(event)
	await get_tree().process_frame
	var released := event.duplicate() as InputEventKey
	released.pressed = false
	Input.parse_input_event(released)
	await get_tree().process_frame


func _planner_pad_press(button_index: JoyButton) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = button_index
	event.pressed = true
	Input.parse_input_event(event)
	await get_tree().process_frame


func _planner_pad_release(button_index: JoyButton) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = button_index
	event.pressed = false
	Input.parse_input_event(event)
	await get_tree().process_frame


func _click_planner_control(control: Control, double_click: bool = false) -> void:
	var position := control.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = position
	motion.global_position = position
	get_viewport().push_input(motion, true)
	await get_tree().process_frame
	var pressed := InputEventMouseButton.new()
	pressed.button_index = MOUSE_BUTTON_LEFT
	pressed.position = position
	pressed.global_position = position
	pressed.pressed = true
	pressed.button_mask = MOUSE_BUTTON_MASK_LEFT
	pressed.double_click = double_click
	get_viewport().push_input(pressed, true)
	await get_tree().process_frame
	var released := pressed.duplicate() as InputEventMouseButton
	released.pressed = false
	released.button_mask = 0
	get_viewport().push_input(released, true)
	await get_tree().process_frame


func _check_planner_offer_then_week(planner) -> void:
	var baseline: Dictionary = planner.schedule_snapshot()
	var baseline_progress := str(planner._step_buttons[0].text)
	var baseline_complete := bool(planner._step_buttons[0].get_meta(
		"core_loop_v2_progress_complete", false))
	_expect(baseline_progress.find("WEEKS 1/4") >= 0 \
			and not baseline_complete,
		"fixed week-four month did not begin at truthful 1/4 progress")
	var first_detail := str(planner._detail_label.text)
	planner._offer_focused("father_first_call")
	await get_tree().process_frame
	_expect(planner.schedule_snapshot() == baseline \
			and _planner_armed_offer_id(planner).is_empty() \
			and str(planner._detail_label.text) != first_detail,
		"focusing an offer scheduled or armed it instead of showing detail")
	var father_detail := str(planner._detail_label.text)
	var hover_button: Button = planner._offer_buttons.get("hyunsu_first_meet")
	if is_instance_valid(hover_button):
		hover_button.mouse_entered.emit()
		await get_tree().process_frame
	_expect(is_instance_valid(hover_button) \
			and planner.schedule_snapshot() == baseline \
			and _planner_armed_offer_id(planner).is_empty() \
			and planner._selected_offer_id == "hyunsu_first_meet" \
			and str(planner._detail_label.text) != father_detail,
		"hovering an offer did not remain a detail-only preview")

	planner._select_week(1)
	var no_arm_text := "%s\n%s\n%s" % [
		str(planner._detail_label.text),
		str(planner._status_label.text),
		str(planner._hint_label.text),
	]
	var no_arm_upper := no_arm_text.to_upper()
	_expect(planner.schedule_snapshot() == baseline \
			and _planner_armed_offer_id(planner).is_empty() \
			and no_arm_upper.find("CHOOSE") >= 0 \
			and (no_arm_upper.find("OFFER") >= 0 \
				or no_arm_upper.find("OPTION") >= 0),
		"clicking an empty week without an armed offer changed the plan or hid guidance")

	planner._assign_offer("father_first_call")
	var armed_button: Button = planner._offer_buttons.get("father_first_call")
	_expect(planner.schedule_snapshot() == baseline \
			and str(planner._step_buttons[0].text) == baseline_progress \
			and bool(planner._step_buttons[0].get_meta(
				"core_loop_v2_progress_complete", false)) == baseline_complete \
			and _planner_armed_offer_id(planner) == "father_first_call" \
			and is_instance_valid(armed_button) \
			and bool(armed_button.get_meta("core_loop_v2_offer_armed", false)) \
			and armed_button.text.to_upper().find("SELECTED ·") >= 0 \
			and str(planner._status_label.text).to_upper().find(
				"WHICH WEEK SHOULD THIS GO IN?") >= 0 \
			and str(planner._hint_label.text).to_upper().find(
				"STEP 2/2") >= 0 \
			and str(planner._hint_label.text).to_upper().find(
				"PLACE") >= 0 \
			and str(planner._hint_label.text).to_upper().find(
				"CANCEL") >= 0,
		"offer press did not arm a zero-mutation intent with the English card/footer cue")
	_expect(str(planner._step_buttons[2].text).find(
			"PLACE/CANCEL OFFER") >= 0,
		"armed zero-delta offer did not name its exact final-review blocker")
	planner._assign_offer("father_first_call")
	_expect(planner.schedule_snapshot() == baseline \
			and _planner_armed_offer_id(planner).is_empty(),
		"pressing the armed offer again did not cancel without mutation")

	planner._assign_offer("father_first_call")
	var legal_before: Dictionary = planner.schedule_snapshot()
	planner._select_week(1)
	var legal_after: Dictionary = planner.schedule_snapshot()
	_expect(_dictionary_delta_count(legal_before, legal_after) == 1 \
			and str(legal_after.get("1", "")) == "father_first_call" \
			and str(planner._step_buttons[0].text).find("WEEKS 2/4") >= 0 \
			and _planner_armed_offer_id(planner).is_empty(),
		"legal offer-to-week confirmation did not make exactly one slot change and clear intent")

	planner._assign_offer("father_first_call")
	var move_before: Dictionary = planner.schedule_snapshot()
	planner._select_week(2)
	var move_after: Dictionary = planner.schedule_snapshot()
	_expect(_dictionary_delta_count(move_before, move_after) == 2 \
			and not move_after.has("1") \
			and str(move_after.get("2", "")) == "father_first_call" \
			and move_after.values().count("father_first_call") == 1 \
			and _planner_armed_offer_id(planner).is_empty(),
		"moving a placed offer did not remove the old slot or created a duplicate")

	_expect(planner.assign_offer_to_week("hyunsu_first_meet", 1),
		"component fixture could not occupy week one")
	planner._assign_offer("father_first_call")
	var occupied_before: Dictionary = planner.schedule_snapshot()
	planner._select_week(1)
	_expect(planner.schedule_snapshot() == occupied_before \
			and _planner_armed_offer_id(planner) == "father_first_call" \
			and planner.placement_error() == "occupied" \
			and str(planner._status_label.text).to_upper().find(
				"REMOVE IT FIRST") >= 0,
		"occupied week did not reject with zero mutation, visible error, and retained intent")

	planner._assign_offer("father_first_call")
	planner._assign_offer("m1_mirae_application")
	var deadline_before: Dictionary = planner.schedule_snapshot()
	var deadline_error := str(planner._status_label.text).to_upper()
	_expect(planner.schedule_snapshot() == deadline_before \
			and _planner_armed_offer_id(planner).is_empty() \
			and planner.placement_error() == "no_open_week" \
			and deadline_error.find("NO VALID WEEK") >= 0,
		"offer with no legal empty week mutated the plan, armed, or hid its guidance")

	planner._assign_offer("father_first_call")
	var same_week_before: Dictionary = planner.schedule_snapshot()
	planner._select_week(2)
	_expect(planner.schedule_snapshot() == same_week_before \
			and _planner_armed_offer_id(planner).is_empty() \
			and planner.placement_error().is_empty(),
		"confirming an offer in its existing week changed the plan or kept stale intent")
	var fixed_button: Button = planner._slot_buttons.get("4")
	_expect(is_instance_valid(fixed_button) and fixed_button.disabled,
		"fixed week-four commitment was not visibly disabled")

	planner._assign_offer("m1_phone_off_sunday")
	var tab_before: Dictionary = planner.schedule_snapshot()
	planner._overview_button.pressed.emit()
	_expect(planner.schedule_snapshot() == tab_before \
			and _planner_armed_offer_id(planner).is_empty(),
		"switching away from Calendar changed the plan or retained armed intent")
	planner._step_buttons[0].pressed.emit()
	_check_planner_focus_neighbors(planner)

	planner._assign_offer("m1_phone_off_sunday")
	var reopen_before: Dictionary = planner.schedule_snapshot()
	_expect(planner.open(1) \
			and planner.schedule_snapshot() == reopen_before \
			and _planner_armed_offer_id(planner).is_empty(),
		"reopening the same month changed its draft or retained armed intent")
	planner._assign_offer("m1_phone_off_sunday")
	_expect(planner.open(2) and _planner_armed_offer_id(planner).is_empty(),
		"opening a new month retained the previous month's armed intent")
	_expect(planner.open(1) \
			and planner.schedule_snapshot().size() == 1 \
			and str(planner.schedule_snapshot().get("4", "")) \
				== "first_temptation_boss" \
			and _planner_armed_offer_id(planner).is_empty(),
		"component interaction fixture did not reset month one cleanly")

func _planner_armed_offer_id(planner) -> String:
	var field_value := str(planner.get("_armed_offer_id"))
	var meta_value := str(planner.get_meta("core_loop_v2_armed_offer_id", ""))
	var public_value := str(planner.armed_offer_id())
	_expect(field_value == meta_value and field_value == public_value,
		"planner armed-offer field, public reader, and QA metadata disagreed")
	return field_value

func _dictionary_delta_count(before: Dictionary, after: Dictionary) -> int:
	var keys: Array = before.keys()
	for key in after.keys():
		if not keys.has(key):
			keys.append(key)
	var changed := 0
	for key in keys:
		if before.has(key) != after.has(key) \
				or before.get(key) != after.get(key):
			changed += 1
	return changed

func _check_planner_focus_neighbors(planner) -> void:
	var offer_controls: Array = planner._offer_buttons.values()
	var week_controls: Array = []
	for raw_week in planner._slot_buttons.values():
		var week_button := raw_week as Button
		if is_instance_valid(week_button) and not week_button.disabled:
			week_controls.append(week_button)
	var expected_right := planner._slot_buttons.get(
		str(planner._selected_week)) as Button
	if not is_instance_valid(expected_right) or expected_right.disabled:
		expected_right = week_controls[0] as Button
	var expected_left := planner._offer_buttons.get(
		_planner_armed_offer_id(planner)) as Button
	if not is_instance_valid(expected_left):
		expected_left = planner._offer_buttons.get(
			planner._selected_offer_id) as Button
	if not is_instance_valid(expected_left):
		expected_left = offer_controls[0] as Button
	var validation: Dictionary = CORE_LOOP.validate_plan(
		int(planner.get_meta("core_loop_v2_month", 0)),
		planner.schedule_snapshot(), planner.routine_snapshot())
	var plan_ready := bool(validation.get("ok", false)) \
		and _planner_armed_offer_id(planner).is_empty()
	var expected_footer: Control = planner._confirm_button \
		if plan_ready else planner._step_buttons[0]
	for index in range(offer_controls.size()):
		var offer := offer_controls[index] as Control
		var expected_top: Control = (
			offer_controls[index - 1] as Control
			if index > 0 else planner._step_buttons[0])
		var expected_bottom: Control = (
			offer_controls[index + 1] as Control
			if index + 1 < offer_controls.size() else expected_footer)
		_expect(is_instance_valid(offer) \
				and _focus_neighbor(offer, "focus_neighbor_top") == expected_top \
				and _focus_neighbor(offer, "focus_neighbor_bottom") \
					== expected_bottom \
				and _focus_neighbor(offer, "focus_neighbor_right") \
					== expected_right,
			"offer column did not expose explicit adjacent up/down and week-right neighbors")
	for index in range(week_controls.size()):
		var week := week_controls[index] as Control
		var expected_top: Control = (
			week_controls[index - 1] as Control
			if index > 0 else planner._step_buttons[0])
		var expected_bottom: Control = (
			week_controls[index + 1] as Control
			if index + 1 < week_controls.size() else planner._routine_edit_button)
		_expect(is_instance_valid(week) \
				and _focus_neighbor(week, "focus_neighbor_top") == expected_top \
				and _focus_neighbor(week, "focus_neighbor_bottom") \
					== expected_bottom \
				and _focus_neighbor(week, "focus_neighbor_left") \
					== expected_left,
			"week column did not expose explicit adjacent up/down and offer-left neighbors")
	_expect(_focus_neighbor(planner._routine_edit_button, "focus_neighbor_top") \
			== week_controls[week_controls.size() - 1] \
			and _focus_neighbor(
				planner._routine_edit_button, "focus_neighbor_bottom") \
				== expected_footer \
			and _focus_neighbor(planner._confirm_button, "focus_neighbor_top") \
				== (planner._routine_edit_button \
					if plan_ready else planner._step_buttons[0]),
		"schedule focus path entered a disabled review or lost its ready footer")

func _focus_neighbor(control: Control, property_name: StringName) -> Control:
	if not is_instance_valid(control):
		return null
	var path: NodePath = control.get(property_name)
	if path.is_empty():
		return null
	return control.get_node_or_null(path) as Control

func _month_one_schedule() -> Dictionary:
	return {
		"1": "m1_mirae_application",
		"2": "father_first_call",
		"3": "hyunsu_first_meet",
		"4": "first_temptation_boss",
	}

func _month_two_legal_schedule() -> Dictionary:
	return {
		"5": "m2_seorin_application",
		"6": "m2_rain_delivery_shift",
		"7": "m2_youth_center_mock_interview",
		"8": "m2_sleep_debt_sunday",
	}

func _growth_routines() -> Dictionary:
	return {
		"primary": "growth",
		"secondary": "livelihood",
	}

func _record_fixture_action(bundle_id: String) -> bool:
	var scene_bundle := CORE_LOOP.bundle(bundle_id)
	var action_id := str(scene_bundle.get("action_id", ""))
	if action_id.is_empty():
		return true
	var config: Dictionary = (
		(scene_bundle.get("action_config", {}) as Dictionary).duplicate(true)
		if scene_bundle.get("action_config", {}) is Dictionary else {}
	)
	var execution := str(config.get("execution", "fixture"))
	var details: Dictionary = {"execution": execution}
	if action_id == "apply":
		details["application_id"] = str(config.get(
			"application_id", bundle_id.trim_suffix("_application")))
		details["status"] = str(config.get("status", "submitted"))
	elif execution == "activity_task":
		var activity_resolution: Dictionary = (
			_default_fixture_activity_task_resolution(bundle_id)
		)
		if not bool(activity_resolution.get("ok", false)):
			return false
		details = activity_resolution.duplicate(true)
		details.erase("ok")
	if not CORE_LOOP.note_action_commitment(
			_finalized_action_record(action_id, details)):
		return false
	if CORE_LOOP.action_story_stage(bundle_id) != "story":
		return true
	if not CORE_LOOP.acknowledge_action_story_result(bundle_id):
		return false
	var roots := CORE_LOOP.resolved_event_roots(bundle_id)
	if roots.is_empty():
		return false
	var root := str(roots[0])
	var event: Dictionary = DataRegistry.find_event(root)
	var choices: Array = event.get("choices", []) \
		if event.get("choices", []) is Array else []
	if choices.is_empty() or not choices[0] is Dictionary:
		return false
	GameState.apply_choice(event, choices[0])
	return CORE_LOOP.note_story_choice(root, 0)

func _default_fixture_activity_task_resolution(
		bundle_id: String) -> Dictionary:
	var begun: Dictionary = CORE_LOOP.begin_or_resume_activity_task(bundle_id)
	if not bool(begun.get("ok", false)):
		return begun
	var config: Dictionary = begun.get("config", {})
	if config.is_empty():
		config = CORE_LOOP.activity_task_config(bundle_id)
	var requirement_ids: Array = (
		(config.get("requirement_ids", []) as Array).duplicate()
		if config.get("requirement_ids", []) is Array else []
	)
	var normal_steps := int(config.get("normal_steps", 0))
	if normal_steps < 1 or requirement_ids.size() <= normal_steps:
		return {"ok": false, "error": "invalid_activity_task_fixture"}
	var selected_requirements: Array = requirement_ids.slice(0, normal_steps)
	var baseline_effects: Variant = config.get("effects", {})
	var raw_outcomes: Variant = config.get("outcomes", {})
	if baseline_effects is Dictionary and raw_outcomes is Dictionary:
		for raw_outcome in (raw_outcomes as Dictionary).values():
			if raw_outcome is Dictionary \
					and (raw_outcome as Dictionary).get("effects", {}) \
						== baseline_effects \
					and (raw_outcome as Dictionary).get(
						"requirements", []) is Array:
				selected_requirements = (
					(raw_outcome as Dictionary).get(
						"requirements", []) as Array
				).duplicate()
				break
	var updated: Dictionary = CORE_LOOP.update_activity_task_requirements(
		selected_requirements)
	if not bool(updated.get("ok", false)):
		return updated
	return CORE_LOOP.resolve_activity_task(false)

func _finalized_action_record(
		action_id: String, details: Dictionary = {}) -> Dictionary:
	return {
		"turn": int(GameState.turn),
		"pressure_id": CORE_LOOP.active_bundle_id(),
		"choice_id": action_id,
		"actual_action_id": action_id,
		"outcome": {},
		"details": details.duplicate(true),
	}

func _collect_surface_text(root: Node) -> String:
	var chunks: Array[String] = []
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is CanvasItem and not (node as CanvasItem).is_visible_in_tree():
			continue
		if node is Label or node is Button or node is RichTextLabel:
			chunks.append(str(node.text))
		for child in node.get_children():
			stack.append(child)
	return "\n".join(chunks)

func _find_meta_node(root: Node, meta_key: String) -> Node:
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node.has_meta(meta_key):
			return node
		for child in node.get_children():
			stack.append(child)
	return null

func _contains_hangul(text: String) -> bool:
	var regex := RegEx.new()
	regex.compile("[가-힣ㄱ-ㅎㅏ-ㅣ]")
	return regex.search(text) != null

func _stop_test_audio() -> void:
	for player_value in AudioManager.get("_pool"):
		var player := player_value as AudioStreamPlayer
		if player != null:
			player.stop()
			player.stream = null
	BGMPlayer.stop()
	for player_key in [
		"_player_a", "_player_b", "_ambience_player", "_season_player",
		"_human_ambience_player",
	]:
		var bgm_player := BGMPlayer.get(player_key) as AudioStreamPlayer
		if bgm_player != null:
			bgm_player.stop()
			bgm_player.stream = null
	await get_tree().process_frame
	await get_tree().create_timer(0.08).timeout

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
