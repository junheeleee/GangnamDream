# ORDER-525 — 같은 데모의 M02 첫 문단·설정 5언어 실제 표면

#### [x] ORDER-525 [P1·실제 화면] 다음 달 장면의 5언어 표시·설정 복귀

**완료 — 2026-10-10 / 첫 문단·설정 복귀 기능 한정 GO.** root CUA 실제 픽셀과
비저자 `phone_independent_review`의 원로그/소스/저장/전체 보존 직접 검수를 구분한다.
독립 픽셀·인간·원어민·전체 가독성·출시 GO가 아니다.

## 재시도 결과·한계

- metadata clean d55cbbae5588ebb813738197e84f1d25c02725a4/tree4740cd3d…에서
  아래 exact522 앱을 무인자로 재실행했다. 실제 KO Continue→M02
  `arc_temptation_clean` 첫 authored 문단 자연 완료→Settings EN/JA/CN/TW/KO
  각각 변경·닫기를 확인했다. 다음 문단/Return/선택/AUTO/skip/새수동저장0이다.
- 기본 창1280×864(제목줄 포함), 첫 문단 KO3/EN4/JA3/CN3/TW3 시각 줄이다.
  title/HUD/nameplate/본문/Settings가 표시되고 닫기마다 같은 장면·첫 문단이다.
  누락 자형·잘림·의도하지 않은 한글 누출은 관측0이며 우하단 진행안내는 작고
  어둡게 보였다. EN 현금3.0million은297만원 반올림 표시다. 기본 글자/보통속도/
  음악25·효과음80·진동ON70·동작감소OFF를 보존하고 언어는KO로 복귀했다.
- CN/TW 첫 줄은 `Kim`, 다음 줄은 `Minjun`으로 시작해 첫 줄의 여백이 크다.
  완문은3줄에 들어가나 가독성 잔여다. 비저자 확인상 원문 내부개행0/토큰각1,
  강제개행0이므로 자동 줄갈이/서체 경계 가능성만 남기며 원인은 미확정이다.
  이를 수리나 완전 가독성 GO로 세지 않고 [526](../queue_active/ORDER-526.md)에서 분리한다.
- own84674/parent84673 정상CmdQ exit0/278.289238초, 정확 native entry1(en),
  stdout=Godot480B/SHA204c7320dfe88db9de17645509c019b098916d92d32c014bc9130e48642e96b9,
  stderr/오류/경고/누수0이다. 종료 후AX 재조회0·두PID부재/editor61385생존이다.
- controller8453→8481B/SHAc2af8be3d10a3db0733634850fb3c23d687f88cb0922f69075d40e7a928e67e3:
  M2/story/4weeks/closed[1]/settlement1/choice1/pressure1/turn5·2970000/70/62 유지다.
  backup=이전8453B/aa41ee32…이며 JSON값 전체 동일·추가효과0이다. 바이트28 차이는
  int→float14곳(상위/주거5+settlement9) 직렬화다. root 첫5곳 집계는 배열 내부9곳을
  빠뜨렸으며 비저자 전량 대조로 정정했다. 원slot19417B/e4978df6…·settings/meta byteexact다.
- private `.git/order525-live-retry-20261010/` 원산출11개를 보존했다.
  before697120B/d5bf73bf…→after697332B/SHA
  3afcb290b662a0d30ab5a2e587695687d7ce149eea560f32591c9f14280eadfa,
  observation3353B/SHAa529a54b77a6487dc2551b73d927addf6ec36a9f999eec3f4e63842589b00f8a,
  command1362B/SHAf3a5dfd44db3fc4381e39105660b8f30f42c793028ee227ec5fd0acb896c2153다.
  root+비저자 fresh에서 before.source=after.source=current·tracked3263/helper5/
  seed2/W238/player33 전량 동일, 보호44중43불변/index40 ns9→10파일만 허용했다.
  로그0→480/새회전0B·controller/backup만 변했고 이전 실패raw8개도 불변이다.
- 독립 final fresh 뒤 문서 동결을 해제했다. 기존 도구 재사용·새checker/runner/보고0,
  지시·규범은 일회성/기존 WORK_UNIT 적용·정본 승격0이다. 이후 문단/선택·다른장면/
  크기·큰글자·옛공개저장/인간·원어민·물리·청취/본편·출시 HOLD와 원manifest
  runtime NOT_RUN/userGO NOT_INHERITED를 보존한다. 이전 실패는 아래 그대로다.

**착수 — 2026-10-10.** [524](../queue_archive/ORDER-524.md)의 실제 M02 ingress를
잇는다. 완료한 M01 저장·재개·결과 진행·정산을 반복하거나 새 앱을 발급하지 않는다.

**입구 대기 — 2026-10-10.** 선언2e927d7 main push 뒤 CUA native inventory가
Mac locked/automatic unlock failed를 반환했다. 앱 실행/입력/새저장/입구 snapshot0이다.
524 정상종료 상태를 보존하고 화면 접근 뒤 이 범위부터 잇는다. 실제 GO는 없다.

