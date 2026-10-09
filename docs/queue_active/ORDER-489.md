# ORDER-489 — 비도달 4장 지연 원고의 장면 등록 정합

#### [~] ORDER-489 착수 — 만지는 파일: assets/scene_audio_manifest.json, assets/scene_direction_manifest.json, docs/KNOWN_FAILURES.md — 2026-10-09

## 근거 / 정확한 범위

DECISIONS 2026-10-01의 지연 연인 변형6 author_only 판정과 완료469의 제품 진입
제외를 유지한다. 현재 KNOWN_FAILURES의 오디오·연출·전 구간 연출3개 실패는
이 원고가 shipping event intent에 남은 동일 결함이다. 원고를 활성화하지 않고
두 현재 제품 등록만 맞춘다. 화면 오더149/457/302는 실제 Mac 잠금으로 진행 불가다.

- exact6: arc_y4_bill_night_jiyeon, arc_y4_body_witness_jiyeon,
  arc_y4_borrowed_name_jiyeon, arc_y4_family_partner_collision_jiyeon,
  arc_y4_three_promises_jiyeon_and_deal, arc_y4_year_close_jiyeon.
- assets/scene_audio_manifest.json의 event_intents.rendered_profile에서6개만 제외.
- assets/scene_direction_manifest.json의 event_intents.explicit_move에서6개만 제외.
- 각 원문과5언어·event_lifecycle·현재 weight0/hidden/조건·런타임·저장·효과·플래그
  불변. 실제 음악/이미지 파일 삭제0, 배경·전환·활동·엔딩 계약 변경0.
- audio --write는 관계없는 기존 제품4개 분류도 바꾸므로 쓰지 않는다.
  그4개(age_39_final/casino_comp_offer/callback_casino_accepted_comp_echo/
  callback_casino_declined_comp_echo)의 기존 등록을 보존하는 최소 패치만 적용한다.
- 위3검사가 실제 PASS일 때만 docs/KNOWN_FAILURES.md의 정확한3행을 제거.
  PEAK_CHAIN_EXIT/EXPOSED_STATE_EXIT와 만료2026-10-16은 유지한다.
- 운영 파일: docs/CODEX_QUEUE.md, CODEX_QUEUE_L3_PENDING.md 순번,
  이 사양/완료 archive, docs/WORK_LOG.md, CLAUDE현재, 생성docs/STATUS.md.
  도구·audit.sh·등록·새 검사/계측·새 오더별 보고/판정 원장은 변경0.

## 깊이 3문 / 제품 의미

- 없으면: 제품 진입 없는 원고가 shipping 오디오/연출 coverage에 남아 새 누락을
  구별하는 기존 검사가 상시 실패한다. 실제 원음과 본문 삭제가 아니라 등록 정합이다.
- 24주 뒤: 상태/경제/연애/선택의 차이0. 원고6개는 이전처럼 제품 비도달이다.
  새로운 선택·서사 깊이·도달성 개선이라고 세지 않는다.
- 경쟁: 살아 있는1702사건의 음악/연출 소유와 기존4개 오디오 분류를 보존한다.
  새 도구·전체 재생성·관계 경로 확장 대신 기존 제품 검사3개를 정상으로 복귀시킨다.

## 검증 / 종료

선언 commit/push 후 두 등록6개씩만 패치한다. 기존 lifecycle/chapter4 causal route,
scene_audio_catalog, scene_direction_catalog, full_run_direction_audit,
scene_audio_contract_check와 필요 시 full_run_audio_audit를 표적으로 실행한다.
두 JSON의 역상으로 비소유 값 변화0·shipping1702를 확인한다.
독립 비저자는 실제 diff·검사 출력·현재 원고의 author_only 조건을 메시지로 검수한다.
표적 context/queue/diff 검사와 생성 STATUS를 갱신하고 main에 commit/push한다.
스케줄러/저장/엔딩 변경0이므로 전체 감사/엔진/240주 재실행0.
기존 full_run 방향·오디오의 Python trace는 실제 플레이 관찰로 쓰지 않는다.
Mac 실제 화면·청취·원어민·인간·물리 패드 미관찰, 본편 출시 HOLD다.

새 규범0. 정본은 기존 AUDIO_QA/event_lifecycle/DECISIONS/WORK_UNIT이며
파일 소유와 최소 패치·종료 절차는 일회성이다.
