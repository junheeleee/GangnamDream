extends "res://tools/ProseRecallCheck.gd"
## Exact first-win facts; prepared components only, never a natural or rendered run.
## Reuse the proven state reset/restoration helpers, not the old fixture population.
const WIN_IDS := ["arc_first_real_win", "arc_first_real_win_father_passed"]
const WIN_POPULATION := {"loaded": 10, "route": 100, "choice": 20, "reentry": 20}
const WIN_COST := {"ko": "15,000원짜리", "en": "15,000-won", "ja": "15000ウォン",
	"zh-CN": "15000韩元", "zh-TW": "1萬5千韓元"}
const WIN_HOME := {"ko": "집으로 돌아와", "en": "Back home,", "ja": "家に戻って",
	"zh-CN": "回到家，", "zh-TW": "回到家"}
const WIN_THRESHOLD := 50_000_000.0


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
	print("FIRST_WIN_FACT_CASE=" + JSON.stringify(row))


func _win_source(language: String) -> Dictionary:
	var directory: String = "events" if language == "ko" else "events_" + language
	var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(
		"res://content/%s/arc_midgame.json" % directory))
	var result: Dictionary = {}
	if not raw is Array:
		failures.append("missing source " + language)
		return result
	for event: Dictionary in raw:
		if str(event.get("id", "")) in WIN_IDS:
			result[str(event["id"])] = event
	return result


func _win_loaded(ko: Dictionary, localized: Dictionary) -> void:
	for event_id: String in WIN_IDS:
		var event: Dictionary = DataRegistry.find_event(event_id)
		var source: Dictionary = localized.get(event_id, {})
		var original: Dictionary = ko.get(event_id, {})
		var choices: Array = event.get("choices", [])
		var text: String = str(choices[0].get("result_text", "")) if not choices.is_empty() else ""
		var sibling: Dictionary = DataRegistry.find_event(WIN_IDS[1] if event_id == WIN_IDS[0] else WIN_IDS[0])
		var sibling_choices: Array = sibling.get("choices", [])
		var sibling_text: String = str(sibling_choices[0].get("result_text", "")) \
			if not sibling_choices.is_empty() else ""
		var text_equal: bool = _source_text_matches(event, source)
		var gameplay_equal: bool = _ordered_equal(_gameplay(event), _gameplay(original))
		_case("loaded", event_id, not source.is_empty() and not original.is_empty()
			and text_equal and gameplay_equal and not text.is_empty() and text == sibling_text
			and text.contains(str(WIN_COST[LocaleManager.language]))
			and text.contains(str(WIN_HOME[LocaleManager.language]))
			and event.get("background", "") == "current_housing", {
			"event": event_id, "text_equal": text_equal, "gameplay_equal": gameplay_equal,
			"result_sha256": text.sha256_text(), "sibling_sha256": sibling_text.sha256_text(),
			"background": event.get("background", ""),
		})


func _win_prepare(turn: int, assets: float, passed: bool, home: String, seen: bool) -> void:
	_prepare(turn)
	GameState.flags = closed_flags.duplicate(true)
	GameState.flags["arc_first_real_win_seen"] = seen
	GameState.flags["father_passed"] = passed
	GameState.cast["father"]["stage"] = "passed" if passed else "health_crisis"
	GameState.money = assets
	GameState.housing = home


func _win_routes(game: Node) -> void:
	var scenarios := [
		{"label": "before_week", "turn": 14, "assets": WIN_THRESHOLD, "seen": false, "eligible": false},
		{"label": "below_assets", "turn": 15, "assets": WIN_THRESHOLD - 1.0, "seen": false, "eligible": false},
		{"label": "at_assets", "turn": 15, "assets": WIN_THRESHOLD, "seen": false, "eligible": true},
		{"label": "above_assets", "turn": 15, "assets": WIN_THRESHOLD + 1.0, "seen": false, "eligible": true},
		{"label": "seen", "turn": 15, "assets": WIN_THRESHOLD, "seen": true, "eligible": false},
	]
	for passed: bool in [false, true]:
		for home: String in ["gosiwon", "oneroom"]:
			for row: Dictionary in scenarios:
				_win_prepare(int(row["turn"]), float(row["assets"]), passed, home, bool(row["seen"]))
				var before: Dictionary = GameState.serialize().duplicate(true)
				var assets: float = GameState.get_total_asset_value()
				var actual: String = game.call("_next_arc_id", int(row["turn"]), true, false)
				var expected: String = WIN_IDS[1] if passed else WIN_IDS[0]
				var eligible: bool = bool(row["eligible"])
				_case("route", "%s/%s/%s" % [str(passed), home, str(row["label"])],
					(actual == expected if eligible else not actual in WIN_IDS)
					and assets == float(row["assets"]) and GameState.serialize() == before, {
					"turn": row["turn"], "assets": assets, "father_passed": passed, "housing": home,
					"seen": row["seen"], "eligible": eligible, "expected_if_eligible": expected,
					"actual": actual, "state_unchanged": GameState.serialize() == before,
				})


