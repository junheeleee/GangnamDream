# ORDER-370 — UI 수집기의 정확한 코드 후속 보호

[x] 2026-09-28. 독립 work_unit 한정 GO, 필수 결함0. 본편/새package GO가 아니다.

- source `15e6cc10cef8d9b031f27ff07b4a15d1d89f8cf8`, tree `6564372cff0d2b0061f92fc504d849523ff2ea90`. [독립 보고](../agent_reviews/ORDER-370.json) SHA `5142232b9bb2a82c8dcad626d8b584d6136772a1dd3f19c6e571bd92e2855bc6`.
- 369 collect_demo 연결이 원래274의 전체 코드 봉인을 위반하여 UI calls0/stats{}가 된 결함을 수리했다. 원래274 block/핀과 기존14 corpus를 보존하고 정확369 hunk 및 봉인된370 appendix를 역제거하여 immutable 전후 Git 전체 바이트를 매번 대조한다. 과거 비교기 안의 scoped read만 바꾸고 현재 관측에는 실제raw를 반환한다. 누락·중복·변조·rollback·Git누락 및 예외 뒤 read복원을 별도 검증했다. I18N 정본에 self-seal/실제 collector 사전 확인 주의 한 문장을 승격했다.
- 첫 named12와 첫 수리 뒤 named12는 각각9 PASS/3 FAIL였으며 두 원형을 보존했다. 전자는 수량 소비자/과거 기대값, 후자는 collector 자체 코드 보호 충돌이었다. 수리 뒤 clean 최종 source에서 named12 및 demo scope self16+86, first-start 기존14+새 코드 경계를 실제 통과했다. 이전366의7개 통과는 원래003b68c staged 도구 source의 증거를 구분하여 재사용했다. 최종source에서19개를 모두 다시 실행했다고 주장하지 않는다.
- 기존126판정/104보고·공개GO1·인간OPEN45·보류72 보존. 원어민·인간·물리패드·새 렌더/입력은 미관측이며 1장 debt8/blocked3/W25..48 gap24·5장·본편/새package HOLD를 유지한다.
- 스킬의 직접저작·파일 소유 분리·독립 검수·표적검증을 적용했다. 이번 범위·전이·검증은 일회성. I18N 재발방지 주의1문장만 상시 승격. 외부출시·스토어·지출·법률 인증0.

## 최초 선언 원문 보존

# Active Queue Spec: ORDER-370

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-370 [P0·검증 수리] 원문 기대값 연결과 UI 수집기의 역사 보호를 함께 유지한다

**[~] 2026-09-28 Codex 착수.** 369 후 실제 named 재검에서 JA self StopIteration,
JA/ZH UI stats KeyError가 발생했다. 직전 원문 지문 오류는 해소됐지만
`collect_demo`의3줄 추가가 기존274의 전체 pipeline raw 보호에 걸려
`whole collector inverse differs`→calls0/stats{}가 됐다. import/cache 오염이
아님을 helper 호출 전후 실제 진단으로 확인했다. 실패2차 원본은 보존한다.

## 깊이 3문·소유

1. 손실: 정상 원문 수리와 UI 수집이 공존하지 못하여 언어 감사가 중단된다.
2. 장기 상태: 검사 도구의 정확한 후속 코드만 인정하며 제품·문구·상태는 불변이다.
3. 경쟁: 승인된369 hunk와 도구의 임의 편집·rollback을 구분한다.

- `/root/compat357`: `tools/ja_translation_pipeline.py` 새 명시 후속 wrapper,
  `tools/first_start_notice_self_test.py` 현재-code admission 연결과 새 표적 테스트.
  기존274 block/핀·기존14 corpus·그 이전 전체 본문은 원형 보존한다.
- root: 위 첫-start 테스트 파일의 전용 실행/증거, 큐2·이 사양→archive·CLAUDE
  현재행·WORK_LOG·생성STATUS·새판정1행·agent_reviews/ORDER-370.json.
  `docs/I18N_INFRASTRUCTURE.md`에 collector 파일의 self-seal 사전 확인 주의1문장.
- `/root/r3_route_probe`: 비저자 독립 검수, private order370 리뷰만 소유한다.

정확369 collect_demo hunk와 새 wrapper만 역제거하면 원형274 pipeline whole raw
0cc156…이어야 한다. Git 전후 실물·전체 바이트·hunk/appendix1회·source caller
출처를 결속하고 원래 비교기에는 scoped-read 안에서만 과거code를 전달한다.
현재 관측 결과에는 실제 코드/raw를 유지하며 과거 파일을 현재인 것처럼 반환하지 않는다.
오류를 빈목록/0으로 덮거나 원핀을 옮기지 않는다. 원형14 음성·그 이전 corpus와
제품·번역·인간·공개 증거는 비소유다. 재귀/스코프 밖 read 오염을 방지한다.

## 검증

실제 collector가 UI 목록·stats를 복구하고 원래 수량/출처 검사를 그대로 쓰는지
확인한다. 새 hunk/appendix 누락·중복·변조·외부함수변조·옛rollback·Git누락,
정상/예외 종료 뒤 read복원, 기존14를 모두 검증한다. 최초/수정후 named 실패를
보존하고 영향받은 JAself/ZHself/JAUI 및 전체265·369demo self를 최종source에서
재검한다. 변경하지 않은 역사1955/689·전체shell·엔진은 반복하지 않는다.
코드 보호 수리일 뿐 렌더/원어민/인간/물리·본편/출시 GO는 아니다. HOLD 유지.
이 exact전이·파일·검증은 **일회성**, 새 주의문만 I18N 정본에 승격한다.
