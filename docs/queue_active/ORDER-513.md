# ORDER-513 — 보호 종막의 마지막 주를 시간 원장에 한 번만 정산한다

#### [~] ORDER-513 [P1·종막 기록] W240 분류 누락·원장 239/기록 240 경계 수리

**착수 — 2026-10-10.** [457](../queue_archive/ORDER-457.md)의 실제 General 완주에서
Time Ledger239/Run Record240 불일치를 확인했다. final autosave는 turn240이며
분류합239, 현재 money축1/countdown 행동이 미정산이다. 비저자 두 명이 코드·저장을
직접 대조했다. 기존 QA_CHECKLIST의 보호 종막 ready→consumed 정확1회와
ScreenshotQA의 네 분류합=살아온 주 수 계약을 복구한다. 새 엔딩/시간/경제 규칙은 없다.

## 한 단위·근거

- 지우면: 마지막 밤 실제 선택이 원장에 빠지고 결말 두 페이지가 서로 다른 기간을 말한다.
- 장기 상태: W240 선택 흔적이 직렬화·재로드/엔딩 기록까지 정확1회 남는다.
- 경쟁: 날짜·월말 비용·정신/숨은 도덕 마모를 추가 실행해 수를 맞추지 않는다.
  과거 미분류 주를 추정 복원하지 않고 기존 turn241·데모24 경계도 보존한다.

## 파일 소유·범위

- root `autoloads/GameState.gd`: 기존 consume wrapper의 성공·최초 소비에서만
  `finalize_action_axis_week(false)`를 호출한다. 기존 함수 기본값true는 불변이고
  false에서는 네 분류/합·돈/사람 주 수·최근 행동·현재 버퍼만 정산한다.
  grind_streak/정신/MORAL_TINT/피로 로그는 불변. reducer/latch·finish_run/selector·
  달력·AP·경제·저장 스키마/호환/자동복구는 바꾸지 않는다.
- root `scenes/MainGame.gd`: turn240·유효한 보호 종막 consumed일 때만 원장
  record_turn=240. 기존 generic turn−1·데모 경계는 그대로다. 새 UI문자열0.
- phone_cn_author `tools/Chapter5FinaleRouteCheck.gd`: 기존 wrapper fixture만
  확장해 Property/General·네 축·최초/중복/직렬화 재소비·마모/경제 불변을 검사한다.
- root `tools/ScreenshotQA.gd`: 기존 원장 fixture에 보호 종막 turn240/합240과
  과거 consumed/합239 미분류1 표본을 추가한다. 기존 turn241/legacy 표본 보존.
- root 운영: 이 사양/완료archive·큐·CLAUDE 마지막갱신·WORK_LOG·생성STATUS.
  phone_independent_review가 실제 diff/기존 계약/표적 결과를 전수 독립 검토한다.
  새 checker/self-test/runner/계측·오더별 형식보고0. 장 단위 기존457 보고를 보존한다.

## 검증·완료

선언 commit/push 뒤 구현한다. 기존 Chapter5FinaleRouteCheck를 pre-autoload 새
격리로 실행해 exact marker와 stdout/engine 오류를 함께 검사한다. 기존 ScreenshotQA
원장 표본 KO/EN·1280×800과 EN Hangul·서사/데모 영향·context/queue/diff를 표적으로
확인한다. 새 실패0·비저자 정확1회/부수효과0 판단 전 완료하지 않는다. 엔딩 분기/
스케줄러/저장 구조는 불변이므로 전체240주·whole audit를 반복하지 않는다.
수리된 실제 후반 재플레이는 별도 선선언/격리에서 수행하고 준비 fixture와 구분한다.

원문/번역·project.godot·사용자 저장·원본 seed/checkpoint·과거 인간 판정·공개
M01~M06 변경0. 자동 PASS는 재미/원어민/인간/물리패드/전체제품/출시 GO가 아니다.
기존 제품 계약의 결함 수리이며 새 정본 규칙0·절차 일회성이다.

## 2026-10-10 구현·표적 확인

- consume wrapper 최초 성공의 W240만 기록을 정산한다. 기본 달력 호출의
  마모는 유지하고 종막에서는 정신/도덕/피로·날짜·경제·AP를 추가 소비하지 않는다.
  이미 consumed인 옛 저장은 역으로 채우지 않는다. 원장은 유효한 consumed
  W240에만 240주를 쓰며 turn241·데모 경계는 기존대로다.
- 기존 Chapter5FinaleRouteCheck exit0/exact marker `terminal-axes=profiles2/cases4/once-json/no-extra-wear`.
  Property/General 네 축·최초/alias 중복/JSON 재소비·pending/closed·기본 마모 대조
  전수 PASS. `/tmp/gangnam-order513-route.FQkhUj` stdout/godot SHA각
  `2f75ef207fc8486ab0c3032262376c3b98613e734987391c5070aba502b70a43`, 오류/경고0.
- 기존 CompileCheck68 PASS(`/tmp/gangnam-order513-compile.5aZtF0`). 기존
  ScreenshotQA ap-act-en KO/EN1280×800 각각 exit0/exact marker·16컷·오류/경고0.
  root가 새11/12 네 화면을 직접 확인했다:132+108=240/기록240/footer240,
  옛 consumed131+108=239/미분류1/footer240. 준비 상태이며 자연 플레이 증거가 아니다.
  KO `/tmp/gangnam-order513-surface-ko.vCIiUP` stdout SHA
  `06fe25a7f1a0dc8808f73720875c4fec9ebc749849c13bc87aaec764ffc1c056`;
  EN `/tmp/gangnam-order513-surface-en.0EE1JB` stdout SHA
  `7ae529ce391b6180f9fe0855620547b7b90982b533934a613adf083529b5c0cf`.
- EN coverage/Hangul·finale route·서사·음악·데모 고정·표면언어 PASS, diff 오류0.
  standalone general finale audit의 lifecycle shipping1708 고정 실패1은
  ce0a32b 동일 파일/동일 원인(실제1696)임을 원함수로 대조했다. 새 실패0이며
  검사/KNOWN_FAILURES를 넓히거나 이 기존 실패를 PASS라고 쓰지 않는다.
- 기존 helper.snapshot fresh 대조로 helper5/seed2/W215/player33가457 종료 전과
  전수 동일. W238/W200/W195/510bak도 원 SHA 유지, 사용자 editor61385 생존.
  수리된 실제 W238→종막 재플레이·CI 새 head·최종 source 결속은 별도다.
