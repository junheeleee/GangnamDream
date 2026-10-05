# WORK_LOG.md — 강남드림 작업 기록

이전 원문 전체는 [검수 비용 계측 전 기록](history/WORK_LOG_2026-10-05_pre_order453.md)에 바이트 그대로 보존했다.

## 2026-10-05 — 보존된 5장 일반 경로의 정상 재플레이 착수 (457)

- 456을 `09683ec`로 마감·푸시하고 [457](queue_active/ORDER-457.md)을 선언한다. 준비 입력4건을 전체 독해로 확대하지 않고, 기존151/150/146 의무 중 General W193→M60·후일담·6/6 한 경로를 실제 메뉴와 개별 GUI 입력으로 읽는다.
- 현player에 없던 두 원본은 별도 게임 검수 namespace에 남아 있었다. General153088B/SHA5f4b5a0f…·Property155940B/SHA72390405…를151의 원본과 대조했다. 현재 사용자 슬롯에 복구하거나 원본metadata를 새 source로 덮지 않는다.
- 새 exact 후보·얇은 격리 실행기·원본/실제player 보존과 GUI 관찰을 분리한다. 자동 넘김/직접사건/주차주입·기존 suite 반복0, 아직 새경로 실행0이다.217판정195보고·인간/공개 이력·본편/새package HOLD를 유지한다.

## 2026-10-05 — 집밥·공원 휴식의 실제 키보드 전달 검수 완료 (456)

- 후보 `5d67f66`를 main에 커밋·푸시하고 첫 KO/EN4경로를 통과했다. 실제24raw/12tap·4pressed/receipt/PNG, 경계 버튼0이다. SAVE 실제50188원·mental−2와 REST mental+9·AP1→0·달력 불변 및 원본4화면의 본문/배경을 확인했다. 실행은 각각19.312/21.777초였다.
- 준비·초기화와 실제 입력 후 효과를 나눴고 입력22·실제player34가 전후 일치했다. 같은 clean 후보의 합성17/context/queue/diff/등록193·조회가 통과했다. 앞선 CLI lane+files usage 오류를 보존했고 엔진 실패는0이다.
- [독립 한정GO](agent_reviews/ORDER-456.json)와 [일회성 사양](queue_archive/ORDER-456.md)으로217판정195보고가 된다. 게임/원고/번역/기존 QA 변경0이며 기존32callback/302/365/전체감사/240주는 반복하지 않았다. 자동 PASS는 자연 플레이·인간/원어민/물리패드·156전체·출시 GO가 아니며 본편/새package HOLD를 유지한다.

## 2026-10-05 — 생활 장면 키보드 관찰 도구·합성 검수 준비 (456)

- 선언 `3acded4` 뒤 GD321줄/scene6줄과 실행기544줄을 분리 작성했다. 실제 root 입력 관측·방향키2/Enter1·버튼/경계 관찰과 입력 전 초기화/입력 후 효과를 나눠 기록한다. 게임·원고·번역·기존 QA 변경0이다.
- 작은 합성17검사가 통과했다. 실제 후보 고정 뒤 KO/EN 두 프로세스의 4경로/4PNG만 실행한다. 아직 엔진실행0이며 모든 실패 로그와 격리 namespace를 보존한다. 기존32callback/302/365/whole audit/240주는 실행하지 않는다.

## 2026-10-05 — 생활 장면 선택의 키보드 전달 검수 착수 (456)

- 홀덤 수리를 `8c7bad5`로 마감·푸시했다. 최신302 지시의 source 수리7개는 완료라 반복하지 않고,156의 `pressed.emit()` 결과 검사에 없는 실제 키보드 전달 공백을 [별도456](queue_archive/ORDER-456.md)으로 선언한다.
- 집밥 SAVE[0]/W230·공원 REST[5]/W216×KO/EN4경로만 대상으로 실제 초기focus→Right2→Enter, 단일 버튼/receipt·효과·결과4PNG·실제player34 보존을 확인한다. 준비된 legacy/internal 경로이며 자연 플레이나156/5장 전체 마감은 아니다. 새 제품/번역 변경0·검수 실행0이다.
- GD observer/실행기·scope/독립 검수를 파일별로 나눴다. 기존32callback·302·365·whole audit/240주는 반복하지 않는다.216판정194보고·인간/공개 이력·본편/새package HOLD를 보존한다.

