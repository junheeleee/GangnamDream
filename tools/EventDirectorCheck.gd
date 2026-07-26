extends Node
## Runtime contract for hidden event curation, repeat policy, and save persistence.

var _failures: Array[String] = []

const DELAYED_PAYOFF_WIRING := [
	{"event": "amb_hoesik_00", "choice": 1, "target": "callback_hoesik_left_early_office", "delay": 12},
	{"event": "amb_hoesik_dodge", "choice": 1, "target": "callback_hoesik_caved_reputation", "delay": 8},
	{"event": "arc_daeun_02_regular", "choice": 0, "target": "callback_daeun_supportive_warmth", "delay": 12},
	{"event": "arc_invest_guidance", "choice": 0, "target": "callback_investment_lesson_echo", "delay": 16},
	{"event": "arc_temptation_fallout", "choice": 0, "target": "callback_escaped_dirty_trace", "delay": 16},
	{"event": "cafe_cb_stole_allin", "choice": 0, "target": "callback_cafe_stole_gambled_result", "delay": 10},
	{"event": "arc_daeun_money_gap", "choice": 2, "target": "callback_told_daeun_everything_echo", "delay": 12},
	{"event": "arc_daeun_money_gap", "choice": 1, "target": "callback_told_daeun_investing_echo", "delay": 12},
	{"event": "arc_father_03_hospital", "choice": 2, "target": "callback_sent_money_instead_echo", "delay": 10},
	{"event": "arc_father_03_hospital", "choice": 0, "target": "callback_rushed_to_father_echo", "delay": 14},
	{"event": "arc_father_medication", "choice": 2, "target": "callback_medication_visited_echo", "delay": 12},
	{"event": "arc_father_medication", "choice": 1, "target": "callback_medication_ignored_echo", "delay": 12},
	{"event": "arc_jiyeon_03_offer", "choice": 2, "target": "callback_jiyeon_honest_referral", "delay": 16},
	{"event": "arc_jiyeon_truth_moment", "choice": 0, "target": "callback_jiyeon_together_pressure", "delay": 16},
	{"event": "arc_jiyeon_truth_warned", "choice": 0, "target": "callback_jiyeon_together_pressure", "delay": 16},
	{"event": "arc_opp_jiyeon_bunyang", "choice": 0, "target": "callback_jiyeon_took_deal_consequence", "delay": 12},
	{"event": "arc_opp_sangchul_realty", "choice": 2, "target": "callback_declined_sangchul_deal_echo", "delay": 16},
	{"event": "arc_sangchul_03_network", "choice": 1, "target": "callback_shadow_investors_proposal", "delay": 12},
	{"event": "hyunsu_pass_news", "choice": 0, "target": "callback_hyunsu_departure_meal_echo", "delay": 16},
	{"event": "arc_daeun_04b_future", "choice": 1, "target": "callback_daeun_deferred_silence", "delay": 12},
	{"event": "arc_daeun_05_breaking", "choice": 1, "target": "callback_daeun_breakup_begged_echo", "delay": 12},
	{"event": "arc_daeun_05_together", "choice": 0, "target": "callback_daeun_daily_life_echo", "delay": 12},
	{"event": "arc_daeun_year3_apart", "choice": 0, "target": "callback_daeun_married_echo", "delay": 12},
	{"event": "arc_daeun_year3_apart", "choice": 1, "target": "callback_daeun_married_echo", "delay": 12},
	{"event": "arc_father_06_confession", "choice": 0, "target": "callback_father_confession_echo", "delay": 12},
	{"event": "arc_father_06_confession", "choice": 1, "target": "callback_father_confession_echo", "delay": 12},
	{"event": "arc_father_06_confession", "choice": 2, "target": "callback_father_confession_echo", "delay": 12},
	{"event": "arc_sangchul_buried_silence", "choice": 0, "target": "callback_sangchul_truth_buried_echo", "delay": 12},
	{"event": "arc_y3_jiyeon_departure", "choice": 0, "target": "callback_jiyeon_busan_postcard", "delay": 16},
	{"event": "arc_y3_jiyeon_departure", "choice": 1, "target": "callback_jiyeon_busan_postcard", "delay": 16},
	{"event": "arc_daeun_year4_together", "choice": 0, "target": "callback_daeun_gangnam_first_echo", "delay": 8},
	{"event": "arc_father_passing_deal_morning", "choice": 0, "target": "callback_chose_money_father_echo", "delay": 12},
	{"event": "arc_y3_cost_of_knowing", "choice": 0, "target": "callback_used_sangchul_after_echo", "delay": 10},
	{"event": "arc_daeun_y5_feelings", "choice": 0, "target": "callback_daeun_committed_gangnam_eve", "delay": 8},
]

