extends Node

signal stats_changed()
signal money_changed(new_amount: float)
signal turn_advanced(new_turn: int)
signal game_over(ending_id: String)
signal log_added(entry: Dictionary)
signal run_started()

var player_name = "김민준"
var player_background = "지방_상경"  # 지방_상경 | 명문대_중퇴 | 금수저
var age = 20
var year = 2026
var month = 1
var turn = 1
var is_game_over = false
var current_trait = "흙수저 생존본능"

const HOUSING_DATA = {
	"gosiwon":   {"name": "고시원",     "emoji": "🏚", "expense": 800_000.0,   "deposit": 0.0,           "next": "oneroom",   "req_cash": 0.0},
	"oneroom":   {"name": "원룸",       "emoji": "🏠", "expense": 1_100_000.0, "deposit": 5_000_000.0,   "next": "apartment", "req_cash": 7_000_000.0},
	"apartment": {"name": "아파트",     "emoji": "🏢", "expense": 1_600_000.0, "deposit": 30_000_000.0,  "next": "gangnam",   "req_cash": 35_000_000.0},
	"gangnam":   {"name": "강남 아파트", "emoji": "🏙", "expense": 2_800_000.0, "deposit": 100_000_000.0, "next": "",          "req_cash": 120_000_000.0},
}

var housing: String = "gosiwon"

var money = 1_000_000.0
var monthly_income = 0.0
var fixed_expense = 800_000.0
var health = 70
var mental = 70
var intelligence = 50
var social_skill = 40
var appearance = 50
var investment_skill = 12
var luck = 45

var action_points = 3
var max_action_points = 3
var tutorial_step = 3

var stress = 25
var reputation = 10
var gambling_tendency = 0
var addiction_tendency = 0

var current_job: Dictionary = {}
var job_tenure = 0
var work_performance = 50

var milestones_reached: Dictionary = {}  # "10m","100m","500m","1b","2b"
var portfolio: Dictionary = {}
var relationships: Array = []
var inventory: Array = []
var news_log: Array = []
var event_log: Array = []
var action_log: Array = []
var flags: Dictionary = {}
var market_prices: Dictionary = {}
var price_history: Dictionary = {}
var market_context = {
	"fear_greed": 50,
	"cycle": "neutral",
	"bubble_assets": [],
	"crash_risk": 0.04,
	"momentum": 0.0,
}

func _ready():
	randomize()

func new_game():
	start_new_game("흙수저 생존본능")

func start_new_game(selected_trait: String, chosen_name: String = "김민준", chosen_background: String = "지방_상경"):
	player_name = chosen_name if not chosen_name.strip_edges().is_empty() else "김민준"
	player_background = chosen_background
	age = 20
	year = 2026
	month = 1
	turn = 1
	is_game_over = false
	current_trait = selected_trait

	housing = "gosiwon"
	money = 1_000_000.0
	monthly_income = 0.0
	fixed_expense = 800_000.0
	health = 70
	mental = 70
	intelligence = 50
	social_skill = 40
	appearance = 50
	investment_skill = 12
	luck = 45
	action_points = 3
	max_action_points = 3
	tutorial_step = 3
	stress = 25
	reputation = 10
	gambling_tendency = 0
	addiction_tendency = 0
	current_job = {}
	job_tenure = 0
	work_performance = 50
	milestones_reached = {}
	portfolio = {}
	relationships = []
	inventory = []
	news_log = []
	event_log = []
	action_log = []
	flags = {}
	market_prices = {}
	price_history = {}
	market_context = {
		"fear_greed": 50,
		"cycle": "neutral",
		"bubble_assets": [],
		"crash_risk": 0.04,
		"momentum": 0.0,
	}

	_apply_trait_bonus(selected_trait)
	_apply_background_bonus(chosen_background)
	_init_market_prices()
	add_log("새 런 시작: %s / %s" % [chosen_background, selected_trait], "system")
	stats_changed.emit()
	run_started.emit()

func _apply_background_bonus(bg: String):
	match bg:
		"명문대_중퇴":
			# 머리는 좋지만 학자금 빚이 있고 현실 경험 부족
			intelligence += 15
			reputation += 8
			social_skill += 5
			money -= 500_000.0
			stress += 10
			flags["background_elite"] = true
		"금수저":
			# 시작 자금 넉넉하지만 생존 감각이 없음
			money += 1_500_000.0
			social_skill += 8
			appearance += 5
			investment_skill -= 5
			luck += 5
			flags["background_rich"] = true
		_:  # 지방_상경 (기본)
			# 기본값 그대로. 보너스 없지만 패널티도 없음
			flags["background_local"] = true

