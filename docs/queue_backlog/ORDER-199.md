# Active Queue Spec: ORDER-199

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-199 [P0·전체 현지화] 어머니·일·살림의 중간 회수를 옮긴다

**[~] 2026-09-08 Codex 착수 — 20종 한 배치, 세 언어 text-only overlay,
원문 결속 검사·수용 기록·증거 문서만 소유한다.**
선언 직전 ORDER198 수용24,186(각8,062)·meta9·batch55를 재확인한다.
공개 working baseline·별도 배경 제품53493fe는 변경하지 않는다.

## 깊이 3문

1. 작은 선택의 뒤끝과 어머니·직장·가족·노후·자기 기준을 KO에서 직접 읽는다.
2. 이미 한 행동과 아직 모르는 결과, 통화와 동석, 요청과 승인을 구분한다.
3. callback27~31 전체20종116leaf 한 배치만 옮긴다. 파일32 이후는 비소유다.
   부모의 미클릭/방 미공개와 회고의 완료/재방문 차이는 번역으로 수리하지 않는다.

## 범위 — A20/116, 총5,451 KO자

- `callback_parttime_survived`
- `callback_budget_check_in`
- `callback_mid_goal_echo`
- `callback_quiet_money_patience`
- `callback_early_greed_humbled`
- `callback_gosiwon_wall_echo`
- `callback_stayed_grounded_echo`
- `mother_call_compare`
- `mother_seoul_visit`
- `mother_reconcile_moment`
- `callback_child_cost_grind`
- `callback_pension_self_fund`
- `callback_parent_first_money`
- `callback_own_path_confirmed`
- `callback_midnight_echo`
- `callback_vision_midcheck`
- `callback_gangnam_standard_held`
- `callback_credit_theft_again`
- `callback_salary_negotiation_result`
- `callback_job_change_outcome`

합38선택·LF170·{name}6, source aggregate
`75c086e616b8e2584b0ec2810aac474b490d22a2e414b5840dc40d973c40f88d`.
known/reader/memory-field/foreshadow/밖표시명 신규0.
전부 shipping·event_standard·protected=false·builtin_overlay_static_only.
두 bridge 사건(child_cost_grind·pension_self_fund)은 선택1개, 나머지는2개다. source 전체 상대순서 그대로다.
공개·정적 M07~M60 closure 교집합0이며 실플레이 도달 증거가 아니다.

callback_events_27.json: 7종/42문구·1654KO자·LF38·name0,
10000B SHA `4a5a26752558c957e21a3d6018a9eff2bba29fda75684d5447cf2d4863cc030e`.
callback_events_28.json: 3종/18문구·898KO자·LF56·name6,
4222B SHA `e9bca87344ad353021f4a377e2c88f3938b3a7fa445d2e28de1020c951ac184a`.
callback_events_29.json: 4종/20문구·1032KO자·LF28·name0,
5177B SHA `da38750869177a358dc418ccea8240cc4fc35e26289d4b90800175f1684d9818`.
callback_events_30.json: 3종/18문구·942KO자·LF24·name0,
4148B SHA `069f8690af899697d452a1642355d6cb25659c9080b326a06565ee0c35c85371`.
callback_events_31.json: 3종/18문구·925KO자·LF24·name0,
4664B SHA `3da2e7593176e5723be85bfe99f7684b35ef8703dd6a9c41d8d6a368f2194f73`.

각 locale 다섯 파일 모두 신규다. 선언 직전15파일 부재와 신규116 미수용을 재검사한다.
누락·추가·gameplay 복사0, JA·간체·번체는 KO에서 각각 독립 저작한다.

## 도달·조건·독자

- DataRegistry89~93 등록, 정확ID runtime literal0, source 즉시/지연 edges0.
- director bridge는 child_cost_grind와 pension_self_fund만 각1참조다.
  foreground/fallback 참조0. 두1선택 bridge의 편성과 실제 도달은 이 번역의 검증범위 밖이다.
- 새flag는15위치14unique다. 내부 조건독자2:
  mother_visited_alone→mother_reconcile_moment,
  job_change_trigger→callback_job_change_outcome.
- 외부 event조건독자0, 외부 known독자3:
  daytime_conviction→arc_36_night_doubt 및 father_passed 변형,
  vision_revised→arc_37_reckoning. 기존 reader문구는 비소유다.
