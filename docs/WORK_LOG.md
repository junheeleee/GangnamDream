# WORK_LOG.md — 강남드림 작업 기록

이전 원문 전체는 [홀덤 비동기 수리 전 기록](history/WORK_LOG_2026-10-04_pre_order438.md)에 바이트 그대로 보존했다.

## 2026-10-04 — 중국어 홀덤 결과·패 이름 화면 검수 완료 (439)

- source9ffc90c를 main에 커밋·푸시했다. 간체/번체38값·공식19×2 receipt/raw 역상, 실제12PNG·24raw/12tap·정산4/Close4·추가rank reader14를 독립 검수했다. 승패 팟30,000과 실제 순익+20,000/−10,000을 구분해 읽을 수 있다.
- runtime49.006초, fresh8검증+조회1 normal405.352초 PASS. 6 fixture typed복원·player34 불변. [독립 보고](agent_reviews/ORDER-439.json), [일회성 사양](queue_archive/ORDER-439.md). scoped GO 후201판정/179보고이며 기존 인간OPEN45/공개GO1·본편/새package HOLD는 그대로다.
- 최초 공식check 실패는 보존했다. 준비형 RIVER/별도rank reader이지 자연 첫손·물리패드·원어민 관측이 아니다. 다음은 크림 카드에 밝은 무늬색을 쓴 확인된 가독성 결함부터 별도 선언한다. CLAUDE 갱신은 다음 선언에서 수행해 품질판정 metadata 마감과 분리한다.

## 2026-10-04 — 홀덤 승패·패순위 중국어 공식 수용 (439)

- CN19/TW19를 공식 import하고 원장에38값/2batch를 append했다. raw4파일 역상 PASS, accepted41694/b211·CN/TW1752·JA3044. 원래 source5bca6fd 헤더를 보존하고 검사수리 마감b8e118d를 통합 기준으로 구분했다.
- 실제 승/패4회·독립rank reader14·12PNG 검수 후보를 동결한다. 아직 화면·입력 PASS0, 원어민/인간/물리패드·본편/새package HOLD. helper 사전검수에서 normal 기준/집계2건을 수리했으며 게임 동작은 바꾸지 않았다.

## 2026-10-04 — 중국어 포커 패 이름 오탐 수리 완료 (440)

- source `f411887`을 main에 커밋·푸시했다. 정확한9개 패명만 지역/원문/UI주소에 결속해 숫자 비교용 rank로 처리하며 틀린 rank·지역문자·추가값을 거부한다. 기존 원문 검사는 유지한다.
- fresh9검증+조회1 PASS(33.469초), 신규801case·과거0. 최초439 실패를 보존한 채 원래 CN19/TW19 공식 check가 PASS했다. 게임/번역 수용/engine 변경0, accepted41656/b209·JA3044/CN/TW1733 유지.
- before=after tracked3060/원래439입력10/player34, 독립 재해시·코드검수 완료. [보고](agent_reviews/ORDER-440.json), [일회성 사양](queue_archive/ORDER-440.md). 이 검사 수리만 GO,200판정/178보고. 자동PASS는 품질·출시 GO가 아니며 실제화면/원어민/인간/물리패드·본편/새package HOLD를 보존한다. 다음은439 번역 수용과 실제 화면이다.

## 2026-10-04 — 정확한 중국어 패 이름 수량검사 오탐 수리 착수 (440)

- 439의 양지역19값은 독립 의미검수를 통과했지만 공식 check가 `트리플→三条/三條`를 새 수량3 발명으로 거부했다. 원래 export/response와 실패를 보존하고 수용은0이다. [별도 수리](queue_archive/ORDER-440.md)를 먼저 선언하며 숫자 없는 부정확한 동의어로 회피하지 않는다.
- 정확9 UI 주소·원문·지역 패명 전체 일치에만 numeric rank 계약을 붙이고 다른 모든 검사를 원문으로 유지한다. claude validator/root 신규focused/receipt scope/independent 검수로 분리한다. 게임·번역 사전·수용원장은 불변,439 runtime 저작은 겹치지 않는 파일에서 계속한다.

## 2026-10-04 — 홀덤 패·승패·정산 중국어 19키 착수 (439)

