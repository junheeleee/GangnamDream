extends Node
## ORDER-834 B1 regression: the investment branch opens only from Sangchul's
## first lesson, plays its authored beats on free weeks in ledger order inside
## their windows and housing, never twice and never closer than MIN_GAP_WEEKS,
## shows the first-loss scene only when holdings are actually under water,
## survives a JSON save, and its choices really trade through the portfolio.

const BEATS := preload("res://systems/InvestBranchBeats.gd")

var _failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	_check_ledger()
	_check_gate_order_gap()
	_check_housing_and_window()
	_check_loss_beat()
	_check_json_round_trip()
	_check_market_choices()
	_check_years_three_four()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("INVEST_BRANCH_BEATS_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("INVEST_BRANCH_BEATS_CHECK_OK beats=%d gate=1 order=3 housing=2 loss=2 json=1 market=4 y34_crash=3 y34_sangchul=1 y34_lean=3 y34_trades=2" % [
		(BEATS.ledger().get("beats", []) as Array).size()])
	get_tree().quit(0)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _always(_event_id: String) -> bool:
	return true


func _gate() -> Dictionary:
	return {"investment_lesson_1": true}


func _check_ledger() -> void:
	var beats: Array = BEATS.ledger().get("beats", [])
	_expect(beats.size() >= 6, "investment ledger lost its beats (%d)" % beats.size())
	var trades := 0
	for raw in beats:
		var event_id := str((raw as Dictionary).get("event_id", ""))
		var event: Dictionary = DataRegistry.find_event(event_id)
		_expect(not event.is_empty() and (event.get("choices", []) as Array).size() >= 2,
			"investment beat missing or without a decision: " + event_id)
		for choice in event.get("choices", []):
			if (choice as Dictionary).has("market_buy") or (choice as Dictionary).has("market_sell"):
				trades += 1
	_expect(trades >= 5, "investment beats no longer trade (%d trading choices)" % trades)


func _check_gate_order_gap() -> void:
	var flags := {}
	_expect(BEATS.take_scene(flags, 17, "gosiwon", {}, {}, _always) == "",
		"the branch opened without Sangchul's lesson")
	flags = _gate()
	_expect(BEATS.take_scene(flags, 17, "gosiwon", {}, {}, _always) == "arc_ch1_invest_first_chart",
		"the first account did not open the branch")
	_expect(BEATS.take_scene(flags, 18, "gosiwon", {}, {}, _always) == "",
		"two investment beats played within the gap")
	_expect(BEATS.take_scene(flags, 20, "gosiwon", {}, {}, _always) == "arc_ch1_theme_invest_deep",
		"the study night did not follow the first account")


func _check_housing_and_window() -> void:
	var moved := _gate()
	_expect(BEATS.take_scene(moved, 20, "villa", {}, {}, _always) == "",
		"a goshiwon-desk scene played after moving out")
	var late := _gate()
	_expect(BEATS.take_scene(late, 50, "villa", {}, {}, _always) == "inv_crypto_mania",
		"year-two coin craze missed its window")


func _check_loss_beat() -> void:
	var holding := {"kospi_etf": {"quantity": 1.0, "avg_price": 35000.0}}
	var up := _gate()
	up["invest_branch_state"] = {"used": ["arc_ch1_invest_first_chart", "arc_ch1_theme_invest_deep"], "last_turn": 20}
	_expect(BEATS.take_scene(up, 30, "villa", holding, {"kospi_etf": 40000.0}, _always) != "arc_invest_first_loss",
		"the first-loss scene played while holdings were up")
	var down := _gate()
	down["invest_branch_state"] = {"used": ["arc_ch1_invest_first_chart", "arc_ch1_theme_invest_deep"], "last_turn": 20}
	_expect(BEATS.take_scene(down, 30, "villa", holding, {"kospi_etf": 30000.0}, _always) == "arc_invest_first_loss",
		"the first-loss scene missed a real loss")


func _check_json_round_trip() -> void:
	var flags := _gate()
	BEATS.take_scene(flags, 17, "gosiwon", {}, {}, _always)
	var loaded: Dictionary = JSON.parse_string(JSON.stringify(flags))
	_expect(BEATS.take_scene(loaded, 20, "gosiwon", {}, {}, _always) == "arc_ch1_theme_invest_deep",
		"investment branch state lost its meaning after a JSON save/load")


