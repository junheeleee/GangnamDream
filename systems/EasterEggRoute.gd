extends RefCounted
## Full-story easter eggs (user direction 2026-11-26).
##
## The eight authored eggs (the goshiwon sage, the triangle-kimbap chronicle,
## 4 a.m. clarity, the gambler in the mirror, the quiet rich man, deja vu...)
## lived only in the old random pool, which the full story never runs. On a
## free full-story week the first egg, in ledger order, whose own conditions hold
## and that has not played yet appears, at most one per min_gap_weeks.
## Each egg keeps its own conditions and once-only flag as the source of truth.
## Deterministic (no RNG). State lives in one flag read and written only here:
##   flags["easter_egg_state"] = {"last_turn": int}

const LEDGER_PATH := "res://content/meta/easter_egg_ledger.json"
const STATE_FLAG := "easter_egg_state"

static var _ledger_cache: Dictionary = {}


static func ledger() -> Dictionary:
	if _ledger_cache.is_empty():
		var text := FileAccess.get_file_as_string(LEDGER_PATH)
		var parsed: Variant = JSON.parse_string(text) if not text.is_empty() else null
		_ledger_cache = parsed if parsed is Dictionary else {}
	return _ledger_cache


static func _in_rest(source: Dictionary, turn: int) -> bool:
	for raw in source.get("rest_weeks", []):
		if raw is Array and (raw as Array).size() == 2 \
				and turn >= int(raw[0]) and turn <= int(raw[1]):
			return true
	return false


## Returns this free week's egg ("" for none) and records it. `eligible` must
## answer the egg's own conditions; `played` reports eggs already in the log.
static func take_scene(flags: Dictionary, turn: int, eligible: Callable, played: Callable,
		data: Dictionary = {}) -> String:
	var source: Dictionary = data if not data.is_empty() else ledger()
	if source.is_empty() or _in_rest(source, turn):
		return ""
	var raw_state: Variant = flags.get(STATE_FLAG, {})
	var state: Dictionary = (raw_state as Dictionary).duplicate(true) \
		if raw_state is Dictionary else {}
	var last := int(state.get("last_turn", -100))
	if turn - last < int(source.get("min_gap_weeks", 6)):
		return ""
	for raw in source.get("eggs", []):
		var event_id := str(raw)
		if event_id.is_empty() or bool(played.call(event_id)) \
				or not bool(eligible.call(event_id)):
			continue
		state["last_turn"] = turn
		flags[STATE_FLAG] = state
		return event_id
	return ""
