# ORDER-560 — CJK 지원 데이터 full 후보 수리

#### [~] ORDER-560 [패키지] 착수 — 2026-10-11

547·558 실제 Mac PCK에 ICU member가 없었다. JSON 번역은 Godot Translation
resource가 아니므로 자동 감지가 이 요구를 찾지 못한다. 공개 데모는 바꾸지 않는다.

## 깊이 3문

1. 지원 데이터가 빠지면 실제 일본어·중국어 단어/줄 경계가 깨질 수 있다. 소스
   문장을 억지로 개행하거나 폰트를 바꿔 패키지 누락을 덮지 않는다.
2. 다음 full-rc도 같은 누락을 내지 않도록 기존 발급 입구에서 설정을 거절하고,
   실제 새 PCK 데이터 바이트를 대조한다. 설치 파일 존재만으로 성공하지 않는다.
3. 원 프로젝트·preset 보존과 재현 가능한 clean 후보가 함께 필요하다. 별도
   build-only commit의 실제 SHA/tree를 발급하며 main base라고 허위 표기하지 않는다.

## 파일 소유·범위

- cjk_wrap_diagnosis: `tools/build.sh`, `tools/build_identity_audit.py`만 구현한다.
  기존 full-rc 설정 admission·missing-data 경고 거절·기존 self-test를 확장한다.
  일반 WARNING 전체 거절·root 설정 자동변경·새 checker/등록·영구 stage generator0.
- root: 이 사양·큐2·`docs/BUILD_PIPELINE.md` 정본·CLAUDE 현재행·WORK_LOG·마감,
  private clone의 `project.godot` ICU key와 `systems/BuildInfo.gd` BUILD_ID만
  apply_patch하고 local commit한다. 원본 두 파일은 수정/스테이징0이다.
- phone_cn_author: `.git/order560-build-20261011/`에 기존558 adapter/safety/PCK
  readers를 재사용한다. prepare/build 두 단계만 분리, 새 제품 도구·등록0이다.
  root 전체 helper 읽기와 독립 admission 전 실행0. root native 입력도 이번0이다.
- phone_independent_review: 실제 diff/helper/입구/산출/보호·최종을 읽기 전용 검수.
  formal 오더보고/판정원장행0, 저자 자가 GO로 대신하지 않는다.

## 구현·후보 신원

- full-rc는 import 전에 `[internationalization]`의
  `locale/include_text_server_data=true`를 요구한다. 기존 build_identity의 명시
  옵션으로 검사하며 root 기본 정적검사에 이 설정의 부재를 실패시키지 않는다.
- 공식 exporter missing-data 경고는 exit0/새 artifact가 있어도 거절한다. 기존
  error/stale/date/clean/fresh-import/manifest 검사와 mock self-test를 유지한다.
  경고 번역의 한계는 실제 raw 판독·PCK 바이트 검증과 분리한다.
- 구현을 main에 커밋·푸시한 exact clean source를 fresh detached clone/HOME/XDG에
  준비한다. root만 그 clone ICU key+BUILD `2026.10.11.2`를 고쳐 local commit한다.
  이력 base→stage diff는 정확 두 파일, clean/날짜/first-parent/new ID를 대조한다.
  private base..HEAD bundle을 verify하고 보존, manifest는 실제 stage SHA/tree다.
- 원 root `project.godot`·`export_presets.cfg`·BuildInfo·공개 userdata·player 저장/
  설정·Human/과거판정·원556/559 저장/raw/runtime·557raw·558app/package·templates를
  보호한다. fresh namespace만 생성, 옛 산출물 덮어쓰기/사용자 데이터 이동0이다.
- 같은 private stage에서 기존 full-rc 한 번으로 Win/Mac/Linux를 발급한다.
  engine4.6.2·소스/산출/manifest 해시·Mac universal/deepstrict·전체 PCK MD5/
  고지12·기존6image import binding을 대조한다. ICU member의 실제 바이트를
  기존 설치4.6.2 데이터와 exact 비교한다. 공식 embedded fallback도 합법이므로
  영구 guard는 설치 ICU 파일의 존재를 요구하지 않는다.

## 검증·닫는 범위

- 기존 build_identity `--self-test`(내부 export mock 포함), syntax/context/queue/diff,
  actual fresh full-rc·date/manifest·Mac PCK ICU와 보존만 검증한다. 필요 영향은
  기존 selector로 확인한다. 전체 audit/240주·비용 도구·ObjectDB 탐침0이다.
- 결함/실패 raw를 보존하고 같은 범위에서 수리한다. 입구 승인 뒤 source/spec/helper
  freeze, 별도 private stage patch 경계와 actual stage 승인 뒤 build만 실행한다.
- source 발급보호와 새 package만 GO 가능. native CJK5언어/Win·Linux 실기기/
  인간·원어민·물리패드·청취·게임/출시 GO는 별도다. ICU 포함만으로 줄바꿈 품질을
  관측했다고 하지 않는다. 본편/출시 HOLD·전체번역 INCOMPLETE·옛FAIL/HOLD 유지.
- 지속 규칙은 BUILD_PIPELINE 현행 full-rc 절로만 승격한다. 사양의 실행 지시는
  일회성이다. 뒤에559 소득 약속 문안 수리와 원W68 본편 정상 이어보기를 잇는다.

## 실제 결과

선언 전. 구현·실제 산출·독립 검수 뒤 채운다.
