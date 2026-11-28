extends Node
## ORDER-840 G2 regression: four fixed hold'em regulars in the full run.
## Two sit per visit (fixed by the week, never someone who left), each with a
## style and two tells; a tell's behaviour shows mostly when it is true and
## sometimes when it is not; one tell's meaning reaches the notebook every two
## counted visits; Boss Yoon asks for a loan on the stairs and stops coming;
## Ms. Han quits; the state survives a save round trip; the loan stays out of
## the session net; outside a full run the club keeps its two old strangers
## and ai_decide keeps its old odds.

const FLOW := preload("res://systems/FullStoryFlow.gd")
const REG := preload("res://systems/HoldemRegulars.gd")
const TH := preload("res://systems/TexasHoldem.gd")
const CLUB := preload("res://scenes/HoldemClub.gd")

var _failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	_check_ledger()
	_check_seating()
	_check_ai_decide()
	_check_tells()
	_check_notebook_and_stories()
	await _check_club()
	GameState.flags.erase(FLOW.STATE_KEY)
	if not _failures.is_empty():
		for failure in _failures:
			push_error("HOLDEM_REGULARS_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("HOLDEM_REGULARS_CHECK_OK regulars=%d ledger=1 seating=1 ai=1 tells=1 stories=1 club=1" % REG.ids().size())
	get_tree().quit(0)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _check_ledger() -> void:
	var styles: Array = []
	for rid in REG.ids():
		var r := REG.regular(rid)
		styles.append(str(r.get("style", "")))
		var tells: Array = r.get("tells", [])
		_expect(tells.size() == 2, "%s does not have two tells" % rid)
		var kinds: Array = []
		for k in range(tells.size()):
			kinds.append(str((tells[k] as Dictionary).get("kind", "")))
			_expect(REG.tell_seen(rid, k) != "" and REG.tell_note(rid, k) != "", "%s tell %d has no text" % [rid, k])
		_expect(kinds.has("bluff") and kinds.has("strong"), "%s does not have one bluff and one strong tell" % rid)
		_expect(REG.display_name(rid) != "?" and REG.description(rid) != "", "%s has no name or description" % rid)
	styles.sort()
	_expect(styles == ["bluffer", "builder", "counter", "stayer"], "styles are %s" % str(styles))
	var agg := func(rid: String) -> float: return float(REG.regular(rid).get("aggression", 0.0))
	_expect(agg.call("yoon_boss") > agg.call("do_manager") and agg.call("do_manager") > agg.call("han_teacher")
		and agg.call("han_teacher") > agg.call("park_driver"), "aggression does not follow the styles")
	var bluff_top := ""
	var best := -1.0
	for rid in REG.ids():
		if float(REG.regular(rid).get("bluff_rate", 0.0)) > best:
			best = float(REG.regular(rid).get("bluff_rate", 0.0))
			bluff_top = rid
	_expect(bluff_top == "do_manager", "the bluffer does not bluff most")
	var ids := REG.ids()
	_expect(ids.has(str(REG.ledger()["debt"]["regular"])) and ids.has(str(REG.ledger()["quit"]["regular"])),
		"the debt or quit story names an unknown regular")


func _check_seating() -> void:
	var flags := {}
	var seen := {}
	for turn in range(1, 41):
		var seats := REG.seat(flags, turn)
		_expect(seats.size() == 2 and seats[0] != seats[1], "W%d does not seat two different regulars" % turn)
		_expect(seats == REG.seat(flags, turn), "W%d seating is not fixed by the week" % turn)
		for rid in seats:
			seen[rid] = true
	_expect(seen.size() == 4, "not every regular sits within forty weeks")
	REG.settle_debt(flags, 100, 0)
	REG.settle_quit(flags, 110)
	for turn in range(111, 131):
		var seats := REG.seat(flags, turn)
		_expect(seats.size() == 2 and not seats.has("yoon_boss") and not seats.has("han_teacher"),
			"W%d seats someone who left: %s" % [turn, str(seats)])


func _check_ai_decide() -> void:
	var weak := [{"value": 2, "suit": 0}, {"value": 7, "suit": 1}]
	var mismatch := 0
	for i in range(200):
		var a := RandomNumberGenerator.new()
		a.seed = 1000 + i
		var b := RandomNumberGenerator.new()
		b.seed = 1000 + i
		var old := TH.ai_decide(weak, [], 30000, 10000, 500000, 0.5, a)
		var same := TH.ai_decide(weak, [], 30000, 10000, 500000, 0.5, b, 0.5 * 0.12)
		if old["action"] != same["action"] or old["amount"] != same["amount"] or a.state != b.state:
			mismatch += 1
	_expect(mismatch == 0, "the default bluff odds or rng draws changed (%d)" % mismatch)
	var bluffs := 0
	for i in range(200):
		var r := RandomNumberGenerator.new()
		r.seed = 5000 + i
		var d := TH.ai_decide(weak, [], 30000, 0, 500000, 0.5, r, 1.0)
		if bool(d.get("bluff", false)):
			bluffs += 1
		_expect(d.has("strength"), "ai_decide does not report strength")
	_expect(bluffs > 150, "a certain bluff with a weak hand is not tagged (%d/200)" % bluffs)


func _check_tells() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	var shown_true := 0
	var shown_false := 0
	for i in range(1000):
		if REG.observed_tell("do_manager", {"action": "raise", "bluff": true, "strength": 0.2}, rng) == REG.tell_seen("do_manager", 0):
			shown_true += 1
		if REG.observed_tell("do_manager", {"action": "raise", "bluff": false, "strength": 0.4}, rng) == REG.tell_seen("do_manager", 0):
			shown_false += 1
	_expect(shown_true > 700 and shown_true < 900, "a true bluff tell shows %d/1000" % shown_true)
	_expect(shown_false > 60 and shown_false < 200, "a false bluff tell shows %d/1000" % shown_false)
	_expect(REG.observed_tell("do_manager", {"action": "fold", "bluff": true}, rng) == "", "a fold shows a tell")
	var strong := 0
	for i in range(1000):
		if REG.observed_tell("park_driver", {"action": "call", "bluff": false, "strength": 0.9}, rng) == REG.tell_seen("park_driver", 0):
			strong += 1
	_expect(strong > 700, "a strong hand's tell shows %d/1000" % strong)


func _check_notebook_and_stories() -> void:
	var flags := {}
	var pair := ["yoon_boss", "han_teacher"]
	_expect(REG.record_visit(flags, pair, 2).is_empty() and REG.visits(flags, "yoon_boss") == 0,
		"a visit of two hands counts")
	_expect(REG.record_visit(flags, pair, 3).is_empty(), "the first visit writes a note")
	var second := REG.record_visit(flags, pair, 5)
	_expect(second.size() == 2 and second.has(REG.tell_note("yoon_boss", 0)), "the second visit writes %s" % str(second))
	REG.record_visit(flags, pair, 5)
	var fourth := REG.record_visit(flags, pair, 5)
	_expect(fourth.has(REG.tell_note("han_teacher", 1)) and REG.tells_known(flags, "han_teacher") == 2,
		"the fourth visit does not write the second note")
	_expect(not REG.debt_due(flags, pair, 96), "the stairs scene comes before year three")
	_expect(REG.debt_due(flags, pair, 97), "the stairs scene does not come after four visits in year three")
	_expect(not REG.debt_due(flags, ["park_driver", "do_manager"], 120), "the stairs scene comes without Boss Yoon at the table")
	_expect(not REG.quit_due(flags, pair), "Ms. Han quits before her fifth visit")
	REG.record_visit(flags, pair, 5)
	_expect(REG.quit_due(flags, pair), "Ms. Han does not quit after five visits")
	# A save writes flags as JSON; the state must read back the same.
	var round_trip: Dictionary = JSON.parse_string(JSON.stringify(flags))
	_expect(REG.visits(round_trip, "han_teacher") == 5 and REG.tells_known(round_trip, "yoon_boss") == 2,
		"the notebook does not survive a save")
	REG.settle_debt(round_trip, 100, 3_000_000)
	_expect(REG.is_gone(round_trip, "yoon_boss") and int(REG.state(round_trip)["lent"]) == 3_000_000, "the loan is not kept")
	_expect(not REG.debt_due(round_trip, pair, 120), "the stairs scene comes twice")
	_expect(not REG.debt_news_due(round_trip, 107) and REG.debt_news_due(round_trip, 108), "the news does not come eight weeks on")
	REG.mark_news_shown(round_trip)
	_expect(not REG.debt_news_due(round_trip, 140), "the news comes twice")
	REG.settle_quit(round_trip, 110)
	_expect(not REG.quit_due(round_trip, pair) and str(REG.state(round_trip)["gone"]["han_teacher"]) == "quit",
		"Ms. Han's leaving is not kept")


func _check_club() -> void:
	GameState.start_new_game()
	GameState.flags[FLOW.STATE_KEY] = {"profile": FLOW.PROFILE_FULL}
	GameState.turn = 120
	GameState.flags[REG.STATE_FLAG] = {"visits": {"yoon_boss": 4, "park_driver": 4, "do_manager": 4, "han_teacher": 4}}
	GameState.add_settled_cash(10_000_000.0 - float(GameState.money))
	# Find a week that seats Boss Yoon.
	var turn := 120
	while not REG.seat(GameState.flags, turn).has("yoon_boss"):
		turn += 1
	GameState.turn = turn
	var club: Control = CLUB.new()
	add_child(club)
	await get_tree().process_frame
	club.open()
	await get_tree().process_frame
	_expect(bool(club.get("_debt_scene_open")), "the stairs scene does not open")
	club.call("_resolve_debt", true)
	_expect(absf(float(GameState.money) - 7_000_000.0) < 1.0, "lending does not take 300만")
	_expect(REG.is_gone(GameState.flags, "yoon_boss"), "Boss Yoon still comes after the stairs")
	var seated: Array = club.get("_seated")
	_expect(seated.size() == 2 and not seated.has("yoon_boss"), "the table still seats Boss Yoon")
	var names := [str(club.call("_opp_name", 0)), str(club.call("_opp_name", 1))]
	_expect(names.has(REG.display_name(str(seated[0]))), "the seats do not carry the regulars' names: %s" % str(names))
	_expect(absf(float((club.call("get_session_summary") as Dictionary).get("net", 1.0))) < 1.0,
		"the loan counts as a gambling loss")
	club.queue_free()
	await get_tree().process_frame
	GameState.flags.erase(FLOW.STATE_KEY)
	var legacy: Control = CLUB.new()
	add_child(legacy)
	await get_tree().process_frame
	legacy.open()
	await get_tree().process_frame
	_expect((legacy.get("_seated") as Array).is_empty(), "outside a full run regulars sit")
	_expect(str(legacy.call("_opp_name", 0)) == LocaleManager.ui("조용한 남자", "Quiet Man"),
		"outside a full run the old strangers are gone")
	legacy.queue_free()
	await get_tree().process_frame
