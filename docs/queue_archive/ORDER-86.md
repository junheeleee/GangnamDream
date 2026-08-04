# Archived Queue Spec: ORDER-86

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-86 [P0·현지화] 영어 인물 목소리와 관계 거리를 24주 데모 전체에서 바로잡는다

**착수 선언 (2026-08-04 Codex) — 만지는 파일:**
영어 정본 `docs/I18N_GLOSSARY.md`, 정확한 데모 영어 오버레이
`content/events_en/arc_daeun.json`, `arc_events.json`, `arc_midgame.json`,
`core_loop_v2_events.json`, `scenario_cafe.json`, `story_events.json`, 실제 24주
동적 대사를 소유한 `scenes/ArubaGame.gd`, `scenes/JobHuntMiniGame.gd`,
`content/meta/demo_core_loop_v2.json`, 파생 계약
`content/meta/demo_localization_scope.json`,
`content/meta/release_content_inventory.json`, `docs/CONTENT_RATING_INVENTORY.md`,
영어 문구를 실제 흐름에서 대조하는 `tools/CoreLoopV2CCheck.gd`,
`tools/CoreLoopV2ECheck.gd`, `tools/ScreenshotQA.gd`,
검토·사람 판정 `docs/QA_CHECKLIST.md`, `docs/human_gates.json`, 완료 기록
`CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/STATUS.md`,
`docs/RELEASE_NOTES.md`, `docs/DEMO_FIXLOG.md`, 이 사양의 활성·아카이브 경로.

한국어 원문, 선택 수·순서, 효과·플래그·후속·도달, 돈·날짜·시각·기간,
저장·런타임, 25~240주 영어, JA·ZH 본문은 소유하지 않는다. 영어 대사의
문장 수·길이·축약형 개수는 목표치로 만들지 않으며
`tools/speech_register_audit.py`도 수정하지 않는다.

**착수 후 범위 확장 (2026-08-04):** 첫 청구서의 실제 KO/EN 화면 증거를
검사하는 `CoreLoopV2ECheck`가 고친 영어 문장 전체를 옛 번역과 정확히 비교해
표적 실행이 실패했다. 의미·몸 상태·한영 동시 렌더 계약은 유지하고, 영어
리터럴만 새 정본과 동기화하기 위해 이 검사 파일을 구현보다 먼저 선언 범위에
추가한다.

**착수 후 범위 확장 2 (2026-08-04):** 960×600 `core-loop-v2` 실제 화면
검사도 첫 청구서 아버지 답장을 옛 영어 리터럴과 비교해 중단됐다. 렌더·선택·
결과 검증은 그대로 두고 `tools/ScreenshotQA.gd`의 해당 영어 표지만 새 정본과
동기화하기 위해, 구현보다 먼저 선언 범위에 추가한다.

**착수 후 범위 확장 3 (2026-08-04):** 13~16주 런타임 검사가 한빛 면접
불참 문장의 옛 수동태에 든 `attended`를 정확히 요구해, 의미가 같은 자연스러운
`misses the scheduled interview`를 거부했다. 일정·지원 상태·불참 결과 검증은
그대로 두고 `tools/CoreLoopV2CCheck.gd`의 영어 표지만 새 정본과 동기화하기
위해 구현보다 먼저 선언 범위에 추가한다.

**사용자 승인 (2026-08-04):** `docs/DECISIONS.md`의 P-10을 권고대로 실행한다.
일본어 화자표를 번역하지 않고 영어만의 수단인 문장 길이·완결성, 요청의 직접성,
머뭇거림 위치, 축약형, 호칭 범위로 화자→청자 관계를 보상한다.

