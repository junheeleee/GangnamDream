# ORDER-220 — 선택 미리보기 언어 소비자 검토

> [x] 완료 — 위임된 내부 작업 GO. 텍스트 component 검수이며 실제 렌더·인간·전체판 GO가 아니다.
> 아래 최초 실패·대기 문장은 당시 기록이며, 마지막 확정 절이 현재 작업 판정을 소유한다.

## 실제 제품 변경

MainGame _choice_effects_preview에4줄124B만 추가했다. health와 mental에만
기존 _tr를 호출한다. KO/EN·돈·stress 반전/합산·부호·0 필터·순서·다른 stat 숨김,
입력·원고·상태·레이아웃은 그대로다. JA 사전의 健康/精神을 이제 소비하며,
해당 키가 없는 CN/TW는 기존 Health/Mental fallback을 유지한다.

전1139343B/77c690b8f4f41d9559b6aac25eb78d5de31d42be423dddbd3e889cf3287c67dd,
후1139467B/5b891505892d3306197cb20b70e4e0d8074941aeb7ec40030857bd32bb912f88.
삽입한 정확 hunk 하나만 역제거하면 전체 raw가 복원된다. ROOT가 실제 diff를 별도로 읽었다.

## 자가 component와 실패 보존

Rawls는50개 기대값을 코드 전에 봉인하고, 선언의 재선택·community/부분키
추가14를 component 전에 별도로 봉인했다. 첫50 proof의 PRE_DECLARATION 문구와
실제 선언 HEAD8360의 동시성은 정정한다. 정확한 주장은 제품 수정 **전** 봉인이다.
원형50 proof는 덮지 않았고 추가14를 원래50이었다고 쓰지 않는다.

새 검사는 실제 MainGame을 격리 초기화하고 _render_event→_finish_typing→
_reveal_choices가 만든 Label.text를 읽는다. 수작업 Label이나 helper만의 검사가 아니다.
실제 Label44개·의도된 무표시20개, dictionary와 명시 game state64개를 비교했다.
1280×800 headless component이며 렌더·전체 플레이·물리 입력 주장은0이다.

1. 첫 실행: 검사 코드 예약어 namespace로 parse error. timeout 안전 종료·로그 보존.
2. 변수명을 qa_namespace로 수리한 같은64: 문구64 PASS지만 SC/TC fontdata 캐시
   부재6 ERROR로 wrapper FAIL. exit0와 성공 marker만으로 통과시키지 않았다.
3. 허용된 격리 import1회로 로컬 캐시를 준비했다. font 원본2·.import2·project.godot·
   bootstrap·제품5·git status는 전후 exact, 새/삭제 UID0이다. editor 종료의 RID/ObjectDB
   오류는 cache 준비 관측으로 보존했고 품질 PASS에 합산하지 않았다.
4. 같은64 최종 자가 실행: Godot/wrapper exit0, 두 로그 오류0·64 PASS.
   기대값과 MainGame은 첫 동결 그대로다. 원래50/추가14·실패·재검을 독립 표본처럼 더하지 않는다.

private order220-author-component-final.json134608B/
d8632afa883b625f7539e423d3b048689260db0736b3dab3b258bad4c5bd990e에 모든 원형이 있다.
새 script15525B/59b537a380f0e7dea22fd2fdc3e66bc4e4be38acd072c742902917fb7e36db23,
wrapper5999B/addf9068790b76ac261efe0ed7086e34038fb781da10753e8e4fbd5b0fda5c05.
ROOT는 component/script/wrapper 전량을 직접 읽었고 별도 실제 실행은 최종 차선에 둔다.

## 역사 지문 연결과 한계

새 MainGame N을77c690으로 정확 역투영한 뒤 기존215 3e15와 앞선 역사 체인에 잇는다.
현재 raw를 먼저 검사하고, 과거 바이트로의 rollback은 현재 승인으로 받지 않는다.
옛 manifest·pin·validator·assert는 바꾸지 않고 명시 관측 hook만 역치환으로 검증한다.
자가 유한26/guard와 ROOT 별도12/guard의 실행 결과는 최종 동결 뒤 기록한다.
기존487/564 전체 self는 저자 단계에서 반복하지 않으며 최종 차선 한 번에 둔다.

