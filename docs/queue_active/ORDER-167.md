# Active Queue Spec: ORDER-167

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-167 [P0·전체 현지화] 마지막 서명과 사람에게 보내는 행동을 세 언어로 옮긴다

**[~] 2026-09-07 Codex L1/L2 수용·L3 OPEN — 아래 정확15 ID의 JA·zh-CN·zh-TW text-only
overlay, 원문 결속 검사·수용 기록·증거 문서만 소유한다.**
사용자 전체 게임 번역 지시를 구현 `80c0702`에서 이어간다.
기존7,866 수용·비표시 메타9·공개 working baseline과 배경 제품53493fe를 보존한다.

## 깊이 3문

1. **없으면 무엇이 깨지는가?** 마지막 해의 계약·가족 판정 뒤 실제 서명과
   선발신이 다시 영어로 돌아간다. 부동산/일반·생존/별세·미집행 분기를 함께
   옮겨 앞선 선택의 회수와 최종 책임을 같은 언어로 읽게 한다.
2. **선택을 바꾸는가?** 효과·일정·생사·주거·채널·참가자·라우팅 변경0이다.
   가능 여부를 묻는 발신은 답장·약속 확정이 아니고 비교 자료는 계약·소유가 아니다.
   실제 서명, 철회, 응답 부재를 각 원문과 조건 그대로 보존한다.
3. **무엇과 경쟁하는가?** 남은 일반 사건·UI·실제 소비자 번역이다. 이15종은
   M49~M60 shipping seed51의 정적 closure61 안에 남은 정확한 묶음이지,
   해당 기간 모든 무작위 사건·화면이나 실제 플레이 전량이라는 뜻은 아니다.

## 한 배치 — 정확15 사건

- `arc_y5_general_debt_memory_cafe_exact`
- `arc_y5_general_debt_memory_voice_exact`
- `arc_pre_ending_summit`
- `arc_y5_general_pre_ending_summit_exact`
- `arc_y5_property_not_executed_notice`
- `arc_final_countdown`
- `arc_final_countdown_general_near_goal_passed`
- `arc_final_countdown_property_not_executed`
- `arc_final_week`
- `arc_y5_final_father_answer_alive`
- `arc_y5_final_father_answer_passed`
- `arc_y5_final_week_daeun_outbound`
- `arc_y5_final_week_general_people_outbound`
- `arc_y5_general_final_record_seal`
- `arc_y5_remaining_jaehyuk_or_self`

197 leaf/24,775 KO자(공백·개행 포함), 표준142+finale reader55다.
사전형 조건38=known19+memory5+description moral2+choice moral12이며,
`arc_pre_ending_summit.description_orthodox/unorthodox` scalar2는 별도로 포함한다.
reader55/12roots의 inline/prepend, sources·texts/true/false/default 배열,
`[[c5read:n]]` 인덱스·개수·순서는 원문과 같아야 한다.

독립 collector/직접 재귀 추출의 ID/path/KO문자열197이 동치이다.
전부 protected=false, shipping, builtin_overlay_static_only이며 기존 target·
accepted·author-only·공개·planned-missing 겹침0이다. summit/countdown/final_week
3종의 기존 story map EXPAND/needs_rule은 그대로 남으므로 shipping 분류를 서사 GO로
해석하지 않는다. 한 source export197/198JSONL행은 limit256 안이다.

## 정확한 소유권

각 `content/events_<ja|zh-CN|zh-TW>/`의 다음3파일에서 위15 ID만 추가한다.

- `arc_pre_ending.json` 9roots/106 leaf
- `arc_drama.json` 4roots/67 leaf
- `arc_year3_drama.json` 2roots/24 leaf

언어별 작성자1명, 교차 검토자 읽기 전용이다. 기존행·키·값·파일 prefix를 먼저
읽고 보존하며 새 행만 붙인다. 모든 문장은 KO 직접 저작이며 영문 중역·간번 변환0.
ROOT는 `tools/full_game_localization.py`, `tools/full_game_localization_self_test.py`,
`tools/zh_translation_audit.py`, `tools/audit_scope.json`,
`content/meta/full_game_localization.json`, 이 사양·CODEX_QUEUE·CLAUDE·WORK_LOG·
생성STATUS·전체 현지화 backlog를 소유한다. 부팅 예산 때문에 완료절을 옮길 때만
기존 `docs/history/WORK_LOG_2026-09-07_localization.md`에 원문 바이트로 보존한다.

