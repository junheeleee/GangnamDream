# ORDER-484 — 카지노 용어집의 중국어 폴백16키

#### [x] ORDER-484 [전체 현지화] 한국어 직접 CN/TW16×2·고정 끝점 연결 — 2026-10-09

## 판정 단위 / 깊이3문

- 지우면: 실제 JeongseonCasino._show_casino_glossary의 고유20키 중 이미
  중국어 수용된 다이사이/카지노 허브로2와 별도 사실수리가 필요한 natural2를
  빼면16키가 두 지역에서 영어 폴백이다. 파일 전체 고유49키를 누락16이라
  부르지 않는다. 16에는 JA 값이 있지만 공식 영수증이 없으며 이번 JA 수용0이다.
- 뒤의 독자: scenes/JeongseonCasino.gd:831/852/859~867 → _tr:63 →
  LocaleManager.ui:150 → locale/ui_zh-CN.json·ui_zh-TW.json. 용어·설명·원화·
  확률/배당 숫자·손실 위험을 원문에서 각각 직접 옮긴다. 효과/경로 변화0이다.
- 경쟁: 새 KO/JA 키 교체까지 같은 배치에 넣으면 Casino source-census와
  sealed JA/retained 경계를 다시 열어야 한다. 먼저 source 불변의16키32값만
  닫고 natural의 KO/JA 사실오류(둘 다8/9면 무조건무승부)는 다음 별도수리로
  남긴다. EN/실제 Baccarat 승패는 이미 큰 점수승리·같을 때tie다.

근거: 사용자 전체 JA/CN/TW·UI 소비자·효율적 검수 위임, ORDER-157과 WORK_UNIT.
읽기 조사만 끝났으며 아래 선언 push 전에 새 번역/공식/collector/engine0이다.
새규범0/일회성. 전체게임·카지노 전체UI·원어민·출시 GO를 주장하지 않는다.

## 정확한 선택16

카지노 용어 설명; 하우스엣지 및 그 설명; RTP 및 그 설명; 배당률 및 그 설명;
커미션 (바카라) 및 그 설명; 더블다운 (블랙잭) 및 그 설명; 다이사이 설명만;
빅/스몰 (다이사이) 및 그 설명; 마틴게일 및 그 설명.

private exact leaf-ID 목록을 현재 _show_casino_glossary literal에서 도출하고,
위16/제외4·원문Hash·실제 수집한 builtin_overlay_static_only/protected=false를
대조한다. 자연스럽게 수량을 읽되 1.06/0.5/2.70/90/35:1/45:1/1.5:1/5/0.95:1/
2/1/10/11/11~17/4~10 및 원화100만원/90만원의 의미를 보존한다.

## 정확 소유 / 실행 단계

- order469_main: private .git/order484-*의 CN/TW32 초안·응답만. 실제 KO16과
  I18N/ZH 정본에서 지역별 직접 저작한다. 자동 문자변환·영어중역·tracked 편집0.
- root: 공식 export/check/import의 locale/ui_zh-CN.json·locale/ui_zh-TW.json16씩;
  content/meta/full_game_localization.json 최초32/batch2·공식headers/receipt SHA만.
  private 선택/원문/실행기·원결과/지문, tools/audit_scope.json 명시 차선/검사만,
  큐/L3·사양/완료archive·WORK_LOG/허용history 롤링·생성STATUS·agent 원장·
  CLAUDE.md 현재상태 한 줄만.