const MULTI_DEFERRED_PAYOFF_WIRING := [
	{
		"event": "arc_jaehyuk_04b_counter", "choice": 1,
		"existing": "arc_jaehyuk_aftermath", "existing_delay": 1,
		"target": "callback_jaehyuk_exploited_retaliate", "delay": 12,
	},
	{
		"event": "arc_jaehyuk_04b_counter", "choice": 2,
		"existing": "arc_jaehyuk_aftermath", "existing_delay": 1,
		"target": "callback_jaehyuk_partnered_reckoning", "delay": 14,
	},
	{
		"event": "arc_sangchul_reckoning", "choice": 2,
		"existing": "arc_sangchul_year3", "existing_delay": 1,
		"target": "callback_sangchul_leveraged_cost", "delay": 12,
	},
]

func _ready() -> void:
	GameState.start_new_game()
	_check_catalog_and_ranges()
	_check_content_diet()
	_check_context_gates()
	_check_once_and_repeat_policy()
	_check_authored_bypass()
	_check_delayed_payoff_wiring()
	_check_demo_pacing()
	_check_full_run_pacing()
	_check_rhythm_save_migration()
	if _failures.is_empty():
		print("EVENT_DIRECTOR_CHECK_OK directed=1015 foreground=61 bridge=18 bridge_roots=7 auto_multi=0 once=1014 repeatable=3 callbacks=37/32 chapters=5 asset_bands=5 demo=9/2/4/3 authored=7 generic=2 full=52/5/20/21 save=legacy+demo+deferred")
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
	_expect(directed_count == 1015, "runtime directed pool is %d, expected 1015" % directed_count)
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

func _check_content_diet() -> void:
	var foreground_count := 0
	var bridge_count := 0
	for event_value in DataRegistry.events:
		var event: Dictionary = event_value
		if EventManager.is_foreground_random_event(event):
			foreground_count += 1
		if EventManager.is_narrative_bridge_event(event):
			bridge_count += 1
			_expect((event.get("choices", []) as Array).size() == 1,
				"multi-choice event entered the automatic bridge pool: %s" \
				% str(event.get("id", "")))
	_expect(foreground_count == 61,
		"curated foreground pool is %d, expected 61" % foreground_count)
	_expect(bridge_count == 18,
		"safe one-choice bridge pool is %d, expected 18" % bridge_count)

	var everyday: Dictionary = DataRegistry.find_event("convenience_store_meal")
	var substantial: Dictionary = DataRegistry.find_event("father_old_photo")
	var chained: Dictionary = DataRegistry.find_event("butterfly_mystery_info_offer")
	var comedy: Dictionary = DataRegistry.find_event("comedy_autocorrect")
	var implicit_chain_root: Dictionary = DataRegistry.find_event("amb_idea_stolen_00")
	var korea_explainer: Dictionary = DataRegistry.find_event("kx_tax_refund")
	var one_choice: Dictionary = DataRegistry.find_event("callback_formal_complaint_filed_echo")
	_expect(not EventManager.is_foreground_random_event(everyday),
		"short everyday card still owns a standalone StoryMode stop")
	_expect(EventManager.is_foreground_random_event(substantial),
		"substantial material-choice scene was removed from the foreground pool")
	_expect(EventManager.is_foreground_random_event(chained),
		"an existing causal chain lost its foreground entry point")
	_expect(not EventManager.is_foreground_random_event(comedy),
		"comedy filler still owns the novel foreground")
	_expect(EventManager.is_foreground_random_event(implicit_chain_root),
		"a material choice that creates a later bridge lost its chain entry point")
	_expect(not EventManager.is_foreground_random_event(korea_explainer),
		"a Korean explainer card entered the foreground through the bridge-root exception")
	_expect(EventManager.is_narrative_bridge_event(one_choice),
		"single-choice state callback did not enter the safe bridge pool")
	_expect(not EventManager.is_narrative_bridge_event(substantial),
		"multi-choice scene can be auto-resolved as a bridge")

	GameState.start_new_game()
	GameState.turn = 24
	GameState.flags["formal_complaint_filed"] = true
	_expect(EventManager.draw_narrative_bridge_event().is_empty(),
		"random bridge leaked into the curated 24-week demo")
	GameState.turn = 80
	var bridge_fixture: Dictionary = DataRegistry.find_event("callback_formal_complaint_filed_echo")
	_expect(EventManager._is_event_eligible(bridge_fixture, true),
		"eligible causal bridge fixture failed its deterministic state conditions")
	_expect(EventManager._event_has_causal_context(bridge_fixture),
		"eligible causal bridge fixture lost its state context")
	var bridge := EventManager.draw_narrative_bridge_event()
	_expect(str(bridge.get("id", "")) == "callback_formal_complaint_filed_echo",
		"eligible causal bridge was not selected after the demo: %s" \
		% str(bridge.get("id", "<empty>")))
	var seen_before := GameState.events_seen
	_expect(EventManager.resolve_narrative_bridge("callback_formal_complaint_filed_echo", 0),
		"safe bridge could not resolve through the original choice path")
	_expect(GameState.events_seen == seen_before + 1,
		"safe bridge did not retain the original event history")
	var bridge_results := EventManager.consume_narrative_bridge_results()
	_expect(bridge_results.size() == 1 \
			and str((bridge_results[0] as Dictionary).get("event_id", "")) \
			== "callback_formal_complaint_filed_echo",
		"safe bridge did not produce exactly one nonblocking result")

