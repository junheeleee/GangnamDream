# 본편 현지화 누적 변경과 전체 CI의 정합 수리

#### [~] ORDER-243 현지화 CI 정합

[~] 착수 — 2026-09-12, Codex. 기준선 main
`5c545a71521721e210e8e1ad83565994ffc0f2df`, 제품 `e2147ec3`.
공개 M01~M06 GO1·인간 OPEN45·본편 HOLD는 보존한다. 일회성 사양이다.

## 실물과 판정 단위

이전 원격 `c2cc7fd5` CI run `34686915442`는 timeout이 아닌 failure다.
전체 감사의 5개 게이트가 실패했고 GDScript compile68은 통과했다. 이후 실제
입력/SimRun/SmokeRace는 skipped다. 이를 현재 번역 후보의 PASS로 합치지 않는다.
원형 로그238,873B SHA `82607425d10a4f275c135e243a4505b87a2878091de8063c22042fbdab31b5c0`,
진단23,980B SHA `9526502ed0366561269eb72403eb7b672a271c914ddc07289419cfe4fab8b53f`는
`.git/full-game-localization/order242-prior-ci-*`에 보존한다.

판정 단위는 같은 CI에서 관찰된 독립 원인3개다. 새 번역·원고·기능을 추가하지 않는다.

1. MainGame의 승인된239+240 네 줄을 모르는 year5/chapter1 감사3개 실행을 수리한다.
   현재 raw9029→239 raw014b→220 raw5b의 정확한 역변환만 공유한다. 기존220와
   이전 역사 pin·함수·26개 변조 표본을 재발급하지 않는다. 현 소스로220/239롤백을
   허용하지 않고 현재 raw 검증을 먼저 수행한다. 역사 hash 투영은 판정 권한이 아니다.
2. 일본어 UI는 기존 source replacement 정본으로 확인되는 은퇴한 키만 보존 항목으로
   분류하고 target 품질도 계속 검사한다. 임의 extra-key 허용·UI 키 삭제는 금지다.
3. 중국어 demo self-test는 실제 비어 있는 overlay를 격리 주입한다. 실제 번역이
   채워졌는데도 empty라고 기대한 fixture만 수리하고 strict coverage 비교는 보존한다.

깊이3문: 제거하면 현재 정당한 번역을 CI가 차단한다. 플레이어 선택·24주 상태는
바꾸지 않는다. 남은 UI 번역과 경쟁하지만 실제 CI failure 수리를 먼저 닫는다.
1년/5년 파급은 검사 기반뿐이며 이야기·수치·세이브·엔딩은 변경0이다.

## 파일 소유권

- Rawls: `tools/main_game_locale_history.py` 신규, `tools/year5_reference_route_audit.py`,
  `tools/chapter1_core_loop_v2_causal_ledger_check.py`의 공유 adapter와 self baseline hook.
- Root: `tools/ja_translation_audit.py`, `tools/demo_localization_scope.py`의 위2원인,
  `tools/audit.sh`, `tools/audit_scope.json`의 신규 유한 검사 등록/실패 전파.
- Plato: `tools/ci_localization_reconciliation_self_test.py` 신규 고정 회귀 표본.
- Root 운영: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  본 사양과 `docs/queue_archive/ORDER-243.md`, `docs/WORK_LOG.md`, `docs/STATUS.md`,
  `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`, `docs/agent_review_decisions.json`,
  `docs/agent_reviews/ORDER-243.json`.
- Poincare: 비저자 독립 검토. private 증거만 쓰며 제품 저작 금지.

위 외 제품 파일·JA pipeline·ZH/full pipeline·이전 manifest/pin·번역 사전·portable
수용38,638/b99·runtime/조건/저장·`project.godot`·human ledger·공개 후보는 raw 보존.
로컬 mirror checkout/branch는 손상 상태이므로 건드리지 않는다.

## 구현 전 고정 검증

원형 MainGame 체인은 `order242-ci-main-game-history-preflight.json`
12,410B SHA `2fac74d6a2f5d6a0105de6df82f300a4f4ea14fa7f4c702615fa8e46c0e6c929`에 있다.
정상 현재1, 네 단일 줄 롤백4, 전체239/220롤백2, extra LF, 무관 health 문구 변조,
wrong/case path, forged hash, wrong intermediate/old pin, stage swap,
missing/duplicate inverse를 코드 작성 전에 고정한다. 원본 정상부터 통과하지 않은
변조 거부는 유효 PASS가 아니다. 옛26표본과 새 표본을 별개로 센다.

JA 정상 은퇴키는 기존 현재 owner/pair·보존 target 품질을 함께 확인한다.
무관 extra·옛 source 복귀·잘못된 target은 계속 거부한다. CN은 실제 empty 이벤트
overlay가 strict events에서 실패하고 실제 채워진 overlay는 그 오류를 내지 않아야 한다.
주입 뒤 loader 복원과 제품 overlay 전후 raw 동일을 확인한다. 임계값 완화 금지.

반복 중에는 실패한5실행과 신규 표본만 수행한다. 기존 녹색 전체 번역 검사를 반복하지
않는다. 최종 clean source에서 명시 차선과 독립 검토 뒤, 실제 전체 CI 실패 수리의
회귀 증거로 통합 CI를 한 번 요청한다. 로컬 `audit.sh`의 일부 구형 저장 격리를
신뢰해 사용자 환경에서 전부 실행하지 않고 GitHub의 일회성 runner를 사용한다.
main 동기화에 딸린 원격 mirror run은 별도 결과로 기록한다. 새 실패는 은폐하거나
현재 사양에 확장하지 않고 다음 작은 오더로 분리한다.

구현 완료 제품과 검토 HEAD를 구분하고 기존5실행/유한 normal·mutant의 원형 결과,
보호 파일 전후 hash, 비저자 판정, 정확한 원격 commit/run 결과를 남긴다.
자동 CI는 정상 속도 플레이·렌더·원어민·재미·전체판 GO의 대체물이 아니다.

## 구현 고정 전 관측

- 저자 history19 첫19/19, 두 live consumer와 입력6 raw 동일이다. 기존220
  self26는 각 consumer에서 직접1회 PASS26/오류0·입력5b exact를 확인했다.
- Root JA/demo 진단은 clean2893/오류0 및 self16 marker다. 두 명령을 묶어
  개별 exit를 캡처하지 않았으므로 최종 명시 차선의 개별 결과로 다시 묶는다.
- 비저자 신규28(history19·JA7·CN2)은 실행 전 고정했다. Root JA 구현 시작
  뒤 명세 파일이 작성됐으므로 전부 blind pre-code라고 부르지 않는다. 출력에
  기대값을 맞춘 경우는0이다. 읽기 쉬운 JSON 형식 변경은 parsed data exact다.
- 원형 private28 SHA `1cc159530b713e307f3d364942a1fb099451ff4b6657a5c9917710fc08d83534`,
  self 코드 SHA `12ff8ba402154da0318565dc1b985676e6d2f679f9213c0ca8ff4f17a019ea38`.
  새28은 최종 명시11의 일부로 처음 실행한다. 기존26과 합쳐 새 표본이라 세지 않는다.
