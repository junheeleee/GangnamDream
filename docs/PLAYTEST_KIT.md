# Gangnam Dream External Playtest Kit

> 현재 기본 대상은 `story_demo_rc` BUILD `2026.08.31.1` M01~M06이다.
> 사용자가 이 exact 구조와 출시 데모 범위에 GO했다. 아래 첫 절은 현행 공개
> 데모용이고, 뒤의 30분·3주 계획·W1~W24 V2 규약은 역사적 내부 진단용이다.

## 현행 공개 M01~M06 스토리 데모 세션

### 후보 고정

- 앱은 `GangnamDream-StoryDemo`, profile은 `story_demo_rc`, BUILD는
  `2026.08.31.1`이다.
- 제품 commit `4e80a63e89821094b8bab21b8d5c73ecfc9b6278`, package source
  `362578d8f4c0781fe35f643a74cc3037e7a80b21`, manifest SHA-256
  `50eed10b18c2c2b056f875a8df55230dc07b5535c55e59ddb89fff1d64e91870`,
  ZIP SHA-256 `956ac93524df6030ef984521550cec7dddafea381387a3df52194e43f5e61289`
  중 하나라도 다르면 같은 세션 집계에 넣지 않는다.
- 공개·Next Fest·기본 외부 테스트에 W1~W24 `demo_rc`, V2 playtest,
  ORDER-103/124 격리 앱을 대신 보내지 않는다.

### 세션 실행

1. 새 `GangnamDream_StoryDemo_v1` 사용자 데이터에서 인자 없이 앱을 연다.
2. 테스터가 언어를 고른 뒤 M01부터 평소 읽는 속도로 M06 끝까지 플레이한다.
3. StoryMode 장면과 현지 선택만 보여야 한다. AP 카드, `주력/함께/여력`,
   주간·월간 계획판이 나타나면 즉시 P0 회귀로 기록한다.
4. 진행자는 정답, 분기, 공략을 설명하지 않는다. 기술적 크래시·창 이탈·입력
   인식 실패에만 개입하고 시각과 화면을 남긴다.
5. 검은 전환막 잔류, 입력 잠금, 초상·배경·화자 불일치, 텍스트 잘림, 같은 장면
   중복, 저장·cold resume 이탈을 정확한 월·장면·선택과 함께 기록한다.

### 끝난 뒤 묻는 질문

1. 가장 기억에 남는 선택은 무엇이고, 왜 망설였나요?
2. 앞선 선택이 뒤 장면에서 돌아왔다고 느낀 순간은 어디였나요?
3. 누구의 다음 장면이 가장 궁금하고, 그 이유는 무엇인가요?
4. 이해하기 어려웠거나 상황과 맞지 않은 화면·초상·소리는 어디였나요?
5. 이 지점에서 본편을 계속하고 싶은가요? 가장 큰 이유 하나는 무엇인가요?

사용자 GO는 이 exact 후보에 이미 존재한다. 새 세션은 플랫폼 회귀·외부 이해·
마케팅 적합성 증거이며 자동 점수로 GO를 취소하거나 다른 커밋에 이전하지 않는다.
P0가 나오면 후보를 HOLD하고 수리한 새 exact candidate에서 다시 판정한다.
일본어·간체·번체는 자동 번역 패리티와 별개로 원어민 세션이 각각 OPEN이며,
그 전에는 Steam 지원 언어 claim으로 쓰지 않는다. 본편 M01~M60과 Chapter 5도
계속 HOLD다.

## Legacy/internal W1~W24 V2 30분 규약

아래 내용은 당시 `demo_rc`와 `core_loop_v2_playtest`의 서울 보드·AP·24주 CTA를
진단하기 위해 만든 역사 규약이다. exact 수치와 양식은 보존하지만 새 공개,
Next Fest, 기본 외부 세션에 실행하지 않는다.

> 역사적 목적: 버그 수가 아니라 30분 안에 플레이어가 자기 3주 계획을
> 세우는가를 확인했다. 모집과 세션 실행은 개발자 담당이었다.

## 1. 모집 표본

- 초기 5명은 진행 절차와 P0 오류를 찾는 파일럿이며, 최종 구조 판정은 **동일 RC 10명**을 채운 뒤에만 낸다.
- 절반은 비주얼노벨/서사 게임 경험자, 절반은 거의 하지 않는 사람으로 맞춘다.
- 국제 출시 판단에는 영어 원어민 또는 자연스러운 영어 사용자 3명 이상을 포함한다.
- 개발 과정, 공략, 정답 선택지, 30억 달성법을 아는 사람은 제외한다.
- 같은 빌드 revision과 같은 30분 제한을 사용한다.

### 모집 문구

