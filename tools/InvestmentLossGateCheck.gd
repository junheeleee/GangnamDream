extends "res://tools/ProseRecallCheck.gd"
## Prepared current-state consumers; not a rendered or naturally played route.
const LOSS := "arc_invest_first_loss"
const INVESTMENT := preload("res://systems/InvestmentSystem.gd")
const LOSS_FLAGS := ["cut_loss_first", "held_through_loss", "averaged_down"]
const LOSS_READERS := ["callback_cut_loss_first_echo", "callback_held_through_loss_echo",
	"callback_averaged_down_echo"]
const LOSS_POPULATION := {"loaded": 5, "helper": 210, "route": 90,
	"competition": 30, "live": 15, "producer": 20, "callback": 60}

func _case(group: String, label: String, passed: bool, details: Dictionary) -> void:
	var identifier: String = "%s/%s/%s" % [group, LocaleManager.language, label]
	if case_ids.has(identifier):
		failures.append("duplicate case " + identifier)
	case_ids[identifier] = true
	counts[group] = int(counts.get(group, 0)) + 1
	if not passed:
		failures.append(identifier + " " + JSON.stringify(details))
	var row: Dictionary = details.duplicate(true)
	row.merge({"id": identifier, "group": group, "locale": LocaleManager.language,
		"passed": passed}, true)
	print("INVESTMENT_LOSS_GATE_CASE=" + JSON.stringify(row))

func _state_bytes() -> PackedByteArray:
	return var_to_bytes(GameState.serialize())

func _loss_prepare(turn: int = 15) -> void:
	_prepare(turn)
	GameState.market_prices = {}
	GameState.investment_skill = 5
	var suppressed: Dictionary = {}
	for event: Dictionary in DataRegistry.get_all_events():
		for choice: Dictionary in event.get("choices", []):
			for flag: String in choice.get("flags", []):
				if flag.ends_with("_seen") or flag.ends_with("_done") or flag.ends_with("_closed"):
					suppressed[flag] = true
	for flag: String in ["prologue_done", "chapter_33_seen", "arc_daeun_met",
			"hyunsu_passed", "visited_father", "cafe_callback_seen"]:
		suppressed[flag] = true
	for flag: String in ["father_passed", "arc_father_passing_seen", "arc_year1_close_seen",
			"arc_year2_close_seen", "arc_year3_close_seen", "arc_year4_close_seen"]:
		suppressed.erase(flag)
	GameState.flags = suppressed
	GameState.flags["arc_invest_guidance_seen"] = true
	GameState.flags["arc_invest_first_loss_seen"] = false
	GameState.portfolio = {"samsung": {"quantity": 1.0, "avg_price": 70000.0}}
	GameState.market_prices = {"samsung": 63000.0}
	EventManager.narrative_bridge_results = []

func _loss_loaded() -> void:
	var source: Dictionary = _source_events(LocaleManager.language).get(LOSS, {})
	var event: Dictionary = DataRegistry.find_event(LOSS)
	var flags: Array = []
	for choice: Dictionary in event.get("choices", []):
		flags.append(choice.get("flags", []))
	_case("loaded", LOSS, not source.is_empty() and _source_text_matches(event, source)
		and flags == [["arc_invest_first_loss_seen", "cut_loss_first"],
			["arc_invest_first_loss_seen", "held_through_loss"],
			["arc_invest_first_loss_seen", "averaged_down"]],
		{"text_equal": _source_text_matches(event, source), "flags": flags,
		"source_description_sha256": str(source.get("description", "")).sha256_text()})

func _helper_case(game: Node, label: String, expected: bool) -> void:
	var before: PackedByteArray = _state_bytes()
	var actual: bool = game.call("_has_current_investment_loss")
	_case("helper", label, actual == expected and _state_bytes() == before,
		{"actual": actual, "expected": expected, "state_unchanged": _state_bytes() == before})

