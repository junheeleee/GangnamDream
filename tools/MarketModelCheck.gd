extends Node
## ORDER-839 T0 regression: the full-run market no longer sinks into a
## permanent bear. Measured 2026-11-27 on the real engine (60 months x 200
## seeds): fear/greed had no mean reversion and the news set leaned fearful,
## so the index sat near 13 by M60, 82% of months in years 3-5 were bear and
## the US large-cap ETF ended at 0.26x. In a full run fear/greed now drifts
## back toward 50 each month and the drawn news is centred on zero (sentiment
## and each category's price effect), so the long-run market follows the
## engine's own cycles and drift. The approved demo market is pinned: the same
## seed must give the same 24 months of prices as before the repair.
## `market_boom` in a full run raises fear/greed instead of netting -5. A
## monthly saver who reads the cycle ends at least 30% above one who only
## buys the index (cycle strength 1.5x in a full run).

const INV := preload("res://systems/InvestmentSystem.gd")
const FLOW := preload("res://systems/FullStoryFlow.gd")
const SEEDS := 200
const MONTHS := 60
const LEGACY_SEED := 7
const LEGACY_MONTHS := 24
## Demo-path fingerprint (fear/greed and four prices each month, seed 7),
## recorded on the engine before the repair.
const LEGACY_PIN := "251eceb9612a5f2d52746a833e9bfaa1"

var _failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	var legacy := _legacy_fingerprint()
	_expect(legacy == LEGACY_PIN, "demo market changed: %s" % legacy)
	var stats := _full_run_stats()
	_check_main_game_boom()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("MARKET_MODEL_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("MARKET_MODEL_CHECK_OK fg_m60=%d bear_late=%.2f kospi=%.2f sp500=%.2f nasdaq=%.2f coin=%.2f cycle_edge=%.2f legacy=1 boom=1" % [
		stats["fg"], stats["bear"], stats["kospi_etf"], stats["sp500"], stats["nasdaq"], stats["bitcoin"],
		stats["cycle_edge"]])
	get_tree().quit(0)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _fresh_market(full_run: bool) -> Node:
	GameState.start_new_game()
	GameState.flags.erase(FLOW.STATE_KEY)
	if full_run:
		GameState.flags[FLOW.STATE_KEY] = {"profile": FLOW.PROFILE_FULL}
	var inv: Node = INV.new()
	add_child(inv)
	inv.initialize()
	return inv


func _legacy_fingerprint() -> String:
	seed(LEGACY_SEED)
	var inv := _fresh_market(false)
	var parts: PackedStringArray = []
	for _m in range(LEGACY_MONTHS):
		inv.process_month(NewsManager.generate_monthly_news())
		parts.append("%d:%s" % [int(GameState.market_context.get("fear_greed", 50)),
			",".join(["kospi_etf", "sp500", "nasdaq", "bitcoin"].map(
				func(id): return str(int(round(float(GameState.market_prices.get(id, 0.0))))) ))])
	inv.queue_free()
	return "|".join(parts).md5_text()


func _median(values: Array) -> float:
	var sorted := values.duplicate()
	sorted.sort()
	return float(sorted[sorted.size() / 2])


func _full_run_stats() -> Dictionary:
	var ratios := {"kospi_etf": [], "sp500": [], "nasdaq": [], "bitcoin": []}
	var fg_end: Array = []
	var bear_late := 0
	var index_end: Array = []
	var cycle_end: Array = []
	for s in range(SEEDS):
		seed(2000 + s)
		var inv := _fresh_market(true)
		var start := {}
		for id in ratios:
			start[id] = float(GameState.market_prices.get(id, 1.0))
		var index_units := 0.0
		var cycle_cash := 0.0
		var cycle_units := 0.0
		var cycle_asset := ""
		for m in range(MONTHS):
			# A monthly saver: the index keeps buying the US large-cap ETF; the
			# cycle reader holds tech in a bull, cash in a bear, the index otherwise.
			var sp: float = float(GameState.market_prices.get("sp500", 1.0))
			index_units += 1_000_000.0 / sp
			cycle_cash += 1_000_000.0
			var cycle := str(GameState.market_context.get("cycle", "neutral"))
			var want := "nasdaq" if cycle == "bull" else ("" if cycle == "bear" else "sp500")
			if want != cycle_asset:
				if cycle_asset != "":
					cycle_cash += cycle_units * float(GameState.market_prices.get(cycle_asset, 0.0)) * 0.995
					cycle_units = 0.0
				cycle_asset = want
			if cycle_asset != "":
				cycle_units += cycle_cash * 0.997 / float(GameState.market_prices.get(cycle_asset, 1.0))
				cycle_cash = 0.0
			inv.process_month(NewsManager.generate_monthly_news())
			if m >= 24 and str(GameState.market_context.get("cycle", "")) == "bear":
				bear_late += 1
		index_end.append(index_units * float(GameState.market_prices.get("sp500", 0.0)))
		cycle_end.append(cycle_cash + (cycle_units * float(GameState.market_prices.get(cycle_asset, 0.0))
			if cycle_asset != "" else 0.0))
		fg_end.append(int(GameState.market_context.get("fear_greed", 50)))
		for id in ratios:
			ratios[id].append(float(GameState.market_prices.get(id, 0.0)) / maxf(float(start[id]), 1.0))
		inv.queue_free()
	GameState.flags.erase(FLOW.STATE_KEY)
	var stats := {"fg": int(_median(fg_end)),
		"bear": float(bear_late) / float(SEEDS * (MONTHS - 24))}
	for id in ratios:
		stats[id] = _median(ratios[id])
	_expect(stats["fg"] >= 40 and stats["fg"] <= 60, "fear/greed median at M60 %d outside 40-60" % stats["fg"])
	_expect(stats["bear"] < 0.5, "bear share in years 3-5 %.2f not below 0.5" % stats["bear"])
	_expect(stats["kospi_etf"] >= 1.0, "KOSPI200 ETF median %.2f below 1.0 after five years" % stats["kospi_etf"])
	_expect(stats["sp500"] >= 0.95, "US large-cap ETF median %.2f below 0.95 after five years" % stats["sp500"])
	# Skill should pay: reading the cycle beats saving into the index (839 T4).
	stats["cycle_edge"] = _median(cycle_end) / maxf(_median(index_end), 1.0)
	_expect(stats["cycle_edge"] >= 1.30, "cycle reading beats the index by only %.2fx" % stats["cycle_edge"])
	return stats


func _check_main_game_boom() -> void:
	var source := FileAccess.get_file_as_string("res://scenes/MainGame.gd")
	var at := source.find("\"market_boom\":")
	_expect(at >= 0, "MainGame has no market_boom branch")
	if at < 0:
		return
	var body := source.substr(at, 700)
	var gate := body.find("FULL_STORY_FLOW.is_full_run()")
	var shock := body.find("apply_market_shock()")
	_expect(gate >= 0 and shock > gate, "market_boom does not skip the shock in a full run")
