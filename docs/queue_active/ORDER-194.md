# Active Queue Spec: ORDER-194

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-194 [P0·전체 현지화] 가족·회복·관계의 후속 선택을 옮긴다

**[~] 2026-09-08 Codex 착수 — 20종씩 두 배치, 세 언어 text-only overlay,
원문 결속 검사·수용 기록·증거 문서만 소유한다.**
선언 직전 ORDER193 수용20,790(각6,930)·meta9·batch46을 재확인한다.
공개 working baseline·별도 배경 제품53493fe는 변경하지 않는다.

## 깊이 3문

1. 아버지의 실제 응답, 회복과 재발, 일·돈·관계에 남은 후속을 KO에서 읽는다.
2. 확정된 회신·상환과 조사 중·약속·준비·내적 해석을 구분한다.
3. 신규40종/238leaf를 두 유한 배치로 옮긴다. 기존 송금회고1종6leaf는
   값·순서·raw object prefix를 보존하며 새 수용량에 합산하지 않는다.

## 범위 — A20/118 + B20/120, 총40/238·6,884 KO자

A는 callback13의 기존 `callback_sent_money_instead_echo` 제외14종과
callback14 앞6종이다. B는 callback14 나머지9종과 callback15 전체11종이다.
총79선택(정식 민원만1선택), LF173·{name}0.
known/reader/memory-field/foreshadow/밖표시명 신규0.
전부 shipping·event_standard·protected=false·builtin_overlay_static_only.

A:

- `callback_father_apology_made_echo`
- `callback_father_story_heard_echo`
- `callback_went_home_for_father_echo`
- `callback_delayed_visiting_dad_consequence`
- `callback_told_dad_okay_echo`
- `callback_saw_father_medical_echo`
- `callback_mlm_debt_closed_echo`
- `callback_mlm_refused_echo`
- `callback_addiction_boundary_held_echo`
- `callback_addiction_recovering_echo`
- `callback_health_ignored_twice_consequence`
- `callback_mlm_friend_recovered_echo`
- `callback_jeonse_insurance_saved_echo`
- `callback_jeonse_planning_move_echo`
- `callback_usb_reported_to_company_echo`
- `callback_stayed_clean_echo`
- `callback_was_compromised_consequence`
- `callback_formal_complaint_filed_echo`
- `callback_holdem_regular_echo`
- `callback_holdem_rule_made_echo`

B:

- `callback_holdem_knew_limit_echo`
- `callback_lotto_5th_prize_echo`
- `callback_won_lottery_small_echo`
- `callback_received_orthodox_award_echo`
- `callback_bankrupt_ceo_mentor_echo`
- `callback_mindset_founder_echo`
- `callback_tried_to_withdraw_result`
- `callback_joined_victims_echo`
- `callback_underground_network_member_consequence`
- `callback_jiyeon_apology_made_echo`
- `callback_jiyeon_mentor_track_echo`
- `callback_jiyeon_trust_built_echo`
- `callback_jiyeon_opens_up_echo`
- `callback_jiyeon_referral_met_echo`
- `callback_jiyeon_deflected_business_echo`
- `callback_jiyeon_mother_direct_echo`
- `callback_jiyeon_gratitude_returned_echo`
- `callback_daeun_bond_deepened_echo`
- `callback_daeun_second_date_echo`
- `callback_daeun_honest_echo`

A3,560자/LF89, source aggregate `d2fadf2d407f3bcc6f4c6472c4ba457934e9bef919eeffee6a6e8d11caa6f40d`.
B3,324자/LF84, source aggregate `6a2b7933f7dba41f3f0cb6f2a2b3c257050735adaee25bae8ed9e2431226ff1d`.
합238 `8831e39747bf9ac74b96f1beb201004eff19c7d87a526bbd02a1a999521aaa1b`.

파일13은 신규14/84·2,552자/LF64,
14는15/88·2,539자/LF64, 15는11/66·1,793자/LF45다.
13번은 기존 송금회고를 첫 행에 byte-exact 유지한 뒤 나머지 KO 순서대로 붙인다.
14/15는 새 파일로 원문 전체 순서대로 쓴다. 누락·추가·gameplay 복사0.

## 도달·조건·독자

- DataRegistry 세 파일 등록. 40종의 일반 사건 구조가 실제 노출의 증거는 아니다.
  공개·정적 M07~M60 closure 교집합0이며, 정확ID runtime literal과
  이벤트 간 inbound/outbound0이다.
