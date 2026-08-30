extends Node
## 종결 자산이 같아도 5년 동안 실제로 걸은 전략이 고유 결산으로 이어지는지 실행한다.

const CHAPTER5_CAUSAL_ROUTE := preload("res://systems/Chapter5CausalRoute.gd")
const CHAPTER5_FINALE_ROUTE := preload("res://systems/Chapter5FinaleRoute.gd")

var _failures: Array[String] = []
var _received_endings: Array[String] = []

const FINAL_SIGNATURE_APPLY_IDS := [
	"gangnam_dream", "empty_house", "with_daeun", "jiyeon_man", "jaehyuk_way",
	"late_call", "stable_success", "ordinary_life", "lonely_rich", "investment_master",
	"reputation_legend", "healthy_retirement", "orthodox_pinnacle", "orthodox_hollow",
	"balanced_life", "unorthodox_legend", "early_retirement", "full_circle",
	"gangnam_dream_white", "gambling_recovery", "career_climber", "career_burnout",
	"sangchul_reckoning", "writer",
]

const FINAL_SIGNATURE_EXCLUDED_IDS := [
	"burnout", "mental_break", "bankruptcy", "crypto_ghost", "debt_spiral",
	"instant_legend", "startup_exit", "second_love", "guardian", "creator_success",
	"political_fix",
]

const FINAL_SIGNATURE_CASES := {
	"final_signature_owned": "owned",
	"final_signature_collateral": "collateral",
	"final_signature_people": "people",
}

const EXPECTED_FINALE_OUTBOUND_CODAS := [
	{
		"kind": "meal",
		"text": "마지막 연락 · 밥을 묻다\n그는 처음 이름을 주고받은 편의점 근처에서 다음 일요일 일곱 시에 밥을 먹자고 먼저 보냈다. 화면에 남은 것은 전송 시각뿐이었다. 다은의 답과 실제 식사는 아직 그녀 쪽의 일이었다.",
		"text_en": "THE LAST MESSAGE · ASKING ABOUT A MEAL\nHe proposed a meal next Sunday at seven, near the convenience store where they first exchanged names. Only the sent time remained on screen. Daeun's answer and the meal itself were still hers to decide.",
	},
	{
		"kind": "apology",
		"text": "마지막 연락 · 사과를 보내다\n그는 다은의 답을 기다리기 전에 그녀의 이름이 들어갈 자리부터 계산한 일을 사과했다. 사과는 답을 요구하지 않았고, 화면에는 용서나 화해 대신 전송 시각만 남았다.",
		"text_en": "THE LAST MESSAGE · SENDING THE APOLOGY\nHe apologized for calculating the place Daeun's name could occupy before waiting for her answer. The apology demanded no reply; the screen held a sent time, not forgiveness or reconciliation.",
	},
	{
		"kind": "distance",
		"text": "마지막 연락 · 돌아올 시각\n그는 오늘 필요한 거리를 말하고 내일 저녁 여덟 시에 자신이 먼저 연락하겠다고 보냈다. 침묵을 관계의 결론으로 만들지 않은 채, 돌아올 책임을 자기 쪽에 남겼다.",
		"text_en": "THE LAST MESSAGE · A TIME TO RETURN\nHe named the distance he needed tonight and sent that he would contact her first tomorrow at eight. Without turning silence into the relationship's ending, he kept the duty to return on his side.",
	},
]
const EXPECTED_GENERAL_OUTBOUND_CODAS := [
	{
		"kind": "minseo_answer_forward",
		"text": "마지막 행동 · 대답 다음의 문장\n그는 민서에게 그날 자신이 했던 대답을 기억한다고, 집을 핑계로 다음 질문을 더 미루지 않겠다고 먼저 보냈다. 화면에는 자기 쪽 전송 시각만 남았고, 읽음·답장·다음 만남은 확정되지 않았다.",
		"text_en": "THE LAST ACTION · THE LINE AFTER HIS ANSWER\nHe told Minseo that he remembered the answer he had given that day and would no longer use getting a home as a reason to postpone the next question. Only his sent time remained; no read receipt, reply, or next meeting was confirmed.",
	},
	{
		"kind": "father_envelope_action",
		"text": "마지막 행동 · 아버지 봉투의 한 줄\n그는 아버지 기록 봉투에 빈 의자 앞에서 했던 행동과 오늘 지운 것, 지우지 못한 것을 한 줄로 적었다. 날짜는 남았지만 방 안에 답이나 사후의 화해는 생기지 않았다.",
		"text_en": "THE LAST ACTION · A LINE ON FATHER'S ENVELOPE\nHe wrote one line on Father's record envelope: what he had done before the empty chair, what he had erased today, and what he had not. The date remained, but no answer or reconciliation beyond death appeared in the room.",
	},
	{
		"kind": "minseo_meeting_request",
		"text": "마지막 행동 · 다음 화요일을 묻다\n그는 민서에게 다음 화요일 저녁 일곱 시 반, 그 카페에서 삼십 분 이야기할 수 있는지 먼저 물었다. 자기 쪽 전송 시각만 생겼고, 읽음·답장·약속된 만남은 여전히 민서의 선택으로 남았다.",
		"text_en": "THE LAST ACTION · ASKING ABOUT NEXT TUESDAY\nHe asked Minseo if she could talk for thirty minutes at that cafe next Tuesday at seven thirty. Only his sent time appeared; the read receipt, reply, and any meeting remained Minseo's to decide.",
	},
]
const EXPECTED_GENERAL_SACRIFICE_CODAS := [
	{
		"kind": "addresses",
		"text": "마지막 포기 · 세 주소\n그는 남겨 둔 세 주소와 가격 알림을 모두 지웠다. 수첩 첫 장의 30억은 남아 있었지만, 그 밤에는 매수도 소유도 이체도 생기지 않았다.",
		"text_en": "THE LAST SACRIFICE · THREE ADDRESSES\nHe deleted all three saved addresses and their price alerts. The three-billion-won figure remained on the first page of his notebook, but that night brought no purchase, ownership, or transfer.",
	},
	{
		"kind": "target",
		"text": "마지막 포기 · 30억\n그는 수첩 첫 장의 30억을 두 줄로 그어 지웠다. 세 주소는 끝까지 그의 소유가 아니었다. 이제 누구에게 무엇을 먼저 할지와 그 책임만 자기 이름에 남았다.",
		"text_en": "THE LAST SACRIFICE · THREE BILLION WON\nHe crossed out the three-billion-won target on the first page of his notebook with two strokes. The three addresses were never his. What he would do first for whom, and responsibility for it, remained beside his own name.",
	},
]

