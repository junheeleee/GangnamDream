# Gangnam Dream Work Log

> 이전 WORK·선언·검증 원문은 [287 보존본](queue_archive/ORDER-287.md)에 있다.

## 2026-09-26 (Codex — 블랙잭 분할 더블의 돈·손익 수리)

- [288](queue_archive/ORDER-288.md): 분할 패에 추가로 건 돈이 정산에서 빠지던 결함을 수리했다. 기존 배율을 유지하면서 승리·무승부 환급과 손익 기록에 실제 원금이 반영된다. source `3f3c502`, 비저자 작업 한정 GO.
- 실제 Table 행동으로 동일24사례×KO/EN=48을 수정 전후 비교했다. 전48실행/296assert 실패(누적 오차 포함), 후48PASS·exit0·engine errors0. 첫 검사 문법 FAIL도 보존했다. 사용자 파일43·입력12 전후 불변, 새 격리 저장 공간만 사용했다.
- 정적12 중10PASS. 기존 `.git` 과거 증거33개를 제품으로 세는 feature-liveness FAIL은 숨기거나 baseline을 넓히지 않았다. 새 큐0행의 순번 FAIL은 완료행을 제거해 복원했고 종료 context·queue·큐 자체검사·판정원장·현황5종 PASS. 전체 감사·실제 화면·물리 입력 재검증 주장은 없다.
- 원격에 먼저 들어온 Claude의 데모 Windows/Linux 빌더·영어 감사 수리를 보존해 병합했다. 그 빌더의 실제 export·실기 실행이나 기존 CI 잔여3건을 이번 작업이 인증/수리한 것은 아니다.
- 공개GO1·인간OPEN45·본편HOLD·번역 수용/보류 원장은 불변. 다음 정산 후보는 바카라 수수료 중복 차감·타이 원금·반복 종료이며, 읽기전용 코드 대조만 마쳤다. 새 범위를 선언한 뒤 별도 재현·수리한다.

## 2026-09-26 (Claude — Windows·Linux 스토리 데모 빌더)

- 사용자 지시("너가 일을해")로 출시 막힘 1순위를 골랐다. 공개 체험판 빌더가 macOS뿐이라 Steam 제출용 Windows·Linux 패키지를 만들 수 없었다.
- `tools/build_story_demo_desktop.sh --platform windows|linux`: macOS 차선과 같은 fixed-source staging·project 재작성, 제품 `Windows`/`Linux / Steam Deck` preset에서 파생, import·네 언어 target·font·i18n gate, export, 호스트 OS가 같으면 다섯 locale native smoke, zip·manifest(`user_go=not_inherited`). 정본 값은 macOS 빌더에서 읽는다.
- 검증: `bash -n`, 가짜 Godot dry-run으로 linux(native smoke 경로 포함)·windows 통과, 음성 5건(HEAD source의 runtime scope 변경·build id·platform·SCRIPT ERROR·디스플레이 없음→xvfb) 확인. 가짜 산출물은 삭제했다. 실제 Godot export·실기 실행은 미관찰이다.
- `audit_scope.json`의 build identity 검사 경로에 등록, `BUILD_PIPELINE.md` 표·절, `NEXTFEST_CHECKLIST.md` 막힘 항목 갱신.

## 2026-09-24 (Claude — main CI 실패 5건 중 2건 수리)

- `main` 685e10f의 CI 실패 5건을 재현하고 bisect로 원인을 찾았다. STATUS_DOC는 9b091a2 이후 현황 문서 미갱신, EN_HANGUL는 29d46d7(ORDER-267)이 새 게임 로그 `ui_format` 2건을 `ja_translation_pipeline.py`의 `NEW_RUN_LOG_CALLS`에만 등록해 영어 한글 감사가 모른 결과다.
- 수리: `english_hangul_audit.py`가 `NEW_RUN_LOG_CALLS`의 format 행을 AST로 읽어 기대 집합에 더한다(등록 정본 하나 유지, manifest 해시·개수 불변). self-test 12건. `STATUS.md` 재생성.
- 대안 기각: manifest `candidate_registry`에 2행 추가는 JA/ZH 감사 32건 연쇄 실패(개수·해시·provenance)를 만들어 되돌렸다.
- 미수리 3건: CHAPTER1_CAUSAL_LEDGER self-test(CI 범위상 29d46d7 추정), CI_LOCALIZATION·META_TITLE history(f231658이 해시 고정 대상 `ja/zh_translation_audit.py`·`full_game_localization.py`를 successor 등록 없이 수정). 처리 방식은 사용자 판단 대기.

