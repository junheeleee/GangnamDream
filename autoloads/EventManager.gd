extends Node

signal event_started(event: Dictionary)
signal event_resolved(event: Dictionary, choice: Dictionary)

var pending_events: Array = []
var current_event: Dictionary = {}
var event_cooldowns: Dictionary = {}
var recent_event_ids: Array = []
var narrative_bridge_results: Array = []
var director_rules: Dictionary = {}
var _follow_up_target_ids: Dictionary = {}

const EVENT_DIRECTOR_PATH := "res://content/meta/event_director.json"
const DEMO_CORE_LOOP_V2 := preload("res://systems/DemoCoreLoopV2.gd")

const ECHO_CATEGORY_ALIASES := {
	"career": ["jobs", "job", "work", "career"],
	"daily_life": ["daily_life", "daily", "rest"],
	"family": ["family", "relationship"],
	"finance": ["finance", "investment", "money"],
	"gambling": ["gambling", "casino", "racetrack", "risk"],
	"health": ["health", "rest", "mental"],
	"investment": ["investment", "finance", "risk"],
	"jobs": ["jobs", "job", "work", "career", "spec"],
	"relationship": ["relationship", "romance", "social"],
	"romance": ["romance", "relationship", "social"],
	"self_development": ["self_development", "study", "spec", "health"],
	"social": ["social", "relationship", "network"],
}

const ECHO_TAG_ALIASES := {
	"addiction": ["gambling", "risk"],
	"career": ["jobs", "work"],
	"casino": ["gambling"],
	"commute": ["jobs", "work"],
	"daily": ["daily_life", "rest"],
	"finance": ["investment", "money"],
	"holdem": ["gambling"],
	"job": ["jobs", "work"],
	"mental": ["health", "rest"],
	"network": ["social", "relationship"],
	"racetrack": ["gambling"],
	"romance": ["relationship", "social"],
	"side_job": ["jobs", "finance"],
	"spec": ["jobs", "self_development"],
	"stress": ["health", "rest"],
	"study": ["self_development"],
	"work": ["jobs", "career"],
}

func _ready():
	_load_director_rules()
	GameState.run_started.connect(_on_run_started)

func _on_run_started():
	event_cooldowns.clear()
	recent_event_ids.clear()
	pending_events.clear()
	narrative_bridge_results.clear()
	current_event = {}

func _load_director_rules() -> void:
	var file := FileAccess.open(EVENT_DIRECTOR_PATH, FileAccess.READ)
	if file == null:
		push_error("Event director manifest missing: %s" % EVENT_DIRECTOR_PATH)
		director_rules = {}
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		director_rules = parsed
		_rebuild_follow_up_targets()
		return
	push_error("Event director manifest is not a dictionary: %s" % EVENT_DIRECTOR_PATH)
	director_rules = {}
	_follow_up_target_ids.clear()

func _rebuild_follow_up_targets() -> void:
	_follow_up_target_ids.clear()
	for event in DataRegistry.events:
		var event_follow_up := str(event.get("follow_up_event", ""))
		if not event_follow_up.is_empty():
			_follow_up_target_ids[event_follow_up] = true
		for choice_value in event.get("choices", []):
			var choice: Dictionary = choice_value
			var immediate_target := str(choice.get("follow_up_event", ""))
			if not immediate_target.is_empty():
				_follow_up_target_ids[immediate_target] = true
			for deferred_value in DataRegistry.deferred_follow_ups(choice):
				var target := str((deferred_value as Dictionary).get("event_id", ""))
				if not target.is_empty():
					_follow_up_target_ids[target] = true

func is_directed_random_event(event: Dictionary) -> bool:
	var event_id := str(event.get("id", ""))
	if event_id.is_empty() or DataRegistry.find_event(event_id).is_empty():
		return false
	if str(event.get("rarity", "")) == "story" \
			or str(event.get("category", "")) == "story" \
			or float(event.get("weight", 1.0)) <= 0.0:
		return false
	var scope: Dictionary = director_rules.get("scope", {})
	for raw_prefix in scope.get("excluded_id_prefixes", []):
		if event_id.begins_with(str(raw_prefix)):
			return false
	if bool(scope.get("exclude_follow_up_targets", true)) \
			and _follow_up_target_ids.has(event_id):
		return false
	return true

func _matching_director_row(rows: Array, value: float) -> Dictionary:
	for row_value in rows:
		if not row_value is Dictionary:
			continue
		var row: Dictionary = row_value
		if row.has("min_turn") and value < float(row["min_turn"]):
			continue
		if row.has("max_turn") and value > float(row["max_turn"]):
			continue
		if row.has("min_assets") and value < float(row["min_assets"]):
			continue
		# Asset bands use an exclusive ceiling so adjacent rows never overlap.
		if row.has("max_assets") and value >= float(row["max_assets"]):
			continue
		return row
	return {}

func _director_chapter_row(turn_value: int = -1) -> Dictionary:
	var resolved_turn: int = GameState.turn if turn_value < 0 else turn_value
	return _matching_director_row(director_rules.get("chapter_windows", []), float(resolved_turn))

func _director_asset_row(asset_value: float = -1.0e30) -> Dictionary:
	var resolved_assets: float = GameState.get_total_asset_value() if asset_value <= -1.0e29 else asset_value
	return _matching_director_row(director_rules.get("asset_bands", []), resolved_assets)

func director_chapter_id(turn_value: int = -1) -> String:
	return str(_director_chapter_row(turn_value).get("id", ""))

func director_asset_band_id(asset_value: float = -1.0e30) -> String:
	return str(_director_asset_row(asset_value).get("id", ""))

func demo_pacing_rules() -> Dictionary:
	var pacing: Variant = director_rules.get("demo_pacing", {})
	return (pacing as Dictionary).duplicate(true) if pacing is Dictionary else {}

func full_run_pacing_rules() -> Dictionary:
	var pacing: Variant = director_rules.get("full_run_pacing", {})
	return (pacing as Dictionary).duplicate(true) if pacing is Dictionary else {}

func content_diet_rules() -> Dictionary:
	var rules: Variant = director_rules.get("content_diet", {})
	return (rules as Dictionary).duplicate(true) if rules is Dictionary else {}

