extends Node

const EXPECTED_ROOTS := [
	{"week": 1, "event": "chapter_card_33"},
	{"week": 2, "event": "arc_intro_01_meal"},
	{"week": 4, "event": "arc_temptation_01"},
	{"week": 5, "event": "arc_intro_03_sns"},
	{"week": 6, "event": "cafe_00"},
	{"week": 8, "event": "arc_temptation_clean"},
	{"week": 9, "event": "arc_intro_04_hyunsu"},
]
const CHOICE_OVERRIDES := {
	"cafe_listen_01": 2,
}
const REQUIRED_FULL_PRESETS := ["Windows", "macOS", "Linux / Steam Deck"]
const REQUIRED_DEMO_PRESETS := ["Windows Demo", "macOS Demo", "Linux / Steam Deck Demo"]

var _failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	_check_build_flavor()
	_check_export_presets()
	_check_opening_interview_causality()
	_check_opening_sequences()
	_check_narrative_bridge_contract()
	_check_chapter_one_temporal_contract()
	_check_employment_consistency()
	_check_side_shift_pay()
	_check_ap_bonus_surface()
	_check_demo_pressure_contract()
	_check_demo_pacing_contract()
	_check_demo_cutoff()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("DEMO_BUILD_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("DEMO_BUILD_CHECK_OK feature=%s cutoff=%d chain=%d presets=%d" % [
		GameState.DEMO_FEATURE,
		GameState.DEMO_TURN_LIMIT,
		EXPECTED_ROOTS.size(),
		REQUIRED_FULL_PRESETS.size() + REQUIRED_DEMO_PRESETS.size(),
	])
	get_tree().quit(0)

func _check_build_flavor() -> void:
	_expect(GameState.is_demo_build(), "The demo test flag did not activate demo mode.")
	_expect(GameState.DEMO_TURN_LIMIT == 24, "Demo cutoff must remain at week 24.")
	var main_scene := str(ProjectSettings.get_setting("application/run/main_scene", ""))
	if main_scene.begins_with("uid://"):
		main_scene = ResourceUID.get_id_path(ResourceUID.text_to_id(main_scene))
	_expect(main_scene == "res://scenes/SplashScreen.tscn", "Boot scene must be SplashScreen, got %s." % main_scene)

func _check_export_presets() -> void:
	var config := ConfigFile.new()
	var error := config.load("res://export_presets.cfg")
	if error != OK:
		_failures.append("Could not read export_presets.cfg (error %d)." % error)
		return
	var flavors := {}
	for section in config.get_sections():
		if not section.begins_with("preset.") or section.ends_with(".options"):
			continue
		var name := str(config.get_value(section, "name", ""))
		var features := str(config.get_value(section, "custom_features", ""))
		flavors[name] = features.split(",", false)
	for preset_name in REQUIRED_FULL_PRESETS:
		_expect(flavors.has(preset_name), "Missing full export preset: %s." % preset_name)
		if flavors.has(preset_name):
			_expect(not flavors[preset_name].has(GameState.DEMO_FEATURE), "Full preset %s carries the demo feature." % preset_name)
	for preset_name in REQUIRED_DEMO_PRESETS:
		_expect(flavors.has(preset_name), "Missing demo export preset: %s." % preset_name)
		if flavors.has(preset_name):
			_expect(flavors[preset_name].has(GameState.DEMO_FEATURE), "Demo preset %s lacks %s." % [preset_name, GameState.DEMO_FEATURE])

