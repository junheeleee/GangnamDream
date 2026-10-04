# ORDER-428 — 번역 검수의 중복 역변환 계산을 줄인다

#### [~] ORDER-428 [P1·QA 효율] 호출 내부의 순수 비교 결과 한 개만 재사용

**[~] 착수 — 2026-10-04.** 사용자 검수 효율·계속 개발·main 커밋/푸시 위임.
같은 snapshot이 연속 전이의 successor/previous로 다시 역변환되는 확인된 병목만 고친다.

## 판정 단위·소유

- root: tools/ui_translation_append.py의 현재 validate_history nested comparison 연결,
  새 _comparison_memo와 모듈 설명의 해당 경계; tools/audit_scope.json 새 명시 차선;
  큐·사양·CLAUDE·WORK_LOG·생성STATUS·archive·agent 보고/판정원장.
- receipt_bridge392: 새 tools/ui_comparison_memo_self_test.py 한 파일.
- receipt_tests392: 새 private428 A/B 계측·normal 실행 helper만.
- independent392: 코드·표적 음성대조·실제 A/B/normal 원본의 비저자 검수 및 최종 보고.
- 기존 self_test·역변환3·Git object/source proof·manifest·split step/finish·validate_append·
  current_proof·종료 HEAD 확인 본문은 비소유다. 번역·원장·게임 source·public demo·
  인간 판정·출시 manifest·기존 실패/성공 증거는 변경0이다.

## 구현·증거

- 한 validate_history 호출 안에서만 슬롯1개를 만든다. canonical path 전체모집단,
  path별 원문 bytes, append-only 교정 목록의 길이(epoch)가 모두 같아야 재사용한다.
  의미 JSON/길이/객체 identity나 지난 PASS는 key가 아니다.
- 입력·저장·반환 dict alias를 차단하고 immutable bytes만 받는다. 역변환 성공값만
  저장하며 예외는 저장/숨김0. 새 public 호출은 새 슬롯이고 Git/원문/현재 census/
  proof/HEAD를 다시 검증한다.
- 표적검사: 동일값 별도dict hit, path별1byte/누락/추가와 epoch0→1→2→3 miss,
  alias/실패반복·복구·한 슬롯 eviction, 실제 세 역변환 동치, public 호출 재검증과
  종료 HEAD 오류·Git/raw/source 실패를 확인한다. synthetic double은 실제 Git 증거와 구분한다.
- 새 표적검사는 baseline에서 위 최소 hunk와 새 helper만 제외한 원문 전체 보존,
  기존 self_test/역사 pin 불변을 확인한다. 과거423 등 역사 focused를 다시 돌려
  옛 전체 hash를 현재에 맞추지 않는다.
- clean 같은후보의 fresh process A/B를 각각1회 실행한다. A는 private 계측기에서
  helper만 기존 uncached loop로 바꾸고 B는 실제 memo를 쓴다. 생산용 OFF옵션0.
  실제 order365 CLI 출력·current_proof history/census·Git/proof 호출 흔적의 동치,
  역변환 호출수/시간·전체시간을 결속한다. 속도 개선은 실측 전 보장하지 않는다.
- B를 해당 normal행으로 재사용하고 나머지 영향 normal을 최대3병렬 각1회만 실행한다.
  engine/full audit/240주/옛 focused0. 실패 시 원본 보존·원인 한정수리이며
  모집단 축소·판정 캐시·필수검사 생략으로 통과시키지 않는다.

범위는 검사 구현의 동치·효율뿐이다. accepted41572/b203·CN/TW1691·JA3044 및
공개GO1·인간OPEN45·본편/새packageHOLD를 유지한다. 원어민·인간·물리 관측0.
성능 수치는 일회성이며 호출-local 계약은 helper docstring/표적검사가 소유한다.

## 구현 후보 — 2026-10-04

- production은 기존 nested comparison1개를 호출local factory로 연결하고 EOF33줄
  helper만 추가했다. 모듈 설명은 판정결과 캐시 금지를 정확히 구별했다.
- 새 focused120case 첫실행14.304초 PASS. 슬롯/epoch/raw/alias/실패·새 public 호출의
  합성모델과 실제20고정blob/3역상 표본을 구별했다. 기존 module의 허용2치환 외
  전체바이트·기존self_test·교정원문은 보존했다. 현재 전체history실행0이다.
- 사전 결과는 원래 PTY 출력에서 apply_patch로 전사했음을 명시해 보존했다.
  clean 같은후보의 최종focused/실제A/B/공통normal·독립 최종판정은 아직 미실행이다.
  속도 개선이나 기존GO 재사용을 주장하지 않고 번역/게임/원장 바이트를 유지한다.