## 2026-10-05 — 홀덤 한국어 승리 조사 수리·화면 검수 완료 (455)

- 후보 `3ede74c`를 main에 커밋·푸시하고 준비한 스트레이트/트리플에서 실제 승리 문구와 순이익+20,000원을 확인했다. 9족보 모두 `로`를 쓰며 기존 lookup·사전·지급·AI/RESULT는 그대로다. 새로운 번역 증량으로 세지 않는다.
- 격리 KO1 process·2PNG/8노드·9rank/비KO4순수분기·실제SHOWDOWN2·복원1 PASS(13.273초). 실제player34 불변, deal/베팅/AI/RESULT/Close/raw0이다. 이미지 두 장을 저자와 비저자가 직접 읽었고 자연 플레이·물리 패드 관찰은 아니다.
- focused61·실제365 기본617.686초와 EN/context/queue/diff/등록192·조회1이 모두 통과했다(전체628.584초). accepted41755/b228/live47·tracked3110/player34/helper5를 보존했다. [독립 한정GO](agent_reviews/ORDER-455.json)·[일회성 사양](queue_archive/ORDER-455.md)으로 마감해216판정194보고이며, 인간/공개 이력·본편/새package HOLD는 유지한다. 자동 PASS는 계약 증거이지 인간·원어민·물리패드·출시 GO가 아니다.

## 2026-10-05 — 홀덤 한국어 승리 표시 반영·표적 검수 준비 (455)

- 선언 `b768cf3` 뒤 제품 `a8fc6a3`을 main에 커밋·푸시했다. 기존1210행을 승리 전용 helper로 감싸고 EOF4행을 추가했다. 71 UiCall의 literal/행/identity는 유지하지만 감싼 호출의 열은 이동한다. 새 게임 규칙·지급·다국어 사전/원장 변경0이다.
- 새13단계 exact proof와 실제manifest 전이1개, 소스/합성 회귀 및 격리 KO1 process를 준비했다. KO9 getter문구·비KO4 template 순수분기와 준비한 합법 스트레이트/트리플 RIVER→실제승리2화면을 구분한다. 실제 deal/베팅/AI/RESULT/Close/raw입력0 계획이며 아직 실행 PASS0이다. 같은 clean 후보에서 focused와 정상365 기본1회, EN·기본가드만 실행한다.
- 저작/비저자 소스 읽기를 병렬로 진행했다. 기존215판정193보고·인간/공개 이력·본편/새package HOLD를 보존하며, 자동 PASS를 인간·원어민·물리패드·출시 GO로 바꾸지 않는다.

## 2026-10-05 — 홀덤 한국어 승리 조사 수리 착수 (455)

- 고정원장 최적화를 `b346586`으로 마감·푸시하고 [별도455](queue_archive/ORDER-455.md)를 선언한다. 9족보가 모두 `로`를 요구하는데 현재 `%s으로`를 일괄 붙이는 표시 결함이다. 기존 lookup literal을 보존한 승리 전용 KO helper는 세 다국어 fallback/수용 재발급을 피하면서 잘못된 한국어 출력만 고친다.
- root 제품, claude exact proof/새focused, receipt 격리 KO9문구/승리2화면·복원/scope, 비저자 최종검토로 소유를 분리했다. 새 제품/실행0이며 수용41755/b228·215판정193보고·인간/공개 이력·본편/새package HOLD를 보존한다.

## 2026-10-05 — 반복 원장 파싱 최적화·동등성 검수 완료 (454)

