extends Node
## ORDER-834 B2.5 regression: free-week habit visits. An activity calls only
## after the player entered it, comes back on the next free week after a week
## the player went (at most twice in a row, then a rest; at most six calls a story year) and waits after a refusal, turns habitual after enough visits,
## stays quiet in mourning/finale weeks, honors the quit flags and the holding
## premise, rotates between activities, survives a JSON save, and every habit
## scene's "go" choice really opens its minigame or a real trade.

const HABIT := preload("res://systems/BranchHabit.gd")
const FLOW := preload("res://systems/FullStoryFlow.gd")

var _failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	_check_ledger_and_sources()
	_check_entry_and_cadence()
	_check_habitual_variant()
	_check_rest_quit_and_holding()
	_check_rotation()
	_check_streak_cap()
	_check_yearly_cap()
	_check_json_round_trip()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("BRANCH_HABIT_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("BRANCH_HABIT_CHECK_OK activities=%d events=%d cadence=3 streak=1 yearly=1 habitual=1 rest=1 quit=1 holding=1 rotation=1 json=1" % [
		(HABIT.ledger().get("activities", []) as Array).size(), HABIT.HABIT_EVENT_IDS.size()])
	get_tree().quit(0)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _always(_event_id: String) -> bool:
	return true


func _log(event_id: String, turn: int, choice_index: int) -> Dictionary:
	return {"event_id": event_id, "turn": turn, "choice_index": choice_index}


func _check_ledger_and_sources() -> void:
	var ledger_ids: Array = []
	var open_flags := {"racetrack": "open_racetrack_after_story", "holdem": "open_holdem_after_story",
		"jeongseon_casino": "open_casino_after_story"}
	for raw in HABIT.ledger().get("activities", []):
		var activity: Dictionary = raw
		var activity_id := str(activity.get("id", ""))
		for raw_event in activity.get("events", []):
			var row: Dictionary = raw_event
			var event_id := str(row.get("event_id", ""))
			ledger_ids.append(event_id)
			var event: Dictionary = DataRegistry.find_event(event_id)
			var choices: Array = event.get("choices", [])
			_expect(not event.is_empty() and choices.size() >= 2,
				"habit scene missing or without a refusal: " + event_id)
			_expect(int((event.get("conditions", {}) as Dictionary).get("min_turn", 0)) >= 9999,
				"habit scene leaked into the random pool: " + event_id)
			var go: Array = row.get("go", [])
			_expect(not go.is_empty() and go.size() < choices.size(),
				"habit scene has no way to go or no way to refuse: " + event_id)
			for index in go:
				_expect(int(index) >= 0 and int(index) < choices.size(),
					"habit go index out of range: %s %s" % [event_id, str(index)])
				if choices.is_empty() or int(index) >= choices.size():
					continue
				var choice: Dictionary = choices[int(index)]
				if open_flags.has(activity_id):
					_expect((choice.get("flags", []) as Array).has(open_flags[activity_id]),
						"habit go choice does not open its minigame: " + event_id)
					var listed := false
					for pair in FLOW.ACTIVITY_SOURCES.get(activity_id, []):
						if str(pair[0]) == event_id and int(pair[1]) == int(index):
							listed = true
					_expect(listed, "habit go choice is not a valid activity source: " + event_id)
				else:
					_expect(choice.has("market_buy") or choice.has("market_sell"),
						"portfolio go choice makes no real trade: " + event_id)
	var sorted_ledger := ledger_ids.duplicate()
	sorted_ledger.sort()
	var sorted_allowed: Array = HABIT.HABIT_EVENT_IDS.duplicate()
	sorted_allowed.sort()
	_expect(sorted_ledger == sorted_allowed, "habit ledger and the engine allow-list differ")
	_expect(HABIT.take_scene({"racetrack_visited": true}, 30, false, [], _always,
		{"activities": [{"id": "racetrack", "requires_any": ["racetrack_visited"],
			"events": [{"event_id": "not_a_habit_scene", "go": [0]}]}]}) == "",
		"the engine played a scene outside its allow-list")


func _check_entry_and_cadence() -> void:
	_expect(HABIT.take_scene({}, 30, false, [], _always) == "",
		"a habit called before the player entered anything")
	var flags := {"racetrack_visited": true}
	_expect(HABIT.take_scene(flags, 30, false, [], _always) == "habit_race_saturday",
		"the track did not call after the first visit")
	_expect(HABIT.take_scene(flags, 30, false, [_log("habit_race_saturday", 30, 0)], _always) == "",
		"the same week offered a second habit scene")
	var went_log := [_log("habit_race_saturday", 30, 0)]
	_expect(HABIT.take_scene(flags, 31, false, went_log, _always) == "habit_race_saturday",
		"after going, the track did not call on the next free week")
	_expect(HABIT.visits(flags, "racetrack") == 1, "a week the player went was not counted")
	var skipped_log := went_log + [_log("habit_race_saturday", 31, 1)]
	var quiet := true
	for turn in range(32, 35):
		if HABIT.take_scene(flags, turn, false, skipped_log, _always) != "":
			quiet = false
	_expect(quiet, "a refusal did not buy quiet weeks")
	_expect(HABIT.take_scene(flags, 35, false, skipped_log, _always) == "habit_race_saturday",
		"the track did not call again after the quiet weeks")
	_expect(HABIT.visits(flags, "racetrack") == 1, "a refusal was counted as a visit")


