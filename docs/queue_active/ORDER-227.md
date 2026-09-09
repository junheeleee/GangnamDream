# Active Queue Spec: ORDER-227

> [~] 착수 — 중국어 연말 회고 동적 선택 템플릿2종/4값과 실제 소비자 검사.

#### [~] ORDER-227 [P0] 중국어 올해의 장면 선택·결과

## 목적·배치

연말 회고는 이미 번역한 사건 제목을 쓰지만 CN/TW의 부모 템플릿 누락 때문에
영어 템플릿과 영어 제목으로 폴백한다. 두 키의 네 값만 채우는 수리1배치다.
15~25개를 맞추려고 관련 없는 UI를 더하지 않는다. 새 선택·효과·AP·달·사건0이다.
그 값이 없으면 실제 중국어 회고 선택이 영어로 남는다. 번역 여부는 기존 선택
상태를 바꾸지 않으며, 원래 선택의 기록과 엔딩 제목 독자는 그대로다.
서사 경쟁·비용·사실은 KO와 기존 GameState가 소유하고 번역은 새 책임을 만들지 않는다.

기준 제품 C2 `3b4866a215ed201be494912076db4b07e0792ac6` /
tree `574646f3eb0d89ef7e4fa9fb10c2161c72fd1887`의226 수용36,072/b86/meta9를 보존한다.
후속 선언 전226 wrapper의 clean·작업 단위 GO를 확인하되 본편 HOLD는 유지한다.
CN/TW 각각2추가, JA0이다. 기존 JA2값은 사전에 있지만 수용 원장에는 없으며 새 수에 넣지 않는다.
예상36,076/JA12024·CN12026·TW12026/b87은 실제 수용 뒤에만 완료 수로 쓴다.

| KO exact key | source SHA256 |
|---|---|
| `「%s」` | b1b2b3853d761dd95b4b94aaaff31b9f4aa7da19a82c8bbd8272642528449303 |
| `그 해를 접으면, 「%s」이 가장 먼저 남았다.` | ae359a0819e86bf5792ddee3603ac065af3ce9d8c805cd118a084ea04f1b1bd2 |

각 source는 `runtime:static_ui`, `ui_static_context`, format_template=true,
builtin_overlay_static_only·protected=false다. placeholder는 `%s`1개·LF0이다.
이전 preflight는 .git/full-game-localization/order226-next-ui-independent-preflight.json
SHA b590f695318e88dfcfa720e570a70492b1e877c7ae856766f2b57ae474e07cbc이며14입력 불변이다.
초기 export는 새 clean 선언 HEAD에서 CN/TW2개씩 하고 원형을 보존한다.

## 정확 소유·역할

- ROOT: `locale/ui_zh-CN.json` 두 키 직접 KO 저작; portable 신규4/b87와 통합 검증.
- Rawls: `locale/ui_zh-TW.json` 두 키 직접 KO 저작. CN 자동 문자변환·EN 중역0.
- Poincare: 기존 `tools/I18nInfrastructureCheck.gd` 메서드1개+_run 호출1개. 다른 기존 검사 원형을 보존한다.
- Plato: 저자 아닌 CN/TW4 전수 L2·교환/원장·최종 정확 제품 독립 판정.
- ROOT는 검사 메서드·원문·실제 caller와 저장 안전성을 독립 검토한다.

운영 소유: CLAUDE 현재1행, WORK_LOG 짧은 새 절(현재39255B·40000이하·history이동0),
docs/CODEX_QUEUE.md·CODEX_QUEUE_L3_PENDING.md 이번행/순번,
docs/queue_active/ORDER-227.md·docs/queue_archive/ORDER-227_L1_L2_RESULTS.md,
docs/queue_backlog/FULL_GAME_LOCALIZATION.md 이번계측, generated STATUS,
tools/audit_scope.json active/archive2경로 등록만, agent_review_decisions 이번 내부 work_unit 판정1.
새 검사 씬/runner/런타임 소유0이며 기존 등록된 I18nInfrastructureCheck를 재사용한다.