Poincare 자가 신규26/guard와 기존 modal27/guard는 통과했다. 앞선 불일치 각2를
원형 보존했으며 전체 self를 아직 실행하지 않았다. ROOT는 실제 두 diff 전체를
읽고 코드 전 봉인한 별도12/guard를 실행해24/24 통과했다. 비소유 key·부호·0필터·
간격·갯수·CRLF·경로와 과거 rollback은 투영하지 않고 거부했다.
명시 새 block/관측 hook만 역제거해 두 이전 파일의 whole raw/AST exact,
옛 assignment·modal validator3개 AST exact와 보호12입력 불변을 확인했다.
이는 새 가드의 독립 정적 검수이며 아직 최종 전체 self나 실제 게임 실행을 대신하지 않는다.

기존 causal coverage gap/blocked·인간/원어민 OPEN은 그대로다. 새 작업 GO는
독립 검수와 정확 source가 결속된 뒤만 기록한다. 본편 전체·공개 출고는 HOLD다.
지속 언어 규칙은 기존 I18N 정본, 이번 정확 소유·절차는 일회성이다.
자동 게이트는 도달성과 계약 증거이지 재미·깊이·문체의 증거가 아니다.

## 최종 UI inventory 의존 실패 — GO 아님

source65f97eb의 overlay12에서 JA pipeline self와 ZH UI context가 실패했다.
새 _tr2가 실제 호출3342/legacy3308을 만들었는데 과거 계획은3340/3306이었다.
이를 무시하거나 호출을 숨기지 않고, 정확한 두 소비자만 별도 현재 기대 view로 검증한다.
디스크 공개 manifest와 원형 계획·기존69 self는 보존한다. active220의 별도 보완 선언
전에는 이 추가 파일을 쓰지 않았다. 수리·독립 회귀 완료 전 본 작업도 GO가 아니다.

원래220 차선은 full-body52·year5 self513·causal 실제/590 self·demo self4/실제·
scope141·queue index25·year5 실제까지 통과했다. causal590은631.85초였다.
그 뒤 shell wrapper의 실행 비트가 없어 직접 실행 전에 PermissionError로 중단됐다.
자기 검사는 bash로 호출했기 때문에 놓친 통합 결함이다. 이미 소유한 wrapper의
내용은 그대로 두고100644→100755만 고쳤다. 긴 통과 검사9개는 반복하지 않고,
미실행 Godot component와 마지막 context/queue만 실행해 결과를 따로 결속한다.
첫 실패 차선 전체를 PASS라고 기록하지 않는다.

실행 비트 수리 뒤 ROOT가 동일64를 독립 실제 실행했다. Godot/runner exit0,
두 로그 오류0, 실제 Label44/의도된 무표시20·선택과 정의된 상태 snapshot64 불변이다.
원형 runner_result/stdout/stderr/godot.log는 아래 격리 증거 디렉터리에 보존했다.
`/var/folders/yr/mf2mg8vn7yld9rk4rf3qh2y80000gn/T/gangnam-choice-preview-locale-yml86ep0`.
ROOT의 개별 assertion·전후 source 지문·로그 재독은
private order220-root-actual-component-final.json에 따로 기록한다.
이는 실제 caller가 만든 텍스트 component 검수이며 렌더/전체 플레이/사람 관찰은 아니다.

UI inventory 보완은 ja_translation_pipeline 한 파일에 한정했다. 실제3342/3308은
그대로 반환하고, 두 exact 등록을 각각1회 검사한 뒤 역사 기준의 별도 기대값에만2를 더한다.
manifest 전체 raw·과거 phase·ORDER96·기존69 검사는 그대로다. 추가 영구 CLI는 없다.
저자 고정19(정상2/변조17)와 ROOT 코드 전 별도10입력은 모두 기대 일치했다.
ROOT는 실제 diff 전량을 읽고 전달 calls·계약이 바뀌지 않는지와 삭제·중복·이동·
KO/EN 교환·미등록 추가·과거 rollback·역사/현재 count 재핀을 양쪽 실제 validator로 확인했다.
private order220-root-ui-inventory-final.json은 최초 독립10 결과이며 저자19와 분리한다.
최종 pipeline SHA0b3c9421fa1228834749309dd56ecaf8bfcf7bdea03100f44cd7eb327a94eb6d.
의존 차선과 최종 전량 L1은 이 동결 뒤 실행한다.