func _loss_helpers(game: Node) -> void:
	var rows := [
		{"id": "empty", "holdings": {}, "prices": {}, "expected": false},
		{"id": "quote_only", "holdings": {}, "prices": {"samsung": 63000.0}, "expected": false},
		{"id": "historical_flag", "holdings": {}, "prices": {}, "expected": false},
		{"id": "break_even", "holdings": {"samsung": {"quantity": 1.0, "avg_price": 70000.0}}, "prices": {"samsung": 70000.0}, "expected": false},
		{"id": "profit", "holdings": {"samsung": {"quantity": 1.0, "avg_price": 70000.0}}, "prices": {"samsung": 71000.0}, "expected": false},
		{"id": "loss", "holdings": {"samsung": {"quantity": 1.0, "avg_price": 70000.0}}, "prices": {"samsung": 63000.0}, "expected": true},
		{"id": "fractional", "holdings": {"samsung": {"quantity": 0.00001, "avg_price": 70000.0}}, "prices": {"samsung": 69999.0}, "expected": true},
		{"id": "integer_loss", "holdings": {"samsung": {"quantity": 1, "avg_price": 70000}}, "prices": {"samsung": 63000}, "expected": true},
		{"id": "mixed", "holdings": {"samsung": {"quantity": 1.0, "avg_price": 70000.0}, "nvidia": {"quantity": 100.0, "avg_price": 820000.0}}, "prices": {"samsung": 63000.0, "nvidia": 892000.0}, "expected": true},
		{"id": "mixed_reverse", "holdings": {"nvidia": {"quantity": 100.0, "avg_price": 820000.0}, "samsung": {"quantity": 1.0, "avg_price": 70000.0}}, "prices": {"samsung": 63000.0, "nvidia": 892000.0}, "expected": true},
		{"id": "unknown_asset", "holdings": {"not_registered_476": {"quantity": 1.0, "avg_price": 70000.0}}, "prices": {"not_registered_476": 63000.0}, "expected": false},
		{"id": "missing_quote", "holdings": {"samsung": {"quantity": 1.0, "avg_price": 70000.0}}, "prices": {}, "expected": false},
		{"id": "holding_null", "holdings": {"samsung": null}, "prices": {"samsung": 63000.0}, "expected": false},
		{"id": "holding_array", "holdings": {"samsung": []}, "prices": {"samsung": 63000.0}, "expected": false},
		{"id": "holding_string", "holdings": {"samsung": "held"}, "prices": {"samsung": 63000.0}, "expected": false},
	]
	for row: Dictionary in rows:
		_loss_prepare()
		GameState.portfolio = row["holdings"].duplicate(true)
		GameState.market_prices = row["prices"].duplicate(true)
		if row["id"] == "historical_flag":
			GameState.flags["had_first_investment"] = true
		_helper_case(game, row["id"], row["expected"])
	var invalid := [null, 0, -1, "1", true, NAN, INF, -INF, []]
	for field: String in ["quantity", "avg_price", "price"]:
		for index: int in range(invalid.size()):
			_loss_prepare()
			if field == "price":
				GameState.market_prices["samsung"] = invalid[index]
			else:
				GameState.portfolio["samsung"][field] = invalid[index]
			_helper_case(game, "%s/invalid%d" % [field, index], false)

func _loss_routes(game: Node) -> void:
	var rows := [
		{"id": "before", "turn": 14, "expected": false},
		{"id": "start", "turn": 15, "expected": true},
		{"id": "end", "turn": 18, "expected": true},
		{"id": "after", "turn": 19, "expected": false},
		{"id": "no_guidance", "turn": 15, "expected": false},
		{"id": "skill4", "turn": 15, "expected": false},
		{"id": "seen", "turn": 15, "expected": false},
		{"id": "sold", "turn": 15, "expected": false},
		{"id": "profit", "turn": 15, "expected": false},
	]
	for row: Dictionary in rows:
		for preview: bool in [false, true]:
			_loss_prepare(row["turn"])
			match row["id"]:
				"no_guidance": GameState.flags["arc_invest_guidance_seen"] = false
				"skill4": GameState.investment_skill = 4
				"seen": GameState.flags["arc_invest_first_loss_seen"] = true
				"sold": GameState.portfolio = {}
				"profit": GameState.market_prices["samsung"] = 71000.0
			var before: PackedByteArray = _state_bytes()
			var actual: String = game.call("_next_arc_id", row["turn"], preview, false)
			_case("route", "%s/%s" % [row["id"], preview], (actual == LOSS) == row["expected"]
				and _state_bytes() == before, {"actual": actual, "expected_loss": row["expected"],
				"turn": row["turn"], "preview": preview, "state_unchanged": _state_bytes() == before})

