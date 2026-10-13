# ORDER-600 — 재연락과 기사에서 없는 이력 회상 제거

#### [x] ORDER-600 [정합] M25 입구/후속 경로 KO·EN 18잎 — 2026-10-13

사용자 위임 잠금 중 월순서 사실 수리. 599 뒤 M25의 t>=100 재연락 입구를
읽고 확인한 지연의 거래/직업/기간, 상철의 신고/손절 발명을 고친다.
상철 fresh 대면은 M33이며 기사도 그 이후다. M25는 옛 저장의 seen 기반
fallback 가능 범위일 뿐 새 실행을 관측했다는 뜻이 아니다. 실제월562/M17 HOLD 하나.

## 근거·깊이 3문

- MainGame:8468 지연은 t>=100+epilogue_seen뿐. offer의 커피 거절→truth→
  epilogue도 가능하며 lunch 소개는 거래실행/손실/직업을 보장하지 않는다.
  마지막 연락시각도 검사하지 않아 3년후/2년/수년침묵 단정이 성립하지 않는다.
- 상철 reckoning의 신고/용서/이용/상환 모두 year3 예약을 생산한다.
  min_turn9999 예약은 EventManager:856, MainGame:7066에서 거절·정리한 뒤
  :8463 seen fallback으로 읽는다. delay1 표시주차를 단정하지 않는다.
  묻음/거리두기 역시 seen을 생산한다. father_passed 치환은 있지만 신고치환은 없다.
- 방치하면 고르지 않은 거래·재직·신고·손절을 기억한다. 기존 두 지연 답장의
  경계/솔직함과 기사 세반응·8주 후속·관계효과가 경쟁하며 모두 보존한다.
  24주 뒤 새로운 상태0, 기존 기억/다음독자0변경. 새 장면·격상·일반 윤문0.

## 소유 범위

- root content/events/arc_year3_drama.json 및 EN counterpart만:
  arc_jiyeon_year3 title/description/choices[1].result_text 각3=6잎.
  기간없는 안부, 공유 사고의 기억, 실제 자신의 선택/기준으로 수리한다.
  오래 연락 안했다는 단정도 빼되 현재 메시지/답장 행동은 유지한다.
- 같은 파일 arc_sangchul_year3 및 _father_passed 각각 description,
  choices[0].text/result_text KO/EN3쌍=12잎. 신고를 현재그의선택으로 중립화,
  창밖 대신 고개들기, 이미 관계끝이라는 회상 대신 지금기사를 덮는 행동.
  EN arrested는 KO입건의 수사 상태로 좁혀 체포를 발명하지 않는다.
- 필요 release_content_inventory 실제 내용SHA/공식 CONTENT_RATING 보고,
  큐2·이사양/archive·WORK_LOG·CLAUDE 현재행. 그외 제품/문서/검사0.
- m24_money_fact_review: .git/order600-20261013/independent-review.md만.
  rework_batch_plan: 같은 곳 preservation-review.md만. root는 그 보고 안쓴다.

flags/조건/DIK/인덱스/효과/라우팅/지연/장소 배선·음악 불변.
다은 기간/아파트 후보는 다음 별도단위며 이 오더에 붙이지 않는다.
공개M01~06/사용자 저장·설정/project.godot/인간 역사/5언어 유지.
JA/zh 다듬기/원장수용0, KO9잎은 실제 KOEN 확정 후 일괄정합 대상으로 남긴다.

## 검증·완료

선언 commit/push 후 구현. 기존 source13 표적(EN/Hangul/story consistency/
continuity/spine/speech/audio/i18n/demo scope·story·JA·ZH/release) actual0.
599 공식after3를 before로 재사용, 새 inventory3의 변동만 판독·미수용 기록.
비저자18잎 의미·조건·구저장, wholeinverse·비소유/데모 보존 GO 뒤
context/queue/diff 확인 후 같은 완료commit으로 닫는다. 새툴/검사/등록/전체audit/
240주/엔진/native/저장접근0. CI빨강 새월0·해제즉시 원559 W68 실제M17 우선.
gangnamdream-dev/WORK_UNIT 적용·일회성/승격0.
자동검사는 계약 증거이지 재미/인간/원어민/물리패드 관찰이나 출시 GO가 아니다.

## 결과·증거

- 선언 c15c40fb280be9498cd740606180a51d1d40d9b1/treef61f7382e9276d39b4947a4b6da059340bd19490.
  KO9/EN9 전18잎 의미GO·보존10/10/demo7/7·비소유3383 exact.
  표적13/공식inventory3 actual0. crime SHA만
  f958f5d21df6266e3115ec7fca8ba1e9faf7fe1db546ca8b4461883838c5c13d로 공식보고와 정렬.
- .git/order600-20261013/independent-review.md: m24_money_fact_review,
  8616B/50feab87c3b84a581e0ef9725735ca85aef006b5c871d50a8d69e714c15d6c25.
  preservation-review.md: rework_batch_plan,
  9447B/a19f6e5a108a23c159a4cba5cf8b3f03f0323e2bb75ddb9f6765cb626d868829.
  root 두 보고 전문 판독. before1423B/db66ef042fe2c7d65e675e50c19f96001166ab35c84cdbb51374c79267fdd269.
  보고서의 제품4 SHA 일치·wholeinverse exact. EN 지연 description의{name}2→1은
  소유 첫문장 재서술 예외이며 문단18/18·나머지17잎 토큰은 exact다.
- source manifest1d9f6cbc97d6b6312a7541f693d2342a249c25bd082d4a71dd8b271c30037fe0.
  current11402/stale40·42·42/invalid64·6·6. 옛 CJK의 연수 표현이 남아 생긴
  JA3/CN1/TW1 numeric mismatch를 미수용 대기로 기록·숨김0. 고유KOEN101/CJK48KO잎.
- callback39 jiyeon_real_talk의 골목/정확인용은 다른 카페 생산자도 있어 보장되지 않는
  기존 부채다. 수정 전에도 성립하지 않았고 min_turn136 후속 별도 수리로 남긴다.

```
도달 경로      : MainGame:8463/8468, EventManager:856, MainGame:7066
생산자 ↔ 독자   : offer/truth/epilogue → 지연; confrontation_seen → 상철
바꾸는 상태     : KO/EN18잎·게임상태0
포기 시 잃는 것 : 기존 선택·정신/관계효과·8주후속 불변
서사 위치       : 지연 M25 가능/상철 fresh M33 이후·legacy t100, 실제월0
장면 계층       : 기존 장면·격상0
닫는 것         : 없는 거래·월급·연수·신고·관계종료 발명
```

일회성/승격0. 실제 M17 OS잠금HOLD 하나·해제우선·새월0·5언어/본편/출시HOLD.
599 CI38397776159 조회시 진행중·이번push 성공 미확정. 다음 다은 기간/주거는 별도단위다.
