# Gangnam Dream External Playtest Kit

> 목적: 버그 수가 아니라 **30분 안에 플레이어가 자기 계획을 세우는가**를 확인한다. 모집과 세션 실행은 개발자 담당, 이 문서는 진행 규약과 기록 양식이다.

## 1. 모집 표본

- 총 5~10명. 첫 판정은 10명을 권장한다.
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

- `build/demo/MANIFEST.sha256`과 테스트 파일 hash가 일치한다.
- 새 저장 슬롯이며 이전 메타 진행/해금이 없다.
- 테스터가 선택한 언어, 해상도, 입력 장치를 기록한다.
- 화면과 게임 오디오를 기록한다. 얼굴·실명·음성은 동의가 있을 때만 기록한다.
- 타이머는 언어 선택 화면을 본 순간부터 30분이다.

진행자가 읽을 문장은 이것뿐이다.

> 이 게임을 처음 봤다고 생각하고 30분 동안 원하는 방식으로 플레이해 주세요. 저는 사용법이나 정답을 설명하지 않겠습니다. 생각나는 말은 편하게 소리 내도 됩니다.

English:

> Please play for 30 minutes as if this were your first time seeing the game. I will not explain the controls or the right choices. Feel free to think aloud.

## 3. 관찰 규칙

- 개입 금지: 버튼 위치, AP 의미, 추천 행동, 목표, 선택 결과를 설명하지 않는다.
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

### 정성 3문항

1. 앞으로 세 주 동안 무엇을 할 계획이었나요? / What were you planning to do over the next three weeks?
2. 가장 기억에 남는 선택 하나와 그 이유는 무엇인가요? / What single choice do you remember most, and why?
3. 계속하고 싶은 이유 또는 멈추고 싶은 가장 큰 이유는 무엇인가요? / What is the main reason you would continue or stop?

### 아트 추가 스팟체크

정량 5번과 짝을 이루는 필수 후속 질문이다. 핵심 정성 3문항 수에는 포함하지 않는다.

- 거슬리거나 게임에서 튄 그림이 있었다면 장면 하나를 적어 주세요. / Name one scene whose art bothered you or felt out of place, if any.

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
| AP 화면에서 첫 행동 결정까지 걸린 시간 |  |
| 첫 잘못 누름/포커스 이탈 |  |
| 텍스트를 연속으로 빠르게 넘긴 구간 |  |
| 자발적으로 다음 결과를 궁금해한 순간 |  |
| 처음 명확히 막힌 지점 |  |
| 기억에 남은 이미지/거슬린 이미지 |  |

## 7. 결과 집계

| Session | 경험 | 언어 | 3주 계획 0~2 | 기억 선택 있음 | 계속 의향 1~5 | UI 1~5 | Art 1~5 | 자발 중단 | P0 오류 |
|---|---|---|---:|---|---:|---:|---:|---|---|
| P01 |  |  |  |  |  |  |  |  |  |

판정 순서:

1. 크래시, 진행 불가, 저장 손상은 즉시 P0 수정이다.
2. 3주 계획 구체 답변이 7/10 미만이면 콘텐츠를 더 넣지 말고 AP 정보 구조와 선택 결과 피드백을 먼저 고친다.
3. 기억 선택이 반복해서 같은 한 장면에만 몰리면 나머지 데모 장면의 하중을 재검토한다.
4. 계속 의향이 낮은 이유는 `텍스트/루프/조작/톤/아트/기술`로 분류하되 원문을 함께 남긴다.
5. 같은 장면이 아트 이탈로 2회 이상 지목되면 `docs/ART_AI_AUDIT.md` P0 후보로 올린다.

내부 QA 통과는 외부 플레이테스트 통과를 대신하지 않는다. 이 키트의 첫 10명 결과가 데모 구조 변경 여부를 결정한다.
