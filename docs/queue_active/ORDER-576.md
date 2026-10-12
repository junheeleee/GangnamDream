# ORDER-576 — 경마 화면의 중국어 빈값 안내

#### [~] ORDER-576 [현지화·UI] 착수 — 2026-10-13

ORDER-157의 전체 번역 위임 안에서 RaceTrack의 KO2키/CN·TW4개만 수용한다.
기준 clean main424a1b171696498b60fbc89910d40c7435e817b2/
treeaca23222d6403275684f84b0df4cd2715e79cb93다. CI38286178784 attempt1은
17:51 UTC 조회에서 in_progress다. 새 월/엔진/실제 입력0, M17/562 하나는
OS잠금 HOLD로 유지한다. 사용자에게 해제를 재요청하지 않는다.

## 깊이 3문·정확 모집단

1. 빼면 기존 RaceTrack 방어적 빈값 안내 두 곳이 CN/TW에서 EN으로 폴백한다.
   MainGame:18041~18051의 full-story activity 입구→RaceTrack.open→기존 _tr→
   LocaleManager.ui 독자는 있지만, 아래 fallback 조건의 실제 정상 플레이 도달을
   주장하지 않는다. native/새 월 확인이나 본편 노출률로 세지 않는다.
2. 기존 상태를 설명할 뿐 선택/24주 결과/가격/정산/저장을 바꾸지 않는다.
   `0전 0승`은 출전0·승리0이지 패배0이 아니다. `선택 없음`은 선택 부재다.
3. 기존 경마 주 안내는 이미 번역돼 있어 반복 수용하지 않는다. 실제 누락2개를
   15~25로 채우기 위해 중복·소비자 미확정·휴면 문구를 섞지 않는다.
   WORK_UNIT의 첫 배치 크기 추정과 판정 가능한 단위 원칙에 따른 작은 수리다.

| exact KO key | 소비자·조건 |
|---|---|
| 0전 0승 | scenes/RaceTrack.gd:456 _render_betting, horse.record 부재 fallback |
| 선택 없음 | scenes/RaceTrack.gd:1225 _pick_summary_text, race.horses 부재 fallback |

두 키의 JA 행은 존재하며 비소유다. 기존 JA `0勝0敗`의 출전/패배 의미 차이는
이번에 발견한 별도 기존 결함이며 이 CN/TW 추가로 고쳤다고 하지 않는다.

## 파일 소유·경계

- root: locale/ui_zh-CN.json·ui_zh-TW.json 위 신규2키와
  content/meta/full_game_localization.json accepted/checksum/UI batch1만.
- root: 큐2/이 사양(마감 archive)/WORK_LOG·CLAUDE 현재행, CN KO 직접 저작.
- mod_layer_ci: 새 private tw.response.jsonl/draft-review.md, TW KO 직접 저작만.
- manual_save_ci: KO2/번역4/원receipt/실제 caller 독립 전수 검수만.
- rework_batch_plan: 새 private before/final·비소유 보존·4파일 exact inverse만.

KO/EN/JA·runtime·조건/효과/플래그/가격·source manifest·project/presets·검사/
collector·공개데모/pin·출시언어·사용자/공개 저장/설정·Human/과거 판정·옛 raw/
seed/app 비소유다. 영구 tool/helper/checker/self-test/등록·479/481 검증비용/
최적화·전체 audit/240주·엔진/컴파일/native/새 월0이다.

## 수용·마감

선언 commit/push 뒤 official export/check/import --accept로 신규 잎만 처리한다.
CN/TW previous null·protected=false, 기존 JA와 원문 불변을 확인한다.
KO에서 지역별 독립 저작하며 root의 인접 EN 노출은 공개한다. 중역·간번 변환0.
원receipt header/digest와 batch를 portable 원장에 추가하고 기존318batch/accepted/
사전 prefix·JA 포함4파일 exact inverse·실제 Git source manifest를 확인한다.
ZH/JA UI·i18n·데모·원장 inventory 및 context/queue/diff를 표적 검증한다.
EN coverage/한글은 직전575 actual0와 KO/EN/runtime byteexact 귀속으로 재실행하지
않는다. 변경 없는 자체검사 반복0, 새 실패0·독립 의미/receipt/보존 GO 뒤 닫는다.

before는 .git/order576-20261013/preservation-before.json 38533B/
dd0be51a9a488c73728730afff3d7fa321ccb2920c5e51604d75ead953d1b1d0에
선언 전 clean·제품4/비소유3359/보호54그룹951개로 봉인했다. 이후 선언 metadata와
구분한다. 예비 읽기 진단의 Entry.calls AttributeError1·없는 조사 파일 rg 오류1은
제품/게이트 실패가 아니며 검사·제품 수정으로 숨기지 않는다.

gangnamdream-dev/I18N의 직접 저작·비소유 보존·source/실관찰 경계를 적용한다.
모집단·소유·검증은 일회성, 새 규범/승격0이다. 자동 계약은 재미·깊이·문체/
인간 관찰 GO가 아니다. 렌더/원어민/인간/물리패드 OPEN·전체 INCOMPLETE·출시 HOLD다.
