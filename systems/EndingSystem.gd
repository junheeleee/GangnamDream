extends Node

func get_ending(ending_id):
	var ending = DataRegistry.get_ending(ending_id)
	if ending.is_empty():
		return {
			"id": ending_id,
			"title": "미기록 엔딩",
			"grade": "C",
			"description": "이 삶은 아직 정리되지 않은 결말로 남았다.",
		}
	return ending

func evaluate_current_ending():
	var total = GameState.get_total_asset_value()
	if GameState.health <= 0:
		return get_ending("burnout")
	if GameState.mental <= 0:
		return get_ending("mental_break")
	if GameState.money < -200_000_000:
		return get_ending("debt_spiral")
	if GameState.money < -100_000_000:
		return get_ending("bankruptcy")
	if GameState.addiction_tendency >= 90:
		return get_ending("crypto_ghost")
	if total >= 3_000_000_000:
		return get_ending("gangnam_dream")
	if GameState.flags.get("startup_exit", false):
		return get_ending("startup_exit")
	if GameState.age >= 55:
		if GameState.reputation >= 80 and total >= 300_000_000:
			return get_ending("reputation_legend")
		if GameState.investment_skill >= 85 and total >= 500_000_000:
			return get_ending("investment_master")
		if total >= 1_000_000_000 and GameState.relationships.is_empty():
			return get_ending("lonely_rich")
		if total >= 1_000_000_000:
			return get_ending("stable_success")
		if GameState.health >= 70 and GameState.mental >= 70:
			return get_ending("healthy_retirement")
		if GameState.flags.get("political_winner", false):
			return get_ending("political_fix")
		return get_ending("ordinary_life")
	return get_ending("ordinary_life")

func get_score():
	return int(GameState.get_total_asset_value() / 100_000.0) + GameState.turn * 10 + GameState.reputation * 100
