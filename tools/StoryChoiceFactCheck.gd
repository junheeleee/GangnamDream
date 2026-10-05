extends Node
## Prepared component evidence, not natural play or a rendered UI observation.
## Run only through the pre-autoload isolated QA bootstrap.
const STORY := preload("res://scenes/StoryMode.gd")
const AFTERMATH := "arc_jaehyuk_aftermath"
const ECHO := "arc_daeun_later_echo"
const JAEHYUK_FLAGS := [
	"jaehyuk_reported", "took_high_road", "jaehyuk_exploited",
	"jaehyuk_partnered", "jaehyuk_scammed",
]
const BREAKUPS := [
	"daeun_let_her_go", "daeun_breakup_accepted", "daeun_breakup_begged",
	"daeun_let_drift", "daeun_asked_finally", "daeun_romance_blocked",
	"daeun_divorced", "arc_daeun_year3_apart_seen", "arc_daeun_ghost_seen",
	"arc_daeun_year5_apart_seen",
]
var failures: Array[String] = []
var cases := 0


func _ready() -> void:
	call_deferred("_run")


func _expect(passed: bool, label: String) -> void:
	cases += 1
	if not passed:
		failures.append(LocaleManager.language + "/" + label)


func _restore_game(snapshot: Dictionary) -> void:
	for key in snapshot:
		var value: Variant = snapshot[key]
		GameState.set(str(key), value.duplicate(true)
			if value is Dictionary or value is Array else value)


func _rejected(event: Dictionary, choice: Dictionary, label: String) -> void:
	var before: Dictionary = GameState.serialize().duplicate(true)
	var cooldowns: Dictionary = EventManager.event_cooldowns.duplicate(true)
	var recent: Array = EventManager.recent_event_ids.duplicate(true)
	var meta: Dictionary = MetaProgression.data.duplicate(true)
	_expect(not GameState.apply_choice(event, choice), label + "/direct reject")
	_expect(GameState.serialize() == before
		and EventManager.event_cooldowns == cooldowns
		and EventManager.recent_event_ids == recent
		and MetaProgression.data == meta, label + "/rejection is inert")


func _visible(story: Node, event: Dictionary, prepared: Dictionary,
		expected: Array, label: String) -> void:
	GameState.flags = prepared.duplicate(true)
	story.set("_current", event)
	story.set("_read_only_replay", false)
	var before: Dictionary = GameState.serialize().duplicate(true)
	var actual: Array = story.call("_visible_choice_indices", event)
	var gallery_live: Array = story.call("_live_gallery_visible_choice_indices", event)
	_expect(actual == expected and gallery_live == expected,
		label + "/visible=%s expected=%s" % [str(actual), str(expected)])
	_expect(GameState.serialize() == before, label + "/pure visibility")
	for index in range((event["choices"] as Array).size()):
		var choice: Dictionary = event["choices"][index]
		_expect(GameState.choice_available(event, choice) == expected.has(index),
			label + "/gate %d" % index)
		if not expected.has(index):
			_rejected(event, choice, label + "/choice %d" % index)


