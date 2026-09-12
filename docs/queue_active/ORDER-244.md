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

## 구현 고정

칭호 raw helper와 Chapter snapshot hook만 연결했다. import1·raw gate·observer를
역제거하면 기존 Chapter 전체와 옛 map/159함수 원형이 exact다. 새18 명세 SHA
`b19daec06150fecf571dbc034d257c43ef9d6f463686294b267cdf1f86a49556`,
self SHA `0f00061417669ae026bd3d647156dad9a0e0b4920ee0c4414e49a5c26fdfcdf9`.
저자 own18 cheap 첫1회는 PASS18/입력8 exact이며 최종 self의 최초 실행과 구분한다.
새 명시 차선은18·실패 Chapter2·변경 운영5의8검사다. 기존 제품 녹색4를 다시
실행하지 않고, 운영5는 선언/등록 입력이 바뀌었으므로 현재 범위에서 검사한다.

## 최초 검증과 원격 후보

HEAD `41e06cd5ca0b0ed221ff4498dc3d3a4f656ba008`, 제품 `fb4cf1195a39c2ec231d2a2731dc4cfaf902de4a`.
최초 명시8은 전부 exit0,683.44초/입력1,200 전후exact·clean이다. 새18 전부 유효,
Chapter 일반은 기존 gap24/debt8, self는590(635.65초)을 통과했다. 등록145·queue25/
fence4·agent222·context359·active77이며 기존 원형 gap을 완성했다고 쓰지 않는다.
원형 `order244-named-first.json` 309,092B SHA
`6c7fd48f0e08eccda4685d1edfa547e95df22371feabe02eae86a7a4db547d45`.
동일 exact HEAD를 main/원격 mirror에 FF했고 CI main34691376114·mirror34691376116이
시작됐다. 최초 관측은 둘 다 in_progress이며 성공·최종 unit GO는 아직 아니다.

최종 관측: mirror는12:18:10Z, main은12:29:59Z에 failure로 종료했다.
두 job의 실패는 audit runtime runner seal expected af026c51/got784d936d의
self/contract2뿐이다. 앞선8의 로컬 통과를 원격 전체 PASS로 합치지 않는다.
main log421123B/b04213d4, mirror420975B/9e3f7209, metadata39460B/673b098e를
private 원형으로 보존했다. compile68 각각PASS·후속실제입력/시뮬 skipped·업로드0.
별도 RO 원인 보고 e6d3d399는 기존정책 보존과 최종 audit raw 재봉인을 제안한다.
새 원인은 다음 좁은 선언으로 분리하며 최종 단위판정과 본편HOLD를 유지한다.
