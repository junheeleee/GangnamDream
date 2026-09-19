# ORDER-271 — 월말결산·경고 중국어 UI

[x] 2026-09-20. 독립 Poincare work_unit GO는 이번 90수용·0보류 처리에만 적용한다.

- 제품 `1fadb15778246c8ae2f000f938e01854a594cb80`, tree `5971c76bb1586189730542c8b96cc25215206acd`. clean 검토 `efcdcfa166ef89fbc2c21c837320d3b0dd572518`. source 이후 STATUS-only.
- 수집·저작전 현금2키의 노출조건을 정정한17기능45키×2=90초안이다. 공개/인간/본편 GO가 아니다.
- 실제 수용 39842/b116/meta9. 기존39752 보존; UI/portable 역복원과 JA/원문/runtime 보존.
- 원어민·렌더·인간플레이·물리패드 OPEN. 공개GO1·인간OPEN45·본편HOLD·기존보류110 유지.
- 원형 QA·실패·수리·남은 위험은 [독립 보고](../agent_reviews/ORDER-271.json), SHA 23641ae8308c481f3401e320130282cc0f64c36937aba673663133f8f614807c.
- 일회성: 본 배치 번역·선정·검증·수용·파일소유 지시. 영속 권한/언어규칙은 기존 WORK_UNIT/I18N 소유, 신규 규범 승격0.

자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

## 실제 캡처

원문은 git-private에 stdout/stderr/exit·입력핀과 보존한다. 진단 수집 exit0와 전체 통과는 다르다.

| 파일 | 바이트 | SHA256 | exit | 결과 |
|---|---:|---|---:|---|
| order271-export-cn-first.json | 377560 | 7fc7bcbad56837e0e29adc2f66528da4fcab9b195d06f5aa7521d0a3c460f982 | 0 | PASS |
| order271-export-tw-first.json | 377560 | a8c77f4332cd728d6f0d39f3b50983fda57692b1424f319284bc8183e10f2ec9 | 0 | PASS |
| order271-formal-export-cn-first.json | 377589 | a76d9aef72476f7a6c14e169bb40a6e8716093dcc3fabfe33b21f1fa3809591d | 0 | PASS |
| order271-formal-export-tw-first.json | 377589 | debf8911f2e6035237293124c74d975d3b8e0b703f9ffcb87b1cc9101480d7fb | 0 | PASS |
| order271-formal-import-cn-first.json | 377511 | bdb21306ff98b425028af608f591a5206762c3a86db8209146ad2e4ea17c0b57 | 0 | PASS |
| order271-formal-import-tw-first.json | 377511 | f6917a0b2a861d0d108ff59a0c2425de3a6acd10d003d2aaedb5c0698e588599 | 0 | PASS |
| order271-named-first.json | 1690343 | 158792bfe027064bf92dde08369a330285a35358c8eefbdb007eec7cc7fa6689 | 0 | PASS |
| order271-named-outer-first.json | 379613 | 69bcc8cc946547a2b4495563d31f68164de441a54d552e63d2b932e1769aee76 | 0 | PASS |
| order271-preflight-check-cn-first.json | 377491 | 58b0ec6c99ec5f5dee24310a94a961e2768ca139c91f21b0db1f1428aaba8bf6 | 0 | PASS |
| order271-preflight-check-tw-first.json | 377498 | 1b6ccc57764d01e66134c0cb803a0bb67b521cf77829860d28267d5c9f370a37 | 0 | PASS |
| order271-preservation-first.json | 377738 | 837ce0def5a170a0b7d228378791c96b44b4a64b037421aed29bf2b5a2127d02 | 0 | PASS |

## WORK 마감 전 원문

# Gangnam Dream Work Log

> 이전 WORK·현재 선언·실패 원문은 [270 보존본](queue_archive/ORDER-270.md)에 있다.

## 2026-09-20 (Codex — 월말결산 중국어90 착수)

- [271](queue_active/ORDER-271.md):17기능45키씩 독립KO직접 저작·비저자전수.90는 예상초안 수다. 현금2키는 수집·저작전 실제소비자 정정으로 제외.
- 기존39752·기보류110·JA·원문·공개판·인간원장 보존. 첫고지본문1은 별도 RO 조사만.
- 독립최초 REWORK2(CNstat명/TW중첩句點), 원90전수r1GO/필수0. 기존check/import각45실제수용, 신규HOLD0.
- 공식39842/b116/meta9, JA13096·CN/TW각13373. 사전각844존재/2171부재는전체실제UI분모가아니다.
- 현재cleanexact·보존·명명12·독립최종은별도마감한다.

