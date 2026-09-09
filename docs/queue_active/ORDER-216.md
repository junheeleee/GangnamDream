# Active Queue Spec: ORDER-216

> [~] 착수 — 만지는 파일: 아래 정확 소유 범위만.

#### [~] ORDER-216 [P0] 위임된 최종 판단과 인간 증거 분리

기준 main eb8f7aaa825491905294822c468b1f0820b9f345. 사용자 최신 전체판 번역·최종 검수 위임을 근거로 아래 사전 권고를 공식 실행 사양으로 채택한다. 사전 권고의 미선언 문구보다 이 선언이 우선한다.

## 깊이 3문

1. 원문 사실과 실제 검수 근거를 지켜 후속의 신뢰를 만든다.
2. 선택의 대가와 이전 판단의 한계를 시간이 흐른 뒤에도 보존한다.
3. 작업량이나 자동 통과를 작품 품질·관찰하지 않은 증거로 바꾸지 않는다.

## 결정과 경계

사용자 최신 지시: “전부 진행, 최종 검수 및 개선까지 전부 권한 넘김. 이제 사용자는
판단 안하고 Codex가 모든걸 담당해 계속 개선”. 게임 개발·품질 검수·내부 제품 판단의
권한 근거로 충분하다. 사용자의 추가 표본 선택/재서명을 진행의 필수 조건으로 두지
않는다. Codex가 분석·권고 결정·구현·독립 검수·수정·다음 오더를 책임진다.

이 위임은 실제 외부 출시/스토어 수정/금전 지출/법률 확답 권한을 자동으로 포함하지
않는다. 관찰하지 않은 원어민 독해·인간 실플레이·물리 패드 조작감도 만들어 내지
않는다. 권한이 생긴 것과 검수가 끝난 것은 다르므로 현재 제품 판정은 HOLD다.

**채택안:** docs/human_gates.json 전체 raw를 보존하고 NEW
docs/agent_review_decisions.json에 위임과 에이전트 최종 판정을 기록한다. 기존
human gate state/evidence/delegated_reviews/candidate를 옮기거나 다시 해석하지
않는다. 에이전트 최종 판정은 별도의 권한·후보·범위·관찰 방법·증거를 가진다.

## 단일 규칙 소유자

지속 규칙은 docs/WORK_UNIT.md의 판정/표본/연속 실행 절만 소유한다.
CLAUDE·큐·PROPOSALS·skill·최종 출시 감사 문서는 그 절을 참조하고 같은 규칙을
복제하지 않는다. 역사 원고·옛 오더의 GO/REJECT/사용자 표본 기록은 보존한다.

- L1 기계와 L2 저자 자가 검수는 그대로 분리한다.
- 작성자와 다른 에이전트가 source/실물/표본을 직접 읽는 최종 품질 검수를 둔다.
  저자의 자체 통과만으로 에이전트 최종 GO를 만들지 않는다.
- 기존 20단위/3표본 등은 추정값 표시를 유지한다. 표본은 독립 검수자가 봉인한
  모집단/seed/추출 방식으로 고르고, 실패 시 원래 같은 배치를 다시 검수한다.
- 인간 관찰은 실제 수행되었을 때만 별도 증거가 된다. 인간 증거 OPEN만을 이유로
  사용자 답변을 기다리지 않는다. Codex가 남은 검수·수리 또는 제한된 주장/범위를
  결정하고 계속 진행한다.
- 최신 제품의 실패·검수 미완료는 HOLD/REWORK다. 역사 후보 GO를 최신 후보에
  자동 승계하거나, 이번 권한 부여만으로 옛 HOLD/REJECT를 PASS로 바꾸지 않는다.

## 정확한 변경 소유 — 총 18경로

Poincare 구현 소유 6:

1. docs/agent_review_decisions.json — 신규 기계 원장
2. tools/human_gates.py — 별도 원장 validator/resolver 및 사실을 구분하는 출력
3. tools/agent_review_decisions_self_test.py — 신규 유한 회귀
4. tools/project_dashboard.py — 동일 resolver를 쓰는 Markdown/HTML 표시
5. docs/WORK_UNIT.md — 판정권/증거/연속 실행의 단일 정본
6. docs/MASTER_RELEASE_AUDIT.md — 현재 경계 및 Gate C의 위임 판정 참조만 정렬

ROOT 운영 소유 12:

7. CLAUDE.md
8. docs/DECISIONS.md
9. docs/CODEX_QUEUE.md
10. docs/CODEX_QUEUE_L3_PENDING.md
11. docs/WORK_LOG.md
12. docs/STATUS.md — 생성만
13. tools/audit_scope.json
14. docs/queue_active/ORDER-216.md
15. docs/queue_archive/ORDER-216.md
16. docs/PROPOSALS.md — 현재 위임 범위의 판정 절차를 WORK_UNIT로 참조하는 짧은 정렬
17. .codex/skills/gangnamdream-dev/SKILL.md — 현재 판정권은 WORK_UNIT를 따른다는 참조;
    인간 done 증거 엄격성은 유지하고 모든 OPEN이 작업 미완료라는 문장만 분리

