# Active Queue Spec: ORDER-385

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-385 [P0·전체 현지화] 중국어 거래 카드와 보유 요약 21키

2026-09-28 착수. 부모157, 기준 main `9a96544`. 선언 뒤 구현한다.
302의 successor package와352의5장 선행 대기는 별도이며 사용자 우선순위인 남은 번역을 이어간다.

## 깊이 3문·한 배치
1. 지우면 거래 버튼·비용·손익·빈 보유 상태가 중국어 대신 영어로 나온다.
2. 24주 뒤 경제·선택 변화0. 매수/매도와 평가손익의 기존 의미만 직접 번역한다.
3. 현재 카드의 제한된 폭과 경쟁하므로 숫자·조건을 보존한 간결한 지역 표현을 쓴다.
한 배치21키×간체/번체42값. 후보의 중복 호출24개는21키로만 수용한다.

## 정확한 파일·역할 소유
- 제품 `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json` 아래 누락 키 append와 `content/meta/full_game_localization.json` 공식42receipt/2batch append만.
- root: 사양/완료 archive·큐2·CLAUDE 현재행·WORK_LOG/허용 history·생성 STATUS·새 독립 보고/판정 원장·private385 교환/실행 증거.
- compat357 CN private 초안, screen_path_probe TW private 초안 및 private385 격리 화면 관찰기/실행기. 서로 한국어에서 직접 작성한다.
- r3_route_probe 비저자 전수42 의미·실제 소스·화면/증거 독립 검수. root만 공식 수용·엔진 실행한다.
- 기존 사전값/receipt·KO/EN/JA·runtime·도구·project·공개데모·인간 원장 비소유. 확인된 runtime 결함은 별도 선언한다.
- WORK_LOG 예산은 오래된 완결 항목을 `docs/history/WORK_LOG_2026-09-07_localization.md`로 원문 보존 이동한다.

## 정확한 키
- `거래 가능 자산 없음`
- `시장 데이터 없음`
- `자산 %d/%d`
- `↑↓ 자산 · ←→ 매수/매도 · LB/RB 페이지`
- `컨디션이 나쁠수록 매수 비용이 기본 0.3%보다 높아질 수 있습니다. 매도 수수료는 0.5%입니다.`
- `표시 %d-%d / %d — 스크롤 대신 자산 커서로 이동`
- `보유 포지션`
- `현재 들고 있는 자산만 요약`
- `아직 보유 자산이 없습니다. 거래 페이지에서 작은 금액으로 시작하세요.`
- `원금 %s → 현재 %s  (%+.1f%%)`
- `외 %d개 포지션`
- `매수 %s`
- `전량`
- `매도 %s`
- `가능한 거래가 없습니다`
- `리스크 %d/5`
- `가격 기록 축적 중`
- `1개월 %+.1f%%`
- `3개월 %+.1f%%`
- `12개월 %+.1f%%`
- `보유 평가액 %s  |  평단 %s  |  수익률 %+.1f%%`

## 검증·판정 경계
- 공식21/locale export/check/import; current append guard·중국어 normal·변경 영향 consumer5·context/queue/diff. 변경 없는 verifier self·전체감사·240주 반복0.
- 1280x800 준비 거래/보유 상태에서 사용 가능한/빈 자산, 낮은 컨디션 수수료, 양/음수 손익과1/3/12개월 이력, 빈 보유와4개 초과, 거래 불가 toast를 두 언어 모두 확인한다. 조건을 겸하는6개 prepared 화면/locale(총12PNG)을 기본 표본으로 하되 같은 모집단의 추가 화면이 필요하면 사양에 기록한 뒤 실행한다.
- 공식 수용 전 private draft를 격리 LocaleManager cache에만 넣어 동일 화면의 지역 font/glyph/폭을 예비검사할 수 있다. 이 증거는 제품 수용/실제 사전 검증으로 세지 않는다. 수용 후에는 cache 주입 없이 실제 사전으로 동일42lookup·소유 문구 구조 binding·폭/경계를 확인한다.
- 매수 기본0.3%보다 높아질 수 있음과 매도0.5%, `%s/%d/%+.1f%%`·화살표·LB/RB·기간·평가액/평단/수익률 구분을 보존한다. 매매 callback은 실행하지 않으며 거래 불가 경로만 호출한다. 공유 pad action label은 확인하되 미번역 부모 RichText4개의 전체 패드 UI를 수용하지 않는다.
- `전량`은 TradingFloor의 현금 전액 매수와 보유 전량 매도에도 공유된다. `全部` 같은 중립 표현으로 두 의미를 보존하고 실제 호출을 대조하되 TradingFloor 화면 전체 검수로 확대하지 않는다.
- frozen pre-autoload 격리·source/실사용자 파일 전후 보존·정확 marker·stdout/엔진 오류 확인. 중립 포커스는 표시 fixture이며383 안내 CTA focus 약3px 잘림은 미수리로 보존한다.
- 자산명/tag·은행/대출/레버리지 조건·시장 gauge·pad 부모·자연 진입/복귀·거래 정산·원어민·인간·물리·출시 판정 비포함. 공개GO1/인간OPEN45·본편/새package HOLD.
범위·역할·표본·계획은 일회성, 언어/보존 규칙은 기존 I18N/WORK_UNIT 재사용. 자동 PASS는 계약 증거이지 재미·문체·사람 GO가 아니다.
