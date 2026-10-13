# ORDER-597 — M24 월급 계산의 주거 형태 정합

#### [~] ORDER-597 [정합] KO/EN 6잎 수리 — 2026-10-13

기준 main87f34d96954612759dc3b26a67a486da9bc80bb4. 사용자 지시로 Mac 잠금 중
M17~M60의 KO/EN 사실을 월 순서대로 수리한다. 현재 M24이며 실제 앱 M17은
562 하나만 HOLD다. 해제 즉시 원559 W68 실제 플레이 우선, CI 빨강 새 월0.

## 확인한 결함과 깊이

MainGame.gd:7307–7312와 story_rules.json:3233–3249의 월급 장면 입구는
재직·근속6·거울장면을 요구하지만 주거 형태는 제한하지 않는다.
GameState.gd:52–61은 빌라/아파트 전세와 주거 비용을 지원한다.
그런데 arc_career_ceiling 기본 본문과 병동/거래 선택 회수 본문 모두 월세를
뺀다고 단정한다. 주거비라는 상위 표현은 기존 모든 주거에 맞는다.

1. 방치하면 전세 경로에도 월세 납부를 발명한다.
2. 새 선택/게임 상태/24주 차이0. 기존 선택·비용·회수는 그대로다.
3. 월급의 한계와 병원/거래 갈등을 보존하며 계산 항목의 주거 형태만 바로잡는다.

## 파일 소유와 작업 범위

- root: content/events/arc_midgame.json 및 content/events_en/arc_midgame.json의
  arc_career_ceiling.description과 description_if_known의
  sangchul_mirror_hospital_face_up / sangchul_mirror_deal_face_up, 총6잎.
  KO 월세→주거비, EN rent→housing costs만 바꾼다.
- 필요할 때만 content/meta/release_content_inventory.json의 실제 content SHA와
  docs/CONTENT_RATING_INVENTORY.md 공식 생성 보고를 정렬한다.
- root: 큐2·이 사양/완료 archive·WORK_LOG·CLAUDE 현재행.
- mod_layer_ci: .git/order597-20261013/independent-review.md만.
- rework_batch_plan: 같은 디렉터리 preservation-review.md만.

다른 시간·직종 문구는 이 범위에서 고치거나 승인하지 않는다. 본문 나머지,
선택/결과/효과/조건/플래그, 실제 경제·저장·주거·라우팅·아트/음악은 불변이다.
JA/zh 다듬기와 원장 수용0. KO 변경3잎은 실제 KO/EN 확정 뒤 정합 대기로 남긴다.
5개 출시 언어·공개 데모·사용자 저장/설정/project.godot·과거 인간 판정 보존.

## 검증과 완료

선언 커밋/푸시 뒤 구현한다. 직전596 공식 locale inventory를 before로 재사용하고
새 공식 inventory3으로 변화를 측정한다. EN coverage/Hangul, story consistency,
narrative continuity/spine, speech, scene audio, i18n, demo scope/story/JA/ZH,
release inventory와 context/queue/diff 검사를 실행한다.
비저자가 실제6잎·입구/주거·독자·나머지 bytes와 데모/비소유 보존을 읽고 판정한다.
표적 새 실패0·source 독립 GO 뒤 마감한다. 새 검사/도구/등록·엔진/전체 audit/
240주·실제 월/새 장면/격상0. 자동 계약은 재미·인간·원어민·물리 패드 증거가 아니다.
본편/출시 HOLD 유지. gangnamdream-dev/WORK_UNIT 적용·일회성 지시·정본 승격0.
