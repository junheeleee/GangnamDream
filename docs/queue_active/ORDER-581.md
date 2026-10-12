# ORDER-581 — 구저장 주간 도입의 시간·거처 중국어

#### [~] ORDER-581 [현지화] 착수 — 2026-10-13

ORDER-157/사용자 전체 번역 위임. 기준 clean main377606e540ce9f4dc70ad490566a70188697b4f2.
MainGame.gd의 `_week_scene_anchor`(11711–11767) 21키(시간4·거처소리16·조립1),
CN/TW 각각 누락21·기존accepted0만 번역한다. 실제 본편 새 월/원문 저작이 아니다.

## 깊이 3문·소비자

- 방치하면 구저장 주간 도입 시간·거처 묘사가 EN fallback이다.
- `_render_ap_actions`:10578의 full-story 조기반환 및 scene_first:10601–10607
  뒤의 legacy 본문:10615 → `_week_opening_line`:11690 → anchor:11711,
  :10646 `_type_text`다. 정상 FullStoryFlow 노출로 세지 않는다.
- 주차1~4와 presentation housing이 기존처럼 시간/소리 한 쌍을 선택한다.
  gangnam→apartment/unknown→gosiwon 폴백 유지. 새 선택·상태·24주 효과0이다.

## 소유·순서·검증

- root: locale/ui_zh-CN.json·locale/ui_zh-TW.json 신규21씩,
  content/meta/full_game_localization.json accepted42/UI batch1/checksum만.
- root: 이 사양·큐2·마감 WORK_LOG/CLAUDE 현재행, 새 .git/order581-20261013/
  CN source/response·공식교환/검사 원자료. TW source는 root export 뒤 전달한다.
- mod_layer_ci: 새 private tw.response.jsonl·tw-author.md만 KO 직접 저작.
- manual_save_ci: 새 private independent-review.md만 비저자 전42 의미/receipt 검수.
- rework_batch_plan: 새 private before.json·final.json·preservation-review.md만 보존 검수.

선언 commit/push → immutable before → 공식 exact21 export2 → 독립 KO 저작/
비저자 전수 GO → check/import --accept → 원receipt header/digest 원장 추가 →
기존4파일 validate_append(raw inverse)·ZH all·JA UI·i18n·demo scope all·story demo·
CN/TW inventory·context/queue/diff. 영향목록은 audit_select --list만 쓴다.
원문/런타임 불변으로 EN은 직전578 actual0에 귀속하며 불필요 재실행0이다.

KO/EN/runtime/JA/기존값·원장·저장·project.godot·공개demo/pin·인간/옛판정·
옛raw/앱/seed 비소유. 새helper/tool/checker/self-test/등록·479/481 후속0이다.
템플릿 {moment}/{detail} 순서·소리 원인/횟수·집 종류 의미를 보존한다.
15~25단위의 자연스러운 기존 함수 묶음21이며 표본 대신 전수 검수한다.

규범/파일소유/단위/검증은 일회성·승격0. 자동계약은 재미/깊이/문체/인간 GO가
아니다. source/receipt만 닫고 렌더/원어민/인간/패드 OPEN·전체 INCOMPLETE·출시
HOLD 유지. CI38315970393은 조회당시 in_progress/null, Mac잠금true/M17 HOLD1·
새월/엔진/native/해제 재요청0. 새실패0/독립 GO 전 완료0·현황판 단독커밋0이다.
