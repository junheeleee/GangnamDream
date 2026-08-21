# Active Queue Spec: ORDER-121

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-121 [P0·CI/생명주기] author-only 원고와 shipping corpus를 기계적으로 분리한다

**착수 선언 (2026-08-22):** GitHub Actions run `32490647155`와 같은 리비전의
로컬 감사를 비교했다. ORDER-119 전후의 `audit.py` 출력은 byte-exact이고,
정적 job의 158 errors는 2026-08-18 원고 배치에서 누적된 비도달 root 154건,
그 선택이 만든 `inert_events 0→121` 1건, dormant year5 kernel의 Variant 추론
3건이다. `tools/debt_baseline.json`을 121로 올리거나 미도달 원고에 가짜 effect를
붙이지 않는다.

이 오더는 비도달 155편을 package에서 지우지 않고 `packaged 1758 / shipping 1603 /
author-only 155`로 분리한다. 이 lifecycle 오분류가 직접 깨뜨린 정적 감사·event
director·visual/audio/direction catalog와 release inventory를 함께 고친다.
화면·페이싱·산문·Chapter 1의 별도 실패는 여기서 통과했다고 주장하지 않고 다음
exact-scope CI 복구 오더가 소유한다. ORDER-119도 전체 audit와 GitHub CI가 green이
되기 전에는 닫지 않는다.

## 깊이 3문

1. 155편은 실행을 빼먹은 shipping 사건이 아니라, archived ORDER-104~113이
   `writer/effect/flag/follow-up 0`과 별도 이관을 명시한 reference 원고다. 실제
   제품 GDScript의 ID literal 진입과 non-author 사건의 follow-up 진입은 모두 0이다.
2. 기존 127편에는 `author_only` 태그가 있으나 28편은 archived spec에만 상태가
   남아 있다. 사건 JSON과 year5 보호 기준을 다시 쓰지 않고 새 machine ledger가
   exact 155 ID를 소유한다. 면제는 숫자형 `weight=0`, `hidden=true`, 정확한
   `conditions={min_turn:9999}`와 제품 진입 0을 모두 만족할 때만 성립한다.
3. package inventory는 1758편을 계속 세고 shipping inventory만 155편을 뺀다.
   커널 세 줄은 의미를 바꾸지 않는 Dictionary 타입 표기 수리이며, 보호된 반려
   R1a snapshot·R1b HOLD·제품 consumer 0은 그대로 둔다.

## 배치 — 정확히 15단위

1. exact 155 ID와 정렬 digest를 가진 `event_lifecycle` machine ledger를 만든다.
2. 공통 helper가 ledger와 KO 사건을 읽어 exact dormant metadata를 검사한다.
3. 제품 GDScript literal, non-author follow-up/deferred follow-up, thoughts unlock,
   demo core loop existing roots, event director와 release inventory의 실행 ID 진입을 검사한다.
4. story map의 planned/needs-rule reference와 invalidated year5 QA reference는 제품
   진입으로 오인하지 않는다. 실행 진입 정본에 들어오면 별도 ingress 검사가 실패한다.
5. `audit.py`의 dead-event 검사가 유효 author-only만 별도 lifecycle로 분리한다.
6. `audit.py`의 inert-event 래칫도 같은 검증 집합만 제외하고 baseline 0을 유지한다.
7. 메타 필드 하나 변조, ledger 누락/중복/hash drift, 제품 literal 진입,
   live follow-up·thoughts·demo/director/release 진입을 각각 거부하는 self-test를 둔다.
