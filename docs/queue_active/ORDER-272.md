#### [~] ORDER-272 — 월초 돌발상황·시장 안내 중국어 UI

[~] 2026-09-20 착수. 부모 ORDER-157, 기준 main `02010c7e7aa951e3855758709b2efda4ddfad3df`.
현재 한국어 15키를 간체·번체에서 독립 저작·원문 대조하고 실제 수용분만 반영한다.

## 고정 모집단과 깊이 3문

- 원본 `.git/full-game-localization/post271-next-ui-scope.json`: 33056B,
  SHA256 `8c94c130fee2c79c3f61b32002646aa874ccafe0f4d3e684679dd2c25693ce71`.
- selected_rows 15키·8기능: 월초 bonus_ap/bonus_income/market_boom/emergency_expense/
  ap_penalty/market_shock/health_crisis의 제목·설명 14, market_cycle_log 부모 1.
  최초 소배치는 실제 확정된 8기능으로 한정한다. 15~25 추정치를 채우려 비노출 문구를 더하지 않는다.
- 제거 시 중국어가 영어 fallback으로 돌아간다. 24주 뒤 효과·선택은 바꾸지 않는 현지화이며
  원화·기간·한 일의 수와 알림/기록 의미를 보존한다. 경쟁 표면은 같은 소비자의 EN fallback이다.
- ROOT는 계획 전체와 실제 월초 호출·7분기·toast/log·시장 부모·LocaleManager를 읽고
  원문/사전/검사/공개 소비자 13개 핀의 일치를 확인했다. 실제 화면 관찰은 아니다.
- 공개121키·268~271 원선정·기보류110과 겹침0. JA15 존재는 새 JA 수용/검수가 아니다.

## 소유 파일 13개

제품: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`, `content/meta/full_game_localization.json`.
운영: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
`docs/queue_active/ORDER-272.md`, `docs/queue_archive/ORDER-272.md`, `docs/WORK_LOG.md`,
`docs/STATUS.md`, `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`,
`docs/agent_review_decisions.json`, `docs/agent_reviews/ORDER-272.json`.
ROOT는 제품·검사·Git, Plato는 private CN초안, Rawls는 private TW초안,
비저자 Poincare는 private 독립 검수를 소유한다. 초안/검수/실제 stdout·stderr·exit는
`.git/full-game-localization/order272-*`에 별도 보존한다. private helper는 기존 교환·캡처 재사용뿐이다.

## 경계와 검증

- KO/EN/JA·runtime·게임플레이·공개판·원본저장·인간원장·기존39842/b116/meta9 보존.
  검사기·기준선·인벤토리/분모·폰트·language allowlist 변경0. 첫고지 본문과 보류110 수리는 별도다.
- AP 관련 두 알림은 기존 자동 toast/log 원문을 옮길 뿐 행동판의 복원/유용성을 승인하지 않는다.
  시장 국면 %s의 neutral/bear/bull 인자는 그대로이며 부모 수용을 전체 로그 번역 완료로 세지 않는다.
- 각 지역 KO직접15초안, 상대 지역 문자변환/중역0. 비저자가 원15×2 전체를 대조한다.
  최초 실패를 남기고 같은 모집단으로 수리·재검토한다. 불합격 기능을 새로 지워 PASS로 만들지 않는다.
- 기존 export→check→현재 target 재export→import --accept 실제 영수증에만 portable을 결속한다.
  기계 실패가 남으면 해당 원형과 기능 전체 보류를 명시하고 수용과 구분한다.
- 표적 QA: 기존 `news-panel-locale-only`의 고정 고유12, 기존39842 해시/중국어 사전 raw 역복원,
  JA·원문·공개·인간·이전58 agent 판정 보존. 추가 전체 감사/240주/engine 실행0.
  clean 제품·정확 검토 HEAD에서 비저자 work_unit 판정 후 메타데이터 마감6만 실행한다.
  최초 named12의11PASS/상태머리말1FAIL은 보존한다. 이 사양 머리말·WORK·STATUS만 고친
  metadata wrapper에서 실패 queue검사만 재실행하고 이전11의 동일 제품 입력을 결속한다.
- 완료 증거는 실제 source/target·생산자/독자 위치·수용/보류수·검사 원출력·commit/tree를 기록한다.
  화면/원어민/인간/물리 패드 OPEN, 공개GO1·인간OPEN45·본편HOLD는 그대로다.

이 사양의 배치·파일소유·검증 지시는 일회성이다. 영속 언어/증거 권한은 기존 I18N/WORK_UNIT을 따른다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
