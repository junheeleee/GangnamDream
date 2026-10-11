# ORDER-558 — 수리를 포함한 full 검수 후보 발급

#### [~] ORDER-558 착수 — 2026-10-11

사용자의 전체 출시 검수 지시를 따른다. 이전 a0bc 앱은 이름·통화 종료·시간·
투자체험·NG+ 수리 이후의 소스가 아니므로 새 후보를 먼저 만든다. 외부 출시가
아닌 내부 검수용 full 후보 발급이다. 이 선언을 main에 push한 뒤 구현한다.

## 깊이 3문

1. 새 앱 없이는 소스 수리와 실제 관측의 후보가 달라진다. 이전 앱의 GO를
   새 소스에 가져오지 않고 clean revision/tree와 산출물 지문을 결속한다.
2. gameplay·원문·번역·저장 schema 변화0. BUILD_ID만 새 발급 날짜/순번으로
   바꾸며 BuildInfo의 기존 비호환키 아님 규칙과 저장 읽기 정책은 유지한다.
3. 과거 앱 재사용 대신 fresh full-rc Win/macOS/Linux 발급을 택한다. 빌드 성공을
   native 플레이·Steam Deck/Windows 실기기·원어민·출시 GO로 확대하지 않는다.

## 파일 소유와 실행

- root: `systems/BuildInfo.gd`의 BUILD_ID 한 값, 이 사양·큐2·마감
  `CLAUDE.md` 현재행·`docs/WORK_LOG.md`. 제품/프로젝트/원고/번역의 다른 편집0.
- phone_cn_author: `.git/order558-build-20261011/` private 공간에서 기존547 발급
  절차와 build helper만 재사용한다. 새 detached clone·fresh HOME/XDG·기존 설치
  templates의 읽기 전용 symlink→`tools/build.sh full-rc`→macOS 앱 압축 해제.
  새 영구 runner/체커·등록·이력/검증최적화0. helper는 root가 읽기 전에 실행하지 않는다.
- phone_independent_review: helper/후보 신원/산출 manifest/PCK·실제 원로그·보존을
  읽기 전용 독립 검수한다. formal 오더보고/판정원장행 추가0.
- cjk_wrap_diagnosis: 큐2의 순번·범위만 소유하고, 이후 metadata 읽기 전용 검수.

## 검증·보존·완료 경계

- `2026.10.11.1`을 BuildInfo에 발급하고 clean 커밋의 날짜/first-parent 규칙을
  기존 build_identity_audit로 확인한다. fresh clone에는 시작 전 .godot가 없어야
  하며 full-rc가 import/Win/macOS/Linux/통합 manifest를 소유한다.
- 실제 exit·원 stdout/stderr/Godot 오류를 확인한다. macOS deep/strict 서명과
  universal arm64/x86_64, PCK payload digest·필수 notices·타깃 이미지 import,
  source revision/tree/ZIP·앱·PCK 지문을 기존 함수로 검증한다.
- 원 project/presets·공개 데모 package/userdata·player·Human/판정원장·원556 W62와
  관측 원자료를 전후 보존한다. 원 사용자 app/editor/설정·저장을 사용하지 않는다.
  root·private checkout 소스가 바뀌면 발급을 중단하고 실패 자료를 보존한다.
- Win/Linux는 발급/정적 신원만이며 native 실행을 주장하지 않는다. 이 오더에서
  앱 플레이는 하지 않는다. 다음 월별 오더가 원W62 한 파일을 새 HOME/XDG에
  복사해 정상 Continue로 M16을 잇고, 선언/관측/마감을 한 커밋에 묶는다.
- 제품동작 검사 삭제/완화·ObjectDB 추적·479/481·STATUS 단독커밋0. 자동 계약은
  재미·깊이·문체/인간품질 증거가 아니다. 옛 strict FAIL/HOLD·공개 GO와 Human은
  보존하며 새 후보의 전체 제품/출시는 HOLD다. 새 규범0, 실행 지시 일회성이다.

## 완료 증거

후보 revision/tree·세 플랫폼 산출물/통합 manifest·PCK/서명·실제 로그·보존·
비저자 판정으로 채운다. source/발급과 다음 native 제품 관측을 구분한다.
