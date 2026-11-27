extends RefCounted
## ORDER-836 B2 — the player's own choices tilt the body (DECISIONS 2026-11-27).
##
## The automatic routine alone fixed the body's slope by employment: with a job
## health climbs to 100 and stays, without one it slides about half a point a
## week into burnout, and no choice changed either (ORDER-836 B2 input, 18 runs).
## In a full run a listed rest choice now adds `rest_health` a week for `weeks`
## weeks, counting the week it was chosen; a listed strain choice takes
## `strain_health` instead. The latest listed choice replaces the earlier tide.
## A monthly health crisis still hits at once with its toast, and also queues
## the next free week's crisis scene, so the player can answer the body. The
## damage is not held for the scene: a dense year can leave no free week for
## months, and held crises then landed together (D1 2026-11-27 gamble_s02:
## three crises from W9 hit at W32 as -38).
##
## Deterministic (no RNG). Choices are read back from the event log (event id,
## turn, choice index). State lives in one flag read and written only here:
##   flags["body_tide_state"] = {"kind": "rest"|"strain"|"", "from": int,
##     "applied": int, "crisis": int, "crisis_used": [event_id]}

const LEDGER_PATH := "res://content/meta/body_tide_ledger.json"
const STATE_FLAG := "body_tide_state"

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
	if not state.get("crisis_used", null) is Array:
		state["crisis_used"] = []
	return state


static func _has_index(indexes: Variant, picked: int) -> bool:
	if not indexes is Array:
		return false
	for index in indexes:
		if int(index) == picked:
			return true
	return false


## The latest listed rest/strain choice at or before `turn`: [kind, turn].
static func _latest_choice(source: Dictionary, event_log: Array, turn: int) -> Array:
	var rows: Dictionary = {}
	for raw in source.get("choices", []):
		if raw is Dictionary:
			rows[str((raw as Dictionary).get("event_id", ""))] = raw
	var best_kind := ""
	var best_turn := -1
	for logged in event_log:
		if not logged is Dictionary:
			continue
		var entry: Dictionary = logged
		var row: Variant = rows.get(str(entry.get("event_id", "")), null)
		var at := int(entry.get("turn", -1))
		if not row is Dictionary or at > turn or at < best_turn:
			continue
		var picked := int(entry.get("choice_index", -1))
		if _has_index((row as Dictionary).get("rest", []), picked):
			best_kind = "rest"
			best_turn = at
		elif _has_index((row as Dictionary).get("strain", []), picked):
			best_kind = "strain"
			best_turn = at
	return [best_kind, best_turn]


## This week's tide in health points (0 for none), recorded so a week never
## pays twice. Call once per full-run week, after that week's scenes.
static func take_week(flags: Dictionary, turn: int, event_log: Array,
		data: Dictionary = {}) -> int:
	var source: Dictionary = data if not data.is_empty() else ledger()
	if source.is_empty():
		return 0
	var state := _state(flags)
	var latest := _latest_choice(source, event_log, turn)
	if str(latest[0]) != "" and int(latest[1]) >= int(state.get("from", -1)):
		state["kind"] = str(latest[0])
		state["from"] = int(latest[1])
	var delta := 0
	var kind := str(state.get("kind", ""))
	var from := int(state.get("from", -1))
	if kind != "" and turn >= from and turn < from + int(source.get("weeks", 6)) \
			and int(state.get("applied", -1)) < turn:
		delta = int(source.get("rest_health", 2)) if kind == "rest" \
			else int(source.get("strain_health", -2))
		state["applied"] = turn
	flags[STATE_FLAG] = state
	return delta


## A monthly health crisis hit this week: the next free week answers it. A
## second crisis before that week keeps the one pending scene.
static func queue_crisis(flags: Dictionary, turn: int) -> void:
	var state := _state(flags)
	if int(state.get("crisis", 0)) <= 0:
		state["crisis"] = turn
	flags[STATE_FLAG] = state


## The crisis scene for this free week ("" for none) and records it.
static func take_crisis_scene(flags: Dictionary, turn: int, event_exists: Callable,
		data: Dictionary = {}) -> String:
	var source: Dictionary = data if not data.is_empty() else ledger()
	var state := _state(flags)
	var crisis := int(state.get("crisis", 0))
	if crisis <= 0 or crisis > turn:
		return ""
	var used: Array = state["crisis_used"]
	var chosen := ""
	var oldest := ""
	for raw in source.get("crisis_scenes", []):
		var event_id := str(raw)
		if not bool(event_exists.call(event_id)):
			continue
		if not used.has(event_id):
			chosen = event_id
			break
		if oldest.is_empty() or used.find(event_id) < used.find(oldest):
			oldest = event_id
	if chosen.is_empty():
		chosen = oldest
	if chosen.is_empty():
		return ""
	used.erase(chosen)
	used.append(chosen)
	state["crisis_used"] = used
	state["crisis"] = 0
	flags[STATE_FLAG] = state
	return chosen
