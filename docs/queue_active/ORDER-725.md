# ORDER-725 — 트레일러 캡처의 저장 격리·새 출력 계약

#### [~] ORDER-725 [C5 화면 없는 준비] 착수 — 2026-10-18

Mac실측잠금. C1 715/724의원자료·W151/f022는동결하고새월을열지않는다.
실제확인한capture_frames.sh는root의ScreenshotQA.tscn으로직접부팅해기존저장경로를
쓰기전에격리하지않고, 공용/tmp/gangnamdream_qa에서남은모든trailerPNG를복사한다.
기존capture의삭제도포함한다. 향후C5촬영전에이실행절차만수리한다.
새시스템/장면/게임플레이/원문/번역/음향·자산/프로젝트/엔진실행/실제촬영0.

## exact 소유·한 단위

root: tools/trailer/capture_frames.sh, tools/trailer/render_all.sh,
tools/trailer/trailer_check.py의capture-self-test분기만, tools/audit_scope.json의
이5경로용좁은선택등록, docs/TRAILER_PRODUCTION.md의실행/산출물·현행상태절만.
기존timeline/편집/음원/인코더/기존static/video검사는변경하지않는다.
root: 이사양/archive·CODEX_QUEUE/L3·CLAUDE그다음행·WORK_LOG새기록,
private .git/order725-trailer-capture-20261018/의 baseline.json, checks.py,
checks.json, logs/, declaration-{queue,l3}.md, closure-{queue,l3,claude,worklog}.md,
completion-receipt.json만. 715/724월선언과그관련미커밋현황은선언/마감commit에서제외한다.
/root/m32_isolation_review: private independent-review.{md,json} 두파일만.
검수자는Git/엔진/QA/UI/실사용자접근0·실제diff/테스트/raw/보존핀을직독한다.

## 수리·표적 검증

기존StoryNameplateBootstrap의pre-autoload userdir를재사용한다. namespace는새32hex,
HOME/XDG/OS설정은불변, 기존디렉터리/출력/심볼릭링크를거부한다.
한번의출력은새전용capture/log경로만쓰고공용tmp/이전PNG fallback·삭제·덮기0.
원stdout/stderr/Godot로그와종료코드·exact namespace/완료marker/오류를함께검증한다.
해당locale22PNG만기존PNG크기·timeline검사에연결한다. 경고·cleanup누수는원문보존하고
strict capture GO와구분한다. 전체render도새run의두locale/네MP4만참조한다.

Mac잠금중실제engine/ffmpeg/촬영은실행하지않는다. self-test는모의engine의입출력·
오류/marker/fresh-path/이전파일보존/locale분리만검사하며실제render·격리관측GO가아니다.
새self-test/기존trailer static·audit 선택/등록·shell구문·문서5+diff만표적검증한다.
원제품·timeline/렌더러/음원/원715/723/사용자앱·저장·공개·과거판정의비소유변경0.

깊이3문: 삭제하면C5촬영이사용자경로와stale그림을접촉한다. 게임의상태/24주선택은
바뀌지않는다. 같은기존컷producer와경쟁하는것은오래된출력·잘못된성공표시다.
승격: TRAILER_PRODUCTION 실행의격리·fresh출력계약만, 나머지일회성.
source수리완료≠새22컷/4영상/실제청취/Steam게시/C5전체/사람/출시GO.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
