# ORDER-430 — 스캘핑 준비 창과 조작 포커스를 단계 안에 둔다

#### [~] ORDER-430 [P1·UI/입력] 준비 창 재생성 잔류·초기 포커스 누락 수리

**[~] 착수 — 2026-10-04.** 사용자 계속 개발·main 커밋/푸시 위임.
429의 실제 r2에서 발견한 기존 제품 결함만 수리한다. 새 게임 규칙은 만들지 않는다.

## 확인된 결함과 의미

- e3c76c6의 CN/TW 10PNG에서 준비 재개방 C의 새 창이 자동 이름으로 생성되고,
  이름 기반 제거가 이를 놓쳐 D/E 거래 화면 위에 남았다. 재개방은 준비 fixture이며
  자연 플레이 경로 전체를 관측했다고 주장하지 않는다.
- 첫 튜토리얼 취소 후 B와 C/D/E의 초기 focus owner가 없었다. 지역별 Esc·Right
  각 한 쌍만 보내고 이후 입력을 중단했다. 거래·정산·행동확정은 0이다.
- 없애면 깨지는 것: 실제 단계 창 소유·키보드/패드 선택 접근성. 24주 상태차·선택
  경쟁은 해당 없음: 기존 입력 결함 수리이고 비용·보상·조건·선택 자체는 변경0.

## 파일 소유

- root: `scenes/ScalpingGame.gd` 및 큐·430 active/archive·429 상태·CLAUDE·WORK_LOG·
  생성 STATUS·agent 보고/판정. 게임 파일만의 작은 제품 commit을 먼저 만든다.
- claude_handoff_review: `tools/ui_translation_append.py`의 새 exact Scalp 전이 검증과
  manifest/current_proof 연결만. 기존 함수 본문·pin·receipt·기존 교정은 그대로 둔다.
- receipt_tests392: `tools/scalping_phase_focus_receipt_check.py`, `tools/audit_scope.json`,
  새 `.git/full-game-localization/order430-*` 격리 runtime·normal helper.
- independent392: 비저자 제품/검사/원본화면·입력·receipt 최종 검수. 제품·helper 저작0.
- 번역 41602/b205·CN/TW1706·JA3044, Main/Tutorial/Font/게임 수치·정산·save,
  과거 성공/실패/helper·인간 원장·공개 데모·출시 manifest 변경0.

## 구현과 증거 계약

- 단계 창을 직접 참조해 재개방/전환 시 숨기고 제거한다. queue_free 이름 경쟁으로
  새 창이 남지 않는다. 준비/결과 창과 거래 본문은 각각 활성 버튼만 포커스 대상이다.
- 나타난 단계의 유효 기본 버튼에 포커스를 주고, 실제 튜토리얼의 우선권을 보존한다.
  비활성 매수/매도 버튼에 남은 포커스를 유효 버튼으로 옮긴다. 방향·Tab·hover는
  같은 활성 표면을 쓰며 새확정/취소 shortcut이나 거래/정산 효과는 추가하지 않는다.
- 429의 첫 실패/타입 실패/r2 제품 실패 모두 원본 보존. 새 격리 프로세스에서 같은
  15키·지역별5화면과 실제 초기 focus·안전 방향/Tab·합성 D-pad를 확인한다.
  D/E에 준비 창이 0이고 표적 전체가 차폐 없이 보이며 비활성 버튼은 건너뛴다.
- 실제 player34 byte 보호·pre-autoload 격리·typed 복원·actual Tutorial 취소·
  start 직후 tick 전 동결을 유지한다. helper focus/neighbors 주입0·물리pad 관측0.
- Scalp 단독 제품 commit의 direct parent/commit/tree/blob/raw SHA·전체diff 역상을
  검증한다. 현재 manifest 하나와 실제 전이 전 manifest의 기존 역사만 허용하고,
  새 Scalp×과거 Main의 존재하지 않은 조합은 거부한다. 반환 census는 실제 현재다.
- 새 focused는 역상 extra edit/다른 source 변화/가상 manifest/HEAD raw mismatch/
  성공 뒤 다음 호출 fault를 검사한다. 오래된 focused·A/B·전체/240주 반복0.
- 최종 clean successor에서 새 focused·영향 입력/번역 표적·공통 normal 각1회.
  429의 공통 normal을 수리 전 중복 실행하지 않는다. 해당 successor에서 429와430을
  각각 판단하고 실패한 e3c76c6의 화면을 성공으로 재명명하지 않는다.

일회성 수리 절차다. 상시 입력 규칙은 기존 CONTROLLER_UX_STRATEGY Acceptance Gates와
CLAUDE의 입력 계약을 따른다. 자동PASS는 계약증거이지 문체·재미·출시GO가 아니다.
본편/새package HOLD·원어민/인간/물리 미관측·공개GO1/인간OPEN45를 유지한다.
