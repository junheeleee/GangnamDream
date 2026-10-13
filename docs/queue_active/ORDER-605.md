# ORDER-605 — 재혁 정산대기의 지급일·경과시간 발명 수리

#### [~] ORDER-605 [정합] KO·EN 8잎 — 2026-10-13

603·604 source 마감 뒤 잠금 중 월순서 사실수리. map M29 wait는 현재 MainGame
fallback t106~114로 M27~29에도 들어온다. 실제월562/M17 HOLD 하나 유지,
OS해제 시 원559 W68 실제플레이 우선·CI빨강 새월0·JAzh다듬기/수용0.

## 근거·깊이 3문

pitch 투자2선택은 -300만/-100만과 투자flag/예약2를 함께 남기고 wait fallback은
pitch_seen+trusted/partial을 요구한다. 따라서 이미 넣은 돈은 보존한다. 반면
'이번 주까지 자리'는 지급기한이 아니며 정산일 다음주/한달 연락공백/3주전 메시지는
생산자에 없다. 예약2도 min_turn9999 deferred필터와 fallback 때문에 실제2주 발화
실측이 아니다. 고정기간 대신 지금 연락을 기다리는 행동과 불안으로 바꾼다.
선택1 즉시결과에 일주일 경과를 쓰지 않는다. 현재화면/손/기다림의 소진으로.
현재선택0의 1~3시간 기다림·선택2의 5분답장과 실제투자/금액/효과는 그대로다.
후속 현수경고 delay2는 특정 지급일을 읽지 않는다. ghost DIK의 대면+다음달 약속은
기존 후월부채, callback54의 '사기당한 뒤 연락'은 현재입구 없는 dormant 원문부채다.
min56+flag만으로 노출을 주장하지 않으며 새 소비자/시간·금융시스템을 만들지 않는다.

## 정확 소유·검증

root content/events/arc_midgame.json 및 events_en 동명, arc_jaehyuk_wait의
 title/description/choices1.text/choices1.result_text 각4=8잎(KO4/EN4)만.
placeholder·본문5문단/결과2문단 보존·다른선택/배경·효과/flag·조건·예약·저장 불변.
필요한 현재 release_content_inventory 실제후보지문·공식보고만 정렬, 공개핀 불변.
큐2/이사양/archive·WORK_LOG·CLAUDE현재행도 root소유. 기존 원장/CJK 수정0.
m24_money_fact_review는 .git/order605-20261013/independent-review.md만,
rework_batch_plan은 같은경로 preservation-review.md만. root는 독립보고를 쓰지 않는다.
선언 commit/push 뒤 적용·audit_select --list·기존source13 actual0·603after3→
공식inventory3 비교·독립8잎/wholeinverse·비소유/공개데모 보존·context/queue/diff.
새전체audit/엔진/native/도구0·사용자파일/project/공개/과거인간판정 보존.
gangnamdream-dev/WORK_UNIT 적용·일회성/승격0. 출시5언어유지/CJK일괄정합은
KO/EN 실제확정 뒤다. source GO를 실제/인간/원어민/물리패드/본편/출시 GO로 쓰지 않는다.

