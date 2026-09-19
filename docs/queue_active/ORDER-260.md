# 소지품·선물 이름의 일본어·중국어 번역

#### [~] ORDER-260 소지품 번역

[~] 착수 — 2026-09-19, Codex. clean main 기준
`3f5b706073bb1d3e12444bd823ba1efc45f99cca` / tree
`ad6deecad1a929ce814f1b310a3fdfb7b3a77035`. 공식39103/b108/meta9에서 시작한다.
기존 현지화 계약의 일회성 적용이며 새 영구 규칙0이다.

## 한 단위와 근거

소지품 표시7키와 같은 화면이 읽는 선물 이름9키, 고유16×3=48만 맡는다.
`_render_sidebars`: 소지품 · 유물, 빈 소지품 안내2문장, 아이템, `%s · %d개`,
사용 AP 1, 간직한 물건, 자동 활성.
`_gift_display_name`: 캔커피 세트, 양말 세트, 에세이집, 전시 도록, 목도리,
향수, 브랜드 지갑, 목걸이, 선물.

JA 선물의 先物는 금융상품 오역이므로 贈り物로 고친다. 간직한 물건도 단순
소유명 所持品에서 大切にしている物로 정밀화한다. 기존14와 나머지 전체사전은
보존하고 CN/TW각16을 한국어에서 직접 채운다. gift8의 기수용 catalog명은
의미 일관성 근거일 뿐 이번48로 중복 계산하지 않는다.

깊이3문: 없으면 중국어 라벨은 영어로 남고 일본어 선물 의미가 틀린다.
선택·24주 상태·1년/5년 서사·경제 변화0이다. 실제 표시 소비자 수리와 경쟁하되
이미 존재하는 lookup을 먼저 채운다. 같은 함수의 호출자3을 번역3배로 세지 않는다.

## 사실·호환 경계

`선물 — 사람 메뉴에서 전달`은 정상 턴의 비도달 메뉴 안내 문제까지 있어 제외한다.
이 안내의 별도 先物 오역도 이번에 닫았다고 쓰지 않는다. People/생활/AP 진입0,
가격·관계·효과·수량·ID·저장 변경0이다. `%s`→`%d`, LF1, AP1을 보존한다.
현재 내장14의 효과는 비어 있으므로 AP1 조건부 라벨 번역을 실제 사용 관측으로
세지 않는다. 자동 활성은 기존 상태 라벨이며 새 보너스/수익 보장이 아니다.
기존 nongift inventory.name의 언어전환 잔류는 별도 표시 소비자 결함이다.
저장/사용자 이름을 덮거나 catalog 수용으로 그 결함까지 해결했다고 쓰지 않는다.

## 파일 소유권

- ROOT 제품4: `locale/ui_ja.json` 선택2값, `locale/ui_zh-CN.json`과
  `locale/ui_zh-TW.json` 각16 append, `content/meta/full_game_localization.json` 신규48/batch1.
- ROOT 운영10: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  본 사양, `docs/queue_archive/ORDER-260.md`, `docs/WORK_LOG.md`, `docs/STATUS.md`,
  `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`, `docs/agent_review_decisions.json`,
  `docs/agent_reviews/ORDER-260.json`.
- Rawls 언어 초안, Plato 비저자 언어 검수·수용 보조, Poincare 최종 비저자 검수.
  제품 적용·실제검사·Git·원격은 ROOT만 맡는다.

코드·게임플레이·수집기·기존검사·audit_scope·audit.sh·project·개인저장·공개후보·
human ledger·손상 mirror는 변경0이다. old39103 원장과 선택 외 UI raw를 보존한다.

## 검증·완료

1. 사전 private 초안2084497f의48을 독립daaa7e1c로 전수검토했다. 실제collector16,
   source hash와 보호교집합은 선언 후 확인한다. 보호 예상0과 다르면 적용 전 조사한다.
2. 편집 전 source-export, 신규48 L1 뒤 UI를 적용한다. clean source에서 다시
   export/check/import --accept, receipt와 actual UI/source/target 결속 후 portable48만 더한다.
   목표39151/b109는 실제수용 전 완료값이 아니다.
3. 신규48 L1과 기존39103 현재 source/target 해시 보존을 검사한다. 기존 전체L1을
   재실행했다고 쓰지 않는다. 새 검사 차선은 만들지 않고 기존 `news-panel-locale-only`의
   동일 고유12 목록만 재사용한다. 이전 차선의259 소유권을260으로 바꾸지 않으며,
   ROOT runner의 baseline→HEAD 전체 no-renames diff가 이번14 소유권을 별도 강제한다.
   고유12는 full self, EN coverage, JA pipeline self/UI, ZH self, story demo self/normal,
   registry verify, queue self, agent self, context, queue다. 엔진·전체감사·Chapter·저장검사0.
4. 최초stdout/stderr/exit, 정확 source/검토HEAD, 미관측 한계를 최종 독립판정에 결속한다.
   단위GO 뒤 원문보관·판정1행·metadata6만 마감한다. WORK 원문은 필요시 본 보관본으로
   이동하며 한도나 검사 기대를 올리지 않는다.

기계 PASS는 계약 증거이지 재미·렌더·원어민·인간 플레이·물리패드 증거가 아니다.
공개 GO1·인간 OPEN45·본편 HOLD와 새 외부출시 권한0을 유지한다.
