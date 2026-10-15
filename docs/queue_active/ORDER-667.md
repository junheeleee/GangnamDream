# ORDER-667 — 사실 수리 뒤 KO/EN 장면 감각 복원

#### [~] ORDER-667 [산문·정합] PR #33의 44곳을 한영으로 다시 읽는다 — 2026-10-15

사용자 직접 지시: PR #33 main 병합, 앞으로 사실 수리의 빈자리에 현재 장면의 감각 하나를 넣고 목록 44곳 KO/EN 재검토.
PR 병합 abda6a7. 모집단은 [검수 문서](../queue_backlog/PROSE_FLATTENING_REVIEW_2026-10-15.md)의 표 순서와 E절이다.

## 근거·깊이 3문

허위 과거를 지우는 과정에서 현재 장면의 긴장과 인물 행동까지 사라졌다.
통째 삭제하면 선행 선택이 남긴 몸·사물·침묵의 회수도 사라진다.
24주 뒤 상태 차이와 같은 자리의 경쟁 선택은 기존 flags/effects/독자가 소유하며 이번에는 산문만 고친다.
DIK는 실제 생산 선택을 대조한다. 목표 달성·생사·관계·주거를 새로 단정하지 않는다.

## 배치 A

표 1~22번 KO/EN 전수. 사실·장소·채널·인물의 지식은 유지하고, 추상 회상·부정 헤지로 채운 자리를 현재 장면의 감각·행동으로 고친다. 이미 구체성이 살아 있으면 유지 이유를 기록한다.

## 배치 B

표 23~44번 KO/EN 전수와 승인된 E절의 선택 text/result_text 및 final_gamble_taken 회수 각 한 쌍. E는 실제 거래·예약 기능을 만들지 않고 멈출 조건을 비운 계획 저장으로 맞춘다. 펜·종이와 폰의 동작이 혼선이면 같은 승인 행동 안에서 문장을 정렬한다.

## 정확한 파일 소유권

- content/events/ 및 content/events_en/의 arc_daeun_extension.json, arc_drama.json, arc_events.json, arc_hyunsu.json, arc_midgame.json, arc_year3_drama.json, arc_year_close.json: 표의 잎만, arc_midgame은 E 세 잎 추가.
- content/endings.json, content/endings_en.json: crypto_ghost description, empty_house description_if_known/father_passed만.
- docs/SCENE_TIER.md 공통 산문 계약에 지속 규칙 승격, docs/DECISIONS.md 이유, CLAUDE.md 현재 상태, docs/WORK_LOG.md 이번 항목, 큐의 이번 행·active/archive 사양.
- 실제 내용 SHA가 바뀌면 content/meta/release_content_inventory.json 및 생성 docs/CONTENT_RATING_INVENTORY.md의 내용 지문만 정렬.
- 사적 검수·대조 증거: .git/prose-review-20261015/. 새 검사 도구·오더별 상설 보고를 만들지 않는다.

조건·효과·flags·선택 순서·DIK 순서·엔딩 라우팅·자산·저장·경제·공개 데모·project.godot·JA/zh·번역 원장은 불변. 시작 시 dirty M18 4파일은 별도 바이트로 보존하고 커밋에서 제외한다.

## 검증·판정

44쌍과 E 3쌍의 전수 의미·KOEN·실제 생산자/독자, changed JSON path 및 비산문 데이터 불변 대조. 독립 검수자는 자신이 쓰지 않은 범위 전수 읽기.
context_manifest_check, queue_consistency_check, audit_select --list 뒤 기존 영향 비엔진 검사, en_coverage_check, diff --check. JA/CN/TW official inventory는 변경 검출만 관측·수용0.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
실제 앱·원어민·물리 패드·출시 판단은 미관찰. 같은 M18/612 HOLD와 공개 데모 GO를 보존한다.
지속 규칙은 SCENE_TIER 공통 산문 계약 소유, 나머지 파일 범위·배치·증거 지시는 일회성이다.
