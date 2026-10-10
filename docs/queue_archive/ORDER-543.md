# ORDER-543 — 본편 상철 첫 만남 날짜 표시 수리

#### [x] ORDER-543 [P1·소비자 정합] 기존3변형 × 5언어 — 2026-10-11 준비 소비자/source 한정 GO / 제품 HOLD

부모534 정상 선행에서 실제 W14(4월)에 ‘3월 끝’이 나온 확인 결함이다.
공유 M04 데모 원문을 바꾸지 않고 본편 표시만 수리한다. 542와 별도 구현 범위이며
이미 완료한 M07 기능·정상 플레이를 반복하지 않는다.

## 깊이 3문·한 배치

1. 실제 본편 첫 만남 달력과 고정된 3월 말 문구가 충돌한다.
2. 날짜를 4월로 다시 고정하지 않고 첫 날짜 접두만 제거한다. 기존 선택·효과·
   관계·진입·타이머·owner·경제·save schema/원문/번역/원장은 불변이다.
3. 새 장면이나 시스템이 아니다. 기존 resolver의 본편 표시 정합 수리다.

모집단은 arc_sangchul_01_meet 기본/orthodox/unorthodox × KO/EN/JA/CN/TW
15표시 전수다. KO ‘3월 끝, ’, JA ‘3月の終わり、’, CN ‘三月底，’,
TW ‘3月底，’만 제거하고 EN ‘Late March, just’를 ‘Just’로 바꾼다.
정확한 접두가 없으면 그대로 둔다. 나머지 문장은 byteexact다.

## 파일 소유

- root: scenes/StoryMode.gd. 기존 변형 선택·memory 뒤 _fmt 앞에서 단일ID,
  valid_session + is_full_run, 공개 demo namespace/return scene 아님,
  read-only replay 아님일 때만 exact locale 접두를 투영한다.
- cjk_wrap_diagnosis: tools/ManualSaveCheck.gd만. 기존 초기화·v4저장·locale/history
  helper를 재사용한 표적 focus를 넣고 기존 일반 실행에도 연결한다.
  기존8/12/production/240 본문·새 runner/제품 profile/도구최적화0이다.
- phone_cn_author: tools/english_hangul_audit.py만. 새 KO exact 접두 matcher는
  출력문이 아닌 내부 literal이다. 정확한 파일/전체줄만 귀속하고 기존 검사는
  유지한다. wrong-file/altered-line/inline leak 음성 self-test를 추가한다.
- phone_independent_review: 비저자 전수·경계·보존 검수,
  docs/agent_reviews/ORDER-543.json만 소유한다.
- root 기록: 이 사양/완료 archive, CODEX_QUEUE/L3순번, WORK_LOG, CLAUDE현재행,
  agent_review_decisions. 필요시 원문 보관 회전만 기존 history에 byteexact로 한다.

## 표적 검증·주장 경계

- 전수15 resolver/page exact, 원본registry/GameState 불변. 정상 full initializer가
  만든 W1 owner에 meet를 handoff한 prepared 소비자 표본이며 W14 정상 도달이 아니다.
- 5locale 각각 부분 산문 v4 disk/load·source paragraph·새 대화 기록·효과 중복0.
  KO↔EN은 실제 언어 변경 consumer, JA/CN/TW는 내부 지원locale 주입이다.
  현재 본편 메뉴의 출시 언어 allowlist를 확대하지 않는다.
- public M04/return scene, read-only flag, preview8/12, unmarked, damaged owner,
  다른ID/불일치 접두 무변경. demo/V2는 명시 인자별 별도 격리 프로세스로 확인한다.
  meet는 gallery root가 아니므로 read-only 음성 표본을 실제 gallery 관측으로 쓰지 않는다.
  과거 대화 기록 소급 재작성/migration0, 기존 저장 본문 기록은 보존한다.
- pre-autoload bootstrap + fresh HOME/XDG/namespace에서 compile/표적 Manual.
  exact marker + stdout/stderr/Godot log의 engine/script/parse 오류0을 함께 요구한다.
  EN coverage/한글+self-test, 원장 inventory, 서사/음악/말투, 데모 고정·언어,
  release inventory/context/큐/diff 관련 차선만 실행하고 새 실패0을 확인한다.
  영향 목록만 먼저 본다. 전체감사·옛 whole8/12/production·240주·ObjectDB탐색0이다.

