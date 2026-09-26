# Active Queue Spec: ORDER-285

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

[~] 착수 — 2026-09-20. 타이틀 제삼자 고지 JA/CN/TW 실제 렌더 14역할.

## 한정 목적과 근거

ORDER-284가 수용한 소개·배포 안내·메타데이터·탭 번역은 실제 화면 미관찰이다.
실제 StartMenu > Settings > Third-Party Notices의 14역할을 세 언어, 1280×800에서
정확 문구·가시성·스크롤·복귀와 함께 확인한다. 신규12×3=36 번역과 기존2×3=6을
구분한다. 법률 본문·출처·의무를 번역하거나 인증하는 작업이 아니다.

깊이 3문: 제거하면 실제 표시/클립 결함을 놓친다. 읽기 전용 UI여서 24주 상태 변화는
0이어야 한다. 같은 자리의 소개·탭·목록·닫기 가독성이 경쟁한다. 서사 tier/선택 비용은
해당 없음이며 새 게임 선택을 만들지 않는다.

## 정확 소유

- `CLAUDE.md` 현재 상태 한 줄.
- `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md` 행/순번.
- `docs/queue_active/ORDER-285.md` 및 종료 시 `docs/queue_archive/ORDER-285.md`.
- `docs/WORK_LOG.md`, `docs/STATUS.md`.
- `docs/agent_review_decisions.json`, `docs/agent_reviews/ORDER-285.json`.
- git-private `.git/full-game-localization/order285*`: observer GDScript/scene,
  runner/oracle, 입력핀, 첫 stdout/stderr/Godot 로그, JSON/PNG와 독립 검수 기록.

제품 런타임·기존 ScreenshotQA·Bootstrap·번역사전·공지 JSON·라이선스·출처원장·
공개 데모·인간 원장·저장슬롯은 수정0. 제품 결함은 원형 증거를 남기고 별도 수리
범위를 선언한다. helper 결함은 동일 14×3 모집단에서 수정·재관찰하며 첫 실패를 보존한다.

## 실행 계약

1. 기존 ScreenshotQA notice scope를 상속한다. 실제 Settings/고지/탭 직접 호출은
   직접 호출로 기록하고, 기존 Down/Back 합성 입력 증거와 혼동하지 않는다.
2. notice JSON의 KO14 source와 수용된 locale dictionary를 독립 oracle로 삼는다.
   runtime LocaleManager의 반환값을 기대값으로 복사하지 않는다.
3. 고정 title/intro/package, section3, provider/copyright/license/source/license_terms와
   status3을 실제 entry에서 읽는다. copyright는 font_noto_color_emoji, 상태는
   godot_engine/salamander_piano/freesound_queue_chime_cc0에서 찾는다.
   화면 밖 텍스트는 실제 목록을 스크롤해 보인 프레임에서만 가시 증거로 센다.
4. 언어마다 새 pre-autoload namespace·새 출력 폴더를 쓴다. 실제 사용자 저장
   파일과 source/observer/oracle/runner 핀을 전후 확인하고 출력은 재사용하지 않는다.
   로그 세 스트림·정상 종료·완료 marker·42 exact bindings·PNG를 함께 확인한다.
   notice-only 진입 전후 GameState/meta 읽기 전용 경계도 확인한다.
5. 1280×800 세 언어의 유한한 표적 캡처만 실행한다. 전체 감사·240주·기존 명명12·
   번역 export/import는 반복하지 않는다. 마감은 context/queue/workunit/human/
   delegated-review/status의 metadata6 및 diff-check로 제한한다.
6. 비저자 검수자는 private helper·실제 산출물·모집단 전수 데이터를 읽고
   세 언어의 고정 안내와 대표 메타데이터/의무·자발 표기 PNG를 직접 검수한다.
   source commit/tree, clean exact review HEAD, 파일 SHA와 미관찰 경계를 결속한다.

## 보존·판정 경계

공식40103/b129/meta9·보류72, 원문 manifest·역사 인간 판정·공개GO1·인간OPEN45·
본편HOLD 보존. 결과는 work_unit 한정이며 원어민/인간 실플레이/물리 패드 감각·
960×600/다른 해상도/패키지/전체 본편 품질·법률 인증으로 확대하지 않는다.
규범은 기존 WORK_UNIT/UI/입력 정본 적용이며 이 선언과 helper는 일회성이다.