KO/EN·runtime·저장·routing·human_gates·catalog/endings·공개 overlay·폰트·
배포/언어 출시 파일은 비소유다. 원문 결함은 번역으로 몰래 고치지 않는다.
새 수량/호칭 오탐은 실제 source와 정상/변조 짝을 만들고 독립 검토한다.
기존 공개 baseline을 완화하지 않는다.

## 검증과 보존

- 원문 manifest `edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`,
  선택197 source aggregate `1ad9f258f5744778cd6ffd2d59881636f053a0c62eb24bf539dc4d203d283a28`.
  최초 source3개를 별도 보존하고 최종 source/response/receipt3쌍을 발급한다.
- 세 언어591문구를 작성자를 바꿔 KO 전수 대조한다. reader55/언어·조건 대안과
  주체·날짜·수량·금액·생사·발신/회신·동의·소유·책임의 범위를 확인한다.
- 이전7,866/meta9·공개본과 기존행의 값/순서/raw prefix를 보존하고 새 수용만 합친다.
  draft 미수용 scope 실패를 baseline 완화로 우회하지 않는다.
- L1 `full-game-localization-overlays` 표적 차선·EN·diff·source/target receipt,
  독립 L2를 실행한다. L3·원어민·실제 화면은 별도 OPEN이다.
  전체 INCOMPLETE·full/main/product HOLD·배포 M01~M06 사용자 GO를 유지한다.

범위·파일·증거는 일회성이다. 지속 현지화 규칙은 기존 I18N_INFRASTRUCTURE와
세 용어집이 소유하며 새 서사·상품·출시 규칙을 만들지 않는다.

## 수용 결과 — L3·원어민·화면 OPEN

- 선언 `c6afbfc` 뒤15종197×3=591문구를 직접 저작하고 다른 작성자가 KO 전수
  대조했다. 철회 창구 날짜3·보증 주체3·사과 지연1·두 종이 행동1, 총8문구를
  고쳐 재대조했다. 이전7,866·메타9·각 언어 기존59행의 값/순서/raw prefix는
  독립 보존검증 PASS다. KO/EN·runtime·공개·폰트·human_gates 변경0이다.
- 초기 source3개를 보존하고 최종 source/response/receipt3쌍을 발급했다.
  각197개 check/import PASS·changed_files=0이며 portable 수용8,457개다.
  accepted checksum `c02b5815a16893f4df3b3cf15a31a4059aebbd4c6992785386930a0ec41a9de8`.
  최종197-record aggregate:
  - JA `c2b56fe23a46f85c566972a323205e118dc9b0ae1b6c519ecba24ec450aa4082`
  - CN `f00d093fb63c762ec9f3af0dd0bc80078da6fd7b9c27a930aeaeb32522c994ce`
  - TW `b126e2eeed13ae4d814688188aedb5d8a409488a28ba8f9b7b0806366b4aea56`
- 실제 원문의 원본/원화·관형절·서명1/2/3·줄긋기·식사·하루·시각과
  합의 당사자2/화면1/도시2를 구분하도록 수량 검사를 보강했다. self121 PASS,
  독립87 fixture에서 신규 누출0이다. 기존에도 통과하던 장부→帳戶資料 의미 한계
  1건은 별도이며 기계 검사를 완전한 의미 검증으로 부르지 않는다.
- 숨은 경로 표시·전날/오늘 지시의 원문 부채는 backlog에 기록하고 번역으로
  몰래 고치지 않았다. 완료164 WORK_LOG절2,618bytes를 history로 이동했으며
  이전 history 본문과 이동절이 그대로 복원된다. 새 history11,808bytes SHA
  `5244fbed9ba58f0212bcac18ec442444bbe7e4a520c903e6565870fe2bed421f`.
- 전체 INCOMPLETE·full/main/product HOLD·출시 데모 GO를 유지한다.
  다음 범위는 남은 관계·생활 사건이며 전체 번역/실플레이 완료 판정이 아니다.
- 최종12개 표적 차선·EN·diff PASS: self121·ZH935·공개14사건100문구/UI121
  유지. 실제 stdout은 git-private `full-game-localization/order167-final-checks.log`.
  중국어 full 폰트 JP-first 차단은 기존 잔여이며 skeleton PASS로 닫지 않는다.
