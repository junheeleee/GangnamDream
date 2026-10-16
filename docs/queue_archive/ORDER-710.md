# ORDER-710 — 16.2 넘김 효과 재현·원인별 수리

#### [x] ORDER-710 완료 — 2026-10-16 · C2/C1 읽기 경계 한정

사용자 PR38 결정문 exacthead6f2607c를43e340f로병합했다. 충돌은POST_LAUNCH_NOTES의
두삽입만양립시켰고main R5기록/역사원문과PR의19+7줄을모두보존했다.
현재main큐12865B/max13000·context actualpass이므로PR의13200B경고를현재실패로복제0.

## 한정 목표·깊이3문

사용자가16.2에서본‘행동문을생략하는듯한넘김’을동일binary/PCK에서격리재현·
캡처한다. Quiet주압축/AUTO/결과카드/월말전환을실제도달경로와화면으로구분해
확인한원인만수리한다. 정적의심만으로원인확정0. 시간경과와그동안돈변화한줄이
읽히고장면문장이읽기전에사라지지않는것이수용기준이다. 의미없는주간카드/고정대기0.
선택/24주상태는원형이며, 읽기기회가없으면현재장면이성립하지않는C2입력·표시문제다.
신규행동계층/수치·직업·관계·효과·확률·경제·분기·장면원고변경0이다.

## exact 소유

- root: 이사양/archive·CODEX_QUEUE/L3·CLAUDE현재행·WORK_LOG.
  PR38 DECISIONS/POST_LAUNCH_NOTES 병합은이미완료한 exact문서2개뿐이다.
- 제품수리는원인화면을확인한뒤 `scenes/StoryMode.gd`의타이핑/방향hold/AUTO/선택
  표시경계 또는 `scenes/MainGame.gd`의Quiet/결과/월말표시경계 중 실제원인구간만.
  원인아닌파일은불변. 입력과표시계약의기존회귀는 `tools/StoryPlaybackCheck.gd`의
  관련사례만보강한다. 다른검사/예외/래칫을완화하거나삭제0.
- private `.git/order710-skip-effect-20261016/`: PR/원scene/보호지문·실행원raw·
  캡처·상태/입력시각·보고·통합영수증·독립검수. root만Git/QA/엔진/UI/패키지실행.
  `/root/m32_path_review`는원인후보읽기, `/root/av_audio_status`는기존격리절차읽기,
  비저자 `/root/m32_isolation_review`는실제화면/수리diff/원raw·보존핀독립검수와
  private보고만. 저자는자가최종판정0·사람/원어민/물리패드증거발급0.
- 후속 파일소유 분리: `/root/av_audio_status`는 `tools/StoryPlaybackCheck.gd`의
  hold+다중선택 읽기 경계 회귀 저작만 맡는다. 실행/최종판정은root·독립검수자만이며
  원인 실제캡처 전 제품수리0·정적 회귀와 사용자 원빌드 재현증거를 구분한다.
- 원16.2 binary184222304B/8ccb6ee3…cd28·PCK404918144B/8e865663…2571은
  user-package696원영수증과실물을대조한다. 원앱을실행/재선택하지않고새
  `/Users/junheelee/Applications/GangnamDream-SkipRepro-20261016.2/GangnamDream.app`
  복사본만쓴다. tools가PCK에서제외돼있으므로기존 `tools/StoryNameplateBootstrap.gd`의
  절대경로 `--script`로 `_init` pre-autoload격리와
  fresh `GangnamDream_StoryNameplateQA_<32hex>` userdir를이용한다. 원PCK/원binary
  byteexact를유지하고main기본StartMenu→정상입력으로재현한다.
  bootstrap성공marker/정확새userdir를확인하기전게임입력0. 격리가증명되지않으면
  원사용자저장으로진행하지않으며실패raw보존뒤기존안전발급방식으로재판단한다.
- 확인된수리의새후보native검수는기존build-only cleanclone/서명·PCK검증방식만.
  원16.2/사용자HumanTest저장·설정·바탕화면안내/shortcut·대표W145checkpoint/
  rootproject/preset/공개demo/KOEN·CJK원고/번역원장/과거판정·복원HOLD를보존한다.
  HOME/XDG/OS잠금·절전·보안권한변경0, 미검증런처옵션/새영구QA도구0.

## 검수·C1 병행