- runtime flag독자는 GameState4447 job_changed_success→career_climber,
  4461 job_change_trigger→career_burnout; MainGame22077의
  mother_reconciled/reconnected 회고문이다. 실제 엔딩/회고 연출을 자동 PASS로 세지 않는다.
- callback27 min/max는 KO순서14–22/13–20/15–22/16–24/14–24/14–22/16–24.
  28 min8/30/100, visit만 gosiwon+no father_passed.
  29 min50/40/60/48, first_money만 min_money500000+no father_passed.
  30 min28/100/44, 31 min44/36/52 모두 has_job.
  다른 장면에 빠진 직업·주거·생존·관계조건을 번역으로 보충하지 않는다.

## 파일 소유권

각 locale callback_events_27.json~31.json 열다섯 파일만 저작한다.
KO 직접 독립 저작, EN 중역·간번 자동변환0, 전수 교차 L2.
ROOT는 tools/full_game_localization.py·full_game_localization_self_test.py·
zh_translation_audit.py·audit_scope.json, portable 수용원장, 이 사양,
CODEX_QUEUE·L3_PENDING·CLAUDE·WORK_LOG·생성STATUS·전체 현지화 backlog를 소유한다.
오탐은 실물 정상/변조 짝과 원문 경계로만 수리한다.
필요하면 완료196 WORK_LOG절만 기존9/7 history 앞으로 원문 이동한다.
활성 문서 예산을 넘으면 완료 증거만 queue_archive로 원문 이동하고 링크한다.
기존 history bytes/끝 개행을 보존한다.
apply_patch 이동 뒤 끝 LF가 하나 줄 수 있으므로, 이동절+기존HEAD bytes의 완전일치를 검사하고 부족한 개행만 복구한다.
KO/EN·runtime·save·fonts·routing·공개·human_gates·다른 사건·catalog/endings 비소유.
완료는 같은 큐 이어보기 [~]·L3 OPEN, 전체 번역이나 제품 GO가 아니다.

## 초기 선택의 사실 경계와 부모 부채

- parttime_survived는33세가을·잔액30만원미만일 때 봤던 공고와 결국안한과거,
  지금여기있음이다. 선택의자기확신/판단유보를 실제채용·소득으로 만들지 않는다.
  parent arc_money_check_low는 공고3개저장/내일지원계획까지만이다.
  그 뒤 결국 알바를 하지 않음·가을·잔액조건은 echo의추가회고이며 새연결을 발명하지 않는다.
- budget은 실제노트검토 뒤 대체로지킴/많이벗어남의 선택이다.
  계획과 실제숫자차이를 새월수입·저축액으로 특정하지 않는다.
- mid_goal은 목표기록의 회수이며 목표상향/현재속도유지다.
  도달했든못했든이라는 불확정을 달성확정이나 새거래로 바꾸지 않는다.
- quiet_money는 아직동료·가족·현수모두모름, c1언젠가말하고싶지만아직아님이다.
  실제고백·전송·축하/회신은 없다.
- early_greed는 반대방향시장후 c0실제매도/손실확정/두번째수업,
  c1실제보유/상승하락가능성/매일화면습관이다. 효과50만원을 새손실액으로 추가하지 않는다.
  parent arc_money_check_high는 큰주문금액입력·확인미클릭까지다.
  echo의 실제보유·매도와 두번째수업을 맞추려고 거래완료·새과거를 넣지 않는다.
- wall은 떠난이웃·짐빠진방·이름도모름이다. c0약1초섬/자기방귀환,
  c1언젠가자신도짐쌀생각이다. 실제이사/다음집소유·연락처를 만들지 않는다.
  parent arc_gosiwon_wall의두드림·작은네답변이 초면관계를 넘어가지 않는다.
- stayed_grounded는 과거판단이 토대였을수도아닐수도라는 회고,
  c0자만안함의자기평가/c1운의역할이다. 실제수익보장이나새성공이 아니다.

## 어머니·가족·노후의 사실 경계

- mother_call_compare는 실제전화, 수원정씨딸의공무원취업·결혼예정은 어머니전언이다.
  {name}은그딸을모르고어머니도잘모를것이라는추측을 확정지식으로 만들지 않는다.
  두선택의실제답변·끝까지들음은 보존하고 새대면·확정경력을 넣지 않는다.
