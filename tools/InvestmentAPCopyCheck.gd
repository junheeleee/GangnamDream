extends Node
## Prepared component probes with real leverage transactions; not rendered UI or natural input.
## Always enter through StoryNameplateBootstrap, before any game autoload starts.

class TradeProbe extends Node:
	var calls: Array = []

	func buy_asset(asset_id, amount) -> Dictionary:
		calls.append(["buy", asset_id, amount])
		return {"success": false, "message": "probe:mutation_reached"}

	func sell_asset(asset_id, ratio) -> Dictionary:
		calls.append(["sell", asset_id, ratio])
		return {"success": false, "message": "probe:mutation_reached"}

	func buy_asset_leveraged(asset_id, amount) -> Dictionary:
		calls.append(["leverage", asset_id, amount])
		return {"success": false, "message": "probe:mutation_reached"}


class MainProbe extends "res://scenes/MainGame.gd":
	var observed_toasts: Array = []
	var closed_count := 0
	var refreshed_count := 0
	var observed_commits: Array = []

	func _show_toast(message: String, color: Color = Color("#8892a4")):
		observed_toasts.append([message, color.to_html()])

	func _close_modal(_play_sound: bool = true, _resume_flow: bool = true):
		closed_count += 1

	# Only presentation that requires an instantiated MainGame scene is replaced.
	# Trade execution, localized copy, money formatting, and weekly finalization are real.
	func _refresh_all():
		refreshed_count += 1

	func _show_ap_action_commit(title: String, icon_id: String, accent: String,
			free_action: bool = false, _art_thumb: Texture2D = null,
			commitment: Dictionary = {}) -> void:
		observed_commits.append([title, icon_id, accent, free_action,
			commitment.duplicate(true)])

	func _action_thumb_texture(_fn: String, _icon_id: String = "") -> Texture2D:
		return null


const INVESTMENT_SYSTEM := preload("res://systems/InvestmentSystem.gd")
const EXPECTED := {
	"ko": "행동력이 없습니다",
	"en": "No Action Points",
	"ja": "行動力がありません",
	"zh-CN": "行动力已用尽",
	"zh-TW": "行動力已用盡",
}
const TRADES := [
	["buy", "_on_buy_asset", 200000.0],
	["sell", "_on_sell_asset", 0.5],
	["leverage", "_on_leverage_buy", 200000.0],
]
var failures: Array[String] = []
var rows: Array = []


func _ready() -> void:
	call_deferred("_run")


func _expect(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)


func _trade_state(game: MainProbe) -> Dictionary:
	return {
		"ap": GameState.action_points,
		"money": GameState.money,
		"portfolio": GameState.portfolio.duplicate(true),
		"pending": GameState.pending_weekly_commitment.duplicate(true),
		"action_log": game.turn_action_log.duplicate(true),
		"axes": GameState.action_axis_this_week.duplicate(true),
		"records": GameState.action_records_this_week.duplicate(true),
	}


func _probe(locale: String, trade: Array, available: bool) -> void:
	var game := MainProbe.new()
	var mutation := TradeProbe.new()
	game.investment_system = mutation
	var before := _trade_state(game)
	game.call(str(trade[1]), "probe_asset", trade[2])
	var expected_toast: String = "probe:mutation_reached" if available else str(EXPECTED[locale])
	var expected_calls: Array = [[trade[0], "probe_asset", trade[2]]] if available else []
	var actual := {
		"toasts": game.observed_toasts.duplicate(true),
		"closed": game.closed_count,
		"mutation_calls": mutation.calls.duplicate(true),
		"unchanged": before == _trade_state(game),
	}
	var expected := {
		"toasts": [[expected_toast, "ff4444ff"]],
		"closed": 0 if available else 1,
		"mutation_calls": expected_calls,
		"unchanged": true,
	}
	var passed: bool = actual == expected
	var phase: String = "restored_probe" if available else "ap_zero"
	_expect(passed, "%s/%s/%s" % [locale, str(trade[0]), phase])
	var row := {"locale": locale, "trade": trade[0], "phase": phase,
		"passed": passed, "expected": expected, "actual": actual}
	rows.append(row)
	print("INVESTMENT_AP_COPY_CASE=" + JSON.stringify(row))
	game.free()
	mutation.free()


