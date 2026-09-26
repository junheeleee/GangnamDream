# Active Queue Spec: ORDER-298

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-298 [P0·표시 수리] 다이사이 하단 행동 버튼의 1280×800 잘림을 고친다

**[~] 2026-09-27 Codex 착수 — 아래 파일만 소유한다.** ORDER-297 첫 CN/TW
실행의 같은 결함을 수리한다. 관측 source `084bd68b94db605ad1fc5595f442bbb29da6c4ad`.
두 지역·홀짝4화면 모두 ROLL/Default Bet/Casino Hub 버튼 y753+54=807로
화면800을7px 넘는다. root VBox851, table panel y76+757=833. 원본8PNG·40raw와
실패 출력은 `.git/full-game-localization/order297-render-{cn,tw}-first`에 보존한다.

## 깊이 3문

1. 지우면 무엇이 깨지는가: 하단 행동 버튼이 끝까지 보이지 않고 표적 표시 게이트가 실패한다.
2. 장기 상태가 다른가: 여백만 달라진다. cash/AP/직렬화 상태/입력·배당·RNG 변경은 허용하지 않는다.
3. 무엇과 경쟁하는가: 기존 모든 베팅/금액/행동을 같은 첫 화면에 유지하면서 수직 여백을 배분한다.

## 한 배치 15단위

1. 첫 두 지역의 전체 실패/8PNG/40raw를 덮지 않고 원인과 실제 경계를 결속한다.
2. observer/validator 결함이 아닌 실제 제품 VBox 최소 높이 초과인지 독립 대조한다.
3. 사용자 파일43개와 locale/receipt/project/human/공개 원형을 봉인한다.
4. `_build_ui`의 table separation9→4로8간격의40px를 확보한다.
5. body top/bottom margin18→12로12px를 확보한다(예상 전체851→799).
6. 글자·버튼·아이콘·배당·줄바꿈·visibility·scroll·논리 값은 그대로 둔다.
7. 변경 diff가 위 세 상수에 한정되는지 독립 검수한다.
8. 최초 oracle/helper를 보존하고 후속 source pin만 새 후보로 결속한다.
9. CN Roulette 홀짝2상태를 원래 strict oracle로 재검수한다.
10. TW Roulette 홀짝2상태를 원래 strict oracle로 재검수한다.
11. CN DaiSai 홀짝2상태와 모든 visible text/footer 전체 경계를 재검수한다.
12. TW DaiSai 홀짝2상태와 모든 visible text/footer 전체 경계를 재검수한다.
13. 원래40raw·typed snapshot·cash/AP/meta/files/RNG 불변과 실제 timer 종료를 재검수한다.
14. root/비저자가 후속8PNG 전수를 보고 축소·숨김 없이 첫 화면 적합을 판정한다.
15. 표적 검사와 독립 source-bound 판정 후297/298 각각 정확한 work_unit으로 닫는다.

## 파일 소유권

- root: `scenes/DaiSaiTable.gd`의 위 `_build_ui` 여백3상수만.
- root 기록: 이 사양→`docs/queue_archive/ORDER-298.md`, 기존297 완료 archive,
  `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md` 순번만,
  `docs/WORK_LOG.md`, 생성 `docs/STATUS.md`, `CLAUDE.md` 현재 상태 한 행,
  `docs/agent_review_decisions.json` 새 work_unit 두 행,
  `docs/agent_reviews/ORDER-297.json`·`ORDER-298.json` 독립보고 복사.
- 원래 oracle/validator 저자: 새 git-private `order298-*` 원본 보존·binding 기록,
  `order297-oracle.json` provenance/source identity와 `order297-render.py` oracle SHA만.
  expectations/keys/values/route/validator/observer 완화 금지. 필요 helper 오류는
  원인·원본을 보존하고 별도 독립 재검수한다.
- reviewer: helper/제품 비저자, 새 private `order297-*review*.json`·`order298-*review*.json`.
- root: 새 private `order298-*` capture/보존/closure/check; 첫297 helper 원본 보존 사본.

## 검증·경계

297의 동일8PNG·40raw·13키(12 visible+helper0 nonvisual)·독립 전체 부모문장
oracle·모든 visible control/canvas 측정을 그대로 적용한다. 새 exclusive output,
실제 pre-autoload UUID 격리·두 marker·exact success·exit0·engine error0·유저 파일
전후 동일을 요구한다. 함수 직접 호출로 입력을 대체하거나 가짜 timer/스크롤을 쓰지 않는다.
표적 context/queue/ledger/dashboard/diff와 audit selector를 사용하며 기존 금융26화면,
188raw·번역 named12·전체 감사는 반복하지 않는다.

새 번역/다른 UI/게임로직/정산/오디오/저장 포맷은 비소유다. 작은 수직 여백의
가독성은 실제8화면으로 판단하며 폰트·버튼 크기는 줄이지 않는다. 정상 진입,
무작위 라운드, 다른 해상도, 원어민/인간/물리 패드, 전체판·패키지 GO는 미관측이다.
공개GO1·인간OPEN45·본편HOLD 유지. 자동 PASS는 재미·깊이·문체 판단의 대체가 아니다.

**규범 판정:** 이 결함·수리 상수·15단위·증거 구성은 일회성이다.
계속 유효한 UI/I18N/WORK_UNIT 규칙은 기존 정본을 그대로 따른다.
