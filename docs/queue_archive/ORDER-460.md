# ORDER-460 — 코인 교정 번역의 현재 파일 소비자 연결

#### [x] ORDER-460 [P1·수리 의존] 준비 언어 사건3파일의 exact current admission

**[~] 착수 — 2026-10-05.** 459 연결 검토 중 기존365 소비자는 커피 사건3파일만
현재 증명으로 읽고 코인 사건3파일은 이전 원장으로 넘긴다는 누락을 확인했다.
459의 원문·receipt 전이 증명에 의존하는 마지막 소비자만 별도 선언한다.

## 소유와 경계

- root: `tools/order365_ui_receipt_compat.py`의 coin adapter import, fresh proof의
  현재 raw 결속, `source_errors`의 exact JA/CN/TW 사건3경로 분기와
  기존47경로를 보존한 LIVE_PATHS exact3추가(50경로)만 수정한다.
- receipt_tests392: 이미459에서 소유한 `tools/coin_call_receipt_history_self_test.py`에
  이 소비자 분기의 제출 raw 불일치·누락·다른 경로 위임 반례를 함께 검증한다.
- root: `tools/audit_scope.json`의 같은 focused 등록에 소비자 경로를 연결하며,
  큐/활성/보관·CLAUDE·WORK_LOG·생성STATUS·판정원장을 갱신한다.
- independent392: `docs/agent_reviews/ORDER-460.json`만 추가 독립 판정한다.
- 459의 API가 반환하는 고정된 현재 제품 raw와 actual HEAD를 사용한다. 기존
  과거 원문/원장·header·collector·기타 LIVE_PATHS 위임·제품/런타임 수정0이다.
  상위 성공 캐시, 경로 wildcard, 과거 pin 재발급, monkeypatch는 추가하지 않는다.

## 검증과 완료

459와 같은 focused 실행 및 기본 full-body1회가 이 단일 연결도 검증한다.
두 오더라는 이유로 같은 검사나 역사 self-test를 두 번 실행하지 않는다.
제출된3파일이 exact current와 다르면 거부하고 다른 경로는 기존 증명을 따른다.
458의 선행 화면은 제품 bytes 불변 대조 뒤 재사용하며 새 실제 플레이를 뜻하지 않는다.
비저자 한정 GO 뒤 별도 마감한다. 인간/원어민/패드·공개 이력·전체 본편 HOLD 유지.

첫 focused는136개 확인 뒤 `actual current47 path census`에서 실패했다.
실제47경로에 코인3파일이 없어서 새 분기 앞의 미등록 검사가 거부하는 결함이다.
`.git/chapter5-replay/order459-focused-first.log`를 보존하며, 같은 파일/정확3범위에서
목록을 연결한다. 기존47경로를 지우거나 임의 개수 하한으로 검사하지 않는다.

이 정확한 연결과 실행 계획은 **일회성**이며 새로운 규범이나 출시 GO가 아니다.

## 완료 — 2026-10-05

- source `be89b7f86cc40d07145610353fab5d427c920821`, tree
  `ccf14176b3cc7015bfd0d8f8cd33cc462a75010f`: 기존47순서+코인3=정확50.
  제출 raw 불일치·누락·unknown·비소유 위임 반례를 공동 focused151에서 확인했다.
  합성 active-context 반례를 fresh 전체원장 실행으로 세지 않는다.
- 실제 기본 full-body1회는688.315초/exit0/빈 stderr로 현재50경로 수용을 통과했다.
  공동 결과 SHA `a7f694c3aa94f6b0d93de41b1284fe1d329968ee3869076d253d6896692592ec`.
  459와 같은 실행을 공유하며 두 번 실행했다고 세지 않는다. 입력16/player34/seed2+W195 불변.
- [독립 보고](../agent_reviews/ORDER-460.json) SHA
  `ef601481846c097bfc51bb80ff36083f49bae2bc3fd710b7b6811cba1f525b75`, 한정GO.
  첫136FAIL/사전검수 누락과 기존 역사 self-test 미실행을 보존한다.
  제품/인간/공개 이력 변화0·자연457/본편/새package/출시HOLD다.
- 규범 판정: 정확3추가·소유·공동 실행은 일회성. 기존 WORK_UNIT 적용, 새 정본 승격0.
