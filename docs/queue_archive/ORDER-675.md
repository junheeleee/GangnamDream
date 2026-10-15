# Closed Queue Spec: ORDER-675

> 우선순위·상태 정본: [CODEX_QUEUE](../CODEX_QUEUE.md).

#### [x] ORDER-675 [C5·상점] 발견을 남기는 긴 소개문을 5개 언어로 준비한다

## 대상·기여

DECISIONS 2026-10-15 C5의 5언어 상점 설명 준비물이다. 674의 태그라인/확정
Short A는 불변이며 누락된 JA/CN/TW About를 채운다. 원문 About KO/EN의 색·선악
게이지·DIK 재독·유물 제시 설명은 같은 STEAM_PAGE §1.5/발견 보존 정본과 충돌하므로
판매 copy에서 제거한다. EN만의6년상환과 사람에게시간을줄자격평가도 KO와 맞춘다.
게임 원문·메커니즘을 바꾸는 작업이 아니라 이미 승인된 마케팅 경계를 적용하는 것이다.
공개 장면·개별 엔딩 결과/조건을 더 밝히거나 새로운 기능·달성·효과를 약속하지 않는다.

## 깊이 3문

1. 삭제하면 무엇이 깨지는가? C5 긴소개3언어가 없고 기존KOEN소개가 발견을 미리 밝힌다.
2. 플레이 상태를 바꾸는가? 아니다. 게임/저장/선택/retail언어 노출과 무관한 로컬 문서다.
3. 무엇과 경쟁하는가? 판매 화면의 읽기 폭과 플레이어의 발견이다. 시작사정·돈/시간/
   사람의 지금 행동·240주/35결말 범위·기존내용경고만5블록으로 명확히 제시한다.

## 배치 1 — KO/EN source 5블록×2

root가 STEAM_PAGE §4/§5를 같은5블록으로 정렬한다. 독립검수자가 실제원문과
판매경계·현재source의240주/35엔딩·원화/인물/기회 비보장·KOEN 의미를 전수 대조한다.
긴 기능목록·메커니즘·미리 확정하는 개인별 결과를 새로 번역하지 않는다.
원source는 before.json과 실제Git에 보존하며 승인된규칙 자체는 바꾸지 않는다.

## 배치 2 — CJK 신규 5블록×3

독립KO저작 JA/CN/TW About를 §5.1/§5.2/§5.3에 넣는다. 영어중역/간번변환0,
원화·숫자·이름·5블록/BBCode/문단 의미를 보존하며 기존CJK 문체 다듬기0이다.
비저자검수자는 세언어15블록 전수와 최종5언어 문서·원형/비소유를 대조한다.
기존release/context/queue 표적과 지역문자/텍스트검사를 재사용한다. 새검수도구/전체audit/
engine·실제앱·외부등록·사용자설정변경0이다. C3 실제실패가 확인되면 우선 수리한다.

## exact 소유권

- root: docs/STEAM_PAGE.md §4·§5 본문과 신규§5.1~5.3만. §1~3/6~13/마케팅정본·
  가격·AI공시·기존674카피·다른제품 불변. §11의 별도피치도 이범위밖이다.
- root: 큐2·이 사양/archive·CLAUDE 현재행·WORK_LOG 새앞부분·private before/source/
  검사/후보/보존증거. 진행중612사양·suffix3555B·612큐overlay는 commit에서 제외한다.
- m46_48_fact_read: .git/order675-store-about/ja-draft.json·ja-author.md만.
- a1_data_content: .git/order675-store-about/zh-CN-draft.json·zh-TW-draft.json·zh-author.md만.
- a1_qa_release_audit: .git/order675-store-about/review-source.*·review-final.*만.
  제품/Git/검사·engine 쓰기0, 저자산출물을 직접 읽는 독립 검수다.

## 수용·규범·한계

선행 source5블록의 독립판정 뒤 번역하고 최종문서의 actualGit/파일SHA에 보고를 결속한다.
신규3언어/KOEN수리 외 원문을 역변환해 old문서바이트를 확인한다. 게임/사전/번역원장/
검사/인간원장/공개demo/사용자저장·설정·project 불변·실제월추가0이다.
긴소개문 초안의 내부수용만 닫으며 Steam허용량/렌더/게시·게임CJK확정·원어민/사람/
C1~C5전체/출시GO는 발급하지 않는다. 실제Mac은현재잠김이므로native재시도0이다.
판매경계는 STEAM_PAGE §1.5/발견 보존이 이미소유, 새규범승격0·exact5블록과소유는일회성.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

