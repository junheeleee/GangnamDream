# Active Queue Spec: ORDER-297

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-297 [P0·표시/입력] 수용된 룰렛 선택 유형과 공유 홀짝의 CN/TW 실제 소비자를 검수한다

**[~] 2026-09-27 Codex 착수 — 아래 파일만 소유한다.** 부모 ORDER-157,
선행 ORDER-296 제품 `0328647cd17995d06f0d0d49861959982e6f82d1`, 시작 clean
`b6ef523c3d03dea26ad3b25673e96f16d077e6ef`. 번역/게임 코드 추가 수리는 별도다.

## 깊이 3문

1. 지우면 무엇이 깨지는가: 사전 수용만으로 새 10버튼·공유 홀짝의 실제 표시,
   줄바꿈·지역 서체·키보드 선택·금전 무변경을 입증할 수 없다.
2. 장기 상태가 다른가: 선택 표시만 바뀐다. 24주 경제·AP·통계·저장·RNG 변화는
   허용하지 않는다. 베팅/굴리기/회차 정산 증거로 확대하지 않는다.
3. 무엇과 경쟁하는가: OUTSIDE/SIMPLE의 홀짝 두 선택이다. 선택 커서와 실제
   선택값을 구분하고 반복 Enter로 DaiSai 굴리기를 시작하지 않는다.

## 한 배치 20단위

1. 13 source 키·26 accepted 값과 17 literal reader의 현재 SHA를 봉인한다.
2. 12 visible 키/16 reader와 일반 caller 없는 helper0 한 키를 분리한다.
3. 독립 oracle은 제품 번역값·부모 원문을 읽어 봉인하며 observed 결과로 만들지 않는다.
4. 실제 유저 파일 전수 census와 pre-autoload UUID 저장 격리를 잠근다.
5. 실제 Roulette를 생성하고 명시한 IDLE fixture 뒤 full typed baseline을 잡는다.
6. 실제 DaiSai를 생성하고 명시한 IDLE fixture 뒤 full typed baseline을 잡는다.
7. CN Roulette 홀수 선택 화면, 실제 10버튼·hint·canvas를 확인한다.
8. CN Roulette 짝수 선택 화면을 확인한다.
9. TW Roulette 홀수 선택 화면을 확인한다.
10. TW Roulette 짝수 선택 화면을 확인한다.
11. CN DaiSai 홀수 선택 화면, info·hint·feedback·canvas를 확인한다.
12. CN DaiSai 짝수 선택 화면을 확인한다.
13. TW DaiSai 홀수 선택 화면을 확인한다.
14. TW DaiSai 짝수 선택 화면을 확인한다.
15. locale별 helper0 direct return 1회와 상태 무변경만 확인한다(화면/일반 도달 아님).
16. Roulette Left/Enter/Right/Down/Enter, DaiSai Right/Right/Enter/Right/Enter를 dispatch한다.
17. 모든 입력·release·capture·wait·dispose의 정확 delta와 금전/전역/파일 불변을 확인한다.
18. 실제 글꼴·unclamped shaping·margin·줄 간격·clip·canvas transform을 전수 계측한다.
19. root와 비저자 reviewer가 8PNG 전수를 직접 보고 결함·미관측 한계를 기록한다.
20. source-bound 독립 판정, 원장 append-only, 다음 안전 범위를 기록한다.

## 정확한 모집단·방법

- CN/TW 각 1280×800 4PNG/20 raw event rows = 총 8PNG/40행.
- Roulette는 Left, Enter, Right, Down, Enter; DaiSai는 Right, Right, Enter,
  Right, Enter의 각각 5 press/release 쌍.
  `Input.parse_input_event`의 InputEventKey이며 echo=false; 직접 handler/pressed 호출 금지.
- Roulette initial: phase0, bet_type−1, chosen_number0, stake50000, bet_amount0,
  pad_mode0/outside_idx0/action_idx1/navigationfalse, rounds/wins/losses/net0,
  history[], last_result−1. cursor2→2→0→3→3, 선택−1→3→3→3→4,
  bet_amount0→50000→50000→50000→50000. spin/debit 없음.