func _ready() -> void:
	# Route identity is a data/state contract. Do not retain ending stinger streams
	# while the fixture emits many game_over signals in one headless frame.
	AudioManager.sfx_enabled = false
	GameState.game_over.connect(_on_game_over)
	_check_final_signature_coda_contract()
	_check_chapter5_finale_outbound_coda_contract()
	_check_chapter5_finale_ending_release()
	_check_chapter5_finale_failure_priority()
	_check_chapter5_general_outbound_coda_contract()
	_check_chapter5_general_sacrifice_coda_contract()
	_check_chapter5_general_ending_release()
	_check_chapter5_general_failure_priority()
	_check_startup_before_generic_gangnam()
	_check_first_year_gangnam_is_instant_legend()
	_check_generic_gangnam_waits_for_final_week()
	_check_full_circle_waits_for_final_week()
	_check_father_passed_gangnam_is_empty_house()
	_check_father_passed_blocks_late_call()
	_check_daeun_reckoning_blocks_instant_gangnam()
	_check_failure_stays_immediate_after_goal()
	_check_committed_investor_before_career()
	_check_uncommitted_investor_stays_career()
	_check_legacy_investment_master_path()
	_check_orthodox_before_career()
	_check_unorthodox_before_career()
	_check_balanced_before_career()
	_check_plain_career_fallback()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("ENDING_ROUTE_IDENTITY_CHECK_FAIL " + failure)
		_stop_fixture_audio()
		await get_tree().create_timer(0.5).timeout
		get_tree().quit(1)
		return
	_stop_fixture_audio()
	await get_tree().create_timer(0.5).timeout
	print("ENDING_ROUTE_IDENTITY_CHECK_OK routes=15+finale4 coda_apply=72 coda_excluded=33 finale_coda=6 general_sacrifice_coda=2 failure_priority=10 w240_canonical_once=4 instant_legend=preserved")
	get_tree().quit(0)

func _stop_fixture_audio() -> void:
	for raw_player in AudioManager.get("_pool"):
		if is_instance_valid(raw_player):
			(raw_player as AudioStreamPlayer).stop()
			(raw_player as AudioStreamPlayer).stream = null
	var fixture_sounds: Dictionary = AudioManager.get("_sounds")
	fixture_sounds.clear()


