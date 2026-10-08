# ORDER-485 — 카지노 용어집의 중국어 수량 오탐3문맥

#### [x] ORDER-485 [QA] source-bound 수량 역할·기존 검증 보존 — 한정 GO — 2026-10-08

## 깊이3문 / 근거

- 지우면: ORDER-484 준비 원 translation_errors32에서 정상6값이 10개 숫자진단으로
  거절된다. 11일 기간이 아닌 점수11, 3颗/3顆의 주사위, 세 주사위의3을 처리해야 한다.
- 독자: full_game_localization.translation_errors → zh_translation_audit.validate_text;
  static_ui_coverage도 KO pointer escaped canonical ID로 같은 함수를 읽는다.
  새 번역 수용/원장 발급/게임 상태 변화0이다.
- 경쟁: 원문이나 번역을 왜곡해 검사를 만족시키지 않고 정확3 UI문맥 숫자 역할만
  정렬한다. 광역 classifier/day 면제·target whitelist·진단 삭제는 하지 않는다.

위임 근거는 사용자 현지화·검수 효율 지시와 WORK_UNIT이다.
원실패 .git/order484-20261008.QsF61I/draftpreflight1/result.json SHA
13fd959538ff4f9460125f3395c881f82741e7cdfb1ad3a3ab8e3b44e6c0d24b.
독립 원실패 검수는 번역오류가 아닌 parser오탐을 직접 확인했다.
이 단위는 source3의 수량 검사만이며 전체 용어집·중국어·제품출시 GO가 아니다.

## 선택 / 파일 소유

source3는 실제 JeongseonCasino._show_casino_glossary의 더블다운 설명,
다이사이 설명, 빅/스몰 설명이다. 정확 KO literal + escaped ui:<KO>:/<pointer> +
CN/TW만 적용하고 KO/source hash·owner가 달라지면 기존 경로를 유지한다.

- order484_author: tools/zh_translation_audit.py만. 3문맥 numeric pair helper와
  validate_text 우선순위만 추가한다. 원 숫자 역할/card2·추가card1·배수2·점수10/11·
  dice3·합계11~17/4~10을 검증하고 허가된 span만 mask한다.
  원문 기반 script·돈·BBCode·newline/paragraph·placeholder·English·용어 검사는 보존.
- order484_history: tools/zh_dice_title_consumer_self_test.py만. 옛 DIRECT/STATIC/
  SOURCE_FIXTURE/OFF_BASELINE/main과 원 함수·모집단을 보존하며 --casino-glossary-only
  새 focused CLI를 추가한다. 정상6 + 각 source/owner/locale OFF 및 missing/changed/
  extra/duplicate/sign/percent/time/money/token/script/layout/역할교환 반례와
  원 translation_errors/static consumer·예외 복원을 직접 검증한다.
- root: tools/audit_scope.json 새 exact 차선/CLI등록, 큐/L3/사양/archive·WORK_LOG 및
  허용 history raw 롤링·생성STATUS·CLAUDE 현재상태 한 줄·agent 판정 원장만.
- order484_review: docs/agent_reviews/ORDER-485.json만. 원source3/6실패·변경diff·
  정상/음성모집단·실제소비자/원로그·candidate를 전수 읽고 이 수리만 GO/HOLD.

파일 범위2+등록1, 배치1. 신규module/helper 역사수정0·collector/main 함수교체0.
선언 commit/push 뒤만 구현한다. 독립 테스트 예상 모집단을 코드수리 전에 동결한다.

## 검증 / 종료

1. 준비32의 원실패를 보존하고 같은32를 원 translation_errors로 다시 실행한다.
2. 새 focused CLI만 실행, old Dice20/전체ZH self/전체UI/240주·원공식/engine 반복0.
   원 numeric validator의 비소유 문맥 결과를 before/after로 대조한다.
