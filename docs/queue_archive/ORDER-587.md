# ORDER-587 — M19 미실행 모임·근무 회상 정합

#### [x] ORDER-587 [정합] KO/EN 4잎 source 수용 — 2026-10-13

기준 clean maindbb3566d5d1893091bd26dbf7e69dea66fe30b04/
tree1beda5c2528804cb7c23a041778d8a46c067b53b. M17→M18 판독/수리 뒤
M19(W73–76)의 새 문턱과 조건부 KO/EN 본문·변형·결과를 순서대로 읽었다.
Mac 잠금/source만, 해제 즉시562 원W68 실제M17 우선·CI빨강 새월0이다.
출시5언어 유지·KO/EN 실제 확정 전 JA/zh 다듬기0/누락만·일괄 정합은 이후다.

## 근거와 깊이

1. 카지노 초대 choice0는 M14 모임에서 이미 얼굴을 봤다고 회상한다.
   MainGame:8041–8044는 W76+/coffee02_seen/현금300만만 요구한다.
   coffee02는 1:1커피와 미래 모임 약속/거절이지 타인 목격이 아니다.
   M14 은행 fallback 뒤 M19 현금300만 경로에도 성립하지 않는 과거다.
   네 명/직업은 유지하되 마지막 인물을 상철이 함께 간다고 적은 지인으로 쓴다.
2. arc_daeun_trace 기본본문 야근 뒤/After another late shift는 MainGame:
   8254–8258의 let_go/ghost만으로 열리며 직업/그날 근무 증거가 없다.
   늦은 밤/Late at night로 써서 없던 야근·반복 교대를 만들지 않는다.
3. 선택·결과의 효과·flags·관계/현금/이동/후속은 불변이다. 상태/24주 차이0,
   고치는 것은 과거/근무의 부당한 단정이다. 새 선택이나 경로를 만들지 않는다.

fresh 현재 fork는 M22 생산자라 trace를 실제 fresh M19 화면으로 세지 않는다.
casino의 glimpsed와 never met는 같은 뜻이 아니므로 두 문장만의 즉시모순을
확정 근거로 삼지 않는다. 미실행 모임 선행 부재가 근거다. entered_network
하나로 새 가드를 걸지도 않는다(03_seen은 두 선택 모두, entered는 한 선택만).

## 정확 소유·보존 계약

- root 제품: content/events/arc_events.json 및 content/events_en/arc_events.json의
  arc_sangchul_casino_invite choices[0].result_text 각각1잎,
  content/events/arc_midgame.json 및 content/events_en/arc_midgame.json의
  arc_daeun_trace.description 각각1잎. 각 한 구절만, 총4잎이다.
- 필요 지문: content/meta/release_content_inventory.json candidate_scan의 실제
  content SHA만 / docs/CONTENT_RATING_INVENTORY.md 공식 보고만.
- root metadata: 큐2·이 사양/마감 archive·WORK_LOG·CLAUDE 현재행만.
  manual_save_ci는 새 .git/order587-20261013/독립 의미보고만,
  rework_batch_plan은 같은곳 보존·실제 demo pin/원장 경계 보고만 소유한다.

현재 demo_localization_scope는 과거 전체 파일 이력 대신72 protected 사건의
semantics와467본문을 잠근다(tools/demo_localization_scope.py:791–864).
manifest9d50b64e…·semantics4fc2e77e…·본문 current40769/43ec49da…를 그대로
검증한다. 위 두 사건은 보호72/공개14 밖이다. 따라서 데모 slice·계약 bytes를
유지한 채 같은 커밋의 데모 검사를 통과시킨다. 관성적인 pin/검사 수정0이며,
실제 계약 변동이 나오면 작업을 닫지 않고 원인부터 고친다. M01~M06 불변이다.
JA/CN/TW/번역 원장/accepted를 수정0, 새 KO2잎 stale는 공식 inventory로 공개한다.
source/receipt의 미완료를 다섯 언어 GO나 source오류0으로 덮지 않는다.

## 검증·마감

선언 commit/push → before 및 공식3locale →4구절 patch →3locale after→
EN coverage/Hangul·narrative continuity/spine·story consistency·speech/audio·
i18n·demo scope/현재계약 self-test·story demo/JA demo/ZH demo·release 지문/
보고·context/queue/diff. demo contract에 직접 닿는 파일이라 해당 자체검사1만
추가하며 다른 닫힌 자체검사 반복0이다. 원문4 span역복원·나머지 게임플레이/
protected72/공개14/CJK/원장/비소유·조건/후속 exact를 독립 판독한다.
새 제품 gate 실패0·독립 source GO 전 완료0, 의도한 번역 stale는 따로 남긴다.
새 tool/검사/등록/엔진/native/전체audit/240주/검증비용 작업0이다.

