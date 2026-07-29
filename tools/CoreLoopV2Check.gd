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
	await _check_prototype_completion_surface()
	_check_planner_surface()
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
			+ "terminal=week12/24w_sticky_recap planner=1280x720_no_scroll "
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
	_expect(CORE_LOOP.is_active(),
		"prototype did not become active in week one")
	GameState.turn = 9
	_expect(CORE_LOOP.is_active(),
		"prototype did not extend its explicit runtime through week 9")
	GameState.turn = 13
	_expect(not CORE_LOOP.is_active(),
		"prototype escaped its week 1-12 boundary")
	_expect(not CORE_LOOP.is_prototype_complete(),
		"prototype marked an untouched week-thirteen run complete")

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
		"prototype closed before the week-twelve month-end rollover")
	GameState.turn = 13
	_expect(CORE_LOOP.mark_prototype_complete(),
		"prototype could not mark its post-week-twelve terminal state")
	_expect(CORE_LOOP.is_prototype_complete(),
		"prototype terminal marker was not readable")
	_expect(not CORE_LOOP.is_active(),
		"completed prototype remained active in week thirteen")

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
	_expect(CORE_LOOP.is_prototype_complete(),
		"prototype terminal marker did not survive save/load")
	_expect(GameState.turn == 13,
		"prototype terminal save did not remain at the post-week-twelve boundary")

func _check_prototype_completion_surface() -> void:
	LocaleManager.language = "en"
	GameState.add_log("Core Loop V2 completion fixture", "system")
	var packed := load("res://scenes/MainGame.tscn") as PackedScene
	_expect(packed != null,
		"completion recap could not load MainGame.tscn")
	if packed == null:
		return
	var main_game = packed.instantiate()
	main_game.set_meta("_screenshot_qa_static_surface", true)
	main_game.set_meta(
		"_qa_core_loop_v2_completion_snapshot",
		_qa_twenty_four_week_completion_snapshot())
	main_game.set_meta("_qa_core_loop_v2_completion_cap_week", 24)
	add_child(main_game)
	await get_tree().process_frame
	await get_tree().process_frame
	# LocaleManager's startup setting load is deferred; reassert the requested
	# language after that callback before rendering this isolated QA surface.
	LocaleManager.language = "en"
	main_game._core_loop_v2_show_completion()
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(str(main_game._modal_kind) == "core_loop_v2_complete",
		"post-week-twelve MainGame did not open the completion recap")
	_expect(bool(main_game.modal_layer.get_meta(
			"core_loop_v2_completion", false)),
		"completion recap did not expose its terminal surface marker")
	_expect(not main_game.modal_close_button.visible,
		"completion recap exposed a close path into the legacy director")
	_expect(GameState.turn == 13,
		"opening the completion recap advanced into another week")
	var viewport_rect := get_viewport().get_visible_rect()
	var panel_rect: Rect2 = main_game.modal_panel.get_global_rect()
	_expect(viewport_rect.encloses(panel_rect),
		"completion recap escaped the viewport: viewport=%s panel=%s" % [
			viewport_rect, panel_rect])
	var done_button := _find_meta_node(
		main_game.modal_layer, "core_loop_v2_recap_done") as Button
	_expect(is_instance_valid(done_button),
		"completion recap omitted its terminal CTA")
	if is_instance_valid(done_button):
		var done_rect: Rect2 = done_button.get_global_rect()
		# Focus tween can expand the CTA by roughly three logical pixels
		# while it remains visually inside the fixed footer.
		_expect(done_button.is_visible_in_tree() \
				and panel_rect.grow(4.0).encloses(done_rect) \
				and main_game.modal_footer.visible,
			"completion CTA escaped its sticky footer: panel=%s button=%s" % [
				panel_rect, done_rect])
	var scroll_rect: Rect2 = main_game.modal_scroll.get_global_rect()
	var intro_node := _find_meta_node(
		main_game.modal_layer, "core_loop_v2_recap_intro") as Control
	_expect(is_instance_valid(intro_node) \
			and scroll_rect.grow(4.0).encloses(
				intro_node.get_global_rect()) \
			and main_game.modal_scroll.scroll_vertical == 0,
		"24-week record did not open at its title and first paragraph")
	_expect(main_game.modal_scroll.vertical_scroll_mode \
			== ScrollContainer.SCROLL_MODE_AUTO \
			and main_game.modal_body.get_combined_minimum_size().y \
				> main_game.modal_scroll.size.y,
		"24-week record did not retain an explorable bounded body")
	_expect(get_viewport().gui_get_focus_owner() == done_button,
		"sticky completion CTA did not own initial focus")
	var surface_text := _collect_surface_text(main_game.modal_layer)
	var upper_surface := surface_text.to_upper()
	_expect(upper_surface.find("COMPLETED") >= 0,
		"completion recap omitted the completed-activities section")
	_expect(upper_surface.find("NOT CHOSEN") >= 0,
		"completion recap omitted the unchosen-opportunities section")
	_expect(upper_surface.find("CASH LEFT") >= 0 \
			and upper_surface.find("HEALTH") >= 0,
		"completion recap omitted current cash or health state")
	_expect(surface_text.find("Hyunsu") >= 0,
		"completion recap omitted the player's relationship initiative")
	_expect(upper_surface.find("WEEK 25") >= 0,
		"24-week completion density fixture did not state its week-25 boundary")
	_expect(not _contains_hangul(surface_text),
		"English completion recap leaked Hangul: %s" % surface_text)
	main_game.free()
	packed = null
	await get_tree().process_frame