func _check_context_gates() -> void:
	GameState.turn = 12
	GameState.housing = "gosiwon"
	GameState.current_job = {}
	var delivery: Dictionary = DataRegistry.find_event("delivery_app_temptation")
	var rainy_night: Dictionary = DataRegistry.find_event("romance_034")
	_expect(EventManager.director_context_multiplier(delivery) == 0.0,
		"unemployed player can receive the after-work delivery scene")
	_expect(EventManager.director_context_multiplier(rainy_night) == 0.0,
		"unemployed player can receive the after-work Gangnam scene")
	var commute: Dictionary = DataRegistry.find_event("season_rainy_commute")
	_expect(not commute.is_empty(), "rainy commute fixture is missing")
	_expect(EventManager.director_context_multiplier(commute) == 0.0,
		"unemployed player can receive a commute scene")
	GameState.current_job = {"id": "job_01", "category": "part_time", "tier": 1}
	_expect(EventManager.director_context_multiplier(commute) > 0.0,
		"employed player cannot receive a commute scene")
	_expect(EventManager.director_context_multiplier(delivery) > 0.0,
		"employed player cannot receive the after-work delivery scene")
	_expect(EventManager.director_context_multiplier(rainy_night) > 0.0,
		"employed player cannot receive the after-work Gangnam scene")

	GameState.current_job = {}
	var gosiwon: Dictionary = DataRegistry.find_event("gosiwon_neighbor_first_meet")
	_expect(EventManager.director_context_multiplier(gosiwon) > 0.0,
		"goshiwon event is blocked in the goshiwon")
	GameState.housing = "apartment"
	_expect(EventManager.director_context_multiplier(gosiwon) == 0.0,
		"goshiwon event survives after moving to an apartment")
	GameState.housing = "gosiwon"
	var back_pain: Dictionary = DataRegistry.find_event("health_back_pain")
	var neighbor_success: Dictionary = DataRegistry.find_event("rare_goshiwon_neighbor_success")
	_expect(EventManager.director_context_multiplier(back_pain) > 0.0,
		"goshiwon mattress scene is blocked in the goshiwon")
	_expect(EventManager.director_context_multiplier(neighbor_success) > 0.0,
		"goshiwon neighbor scene is blocked in the goshiwon")
	GameState.housing = "apartment"
	_expect(EventManager.director_context_multiplier(back_pain) == 0.0,
		"goshiwon mattress scene survives after moving")
	_expect(EventManager.director_context_multiplier(neighbor_success) == 0.0,
		"goshiwon neighbor-success scene survives after moving")
	GameState.housing = "gosiwon"

	var six_month_romance: Dictionary = DataRegistry.find_event("romance_045")
	_expect(EventManager.director_context_multiplier(six_month_romance) == 0.0,
		"six-month partner scene can appear before any romance")
	GameState.flags["daeun_romance_started"] = true
	_expect(EventManager.director_context_multiplier(six_month_romance) > 0.0,
		"six-month partner scene stays blocked during an active romance")
	GameState.flags.erase("daeun_romance_started")

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
	var scheduled_arc: Dictionary = DataRegistry.find_event("arc_paycheck_reality")
	var direct_follow_up: Dictionary = DataRegistry.find_event("yolo_morning_after")
	var counts_before := GameState.random_event_counts.duplicate(true)
	_expect(not EventManager.is_directed_random_event(story), "authored story entered the random director")
	_expect(not EventManager.is_directed_random_event(scheduled_arc),
		"scheduled arc entered the random director")
	_expect(not EventManager.is_directed_random_event(direct_follow_up),
		"direct follow-up entered the random director")
	_expect_close(EventManager.director_context_multiplier(story), 1.0,
		"authored story received contextual weighting")
	EventManager.register_directed_event(story)
	_expect(GameState.random_event_counts == counts_before,
		"authored story changed random-event history")

