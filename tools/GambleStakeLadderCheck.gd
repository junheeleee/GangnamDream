extends Node
## ORDER-840 G1 regression: the stakes grow with the run. In a full run the
## racetrack stakes and hold'em buy-ins/blinds come from the highest open tier
## of gamble_stake_ledger (turn, story flags, habit visits, cash) and are fixed
## when the table opens; outside a full run the tables keep their fixed lists.

const FLOW := preload("res://systems/FullStoryFlow.gd")
const LADDER := preload("res://systems/GambleStakeLadder.gd")
const TRACK := preload("res://scenes/RaceTrack.gd")
const CLUB := preload("res://scenes/HoldemClub.gd")

var _failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	_check_tiers()
	await _check_tables()
	GameState.flags.erase(FLOW.STATE_KEY)
	if not _failures.is_empty():
		for failure in _failures:
			push_error("GAMBLE_STAKE_LADDER_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("GAMBLE_STAKE_LADDER_CHECK_OK tiers=%d gates=5 tables=1 legacy=1" % (LADDER.ledger().get("tiers", []) as Array).size())
	get_tree().quit(0)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _visits(n: int) -> Dictionary:
	return {"branch_habit_state": {"visits": {"holdem": n, "racetrack": n}}}


func _check_tiers() -> void:
	_expect(LADDER.tier("holdem", {}, 1, 500000.0).get("id", "") == "entry", "W1 is not the entry tier")
	_expect(LADDER.tier("holdem", _visits(3), 60, 5_000_000.0).get("id", "") == "entry",
		"the regular tier opens before four visits")
	_expect(LADDER.tier("holdem", _visits(4), 60, 5_000_000.0).get("id", "") == "regular",
		"four visits in year 2 do not open the regular tier")
	var invited := _visits(4)
	invited["casino_club_introduced"] = true
	_expect(LADDER.tier("holdem", invited, 100, 10_000_000.0).get("id", "") == "regular",
		"the high-stakes room opens without the cash")
	_expect(LADDER.tier("holdem", invited, 100, 30_000_000.0).get("id", "") == "high_stakes",
		"Sangchul's introduction, year 3 and the cash do not open the high-stakes room")
	_expect(LADDER.holdem_blind_scale(invited, 100, 30_000_000.0) == 10, "the high-stakes blinds are not ten times")


func _check_tables() -> void:
	GameState.start_new_game()
	GameState.flags[FLOW.STATE_KEY] = {"profile": FLOW.PROFILE_FULL}
	GameState.flags["casino_club_introduced"] = true
	GameState.flags["branch_habit_state"] = {"visits": {"holdem": 5, "racetrack": 5}}
	GameState.turn = 110
	GameState.add_settled_cash(40_000_000.0 - float(GameState.money))
	var track: Control = TRACK.new()
	add_child(track)
	await get_tree().process_frame
	track.open()
	_expect((track.get("_session_stakes") as Array).has(3000000), "the full-run track does not use the ladder")
	GameState.add_settled_cash(1_000_000.0 - float(GameState.money))
	_expect((track.get("_session_stakes") as Array).has(3000000), "the track's stakes changed mid-visit")
	track.queue_free()
	GameState.add_settled_cash(40_000_000.0 - float(GameState.money))
	var club: Control = CLUB.new()
	add_child(club)
	await get_tree().process_frame
	club.call("_apply_stake_ladder")
	_expect((club.get("_session_buyins") as Array).has(10000000) and int(club.call("_big_blind")) == 100000,
		"the full-run club does not open the high-stakes room")
	club.queue_free()
	GameState.flags.erase(FLOW.STATE_KEY)
	var legacy: Control = CLUB.new()
	add_child(legacy)
	await get_tree().process_frame
	legacy.call("_apply_stake_ladder")
	_expect((legacy.get("_session_buyins") as Array) == CLUB.VALID_BUYINS and int(legacy.call("_big_blind")) == 10000,
		"outside a full run the club no longer uses its fixed buy-ins")
	legacy.queue_free()
	await get_tree().process_frame
