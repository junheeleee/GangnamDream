extends Node
## ORDER-22: 행동→사건→주간 장면→소리의 연결을 런타임으로 검증한다.

const MainGameScript = preload("res://scenes/MainGame.gd")

var _failures: Array[String] = []
var _original_language := "ko"

func _ready() -> void:
	_original_language = LocaleManager.language
	_check_recent_action_echoes()
	_check_action_consequence_echoes()
	_check_weekly_commitment_contract()
	_check_scene_first_week_contract()
	_check_event_causality()
	_check_week_surface()
	_check_demo_pressure_choices()
	_check_full_run_pressure_diversity()
	_check_demo_pacing()
	_check_arc_preview_read_only()
	_check_sfx_mix()
	LocaleManager.language = _original_language
	DataRegistry.reload()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("IMMERSION_LOOP_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("IMMERSION_LOOP_CHECK_OK memory=2 action_ids=8 commitments=1x3 scene_first=1 no_ap_surface=1 auto_advance=1 outcomes=2 completion_boundary=1 consequence_paths=4 echo=2.6 prior=1.88 filler=0.42 quiet=3 causal=4 vignette=2 omen=1 preview=2 rent=1 pressures=11 families=6 cards=3 pacing=9/2/4 sfx=8")
	get_tree().quit(0)

func _check_recent_action_echoes() -> void:
	GameState.start_new_game()
	GameState.register_action_axis("money", "work")
	GameState.finalize_action_axis_week()
	var first := GameState.get_recent_action_echoes()
	_expect_close(float(first.get("jobs", 0.0)), 1.0, "latest work action did not create a job echo")
	if first.has("investment") or first.has("gambling"):
		_fail("job hunt leaked into investment or gambling echoes")

	GameState.register_action_axis("human", "city")
	GameState.finalize_action_axis_week()
	var second := GameState.get_recent_action_echoes()
	_expect_close(float(second.get("relationship", 0.0)), 1.0, "latest city action did not create a relationship echo")
	_expect_close(float(second.get("jobs", 0.0)), 0.55, "prior work echo did not decay to one-week strength")
	if GameState.recent_action_weeks.size() != 2:
		_fail("recent action memory is not capped at two weeks")

	var saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	var restored := GameState.get_recent_action_echoes()
	_expect_close(float(restored.get("relationship", 0.0)), 1.0, "latest action echo did not survive save/load")
	_expect_close(float(restored.get("jobs", 0.0)), 0.55, "prior action echo did not survive save/load")
	GameState.register_action_axis("money")
	GameState.finalize_action_axis_week()
	_expect_close(float(GameState.get_recent_action_echoes().get("investment", 0.0)), 1.0,
		"place-less asset trade did not create an investment echo")
	if GameState.get_recent_action_echoes().has("jobs"):
		_fail("third week did not evict the oldest action echo")

func _check_action_consequence_echoes() -> void:
	GameState.start_new_game()
	GameState.register_action_axis("money", "work", "apply")
	GameState.finalize_action_axis_week()
	var application_records := GameState.get_latest_action_records()
	if application_records.size() != 1 or str(application_records[0].get("id", "")) != "apply":
		_fail("application action identity was not finalized: %s" % application_records)
	var saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	var restored_records := GameState.get_latest_action_records()
	if restored_records.size() != 1 or str(restored_records[0].get("id", "")) != "apply":
		_fail("application action identity did not survive save/load: %s" % restored_records)

	var job_event := _event("qa_exact_job_echo", "jobs", ["work"], {"min_turn": 1})
	LocaleManager.language = "ko"
	var application_frame_ko := EventManager.causal_frame_for(job_event)
	if not (application_frame_ko.contains("지원서") or application_frame_ko.contains("메일함")):
		_fail("application event lost its exact Korean cause: %s" % application_frame_ko)
	LocaleManager.language = "en"
	var application_frame_en := EventManager.causal_frame_for(job_event)
	if application_frame_en.findn("application") < 0 or _contains_hangul(application_frame_en):
		_fail("application event lost its exact English cause: %s" % application_frame_en)

	GameState.start_new_game()
	GameState.register_action_axis("human", "home", "rest")
	GameState.finalize_action_axis_week()
	var health_event := _event("qa_exact_health_echo", "health", ["rest"], {"min_turn": 1})
	LocaleManager.language = "ko"
	var rest_frame_ko := EventManager.causal_frame_for(health_event)
	LocaleManager.language = "en"
	var rest_frame_en := EventManager.causal_frame_for(health_event)
	if not (rest_frame_ko.contains("멈춘") or rest_frame_ko.contains("비워 둔")):
		_fail("rest event lost its exact Korean cause: %s" % rest_frame_ko)
	if rest_frame_en.findn("application") >= 0 or _contains_hangul(rest_frame_en):
		_fail("rest event inherited the application cause: %s" % rest_frame_en)
	if application_frame_en == rest_frame_en:
		_fail("different AP choices collapsed into the same event cause")

	var game = MainGameScript.new()
	LocaleManager.language = "en"
	var state_before_preview: Dictionary = GameState.serialize()
	var rest_echo := str(game.call("_demo_director_recent_action_line"))
	if rest_echo.findn("rest") < 0 or rest_echo.findn("application") >= 0:
		_fail("rest path did not create a distinct weekly echo: %s" % rest_echo)
	if GameState.serialize() != state_before_preview:
		_fail("weekly action echo preview mutated game state")
	GameState.start_new_game()
	GameState.register_action_axis("human", "store", "contact", "daeun")
	GameState.register_action_axis("money", "store", "save")
	GameState.finalize_action_axis_week()
	var contact_save_echo := str(game.call("_demo_director_recent_action_line"))
	if contact_save_echo.findn("Daeun") < 0 or contact_save_echo.findn("cutting back") < 0:
		_fail("weekly echo did not preserve both distinct choices: %s" % contact_save_echo)
	var forbidden_surface := contact_save_echo.to_lower()
	if forbidden_surface.contains("moral") or forbidden_surface.contains("route") \
			or contact_save_echo.contains("도덕"):
		_fail("weekly action echo exposed a hidden system: %s" % contact_save_echo)
	game.free()

func _check_weekly_commitment_contract() -> void:
	GameState.start_new_game()
	GameState.turn = 1
	GameState.action_points = 2
	var game = MainGameScript.new()
	var pressure := {
		"id": "qa_commitment",
		"family": "employment",
		"person_id": "daeun",
		"action_ids": ["invest", "study", "contact"],
	}
	for language in ["ko", "en"]:
		LocaleManager.language = language
		for action_id in pressure.get("action_ids", []):
			var preview: Dictionary = game.call("_weekly_commitment_preview", action_id, "daeun")
			for key in ["risk", "now", "cost", "later"]:
				if str(preview.get(key, "")).strip_edges().is_empty():
					_fail("weekly commitment %s has no %s preview" % [action_id, key])
			if language == "en" and _contains_hangul(" ".join(preview.values())):
				_fail("English weekly commitment preview leaked Hangul: %s" % preview)

	LocaleManager.language = "ko"
	var invest_payload: Dictionary = game.call("_weekly_commitment_payload", pressure, "invest")
	if not GameState.arm_weekly_commitment(invest_payload):
		_fail("investment commitment could not be armed")
	if GameState.action_points != 2 or not GameState.weekly_commitments.is_empty():
		_fail("opening a cancelable commitment spent the week before a real action")
	GameState.cancel_pending_weekly_commitment(GameState.turn)
	if not GameState.pending_weekly_commitment.is_empty():
		_fail("canceling a commitment left a pending lock")

	if not GameState.arm_weekly_commitment(invest_payload):
		_fail("investment commitment could not be re-armed after cancel")
	GameState.register_action_axis("money", "city", "invest_buy")
	if GameState.action_points != 2 or not GameState.weekly_commitments.is_empty() \
			or not GameState.has_pending_weekly_commitment(GameState.turn):
		_fail("opening/recording a sub-action finalized the commitment before its outcome")
	GameState.add_money(-100_000.0)
	GameState.modify_stat("investment_skill", 1)
	if not GameState.finalize_weekly_commitment("invest_buy", "", {
		"asset_id": "asset_01", "trade": "buy", "amount": 100_000.0,
	}):
		_fail("actual trade could not finalize the armed commitment")
	if GameState.action_points != 0 or GameState.weekly_commitments.size() != 1:
		_fail("actual trade did not close the week exactly once: AP=%d records=%d" % [
			GameState.action_points, GameState.weekly_commitments.size()])
	var record: Dictionary = GameState.weekly_commitments[0]
	if str(record.get("choice_id", "")) != "invest" \
			or str(record.get("actual_action_id", "")) != "invest_buy" \
			or (record.get("forgone_ids", []) as Array).size() != 2:
		_fail("weekly commitment lost its choice, actual action, or forgone paths: %s" % record)
	var outcome: Dictionary = record.get("outcome", {})
	if not is_equal_approx(float(outcome.get("money", 0.0)), -100_000.0) \
			or int(outcome.get("investment_skill", 0)) != 1:
		_fail("weekly commitment lost its actual public outcome: %s" % outcome)
	if GameState.arm_weekly_commitment(game.call("_weekly_commitment_payload", pressure, "study")):
		_fail("a second commitment was accepted in the same week")

	var saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	if GameState.weekly_commitments.size() != 1:
		_fail("weekly commitment did not survive save/load")
	GameState.turn = 2
	var unresolved := GameState.get_unresolved_weekly_commitments(2)
	if unresolved.size() != 1:
		_fail("next week could not see the unresolved commitment: %s" % unresolved)
	LocaleManager.language = "en"
	var echo_record := str(game.call("_demo_director_recent_action_record", unresolved))
	if echo_record.findn("chosen") < 0 or echo_record.findn("not chosen that week") < 0 \
			or echo_record.findn("actual result") < 0 or echo_record.findn("cash") < 0 \
			or echo_record.findn("market") < 0 or _contains_hangul(echo_record):
		_fail("weekly commitment echo did not name the choice, outcome, and paths not chosen that week: %s" % echo_record)
	var forbidden := echo_record.to_lower()
	if forbidden.contains("moral") or forbidden.contains("route"):
		_fail("weekly commitment echo exposed a hidden system: %s" % echo_record)
	if GameState.consume_weekly_commitment_echoes(2).size() != 1 \
			or not GameState.consume_weekly_commitment_echoes(2).is_empty():
		_fail("weekly commitment echo was not consumed exactly once")
	game.free()

func _check_scene_first_week_contract() -> void:
	GameState.start_new_game()
	GameState.turn = 1
	GameState.month = 1
	GameState.week_of_month = 1
	GameState.current_job = {}
	GameState.flags["arc_intro_meal_seen"] = true
	var game = MainGameScript.new()
	game.current_event = {}
	if not bool(game.call("_scene_first_week_enabled")):
		_fail("direct week did not opt into the scene-first surface")
	var pressure: Dictionary = game.call("_demo_week_pressure")
	var scene_paths: Array[String] = []
	for raw_action_id in pressure.get("action_ids", []):
		var spec: Dictionary = game.call(
			"_demo_action_spec", str(raw_action_id), str(pressure.get("person_id", "")))
		var scene_path := str(game.call(
			"_action_scene_background_path", str(spec.get("fn", "")), str(spec.get("icon", ""))))
		if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
			_fail("scene-first choice has no valid full-scene background: %s" % raw_action_id)
		else:
			scene_paths.append(scene_path)
	if scene_paths.size() != 3:
		_fail("scene-first week does not expose exactly three scene-backed choices")
	var contact_spec: Dictionary = game.call("_demo_action_spec", "contact", "daeun")
	var contact_scenarios := [
		{"turn": 1, "job": {}},
		{"turn": 2, "job": {"id": "job_03"}},
		{"turn": 3, "job": {"id": "job_01"}},
		{"turn": 4, "job": {"id": "job_03"}},
	]
	var contact_paths := {}
	for scenario in contact_scenarios:
		GameState.turn = int(scenario.get("turn", 1))
		GameState.current_job = (scenario.get("job", {}) as Dictionary).duplicate(true)
		var contact_scene := str(game.call(
			"_action_scene_background_path", str(contact_spec.get("fn", "")),
			str(contact_spec.get("icon", ""))))
		if contact_scene.is_empty() or not ResourceLoader.exists(contact_scene) \
				or contact_scene.findn("cafe") >= 0:
			_fail("remote contact preview has an invalid or face-to-face location: %s" % contact_scene)
		else:
			contact_paths[contact_scene] = true
	if contact_paths.size() < 4:
		_fail("remote calls still collapse into one location instead of home/transit/work/outdoors: %s" % contact_paths.keys())

	GameState.turn = 3
	GameState.action_points = 2
	GameState.current_job = {"id": "job_01"}
	var contact_pressure := {
		"id": "qa_contact_location",
		"family": "relationship",
		"person_id": "daeun",
		"action_ids": ["contact", "study", "save"],
	}
	var contact_payload: Dictionary = game.call(
		"_weekly_commitment_payload", contact_pressure, "contact")
	var original_background_id := str(contact_payload.get("scene_background_id", ""))
	if original_background_id != "convenience_night" \
			or not GameState.arm_weekly_commitment(contact_payload):
		_fail("contact commitment did not capture its original workplace: %s" % contact_payload)
	elif str(GameState.pending_weekly_commitment.get("scene_background_id", "")) \
			!= original_background_id:
		_fail("arming a contact commitment discarded its original location")
	elif not GameState.finalize_weekly_commitment("contact", "daeun"):
		_fail("contact commitment could not finalize for location persistence")
	else:
		var original_record := GameState.get_weekly_commitment_for_turn(3)
		var original_scene := str(game.call("_scene_background_for_commitment", original_record))
		var saved: Dictionary = GameState.serialize()
		GameState.start_new_game()
		GameState.load_from_dict(saved)
		GameState.turn = 90
		GameState.current_job = {"id": "job_03"}
		GameState.housing = "apartment"
		var restored_record := GameState.get_weekly_commitment_for_turn(3)
		var restored_scene := str(game.call("_scene_background_for_commitment", restored_record))
		if original_scene.is_empty() or restored_scene != original_scene \
				or restored_scene.findn("convenience_store_night") < 0:
			_fail("contact location changed after save/load or later life changes: %s -> %s" % [
				original_scene, restored_scene])
	game.free()

func _check_event_causality() -> void:
	GameState.start_new_game()
	GameState.run_theme_categories = []
	GameState.month_focus = ""
	GameState.register_action_axis("money", "work")
	GameState.finalize_action_axis_week()
	GameState.register_action_axis("human", "city")
	GameState.finalize_action_axis_week()

	var job_event := _event("qa_job_echo", "jobs", ["work"], {"min_turn": 1})
	var social_event := _event("qa_social_echo", "relationship", ["social"], {"min_turn": 1})
	var unrelated_event := _event("qa_unrelated_echo", "disasters", ["weather"], {"min_turn": 1})
	var story_event := _event("arc_qa_story", "story", ["arc"], {"min_turn": 1})
	story_event["rarity"] = "story"
	_expect_close(EventManager.action_echo_multiplier(job_event), 1.88, "prior-week job event multiplier is wrong", 0.002)
	_expect_close(EventManager.action_echo_multiplier(social_event), 2.6, "latest social event multiplier is wrong")
	_expect_close(EventManager.action_echo_multiplier(unrelated_event), 1.0, "unrelated event received an action boost")
	_expect_close(EventManager.action_echo_multiplier(story_event), 1.0, "authored story arc received random-pool action weighting")

	LocaleManager.language = "ko"
	var frame_ko := EventManager.causal_frame_for(social_event)
	if frame_ko.is_empty() or not _contains_hangul(frame_ko):
		_fail("Korean causal frame is missing")
	LocaleManager.language = "en"
	var frame_en := EventManager.causal_frame_for(social_event)
	if frame_en.is_empty() or _contains_hangul(frame_en):
		_fail("English causal frame is missing or leaked Hangul: %s" % frame_en)

	GameState.recent_action_weeks = []
	var filler := _event("qa_filler", "daily_life", [], {})
	var conditioned := _event("qa_conditioned", "daily_life", [], {"min_turn": 1})
	_expect_close(EventManager._effective_weight(filler), 0.42, "unconditional filler attenuation is wrong")
	_expect_close(EventManager._effective_weight(conditioned), 1.0, "conditioned event was attenuated as filler")
	GameState.turn = 6
	_expect_close(EventManager.quiet_week_chance([filler]), 0.0, "first eight demo weeks can be silenced")
	GameState.turn = 12
	_expect_close(EventManager.quiet_week_chance([filler, _event("qa_filler_2", "daily_life", [], {})]), 0.28,
		"filler-heavy quiet-week chance is wrong")
	GameState.recent_action_weeks = [{"turn": 11, "money": 0, "human": 1, "places": {"city": {"count": 1}}}]
	_expect_close(EventManager.quiet_week_chance([social_event]), 0.04,
		"strong action echo should nearly eliminate quiet weeks")

func _check_week_surface() -> void:
	GameState.start_new_game()
	GameState.turn = 1
	GameState.month = 1
	GameState.week_of_month = 1
	GameState.housing = "gosiwon"
	GameState.flags["prologue_done"] = true
	GameState.flags["chapter_33_seen"] = true
	GameState.flags["arc_intro_meal_seen"] = true
	GameState.flags["arc_intro_dad_seen"] = false
	var game = MainGameScript.new()

	LocaleManager.language = "ko"
	var opening_ko := game._week_opening_line()
	if not opening_ko.contains("겨울") or not (opening_ko.contains("벽") or opening_ko.contains("복도")):
		_fail("Korean weekly opening does not establish winter goshiwon space: %s" % opening_ko)
	var flags_before: Dictionary = GameState.flags.duplicate(true)
	var omen_ko := game._upcoming_arc_foreshadow_line()
	if omen_ko.is_empty() or not omen_ko.contains("창원"):
		_fail("two-week father arc did not create a subtle omen: %s" % omen_ko)
	if GameState.flags != flags_before:
		_fail("preview-only arc query mutated story flags")

	LocaleManager.language = "en"
	var opening_en := game._week_opening_line()
	var omen_en := game._upcoming_arc_foreshadow_line()
	if _contains_hangul(opening_en + omen_en) or opening_en.findn("winter") < 0 or omen_en.findn("Changwon") < 0:
		_fail("English weekly opening/omen is incomplete: %s | %s" % [opening_en, omen_en])

	GameState.week_of_month = 4
	GameState.money = 0.0
	GameState.monthly_income = 0.0
	var rent := game._week_rent_deadline()
	if not bool(rent.get("urgent", false)) or bool(rent.get("covered", true)) \
			or not str(rent.get("text", "")).contains("RENT DUE"):
		_fail("rent due week is not presented as an uncovered threat: %s" % rent)
	game.free()

func _check_arc_preview_read_only() -> void:
	GameState.start_new_game()
	GameState.turn = 40
	GameState.month = 10
	GameState.week_of_month = 1
	GameState.age = 33
	GameState.housing = "gosiwon"
	# 모든 앞선 1회성 장면을 본 상태로 만들어 퇴사 직후 분기까지 직접 도달한다.
	for event in DataRegistry.get_all_events():
		for choice in event.get("choices", []):
			for raw_flag in choice.get("flags", []):
				var flag := str(raw_flag)
				if flag.ends_with("_seen") or flag.ends_with("_done") or flag.ends_with("_closed"):
					GameState.flags[flag] = true
	GameState.flags["prologue_done"] = true
	GameState.flags["arc_daeun_met"] = true
	GameState.flags["hyunsu_failed"] = true
	GameState.flags["just_quit_job"] = true
	GameState.flags.erase("arc_quit_job_seen")
	var game = MainGameScript.new()
	var preview_id := game._next_arc_id(GameState.turn, true)
	if preview_id != "arc_quit_job":
		_fail("preview fixture did not reach the quit-job arc: %s" % preview_id)
	if not bool(GameState.flags.get("just_quit_job", false)):
		_fail("preview-only arc query consumed the live quit-job flag")
	var live_id := game._next_arc_id()
	if live_id != "arc_quit_job" or GameState.flags.has("just_quit_job"):
		_fail("live quit-job query did not consume its one-shot flag: %s" % live_id)
	game.free()

func _check_demo_pressure_choices() -> void:
	GameState.start_new_game()
	GameState.turn = 1
	GameState.month = 1
	GameState.week_of_month = 1
	GameState.housing = "gosiwon"
	GameState.current_job = {}
	GameState.monthly_income = 0.0
	GameState.money = 500_000.0
	GameState.health = 65
	GameState.mental = 60
	GameState.flags["arc_intro_meal_seen"] = true
	var game = MainGameScript.new()

	LocaleManager.language = "ko"
	var state_before: Dictionary = GameState.serialize()
	var intent: Dictionary = game._demo_week_pressure()
	_check_pressure_contract(game, intent, "chapter1_intent", ["apply", "side_shift", "study"])
	if GameState.serialize() != state_before:
		_fail("demo pressure preview mutated GameState")
	GameState.flags["chapter_intent_id"] = "secure_work"
	GameState.flags["chapter_intent_turn"] = 1
	GameState.turn = 2
	GameState.week_of_month = 2
	var readiness: Dictionary = game._demo_week_pressure()
	_check_pressure_contract(game, readiness, "employment_readiness", ["resume", "study", "apply"])
	GameState.flags["resume_polished"] = true
	var followup: Dictionary = game._demo_week_pressure()
	_check_pressure_contract(game, followup, "employment_followup", ["apply", "study", "side_shift"])
	GameState.flags.erase("resume_polished")
	GameState.turn = 3
	GameState.week_of_month = 3
	var survival: Dictionary = game._demo_week_pressure()
	_check_pressure_contract(game, survival, "employment_survival", ["side_shift", "save", "apply"])

	GameState.current_job = {"id": "job_03", "name": "사무직", "tier": 2}
	GameState.monthly_income = 0.0
	GameState.money = 0.0
	GameState.week_of_month = 4
	var rent: Dictionary = game._demo_week_pressure()
	_check_pressure_contract(game, rent, "rent", ["side_shift", "save", "rest"])

	GameState.health = 40
	var condition: Dictionary = game._demo_week_pressure()
	_check_pressure_contract(game, condition, "condition", ["rest", "side_shift", "contact"])

	GameState.health = 65
	GameState.mental = 65
	GameState.money = 2_000_000.0
	GameState.monthly_income = 2_500_000.0
	GameState.week_of_month = 2
	GameState.grind_streak_weeks = 3
	var relationship: Dictionary = game._demo_week_pressure()
	_check_pressure_contract(game, relationship, "relationship", ["contact", "side_shift", "rest"])

	GameState.grind_streak_weeks = 0
	GameState.flags["arc_invest_guidance_seen"] = true
	GameState.flags.erase("investment_first_visited")
	GameState.turn = 3
	GameState.month = 3
	GameState.week_of_month = 3
	var capital: Dictionary = game._demo_week_pressure()
	_check_pressure_contract(game, capital, "capital", ["invest", "save", "contact"])
	var capital_windows := 0
	var capital_per_month: Dictionary = {}
	for week in range(1, GameState.DEMO_TURN_LIMIT + 1):
		GameState.turn = week
		GameState.month = int((week - 1) / 4) + 1
		GameState.week_of_month = posmod(week - 1, 4) + 1
		var pressure: Dictionary = game._demo_week_pressure()
		if str(pressure.get("id", "")) != "capital":
			continue
		capital_windows += 1
		var month_index := int((week - 1) / 4)
		capital_per_month[month_index] = int(capital_per_month.get(month_index, 0)) + 1
	if capital_windows != 2:
		_fail("demo capital pressure must appear once per quarter, got %d" % capital_windows)
	for month_index in capital_per_month:
		if int(capital_per_month[month_index]) > 1:
			_fail("demo capital pressure repeated within month %s" % month_index)

	LocaleManager.language = "en"
	GameState.turn = 23
	GameState.month = 6
	GameState.week_of_month = 3
	var capital_en: Dictionary = game._demo_week_pressure()
	_check_pressure_contract(game, capital_en, "capital", ["invest", "save", "contact"])
	var surface := "%s %s %s" % [
		str(capital_en.get("title", "")), str(capital_en.get("question", "")), str(capital_en.get("detail", ""))]
	if _contains_hangul(surface):
		_fail("English demo pressure leaked Hangul: %s" % surface)
	for hidden_word in ["moral", "route score", "morality score"]:
		if surface.to_lower().contains(hidden_word):
			_fail("demo pressure exposed hidden system vocabulary: %s" % hidden_word)
	game.free()

func _check_full_run_pressure_diversity() -> void:
	var language_before := LocaleManager.language
	var fixtures: Array[Dictionary] = [
		{"turn": 29, "week": 1, "job": "job_03", "housing": "gosiwon", "person": true},
		{"turn": 37, "week": 2, "job": "job_03", "housing": "oneroom", "person": true, "money_weeks": 4},
		{"turn": 45, "week": 4, "job": "job_03", "housing": "gosiwon", "person": true, "human_weeks": 3},
		{"turn": 61, "week": 1, "job": "job_06", "housing": "oneroom", "person": true, "invest": true, "portfolio": 1},
		{"turn": 69, "week": 2, "job": "job_03", "housing": "gosiwon", "person": true, "invest": true},
		{"turn": 77, "week": 4, "job": "job_06", "housing": "oneroom", "person": true, "invest": true, "portfolio": 2},
		{"turn": 109, "week": 1, "job": "job_10", "housing": "villa", "person": true, "invest": true, "portfolio": 1},
		{"turn": 121, "week": 2, "job": "job_10", "housing": "oneroom", "person": true},
		{"turn": 137, "week": 4, "job": "job_10", "housing": "villa", "person": true, "mental": 54},
		{"turn": 157, "week": 1, "job": "job_10", "housing": "villa", "person": true},
		{"turn": 173, "week": 2, "job": "job_03", "housing": "oneroom", "person": true, "health": 54},
		{"turn": 189, "week": 4, "job": "job_13", "housing": "apartment", "person": true},
		{"turn": 205, "week": 1, "job": "job_13", "housing": "apartment", "person": true, "invest": true, "portfolio": 1},
		{"turn": 213, "week": 4, "job": "job_13", "housing": "apartment", "person": true, "invest": true, "portfolio": 1},
		{"turn": 221, "week": 2, "job": "job_13", "housing": "apartment", "person": true, "invest": true, "portfolio": 2},
		{"turn": 229, "week": 4, "job": "job_13", "housing": "apartment", "person": true, "invest": true, "portfolio": 1},
		{"turn": 237, "week": 1, "job": "job_13", "housing": "apartment", "person": true, "invest": true, "portfolio": 1},
	]
	var ids_by_language: Dictionary = {}
	var ko_families: Dictionary = {}
	var ko_chapter_families: Array[Dictionary] = [{}, {}, {}, {}, {}]
	var game = MainGameScript.new()
	for language in ["ko", "en"]:
		LocaleManager.language = language
		DataRegistry.reload()
		var ids: Array[String] = []
		for fixture in fixtures:
			_configure_pressure_fixture(fixture)
			var state_before: Dictionary = GameState.serialize()
			var pressure: Dictionary = game._demo_week_pressure()
			var pressure_id := str(pressure.get("id", ""))
			var family := str(pressure.get("family", ""))
			ids.append(pressure_id)
			if GameState.serialize() != state_before:
				_fail("full-run pressure preview mutated GameState at turn %d" % GameState.turn)
			var actions: Array = pressure.get("action_ids", [])
			var unique_actions: Dictionary = {}
			for action_value in actions:
				var action_id := str(action_value)
				unique_actions[action_id] = true
				var spec: Dictionary = game._demo_action_spec(action_id, str(pressure.get("person_id", "")))
				if spec.is_empty() or str(spec.get("fn", "")).is_empty():
					_fail("full-run pressure %s has an unbound action: %s" % [pressure_id, action_id])
			if actions.size() != 3 or unique_actions.size() != 3:
				_fail("full-run pressure %s must expose three distinct actions: %s" % [pressure_id, actions])
			if family.is_empty():
				_fail("full-run pressure %s has no family" % pressure_id)
			if language == "ko":
				ko_families[family] = true
				ko_chapter_families[mini(4, floori(float(GameState.turn - 1) / 48.0))][family] = true
			else:
				var surface := "%s %s %s" % [
					str(pressure.get("title", "")),
					str(pressure.get("question", "")),
					str(pressure.get("detail", "")),
				]
				if _contains_hangul(surface):
					_fail("English full-run pressure leaked Hangul at turn %d: %s" % [GameState.turn, surface])
				for hidden_word in ["moral", "route score", "morality score", "ending route"]:
					if surface.to_lower().contains(hidden_word):
						_fail("full-run pressure exposed hidden system vocabulary: %s" % hidden_word)
		ids_by_language[language] = ids
	if ids_by_language.get("ko", []) != ids_by_language.get("en", []):
		_fail("full-run pressure selection changed with locale: %s" % ids_by_language)
	if ko_families.size() < 6:
		_fail("full-run pressure snapshots exposed only %d families: %s" % [ko_families.size(), ko_families.keys()])
	for chapter_index in range(ko_chapter_families.size()):
		if ko_chapter_families[chapter_index].size() < 3:
			_fail("chapter %d snapshots exposed only %d pressure families: %s" % [
				chapter_index + 1,
				ko_chapter_families[chapter_index].size(),
				ko_chapter_families[chapter_index].keys(),
			])
	game.free()
	LocaleManager.language = language_before
	DataRegistry.reload()

func _configure_pressure_fixture(fixture: Dictionary) -> void:
	GameState.start_new_game()
	GameState.turn = int(fixture.get("turn", 1))
	GameState.week_of_month = int(fixture.get("week", 1))
	GameState.housing = str(fixture.get("housing", "gosiwon"))
	GameState.health = int(fixture.get("health", 70))
	GameState.mental = int(fixture.get("mental", 70))
	GameState.grind_streak_weeks = 0
	GameState.last_month_money_weeks = int(fixture.get("money_weeks", 0))
	GameState.last_month_human_weeks = int(fixture.get("human_weeks", 0))
	var housing_cash := {
		"gosiwon": 5_000_000.0,
		"oneroom": 20_000_000.0,
		"villa": 80_000_000.0,
		"apartment": 200_000_000.0,
	}
	GameState.money = float(housing_cash.get(GameState.housing, 5_000_000.0))
	var job_id := str(fixture.get("job", "job_03"))
	GameState.current_job = DataRegistry.get_job(job_id).duplicate(true)
	GameState.monthly_income = float(GameState.current_job.get("base_salary", 2_500_000.0))
	GameState.job_tenure = 1
	GameState.work_performance = 55
	if bool(fixture.get("person", false)):
		GameState.flags["daeun_romance_started"] = true
	if bool(fixture.get("invest", false)):
		GameState.flags["arc_invest_guidance_seen"] = true
	GameState.portfolio = {}
	for index in range(int(fixture.get("portfolio", 0))):
		var asset_id := "fixture_asset_%d" % index
		GameState.portfolio[asset_id] = {"quantity": 1.0, "avg_price": 1_000_000.0}

func _check_demo_pacing() -> void:
	GameState.start_new_game()
	GameState.turn = 2
	GameState.month = 1
	GameState.week_of_month = 2
	GameState.money = 500_000.0
	GameState.monthly_income = 2_000_000.0
	GameState.health = 65
	GameState.mental = 60
	var game = MainGameScript.new()
	if str(game.call("_demo_director_week_kind")) != "quiet":
		_fail("scheduled quiet week did not enter quiet flow")
	GameState.health = 35
	if str(game.call("_demo_director_week_kind")) != "quiet":
		_fail("a locked quiet week changed kind after its routine altered crisis state")
	GameState.flags.erase("demo_director_kind_turn")
	GameState.flags.erase("demo_director_locked_kind")
	if str(game.call("_demo_director_week_kind")) != "decision":
		_fail("health crisis present at week entry did not promote quiet to decision")
	GameState.health = 65
	GameState.monthly_income = 0.0
	GameState.flags.erase("demo_director_kind_turn")
	GameState.flags.erase("demo_director_locked_kind")
	if str(game.call("_demo_director_week_kind")) != "decision":
		_fail("unfunded rent present at week entry did not promote quiet to decision")
	GameState.monthly_income = 2_000_000.0
	GameState.flags["demo_director_crisis_turn"] = GameState.turn
	GameState.flags.erase("demo_director_kind_turn")
	GameState.flags.erase("demo_director_locked_kind")
	if str(game.call("_demo_director_week_kind")) != "decision":
		_fail("monthly crisis present at week entry did not promote quiet to decision")
	GameState.flags.erase("demo_director_crisis_turn")
	GameState.action_axis_this_week = {"money": 1, "human": 1}
	GameState.action_places_this_week = {
		"city": {"count": 1, "money": 1, "human": 0},
		"home": {"count": 1, "money": 0, "human": 1},
	}
	game.call("_demo_director_capture_routine")
	if GameState.week_routine != ["network", "rest"]:
		_fail("mixed decision did not become a network/rest quiet routine: %s" % GameState.week_routine)
	GameState.action_points = 3
	GameState.action_axis_this_week = {"money": 0, "human": 0}
	var used: Dictionary = game.call("_montage_apply_routine")
	if GameState.action_points != 0:
		_fail("quiet routine discarded bonus AP: %d remained" % GameState.action_points)
	if not bool(used.get("money", false)) or not bool(used.get("human", false)):
		_fail("quiet routine did not preserve the last mixed decision across bonus AP: %s" % used)
	var counts := {"decision": 0, "boss": 0, "echo": 0, "quiet": 0}
	for week in range(1, GameState.DEMO_TURN_LIMIT + 1):
		var kind := EventManager.demo_week_kind(week)
		counts[kind] = int(counts.get(kind, 0)) + 1
	if int(counts.get("decision", 0)) + int(counts.get("boss", 0)) != 9 \
			or int(counts.get("boss", 0)) != 2 \
			or int(counts.get("echo", 0)) != 4:
		_fail("demo pacing counts drifted: %s" % counts)

	GameState.start_new_game()
	GameState.turn = 151
	GameState.month = 2
	GameState.week_of_month = 3
	GameState.monthly_income = 2_000_000.0
	GameState.health = 65
	GameState.mental = 60
	if str(game.call("_demo_director_week_kind")) != "echo":
		_fail("chapter-four echo did not enter the carried-routine flow")
	GameState.turn = 152
	GameState.week_of_month = 4
	GameState.health = 35
	GameState.flags.erase("demo_director_kind_turn")
	GameState.flags.erase("demo_director_locked_kind")
	if str(game.call("_demo_director_week_kind")) != "decision":
		_fail("full-run health crisis did not interrupt a quiet week")
	game.free()

func _check_pressure_contract(game: Node, pressure: Dictionary, expected_id: String,
		expected_actions: Array) -> void:
	if str(pressure.get("id", "")) != expected_id:
		_fail("demo pressure expected %s, got %s" % [expected_id, pressure])
		return
	var actions: Array = pressure.get("action_ids", [])
	if str(pressure.get("family", "")).is_empty():
		_fail("demo pressure %s has no family" % expected_id)
	if actions != expected_actions or actions.size() != 3:
		_fail("demo pressure %s must expose exactly three contextual actions: %s" % [expected_id, actions])
	for raw_action_id in actions:
		var action_id := str(raw_action_id)
		var spec: Dictionary = game._demo_action_spec(action_id, str(pressure.get("person_id", "")))
		if spec.is_empty() or str(spec.get("fn", "")).is_empty():
			_fail("demo pressure %s has an unbound action: %s" % [expected_id, action_id])
			continue
		var preview: Dictionary = game._weekly_commitment_preview(
			action_id, str(pressure.get("person_id", "")))
		for key in ["risk", "now", "cost", "later"]:
			if str(preview.get(key, "")).strip_edges().is_empty():
				_fail("demo action %s lacks %s preview: %s" % [action_id, key, preview])
		if LocaleManager.is_english() and _contains_hangul(" ".join(preview.values())):
			_fail("English demo action preview leaked Hangul: %s" % preview)

func _check_sfx_mix() -> void:
	var expected := {
		"game_over": -4.0,
		"casino_lose": -2.0,
		"casino_spin": -2.0,
		"casino_jackpot": -4.0,
		"civil_defense_siren": -3.0,
		"ending_stinger_good": -7.0,
		"ending_stinger_bad": -7.0,
		"ending_stinger_legend": -9.0,
	}
	for sound_id in expected:
		_expect_close(AudioManager.sfx_mix_trim_db(sound_id), float(expected[sound_id]),
			"loud SFX trim changed for %s" % sound_id)
	_expect_close(AudioManager.sfx_mix_trim_db("click"), 0.0, "shared trim double-attenuated the UI click")
	for player in AudioManager._pool:
		player.stop()
	GameState.week_of_month = 2
	AudioManager._on_turn_advanced(2)
	if _audio_pool_playing():
		_fail("monthly punctuation SFX still fires every week")
	GameState.week_of_month = 1
	AudioManager._on_turn_advanced(5)
	if not _audio_pool_playing():
		_fail("monthly punctuation SFX did not fire at the actual month boundary")
	for player in AudioManager._pool:
		player.stop()

func _event(id: String, category: String, tags: Array, conditions: Dictionary) -> Dictionary:
	return {
		"id": id,
		"category": category,
		"tags": tags,
		"conditions": conditions,
		"rarity": "common",
		"weight": 1.0,
		"choices": [],
	}

func _audio_pool_playing() -> bool:
	for player in AudioManager._pool:
		if player.playing:
			return true
	return false

func _contains_hangul(text: String) -> bool:
	var regex := RegEx.new()
	regex.compile("[가-힣]")
	return regex.search(text) != null

func _expect_close(actual: float, expected: float, message: String, epsilon: float = 0.0001) -> void:
	if absf(actual - expected) > epsilon:
		_fail("%s expected=%.3f actual=%.3f" % [message, expected, actual])

func _fail(message: String) -> void:
	_failures.append(message)
