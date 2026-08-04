# Active Queue Spec: ORDER-85

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-85 [P0·서사/현지화] 24주 데모 산문을 정본 문체로 한 번 정리한다

**착수 선언 (2026-08-04 Codex) — 만지는 파일:**
`docs/SCENE_TIER.md`, `docs/I18N_GLOSSARY.md`, `docs/QA_CHECKLIST.md`,
정확한 데모 원문 72사건을 소유한 `content/events/arc_daeun.json`,
`arc_events.json`, `arc_midgame.json`, `chapter_cards.json`,
`core_loop_v2_events.json`, `scenario_cafe.json`, `story_events.json`과 대응하는
`content/events_en/` 오버레이, `content/meta/demo_core_loop_v2.json`,
`content/meta/story_rules.json`, `content/events/arc_year_close.json`,
`scenes/OpeningCinematic.gd`, `scenes/MainGame.gd`, 신규
`tools/demo_prose_style_audit.py`, `tools/demo_localization_scope.py`,
`tools/demo_core_loop_v2_audit.py`,
`tools/ManualSaveCheck.gd`, `tools/CoreLoopV2ECheck.gd`, `tools/audit.sh`,
`tools/audit_scope.json`,
`content/meta/demo_localization_scope.json`, `content/meta/release_content_inventory.json`,
`assets/scene_direction_manifest.json`,
`docs/I18N_INFRASTRUCTURE.md`, `docs/I18N_GLOSSARY_ZH.md`,
`docs/CONTENT_RATING_INVENTORY.md`, `docs/human_gates.json`, `CLAUDE.md`,
`docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/STATUS.md`,
`docs/RELEASE_NOTES.md`, `docs/DEMO_FIXLOG.md`, 이 사양의 활성·아카이브 경로.
효과·수치·선택 구조·사건 도달·저장·출시 언어 노출은 소유하지 않는다.

**사용자 승인 (2026-08-04):** `docs/DECISIONS.md`의 P-9를 권고대로 실행한다.
장면은 이미지나 행동으로 닫고 방금 보여 준 감정을 다시 해설하지 않는다. 같은
문단에서 같은 종결어미를 세 번 연속 쓰지 않는다. 시각은 아라비아 숫자로 쓰며
분 단위는 그 분 자체가 선택 압박인 장면에만 남긴다. 영어 서술은 현재 장면을
현재형으로 쓰고, 과거는 회상에만 쓰며, 한국어 수량 표현을 직역하지 않는다.

**실측 범위:** 현재 fresh-start 24주 표면은 72사건·447본문·동적 한영
487회/480고유다. 최초 결함 측정은 핵심 36본문·232문장에서 설명형 끝맺음
6건, `-었다` 계열 111문장, 시각 표기 혼용을 찾았다. 이 수치는 작성 목표나
자동 합격 점수가 아니라 전수 판정의 출발점이다.

**착수 직후 범위 정정:** 위 487회/480고유는 `first_bill_finale` 안의 인라인
`{ko,en}` 56쌍을 세지 않은 보고값이다. 실제 첫 청구서에 표시되는 문장을 빼고
전수라 부를 수 없으므로, 같은 데모 계약을 일반 재귀로 수집해 실제 총수·해시·
JA/ZH 준비 행과 문서의 기준선을 함께 바로잡는다. 24주 밖 표면은 더하지 않는다.

## 깊이 3문

1. 이 규칙과 정리 작업을 지우면 이미 확인된 설명형 끝맺음·단조로운 리듬·혼용
   시각이 P-7과 장기 회수 장면, 일본어·중국어 번역으로 그대로 복제된다.
2. 이 작업은 선택을 새로 만들지 않으므로 고른/안 고른 플레이어의 상태는 완전히
   같아야 한다. 문장을 고친 뒤에도 효과·플래그·후속 사건·주차·금액은 불변이다.