기존 CN12051B/SHA47eb24bdd040ff39d128d516a5e5eb2ece78a9fffe9f83c1fd29ad1c391a17fc,
TW12158B/SHA27218f1f3267f85850910aa1e766a4d2e6a22fabe48ff5485c13ea64b7340b9e,
JA279965B/SHA65317ae73728eb8b40b46f5ccac2b241899153b90831f926ade40363ae5e1413를 봉인한다.
CN/TW 끝에 두 키만 append하고 역제거 시 raw exact·기존 순서/값 불변이다. JA raw 불변.
KO/EN·이벤트 전량·LocaleManager/GameState/DataRegistry/StoryMode·공개판·저장·폰트·CI·인간원장은 비소유다.

## 실제 소비자·검증

GameState.get_year_scene_candidates→build_year_scene_choices→StoryMode의 초기/refresh가
같은 두 포맷을 읽는다. 3후보 미만은 회고가 표시되지 않는다. 실제 수용된 기존
hidden_whole_picture/arc_36_father_comes_to_seoul/gambling_rock_bottom 세 family를
합성 seen-history로 넣고 KO/EN/JA/CN/TW 각3선택의 text/result를 검사한다.
기대값은 원문·raw overlay/사전에서 독립 읽으며 ui_format을 oracle로 쓰지 않는다.
각 target title≠EN, ID·순서·year_scene·effects{} 불변, 잔여%s0·두키 miss0를 확인한다.
합성 모집단은 실제 세 장면의 한 run 동시 도달·화면 관찰이 아니다.
seen-history/year_scenes·언어/진단을 복원하고 read-only serialize 전후로 게임 상태를 확인한다.
new_game/save/load/record_year_scene/choice/effect 호출0, 기존 폴백·잘못된 형식 대조는 유지한다.

검사 저작 뒤 UI 수정 전에 기존 누락 실패를 한 번 봉인하고, UI4 저작·L2 뒤 같은
소비자 검사를 한 번 재실행한다. 실패 원인은 고친 뒤 그 검사만 재실행한다.
두 언어 저자는 이 baseline 봉인 전 사전 쓰기0을 지킨다. 누락 키는 _expect 진단으로
적재한 뒤 안전하게 계속/복원하며 없는 키 접근의 script error를 재현 성공으로 세지 않는다.
실행은 기존 StoryNameplateBootstrap.gd와 새 QA namespace를 autoload 전에 적용한다.
HOME·출시모드·project.godot 변경0. fresh namespace 및 pre/post user 경로마커 exact,
exit0·정확 I18N 성공마커·stdout/stderr/Godot logfile 전체의 script/parse/engine 오류0를 요구한다.
새 메서드는 namespace가 주어진 경우만 post 경로를 assert/출력해 일반 audit 호출을 막지 않는다.
실제 사용자 settings/slot/meta 비쓰기와 격리 로그를 보존하며 삭제0이다.
격리 addendum: order226-next-ui-isolation-addendum.json SHA
ae7716e271f77d3dab8a42efde30b11b0682e97feb719f78089d2031fda9a4a4.

초기2export→각 직접 저작/4전수L2→최종2export/check/import--accept→portable4역보존,
선택4 L1·JSON 중복/%s/줄바꿈·기존원장36,072/hash/메타9 보존·공개demo정적검사,
I18n 실제 소비자(전후 각1회)·scope verify/context/queue/diff로 닫는다.
변경 경로의 audit_select --list는 확인하되 넓은 자동선택을 실행하지 않고 위 검사만 쓴다.
전체 accepted L1·overlays12·전체audit·year5·240주·화면 전수 재실행0.
기존226 기초 검사와 이번 추가4의 증거를 구별한다. 완성률·원어민·본편 GO를 발명하지 않는다.
독립 정확 C2 work_unit 판정 뒤 active raw 보관과 최종 원장·clean STATUS wrapper를 main에 결속한다.

본편 HOLD·native/render/human/physical OPEN·외부 출시 미승인.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
지속 규칙은 I18N_INFRASTRUCTURE·ZH용어집·WORK_UNIT 소유, 이번 범위·절차는 일회성이다.