func _check_opening_sequences() -> void:
	GameState.start_new_game("김민준", "지방_상경", "직장형", "백수", "자유런", "현실")
	GameState.flags["prologue_done"] = true
	GameState.flags["story_flashforward_seen"] = true
	var packed := load("res://scenes/MainGame.tscn") as PackedScene
	if packed == null:
		_failures.append("MainGame.tscn failed to load.")
		return
	var main_game := packed.instantiate()
	# This representative opening path chose Secure Work in week one. Other
	# intents are covered separately and must not receive this interview.
	GameState.flags["opening_interview_application_sent"] = true
	GameState.flags["opening_interview_application_turn"] = 1
	for row in EXPECTED_ROOTS:
		var week := int(row.get("week", 0))
		GameState.turn = week
		var expected_id := str(row.get("event", ""))
		var actual_id := str(main_game.call("_next_arc_id"))
		_expect(actual_id == expected_id, "Week %d expected %s, got %s." % [week, expected_id, actual_id])
		if actual_id != expected_id:
			break
		_resolve_story_chain(actual_id)
	main_game.free()
	_expect(bool(GameState.flags.get("arc_intro_dad_seen", false)),
		"The interview did not continue into the 125-year calculation.")
	_expect(bool(GameState.flags.get("arc_temptation_clean_seen", false)),
		"The first temptation did not return as a delayed week-eight consequence.")
	_expect(bool(GameState.flags.get("arc_intro_sns_seen", false)),
		"The independent week-five mirror scene disappeared from the opening flow.")
	_expect(bool(GameState.flags.get("chapter1_closed", false)),
		"Hyunsu's first conversation did not continue into the opening chapter close.")

func _check_opening_interview_causality() -> void:
	GameState.start_new_game("김민준", "지방_상경", "직장형", "백수", "자유런", "현실")
	GameState.flags["prologue_done"] = true
	GameState.flags["chapter_33_seen"] = true
	var packed := load("res://scenes/MainGame.tscn") as PackedScene
	if packed == null:
		_failures.append("MainGame.tscn failed to load for interview causality.")
		return
	var main_game := packed.instantiate()
	GameState.turn = 2
	_expect(str(main_game.call("_next_arc_id", 2, true, false)) != "arc_intro_01_meal",
		"The Mapo interview fired without an application.")
	GameState.flags["opening_interview_application_sent"] = true
	GameState.flags["opening_interview_application_turn"] = 2
	_expect(str(main_game.call("_next_arc_id", 2, true, false)) != "arc_intro_01_meal",
		"The Mapo interview fired in the application week.")
	GameState.turn = 3
	_expect(str(main_game.call("_next_arc_id", 3, true, false)) == "arc_intro_01_meal",
		"The Mapo interview did not unlock after an application.")
	GameState.current_job = DataRegistry.get_job("job_01").duplicate(true)
	_expect(str(main_game.call("_next_arc_id", 3, true, false)) != "arc_intro_01_meal",
		"The Mapo interview fired for an already-employed save.")
	main_game.free()

func _check_narrative_bridge_contract() -> void:
	GameState.start_new_game("김민준", "지방_상경", "직장형", "백수", "자유런", "현실")
	var before_events: int = GameState.events_seen
	var before_intelligence: int = GameState.intelligence
	var resolved: bool = EventManager.resolve_narrative_bridge("arc_money_check_low", 0)
	_expect(resolved, "The authored bridge event could not be resolved.")
	_expect(bool(GameState.flags.get("arc_money_check_seen", false)),
		"The bridge dropped the original choice flag.")
	_expect(GameState.intelligence == before_intelligence + 1,
		"The bridge dropped the original choice effects.")
	_expect(GameState.events_seen == before_events + 1,
		"The bridge did not enter authored-event history.")
	var results: Array = EventManager.consume_narrative_bridge_results()
	_expect(results.size() == 1, "The bridge did not leave exactly one narrative trace.")
	if results.size() == 1:
		_expect(not str(results[0].get("summary", "")).is_empty(),
			"The bridge trace lost its localized summary.")
	GameState.start_new_game("김민준", "지방_상경", "직장형", "백수", "자유런", "현실")
	GameState.turn = GameState.DEMO_TURN_LIMIT + 1
	GameState.flags["formal_complaint_filed"] = true
	EventManager.event_cooldowns.clear()
	EventManager.recent_event_ids.clear()
	_expect(EventManager.draw_narrative_bridge_event().is_empty(),
		"A post-demo random bridge leaked through the demo build's CTA boundary.")

