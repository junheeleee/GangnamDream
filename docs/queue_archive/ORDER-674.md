# Closed Queue Spec: ORDER-674

> 우선순위·상태 정본: [CODEX_QUEUE](../CODEX_QUEUE.md).

#### [x] ORDER-674 [C5·상점] 확정된 태그라인·짧은 설명의 세 언어 누락을 채운다

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

## 2026-10-15 문안 준비 수용 — C5 전체 아님

| 항목 | 관측 |
|---|---|
| source | ef9bdb51aa8e8499ae4b662f2b2af8c558ee235b/tree ddf3003087019b3bffaf5cc25ed5e16a3034e29e |
| 선언 | a6acfb9f7cf274bbe73940054f31aacb267e6787 |
| 제품 후보 | 52591ab1d5793d515c26425b18e5ddd0cb584de2/tree451fe83dda7a1ab83711d5b8901c4724bb1d6b0f |
| 제품 차이 | STEAM_PAGE1경로·31추가1삭제·신규6값/EN면적1교정 |
| 문서핀 | 33183B/SHA0a74c1cc97bca89142e2266f0b16e0c5049383c16908ce90be997a9ef6444244 |
| 생산자↔독자 | STEAM_PAGE §2/§3A KO2 ↔ 같은 절 JA/CN/TW2각6 신규문안 |
| 상태 변화 | 각 CJK 태그라인/Short A0→2, 기존KOEN값중EN면적4→4.5평만교정 |
| 서사·장면계층 | 해당없음·상점상황카피·게임/선택상태변화0 |
| 독립 품질 | a1_qa_release_audit·6값+EN1교정 전수·GO_SOURCE_COPY_ONLY/차단0 |
| 원형 | 6값추가와EN교정을역변환하면oldSTEAM31613B exact; 다른제품경로diff0 |
| 표적 | existing release content/context/queue3 actualPASS·git diff check0 |
| 비소유 | project/LocaleManager/인간·에이전트원장/61211314B·suffix3555B exact |
| 닫는 것 | 확정 태그라인/Short A의3언어 누락6값·EN면적불일치만 |

중국어는 4.5坪 원형과 정확한 약15㎡를 병기했다(4.5×400/121≈14.876㎡).
이를 금지된 현지치환으로 읽은 초기 검수 전제는 근거를 확인해 철회했다.
일반 UI 숫자 검사는 보조15를 추가 숫자로 진단하므로 short2값의 generic PASS는
발급하지 않는다. 지역문자4값은오류0이며 검사·기준선·CI예외 변경0이다.
기계진단과 독립 문안 의미 판정을 구분했고 통과시키려고 올바른 문안을 바꾸지 않았다.

private 보고 `.git/order674-store-short/review.md`4622B/
SHAbb528e9441a5f18ad39105a4f97bfa3dff9e3149523356f8702f8ea0cd11f0d9,
`review.json`6897B/SHAcff2270dc8ff00210ac11c7c3b231231de7d103f472545c1585662e4f4a38eec.
root는 MD전문과 실제보고SHA·제품SHA를 대조했다. `preservation-and-text-checks.json`
2419B/SHA05a2709f6d0cb1602ffe3ed978782a983e749ae3871461ab9b391dc3534dd6ae,
`targeted-audits.md`783B/SHA1c08f9766fdc44f224a716da9151879a2c0397e0cecb26a1bb6dd31c5bc451f2.

원격CI의당시static성공/Godot진행은전체green이아니다. 실제Steam필드길이·렌더·
게시·원어민/인간·인게임5언어공개·C5전체/출시GO는미관찰/HOLD다.
긴About/폐기B·C/§11/가격·공시·이미지·게임본문·사전/원장·저장불변,
Mac/engine/새월/외부실행0. 일회성카피준비이며 새규범승격0이다.