**실측 범위:** 정확한 fresh-start 24주 범위는 `72사건 / 447본문 / 동적
543회·536고유 / 카탈로그 4`다. 따옴표가 있는 55사건 중 52사건은 실제 대사·
문자·기관 문구이고 3사건은 수첩·서류 인용이다. 편의점 손님, 자소서,
모의면접처럼 매번 달라지는 147개 활동 대사도 플레이어가 실제로 읽으므로
같은 전수 범위에 넣는다. 최초 재독에서 재혁의 과도한 격식, 아버지의 영어
비문, 다은의 판촉문 같은 직역 명사, 사고 보상을 개인 빚 상환처럼 바꾼 의미
오류를 확인했다. 이 수치는 작성 목표나 합격 비율이 아니다.

## 깊이 3문

1. 이 표와 전수 교정을 지우면 한국어에서 다른 거리로 말하는 다은·지연·현수·
   아버지·상철·재혁이 영어에서 같은 중립 번역문으로 합쳐지고, 이후 번역도 그
   평탄화를 정본으로 복제한다.
2. 이 작업은 선택 설계가 아니다. 고른 경로와 고르지 않은 경로의 효과·플래그·
   관계·도달·금액·주차는 수정 전후 완전히 같아야 한다.
3. 한 줄에서는 자연스러운 영어, 한국어 관계 거리, 짧은 화면 독해가 경쟁한다.
   인물 표식을 세게 넣어 번역투가 되거나 자연스럽게 만든다는 이유로 누구나 할
   법한 말이 되면 모두 실패다.

## 배치 A — 영어 정본과 22개 전수 판정 단위

정본 표는 각 관계에 대해 `문장 길이·완결성 / 요청의 직접성·우회 / 머뭇거림
위치 / 축약형 / 호칭의 허용 시점·반복 범위 / 금지할 평탄화·과장`을 기록한다.
숫자 비율이나 정규식 점수는 넣지 않고 장면의 의도적 예외를 허용한다.

1. 영어 보상 수단과 공통 금지 규칙
2. 다은→민준
3. 민준→다은
4. 지연→민준
5. 민준→지연
6. 현수→민준
7. 민준→현수
8. 아버지→민준
9. 민준→아버지
10. 상철→민준
11. 민준→상철
12. 재혁→민준
13. 민준→재혁
14. 카페의 남자·Manager Kim→민준
15. 민준→카페의 남자·Manager Kim
16. 면접관·채용팀·상담사·창구 직원→민준
17. 민준→면접관·채용팀·상담사·창구 직원
18. 최씨 이웃↔민준
19. 수사관↔민준
20. 불법 모집책→민준
21. 채권자·편의점 손님·익명 단역·자소서·모의면접·인용 공식 문구
22. 72사건·동적 543회 전체 교차 검토: 선택지의 민준 목소리, 호칭, 사실·숫자·
    토큰·문단·동적 키 패리티

각 단위는 파일이 아니라 화자와 관계를 기준으로 묶는다. 증거 원장 열은
`단위 / 사건 ID·경로 / 화자→청자·관계 단계 근거 / 다섯 영어 수단 /
PASS·EDIT와 before→after / 한국어 의미·숫자·토큰 불변 / 독립 재독`이다.
멀쩡한 문장은 개수 균형을 위해 고치지 않는다.

## 비범위

- 새 대사·장면·선택·인물성을 발명하지 않는다. 낮은 점수의 뻔한 면접 답변은
  뻔한 선택으로 남기되 비원어민 문법만 고친다.
- 한국어 경어를 `sir`, `ma'am`, `-ssi`, `oppa`의 반복으로 보상하지 않는다.
  현재 데모의 `oppa` 0과 `-ssi` 0을 유지하고, 현수의 `hyung`은 관계가 실제로
  드러나는 자리에서만 선택적으로 남긴다.
- 축약형 비율·평균 문장 길이·완곡어 개수를 새 자동 게이트로 만들지 않는다.
  기존 `speech_register_audit`은 호칭·관계 단계 회귀로만 사용한다.

## 검증과 사람 판정

