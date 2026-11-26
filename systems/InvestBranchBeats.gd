extends RefCounted
## ORDER-834 B1 — the investment branch, years 1-2.
##
## C6 (2026-11-24) measured zero investment-category events in a real full-story
## run: the authored investment scenes lived in the old random pool and assumed a
## trading screen the new story never opens. A player who answers Sangchul's
## first lesson with "how do I start?" (`investment_lesson_1`) now meets those
## scenes on free weeks, in ledger order, each inside its own window:
##   first account -> late-night study -> first loss (only when the holdings are
##   actually under water) -> a goshiwon night trade -> 3x leverage -> the coin
##   craze. Their choices buy and sell real holdings (market_buy / market_sell)
##   and add investor tendency, so the run's net worth follows the market and a
##   steady investor can realize the investor identity by the end of year two.
## A run that never opened the branch never sees any of this.
## Deterministic: no RNG. State lives in one flag read and written only here:
##   flags["invest_branch_state"] = {"used": [event_id], "last_turn": int}

const LEDGER_PATH := "res://content/meta/invest_branch_ledger.json"
const STATE_FLAG := "invest_branch_state"
const MIN_GAP_WEEKS := 3

static var _ledger_cache: Dictionary = {}


static func ledger() -> Dictionary:
	if not _ledger_cache.is_empty():
		return _ledger_cache
	var text := FileAccess.get_file_as_string(LEDGER_PATH)
	var parsed: Variant = JSON.parse_string(text) if not text.is_empty() else null
	if parsed is Dictionary:
		_ledger_cache = parsed
	return _ledger_cache


static func _state(flags: Dictionary) -> Dictionary:
	var raw: Variant = flags.get(STATE_FLAG, {})
	var state: Dictionary = (raw as Dictionary).duplicate(true) if raw is Dictionary else {}
	if not state.get("used", null) is Array:
		state["used"] = []
	state["last_turn"] = int(state.get("last_turn", -100))
	return state


## Unrealized result of the current holdings at today's prices: >0 up, <0 down.
static func portfolio_pnl(portfolio: Dictionary, prices: Dictionary) -> float:
	var pnl := 0.0
	for asset_id in portfolio.keys():
		var holding: Variant = portfolio[asset_id]
		if not holding is Dictionary:
			continue
		var quantity := float((holding as Dictionary).get("quantity", 0.0))
		var avg := float((holding as Dictionary).get("avg_price", 0.0))
		pnl += quantity * (float(prices.get(asset_id, avg)) - avg)
	return pnl


static func _beat_ready(beat: Dictionary, turn: int, housing: String, portfolio: Dictionary,
		prices: Dictionary, used: Array) -> bool:
	if turn < int(beat.get("min_week", 0)) or turn > int(beat.get("max_week", 999)):
		return false
	if beat.has("housing") and housing != str(beat["housing"]):
		return false
	if beat.has("after") and not used.has(str(beat["after"])):
		return false
	var need: Variant = beat.get("portfolio", false)
	if need is bool and need and portfolio.is_empty():
		return false
	if need is String and str(need) == "loss" \
			and (portfolio.is_empty() or portfolio_pnl(portfolio, prices) >= 0.0):
		return false
	return true


## Returns the beat to play this free week ("" for none) and records it.
## `event_exists` filters ids the data registry cannot resolve.
static func take_scene(flags: Dictionary, turn: int, housing: String, portfolio: Dictionary,
		prices: Dictionary, event_exists: Callable, data: Dictionary = {}) -> String:
	var source: Dictionary = data if not data.is_empty() else ledger()
	if not bool(flags.get(str(source.get("gate_flag", "")), false)):
		return ""
	var state := _state(flags)
	if turn - int(state["last_turn"]) < MIN_GAP_WEEKS:
		return ""
	var used: Array = state["used"]
	for raw in source.get("beats", []):
		if not raw is Dictionary:
			continue
		var beat: Dictionary = raw
		var event_id := str(beat.get("event_id", ""))
		if event_id.is_empty() or used.has(event_id):
			continue
		if not _beat_ready(beat, turn, housing, portfolio, prices, used):
			continue
		if not bool(event_exists.call(event_id)):
			continue
		used.append(event_id)
		state["used"] = used
		state["last_turn"] = turn
		flags[STATE_FLAG] = state
		return event_id
	return ""
