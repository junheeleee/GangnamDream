# 저장한 소지품 이름의 현재 언어 표시

#### [~] ORDER-261 저장 물건명 언어 갱신

[~] 착수 — 2026-09-19, Codex. clean main 기준
`633a3ef4ed8e21c3d31ac1a12c7bca37af950eb7` / tree
`d11aec0684967d174e9a89f416ace88a4c08e8c2`.
공식39151/b109/meta9·공개GO1·인간OPEN45·본편HOLD를 유지한다.
기존 현지화·저장 호환 계약의 일회성 적용이며 새 게임 시스템은 아니다.

## 판정 단위와 실물

MainGame `_render_sidebars`의 nongift 이름 한 consumer를 수리한다.
현재 획득 시 저장한 이름을 표시하여 언어 변경을 따라오지 못한다. 선물은 별도
`_gift_display_name`을 이미 읽는다. LM은 `language_changed` 뒤 DR을 reload하므로
현재 DR 이름만 읽는 변경으로는 같은 패널의 즉시 갱신을 보장하지 못한다.

깊이3문: 없으면 번역된 유물6종도 옛 언어로 남는다. 선택·24주 상태 차이를
만드는 기능이 아니라 표시 정합 수리다. 남은 UI 번역과 경쟁하므로 이 consumer와
필수 호환 검증만 맡는다. M01~M60 공통 소지품 표면이며 서사·숫자·효과 변경0이다.

## 확정 정책

`DataRegistry.get_inventory_display_name(item: Dictionary, legacy_fallback: String)`을
추가하고 Main의 기존 nongift 표현식 전체를 fallback으로 전달한다. 기존 gift,
아이템 `_tr` 소유/pair, 수량·순서·버튼·효과는 그대로 둔다.

- DR은 실제 reload 시 기본14 ID의 5언어 별칭과 loaded 언어/유효 이름을 기억한다.
  별칭은 같은 ID의 정확한 비공백 문자열만 인정한다. 번역 literal을 코드에 넣지 않는다.
- 알려진 ID의 이름 누락·정확한 기본 별칭만 갱신한다. custom·빈값·공백·비문자열·
  미지 ID는 기존 fallback 우선이다. 같은 ID의 기본명과 완전히 같은 custom은 저장
  포맷상 구별할 수 없음을 명시하며 출처 필드나 migration을 추가하지 않는다.
- 같은 loaded 언어에서는 live registry를 읽어 메모리 이름 override를 보존한다.
  모드 설정 변경만으로 pending preset을 즉시 적용하지 않는다.
- 실제 LM 언어 변경 신호 중에는 기존 source→EN→target→ordered preset과 같은
  다음 item reload 결과를 일시 미리 읽는다. 곧 버려질 memory override는 화면에
  남기지 않는다. 캐시는 DR revision/target에 한정하고 실제 reload에서 지운다.
- 실제 reload/notify의 기존 revision 증가 두 지점과 신호 순서를 보존한다.
  영어 fallback·명시적 빈값/타입·모드 병합은 기존 loader 의미를 그대로 따른다.
  기존 ModLoader lazy cache read는 허용되지만 inventory/save 쓰기는 금지다.

정책·기대의 구현 전 원형: private `post260-inventory-display-policy.json`
33313B/SHA `49a373ae84d5ea889ed1df7369076afd488d83e96a9712c650663dbc09e691d7`.
정책 독립 RO8321B/SHA `902f674e444e88143278c30470e248f7238ecb3c9a58fc4f2786d1ef94fcfce1`
필수0을 확인했다. 기본6×5와 선물 UI8×5는 서로 다른 oracle이다. 신규 번역 수용은0이다.

## 정확한 파일 소유권

- Rawls: `autoloads/DataRegistry.gd`, `scenes/MainGame.gd`의 위 표시 범위만.
- Plato: `tools/main_game_locale_history.py`,
  `tools/chapter1_core_loop_v2_causal_ledger_check.py`,
  `tools/ci_localization_reconciliation_self_test.py`,
  `tools/meta_title_locale_successor_self_test.py`의 새 물리 입력 선검증/유한 역변환.
- Root: 신규 `tools/InventoryNameLocaleCheck.tscn`,
  `tools/run_inventory_name_locale_qa.sh`, `tools/audit_scope.json`의 명시 차선/영향 등록.
