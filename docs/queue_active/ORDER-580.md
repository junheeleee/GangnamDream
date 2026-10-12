# ORDER-580 — 첫 월급·투자 거래 조건 안내 중국어

#### [~] ORDER-580 [현지화] 착수 — 2026-10-13

clean main01140a9cd51e1e4aa78c3f65af82811524ef1c93/tree
bbd98ab0c05e6ae8b9d6c9256fb0a2aeabe17545의 실제 CN/TW 누락1키다.
ORDER-157/사용자 전체 번역 위임 범위다. CI38309378791은 조회 당시
in_progress/null·OS잠금 True·M17/562 HOLD 하나다. 새월/엔진/native0다.

## 깊이 3문·소비자

1. KO `첫 월급 수령! 투자 거래 조건을 갖췄습니다`의 CN/TW 값·accepted는
   모두 없다. 방치하면 해당 조건에서 준비언어 UI가 EN fallback으로 표시된다.
2. FullStoryFlow 소유 MainGame:709–710의 월말 → :9032 이전급여 여부 →
   GameState:1690–1691 payable_income>0 → MainGame:9042 false→true 및 :9044
   guidance true → :9045 _tr/:9046 toast → :6505–6508 → NotificationToast:27–28
   label이다. show_summary=false는 모달만 건너뛴다. guidance 생산3은
   arc_events:512/527/539, MainGame:7839–7843 직접선택과 :6952–6955 full-run
   비압축 경로다. random draw 비활성 표식과 직접선택을 혼동하지 않는다.
3. 급여 이후 guidance를 봐도 이 toast가 소급되지 않는다. 실제 시점/빈도/
   후속장면과 화면 겹침은 미관찰이다. 투자 실행·이익·순현금 증가를 보장하지
   않는다. 선택/효과/24주 결과 차이0·실제 안내 번역이며 새 행동이 아니다.

## 정확한 소유·비소유

- root: locale/ui_zh-CN.json·locale/ui_zh-TW.json에 위 신규1씩, content/meta/full_game_localization.json
  accepted CN/TW각1·공식 receipt header/digest의 UI batch1·checksum만.
- mod_layer_ci: 새 .git/order580-20261013/tw.response.jsonl·tw-draft-review.md만.
  KO에서 독립 작성한다. root가 공식 export 뒤 파일 소유를 넘긴다.
- root: 같은 private CN response/draft와 큐2/이 사양/마감 WORK_LOG·CLAUDE 현재행.
- manual_save_ci: 새 private 독립 KO/응답/공식receipt 전수검수만.
- rework_batch_plan: 새 private before/final·4원본 exact inverse/비소유 보존만.

KO/EN/runtime·기존JA·CN/TW옛값/원장/배치·project/presets·사용자/공개 저장설정·
Human/과거판정·공개demo/pin·retail언어·옛579raw/seed/app은 비소유다. CN/TW는
KO에서 각각 작성·중역/간번변환0, 인접 EN/JA/기존CN/TW 노출은 숨기지 않는다.
검사/helper/tool/self-test/등록 변경·479/481 비용최적화0다.

## 순서·검증·판정

선언 commit/push → immutable before → fresh official CN/TW exact1 export →
독립 KO 직접 저작·비저자 전수 GO → official check/import --accept → 원official
header/digest/accepted의 portable 원장 추가다. 기존 ui_translation_append의
4파일 pure validate_append·raw inverse와 실제Git source census를 쓴다.
기존 helper 재사용·새 영구 도구0, 기존322batch/모든accepted를 exact 보존한다.

audit_select --list 영향조회만; ZH all·JA UI(비소유)·i18n·demo scope all·story demo·
공식CN/TW inventory·context/queue/diff 표적이다. EN은 KO/EN/runtime exact와
직전578 actual0로 귀속한다. CN/TW static2021→2022/2980·missing959→958·invalid0,
JA57 unchanged·source17504/unsupported466/manifest9680…fb5d 불변이어야 한다.
새실패0·독립 의미/receipt/보존 GO 전 완료0·전체audit/240주/엔진/self-test 반복0다.

규범·소유·단위·순서는 일회성/승격0이다. gangnamdream-dev/I18N 직접저작·
비소유 보존·기계/실관찰 경계를 따른다. 조건부 소스소비자와 실제노출 GO는
별도다. 렌더/원어민/인간/물리패드 OPEN·전체 INCOMPLETE·출시 HOLD·M17 OS잠금
HOLD 하나를 유지하고 실제 commit/CI는 마감 후 별도 private에 기록한다.
현황판 단독후속0·자동계약은 재미/깊이/문체/인간관찰 GO가 아니다.