func _check_final_signature_coda_contract() -> void:
	var expected_ids: Array[String] = []
	expected_ids.append_array(FINAL_SIGNATURE_APPLY_IDS)
	expected_ids.append_array(FINAL_SIGNATURE_EXCLUDED_IDS)
	expected_ids.sort()
	var catalog_ids: Array[String] = []
	var seen_ids: Dictionary = {}
	var seen_cgs: Dictionary = {}
	for ending_variant in DataRegistry.endings:
		if not ending_variant is Dictionary:
			_failures.append("ending catalog contains a non-Dictionary row")
			continue
		var ending: Dictionary = ending_variant
		var ending_id := str(ending.get("id", ""))
		var cg_id := str(ending.get("cg", ""))
		if seen_ids.has(ending_id):
			_failures.append("ending catalog duplicated id %s" % ending_id)
		seen_ids[ending_id] = true
		catalog_ids.append(ending_id)
		if cg_id != "cg_ending_%s" % ending_id:
			_failures.append("%s changed its dedicated CG id to %s" % [ending_id, cg_id])
		if seen_cgs.has(cg_id):
			_failures.append("ending catalog shared CG %s" % cg_id)
		seen_cgs[cg_id] = true
	catalog_ids.sort()
	if catalog_ids != expected_ids:
		_failures.append("final-signature 24/11 partition does not equal the 35 ending catalog")

	var applied := 0
	var excluded := 0
	for ending_id in expected_ids:
		for flag_id: String in FINAL_SIGNATURE_CASES:
			var input_flags := {flag_id: true, "unrelated_run_fact": true}
			var before := input_flags.duplicate(true)
			var coda: Dictionary = EndingSystem.final_signature_coda(ending_id, input_flags)
			if input_flags != before:
				_failures.append("%s/%s mutated the run flags" % [ending_id, flag_id])
			if ending_id in FINAL_SIGNATURE_APPLY_IDS:
				applied += 1
				_check_signature_payload(ending_id, flag_id, coda)
			else:
				excluded += 1
				if not coda.is_empty():
					_failures.append("excluded ending %s returned %s" % [ending_id, flag_id])
	if applied != 72 or excluded != 33:
		_failures.append("final-signature matrix drifted apply=%d excluded=%d" % [applied, excluded])

	var invalid_cases: Array = [
		["unknown_ending", {"final_signature_owned": true}],
		["ordinary_life", {}],
		["ordinary_life", {"final_signature_owned": false}],
		["ordinary_life", {"final_signature_owned": true, "final_signature_people": true}],
		["ordinary_life", {
			"final_signature_owned": true,
			"final_signature_collateral": true,
			"final_signature_people": true,
		}],
		["ordinary_life", {"final_signature_unknown": true}],
		["ordinary_life", {
			"final_signature_owned": true,
			"final_signature_unknown": false,
		}],
		["ordinary_life", {"final_signature_owned": "true"}],
		["ordinary_life", null],
		["ordinary_life", []],
		["ordinary_life", "final_signature_people"],
	]
	for invalid_case in invalid_cases:
		var coda: Dictionary = EndingSystem.final_signature_coda(
			invalid_case[0], invalid_case[1])
		if not coda.is_empty():
			_failures.append("invalid final-signature input returned a coda: %s" % [invalid_case])

	var first_payload: Dictionary = EndingSystem.final_signature_coda(
		"ordinary_life", {"final_signature_owned": true})
	first_payload["kind"] = "mutated_by_test"
	var second_payload: Dictionary = EndingSystem.final_signature_coda(
		"ordinary_life", {"final_signature_owned": true})
	if str(second_payload.get("kind", "")) != "owned":
		_failures.append("final-signature resolver leaked a mutable shared payload")


func _check_signature_payload(
		ending_id: String, flag_id: String, coda: Dictionary) -> void:
	var keys: Array = coda.keys()
	keys.sort()
	if keys != ["kind", "text", "text_en"]:
		_failures.append("%s/%s returned payload keys %s" % [ending_id, flag_id, keys])
		return
	if str(coda.get("kind", "")) != str(FINAL_SIGNATURE_CASES[flag_id]):
		_failures.append("%s/%s returned kind %s" % [ending_id, flag_id, coda.get("kind", "")])
	if str(coda.get("text", "")).strip_edges().is_empty() \
			or str(coda.get("text_en", "")).strip_edges().is_empty():
		_failures.append("%s/%s returned an empty KO/EN coda" % [ending_id, flag_id])
	var surface := "%s %s" % [coda.get("text", ""), coda.get("text_en", "")]
	if "final_signature_" in surface:
		_failures.append("%s/%s leaked an internal flag onto the player surface" % [ending_id, flag_id])

func _completed_chapter5_causal_state() -> Dictionary:
	var state := CHAPTER5_CAUSAL_ROUTE.default_state()
	var locked := CHAPTER5_CAUSAL_ROUTE.lock_entry(
		state, 195, "투자형", true, true, 2_100_000_000.0)
	if not bool(locked.get("ok", false)):
		return {}
	state = (locked.get("state", {}) as Dictionary).duplicate(true)
	var choice_indices := {
		"arc_y5_jaehyuk_guarantee_decision_reference": 1,
		"arc_sangchul_final_door": 0,
		"arc_y5_three_in_room_decision": 1,
	}
	for turn_value in range(195, 221):
		while true:
			var event_id := CHAPTER5_CAUSAL_ROUTE.next_event_for_turn(
				state, turn_value)
			if event_id.is_empty():
				break
			var result := CHAPTER5_CAUSAL_ROUTE.commit_choice(
				state, event_id, int(choice_indices.get(event_id, 0)), turn_value)
			if not bool(result.get("ok", false)):
				return {}
			state = (result.get("state", {}) as Dictionary).duplicate(true)
	return state if CHAPTER5_CAUSAL_ROUTE.route_complete(state) else {}