## 최종 확정 — 내부 작업 GO, 실제 렌더 미관찰

최종 제품 소스09bfcdedb44836ccdb249d21a08c29c70b50b7d0,
tree d0cae440f828a38b1a634dab0dacef0d18c2c55f,
마지막 검사 clean wrapper ad78e1b507c91e481966d2563a2e956aac6d5e7a다.
ROOT가 구현자와 별도로 제품 diff·새 component 전체·역사 guard 전체를 읽고,
코드 전 고정한 독립 guard24와 UI inventory10을 최초 실행해 모두 기대 일치했다.
Plato도 component code와 scoped12입력 결속을 독립 확인했다.

마지막 명시 choice-preview-ui-inventory6은 exit0이다. JA88·ZH11929,
scope141·queue index25/fence4·context·queue77/75가 통과했다.
처음 차선9개 통과→실행 권한 실패→실제 component64 재검 통과→마지막 context/queue
완료의 순서를 보존한다. 처음 실패한 aggregate를 성공이었다고 바꾸지 않았고,
이미 끝난 year5 self513·causal self590과 Godot64를 다시 돌려 표본을 늘리지 않았다.
causal의 기존 coverage gap24·snapshot debt8/blocked3과 year5 reference-only는 그대로다.

private 최종 증거:

- order220-final-ui-dependency.log2066B/
  8afd4f0cb18d8b9fd6b7444a399533258c23d1c13eafa7760e9099c97f23c825.
- order220-root-actual-component-final.json2839B/
  513e8dbaa8b7d21c308aec146d0f6a2de175e39a0f81941d222d613e2754496f.
- order220-root-ui-inventory-final.json10676B/
  873cc23f2f7ca8e32aafcc68d26ba7e208f4dc3ba45918f2fec31d4aa6c873cd.
- order219-all-accepted-l1-final.json68219B/
  3f841441cc3199a321569044c803d5092e0216ca40d7e471a7f9a56baf45f166:
  최종 QA 의존 포함587입력 전후 exact·33711 번역 hash/L1 오류0.

ROOT 최종 판단: JA 건강/정신이 기존 사전에서 실제 선택 Label로 전달되는 결함을
고쳤고, KO/EN 및 CN/TW fallback·community 우선순위·효과/선택/정의 상태의 불변을
다섯 언어64 component 입력으로 확인했으므로 이 소비자 작업은 내부 GO다.
실제 Label44/의도된 무표시20이며 전체 장면 렌더·플레이·물리 조작은 미관찰이다.
CN/TW에 없던 UI 사전을 새로 완성한 작업도 아니며 남은 다른 direct-EN 소비자도 별도다.

정본 판정: 지속 routing은 기존 I18N_INFRASTRUCTURE의 UI Contract,
증거/위임 경계는 WORK_UNIT의 3절이 이미 소유한다(중복 승격 없음).
이번 exact 소유·지문 역연결·고정 UI 등록2·검사 입력과 재실행 순서는 일회성이다.
공개 manifest·원문·인간 기록·project.godot·사용자 저장은 그대로이고 전체판 HOLD를 유지한다.

## 착수 선언 원문 보관 — 일회성

Plato 최종 독립 결속 검수도 blocker0이었다. pipeline 기존61함수 중58 AST 불변,
변경3 hook 역치환과 신규2 제거로 이전174985B 전체 raw를 정확히 복원했다.
기존69 self·상수·collector·디스크 manifest 불변과 실제3342/3308을 확인했다.
private order220-independent-final-linkage.json27775B/
1ce9a8e78f3613fd973a94ea99bad3c4a451d89bd9a1b9e3b1e001073013e215.
archive 작성 중인 문서 변경은 제품 입력과 구분했고 원격 CI는 판정하지 않았다.

아래 [~]은 당시 선언의 원형이며 현재 상태는 위 [x] 완료 판정을 따른다.