func _event_has_stateful_condition(event: Dictionary) -> bool:
	var conditions: Variant = event.get("conditions", {})
	if not conditions is Dictionary:
		return false
	for raw_key in (conditions as Dictionary).keys():
		var key := str(raw_key)
		if key not in ["min_turn", "max_turn"]:
			return true
	return false

func _event_passes_content_exclusions(event: Dictionary, rules: Dictionary) -> bool:
	if rules.get("excluded_categories", []).has(str(event.get("category", ""))):
		return false
	var event_id := str(event.get("id", ""))
	for raw_prefix in rules.get("excluded_id_prefixes", []):
		if event_id.begins_with(str(raw_prefix)):
			return false
	return true

func is_foreground_random_event(event: Dictionary) -> bool:
	if not is_directed_random_event(event):
		return false
	var rules := content_diet_rules()
	if rules.is_empty() or not _event_passes_content_exclusions(event, rules):
		return false
	# Text is localized before runtime. Use the KO-source audited allowlist so EN,
	# JA, and future overlays never produce a different playable event pool.
	return rules.get("foreground_event_ids", []).has(str(event.get("id", "")))

func is_narrative_bridge_event(event: Dictionary) -> bool:
	if not is_directed_random_event(event):
		return false
	var rules := content_diet_rules()
	if rules.is_empty() or not _event_passes_content_exclusions(event, rules):
		return false
	if not rules.get("bridge_event_ids", []).has(str(event.get("id", ""))):
		return false
	var choices: Array = event.get("choices", [])
	if bool(rules.get("bridge_single_choice_only", true)) and choices.size() != 1:
		return false
	if _event_has_follow_up(event):
		return false
	if bool(rules.get("bridge_requires_stateful_condition", true)) \
			and not _event_has_stateful_condition(event):
		return false
	if choices.is_empty() or not choices[0] is Dictionary:
		return false
	return not str((choices[0] as Dictionary).get("result_text", "")).is_empty()

func _event_has_causal_context(event: Dictionary) -> bool:
	var rules := content_diet_rules()
	if not bool(rules.get("foreground_requires_causal_context", true)):
		return true
	if action_echo_multiplier(event) > 1.0 or _event_has_follow_up(event) \
			or _event_has_stateful_condition(event):
		return true
	var tags: Array = event.get("tags", [])
	for tag in ["callback", "chain", "crisis", "milestone"]:
		if tags.has(tag):
			return true
	return false

func _pacing_turn_list_has(values: Variant, turn_value: int) -> bool:
	if not values is Array:
		return false
	for raw_turn in values:
		if int(raw_turn) == turn_value:
			return true
	return false

func _week_kind_for_pacing(pacing: Dictionary, turn_value: int) -> String:
	if pacing.is_empty() \
			or turn_value < int(pacing.get("min_turn", 1)) \
			or turn_value > int(pacing.get("max_turn", 0)):
		return "decision"
	if _pacing_turn_list_has(pacing.get("boss_weeks", []), turn_value):
		return "boss"
	if _pacing_turn_list_has(pacing.get("decision_weeks", []), turn_value):
		return "decision"
	if _pacing_turn_list_has(pacing.get("echo_weeks", []), turn_value):
		return "echo"
	return "quiet"

func demo_week_kind(turn_value: int = -1) -> String:
	var resolved_turn: int = GameState.turn if turn_value < 0 else turn_value
	return _week_kind_for_pacing(demo_pacing_rules(), resolved_turn)

func narrative_week_kind(turn_value: int = -1) -> String:
	var resolved_turn: int = GameState.turn if turn_value < 0 else turn_value
	var pacing := demo_pacing_rules() if resolved_turn <= GameState.DEMO_TURN_LIMIT \
			else full_run_pacing_rules()
	return _week_kind_for_pacing(pacing, resolved_turn)

## A direct week can be consumed by an authored foreground choice instead of
## opening a second generic AP board. Ownership is explicit and data-driven so a
## short random card can never accidentally spend the whole week.
func narrative_commitment_contract(event_id: String, turn_value: int = -1) -> Dictionary:
	var resolved_turn: int = GameState.turn if turn_value < 0 else turn_value
	var week_kind := narrative_week_kind(resolved_turn)
	if week_kind not in ["decision", "boss"]:
		return {}
	var pacing := demo_pacing_rules() if resolved_turn <= GameState.DEMO_TURN_LIMIT \
			else full_run_pacing_rules()
	var owners: Variant = pacing.get("commitment_event_owners", {})
	if not owners is Dictionary:
		return {}
	var raw_contracts: Variant = (owners as Dictionary).get(str(resolved_turn), [])
	if not raw_contracts is Array:
		return {}
	var wanted_id := event_id.strip_edges()
	for raw_contract in raw_contracts:
		var contract: Dictionary = {}
		if raw_contract is Dictionary:
			contract = (raw_contract as Dictionary).duplicate(true)
		else:
			contract = {"id": str(raw_contract)}
		var owner_id := str(contract.get("id", "")).strip_edges()
		if owner_id.is_empty() or owner_id != wanted_id:
			continue
		contract["id"] = owner_id
		contract["week_kind"] = week_kind
		return contract
	return {}

func narrative_commitment_event_ids(turn_value: int = -1) -> Array[String]:
	var resolved_turn: int = GameState.turn if turn_value < 0 else turn_value
	var pacing := demo_pacing_rules() if resolved_turn <= GameState.DEMO_TURN_LIMIT \
			else full_run_pacing_rules()
	var owners: Variant = pacing.get("commitment_event_owners", {})
	var result: Array[String] = []
	if not owners is Dictionary:
		return result
	var raw_contracts: Variant = (owners as Dictionary).get(str(resolved_turn), [])
	if not raw_contracts is Array:
		return result
	for raw_contract in raw_contracts:
		var event_id := str(raw_contract.get("id", "")) \
				if raw_contract is Dictionary else str(raw_contract)
		event_id = event_id.strip_edges()
		if not event_id.is_empty() and not result.has(event_id):
			result.append(event_id)
	return result

func narrative_event_owns_commitment(event_id: String, turn_value: int = -1) -> bool:
	return not narrative_commitment_contract(event_id, turn_value).is_empty()

