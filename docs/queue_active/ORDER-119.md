# Active Queue Spec: ORDER-119

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-119 [P0·표면/QA] 결과를 스탯 정산표가 아니라 세계 안의 변화로 돌려놓는다

**사용자 실측 (2026-08-21):** 4·6·16주 화면에서 `정신 -8`, `아버지 호감 +2`,
`VIP 인맥 해금`, `사회성 3배`, `남은 웨이브`가 노출됐다. 이 오더는 데모만이
아니라 240주 본편까지 같은 표면 계약을 적용한다.

**착수 선언 (2026-08-21):** 사용자 증거 기준은
`921edf7e7eb04b5034bb3b788249875630619887`, 구현 기준은
`1220b294e69a11aa34c680790f02f9ccbec0e8c3`이다. 아래 런타임·QA 파일은 두
리비전 사이 byte-exact다. 착수 후 literal-localizer 전수 스캔에서 같은 누출이
`ArubaGame` 결과와 `JobSystem` 지원 준비 문구에도 5건 확인되었고, 이어진 L2에서
literal 밖 동적 조립으로 같은 수치를 만드는 `StoryMode` 결과 경로도 확인됐다.
`StoryMode`의 기계식 결과 카드를 폐기하자 기존 `TextMaterialCheck`와
`StoryPlaybackCheck`, 데모 번역 범위 검사도 폐기된 결과 함수·카드를 계속 요구하는
계약 충돌이 드러났다. 숨은 카드나 빈 호환 함수를 되살리지 않고 세 검사를 새
authored-result-only 표면에 맞춘다. 네 갈래 주차 원장의 다섯 정수 필드는 기존
저장 손상 진단에도 등록해 타입 오류 전 백업 복구 경계를 유지한다. 결과 카드와
동적 등급 문구를 폐기한 뒤 기존 번역 원장이 제거된 호출을 계속 요구하는 것도
확인됐다. 죽은 결과 함수를 되살리지 않고 번역 원장과 현재 JA 키를 새 정적 산문
표면에 맞춘다. 같은 변경이 dormant year5 경계의 보호 파일 해시도 바꾸므로, 현재
런타임 의미를 건드리지 않고 그 보호 해시만 새 후보 바이트에 맞춘다. 일본어 파이프라인의
변이 self-test도 폐기 전 호출 수를 코드에 고정하고 있어, 검사의 강도를 낮추지 않고 새
원장 exact 값으로 갱신한다. 결과·저장 소유 파일의 바이트가 바뀌면서 Chapter 1 인과
원장의 source snapshot과 직접 runtime-proof binding도 낡았으므로, 사건·부채 의미는
바꾸지 않고 현재 후보의 위치·해시·semantic digest만 다시 고정한다. dormant year5
감사기는 현재 제품 보호 해시뿐 아니라 보호 기준 커밋도 고정하므로, 반려된 R1a
snapshot은 그대로 둔 채 먼저 만든 구현 커밋을 새 current-file 기준으로 읽도록
갱신한다. 만지는 파일은 정확히 다음 28개뿐이며
`project.godot`은 수정·스테이징하지 않는다.

- `scenes/MainGame.gd`, `scenes/StoryMode.gd`, `scenes/JobHuntMiniGame.gd`, `scenes/ArubaGame.gd`
- `autoloads/GameState.gd`, `autoloads/SaveManager.gd`
- `systems/InvestmentSystem.gd`, `systems/JobSystem.gd`
- `tools/ScreenshotQA.gd`, `tools/TextMaterialCheck.gd`, `tools/StoryPlaybackCheck.gd`
- `tools/player_surface_language_audit.py`, `tools/demo_localization_scope.py`
- `tools/ja_translation_pipeline.py`
- `tools/chapter1_core_loop_v2_causal_ledger_check.py`
- `tools/year5_reference_route_audit.py`
- `tools/audit.sh`, `tools/audit_scope.json`
- `content/meta/demo_localization_scope.json`, `content/meta/year5_reference_routes.json`, `locale/ui_ja.json`
- `content/meta/chapter1_core_loop_v2_causal_ledger.json`
- `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/queue_active/ORDER-119.md`
- `docs/WORK_LOG.md`, `docs/STATUS.md`, `docs/DECISIONS.md`

`docs/DECISIONS.md`는 기존 정본으로 설명되지 않는 새 규칙이 실제로 생길 때만
수정한다. 사건 원고·밸런스·story map·save manager·ending·에셋·현지화 JSON과
`content/meta/demo_core_loop_v2.json`의 `runtime_default`는 범위 밖이다.

## 착수 전 멈춤 진단

최신 기준·Godot 4.6.2·빈 HOME/XDG/사용자 데이터에서 KO demo-experience를 단독
실행하면 73.45초에 W24 CTA까지 도달했고, W16→W24는 16초였다.
`CoreLoopV2CCheck`의 W16→W17/Month5 이월도 통과했다. 멈춤처럼 보인 실행은 GUI
Godot 두 개가 동시에 렌더될 때 저FPS 프레임 대기와 종료 시점 stdout 버퍼링이
겹친 QA 실행 충돌이다. 제품 진행 버그가 아니므로 이 오더는 진행하되, 실렌더 3종은
서로 다른 HOME/XDG/OUT에서 **직렬 실행**한다. ScreenshotQA의 기존 결과 문구
assertion은 새 표면 계약에 맞추지만 하네스 구조 수리는 별도 범위다.

