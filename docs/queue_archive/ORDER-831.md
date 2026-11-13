# ORDER-831 — 체험판 2차 평가 최종 수리

#### [x] ORDER-831 · C2/C3/C4 · ORDER-829 동결 예외의 마지막 수정

2026-11-13 사용자 승인. 직접 진행 두 장면의 민준 발화, 월말·최종 회고의 기존
가까운 재정 목표, 4월의 실제 매물 금액 계산, 지정된 반복·소품·시각·M6 추가
인계의 부담 및 영어 문장만 고친다. 반장의 문자·3월 계산대·6월 확인 전화와
잔여 50만 원·문의 직전 컷·1월 도입과 상철 핵심 대사 보존. M11 첫 돈의 문,
선택 효과·플래그·아이템·연출·저장·새 시스템과 장면은 변경하지 않는다.

### [~] 착수 — 만지는 파일

- 본문: `content/events/arc_events.json`, `content/events/core_loop_v2_events.json`,
  `content/events_en/{arc_events,arc_daeun,core_loop_v2_events}.json`,
  `content/events_{ja,zh-CN,zh-TW}/story_demo_events.json`. 공유 독자의 문구가
  원문에 정확 결속된 경우 `content/meta/demo_core_loop_v2.json`의 해당 추적문만.
- 표면: `playtests/order124/StoryChoiceM1M6Playtest.gd`, 기존 키 재사용을 우선하는
  `locale/ui_{ja,zh-CN,zh-TW}.json`의 해당 보호 키. 재정 사다리의 `GameState`
  기존 소비만 사용하고 기준·스폰 가중치·경제는 수정하지 않는다.
- 검사: `tools/{StoryChoiceM1M6Check,StoryDemoFourLanguageCheck,ScreenshotQA}.gd`,
  `tools/{demo_localization_scope,full_body_translation_scope,demo_core_loop_v2_audit,zh_translation_audit,english_hangul_audit}.py`의 해당 소스 결속 및 표적 회귀만.
  기존 재정 키 1개를 데모에서 추가로 읽는 `tools/story_demo_localization_audit.py`의
  정확한 UI 인벤토리와 음성·비용 회귀도 포함한다. 이전 보호 지문·키 검사는 보존한다.
- 문서: 이 사양, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `CLAUDE.md`. 본편 직접
  진행 발화와 M01~M10 돈 판단은 여기서 목록으로만 남기고 수정하지 않는다.

상철 4월 사무실 체인(T2, 기존 두 응답의 결합과 소품/방 구하기 현실성), 6월 연락
및 종막(T1 체인의 해당 링크)만 수정한다. 기존 방·초상·연출·소리·문단 경계를
유지하며 발화는 인물 소유 지식 안에서, 비용은 새 차감 없이 행동/시간으로 쓴다.

5언어 보호 차선·공유 독자·별도 소스 RC·실제 5언어 화면으로 확인한다. 8.31과
11.13.1은 덮지 않고 역사 판정을 이월하지 않는다. AI 블라인드 평가 재실행0.
다음은 사람 1명 1시간 테스트, 이후 상점 A안. Steam 업로드0.

### 본편 조사만 — 수정하지 않음

직접 진행은 한 개의 실제 선택이 보이고 타이머·장 카드가 아닐 때만
`scenes/StoryMode.gd:3351`에서 열리며, 선택 문구는 힌트에 들어간다.
2월 거절과 6월 장부는 행동으로, 결과에도 행동이 있어 대사 누락이 아니다.

| 새 이야기에서 도달하는 추가 후보 | 근거 |
|---|---|
| `cafe_caught_honest` | `scenes/MainGame.gd:7900` → `content/events/scenario_cafe.json:135` |
| `arc_daeun_proposal_last_cup` | `scenes/MainGame.gd:8093` → `content/events/arc_daeun_romance.json:183` |
| `arc_daeun_wedding_night_honest` | `scenes/MainGame.gd:8112` → `content/events/arc_romance_specials.json:592` |
| `arc_jiyeon_wedding_night_window` | `scenes/MainGame.gd:8814` → `content/events/arc_romance_specials.json:731` |

별도 옛 AP 경로: `arc_daeun_first_kiss_ask`, `arc_season_sea_daeun_years`,
`arc_season_sea_daeun_horizon`, `arc_season_sea_jiyeon_voice`,
`arc_season_fireworks_jiyeon_schedule`(`scenes/MainGame.gd:16802`, `:16919`).
현수 재회의 `hyunsu_reunion_photo`·`hyunsu_reunion_memory`는 인용문 없이
식사 제안의 응답만 남는 별도 옛 경로(`content/events/arc_hyunsu.json:303`, `:331`).
체험판에 들지 않는 본편 초반 SNS 기억의 EN `bankbook` 두 건도 별도 목록이다.