## Compatibility wrappers for checks and old callers that specifically inspect
## boss weeks. New runtime code should use the general commitment contract.
func narrative_boss_event_ids(turn_value: int = -1) -> Array[String]:
	var resolved_turn: int = GameState.turn if turn_value < 0 else turn_value
	if narrative_week_kind(resolved_turn) != "boss":
		return []
	return narrative_commitment_event_ids(resolved_turn)

func narrative_event_owns_boss(event_id: String, turn_value: int = -1) -> bool:
	var resolved_turn: int = GameState.turn if turn_value < 0 else turn_value
	return narrative_week_kind(resolved_turn) == "boss" \
			and narrative_event_owns_commitment(event_id, resolved_turn)

func demo_should_show_full_summary(turn_value: int = -1) -> bool:
	var resolved_turn: int = GameState.turn if turn_value < 0 else turn_value
	var pacing := demo_pacing_rules()
	if pacing.is_empty() \
			or resolved_turn < int(pacing.get("min_turn", 1)) \
			or resolved_turn > int(pacing.get("max_turn", 0)):
		return true
	return _pacing_turn_list_has(pacing.get("full_summary_weeks", []), resolved_turn)

func narrative_should_show_full_summary(turn_value: int = -1) -> bool:
	var resolved_turn: int = GameState.turn if turn_value < 0 else turn_value
	var pacing := demo_pacing_rules() if resolved_turn <= GameState.DEMO_TURN_LIMIT \
			else full_run_pacing_rules()
	if pacing.is_empty() \
			or resolved_turn < int(pacing.get("min_turn", 1)) \
			or resolved_turn > int(pacing.get("max_turn", 0)):
		return true
	return _pacing_turn_list_has(pacing.get("full_summary_weeks", []), resolved_turn)

func _director_category_multiplier(row: Dictionary, event: Dictionary) -> float:
	if row.is_empty():
		return 1.0
	var category_multipliers: Dictionary = row.get("category_multipliers", {})
	return float(category_multipliers.get(
		str(event.get("category", "")), row.get("default_multiplier", 1.0)))

func director_context_multiplier(event: Dictionary) -> float:
	if not is_directed_random_event(event):
		return 1.0
	var tags: Array = event.get("tags", [])
	var event_id := str(event.get("id", ""))
	var explicit_requirements: Dictionary = director_rules.get(
		"context_requirements", {}).get(event_id, {})
	var employment: Dictionary = director_rules.get("employment", {})
	var has_job := not GameState.current_job.is_empty()
	if explicit_requirements.has("has_job") \
			and has_job != bool(explicit_requirements.get("has_job", false)):
		return 0.0
	if bool(explicit_requirements.get("active_romance", false)):
		var active_romance: bool = (
			GameState.flags.get("daeun_romance_started", false) \
			and not GameState.flags.get("daeun_divorced", false)
		) or (
			GameState.flags.get("jiyeon_romance_started", false) \
			and not GameState.flags.get("jiyeon_left", false)
		)
		if not active_romance:
			return 0.0
	if explicit_requirements.has("housing_in") \
			and not explicit_requirements.get("housing_in", []).has(GameState.housing):
		return 0.0
	var impossible_tags: Array = employment.get(
		"requires_no_job_tags" if has_job else "requires_job_tags", [])
	for tag in impossible_tags:
		if tags.has(str(tag)):
			return 0.0

	var housing_rules: Dictionary = director_rules.get("housing", {})
	var housing_requirements: Dictionary = housing_rules.get("tag_requirements", {})
	for tag in housing_requirements:
		if tags.has(str(tag)) and GameState.housing != str(housing_requirements[tag]):
			return 0.0

	var relationship_rules: Dictionary = director_rules.get("relationships", {})
	var named_cast_tags: Array = relationship_rules.get("named_cast_tags", [])
	var introductions: Dictionary = relationship_rules.get("introduction_events", {})
	var has_known_cast := false
	for person_value in named_cast_tags:
		var person_id := str(person_value)
		if not tags.has(person_id):
			continue
		var introduction_ids: Array = introductions.get(person_id, [])
		if introduction_ids.has(event_id):
			continue
		if not GameState.cast_has_met(person_id):
			return float(relationship_rules.get("unknown_multiplier", 0.0))
		has_known_cast = true

	var multiplier := _director_category_multiplier(_director_chapter_row(), event)
	multiplier *= _director_category_multiplier(_director_asset_row(), event)
	var employment_row: Dictionary = employment.get("employed" if has_job else "unemployed", {})
	multiplier *= _director_category_multiplier(employment_row, event)
	if has_known_cast:
		multiplier *= float(relationship_rules.get("known_multiplier", 1.0))
	return maxf(0.0, multiplier)

func director_repeat_policy(event: Dictionary) -> Dictionary:
	var default_policy: Dictionary = director_rules.get("default_policy", {})
	var policy := default_policy.duplicate(true)
	var repeatable_events: Dictionary = director_rules.get("repeatable_events", {})
	var event_id := str(event.get("id", ""))
	if repeatable_events.has(event_id):
		policy["once_per_run"] = false
		for key in (repeatable_events[event_id] as Dictionary):
			policy[key] = repeatable_events[event_id][key]
	return policy

func cooldown_for_event(event: Dictionary) -> int:
	var cooldown := int(event.get("cooldown", 6))
	if is_directed_random_event(event):
		cooldown = maxi(cooldown, int(director_repeat_policy(event).get("cooldown", 6)))
	return maxi(cooldown, 0)

func register_directed_event(event: Dictionary) -> void:
	if not is_directed_random_event(event):
		return
	var event_id := str(event.get("id", ""))
	GameState.random_event_counts[event_id] = int(
		GameState.random_event_counts.get(event_id, 0)) + 1
	GameState.random_event_last_turns[event_id] = GameState.turn
	var cooldown := cooldown_for_event(event)
	if cooldown > 0:
		event_cooldowns[event_id] = maxi(int(event_cooldowns.get(event_id, 0)), cooldown)
	_remember_recent(event_id)

