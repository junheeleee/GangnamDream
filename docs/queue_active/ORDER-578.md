# ORDER-578 — 본편 10억 달성 안내의 목표 비율 오류

#### [~] ORDER-578 [정합·현지화] 착수 — 2026-10-13

clean main360f7c6b591fda642b04d1a11ca76ed2be536088/tree
ba814822e4b36909ecef311fcf0c298bb3269433에서 확인한 실제 표면 오류다.
사용자 위임 개발·품질 검수 및 ORDER-157의 KO 직접 현지화 원칙 안에서 처리한다.
CI38295629046 attempt1 조회는 in_progress/결론null, M17/562 OS잠금 HOLD 하나다.
새 월·엔진·실제 화면·잠금 우회/해제 재요청0이다.

## 깊이 3문·정확 범위

1. MainGame.gd:23377의 자산10억 알림은 30억 목표에 `절반 왔다`고 잘못 말한다.
   정상 _ready:398 → _refresh_all:9647 → _check_milestones:23362 경로이며
   total≥1,000,000,000·milestone1b 미수령 때 log/toast로 표시한다(:23382–23385).
   이를 빼면 거짓 진행률과 CN/TW 영어 fallback이 남는다. 실제 화면 관찰은0이다.
2. KO를 `⚡ 자산 10억 달성!`, EN을 `⚡ Assets reached 1 billion won!`으로 고친다.
   특정 목표 비율을 새로 고정하지 않고 달성 사실만 알린다. amount/id/순서/색/
   이미 받은 milestone·영수증·저장·24주 결과는 바꾸지 않는다.
3. JA 기존 `半分来た`도 같은 오류다. 새 KO키의 JA/CN/TW 각1만 직접 작성한다.
   기존 JA키는 고아 방지를 위해 제거하되 Git 원문/값·과거 원장을 보존한다.
   old key의 accepted는 세 언어 모두0, batch root0이다. 정상 도달이 확인된
   실제1쌍만 처리하며 추정15~25를 채우려고 legacy/V2 문구를 섞지 않는다.

## 소유·병렬 분리

- root: scenes/MainGame.gd 위 _tr 한 쌍만; locale/ui_ja.json 기존키 제거/새키1,
  locale/ui_zh-CN.json·ui_zh-TW.json 새키1씩;
  content/meta/full_game_localization.json 새 accepted3/checksum/UI batch1만.
- root: 큐2/이 사양(마감 archive)/WORK_LOG·CLAUDE 현재행, JA/CN KO 직접 저작.
- mod_layer_ci: 새 .git/order578-20261013/tw.response.jsonl·tw-draft-review.md만.
- manual_save_ci: 같은 private의 독립 source/공식receipt 전수 review만.
- rework_batch_plan: 같은 private before/final·정확 역치환/보존 review만.

기존 source와 인접 EN을 읽은 것은 공개하며 번역은 KO에서 직접 쓴다.
간번 변환0·EN 중역0. 다른 원문/값·게임상태·source code·project/presets·사용자/
공개 저장/설정·Human/과거 판정·공개데모/pin·retail언어·옛 raw/seed/app은 비소유다.
새 영구 tool/helper/checker/self-test/등록·479/481 비용최적화0이다.

## 순서·표적 검증

선언 commit/push → source 한 쌍만 별도 local commit → 실제 Git source manifest에
묶인 fresh JA/CN/TW exact1 export → 각 KO 직접 응답 → 비저자 전수 의미 GO →
공식 check/import --accept → JA old orphan 제거/원장 receipt 추가 순서다.
기존 accepted/batch 전부 보존, 원official header/digest를 portable 원장에 둔다.
source 변경은 독립 대조하고 번역 append-only/history gate로 대신 통과시키지 않는다.
현재 JSON span reader로 사전3/원장4 raw inverse, MainGame 정확1줄 inverse,
실제 source Gitmanifest·비소유/공개/사용자/옛577raw 불변을 검수한다.

audit_select --list로 영향만 조회한다. EN coverage·EN 한글·JA UI·ZH all·
i18n coverage·demo scope all·story demo·공식 locale inventory·context/queue/diff만
수행한다. source literal만 바뀌므로 엔진/컴파일/전체 audit/240주/변경 없는
self-test0이다. 새 제품 실패0·비저자 source/receipt/보존 GO 뒤 닫는다.
source/새 UI키의 hash 전이를 실제 수리로 기록하고 기존JA58를 전수오역으로 세지 않는다.

## 판정 경계

gangnamdream-dev/I18N의 직접 저작·비소유 보존·source/실관찰 분리를 적용한다.
일회성 모집단/소유/순서·새 규범 승격0. 자동 계약은 재미·깊이·문체·인간 관찰 GO가
아니다. 렌더/원어민/인간/물리패드 OPEN·전체 INCOMPLETE·출시 HOLD를 보존한다.
현재 앱에 수리가 반영됐다는 주장0이며 새 push CI는 실제 commit 뒤 따로 확인한다.
현황판 단독 후속0. 카지노 내추럴 도움말-모델 불일치는 유효 구경로의 별도 후속이며
이번 source/번역 수리에 섞지 않는다.
