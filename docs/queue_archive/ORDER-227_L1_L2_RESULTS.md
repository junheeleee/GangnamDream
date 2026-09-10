# ORDER-227 — 중국어 연말 동적 선택 검토

> [~] 착수 — UI 템플릿2종/4값. 본편 HOLD·실제 관찰 OPEN.

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
신규2씩 역제거하면 각 기존raw exact이며 JA 원형은 그대로다. 이전226 whole605 입력 중
이 두 UI파일만 바뀌었고 역보존으로 기존36,072의 해시/검사 증거와 연결했다. 전체L1 재실행0이다.

공개 demo 정적5locale14사건100문구121UI PASS·scope verify141/guard6·context343·queue76
및 diff 검사를 통과했다. direct verify의 EXTRA15는 비실행 등록 정보이며 이전 명시차선
출력의 마지막 EXTRA2행만 보인 것과 분리한다. 일반 경로선택25개는 --list만 확인했고
선언대로 해당 소비자·추가4·공개 정적·문서 검사만 실행했다. 전체audit·overlays12·240주0이다.
실제 교환/표적 명령 출력 order227-command-results.json SHA
5ec3d28600708e0e73801d4c6535c14cbe16abdbf9e4114dbb439c70892d61ce.
WORK39609B(새354B)·예산40000이하·history 이동0, 실제 원어민/화면/실플레이·전체판은 미판정이다.
