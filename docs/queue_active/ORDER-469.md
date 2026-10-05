# ORDER-469 — 4장 지연 연인 변형6개의 비도달 정렬

#### [~] ORDER-469 [P1·사용자 지시] 자연 경로에 없는 지연 연인 변형을 author_only로 보존한다

**착수 — 2026-10-05.** PR31 들이기 [468](../queue_archive/ORDER-468.md) 뒤 실행하는
사용자 후속7k의 첫 독립 단위다. 기준 main `2f06da6`에서 read-only 영향 조사를 마쳤다.
아래 소유 범위를 선언 커밋으로 먼저 고정하고 구현한다. 아직 실행 검증 결과는 없다.

## 근거와 완결 경계

- 사용자 직접 지시: PR31 이후 `CODEX_RETURN_PLAN_2026-09-30.md`의7k를 별도 오더로 수행.
- 정본: [DECISIONS](../DECISIONS.md) 2026-10-01의 사용자 승인.
- 대상6개는 4장153~190주에 연인을 전제하지만 지연 연애의 자연 생산자는193주 이후다.
  결정문 당시의169~190 표기와 달리 현재 Main의 실제6슬롯은153/164/167/177/181/190이다.
  원고를 지우거나 4장 연애를 새로 발명하지 않고 패키지에 비도달 reference로 보존한다.
- 한 판정 단위는 **Main 분기·사건 배정 목록·생명주기·검사·현재 심의 목록의 동시 정렬**이다.
  본문·번역·효과·플래그·선택 인덱스는 그대로 두며 다은/무연애 경로를 보존한다.

## 정확한 대상

1. `arc_y4_three_promises_jiyeon_and_deal`
2. `arc_y4_body_witness_jiyeon`
3. `arc_y4_family_partner_collision_jiyeon`
4. `arc_y4_borrowed_name_jiyeon`
5. `arc_y4_bill_night_jiyeon`
6. `arc_y4_year_close_jiyeon`

앞5개는 `content/events/arc_chapter_themes.json`, 마지막은 `content/events/arc_year_close.json`이다.
read-only 조사에서 모두 이미 `weight=0`, `hidden=true`, `conditions={min_turn:9999}`였다.
기존 원고·조건 바이트는 필요 없이 다시 쓰지 않는다. 실제 결함은 Main6호출과
`content/meta/event_director.json`의 `commitment_event_owners`에도 제품 연결이 남은 점이다.

## 깊이 3문

1. 이 수리를 빼면 같은 장면의 자연 도달성과 테스트로 주입한 연애가 섞여 정본을 잘못 승인한다.
2. 정상 저장의 24주 뒤 선택 상태는 바꾸지 않는다. 비정상/주입 지연 상태가4장에 있어도
   지연 연인을 전제하지 않는 기존 unattached 분기로 보내며5장 연애 생산자는 보존한다.
3. 같은 월 슬롯에서 기존 다은/무연애 변형과 경쟁한다. 신규 선택·보상은 만들지 않는다.

## 선언 파일 소유와 보존선

- pr31_main_compat: `scenes/MainGame.gd`의 `_chapter_four_relationship_event_id` 및6호출,
  `tools/arc_flow_sim.py`의 같은 selector와6호출,
  신규 `tools/ChapterFourRelationshipCheck.gd`, `tools/ChapterFourRelationshipCheck.tscn`.
  런타임 동결 뒤 `tools/main_game_locale_history.py`, `tools/ja_translation_pipeline.py`의
  정확한 Main/source 위치 후속 연결도 이 소유자가 맡는다.
- root metadata: `content/meta/event_director.json`, `content/meta/event_lifecycle.json`,
  `content/meta/narrative_spine.json`, `content/meta/exposed_event_state_contracts.json`,
  `content/meta/release_content_inventory.json`,
  생성 `docs/CONTENT_RATING_INVENTORY.md`.
- root 검사: `tools/chapter4_causal_route_audit.py`, `tools/exposed_state_consistency_audit.py`,
  `tools/narrative_spine_audit.py`, `tools/audit_scope.json` 등록.
  shared2의 YEAR5 실제37실패 중 새4는 이 단위의 exposed/spine raw 변경을 과거와
  바로 비교한 결함이다. `tools/year5_reference_route_audit.py`의 관측 해시 경계와
  표적 자체검사를 root 소유로 추가 선언한다. 실제469 Git/디스크 역상 증명 후 두
  메타 경로만 이전 관측값으로 연결하며, 이전 raw핀·기존33실패는 덮어쓰지 않는다.
  첫 표적 실행에서 `tools/event_lifecycle.py` 자체검사의105/1708 고정 기대값이 검출됐다.
  실제 검증된111/1702와 맞추는 한 줄만 root 소유로 추가 선언한다. 기존 음성27사례는 보존한다.
  `tools/event_director_audit.py`의 shipping 기대값1708도 실제1702로 맞추는 한 줄을
  추가 선언한다. 수집·도달 로직은 바꾸지 않는다.
- pr31_history_plan: 신규 `tools/order469_source_compat.py`,
  `tools/order469_source_compat_self_test.py`, 기존 `tools/pr31_intake_history.py`,
  `tools/pr31_intake_history_self_test.py`, `tools/ui_translation_append.py`,
  `tools/full_body_translation_scope.py`. 실제 제품 커밋·부모·파일 집합·역상을 증명하며
  기존 PR31 raw pin/e300 census/번역 수용 원장을 덮어쓰지 않는다.
