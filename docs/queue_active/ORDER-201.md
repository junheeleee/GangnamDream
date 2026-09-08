# Active Queue Spec: ORDER-201

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-201 [P0·전체 현지화] 아버지·관계·목표의 후속을 옮긴다

**[~] 2026-09-08 Codex 착수 — callback36~39의 미수용15종90leaf 한 배치, 세 언어 text-only.**
선언 직전 ORDER200 수용24,810(각8,270)·meta9·batch57를 재확인한다.
공개 working baseline·별도 배경 제품53493fe를 변경하지 않는다.

## 깊이 3문

1. 아버지와의 실제 통화, 헤어진 사람의 회상, 현재 연인의 방문을 구분한다.
2. 원문의 실제 답장·만남은 보존하되 미정 약속·목표를 달성으로 앞당기지 않는다.
3. 36 asked1종·37의6종·38의2종·39의6종만 옮긴다.
   36 기존3종18leaf와 40 이후 사건은 비소유다.

## 범위 — A15/90, 총5,021 KO자

- `callback_asked_father_more_echo`
- `callback_investment_lesson_echo`
- `callback_knows_dad_reason_echo`
- `callback_daeun_daily_life_echo`
- `callback_daeun_breakup_accepted_echo`
- `callback_daeun_breakup_begged_echo`
- `callback_daeun_let_drift_echo`
- `callback_minseo_card_echo`
- `callback_minseo_real_talk_echo`
- `callback_daeun_knows_struggle_echo`
- `callback_daeun_married_echo`
- `callback_daeun_gangnam_first_echo`
- `callback_sangchul_news_father_echo`
- `callback_sangchul_complicated_echo`
- `callback_jiyeon_real_talk_echo`

합30선택·LF207·{name}19. source aggregate
`93a79eabdfdc864e0bc8e5972ba00b2466f35aa7a486b37ab7e98704d57b56f1`.
known/reader/memory-field/foreshadow/밖표시명 신규0.
전부 shipping·event_standard·protected=false·builtin_overlay_static_only.
각 사건2선택. public·정적 M07~M60 closure 교집합0이며 실제 도달 증거가 아니다.

callback_events_36.json: 1종/6leaf·289KO자·LF17·name1,
6913B SHA `0aec7a80bf1777dff9848204d18cb3cf29fdd69ff71803a99668876bb88774ce`.
callback_events_37.json: 6종/36leaf·2145KO자·LF92·name7,
10575B SHA `6bd394ed64881a42d67fde1a5e310df60431b52567798f6c0335bd0453a21ba9`.
callback_events_38.json: 2종/12leaf·614KO자·LF27·name0,
3341B SHA `9c2f17fbb793fcbb9ddf8b5e408b073b253d2d8a8c5734441600b88e4c9b123b`.
callback_events_39.json: 6종/36leaf·1973KO자·LF71·name11,
10279B SHA `0d47c8746ab2667cf43417d98f597c008b74830a1e2e17357f36f9a9bf572195`.

37/38/39의9개 locale파일은 신규다. 36은 기존3행18leaf 뒤에 asked만 append한다.
JA/CN 기존순서 visited→ignored→rushed, TW ignored→visited→rushed를 각각 보존한다.
KO의 순서를 따라 이미 수용된 overlay를 재정렬하지 않는다.
기존36 raw prefix·18leaf·portable 수용기록을 보존한다.
ja 3185B SHA `80ca97ed636224abcf1de48d19caf6902f0b6e5c092f3600b33056ade31b4f09`.
zh-CN 2432B SHA `24d302179c5ab0d2e25063f8d5dfb78efe756630f8325882010fb1b859f42dd5`.
zh-TW 2487B SHA `1c66e9fca1599dd748c9f35d88890b3084730327a419715b95c80fc57464a6e5`.
선언 직전 신규90 미수용·target 부재와 기존36 지문을 재확인한다.

## 도달·조건·독자

