# Active Queue Spec: ORDER-374

#### [~] ORDER-374 — 취업 준비 중국어 질문·선택·안내 전체 잔여 묶음

**[~] 2026-09-28 착수 — 만지는 파일: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`, `content/meta/full_game_localization.json`의 신규 UI/수용 append, 큐·작업/독립 검수 기록.** 부모157과 사용자의 “검수를 효율적으로 하면서 속도를 올리자” 지시를 적용한다. 한국어 원문은 현재 `scenes/JobHuntMiniGame.gd`이며 runtime 코드는 비소유다.

## 판정 가능한 범위

- 자소서8문항(q/hint/선택3), 면접10문항(q/선택3), 제목·타이머·CTA 묶음, 점수별반응·시간초과 묶음: 총20단위, 한국어94고유키×CN/TW=188신규문구.
- 기존 collector의 `ui_demo_dynamic`80키 + `ui_static_context`14키. JobHunt에 정확한 한국어 literal이 있고 양쪽사전에 없으며 public 보호키가 아닌 leaf만 봉인한다. shared 확인/제목은 해당 callsite 의미도 대조한다.
- 같은 한국어에서 지역별로 독립 저작한다. 번체는 간체의 문자변환으로 만들지 않는다. 이미 있는 사전값·공개데모·KO/EN/JA·점수/순서/타이머/게임/저장/폰트바이트·인간원장 불변.

## 깊이와 소유

1. 지우면 질문·답변이 영어로 남아 중국어 문장을 고를 수 없다. `_loc`/`LocaleManager.ui`가 실제 소비자다.
2. 선택 결과나24주 상태를 새로 만들지 않는다. 기존 score3/1/0의 구체성·책임감 차이와 숨은수치 비노출을 번역에서 보존한다.
3. 같은 화면공간의 세 답변이 경쟁한다. 정답을 덧붙이거나 짧게 만들려고 근거·기한·가족빚 원인을 지우지 않는다.
- root: TW 직접초안·두언어 source-bound export/check/import/공식원장·표적실행·큐/기록.
- screen_path_probe: CN 직접초안만; 이후 별도 private 화면관측 helper만. locale/원장은 root 단일작성, 파일충돌0.
- r3_route_probe: 비저자 검수.94×2 문구 전수 대조(짧은 단일화면이므로 표본추출관리보다 직접읽기가 작다), 실제 새화면 표본은 스스로 선택. 원어민·인간·물리 관측으로 승격하지 않는다.
- compat357: 기존 검사 잠금의 최소 후속설계 읽기전용. 도구변경이 필요하면 새 범위를 먼저 선언한다.

## 효율적인 검증·마감

- 기존 `full_game_localization.py`로 변경 전 exact94 export, 응답check/import. raw중복·숫자/토큰/줄바꿈/지역문자·현재원문/대상해시와 기존값 불변을 전수확인한다. 최초실패는 남긴다.
- 같은 inputs의 collector는 private한 검증실행 안에서만 재사용할 수 있다. 서로 다른 source/target 실행의 성공을 cache하지 않는다. 검사기 자체를 바꾸지 않으면 방금통과한 대형 self/옛1955/689/240주를 반복하지 않는다.
- 변경된 중국어 화면만 기존 pre-autoload 격리 bootstrap으로1280×800에서 관측: 두지역 각각18문항과 타이머/반응/CTA의 실제 Label/Button 값·지역font·glyph·배치. 준비된문항/직접반응 관측은 자연진입/물리입력으로 부르지 않는다.
- 기존371의 입력4/준비48 및372의5언어 font회귀는 변경되지 않은 runtime 의존성hash로 영향 연결한다. 새로운 번역의 배치 검증과 새화면은 생략하지 않는다.
- context/queue/diff, 기존 selector가 고르는 영향 목록, 표적언어검사만 실행한다. 번역과 무관한 기존 liveness오탐은 확대수리하지 않는다. 과거 whole-file 고정 검사는 FAIL을 숨기지 않으며, 현재수용 증분의 연결수리는 별도 scope가 소유한다.
- 독립 GO는 이 번역 work_unit에 한정한다. 본편/새package HOLD, 원어민/인간/물리 OPEN, 출시언어/외부상태 변경0. 작업지시·모집단·검수계획은 일회성, 기존 WORK_UNIT/I18N을 바꾸는 새정본 규칙0.
