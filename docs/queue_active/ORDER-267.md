# 새 게임 기록의 다국어 전달

#### [~] ORDER-267 새 게임 기록 locale 소비자·번역

[~] 착수 — 2026-09-20 Codex. clean main
`242fb9ab0bb776980b88843362c415c324a99f6c`. 공식39265/b111/meta9·old53판정.
한국어 원문 직접 번역의 기존 계약을 적용하는 일회성 단위이며 새 영구규칙0이다.

## 한 단위·깊이3문

새 게임의 출발 상태와 먼저 눈에 들어온 소식 기록에서 준비 언어가 영어 인수를
직접 받는 결함 하나를 고친다. `start_new_game`의 profile 부모, `_localized_profile_label`,
`_roll_run_theme`의 표시 코드만 대상으로 한다. 삭제하면 영어 직행과 부모/인수 혼합이
남는다. 24주·1년·5년 선택/게임 상태 변화0인 표시 수리이며 사전만 추가하는 방법과
경쟁하되 실제 생성자까지 연결한다. 새 프로필·테마·route 선택 UI는 만들지 않는다.

원문11 = profile2(백수/알바), category7(투자/직장/인간관계/건강/연애/도박/재정),
기존 부모2다. 실제 원문·현재 target·source hash를 먼저 수집한다. `알바`의 명사형은
Gigs와 시작 상태에, `직장`의 仕事/工作는 Jobs와 일반 Job fallback에 공유 가능함을
Poincare가 실제 소비자에서 확인했다. 건강은 기존 legacy健康와 BODY context를 구분한다.
새 context ID0, 기존 투자/건강 수용6은 재수용·신규 건수에 더하지 않는다.
예상 새27/공식39292는 실제 receipt 전 완료 수치가 아니다.

## 소유권

- ROOT 제품: `autoloads/GameState.gd` 위3span, `locale/ui_ja.json`,
  `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json` 위11키 승인 차이,
  `content/meta/full_game_localization.json` 새 수용만, `tools/audit_scope.json` 전용 차선.
- Plato 제품: `tools/main_game_locale_history.py`, `tools/year5_reference_route_audit.py`,
  `tools/chapter1_core_loop_v2_causal_ledger_check.py`, `tools/ja_translation_pipeline.py`,
  `tools/ci_localization_reconciliation_self_test.py`, `tools/meta_title_locale_successor_self_test.py`,
  `tools/gift_caption_locale_self_test.py`, 새 `tools/new_run_log_locale_self_test.py`.
  기존 본문·원장·fixture는 원형 보존하고 현재 raw 선검사와 exact 역사 관측만 결속한다.
- Rawls 제품: 새 `tools/NewRunLogLocaleCheck.tscn`, `tools/run_new_run_log_locale_qa.sh`.
  기존 pre-autoload 격리 bootstrap/runner를 재사용한다. 원본 저장은 열지 않는다.
- ROOT 운영10: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  본 사양, `docs/queue_archive/ORDER-267.md`, `docs/WORK_LOG.md`, `docs/STATUS.md`,
  `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`, `docs/agent_review_decisions.json`,
  `docs/agent_reviews/ORDER-267.json`.
- ROOT JA/CN, Rawls TW는 각각 KO에서 직접 저작. Poincare 비저자 언어33 전수와
  사전 fixture·실제 산출물·검사 원문을 독립 검수한다. ROOT만 실행·Git·수용한다.

도구 범위가 넓은 이유는 기존 GameState whole8a407·수집기·self의 역사 봉인을
보존하기 위해서다. `.git/full-game-localization/post265-profile-theme-adapter-plan.json`
SHA12b935acac2a3cc340d72afb2e62847d1e6c8cde63e3ff8539922a5929e28d10의 최소 연결을
따른다. 옛 거대 fixture 복사·기존 expected/hash 교체·검사 완화는 하지 않는다.

## 제품 경계