- DataRegistry98~101 등록. source incoming5, 전부 deferred이다:
  daeun_05_together→daily_life delay12,
  daeun_05_breaking→breakup_begged delay12,
  daeun_year3_apart 양선택→married delay12,
  daeun_year4_together→gangnam_first delay8,
  invest_guidance→investment_lesson delay16.
  이는 고유 owner→target edge5, occurrence6이다. 신규15에서 나가는 ID edge0.
- director foreground/bridge/fallback/context 명시ID0·runtime 정확ID0.
- 정확 ID literal과 별개로 metadata→일반해석 제외 경로1이 있다.
  demo_core_loop_v2의 father_quiet_call c2는 asked를 supersede하고
  father_health_signal을 replacement_bundle로 기록한다.
  DemoCoreLoopV2의 관계결과 처리가 legacy_callback_resolutions에 영수증을 쓰며,
  legacy_callback_is_superseded의 policy 판정을 EventManager eligibility가 읽어 제외한다.
  그 영수증이 있는 V2 경로에서는 asked가 빠지며 모든 세이브에서 미도달이라고 단정하지 않는다.
- story_rules의 communication coverage_targets에는 asked/news/knows_dad 세 ID 참조도 있다.
  이 목록 참조를 위 source deferred edge나 직접 runtime 호출 수에 합산하지 않는다.
- 출력flag2(contacted_minseo·thought_about_after), 외부 event조건독자0.
  외부 known독자4문구/2root:
  arc_minseo_03_arrival와 arc_minseo_03b_not_arrived의 각 두 변형.
  flag runtime literal0. 외부 문구는 비소유다.
- min_turn: 36 asked24(+no father_passed);
  37 investment28/knows_dad80/daily72/breakup둘56/drift56;
  38 card165/real184; 39 struggle120/married112/gangnam153/news120/complicated120/jiyeon136.
  37 knows_dad는 global flag가 아니라 cast_flag(sangchul,knows_dad_reason).
  39 news에도 no father_passed가 있으며, 나머지에 없는 생사/주거/연애조건은 추가하지 않는다.
  max_turn 없음. 조건 최소값을 '수주/수개월/석 달'과 정확한 시간표로 주장하지 않는다.
- 부모16root(중복setter 포함)와 외부 known4문구를 KO 전량 읽는다.
  arc_daeun_05_together/breaking/uncertain,
  arc_daeun_year3_together/apart/year4_together, arc_daeun_proposal_answer,
  arc_sangchul_01_answer, arc_invest_guidance, arc_father_quiet_call,
  arc_minseo_01_meet/02_real, arc_sangchul_year3/father_passed,
  arc_jiyeon_year3/real_reason.
  부모의 known/memory/orthodox/unorthodox/bridge도 읽되 저작하지 않는다.

## 파일 소유권

각 locale callback_events_36.json~39.json 열두 파일만 저작한다.
KO 직접 독립 저작, EN 중역·간번 자동변환0, 전수 교차 L2.
ROOT는 tools/full_game_localization.py·full_game_localization_self_test.py·
zh_translation_audit.py·audit_scope.json, portable 수용원장, 이 사양,
CODEX_QUEUE·L3_PENDING·CLAUDE·WORK_LOG·생성STATUS·전체 현지화 backlog를 소유한다.
오탐은 실물 정상/변조 짝과 원문 경계로만 수리한다.
필요하면 완료198 WORK_LOG절만 기존9/7 history 앞으로 원문 이동한다.
활성 문서 예산을 넘으면 완료 증거만 queue_archive로 원문 이동하고 링크한다.
기존 history bytes/끝 LF2를 보존하며 이동절+기존HEAD bytes 완전일치를 검사한다.
KO/EN·runtime·save·fonts·routing·공개·human_gates·다른 사건·catalog/endings 비소유.
완료는 같은 큐 이어보기 [~]·L3 OPEN, 전체 번역이나 제품 GO가 아니다.

## 아버지·투자의 사실 경계

