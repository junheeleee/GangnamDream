# Gangnam Dream Work Log

> 이전 WORK·선언·검증 원문은 [285 보존본](queue_archive/ORDER-285.md)에 있다.

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

## 2026-09-26 (Codex — 고지 세 언어 실제 화면)

- [285](queue_archive/ORDER-285.md): source 180f7ed / exact review 73fb10c, 비저자 한정 GO.
- 실제 고지의 JA/CN/TW14역할×3=42 정확 표기와 클립/스크롤·합성 Down/Back 복귀를 확인했다. 신규36·기존6을 구분하며 실제 라이선스 원장·본문은 그대로다.
- 사용자 저장·게임/meta·source 입력핀 보존. 원어민/인간/물리 패드·다른 해상도·패키지 미관찰. 런타임/번역/인간 원장 수정0.
- 공식40103/b129/meta9·보류72·공개GO1·인간OPEN45·본편HOLD 유지. 이 UI 한정 검수는 전체판 번역 완료가 아니다.

## 다음 안전한 범위

- UI사전3028 중 CN/TW각2061키 부재는 전체 live UI 분모가 아니다. 다음 실제 producer/consumer 묶음을 별도 선언해 번역한다. 실제 화면의 남은 직행EN·동적인자는 별도 범위다.
- 읽기전용 다음 후보는 order285-next-ui-scope.json(20299B/SHA c28d76b13c8fd3434a5b9f363bb3f41822a8ed7627c9313ade8736a7dfb7e769)의 Blackjack 조작/기록13키다. JA13 유지·CN/TW26 후보일 뿐 신규 선언/저작/수용0이며, 정산·환불·규칙/EV11키는 split/추가비용 정합 위험으로 제외했다.
- BigWheel JOKER배 부모·바카라 수수료 이중차감/타이 원금과 튜토리얼은 별도 원문/산식 채무다. post283-baccarat-accounting-scope.json 계획은 실행/수리/GO가 아니다.
- 보류72(268의62·270의10)는 월말 net==0·첫월급 투자접근·시장/AP효과·자산10억 절반·저자산 초기판정·잠/식사 고지 등 원문 정합 수리가 필요하다.
- 비보호 shipping 사건11578 세 언어 수용, 잔여843은 참고741·보호102. 공개판·역사 인간 판정을 보존한다.
- 재개 시 check/import에도 --locale 명시, 새파일 포함 staged diff-check 성공 뒤 commit. 실패 원형을 남기고 동일 모집단을 수리한다.