func _loss_competition(game: Node) -> void:
	for mode: String in ["paycheck_card", "paycheck_preview", "paycheck_bridge", "profit_fallback", "father_card", "father_preview"]:
		_loss_prepare()
		var expected := LOSS
		if mode.begins_with("paycheck"):
			GameState.current_job = {"id": "job_01", "category": "survival"}
			GameState.flags["has_received_paycheck"] = true
			GameState.flags["arc_paycheck_reality_seen"] = false
			if mode == "paycheck_card": expected = "arc_paycheck_reality"
		elif mode == "profit_fallback":
			GameState.money = 50000000.0
			GameState.market_prices["samsung"] = 71000.0
			GameState.flags["arc_first_real_win_seen"] = false
			expected = "arc_first_real_win"
		else:
			GameState.flags["arc_intro_dad_seen"] = false
			expected = "arc_intro_02_dad_call"
		var before: PackedByteArray = _state_bytes()
		var holdings_before: PackedByteArray = var_to_bytes(GameState.portfolio)
		var prices_before: PackedByteArray = var_to_bytes(GameState.market_prices)
		var flags_before: Array = []
		for flag: String in LOSS_FLAGS: flags_before.append(GameState.flags.get(flag, false))
		var actual: String = game.call("_next_arc_id", 15, mode.ends_with("preview"), mode == "paycheck_bridge")
		var mutation_ok: bool = _state_bytes() == before
		if mode == "paycheck_bridge":
			mutation_ok = GameState.flags.get("arc_paycheck_reality_seen", false) \
				and not GameState.flags.get("arc_invest_first_loss_seen", false) \
				and EventManager.narrative_bridge_results.size() == 1 \
				and var_to_bytes(GameState.portfolio) == holdings_before \
				and var_to_bytes(GameState.market_prices) == prices_before
			for index: int in range(LOSS_FLAGS.size()):
				mutation_ok = mutation_ok and GameState.flags.get(LOSS_FLAGS[index], false) == flags_before[index]
		_case("competition", mode, actual == expected and mutation_ok,
			{"actual": actual, "expected": expected, "allowed_bridge_mutation": mode == "paycheck_bridge",
			"state_contract": mutation_ok})

func _loss_live(game: Node) -> void:
	for transition: String in ["recovered", "became_loss", "sold_after_preview"]:
		_loss_prepare()
		if transition == "became_loss": GameState.market_prices["samsung"] = 70000.0
		var before: PackedByteArray = _state_bytes()
		var preview: String = game.call("_next_arc_id", 15, true, false)
		var preview_pure: bool = _state_bytes() == before
		if transition == "recovered": GameState.market_prices["samsung"] = 70000.0
		elif transition == "became_loss": GameState.market_prices["samsung"] = 63000.0
		else: GameState.portfolio = {}
		before = _state_bytes()
		var actual: String = game.call("_next_arc_id", 15, false, false)
		_case("live", transition, preview_pure and _state_bytes() == before
			and (preview == LOSS) == (transition != "became_loss")
			and (actual == LOSS) == (transition == "became_loss"),
			{"preview": preview, "actual": actual, "preview_pure": preview_pure,
			"current_state_pure": _state_bytes() == before})

func _loss_producer(game: Node) -> void:
	var investment: Node = INVESTMENT.new()
	_loss_prepare()
	GameState.money = 2000000.0
	GameState.portfolio = {}
	GameState.market_prices = {"samsung": 70000.0}
	var bought: Dictionary = investment.buy_asset("samsung", 140000.0)
	var quantity: float = float(GameState.portfolio.get("samsung", {}).get("quantity", 0.0))
	_case("producer", "buy_break_even", bought.get("success", false) and quantity > 0.0
		and not game.call("_has_current_investment_loss"), {"success": bought.get("success", false), "quantity": quantity})
	GameState.market_prices["samsung"] = 63000.0
	_case("producer", "quote_loss", game.call("_has_current_investment_loss"), {"price": 63000.0})
	var partial: Dictionary = investment.sell_asset("samsung", 0.5)
	_case("producer", "partial_sell", partial.get("success", false) and game.call("_has_current_investment_loss")
		and is_equal_approx(float(GameState.portfolio["samsung"]["quantity"]), quantity / 2.0), {"success": partial.get("success", false)})
	var sold: Dictionary = investment.sell_asset("samsung", 1.0)
	_case("producer", "full_sell", sold.get("success", false) and GameState.portfolio.is_empty()
		and GameState.flags.get("had_first_investment", false) and not game.call("_has_current_investment_loss"),
		{"success": sold.get("success", false), "historical_flag": GameState.flags.get("had_first_investment", false)})
	investment.free()

