# ORDER-598 — M24 다은 돈 대화의 투자 실적 발명

#### [~] ORDER-598 [정합] 생산자·12주 회수 KO/EN 수리 — 2026-10-13

사용자 위임의 잠금 중 월순서 KO/EN 검토. 직전597 수리 뒤 M24의 다른
확정 결함을 처리한다. 실제월은562/M17 하나만 HOLD, 해제 즉시 원559 W68 우선.

## 근거와 판단

MainGame:7315–7320 및 story_rules:1054는 W95와 다은 선택/놓아주지 않음만
요구한다. 투자·배당·수익 조건은 없다. 그런데 arc_daeun_money_gap 본문은
배당을 받고 선택1은 투자 성공을 말하며 callback_told_daeun_investing_echo는
그 대사와 수익/손실 보유종목을 회상한다. 독립 사전 판독도 같은 반례를 확인했다.

1. 그대로 두면 투자하지 않은 경로에 거래·성과·보유자산을 발명한다.
2. 조금/전부 공유하기 또는 숨기기의 기존 차이·효과·12주 회수는 유지한다.
3. 이미 결제한 커피 알림과 실제 잔고·지출, 돈에 관한 고민으로 신뢰 갈등을 남긴다.
   새 대사를 구저장이 했다고 직접 인용하지 않고 과거 돈 이야기의 간접 회상을 쓴다.

## 소유·정확 범위

- root content/events/arc_midgame.json 및 content/events_en/arc_midgame.json:
  arc_daeun_money_gap.description, choices[1].text/result_text 각3잎.
  KO choices[0].result_text 한 잎은 이미 커피를 낸 뒤인 만큼 다음 커피 약속으로
  정렬한다(EN은 이미 next time). 합계 KO4/EN3.
- root content/events/callback_events_44.json 및 EN counterpart:
  callback_told_daeun_investing_echo.description, choices[0/1].result_text 각3잎.
  돈 이야기를 조금 했다는 간접 회상/현재 잔고·지출/중립 숫자로 수리한다.
  총 KO7+EN6=13잎. callback43 전체공유 경로와 다른 사건은 불변이다.
- root tools/speech_register_audit.py: 위 두 사건의 바뀌는 required3와 대응
  forbidden3 대사만 정렬한다. 존댓말/반말 검사 자체·범위·횟수는 유지한다.
- 필요 release_content_inventory.json의 실제 내용 지문 및 공식 CONTENT_RATING
  보고, 큐2·이 사양/완료archive·WORK_LOG·CLAUDE 현재행만.
- m24_money_fact_review: .git/order598-20261013/independent-review.md만.
  rework_batch_plan: 같은 곳 preservation-review.md만.

GameState:2092의 구 event_log 선택문은 그대로 보존한다. 내부 flag명
told_daeun_investing/모든ID·효과/조건/12주지연/관계·저장·라우팅·원선택 인덱스는
불변이며 과거 투자 이야기도 돈 이야기의 부분집합이므로 간접 회상과 양립한다.
JA/zh 다듬기·원장 수용0, KO 변경7잎은 실제 KO/EN 확정 후 정합대기로 남긴다.
공개demo·사용자 저장/설정/project.godot·과거 인간 판정/5언어 유지.

## 검증과 완료

선언 commit/push 먼저. 직전597 공식after를 before로 재사용하고 새 inventory3으로
변경을 감지한다. EN coverage/Hangul·story consistency/continuity/spine·speech/
audio·i18n·demo scope/story/JA/ZH·release inventory·context/queue/diff를 확인한다.
독립13잎/구저장·생산자/독자 의미와 whole inverse·보호영역 일치, 표적새실패0 뒤 닫는다.
말투 검사 수정은 새 required/forbidden 세쌍을 모두 직접 읽어 강도 보존을 확인한다.
새 도구/검사/등록·전체audit/240주/엔진/native/장면추가/격상0. 기존 장면의 사실 수리다.
gangnamdream-dev/WORK_UNIT 적용·일회성/승격0. 자동검사는 인간·원어민·물리패드
증거가 아니며 실제월/전체5언어/본편출시 HOLD를 유지한다.
