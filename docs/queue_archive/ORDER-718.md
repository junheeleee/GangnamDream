# ORDER-718 — 기존 본편 월말 결산의 실제 현금 변화·원인

#### [x] ORDER-718 [C2/C5 기존 UI] source 통합 완료 — 2026-10-18

DECISIONS 2026-10-16 3번. 1/5수리·과거2그림집계 뒤, 실제C1과병렬로 한결산화면만
다듬는다. 새화면·AP·행동판·주도권/밸런스/정산순서 변경0. 717패키지/714수정앱·CI를
방해하지 않도록 privateclone에서 저작하며 root제품 통합은717 export검증과 실제월
checkpoint가 끝난 뒤다. 현재M37HOLD/M38미진입·월최대2·CI진행≠녹색/새월조건 보존.

## 확인된 원인·한 단위

MainGame709는본편결산숨김(false,false). 9033 snap은4주루틴/월간처리뒤이고,
22909 net=월수입−고정비만계산해 실제당월cashΔ가아니다. show_summary=true만으로
자동begin_month와모달이겹칠수있어 현존모달·정산/저장 once를 함께 보호한다.
현재월초현금1회앵커→월말압박직후동결cashΔ와 이름있는 실제원인·월말잔액을
**기존 `_show_month_summary` 한화면**에서 보이게 하는 한단위다.
routine_receipts의요청액이아닌 actual money합계, 실제월수입/월세/이자·잔차만이름붙인다.
잔차를근거없이 투자/특정사건탓이라하지않는다. 과거앵커없는저장은부분기록을명시한다.
저장성공뒤모달·확인전새본문진입차단, 확인/재로드가정산·루틴·RNG를다시실행하지않게한다.
표시전용pending/ack는기존flags에작게보관가능·게임플레이조건flag/저장버전변경0.

## exact 파일 소유

root: 이사양/archive·CODEX_QUEUE/L3·CLAUDE현재행·WORK_LOG,
`.git/order718-month-cash-summary-20261017/`의 cleanclone/격리fixture준비·원raw/
생성PNG·보호/후보/통합영수증. 원프로젝트/사용자16.2/17.1/17.2/공개/과거판정은보존한다.
private clone base37089e77b05b2b6c4aceeadf733d22e4c536283f, codex/month-cash-summary-718.
`/root/m32_path_review` 저작소유(private clone 안에만):
- `scenes/MainGame.gd`의 본편월초현금앵커/기존결산 내용·표시만.
- `locale/ui_ja.json`, `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`의 필요한신규UI키만.
  기존CJK본문/기존UI다듬기/번역원장 재결속0, 5언어누락소비자만보충한다.
- `tools/ManualSaveCheck.gd`, `tools/ScreenshotQA.gd`의 기존검증에 좁은새사례만.
- private author-report.{md,json}·source-diff.patch만. 제품root/타인파일/Git/엔진/UI실행0.
`FullStoryFlow.gd`, `GameState.gd` 및 기존publicdemo 흐름은 읽기만·변경필요하면먼저root에보고.
`/root/av_audio_status`: private `qa-admission.{md,json}`만·root의fixture helper/
fresh공식engine사본/원project대조·pre-autoload Bootstrap/6소유파일만검수한다.
실행0·제품/userpath쓰기0·기존717보고동결·표적QA격리한정, 최종제품GO대신아님.
root만추후 exact diff통합·proven pre-autoload 격리QA를실행한다.
`/root/m32_isolation_review`: private independent-review.{md,json}만·실제코드/패널/원raw직독.
검수자 Git/QA/engine/UI/실사용자경로/제품쓰기0. 717지정보고와충돌하지않는다.

## 표적 검증·판정

기존ManualSave의월말저장재시도/루틴once를보존하며 실제cash합계·pending확인중복·
quiet월/재로드/저장실패/oldsave앵커없음 사례를더한다. 기존결산KO/EN1280×800을
직접render해 한화면의현금Δ·원인·잔액/잘림·겹침을확인·기계render≠사람관찰.
기존음성검사/실제제품동작검사삭제·느슨화0. 영향 source/UI/ManualSave·docs5+diff만,
전체로컬/240주0. 새월플레이/본편C1완료/외부상점·Steam조작/출시GO0.
깊이3문: 숨긴월말이면숫자압박이보이지않는다. 기존선택/24주대가는불변이며표시만참으로
회수한다. 경쟁은기존돈/몸/사람선택이고 새배분기능을만들지않는다. 계층/산문저작0.
승격0·승인DECISIONS/기존UI·저장계약적용·나머지일회성.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