func _check_delayed_payoff_wiring() -> void:
	var unique_targets: Dictionary = {}
	for row_value in DELAYED_PAYOFF_WIRING:
		var row: Dictionary = row_value
		var event_id := str(row["event"])
		var choice_index := int(row["choice"])
		var target_id := str(row["target"])
		var delay := int(row["delay"])
		var event: Dictionary = DataRegistry.find_event(event_id)
		var target: Dictionary = DataRegistry.find_event(target_id)
		_expect(not event.is_empty(), "delayed-payoff producer is missing: %s" % event_id)
		_expect(not target.is_empty(), "delayed-payoff target is missing: %s" % target_id)
		if event.is_empty():
			continue
		var choices: Array = event.get("choices", [])
		_expect(choice_index >= 0 and choice_index < choices.size(),
			"delayed-payoff choice index is invalid: %s#%d" % [event_id, choice_index])
		if choice_index < 0 or choice_index >= choices.size():
			continue
		var choice: Dictionary = choices[choice_index]
		_expect(choice.get("deferred_follow_up", "") is String,
			"legacy delayed-payoff row stopped using the compatible string shape: %s#%d" \
			% [event_id, choice_index])
		_expect(str(choice.get("deferred_follow_up", "")) == target_id,
			"delayed-payoff target drifted: %s#%d" % [event_id, choice_index])
		_expect(int(choice.get("deferred_delay", -1)) == delay,
			"delayed-payoff delay drifted: %s#%d" % [event_id, choice_index])
		unique_targets[target_id] = true

		GameState.start_new_game()
		GameState.turn = 40
		GameState.deferred_events.clear()
		GameState.apply_choice(event, choice)
		var scheduled := false
		for entry_value in GameState.deferred_events:
			var entry: Dictionary = entry_value
			if str(entry.get("event_id", "")) != target_id:
				continue
			scheduled = int(entry.get("trigger_turn", -1)) == 40 + delay
			break
		_expect(scheduled,
			"runtime did not schedule delayed payoff: %s#%d -> %s +%d" \
			% [event_id, choice_index, target_id, delay])
	_expect(DELAYED_PAYOFF_WIRING.size() == 34,
		"delayed-payoff wiring row count drifted")
	_expect(unique_targets.size() == 29,
		"delayed-payoff unique target count drifted: %d" % unique_targets.size())

	var multi_targets: Dictionary = {}
	for row_value in MULTI_DEFERRED_PAYOFF_WIRING:
		var row: Dictionary = row_value
		var event_id := str(row["event"])
		var choice_index := int(row["choice"])
		var existing_id := str(row["existing"])
		var existing_delay := int(row["existing_delay"])
		var target_id := str(row["target"])
		var target_delay := int(row["delay"])
		var event: Dictionary = DataRegistry.find_event(event_id)
		var choices: Array = event.get("choices", [])
		_expect(choice_index >= 0 and choice_index < choices.size(),
			"multi delayed-payoff choice index is invalid: %s#%d" % [event_id, choice_index])
		if choice_index < 0 or choice_index >= choices.size():
			continue
		var choice: Dictionary = choices[choice_index]
		var normalized: Array = DataRegistry.deferred_follow_ups(choice)
		_expect(_normalized_schedule_has(normalized, existing_id, existing_delay),
			"multi delayed-payoff lost existing schedule: %s#%d -> %s +%d" \
			% [event_id, choice_index, existing_id, existing_delay])
		_expect(_normalized_schedule_has(normalized, target_id, target_delay),
			"multi delayed-payoff lost added schedule: %s#%d -> %s +%d" \
			% [event_id, choice_index, target_id, target_delay])
		_expect(normalized.size() == 2,
			"multi delayed-payoff has an unexpected third schedule: %s#%d" \
			% [event_id, choice_index])
		multi_targets[target_id] = true

		GameState.start_new_game()
		GameState.turn = 40
		GameState.deferred_events.clear()
		GameState.apply_choice(event, choice)
		_expect(_runtime_schedule_has(existing_id, 40 + existing_delay),
			"runtime lost existing schedule beside added callback: %s#%d" \
			% [event_id, choice_index])
		_expect(_runtime_schedule_has(target_id, 40 + target_delay),
			"runtime did not schedule added delayed payoff: %s#%d" \
			% [event_id, choice_index])
		_expect(GameState.deferred_events.size() == 2,
			"one choice did not retain exactly two deferred schedules: %s#%d" \
			% [event_id, choice_index])
		GameState.turn = 40 + existing_delay
		var first_due: Array = GameState.pop_ready_deferred_events()
		_expect(first_due == [existing_id],
			"existing one-week follow-up did not fire first: %s#%d" \
			% [event_id, choice_index])
		_expect(GameState.has_deferred_event(target_id),
			"later callback was swallowed by the existing follow-up: %s#%d" \
			% [event_id, choice_index])
		GameState.turn = 40 + target_delay
		var second_due: Array = GameState.pop_ready_deferred_events()
		_expect(second_due == [target_id],
			"added callback did not fire at its own delay: %s#%d" \
			% [event_id, choice_index])
		_expect(GameState.deferred_events.is_empty(),
			"multi delayed-payoff left a duplicate schedule after both firings: %s#%d" \
			% [event_id, choice_index])
	_expect(MULTI_DEFERRED_PAYOFF_WIRING.size() == 3,
		"multi delayed-payoff wiring row count drifted")
	_expect(multi_targets.size() == 3,
		"multi delayed-payoff unique target count drifted: %d" % multi_targets.size())

	GameState.start_new_game()
	GameState.turn = 70
	var mixed_choice := {
		"deferred_follow_up": [
			"",
			"schema_shared_delay",
			{"id": "", "delay": 2},
			{"id": "schema_custom_delay", "delay": 3},
			{"id": "schema_shared_delay", "delay": 2},
		],
		"deferred_delay": 7,
	}
	_expect(DataRegistry.deferred_follow_up_shape_is_valid(mixed_choice),
		"valid mixed deferred schedule failed schema validation")
	_expect(not DataRegistry.deferred_follow_up_shape_is_valid({
			"deferred_follow_up": ["schema_bad_default"],
			"deferred_delay": 7.0,
		}), "floating-point default delay bypassed integer schema")
	_expect(not DataRegistry.deferred_follow_up_shape_is_valid({
			"deferred_follow_up": [{"id": "schema_bad_entry", "delay": 3.5}],
		}), "floating-point entry delay bypassed integer schema")
	_expect(not DataRegistry.deferred_follow_up_shape_is_valid({
			"deferred_follow_up": {"id": "schema_not_an_array"},
		}), "dictionary root bypassed string-or-array schema")
	GameState.apply_choice({"id": "deferred_schema_fixture"}, mixed_choice)
	_expect(_runtime_schedule_has("schema_shared_delay", 72),
		"duplicate deferred id did not preserve the earlier trigger turn")
	_expect(_runtime_schedule_has("schema_custom_delay", 73),
		"per-entry deferred delay was not honored")
	_expect(GameState.deferred_events.size() == 2,
		"empty ids or duplicate deferred ids leaked into storage")

	var saved: Dictionary = GameState.serialize()
	var saved_deferred: Array = GameState.deferred_events.duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	_expect(GameState.deferred_events == saved_deferred,
		"legacy deferred_events save format changed during array extension")
	GameState.start_new_game()

