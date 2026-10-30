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

### 엔진 사본 입구 수리 — 실행 전 범위

첫 repo내 사본은 codesign의 Finder정보 거부로 엔진 시작 전에 멈췄다.
원 `engine/`·`codesign.*.log`를 보존한다. 원본에는 FinderInfo가 없음을
읽기 확인했으며 속성 제거·보안 우회0. 새 exact 비동기화 경로
`/private/tmp/gd-order736-engine.YuH0qQRY/Godot.app`·동부모 `_sc_`만 사용한다.
private `engine-location.json`·`signature-failure.json`·새 `codesign2.*.log`를
추가하며 root `run.py`는 새 사본/서명 로그와 과거 engine 제외만 변경한다.
비저자 변경분 검수 뒤 새 서명 통과 시에만 최초 headless 엔진 실행을 허용한다.

### 실제 컴파일 결함 수리 — 재검사 전 범위

서명2통과 뒤 최초 엔진은 fixture `var namespace` 예약어 ParseError로HOLD.
원fixture/run/before/result/원3로그 보존. helper의 signal회수 exit−9,
보호898그룹exact·소스2398불변. 같은구문을쓴 제품renderer도 `qa_namespace`로
수리하고 정적회귀반례를 추가한다. root exact새 `compile-check2.gd/.tscn`,
`run2.py`, `attempt2/`의원3로그/before/result/서명로그만 추가한다.
기존 /private/tmp 사본은 exactbinarySHA/서명 재확인 후 재사용한다.
최초GO상속0·비저자새입구뒤 headless 컴파일/치수만 재검사한다.

attempt2는 actual vertical minimum overflow로HOLD(exit1·보호898exact).
실패조기종료로치수누락/fixture정리누수도보존한다. `compile-check3.gd/.tscn`,
`run3.py`, `attempt3/`를추가하여4치수를실패전모두기록하고모든임시노드를
정리한뒤overflow를보고한다. 제품값은실측후에만최소수리한다.

attempt3실측 main306x167/header237x133/small225x127/vertical427x231,
세로선언216높이만15부족. master/art/font는유지하고title높이248로32확대,
하단888≤896·실측여유17 확보. 정적회귀반례1추가·새 `run4.py`/
`attempt4/`에서동일fixture3·source새pin·격리/서명/원로그/보호전후 재검사.
원attempt1/2/3 실패를보존하며 RID단독누수도명시거부한다.
