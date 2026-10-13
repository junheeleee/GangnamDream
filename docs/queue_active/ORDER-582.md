# ORDER-582 — 바카라 내추럴 도움말의 잘못된 무승부 안내

#### [~] ORDER-582 [정합·현지화] 착수 — 2026-10-13

기준 main c5371ece56dd8d023222ac33b14ecdb9720302e9. ORDER-578가 남긴
카지노 내추럴 오류는 blackjack 배당 문제가 아니라 바카라 설명의 오류다.
JeongseonCasino._show_glossary:862는 양쪽 내추럴을 모두 무승부라고 쓰지만
Baccarat.play:49–79는 추가 드로우 없이 점수를 비교한다. 9 대 8은 승패,
8 대 8·9 대 9만 무승부다. 기존 게임 규칙·배당·입력·저장은 바꾸지 않는다.

## 깊이·범위

잘못된 설명을 남기면 플레이어가 실제 정산을 오류로 이해한다. KO/EN 한 쌍을
첫 두 장의 8/9, 추가 드로우 없음, 높은 점수 승리·동점만 무승부로 맞춘다.
JA도 기존 오설명을 새 KO키로 수리하고 고아 옛키1만 제거한다. CN/TW는
같은 설명과 현재 누락된 제목 `내추럴 (바카라)`을 KO에서 각각 직접 작성한다.
실측2 source단위/번역5만 처리하고 15~25를 채우려고 관련 없는 UI를 섞지 않는다.
구저장 카지노 용어 소비 경로의 source 증거이며 정상 본편·실제 화면 증거가 아니다.

## 파일 소유·순서

- root: scenes/JeongseonCasino.gd 해당 KO/EN literal 한 쌍;
  locale/ui_ja.json 설명의 old키1/new키1;
  locale/ui_zh-CN.json·locale/ui_zh-TW.json 제목/설명 각2;
  content/meta/full_game_localization.json 새 accepted5/checksum/batch/source-change만.
- root: 큐2·이 사양/마감 archive·WORK_LOG·CLAUDE 현재행, KO/EN/JA/CN 저작.
- mod_layer_ci: 새 .git/order582-20261013/tw.response.jsonl만 KO 직접 저작.
- manual_save_ci: 같은 private의 비저자 source/공식receipt 검토 보고서만.
- rework_batch_plan: 같은 private before/final·보존 보고서만.

선언 commit/push → source literal만 local commit → 실제 Git source manifest에
fresh JA1/CN2/TW2 export → KO 직접 응답·비저자 전수 검토 → 공식 check/import
--accept → oldJA orphan 제거·portable 원장 추가 → 표적검증·독립 보존 → 마감/push.
소스 변경은 append-only proof로 수용하지 않는다. 원official header/digest와
기존 accepted/batch를 보존한다. 새 helper/checker/selftest/등록·479/481 작업0.

## 검증·경계

기존 audit_select --list로 영향 조회만 한다. EN coverage·EN 한글·JA UI·ZH all·
i18n coverage·demo scope all·story demo·locale inventory3·context/queue/diff와
정확한 runtime literal inverse/사전·원장 비소유 보존을 확인한다. 규칙/스키마/장면
변경0인 텍스트 수리이므로 엔진·전체 audit·240주·변경 없는 selftest 반복0이다.
새 실패0·비저자 의미/receipt/보존 GO 전에 완료하지 않는다.

project.godot·사용자 저장·공개 M01~M06/데모 pin·retail언어·과거 인간 판정·
옛 raw/seed/app은 비소유다. c5371ec CI는 조회 당시 in_progress/결론null,
M17/562 OS잠금 HOLD 하나이며 새 월/실제 화면/해제 재요청0이다.
gangnamdream-dev/I18N의 직접저작·정확소유·source/실관찰 분리를 적용한다.
일회성 오더 범위·새 규범 승격0. 렌더/원어민/인간/물리패드 OPEN·전체
INCOMPLETE·출시 HOLD를 보존하고 내부 수리를 출시 승인으로 확대하지 않는다.
