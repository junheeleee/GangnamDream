# Active Queue Spec: ORDER-302

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-302 [P0·출시 데모] 체험판 M01~M06 대본의 사실 충돌과 영어 오역을 고친다

**2026-09-26 Claude 발행 · 사용자 승인.** Claude가 공개 데모 `story_demo_rc`의
실제 노출 장면 11개(KO/EN)와 셸 문구를 읽고 찾은 결함이다. 외부 플레이테스트
전에 닫는다. 산문을 새로 쓰는 작업이 아니라 사실·용어·문법 정합 수리다.

## 깊이 3문

1. **왜 지금인가?** 외부 테스터가 가장 먼저 읽는 구간이다. 직업·월세·장소가
   화면마다 다르면 "무슨 게임인가"보다 "설정이 틀렸다"가 먼저 기억된다.
2. **무엇을 바꾸지 않는가?** gameplay key, 선택 수, 효과, 이벤트 ID, 장면 순서,
   경제 수치는 바꾸지 않는다. 아래 2번도 텍스트만으로 닫는다.
3. **GO는 어떻게 되는가?** 공개 데모 GO는 exact identity(BUILD `2026.08.31.1`)에
   묶여 있다. 이 수리는 새 데모 후보를 만들며 GO를 물려받지 않는다
   (`MASTER_RELEASE_AUDIT.md` Gate C). 수리 뒤 새 후보로 재판정한다.

## 수리 목록

| # | 위치 | 결함 | 수리 방향 |
|---:|---|---|---|
| 1 | `playtests/order124/StoryChoiceM1M6Playtest.gd` 시작 화면 `baseline_text`(공개 분기) | "편의점 야간 수입"이 자동이라고 적혀 있으나 M01은 야간 상하차, M03은 민준이 편의점 손님으로 다은(야간 직원)을 처음 만난다. | "야간 단기 일 수입"처럼 직업을 특정하지 않는 문구로 KO/EN을 함께 바꾼다. |
| 2 | `arc_temptation_01`(월세 65만원) ↔ `arc_sangchul_01_meet`(원룸 보증금 1000·월 55) | 고시원 월세가 원룸 월세보다 비싸 "왜 고시원에 사는가"가 생긴다. | 경제 수치는 두고 상철 대사의 원룸 조건만 월세 65만원 이상(예: "보증금 천에 월 칠십")으로 바꾼다. KO/EN/JA/zh 동일 수치. |
| 3 | 같은 파일 M06 `intro_template` | "3월, 버스 정류장에서 — %s"인데 실제 지연 장면은 신촌 이면도로 자전거 사고다. | "3월, 빗길에서"처럼 실제 장소로 KO/EN을 맞춘다. |
| 4 | `content/events_en/arc_events.json` `arc_jaehyuk_01_reunion` | "You'll be in touch"(원문 "내가 연락할게"), "Why now, why you"(원문 "나한테"), 3인칭 서술 속 "our whole service". | "I'll be in touch.", "Why now—why me?", "through their whole service". |
| 5 | EN 데모 장면 전체 | 장면마다 과거/현재 시제가 바뀐다. 특히 M04 상철 4연속 장면이 첫 장면만 과거형이다. 인용부호가 `'`·`"`·`“”`로 섞인다. | M04 연쇄 4장면을 한 시제로 통일한다. 데모 11장면의 대사 인용부호를 한 규칙으로 맞춘다. |
| 6 | `content/events/arc_events.json` `arc_sangchul_01_answer` 선택 1·2·3 | KO 결과문에 과거형 사이 현재형("피식 웃는다"), `{name}` 대신 "김민준" 직접 표기가 섞인다. | 과거형·`{name}`으로 맞춘다. |
| 7 | `arc_temptation_clean` KO | "받지 않은 200만원은 없었고"가 이중 부정으로 읽힌다. | 뜻("200만원은 들어오지 않았다")이 바로 읽히게 고친다. |

## 판단만 남기는 항목 (이 오더에서 고치지 않음)