func process_month_events():
	_tick_cooldowns()
	if pending_events.is_empty():
		var event = select_random_event()
		if not event.is_empty():
			queue_event(event)

func select_random_event():
	var eligible: Array = []
	for event in DataRegistry.events:
		if is_foreground_random_event(event) and _is_event_eligible(event) \
				and _event_has_causal_context(event):
			eligible.append(event)
	return _weighted_pick(eligible)

## 상황 카드용 — 서로 다른 앰비언트 이벤트 count개를 뽑는다.
## 스토리/아크/시나리오(StoryMode 전용)와 weight<=0은 제외. 쿨다운 1회 틱.
func draw_situations(count: int) -> Array:
	_tick_cooldowns()
	var eligible: Array = []
	for event in DataRegistry.events:
		if not is_foreground_random_event(event):
			continue
		if not _is_event_eligible(event):
			continue
		if not _event_has_causal_context(event):
			continue
		if str(event.get("rarity", "")) == "story":
			continue
		if str(event.get("category", "")) == "story":
			continue
		if float(event.get("weight", 1.0)) <= 0.0:
			continue
		eligible.append(event)
	if count == 1 and _should_hold_quiet_week(eligible):
		return []
	var picked: Array = []
	for i in range(count):
		if eligible.is_empty():
			break
		var e: Dictionary = _weighted_pick(eligible)
		if e.is_empty():
			break
		picked.append(e)
		eligible.erase(e)
	return picked

## Quiet/Echo can carry a deterministic one-choice consequence without opening
## another StoryMode stop. Multi-choice cards are never eligible here.
func draw_narrative_bridge_event() -> Dictionary:
	var rules := content_diet_rules()
	if GameState.is_demo_build() \
			or GameState.turn < int(rules.get("bridge_min_turn", 25)):
		return {}
	_tick_cooldowns()
	var eligible: Array = []
	for event in DataRegistry.events:
		if not is_narrative_bridge_event(event):
			continue
		# The curated bridge itself is the delayed consequence. Once its exact
		# state condition is true, do not put it behind the generic hidden-event
		# discovery roll as well.
		if not _is_event_eligible(event, true) or not _event_has_causal_context(event):
			continue
		eligible.append(event)
	# Recurring survival reminders should keep the world alive, but they must
	# not crowd out a newly eligible consequence of the player's prior choice.
	# Use them only when no stronger causal callback can fire this week.
	var fallback_ids: Array = rules.get("bridge_fallback_event_ids", [])
	var primary: Array = []
	for event in eligible:
		if not fallback_ids.has(str((event as Dictionary).get("id", ""))):
			primary.append(event)
	if not primary.is_empty():
		eligible = primary
	return _weighted_pick(eligible)

func _event_echo_families(event: Dictionary) -> Array:
	var families: Array = []
	var category := str(event.get("category", "")).to_lower()
	for family in ECHO_CATEGORY_ALIASES.get(category, [category]):
		if not str(family).is_empty() and not families.has(str(family)):
			families.append(str(family))
	for raw_tag in event.get("tags", []):
		var tag := str(raw_tag).to_lower()
		if not tag.is_empty() and not families.has(tag):
			families.append(tag)
		for alias in ECHO_TAG_ALIASES.get(tag, []):
			if not families.has(str(alias)):
				families.append(str(alias))
	return families

## QA와 StoryMode가 공유하는 최근 행동 매치. 본문/선택지 데이터는 건드리지 않는다.
func action_echo_match(event: Dictionary) -> Dictionary:
	if str(event.get("category", "")) == "story" or str(event.get("rarity", "")) == "story" \
			or float(event.get("weight", 1.0)) <= 0.0:
		return {}
	var recent_action_rules: Dictionary = director_rules.get("recent_action", {})
	var prior_strength := float(recent_action_rules.get("prior_week_strength", 0.55))
	var prior_multiplier := float(recent_action_rules.get("prior_week_multiplier", 1.88))
	var max_multiplier := float(recent_action_rules.get("max_multiplier", 2.6))
	var recent: Dictionary = GameState.get_recent_action_echoes(prior_strength)
	var event_families := _event_echo_families(event)
	var action_record: Dictionary = GameState.get_recent_action_record_for_families(
		event_families, prior_strength)
	var best_family := ""
	var best_strength := 0.0
	for family in event_families:
		var strength := float(recent.get(str(family), 0.0))
		if strength > best_strength:
			best_strength = strength
			best_family = str(family)
	if best_family.is_empty():
		return {}
	var resolved_multiplier := 1.0
	if best_strength >= 0.99:
		resolved_multiplier = max_multiplier
	elif best_strength >= prior_strength - 0.001:
		resolved_multiplier = prior_multiplier
	var result := {
		"family": best_family,
		"strength": best_strength,
		"multiplier": resolved_multiplier,
	}
	if not action_record.is_empty():
		result["action_id"] = str(action_record.get("id", ""))
		result["subject_id"] = str(action_record.get("subject", ""))
		result["action_strength"] = float(action_record.get("strength", 0.0))
		result["action_turn"] = int(action_record.get("week_turn", 0))
	return result

func action_echo_multiplier(event: Dictionary) -> float:
	var match_data := action_echo_match(event)
	return float(match_data.get("multiplier", 1.0))

func _causal_variant(event: Dictionary, lines: Array) -> String:
	if lines.is_empty():
		return ""
	var index: int = posmod(hash(str(event.get("id", ""))) + GameState.turn * 31, lines.size())
	return str(lines[index])

