# Active Queue Spec: ORDER-165

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-165 [P0·현지화 수리] 데모 간체의 두 기록을 정확히 복원한다

**[~] 2026-09-07 Codex 착수 — 아래 한 leaf와 정적 보존선만 소유한다.**
사용자의 전체 게임 번역 지시를 수행하다 새 수량 검사에서 발견한 실제 누락이다.
47사건 번역 ORDER-164에 공개 표면 변경을 숨기지 않고 이 한 건만 분리한다.

- 대상: `content/events_zh-CN/story_demo_events.json`의
  `arc_temptation_fallout.description` 마지막 문장만.
- 원문: `두 기록이 같은 화면에 남았다.`
- 현재: `这些记录留在同一块屏幕上。`
- 수리: `这两条记录留在同一块屏幕上。`

은행/모집책의 두 기록을 단순 복수로 옮겨 명시 수량이 빠졌다. 사건·효과·비용·
동의·반환·시간·상대방은 변경0이다. 수량 검사를 이 문장만 면제하거나 두 개를
임의 복수로 허용하면 후속 숫자 누락도 숨길 수 있으므로 검사를 완화하지 않는다.
신규20장면으로 키우지 않는 발견 결함 한 건의 정밀 수리다.

소유: 위 exact leaf, `tools/full_body_translation_scope.py`의 zh-CN target
baseline fingerprint와 해당 보존선 설명, 이 사양·CODEX_QUEUE·WORK_LOG·생성
STATUS·전체 현지화 backlog·`tools/audit_scope.json` 등록. 다른 target99문구,
JA/TW·UI/catalog·KO/EN·runtime·출시 파일·human_gates·기존 수용5412/메타9는 비소유.
기존 CN baseline `800aaa457f8bcbb00c33fa258fb39db375c41628cabb925ef3cdb05abe912217`
은 이 사양에 역사 증거로 보존한다. 실제 한 문장 개선 뒤 새 정확 fingerprint만
계산하며 source/보호 재사용8문구의 해시를 바꾸지 않는다.

검증: 독립 KO 대조, 이전 target99개+이번 문장 나머지 바이트 보존, 숫자2→3/누락
변조 거부, public localization·full-body self-test·ZH935·EN·diff 표적 검사.
전체 번역 원장의 새 수용460×3에 이 수리를 중복 합산하지 않는다.
원어민/실제 화면은 OPEN이다. 이미 배포된 BUILD2026.08.31.1과 사용자 GO 증거,
배경 제품53493fe·본편 HOLD는 그대로 두며 새 demo/full 후보를 발급하지 않는다.

이 소유권과 판정은 일회성이다. 상시 현지화 규칙은 I18N_INFRASTRUCTURE가 소유한다.
