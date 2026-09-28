# Active Queue Spec: ORDER-369

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-369 [P0·검증 수리] 구형 V2 번역 범위에 승인된 대본 수리의 현재 기대값을 연결한다

**[~] 2026-09-28 Codex 착수.** 365 named12에서 확인한 기존 실패3명령의
공통 source2항목을 수리한다. 시작6a568d9부터 존재하며 이번 중국어44의 원문
변경이 아니다. 305 제품031f5e5의 구형72사건/467leaf 교집합은 answer결과0
이름토큰(+3), 결과1 시제(0), temptation_clean 설명(-1)의3leaf이며 나머지464는
동일하다. 40767/f6b2fc…→40769/43ec49…이다. 공개story-demo14사건/100leaf와
다른 분모이고 공개검사는 이미 통과했다.

## 깊이 3문·소유권

1. 손실: 이미 승인된 이름·시제·거절문 수리 때문에 별개 언어 감사가 막힌다.
2. 장기 상태: 기대 관측만 연결한다. 공개package/원문/번역/게임 상태는 불변이다.
3. 경쟁: 승인된3leaf와 임의 문구 변경·rollback을 구분한다.

- `/root/compat357`: `tools/demo_localization_scope.py`의 명시적 current expected
  view와 자체 표적 self-test, `tools/ja_translation_pipeline.py` collect_demo,
  `tools/ja_translation_audit.py` _demo_runtime의 호출부만 소유한다.
- `tools/zh_translation_audit.py` main의 source-contract 연결 한 곳은368 저자가
  한 파일 작업을 freeze한 뒤 root가 담당한다. 동시 편집하지 않는다.
- root: 큐2·CLAUDE 현재행·WORK_LOG·생성STATUS·이 사양→archive·새판정1행과
  agent_reviews/ORDER-369.json, git-private order369 증거.
- `/root/r3_route_probe`: 저작 비참여, private order369 독립 검수만 소유한다.

## 한 단위·보존

원래 manifest source계약과 whole-raw를 보존한다(Chapter1 역사핀9d50b64e…).
범용 compare_contract와 기존 corpus/음성 사례는 그대로 둔다. 별도 helper가
immutable305 전후KO·현재raw·정확3leaf·나머지464·72/467 분모·원계약을 검증한
뒤 기대값 copy의2필드만 갱신한다. observed/runtime에는 실제 현재 문구와
40769/43ec49…를 그대로 돌려준다. 승인문구를 과거원문으로 되돌려 보고하거나
모든 hash 차이를 면제하지 않는다. 실패는 caller 오류로 전파하고 fail closed다.
기존305/310/316/309/313/350/351/365 호환모듈·핀·제품·인간/공개원장은 비소유.

## 검증·판정

현재 정상과 과거/부분rollback·다른leaf·수량/키/분모/manifest 변조·Git증거
누락/불일치·관측위조를 표적으로 검사한다. 기존 demo_scope self-test와
JA pipeline self·JA UI·ZH self의 실제 실패3명령을 재실행하며 full-game265의
368 연결 회귀도 확인한다. 성공한 검사라도 이 변경이 입력/경로에 영향을 주면
그 이유를 명시하고 표적 재검한다. 첫 named12실패는 그대로 보존한다.
역사1955/689·전체shell·엔진/패키지를 반복하지 않는다. 원어민·인간·물리·새렌더
미관측, 본편/새package HOLD. 이 전이·4도구·검증은 **일회성**, 상시 승격0이다.
