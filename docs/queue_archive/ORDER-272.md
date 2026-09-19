# ORDER-272 — 월초 돌발상황·시장 안내 중국어 UI

[x] 2026-09-20. 독립 Poincare work_unit GO는 이번 30수용·0보류 처리에만 적용한다.

- 제품 `b61eeb59db9bd49281701507f4e1f627869ba000`, tree `b8ef26ee69d90d8c0ec6e6338d2e2fd9d66681f8`. clean 검토 `49428e8e5d1a2e325ee8d4e3edeac2cfecc82378`. source 이후 사양 머리말·WORK·STATUS만 변경.
- 최초 명명12는11PASS/queue1FAIL이다. 문서 머리말만 수리한 뒤 같은 queue검사 PASS, 원형 실패 보존.
- 고정8기능15키×2=30초안 전수 원문대조다. AP행동판/전체시장로그·공개/인간/본편 GO가 아니다.
- 실제 수용 39872/b117/meta9. 기존39842 보존; UI/portable 역복원과 JA/원문/runtime 보존.
- 원어민·렌더·인간플레이·물리패드 OPEN. 공개GO1·인간OPEN45·본편HOLD·기존보류110 유지.
- 원형 QA·실패·수리·남은 위험은 [독립 보고](../agent_reviews/ORDER-272.json), SHA 657dfadea284520ae356d6a129faaaffa41c375542fad8a9cc67015d965c0ae7.
- 일회성: 본 배치 번역·선정·검증·수용·파일소유 지시. 영속 권한/언어규칙은 기존 WORK_UNIT/I18N 소유, 신규 규범 승격0.

자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

## 실제 캡처

원문은 git-private에 stdout/stderr/exit·입력핀과 보존한다. 진단 수집 exit0와 전체 통과는 다르다.

| 파일 | 바이트 | SHA256 | exit | 결과 |
|---|---:|---|---:|---|
| order272-export-cn-first.json | 377535 | 8523e6167d765d0c1adaf62b7e9dc71cf2ac55c399aed2a536ea447f62c95a6c | 0 | PASS |
| order272-export-tw-first.json | 377535 | 74a4649de888641e4d6bfe37d303130e983c445a96fc057d03e2927aaab2e4f5 | 0 | PASS |
| order272-formal-export-cn-first.json | 377564 | e060bf5e4280529638e41bcc12d8b53e58fe2831689913c43d39eb1c659f7334 | 0 | PASS |
| order272-formal-export-tw-first.json | 377564 | 4a4ecd58b391d32900e40c9cf0c8f693514c7c53a444b94a6f822d7fe2495e65 | 0 | PASS |
| order272-formal-import-cn-first.json | 377517 | 73b0a6bd66393cadec959ffb6b023a066de0e587d021c1633f76bf062de07004 | 0 | PASS |
| order272-formal-import-tw-first.json | 377509 | 3d16c1db1caff1cc36c78f8fa9470f276cde0f7eed5309c70fee80be463ea9f8 | 0 | PASS |
| order272-named-first.json | 1691153 | 10a78d5de567f5d7a69c59e37a085c2b6e647adf010be46e311d45a12242a8dd | 1 | FAIL preserved |
| order272-named-outer-first.json | 379624 | 188e9e8c5dd1d50da26ee94f9c82758218a6666d0c30a45e8fd6fe1665639d4c | 1 | FAIL preserved |
| order272-preflight-check-cn-first.json | 377491 | 31a2ec2051e1805f3a6d40e60d6a2d92372a7c6a2ab28003c799564dd32e0521 | 0 | PASS |
| order272-preflight-check-tw-first.json | 377489 | 2c5774753dffe0a51deda843cc68f33889b0b4790e41f492f6f7af810271aa9a | 0 | PASS |
| order272-preservation-first.json | 377737 | 91a07e2fad9651ec331ae73c705a620175b50e96d7de0e9d15b0151d6417d086 | 0 | PASS |
| order272-queue-recheck-first.json | 377136 | b47b7a82dd94e7654b2fcecb1818747ff0177e6a4451e9fa3f4f75686eb79c88 | 0 | PASS |

## WORK 마감 전 원문

# Gangnam Dream Work Log

> 이전 WORK·현재 선언·실패 원문은 [271 보존본](queue_archive/ORDER-271.md)에 있다.

## 2026-09-20 (Codex — 월초 돌발상황 중국어 30초안 착수)

- [272](queue_active/ORDER-272.md): 확정15키·8기능, 지역별 독립KO직접저작과 비저자 전수 대조.
- 계획 post271-next-ui-scope.json의 전체/13핀을 확인했다. 실제 수용 전이며 기존39842와 보류110 보존.
- 첫고지본문 collector 수리와 보류110은 별도. 코드변경 없는 확정 UI 누락을 먼저 닫는다.
- 최초비저자30전수언어GO/필수0, 양언어 기존check/import각15실제수용. 최초기계실패/신규HOLD0.
- 공식39872/b117/meta9, JA13096·CN/TW각13388. 사전각859존재/2156부재는 전체실제UI분모가 아니다.
- clean exact·명명12·보존·비저자최종은 다음 마감 증거로 분리한다.
- 최초명명12는11PASS/queue1FAIL이다. 활성 사양의 상태 머리말은 `#### [~] ORDER-ID`여야 한다.
  처음 만든 사양에 그 형식을 빠뜨린 문서 오류만 고치고 실패검사만 재실행한다. 최초 증거는 보존한다.

## 2026-09-20 (Codex — 월말결산·경고 중국어 90 반영)

- [271](queue_archive/ORDER-271.md): 제품1fadb15·검토efcdcfa, 독립 Poincare 한정GO/필수0.
- 원90초안 전수 언어검토 뒤 실제90수용·0보류. 상세 실패·의미·원고는 독립보고에 보존.
- 공식39842/b116/meta9. 기존39752·KO/EN/JA·runtime·공개판·인간원장/과거57판정 보존.
- 명명12 통과는 회귀증거이며 원어민·화면 완료가 아니다. 공개GO1·인간OPEN45·본편HOLD.

## 다음 안전한 범위

- 첫고지본문1의 JA/CN/TW누락과 수집 미노출은 별도 수리 대상이다.
  `.git/full-game-localization/post270-first-warning-repair-scope.json` 7257B/SHA66a21413b144447af3b99671907bb058b5892aca1962df3a07bc29fef438c6ba.
  ROOT가 RO메모 전량을 읽었다. 기존KO/EN7literal씩을 같은완성값의 단일literal로 펴는 방향이며, 새1key의 현재/역사 collector경계와 JA누락을 별도선언으로 검증한다. 새collector대형화0.
- 이전268보류62+269보류38+270보류10=110 원고는 각 독립보고에 보존했다. 재저작 없이 실제 기계경계 수리와 회복수용 대상이다.
- 271은 sourceplan의 is_english 의미오류를 저작전정정했다. language!=ko인 소비자는 CN/TW도 true로 읽는다.
- 현재 원문 `자산10억! 절반`, 저자산만 본 `아직 초반`, 투자확인 없는등급, 경고의잠/식사묘사는 별도정합 수리후보다.
- 비보호 shipping 사건11578 세 언어 수용 완료.843은 참고741·보호102이며 신규 활성 사건 공백이 아니다. 실제화면·동적표시명·직행EN·원어민 검수는 별도다.

## 활성 사양 원문

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