- director의 bridge allowlist에 정식 민원1종이 있다. min_turn80·현재주거·
  서면 민원flag·단일 선택과 '사실관계 확인 중' 회신을 보존한다.
  EventManager의 조건/제외/후속 검사까지 통과한 실제 플레이를 확약하지 않는다.
- 새flag 생산2위치: addiction_relapsed, health_treated.
  외부 조건reader는 callback_health_treated_followup의 health_treated1곳이다.
  새flag나 독자를 추가하지 않으며 기존 원장/효과는 비소유다.
  addiction_relapsed는 arc_addiction_recovery.json의 description_if_known에도
  읽힌다. 이는 외부 조건reader1 수에 합산하지 않으며 해당 기존 번역은 비소유다.
- 옛 V2 father_first_call의 arc_father_01_call 선택1은
  callback_told_dad_okay_echo를 superseded receipt로 닫을 수 있다.
  DemoCoreLoopV2의 receipt 저장/조회와 EventManager의 제외를 보존한다.
  이 legacy 메타를 신규 제품 장면이나 항상 발생하는 retirement로 해석하지 않는다.

## 파일 소유권

각 locale의 callback_events_13.json·14.json·15.json 아홉 파일만 저작한다.
KO 직접 독립 저작, EN 중역·간번 자동변환0, 전수 교차 L2.
ROOT는 tools/full_game_localization.py·full_game_localization_self_test.py·
zh_translation_audit.py·audit_scope.json, portable 수용원장, 이 사양,
CODEX_QUEUE·L3_PENDING·CLAUDE·WORK_LOG·생성STATUS·전체 현지화 backlog를 소유한다.
오탐은 실물 정상/변조 짝과 원문 경계로만 수리한다.
필요하면 완료191 WORK_LOG절만 기존9/7 history 앞으로 원문 이동한다.
기존 history bytes/끝 개행·기존13번 row bytes를 보존한다.
KO/EN·runtime·save·fonts·routing·공개·human_gates·다른 사건·catalog/endings 비소유.
완료는 같은 큐 이어보기 [~]·L3 OPEN, 전체 번역이나 제품 GO가 아니다.

## 가족·회복의 사실 경계

- 신규 아버지6종 모두 no_flag father_passed다. 사과1개월·이야기2개월·
  급히내려감2개월·미룬방문2개월·괜찮다는말2개월·진료2개월을 섞지 않는다.
  실제 오늘전화/문자·실제응답·한시간 이야기·어머니 전언을 보존한다.
  다음방문 날짜결정은 방문완료0이며 아버지의 침묵을 읽음/동의로 강화0.
  진료 동행분기의 실제 '좋아졌다'와 혼자진료뒤 '괜찮대'를 완치로 바꾸지 않는다.
- 기존 송금회고의 두달반·미정달력·누르지않은통화6leaf는 이미수용되어 비소유다.
- MLM완납1개월뒤 실제채권자연락/감사는 빚추가0, 거절3개월뒤 지인의전액손실과
  사과는 주인공손실0. '그 사람은 잘못없었다'는 원문서술로 유지한다.
  회복친구3개월뒤 선연락·감사/긴이야기는 새완납이나 완전회복0.
- 중독경계2개월뒤 실제이번유지·두번에서세번도가능은 세번째완료0,
  한번쯤이라는 재발분기를 회복으로 미화0. 회복노력2개월은 완치0.
  두번병원연기의 악화/예약후의사발언은 원문시간압축으로 유지한다.
  예약분기의 health_treated와 버틴분기의 일주일뒤 악화를 각각 보존하며, 번역으로 수리0.
- 전세보증보험의 실제대위변제·전액반환은 지우지 않는다.
  다음집보험은 첫할일 메모이지 가입완료0. 몇만원/수억의 대략수량은
  원문그대로이며 보험현실비용을 조언처럼 고치거나 보장하지 않는다.
  이사준비의 실제부동산3군데와 분기별강남쪽/외곽이동은 유지한다.
  effects의200만지출/100만을 새산문금액으로 추가0, 소유발명0.

## 일·도박·법적 후속의 사실 경계

- 회사비리신고2개월뒤 HR실제연락과 해당직원징계는 원문대로.
  정식민원1선택은 조사중 회신·접수번호/담당자뿐이며 징계/승소로 합치지 않는다.