- asked는 부모 quiet_call에서 실제로 안부를 더 물어본 선택의 후속이다.
  일요일 저녁 실제 전화, 아버지의 고맙다는 말이 도입에 있다.
  c0는 통화를 끊은 뒤 한동안 아무것도 안 함, c1는 아버지가 조용히 웃으며 응답함이다.
  수화기 너머를 물리적 동석으로 바꾸지 않고, 새 방문이나 치료·완쾌를 만들지 않는다.
  기존36 방문/무시/급행 세 사건의 번역을 수정하지 않는다.
- investment의 부모는 투자 탭을 처음 열고, 감당할 만큼 넣어보기로 한 장면이다.
  echo는 이미 첫 소액을 실제 투자한 뒤다. 시작 단계 차이를 임의 연결 문장으로 메우지 않는다.
  빨간 차트는 색만 그대로 두며 상승/하락을 색에 덧씌우지 않는다.
  떠오르는 상철의 말은 기억이지 현재 상철의 동석/새통화가 아니다.
  c0 기다린 뒤 사흘 만에 본전보다 조금 위, c1 실제 추가투자 뒤 손실이다.
  효과 -5만원을 산문에 새 금액으로 넣거나 큰 성공/파산으로 바꾸지 않는다.
- knows_dad는 밤에 상철에게서 실제 전화가 오고, 아버지에게 보여주고 싶다던 이유를 되묻는다.
  c0 여전히 마음에 있음/c1 잘 모르겠음의 내적 차이다.
  생사 guard 없는 장면에 아버지의 죽음/생존·만남·성공 확정을 추가하지 않는다.
  임상철 정본 표기를 유지하며 아버지와 상철의 관계를 새로 발명하지 않는다.

## 다은·헤어짐·결혼의 사실 경계

- daily_life는 부모에서 연인아님/known에선연인인 차이가 있고,
  현재 echo는 익숙한 방문·달걀 대신 두부·함께 요리하는 생활 장면이다.
  c0 실제로 같이 만든 찌개가 짰지만 둘 다 아니라고 웃음,
  c1 다은이 먼저 잠든 동안 주인공이 차트를 계속 본다.
  방문/현재 방을 혼인·공동소유·전세계약·배우자확정으로 바꾸지 않는다.
- breakup_accepted는 헤어진 지 수주 뒤 포장마차 앞을 지나며 그녀의 잘되길 바랐던 말을 떠올린다.
  잘살아보겠다는 다짐/일부러 먼 길로 돌아감이지 새답장·만남·재결합이 아니다.
- breakup_begged는 '바뀔 수 있다'던 자기 약속과 기다림이 지쳤다는 다은의 말을 회상한다.
  c0 실제로 조금씩 변한 자신/c1 변하지 못한 자신이며 다은의 귀환·재승낙은 없다.
- let_drift는 편의점 직원에게서 다은이 잘지내며 카페에서 일한다는 전언을 듣는다.
  그 자리의 신규취직·다은의 방문/직접발신으로 만들지 않는다.
  c0 나중에 연락할까 생각하지만 지금은 아님, c1 다행이라고 말하고 계산함.
  어느 쪽도 실제로 다은에게 연락하지 않는다.
- knows_struggle는 다은이 실제 들어와 옆에 앉아 오늘 어땠냐고 묻는다.
  처음 힘듦을 털어놓았던 날은 회상이다.
  c0 다은은 잠깐 웃고 말없이 곁에 있음,
  c1 '진짜요?'라며 못믿는 눈빛/익숙해진건지나아진건지 자기불확실성이다.
  회복·용서·고백승낙·동거계약 등 새결과를 만들지 않는다.
- married echo는 몇 달 전 사진 속 웨딩드레스와 웃음을 떠올리며,
  그 사람이 자기 기억 바깥의 삶에 속한 것을 느끼는 장면이다.
  부모 year3_apart에서 다은은 타인의 결혼식 하객이 아니라 사진의 신부다.
  같은 daeun_married flag를 proposal_answer의 주인공 청혼 수락도 쓰는 원문 부채가 있다.
  flag 이름 때문에 이 echo를 주인공과 다은의 혼인/신혼집으로 다시 쓰지 않는다.
  c0 진심으로 잘됐다는 내적수용, c1 좋아요/댓글 없이 휴대폰을 닫음.
  새로운 축하메시지·답장·현재배우자·재결합·정확한배우자신원을 추가하지 않는다.