| 본편 월 | 돈 판단 조사 |
|---|---|
| M01–M02 | W4 200만 원 유혹, W8 반환 150만/추가 300만. 거절 경로는 야간근무 수락과 별개로 금액 선택 없음. `systems/FullStoryFlow.gd:441` |
| M03 | 통장 계획·무직 조건 야간 일자리; 조건부 첫 투자/경마는 기본 경로를 대표하지 않음. 본편 지연 보상은 체험판과 달리 W17 이후. `scenes/MainGame.gd:7957`, `:7978`, `:7999`, `:8173` |
| M04–M05 | 방·종잣돈 배분 판단이 약함. 조건부 월급날·보유 손실 및 지연 보상은 예외. `scenes/MainGame.gd:8233`, `content/events/arc_midgame.json:2284`, `:2395` |
| M06 | 창원 이동 5만/통화/보류와 일부 강남 방문은 존재. 체험판 첫 청구서 5택은 본편 공통 아님. `scenes/MainGame.gd:8149`, `:8326` |
| M07–M08 | 현수 시험은 돈 판단 없음. 방 계약 계획은 실제 공통 선택이 아니며, 새 방 장면은 이미 이사한 경우. `scenes/MainGame.gd:8351`, `:7850` |
| M09 | 다은을 만난 경우 식사 3만/산책/목표 말하기. 다른 관계 분기는 동등한 예산 판단 없음. `scenes/MainGame.gd:8059` |
| M10 | 첫 공과금은 이사 조건부이며 납부 뒤의 장부·통화·루틴 선택. `scenes/MainGame.gd:7395`, `content/events/arc_midgame.json:3721` |

사람 테스트 뒤 우선 확인은 M04–M08·M10, M09는 분기 차이. 자동 정산·비용이
모든 경로에 체감 가능한 돈 선택이 있다는 증거는 아니다. M11과 본편 코드는 불변.

### 완료 — 2026-11-13 KST

- 도달: 제품 `cfc7e09374e4f09315c4b0ed3ad158cd0843b827`, tree
  `0134de0f798c530079d681f8d59aaf06d3094d90`. macOS BUILD `2026.11.13.2`,
  ZIP 446,185,535 bytes / SHA-256 `affe6e728a13c507676fa25aaaeca28827a76cd7a60c97fe257fde4afffbd8bd`.
  서명·ZIP 앱 바이트·PCK 1,902·JSON 675·ICU 일치. 빌드의 기존 제외 폴더
  경고 1종 외 오류0. .1 역사 ZIP `f2b5c785…e256` 재확인, 8.31 재발급0.
- 생산자/독자: `arc_sangchul_01_{measure,coffee}` 결과 P0/P2 →
  StoryMode 직접 진행; `GameState.get_financial_rung` → 데모 M01–M05 정산·M06 회고.
  보증금 1,000만+월세 70만=1,070만(관리비 별도); 실제 절약 가능액을 보기 전
  날짜 확정0. 재정 사다리와 30억 장기 목표·이전 효과·저장 계약 불변.
- 포기와 비용: W24 `v2_dirty_recruiter_week24`의 차단/캡처는 그대로이며, 압박·
  아침 시간·남은 이름의 연결만 강화. 새 송금·법적 처분·수치·플래그0.
  W24 기존 확인 전화·남은 50만 원·문의 직전 결말은 보존.
- 검사: 격리 StoryChoice 3경로/28 selector, 공개 5언어/30정산, 앱 자체
  5언어/120주/30정산과 정상 콜드 재개. 정확 소스 실제 그래픽 110 PNG
  (4월 두 갈래 20·정산/회고 2해상도 60·종막 30), 잘림0.
  상철 이름표는 기존 상대 초상이고 본문 첫 줄은 민준 발화로 명시한다.
- 공개 현지화 14사건/100잎/125 UI, 55개 자체 검사, demo scope 16+71,
  밀도·legacy 내용·JA/zh·EN·공유 서사/정합·컨텍스트 검사 통과.
  본편 광역 원장 48건은 전후 같은 오류 집합(신규0), 범위 밖. 제품 CI
  [43440248243](https://github.com/junheeleee/GangnamDream/actions/runs/43440248243)
  정적 성공·엔진 진행 중. 전체 성공으로 세지 않는다.
- 일회성: 이 평가 목록·새 로컬 RC. 승인·인간 증거·시장 제출에 승격하지 않는다.
  추가 AI 평가0, 사람 1명 1시간과 이후 상점 A안은 미실행.
