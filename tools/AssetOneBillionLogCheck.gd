extends "res://tools/ProseRecallCheck.gd"
## Prepared real check_game_over/add_log only; no natural month, screen or input.
const ONE_BILLION_POPULATION := {"threshold": 40, "net_debt": 5, "restore": 5}
const LOCALE_STATE := ["language", "content_revision", "_builtin_ui_tables",
	"_community_ui_tables", "_ui_misses", "_ui_format_errors"]
const MILESTONE_KEY := "💰 자산 10억 돌파 — 30억의 3분의 1."
const MESSAGES := {
	"ko": MILESTONE_KEY,
	"en": "💰 Assets passed KRW 1B — one third of the goal.",
	"ja": "💰 資産が10億ウォンを突破 — 30億ウォンの3分の1。",
	"zh-CN": "💰 资产突破10亿韩元 — 30亿韩元的三分之一。",
	"zh-TW": "💰 資產突破10億韓元 — 30億韓元的三分之一。",
}
var test_language: String = ""

func _case(group: String, label: String, passed: bool, details: Dictionary) -> void:
	var identifier: String = "%s/%s/%s" % [group, test_language, label]
	if case_ids.has(identifier): failures.append("duplicate case " + identifier)
	case_ids[identifier] = true
	counts[group] = int(counts.get(group, 0)) + 1
	if not passed: failures.append(identifier + " " + JSON.stringify(details))
	var row: Dictionary = details.duplicate(true)
	row.merge({"id": identifier, "group": group, "locale": test_language,
		"passed": passed}, true)
	print("ASSET_ONE_BILLION_LOG_CASE=" + JSON.stringify(row))

func _check(group: String, label: String, cash: float, debt: float,
		already: bool) -> void:
	_prepare(49)
	GameState.money = cash
	GameState.loans = {"bank": debt, "second": 0.0}
	GameState.peak_asset = 750_000_000.0
	GameState.addiction_tendency = 30
	GameState.flags = {"asset_100m_reached": true, "asset_500m_reached": true,
		"asset_2b_reached": true, "asset_2_7b_reached": true,
		"asset_1b_reached": already}
	GameState.action_log = [{"turn": 48, "date": "prepared legacy date",
		"message": "legacy milestone record", "type": "money"}]
	var before: Dictionary = GameState.serialize().duplicate(true)
	var expected: Dictionary = before.duplicate(true)
	var net: float = cash - debt
	var emits: bool = net >= 1_000_000_000.0 and not already
	var date: String = GameState.get_date_string()
	var expected_entries: Array = []
	if emits:
		expected["flags"]["asset_1b_reached"] = true
		var entry: Dictionary = {"turn": 49, "date": date,
			"message": MESSAGES[test_language], "type": "money"}
		expected["action_log"].append(entry)
		expected_entries.append(entry)
	expected["peak_asset"] = maxf(float(before["peak_asset"]), net)
	var emitted: Array = []
	var on_log: Callable = func(entry: Dictionary) -> void: emitted.append(entry.duplicate(true))
	GameState.log_added.connect(on_log)
	var actual_net: float = GameState.get_total_asset_value()
	GameState.check_game_over()
	GameState.log_added.disconnect(on_log)
	var after: Dictionary = GameState.serialize().duplicate(true)
	var target_miss: bool = LocaleManager.get_ui_misses(test_language).has(MILESTONE_KEY)
	var passed: bool = actual_net == net and after == expected \
		and emitted == expected_entries and not GameState.is_game_over and not target_miss
	_case(group, label, passed, {"cash": cash, "loan": debt, "net": actual_net,
		"prepared_already": already, "expected_emissions": int(emits),
		"actual_emissions": emitted.size(), "actual_entries": emitted,
		"expected_entries": expected_entries, "whole_serialized_state_matches": after == expected,
		"flag_after": GameState.flags["asset_1b_reached"], "peak_after": GameState.peak_asset,
		"target_fallback_miss": target_miss, "ending_unchanged": not GameState.is_game_over,
		"routing_preparation": "age34/turn49; final_week flag absent; no ending predicate replaced"})

func _run() -> void:
	var qa_namespace: String = OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	if not qa_namespace.begins_with("GangnamDream_StoryNameplateQA_") \
			or OS.get_user_data_dir().get_file() != qa_namespace:
		push_error("ASSET_ONE_BILLION_LOG_CHECK_FAIL pre-autoload isolation missing")
		get_tree().quit(1)
		return
	print("STORY_NAMEPLATE_QA_USER_DIR=" + OS.get_user_data_dir())
	initial_game = GameState.serialize().duplicate(true)
	initial_transients = _snapshot_properties(GameState, TRANSIENTS)
	initial_events = _snapshot_properties(EventManager, EVENT_STATE)
	var locale_snapshot: Dictionary = _snapshot_properties(LocaleManager, LOCALE_STATE)
	var old_meta: Dictionary = MetaProgression.data.duplicate(true)
	var old_unlocks: Dictionary = MetaProgression.get("_new_this_run").duplicate(true)
	var threshold_values := {"below10": 999_999_999.0, "exact10": 1_000_000_000.0,
		"above15": 1_500_000_000.0, "goal30": 3_000_000_000.0}
	for language: String in LOCALES:
		test_language = language
		LocaleManager.language = language
		for label: String in threshold_values:
			for already: bool in [false, true]:
				_check("threshold", label + ("/already" if already else "/first"),
					float(threshold_values[label]), 0.0, already)
		_check("net_debt", "cash11_minus_loan2", 1_100_000_000.0, 200_000_000.0, false)
		_restore_properties(GameState, initial_game)
		_restore_properties(GameState, initial_transients)
		_restore_properties(EventManager, initial_events)
		_restore_properties(LocaleManager, locale_snapshot)
		var restored: bool = GameState.serialize() == initial_game \
			and _snapshot_properties(GameState, TRANSIENTS) == initial_transients \
			and _snapshot_properties(EventManager, EVENT_STATE) == initial_events \
			and _snapshot_properties(LocaleManager, LOCALE_STATE) == locale_snapshot \
			and MetaProgression.data == old_meta and MetaProgression.get("_new_this_run") == old_unlocks
		_case("restore", "singletons", restored, {"restored": restored,
			"natural_month_observation": false, "render_input_observation": false,
			"saved_language_write": false})
	if counts != ONE_BILLION_POPULATION or case_ids.size() != 50:
		failures.append("case population drift: " + JSON.stringify(counts))
	print("ASSET_ONE_BILLION_LOG_POPULATION=" + JSON.stringify(counts))
	if not failures.is_empty():
		for failure: String in failures: push_error("ASSET_ONE_BILLION_LOG_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("ASSET_ONE_BILLION_LOG_CHECK_OK locales=5 cases=50 threshold=40 net_debt=5 restore=5 prepared_component_only=true")
	get_tree().quit(0)
