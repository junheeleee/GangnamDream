# Archived Queue Spec: ORDER-308

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-308 [QA] 데모 원룸 월세의 쉼표 경계 오탐

2026-09-27 착수. source `354c270`의305 언어검사에서 CN/TW orthodox 두 곳만 FAIL.
실제 KO `월 칠십,`과 중국어70만은 같지만 공유 구어 regex가 쉼표 앞 `칠십`을
`칠`까지만 되돌아 읽어7만원으로 잘못 셈한다. 실패 원본305-localization-first 보존.

- 깊이: 검사 오탐을 그대로 두면 맞는 번역을 틀렸다고 판정한다. 검사를 끄면 실제
  금액 손실을 놓친다. 정확한 현재 문장의 검사 입력만 명시형으로 바꾼다.
  게임경제·플레이어 선택/보상·기회비용/경로 차이는0이고 새 원고를 쓰지 않는다.
- 저자 `/root/release_status_crosscheck`: `tools/story_demo_localization_audit.py`만.
  정확 key `event::arc_sangchul_01_meet::description_orthodox`와 정확 금액 문구의
  교집합만 명시형70만원으로 정규화한다. 공유zh parser/실제5언어원고/게임코드 변경0.
  기존8self-case 보존, CN/TW 실제값 positive 및7/55/700만·보증금·통화표시·토큰
  변조 negative, 다른key/다른금액·부분prefix에 새정규화가 적용되지 않는 경계 추가.
- root: 큐2파일·이 사양·WORK_LOG·생성STATUS·새scoped판정원장,
  private `order308-*` 증거 및capture308label. 비저자 `/root/blackjack_accounting_review`:
  private `order308-review*.json`와 `docs/agent_reviews/ORDER-308.json`만 소유한다.
- 검증: demo localization normal/self, 보존23leaf/40299 및selector/context/queue.
  앞 후보의 엔진1회/5언어·702year5self·다른호환 PASS는 원고/실행코드/검사기 무변경
  diff bridge와 실제입력SHA로 재사용한다. 이 한 검사기의 변경만으로 엔진을 반복하지 않는다.
- 기존 공개/인간/원어민/물리판정은 보존한다. 이 작업만 비저자GO 후 종료하고302전체,
  실제화면·EN문체·새package/본편HOLD는 유지한다. 규범은 일회성/기존 정본 적용이다.

## 2026-09-27 완료 증거

- source `59d4f790ecfd84f023c5796039264e4bfe72cdcf`, tree `0d6807438c512e5b3873c0a310d24e211612f0c1`; [비저자 보고](../agent_reviews/ORDER-308.json) 작업 한정 GO.
- 생산자↔독자: 정확 orthodox key+`월 칠십, 별도 관리비.`1회 ↔ 중국어 검사 입력 명시70만원. 타key·다른금액·단위·왼쪽prefix·중복 문구는 새치환0. 공유parser/실제원고·게임상태·경제 변경0.
- `STORY_DEMO_LOCALIZATION_OK locales=5 source_events=14 leaves=100 controller_ui=38 story_ui=82 target_ui=121`.
- `STORY_DEMO_LOCALIZATION_SELF_TEST_OK mutations=28 fixtures=10 boundaries=17 cases=55`. 기존8case 보존+실제 fullleaf6 positive/24negative/17경계. 공식2capture exit0/stderr0/1215입력 불변.
- 최초 localization FAIL2는 `305-localization-first`에 보존. 최종 `308-bridge-first`는 이전18capture의 raw36stream·17PASS/1FAIL 및 runtime3로그/1220핀을 대조한다. 다른 검사·원고·실행 입력 무변경으로 엔진/702self 재실행0.
- 최종23leaf 보존검사 PASS; accepted40299/공개GO/인간OPEN45 불변. 닫는 것: exact 오탐만, 일반 공유parser 전면수리나 전체품질/화면 승인 아님. 포기비용·장면 계층 해당 없음. 규범 승격: 없음(일회성/기존 정본 적용).
