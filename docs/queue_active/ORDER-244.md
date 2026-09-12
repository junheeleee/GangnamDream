# 칭호 현지화의 Chapter 1 역사 스냅샷 정합

#### [~] ORDER-244 칭호 원형 검사 정합

[~] 착수 — 2026-09-12, Codex. 기준 HEAD `887064972a9748475a9577efd1d607fd2199e316`,
제품 `33179f88ef1222a14cf585e13fe427b8e3482a6b`. 일회성 1원인 수리다.

## 관측과 범위

앞선 명시11은 9 PASS/2 FAIL이다. Chapter 1 일반/self 두 실패의 유일한 원인은
242에서 추가한 MetaProgression 칭호 번역30줄이다. 243의 원래3원인에 합치지 않는다.
최초 결과 `.git/full-game-localization/order243-named-first.json` 372,230B
SHA `7854ff0cb7e1b7186a6856c878cad750266a195171208a9e61df4e2ebeca22f4`를 보존한다.

현재52,819B/`5bc1465e18ae3e36ef5daef1c27dd3923d1566884e5d0545e6b00c2c7893ab58`의
정확한2,823B 삽입을 역변환하면 옛49,996B/`a36617f4979e08a37e89cecc0566a4e64d54bb5373469e2fa1e162d10dde34dc`다.
먼저 현재 raw를 검증하고 그 뒤 역사 관측값만 투영한다. 옛 pin·기준선 갱신,
이전 제품 롤백 허용, 런타임·번역문·조건·저장 수정은 금지다.
사전18입력·API는 private `order244-meta-title-history-preflight.json` 16,998B
SHA `b5c51b34637f594755a583436d9023547b70056344a6c4c452f8c4d2916967de`다.

깊이3문: 없으면 정당한 번역을 옛 source 검사에서 차단한다. 선택과 24주 상태는
변경0이다. 다음 칭호 번역과 경쟁하지만 실패 원인부터 닫는다. 1년/5년 영향은
검사 기반뿐이며 공개 GO1·인간 OPEN45·본편 HOLD를 그대로 둔다.

## 파일 소유권

- Rawls: 신규 `tools/meta_title_locale_history.py`, 기존
  `tools/chapter1_core_loop_v2_causal_ledger_check.py`의 import·현재 raw gate·역사 관측 hook만.
  243 저자가 반환한 파일을 승계하되 기존243 helper/220함수/26표본/옛 pin은 보존한다.
- Plato: 신규 `tools/meta_title_locale_history_self_test.py`의 고정18 정상/변조 회귀.
- Root: `tools/audit.sh`, `tools/audit_scope.json`의 신규 검사 등록·실패 전파·변경 전용 차선.
- Root 운영: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  본 사양·`docs/queue_active/ORDER-243.md`, `docs/queue_archive/ORDER-244.md`,
  `docs/WORK_LOG.md`, `docs/STATUS.md`, `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`,
  `docs/agent_review_decisions.json`, `docs/agent_reviews/ORDER-244.json`.
- Poincare: 제품 저작 없이 독립 전량 검토·private 증거.

나머지 제품·기존243 신규28·JA pipeline·번역 사전·수용38,638/b99·인간 원장·
`project.godot`·옛 manifest·손상된 로컬 mirror는 raw 보존한다.

## 검증과 완료

18 입력은 구현 전에 고정한다. 정상 current의 통과 없는 변조 거부는 PASS가 아니다.
wrong/case path·옛 raw·문구/ID/필드·함수/저장·registry/forged 관측은 계속 거부한다.
새18과 실패한 Chapter 1 일반/self만 다시 실행하고 기존 녹색9는 과거 증거로 보존한다.
현재 차선의 등록·큐·문서 검사는 변경 범위만 수행한다. 기존9의 재사용은 각 입력
변경 여부를 결속하며 새 현재 PASS처럼 재발급하지 않는다.

clean 제품·검토 HEAD와 독립 검토 뒤243과 합쳐 GitHub 일회성 runner의 exact CI를
요청한다. 로컬 전체 감사/실제 세이브 사용0. CI 밖 새 실패는 별도 오더다.
자동/정적 증거는 렌더·원어민·인간 실플레이·재미·전체판 GO가 아니다.