- [선언 사양](queue_archive/ORDER-439.md)의19키만 간체/번체 독립 저작한다. 기존JA19는 사전에 있어 재저작하지 않는다. 현재 accepted41656/b209·CN/TW1733·JA3044, 목표+38값/2batch다.
- root TW/공식교환/통합, claude CN, receipt 새 격리helper/명시차선, independent 비저자38값/실제소비자 검수로 파일 소유를 나눴다. 실제 승/패4회 및 별도14rank reader·12PNG·typed복원을 표적으로 삼는다. 아직 새 수용·runtime PASS0.
- 438 source3c242a5의 수리·표적검사·독립보고를 main에 정리했다. 다음은 확인된 영어fallback 결과 소비자를 고친다. 카드 저대비·직접 영문/규칙 collector 및 실제 인간/원어민/물리패드·본편HOLD는 유지한다.

## 2026-10-04 — 홀덤 연속 입력·퇴장 뒤 타이머의 실제 회귀 통과 (438)

- 제품 `aa21f0b`와 신규 검사 `3c242a5`를 main에 커밋·푸시했다. 실제 player 0.3초/AI 0.6초 창의 추가 Enter를 막고, RESULT·Close·재진입 뒤 옛 callback이 새 판을 바꾸지 않는 것을 확인했다.
- 같은 source3c242a5에서 KO 실제2PNG·26raw/13tap·첫손3·테이블행동3·정산2·Close1과 별도 prepared token1 PASS. 두 정산의 현금−10k/mental−5·Meta, 실제 Main 회수의 AP−1·행동/장소/로그 효과를 확인했다. 실제 플레이어 파일34개 불변.
- 첫 회귀는 Main이 AP 버튼을 재생성한 뒤 옛 absolute focus path로 복원하려다 FAIL했다. 실패138파일은 원문 보존하고, 새438 helper만 실제 Main 소유의 유일한 name/index/action/fn/pressure 일치 버튼을 찾아 복원하도록 고쳤다. 실제 raw 경로/ID 변화는 지우지 않았으며, 재실행 typed3그룹 복원 PASS다. 첫 FAIL을 PASS로 바꾸지 않았다.
- fresh10검증+차선조회1 PASS(389.657초), 신규 focused50·과거case0. accepted41656/b209·JA3044/CN/TW1733 불변. 434의 서사4종은 참조/NOT_RUN이며 완료 회귀·전체감사·240주·성능A/B 재실행0.
- 성공 runtime SHA `457e89d58cd2b5c8ff914fae59a297cde7c0a864e015540451b968f84017812c`, normal SHA `9cdd34c5ab12b25d478bfa2a72104395588ce40225ad003d7ff99949d28237c2`. [독립 최종 보고](agent_reviews/ORDER-438.json)로 source3c242a5·이 범위 GO, 199판정/177보고. 지시는 일회성이다. 저대비 카드·직접 영어/후속 번역·원어민/인간/물리패드·본편/새package HOLD는 그대로다. CLAUDE 현재 상태는 다음 선언에서 갱신해 품질 판정 metadata 마감과 분리한다.

## 2026-10-04 — 홀덤 중복 행동·이전 타이머 수리 착수 (438)

- 제품 단독 `aa21f0b`에서 transient busy·generation을 추가했다. 타이머가 같은 세대일 때만 다음 행동을 잇고, RESULT/close/open/새 손 경계는 이전 callback을 무효화한다. 기존61 UiCall 전체 tuple·행 좌표와 금액/승패 산식은 보존했다.
- history EOF4전이·24객체/19실제 manifest·신규 focused를 별도 저작했다. 기존 proof·focused·번역 원문은 그대로다. 새 실제 시간창 회귀와10검증+조회1의 실행·최종 판정은 아직 대기이며, 사전 소스 읽기와 AST 확인을 실제 PASS로 세지 않는다.
- 437 실제 trace와 소스에서 AI 끝 대기 중 조기 입력 및 퇴장/재진입 뒤 stale continuation을 확인했다. busy+generation으로 기존 선택의 단일 실행을 보존하며 정산 산식은 바꾸지 않는다.
- root 제품/append/normal, claude history/newfocused, receipt private runtime/scope, independent 비저자 검수로 분리한다. KO 두 실제 시간창과 정산/재진입·새 busy 경계를 표적으로 삼는다. 아직438실행/GO0.
- 437 sourcecb648d9는 독립GO·제품/검사/마감main push 완료. [보고](agent_reviews/ORDER-437.json), [사양](queue_archive/ORDER-437.md). 과거198판정176보고·player34·공개GO1·인간OPEN45·본편HOLD 보존.
- 부팅 문서 예산 때문에 긴 이전 WORK_LOG는 새 후보 선언에서 손실 없이 이동했다. 품질 판정만 담는 metadata 마감과 이 새 이력 이동을 분리했다.
