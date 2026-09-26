# ORDER-285 — 타이틀 고지 세 언어 실제 화면

[x] 2026-09-26. 비저자 독립 검수 work_unit 한정 GO, 필수 결함0.

- source `180f7ed253bca12ac3a6a446bbb34764a385a421`, tree `31b79de4532b0c21033b00937c278a882039a992`; clean review `73fb10ca6f9cc442caf1931f8359d40789988b6a`, STATUS-only wrapper.
- JA/CN/TW 1280×800 실제 고지의 14역할×3=42 정확 표기를 관찰했다. 신규36값과 기존6값을 구분한다.
- 대표 entry4의 메타데이터·저작권·동봉/표시의무/자발적 크레디트 문구는 각 탭의 첫 가시 영역에서 캡처됐다. 보충 자동스크롤은 필요0회였으며 그 미실행 경로를 PASS라고 하지 않는다.
- 메뉴 진입·탭 전환·표적 스크롤 위치는 직접 호출이다. 기존 Down/Back 합성 입력의 스크롤 포커스·이동·Settings 복귀는 별도 관찰했다. 인간/물리 패드 입력이 아니다.
- 실제 저장 파일의 전후 파일집합·해시, pre-autoload 격리, notice-only 게임/meta 보존, 입력핀·정상 종료·세 로그·완료 marker를 확인했다.
- 최초 helper 예약변수 구문 실패·CN/TW 종료 BGM 잔류 실패·CN verbose 진단은 원형 보존했다. 실제 고지 판정 이후 private teardown에서 메뉴 음원 참조를 놓고 동일3언어를 재검증했다. 제품 종료 누수의 수정/닫힘 증거가 아니다.
- 제품 코드·원문/번역·공지 JSON·라이선스·출처·공개 데모·인간 원장은 수정0. 공식40103/b129/meta9·보류72·공개GO1·인간OPEN45·본편HOLD 유지.
- 상세 범위/최초 실패/수리와 직접 본 PNG는 [독립 보고](../agent_reviews/ORDER-285.json), SHA `6a18b7de19341117238d4ce222019eff46c705fa0c27ca36629782f849b658f5`에 결속한다.
- 원어민·인간 실플레이·물리 패드·다른 해상도·패키지·법률 인증 미관찰. 본편/언어 전체 GO가 아니다.
- 규범 승격: 없음. 기존 WORK_UNIT·UI·입력 정본 적용이며 새 선언/observer/검수 범위는 일회성이다.

## 실제 실행 기록

| 실행 | 언어 | 결과 | PNG 수 | result SHA256 |
|---|---|---|---:|---|
| order285-render-cn-final-first | zh-CN | PASS | 4 | b4fad2fac6622f26e0d7e4ae76971cc8239dc54766b17dba28ad73ff60a77d0b |
| order285-render-cn-first | zh-CN | FAIL retained | 4 | e0a8a5d7b6b5eefe9d29b48cbf1d34b69aa6869cb32aa732bc26bc23630b594f |
| order285-render-cn-verbose-first | zh-CN | FAIL retained | 4 | 363c275a56c21a68c4b291dc3f89dae678cf909ac1b7ce44c2831ea224f68421 |
| order285-render-ja-final-first | ja | PASS | 4 | 6332e061a15c5c23dbc21210863a45fc5aff76329655846c6fa67f3f9891b082 |
| order285-render-ja-first | ja | FAIL retained | 0 | 575bf7fb1454603330e3fcd29a24898accb53d404f52a8410c19fa9ad6dce07f |
| order285-render-ja-repair-first | ja | PASS | 4 | fce27ef1e30d54a31648931ae11dcff0a658de95662ef50c32eacfe47e7d500d |
| order285-render-tw-final-first | zh-TW | PASS | 4 | 43164265a02016bb33dda387b039248b2d05ce649d8560335fdd4d280921a4d1 |
| order285-render-tw-first | zh-TW | FAIL retained | 4 | 97612564f31fd3cd04b307463de546f4d7217bc290c7eef6bf9bba9c75945d77 |