- DaiSai initial: phase0, bet_type0, selected−1, stake50000,
  pad_mode0/simple_idx0/navigationfalse, dice/pending=[1,2,3], counters0/history[].
  cursor1→2→2→3→3, bet0→0→2→2→3. 첫 Enter는 다른 선택; roll 없음.
- baseline 뒤 cash10000000·AP·complete GameState/meta/meta_new/settings/logs,
  RNG·나머지 typed table state·저장 파일 불변. release는 no-op.
- Roulette 이동 flash는 실제 1.8초 만료와 message hidden/footer restored 뒤 capture.
  DaiSai feedback은 지속형이므로 강제로 숨기거나 가짜 만료를 기다리지 않는다.
- 10 Roulette button full text의 줄바꿈·범위·35:1/1:1/2:1 보존. canvas도 실제
  draw font/size/baseline/width/panel transform으로 unclamped shaping을 검증한다.
- 단일 숫자 `_bet_type_label(0)`은 현재 ordinary caller 0. return만 검사한다.
- `.git/full-game-localization/order296-next-render-scope.json`
  SHA `52d93c9073e630e3537c9c84c927a5bf0ba85837b5c36ee82082f4f393d964a0`
  세부 fixture/reader/geometry 계획을 입력으로 사용한다. 현 제품 SHA는 재확인한다.
  사전 독립 리뷰에서 제안의 Roulette Right-only 선형 이동은 실제 3열 가로 wrap과
  불일치했다. 위 Left/Enter/Right/Down/Enter로 선언 전에 교정하며 odd capture는
  locale raw4행 뒤, even은10행 뒤다. 제안 원본은 덮지 않는다.

## 파일 소유권·분업

- root: 이 사양→`docs/queue_archive/ORDER-297.md`, `docs/CODEX_QUEUE.md`,
  `docs/WORK_LOG.md`, `docs/STATUS.md`, `CLAUDE.md` 현재 상태 한 행,
  `docs/agent_review_decisions.json` 새 work_unit 판정 1행,
  `docs/agent_reviews/ORDER-297.json` 독립 보고서 복사. 과거 원장/보고서 byte 보존.
- observer author: 새 git-private `order297-selection-observer.gd/.tscn`만.
- oracle/validator author: 새 git-private `order297-oracle.json`,
  `order297-validate.py`, `order297-render.py`만. root만 엔진 실행.
- 독립 reviewer: helper 비저자, 새 git-private `order297-*review*.json`만.
- root 보조/증거: 새 git-private `order297-*` capture/check/closure와 run 폴더.
  모든 실패 출력 보존, existing evidence overwrite 금지.

## 검증·경계

새 exclusive 디렉터리에서 serial graphical Godot gl_compatibility/opengl3 실행.
StoryNameplateBootstrap pre-autoload 저장 격리 두 marker와 exact completion marker,
exit0, stdout/stderr/Godot log의 script/parse/engine error0을 모두 요구한다.
전후 source/locale/helper/oracle/font/user 파일 SHA를 비교하고 timer/audio를 drain한다.
표적 audit_select·context·queue·human/agent ledger·dashboard·diff 검사를 쓴다.
완료된 295 금융26화면·292 188raw·296 번역 static suite/전체 감사는 반복하지 않는다.

KO/EN/JA/중국어 사전·receipt·게임 코드·project.godot·공개 데모·인간 원장은 비소유다.
DaiSai의 별도 `홀수\n1:1`/`짝수\n1:1` 빠른 버튼과 영어 chrome은 알려진 미번역이며
이번 296 parenthesized 키 완료로 세지 않는다. 일반 ingress, random play,
정산·로그, 다른 해상도, 원어민, 인간 플레이, 물리 패드, 오디오 품질은 미관측이다.
결함이 있으면 숨김·축소·강제 스크롤·oracle 완화 없이 증거와 별도 수리 범위로 남긴다.
전체 본편 HOLD·공개GO1·인간OPEN45 유지. 자동 PASS는 재미·깊이·문체 GO가 아니다.

**규범 판정:** 위 모집단·fixture·helper·파일 소유권은 일회성.
UI/입력·언어·판정의 계속 유효한 규칙은 기존 정본을 변경 없이 따른다.
