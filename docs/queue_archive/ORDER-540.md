# ORDER-540 — 본편 첫 월급 장면의 주차 만료 수리

#### [x] ORDER-540 [P1·연결 결함] 늦어진 첫 월급 장면 보존 — source 한정 GO

**완료 — 2026-10-10 / source 한정 GO.** 534 정상 입구 수리 중 발견한
첫 월급 reader의 W17 만료만 고친다. 새 preview profile·상한 연장·기본 입구 변경0.
근거는 DECISIONS 2026-08-24와 CHOICE_CONSEQUENCE_SYSTEM의 실제 선택/자동 정산이다.

## 깊이 3문

1. 없으면 실제 급여를 받았어도 상위 장면이 W17을 차지하면 첫 월급의 사용 선택이 사라진다.
2. 취업을 받은 사람만 기존 월말 입금과 첫 근무·급여 장면을 얻는다. 거절한 사람에게
   직업·입금·급여 장면을 발명하지 않는다. 기존 선택 효과와 장기 플래그를 보존한다.
3. 같은 주의 상위 인물 장면과 경쟁하므로 우선순위를 올리지 않고, 다음 가용 주까지 남긴다.

## 정확한 소유

- root: scenes/MainGame.gd의 첫 월급 조건 helper/호출만, tools/audit_scope.json의
  기존 ManualSave 설명(필요할 때만), 이 사양·큐/L3 순번·WORK_LOG·CLAUDE 현재행,
  독립 보고/agent 판정원장과 private 검증 기록.
- 검사 adapter 등록 누락은 tools/arc_flow_sim.py의 기존 full 대표 모델 eval binding에
  이 helper만 연결한다. 초기 미등록 실패 raw를 보존하며 검사·기대값·면제 삭제0.
- cjk_wrap_diagnosis: tools/ManualSaveCheck.gd의 표적 첫 월급 fixture만.
- phone_cn_author: 기존 채용/급여/데모 producer-reader 읽기 검토만, 제품 수정0.
- phone_independent_review: 비저자 source·검증 raw·보존 최종 검수만.
- 원문/번역·GameState/JobSystem/SaveManager·FullStoryFlow·StoryMode/StartMenu·
  project.godot·공개 데모 pin/저장·사용자 저장·인간 원장은 비소유다.

## 일회성 구현·검증 계약

- 본편 non-demo/non-V2에서 W14 이후 실제 current_job·has_received_paycheck가 있고
  arc_paycheck_reality_seen이 없으면 W17 이후에도 기존 자리에서 도달 가능하다.
  원래 W14 최소 주차·한 주 한 root·상위 장면 우선·선택/효과·급여 계산은 그대로다.
- has_received_paycheck는 창작자/초기특전도 쓰는 역사 호환 플래그다. 이번 수리는
  기존 자격 의미만 보존하며 현재 직장의 최초 실입금을 새로 증명하는 receipt가 아니다.
  W24 이내 full의 기존 bridge 무언 소비와 정상 handoff도 이 단위에서 수리/GO하지 않는다.
- demo와 legacy V2는 기존 W14–17 조건과 bridge를 보존한다. 새 flag/schema/입금0.
- 기존 격리 ManualSave fixture에서 실제 authored 채용 accept/refuse 적용,
  첫 근무 selector, 기존 월말 producer, v4 disk/cold, 미입금/무직/이미읽음/늦은주차,
  demo/V2 경계를 확인한다. 주차 준비/함수 호출은 합성 검증이며 자연 앱 플레이가 아니다.
- 기존 isolated bootstrap/fresh HOME/XDG/namespace·marker·3stream scan으로 compile와
  표적 fixture 및 기존 저장 회귀를 검증한다. 영향 정적·arc/EN/한글·서사/음악·데모·
  context/queue/diff를 표적으로 확인한다. 새 실패0 전 완료0.
- 전체감사/240주/누수 탐침/검증비용 도구0. 534 실제 M07·기본 full 연결·native/human/
  physical/native-reader·연속 청취·전체 제품/출시는 HOLD다. 자동 통과는 계약 증거이지
  재미·깊이·문체 증거가 아니다. 새 정본 규칙0, 실행 지시는 일회성이다.

## 구현·검증 결과 — 최종 후보 결속 완료

- Main helper는 full의 W17 상한만 제거한다. demo/loaded V2의 W14–17,
  기존 자격·우선순위·bridge·월말 지급·선택 효과·원문·8/12 profile은 불변이다.
- 실제 authored rescue 양선택·첫근무·월말1회·늦은 reader·v4/new Main·결과 cold를
  기존 ManualSave에 넣었다. full/demo/V2 focus 및 whole4회 exit0/exact marker/
  3stream PASS. W25는 selector query이며 자연 W25 플레이 증거가 아니다.
- 정적18 제품검사 PASS. 최초 arc/narrative 모델미등록2FAIL은 선언 후 adapter/f
  binding으로 수리하고 최종2회 raw를 남겼다. V2검사 actualexit0의 정상 데이터명
  hyunsu_result_fail을 잡은 wrapper오탐은 원2stream으로 분리한다. 게이트 삭제0.
- compile69 actualexit0/빈stderr/전체marker1회. 축약marker wrapper FAIL을 원형
  보존하고 재실행 없이 독립 재평가한다. 첫 focus/diagnostic2FAIL은 기존 AP UI
  invest_hint_shown 한 잎 차이로 분리했고, 그 기존 조건만 로컬 예측해 나머지
  전체 상태/경제 비교를 유지했다. 실패·수리·최종 raw를 모두 private에 보존한다.
- 독립 source 최종 GO·보존 결속 뒤 이 범위만 닫는다. 기본 본편534/M07·W24이내
  full bridge/normal handoff·완성게임·출시 및 인간 증거의 HOLD는 바뀌지 않는다.

## 최종 판정

제품 후보 `bf6ab1fbcedbd7c27091e956d1864dc4b3ed55eb` /
tree `c47b7a0e264b33e4043c0883740a17d01790662a`에
[독립 보고](../agent_reviews/ORDER-540.json) 9330B /
SHA `f3d036ce8cb95b8c35b37ab173b5261eb6ae301f0efd8544ca8960e03e171e4a`를 결속했다.
비소유제품2381·보호23그룹581파일·사용자33파일·과거278판정 exact다.
이 마감은 제품4파일·CLAUDE·보호 원본을 다시 바꾸지 않으며 source 범위만 닫는다.
정상 본편 입구·실제 M07·출시 HOLD는 부모534가 계속 소유한다. 실행 지시는 일회성이다.
