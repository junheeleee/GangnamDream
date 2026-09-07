# Active Queue Spec: ORDER-169

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-169 [P0·현지화 수리] 일본어 두 장면의 원화를 명확히 한다

**[~] 2026-09-07 Codex L1/L2 수용·L3 OPEN — 아래 기존 JA2 leaf와 수용 기록만 소유한다.**
사용자 전체판 번역 지시를 수행하다 발견한 단위 정밀화다. 구현
`3db9cc18d1ee9701779434b07b838961389cfc85`의8,949문구를 기준으로 한다.

- `content/events_ja/arc_year3_drama.json`:
  `events:arc_father_legacy:/description`의
  `30億まで` → `30億ウォンまで` 한 번.
- `content/events_ja/arc_pre_ending.json`:
  `events:arc_y5_final_offer:/description`의
  `30億も` → `30億ウォンも` 한 번.

KO는 모두30억이며 JA 용어집의 원화 계약을 명시하는 수리다. 엔으로 환산한
오역은 아니지만 통화 단위가 생략됐다. 금액·선택·책임·아버지 생사·계약 상태를
바꾸지 않으며 장면을 추가하지 않는다.

## 깊이 3문

1. 없으면 목표 금액의 통화가 두 장면에서 암묵적이다.
2. 효과·비용·관계·일정 변경0, 원문 의미와 명시적 원화 단위만 복원한다.
3. 남은 관계·생활·UI 번역과 경쟁하므로 발견 결함2문구만 별도 수리한다.
   15~25개의 새 장면으로 키우지 않는다.

## 소유권과 보존

ROOT는 두 파일의 exact target2, `content/meta/full_game_localization.json`의
해당 JA수용2·checksum·수리 기록, 이 사양·CODEX_QUEUE·CLAUDE·WORK_LOG·생성
STATUS·전체 현지화 backlog·`tools/audit_scope.json` 등록만 수정한다.
부팅 예산을 위해 초기 큐의 전략/앵커 문단은 기존
`docs/queue_archive/CODEX_QUEUE_2026-09.md`로 원문 이동하고 링크를 남긴다.
비표시 메타9·나머지8,947수용·모든 다른 target값/조건/행순서는 보존한다.
KO/EN·CN/TW·runtime·공개·fonts·human_gates·출시 파일은 비소유다.

## 검증

- 원문 manifest `edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
- 수정 전 exact2 source batch와 기존 수용을 보존한다. KO 대조 뒤 apply_patch로
  두 번만 치환하며 최종 source/response/receipt를 발급한다. source가 같아도
  이전 target hash 영수증은 새로운 문구의 수용 증거로 쓰지 않는다.
- 독립 리뷰는 원문·용어·초기/최종 해시 결속, 전체 파일이 두 치환뿐임,
  기존8,947/meta9와 공개 보존을 점검한다. 새 번역 수에는 중복 합산0이다.
- full-game-localization-overlays 표적 차선·EN·diff, 소스/응답 check와
  import --accept(최종 현재값과 동일하므로 changed_files0)를 실행한다.
- 원어민·실제 화면·L3 OPEN, 전체 INCOMPLETE·full/main/product HOLD,
  M01~M06 배포판 BUILD2026.08.31.1 사용자 GO를 유지한다.

소유권·수리 절차는 일회성이다. 지속 원화 규칙은 I18N_GLOSSARY_JA가 소유한다.

## 수리 결과

- 선언 `156e56446af8168f227a781dead1225726e25e84` 뒤 두 치환만 적용했다.
  최초 source2 보존, 최종 source/response/receipt2 check/import PASS,
  changed_files0. 기존 private 증거는 덮지 않았다.
- 최종2-record aggregate `b6dc8c34f03d25aa2cae9bee0a5ad40e58b8db73720ab89a0a06928aa4eb3070`.
  portable checksum `46778f0233061f1b9c35ddcd43097a89cbe61d13d39ddcc42472929adb93bd51`.
  기존 두 hash를 교체했으므로 총8,949 유지이며 신규 수용 증가0이다.
- source/효과/관계/일정 변경0, 나머지8,947수용과 비표시 메타9는 보존한다.
  L3·원어민·화면 OPEN, 전체 INCOMPLETE·full/main/product HOLD·출시 데모 GO 유지.
- 최종12개 표적 차선·EN·diff PASS. self131·ZH935·공개14/100·UI121을
  확인했다. private receipt를 통하지 않고 portable8,949와 현재 target을
  직접 대조해 locale별2,983·source/hash/L1 오류0이었다.
- 큐에서 옮긴 초기 안내401bytes SHA
  `ce267e253a431342c2139dd55f21ac44b7ac1dc94d6e98007f387585a719062d`.
  원문은 기존9월 archive에 그대로 있으며 활성 오더나 사람 gate는 내리지 않았다.
