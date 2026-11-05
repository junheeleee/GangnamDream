# ORDER-795 — 일본어 부친 후일담 귀향 의미

#### [x] ORDER-795 · 일본어 부친 후일담 귀향 의미 — 2026-11-06

부모157/C5. 착수 — `locale/ui_ja.json`의 부친 귀향 권유/사후 창원 방문
기존2키와 `content/meta/full_game_localization.json`의 해당 결속만 소유한다.
한국어 ‘내려오다/내려가다’는 고향으로 돌아감을 옮기며 층간 이동·하차를 발명하지 않는다.
살아 있는 부친의 식사 권유와 fs=passed 뒤 1회 방문/빈방을 구분한다.
`_ending_cast_epilogue`의 good/bad·부친 stage·돈 선택/막차 우선은 읽기만 한다.
KO/EN/CN/TW·원문·코드·분기·수치·저장·공개 데모 비소유, 신규 커버리지0.
기존 공식 export/check/import replace·사전/원장 역복원·JA UI·데모·EN과
다른 에이전트의 실제2값 전수 검수를 수행한다. 실제 화면/원어민은 별도다.
작업 지시는 일회성, 기존 현지화/판정 정본을 따른다.

제품 `8f1da7ad89e754afcb2510cbbd452915e8a3e51a` 정상 push.
기존 JA2 첫 원문 결속 수용·신규 커버리지0. 공식 check/import·전체 사전/원장
byte 역복원(원385배치)·JA UI·데모·EN 및
[독립 전수 source GO](../agent_reviews/order795-ja-father-homecoming.md).
1회 방문·빈방 문장 exact·생사/분기·다른 언어·코드·저장·공개 데모 불변.
선택목록31은 실행 증거가 아니며 실제 화면/원어민/전체 CI 완료는 별도다.
자동 검사는 계약 증거이지 사람 품질·출시 판정이 아니다.

마감 후 문맥 제한 실패와 종속 커밋 진행 실수는 WORK_LOG에 보존했다.
`47b656e0f755dc5b7f4142f89722a7ece3fc6488`에서 원문 전체40855B를
byteexact 이관하고 현재 기록15229B로 수리했다. 제품/기존 기록·판정 불변,
[새 실제 source 독립 GO](../agent_reviews/order795-ja-father-homecoming-rollover.md).
기록 수리는 신규 번역 커버리지나 이전 실패의 성공 치환이 아니다.
