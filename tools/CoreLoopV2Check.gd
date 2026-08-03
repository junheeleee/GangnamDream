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
			+ "followup=restored save=roundtrip "
			+ "boundary=week12_continues/week24_cap "
			+ "planner=wide4tabs/4weeks/status+people+record/two_step/read_only "
			+ "planner_input=west_remove/east_safe/shoulders/p-north "
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
	_expect(planner._tab_buttons.size() == 4 \
			and planner._tab_buttons[0].text == "OVERVIEW" \
			and planner._tab_buttons[1].text == "CALENDAR" \
			and planner._tab_buttons[2].text == "PEOPLE" \
			and planner._tab_buttons[3].text == "RECORD",
		"wide planner did not expose the four canonical tabs")
	_expect(planner._slot_buttons.size() == 4 \
			and planner._offer_buttons.size() == 6,
		"wide planner did not expose four weeks and six month-one options")
	_expect(planner._offer_scroll.follow_focus \
			and planner._calendar_scroll.follow_focus \
			and planner._offer_scroll.horizontal_scroll_mode \
				== ScrollContainer.SCROLL_MODE_DISABLED \
			and planner._calendar_scroll.horizontal_scroll_mode \
				== ScrollContainer.SCROLL_MODE_DISABLED,
		"wide planner lost controller focus-following vertical scroll")
	_expect(planner._page_margin.get_theme_constant("margin_left") == 42 \
			and planner._calendar_scroll.custom_minimum_size.x >= 419.0,
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
	planner._switch_tab(0)
	await get_tree().process_frame
	var status_text := _collect_surface_text(planner)
	surface_samples.append(status_text)
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

	planner._switch_tab(2)
	await get_tree().process_frame
	var initial_people := _collect_surface_text(planner)
	surface_samples.append(initial_people)
	_expect(initial_people.find("Father") >= 0,
		"People did not show Father's already-saved number")
	for hidden_name in ["Hyunsu", "Kim Daeun", "Han Jiyeon"]:
		_expect(initial_people.find(hidden_name) < 0,
			"People revealed an unmet or unnamed person: %s" % hidden_name)

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
	planner._switch_tab(2)
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
	planner._switch_tab(2)
	await get_tree().process_frame
	_expect(_collect_surface_text(planner).find("Kim Daeun") >= 0,
		"People did not remember Daeun's name after the authored exchange")

	GameState.core_loop_v2_state = planning_state
	planner._switch_tab(1)
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

	planner._select_week(2)
	var west_event := InputEventAction.new()
	west_event.action = "gd_secondary"
	west_event.pressed = true
	planner._unhandled_input(west_event)
	_expect(not planner.schedule_snapshot().has("2") \
			and planner.visible and planner._active_tab == 1,
		"West did not remove only the selected non-fixed week")
	_expect(planner.assign_offer_to_week("father_first_call", 2),
		"planner could not restore the week removed with West")
	_expect(planner.select_routine("primary", "growth") \
			and planner.select_routine("secondary", "livelihood"),
		"planner could not choose two distinct weekly routines")
	var schedule: Dictionary = planner.schedule_snapshot()
	_expect(schedule.size() == 4 \
			and str(schedule.get("4", "")) == "first_temptation_boss",
		"planner did not preserve all four weeks and the fixed boss event")

	planner._switch_tab(3)
	await get_tree().process_frame
	var record_text := _collect_surface_text(planner)
	surface_samples.append(record_text)
	_expect(record_text.find("THIS MONTH'S PLAN") >= 0 \
			and record_text.find("TWO THINGS TO KEEP UP EACH WEEK") >= 0 \
			and record_text.find("OPTIONS LEFT OUT") >= 0,
		"Record did not explain routines, scheduled work, and options left out")
	planner._switch_tab(1)
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
			and commits.is_empty(),
		"first confirmation skipped the explicit review step")
	var review_text := _collect_surface_text(planner)
	surface_samples.append(review_text)
	_expect(review_text.find("REVIEW PLAN") >= 0 \
			and review_text.find("OPTIONS LEFT OUT") >= 0,
		"review step did not disclose the plan and forgone options")
	planner._commit_plan()
	_expect(commits.size() == 1 \
			and int(commits[0].get("month", 0)) == 1,
		"second confirmation did not emit exactly one immutable plan payload")
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
	_expect(planner.open(1, true) and planner.read_only_plan() \
			and planner.schedule_snapshot() == committed_schedule \
			and planner.routine_snapshot() == committed_routines,
		"Schedule button did not reopen the exact confirmed plan read-only")
	_expect(not planner.assign_offer_to_week("m1_phone_off_sunday", 1) \
			and not planner.unassign_week(2) \
			and not planner.select_routine("primary", "recovery") \
			and planner.schedule_snapshot() == committed_schedule \
			and planner.routine_snapshot() == committed_routines,
		"read-only planner changed an immutable monthly promise")

	planner.size = Vector2(960, 600)
	planner._apply_responsive_layout()
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(planner._compact_layout \
			and planner._page_margin.get_theme_constant("margin_left") == 24 \
			and planner._calendar_scroll.custom_minimum_size.x >= 339.0 \
			and planner._calendar_scroll.custom_minimum_size.x <= 341.0,
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

	planner._switch_tab(0)
	await get_tree().process_frame
	surface_samples.append(_collect_surface_text(planner))
	planner._switch_tab(2)
	await get_tree().process_frame
	surface_samples.append(_collect_surface_text(planner))
	planner._switch_tab(3)
	await get_tree().process_frame
	surface_samples.append(_collect_surface_text(planner))
	var surface_text := "\n".join(surface_samples)
	_expect(not _contains_hangul(surface_text),
		"English planner surface leaked Hangul: %s" % surface_text)
	for forbidden in [
		"ACTION POINT", "AFFINITY", "MORAL", "행동력", "호감도", "도덕",
	]:
		_expect(surface_text.to_upper().find(forbidden.to_upper()) < 0,
			"planner exposed hidden system language: %s" % forbidden)

	planner._confirm_button.pressed.emit()
	_expect(not planner.visible and close_receipts.size() == 1,
		"read-only planner did not close once and return control")
	planner.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
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
	var details := {
		"execution": str(config.get("execution", "fixture")),
	}
	if action_id == "apply":
		details["application_id"] = str(config.get(
			"application_id", bundle_id.trim_suffix("_application")))
		details["status"] = str(config.get("status", "submitted"))
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
