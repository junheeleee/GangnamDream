# Active Queue Spec: ORDER-356

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-356 [P1·본편] 병실 조건부 본문의 시간 정합을 고친다

2026-09-27 Codex 발행·착수. 313 사전 대조에서 `arc_father_04_visit`의
`description_if_known.arc_sangchul_03_seen`도 기본 본문의 첫 KTX/두 시간 문장을
되풀이함을 확인했다. 기본 본문만 고치면 상철 인맥을 만난 경로에 결함이 남는다.

## 깊이 3문

1. 무엇이 깨지는가: 실제 선택된 조건부 본문이 같은 입원/방문 날짜를 다르게 말한다.
2. 무엇을 보존하는가: W96 병실 문 선택과 이후 상태·회수, 저녁 초대/일곱 시 회신 압박.
3. 무엇과 경쟁하는가: 313 기본 본문의 수리와 함께 최소한의 시간 사실만 맞춘다.

## 정확한 범위와 소유

- `header_layout`: `content/events{,_en,_ja,_zh-CN,_zh-TW}/arc_events.json`의
  위 조건부 description **5 text leaf**만. 입원 연락 뒤 몇 주의 지연을 첫 문장에
  인정하고 서울→창원 두 시간을 세 시간 가까이로 고친다. 새로운 지연 이유는 넣지 않는다.
  KO에서 일본어·간체·번체를 각각 직접 수리한다. 나머지 장면과 문단·토큰은 보존한다.
- root: `content/meta/full_game_localization.json`의 위 JA/CN/TW 기존 receipt3과
  파생 checksum·새 batch, 이 사양/큐/WORK_LOG/STATUS/CLAUDE 현재 한 행,
  새 agent판정 및 `docs/agent_reviews/ORDER-356*.json`, private `order356-*` 증거만.
- 313과 파일을 공유하지만 leaf는 겹치지 않으며 같은 저자만 편집한다.
  `screen_independent_review`는 비저자 전수 대조·source-bound 최종 보고만 한다.
  gameplay·스케줄·story rule·자산·엔진·공개/인간 판정·project 변경0.

## 검증과 완료

- 수정 전 export, 수정 후 fresh export→check/import, 기존 receipt3 재검증과
  다른 accepted행/이력 불변, exact5 leaf 외 불변을 증명한다.
- 313과 같은 정적 검사를 공유하되 실행/분모를 중복 집계하지 않는다. EN coverage·
  localization receipt·구조·story consistency 및 영향 목록을 확인하고 실패를 보존한다.
- 현재 원문과 과거 핀 비교를 혼동하지 않는다. 호환 실패는 별도 선언 없이 면제/수정하지 않는다.
  독립 GO 이전에는 미완료이며 원어민/인간/물리/실제 화면·입력 미관측, 본편/새package HOLD다.
- 규범은 일회성/기존 I18N·WORK_UNIT·313 시간 판단 적용이며 새 정본 규칙을 만들지 않는다.
