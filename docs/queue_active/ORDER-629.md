# ORDER-629 — M37 영수증 회고가 발명한 생활 이력 수리

#### [~] ORDER-629 [정합] 약속 거절·짧은 통화·검진 미룸 단정 — 2026-10-14

Mac 접근 보류 중 최신 사용자 지시의 KO/EN 월순서 사실 점검이다.
실제 M18/612 하나는 그대로 열어 두며 새 월 플레이를 시작하지 않는다.
5개 출시 언어 유지, JA/zh 다듬기·수용0·누락만 원칙을 유지한다.

## 근거·깊이 3문

`scenes/MainGame.gd:8409`의 입구는 t148..160, goal_vertigo_seen,
미예약/미관측만 요구한다. 주말 거절·부모와 짧은 통화·검진 연기 이력이나
현재 건강을 검사하지 않는다. arc_goal_vertigo의 세 선택 모두 이 장면을
예약하므로 그 생산자도 해당 생활 사실을 보장하지 않는다.
그런데 arc_35_path_cost.description은 세 생활 이력과 지친 얼굴을 단정하고,
choice1 결과는 이전에 미뤘던 전화가 있음을 덧붙인다.
기존 선택의 대가 인정/현재 한 행동/답 없는 회고 경쟁은 유지하면서
확인되지 않은 과거를 지금 점검하는 질문으로 바꾼다.
장면 삭제는 path_cost_seen → habit_check의 독자를 끊는다.
24주 뒤 차이는 기존 embraced_cost/reclaimed_cost와 후속들이 소유하며
새 flag·수치·선택·체계를 추가하지 않는다.

## 정확 소유

root: content/events/arc_chapter_themes.json 및
content/events_en/arc_chapter_themes.json의 arc_35_path_cost만.
description 2잎에서 세 번째 문단을 현재 생활 항목을 살피는 질문으로 바꾸고,
choices[1].result_text 2잎의 미뤘던 전화는 현재 거는 전화로 바꾼다.
총 KO/EN 4잎, description 각4문단/name KO1·EN2·result 각1문단/name1 유지.
나머지 문단·제목·모든 선택text·효과·flag·deferred/조건·다른 사건은 byte exact.
release inventory 내용 지문이 실제 달라질 경우
content/meta/release_content_inventory.json의 해당 content hash와
docs/RELEASE_CONTENT_INVENTORY.md의 생성 지문 행만 기존 도구로 정렬한다.
번역 원장·JA/zh 원고·저장·원문 밖 런타임·공개 데모·project/preset/BuildInfo 불변.
root는 큐2/이 사양/archive/CLAUDE현재행/WORK_LOG만 메타 소유한다.
독립 검수자는 .git/order629-20261014/review.md와 review.json만 소유하며
추가 agent·engine·UI·Git·제품/정본 쓰기0이다.

612의 월별 metadata는 이번 선언/제품/마감 commit에 섞지 않는다.
기존 .git/order612-savefix-20261014/build/native의 핀·영수증과 발급 앱은 불변이다.
새 source commit은 그 native 준비의 inspection source guard와 달라지므로
옛 준비 GO를 새 HEAD native 허가로 쓰지 않는다. 재접근 시 같은 M18 앱 범위와
현 source 차이를 결속한 최소 이어보기만 준비하며 재빌드부터 반복하지 않는다.

## 검증·한계

실제 KO/EN 원문·입구·생산자·후속을 직접 읽고 4잎 전수 독립 검수한다.
Git 선언 전 base 대비 전체 JSON 역변환/비소유 바이트·문단/name·선택효과 불변 확인.
audit_select --list로 영향 목록만 확인 후 관련 기존 비엔진 source 검사만 실행한다.
release default가 실제 stale이면 원 실패를 보존하고 --write-report로 최소 정렬한다.
KO 변경으로 공식 JA/CN/TW inventory를 각각 한 번 관측하되 수용/write0이다.
context/queue/self/diff, STATUS advisory만 수행·STATUS 전용 commit0.
전체 audit·240주·native·새 월·검증비용/도구사업·새 checker/self-test0.
source 한정 판단이며 구저장 산문 migration0, 실제 월/5언어/인간/출시 GO가 아니다.
일회성 범위·새 정본 승격0.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
