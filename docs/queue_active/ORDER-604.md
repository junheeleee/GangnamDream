# ORDER-604 — 실제 주거 상태 계약 등록 누락 수리

#### [~] ORDER-604 [정합] 다은 3년차 주거 도메인 1값 — 2026-10-13

603의 기존 exposed 검사 actual1에서 arc_daeun_year3_together만 undeclared housing.
601이 배경을 current_housing으로 고쳤지만 노출 상태 계약에 housing을 빠뜨렸다.
사용자 CI 실패 우선 지시로 이 한 값 수리를603보다 먼저 닫는다. 새 실제월은 열지 않는다.

## 깊이·소유·검증

기존 실제 주거 consumer와 검사 검출이 옳다. 해당 state_sensitive 배열에 housing만
추가해 location/relationship도 그대로 검사한다. 게임 원문/효과/시각/음악/저장/조건,
새 시스템이나 검사 면제는 없고 미래 주거 변경도 계속 보호한다.
root content/meta/exposed_event_state_contracts.json의 해당 배열 1값·큐2·이사양/archive·
WORK_LOG만. 같은 파일의603 unorthodox 변경은 별도 소유이며604커밋에 넣지 않는다.
선언 후 apply_patch, 기존 exposed 검사 actual0 확인, 비저자 root/rework_batch_plan
독립 diff 판독(.git/order604-20261013/independent-review.md만), context/queue/diff.
603과 함께 있는 작업트리 검증임을 명시하고604커밋은 독립1값만 포함한다.
CJK/원장/데모/사용자저장/설정/project.godot/인간 판정 보존, 엔진/native0.
gangnamdream-dev·WORK_UNIT 적용, 일회성/승격0. 본편/출시 GO가 아니다.

