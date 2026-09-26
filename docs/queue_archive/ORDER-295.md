# ORDER-295 — 카지노 금융 중국어 실제 표시

[x] 2026-09-27. 비저자 작업 한정 GO. 신규 번역·정산 코드 변경 없음.

- source `987b64d8912130e93f899187967c9da6a02632d8`, tree `554c14432b864f1f8f564cd37f498be802930b6b`. [독립 보고](../agent_reviews/ORDER-295.json) SHA `6cf5e43d9d680d0ad4f1564d612e1c3865f28c6eca1d5e2b4a3d55fb78547c2c`.
- 수용18키/CN·TW36값을 실제1280×800 각13화면, 총26PNG로 확인했다. 17고유키·18 visual reader, 나머지1키는 실제 수수료 지급로그2건이다. root와 비저자 모두 원본26PNG를 직접 읽었다.
- 미납5000/100000·음수/양수/0손익·남은카드50/100%·원금포함총수령180만원과 순이익175만원·마우스/키보드/Xbox 표시를 분리했다. 실제 Button/Label/RichText 소비자와 SC/TC폰트·glyph·자연크기·버튼 내부여백·ancestor clipping을 검사했다.
- 수용된 CN/TW 두 실행 합계 raw Enter/Esc press/release8이벤트, 비화면 유료종료2건, 준비된 룰렛 실제 finish callback4건(승2/패2). 승리 현금995만→1175만, net+175만; 패배 현금995만 유지/net−5만. 종료 현금1000만→999만5000·미납5000→0·net−5만 유지·로그1·closed1/지역. RNG 불변. 실패한 CN2회도 별도 보존하므로 실제 graphical 실행은 총4회이며 위 수용 모집단과 합산하지 않는다.
- 표시 구간은 serialized GameState/AP/meta/settings/files/table typed 전후 불변. effectful 구간은 현금/로그/통계/숨은경향+2/메타play+1와 격리meta파일만 정확히 비교했다. namespace는 autoload 전에 새로 분리했고 실제 사용자43파일·제품입력은 전후 SHA 불변이다.
- Baccarat 예시 카드는 player[0,4] 합6/banker[2,3] 합7의 합법적 완료형으로 준비했다. 과거 계획의 player[0,1] 합3은 추가 드로우가 필요하므로 준비 전 조정했으며, frozen계획·금융oracle·모집단은 수정하지 않았다.
- 실행 전 독립 검수에서 private Button 측정기의 raw margin/마지막 줄 뒤 간격 과대계산을 발견했다. Godot4.6.2 실제 식의 effective margin·줄 사이 간격으로 수리했고 첫 REWORK/원본 helper와 후속 preflight를 보존했다. 제품 수리나 실제 엔진 실패로 세지 않는다.
- CN 첫 실행은 oracle JSON float와 실제 int의 Dictionary 비교 때문에13수치 행을 거절했고, 별도 진단은 카드 등장 중인2화면24 Label의 scale을 거절했다. 이 실패의13PNG·세 로그·관측값·helper를 그대로 보존했다. 숫자 oracle만 유한한 exact 수치 비교로 수리하고 실제 카드 애니메이션 정착0.25초를 기다린 뒤 전체13경우를 새 폴더에서 재실행했다. typed 런타임 비교·geometry 기준은 완화하지 않았다.
- CN 두 번째 실행도 실패로 보존했다. 실제 정착캡처는1.802~1.895초로 통과했으나 메시지 timer가 wall-clock1.8초 직전에 끝나 준비단계의 하한 assertion이 먼저 실행됐다. 관측기는 메시지 숨김과 wall-clock1.8초를 모두 기다리도록 수리했고 기존2.2초 상한·13경우 모집단·모든 실제캡처 기준을 유지했다.
- 도달: ORDER295_FINANCIAL_OK states=13 keys=18 exits=1 callbacks=2 raw_events=4, 각지역. 생산자↔독자: locale/ui_zh-*.json ↔ BaccaratTable/RouletteTable/JeongseonCasino. 상태: 미관측 금융표시→26화면·로그2·callback4 한정 관측. 제거손실: 금액/상태/긴 번역 소비자의 표시 증거. 서사/계층: 기존 카지노 UI·새 장면 없음. 닫음: exact 금융 표시 배치만.
- 이는 준비된 컴포넌트·결과 callback이지 무작위 spin/debit/애니메이션·정상진입·게임 로그 UI·인간/원어민/물리패드 관측이 아니다. 원화 만원 단위 반올림(95000→10万/萬,9995000→1000万/萬)은 기존 의미로 남는다.
- 이전292/293의188 raw,294의named12,전체감사·240주를 반복하지 않았다. 마감 문서검사는 선택기6종(context/queue/queue-self/원장/원장self/생성현황)이며 별도 기록한다.
- 공식40213/b133/meta9·보류72·공개GO1·인간OPEN45·본편HOLD 유지. 남은 룰렛 선택버튼·Odd/Even 공유소비자·직접영어와 바카라 raw결과로그는 후속 별도 범위다. 자동 PASS는 계약 증거이지 재미·깊이·출시 승인이나 인간 판단의 대체가 아니다. 규범 승격 없음: 기존 WORK_UNIT/UI/입력 계약의 일회성 적용.

