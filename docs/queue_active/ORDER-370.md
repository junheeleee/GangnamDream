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