## 선언 정정·실행 메모

db8254e의L3이동행gate누락을d9141be에서즉시교정했다. 원human98 두OPEN과출시후보류는
그대로이며 새사람판정0. 이단위의표적검증→stage→commit 묶음은 fail-fast로 실행해
앞검사실패뒤commit으로흘러가지않게한다. 제품예외/검사완화가아닌일회성실행교정이다.

초안QA의확인된UI오류는생계→Livelihood가기존ambiguous키와충돌한것이다.
원source6/author보고/원patch·원5호출은동결보존한다. 같은6파일만 private `source-v2/`
사본에서저작자가수리하며 `author-report-v2.{md,json}`/`source-diff-v2.patch`만추가한다.
생계수입의고유KO/EN키와필요한JAzh신규키만교정·정산/receipt/조건/검사registry완화0.
root는원QA완료뒤같은fixture에수리byte만기계복사하고기존cache로표적UI/static/render만
재검수한다. label-only라통과한정산·저장전체검사를이유없이반복하지않으며원실패는보존한다.

첫KO render는 complete1컷뒤 partial CTA기하검사에서실패·EN미실행이다. 원PNG의원인5금액도
보이지않으므로 v2까지동결하고 같은6파일의 `source-v3/`에서 표시너비/모달배치만수리한다.
저자는 `author-report-v3.{md,json}`/`source-diff-v3.patch`, root는 `recheck-helper.py`/
`recheck-plan.json`/`recheck-*` 원로그·결과/`rendered-v3/`만추가한다. 숫자5개실표시와CTA
내부영역을기존ScreenshotQA에검증·상세기하진단을더하되 경제/저장/RNG/기존assert완화0.
기존cache의UI/정적/KOEN3컷만재검수·새import/통과한전체저장반복0. 별도native와겹치지않는다.
수리전원인확정은 root의 `recheck-diagnostic.py`/`recheck-diagnostic-*`에서 v2제품+
진단출력만더한ScreenshotQA로 KO1회 수행한다. 실패예상원raw/별도PNG를보존하고 검사완화0.
`/root/av_audio_status`는 추가 `qa-admission-v3.{md,json}`만소유해 새helper/plan/동결후보의
기존격리재사용입구를검수한다. 원admission보고는동결·실행권한/제품GO로확대0.

v3 static4/KOEN6컷은통과했으나 EN기타−1.18m이−1.2m으로축약되어 화면합계와Δ가
2만원달라보임을독립검수에서확인했다. 새C2/경제결함으로확대하지않고 같은단위의표시만
`source-v4/`에서수리한다. 저자는같은6파일/`author-report-v4.{md,json}`/
`source-diff-v4.patch`만소유·실수정은MainGame/ScreenshotQA2파일한정이다. 기존
`LocaleManager.format_whole_won`을Δ/시작끝/원인5에재사용·새정산/전역formatter/locale키0.
root는 `recheck-v4.py`/`recheck-v4-*`/`rendered-v4/{ko,en}`·기존cache의정적1/화면2만,
av는 `qa-admission-v4.{md,json}`만검수한다. v3의모든소스/보고/raw/6PNG는동결한다.

## private 수용 — main 통합 전

v4 기존audit1/KOEN화면2 exit0·8raw오류0·6PNG 전독. 8금액exact원화/
5원인합−560000=월초1000000→월말440000, 부분기록/저장재시도/CTA잘림0.
원경제·저장3fixture 통과와v3 UI3축정정은유효·통과전체반복0·원실패보존.
비저자 GO_PRIVATE_SOURCE_AND_SYNTHETIC_PANEL_ONLY·MD4430B/bbaa3218…71a6/
JSON26669B/18245645…0dcf·base370+v4patchad3527…84a5/6source핀결속.
115원자료/보호379그룹748기록exact·파생진단source를원시점사본으로바꾸지않았다.
실제M37수정앱검수·root통합/새패키지/전체CI/원어민/사람/청취/출시GO0.
현재[~]는 통합미완료이며 source-v4만수용·원717/714사용자경로변경0이다.

