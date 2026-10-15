# Active Queue Spec: ORDER-674

> 우선순위·상태 정본: [CODEX_QUEUE](../CODEX_QUEUE.md).

#### [~] ORDER-674 [C5·상점] 확정된 태그라인·짧은 설명의 세 언어 누락을 채운다

## 대상·근거

DECISIONS 2026-10-15 C5의 5언어 상점 설명 준비에 직접 기여한다.
STEAM_PAGE §2 태그라인과 §3 확정 A의 KO 원문에서 JA/CN/TW 각2값, 신규6값만
독립 작성한다. EN A의 four-pyeong만 KO의4.5평과 맞추어 4.5-pyeong으로 수리한다.
인게임 KOEN 확정 전 CJK 문체 다듬기는 재개하지 않으며 출시 준비용 누락만 채운다.
긴 About/폐기 B·C/§11 피치·이미지/메커니즘 설명은 번역·수리하지 않는다.
상점 초안이지 실제 Steam 등록·C5전체·5언어 retail 지원 완료가 아니다.

## 깊이 3문

1. 삭제하면 무엇이 깨지는가? 상점 태그라인·확정 Short A의 JA/CN/TW 준비물이 없다.
2. 플레이어 상태를 바꾸는가? 아니다. 게임·선택·저장·언어 공개와 무관한 문서다.
3. 무엇과 경쟁하는가? 짧은 판매 문안의 제한된 읽기 폭이다. 33세/무직/4.5평/
   50만원/5년/30억 목표·월별 시간/포기·아버지 무릎의 비공개 이유만 보존한다.
   원화와 한국 장소를 현지통화/주거로 치환하거나 성공/플레이 효과를 보장하지 않는다.

## 배치 — 누락6값과 EN 면적1교정

작은 C5 준비물 한 객체이며 15~25 추정치를 채우려고 불필요한 판매 문구를 추가하지 않는다.
한국어 확정 source2·신규값6·EN한값 교정을 전수 독립 검토한다. 단어/숫자와 문안
길이·빈값/한글/지역문자·다른절 raw 보존을 대조한다. 신규 영구 checker·전체audit·
engine/실제앱·사용자/OS설정 변경0이다. CI 실패·만료 예외가 확인되면 먼저 처리한다.

## exact 파일 소유

- root: docs/STEAM_PAGE.md §2에 JA/CN/TW 태그라인, §3 A에 JA/CN/TW 짧은 설명만
  추가하며 위 EN 면적1값만 교정한다. §3의 확정 A/폐기 B·C 상태와 나머지절 exact 보존.
- 일본어 저자 m46_48_fact_read: .git/order674-store-short/ja-draft.json·ja-author.md만.
- 중국어 저자 a1_data_content: .git/order674-store-short/zh-CN-draft.json,
  zh-TW-draft.json·zh-author.md만. 두 언어는 KO에서 각각 직접 작성, 자동변환0.
- 비저자 a1_qa_release_audit: .git/order674-store-short/review*.md/json만.
  source·최종6값·EN교정·비소유 보존 읽기 검수이며 제품/Git/검사·engine 쓰기0.
- root: 큐2·이 사양/archive·CLAUDE 현재행·WORK_LOG 새 앞부분 및 같은 private경로
  before/검사/후보/보존 증거. 게임 source/사전/번역원장/검사/인간원장 불변.
  진행중612사양과 WORK_LOG suffix3555B·큐612overlay는 마감commit에서 제외한다.

## 수용·한계·규범

원문 source commit/target 후보·보고 SHA, 독립 전수 품질·source 외 byte보존을 결속하고
기존 docs 표적/context/queue/diff만 실행한다. 한글/통화/지역문자는 기존 분류기를 읽기
재사용하며 새도구/규칙/기준선은 만들지 않는다. 기계 길이 측정은 실제 Steam 필드의
현재 허용 길이·렌더·게시 검증이나 원어민 GO가 아니다. 사람·상점·C1~C5/출시 HOLD.
source 규범은 STEAM_PAGE §1.5/발견 보존, I18N 용어집·최신 DECISIONS가 그대로 소유한다.
이 exact6값/배치/파일 소유·검증은 일회성, 새 정본규칙 승격0이다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