- 2026-10-08 최신 사용자 결정(PR #32)이 위임 범위를 갱신한다. 미구현이던
  history helper5 확장·새 전용 self CLI·오더별 agent_reviews 파일 계획은 중단한다.
  옛 private 연결 초안과 과거 검사/판정은 삭제하거나 성공으로 바꾸지 않는다.
- root: 동일한 고정 제품 후보의 지역별 독립 checkout에서 기존 원공식
  check/import를 실행한다. 원 collect·모집단·함수·target hash·영수증 검증은
  그대로다. 지역별 import가 다른 지역의 옛 이력 핀을 무효화하는 문제를
  checkout 분리로 피하며, 캐시·collector 대체·새 검사 도구는 만들지 않는다.
  실제 검증된 UI2와 원공식 receipt2만 main에 한 묶음으로 반영한다.
- 비저자: 새로 관찰한 원문 export·실제 diff/공식/표적 소비자와 제한을
  독립 대조한다. 오더별 새 보고 파일은 만들지 않고 실제 결과는 WORK_LOG에
  남긴다. 장/릴리스 단위 독립 판정과 인간·원어민 관찰은 별개다.

먼저 source 불변에서 실제 공식 export2를 원문 증거로 보존한다. 초안은 private에서
병렬 작성할 수 있지만 export/검수의 live guard 안에서는 tracked/helper/HEAD를
바꾸지 않는다. 그 다음 동일 제품 후보의 지역별 fresh 공식 check/import2씩→
검증된 UI2·원영수증2·원장1을 결속한다. 대상 수동편집 시 현재 target hash로 새export하고
옛export는 보존한다. 모든 실제 main/collect invocation 수와 후보를 각각 남긴다.

## 표적 검수 / 마감

### 재개 입력 — 2026-10-08

옛 private preexport4는 before/CN빈로그만 있고 프로세스·원result가 없다.
성공·소실 원인·정상종료 보존을 추정하지 않으며 유효 export/수용0이다.
149 실제창 후속 wrapper 마감 뒤 clean입장에서 원pre_export4.py를 새
preexport5 디렉터리로 실행한다. 옛1~4시도/초안32·준비PASS는 그대로다.
원main/collect/UIcollector 각2·원source17행씩2·원exit/보존/observer복원 뒤에만
후속 typed 연결을 수정한다. 실행 중 tracked/helper/HEAD 변경0이며 새규범0이다.

1. source16·CN/TW32의 의미/숫자/원화·지역문자/토큰/개행·전량 KO 대조 및
   실제 기본수용기 export/check/import. accepted 예정41855→41887/b280→282는
   계획일 뿐 실제 원공식 영수증/원장 대조 전 완료로 세지 않는다.
2. 원UI/receipt 이전members/raw·모든 비소유source/JA·retained·공개/과거판정
   불변과 변조거절을 기존 제품 검증 API로 확인한다. 옛141/222/365/
   전체self/동일UI·240주·전체스토리·출시감사를 관성 반복하지 않는다.
3. 실제 원collector 입장 및 바뀐 UI/receipt consumer·JA UI/demo/ZH demo·
   en_coverage/english_hangul/등록을 영향 입력으로 선택한다. 입력이 같은 사건
   본문/연출 결과를 새 실행이라고 세지 않는다. whole pipeline 비용·실행시간과
   contract 검사를 재미/문체·원어민/실제 화면/자연 플레이/패드 관찰로 바꾸지 않는다.
4. 가능한 준비 소비자 검수에서는 실제 LocaleManager→Casino 제목/term/definition
   node를 지역별16값과 대조한다. 실제 화면/키보드 미관찰이면 그대로 OPEN이며
   과거 잠금 확인을 이유 없이 반복하지 않는다. 정상 player namespace는 금지다.
5. L2 전7칸·실제 결함/수리/실패 원형·독립 최종 판단 뒤 검증분만 main에 마감한다.
   새 실패0 전에는 완료하지 않는다. 새규범0/이번입력·typed 단계·검수는 일회성이다.

project.godot·사용자 저장/seed·Casino/KO/EN/JA·경제/엔딩/라우팅·공개 데모·
SHIPPING_LANGUAGES·과거판정·human_gates.json은 변경/stage0. 본편HOLD·공개GO1·
인간OPEN45/done1·원어민/물리 관찰 OPEN 유지, 외부출고/스토어/지출/법률권한0이다.

### 원문 export5 중단·선행 수리 — 2026-10-08

own PID18332 SIGINT 뒤 실제 wrapper1/3950.184972초로 종료했다. 원main/collect/UI
진입1씩·None 반환1·유효수집/export/수용0이며 보존/observer복원true다.
원결과SHA51851de6e81b756f430e269da90244d724d038c08e6b9524883edb4c099e6223과
초안·준비/옛실패는 그대로다. [별도486](../queue_archive/ORDER-486.md) 순수 계산 수리 뒤 원 export2를
재개한다. guard 정상 성공이나 전체병목 원인·속도개선으로 바꾸지 않는다.

### 수리 마감 뒤 원문 export6 재개 — 2026-10-08

source940ad0b의 도구 한정GO 뒤 clean metadata wrapper에서 private pre_export6.py를
새 attempt preexport6로 실행한다. 옛runner/1~5는 불변이다. 원 main/collect/UI를
바꾸지 않고 각 원 main 작업에 B/F pure_semantic_scope를 한 번씩만 감싼다.
원 main/collect/UI 각각2·source17행씩2와 clean/current/protected 전후 guard,
원 함수 identity·observer복원은 그대로다. operation 각각 cold0·retained dict
종료clear·token복원을 기록하며 원 export2가 실제 종료되기 전 tracked/helper/HEAD
변경0이다. 원공식 export/check/import 성공·32값수용·전체속도 개선은 아직0이다.

### 원문 export6 실제 종료·최신 검수 결정 적용 — 2026-10-09

원 main/collect2가 각각 정상 종료했고 CN/TW 원문16씩·UI3478/errors0·
동일 source manifest/17505잎 지문과 전후 preserved/observer복원true를 확인했다.
당시 후보는 d231078이며 result.json passed=true다. CN/TW source SHA는 각각
fdd195c85d54883677a909bf3d3210dcd50c631949b350949275352b9322ebfc /
645861523a56118b97b5ec6473f8c7329c95f683b80586ba0fae4bad6d4ce18c.
source16·초안 대응을 비저자가 지역별 새 export에서 확인했다. check/import·
32값 수용·실제 화면 완료는 아직 아니다. live guard 종료 뒤 docs-only PR #32
merge b81d2b0을 로컬 main에 fast-forward했다. 제품 원문/번역은 동일하다.
이 오더를 마친 즉시 상시 실패 표→별도 삭제 커밋→KNOWN_FAILURES/녹색 CI의
검수 정리 오더만 진행한다. 479·481 및 비용/재사용/시간단축 후속은 중단하며
정리가 끝날 때까지 다른 새 오더를 열지 않는다. 기본 arc_36_unexpected_hand의
"지난 주말 가지 못한 곳"은 정리 이후 문장 묶음으로 남긴다.

### source/UI 한정 마감 — 2026-10-09

원 regional import의 실제 accepted receipt2와 UI16씩을 main에 결속했다.
source faa71588579d52e5f145b68b313f86d4e4523ec6 /
tree246f8162830e4290637b017d449081358fcbbe26, 변경은 CN/TW UI·원장3뿐이다.
UI1811→1827씩, 원장41855→41887/b280→282이며 기존 값·순서·raw 역상,
JA0·원 source213 파일을 기존 pure validate_append로 확인했다.
실제 fresh pre-autoload Casino 소비자는 translation32/reentry2/restore2 PASS,
exact marker/exit0·stdout/Godot log fatal0이다. 화면·서체·입력·자연플레이는 아니다.
비저자 /root/glossary_preexport_review가 실제3파일·원receipt·새 로그를 읽고
source/UI 한정 마감 결함0으로 판단했다. 새 per-order 보고/이력 도구는 만들지 않는다.
EN/한글누출·context·diff PASS와 별개로 JA_UI·JA_DEMO_PIPELINE·JA_DEMO_AUDIT·
ZH_DEMO_AUDIT·DEMO_I18N_SCOPE는 실제 FAIL5다. 고정482 UI/원장 admission의
새 append 거부가 옛40767 기대값 fallback 또는 빈 stats KeyError로 이어졌다.
이를 PASS로 바꾸지 않으며 제품 검사 보존·복구와 전체CI 미녹색은 바로 다음
사용자 지정 검수 정리 오더로 이관한다. 원어민·인간·물리·본편출시 HOLD 유지.
모든 실행 지시는 일회성/새 규범0이며 자동 PASS는 재미·문체·인간 GO가 아니다.
