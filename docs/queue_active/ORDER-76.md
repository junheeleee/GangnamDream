# Active Queue Spec: ORDER-76

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-76 [P0·첫 플레이] 넓은 월간 계획판과 세로 연락폰을 분리한다

**사용자 승인 (2026-08-03):** 휴대폰 기종 변경·구매를 취소한다. 일정·잔액·
투자·도박 등 게임 시스템을 휴대폰 앱에 넣지 않고, 휴대폰은 실제 연락에
해당하는 문자·통화·연락처만 담은 세로형 우측 패널로 만든다. 월간 계획은
휴대폰 도입 전의 넓고 직관적인 화면을 기준으로 복원한다.

> 구현 파일: `scenes/CoreLoopPlanner.gd`, 신규 `scenes/CommunicationPhone.gd`,
> `scenes/MainGame.gd`, `scenes/TutorialOverlay.gd`, `systems/PhoneSystem.gd`,
> `autoloads/GameState.gd`, `content/meta/demo_core_loop_v2.json`,
> `tools/demo_core_loop_v2_audit.py`, `tools/core_loop_v2_balance_sim.py`,
> `tools/PhoneSystemCheck.gd`, `tools/CoreLoopV2Check.gd`,
> 신규 `tools/CommunicationPhoneCheck.gd`와 그 `.uid`·`.tscn`,
> 신규 `tools/CoreLoopV2FirstEntryCheck.gd`와 그 `.uid`·`.tscn`,
> `tools/CoreLoopV2HandoffCheck.gd`, `tools/ScreenshotQA.gd`,
> `tools/audit.sh`, `tools/audit_scope.json`.
>
> 정본·출시 문서: `docs/DECISIONS.md`, `docs/CORE_LOOP_V2.md`,
> `docs/CONTROLLER_UX_STRATEGY.md`, `docs/INPUT_MATRIX.md`,
> `docs/QA_CHECKLIST.md`, `docs/BALANCE.md`, `docs/MASTER_RELEASE_AUDIT.md`,
> `docs/DEMO_FIXLOG.md`, `assets/ui/phone/README.md`,
> `content/meta/release_content_inventory.json`.
>
> 종료 파일: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/STATUS.md`,
> `docs/WORK_LOG.md`, `docs/queue_archive/ORDER-76.md`. ORDER-74에서 이미
> 선언한 `scenes/StoryMode.gd`·`tools/FlashforwardVisualCheck.gd`의 실루엣
> 수정과 Chapter 1 카드 복구는 첫 진입 회귀에 함께 통합하되 소유권은 유지한다.
> 24주 사건 선택 순서·효과·주간 영수증, 투자 수익률, 도박 확률은 바꾸지 않는다.

## 깊이 3문

1. 지우면 1280×800에서 일정·은행·투자까지 작은 가로 휴대폰 화면 안에 갇혀
   Steam Deck의 읽기 크기와 조작 맥락을 동시에 잃는다.
2. 월초에 받은 제안은 넓은 네 주 계획과 경쟁하고, 실제 문자·통화만 휴대폰의
   대화 기록으로 남는다.
3. 일정·연락·금융을 서로 다른 표면이 소유해야 1년·5년 확장 때 앱 하나가 모든
   시스템의 병목이 되지 않는다.

## 배치 A — 표면과 저장 소유권 분리

- `168e9de`의 42px 여백·넓은 제안 열·420px 네 주 열을 외형 기준으로 삼되,
  이후 추가된 24주·읽기 전용·관계 기억·2단계 확정 계약은 보존한다.
- 넓은 계획판은 `현황 / 일정 / 사람 / 기록`을 소유한다. 잔액·고정비·투자 현황·
  발견한 장소는 여기 또는 기존 본게임 모달에서 보여 주고 실행 효과는 만들지 않는다.
- 우측 세로폰은 앱 런처 없이 `대화 / 연락처`로 바로 열린다. `inbound_message`와
  `call_log`, 실제 `phone|kakao|business_card` 연락수단만 들어간다.
- 기종·구매·즐겨찾기는 진입점을 모두 제거한다. 기존 유효 구매 영수증은 저장
  schema 3 이관 때 정확히 한 번 환불하고 재로드 중복 환불을 막는다.

## 배치 B — 첫 진입·Deck 회귀와 출시 정합

- 첫 플레이를 `프롤로그 → Chapter 1 → 넓은 월간 계획판 → 계획 튜토리얼`로
  고정하고, 튜토리얼은 휴대폰이 아니라 제안 배치·주로 할 일·보조로 할 일을 설명한다.
- KO/EN 1280×800과 960×600에서 빈 계획·검토·읽기 전용·대화 목록·대화방·
  연락처·폰 닫은 뒤 포커스를 캡처하고 텍스트 잘림과 입력 누수를 거부한다.
- 기존 리퍼폰 18만 원을 가정한 경제 시뮬레이션·폰 8앱/4기종 감사·출시 문서를
  새 표면 계약과 환불 원장으로 바꾼다.

## 완료 증거

- 휴대폰 기종·구매·즐겨찾기 런타임 진입점: `0`
- 폰 밖 표면: 월간 일정·현황·사람·기록 PASS
- 폰 안 표면: 실제 대화·연락 가능한 연락처만 PASS
- 유효 레거시 구매 환불: 정확히 `1회`, 반복 로드 추가 환불 `0원`
- 첫 진입: `prologue → chapter_33 → planner → tutorial`
- KO/EN 1280×800·960×600 포커스 누수·잘림: `0`
