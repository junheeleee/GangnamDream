extends Node
## ORDER-836 B2 regression: the player's choices tilt the body. Every ledger
## choice exists in the shipped event with a real index; a rest choice adds
## health for the chosen week and the five after it, a strain choice takes it,
## the latest listed choice replaces the earlier tide, a week never pays twice,
## an unlisted index leaves the tide alone, a health crisis queues exactly one
## crisis scene (first unused, then the oldest), and the state survives a JSON
## save. MainGame applies the tide and the crisis scene only in a full run.

const TIDE := preload("res://systems/BodyTide.gd")

var _failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	_check_ledger()
	_check_rest_and_strain()
	_check_replace_and_idempotent()
	_check_crisis()
	_check_json_round_trip()
	_check_main_game_gate()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("BODY_TIDE_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("BODY_TIDE_CHECK_OK choices=%d crisis_scenes=%d rest=1 strain=1 replace=1 idempotent=1 crisis=3 json=1 gate=1" % [
		(TIDE.ledger().get("choices", []) as Array).size(),
		(TIDE.ledger().get("crisis_scenes", []) as Array).size()])
	get_tree().quit(0)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _log(event_id: String, turn: int, choice_index: int) -> Dictionary:
	return {"event_id": event_id, "turn": turn, "choice_index": choice_index}


func _always(_event_id: String) -> bool:
	return true


func _check_ledger() -> void:
	var source := TIDE.ledger()
	_expect(not source.is_empty(), "the body tide ledger did not load")
	for raw in source.get("choices", []):
		var row: Dictionary = raw
		var event: Dictionary = DataRegistry.find_event(str(row.get("event_id", "")))
		var count := (event.get("choices", []) as Array).size()
		_expect(not event.is_empty(), "ledger event missing: %s" % row.get("event_id", ""))
		for key in ["rest", "strain"]:
			for index in row.get(key, []):
				_expect(int(index) >= 0 and int(index) < count,
					"%s %s index %s is not a real choice" % [row.get("event_id", ""), key, index])
	for event_id in source.get("crisis_scenes", []):
		_expect(not DataRegistry.find_event(str(event_id)).is_empty(),
			"crisis scene missing: %s" % event_id)


func _run(flags: Dictionary, event_log: Array, turns: Array) -> Array:
	var deltas: Array = []
	for turn in turns:
		deltas.append(TIDE.take_week(flags, int(turn), event_log))
	return deltas


func _check_rest_and_strain() -> void:
	var rest_log := [_log("health_sleep_debt", 40, 0)]
	var rest := _run({}, rest_log, range(39, 48))
	_expect(rest == [0, 2, 2, 2, 2, 2, 2, 0, 0],
		"a rest choice did not add health for six weeks from the chosen week: %s" % str(rest))
	var strain := _run({}, [_log("drama_burnout_warning", 60, 1)], range(60, 67))
	_expect(strain == [-2, -2, -2, -2, -2, -2, 0],
		"a strain choice did not take health for six weeks: %s" % str(strain))
	var unlisted := _run({}, [_log("health_checkup_reminder", 70, 1)], range(70, 73))
	_expect(unlisted == [0, 0, 0], "an unlisted choice moved the tide: %s" % str(unlisted))


func _check_replace_and_idempotent() -> void:
	var flags := {}
	var event_log: Array = [_log("health_burnout_signal", 80, 0)]
	var first := _run(flags, event_log, [80, 81])
	event_log.append(_log("arc_36_body_signal", 82, 2))
	var after := _run(flags, event_log, [82, 87, 88])
	_expect(first == [2, 2] and after == [-2, -2, 0],
		"the latest choice did not replace the earlier tide: %s %s" % [str(first), str(after)])
	_expect(TIDE.take_week(flags, 87, event_log) == 0, "the same week paid twice")


func _check_crisis() -> void:
	var flags := {}
	_expect(TIDE.take_crisis_scene(flags, 50, _always) == "", "a crisis scene played with no crisis")
	TIDE.queue_crisis(flags, 50)
	var first := TIDE.take_crisis_scene(flags, 50, _always)
	_expect(first == "health_burnout_signal" and TIDE.take_crisis_scene(flags, 51, _always) == "",
		"one crisis did not bring exactly one scene: %s" % first)
	var seen: Array = []
	for turn in [60, 70, 80, 90]:
		TIDE.queue_crisis(flags, turn)
		seen.append(TIDE.take_crisis_scene(flags, turn, _always))
	_expect(seen == ["health_checkup_00", "health_sleep_debt", "health_checkup_reminder",
			"health_burnout_signal"],
		"crisis scenes did not rotate to the oldest: %s" % str(seen))


func _check_json_round_trip() -> void:
	var flags := {}
	var event_log := [_log("health_insomnia", 100, 1)]
	TIDE.take_week(flags, 100, event_log)
	TIDE.queue_crisis(flags, 101)
	var restored: Dictionary = JSON.parse_string(JSON.stringify(flags))
	_expect(TIDE.take_week(restored, 100, event_log) == 0, "a JSON save let a week pay twice")
	_expect(TIDE.take_week(restored, 101, event_log) == -2, "a JSON save lost the tide")
	_expect(TIDE.take_crisis_scene(restored, 101, _always) != "", "a JSON save lost the crisis")


func _check_main_game_gate() -> void:
	var source := FileAccess.get_file_as_string("res://scenes/MainGame.gd")
	var tide_at := source.find("func _full_story_apply_body_tide(")
	var crisis_at := source.find("func _full_story_body_crisis_scene_id(")
	_expect(tide_at >= 0 and crisis_at >= 0
			and source.find("if not FULL_STORY_FLOW.is_full_run():", tide_at) < tide_at + 200
			and source.find("if not FULL_STORY_FLOW.is_full_run():", crisis_at) < crisis_at + 120
			and source.contains("BODY_TIDE.queue_crisis(GameState.flags"),
		"MainGame does not gate the body tide and crisis scene to the full run")