3. 전체tracked/HEAD·보호project/사용자·공개/human·원입력과 함수 정체성 입출구를
   검사하며 실제 결과/실패/불변과 검증하지 않은 모집단을 구분한다.
4. 등록/목록/context/queue/diff·L2전7칸·독립 최종 원문보고와 source identity 결속.
   새실패0 전 완료금지, 484의 공식 export/check/import/수용은 별도 미완료다.

새규범0/일회성. source/locale/receipt/게임/사용자 저장/seed/project.godot·과거인간
판정과 공개M01~M06 변경0. 자동검사는 계약 증거이지 재미·깊이·문체 증거가 아니다.
본편HOLD·공개GO1·human OPEN45/done1·native/human/physical 관찰OPEN·외부권한0.

## 같은 단위의 REWORK / 재착수 — 2026-10-08

source eaa860169bdf9286d4abdc6452caa727e2c108cf/tree9af1728b2a34dc9a880804e88bc9cf3a6b3123e9의
원232/direct·220/full·210/격리static·복원3와 준비32는 실제PASS로 보존한다.
그러나 독립 검수는 정확2倍 뒤 以上/半이 허가될 정적결함을 발견해 REWORK했다.
docs/agent_reviews/ORDER-485.json(SHA5d88cead3b1153da0e48d45f834d53a18ed4a5be1d5d8627c5d3622b7b09c805)은
이 eaa 후보의 원REWORK보고이며 덮어쓰지 않는다. 경로/hash는 fixture의 별도 관측이지
lang/key/source/target만 받는 helper가 synthetic path/hash를 직접 검사한다는 뜻은 아니다.

- 코드수리 전 별도suffix8(CN/TW×以上/半/以下/左右) SHA
  887e0b4454406c3de7637d91334888db6cf35c172ad1ab31451be53c9514bd58을 동결했다.
  원228·OFF34·추가script4·원draft32·원FAIL/PASS는 변경0이다.
- root 실제before8 direct/full/격리static 모두 오류0으로 잘못 허가했고 기대는REJECT다.
  order485-suffix-before.json SHA64038d5689c76f878f93f753d5fd04545cf326d0e644e04e5068e0d6dbea6dae:
  quality_passed=false/exit1·false_acceptances8·observation_complete/preserved=true,
  main/collect/engine0이다. 정상번역 수용이나 품질GO가 아니다.
- order484_author는 같은 ZH 파일의 bet multiplier 단위 바로 뒤 positive 경계만
  추가한다. 수평공백 뒤 절구두점 [，,。.;；] 또는 문자열 끝만 허용하며 한자/Latin
  연결어를 선제 허용하지 않는다. 첫 suffix4종 denylist는 아직 검증0이며 동일
  부분마스킹의 多/余/餘/上下를 못 막으므로 대체한다. 정상2는 모두 倍 뒤 쉼표다.
  other helper/일반 숫자/원문·번역·영수증/생산guard 불변.
- order484_history는 같은 self 파일에 별도8 및 추가경계12 기대/chrono만 추가한다.
  추가12는 CN/TW×多·余/餘·上下·任·x·수평공백+多로 경계수리 전 따로 동결한다.
  root는 이12의 실제 before도 원 direct/full/격리static으로 기록한다.
  원232 및 228+4의 배열·기대·기본CLI는 보존하고 실제총252으로 같은 focused CLI를 다시
  검증한다. 알려진결함 수정이 재실행 이유이며 모집단 축소/옛PASS 삭제0이다.
- root는 등록의 final 보고경로1만 추가하고 새선언·QA·증거/후보를 결속한다.
  비저자의 후속 최종보고는 docs/agent_reviews/ORDER-485-final.json만 소유한다.
  새candidate/실제252·준비32·등록/변경분 검사 전 GO/완료/484 공식수용0이다.

깊이3문·단위/배치1·파일소유/금지/외부권한 경계는 위 계획 그대로다. 이8개는
별도수리 범위가 아니라 원정확2배 역할을 닫는 미수리 결함이다. 새규범0/일회성.

