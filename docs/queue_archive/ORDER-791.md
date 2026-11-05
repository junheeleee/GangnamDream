# ORDER-791 — 본편 칭호·엔딩 인용부호

#### [x] ORDER-791 · 본편 칭호·엔딩 인용부호 — 2026-11-06

부모157/C5. 착수 — `scenes/MainGame.gd::_quote_ui`의 JA/CN/TW 구두점만.
초상 아래 칭호와 본편 엔딩 요약은 기존 연말 기록과 같은 언어별 인용부호를 쓴다.
KO/EN/기타 언어·안쪽 문자열·번역 사전·공개 데모·저장·조건 비소유. 신규 키0.

제품 `e83dd36ae9e90a2af6a08fc5ae3327c757c39386` 정상 push.
JA/TW 「…」·CN “…”를 기존 두 호출에 적용하고 원래 fallback을 보존했다.
정확한 소스 역복원·데모·EN·direct branch delta 통과,
[독립 source GO](../agent_reviews/order791-cjk-ui-quotes.md).
원래 direct 검사 실패3은 baseline3/new0로 분리 보존했다. 선택목록86은 실행 아님.
제품 CI42054688891 대기 관측, 전체 성공 미관측. 실제 화면·엔진·원어민 미관찰.
자동 검사는 계약 증거이며 사람 품질·출시 판정이 아니다. 이 범위는 일회성이다.
