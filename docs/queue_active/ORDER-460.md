# ORDER-460 — 코인 교정 번역의 현재 파일 소비자 연결

#### [~] ORDER-460 [P1·수리 의존] 준비 언어 사건3파일의 exact current admission

**[~] 착수 — 2026-10-05.** 459 연결 검토 중 기존365 소비자는 커피 사건3파일만
현재 증명으로 읽고 코인 사건3파일은 이전 원장으로 넘긴다는 누락을 확인했다.
459의 원문·receipt 전이 증명에 의존하는 마지막 소비자만 별도 선언한다.

## 소유와 경계

- root: `tools/order365_ui_receipt_compat.py`의 coin adapter import, fresh proof의
  현재 raw 결속, `source_errors`의 exact JA/CN/TW 사건3경로 분기만 수정한다.
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

이 정확한 연결과 실행 계획은 **일회성**이며 새로운 규범이나 출시 GO가 아니다.