- 후보 `457c937`를 main에 커밋·푸시하고 focused181/19.707초 및 실제365 기본610.898초를 통과했다. context/queue/diff/등록191·조회1 포함 전체631.567초, accepted41755/b228/live47·historical0 출력이 기존453과 정확히 같다. 번역/게임 수리로 세지 않는다.
- 실제 고정 blob쌍 두 개에서 각 cold1+warm2 원장파싱5회(준비2+동적3)를 관측했다. 직접 API의 실측2회×3=기존6회는 산술 비교이며 과거 전체검사를 재실행한 값이 아니다. UI12회는 유지했다. 이전 계측709.311초와 현재610.898초는 조건이 달라 정밀 A/B·확정 개선율이 아니다.
- 원문 oracle·단일 결함·비소유 checksum 경계·새 호출/실패 후 복구·불변 투영과 중첩 context 복원을 검수했다. tracked3107/player34/helper1·과거증거216파일 불변, [독립 한정GO](agent_reviews/ORDER-454.json)·[일회성 사양](queue_archive/ORDER-454.md)으로 마감하며215판정193보고가 된다. 인간/공개 이력·본편/새package HOLD를 유지한다. 자동 PASS는 계약 증거이지 원어민·인간·물리패드·출시 GO가 아니다.

## 2026-10-05 — 두 고정 원장 재사용 구현·동등성 검수 준비 (454)

- 선언 `d463609` 뒤 초기 두 비교와 proof/계보 확인 뒤 바인딩만 변경했다. 호출지역 불변투영은 원시 토큰·배치 구분자·ordered receipt를 보관하며 전체 Document 그래프나 검증 결과는 저장하지 않는다. 동적 snapshot·UI 파싱·기존 결과 memo·Git/proof/HEAD·현재 전체 checksum은 유지했다.
- 봉인453 두 함수 oracle·실제12개 Git blob·합성 결함/후속append·복구/격리·cold 준비비용과 warm 파싱 수를 확인할 focused 및 전용차선을 작성했다. root와 비저자 읽기 뒤 clean 후보에서 표적검사→실제365 기본1회로 진행한다. 아직 새 실행 PASS0이며 기존 게임/번역/원장·214판정192보고·인간/공개 이력·본편/새package HOLD를 보존한다.

## 2026-10-05 — 두 고정 원장 토큰 재사용 착수 (454)

- 계측 작업을 main `7d6771e`로 마감·푸시했다. [별도454](queue_archive/ORDER-454.md)는 관측된130.446초의 두 고정원장 파싱만 대상으로 한다. 고정 UI296회/2.579초와 나머지 비교·검증은 유지한다. 전체 Document 캐시/검증 생략/게임·번역 변경은 하지 않는다.
- append 저작, 새focused/scope 저작, 비저자 검수와 root실행을 분리한다. 실제 blob/oracle 동등성·합성 결함·반복 파싱 생성 수와 새 정상 admission으로 검수하며453 profiler의 옛 source pin은 바꾸지 않는다. 아직 구현/새검수0, 기존214/192·인간/공개 이력·본편/새package HOLD다.
- 읽기에서 기존 memo standalone의 옛428 전체파일/EOF 봉인이 후속430~452와 이미 맞지 않음을 확인했다. 기존 검사를 바꾸거나 알려진 역사조건 실패를 다시 돌리지 않고, 관련 `synthetic_history`/`uncached_factory` 회귀만 새 focused가 명시적으로 소비하도록 실행계획을 좁혔다. 이 조정은 실제 검사 실패 뒤의 완화가 아니며 실행 전 읽기 진단이다.

## 2026-10-05 — 검수 비용 계측 완료·다음 최적화 범위 확정 (453)

- 후보 `d6d7fc5`를 main에 커밋·푸시하고 최초 계측1회와 합성13검사·context/queue/diff/등록190·조회1을 통과했다. 실제365 main708.010초/전체709.903초, accepted41755/b228/live47·과거case0이며 기존 게임·번역·검사 구현 변경0이다.
- append Document1118회/349.435초 중 고정자료560회/186.928초를 확인했다. 초기두교정 고정자료444회/133.025초(실제 main18.79%) 중 원장148회가130.446초이므로 후속은 두 고정원장의 경량 불변토큰 재사용으로 좁힌다. UI쪽296회/2.579초는 그대로 두며 속도 개선은 아직 미구현·미입증이다. 중첩 포함시간을 합산하거나 미귀속 시간을 Git 비용으로 단정하지 않는다.
- tracked3104·실제player34·이전452증거201 불변, 원 callable/argv 복원과 오류0을 확인했다. [비저자 한정GO](agent_reviews/ORDER-453.json)·[일회성 사양](queue_archive/ORDER-453.md)으로 마감하며 기존213판정191보고 뒤214/192가 된다. 인간OPEN45/DONE1·공개GO1·본편/새package HOLD를 유지한다. 자동 PASS는 계약 증거이며 원어민·인간·물리패드·출시 GO가 아니다.