- Root 운영: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  본 사양과 `docs/queue_archive/ORDER-261.md`, `docs/WORK_LOG.md`, `docs/STATUS.md`,
  `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`, `docs/agent_review_decisions.json`,
  `docs/agent_reviews/ORDER-261.json`.
- Poincare: 비저자 독립 검토. private 증거만 쓰며 제품 저작·QA 실행 금지.

제품9경로다. 기존 UI/catalog/portable, GameState/LM/SaveManager/MetaProgression,
기존 fixture/old pins·기대, year5/audit.sh/runtime-trace, 인간 원장, project.godot 및
손상 mirror checkout/branch는 변경하지 않는다. 선물 전달 안내·AP·실제사용은 별도다.

## 검증과 완료 경계

새 Main/DR 전체 raw를 먼저 검증한 뒤 이전 승인 바이트로만 역변환한다. Chapter의
DR 기존9ee97 핀은 덮지 않는다. 현재 raw의 revision/순서 의미 검사도 유지한다.
새 정상 두 Main reader/Chapter를 먼저 통과한 뒤 rollback·무관 바이트·LF/경로/
claim/registry/역변환 변조를 거부한다. 기존256/243·meta suite는 명시 historical view로
실행하고 새 표본으로 중복 집계하지 않는다. imported callable도 finally 복원한다.

실행 전 독립 검토한 유한 fixture를 고정한다. actual MainGame/inventory_box와
실제 set_language를 사용하여 같은 패널의 KO→EN→JA→CN→TW→KO 및 동일 언어를
추가 refresh/prewarm 없이 관측한다. 유물6종의 기본 별칭, custom/unknown/blank/type,
선물8/unknown fallback, 실제 add_item 중복수량·KO 저장/다른 언어 로드, memory override와
pending preset 적용 시점을 각각 관측한다. loader 통제표는 기존 helper 의미를 비교한다.

실제 Godot은 기존 preautoload fresh namespace를 재사용하고 사용자 저장소는 읽거나
지우지 않는다. 모든 전후 GameState·meta·로그·inventory typed 상태와 세이브 raw를
남기고 language settings/revision/cache 및 실제 획득·저장·로드의 허용 변화는 분리한다.
첫 실패를 보존하며 정확 marker·exit·stdout/stderr/Godot 로그의 엔진 오류를 함께 판정한다.
신규 runtime은 headless component 관측이지 렌더·정상 속도 인간 플레이가 아니다.

명시 차선은 새 CI/기존 meta 유한 회귀, Chapter 현재 일반, registry/queue/agent/context,
UI source와 EN 보존을 검사한다. 새 격리 runtime은 별도 실행한다. 반복 중 전체감사,
기존 Chapter590/240주/번역전량/old545 engine을 다시 돌리지 않는다. 새 실제 실패의
원인이 범위 밖이면 별도 단위로 분리한다. 완료는 exact source/검토 HEAD·독립 최종에
결속하며 공개GO1·인간OPEN45·본편HOLD를 바꾸지 않는다.

## 실제 첫 검사와 fixture 수리

- clean b750c0d의 고유13은 첫PASS(65.54초, named1600/outer1196 입력불변).
  실제 source25의 유효음성20과 역사20/28·meta chain은 별도 모집단이다.
- 같은 후보의 첫 runtime는 fixture `_get`가 Godot 기본 함수와 충돌해 groups0이다.
  raw50185dbf와 엔진 parse 오류를 보존했고, 해당 격리 프로세스만 종료했다(exit−15).
  정의1·호출4를 `_display_name`으로 바꾼 clean40b883a의 두 번째 실행은48/51이다.
  raw602011db와 empty-state 카드 해석 오류·save/load 숫자형식·cache 복구 실패3을 보존한다.
- JSON 숫자는 저장 경계에서만 parse/stringify로 값 비교하며 일반 표시·inventory의
  typed 보존은 유지한다. 빈 inventory는 이름 카드0개로 읽고 빈 caption 검수로 세지 않는다.
  LM cache는 baseline key집합에서 새로 읽을 JA/CN/TW의 두 table 수로 revision 증가를
  계산한다. 현재 revision을 무조건 정답으로 삼거나 사전 warming으로 초기 상태를 숨기지 않는다.
- 기존51·이름 기대·실제 게임 코드·runner는 바꾸지 않았다. 같은51의 다음 실행·최종
  독립 검토 전에는 완료가 아니다. 재발방지: fixture helper는 엔진 내장 함수명을 피하고,
  JSON 저장 비교에서는 값 보존과 런타임 숫자 타입 보존을 분리한다.
