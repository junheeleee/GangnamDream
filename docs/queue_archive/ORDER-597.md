# ORDER-597 — M24 월급 계산의 주거 형태 정합

#### [x] ORDER-597 [정합] KO/EN 6잎 source 수리 — 2026-10-13

기준 main87f34d96954612759dc3b26a67a486da9bc80bb4. 사용자 지시로 Mac 잠금 중
M17~M60의 KO/EN 사실을 월 순서대로 수리한다. 현재 M24이며 실제 앱 M17은
562 하나만 HOLD다. 해제 즉시 원559 W68 실제 플레이 우선, CI 빨강 새 월0.

## 확인한 결함과 깊이

MainGame.gd:7307–7312와 story_rules.json:3233–3249의 월급 장면 입구는
재직·근속6·거울장면을 요구하지만 주거 형태는 제한하지 않는다.
GameState.gd:52–61은 빌라/아파트 전세와 주거 비용을 지원한다.
그런데 arc_career_ceiling 기본 본문과 병동/거래 선택 회수 본문 모두 월세를
뺀다고 단정한다. 주거비라는 상위 표현은 기존 모든 주거에 맞는다.

1. 방치하면 전세 경로에도 월세 납부를 발명한다.
2. 새 선택/게임 상태/24주 차이0. 기존 선택·비용·회수는 그대로다.
3. 월급의 한계와 병원/거래 갈등을 보존하며 계산 항목의 주거 형태만 바로잡는다.

## 파일 소유와 작업 범위

- root: content/events/arc_midgame.json 및 content/events_en/arc_midgame.json의
  arc_career_ceiling.description과 description_if_known의
  sangchul_mirror_hospital_face_up / sangchul_mirror_deal_face_up, 총6잎.
  KO 월세→주거비, EN rent→housing costs만 바꾼다.
- 필요할 때만 content/meta/release_content_inventory.json의 실제 content SHA와
  docs/CONTENT_RATING_INVENTORY.md 공식 생성 보고를 정렬한다.
- root: 큐2·이 사양/완료 archive·WORK_LOG·CLAUDE 현재행.
- mod_layer_ci: .git/order597-20261013/independent-review.md만.
- rework_batch_plan: 같은 디렉터리 preservation-review.md만.

다른 시간·직종 문구는 이 범위에서 고치거나 승인하지 않는다. 본문 나머지,
선택/결과/효과/조건/플래그, 실제 경제·저장·주거·라우팅·아트/음악은 불변이다.
JA/zh 다듬기와 원장 수용0. KO 변경3잎은 실제 KO/EN 확정 뒤 정합 대기로 남긴다.
5개 출시 언어·공개 데모·사용자 저장/설정/project.godot·과거 인간 판정 보존.

## 검증과 완료

선언 커밋/푸시 뒤 구현한다. 직전596 공식 locale inventory를 before로 재사용하고
새 공식 inventory3으로 변화를 측정한다. EN coverage/Hangul, story consistency,
narrative continuity/spine, speech, scene audio, i18n, demo scope/story/JA/ZH,
release inventory와 context/queue/diff 검사를 실행한다.
비저자가 실제6잎·입구/주거·독자·나머지 bytes와 데모/비소유 보존을 읽고 판정한다.
표적 새 실패0·source 독립 GO 뒤 마감한다. 새 검사/도구/등록·엔진/전체 audit/
240주·실제 월/새 장면/격상0. 자동 계약은 재미·인간·원어민·물리 패드 증거가 아니다.
본편/출시 HOLD 유지. gangnamdream-dev/WORK_UNIT 적용·일회성 지시·정본 승격0.

## 결과

세 본문×두 언어의 월세/rent만 주거비/housing costs로 고쳤다. 표적13 actual0,
독립6/6 source GO, 보존10/10·공개 demo7/7·비소유3380 mode/blob/SHA 일치.
선언52e65476f6220db820017eebbddf60beda931da8/tree0c7a49e2f7685ff6695b468cde8dd6eb87f80bfa.
KO297449B/0bea035b51c5b7a26dddf0e98fb1c0336e0f4a0fb5521d07a1fff0097978505a,
EN218553B/7484cce409cbfade6ee5ec34ebe01cd540a3074316f439e7ca4b96b091d82664.
각6span 역치환으로 before 두 파일 전체 bytes가 재구성된다. release7축/공식보고 불변.

- mod_layer_ci independent-review.md 6418B/
  a22a53c739156c7866871a657faa4b4a1cdb60f898f8d2948bf5384cc1d45f83.
- rework_batch_plan preservation-review.md 8610B/
  02e9c3a8a94d45f7516617f016a845c2d244e845387a88bf28f9465936a9ef60.
- 두 원보고는 .git/order597-20261013/에 보존, root 전문 판독. source 작성 뒤
  capacity로 SHA 회신이 누락됐지만 비저자가 완결 원파일/실물6구절/핀을 다시 읽어
  원6span GO에 결속했다. 원보고 수정0, 별도 EN주체 후보는 미확정으로 보존한다.
  root가 실제 거울 원발화도 읽었으며 이는 상철이 민준에게 한 평가였다.
- 공식596after→597after3 actual0: KO3 source만 변경, manifest
  77916f0d8968dff5a70f1ab0a467512045a8605fc45f9c025430efcffcea1461.
  각current11424, stale21/22/22, invalid61/4/4 목록 불변. 누적26KO잎 CJK정합대기.
  CN/TW 원pending 응답과 별도 final0는 구별해 보존한다. 수용/다듬기0.

```
도달 경로      : MainGame:7307–7312, story_rules:3233–3249
생산자 ↔ 독자   : arc_career_ceiling ↔ callback_kept_job_as_base_echo/career_pivot_intent_echo
바꾸는 상태     : gameplay0, KO3/EN3의 주거 명사만
포기 시 잃는 것 : 기존 세 선택/독자 불변, 새 선택0
서사 위치       : M24 W94–95, 실제 월0
장면 계층       : 기존 장면·격상0·전체 장면 승인0
닫는 것         : 전세 경로의 월세 납부 발명6곳
```

엔진/native/사용자 저장 접근0·5언어/인간OPEN/공개GO/종료잔여 보존·출시HOLD.
다음 읽기에서 M24 다은 돈대화의 투자배당/수익 및12주독자 보유종목 발명을
확인했다. 별도 다음 사양에서 생산자·독자를 함께 수리하며 이 범위에 섞지 않는다.
원장 구조를 실제 화면/품질/출시GO로 바꾸지 않았고 현황판 단독후속0이다.