## 2026-10-15 긴 소개문 준비 수용 — C5 전체 아님

| 항목 | 실제 관측 |
|---|---|
| 시작·선언 | a38d0765824ced449b34b21fbac2420667422bda → 994eb7d2b89b7c9b73c58ff669dbe35ac87b0315 |
| KOEN source | fda8582f543aa3c3b09e7bf5d14ba84fc8658ed8/tree6c626355e7672062b0b16b9907f46298e610620a |
| 최종 제품 | 30aedf86d63561c31f549ebce77254b259b38355/tree9e968621bc1103b39664d9f00ca0c40fa09a79fc |
| 문서 | STEAM_PAGE33731B/SHA64781a2fb118f3b4c50aaa9b16e170723a05302d6d0a9946e5fc79fd0f1d20dd |
| 생산자↔독자 | 같은 문서§4 KO5블록 ↔ §5 EN5/신규§5.1~5.3 JA·CN·TW5각15 |
| 상태 변화 | 기존KOEN About 정렬·CJK 긴소개0→5각15블록; 게임/선택/저장 상태변화0 |
| 서사·장면계층 | 해당없음·상점상황카피; 게임 scene 저작/본문확정 아님 |
| 독립검수 | a1_qa_release_audit·source10/최종25블록 전수·GO_STORE_ABOUT_COPY_ONLY |
| 보존 | 신규3절과KOEN수리를역변환하면old문서exact; §1~3/§6~13·674·공시·가격·다른제품 불변 |
| 표적 | 최종수리뒤 existing release inventory/context/queue3 actual0·diff0 |
| 비소유 | 보호9 SHAexact·612사양11314B/WORK_LOG suffix3555B exact·stage제외 |
| 닫는 것 | 발견을설명하던KOEN About 불일치와긴소개3언어누락만 |

최초5c86938의 EN 어순을수리해source10을재전수했다. CJK첫15블록은JA지명쉼표·
CN/TW월세/생활비·TW표제/약속의최소수리뒤같은15전량을재검수했다. 최초버전과
진단은private first/second-cjk-checks 및저작보고의전후핀에보존했다.
지역문자15블록/JAtext5오류0. generic ZH text의방한칸(cell)2·한번의5년(occurrence)1
진단은검수자가원문과一间房/一間房·一段5年的歷程의동등함을직접확인한오탐이다.
진단을숨기거나기계완전PASS로바꾸지않았고checker/기준선/CI예외변경0이다.

private `.git/order675-store-about/review-source.md`4332B/
SHA26ba04c99af61d41b7cc71349aef1ea6fe79d2761b8e2051aa30d0cb4d7d28e7,
`review-source.json`4855B/SHA361ab3eece6c4d046aa8a04021eb91653c6b115f56c47012f91a623eb7b9aa4f.
`review-final.md`4684B/SHA6230c1e089f263ea24fef52f14c3f8e863a4eeebbdfcdfca38eea78ed49089eb,
`review-final.json`12229B/SHA1390b82667ff411972de5a378a82ad419e3ee46e583bbe0649253ebba04feaf1.
root가두최종보고전문·실제Git·보고16핀/보호9를전부대조했다.
`preservation-and-text-checks.json`6246B/SHA422c90dbe40415c601bf9a3ac79ad69f4fdcfd3ca1639ad88695711b4045f502,
`targeted-audits.md`1469B/SHA953550f6c39c7d4ee622fa90623d28bda6004164fdab622720c3717265287d1e.

240주·35엔딩은source상수/KOEN35 ID목록근거이며실제240주완주가아니다.
Steam필드허용량/렌더/게시·실제앱/retail5언어·원어민/사람·현재CIgreen·C1~C5전체/
출시GO는미관찰/HOLD다. Mac잠금중engine/새월/OS설정·외부실행0, 공개demo/인간판정/
사용자저장·project 보존. 개발스킬의KO직접번역·독립검수·표적/보존규칙적용.
승격: 새규범0(판매경계는기존STEAM_PAGE§1.5/발견보존소유);이카피준비/소유/배치는일회성.
