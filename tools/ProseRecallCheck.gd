extends Node
## Bounded prepared consumers only: not a natural route, replay, or rendered UI.
## Run through StoryNameplateBootstrap's pre-autoload isolated namespace only.
const MAIN := preload("res://scenes/MainGame.gd")
const STORY := preload("res://scenes/StoryMode.gd")
const FINALE := preload("res://systems/Chapter5FinaleRoute.gd")
const LOCALES := ["ko", "en", "ja", "zh-CN", "zh-TW"]
const FILES := ["arc_midgame.json", "arc_year_close.json", "arc_hyunsu.json",
	"arc_daeun_extension.json", "arc_chapter_themes.json"]
const YEAR_ONE := "arc_year_one_mark"
const YEAR_TWO := "arc_year2_close"
const HYUNSU := "hyunsu_year5_call"
const HYUNSU_PASSED := "hyunsu_year5_call_father_passed"
const ENDING := "arc_daeun_year5_ending"
const APART := "arc_daeun_year5_apart"
const DAEUN_READER := "arc_y4_body_witness"
const HYUNSU_READER := "arc_y4_body_witness_hyunsu"
const TARGETS := [YEAR_ONE, YEAR_TWO, HYUNSU, HYUNSU_PASSED, ENDING, APART,
	DAEUN_READER, HYUNSU_READER]
const BODY_KEYS := {
	YEAR_ONE: ["m4_housing_priority_runway", "m4_housing_priority_privacy",
		"m4_housing_priority_time"],
	YEAR_TWO: ["y2_lease_renewed_one_year", "y2_lease_renewed_six_months",
		"y2_lease_move_out_scheduled", "year1_resolve", "year1_numb",
		"jaehyuk_stood_up", "chose_money_over_father", "crossed_line"],
	HYUNSU: ["crossed_line", "called_hyunsu_first"],
	HYUNSU_PASSED: ["crossed_line", "called_hyunsu_first"],
	ENDING: ["daeun_married", "daeun_year4_close", "daeun_romance_started"],
	APART: [],
}
const BODY_TURNS := {YEAR_ONE: 49, YEAR_TWO: 96, HYUNSU: 200,
	HYUNSU_PASSED: 200, ENDING: 193, APART: 193}
const PERSON_MEMORY := "arc_y4_missed_cost_seen&arc_y4_missed_cost_repaired_person"
const REPAIR_FLAGS := ["arc_y4_missed_cost_seen", "arc_36_unexpected_hand_seen",
	"arc_y4_missed_cost_repaired_person", "accepted_grace"]
const PRODUCERS := [
	{"id": "arc_36_unexpected_hand", "choice": 1, "missed": "father"},
	{"id": "arc_36_unexpected_hand_person_deal", "choice": 0, "missed": "deal"},
]
const POPULATION := {"loaded": 40, "body": 185, "memory": 50, "choice": 14,
	"route": 36, "father": 6, "callback": 3, "followup": 3}
const TRANSIENTS := ["pending_story_queue", "story_return_scene", "returning_from_story",
	"pending_tint_vignette", "pending_scar_vignette"]
const EVENT_STATE := ["pending_events", "current_event", "event_cooldowns",
	"recent_event_ids", "narrative_bridge_results"]
var failures: Array[String] = []
var counts: Dictionary = {}
var case_ids: Dictionary = {}
var initial_game: Dictionary = {}
var initial_transients: Dictionary = {}
var initial_events: Dictionary = {}
var closed_flags: Dictionary = {}


func _ready() -> void:
	call_deferred("_run")


func _copy(value: Variant) -> Variant:
	return value.duplicate(true) if value is Dictionary or value is Array else value


func _snapshot_properties(owner: Object, keys: Array) -> Dictionary:
	var result: Dictionary = {}
	for key: String in keys:
		result[key] = _copy(owner.get(key))
	return result


func _restore_properties(owner: Object, snapshot: Dictionary) -> void:
	for key: String in snapshot:
		owner.set(key, _copy(snapshot[key]))