- L1: `72사건 / 447본문 / 543회·536동적 / 카탈로그 4` 범위와 한영 오버레이
  구조·선택 수·플레이스홀더·문단, 영어 커버리지·한글 누출 0, 기존 말투·서사·
  Core Loop·출시 인벤토리, JSON/GDScript 컴파일, 실제 Godot 대화 기록과 24주
  완주, 전체 감사·CI를 통과한다.
- L2: 위 22단위를 한국어와 다시 대조해 의미·함축·관계 거리·숫자·날짜가 같고,
  화자 이름을 가려도 인물과 관계의 차이가 남는지 독립 2차 재독한다.
- L3: 사용자는 같은 `demo_rc`에서 22단위 중 임의의 서로 다른 3단위를 고른다.
  영어 원어민 또는 준원어민이 이름을 가린 상태에서도 관계와 목소리 차이를
  설명하고 한국어와 의미·거리·사실을 대조한다. 하나라도 번역투·평탄화·과장된
  호칭이면 표본만 고치지 않고 22단위를 전량 재검토한다.

## 완료 조건

- 영어 화자→청자 표가 정본 한 곳에 있고, 실제 24주 사건·동적 대사를 22단위로
  전수 판정한 증거가 있다.
- 의미 오류와 번역투는 사라지되 한국어 사실·선택·효과·플래그·후속·도달·수치는
  불변이고, `oppa/-ssi` 0과 선택적 `hyung`이 관계 단계와 맞는다.
- 영어 1280×800·960×600의 장문 대사·선택·결과·로그, 표적 실행, 전체 감사와
  원격 CI가 초록이다. 규범 승격·일회성 판정을 기록하고 사람 게이트를 연 채
  사양을 아카이브한다.

## 완료 증거 — 22단위 L2 전수 원장

