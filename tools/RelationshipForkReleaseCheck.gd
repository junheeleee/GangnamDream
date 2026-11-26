extends Node
## M22 relationship fork: a player who lets Daeun go still meets Jiyeon's offer
## inside M22 (user decision 2026-11-26). Before this, releasing Daeun closed
## both doors and Jiyeon's romance started in 0/18 D1 runs. Daeun's parting
## scenes play first; holding Daeun, an unknown Jiyeon or a spent offer stay shut.

const MAIN := preload("res://scenes/MainGame.gd")
const OFFER := "arc_jiyeon_03_offer"

var _failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	var game: Node = MAIN.new()
	_case(game, "parting first", 86, {}, "")
	_case(game, "after regret", 87, {"arc_daeun_ghost_seen": true, "arc_daeun_regret_seen": true}, OFFER)
	_case(game, "last M22 week", 88, {"arc_daeun_ghost_seen": true}, OFFER)
	_case(game, "held Daeun", 88, {"daeun_let_her_go": false, "daeun_chose_her": true,
		"arc_daeun_regret_seen": true}, "")
	_case(game, "never met at store", 88, {"arc_jiyeon_store_seen": false, "arc_daeun_regret_seen": true}, "")
	_case(game, "offer already seen", 88, {"arc_jiyeon_offer_seen": true, "arc_daeun_regret_seen": true}, "")
	_case(game, "after M22", 89, {"arc_daeun_regret_seen": true}, "")
	game.free()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("RELATIONSHIP_FORK_RELEASE_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("RELATIONSHIP_FORK_RELEASE_CHECK_OK cases=7")
	get_tree().quit(0)


func _case(game: Node, label: String, turn: int, overrides: Dictionary, expected: String) -> void:
	GameState.start_new_game()
	var flags := {
		"arc_jiyeon_crash_seen": true, "arc_jiyeon_store_seen": true,
		"arc_daeun_regular_seen": true, "arc_daeun_fork_seen": true,
		"arc_daeun_fork_receipt_seen": true, "daeun_let_her_go": true,
	}
	flags.merge(overrides, true)
	for key in flags.keys():
		GameState.flags[key] = flags[key]
	GameState.turn = turn
	var actual := str(game.call("_story_graph_contract_event_id", turn, GameState.flags, false))
	if actual != expected:
		_failures.append("%s: W%d routed %s, expected %s" % [label, turn,
			actual if not actual.is_empty() else "(none)", expected if not expected.is_empty() else "(none)"])
