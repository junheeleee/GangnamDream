# ORDER-577 — 일본어 경마 전적의 출전·승리 의미 교정

#### [~] ORDER-577 [현지화·UI] 착수 — 2026-10-13

ORDER-157의 전체 번역 위임 안에서 KO `0전 0승`의 기존 JA 값 하나만 고친다.
기준 clean main b8021277db6a7791901fd399967193e6f762930a/tree
856eb38b25f4e69b663c5c776b53b6e0e6d82c6d다. CI38289392492 attempt1은
조회 시 in_progress·결론 null이다. M17/562는 OS잠금 HOLD 하나, 새 월0이다.

## 깊이 3문·범위

1. RaceTrack.gd:456의 `horse.record` 부재 fallback은 출전0/승리0인데
   ui_ja.json:150의 `0勝0敗`는 승리0/패배0을 말한다. KO에서 `0戦0勝`으로
   직접 교정한다. HorseWorld.gd:119의 `%d전 %d승`/`%d戦 %d勝`는 이미 맞다.
2. 선택·효과·가격·정산·24주 결과·저장은 바꾸지 않는다. 현재 상태 설명이다.
3. 정상 HorseWorld는 record를 생성하므로 방어적 대체 문구 수리 한정이다.
   실제 정상 노출·새 번역 coverage·월별 실제 관측으로 세지 않는다.
   하나의 확인된 의미 결함을 15~25 추정에 맞춰 늘리지 않는다.

## 소유·비소유

- root: locale/ui_ja.json 위 기존 값1개, content/meta/full_game_localization.json
  해당 첫 accepted 또는 기존 receipt 교정·checksum·별도 ui_correction batch1만.
  기존319 batch/공식 receipt는 보존하고 previous target hash를 새 기록에 결속한다.
- root: 큐2/이 사양(마감 archive)/WORK_LOG·CLAUDE 현재행, KO 직접 저작.
- manual_save_ci: 새 .git/order577-20261013/의 독립 의미·공식 영수증 보고만.
- rework_batch_plan: 같은 새 private before/final 보호·정확 역치환 검수만.

KO/EN/CN/TW·runtime·source manifest·조건/효과/플래그/가격·project/presets·
사용자/공개 저장/설정·Human/옛 판정·공개데모/pin·retail 언어·옛 raw/seed/app은
비소유다. 새 영구 tool/helper/checker/self-test/등록·479/481 비용최적화·전체
audit/240주·엔진/컴파일/native/새 월0이다. OS잠금 우회/해제 재요청0이다.

## 수용·검증

선언 commit/push → fresh 공식 exact1 export → KO 직접 응답 → 비저자 의미 검수 →
check/import --accept --replace-existing 한다. 이전 target hash·source/새 target·
원official header/digest를 별도 correction 기록으로 묶고 기존 이력은 보존한다.
기존키 수정은 append-only proof로 통과시키지 않는다. 기존 JSON span parser와
Git blob로 정확1값+원장 owned delta만 역치환했을 때 before 전체 바이트 복원을
독립 검수하고 비소유/보호/옛576 raw 불변을 확인한다. 새 helper는 만들지 않는다.

named full-game-localization-overlays 차선은 목록만 조회한다. 영향 표적은 JA UI·
i18n coverage·demo scope all·story demo·공식 JA inventory·context/queue/diff다.
ZH 및 EN/한글은 직전576/575 actual0와 CN/TW/KO/EN/runtime byteexact로 귀속한다.
기존 verifier·collector 불변이므로 변경 없는 self-test/전체 감사는 반복하지 않는다.
새 실패0·비저자 source/receipt/보존 GO 뒤 source 교정만 닫는다.

## 판정 경계

원어민·렌더·인간·물리패드 OPEN·전체 번역 INCOMPLETE·출시 HOLD 유지.
현재 앱에 이 교정이 들어갔다고 주장하지 않는다. 실제 commit/push CI는 별도
확인하고 현황판 단독 후속0이다. gangnamdream-dev/I18N 직접 저작·비소유 보존·
source/실관찰 분리를 적용한다. 모집단/소유/검증 일회성·새 규범/승격0이다.
자동 계약은 재미·깊이·문체·인간 관찰 GO가 아니다.
