extends Node
## Prepared real-Main selector check, not a natural route or rendered screen.
## Run only through the existing pre-autoload isolated QA bootstrap.
const MAIN = preload("res://scenes/MainGame.gd")
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
var failures: Array[String] = []
var normal_cases := 0
var missed_cases := 0

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
	var game: Node = MAIN.new()
	for slot: Dictionary in SLOTS:
		for relationship: Dictionary in RELATIONSHIPS:
			_check(game, slot, relationship, false)
			if slot.has("missed_flag"):
				_check(game, slot, relationship, true)
	game.free()
	GameState.flags = old_flags
	var restored: bool = GameState.serialize() == old_state \
		and MetaProgression.data == old_meta \
		and MetaProgression.get("_new_this_run") == old_unlocks
	if not restored:
		failures.append("singleton GameState/MetaProgression changed by prepared fixture")
	if normal_cases != 48 or missed_cases != 16:
		failures.append("prepared case population drifted")
	print("CHAPTER_FOUR_RELATIONSHIP_RESTORED=" + str(restored))
	if not failures.is_empty():
		for failure: String in failures:
			push_error("CHAPTER_FOUR_RELATIONSHIP_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("CHAPTER_FOUR_RELATIONSHIP_CHECK_OK normal_cases=48 missed_cases=16 prepared_component_only=true")
	get_tree().quit(0)
