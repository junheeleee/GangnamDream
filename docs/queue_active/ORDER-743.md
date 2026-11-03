# ORDER-743 — 입원·관계·갱신 선택의 JA/zh 정합

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-743 · 입원·관계·갱신 선택의 JA/zh 정합

2026-11-03 root 착수, 부모157·C5. 여섯 장면×세 언어=18 장면-언어 단위,
KR12 leaf/JA·CN·TW36개 기존 번역 정정만 소유한다. 신규 커버리지0.

## 정확한 소유권·깊이3문 (일회성)

- `content/events_{ja,zh-CN,zh-TW}/arc_events.json`: arc_father_03_hospital의
  description/description_unorthodox(2), arc_jiyeon_03_offer description(1).
- 같은 세 언어 `arc_daeun.json`: arc_daeun_04_morning description(1),
  arc_daeun_04b_future description(1), arc_daeun_05_together title 및
  description_if_known/daeun_romance_started(2).
- 같은 세 언어 `arc_midgame.json`: arc_y2_relationship_fork_unattached의
  description, choices/0의 text/result_text, choices/1·2/result_text(5).
- `content/meta/full_game_localization.json`: 이36개 수용/correction 및 원 batch/
  수용·이전target 지문 보존만. 큐·이 사양·157·CLAUDE·11-03 WORK_LOG,
  독립 보고/판정만 추가 소유한다. KO/EN·효과·저장·공개demo·allowlist 비소유.

1. 제거하면: 현재 이동비/현금을 특정 투자로, 일회 갱신금30만원을 월세/매월
   절약금으로, 방 안을 편의점으로, 열린 연애 기간을 몇 달로 발명하는 번역이 남는다.
2. 선택 대가: 같은 주소12개월/짧은 계약과 묶인100만원/퇴실일 확정, 전화로 듣는
   살아 있는 아버지의 입원, 지연의 미안함과 다은 관계의 정확한 단계가 소유한다.
3. 경쟁: source hash가 낡은 shipping 장면6개를 전독하고 잘못된 사실부터 정합한다.
   원문 없는 월세 일정·투자·수익·선물 거절·연애 성과를 설명으로 보충하지 않는다.

현재 한국어에서 세 언어 각각 직접 번역한다. fresh official export/check →
독립36개 전독 → 명시 replace import. 숫자/시각/기간·원화·토큰/문단·지역문자,
HEAD 대비 소유값만 복원한 전체 JSON/수용체인 역대조, 공개demo/EN·scope 변화·
context/queue/diff를 확인한다. 불변 self-test/완료738~742는 반복하지 않는다.

도달 경로: 실제 stale source12와 현재 원문/목표 전체 문맥 대조.
생산자↔독자: KR arc_events/arc_daeun/arc_midgame → 기존 built-in overlay consumer.
바꾸는 상태: stale36 → current36. 신규 커버리지0.
포기 시 잃는 것: W85~88 제안/부모방문4일뒤 입원·다은 단계/갱신의 실제 사실.
서사 위치/계층: 기존6사건/원본 계층 불변.
닫는 것: 이36개 source 정합만. 규범은 기존 I18N 정본 적용·승격0.
전체언어/차선·실화면·원어민·최신CI·출시 GO는 별도다.
