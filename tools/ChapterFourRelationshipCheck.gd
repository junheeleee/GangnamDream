extends Node
## Prepared real-Main selector check, not a natural route or rendered screen.
## Run only through the existing pre-autoload isolated QA bootstrap.
const MAIN = preload("res://scenes/MainGame.gd")
const STORY = preload("res://scenes/StoryMode.gd")
const PERSON_DEAL_ID := "arc_36_unexpected_hand_person_deal"
const PERSON_DEAL_LOCALES := ["ko", "en", "ja", "zh-CN", "zh-TW"]
const FATHER_P0_ROOT := "arc_father_passing"
const FATHER_P0_HOSPITAL_TERMINAL := "arc_father_passing_hospital_room"
const FATHER_P0_MONEY_TERMINAL := "arc_father_passing_deal_morning"
const FATHER_P0_W190 := [
	"arc_y4_year_close_daeun",
	"arc_y4_year_close_unattached",
]
const RELATIONSHIPS := [
	{"id": "none", "flags": {}, "daeun": false, "partner": ""},
	{"id": "daeun", "flags": {"daeun_romance_started": true},
		"daeun": true, "partner": "daeun"},
	{"id": "jiyeon", "flags": {"jiyeon_romance_started": true},
		"daeun": false, "partner": "jiyeon"},
	{"id": "both", "flags": {"daeun_romance_started": true,
		"jiyeon_romance_started": true}, "daeun": true, "partner": "daeun"},
	{"id": "daeun_divorced", "flags": {"daeun_romance_started": true,
		"daeun_divorced": true}, "daeun": false, "partner": ""},
	{"id": "jiyeon_left", "flags": {"jiyeon_romance_started": true,
		"jiyeon_left": true}, "daeun": false, "partner": ""},
	{"id": "divorced_and_jiyeon", "flags": {"daeun_romance_started": true,
		"daeun_divorced": true, "jiyeon_romance_started": true},
		"daeun": false, "partner": "jiyeon"},
	{"id": "married_flag_only", "flags": {"daeun_married": true},
		"daeun": false, "partner": ""},
]
const SLOTS := [
	{"turn": 153, "prerequisites": {},
		"daeun": "arc_y4_three_promises",
		"unattached": "arc_y4_three_promises_deal_only"},
	{"turn": 164, "prerequisites": {"arc_36_body_signal_seen": true},
		"daeun": "arc_y4_body_witness", "unattached": "arc_y4_body_witness_hyunsu"},
	{"turn": 167, "prerequisites": {"arc_y4_body_witness_seen": true},
		"daeun": "arc_y4_family_partner_collision",
		"unattached": "arc_y4_family_commitment_none",
		"missed_flag": "arc_y4_three_promises_missed_father",
		"missed_event": "arc_y4_family_table_missed"},
	{"turn": 177, "prerequisites": {},
		"daeun": "arc_y4_borrowed_name", "unattached": "arc_y4_borrowed_name_self",
		"missed_flag": "arc_y4_three_promises_missed_deal",
		"missed_event": "arc_y4_borrowed_name_document_gap"},
	{"turn": 181, "prerequisites": {},
		"daeun": "arc_y4_bill_night", "unattached": "arc_y4_bill_night_unattached"},
	{"turn": 190, "prerequisites": {},
		"daeun": "arc_y4_year_close_daeun", "unattached": "arc_y4_year_close_unattached"},
]
# Keep the original eight rows/64 selector cases unchanged. These five rows
# supplement only the person-deal body table, including current 0/1 truthiness.
const PERSON_DEAL_EXTRA_RELATIONSHIPS := [
	{"id": "divorced_only", "flags": {"daeun_divorced": true}, "daeun": false},
	{"id": "started_zero", "flags": {"daeun_romance_started": 0}, "daeun": false},
	{"id": "started_one", "flags": {"daeun_romance_started": 1}, "daeun": true},
	{"id": "started_one_divorced_zero", "flags": {"daeun_romance_started": 1,
		"daeun_divorced": 0}, "daeun": true},
	{"id": "started_one_divorced_one", "flags": {"daeun_romance_started": 1,
		"daeun_divorced": 1}, "daeun": false},
]
var failures: Array[String] = []
var normal_cases := 0
var missed_cases := 0
var person_deal_cases := 0
var father_known_cases := 0
var father_money_cases := 0
var father_medical_cases := 0
var father_terminal_cases := 0
var father_w190_cases := 0
var father_w190_memory_cases := 0
var father_w190_choice_cases := 0
var father_w190_route_cases := 0