PROPOSALS/skill은 최신 위임을 다시 사용자 승인 대기로 돌리지 않기 위한 참조 정렬이다.
context_manifest_check는 docs/**/*.md를 분류하므로 신규 JSON 때문에 document_groups를
늘릴 필요는 없다. JSON은 WORK_UNIT 링크와 새 validator/audit_scope가 소유한다.
queue_index/self 기존 parser를 변경하지 않는다. 기존 이어보기 행을 무더기 완료로
돌리지 않고, 각 후속 검수에서 실제 agent final 증거가 갖춰진 범위만 정리한다.

비소유: human_gates.json, 모든 KO/EN/JA/ZH 원고, portable/수용 원장, runtime,
project.godot, 공개 package/BUILD/manifest, 과거 판정 기록, 다른 감사/번역 가드.
214의 source/initial/target/수용과 독립이며 이 오더가 214 판정을 대신하지 않는다.

## 새 원장 schema 1 — 작은 별도 축

최상위 정확 키: schema_version, delegation, decisions. initial decisions는 []다.
유효한 현재 판정이 없으면 resolver가 HOLD를 반환하므로 가짜 현재 GO를 넣지 않는다.

delegation 정확 필드:

- id: 고유 고정 ID
- granted_at: 실제 사용자 지시 날짜 YYYY-MM-DD
- granted_by: user
- delegated_to: Codex
- source: 현재 사용자 대화의 정확 인용/추적 기록; 구현자가 승인했다고 쓰지 않음
- scopes: game_development, quality_review, internal_product_decision
- exclusions: external_publication, storefront_change, expenditure, legal_certification
- user_resign_required: false

decisions의 각 기록 정확 필드:

- id, delegation_id, decided_at, decided_by
- authority: user_delegated_agent_final 고정; decided_by=user 금지
- scope: work_unit 또는 internal_product; subject와 실제 검수 범위를 record에 명시
- subject: kind(source 또는 package), commit, tree, manifest_sha256
  - commit/tree는 full hash, 실제 Git commit의 tree와 일치해야 한다.
  - source는 manifest_sha256=null, package는 실제 manifest SHA-256 필수다.
  - package identity와 source checkout identity를 교차 대체하지 않는다.
- verdict: GO, HOLD, REWORK
- evidence: [{kind, path, sha256}] — GO는 비어 있을 수 없다.
  kind는 source_review/automated_contract/agent_render_observation/agent_runtime_observation.
  human/native/physical-user-feel 관찰 유형은 이 agent 원장에 허용하지 않는다.
- unobserved: 실제 안 본 범위를 명시한 문자열 배열; 원어민/인간/물리 조작감은
  그 증거가 없는 현재 판정에 계속 포함한다.
- record: 독립 검수자, 모집단·실제 읽은 범위, 방법, 결함과 수리, 한계, 판정 근거의
  저장소 내 증거 경로와 SHA-256. 인간 증거를 이 원장으로 발급하지 않는다고 명시.

구조 검사는 자유 산문의 진실까지 자동 증명하지 않는다. 실제 보고의 관찰/미관찰
구분은 독립 검수자가 확인한다. 기존 인간 원장에 실제 증거가 추가되는 미래 작업은
그 별도 소유 오더로 수행하며 이 schema를 통한 인간 gate 우회는 없다.

## validator와 표시의 좁은 구현

- 기존 load/load_ledger/validate_ledger/scope_blocks/open_gates/
  canonical_active_candidate의 인간 증거 의미와 본문 AST는 유지한다.
- 별도 load_agent_review_ledger, validate_agent_review_ledger,
  effective_agent_decision(subject, scope) helper를 추가한다. subject는 호출자가
  관측한 exact 입력이지 결정 기록 자체에서 역으로 만드는 expected가 아니다.
- 현재 subject와 kind/commit/tree/manifest/scope가 모두 같은 최신 유효 기록만
  효력이 있다. 이전 후보 기록은 역사로 남되 현재 GO로 계산하지 않는다.
- 뒤에 나온 HOLD/REWORK가 같은 후보의 이전 GO를 가린다. GO만 찾아 뒤로 건너뛰지
  않는다. 기록 ID 중복, 미지 권한, unknown key, 틀린 경로/해시, 혼합 후보는 실패다.
- 인간 원장 validation은 계속 인간 state/evidence만 판정한다. 별도 agent 원장
  validation 성공도 품질 GO가 아니다. 빈 decisions → 현재 agent HOLD가 정상이다.
- main/print_pending/dashboard는 ‘에이전트 최종 판정’, ‘인간 증거 상태’,
  ‘미관찰 한계’를 구분한다. Codex에게 위임된 범위에 ‘사용자 최종 GO 대기’를
  필수 다음 행동으로 출력하지 않는다. 과거 record 문자열은 고치지 않는다.
- Claude라는 표시 하드코딩은 실제 decided_by를 출력하도록 한다. 역사의 저자와
  실제 관찰 방법을 바꾸지 않는다. Markdown/HTML은 같은 helper의 결과를 렌더한다.