func _check_chapter_one_temporal_contract() -> void:
	GameState.start_new_game("김민준", "지방_상경", "직장형", "백수", "자유런", "현실")
	var exam_day: Dictionary = DataRegistry.find_event("hyunsu_exam_day")
	var result_pass: Dictionary = DataRegistry.find_event("hyunsu_result_pass")
	var result_fail: Dictionary = DataRegistry.find_event("hyunsu_result_fail")
	_expect(int((exam_day.get("conditions", {}) as Dictionary).get("min_turn", 0)) == 23,
		"Hyunsu's exam data gate must open in week 23, after the Gangnam finale.")
	_expect(int((result_pass.get("conditions", {}) as Dictionary).get("min_turn", 0)) == 25,
		"Hyunsu's passing result must wait until week 25.")
	_expect(int((result_fail.get("conditions", {}) as Dictionary).get("min_turn", 0)) == 25,
		"Hyunsu's failing result must wait until week 25.")
	GameState.turn = 25
	_expect(not result_fail.is_empty(), "Hyunsu's formal failure result is missing.")
	if result_fail.is_empty():
		return
	var result_choices: Array = result_fail.get("choices", [])
	_expect(result_choices.size() == 2, "Hyunsu's formal failure result lost a choice.")
	if result_choices.is_empty():
		return
	GameState.apply_choice(result_fail, result_choices[0])
	_expect(GameState.has_deferred_event("arc_hyunsu_exam_fail"),
		"StoryMode choice application dropped Hyunsu's four-week aftermath.")
	GameState.turn = 28
	_expect(GameState.pop_ready_deferred_events().is_empty(),
		"Hyunsu's aftermath arrived before four weeks passed.")
	GameState.turn = 29
	_expect(GameState.pop_ready_deferred_events() == ["arc_hyunsu_exam_fail"],
		"Hyunsu's aftermath did not arrive exactly four weeks after the result.")

	var aftermath: Dictionary = DataRegistry.find_event("arc_hyunsu_exam_fail")
	var aftermath_choices: Array = aftermath.get("choices", [])
	_expect(aftermath_choices.size() == 3, "Hyunsu's aftermath choice contract changed.")
	if not aftermath_choices.is_empty():
		GameState.apply_choice(aftermath, aftermath_choices[0])
	GameState.turn = 34
	_expect(GameState.pop_ready_deferred_events() == ["arc_hyunsu_drift"],
		"Hyunsu's drift did not arrive five weeks after the aftermath.")

	var drift: Dictionary = DataRegistry.find_event("arc_hyunsu_drift")
	var drift_choices: Array = drift.get("choices", [])
	_expect(drift_choices.size() == 3, "Hyunsu's drift choice contract changed.")
	if not drift_choices.is_empty():
		GameState.apply_choice(drift, drift_choices[0])
	GameState.turn = 40
	_expect(GameState.pop_ready_deferred_events() == ["arc_hyunsu_new_path"],
		"Hyunsu's new path did not arrive six weeks after the drift.")
	_expect(not GameState.has_deferred_event("hyunsu_pivot"),
		"The obsolete duplicate Hyunsu pivot was scheduled.")

	var goodbye: Dictionary = DataRegistry.find_event("arc_goshiwon_goodbye")
	var goodbye_choices: Array = goodbye.get("choices", [])
	_expect(goodbye_choices.size() == 3, "Goshiwon goodbye choice contract changed.")
	for choice in goodbye_choices:
		_expect(str(choice.get("follow_up_event", "")) == "arc_housing_new_life",
			"A goshiwon goodbye branch no longer reaches the first night at home.")
	var first_night: Dictionary = DataRegistry.find_event("arc_housing_new_life")
	_expect(str(first_night.get("background", "")) == "current_housing",
		"The first night after moving is pinned to a fixed or obsolete room.")

	var paycheck: Dictionary = DataRegistry.find_event("arc_paycheck_reality")
	var paycheck_choices: Array = paycheck.get("choices", [])
	_expect(not paycheck_choices.is_empty(), "The first-paycheck scene has no choices.")
	if not paycheck_choices.is_empty():
		var beer_effects: Dictionary = paycheck_choices[0].get("effects", {})
		_expect(int(beer_effects.get("money", 0)) == -3800,
			"One convenience-store beer must cost 3,800 won, not a meal-sized charge.")

func _resolve_story_chain(event_id: String) -> void:
	var next_id := event_id
	var guard := 0
	while not next_id.is_empty() and guard < 12:
		guard += 1
		var event: Dictionary = DataRegistry.find_event(next_id)
		if event.is_empty():
			_failures.append("Missing early-flow event: %s." % next_id)
			return
		var choices: Array = event.get("choices", [])
		if choices.is_empty():
			_failures.append("Early-flow event has no choice: %s." % next_id)
			return
		var choice_index := int(CHOICE_OVERRIDES.get(next_id, 0))
		if choice_index < 0 or choice_index >= choices.size():
			_failures.append("Invalid smoke choice %d for %s." % [choice_index, next_id])
			return
		var choice: Dictionary = choices[choice_index]
		GameState.apply_choice(event, choice)
		next_id = str(choice.get("follow_up_event", ""))
	if guard >= 12 and not next_id.is_empty():
		_failures.append("Early-flow follow-up chain exceeded the safety limit at %s." % next_id)

