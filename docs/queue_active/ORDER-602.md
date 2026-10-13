# ORDER-602 — M26~27 달력·즉시 결과 시간 사실 수리

#### [~] ORDER-602 [정합] KO·EN 17잎 — 2026-10-13

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
