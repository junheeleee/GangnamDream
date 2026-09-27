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
- 배치 A에서 감지한 역사 검사/volume hash 호환은 별도 [304](ORDER-304.md)가 소유한다.