func _apply_trait_bonus(selected_trait):
	var bonuses = {}
	if has_node("/root/MetaProgression"):
		bonuses = MetaProgression.get_trait_bonus(selected_trait)
	apply_effects(bonuses)

func _init_market_prices():
	for asset in DataRegistry.assets:
		market_prices[asset.get("id", "")] = float(asset.get("initial_price", asset.get("base_price", 10_000.0)))

func advance_calendar():
	if is_game_over:
		return
	turn += 1
	month += 1
	if month > 12:
		month = 1
		year += 1
		age += 1
	turn_advanced.emit(turn)

func get_housing_expense() -> float:
	return float(HOUSING_DATA.get(housing, HOUSING_DATA["gosiwon"]).get("expense", 800_000.0))

func get_housing_info() -> Dictionary:
	return HOUSING_DATA.get(housing, HOUSING_DATA["gosiwon"])

func can_upgrade_housing() -> bool:
	var info = get_housing_info()
	var next_id = str(info.get("next", ""))
	if next_id.is_empty():
		return false
	var next_info = HOUSING_DATA.get(next_id, {})
	return money >= float(next_info.get("req_cash", 0.0))

func upgrade_housing() -> Dictionary:
	var info = get_housing_info()
	var next_id = str(info.get("next", ""))
	if next_id.is_empty():
		return {"success": false, "message": "이미 최고 등급 주거입니다."}
	var next_info = HOUSING_DATA.get(next_id, {})
	if money < float(next_info.get("req_cash", 0.0)):
		return {"success": false, "message": "자금이 부족합니다."}
	var deposit_diff = float(next_info.get("deposit", 0.0)) - float(info.get("deposit", 0.0))
	add_money(-deposit_diff)
	housing = next_id
	fixed_expense = get_housing_expense()
	add_log("이사: %s → %s (보증금 %s)" % [info.get("name",""), next_info.get("name",""), format_money(deposit_diff)], "system")
	stats_changed.emit()
	return {"success": true, "housing": next_info}

func apply_monthly_pressure():
	fixed_expense = get_housing_expense()
	add_money(monthly_income - fixed_expense)
	# 첫 월급 수령 플래그 — 투자 기능 잠금 해제 트리거
	if monthly_income > 0 and not flags.get("has_received_paycheck", false):
		flags["has_received_paycheck"] = true
		add_log("💳 첫 월급이 통장에 들어왔다. 이제 투자를 시작할 수 있다.", "job")

	# ── 서울살이 기본 압박 ──────────────────────────────────────────
	# 건강: 매달 자동 -3 (바쁜 일상, 수면 부족, 불규칙한 식사)
	# 정신: 매달 자동 -4 (고독, 미래 불안, 도시 피로)
	# 스트레스: 매달 자동 +4 (서울은 기본이 힘들다)
	modify_stat("health", -3)
	modify_stat("mental", -4)
	modify_hidden_stat("stress", 4)

	# 무직이면 정신/스트레스 추가 압박
	if monthly_income == 0:
		modify_stat("mental", -3)
		modify_hidden_stat("stress", 5)
		add_log("💸 수입이 없다. 통장 잔고가 줄어가는 게 느껴진다.", "stress")

	# 스트레스 단계별 추가 피해 (누적 구조)
	if stress >= 80:
		modify_stat("health", -4)
		modify_stat("mental", -4)
		add_log("🚨 극심한 스트레스가 몸과 마음을 갉아먹고 있다.", "stress")
	elif stress >= 60:
		modify_stat("health", -2)
		modify_stat("mental", -2)
	elif stress >= 40:
		modify_stat("mental", -1)

	# 현금 위기 — 잔고 30만원 미만
	if money < 300_000:
		modify_hidden_stat("stress", 8)
		modify_stat("mental", -4)
		add_log("😰 통장 잔고가 30만원 아래다. 이번 달을 버틸 수 있을까.", "money")
	elif money < 0:
		modify_hidden_stat("stress", 12)
		modify_stat("mental", -5)
		add_log("🆘 잔고가 마이너스다. 이러다 진짜 쫓겨난다.", "money")

	check_game_over()

