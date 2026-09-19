# 월말 결산·현금 표시·경마 복귀 경고 중국어 UI

#### [~] ORDER-271 중국어 UI17기능·47키

[~] 착수 — 2026-09-20 Codex. clean main `d997f302a09d2ffc5460d714fed78d3020c63232`.
공식39752/b115/meta9·기존57판정. 남은 실제 중국어 문구 저작을 우선한다.

## 깊이3문과 고정 범위

이 번역을 빼면 월말에 돈·몸·마음·시간을 돌아보는 표면과 경마 복귀 경고가 영어로 남는다.
24주 뒤 게임 상태는 변하지 않는 현지화 작업이며, 같은 화면의 영어 폴백과 경쟁한다.
새 선택이나 도달 경로를 만들지 않고 현재 호출과 사실 의미를 검수한다.

고정 계획 `.git/full-game-localization/post270-ui-next-plan.json` 41021B,
SHA `30953c7c60e7107c2c41200193d1159ccfc76d23c64ae3e218b555a11061e423`의
48키18기능 중 `first_start_warning` 한 키를 뺀 47키17기능만 이번 번역 모집단이다.
ROOT가 계획 전량·KO/EN48·조건·제외를 읽고13현재핀을 확인했다.
현금3·수첩2·결산입금기록3·결산틀2·수입/비용카드7·지원금1·판정/잔여4·몸1·마음1·
주간시간배분3·선택기록1·급증3·성장3·생존/일반4·적자3·위기2·경마의존경고4.
JA47은 기존값을 보존한다. first_start_warning은 세언어누락·수집지원 미관측으로 별도 RO 조사만 한다.

## 파일 소유

- ROOT 제품3: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`의 선택47 추가,
  `content/meta/full_game_localization.json`의 실제 신규 수용만.
- ROOT 운영10: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  본 사양, `docs/queue_archive/ORDER-271.md`, `docs/WORK_LOG.md`, `docs/STATUS.md`,
  `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`, `docs/agent_review_decisions.json`,
  `docs/agent_reviews/ORDER-271.json`.
- Plato 간체·Rawls 번체: KO 직접 독립저작, 각각 private 초안만. Poincare 비저자 전수 언어·최종 exact 검토.
  ROOT만 제품/QA/Git. private 일회성 보조는 기존 교환/캡처를 최소 변경해 재사용한다.

## 의미와 비소유 경계

주차·현금·자산·수입과 고정비의 차이·실제 지원금/급여 수령을 그대로 둔다.
이미 기록된 주간축과 실제 행동기록만 표현하고 AP 판·전화·투자 기능을 활성화하지 않는다.
문맥 수첩의30억은 원화이며5년기간/개월token을 보존한다. 경고는 기존 조건·주장의 번역이지 새 측정값이 아니다.
자산증가만 본 등급의 투자 묘사, 저자산 분기의 '아직 초반', 중독지수만 본 잠/식사 경고는 원문 한계다.
번역이 원문보다 원인·수익·회복·생리 상태를 더 확정하지 않는다. 원문 수리는 이번 비소유다.
보존: KO/EN·JA·runtime/선택/라우팅/저장·공개M01~M06·인간원장·기존39752·기보류110.
원268/269/270키·공개121·first_start_warning·비활성 AP/phone/debug/fallback·직행EN 수리·검사/fixture/pin 변경0.

## 유한 검증과 마감

1. clean 선언에서 기존 collector로 각47 export, 실제ID/KO/지원/보호 확인. KO직접94초안→비저자전수.
2. 기존 check 첫 실패는 보존. 언어 결함이면 원모집단 전체 재검토; 기계경계면 해당 기능 양언어를 HOLD로
   분리하고 원94전체통과로 부르지 않는다. 보류원고는 최종보고에 보존. 새검사 확장/왜곡번역0.
3. 승인값만 apply_patch 설치→clean 재export→기존 import --accept 실제receipt와 변경0확인.
   실제 수용만 portable추가, old39752 현재해시·UI/portable 역복원·JA 보존을 clean 후보에서 검사한다.
4. `news-panel-locale-only` 고정명명12를 이번 전체diff와 owned13에 결속해 한 번 실행한다.
   전체 감사·engine·240주·새guard0. 자동검사와 별개로 비저자 clean exact 한정판정을 받는다.
5. GO후 보고/원장/큐/WORK/STATUS metadata 마감과 변경에 맞는 기존 selector검증→main/번역브랜치 동기화.

이번 저작·선정·검증·파일소유 지시는 일회성. 영속 언어·권한규칙은 기존 WORK_UNIT/I18N이 소유한다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
공개GO1·인간OPEN45·본편HOLD. 원어민/실제화면/인간플레이/물리패드·외부출시 권한0.