func _prepare_chapter5_finale_case(
		total_assets: float, outbound_choice: int = 0,
		last_turn: int = 240, include_outbound: bool = true) -> bool:
	_prepare_case(37)
	GameState.money = total_assets
	GameState.relationships = [{
		"id": "finale_fixture", "name": "Finale fixture", "type": "friend",
		"affection": 60, "trust": 60, "met_turn": 1,
	}]
	var source_state := _completed_chapter5_causal_state()
	if source_state.is_empty():
		return false
	GameState.chapter5_causal_state = source_state
	for turn_value in range(221, last_turn + 1):
		GameState.turn = turn_value
		if turn_value == CHAPTER5_FINALE_ROUTE.ENTRY_TURN \
				and not GameState.prepare_chapter5_finale_route_entry():
			return false
		while true:
			var event_id := GameState.chapter5_finale_next_event_for_turn()
			if event_id.is_empty():
				break
			if event_id == "arc_y5_final_week_daeun_outbound" \
					and not include_outbound:
				return true
			var choice_index := outbound_choice \
				if event_id == "arc_y5_final_week_daeun_outbound" else 0
			var result := GameState.record_chapter5_finale_choice(
				event_id, choice_index)
			if not bool(result.get("ok", false)):
				return false
	if include_outbound and last_turn >= 240:
		GameState.flags["arc_final_week_seen"] = true
	return true


func _prepare_chapter5_general_finale_case(
		total_assets: float, outbound_choice: int = 0,
		include_outbound: bool = true, sacrifice_choice: int = 1) -> bool:
	_prepare_case(37)
	GameState.player_route = "투자형"
	GameState.tendency_realized = "invest"
	GameState.flags["route_invest"] = true
	# Entry is intentionally exact at W224. Under-goal ending fixtures model a
	# later loss by applying their terminal assets only after the durable route
	# has been completed.
	GameState.money = maxf(total_assets, 2_500_000_000.0)
	GameState.flags["father_passed"] = true
	GameState.flags["chapter5_general_minseo_arrival_1"] = true
	GameState.flags["arc_y5_general_name_boundary_exact_seen"] = true
	GameState.flags["chapter5_general_name_boundary_0"] = true
	GameState.flags["arc_y5_general_debt_memory_reconnect_seen"] = true
	GameState.flags["chapter5_general_debt_memory_reconnect_0"] = true
	GameState.flags["arc_endgame_sixmonths_seen"] = true
	GameState.event_log = [
		{"event_id": "arc_minseo_03_arrival", "choice_index": 1, "turn": 203},
		{"event_id": "arc_y5_general_name_boundary_exact", "choice_index": 0, "turn": 211},
		{"event_id": "arc_y5_general_debt_memory_reconnect", "choice_index": 0, "turn": 220},
	]
	GameState.turn = 224
	if not GameState.prepare_chapter5_finale_route_entry():
		return false
	var prefinal_events: Array[String] = [
		"arc_y5_general_father_legacy_voice_exact",
		"arc_y5_general_debt_memory_voice_exact",
		"arc_y5_general_pre_ending_summit_exact",
		"arc_y5_general_final_record_seal",
	]
	var prefinal_turns: Array[int] = [224, 229, 234, 237]
	var prefinal_choices: Array[int] = [0, 0, 0, 1]
	for index in range(prefinal_events.size()):
		GameState.turn = prefinal_turns[index]
		var result := GameState.record_chapter5_finale_choice(
			prefinal_events[index], prefinal_choices[index])
		if not bool(result.get("ok", false)):
			return false
	GameState.turn = 240
	var sacrifice := GameState.record_chapter5_finale_choice(
		"arc_final_countdown_general_near_goal_passed", sacrifice_choice)
	if not bool(sacrifice.get("ok", false)):
		return false
	if not include_outbound:
		GameState.money = total_assets
		return true
	var outbound := GameState.record_chapter5_finale_choice(
		"arc_y5_final_week_general_people_outbound", outbound_choice)
	if bool(outbound.get("ok", false)):
		GameState.flags["arc_final_week_seen"] = true
		GameState.money = total_assets
	return bool(outbound.get("ok", false))