## 최초 선언 원문

# Active Queue Spec: ORDER-295

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-295 [P0·실제 표시] 카지노 금융/상태 CN·TW 26화면과 지급로그2건

**[~] 2026-09-27 Codex 착수 — 아래 exact 범위만 소유한다.** 사용자
“순서대로 진행해” 및 ORDER-157의 UI 소비자 검수 위임. 기준 clean main
`6c943d5b00587eb8cc4ed80aa06f0b6dae926fe8`. ORDER-294 수용18키/36값의
표시·상태 소비자만 확인하며 292/293의188 raw입력은 반복하지 않는다.

## 깊이 3문·모집단

1. 제거 손실: 번역36값의 실제 Button/Label/RichText 읽힘과 금액 의미가 미관측으로 남는다.
2. 24주 상태: 제품 변경 없이 준비된 상태의 렌더와 격리된 callback만 관측한다.
3. 경쟁: 새 번역 확대 전에 이번18키의 긴 안내·수수료·총수령/순이익 오독을 확인한다.

1280×800, CN/TW 각13PNG(바카라3·룰렛9·정선1), 총26PNG.
17고유키·18 visual reader이며 나머지1키는 실제 지급로그2건으로만 검수한다.
private `order294-next-render-scope.json`의13경우/언어와 비화면 exit경우를
이번 실행 모집단으로 채택한다. 그 파일의 선언 전 source핀은 역사값이며
이번 accepted36·현행소스·oracle·helper핀을 실행 전에 새로 결속한다.

- 바카라: 0수수료/규칙·음수net+미납5000·양수net+미납100000.
- 룰렛: BET누락 경고·mouse/keyboard/Xbox preview·원금포함총수령·준비된
  SPINNING·실제 finish callback의 당첨 임시표시/정착RESULT·독립패배표시.
- 정선: 실제 component 헤더 공유잔액. open/자식게임/정상 ingress는 호출하지 않는다.
- 실제 raw Enter/Esc press/release 각1쌍/언어만 사용한다. brand override는 합성이다.
- 준비된 spin결과의 `_finish_spin` 호출은 실정산 callback 증거이지 무작위
  spin/debit/애니메이션이나 정상 게임판 증거가 아니다. 지급로그는 PNG로 세지 않는다.

## 파일 소유권

- root: private `order295-render.py`, `order295-oracle.json`, 실행별 immutable
  output·bootstrap 및 source/userdata핀. 큐2파일·이 active/archive·WORK_LOG·
  CLAUDE 현재상태1행·생성STATUS·agent_reviews/ORDER-295.json·판정원장 append1.
- 구현 에이전트: private `order295-financial-observer.gd`만.
- 독립 검수자: private `order295-preflight-review-*.json`,
  `order295-independent-review-*.json`만. helper/제품 저작 금지.
- 제품 runtime·locale·수용원장·project.godot·KO/EN/JA·공개/인간 원장 비소유.
  확인된 제품 결함은 별도 오더에서 exact 수리범위를 선언하고 원래 모집단 재검수.

## 검증·실패 보존·완료 경계

UI/입력 프로필과 QA 계약을 적용한다. 기존 ScreenshotQA형 실제컴포넌트
관측 helper를 이번 부모/상태에 한정하여 사용한다. 언어별 serial graphical
launch, autoload보다 앞선 fresh namespace 확인, 원본 userdata 모든파일
SHA 불변, source·helper·oracle·폰트 SHA 전후불변. stdout/stderr/엔진log의
오류0·정확한 marker·exit0·정상 teardown을 함께 요구한다.
순수표시 중 serialized GameState/AP/meta/settings/files/table state 불변.
지급exit/승패callback은 지정된 cash/net/counter/history/log/숨은경향+2/meta
play+1/격리meta파일만 허용하며 전체typed delta를 기록하고 그 외는 실패다.
새 fixture 준비와 실제작동을 분리 기록하고 RNG 사용 여부를 과장하지 않는다.
모든26PNG를 root와 비저자 모두 원해상도로 읽고 exact raw/parsed텍스트·
SC/TC font·glyph·Button내부여백·자연크기·실제ancestor clipping을 대조한다.
동일원문 named12/전체감사/240주 반복0. docs 변경은 context·queue·원장·
dashboard·diff와 선택된 표적게이트만 실행한다. 실패시 원래모집단과 실패자료를
유지하고 새 evidence폴더에 재실행한다. 숨김/강제스크롤/검사완화 금지.
공식40213/b133/meta9·보류72·공개GO1·인간OPEN45·본편HOLD 보존.
원어민/인간/물리패드/다른해상도·플랫폼/패키지/전체카지노 승인으로 확대하지 않는다.
자동 PASS는 계약 증거이며 재미·깊이·인간 판단의 대체가 아니다.
규범 승격 없음: WORK_UNIT·UI·입력 정본을 적용하며 이26화면과 실행구성은 일회성이다.