- M04 `arc_sangchul_01_measure`·`arc_sangchul_01_coffee`는 선택지가 1개씩이라
  연속으로 "선택이 아닌 선택"이 된다. 외부 플레이테스트의 `스킵` 표시가 이
  구간에 몰리는지 본 뒤 결정한다(`PLAYTEST_KIT.md`).
- M06 선택지 "한빛유통 월말 오류표 … 입사 뒤 처음"은 M01~M05 장면에 입사가
  나오지 않는다. 어떤 조건에서 노출되는지 확인하고, 설명 없이 노출되면 별도
  수리 오더로 올린다.

## 검증

- 바뀐 문자열의 JA/zh-CN/zh-TW 오버레이도 같은 사실로 갱신한다.
- `python3 tools/en_coverage_check.py`, `python3 tools/english_hangul_audit.py`,
  `python3 tools/story_demo_localization_audit.py`, 번역 파이프라인·감사의 표적 차선.
- 데모 전용 `StoryDemoFourLanguageCheck`와 KO/EN 실제 화면 확인.
- 새 데모 후보 identity를 기록하고 사람 판정은 OPEN으로 둔다.

## 2026-09-27 Codex 실행 선언 — 첫 배치 A

사용자 승인 원문은 위와 같이 보존한다. 첫 배치는 수리4의 EN 재혁 재회
`description`, `choices[0].result_text`, `choices[1].result_text` 세 leaf만 고친다.
`our whole service`→`their whole service`, `You'll be in touch`→`I'll be in touch`,
`Why now, why you.`→`Why now—why me?`를 원문 화자와 대조한다. 인용부호·시제
전수는 수리5의 다음 배치로 남기고 세 leaf의 나머지 바이트는 보존한다.

- root 소유: `content/events_en/arc_events.json` 위 세 substring; 이 사양·큐·
  `docs/WORK_LOG.md`·생성 `docs/STATUS.md`·`CLAUDE.md` 현재 행;
  새 private `.git/full-game-localization/order302-demo-*` 검사·실행 증거.
- 비저자 `/root/blackjack_accounting_review`: 새 private `order302-demo-english-review*.json`
  및 정확복사 `docs/agent_reviews/ORDER-302-A.json`만. 저작/검사기 작성과 분리한다.
- 독립 영향 분석은 읽기 전용이다. KO/JA/CN/TW·게임효과·기존 원장/승인·패키지·
  build identity/공개 데모 파일은 변경하지 않는다. KO가 그대로인 영어 오역 수리이므로
  다른 세 언어는 같은 뜻인지 읽고 이미 일치하면 덮어쓰지 않는다.
- 표적: exact3leaf/inverse-byte·토큰/개행/다른 파일 보존 검사,
  `en_coverage_check.py`, `english_hangul_audit.py`, `story_demo_localization_audit.py`.
  전체11장면 전수/5locale runtime·KO/EN 실제화면·새패키지·새후보 판정은 후속이다.
- 배치 A만 끝나도 오더는 `[~]`다. 기존 공개 GO는 보존된 옛 exact package에만
  유효하며 수정 source/미발급 새 package는 이를 상속하지 않는다.
- 선언 기준 clean `6a89850`; 동시 번호 충돌의 미구현 DaiSai 계획은303으로 보존했다.
  위 파일/세 substring/증거 계획은 일회성이고 새 정본 규칙을 만들지 않는다.

### 배치 A 독립 대조 중 별도 메모

- 비저자 지역 대조는 KO3과 JA/CN/TW 각3leaf(9/9)의 복무 이력·재혁의 연락 약속·
  민준의 내면 질문을 확인했다. 이 세 의미는 이미 일치하여 세 언어는 무수정이다.
- EN `description`의 개행8 / KO·JA·CN·TW 개행9는 수정 전부터 있던 차이다.
  좋은 옷/시계/얼굴 지문 뒤 마지막 대사 앞 빈 줄은 수리5의 형식 전수에서 함께 본다.
  배치 A가 만든 회귀나 이번에 고친 항목으로 세지 않는다.
- 배치 A에서 감지한 역사 검사/volume hash 호환은 별도 [304](../queue_archive/ORDER-304.md)가 소유한다.

### 배치 A 완료와 다음 시작점 (2026-09-27)