func _ready() -> void:
	call_deferred("_run")

func _check(game: Node, slot: Dictionary, relationship: Dictionary,
		missed: bool) -> void:
	var prepared: Dictionary = (slot["prerequisites"] as Dictionary).duplicate(true)
	prepared.merge(relationship["flags"] as Dictionary, true)
	if missed:
		prepared[str(slot["missed_flag"])] = true
	# The slot argument and relationship helper must see the exact same state.
	GameState.flags = prepared
	var before: Dictionary = GameState.flags.duplicate(true)
	var expected: String = str(slot["daeun"]) if bool(relationship["daeun"]) \
		else str(slot["missed_event"] if missed else slot["unattached"])
	var actual: String = game.call("_chapter_four_causal_arc_id",
		int(slot["turn"]), GameState.flags, false)
	var partner: String = game.call("_romance_partner_id")
	var state_unchanged: bool = GameState.flags == before
	var passed: bool = actual == expected and state_unchanged \
		and partner == str(relationship["partner"]) \
		and not DataRegistry.find_event(actual).is_empty()
	if missed:
		missed_cases += 1
	else:
		normal_cases += 1
	if not passed:
		failures.append("W%d/%s/missed=%s expected=%s actual=%s partner=%s" % [
			int(slot["turn"]), str(relationship["id"]), missed, expected, actual, partner])
	print("CHAPTER_FOUR_RELATIONSHIP_CASE=" + JSON.stringify({
		"turn": int(slot["turn"]), "relationship": str(relationship["id"]),
		"missed": missed, "expected": expected, "actual": actual,
		"partner": partner, "state_unchanged": state_unchanged, "passed": passed,
	}))

func _check_person_deal(game: Node, story: Node, event: Dictionary,
		language: String, relationship: Dictionary, structure_valid: bool) -> void:
	GameState.flags = (relationship["flags"] as Dictionary).duplicate(true)
	var before_selector: Dictionary = GameState.flags.duplicate(true)
	var expected_selector: String = "arc_y4_three_promises" \
		if bool(relationship["daeun"]) else "arc_y4_three_promises_deal_only"
	var actual_selector: String = game.call("_chapter_four_causal_arc_id",
		153, GameState.flags, false)
	var selector_unchanged: bool = GameState.flags == before_selector
	GameState.flags.merge({
		"arc_y4_three_promises_seen": true,
		"arc_y4_three_promises_missed_person": true,
		"arc_y4_three_promises_missed_deal": true,
	}, true)
	var before_body: Dictionary = GameState.flags.duplicate(true)
	var actual_repair: String = game.call("_chapter_four_causal_arc_id",
		157, GameState.flags, false)
	var known: Dictionary = {}
	if event.get("description_if_known") is Dictionary:
		known = event["description_if_known"]
	var expected_raw: String = str(known.get("daeun_romance_started", "")) \
		if bool(relationship["daeun"]) else str(event.get("description", ""))
	var expected_body: String = story.call("_fmt", expected_raw)
	var actual_body: String = story.call("_resolved_story_description", event)
	var state_unchanged: bool = selector_unchanged and GameState.flags == before_body
	var passed: bool = structure_valid and actual_selector == expected_selector \
		and actual_repair == PERSON_DEAL_ID and not expected_body.is_empty() \
		and actual_body == expected_body and state_unchanged
	person_deal_cases += 1
	if not passed:
		failures.append("person_deal/%s/%s selector=%s repair=%s body_equal=%s" % [
			language, str(relationship["id"]), actual_selector, actual_repair,
			actual_body == expected_body])
	print("CHAPTER_FOUR_PERSON_DEAL_CASE=" + JSON.stringify({
		"locale": language, "relationship": str(relationship["id"]),
		"expected_selector": expected_selector, "actual_selector": actual_selector,
		"expected_branch": "daeun" if bool(relationship["daeun"]) else "clinic",
		"actual_repair": actual_repair, "structure_valid": structure_valid,
		"expected_body_sha256": expected_body.sha256_text(),
		"actual_body_sha256": actual_body.sha256_text(),
		"state_unchanged": state_unchanged, "passed": passed,
	}))

