# ORDER-287 — 블랙잭 중국어 실제 화면·표적 입력

[x] 2026-09-26. 비저자 독립 검수 work_unit 한정 GO, 필수 결함0.

- source `faca57dc3d779c1f3ed64f78721fbf7cfbb90a1b`, tree `aea53fa45077261042c7cb288769685802b2ce57`; clean review `25a5d3e6982e8007558fbe5831360e41a56f5ed0`. source 뒤 차이는 STATUS 하나다.
- 간체·번체 각각 betting/history·H/S/D/P·result 6상태, 합계12 준비 표시를 실제1280×800 Godot 그래픽으로 관찰했다. 언어별13키·Table16 literal site를 선택 표기31건씩(합계62) 정확히 관측했다. 새 번역 수용0이다.
- 고정13값은 기존286의 독립 승인 원고에서 가져왔다. 실제 H/S/D/P 전략 반환·사용 가능/불가 버튼을 확인했고 모든 선택 표기는 최초 화면 안에 들어왔다. 보조 scroll0회이므로 그 분기 통과를 주장하지 않는다. 직접 본 PNG는12장이다.
- 별도 합성 입력27×2=54사례: X·PageUp/Down, trigger press/hold/release와 양끝 클램프, Q/E 합법 행동 순환·불법 건너뜀, 결과 confirm→betting, cancel→closed, echo/hidden/PLAYER_TURN major 비적용. 키 사례는 press/release를 함께 보내므로 raw event54개라는 뜻은 아니다. 실제 입력 경로에 보냈지만 물리 기기를 조작한 것은 아니다.
- 실제 deal/hit/stand/double/split 정산 입력0. hand/history/result는 준비 상태이며 실제 게임 결과·fresh StoryMode 도달을 증명하지 않는다. 강제 PlayStation 글리프와 키보드 입력 모드 전환을 구분한다.
- 각 실행 source/helper/asset 입력핀1226 및 실제 full/demo 사용자 파일43 전후 불변. 각 표시·입력의 typed 직렬화 GameState/meta/money/AP/rounds·namespace 원파일 불변, local stake/phase/highlight/visible/closed_signals만 명시한 변화다. 재생성 UI·flash timer·controller last-device는 입력별 제외 항목이다. 종료 뒤 직렬화 GameState·meta 변수·locale/tutorial/settings/controller/mouse·namespace 복구를 실제 비교했다. locale cache/revision은 setup 효과이며 복구 주장 밖이다.
- private observer의 최초 정적 지적2(scroll-이미지 시점, 복구 readback)를 수리했다. 최초 보고의 SHA는 동시 수정 후 원문을 잡았으므로 수리 전 snapshot 핀으로 쓰지 않는다. 이 한계와 최초 보고 원형을 남겼다.
- 최초 CN은 private `TABLE.resource_path` 문법 오류로0이미지 FAIL. own runner에 SIGTERM을 보내 격리 engine group을 회수(exit-9)했고 raw3로그·result를 보존했다. 실행 원문을 별도 보존한 뒤 실제 instance Script 경로 조회 한 줄만 수리했다. 동일 모집단의 CN 후속/TW 최초는 모두 exit0·오류0·stderr0B·6PNG PASS다.
- 화면의 HUD·규칙·EV 부모 영어 누락3/언어와 직접 EN 도형·동적 결과는 제외 범위로 남는다. 선택13키의 검수로 블랙잭 전체 번역·원금/정산·~0.5% EV·가독성 전반을 인증하지 않는다. private audio teardown은 제품 종료 수리가 아니다.
- [독립 보고](../agent_reviews/ORDER-287.json) SHA `41130437a7ee7890b750d1701b3d10f3d61d82c499b8b5039657a5780c4a09f6`가 실제 로그·관찰 JSON·PNG 해시 및 방법을 결속한다.
- 공식40129/b130/meta9·보류72, 공개GO1·인간OPEN45·본편HOLD와 과거73 agent 판정 원형 보존. 제품/runtime/번역/portable/기존 검사 변경0. 원어민·인간·물리 패드·다른 해상도·패키지 미관찰.
- 규범 승격 없음. 기존 WORK_UNIT/UI/input 계약 적용이며 이번12표시·54합성 입력 사례·private 실행기는 일회성이다.

