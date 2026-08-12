extends Node

const CORE_LOOP := preload("res://systems/DemoCoreLoopV2.gd")
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
	_check_v2_preplan_opening_contract()
	_check_v2_legacy_paused_send_contract()
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
	print("DEMO_BUILD_CHECK_OK feature=%s cutoff=%d chain=%d presets=%d fresh_w1=guided_typed roots=0 legacy_paused_send=1" % [
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

func _check_v2_preplan_opening_contract() -> void:
	GameState.start_new_game(
		"김민준", "지방_상경", "직장형", "백수", "자유런", "현실")
	_expect(CORE_LOOP.initialize_for_run(true),
		"Fresh V2 opening fixture could not initialize.")
	GameState.turn = 1
	GameState.flags["prologue_done"] = true
	var opening_roots := ["arc_intro_01_meal", "v2_opening_return_math"]
	_expect(CORE_LOOP.begin_fresh_w1_onboarding(),
		"Fresh V2 opening did not create its guided W1 owner.")
	_expect(CORE_LOOP.fresh_preplan_opening_roots().is_empty(),
		"Fresh V2 entry reserved interview/calculation before the W1 action.")
	_expect(CORE_LOOP.opening_follow_up_event(
			"story_prologue_meal", "story_pressure", opening_roots).is_empty(),
		"Fresh prologue did not stop before the guided W1 board.")
	var before_story_send: Dictionary = GameState.serialize().duplicate(true)
	_expect(not CORE_LOOP.story_choice_commit_available(
			CORE_LOOP.OPENING_APPLICATION_EVENT_ID, 0, []) \
			and not CORE_LOOP.note_story_choice(
				CORE_LOOP.OPENING_APPLICATION_EVENT_ID, 0, []) \
			and GameState.serialize() == before_story_send,
		"Fresh opening allowed the retired Story Send to write material state.")

	var initialized := CORE_LOOP.initialize_seoul_cycle(1)
	var cycle := CORE_LOOP.seoul_cycle_snapshot(1)
	var capacities: Array = cycle.get("capacities", [])
	if not bool(initialized.get("ok", false)) or capacities.is_empty():
		_failures.append("The guided W1 Seoul Cycle board could not initialize.")
		return
	var capacity: Dictionary = capacities[0]
	var allocation := CORE_LOOP.commit_seoul_cycle_allocation(
		str(capacity.get("id", "")), CORE_LOOP.W1_ONBOARDING_NODE_ID, 1)
	var trigger_claim := CORE_LOOP.claim_seoul_cycle_trigger()
	var typed_action_ready := bool(allocation.get("ok", false)) \
		and bool(trigger_claim.get("ok", false)) \
		and CORE_LOOP.begin_seoul_cycle_trigger(
			CORE_LOOP.W1_ONBOARDING_BUNDLE_ID) \
		and GameState.arm_weekly_commitment({
			"turn": 1,
			"pressure_id": CORE_LOOP.W1_ONBOARDING_BUNDLE_ID,
			"pressure_family": "growth",
			"choice_id": "resume",
			"forgone_ids": [],
			"supplemental_to_seoul_cycle": true,
		}) \
		and CORE_LOOP.restart_fresh_w1_minigame()
	_expect(typed_action_ready,
		"The guided board did not hand its exact W1 action to the minigame.")
	if not typed_action_ready:
		return
	var transaction := CORE_LOOP.finalize_fresh_w1_application(2, 2)
	_expect(bool(transaction.get("ok", false)) \
			and CORE_LOOP.complete_active_bundle() \
				== CORE_LOOP.W1_ONBOARDING_BUNDLE_ID \
			and CORE_LOOP.fresh_w1_onboarding_phase() == "action_completed" \
			and CORE_LOOP.claim_fresh_w1_opening_interview(),
		"The typed W1 action did not submit and present its interview owner.")
	var presented_receipt: Dictionary = (
		GameState.core_loop_v2_state.get(
			"consequence_receipts", {}) as Dictionary
	).get(CORE_LOOP.OPENING_INTERVIEW_BUNDLE_ID, {})
	_expect(str(presented_receipt.get("status", "")) == "presented" \
			and presented_receipt.get("roots", []) == opening_roots \
			and str(presented_receipt.get("claim_source", "")) \
				== "typed_action_receipt" \
			and CORE_LOOP.application_status(
				"mirae_industrial_tech") == "submitted",
		"Typed W1 Send did not persist its submitted application and receipt.")

	CORE_LOOP.prepare_story_bundle(CORE_LOOP.OPENING_INTERVIEW_BUNDLE_ID)
	var interview_event: Dictionary = DataRegistry.find_event(
		"arc_intro_01_meal")
	var interview_choices: Array = interview_event.get("choices", [])
	if interview_choices.size() != 2:
		_failures.append("The V2 opening interview lost its two answers.")
		return
	_expect(GameState.apply_choice(
			interview_event, interview_choices[0] as Dictionary) \
			and CORE_LOOP.note_story_choice("arc_intro_01_meal", 0) \
			and CORE_LOOP.application_status(
				"mirae_industrial_tech") == "interviewed",
		"The V2 interview did not advance the submitted application exactly once.")

	var math_event: Dictionary = DataRegistry.find_event(
		"v2_opening_return_math")
	var math_choices: Array = math_event.get("choices", [])
	if math_choices.size() != 2:
		_failures.append("The 125-year calculation lost its two expressions.")
		return
	var before_math: Dictionary = GameState.serialize().duplicate(true)
	_expect(GameState.is_expression_choice(math_choices[0] as Dictionary) \
			and GameState.apply_choice(
				math_event, math_choices[0] as Dictionary) \
			and CORE_LOOP.note_story_choice("v2_opening_return_math", 0) \
			and GameState.serialize() == before_math,
		"The 125-year expression mutated persistent game state.")
	CORE_LOOP.restore_story_bundle_followups()
	_expect(CORE_LOOP.complete_active_bundle() \
			== CORE_LOOP.OPENING_INTERVIEW_BUNDLE_ID,
		"The interview/calculation consequence did not consume its owner.")
	var consumed_receipt: Dictionary = (
		GameState.core_loop_v2_state.get(
			"consequence_receipts", {}) as Dictionary
	).get(CORE_LOOP.OPENING_INTERVIEW_BUNDLE_ID, {})
	_expect(str(consumed_receipt.get("status", "")) == "consumed" \
			and consumed_receipt.get("roots", []) == opening_roots \
			and str(consumed_receipt.get("claim_source", "")) \
				== "typed_action_receipt" \
			and CORE_LOOP.fresh_w1_onboarding_phase() == "consumed",
		"The consumed opening receipt lost its exact two-root history.")

	var main_script := load("res://scenes/MainGame.gd") as GDScript
	var main_game: Node = main_script.new()
	_expect(str(main_game.call("_opening_chapter_event_id")) \
			== "chapter_card_33",
		"Chapter 1 did not unlock after typed Send, interview, and calculation.")
	main_game.free()
	var opening_counts := {
		"story_pressure": 0,
		"v2_opening_application_send": 0,
		"arc_intro_01_meal": 0,
		"v2_opening_return_math": 0,
	}
	for raw_entry in GameState.event_log:
		if raw_entry is Dictionary:
			var event_id := str((raw_entry as Dictionary).get("event_id", ""))
			if opening_counts.has(event_id):
				opening_counts[event_id] = int(opening_counts[event_id]) + 1
	_expect(opening_counts == {
		"story_pressure": 0,
		"v2_opening_application_send": 0,
		"arc_intro_01_meal": 1,
		"v2_opening_return_math": 0,
	}, "Fresh W1 wrote Story application material, replayed the app-open card, or logged its expressions.")
	_expect(not bool(GameState.flags.get("mindset_saver", false)) \
			and not bool(GameState.flags.get("mindset_investor", false)) \
			and not bool(GameState.flags.get("mindset_founder", false)),
		"The expression-only calculation fabricated a legacy mindset.")

func _check_v2_legacy_paused_send_contract() -> void:
	GameState.start_new_game(
		"김민준", "지방_상경", "직장형", "백수", "자유런", "현실")
	_expect(CORE_LOOP.initialize_for_run(true),
		"Legacy paused-Send fixture could not initialize.")
	GameState.turn = 1
	GameState.flags["prologue_done"] = true
	var roots: Array = CORE_LOOP.fresh_preplan_opening_roots()
	var before_wrong_queue: Dictionary = GameState.serialize().duplicate(true)
	_expect(roots == ["arc_intro_01_meal", "v2_opening_return_math"] \
			and CORE_LOOP.fresh_w1_onboarding_snapshot().is_empty(),
		"Legacy no-marker save lost its exact adjacent interview/math queue.")
	_expect(not CORE_LOOP.story_choice_commit_available(
			CORE_LOOP.OPENING_APPLICATION_EVENT_ID, 0, []) \
			and not CORE_LOOP.note_story_choice(
				CORE_LOOP.OPENING_APPLICATION_EVENT_ID, 0, []) \
			and GameState.serialize() == before_wrong_queue,
		"Legacy Send accepted a missing or inexact reserved queue.")
	var send_event: Dictionary = DataRegistry.find_event(
		CORE_LOOP.OPENING_APPLICATION_EVENT_ID)
	var choices: Array = send_event.get("choices", [])
	if choices.size() != 1:
		_failures.append("The legacy paused-Send event is missing.")
		return
	var commit_available := CORE_LOOP.story_choice_commit_available(
		CORE_LOOP.OPENING_APPLICATION_EVENT_ID, 0, roots)
	var applied := commit_available and GameState.apply_choice(
		send_event, choices[0] as Dictionary)
	var recorded := applied and CORE_LOOP.note_story_choice(
		CORE_LOOP.OPENING_APPLICATION_EVENT_ID, 0, roots)
	var trigger: Dictionary = CORE_LOOP.bundle(
		CORE_LOOP.OPENING_INTERVIEW_BUNDLE_ID).get("preplan_trigger", {})
	_expect(commit_available and applied and recorded,
		"The exact legacy paused-Send save could not resume its authored click "
		+ ("(available=%s applied=%s recorded=%s status=%s active=%s "
		+ "trigger=%s pending=%s committed=%s flags=%s).") % [
			str(commit_available), str(applied), str(recorded),
			CORE_LOOP.application_status("mirae_industrial_tech"),
			CORE_LOOP.active_bundle_id(),
			str(trigger),
			str(GameState.has_pending_weekly_commitment(1)),
			str(GameState.has_weekly_commitment_for_turn(1)),
			str(GameState.flags),
		])
	var state: Dictionary = GameState.core_loop_v2_state
	var receipt: Dictionary = (
		state.get("consequence_receipts", {}) as Dictionary
	).get(CORE_LOOP.OPENING_INTERVIEW_BUNDLE_ID, {})
	var transition_key := "%s:%s:0:1" % [
		CORE_LOOP.OPENING_INTERVIEW_BUNDLE_ID,
		CORE_LOOP.OPENING_APPLICATION_EVENT_ID,
	]
	var transition: Dictionary = (
		state.get("application_transition_receipts", {}) as Dictionary
	).get(transition_key, {})
	_expect(CORE_LOOP.application_status(
			"mirae_industrial_tech") == "submitted" \
			and str(receipt.get("claim_source", "")) == "story_choice" \
			and receipt.get("roots", []) == roots \
			and str(transition.get("source", "")) == "legacy_story_send" \
			and CORE_LOOP.action_receipt(
				CORE_LOOP.W1_ONBOARDING_BUNDLE_ID).is_empty() \
			and not GameState.has_weekly_commitment_for_turn(1),
		"Legacy Send fabricated a fresh weekly action or lost its exact provenance.")

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
	_expect(int((exam_day.get("conditions", {}) as Dictionary).get("min_turn", 0)) == 24,
		"Hyunsu's exam data gate must open in week 24, at the demo exit.")
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
	GameState.current_job = DataRegistry.get_job("job_11").duplicate(true)
	_expect(not bool(main_game.call("_career_specialization_ready", GameState.flags)),
		"Company-ladder specialization appeared for a startup founder.")
	GameState.current_job = DataRegistry.get_job("job_03").duplicate(true)
	GameState.turn = 25
	GameState.flags["spec_elite"] = true
	GameState.flags.erase("arc_spec_elite_result_seen")
	_expect(bool(main_game.call(
		"_story_event_prerequisites_met",
		"arc_spec_elite_result", 25, GameState.flags)),
		"Elite specialization result did not open for an employed office route.")
	GameState.current_job = {}
	_expect(not bool(main_game.call(
		"_story_event_prerequisites_met",
		"arc_spec_elite_result", 25, GameState.flags)),
		"Elite specialization result survived after the player quit.")
	GameState.flags.erase("spec_elite")
	GameState.flags["spec_social_climber"] = true
	GameState.current_job = DataRegistry.get_job("job_03").duplicate(true)
	_expect(bool(main_game.call(
		"_story_event_prerequisites_met",
		"arc_spec_climber_result", 25, GameState.flags)),
		"Relationship specialization result did not open for an employed office route.")
	GameState.current_job = {}
	_expect(not bool(main_game.call(
		"_story_event_prerequisites_met",
		"arc_spec_climber_result", 25, GameState.flags)),
		"Relationship specialization result survived after the player quit.")
	GameState.flags.erase("spec_social_climber")
	GameState.turn = 16
	GameState.job_tenure = 3
	GameState.flags.erase("arc_office_routine_seen")
	GameState.current_job = DataRegistry.get_job("job_01").duplicate(true)
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
	_expect(str(DataRegistry.find_event("arc_temptation_clean").get("background", "")) == "current_housing",
		"Clean temptation aftermath stopped following the player's live home.")
	var medication_event: Dictionary = DataRegistry.find_event("arc_father_medication")
	_expect(str(medication_event.get("background", "")) == "subway",
		"Father medication message still assumes an office.")
	var medication_text := JSON.stringify(medication_event)
	_expect(not medication_text.contains("회의") and not medication_text.contains("자리로 돌아"),
		"Father medication message still narrates employment-only actions.")
	var orthodox_weight: Dictionary = DataRegistry.find_event("arc_35_orthodox_weight")
	_expect(str(orthodox_weight.get("background", "")) == "current_housing",
		"The orthodox route reflection still assumes an office.")
	var holdem_transfer: Dictionary = DataRegistry.find_event("holdem_skill_transfers")
	var holdem_conditions: Dictionary = holdem_transfer.get("conditions", {})
	_expect(bool(holdem_conditions.get("has_job", false)),
		"The office holdem-transfer event can still enter the random pool while unemployed.")
	for dynamic_event_id in [
		"anxiety_child_cost_calc",
		"arc_father_01_call", "arc_father_02_signal",
		"arc_hyunsu_lifeline_call", "arc_jiyeon_year4_call",
		"cafe_cb_stole_call", "cafe_cb_honest_00",
		"callback_asked_father_more_echo",
		"callback_called_about_medication_echo",
		"callback_called_dad_milestone_echo",
		"callback_called_hyunsu_scam_echo",
		"callback_child_cost_grind",
		"callback_chose_money_father_echo",
		"callback_daeun_breakup_begged_echo",
		"callback_daeun_daily_life_echo",
		"callback_father_promise",
		"callback_knows_dad_reason_echo",
		"callback_proactive_parent_care_echo",
		"callback_rushed_to_father_echo",
		"callback_sangchul_news_father_echo",
		"callback_sangchul_personal_echo",
		"callback_told_father_win_echo",
		"hyunsu_year4_echo", "hyunsu_year5_call",
		"rel_daeun_first_text",
	]:
		_expect(str(DataRegistry.find_event(dynamic_event_id).get(
			"background", "")) == "current_housing",
			"%s is still pinned to an obsolete home." % dynamic_event_id)
	_expect(str(DataRegistry.find_event("callback_father_confession_echo").get(
		"background", "")) == "cafe",
		"Sangchul's in-person tea callback is not grounded in the cafe.")
	_expect(str(DataRegistry.find_event("arc_intro_02_dad_call").get(
		"background", "")) == "goshiwon_room",
		"The fixed week-two goshiwon calculation lost its authored room.")
	_expect(str(DataRegistry.find_event("arc_father_ng_call").get(
		"background", "")) == "current_housing",
		"The NG+ father call stopped following the player's live home.")
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
	GameState.turn = 22
	GameState.money = 3_000_000.0
	_expect(str(main_game.call("_next_milestone_id")).is_empty(),
		"First savings milestone surfaced before its week-twenty-three slot.")
	_expect(GameState.flags.get("story_first_savings_pending", false),
		"Crossing three million won was not latched for week twenty-three.")
	GameState.turn = 23
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
	# Earlier temporal checks intentionally leave the state on an authored week.
	# Reset so this assertion measures the generic AP rail, not story ownership.
	GameState.start_new_game("김민준", "지방_상경", "직장형", "백수", "자유런", "현실")
	GameState.turn = 3
	GameState.money = 10_000_000.0
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