func _check_person_deal_locales(game: Node, story: Node) -> void:
	var relationships: Array = RELATIONSHIPS.duplicate(true)
	relationships.append_array(PERSON_DEAL_EXTRA_RELATIONSHIPS)
	for language: String in PERSON_DEAL_LOCALES:
		LocaleManager.language = language
		DataRegistry.reload()
		var event: Dictionary = DataRegistry.find_event(PERSON_DEAL_ID)
		var known: Dictionary = {}
		if event.get("description_if_known") is Dictionary:
			known = event["description_if_known"]
		var structure_valid: bool = not event.is_empty() \
			and known.keys() == ["daeun_divorced", "daeun_romance_started"] \
			and event.get("description") is String \
			and known.get("daeun_divorced") == event.get("description") \
			and known.get("daeun_romance_started") is String \
			and not str(known.get("daeun_romance_started", "")).strip_edges().is_empty() \
			and known.get("daeun_romance_started") != event.get("description")
		for relationship: Dictionary in relationships:
			_check_person_deal(game, story, event, language, relationship, structure_valid)

func _father_p0_expect(condition: bool, label: String) -> void:
	if not condition:
		failures.append("father_p0/" + label)

func _check_father_p0_known(story: Node, language: String) -> void:
	var event: Dictionary = DataRegistry.find_event(FATHER_P0_ROOT)
	var known: Dictionary = event.get("description_if_known", {})
	var cases: Array[Dictionary] = [
		{"label": "called", "flags": {"called_father_on_ktx": true},
			"key": "called_father_on_ktx"},
		{"label": "not_called", "flags": {"did_not_call_father_on_ktx": true},
			"key": "did_not_call_father_on_ktx"},
		{"label": "both_first_match", "flags": {
			"called_father_on_ktx": true, "did_not_call_father_on_ktx": true},
			"key": "called_father_on_ktx"},
	]
	for fixture: Dictionary in cases:
		GameState.flags = (fixture["flags"] as Dictionary).duplicate(true)
		var expected: String = story.call("_fmt", str(known.get(fixture["key"], "")))
		var actual: String = story.call("_resolved_story_description", event)
		var passed: bool = not expected.is_empty() and actual == expected
		father_known_cases += 1
		_father_p0_expect(passed, "%s/root_known/%s" % [language, fixture["label"]])
		print("CHAPTER_FOUR_FATHER_KNOWN_CASE=" + JSON.stringify({
			"locale": language, "case": fixture["label"],
			"expected_sha256": expected.sha256_text(),
			"actual_sha256": actual.sha256_text(), "passed": passed,
		}))

func _w190_choice_contract(choice: Dictionary) -> Dictionary:
	return {
		"choice_kind": str(choice.get("choice_kind", "")),
		"flags": (choice.get("flags", []) as Array).duplicate(true),
		"effects": (choice.get("effects", {}) as Dictionary).duplicate(true),
		"cast_effects": (choice.get("cast_effects", {}) as Dictionary).duplicate(true),
		"follow_up_event": str(choice.get("follow_up_event", "")),
	}