func apply_choice(event, choice):
	apply_effects(choice.get("effects", {}))
	for rel_effect in choice.get("relationship_effects", []):
		apply_relationship_effect(rel_effect)
	for investment_effect in choice.get("investment_effects", []):
		apply_investment_effect(investment_effect)
	for flag_id in choice.get("flags", []):
		flags[str(flag_id)] = true
	event_log.append({
		"turn": turn,
		"event_id": event.get("id", ""),
		"choice": choice.get("text", ""),
		"result": choice.get("result_text", ""),
	})
	add_log("%s: %s" % [event.get("title", "이벤트"), choice.get("result_text", choice.get("text", ""))], "event")

func apply_effects(effects):
	for key in effects:
		var value = effects[key]
		match key:
			"money":
				add_money(float(value))
			"monthly_income":
				monthly_income += float(value)
			"fixed_expense":
				fixed_expense = max(0.0, fixed_expense + float(value))
			"health", "mental", "intelligence", "social_skill", "appearance", "investment_skill", "luck":
				modify_stat(key, int(value))
			"stress", "reputation", "gambling_tendency", "addiction_tendency":
				modify_hidden_stat(key, int(value))
			"flag":
				flags[str(value)] = true
			"unflag":
				flags.erase(str(value))
	stats_changed.emit()

func apply_relationship_effect(effect):
	var rel_id = str(effect.get("id", effect.get("type", "unknown")))
	var found = false
	for rel in relationships:
		if rel.get("id", "") == rel_id:
			rel["affection"] = clamp(int(rel.get("affection", 40)) + int(effect.get("affection", 0)), 0, 100)
			rel["trust"] = clamp(int(rel.get("trust", 40)) + int(effect.get("trust", 0)), 0, 100)
			found = true
			break
	if not found:
		relationships.append({
			"id": rel_id,
			"name": effect.get("name", "새 인연"),
			"type": effect.get("type", "friends"),
			"affection": clamp(int(effect.get("affection", 45)), 0, 100),
			"trust": clamp(int(effect.get("trust", 40)), 0, 100),
			"met_turn": turn,
		})
	stats_changed.emit()

func apply_investment_effect(effect):
	var asset_id = str(effect.get("asset_id", ""))
	if asset_id.is_empty():
		return
	if not market_prices.has(asset_id):
		return
	market_prices[asset_id] *= 1.0 + float(effect.get("price_delta", 0.0))
	if bool(effect.get("bubble", false)):
		var bubble_assets: Array = market_context.get("bubble_assets", [])
		if not bubble_assets.has(asset_id):
			bubble_assets.append(asset_id)
		market_context["bubble_assets"] = bubble_assets

func add_money(amount):
	money += amount
	money_changed.emit(money)
	stats_changed.emit()

func modify_stat(stat_name, amount):
	match stat_name:
		"health":
			health = clamp(health + amount, 0, 100)
		"mental":
			mental = clamp(mental + amount, 0, 100)
		"intelligence":
			intelligence = clamp(intelligence + amount, 0, 100)
		"social_skill":
			social_skill = clamp(social_skill + amount, 0, 100)
		"appearance":
			appearance = clamp(appearance + amount, 0, 100)
		"investment_skill":
			investment_skill = clamp(investment_skill + amount, 0, 100)
		"luck":
			luck = clamp(luck + amount, 0, 100)

func modify_hidden_stat(stat_name, amount):
	match stat_name:
		"stress":
			stress = clamp(stress + amount, 0, 100)
		"reputation":
			reputation = clamp(reputation + amount, -100, 100)
		"gambling_tendency":
			gambling_tendency = clamp(gambling_tendency + amount, 0, 100)
		"addiction_tendency":
			addiction_tendency = clamp(addiction_tendency + amount, 0, 100)

func spend_ap(amount: int = 1) -> bool:
	if action_points < amount:
		return false
	action_points -= amount
	stats_changed.emit()
	return true

func restore_ap():
	action_points = max_action_points
	stats_changed.emit()

func add_item(item_id, quantity):
	var item = DataRegistry.get_item(item_id)
	if item.is_empty():
		return
	for owned in inventory:
		if owned.get("id", "") == item_id:
			owned["quantity"] = int(owned.get("quantity", 0)) + quantity
			stats_changed.emit()
			return
	var owned_item = item.duplicate(true)
	owned_item["quantity"] = quantity
	inventory.append(owned_item)
	stats_changed.emit()

func remove_item(item_id, quantity):
	for i in range(inventory.size()):
		if inventory[i].get("id", "") == item_id:
			inventory[i]["quantity"] = int(inventory[i].get("quantity", 1)) - quantity
			if int(inventory[i]["quantity"]) <= 0:
				inventory.remove_at(i)
			stats_changed.emit()
			return true
	return false

