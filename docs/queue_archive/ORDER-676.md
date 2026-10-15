# Closed Queue Spec: ORDER-676

> 우선순위·상태 정본: [CODEX_QUEUE](../CODEX_QUEUE.md).

#### [x] ORDER-676 [C5·트레일러] 색 메커니즘을 설명하는 자막 한 쌍을 판돈의 질문으로 맞춘다

## 대상·깊이

C5 트레일러 준비 입력의 확인된 정본 충돌1건이다. STEAM_PAGE 발견 보존 정본은
옛 컷4의 "영혼이 색으로 무너진다"를 재검토하라고 이미 명시하지만,
timeline의30/60초 KOEN과기존SRT에는그설명이남아있다. 새기능/문체취향이아니다.

1. 지우면 무엇이 깨지는가? 구판의 발견 노출 자막이 다음 트레일러에도 그대로 나온다.
2. 플레이 상태가 변하는가? 아니다. 게임/저장/선택/5언어본문과 무관한 판매 자막이다.
3. 무엇과 경쟁하는가? 4.45/5.45초 읽기 폭이다. 이미 Short/About에서 소유한
   누구에게 시간을 쓸지의 질문만 남겨 색/도덕/소리 메커니즘 이름을 붙이지 않는다.

## 한 배치·exact 소유

- root: tools/trailer/timeline.json의 edits30/60 captions[2].ko/.en 총4scalar만.
  제안 KO "누구에게 시간을 쓸까." / EN "Who gets your time?"를 비저자가 정본과 대조한다.
  컷/프레임/타이밍/스타일/음원·믹스/기타자막/기존영상/SRT/manifest 불변이다.
- root: 큐2·이사양/archive·CLAUDE현재행·WORK_LOG새앞부분 및
  .git/order676-trailer-caption/before/검사/후보·보존기록만.
- 독립 a1_qa_release_audit: 같은 private review.md/json만, 제품/Git/검사/engine쓰기0.
  KOEN1쌍과30/60두소비자·전체raw역변환·실제Git/보호핀을전수읽어판정한다.
- 612실제M18 사양/큐overlay·월로그suffix3555B는보존/stage제외한다.

## 검증·수용·한계

기존 trailer_check.py의정적모드로2편집/2언어/22프레임·자막시각·음원계약을확인하고,
수리4scalar를되돌려old timeline raw bytes와JSON전체/기타자막 exact를대조한다.
context/queue/diff를표적으로실행한다. 신규checker/도구/fast lane·기준선/CI예외0.
현재audit_select목록은timeline경로미매칭으로전체audit요구를출력한다. 이를selector
PASS로바꾸지않으며기존직접trailer표적을실행하고C3 main전체CI는계속별도미충족으로
남긴다. 사용자최신카피검증상한에따라로컬전체audit/engine을이수리때문에돌리지않는다.

실제후보Git/보고SHA로소스자막수용만닫는다. 기존4MP4/SRT는옛카피의미재생성산출물이며
새후보영상으로승격하지않는다. 렌더/현후보촬영·재생/자막가독성/믹스/Steam게시/
C1~C5전체·출시GO0, OS설정/사용자저장/project/공개demo·게임본문불변이다.
Mac잠금해제시큐의가장앞선보류월612로복귀하며새월을열지않는다.
정본승격0(기존STEAM_PAGE §1.5/발견보존소유), 소유·배치·수용은일회성.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

## 2026-10-15 자막 원본 수용 — 실제 영상 완료 아님

| 항목 | 실제 관측 |
|---|---|
| 선언 | 85536559cd1378bcb04b1ea123238f0e262d9aa1 |
| 제품 | c12e6b0687c3a22edfa6f31c37ea3195c98a1f9e/tree10982950731bb7f1e8a25aca2a24b3ecc09b064c |
| 파일 | timeline5952B/SHA783cb2fd7907bbb749aaa4a73713a0d5fe970ce99cba43b89b7b079d2241d7c0 |
| 생산자↔독자 | timeline captions[2] KOEN1쌍 ↔ 기존30/60초2소비자·4scalar |
| 상태 변화 | 색을설명하던문장→시간을누구에게쓸지묻는판돈질문; 게임/저장상태변화0 |
| 서사·계층 | 해당없음·판매자막소스; 게임장면저작0 |
| 판정 | a1_qa_release_audit·4전수·GO_TRAILER_SOURCE_CAPTION_ONLY/차단0 |
| 보존 | old쌍역치환시5982B raw exact/JSON差4만·컷/시각/style/audio/다른자막불변 |
| 실제표적 | 기존TRAILER_CHECK_OK edits2/languages2/frames22·context/queue/diff0 |
| 비소유 | 보호9핀exact·612사양11314B·월로그suffix3555B exact/stage제외 |
| 닫는 것 | 발견을명명하던KOEN자막source1쌍만 |

private `.git/order676-trailer-caption/review.md`3801B/
SHA7f16a2496ed9a7261a1221566cce1fda3ffca8be45064edd5efb9c0aab206382,
`review.json`5763B/SHA3ea204023472b13d7e47c9b49a57aeb6ed6c950ae39a6a378dfd60bc254cedc5.
`proof.json`3214B/SHA33e4ed304008d4975dc26fb4c2664ec6e3b35cbe5c38eb73bf492f672c22d74b.
root보고전문/6핀·보호9/실제Git대조PASS. 초기선언큐13025B예산실패는제목/gate만줄여
해결하고declaration-validation에보존했다. budget/checker완화0·제품착수전선언수리완료.

selector LIST미매칭→전체audit요구는계속미충족/PASS0이다. 최신사용자카피상한에따라
기존직접표적만썼으며C3 main전체CI는별도이다. 신규도구/등록/fastlane/예외/engine0.
기존MP4/SRT는옛카피의미재생성물이며새source산출물로세지않는다. 현재영상촬영/
재생·가독성/믹스/Steam·native/사람·CIgreen·C5전체/출시GO0, 같은612/M18 HOLD보존.
개발스킬의정본·비저자전수·표적/보존규칙적용;승격0(기존발견보존소유)/일회성수리.
