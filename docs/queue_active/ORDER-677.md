# Active Queue Spec: ORDER-677

> 우선순위·상태 정본: [CODEX_QUEUE](../CODEX_QUEUE.md).

#### [~] ORDER-677 [C2·크레딧] 조기 결말에도 5년을 살았다고 단정하는 감사 문구를 수리한다

## 대상·깊이

C2의 실제 선택/기간과 반대인 문장 수리다. 정상 본편 W14의 racetrack 진입,
tipster90회와 skip 갱신은 턴을 늘리지 않고 addiction90 terminal에 도달한다.
GameState.finish_run은 turn을240으로 올리지 않는다. 공통 ending credits는
이 경우에도 무조건 "이 5년을 살아 준 당신에게"라고 감사한다.
이는 production 조건으로 입증한 반례이며 실제 앱 플레이 증거가 아니다.

1. 지우면 무엇이 깨지는가? 조기 결말의 경과기간을 거짓으로 서술하는 UI가 남는다.
2. 게임 상태를 바꾸는가? 아니다. 기존 thanks Label의 KO/EN literal만 바꾼다.
3. 무엇과 경쟁하는가? 같은 credits 공간이다. 지운 사실 자리에 현재 화면의
   불빛1감각만 넣고 새 과거·관계·돈·기간을 만들지 않는다(SCENE_TIER 공통산문계약).

## exact 소유·배치

- root: scenes/MainGame.gd의 _ending_build_credits_page thanks KO/EN1쌍만.
  후보 KO "그리고 지금, 이 화면의 불빛 앞에 있는 당신에게." /
  EN "And to you, here in the light of this screen."
  경주/중독/돈/턴/finish_run/엔딩라우팅/저장/다른 credits 불변, 새 장면 저작0.
- root: locale/ui_ja.json, locale/ui_zh-CN.json, locale/ui_zh-TW.json의 신규 thanks
  1키씩과 content/meta/full_game_localization.json의 accepted3·UIbatch1 append만.
  이전 기간 키/번역/영수증은 역사로 보존하며 기존 JA/zh 다듬기는 하지 않는다.
- m46_48_fact_read: .git/order677-ending-thanks/ja-response*만 신규 JA 저작.
- a1_data_content: .git/order677-ending-thanks/zh-response*만 신규 CN/TW 저작.
- 비저자 a1_qa_release_audit: 같은 private source-review*/target-review*/final-review*
  한정. source2·target3 전수 독립 검수, 제품/검사/Git/engine 쓰기0.
- root: 큐2·이사양/archive·CLAUDE현재행·WORK_LOG새앞부분과 같은 private
  before/batch/response/receipt/proof/검사기록. 612사양/dirty큐overlay·월로그
  suffix3555B는 보존하며 stage에서 제외한다.

## 검증·닫는 범위

source 독립GO 뒤 literal2를 로컬 Git에 결속하고 공식 export/check/import로
새 UI3값을 수용한다. ui_translation_append의 기존4파일 raw inverse·실제Git
source census·영수증 hash를 쓴다. source/target review와 context/queue/diff,
관련 EN한글/coverage·JA/ZH UI·번역원장·공개demo 검사만 표적 실행한다.
CompileCheck는 기존 StoryNameplateBootstrap의 pre-autoload fresh 저장 namespace로
격리하며 marker와 stdout/Godot로그를 함께 확인한다. 신규 checker/시간단축도구/
제품검사삭제·완화/기준선/CI예외/전체audit·240주 재실행0이다.

수용은 common thanks1쌍·신규번역3값에 한정한다. actual credits 렌더/조기경로 실제
플레이·C1완주·C2전체·mainCI green·C4사람/원어민·C5전체/출시GO를 발급하지 않는다.
Mac잠금이면 같은612/M18 app14.3을 보존하며 새월0; 해제시 해당월로 복귀한다.
사용자저장/설정/project.godot·공개demo·인간판정·보류76오더 불변.
승격0(기존 DECISIONS C2·SCENE_TIER 소유), 위 소유·배치·수용은 일회성이다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