| # | 단위·경로 | 관계·다섯 수단 | 판정·대표 before→after | 불변·독립 재독 |
|---:|---|---|---|---|
| 1 | `I18N_GLOSSARY` | 공통 다섯 수단 | EDIT — UI 톤만 존재 → 문장 완결성·직접성·머뭇거림·축약형·호칭 계약 | 비율·개수 목표 없음, 재독 PASS |
| 2 | `arc_daeun`, 다은 약속·첫 청구서 | 다은→민준, 따뜻한 생활 관찰·공동화 | EDIT — `Grab another` → `You can grab another one`; 판촉문식 `other person` → `ask each other`, `No fair...` | 관계 진전·효과 불변 |
| 3 | 다은 재방문·첫 청구서 | 민준→다은, 실용어 뒤 질문 | EDIT — `came in handy` → `I enjoyed the extra gimbap`; 문어적 인사·확인문 자연화 | 이름 교환·약속 순서 불변 |
| 4 | `arc_jiyeon_02_store`, `v2_jiyeon_second_crossing` | 지연→민준, 통제된 완결문·거절 출구 | EDIT — `thinking about it` → `worrying about it`; 재소개 모순 → `barely got to say a proper hello` | 사고·보상·관계 단계 불변 |
| 5 | 같은 지연 장면 선택 | 민준→지연, 짧고 정중한 경계 | EDIT — 개인 빚처럼 보인 `paying me back` → `compensation`; `I'm going to head home` → `I think I'll just leave` | 선택 수·결과 불변 |
| 6 | 현수 첫 만남·공부·시험 문자 | 현수→민준, 부탁+자기 몫·선택적 `hyung` | EDIT — `I'm next door`와 매문장 호칭 → `from the room next door`와 관계가 작동하는 자리만 호칭 | 시험 날짜·한 시간·후속 불변 |
| 7 | 현수 장면의 민준 선택 | 민준→현수, 짧고 실용적 | EDIT — `Still figuring it out` → `I'm still figuring it out`; 문장 조각을 자연스러운 완결문으로 교정 | 목표·선택 효과 불변 |
| 8 | `arc_father_01`, 첫 청구서 | 아버지→민준, 짧은 절·밥으로 우회 | EDIT — `You doing all right.` / `You eating.` / `Ate.` → 자연스러운 질문·`I did.` | 23초·6년·침묵 불변 |
| 9 | 아버지 통화·일요일 전화 | 민준→아버지, 밥·잠·다음 통화 | EDIT — `Yeah. You too?` → `Yeah. Did you eat?`; 호칭과 질문 위치 자연화 | 통화 선택·기억 불변 |
| 10 | 상철 첫·두 번째 만남 | 상철→민준, 질문 뒤 구체적 대비 | EDIT — 흐려진 강남 명제 → `see it as a means to an end`; `don't lose anything` → `Don't lose what matters` | 명함·두 건물·후속 불변 |
| 11 | 상철에게 답하는 선택 | 민준→상철, 존중하되 비굴하지 않음 | EDIT — `That question, I can answer.` → `That one I can answer.` | 선택·명함 불변 |
| 12 | 재혁 첫 문자·재회·동적 중복 | 재혁→민준, 옛 친구 구어·축약형 | EDIT — 군대 소개문 → `We served together. Remember me? Been a while. How've you been?`; 동적 메시지도 동일화 | 10년 공백·만남 시점 불변 |
| 13 | 재혁에게 답하는 선택 | 민준→재혁, 안부 또는 날카로운 질문 | EDIT — `Have you been well?` → `How've you been?`; `What brought this on?` → `What's this about all of a sudden?` | 친근·경계 경로 불변 |
| 14 | `scenario_cafe` | 카페의 남자·Manager Kim→민준, 거래 조건 압축 | EDIT — `entry pass` → `right to a new unit`; `Get educated` → `Learn the basics`; 5천만원 대화에 끼어든 의미 복구 | 금액·권리·명함 불변 |
| 15 | 같은 카페 선택 | 민준→카페의 남자·Manager Kim | PASS — `May I ask you just one thing?` 등은 낯선 연장자에게 목적을 숨기지 않는 현재 거리와 맞아 개수 맞추기 수정 안 함 | 독립 재독 PASS |
| 16 | 채용팀·상담사·창구·면접 질문 | 기관→민준, 절차·기한이 선명한 문장 | EDIT — 채용 제안을 실제 offer 문장으로 복구; `Let us start` → `Let's start`; `Pressure` → `Curveball` | 18시·월요일·직무 사실 불변 |
| 17 | 지원서·면접 답변 | 민준→기관, 근거와 다음 행동 우선 | EDIT — `Reliability.` → `Reliable.`; 낮은 점수 답변도 회피 의미를 보존하며 문법만 정상화 | 문항·점수·타이머·배열 불변 |
| 18 | `v2_father_health_signal` | 최씨 이웃↔민준, 관찰과 확인 분리 | EDIT — 반복 약국 봉투를 자연스러운 관찰문으로, 답장은 추정 없이 본 사실만 묻게 교정 | 병명·병원 선취 없음 |
| 19 | `v2_dirty_investigator_call` | 수사관↔민준, 공식 사실 범위 | EDIT — `police cyber investigation team` → `police cybercrime unit`; 회수 요청의 계좌·사기금 의미 복구 | 혐의·처분·금액 선취 없음 |
| 20 | 대포통장 모집책 | 불법 모집책→민준, 짧은 명령·압박 | EDIT — 어색한 `Hyungnim`·명령문 → `Clean work... pay another million apiece. You're already in this anyway.` | 범죄 사실·금액·후속 불변 |
| 21 | 채권자·편의점 손님·익명·서면·활동 | 즉시 목적에 맞는 단역 목소리 | EDIT — 요청 이름을 사람 명사로 복구하고 `How do you respond?`로 조합; 서면 약속·활동 147개·자소서·면접 답변 재독 | 보너스·스트레스·점수·시간 불변 |
| 22 | 전체 교차 검토 | 72사건·447본문·동적 543회/536고유·활동 147 | PASS — 오버레이는 문자열 잎만, 메타는 영어 값만, GDScript는 한영 쌍만 변경; `oppa/-ssi` 0, `hyung` 선택적 | 선택·토큰·문단·날짜·금액·효과·도달 불일치 0 |