## 같은 원수량 역할의 카드 경계 REWORK — 2026-10-08

- source3ffd028/tree06cb8efd에서 실제252/direct·240/full·230/격리static·212음성·
  예외복원3와 같은준비32, 등록/목록/context/queue/diff는 PASS로 보존한다.
  독립 읽기는 initial/additional card의 [张張]牌 뒤 以上/多도 같은 부분마스킹
  경로에 남는다고 확인했다. 최종발급/완료/484공식수용은 아직0이다.
- 같은 저자/소유 ZH에서 初2·追加1 역할만 match.end()(牌 포함) 뒤 positive 경계를
  닫는다. 실제 초기牌后，/牌後，와 추가牌。는 허용하고 다른 역할·원검사·원문/
  초안/영수증은 불변이다. 경계 방식은 비저자가 정상2를 직접 읽어 판단한다.
- 같은 self 저자는 별도card8(CN/TW×initial/additional×以上/多)을 수리 전에
  따로 동결한다. root actualbefore8 뒤만 추가하고 기존252/기대/기본CLI는 보존해
  총260을 재검증한다. 최초부터 소유한 정확2장/1장 역할의 같은 결함이며 새장면/
  원고/파일/전체검사 범위0이다. 실제260·같은32·변경분검사·새후보/독립final 전
  GO/완료0, 원 eaa REWORK 보고와3ffd PASS/seal은 덮어쓰지 않는다. 일회성이다.

## 최종 수리 / 실제 검증 / 독립 한정 GO — 2026-10-08

- 최종 source3 `aefc0798680ae001a6116d1b0510ea711b41cce2` /
  tree `aa7042eb671a713182fa899d9f76a13c5bb79f14`를 main에 push했다.
  배수·初2장·追加1장 뒤 positive 경계를 닫았으며 정확 KO3/escaped ID/CN·TW만 ON이다.
  helper API는 lang/key/source/target이고 실제 path/hash는 별도 fixture 관측이다.
  synthetic path/hash를 이 API가 직접 검증한다고 주장하지 않는다.
- 최초228/OFF34·script4·suffix8·boundary12·card8을 별도 시간순 동결했다.
  원252/232의 배열·기대와 원 draft32를 보존했다. card before8은 clean660aee에서
  direct/full/격리static 모두 잘못 허가됨을 실제 확인했다:
  order485-card-before.json SHA
  3a8a7d001c50f351e8443d4ee0e10f853d264900874f4aa4d39d9d016c8340b3,
  quality_passed=false/exit1·false_acceptances8·보존true다.
- 최종 actual260=228+4+8+12+8, direct260/full248/격리static238/음성220/예외복원3
  PASS. full의 skip12는 JA-OFF6+malformed pointer6이며 전체UI census가 아니다.
  per-case flags6214/global flags21 true, 원 collect/main 실제관측0/0이다.
  JA에 build_scope 속성이 없으므로 observed build_scope=0 카운터를 주장하지 않는다.
  고의 주입 RuntimeError traceback3만 구조적으로 허용했고 그 외 payload의 오류 탐지는 유지했다.
- order485-rework-checks2/result.json SHA
  4e39368438db76feb2311d08dc00b7766e5d75b3da2038423ea4560ea5f9af81:
  전체7명령 actualexit0/14.319211875초/errornull/입력보존true.
  집중260 11.571959875초, 같은준비32 1.567876초, 등록·목록·context·queue·diff
  나머지5다. --list --lane은 등록목록이고 그 차선4개를 실행한 것이 아니다.
  집중stdout SHA93dd13d0daac6279ff21454126ec96024f5d03d007d078d9ba10bdf795a987c8.
  준비32결과 SHAa46433d3930ad063dcfc3597980407c38daf2e9571be4eba4702c560d27cc2ac,
  실제 원translation_errors32/errors0/PASS, pureAPI0.165836292초다.
