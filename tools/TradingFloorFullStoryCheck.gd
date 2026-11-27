extends Node
## ORDER-839 T1 regression: the trading board is a full-story activity.
## The portfolio habit scenes' first choice opens it (FullStoryFlow activity
## `trading_floor`), the habit calls again after four weeks at the earliest,
## a session has three orders without spending action points, buys are cash
## ratios and sells holding ratios, only assets the story has opened are
## listed (a holding always stays), the hidden low-mental fee is capped, the
## chart keeps sixty months, and the session summary is what MainGame
## receipts. A run that has used the board keeps it while all in cash, and
## deleting the app closes it. Outside a full run the board still spends
## action points.

const FLOW := preload("res://systems/FullStoryFlow.gd")
const HABIT := preload("res://systems/BranchHabit.gd")
const INV := preload("res://systems/InvestmentSystem.gd")
const BOARD := preload("res://scenes/TradingFloor.gd")

var _failures: Array[String] = []
var _closed := 0


func _ready() -> void:
	await get_tree().process_frame
	_check_ledger()
	_check_activity_source()
	_check_unlocks()
	await _check_full_run_session()
	await _check_legacy_session()
	_check_main_game_routes()
	GameState.flags.erase(FLOW.STATE_KEY)
	if not _failures.is_empty():
		for failure in _failures:
			push_error("TRADING_FLOOR_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("TRADING_FLOOR_CHECK_OK tiers=%d ledger=1 source=1 unlock=6 session=1 legacy=1 routes=1" % [
		(BOARD.ledger().get("tiers", []) as Array).size()])
	get_tree().quit(0)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _check_ledger() -> void:
	var ledger := BOARD.ledger()
	_expect(int(ledger.get("orders_per_session", 0)) == 3, "orders_per_session is not 3")
	var asset_ids := {}
	for asset in DataRegistry.assets:
		asset_ids[str(asset.get("id", ""))] = true
	for raw in ledger.get("tiers", []):
		var tier: Dictionary = raw
		for aid in tier.get("assets", []):
			_expect(asset_ids.has(str(aid)), "tier %s lists unknown asset %s" % [tier.get("id"), aid])
		for event_id in tier.get("requires_any_event", []):
			_expect(not DataRegistry.find_event(str(event_id)).is_empty(),
				"tier %s waits for missing scene %s" % [tier.get("id"), event_id])
		_expect(not (tier.get("requires_any", []) as Array).is_empty()
			or not (tier.get("requires_any_event", []) as Array).is_empty(),
			"tier %s opens with nothing" % tier.get("id"))


func _check_activity_source() -> void:
	_expect(FLOW.ACTIVITY_FLAGS.get("trading_floor", "") == "open_trading_after_story",
		"FullStoryFlow has no trading_floor activity flag")
	var sources: Array = FLOW.ACTIVITY_SOURCES.get("trading_floor", [])
	_expect(sources.size() == 2, "trading_floor sources are not the two portfolio habit scenes")
	for raw in sources:
		var pair: Array = raw
		var event: Dictionary = DataRegistry.find_event(str(pair[0]))
		var choices: Array = event.get("choices", [])
		_expect(choices.size() == 2, "%s does not have open/leave choices" % pair[0])
		if choices.size() > int(pair[1]):
			var flags: Array = (choices[int(pair[1])] as Dictionary).get("flags", [])
			_expect(flags.has("open_trading_after_story"), "%s choice %d does not open the board" % pair)
			_expect(not (choices[int(pair[1])] as Dictionary).has("market_buy"),
				"%s still buys from the scene" % pair[0])
	var habit_ledger := HABIT.ledger()
	for raw in habit_ledger.get("activities", []):
		var activity: Dictionary = raw
		if str(activity.get("id", "")) != "portfolio":
			continue
		_expect(HABIT._gap_after_go(habit_ledger, activity) == 4, "portfolio does not wait four weeks")
		for ev in activity.get("events", []):
			var go: Array = (ev as Dictionary).get("go", [])
			_expect(go.size() == 1 and int(go[0]) == 0, "portfolio go index is not the open choice")
	_expect(HABIT._gap_after_go(habit_ledger, {"id": "racetrack"}) == 1,
		"the shared return gap changed for other activities")
	var portfolio: Dictionary = {}
	for raw in habit_ledger.get("activities", []):
		if str((raw as Dictionary).get("id", "")) == "portfolio":
			portfolio = raw
	var lesson := {"investment_lesson_1": true}
	_expect(not HABIT._eligible(portfolio, lesson, false), "the board is offered before any holding or visit")
	_expect(HABIT._eligible(portfolio, lesson, true), "a holding does not open the board")
	_expect(HABIT._eligible(portfolio, {"investment_lesson_1": true, "trading_board_opened": true}, false),
		"a trader all in cash loses the board")
	_expect(not HABIT._eligible(portfolio, {"investment_lesson_1": true,
		"trading_board_opened": true, "trading_app_deleted": true}, true),
		"deleting the app does not close the board")
	var regular: Dictionary = DataRegistry.find_event("habit_portfolio_regular")
	var leave: Array = ((regular.get("choices", []) as Array)[1] as Dictionary).get("flags", [])
	_expect(leave.has("trading_app_deleted"), "the delete-the-app choice does not record it")


