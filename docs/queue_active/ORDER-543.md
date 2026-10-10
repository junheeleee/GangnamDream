# ORDER-543 — 본편 상철 첫 만남 날짜 표시 수리

#### [~] ORDER-543 [P1·소비자 정합] 기존3변형 × 5언어 — 2026-10-11 착수 / 제품 HOLD

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