func _action_causal_frame(event: Dictionary, match_data: Dictionary) -> String:
	match str(match_data.get("action_id", "")):
		"apply":
			return _causal_variant(event, [
				LocaleManager.ui("지원서를 보낸 뒤, 메일함을 새로고침하던 며칠이었다.", "It came after he sent an application and spent days refreshing his inbox."),
				LocaleManager.ui("답이 오지 않은 지원서가 이번 주까지 따라왔다.", "An unanswered application followed him into this week."),
			])
		"resume":
			return _causal_variant(event, [
				LocaleManager.ui("지원서의 문장을 고쳐 쓴 뒤라, 일에 관한 말이 다르게 들렸다.", "After rewriting his application, every word about work sounded different."),
				LocaleManager.ui("밤새 다듬은 지원서가 아직 노트북 화면에 열려 있었다.", "The application he polished overnight was still open on his laptop."),
			])
		"side_shift":
			return _causal_variant(event, [
				LocaleManager.ui("추가 근무를 마친 피로와 입금 알림이 함께 남은 주였다.", "The fatigue of an extra shift and its deposit alert lingered together."),
				LocaleManager.ui("한 번 더 일한 대가가 통장과 몸에 따로 찍혀 있었다.", "The price of one more shift had registered separately in his bank account and his body."),
			])
		"save":
			return _causal_variant(event, [
				LocaleManager.ui("지출을 하나씩 지운 뒤라, 작은 가격표도 오래 눈에 남았다.", "After cutting expenses one by one, even small price tags stayed in his sight."),
				LocaleManager.ui("쓰지 않은 돈을 지키느라 이번 주의 생활이 조금 좁아졌다.", "Protecting the money he did not spend had made this week's life a little narrower."),
			])
		"rest":
			return _causal_variant(event, [
				LocaleManager.ui("하루를 멈춘 뒤라, 미뤄 둔 몸의 신호가 더 선명했다.", "After stopping for a day, the signals his body had postponed felt sharper."),
				LocaleManager.ui("일정을 비워 뒀다. 오랜만에 쫓기지 않는 한 주였다.", "He cleared the week. For once, it did not feel like a chase."),
			])
		"study", "study_read", "study_exercise", "study_meditation", "study_invest":
			return _causal_variant(event, [
				LocaleManager.ui("지난주에 쌓은 한 가지가 아직 생각과 몸의 습관에 남아 있었다.", "The one thing he practiced last week still lingered in thought and habit."),
				LocaleManager.ui("한 번의 연습은 작았지만, 이번 주의 판단을 조금 바꾸고 있었다.", "One practice session was small, but it was already changing this week's judgment."),
			])
		"contact":
			return _causal_variant(event, [
				LocaleManager.ui("먼저 보낸 연락의 답장이 아직 대화창 위에 남아 있었다.", "The reply to the message he sent first was still sitting at the top of the chat."),
				LocaleManager.ui("누군가에게 시간을 내어 준 뒤라, 이번 주는 완전히 혼자가 아니었다.", "After making time for someone, he was not entirely alone this week."),
			])
		"invest_buy", "invest_sell", "invest_leverage":
			return _causal_variant(event, [
				LocaleManager.ui("직접 거래를 확정한 뒤라, 시세의 작은 움직임도 내 일이 됐다.", "After confirming a trade himself, even a small market move had become personal."),
				LocaleManager.ui("매수와 매도의 숫자가 이번 주의 다른 판단에도 달라붙었다.", "The numbers from the trade clung to every other judgment this week."),
			])
	return ""

func causal_frame_for(event: Dictionary) -> String:
	var match_data := action_echo_match(event)
	if float(match_data.get("strength", 0.0)) < 0.5:
		return ""
	var action_frame := _action_causal_frame(event, match_data)
	if not action_frame.is_empty():
		return action_frame
	match str(match_data.get("family", "")):
		"jobs", "job", "career", "work", "workplace", "spec", "side_job":
			return _causal_variant(event, [
				LocaleManager.ui("지원서와 일 생각으로 며칠을 보낸 뒤였다.", "It came after days spent thinking about applications and work."),
				LocaleManager.ui("일자리 화면을 몇 번이나 다시 열어 본 주였다.", "He had reopened the job listings several times that week."),
				LocaleManager.ui("이번 주에는 일에 관한 말이 유난히 오래 남았다.", "Words about work had lingered longer than usual that week."),
			])
		"investment", "finance", "money", "risk":
			return _causal_variant(event, [
				LocaleManager.ui("며칠째 숫자와 시세를 들여다보던 주였다.", "It had been a week of watching numbers and prices."),
				LocaleManager.ui("닫아 둔 시세창을 습관처럼 다시 열었다.", "He reopened the market screen out of habit."),
				LocaleManager.ui("숫자를 오래 본 뒤에는 다른 소식도 숫자처럼 들렸다.", "After staring at numbers for so long, even other news sounded numerical."),
			])
		"gambling", "casino", "racetrack", "holdem", "addiction":
			return _causal_variant(event, [
				LocaleManager.ui("베팅판을 떠난 뒤에도 숫자가 머릿속에 남아 있었다.", "The numbers stayed in his head even after he left the betting floor."),
				LocaleManager.ui("끝난 승부를 머릿속에서 한 번 더 돌려 보던 주였다.", "He had been replaying an already finished bet in his head."),
				LocaleManager.ui("이번 주에는 우연도 신호처럼 보였다.", "That week, even coincidence looked like a signal."),
			])
		"relationship", "romance", "social", "network", "daeun", "family":
			return _causal_variant(event, [
				LocaleManager.ui("이번 주에는 사람 쪽으로 시간을 내고 있었다.", "This week, he had been making time for people."),
				LocaleManager.ui("혼자 보내지 않은 시간이 아직 몸에 남아 있었다.", "The hours he had not spent alone still lingered in him."),
				LocaleManager.ui("연락을 주고받은 뒤라 휴대폰이 평소보다 가까이 놓여 있었다.", "After trading messages, he kept his phone closer than usual."),
			])
		"health", "rest", "mental", "self_development", "study", "daily_life", "daily":
			return _causal_variant(event, [
				LocaleManager.ui("몸과 마음을 추스를 시간을 겨우 만들어 둔 주였다.", "It had been a week of barely making room to recover."),
				LocaleManager.ui("억지로라도 숨을 고른 뒤라 몸의 신호가 더 또렷했다.", "After forcing himself to slow down, his body's signals felt clearer."),
				LocaleManager.ui("잠깐 멈춘 시간이 이번 주의 감각을 바꾸어 놓았다.", "A brief pause had changed the texture of the week."),
			])
	return ""

func _event_has_follow_up(event: Dictionary) -> bool:
	if not str(event.get("follow_up_event", "")).is_empty():
		return true
	for choice_value in event.get("choices", []):
		var choice: Dictionary = choice_value
		if not str(choice.get("follow_up_event", "")).is_empty() \
				or not DataRegistry.deferred_follow_ups(choice).is_empty():
			return true
	return false