- mother_seoul_visit는 어머니혼자실제방문, 아버지는일있다고말함이다.
  c0두시간청소·어머니가반찬남기고감, c1삼겹살집실제식사/어머니가고기구움이다.
  냉장고넣으라는말을 이미넣음으로, 음식유사집밥감정을 다른요리로 바꾸지 않는다.
  parent arc_34_parents_visit는 hid_room/showed_room양쪽에서
  arc_34_parents_visited를 세운다. echo의'다시방봄/저번과같음' 전제는
  방을안보여준부모선택과 어긋나는 원문부채다. 방공개조건이나가상방문을 추가하지 않는다.
- mother_reconcile_moment는전화이며한강배경이 실제동석의증거가아니다.
  c0믿는다는말뒤눈따가움/피곤해서일것이라는절제,
  c1별내용없는긴통화의필요함을 보존한다. 만남·송금·가족합의추가0.
- child_cost는 언젠가육아계획의3억2천만원=KRW320000000 회고다.
  실제아이출생·배우자·이미부모됨·육아지출확정0.
- pension은 월급들어옴/이번달10%분리, 처음10만원→이번20만원이다.
  국민연금없다고생각하는태도를 제도폐지·실제수급불가확정으로 덧칠하지 않는다.
  새은행상품·송금계좌·저축성공금액·일본/중국연금으로 바꾸지 않는다.
- parent_first_money는 도입이미송금/아버지실제전화인데
  c1통장보고다음달미룸으로 돌아가는 원문분기부채가 있다.
  c0당연하다는말/통화종료·시작감정과 c1아직미룸/기다릴시간불확실을 각각보존한다.
  앞송금회수·두번째송금·전화부활을 만들어모순을 잇지 않는다.
  효과30만원을 산문에새로넣지 않는다. no father_passed가 살아있는전화의조건이다.
- own_path는 친구돌잔치뒤지하철회고다. 좋아보임/원함의차이,
  c1조금부러움인정이 같은길선택·새결혼결심은 아니다.
  parent anxiety_friend_baby의카톡→전화종료압축과 생애시점은 새연결을 넣지 않는다.

## 자기 기준·직장의 사실 경계

- midnight는새벽3시확신을낮직장에서되묻는다. 직장조건없는것은 KO부채다.
  c0낮에도같음/c1흔들림인정과인식의노력이며 새승진/수익확정0.
- vision은38세30억원·5년대략절반의중간확인이다.
  min_turn100은정확2년반증거가아니다. c0방향맞음/c1실제수정의차이를 유지한다.
- gangnam_standard는고시원또는작은원룸의대안적서술이며 현재주거확정이 아니다.
  기준내면화/강남자체욕망인정은입주·소유·목표달성이 아니다.
- credit_theft는기획공로를팀장이또가져간것이다. 신용카드/금전절도로 바꾸지 않는다.
  c0날짜·메일·초안의 실제인사팀면담, c1인사팀안감/이력서열기다.
  면담을징계/배상확정으로, 이력서열기를새회사취업으로 바꾸지 않는다.
- salary_result c0는요구금액의70% 수준인 실제인상이다.
  연봉70%인상이나요구전액·효과20만원을 추가하지 않는다.
  c1지금어렵다는실제거부/다음다른회사에서시작할생각이며 계약확정0.
- job_change는이미이력서수정·지원·면접후 c0새회사첫달/c1결국같은자리다.
  두선택을동일완료/미완료로평탄화하지 않는다.
  이직의정서적단단함과두려움인정은새연봉·승진·약속확정이 아니다.

## 검증

