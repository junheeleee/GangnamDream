# Completed Queue Spec: ORDER-213

> [x] 완료 — 2026-09-09. 감사2와 이 사양·큐/L3·audit_scope·CLAUDE/WORK/STATUS·결과 기록만 수정했다. 제품 번역/manifest/사람 판정은 바꾸지 않았다.

#### [x] ORDER-213 [P0·CI 정합] 승인 번역과 역사 보호 지문을 분리한다

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

## 2026-09-09 수리·검증 결과

선언 `523ca4f5267a33b4a4427728643435dbc57f3aa6` 뒤 감사 두 파일만 구현했다.
기준 제품 `3300a39f6e9fef0af2c182ae86c63390468ede7a` 대비 content/locale/
scenes/systems/autoloads/assets/project.godot/human_gates 변경0이다.
번역32,484·retained metadata9·배치78·원 source_revision과 manifest도 그대로다.

- year5: 원 protected registry와 inherited predecessor가 모두 예전 빈 파일 pin일
  때만 위 승인 엔딩3 지문으로 전진한다. current로 registry를 갱신해도 실패한다.
- public: 원 PUBLIC_DEMO_FROZEN_FILES는 그대로 두고 CN 한 경로의 working source만
  승인 pin으로 비교한다. 역치환은 원래 파일을 raw exact 복원한다.
- 알려지지 않은 경로/old/current, rollback, 순서·삭제·메타·토큰·LF 등 변조를 거부한다.
  현재 파일에서 expected 값을 만들지 않으며 디렉터리 면제도 없다.
- 기존 self3개와 기존 global AST를 보존했다. 독립 코드 검토 필수 지적0.
  별도 독립 범위 검토에서도 1,850파일610,761,110B의 raw·경로·mode 변경0이다.
  자동/에이전트 결과를 사람 GO로 합산하지 않는다.

`translation-protected-hash-reconciliation --list` 뒤 같은 차선을 단독 실행해
11검사 전부 PASS했다. year5 self460=기존420+신규40, public self127=기존79+신규48다.
focused 신규40의 반복 실행은 460에 다시 더하지 않는다. 두 정적 본검사도 PASS다.
full-body scope52, 공개 localization 변조4·5언어14사건/100leaf/121UI,
queue-index25/fence4, 등록139, context·queue도 통과했다.
폐쇄 문서·대시보드의 context328/links130·queue75/in_progress73·index25/fence4·
등록139·EN clean·diff0도 다시 확인했다. 큐/L3는 기준 제품의75행과 raw exact,
WORK는 기존39,265B를 보존하고466B만 더해39,731B다. history 변경0이다.

| 동결 코드/증거 | bytes | SHA256 |
|---|---:|---|
| tools/year5_reference_route_audit.py | 600344 | 84e898381de8cfc958fa21ced517ece5bccc3d6e30c3435c079345e4b4949f98 |
| tools/chapter5_human_reject_audit.py | 119529 | cd5832a0d3d93715d4b68f49abc7133a796ecfe0e29a3d285be161f53239835f |
| private/order213-year5-transition-final.json | 9058 | c6851739d9ec9fc3a3f2591fe6f293f7568d0429318ddb4fed87caa85eed1d14 |
| private/order213-public-source-final.json | 1359 | 89488d72aa2438870a87a5244608bb9f51fd5240e2adc12191022842c9c17b20 |
| private/order213-root-lane.json | 6961 | 879b44e1f2c2603e0fb418d8376e9954e19664db1187e3a1de2d6162d17df8f2 |
| private/order213-root-scope.json | 1707 | 9c1850d1c83858ea35accea3c901cb376e65b24a5f48adc653c5cc97eee4d259 |
| private/order213-root-closure-checks.json | 6432 | e9160d930eb097d9279c59b69a6d46ee8fe7ad5d76b8ee419f4d51e0d86c88ae |
| private/order213-independent-product-scope.json | 7343 | dbfb58474edc9fdc5e7e1c4bc4cdd6117bf55f4726aa08dbc4d23dd01eae6e89 |

private는 이 세션의 git-private `full-game-localization` 증거 디렉터리다.
수리 전 엔딩3 오류와 원격 e87 CI34310713725의 동일4지문/두 감사 실패는
before 및 `order213-current-main-ci-failure.json`에 보존했다. 성공으로 덮어쓰지 않았다.
새 개발 커밋의 원격 CI는 별도 실행 상태이며 이 로컬 PASS를 전체 CI GO라 부르지 않는다.
전체 audit·Godot·240주·원어민·인간 실플레이는 이번 수리에서 실행하지 않았다.

규범 판정: **일회성** — 이 네 역사 전이의 범위·소유·증거만 정리한 유지보수다.
지속 정본 규칙 추가0. 공개 M01~M06 사용자 GO, 원어민/화면/L3 OPEN,
Chapter 5 기존 사람 게이트와 본편 INCOMPLETE/HOLD를 전부 보존한다.
