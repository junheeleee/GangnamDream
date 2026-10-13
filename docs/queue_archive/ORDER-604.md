# ORDER-604 — 실제 주거 상태 계약 등록 누락 수리

#### [x] ORDER-604 [정합] 다은 3년차 주거 도메인 1값 — 2026-10-13

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

## 완료

선언1877f2d 뒤 housing1만 추가. 603+604 작업트리의 기존 exposed actual0,
원603실패는 private check-exposed-v1-fail.json에 보존. root 전문 판독한 비저자
독립보고 `.git/order604-20261013/independent-review.md` 2176B /
`165c38ef303131c05c7b223f1dcdc611c300706f3d9a1845bacd8a734a41d078` GO.
604-only 투영51758B `2f23b1dc8e291f9a742564bbedd84b492ce89b8f99e4bdc0703a271d65a3be24`
와 staged blob 일치 확인 후 commit. 603의 다른 housing 값은 별도 미커밋으로 유지한다.
검사 약화0·게임/사용자/공개/원장 변경0·실제 M17 잠금HOLD. 일회성/승격0.