func _check_chapter5_general_outbound_coda_contract() -> void:
	for choice_index in range(3):
		if not _prepare_chapter5_general_finale_case(150_000_000.0, choice_index):
			_failures.append("could not build general coda choice %d" % choice_index)
			continue
		var ready := GameState.chapter5_finale_state.duplicate(true)
		if not EndingSystem.chapter5_finale_outbound_coda("ordinary_life", ready).is_empty():
			_failures.append("ready general finale exposed coda early")
			continue
		GameState.consume_chapter5_finale_ending()
		var consumed := GameState.chapter5_finale_state.duplicate(true)
		var coda := EndingSystem.chapter5_finale_outbound_coda("ordinary_life", consumed)
		if coda != EXPECTED_GENERAL_OUTBOUND_CODAS[choice_index]:
			_failures.append("general coda %d payload drifted" % choice_index)
			continue
		coda["kind"] = "mutated"
		if EndingSystem.chapter5_finale_outbound_coda(
			"ordinary_life", consumed) != EXPECTED_GENERAL_OUTBOUND_CODAS[choice_index]:
			_failures.append("general coda leaked mutable payload")
		for unsupported in ["burnout", "instant_legend", "unknown_ending"]:
			if not EndingSystem.chapter5_finale_outbound_coda(unsupported, consumed).is_empty():
				_failures.append("unsupported ending received general coda")
		var corrupt := consumed.duplicate(true)
		((corrupt["receipts"] as Dictionary)[
			"arc_y5_final_week_general_people_outbound"] as Dictionary)["choice_index"] = 99
		if not EndingSystem.chapter5_finale_outbound_coda("ordinary_life", corrupt).is_empty():
			_failures.append("corrupt general state received coda")


func _check_chapter5_general_sacrifice_coda_contract() -> void:
	for choice_index in range(2):
		if not _prepare_chapter5_general_finale_case(
				150_000_000.0, 2, true, choice_index):
			_failures.append(
				"could not build general sacrifice coda choice %d" % choice_index)
			continue
		var ready := GameState.chapter5_finale_state.duplicate(true)
		if not EndingSystem.chapter5_general_sacrifice_coda(
				"ordinary_life", ready).is_empty():
			_failures.append("ready general finale exposed sacrifice coda early")
			continue
		GameState.consume_chapter5_finale_ending()
		var consumed := GameState.chapter5_finale_state.duplicate(true)
		var coda := EndingSystem.chapter5_general_sacrifice_coda(
			"ordinary_life", consumed)
		if coda != EXPECTED_GENERAL_SACRIFICE_CODAS[choice_index]:
			_failures.append(
				"general sacrifice coda %d payload drifted" % choice_index)
			continue
		coda["kind"] = "mutated"
		if EndingSystem.chapter5_general_sacrifice_coda(
				"ordinary_life", consumed) \
				!= EXPECTED_GENERAL_SACRIFICE_CODAS[choice_index]:
			_failures.append("general sacrifice coda leaked mutable payload")
		for unsupported in ["burnout", "instant_legend", "unknown_ending"]:
			if not EndingSystem.chapter5_general_sacrifice_coda(
					unsupported, consumed).is_empty():
				_failures.append(
					"unsupported ending received general sacrifice coda")
		var corrupt := consumed.duplicate(true)
		((corrupt["receipts"] as Dictionary)[
			"arc_final_countdown_general_near_goal_passed"] \
			as Dictionary)["choice_index"] = 99
		if not EndingSystem.chapter5_general_sacrifice_coda(
				"ordinary_life", corrupt).is_empty():
			_failures.append("corrupt general state received sacrifice coda")


func _check_chapter5_general_ending_release() -> void:
	if not _prepare_chapter5_general_finale_case(3_200_000_000.0):
		_failures.append("could not build goal general finale")
		return
	_expect_no_route("general goal before consumed outbound")
	GameState.consume_chapter5_finale_ending()
	_expect_route("general father-passed goal release", "empty_house")
	if not _prepare_chapter5_general_finale_case(150_000_000.0):
		_failures.append("could not build under-goal general finale")
		return
	GameState.consume_chapter5_finale_ending()
	_expect_route("general under-goal release", "ordinary_life")


func _check_chapter5_general_failure_priority() -> void:
	var cases := [
		["health", 0, "burnout"], ["mental", 0, "mental_break"],
		["money", -150_000_000.0, "bankruptcy"],
		["money", -250_000_000.0, "debt_spiral"], ["addiction", 90, "crypto_ghost"],
	]
	for failure_case in cases:
		if not _prepare_chapter5_general_finale_case(3_200_000_000.0):
			_failures.append("could not build general failure-priority fixture")
			return
		match str(failure_case[0]):
			"health": GameState.health = int(failure_case[1])
			"mental": GameState.mental = int(failure_case[1])
			"money": GameState.money = float(failure_case[1])
			"addiction": GameState.addiction_tendency = int(failure_case[1])
		_expect_route("general immediate %s priority" % failure_case[2], str(failure_case[2]))