````markdown
# Active Queue Spec: ORDER-220

> [~] 착수 — 선택 효과의 번역 소비자 한 곳과 그 표적 회귀만.

#### [~] ORDER-220 [P0] 선택 미리보기 일본어 건강·정신 표시

기준 main c0dac7467a23e64e0148fe9f049a915694857a7f.
## 깊이와 결함

1. 기존 JA 건강=健康/정신=精神이 있는데 _choice_effects_preview가 is_english 분기로
   건너뛰어 Health/Mental을 내보낸다. 번역 존재와 플레이 표면이 끊긴 실제 소비자 결함이다.
2. 선택 상태/효과·24주 결과를 바꾸지 않는다. 고르기 전 읽는 언어만 바로잡는다.
3. stat 우선순위·돈·줄 간격·다른 정보량과 경쟁하지 않으며 health/mental만 기존 _tr로 보낸다.

_render_event→_reveal_choices→_choice_effects_preview→실제 Label이 대상이다.
13개 direct-EN 분기 조사 중 확인된 이 소비자만 수리한다. CN/TW에 해당 UI 키가
없는 경우 영어 fallback이 정상이며 새 번역 사전을 이 작업에 끼우지 않는다.
LocaleManager.is_english의 non-KO 계약, community overlay 우선순위와 cache를 바꾸지 않는다.

## 소유

- Rawls: scenes/MainGame.gd의 해당 소비자, 신규 tools/ChoicePreviewLocaleCheck.gd,
  tools/ChoicePreviewLocaleCheck.tscn, tools/ChoicePreviewLocaleCheck.gd.uid,
  tools/run_choice_preview_locale_qa.sh.
  테스트 전용 초기화는 autoload보다 먼저 격리하고 실제 사용자 저장/설정을 읽거나 쓰지 않는다.
- Poincare: tools/year5_reference_route_audit.py,
  tools/chapter1_core_loop_v2_causal_ledger_check.py의 exact 새 byte 전이와 해당 self hook만.
  219 TW2파일 동결·반납 뒤 이 두 파일을 순차 소유한다.
- ROOT: tools/audit_scope.json의 전용 named 차선/검사 정확 등록, CLAUDE.md,
  docs/queue_active/ORDER-220.md, docs/queue_archive/ORDER-220.md,
  docs/CODEX_QUEUE.md, docs/CODEX_QUEUE_L3_PENDING.md, docs/WORK_LOG.md,
  generated docs/STATUS.md, docs/agent_review_decisions.json의 새220 기록만.
- KO/EN prose·data/effects·UI dictionaries·LocaleManager·StoryMode·입력·저장·레이아웃·폰트·
  project.godot·공개판·인간/출시 manifest·완료215/218 증거는 비소유다.

## 코드 전 기대값과 회귀

Rawls는 구현 전 유한 실제 입력/기대값을 private proof에 봉인한다.
health3/mental2/stress5/intelligence99는 KO 건강+3 정신-3, EN Health+3 Mental-3,
JA 健康+3 精神-3, CN/TW Health+3 Mental-3이다(표시 간격은 기존 그대로).
money의 ₩/KRW·수치·부호는 기존 각 언어 출력 그대로다. 기대값을 수정 후 제품에서 생성하지 않는다.
양/음/0·stress 반전/mental 합산/상쇄·숨긴 stat·순서·원본 dictionary 불변,
locale 재선택과 community override/부분키 fallback을 실제 component에서 검증한다.
자가 표적1회 뒤 ROOT가 caller Label/격리·결과를 별도로 읽고 실제 Godot에서 실행한다.
headless 표적은 렌더나 정상 속도 전체 플레이로 기록하지 않는다.