func _check_demo_cutoff() -> void:
	GameState.turn = GameState.DEMO_TURN_LIMIT
	_expect(not GameState.has_reached_demo_limit(), "Demo ended before week 24 was completed.")
	GameState.turn = GameState.DEMO_TURN_LIMIT + 1
	_expect(GameState.has_reached_demo_limit(), "Demo did not stop before week 25.")

func _check_demo_pacing_contract() -> void:
	var decision_count := 0
	var boss_count := 0
	var echo_count := 0
	var summary_count := 0
	for week in range(1, GameState.DEMO_TURN_LIMIT + 1):
		var kind := EventManager.demo_week_kind(week)
		if kind in ["decision", "boss"]:
			decision_count += 1
		if kind == "boss":
			boss_count += 1
		elif kind == "echo":
			echo_count += 1
		if EventManager.demo_should_show_full_summary(week):
			summary_count += 1
	_expect(decision_count >= 8 and decision_count <= 10,
		"Demo must expose 8..10 AP decision weeks, got %d." % decision_count)
	_expect(boss_count == 2, "Demo must expose two boss weeks, got %d." % boss_count)
	_expect(echo_count >= 3 and echo_count <= 5,
		"Demo must expose 3..5 echo weeks, got %d." % echo_count)
	_expect(summary_count == 3,
		"Demo must show only first-month, quarter, and final summaries, got %d." % summary_count)

	var packed := load("res://scenes/MainGame.tscn") as PackedScene
	var main_game := packed.instantiate()
	GameState.start_new_game()
	GameState.turn = 21
	GameState.month = 6
	GameState.week_of_month = 1
	_expect(str(main_game.call("_next_milestone_id")).is_empty(),
		"Six-month reflection fired at the entrance to month six instead of the demo finale.")
	GameState.turn = GameState.DEMO_TURN_LIMIT
	GameState.week_of_month = 4
	_expect(str(main_game.call("_next_milestone_id")) == "story_six_months",
		"Six-month reflection did not anchor the week-24 finale.")
	main_game.queue_free()

