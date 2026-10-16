# ORDER-718 — 기존 본편 월말 결산의 실제 현금 변화·원인

#### [~] ORDER-718 [C2/C5 기존 UI] 착수 — 2026-10-17

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
