# ORDER-227 — 중국어 연말 동적 선택 검토

> [x] 내부 작업 GO — 2026-09-10. UI 템플릿2종/4값. 본편 HOLD·실제 관찰 OPEN.

앞선462 수용은 제품3b4866a215ed201be494912076db4b07e0792ac6의 내부 작업 GO다.
clean wrapper2dbb6b2b813ae662d78323dec734c87df4937aea를 main에 push했다.
이번 준비는 ORDER-226의 source/UI/격리 preflight에 근거하며 전체 UI 완료가 아니다.
CN/TW baseline 실패 봉인 전 사전 쓰기0, JA 기존값/사건/게임 상태/공개판 원형을 보존한다.
직접 소비자 검사는 합성 seen-history이며 실제 도달·화면·인간 플레이·원어민 증거가 아니다.
지속 규칙은 I18N_INFRASTRUCTURE·ZH용어집·WORK_UNIT 소유, 이번 범위·절차는 일회성이다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

선언 첫 큐 검사는 새1행이 이어보기 뒤에 있어 순번 오류였다. 기존75행을 바꾸지 않고
새 행만 이어보기 앞 독립 표로 옮겨 재검했다. 제품·번역 저작 전 운영 수정이다.

## 기준·직접 저작

clean 선언 wrapper edb9f95034cc93f2c708525af11f61d83f668341에서 CN/TW 각각2개 초기
export를 발급했다. 각1953B·header11/body16·previous=SHA(null)다.
CN SHA2350f02ee6debbd8e657aa2442eb6694d3fd4aea9d278b4ff0466821cc51207c,
TW SHA257ac6cfafced4791037c10e0d52311f46ca86a246f8e309e5f3aa9028b4115d.
독립 초기 결속 order227-independent-initial.json13451B/SHA
a8c9cb8e72eeaba628db0b43f799738f9150b467b43880a07302f22b4796e120.
기존 UI는 CN/TW 각122키다. 공개 데모121 요구키와 전체 파일 키 수를 혼동하지 않는다.
JA 사전2901키 중 이번2값은 존재하지만 미수용이므로 새4값에 넣지 않는다.

ROOT CN2와 Rawls TW2는 KO에서 각각 직접 저작했다. Plato가 비저자로4문구 전부
의미·자연성·지역 인용부호·%s1/LF0을 대조해 필수0·선택0으로 판정했다.
독립 private초안 L2는 order227-independent-draft-l2.json7258B/SHA
220082afea37f1703a11255543ae88e44a3272b93742c3e02ce3b6252ca49b47다.
CN ‘合上那一年的篇章，最先留在心里的是“%s”。’와 TW
‘收起那一年時，最先留下的是「%s」。’는 새 만남·일정·선택 효과 없이 회고만 옮긴다.

## 실제 소비자 — 최초 오류와 누락 기준선

Poincare의 메서드1+hook1은 ROOT가 전부 독립 읽고 고정했다. 최초 실행은
state_restored의 Variant 비교 추론 때문에 parse 오류가 났으며 누락 재현으로 세지 않는다.
관측한 해당 Godot pid/pgid85438만 SIGTERM(-15)했다. 원형 전체 stdout/stderr/engine은
order227-runtime-first-parse.json/SHAee25b6ca1baa3aaf8a39d5ce380c0d59a957719a131a9491eb75d9e49a931772.
pre-autoload 마커만 있었고 post 미출력이라 이 실패 실행의 격리 완료도 주장하지 않는다.
Poincare가 bool 명시1곳5byte만 고쳐 최종 검사29978B/SHA
f452dab9b02a13a402a4230670c59717b7e7541cdc24b8efaf4bf735ebed0062로 동결했다.
추가 메서드/hook 역제거 시 기존19887B 검사 원형 exact다.

UI 쓰기 전 같은 검사 재실행은 정상적인8실패(키 누락4+EN fallback miss4)·engine exit1이다.
5언어×3후보=15선택·30필드 전체와 state_restored=1, pre/post 사용자 공간 exact를 확인했다.
CN/TW12필드는 실제 영어 제목/문장으로 나왔다. script/parse/compile 오류0·입력13불변이다.
원형 order227-runtime-baseline.json, engine log는
/private/tmp/gangnam-i18n-year-baseline.Rktu5A/godot.log에 보존했다.
두 저자는 이 기준선 봉인 전 실제 사전 쓰기0을 지켰고, 봉인 뒤에만4값을 append했다.
HOME·제품모드·프로젝트파일·실제 사용자 저장파일 변경0, 새 임시 namespace는 삭제하지 않는다.

## 최종 실제 출력·수용