func _check_unlocks() -> void:
	_expect(BOARD.unlocked_asset_ids({}, {}).is_empty(), "assets listed before the first lesson")
	var first := BOARD.unlocked_asset_ids({"investment_lesson_1": true}, {})
	_expect(first == ["kospi_etf", "sp500", "samsung", "reits"], "first lesson opens %s" % str(first))
	var coins := BOARD.unlocked_asset_ids({"investment_lesson_1": true}, {},
		[{"event_id": "inv_crypto_mania", "turn": 60, "choice_index": 1}])
	_expect(coins.has("bitcoin") and coins.has("meme_coin"), "the crypto scene does not open coins")
	var property := BOARD.unlocked_asset_ids({"pb_access": true}, {})
	_expect(property == ["officetel", "gangnam_share"], "private banking opens %s" % str(property))
	var startup := BOARD.unlocked_asset_ids({}, {},
		[{"event_id": "arc_jaehyuk_03_pitch", "turn": 104, "choice_index": 0}])
	_expect(startup.has("seed_startup") and startup.has("ai_startup"), "a startup pitch does not open startup stakes")
	var held := BOARD.unlocked_asset_ids({}, {"nasdaq_3x": {"quantity": 1.0, "avg_price": 90000.0}})
	_expect(held == ["nasdaq_3x"], "a holding is not kept on the board")


func _fresh(full_run: bool) -> Array:
	GameState.start_new_game()
	GameState.flags.erase(FLOW.STATE_KEY)
	if full_run:
		GameState.flags[FLOW.STATE_KEY] = {"profile": FLOW.PROFILE_FULL}
	GameState.flags["investment_lesson_1"] = true
	var inv: Node = INV.new()
	add_child(inv)
	inv.initialize()
	var board: Control = BOARD.new()
	board.setup(inv)
	add_child(board)
	board.closed.connect(func(): _closed += 1)
	return [inv, board]


func _check_full_run_session() -> void:
	var pair := _fresh(true)
	var inv: Node = pair[0]
	var board: Control = pair[1]
	GameState.add_settled_cash(10_000_000.0 - float(GameState.money))
	GameState.mental = 80
	var ap_before := int(GameState.action_points)
	board.open()
	await get_tree().process_frame
	_expect(board.visible and int(board.call("orders_left")) == 3, "a session does not open with three orders")
	_expect(bool(GameState.flags.get("trading_board_opened", false)), "opening the board is not recorded")
	_expect(not (board.call("_asset_ids") as Array).has("bitcoin"), "a locked asset is listed")
	board.call("_select", "kospi_etf")
	var cash := float(GameState.money)
	board.call("_do_buy", int(floor(cash * 0.25)))
	var held: Dictionary = GameState.portfolio.get("kospi_etf", {})
	var value := float(held.get("quantity", 0.0)) * float(GameState.market_prices.get("kospi_etf", 0.0))
	_expect(absf(float(GameState.money) - cash * 0.75) <= 1.0, "a 25% buy did not take a quarter of the cash")
	_expect(value > cash * 0.25 * 0.99 and value < cash * 0.25, "the buy fee is not about 0.3%")
	_expect(int(GameState.action_points) == ap_before, "a full-run order spent action points")
	board.call("_do_sell", 0.5)
	board.call("_do_buy", int(floor(float(GameState.money) * 0.1)))
	_expect(int(board.call("orders_left")) == 0, "three orders did not use the session")
	var after_three := float(GameState.money)
	board.call("_do_buy", int(floor(float(GameState.money) * 0.1)))
	_expect(float(GameState.money) == after_three, "a fourth order went through")
	var summary: Dictionary = board.call("get_session_summary")
	_expect(int(summary.get("rounds", -1)) == 3, "the summary does not count three orders")
	_expect(float(summary.get("net", 0.5)) == floor(float(summary.get("net", 0.5))),
		"the session net is not whole won")
	# A tired mind pays at most the capped hidden fee.
	GameState.mental = 0
	var fee: Dictionary = inv.buy_asset("sp500", 1_000_000.0)
	_expect(bool(fee.get("success", false)) and float(fee.get("fee", 1e9)) <= 1_000_000.0 * 0.0231,
		"the low-mental fee is not capped in a full run")
	for _m in range(30):
		inv.process_month(NewsManager.generate_monthly_news())
	_expect((GameState.price_history.get("kospi_etf", []) as Array).size() == 30,
		"the full-run chart does not keep its months")
	var cancel := InputEventAction.new()
	cancel.action = "ui_cancel"
	cancel.pressed = true
	board.call("_unhandled_input", cancel)
	_expect(not board.visible and _closed == 1, "Escape does not close the board once")
	board.queue_free()
	inv.queue_free()
	await get_tree().process_frame


func _check_legacy_session() -> void:
	var pair := _fresh(false)
	var inv: Node = pair[0]
	var board: Control = pair[1]
	GameState.add_settled_cash(10_000_000.0 - float(GameState.money))
	GameState.action_points = 2
	board.open()
	await get_tree().process_frame
	board.call("_select", "kospi_etf")
	board.call("_do_buy", 1_000_000)
	_expect(int(GameState.action_points) == 1, "outside a full run a trade no longer spends action points")
	for _m in range(20):
		inv.process_month(NewsManager.generate_monthly_news())
	_expect((GameState.price_history.get("kospi_etf", []) as Array).size() == 12,
		"outside a full run the price history is not twelve months")
	board.call("_on_close")
	board.queue_free()
	inv.queue_free()
	await get_tree().process_frame


func _check_main_game_routes() -> void:
	var source := FileAccess.get_file_as_string("res://scenes/MainGame.gd")
	_expect(source.contains("func _open_trading_floor():"), "MainGame cannot open the board")
	_expect(source.contains("func _on_trading_floor_closed():"), "MainGame cannot close the board")
	var routed := source.find("\"trading_floor\":\n\t\t\t\t_open_trading_floor()")
	_expect(routed >= 0, "an entry save does not route back into the board")
	_expect(source.contains("trading_floor.closed.connect(_on_trading_floor_closed)"),
		"the board's close signal is not connected")
