# ORDER-414 — 일본어 선물 설명 두 의미 교정

#### [x] ORDER-414 [P1·현지화 수리] 에세이집과 향수의 일본어 설명을 한국어 뜻으로 되돌린다

## 완료 — 2026-10-04

- sourcec5e7b4e03f871e4a4a509c851cacb54cd255a7f0/tree3bef1595624a0a937a86550232cdff74c3992c97 한정 독립GO.
- JA2값 교정·첫receipt2/batch1, accepted41252/b185. 신규키0/게임조건0/기존raw역상 보존.
- 실제runtime47462fc의2PNG·4binding·2typed복원 9.583초PASS; 최종후보는 QA Python2파일만 달라 화면을 재실행하지 않았다.
- 최초15명령은 leaf정렬 오탐·조회옵션 오류로 FAIL876.304초. 원본 보존 후 focused94부터 실패8개만 재검사776.335초PASS, 기존7PASS 재사용.
- 독립 [보고](../agent_reviews/ORDER-414.json), private SHA942af46dbe21c9d0f6eb1d70c13164cbf253ac19181616bf9abe0ce3a847e672.
- source2990/helper71/입력5/최초증거80 불변. 공개GO1·인간OPEN45·본편/새packageHOLD 보존.
- 승격: 없음(일회성 수리·검수). 자동PASS는 계약증거이지 재미·문체·출시GO가 아니다. 원어민/인간/물리·자연진입/전달 미관측.

## 아래는 착수 선언 원문

**[~] 착수 — 2026-10-04.** 사용자 계속 개발·품질검수·main 커밋/푸시 위임.
412/413 독립 대조로 확인한 기존 JA 설명2곳만 별도 교정한다.

## 판정 단위·깊이3문

- 에세이집은 '밑줄을 그을 대목이 많음'인데 기존 JA가 '이미 너무 많이 그어짐'을
  발명한다. 향수의 '가격이 먼저 보임'은 기존 JA에서 일반적인 '가치'로 바뀐다.
- 상태·가격·선물 반응·주차 변화0. 기존 두 설명의 의미를 수리한다.
- 확인된 두 결함을 한 수리 배치로 묶는다. 신규 UI 키0/수정값2,
  기존 공식수용 이력은 없어 첫 공식 receipt2/batch1이 추가된다.
  번역 키 증가와 공식수용 증가를 구분한다.

## 정확 모집단과 소유

- 제품: locale/ui_ja.json의 아래 두 기존 값만, content/meta/full_game_localization.json의
  해당 첫 receipt2·checksum·새 JA batch1만 root가 수용한다.
  1. `밑줄 그을 자리가 많은 책` — 기존 `下線が引かれすぎた本`
  2. `값이 먼저 보이는 선물` — 기존 `価値が先に見える贈り物`
- 실제 소비자: MainGame::_gift_display_desc → _build_gift_shelf_card / _open_gift_picker.
  코드·KO/EN/CN/TW·상품명/카탈로그·나머지 JA·가격/조건·게임 상태 불변.
- /root/receipt_bridge392: tools/ui_translation_append.py 새 exact legacy-target
  transition/비교역상. 현재 validate_history의 전용분기·최초receipt 집계 소수 hunk만
  연결하며 함수전체복제0. 앞선 380/384 correction·392 split 및 generic append 거부 보존.
- /root/receipt_tests392: tools/ui_translation_append_self_test.py 새 표적 body/dispatch와
  tools/audit_scope.json 연결, 새 private414-focused-* helper만.
- Root: JA직접초안·공식교환/수용·새 private414 화면helper·격리엔진실행·통합.
  제품2path만 먼저 commit하여 실제 parent/tree/blob를 proof의 대상으로 고정한다.
- /root/independent392: 저작 아닌 두 값 원문/수용/교정proof/실제화면/검사 원본
  독립검수, private414-independent-review.json 단1회 동결.
- Root운영: 이사양·CODEX_QUEUE·CLAUDE·WORK_LOG·생성STATUS·완료archive·
  docs/agent_reviews/ORDER-414.json·docs/agent_review_decisions.json.
- 기존 source-history module·공개demo·인간원장·project.godot·출시manifest 비소유.

## 최소 교정 계약

- 정확 두 기존 KO leaf를 clean parent에서 한 공식 JA export/check/import.
  --replace-existing을 명시하며 exported previous_target_sha256를 보존한다.
  미수용 legacy였다는 실제 증거를 유지하고 원래 batch/receipt를 발명하지 않는다.
- 기존 generic validate_append는 임의 기존값 수정을 계속 거부한다.
  exact Git direct-parent·제품2path·tree/blob/raw·현재 KO source·새 두 target/header/
  receipt digest를 증명한 이 전이만 허용한다.
- 두 JA raw값을 되돌리고 새 receipt2/batch1만 걷어낸 비교역상이 이전 전체 bytes와
  같아야 한다. 현재 UI로 비교역상을 공급하지 않는다. 후속 정상 append 허용,
  교정 rollback·혼합 무단변경·HEAD/Git실패는 거부한다.
- 기존 교정/split helper 원문·핀·기능·과거 self-test는 보존한다. 새 반복검사나 범용교정
  시스템을 만들지 않는다.

## 표적 검수

- 비저자 두 값 KO직접 의미 전수대조·토큰/조건/인물 사실 추가0.
- isolated pre-autoload 실제 JA1280×800: 생활진열대와 전달선택창의 두 상품설명
  각각 표시. 두 target이 한 화면에 함께 온전히 보이는 scroll 위치를 사용해
  소비자당1컷·총2PNG, 2 lookup/4 binding. 기존 나머지40가격/14중문화면 반복0.
  준비state는413의 검증된 gosiwon·money500000·8종각2·daeun met/affinity8/AP1/cd0.
  실제 JP14px·fullfit·카드 containment·서로겹침없음, typed복원·player/source/helper불변.
  구매/전달/confirm/raw/time0. 자연진입·Back·물리 입력 관측 아님.
- 새교정 표적검사만 1회: 정확한 교정허용, 부분/이웃/타언어변경·중복key·잘못된
  source/previous-target/header/digest·누락/중복/가짜과거receipt·raw형식·Git parent/
  path/object·호출간HEAD/Git변경·후속append/rollback 거부.
- 최종 normal receipt/fullbody/storygraph/Chapter5/Year5/Chapter1/JA/ZH/EN/context/queue/diff와
  audit_select 목록조회는 변경영향상 필요한 항목만1회, 최대3병렬.
  Chapter1timeout1200, helper AST사전확인. 과거self/완료화면/전체감사/240주 반복0.
  실패 원본을 남기고 실패영향만 새 시도로 검사한다.

## 경계

일회성 수리사양·상시규범 추가0. 자동PASS는 계약증거이지 문체·재미·출시GO가 아니다.
공개GO1·인간OPEN45·본편/새packageHOLD·원어민/인간/물리미관측을 보존한다.
전체판 번역·Claude B3/B4·다른UI결함은 별도후속이며 외부출시/스토어/지출/법률0.
