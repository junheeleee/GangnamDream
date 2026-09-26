# Active Queue Spec: ORDER-286

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

[~] 착수 — 2026-09-26. 블랙잭 조작·기록13키 중국어26값.

#### [~] ORDER-286 [P0·전체 현지화] 블랙잭 조작·기록 중국어26값

## 목적·분모

읽기전용 `order285-next-ui-scope.json`(SHA c28d76b13c8fd3434a5b9f363bb3f41822a8ed7627c9313ade8736a7dfb7e769)의
selected_rows13을 고정한다. BlackjackTable 직접16호출과 공유6호출의 이름·기록·
베팅 선택·카드 행동·다음 핸드 안내다. 한국어에서 간체·번체를 각각 독립 저작한다.
기존 JA13은 그대로 보존하며 새 수용으로 세지 않는다. 중국어 사전 각13 추가와
공식26 수용만 목표다. 정산·환불·규칙/EV11키와 직행EN/동적 결과는 제외한다.

깊이3문: 없으면 해당 중국어 조작 안내가 영어로 남는다. 저장·24주 상태 변화는0이며
새 선택이 아니다. 같은 자리에서 행동명과 버튼 안내의 짧고 정확한 의미가 경쟁한다.
13은 이 소비자 묶음의 실제 크기이며 목표 수량을 맞추려고 정산 채무를 섞지 않는다.

## 정확 소유

- `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`: 고정13키 append만.
- `content/meta/full_game_localization.json`: 기존40103/b129/meta9 보존,26값과 배치1 추가.
- `CLAUDE.md` 현재 상태 한 줄, 큐 두 파일, 이 활성 사양/종료 시 archive286,
  WORK_LOG, STATUS, agent_review_decisions, agent_reviews/ORDER-286.json.
- git-private `.git/full-game-localization/order286*`: 별도 언어 원고·독립 검수,
  기존 export/check/import의 source/response/receipt, 유한 검증 캡처·패치 helper.

런타임·KO/EN·JA·공개데모·human_gates·project·출시언어·기존 검사/래칫은 불변.
게임 산식·금액 정합 수리·새 checker·새 렌더 하네스·전체감사·240주 실행은 비소유다.
스플릿 추가 비용/AA 카드 수의 의심은 별도 재현/수리 범위이지 이번 번역 GO가 아니다.

## 순서·검증

1. 선언 commit 후 기존 한국어 호출과 인자·공유 reader, protected/held 비충돌을 확인한다.
2. 고정13 exact leaf ID로 locale별 export; 독립 KO 초안·비저자26값 전수 대조.
3. check 후 append; 적용후 새 export/check/import --accept로 현재 target hash를 묶는다.
4. portable에26 추가. 기존40103/source manifest/사전 원형의 역복원과 JA·보류72·공개
   바이트를 검증한다. 원어민/실화면은 미관찰로 둔다.
5. 기존 news-panel-locale-only 고정12 검사 목록만 재사용한다. private 실행기는
   이 선언의 전체 baseline diff 소유권을 따로 확인하며 이전 오더 소유권을 확대하지 않는다.
   기존 검사·원문·기준선 수정0; 첫 실패를 보존하고 같은13×2 모집단을 수리한다.
6. 비저자 최종 리뷰는 실제 원문·26값·형식/지역 문자·수용증거·보존·검사 원문을
   읽고 clean source commit/tree와 review HEAD에 work_unit 한정 결속한다.
   종료 metadata6·diff-check만 실행하며 같은 검사를 이유 없이 재실행하지 않는다.

자동 계약은 재미·원어민·실화면·물리 패드의 증거가 아니다. 공개GO1·인간OPEN45·
본편HOLD 유지. 규범 승격 없음: 기존 I18N/WORK_UNIT 적용, 이번13키·도구 지시는 일회성.

## 실제 최초 검사와 표적 수리

명명12 최초 실행은 언어/회귀10·context1 PASS, queue-consistency1 FAIL이었다.
사양의 표준 상태 머리말 누락만 위처럼 수리했다. 기존 검사나 제품/26값은 변경0.
같은 source의 새 clean metadata 후보에서 영향받은 queue-consistency/context2만
재확인하며 최초 실패·원래11 PASS를 따로 보존한다. 무관한10을 재실행하지 않는다.