- pr31_intake_review: 비저자 read-only 검수 및 `docs/agent_reviews/ORDER-469.json`만 소유.
  root만 프로젝트 도구·Godot를 실행한다. 에이전트는 소유 파일 수정과 stdlib/Git 조회만 한다.
  세션 중단 뒤 같은 소유를 각각 `order469_main`, `order469_history`, `order469_review`가
  인계했다. 파일 경계와 비저자 분리는 그대로다.
- `tools/HiddenFeatureCheck.gd`에는 현재 목표6개 ID가 없으며 지연 연애 주입은5장 엔딩용이다.
  이 파일은 read-only 보존한다. 사용자 작업표의 당시 예상과 현재 실물이 다르므로
  무관한5장 주입을 없애지 않는다. 같은 이유로 목표 원고/오버레이도 재작성하지 않는다.
- Main literal6개 제거는 노출계약의 해당6행과 root/exposed census에도 영향을 준다.
  현재 예상386→380/537→531은 실제 collector 대조 후 결속할 값이지 이미 실행한 결과가 아니다.
- ledger-only6개 추가 시 예상 shipping1708→1702, author_only105→111, ledger-only8→14이며
  packaged1813/tagged97은 보존한다. 최종 개수·해시는 실제 검사로 결속한다.
- release inventory의 현재 도달 예시 `tobacco_and_medicine_references`에 남은
  `arc_y4_three_promises_jiyeon_and_deal`도 실제 분류와 맞춘다. 패키지에 남은 원고의
  내용 사실을 삭제하거나 심의/법률 인증을 발급하는 변경이 아니다.
- `arc_flow_sim`의 같은 관계 selector/6호출과 `narrative_spine`의4장 live anchor6개도
  실제 제품 분기에 맞춘다. spine 감사의 지연 setup/boss 강제항목2개는 이 사용자 승인에
  한정해 정렬한다. story_map의 해당6참조는 `needs_rule` 비제품 참고이므로 보존한다.
- root 기록: 이 사양/큐·CLAUDE현재행·WORK_LOG·생성STATUS·`docs/agent_review_decisions.json`.
  제품/번역 원문 불변과 준비 컴포넌트64사례(6슬롯×8상태+우선분기16)를 표적 검증한다.
- 기존 raw/history pin을 새 값으로 덮어쓰거나 범용 hash 우회를 만들지 않는다. 실제 전이만
  좁혀 결속하며 Main/source consumer 지원이 필요하면 소유 경로를 먼저 선언한다.
- 금지: `project.godot`, 5언어 `arc_events.json`, 공개 패키지·사용자 저장·인간 원장.
  목표6개 산문/번역 원고·효과는 보존하며 번역 수용을 한 것으로 발급하지 않는다.

## 검증 계획

- 대상6개 packaged 보존·author_only 목록/수치/hash, 실제 product ingress0.
- Main6슬롯 × 다은/지연/없음/혼합·이별 flag의 실제 selector 표적 회귀. 준비된 컴포넌트와
  자연 플레이를 구분하고 pre-autoload 격리·보호 파일 전후 hash·Godot 오류 로그를 확인한다.
- W167의 아버지 약속 누락·W177의 거래 약속 누락 우선 분기는 그대로다. 다은 연애 flag가 있고
  이혼 flag가 없는 실제 Main 조건을 oracle로 삼고, `daeun_married`만으로 연인으로 만들지 않는다.
- Chapter4 causal route·event lifecycle·release inventory 및 영향받는 기존 엄격 이력 검사를
  표적 실행한다. 단순 전체 PASS가 아니라 baseline/new 실패를 분리한다.
- 정상 다은/무연애 선택·효과·후속, 지연5장 실제 생산자,5언어 본문/번역 바이트 불변을 대조한다.
- 비저자가 실제 원문·구현·검증 결과를 직접 보고 한정 판정한다. 원어민·인간/물리 입력·
  실제 렌더 미관찰을 유지하며 본편/출시 GO로 확대하지 않는다.

## 뒤따르는 별도 단위

이 단위 뒤 같은 사용자7k의 데모 계약 bundle을 먼저 선언한다:
`arc_jaehyuk_aftermath` 내부 경로명/선택사실(F1), `arc_daeun_later_echo` 함께하는 관계 조건과
삼각김밥(F9), `arc_jaehyuk_04b_counter` 해설 수리.5언어 `arc_events.json`은 정확한
`demo_localization_scope` successor와 함께만 바꾼다. F1은 과거 선택 사실이 없는 오래된
저장에서 visible choice0으로 멈추지 않는 중립 회복 경로도 같은 단위에서 설계·검증한다.
선택을 지어내거나 기존 선택 인덱스/회상 기록을 바꾸지 않는다.

그다음 `arc_36_unexpected_hand_person_deal`은 DECISIONS 2026-10-03대로 실제 다은
조건 DIK/야간진료 기본문·중립 선택/결과를5언어와 영수증까지 묶는다.
준비된2장 수첩·5장 '5년' 초안과 PR 검수에서 남긴 기존 엔딩 사실2건은 각각 뒤의 소단위다.
새로운 발견을 이6변형 정렬에 계속 붙이지 않는다.
