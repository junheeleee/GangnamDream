extends Node
## ORDER-834 B2 regression: the gambling branch only follows a fact the player
## made (visited the track, met the mentor, went to Jeongseon, entered the
## network), plays its beats in ledger order inside their windows and gaps,
## respects the job premise and the "took a break" exits, survives a JSON save,
## and every beat is a real decision with an authored wager or exit.

const BEATS := preload("res://systems/GambleBranchBeats.gd")

var _failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	_check_ledger()
	_check_gates_order_gap()
	_check_job_and_exits()
	_check_casino_and_holdem()
	_check_json_round_trip()
	_check_years_three_four()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("GAMBLE_BRANCH_BEATS_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("GAMBLE_BRANCH_BEATS_CHECK_OK beats=%d gate=1 order=3 job=1 exits=2 casino=2 holdem=1 json=1 y34_addiction=4 y34_father=1 y34_recovery=1 y34_session=2 y34_race_money=1" % [
		(BEATS.ledger().get("beats", []) as Array).size()])
	get_tree().quit(0)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _always(_event_id: String) -> bool:
	return true


func _check_ledger() -> void:
	var beats: Array = BEATS.ledger().get("beats", [])
	_expect(beats.size() >= 12, "gambling ledger lost its beats (%d)" % beats.size())
	var wagers := 0
	for raw in beats:
		var event_id := str((raw as Dictionary).get("event_id", ""))
		var event: Dictionary = DataRegistry.find_event(event_id)
		_expect(not event.is_empty() and (event.get("choices", []) as Array).size() >= 2,
			"gambling beat missing or without a decision: " + event_id)
		_expect(not (raw as Dictionary).get("requires", []).is_empty()
				or not (raw as Dictionary).get("requires_any", []).is_empty(),
			"gambling beat opens without a player fact: " + event_id)
		for choice in event.get("choices", []):
			if float(((choice as Dictionary).get("effects", {}) as Dictionary).get("money", 0.0)) < 0.0:
				wagers += 1
	_expect(wagers >= 6, "gambling beats lost their authored wagers (%d)" % wagers)


func _check_gates_order_gap() -> void:
	_expect(BEATS.take_scene({}, 30, true, _always) == "", "the branch opened without a visit")
	var flags := {"racetrack_visited": true, "racetrack_guide_met": true}
	_expect(BEATS.take_scene(flags, 16, false, _always) == "race_early_lesson",
		"the mentor's lesson did not come first")
	_expect(BEATS.take_scene(flags, 17, false, _always) == "", "two gambling beats within the gap")
	_expect(BEATS.take_scene(flags, 19, false, _always) == "race_number_three",
		"the track did not continue in order")


func _check_job_and_exits() -> void:
	var jobless := {"racetrack_visited": true,
		"gamble_branch_state": {"used": ["race_number_three"], "last_turn": 20}}
	_expect(BEATS.take_scene(jobless, 30, false, _always) == "race_last_train_home",
		"a workplace racetrack scene played without a job")
	var paused := {"racetrack_visited": true, "racetrack_guide_met": true, "racetrack_paused": true,
		"gamble_branch_state": {"used": ["race_early_lesson", "race_number_three", "race_coworker_encounter",
			"race_last_train_home", "race_addiction_warning"], "last_turn": 40}}
	_expect(BEATS.take_scene(paused, 60, true, _always) == "",
		"the track kept calling after the player took a month off")
	var heard := {"racetrack_visited": true, "race_mentor_truth_heard": true,
		"gamble_branch_state": {"used": ["race_number_three", "race_coworker_encounter",
			"race_last_train_home"], "last_turn": 40}}
	_expect(BEATS.take_scene(heard, 60, true, _always) == "",
		"the last-bettor line played after walking out with the mentor")


func _check_casino_and_holdem() -> void:
	var early := {"casino_club_introduced": true}
	_expect(BEATS.take_scene(early, 70, true, _always) == "", "Jeongseon chips before the W76 trip")
	var trip := {"casino_club_introduced": true}
	_expect(BEATS.take_scene(trip, 77, true, _always) == "casino_chip_exchange",
		"the Jeongseon trip still has no reader")
	var net := {"entered_network": true}
	_expect(BEATS.take_scene(net, 60, true, _always) == "holdem_first_visit",
		"Sangchul's network did not lead to the hold'em room")


func _check_json_round_trip() -> void:
	var flags := {"racetrack_visited": true, "racetrack_guide_met": true}
	BEATS.take_scene(flags, 16, false, _always)
	var loaded: Dictionary = JSON.parse_string(JSON.stringify(flags))
	_expect(BEATS.take_scene(loaded, 19, false, _always) == "race_number_three",
		"gambling branch state lost its meaning after a JSON save/load")


func _years_three_four() -> Dictionary:
	var rows: Array = []
	for raw in BEATS.ledger().get("beats", []):
		if int((raw as Dictionary).get("min_week", 0)) >= 97:
			rows.append(raw)
	return {"min_gap_weeks": 0, "beats": rows}


func _check_years_three_four() -> void:
	var data := _years_three_four()
	_expect((data["beats"] as Array).size() == 8, "years 3-4 gambling beats are not the eight authored scenes")
	var track := {"racetrack_visited": true}
	_expect(BEATS.take_scene(track.duplicate(), 100, false, _always, data, {"addiction": 55}) == "drama_addiction_mirror",
		"addiction 55 did not bring the mirror")
	_expect(BEATS.take_scene(track.duplicate(), 100, false, _always, data, {"addiction": 72}) == "race_big_win",
		"the mirror played after the rock bottom owns the run")
	var warn_only := {"min_gap_weeks": 0, "beats": (data["beats"] as Array).filter(
		func(row): return str((row as Dictionary).get("event_id", "")) == "drama_addiction_warning")}
	_expect(BEATS.take_scene(track.duplicate(), 100, false, _always, warn_only, {"addiction": 66}) == "drama_addiction_warning",
		"a living father did not notice addiction 66")
	_expect(BEATS.take_scene({"racetrack_visited": true, "father_passed": true}, 100, false, _always, warn_only,
			{"addiction": 66}) == "",
		"the father's call came after he passed")
	_expect(BEATS.take_scene({"racetrack_visited": true, "in_recovery_started": true}, 100, false, _always, data,
			{"addiction": 30}) == "",
		"a year-three win scene played during recovery")
	_expect(BEATS.take_scene({"jeongseon_session_win": true}, 120, false, _always, data, {}) == "jeongseon_big_win_urge"
			and BEATS.take_scene({"jeongseon_session_loss": true}, 120, false, _always, data, {}) == "jeongseon_big_loss_bus",
		"the Jeongseon bus scenes do not follow the last session's result")
	var race: Array = DataRegistry.find_event("race_big_win").get("choices", [])
	_expect(race.size() == 2
			and float(((race[0] as Dictionary).get("effects", {}) as Dictionary).get("money", 0.0)) == 170000.0
			and float(((race[1] as Dictionary).get("effects", {}) as Dictionary).get("money", 0.0)) == 160000.0,
		"the big race win no longer pays what its prose says (18x on 10,000 won)")