func _loss_callbacks() -> void:
	for index: int in range(3):
		for turn: int in [35, 36]:
			for retained: bool in [false, true]:
				_loss_prepare(15)
				var event: Dictionary = DataRegistry.find_event(LOSS)
				var committed: bool = GameState.apply_choice(event, event["choices"][index])
				var produced: bool = GameState.flags.get(LOSS_FLAGS[index], false)
				GameState.turn = turn
				if not retained: GameState.flags.erase(LOSS_FLAGS[index])
				var callback: Dictionary = DataRegistry.find_event(LOSS_READERS[index])
				var before: PackedByteArray = _state_bytes()
				var actual: bool = EventManager.call("_check_conditions", callback.get("conditions", {}))
				_case("callback", "%d/%d/%s" % [index, turn, retained], committed and produced
					and actual == (retained and turn >= 36) and _state_bytes() == before,
					{"reader": LOSS_READERS[index], "flag": LOSS_FLAGS[index], "turn": turn,
					"prepared_choice_turn": 15,
					"retained": retained, "actual": actual, "produced": produced,
					"state_unchanged": _state_bytes() == before})

func _run() -> void:
	var namespace476: String = OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	if not namespace476.begins_with("GangnamDream_StoryNameplateQA_") \
			or OS.get_user_data_dir().get_file() != namespace476:
		push_error("INVESTMENT_LOSS_GATE_CHECK_FAIL pre-autoload isolation missing")
		get_tree().quit(1)
		return
	print("STORY_NAMEPLATE_QA_USER_DIR=" + OS.get_user_data_dir())
	initial_game = GameState.serialize().duplicate(true)
	initial_transients = _snapshot_properties(GameState, TRANSIENTS)
	initial_events = _snapshot_properties(EventManager, EVENT_STATE)
	var old_meta: Dictionary = MetaProgression.data.duplicate(true)
	var old_unlocks: Dictionary = MetaProgression.get("_new_this_run").duplicate(true)
	var old_language: String = LocaleManager.language
	var game: Node = MAIN.new()
	game.set_meta("_screenshot_qa_static_surface", true)
	for language: String in LOCALES:
		LocaleManager.language = language
		DataRegistry.reload()
		_loss_loaded()
		_loss_helpers(game)
		_loss_routes(game)
		_loss_competition(game)
		_loss_live(game)
		_loss_producer(game)
		_loss_callbacks()
	game.free()
	LocaleManager.language = old_language
	DataRegistry.reload()
	_restore_properties(GameState, initial_game)
	_restore_properties(GameState, initial_transients)
	_restore_properties(EventManager, initial_events)
	MetaProgression.data = old_meta.duplicate(true)
	MetaProgression.set("_new_this_run", old_unlocks.duplicate(true))
	var restored: bool = GameState.serialize() == initial_game \
		and _snapshot_properties(GameState, TRANSIENTS) == initial_transients \
		and _snapshot_properties(EventManager, EVENT_STATE) == initial_events \
		and MetaProgression.data == old_meta and MetaProgression.get("_new_this_run") == old_unlocks \
		and LocaleManager.language == old_language
	print("INVESTMENT_LOSS_GATE_RESTORED=" + JSON.stringify(restored))
	if not restored: failures.append("singleton restoration failed")
	if counts != LOSS_POPULATION or case_ids.size() != 430:
		failures.append("case population drift: " + JSON.stringify(counts))
	print("INVESTMENT_LOSS_GATE_POPULATION=" + JSON.stringify(counts))
	if not failures.is_empty():
		for failure: String in failures: push_error("INVESTMENT_LOSS_GATE_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("INVESTMENT_LOSS_GATE_CHECK_OK locales=5 cases=430 loaded=5 helper=210 route=90 competition=30 live=15 producer=20 callback=60 prepared_component_only=true")
	get_tree().quit(0)