> 30분 동안 설명 없이 PC 게임 데모를 플레이하고 짧은 설문에 답해 주실 분을 찾습니다. 게임 실력은 중요하지 않습니다. 화면과 음성이 기록될 수 있으며 개인정보나 얼굴은 기록하지 않습니다. 플레이 중 막혀도 진행자가 방법을 알려주지 않는 테스트입니다.

English:

> We are looking for players to try a PC game demo for 30 minutes without instructions, followed by a short survey. No particular gaming skill is required. The game screen and audio may be recorded, but no personal information or face recording is needed. The observer will not explain what to do if you get stuck.

## 2. 세션 준비

진행자는 시작 전에 다음만 확인한다.

- 당시 `human_gates.json`의 legacy `demo_rc`가 `active`였고
  revision·manifest·해당 플랫폼 artifact 해시와 세션 파일이 일치한다.
  flavor·패키징만 증명한 산출물은 후보 등록 전에 외부 세션에 쓰지 않는다.
- `build/playtest/MANIFEST.sha256`과 테스트 파일 hash가 일치한다.
- retail 저장은 건드리지 않는다. `gangnam_dream_v2_playtest_v1_*` 진행·설정·메타만
  없는 새 테스트 계정 또는 새 playtest 사용자 데이터로 시작한다.
- 창 제목·시작 화면·전 장면 우상단에 V2 playtest 표식이 보이고, 시작 메뉴의
  기본 진입이 `24주 데모 시작 / Start 24-Week Demo`인지 확인한다.
- 테스터가 선택한 언어, 해상도, 입력 장치를 기록한다.
- 화면과 게임 오디오를 기록한다. 얼굴·실명·음성은 동의가 있을 때만 기록한다.
- 타이머는 언어 선택 화면을 본 순간부터 30분이다.

### RC 식별과 세션 JSON

`playtest` 빌드는 더러운 작업트리를 거부한다. 진행자는 `MANIFEST.sha256`의 전체 commit/tree 해시와 `source_status=clean`을 확인하고, manifest 파일 자체와 배포한 플랫폼 산출물의 SHA-256을 세션에 기록한다.

```bash
sed -n '1,10p' build/playtest/MANIFEST.sha256
shasum -a 256 build/playtest/MANIFEST.sha256
shasum -a 256 build/playtest/windows/GangnamDreamV2Playtest.exe
```

- 기록 정본: `docs/playtest_session_template.json`
- 세션당 JSON 파일 하나를 사용하고 `session_id`를 중복하지 않는다.
- 실명·연락처·음성·자유 전사문 같은 개인정보는 JSON에 넣지 않는다.
- `build_revision`, `manifest_sha256`, `artifact_sha256`은 직접 입력한다. 하나의 집계에 서로 다른 revision/manifest가 섞이면 전체를 거부한다.
- `plan_score`는 진행자가 설문 직후 0~2로 채점하고, 나머지 1~5점은 테스터 응답을 그대로 기록한다.

진행자가 읽을 문장은 이것뿐이다.

> 이 게임을 처음 봤다고 생각하고 30분 동안 원하는 방식으로 플레이해 주세요. 저는 사용법이나 정답을 설명하지 않겠습니다. 생각나는 말은 편하게 소리 내도 됩니다.

English:

> Please play for 30 minutes as if this were your first time seeing the game. I will not explain the controls or the right choices. Feel free to think aloud.

## 3. 관찰 규칙

- 개입 금지: 버튼 위치, 서울 보드의 의미, 추천 행동, 목표, 선택 결과를 설명하지 않는다.
- 질문을 받으면 `지금 보이는 정보만으로 해보세요 / Please use only what the game shows you.`라고만 답한다.
- 기술적 크래시, 창 이탈, 입력 장치 인식 실패에만 개입하고 정확한 시간을 기록한다.
- 표정이나 침묵을 해석하지 말고 행동을 기록한다. `지루해 보임` 대신 `22초간 아무 입력 없음`으로 쓴다.
- 테스터가 텍스트를 넘긴 경우 비난하거나 다시 읽게 하지 않는다.
- 30분 전에 자발적으로 중단하면 설득하지 말고 중단 이유를 바로 묻는다.

## 4. 핵심 성공 기준

30분 직후 첫 질문은 힌트 없이 묻는다.

> 앞으로 세 주 동안 무엇을 할 계획이었나요?

> What were you planning to do over the next three weeks?

채점:

| 점수 | 기준 | 예시 |
|---|---|---|
| 2 구체적 | 행동 1개 이상과 순서/이유/위험 중 하나를 말함 | `먼저 구직하고, 월세를 버틸 돈을 만든 뒤 투자 공부를 하려 했다` |
| 1 막연함 | 방향만 있고 실제 행동이나 이유가 없음 | `돈을 더 벌려고 했다` |
| 0 없음 | 계획이 없거나 핵심 루프를 오해함 | `다음 이벤트가 자동으로 뜨길 기다렸다` |

