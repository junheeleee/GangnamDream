# ORDER-408 — 번역 검수의 Chapter1 동일 호출 중복 증명 제거

#### [x] ORDER-408 [P1·검수 효율] 번역 검수의 Chapter1 동일 호출 중복 증명 제거

## 완료 — 2026-10-04

- source `fb46b9f770adf7d9a7e753e18e6a2223665750f9`, tree `5204c3300a71e3f97968bf3da76977f417f4ead6`.
- focused19방법 PASS0.324초·실제 Chapter1 PASS269.825초·전체7명령270.322초.
  원본 stdout·debt8/blocked3/gap24 유지, source2978/helper37/prior6 불변.
- 이전407실측776.493초 대비506.668초 감소. 동시 실행한 다른 검사들이 달라
  통제된 벤치마크나 일반적 속도 보장이 아니다. 구버전 재실행0.
- [독립 원문 검수](../agent_reviews/ORDER-408.json) 한정GO. scoped double의
  제어흐름 증거와 실제 normal의 immutable admission 증거를 구분했다.
- 제품·번역·원래proof/pin·공개demo·인간증거 변경0, 새Godot/화면/입력0.
  공개GO1·인간OPEN45·본편/새packageHOLD 유지. 상시규범추가0/일회성.

## 원래 선언

**[~] 착수 — 2026-10-04.** 사용자 검수 효율·계속 개발·main 커밋/푸시 위임.
406 Chapter1 초회720초 timeout, 단독재시도684.920초를 실측했다.
동일 snapshot 내부 current UI admission과 두 font comparison이 각각 outer proof를
열어 같은 UI receipt 자료를 세 번 읽는 것을 코드에서 확인했다.
이번 작업은 검사 호출 수명만 정리하며 제품·번역·판정 기준을 바꾸지 않는다.

## 판정 단위·깊이3문

- 생략하면 후속 번역 배치의 Chapter1 검사마다 같은 admission을 세 번 지불한다.
- 플레이어의 24주 상태·경쟁 선택은 N/A: 도구 실행시간과 동일 오류 보존만 판정한다.
- 한 bounded wrapper와 focused 회귀를 한 단위로 본다. 일반 proof cache나 전체 감사
  재설계로 확장하지 않는다. 속도 향상은 실제 시간과 호출수로 확인한 만큼만 보고한다.

## 정확한 범위

- Chapter1 파일의 기존 267 appendix까지 prefix를 바이트 보존한다.
  기존 `_audited_source_snapshot_errors`(267 wrapper 포함)를 저장하고,
  `if __name__` 앞의 새 appendix에서 기존 `fresh_validation_proof()`로 감싼다.
- 성공한 한 snapshot의 UI outer proof를1회만 열고, 기존 whole admission·각 raw/hash
  비교·두 font inverse·그 밖의 오류 수집을 그대로 실행한다. 호출간 캐시0.
- context 진입만 좁게 catch한다. 진입 실패 시 기존 delegate를1회 실행해 진단을
  모으되 최초 실패를 반드시 보존한다. 같은 오류는 중복 추가하지 않는다.
  delegate 예외는 재시도/삼키기 없이 전파하고 모든 종료에서 context token을 복원한다.
- 원래 proof 모듈·immutable pin·역사 source/receipt·Chapter1 debt/gap·장면·조건·
  UI/EN/KO/JA/CN/TW·저장·공개demo·인간/원어민 원장 변경0.

## 파일 소유

- /root/receipt_bridge392: `tools/chapter1_core_loop_v2_causal_ledger_check.py`
  새 appendix만(기존 본문/267 prefix/main 불변).
- /root/receipt_tests392: 새 `tools/chapter1_ui_proof_reuse_check.py` focused검사만.
  implementation wrapper의 공개된 callable seam을 써서 파일 소유를 겹치지 않는다.
- Root: `tools/audit_scope.json`에 새 targeted차선/check 등록만,
  CLAUDE·WORK_LOG·STATUS·CODEX_QUEUE·이 사양·완료archive·
  docs/agent_reviews/ORDER-408.json·docs/agent_review_decisions.json.
  private order408 검수 runner/원본 로그는 별도로 보존한다.
- /root/independent392: 비저자 원문/변경/원본focused·normal 증거 검토와
  private order408-independent-review.json만. 직접 재실행0.

## 표적 검수

- focused: 기존 prefix/267 연결 보존, 기존3회→새1회와 결과동일, 기존오류순서,
  진입실패+다른diagnostics, 최초실패뒤 fallback성공에도FAIL, delegate예외1회전파,
  정상/실패/예외 token복원, nested원token유지, 다음호출의fresh Git/HEAD/raw 실패거부,
  실패뒤정상복구, admission실패시 historical projection차단을 다룬다.
  scoped spy/mock의 제어흐름 증거와 실제 immutable proof검증을 구분한다.
- 실제 최종후보 Chapter1 normal1회: 같은 debt8/blocked3/gap24와 모든 기존diagnostics.
  collector/UI 전체검증은 이 normal의 실제 admission 안에서 그대로 작동한다.
  비교시간은 보존된407 original normal을 사용하며 비교용 구버전 재실행0.
- 새focused1회·Chapter1 normal1회·audit_select list/verify·context/queue/diff만.
  변경하지 않은406focused·이전 전체self-test·locale/PNG·전체감사·240주 재실행0.
  원본보존, clean source/helper before/after. 실패 시 해당 영향만 새시도로 재검증.
- Godot 실행/실제 입력0: 이번에 화면/입력 품질을 새로 관찰했다고 주장하지 않는다.

## 경계

일회성 사양/상시규범 추가0. 자동PASS는 계약 증거이지 재미·문체·출시GO가 아니다.
공개GO1·인간OPEN45·본편/새packageHOLD, 원어민/인간/물리 미관측을 보존한다.
EN Tenure잘림·60이상 의미수리와 Claude B3/B4는 별도 후속이며 이번에 섞지 않는다.
외부 출시·스토어·지출·법률0.