## 금지·완료

content 전체·FGL 영수증·demo pin·public 패키지·project.godot·사용자 저장·
과거 인간/agent 판정 불변. 변경 없는15원문에 번역 영수증을 새로 발급하지 않는다.
공개 M01–M06 표시는 보존하고 본편의15표시·제외 경계와 표적 새실패0·독립 정확source
GO만 닫는다. 자동 계약은 재미·깊이·문체의 증거가 아니다.
변경 후 native 정상 화면/원어민/인간/물리패드·M08 이후·전체본편·출시는 OPEN/HOLD다.
새 정본 규칙0/이 사양의 실행 지시는 일회성이다.

## 구현·표적 결과

StoryMode는 정확한15원문의 날짜 접두만 본편 표시에서 제외한다. EN의 just는
문두 Just로 바꾸며 나머지는 exact다. 기존 변형/memory 뒤 _fmt 앞에 연결해
초기 페이지·언어 refresh·새 대화 기록이 같은 소비자를 읽는다. 원문/번역/FGL/
inventory/공개 row/pin/프로필/달력/선택/효과/save schema 변경0이다.
EN 한글 검사는 출력되지 않는 KO 접두 matcher의 exact 파일/wholeline만 귀속했고
기존18+신규15 self-test33가 통과했다. 다른 출력 literal/파일/변형13은 여전히 거부한다.

정적23 모두 actualexit0/stderr0·새 실패0이며 소유 source6 before/after exact다.
이 검사는 Manual 작성 전의 Story/ENaudit/내용 원장에 대한 실행이며, 새 Manual은
아래 final 엔진 실행으로 직접 컴파일·기능 검증했다. 전체감사/240/옛whole8/12/production0.
초기 compile69는 독립 보호 snapshot 전에 실행됐으므로 그 실행의 사전 독립 보존은
주장하지 않는다. 이후 Manual 전에 fresh 보호 기준을 봉인했다.

최초 normal은 v4 raw history 비교10건만 FAIL이었다. 원로그를 보존하고 기대값만
기존 JSON round-trip으로 직렬화 표현에 맞췄다. 후속 normal의5행 실제 관측에서
locale별5 numeric leaf가 memory INT2→disk FLOAT3인 것과 전체entries exact1을 확인했다.
새/옛 기록의 필드·본문·순서/owner/경제/진행 비교는 유지했고 SaveManager 수정0이다.
final normal actual0/8.179554s·exactmarker1/3stream 오류·경고·누수0이다.
15 fresh 페이지와5locale×새/합성과거history의10회 same-process v4 disk/new-Story,
KO↔EN 실제 consumer와 제외 pure probes가 통과했다. 정상 W14/native/new OS cold가 아니다.
demo/V2 초기 별도 프로세스는 actual0/marker/원문15 무변경 PASS이며 해당 분기 수리0이라
반복0이다. compile+초기3+후속1 총5run의15원stream·static46stream을 보존했다.

비저자 fresh 보호69그룹/1074파일과 비소유 tracked제품2382가 exact다. helper5/seed2/
W238/player33·인간 원장·과거282판정·15원문/번역/잔여·FGL/기존영수증을 보존했다.
baseline38454B/SHA2a79c9e0478472db6883ba159261b8518b72ee629d1ebdf8c33a7185f68ea54d,
final15096B/SHAc3d1ee9b35896d30d74f9e33580f04a4808c2e211619004bb4767566cf16c3aa는
.git/order543-qa-20261011/의 독립 private 증거다. 제품3 및 CLAUDE현재2행만 바뀐
clean e8c0e9829cc40aef8c37a7db3d6b95c26db33d60/tree7da0272c7b06b48f61dcacb231eb6dafddf6a32c를
최종 source 후보로 삼는다. 독립 최종 보고의 SHA는 WORK_LOG/판정 원장에 결속한다.
자동 계약은 재미·깊이·문체 증명이 아니며 새 규범0/실행 지시 일회성이다.
