extends Node
## ORDER-22: 행동→사건→주간 장면→소리의 연결을 런타임으로 검증한다.

const MainGameScript = preload("res://scenes/MainGame.gd")

var _failures: Array[String] = []
var _original_language := "ko"

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	_original_language = LocaleManager.language
	_check_recent_action_echoes()
	_check_action_consequence_echoes()
	_check_market_transaction_contract()
	_check_weekly_mutation_action_contract()
	_check_weekly_job_signal_contract()
	_check_weekly_random_preflight_contract()
	_check_weekly_commitment_contract()
	_check_forgone_path_contract()
	_check_scene_first_week_contract()
	_check_financial_progress_contract()
	_check_event_causality()
	_check_random_narrative_bridge_flow()
	_check_week_surface()
	_check_demo_pressure_choices()
	_check_full_run_pressure_diversity()
	_check_demo_pacing()
	_check_arc_preview_read_only()
	_check_sfx_mix()
	_check_transient_portrait_timer_source_contract()
	await _check_transient_portrait_timer_contract()
	await _check_quiet_week_reading_contract()
	LocaleManager.language = _original_language
	DataRegistry.reload()
	await _release_audio_for_exit()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("IMMERSION_LOOP_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("IMMERSION_LOOP_CHECK_OK memory=2 action_ids=8 commitments=1x3 forgone=relationship/body/career/market scene_first=1 no_ap_surface=1 quiet_compressed=1 meaningful_confirm=1 month_manual=1 outcomes=2 completion_boundary=1 consequence_paths=4 echo=2.6 prior=1.88 filler=0.42 quiet=3 causal=4 bridges=ko/en vignette=2 omen=1 preview=2 bills=1 rungs=4 reserve=1 pressures=11 families=6 cards=3 pacing=9/2/4 sfx=8 transient_timers=2")
	get_tree().quit(0)

func _release_audio_for_exit() -> void:
	for raw_tween in get_tree().get_processed_tweens():
		if raw_tween is Tween and (raw_tween as Tween).is_valid():
			(raw_tween as Tween).kill()
	BGMPlayer.stop()
	_detach_audio_streams(get_tree().root)
	for raw_player in AudioManager._pool:
		if raw_player is AudioStreamPlayer:
			(raw_player as AudioStreamPlayer).stop()
			(raw_player as AudioStreamPlayer).stream = null
	AudioManager._sounds.clear()
	await AudioManager.drain_pending_timers_for_exit()
	# Timer completions can instantiate their final WAV playback after the first
	# detach pass. Sweep once more after the timer owner is drained so headless QA
	# exits without retaining three short UI samples and their playback objects.
	BGMPlayer.stop()
	_detach_audio_streams(get_tree().root)
	var fixture_pool: Array = AudioManager._pool.duplicate()
	for raw_player in fixture_pool:
		if raw_player is AudioStreamPlayer:
			(raw_player as AudioStreamPlayer).stop()
			(raw_player as AudioStreamPlayer).stream = null
			raw_player.free()
	AudioManager._pool.clear()
	AudioManager._sounds.clear()
	await get_tree().create_timer(0.25).timeout
	for _release_frame in range(8):
		await get_tree().process_frame

func _detach_audio_streams(root: Node) -> void:
	if root is AudioStreamPlayer:
		(root as AudioStreamPlayer).stop()
		(root as AudioStreamPlayer).stream = null
	elif root is AudioStreamPlayer2D:
		(root as AudioStreamPlayer2D).stop()
		(root as AudioStreamPlayer2D).stream = null
	for child in root.get_children():
		_detach_audio_streams(child)

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
	if not (rest_frame_ko.contains("멈춘") or rest_frame_ko.contains("비워")):
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

func _check_market_transaction_contract() -> void:
	GameState.start_new_game()
	GameState.market_prices["samsung"] = 70_000.0
	var market = load("res://systems/InvestmentSystem.gd").new()
	var buy: Dictionary = market.buy_asset("samsung", 100_000.0)
	if not bool(buy.get("success", false)) \
			or not is_equal_approx(float(buy.get("price", 0.0)), 70_000.0) \
			or not is_equal_approx(float(buy.get("cash_committed", 0.0)), 100_000.0) \
			or float(buy.get("quantity", 0.0)) <= 0.0 \
			or float(buy.get("fee", 0.0)) <= 0.0:
		_fail("buy transaction did not return its concrete fill: %s" % buy)
	var sell: Dictionary = market.sell_asset("samsung", 1.0)
	if not bool(sell.get("success", false)) \
			or not is_equal_approx(float(sell.get("price", 0.0)), 70_000.0) \
			or not is_equal_approx(float(sell.get("ratio", 0.0)), 1.0) \
			or float(sell.get("quantity", 0.0)) <= 0.0 \
			or float(sell.get("proceeds", 0.0)) <= 0.0 \
			or not sell.has("profit"):
		_fail("sell transaction did not return its concrete settlement: %s" % sell)
	GameState.start_new_game()
	GameState.market_prices["samsung"] = 70_000.0
	var leverage: Dictionary = market.buy_asset_leveraged("samsung", 200_000.0)
	if not bool(leverage.get("success", false)) \
			or not is_equal_approx(float(leverage.get("price", 0.0)), 70_000.0) \
			or not is_equal_approx(float(leverage.get("cash_committed", 0.0)), 200_000.0) \
			or not is_equal_approx(float(leverage.get("exposure", 0.0)), 400_000.0) \
			or float(leverage.get("quantity", 0.0)) <= 0.0:
		_fail("leverage transaction did not return its concrete exposure: %s" % leverage)
	market.free()

func _check_weekly_mutation_action_contract() -> void:
	var market = load("res://systems/InvestmentSystem.gd").new()
	GameState.start_new_game("김민준", "지방_상경", "none")
	GameState.turn = 1
	GameState.action_points = 2
	GameState.money = 1_000_000.0
	GameState.market_prices["samsung"] = 70_000.0
	var payload := {
		"turn": 1,
		"pressure_id": "qa_external_buy",
		"pressure_family": "market",
		"choice_id": "invest",
		"forgone_ids": ["study", "save"],
	}
	if not GameState.arm_weekly_commitment(payload):
		_fail("external mutation fixture could not arm its investment commitment")
		market.free()
		return
	var signal_order: Array[String] = []
	var stats_probe := func() -> void:
		signal_order.append("stats")
	var log_probe := func(_entry: Dictionary) -> void:
		signal_order.append("log")
	var weekly_probe := func(_record: Dictionary) -> void:
		signal_order.append("weekly")
	var trade_probe := func(
			_asset_id: String, _action: String,
			_quantity: float, _price: float) -> void:
		signal_order.append("trade")
	var portfolio_probe := func() -> void:
		signal_order.append("portfolio")
	GameState.stats_changed.connect(stats_probe)
	GameState.log_added.connect(log_probe)
	GameState.weekly_commitment_finalized.connect(weekly_probe)
	market.trade_executed.connect(trade_probe)
	market.portfolio_updated.connect(portfolio_probe)
	var publisher := func(result: Dictionary) -> void:
		market.trade_executed.emit(
			"samsung", "buy", float(result.get("quantity", 0.0)),
			float(result.get("price", 0.0)))
		market.portfolio_updated.emit()
	var transaction := GameState.finalize_weekly_mutation_action(
		"invest_buy", "money",
		Callable(market, "buy_asset").bind("samsung", 100_000.0),
		"", "", {"asset_id": "samsung", "trade": "buy"}, {}, "invest",
		[market, market], publisher)
	var receipt: Dictionary = GameState.get_weekly_commitment_for_turn(1)
	if not bool(transaction.get("ok", false)) \
			or GameState.action_points != 0 \
			or not GameState.pending_weekly_commitment.is_empty() \
			or receipt.get("identity_evidence", {}) \
				!= {"kind": "invest", "weight": 4, "version": 2} \
			or GameState.tendency != {"career": 0, "invest": 4, "found": 0} \
			or not GameState.portfolio.has("samsung") \
			or market.is_blocking_signals():
		_fail("external mutation did not settle state, receipt, and owner together: %s" \
			% transaction)
	if signal_order != ["stats", "log", "weekly", "trade", "portfolio"]:
		_fail("external mutation signals were partial, missing, or duplicated: %s" \
			% signal_order)
	GameState.stats_changed.disconnect(stats_probe)
	GameState.log_added.disconnect(log_probe)
	GameState.weekly_commitment_finalized.disconnect(weekly_probe)
	market.trade_executed.disconnect(trade_probe)
	market.portfolio_updated.disconnect(portfolio_probe)

	# A mutation that succeeds locally but collides at receipt finalization must
	# restore cash, portfolio, log, AP, pending, and every signal owner exactly.
	GameState.start_new_game("김민준", "지방_상경", "none")
	GameState.turn = 1
	GameState.action_points = 2
	GameState.money = 1_000_000.0
	GameState.market_prices["samsung"] = 70_000.0
	GameState.arm_weekly_commitment(payload)
	var before_conflict: Dictionary = GameState.serialize().duplicate(true)
	var failure_signals := {"stats": 0, "log": 0, "weekly": 0, "trade": 0,
		"portfolio": 0}
	var failure_stats_probe := func() -> void:
		failure_signals["stats"] = int(failure_signals["stats"]) + 1
	var failure_log_probe := func(_entry: Dictionary) -> void:
		failure_signals["log"] = int(failure_signals["log"]) + 1
	var failure_weekly_probe := func(_record: Dictionary) -> void:
		failure_signals["weekly"] = int(failure_signals["weekly"]) + 1
	var failure_trade_probe := func(
			_asset_id: String, _action: String,
			_quantity: float, _price: float) -> void:
		failure_signals["trade"] = int(failure_signals["trade"]) + 1
	var failure_portfolio_probe := func() -> void:
		failure_signals["portfolio"] = int(failure_signals["portfolio"]) + 1
	GameState.stats_changed.connect(failure_stats_probe)
	GameState.log_added.connect(failure_log_probe)
	GameState.weekly_commitment_finalized.connect(failure_weekly_probe)
	market.trade_executed.connect(failure_trade_probe)
	market.portfolio_updated.connect(failure_portfolio_probe)
	var collide_after_buy := func() -> Dictionary:
		var result: Dictionary = market.buy_asset("samsung", 100_000.0)
		GameState.weekly_commitments.append({
			"turn": GameState.turn,
			"choice_id": "qa_conflict",
			"actual_action_id": "qa_conflict",
		})
		return result
	var failed_transaction := GameState.finalize_weekly_mutation_action(
		"invest_buy", "money", collide_after_buy, "", "",
		{"asset_id": "samsung", "trade": "buy"}, {}, "invest", [market, market],
		publisher)
	if bool(failed_transaction.get("ok", true)) \
			or not bool(failed_transaction.get("rolled_back", false)) \
			or GameState.serialize() != before_conflict \
			or failure_signals != {
				"stats": 0, "log": 0, "weekly": 0, "trade": 0,
				"portfolio": 0,
			} \
			or market.is_blocking_signals():
		_fail("late external mutation failure leaked state or signals: %s / %s" \
			% [failed_transaction, failure_signals])
	GameState.stats_changed.disconnect(failure_stats_probe)
	GameState.log_added.disconnect(failure_log_probe)
	GameState.weekly_commitment_finalized.disconnect(failure_weekly_probe)
	market.trade_executed.disconnect(failure_trade_probe)
	market.portfolio_updated.disconnect(failure_portfolio_probe)

	# Direct recovery callers run after a weekly transaction has returned and
	# therefore may be unblocked. Silent rollback must publish no loader signal,
	# while an explicit public restore publishes exactly once after exact state.
	var direct_restore_snapshot: Dictionary = GameState.serialize().duplicate(true)
	var direct_restore_stats := {"count": 0, "exact": true}
	var direct_restore_probe := func() -> void:
		direct_restore_stats["count"] = int(direct_restore_stats["count"]) + 1
		if GameState.serialize() != direct_restore_snapshot:
			direct_restore_stats["exact"] = false
	GameState.stats_changed.connect(direct_restore_probe)
	GameState.money += 12_345.0
	GameState._restore_serialized_snapshot_exact(direct_restore_snapshot, false)
	var silent_restore_ok: bool = GameState.serialize() == direct_restore_snapshot \
		and direct_restore_stats == {"count": 0, "exact": true}
	GameState.money += 54_321.0
	GameState._restore_serialized_snapshot_exact(direct_restore_snapshot, true)
	if not silent_restore_ok \
			or GameState.serialize() != direct_restore_snapshot \
			or direct_restore_stats != {"count": 1, "exact": true}:
		_fail("exact rollback leaked a loader signal or exposed partial state")
	GameState.stats_changed.disconnect(direct_restore_probe)

	# A nonempty stale owner must fail closed before calling the mutation. It may
	# never fall through to the legacy no-pending action path.
	GameState.pending_weekly_commitment = payload.duplicate(true)
	GameState.pending_weekly_commitment["turn"] = 2
	var stale_before: Dictionary = GameState.serialize().duplicate(true)
	var mutation_calls := {"count": 0}
	var stale_mutation := func() -> Dictionary:
		mutation_calls["count"] = int(mutation_calls["count"]) + 1
		return {"success": true}
	var stale_result := GameState.finalize_weekly_mutation_action(
		"invest_buy", "money", stale_mutation)
	if str(stale_result.get("error", "")) != "pending_turn_mismatch" \
			or int(mutation_calls["count"]) != 0 \
			or GameState.serialize() != stale_before:
		_fail("stale weekly owner reached or changed the external mutation")

	# A caller may already be suppressing an external owner. The transaction must
	# preserve that state even when the same owner is supplied more than once.
	GameState.start_new_game("김민준", "지방_상경", "none")
	GameState.turn = 1
	GameState.action_points = 2
	GameState.arm_weekly_commitment(payload)
	market.set_block_signals(true)
	var preblocked_result := GameState.finalize_weekly_mutation_action(
		"invest_buy", "money", func() -> Dictionary:
			return {"success": true},
		"", "", {}, {}, "", [market, market])
	if not bool(preblocked_result.get("ok", false)) \
			or not market.is_blocking_signals():
		_fail("duplicate/preblocked signal owner state was not restored exactly")
	market.set_block_signals(false)
	market.free()

	# Retail/V1 keeps the historical +1 founder interpretation for a survival
	# shift, but a scene-first weekly owner must settle that delta before its
	# receipt and realization signals become observable.
	GameState.start_new_game("김민준", "지방_상경", "none")
	GameState.turn = 25
	GameState.action_points = 2
	GameState.tendency = {"career": 0, "invest": 0, "found": 11}
	var shift_payload := {
		"turn": 25,
		"pressure_id": "qa_legacy_pending_shift",
		"pressure_family": "career",
		"choice_id": "side_shift",
		"forgone_ids": ["rest", "contact"],
	}
	if not GameState.arm_weekly_commitment(shift_payload):
		_fail("legacy pending side-shift fixture could not arm")
		return
	var shift_signal_order: Array[String] = []
	var shift_signals_settled := {"value": true}
	var shift_stats_probe := func() -> void:
		shift_signal_order.append("stats")
	var shift_weekly_probe := func(_record: Dictionary) -> void:
		shift_signal_order.append("weekly")
		if int(GameState.tendency.get("found", 0)) != 12 \
				or GameState.tendency_realized != "found" \
				or GameState.player_route != "창업형" \
				or not bool(GameState.flags.get("route_startup", false)):
			shift_signals_settled["value"] = false
	var shift_tendency_probe := func(kind: String) -> void:
		shift_signal_order.append("tendency")
		if kind != "found":
			shift_signals_settled["value"] = false
	GameState.stats_changed.connect(shift_stats_probe)
	GameState.weekly_commitment_finalized.connect(shift_weekly_probe)
	GameState.tendency_awakened.connect(shift_tendency_probe)
	var shift_game = MainGameScript.new()
	var legacy_shift_transaction: Dictionary = shift_game.call(
		"_finalize_weekly_side_shift_action",
		{"money": 10_000, "stress": 1, "health": -1}, {
			"execution": "side_shift",
			"earned": 10_000,
		})
	var shift_record: Dictionary = GameState.get_weekly_commitment_for_turn(25)
	var shift_details: Dictionary = shift_record.get("details", {}) \
		if shift_record.get("details", {}) is Dictionary else {}
	if not bool(legacy_shift_transaction.get("ok", false)) \
			or shift_details.get("legacy_tendency_delta", {}) \
				!= {"kind": "found", "weight": 1} \
			or shift_signal_order != ["stats", "weekly", "tendency"] \
			or not bool(shift_signals_settled["value"]):
		_fail("legacy pending side shift settled identity outside its receipt: %s / %s" \
			% [legacy_shift_transaction, shift_signal_order])
	GameState.stats_changed.disconnect(shift_stats_probe)
	GameState.weekly_commitment_finalized.disconnect(shift_weekly_probe)
	GameState.tendency_awakened.disconnect(shift_tendency_probe)
	shift_game.free()

func _check_weekly_random_preflight_contract() -> void:
	var game = MainGameScript.new()
	GameState.start_new_game("김민준", "지방_상경", "none")
	GameState.turn = 10
	GameState.action_points = 2
	GameState.pending_weekly_commitment = {
		"turn": 9,
		"choice_id": "rest",
	}
	var stale_before: Dictionary = GameState.serialize().duplicate(true)
	seed(761_903)
	var expected_roll := randi()
	seed(761_903)
	game.call("_ap_study_commit", 0)
	game.call("_ap_save_money")
	game.call(
		"_ap_vignette", "QA", [{"t": "QA", "et": "QA", "e": {}}],
		"#000000", "home", "rest")
	var actual_roll := randi()
	if GameState.serialize() != stale_before or actual_roll != expected_roll:
		_fail("stale random weekly action changed state or consumed RNG")

	GameState.pending_weekly_commitment = {
		"turn": 10,
		"choice_id": "contact",
	}
	var mismatch_before: Dictionary = GameState.serialize().duplicate(true)
	seed(418_227)
	expected_roll = randi()
	seed(418_227)
	game.call("_ap_save_money")
	game.call(
		"_ap_vignette", "QA", [{"t": "QA", "et": "QA", "e": {}}],
		"#000000", "home", "rest")
	actual_roll = randi()
	if GameState.serialize() != mismatch_before or actual_roll != expected_roll:
		_fail("mismatched random weekly action changed state or consumed RNG")
	game.free()

func _check_weekly_job_signal_contract() -> void:
	var game = MainGameScript.new()
	var jobs = load("res://systems/JobSystem.gd").new()
	game.set("job_system", jobs)
	GameState.start_new_game("김민준", "지방_상경", "none")
	GameState.turn = 1
	GameState.action_points = 2
	var payload := {
		"turn": 1,
		"pressure_id": "qa_job_signal",
		"pressure_family": "employment",
		"choice_id": "apply",
		"forgone_ids": ["save", "rest"],
	}
	if not GameState.arm_weekly_commitment(payload):
		_fail("job signal fixture could not arm its weekly commitment")
		jobs.free()
		game.free()
		return
	var signal_payloads: Array[Dictionary] = []
	var job_probe := func(job: Dictionary) -> void:
		signal_payloads.append(job.duplicate(true))
	jobs.job_changed.connect(job_probe)
	var transaction := GameState.finalize_weekly_mutation_action(
		"apply", "money", Callable(game, "_weekly_job_mutation").bind("job_01"),
		"work", "", {"job_id": "job_01"}, {}, "career", [jobs, jobs],
		Callable(game, "_publish_weekly_job_mutation"))
	var expected_payload: Dictionary = DataRegistry.get_job("job_01").duplicate(true)
	if not bool(transaction.get("ok", false)) \
			or signal_payloads != [expected_payload] \
			or signal_payloads[0].has("effective_salary") \
			or jobs.is_blocking_signals():
		_fail("weekly job signal payload diverged from legacy JobSystem: %s / %s" \
			% [transaction, signal_payloads])
	jobs.job_changed.disconnect(job_probe)
	jobs.free()
	game.free()

func _check_random_narrative_bridge_flow() -> void:
	var language_before := LocaleManager.language
	for language in ["ko", "en"]:
		LocaleManager.language = language
		DataRegistry.reload()
		EventManager.event_cooldowns.clear()
		EventManager.recent_event_ids.clear()
		EventManager.narrative_bridge_results.clear()

		GameState.start_new_game()
		GameState.turn = GameState.DEMO_TURN_LIMIT
		GameState.flags["formal_complaint_filed"] = true
		var game = MainGameScript.new()
		var seen_before_demo := GameState.events_seen
		game.call("_maybe_resolve_random_narrative_bridge", "quiet")
		if GameState.events_seen != seen_before_demo \
				or not EventManager.consume_narrative_bridge_results().is_empty():
			_fail("%s random narrative bridge leaked into the 24-week demo" % language)
		game.free()

		GameState.start_new_game()
		GameState.turn = 80
		GameState.flags["formal_complaint_filed"] = true
		EventManager.event_cooldowns.clear()
		EventManager.recent_event_ids.clear()
		EventManager.narrative_bridge_results.clear()
		game = MainGameScript.new()
		var seen_before_full := GameState.events_seen
		game.call("_maybe_resolve_random_narrative_bridge", "decision")
		if GameState.flags.has("month_event_turn") \
				or not EventManager.narrative_bridge_results.is_empty():
			_fail("%s direct week auto-resolved a narrative bridge" % language)
		game.call("_maybe_resolve_random_narrative_bridge", "quiet")
		var results: Array = EventManager.consume_narrative_bridge_results()
		if results.size() != 1 \
				or str((results[0] as Dictionary).get("event_id", "")) \
				!= "callback_formal_complaint_filed_echo":
			_fail("%s quiet week did not resolve the one causal bridge: %s" % [
				language, results])
		elif language == "en" and _contains_hangul(str((results[0] as Dictionary).get(
				"summary", ""))):
			_fail("English narrative bridge leaked Hangul: %s" % results[0])
		if GameState.events_seen != seen_before_full + 1 \
				or int(GameState.flags.get("month_event_turn", -1)) != GameState.turn:
			_fail("%s narrative bridge did not retain history or its once-per-week latch" % language)
		game.call("_maybe_resolve_random_narrative_bridge", "echo")
		if not EventManager.consume_narrative_bridge_results().is_empty() \
				or GameState.events_seen != seen_before_full + 1:
			_fail("%s narrative bridge resolved twice in one week" % language)
		game.free()

		GameState.start_new_game()
		GameState.turn = 61
		GameState.flags["pension_anxiety_awakened"] = true
		EventManager.event_cooldowns.clear()
		EventManager.recent_event_ids.clear()
		EventManager.narrative_bridge_results.clear()
		game = MainGameScript.new()
		var seen_before_hidden_bridge := GameState.events_seen
		game.call("_maybe_resolve_random_narrative_bridge", "quiet")
		results = EventManager.consume_narrative_bridge_results()
		if results.size() != 1 \
				or str((results[0] as Dictionary).get("event_id", "")) \
				!= "callback_pension_self_fund" \
				or not bool(GameState.flags.get("pension_self_saving", false)) \
				or GameState.events_seen != seen_before_hidden_bridge + 1:
			_fail("%s hidden causal bridge did not resolve deterministically: %s" % [
				language, results])
		game.free()
	LocaleManager.language = language_before
	DataRegistry.reload()

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
		var preview_actions: Array = pressure.get("action_ids", []).duplicate()
		preview_actions.append("gamble")
		for action_id in preview_actions:
			var preview: Dictionary = game.call("_weekly_commitment_preview", action_id, "daeun")
			for key in ["risk", "now", "cost", "later"]:
				if str(preview.get(key, "")).strip_edges().is_empty():
					_fail("weekly commitment %s has no %s preview" % [action_id, key])
			if language == "en" and _contains_hangul(" ".join(preview.values())):
				_fail("English weekly commitment preview leaked Hangul: %s" % preview)

	LocaleManager.language = "ko"
	DataRegistry.reload()
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
	var identity_signal_snapshots: Array[Dictionary] = []
	var identity_signal_probe := func() -> void:
		identity_signal_snapshots.append({
			"ap": GameState.action_points,
			"pending": GameState.pending_weekly_commitment.duplicate(true),
			"commitment_count": GameState.weekly_commitments.size(),
			"invest": int(GameState.tendency.get("invest", 0)),
		})
	GameState.stats_changed.connect(identity_signal_probe)
	if not GameState.finalize_weekly_commitment("invest_buy", "", {
		"asset_id": "samsung",
		"trade": "buy",
		"amount": 100_000.0,
		"price": 70_000.0,
		"quantity": 1.42,
		"fee": 300.0,
		"net_invested": 99_700.0,
	}, "invest"):
		_fail("actual trade could not finalize the armed commitment")
	GameState.stats_changed.disconnect(identity_signal_probe)
	if GameState.action_points != 0 or GameState.weekly_commitments.size() != 1:
		_fail("actual trade did not close the week exactly once: AP=%d records=%d" % [
			GameState.action_points, GameState.weekly_commitments.size()])
	var record: Dictionary = GameState.weekly_commitments[0]
	if str(record.get("choice_id", "")) != "invest" \
			or str(record.get("actual_action_id", "")) != "invest_buy" \
			or (record.get("forgone_ids", []) as Array).size() != 2 \
			or record.get("identity_evidence", {}) != {
				"kind": "invest", "weight": 4, "version": 2,
			}:
		_fail("weekly commitment lost its choice, actual action, or forgone paths: %s" % record)
	if identity_signal_snapshots.is_empty():
		_fail("identity commitment emitted no settled stats snapshot")
	for signal_snapshot in identity_signal_snapshots:
		if int(signal_snapshot.get("ap", -1)) != 0 \
				or not (signal_snapshot.get("pending", {}) as Dictionary).is_empty() \
				or int(signal_snapshot.get("commitment_count", 0)) != 1 \
				or int(signal_snapshot.get("invest", 0)) != 4:
			_fail("identity commitment exposed a partial transaction: %s" % signal_snapshot)
	var outcome: Dictionary = record.get("outcome", {})
	if not is_equal_approx(float(outcome.get("money", 0.0)), -100_000.0) \
			or int(outcome.get("investment_skill", 0)) != 1:
		_fail("weekly commitment lost its actual public outcome: %s" % outcome)
	var invest_surface := str(game.call("_weekly_commitment_outcome_text", record))
	_expect_surface_exact(
		invest_surface,
		"매수 주문이 체결됐다. 다음 장이 열릴 때까지 돈은 그 자산에 묶였다.",
		[
			"택한 것 ·", "실제 결과 ·", "그 주에 놓친 길 ·", "남은 웨이브 ·",
			"지난 선택 ·", "남은 메아리",
			"체결가", "10만원", "100,000", "100000", "70,000", "70000",
			"현금 +", "현금 -", "투자자산 +", "투자자산 -",
			"투자감각 +", "투자감각 -", "+1",
		],
		"investment outcome prose")
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
	DataRegistry.reload()
	var echo_record := str(game.call("_demo_director_recent_action_record", unresolved))
	_expect_surface_exact(
		echo_record,
		"The buy order filled. That week left no time for the other paths: Build One Thing / Reach Out to Kim Daeun. At the next market close, the value of the money tied up in Hanseong Electronics will move with its price.",
		[
			"chosen ·", "last choice ·", "not chosen that week ·",
			"actual result ·", "remaining wave ·", "remaining echo",
			"cash +", "cash -", "invested +", "invested -", "investing +", "investing -",
			"100,000", "100000",
			"70,000", "70000", "+1", "moral", "route",
		],
		"investment Echo prose",
		true)
	if GameState.consume_weekly_commitment_echoes(2).size() != 1 \
			or not GameState.consume_weekly_commitment_echoes(2).is_empty():
		_fail("weekly commitment echo was not consumed exactly once")

	# A venue browser is not a weekly action. Only a completed session may spend AP
	# and enter the same saved commitment ledger as an investment trade.
	GameState.start_new_game()
	GameState.turn = 80
	GameState.action_points = 2
	GameState.money = 1_000_000.0
	var gamble_pressure := {
		"id": "qa_gamble_commitment",
		"family": "market",
		"person_id": "",
		"action_ids": ["invest", "gamble", "save"],
	}
	var gamble_payload: Dictionary = game.call(
		"_weekly_commitment_payload", gamble_pressure, "gamble")
	var scalping = load("res://scenes/ScalpingGame.gd").new()
	scalping.set("_entry_balance", GameState.money)
	scalping.set("_runs_completed", 0)
	scalping.set("_session_trades", 0)
	var before_cancel: Dictionary = GameState.serialize()
	if not GameState.arm_weekly_commitment(gamble_payload):
		_fail("gambling commitment could not be armed")
	var canceled: Dictionary = game.call(
		"_settle_gamble_session", "gamble_scalping", "scalping", "underground", scalping)
	if int(canceled.get("rounds", -1)) != 0 or GameState.serialize() != before_cancel:
		_fail("a no-play gambling exit changed AP, state, or commitment: %s" % canceled)

	if not GameState.arm_weekly_commitment(gamble_payload):
		_fail("gambling commitment could not be re-armed after a no-play exit")
	scalping.set("_entry_balance", GameState.money)
	scalping.set("_runs_completed", 1)
	scalping.set("_session_trades", 4)
	GameState.add_money(-250_000.0)
	var settled: Dictionary = game.call(
		"_settle_gamble_session", "gamble_scalping", "scalping", "underground", scalping)
	if int(settled.get("rounds", 0)) != 1 or int(settled.get("trades", 0)) != 4 \
			or not is_equal_approx(float(settled.get("session_net", 0.0)), -250_000.0):
		_fail("completed gambling session lost its concrete settlement: %s" % settled)
	if GameState.action_points != 0 or GameState.weekly_commitments.size() != 1:
		_fail("completed gambling session did not close the week exactly once")
	var gamble_record: Dictionary = GameState.weekly_commitments[0]
	var gamble_outcome: Dictionary = gamble_record.get("outcome", {})
	if str(gamble_record.get("actual_action_id", "")) != "gamble_scalping" \
			or not is_equal_approx(float(gamble_outcome.get("money", 0.0)), -250_000.0):
		_fail("gambling commitment lost the actual action or cash result: %s" % gamble_record)
	LocaleManager.language = "en"
	var gamble_surface := str(game.call("_weekly_commitment_outcome_text", gamble_record))
	_expect_surface_exact(
		gamble_surface,
		"He ended the session and stood up. The result remained in both the account and the time spent there.",
		[
			"chosen ·", "last choice ·", "not chosen that week ·",
			"actual result ·", "remaining wave ·", "remaining echo",
			"cash +", "cash -", "scalping", "1 session", "4 trades", "net ",
			"-250", "250,000", "250000",
		],
		"gambling outcome prose",
		true)
	var gamble_saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(gamble_saved)
	GameState.turn = 81
	var gamble_echo := str(game.call(
		"_weekly_commitment_echo_record", GameState.get_unresolved_weekly_commitments(1)[0]))
	_expect_surface_exact(
		gamble_echo,
		"He ended the session and stood up. That week left no time for the other paths: Put Money in Motion / Cut Back. The money and time left there remain visible in both the account and the body next week.",
		[
			"chosen ·", "last choice ·", "not chosen that week ·",
			"actual result ·", "remaining wave ·", "remaining echo",
			"cash +", "cash -", "scalping", "1 session", "4 trades", "net ",
			"-250", "250,000", "250000",
		],
		"gambling Echo prose",
		true)
	_check_weekly_threshold_signal_contract(game)
	scalping.free()
	game.free()

func _check_weekly_threshold_signal_contract(game: Node) -> void:
	# A deferred foreground transaction publishes one settled threshold crossing,
	# never the blocked intermediate emitted by modify_stat().
	GameState.start_new_game("김민준", "지방_상경", "none")
	GameState.turn = 1
	GameState.action_points = 2
	GameState.intelligence = 29
	GameState.unlocked_stat_thresholds = {}
	var study_pressure := {
		"id": "qa_threshold_effect",
		"family": "growth",
		"person_id": "",
		"action_ids": ["study", "save", "contact"],
	}
	var study_payload: Dictionary = game.call(
		"_weekly_commitment_payload", study_pressure, "study")
	if not GameState.arm_weekly_commitment(study_payload):
		_fail("threshold effect fixture could not arm its weekly commitment")
		return
	var effect_signal_order: Array[String] = []
	var effect_crossings: Array[String] = []
	var effect_stats_probe := func() -> void:
		effect_signal_order.append("stats")
	var effect_weekly_probe := func(_record: Dictionary) -> void:
		effect_signal_order.append("weekly")
	var effect_threshold_probe := func(stat_name: String, threshold: int) -> void:
		effect_signal_order.append("threshold")
		effect_crossings.append("%s:%d" % [stat_name, threshold])
	GameState.stats_changed.connect(effect_stats_probe)
	GameState.weekly_commitment_finalized.connect(effect_weekly_probe)
	GameState.stat_threshold_crossed.connect(effect_threshold_probe)
	var effect_transaction := GameState.finalize_weekly_effect_action(
		"study_read", {"intelligence": 1}, "money", "library", "", {}, {},
		"career", true)
	if not bool(effect_transaction.get("ok", false)) \
			or not bool(effect_transaction.get("signals_deferred", false)) \
			or effect_transaction.get("threshold_crossings", []) != [{
				"stat_name": "intelligence", "threshold": 30,
			}] \
			or GameState.intelligence != 30 \
			or int(GameState.tendency.get("career", 0)) != 4:
		_fail("deferred threshold transaction lost its settled state: %s" \
			% effect_transaction)
	if not effect_signal_order.is_empty() or not effect_crossings.is_empty():
		_fail("deferred threshold transaction leaked a pre-publish signal")
	if not GameState.publish_deferred_weekly_effect_action(effect_transaction) \
			or GameState.publish_deferred_weekly_effect_action(effect_transaction):
		_fail("deferred threshold transaction did not publish exactly once")
	if effect_signal_order != ["stats", "weekly", "threshold"] \
			or effect_crossings != ["intelligence:30"]:
		_fail("effect threshold signal was missing, duplicated, or out of order: %s / %s" \
			% [effect_signal_order, effect_crossings])
	GameState.stats_changed.disconnect(effect_stats_probe)
	GameState.weekly_commitment_finalized.disconnect(effect_weekly_probe)
	GameState.stat_threshold_crossed.disconnect(effect_threshold_probe)

	# The route-realization passive is part of the same receipt. Its +6 investing
	# skill crossing must wake only after AP, pending, receipt, route, and score agree.
	GameState.start_new_game("김민준", "지방_상경", "none")
	GameState.turn = 1
	GameState.action_points = 2
	GameState.investment_skill = 24
	GameState.unlocked_stat_thresholds = {}
	GameState.tendency = {"career": 0, "invest": 8, "found": 0}
	var invest_pressure := {
		"id": "qa_threshold_passive",
		"family": "market",
		"person_id": "",
		"action_ids": ["invest", "study", "save"],
	}
	var invest_payload: Dictionary = game.call(
		"_weekly_commitment_payload", invest_pressure, "invest")
	if not GameState.arm_weekly_commitment(invest_payload):
		_fail("threshold passive fixture could not arm its weekly commitment")
		return
	var passive_signal_order: Array[String] = []
	var passive_crossings: Array[String] = []
	var passive_stats_probe := func() -> void:
		passive_signal_order.append("stats")
	var passive_weekly_probe := func(_record: Dictionary) -> void:
		passive_signal_order.append("weekly")
	var passive_threshold_probe := func(stat_name: String, threshold: int) -> void:
		passive_signal_order.append("threshold")
		passive_crossings.append("%s:%d" % [stat_name, threshold])
	var passive_tendency_probe := func(_kind: String) -> void:
		passive_signal_order.append("tendency")
	GameState.stats_changed.connect(passive_stats_probe)
	GameState.weekly_commitment_finalized.connect(passive_weekly_probe)
	GameState.stat_threshold_crossed.connect(passive_threshold_probe)
	GameState.tendency_awakened.connect(passive_tendency_probe)
	var passive_ok := GameState.finalize_weekly_commitment(
		"invest_buy", "", {"asset_id": "samsung"}, "invest")
	var passive_record: Dictionary = GameState.get_weekly_commitment_for_turn(1)
	if not passive_ok or GameState.investment_skill != 30 \
			or GameState.tendency_realized != "invest" \
			or GameState.player_route != "투자형" \
			or passive_record.get("identity_evidence", {}) != {
				"kind": "invest", "weight": 4, "version": 2,
			}:
		_fail("realization passive did not settle as one exact receipt: %s" \
			% passive_record)
	if passive_signal_order != ["stats", "weekly", "threshold", "tendency"] \
			or passive_crossings != ["investment_skill:30"]:
		_fail("passive threshold signal was missing, duplicated, or out of order: %s / %s" \
			% [passive_signal_order, passive_crossings])
	GameState.stats_changed.disconnect(passive_stats_probe)
	GameState.weekly_commitment_finalized.disconnect(passive_weekly_probe)
	GameState.stat_threshold_crossed.disconnect(passive_threshold_probe)
	GameState.tendency_awakened.disconnect(passive_tendency_probe)

func _check_forgone_path_contract() -> void:
	var language_before := LocaleManager.language
	var game = MainGameScript.new()

	# A person does not wait in stasis. Canceling the reopened card is still free;
	# completing it later pays a bounded relationship cost exactly once.
	GameState.start_new_game()
	GameState.turn = 1
	GameState.action_points = 2
	var relationship_pressure := {
		"id": "qa_forgone_relationship",
		"family": "human",
		"person_id": "daeun",
		"action_ids": ["side_shift", "rest", "contact"],
	}
	var shift_payload: Dictionary = game.call(
		"_weekly_commitment_payload", relationship_pressure, "side_shift")
	if not GameState.arm_weekly_commitment(shift_payload) \
			or not GameState.finalize_weekly_commitment("side_shift"):
		_fail("forgone relationship seed could not close its first week")
	if GameState.get_forgone_path_debt("rest").is_empty() \
			or GameState.get_forgone_path_debt("contact", "daeun").is_empty():
		_fail("weekly alternatives did not become body/person path debts")
	var relationship_saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(relationship_saved)
	GameState.turn = 9
	GameState.action_points = 2
	LocaleManager.language = "en"
	DataRegistry.reload()
	var contact_preview_en: Dictionary = game.call(
		"_weekly_commitment_preview", "contact", "daeun")
	var contact_cost_en := str(contact_preview_en.get("cost", ""))
	if contact_cost_en.findn("delayed cost") < 0 \
			or contact_cost_en.findn("8w") < 0 or _contains_hangul(contact_cost_en):
		_fail("English reopened relationship card hid or mistranslated its cost: %s" % contact_cost_en)
	LocaleManager.language = "ko"
	DataRegistry.reload()
	var contact_pressure := {
		"id": "qa_return_relationship",
		"family": "human",
		"person_id": "daeun",
		"action_ids": ["contact", "study", "save"],
	}
	var contact_payload: Dictionary = game.call(
		"_weekly_commitment_payload", contact_pressure, "contact")
	var debt_before_cancel: Dictionary = GameState.forgone_path_debts.duplicate(true)
	if not GameState.arm_weekly_commitment(contact_payload):
		_fail("reopened relationship commitment could not be armed")
	GameState.cancel_pending_weekly_commitment(GameState.turn)
	if GameState.forgone_path_debts != debt_before_cancel:
		_fail("canceling a reopened path consumed or changed its debt")
	if not GameState.arm_weekly_commitment(contact_payload):
		_fail("reopened relationship commitment could not be re-armed")
	GameState.modify_stat("mental", 5)
	GameState.apply_cast_effect("daeun", {"affinity": 4})
	if not GameState.finalize_weekly_commitment("contact", "daeun"):
		_fail("reopened relationship could not settle")
	var contact_record: Dictionary = GameState.get_weekly_commitment_for_turn(9)
	var contact_return: Dictionary = contact_record.get("return_cost", {})
	var contact_outcome: Dictionary = contact_record.get("outcome", {})
	if str(contact_return.get("kind", "")) != "relationship_cooling" \
			or int(contact_return.get("affinity", 0)) != -1 \
			or int(contact_outcome.get("affinity", 0)) != 3 \
			or GameState.get_cast_affinity("daeun") != 3:
		_fail("late contact did not reduce the real affinity gain exactly once: %s" % contact_record)
	if not GameState.get_forgone_path_return("contact", "daeun").is_empty():
		_fail("resolved relationship debt remained active")
	var contact_echo := str(game.call("_weekly_commitment_echo_record", contact_record))
	_expect_surface_exact(
		contact_echo,
		"이야기를 마친 뒤에도 김다은이 오래 마음에 남았다. 그 주에는 다른 길로 갈 시간이 남지 않았다: 하나를 쌓는다 / 지출을 깎는다. 늦어진 연락 앞에서는 지난 시간이 먼저 보였다.",
		[
			"택한 것 ·", "지난 선택 ·", "미뤄 둔 대가 ·", "실제 결과 ·",
			"그 주에 놓친 길 ·", "남은 웨이브 ·", "남은 메아리",
			"호감 +", "호감 -", "-1", "+3", "정신 +", "정신 -",
		],
		"relationship Echo prose")

	# One recovery week cannot erase every week that was repeatedly deferred, and
	# a late application starts the next job with measurable catch-up work.
	GameState.start_new_game()
	GameState.turn = 1
	GameState.action_points = 2
	var body_pressure := {
		"id": "qa_forgone_body",
		"family": "body",
		"person_id": "",
		"action_ids": ["side_shift", "rest", "apply"],
	}
	if not GameState.arm_weekly_commitment(game.call(
			"_weekly_commitment_payload", body_pressure, "side_shift")) \
			or not GameState.finalize_weekly_commitment("side_shift"):
		_fail("forgone body/career seed could not close")
	GameState.turn = 9
	GameState.action_points = 2
	GameState.health = 40
	GameState.mental = 40
	var rest_pressure := {
		"id": "qa_return_body",
		"family": "body",
		"person_id": "",
		"action_ids": ["rest", "side_shift", "apply"],
	}
	if not GameState.arm_weekly_commitment(game.call(
			"_weekly_commitment_payload", rest_pressure, "rest")):
		_fail("reopened rest commitment could not be armed")
	GameState.modify_stat("health", 6)
	GameState.modify_stat("mental", 6)
	if not GameState.finalize_weekly_commitment("rest"):
		_fail("reopened rest commitment could not settle")
	var rest_record: Dictionary = GameState.get_weekly_commitment_for_turn(9)
	var rest_return: Dictionary = rest_record.get("return_cost", {})
	if str(rest_return.get("kind", "")) != "accumulated_fatigue" \
			or GameState.health != 45 or GameState.mental != 45:
		_fail("deferred rest did not leave bounded fatigue after recovery: %s" % rest_record)

	GameState.turn = 13
	GameState.action_points = 2
	GameState.current_job = {"id": "old_job"}
	GameState.work_performance = 50
	var apply_pressure := {
		"id": "qa_return_application",
		"family": "career",
		"person_id": "",
		"action_ids": ["apply", "rest", "save"],
	}
	var apply_preview: Dictionary = game.call("_weekly_commitment_preview", "apply", "")
	if str(apply_preview.get("cost", "")).findn("놓친 지원 2회") < 0:
		_fail("repeatedly deferred application did not disclose its accumulated cost: %s" % apply_preview)
	if not GameState.arm_weekly_commitment(game.call(
			"_weekly_commitment_payload", apply_pressure, "apply")):
		_fail("reopened application commitment could not be armed")
	GameState.current_job = {"id": "new_job"}
	GameState.work_performance = 50
	if not GameState.finalize_weekly_commitment("apply", "", {"job_id": "new_job"}):
		_fail("reopened application commitment could not settle")
	var apply_record: Dictionary = GameState.get_weekly_commitment_for_turn(13)
	var apply_return: Dictionary = apply_record.get("return_cost", {})
	if str(apply_return.get("kind", "")) != "application_delay" \
			or int(apply_return.get("missed_count", 0)) != 2 \
			or GameState.work_performance != 46:
		_fail("late application did not lower starting performance by its bounded cost: %s" % apply_record)

	# Market opportunity cost is the real price movement since the skipped window,
	# not a fabricated cash deduction. Declining gambling never creates a debt.
	GameState.start_new_game()
	GameState.turn = 1
	GameState.action_points = 2
	GameState.market_prices = {"samsung": 100.0}
	var market_pressure := {
		"id": "qa_forgone_market",
		"family": "market",
		"person_id": "",
		"action_ids": ["save", "invest", "gamble"],
	}
	if not GameState.arm_weekly_commitment(game.call(
			"_weekly_commitment_payload", market_pressure, "save")) \
			or not GameState.finalize_weekly_commitment("save"):
		_fail("forgone market seed could not close")
	if GameState.get_forgone_path_debt("invest").is_empty() \
			or not GameState.get_forgone_path_debt("gamble").is_empty() \
			or GameState.forgone_path_debts.size() != 1:
		_fail("market debt was not tracked exactly, or declining gambling was punished: %s" \
			% GameState.forgone_path_debts)
	var market_saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(market_saved)
	GameState.turn = 13
	GameState.action_points = 2
	GameState.market_prices["samsung"] = 125.0
	var invest_preview: Dictionary = game.call("_weekly_commitment_preview", "invest", "")
	var invest_cost := str(invest_preview.get("cost", ""))
	if invest_cost.findn("한성전자") < 0 or invest_cost.findn("+25.0%") < 0:
		_fail("reopened market card did not name its actual price movement: %s" % invest_cost)
	var cash_before_trade: float = float(GameState.money)
	if not GameState.arm_weekly_commitment(game.call(
			"_weekly_commitment_payload", {
				"id": "qa_return_market", "family": "market", "person_id": "",
				"action_ids": ["invest", "save", "gamble"],
			}, "invest")):
		_fail("reopened market commitment could not be armed")
	GameState.add_money(-100_000.0)
	if not GameState.finalize_weekly_commitment("invest_buy", "", {
		"asset_id": "samsung", "trade": "buy", "amount": 100_000.0,
		"price": 125.0, "quantity": 800.0, "fee": 0.0, "net_invested": 100_000.0,
	}):
		_fail("reopened market commitment could not settle")
	var market_record: Dictionary = GameState.get_weekly_commitment_for_turn(13)
	var market_return: Dictionary = market_record.get("return_cost", {})
	if str(market_return.get("kind", "")) != "market_moved" \
			or str(market_return.get("market_asset_id", "")) != "samsung" \
			or not is_equal_approx(float(market_return.get("market_change_ratio", 0.0)), 0.25) \
			or not is_equal_approx(GameState.money, cash_before_trade - 100_000.0):
		_fail("market return fabricated a penalty or lost its actual movement: %s" % market_record)
	LocaleManager.language = "en"
	DataRegistry.reload()
	var market_echo_en := str(game.call("_weekly_commitment_echo_record", market_record))
	_expect_surface_exact(
		market_echo_en,
		"The buy order filled. That week left no time for the other paths: Cut Back / Stake It. While he waited, the market screen had already moved somewhere else.",
		[
			"chosen ·", "last choice ·", "not chosen that week ·",
			"actual result ·", "delayed cost ·", "remaining wave ·",
			"remaining echo", "25.0%", "+25", "12w", "cash +", "cash -",
			"invested +", "invested -", "investing +", "investing -",
		],
		"market Echo prose",
		true)

	LocaleManager.language = language_before
	DataRegistry.reload()
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

func _check_financial_progress_contract() -> void:
	LocaleManager.language = "ko"
	GameState.start_new_game()
	var bills_rung: Dictionary = GameState.get_financial_rung()
	if str(bills_rung.get("kind", "")) != "bills":
		_fail("starting KRW 500K did not show this month's bills: %s" % bills_rung)
	_expect_close(float(bills_rung.get("target", 0.0)), 650_000.0,
		"starting bill target drifted from the goshiwon cost")

	GameState.current_job = {"id": "qa_job"}
	GameState.monthly_income = 1_320_000.0
	var reserve_rung: Dictionary = GameState.get_financial_rung()
	if str(reserve_rung.get("kind", "")) != "reserve":
		_fail("first employment erased reserve pressure: %s" % reserve_rung)
	_expect_close(float(reserve_rung.get("target", 0.0)), 1_950_000.0,
		"three-month reserve did not follow actual monthly bills")

	GameState.money = 2_500_000.0
	var first_savings_rung: Dictionary = GameState.get_financial_rung()
	if str(first_savings_rung.get("kind", "")) != "wealth":
		_fail("cash above reserve did not enter a wealth rung: %s" % first_savings_rung)
	_expect_close(float(first_savings_rung.get("target", 0.0)), 3_000_000.0,
		"first wealth rung is not KRW 3M")

	GameState.money = 5_000_000.0
	var one_room_rung: Dictionary = GameState.get_financial_rung()
	_expect_close(float(one_room_rung.get("target", 0.0)), 8_000_000.0,
		"KRW 5M did not point to the one-room rung")
	_expect_close(float(one_room_rung.get("progress", 0.0)), 0.4,
		"wealth rung did not show progress between KRW 3M and KRW 8M")

	LocaleManager.language = "en"
	var english_rung: Dictionary = GameState.get_financial_rung()
	if _contains_hangul(str(english_rung)):
		_fail("English financial rung leaked Hangul: %s" % english_rung)

	LocaleManager.language = "ko"
	GameState.start_new_game()
	GameState.current_job = {"id": "qa_job"}
	GameState.monthly_income = 650_000.0
	GameState.money = 800_000.0
	GameState.health = 70
	GameState.mental = 70
	GameState.apply_monthly_pressure()
	_expect_close(float(GameState.mental), 64.0,
		"employed run below three months of cash lost its reserve pressure")
	if str(GameState.flags.get("cash_reserve_band", "")) != "thin":
		_fail("employed thin reserve was not classified from cash: %s" % GameState.flags)

	GameState.start_new_game()
	GameState.current_job = {"id": "qa_job"}
	GameState.monthly_income = 650_000.0
	GameState.money = 3_000_000.0
	GameState.health = 70
	GameState.mental = 70
	GameState.apply_monthly_pressure()
	_expect_close(float(GameState.mental), 65.0,
		"three-month cash buffer did not remove only the reserve penalty")
	if str(GameState.flags.get("cash_reserve_band", "")) != "safe":
		_fail("safe reserve was not classified from actual cash: %s" % GameState.flags)

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
			or not str(rent.get("text", "")).contains("BILLS DUE"):
		_fail("bill due week is not presented as an uncovered threat: %s" % rent)
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
	GameState.flags["casino_club_introduced"] = true
	var capital_with_venue: Dictionary = game._demo_week_pressure()
	_check_pressure_contract(game, capital_with_venue, "capital", ["invest", "gamble", "save"])
	GameState.flags.erase("casino_club_introduced")
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

	# An explicit investment-study decision must remain investment study when a
	# quiet/echo week repeats it. It previously collapsed to saving and silently
	# accumulated career identity instead.
	GameState.tendency = {"career": 0, "invest": 0, "found": 0}
	GameState.tendency_realized = ""
	GameState.action_axis_this_week = {"money": 1, "human": 0}
	GameState.action_places_this_week = {
		"home": {"count": 1, "money": 1, "human": 0},
	}
	GameState.action_records_this_week = [{
		"id": "study_invest", "axis": "money", "place": "home",
		"subject": "", "families": ["investment", "finance"],
	}]
	game.call("_demo_director_capture_routine")
	if GameState.week_routine != ["study_invest", "study_invest"]:
		_fail("investment study collapsed into a different quiet routine: %s" % GameState.week_routine)
	var investment_routine_money := float(GameState.money)
	GameState.action_points = 2
	var investment_used: Dictionary = game.call("_montage_apply_routine")
	if GameState.action_points != 0 or not bool(investment_used.get("money", false)):
		_fail("investment-study quiet routine did not consume its two visible money slots")
	if int(GameState.tendency.get("invest", 0)) != 0 \
			or int(GameState.tendency.get("career", 0)) != 0:
		_fail("investment-study quiet routine invented identity evidence: %s" % GameState.tendency)
	if not GameState.tendency_realized.is_empty():
		_fail("investment-study quiet routine realized an unchosen identity")
	if not is_equal_approx(float(GameState.money), investment_routine_money):
		_fail("investment study invented a cash return during quiet-week repetition")

	# Three visible, route-defining decisions are one 12-point identity arc. Two
	# investment studies survive two career pressures; the real buy seals invest.
	# This script-only fixture reads state directly; do not broadcast UI work.
	var signals_were_blocked := GameState.is_blocking_signals()
	GameState.set_block_signals(true)
	GameState.player_route = "none"
	for identity_flag in [
		"route_career", "route_invest", "route_startup",
		"pending_spec_career", "pending_spec_invest", "pending_spec_found",
	]:
		GameState.flags.erase(identity_flag)
	GameState.add_deliberate_tendency("invest")
	GameState.add_deliberate_tendency("invest")
	GameState.add_deliberate_tendency("career")
	GameState.add_deliberate_tendency("career")
	if GameState.tendency != {"career": 8, "invest": 8, "found": 0} \
			or not GameState.tendency_realized.is_empty():
		_fail("deliberate identity evidence did not preserve the tied route: %s" % GameState.tendency)
	# A damaged/legacy competing flag cannot survive the one-route realization.
	GameState.player_route = "직장형"
	GameState.flags["route_career"] = true
	GameState.add_deliberate_tendency("invest")
	if GameState.tendency_realized != "invest" \
			or GameState.player_route != "투자형" \
			or not bool(GameState.flags.get("route_invest", false)) \
			or bool(GameState.flags.get("route_career", false)):
		_fail("third deliberate investment action did not seal one investor route")

	# Adding investment evidence may never awaken a different, previously leading
	# route. This was the exact W23 failure before trigger-kind ownership existed.
	GameState.tendency = {"career": 12, "invest": 2, "found": 0}
	GameState.tendency_realized = ""
	GameState.player_route = "none"
	for identity_flag in [
		"route_career", "route_invest", "route_startup",
		"pending_spec_career", "pending_spec_invest", "pending_spec_found",
	]:
		GameState.flags.erase(identity_flag)
	GameState.add_tendency("invest", 1)
	if not GameState.tendency_realized.is_empty() \
			or GameState.flags.get("route_career", false):
		_fail("investment evidence awakened the leading career route")

	# Missing/partial legacy identity keys must not inherit another loaded slot,
	# and provenance-free automatic scores cannot mix with the new 4-point scale.
	var identity_fixture_snapshot: Dictionary = GameState.serialize().duplicate(true)
	var legacy_missing: Dictionary = identity_fixture_snapshot.duplicate(true)
	legacy_missing.erase("tendency")
	legacy_missing.erase("tendency_realized")
	legacy_missing.erase("tendency_evidence_version")
	legacy_missing.erase("player_route")
	for identity_flag in [
		"route_career", "route_invest", "route_startup",
		"pending_spec_career", "pending_spec_invest", "pending_spec_found",
	]:
		(legacy_missing["flags"] as Dictionary).erase(identity_flag)
	GameState.tendency = {"career": 0, "invest": 16, "found": 0}
	GameState.tendency_realized = "invest"
	GameState.player_route = "투자형"
	GameState.flags["route_invest"] = true
	GameState.load_from_dict(legacy_missing)
	if GameState.tendency != {"career": 0, "invest": 0, "found": 0} \
			or not GameState.tendency_realized.is_empty() \
			or GameState.player_route != "none" \
			or GameState.tendency_evidence_version \
			!= GameState.TENDENCY_EVIDENCE_VERSION:
		_fail("legacy identity omission inherited another slot")
	var legacy_partial: Dictionary = GameState.serialize().duplicate(true)
	legacy_partial.erase("tendency_evidence_version")
	legacy_partial["tendency"] = {"career": 8}
	legacy_partial["tendency_realized"] = ""
	legacy_partial["player_route"] = "none"
	GameState.load_from_dict(legacy_partial)
	if GameState.tendency != {"career": 0, "invest": 0, "found": 0}:
		_fail("legacy partial identity scores were not normalized fail-closed")
	var legacy_committed: Dictionary = GameState.serialize().duplicate(true)
	legacy_committed.erase("tendency_evidence_version")
	legacy_committed["tendency"] = {"career": 4, "invest": 0, "found": 0}
	legacy_committed["tendency_realized"] = ""
	legacy_committed["player_route"] = "직장형"
	legacy_committed["flags"]["route_career"] = true
	GameState.load_from_dict(legacy_committed)
	if GameState.tendency_realized != "career" \
			or GameState.player_route != "직장형" \
			or not bool(GameState.flags.get("route_career", false)) \
			or bool(GameState.flags.get("route_invest", false)) \
			or GameState.tendency \
				!= {"career": 12, "invest": 0, "found": 0}:
		_fail("committed legacy route did not migrate as one exact identity")
	var migrated_committed: Dictionary = GameState.serialize().duplicate(true)
	GameState.load_from_dict(migrated_committed)
	if GameState.tendency_realized != "career" \
			or GameState.player_route != "직장형" \
			or not bool(GameState.flags.get("route_career", false)) \
			or bool(GameState.flags.get("route_invest", false)) \
			or GameState.tendency \
				!= {"career": 12, "invest": 0, "found": 0}:
		_fail("migrated legacy route disappeared on its second V2 load")
	var legacy_claim_without_pair: Dictionary = legacy_committed.duplicate(true)
	legacy_claim_without_pair["tendency_realized"] = "invest"
	legacy_claim_without_pair["player_route"] = "none"
	for identity_flag in ["route_career", "route_invest", "route_startup"]:
		(legacy_claim_without_pair["flags"] as Dictionary).erase(identity_flag)
	GameState.load_from_dict(legacy_claim_without_pair)
	if not GameState.tendency_realized.is_empty() \
			or GameState.player_route != "none" \
			or bool(GameState.flags.get("route_invest", false)) \
			or GameState.tendency \
				!= {"career": 0, "invest": 0, "found": 0}:
		_fail("legacy realization without an exact route pair was promoted")
	var legacy_flag_only: Dictionary = legacy_committed.duplicate(true)
	legacy_flag_only["tendency_realized"] = ""
	legacy_flag_only["player_route"] = "none"
	for identity_flag in ["route_career", "route_invest", "route_startup"]:
		(legacy_flag_only["flags"] as Dictionary).erase(identity_flag)
	(legacy_flag_only["flags"] as Dictionary)["route_invest"] = true
	GameState.load_from_dict(legacy_flag_only)
	if not GameState.tendency_realized.is_empty() \
			or GameState.player_route != "none" \
			or bool(GameState.flags.get("route_invest", false)) \
			or GameState.tendency \
				!= {"career": 0, "invest": 0, "found": 0}:
		_fail("legacy flag-only identity was promoted without its exact route")
	var legacy_claim_wrong_pair: Dictionary = legacy_committed.duplicate(true)
	legacy_claim_wrong_pair["tendency_realized"] = "invest"
	GameState.load_from_dict(legacy_claim_wrong_pair)
	if not GameState.tendency_realized.is_empty() \
			or GameState.player_route != "none" \
			or bool(GameState.flags.get("route_career", false)) \
			or bool(GameState.flags.get("route_invest", false)) \
			or GameState.tendency \
				!= {"career": 0, "invest": 0, "found": 0}:
		_fail("legacy realization with a contradictory route pair was promoted")
	var v2_preselected: Dictionary = GameState.serialize().duplicate(true)
	v2_preselected["tendency"] = {"career": 0, "invest": 0, "found": 0}
	v2_preselected["tendency_realized"] = ""
	v2_preselected["tendency_evidence_version"] = GameState.TENDENCY_EVIDENCE_VERSION
	v2_preselected["player_route"] = "직장형"
	for identity_flag in ["route_career", "route_invest", "route_startup"]:
		(v2_preselected["flags"] as Dictionary).erase(identity_flag)
	(v2_preselected["flags"] as Dictionary)["route_career"] = true
	GameState.load_from_dict(v2_preselected)
	if GameState.player_route != "직장형" \
			or not bool(GameState.flags.get("route_career", false)) \
			or not GameState.tendency_realized.is_empty():
		_fail("exact V2 preselected route did not survive save/load")
	var v2_flag_only: Dictionary = v2_preselected.duplicate(true)
	v2_flag_only["player_route"] = "none"
	(v2_flag_only["flags"] as Dictionary).erase("route_career")
	(v2_flag_only["flags"] as Dictionary)["route_invest"] = true
	GameState.load_from_dict(v2_flag_only)
	if GameState.player_route != "none" \
			or bool(GameState.flags.get("route_invest", false)):
		_fail("V2 flag-only identity was promoted without an exact route pair")
	var v2_unearned_realization: Dictionary = v2_preselected.duplicate(true)
	v2_unearned_realization["tendency"] = {
		"career": 0, "invest": 0, "found": 0,
	}
	v2_unearned_realization["tendency_realized"] = "invest"
	v2_unearned_realization["player_route"] = "투자형"
	for identity_flag in ["route_career", "route_invest", "route_startup"]:
		(v2_unearned_realization["flags"] as Dictionary).erase(identity_flag)
	(v2_unearned_realization["flags"] as Dictionary)["route_invest"] = true
	GameState.load_from_dict(v2_unearned_realization)
	if GameState.tendency_realized != "" or GameState.player_route != "none" \
			or bool(GameState.flags.get("route_invest", false)):
		_fail("V2 zero-score realization was promoted into a permanent route")
	var v2_contradictory_realization: Dictionary = (
		v2_unearned_realization.duplicate(true))
	v2_contradictory_realization["tendency"] = {
		"career": 0, "invest": 12, "found": 0,
	}
	v2_contradictory_realization["player_route"] = "직장형"
	(v2_contradictory_realization["flags"] as Dictionary).erase("route_invest")
	(v2_contradictory_realization["flags"] as Dictionary)["route_career"] = true
	GameState.load_from_dict(v2_contradictory_realization)
	if GameState.tendency_realized != "" or GameState.player_route != "none" \
			or bool(GameState.flags.get("route_career", false)):
		_fail("V2 contradictory realization/route pair did not fail closed")
	var legacy_competing: Dictionary = v2_preselected.duplicate(true)
	legacy_competing.erase("tendency_evidence_version")
	(legacy_competing["flags"] as Dictionary)["route_invest"] = true
	GameState.load_from_dict(legacy_competing)
	if GameState.player_route != "none" \
			or not GameState.tendency_realized.is_empty() \
			or bool(GameState.flags.get("route_career", false)) \
			or bool(GameState.flags.get("route_invest", false)):
		_fail("competing legacy route flags did not fail closed")
	var malformed_identity: Dictionary = v2_preselected.duplicate(true)
	malformed_identity["tendency"] = "not-a-score-map"
	malformed_identity["tendency_realized"] = 7
	malformed_identity["tendency_evidence_version"] = "newest"
	malformed_identity["player_route"] = ["투자형"]
	for identity_flag in ["route_career", "route_invest", "route_startup"]:
		(malformed_identity["flags"] as Dictionary).erase(identity_flag)
	GameState.load_from_dict(malformed_identity)
	if GameState.tendency != {"career": 0, "invest": 0, "found": 0} \
			or not GameState.tendency_realized.is_empty() \
			or GameState.player_route != "none" \
			or GameState.tendency_evidence_version \
			!= GameState.TENDENCY_EVIDENCE_VERSION:
		_fail("malformed identity fields did not migrate fail-closed")
	GameState.new_game()
	if GameState.player_route != "none" \
			or bool(GameState.flags.get("route_career", false)) \
			or bool(GameState.flags.get("route_invest", false)) \
			or bool(GameState.flags.get("route_startup", false)):
		_fail("restart did not use the neutral New Story identity boundary")
	GameState.load_from_dict(identity_fixture_snapshot)
	GameState.set_block_signals(signals_were_blocked)
	GameState.action_axis_this_week = {"money": 1, "human": 1}
	game.call("_demo_director_capture_routine")
	if GameState.week_routine != ["study_invest", "rest"]:
		_fail("mixed investment/person decision lost either side: %s" % GameState.week_routine)
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

func _check_transient_portrait_timer_source_contract() -> void:
	var source := FileAccess.get_file_as_string("res://scenes/MainGame.gd")
	var marker := "func _check_milestones()"
	var start := source.find(marker)
	if source.is_empty() or start < 0:
		_fail("MainGame milestone source contract could not find _check_milestones")
		return
	var function_tail := source.substr(start)
	var next_function := function_tail.find("\nfunc ", marker.length())
	var function_source := function_tail if next_function < 0 \
		else function_tail.substr(0, next_function)
	for forbidden in ["create_timer(", "await "]:
		if function_source.contains(forbidden):
			_fail("_check_milestones reintroduced a free SceneTreeTimer coroutine: %s" \
				% forbidden)

func _check_transient_portrait_timer_contract() -> void:
	var language_before := LocaleManager.language
	LocaleManager.language = "ko"
	DataRegistry.reload()

	# A single refresh can cross several thresholds. Only the first threshold may
	# own the happy portrait; repeated refreshes must not duplicate it, and the
	# same child Timer must advance the queue in ascending order.
	_prepare_week_runtime_fixture(12)
	GameState.money = 8_000_000.0
	GameState.milestones_reached = {}
	var game := await _boot_week_runtime()
	if not is_instance_valid(game):
		LocaleManager.language = language_before
		DataRegistry.reload()
		return
	var milestone_timer := game.get("_milestone_portrait_timer") as Timer
	var critical_timer := game.get("_critical_portrait_timer") as Timer
	if not is_instance_valid(milestone_timer) or not is_instance_valid(critical_timer):
		_fail("MainGame did not create both view-owned portrait timers")
		await _dispose_week_runtime(game)
		LocaleManager.language = language_before
		DataRegistry.reload()
		return
	if milestone_timer.get_parent() != game or critical_timer.get_parent() != game \
			or not milestone_timer.one_shot or not critical_timer.one_shot \
			or not is_equal_approx(milestone_timer.wait_time, 2.0) \
			or not is_equal_approx(critical_timer.wait_time, 1.2) \
			or milestone_timer.process_mode != Node.PROCESS_MODE_ALWAYS \
			or critical_timer.process_mode != Node.PROCESS_MODE_ALWAYS:
		_fail("portrait timers are not reusable one-shot children of MainGame")
	milestone_timer.wait_time = 0.2
	GameState.money = 60_000_000.0
	game.call("_check_milestones")
	var milestone_timer_id := milestone_timer.get_instance_id()
	game.call("_check_milestones")
	game.call("_check_milestones")
	if GameState.milestones_reached.size() != 1 \
			or not GameState.milestones_reached.has("10m") \
			or _count_action_logs_containing("자산 1천만원 돌파") != 1 \
			or not bool(GameState.flags.get("just_hit_milestone", false)):
		_fail("simultaneous milestone crossing duplicated or skipped the first threshold")
	await milestone_timer.timeout
	for _frame in range(3):
		await get_tree().process_frame
		if GameState.milestones_reached.has("50m"):
			break
	if not is_instance_valid(milestone_timer) \
			or milestone_timer.get_instance_id() != milestone_timer_id \
			or GameState.milestones_reached.size() != 2 \
			or not GameState.milestones_reached.has("50m") \
			or _count_action_logs_containing("자산 5천만원 돌파") != 1 \
			or not bool(GameState.flags.get("just_hit_milestone", false)):
		_fail("milestone timeout did not reuse the timer for the next threshold")
	else:
		await milestone_timer.timeout
		await get_tree().process_frame
		if bool(GameState.flags.get("just_hit_milestone", false)) \
				or bool(game.get("_milestone_portrait_active")):
			_fail("final milestone timeout left the happy portrait active")

	# Repeated critical outcomes restart one child Timer. The flag must survive
	# the first deadline and clear only after the latest trigger's timeout.
	critical_timer.wait_time = 0.3
	game.call("_arm_critical_portrait_feedback")
	var critical_timer_id := critical_timer.get_instance_id()
	await get_tree().create_timer(0.12).timeout
	var time_left_before_restart := critical_timer.time_left
	game.call("_arm_critical_portrait_feedback")
	var time_left_after_restart := critical_timer.time_left
	if critical_timer.get_instance_id() != critical_timer_id \
			or time_left_after_restart <= time_left_before_restart:
		_fail("repeated critical feedback replaced or failed to restart its timer")
	await get_tree().create_timer(0.19).timeout
	if not bool(GameState.flags.get("just_critical_event", false)):
		_fail("critical portrait cleared at the first trigger's obsolete deadline")
	else:
		await critical_timer.timeout
		if bool(GameState.flags.get("just_critical_event", false)):
			_fail("critical portrait did not clear after the restarted timer")
	await _dispose_week_runtime(game)

	# Freeing MainGame before either timeout must synchronously clear global
	# transient state and free both child timers. A replacement view then handles
	# the next unmarked milestone once, without replaying the first.
	_prepare_week_runtime_fixture(12)
	GameState.money = 8_000_000.0
	GameState.milestones_reached = {}
	game = await _boot_week_runtime()
	if not is_instance_valid(game):
		LocaleManager.language = language_before
		DataRegistry.reload()
		return
	milestone_timer = game.get("_milestone_portrait_timer") as Timer
	critical_timer = game.get("_critical_portrait_timer") as Timer
	milestone_timer.wait_time = 10.0
	critical_timer.wait_time = 10.0
	GameState.money = 60_000_000.0
	game.call("_check_milestones")
	game.call("_arm_critical_portrait_feedback")
	var abandoned_milestone_timer_id := milestone_timer.get_instance_id()
	var abandoned_critical_timer_id := critical_timer.get_instance_id()
	game.free()
	await get_tree().process_frame
	if is_instance_id_valid(abandoned_milestone_timer_id) \
			or is_instance_id_valid(abandoned_critical_timer_id) \
			or bool(GameState.flags.get("just_hit_milestone", false)) \
			or bool(GameState.flags.get("just_critical_event", false)):
		_fail("freeing MainGame retained a portrait timer or transient flag")

	var replacement := await _boot_week_runtime()
	if is_instance_valid(replacement):
		replacement.call("_check_milestones")
		if GameState.milestones_reached.size() != 2 \
				or not GameState.milestones_reached.has("10m") \
				or not GameState.milestones_reached.has("50m") \
				or _count_action_logs_containing("자산 1천만원 돌파") != 1 \
				or _count_action_logs_containing("자산 5천만원 돌파") != 1:
			_fail("replacement MainGame did not continue with exactly one next milestone")
		replacement.free()
		await get_tree().process_frame
		if bool(GameState.flags.get("just_hit_milestone", false)) \
				or bool(GameState.flags.get("just_critical_event", false)):
			_fail("replacement MainGame teardown retained transient portrait state")
	else:
		_fail("replacement MainGame could not boot after timer-owner teardown")

	LocaleManager.language = language_before
	DataRegistry.reload()

func _count_action_logs_containing(fragment: String) -> int:
	var count := 0
	for raw_entry in GameState.action_log:
		var entry: Dictionary = raw_entry if raw_entry is Dictionary else {}
		if str(entry.get("message", "")).contains(fragment):
			count += 1
	return count

func _check_quiet_week_reading_contract() -> void:
	var language_before := LocaleManager.language
	LocaleManager.language = "ko"
	DataRegistry.reload()
	ControllerHints.force_brand_for_qa(ControllerHints.Brand.PLAYSTATION)

	_prepare_week_runtime_fixture(12)
	var quiet_game := await _boot_week_runtime()
	if not is_instance_valid(quiet_game):
		ControllerHints.clear_qa_override()
		LocaleManager.language = language_before
		DataRegistry.reload()
		return
	quiet_game.call("_demo_director_auto_week", "quiet")
	var compression_frames := 0
	while compression_frames < 12 \
			and not bool(quiet_game.get("_pending_month_summary")):
		compression_frames += 1
		await get_tree().process_frame
	if not bool(quiet_game.get("_pending_month_summary")):
		_fail("information-free quiet week did not reach its month summary within 12 frames")
	if GameState.turn != 13:
		_fail("compressed quiet week advanced to turn %d instead of 13" % GameState.turn)
	if GameState.last_month_money_weeks <= 0 or GameState.last_month_human_weeks <= 0:
		_fail("compressed quiet week lost its routine economy/axis settlement")
	var quiet_choice_box := quiet_game.get("choice_box") as Control
	if _has_visible_named_node(quiet_choice_box, "DemoDirectorBeat"):
		_fail("information-free quiet week still rendered a reading card")
	var quiet_title := quiet_game.get("event_title") as Label
	var quiet_body = quiet_game.get("event_body")
	if (is_instance_valid(quiet_title) and not quiet_title.text.is_empty()) \
			or (is_instance_valid(quiet_body) and not str(quiet_body.text).is_empty()):
		_fail("month summary left stale weekly title/body visible underneath")
	var summary_confirm := _find_control_with_meta(
		quiet_game.get("modal_body") as Node, "month_summary_confirm")
	if not is_instance_valid(summary_confirm):
		_fail("month summary has no explicit confirmation control")
	var summary_turn: int = GameState.turn
	await get_tree().create_timer(3.05).timeout
	if GameState.turn != summary_turn or not bool(quiet_game.get("_pending_month_summary")):
		_fail("month summary advanced automatically before confirmation")
	await _dispose_week_runtime(quiet_game)

	_prepare_week_runtime_fixture(6)
	GameState.weekly_commitments = [{
		"turn": 5,
		"pressure_id": "qa_echo",
		"pressure_family": "body",
		"choice_id": "rest",
		"actual_action_id": "rest",
		"person_id": "",
		"forgone_ids": ["save", "study"],
		"outcome": {"health": 4.0, "mental": 2.0},
		"echoed_turn": -1,
	}]
	# After confirmation, keep the fixture in MainGame instead of launching an arc.
	GameState.flags["foreground_story_turn"] = 7
	var echo_game := await _boot_week_runtime()
	if not is_instance_valid(echo_game):
		ControllerHints.clear_qa_override()
		LocaleManager.language = language_before
		DataRegistry.reload()
		return
	echo_game.call("_demo_director_auto_week", "echo")
	await get_tree().process_frame
	await get_tree().process_frame
	var echo_card := _find_control_with_meta(
		echo_game.get("choice_box") as Node, "requires_confirmation")
	var echo_confirm := _find_control_with_meta(
		echo_game.get("choice_box") as Node, "demo_beat_confirm")
	if not is_instance_valid(echo_card) or not bool(echo_card.get_meta(
			"requires_confirmation", false)):
		_fail("meaningful Echo did not render a blocking result card")
	if not is_instance_valid(echo_confirm):
		_fail("meaningful Echo has no explicit confirmation control")
	var echo_turn: int = GameState.turn
	await get_tree().create_timer(3.05).timeout
	if GameState.turn != echo_turn:
		_fail("meaningful Echo advanced automatically before confirmation")
	if is_instance_valid(echo_confirm) \
			and get_viewport().gui_get_focus_owner() != echo_confirm:
		_fail("meaningful Echo did not focus its controller confirmation")
	await _press_joy_south()
	if GameState.turn != echo_turn + 1:
		_fail("PlayStation south-button confirmation did not advance the Echo "
			+ "turn=%d disabled=%s advancing=%s focus=%s" % [
				GameState.turn,
				str(echo_confirm.disabled if is_instance_valid(echo_confirm) else "freed"),
				str(echo_game.get("_demo_director_advancing")),
				str(get_viewport().gui_get_focus_owner()),
			])
	await _dispose_week_runtime(echo_game)

	ControllerHints.clear_qa_override()
	LocaleManager.language = language_before
	DataRegistry.reload()

func _prepare_week_runtime_fixture(turn_value: int) -> void:
	GameState.start_new_game("김민준", "지방_상경", "직장형", "백수", "자유런", "현실")
	var zero_based := maxi(0, turn_value - 1)
	GameState.turn = turn_value
	GameState.year = 2026 + floori(float(zero_based) / 48.0)
	GameState.month = posmod(floori(float(zero_based) / 4.0), 12) + 1
	GameState.week_of_month = posmod(zero_based, 4) + 1
	GameState.money = 8_000_000.0
	GameState.monthly_income = 2_400_000.0
	GameState.current_job = {
		"id": "job_03",
		"name": "사무 보조",
		"category": "office",
		"base_salary": 2_400_000.0,
		"tier": 2,
	}
	GameState.health = 82
	GameState.mental = 84
	GameState.action_points = 2
	GameState.max_action_points = 2
	GameState.week_routine = ["save", "rest"]
	GameState.flags["prologue_done"] = true
	GameState.flags["story_flashforward_seen"] = true
	GameState.flags["tutorial_shown"] = true
	GameState.flags.erase("demo_director_kind_turn")
	GameState.flags.erase("demo_director_locked_kind")
	GameState.flags.erase("month_event_turn")
	GameState.add_log("ImmersionLoop quiet-week runtime fixture", "system")
	GameState.returning_from_story = false
	EventManager.event_cooldowns.clear()
	EventManager.recent_event_ids.clear()
	EventManager.narrative_bridge_results.clear()
	TutorialOverlay._seen["main_game"] = true

func _boot_week_runtime() -> Node:
	var packed := load("res://scenes/MainGame.tscn") as PackedScene
	if packed == null:
		_fail("MainGame.tscn failed to load for quiet-week runtime")
		return null
	var game := packed.instantiate()
	game.set_meta("_screenshot_qa_static_surface", true)
	add_child(game)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	return game

func _dispose_week_runtime(game: Node) -> void:
	if is_instance_valid(game):
		game.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame

func _find_control_with_meta(root: Node, meta_key: String) -> Control:
	if not is_instance_valid(root):
		return null
	if root is Control and root.has_meta(meta_key):
		return root as Control
	for child in root.get_children():
		var found := _find_control_with_meta(child, meta_key)
		if is_instance_valid(found):
			return found
	return null

func _has_visible_named_node(root: Node, node_name: String) -> bool:
	if not is_instance_valid(root):
		return false
	if root.name == node_name and (not (root is CanvasItem) or (root as CanvasItem).visible):
		return true
	for child in root.get_children():
		if _has_visible_named_node(child, node_name):
			return true
	return false

func _press_joy_south() -> void:
	# ControllerHints is forced to PlayStation above; feed the semantic confirm
	# action that Steam Input maps from the physical south (Cross) button.
	var press := InputEventAction.new()
	press.action = "ui_accept"
	press.pressed = true
	Input.parse_input_event(press)
	await get_tree().process_frame
	var release := InputEventAction.new()
	release.action = "ui_accept"
	release.pressed = false
	Input.parse_input_event(release)
	await get_tree().process_frame

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

func _expect_surface_exact(
		actual: String,
		expected: String,
		forbidden_tokens: Array,
		context: String,
		require_english := false) -> void:
	if actual != expected:
		_fail("%s changed:\nexpected=%s\nactual=%s" % [context, expected, actual])
	var normalized := actual.to_lower()
	for raw_token in forbidden_tokens:
		var token := str(raw_token).to_lower()
		if not token.is_empty() and normalized.contains(token):
			_fail("%s exposed retired system detail '%s': %s" % [context, raw_token, actual])
	if require_english and _contains_hangul(actual):
		_fail("%s leaked Hangul: %s" % [context, actual])

func _expect_close(actual: float, expected: float, message: String, epsilon: float = 0.0001) -> void:
	if absf(actual - expected) > epsilon:
		_fail("%s expected=%.3f actual=%.3f" % [message, expected, actual])

func _fail(message: String) -> void:
	_failures.append(message)