## 2026-09-24 (Claude — 체험판 외부 테스트·Steam 제출 점검 보강)

- 사용자 요청으로 체험판 출시 준비 상태를 점검했다. 새 문서를 만들지 않고 기존 정본 두 곳만 보강했다.
- `PLAYTEST_KIT.md` 현행 M01~M06 절: 진행자 안내 문구(KO/EN), 관찰 표시, 48시간 뒤 기억 확인, Gate A·B·C·F 결과 집계표, 읽는 법 `[첫 실행 재조정]`.
- `NEXTFEST_CHECKLIST.md`: 2026-09-24 점검 절. 공개 체험판 Windows/Linux builder 부재, 캡슐 규격 재확인 필요(Steamworks 문서 접근 차단으로 미확인), 퍼블리셔 표기 불일치, 외부 플레이테스트 0건, 10월 회차 일정 판단.
- `store_shot_check.py` 재실행 PASS(8장). 게임 실행·빌드·실제 화면은 이 환경에 Godot이 없어 미관찰이다. 공개GO1·인간OPEN45·본편HOLD 불변.

## 2026-09-26 (Codex — 블랙잭 중국어 실제 화면·표적 입력)

- [287](queue_archive/ORDER-287.md): 최종 source 11946a3 / exact review a99fecc, 비저자 한정 GO/필수0. 실제 엔진은 제품이 같은25a5d3e에서 실행했다.
- 간체·번체13키의 Table16site를 각6상태·31선택 표기에서 확인했다. 총12 PNG·62표기가1280×800 최초 화면 안에 들어온다. 합성 키/trigger54사례에서 금액 미리보기·클램프·행동 하이라이트·다음 핸드/닫기를 확인했다.
- private 최초 parse FAIL은 원형 보존하고 경로 조회 한 줄만 수리했다. 같은 모집단의 후속CN/최초TW PASS, 제품 변경0·실제 사용자 파일43·직렬화 게임/meta 변수/명시 설정 복구 확인. locale cache/revision 복구는 주장하지 않는다.
- 준비 hand/result·강제 글리프·합성 입력이며 실제 정산·fresh-story·원어민·인간·물리 패드·다른 해상도는 미관찰. HUD/규칙/EV 부모 영어와 직접EN·동적 결과는 남아 있다.
- 공식40129/b130/meta9·보류72·공개GO1·인간OPEN45·본편HOLD 불변. [286](queue_archive/ORDER-286.md)의 중국어26수용과 이번 실제 관찰을 구분한다.

- 종료 metadata6 최초5 PASS/CLAUDE 부팅 예산1 FAIL을 보존했다. 현재 상태 한 줄을17976B로 줄여 context만 후속 PASS, 변경 없는 실제 화면/입력은 반복하지 않았다.

## 다음 안전한 범위

- 읽기전용 order287-next-blackjack-scope.json(13620B/SHA e9cfe408ca57c4f95bdbc21f4dfdc65278e83b2658f6445eb17eee819bf42984)은 HUD 부모·승률 fragment2키의 CN/TW4값을 다음 최소 번역으로 권고한다. 아직 선언/저작/수용0이며 현재287 화면은 그 번역후 증거가 아니다. hand/deal 분모와 순익/총회수 의미를 구분한다.
- 공유6소비자·JA/KO/EN 화면, AA 추가 카드·net0 타이 설명·EV 주장은 별도 범위다. 분할 double 원금만288에서 실제 재현·수리했다. 다른 정적 결손을 실행 재현이나 수리 완료로 부르지 않는다.
- UI사전3028 중 CN/TW각2048키 부재는 전체 live UI 분모가 아니다. 새 producer/consumer와 파일 소유를 큐에 선언한 뒤 진행한다.
- BigWheel JOKER배 부모·바카라 수수료 이중차감/타이 원금과 튜토리얼은 별도 원문/산식 채무다. post283-baccarat-accounting-scope.json 계획은 실행/수리/GO가 아니다.
- 보류72(268의62·270의10)는 월말 net==0·첫월급 투자접근·시장/AP효과·자산10억 절반·저자산 초기판정·잠/식사 고지 등 원문 정합 수리가 필요하다.
- 비보호 shipping 사건11578 세 언어 수용, 잔여843은 참고741·보호102. 공개판·역사 인간 판정을 보존한다.
- 재개 시 check/import에도 --locale 명시, 새파일 포함 staged diff-check 성공 뒤 commit. 실패 원형을 남기고 같은 모집단을 수리한다.
