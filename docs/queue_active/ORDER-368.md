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
