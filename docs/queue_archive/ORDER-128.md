# Active Queue Spec: ORDER-128

> Canonical status and execution order are indexed in docs/CODEX_QUEUE.md.

#### [x] ORDER-128 [P0·CI 신뢰] 전체 감사 12개 실패를 의미 축소 없이 닫는다

**사용자 지시·착수 선언 (2026-08-25):** 사용자는 CI 오류를 포함한 큐 작업을
계속 진행하고, 종막 밀도를 올린 뒤 직접 플레이할 시점에 알려 달라고 했다.
ORDER-127 전체 감사 13 flag 중 STATUS_DOC 1건은 마감 생성으로 해소됐다.
남은 12건은 실제 코드 결함, 좁은 데모의 승인된 예외, stale 원장을 분리해 고친 뒤 같은 exact tree의
전체 GREEN을 확인한다.

**[x] 완료 — 만진 파일:** scenes/StoryMode.gd,
tools/peak_scene_chain_audit.py, tools/First30SecondsCheck.gd,
tools/ja_translation_pipeline.py, tools/ja_translation_audit.py,
tools/zh_translation_audit.py,
tools/chapter1_core_loop_v2_causal_ledger_check.py,
content/meta/year5_reference_routes.json, tools/year5_reference_route_audit.py,
content/meta/demo_localization_scope.json, tools/audit_scope.json,
docs/CODEX_QUEUE.md, 이 사양, docs/queue_archive/ORDER-127.md,
docs/queue_archive/CODEX_QUEUE_2026-08.md, CLAUDE.md,
docs/WORK_LOG.md, docs/history/WORK_LOG_2026-08-24.md,
생성본 docs/STATUS.md.

## 깊이 3문

1. 왜 검사 기준을 지우지 않는가? StoryMode 타입, 종막 우선순위, 저장 표시,
   한글 누출, 중국어 금액·지역 문자는 실제 제품 의미다.
2. 왜 번역문부터 바꾸지 않는가? ORDER-126 전용 감사에서 통과한 속어 금액,
   Hanbit 준비형, 대만 표준 자형을 구형 범용 감사가 오탐하고 있다.
3. 왜 종막 카피를 같이 고치지 않는가? CI 기준선을 먼저 복구해야 다음
   서명 coda·M59~M60 개작의 새 회귀를 분리할 수 있다.

## 배치 A — 코드·종막·저장 10단위

1. StoryMode 2044행 Variant 추론을 명시적 String으로 고친다.
2. fresh HOME 첫 30초 진입을 실행해 저장 표시까지 확인한다.
3. 다은 심판 guard가 ORDER-127의 gangnam_goal_reached를 읽게 한다.
4. ORDER-127 기록을 기존 11, 새 PEAK guard 1, STATUS 1로 정정한다.
5. 챕터 1 원장은 StoryMode 실제 변경만 source snapshot으로 재정렬한다.
6. 원장 self-test는 새 baseline에서도 변조를 거부한다.
7. PY, PEAK_CHAIN, FIRST30, 챕터 1 direct/self-test를 통과한다.
8. 30억 종막 15-case 실행 검사를 보존한다.
9. 새 저장 필드·엔딩 ID·CG·밸런스 수치를 만들지 않는다.
10. 코드 결함을 baseline 갱신으로 숨기지 않는다.

## 배치 B — EN·JA·zh-CN·zh-TW 정합 12단위

1. StoryMode 저장 helper를 UI format registry의 실제 소유자로 옮긴다.
2. UI call·legacy key·context ID·parameter provenance를 collector와 맞춘다.
3. manifest phase를 invalid_partial이 아닌 완료된 atomic phase로 고정한다.
4. JA·zh-CN·zh-TW의 ORDER-126 신규 UI 34 key 소유권을 정리한다.
5. ‘건당 백’을 100만원으로 보존한 번역을 범용 금액 감사도 정확히 이해하게 한다.
6. 승인된 회사명 Hanbit 流通만 허용하고 임의 한자 회사명은 계속 거부한다.
7. 대만 표준 자형 床은 허용하되 다른 간체 전용 문자는 계속 거부한다.
8. 금액·placeholder·인물명·선택 index·gameplay key를 보존한다.
9. EN Hangul, JA UI/pipeline, ZH, demo i18n direct/self-test를 통과한다.
10. mutation self-test가 오역·지역 문자·금액·registry drift를 거부한다.
11. 출시 언어 claim과 원어민 GO는 열지 않는다.
12. 같은 exact tree의 tools/audit.sh가 실패 flag 0으로 끝난다.

## 완료 증거

- 남은 12 flag의 direct/self-test가 모두 PASS한다.
- 15 routing, 35 ending ID·CG, Year5 dormant guard가 ORDER-127과 동일하다.
- 중국어 번역문은 byte 의미를 보존하고, 여섯 오탐과 신규 UI 34 key 소유권이 정리된다.
- context, queue, STATUS, 영향 selector, EN coverage, diff가 PASS한다.
- 최종 exact commit의 전체 감사가 “감사 통과”로 끝난다.

## 다음 경계

이 오더는 검사 신뢰만 복구한다. 마지막 서명의 엔딩 후일담과 M59~M60
9/10/9 장면 개작은 다음 작은 오더가 소유한다. 자동 GREEN은 재미 GO가 아니다.

## 규범 판정

- **승격:** 없음. 중국어 금액·준비형 회사명·대만 표준 자형, 일본어·중국어
  story-demo UI의 별도 소유권은 기존 번역 정본과 전용 strict collector를 실제
  범용 감사에 연결한 것이며 새 작품 규칙을 만들지 않는다.
- **일회성:** 실측 호출 수·source hash·proof binding·Year5 baseline commit과
  오더 번호·검사 marker는 이 완료 기록에만 남긴다.

## 완료 기록 (2026-08-25)

- 구현 `0e4da0d` / tree `62f930fbd146a18daf2481eac7dce561c410d2d0`에서
  ORDER-127 뒤 남은 전체 감사 12 flag를 모두 닫았다. StoryMode 타입, 다은
  guard, 첫 화면 고지 수를 실제 런타임과 맞추고, Chapter 1 proof 27개와
  dormant Year5 보호 baseline은 의미 변경 뒤 exact source로 재결합했다.
- EN UI format registry는 실제 `56/48`, 호출 `3316=3282+34`, 한국어 source
  `2818`로 맞췄다. 오류 메시지에 보인 여덟 행은 preview였고 실제 별도 소유는
  JA·zh-CN·zh-TW 각각 story-demo UI `34/34`다. strict source collector가 이를
  파생하며 임의 extra·누락·한글 잔존을 계속 거부한다.
- `건당 백=100만원`, source-scoped `Hanbit 流通`, zh-TW 공용자 `床`을 좁은
  의미 검사와 mutation self-test로 고쳤다. KO/EN/JA/zh-CN/zh-TW 번역 JSON은
  바꾸지 않았고, ZH self-test 263건과 demo i18n self-test 16건이 통과했다.
- `audit.sh`는 failure flag 0, `✅ 감사 통과`, 엔딩 35종·전용 CG 35장,
  `ENDING_ROUTE_IDENTITY_CHECK_OK cases=15`, 240주 KO/EN A/V·장면 방향,
  `COMPILE_CHECK_OK total=66`으로 끝났다. 이 GREEN은 검사 신뢰 복구이며
  후반 밀도나 사람 재미 판정을 닫지 않는다.
