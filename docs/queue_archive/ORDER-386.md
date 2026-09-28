# ORDER-386 — 거래 카드·하단 안내 가시성과 자산 이동

[x] 2026-09-29. 독립 work_unit 한정 GO. 본편/새package GO가 아니다.

- 최종 source `e395638ebb5e72f5964dfa0142211a9c778f63e7`, tree `65a6111513b7fdd3cf1c38adc3b2e7071c9c2368`. [독립 보고](../agent_reviews/ORDER-386.json) SHA `3fff44037dffef5e67774f3f0202241f33e54c4eb874b7b9f43d2fe83b4385dc`.
- 선택 자산 한 카드와46px 마우스 ↑/↓만 추가해 기존 두 카드 세로 경쟁을 없앴다. 전체 ID·순환·기존 키보드/패드 의미·매매 callback·경제 불변. footer rect y744..766→627..649, clip하단740 안으로 복구. 두 함수 외 제품 수정0·새 번역0.
- 격리1280×800 실제22PNG/248node·binding/17fixture/5언어140자동입력·mouse signal30·trade0 PASS,67.968초. 최초 정적12명령 중11exit0/ch5하나300초timeout을 보존하고 그 하나만 단독292.847초exit0으로 재검수했다. 현재focused45·receipt guard·consumer5·등록/context/queue/diff와차선조회만, 전체감사/과거self/240주/번역재수용0.
- 기존148판정/126보고와 원385 HOLD·실패·PNG를 보존하고 현재 source의 한정 GO만 append했다. 공개GO1/인간OPEN45·본편/새packageHOLD 유지.
- 원어민·인간·물리·자연진입/복귀·실제매매/정산·패드표시 전체는 미관측이다. 외부출시/스토어/지출/법률행위0.
- 승격 없음: UI/입력·WORK_UNIT 기존 규칙 재사용. 모집단·소유·표적계획은 일회성이다. 개발스킬의 선행선언·소유분리·독립검수·격리실행을 적용했다. 자동PASS는 계약증거이며 재미·문체·사람GO가 아니다.

## 최초 선언과 진행 원문 보존

# Active Queue Spec: ORDER-386

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-386 [P0·UI 수리] 거래 카드·하단 안내 가시성과 자산 이동

2026-09-28 착수. 기준 main `6d8f623`, 부모385의 실제 사전 화면 FAIL2를 수리한다.
385의 번역42값과 실패 기록은 보존한다. 302/352 및 은행 번역은 이번 비소유다.

## 깊이 3문 · 한 수리 배치
1. 이 수리가 없으면 저컨디션·보유 정보가 겹칠 때 하단 자산 이동 안내가 clip 밖으로 사라진다(실측 y744..766/clip740).
2. 경제·선택·24주 결과 변화0. 이미 가능한 자산과 거래를 보이게 하는 배치·입력 수리다.
3. 두 상세 카드는 제한된 세로 공간을 경쟁한다. 선택한 한 카드와 명확한 자산 이동을 남겨 수수료·가격·매매·안내의 공간을 확보한다.
한 단위는 거래 상세창 가시성이다. 이 수리는 다량 번역 배치가 아니며 독립적으로 판정한다.

## 구현 · 정확한 파일 소유
- root 제품: `scenes/MainGame.gd`의 `_render_investment_assets_page`와 `_invest_move_asset`만. 선택 자산 한 카드, start=selected, caption 안 마우스 ↑/↓ 버튼. 기존 전체 ID·순환·기존 키보드/패드 경로·매매 callback 유지. 버튼은46px·FOCUS_NONE·현재 열린 assets 모달 가드. 기본 이동음을 보존하고 마우스 버튼의 중복 클릭음만 선택적 인자로 억제할 수 있다.
- 기존 두 자산 동시 비교는 한 자산 상세로 바뀌며, 마우스는 새 이동 버튼으로 모든 자산에 도달한다. 폰트 축소·footer 삭제·모달/카드 전역 스타일 변경·지연 layout callback·새 번역키0.
- compat357 도구: `tools/main_game_locale_history.py`, `tools/ui_translation_append.py`, `tools/ui_translation_append_self_test.py`, `tools/audit_scope.json`. 정확한 새 Git 전이/whole raw/역상을 기존 모듈 끝에서 결속한다. 기존381/382 구현·pin·반례를 보존하고 현재386→382→381 비교 및 pre386 official header manifest를 연결한다. HEAD 위조·원형 완화·새 호환 모듈0.
- screen_path_probe: private `.git/full-game-localization/order386-*` 화면/입력 관찰기와 실행기만. frozen385 helpers/실패/PNG는 수정하지 않는다.
- r3_route_probe: 비저자 구현·도구·실제 표적 화면/입력·수용42 보존 독립 검수, private386 최종 보고. 제품/도구 저작0.
- root: 큐2/active386·385와 완료 archive, CLAUDE 현재행, WORK_LOG/기존 `docs/history/WORK_LOG_2026-09-07_localization.md` 원문 이동, 생성STATUS, 새 `docs/agent_reviews/ORDER-386.json` 및 필요시 `ORDER-385-runtime-recheck.json`, 판정 원장 append, private 실행/증거. root만 엔진/표적검사를 실행한다.
- KO/EN/JA/CN/TW 사전·수용 원장40,928/b154·기존148판정/126보고·인간 원장·project·공개 데모·게임 상태/시간/수수료/자산 목록은 비소유다.

## 표적 검증과 완료
- 원385의 실제 사전12개 prepared 화면/42lookup 전체를 새 관찰기에서 다시 확인한다. 한 카드에 맞춘 구조 기대만 바꾸고 글리프/폭/ancestor clip 검사와 전수21키 커버는 유지한다. 초안 cache 예비 실행은 반복하지 않는다.
- 추가 KO/EN/JA/CN/TW 각2화면: 모든5자산 보유·저컨디션 첫 자산, 실제 이동 뒤 마지막 자산. 키보드 상하와 마우스 두 버튼의 첫/끝 순환·중간 선택, 전체 ID·선택 카드 일치, 전후 돈/AP/보유/기록·매매 signal0을 확인한다. 새 UI 버튼도 glyph/font/폭/clip 검사를 받는다. 기본 총22PNG,1280x800. 추가 모집단이 필요하면 실행 전 기록한다.
- fresh pre-autoload 격리, source/실사용자 파일 전후 일치, typed fixture 복원, 정확 marker와 stdout/엔진 로그 오류 검사를 유지한다. 실제 입력은 자동 주입 관측이며 물리 조작감이 아니다. 새로운 매매 확정/자연 진입·복귀는 비포함.
- 새 역상 focused self, 현행 UI receipt guard, 현재 consumer5 normal, registry/context/queue/diff와 영향 조회. 원형 self corpus·전체감사·240주·새 번역 export/import를 반복하지 않는다.
- 386 GO와 385 재검수 GO는 새 실제 source에 각각 결속해야 한다. 이전385 HOLD와 실패를 삭제·덮어쓰지 않는다. 하나라도 실패하면 active/HOLD를 유지한다.
- 기존 guide CTA focus 약3px 잘림·전체 UI/원어민·인간·물리·본편/새package HOLD는 이번 GO로 닫지 않는다. 외부 출시/스토어/지출/법률 행위0.

규범 승격0: 범위·역할·표본은 일회성이다. 현행 UI/입력·WORK_UNIT의 기존 규칙을 재사용한다. 자동 PASS는 계약 증거이며 재미·문체·사람 GO가 아니다.