func _qa_twenty_four_week_completion_snapshot() -> Dictionary:
	var snapshot := CORE_LOOP.completion_snapshot()
	var bundle_ids: Array = (
		CORE_LOOP.contract().get("scene_bundles", {}) as Dictionary
	).keys()
	bundle_ids.sort()
	_expect(not bundle_ids.is_empty(),
		"24-week completion QA could not enumerate authored bundles")
	if bundle_ids.is_empty():
		return snapshot
	var kept: Array = []
	var forgone: Array = []
	for index in range(24):
		kept.append({
			"week": index + 1,
			"bundle_id": str(bundle_ids[index % bundle_ids.size()]),
		})
		forgone.append({
			"week": index + 1,
			"bundle_id": str(bundle_ids[
				(index + 24) % bundle_ids.size()]),
		})
	snapshot["kept"] = kept
	snapshot["forgone"] = forgone
	var summaries: Dictionary = (
		snapshot.get("month_summaries", {}) as Dictionary
	).duplicate(true)
	summaries["6"] = {
		"month": 6,
		"fixed_expense": 650_000.0,
		"cash_shortfall": 310_000.0,
	}
	snapshot["month_summaries"] = summaries
	return snapshot

func _check_planner_surface() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	LocaleManager.language = "en"
	var planner = PLANNER.new()
	add_child(planner)
	planner.open(1)
	_expect(planner.visible, "planner did not open")
	_expect(planner._slot_buttons.size() == 4,
		"planner did not render four week slots")
	_expect(not planner._calendar_surface is ScrollContainer,
		"planner calendar introduced a scroll surface")
	_expect(planner.assign_offer_to_week("m1_mirae_application", 1),
		"planner could not schedule the application")
	_expect(planner.assign_offer_to_week("father_first_call", 2),
		"planner could not schedule the father call")
	_expect(planner.assign_offer_to_week("hyunsu_first_meet", 3),
		"planner could not schedule the Hyunsu meeting")
	_expect(not planner.unassign_week(4),
		"planner allowed East/cancel to remove the fixed boss week")
	_expect(planner.unassign_week(2),
		"planner could not remove a player-assigned week")
	_expect(planner.assign_offer_to_week("father_first_call", 2),
		"planner could not restore a removed player assignment")
	var schedule: Dictionary = planner.schedule_snapshot()
	_expect(schedule.size() == 4 \
			and str(schedule.get("4", "")) == "first_temptation_boss",
		"planner did not preserve its fixed fourth week")

	var surface_text := _collect_surface_text(planner)
	_expect(not _contains_hangul(surface_text),
		"English planner leaked Hangul: %s" % surface_text)
	for forbidden in [
		"ACTION POINT", "AFFINITY", "MORAL", "행동력", "호감도", "도덕",
	]:
		_expect(surface_text.to_upper().find(forbidden.to_upper()) < 0,
			"planner exposed hidden system language: %s" % forbidden)
	planner._switch_tab(2)
	var people_text := _collect_surface_text(planner)
	_expect(people_text.find("Hyunsu") < 0,
		"People tab revealed Hyunsu before the first meeting")
	planner.free()

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
	return CORE_LOOP.note_action_commitment(
		_finalized_action_record(action_id, details))

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
		if node is Label or node is Button:
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

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
