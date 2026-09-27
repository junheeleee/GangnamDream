# Active Queue Spec: ORDER-361

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [ ] ORDER-361 [P1·검증] 4장 문구 수리의 현재 소스와 역사 비교를 연결한다

2026-09-28 Codex 발행. 351에서 실제 관측한 full-body current admission
6경로 실패의 별도 후속이다. 구현·새 도구 실행은 아직 하지 않았다.

## 깊이 3문

1. 왜 지금인가: 고친 원고를 실제 회귀 검사가 읽을 수 있어야 한다.
2. 무엇을 보존하는가: 현재 5언어 원문/receipt, 원형 350·313·309·316·310·305
   모듈·고정 pin·실패 이력·인간/공개 package 판정 전체.
3. 무엇과 경쟁하는가: 351 통합을 닫기 위한 검증 연결이다. 새 집필·번역·
   콘텐츠 지문 재검토(362)·출시 승인은 이 범위 밖이다.

## 실제 입력과 실패

- 제품 `3f0aa92dc9c3bdefd6a333fa84481a318baad907`, 직접 부모
  `6297e8cbcd4e77278055b5e332f545ea32de90f9`. 11 JSON의 기존 문구87
  (KO16/EN23/JA·CN·TW 각16)과 ledger 기존48갱신, 새 key/receipt0, b141→142다.
- `order351-static-first-11-stdout.log`: old350 exact successor 거부6경로는
  `content/events{,_en,_ja,_zh-CN,_zh-TW}/arc_drama.json`과
  `content/meta/full_game_localization.json`이다. exit1을 보존한다.
- 현재 새12경로와 기존 LIVE38의 합집합44. 역사 대상 KO/EN5파일39leaf와
  기존14파일68leaf의 합집합17파일107leaf다. 실행 전 실제 Git에서 재계산한다.
- EN `arc_minseo_01_meet.description`의 개행8→6은 주석 문단을 대사 밖 짧은
  설명으로 바꾼 정확 예외다. 다른 문단·토큰 불변 조건까지 완화하지 않는다.

## 착수 후 소유할 파일 — 8도구, 1~2배치

- 새 `tools/order351_source_compat.py`: 실제 부모/제품 commit·전체12경로·raw/
  payload·87leaf·48receipt 전이를 먼저 검증한다. 현재 source/번역 inventory를
  바꾸지 않고 KO/EN의 역사 비교에서만 351→350/359→313→309→316→310→305로 잇는다.
- 기존 소비자5: `tools/full_body_translation_scope.py`,
  `tools/story_graph_contract_audit.py`, `tools/chapter5_human_reject_audit.py`,
  `tools/year5_reference_route_audit.py`,
  `tools/chapter1_core_loop_v2_causal_ledger_check.py`.
- `tools/audit_scope.json`, `tools/audit.sh`: 새 명시 차선만. 기존 검사 면제0.
- 마감: 이 사양·351 후속 검토·두 큐·WORK_LOG·생성 STATUS·CLAUDE 현재행,
  새 독립 보고와 판정 append. 실제 구현 전에 최신 지침/선택 프로필을 읽고
  소유자를 분리한 `[~]` 착수 선언 커밋을 먼저 만든다.
- 원형6모듈·그 corpus/assertion·제품 원고/번역·게임 코드·인간 원장·공개
  source/tree/PCK/ZIP·콘텐츠 인벤토리는 수정하지 않는다.

## 놓치지 않을 역사 경계

- year5의 기존350 corpus는 ORDER-155 이후 보존분기와 결속되어 있다.
  `order309_transition_self_test`의 그 분기를 새 current351로 옮기지 않는다.
  기존350 별칭을 보존해야 앞선4실패를 재발시키지 않는다. 새351 history의
  ORDER-155 등록 교집합은0, chapter1 기존 KO midgame 교집합1은 그대로다.
- 이전350 직접 CLI를 현재 소스 PASS로 바꾸지 않는다. 원형350 self-test는
  실제 과거 ROOT/모듈/Git 신원을 검증한 격리 fixture에서 실행한다.
- stale/rollback/mixed source, 이웃 leaf·새 key·조작 receipt·위조 Git 증거는
  계속 거부한다. 실패를 현재 해시 덮어쓰기로 없애지 않는다.

## 완료 조건

- 새 모듈 normal/self/historical, 소비자5 normal/self와 명시 차선의 실제
  결과·전후 source census·실패를 보존한다. 351의 64상태 화면을 이유 없이
  재실행하지 않는다. 전체 shell/240주/자연 입력 통과로 확대하지 않는다.
- 비저자가 전이 전체와 정확한 최종 clean source를 검토해 별도 작업 판정한다.
  351은 362 콘텐츠 지문 재검토까지 닫힌 뒤 별도 후속 판정한다.
- 일회성 지시, 상시 규범은 기존 WORK_UNIT/I18N/큐 정본이다.
  원어민/인간/물리 관찰 OPEN, 본편/새 package HOLD 및 외부 권한 경계 유지.
