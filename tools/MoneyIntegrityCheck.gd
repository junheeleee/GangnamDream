extends Node
## ORDER-84: whole-won cash, funded opportunity choices, and legacy migration.

const INVESTMENT_SYSTEM := preload("res://systems/InvestmentSystem.gd")
const MAIN_GAME_SCRIPT := preload("res://scenes/MainGame.gd")
const STORY_MODE_SCRIPT := preload("res://scenes/StoryMode.gd")

const OPPORTUNITY_FILES := [
	"res://content/events/amb_scenarios2.json",
	"res://content/events/arc_events.json",
	"res://content/events/callback_events_3.json",
	"res://content/events/callback_events_4.json",
	"res://content/events/callback_events_5.json",
	"res://content/events/investment_events.json",
	"res://content/events/scenario_cafe_callback.json",
]
const FALLBACK_EVENT_IDS := [
	"cafe_cb_stole_allin",
	"cafe_cb_stole_smart",
]

var _failures: Array[String] = []
var _inject_late_commitment := false


func _ready() -> void:
	_check_rounding_boundaries()
	_check_monthly_settlement()
	_check_opportunity_inventory_and_visibility()
	_check_zero_stake_is_inert()
	_check_fomo_predebit_gate()
	_check_positive_win_and_loss()
	_check_fallback_resolution()
	_check_item_gated_opportunity_fallback()
	_check_investment_cash_receipts()
	_check_loan_cash_conservation()
	_check_legacy_save_and_reload()
	_check_atomic_rollback()

	EventManager.current_event = {}
	EventManager.pending_events.clear()
	EventManager.narrative_bridge_results.clear()
	if _failures.is_empty():
		print(
			"MONEY_INTEGRITY_CHECK_OK "
			+ "cash=whole_won/half_away/positive_zero_negative "
			+ "monthly=single_settlement opportunities=19/15/7 "
			+ "availability=main_story_event_manager/predebit "
			+ "zero_stake=inert_rng_state_cooldown_followup "
			+ "fallbacks=2/state_free/ko_en_indexed/item_gate_safe "
			+ "mods=new_override_topology_guarded "
			+ "outcomes=win_loss_net_once investment=receipts_conserved "
			+ "save=legacy_phone_fraction_normalized/reload_idempotent "
			+ "rollback=serialized_exact")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("MONEY_INTEGRITY_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)


func _check_rounding_boundaries() -> void:
	_expect(GameState.settle_cash(1.49) == 1.0, "positive value did not round down")
	_expect(GameState.settle_cash(1.5) == 2.0, "positive .5 did not round away from zero")
	_expect(GameState.settle_cash(-1.49) == -1.0, "negative value did not round toward nearest won")
	_expect(GameState.settle_cash(-1.5) == -2.0, "negative .5 did not round away from zero")

	_fresh()
	GameState.money = 10.0
	_expect(GameState.add_money(-0.5) == -1.0 and GameState.money == 9.0,
		"positive balance plus a -0.5 transaction failed to charge one won")
	_expect_whole_serialized("positive balance / negative half")

	GameState.money = -10.0
	_expect(GameState.add_money(0.5) == 1.0 and GameState.money == -9.0,
		"negative balance plus a +0.5 transaction failed to credit one won")
	_expect_whole_serialized("negative balance / positive half")

	GameState.money = 0.0
	_expect(GameState.add_money(0.49) == 0.0 and GameState.money == 0.0,
		"sub-half positive transaction created cash")
	_expect(GameState.add_money(-0.49) == 0.0 and GameState.money == 0.0,
		"sub-half negative transaction removed cash")


func _check_monthly_settlement() -> void:
	_fresh()
	GameState.money = 100.0
	GameState.housing = "gosiwon"
	GameState.monthly_income = GameState.get_housing_expense() + 0.5
	GameState.current_job = {}
	GameState.loans = {"bank": 0.0, "second": 0.0}
	seed(31_415)
	GameState.apply_monthly_pressure()
	_expect(GameState.money == 101.0,
		"monthly salary minus fixed expense did not settle once to +1 won")
	_expect_whole_serialized("monthly salary and fixed expense")


func _check_opportunity_inventory_and_visibility() -> void:
	var opportunity_choices := 0
	var opportunity_events: Dictionary = {}
	var opportunity_files: Dictionary = {}
	var fallback_events: Dictionary = {}
	for path in OPPORTUNITY_FILES:
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		_expect(parsed is Array, "%s is not an event array" % path)
		if not parsed is Array:
			continue
		for event_value in parsed as Array:
			if not event_value is Dictionary:
				continue
			var event: Dictionary = event_value
			var event_has_opportunity := false
			for choice_value in event.get("choices", []):
				if not choice_value is Dictionary:
					continue
				var choice: Dictionary = choice_value
				if choice.get("opportunity", {}) is Dictionary \
						and not (choice.get("opportunity", {}) as Dictionary).is_empty():
					opportunity_choices += 1
					event_has_opportunity = true
				if choice.get("opportunity_unavailable_fallback", false) is bool \
						and bool(choice.get("opportunity_unavailable_fallback", false)):
					fallback_events[str(event.get("id", ""))] = true
			if event_has_opportunity:
				opportunity_events[str(event.get("id", ""))] = true
				opportunity_files[str(path)] = true
	_expect(opportunity_choices == 19, "runtime inventory is not 19 opportunity choices")
	_expect(opportunity_events.size() == 15, "runtime inventory is not 15 opportunity events")
	_expect(opportunity_files.size() == 7, "runtime inventory is not seven opportunity files")
	_expect(fallback_events.keys().all(func(event_id):
		return str(event_id) in FALLBACK_EVENT_IDS) \
		and fallback_events.size() == 2,
		"fallback event inventory is not the two legacy one-choice scenes")

	var main_game: Node = MAIN_GAME_SCRIPT.new()
	var story_mode: Node = STORY_MODE_SCRIPT.new()
	for raw_event_id in opportunity_events:
		var event_id := str(raw_event_id)
		var event: Dictionary = DataRegistry.find_event(event_id)
		var choices: Array = event.get("choices", [])
		for empty_cash in [0.0, -50.0]:
			GameState.money = empty_cash
			story_mode.set("_current", event)
			var expected_indices: Array[int] = []
			for choice_index in range(choices.size()):
				var choice: Dictionary = choices[choice_index]
				if choice.get("opportunity", {}) is Dictionary \
						and not (choice.get("opportunity", {}) as Dictionary).is_empty():
					_expect(not GameState.choice_available(event, choice),
						"%s[%d] stayed available at cash %s"
							% [event_id, choice_index, str(empty_cash)])
				if GameState.choice_available(event, choice):
					expected_indices.append(choice_index)
			var main_indices: Array = main_game.call(
				"_available_event_choice_indices", event)
			var story_indices: Array = story_mode.call(
				"_visible_choice_indices", event)
			_expect(not expected_indices.is_empty(),
				"%s has no legal exit at cash %s" % [event_id, str(empty_cash)])
			_expect(main_indices == expected_indices and story_indices == expected_indices,
				"%s MainGame/StoryMode availability diverged at cash %s"
					% [event_id, str(empty_cash)])

		for choice_index in range(choices.size()):
			var choice: Dictionary = choices[choice_index]
			var opportunity: Variant = choice.get("opportunity", {})
			if not opportunity is Dictionary \
					or (opportunity as Dictionary).is_empty():
				continue
			var minimum_cash := _minimum_cash_for_opportunity_choice(choice)
			GameState.money = minimum_cash
			_expect(GameState.choice_available(event, choice),
				"%s[%d] rejected its first positive whole-won stake at cash %s"
					% [event_id, choice_index, str(minimum_cash)])

	for event_id in FALLBACK_EVENT_IDS:
		var event: Dictionary = DataRegistry.find_event(event_id)
		GameState.money = 0.0
		_expect(main_game.call("_available_event_choice_indices", event) == [1],
			"%s did not expose only fallback at zero cash" % event_id)
		story_mode.set("_current", event)
		story_mode.set("_read_only_replay", true)
		_expect(story_mode.call("_visible_choice_indices", event) == [0],
			"%s replay rewrote its funded historical choice as a cash fallback"
				% event_id)
		story_mode.set("_read_only_replay", false)
		GameState.money = 1.0
		_expect(main_game.call("_available_event_choice_indices", event) == [0],
			"%s did not expose only opportunity at one won" % event_id)
	main_game.free()
	story_mode.free()

	var fixed_choice := {
		"text": "fixed",
		"result_text": "fixed",
		"opportunity": {"cost": 1.5},
	}
	var fixed_event := {"id": "qa_fixed_cost", "choices": [fixed_choice]}
	GameState.money = 1.0
	_expect(not GameState.choice_available(fixed_event, fixed_choice),
		"fixed-cost opportunity ignored its rounded two-won cost")
	GameState.money = 2.0
	_expect(GameState.choice_available(fixed_event, fixed_choice) \
		and GameState.opportunity_stake(fixed_choice["opportunity"]) == 2.0,
		"fixed-cost opportunity rejected an affordable rounded two-won stake")


func _check_zero_stake_is_inert() -> void:
	_fresh()
	GameState.money = 0.0
	var base_event: Dictionary = DataRegistry.find_event("amb_coin_00")
	var choice: Dictionary = (
		base_event.get("choices", [])[0] as Dictionary).duplicate(true)
	choice["effects"] = {"mental": 7}
	choice["flags"] = ["qa_zero_stake_leak"]
	choice["follow_up_event"] = "cafe_cb_stole_allin"
	choice["deferred_follow_up"] = "cafe_cb_stole_smart"
	choice["deferred_delay"] = 1
	var event := {
		"id": "qa_zero_stake_event",
		"title": "QA zero stake",
		"choices": [choice],
	}
	var before: Dictionary = GameState.serialize().duplicate(true)
	seed(87_654)
	var expected_next_roll: float = randf()
	seed(87_654)
	_expect(not GameState.apply_choice(event, choice),
		"zero-stake choice was accepted directly")
	var actual_next_roll: float = randf()
	_expect(actual_next_roll == expected_next_roll,
		"zero-stake direct choice consumed RNG")
	_expect(GameState.serialize() == before,
		"zero-stake direct choice changed serialized state")

	EventManager.current_event = event.duplicate(true)
	EventManager.pending_events = [{"id": "qa_existing_pending"}]
	var cooldowns_before: Dictionary = EventManager.event_cooldowns.duplicate(true)
	var recent_before: Array = EventManager.recent_event_ids.duplicate(true)
	var bridges_before: Array = EventManager.narrative_bridge_results.duplicate(true)
	var pending_before: Array = EventManager.pending_events.duplicate(true)
	seed(91_919)
	expected_next_roll = randf()
	seed(91_919)
	_expect(not EventManager.resolve_current_event(0),
		"EventManager accepted a zero-stake current choice")
	actual_next_roll = randf()
	_expect(actual_next_roll == expected_next_roll,
		"EventManager zero-stake rejection consumed RNG")
	_expect(GameState.serialize() == before \
		and EventManager.current_event == event \
		and EventManager.event_cooldowns == cooldowns_before \
		and EventManager.recent_event_ids == recent_before \
		and EventManager.narrative_bridge_results == bridges_before \
		and EventManager.pending_events == pending_before,
		"EventManager zero-stake rejection changed state, cooldown, or history")
	EventManager.current_event = {}
	EventManager.pending_events.clear()

	seed(73_311)
	expected_next_roll = randf()
	seed(73_311)
	_expect(not EventManager.resolve_narrative_bridge("amb_coin_00", 0),
		"narrative bridge accepted a zero-stake choice")
	actual_next_roll = randf()
	_expect(actual_next_roll == expected_next_roll \
		and GameState.serialize() == before \
		and EventManager.narrative_bridge_results == bridges_before,
		"narrative bridge zero-stake rejection changed RNG or state")


func _check_fomo_predebit_gate() -> void:
	_fresh()
	var event: Dictionary = DataRegistry.find_event("callback_fomo_invested_result")
	var choice: Dictionary = event.get("choices", [])[1]
	GameState.money = 1_000_004.0
	_expect(not GameState.choice_available(event, choice),
		"FOMO opportunity ignored its one-million-won pre-debit boundary")
	var before: Dictionary = GameState.serialize().duplicate(true)
	_expect(not GameState.apply_choice(event, choice) \
		and GameState.serialize() == before,
		"invalid FOMO choice applied its top-level debit or other state")
	GameState.money = 1_000_005.0
	_expect(GameState.choice_available(event, choice),
		"FOMO opportunity rejected the first balance that settles a one-won stake")


func _check_positive_win_and_loss() -> void:
	var win_choice: Dictionary = {
		"text": "win",
		"result_text": "win",
		"opportunity": {
			"stake_ratio": 0.5,
			"success_rate": 0.98,
			"win_multiplier": 1.5,
			"loss_ratio": 0.5,
			"luck_factor": 0.0,
			"skill_gain": 3,
			"win_flag": "qa_money_win",
			"lose_flag": "qa_money_loss",
		},
	}
	var event: Dictionary = {"id": "qa_money_win_event", "title": "QA", "choices": [win_choice]}
	_fresh()
	GameState.money = 5.0
	GameState.luck = 0
	GameState.cast["sangchul"]["affinity"] = 0
	var mental_before: int = GameState.mental
	var skill_before: int = GameState.investment_skill
	seed(_seed_with_roll(true, 0.98))
	_expect(GameState.apply_choice(event, win_choice), "funded win choice was rejected")
	# round(5 * .5) = 3 stake; round(3 * 1.5) = +5 net.
	_expect(GameState.money == 10.0 \
		and GameState.investment_skill == skill_before + 3 \
		and GameState.mental == mental_before + 2 \
		and bool(GameState.flags.get("qa_money_win", false)) \
		and str(GameState.flags.get("_last_opportunity_result", "")) == "win",
		"opportunity win did not settle one exact +5-won net transaction")
	_expect_whole_serialized("positive opportunity win")

	var lose_choice: Dictionary = win_choice.duplicate(true)
	lose_choice["text"] = "lose"
	lose_choice["result_text"] = "lose"
	(lose_choice["opportunity"] as Dictionary)["success_rate"] = 0.02
	event = {"id": "qa_money_loss_event", "title": "QA", "choices": [lose_choice]}
	_fresh()
	GameState.money = 5.0
	GameState.luck = 0
	GameState.cast["sangchul"]["affinity"] = 0
	mental_before = GameState.mental
	skill_before = GameState.investment_skill
	seed(_seed_with_roll(false, 0.02))
	_expect(GameState.apply_choice(event, lose_choice), "funded loss choice was rejected")
	# round(5 * .5) = 3 stake; round(3 * .5) = -2 net.
	_expect(GameState.money == 3.0 \
		and GameState.investment_skill == skill_before + 3 \
		and GameState.mental == mental_before - 9 \
		and bool(GameState.flags.get("qa_money_loss", false)) \
		and str(GameState.flags.get("_last_opportunity_result", "")) == "lose",
		"opportunity loss did not settle one exact -2-won net transaction")
	_expect_whole_serialized("positive opportunity loss")


func _check_fallback_resolution() -> void:
	for event_id in FALLBACK_EVENT_IDS:
		_fresh()
		GameState.money = 0.0
		var event: Dictionary = DataRegistry.find_event(event_id)
		var choices: Array = event.get("choices", [])
		_expect(choices.size() == 2,
			"%s does not have opportunity plus fallback" % event_id)
		if choices.size() != 2:
			continue
		var fallback: Dictionary = choices[1]
		_expect(not GameState.choice_available(event, choices[0]) \
			and GameState.choice_available(event, fallback),
			"%s zero-cash availability is not opportunity-off/fallback-on" % event_id)
		var money_before: float = GameState.money
		var stats_before: Dictionary = _public_stat_snapshot()
		var flags_before: Dictionary = GameState.flags.duplicate(true)
		var deferred_before: Array = GameState.deferred_events.duplicate(true)
		var events_seen_before: int = GameState.events_seen
		var event_log_before: int = GameState.event_log.size()
		seed(64_002)
		var expected_next_roll := randf()
		seed(64_002)
		EventManager.current_event = event.duplicate(true)
		_expect(EventManager.resolve_current_event(1),
			"%s fallback did not resolve normally" % event_id)
		var actual_next_roll := randf()
		_expect(actual_next_roll == expected_next_roll \
			and GameState.money == money_before \
			and _public_stat_snapshot() == stats_before \
			and GameState.flags == flags_before \
			and GameState.deferred_events == deferred_before,
			"%s fallback changed RNG, cash, stats, flags, or follow-up" % event_id)
		_expect(GameState.events_seen == events_seen_before + 1 \
			and GameState.event_log.size() == event_log_before + 1 \
			and EventManager.current_event.is_empty(),
			"%s fallback did not create exactly one neutral event completion" % event_id)
		_expect_whole_serialized("%s fallback" % event_id)


func _check_item_gated_opportunity_fallback() -> void:
	_fresh()
	GameState.money = 100.0
	var opportunity_choice := {
		"text": "Risk it",
		"result_text": "Resolved.",
		"requires_item": "qa_opportunity_ticket",
		"opportunity": {
			"stake_ratio": 0.5,
			"success_rate": 0.5,
			"win_multiplier": 2.0,
			"loss_ratio": 1.0,
		},
	}
	var fallback_choice := {
		"text": "Leave",
		"result_text": "Left.",
		"opportunity_unavailable_fallback": true,
	}
	var event := {
		"id": "qa_item_gated_opportunity",
		"choices": [opportunity_choice, fallback_choice],
	}
	_expect(not GameState.choice_available(event, opportunity_choice) \
		and GameState.choice_available(event, fallback_choice),
		"item-gated opportunity hid both itself and its fallback")
	GameState.inventory = [{"id": "qa_opportunity_ticket", "quantity": 1}]
	_expect(GameState.choice_available(event, opportunity_choice) \
		and not GameState.choice_available(event, fallback_choice),
		"funded item-gated opportunity did not replace its fallback")
	_expect(not DataRegistry._mod_opportunity_topology_valid([
		opportunity_choice,
		{
			"text": "Use another item",
			"result_text": "Left.",
			"requires_item": "qa_other_ticket",
		},
	]), "mod topology accepted an item-gated-only opportunity exit")
	_expect(DataRegistry._mod_opportunity_topology_valid([
		opportunity_choice, fallback_choice,
	]), "mod topology rejected a state-free opportunity fallback")


func _check_investment_cash_receipts() -> void:
	_fresh()
	var investment: Node = INVESTMENT_SYSTEM.new()
	var asset: Dictionary = DataRegistry.assets[0]
	var asset_id: String = str(asset.get("id", ""))
	var minimum: float = maxf(
		float(asset.get("min_invest", 1.0)),
		float(asset.get("initial_price", asset.get("base_price", 1.0))))
	var requested: float = ceil(minimum) + 0.5
	var committed: float = GameState.settle_cash(requested)
	GameState.money = committed + 10.0
	var money_before: float = GameState.money
	var buy: Dictionary = investment.buy_asset(asset_id, requested)
	_expect(bool(buy.get("success", false)) \
		and float(buy.get("cash_committed", 0.0)) == committed \
		and GameState.money == money_before - committed,
		"investment buy cash, receipt, and balance did not conserve one settled amount")
	_expect_whole_serialized("investment buy")

	var sell: Dictionary = investment.sell_asset(asset_id, 1.0)
	var proceeds: float = float(sell.get("proceeds", 0.0))
	_expect(bool(sell.get("success", false)) \
		and proceeds == GameState.settle_cash(proceeds) \
		and GameState.money == money_before - committed + proceeds,
		"investment sell receipt did not match the credited whole-won proceeds")
	_expect_whole_serialized("investment sell")

	GameState.portfolio[asset_id] = {
		"quantity": 0.000000001,
		"avg_price": float(GameState.market_prices.get(asset_id, 1.0)),
	}
	var tiny_before: Dictionary = GameState.portfolio[asset_id].duplicate(true)
	var tiny_sale: Dictionary = investment.sell_asset(asset_id, 1.0)
	_expect(not bool(tiny_sale.get("success", true)) \
		and GameState.portfolio.get(asset_id, {}) == tiny_before,
		"voluntary sale disposed of an asset for zero settled won")

	var leverage_before: Dictionary = GameState.serialize().duplicate(true)
	var zero_leverage: Dictionary = investment.buy_asset_leveraged(asset_id, 0.49)
	_expect(not bool(zero_leverage.get("success", true)) \
		and GameState.serialize() == leverage_before,
		"sub-one-won leverage trade changed cash, portfolio, skill, or logs")
	var negative_leverage: Dictionary = investment.buy_asset_leveraged(asset_id, -10.0)
	_expect(not bool(negative_leverage.get("success", true)) \
		and GameState.serialize() == leverage_before,
		"negative leverage trade changed cash, portfolio, skill, or logs")

	GameState.portfolio.clear()
	var leverage_requested := 200_000.5
	var leverage_committed := GameState.settle_cash(leverage_requested)
	GameState.money = leverage_committed + 10.0
	money_before = GameState.money
	var leverage: Dictionary = investment.buy_asset_leveraged(
		asset_id, leverage_requested)
	_expect(bool(leverage.get("success", false)) \
		and float(leverage.get("cash_committed", 0.0)) == leverage_committed \
		and float(leverage.get("exposure", 0.0)) == leverage_committed * 2.0 \
		and GameState.money == money_before - leverage_committed \
		and float((GameState.portfolio.get(asset_id, {}) as Dictionary).get(
			"leveraged_amount", 0.0)) == leverage_committed,
		"positive leverage cash, principal, exposure, and receipt diverged")
	_expect_whole_serialized("positive leverage buy")

	var dividend_asset: Dictionary = {}
	for asset_value in DataRegistry.assets:
		if asset_value is Dictionary \
				and str((asset_value as Dictionary).get("category", "")) \
					in ["korean_stock", "real_estate"]:
			dividend_asset = asset_value
			break
	_expect(not dividend_asset.is_empty(), "no dividend-paying asset is registered")
	if not dividend_asset.is_empty():
		var dividend_id := str(dividend_asset.get("id", ""))
		var dividend_price := float(GameState.market_prices.get(
			dividend_id, dividend_asset.get("initial_price", 1.0)))
		GameState.portfolio = {
			dividend_id: {"quantity": 0.5 / (dividend_price * 0.002)},
		}
		GameState.money = 0.0
		investment.call("_apply_dividends")
		_expect(GameState.money == 1.0,
			"exact half-won dividend did not settle to one credited won")
		_expect_whole_serialized("dividend")

	GameState.portfolio = {
		asset_id: {
			"quantity": 0.6 / 0.85 / 10.0,
			"avg_price": 100.0,
			"leveraged_amount": 100.0,
		},
	}
	GameState.market_prices[asset_id] = 10.0
	GameState.money = 0.0
	investment.call("_check_margin_calls")
	_expect(GameState.money == 1.0 \
		and not GameState.portfolio.has(asset_id),
		"margin call did not credit rounded liquidation proceeds and erase position")
	_expect_whole_serialized("margin-call liquidation")
	investment.free()


func _check_loan_cash_conservation() -> void:
	_fresh()
	GameState.money = 100.0
	var cash_before: float = GameState.money
	_expect(GameState.borrow("second", 100.5),
		"fractional loan request did not settle to a valid whole-won principal")
	_expect(float(GameState.loans.get("second", 0.0)) == 101.0 \
		and GameState.money == cash_before + 101.0,
		"borrowed principal and credited cash diverged")
	_expect(GameState.repay("second", 40.5),
		"fractional repayment did not settle to a valid whole-won payment")
	_expect(float(GameState.loans.get("second", 0.0)) == 60.0 \
		and GameState.money == cash_before + 60.0,
		"repaid principal and debited cash diverged")

	# Grade 10 gives 1.12% / 1.53%.  These principals deliberately make the
	# combined raw interest 0.5008 won while each product is below 0.5 won;
	# per-product rounding would incorrectly produce zero.
	GameState.money = -1.0
	GameState.monthly_income = 0.0
	GameState.loans = {"bank": 1.0, "second": 32.0}
	_expect(GameState.get_credit_grade() == 10,
		"interest fixture did not hold credit grade 10")
	var raw_interest := (
		1.0 * GameState.get_loan_rate("bank")
		+ 32.0 * GameState.get_loan_rate("second"))
	_expect(raw_interest > 0.5 and raw_interest < 0.501 \
		and GameState.get_monthly_loan_interest() == 1.0,
		"two-product interest was not summed raw and settled once")
	_expect_whole_serialized("loan borrow and repay")

	var legacy_principal: Dictionary = GameState.serialize().duplicate(true)
	legacy_principal["loans"] = {"bank": 100.5, "second": 200.49}
	GameState.load_from_dict(legacy_principal)
	_expect(GameState.loans == {"bank": 101.0, "second": 200.0},
		"fractional legacy loan principal did not normalize to whole won")


func _check_legacy_save_and_reload() -> void:
	_fresh()
	var legacy_save: Dictionary = GameState.serialize().duplicate(true)
	# If cash were rounded before the phone refund, this crossing case would
	# become zero instead of +1 and expose the wrong migration order.
	legacy_save["money"] = -179_999.5
	legacy_save["turn"] = 20
	legacy_save["phone_state"] = _valid_legacy_phone_state()
	GameState.load_from_dict(legacy_save)
	_expect(GameState.money == 1.0,
		"fractional legacy cash plus phone refund did not normalize once at the end")
	_expect_whole_serialized("legacy phone refund")
	var settled: Dictionary = GameState.serialize().duplicate(true)
	GameState.money = -999.0
	GameState.load_from_dict(settled)
	_expect(GameState.money == 1.0 \
		and GameState.serialize() == settled,
		"settled save/load was not idempotent")
	GameState.load_from_dict(GameState.serialize().duplicate(true))
	_expect(GameState.money == 1.0,
		"second settled reload changed cash")

	var negative_legacy: Dictionary = settled.duplicate(true)
	negative_legacy["money"] = -100.5
	negative_legacy["phone_state"] = {
		"schema": 3,
		"device_purchase_retired": true,
		"legacy_refund_applied": true,
		"legacy_refund_amount": 0.0,
	}
	GameState.load_from_dict(negative_legacy)
	_expect(GameState.money == -101.0,
		"negative fractional legacy cash did not round away from zero")

	var forged_legacy: Dictionary = settled.duplicate(true)
	forged_legacy["money"] = 100.5
	var forged_phone: Dictionary = _valid_legacy_phone_state()
	var forged_receipt: Dictionary = (
		forged_phone.get("purchase_receipts", [])[0] as Dictionary).duplicate(true)
	forged_receipt["price"] = 179_999.0
	forged_phone["purchase_receipts"] = [forged_receipt]
	forged_legacy["phone_state"] = forged_phone
	GameState.load_from_dict(forged_legacy)
	_expect(GameState.money == 101.0 \
		and GameState.phone_state == {
			"schema": 3,
			"device_purchase_retired": true,
			"legacy_refund_applied": true,
			"legacy_refund_amount": 0.0,
		},
		"forged phone receipt produced a refund or skipped cash normalization")


func _check_atomic_rollback() -> void:
	_fresh()
	GameState.turn = 5
	GameState.money = 1_000.0
	_expect(GameState.arm_weekly_commitment({
		"turn": 5,
		"pressure_id": "qa_money_rollback",
		"pressure_family": "qa",
		"choice_id": "rest",
		"forgone_ids": [],
	}), "money rollback fixture could not arm its commitment")
	var before: Dictionary = GameState.serialize().duplicate(true)
	var injection_callback: Callable = Callable(self, "_inject_commitment_after_spend")
	GameState.stats_changed.connect(injection_callback)
	_inject_late_commitment = true
	var result: Dictionary = GameState.finalize_weekly_effect_action(
		"rest", {"money": 123.5, "mental": 1}, "human", "home")
	_inject_late_commitment = false
	if GameState.stats_changed.is_connected(injection_callback):
		GameState.stats_changed.disconnect(injection_callback)
	_expect(not bool(result.get("ok", true)) \
		and bool(result.get("rolled_back", false)) \
		and GameState.serialize() == before,
		"failed transaction did not roll whole-won cash back byte-for-byte")
	_expect_whole_serialized("atomic rollback")


func _inject_commitment_after_spend() -> void:
	if not _inject_late_commitment:
		return
	_inject_late_commitment = false
	GameState.weekly_commitments.append({
		"turn": GameState.turn,
		"choice_id": "qa_conflict",
		"actual_action_id": "qa_conflict",
	})


func _minimum_cash_for_opportunity_choice(choice: Dictionary) -> float:
	var opportunity: Dictionary = choice.get("opportunity", {})
	var projected_minimum := 0.0
	if opportunity.has("stake_ratio"):
		var ratio := float(opportunity.get("stake_ratio", 0.0))
		projected_minimum = 1.0
		while GameState.settle_cash(projected_minimum * ratio) < 1.0:
			projected_minimum += 1.0
	else:
		projected_minimum = GameState.settle_cash(
			float(opportunity.get("cost", 0.0)))
	var effects: Variant = choice.get("effects", {})
	var pre_delta := 0.0
	if effects is Dictionary:
		pre_delta = GameState.settle_cash(
			float((effects as Dictionary).get("money", 0.0)))
	return maxf(0.0, projected_minimum - pre_delta)


func _seed_with_roll(want_below: bool, threshold: float) -> int:
	for candidate in range(1, 100_000):
		seed(candidate)
		var roll := randf()
		if (want_below and roll < threshold) \
				or (not want_below and roll >= threshold):
			return candidate
	return 1


func _valid_legacy_phone_state() -> Dictionary:
	return {
		"schema": 2,
		"current_device_id": "refurbished",
		"owned_device_ids": ["starter", "refurbished"],
		"purchase_receipts": [{
			"device_id": "refurbished",
			"previous_device_id": "starter",
			"price": 180_000.0,
			"turn": 13,
			"balance_before": 500_000.0,
			"balance_after": 320_000.0,
		}],
		"favorite_app_id": "bank",
	}


func _public_stat_snapshot() -> Dictionary:
	return {
		"health": GameState.health,
		"mental": GameState.mental,
		"intelligence": GameState.intelligence,
		"social_skill": GameState.social_skill,
		"appearance": GameState.appearance,
		"investment_skill": GameState.investment_skill,
		"luck": GameState.luck,
		"reputation": GameState.reputation,
	}


func _expect_whole_serialized(label: String) -> void:
	var serialized_money := float(GameState.serialize().get("money", 0.0))
	_expect(serialized_money == GameState.settle_cash(serialized_money),
		"%s serialized fractional cash %s" % [label, str(serialized_money)])
	_expect(float(GameState.money) == GameState.settle_cash(float(GameState.money)),
		"%s retained fractional live cash %s" % [label, str(GameState.money)])


func _fresh() -> void:
	GameState.start_new_game("김민준", "지방_상경", "none", "백수", "자유런", "현실")
	GameState.difficulty = "현실"
	GameState.flags.erase("_last_opportunity_result")
	EventManager.current_event = {}
	EventManager.pending_events.clear()
	EventManager.narrative_bridge_results.clear()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
