# Active Queue Spec: ORDER-279

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-279 [P0·전체 현지화] 슬롯 중국어 21키와 일본어 패배 표시를 바로잡는다

**[~] 2026-09-20 Codex 착수 — 아래 파일만 소유한다.** 부모157 후속,
기준 `9cad07832b6e4eb686d629ea6e75a255e2525620`.
RO 계획 `.git/full-game-localization/post278-next-slot-ui-scope.json`
SHA `12ff8abdbc940a5fbc1862b45e5351c038c6c2943f6c5845c9cd205cdb2b9a30`의
`selected_rows` 21개 전량이 선정 원문이다. main agent가 계획·현지화3정본과
실제 손실/총지급/순익 소비자를 직접 읽었다.

## 깊이 3문

1. 지우면 무엇이 깨지는가: 중국어에서 슬롯 안내21키가 영어 폴백으로 남고,
   일본어의 실제 패배2호출이 `大当たり`로 표시되는 의미 역전이 남는다.
2. 24주 뒤 무엇이 다른가: 금액·확률·상태·플래그 불변, 같은 결과를 정확한
   대상언어로 읽는다. 번역 키 추가로 도박 진입/AP를 활성화하지 않는다.
3. 무엇과 경쟁하는가: 기존 본문 재검사 대신 확인된 UI 결손과 의미 역전을
   고친다. 실제화면과 원어민 판정을 사전 키 수로 대체하지 않는다.

## 한 배치 / 21 원문 단위

- CN/TW를 KO에서 각각 독립 작성해21씩42값을 추가한다. 한국어
  `[color=#4a4a6a]— 꽝 —[/color]`의 JA 한 값만 실제 패배로 수리한다.
- 총지급 `gain`과 누적 순익 `gain-stake`, near miss와 실제 패배, 원화 인자,
  200/50/20/15/1.5배, BBCode·%s6·%d/%s 순서를 유지한다. 손실을 보상이나
  다음 당첨 약속으로 옮기지 않는다. 공유3키의 다른7호출도 전수 대조한다.
- 실제 source-bound export로 비보호·정적 소비자·accepted 충돌을 재확인하고,
  비저자 전수 검수와 기존 check를 거친 뒤 append/JA1수리한다. 새 target hash
  export/import receipt로만 원장에 기록한다. 새 checker 예외는 비소유다.
- 정상 수용 목표43: 공식39929→39972/b124/meta9. 원형 보류72는 별도다.
  원고나 기계 결함은 원형을 보존해 같은 원문 모집단에서 수리하며 수용 수를
  목표에 맞추어 조작하지 않는다.

## 정확한 파일 소유권

- `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`: 위21키씩 append만.
- `locale/ui_ja.json`: 위 색상 패배 키의 한 값만.
- `content/meta/full_game_localization.json`: 실제43 receipt 및 한 배치만.
- `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  `docs/WORK_LOG.md`, 생성 `docs/STATUS.md`, 이 사양과 `docs/queue_archive/ORDER-279.md`,
  `docs/agent_reviews/ORDER-279.json`, `docs/agent_review_decisions.json`.

원문·런타임·입력·효과·확률·checker·collector·project.godot·저장·공개 데모·
인간 원장·다른 JA행·보류72는 비소유다. `.git/full-game-localization/order279-*`에
KO/source/초안/검수/최초 실제 결과를 보존한다. 저자와 독립 검수자 파일 소유를 나눈다.

## 검증과 한계

3지역 실제 check/import·old39929 hash·UI/portable 역복원·한영/게임소스·공개/인간
보존 뒤, clean source와 STATUS-only 검토 HEAD를 결속한다. 기존 명명
`news-panel-locale-only`12검사 목록만 재사용하고 기준부터 전체 diff가 위13경로
안인지 별도 확인한다. 독립 비저자가 실제43값·의미·공유호출·receipt·보존·명명12를
전수 검토한 한정 work_unit 판정 뒤 metadata6으로 닫는다. 전체 감사·엔진·240주 없음.
조건부 legacy/AP hub→slot 소비자는 존재하나 fresh-story 진입·화면/입력 미관찰이다.
동적 win_type4와 직행영문 기계 라벨은 비포함이라 슬롯 전체 번역완료로 세지 않는다.
공개GO1·인간OPEN45·본편HOLD·원어민/인간/물리패드 미관찰 유지.
자동 통과는 계약 증거이지 재미·깊이·문체의 증거가 아니다. 기존 WORK_UNIT/I18N
규칙 재사용, 새 규범 없음. 선정·소유·검증은 일회성이다.