## 실제 실행 원형

result는 각 raw stdout/stderr/Godot log, PNG, source/user before/after를 bytes·SHA에 결속한다.

| 실행 | result 바이트 | SHA256 | exit | 결과 |
|---|---:|---|---:|---|
| cn-first | 406417 | 5e5b526199842c4067a27b3166b9a52e305c6b6eaf9fbe200bc14276d68ba134 | -9 | FAIL retained |
| cn-repair-first | 407243 | 337164c67ec885ba0af72ec05e1b86ea8caacc1b6e5ea2e4fdd4275f0a74c22c | 0 | PASS |
| tw-first | 407227 | 054d961bddf1759cf295dd0596f1d0d60f73358c13021101dbc1e22c4e3ef7c6 | 0 | PASS |

## 이전 WORK 원문

# Gangnam Dream Work Log

> 이전 WORK·선언·검증 원문은 [286 보존본](queue_archive/ORDER-286.md)에 있다.

## 2026-09-26 (Codex — 블랙잭 조작·기록 중국어26값)

- [286](queue_archive/ORDER-286.md): source f0231d4 / exact review 9b8fec8, 비저자 한정 GO/필수0.
- 블랙잭 이름·기록·베팅 선택·카드 행동·다음 핸드 KO13키를 간체·번체 각13 직접 채웠다. 실제16+공유6 literal 호출을 대조했고 기존 JA는 그대로다.
- 공식40129/b130/meta9. 기존40103 source/target·portable/중국어 사전 원형 역복원·JA 보존, 공식 교환 PASS. 명명12 최초11 PASS/상태 머리말1 FAIL을 보존하고 머리말만 수리해 queue/context2 PASS. 기존 검사·제품26값 수정0, 무관한10 재실행0.
- 이번 단위의 실제화면·원어민·인간·물리 패드 관찰0. 정산/환불/규칙11·split/AA 의심·직행EN/동적 결과 제외. 공개GO1·인간OPEN45·본편HOLD·보류72 불변.
- [285](queue_archive/ORDER-285.md)의 실제 고지42표기·합성 입력 관찰은 완료 기록으로 보존하며 이번 블랙잭 화면 증거로 전용하지 않는다.

## 다음 안전한 범위

- UI사전3028 중 CN/TW각2048키 부재는 전체 live UI 분모가 아니다. 다음 producer/consumer 묶음과 실제 표시·입력은 별도 큐 선언 후 진행한다. legacy/AP 소비자는 fresh-story/실화면 증거가 아니다.
- 읽기전용 order286-next-render-scope.json(20826B/SHA cc831f82ef0ff88a3b2b6989a3f7392a76779ecc0c983f1c88b5ee10c88d0ea2)은 기존 격리를 재사용하는 Table6표시상태와 공유6 별도 소비자를 구분했다. 다음 최소 권고는 새 번역 CN/TW의 Table6상태(12관찰)부터이며, 공유6은 미관찰로 둔다. 5언어/공유 전량안은 아직 선택·선언·구현·실행0이다. 새 fixture 전 정확 가시성/입력/상태 보존 모집단을 큐에 선언한다.
- BigWheel JOKER배 부모·바카라 수수료 이중차감/타이 원금과 튜토리얼은 별도 원문/산식 채무다. post283-baccarat-accounting-scope.json 계획은 실행/수리/GO가 아니다.
- 보류72(268의62·270의10)는 월말 net==0·첫월급 투자접근·시장/AP효과·자산10억 절반·저자산 초기판정·잠/식사 고지 등 원문 정합 수리가 필요하다.
- 비보호 shipping 사건11578 세 언어 수용, 잔여843은 참고741·보호102. 공개판·역사 인간 판정을 보존한다.
- 재개 시 check/import에도 --locale 명시, 새파일 포함 staged diff-check 성공 뒤 commit. 실패 원형을 남기고 동일 모집단을 수리한다.

## 최초 선언 원문

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
