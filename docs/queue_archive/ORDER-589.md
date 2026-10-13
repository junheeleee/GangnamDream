# ORDER-589 — M20 현수 발령의 무조건 동거 회상

#### [x] ORDER-589 [정합] KO/EN 4잎·590 인용 정합 후 수용 — 2026-10-13

기준 clean main717d5aee808d1e92b8a3f1dbd3575f93a93a4e0c/
tree4bb7d0f26c2788c91127c3476ed2ca2cf4afde13. M17→19 뒤 M20의 story_map과
실제 새 문턱4개/KOEN 본문·변형·선택·결과를 읽었다. source 관찰이지 실제월 GO가
아니다. Mac잠금·실제M17 HOLD 하나, 해제 즉시562 원W68 우선·CI빨강 새월0.

## 근거·깊이

MainGame:8152–8154 hyunsu_pass_news는 W80+/hyunsu_passed/미열람만 요구한다.
GameState:1642–1656 이사·MainGame:7640–7644 탈출 회상이 먼저 완료돼도 열리며
현 본문은 현수의 고시원을 방문한다고 쓴다. 그러나 choice0는 언제 여기 나가냐/
한 명 먼저 나갔다고 현재 동거·선후를, choice1은 다음날 빈방/공용 주방과 새벽
소리 부재를 민준의 직접 관찰처럼 쓴다. 현재 주거/재방문 근거0이다.

1. 이미 이사한 경로의 주소/관찰을 발명하지 않아야 한다.
2. 게임플레이·24주 상태차이0, 새 선택/주거/재방문/연락·사진을 추가하지 않는다.
3. 현수의 현 짐싸기·발령지로 떠남, 그 자리를 방문하고 돌아가는 현재 장면으로
   닫는다. 순대국밥/비용/호감·친구를 보내는 여운과 확인된 라면 기억은 유지한다.

## 소유·대체

- root 제품 content/events/arc_hyunsu.json 및 content/events_en/arc_hyunsu.json의
  hyunsu_pass_news choices[0/1].result_text 각각2잎, 총4잎 안의 아래 구절만.
  choice0 질문을 형은 다음에 어디로 갈 거예요 / Where are you headed next,
  hyung으로; 끝 선후 단정을 현수는 다음 주에 발령지로 떠난다 / Next week,
  Hyunsu would leave for his new posting으로 바꾼다. 기존 글쎄/식사/계산서 유지.
  choice1 다음날/며칠간 직접 부재관찰 두 문단을 현재 냄비 포장→기존2시 물끓음
  기억→민준 복도·계단 출발/테이프 소리로 쓴다. 처음 감사/서툰 악수 문단 exact.
- 의존 지문 content/meta/release_content_inventory.json의 실제 content SHA만,
  docs/CONTENT_RATING_INVENTORY.md 공식 보고만; 불변이면 수정0.
- root metadata 큐2·이 사양/완료archive·WORK_LOG·CLAUDE 현재행만.
  manual_save_ci 새 .git/order589-20261013/independent-review.md,
  rework_batch_plan 새 preservation-review.md만 소유한다. 다른 파일/쓰기0.

description의 방4년은 공부4년과 다른 사실이라 미확정으로 수리0, choices/effects/
flags/조건/후속16주/비용/관계/주거·런타임/시각/오디오 나머지 bytes exact다.
KOEN 확정까지 JAzh 다듬기/원장수용0·출시5언어 유지·source2잎 정합대기는 공개한다.
직전588 after3locale를 실제 원관측 before로 재사용, 새수집이라고 보고하지 않는다.

## 검수·경계

선언 commit/push→4잎 한정수리→공식3locale inventory after→EN coverage/Hangul·
narrative continuity/spine·story consistency·exposed_state·speech/audio·i18n·
demo scope/story demo/JA/ZH demo·release 지문/보고·context/queue/diff.
원문span 역복원/게임플레이·데모72/공개14·CJK/원장/비소유 독립 대조, 의미 전4잎
독립판독·source GO/새제품게이트실패0 전 완료0. 번역 정합대기를 전체언어 오류0으로
덮지 않는다. 새tool/검사/등록/selftest/엔진/native/전체audit/240주 실행0.

