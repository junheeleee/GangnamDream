# Active Queue Spec: ORDER-78

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-78 [P0·출시 증거] 실제 입력만으로 V2 24주를 처음부터 끝까지 완주한다

**사용자 근거 (2026-08-04):** 24주 데모를 집에서 바로 플레이할 수 있는
출시선까지 자율적으로 마무리하라는 지시와, 한 편의 소설·영화처럼 이어지는지
전체 흐름에서 판단하라는 지시를 따른다. 기존 `demo-experience`는 레거시
MainGame을 완주하므로 V2의 월간 계획·첫 청구서 완주 증거로 세지 않는다.

> 배치 A — 실제 입력 블랙박스:
> `tools/ScreenshotQA.gd`, `scenes/CoreLoopPlanner.gd`,
> `tools/audit.sh`, `.github/workflows/ci.yml`, `tools/audit_scope.json`.
>
> 배치 B — 정본·완료 기록:
> `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CORE_LOOP_V2.md`,
> `docs/QA_CHECKLIST.md`, `docs/DEMO_FIXLOG.md`, `docs/WORK_LOG.md`,
> `docs/RELEASE_NOTES.md`, `docs/STATUS.md`,
> `docs/queue_active/ORDER-78.md`, `docs/queue_archive/ORDER-78.md`.
>
> 게임의 원고·수치·저장 스키마·장면 편성·선택 효과는 바꾸지 않는다.
> 실제 화면을 고르는 안정된 메타데이터 외의 런타임 변경이 필요하면 이 오더에
> 조용히 붙이지 않고 원인을 먼저 기록한다.

## 깊이 3문

1. 지우면 각 화면 fixture가 PASS해도 처음 산 플레이어가 타이틀에서 24주
   완료까지 갈 수 있는지는 증명되지 않는다.
2. 월간 계획 여섯 번의 실제 배치가 지원·취업·관계·첫 청구서 후보를 만들고,
   그 결과가 완료 자동 저장과 25주 이후 원장에 이어진다.
3. 같은 장치만 쓴 KO 패드와 EN 키보드 경로가 번역문·포커스 순서·숨은
   단축키에 기대지 않고 같은 24주 사실을 만들어야 한다.

## 배치 A — 타이틀에서 완료 CTA까지

- 기존 레거시 입력 경로를 수정해 V2인 것처럼 보고하지 않는다.
  `core-loop-v2-gamepad`와 `core-loop-v2-keyboard` 두 전용 스코프를 만든다.
- 타이틀 진입 버튼은 표시 문자열이 아니라
  `core_loop_v2_test_entry=true`와 `build_entry_kind=core_loop_v2_playtest`를
  함께 읽는다. 계획판의 월·제안 ID·주차·확정도 언어와 배치에 독립적인
  메타데이터로 찾는다.
- 첫 진입은 실제 프롤로그→Chapter 1→월간 계획판→3장 튜토리얼 순서다.
  튜토리얼은 세 번의 실제 확인 입력으로만 닫고, 그동안 계획·루틴·탭이
  바뀌지 않아야 한다.
- 검증된 `livelihood + recovery` 경로로 여섯 달의 네 약속을 실제 UI에서
  배치한다. 각 월 확정은 검토 열기와 최종 확정의 두 입력을 구분하고,
  내부 배열 수정이나 `pressed.emit()`으로 대신하지 않는다.
- StoryMode는 타이핑 완성과 문단 진행을 구분하고 실제 선택 레일이 열린 뒤
  원본 `choice_index`를 고른다. 24주 첫 청구서는 opening→decision→ledger를
  같은 StoryMode 인스턴스에서 정확히 한 번씩 지나고, `body_rest` 원본
  인덱스 7과 현수 시험 아침을 확인한다.
- 완료 모달은 24주 상태를 정확히 한 번 자동 저장하고 실제 CTA 입력으로
  타이틀에 돌아온다. 돌아온 타이틀에서도 같은 장치로 splash를 넘긴 뒤
  V2 데모 버튼을 다시 찾을 수 있어야 한다.
- KO는 PlayStation 물리 위치 패드만, EN은 키보드만 쓴다. 마우스와 다른
  장치 입력이 한 번이라도 섞이면 실패한다.

## 배치 B — CI와 출시 증거

- 최소 행렬은 KO 1280×800 PlayStation-layout gamepad와 EN 1280×800
  keyboard다. 두 경로는 서로 다른 격리 홈을 쓰고 사용자 세이브·설정·메타·
  화면 설정을 원상 복구한다.
- 성공 표식은 언어·장치·튜토리얼 3·계획 6·24주·첫 청구서 1/1/1·현수 1·
  자동 저장 1·타이틀 복귀 1·입력 혼입 0을 한 줄로 출력한다.
- 로컬 실행과 CI가 같은 명령을 사용한다. Linux CI는 xvfb+OpenGL3로 실제
  GUI 입력 경로를 실행하며, 실패 로그가 잘리지 않게 보존한다.
- 자동 완주는 몰입·재미·패드 손맛을 판정하지 않는다. 이 작업이 닫혀도 정상
  속도 독해, 연속 A/V, Steam Deck·실물 패드, 외부 사람 GO는 열린다.

## 완료 증거

- 타이틀 진입: 번역문 검색 0, 안정 메타 2개 일치
- 튜토리얼: `3 pages / once / state mutation 0`
- 월간 계획: `6 plans / weeks 1..24 / routine receipts 24 / units 48`
- 종료 상태: `turn 25 / month 7 / completed_through_week 24 / game over false`
- 취업: exact Week-17 수락 출처와 현재 `job_03`
- 첫 청구서: opening/decision/ledger `1/1/1`, decision index `7`, exact receipt
- 현수 시험 아침: ledger 뒤 `1`, 정식 결과 선취 `0`
- 자동 저장: turn-25 완료 payload `1`, CTA 뒤 추가 저장 `0`
- 타이틀 복귀: 같은 장치로 V2 진입 명령 재발견
- KO 패드: keyboard/mouse `0`; EN 키보드: gamepad/mouse `0`
- 전체 감사·두 실제 입력 스코프·CI: PASS

## 규범 판정 예정

- 계속 유효한 V2 실제 입력 게이트는 `CORE_LOOP_V2.md`와 `QA_CHECKLIST.md`에
  승격한다.
- 정확한 월별 테스트 경로·선택 인덱스·도우미 함수·입력 횟수는 이 검증의
  fixture이며 다른 서사 경로의 정본으로 승격하지 않는다.