func _check_chapter5_finale_outbound_coda_contract() -> void:
	var outbound_event: Dictionary = DataRegistry.find_event(
		"arc_y5_final_week_daeun_outbound")
	var outbound_choices: Array = outbound_event.get("choices", [])
	if outbound_choices.size() != 3:
		_failures.append("finale outbound no longer has exactly three choices")
	else:
		for raw_choice in outbound_choices:
			var choice: Dictionary = raw_choice
			if choice.get("effects", {}) != {} \
					or (choice.get("flags", []) as Array).has(
						"final_week_self_approval") \
					or (choice.get("flags", []) as Array).has(
						"final_week_gratitude"):
				_failures.append(
					"finale outbound reintroduced legacy effects or meaning flags")

	for choice_index in range(3):
		if not _prepare_chapter5_finale_case(
				150_000_000.0, choice_index, 240, true):
			_failures.append("could not build finale coda choice %d" % choice_index)
			continue
		var ready_state := GameState.chapter5_finale_state.duplicate(true)
		if not EndingSystem.chapter5_finale_outbound_coda(
				"ordinary_life", ready_state).is_empty():
			_failures.append("ready finale state exposed outbound coda early")
		var release := GameState.consume_chapter5_finale_ending()
		if not bool(release.get("ok", false)):
			_failures.append("could not consume finale coda choice %d" % choice_index)
			continue
		var consumed_state := GameState.chapter5_finale_state.duplicate(true)
		var before := consumed_state.duplicate(true)
		var coda := EndingSystem.chapter5_finale_outbound_coda(
			"ordinary_life", consumed_state)
		var keys: Array = coda.keys()
		keys.sort()
		if consumed_state != before \
				or keys != ["kind", "text", "text_en"] \
				or coda != EXPECTED_FINALE_OUTBOUND_CODAS[choice_index]:
			_failures.append(
				"finale outbound coda %d did not resolve exact KO/EN payload" \
				% choice_index)
		coda["kind"] = "mutated_by_test"
		if str(EndingSystem.chapter5_finale_outbound_coda(
				"ordinary_life", consumed_state).get("kind", "")) \
				!= str(EXPECTED_FINALE_OUTBOUND_CODAS[choice_index]["kind"]):
			_failures.append("finale outbound coda leaked shared mutable payload")
		for unsupported_ending in ["burnout", "instant_legend", "unknown_ending"]:
			if not EndingSystem.chapter5_finale_outbound_coda(
					unsupported_ending, consumed_state).is_empty():
				_failures.append(
					"unsupported ending %s received finale outbound coda" \
					% unsupported_ending)
		var corrupt := consumed_state.duplicate(true)
		var corrupt_receipts: Dictionary = corrupt["receipts"]
		var corrupt_outbound: Dictionary = (
			corrupt_receipts["arc_y5_final_week_daeun_outbound"] \
			as Dictionary).duplicate(true)
		corrupt_outbound["choice_index"] = 99
		corrupt_receipts["arc_y5_final_week_daeun_outbound"] = corrupt_outbound
		corrupt["receipts"] = corrupt_receipts
		if not EndingSystem.chapter5_finale_outbound_coda(
				"ordinary_life", corrupt).is_empty():
			_failures.append("corrupt finale state received an outbound coda")

	if not _prepare_chapter5_finale_case(150_000_000.0, 0, 239, false):
		_failures.append("could not build pending W239 outbound coda fixture")
	elif not EndingSystem.chapter5_finale_outbound_coda(
			"ordinary_life", GameState.chapter5_finale_state).is_empty():
		_failures.append("pending W239 finale state received an outbound coda")

func _check_chapter5_finale_ending_release() -> void:
	if not _prepare_chapter5_finale_case(3_200_000_000.0, 0, 240, true):
		_failures.append("could not build goal-reaching W240 finale")
		return
	_expect_no_route("goal finale before consumed outbound")
	var goal_release := GameState.consume_chapter5_finale_ending_check()
	if not bool(goal_release.get("ok", false)):
		_failures.append("goal finale did not release its canonical ending")
	else:
		_expect_route("goal finale consumed at W240", "gangnam_dream")
		var after_goal := _received_endings.size()
		GameState.check_game_over()
		if _received_endings.size() != after_goal:
			_failures.append("goal finale emitted its canonical ending more than once")

	if not _prepare_chapter5_finale_case(150_000_000.0, 1, 240, true):
		_failures.append("could not build under-goal W240 finale")
		return
	GameState.flags["daeun_romance_started"] = true
	var under_goal_release := GameState.consume_chapter5_finale_ending_check()
	if not bool(under_goal_release.get("ok", false)):
		_failures.append("under-goal finale did not release its canonical ending")
	else:
		_expect_route("under-goal finale consumed at W240", "with_daeun")
		var after_under_goal := _received_endings.size()
		GameState.check_game_over()
		if _received_endings.size() != after_under_goal:
			_failures.append(
				"under-goal finale emitted its canonical ending more than once")

	if not _prepare_chapter5_finale_case(3_200_000_000.0, 0, 239, false):
		_failures.append("could not build pending W239 finale")
	else:
		_expect_no_route("goal finale still pending at W239")

