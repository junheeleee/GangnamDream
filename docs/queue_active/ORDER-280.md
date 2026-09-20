# Active Queue Spec: ORDER-280

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-280 [P0·전체 현지화] 슬롯 당첨 결과 네 키의 중국어 폴백을 닫는다

**[~] 2026-09-20 Codex 착수 — 아래 12경로만 소유.** 부모 ORDER-157.
기준 `e60aa1c2f820b3b83308ccdeb23126419191231b`. 슬롯 정적 UI 다음의 별도 작은
배치다. 서로 연결된 4결과·8값을 판정 가능한 한 묶음으로 삼고 숫자 하한에 맞추어
범위를 늘리지 않는다. 신규 게임·AP판·확률·출시 언어 변경은 없다.

## 깊이 3문과 정확한 원문

1. 지우면 무엇이 깨지는가: 새 당첨 결과·최근 기록·수익 로그에서 영어 결과명이 남는다.
2. 24주 상태 차이: 선택 신설이 아닌 동일 결과의 표시다. 돈·확률·진행 상태 차이0.
3. 같은 자리의 경쟁: 동일 UI의 영어 폴백을 KO 직접 번역으로 대체하며 새 화면/행동0.

| 원문 키 | 생산자 | 독자·의미 |
|---|---|---|
| 777 잭팟! | systems/SlotMachine.gd:115 | SlotMachineGame:345의 begins_with("777") — 반드시 선두777 보존 |
| 체리 3개 | systems/SlotMachine.gd:121 | 실제 체리3개, 20배 결과 |
| 체리 2개 | systems/SlotMachine.gd:127 | 실제 체리2개, 3배 결과; TutorialOverlay:59의 공유 키 |
| 체리 1개 | systems/SlotMachine.gd:130 | 실제 체리1개, 1.5배 결과 |

사전 키는 정적 literal이고 결과 인자로 동적으로 소비된다. 영어·일본어 중역 및
간번 자동 변환0. 기존 JA4는 유지하고 신규 수용으로 세지 않는다.
선정 근거 private post279-next-slot-values.json(9566B,
SHA6e8515547bb3c1c463e78c2ed44de9ec2d61dbdb8717a48dce67ed43219d7baf).
루트가 원문과14핀을 확인한 기존 RO 메모이며 새 export는 선언 뒤 수행한다.

## 파일 소유권

- locale/ui_zh-CN.json, locale/ui_zh-TW.json: 위4키씩 append만.
- content/meta/full_game_localization.json: exact8 수용과 1배치 append.
- CLAUDE.md, docs/CODEX_QUEUE.md, docs/CODEX_QUEUE_L3_PENDING.md.
- docs/queue_active/ORDER-280.md, docs/queue_archive/ORDER-280.md.
- docs/WORK_LOG.md, docs/STATUS.md.
- docs/agent_review_decisions.json, docs/agent_reviews/ORDER-280.json.

KO/EN/JA·런타임·checker·collector·수치·원문 manifest·project.godot·공개 데모·
인간 원장·이전66 판정은 비소유. 원형39972/b124/meta9 및 보류72를 보존한다.

## 실행·검증

각 지역 저작을 분리하고 비저자 검수자가 KO4×2를 전수 읽는다. source-bound
export/check 및 수동 사전 설치 후 fresh export/import --accept를 사용한다.
private 원문·응답·receipt·stdout/stderr·exit·SHA를 보존한다. 원문과 target hash,
UI/portable 원형 역복원 및 기존39972 유지 확인 뒤 최종 clean 후보에 기존 명명
news-panel-locale-only의 고유12검사를 1회 실행한다. 실패면 원형을 남기고 원인만
고쳐 재시도한다. 종료 metadata6 외 전체감사·240주·엔진·새 검사 확장은 없다.

777 선두 분기·체리 개수·총지급/순익 부모 의미를 독립 확인한다. 원본 UI/로그는
이미 완성된 문자열을 저장하므로 과거 로그 재번역/실시간 locale 재구성은 주장하지
않는다. legacy/AP 조건부 경로이며 fresh-story 도달·실제화면·원어민·인간·물리패드
미관찰이다. 직접 영문 기계/심볼 라벨과 tutorial의 별도 기존 원문 결함은 범위 밖.
제품 GO·전체 슬롯 번역완료는 아니다. 공개GO1·인간OPEN45·본편HOLD 유지.

선정/소유/배치/검사는 일회성. 기존 WORK_UNIT·I18N 규범을 재사용하며 신규 승격0.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