func _win_choices(game: Node) -> void:
	for passed: bool in [false, true]:
		for home: String in ["gosiwon", "oneroom"]:
			_win_prepare(15, WIN_THRESHOLD, passed, home, false)
			var event_id: String = WIN_IDS[1] if passed else WIN_IDS[0]
			var event: Dictionary = DataRegistry.find_event(event_id)
			var choice: Dictionary = event["choices"][0]
			var expected: Dictionary = _choice_snapshot()
			expected["money"] = float(expected["money"]) - 15_000.0
			expected["mental"] = clampi(int(expected["mental"]) + 12, 0, 100)
			expected["flags"]["arc_first_real_win_seen"] = true
			var available: bool = GameState.choice_available(event, choice)
			var committed: bool = GameState.apply_choice(event, choice)
			var actual: Dictionary = _choice_snapshot()
			var receipt: Dictionary = GameState.event_log.back() if not GameState.event_log.is_empty() else {}
			var result: String = str(choice.get("result_text", ""))
			_case("choice", "%s/%s" % [event_id, home], available and committed
				and choice.get("effects", {}) == {"mental": 12.0, "money": -15000.0}
				and choice.get("flags", []) == ["arc_first_real_win_seen"]
				and actual == expected and GameState.housing == home and GameState.events_seen == 1
				and str(receipt.get("event_id", "")) == event_id
				and int(receipt.get("choice_index", -1)) == 0, {
				"event": event_id, "housing": home, "available": available, "committed": committed,
				"expected_sha256": JSON.stringify(expected).sha256_text(),
				"actual_sha256": JSON.stringify(actual).sha256_text(), "snapshot_equal": actual == expected,
				"mental": GameState.mental, "money": GameState.money, "events_seen": GameState.events_seen,
				"receipt_index": receipt.get("choice_index", -1), "result_sha256": result.sha256_text(),
			})
			# Prepared eligibility restoration only, NOT a product refund. Otherwise
			# the spend itself would hide a broken seen-reader below the threshold.
			var spent_cash: float = GameState.money
			GameState.money = WIN_THRESHOLD
			var before: Dictionary = GameState.serialize().duplicate(true)
			var selected: String = game.call("_next_arc_id", 15, true, false)
			_case("reentry", "%s/%s" % [event_id, home], committed
				and spent_cash == WIN_THRESHOLD - 15_000.0
				and GameState.get_total_asset_value() == WIN_THRESHOLD
				and bool(GameState.flags.get("arc_first_real_win_seen", false))
				and not selected in WIN_IDS and GameState.serialize() == before, {
				"event": event_id, "housing": home, "spent_cash": spent_cash,
				"prepared_cash_restore": WIN_THRESHOLD, "actual": selected,
				"state_unchanged": GameState.serialize() == before,
			})


func _run() -> void:
	var qa_namespace474: String = OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	if not qa_namespace474.begins_with("GangnamDream_StoryNameplateQA_") \
			or OS.get_user_data_dir().get_file() != qa_namespace474:
		push_error("FIRST_WIN_FACT_CHECK_FAIL pre-autoload isolation missing")
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
	var ko: Dictionary = _win_source("ko")
	for language: String in LOCALES:
		LocaleManager.language = language
		DataRegistry.reload()
		_win_loaded(ko, _win_source(language))
		closed_flags = {}
		_build_closed_flags()
		_win_routes(game)
		_win_choices(game)
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
	print("FIRST_WIN_FACT_RESTORED=" + JSON.stringify(restored))
	if not restored:
		failures.append("singleton restoration failed")
	if counts != WIN_POPULATION or case_ids.size() != 150:
		failures.append("case population drift: " + JSON.stringify(counts))
	print("FIRST_WIN_FACT_POPULATION=" + JSON.stringify(counts))
	if not failures.is_empty():
		for failure: String in failures:
			push_error("FIRST_WIN_FACT_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("FIRST_WIN_FACT_CHECK_OK locales=5 cases=150 loaded=10 route=100 choice=20 reentry=20 prepared_component_only=true")
	get_tree().quit(0)