func _check_father_p0_w190(story: Node, language: String) -> void:
	var expected_choice_contracts: Array[Dictionary] = [
		{"choice_kind": "decision", "flags": [
			"arc_y4_year_close_boundary_seen",
			"arc_y4_year_close_protected_relationship"],
			"effects": {}, "cast_effects": {}, "follow_up_event": ""},
		{"choice_kind": "decision", "flags": [
			"arc_y4_year_close_boundary_seen",
			"arc_y4_year_close_protected_body"],
			"effects": {}, "cast_effects": {}, "follow_up_event": ""},
		{"choice_kind": "decision", "flags": [
			"arc_y4_year_close_boundary_seen",
			"arc_y4_year_close_protected_family"],
			"effects": {}, "cast_effects": {}, "follow_up_event": ""},
	]
	for event_id: String in FATHER_P0_W190:
		var event: Dictionary = DataRegistry.find_event(event_id)
		var known: Dictionary = event.get("description_if_known", {})
		for father_passed: bool in [false, true]:
			GameState.flags = {"father_passed": true} if father_passed else {}
			var expected_raw: String = str(known.get("father_passed", "")) \
				if father_passed else str(event.get("description", ""))
			var expected: String = story.call("_fmt", expected_raw)
			var actual: String = story.call("_resolved_story_description", event)
			var passed: bool = not expected.is_empty() and actual == expected
			father_w190_cases += 1
			_father_p0_expect(passed, "%s/%s/life=%s" % [
				language, event_id, "passed" if father_passed else "alive"])
		var memory_map: Dictionary = event.get("description_memory_if_known", {})
		var memory_key: String = str(memory_map.keys()[0]) \
			if not memory_map.is_empty() else ""
		var memory_flags: Dictionary = {"father_passed": true}
		if not memory_key.is_empty():
			memory_flags[memory_key] = true
		GameState.flags = memory_flags
		var passed_prefix: String = story.call(
			"_fmt", str(known.get("father_passed", "")))
		var memory_text: String = story.call(
			"_fmt", str(memory_map.get(memory_key, "")))
		var assembled: String = story.call("_resolved_story_description", event)
		var memory_passed: bool = not memory_key.is_empty() \
			and assembled.begins_with(passed_prefix) \
			and assembled.contains(memory_text)
		father_w190_memory_cases += 1
		_father_p0_expect(memory_passed, "%s/%s/passed_memory_prefix" % [
			language, event_id])
		var choices: Array = event.get("choices", [])
		for index in range(expected_choice_contracts.size()):
			var actual_contract: Dictionary = _w190_choice_contract(
				choices[index] as Dictionary) \
				if index < choices.size() and choices[index] is Dictionary else {}
			var passed: bool = actual_contract == expected_choice_contracts[index]
			father_w190_choice_cases += 1
			_father_p0_expect(passed, "%s/%s/choice=%d" % [
				language, event_id, index])

func _check_father_p0_money(story: Node, language: String) -> void:
	var event: Dictionary = DataRegistry.find_event(FATHER_P0_MONEY_TERMINAL)
	var bodies: Array[String] = []
	for amount: float in [4_900_000.0, 5_100_000.0]:
		GameState.flags = {}
		GameState.money = amount
		GameState.portfolio = {}
		GameState.loans = {"bank": 0.0, "second": 0.0}
		var expected_assets: String = str(GameState.format_money(amount))
		var actual: String = story.call("_resolved_story_description", event)
		var passed: bool = actual.contains(expected_assets) \
			and not actual.contains("{assets}")
		father_money_cases += 1
		_father_p0_expect(passed, "%s/money/assets=%d" % [language, int(amount)])
		bodies.append(actual)
	_father_p0_expect(bodies.size() == 2 and bodies[0] != bodies[1],
		"%s/money/above_below_not_dynamic" % language)

