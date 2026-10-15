# ORDER-686 — 이미 대체된 P-19의 만료 문서 실패 정리

#### [x] ORDER-686 [C3 문서] 대체 근거·원문 보존·표적 통과 — 2026-10-16

## 실제 실패·판정

685 월별 마감의 표적 문서 검사에서 context_manifest_check가 P-19의
22일/상한21일로 실제 exit1이었다. 다른 문서4/EN누출/diff는 통과했다.
main d29/run38754678031 static 성공·Godot 진행/실패0이며 진행 중은 녹색이 아니다.
새 월을 열지 않고 이 실패부터 고친다. KNOWN_FAILURES CI 예외는0/만료0다.

P-19 원안은 역사 self-test3개 집계 제거지만 최신 사용자 결정 2026-10-08과
완료487은 제품 동작이 없는 역사 층만 삭제하고 chapter1 causal self-test의
상태·저장 반례는 고쳐 유지했다. 원안을 통째로 실행하거나 테스트를 끄지 않는다.
원문을 POST_LAUNCH_NOTES에 손실 없이 보존하고 닫힌 제안에 대체 근거를 남긴다.
출시 후 새 구현 오더로 자동 재개하지 않는다. 사용자 재서명·정본 규칙 변경0.

## exact 파일 소유

root: docs/PROPOSALS.md, docs/POST_LAUNCH_NOTES.md, docs/CODEX_QUEUE.md,
docs/CODEX_QUEUE_L3_PENDING.md의 순번만 기계 정렬,
docs/queue_active/ORDER-686.md 및 완료 archive, docs/WORK_LOG.md, CLAUDE.md 현재행.
큐는 기존 행/상태를 보존하고 연속1부터 순번만 맞춘다. 초기 임시0행은
실제 queue parser가 거부했으므로 검사 약화 없이 이 선언 범위에서 고친다.
비저자: 위 문서/기존487/현행 검사 읽기와 메시지 검수만. 제품/도구/예외/
context_manifest·검사 날짜/상한/STATUS·저장/설정/project·공개/Human 변경0.

## 완료 기준·순서

685 한달 마감과 이 선언을 로컬 커밋한 뒤 구현한다. 다음 원격 동기화는
686 수리/표적 통과 후 두 커밋을 함께 push하여 불필요한 빨강 중간 HEAD를 피한다.
원P-19 바이트 대조·닫힌 근거의 독립 읽기 GO·기존 영향 문서 검사/diff 통과,
제품/검사 diff0을 확인하고 닫는다. 전체audit/240주·앱 재실행/새tool0.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
승격0·기존 소유 규칙 적용이며 이 실행 절차는 일회성이다.

## 실제 완료

P-19를 후속 승인·완료487로 대체된 닫힌 제안으로 옮겼다. 원안 세 검사 전부
삭제 승인이 아님을 명시했고, 당시 원문1947B/SHA256
5925c26749cbc5339a421882a2226afdc72eea2bf65182d8836d7c4d373ef99c를
POST_LAUNCH_NOTES에 바이트 그대로 보존했다. root와 비저자 a1_data_content가
독립 추출·현재 실행/분류3행·승인/487 마감을 전수 읽고 같은 핀·GO를 확인했다.
현행 causal self-test 실행·집계는 유지, 코드/검사/예외/날짜/상한 수정0다.

첫 재검사에서는 root의 큐0행이 연속 순번 계약을 깨뜨려 queue/dashboard/
agent self-test가 실제 실패했다. L3 순번 소유를 먼저 추가하고 기존 행/상태는
유지한 채 연속1부터 기계 정렬했다. 재실행은 문서6 actual exit0:
context open_proposals0·queue78/76·dashboard stale 비차단·human 후보재build0·
queue fixture25/4·agent cases290/human_evidence_unchanged=true다.
마감의 행 제거 후 context/queue/diff를 재확인한다. 앞선 실패를 PASS로 바꾸지 않는다.
main CI는 아직 진행 중/실패0이지 녹색 확정이 아니다. 다음은 원W97/M25이며
완료월 반복·새 엔진/전체audit/240주·제품/원문/번역/저장 변경0다.
