# ORDER-527 — 수리 앱의 실제 M02 재개·선택·M03 복귀

#### [x] ORDER-527 [P1·실제 진행] M02 저장에서 정상 이어하기로 다음 선택을 읽는다

**착수 — 2026-10-10 / 선언 뒤 실행.** [526](../queue_archive/ORDER-526.md)의
exact ICU 앱은 fresh M01→M02·첫 문단/설정5언어·중국어 줄갈이 개선만 GO다.
같은 앱의 실제 M02 controller 저장을 정상 Continue로 재개하고, KO 남은 본문/
선택·결과를 자연 완독→월 정산→M03 첫 문단까지 한 단위로 확인한다.
M02 마지막 본문의 단일행동 안내에서 EN 설정·닫기·같은 행동 복귀를 확인한 뒤
KO로 돌아와 Return으로 행동0을 확정한다. 예기치 않은 상태/결함이면 다음 달로
밀지 않는다. 제품 결함은 별도 수리하고 검수 전제 오류는 같은 단위에서 정정한다.
이미 통과한 M01 fresh·5언어 첫 문단·발급/검사기 자체검사를 반복하지 않는다.

**입구 화면 대기 — 2026-10-10.** 선언 문서 검사 중 기존 살아 있는 Godot 창의
native screenshot이 Mac locked/automatic unlock failed를 반환했다. 새 ICU 앱
launch/input/savecopy0·527 입구snapshot0이며 526 정상 완료 결과와 구별한다.
잠금 우회/자동해제 재시도0. 실제 재개는 미실행이며 소스/정본 준비만 읽기 검수한다.

**독립 준비 검수 — 2026-10-10.** phone_independent_review는 KO/EN
arc_temptation_clean 전량과 exact ICU stage 동일성을 직접 대조했다. authored 본문2/
선택1(index0)/결과2이며 실제 입력 수는 화면 분할을 따른다. 선택은 목/토 새벽 두
근무를 수락하며 즉시200만원 지급이 아니라 mental+10/clean_seen·stayed_clean이다.
Continue/locale복귀는 선택효과를 다시 적용하지 않고, 완료 뒤 controller의 월 guard가
정산을 한 번만 적용한다. 예정M3 경계는 elapsed8/closed[1,2]/pressure2/turn9/
선택2건이다. 실제 수치/월경제는 실행 뒤 저장과 대조한다. 준비 한정GO/실제GO0이다.

**실제 시도1·전제 정정 — 2026-10-10.** 화면 접근이 돌아와 정상 Continue로
M02 KO 본문2개를 자연 완독했다. 별도 Return2회째 결과1/정신72로 이동해 즉시
정상CmdQ했다. 선택dock은 없었다. StoryMode3335/5776은 한 행동을 마지막 본문의
Enter/클릭 안내로 직접 확정하며 DECISIONS2026-07-20과 정합하다. 제품 결함이나
입력 누출이 아니라 이 사양의 선택버튼 전제 오류다. EN복귀/결과2/정산/M03은 미실행,
원래 완료 판정은 REWORK다. durable 저장은 M2/정신62/선택1/정산1이며 30개 숫자의
int→float 재직렬화만 있었다(8421→8481B/ce380aa3…). 사라진 in-memory 결과 복원을
주장하지 않는다. 독립 전량 fresh 보존GO 뒤 동결을 해제했다.

- 시도1 raw7개 `.git/order527-live-20261010/`: before718692B/8cd7a64a…,
  after717956B/134fd6d4…, observation3698B/c9009276…. exit0/60.965706초,
  stdout=Godot472B/cccfb27a…·stderr/오류/경고/누수0. own55330/55329부재,
  editor61385생존. source3267/helper5/seed2/W238/player33·immutable54 전량 동일.
- **정정 재개 선언:** 같은527에서 `.git/order527-resume-20261010/`만 새 raw로 쓴다.
  앞54곳+시도1 raw7개를 immutable55로 봉인하며 mutable namespace는 현재6파일이다.
  정상 Continue로 durable M02 처음부터 다시 읽는 이유는 시도1 중단이다. 마지막
  본문 단일행동 안내 EN→KO복귀 후 Return확정→결과 완독→정산→M03첫문단만 확인한다.
  재발급/새checker/제품수리0이다. 실제 소비자의 단일행동 경로를 검수 전제로 삼는다.

## 깊이 3문

1. 이 확인이 없으면 중국어 데이터 수리 앱의 재개·다음 선택/월 복귀가 실제 미검수다.
2. 재개 자체는 효과를 더하지 않아야 하며 실제 M02 선택은 정본 결과를 한 번만 반영한다.
3. 자동상태 주입이 아니라 같은 실제 저장·무인자 앱·정상 입력으로 판정한다.

## 정확한 대상·소유

- package source25fc879d39a6593e244b3905d7782f22560676c2/tree
  de0898823de1cbb26ea9cfe7c5a7ccd0233b5e6a, BUILD2026.10.10.1/icu-break.
  [manifest 사본](../agent_reviews/ORDER-526-manifest.json)의SHA
  7a435023dbb662de53f02012242ffa04b106f0b56f86ab5ca6c5eab7bdf50072.
  기존 설치 앱/namespace는 manifest exact 값만 쓴다. 재발급/수정0이다.
