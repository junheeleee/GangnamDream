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

## 번역 결과 — L1/L2 수용·L3 OPEN

- 선언 `c27d5259f10e3990699b42e31618e1e48aeb0ff9` 뒤25 roots/172 leaf씩을
  KO 직접 저작했다. 세 언어516문구를 다른 작성자 또는 ROOT가 전수 대조했다.
  JA 독립 필수 수정0. CN/TW 각각 family_024의 '弟妹'4문구는 동생의 아내로
  오독하지 않도록 성별 대안/손아래 형제자매/대명사로 명료화했다. SNS 역 앞의
  원문에 없는 서 있는 자세1문구씩도 덜고 변경5곳씩 재대조했다.
- 초기173행 source3개는 저작 전 target=null과 같은 원문172를 보존한다.
  최종 source/response check·import --accept3개 PASS·changed_files0.
  기존 private 증거를 덮지 않고 작성된 target을 수용했다.
- 최종172-record aggregate JA
  `7be8645773bb6433864337f40be9d5ba30914264b1a8c72b99d28326cd8a2cec`,
  CN `f7ed31641e0cf6fdd34668a47165121e5d1da9db16a13f92888eb23a7765b9e0`,
  TW `3c8b841e57cddb529d4c66da725d80a32331717f52289e74377722acc915433b`.
  신규516·누적14,355(언어별4,785), 사건478종3,717/locale다.
  이전13,839/meta9·batch31·기존79행589문구의 값·raw row·상대순서를 보존했다.
  새25행 내부는 KO 상대순서이며 life_events2 전체는 변경0이다.
- 실제 Minsu 원문 이름과 '스스로에게 한 약속'의 관형어 오탐만 문맥에
  결속했다. 원문 다른 이름/식별자 차용과 진짜 하나/둘 수량은 별개다.
  독립20반례 PASS, full-game self174는 기존172+신규2다.
- ZH 고3 학년·옆자리50대 인물·아버지 방문 문의·둘 중 하나의 진실을
  각 원문/목표 문맥과 불일치 증인에 결속했다. 단순 전역 숫자 면제0.
  독립 검토에서 새 방문 문의의 沒/没 부정과 진실 대안의 앞 부정문을
  뒤 정상문이 덮는2유형을 발견해 닫았다. 정상2/변조2 재확인 PASS,
  ZH self3363는 기존3319+새40+종결4다. 자동 검사는 전 언어 의미 인증이 아니다.
- 완료177절1,379bytes만 기존 history26,549bytes 앞으로 원문 이동했다.
  새27,928bytes SHA `3ab83abf5ee6ecb9bb32fd0acd4e59d90e721b1bab6c668a1d74e9c51ce7dff9`,
  기존 내용·끝 LF2를 유지한다. 검수행은 같은 활성 이어보기로만 이동한다.
- 실제 대출·대여·답장·KTX 귀향/병원 방문/통화·전연인 만남은 원문 사실대로다.
  동료 점심 요청은 수락하지 않았고 앱 매칭은 실제 만남이 아니다.
  선언의 성별·원문 글자수·친족·생사·기간/주거·선택 재진입 부채는 별도 남겼다.
  KO/EN·runtime·공개·fonts·save·human_gates 변경0, 원본 checkout 쓰기0.
  full/main/product HOLD·전체 INCOMPLETE·L3/원어민/화면 OPEN·출시 데모 GO 유지.

- portable checksum `2d6053992dfdcb61ce15e3cbe840340b3b2edea7e38b9df0a08c49ef2dbd825e`.

- 최종 named12 실제 PASS: full self174/ZH self3363, audit ERROR0/WARNING0,
  공개14사건100 leaf/121 UI·5언어 exact 유지. EN1813/1813·35/35와
  한글 잔류 검사, 전14,355 source/target hash·L1 오류0, diff PASS다.
  원시 stdout private `order180-final-checks.log` 4225bytes,
  SHA `dde0db6ff449c2f83f627c006f3fcfac8a5d171008f87fb721948b692aeb5f87`를 byte-exact 확인했다.
  context boot29,187/docs282/links80, queue43/in_progress41, 등록139다.
  Chinese full-route JP-first blocked는 남은 별도 화면/폰트 게이트이며 PASS로 닫지 않는다.