source manifest `edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
저작전 initial3 A117행, 신규116previousnull×3.
최종source/response/receipt3쌍·348문구 대조, 기존24,186/meta9/b55 보존.
named full-game-localization-overlays --list 뒤 선택12·EN·diff·전량수용 hash/L1.
실행 stdout만 증거화, 전체audit/Godot/240주0.
전체 INCOMPLETE·full/main/product HOLD·L3/원어민/화면 OPEN.
출시 M01~M06 BUILD2026.08.31.1 사용자 GO 유지.
이 문서는 일회성 범위이며 지속 규칙의 소유자는 I18N_INFRASTRUCTURE/용어집이다.

## 수용 결과 — 348번역·L1/L2, L3 OPEN

- 선언 `c7d969aa67ce0a189ac3a775257d58be0e565e4e` push 뒤 initial3
  A117행·신규116 previous null×3를 저작 전에 봉인했다.
  KO 직접 독립 저작 후 다른 작성자/ROOT가348문구 전부를 대조했다.
- callback27~31 신규20종116leaf씩,15개 text-only 파일을 더했다.
  기존24,186/meta9/b55 보존, 누적24,534(각8,178)·b56이다.
  언어별 events1,016종7,110·endings234·catalog834다.
- 독립 L2 필수0, 정밀3: CN 목소리를울먹임으로 특정한표현1·반찬통복수1,
  TW 방의짐이빽빽했다는 강도1을 줄였다. 지정3 교차검토와
  전체15파일/records 역치환으로 JA116/CN114/TW115 나머지 불변을 확인했다.
- ZH 실물4오탐(두언어의第二堂课/課·Jeong)을 source 결속으로 수리했다.
  독립검토가 찾은 괄호없는성씨별칭4를 추가로 닫았다. ZH self6548 PASS,
  독립 고정86(정상8·target60·source18) 전부와 별도붙여쓰기4도 PASS다.
  숫자는 numeric-only, 이름은 terminology+Latin으로 확인했다.
  독립86 SHA `549e6c3e78e3d6c6caa25c1a2a90f5509e8703c3fba81325a439e69a93bf02ba`.
  무수량 의미·원어민·화면 검수나 다른장면 전체인증은 아니다.
- 최종 source/response/receipt3쌍·실물348 L1 오류0,
  check/import --accept3 changed_files0. 최종116 records:
  JA `baa91fc7a5d656396030b3797c4df5a0705646ef1c0b9db2685ce99a2febb516`,
  CN `52d468286333ecb429baa00091a90c540e2e01bd82b4bb89a9b216886c56d19c`,
  TW `32427d60ee207dc84749215533af34ae95b389f7f3b87fe0d88cd9bc8def61e2`.
- 완료196 WORK_LOG절1,107B만 history 앞으로 원문 이동했다.
  49,325→50,432B SHA
  `dbd71dca479e99ab9838889809f24a7fef763bf843338c978b287b8d72035821`.
  기존 bytes·끝 LF2 유지, 같은 활성 이어보기 [~]·L3 OPEN이다.
- 통화/방문·계획/이직·요구액70%·미래양육/현재자녀를 구분했다.
  매도전 주문미확인·어머니재방문·송금뒤미룸 등 KO부채는 번역으로 잇지 않았다.
  KO/EN·runtime·공개·fonts·save·human_gates 변경0, 원본 checkout 쓰기0.
  전체 INCOMPLETE·full/main/product HOLD·원어민/화면 OPEN·출시 데모 GO 유지.
- portable checksum `8653b04c90c646e8019246e3d014a52b789eccc57c461627be1448f91a1e7774`.

### 최종 표적 회귀

named lane --list 후 선택12 PASS: source inventory52·full self204·JA69·
ZH6548·공개 구조4변이, audit ERROR0/WARNING0, EN1,813/1,813+35/35,
JA/CN/TW skeleton1,030사건을 확인했다. 공개14사건/100문구/121UI·5언어 exact,
context302문서·queue62행·diff whitespace0도 정상이다.
이 수치는 전체 번역·JP-first글꼴·원어민/화면의 완료 증거가 아니다.
전량24,534 source/target/hash/L1, 기존24,186/meta9/b55 보존 검사 PASS.
독립 인수는 한국어5+overlay15+private12+portable1+human1의34입력을 동결해
초기/최종/receipt/현재번역/새수용348과 기존원장을 대조했다(추가L1실행0).
입력 SHA `ff330978bab10c45b8366fcddd82ee3e778d431acc7f6bdd5cb0456d0cdbc1e8`.
실행 stdout `order199-final-checks.log` 4,425B SHA
`1c60960140a0dd0e0d2a8995c386270007324aad00d458f05c2ce0f13afb9c07`.
원어민/화면/L3 OPEN, 전체 INCOMPLETE·HOLD·출시 데모 사용자 GO 유지.
