# 시스템 모달의 남은 일본어·중국어 번역 수용

#### [~] ORDER-257 시스템 설정·저장 번역

[~] 착수 — 2026-09-13, Codex. 기준 clean HEAD
`759d9eead2c1eb8f5205704d1902805c4b43429b`, tree
`4d45b45f0015da90472dcd36a5bd90008e9ae114`.
현재 공식38,968/b105/meta9이며 이 단위의 신규 수용은 아직0이다.

## 한 단위와 사전 근거

기존 MainGame 시스템 모달에서 이미 조회하는18키의 번역·공식수용만 맡는다.
JA18·CN/TW각5는 존재하지만 선택54기록은 미수용이다. 중국어 각13만 추가하고
기존28값과 공개공유15값은 그대로 보존한다. 모달 전체·저장된 사용자 라벨·실제
저장 동작·화면 품질의 완료 판정이 아니다.

RO scope `post256-next-ui-scope.json` SHA763171ca1097a41825a6d8fe1edc46f640a577abc89b50879856806066a092ae,
비저자 사전검토 `order257-independent-preflight.json`
SHAc9412a611c99a2937b31a5222f4115a375eb8fb5a0d3244b1e7776c774f63875를 보존한다.
두 자료는 private `.git/full-game-localization/`에 있으며 새26 번역 승인·실제
collector/공식54/최종GO를 대신하지 않는다.

깊이3문: 없으면 시스템 메뉴의 해당 중국어 안내가 영어 폴백으로 남는다.
선택·24주 상태·1년/5년 규칙의 변경은0이다. GameState non-KO 분기 수리와 경쟁하지만
이미 연결된 조회의 누락부터 메운다. 호출0인 route4를 새 노출·번역 진척으로 세지 않는다.

## 고정18과 문맥

| 소유 함수 | KO key |
|---|---|
| `_open_system_menu` | 시스템 |
| `_open_system_menu` | 설정 / 저장 |
| `_open_system_menu` | 오디오, 화면, 세이브 슬롯을 관리합니다. |
| `_open_system_menu` | 메인 메뉴로 |
| `_open_system_menu` | 게임 종료 |
| `_build_display_settings` | 동작 감소 |
| `_build_display_settings` | 진동 강도 |
| `_build_save_load_section` | 저장 / 불러오기 |
| `_build_save_load_section` | 슬롯 1–5 |
| `_build_save_load_section` | 1–5 |
| `_build_save_load_section` | 6–10 |
| `_populate_save_load_page` | 슬롯 %d–%d |
| `_populate_save_load_page` | 빈 슬롯 |
| `_populate_save_load_page` | 챕터 %d · %d주차 · %s |
| `_populate_save_load_page` | 저장 |
| `_populate_save_load_page` | 불러오기 |
| `_save_to_slot` | 저장에 실패했습니다. 다시 시도해 주세요. |
| `_save_to_slot` | 슬롯 %d에 저장했습니다 |

17개의 선택 `_tr` 호출과1개의 `ui_format` 템플릿이다. 같은키의 다른 호출까지
이18회의 새 실행으로 세지 않는다. `%d,%d,%s`는 chapter/turn/total_assets의 원화
표시 순서이고 현금·위안·엔이 아니다. 저장metadata.label이 있으면 기존 라벨이
우선하며, 빈 경우에만 위 fallback이 쓰인다. 저장 성공/실패의 사실 극성을 보존한다.

공개공유5=`동작 감소/진동 강도/슬롯 %d–%d/저장/불러오기`의 JA/CN/TW15값은
바이트 그대로 둔다. 숫자 범위1–5/6–10·자리표시자 순서·기존JA 범위기호도 보존한다.
기존 의미결함이 새로 확인되면 조용히 고치지 않고 별도 범위로 판단한다.

## 소유권과 보존선

- ROOT 제품: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json` 각각13 append만,
  `content/meta/full_game_localization.json`의 공식54기록과 batch1 추가만,
  `tools/audit_scope.json`의 `system-modal-locale-only` fast lane1 등록만.
- ROOT 운영: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  본 사양·`docs/queue_archive/ORDER-257.md`, `docs/WORK_LOG.md`, `docs/STATUS.md`,
  `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`, `docs/agent_review_decisions.json`,
  `docs/agent_reviews/ORDER-257.json`.
- Rawls는 사적54언어표만 저작한다. Poincare는 언어54·적용·공식수용·최종 단위를
  비저자 검수한다. 공유 폴더의 제품 적용·collector·QA·import·Git·원격은 ROOT만 맡는다.

JA 사전 전체, 기존 중국어 사전 전체의 역복원, old38,968 portable raw,
게임코드·조건·저장ID·숫자·RNG·버튼·슬롯·프로필·관계·소스수집기·기존 검사 코드·
`audit.sh`·`project.godot`·개인 세이브·인간원장·손상된 로컬 mirror는 보존한다.
기존97/98의 입력·포맷·물리 L3 OPEN을 이 번역 수용으로 닫지 않는다.
새 runtime fixture·기존545 재실행·ManualSave/Chapter·240주·공개24주 engine 실행은0이다.

## 적용·검증·판정

1. 실제KO/EN와 기존값을 본 사적54표를 독립 전수검토하고 대상·토큰·공유15를 봉인한다.
2. ROOT가 실제 collector의18 ID·source hash·보호5·조회소유를 확인하고 L1을 수행한다.
   JA 전체와 중국어 기존키 원형을 보존하며 각13만 append한다.
3. clean 소스에서 locale별18 공식 export/check/import를 수행한다. 보호값 동일 응답은
   변경 없이 수용 가능하나 보호값 변경은 계속 거부한다. private receipt54와 actual UI,
   source/target hash를 결속한 뒤에만 portable54를 추가한다. 목표39,022/b106은 계획값이다.
4. 전체수용 L1·old38,968 raw 역복원과 선언된 영향 검사를 실행한다. 명시검사10은
   full_game_localization self, ZH self, JA pipeline self, JA UI, story_demo self/normal,
   EN coverage, 등록verify, queue_index self, agent_review self다. 기존always2와 합친
   고유12 예상이며 실제 selector 목록을 확정한다. 처음의13 추정은 채택하지 않는다.
5. 첫 결과·실패 원형을 보존하고 실제 source/검토HEAD·범위·미관측 한계를 비저자
   최종보고에 결속한다. 마감 문서 검사는 별도이며 보관 이동 전 상대 링크를 확인한다.

공개정적검사와 L1은 실제 모달 구성·동일 열린 모달의 언어갱신·페이지·저장/불러오기·
렌더·원어민·물리조작 증거가 아니다. 이 단위는 번역·수용 한정 GO만 가능하며
공개GO1·인간OPEN45·본편HOLD와 기존 판정 원형을 보존한다. 규범은 기존 현지화·
후보·보존 계약의 일회성 적용이고 새 게임·출시·검사 수량 규칙은0이다.
