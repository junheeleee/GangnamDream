# ORDER-286 — 블랙잭 조작·기록 중국어26값

[x] 2026-09-26. 비저자 독립 검수 work_unit 한정 GO, 필수 결함0.

- source `f0231d46b7def4c2b3f50279970f470071b84e87`, tree `6c79ab5a7d35697ed3c69e4f5099f97cd3d0edf1`; clean review `9b8fec87429d5f0a915bbded9481f5e7c1f8ec3f`, STATUS와 활성 상태 머리말만 바뀐 metadata wrapper.
- 블랙잭 이름·기록·베팅 선택·카드 행동·다음 핸드 KO13키를 간체/번체에서 각각 독립 저작했다. BlackjackTable16와 공유6 literal 호출의 의미·인자에 맞추며 JA13은 변경/신규수용0이다.
- 要牌/停牌/加倍下注/分牌/下一手로 행동을 구분한다. %s·슬래시·금액 −/+·x2·구분 공백과 기록 접미 공백을 유지했다. 지급/환불/수익 보장 문구를 추가하지 않았다.
- 공식 preflight export/check13×2 후 append, 적용후 새 export/check/import --accept13×2 모두 PASS다. 적용후 import의 changed_files0과 독립 원고/설치/receipt 일치를 구분한다.
- 공식40129/b130/meta9. 기존40103 source/target·portable와 중국어 사전 raw 역복원, JA/KO/EN/runtime·공개·인간 원형 유지. 원문 manifest 2af00468 유지.
- 기존 명명12 최초 실행은11 PASS·queue 상태 머리말 누락1 FAIL이었다. active 사양의 표준 머리말만 수리하고 최종 clean metadata 후보에서 queue/context2 PASS를 확인했다. 이미 통과한 언어/회귀10은 재실행하지 않았다. 원래12 실행·후속2를 최종12 전량 재실행이라고 하지 않는다.
- 최초 실패·전후 입력·clean HEAD/tree·child stdout/stderr 원문을 보존했다. 제품/26값/기존 검사 변경0, 새 엔진/실화면/전체감사 실행0이다.
- 상세 방법·증거·한계는 [독립 보고](../agent_reviews/ORDER-286.json), SHA `12408f98f6f3d0ea877b35cc267bab9ac8b9a17862a47e02f419ed30ec1272ce`에 결속한다.
- 정산·환불·규칙/EV11키, split 추가 비용/AA 카드 수 의심, 직행EN·동적 결과는 비소유다. 이 한정 GO는 블랙잭 전체 번역/산식/화면이나 본편 GO가 아니다.
- 원어민·인간·물리 패드·실제 화면 미관찰. 공개GO1·인간OPEN45·본편HOLD·보류72 유지.
- 규범 승격 없음. 기존 I18N/WORK_UNIT 적용이며 이번13키·배치·검사 재사용은 일회성이다.

## 최초 실제 캡처

git-private에 stdout/stderr bytes·SHA·exit·입력핀을 원형 보존한다.

