extends Node
## ORDER-22: 행동→사건→주간 장면→소리의 연결을 런타임으로 검증한다.

const MainGameScript = preload("res://scenes/MainGame.gd")

var _failures: Array[String] = []
var _original_language := "ko"

func _ready() -> void:
	_original_language = LocaleManager.language
	_check_recent_action_echoes()
	_check_event_causality()
	_check_week_surface()
	_check_demo_pressure_choices()
	_check_arc_preview_read_only()
	_check_sfx_mix()
	LocaleManager.language = _original_language
	DataRegistry.reload()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("IMMERSION_LOOP_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("IMMERSION_LOOP_CHECK_OK memory=2 echo=2.6 prior=1.88 filler=0.42 quiet=3 causal=2 vignette=2 omen=1 preview=2 rent=1 pressures=5 cards=3 sfx=8")
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
	var employment: Dictionary = game._demo_week_pressure()
	_check_pressure_contract(game, employment, "employment", ["apply", "resume", "side_shift"])
	if GameState.serialize() != state_before:
		_fail("demo pressure preview mutated GameState")

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
	var capital: Dictionary = game._demo_week_pressure()
	_check_pressure_contract(game, capital, "capital", ["invest", "save", "contact"])

	LocaleManager.language = "en"
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

func _check_pressure_contract(game: Node, pressure: Dictionary, expected_id: String,
		expected_actions: Array) -> void:
	if str(pressure.get("id", "")) != expected_id:
		_fail("demo pressure expected %s, got %s" % [expected_id, pressure])
		return
	var actions: Array = pressure.get("action_ids", [])
	if actions != expected_actions or actions.size() != 3:
		_fail("demo pressure %s must expose exactly three contextual actions: %s" % [expected_id, actions])
	for raw_action_id in actions:
		var action_id := str(raw_action_id)
		var spec: Dictionary = game._demo_action_spec(action_id, str(pressure.get("person_id", "")))
		if spec.is_empty() or str(spec.get("fn", "")).is_empty():
			_fail("demo pressure %s has an unbound action: %s" % [expected_id, action_id])
			continue
		var preview := str(game._ap_action_preview(str(spec.get("fn", "")), str(spec.get("icon", "ap"))))
		if not preview.contains("AP 1") or (not preview.contains("1~3주") and not preview.contains("1–3W")):
			_fail("demo action %s lacks cost/risk/echo preview: %s" % [action_id, preview])
		if LocaleManager.is_english() and _contains_hangul(preview):
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
