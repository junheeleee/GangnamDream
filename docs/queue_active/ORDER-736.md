# ORDER-736 — 캡슐 코드·실제 글꼴 치수의 headless 확인

#### [~] ORDER-736 — 2026-10-30 착수

C5. 사용자 `고` 뒤735의 source/모의GO와 실제 컴파일/글꼴치수를 분리해 검증한다.
Mac잠금 중 앱화면이 필요 없는 headless QA만. 실제 캡슐렌더/PNG저장/게임플레이0.
깊이3문: 모의검사는GDScript/폰트실측을대신못함 / 제품·선택·저장편집0 /
화면이 필요한C1을대체하지않으며 새CJK/폴리시를열지않음.

root 소유 exact: 같은private `.git/order736-steam-capsule-compile-20261030/`의
`compile-check.gd/.tscn`, `run.py`, `engine/Godot.app` 사본·`engine/_sc_`,
원3로그·`before.json`/`result.json`/엔진서명 로그·새QA namespace 기록.
비저자 capsule_review 소유: 같은폴더 `review.md/.json`.
확인된 컴파일/치수 결함만 수리 가능: `tools/SteamCapsuleExport.gd`,
`tools/steam_capsules.json` 및 `tools/steam_capsule_export_self_test.py` 표적 반례.
큐/이사양/마감archive·WORK_LOG새항목·CLAUDE준비한줄만 정리한다.

공식엔진SHAe6b5cfdc226ffb7ec4f4950b0b12ddba4f040624724cff1acce9ae1241cf0034를
새 self-contained 사본으로 사용, 기존엔진/템플릿/730사본·서명·저장·앱 보존.
기존 StoryNameplateBootstrap으로 autoload 전에 fresh32hex namespace 선택.
명시 `--headless`·private fixture scene만. 원renderer는tree에추가하지않아
그 `_ready`/PNG출력을실행하지않는다. source GDScript/scene load 및 실제
`_build_surface`/기존 FontKit/wordmark minimum4개만 측정·폐기한다.
필수: headless확인·정확표식/순서·실exit·stdout/stderr/Godot로그오류/누수0·
표적입력SHA/보호전후동일. timeout은process-tree회수·원자료보존 후HOLD.
허용되지 않은 namespace·렌더출력·플레이·저장복사/편집·seed·원앱재실행0.

검증은 컴파일/레이아웃치수까지만, 실제그림/얼굴/타이틀가독성/시각/사람/
원어민/패드/출시GO0. 원ad/ad2/초안zip/53a3 보존·재개새입구필수.
이번fixture/실행은일회성. 새규범은없고 기존headless격리·원로그계약을사용한다.
