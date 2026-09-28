# Active Queue Spec: ORDER-381

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-381 [P0·UI 수리] 패드 안내를 지역 글꼴과 실제 표시 폭에 연결한다

부모 ORDER-379/157. 2026-09-28 착수 — 아래 파일 소유를 확정하고 별도 선언 뒤 구현한다.
기준 제품 `ffc564fcaee1d28826f19819f51f996dc7241a80`.

## 확인된 결함·깊이 3문
1. 지우면: CN/TW 취업 T3에서 뒤로가기 50px가 1px 영역에 들어가고,
   RichText 안내의 normal font가 지역 글꼴에 연결되지 않은 채 남는다.
2. 24주 차이: 경제·선택·직업 자격을 바꾸지 않는다. 조작 안내를 온전히 읽게 한다.
3. 경쟁: 전역 레이아웃/새 UI를 늘리지 않고 현재 소비자 세 곳만 수리한다.
기존 닫기 ✕도 bundled font에 없다. 화면에 보이는 시스템 폴백을 이식성 증명으로
쓰지 않는다. 실제 결함은 `order379-screen-fourth-corrected`의 T3 두 지역4노드,
close 부채8이며 380의 상태4관측 217/288px PASS는 다시 번역하지 않는다.

## 선언할 정확한 파일 소유와 1배치
- root: `scenes/MainGame.gd`의 세 소비자만. modal_pad_hint_label의 clip을 해제해
  Container가 실제 최소 폭을 계산하게 하고, 취업 RichText normal font를 기존
  지역 regular font에 연결하며, 닫기를 bundled 지원 ×로 바꾼다. 실제 측정으로
  적합성을 판단하며 전역 폰트 크기·정산·입력 라우팅·채용·다른 문구는 비소유.
- 호환 저자: `tools/main_game_locale_history.py`에 실제 제품 commit/직접 parent/
  tree/blob/SHA·정확 세 수리의 전체 raw 역상을 추가한다. 공개 역사 API와
  collector가 직접 호출하는 gift_caption 입구를 모두 연결하고 원형 본문/pin 유지.
- 호환 저자: `tools/ja_translation_pipeline.py`는 현재 MainGame 호출 위치만
  실제 원문에 재결속한다. 의미/ID/키/개수·역사 수집은 유지한다.
- 호환 저자: `tools/ui_translation_append.py`의 현재 MainGame 증명·비교용
  manifest 연결만. 현재→수리 전→필요한 기존 Aruba 전이로 비교하며 실제
  inventory/원문/원장/공식 header를 과거 값으로 바꾸지 않는다.
- 호환 저자: 기존 `tools/ui_translation_append_self_test.py`의 새 focused 옵션,
  `tools/audit_scope.json` 등록. 원형 gift/new-run self·wholepin은 바꾸지 않는다.
- root: 이 사양/완료 archive, 큐 두 인덱스, CLAUDE 현재행, WORK_LOG,
  생성 STATUS, agent 원장/381 및 부모379의 새 후속 보고(기존379 보고 보존).
  private381 helper/evidence.
- 독립 검수자: 제품/도구 비저자. 실제 diff·증거·PNG와 최종 source 판정.
실행 역할: root는 제품·정본·격리 엔진 실행과 정리, compat357은 위 도구5파일,
screen_path_probe는 private381 관찰기/실행기만, r3_route_probe는 독립 읽기 검수다.
WORK_LOG 용량이 부족하면 기존 `docs/history/WORK_LOG_2026-09-07_localization.md`로
오래된 완결 항목만 바이트 보존 이동한다. 기존379 관찰기와 실패 증거는 동결한다.
새 모듈 연쇄나
위 경계 밖 변경이 필요하면 구현 전에 범위를 다시 선언한다.

## 검증·완료 경계
- 정확 전이/부분수리/rollback/이웃·공백/Git 위조/manifest/호출 위치의 새 focused,
  현행 receipt guard/영향 consumer5 normal 및 등록/context/queue/diff만 우선한다.
  변경 없는 역사 self/전체감사/240주 반복0. 실행 시간·실패 원본을 보존한다.
- 기존379의 10상태와 KO/EN/JA 표적에서 글꼴·glyph·폭·실제 PNG를 확인한다.
  기존 닫기 예외를 PASS로 돌리지 않고 새 glyph의 실제 지원을 관측한다.
  키보드 취소·탭·커서 입력과 준비된 패드 표시를 구분해 기록하며 물리 관찰로
  바꾸지 않는다. 채용/정산은 실행하지 않고 준비상태·저장·실사용자 파일 불변을 본다.
- root만 proven pre-autoload 격리 엔진 실행. 원래379 실패4실행/380 GO를 보존하고
  독립 후속 판정까지 부모379 HOLD다. 공개GO1·인간OPEN45·본편/새package HOLD.
외부출시·스토어·지출·법률 권한은 포함하지 않는다. 정확 수정/핀/검사계획은 일회성.

## 실제 실행 결과·후속 경계
- 제품 `b9b5c3d`, 검사 도구 포함 clean 실행 `a332f746636e677a4b77d9d97d08353bcf0addc1`.
- L1: 새 self43·current guard·영향 consumer5·등록/context/queue/diff =11검사 PASS,
  선택조회1은 검사로 세지 않는다. 전후 source census 불변.
- L2: 13준비상태/13PNG·사전92lookup·5언어 합성 키보드40edges. 기존379의
  10화면과 이번3소유표적은 정상. CN/TW 뒤로가기1px→50px(실제문구50px),
  regional normal/bold 공유 font 및 ×11노드 glyph 확인. 실사용자34파일 불변.
- 새 EN T3 경력란 `Public Agency Contract Worker · Tier 3 · Promotions 1/3`이
  372/288px로 잘려 **전체 실행은 FAIL 그대로 보존**한다. 이는 이번 세 소비자
  밖의 기존 status label이며 새382로 분리한다. KO/JA 추가 화면 정상이다.
- 도달: 준비된 MainGame 취업 모달에서 E/Down/Q/Esc 실제 합성 dispatch.
  생산자/독자: `_build_modal`/`_open_jobs` → `_open_modal`/`_refresh_job_pad_hint`.
  상태: 표시폭·font·glyph만 변경; 경제/채용/정산0, 포기비용/서사위치/계층=N/A(UI).
  취소 검사는 비어 있는 pending/bundle/resume와 local current_event sentinel을
  명시 준비·복구했다. 자연 주차복귀/인간/원어민/물리 관측으로 바꾸지 않는다.
- 최종 독립 판정은 원본 전체FAIL과 좁은 범위 증거를 함께 읽은 뒤 별도 기록한다.