func _case(group: String, label: String, passed: bool, details: Dictionary) -> void:
	var case_id: String = "%s/%s/%s" % [group, LocaleManager.language, label]
	if case_ids.has(case_id):
		failures.append("duplicate case " + case_id)
	case_ids[case_id] = true
	counts[group] = int(counts.get(group, 0)) + 1
	if not passed:
		failures.append(case_id + " " + JSON.stringify(details))
	var row: Dictionary = details.duplicate(true)
	row.merge({"id": case_id, "group": group, "locale": LocaleManager.language,
		"passed": passed}, true)
	print("PROSE_RECALL_CASE=" + JSON.stringify(row))


func _prepare(turn: int = 49) -> void:
	_restore_properties(GameState, initial_game)
	_restore_properties(GameState, initial_transients)
	_restore_properties(EventManager, initial_events)
	GameState.flags = {}
	GameState.turn = turn
	GameState.age = 33 + int(floor(float(turn - 1) / 48.0))
	GameState.year = 2026 + int(floor(float(turn - 1) / 48.0))
	GameState.month = int(floor(float(turn - 1) / 4.0)) % 12 + 1
	GameState.week_of_month = (turn - 1) % 4 + 1
	GameState.player_name = "Recall QA"
	GameState.is_game_over = false
	GameState.money = 500_000.0
	GameState.portfolio = {}
	GameState.loans = {"bank": 0.0, "second": 0.0}
	GameState.housing = "gosiwon"
	GameState.player_route = "none"
	GameState.current_job = {}
	GameState.mental = 50
	GameState.health = 50
	GameState.intelligence = 50
	GameState.investment_skill = 50
	GameState.luck = 50
	GameState.moral_tint = 0.0
	GameState.route_orthodox = 0
	GameState.route_unorthodox = 0
	GameState.cast = {
		"father": {"stage": "health_crisis", "affinity": 0, "met": true, "flags": {}},
		"daeun": {"stage": "unknown", "affinity": 0, "met": false, "flags": {}},
		"jiyeon": {"stage": "unknown", "affinity": 0, "met": false, "flags": {}},
		"hyunsu": {"stage": "unknown", "affinity": 0, "met": false, "flags": {}},
		"sangchul": {"stage": "unknown", "affinity": 0, "met": false, "flags": {}},
		"jaehyuk": {"stage": "unknown", "affinity": 0, "met": false, "flags": {}},
	}
	GameState.core_loop_v2_state = {}
	GameState.chapter5_causal_state = {}
	GameState.chapter5_finale_state = FINALE.default_state()
	GameState.deferred_events = []
	GameState.pending_story_queue = []
	GameState.pending_tint_vignette = {}
	GameState.pending_scar_vignette = ""
	GameState.action_axis_this_week = {"money": 0, "human": 0}
	GameState.action_places_this_week = {}
	GameState.action_records_this_week = []
	GameState.recent_action_places = []
	GameState.recent_action_weeks = []
	GameState.event_log = []
	GameState.action_log = []
	GameState.events_seen = 0
	EventManager.event_cooldowns = {}
	EventManager.recent_event_ids = []


func _source_events(language: String) -> Dictionary:
	var result: Dictionary = {}
	var directory: String = "events" if language == "ko" else "events_" + language
	for file_name: String in FILES:
		var path: String = "res://content/%s/%s" % [directory, file_name]
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if not parsed is Array:
			failures.append("source array missing " + path)
			continue
		for event: Dictionary in parsed:
			result[str(event.get("id", ""))] = event
	return result


func _ordered_equal(left: Variant, right: Variant) -> bool:
	if left is Dictionary and right is Dictionary:
		if left.keys() != right.keys():
			return false
		for key: Variant in left:
			if not _ordered_equal(left[key], right[key]):
				return false
		return true
	if left is Array and right is Array:
		if left.size() != right.size():
			return false
		for index: int in range(left.size()):
			if not _ordered_equal(left[index], right[index]):
				return false
		return true
	return left == right


