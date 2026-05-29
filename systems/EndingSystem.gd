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

# NOTE: 엔딩 발동 로직은 GameState.check_game_over()에서 담당.
# evaluate_current_ending()은 제거됨 — GameState가 유일한 판정 소스.

func get_score():
	return int(GameState.get_total_asset_value() / 100_000.0) + GameState.turn * 10 + GameState.reputation * 100