func _check_market_choices() -> void:
	GameState.start_new_game()
	GameState.money = 1_000_000
	GameState.portfolio = {}
	GameState.apply_choice({"id": "invest_check"}, {"text": "buy", "market_buy": {"asset_id": "kospi_etf", "amount": 200000}})
	_expect(GameState.portfolio.has("kospi_etf") and int(GameState.money) == 800_000,
		"a market_buy choice did not buy (money=%s)" % str(GameState.money))
	GameState.apply_choice({"id": "invest_check"}, {"text": "sell", "market_sell": {"asset_id": "*", "ratio": 1.0}})
	_expect(GameState.portfolio.is_empty() and int(GameState.money) > 950_000,
		"a market_sell choice did not sell (money=%s)" % str(GameState.money))
	GameState.money = 1_000_000
	GameState.apply_choice({"id": "invest_check"}, {"text": "lev", "market_buy": {"asset_id": "kospi_3x", "cash_ratio": 0.3, "min": 15000, "max": 10000000}})
	_expect(int(GameState.money) == 700_000, "a cash_ratio buy spent %s instead of 30%%" % str(1_000_000 - int(GameState.money)))
	GameState.money = 100_000
	GameState.portfolio = {}
	GameState.apply_choice({"id": "invest_check"}, {"text": "coin", "market_buy": {"asset_id": "bitcoin", "amount": 500000}})
	_expect(int(GameState.money) == 0 and GameState.portfolio.has("bitcoin"),
		"a buy spent more than the cash on hand (money=%s)" % str(GameState.money))


func _years_three_four() -> Dictionary:
	var rows: Array = []
	for raw in BEATS.ledger().get("beats", []):
		if int((raw as Dictionary).get("min_week", 0)) >= 97:
			rows.append(raw)
	return {"gate_flag": "investment_lesson_1", "min_gap_weeks": 0, "beats": rows}


func _check_years_three_four() -> void:
	var data := _years_three_four()
	_expect((data["beats"] as Array).size() == 4, "years 3-4 investment beats are not the four authored scenes")
	var held := {"kospi_etf": {"quantity": 10.0, "avg_price": 10000.0}}
	var down := {"kospi_etf": 9000.0}
	_expect(BEATS.take_scene(_gate(), 100, "officetel", held, down, _always, data,
			{"market_cycle": "bear"}) == "market_crash_panic",
		"a real bear market with holdings down 10% did not bring the crash scene")
	_expect(BEATS.take_scene(_gate(), 100, "officetel", held, down, _always, data,
			{"market_cycle": "bull"}) == "",
		"the crash scene played outside a bear market")
	_expect(BEATS.take_scene(_gate(), 100, "officetel", held, {"kospi_etf": 9800.0}, _always, data,
			{"market_cycle": "bear"}) == "",
		"the crash scene played on a 2% dip")
	_expect(BEATS.take_scene(_gate(), 100, "officetel", held, {"kospi_etf": 11000.0}, _always, data,
			{"cast_stages": {"sangchul": "trusted"}}) == "sangchul_tip_warning",
		"a trusted Sangchul did not warn a holder in year three")
	_expect(BEATS.take_scene(_gate(), 110, "officetel", {}, {}, _always, data,
			{"route_lean": "unorthodox"}) == "unorthodox_gray_zone_tip"
			and BEATS.take_scene(_gate(), 110, "officetel", {}, {}, _always, data,
			{"route_lean": "orthodox"}) == "orthodox_institutional_access"
			and BEATS.take_scene(_gate(), 110, "officetel", {}, {}, _always, data, {}) == "",
		"the gray tip and the PB door do not follow which way the run leaned")
	var crash: Array = DataRegistry.find_event("market_crash_panic").get("choices", [])
	var gray: Array = DataRegistry.find_event("unorthodox_gray_zone_tip").get("choices", [])
	_expect(crash.size() == 3 and (crash[0] as Dictionary).has("market_buy")
			and (crash[1] as Dictionary).has("market_sell") and not (crash[2] as Dictionary).has("market_sell"),
		"the crash choices do not buy, sell and hold for real")
	_expect(not gray.is_empty() and str(((gray[0] as Dictionary).get("market_buy", {}) as Dictionary).get("asset_id", "")) == "ai_chip",
		"the gray tip does not buy the chip theme it names")
