# 누적 인생 칭호 일본어 회차 수량 오탐

#### [~] ORDER-249 인생 회차 수량 검사 정합

[~] 착수 — 2026-09-12, Codex. 기준 clean HEAD
`4d4f418a7edcd55539e40c703bb4f8f60b1bc605`. 이번248의 첫66 L1 중 JA4 오탐을
별도 원인1/좁은 검사 수리로 다룬다. 최초36432153의 전체66 결과는 보존한다.
247 exact07ef 원격 실행과 독립적으로 로컬 선언·수리를 진행하되 원격push는 보류한다.

## 원인과 경계

KO ‘다섯 번/열 번’의 인생 name/desc4에서 Arabic 숫자 스트림은 빈값이고,
정확한 JA5度/10度는5/10이므로 숫자 불일치가 발생한다. 번역·원문·획득 조건은
변경하지 않는다. 정확한UI source4·전체leaf ID·JA로 제한한 numeric-only adapter를
추가한다. 회차를 년·인원으로 바꾸거나 부호·추가수량·숫자 위치를 바꾸면 거부한다.
다른source/ID/locale/OFF는 기존 진단 원형을 유지한다. 오류 문자열 삭제나
전체 validate 조기 성공·generic 수사 파서 확대는 하지 않는다.

깊이3문: 없으면 정확한JA4의 공식 수용이 막힌다. 선택·24주·1년/5년 상태 변화0.
일반 수사 파서 확대와 경쟁하므로 실제4source에만 한정한다. 원어민·화면·인간
플레이·본편GO가 아닌 수량 검사의 동일 의미 오탐 한 원인만 닫는다.

## 파일 소유권·검증

- Plato: `tools/full_game_localization.py`의 새 exact helper와 JA 숫자 비교 hook.
- Rawls: `tools/full_game_localization_self_test.py`의 신규 frozen 회귀1. 기존260원형 유지.
- ROOT: 사전 고정 모집단 baseline/post 실제 실행과 최종248 명시11 재사용, 적용/커밋.
- Poincare: 비저자 원문·전량 코드·대조군·최종 실행 증거 독립 검수.
- ROOT 운영: CLAUDE, 큐2, 본 active/archive249, WORK_LOG, STATUS,
  localization backlog, agent_review_decisions와 agent_reviews/ORDER-249.json.

구현 전 private 고정 모집단을 봉인하고 실제4·합당한표기·수량/단위/역할 변조·OFF의
첫 결과를 저장한다. 정상base가 실패한 mutant의 거부를 유효 통과로 세지 않는다.
수리 뒤 같은 모집단을 전량 검증하고248의 같은66 L1을 다시 검사한다. 전체 수용
회귀와 공통 명시11은 같은 최종 후보에 한 번만 실행하여 두 단위에 범위를 구분해
결속한다. 신규 테스트 하나의 nested 대조를 전체 suite 수와 섞지 않는다.

248의 engine 입력19는 이 수리로 바뀌지 않으므로 raw 동일하면 중복 실행하지 않는다.
JA pipeline/ZH/MP/게임play/UI/조건·저장·인간원장/프로젝트/audit.sh 직접 변경0.
공개GO1·인간OPEN45·본편HOLD. 일회성 작업 지시이며 새 규범 없음.

## 첫 대조와 수리 관측

사전33(정상6/변조19/OFF8)23549B/5fb3f843을 구현 전 봉인했다. 실제 baseline
f45d7b17에서 helper는33모두 부재, full 정상은五표기1만PASS/연결된 유효negative0이다.
원래4오탐·잘못된 한자값/누락이 통과하던 사실과 OFF8·돈/token 진단을 보존했다.

새 helper43줄/hook4줄만 추가(90b2f806), 새 unittest1만 추가(0dc399b9).
각 역제거→이전 fulltool c294603d/fullself80c5aaf0 전체 raw exact, 기존260 보존이다.
ROOT가 비저자로 새 코드·33literal 전량을 읽은 뒤 최초 targeted unittest1을 실행했다.
같은33 전량PASS/정상base를 가진negative19/OFF8exact, inner6/outer1193 전후exact,
0.483초/exit0이며07d01d29에 원형 보존했다. 전체261 실행이라고 세지 않는다.
이후248 같은66 L1도 오류0(fbfcef0c), 번역·source manifest·engine19는 그대로다.
Poincare 최종 독립검수·전체수용 회귀·공통11은 남아 있다.
