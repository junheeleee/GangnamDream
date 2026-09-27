# Active Queue Spec: ORDER-357

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-357 [P1·검증] 2장 원고 수리의 현재 소스와 역사 비교를 연결한다

2026-09-27 Codex 발행. 313/356의 원고20문구·기존 번역receipt9 재결속 뒤
실제 정적9검사 중6 PASS/3 FAIL이다. 새 문장을 과거 문장으로 되돌리거나 기존 승인
핀을 덮지 않고, 현재 원고 입구와 역사 비교의 exact 역변환만 수리하는 한 배치다.
**2026-09-27 착수 — 만지는 파일: 아래 도구8개와 명시한 마감 기록만.**

## 착수 소유 분할

- `compat357`: 새 `tools/order313_source_compat.py` 한 파일. 현재 admission·역사 역합성·
  원형 모듈 보존·회귀와 격리된 원형309 corpus 실행을 소유한다.
- `consumers357`: 아래 기존 소비자5개만. 기존 API에 호환되는 새 모듈을 소비하고
  필요한 index/raw binding·합집합·실제 양성 관측을 수리한다.
- root: `tools/audit_scope.json`·`tools/audit.sh` 두 파일, private `order357-*` 실행
  기록과 이미 명시한 마감 문서·새 판정만. 제품·옛 모듈은 바꾸지 않는다.
- `review357`: 원고/원형 모듈/새 도구·소비자·실제 증거의 비저자 읽기 전용 검수.
  구현 전 API·위험 검토와 구현 후 source-bound 독립 판정을 분리한다.
- 313의6 PASS/3 FAIL·독립HOLD와356 HOLD를 보존한다. 새 표적 차선 검증 뒤에도
  각각의 후속 독립 판정 전에는 완료로 올리지 않는다. 작업 지시는 일회성이다.

## 깊이 3문

1. 왜 필요한가: 수리된 M14·M24 문장이 현재 guard와 과거 전량 지문 비교에서 거절된다.
2. 무엇을 보존하는가: 원고20·receipt9, 기존 선택/상태와 옛 승인·실패 원문 전체.
3. 무엇과 경쟁하는가: 3장 새 집필 전에 2장 수리의 적용 검증을 닫는다. 출시 판정이 아니다.

## 입력과 불변 경계

- 실제 전후 제품: `43f76f1bcd25665e765a7ddfff232020d837ca4f` →
  `ac02dbc6a18126dda25e8fea8562faff18c1a365`; 후자는 8제품파일만 바꾼 직계 자식이다.
- 전체 현재 guard는 7 JSON/20 text leaf와 ledger1/receipt9, 공식40299·b137→139다.
  313은15/6, 356은5/3이며 새 번역0이다. 두 오더의 별도 이력/receipt를 구분한다.
- 역사 비교에만 역투영할 경계는 **KO/EN4파일/11leaf**:
  KO arc_events network/visit 기본 description·visit 조건부 description(3),
  EN arc_events 같은3+두 choice text(5), EN arc_midgame medication description/
  선택1 result_text(2), EN arc_daeun fork 선택2 result_text(1).
  JA/CN/TW9leaf·현재 receipt는 옛 번역 보고로 역투영하지 않는다.
- 순서는 current313/356 admission → 정확한 위 역변환 → 기존309/316/310/305 체인이다.
  이전 모듈4개·상수·fixture·옛 공개manifest·인간/agent 과거 판정은 불변이다.
  rollback/혼합/부분/이웃 문구·receipt 변조는 live source로 허용하지 않는다.
- 현재 guard 합집합은 기존15+새8의19경로, year5 역사 경로 합집합은 기존4+새4의7경로다.
  둘 다 겹치는 EN arc_midgame을 한 번만 세며 과거 Hyunsu/core 보호를 빠뜨리지 않는다.

## 구현 소유 예정 (선언 후)

- 새 `tools/order313_source_compat.py`: 두 unit의 전후 raw/Git proof·leaf·receipt 경계,
  현재입구/역사 view 분리, 정상/변조 회귀. 증거는 private `order357-*`다.
- 기존 소비자5: `tools/full_body_translation_scope.py`,
  `tools/story_graph_contract_audit.py`, `tools/chapter5_human_reject_audit.py`,
  `tools/year5_reference_route_audit.py`, `tools/chapter1_core_loop_v2_causal_ledger_check.py`.
  full-body의 실제 보고는 현재 텍스트를 유지하며 비교용 post-305 의미를 보존한다.
  graph의 raw/indexed binding은 EN arc_daeun도 결속한다. year5 immutable155 경계는
  이전309와 새 경로 합집합 전체 역합성 바이트가 일치할 때만 인정한다. 파일명 면제 금지.
  chapter1의 직접310 raw 입구도 새 admission 뒤 기존 비교로 연결한다.
- `tools/audit_scope.json`·`tools/audit.sh`: 새 gate/명시 `chapter2-prose-source-compat`
  차선만 연결한다. 예전 차선 의미를 넓히거나 기존 검사를 제거하지 않는다.
- root 마감: 이 사양/313·356 후속 결과/두 큐/WORK_LOG/생성STATUS/CLAUDE 현재 한 행,
  새 agent판정과 `docs/agent_reviews/ORDER-357.json`·313/356 후속 보고.
  원고/locale/receipt/런타임/project/인간·공개manifest는 비소유다.

## 완료 증거

- 새 exact admission·rollback/혼합/이웃/receipt/Git-proof 음성검사,
  이전305/310/316/309 역사 자체 검사 corpus, 다섯 소비자 normal/self-test,
  localization receipt·KO/EN 구조/누출·story consistency·선택기·문서/큐를
  정확 경로8제품+8도구에 한정한 명시 차선으로 실행한다.
- 기존313 정적9개 **6 PASS/3 FAIL**을 보존한다. 실제 실패는 full-body63 중6실패,
  graph4오류,309guard286 corpus의 live admission 실패다. 선택만 한79개 전체나
  선택된 엔진검사·240주·화면·입력·원어민·인간·물리·package 실행으로 바꾸지 않는다.
- clean source/실행한 증거 SHA를 직접 읽은 비저자 판정 뒤 313·356도 각 후속 판정한다.
  자동 게이트는 계약 증거이지 재미·깊이·문체나 사람 판정이 아니다. 본편/새package HOLD.
- 이 작업 지시는 일회성이며 기존 I18N·WORK_UNIT을 적용한다.

### 구현 전 읽기 전용 대조로 확인한 역사 검사 경계

- 기존309 `historical_self_test()`는305/310/316의301경우만 실행한다.309 자체286을
  포함했다고 보고하지 않는다.309 `self_test()`는 옛 live입구 양성검사를 포함하므로
  최신 원문에서 그대로 통과시킬 수 없다. 기존 직접CLI 실패도 숨기지 않는다.
- 새 최신 admission 뒤 원형301을 실행하는 것과, immutable pre313 `43f76f1`의
  old309 LIVE_PATHS15 및 원형 모듈4개를 검증한 격리 root/subprocess에서 원형309의
  286을 실행하는 것을 분리한다. 실제 구현 때 필요한 import 의존도 정확히 고정한다.
  예상 역사587은 아직 미실행이며 함수/핀/양성assertion 수정·실패 필터·mock 우회 금지다.
- 기존 audit.sh/옛 차선의 old309 현재 입구가 최신 바이트를 거절하는 의미는 보존한다.
  새 명시 차선의 좁은 결과를 옛 직접CLI나 전체 shell PASS로 바꾸지 않는다.
