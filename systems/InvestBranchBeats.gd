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

const ENGINE := preload("res://systems/BranchBeats.gd")
const LEDGER_PATH := "res://content/meta/invest_branch_ledger.json"
const STATE_FLAG := "invest_branch_state"

static var _ledger_cache: Dictionary = {}


static func ledger() -> Dictionary:
	if _ledger_cache.is_empty():
		_ledger_cache = ENGINE.load_ledger(LEDGER_PATH)
	return _ledger_cache


static func portfolio_pnl(portfolio: Dictionary, prices: Dictionary) -> float:
	return ENGINE.portfolio_pnl(portfolio, prices)


## Returns the beat to play this free week ("" for none) and records it.
## `event_exists` filters ids the data registry cannot resolve or already played.
static func take_scene(flags: Dictionary, turn: int, housing: String, portfolio: Dictionary,
		prices: Dictionary, event_exists: Callable, data: Dictionary = {}) -> String:
	var source: Dictionary = data if not data.is_empty() else ledger()
	return ENGINE.take(source, STATE_FLAG, flags, {
		"turn": turn, "housing": housing, "portfolio": portfolio, "prices": prices,
	}, event_exists)
