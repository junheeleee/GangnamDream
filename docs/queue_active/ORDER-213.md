# Active Queue Spec: ORDER-213

> [~] 착수 — 만지는 파일: 감사2와 이 사양·큐/L3·audit_scope·CLAUDE/WORK/STATUS·결과 기록만. 제품 번역/manifest/사람 판정은 바꾸지 않는다.

#### [~] ORDER-213 [P0·CI 정합] 승인 번역과 역사 보호 지문을 분리한다

기준 제품은 선언 직전 3300a39f6e9fef0af2c182ae86c63390468ede7a로 고정한다. 원문·번역·portable·배포판은
그대로 두고, 승인된 번역이 오래된 빈 파일/초기 CN pin과 충돌하는 두 검사만 수리한다.

## 실측 문제와 권한

- 원격 fb02197 CI34306171104의 최종 실패는 YEAR5_REFERENCE_ROUTE_EXIT와
  CHAPTER5_HUMAN_REJECT_EXIT다. e87 소스의 읽기 전용 재현도 ending3/CN1 오류다.
  기존 자동 결과를 인간 실플레이·원어민 판정에 합산하지 않는다.
- 엔딩은 ORDER157의6e088e5→159의fc749d1→160의74be170에서
  0→3→17→35종으로 승인·번역됐다. 현재3파일은 마지막 커밋과 raw exact다.
- CN 공개 원문은 ORDER165 선언e9f5993 뒤 ef931a5에서
  ‘这些记录留在同一块屏幕上。’ 한 문장을 ‘这两条记录留在同一块屏幕上。’로
  한국어 두 기록에 맞췄다. 역치환으로 원래 파일을 raw exact 복원한다.
- 이 작업은 승인된 변경을 정확한 역사 전이로 인식하는 검사 오탐 수리다.
  새 번역 승인·공개판 재배포·사람 GO 재발급이 아니다.

## 불변값과 엄격한 전이

year5 manifest105761B/SHA07c814ea5ea3b7c82157b1aaa3a5bdf15ef251cbb1b2ceda902d1ccc54b3442a
및 files/authorized_source_transitions를 바꾸지 않는다. 원래 빈3파일 SHA는
37517e5f3dc66819f61f5a7bb8ace1921282415f10551d2defa5c3eb0985b570이다.

| 정확한 경로 | 승인된 현재 SHA256 |
|---|---|
| content/endings_ja.json | 24a912608c75e43d9902c4334cfb6926d95647e40b20d3fafadc12f6b046cb7f |
| content/endings_zh-CN.json | 35ab6ba6a5a4b944e8e5f9b16beecdc3fe807dc792d046408d6f83180623f1e8 |
| content/endings_zh-TW.json | 2b895ebe9b27ee4ac98ebe6612462c7d650ef6da19ec0e068ff8dff575f53ec8 |

PUBLIC_DEMO_FROZEN_FILES의 CN old cd67bf8007c6dad44d8c6161a52ad44484ea510ab084acd18f68ba4c535dc142
및 배포 package/product/manifest/사용자 GO를 보존한다. 별도 working-source 전이만
4e749e041c7d463d26aa3c54da284b4d5da1455611b0af651b74a81b6048bbc8로 향한다.
공개 데모5언어 보호와 일반 경로/Property의 OPEN·전체 HOLD는 변하지 않는다.

두 검사 모두 경로와 원래 predecessor가 정확할 때만 고정 current를 사용한다.
expected hash를 현재 파일에서 계산하거나, 원래 registry를 current로 갱신하거나,
locale 디렉터리 전체를 면제하거나, 추가 문자열/순서/메타 변경을 승인하지 않는다.

## 소유와 검증

- 구현: tools/year5_reference_route_audit.py, tools/chapter5_human_reject_audit.py.
  새 고정 회귀는 각 파일 안에 추가하고 기존 self 함수·fixture AST는 보존한다.
- 운영: docs/queue_active/ORDER-213.md, docs/queue_archive/ORDER-213.md,
  docs/CODEX_QUEUE.md, docs/CODEX_QUEUE_L3_PENDING.md, tools/audit_scope.json,
  CLAUDE.md, docs/WORK_LOG.md, 생성 docs/STATUS.md.
- 번역/KO/EN/runtime/save/font/원장/manifest/사람 gates·다른 오더 수정0.
- normal4와 unknown old/current·rollback·다른언어/경로·삭제/순서·메타·토큰/LF·
  original registry 갱신 등 변조를 실제 검사 함수에 넣는다. 기존 self도 전량 실행한다.
- audit_scope에 두 감사 파일만의 순수 소스 차선을 추가한다. 기존 일반/Godot 매핑은
  그대로 두고 year5 정적 본검사 등록을 보강한다. --list 뒤 차선 단독으로 실행한다.
  public localization와 full-body scope, context/queue/index/verify/diff를 함께 확인한다.
- 대상은 보호지문 비교뿐이므로 이번 배치에서 전체 audit·Godot·240주를 새로
  실행하지 않는다. 원격 CI는 새 exact commit의 실제 상태만 보고하며 대기/실패를 GO로 바꾸지 않는다.
- 기준 제품과 제품 파일 전체 diff0, 기존 보호표·manifest·사람gates raw exact,
  ROOT/독립 검토를 통과한 뒤 개발 main에 정리한다. 이는 출시 승격이 아니다.

단일 유지보수 수리이므로 억지로15~25개 번역 장면을 묶지 않는다.
선언·지문·증거·소유 범위는 일회성이고 지속 새 정본 규칙은 만들지 않는다.

실행 환경: 번역212를 main/origin에 통합한 뒤 현재 main에서 수리한다. 번역 worktree는 clean 상태로 보존한다.
