# 이야기 진행표 일본어·중국어 20키

#### [~] ORDER-263 이야기 진행표 번역

[~] 착수 — 2026-09-19, Codex. clean main 기준
`c87c9758e514da18a66a274731a739854a6a3a5f`, tree
`82ec3565fea3b326b9ca831c7f5e2d4534ae1d9e`. 공식39151/b109/meta9.
기존 현지화 계약의 일회성 적용이며 새 영구 규칙0이다.

## 한 단위와 근거

기존 `_refresh_arc_box`의 진행표 고유20키×3언어=60만 다룬다.
스토리 아크, 첫 만남, 거리 둠 / 가까워짐, 기로, 결말, 투자 조언,
두 번째 커피, 옆방 라면, 그의 경고, 진실, 전화, 이상 신호, 병원 소식,
방문, 별세 / 여운, 화해 / 여운, 유대, 투자 제안, 도주 / 반격, 사후처리.
JA20 기존값을 한국어 문맥에서 검수하고 CN/TW각20을 직접 번역한다.
JA의 커피 잔 수·기술적 이상 신호·병원 직접 발신 암시를 실제 원문에 맞춘다.

깊이3문: 없으면 중국어 진행표는 영어로 남고 JA는 인물 사건의 사실을 오독한다.
선택/24주 상태/1년·5년 이야기·경제 변화0인 표시 번역이다. 같은 자리의 실제
UI 소비자 수리와 경쟁하되 기존 lookup의 확인된 결손을 채운다.
진행표 호출21과 `_ap_act_info`의 동일 진실1은 고유20이며22번 수용하지 않는다.

## 사실·호환 경계

커피는 두 번째 대화 맥락이지 두 잔째/리필을 확정하지 않는다. 이상 신호는
이웃의 불확실한 연락이며 진단/입원 확정이 아니다. 병원 소식은 어머니가 전한다.
완료/대기 접두어와 단계 조건은 그대로다. 별세와 화해 분기, 방문 여부, 결과의
불확실성을 보존한다. 참조 사건의 min_turn9999를 신규 도달성으로 세지 않는다.
이야기 탭 전체·남은 카드제목/힌트·월/통화 표기는 이번 완료가 아니다.
AP/생활/People 진입·카드 노출·장면·선택·소유·수락·건강 상태·저장 변경0이다.

## 파일 소유권

- ROOT 제품4: `locale/ui_ja.json` 선택20 중 승인된 차이만,
  `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json` 각20 append,
  `content/meta/full_game_localization.json` 신규60/batch1.
- ROOT 운영10: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  본 사양, `docs/queue_archive/ORDER-263.md`, `docs/WORK_LOG.md`, `docs/STATUS.md`,
  `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`, `docs/agent_review_decisions.json`,
  `docs/agent_reviews/ORDER-263.json`.
- ROOT JA, Plato CN, Rawls TW 초안; Poincare 비저자 전수60 언어·최종 증거 검수.
  보조자는 private 초안/검수 파일만 소유하며 제품 적용·검사·Git은 ROOT만 한다.

코드·수집기·validator·audit_scope·project·저장·공개후보·human ledger·손상 mirror0.
old39151 원장 전체와 선택 외 UI raw를 보존한다.

## 검증·완료

1. RO 계획8c3a5982/bccb3fdd는 범위 근거뿐이다. 선언 뒤 actual collector20,
   보호0 예상·Main실제22호출·source hash를 확인하고 편집 전3 source export를 보존한다.
2. 독립 전수60 검수→선택60 L1→승인값만 편집한다. clean 제품에서 재export/check/
   import --accept 후 receipt/source/target 결속으로 portable60만 더한다.
   예상39211/b110/JA13069/CN13071/TW13071은 실제 수용 전 완료값이 아니다.
3. 신규60 L1 및 old39151 현재 source/target 해시와 raw 역복원을 검증한다.
   기존 전체L1 반복0. `news-panel-locale-only`의 고유12 검사목록만 재사용하며,
   새 ROOT driver가 baseline→HEAD 전체 diff를 이번14 소유권으로 별도 제한한다.
   기존 차선 소유권·기대 변경0, 엔진·전체감사0. 최초 stdout/stderr/exit를 보존한다.
4. clean exact source/검토HEAD와 최초 증거를 독립 단위판정에 결속하고 원문보관·
   판정1행·metadata만 마감한다. 문서 한도나 검사 기대를 올리지 않는다.

기계/에이전트 PASS는 렌더·정상속도 인간플레이·원어민·물리패드 증거가 아니다.
공개 GO1·인간 OPEN45·본편 HOLD·외부 출시 권한0을 유지한다.
