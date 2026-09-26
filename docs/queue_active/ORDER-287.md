# Active Queue Spec: ORDER-287

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-287 [P0·실제 화면] 블랙잭 중국어 조작·기록 가시성

[~] 착수 — 2026-09-26. 만지는 파일은 아래 정확 소유로 한정한다.

## 목적·분모

286의 중국어26값이 실제 BlackjackTable에서 잘리고 빠지지 않는지 관찰한다.
읽기전용 계획 order286-next-render-scope.json(SHA cc831f82ef0ff88a3b2b6989a3f7392a76779ecc0c983f1c88b5ee10c88d0ea2)의
최소안만 고른다. CN/TW×BETTING/history·H/S/D/P·RESULT 6상태=12표시상태,
고정13키·Table16 literal 호출의 가시표기를 본다. 실제 basic_strategy가 반환하는
H/S/D/P를 쓰며 hand/result/history는 명시적 준비 상태이지 실제 플레이 결과가 아니다.
공유6 호출·JA/KO/EN·직행EN/동적 결과·규칙/EV11은 이번 렌더 분모에 넣지 않는다.

깊이3문: 없으면 승인26값의 실제 가시성은 미관찰이다. 상태/24주 선택을 추가하지
않는다. 같은 화면에서 조작 안내가 카드·금액·버튼과 공간을 나누는지 판정한다.

## 정확 소유·역할

- CLAUDE 현재 상태 한 줄, 큐 두 파일, 이 active/archive287, WORK_LOG, STATUS,
  agent_review_decisions, agent_reviews/ORDER-287.json.
- git-private order287*: 고정 CN/TW 기대값·표시상태, 직접 실제 노드를 여는
  작은 observer와 기존 pre-autoload 격리 utility를 재사용하는 실행기·원형 증거.
- 저작 에이전트는 private observer만, ROOT는 private runner/큐/통합만,
  비저작 독립 에이전트는 구현·실제 출력·PNG 검수만 맡는다.

제품/runtime·번역/portable·assets·기존 검사·project·공개데모·인간 원장 변경0.
실제 UI 결함을 찾으면 실패와 정확 재현을 보존하고 새 수리 범위를 먼저 선언한다.
새 영구 검사/프레임워크·전체casino suite·240주·전체감사·게임 정산은 실행하지 않는다.

## 실행·증거

1. 선언 commit/push 후 기존 BlackjackTable·ControllerHints·bootstrap/격리를
   읽는다. 검수한 KO→CN/TW 원고와 각 인자 순서를 실행 전 기대값으로 고정한다.
2. 설치된 Godot 그래픽 renderer,1280×800, 두 언어를 각각 새 user namespace로
   pre-autoload 격리한다. 실제 사용자 파일 집합/해시와 제품 입력을 전후 보존한다.
3. 실제 6상태를 렌더하고 각 선택 Label/Button/RichText를 가시 영역에 놓아
   exact text·클립/크기·PNG를 남긴다. 직접 상태 주입/스크롤을 실제 조작으로 세지 않는다.
4. 별도 합성 입력은 BETTING 키보드 X·PageUp/PageDown 및 trigger press/hold/release의
   금액 증감/클램프, PLAYER_TURN Q/E 하이라이트와 불법행동 건너뜀,
   RESULT confirm→BETTING, BETTING cancel→closed, hidden/echo/invalid-phase
   무변화를 확인한다. 실제 딜·hit/stand/double/split 정산 입력은 보내지 않는다.
5. money/AP/rounds·게임/meta·namespace 파일의 불변 및 명시적 local stake/phase/focus
   변화만 인정한다. 튜토리얼/locale/forced glyph 설정은 setup이며 종료 때 복원한다.
6. 첫 실패를 원형 보존하고 동일12표시 모집단의 private fixture 결함만 수리한다.
   실제 종료 exit·stdout/stderr/Godot log 오류·PNG·source pins를 각각 확인한다.
7. 비저자가 clean source/tree·review에 실제12와 입력증거/PNG를 결속한다.
   마감은 metadata6·diff-check만, 번역검사와 이전 고지 렌더는 반복하지 않는다.

자동 계약은 재미·원어민·인간·물리 패드의 증거가 아니다. fresh StoryMode 도달성·
정산 정상화·모든 해상도·전체 언어/제품 GO를 주장하지 않는다. 공식40129/b130/meta9,
보류72·공개GO1·인간OPEN45·본편HOLD를 유지한다. 규범 승격 없음, 이번 범위는 일회성.