## 2026-09-20 (Codex — 상태·기록·엔딩 중국어 138 반영)

- [270](queue_archive/ORDER-270.md): 제품ef83b96·검토4583aa4, 독립 Poincare 한정GO/필수0.
- 원148초안 전수 언어검토 뒤 실제138수용·10보류. 상세 실패·의미·원고는 독립보고에 보존.
- 공식39752/b115/meta9. 기존39614·KO/EN/JA·runtime·공개판·인간원장/과거56판정 보존.
- 명명12 통과는 회귀증거이며 원어민·화면 완료가 아니다. 공개GO1·인간OPEN45·본편HOLD.
- 마감 검사는 미커밋 변경 기준 selector6개다. `--base ref`는 커밋된 diff만 보므로 dirty 마감에는 쓰지 않는다.

## 다음 안전한 범위

- 실제 남은 중국어 UI 초안 우선. 이전268보류62+269보류38은 보고에 보존하여 재저작하지 않는다.
- 다음 RO 계획 `.git/full-game-localization/post270-ui-next-plan.json` 41021B/SHA30953c7c60e7107c2c41200193d1159ccfc76d23c64ae3e218b555a11061e423:
  48키18기능 후보 중 현재 literal47·17기능은 CN/TW미번역, 첫고지본문1은 세언어누락/collector지원미관측으로 별도다.
  ROOT는 계획 전량/원문48/조건/13소스핀을 읽고 현재일치를 확인했다. 새 큐 선언·직접소비자확인·저작은 아직이다.
- 현재 소스 `자산10억! 절반` 오독은 번역에서 제외한 별도 원문 수리 후보.
- 첫시작 콘텐츠 안내본문·동적 직업/단서/생각명·직행EN은 이번 라벨 번역만으로 완료가 아니다.
- 비보호 shipping 사건11578 세 언어 수용 완료.843은 참고741·보호102로 신규 활성 사건 공백 아님.

## 활성 사양 원문

# 월말 결산·현금 표시·경마 복귀 경고 중국어 UI

#### [~] ORDER-271 중국어 UI17기능·45키

[~] 착수 — 2026-09-20 Codex. clean main `d997f302a09d2ffc5460d714fed78d3020c63232`.
공식39752/b115/meta9·기존57판정. 남은 실제 중국어 문구 저작을 우선한다.

## 깊이3문과 고정 범위

이 번역을 빼면 월말에 돈·몸·마음·시간을 돌아보는 표면과 경마 복귀 경고가 영어로 남는다.
24주 뒤 게임 상태는 변하지 않는 현지화 작업이며, 같은 화면의 영어 폴백과 경쟁한다.
새 선택이나 도달 경로를 만들지 않고 현재 호출과 사실 의미를 검수한다.

고정 계획 `.git/full-game-localization/post270-ui-next-plan.json` 41021B,
SHA `30953c7c60e7107c2c41200193d1159ccfc76d23c64ae3e218b555a11061e423`의
48키18기능 중 `first_start_warning` 한 키와 아래 현금2를 뺀 45키17기능만 이번 번역 모집단이다.
ROOT가 계획 전량·KO/EN48·조건·제외를 읽고13현재핀을 확인했다.
제목1·수첩2·결산입금기록3·결산틀2·수입/비용카드7·지원금1·판정/잔여4·몸1·마음1·
주간시간배분3·선택기록1·급증3·성장3·생존/일반4·적자3·위기2·경마의존경고4.
JA45은 기존값을 보존한다. first_start_warning은 세언어누락·수집지원 미관측으로 별도 RO 조사만 한다.

## 파일 소유