## 2026-10-05 — 검수 비용 계측 도구·합성 회귀 준비 (453)

- 선언 `e3f3935` 뒤 새profiler430행과 합성13검사를 파일별로 나눠 작성했다. 원 검사 호출·반환·예외를 유지하고 호출 위치/순번별 JSON 비용을 기록한다. 기록 실패가 원 예외를 덮는 경계도 수리했으며 기존 게임·번역·검사 구현은 변경0이다.
- 저자/비저자 읽기와 AST 확인 뒤 clean 후보로 고정한다. 실제 검수는 새focused를 먼저 통과한 경우에만 계측된365 기본1회와 context/queue/diff/등록·조회로 진행한다. 아직 실제 계측 PASS0이며 속도 개선·원어민·인간·출시 GO를 주장하지 않는다.

## 2026-10-05 — 검수 속도 개선을 위한 실제 비용 계측 착수 (453)

- 홀덤 순손익 수리를 `2f8a5c2`로 마감·푸시하고 clean wrapper 현황을 `27f3f12`로 갱신했다. 다음은 [별도453](queue_archive/ORDER-453.md) 측정1배치다. 새 CLI/focused/scope만 추가하고 기존 게임/번역/원장/parser/검사 구현은 바꾸지 않는다.
- 사양에 저작/검수 파일 소유를 나눴다. 실제365 main1회·반환/예외/복구·site별 시간·peak RSS를 측정한다. 아직 구현/실행0이며723.222초의 병목 귀속·최적화/A-B는 미확인이다. 기존213판정191보고·인간/공개 이력·본편/새package HOLD를 보존한다.

## 2026-10-05 — 홀덤 한 판 손익·두 판 최종 정산 확인 완료 (452)

- 검수 후보 `1bfc7b9`를 main에 커밋·푸시했다. 이제 팟30,000원과 내 순손익을 구분한다. 실제 시작/블라인드2회 뒤 준비 RIVER2개를 실제 SHOWDOWN으로 진행해 승+20,000원·패−10,000원, 최종+10,000원/cash5,010,000을 확인했다. 지급 규칙 자체는 바꾸지 않았다.
- 실제3PNG·11표적 노드와 typed/RNG/새int/Meta/semantic focus 복원1 PASS(16.312초), 실제player34 불변이다. 중복 RESULT1회 무효와 신호1회도 확인했으며 raw/tap·베팅·AI·Close0, 자연 플레이나 물리 패드 관측은 아니다.
- 같은 clean 후보에서7검증+조회1 PASS(726.422초): focused42/과거0·receipt723.222초·EN/context/queue/diff/등록189. accepted41755/b228·사전3053/1776/1776을 보존했고 공식 교환0이다. [독립 한정GO](agent_reviews/ORDER-452.json)·[일회성 사양](queue_archive/ORDER-452.md)으로 닫으며213판정191보고가 된다. 기존 이력·인간OPEN45/DONE1·공개GO1·본편/새package HOLD를 유지한다. 자동 PASS는 계약 증거이지 재미·깊이·문체·사람 관찰·출시 GO가 아니다.
- 검수 읽기 진단에서 고정 교정 JSON의 반복 파싱과 manifest별 반복 source proof를 확인했다. 시간 기여율은 아직 미계측이다. full Document 캐시는 메모리 위험이 있어 적용하지 않았으며, 표적 계측과 불변 토큰 재사용 검토를 별도 후속으로 남긴다.

