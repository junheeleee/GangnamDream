# 시장 뉴스 표면의 일본어·중국어 번역 수용

#### [~] ORDER-259 시장 뉴스 번역

[~] 착수 — 2026-09-19, Codex. clean main 기준
`58b63d68a1c4c9725218dfd3769e62e44c6f97cc` / tree
`ddaf4014fa295fc5eafe25eb33772aaa52f3db17`. 공식39076/b107/meta9 보존에서 시작한다.
기존 현지화 계약을 적용하는 일회성 작업이며 새 영구 규칙은 만들지 않는다.

## 판정 가능한 범위

MainGame `_render_news`의 시장 뉴스, 아직 들어온 뉴스가 없습니다., 중립, 루머,
강한 호재, 호재, 강한 악재, 악재와 `_random_topic`의 시장: 고유9키×3언어=27이다.
시장 키는 topic 기본값·빈 배열의2호출 및 `_invest_pages`1호출을 공유한다.
소유9키의 전체11호출을 확인하되 호출 수를 번역 개수로 세지 않는다.
JA 기존9를 검수·보존하고 CN/TW 각9를 한국어에서 독립 작성한다.
9는 이 화면의 실제 경계이며 15개를 맞추려 무관한 소지품·선물 키를 더하지 않는다.

깊이3문: 누락하면 준비 중국어의 뉴스 라벨이 영어로 남는다. 선택·24주 상태는
바꾸지 않는 표면 수리다. UI 소비자 수리와 경쟁하되 이미 존재하는 lookup을 먼저
채운다. 1년/5년의 이야기·수치·저장·엔딩 변경0이다.

루머 분기가 power 분류보다 먼저라는 의미와 호재/악재의 강약을 보존한다.
분류는 실제 수익·가격 상승 보장이 아니다. 임계값·부호·%·색·RNG는 변경0이다.
언어 변경 때 라벨 재생성과 이미 저장된 headline/topics의 재번역은 별개다.
기존 news_log 캐시·직접 영어 MARKET TICKER·생성 경로는 이 작업에서 수리하지 않는다.
정적 호출 확인을 현재 모든 모드의 뉴스 노출이나 실제 화면 관찰로 기록하지 않는다.

## 파일 소유권

- ROOT 제품: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json` 각9 append,
  `content/meta/full_game_localization.json` 공식27기록과 batch1,
  `tools/audit_scope.json` explicit-only `news-panel-locale-only` 차선1.
- ROOT 운영: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  본 사양, `docs/queue_archive/ORDER-259.md`, `docs/WORK_LOG.md`, `docs/STATUS.md`,
  `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`, `docs/agent_review_decisions.json`,
  `docs/agent_reviews/ORDER-259.json`.
- Rawls: private27 언어표. Poincare: 비저자 전수 언어·최종 검수. Plato: private
  수용 절차 RO 검토. 제품 적용·실행·Git·원격은 ROOT만 맡는다.

JA 전체·기존 CN/TW·old39076 원장 원형, runtime·source collector·기존 검사·audit.sh·
project.godot·개인 세이브·human ledger·공개 후보·손상 mirror는 보존한다.

## 검증과 완료

1. 독립27 전수 언어 검수 뒤 실제 collector9/source hash/보호여부를 확인한다.
   공개 보호교집합0을 예상하되 실제 결과가 다르면 보호값을 변경하지 않고 조사한다.
2. 편집 전 source export를 보존한다. 사전 수동 append 뒤 clean source에서 다시
   export/check/import --accept한다. 실제 receipt/source/target/사전을 묶어 portable에
   27만 추가한다. 목표39103/b108은 실제 수용 전 완료로 세지 않는다.
3. 신규27 L1 및 old39076 source/target 원형 보존을 검증한다. 이미 끝난 이전 전체L1을
   새로 실행했다고 쓰지 않는다. 고유12는 full localization self, ZH self, JA pipeline
   self, JA UI, story demo self/normal, EN coverage, registry verify, queue self,
   agent review self, context, queue다. 실제 selector 목록과 no-renames 전체diff의
   소유경로를 확인한다. 전체감사·엔진·Chapter·사용자 저장 검사는 실행하지 않는다.
4. 최초 실행 stdout/stderr/exit와 정확 source/검토 HEAD·미관측 한계를 독립 최종보고에
   결속한다. 단위 GO 뒤 원문보관·판정1행·metadata 검증만 마감한다.

기계 PASS는 도달성·계약 증거이지 재미·문체·렌더·원어민·인간 플레이·물리 패드
증거가 아니다. 공개 GO1·인간 OPEN45·본편 HOLD를 유지하며 외부 출시 판정0이다.
