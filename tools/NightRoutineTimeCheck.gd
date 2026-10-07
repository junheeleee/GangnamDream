extends "res://tools/ProseRecallCheck.gd"
## Two chronology consumers, prepared only: no rendered or natural-play claim.
const NIGHT := "arc_night_routine"
const NIGHT_CALLBACK := "callback_slept_early_echo"
const NIGHT_POPULATION := {"loaded": 5, "priority": 50, "route": 35,
	"direct": 5, "bridge": 5, "callback": 20}


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
	print("NIGHT_ROUTINE_TIME_CASE=" + JSON.stringify(row))


func _night_source(language: String) -> Dictionary:
	var directory: String = "events" if language == "ko" else "events_" + language
	var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(
		"res://content/%s/arc_midgame.json" % directory))
	if raw is Array:
		for event: Dictionary in raw:
			if str(event.get("id", "")) == NIGHT:
				return event
	return {}


func _night_gameplay(event: Dictionary) -> Dictionary:
	var value: Dictionary = _gameplay(event)
	for choice: Dictionary in value.get("choices", []):
		choice.erase("bridge_summary")
	return value


func _night_loaded(ko: Dictionary, source: Dictionary) -> void:
	var event: Dictionary = DataRegistry.find_event(NIGHT)
	var text_equal: bool = _source_text_matches(event, source)
	var summaries_equal: bool = true
	for index: int in range(source.get("choices", []).size()):
		summaries_equal = summaries_equal and event["choices"][index].get("bridge_summary") \
			== source["choices"][index].get("bridge_summary")
	var gameplay_equal: bool = _ordered_equal(_night_gameplay(event), _night_gameplay(ko))
	var choice: Dictionary = event["choices"][1]
	_case("loaded", NIGHT, not source.is_empty() and text_equal and summaries_equal and gameplay_equal, {
		"text_equal": text_equal, "summaries_equal": summaries_equal, "gameplay_equal": gameplay_equal,
		"result_sha256": str(choice.get("result_text", "")).sha256_text(),
		"summary_sha256": str(choice.get("bridge_summary", "")).sha256_text(),
	})


func _night_prepare(turn: int = 12) -> void:
	_prepare(turn)
	GameState.cast["hyunsu"]["met"] = true
	GameState.flags = {"arc_intro_hyunsu_seen": true}
	EventManager.narrative_bridge_results = []


func _night_priorities(game: Node) -> void:
	var rows := [
		{"label": "none", "flags": {}, "affinity": 0, "legacy": 2, "v2": 2},
		{"label": "encouraged", "flags": {"hyunsu_encouraged": true}, "affinity": 0, "legacy": 1, "v2": 1},
		{"label": "affinity", "flags": {}, "affinity": 3, "legacy": 1, "v2": 1},
		{"label": "invest_over_encouraged", "flags": {"route_invest": true, "hyunsu_encouraged": true}, "affinity": 3, "legacy": 0, "v2": 0},
		{"label": "legacy_mindset", "flags": {"mindset_investor": true, "hyunsu_encouraged": true}, "affinity": 0, "legacy": 0, "v2": 1},
	]
	for enabled: bool in [false, true]:
		for row: Dictionary in rows:
			_night_prepare()
			GameState.flags.merge(row["flags"], true)
			GameState.cast["hyunsu"]["affinity"] = int(row["affinity"])
			GameState.core_loop_v2_state = {"enabled": enabled}
			var before: Dictionary = GameState.serialize().duplicate(true)
			var selected: int = game.call("_demo_narrative_bridge_choice", NIGHT)
			var expected: int = int(row["v2"] if enabled else row["legacy"])
			_case("priority", "%s/%s" % [str(enabled), row["label"]], selected == expected
				and GameState.serialize() == before, {"v2_enabled": enabled, "flags": row["flags"],
				"affinity": row["affinity"], "actual": selected, "expected": expected,
				"state_unchanged": GameState.serialize() == before})


