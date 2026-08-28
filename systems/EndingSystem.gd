extends Node

const CHAPTER5_FINALE_ROUTE := preload("res://systems/Chapter5FinaleRoute.gd")

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
		"text": "마지막 서명 · 계산\n마지막 장에서 사람들의 이름과 시간은 비용 열에 함께 남았다. 한 열에 두어도 같은 단위가 되지 않는 항목은 그대로 보였다. 무엇을 계산했고 무엇을 계산할 수 없었는지도 같은 서명 아래 남았다.",
		"text_en": "THE LAST SIGNATURE · ACCOUNTING\nOn the last page, people's names and time remained together in the cost column. Even there, entries that shared no unit stayed visibly unlike. What he calculated and what could not be calculated remained beneath the same signature.",
	},
	"final_signature_people": {
		"kind": "people",
		"text": "마지막 서명 · 사람들\n마지막 장에 사람들의 이름을 먼저 적었다. 그것은 누구의 복귀나 용서도 약속하지 않았고, 먼저 연락할 책임만 자기 이름 옆에 남겼다.",
		"text_en": "THE LAST SIGNATURE · PEOPLE\nHe wrote people's names first on the last page. It promised neither anyone's return nor forgiveness; it only left him responsible for reaching out first.",
	},
}

const CHAPTER5_FINALE_OUTBOUND_CODA_BY_CHOICE := {
	0: {
		"kind": "meal",
		"text": "마지막 연락 · 밥을 묻다\n그는 처음 이름을 주고받은 편의점 근처에서 다음 일요일 일곱 시에 밥을 먹자고 먼저 보냈다. 화면에 남은 것은 전송 시각뿐이었다. 다은의 답과 실제 식사는 아직 그녀 쪽의 일이었다.",
		"text_en": "THE LAST MESSAGE · ASKING ABOUT A MEAL\nHe proposed a meal next Sunday at seven, near the convenience store where they first exchanged names. Only the sent time remained on screen. Daeun's answer and the meal itself were still hers to decide.",
	},
	1: {
		"kind": "apology",
		"text": "마지막 연락 · 사과를 보내다\n그는 다은의 답을 기다리기 전에 그녀의 이름이 들어갈 자리부터 계산한 일을 사과했다. 사과는 답을 요구하지 않았고, 화면에는 용서나 화해 대신 전송 시각만 남았다.",
		"text_en": "THE LAST MESSAGE · SENDING THE APOLOGY\nHe apologized for calculating the place Daeun's name could occupy before waiting for her answer. The apology demanded no reply; the screen held a sent time, not forgiveness or reconciliation.",
	},
	2: {
		"kind": "distance",
		"text": "마지막 연락 · 돌아올 시각\n그는 오늘 필요한 거리를 말하고 내일 저녁 여덟 시에 자신이 먼저 연락하겠다고 보냈다. 침묵을 관계의 결론으로 만들지 않은 채, 돌아올 책임을 자기 쪽에 남겼다.",
		"text_en": "THE LAST MESSAGE · A TIME TO RETURN\nHe named the distance he needed tonight and sent that he would contact her first tomorrow at eight. Without turning silence into the relationship's ending, he kept the duty to return on his side.",
	},
}

const CHAPTER5_GENERAL_OUTBOUND_CODA_BY_CHOICE := {
	0: {
		"kind": "minseo_answer_forward",
		"text": "마지막 행동 · 대답 다음의 문장\n그는 민서에게 그날 자신이 했던 대답을 기억한다고, 집을 핑계로 다음 질문을 더 미루지 않겠다고 먼저 보냈다. 화면에는 자기 쪽 전송 시각만 남았고, 읽음·답장·다음 만남은 확정되지 않았다.",
		"text_en": "THE LAST ACTION · THE LINE AFTER HIS ANSWER\nHe told Minseo that he remembered the answer he had given that day and would no longer use getting a home as a reason to postpone the next question. Only his sent time remained; no read receipt, reply, or next meeting was confirmed.",
	},
	1: {
		"kind": "father_envelope_action",
		"text": "마지막 행동 · 아버지 봉투의 한 줄\n그는 아버지 기록 봉투에 빈 의자 앞에서 했던 행동과 오늘 지운 것, 지우지 못한 것을 한 줄로 적었다. 날짜는 남았지만 방 안에 답이나 사후의 화해는 생기지 않았다.",
		"text_en": "THE LAST ACTION · A LINE ON FATHER'S ENVELOPE\nHe wrote one line on Father's record envelope: what he had done before the empty chair, what he had erased today, and what he had not. The date remained, but no answer or reconciliation beyond death appeared in the room.",
	},
	2: {
		"kind": "minseo_meeting_request",
		"text": "마지막 행동 · 다음 화요일을 묻다\n그는 민서에게 다음 화요일 저녁 일곱 시 반, 그 카페에서 삼십 분 이야기할 수 있는지 먼저 물었다. 자기 쪽 전송 시각만 생겼고, 읽음·답장·약속된 만남은 여전히 민서의 선택으로 남았다.",
		"text_en": "THE LAST ACTION · ASKING ABOUT NEXT TUESDAY\nHe asked Minseo if she could talk for thirty minutes at that cafe next Tuesday at seven thirty. Only his sent time appeared; the read receipt, reply, and any meeting remained Minseo's to decide.",
	},
}

