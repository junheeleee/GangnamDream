# ORDER-601 — 다은 관계 기간과 현재 주거 사실 수리

#### [~] ORDER-601 [정합] M24 이후/ M25 입구 KO·EN 17잎 — 2026-10-13

600 완료 뒤 사용자 위임 잠금 중 월순서 사실 수리. 실제월562/M17 HOLD 하나.
Mac 해제 시 원559 W68 실제 M17 우선, CI빨강 새월0.

## 근거·깊이 3문

- 05는 MainGame:7872 t>=96/close_bond, year3는 :8513 t>=100/close_bond 또는
  together_path다. max_turn/계절/첫만남일/고백경과/공동통근/주거종류를 검사하지 않는다.
  첫만남 W10~12 또는 t>=12와 고백 t>=86, 옛저장 복구 모두 고정연수와 양립하지 않는다.
  W96은 다른 장면 우선이라 실제05 표시주차라고 주장하지 않는다.
- 그대로 두면 겨울이 아니어도 겨울, 만난 지 딱2년/연인몇달·몇계절, 함께출근하던
  지하철, 현재 아파트가 발명된다. 선택의 안정/솔직한 회상/고충, 방문·함께먹기·
  어깨기댐은 살려 오늘 주거 안 행동으로 고친다. 투자화면을 보는 것은 거래실행과
  같지 않고 셋방/작은방만으로 강한 반례가 아니므로 불필요한 전체 윤문은 하지 않는다.
- 24주 뒤 stable/knows_struggle/daily_life/honest_together/married 독자가 읽는
  상태는 unchanged. 관계경제/혼인/이사/타이머 새시스템0, 선택과 후속 의미를 보존한다.

## 파일 소유·정확 범위

- root content/events/arc_daeun.json + EN: arc_daeun_05_together title와
  romance DIK만 각2=4잎. 계절없는 저녁 제목, 몇달을 기간없는 연인 표현으로.
  공개 firstmeet/기본본문/선택과 효과는 그대로다.
- root content/events/arc_daeun_extension.json + EN: year3_together title,
  description, choice1 text/result, romance DIK 각5=10잎. 정확연수/경제성과 단정
  제거·기억/현재 안부로, 통근 회상 대신 방안의 라면/대화·기댐 유지.
  KO background apartment→기존 current_housing 한 값(동적배경/음향 resolver 재사용).
  apart description KO/EN2잎 및 EN choice0 result의 KO에 없는 two years 문장1잎.
  합계17잎(8KO/9EN)+주거1. flags/조건/DIK key순서/효과/라우팅/예약 unchanged.
- root tools/speech_register_audit.py year3_together required2/forbidden2만
  새대사로 정렬, 존대 보호강도·검사개수/로직은 그대로. 새검사/등록/도구0.
- 필요 release_content_inventory 실제내용 지문 및 공식 CONTENT_RATING 보고,
  큐2/이사양/archive/WORK_LOG/CLAUDE 현재행. 그외 제품문서0.
- m24_money_fact_review: .git/order601-20261013/independent-review.md만.
  rework_batch_plan: 같은 곳 preservation-review.md만. root는 그 보고 안 쓴다.

## 검증·경계

선언 commit/push 후 구현. 기존 source13표적+event_visual_contract=14 actual0.
600 공식after3 재사용→601 official inventory3 비교로 바뀐KO8잎과 미수용 부채 기록.
비저자 전17 의미/분기·wholeinverse·비소유/데모 검수 후 context/queue/diff 마감.
공개M01~M06 이벤트 raw/의미·원장·CJK·project.godot·사용자저장/설정·인간판정 보존.
현재 demo scope는 보호72사건/467잎 계약이며 같은 파일의 full-only05만 바꾼다.
JAzh 다듬기/수용0·실제KOEN 확정뒤 정합대기. 전체audit/240주/엔진/native/새월0.
gangnamdream-dev/WORK_UNIT 적용, 기존 장면 사실수리·격상0·일회성/승격0.
자동검사는 계약 증거이지 재미/인간/원어민/물리패드 관찰 또는 출시 GO가 아니다.
