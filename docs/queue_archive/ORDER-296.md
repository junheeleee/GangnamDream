# ORDER-296 — 룰렛 선택 유형·홀짝 공유 소비자 중국어

[x] 2026-09-27. 비저자26값 전수 작업 한정 GO, 필수 결함0. 실제 화면/입력은 별도 후속이다.

- source `0328647cd17995d06f0d0d49861959982e6f82d1`, tree `dd3dd372c8c1051a4e64e5c0ec38a7eb80a3abc3`. [독립 보고](../agent_reviews/ORDER-296.json) SHA `71081f49d4fed9a53a5f85dfdc06a900b65678f1835cb13ea4ef260f0d32e089`.
- KO13키를 CN/TW에서 독립 직접 저작했다. 단일 번호와 홀짝을 구별하고 기존 색/구간/묶음 용어, 줄바꿈10개/지역, 번호범위·순번·35:1/1:1/2:1을 보존했다. CN 单个数字/奇数/偶数, TW 單一號碼/單數/雙數.
- 17 literal reader(룰렛15/DaiSai2)는 정적 소스 범위다. `_bet_type_label(0)`의 단일 숫자는 현재 유일 caller가1~9를 넘겨 정상 노출이 확인되지 않는다. 나머지도 이번에 실제 렌더/입력으로 관찰한 것은 아니다. 홀짝은 룰렛 결과와 DaiSai 합계의 성질이며0/트리플 제외는 각 모델의 규칙으로 남겼다.
- 공식 사전 export/check와 적용후 새 target-hash export/check/import 각13 PASS. named12 표적검사 PASS. 원문·게임규칙·계산·입력 코드 수정0.
- 공식40239/b134/meta9(신규26). 기존40213 pin·사전1022값/지역·portable raw inverse 보존, 각1035키. JA3028 reference 대비 CN/TW각1993 부재(전체 live UI 분모 아님). JA/KO/EN/runtime/project/공개/human 원형 불변·보류72 유지.
- 도달: FULL_LOCALIZATION_BATCH_VALID locale=zh-CN/zh-TW leaves=13. 생산자↔독자: locale/ui_zh-*.json ↔ RouletteTable.gd:404,410,412,762,764,1020~1033 / DaiSai.gd:94,96. 상태: 각13키 부재→수용. 제거손실: 해당13키 영어 폴백. 서사/계층: 기존 카지노 UI, 신규 장면 없음. 닫음: exact26 번역·source-bound 수용만.
- 다음은 새 선택버튼·공유 홀짝 표시의 실제 화면/입력 검수다. 금융26화면·기존188raw를 이유 없이 반복하지 않는다. dead0 branch는 정상 노출로 만들지 않는다. 직접영어·다른DaiSai 버튼·바카라 raw로그·정선 원문채무는 별도 범위다.
- 원어민·인간·물리패드·일반진입·패키지 미관측. 공개GO1·인간OPEN45·본편HOLD 유지. 규범 승격 없음: 기존I18N/WORK_UNIT 적용, 이13키와 증거 구성은 일회성이다.
- 자동 게이트는 계약 증거이지 재미·깊이·문체 또는 인간 판단의 대체가 아니다.

## 최초 선언 원문

# Active Queue Spec: ORDER-296

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-296 [P0·현지화] 룰렛 선택 유형·홀짝 공유 소비자 중국어 26값

**[~] 2026-09-27 Codex 착수 — 아래 exact 범위만 소유한다.** 사용자
“순서대로 진행해” 및 ORDER-157 위임. 기준선 clean main
`1fd9590183fa6429a2f989c7a9a4a1311c6e8b1f`. 완료된295 화면 검사를 반복하지 않는다.

## 깊이 3문·범위

1. 제거 손실: 선택 버튼·현재 유형·다이사이 홀짝에 영어 폴백이 남는다.
2. 24주 상태: 언어만 달라지고 베팅·현금·확률·저장·시간은 불변이다.
3. 경쟁: 사전 부재2006키/지역 중 확인된13키·17 literal reader를 먼저 닫는다.
   이는3028 reference 기준이며 전체 live UI나 카지노 전체 분모가 아니다.

13 KO키 × 독립 CN/TW =26값. RouletteTable15 literal reader와 DaiSai2 reader다.
한국어 목록은 아래와 같으며 실제 줄바꿈은 JSON에서 보존한다.

- `단일 숫자`, `홀수`, `짝수`
- `단일숫자\n(35:1)`, `빨강\n(1:1)`, `검정\n(1:1)`
- `홀수\n(1:1)`, `짝수\n(1:1)`
- `낮음 1-18\n(1:1)`, `높음 19-36\n(1:1)`
- `1묶음 1-12\n(2:1)`, `2묶음 13-24\n(2:1)`, `3묶음 25-36\n(2:1)`

단일 숫자는 특정 번호 하나이며 홀짝은 양 게임이 공유하는 수의 성질이다.
지급비율·번호범위·줄바꿈을 그대로 두고 기존 색/구간/묶음 번역과 일치시킨다.
0·트리플 예외 규칙을 이 공용 라벨에 발명하거나 다른 게임 규칙으로 옮기지 않는다.

## 파일 소유권

- root: `locale/ui_zh-TW.json`13키 직접 저작, 검수된 `locale/ui_zh-CN.json`13키 반영,
  `content/meta/full_game_localization.json`26 pin·batch1 append.
- CN저자: private `.git/full-game-localization/order296-zh-CN-draft.json`만.
- 독립 scope/검증 보조: private `order296-source-scope.json`, 검사 driver만.
- 비저자: private `order296-language-review-*.json`, `order296-independent-review-*.json`만.
- root기록: CLAUDE 현재상태1행, CODEX_QUEUE·CODEX_QUEUE_L3_PENDING,
  이 active/archive, WORK_LOG, 생성 STATUS, agent_reviews/ORDER-296.json,
  agent_review_decisions.json append1; private `order296-*` 교환·증거.
- KO/EN·JA·runtime·project·공개판·human_gates·기존receipt·검사/기준선 비소유.

## 검증·판정 경계

사전 export → 지역별 KO 직접 저작 → 공식 check → 비저자26값/17 reader 전수
→ append → 새 target-hash export/check/import --accept → portable수용.
기존40213/b133/meta9·사전1022/지역·JA·원문·공개·인간 raw와 기존pin 보존.
신규 수용시40239/b134/meta9·각1035 예상, 실제값으로 확정한다.
기존 `news-panel-locale-only` named12 및 exact diff 보존 guard,
context/queue/원장/dashboard·clean source identity를 확인한다. 전체감사/240주 없음.
도달은 source-bound 정적 소비자 증거이며 실제 렌더/입력은 다음 별도 배치다.
생산자 locale/UI → RouletteTable/DaiSai, 신규 장면/선택 없음.
원어민·인간·물리패드 미관측, 공개GO1·인간OPEN45·본편HOLD·보류72 보존.
자동 게이트는 계약 증거이지 재미·깊이·문체 또는 인간 판단의 대체가 아니다.

규범 승격 없음: I18N/WORK_UNIT 적용, 이13키·소유권·검사 구성은 일회성이다.
