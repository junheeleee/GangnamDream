# Active Queue Spec: ORDER-180

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-180 [P0·전체 현지화] 아버지·직장 인연·연애의 일상선을 옮긴다

**[~] 2026-09-08 Codex 착수 — 아래25 ID의 세 언어 text-only overlay,
원문 결속 검사·수용 기록·증거 문서만 소유한다.**
직전13,839번역(언어별4,613)·메타9·batch31과 공개 working baseline·
별도 배경 제품53493fe를 착수 직전 재확인해 보존한다. 사용자의 전체 게임 번역 지시를 이어간다.

## 깊이 3문

1. 아버지의 방문·직장 인연·연애의 작은 선택도 다른 언어에서 같은 인과를 남겨야 한다.
2. 생사·관계·돈·통화·방문·첫 만남과 도달성 조건은 변경0이다.
3. 남은 사건·UI·소비자와 경쟁하므로25단위 한 배치에 한정한다.

## 배치 A — 아버지·인연25 roots /172 leaf /8,301 KO자

전부 `content/events/life_events.json`의 다음25개다. 아래는 KO 상대순서다.

- `father_wedding_call`
- `family_002`
- `family_013`
- `family_024`
- `romance_034`
- `family_035`
- `romance_045`
- `sangchul_meet`
- `sangchul_amb_call`
- `sangchul_amb_lunch`
- `father_missed_chance`
- `father_health_call`
- `father_first_visit`
- `father_reconcile`
- `survival_friend_sns`
- `romance_blind_date`
- `romance_coworker_tension`
- `romance_ex_message`
- `romance_dating_app`
- `comedy_umchinah`
- `late_night_driver`
- `old_colleague_gangnam`
- `business_card_first`
- `hometown_friend_ask`
- `seoul_five_years`

source aggregate
`00aae652e0e8a3688c60ce3fa62a87c7c9dbd4a41266d4defc4d7f0a13258cfe`.
제목25+본문25+61선택/결과122=172. known/memory/reader/foreshadow/밖name0.
전부 shipping·protected=false·builtin_overlay_static_only다.
대상3언어 target/accepted0과 직전179 교집합0을 선언 직전 확인한다.

명시 foreground/bridge/fallback0, autoloads/systems/scenes의 대상 literal0,
전체 KO 사건의 직접 follow_up_event 유입/비어 있지 않은 유출0이다.
event_director.context_requirements의 romance_034 has_job,
romance_045 active_romance와 introduction_events의 sangchul_meet는 별개다.
active_romance는 시작/미이별을 확인하며6개월 지속을 보증하지 않는다.
father_wedding_call의 requires_living_father와 아버지4종의 father_passed
배제는 EventManager가 소비한다. 정적 확인은 전체 비도달·플레이 GO가 아니다.
24회/16종 flag write의 밖 condition 독자11종은 callback8 및
parents_bankbook/sangchul_why_gangnam/father_hospital_wait3이다.
father_reconciled와 sangchul_met의 runtime 소비도 새 번역 범위가 아니다.

## 파일 소유권

각 `content/events_<ja|zh-CN|zh-TW>/life_events.json`에 위25행만 추가한다.
기존 값·raw row·행 상대순서·source/target hash를 유지하고 새25행 내부의
KO 상대순서를 따른다. 기존 배열 전체 재정렬0, gameplay key 복사0.
KO 직접 저작과 다른 작성자/ROOT의 전수 L2. 영어 중역·간번 자동변환0.
문단·토큰·수량·인물/사실 경계를 보존한다.

ROOT는 full_game_localization.py·full_game_localization_self_test.py·
zh_translation_audit.py·audit_scope.json, content/meta/full_game_localization.json,
이 사양·CODEX_QUEUE·CODEX_QUEUE_L3_PENDING·CLAUDE·WORK_LOG·생성STATUS·
전체 현지화 backlog를 소유한다. 필요하면 완료177 WORK_LOG절만 기존9/7
현지화 history 앞으로 원문 이동하고 기존 내용·끝 개행도 보존한다.
실제 번역에서 재현한 검사 오탐만 좁은 문맥과 정상/변조 짝으로 수리한다.
KO/EN·runtime·save·routing·human_gates·life_events2·catalog/endings·공개·
폰트·배포 비소유다. 수용 후 같은 활성 이어보기로 옮기되 [~]·L3 OPEN 유지.

## 원문 사실·부채 경계

- family_024의 형(언니) 템플릿을 번역자가 한 성별로 고정하지 않는다.
  '왔니' 두 글자와 '잘 지내?' 세 글자의 원문 수를 번역 대사 문자수로
  임의 수리하지 않는다. 정상 괄호2쌍·SNS emoticon1과 {name}13 leaf/14회를 보존한다.
- family_013은 한도 조회 선택 뒤 실제 대출/전액 지원이 명시된 압축이다.
  실제10만원/50만원 대여·가족 답장도 유지하며 산문에 없는 효과 수치를 덧쓰지 않는다.
- 아버지의 실제 KTX 귀향·병원 방문·10분 통화·복약 고백·삼치구이/된장찌개와
  못 간 방문의 '최적' 역설을 보존한다. 첫 고백이라 부르는 회수와 앞 탐욕 고백의
  관계는 별도 source 확인점이다. 새 통화·방문·생사를 발명하지 않는다.
- 연애6개월 산문과 active_romance 조건은 다른 보증이다. 소개팅/앱의 고정33세,
  seoul_five_years의5년 산문↔min_turn220·새집은 별도 기간/주거 확인점이다.
  business_card_first의 '몇 해 전'은 회상이며 게임 경과 연수로 확정하지 않는다.
- 전연인 질문 뒤 약1시간 카페 만남은 source 실제 성사다. 매칭 앱의 성공은
  매칭이지 만남이 아니며 동료 점심 요청은 상대의 당황까지만 있다.
  hometown_friend_ask의 메시지→통화 종료는 원문 압축으로 남긴다.
- 상철50대·OO동·30년 국밥에 고기 종류를 발명하지 않는다. 민수는 민준이
  아니며 고3/학급 꼴등·큰어머니/고모 관계를 지역의 다른 친족으로 바꾸지 않는다.
  대리기사 서비스도 택시로 치환하지 않는다. 현재 용어집에 없는 표기는 KO에서
  직접 옮기고 정당한 표기의 검사 오탐만 문맥에 결속한다.
- 이미 인사한 옛 동료를 못 본 척하는 선택, 서울5년의 양립 감정,
  family_035의 산문에 없는 돈 효과는 번역에서 재연출하지 않는다.
  약50m·밤1시·5초 기회·10회가량 읽기·SNS 진심이0%는 아님을 의미 대조한다.

## 검증

원문 manifest
`edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
초기source3 보존, 최종source/response/receipt3쌍과516문구 독립 KO 대조.
named full-game-localization-overlays를 --list로 확인 후 실행, EN·diff와
portable 전량 source/hash를 검사한다. 전체 INCOMPLETE·full/main/product HOLD,
L3/원어민/화면 OPEN·출시 M01~M06 BUILD2026.08.31.1 사용자 GO 유지.

이 범위·배치·증거 절차는 일회성이다. 지속 규칙은 I18N_INFRASTRUCTURE와
언어별 용어집이 소유하며 새 서사·제품·출시 규칙을 만들지 않는다.