재혁 EN3leaf/3substring 수리는 원고 `3fb9890`, 검사 호환 포함 후보
`ae0a302574998c5415ff7a2e0428f80006648cf5`에서 독립 부분 검수를 마쳤다.
[302-A 보고](../agent_reviews/ORDER-302-A.json) SHA `538315b80cb77f6576caaf628b92e2a09b31494cc543b077a77e15ae07045c9c`.
전체 ORDER-302는 HOLD이며 이 부분 결과가 전체 데모/새 package GO는 아니다.
정확3leaf와 그 외 원고·KO/JA/CN/TW·게임효과·기존 공개/인간 원형 보존,
언어3검사 및304 표적검사 PASS. 새엔진·화면·입력 관측0.

다음은 수리1/3의 공개 시작 안내와 M06 회상 장소: controller의 `_show_home`
공개 분기/`_install_story_demo_m6_event`, KO key2개와 세 지역 사전6값을 먼저
선언한다. EN 시작안내 `Night-shift income`은 이미 직업 중립이다. 최소 파일은
`playtests/order124/StoryChoiceM1M6Playtest.gd` + `locale/ui_ja.json`,
`locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`이다. legacy/public=false 안내는
별도키이며 묵시 확장하지 않는다. 두 키의 기존 portable accepted receipt0;
공식 수용 수량과 과거 공개 GO를 임의 갱신하지 않는다. 구현/실제화면은 미실행.

## 2026-09-27 배치 B 착수 — 공개 안내·회상 사실 2키

기준 clean `a2a9c4b348577ed311dde637270cad8c0aef44c8`. 수리1/3만 실행한다.
직업 오기는 플레이어가 민준과 다은의 일을 혼동하게 하고, 장소 오기는 자신의
지연 선택 기억과 충돌한다. 선택·경제·상태 차이는 새로 만들지 않는 정합 수리다.

- root: `playtests/order124/StoryChoiceM1M6Playtest.gd` 공개 baseline의
  `편의점 야간 수입`→`야간 단기 일 수입`, M06 부모의 `3월, 버스 정류장에서`
  →`3월, 빗길에서` 및 EN 해당 장소. 이미 중립인 EN 시작 안내는 보존한다.
- 지역 저자 `/root/release_status_crosscheck`: `locale/ui_ja.json`,
  `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`의 해당 부모 KO키2개 이동과
  그 값의 직업/장소 substring만. 한국어에서 각 지역별 직접 저작, 다른 값 보존.
- root 증거: 새 private `.git/full-game-localization/order302-b-*`,
  기존 capture helper의 새 `b-*` label, 이 사양·큐·WORK_LOG·생성 STATUS·CLAUDE 상태행.
- 독립 검수 `/root/blackjack_accounting_review`: 제품 저작 없이 두 키/세 지역6값
  전수, private `order302-b-review*.json` 및 `docs/agent_reviews/ORDER-302-B.json`.
  검사 준비 `/root/blackjack_accounting_tests`는 기존 전용 검사/격리를 읽기 전용 조사한다.
- 검증: 이전2키→새2키 동시 migration/중복0/그 외 byte보존, 토큰5·개행 보존,
  story-demo 정적 감사·JA/중국어 표적·기존 full-game 수용핀, 격리된
  `StoryDemoFourLanguageCheck`의 exact marker와 stdout/Godot로그 오류 검사.
  pre-autoload 새 격리 user namespace를 사용하며 사용자 project.godot·저장·설정 불변.
- legacy/public=false 별도 키, 원고의 월세·시제·인용·KO표기, 나머지 gameplay,
  과거 accepted/human/agent 원장과 공개 package는 제외한다. 새 receipt 수0.
  실제 렌더/입력은 실행 증거가 있을 때만 주장한다. headless 진행은 화면 관찰이 아니다.
- 이 배치만으로 ORDER-302 전체/본편/새패키지 GO를 발급하지 않는다.
  잔여 항목2/5/6/7과 KO/EN 실제화면·새후보 판정은 계속 OPEN이다.