현재 MainGame1139343B/77c690b8f4f41d9559b6aac25eb78d5de31d42be423dddbd3e889cf3287c67dd.
새 승인 N은 실제 저작 동결·ROOT diff 확인 뒤만 계산한다. N의 정확 소유 hunk만
역치환→77c690→기존215 3e15→역사 체인으로 연결한다. 옛 pin/상수/manifest/validator 불변.
현재 raw 검증을 projection보다 먼저 하고 rollback·다른 파일·타 바이트 변경은 거부한다.
private order220-guard-chain-readonly-plan.json 14900B/
b04e3385c4d37b49719bc1e758a4388ee376b0880607f534ce6efca30606e58f가
guard당26개 사전 변이 설계를 소유한다. 실제 N/hunk로 결속한 입력을 guard 저작 전에 봉인한다.
기존 self 관측 hook은 파일당2곳만 잇고 assert·변조와 옛 전체 AST는 명시 역치환으로 보존한다.

## 완료 경계

저자 focused 검사와 old modal27만 먼저 실행하며 기존 전체487/564 self는 반복하지 않는다.
ROOT 독립 변이·raw 역치환·보호 지문 검수 뒤 전용 named 차선 --list→최종1회를 실행한다.
그 차선은 두 실제 guard/전체 self, demo self/실제, full-body self, 신규 Godot component,
queue/index/scope/context를 포함한다. stdout와 Godot log 양쪽 오류·필수 marker를 검사한다.
기존 causal coverage gap/blocked와 인간 OPEN을 가짜 완료로 바꾸지 않는다.
깨끗한 새 exact source·독립 검수 보고를 작업 GO에 결속하고 원문 사양을 archive한다.
원어민·화면·인간·물리·본편 전체 GO나 외부 출시의 증거로 합산하지 않는다.

지속 언어 routing 규칙은 기존 I18N_INFRASTRUCTURE가 소유한다. 이번 exact 소유·전이·절차는 일회성이다.
자동 게이트는 도달성과 계약 증거이지 재미·깊이·문체의 증거가 아니다.

## 2026-09-09 필수 QA 통합 보완 선언 — 제품 범위 추가 없음

clean source65f97eb100e630bedd7993a893406ec495fc5c6b에서 최종 overlay 차선이
JA pipeline self와 ZH UI context에서 실패했다. 승인한 literal _tr2 때문에
실제 호출3342/legacy3308이 과거 계획3340/3306보다2개 늘어난 정확한 의존 결함이다.
번역·MainGame·UI dictionary·공개 manifest를 바꾸는 신규 제품 범위가 아니다.
기존 실패 원형을 보존하고 같은220의 필수 검사 통합 파일만 아래처럼 추가 소유한다.

- Rawls: tools/ja_translation_pipeline.py의 현재 UI inventory 검증과 그 focused self만.
  전달받은 UiCall에서 MainGame/_choice_effects_preview/legacy의 건강/Health,
  정신/Mental을 각1회 검증한다. 삭제·중복·함수/KO/EN 이동을 거부한다.
- 관측 calls·통계3342/3308은 그대로 반환한다. 원형 계약을 변형하지 않은 별도
  기대 view에서 current_source_snapshot의 두 count와 final phase의 두 count만
  고정 등록2를 더한다. 발견 개수에 따른 자동 허용·호출 필터·일반 숫자 면제는 금지다.
- 디스크 demo_localization_scope 전체 raw, ORDER96 상수·107-key·34 migration·29 IDs,
  key SHA·baseline/A/B phase와 기존69 self는 원형을 보존한다. 기존 final3340/3306
  기대값과 새 실제3342/3308은 따로 검증한다. 정상·변조를 코드 전에 봉인한다.
- ROOT: 기존 audit_scope 소유 안에 이 파일과 명시 choice-preview-ui-inventory 차선을
  등록한다. 실패2와 새 focused 회귀만 다시 실행하고, 이미 진행 중인 원래220 차선의
  두 긴 self·Godot을 이유 없이 재실행하지 않는다. 소스/검사 입력 불변을 별도로 결속한다.
  독립 고정10입력은 private order220-root-ui-inventory-precode.json에 코드 전 봉인했다.
- 기존219 수용 원형·L2·교환은 불변이다. 새 pipeline을 쓰는 최종 전량 L1은 입력 지문과
  함께 재확인한다. 같은 실패의 수리·재검을 새 블라인드 표본으로 세지 않는다.

이 파일 소유 보완과 검사 순서는 이번 오더 한정이다. 두 활성 배치와 제품 범위는 유지한다.
````
