# Active Queue Spec: ORDER-361

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

## 2026-09-28 후속363/364 실행 — 통합 판정은 별도

- [363](../queue_archive/ORDER-363.md)의 exact inventory 관측 연결 및 [364](../queue_archive/ORDER-364.md)의
  원형 반례 owner복원 뒤 Chapter1 normal과
  self689(기존622+361추가4+새63) 실제 PASS. 원래361의 두 exit1은 보존했다.
- 현재 원문/번역/inventory·기존 판정·화면64준비상태/70PNG 불변. 363 clean
  source에 독립 GO를 결속했으며, 이 작업의 별도 후속 보고/판정까지 통합 HOLD다.
- 새 화면·자연 입력·원어민·인간·물리 관찰0, 공개 GO·본편/새package HOLD 유지.

#### [~] ORDER-361 [P1·검증] 4장 문구 수리의 현재 소스와 역사 비교를 연결한다

2026-09-28 Codex 발행. 351에서 실제 관측한 full-body current admission
6경로 실패의 별도 후속이다. 아래 착수 선언 후 구현한다.

## 2026-09-28 구현·표적 실행 — 통합 HOLD

- 독립 최종 [보고](../agent_reviews/ORDER-361.json)는 source
  `22f0d0ddbb42e393bf290ecaf0c664d28a3d5163`/tree
  `6246af71a02a922e36cb6756f8b37300ee85401f`에 결속한 **HOLD**다.
  private 원본과 동일한 SHA
  `eb4ddd52afed87de1100f0a654bce578c7c88665976b064179d150de3c2b2b84`.
  실제20실행/역사 fixture/최종 문서 교량을 독립 대조했고 아래1원인·2실패가
  완료 차단으로 남는다. 이전120판정/98보고를 보존해 각1개만 추가(121/99)했다.

- 새 모듈/소비자5/등록2의 정확8도구만 구현했다. 제품12파일·전체content·
  원형6모듈·기존120판정/98보고·인간 원장은 선언7591501과 동일하다.
- 제품3f0aa92의 직접 부모6297e8c, 정확12 raw 전이/기존87문구/기존48receipt를
  검증했다. 현재LIVE44와 역사KOEN17파일107leaf, 신규receipt0,
  40302/b142/meta9/보류72를 유지하며 현재 inventory를 옛 본문으로 바꾸지 않는다.
- 명시 차선19종 최초 **17PASS/2FAIL**. 새 경계795·역사1955·full-body162·
  graph388·year51212·chapter5146·localization264사례 PASS다.
  year5self1316.355초, timeout0. 옛350 직접 CLI/current 의미는 바꾸거나 면제하지 않았다.
- chapter1 normal/self는 모두 `audited file snapshot mismatch
  content/meta/release_content_inventory.json`으로 exit1. self는 fixture 준비에서
  중단했으므로 기존622/신규4 corpus를 실행 완료로 세지 않는다.
  360의 정확6지문 갱신 `eaa588e0…1764`→`2ff67584…88b0`가 원인이며
  351 제품은 이 파일을 바꾸지 않았다. 351의12경로에 끼워 넣거나 원형 pin을
  덮어쓰지 않고 [363](../queue_archive/ORDER-363.md)을 [362](../queue_archive/ORDER-362.md) 뒤에 분리했다.
- 독립 검수에서 receipt 반례2곳의 정렬 직렬화가 의도한 손상 전에 key 순서로
  거절될 수 있음을 확인했다. `self_test`의 두 표현만 순서 보존 직렬화로 보강,
  새 경계 self795만 재실행 PASS(77.975초). 최초 약한 PASS도 원형 보존한다.
  두 표현을 정규화한 전체 AST 동일/다른18 CLI의 해당 함수 비호출을 확인했다.
- 총20실행에서 선택19종의 최종 **17PASS/2FAIL**, 매번 tracked+untracked text
  1836경로 전후 동일. dirty 선언HEAD7591501에서 실행했고 clean 마감 소스에서
  재실행한 것으로 세지 않는다. 집계 `.git/full-game-localization/order361-final-aggregate.json`
  SHA `a673ff5461764bfa3b07924ddb0e250010abf818c2f1b6bb76b4f95780cbd1ce`.
- 역사1955는 원형305132+310106+31663과 격리309286+313370+350998이다.
  실제 Git/module/ROOT 신원 및 byte 보존을 확인한 fixture 증거이며 현재 옛 CLI의
  PASS나 엔진/화면/자연 입력/전체240주 관찰이 아니다.
- clean source에 비저자 판정을 결속한 뒤에도 위 실패가 남으면 HOLD다.
  362→363 뒤 필요한 해당 검사와351/361 후속 검수를 수행한다.
  새 범위는363 사양으로 선언만 했고 구현0. 규범은 일회성/기존 WORK_UNIT·I18N,
  새 상시 규칙0. 본편/새package HOLD·원어민/인간/물리 OPEN·외부 출시0 유지.

## 2026-09-28 착수 — 파일 소유와 검증

- 기준 `c580791ec534d82632a230bd77d14f5b99a6f041`, clean main. 현재 작업 프로필은
  현지화의 원문/수용 기록 검증이며 새 번역·빌드·출시 검수로 확대하지 않는다.
- `/root/compat357`: 새 `tools/order351_source_compat.py` 한 파일.
- `/root/screen_path_probe`: 아래 기존 소비자5 파일만. 옛350 별칭·corpus는
  그대로 두고 현재351 입구와 추가 반례를 분리한다.
- root: `tools/audit_scope.json`, `tools/audit.sh`와 아래 마감 문서/원장.
  `/root/r3_route_probe`: 비저자 독립 검수, 제품/검사 저작 없이 전수 경계 검토.
- private 실행 증거는 `.git/full-game-localization/order361-*`에 보존한다.
  소스 동결 후 normal/self/historical 및 명시 차선의 실제 결과를 기록하며
  선행351 화면64상태/70PNG를 재실행하지 않는다. 새 Git 검증·코드 변경이므로
  그 표적 회귀는 새로 실행한다. 실패/재실행은 별개로 보존한다.
- 마감은 이 사양·351 후속 상태·큐2·WORK_LOG·CLAUDE 현재행·생성 STATUS,
  새 `docs/agent_reviews/ORDER-361.json`와 판정 원장 append만 소유한다.
  현재351 HOLD와362 미착수, 인간 원장·공개 후보·제품12파일은 보존한다.
- 이 선언은 일회성이고 기존 WORK_UNIT/I18N 규칙을 적용한다. 독립 최종 검수는
  실제 clean 소스 신원에 결속하며 자동 PASS를 원어민/인간/물리 관찰로 바꾸지 않는다.

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