func _check_facts(story: Node, aftermath: Dictionary, echo: Dictionary) -> void:
	for mask in range(32):
		var prepared := {}
		for index in range(JAEHYUK_FLAGS.size()):
			prepared[JAEHYUK_FLAGS[index]] = bool(mask & (1 << index))
		var expected: Array = []
		if mask & 3:
			expected.append(0)
		if mask & 12:
			expected.append(1)
		if mask & 16:
			expected.append(2)
		if mask == 0:
			expected.append(3)
		_visible(story, aftermath, prepared, expected, "Jaehyuk mask %d" % mask)
	_visible(story, aftermath, {}, [3], "unknown")
	_visible(story, aftermath, {"crossed_line": true}, [3], "unrelated moral history")
	_visible(story, aftermath, {"take_high_road": true}, [3], "nonexistent alias")
	for flag_id: String in JAEHYUK_FLAGS:
		for bad in [null, 0, 1, "true", [], {}]:
			_visible(story, aftermath, {flag_id: bad}, [], "bad " + flag_id + str(bad))
	_visible(story, echo, {}, [1], "no Daeun history")
	_visible(story, echo, {"daeun_romance_started": true}, [0, 1], "Daeun started")
	_visible(story, echo, {"daeun_romance_started": false}, [1], "Daeun false")
	_visible(story, echo, {"daeun_romance_started": true, "daeun_ended": true},
		[0, 1], "shared ended is not breakup")
	for flag_id: String in BREAKUPS:
		_visible(story, echo, {"daeun_romance_started": true, flag_id: false},
			[0, 1], "inactive breakup " + flag_id)
		for value in [true, null, 1, "false"]:
			_visible(story, echo, {"daeun_romance_started": true, flag_id: value},
				[1], "breakup priority " + flag_id + str(value))
	for flag_id in ["daeun_married", "daeun_close_bond", "daeun_together_path"]:
		_visible(story, echo, {flag_id: true}, [1], "not a positive " + flag_id)
	for bad in [null, 1, "true", [], {}]:
		_visible(story, echo, {"daeun_romance_started": bad}, [1], "bad started")


func _check_bad_contract(story: Node, aftermath: Dictionary) -> void:
	GameState.flags = {}
	var neutral: Dictionary = aftermath["choices"][3]
	_rejected(aftermath, neutral.duplicate(true), "detached equal choice")
	for bad in [null, true, 1, "", "unknown", "jaehyuk_used", [], {}]:
		var mutated: Dictionary = aftermath.duplicate(true)
		mutated["choices"][0]["requires_story_fact"] = bad
		_visible(story, mutated, {}, [], "malformed marker " + str(bad))
	var missing: Dictionary = aftermath.duplicate(true)
	missing["choices"][0].erase("requires_story_fact")
	_visible(story, missing, {}, [], "missing required marker")
	var duplicate: Dictionary = aftermath.duplicate(true)
	duplicate["choices"][0] = duplicate["choices"][3]
	_visible(story, duplicate, {}, [], "duplicate choice")
	for structure in [null, {}, [], [null], [neutral, neutral]]:
		var malformed := {"id": AFTERMATH, "choices": structure}
		_expect(not GameState.choice_available(malformed, neutral), "bad choice structure gate")
		_expect(not story.call("_live_gallery_choice_visible", malformed, neutral),
			"bad choice structure live gallery gate")
		_rejected(malformed, neutral, "bad choice structure")
	var unrelated := {"id": "qa_unrelated", "choices": []}
	_expect(GameState.choice_available(unrelated, {"text": "ordinary"}),
		"unrelated detached choice compatibility")
	_rejected(unrelated, neutral, "marker on unrelated event")