func _prepare_leverage_case(ap: int = 2, cash: float = 1000000.0) -> Dictionary:
	GameState.start_new_game("김민준", "지방_상경", "none", "백수", "자유런", "현실")
	GameState.year = 2026
	GameState.month = 3
	GameState.week_of_month = 1
	GameState.turn = 9
	GameState.action_points = ap
	GameState.money = cash
	GameState.action_log = []
	var asset: Dictionary = DataRegistry.assets[0]
	var asset_id := str(asset.get("id", ""))
	var price := float(asset.get("initial_price", asset.get("base_price", 10000.0)))
	GameState.market_prices = {asset_id: price}
	return {"id": asset_id, "name": str(asset.get("name", asset_id)), "price": price}


func _probe_leverage_success(locale: String, amount: float, weekly_owner: bool) -> void:
	var asset := _prepare_leverage_case()
	var game := MainProbe.new()
	var investment: Node = INVESTMENT_SYSTEM.new()
	game.investment_system = investment
	var trade_events: Array = []
	var portfolio_events: Array = []
	var finalized_events: Array = []
	investment.trade_executed.connect(func(id: String, action: String,
			quantity: float, price: float) -> void:
		trade_events.append({"id": id, "action": action, "quantity": quantity,
			"price": price, "ap": GameState.action_points,
			"pending": GameState.pending_weekly_commitment.duplicate(true),
			"weekly_count": GameState.weekly_commitments.size()}))
	investment.portfolio_updated.connect(func() -> void:
		portfolio_events.append(true))
	var finalized_probe := func(record: Dictionary) -> void:
		finalized_events.append(record.duplicate(true))
	GameState.weekly_commitment_finalized.connect(finalized_probe)
	if weekly_owner:
		_expect(GameState.arm_weekly_commitment({
			"turn": GameState.turn, "choice_id": "invest",
			"pressure_id": "qa_investment", "pressure_family": "money",
			"forgone_ids": ["study", "rest"],
		}), locale + "/leverage_weekly_owner_arm")
	var money_before: float = GameState.money
	var skill_before: int = GameState.investment_skill
	var committed := GameState.settle_cash(amount)
	var fee := committed * 0.015
	var exposure := committed * 2.0
	var quantity := (exposure - fee) / float(asset["price"])
	var expected_toast := LocaleManager.ui(
		"레버리지 매수 — %s ×2배 포지션 확보",
		"Leverage buy — secured %s ×2 position") % GameState.format_money(committed)
	var double_exposure_toast := LocaleManager.ui(
		"레버리지 매수 — %s ×2배 포지션 확보",
		"Leverage buy — secured %s ×2 position") % GameState.format_money(exposure)
	var expected_action_log := LocaleManager.ui(
		"✓ 레버리지 → %s ×2배  %s", "✓ Leverage → %s ×2  %s") \
		% [asset["name"], GameState.format_money(committed)]
	var expected_trade_log := LocaleManager.ui(
		"⚡ 레버리지 매수: {asset}에 {cash}을 투입해 두 배 규모의 포지션을 열었다.",
		"⚡ Leveraged buy: Committed {cash} to {asset} and opened a position twice that size."
	).format({"asset": asset["name"], "cash": GameState.format_money(committed)})
	game.call("_on_leverage_buy", str(asset["id"]), amount)
	GameState.weekly_commitment_finalized.disconnect(finalized_probe)
	var holding: Dictionary = GameState.portfolio.get(asset["id"], {})
	var record: Dictionary = GameState.get_weekly_commitment_for_turn(GameState.turn)
	var details: Dictionary = record.get("details", {})
	var receipt_ok := record.is_empty() and finalized_events.is_empty()
	if weekly_owner:
		var outcome: Dictionary = record.get("outcome", {})
		receipt_ok = str(record.get("choice_id", "")) == "invest" \
			and str(record.get("actual_action_id", "")) == "invest_leverage" \
			and record.get("forgone_ids", []) == ["study", "rest"] \
			and str(details.get("asset_id", "")) == str(asset["id"]) \
			and str(details.get("trade", "")) == "leverage_buy" \
			and float(details.get("amount", -1.0)) == committed \
			and float(details.get("exposure", -1.0)) == exposure \
			and float(details.get("fee", -1.0)) == fee \
			and float(details.get("price", -1.0)) == float(asset["price"]) \
			and is_equal_approx(float(details.get("quantity", -1.0)), quantity) \
			and float(outcome.get("money", 0.0)) == -committed \
			and int(outcome.get("investment_skill", 0)) == 1 \
			and finalized_events == [record]
	var trade_signal_ok := trade_events.size() == 1 and portfolio_events.size() == 1
	if not trade_events.is_empty():
		var trade_event: Dictionary = trade_events[0]
		trade_signal_ok = trade_signal_ok \
			and str(trade_event["id"]) == str(asset["id"]) \
			and str(trade_event["action"]) == "leverage_buy" \
			and is_equal_approx(float(trade_event["quantity"]), quantity) \
			and float(trade_event["price"]) == float(asset["price"])
		if weekly_owner:
			trade_signal_ok = trade_signal_ok and int(trade_event["ap"]) == 0 \
				and (trade_event["pending"] as Dictionary).is_empty() \
				and int(trade_event["weekly_count"]) == 1
	var actual := {
		"toasts": game.observed_toasts.duplicate(true),
		"closed": game.closed_count, "refreshed": game.refreshed_count,
		"ap": GameState.action_points, "money": GameState.money,
		"holding": holding.duplicate(true), "cash_debited": money_before - GameState.money,
		"principal": float(holding.get("leveraged_amount", 0.0)),
		"gross_exposure": float(holding.get("leveraged_amount", 0.0)) * 2.0,
		"fee_from_position_value": float(holding.get("leveraged_amount", 0.0)) * 2.0 \
			- float(holding.get("quantity", 0.0)) * float(asset["price"]),
		"position_value": float(holding.get("quantity", 0.0)) * float(asset["price"]),
		"pending": GameState.pending_weekly_commitment.duplicate(true),
		"weekly_count": GameState.weekly_commitments.size(),
		"receipt": record.duplicate(true), "receipt_ok": receipt_ok,
		"trade_signal_ok": trade_signal_ok,
		"action_log": game.turn_action_log.duplicate(true),
		"trade_logs": GameState.action_log.duplicate(true),
		"commit_count": game.observed_commits.size(),
	}
	var expected := {
		"toast": expected_toast, "rejected_double_exposure_toast": double_exposure_toast,
		"ap": 0 if weekly_owner else 1, "money": money_before - committed,
		"quantity": quantity, "price": asset["price"], "fee": fee,
		"principal": committed, "exposure": exposure,
		"weekly_count": 1 if weekly_owner else 0,
		"action_log": expected_action_log, "trade_log": expected_trade_log,
		"commit_count": 0 if weekly_owner else 1,
	}
	var passed: bool = game.observed_toasts == [[expected_toast, "ef4444ff"]] \
		and expected_toast != double_exposure_toast \
		and GameState.money == money_before - committed \
		and GameState.action_points == (0 if weekly_owner else 1) \
		and GameState.portfolio.size() == 1 \
		and is_equal_approx(float(holding.get("quantity", 0.0)), quantity) \
		and float(holding.get("avg_price", 0.0)) == float(asset["price"]) \
		and float(holding.get("leveraged_amount", 0.0)) == committed \
		and is_equal_approx(float(actual["position_value"]), exposure - fee) \
		and GameState.investment_skill == skill_before + 1 \
		and GameState.action_axis_this_week == {"money": 1, "human": 0} \
		and GameState.action_records_this_week.size() == 1 \
		and str(GameState.action_records_this_week[0].get("id", "")) == "invest_leverage" \
		and int(GameState.tendency.get("invest", 0)) == 4 \
		and GameState.pending_weekly_commitment.is_empty() \
		and GameState.weekly_commitments.size() == (1 if weekly_owner else 0) \
		and receipt_ok and trade_signal_ok \
		and game.turn_action_log == [expected_action_log] \
		and GameState.action_log.size() == 1 \
		and str(GameState.action_log[0].get("message", "")) == expected_trade_log \
		and str(GameState.action_log[0].get("type", "")) == "trade" \
		and game.closed_count == 1 and game.refreshed_count == 1 \
		and game.observed_commits.size() == (0 if weekly_owner else 1)
	var phase := "leverage_weekly_owner" if weekly_owner else "leverage_success"
	_expect(passed, "%s/%s/%s" % [locale, phase, str(amount)])
	var row := {"locale": locale, "trade": "leverage", "phase": phase,
		"amount": amount, "passed": passed, "expected": expected, "actual": actual}
	rows.append(row)
	print("INVESTMENT_AP_COPY_CASE=" + JSON.stringify(row))
	game.free()
	investment.free()