func _gameplay(event: Dictionary) -> Dictionary:
	var result: Dictionary = event.duplicate(true)
	for key: String in ["title", "description"]:
		result.erase(key)
	for key: String in ["description_if_known", "description_memory_if_known"]:
		if result.get(key) is Dictionary:
			for condition: String in result[key]:
				result[key][condition] = "<localized prose>"
	for choice: Dictionary in result.get("choices", []):
		choice.erase("text")
		choice.erase("result_text")
	return result


func _source_text_matches(loaded: Dictionary, source: Dictionary) -> bool:
	for key: String in ["title", "description", "description_if_known",
			"description_memory_if_known"]:
		if loaded.has(key) != source.has(key):
			return false
		if source.has(key) and not _ordered_equal(loaded[key], source[key]):
			return false
	var loaded_choices: Array = loaded.get("choices", [])
	var source_choices: Array = source.get("choices", [])
	if loaded_choices.size() != source_choices.size():
		return false
	for index: int in range(source_choices.size()):
		for key: String in ["text", "result_text"]:
			if loaded_choices[index].get(key) != source_choices[index].get(key):
				return false
	return true


func _check_loaded(ko: Dictionary, source: Dictionary) -> void:
	for event_id: String in TARGETS:
		var event: Dictionary = DataRegistry.find_event(event_id)
		var original: Dictionary = ko.get(event_id, {})
		var localized: Dictionary = source.get(event_id, {})
		var gameplay_equal: bool = _ordered_equal(_gameplay(event), _gameplay(original))
		var text_equal: bool = _source_text_matches(event, localized)
		_case("loaded", event_id, not event.is_empty() and not original.is_empty()
			and not localized.is_empty() and gameplay_equal and text_equal, {
			"event": event_id, "gameplay_equal": gameplay_equal, "text_equal": text_equal,
			"gameplay_sha256": JSON.stringify(_gameplay(event)).sha256_text(),
		})


func _body_case(story: Node, event_id: String, label: String,
		active: Array, expected_key: String) -> void:
	_prepare(int(BODY_TURNS[event_id]))
	if event_id == HYUNSU_PASSED:
		GameState.flags["father_passed"] = true
		GameState.cast["father"]["stage"] = "passed"
	for flag: String in active:
		GameState.flags[flag] = true
	var event: Dictionary = DataRegistry.find_event(event_id)
	story.set("_current", event)
	story.set("_read_only_replay", false)
	var map_name: String = "description_memory_if_known" if event_id == YEAR_ONE \
		else "description_if_known"
	var known: Dictionary = event.get(map_name, {})
	var raw: String = str(event.get("description", ""))
	if not expected_key.is_empty():
		var selected: String = str(known.get(expected_key, ""))
		raw = raw + "\n\n" + selected if event_id == YEAR_ONE else selected
	var before: Dictionary = GameState.serialize().duplicate(true)
	var expected: String = story.call("_fmt", raw)
	var actual: String = story.call("_resolved_story_description", event)
	var echo_empty: bool = EventManager.causal_frame_for(event).is_empty()
	var structure: bool = known.keys() == BODY_KEYS[event_id]
	var unchanged: bool = GameState.serialize() == before
	_case("body", event_id + "/" + label, structure and echo_empty and unchanged
		and not expected.is_empty() and actual == expected, {
		"event": event_id, "active": active, "expected_key": expected_key,
		"map": map_name, "structure": structure, "echo_empty": echo_empty,
		"expected_sha256": expected.sha256_text(), "actual_sha256": actual.sha256_text(),
		"paragraphs": actual.split("\n\n", false).size(), "state_unchanged": unchanged,
	})


func _check_bodies(story: Node) -> void:
	for event_id: String in BODY_KEYS:
		var keys: Array = BODY_KEYS[event_id]
		_body_case(story, event_id, "base", [], "")
		for key: String in keys:
			_body_case(story, event_id, "single/" + key, [key], key)
		for index: int in range(maxi(0, keys.size() - 1)):
			_body_case(story, event_id, "suffix/" + str(index), keys.slice(index), str(keys[index]))


