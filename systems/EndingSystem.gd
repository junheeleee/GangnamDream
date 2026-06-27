extends Node

func get_ending(ending_id):
	var ending = DataRegistry.get_ending(ending_id)
	if ending.is_empty():
		return {
			"id": ending_id,
			"title": LocaleManager.ui("미기록 엔딩", "Unrecorded Ending"),
			"grade": "C",
			"description": LocaleManager.ui("이 삶은 아직 정리되지 않은 결말로 남았다.", "This life remains an ending that has not yet been recorded."),
		}
	return ending

# NOTE: 엔딩 발동 로직은 GameState.check_game_over()에서 담당.
# evaluate_current_ending()은 제거됨 — GameState가 유일한 판정 소스.

func get_score():
	var months_elapsed = (GameState.age - 33) * 12 + GameState.month
	return int(GameState.get_total_asset_value() / 100_000.0) + months_elapsed * 10 + GameState.reputation * 100