16.2 source는ad230fd/build-onlycf5851d이며새main과혼동하지않는다. 비고정실제
동작을관측한정상속도컷과시각을남기고본딩된입력/타이핑끝/hold/AUTO/다음화면
순서를대조한다. 동일원인수리전후캡처, AUTO OFF/ON·정상Enter/hold·설정/기록pause·
directcontinue/선택정지 경계의관련표적만실행한다. 결과/경제/저장보존도함께본다.
기존source영향선택목록은실행없이확인하고관련정적/격리StoryPlayback·문서표적만.
전체로컬audit/새240주/완료월재검수0. 16.2버그재현은완료월을다시여는C1월작업이아니다.

현재3b9a87d CI38904281491은정적job success/전체engine감사중·진행≠녹색이다.
실제대표경로M37은새main전체녹색뒤보존W145에서즉시재개·월최대2/월별한commit.
현재고정16.5는종료됐고사용자앱은UI경쟁/저장덮기0이다. C1을무기한새꾸미기로
미루지않고확인한넘김수리만한다. PR38의2~4·R6는이번소유가아니며자동재개0.

규범은최신DECISIONS/기존입력정본을따른다. 새정본변경0·나머지일회성.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

## 원16.2 첫 입구 실패 · 입력0

원binary/PCK의7파일과서명은exact이나 `--scene`은release binary의path override
차단으로exit1/4.55495초였다. marker없음·실화면관측0·넘김원인증거0이다.
원raw3을보존하며 같은binary/PCK에서 `--scene`만빼고 원기본boot를사용한다.
기존절대bootstrap의fresh namespace/정확marker가확인될때만입력한다.
설정/원앱/저장·보안우회0. 원binary에서안전격리가계속차단되면 동일PCK와
공식동버전진단엔진을구분해사용하거나기존build-only안전발급으로재판단한다.

두번째원binary는bootstrap marker/새userdir가없고기존진행이보이는제목으로열렸다.
게임입력0에서소유PID69947을TERM종료(-15)했다. 실제진행save/bak/meta의mtime은
시도전21:29이며설정77B의mtime22:22:20갱신은확인됐다. 이전실행영수증의
user_app_access:false는root의직접path접근0만가리키며프로세스의실저장격리성공을
뜻하지않는다. 이제실16.2path stat메타만읽어확인했으며내용/선택/진행편집0·설정복원0.
이실패를재현GO로세지않고원raw/관측을보존·사용자에게알렸다.

후속은기존self-contained 공식4.6.2 engine과원16.2 PCK를조합한다. PCK404918144B/
8e865663…2571·BuildInfo16.2/모든제품로직은exact이며runtimebinary는원release와
다르다고명시한다. 기존절대bootstrap+headless짧은입장검사로pre-autoload정확marker/
fresh경로를먼저증명한뒤새namespace의graphical재현만한다. 원binary성공으로확대0.
PR39는9f0d077로문서2개만병합했다. A5선택회수표식은이넘김수리다음별도exact선언이며
이오더에서동시구현0·2~4/R6재개0·현재원고/조건/시간/경제/사용자자료보존이다.

동일PCK/공식engine의headless3frame 입장에서는정확freshnamespace marker와exit0을
확인했다. 강제짧은종료의ObjectDB누수 WARNING/1resource ERROR 때문에전체QA
pass는아니며원raw를보존한다. 추가누수추적0·입장격리증거와종료오류를구분한다.
GUI는또다른freshnamespace로만진행·marker/경로확인뒤정상입력한다.

GUI는문틈결과까지정상입력했으나이후반복Return/A가화면을바꾸지않고좌표클릭은
noWindowsAvailable이다. on-console/loginYes·sleep/display0·소유PID생존이며
org.godotengine.godot의다른편집기와중복실행중이다. 제품진행불가/넘김원인확정0.
기존private실행원장을종료보존한뒤같은officialengine의새private복사본에서
CFBundleIdentifier/Name/DisplayName3키만고유화·기존ad-hoc sign/strictverify패턴을
재사용한다. `.git/order710-skip-effect-20261016/unique-engine/SkipRepro710.app/Contents/Info.plist`
만metadata편집·원engine/편집기/사용자앱불변이다. 재서명후engineSHA를별도로남겨
원enginebyteexact주장0·원16.2PCK byteexact는유지한다. 새launcher/권한/보안설정0.
각시도새32hex namespace·pre-autoloadmarker·실제한입력의화면변화를확인한뒤진행한다.
private Documents경로의FinderInfo가삭제후즉시재생성돼strict서명검증이실패했다.
실패원장은남기고새 `/Users/junheelee/Applications/GangnamDream-SkipRepro-20261016.2/SkipRepro710.app`
한개에만동일고유진단엔진을복사해검증한다. 사본의FinderInfo만정리하며quarantine/
provenance를전후대조보존하고검증실패본실행0·원앱복사본/사용자앱불변이다.

