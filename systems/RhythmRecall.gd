extends RefCounted
## ORDER-837 B1 — a free week never becomes the fourth silent week in a row.
##
## D1 (2026-11-24) measured 5-7 gaps of 4+ weeks per run (longest 11) while
## 141 authored callback scenes already had their seed flags set by a reached
## decision and were never scheduled. When the full story reaches a free week
## (no causal/finale route, arc, milestone or body scene owns it) and the last
## foreground story is MAX_GAP_WEEKS or more behind, this picks one of those
## recalls from content/meta/rhythm_recall_ledger.json:
##   - oldest decision first (ledger order), one recall per decision, never twice;
##   - every required flag set and EventManager's deferred eligibility (event
##     conditions plus living-father contracts) satisfied;
##   - scenes whose prose names an elapsed time ("두 달 전") only inside a window
##     after the latest choice of their decision event;
##   - not during mourning (W189-192 after the father died) or the finale (W238+).
## Deterministic: no RNG, so a reload of the same week picks the same scene.
## State lives in one flag read and written only here:
##   flags["rhythm_recall_state"] = {"used": [event_id], "last_turn": int}

const LEDGER_PATH := "res://content/meta/rhythm_recall_ledger.json"
const STATE_FLAG := "rhythm_recall_state"
const MAX_GAP_WEEKS := 3
const FIRST_TURN := 5
const MOURNING_FIRST := 189
const MOURNING_LAST := 192
const FINALE_FIRST := 238

static var _ledger_cache: Array = []


static func ledger() -> Array:
	if not _ledger_cache.is_empty():
		return _ledger_cache
	var text := FileAccess.get_file_as_string(LEDGER_PATH)
	var parsed: Variant = JSON.parse_string(text) if not text.is_empty() else null
	if parsed is Dictionary and (parsed as Dictionary).get("recalls", null) is Array:
		_ledger_cache = (parsed as Dictionary)["recalls"]
	return _ledger_cache


static func gap_due(turn: int, last_story_turn: int) -> bool:
	return turn >= FIRST_TURN and turn - last_story_turn > MAX_GAP_WEEKS


static func is_rest_week(turn: int, flags: Dictionary) -> bool:
	if turn >= FINALE_FIRST:
		return true
	return turn >= MOURNING_FIRST and turn <= MOURNING_LAST \
		and bool(flags.get("father_passed", false))


static func decision_turn(decision_events: Array, event_log: Array) -> int:
	var latest := -1
	for raw in event_log:
		if raw is Dictionary and decision_events.has(str((raw as Dictionary).get("event_id", ""))):
			latest = maxi(latest, int((raw as Dictionary).get("turn", -1)))
	return latest


static func in_elapsed_window(row: Dictionary, turn: int, event_log: Array) -> bool:
	if not row.has("elapsed_weeks"):
		return true
	var elapsed := int(row["elapsed_weeks"])
	var decided: int = decision_turn(row.get("decision_events", []), event_log)
	if decided < 0:
		return false
	var since := turn - decided
	return since >= ceili(elapsed * 0.75) and since <= int(elapsed * 1.5)


static func _state(flags: Dictionary) -> Dictionary:
	var raw: Variant = flags.get(STATE_FLAG, {})
	var state: Dictionary = (raw as Dictionary).duplicate(true) if raw is Dictionary else {}
	if not state.get("used", null) is Array:
		state["used"] = []
	return state


## Returns the recall to play this free week ("" for none) and records it.
static func take_scene(flags: Dictionary, turn: int, last_story_turn: int,
		event_log: Array, eligible: Callable, rows: Array = []) -> String:
	if not gap_due(turn, last_story_turn) or is_rest_week(turn, flags):
		return ""
	var state := _state(flags)
	var used: Array = state["used"]
	for raw_row in (rows if not rows.is_empty() else ledger()):
		if not raw_row is Dictionary:
			continue
		var row: Dictionary = raw_row
		var event_id := str(row.get("event_id", ""))
		if event_id.is_empty() or used.has(event_id):
			continue
		var ready := true
		for flag_id in row.get("requires_flags", []):
			if not bool(flags.get(str(flag_id), false)):
				ready = false
				break
		if not ready or not in_elapsed_window(row, turn, event_log):
			continue
		if not bool(eligible.call(event_id)):
			continue
		used.append(event_id)
		state["used"] = used
		state["last_turn"] = turn
		flags[STATE_FLAG] = state
		return event_id
	return ""