func add_log(message, log_type):
	var entry = {
		"turn": turn,
		"date": get_date_string(),
		"message": message,
		"type": log_type,
	}
	action_log.append(entry)
	if action_log.size() > 120:
		action_log.pop_front()
	log_added.emit(entry)

func get_date_string():
	return "%d년 %d월" % [year, month]

func format_money(amount):
	var sign = ""
	if amount < 0:
		sign = "-"
	var abs_amount = abs(amount)
	if abs_amount >= 100_000_000:
		return "%s%.1f억원" % [sign, abs_amount / 100_000_000.0]
	if abs_amount >= 10_000:
		return "%s%.0f만원" % [sign, abs_amount / 10_000.0]
	return "%s%.0f원" % [sign, abs_amount]

func get_total_asset_value():
	var total = money
	for asset_id in portfolio:
		var holding: Dictionary = portfolio[asset_id]
		total += float(holding.get("quantity", 0.0)) * float(market_prices.get(asset_id, holding.get("avg_price", 0.0)))
	return total

func get_wealth_tier():
	var total = get_total_asset_value()
	if total >= 2_000_000_000:
		return "강남 상류층"
	if total >= 500_000_000:
		return "자산가"
	if total >= 100_000_000:
		return "중산층"
	if total >= 30_000_000:
		return "버티는 청년"
	return "월세 생존자"

func check_game_over():
	if is_game_over:
		return
	if health <= 0:
		finish_run("burnout"); return
	if mental <= 0:
		finish_run("mental_break"); return
	if money < -50_000_000:
		finish_run("debt_spiral"); return
	if money < -30_000_000:
		finish_run("bankruptcy"); return
	if addiction_tendency >= 90:
		finish_run("crypto_ghost"); return
	if get_total_asset_value() >= 2_000_000_000:
		finish_run("gangnam_dream"); return
	if flags.get("startup_exit", false):
		finish_run("startup_exit"); return
	if age >= 65:
		var total = get_total_asset_value()
		if reputation >= 80 and total >= 300_000_000:
			finish_run("reputation_legend")
		elif investment_skill >= 85 and total >= 500_000_000:
			finish_run("investment_master")
		elif total >= 1_000_000_000 and relationships.is_empty():
			finish_run("lonely_rich")
		elif total >= 1_000_000_000:
			finish_run("stable_success")
		elif health >= 70 and mental >= 70:
			finish_run("healthy_retirement")
		elif flags.get("political_winner", false):
			finish_run("political_fix")
		else:
			finish_run("ordinary_life")

func finish_run(ending_id):
	is_game_over = true
	MetaProgression.record_run({
		"ending_id": ending_id,
		"turn": turn,
		"age": age,
		"total_assets": get_total_asset_value(),
		"trait": current_trait,
	})
	game_over.emit(ending_id)

func serialize():
	return {
		"player_name": player_name,
		"player_background": player_background,
		"age": age,
		"year": year,
		"month": month,
		"turn": turn,
		"is_game_over": is_game_over,
		"current_trait": current_trait,
		"housing": housing,
		"money": money,
		"monthly_income": monthly_income,
		"fixed_expense": fixed_expense,
		"health": health,
		"mental": mental,
		"intelligence": intelligence,
		"social_skill": social_skill,
		"appearance": appearance,
		"investment_skill": investment_skill,
		"luck": luck,
		"stress": stress,
		"reputation": reputation,
		"action_points": action_points,
		"max_action_points": max_action_points,
		"tutorial_step": tutorial_step,
		"gambling_tendency": gambling_tendency,
		"addiction_tendency": addiction_tendency,
		"current_job": current_job,
		"job_tenure": job_tenure,
		"work_performance": work_performance,
		"milestones_reached": milestones_reached,
		"portfolio": portfolio,
		"relationships": relationships,
		"inventory": inventory,
		"news_log": news_log,
		"event_log": event_log,
		"action_log": action_log,
		"flags": flags,
		"market_prices": market_prices,
		"price_history": price_history,
		"market_context": market_context,
	}

func load_from_dict(data):
	var int_fields = [
		"age", "year", "month", "turn",
		"health", "mental", "intelligence", "social_skill", "appearance",
		"investment_skill", "luck", "stress", "reputation",
		"gambling_tendency", "addiction_tendency",
		"job_tenure", "work_performance",
		"action_points", "max_action_points", "tutorial_step",
	]
	var allowed = serialize().keys()
	for key in data:
		if not allowed.has(key):
			continue
		var value = data[key]
		if int_fields.has(key) and value is float:
			value = int(value)
		set(key, value)
	stats_changed.emit()