## 2026-10-05 — 홀덤 순손익 제품 반영·표적 검수 준비 (452)

- 선언 `1a31721` 뒤 제품 `ffc99a1`을 main에 커밋·푸시했다. 변경은49/355/1207/1210/1218 정확5줄이며 손별 블라인드 전 stack과 지급 후 stack 차이를 summary/history·승리 메시지에 연결했다. 실제 지급·RESULT·71 UiCall/행수·다국어 사전/원장은 그대로다.
- 독립 소스 읽기 및 KO두손/3PNG·typed/RNG/Meta/semantic focus 복원 helper와 새focused를 병렬 준비한다. 아직 엔진·새 정상검수·최종GO는 미실행이다. 기존212판정190보고·인간/공개 이력·본편/새package HOLD를 보존한다.

## 2026-10-05 — 홀덤 순손익 표시 수리 착수 (452)

- [별도452](queue_archive/ORDER-452.md)는 손 시작 stack을 캡처하고 SHOWDOWN/history.net·승리 메시지의 숫자만 실제 잔액 차이로 바꾸는5줄 수리다. gross POT 상세·지급/승자/AI·RESULT 실제현금·71 UiCall·사전/원장은 유지한다. 아직 새 제품·검수 PASS0이다.
- root 제품/normal, claude exact12번째 proof/새focused, receipt private KO두손/3PNG·전체 복원/scope, independent 최종검수로 나눈다. 승→다음손 패→RESULT+중복가드 한 세션으로 손별 기준과 street reset을 함께 검수하며 과거 다국어/베팅 suite·whole audit는 반복하지 않는다.
- 451을 `7e9b03d`로 마감·푸시했고 clean wrapper 현황을 `07da271`로 갱신해 DASHBOARD_FRESH를 확인했다. accepted41755/b228·212판정190보고·인간/공개 이력·본편/새package HOLD를 보존한다.

## 2026-10-05 — 폴드·일본어 정산/판돈 선택 표시 수리 완료 (451)

- 검수 후보 `f17579c`를 main에 커밋·푸시했다. 일본어·간체·번체의 폴드 상태와 JA 정산/단타 판돈 선택을 올바르게 읽는다. 새 키0·정정2·첫receipt2·batch1, accepted41755/b228·사전3053/1776/1776이다.
- 실제4PNG·13표적 노드·복원4 PASS(30.940초). 원본4장을 저자/비저자가 직접 읽었고 raw/딜/AI/실제정산/Close0·player34 불변이다. fresh8검증+조회1 PASS(687.894초), focused64/과거0·등록188. 원장 검사는686.527초이며 실행 중5초 OS passive sample은 병목 확정이나 성능 A/B가 아니다.
- [독립 한정 GO](agent_reviews/ORDER-451.json)·[일회성 사양](queue_archive/ORDER-451.md)으로 닫는다. 기존211판정189보고 보존 후212/190이며 root의raw 체크섬 오기/전진수리·원449 REWORK·인간OPEN45/DONE1·공개GO1·본편/새package HOLD를 보존한다. 자동 PASS는 계약 증거이지 재미·깊이·문체·사람 관찰·출시 GO가 아니다.
- 다음 별도 수리 후보는 SHOWDOWN이 내 순손익 대신 ±전체팟을 표시하는 결함이다. 읽기 진단상 100k 시작/내출자10k/팟30k에서 승리+30k→실제+20k, 패배−30k→실제−10k다. RESULT의 실제현금 계산은 별도이며 이 범위에서 변경/재검수하지 않았다.

## 2026-10-03 (Claude — 2장 수첩·5장 "5년" 적용 대기 초안)

