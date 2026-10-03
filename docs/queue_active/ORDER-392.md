# ORDER-392 — 선반영 중국어 UI8값의 공식 수용원장·이력 복구

#### [~] ORDER-392 [P0·현지화] 선반영 중국어 UI8값의 공식 수용원장·이력 복구

**[~] 착수 — 2026-10-03.** 사용자 개발·검수 위임, Claude PR31 인계 B2.

## 문제와 선택

main `9fb7ff21`의 CN/TW 패드 안내8값은 이미 반영됐지만 원장은40,981/b161로
남아 `order365_ui_receipt_compat`가 additions mismatch로 실패한다. Claude
`9db4a6e5`의 공식8receipt/2batch를 원래 source `18dd16d6`과 대조하여 복구한다.
PR31 runbook의 B3 원고 미수용 시 허용하는 original392-first 경로를 선택했다.
폰트·B3/B4 원고를 무검수 통합하지 않는다. 이후 B4 누적원장은 별도 대조 대상이다.

깊이3문: 제거하면 실제 UI값과 증거가 분리돼 후속 검사가 막힌다. 플레이 상태·
24주 뒤 차이·경쟁 선택은 이력 수리에는 해당하지 않으며 경제/저장/서사 불변이다.
하나의 판정 단위는 exact UI 선반영→공식 원장 회복 전이이며 전수 검수한다.

## 파일 소유와 경계

- Root: `content/meta/full_game_localization.json`의 검증된8receipt/2batch만
  원격과 byte-exact 일치하도록 반영. 기존 receipt/batch/JA/메타데이터 불변.
- `/root/receipt_bridge392`: `tools/ui_translation_append.py`만. PR30
  `0f5852d0`의 실제 두 부모, main 유입 `e89f3ed`, 원본 `9db4a6e5`와 복구
  commit/tree/blob/raw를 고정한 split transition. 기존 일반 append 검증 불변.
- `/root/receipt_tests392`: `tools/ui_translation_append_self_test.py`,
  `tools/audit_scope.json`만. 새 focused 차선과 fail-closed 반례.
- `/root/independent392`: 읽기 전용 독립 검수.8값·receipt·실제 Git source
  manifest·원시 역삭제·전이/반례·최종 후보를 직접 확인한다.
- Root 기록: 이 사양·`docs/CODEX_QUEUE.md`·`docs/queue_active/ORDER-391.md`,
  `CLAUDE.md`·`docs/WORK_LOG.md`·생성 `docs/STATUS.md`, 필요시 기존
  `docs/history/WORK_LOG_2026-09-07_localization.md` 손실 없는 이동,
  `docs/agent_reviews/ORDER-392.json`·`docs/agent_review_decisions.json`,
  완료 후 `docs/queue_archive/ORDER-392.md`·`docs/queue_archive/CODEX_QUEUE_2026-09.md`.
  private `.git/full-game-localization/order392-*`은 실제 교환·검사 증거만.

## 검증과 완료 조건

1. 실제 Git `18dd16d6` 기준 공식 export/check CN/TW 각4leaf를 기존 원본과
   대조한다. 재검증과 역사 원본의 provenance를 구분하고 기존 private 파일 불변.
2. 기존8 UI값·JA·기존 원장 prefix·나머지 metadata 보존,40,989/b163와 digest.
3. 좁은 Git 전이 proof 및 normal 현재 history/소비자 검사. 일반 validate_append는
   그대로 적용하며 미회복 pending HEAD·중간 다른 변경·잘못된 commit/tree/blob/
   raw/source/target/header·중복/고아를 거부한다. old history/회귀 실패 보존.
4. focused self-test만 실행. 기존350은5언어 arc_drama+원장,351은 원장 pin
   mismatch가 본 작업 이전부터 존재함을 구분한다. 이 불일치를 넓은 예외로
   숨기거나 여기서 수리하지 않는다. 수정 없는 비싼 역사 self 반복0.
5. 영향 차선 조회·context/queue/diff 및 필요한 표적 normal만. 전체감사·240주0.
   독립 검수 후 exact source에 work_unit 판정을 기록한다.

## 비포함·증거 경계

UI 사전값·MainGame·폰트·게임 원고·공개 데모·사람 원장·출시 언어 변경0.
ORDER-391 실제 화면/지역 primary font 검수는 OPEN이며 여기서 닫지 않는다.
자동검사는 계약 증거이지 재미·원어민/인간/물리 패드/출시 GO가 아니다.
기존154판정/132보고 보존. 공개GO1·인간OPEN45·본편/새package HOLD.
외부 제출·스토어 변경·지출·법률 인증0. 새 상시규범0; 위 분담/검증은 일회성.
