# ORDER-667 — 사실 수리 뒤 KO/EN 장면 감각 복원

#### [~] ORDER-667 [산문·정합] PR #33의 44곳을 한영으로 다시 읽는다 — 2026-10-15

사용자 직접 지시: PR #33 main 병합, E절 문안과 A~D 대안을 KO/EN에 적용하고 목록 44곳을 재검토한다. 앞으로 사실 수리의 빈자리에 현재 장면의 감각 하나를 넣는다.
PR 병합 abda6a7. 모집단은 [검수 문서](../queue_backlog/PROSE_FLATTENING_REVIEW_2026-10-15.md)의 표 순서와 E절이다.

## 근거·깊이 3문

허위 과거를 지우는 과정에서 현재 장면의 긴장과 인물 행동까지 사라졌다.
통째 삭제하면 선행 선택이 남긴 몸·사물·침묵의 회수도 사라진다.
24주 뒤 상태 차이와 같은 자리의 경쟁 선택은 기존 flags/effects/독자가 소유하며 이번에는 산문만 고친다.
DIK는 실제 생산 선택을 대조한다. 목표 달성·생사·관계·주거를 새로 단정하지 않는다.

## 배치 A

표 1~22번 KO/EN 전수. 사실·장소·채널·인물의 지식은 유지하고, 추상 회상·부정 헤지로 채운 자리를 현재 장면의 감각·행동으로 고친다. 이미 구체성이 살아 있으면 유지 이유를 기록한다.

## 배치 B

표 23~44번 KO/EN 전수와 승인된 E절의 선택 text/result_text 및 final_gamble_taken 회수 각 한 쌍. E는 승인 문안을 쓰고 실제 거래·예약 기능을 만들지 않는다. A~D 대안은 해당 잎에 적용하며, 실제 정본과 충돌하는 사실이 발견되면 근거와 수정 이유를 명시한다.

## 정확한 파일 소유권

- content/events/ 및 content/events_en/의 arc_daeun_extension.json, arc_drama.json, arc_events.json, arc_hyunsu.json, arc_midgame.json, arc_year3_drama.json, arc_year_close.json: 표의 잎만. E의 선택 text/result_text 두 잎은 arc_midgame, final_week 회수 한 잎은 실제 소유 파일 arc_drama에 추가한다.
- content/endings.json, content/endings_en.json: crypto_ghost description, empty_house description_if_known/father_passed만.
- docs/SCENE_TIER.md 공통 산문 계약에 지속 규칙 승격, docs/DECISIONS.md 이유, CLAUDE.md 현재 상태, docs/WORK_LOG.md 이번 항목, 큐의 이번 행·active/archive 사양.
- 실제 내용 SHA가 바뀌면 content/meta/release_content_inventory.json 및 생성 docs/CONTENT_RATING_INVENTORY.md의 내용 지문을 정렬한다. 문장 변경으로 키워드 탐색 후보가 달라지면 관측 count·file count·ID 지문도 함께 정렬하되 사건/엔딩 roster·공개 후보·정성 내용축·등급 판단은 불변이다. 새 ‘입술을’의 ‘술을’ 부분일치도 후보 관측일 뿐 실제 음주 추가가 아니다.
- 사적 검수·대조 증거: .git/prose-review-20261015/. 새 검사 도구·오더별 상설 보고를 만들지 않는다.

조건·효과·flags·선택 순서·DIK 순서·엔딩 라우팅·자산·저장·경제·공개 데모·project.godot·JA/zh·번역 원장은 불변. 시작 시 dirty M18 4파일은 별도 바이트로 보존하고 커밋에서 제외한다.

## 검증·판정

44쌍과 E 3쌍의 전수 의미·KOEN·실제 생산자/독자, changed JSON path 및 비산문 데이터 불변 대조. 독립 검수자는 자신이 쓰지 않은 범위 전수 읽기.
context_manifest_check, queue_consistency_check, audit_select --list 뒤 기존 영향 비엔진 검사, en_coverage_check, diff --check. JA/CN/TW official inventory는 변경 검출만 관측·수용0.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
실제 앱·원어민·물리 패드·출시 판단은 미관찰. 같은 M18/612 HOLD와 공개 데모 GO를 보존한다.
지속 규칙은 SCENE_TIER 공통 산문 계약 소유, 나머지 파일 범위·배치·증거 지시는 일회성이다.