실행 전 격리 검토: 기존 검사 `_ready`는 autoload보다 늦으므로 private SceneTree
bootstrap에서 fresh32hex RuntimeQA 경로를 먼저 설정·검증한다. 전역 HOME을 재지정하지
않고 실제 OS 경로와 모든 controller ENTRY를 결속하며 상속 probe 출력경로를 제거한다.
사용자 두 저장 root 전후 census/hash를 대조한다. 이 실행 보완은 제품 변경이 아니다.

### 배치 B 검증과 다음 시작점

- 후보: `6c4cd0d1302e2d8a7452a2a12a557757898fe8d3`, tree
  `32831908d9a95a0028a8bcc6248a497f6cc6e287`; 제품 controller3substring·사전6행만.
- 도달 경로: `STORY_DEMO_FOUR_LANGUAGE_CHECK_OK locales=5 routes=5 months=30 weeks=120 settlements=30 ap_surface=0 save=5 story=10 build=2026.08.31.1`.
- 생산자↔독자: `StoryChoiceM1M6Playtest.gd:2178`↔`:2183` 공개 안내;
  `:1220` 선택이력↔`:1126` 템플릿↔`:1129` M06 description.
- 바꾸는 상태: 직업 오기→야간 단기 일, 버스 정류장→빗길. 게임 상태 변화0.
  포기 시 잃는 것/장면 계층: 해당 없음(기존 공개 안내·M06 회상 사실 수리).
  서사 위치: home / M06.recollection. 닫는 것: 수리1/3의 문구·lookup 정합만.
- 정확 byte 역치환·중복0·토큰5/개행7, EN/Hangul/story-demo·JA UI·ZH skeleton·
  density 감사 PASS. 전체 inventory는 INCOMPLETE와 기존 invalid를 그대로 보고한다.
  기존 portable40299핀 현재성 PASS(ja13111/CN13594/TW13594), 새 수용0.
- 실제 엔진1회/8.66초, exact marker·오류/누수0·controller ENTRY12의 격리경로 일치.
  사용자43파일·1219실행 source/helper핀 전후 불변. PNG0·물리/인간/원어민 관측0.
  증거는 private `order302-b-runtime-first/`와 `order302-demo-check-b-*-first.json`.
- 비저자 [302-B 보고](../agent_reviews/ORDER-302-B.json)는 두 키/지역6값 전수와
  실제 raw 증거에 한정한다. 전체302/본편은 HOLD, 옛 공개 package GO 미상속.
  보고 SHA `65721aa3fa812f1132fd0dc74a7bfad383b9cba10ef8f993621796efbdc12b3b`.
- 자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
  headless PASS는 실제 화면·잘림·정상 속도 독해·패키지 승인이 아니다.
- 다음은 원룸 월세와 KO 결과문/이름/이중부정(2/6/7), 별도의 EN 시제·인용(5),
  KO/EN 실제화면·새후보 판정이다. 두 배치를 마쳤으므로 잔여 저작은 후속 작은
  사양으로 분리 선언한 뒤 구현한다. 기존 두 배치나 엔진 검사를 이유 없이 반복하지 않는다.

읽기 전용 후속 조사(구현 선언 아님): 월세는 meet의 description/orthodox/unorthodox
3종×5언어=15leaf다. answer 결과0의 KO/JA/CN/TW 고정 이름은 `{name}`으로 맞춰야
하고 EN은 이미 토큰이다. 결과1의 KO `웃는다`만 과거형 수리, 결과2는 지목한
결함이 없다. clean description의 이중부정은 KO/JA/CN을 함께 검토하고 EN/TW는
이미 뜻이 명확하다. 이7 source leaf의 지역21 accepted 슬롯0·overlay 소유중복0.
EN 월세는304의 exact 파일핀 밖이므로 새 successor 역투영을 별도 선언하고 과거
핀을 덮어쓰지 않는다. 원고5파일(arc KO/EN + 지역 story_demo3), 기계효과는 불변이다.

2026-09-27: 잔여2/6/7은 [305](ORDER-305.md), 그 exact 역사 검사 호환은
[306](ORDER-306.md)으로 분리 선언했다. 이 부모는 EN 문체5·실제화면·새후보 OPEN/HOLD다.
