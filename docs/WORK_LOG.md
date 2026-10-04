# WORK_LOG.md — 강남드림 작업 기록

이전 원문 전체는 [홀덤 비동기 수리 전 기록](history/WORK_LOG_2026-10-04_pre_order438.md)에 바이트 그대로 보존했다.

## 2026-10-04 — 홀덤 중복 행동·이전 타이머 수리 착수 (438)

- 제품 단독 `aa21f0b`에서 transient busy·generation을 추가했다. 타이머가 같은 세대일 때만 다음 행동을 잇고, RESULT/close/open/새 손 경계는 이전 callback을 무효화한다. 기존61 UiCall 전체 tuple·행 좌표와 금액/승패 산식은 보존했다.
- history EOF4전이·24객체/19실제 manifest·신규 focused를 별도 저작했다. 기존 proof·focused·번역 원문은 그대로다. 새 실제 시간창 회귀와10검증+조회1의 실행·최종 판정은 아직 대기이며, 사전 소스 읽기와 AST 확인을 실제 PASS로 세지 않는다.
- 437 실제 trace와 소스에서 AI 끝 대기 중 조기 입력 및 퇴장/재진입 뒤 stale continuation을 확인했다. busy+generation으로 기존 선택의 단일 실행을 보존하며 정산 산식은 바꾸지 않는다.
- root 제품/append/normal, claude history/newfocused, receipt private runtime/scope, independent 비저자 검수로 분리한다. KO 두 실제 시간창과 정산/재진입·새 busy 경계를 표적으로 삼는다. 아직438실행/GO0.
- 437 sourcecb648d9는 독립GO·제품/검사/마감main push 완료. [보고](agent_reviews/ORDER-437.json), [사양](queue_archive/ORDER-437.md). 과거198판정176보고·player34·공개GO1·인간OPEN45·본편HOLD 보존.
- 부팅 문서 예산 때문에 긴 이전 WORK_LOG는 새 후보 선언에서 손실 없이 이동했다. 품질 판정만 담는 metadata 마감과 이 새 이력 이동을 분리했다.