func _check_chapter5_finale_failure_priority() -> void:
	var cases: Array[Dictionary] = [
		{"kind": "health", "value": 0, "ending": "burnout"},
		{"kind": "mental", "value": 0, "ending": "mental_break"},
		{"kind": "money", "value": -150_000_000.0, "ending": "bankruptcy"},
		{"kind": "money", "value": -250_000_000.0, "ending": "debt_spiral"},
		{"kind": "addiction", "value": 90, "ending": "crypto_ghost"},
	]
	for failure_case in cases:
		if not _prepare_chapter5_finale_case(
				3_200_000_000.0, 0, 240, true):
			_failures.append("could not build failure-priority finale fixture")
			return
		GameState.peak_asset = GameState.GANGNAM_TARGET
		match str(failure_case["kind"]):
			"health": GameState.health = int(failure_case["value"])
			"mental": GameState.mental = int(failure_case["value"])
			"money": GameState.money = float(failure_case["value"])
			"addiction": GameState.addiction_tendency = int(failure_case["value"])
		_expect_route(
			"finale immediate %s priority" % failure_case["ending"],
			str(failure_case["ending"]))

func _prepare_case(age_value: int = 38) -> void:
	MetaProgression.data = DataRegistry.default_meta.duplicate(true)
	MetaProgression._new_this_run = {"achievements": []}
	GameState.start_new_game()
	GameState.age = age_value
	GameState.money = 0.0
	GameState.portfolio = {}
	GameState.loans = {"bank": 0.0, "second": 0.0}
	GameState.reputation = 5
	GameState.health = 65
	GameState.mental = 60
	GameState.route_orthodox = 0
	GameState.route_unorthodox = 0
	GameState.investment_skill = 15
	GameState.tendency_realized = ""
	GameState.current_job = {}
	GameState.flags = {}
	GameState.relationships = []

func _set_tier_four_job() -> void:
	GameState.current_job = {"id": "job_08", "name": "route fixture", "tier": 4}
	GameState.flags["max_job_tier"] = 4

func _expect_route(label: String, expected: String) -> void:
	var before := _received_endings.size()
	GameState.check_game_over()
	if _received_endings.size() != before + 1:
		_failures.append("%s emitted %d endings instead of one" % [label, _received_endings.size() - before])
		return
	var actual := _received_endings[-1]
	if actual != expected:
		_failures.append("%s routed to %s instead of %s" % [label, actual, expected])

func _expect_no_route(label: String) -> void:
	var before := _received_endings.size()
	GameState.check_game_over()
	if _received_endings.size() != before:
		_failures.append("%s emitted an ending before the finale" % label)
	if GameState.is_game_over:
		_failures.append("%s marked the run over before the finale" % label)

func _check_startup_before_generic_gangnam() -> void:
	_prepare_case(34)
	GameState.money = 3_200_000_000.0
	GameState.flags["startup_exit"] = true
	_expect_route("startup acquisition", "startup_exit")

func _check_first_year_gangnam_is_instant_legend() -> void:
	_prepare_case(33)
	GameState.turn = 48
	GameState.money = 3_200_000_000.0
	MetaProgression.data["sangchul_truth_ever_known"] = true
	GameState.flags["father_reconciled"] = true
	GameState.flags["cleared_father_debt_from_sangchul"] = true
	_expect_route("first-year 3B arrival", "instant_legend")

func _check_generic_gangnam_waits_for_final_week() -> void:
	_prepare_case(34)
	GameState.turn = 49
	GameState.money = 3_200_000_000.0
	GameState.cast["father"]["affinity"] = 60
	_expect_no_route("ordinary 3B arrival")
	if GameState.peak_asset < GameState.GANGNAM_TARGET:
		_failures.append("ordinary 3B arrival did not persist its peak achievement")
	var goal_snapshot: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(goal_snapshot)
	if GameState.peak_asset < GameState.GANGNAM_TARGET:
		_failures.append("ordinary 3B achievement did not survive serialization")
	GameState.money = 2_500_000_000.0
	_expect_no_route("post-goal asset decline")
	GameState.turn = 240
	GameState.age = 37
	GameState.flags["arc_final_week_seen"] = true
	_expect_route("ordinary 3B finale after decline", "gangnam_dream")

