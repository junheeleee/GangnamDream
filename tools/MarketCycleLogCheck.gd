extends "res://tools/ProseRecallCheck.gd"
## Prepared real log producer only; no monthly progression, rendering or input.
const INVESTMENT := preload("res://systems/InvestmentSystem.gd")
const MARKET_POPULATION := {"roll_log": 15, "unknown": 5, "restore": 5}
const LOCALE_STATE := ["language", "content_revision", "_builtin_ui_tables",
	"_community_ui_tables", "_ui_misses", "_ui_format_errors"]
const LABELS := {
	"ko": ["상승장", "하락장", "횡보장"],
	"en": ["Bull Market", "Bear Market", "Sideways"],
	"ja": ["上昇相場", "下落相場", "横ばい相場"],
	"zh-CN": ["牛市", "熊市", "横盘行情"],
	"zh-TW": ["多頭市場", "空頭市場", "盤整"],
}
const PARENTS := {
	"ko": "시장 국면 전환: %s", "en": "Market cycle shifted: %s",
	"ja": "市場局面転換: %s", "zh-CN": "市场行情转变：%s",
	"zh-TW": "市場局勢轉變: %s",
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
	print("MARKET_CYCLE_LOG_CASE=" + JSON.stringify(row))

func _legacy_roll(fixed_seed: int) -> Dictionary:
	seed(fixed_seed)
	var timer: int = randi_range(5, 11)
	var roll: float = randf()
	var cycle: String = "neutral"
	if roll < 0.25: cycle = "bear"
	elif roll > 0.72: cycle = "bull"
	return {"timer": timer, "cycle": cycle, "next": randi()}

func _seed_for_cycle(cycle: String) -> int:
	for fixed_seed: int in range(1, 101):
		if _legacy_roll(fixed_seed)["cycle"] == cycle: return fixed_seed
	failures.append("no deterministic legacy seed for " + cycle)
	return 1

func _market_consumers() -> void:
	var investment: Node = INVESTMENT.new()
	for index: int in range(3):
		var cycle: String = ["bull", "bear", "neutral"][index]
		_prepare(17)
		GameState.portfolio = {"samsung": {"quantity": 1.0, "avg_price": 70000.0}}
		GameState.market_prices = {"samsung": 63000.0}
		GameState.market_context = {"fear_greed": 50, "cycle": "prior_cycle", "crash_risk": 0.4}
		GameState.action_log = [{"turn": 16, "date": "prepared legacy date",
			"message": "legacy neutral", "type": "market"}]
		investment.set("cycle_timer", 99)
		var before: Dictionary = GameState.serialize().duplicate(true)
		var date: String = GameState.get_date_string()
		var emitted: Array = []
		var on_log: Callable = func(entry: Dictionary) -> void: emitted.append(entry.duplicate(true))
		GameState.log_added.connect(on_log)
		var fixed_seed: int = _seed_for_cycle(cycle)
		var expected: Dictionary = _legacy_roll(fixed_seed)
		seed(fixed_seed)
		investment.call("_roll_cycle")
		var actual_next: int = randi()
		GameState.log_added.disconnect(on_log)
		var expected_message: String = PARENTS[test_language] % LABELS[test_language][index]
		var entry: Dictionary = GameState.action_log.back()
		var expected_entry: Dictionary = {"turn": 17, "date": date,
			"message": expected_message, "type": "market"}
		var after: Dictionary = GameState.serialize().duplicate(true)
		var context: Dictionary = GameState.market_context.duplicate(true)
		after["action_log"] = before["action_log"].duplicate(true)
		after["market_context"] = before["market_context"].duplicate(true)
		var passed: bool = context == {"fear_greed": 50, "cycle": cycle, "crash_risk": 0.02,
			"cycle_timer": expected["timer"]} \
			and investment.get("cycle_timer") == expected["timer"] \
			and actual_next == expected["next"] and expected["cycle"] == cycle \
			and GameState.action_log.size() == before["action_log"].size() + 1 \
			and GameState.action_log.slice(0, before["action_log"].size()) == before["action_log"] \
			and entry == expected_entry and emitted == [expected_entry] and after == before
		_case("roll_log", cycle, passed, {"seed": fixed_seed, "cycle": context["cycle"],
			"timer": investment.get("cycle_timer"), "legacy_timer": expected["timer"],
			"next_rng": actual_next, "legacy_next_rng": expected["next"],
			"actual_entry": entry, "expected_entry": expected_entry,
			"only_log_and_context_changed": after == before, "signal_count": emitted.size()})
	var unknown_before: PackedByteArray = var_to_bytes(GameState.serialize())
	var locale_before: Dictionary = _snapshot_properties(LocaleManager, LOCALE_STATE)
	var timer_before: int = int(investment.get("cycle_timer"))
	seed(478)
	var expected_next: int = randi()
	seed(478)
	var unknown: String = investment.call("_cycle_display_name", "future_cycle")
	var unknown_next: int = randi()
	_case("unknown", "future_cycle", unknown == "future_cycle" and unknown_next == expected_next \
		and var_to_bytes(GameState.serialize()) == unknown_before \
		and _snapshot_properties(LocaleManager, LOCALE_STATE) == locale_before \
		and investment.get("cycle_timer") == timer_before,
		{"actual": unknown, "rng_unchanged": unknown_next == expected_next,
		"state_unchanged": var_to_bytes(GameState.serialize()) == unknown_before})
	investment.free()

func _run() -> void:
	var namespace478: String = OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	if not namespace478.begins_with("GangnamDream_StoryNameplateQA_") \
			or OS.get_user_data_dir().get_file() != namespace478:
		push_error("MARKET_CYCLE_LOG_CHECK_FAIL pre-autoload isolation missing")
		get_tree().quit(1)
		return
	print("STORY_NAMEPLATE_QA_USER_DIR=" + OS.get_user_data_dir())
	initial_game = GameState.serialize().duplicate(true)
	initial_transients = _snapshot_properties(GameState, TRANSIENTS)
	initial_events = _snapshot_properties(EventManager, EVENT_STATE)
	var locale_snapshot: Dictionary = _snapshot_properties(LocaleManager, LOCALE_STATE)
	var old_meta: Dictionary = MetaProgression.data.duplicate(true)
	var old_unlocks: Dictionary = MetaProgression.get("_new_this_run").duplicate(true)
	for language: String in LOCALES:
		test_language = language
		LocaleManager.language = language
		_market_consumers()
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
			"global_rng_restoration_claim": false, "saved_language_write": false})
	if counts != MARKET_POPULATION or case_ids.size() != 25:
		failures.append("case population drift: " + JSON.stringify(counts))
	print("MARKET_CYCLE_LOG_POPULATION=" + JSON.stringify(counts))
	if not failures.is_empty():
		for failure: String in failures: push_error("MARKET_CYCLE_LOG_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("MARKET_CYCLE_LOG_CHECK_OK locales=5 cases=25 roll_log=15 unknown=5 restore=5 prepared_component_only=true")
	get_tree().quit(0)