const CHAPTER5_GENERAL_SACRIFICE_CODA_BY_CHOICE := {
	0: {
		"kind": "addresses",
		"text": "마지막 포기 · 세 주소\n그는 남겨 둔 세 주소와 가격 알림을 모두 지웠다. 수첩 첫 장의 30억은 남아 있었지만, 그 밤에는 매수도 소유도 이체도 생기지 않았다.",
		"text_en": "THE LAST SACRIFICE · THREE ADDRESSES\nHe deleted all three saved addresses and their price alerts. The three-billion-won figure remained on the first page of his notebook, but that night brought no purchase, ownership, or transfer.",
	},
	1: {
		"kind": "target",
		"text": "마지막 포기 · 30억\n그는 수첩 첫 장의 30억을 두 줄로 그어 지웠다. 세 주소는 끝까지 그의 소유가 아니었다. 이제 누구에게 무엇을 먼저 할지와 그 책임만 자기 이름에 남았다.",
		"text_en": "THE LAST SACRIFICE · THREE BILLION WON\nHe crossed out the three-billion-won target on the first page of his notebook with two strokes. The three addresses were never his. What he would do first for whom, and responsibility for it, remained beside his own name.",
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


## The first general-finale aftermath card comes from the exact consumed W240
## sacrifice receipt. This keeps the rejected administrative signature flags
## from overwriting the action the player actually chose.
func chapter5_general_sacrifice_coda(
		ending_id: Variant, raw_finale_state: Variant) -> Dictionary:
	var normalized_ending_id := str(ending_id).strip_edges()
	if normalized_ending_id not in FINAL_SIGNATURE_CODA_ENDING_IDS \
			or not raw_finale_state is Dictionary:
		return {}
	var canonical := CHAPTER5_FINALE_ROUTE.state_from_save(
		raw_finale_state, true, CHAPTER5_FINALE_ROUTE.GENERAL_ENTRY_TURN)
	if str(canonical.get("status", "")) != "open" \
			or str(canonical.get("ending_check", "")) != "consumed" \
			or not CHAPTER5_FINALE_ROUTE.route_complete(canonical):
		return {}
	var receipt := CHAPTER5_FINALE_ROUTE.receipt_snapshot_for_stage(
		canonical, "sacrifice")
	if str(receipt.get("event_id", "")) \
			!= "arc_final_countdown_general_near_goal_passed":
		return {}
	var choice_index := int(receipt.get("choice_index", -1))
	if not CHAPTER5_GENERAL_SACRIFICE_CODA_BY_CHOICE.has(choice_index):
		return {}
	return (CHAPTER5_GENERAL_SACRIFICE_CODA_BY_CHOICE[choice_index] \
		as Dictionary).duplicate(true)


## The protected M56-M60 route records the final outgoing action in its exact
## reducer receipt. Read that receipt directly so legacy self-approval/gratitude
## flags cannot make the ending remember a sentence the player never chose.
func chapter5_finale_outbound_coda(
		ending_id: Variant, raw_finale_state: Variant) -> Dictionary:
	var normalized_ending_id := str(ending_id).strip_edges()
	if normalized_ending_id not in FINAL_SIGNATURE_CODA_ENDING_IDS \
			or not raw_finale_state is Dictionary:
		return {}
	var canonical := CHAPTER5_FINALE_ROUTE.state_from_save(
		raw_finale_state, true, CHAPTER5_FINALE_ROUTE.ENTRY_TURN)
	if str(canonical.get("status", "")) != "open" \
			or str(canonical.get("ending_check", "")) != "consumed" \
			or not CHAPTER5_FINALE_ROUTE.route_complete(canonical):
		return {}
	var receipt := CHAPTER5_FINALE_ROUTE.receipt_snapshot_for_stage(
		canonical, "outbound")
	var event_id := str(receipt.get("event_id", ""))
	var coda_by_choice: Dictionary = {}
	if event_id == "arc_y5_final_week_daeun_outbound":
		coda_by_choice = CHAPTER5_FINALE_OUTBOUND_CODA_BY_CHOICE
	elif event_id == "arc_y5_final_week_general_people_outbound":
		coda_by_choice = CHAPTER5_GENERAL_OUTBOUND_CODA_BY_CHOICE
	else:
		return {}
	var choice_index := int(receipt.get("choice_index", -1))
	if not coda_by_choice.has(choice_index):
		return {}
	return (coda_by_choice[choice_index] \
		as Dictionary).duplicate(true)

# NOTE: 엔딩 발동 로직은 GameState.check_game_over()에서 담당.
# evaluate_current_ending()은 제거됨 — GameState가 유일한 판정 소스.

func get_score():
	var months_elapsed = (GameState.age - 33) * 12 + GameState.month
	return int(GameState.get_total_asset_value() / 100_000.0) + months_elapsed * 10 + GameState.reputation * 100
