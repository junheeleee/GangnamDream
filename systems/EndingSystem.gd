extends Node

const FINAL_SIGNATURE_CODA_ENDING_IDS := [
	"gangnam_dream",
	"empty_house",
	"with_daeun",
	"jiyeon_man",
	"jaehyuk_way",
	"late_call",
	"stable_success",
	"ordinary_life",
	"lonely_rich",
	"investment_master",
	"reputation_legend",
	"healthy_retirement",
	"orthodox_pinnacle",
	"orthodox_hollow",
	"balanced_life",
	"unorthodox_legend",
	"early_retirement",
	"full_circle",
	"gangnam_dream_white",
	"gambling_recovery",
	"career_climber",
	"career_burnout",
	"sangchul_reckoning",
	"writer",
]

const FINAL_SIGNATURE_CODA_EXCLUDED_ENDING_IDS := [
	"burnout",
	"mental_break",
	"bankruptcy",
	"crypto_ghost",
	"debt_spiral",
	"instant_legend",
	"startup_exit",
	"second_love",
	"guardian",
	"creator_success",
	"political_fix",
]

const FINAL_SIGNATURE_CODA_BY_FLAG := {
	"final_signature_owned": {
		"kind": "owned",
		"text": "마지막 서명 · 책임\n마지막 장에 자기 이름을 썼다. 책임을 누구에게도 넘기지 않았지만, 빌린 시간과 미뤄 둔 관계까지 그 서명 하나로 정리된 것은 아니었다.",
		"text_en": "THE LAST SIGNATURE · RESPONSIBILITY\nHe wrote his own name on the last page. He handed responsibility to no one else, but one signature did not settle the time he had borrowed or the relationships he had postponed.",
	},
	"final_signature_collateral": {
		"kind": "collateral",
		"text": "마지막 서명 · 담보\n마지막 장에서 사람들의 이름은 다시 비용과 가치의 열로 들어갔다. 다섯 해는 끝났지만, 계산표 밖으로 밀려난 목소리가 저절로 돌아온 것은 아니었다.",
		"text_en": "THE LAST SIGNATURE · COLLATERAL\nOn the last page, people's names entered the cost and value columns again. The five years were over, but the voices pushed beyond the ledger did not return on their own.",
	},
	"final_signature_people": {
		"kind": "people",
		"text": "마지막 서명 · 사람들\n마지막 장에 사람들의 이름을 먼저 적었다. 그것은 누구의 복귀나 용서도 약속하지 않았고, 먼저 연락할 책임만 자기 이름 옆에 남겼다.",
		"text_en": "THE LAST SIGNATURE · PEOPLE\nHe wrote people's names first on the last page. It promised neither anyone's return nor forgiveness; it only left him responsible for reaching out first.",
	},
}

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


## 마지막 서명은 기존 ending description의 first-true 변주를 덮지 않는다.
## ending ID와 그 런의 flags만 읽는 순수 resolver로 독립 후일담 카드만 돌려준다.
func final_signature_coda(ending_id: Variant, run_flags: Variant) -> Dictionary:
	if not run_flags is Dictionary:
		return {}
	var normalized_ending_id := str(ending_id).strip_edges()
	if normalized_ending_id not in FINAL_SIGNATURE_CODA_ENDING_IDS:
		return {}
	var flags: Dictionary = run_flags
	for raw_flag_id in flags.keys():
		var flag_id := str(raw_flag_id)
		if flag_id.begins_with("final_signature_") \
				and flag_id not in FINAL_SIGNATURE_CODA_BY_FLAG:
			return {}
	var selected_flags: Array[String] = []
	for flag_id: String in FINAL_SIGNATURE_CODA_BY_FLAG:
		if flags.has(flag_id) and not flags[flag_id] is bool:
			return {}
		if bool(flags.get(flag_id, false)):
			selected_flags.append(flag_id)
	if selected_flags.size() != 1:
		return {}
	return (FINAL_SIGNATURE_CODA_BY_FLAG[selected_flags[0]] as Dictionary).duplicate(true)

# NOTE: 엔딩 발동 로직은 GameState.check_game_over()에서 담당.
# evaluate_current_ending()은 제거됨 — GameState가 유일한 판정 소스.

func get_score():
	var months_elapsed = (GameState.age - 33) * 12 + GameState.month
	return int(GameState.get_total_asset_value() / 100_000.0) + months_elapsed * 10 + GameState.reputation * 100