UI/검사 C1 clean `25821b48b7f0ee53194bd9db61ea34ab88356c35`에서 final2export를 발급하고
같은 f452dab9 검사 코드를 실행했다. 실제 engine exit0·정확 I18N 성공마커,
15선택/30필드·state_restored1·pre/post 격리·script/parse/engine 오류0·입력13 불변이다.
CN/TW12필드만 지역 문구·제목으로 바뀌고 KO/EN/JA18필드는 기준선과 exact다.
기존 invalid-format 의도 경고19는 전후 동일하며 실제 오류나 새 성공으로 합산하지 않는다.
runtime-final.json SHAea3920c2e10c738fe512a3d8fe3bbed02d4fafc74fe49badac7fe020906635d4,
engine은 /private/tmp/gangnam-i18n-year-final.FAEBk9/godot.log에 보존한다.
runner 자체 exit0이 아니라 JSON 안 engine_exit·마커·전체 로그·격리·15/30을 판정했다.

ROOT는 검사 코드 전체와 실제 기록을 검토했고 Poincare는 UI4의 비저자로 원문·L2·raw사전·
raw제목15를 독립 대입해 기대30필드 전부를 비교했다. source/L2/결과 필수0이다.
검사 저자 역할은 숨기지 않는다. order227-independent-runtime-final-review.json8279B/SHA
a14889dceb2ec1a2396955d80f68a01cc09c2a22be4613f7a402c11eb338be5e. 재실행0이다.

최종 check2/import--accept2는 각2문구 PASS·changed_files0다. 공식 영수증과 L2의4
source/target hash를 새 portable b87에 결속했다. 누적36,076/JA12,024·CN/TW각12,026,
portable9346971B/SHA6f0922de659bbf70dc9054a9508ef582f8633d1ad9a57a5d939eb6d065bd1fdf다.
신규4+b87만 역제거하면 이전9345058B/36,072/b86/meta9의 전체 raw를 정확히 복원한다.
다른 top값/순서·기존 accepted 순서/값은 그대로다. 계획뿐 아니라 실제 적용 raw·역보존을 확인했다.
CN/TW 사전122→124 각각12207B/c5c89de364bf82f2a6fcf74b9eb6763bd987e6eea23d65e6ded9690ab60dc585,
12302B/e15c31da7138f23bff2eded59cc51eae14e8ae2de1d3d56a5dfbeb79b1b0b85a다.
신규2씩 역제거하면 각 기존raw exact이며 JA 원형은 그대로다. portable 수용 전 C1 직전
관측에서는 이전226 whole605 중 UI2만 변경이었다. 최종 C2에서는602불변+의도된3변경
(UI2와 portable1)이며 각각의 raw 역보존으로 기존36,072 증거와 연결한다. 전체L1 재실행0이다.

공개 demo 정적5locale14사건100문구121UI PASS·scope verify141/guard6·context343·queue76
및 diff 검사를 통과했다. direct verify의 EXTRA15는 비실행 등록 정보이며 이전 명시차선
출력의 마지막 EXTRA2행만 보인 것과 분리한다. 일반 경로선택25개는 --list만 확인했고
선언대로 해당 소비자·추가4·공개 정적·문서 검사만 실행했다. 전체audit·overlays12·240주0이다.
실제 교환/표적 명령 출력 order227-command-results.json SHA
5ec3d28600708e0e73801d4c6535c14cbe16abdbf9e4114dbb439c70892d61ce.
WORK39609B(새354B)·예산40000이하·history 이동0, 실제 원어민/화면/실플레이·전체판은 미판정이다.

## 최종 내부 판정·보관

Plato가 exact C2 `42572bfbf5521cea690010210600225a9dd9d4a5` /
tree `bce426b65240a1eae68456fbeac9416c0c38caf6`의 clean 전후·입력38 exact를 확인하고
ORDER-227 한정 GO·필수0으로 판정했다. ROOT는 이 독립 근거를 검토해 해당 수리를 수용한다.
공식 교환8파일과 신규4/current L2/receipt/portable, old36,072/meta9·UI122 raw 역보존,
JA/human/agent13·WORK354B추가/39609B를 확인했다. 현재605의 시점 차이는 위에서 정밀화했다.
최종 증거 order227-independent-c2-review.json15352B/SHA
7f89c8775611ae0c0cc9f6f6a0c3b34ea4e97f8b10ffd05db832bcfa454cffcb. 추가 검사 실행0이다.
이후 이번 agent14·큐75 복원·활성 원문 보관·generated STATUS만 metadata wrapper로 결속한다.
본편 HOLD·원어민/화면/실플레이/현재 원격CI 미판정, 외부 출시 미승인이다.
active 원문은 아래 손실 없이 보관하고 활성 파일만 제거한다. 다른75행은2dbb6b2 기준 raw로 복원한다.
추가 정본 규칙0, 소유·모집단·순서는 일회성이다.

## 활성 선언 원문 — 손실 없는 보관

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