func _is_low_signal_filler(event: Dictionary) -> bool:
	var conditions: Dictionary = event.get("conditions", {})
	if not conditions.is_empty():
		return false
	if str(event.get("rarity", "common")) != "common" or _event_has_follow_up(event):
		return false
	var tags: Array = event.get("tags", [])
	return not tags.has("tradeoff") and not tags.has("callback") and not tags.has("milestone")

func quiet_week_chance(eligible: Array) -> float:
	if GameState.turn <= 8 or eligible.is_empty():
		return 0.0
	var strongest_echo := 1.0
	var filler_count := 0
	for event in eligible:
		strongest_echo = maxf(strongest_echo, action_echo_multiplier(event))
		if _is_low_signal_filler(event):
			filler_count += 1
	if strongest_echo >= 2.0:
		return 0.04
	return 0.28 if filler_count * 2 >= eligible.size() else 0.16

func _should_hold_quiet_week(eligible: Array) -> bool:
	var chance := quiet_week_chance(eligible)
	if chance <= 0.0:
		return false
	# 같은 저장/같은 주를 다시 열어도 사건 유무가 뒤집히지 않는 결정론적 호흡.
	var signature := posmod(
		GameState.turn * 37 + GameState.month * 17 + GameState.events_seen * 11 \
				+ recent_event_ids.size() * 7,
		1000
	)
	return signature < int(roundf(chance * 1000.0))

func queue_event(event):
	if event.is_empty():
		return
	pending_events.append(event)

func get_next_event():
	if pending_events.is_empty():
		current_event = {}
		return {}
	current_event = pending_events.pop_front()
	event_started.emit(current_event)
	return current_event

func resolve_current_event(choice_index) -> bool:
	if current_event.is_empty():
		return false
	var choices: Array = current_event.get("choices", [])
	if choice_index < 0 or choice_index >= choices.size():
		return false
	var choice: Dictionary = choices[choice_index]
	if not GameState.choice_available(current_event, choice):
		return false
	if not GameState.apply_choice(current_event, choice):
		return false

	var event_id := str(current_event.get("id", ""))
	var cooldown := cooldown_for_event(current_event)
	if cooldown > 0:
		event_cooldowns[event_id] = maxi(int(event_cooldowns.get(event_id, 0)), cooldown)
	_remember_recent(event_id)

	var follow_up = str(choice.get("follow_up_event", ""))
	if not follow_up.is_empty():
		var chained = DataRegistry.find_event(follow_up)
		if not chained.is_empty():
			queue_event(chained)

	event_resolved.emit(current_event, choice)
	current_event = {}
	return true

func trigger_event_by_id(event_id):
	var event = DataRegistry.find_event(event_id)
	if not event.is_empty():
		queue_event(event)

## Delayed callbacks may outlive the state that made them plausible. Unlike an
## immediate authored follow-up, they must still satisfy their event conditions.
func deferred_event_is_eligible(event_id: String) -> bool:
	var event: Dictionary = DataRegistry.find_event(event_id)
	if event.is_empty():
		push_error("Deferred event missing: %s" % event_id)
		return false
	return _check_conditions(event.get("conditions", {}))

func trigger_deferred_event_by_id(event_id: String) -> bool:
	if not deferred_event_is_eligible(event_id):
		return false
	var event: Dictionary = DataRegistry.find_event(event_id)
	queue_event(event)
	return true

## Low-signal authored events keep their original effects and history without
## interrupting the novel with another standalone choice screen. The caller
## chooses from the event's existing options based on decisions already made.
func resolve_narrative_bridge(event_id: String, choice_index: int) -> bool:
	var event: Dictionary = DataRegistry.find_event(event_id)
	if event.is_empty():
		push_error("Narrative bridge event missing: %s" % event_id)
		return false
	var choices: Array = event.get("choices", [])
	if choice_index < 0 or choice_index >= choices.size():
		push_error("Narrative bridge choice out of range: %s[%d]" % [event_id, choice_index])
		return false
	var choice: Dictionary = choices[choice_index]
	if not GameState.choice_available(event, choice):
		return false
	if not GameState.apply_choice(event, choice):
		return false
	var cooldown := cooldown_for_event(event)
	if cooldown > 0:
		event_cooldowns[event_id] = maxi(int(event_cooldowns.get(event_id, 0)), cooldown)
	_remember_recent(event_id)
	narrative_bridge_results.append({
		"turn": GameState.turn,
		"event_id": event_id,
		"title": str(event.get("title", "")),
		"summary": str(choice.get("bridge_summary", choice.get("result_text", choice.get("text", "")))),
	})
	event_resolved.emit(event, choice)
	return true

func consume_narrative_bridge_results() -> Array:
	var results := narrative_bridge_results.duplicate(true)
	narrative_bridge_results.clear()
	return results

func _tick_cooldowns():
	for event_id in event_cooldowns.keys():
		event_cooldowns[event_id] = int(event_cooldowns[event_id]) - 1
		if int(event_cooldowns[event_id]) <= 0:
			event_cooldowns.erase(event_id)

func _remember_recent(event_id):
	if event_id.is_empty():
		return
	# StoryMode와 EventManager 경로가 같은 사건을 기록해도 최근 목록은 한 칸만 쓴다.
	if recent_event_ids.has(event_id):
		recent_event_ids.erase(event_id)
	recent_event_ids.append(event_id)
	if recent_event_ids.size() > 25:
		recent_event_ids.pop_front()

func _is_event_eligible(event, deterministic_hidden: bool = false):
	var event_id = str(event.get("id", ""))
	if event_id.is_empty():
		return false
	if DEMO_CORE_LOOP_V2.legacy_callback_is_superseded(event_id):
		return false
	if event_cooldowns.has(event_id) or recent_event_ids.has(event_id):
		return false
	if is_directed_random_event(event):
		if director_context_multiplier(event) <= 0.0:
			return false
		var policy := director_repeat_policy(event)
		var seen_count := int(GameState.random_event_counts.get(event_id, 0))
		var max_per_run := int(policy.get("max_per_run", 1))
		if bool(policy.get("once_per_run", true)) and seen_count >= 1:
			return false
		if max_per_run > 0 and seen_count >= max_per_run:
			return false
		if seen_count > 0:
			var last_turn := int(GameState.random_event_last_turns.get(event_id, -9999))
			if GameState.turn - last_turn < int(policy.get("cooldown", 6)):
				return false
	if bool(event.get("hidden", false)) and not deterministic_hidden \
			and not MetaProgression.is_hidden_event_unlocked(event_id):
		return _check_hidden_chance(event)
	return _check_conditions(event.get("conditions", {}))

