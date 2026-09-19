# 소지품 선물의 잘못된 메뉴 안내 정정

#### [~] ORDER-262 선물 안내 정정

[~] 착수 — 2026-09-19, Codex. clean main `b71be05a44558fa9b79c35110e3a77ac278764de`,
tree `f4eb40a081ae8f06614689505a29388d48d61362`에서 시작한다.
기존 현지화·사실 표면 계약의 일회성 적용이며 새 영구 규칙0이다.

## 한 단위와 판단

`MainGame._render_sidebars`의 effects가 없는 gift 안내 한 줄만 고친다.
현재 `선물 — 사람 메뉴에서 전달 / Gift — deliver from the People menu`는
정상 1~240주에서 확인한 Main 행동 화면의 early return 뒤에 있는 메뉴를 지시한다.
보유 선물을 분류하는 기존 `선물 / Gift`로 바꾼다. 메뉴·전달 기능을 새로 열지 않는다.
이미 수용된 JA `贈り物`, CN `礼物`, TW `禮物`를 재사용하므로 신규 번역수용0이다.

깊이3문: 없애면 잘못된 메뉴 탐색 유도가 남는다. 24주 상태 차이를 만드는 선택이
아니라 기존 보유물의 사실 표시 수리이며 상태 변화0이어야 한다. 소지품 안내 자리에서
사용 불가능한 지시 대신 정확한 품목 분류를 표시한다.

옛 긴 안내는 현행 호출이0이 된다. 미수용 JA 사전의 그 한 행만 함께 내려 unknown
extra를 만들지 않는다. 원형은 이전 Git·정확 역치환으로 보존한다. 다른 legacy
상점/People 안내는 별도 부채이며 이번 수리로 완료 처리하지 않는다.

## 정확한 파일 소유

제품10경로:
- `scenes/MainGame.gd`: 위 caption의 `_tr` 한 쌍만.
- `locale/ui_ja.json`: 미수용 긴 안내 한 행만 제거. `선물` 및 나머지 전부 raw 보존.
- `tools/main_game_locale_history.py`, `tools/ja_translation_pipeline.py`,
  `tools/ci_localization_reconciliation_self_test.py`,
  `tools/meta_title_locale_successor_self_test.py`: 새 실제 원문 선검사와 고유 유한 역변환,
  기존 검사에만 이전 bytes를 제공하는 복원 가능한 역사 관측. 과거 핀·기대는 덮지 않는다.
- 신규 `tools/gift_caption_locale_self_test.py`: 정상 선행·변조/롤백·pair owner·위조 hash·OFF.
- 신규 `tools/GiftCaptionLocaleCheck.tscn`, `tools/run_gift_caption_locale_qa.sh`: 격리 실제 Main 표적 검사.
- `tools/audit_scope.json`: 명시 전용 차선·검사 의존성 등록.

운영: 이 active와 `docs/queue_archive/ORDER-262.md`, `docs/CODEX_QUEUE.md`,
`docs/CODEX_QUEUE_L3_PENDING.md`, `docs/WORK_LOG.md`,
신규 `docs/history/WORK_LOG_2026-09-19_pre_gift.md`(기존 WORK 전량 무손실 이동),
`docs/STATUS.md`, `CLAUDE.md`, `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`,
`docs/agent_reviews/ORDER-262.json`, `docs/agent_review_decisions.json`.
Root는 Main/JA/등록/기록/Git/실행, Plato는 guard4+새 source self,
Rawls는 새 scene/runner, Poincare는 비저자 독립 검수만 소유한다.

## 검증과 보존

소스 예상: 실제 caption owner 한 쌍 교체, 다른 `_gift_display_name` fallback 보존,
호출수 동일·고유 UI키1 감소. 기존 `선물` 수용 해시3과 전체39151 portable 불변을
실제 수집 결과와 대조한다. 과거 keyset/count는 실제 현행 inventory와 구분한다.
새 source controls는 구현 전 고정하고 정상 endpoint가 통과하기 전 음성 통과를 세지 않는다.

실제 엔진은 새 namespace를 autoload 전에 정하고 같은 실제 inventory panel에서
5언어×AP1/0=10상태를 본다. 각 상태의8기본+unknown1 caption과 효과 있는 custom1
사용 버튼은 nested100관측이지100실행이 아니다. caption Label, 사용 버튼 disabled 및
정확 `_on_use_item` 연결을 읽고 누르지 않는다. locale/setup 뒤 render 전후 typed
game/meta/inventory/log/registry/settings와 설정 포함 user 파일이 같아야 한다.
parse/script/error/leak·종료·성공marker·10IDs·입력바이트를 함께 판정한다.
기존261 fixture/runner는 바꾸거나51검사를 이유 없이 재실행하지 않는다.

표적 차선: 새 source self, 기존 CI/meta 역사 검증, 현재 Chapter normal, JA pipeline self/UI,
EN, story demo self/normal, full localization self 및 기존39151 source/target 해시 보존,
scope verify, queue/agent self, context/queue. 전체 감사·240주·Chapter590·원어민 검사는 아니다.
최초 실패 raw를 보존하고 원인에 해당하는 검사만 다시 실행한다.

AP/사용·선물 효과·수신인·쿨다운·재고·저장 형식·메뉴 ingress·서사·원고·원어민·
인간 판정·public demo·`project.godot`은 비소유다. 새 수용39151/b109/meta9 유지,
public GO1·인간 OPEN45·본편 HOLD 유지. 실제 화면 가독성/정상입력/선물전달 미관측.
자동 게이트는 계약 증거이며 재미·깊이·문체나 인간 GO가 아니다.
