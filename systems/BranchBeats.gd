extends RefCounted
## ORDER-834 — shared engine for the investment and gambling branches.
##
## A branch ledger lists authored beats in preference order. On a free full-story
## week the first beat that is unused, inside its window and whose requirements
## hold is returned and recorded; a branch never plays two beats closer than its
## min_gap_weeks. Deterministic (no RNG). Each branch keeps its own state flag:
##   flags[state_flag] = {"used": [event_id], "last_turn": int}
##
## Ledger keys: "gate_flag" (optional, every beat needs it), "min_gap_weeks",
## "beats": [{event_id, min_week, max_week, requires: [flag], forbids: [flag],
##            housing, has_job, after, portfolio: true | "loss"}].
## `ctx`: {turn, housing, has_job, portfolio, prices}.


static func load_ledger(path: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text) if not text.is_empty() else null
	return parsed if parsed is Dictionary else {}


static func _state(flags: Dictionary, state_flag: String) -> Dictionary:
	var raw: Variant = flags.get(state_flag, {})
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


static func _beat_ready(beat: Dictionary, flags: Dictionary, ctx: Dictionary, used: Array) -> bool:
	var turn := int(ctx.get("turn", 0))
	if turn < int(beat.get("min_week", 0)) or turn > int(beat.get("max_week", 999)):
		return false
	for flag_id in beat.get("requires", []):
		if not bool(flags.get(str(flag_id), false)):
			return false
	for flag_id in beat.get("forbids", []):
		if bool(flags.get(str(flag_id), false)):
			return false
	if beat.has("housing") and str(ctx.get("housing", "")) != str(beat["housing"]):
		return false
	if bool(beat.get("has_job", false)) and not bool(ctx.get("has_job", false)):
		return false
	if beat.has("after") and not used.has(str(beat["after"])):
		return false
	var portfolio: Dictionary = ctx.get("portfolio", {})
	var need: Variant = beat.get("portfolio", false)
	if need is bool and need and portfolio.is_empty():
		return false
	if need is String and str(need) == "loss" \
			and (portfolio.is_empty() or portfolio_pnl(portfolio, ctx.get("prices", {})) >= 0.0):
		return false
	return true


static func take(ledger: Dictionary, state_flag: String, flags: Dictionary, ctx: Dictionary,
		event_exists: Callable) -> String:
	var gate := str(ledger.get("gate_flag", ""))
	if not gate.is_empty() and not bool(flags.get(gate, false)):
		return ""
	var state := _state(flags, state_flag)
	var turn := int(ctx.get("turn", 0))
	if turn - int(state["last_turn"]) < int(ledger.get("min_gap_weeks", 3)):
		return ""
	var used: Array = state["used"]
	for raw in ledger.get("beats", []):
		if not raw is Dictionary:
			continue
		var beat: Dictionary = raw
		var event_id := str(beat.get("event_id", ""))
		if event_id.is_empty() or used.has(event_id):
			continue
		if not _beat_ready(beat, flags, ctx, used):
			continue
		if not bool(event_exists.call(event_id)):
			continue
		used.append(event_id)
		state["used"] = used
		state["last_turn"] = turn
		flags[state_flag] = state
		return event_id
	return ""
