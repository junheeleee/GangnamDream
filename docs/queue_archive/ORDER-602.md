# ORDER-602 — M26~27 달력·즉시 결과 시간 사실 수리

#### [x] ORDER-602 [정합] KO·EN 17잎 — 2026-10-13

601 source 완료 뒤 사용자 위임 잠금 중 월순서 수리. 실제월562/M17 HOLD 하나.
OS 해제 시 원559 W68 실제플레이 우선·CI빨강 새월0·JAzh 다듬기/수용0.

## 근거·깊이 3문

- MainGame:8368 pressure t105~115는 3년차 봄인데 제목/본문은 2년째 가을이다.
  :8371 birthday t100~112는 35세와 부친생존을 지키지만 현재 설날은 보장하지 않는다.
  ORDER-350 #2의 생일 모순 수리를 보존해 생일로 되돌리지 않고 나이·일반안부로 맞춘다.
- StoryMode:6487/6570은 선택 직후 결과 표시, GameState event_log도 같은 turn이다.
  앱삭제에 2주 경과/집중력 향상 회고를 부과할 근거가 없다. 삭제 직후 습관/멈춤으로.
  민기 청첩장/집사진은 이번에 새로 온 소식이라 선행flag를 요구하지 않는다.
- 장기 birthday_rest_taken/back_to_work와 cut_sns/congratulated_friend 상태는 그대로.
  후월 callback44의 생일·정확인용/2년째 회고, callback54 인용은 수정 전에도 미보장인
  별도 월순서 부채이며 이번에는 flags·스케줄·효과/예약·저장/주거를 바꾸지 않는다.

## 소유·정확 범위

- root content/events/arc_midgame.json 및 events_en 동명:
  arc_35_birthday title/description/choice0 result/choice1 text 각4=8잎.
  설현재성 제거, 35세·33세 출발·2년 경과·사회적시선의 조건형 일반문장 유지,
  정확히 남은3년 대신 남은시간을 헤아림. 현재 안부와 휴식/계획 선택 대비를 살린다.
  arc_year_two_pressure title/description/choice2 result 각3=6잎.
  EN choice0/1/2 label3은 KO의 문자보내기/알림닫기·복잡한마음/앱삭제 행동으로
  직접정렬한다. 이는 달력오류와 별개인 선택 의미 번역부채이며 광범위 윤문은 하지 않는다.
  합계 KO7/EN10=17잎. placeholder·문단·나머지 JSON/metadata 전부 보존.
- 필요 release_content_inventory 실제내용SHA와 공식 CONTENT_RATING 보고만,
  큐2·이사양/archive·WORK_LOG·CLAUDE 현재행. 다른 제품/검사/도구 변경0.
- m24_money_fact_review: .git/order602-20261013/independent-review.md만.
  rework_batch_plan: 같은 경로 preservation-review.md만. root는 독립보고 안 쓴다.

## 검증·경계

선언 commit/push 후 구현. audit_select --list로 선택확인, 기존source13표적 actual0.
601 final3를 기준으로 공식 full_game_localization inventory3 비교·미수용부채 기록.
비저자 전17잎 의미/조건·wholeinverse·비소유/공개데모 보존 검수, context/queue/diff 마감.
원장·CJK·project.godot·사용자 저장/설정·공개M01~06·과거인간판정 보존.
전체audit/240주/엔진/native/새월0. 자동검사는 계약 증거이며 인간·원어민·물리패드
관찰이나 5언어/본편/출시 GO가 아니다. gangnamdream-dev/WORK_UNIT 적용·일회성/승격0.

## 완료 · source 한정

선언b1d43bf 뒤 정확17text(KO7/EN10). title/일반안부/남은시간/휴식·현재사진비교/
앱삭제 직후 손동작 및 EN선택3 정렬. 효과·조건·flag·저장·공개·배경·CJK 불변.
표적13 actual0와 official inventory3 actual0. release7축·공식report bytes 불변.
최종 KO297352B `84551f2ea8e3a1e490900da1d45334e2c2c513fc359f3bc511f1880d3a46abca`,
EN218438B `78ae42540c5049d3364238f58c475593a714844dc9020dbf1030c98de62ec7cf`.

root 전문 판독한 비저자17/17 source GO 및 보존10/10/demo7/7·비소유3385 exact:
- `.git/order602-20261013/independent-review.md` 10937B /
  `ea4a0704f9dd393e0399b764814602628fe11d1cb03ec34baa9aa14f5c1a0712`.
- `.git/order602-20261013/preservation-review.md` 최종7608B /
  `1a223450608ebef35e66eee15dec07ca67fe012503de240d1b7a81ec3da1a460`.
  800ea88의 root 마감이 최종봉인 통지보다 앞서 중간보고핀을 적었다. 603 선언에서
  최종 전문을 다시 읽고 정정했다. 수정은 보조전송 비교불가의 표현 한 문장이며
  제품2핀·판정·측정값은 동일, 제품/검사 재실행0·원커밋을 숨기거나 되쓰지 않는다.
- before1364B `145900497c035932306e82d73d1a289d3980c9850b5cf1be605a1b1c9c79d30c`.
  보조집계 전송잘림/첫parse 거부(write0)는 같은 출력과 공식raw RO읽기로 보완했고
  원검사 재실행·원실패 삭제·제품 재캡처로 처리하지 않았다.

manifest `df34c0f5391f29f54431a9686bace47f39f0cf3f764796b2d5fb3ea135dca90c`,
current11387/stale46·56·56/invalid73·7·7. JA 새numeric3, CN/TW pressure본문의
옛영문Mingi 새감지1씩. source7 추가로 미수용 정합대기63KO/수용0·고유KOEN135.
callback44 생일/지속SNS·54 정확인용은 원생산자에도 미보장인 기존 후월 부채다.
실제M17 OS잠금HOLD·엔진/native/새월0·본편/5언어INCOMPLETE/인간OPEN45/출시HOLD.
601과602선언 CI 조회시 in_progress, 새push 미확정. 일회성/승격0·현황판 단독후속0.