func _check_habitual_variant() -> void:
	var flags := {"holdem_visited": true}
	var log: Array = []
	var seen: Array = []
	for turn in [60, 61, 64, 65, 68, 69]:
		var scene := HABIT.take_scene(flags, turn, false, log, _always)
		seen.append(scene)
		log.append(_log(scene, turn, 0))
	_expect(seen.slice(0, 4).all(func(id): return id == "habit_holdem_night"),
		"the first hold'em visits did not use the first variant: %s" % str(seen))
	_expect(seen[4] == "habit_holdem_regular" and seen[5] == "habit_holdem_regular",
		"four visits did not turn the call habitual: %s" % str(seen))


func _check_rest_quit_and_holding() -> void:
	_expect(HABIT.take_scene({"racetrack_visited": true}, 190, false, [], _always) == ""
			and HABIT.take_scene({"racetrack_visited": true}, 239, false, [], _always) == "",
		"a habit called during mourning or the finale")
	_expect(HABIT.take_scene({"holdem_visited": true, "holdem_quit": true}, 70, false, [], _always) == "",
		"hold'em called after the player quit")
	var invest := {"investment_lesson_1": true}
	_expect(HABIT.take_scene(invest.duplicate(), 40, false, [], _always) == "",
		"the account called without a holding")
	_expect(HABIT.take_scene(invest, 40, true, [], _always) == "habit_portfolio_check",
		"the account did not call with a holding")


func _check_rotation() -> void:
	var flags := {"racetrack_visited": true, "holdem_visited": true}
	var first := HABIT.take_scene(flags, 80, false, [], _always)
	var second := HABIT.take_scene(flags, 81, false, [_log(first, 80, 1)], _always)
	_expect(first == "habit_race_saturday" and second == "habit_holdem_night",
		"two open activities did not take turns: %s, %s" % [first, second])


func _check_streak_cap() -> void:
	var flags := {"investment_lesson_1": true}
	var log: Array = []
	var seen: Array = []
	for turn in range(136, 144):
		var scene := HABIT.take_scene(flags, turn, true, log, _always)
		seen.append(scene)
		if not scene.is_empty():
			log.append(_log(scene, turn, 0))
	var played: Array = seen.map(func(id): return 0 if str(id).is_empty() else 1)
	_expect(played == [1, 1, 0, 0, 1, 1, 0, 0],
		"the same habit ran more than twice in a row or the rest was wrong: %s" % str(seen))
	var skipped := {"racetrack_visited": true}
	HABIT.take_scene(skipped, 30, false, [], _always)
	HABIT.take_scene(skipped, 31, false, [_log("habit_race_saturday", 30, 0)], _always)
	var after_gap := HABIT.take_scene(skipped, 36, false,
		[_log("habit_race_saturday", 30, 0), _log("habit_race_saturday", 31, 0)], _always)
	var state: Dictionary = skipped[HABIT.STATE_FLAG]
	_expect(after_gap == "habit_race_saturday"
			and int(((state["offers"] as Dictionary)["racetrack"] as Dictionary)["streak"]) == 1,
		"a call after a long quiet stretch did not start a new streak")


func _check_yearly_cap() -> void:
	var flags := {"racetrack_visited": true}
	var log: Array = []
	var calls: Array = []
	# Year 2 is turns 49-96. Going every free week with the streak rest gives
	# far more than six chances; only six may call.
	for turn in range(49, 97):
		var scene := HABIT.take_scene(flags, turn, false, log, _always)
		if not scene.is_empty():
			calls.append(turn)
			log.append(_log(scene, turn, 0))
	_expect(calls.size() == 6, "a habit called %d times in one story year: %s" % [calls.size(), str(calls)])
	_expect(HABIT.take_scene(flags, 97, false, log, _always) == "habit_race_regular",
		"the habit did not call again in the next story year")


func _check_json_round_trip() -> void:
	var flags := {"racetrack_visited": true}
	HABIT.take_scene(flags, 50, false, [], _always)
	HABIT.take_scene(flags, 51, false, [_log("habit_race_saturday", 50, 0)], _always)
	var restored: Dictionary = JSON.parse_string(JSON.stringify(flags))
	_expect(HABIT.visits(restored, "racetrack") == 1, "visits did not survive a JSON save")
	_expect(HABIT.take_scene(restored, 51, false, [], _always) == "",
		"a JSON save let the same week offer twice")
	_expect(HABIT.take_scene(restored, 52, false, [_log("habit_race_saturday", 51, 0)], _always) == "",
		"a JSON save lost the streak rest")
	_expect(HABIT.take_scene(restored, 54, false, [_log("habit_race_saturday", 51, 0)], _always)
			== "habit_race_saturday",
		"a JSON save lost the go cadence")