- QA는 660aee HEAD+소유2dirty에서 실제 실행했다. 뒤 CLAUDE의 비소비 현재상태
  252→260 행1 전이가 있어 최종aefc에서 신규QA를 실행했다고 쓰지 않는다.
  clean read-only seal order485-card-seal.json SHA
  55c9103fff424e4630f07a35ca6fc407a1ffe4ac09ad183f7f5bdd01f99cf519:
  wholetracked3251 중 QA입력은 그 상태행 외 동일, 원Git/raw/함수역상/동결6/
  보호6/원REWORK/증거80 SHA를 직접 결속했고 preserved=true다.
  seal은 추가 소비자/engine/공식 수용 검사가 아니다.

### L2 전7칸 / 결속

| 원본 | 호출 | 입력 | 반환·표시 | 실패 | 불변 | 증거 |
|---|---|---|---|---|---|---|
| ZH helper9289/validate9395·9474 | 원직접/ full3142/격리static10441 | frozen260·KO3/escaped ID/CN·TW·JA OFF | 정상6 오류0·음성220 거절·direct260/full248/static238 | old suffix8·boundary10/12·card8 false accept 보존, 고의예외3만 구분 | 원228/OFF34/후속4+8+12+8·원검사/기본CLI/복원3 | checks2/result 4e393684…·stdout93dd13d0…·final보고 |
| 원translation_errors32 | draft_preflight 원API32 | 원draft2 SHA9ce30189…/정확선택2 | 실제32 errors0·수용0 | 최초6 FAIL/10진단 보존 | 원draft·selection/IDs·main/collect0 | prepared32/result a46433d3… |
| 변경분5 / seal | 등록218·목록·context·queue·diff / read-only seal | exact차선·wholetracked/HEAD·QA로그 | 명령5 exit0 / 증거80·보존true | 초기wrapper/옵션/seal실패와eaa REWORK 그대로 | protected6·old보고·ledger280/41855·locale/gameplay | checks2/result / card-seal55c9103f… / final보고 |

각 행의 실제 파일/함수/라인·예외·출력 전수는
[독립 최종보고](../agent_reviews/ORDER-485-final.json)에 결속한다. 이 표의 축약SHA는
위 완전SHA와 해당보고로 식별하며 별도 실행으로 세지 않는다.

### 판정 / 보존 / 남은 일

- 비저자 /root/order484_review가 최종source aefc/treeaa704의 이 수량도구만 GO:
  docs/agent_reviews/ORDER-485-final.json SHA
  3dda1e783b022c6432a9b20bd5d1c6bf7edf55095acbbebe8241278da0fcb67c.
  원eaa REWORK 보고5d88…와 기존 판정247을 유지하고 별도 신규GO 판정을 추가한다.
- 일반/자연 의미·허용되지 않은 paraphrase까지 판정하는 수리나 전체중국어 품질GO가
  아니다. finite 정상표현 밖은 원경로로 거절될 수 있다. static은 실제Entry/UiInventory의
  격리단일 fixture며 wholeliveUI·실제render/input 관찰이 아니다.
- 게임 원문·JA·locale사전·ledger280/41855 변경0·공식용어집32 수용0이다.
  원484를 재개해 실제export/check/import·전이/준비소비자 검증을 이어간다.
  KO/JA natural 사실오문2와 카지노 UI 잔여17은 별도 OPEN이다.
- 새규범0/모든 실행·exact결속 지시는 일회성이다. gangnamdream-dev의 표적·소유·
  실패보존·독립/인간 증거분리를 적용했다. 자동 통과는 재미·깊이·문체 증거가 아니다.
  본편HOLD·공개GO1·human OPEN45/done1·native/human/pad·실제화면/자연플레이·
  external release·wholepipeline 성능은 미관찰/잔여이며 project/사용자저장/공개원문/과거판정은 보존했다.