3. 정밀한 시각은 첫 청구서처럼 마감 몇 분이 선택을 압박할 때만 독해의 속도와
   경쟁한다. 그 밖의 장면에서는 생활 시간대와 인물 행동이 로그 같은 분 단위보다
   우선한다.

## 배치 A — 정본·20개 검토 단위·시각 표기 게이트

- 정본 2단위: `SCENE_TIER.md`가 한국어 장면 끝맺음·문단 리듬·시각 표기를,
  `I18N_GLOSSARY.md`가 영어 현재형 기본·회상 과거·수량 비직역을 한 번씩 소유한다.
- 자동 검사 1단위: 정확한 데모 표면에서 한국어 고유어 시각과 의미 없는 분 단위를
  찾는다. 기간·횟수인 `한 시간`, `두 시간짜리`는 시각으로 오인하지 않는다.
  첫 청구서의 `17:52`·`18:00`과 그 선택을 실제로 가르는 분만 명시 근거로 남긴다.
- 원고 16단위: 프롤로그, Chapter 1 카드, 1장 도입, 카페, 불법 제안, 아버지,
  현수, 다은, 지연, 상철, 재혁, 채용 연락·면접, 생계·성장 행동, 3월 장부·4월
  주거상담, 24주 첫 청구서, 계획판 동적 문구를 각각 독립 원장으로 읽는다.
- 한영 대조 1단위: 바뀐 한국어의 의미·사실·마지막 이미지가 영어에서도 같고,
  현재 장면/회상 시제가 의도적으로 갈리는지 확인한다. 멀쩡한 문장은 수치 목표를
  맞추려고 고치지 않는다.

각 단위 증거는 `범위/판정(PASS·EDIT)/before→after 또는 유지 근거/사실·수치
불변/한영 대응/시각 근거` 여섯 칸으로 남긴다. 규칙 1·2·4는 정규식 점수가 아니라
L2 정독으로 판정한다.

## 비범위

- 새 장면·대사·선택을 발명하지 않는다. 장면 길이, 문장 길이, 축약형, 종결어미
  비율을 목표치로 만들지 않는다. 25~240주 전체 산문과 JA·ZH 본문 번역은 하지
  않는다.
- 캐릭터별 영어 말투표와 그에 따른 대화 리라이트는 바로 다음 P-10 자식 오더가
  소유한다. 여기서는 시제·수량·한국어 편집에 따른 최소 패리티만 다룬다.

## 검증과 사람 판정

- L1: 72사건·447본문·480동적 키의 정확한 도달 범위, 한영 구조·플레이스홀더·
  문단 패리티, 시각 표기, 서사·말투·출시 인벤토리, JSON/GDScript 컴파일,
  24주 KO/EN 표면과 전체 감사·CI를 통과한다.
- L2: 20단위 전수 원장으로 마지막 문장이 이미지/행동인지, 같은 어미 3연속을
  실제 문맥에서만 고쳤는지, 현재 시제와 회상이 맞는지, 날짜·금액·화자 지식·
  인과가 바뀌지 않았는지 교차 검토한다.
- L3: 사용자는 20단위 중 임의 3개를 정상 독해로 고른다. 하나라도 번역투,
  설명형 꼬리, 사실 훼손이면 20단위를 전량 재검토한다. 자동 초록불을 문체
  합격으로 부르지 않는다.

## 완료 조건

- 승인된 네 문체 규칙이 각 정본 소유자에 한 번만 있고, 실제 24주 표면을 전수
  판정한 증거가 있다.
- 의미 없는 정밀 시각과 혼용 표기가 사라지고 첫 청구서의 선택 압박 시각은
  보존된다. 한영 사실·구조·도달·수치·상태는 바뀌지 않는다.
- 표적 검사, KO/EN 화면 표본, 전체 감사와 원격 CI가 초록이고 규범 승격·일회성
  판정을 기록한 뒤 사양을 아카이브한다.