func _normalized_schedule_has(entries: Array, event_id: String, delay: int) -> bool:
	for value in entries:
		var entry: Dictionary = value
		if str(entry.get("event_id", "")) == event_id \
				and int(entry.get("delay", -1)) == delay:
			return true
	return false

func _runtime_schedule_has(event_id: String, trigger_turn: int) -> bool:
	for value in GameState.deferred_events:
		var entry: Dictionary = value
		if str(entry.get("event_id", "")) == event_id \
				and int(entry.get("trigger_turn", -1)) == trigger_turn:
			return true
	return false

func _check_demo_pacing() -> void:
	var kinds: Array[String] = []
	var decisions: Array[int] = []
	var bosses: Array[int] = []
	var echoes: Array[int] = []
	var summaries: Array[int] = []
	for turn_value in range(1, 25):
		var kind := EventManager.demo_week_kind(turn_value)
		kinds.append(kind)
		if kind in ["decision", "boss"]:
			decisions.append(turn_value)
		if kind == "boss":
			bosses.append(turn_value)
		elif kind == "echo":
			echoes.append(turn_value)
		if EventManager.demo_should_show_full_summary(turn_value):
			summaries.append(turn_value)
	_expect(decisions == [1, 4, 8, 10, 13, 16, 20, 23, 24],
		"demo decision schedule drifted: %s" % [decisions])
	_expect(bosses == [4, 24], "demo boss schedule drifted: %s" % [bosses])
	_expect(EventManager.narrative_boss_event_ids(4) == ["arc_temptation_01"],
		"week-four boss owner drifted")
	_expect(EventManager.narrative_event_owns_boss("arc_temptation_01", 4),
		"the burner-account scene does not own the week-four boss")
	_expect(not EventManager.narrative_event_owns_boss("arc_intro_02_dad_call", 4),
		"an unrelated scene can consume the week-four boss")
	_expect(EventManager.narrative_commitment_event_ids(8).is_empty(),
		"week eight must retain its separate generic decision")
	_expect(EventManager.narrative_commitment_event_ids(10).has("arc_ch1_career_first_spec"),
		"week ten route scene cannot own its weekly decision")
	_expect(EventManager.narrative_commitment_event_ids(13).has("cafe_cb_honest_00"),
		"week thirteen cafe callback cannot own its weekly decision")
	_expect(EventManager.narrative_commitment_event_ids(16) == ["arc_father_quiet_call"],
		"week sixteen father call owner drifted")
	_expect(EventManager.narrative_commitment_event_ids(20).has("arc_job_vs_invest"),
		"week twenty work-investment conflict cannot own its weekly decision")
	_expect(EventManager.narrative_commitment_event_ids(23) == ["story_first_savings_milestone"],
		"week twenty-three savings milestone cannot own its weekly decision")
	_expect(EventManager.narrative_boss_event_ids(24).has("hyunsu_exam_day"),
		"week twenty-four Hyunsu scene cannot own the closing boss week")
	var father_contract := EventManager.narrative_commitment_contract(
		"arc_father_quiet_call", 16)
	_expect(str(father_contract.get("axis", "")) == "human" \
			and str(father_contract.get("person_id", "")) == "father",
		"father commitment lost its human-axis relationship contract")
	_expect(not EventManager.narrative_event_owns_commitment("arc_father_quiet_call", 15),
		"authored ownership leaked into a quiet week")
	for owner_week in [4, 10, 13, 16, 20, 23, 24]:
		for owner_id in EventManager.narrative_commitment_event_ids(owner_week):
			var owner_event: Dictionary = DataRegistry.find_event(owner_id)
			_expect(not owner_event.is_empty(),
				"week %d owner does not exist: %s" % [owner_week, owner_id])
			_expect((owner_event.get("choices", []) as Array).size() >= 2,
				"week %d owner is not a real choice: %s" % [owner_week, owner_id])
			var owner_contract := EventManager.narrative_commitment_contract(
				owner_id, owner_week)
			_expect(str(owner_contract.get("axis", "")) in ["money", "human"],
				"week %d owner has no valid axis: %s" % [owner_week, owner_id])
	_expect(echoes == [6, 9, 17, 21], "demo echo schedule drifted: %s" % [echoes])
	_expect(summaries == [4, 12, 24], "demo summary schedule drifted: %s" % [summaries])
	_expect(EventManager.demo_week_kind(25) == "decision",
		"director leaked demo auto-flow beyond the cutoff")
	_expect(kinds.count("quiet") == 11, "demo must retain eleven quiet weeks")

