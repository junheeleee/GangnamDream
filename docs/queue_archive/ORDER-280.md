# ORDER-280 — 슬롯 당첨 결과 중국어8값

[x] 2026-09-20. 비저자 Poincare work_unit 한정GO, 필수 결함0.

- 제품 `3eb1474d0d19c66c31e1b977e97b5a0957c25768`, tree `4e010dfabc0413063032d62fa1dc848f99b44f42`; clean 검토 `e72574ab050bc634b3da31d91ed49f4b91f477dd`, STATUS-only wrapper.
- KO4개의 당첨 결과명을 CN4/TW4 직접 번역했다. 777선두 분기와 체리3/2/1의 정확 개수를 보존하고 TutorialOverlay 공유1을 포함해 전수 대조했다.
- 총지급·순익 부모, 원화·배당·RNG·효과·KO/EN/JA·runtime·checker·collector·원문 manifest 불변.
- 실제 export/check/import4/4, 공식39980/b125/meta9. old39972 source/target hash와 UI/portable 원형 역복원, JA 원형, 보류72 보존.
- 최초 check2건은 --locale 생략으로 CLI default와 batch가 달라 실패했다. 같은 응답/원문에 locale를 지정해 CN은 통과했고 TW는 顆 분류사 오탐으로 거절됐다. 실패와 첫 언어GO를 각각 보존했다.
- 원문의 체리 그림 개수에 자연스러운 통용 분류사 個로 TW 전량4를 재독·별도 v2 작성, CN 포함8값 비저자 재검수를 받고 check했다. 顆가 오역이라는 판정이 아니며 checker를 넓히지 않았다.
- 명명12 PASS. 기존 conditional legacy/AP consumer이고 실제화면·fresh-story·원어민·인간·물리패드는 미관찰이다. 과거 캐시 로그 재번역·직행영문 기계/심볼 라벨·별도 튜토리얼 원문 결함은 비포함.
- [독립 보고](../agent_reviews/ORDER-280.json) SHA `374eb08c2af6b568b2d6dd8fc046ca614d9eb63d51924ddf9c1ee7223ea1a5f6`. 공개GO1·인간OPEN45·본편HOLD 유지, 전체 슬롯/게임 번역완료가 아니다.
- 작업 소유·선정·배치·검사는 일회성. WORK_UNIT/I18N 재사용, 신규 규범 승격0.

자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

## 최초 실제 캡처

git-private에 최초 stdout/stderr bytes·SHA·exit·입력핀을 보존한다.

| 파일 | 바이트 | SHA256 | exit | 결과 |
|---|---:|---|---:|---|
| order280-accept-cn-first.json | 377823 | daa1c2bc67f0d7f1452572ce59e5ac4f62c23767e91cccc89780b5060eaba138 | 0 | PASS |
| order280-accept-tw-first.json | 377820 | 9be1eb93d3ce0bd0d199c09fe8e4d0a679fea726ca320735378ec3ada2cd6fee | 0 | PASS |
| order280-applied-export-cn-first.json | 377883 | 9904bd405a766fc6e1b83c6081a065820ab2987b767f3b6ac69ff99e61d52eff | 0 | PASS |
| order280-applied-export-tw-first.json | 377884 | bc5d16d8296548f29453128af61c10734bf0ff9dfce4ce18ad5a3af12d0996a4 | 0 | PASS |
| order280-export-cn-first.json | 377884 | ef8e8d986c427541b3d9938062731a21fb7d6575aa43d9e1aa3f54344d0fcae5 | 0 | PASS |
| order280-export-tw-first.json | 377884 | ac601db748d2aa9c831567e5ef095a2466d3aa89a974aa10f5c2f497d6634aac | 0 | PASS |
| order280-named-envelope-first.json | 379939 | 3673d944acc224bfc0e50ac32e23c8f7bad60516175f9cd3a62e5225bf276b2e | 0 | PASS |
| order280-named-first.json | 1697811 | bb98d96dcedfe39dbfe95ef173ad2089279b0ce038b931381edcddfc191013f0 | 0 | PASS |
| order280-preflight-cn-first.json | 377624 | d2949b56a6d953d6ecc83556cb1733a51b582d36126611fcb36ec124b0a0c6e7 | 1 | FAIL preserved |
| order280-preflight-cn-locale-first.json | 377822 | 2d66129d1f091970c1d1fb516f0260ce87e0ec47b514ddd59f3db78a4563da68 | 0 | PASS |
| order280-preflight-tw-first.json | 377624 | 4ce73f1ee37e3502b3c90511b5e8871fd737b96121863f0a14c0f5cc62566ffe | 1 | FAIL preserved |
| order280-preflight-tw-locale-first.json | 377945 | 548a050b9307010f9e4a7a5447c13f28ede2a96ed0a7f0e8d778f9758ad49357 | 1 | FAIL preserved |
| order280-preflight-tw-v2-first.json | 377820 | e8ef67495ed07ca72c980d64214435a235e1292c813527b4ebf6855c202a17c6 | 0 | PASS |
| order280-preservation-first.json | 378111 | b8fb11d382b3a4a92223574f3061434373a7689c86b5f1891d06c9900cd0e29b | 0 | PASS |

