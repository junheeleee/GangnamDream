extends Node
## Full-story easter eggs regression: every ledger egg exists, is once-only by
## its own flag, appears on a free week only when its own conditions hold, in
## ledger order, never twice, at most one per min_gap_weeks, never in mourning or
## finale weeks, and the route state survives a JSON save. One live probe proves
## the real EventManager condition gate opens and closes an egg.

const ROUTE := preload("res://systems/EasterEggRoute.gd")

var _failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	_check_ledger()
	_check_order_gap_rest_played()
	_check_json_round_trip()
	_check_live_conditions()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("EASTER_EGG_ROUTE_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("EASTER_EGG_ROUTE_CHECK_OK eggs=%d once=1 order=1 gap=1 rest=1 played=1 json=1 live=2" % [
		(ROUTE.ledger().get("eggs", []) as Array).size()])
	get_tree().quit(0)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _check_ledger() -> void:
	var eggs: Array = ROUTE.ledger().get("eggs", [])
	_expect(eggs.size() == 8, "the egg ledger lost or gained eggs (%d)" % eggs.size())
	for raw in eggs:
		var event_id := str(raw)
		var event: Dictionary = DataRegistry.find_event(event_id)
		_expect(not event.is_empty(), "egg missing: " + event_id)
		var seen_flag := event_id + "_seen"
		var conditions: Dictionary = event.get("conditions", {})
		var no_flag: Variant = conditions.get("no_flag", "")
		_expect((no_flag is String and str(no_flag) == seen_flag)
				or (no_flag is Array and (no_flag as Array).has(seen_flag)),
			"egg is not once-only by its own flag: " + event_id)
		for choice in event.get("choices", []):
			_expect(((choice as Dictionary).get("flags", []) as Array).has(seen_flag),
				"an egg choice does not close the egg: " + event_id)


func _check_order_gap_rest_played() -> void:
	var data := {"min_gap_weeks": 6, "rest_weeks": [[189, 192]], "eggs": ["egg_a", "egg_b"]}
	var all_ok := func(_id: String) -> bool: return true
	var none_played := func(_id: String) -> bool: return false
	var flags := {}
	_expect(ROUTE.take_scene(flags, 50, func(_id): return false, none_played, data) == "",
		"an egg appeared without its conditions")
	_expect(ROUTE.take_scene(flags, 50, all_ok, none_played, data) == "egg_a",
		"the first eligible egg did not come first")
	_expect(ROUTE.take_scene(flags, 55, all_ok, none_played, data) == "",
		"two eggs came closer than the gap")
	var a_played := func(id: String) -> bool: return id == "egg_a"
	_expect(ROUTE.take_scene(flags, 56, all_ok, a_played, data) == "egg_b",
		"the next egg did not follow after the gap")
	_expect(ROUTE.take_scene({}, 190, all_ok, none_played, data) == "",
		"an egg appeared during mourning")
	var both := func(_id: String) -> bool: return true
	_expect(ROUTE.take_scene({}, 80, all_ok, both, data) == "",
		"a played egg appeared again")


func _check_json_round_trip() -> void:
	var data := {"min_gap_weeks": 6, "eggs": ["egg_a"]}
	var flags := {}
	ROUTE.take_scene(flags, 40, func(_id): return true, func(_id): return false, data)
	var restored: Dictionary = JSON.parse_string(JSON.stringify(flags))
	_expect(ROUTE.take_scene(restored, 43, func(_id): return true, func(_id): return false, data) == "",
		"a JSON save lost the egg gap")


func _check_live_conditions() -> void:
	var saved_turn: int = GameState.turn
	var saved_money: float = GameState.money
	var saved_flags: Dictionary = GameState.flags.duplicate(true)
	GameState.turn = 60
	GameState.money = 500000.0
	GameState.flags.erase("egg_triangle_kimbap_seen")
	_expect(EventManager.deferred_event_is_eligible("egg_triangle_kimbap"),
		"the triangle-kimbap egg did not open for a broke W60 run")
	GameState.flags["egg_triangle_kimbap_seen"] = true
	_expect(not EventManager.deferred_event_is_eligible("egg_triangle_kimbap"),
		"the triangle-kimbap egg reopened after it played")
	GameState.turn = saved_turn
	GameState.money = saved_money
	GameState.flags = saved_flags