고유engine는사본FinderInfo만정리한뒤strictpass·quarantine/provenance불변이다.
원PCK byteexact와새pre-autoloadnamespace marker를확인하고정상초반입력으로
story_knee_choice에진입했다. AUTO OFF의마지막문장‘문고리는바로앞에있었다.’를
58캡처에서읽었고추가입력0인59캡처에서선택레일이본문을숨겼다. 동일원PCK/공식
재서명진단engine관측이며원releasebinary의성공재현으로확대0이다. Quiet/월말은
이위치에없고결과도아닌description 마지막문장·direction.hold1.5 만료경계다.
별도source회귀도수리전ko/natural에서동일경계로exit1을남겼다(원raw보존).
제품변경은StoryMode._process의hold만료분기만으로한정해수동새입력/AUTO기존
읽기대기로돌아오게한다. MainGame·원고·조건·효과·시간/경제·자산/사운드불변이다.

수리후source보충검수: HEAD9f0d077 cleanarchive의private source-qa에선언한
StoryMode/StoryPlaybackCheck 두파일만overlay했다. import exit0·pre-autoload격리
StoryPlayback exit0/8case+기존156case1044page를확인했다. wrapper에marker prefix를
준오류는full exactline/오류0을unchanged raw로대조한정정영수증에결속했고재실행0이다.
같은고유진단engine에서또새namespace로source-tree StartMenu 정상native를열어
동일장면을보충재검수한다. 이것은새export/PCK·출시binary검수가아니며source
기본BuildInfo10.11.1과원16.2PCK의표시신원을혼동하지않는다. 이후대표경로의
새발급앱은기존build-only cleanclone/서명·PCK검증대로별도묶는다.

## 수용·보존·다음

원16.2PCK57~59와수정source80~84 원JPEG/입력원장을root·비저자가직접대조했다.
수정후81~83의24.3초무입력구간에마지막본문이유지되고새Return에서만84선택이
열렸다. 두정상native exit0/원raw3씩오류0·선택확정0·HUD돈/H/M불변이다.
독립판정 GO_A1_AUTHORED_HOLD_READING_BOUNDARY_ONLY, 보고는private
independent-final.md(5796B/5cd457468b2500a4c019100102e6d0c12c6ecefbbdae3eaf6062ae531260ad8f),
independent-final.json(8721B/3dfeee2d84951fd91772061bb15b1e3488370e0d74fd34602ea550ce17b07484)이다.
원1287핀중제품2파일만변경·StoryMode261함수중_process만·기존checker raw역산exact.
root 원사용자앱7파일exact·source5표적/문서context/queue/diff통과. scope선택명령에
--list를빠뜨린실행은부모/자식2PID TERM중단143이며전체감사PASS로세지않는다.
최종source StoryMode304657B/3ebbe2ccd9cf2ef5f53ed5ea6122750e9d50f4be974445007c4bd80449476ab9,
checker61739B/f3f15f16171717dd1683c174db683a6e26418c56191e633b80477ea4d27b0f76.
원binary격리실패의설정77B mtime갱신사고/진행mtime만확인한한계를보존한다.
전체저장byteexact·원releasebinary성공·새export·EN/AUTO native·사람/패드·C2전체/
C1완주/출시GO0이다. 이후본편새후보발급·CI·대표경로는별도이며완료월재개0.
개발스킬의격리/독립/표적/증거분리로수용·제품정본승격0·일회성·기존입력계약준수다.
승격: `.codex/skills/gangnamdream-dev/SKILL.md`:Verify 에원release의격리입장실패시
일반boot재시도금지1줄을추가했다. 실제설정mtime사고를예방하는절차이며제품규칙변경0.
PR39는이미9f0d077 병합·다음은결정5의StoryMode/UI5문구만별도exact선언한다.