func _check_employment_consistency() -> void:
	GameState.start_new_game("김민준", "지방_상경", "직장형", "백수", "자유런", "현실")
	var packed := load("res://scenes/MainGame.tscn") as PackedScene
	if packed == null:
		_failures.append("MainGame.tscn failed to load for employment checks.")
		return
	var main_game := packed.instantiate()
	GameState.flags["pending_spec_career"] = true
	GameState.flags["career_months_total"] = 12
	GameState.current_job = {}
	_expect(not bool(main_game.call("_career_specialization_ready", GameState.flags)),
		"Career specialization appeared while unemployed.")

	GameState.current_job = DataRegistry.get_job("job_03").duplicate(true)
	GameState.flags["career_months_total"] = 11
	_expect(not bool(main_game.call("_career_specialization_ready", GameState.flags)),
		"Career specialization appeared before 12 worked months.")
	GameState.flags["career_months_total"] = 12
	_expect(bool(main_game.call("_career_specialization_ready", GameState.flags)),
		"Career specialization did not unlock after 12 worked months in an office job.")
	GameState.current_job = DataRegistry.get_job("job_01").duplicate(true)
	_expect(not bool(main_game.call("_career_specialization_ready", GameState.flags)),
		"Office specialization appeared during convenience-store survival work.")
	GameState.turn = 16
	GameState.job_tenure = 3
	GameState.flags.erase("arc_office_routine_seen")
	_expect(not bool(main_game.call("_office_routine_available", GameState.flags, 16)),
		"A convenience-store survival job exposed the office overtime scene.")
	GameState.current_job = DataRegistry.get_job("job_03").duplicate(true)
	_expect(bool(main_game.call("_office_routine_available", GameState.flags, 16)),
		"A three-week office job could not expose the office overtime scene.")

	GameState.flags.erase("pending_spec_career")
	GameState.flags.erase("arc_first_job_week_seen")
	GameState.current_job = DataRegistry.get_job("job_01").duplicate(true)
	GameState.turn = 2
	GameState.job_tenure = 0
	GameState.flags["job_started_turn"] = 1
	_expect(str(main_game.call("_first_job_week_arc_id", GameState.flags)).is_empty(),
		"Week-two interview chain was followed by a second first-shift conflict.")
	GameState.turn = 3
	_expect(str(main_game.call("_first_job_week_arc_id", GameState.flags)) == "arc_first_job_week_convenience",
		"The deferred convenience first-shift scene did not reopen in week three.")
	GameState.turn = 10
	GameState.job_tenure = 0
	GameState.flags["job_started_turn"] = 10
	_expect(str(main_game.call("_first_job_week_arc_id", GameState.flags)).is_empty(),
		"First-job story chained during the same week as hiring.")
	GameState.turn = 11
	_expect(str(main_game.call("_first_job_week_arc_id", GameState.flags)) == "arc_first_job_week_convenience",
		"Convenience job did not route to its first-week scene.")
	GameState.current_job = DataRegistry.get_job("job_02").duplicate(true)
	_expect(str(main_game.call("_first_job_week_arc_id", GameState.flags)) == "arc_first_job_week_delivery",
		"Delivery job did not route to its first-week scene.")
	GameState.current_job = DataRegistry.get_job("job_03").duplicate(true)
	_expect(str(main_game.call("_first_job_week_arc_id", GameState.flags)) == "arc_first_job_week",
		"Office job did not route to the canonical first-week scene.")
	_expect(DataRegistry.find_event("story_first_workday").is_empty(),
		"Obsolete duplicate story_first_workday remains registered.")
	_expect(str(DataRegistry.find_event("arc_first_job_week_convenience").get("background", "")) == "convenience_night",
		"Convenience first-week scene has the wrong background.")
	_expect(str(DataRegistry.find_event("arc_first_job_week_delivery").get("background", "")) == "aruba_delivery",
		"Delivery first-week scene has the wrong background.")
	var first_paycheck: Dictionary = DataRegistry.find_event("story_first_paycheck_feel")
	_expect(str(first_paycheck.get("background", "")) == "current_workplace",
		"First paycheck is no longer bound to the player's live workplace.")
	GameState.current_job = DataRegistry.get_job("job_01").duplicate(true)
	_expect(ImageRegistry.resolve_contextual_background_id("current_workplace") == "convenience_night",
		"Convenience paycheck did not resolve to the convenience store.")
	GameState.current_job = DataRegistry.get_job("job_02").duplicate(true)
	_expect(ImageRegistry.resolve_contextual_background_id("current_workplace") == "aruba_delivery",
		"Delivery paycheck did not resolve to the delivery route.")
	GameState.current_job = DataRegistry.get_job("job_03").duplicate(true)
	_expect(ImageRegistry.resolve_contextual_background_id("current_workplace") == "office",
		"Corporate paycheck did not resolve to the office.")
	_expect(str(DataRegistry.find_event("story_first_savings_milestone").get("background", "")) == "current_housing",
		"First savings milestone is no longer grounded in the player's live home.")
	_expect(str(DataRegistry.find_event("arc_temptation_clean").get("background", "")) == "goshiwon_room",
		"Clean temptation aftermath moved out of the room described by its prose.")
	var job_invest: Dictionary = DataRegistry.find_event("arc_job_vs_invest")
	for choice_value in job_invest.get("choices", []):
		var choice: Dictionary = choice_value
		_expect(str(choice.get("follow_up_event", "")) == "arc_hyunsu_night_talk",
			"Job-investment conflict no longer resolves into Hyunsu's night mirror.")
	var required_transitions := {
		"arc_intro_01_meal->arc_intro_02_dad_call": "time_cut",
		"arc_intro_04_hyunsu->arc_chapter1_close": "explicit_move",
		"cafe_00->cafe_listen_01": "same_location",
		"cafe_listen_01->cafe_peek_01": "same_location",
		"cafe_peek_01->cafe_caught_honest": "same_location",
		"cafe_cb_honest_00->cafe_cb_honest_in": "explicit_move",
		"arc_gangnam_visit_alone->arc_four_months_in": "explicit_move",
		"arc_job_vs_invest->arc_hyunsu_night_talk": "explicit_move",
	}
	for transition_key in required_transitions:
		var transition_ids := str(transition_key).split("->", false, 1)
		var contract := DataRegistry.get_story_transition(transition_ids[0], transition_ids[1])
		_expect(str(contract.get("mode", "")) == str(required_transitions[transition_key]),
			"Demo transition contract drifted: %s." % transition_key)
	GameState.flags["story_first_paycheck_seen"] = true
	GameState.flags.erase("story_first_savings_seen")
	GameState.flags.erase("story_first_savings_pending")
	GameState.turn = 17
	GameState.money = 3_000_000.0
	_expect(str(main_game.call("_next_milestone_id")).is_empty(),
		"First savings milestone interrupted Jiyeon's week-seventeen scene.")
	_expect(GameState.flags.get("story_first_savings_pending", false),
		"Crossing three million won was not latched for the next quiet week.")
	GameState.turn = 18
	GameState.money = 2_900_000.0
	_expect(str(main_game.call("_next_milestone_id")) == "story_first_savings_milestone",
		"A latched savings milestone vanished after later AP spending.")
	main_game.free()

