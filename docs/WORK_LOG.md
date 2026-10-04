# WORK_LOG.md — 강남드림 작업 기록

이전 원문 전체는 [홀덤 비동기 수리 전 기록](history/WORK_LOG_2026-10-04_pre_order438.md)에 바이트 그대로 보존했다.

## 2026-10-04 — 홀덤 연속 입력·퇴장 뒤 타이머의 실제 회귀 통과 (438)

- 제품 `aa21f0b`와 신규 검사 `3c242a5`를 main에 커밋·푸시했다. 실제 player 0.3초/AI 0.6초 창의 추가 Enter를 막고, RESULT·Close·재진입 뒤 옛 callback이 새 판을 바꾸지 않는 것을 확인했다.
- 같은 source3c242a5에서 KO 실제2PNG·26raw/13tap·첫손3·테이블행동3·정산2·Close1과 별도 prepared token1 PASS. 두 정산의 현금−10k/mental−5·Meta, 실제 Main 회수의 AP−1·행동/장소/로그 효과를 확인했다. 실제 플레이어 파일34개 불변.
- 첫 회귀는 Main이 AP 버튼을 재생성한 뒤 옛 absolute focus path로 복원하려다 FAIL했다. 실패138파일은 원문 보존하고, 새438 helper만 실제 Main 소유의 유일한 name/index/action/fn/pressure 일치 버튼을 찾아 복원하도록 고쳤다. 실제 raw 경로/ID 변화는 지우지 않았으며, 재실행 typed3그룹 복원 PASS다. 첫 FAIL을 PASS로 바꾸지 않았다.
- fresh10검증+차선조회1 PASS(389.657초), 신규 focused50·과거case0. accepted41656/b209·JA3044/CN/TW1733 불변. 434의 서사4종은 참조/NOT_RUN이며 완료 회귀·전체감사·240주·성능A/B 재실행0.
- 성공 runtime SHA `457e89d58cd2b5c8ff914fae59a297cde7c0a864e015540451b968f84017812c`, normal SHA `9cdd34c5ab12b25d478bfa2a72104395588ce40225ad003d7ff99949d28237c2`. [독립 최종 보고](agent_reviews/ORDER-438.json)로 source3c242a5·이 범위 GO, 199판정/177보고. 지시는 일회성이다. 저대비 카드·직접 영어/후속 번역·원어민/인간/물리패드·본편/새package HOLD는 그대로다. CLAUDE 현재 상태는 다음 선언에서 갱신해 품질 판정 metadata 마감과 분리한다.

## 2026-10-04 — 홀덤 중복 행동·이전 타이머 수리 착수 (438)

- 제품 단독 `aa21f0b`에서 transient busy·generation을 추가했다. 타이머가 같은 세대일 때만 다음 행동을 잇고, RESULT/close/open/새 손 경계는 이전 callback을 무효화한다. 기존61 UiCall 전체 tuple·행 좌표와 금액/승패 산식은 보존했다.
- history EOF4전이·24객체/19실제 manifest·신규 focused를 별도 저작했다. 기존 proof·focused·번역 원문은 그대로다. 새 실제 시간창 회귀와10검증+조회1의 실행·최종 판정은 아직 대기이며, 사전 소스 읽기와 AST 확인을 실제 PASS로 세지 않는다.
- 437 실제 trace와 소스에서 AI 끝 대기 중 조기 입력 및 퇴장/재진입 뒤 stale continuation을 확인했다. busy+generation으로 기존 선택의 단일 실행을 보존하며 정산 산식은 바꾸지 않는다.
- root 제품/append/normal, claude history/newfocused, receipt private runtime/scope, independent 비저자 검수로 분리한다. KO 두 실제 시간창과 정산/재진입·새 busy 경계를 표적으로 삼는다. 아직438실행/GO0.
- 437 sourcecb648d9는 독립GO·제품/검사/마감main push 완료. [보고](agent_reviews/ORDER-437.json), [사양](queue_archive/ORDER-437.md). 과거198판정176보고·player34·공개GO1·인간OPEN45·본편HOLD 보존.
- 부팅 문서 예산 때문에 긴 이전 WORK_LOG는 새 후보 선언에서 손실 없이 이동했다. 품질 판정만 담는 metadata 마감과 이 새 이력 이동을 분리했다.