func _check_full_run_pacing() -> void:
	var direct_by_chapter := [0, 0, 0, 0, 0]
	var bosses: Array[int] = []
	var echoes: Array[int] = []
	var summaries: Array[int] = []
	for turn_value in range(1, GameState.RUN_TURN_LIMIT + 1):
		var kind := EventManager.narrative_week_kind(turn_value)
		if kind in ["decision", "boss"]:
			direct_by_chapter[int((turn_value - 1) / 48)] += 1
		if kind == "boss":
			bosses.append(turn_value)
		elif kind == "echo":
			echoes.append(turn_value)
		if EventManager.narrative_should_show_full_summary(turn_value):
			summaries.append(turn_value)
	_expect(direct_by_chapter == [13, 9, 10, 10, 10],
		"full-run chapter decision cadence drifted: %s" % [direct_by_chapter])
	_expect(bosses == [4, 24, 45, 92, 140, 176, 237],
		"full-run boss cadence drifted: %s" % [bosses])
	_expect(echoes.size() == 21, "full run must expose twenty-one echo weeks")
	_expect(summaries.size() == 21 and summaries.back() == 240,
		"full run must expose twenty-one gated summaries through week 240")
	_expect(EventManager.narrative_week_kind(241) == "decision",
		"narrative cadence leaked automatic time beyond the five-year run")