func _check_side_shift_pay() -> void:
	var aruba_script := load("res://scenes/ArubaGame.gd") as Script
	if aruba_script == null:
		_failures.append("ArubaGame.gd failed to load.")
		return
	var constants := aruba_script.get_script_constant_map()
	var base_pay := int(constants.get("BASE_PAY", 0))
	_expect(base_pay >= 82_560 and base_pay <= 120_000,
		"One side shift must stay near a 2026 eight-hour minimum-wage day, got %d." % base_pay)

func _check_ap_bonus_surface() -> void:
	var packed := load("res://scenes/MainGame.tscn") as PackedScene
	if packed == null:
		_failures.append("MainGame.tscn failed to load for AP checks.")
		return
	var main_game := packed.instantiate()
	GameState.max_action_points = 2
	GameState.action_points = 3
	var status := str(main_game.call("_ap_status_text"))
	var remaining := str(main_game.call("_ap_remaining_text"))
	_expect(not status.contains("3/2"), "Bonus AP surfaced as the invalid-looking fraction 3/2.")
	_expect(status.contains("+1"), "Bonus AP status did not explain the extra point: %s." % status)
	_expect(remaining.contains("+1"), "AP rail did not mark the extra point as a bonus: %s." % remaining)
	main_game.free()

func _check_demo_pressure_contract() -> void:
	var packed := load("res://scenes/MainGame.tscn") as PackedScene
	if packed == null:
		_failures.append("MainGame.tscn failed to load for demo pressure checks.")
		return
	GameState.start_new_game("김민준", "지방_상경", "직장형", "백수", "자유런", "현실")
	GameState.turn = 1
	GameState.current_job = {}
	GameState.flags["arc_intro_meal_seen"] = true
	var main_game := packed.instantiate()
	var before: Dictionary = GameState.serialize()
	var pressure: Dictionary = main_game.call("_demo_week_pressure")
	var actions: Array = pressure.get("action_ids", [])
	_expect(str(pressure.get("id", "")) == "chapter1_intent",
		"Demo week 1 must ask the player to own Minjun's opening plan: %s." % pressure)
	_expect(actions.size() == 3,
		"Demo primary pressure must offer exactly three contextual responses.")
	_expect(GameState.serialize() == before, "Reading the demo pressure mutated GameState.")
	GameState.turn = GameState.DEMO_TURN_LIMIT
	var week_24_pressure: Dictionary = main_game.call("_demo_week_pressure")
	_expect(not week_24_pressure.is_empty(),
		"Week 24 lost the contextual pressure surface.")
	GameState.turn = 29
	var full_run_pressure: Dictionary = main_game.call("_demo_week_pressure")
	_expect(not full_run_pressure.is_empty(),
		"The contextual decision surface did not carry into the full run.")
	GameState.turn = GameState.RUN_TURN_LIMIT + 1
	var post_run_pressure: Dictionary = main_game.call("_demo_week_pressure")
	_expect(post_run_pressure.is_empty(),
		"The contextual pressure surface leaked beyond the five-year run.")
	main_game.free()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