**통과 기준: 10명 중 7명 이상이 2점.** 5~9명만 모집했다면 비율을 반올림하지 말고 원점수와 표본 수를 함께 보고하며, 10명까지 추가 모집하기 전 최종 GO 판정을 내리지 않는다.

## 5. 30분 후 설문

### 정량 5문항

각 문항은 1점(전혀 아니다)~5점(매우 그렇다).

1. 게임의 목표와 남은 시간을 이해했다. / I understood the goal and time limit.
2. 매주 무엇을 선택해야 하는지 판단할 수 있었다. / I could decide what to do each week.
3. 내 선택이 이후 장면이나 상태에 영향을 준다고 느꼈다. / My choices felt consequential.
4. 글자, 버튼, 정보 배치가 읽고 조작하기 편했다. / Text, buttons, and information were easy to read and use.
5. 그림이 게임의 분위기와 어울렸다. / The art fit the game's atmosphere.

### 정성 4문항

1. 앞으로 세 주 동안 무엇을 할 계획이었나요? / What were you planning to do over the next three weeks?
2. 가장 기억에 남는 선택 하나와 그 이유는 무엇인가요? / What single choice do you remember most, and why?
3. 실제로 고르기를 망설였던 선택이 있었나요? 있었다면 어떤 선택이었고 왜였나요? / Was there a choice you actually hesitated over? Which one, and why?
4. 계속하고 싶은 이유 또는 멈추고 싶은 가장 큰 이유는 무엇인가요? / What is the main reason you would continue or stop?

### 아트 추가 스팟체크

정량 5번과 짝을 이루는 필수 후속 질문이다. 핵심 정성 4문항 수에는 포함하지 않는다.

- 거슬리거나 게임에서 튄 그림이 있었다면 장면 하나를 적어 주세요. / Name one scene whose art bothered you or felt out of place, if any.
- 답변에는 가능하면 장면 제목 또는 당시 장소를 적는다. 진행자는 “AI 같았나요?”처럼 원인을 유도하지 않는다. / Ask for a scene title or location when possible. Do not lead the player by asking whether it looked AI-generated.

## 6. 관찰 기록지

### 세션 정보

| 필드 | 기록 |
|---|---|
| Session ID |  |
| 날짜/진행자 |  |
| build revision/hash |  |
| 언어 | KO / EN |
| 기기/해상도 |  |
| 입력 | Mouse+KB / Xbox / DualSense / Steam Deck |
| 서사 게임 경험 | 경험자 / 비경험자 |
| 완료/자발 중단 시간 |  |

### 타임라인

| 시각 | 화면/주차 | 관찰 가능한 행동 | 막힘(초) | 발화 원문 | 기술 오류 |
|---:|---|---|---:|---|---|
| 00:00 | 언어 선택 |  |  |  |  |
|  |  |  |  |  |  |
| 30:00 | 종료 |  |  |  |  |

### 필수 관찰점

| 관찰점 | 시간/결과 |
|---|---|
| 돈 50만원·목표 30억·5년을 처음 이해한 순간 |  |
| 첫 의미 있는 선택 |  |
| 선택지 앞에서 5초 이상 멈춘 장면(주차·선택 원문) |  |
| 첫 서울 보드에서 첫 여력 배치까지 걸린 시간 |  |
| 첫 잘못 누름/포커스 이탈 |  |
| 텍스트를 연속으로 빠르게 넘긴 구간 |  |
| 자발적으로 다음 결과를 궁금해한 순간 |  |
| 처음 명확히 막힌 지점 |  |
| 기억에 남은 이미지/거슬린 이미지 |  |

## 7. 결과 집계

| Session | 경험 | 언어 | 3주 계획 0~2 | 기억 선택 | 망설인 선택 | 계속 의향 1~5 | UI 1~5 | Art 1~5 | 자발 중단 | P0 오류 |
|---|---|---|---:|---|---|---:|---:|---:|---|---|
| P01 |  |  |  |  |  |  |  |  |  |  |

판정 순서:

1. 크래시, 진행 불가, 저장 손상은 즉시 P0 수정이다.
2. 3주 계획 구체 답변이 7/10 미만이면 콘텐츠를 더 넣지 말고 서울 보드 정보 구조와 선택 결과 피드백을 먼저 고친다.
3. 기억 선택이 반복해서 같은 한 장면에만 몰리면 나머지 데모 장면의 하중을 재검토한다.
4. 실제 망설임이 10명 중 0~1명이라면 자동 판정을 바꾸지 않고, 선택 판돈 수술의 근거로 장면·선택 원문과 함께 보고한다.
5. 계속 의향이 낮은 이유는 `텍스트/루프/조작/톤/아트/기술`로 분류하되 원문을 함께 남긴다.
6. 같은 장면이 아트 이탈로 2회 이상 지목되면 `docs/ART_AI_AUDIT.md` P0 후보로 올린다.

