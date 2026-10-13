# ORDER-600 — 재연락과 기사에서 없는 이력 회상 제거

#### [~] ORDER-600 [정합] M25 입구/후속 경로 KO·EN 18잎 — 2026-10-13

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