- gangnam_first는 부모의 실제 답장과 지도핀을 받고 카페에 가자고 약속한 후속이다.
  echo에서 다은은 강남 회사 첫 출근을 마쳤다.
  c0 이번주말 카페에 가자고 하고 실제 함께 간 강남 카페 결과가 있다.
  원문에 있는 실제 만남을 일반경로의 무응답 조건으로 지우지 않는다.
  c1 '나도 곧 갈거야'/다은의 '알아요', 아직 약속을 지킬 날은 미래다.
  주인공의 강남 취직·이사·아파트소유로 바꾸지 않는다.
  '여기서 커피를 마시는 건 처음'에 강남 모든 카페 평생최초를 덧붙이지 않는다.

## 민서·상철·지연의 사실 경계

- minseo_card는 민서의 명함을 받아 몇 달(결과 석 달) 두었다가 꺼낸다.
  c0 실제 문자와 민서의 빠른 실제 답장 '언제 한번 봐요'가 원문에 있다.
  만남 제안은 있지만 날짜/시간/장소 확정·현재동석·만남성사는 없다.
  c1 다시 지갑에 넣고 미룸이며 발신·읽음·응답이 생기지 않는다.
  원문의 민서 아파트 보유를 주인공 소유로 바꾸지 않는다.
- minseo_real_talk는 과거 카페에서 들은 목표 이후의 말/표정을 혼자 떠올린다.
  30억은 도달했을 때를 상상한 조건문이지 현재잔액·자산획득이 아니다.
  c0 강남 이후를 생각함, c1 아직은도달먼저지만 말이사라지지않음.
  새민서통화/동석·30억상실·계약·주소이전은 없다.
- news_father는 살아있는 아버지와 일요일 저녁 실제통화다.
  예전 상철기사를 알린 통화를 아버지가 먼저 꺼낸다.
  c0 나쁜사람에게도배울것있다는응답, c1 이미지난일이라며화제전환.
  뉴스 언급을 판결·유죄확정·수감·배상·새고소완료로 증폭하지 않는다.
- complicated는 상철 덕을 본 것과 아버지를 힘들게 한 것이 동시에 사실이라는 내적정리다.
  원문 '두 가지'의 숫자와 둘 다 인정/아직시간필요를 보존한다.
  같은 flag는 father_passed 부모도 쓰므로 생사·통화·사과·용서완료를 덧붙이지 않는다.
- jiyeon_real_talk는 실제 카카오톡 수신, 신촌 골목의 대화를 떠올림이다.
  c0 실제 솔직답장 뒤 지연의 이모티콘 하나,
  c1 아직찾는중이라는 실제답장 뒤 지연의 실제응답이 있다.
  깊지는않지만 방향을아는관계/아직포기아님의 차이를 유지한다.
  두 setter 부모는 각각 장기간 뒤 문자대화와 시험준비 카페대면이다.
  그 차이를 새 골목만남·데이트·연애성사·시험합격으로 봉합하지 않는다.

## 검증

source manifest `edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
저작전 initial3 A91행, 신규90previousnull×3.
최종source/response/receipt3쌍·270문구 대조, 기존24,810/meta9/b57 보존.
check/import는 source JSONL을 --batch, 언어를 --locale로 명시한다(--source 없음).
named full-game-localization-overlays --list 뒤 선택12·EN·diff·전량수용 hash/L1.
실행 stdout만 증거화, 전체audit/Godot/240주0.
전체 INCOMPLETE·full/main/product HOLD·L3/원어민/화면 OPEN.
출시 M01~M06 BUILD2026.08.31.1 사용자 GO 유지.
이 문서는 일회성 범위이며 지속 규칙의 소유자는 I18N_INFRASTRUCTURE/용어집이다.
