# ORDER-262 — 소지품 선물 안내 정정 결과

[x] ORDER-262 — 2026-09-19. Poincare LOCAL work_unit GO / required 0.

제품 source `d4c08dbd9cd8f5962810b2adb3b8cbbb8a60ccf1`
tree `10cd179cba42dc9ac3df3f517294955e40f402c6`
clean 검토 `a04a20ac5992acd30a7a0baf9f66b6dae9409d84`
tree `4ea7c113659bb46b31b4e9a5a82b9111807a0a7a`

## 완료 범위와 증거

- 소비자: `scenes/MainGame.gd:9924`의 비도달 메뉴 지시 → 기존 `선물 / Gift`.
  JA/CN/TW 기존 수용3을 재사용했다. AP·전달 기능·메뉴·서사 변경0.
- JA 미수용 옛 안내1행만 제거했다. 정확 역치환·이전 Git 원형을 보존한다.
- 최초 고유15/15 통과: 90.363948709초, 1606입력 불변.
  원본 `order262-named-first.json` SHA `6fbfac2f32263d29bb4aa23f172a65ed2b1b05df404a3c2c7b4412e122e9cb6f`.
- 현재 source22/22(정상1·유효거부19·claim1·OFF1), 별도 UI메모리 관측3 통과.
  기존 CI25/20/28 및 meta 역사 모집단은 현재 검증 수에 합산하지 않는다.
- 최초 실제 엔진10/10: 5언어×AP1/0, 같은 panel1, 카드100 안의 caption90/button10.
  10 typed 상태 triplet·설정 포함 raw 파일이 각 수동 render 전후 동일했다.
  engine0·stderr0·error/leak0, runtime27·outer1199입력 불변.
  원본 `order262-runtime-first.json` SHA `dd0070f46cae547a408ad0158243867092de3209dd08322a4c34a2b7eda893a1`.
- 실제 현행 source/target39151 해시 보존, portable39151/b109/meta9 원형 동일.
  신규번역수용0. UI키1 퇴역으로 총분모17483/UI3665가 되었으며 번역진척으로 세지 않는다.
- 원어민·실제화면·버튼누름·선물전달·즉시언어신호·전체세션 복원은 미관측이다.
  locale/setup은 측정 render 밖이며 사용자 저장소를 테스트하지 않았다.
- 구현 전 UI전체고정/보조probe 조건/검사 의존성은 독립 검수에서 수정했다.
  최초 실제 검사 실패0. Root의 결과보기 JSON decoder 오류는 RO열람 오류이지 QA실패가 아니다.
- Chapter gap24/debt8/blocked3·JA beta·scope EXTRA21·공개GO1·인간OPEN45·본편HOLD 유지.

규범 분류: 기존 표시·현지화·보존 계약의 일회성 적용. 새 영구 규칙0.

[독립 최종 보고](../agent_reviews/ORDER-262.json)
SHA `2a8f551c14ddcb8860c316e14eae9df1eefd4a7251e60dc7d3e3d8a85cb56d16`.
위 private 원증거의 전체 경로·바이트·SHA와 미관측 경계는 이 보고에 결속한다.
이번 GO는 이 단위와 정확 제품에만 적용하며 전체판/출시 GO가 아니다.

## 착수 WORK 원문 보존

# Gangnam Dream Work Log

> 이전 WORK 전체 39,897바이트는 [9/19 보존본](history/WORK_LOG_2026-09-19_pre_gift.md)에
> 원형 그대로 이동했다. 보존본의 상대 링크도 당시 원문이며 과거 기록을 축약하지 않았다.

## 2026-09-19 (Codex — 잘못된 소지품 메뉴 안내 수리)

- [262](queue_active/ORDER-262.md): effects 없는 선물의 비도달 People 안내를 기존5언어 품목명으로 교체한다.
- 미수용 JA 옛 안내1행만 내려 실제 collector와 맞춘다. 이전Git·정확 inverse는 보존한다.
- Main/사전2개는 반영, 역사 연결·실제10상태·독립 검수는 진행 중이다.
- 신규번역0·공식39151/b109/meta9·공개GO1·인간OPEN45·본편HOLD 유지.

## 이어보기

- 저장 물건명 즉시 갱신 마감: [261](queue_archive/ORDER-261.md), source7bbe8de/검토648167a.
- 이전 CI 수리의 역사 한정 마감: [243](queue_archive/ORDER-243.md), 현재판GO 아님.

## 선언 원문 보존

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