func _memory_case(game: Node, story: Node, producer: Dictionary,
		reader_id: String, reconnected: bool) -> void:
	_prepare(157)
	var source_id: String = str(producer["id"])
	# Deliberately change the relationship between producer and reader. A shared
	# repair receipt cannot identify its old recipient from today's reader.
	GameState.flags = {"arc_y4_three_promises_seen": true,
		"arc_y4_three_promises_missed_person": true,
		"daeun_romance_started": reader_id != DAEUN_READER}
	GameState.flags["arc_y4_three_promises_missed_" + str(producer["missed"])] = true
	var selected_source: String = game.call("_chapter_four_causal_arc_id", 157,
		GameState.flags, false)
	var source: Dictionary = DataRegistry.find_event(source_id)
	var index: int = int(producer["choice"])
	var committed: bool = GameState.apply_choice(source, source["choices"][index])
	var receipt_ok: bool = committed and not GameState.event_log.is_empty() \
		and str(GameState.event_log.back().get("event_id", "")) == source_id \
		and int(GameState.event_log.back().get("choice_index", -1)) == index
	for flag: String in REPAIR_FLAGS:
		receipt_ok = receipt_ok and bool(GameState.flags.get(flag, false))
	receipt_ok = receipt_ok and not GameState.flags.get("arc_y4_missed_cost_repaired_father", false) \
		and not GameState.flags.get("arc_y4_missed_cost_repaired_deal", false)
	GameState.turn = 164
	GameState.flags["arc_36_body_signal_seen"] = true
	GameState.flags["daeun_romance_started"] = reader_id == DAEUN_READER
	GameState.flags["hyunsu_reconnected"] = reconnected
	var selected_reader: String = game.call("_chapter_four_causal_arc_id", 164,
		GameState.flags, false)
	var reader: Dictionary = DataRegistry.find_event(reader_id)
	var raw: String = str(reader.get("description", ""))
	if reconnected:
		raw = str(reader.get("description_if_known", {}).get("hyunsu_reconnected", ""))
	raw += "\n\n" + str(reader.get("description_memory_if_known", {}).get(PERSON_MEMORY, ""))
	story.set("_current", reader)
	var before: Dictionary = GameState.serialize().duplicate(true)
	var expected: String = story.call("_fmt", raw)
	var actual: String = story.call("_resolved_story_description", reader)
	var unchanged: bool = GameState.serialize() == before
	_case("memory", "%s/%s/%s" % [source_id, reader_id, "dik" if reconnected else "base"],
		selected_source == source_id and selected_reader == reader_id and receipt_ok
		and unchanged and not expected.is_empty() and actual == expected, {
		"producer": source_id, "choice_index": index, "source_turn": 157,
		"reader": reader_id, "reader_turn": 164, "selected_source": selected_source,
		"selected_reader": selected_reader, "receipt_ok": receipt_ok,
		"past_daeun": reader_id != DAEUN_READER, "current_daeun": reader_id == DAEUN_READER,
		"hyunsu_reconnected": reconnected, "state_unchanged": unchanged,
		"expected_sha256": expected.sha256_text(), "actual_sha256": actual.sha256_text(),
	})


