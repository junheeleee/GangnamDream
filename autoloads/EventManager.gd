extends Node

signal event_started(event: Dictionary)
signal event_resolved(event: Dictionary, choice: Dictionary)

var pending_events: Array = []
var current_event: Dictionary = {}
var event_cooldowns: Dictionary = {}
var recent_event_ids: Array = []

func _ready():
	GameState.run_started.connect(_on_run_started)

func _on_run_started():
	event_cooldowns.clear()
	recent_event_ids.clear()
	pending_events.clear()
	current_event = {}

func process_month_events():
	_tick_cooldowns()
	if pending_events.is_empty():
		var event = select_random_event()
		if not event.is_empty():
			queue_event(event)

func select_random_event():
	var eligible: Array = []
	for event in DataRegistry.events:
		if _is_event_eligible(event):
			eligible.append(event)
	return _weighted_pick(eligible)

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

func resolve_current_event(choice_index):
	if current_event.is_empty():
		return
	var choices: Array = current_event.get("choices", [])
	if choice_index < 0 or choice_index >= choices.size():
		return
	var choice: Dictionary = choices[choice_index]
	GameState.apply_choice(current_event, choice)

	var cooldown = int(current_event.get("cooldown", 6))
	if cooldown > 0:
		event_cooldowns[current_event.get("id", "")] = cooldown
	_remember_recent(current_event.get("id", ""))

	var follow_up = str(choice.get("follow_up_event", ""))
	if not follow_up.is_empty():
		var chained = DataRegistry.find_event(follow_up)
		if not chained.is_empty():
			queue_event(chained)

	event_resolved.emit(current_event, choice)
	current_event = {}

func trigger_event_by_id(event_id):
	var event = DataRegistry.find_event(event_id)
	if not event.is_empty():
		queue_event(event)

func _tick_cooldowns():
	for event_id in event_cooldowns.keys():
		event_cooldowns[event_id] = int(event_cooldowns[event_id]) - 1
		if int(event_cooldowns[event_id]) <= 0:
			event_cooldowns.erase(event_id)

func _remember_recent(event_id):
	if event_id.is_empty():
		return
	recent_event_ids.append(event_id)
	if recent_event_ids.size() > 25:
		recent_event_ids.pop_front()

func _is_event_eligible(event):
	var event_id = str(event.get("id", ""))
	if event_id.is_empty():
		return false
	if event_cooldowns.has(event_id) or recent_event_ids.has(event_id):
		return false
	if bool(event.get("hidden", false)) and not MetaProgression.is_hidden_event_unlocked(event_id):
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
			"min_turn":
				if GameState.turn < int(req): return false
			"max_stress":
				if GameState.stress > int(req): return false
			"min_stress":
				if GameState.stress < int(req): return false
			"has_job":
				if bool(req) and GameState.current_job.is_empty(): return false
			"no_job":
				if bool(req) and not GameState.current_job.is_empty(): return false
			"has_portfolio":
				if bool(req) and GameState.portfolio.is_empty(): return false
			"has_relationship":
				if bool(req) and GameState.relationships.is_empty(): return false
			"flag":
				if not GameState.flags.get(str(req), false): return false
			"no_flag":
				if GameState.flags.get(str(req), false): return false
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
			"min_reputation":
				if GameState.reputation < int(req): return false
			"min_work_performance":
				if GameState.work_performance < int(req): return false
			"min_job_tenure":
				if GameState.job_tenure < int(req): return false
	return true

func _weighted_pick(events):
	if events.is_empty():
		return {}
	var total = 0.0
	for event in events:
		total += _effective_weight(event)
	var roll = randf() * total
	var cursor = 0.0
	for event in events:
		cursor += _effective_weight(event)
		if roll <= cursor:
			return event
	return events.back()

func _effective_weight(event):
	var weight = float(event.get("weight", 1.0))
	match str(event.get("rarity", "common")):
		"common":
			weight *= 1.0
		"uncommon":
			weight *= 0.7
		"rare":
			weight *= 0.28
		"legendary":
			weight *= 0.08
	if GameState.stress > 70 and event.get("tags", []).has("stress"):
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
	# 런 테마 보너스: 매 런마다 2개 카테고리 이벤트 1.35x
	var run_themes: Array = GameState.run_theme_categories
	if not run_themes.is_empty():
		if run_themes.has(str(event.get("category", ""))):
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
	return max(0.01, weight)
