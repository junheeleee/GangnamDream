extends RefCounted
## ORDER-840 G1 — the stakes grow with the run (no big table on day one).
## Full run only: the racetrack's stake list and the hold'em buy-ins and
## blinds come from the highest tier the run has opened in
## content/meta/gamble_stake_ledger.json (turn, story flags, habit visits,
## cash). Outside a full run the tables keep their fixed lists.

const LEDGER_PATH := "res://content/meta/gamble_stake_ledger.json"
const HABIT_STATE_FLAG := "branch_habit_state"

static var _ledger_cache: Dictionary = {}


static func ledger() -> Dictionary:
	if _ledger_cache.is_empty():
		var text := FileAccess.get_file_as_string(LEDGER_PATH)
		var parsed: Variant = JSON.parse_string(text) if not text.is_empty() else null
		_ledger_cache = parsed if parsed is Dictionary else {}
	return _ledger_cache


static func _visits(flags: Dictionary, activity_id: String) -> int:
	var state: Variant = flags.get(HABIT_STATE_FLAG, {})
	if not state is Dictionary:
		return 0
	var visits: Variant = (state as Dictionary).get("visits", {})
	return int((visits as Dictionary).get(activity_id, 0)) if visits is Dictionary else 0


## The highest tier open for this activity ("racetrack" or "holdem").
static func tier(activity_id: String, flags: Dictionary, turn: int, money: float,
		data: Dictionary = {}) -> Dictionary:
	var source: Dictionary = data if not data.is_empty() else ledger()
	var best: Dictionary = {}
	for raw in source.get("tiers", []):
		if not raw is Dictionary:
			continue
		var row: Dictionary = raw
		if turn < int(row.get("min_turn", 0)) or money < float(row.get("min_cash", 0)):
			continue
		if _visits(flags, activity_id) < int(row.get("min_visits", 0)):
			continue
		var any: Array = row.get("requires_any", [])
		var found := any.is_empty()
		for flag_id in any:
			if bool(flags.get(str(flag_id), false)):
				found = true
		if found:
			best = row
	return best


static func race_stakes(flags: Dictionary, turn: int, money: float) -> Array:
	return _ints(tier("racetrack", flags, turn, money).get("race_stakes", []))


static func holdem_buyins(flags: Dictionary, turn: int, money: float) -> Array:
	return _ints(tier("holdem", flags, turn, money).get("holdem_buyins", []))


static func holdem_blind_scale(flags: Dictionary, turn: int, money: float) -> int:
	return maxi(1, int(tier("holdem", flags, turn, money).get("holdem_blind_scale", 1)))


static func _ints(values: Array) -> Array:
	var out: Array = []
	for value in values:
		out.append(int(value))
	return out