장면추가/격상·자산/연출0·기존미선언T3, 전장면 승인0. project.godot/사용자 저장·
설정/원559seed·앱/옛raw·human원장 비소유·접근0. gangnamdream-dev/WORK_UNIT의
조건·소유·한영 표적검수/관찰 분리 적용·일회성/승격0. 자동 계약은 재미·깊이·문체/
인간·원어민·물리패드 증거가 아니다. 공개GO·인간OPEN45·전체언어/본편/출시HOLD·
종료잔여 유지. CI717d5ae run38347941886 진행중/완료미확정·M21 선행0.

## 실제 결과

최종 KO/EN 4잎·6구절 수리, 표적14 actual0·전4잎 독립 source GO다.
단순 이사 질문/선후 단정과 미래 빈방·주방 직접 관찰을 현재 방문/출발로 맞췄다.
선택/효과/돈/관계/예약16주/본문 나머지 바이트 불변·release7축 지문/report 불변이다.

- 의미 manual_save_ci `.git/order589-20261013/independent-review.md`5976B/
  824222aabe981532a9c8b1f83c0058febdbc6c24710ee03a2120ab513056af9e.
- 보존 rework_batch_plan `preservation-review.md`9965B/
  a5819317e92583e840a6561fee3c0827e17c1739b85bec8d8cfae56c4f5e55d6.
  실제90a7d65/tree0bba5ed0/index0/dirty4 union 관측이다. 옛 HEAD/dirty2 기대값 및
  child2를 비소유로 보던 검사 false2(15/17)를 보존했다. parent6span inverse와
  child외3369 exact/데모7/7로 scope를 분리, 이를 단독17/17 PASS로 바꾸지 않는다.
- v1 새{name} KO1/EN2 및 cast명 추가로 inventory invalid 각+1 REWORK가 났다.
  v1 두원본/after3/check14를 보존하고 v2는 추가token/cast0·기존 문단 구조 유지로
  고쳤다. v2 final-*.json14개 actual0·after-v2-3locale actual0이다. v1 narrative
  출력은 중간 인간 상태 일부가 잘린 원수신이고, final 출력은 완전 수신/별도 보존했다.
- 최종 parent핀 KO36593B/acb77fb682c80d4498dd6658dd67020337789d38ca03acfe2640c42f2fd2d1fd,
  EN27198B/3dd2aec54ddc5bd2cd0ab6f7758e3b10d6846a5ecba090f9b4bfa078a9b99d89.
  before8핀1185B/da6ff86b30f44c3209e154748ff9e76d8960156606c26eb830daa8b401ee562f.
  두source 역복원은 선언원본658aafc…/b041f0… exact다.
- 공식 before는588 after원관측을 재사용했다. v2는 KO result2잎만 전이,
  manifestbe1d3da0133550b5695db0da923f40dfdb6cf4a28259b9c547ee17c1fa4d8a12,
  각currentreceipt11445→11443/stale4→6·invalid JA57/CN1/TW1 exact다.
  JAzh 수정/원장수용0·번역 정합대기·5언어 전체완료0이다.

비저자가16주callback의 옛 직접인용을 발견해 한때 인과HOLD했다. 그 원보고/HOLD를
지우지 않고 별도590 선언·KOEN2quote수리·현재 source정합GO/보존25/25로만 해소했다.
590의 current90a7 union 판독에서 parent2 wholepins/나머지3369 및 보호demo72/467/
공개14가 exact다. 중간 불일치제품을 따로 commit하지 않고 둘을 한 구현커밋에 묶는다.

```
도달 경로      : MainGame.gd:8152–8154; EXPOSED_STATE_CONSISTENCY_AUDIT_OK
생산자 ↔ 독자   : arc_hyunsu.json:414–417 ↔ callback_events_41.json:94–99/590
바꾸는 상태     : gameplay0; KOEN4result text; CJK currentreceipt−2/locale
포기 시 잃는 것 : choice1에 식사flag/callback0; choice0의16주reader exact
서사 위치       : M20 W80+ 발령·조건부 호환source; 실제월0
장면 계층       : 기존미선언T3·격상0·전체장면 승인0
닫는 것         : 무조건 동거/미래 직접관찰1묶음; 590 인용 연동 해소
```

gangnamdream-dev/WORK_UNIT 적용·일회성/승격0·엔진/native/새월0·Mac잠금true다.
실제M17 HOLD 하나·해제즉시 원W68 우선·CI빨강 새월0·새push CI미확정.
공개GO·사용자저장/과거인간/5언어·출시HOLD/종료잔여 보존, M21 미판독이다.
