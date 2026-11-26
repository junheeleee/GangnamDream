extends RefCounted
## ORDER-834 B2.5 — free-week habit visits (DECISIONS 2026-11-26).
##
## The branch beats (InvestBranchBeats / GambleBranchBeats) are authored scenes
## the story opens once. This is the player's own repetition: once a full run has
## entered the racetrack, the hold'em room, Jeongseon or a brokerage account, a
## free week may offer one short habit scene. Going opens the real minigame or a
## real trade; refusing is always a choice. An activity the player went to calls
## again on the next free week; a refusal buys return_gap_after_skip quiet weeks.
## After habitual_visits weeks the regular variant (heavier cost) replaces the first.
##
## Deterministic (no RNG). Whether the player went is read back from the event log
## (the offered event's choice index on the offered turn). State lives in one flag
## read and written only here:
##   flags["branch_habit_state"] = {
##     "offers": {activity: {"turn": int, "event": id, "settled": bool, "went": bool}},
##     "visits": {activity: int}}

const LEDGER_PATH := "res://content/meta/branch_habit_ledger.json"
const STATE_FLAG := "branch_habit_state"
## The only scenes this engine may play. The ledger orders and gates them; a
## ledger id outside this list never plays (BranchHabitCheck keeps them equal).
const HABIT_EVENT_IDS := [
	"habit_race_saturday", "habit_race_regular",
	"habit_holdem_night", "habit_holdem_regular",
	"habit_casino_trip", "habit_casino_regular",
	"habit_portfolio_check", "habit_portfolio_regular",
]

static var _ledger_cache: Dictionary = {}


static func ledger() -> Dictionary:
	if _ledger_cache.is_empty():
		var text := FileAccess.get_file_as_string(LEDGER_PATH)
		var parsed: Variant = JSON.parse_string(text) if not text.is_empty() else null
		_ledger_cache = parsed if parsed is Dictionary else {}
	return _ledger_cache


static func _state(flags: Dictionary) -> Dictionary:
	var raw: Variant = flags.get(STATE_FLAG, {})
	var state: Dictionary = (raw as Dictionary).duplicate(true) if raw is Dictionary else {}
	if not state.get("offers", null) is Dictionary:
		state["offers"] = {}
	if not state.get("visits", null) is Dictionary:
		state["visits"] = {}
	return state


static func visits(flags: Dictionary, activity_id: String) -> int:
	return int((_state(flags)["visits"] as Dictionary).get(activity_id, 0))


static func _in_rest(source: Dictionary, turn: int) -> bool:
	for raw in source.get("rest_weeks", []):
		if raw is Array and (raw as Array).size() == 2 \
				and turn >= int(raw[0]) and turn <= int(raw[1]):
			return true
	return false


static func _go_indexes(activity: Dictionary, event_id: String) -> Array:
	for raw in activity.get("events", []):
		if raw is Dictionary and str((raw as Dictionary).get("event_id", "")) == event_id:
			return (raw as Dictionary).get("go", [])
	return []


## Reads each past, unsettled offer back from the event log exactly once.
static func _settle(state: Dictionary, source: Dictionary, turn: int, event_log: Array) -> void:
	var offers: Dictionary = state["offers"]
	var counts: Dictionary = state["visits"]
	for raw in source.get("activities", []):
		if not raw is Dictionary:
			continue
		var activity: Dictionary = raw
		var activity_id := str(activity.get("id", ""))
		var offer: Variant = offers.get(activity_id, null)
		if not offer is Dictionary or bool((offer as Dictionary).get("settled", false)) \
				or int((offer as Dictionary).get("turn", 0)) >= turn:
			continue
		var offered: Dictionary = offer
		var went := false
		var go: Array = _go_indexes(activity, str(offered.get("event", "")))
		for logged in event_log:
			if logged is Dictionary \
					and str((logged as Dictionary).get("event_id", "")) == str(offered.get("event", "")) \
					and int((logged as Dictionary).get("turn", -1)) == int(offered.get("turn", -2)):
				var picked := int((logged as Dictionary).get("choice_index", -1))
				for index in go:
					if int(index) == picked:
						went = true
		offered["settled"] = true
		offered["went"] = went
		offers[activity_id] = offered
		if went:
			counts[activity_id] = int(counts.get(activity_id, 0)) + 1
	state["offers"] = offers
	state["visits"] = counts


static func _eligible(activity: Dictionary, flags: Dictionary, has_portfolio: bool) -> bool:
	var any: Array = activity.get("requires_any", [])
	if not any.is_empty():
		var found := false
		for flag_id in any:
			if bool(flags.get(str(flag_id), false)):
				found = true
		if not found:
			return false
	for flag_id in activity.get("requires_all", []):
		if not bool(flags.get(str(flag_id), false)):
			return false
	for flag_id in activity.get("forbids", []):
		if bool(flags.get(str(flag_id), false)):
			return false
	return not bool(activity.get("portfolio", false)) or has_portfolio


## Returns this free week's habit scene ("" for none) and records the offer.
## `event_exists` filters ids the data registry cannot resolve.
static func take_scene(flags: Dictionary, turn: int, has_portfolio: bool, event_log: Array,
		event_exists: Callable, data: Dictionary = {}) -> String:
	var source: Dictionary = data if not data.is_empty() else ledger()
	if source.is_empty():
		return ""
	var state := _state(flags)
	_settle(state, source, turn, event_log)
	flags[STATE_FLAG] = state
	if _in_rest(source, turn):
		return ""
	var offers: Dictionary = state["offers"]
	var best: Dictionary = {}
	var best_last := 0
	for raw in source.get("activities", []):
		if not raw is Dictionary or not _eligible(raw as Dictionary, flags, has_portfolio):
			continue
		var activity: Dictionary = raw
		var activity_id := str(activity.get("id", ""))
		var last := -100
		var gap := 0
		var offer: Variant = offers.get(activity_id, null)
		if offer is Dictionary:
			last = int((offer as Dictionary).get("turn", -100))
			gap = int(source.get("return_gap_after_go", 1)) \
				if bool((offer as Dictionary).get("went", false)) \
				else int(source.get("return_gap_after_skip", 4))
		if turn - last < gap or turn == last:
			continue
		if best.is_empty() or last < best_last:
			best = activity
			best_last = last
	if best.is_empty():
		return ""
	var activity_id := str(best.get("id", ""))
	var habitual := int((state["visits"] as Dictionary).get(activity_id, 0)) \
		>= int(source.get("habitual_visits", 4))
	var chosen := ""
	for raw in best.get("events", []):
		if raw is Dictionary and bool((raw as Dictionary).get("habitual", false)) == habitual:
			chosen = str((raw as Dictionary).get("event_id", ""))
			break
	if chosen.is_empty() or not HABIT_EVENT_IDS.has(chosen) \
			or not bool(event_exists.call(chosen)):
		return ""
	offers[activity_id] = {"turn": turn, "event": chosen, "settled": false, "went": false}
	state["offers"] = offers
	flags[STATE_FLAG] = state
	return chosen