func _check_memories(game: Node, story: Node) -> void:
	for producer: Dictionary in PRODUCERS:
		for reader_id: String in [DAEUN_READER, HYUNSU_READER]:
			_memory_case(game, story, producer, reader_id, false)
		_memory_case(game, story, producer, HYUNSU_READER, true)
	for reader_id: String in [DAEUN_READER, HYUNSU_READER]:
		for missing: String in ["arc_y4_missed_cost_seen", "arc_y4_missed_cost_repaired_person"]:
			_prepare(164)
			GameState.flags = {"arc_36_body_signal_seen": true,
				"daeun_romance_started": reader_id == DAEUN_READER,
				"arc_y4_missed_cost_seen": true, "arc_y4_missed_cost_repaired_person": true}
			GameState.flags.erase(missing)
			var reader: Dictionary = DataRegistry.find_event(reader_id)
			story.set("_current", reader)
			var before: Dictionary = GameState.serialize().duplicate(true)
			var actual_id: String = game.call("_chapter_four_causal_arc_id", 164, GameState.flags, false)
			var actual: String = story.call("_resolved_story_description", reader)
			var expected: String = story.call("_fmt", str(reader.get("description", "")))
			var unchanged: bool = GameState.serialize() == before
			_case("memory", reader_id + "/missing/" + missing,
				actual_id == reader_id and actual == expected and unchanged, {
				"reader": reader_id, "missing": missing, "selected_reader": actual_id,
				"expected_sha256": expected.sha256_text(), "actual_sha256": actual.sha256_text(),
				"state_unchanged": unchanged,
			})


func _choice_snapshot() -> Dictionary:
	return {"mental": GameState.mental, "intelligence": GameState.intelligence,
		"investment_skill": GameState.investment_skill, "luck": GameState.luck,
		"tint": GameState.moral_tint, "money": GameState.money, "health": GameState.health,
		"flags": GameState.flags.duplicate(true), "cast": GameState.cast.duplicate(true),
		"inventory": GameState.inventory.duplicate(true), "portfolio": GameState.portfolio.duplicate(true),
		"loans": GameState.loans.duplicate(true), "deferred": GameState.deferred_events.duplicate(true)}


func _check_choices() -> void:
	for event_id: String in BODY_KEYS:
		var event: Dictionary = DataRegistry.find_event(event_id)
		var choices: Array = event.get("choices", [])
		for index: int in range(choices.size()):
			_prepare(int(BODY_TURNS[event_id]))
			if event_id == HYUNSU_PASSED:
				GameState.flags["father_passed"] = true
				GameState.cast["father"]["stage"] = "passed"
			var choice: Dictionary = choices[index]
			var expected: Dictionary = _choice_snapshot()
			var effects: Dictionary = choice.get("effects", {})
			for key: String in effects:
				if not key in ["mental", "intelligence", "investment_skill", "luck", "tint"]:
					failures.append("unexpected owned choice effect " + event_id + "/" + key)
				else:
					expected[key] += effects[key]
			for flag: String in choice.get("flags", []):
				expected["flags"][flag] = true
			for person: String in choice.get("cast_effects", {}):
				var effect: Dictionary = choice["cast_effects"][person]
				if effect.has("affinity"):
					expected["cast"][person]["affinity"] += int(effect["affinity"])
				if effect.has("stage"):
					expected["cast"][person]["stage"] = str(effect["stage"])
			var available: bool = GameState.choice_available(event, choice)
			var committed: bool = GameState.apply_choice(event, choice)
			var actual: Dictionary = _choice_snapshot()
			var receipt: Dictionary = GameState.event_log.back() if not GameState.event_log.is_empty() else {}
			_case("choice", event_id + "/" + str(index), available and committed
				and actual == expected and GameState.events_seen == 1
				and str(receipt.get("event_id", "")) == event_id
				and int(receipt.get("choice_index", -1)) == index, {
				"event": event_id, "choice_index": index, "available": available,
				"committed": committed, "expected": expected, "actual": actual,
				"receipt_index": receipt.get("choice_index", -1),
			})


func _build_closed_flags() -> void:
	# Same prepared one-shot isolation as CoreChoiceSliceCheck; no natural-run claim.
	for event: Dictionary in DataRegistry.get_all_events():
		for choice: Dictionary in event.get("choices", []):
			for flag: String in choice.get("flags", []):
				if flag.ends_with("_seen") or flag.ends_with("_done") or flag.ends_with("_closed"):
					closed_flags[flag] = true
	for flag: String in ["prologue_done", "chapter_33_seen", "chapter_34_seen",
			"chapter_35_seen", "chapter_36_seen", "chapter_37_seen", "arc_daeun_met",
			"hyunsu_passed", "visited_father"]:
		closed_flags[flag] = true
	closed_flags.erase("father_passed")
	closed_flags.erase("arc_father_passing_seen")
	print("PROSE_RECALL_ROUTE_BASELINE=" + JSON.stringify(closed_flags))


