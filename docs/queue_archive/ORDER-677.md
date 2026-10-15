# Closed Queue Spec: ORDER-677

> 우선순위·상태 정본: [CODEX_QUEUE](../CODEX_QUEUE.md).

#### [x] ORDER-677 [C2·크레딧] 조기 결말에도 5년을 살았다고 단정하는 감사 문구를 수리한다

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

- root: scenes/MainGame.gd의 _ending_build_credits_page thanks Label 선택만.
  후보 KO "그리고 지금, 이 화면의 불빛 앞에 있는 당신에게." /
  EN "And to you, here in the light of this screen."
  int(GameState.turn) >= 기존 RUN_TURN_LIMIT(240)이면 기존5년 감사문,
  그전이면 위 현재불빛 문구를 쓴다. 경주/중독/돈/턴/finish_run/엔딩라우팅/
  저장/다른 credits 불변, 새 장면 저작0. UI 읽기조건만 추가한다.
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

source 독립GO 뒤 thanks Label만 로컬 Git에 결속하고 공식 export/check/import로
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

## 2026-10-15 표적 실패와 같은 범위 재설계

첫 source1e49e7d의 무조건 새문구 교체는 JA_UI에서 old5년키 unknown extra로
실제로 실패했다(.git/order677-ending-thanks/ja-ui.log). 검사나 이전사전/원장을
고쳐 숨기지 않는다. 공통 credits의 현재 turn을 기존 RUN_TURN_LIMIT에 대조해
5년을 마친 경우에만 옛 감사문을 유지하고 조기 결말에서 새문구를 쓴다.
검사만 위한 죽은 literal이 아니라 정상5년 credits를 보존하는 실제소비자다.
239/240경계·W14/241의 UI조건을 직접 대조하고 격리 CompileCheck를 새source로
재실행한다. 소유는 같은 Label 선택 안이며 엔딩 ID/라우팅/상태/저장 변경0이다.
공식 source batch는 수정source에서 다시export/검수/import하고 원batch·영수증은
private에 보존한다. 같은 KO신규문구의 CJK3값은 재저작하지 않는다. 현재미커밋677
batch의 header/digest만 실제 새영수증으로 결속하며 기존330batch/accepted는 불변이다.

## 2026-10-15 수용 — 기간 사실·신규번역 한정

재선언7d31e4b→source97cd43461fd16556e27a8f8bad1174c89d688b39/
tree815f8a87953d7988b77e153b35550bb18a409c8e→최종target
762e16580685a2b9bcdb3603346c005944c0f0d2/treee2f69b67719b2c8aefce2254d716b0b9e191475d.
공통 credits Label의 기존240주 기준 읽기만 수리했다. W14/239는 현재 화면불빛 감사,
240/241은 기존5년 감사다. 종료/경주/돈/턴/저장·다른UI 불변이며 source블록을
옛3줄로 역치환하면 before MainGame 전체raw가 exact다.

KO/EN 사실경계와 신규JA/CN/TW1각3값을 비저자가 전수 수용했다. 첫CN/TW
微光은 원문에 없는 희미함이라 반려·微만삭제했고 원안/검사출력은 보존했다.
첫source1e49의 무조건 새문구는 JA unknown-extra1로 실제실패했으며, 죽은키/예외
신설 대신 정상5년 소비자를 조건 안에 유지해 같은JA검사를 통과했다.

공식accepted.source/response3과 import3(내장check actualPASS)을 source97에 결속,
UI신규3·accepted3·batch330→331만 append했다. 최종 current_proof는 네파일
full raw inverse/기존원장exact·first-parent 전이1·실제Git source census
b8fac880399ade9b7f0582783d1792fc8090386b81f89e78a9adc45bade33540을 확인했다.
잘못된 present-target 재export의 첫target1f1656b는 current_proof에서 실제실패했다.
원격push0 상태에서 별도 refs/codex/order677-rejected-target에 보존하고, root소유
해당commit만 soft-reset해 파일손실 없이 새 missing-target export로 재수용했다.
실패candidate/로그를 감추거나 baseline/checker/기존330batch를 바꾸지 않았다.
공식import가 정규화한 JA기존5줄 탭만 원형으로 복원했다.

최종source의 격리 CompileCheck69 marker/stdout·Godot로그 오류/경고/잔여0,
JA UI2982 오류0·ZH audit·EN한글0/coverage·i18n EN1813/35·publicdemo82/121과
context/queue/diff 통과. UI3는 위검사 입력과 byte exact여서 영수증header 재결속 후
무관한검사를 반복하지 않았다. 전체audit/240주/새tool/selftest/검사등록·삭제·예외0.
broader JA/CN/TW inventory invalid137/70/72·INCOMPLETE/nativeOPEN은 그대로이며
새치명결함/출시준비 완료로 바꾸지 않는다.

비저자 final GO_ORDER_677_FINAL_PRODUCT_ONLY:
private final-review.md5603B/SHAba7ab0983b13ae6fb9e32b72b5697e3032fe6697e05cfffa05032ae2b57884a0,
final-review.json13862B/SHAd07a4eddb6db6c7384dc68616a0d8317ac6501884a367802c3b633bbc11521f4.
history-proof.json852B/SHA42fa9868a40dba132fca88aeec32e1bb0f459a40c7a46ec38b326be6223b5aca,
preservation-proof.json6577B/SHA7241f24deb5381139d25d0596344c8c7645459ac2410b59be44f5d43934c6731.
root보고전문·actual35핀/Git identity 확인. 612사양11314B·월로그suffix3555B,
project/LocaleManager/인간·agent원장·실제player33files exact/stage제외.

Mac잠금 지속·같은612/M18 app14.3 보존/새월0. actual credits/조기경로플레이·native/
원어민/물리패드·C1/C2전체·mainCIgreen·C4/C5전체·외부Steam/출시GO0이다.
개발스킬의조건대조·독립KO번역/비저자검수·표적/보존 적용;승격0/일회성수리다.