- ROOT 제품3: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`의 선택45 추가,
  `content/meta/full_game_localization.json`의 실제 신규 수용만.
- ROOT 운영10: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  본 사양, `docs/queue_archive/ORDER-271.md`, `docs/WORK_LOG.md`, `docs/STATUS.md`,
  `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`, `docs/agent_review_decisions.json`,
  `docs/agent_reviews/ORDER-271.json`.
- Plato 간체·Rawls 번체: KO 직접 독립저작, 각각 private 초안만. Poincare 비저자 전수 언어·최종 exact 검토.
  ROOT만 제품/QA/Git. private 일회성 보조는 기존 교환/캡처를 최소 변경해 재사용한다.

## 의미와 비소유 경계

주차·현금·자산·수입과 고정비의 차이·실제 지원금/급여 수령을 그대로 둔다.
이미 기록된 주간축과 실제 행동기록만 표현하고 AP 판·전화·투자 기능을 활성화하지 않는다.
문맥 수첩의30억은 원화이며5년기간/개월token을 보존한다. 경고는 기존 조건·주장의 번역이지 새 측정값이 아니다.
자산증가만 본 등급의 투자 묘사, 저자산 분기의 '아직 초반', 중독지수만 본 잠/식사 경고는 원문 한계다.
번역이 원문보다 원인·수익·회복·생리 상태를 더 확정하지 않는다. 원문 수리는 이번 비소유다.
보존: KO/EN·JA·runtime/선택/라우팅/저장·공개M01~M06·인간원장·기존39752·기보류110.
원268/269/270키·공개121·first_start_warning·비활성 AP/phone/debug/fallback·직행EN 수리·검사/fixture/pin 변경0.

## 유한 검증과 마감

1. clean 선언에서 기존 collector로 각45 export, 실제ID/KO/지원/보호 확인. KO직접90초안→비저자전수.
2. 기존 check 첫 실패는 보존. 언어 결함이면 원모집단 전체 재검토; 기계경계면 해당 기능 양언어를 HOLD로
   분리하고 원90전체통과로 부르지 않는다. 보류원고는 최종보고에 보존. 새검사 확장/왜곡번역0.
3. 승인값만 apply_patch 설치→clean 재export→기존 import --accept 실제receipt와 변경0확인.
   실제 수용만 portable추가, old39752 현재해시·UI/portable 역복원·JA 보존을 clean 후보에서 검사한다.
4. `news-panel-locale-only` 고정명명12를 이번 전체diff와 owned13에 결속해 한 번 실행한다.
   전체 감사·engine·240주·새guard0. 자동검사와 별개로 비저자 clean exact 한정판정을 받는다.
5. GO후 보고/원장/큐/WORK/STATUS metadata 마감과 변경에 맞는 기존 selector검증→main/번역브랜치 동기화.

이번 저작·선정·검증·파일소유 지시는 일회성. 영속 언어·권한규칙은 기존 WORK_UNIT/I18N이 소유한다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
공개GO1·인간OPEN45·본편HOLD. 원어민/실제화면/인간플레이/물리패드·외부출시 권한0.

## 수집·저작 전 소비자 정정

선언7cc70ac의 원47을 실제코드로 확인하던 중 계획오류를 찾았다. LocaleManager.is_english:139는
language != ko이므로 CN/TW에서 true다. Main9287~9296의 `현금 %s  |  자산 %s`와 `현금 %s`는
중국어 HUD가 읽지 않는다. 다른 공유호출도 이번 활성경로 근거가 아니다. 두키를 저작/공식export/검수 전에 제외한다.
두 저자 모두 초안파일 작성 전 수신을 확인했다. 제목 `강남드림` 한 키는 현재 Main 상단에서 읽으므로 남긴다.
원계획48·첫선언47과 그 오류는 보존하며, 번역 또는 기계 FAIL 뒤 통과를 위해 축소한 것이 아니다.
최종90초안 모집단과 old39752·기보류110은 분리한다. 두키는 HOLD번역원고나 새수용이 아니다.

## 실제 반영 — 최종 exact 전

원90 독립언어REWORK2: CN정신력명칭과 TW수첩의 중첩마침표. 원초안불변+r1한글자씩수리후
같은90전수 언어GO/필수0. 첫기계check각45통과, 승인45씩UI추가→clean재export/import--accept각45,
실제import제품변경0. 신규HOLD0·기보류110불변. 공식39842/b116/meta9·기존39752보존대조.
첫고지본문은RO메모만완료: 원KO/EN7literal을동일단일literal로표현하는방향이며 새1key의현재/역사수집계약은별도수리다.