- root 소유: 이 사양·CODEX_QUEUE·부모302·CLAUDE·WORK_LOG·생성STATUS·
  agent_review_decisions·WORK_LOG 정상예산 분리 history 원문 보존,
  private `.git/order527-live-20261010/`·`.git/order527-resume-20261010/` 원증거만.
  새checker/runner/오더별보고0, 기존 builder의 무인자 실행·snapshot만 재사용한다.
- 비저자 phone_independent_review: source/실제패키지·원로그·저장·보호 census 전량
  읽기 전용 독립 대조. rootpixels/독립 원산출 검수와 인간·원어민·물리는 구별한다.
- 제품코드/원고/번역·project/preset·공개본/옛앱·원저장·seed/W238·옛raw·
  과거 인간 판정은 불변이다. 같은 ICU runtime namespace만 정상 UI 쓰기를 허용한다.

## 실행·완료

1. 실행 입구~독립 final fresh 동안 source/docs/helper를 동결한다. source 전량/
   helper5/seed2/W238/player33, 기존54곳+시도1 raw7개를55곳으로 봉인한다.
   ICU namespace 현재6파일/선택1/정산1/M2를 입구로 읽어 둔다. 저장복사/주입0이다.
2. native 실제 screenshot preflight 접근 뒤 정확 executable을 무인자1회 실행한다.
   정상 Continue로 M02 첫 문단·이름표/HUD/수치 복원을 확인하고 남은 KO 문단은
   자연 완료 뒤 개별 입력한다. 마지막 본문 행동안내에서 EN→KO 설정복귀 후
   Return으로 행동0을 확정하고 결과를 자연 완독한다. 별도 선택dock을 요구하지 않는다.
3. 다음 정산 한 번·M03 첫 문단까지만 관찰하고 정상 CmdQ한다. AUTO/skip/연타/
   강제선택·수동save·공개/옛slot 복사0. 종료 뒤 AX를 다시 조회하지 않는다.
4. 원 stdout/stderr/Godot의 성공 신원/오류·경고·누수/exit와 실제 상태를 대조한다.
   보호 전체 before=after=fresh·own프로세스 부재/사용자editor생존·독립검수 뒤
   관측 범위만 GO한다. 다른 선택·크기·M03이후·인간/원어민/물리·청취/출시는 HOLD다.

## 완료 — 2026-10-10 / 정정 범위 한정 GO

- 정정 시도는 정상Continue1·Return4·설정2/EN→KO/닫기2·CmdQ1이다.
  M02 KO본문 각3줄·EN마지막4줄/행동안내·KO같은문단3줄이 완문으로 복귀했다.
  설정복귀 동안297만원/건강70/정신62 유지, 새Return만 결과1/정신72로 확정했다.
  결과1·2 각2줄 자연완독 뒤 한 번 정산해 M03첫문단1줄/+1/편의점CG로 자동 복귀했다.
  M03 CG에는 HUD/이름표가 없었으며 표시됐다고 주장하지 않는다. 추가M03입력0이다.
- 실제 save10529B/SHA d5afe7ab555c36e8c61713c46874efd0132bb811f86112c8792cfa32b1ed37e0:
  M3/elapsed8/closed[1,2]/pressure2/turn9/선택2·정산2/364만원·건강70·정신70.
  M2 신규선택0·정산 각1건, 기존M1 영수증 동일, 정산 현금297→364만원/정신72→70다.
  backup M3 transition→current M3 story는 월폐쇄 뒤 정상 자동진입과 맞는다.
- `.git/order527-resume-20261010/` raw7: before720298B/659b50cc…,
  after720651B/2944b4a7…, observation6045B/ce9c40ab…, command1470B/779749b4….
  OS1회/exit0/168.756498초/stdout=Godot790B/7dcba27f…·stderr/오류/경고/누수0.
  nativeentry en→ko2는 controller재진입이며 앱2회가 아니다. own65109/65108부재,
  editor61385생존. AUTO/skip/hold/수동save/복사/주입/재발급/새검사0이다.
- root와 비저자 phone_independent_review는 source7e1f45d8019fa8fdb87c7009fdcde2f9c8ff5a91/
  tree4b66368d8eab67785a853f96d8e67e7501862e0b의3267파일/helper5/seed2/W238/player33,
  immutable55곳 before=after=fresh·runtime허용7파일을 전량 대조했다. 독립자는
  _close_month690의 guard/저장실패rollback·실제 신규영수증을 읽고 한정GO/동결해제했다.
  첫시도REWORK 원증거는55번째 보호로 전량 보존했다. rootpixels/독립원산출검수이며
  PNG영속0·독립pixels0이다. 다른경로/크기·JAzh 이행동·M03이후·인간/원어민/물리/
  연속청취·전체302/본편/출시는HOLD, 원manifest NOT_RUN/옛 공개GO 불승계다.

일회성 실행 지시/정본승격0. 자동 계약 통과는 재미·깊이·전체 품질 GO가 아니다.