func _route_case(game: Node, label: String, turn: int, edits: Dictionary,
		expected: String, forbidden: String = "", assets: float = 500_000.0,
		finale_locked: bool = false) -> void:
	_prepare(turn)
	GameState.flags = closed_flags.duplicate(true)
	GameState.flags.merge(edits, true)
	GameState.money = assets
	var lock_valid: bool = true
	if finale_locked:
		var locked: Dictionary = FINALE.lock_entry(FINALE.default_state(), FINALE.ENTRY_TURN,
			FINALE.ROUTE_ID, FINALE.PROFILE_ID,
			{"m55_decision": 0, "w212_guarantee": 0, "w215_final_door": 0},
			{"life": "alive", "contact_mode": "called"}, FINALE.ACTORS)
		GameState.chapter5_finale_state = locked.get("state", {})
		lock_valid = bool(locked.get("ok", false)) and GameState.chapter5_finale_holds_ending()
	else:
		lock_valid = not GameState.chapter5_finale_holds_ending()
	var before: Dictionary = GameState.serialize().duplicate(true)
	var actual: String = game.call("_next_arc_id", turn, true, false)
	var unchanged: bool = GameState.serialize() == before
	var matched: bool = actual != forbidden if not forbidden.is_empty() else actual == expected
	_case("route", label, matched and unchanged and lock_valid, {
		"turn": turn, "edits": edits, "assets": assets, "finale_locked": finale_locked,
		"lock_valid": lock_valid, "expected": expected, "forbidden": forbidden,
		"actual": actual, "state_unchanged": unchanged,
	})


