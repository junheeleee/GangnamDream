# Closed Queue Spec: ORDER-678

> 우선순위·상태 정본: [CODEX_QUEUE](../CODEX_QUEUE.md).

#### [x] ORDER-678 [C5·시작 표면] Splash 문맥의 중국어 누락1키를 보충한다

## 대상·깊이

SplashScreen.gd:377의 LocaleManager.ui가 읽는 고정KO
"서울, 2026. 정답도 보장도 없다."는 JA에 있고 CN/TW에는 없다.
현재 영어폴백이며 빈문자/치명결함이라고 세지 않는다. C5 5언어 본편 첫화면 준비의
누락2값만 보충한다. retail은아직KOEN, 실제5언어화면/출시가완료되는것은아니다.

1. 삭제하면 중국어 두지역의 시작문구가 영어폴백으로 남는다.
2. 상태변화0: source/연도/배경/본문/저장/선택/retail언어목록은 불변이다.
3. 기존13px Label 한 문장과 경쟁한다. 새label/문장/효과/화면설계가 아니라
   기존KO의 서울·2026·정답/보장없음을 각각 직접번역한다.

## exact 소유·수용

- root: locale/ui_zh-CN.json, locale/ui_zh-TW.json 신규위1키씩,
  content/meta/full_game_localization.json accepted2·UIbatch1 append만.
  JA사전은 네파일proof의 불변입력이며 새값/기존값수정0.
- a1_data_content: .git/order678-splash-context/zh-response.json/.md만 지역별직접저작.
- 비저자 a1_qa_release_audit: 같은private copy-review*/final-review*만. source소비자,
  번역2값·날짜/지역자형/대상Git·append보존을전수읽고판정, 제품/Git/engine쓰기0.
- root: 큐2·이사양/archive·CLAUDE현재행·WORK_LOG새앞부분, 같은private
  before/leaf-ID/source/response/receipt/검사·proof기록. 새checker·도구/예외0.
  pending612사양/큐overlay·월로그suffix3555B는보존/stage제외.

공식export를 두target이실제없는 상태에서 먼저 만든다. 쉼표가있는KO키이므로
기존 --leaf-ids JSON을 쓴다. 독립KO대조뒤 check/import하고 원본영수증을
sourceGit revision/manifest와결속해accepted/batch와같이커밋한다.
기존 ui_translation_append의 CURRENT_PATHS 네파일 raw inverse/실제Git source
census·first-parent전이를확인한다. ZH audit/i18n coverage/publicdemo82/121과
context/queue/diff만표적실행한다. source/engine/UI변경0이므로 Compile/월play/
전체audit/240주/새selftest·등록·기준선변경을돌리지않는다.

KO/EN/JA 및기존중국어/원장·project/LocaleManager/공개demo/사용자저장·설정·
인간판정을보존한다. 실제Splash렌더/글꼴/넘침/native/원어민·C1/C2/C3전체·
retail5언어/C4/C5전체/외부Steam/출시GO0. Mac해제시같은612/M18부터복귀한다.
승격0(기존I18N/C1~C5소유), 소유/배치/검증은일회성이다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

## 2026-10-15 수용 — 누락2값만

선언900c0c34c055682ac14acd7aaf0739eefd91c2fa/tree f9b15503415133c2f40d9f760ea2d6d7dc8d0eef,
제품c3a54ed5374afbafe3bb96bed6d569afe0794721/tree fd09b2850c75048342b817b4bd2b20858d41e5fb.
CN "首尔，2026年。没有标准答案，也没有保证。" /
TW "首爾，2026年。沒有正確答案，也沒有保證。"를 KO에서 각각 직접저작했다.
서울/2026/정답과보장부재를보존하고 효과/숨은규칙/새장면/기존번역다듬기0.

official export2는 실제missing-target 상태에서 만들었고 check2/import2 actual0,
신규UI2/accepted2·batch331→332만 수용했다. current_proof 네파일full rawinverse,
실제Git source census b8fac880399ade9b7f0582783d1792fc8090386b81f89e78a9adc45bade33540,
first-parent 전이1·JA0/CN1/TW1·기존331batch/accepted/비소유top-level exact를 확인했다.
source2/JA/project/LocaleManager/human/agent/612 보호8·suffix3555B·player33files exact.
ZH audit/i18n coverage/publicdemo82/121 실제3표적0. 메타context/queue/diff 통과,
source/engine/UI/언어allowlist변경0으로Compile/전체audit/240주/새tool·예외0이다.

비저자 GO_ORDER_678_FINAL_PRODUCT_ONLY, private final-review.md5174B/
SHA353c479b1ee89217adce44f2e63d369d0eba6da10c5ebd83ec272199c83a958d,
final-review.json7809B/SHA8c003aede6a10c39bde46c369ab229ab95923fc28ea3647a1daba4a7b17e6273.
history-proof.json852B/SHA797be9669f71650eafc0aeef488464bf3bf7e340e9986bf687bd5a7f5cb93e61,
preservation-proof.json4086B/SHA683baa0d08def9e3a4c8958ce39b2f4551258fc2d76662fbc37c5fa50db3a2d5.
root보고전문·actual17핀/Git identity 대조. 초기선언EOF빈줄과index가정재시도는
setup-diagnostics에보존하고제품착수전수리했다. checker/기준선/등록/CI예외변경0.

게임원문/KOEN/JA·UI설계/저장·공개demo/인간판정 불변,612overlay4는stage제외했다.
Mac잠금/같은M18 app14.3 유지/새월0. actualSplash렌더/폰트/폭/native·원어민,
retail5언어/CIgreen·C1~C5전체/외부Steam/출시GO는없다. 영어폴백누락을빈문자
치명결함으로세지않았으며소규모C5준비만닫는다. 개발스킬의KO직접번역·독립검수·
표적/보존적용,새규범승격0/일회성이다.
