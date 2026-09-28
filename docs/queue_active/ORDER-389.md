# Active Queue Spec: ORDER-389

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-389 [P1·전체 현지화] 신용등급·튜토리얼 위험 중국어 UI 10값

**[~] 2026-09-29 Codex 착수 — 아래 파일만 소유한다.** ORDER-157의 전체판 번역
위임을 따른다. ORDER-388에서 제외한 신용등급4키와 공유 한국어 `위험`의
튜토리얼 context1키를 별도 수용한다.

## 깊이 3문

1. 없애면 무엇이 깨지는가: 신용등급과 튜토리얼 위험 표시의 영어 잔여 또는
   공유 fallback 혼동이 남는다. 신용 평가는 실제 등급 소비자 의미로 옮긴다.
2. 24주 뒤 상태 차이: 표시 번역이며 새 선택이 아니다. 신용점수·등급·금리·
   대출·AP·진행·저장 변화0. 위험을 안전으로 뒤집거나 등급 경계를 바꾸지 않는다.
3. 경쟁: 남은 UI와 검수 시간이 경쟁한다. 공유 fallback을 함께 닫는10값을
   전수 독립 검수하고 4등급과 튜토리얼 실제 소비자만 준비상태로 렌더한다.

## 정확한 파일 소유권과 모집단

- 제품: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json` 신규 각5키 및
  `content/meta/full_game_localization.json` 공식 수용·영수증 append만.
- 키: `우량`, `ui.credit.standard_grade`(한국어 `보통`), `주의`, `위험`,
  `ui.tutorial.danger`(한국어 `위험`). 기존 plain `보통`과
  `ui.investment.warning_badge` 및 JA 값은 보존한다.
- Root: 공식 교환·수용 연결·표적 정적검증·기록. `/root/compat357`:
  private `order389-zh-CN-draft.json`, `order389-zh-TW-draft.json` 독립 직접 저작.
  간번 변환·영어 중역 금지. `/root/screen_path_probe`: private
  `order389-check.gd`, `order389-check.tscn`, `order389-run.py`와 격리 화면 증거.
  `/root/r3_route_probe`: 비저자 원문10값·실제 PNG 전수 검수, exact source 판정.
- 기록: 이 사양·큐2개·CLAUDE·WORK_LOG·STATUS·필요시 기존
  `docs/history/WORK_LOG_2026-09-07_localization.md`로 손실 없는 이동,
  `docs/agent_reviews/ORDER-389.json`, `docs/agent_review_decisions.json`,
  `docs/queue_archive/ORDER-389.md`; private `order389-*` 교환·검증·검수 증거.

## 표적 검증과 한계

- 공식 export/check/import 각2배치, token/숫자/지역문자·한국어 의미 전수·
  기존 raw 역삭제 및 수용 receipt 보존. context ID와 한국어 source를 구분한다.
- 현재 UI append guard·영향 consumer5·중국어 검사·context/queue/diff·기존
  overlay 차선 조회. 최장 첫장 검사를 먼저 병렬 배정한다. 검사기 변경0,
  변경 없는 self·전체 감사·240주·JA 재실행0. 성능 향상은 관측 전 주장하지 않는다.
- 실제 MainGame 신용등급4단계와 tutorial danger 노드, CN/TW 1280×800
  SC/TC font·glyph·문구·경계·PNG. 초안 폭 예비검사와 수용사전 실제 실행은
  구분한다. 격리 bootstrap·실사용자 저장 불변·준비상태 typed 복원 증거를 남긴다.
- 동적 대출상품명은 `unverified_consumer`이므로 제외하며 collector를 우회하지 않는다.
  레거시 은행 전체·자연진입/복귀·실제 거래·새 입력·기존 선택테두리 약3px
  잘림 수리는 제외. 새 runtime 결함은 별도 선언한다.
- KO/EN/JA·경제·런타임·저장·project.godot·공개데모·사람원장·출시언어 불변.
  기존152판정/130보고·실패/GO/HOLD/OPEN 보존. 원어민·인간·물리 미관측과
  본편/새 package HOLD 유지. 외부 출시·스토어·지출·법률 행위0.
- I18N/WORK_UNIT 정본 재사용, 새 상시규범0. 모집단·분담·검증 계획은 일회성.
  자동 PASS는 계약 증거이며 재미·깊이·문체·원어민/인간/출시 GO가 아니다.
