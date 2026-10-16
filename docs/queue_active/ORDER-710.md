# ORDER-710 — 16.2 넘김 효과 재현·원인별 수리

#### [~] ORDER-710 착수 — 2026-10-16 · C2/C1 읽기 경계

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
- 원16.2 binary184222304B/8ccb6ee3…cd28·PCK404918144B/8e865663…2571은
  user-package696원영수증과실물을대조한다. 원앱을실행/재선택하지않고새
  `/Users/junheelee/Applications/GangnamDream-SkipRepro-20261016.2/GangnamDream.app`
  복사본만쓴다. tools가PCK에서제외돼있으므로기존 `tools/StoryNameplateBootstrap.gd`의
  절대경로 `--script`와기본 `res://scenes/StartMenu.tscn`으로 `_init` pre-autoload격리와
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