func _check_father_p0_terminals(language: String) -> void:
	var expected: Dictionary = {
		FATHER_P0_HOSPITAL_TERMINAL: {
			"effects": {"mental": -40.0, "tint": 10.0},
			"cast_effects": {"father": {"stage": "passed"}},
			"flags": ["arc_father_passing_seen", "father_passed",
				"tried_to_go_to_father"],
			"deferred_follow_up": "", "deferred_delay": -1,
		},
		FATHER_P0_MONEY_TERMINAL: {
			"effects": {"mental": -25.0, "money": 5_000_000.0, "tint": -8.0},
			"cast_effects": {"father": {"stage": "passed"}},
			"flags": ["arc_father_passing_seen", "father_passed",
				"chose_money_over_father"],
			"deferred_follow_up": "callback_chose_money_father_echo",
			"deferred_delay": 12,
		},
	}
	for event_id: String in expected:
		var event: Dictionary = DataRegistry.find_event(event_id)
		var choices: Array = event.get("choices", [])
		var choice: Dictionary = choices[0] as Dictionary \
			if choices.size() == 1 and choices[0] is Dictionary else {}
		var actual: Dictionary = {
			"effects": (choice.get("effects", {}) as Dictionary).duplicate(true),
			"cast_effects": (choice.get("cast_effects", {}) as Dictionary).duplicate(true),
			"flags": (choice.get("flags", []) as Array).duplicate(true),
			"deferred_follow_up": str(choice.get("deferred_follow_up", "")),
			"deferred_delay": int(choice.get("deferred_delay", -1)),
		}
		var passed: bool = actual == expected[event_id]
		father_terminal_cases += 1
		_father_p0_expect(passed, "%s/%s/terminal_state" % [language, event_id])

func _check_father_p0_medical(game: Node) -> void:
	for mask in range(8):
		var flags: Dictionary = {
			"arc_father_medication_seen": true,
			"arc_father_03_seen": true,
			"arc_y4_bill_night_seen": true,
		}
		if (mask & 1) != 0:
			flags["called_about_medication"] = true
		if (mask & 2) != 0:
			flags["sangchul_helped_with_father"] = true
		if (mask & 4) != 0:
			flags["father_care_coordinated"] = true
		else:
			flags["father_care_left_open"] = true
		var before: Dictionary = flags.duplicate(true)
		var evidence_count: int = int((mask & 1) != 0) + int((mask & 2) != 0) \
			+ int((mask & 4) != 0)
		var expected: String = "arc_y4_father_crisis_stabilized" \
			if evidence_count >= 2 \
			else FATHER_P0_ROOT
		var actual: String = game.call("_chapter_four_father_outcome_id", flags, false)
		var passed: bool = actual == expected and flags == before
		father_medical_cases += 1
		_father_p0_expect(passed, "medical/mask=%d" % mask)
	var passed_terminal: String = game.call(
		"_chapter_four_father_outcome_id", {}, true)
	father_medical_cases += 1
	_father_p0_expect(passed_terminal.is_empty(), "medical/terminal_reopened")
	var damaged: String = game.call("_chapter_four_father_outcome_id", {
		"arc_father_medication_seen": true,
		"arc_father_03_seen": true,
	}, false)
	father_medical_cases += 1
	_father_p0_expect(damaged == "arc_y4_father_outcome_unknown",
		"medical/damaged_receipt_not_closed")

func _check_father_p0_passed_w190_routes(game: Node) -> void:
	for fixture: Dictionary in [
		{"label": "daeun", "flags": {
			"father_passed": true, "daeun_romance_started": true},
			"expected": FATHER_P0_W190[0]},
		{"label": "unattached", "flags": {"father_passed": true},
			"expected": FATHER_P0_W190[1]},
	]:
		var flags: Dictionary = (fixture["flags"] as Dictionary).duplicate(true)
		var before: Dictionary = flags.duplicate(true)
		GameState.flags = flags
		var actual: String = game.call(
			"_chapter_four_causal_arc_id", 190, flags, true)
		var passed: bool = actual == str(fixture["expected"]) and flags == before
		father_w190_route_cases += 1
		_father_p0_expect(passed, "w190_route/%s" % fixture["label"])