func _check_hidden_chance(event):
	if not _check_conditions(event.get("conditions", {})):
		return false
	var rarity = str(event.get("rarity", "rare"))
	var chance = 0.01
	if rarity == "legendary":
		chance = 0.004
	elif rarity == "rare":
		chance = 0.012
	return randf() < chance + float(GameState.luck) / 8000.0

func _check_conditions(conditions):
	for key in conditions:
		var req = conditions[key]
		match key:
			"min_money":
				if GameState.money < float(req): return false
			"max_money":
				if GameState.money > float(req): return false
			"month":
				# 시즌 이벤트: 특정 달(int) 또는 달 목록(Array)에만 등장
				if req is Array:
					if not (req as Array).has(GameState.month): return false
				elif GameState.month != int(req): return false
			"min_health":
				if GameState.health < int(req): return false
			"max_health":
				if GameState.health > int(req): return false
			"min_mental":
				if GameState.mental < int(req): return false
			"max_mental":
				if GameState.mental > int(req): return false
			"min_intelligence":
				if GameState.intelligence < int(req): return false
			"min_social", "min_social_skill":
				if GameState.social_skill < int(req): return false
			"min_investment_skill":
				if GameState.investment_skill < int(req): return false
			"min_luck":
				if GameState.luck < int(req): return false
			"min_appearance":
				if GameState.appearance < int(req): return false
			"min_reputation":
				if GameState.reputation < int(req): return false
			"min_addiction":
				if GameState.addiction_tendency < int(req): return false
			"max_addiction":
				if GameState.addiction_tendency > int(req): return false
			"min_gambling":
				if GameState.gambling_tendency < int(req): return false
			"min_turn":
				if GameState.turn < int(req): return false
			"max_stress":
				if GameState.mental < (100 - int(req)): return false
			"min_stress":
				if GameState.mental > (100 - int(req)): return false
			"has_job":
				if bool(req) and GameState.current_job.is_empty(): return false
			"no_job":
				if bool(req) and not GameState.current_job.is_empty(): return false
			"job_id":
				# 특정 직업 id와 일치해야 발동 (e.g. "job_01"이면 편의점 알바만)
				if GameState.current_job.get("id", "") != str(req): return false
			"min_job_tier":
				# 현재 직업 티어가 req 미만이면 제외 (무직이면 tier 0으로 취급)
				var cur_tier = int(GameState.current_job.get("tier", 0))
				if cur_tier < int(req): return false
			"max_job_tier":
				var cur_tier = int(GameState.current_job.get("tier", 999))
				if cur_tier > int(req): return false
			"job_category":
				# 직업 카테고리가 일치하지 않으면 제외 (무직이면 항상 false)
				if GameState.current_job.get("category", "") != str(req): return false
			"has_portfolio":
				if bool(req) and GameState.portfolio.is_empty(): return false
			"has_relationship":
				if bool(req) and GameState.relationships.is_empty(): return false
			"flag":
				if not GameState.flags.get(str(req), false): return false
			"no_flag":
				# 단일 플래그 또는 배열 지원 (배열이면 하나라도 set이면 제외)
				if req is Array:
					for fl in req:
						if GameState.flags.get(str(fl), false): return false
				elif GameState.flags.get(str(req), false): return false
			"min_route_orthodox":
				if GameState.route_orthodox < int(req): return false
			"min_route_unorthodox":
				if GameState.route_unorthodox < int(req): return false
			"max_route_orthodox":
				if GameState.route_orthodox > int(req): return false
			"max_route_unorthodox":
				if GameState.route_unorthodox > int(req): return false
			"month_focus":
				if GameState.month_focus != str(req): return false
			"housing":
				if GameState.housing != str(req): return false
			"min_housing_months":
				if GameState.housing_months.get(GameState.housing, 0) < int(req): return false
			"max_turn":
				if GameState.turn > int(req): return false
			"market_cycle":
				if GameState.market_context.get("cycle", "neutral") != str(req): return false
			"min_fear_greed":
				if int(GameState.market_context.get("fear_greed", 50)) < int(req): return false
			"max_fear_greed":
				if int(GameState.market_context.get("fear_greed", 50)) > int(req): return false
			"min_work_performance":
				if GameState.work_performance < int(req): return false
			"min_job_tenure":
				if GameState.job_tenure < int(req): return false
			"min_assets":
				if GameState.get_total_asset_value() < float(req): return false
			"max_assets":
				if GameState.get_total_asset_value() > float(req): return false
			# ── 스토리 인물(cast) 조건 ──────────────────────────
			"route":
				# 경제 루트: "직장형" | "투자형" | "창업형"
				if GameState.player_route != str(req): return false
			"cast_stage":
				# { "person": "jiyeon", "is": "interest" } 또는 { "person":"jiyeon", "in":["interest","warm"] }
				if not _check_cast_stage(req): return false
			"cast_met":
				# { "jiyeon": true } 형태 — 만났는지 여부
				for pid in req:
					if GameState.cast_has_met(str(pid)) != bool(req[pid]): return false
			"min_cast_affinity":
				# { "jiyeon": 30 } — 호감도 최소
				for pid in req:
					if GameState.get_cast_affinity(str(pid)) < int(req[pid]): return false
			"max_cast_affinity":
				for pid in req:
					if GameState.get_cast_affinity(str(pid)) > int(req[pid]): return false
			"cast_flag":
				# { "person":"jaehyuk", "flag":"suspected" }
				if not GameState.cast_has_flag(str(req.get("person","")), str(req.get("flag",""))): return false
			"has_item":
				if not GameState.has_item(str(req)): return false
	return true