func _probe_leverage_failure(locale: String, phase: String) -> void:
	var asset := _prepare_leverage_case(0 if phase == "leverage_ap_zero" else 2,
		100000.0 if phase == "leverage_insufficient_cash" else 1000000.0)
	var game := MainProbe.new()
	var investment: Node = INVESTMENT_SYSTEM.new()
	game.investment_system = investment
	var trade_events: Array = []
	investment.trade_executed.connect(func(_id: String, _action: String,
			_quantity: float, _price: float) -> void:
		trade_events.append(true))
	var asset_id := "qa_missing_asset" if phase == "leverage_missing_asset" else str(asset["id"])
	var expected_toast := str(EXPECTED[locale])
	if phase == "leverage_insufficient_cash":
		expected_toast = LocaleManager.ui("잔액 부족", "Insufficient balance")
	elif phase == "leverage_missing_asset":
		expected_toast = LocaleManager.ui("존재하지 않는 자산", "Asset does not exist")
	var before: Dictionary = GameState.serialize().duplicate(true)
	var before_log := GameState.action_log.duplicate(true)
	game.call("_on_leverage_buy", asset_id, 200000.0)
	var actual := {
		"toasts": game.observed_toasts.duplicate(true),
		"closed": game.closed_count, "refreshed": game.refreshed_count,
		"commit_count": game.observed_commits.size(),
		"trade_events": trade_events.duplicate(true),
		"unchanged": before == GameState.serialize() and before_log == GameState.action_log,
		"action_log": game.turn_action_log.duplicate(true),
	}
	var expected := {
		"toasts": [[expected_toast, "ff4444ff"]],
		"closed": 1 if phase == "leverage_ap_zero" else 0, "refreshed": 0,
		"commit_count": 0, "trade_events": [], "unchanged": true, "action_log": [],
	}
	var passed: bool = actual == expected
	_expect(passed, locale + "/" + phase)
	var row := {"locale": locale, "trade": "leverage", "phase": phase,
		"passed": passed, "expected": expected, "actual": actual}
	rows.append(row)
	print("INVESTMENT_AP_COPY_CASE=" + JSON.stringify(row))
	game.free()
	investment.free()