func _night_routes(game: Node) -> void:
	var rows := [
		{"label": "before", "turn": 11, "housing": "gosiwon", "met": true, "seen": false, "eligible": false},
		{"label": "start", "turn": 12, "housing": "gosiwon", "met": true, "seen": false, "eligible": true},
		{"label": "end", "turn": 22, "housing": "gosiwon", "met": true, "seen": false, "eligible": true},
		{"label": "after", "turn": 23, "housing": "gosiwon", "met": true, "seen": false, "eligible": false},
		{"label": "other_home", "turn": 12, "housing": "oneroom", "met": true, "seen": false, "eligible": false},
		{"label": "unmet", "turn": 12, "housing": "gosiwon", "met": false, "seen": false, "eligible": false},
		{"label": "seen", "turn": 12, "housing": "gosiwon", "met": true, "seen": true, "eligible": false},
	]
	var suppressed: Dictionary = {}
	for event: Dictionary in DataRegistry.get_all_events():
		for choice: Dictionary in event.get("choices", []):
			for flag: String in choice.get("flags", []):
				if flag.ends_with("_seen") or flag.ends_with("_done") or flag.ends_with("_closed"):
					suppressed[flag] = true
	for flag: String in ["prologue_done", "chapter_33_seen", "chapter_34_seen", "chapter_35_seen",
			"chapter_36_seen", "chapter_37_seen", "arc_daeun_met", "hyunsu_passed", "visited_father"]:
		suppressed[flag] = true
	suppressed.erase("father_passed")
	suppressed.erase("arc_father_passing_seen")
	# W11–23 preparation must not mark future year-end closures complete.
	for flag: String in ["arc_year1_close_seen", "arc_year2_close_seen",
			"arc_year3_close_seen", "arc_year4_close_seen"]:
		suppressed.erase(flag)
	for row: Dictionary in rows:
		_night_prepare(int(row["turn"]))
		GameState.flags = suppressed.duplicate(true)
		GameState.flags["arc_intro_hyunsu_seen"] = bool(row["met"])
		GameState.flags["arc_night_routine_seen"] = bool(row["seen"])
		GameState.housing = str(row["housing"])
		var before: Dictionary = GameState.serialize().duplicate(true)
		# false,false requests the existing card ingress, not auto-resolving preview.
		var selected: String = game.call("_next_arc_id", int(row["turn"]), false, false)
		_case("route", str(row["label"]), (selected == NIGHT) == bool(row["eligible"])
			and GameState.serialize() == before, {"turn": row["turn"], "housing": row["housing"],
			"intro_seen": row["met"], "seen": row["seen"], "eligible": row["eligible"],
			"actual": selected, "state_unchanged": GameState.serialize() == before})


func _night_expected() -> Dictionary:
	var expected: Dictionary = _choice_snapshot()
	expected["mental"] = 56
	expected["cast"]["hyunsu"]["affinity"] = 1
	expected["flags"]["arc_night_routine_seen"] = true
	expected["flags"]["slept_early"] = true
	return expected


