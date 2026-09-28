# Active Queue Spec: ORDER-375

#### [~] ORDER-375 — 검증된 UI 번역 append의 재사용 가능한 검사 연결

**[~] 2026-09-28 착수 — 만지는 파일: `tools/order365_ui_receipt_compat.py`, 새 `tools/ui_translation_append.py`, 새 `tools/ui_translation_append_self_test.py`, `tools/audit_scope.json`, `docs/I18N_INFRASTRUCTURE.md`의 사용법, 이 사양·큐·마감기록.** 사용자의 검수 효율화 지시로 실제 병목을 한 번 수리한다. 원문/게임/번역 저작은374 소유, 여기서는 검사만 소유한다.

## 확인된 문제와 범위

- `order365_ui_receipt_compat.source_errors`의 사전2+원장 전체hash 고정 때문에 기존 export/check/import로 적법하게 추가한 번역조차5현재소비자가 거절한다. 매배치 새역사승계모듈을 쓰는 비용을 없앤다.
- 기존365의22키/40346/b143와 immutable Git/이전351proof·모든역사 pin은 그대로 검증한다. 이후 **추가만** 허용하는 별도 증분검사를 둔다. 기존키 수정/삭제·알수없는언어/leaf·공개보호키·기존receipt/metadata/batch수정은 거절한다.
- 각 신규batch에 공식 import receipt의 header를 `official_receipt_headers_by_locale`로 보존한다(374가 기록). private파일 없이 header+공식accepted추가행으로 receipt를 재구성하고 기록digest와 대조한다. 현재KO소스와 해당지역 target도기계검사한다. 자체일치hash만으로신뢰하지 않는다.
- 현재실제 Git 후보의3파일blob과 제출raw를 결속한다. 역사승계의검증과 현재성공을 혼동하지않고 과거payload/부분승계/동시위조/rollback검사를 둔다. 승인된baseline까지 정확raw역삭제가성립해야하며 줄공백/기존byte도보존한다.
- `full_game_localization.collect()` 재사용은 호출순환없음을 검토했다. 현재호출문맥 안에서만 수집/검증결과를 재사용하고 다른호출/source로 성공cache하지 않는다. 관측API는 current bytes/payload를 그대로 유지하며 역사raw를현재관측으로반환하지 않는다.

## 소유와 판정

- compat357: 위 도구3개/registry만 저작, private 자가자료. 기존consumer5파일은비소유이며필요하면먼저root에알린다.
- root: I18N 사용법1단락·metadata·375의표적실행.374의번역/원장과분리한다.
- r3_route_probe: 비저자검수. 원본코드/회귀증거/실제375diff로 판단, 번역author와도분리한다.

## 표적 증거

- 새양성: baseline그대로, 이번94×2적법append, portable새checkout자료, 현재3파일관측일치.
- 새음성: 누락/추가/중복key,기존값/공백/receipt/batch변경,신규source/target/locale/digest/header위조,보호키,미지원consumer,staleKO,실제Git/raw불일치,부분/전체rollback. 합성실행의격리경로만변경한다.
- 과거365self/consumer/font증거는보존한다. 과거양성을현재로속이지않고기존fixture를명시적으로검사하며 새현재회귀를분리한다. 원형240+12+60을지우거나baseline완화하지않는다.
- 검사코드변경때문에새self와현재5normal을실행한다. 옛1955/689/full240주·엔진은375에서실행하지않는다.374실제화면과비중복이다.
- 작업중확인된기존liveness Python-launcher오탐은비소유로FAIL보존한다. 전체감사녹색/상품GO/원어민/인간/물리/출시를주장하지않는다.
- 깊이3문: 삭제하면적법한새번역이legacy검사에막힌다; 게임상태/선택을바꾸지않는다; 반복검사시간을188문구와실제소비자검수에배분한다.
- API사용법은I18N기존증분절에링크로승격, 이배치와파일소유/회귀모집단은일회성. 새gameplay정본·출시언어변경0.
