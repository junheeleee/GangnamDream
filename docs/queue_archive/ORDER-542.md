# ORDER-542 — 본편 집주인·투자 길잡이 선행 문장 정합

#### [x] ORDER-542 [P1·원고 정합] 기존4잎 × 5언어 — 2026-10-11 source 한정 GO / 제품 HOLD

**착수 — 2026-10-11 / 부모534 실제 선행에서 확인한 결함 두 건.**
월별 관측 기록 a1833da와 분리한 구현 범위다. 기존 M07 기능 검수를 반복하지 않는다.

## 깊이 3문·배치

1. 일한 이력 뒤 무노동 단정과 W14→W15를 두 주로 쓰는 문장이 정상 선행과 충돌한다.
2. 새 선택·상태를 만들지 않는다. 등록 직업 없음은 고정 일자리 없음으로 한정하고,
   첫 만남 뒤의 저녁은 고정 경과 주수 없이 쓴다. 효과·직업·급여·라우팅 불변이다.
3. 장면/선택 슬롯·타이머를 추가하지 않는다. 기존 서술의 사실만 바로잡는다.

모집단: `arc_rescue_job.description`1 + `arc_invest_guidance.description`,
`description_orthodox`, `description_unorthodox`3의 KO/EN/JA/zh-CN/zh-TW
**20잎 한 배치 전수 독립 검수**. 장면 신설·심화가 아닌 기존 정합 수리다.

## 파일 소유

- root: `content/events/arc_events.json`, `content/events_en/arc_events.json` 위4잎만.
  공식 import로 `content/events_ja/arc_events.json`, `content/events_zh-CN/arc_events.json`,
  `content/events_zh-TW/arc_events.json` 같은4잎을 수용한다.
  `content/meta/full_game_localization.json` correction12영수증·별도batch,
  `content/meta/release_content_inventory.json` 실제 바뀐 지문만,
  `docs/CONTENT_RATING_INVENTORY.md` 필요시 기존 생성기만 쓴다.
- phone_cn_author: `.git/order542-qa-20261011/` 공식 source/response 초안만.
  세 locale 모두 KO 직접 작성, 중국어 지역 자동 변환0. 제품 overlay/원장 직접쓰기0.
- phone_independent_review: 비저자20잎·gameplay/데모/과거원장 보존·공식 receipt/후보
  전수 검수, `docs/agent_reviews/ORDER-542.json`만 소유한다.
- root 기록: 이 사양·완료 archive, CODEX_QUEUE/L3순번, WORK_LOG, CLAUDE현재행,
  agent_review_decisions. 필요한 원문 보관 회전만 기존 history에 byteexact로 한다.

## 검증·금지

- KO/EN 후 정확4 leaf IDs로 export→check→import --accept --replace-existing.
  이전 target SHA와 공식 receipt를 결속하고 옛 batch·accepted개수는 보존한다.
  새coverage0·원어민/rendered OPEN. exporter HEAD를 수정원문commit이라고 쓰지 않는다.
- 기존 EN coverage/한글·원장 inventory·서사 연속성·장면 음악·말투·데모 고정·
  release inventory·context/큐/diff 표적 검사를 실행한다. 새 실패0이어야 한다.
  영향 선택 목록을 먼저 보고 관련 차선만 실행한다. 전체감사/240주/엔진·앱·저장
  재실행/비용도구·검사완화·STATUS-only 추종commit0.
- 공개 M01–M06 row/locale story_demo_events·demo pin·게임플레이·선택/결과·
  project.godot·사용자 저장·과거 인간/agent판정 불변. 공유 `arc_sangchul_01_meet`
  의 3월끝 수리는 이번에 하지 않는다. 본편 전용 소비자 범위가 따로 필요하다.

## 완료 경계

정확20잎·공식12교정·다른잎/gameplay/데모 불변·표적 새실패0·비저자 정확source
GO만 닫는다. 자동 계약은 재미·깊이·문체의 증거가 아니다. 실제 변경화면/원어민/
인간·패드·M08이후·전체본편/출시 GO는 별개다. 새 정본규칙0/실행지시 일회성.

## 구현·표적 결과

KO/EN8·KO직접JA/CN/TW12의20잎을 질문 또는 첫 시간구만 교정했다.
JA 첫 질문의 옛 source-bound 호칭 예외 미적용 FAIL/초안을 보존하고, 소유 질문
내 부름만 수정해 공식 check/import6회 PASS다. 번역기/예외/검사코드 변경0이다.
공식 writer의 JSON 재포맷은 원형으로 정렬했으며 semantic exact, 각 파일4줄
변경뿐이다. 기존307batch·accepted개수/키/순서·다른receipt는 exact이며 새batch1,
기존receipt12 source/target 교정만 추가했다. 새coverage0·native/rendered OPEN이다.

clean bed87f3 baseline19와 변경후 같은19 모두 exit0/stderr0, 새실패0이다.
원 stdout/stderr/결과·전후SHA·final-comparison은 `.git/order542-qa-20261011/`에
보존한다. final 검사 전후8파일도 exact다. JA invalid58→58/ZH0→0 및 각group
카운터/원장부채 불변, owned12 currentreceipt/digest가 현재 원문/target과 맞는다.
release inventory PASS·JSON/생성보고 byteexact라 불필요한 재생성0이다.
비저자20잎 문안 GO/추가retouch0과 최종 clean source 판정을 결속했다. 실제 화면 재검수0이다.

## 독립 최종 판정

[최종 보고](../agent_reviews/ORDER-542.json)10738B/
`05f564d0ab17e47df877c5b12e725ec5f15f797b305b6ac30a8944667c7532ef`는
clean main/origin `0d10afa8de7554bfb119521a70f905684388080b` /
tree `23fc3d140470a81ed201d28f5bda3cada154cdcc`의 이 단위만 GO다.
20잎·공식12교정·5JSON/원장 raw역상·기존307batch·281판정/Human 보존과
baseline/final19 원76stream·공식6 원12stream을 독립 대조했다.
공유 첫 만남 날짜·변경 화면·원어민/인간/물리 패드·M08 이후·전체 본편/출시는
HOLD/OPEN이다. 새 정본승격0/이 사양 실행지시 일회성이다.
