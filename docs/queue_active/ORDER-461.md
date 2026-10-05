# ORDER-461 — 한 번의 번역 원문 비교에서 홀덤 이력 증명 중복을 줄인다

#### [~] ORDER-461 [P1·검수 비용] 동일 matcher 안13중복→1증명

**[~] 착수 — 2026-10-05.** 사용자 효율적 검수 지시에 따라 실제 기본 full-body
688.315초 비용을 조사했다. 한 source matcher에서 Holdem wrapper13개가 각각
동일13단계 증명을 반복한다. 정적 계수는169단계/390Git호출/1014객체요청이며,
전체688초 중 기여 시간은 아직 계측하지 않았다. 완료458~460을 다시 수리하지 않는다.

## 범위·소유

- claude_handoff_review: `tools/holdem_money_history.py`만. 현재455의13단계 증명에
  한정한 private ContextVar scope와 immutable predecessor tuple 재사용을 구현한다.
  `_holdem_exact_stage_chain` 본문·모든 pin/inverse·과거 API 결과는 그대로 둔다.
- root: `tools/ui_translation_append.py`의 최외곽 `_source_manifest_matches`를
  한 호출 scope로 감싸는 얇은 연결, `tools/audit_scope.json`의 새 focused 등록,
  CLAUDE·큐/L3·이 사양/보관·WORK_LOG·생성STATUS·판정원장.
- receipt_tests392: 새 `tools/holdem_manifest_proof_scope_self_test.py`만.
  실제 고정13단계 한 번과 작은 합성 boundary/실패/누락 반례를 구분한다.
- independent392: 위 세 코드 파일과 실제 결과를 읽고 마지막
  `docs/agent_reviews/ORDER-461.json`만 작성한다. 코드 저작과 최종판정을 분리한다.
- 프로젝트 import·검사·엔진은 root만 실행한다. 제품·원고·번역·receipt·human·
  공개 package·365·full-body·collector·current_proof/validate_history 본문 변경0이다.

## 정확한 재사용 경계

하나의 matcher 호출만 scope다. 다음 manifest/다음 호출은 반드시 새 증명을 한다.
matcher boolean/성공·실패 판정의 캐시, whole-run/LRU/disk cache는 금지한다.
성공한13단계의 immutable bytes tuple만 공유하고 매 재사용에서 root/exact raw/
HEAD/disk/stage pin·함수 identity·inverse 설정을 대조한다. 달라지면 fail-closed이며 자동 갱신하지
않는다. 실패한 증명은 저장하지 않는다. 정상·예외 종료 모두 finally로 context를
복원하고 중첩 호출은 바깥 값을 오염시키지 않는다. 현재원장 exact50·각 header와
원문 census·원래 matcher 위임/허용/거부 의미는 유지한다.

## 검증·완료

1. source 구조/구문·등록·선언범위와 비저자 사전읽기. 원체인/고정pin/inverse 불변 대조.
2. 새 focused: scope 안13predecessor의 원래 결과/전체증명1회, scope 밖/다음scope의
   fresh 재증명; raw/HEAD/disk/root/stage/함수 변이, 첫/후속실패와 중첩reset,
   반환 tuple/bytes 불변성, 원 matcher의 허용/거부 결과 보존. 실제/합성 계수 분리.
3. 깨끗한 새 후보에서 기본 full-body1회. source50와 원장/제품/실제player34/seed2+
   W195 checkpoint 전후 보존, 성공marker·exit·stderr·실행시간을 기록한다.
   선행688.315초와 현재값은 실행별 비용이며 통제된 속도 A/B나13배 향상으로 부르지 않는다.
4. `holdem-manifest-proof-scope` 명시 차선은 새 focused/등록과 always context/queue만
   고르며 기본 full-body는 위3의 별도1회로 중복하지 않는다. 판정원장/diff·생성STATUS,
   비저자 한정판정 후 main 커밋/푸시.
   원458 화면·공식교정·과거 self-test 전량·standalone365·엔진·240주·302 빌드 반복0.

없애면 검수 안전성이 아니라 불필요한 중복 비용이 줄어야 한다. 선택/경제·24주 뒤
플레이 상태는 불변이며 경쟁하는 것은 같은 개발 시간이다. 이 단위는 검수도구 비용만
소유하고 실제457·M60/후일담/Property·302 successor·출시HOLD는 닫지 않는다.
규범 판정: 파일·단일 scope·표적 실행 지시는 **일회성**. 기존 WORK_UNIT 적용,
새 정본 승격0이며 자동PASS는 재미·인간·원어민·물리패드·출시 GO가 아니다.

## 구현 증거 — 최종 수용 전

- history/append 원prefix 보존, EOF99/15행. 비저자 사전읽기 차단0이며 inverse literal
  전역변이 반례를 반영했다. 제품·번역·365·full-body·current_proof/validate_history 변경0.
- 명시 차선4 PASS: focused221/historical0·실제chain1/78요청/13predecessor,
  나머지 합성 또는 원문보존. 등록195·context·queue79/76 PASS다.
- 기본 full-body 현재50 수용·비저자 최종판정은 구현 clean commit 뒤 실행한다.