- 깨끗이 버팀3개월의 타인문제 전언은 실제새기회완료0,
  타협2개월뒤 수습시도/완전복구어려움 또는 인정/실제응답은 원문대로.
- 홀덤단골3개월뒤 모르는번호의 실제대회권유는 참가수락0,
  연락처출처 답변은 새동석0. 규칙2개월뒤 실제지나침과 입장후2시간을 구분한다.
  한계1개월뒤 실제칭찬연락/응답에 새게임·치유·도덕점수노출0.
- 5등복권1개월·5천원 당첨 뒤 실제1장/5장 분기를 보존한다.
  '5천원이1천원이익을불렀다'라는 원문수치·인과부채를 재계산/수리0,
  5장전부꽝·5등이추가5장을샀다는 회고를 바꾸지 않는다.
  소액당첨2개월의 기존저축과 소비기억부재는 새상금0.
- 정통적일/표창2개월뒤 팀회의·실제응답은 새승진0,
  파산CEO2개월뒤 실제선연락/한시간대화는 복권·사업성공0.
  창업자사고3개월뒤 회의제안과 팀장질문은 창업/채택완료0.
- 관계탈출2개월뒤 완전탈출/미완전의 각각결과는 원문대로.
  피해자모임2개월뒤 집단소송 진행중은 승소·환급0.
  비공식네트워크2개월뒤 요청거절/떠나기어려움과 한번더수행/끝나지않음을 구분한다.
  effect50만원을 새산문수령으로 만들지 않는다.

## 관계의 사실 경계

- 지연사과2개월뒤 실제선만남제안과 수락후첫만남은 원문대로,
  미룸분기의 '조만간/그래요'는 새일시확정0.
- 멘토3개월뒤 소개인과이어진연락·실제제안1개·지연신뢰평가는 계약/수익0.
  신뢰쌓임뒤 첫속이야기·긴대화·한순간비유는 전면관계회복0.
  마음열림1개월과 실제오빠호칭/상호이야기는 호칭정본을 따른다.
- 소개인2개월뒤 실제다시만남과 바빠서거절/이해를 구분한다.
  사업이야기2개월뒤 듣기/넘기기·지연표정과 '알겠어요'에 계약동의0.
- 어머니직접대화2개월뒤 칭찬은 지연전언이고 전달하겠다는 답은 전달완료0.
  돌아온감사는 실제무언가를해줌이지만 구체선물/돈/호의를 새로발명0.
- 다은관계2개월뒤 실제힘든전화·직접나감과 전화로한시간듣기는 분기별채널이다.
  미실행방문을 추가하지 않고 원문의 실제방문/대답을 지우지도 않는다.
- 두번째단둘만남1개월뒤 세번째제안과 '세번이됐다'는 원문압축을 그대로 옮긴다.
  새장소/일정/만남장면을 보태지 않는다. 일정확인후연락분기의 '됐다'는
  가능해졌다는 뜻이며 새답장·승낙을 발명0.
- 솔직한대화2개월뒤 그날회고와 실제응답은 새연애수락·결혼0.
  원문에 없는 관계guard/직업guard/시간압축은 번역으로 수리하지 않는다.

## 검증

source manifest `edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
callback_events_13.json 18413B SHA `c716e9902885a7f4884a241cc9b6e0b8eacf4dc48457368a76292a44b7cf969e`.
callback_events_14.json 17534B SHA `7520de4c224b1e7b01bf6d03443527895729e3a981b41d33b5a6e4b14710ad24`.
callback_events_15.json 13076B SHA `86f1a5e13fb1606644c1c665f654d6d29f62fc875fdae8ccb3be4c5fce1c45b5`.
13번 기존 JA965B/CN734B/TW755B 단일row6leaf의 지문·raw prefix를 선언 직전 봉인한다.
저작전 initial6 A119/B121행, 신규238previousnull×3.
최종source/response/receipt6쌍·714문구 대조, 기존20,790/meta9/b46 보존.
named full-game-localization-overlays --list 뒤 선택12·EN·diff·전량수용 hash/L1.
실행 stdout만 증거화, 전체audit/Godot/240주0.
전체 INCOMPLETE·full/main/product HOLD·L3/원어민/화면 OPEN.
출시 M01~M06 BUILD2026.08.31.1 사용자 GO 유지.
이 문서는 일회성 범위이며 지속 규칙의 소유자는 I18N_INFRASTRUCTURE/용어집이다.