func _run() -> void:
	var qa_namespace467 := OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	if not qa_namespace467.begins_with("GangnamDream_StoryNameplateQA_") \
			or OS.get_user_data_dir().get_file() != qa_namespace467:
		push_error("INVESTMENT_AP_COPY_CHECK_FAIL pre-autoload isolation missing")
		get_tree().quit(1)
		return
	print("STORY_NAMEPLATE_QA_USER_DIR=" + OS.get_user_data_dir())
	var old_language: String = LocaleManager.language
	var old_sfx_enabled: bool = AudioManager.sfx_enabled
	# This transaction/copy component does not observe SFX playback. Keep audio
	# outside its scope; the separate product audio checks remain unchanged.
	AudioManager.sfx_enabled = false
	for locale: String in EXPECTED:
		LocaleManager.set_language(locale)
		GameState.pending_weekly_commitment = {}
		GameState.is_game_over = false
		GameState.year = 2026
		GameState.month = 3
		GameState.week_of_month = 1
		GameState.turn = 9
		GameState.action_points = 0
		GameState.max_action_points = 2
		GameState.action_axis_this_week = {"money": 0, "human": 0}
		GameState.action_records_this_week = []
		GameState.money = 1000000.0
		GameState.portfolio = {"probe_asset": {"amount": 10.0, "average_cost": 100.0}}
		for trade: Array in TRADES:
			_probe(locale, trade, false)
		var month_ended: bool = GameState.advance_calendar()
		GameState.restore_ap()
		var restored: bool = not month_ended and GameState.year == 2026 \
			and GameState.month == 3 and GameState.week_of_month == 2 \
			and GameState.turn == 10 and GameState.action_points == 2
		_expect(restored, locale + "/same_month_weekly_restore")
		print("INVESTMENT_AP_COPY_RESTORE=" + JSON.stringify({"locale": locale,
			"passed": restored, "month": GameState.month, "week": GameState.week_of_month,
			"turn": GameState.turn, "ap": GameState.action_points, "month_ended": month_ended}))
		for trade: Array in TRADES:
			_probe(locale, trade, true)
	for locale: String in EXPECTED:
		LocaleManager.set_language(locale)
		for amount: float in [200000.0, 500000.0]:
			_probe_leverage_success(locale, amount, false)
		for phase: String in ["leverage_insufficient_cash", "leverage_missing_asset",
				"leverage_ap_zero"]:
			_probe_leverage_failure(locale, phase)
		_probe_leverage_success(locale, 500000.0, true)
	_expect(rows.size() == 60, "case_count_not_60")
	LocaleManager.set_language(old_language)
	AudioManager.sfx_enabled = old_sfx_enabled
	await get_tree().process_frame
	if not failures.is_empty():
		for failure: String in failures:
			push_error("INVESTMENT_AP_COPY_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("INVESTMENT_AP_COPY_CHECK_OK cases=60 locales=5 weekly_restores=5 "
		+ "real_leverage_success=10 real_leverage_failure=15 weekly_owner_success=5 "
		+ "prepared_component_only=true")
	get_tree().quit(0)
