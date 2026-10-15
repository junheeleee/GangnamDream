# Active Queue Spec: ORDER-676

> 우선순위·상태 정본: [CODEX_QUEUE](../CODEX_QUEUE.md).

#### [~] ORDER-676 [C5·트레일러] 색 메커니즘을 설명하는 자막 한 쌍을 판돈의 질문으로 맞춘다

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