- Codex가 PR #31 들이기를 하는 동안 충돌을 피하려고 콘텐츠·원장을 건드리지 않고 문서 초안만 썼다: [PROSE_DRAFT_CH2_CH5_2026-10-03.md](queue_backlog/PROSE_DRAFT_CH2_CH5_2026-10-03.md).
- `arc_year_one_mark`는 공책 두 칸 대신 거래내역 출력지 입금 줄 옆에 이름을 적는 일로, `arc_year2_close`는 배경(눈 내린 주택가 골목)과 어긋난 "책상 위 수첩 세 칸"을 가로등 아래 은행 명세표 뒷면으로 바꿨다. CH2 지시서 51·104행의 끝 논설 삭제도 같은 초안에 넣었다.
- 5장 "5년"은 숫자 대신 고시원·편의점 카운터를 가리키게 했다. 추가로 `hyunsu_year5_call` 첫 줄 "막판이었다. 강남까지 정말 얼마 안 남았다."가 자산 조건 없이 뜨는 사실 결함을 찾아 초안에 넣었다.
- 적용(KO/EN·JA/zh 공식 경로·원장·등급 지문·검사)은 Codex가 들이기 뒤 한 배치로 한다. 검사는 문서 검사만 돌렸다.

## 2026-10-01 (Claude — Codex 부재 중 직접 수리 3배치)