8. event director가 shipping 1603만 등록 계약과 대조하게 한다.
9. visual/audio/direction catalog가 같은 shipping set을 공유하고 별도 manifest는 늘리지 않는다.
10. release inventory는 all-resources 1758과 shipping 1603을 둘 다 검증한다.
11. 기존 9개 M1M6 raster와 현 content-rating 실측을 package ledger/report에 정직하게 반영한다.
12. year5 kernel의 `_lookup()` 결과 세 곳을 명시적 `Dictionary`로 선언한다.
13. shipping `arc_final_countdown` 세 산문 변형에 실제 존재하는 음악 시작 문단을 고정한다.
14. release tool/ledger와 기존 사건 source를 읽는 Chapter 1 ledger/checker만 현재 바이트에 재고정한다.
15. exact-scope lane과 helper self-test를 등록하고 정적 GitHub job의 story-map/audit/balance를 모두 green으로 만든다.

## 파일 소유권 — 정확히 25개

- `content/meta/event_lifecycle.json`
- `tools/event_lifecycle.py`
- `tools/audit.py`
- `tools/event_director_audit.py`
- `tools/event_visual_contract_check.py`
- `tools/scene_audio_catalog.py`
- `tools/scene_direction_catalog.py`
- `tools/full_run_direction_audit.py`
- `tools/release_content_inventory.py`
- `content/meta/release_content_inventory.json`
- `docs/CONTENT_RATING_INVENTORY.md`
- `assets/scene_audio_manifest.json`
- `tools/audit.sh`
- `tools/audit_scope.json`
- `tools/year5_reference_route_audit.py`
- `systems/Year5ReferenceRouteKernel.gd`
- `content/meta/chapter1_core_loop_v2_causal_ledger.json`
- `tools/chapter1_core_loop_v2_causal_ledger_check.py`
- `CLAUDE.md`
- `docs/CODEX_QUEUE.md`
- `docs/queue_active/ORDER-121.md`
- `docs/queue_archive/ORDER-121.md`
- `docs/queue_archive/CODEX_QUEUE_2026-08.md`
- `docs/WORK_LOG.md`
- `docs/STATUS.md`

`project.godot`, KO/EN 사건 파일, 원고 문구, effects/flags/follow-up, 밸런스,
`tools/debt_baseline.json`, story map, year5 manifest, runtime dispatcher와
save는 범위 밖이다.

**범위 보정 (2026-08-22):** exact 155 ID를 소유하는 새 lifecycle 원장을 기존
Year 5 감사기가 제품 consumer로 오인한다. ID를 숨기지 않고, 감사기가 이 정확한
비실행 원장만 제외하면서 제품 코드의 원장 로드는 계속 거부하도록
`tools/year5_reference_route_audit.py` 한 파일을 구현 전에 범위에 추가했다.

## 완료·판정

- L1: helper direct/self-test, `audit.py` ERROR 0, story map self-test, year5
  direct/self-test, Chapter 1 direct/self-test, 여섯 shipping consumer direct/self-test,
  scene audio contract,
  Godot kernel compile,
  `audit_select --verify`, context/queue/dashboard, strict JSON, diff-check.
- 정적 CI: GitHub의 `story_map_audit.py`, `audit.py`, `balance_check.py` 세 단계가
  같은 commit에서 모두 green이어야 한다.
- L2: declared/exempt/product-ingress가 `155/155/0`, packaged/shipping이
  `1758/1603`, live inert baseline이 0인지 독립 재검한다. 모든 사건 JSON과 기존
  audio/visual/direction manifest는 기준 commit과 byte-exact여야 한다.
- 이 배치가 전체 `audit.sh` green을 뜻하지 않는다. 남은 실패 목록과 기준 commit을
  완료 기록에 그대로 넘기며, 그 후속 복구와 ORDER-119 closure 전까지 CI 전체는 OPEN이다.

## 정본·일회성 판정

- `author_only`는 패키지에는 있으나 현재 제품에서 비도달인 reference 원고이며,
  활성화하려면 태그 제거와 실제 ingress 계약을 함께 갱신한다는 규칙은 계속 유효하다.
  완료 시 `CLAUDE.md`의 사건 생명주기 절에 한 번만 승격한다.
- 정확한 155/28 수치, 158건 분해와 GitHub run ID는 이 복구의 일회성 증거다.
