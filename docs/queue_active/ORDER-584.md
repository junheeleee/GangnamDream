# ORDER-584 — 구저장 월 상황판의 시간·거처·계절 중국어

#### [~] ORDER-584 [현지화] CN/TW21키씩 착수 — 2026-10-13

기준 clean main51f7ab19e20081ec79570bcc3029fb7a654b0e6c/tree
079fbd1dd46dcb6291dcb8a63a4e4b6669c8a231. 현재157 위임의 supported UI 누락을 잇는다.
비저자 탐색으로 MainGame._month_narration:11826–11879의 경과개월5·거처4·
계절12 exact21을 확인했다. 모두 ui_static_context/supported/unprotected·JA존재·
CN/TW부재다. 581 주간 소리/시각과 겹치지 않는다. 실측 한 묶음만 처리한다.

## 깊이·범위·소유

1. 누락을 두면 구저장 AP 월상황판이 영어 fallback으로 남는다.
2. _render_ap_actions:10577 → _week_opening_line:11689 → _month_narration:11757
   → _tr:476/LocaleManager.ui:212 → lines:10615/_type_text:10646이다.
   FullStoryFlow:10578·scene_first:10601 조기반환 및 선행 위기/관계/자산 반환을
   보존하며 정상 본편 노출이나 실제21조건 도달을 주장하지 않는다.
3. 선택·24주 상태·계산·조건 불변이다. KO의 경과/잔여 시간·1.5평·추정/확정·
   관찰의 강도와 %s/문단을 지역별 직접 번역한다. 새 인과/사실은 만들지 않는다.

- root: locale/ui_zh-CN.json·locale/ui_zh-TW.json 해당 새21키씩만;
  content/meta/full_game_localization.json accepted42/checksum/새 UI batch1만.
- root: 큐2·이 사양/마감 archive·WORK_LOG·CLAUDE 현재2행·새 private 실행자료.
- mod_layer_ci: 새 .git/order584-20261013/tw.response.jsonl만 KO 직접 저작.
- manual_save_ci: 같은 새 private의 비저자42 전수 source/receipt 보고만.
- rework_batch_plan: 같은 새 private before/final/보존 보고만.

KO/EN/runtime/JA·조건/게임플레이·project.godot·저장·공개 M01~M06·옛 raw/앱/
seed/인간 판정·retail언어는 비소유다. 새 Blackjack provider/번역은 이번 범위0이다.

## 순서·검증·한계

선언commit/push → immutable before → 공식 exact21 fresh export×2 → KO 직접
CN/TW 분리 저작 → 비저자42 전수 대조 → 공식 check/import --accept×2 →
원official header/digest를 보존한 portable 원장 append → 표적/독립 보존 →
context/queue/diff·마감commit/push → 현재 Git append proof/새CI 한 번 확인이다.
공식 source manifest98664e3985186e7173cfa8cde576aec6136f41f756cf185699d5020cd81177cb는
불변이어야 하며 기존325batch/모든accepted·사전 old members/order/bytes exact다.

기존 selector --list 조회만; ZH all·JA UI·i18n coverage·demo scope all·story demo·
CN/TW official inventory와 기존 ui_translation_append 현 후보 proof를 쓴다.
EN 검사2는 선언 clean 상태 actual0 뒤 KO/EN/runtime exact로 귀속하고 변경 없는
반복0이다. 새 실패0·독립 GO 전 완료0. 새 helper/checker/selftest/등록·엔진/
전체 audit/240주/479·481 후속0이다. 가져오기 정규화는 exact inverse로 복원한다.

gangnamdream-dev/I18N의 KO 직접 저작·소유 보존·source/실관찰 분리를 적용한다.
일회성/승격0·Maclockedtrue·M17/562 HOLD 하나·새월/해제 재요청0이다.
기준51f7 CI38331629727은 정적job success/엔진 audit in_progress, transport500은
원자료 보존 후 한 번 재시도했으며 취소/재실행0이다. 렌더/원어민/인간/물리패드
OPEN·전체 INCOMPLETE·출시 HOLD·종료resource/Presence 잔여를 유지한다.