func _check_full_circle_waits_for_final_week() -> void:
	_prepare_case(34)
	GameState.turn = 49
	GameState.money = 3_200_000_000.0
	MetaProgression.data["sangchul_truth_ever_known"] = true
	GameState.flags["father_reconciled"] = true
	GameState.flags["cleared_father_debt_from_sangchul"] = true
	_expect_no_route("full-circle 3B arrival")
	GameState.turn = 240
	GameState.age = 37
	GameState.flags["arc_final_week_seen"] = true
	_expect_route("full-circle finale", "full_circle")

func _check_father_passed_gangnam_is_empty_house() -> void:
	_prepare_case(34)
	GameState.money = 3_200_000_000.0
	GameState.flags["father_passed"] = true
	GameState.flags["father_reconciled"] = true
	GameState.flags["arc_final_week_seen"] = true
	GameState.cast["father"]["affinity"] = 60
	_expect_route("3B arrival after father passed", "empty_house")

func _check_father_passed_blocks_late_call() -> void:
	_prepare_case()
	GameState.flags["father_reconciled"] = true
	GameState.flags["father_passed"] = true
	_expect_route("reconciled father already passed", "ordinary_life")

func _check_daeun_reckoning_blocks_instant_gangnam() -> void:
	_prepare_case(34)
	GameState.money = 3_200_000_000.0
	GameState.flags["daeun_married"] = true
	GameState.flags["used_daeun_as_means"] = true
	GameState.flags["arc_final_week_seen"] = true
	var before := _received_endings.size()
	GameState.check_game_over()
	if _received_endings.size() != before or GameState.is_game_over:
		_failures.append("3B arrival bypassed Daeun's pending final reckoning")
	GameState.flags["arc_daeun_final_choice_seen"] = true
	_expect_route("3B arrival after Daeun reckoning", "gangnam_dream")

func _check_failure_stays_immediate_after_goal() -> void:
	_prepare_case(34)
	GameState.money = 3_200_000_000.0
	GameState.health = 0
	_expect_route("fatal health after 3B arrival", "burnout")
	_prepare_case(34)
	GameState.mental = 0
	_expect_route("fatal mental state", "mental_break")
	_prepare_case(34)
	GameState.money = -150_000_000.0
	_expect_route("bankruptcy threshold", "bankruptcy")
	_prepare_case(34)
	GameState.money = -250_000_000.0
	_expect_route("debt spiral threshold", "debt_spiral")
	_prepare_case(34)
	GameState.addiction_tendency = 90
	_expect_route("addiction threshold", "crypto_ghost")

func _check_committed_investor_before_career() -> void:
	_prepare_case()
	GameState.money = 188_000_000.0
	GameState.investment_skill = 90
	GameState.tendency_realized = "invest"
	GameState.route_orthodox = 5
	GameState.route_unorthodox = 40
	_set_tier_four_job()
	_expect_route("committed investor", "investment_master")

func _check_uncommitted_investor_stays_career() -> void:
	_prepare_case()
	GameState.money = 188_000_000.0
	GameState.investment_skill = 80
	GameState.tendency_realized = "invest"
	GameState.route_orthodox = 5
	GameState.route_unorthodox = 40
	_set_tier_four_job()
	_expect_route("investor below mastery", "career_climber")

func _check_legacy_investment_master_path() -> void:
	_prepare_case()
	GameState.money = 500_000_000.0
	GameState.investment_skill = 55
	GameState.route_unorthodox = 10
	_set_tier_four_job()
	_expect_route("legacy 500M investor", "investment_master")

func _check_orthodox_before_career() -> void:
	_prepare_case()
	GameState.money = 1_000_000_000.0
	GameState.route_orthodox = 40
	GameState.route_unorthodox = 5
	_set_tier_four_job()
	_expect_route("orthodox strategy", "orthodox_pinnacle")

func _check_unorthodox_before_career() -> void:
	_prepare_case()
	GameState.money = 500_000_000.0
	GameState.route_orthodox = 5
	GameState.route_unorthodox = 40
	_set_tier_four_job()
	_expect_route("unorthodox strategy", "unorthodox_legend")

func _check_balanced_before_career() -> void:
	_prepare_case()
	GameState.money = 150_000_000.0
	GameState.route_orthodox = 20
	GameState.route_unorthodox = 18
	_set_tier_four_job()
	_expect_route("balanced strategy", "balanced_life")

func _check_plain_career_fallback() -> void:
	_prepare_case()
	GameState.money = 150_000_000.0
	GameState.route_orthodox = 10
	GameState.route_unorthodox = 0
	_set_tier_four_job()
	_expect_route("plain career", "career_climber")

func _on_game_over(ending_id: String) -> void:
	_received_endings.append(ending_id)