func _check_routes(game: Node) -> void:
	_build_closed_flags()
	var m13: Dictionary = {"arc_year_one_mark_seen": false, "arc_34_money_attracts_seen": false}
	for turn: int in [48, 49, 52, 53]:
		_route_case(game, "m13/week" + str(turn), turn, m13,
			YEAR_ONE if turn in [49, 52] else "", "" if turn in [49, 52] else YEAR_ONE)
	_route_case(game, "m13/closure", 49, {"arc_year_one_mark_seen": true,
		"arc_34_money_attracts_seen": false}, "arc_34_money_attracts_money")
	for seen: bool in [false, true]:
		_route_case(game, "m13/money_seen/" + str(seen), 49,
			{"arc_year_one_mark_seen": seen, "arc_34_money_attracts_seen": true}, "", YEAR_ONE)
	var w96: Dictionary = {"arc_year2_close_seen": false, "arc_father_03_seen": true,
		"visited_father": false, "father_visit_deferred": false}
	for turn: int in [95, 97]:
		_route_case(game, "w96/outside/" + str(turn), turn, w96, "", YEAR_TWO)
	_route_case(game, "w96/father_first", 96, w96, "arc_father_04_visit")
	for flag: String in ["visited_father", "father_visit_deferred", "father_passed"]:
		var prepared: Dictionary = w96.duplicate(true)
		prepared[flag] = true
		_route_case(game, "w96/" + flag, 96, prepared, YEAR_TWO)
	var absent: Dictionary = w96.duplicate(true)
	absent["arc_father_03_seen"] = false
	_route_case(game, "w96/no_father03", 96, absent, YEAR_TWO)
	_route_case(game, "w96/already_seen", 96,
		{"arc_year2_close_seen": true, "visited_father": true}, "", YEAR_TWO)
	for seen: bool in [false, true]:
		_prepare(96)
		GameState.flags["arc_year2_close_seen"] = seen
		game.call("_go_story_mode", ["arc_father_04_visit"])
		var queue: Array = GameState.pending_story_queue.duplicate()
		var count: int = queue.count(YEAR_TWO)
		_case("route", "w96/queue/" + str(seen), count == (0 if seen else 1)
			and not queue.is_empty() and queue[0] == "arc_father_04_visit"
			and (seen or (queue.size() >= 2 and queue[1] == YEAR_TWO)), {
			"seen": seen, "queue": queue, "year2_count": count,
		})
	var hyunsu: Dictionary = {"hyunsu_year4_echo_seen": true, "hyunsu_year5_call_seen": false}
	_route_case(game, "hyunsu/199", 199, hyunsu, "", HYUNSU)
	_route_case(game, "hyunsu/200_low", 200, hyunsu, HYUNSU)
	_route_case(game, "hyunsu/239_high", 239, hyunsu, HYUNSU, "", 2_900_000_000.0)
	_route_case(game, "hyunsu/no_echo", 200,
		{"hyunsu_year4_echo_seen": false, "hyunsu_year5_call_seen": false}, "", HYUNSU)
	_route_case(game, "hyunsu/seen", 200, {"hyunsu_year5_call_seen": true}, "", HYUNSU)
	var ending: Dictionary = {"daeun_romance_started": true,
		"arc_daeun_year4_together_seen": true, "arc_daeun_year5_seen": false}
	_route_case(game, "ending/192", 192, ending, "", ENDING, 2_900_000_000.0)
	_route_case(game, "ending/under", 193, ending, "", ENDING, 2_899_999_999.0)
	_route_case(game, "ending/threshold", 193, ending, ENDING, "", 2_900_000_000.0)
	var started: Dictionary = ending.duplicate(true)
	started["arc_daeun_year4_together_seen"] = false
	started["arc_daeun_year3_together_seen"] = false
	_route_case(game, "ending/started_only", 193, started, ENDING, "", 2_900_000_000.0)
	var together: Dictionary = ending.duplicate(true)
	together["daeun_romance_started"] = false
	_route_case(game, "ending/together_only", 193, together, ENDING, "", 2_900_000_000.0)
	var neither: Dictionary = started.duplicate(true)
	neither["daeun_romance_started"] = false
	_route_case(game, "ending/neither", 193, neither, "", ENDING, 2_900_000_000.0)
	var completed: Dictionary = ending.duplicate(true)
	completed["arc_daeun_year5_seen"] = true
	_route_case(game, "ending/seen", 193, completed, "", ENDING, 2_900_000_000.0)
	_route_case(game, "ending/239", 239, ending, ENDING, "", 2_900_000_000.0)
	_route_case(game, "ending/locked239", 239, ending, "", ENDING, 2_900_000_000.0, true)
	var apart: Dictionary = {"arc_daeun_year3_apart_seen": true,
		"arc_daeun_year5_apart_seen": false}
	_route_case(game, "apart/192", 192, apart, "", APART)
	_route_case(game, "apart/193", 193, apart, APART)
	_route_case(game, "apart/no_source", 193,
		{"arc_daeun_year3_apart_seen": false, "arc_daeun_year5_apart_seen": false}, "", APART)
	_route_case(game, "apart/seen", 193, {"arc_daeun_year5_apart_seen": true}, "", APART)
	var both: Dictionary = ending.duplicate(true)
	both.merge(apart, true)
	_route_case(game, "apart/ending_priority", 193, both, ENDING, "", 2_900_000_000.0)