func _check_receipts(story: Node, aftermath: Dictionary) -> void:
	var baseline: Dictionary = GameState.serialize().duplicate(true)
	var histories := [{"jaehyuk_reported": true}, {"jaehyuk_partnered": true},
		{"jaehyuk_scammed": true}, {}]
	for index in range(4):
		_restore_game(baseline)
		GameState.flags = histories[index].duplicate(true)
		GameState.turn = 130
		GameState.mental = 50
		GameState.reputation = 50
		GameState.deferred_events = []
		var choice: Dictionary = aftermath["choices"][index]
		var money_before: float = GameState.money
		var tint_before: float = GameState.moral_tint
		_expect(GameState.apply_choice(aftermath, choice), "allowed direct commit %d" % index)
		_expect(GameState.event_log.back().get("choice_index", -1) == index,
			"original receipt index %d" % index)
		_expect(GameState.deferred_events == [{"event_id": "arc_jaehyuk_mirror",
			"trigger_turn": 131}], "single mirror scheduled %d" % index)
		if index == 3:
			_expect(GameState.flags == {"arc_jaehyuk_aftermath_seen": true}
				and GameState.money == money_before and GameState.mental == 50
				and GameState.reputation == 50 and GameState.moral_tint == tint_before,
				"neutral invents no past or reward")
		GameState.turn = 131
		_expect(not GameState.claim_deferred_event("arc_jaehyuk_mirror", 131).is_empty()
			and GameState.claim_deferred_event("arc_jaehyuk_mirror", 131).is_empty(),
			"mirror claimed exactly once %d" % index)
		# Result restoration and frozen replay read receipts, never today's flags.
		GameState.flags = {"jaehyuk_reported": "corrupt current history"}
		_expect(story.call("_applied_result_choice_receipt_matches",
			AFTERMATH, index, choice, {}), "saved result keeps index %d" % index)
		_expect(not story.call("_applied_result_choice_receipt_matches",
			AFTERMATH, (index + 1) % 4, choice, {}), "resume rejects swapped index")
		story.set("_current", aftermath)
		story.set("_read_only_replay", true)
		story.set("_gallery_replay_snapshot", {"visible_choice_indices": {AFTERMATH: [index]}})
		var before: Dictionary = GameState.serialize().duplicate(true)
		_expect(story.call("_visible_choice_indices", aftermath) == [index]
			and GameState.serialize() == before, "frozen gallery consumer %d" % index)
	story.set("_read_only_replay", false)
	_restore_game(baseline)


func _check_mods(aftermath: Dictionary, echo: Dictionary) -> void:
	for base: Dictionary in [aftermath, echo]:
		var source := {"id": base["id"], "override": true, "choices": []}
		for choice: Dictionary in base["choices"]:
			source["choices"].append({"text": choice["text"], "result_text": choice["result_text"]})
		var merged: Dictionary = DataRegistry._merge_mod_event_override(base, source, "qa_story_fact")
		_expect(not merged.is_empty() and DataRegistry.story_choice_fact_layout_valid(merged),
			"marker-less text mod inherits exact gates")
		if base["id"] == AFTERMATH:
			source["choices"].pop_back()
			merged = DataRegistry._merge_mod_event_override(base, source, "qa_legacy_aftermath")
			_expect(not merged.is_empty() and merged["choices"].size() == 4
				and merged["choices"][3] == base["choices"][3], "legacy mod retains neutral verbatim")
			if not merged.is_empty():
				GameState.flags = {}
				_expect(GameState.choice_available(merged, merged["choices"][3])
					and not GameState.choice_available(merged, merged["choices"][0]),
					"legacy mod cannot bypass or lose the neutral gate")
		for gate in [{"requires_item": "ticket"}, {"opportunity": {"cost": 999999999}},
				{"opportunity_unavailable_fallback": true}]:
			var extra_gate: Dictionary = source.duplicate(true)
			extra_gate["choices"][0].merge(gate)
			_expect(DataRegistry._merge_mod_event_override(base, extra_gate, "qa_extra_gate").is_empty(),
				"extra gate cannot hide the only factual choice")
			GameState.flags = {"jaehyuk_reported": true, "daeun_romance_started": true}
			GameState.money = 0.0
			GameState.inventory = []
			_expect(GameState.choice_available(base, base["choices"][0]),
				"rejected gated override leaves original choice available")
		for marker in [null, true, 1, "", "wrong", "jaehyuk_victim", []]:
			source["choices"][0]["requires_story_fact"] = marker
			_expect(DataRegistry._merge_mod_event_override(base, source, "qa_bad_fact").is_empty(),
				"forged mod marker rejected " + str(marker))
		source["choices"][0].erase("requires_story_fact")
		source["choices"].pop_back()
		_expect(DataRegistry._merge_mod_event_override(base, source, "qa_bad_count").is_empty(),
			"count migration restricted to aftermath 3-to-4")
	var custom := {"text": "custom", "result_text": "custom", "requires_story_fact": "jaehyuk_unknown"}
	_expect(not DataRegistry._mod_choice_valid(custom, {}, {}, "qa_new_fact"),
		"new mod cannot author a story fact marker")