기존 KO/EN 완성 문장, profile unknown 원값 passthrough, pool.shuffle/두 ID/순서,
run_theme_categories·가중·상태·시간·세이브 포맷은 불변이다. 생성 시점의 기록만
현지화하며 기존 action_log를 언어 전환 때 소급 번역하지 않는다. 부모 미스는 명시
영어 부모+영어 인수를 쓰고, 번역 hit의 인수도 실제 lookup을 거친다. 인수 미스의
기존 영어 fallback·community 우선순위와 invalid format 거부를 숨기지 않는다.
MainGame/LocaleManager/StartMenu/EventManager/DataRegistry·project·사람 원장·공개
데모·소스 원문·카테고리 gameplay ID·판정 권한은 비소유다. 휴면route4 비노출 유지.

## 유한 검증

1. 독립 언어33 검토와 편집 전3 export. 선택11의 기존 수용/미수용을 실제 분리한다.
2. Poincare가 코드 전 사례를 봉인한다: 현재 GS3span/수집기 정상, 개별 rollback·
   무관 byte·위조 hash/registry·selector/format provenance·OFF와 실제 Year5/Chapter
   원문 선검사. 정상 성공 뒤 음성을 세고 새 사례와 기존 역사 사례를 구분한다.
3. 승인된 표시/번역만 적용. 실제 원문 수집은 새9 UI호출과 부모2 format 전환을
   노출하고, 옛 정본 검사는 역투영한 과거에서 실행한다. 이전 호출 위치를 현재로
   속이지 않는다. source denominator 증분은 실제 수집 후 기록한다.
4. clean 제품 공식 export/check/import --accept, 신규 receipt만 portable에 결속.
   old39265 현재 source/target·원장/UI 비소유 raw 보존을 확인하되 old전체L1 재실행0.
5. 별도 격리 headless component1: KO/EN/JA/CN/TW, profile2+unknown, category7,
   동일 RNG·게임 상태·실제 add_log→기존 Main 기록 reader, 부모/인수 미스와 community,
   기존 기록/저장 불변을 검사한다. 의미별 사례를 사전 고정하며 숫자 채우기0이다.
   최초 stdout/stderr/engine log·exit·오류·입력 pins를 보존하고 marker와 오류 부재 모두 필요하다.
6. 전용 차선1회: new source self, 기존 CI/meta/gift self 각 역사 위임, Year5/Chapter,
   full localization self, JA self/UI, ZH self, EN, story-demo self/actual,
   selector verify, queue self, agent self와 context/queue. 엔진·전체감사·240주 반복0.
7. 비저자 clean exact 단위 GO 뒤 원문보관·판정1행·STATUS·metadata4만 마감한다.
   첫 실패는 원형 보존하고 새 원인/범위는 별도 선언한다. 문서 예산 상향0.

자동 계약증거는 재미·깊이·문체·원어민·실제 화면·인간 플레이·물리패드 관찰이 아니다.
공개GO1·인간OPEN45·본편HOLD와 외부 출시 권한0을 보존한다.

## 구현 중 관측 — 실행·수용 전

- 언어33 초검수의 JA 재정 `家計` 범위 축소를 `お金`으로 수리했다. 원 REWORK와
  개정 전수GO(93a09c22)를 각각 보존한다. 새 수용은 아직0이다.
- GS3span은5076adf7로 적용했다. old8a407 exact 역복원을 사전 코드 검수했다.
- 도구7 초검수(ce36f98f)의 current format_calls 누락1을 수리했다. 원 기록을 유지한다.
- 도구8 사전 PASS/필수0(ee004c83) 뒤 self binding만 실행 승인했다. 아직 실행 성공 증거는 아니다.
- runtime2 사전 PASS/필수0(08664542) 뒤 승인 bit만 바꿨다(scene7d314a97).
  엔진·QA 성공이나 화면/인간 판정이 아니다. 공식 export는 대상 사전 편집 전에 시행한다.
- 실제 원문17484, UI3666/미확인329, manifest2346e6c4. 독립33과 표적L1 33/0 뒤
  clean4d712e3 공식9×3 export/check/import(사전 추가편집0)와 신규27 portable를 결속했다.
  현재39292/b112/meta9이며 기존6재사용·원래39265 보존은 별도 검증한다.