장면 추가/격상·자산/연출 변경0·기존 미선언T3 유지, 전장면 승인0이다.
project.godot·사용자 저장/설정·원559 seed/앱/옛raw·human 판정은 비소유/접근0.
gangnamdream-dev/WORK_UNIT의 조건·소유·한영/표적검수·관찰 분리를 적용한다.
일회성/승격0. 자동 계약은 재미·깊이·문체·인간/원어민/물리패드 증거가 아니다.
실제M17·원어민/인간 OPEN45·전체 번역/본편/출시 HOLD·종료 잔여는 유지한다.

## 실제 결과

KO/EN4잎 수리·표적14 actual0·독립 전4잎 source GO/blocker0다.
카지노는 현재 회신한 동행 목록으로, trace는 늦은 밤으로 맞췄다. 해당 EN 과거목격
{name}1도 없애 KO원래0과 같아졌고 그 밖의 토큰/문단/게임플레이는 exact다.
release gambling/fear의 실제 contentSHA2개와 생성보고2행만 연동했다.

- 비저자 manual_save_ci `.git/order587-20261013/independent-review.md`4657B/
  6f7489f572c0d05bac9681115747f68bd1e31e7d6f0033a08ad80de336a468c0.
- rework_batch_plan 보존16/16·demo 직접대조7/7true: source4spans·지문2/
  보고2 역복원, 비소유3367 mode/blob/SHA·CJK/원장/project/사람 원장 exact다.
  `.git/order587-20261013/preservation-review.md`11854B/
  daa92c701614cfd2600d020900b991490b44614cea1f7a170e07ac27b97b9274.
  protected72 실물 slice/semantics4fc2e77e…·467잎40769/43ec49da…·공개14
  KO/EN fullrow/rawslice exact, validator/manifest bytes 불변이다. pin 수정0은
  누락이 아니라 현재 계약이 데모 밖 본문을 전체파일로 잠그지 않기 때문이다.
- 공식3locale 전후6 actual0, source manifest5e73ab…→
  ccaead5e4ada481a3045452675ae3dc8ded3f9067910b8ef4a8db69b2ecc4698,
  KO source2잎만 전이·17504/466 불변이다. 각 current event receipt11448→11446,
  stale1→3, JA invalid57/CN·TW1은 exact다. 새 번역 수용0·원문후속 정합대기다.
- `.git/order587-20261013/before.json`1833B/
  bcf303defa7342a6a8fcff4beb88030956bbe1346c112f90d3b58859f33ca6a7;
  `inventory-observation.json`2445B/153940d56369000463b6a8f9dea78e65fbcac9ad4809a4b6b4944e7ac2826b7b;
  `demo-roster.json`2481B/6c54a856cd1b803e6cd2a6b0424bee36074bad7eb9ab32379baa6545324f9769.
  root는 기존 build_scope를 잘못된 인자로 불러 TypeError/쓰기0을 보존하고,
  실제 무인자·반환순서를 읽어 source-only72목록을 포착했다. 비저자는 그 목록과
  실제before/current를 직접 대조했으며 reachability collector/엔진 실행0이다.

```
도달 경로      : MainGame.gd:8041–8044 / 8254–8258; demo Scope actual0
생산자 ↔ 독자   : arc_events coffee02/03 ↔ MainGame.gd:8041; daeun fork ↔ :8254
바꾸는 상태     : gameplay0; KO/EN text4; CJK current receipts −2/locale
포기 시 잃는 것 : 신규 선택0; 기존 카지노 후속·trace 3결과 exact
서사 위치       : M19 W76+ 조건부 초대·W76–84 trace, fresh 실제 노출 주장0
장면 계층       : 기존 미선언T3·격상0·전장면 승인0
닫는 것         : 미실행모임/무근거야근2; 별도30억 단정/실제월/전체언어/출시 미완료
```

M19 판독에서 뒤늦게 확정된 daeun_04_morning의 30억 거리 단정은 별도 후속으로
분리한다. 이 오더에 붙이지 않았으며 M20은 아직 미판독이다. 일회성/승격0·
gangnamdream-dev/WORK_UNIT의 소유/조건/표적검수·관찰 구분 적용·native/새월0,
Mac locktrue·실제M17 HOLD 하나·해제 즉시 원W68 우선·새push CI미확정,
전체5언어 정합/본편/출시 HOLD·공개/사용자저장/옛판정·종료 잔여는 유지한다.