func _check_cast_stage(req: Dictionary) -> bool:
	var pid = str(req.get("person", ""))
	if pid == "":
		return true
	var stage = GameState.get_cast_stage(pid)
	if req.has("is"):
		return stage == str(req["is"])
	if req.has("in"):
		return (req["in"] as Array).has(stage)
	if req.has("not"):
		return stage != str(req["not"])
	return true

func _weighted_pick(events):
	if events.is_empty():
		return {}
	var weighted_events: Array = []
	var weights: Array[float] = []
	var total := 0.0
	for event in events:
		var weight: float = float(_effective_weight(event))
		if weight <= 0.0:
			continue
		weighted_events.append(event)
		weights.append(weight)
		total += weight
	if weighted_events.is_empty() or total <= 0.0:
		return {}
	var roll = randf() * total
	var cursor := 0.0
	for index in range(weighted_events.size()):
		cursor += weights[index]
		if roll <= cursor:
			return weighted_events[index]
	return weighted_events.back()

func _effective_weight(event):
	var weight = float(event.get("weight", 1.0))
	var context_multiplier := director_context_multiplier(event)
	if context_multiplier <= 0.0:
		return 0.0
	weight *= context_multiplier
	if is_directed_random_event(event):
		var event_id := str(event.get("id", ""))
		var seen_count := int(GameState.random_event_counts.get(event_id, 0))
		if seen_count > 0:
			var repeat_decay := float(director_repeat_policy(event).get("repeat_decay", 1.0))
			weight *= pow(repeat_decay, seen_count)
	match str(event.get("rarity", "common")):
		"common":
			weight *= 1.0
		"uncommon":
			weight *= 0.7
		"rare":
			weight *= 0.28
		"legendary":
			weight *= 0.08
	weight *= action_echo_multiplier(event)
	if _is_low_signal_filler(event):
		weight *= 0.42
	if GameState.mental < 30 and event.get("tags", []).has("stress"):
		weight *= 1.6
	if GameState.market_context.get("fear_greed", 50) > 75 and event.get("category", "") == "finance":
		weight *= 1.35
	# 루트 성향 가중치 차등: 쌓인 루트 방향의 이벤트를 최대 1.5배 부스트
	var tags: Array = event.get("tags", [])
	var orth = GameState.route_orthodox
	var unorth = GameState.route_unorthodox
	var diff = orth - unorth
	if diff >= 6 and (tags.has("orthodox") or tags.has("work") or tags.has("spec")):
		weight *= 1.0 + min(float(diff) / 30.0, 0.5)
	elif diff <= -6 and (tags.has("investment") or tags.has("unorthodox") or tags.has("risk")):
		weight *= 1.0 + min(float(-diff) / 30.0, 0.5)
	# 청렴런: gambling 카테고리 이벤트 완전 차단
	if GameState.flags.get("no_gambling", false) and str(event.get("category", "")) == "gambling":
		return 0.0
	# 런 테마 보너스: 매 런마다 2개 카테고리 이벤트 1.35x
	var run_themes: Array = GameState.run_theme_categories
	if not run_themes.is_empty():
		var ev_cat := str(event.get("category", ""))
		# romance는 relationship 테마에도 반응
		var effective_cat := "relationship" if ev_cat == "romance" else ev_cat
		if run_themes.has(ev_cat) or run_themes.has(effective_cat):
			weight *= 1.35
	# 이번 달 집중 태그와 일치하면 보너스
	var focus = GameState.month_focus
	if not focus.is_empty():
		var focus_tag_map = {
			"투자": ["investment", "finance"],
			"부업": ["work", "side_job"],
			"연애": ["romance", "social"],
			"자유시간": ["daily", "rest"],
			"스펙 쌓기": ["spec", "study"],
			"커리어 관리": ["work", "jobs"],
			"인맥 관리": ["social", "relationship"],
			"저축 집중": ["finance"],
		}
		var boost_tags: Array = focus_tag_map.get(focus, [])
		for bt in boost_tags:
			if tags.has(bt):
				weight *= 1.25
				break
	# 강남드림 트레이드오프 시나리오(신규 고품질 콘텐츠)를 매 턴 사건으로 우선 노출.
	# (옛 로그라이크 이벤트보다 훨씬 자주 등장 → 일방적 선택지 비중 자연 감소)
	if tags.has("tradeoff"):
		weight *= 4.5
	# cast 친밀도 기반 이벤트 큐레이션: 관계 깊이에 따라 관련 이벤트 부스트
	var ev_cat := str(event.get("category", ""))
	var sangchul_aff: int = GameState.get_cast_affinity("sangchul")
	var daeun_aff: int = GameState.get_cast_affinity("daeun")
	var jiyeon_aff: int = GameState.get_cast_affinity("jiyeon")
	if sangchul_aff >= 15 and (ev_cat == "investment" or tags.has("investment") or tags.has("network")):
		weight *= 1.0 + min(float(sangchul_aff - 15) / 60.0, 0.25)
	if daeun_aff >= 12 and (ev_cat == "relationship" or ev_cat == "romance" or tags.has("romance")):
		weight *= 1.0 + min(float(daeun_aff - 12) / 60.0, 0.25)
	if jiyeon_aff >= 12 and (tags.has("romance") or tags.has("jiyeon")):
		weight *= 1.0 + min(float(jiyeon_aff - 12) / 60.0, 0.25)
	# 직업 카테고리 기반 큐레이션: 직장인 = 직장 이벤트 더 자주
	if not GameState.current_job.is_empty():
		var job_cat := str(GameState.current_job.get("category", ""))
		if job_cat != "" and (ev_cat == "jobs" or tags.has(job_cat)):
			weight *= 1.2
	# 뉴스 → 삶 직접 영향: 경제 공포 시 실직/주거 이벤트 상승
	var fg: int = int(GameState.market_context.get("fear_greed", 50))
	if fg < 25 and (ev_cat == "jobs" or tags.has("layoff") or tags.has("unemployment")):
		weight *= 1.4
	if fg < 20 and (ev_cat == "disasters" or tags.has("housing") or tags.has("jeonse")):
		weight *= 1.3
	return max(0.01, weight)