func _check_legacy_availability(story: Node) -> void:
	GameState.flags = {}
	GameState.money = 100.0
	GameState.inventory = []
	var risk := {"text": "Risk", "result_text": "Resolved", "requires_item": "qa_fact_ticket",
		"opportunity": {"cost": 50.0, "success_rate": 0.5, "win_multiplier": 2.0, "loss_ratio": 1.0}}
	var exit_choice := {"text": "Leave", "result_text": "Left", "opportunity_unavailable_fallback": true}
	var event := {"id": "qa_fact_opportunity", "choices": [risk, exit_choice]}
	_visible(story, event, {}, [1], "item missing still exposes old fallback")
	GameState.inventory = [{"id": "qa_fact_ticket", "quantity": 1}]
	_visible(story, event, {}, [0], "funded item still hides old fallback")
	GameState.money = 49.0
	_visible(story, event, {}, [1], "unfunded opportunity still exposes fallback")
	var before: Dictionary = GameState.serialize().duplicate(true)
	_expect(GameState.apply_choice(event, exit_choice), "legacy fallback commits")
	_expect(GameState.money == before["money"] and GameState.flags == before["flags"],
		"legacy fallback has no cash or flag reward")


func _run() -> void:
	var qa_namespace470 := OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	if not qa_namespace470.begins_with("GangnamDream_StoryNameplateQA_") \
			or OS.get_user_data_dir().get_file() != qa_namespace470:
		push_error("STORY_CHOICE_FACT_CHECK_FAIL pre-autoload isolation missing")
		get_tree().quit(1)
		return
	print("STORY_NAMEPLATE_QA_USER_DIR=" + OS.get_user_data_dir())
	var old_game: Dictionary = GameState.serialize().duplicate(true)
	var old_meta: Dictionary = MetaProgression.data.duplicate(true)
	var old_unlocks: Dictionary = MetaProgression.get("_new_this_run").duplicate(true)
	var old_cooldowns: Dictionary = EventManager.event_cooldowns.duplicate(true)
	var old_recent: Array = EventManager.recent_event_ids.duplicate(true)
	var old_language: String = LocaleManager.language
	var story: Node = STORY.new()
	for language in ["ko", "en", "ja", "zh-CN", "zh-TW"]:
		LocaleManager.language = language
		DataRegistry.reload()
		_restore_game(old_game)
		var aftermath: Dictionary = DataRegistry.find_event(AFTERMATH)
		var echo: Dictionary = DataRegistry.find_event(ECHO)
		var valid := DataRegistry.story_choice_fact_layout_valid(aftermath) \
			and DataRegistry.story_choice_fact_layout_valid(echo)
		_expect(valid, "localized source-owned fact layout")
		if not valid:
			continue
		_check_facts(story, aftermath, echo)
		_check_bad_contract(story, aftermath)
		_check_receipts(story, aftermath)
		_check_mods(aftermath, echo)
		_check_legacy_availability(story)
		print("STORY_CHOICE_FACT_LOCALE=" + language + " assertions=" + str(cases))
	story.free()
	LocaleManager.language = old_language
	DataRegistry.reload()
	_restore_game(old_game)
	EventManager.event_cooldowns = old_cooldowns
	EventManager.recent_event_ids = old_recent
	_expect(GameState.serialize() == old_game and MetaProgression.data == old_meta
		and MetaProgression.get("_new_this_run") == old_unlocks, "singleton restoration")
	if not failures.is_empty():
		for failure: String in failures:
			push_error("STORY_CHOICE_FACT_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("STORY_CHOICE_FACT_CHECK_OK locales=5 assertions=%d prepared_component_only=true" % cases)
	get_tree().quit(0)
