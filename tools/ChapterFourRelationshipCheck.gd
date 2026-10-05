extends Node
## Prepared real-Main selector check, not a natural route or rendered screen.
## Run only through the existing pre-autoload isolated QA bootstrap.
const MAIN = preload("res://scenes/MainGame.gd")
const STORY = preload("res://scenes/StoryMode.gd")
const PERSON_DEAL_ID := "arc_36_unexpected_hand_person_deal"
const PERSON_DEAL_LOCALES := ["ko", "en", "ja", "zh-CN", "zh-TW"]
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
	var game: Node = MAIN.new()
	for slot: Dictionary in SLOTS:
		for relationship: Dictionary in RELATIONSHIPS:
			_check(game, slot, relationship, false)
			if slot.has("missed_flag"):
				_check(game, slot, relationship, true)
	var story: Node = STORY.new()
	_check_person_deal_locales(game, story)
	story.free()
	game.free()
	GameState.flags = old_flags
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
	print("CHAPTER_FOUR_RELATIONSHIP_RESTORED=" + str(restored))
	if not failures.is_empty():
		for failure: String in failures:
			push_error("CHAPTER_FOUR_RELATIONSHIP_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("CHAPTER_FOUR_PERSON_DEAL_CHECK_OK locales=5 cases=65 prepared_component_only=true")
	print("CHAPTER_FOUR_RELATIONSHIP_CHECK_OK normal_cases=48 missed_cases=16 prepared_component_only=true")
	get_tree().quit(0)
