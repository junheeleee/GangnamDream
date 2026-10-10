# ORDER-540 — 본편 첫 월급 장면의 주차 만료 수리

#### [~] ORDER-540 [P1·연결 결함] 실제 입금 뒤 늦어진 첫 월급 장면 보존

**착수 — 2026-10-10 / 구현 전 선언.** 534 정상 입구 수리 중 발견한
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
- cjk_wrap_diagnosis: tools/ManualSaveCheck.gd의 표적 첫 월급 fixture만.
- phone_cn_author: 기존 채용/급여/데모 producer-reader 읽기 검토만, 제품 수정0.
- phone_independent_review: 비저자 source·검증 raw·보존 최종 검수만.
- 원문/번역·GameState/JobSystem/SaveManager·FullStoryFlow·StoryMode/StartMenu·
  project.godot·공개 데모 pin/저장·사용자 저장·인간 원장은 비소유다.

## 일회성 구현·검증 계약

- 본편 non-demo/non-V2에서 W14 이후 실제 current_job·has_received_paycheck가 있고
  arc_paycheck_reality_seen이 없으면 W17 이후에도 기존 자리에서 도달 가능하다.
  원래 W14 최소 주차·한 주 한 root·상위 장면 우선·선택/효과·급여 계산은 그대로다.
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