| 파일 | 바이트 | SHA256 | exit | 결과 |
|---|---:|---|---:|---|
| order286-accept-cn-first.json | 378450 | 200441ca552d381ce2065dbfbac97ebc9dfeca58c084529fc7cbf4c8f9b3a673 | 0 | PASS |
| order286-accept-tw-first.json | 378450 | 5fceb39c15cdcb5582221b921f1abc65791cd5aebe742e33f1f4f1355e6b14d7 | 0 | PASS |
| order286-applied-check-cn-first.json | 378445 | 9fcbd3c2d531adb54715aa38827d107974953d8178414ae597a1522712e950dc | 0 | PASS |
| order286-applied-check-tw-first.json | 378446 | 3cba7a9211972c344c95058f04d7fbbe0963415619845fda67c2a6c3353f80e0 | 0 | PASS |
| order286-applied-export-cn-first.json | 378540 | 39d8b2124726e6304508b4fd34915e5ee2afd7879fd252a42ea43b2fc9006b53 | 0 | PASS |
| order286-applied-export-tw-first.json | 378540 | 2e633b8c589ea74acf38e6b3c941274249708ee3ff28a9fa1a811a2856fc9cc9 | 0 | PASS |
| order286-check-cn-first.json | 378441 | 759fa0aad12675b78b73a24548d84ce8aa744c9c2e6f4ffe05d32a984427c28b | 0 | PASS |
| order286-check-tw-first.json | 378435 | 94cae0a80ef13a2377f92bc91add9b480c9f3086f6e27e9afc1f5419b28313ff | 0 | PASS |
| order286-context-repair-first.json | 378242 | ef029012cb81532620ff0f060113c04ea7b0f5f2074d40d7fdf83a5dbfbc52dd | 0 | PASS |
| order286-export-cn-first.json | 378536 | 1cb131ebbc9aa6c8dd454917612bb56983991df1af80986a2acb1914bd32b44d | 0 | PASS |
| order286-export-tw-first.json | 378536 | c2ba0dd8994b3b66d07eed8735a839d9c28b73e9d164dc609fbeb0416736148a | 0 | PASS |
| order286-named-envelope-first.json | 380566 | 9cbcdd1e85b4bfc7898f0d77664fc350d51b4f5c67de5d6ade59f65c71a9cc70 | 1 | FAIL retained |
| order286-named-first.json | 1703611 | 3be0aa7240fa55348ed72a5a42f6413a83152bf93111aa4fb76e7412f9276aea | 1 | FAIL retained |
| order286-preservation-first.json | 378802 | d72f7b88473a01e1e3063d5cff0da4bad02a128a1d964941ad3c8a4887ad0d57 | 0 | PASS |
| order286-queue-repair-first.json | 378071 | 9631f99a67b7b8e2522b228870211efdddbf9908ac11e413aaf73183947895e2 | 0 | PASS |

## 이전 WORK 원문

# Gangnam Dream Work Log

> 이전 WORK·선언·검증 원문은 [285 보존본](queue_archive/ORDER-285.md)에 있다.

## 2026-09-26 (Codex — 고지 세 언어 실제 화면)

- [285](queue_archive/ORDER-285.md): source 180f7ed / exact review 73fb10c, 비저자 한정 GO.
- 실제 고지의 JA/CN/TW14역할×3=42 정확 표기와 클립/스크롤·합성 Down/Back 복귀를 확인했다. 신규36·기존6을 구분하며 실제 라이선스 원장·본문은 그대로다.
- 사용자 저장·게임/meta·source 입력핀 보존. 원어민/인간/물리 패드·다른 해상도·패키지 미관찰. 런타임/번역/인간 원장 수정0.
- 공식40103/b129/meta9·보류72·공개GO1·인간OPEN45·본편HOLD 유지. 이 UI 한정 검수는 전체판 번역 완료가 아니다.

## 다음 안전한 범위

- UI사전3028 중 CN/TW각2061키 부재는 전체 live UI 분모가 아니다. 다음 실제 producer/consumer 묶음을 별도 선언해 번역한다. 실제 화면의 남은 직행EN·동적인자는 별도 범위다.
- 읽기전용 다음 후보는 order285-next-ui-scope.json(20299B/SHA c28d76b13c8fd3434a5b9f363bb3f41822a8ed7627c9313ade8736a7dfb7e769)의 Blackjack 조작/기록13키다. JA13 유지·CN/TW26 후보일 뿐 신규 선언/저작/수용0이며, 정산·환불·규칙/EV11키는 split/추가비용 정합 위험으로 제외했다.
- BigWheel JOKER배 부모·바카라 수수료 이중차감/타이 원금과 튜토리얼은 별도 원문/산식 채무다. post283-baccarat-accounting-scope.json 계획은 실행/수리/GO가 아니다.
- 보류72(268의62·270의10)는 월말 net==0·첫월급 투자접근·시장/AP효과·자산10억 절반·저자산 초기판정·잠/식사 고지 등 원문 정합 수리가 필요하다.
- 비보호 shipping 사건11578 세 언어 수용, 잔여843은 참고741·보호102. 공개판·역사 인간 판정을 보존한다.
- 재개 시 check/import에도 --locale 명시, 새파일 포함 staged diff-check 성공 뒤 commit. 실패 원형을 남기고 동일 모집단을 수리한다.

## 최초 선언 원문

# Active Queue Spec: ORDER-286

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

[~] 착수 — 2026-09-26. 블랙잭 조작·기록13키 중국어26값.

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

## 표준 머리말 수리 후 활성 사양

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