22단위는 서로 다른 두 재독자가 한국어 원문·선행 장면과 다시 대조했다. 마지막
재독에서 감사만 하고 떠난 다은 장면을 `said hello`로 바꾼 모순, 이미 이름을
나눈 지연에게 다시 소개한다는 연속성, `이번 기수`를 한 회차처럼 줄인 문장을
추가로 찾아 고쳤다. 멀쩡한 15번은 수정 개수를 맞추지 않고 PASS로 남겼다.

## 구현 증거 (2026-08-04)

- L1 범위는 `72사건 / 447본문 / 동적 543회·536고유 / 활동 147 / 카탈로그 4`로
  고정됐다. 영어 전체 카탈로그는 `1,601/1,601`, 한글 누출은 0이다. 정확한 데모
  재귀 표본에서 `oppa=0`, `-ssi=0`, 선택적 `hyung=10회·10표면`이며 10은 목표치가
  아니라 실제 관계 장면의 관측값이다.
- 사건 오버레이는 문자열 잎만, `demo_core_loop_v2`는 영어 값만, 활동 스크립트는
  한영 문구 쌍과 그 영어 조합문만 바뀌었다. 선택 수·순서·타입·플레이스홀더·
  문단, 효과·플래그·후속·도달, 돈·날짜·시간·점수·저장에는 차이가 없다.
- 영어 Core Loop는 1280×800과 960×600에서 각각 36장, Story는 1280×800 31장,
  대면·원격 표면은 960×600 7장을 렌더해 본문·선택·상단 HUD·대화 기록 버튼의
  잘림과 겹침이 없음을 직접 확인했다.
- 실제 영어 키보드 입력은 `weeks=24`, `story_events=42`, `keyboard_events=1352`,
  `plans=6`, `offer_intents=22`, `week_commits=22`, `first_bill=1/1/1`, `autosave=1`,
  `title_return=1`, 타 장치·의미 입력·미상 입력 0으로 타이틀 복귀까지 완주했다.
- 현지화 범위·커버리지·누출·말투·서사·Core Loop·문체·출시 인벤토리,
  `CoreLoopV2C/ECheck`, `StoryDialogueHistoryCheck`, Godot 60스크립트 컴파일과
  `tools/audit.sh` 전체가 통과했다. `demo_en_voice_random_three`는 자동 통과시키지
  않고 열린 사람 판정으로 유지한다.

## 완료·규범 판정 (2026-08-04)

- 구현 커밋 `556e929`를 `main`에 반영했고 원격 CI
  [30905074570](https://github.com/junheeleee/GangnamDream/actions/runs/30905074570)이
  정적 감사, 전체 Godot 감사, KO PlayStation·EN 키보드 24주 실제 입력, 경제·
  경마 스모크를 모두 통과했다.
- **승격:** 계속 유효한 영어 관계 거리 규칙은
  `docs/I18N_GLOSSARY.md`의 `영어 인물 목소리 — 화자→청자`가 소유한다.
- **자동 지속:** 기존 현지화 범위·커버리지·한글 누출·말투·서사·Core Loop·
  출시 인벤토리와 정확한 Godot 화면·입력 검사가 의미·구조 회귀를 막는다.
- **일회성:** 22단위 before→after 원장, 두 독립 재독과 이번 화면·실행 표본은
  이 교정 배치의 완료 증거다. 문장 길이·축약형·완곡어·호칭 비율을 새 자동
  합격선으로 만들지 않는다.
- **사람 판정:** `demo_en_voice_random_three`는 같은 `demo_rc`에서 원어민 또는
  준원어민이 임의 3단위를 판정할 때까지 열린 채로 남는다.