- current product는 HOLD/검수 미완료다. human open45/done1 통계는 그대로 노출한다.

## 보호 지문과 다른 감사 영향

현재 docs/human_gates.json: 103390 B /
6ab5c927c9f327aa2892c231d49fe144c1c154cb6069fc539f4f3f8e9c30c9f6.
gate46(open45/done1), delegated_reviews22(24가 아님), release_candidates5.
이 파일 전체 raw를 선언 전후 동일하게 유지한다. 과거 22개 판정의 상태·본문·순서도
자동으로 보존된다. story_demo의 실제 사용자 GO1과 원어민 OPEN3도 그대로다.

- release_content_inventory.py: 공개 candidate와 공개 4gate의 canonical row SHA를
  고정한다. 원래 rows를 보존하므로 이 감사 상수/원장을 변경할 필요가 없다.
- chapter5_human_reject_audit.py: 공개 candidate 신원, done/user_final evidence와
  package/product/manifest를 읽는다. 모두 그대로이며 도구 수정 불필요다.
- story_demo_package_audit.expected_density_contract: 명시한 revision의 Git blob으로
  human_gates_sha256을 비교한다. current 새 원장으로 역사 기대값을 재계산하지 않는다.
- build_story_demo_macos.sh: stage한 human_gates raw의 digest를 기록한다. 이번 오더는
  패키징을 실행하거나 역사 artifact manifest를 재발급하지 않는다.
- year5의 역사 보호표/원 manifest도 수정하지 않는다. 새 agent JSON은 런타임이나
  공개 export consumer로 자동 연결하지 않는다.

## 자체 유한 self-test (사전고정 후 구현)

최소 축을 named case로 고정한다. 사례 수를 목표로 범위를 늘리지 않는다.

1. 빈 decisions + 유효 위임 → validator PASS, effective HOLD, 사용자 재서명 요구 없음.
2. exact source 독립 검수 GO → agent GO; human open45/done1 및 old raw 그대로.
3. exact package GO와 source GO를 따로 허용하며 서로의 scope를 빌리지 못함.
4. commit/tree/manifest/kind/scope 각각 하나만 달라지면 현재 GO 불가.
5. 같은 후보 최신 HOLD/REWORK가 앞선 GO를 가림; 다른 후보 GO는 미적용 역사.
6. unknown/없는 delegation, duplicate decision ID, unknown fields, 빈 증거 GO 거부.
7. evidence/record 경로 이탈·없는 파일·sha drift 및 commit/tree 불일치 거부.
8. authority=user_final, decided_by=user, human/native/physical-user-feel 증거 kind 거부.
9. agent GO가 gate.state/evidence/과거 delegated_reviews/candidate를 바꾸지 않음.
10. 원 human validator의 done-without-evidence, wrong human authority, candidate
    mismatch 기존 거부를 보존. 새 agent GO를 넣어도 이 실패를 가리지 않음.
11. 외부 출시/스토어/금전/법률 인증 scope 요청 거부; 게임 내부 판정과 혼합 금지.
12. CLI/Markdown/HTML 모두 실제 reviewer·agent verdict·human evidence 상태·미관찰
    범위를 구분. 과거 Claude 기록을 Codex 인간 관찰로 다시 표시하지 않음.
13. 공개 GO1/원어민 OPEN3/candidate5 및 human ledger 전체 raw 원형 검사.
14. 기존 queue_index_self_test 전체 보존; 기존 queue 행의 갑작스러운 일괄 완료 0.

ROOT 독립 입력은 자체 fixture와 분모를 분리한다. schema PASS를 제품 GO로 세지 않는다.

## 선언 뒤 표적 검증/완료

신규 self, human_gates, 기존 queue_index_self_test, dashboard --check,
context/queue/index/audit_select --verify/diff를 등록 차선에서 실행한다.
공개 보호 소비자의 표적 검사로 위 원형을 확인하되 전량 번역 L1/전체 audit/Godot/
실플레이를 이 운영 schema 작업에서 반복하지 않는다. --list와 실제 출력은 별도 기록한다.

보존 proof는 선언 전후 human raw, 공개 candidate/gates canonical hash, 공개 표시4,
year5 manifest, portable, KO/EN/runtime/project와 변경 exact17을 확인한다.
214 병렬 변경은 그 선언 scope로 분리하며 216 결과에 합산하지 않는다.
완료 기록에는 ‘미래 판정권 전환 완료 / 현제품 HOLD / 인간 증거 미관찰은 그대로’로
적는다. 이 오더의 절차·파일 소유는 일회성, 판정 규범은 WORK_UNIT로만 승격한다.

## 기록 예산 추가 소유

18. docs/history/WORK_LOG_2026-09-07_localization.md — ROOT는 완료210절 1371B/SHA cdc68f670e6d542f88ad82bef1d33339da36d298bdf9244941775d55b22496b1만 앞으로 raw 이동한다. 214의209절 이동과 구분하며 원형·기존 history 끝 LF를 보존한다.
