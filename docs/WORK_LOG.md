# WORK_LOG.md — 강남드림 작업 기록

이전 기록은 [568 전 원문](history/WORK_LOG_2026-10-12_pre_order568.md)에 바이트 그대로 보존했다. 그 보존본이 앞선 원문 링크를 가진다.
보존 원문은 39872B/SHA256 f733be0a4de292acfa40d7717be6180b5d5847dfa37e963628043eae5b8ce652이다.

## 2026-10-12 — 일반 종막 검사의 제품 무관 이력 핀 제거

- [568](queue_archive/ORDER-568.md): 삭제 전 표 de131523을 먼저 commit/push하고 그 뒤 전챕터 옛 census 상수2줄/counts8줄만 제거했다. 개수 일치는 종막 도달을 보장하지 않아 지키는 제품 동작이 없었다. 실제 root/선택/영수증/라우팅·비도달 방어 및 현재 코퍼스 counts/hash 검사는 그대로다. 전용 self-test0·기존32/27 유지.
- 기존4검사 exit0/stderr0·비저자 actual diff/원출력 GO. 게임·번역·원장·저장 변경0이며 새 CI는 미확정이다. 원자료·보존은 [사양](queue_archive/ORDER-568.md)에 결속한다. M17 OS잠금 HOLD/native0·번역 INCOMPLETE·본편/출시 HOLD, 일회성/승격0이다.

## 2026-10-12 — 경마 검사 마감·일반 종막 검사 정리 선언

- [567](queue_archive/ORDER-567.md): ab66435c의 CI38196803190/attempt1·jobs2·모든 step success. 독립 source/raw/보존·등록 CI 수리 한정 완료다. 전체 raw에는 종료 resource ERROR3줄이 남아 strict-clean/본편 출시 GO가 아니다.
- [568](queue_archive/ORDER-568.md): 삭제 전 표를 먼저 선언한다. 일반 종막과 무관한 전챕터 옛 census 상수2줄/counts8줄만 삭제 대상이다. 전체 개수가 같아도 종막 도달을 보장하지 않아 지키는 제품 동작이 없다. ROOT_IDS 비도달·선택·영수증·라우팅 및 별도 현재 코퍼스 counts/hash 검사는 보존한다.
- gangnamdream-dev의 제품 방어/이력 핀·자동/실관찰 경계를 적용한다. 게임·원장·사용자/공개 저장·Human·옛 raw 불변, M17 하나·OS잠금 native0·새 월0·번역 INCOMPLETE·출시 HOLD다. 일회성/승격0이다.