## 깊이 3문

1. 원인은 한 문구가 아니라 `outcome`의 스탯 delta를 네 렌더 경로가 각자 라벨로
   조립하는 구조다. 결과 산문을 한 함수에서 만들고 네 경로가 같은 문장을 써야 한다.
2. 안 고른 선택지는 무엇을 하지 않았는지만 남긴다. 선택 전 `지금/대가/후속`은
   정직한 정보라 보존하지만 선택 후에는 정확한 보상·스탯·등급을 다시 공개하지 않는다.
3. 돈/사람 주는 겹칠 수 있으므로 단순 뺄셈으로 24주를 맞추면 거짓이다. 매주를
   `돈만/사람만/둘 다/어느 쪽도 아님` 중 정확히 하나로 기록하고, 구 저장의 복원
   불가능한 과거는 숫자를 발명하지 않고 분류 불가로 표시한다.

## 배치 — 정확히 20단위

1. `_weekly_commitment_outcome_text`의 스탯명+부호숫자, affinity, A–D grade 폴백 제거.
2. 선택한 story choice는 기존 결과 산문을, 일반 행동은 action/detail별 관측 가능한
   KO/EN 산문을 쓰는 단일 receipt prose 생성기 구축. 데이터가 없으면 수치 폴백 금지.
3. 지연 대가를 잠·기다림·이미 지나간 창구 같은 세계 안 변화로 자연화.
4. forgone story/generic 선택은 행동명만 보존하고 대시 뒤 정확 보상·결과를 제거.
5. A1 다행 영수증을 1~3문장 산문으로 교체.
6. A2 다음 주 echo 문장을 같은 canonical 산문으로 교체.
7. A3 scene-first 결과의 3행 정산표를 한 산문 블록으로 교체.
8. A4 중앙 확정 카드의 3행 정산표를 줄바꿈 산문으로 교체하고 ellipsis 제거.
9. investment_skill 30/50/70 토스트를 시장에서 보이는 변화로 교체.
10. intelligence 30/50/70 토스트를 읽는 방식·눈에 들어오는 단서 변화로 교체.
11. social_skill 30/50/70 토스트를 이름을 부르고 자리를 내주는 사람 행동으로 교체.
12. MainGame·StoryMode의 나머지 결과·월 위기·성향·직업 표면과 동적 조립 경로에
    남은 동일 금지어를 자연화.
13. JobHuntMiniGame의 A–D 평가 표면을 면접관/지원서의 관측 가능한 반응으로 교체.
14. GameState·InvestmentSystem·ArubaGame·JobSystem의 localized 결과/log에 남은
    스탯 delta·배수 언어 제거.
15. `이번 주  ...`, `기척  ...`의 구분자를 ` · `로 고쳐 이중 공백 제거.
16. 데모 종료 `WHAT REMAINS`에서 현재 직업을 장면이 아닌 항목으로 분리.
17. GameState에 네 배타적 주차 분류를 reset/serialize/load 가능한 상태로 기록.
18. 6개월·5년 시간 원장에 네 분류와 합계를 표시하고 구 저장의 미분류 과거를 정직하게
    표시. 새 24주 경로 합은 정확히 24여야 한다.
19. `player_surface_language_audit.py --self-test`를 추가. `_tr`와 LocaleManager의
    플레이어 문구에서 스탯+부호숫자, 해금/unlocked, 배수/xN, wave, grade A–D를 0으로
    잠근다. 함수·패턴 단위 allowlist는 칭호/업적, 정선 카지노, 선택 전 3단만 사유와
    함께 허용하며 파일 전체 예외는 금지한다.
20. ScreenshotQA가 A1~A4, threshold, C1~C4, KO/EN 금지어 0과 24주 합을 검사하도록
    갱신하고 실제 KO/EN demo-experience·KO full-gamepad 화면을 직렬 캡처한다.

## 완료·판정

- L1: 새 lint self-test, context, audit scope verify, 전체 `audit.sh`, EN coverage,
  diff-check. GameState 새 상태는 새 게임·serialize/load·구 저장을 검사한다.
- L2: 네 영수증 경로가 같은 1~3문장을 쓰고 선택 후 forgone 수치가 0인지 직접 재독.
  9개 threshold와 나머지 전역 매치를 KO/EN으로 전수 확인한다.
- L3 증거: 1280×800 KO/EN demo-experience와 KO PlayStation full-gamepad 실렌더.
  스탯 숫자·해금·배수·wave·grade가 화면에 0이고 W24/240주 종착을 확인한다.

## 정본·일회성 판정

- 숨은 스탯·도덕 상태를 플레이어에게 설명하지 않고 결과를 세계의 변화로 쓴다는
  규칙은 `CLAUDE.md`와 기존 선택 정본이 이미 소유한다. 중복 승격하지 않는다.
- 정확한 4경로, 9토스트, 네 주차 분류, matcher와 캡처 조합은 이 복구의 일회성
  완료 계약이다.