## main 통합 — 실제 checkpoint 뒤

714 M37은34f24ef로마감했다. 715는같은17.2/W150에서5본문뒤선택0 STOP·
nativewait0/저장dd3c…910d byteexact로종료했다. 실제기간REWORK는별도721의
34c1e7f에서KOEN4leaf만수리했고 수정앱/M38미완료는보존한다.
이제고정370→source-v4의6파일을34c1e7f에exact통합한다. 충돌/비소유delta면중단.
721의두본문과CJK본문/기존UI/원ledger/project/preset/사용자앱은변경하지않는다.

root 추가exact: private718 `integration-proof.json`, `integration-checks.py`,
`integration-results.json`, `integration-*.stdout.log`, `integration-*.stderr.log`,
`closure-{queue,l3}.md`, `closure-checks.{stdout,stderr}.log`, `closure-receipt.json`.
`/root/m32_isolation_review`는 `integration-review.{md,json}`만 추가소유한다.
기존v4보고/115핀/모든원실패/6PNG/경제·저장3fixture는동결하고반복하지않는다.
root6파일전바이트=검수v4·기존370본문대비721네prefix외제품delta0을증명한다.
현재root의audit/JA UI/다국어표면/영문한글만표적검수·새engine/import/export/native0.
경로선택의넓은엔진/240주검사는이번통합에서열지않고새main CI는별도판정한다.
통합GO≠새패키지/실제월말/키홀드감각/사람/CJK全体/전체C2/M38/출시GO다.
실제다음후보는같은W150에서721수리와기존월말화면을함께관측한다.

### 통합 REWORK와 한정 재검수

root통합4검사중audit/다국어/EN한글3통과·JAUI만새whole_won2호출미등록으로실패했다.
원실패927B/070b8113…0b42와비저자`integration-review.{md,json}`의
REWORK_JA_UI_FORMATTER_REGISTRY를동결한다. private GO를통합GO로가져오지않는다.
별도722는두consumer의정식등록/실제collector음성을수리한다. source718 6개와721
본문2개는동결한다. 722완료commit뒤root는추가exact `integration-retry.py`,
`integration-retry-results.json`, `integration-ja-ui-retry.{stdout,stderr}.log`로
실패JAUI하나만다시검수한다. 비저자는새 `integration-review-v2.{md,json}`만소유해
722수리/원REWORK/새raw/동일6blob을직독한다. 원경제·저장·6PNG/통과3static/엔진반복0.

## source 통합 한정 완료

722수리 local1f10f824 뒤 실패JAUI하나만실제재검수: exit0/2.964899초·stdout214B/
bb866b4b…8beb·stderr0/errors0/2994 beta strings. 원실패927B/070b8113…0b42와
원8integration raw/REWORK2보고는그대로다. 6blob/721본문2/722source4/135원핀exact.
비저자GO_SOURCE_INTEGRATION_ONLY·새v2 MD3469B/da30c155…fd49·JSON14018B/
153d4cde…9680, 원6PNG관측은동일byte범위로만재사용했다. 새그림/저장·경제fixture/
엔진·native/통과3static 반복0. 722 collector가분리한unsupported466은전체채무로유지.
기존월말의8정밀금액·실제원인5·부분기록고지·저장뒤모달·ack실패재시도/once만통합했다.
새게임선택/AP/경제/정산순서/RNG/공개demo/사용자앱·저장·project/preset·CJK기존본문0변경.
새main전체CI/패키지/실제월말/수정현수앱/M38/사람·원어민·패드·청취/출시GO0.
다음별도선언의새검수앱은같은W150미선택저장을잇는다. M39경제는152종료뒤모달전
실행되므로152경계전에M39를선언한다. H5/복원HOLD/nativeexitnull/710사고는보존한다.
승격0·승인된기존UI/격리/저장계약적용·본사양의실행지시는일회성.