func _check_father_p0_locales(story: Node) -> void:
	for language: String in PERSON_DEAL_LOCALES:
		LocaleManager.language = language
		DataRegistry.reload()
		_check_father_p0_known(story, language)
		_check_father_p0_w190(story, language)
		_check_father_p0_money(story, language)
		_check_father_p0_terminals(language)

func _run() -> void:
	var qa_namespace469 := OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	if not qa_namespace469.begins_with("GangnamDream_StoryNameplateQA_") \
		or OS.get_user_data_dir().get_file() != qa_namespace469:
		push_error("CHAPTER_FOUR_RELATIONSHIP_CHECK_FAIL pre-autoload isolation missing")
		get_tree().quit(1)
		return
	print("STORY_NAMEPLATE_QA_USER_DIR=" + OS.get_user_data_dir())
	var old_flags: Dictionary = GameState.flags
	var old_state: Dictionary = GameState.serialize().duplicate(true)
	var old_meta: Dictionary = MetaProgression.data.duplicate(true)
	var old_unlocks: Dictionary = MetaProgression.get("_new_this_run").duplicate(true)
	var old_language: String = LocaleManager.language
	var old_money: float = GameState.money
	var old_portfolio: Dictionary = GameState.portfolio
	var old_loans: Dictionary = GameState.loans
	var game: Node = MAIN.new()
	for slot: Dictionary in SLOTS:
		for relationship: Dictionary in RELATIONSHIPS:
			_check(game, slot, relationship, false)
			if slot.has("missed_flag"):
				_check(game, slot, relationship, true)
	var story: Node = STORY.new()
	_check_person_deal_locales(game, story)
	_check_father_p0_medical(game)
	_check_father_p0_passed_w190_routes(game)
	_check_father_p0_locales(story)
	story.free()
	game.free()
	GameState.flags = old_flags
	GameState.money = old_money
	GameState.portfolio = old_portfolio
	GameState.loans = old_loans
	LocaleManager.language = old_language
	DataRegistry.reload()
	var restored: bool = GameState.serialize() == old_state \
		and MetaProgression.data == old_meta \
		and MetaProgression.get("_new_this_run") == old_unlocks \
		and LocaleManager.language == old_language
	if not restored:
		failures.append("singleton GameState/MetaProgression changed by prepared fixture")
	if normal_cases != 48 or missed_cases != 16:
		failures.append("prepared case population drifted")
	if person_deal_cases != 65:
		failures.append("person-deal prepared case population drifted")
	if father_known_cases != 15 or father_money_cases != 10 \
			or father_medical_cases != 10 or father_terminal_cases != 10 \
			or father_w190_cases != 20 \
			or father_w190_memory_cases != 10 \
			or father_w190_choice_cases != 30 or father_w190_route_cases != 2:
		failures.append("father P0 prepared case population drifted")
	print("CHAPTER_FOUR_RELATIONSHIP_RESTORED=" + str(restored))
	if not failures.is_empty():
		for failure: String in failures:
			push_error("CHAPTER_FOUR_RELATIONSHIP_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("CHAPTER_FOUR_PERSON_DEAL_CHECK_OK locales=5 cases=65 prepared_component_only=true")
	print("CHAPTER_FOUR_FATHER_P0_CHECK_OK locales=5 known=15 money=10 " \
		+ "medical=10 terminals=10 w190_variants=20 w190_memory=10 " \
		+ "w190_choices=30 w190_routes=2 " \
		+ "prepared_component_only=true")
	print("CHAPTER_FOUR_RELATIONSHIP_CHECK_OK normal_cases=48 missed_cases=16 prepared_component_only=true")
	get_tree().quit(0)
