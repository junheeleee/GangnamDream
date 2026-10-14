# ORDER-628 — 본편 월초 경제의 저장 경계 수리

#### [x] ORDER-628 [저장 정합] source 한정 수리 완료 — 2026-10-14

실제612/M18의 첫W73에서 HUD−657만원/정신77과 디스크−6371703/정신87이
달랐다. 월말값은 정상1회이며, 달력autosave 뒤 _begin_month의 월초경제가
계산되고 선택전StoryMode CmdQ는 autosave하지 않는 순서가 원인이다.
화면만원반올림으로 정확돌발지출액수는미관측·약20만원이다.
발급9dea518f와현재a5b36d6의관련6파일byteexact를 독립상태검수자가확인했다.

## 깊이3문·한정범위

플레이어가 이미 본 월초 현금·정신/시장/뉴스 상태가 다음Continue에서 다시
추첨되지 않도록 한다. 계산을 지우거나 숫자/확률/원문/저장스키마를 바꾸지 않는다.
full-story의 정상calendar advance+complete_turn 뒤, 기존 durable calendar save
직전에 새달 첫주 경제를 계산한다. 이후 _begin_month는 기존marker로 inert다.
정상 full profile(is_full_run)에만 적용하며 명시8/12주 preview와 종료boundary는 그대로 둔다.
실패 재시도는 기존 full_story_calendar_save_pending 소유의 저장만 재시도하며
경제/RNG를 재실행하지 않아야 한다. StoryMode 전역종료저장은 확장하지 않는다.
이로써 월경계직후coldContinue와 저장실패재시도까지같은결과가이어진다.

root 소유: scenes/MainGame.gd의 _full_story_advance_week 호출순서와
_begin_month의 prev_prices 소비자·비직렬화 일회성 local 가격인계값,
큐2/이사양/archive·CLAUDE현재행/WORK_LOG·.git/order628-20261014/ 새표적증거.
a1_state_economy_audit 소유: tools/ManualSaveCheck.gd의 기존 full-story production/
third-month/calendar-save-retry fixture 내 월초disk/live/marker/RNG회귀 assertions만.
m17_native_admission 또는 비저자검수자: 새독립source/보존보고만, 제품쓰기0.
서로소유파일교차쓰기0·기존checker재사용/새영구검사·self-test·비용사업0.

## 검증·완료경계

기존 full-story production/third-month/calendar-save-retry/월초inert의 관련표본을
검수 전 실제읽고 사용자HOME·3XDG·실제Godotuserdir·recoverylock을 격리한
검증에서 실행한다. 성공marker+stdout/Godot로그의parse/script/engine오류0을
함께확인한다. 정상월경계disk/live경제exact·marker==targetturn, failedsave후
저장재시도의RNG/상태불변·이어진_begin_month inert가 필요하다.
표적resolver목록은실행과구분·전audit/240주·정산/시장원문대량검사중복0.
게임원문/번역/효과·정산수치·저장schema·공개데모·사용자설정저장·project 불변.
source수리GO는 실제새앱검수GO가아니다. 612한달기록은이번선언/제품commit에서
제외하고, 새후보발급후 같은원W69→첫W73 실제재검수와한commit마감을이어간다.
다음월플레이0·CI빨강일때새월0·5언어/인간/원어민/패드/청취/출시HOLD유지.
이번지시는일회성·승격0. 자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

## 첫 후보 독립 REWORK·필수 소비자 보완 선언

local 제품f1e7e8f의4표적runtime은통과했으나 독립검수자가 _begin_month의
prev_prices=post-roll 덮어쓰기를지적했다. 시세등락/portfolio pulse의 pre-roll
가격소비자를잃으므로 sourceGO로닫거나push하지않는다. 기존후보/12raw 불변.
같은파일에서 early-roll 직전가격을 prev_prices에담고 현재turn을 비직렬화local에
인계한다. 다음 _begin_month에서 같은turn일때만 가격대입을1회건너뛰고local을
소비한다. 새Main/cold·preview·다음동일주호출은원래동작, 저장flag/schema변경0.
같은production fixture에 pre-roll prev_prices/rolled market 및 바로이어진
_begin_month 인계소비 회귀를 추가한다. 원정산/AP/저장실패/RNG 검사는유지한다.

## 마감 — source GO / 동일월 실제앱은 미관측

선언f174a8c → 첫제품f1e7e8f REWORK → 보완선언8811098 → 최종제품
1f2a59298eb29fd633fcda0ba7dfca20d307fb28 /
tree7773137ca5aba007959ab09a18b905d43a00161e.
MainGame SHA693d08fd8f154b11edbe7198524723f2610dc978c89ca2471a59b2481b9ab61f,
ManualSaveCheck SHAff693e581e1a5082695db69eae72b30c33a0f99225bd1b15cc5fe7459930411f.
최종production79365/preview8 80120/preview12 21721/monthly46878 각exit0,
원stdout/Godot exactmarker각1·12로그오류0·expected injected save경고보존.
원정산/AP 관측은 turn_advanced에서 월초계산전 대조해 약화하지 않았다.
durable경제/시세 pre-roll·rolled/다음begin_month inert·인계소비·colddefault−1,
preview제외·실패old disk보존/pending/retry/control/RNG를 기존fixture로 검증했다.

.git/order628-20261014/price-handoff/validation.json
5548B/SHA3b17429652d20c4f90c22a89e3946f110275fbc46c9e4d16f664963291c94163;
independent-source-review.md7377B/
c9324e37ad8d742f8fc020dd833366a19a798b2991a7d18b17d7d83f5e29183c,
independent-source-review.json6259B/
7def8837e6b9dfbf6be6883b27f6d76e2f5c32f6160d17f6afca01df666262cc.
비저자a1_qa_release_audit 소스·12raw578줄실독/sourceGO·root전문/핀확인.
project/preset/human불변·사용자33비shader파일전후exact(root증거)·공개demo변경0,
독립전역55그룹/app400MB census재실행0·구f1e7/12raw/receipt 불변.

새앱export/같은원W69→첫W73 실제화면·HUD/저장 재검수는612에 남는다.
뒤nativeinventory한번은 자동해제실패·세션잠금Yes/IOConsoleNo·전원sleep/display0,
세부원인미확정·Mac설정변경0·새월실행0이다. 같은M18외 다음월0.
612월별큐/사양/관측기록은 이마감commit제외·전역candidateHOLD와 분리한다.
sourceGO≠새앱/native/인간/원어민/물리패드/청취/자연240/전체CI/5언어/출시GO.
마감context/queue/self/diff actual0·현황판전용commit0·새push CI미확정.
일회성·승격0. 자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
