extends "res://tools/ProseRecallCheck.gd"
## Exact prepared choice/result consumers only, not natural play or rendered UI.
const HOLD_EVENT := "arc_invest_first_loss"
const HOLD_READER := "callback_held_through_loss_echo"
const HOLD_POPULATION := {"loaded": 5, "formatted": 5, "producer": 5,
	"record": 5, "callback": 20}

func _case(group: String, label: String, passed: bool, details: Dictionary) -> void:
	var identifier: String = "%s/%s/%s" % [group, LocaleManager.language, label]
	if case_ids.has(identifier): failures.append("duplicate case " + identifier)
	case_ids[identifier] = true
	counts[group] = int(counts.get(group, 0)) + 1
	if not passed: failures.append(identifier + " " + JSON.stringify(details))
	var row: Dictionary = details.duplicate(true)
	row.merge({"id": identifier, "group": group, "locale": LocaleManager.language,
		"passed": passed}, true)
	print("INVESTMENT_LOSS_HOLD_CASE=" + JSON.stringify(row))

func _unchanged_facts() -> Dictionary:
	return {"turn": GameState.turn, "age": GameState.age, "year": GameState.year,
		"month": GameState.month, "week": GameState.week_of_month,
		"money": GameState.money, "portfolio": GameState.portfolio.duplicate(true),
		"prices": GameState.market_prices.duplicate(true)}

func _hold_consumers() -> void:
	_prepare(15)
	GameState.portfolio = {"samsung": {"quantity": 1.0, "avg_price": 70000.0}}
	GameState.market_prices = {"samsung": 63000.0}
	var source: Dictionary = _source_events(LocaleManager.language).get(HOLD_EVENT, {})
	var event: Dictionary = DataRegistry.find_event(HOLD_EVENT)
	var choice: Dictionary = event.get("choices", [])[1]
	var authored: String = str(source.get("choices", [])[1].get("result_text", ""))
	var raw: String = str(choice.get("result_text", ""))
	_case("loaded", HOLD_EVENT, not authored.is_empty() and raw == authored
		and _source_text_matches(event, source) and raw.split("\n\n").size() == 3
		and raw.count("{name}") == 1,
		{"current_source_sha256": authored.sha256_text(), "loaded_sha256": raw.sha256_text(),
		"paragraphs": raw.split("\n\n").size(), "tokens": raw.count("{name}")})
	var story: Node = STORY.new()
	var state_before: PackedByteArray = var_to_bytes(GameState.serialize())
	var formatted: String = story.call("_fmt", raw)
	story.free()
	var expected: String = raw.replace("{name}", GameState.player_name)
	_case("formatted", "StoryMode", formatted == expected and not formatted.contains("{name}")
		and var_to_bytes(GameState.serialize()) == state_before,
		{"actual_sha256": formatted.sha256_text(), "expected_sha256": expected.sha256_text(),
		"state_unchanged": var_to_bytes(GameState.serialize()) == state_before})
	var facts_before: Dictionary = _unchanged_facts()
	var log_count: int = GameState.event_log.size()
	var events_before: int = GameState.events_seen
	var skill_before: int = GameState.investment_skill
	var mental_before: int = GameState.mental
	var applied: bool = GameState.apply_choice(event, choice)
	_case("producer", "hold", applied and choice.get("effects", {}) == {"investment_skill": 3.0, "mental": -3.0}
		and choice.get("flags", []) == ["arc_invest_first_loss_seen", "held_through_loss"]
		and GameState.investment_skill == skill_before + 3 and GameState.mental == mental_before - 3
		and GameState.flags.get("arc_invest_first_loss_seen", false)
		and GameState.flags.get("held_through_loss", false)
		and not GameState.flags.get("cut_loss_first", false)
		and not GameState.flags.get("averaged_down", false)
		and _unchanged_facts() == facts_before,
		{"applied": applied, "skill_delta": GameState.investment_skill - skill_before,
		"mental_delta": GameState.mental - mental_before,
		"portfolio_quote_calendar_cash_unchanged": _unchanged_facts() == facts_before})
	var receipt: Dictionary = GameState.event_log.back() if not GameState.event_log.is_empty() else {}
	_case("record", "event_log", applied and GameState.event_log.size() == log_count + 1
		and GameState.events_seen == events_before + 1 and receipt.get("event_id", "") == HOLD_EVENT
		and receipt.get("choice_index", -1) == 1 and receipt.get("turn", -1) == 15
		and receipt.get("result", "") == formatted
		and receipt.get("choice", "") == GameState.format_event_text(str(choice.get("text", ""))),
		{"event_id": receipt.get("event_id", ""), "choice_index": receipt.get("choice_index", -1),
		"result_sha256": str(receipt.get("result", "")).sha256_text(),
		"formatted_sha256": formatted.sha256_text(), "turn": receipt.get("turn", -1)})
	var reader: Dictionary = DataRegistry.find_event(HOLD_READER)
	for turn: int in [35, 36]:
		for retained: bool in [false, true]:
			GameState.turn = turn
			if retained: GameState.flags["held_through_loss"] = true
			else: GameState.flags.erase("held_through_loss")
			var before: PackedByteArray = var_to_bytes(GameState.serialize())
			var actual: bool = EventManager.call("_check_conditions", reader.get("conditions", {}))
			_case("callback", "%d/%s" % [turn, retained], not reader.is_empty()
				and reader.get("conditions", {}) == {"flag": "held_through_loss", "min_turn": 36.0}
				and actual == (retained and turn >= 36) and var_to_bytes(GameState.serialize()) == before,
				{"reader": HOLD_READER, "turn": turn, "retained": retained, "actual": actual,
				"prepared_choice_turn": 15, "quote": GameState.market_prices["samsung"],
				"state_unchanged": var_to_bytes(GameState.serialize()) == before})

func _run() -> void:
	var namespace477: String = OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	if not namespace477.begins_with("GangnamDream_StoryNameplateQA_") \
			or OS.get_user_data_dir().get_file() != namespace477:
		push_error("INVESTMENT_LOSS_HOLD_CHECK_FAIL pre-autoload isolation missing")
		get_tree().quit(1)
		return
	print("STORY_NAMEPLATE_QA_USER_DIR=" + OS.get_user_data_dir())
	initial_game = GameState.serialize().duplicate(true)
	initial_transients = _snapshot_properties(GameState, TRANSIENTS)
	initial_events = _snapshot_properties(EventManager, EVENT_STATE)
	var old_meta: Dictionary = MetaProgression.data.duplicate(true)
	var old_unlocks: Dictionary = MetaProgression.get("_new_this_run").duplicate(true)
	var old_language: String = LocaleManager.language
	for language: String in LOCALES:
		LocaleManager.language = language
		DataRegistry.reload()
		_hold_consumers()
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
	print("INVESTMENT_LOSS_HOLD_RESTORED=" + JSON.stringify(restored))
	if not restored: failures.append("singleton restoration failed")
	if counts != HOLD_POPULATION or case_ids.size() != 40:
		failures.append("case population drift: " + JSON.stringify(counts))
	print("INVESTMENT_LOSS_HOLD_POPULATION=" + JSON.stringify(counts))
	if not failures.is_empty():
		for failure: String in failures: push_error("INVESTMENT_LOSS_HOLD_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("INVESTMENT_LOSS_HOLD_CHECK_OK locales=5 cases=40 loaded=5 formatted=5 producer=5 record=5 callback=20 prepared_component_only=true")
	get_tree().quit(0)
