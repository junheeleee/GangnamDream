# Active Queue Spec: ORDER-363

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [ ] ORDER-363 [P1·검증] 콘텐츠 검토 기록의 정확한 후속값을 1장 역사 비교에 연결한다

2026-09-28 Codex 발행. 361의 실제 Chapter1 normal/self 실패를 분리한 후속이다.
362의 본문 재검토와 지문 갱신 뒤 착수한다. 구현·pin 변경·검사 재실행0.

## 깊이 3문

1. 왜 지금인가: 검토된 현재 콘텐츠 기록 때문에 보존된 1장 인과 검사가 중단된다.
2. 무엇을 보존하는가: 원형101/151~156 pin·622사례·361 추가4반례·원장/부채,
   현재 inventory·공개 package·인간 판정. 역사 비교만 정확한 후속값에 연결한다.
3. 무엇과 경쟁하는가: 360만 잇고362에서 다시 깨뜨리는 반복을 피한다.
   새 원고·번역·게임 로직·등급 판단은 범위 밖이다.

## 실제 실패와 증거

- `.git/full-game-localization/order361-first-11.json` SHA
  `c715bcc36ef7cd6619e14945bd4d555085650e02cff95a9dc3023d96fe632a34`:
  normal exit1,37.689초. `order361-first-12.json` SHA
  `6a7f02a8a0c60bec5ae8e61ce74b308ff69b37d1b5458dc42180c116faec428c`:
  self exit1,37.028초. 둘 다 stderr에 inventory snapshot mismatch를 기록하며
  self는 fixture 준비에서 중단, 기존622+추가4사례 완료 주장은0이다.
- Chapter1 기대 체인은156의 inventory raw SHA
  `eaa588e0401af69a9079aa2d11f105e4e57c6780e5030c517320a34a5f251764`에서 끝난다.
  360 제품 `c94cd3ae19f22a015b3bd6b6e25afb17a8561242`는 정확6축의
  `candidate_scan.expected_content_sha256`만 바꿔 현재 raw SHA
  `2ff675845e1017764eb67c1c9c330ecd3b3507fa0b40535757b00bba073a88b0`가 됐다.
  351 제품과361은 이 파일을 바꾸지 않았다. 350/351의 LIVE·KOEN history 밖이다.
- 362의 실제 제품·직접 부모·정확 raw 전이는 완료 후 관측해 봉인한다.
  아직 없는 commit/hash를 발명하거나 미리 승인하지 않는다.

## 착수 후 소유할 파일 — 3도구, 1배치

- `tools/chapter1_core_loop_v2_causal_ledger_check.py`: inventory 한 경로만의
  exact observation bridge와 표적 반례. immutable360·362 부모/제품/Git blob을
  확인하고 검토된 지문 필드만 역변환했을 때 전체 이전 raw와 같아야 한다.
  현재 raw/관측 hash를 먼저 결속하고 역사 비교에만 사용한다. 새 공용 모듈은 만들지 않는다.
- `tools/audit_scope.json`, `tools/audit.sh`: 필요하면 해당 명시 차선만 추가.
  기존 검사·원형 모듈·pin·corpus의 삭제/면제/완화0.
- 마감: 이 사양·351/361 후속 상태·큐2·WORK_LOG·CLAUDE 현재행·생성 STATUS,
  비저자 보고와 판정 append. 착수 때 최신 WORK_UNIT/프로필과 파일 소유자를
  확인하고 `[~]` 선언 커밋을 구현 전에 분리한다.
- 제품·번역·현재 inventory·생성 콘텐츠 표·인간 원장·공개 pin은 비소유다.

## 완료 조건

- rollback/neighbor·공백/사실·공개pin/다른 경로/관측hash 불결속/누락·위조Git을
  거부하고 기존 pin·원장·부채·622사례와361 추가4사례를 보존한다.
- Chapter1 normal/self와 정확 소비자 표적 검사를 실제 실행한다. 최초 두 실패,
  새 실행의 전후 source census·marker/오류로그·사례 수를 각각 보존한다.
  361의 다른 통과 검사는 바뀐 호출 경계가 요구할 때만 재실행한다.
- 비저자가 정확 clean source와 전수 전이·반례·실행 증거를 읽고 판정한다.
  그 뒤351/361 후속 판정은 별도 보고/원장 append로 결속한다.
- 일회성 작업 지시이며 기존 WORK_UNIT·I18N·큐 규범을 적용한다.
  자동 계약은 재미·문체·원어민/인간/물리 관측이 아니다. 본편/새package HOLD,
  기존 공개GO·인간OPEN·외부 출시/스토어/지출/법률 인증 권한 경계를 유지한다.