**첫 시도 중단 — 2026-10-10.** native inventory는 접근됐으나 무인자 own76110/
parent76109 실행 직후 getApp이 다시 Mac locked를 반환했다. 화면/게임입력/새저장0,
검증한 own group만 SIGTERM으로 종료했다. exit−15/26.664948초이며 정상CmdQ가
아니다. stdout/stderr/Godot 각0B·entry0으로 실제 부팅 GO나 제품 실패를 추론하지
않는다. `.git/order525-live-20261010/` 원산출8개는 실패 증거로 보존한다.

root+phone_independent_review 직접 fresh에서 before.source=after.source=fresh,
clean c9bfae1d/tree1abff6f1·tracked3263/helper5/seed2/W238/player33 동일이다.
43곳 중42불변, index40 namespace만 log806→0B와 동일806B/0192f57b… 회전1개다.
원slot19417B/e4978df6…·controller/backup/settings/meta byteexact, own/parent 부재·
editor61385 생존이다. after695394B/17975d2d…·observation1993B/a7f98f32…·
command1347B/abd9f572…를 독립 대조했다. 동결은 이 fresh 뒤 해제하며 실제5언어는
HOLD다. inventory 성공은 이후 화면 접근을 보장하지 않으므로 실패 시 입력을 보내지 않는다.

읽기 준비: 비저자가5언어 title/첫 authored 문단·{name} 각1·문단 경계와 Settings/
HUD/이름표 consumer를 직접 확인했다. 관련13파일은 현재=exact522 stage이며 새 확정
결함0이다. JA4:20 시작시각 의심은 선행 출근 지시/EN loading shift까지 대조한 뒤
확정 오역 판단을 철회하고 시간 수식의 미확정 해석 위험으로 남긴다. 수정0이며
자형/줄바꿈/잘림/실제 모달 복귀·원어민 품질을 확인한 것은 아니다.

## 한 단위·깊이 3문

1. 없으면 준비된 번역이 실제 다음 달 HUD/이름표/본문/설정에서 읽히는지 모른다.
2. 선택·효과·월은 바꾸지 않고 같은 M02 첫 원문 문단을 5언어에서 비교한다.
3. 자동 fixture/이미지 대신 실제 언어 설정→닫기→동일 문단 복귀를 쓴다.

## 범위·소유·보존

- exact522 source a2008f3d77ad21f007787908b048d81da698e779/tree503ac425151b67117eb441ff2a3313be860d1ced,
  BUILD2026.10.10.1/nameplate-fix/manifest949b86d8… 앱·namespace를 그대로 쓴다.
- root: 실제 CUA/기존 b.run_command·b.snapshot·c.snapshot 일회성 조합,
  private `.git/order525-live-20261010/` 및 별도 `order525-live-retry-20261010/`
  원로그/전후/관찰, 이 사양/302/큐·CLAUDE/
  WORK_LOG/생성STATUS/위임원장만. 새checker/runner/오더별보고0이다.
- 비저자 phone_independent_review: 원로그/실제 저장/5언어 source consumer와
  보존 읽기 전용. root 픽셀 관찰을 직접 픽셀/인간/원어민 관찰로 바꾸지 않는다.
- 입구~final fresh 독립 대조까지 source/docs/helper 동결. 524 after42곳+524raw1=43곳
  중 index40 동일 후보namespace만 UI 쓰기를 허용하고 나머지42곳 불변이다.
  원slot1 19417B/e4978df6…도 byteexact로 둔다. player33/project/preset/seed2/W238/
  공개·옛앱·ZIP·원manifest·실패raw·인간 판정은 보존한다.
- 재시도는 첫 시도 after43곳에 실패raw1을 더한44곳을 새 입구로 봉인한다.
  index40 후보namespace만 UI 변경 허용·나머지43불변이며 첫 시도 원산출을 덮지 않는다.

## 실행·판정

1. Mac 접근/clean 입구·43곳을 확인하고 같은 executable을 무인자 새 process로 시작한다.
2. KO home Continue→자동 M02 `arc_temptation_clean`의 첫 원문 문단 완료만 본다.
   Return/게임advance/choice/AUTO/skip/길게누름/새수동저장/저장복사·주입0이다.
3. 실제 Settings에서 EN→JA→zh-CN→zh-TW→KO로 변경·닫기한다. 각 언어의
   첫 원문 문단(재분할되면 첫 화면까지만), title/HUD/nameplate/진행안내/설정과
   복귀를 본다. 폰트 누락·잘림·다른 언어 누출·진행 위치/모달 문제를 원관찰에 남긴다.
   언어 변경 때문에 다시 타이핑하면 자연 완료만 기다리고 다음 문단으로 넘어가지 않는다.
4. 정상CmdQ/own종료/editor보존, full stdout/stderr/Godot·각 정확 entry/exit를 읽는다.
   closedM1/settlement1/elapsed4/choice1과 원slot byteexact·42불변/ns1허용·전체 source/
   helper/seed/player를 root+독립 final fresh 대조한다. 언어 설정/이름 현지화/대화기록의
   정상 변화는 gameplay 효과와 구분한다. 결함 수리는 별도 선선언한다.

이 단위는 M02 첫 표면/언어 설정 복귀뿐이다. M02 전체/다른 데모 장면·해상도·큰글자/
옛공개저장 호환·인간/원어민/물리/청취·전체제품/출시 GO는 아니다.
