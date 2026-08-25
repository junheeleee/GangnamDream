# Active Queue Spec: ORDER-127

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-127 [P0·엔딩 인과] 1장 30억 비밀 엔딩은 남기고 일반 성공은 마지막 서명까지 보낸다

**사용자 승인·착수 선언 (2026-08-25):** 후반 밀도 감사 뒤 사용자는 “30억
즉시엔딩은 오히려 게임의 이스터에그 느낌으로 필요한 거 아니야?”라고 지적했다.
따라서 현재 33세 초고속 `instant_legend`는 삭제하지 않는다. 34세 이후 일반
30억 도달만 즉시 `finish_run`하지 않고, M60 `arc_final_week` 선택을 끝낸 뒤
기존 관계·도덕·아버지 분기로 결산한다.

**[~] 착수 — 만지는 파일:** `autoloads/GameState.gd`,
`tools/EndingRouteIdentityCheck.gd`, `tools/ending_distinctness_audit.py`,
`tools/demo_core_loop_v2_audit.py`, `docs/ENDING_CONTRACT.md`,
`content/meta/year5_reference_routes.json`,
`tools/chapter1_core_loop_v2_causal_ledger_check.py`,
`docs/DECISIONS.md`, `docs/CODEX_QUEUE.md`, 이 사양, `CLAUDE.md`,
`docs/WORK_LOG.md`, `docs/queue_archive/CODEX_QUEUE_2026-08.md`,
생성본 `docs/STATUS.md`, `tools/audit_scope.json`.

## 깊이 3문

1. 왜 즉시 성공을 전부 없애지 않는가? 첫해 30억은 정상 성장선 밖의 희귀한
   변칙 성취라 전용 CG·문장으로 즉시 보상하는 것이 재플레이 발견감에 맞다.
2. 왜 2~5년차 30억은 기다리는가? 일반 도달이 곧바로 끝나면 아버지·연인·상철과
   마지막 서명, M59~M60의 대가를 건너뛰어 게임이 뒤로 갈수록 얇아진다.
3. 왜 새 승리 수치를 만들지 않는가? `GANGNAM_TARGET`과 저장되는 `peak_asset`이
   이미 실제 30억 도달을 증명한다. 기존 ID·CG·저장 스키마를 유지하고 종결
   시점만 고친다.

## 배치 A — 일반 30억 종결 gate 8단위

1. `age <= 33`이고 현재 순자산이 30억 이상이면 기존처럼 즉시
   `instant_legend`로 닫는다.
2. 34세 이후 처음 30억에 닿으면 `peak_asset`에 성취를 남기되
   `arc_final_week_seen` 전에는 일반 강남 엔딩을 호출하지 않는다.
3. 도달 뒤 자산이 잠시 내려가도 이미 달성한 목표를 취소하지 않고 마지막
   결산에서 `peak_asset >= GANGNAM_TARGET`을 읽는다.
4. `arc_final_week_seen` 뒤에는 현재 아버지·배우자·관계·MORAL_TINT 분기 순서를
   보존해 기존 35개 ID 중 알맞은 성공 엔딩으로 닫는다.
5. 다은을 수단으로 쓴 결혼 런은 기존 `arc_daeun_final_choice`를 먼저 끝내야 한다.
6. 체력·마음·파산·중독의 실패 결말은 기다리지 않고 즉시 끝난다.
7. 별도 인수 사건이 소유하는 `startup_exit`의 우선순위와 즉시 종결은 이 오더에서
   바꾸지 않는다. 해당 R1b 활성화도 하지 않는다.
8. 새 엔딩 ID·CG, 밸런스 수치, AP/월간 행동판, 저장 버전을 만들거나 지우지 않는다.

## 배치 B — 표적 회귀와 문서 정합 7단위

1. 첫해 30억이 정확히 `instant_legend` 한 번을 내는 실행 검사를 둔다.
2. 34세 일반 30억은 마지막 서명 전 종결 0, 서명 뒤 기존 정상 강남 종결 1임을
   같은 런 상태에서 검사한다.
3. 30억 도달 뒤 하락한 자산도 마지막 서명에서 도달 사실을 잃지 않는지 검사한다.
4. 아버지 별세·다은 최종 심판·실패 결말의 기존 우선순위를 검사한다.
5. `startup_exit`이 이 변경 때문에 일반 강남으로 흡수되지 않는지 검사한다.
6. `ENDING_CONTRACT.md`는 비밀 엔딩 예외와 M60 본 결말 gate를 소유하고,
   `DECISIONS.md`에는 이번 판단 이유만 남긴다.
7. 영향 선택 감사, 전체 감사, EN coverage, context/diff 검사를 통과한다.

## 완료 증거

- headless `EndingRouteIdentityCheck`가 비밀 엔딩·일반 도달 보류·최종 서명 뒤
  라우팅·목표 도달 후 하락·즉시 실패·startup 불변을 모두 실행해 PASS한다.
- 일반 30억 경로에서 `arc_final_week_seen=false`인 동안 `game_over` signal과
  `is_game_over`가 모두 발생하지 않는다.
- `arc_final_week_seen=true` 뒤에는 기존 성공 ID 하나만 발생한다.
- 기존 엔딩 35 ID·CG, 저장 스키마, 밸런스 상수, 제품 설정 파일은 byte 의미상
  그대로다.
- 범위 밖 파일 drift 0, context/영향 감사/전체 감사/EN coverage/diff PASS다.

## 다음 경계

이 오더는 종막을 건너뛰는 문만 막는다. `final_signature_owned/collateral/people`가
실제 엔딩 본문과 사람들의 이후를 바꾸게 만드는 작업, M59~M60 장면을 8~10개
의미 전환으로 강화하는 작업, 4~5년차 route root 공백 수리는 각각 다음 작은
오더가 소유한다. 이 배치의 자동 GREEN을 후반 재미 GO로 부르지 않는다.