## 이전 WORK 원문

# Gangnam Dream Work Log

> 이전 WORK·선언·검증 원문은 [284 보존본](queue_archive/ORDER-284.md)에 있다.

## 2026-09-20 (Codex — 실제 타이틀 고지 안내 세 언어36값)

- [284](queue_archive/ORDER-284.md): 제품ca8dfe0·검토0ee137b, 독립 Poincare 한정GO/필수0.
- 실제 설정→제3자 고지의 소개·배포 사본 안내·메타데이터·상태·탭12키를 JA/CN/TW 각12 채웠다. 법률/저작권 본문과 자산명은 번역하지 않았다.
- JSON14쌍의 실제 reader source provider를 full/JA/ZH가 공유한다. 기존static2 보존·신규12 등록, 임의extra를 거부한다. 기존 역사 pipeline/fullself는 불변이다.
- 공식40103/b129/meta9. old40067 source/target hash·세 UI/portable raw 역복원·원문manifest 보존, 기존 명명12 및 새 notice self5methods PASS.
- 최초 notice2실패/fullself3실패를 보존하고 JA 개행·정확 함수 변이·ZH partial source 경계를 수리했다. 같은5/12 전체 재검증으로 닫았고 역사 fullself/pipeline·번역36은 변경0이다.
- 실제화면·원어민·인간·물리패드·법률준수 미관찰/인증0. 공개GO1·인간OPEN45·본편HOLD·보류72 불변.
- 규범 승격은 I18N_INFRASTRUCTURE의 notice chrome/법률본문 경계다. 이번 한정GO는 게임 전체나 언어출시 GO가 아니다.

## 다음 안전한 범위

- 설정·저장·대화기록의 이미 번역된 literal 표면을 반복 저작하지 않는다. 이번36값의 실제 title notice 레이아웃/언어변경은 아직 관찰하지 않았으며 별도 큐 선언 후 표적 실행한다.
- 읽기전용 화면 계획 post284-notice-render-scope.json(11943B/SHA8667d258a9774dfce81c90f417eefaabf81b749689ab91c9a260c3e783d14a28)은 기존 ScreenshotQA notice scope와 pre-autoload namespace를 재사용한다. 새 출력폴더/실제슬롯 전후 해시가 필요하며, 기존 기하/탭/합성입력 확인과 전체14역할의 가시성은 별도다. 실행·새화면·신규오더 선언은 아직0이다.
- UI 사전3028 중 CN/TW각2061키 부재는 전체 live UI 분모가 아니다. 실제 producer/consumer·동적인자·직행EN·화면을 따로 대조한다. legacy/AP 소비자는 fresh-story/실제화면 증거가 아니다.
- BigWheel JOKER배 부모와 직접영문 기계/심볼·튜토리얼은 별도 원문/인자 채무다.
- 바카라 뱅커 수수료 이중차감·타이 원금 누락은 정적 산식채무2다. 읽기 전용 계획 post283-baccarat-accounting-scope.json(12075B/SHA99c70565d28bd0c23b8574c65d5f6f9ac85615964e29ad4168e696247adf99f3)은 실행/수리/GO가 아니다. 타이8배·수수료/HUD/규칙은 계산 수리와 함께 별도 범위로 다룬다.
- 보류72는268의62·270의10. 월말 net==0·첫월급 투자접근·시장/AP효과·자산10억 절반·저자산 초기판정·잠/식사 고지는 별도 원문 정합 대상이다.
- 비보호 shipping 사건11578 세 언어 수용, 잔여843은 참고741·보호102. 공개판·역사 인간 판정은 유지한다.
- 재개 시 check/import에도 --locale를 명시한다. 새파일 포함 staged diff --check exit0 뒤에만 commit하고, 최초 검사 실패는 보존하며 무관한 역사층을 우회 수리하지 않는다.

## 활성 사양 원문

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
