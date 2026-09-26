# Active Queue Spec: ORDER-291

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-291 [P0·현지화] 카지노 베팅 준비금액·룰렛 조작 안내 중국어 44값

**[~] 2026-09-27 Codex 착수 — 아래 exact 범위만 소유한다.** 사용자
“순서대로 진행해”와 ORDER-157의 직접 한국어 번역 위임을 따른다.
기준선 `2b179c13c79f06a9fac8350f204db8d46414127e`의 clean main이다.
앞선 블랙잭 4값·표시 검수는 반복하지 않는다.

## 깊이 3문·범위

1. 제거하면 무엇이 깨지는가: 선택된 22키가 CN/TW에서 다시 영어로 폴백한다.
2. 24주 뒤 상태가 다른가: 번역만 바뀌며 현금·주차·정산·저장 상태는 불변이다.
3. 무엇과 경쟁하는가: 남은 UI 2046키/지역 중 실제 Baccarat/Roulette reader가
   확인된 한 구성요소 묶음이다. 규칙·정산·공유 동적 부모는 별도 단위로 둔다.

22 KO키 × 독립 zh-CN/zh-TW = 44값, literal 호출 33곳.
재현 목록·reader·제외 근거는 `.git/full-game-localization/order290-next-ui-scope.json`
(SHA `d404742f50523d27769df7ea69fca03d9e054933cfe41a033e74999b6d59ddb9`).
이 계획의 candidate ID는 공식 leaf ID가 아니므로 exact KO를 공식 collector로 export한다.

- `%s 모드`, `1묶음 1-12`, `2묶음 13-24`, `3묶음 25-36`
- `[b]%s[/b] · %s  [%s/%s] 모드  [%s] 칩/스핀  [%s/%s] 금액 −/+  [%s] 금액 +  [%s] 규칙  [%s] 취소`
- `[b]총 %s[/b]`, `[color=#d4a020]플 %s[/color]`, `[color=#e85d5d]뱅 %s[/color]`, `[color=#f0b429]타이 %s[/color]`
- `검정`, `낮음 1-18`, `높음 19-36`, `베팅 유형을 선택하세요`, `베팅 유형을 선택해 주세요`
- `베팅을 비웠습니다.`, `빨강`, `선택 전`, `숫자 %d`, `숫자를 선택해 주세요`, `숫자판`, `액션`, `외부 베팅`

Baccarat P/B/T는 배치 중인 금액이고 총액은 PP/BP까지 포함한다. Roulette
부모 안내와 mode/선택값을 함께 옮기며 입력·숫자 범위·색·토큰 순서를 바꾸지 않는다.
`홀수/짝수`는 DaiSai 저장/동적 영어 부모도 읽어 비소유다. BET/SPIN·PP/BP,
직접 영어 table 표기·배당/수수료/손익·나머지 UI는 그대로 남아 전체 카지노 번역이 아니다.

## 파일 소유권

- root: `locale/ui_zh-TW.json` 22키, `locale/ui_zh-CN.json`의 검수된 22키 반영,
  `content/meta/full_game_localization.json` 44 source/target pin과 batch 1 추가.
- 독립 CN 저자: `.git/full-game-localization/order291-zh-CN-draft.json`만 작성.
  root는 TW를 한국어에서 독립 작성하며 간번 변환을 하지 않는다.
- 독립 비저자 검수자: `.git/full-game-localization/order291-language-review-first.json`,
  `order291-independent-review-first.json` 및 검수용 private 증거만 작성.
- root 기록: `CLAUDE.md` 현재 상태 1행, `docs/CODEX_QUEUE.md`, 필요 시
  `docs/CODEX_QUEUE_L3_PENDING.md`, 이 active/archive 사양, `docs/WORK_LOG.md`,
  생성 `docs/STATUS.md`, `docs/agent_reviews/ORDER-291.json`,
  `docs/agent_review_decisions.json` append 1.
- private 교환/검사: `.git/full-game-localization/order291-*`.

KO/EN·JA·runtime·테스트/기준선·project.godot·공개 데모·human_gates·과거 번역/
receipt/판정은 비소유다. 새 runtime/렌더/입력 수리는 다음 별도 선언에 둔다.

## 검증·판정

사전 export → 독립 KO 직접 저작 → 공식 check → 비저자 44값 전수·33 reader 확인
→ append → 새 target-hash export/check/import --accept → portable pin 추가.
원장 40,133/b131/meta9와 기존 UI 982값/지역의 raw inverse 보존, JA·원문·공개·
인간 바이트 보존. 전체 manifest 변경 없이 새 44값만 수용한다.

`news-panel-locale-only` 기존 named 12검사 명시 재사용 + 전체 baseline diff의
exact 파일 소유권 guard. 이 lane 이름으로 카지노 전체 검수를 주장하지 않는다.
context/queue/독립 판정/생성 dashboard·diff 검사와 clean source commit/tree를 결속한다.
전수 비저자 검수와 관련 검사 없이는 완료하지 않는다. 실제 렌더·입력은 이 배치에서
미관측으로 남겨 다음 우선 작업으로 넘기며 원어민·인간·물리 패드·본편 HOLD를 보존한다.

규범: 기존 I18N/WORK_UNIT 정본 적용. 위 22키·파일 범위·검사 구성은 일회성이다.
