# Active Queue Spec: ORDER-355

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-355 [P1·검증] 1장 원고 수리의 현재 소스와 역사 비교를 분리한다

2026-09-27 Codex 발행. [309](ORDER-309.md)의 원고17/기존receipt9 수리는 적합하지만
실제 정적 검사4개가 새 원문을 거절했다. 원고를 되돌리거나 옛 승인 핀을 덮는 대신
확정된 후속 변경만 검증하는 한 배치다. **2026-09-27 착수**하며 아래 범위만 소유한다.
선언 커밋 뒤 구현한다. 사용자 재서명 대기는 아니다.

## 깊이 3문

1. 왜 필요한가: 정상 원고 수리가 과거 전체파일/객체 비교에서 불명확한 차이로 남는다.
2. 무엇을 보존하는가: 플레이어 문장17·선택/상태0변경, 현재 번역receipt9와 과거 승인.
3. 무엇과 경쟁하는가: R2의 새 원고 전에309 자체 검증을 닫는다. 전역 감사/출시가 아니다.

## 확정 입력과 정확한 경계

- 전후 제품 commit: `7717fd7f72b04c40d684a8c27c6e93cc546bda4c` →
  `506e4c8ff6e4bf9265706845b4994b6203a05533`. product JSON7/17leaf와 ledger1을
  전체 raw hash·Git 객체·정확 leaf 차이로 먼저 결속한다. 이후 CLAUDE 수정은 제품 차이가 아니다.
- 역사 비교에서만 역투영할 모집단은 **4파일/8leaf**:
  KO·EN `arc_hyunsu.json` 각 pass/fail description·fail 선택2 result_text(6),
  EN `arc_midgame.json` goodbye 선택3 result_text(1),
  EN `core_loop_v2_events.json` reunion echo 선택1 result_text(1).
- JA/CN/TW3파일9leaf와 현재 source/target receipt9는 **역투영하지 않는다**.
  실제 보고/번역 inventory는 새 원문을 보여주고 역사 비교 view만 명시적으로 구분한다.
- 현재 raw admission → exact309 역변환 → 기존316/310/305 및 해당 역사 체인을 따른다.
  옛 module/상수/fixture·공개manifest·인간 판정은 불변이다. rollback은 live source로 받지 않는다.
- year5의155 파일 목록 비교는 단순 파일명 제외가 아니다. admitted 후속 파일의 전체
  역합성 바이트가 해당 immutable155 baseline과 같을 때만 설명된 차이로 처리한다.

## 선언 파일 소유

- 새 `tools/order309_source_compat.py` — 위 경계·Git proof·raw/payload/hash view·음성 회귀.
- `tools/full_body_translation_scope.py`, `tools/story_graph_contract_audit.py`,
  `tools/chapter5_human_reject_audit.py`, `tools/year5_reference_route_audit.py`,
  `tools/chapter1_core_loop_v2_causal_ledger_check.py` — 실제 live 경계와 역사 비교 호출부만.
- `tools/audit_scope.json` — 새 live gate와 원래 역사 self-test의 명시 연결. 기존 회귀를
  빠뜨리거나 일반 차선을 넓혀 실패를 감추지 않는다.
- `tools/audit.sh` — 필요 시 새 gate 명령·exit 집계만 추가한다. 전체 shell 실행·엔진 변경0.
- root 마감: 이 사양/309 후속 결과, 두 큐, WORK_LOG/STATUS, CLAUDE 현재 한 행,
  agent ledger 새355 및309 후속 판정, `docs/agent_reviews/ORDER-355.json`·`ORDER-309-followup.json`.
  private 증거는 `.git/full-game-localization/order355-*`로 분리한다.
- 원고/locale/receipt/런타임/인간/project/기존305·310·316 module은 비소유다.

### 실행 분할과 적용 차선 (일회성)

- `header_layout`: 새 `tools/order309_source_compat.py`와 자체 음성/역사 회귀.
- `screen_path_probe`: `tools/year5_reference_route_audit.py` 한 파일의 연결과 표적 검증.
- root: 나머지 소비자4·registry·필요 시 audit.sh·위에 선언한 마감 문서/증거.
- `screen_independent_review`: 비저자 독립 검수, 제품/도구 편집 없음.
- 적용 차선은 원고309의7 JSON·ledger1과 이번 검증 도구8파일에만 한정한다.
  current admission/self-test, 원래305/310/316 역사 corpus, 다섯 소비자 normal/self-test,
  localization receipt self-test·KO/EN 구조/누출·audit.py·선택기·문서/큐 검사를 실행한다.
  이번 변경은 게임/엔진/입력 바이트0이므로 엔진·240주·75개 전체 검사를 대신 주장하지 않는다.
  기존 선택기 일반 차선은 완화하지 않고 새 호환 검사만 명시 등록한다.

## 완료 게이트

- 현재7/17·receipt9, 역사4/8을 정확 결속한다. 8leaf/이웃/잘못된경로·hash·rollback·
  Git proof 부재/손상·raw와 관측 불일치를 거절하고, 현재 receipt를 역사값으로 바꾸지 않는다.
- 기존305/310/316 회귀 함수를 보존하고 새 admission 뒤 해당 역사 corpus를 실행한다.
  옛310/316 직접 CLI의 live 의미와 별도로 보고하며, 과거 실패 파일을 덮지 않는다.
- 다섯 실제 소비자 경계를 표적 검증하고309의 원래4실패가 새 경계에서 해소됐는지 확인한다.
  전역 hash 재생성·baseline 완화·검사 제거로 PASS를 만들지 않는다.
- 선택기 등록/변경범위·문서/큐·diff 검사와 비저자 최종 source 결속. 필요한 적용 차선을
  구체적으로 선언하고 전체75검사·240주·엔진을 실행했다고 대신 주장하지 않는다.
- 355 완료만으로309를 닫지 않는다.309 전체의 해당 검증 결과와 독립 후속 판정이 필요하다.
- 기존354 15PASS/7FAIL·사람OPEN45·공개GO1·본편/새package HOLD 보존. 원어민/물리/출시GO0.

확인된 실패 원문은 `.git/full-game-localization/order309-static-{03,04,05,08}.json`,
읽기 전용 영향 계획은 `order309-compat-followup-plan.json`이다. 새 규범은 기존
WORK_UNIT/I18N 보호 원칙 적용, 정확 소유·실행 지시는 일회성이다.