func _check_rhythm_save_migration() -> void:
	GameState.start_new_game()
	GameState.turn = 151
	GameState.money = 12_345_678.0
	GameState.flags["father_reconciled"] = true
	GameState.flags["demo_director_kind_turn"] = 151
	GameState.flags["demo_director_locked_kind"] = "quiet"
	var old_state: Dictionary = GameState.serialize()
	var migrated: Dictionary = SaveManager.migrate_narrative_rhythm_state(old_state, 0)
	var migrated_flags: Dictionary = migrated.get("flags", {})
	_expect(not migrated_flags.has("demo_director_kind_turn") \
			and not migrated_flags.has("demo_director_locked_kind"),
		"legacy save retained a stale week-kind lock")
	_expect(bool(migrated_flags.get("father_reconciled", false)) \
			and is_equal_approx(float(migrated.get("money", 0.0)), 12_345_678.0),
		"legacy rhythm migration changed authored or economy state")

	var demo_state: Dictionary = old_state.duplicate(true)
	demo_state["turn"] = GameState.DEMO_TURN_LIMIT + 1
	demo_state["money"] = 7_654_321.0
	var carried: Dictionary = SaveManager.migrate_narrative_rhythm_state(
			demo_state, SaveManager.NARRATIVE_RHYTHM_VERSION)
	_expect(int(carried.get("turn", 0)) == 25 \
			and is_equal_approx(float(carried.get("money", 0.0)), 7_654_321.0),
		"current demo state cannot carry into the full build")
	_expect(str(carried.get("flags", {}).get("demo_director_locked_kind", "")) == "quiet",
		"current-version save lost its in-progress week classification")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)

func _expect_close(actual: float, expected: float, message: String, tolerance: float = 0.002) -> void:
	if absf(actual - expected) > tolerance:
		_failures.append("%s (%.4f != %.4f)" % [message, actual, expected])