- 사용자 지시("너 스스로 판단하고 개선해야해")로 지시서 항목을 직접 고쳤다. 배치마다 KO/EN → JA·zh 공식 export/check/import → 영수증 → 심의 지문·보고서 → 검사.
- **엔딩 사실(`3643da2b`):** `empty_house`는 살아 있지만 화해하지 않은 아버지 런에서도 열린다. 그래서 기본 본문을 생존 기준으로 바꾸고 사망 문장은 `father_passed` 변형으로 옮겼다. 아버지가 살아 있으면 사망 전제 변형을 건너뛴다(MainGame 6줄). 그 밖에 E3~E11·E13(고시원 고정, 액수, 편의점, 6년, 미뤘던 전화, 부부 존대, 하드코딩)을 고쳤다.
- **4·5장 표기(`65be1dee`):** 청혼 체인의 고정 시점 "5년" 표현, 예식 전 "아내/처가", 연인 확정 뒤 지연의 존대, 연애·공시 기간을 고쳤다. 5장 F1은 판독 오류로 정정했다. 등급 축 sexuality·fear 지문은 연도·호칭만 바뀌어 강도 변화 없이 갱신했다.
- **엔딩 교훈 삭제(이번):** 10엔딩 52문단의 주제문·교훈 줄을 지웠다("더럽게", "충분한 밤", "30억으로도 못 사는" 등). 번역도 같은 줄만 지웠고 언어별 삭제 줄 수가 일치한다.
- **검사:** ending_distinctness·en/i18n·english_hangul·speech_register·multilingual·peak·audit·chapter4/5 경로·release_content_inventory·diff-check PASS. 이 환경에 Godot가 없어 컴파일은 CI가 본다. `zh_translation_audit` KeyError·수용원장 `ui:%d년 차`·`story_graph_contract_audit`의 MainGame 원문 승인(ORDER-390)은 수리 전 브랜치에서도, `ci_localization_reconciliation_self_test`·`chapter5_human_reject_audit`는 main에서도 실패한다. Codex가 들일 때 ORDER-390 승인 이력을 이번 MainGame 6줄과 함께 갱신해야 한다.
- **5장 정점·4장 내부어:** `arc_pre_ending_father_call`의 해설 꼬리 두 곳을 지웠다(대사는 보존). `arc_pre_ending_winter`는 현재형을 과거형으로 바꾸고 교훈 세 줄과 "갚아낸 빚"을 지웠다. `arc_year_three_half`의 계약어와 손상 폴백의 "배타 영수증"은 젖어 번진 메모라는 장면으로 바꿨다. 등급 fear 축 지문을 갱신했다.
- **5장 판정·예고(배치5):** `arc_daeun_final_choice`의 서술자 판정과 현재형, `arc_late_game_push`·`arc_37_ending_peace`의 선택지 예고와 생사 추상어, `arc_minseo_03_arrival`의 계약어("자기 쪽 기록으로만", "반응을 빌리지 않고"), `arc_minseo_03b_not_arrived`의 교훈 두 줄과 "민준" 하드코딩(F10)을 고쳤다. 원격 민서의 무읽음·무답장 사실은 보존했다.
- **4장 계약어(배치6):** `arc_y4_borrowed_name` 3변형의 선택 예고·결산문, `arc_y4_bill_night`·`_unattached`의 다은 대사와 계약어, `arc_y4_year_close_daeun`·`_unattached`의 결산문을 19잎×5언어로 고쳤다. 줄어든 `_document_gap`·`bill_night_unattached`가 `narrative_continuity`의 고립 소장면(420자 이하)에 걸려, 해설을 되살리지 않고 손가락·물컵 같은 감각 묘사로 보강해 통과시켰다. 지연 변형 6개는 F12 판정 대기로 건드리지 않았다.
- **데모 계약 회귀 복구:** 배치1에서 고친 `arc_hyunsu_lifeline_call`("공시 4년 만에")은 `min_turn 9999`라 제품에서 나오지 않는데, 출시 데모가 원문 바이트를 고정한 `arc_events.json` 안에 있어 CI의 데모 현지화 검사 4개(JA_DEMO_INVENTORY·JA_DEMO_AUDIT·DEMO_I18N_SCOPE·_SELF_TEST)를 깼다. 5언어 파일과 영수증 18건을 기준 커밋 `89cb4450`으로 되돌렸다. 앞으로 `arc_events.json`은 건드리지 않는다.
- **4장 계약어·5장 도덕 판정(배치7):** `arc_y4_three_promises`·`_deal_only`, `arc_36_unexpected_hand` 3변형, `arc_y4_body_witness`·`_hyunsu`, `arc_y4_family_*` 비지연 3장면, `arc_year4_close`의 설계 규칙 문장("없는 연인이나 친구의 이름으로", "누구의 반응도 발명되지 않았다", "이 경로에는 파트너를")과 선택 예고를 32잎×5언어로 걷었다. `arc_daeun_the_test`는 "임상철이 됐다"·"발걸음은 가벼웠다"를 지우고, 다은이 첫 장에서 손을 멈췄다가 "괜찮다고 했잖아요"라며 읽지 않기로 하는 장면과 지하철 유리창에 비친 익숙한 웃음으로 바꿨다(4장 F6). 420자 아래로 준 세 장면은 감각 묘사로 보강했다. 등급 축 alcohol("복용표" 토큰) 지문만 갱신했다.
- **얇은 엔딩 재작성(배치8):** `full_circle`·`guardian`·`second_love`·`crypto_ghost`·`writer`의 기본 본문을 지시서 권고대로 다시 썼다(변형은 같은 꼬리 문단을 유지, 11잎×5언어). full_circle은 꺼지는 텔레비전과 공장 기름 밴 손, guardian은 지난 삶에서 들지 못한 짐 가방, second_love는 교훈 줄 대신 설탕 뺀 머그잔과 김 서린 유리, crypto_ghost는 새로고침하는 엄지와 식은 국, writer는 경로 고정 사건 목록과 판매 기록 대신 새벽 3시의 첫 문장으로 바꿨다. 작은따옴표 대사는 큰따옴표로 바꿨다. 라우팅·조건·DIK 키는 그대로이고 엔딩 corpus 지문만 갱신했다.
- **장면 음악 회귀 복구:** 배치7이 `arc_year4_close`의 `arc_y4_midpoint_receipt_seen` 변형을 두 문단으로 줄여, 셋째 문단에 걸린 음악 신호가 사라졌다(CI `SCENE_AUDIO`). 해설을 되살리지 않고 뭉개진 볼펜 자국을 짚는 문단을 넣어 세 문단으로 복구했다(5언어). 앞으로 문단을 지울 때 `scene_audio_contract_check`를 함께 돌린다.
- **4·5장 사실 결함(배치9):** 4장 F9(결혼 견적 결과문 "3천만원이 넘는 돈", 차감 수치 불변)·F10(`arc_y4_father_crisis_stabilized` "민준"→`{name}`)·F11("새벽 12시"→"자정"), 5장 F3(`arc_father_legacy` 선택1 "소리 내어 말했다")·F4("했어요"→"보세요")·F7(`arc_jiyeon_year5_return` 선택 문구를 결과와 일치, "부산 2년")을 5언어에 반영했다(10잎). 5장 F9(`arc_daeun_later_echo`)는 데모 고정 파일 `arc_events.json` 안이라 건너뛰었다. `arc_father_legacy` 본문·회상 3잎은 이번 변경 전부터 수용원장 source 지문이 어긋나 있어(보류 커밋 계열로 추정) 손대지 않았다. CI 실패 목록은 기존과 같다.
- **2·3장 사실 결함(배치10):** 3장 F1(재혁 "군대 선임"→"동기")·F2(현수 공시 "4년"→"여섯 해가 넘는 시험", 제목 포함)·F3(다은 연애 기간 "2년이 넘었다"→"몇 계절", 동거 서술은 ROMANCE 대조 필요로 남김)·F4(지연 첫 만남 "상철의 소개"→"빗길의 사고")·F5(상철을 만나는 곳 "같은 카페"→"같은 사무실, 같은 책상"), 2장 F2("편의점 밖에서 보는 다은"→"약속을 잡고 만나는")·F3("남은 4년"→"남은 시간", 밤의 장소를 편의점 휴게 의자로)를 12잎×5언어에 반영했다. 2장 F1(P0, `arc_jaehyuk_aftermath` 선택지의 `[crossed_line 경로]` 같은 경로명 노출)과 F4(`arc_jiyeon_03_offer`)는 데모 고정 파일 `arc_events.json` 안이라 손대지 못했다. 엄격해진 검증기에 맞춰 zh의 "两个不同的世界"(원문에 없는 수량), JA "三年目"(원문 3년째)도 고쳤다. 등급 sexuality·fear·alcohol 축 지문만 갱신했다(강도 불변).
- **1장(배치11):** F6(`arc_goshiwon_goodbye` 변형의 "30개월"→"고시원의 요령")만 5언어에 반영했다. F1·F3·F4·F7은 데모 고정 파일 `arc_events.json` 안이다. F2(KTX 회상이 `told_dad_okay` 경로의 실제 대사와 다름)는 회상 변형 추가가 노출 상태 계약(`exposed_event_state_contracts`)과 번역 장부 배치 구조를 함께 건드려 Codex 몫으로 남겼다. F5(도달 불가 변형)는 삭제 판정이 필요하다. 등급 sexuality 축 지문만 갱신했다.
- **사용자 판정 3건("권고 3건 진행해"):** DECISIONS 2026-10-01에 기록했다. `instant_legend`의 개발자 목소리 문장은 5언어에서 지웠다(엔딩 corpus 지문 갱신). 지연 변형 author_only 전환과 `later_echo` 선택 조건은 각각 검사 도구 승격 목록·lifecycle 원장·코드 분기와 데모 고정 파일 계약을 함께 바꿔야 해 Codex 복귀 계획 7k로 넘겼다.
- **3장 도덕 해설(사용자 "응"):** `arc_y3_cost_of_knowing`의 선택지 나열·"출처가 깨끗해지는 것은 아니었다", `arc_y3_sangchul_deeper_room`의 자기 승인 문장을 지우고, `arc_35_orthodox_weight`·`_unorthodox_weight`를 분류어("정석의 무게")와 격언 없이 적금 자동이체 알림·새벽 3시 7분의 매도 버튼으로 다시 썼다. 하드코딩 "민준/Minjun" 2곳도 `{name}`으로 바꿨다. 9잎×5언어. 비정석 장면에서 "불안"이 빠져 등급 fear·violence 후보에서 빠졌으므로(사실 항목 참조 없음, violence는 원래 검색 잡음) 두 축의 수·목록 지문과 gambling·sexuality 지문을 갱신했다. `arc_jaehyuk_04b_counter`는 데모 고정 파일이라 7k에 넣었다. CI 대조 실패 집합은 기존 29개 그대로다.
- **남김:** 4장 `_person_deal`은 2026-10-03 사용자 위임으로 판정했다(DECISIONS 2026-10-03: 합치지 않고 다은 경로 DIK·야간 진료 기본 본문·중립 선택문). 구현은 지연 변형·`later_echo`와 함께 Codex 7k다.