## WORK 마감 전 원문

# Gangnam Dream Work Log

> 이전 WORK·선언·검증 원문은 [279 보존본](queue_archive/ORDER-279.md)에 있다.

## 2026-09-20 (Codex — 슬롯 중국어42·일본어 패배 수리)

- [279](queue_archive/ORDER-279.md): 제품9860e2b·검토fb6127f, 독립 Poincare 한정GO/필수0.
- 슬롯21키의 간체·번체42값을 채우고, 일본어에서 꽝을 대박으로 표시하던 한 값(실제2호출)을 바로잡았다. 총지급/순익·near miss/패배·원화·배수·패드 인자는 보존했다.
- 공식39972/b124/meta9. 기존39929 source/target hash·UI/portable raw 역복원·다른JA행·원문 manifest 보존, 명명12 PASS.
- 이 UI의 실제화면·원어민·인간·물리패드 미관찰. 공개GO1·인간OPEN45·본편HOLD 유지, 과거보류72 불변.

## 다음 안전한 범위

- 슬롯은 정적21키만 이번 범위다. 다음 동적 win_type4의 RO 메모 `.git/full-game-localization/post279-next-slot-values.json`(9566B, SHA6e8515547bb3c1c463e78c2ed44de9ec2d61dbdb8717a48dce67ed43219d7baf)의 원문·14핀을 확인했다. CN/TW8값만 별도 선언 가능하며 JA4는 유지한다. 777 선두는 실제 잭팟 분기 계약이고 체리2는 정확히2개다. TutorialOverlay 공유1·캐시된 과거 로그·조건부 진입·직행영문 기계 라벨 한계를 보존한다. 새 번역·검사·제품 변경은 아직 없다.
- 남은 UI·동적인자·직행EN은 전체 번역완료와 별개다. UI사전3016 중 CN/TW각2108키 부재는 전체 live UI 분모가 아니다. legacy/AP 조건부 진입은 fresh-story/화면 증거가 아니다.
- 보류72는268의62·270의10이다. 자산 안내5키×2의 KO 3분의1→분 단위 오탐2 수리는 새 선언 전 실제 원고·원형 진단·소비자 재확인을 요구한다.
- 월말 흑자1의 net==0·첫 월급2 투자접근·시장 동적인자/AP효과·자산10억 절반·저자산 초기판정·잠/식사 고지는 별도 원문 정합 대상이다.
- 비보호 shipping 사건11578 세 언어 수용 완료, 잔여843은 참고741·보호102다. 공개판과 역사 인간 판정은 유지한다.

## 활성 사양 원문

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