func _night_choice(game: Node, story: Node, bridge: bool) -> void:
	_night_prepare()
	if bridge:
		GameState.flags["hyunsu_encouraged"] = true
	var event: Dictionary = DataRegistry.find_event(NIGHT)
	var choice: Dictionary = event["choices"][1]
	var expected: Dictionary = _night_expected()
	var available: bool = GameState.choice_available(event, choice)
	var selected: int = game.call("_demo_narrative_bridge_choice", NIGHT) if bridge else 1
	var committed: bool = EventManager.resolve_narrative_bridge(NIGHT, selected) if bridge \
		else GameState.apply_choice(event, choice)
	var receipt: Dictionary = GameState.event_log.back() if not GameState.event_log.is_empty() else {}
	var actual: Dictionary = _choice_snapshot()
	var raw_text: String = str(choice.get("bridge_summary" if bridge else "result_text", ""))
	var expected_text: String = GameState.format_event_text(raw_text).strip_edges()
	var text: String = ""
	var bridge_contract: bool = true
	if bridge:
		var results: Array = EventManager.consume_narrative_bridge_results()
		bridge_contract = results.size() == 1 and EventManager.narrative_bridge_results.is_empty()
		if results.size() == 1:
			var result: Dictionary = results[0]
			bridge_contract = bridge_contract and result.get("event_id", "") == NIGHT \
				and int(result.get("turn", -1)) == 12 and result.get("summary", "") == raw_text
			text = game.call("_narrative_bridge_summary", result)
		bridge_contract = bridge_contract and EventManager.consume_narrative_bridge_results().is_empty() \
			and int(EventManager.event_cooldowns.get(NIGHT, 0)) == 9999 \
			and EventManager.recent_event_ids.count(NIGHT) == 1
	else:
		# Actual direct result formatter, without calling UI/audio/input _choose().
		text = story.call("_fmt", raw_text)
	_case("bridge" if bridge else "direct", NIGHT, available and selected == 1 and committed
		and actual == expected and GameState.events_seen == 1 and text == expected_text
		and not text.is_empty() and bridge_contract and choice.get("effects", {}) == {"mental": 6.0}
		and str(receipt.get("event_id", "")) == NIGHT and int(receipt.get("choice_index", -1)) == 1, {
		"available": available, "selected": selected, "committed": committed,
		"expected_sha256": JSON.stringify(expected).sha256_text(),
		"actual_sha256": JSON.stringify(actual).sha256_text(), "snapshot_equal": actual == expected,
		"mental": GameState.mental, "affinity": GameState.get_cast_affinity("hyunsu"),
		"seen": GameState.flags.get("arc_night_routine_seen", false),
		"slept_early": GameState.flags.get("slept_early", false), "events_seen": GameState.events_seen,
		"receipt_index": receipt.get("choice_index", -1), "bridge_contract": bridge_contract,
		"expected_text_sha256": expected_text.sha256_text(), "actual_text_sha256": text.sha256_text()})


func _night_callbacks() -> void:
	var event: Dictionary = DataRegistry.find_event(NIGHT_CALLBACK)
	var conditions: Dictionary = event.get("conditions", {})
	for turn: int in [39, 40]:
		for slept: bool in [false, true]:
			_night_prepare(turn)
			GameState.flags["slept_early"] = slept
			var before: Dictionary = GameState.serialize().duplicate(true)
			var available: bool = EventManager.call("_check_conditions", conditions)
			_case("callback", "%d/%s" % [turn, str(slept)], not event.is_empty()
				and conditions == {"flag": "slept_early", "min_turn": 40.0}
				and available == (slept and turn >= 40) and GameState.serialize() == before, {
				"reader": NIGHT_CALLBACK, "turn": turn, "slept_early": slept,
				"actual": available, "expected": slept and turn >= 40,
				"conditions": conditions, "state_unchanged": GameState.serialize() == before})


func _run() -> void:
	var namespace475: String = OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	if not namespace475.begins_with("GangnamDream_StoryNameplateQA_") \
			or OS.get_user_data_dir().get_file() != namespace475:
		push_error("NIGHT_ROUTINE_TIME_CHECK_FAIL pre-autoload isolation missing")
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
	var story: Node = STORY.new()
	var ko: Dictionary = _night_source("ko")
	for language: String in LOCALES:
		LocaleManager.language = language
		DataRegistry.reload()
		_night_loaded(ko, _night_source(language))
		_night_priorities(game)
		_night_routes(game)
		_night_choice(game, story, false)
		_night_choice(game, story, true)
		_night_callbacks()
	story.free()
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
	print("NIGHT_ROUTINE_TIME_RESTORED=" + JSON.stringify(restored))
	if not restored:
		failures.append("singleton restoration failed")
	if counts != NIGHT_POPULATION or case_ids.size() != 120:
		failures.append("case population drift: " + JSON.stringify(counts))
	print("NIGHT_ROUTINE_TIME_POPULATION=" + JSON.stringify(counts))
	if not failures.is_empty():
		for failure: String in failures:
			push_error("NIGHT_ROUTINE_TIME_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("NIGHT_ROUTINE_TIME_CHECK_OK locales=5 cases=120 loaded=5 priority=50 route=35 direct=5 bridge=5 callback=20 prepared_component_only=true")
	get_tree().quit(0)
