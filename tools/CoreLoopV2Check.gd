extends Node
## ORDER-57: explicit 8-week Core Loop V2 runtime, save, causality, and UI contract.

const CORE_LOOP := preload("res://systems/DemoCoreLoopV2.gd")
const PLANNER := preload("res://scenes/CoreLoopPlanner.gd")

var _failures: Array[String] = []

func _ready() -> void:
	var original_language := LocaleManager.language
	_check_explicit_activation()
	_check_month_one_plan()
	_check_delayed_consequences_cross_month()
	_check_relationship_initiative()
	_check_story_followup_suppression()
	_check_branch_resolution()
	_check_planner_surface()
	LocaleManager.language = original_language
	if _failures.is_empty():
		print(
			"CORE_LOOP_V2_CHECK_OK activation=explicit months=2 slots=4 "
			+ "locked=week4 forgone=ledger delayed=cross_month/one_per_week "
			+ "relationship=player_initiated followup=restored save=roundtrip "
			+ "planner=1280x720_no_scroll en_hangul=0 hidden_scores=0")
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
	_expect(not CORE_LOOP.is_active(),
		"prototype escaped its week 1-8 boundary")

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
	_expect(not bool(invalid_result.get("ok", false)) \
			and str(invalid_result.get("error", "")) == "locked_week_changed",
		"week-four boss could be replaced")

	var schedule := _month_one_schedule()
	var committed := CORE_LOOP.commit_plan(1, schedule)
	_expect(bool(committed.get("ok", false)),
		"valid month-one schedule was rejected")
	_expect(CORE_LOOP.bundle_id_for_turn(4) == "first_temptation_boss",
		"week-four boss was not preserved in the committed schedule")
	_expect(CORE_LOOP.forgone_for_month(1).size() == 3,
		"month-one forgone ledger did not record exactly three closed offers")

	_expect(CORE_LOOP.begin_bundle("m1_mirae_application", "schedule"),
		"application bundle could not begin")
	_expect(CORE_LOOP.note_action_commitment({"choice_id": "apply"}),
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

func _check_delayed_consequences_cross_month() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	GameState.turn = 3
	CORE_LOOP.commit_plan(1, _month_one_schedule())
	CORE_LOOP.begin_bundle("m1_mirae_application", "schedule")
	CORE_LOOP.note_action_commitment({"choice_id": "apply"})
	GameState.flags["opening_interview_application_sent"] = true
	GameState.flags["opening_interview_application_turn"] = 3
	CORE_LOOP.complete_active_bundle()

	GameState.turn = 4
	_expect(CORE_LOOP.pending_consequence_id().is_empty(),
		"application consequence displaced the locked week-four boss")
	CORE_LOOP.begin_bundle("first_temptation_boss", "schedule")
	CORE_LOOP.complete_active_bundle()

	GameState.turn = 5
	_expect(CORE_LOOP.pending_consequence_id() == "opening_interview_math",
		"week-three application result was lost at the month boundary")
	CORE_LOOP.begin_bundle("opening_interview_math", "consequence")
	CORE_LOOP.complete_active_bundle()
	_expect(CORE_LOOP.pending_consequence_id().is_empty(),
		"two consequence scenes stacked in the same week")
	GameState.turn = 6
	_expect(CORE_LOOP.pending_consequence_id() == "temptation_consequence",
		"boss consequence did not wait for the following open week")

func _check_relationship_initiative() -> void:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	_expect(not CORE_LOOP.available_offer_ids(2).has("hyunsu_player_reachout"),
		"relationship pursuit appeared before meeting Hyunsu")
	GameState.turn = 2
	CORE_LOOP.begin_bundle("hyunsu_first_meet", "schedule")
	CORE_LOOP.complete_active_bundle()
	_expect(CORE_LOOP.relationship_stage("hyunsu") == "met",
		"first meeting did not persist the met stage")
	_expect(not CORE_LOOP.was_player_initiated("hyunsu"),
		"chance meeting was misrecorded as player initiation")
	_expect(CORE_LOOP.available_offer_ids(2).has("hyunsu_player_reachout"),
		"player follow-up did not open after meeting Hyunsu")
	GameState.turn = 5
	CORE_LOOP.begin_bundle("hyunsu_player_reachout", "schedule")
	CORE_LOOP.complete_active_bundle()
	_expect(CORE_LOOP.relationship_stage("hyunsu") == "player_reached_out",
		"proactive message did not advance the relationship stage")
	_expect(CORE_LOOP.was_player_initiated("hyunsu"),
		"proactive message was not recorded as the player's action")

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
	_expect(not (choices[0] as Dictionary).has("follow_up_event"),
		"legacy auto-closing was not suppressed inside the V2 scene")
	CORE_LOOP.restore_story_bundle_followups()
	_expect(str((choices[0] as Dictionary).get("follow_up_event", "")) \
			== "arc_chapter1_close",
		"suppressed legacy follow-up was not restored after the V2 scene")

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
	planner.queue_free()

func _month_one_schedule() -> Dictionary:
	return {
		"1": "m1_mirae_application",
		"2": "father_first_call",
		"3": "hyunsu_first_meet",
		"4": "first_temptation_boss",
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

func _contains_hangul(text: String) -> bool:
	var regex := RegEx.new()
	regex.compile("[가-힣ㄱ-ㅎㅏ-ㅣ]")
	return regex.search(text) != null

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