세션 JSON을 정형 검증하고 집계한다.

```bash
python3 tools/playtest_report.py /path/to/sessions/*.json > /path/to/playtest-report.md
python3 tools/playtest_report.py --format json /path/to/sessions/*.json
```

집계기는 중복 ID, 혼합 revision/manifest, 같은 플랫폼의 서로 다른 바이너리, 누락·알 수 없는 필드, 점수 범위 이탈을 거부한다. 결과 상태는 세 가지다.

| 상태 | 의미 |
|---|---|
| `INCOMPLETE_SAMPLE` | 10명, EN 3명, 서사 경험/비경험 각 4명 이상 중 하나가 부족하다. 수리 결정 전에 같은 RC 표본을 채운다. |
| `NO_GO_REPAIR_REQUIRED` | P0 오류가 하나라도 있거나, 완성 표본의 구체적 3주 계획이 70% 미만이다. |
| `READY_FOR_HUMAN_VERDICT` | 표본 계약·P0·계획 임계를 통과했다. 지금도 재미·출시 GO는 아니며 원문, 중단 이유, 기억 선택, 아트 이탈을 사람이 검토한다. |

이 legacy 내부 QA 통과는 당시 외부 플레이테스트를 대신하지 않았다. 첫 10명
결과는 W1~W24 V2 구조 진단에만 쓰며 현행 M01~M06 데모 판정에 합산하지 않는다.

## 8. Legacy/internal V2 개발자 첫 24주 집 플레이

이 절은 외부 30분 표본과 섞지 않는다. 개발자가 새 서울 사이클을 처음 끝까지
겪는 한 경로이며, 정식 사람 게이트 전체를 닫는 표본이 아니다.

### 플레이 전

- 아래 사후 질문을 먼저 읽지 않는다.
- 당시 active였던 `demo_rc`의 새 playtest 저장에서 `24주 데모 시작`을 선택한다.
- 평소 읽는 속도로 원하는 선택을 한다. 기능·분기·카지노를 일부러 전수하지 않는다.
- 가능하면 실제 패드를 사용하되, 입력 검사가 플레이 목적을 대신하지 않게 한다.
- 시작 시각과 24주 CTA 도착 시각만 기록한다. 막히면 시각과 화면만 남기고
  공략·디버그 문서·자동화 경로를 보지 않는다.

### 24주 CTA 뒤에만 묻는 일곱 질문

1. 이 게임은 무엇을 하는 게임이었다고 느꼈고, 가장 재미있었던 행동은 무엇이었나요?
2. 가장 오래 고민한 선택 하나는 무엇이었고, 무엇을 얻고 무엇을 포기했다고 느꼈나요?
3. 앞에서 한 선택이 나중 장면이나 상태로 돌아왔다고 느낀 순간이 있었나요?
   있었다면 무엇이 어떻게 돌아왔나요?
4. 다시 한다면 어느 달의 무엇을 다르게 고르겠나요? 그러면 이후가 어떻게
   달라질 것 같나요?
5. 서울 보드에서 고른 것과 이야기 장면에서 고른 것은 각각 어떤 종류의 결정처럼
   느껴졌나요? 차이가 없었다면 없었다고 말해 주세요.
6. 3번의 자유 응답을 먼저 기록한 뒤 묻는다. 자기소개서 고치기를 했거나 놓친
   일이 이후 지원·면접에 무엇을 바꿨다고 느꼈나요? 아무 차이도 못 느꼈다면
   그대로 말해 주세요.
7. 처음부터 CTA까지 몇 분 걸렸고, 읽기보다 확인 버튼을 연속으로 누른 구간은
   어디였나요? 화면·전환·음악·효과음·패드 버튼·진동 중 막히거나 싸게 또는
   반복적으로 느껴진 순간도 함께 말해 주세요.

5번과 6번은 자유 회상 뒤 결함을 좁히는 2차 진단 질문이다. 답변이 의도와
일치해도 유도 없이 기억했음을 증명하지 않으므로 공식 사람 게이트를 PASS로
바꾸지 않는다.

답변은 요약부터 만들지 않고 원문을 먼저 `docs/DEMO_FIXLOG.md`에 보존한다. 한 번의
한국어 자연 플레이에서 나온 패드·진동 문제는 수리 근거가 될 수 있지만,
KO/EN 각 1회, 세 청취 환경, 물리 패드 기종과 ORDER-98 임의 표본을 요구하는
정식 게이트를 대신하지 않는다.
