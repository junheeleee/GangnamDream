# ORDER-368 — 중국어 정적 UI 수량 소비자

[x] 2026-09-28. 독립 work_unit 한정 GO, 필수 결함0. 본편/새package GO가 아니다.

- source `15e6cc10cef8d9b031f27ff07b4a15d1d89f8cf8`, tree `6564372cff0d2b0061f92fc504d849523ff2ea90`. [독립 보고](../agent_reviews/ORDER-368.json) SHA `a0968401f3ffc7e693f20e8f478cee48bd819033cabd2a914d084b9a4bc3a237`.
- 실제 legacy UI collector의 출처를 확인한 한 결과문만367의 full-game 해석에 연결했다. 임의 key-only validate_text와367 provenance-off는 원래 거절을 유지한다. 지역별 정상·잘못된 수량/소유자/추가량·출처·토큰·개행·문자 회귀를 확인했다. story-demo owner 실패 표시는 같은 UI 오류의 재인용이었으며 별개4개 누락으로 세지 않는다.
- 첫 named12와 첫 수리 뒤 named12는 각각9 PASS/3 FAIL였으며 두 원형을 보존했다. 전자는 수량 소비자/과거 기대값, 후자는 collector 자체 코드 보호 충돌이었다. 수리 뒤 clean 최종 source에서 named12 및 demo scope self16+86, first-start 기존14+새 코드 경계를 실제 통과했다. 이전366의7개 통과는 원래003b68c staged 도구 source의 증거를 구분하여 재사용했다. 최종source에서19개를 모두 다시 실행했다고 주장하지 않는다.
- 기존126판정/104보고·공개GO1·인간OPEN45·보류72 보존. 원어민·인간·물리패드·새 렌더/입력은 미관측이며 1장 debt8/blocked3/W25..48 gap24·5장·본편/새package HOLD를 유지한다.
- 스킬의 직접저작·파일 소유 분리·독립 검수·표적검증을 적용했다. 이번 범위·전이·검증은 일회성. 상시 규칙 승격0. 외부출시·스토어·지출·법률 인증0.

## 최초 선언 원문 보존

# Active Queue Spec: ORDER-368

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-368 [P0·검증 수리] 중국어 정적 UI 소비자에도 네 답의 출처를 결속한다

**[~] 2026-09-28 Codex 착수.** 365 named12의 실제 실패에서 파생했다.
367의 full-game 검사 수리는 통과했으나 `zh_translation_audit.static_ui_coverage`
직접 소비자가 같은 수량 해석에 연결되지 않아 양지역의 정상4답을 거절한다.
story-demo owner 문구는 동일 오류의 재인용이며 별도 누락4건이 아니다.

## 깊이 3문·정확한 소유

1. 손실: UI 사전에 들어간 정확한4답 번역을 기존 중국어 감사가 사용할 수 없다.
2. 장기 상태: 검사 연결만 바뀌며 결과·문항·채용·효과·본문은 그대로다.
3. 경쟁: 실제 수집된 static UI 출처와 임의 key-only 문자열을 구분한다.

- `/root/screen_path_probe`: `tools/zh_translation_audit.py` 한 파일. 실제 legacy
  collector entry에 묶인 작은 어댑터와 같은 파일의 표적 self-test를 추가한다.
- root: 큐2·CLAUDE 현재행·WORK_LOG·생성STATUS·이 사양→archive,
  agent_review_decisions 새1행·agent_reviews/ORDER-368.json 및 private order368 증거.
- `/root/r3_route_probe`: 비저자 독립 검수, private order368 review만 소유.

367의 정확 leaf 해석을 재사용하되 `validate_text`의 일반 key-only 호출을
자동 허용하지 않는다. 실제 inventory의 한국어·위치·정체성을 확인한 static
소비자만 full-game leaf 경로로 연결한다. 다른 문장·그룹·출처는 원래 진단을
유지한다. 기존 corpus/검사·원문·번역·원장·인간/공개 증거·게임코드는 비소유다.

## 표적 검증·완료

CN/TW 실제값과 동등수사, 다른 수량/소유자/단위/추가량·토큰·개행·지역문자,
collector/key/source/locale 이탈, generic validate_text 원형 실패를 검사한다.
실제 static_ui_coverage 연결을 확인하고 기존367의97 subtest와 전체265를
완화하지 않는다. 실제 named 실패 원본을 보존한 뒤 중국어 self-test를 다시
실행한다. 다른 demo source2항목 실패는 별도 원인·사양으로 처리한다.
전체 UI·렌더·원어민·인간·물리패드·제품/출시 GO는 아니다. 기존 HOLD 유지.
이 leaf·한 파일·검증 연결은 **일회성**, 상시 승격0이다.
