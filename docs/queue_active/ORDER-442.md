# ORDER-442 — 홀덤의 베팅과 안내를 중국어로 읽는다

#### [~] ORDER-442 [P1·현지화] 베팅·진행 단계·힌트 15키의 간체·번체 30값

**[~] 착수 — 2026-10-05.** 441 카드 수리를 완료한 게임에서 실제 남은 영어
fallback 소비자를 이어 번역한다. 사용자의 계속 개발·main 커밋/푸시 위임이다.

## 범위·소유

- root: private442 KO 목록·TW 직접 초안·공식 export/check/import·append/normal 증거 및 runtime Python runner,
  `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`, `content/meta/full_game_localization.json`,
  CLAUDE·큐/L3·이 사양/보관본·WORK_LOG·생성STATUS·새 agent 보고/판정.
- claude_handoff_review: private442 CN 초안과 runtime oracle helper. 한국어에서 직접
  저작하며 지역 변환0. Python runner와 oracle 파일을 분리해 병렬 작성한다.
- receipt_tests392: 새 private442 격리 GD/scene helper와
  `tools/audit_scope.json`의 명시 `holdem-betting-zh` 차선만.
- independent392: 비저자 30값 전수·실제 소비자·helper·화면/입력·최종 근거 검수.
  모든 공식 교환·collector·검사·engine 실행은 root만 한다. 기존 증거/helper 불변.
- KO/EN/JA·Holdem/Tutorial/TexasHoldem/Main/GameState/Meta/LocaleManager/FontKit·
  자산·AI/돈/덱/승패/타이머/AP/저장·인간원장·공개데모/출시 manifest 불변.
  기존202판정/180보고와 accepted41694/b211을 보존한다.

## 정확한 15키

1. `플랍`
2. `턴`
3. `리버`
4. `체크`
5. `1/3팟\n%s` — 실제 LF 한 개
6. `폴드했습니다.`
7. `체크.`
8. `콜 (%s).`
9. `레이즈 → %s`
10. `콜`
11. `레이즈`
12. `[%s] 돌아가기  [%s] 나가기` — 가운데 공백 두 개
13. `바이인할 현금이 부족합니다.`
14. `힌트: ` — 뒤 공백 포함
15. `다음 ›`

## 구현·표적 검수

- 두 지역을 한국어에서 별도로 작성하고 정확한 placeholder·LF·공백·화살표·원화
  수량을 보존한다. JA15는 기존 사전값이며 재저작/신규 수용으로 세지 않는다.
- 공식15×2 export/check/import·4파일 raw 역상으로 목표 accepted41724/b213,
  CN/TW1767·JA3044를 결속한다. 이전 수용/receipt/header/source는 다시 쓰지 않는다.
- proven pre-autoload CN/TW 각1프로세스. 각15고유키·버튼/AI 공유 체크의 별도
  consumer를 기록한다. 사전 검수에서 FLOP 버튼과 입력 뒤 Check transient를 분리해
  13관측·6PNG/지역으로 조정했다. 두 번째 Check는 별도 prerequisite 단계로 기록한다.
- 실제 Tutorial 첫 장의 힌트/Next와 다음 장 이동·취소, 준비49,999원 SETUP의
  실제 입력 거부, 준비 FLOP의 체크·1/3팟 버튼, 실제 Check로 TURN/RIVER 진행,
  별도 Fold/Call/Raise와 AI Check/Call/Raise transient, 실제 RESULT footer를 읽는다.
- 합법52장 partition·seed1/강도 구간·금액을 사전 결속한다. actual 메시지/승자/폰트
  주입0, 자연 딜·스토리 ingress 주장0. 플레이어0.3초/AI0.6초 문구는 post-draw에
  관측하고 타이머를 취소/바꾸지 않은 채 실제 player-wait/SHOWDOWN까지 소진한다.
- Fold의 실제 Esc→RESULT→Enter Close는 정산·Meta 파일·Main AP/로그 효과가 있다.
  준비 reader의 효과0과 합치지 않고 현금−10k/mental−5/AP−1 등 독립 기대와 대조한다.
  raw/tap/행동/SHOWDOWN/정산/Close와 prerequisite Check를 실측대로 따로 센다.
- 기존 SC/TC font·glyph·fit·actual bounds·겹침과 카드 수리를 보존한다. busy/타임아웃
  상태는 복원하지 않고 중단한다. quiescent 이후 whole typed/RNG/pending/generation·
  Main 의미focus·Tutorial seen·Meta 원래bytes/존재·논리BGM/Controller를 복원하며
  실제player34를 보존한다. 음원 playhead/전역 시각 RNG/노드identity 복원 주장은 없다.
- 같은 clean 후보에서 receipt/fullbody·ZH/EN·context/queue/diff/등록8검증+차선조회1,
  새 표적 화면만 fresh 실행한다. 441 카드/438 비동기/439 승패·과거 focused·
  434서사4종·JA audit·전체감사/240주/성능 A/B는 참조/NOT_RUN이다.

## 진행 증거

- 선언 `b6c85b1c38c1ce266923b911c4365035787cbe4e` main push 후 저작.
  CN/TW 별도15값·비저자30값 전수 의미/토큰 검수 PASS, 공식 check/import 각2 PASS.
  accepted41724/b213·CN/TW1767·JA3044. `.git/full-game-localization/order442-append-precommit.json`
  의4파일 역상·공식 헤더 보존에 결속한다. 화면/입력/정산·최종GO는 아직 미완료다.
- source0253803의 실제 두 지역 실행은 콜 문구 확대 잘림으로 FAIL이다.
  첫 원본 `order442-screen-first/result.json` SHA
  `2dc7dcb19da7edd0009466d8e6dd9a457bd03542f9a771930fca734cd23cd07b`를
  보존한다. 소스/player34 불변, 관측26·PNG12·raw48을 남겼으나 PASS로 세지 않는다.
  [별도443 수리](ORDER-443.md) 뒤 같은 문구/입력 묶음을 재검수한다.

## 깊이·한계·일회성

- 이 번역이 없으면 베팅 행동과 진행 단계·거부 이유가 영어 fallback으로 남는다.
  기존 선택을 이해하게 하는 수리이며 새 선택층·24주 결과·경제 규칙을 만들지 않는다.
- 규칙 동적 본문4키의 collector·직접 영어 FOLD/CHECK/CALL/RAISE/POT/STACK 등은
  별도 후속이다. 공통 Tutorial 두 키의 수용을 전체 Tutorial 번역 완료로 부르지 않는다.
- 지시는 일회성·정본 추가0. 자동PASS는 계약 증거이지 품질 GO가 아니다.
  공개GO1·인간OPEN45·원어민/인간/물리패드 미관측·본편/새package HOLD 유지.
