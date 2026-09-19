# Active Queue Spec: ORDER-273

#### [~] ORDER-273 — 경마 거리 단위 오탐 수리와 기존 중국어 20값 복구

2026-09-20 착수. 부모 [157](ORDER-157.md), 현재 위임 [WORK_UNIT](../WORK_UNIT.md).
기준 main `f61c7f4e6066900fd12e461754f9966a409007ac`, 공식39872/b117/meta9, 기존보류110.

## 깊이 3문과 한정 범위

1. 무엇이 깨졌는가: 경마 거리 `%dm`에서 placeholder를 제거한 target의 `m`을 source의 `dm`과 대조하여 정상 원고4값을 영어잔재로 거부한다. 같은 기능의16값도 함께 보류됐다.
2. 게임 상태가 달라지는가: 아니다. 24주/5년 효과·선택·저장·확률은 그대로이며 중국어 경마 정보표의 영어 폴백만 줄인다.
3. 무엇과 경쟁하는가: 새 UI 저작보다 기존 검수 원고20값을 재저작 없이 복구한다. 다른90보류·첫고지·동적 표시명·직행EN은 새 범위다.

기존 두 기능 `race_header_cash`/`horse_form_rows`의10키×2지역20값만 수용후보다.
두 기능은 같은 오탐 원인을 공유하므로 15~25독립기능에 억지로 맞추지 않는다.
회귀입력20개(정상4/변이14/OFF2)는 번역20값과 별도 모집단이며 합산하지 않는다.
원형은 `.git/full-game-localization/post272-metre-repair-cases.json` 23815B,
SHA256 `67bb7c8a5688e11dab6ab6f255e9a3b8a18edd7d3d94247a45984809723dafa9`.
공개269 `held_drafts` 원문과 SHA를 대조한다. 기존 언어 GO를 기계 수용으로 부르지 않는다.

## 파일 소유권

- 구현자 Plato: `tools/zh_translation_audit.py`의 두 완성 KO원문에 한정된 거리 slot/unit 검사와 기존 self-test의 소형 회귀 사례. 전역 m/dm 허용·기존 기준선 완화·새 프레임워크 금지.
- ROOT: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`의 위10키씩만; `content/meta/full_game_localization.json`의 실제 영수증20값과1배치만.
- 운영 ROOT: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`, 이 active와 `docs/queue_archive/ORDER-273.md`, `docs/WORK_LOG.md`, `docs/STATUS.md`, `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`, `docs/agent_review_decisions.json`, `docs/agent_reviews/ORDER-273.json`.
- 비저자 Poincare: 읽기 검토와 git-private 봉인 보고. Git/QA/공식 수용은 ROOT만 수행한다.
- git-private 기존 exchange/capture helper를 재사용한다. 원형 first결과를 덮지 않는다.

## 구현·검증

- 선언 commit 뒤 수리 전 direct validate_text/full translation_errors의20회귀입력과20원고를 실제 관찰한다. 기대값은 관찰과 분리하며 진단 완료exit0를 번역PASS로 세지 않는다.
- source의 distance 인자 slot(header1/horse2, 0부터)와 미터 suffix를 묶고 종류·순서·부호·BBCode·줄바꿈·돈·문자·다른 영어 검사는 보존한다. 숫자 뒤 일반 공백은 오류라고 새로 규정하지 않는다.
- 수리 뒤 같은20입력을 실행한다. 정상4 모두 PASS 전에는 음성14의 성공을 주장하지 않는다. OFF2는 원형 진단과 동일해야 한다. 원고20 전수 언어·소비자 재대조 뒤 기존 check/import로 실제 수용한다.
- 새 exact clean 후보에서 기존 `news-panel-locale-only` 명명12를 한 번 실행한다. 이 차선의 ZH self-test가 변경 checker를 직접 검사하고, fullself가 실제 adapter를 회귀 검사한다. 실패는 원형 보존 후 해당 검사만 수리·재실행한다. 전체감사·엔진·240주·새 native claim0.
- 기존39872 source/target 해시, UI/portable raw inverse, KO/EN/JA/runtime/project/public/human 원형 보존을 확인한다. 선언소유14경로 밖 수정0.
- 비저자가 실제 변경과 증거를 읽고 clean source commit/tree 및 STATUS-only 또는 명시 운영metadata wrapper를 결속해 한정 work_unit 판정한다. closure metadata만 바뀌면 그 표적 검사를 별도 실행한다.

## 닫는 것과 남는 것

닫는 것: 실제 통과한 거리 검사 수리·최대20값 수용. 원고 의미·거리 단위·숫자 소유를 왜곡하지 않는다.
보존: 기존 인간 판정·공개GO1·인간OPEN45·본편HOLD. 원어민·실제 화면·물리패드 OPEN.
이 배치의 선정·파일소유·증거 계획은 일회성이다. 언어·위임 규범은 기존 정본을 유지한다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
