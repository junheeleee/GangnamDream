# Gangnam Dream Decisions

## 2026-05-16 (Init)
- Use `/Users/junheelee/Documents/GitHub/GangnamDream` as the active development folder.
- Use GitHub Desktop for daily commit, branch, and push workflow.
- Use Godot 4.6 as the target engine version.
- Treat `docs/` as the source of truth for requirements and planning.

## 2026-05-16 (Prototype Improvement Pass)

- **엔딩 ID 기준**: `endings.json`의 `id` 필드를 정식 키로 확정. `GameState`에서 호출하는 ID는 반드시 `endings.json`과 일치해야 한다. 이 문서를 진실의 원천으로 삼는다.
- **65세 엔딩 분기**: 은퇴 시 자산 5억 이상은 `stable_success(B)`, 미만은 `ordinary_life(C)`로 분기. 단순 나이 도달보다 자산 결과를 중시하는 설계.
- **result_text 필수화**: 모든 이벤트 선택지에 `result_text`를 반드시 채운다. 빈 문자열은 품질 기준 미달로 간주.
- **투자 UI 설계**: 고정 10만원 매수 대신 3단계(10만/50만/100만) 선택. 전량 매도 대신 분할(25%/50%/전량) 선택. 리스크 표시는 점(●/○) 기호 사용.
- **모달 구조**: 스크롤 가능한 바디 + 고정 헤더(타이틀+X). 모달 내 콘텐츠가 많아져도 접근 가능하도록.
- **스탯 색상 경고 기준**: 건강/정신력 50↓ 노란색, 30↓ 빨간색. 스트레스 60↑ 노란색, 80↑ 빨간색. 게임 오버 조건(0)보다 충분히 앞서 경고.
- **PM 워크플로**: 대화에서 발생하는 모든 개발 요건은 Codex가 `docs/`에 직접 반영. 커밋 메시지도 세션 단위로 관리.