func _check_father() -> void:
	var rows: Array = [
		{"label": "alive", "requested": HYUNSU, "expected": HYUNSU},
		{"label": "flag", "flag": "father_passed", "requested": HYUNSU, "expected": HYUNSU_PASSED},
		{"label": "receipt", "flag": "arc_father_passing_seen", "requested": HYUNSU, "expected": HYUNSU_PASSED},
		{"label": "cast", "cast": true, "requested": HYUNSU, "expected": HYUNSU_PASSED},
		{"label": "reject_passed_when_alive", "requested": HYUNSU_PASSED, "expected": ""},
		{"label": "passed_id", "flag": "father_passed", "requested": HYUNSU_PASSED, "expected": HYUNSU_PASSED},
	]
	for row: Dictionary in rows:
		_prepare(200)
		if row.has("flag"):
			GameState.flags[str(row["flag"])] = true
		if bool(row.get("cast", false)):
			GameState.cast["father"]["stage"] = "passed"
		var before: Dictionary = GameState.serialize().duplicate(true)
		var actual: String = EventManager.live_event_variant_id(str(row["requested"]))
		var unchanged: bool = GameState.serialize() == before
		_case("father", str(row["label"]), actual == str(row["expected"]) and unchanged, {
			"requested": row["requested"], "expected": row["expected"],
			"actual": actual, "state_unchanged": unchanged,
		})


func _check_followups_and_callback(story: Node) -> void:
	var event: Dictionary = DataRegistry.find_event(YEAR_ONE)
	for index: int in range(3):
		_prepare(49)
		var choice: Dictionary = event["choices"][index]
		var committed: bool = GameState.apply_choice(event, choice)
		story.set("_current", event)
		story.set("_queue", [])
		var before: Dictionary = GameState.serialize().duplicate(true)
		var actual: String = story.call("_choice_follow_up_id", choice, YEAR_ONE, index)
		_case("followup", "choice/" + str(index), committed
			and actual == "arc_34_money_attracts_money"
			and GameState.serialize() == before and not DataRegistry.find_event(actual).is_empty(), {
			"choice_index": index, "committed": committed, "actual": actual,
		})
	var callback: Dictionary = DataRegistry.find_event("callback_keeps_records_echo")
	for row: Dictionary in [{"turn": 75, "keep": true, "expected": false},
			{"turn": 76, "keep": true, "expected": true},
			{"turn": 76, "keep": false, "expected": false}]:
		_prepare(49)
		var committed: bool = GameState.apply_choice(event, event["choices"][0])
		GameState.turn = int(row["turn"])
		if not bool(row["keep"]):
			GameState.flags.erase("keeps_records")
		var before: Dictionary = GameState.serialize().duplicate(true)
		var actual: bool = EventManager.call("_check_conditions", callback.get("conditions", {}))
		_case("callback", "%d/keep=%s" % [int(row["turn"]), str(row["keep"])],
			committed and not callback.is_empty() and actual == bool(row["expected"])
			and GameState.serialize() == before, {"turn": row["turn"], "keeps_records": row["keep"],
			"actual": actual, "expected": row["expected"], "producer_committed": committed})


func _run() -> void:
	var qa_namespace472: String = OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	if not qa_namespace472.begins_with("GangnamDream_StoryNameplateQA_") \
			or OS.get_user_data_dir().get_file() != qa_namespace472:
		push_error("PROSE_RECALL_CHECK_FAIL pre-autoload isolation missing")
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
	story.set("_read_only_replay", false)
	var ko: Dictionary = _source_events("ko")
	for language: String in LOCALES:
		LocaleManager.language = language
		DataRegistry.reload()
		_check_loaded(ko, _source_events(language))
		_check_bodies(story)
		_check_memories(game, story)
	LocaleManager.language = "ko"
	DataRegistry.reload()
	_check_choices()
	_check_routes(game)
	_check_father()
	_check_followups_and_callback(story)
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
	print("PROSE_RECALL_RESTORED=" + JSON.stringify(restored))
	if not restored:
		failures.append("singleton restoration failed")
	if counts != POPULATION or case_ids.size() != 337:
		failures.append("case population drift: " + JSON.stringify(counts))
	print("PROSE_RECALL_POPULATION=" + JSON.stringify(counts))
	if not failures.is_empty():
		for failure: String in failures:
			push_error("PROSE_RECALL_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("PROSE_RECALL_CHECK_OK locales=5 cases=337 loaded=40 body=185 memory=50 choice=14 route=36 father=6 callback=3 followup=3 prepared_component_only=true")
	get_tree().quit(0)
