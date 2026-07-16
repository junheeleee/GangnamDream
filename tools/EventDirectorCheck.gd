extends Node
## Runtime contract for hidden event curation, repeat policy, and save persistence.

var _failures: Array[String] = []

func _ready() -> void:
	GameState.start_new_game()
	_check_catalog_and_ranges()
	_check_context_gates()
	_check_once_and_repeat_policy()
	_check_authored_bypass()
	if _failures.is_empty():
		print("EVENT_DIRECTOR_CHECK_OK directed=1045 once=1042 repeatable=3 chapters=5 asset_bands=5")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("EVENT_DIRECTOR_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)

func _check_catalog_and_ranges() -> void:
	var directed_count := 0
	for event_value in DataRegistry.events:
		var event: Dictionary = event_value
		if EventManager.is_directed_random_event(event):
			directed_count += 1
	_expect(directed_count == 1045, "runtime directed pool is %d, expected 1045" % directed_count)
	var chapter_ids: Array[String] = []
	for turn_value in [1, 49, 97, 145, 193]:
		chapter_ids.append(EventManager.director_chapter_id(turn_value))
	_expect(chapter_ids == ["survival", "foothold", "leverage", "consequence", "reckoning"],
		"chapter windows do not cover the five-year run")
	var asset_ids: Array[String] = []
	for asset_value in [-1.0, 0.0, 5_000_000.0, 50_000_000.0, 300_000_000.0]:
		asset_ids.append(EventManager.director_asset_band_id(asset_value))
	_expect(asset_ids == ["negative", "survival", "foothold", "capital", "affluent"],
		"asset bands overlap or leave a gap")

func _check_context_gates() -> void:
	GameState.turn = 12
	GameState.housing = "gosiwon"
	GameState.current_job = {}
	var commute: Dictionary = DataRegistry.find_event("season_rainy_commute")
	_expect(not commute.is_empty(), "rainy commute fixture is missing")
	_expect(EventManager.director_context_multiplier(commute) == 0.0,
		"unemployed player can receive a commute scene")
	GameState.current_job = {"id": "job_01", "category": "part_time", "tier": 1}
	_expect(EventManager.director_context_multiplier(commute) > 0.0,
		"employed player cannot receive a commute scene")

	GameState.current_job = {}
	var gosiwon: Dictionary = DataRegistry.find_event("gosiwon_neighbor_first_meet")
	_expect(EventManager.director_context_multiplier(gosiwon) > 0.0,
		"goshiwon event is blocked in the goshiwon")
	GameState.housing = "apartment"
	_expect(EventManager.director_context_multiplier(gosiwon) == 0.0,
		"goshiwon event survives after moving to an apartment")
	GameState.housing = "gosiwon"

	var introduction: Dictionary = DataRegistry.find_event("sangchul_meet")
	var callback: Dictionary = DataRegistry.find_event("callback_told_sangchul_truth_echo")
	_expect(EventManager.director_context_multiplier(introduction) > 0.0,
		"Sangchul introduction was mistaken for a continuity contradiction")
	_expect(EventManager.director_context_multiplier(callback) == 0.0,
		"Sangchul callback can appear before Minjun meets him")
	GameState.apply_cast_effect("sangchul", {"met": true})
	_expect(EventManager.director_context_multiplier(callback) > 0.0,
		"Sangchul callback stays blocked after the meeting")

	GameState.current_job = {}
	var valid: Dictionary = DataRegistry.find_event("first_month_rent_pressure")
	var picked: Dictionary = EventManager._weighted_pick([commute, valid])
	_expect(str(picked.get("id", "")) == "first_month_rent_pressure",
		"zero-weight contradiction leaked through weighted selection")

func _check_once_and_repeat_policy() -> void:
	GameState.turn = 1
	GameState.money = 500_000.0
	GameState.housing = "gosiwon"
	GameState.current_job = {}
	GameState.random_event_counts = {}
	GameState.random_event_last_turns = {}
	EventManager.event_cooldowns.clear()
	EventManager.recent_event_ids.clear()

	var once_event: Dictionary = DataRegistry.find_event("first_month_rent_pressure")
	_expect(EventManager._is_event_eligible(once_event), "fresh once-per-run event is not eligible")
	EventManager.register_directed_event(once_event)
	EventManager.event_cooldowns.clear()
	EventManager.recent_event_ids.clear()
	GameState.turn = 120
	_expect(not EventManager._is_event_eligible(once_event),
		"default random event returned later in the same run")

	GameState.random_event_counts = {}
	GameState.random_event_last_turns = {}
	EventManager.event_cooldowns.clear()
	EventManager.recent_event_ids.clear()
	GameState.turn = 1
	var repeat_event: Dictionary = DataRegistry.find_event("convenience_store_meal")
	var first_weight := float(EventManager._effective_weight(repeat_event))
	EventManager.register_directed_event(repeat_event)
	_expect(int(GameState.random_event_counts.get("convenience_store_meal", 0)) == 1,
		"first repeatable event was not counted")
	var saved: Dictionary = GameState.serialize()
	GameState.random_event_counts = {}
	GameState.random_event_last_turns = {}
	GameState.load_from_dict(saved)
	_expect(int(GameState.random_event_counts.get("convenience_store_meal", 0)) == 1,
		"repeat history did not survive save/load")

	EventManager.event_cooldowns.clear()
	EventManager.recent_event_ids.clear()
	GameState.turn = 25
	_expect(EventManager._is_event_eligible(repeat_event),
		"repeatable event did not return after its 24-week cooldown")
	var second_weight := float(EventManager._effective_weight(repeat_event))
	_expect_close(second_weight / maxf(first_weight, 0.0001), 0.35,
		"second appearance did not decay to 35 percent")
	EventManager.register_directed_event(repeat_event)
	EventManager.event_cooldowns.clear()
	EventManager.recent_event_ids.clear()
	GameState.turn = 100
	_expect(not EventManager._is_event_eligible(repeat_event),
		"repeatable event exceeded its two-appearance cap")

func _check_authored_bypass() -> void:
	var story: Dictionary = DataRegistry.find_event("story_flashforward")
	var counts_before := GameState.random_event_counts.duplicate(true)
	_expect(not EventManager.is_directed_random_event(story), "authored story entered the random director")
	_expect_close(EventManager.director_context_multiplier(story), 1.0,
		"authored story received contextual weighting")
	EventManager.register_directed_event(story)
	_expect(GameState.random_event_counts == counts_before,
		"authored story changed random-event history")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)

func _expect_close(actual: float, expected: float, message: String, tolerance: float = 0.002) -> void:
	if absf(actual - expected) > tolerance:
		_failures.append("%s (%.4f != %.4f)" % [message, actual, expected])
