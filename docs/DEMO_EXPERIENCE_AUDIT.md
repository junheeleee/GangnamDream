# Demo Experience Audit

> 상태: 2026-07-19 KO/EN 24주 자동 체험 기준선 통과. 사용자 Demo Round 2 NO-GO는 유지한다.

## 목적

`demo-input`의 빠른 확인 횟수는 도달성과 입력 안전만 증명한다. 이 감사는 실제로 노출된 본문·결과·선택·AP 개입·이미지·오디오를 기계 판독 JSON으로 기록한 뒤, 정상 독해 속도에서 데모의 길이와 결정 간격을 추정한다. 자동 수치는 산문의 재미, 선택의 후회, 장면 기억을 판정하지 않는다.

## 2026-07-19 기준선

| 지표 | KO PlayStation | EN Xbox | 계약 |
|---|---:|---:|---:|
| 주차 / 사건 / 뿌리 | 24 / 47 / 24 | 24 / 47 / 24 | 동일 |
| 의미 선택 / 직접 행동 | 36 / 10 | 36 / 10 | 동일 |
| 정상 독해 추정 | 67.3분 | 58.9분 | 40~90분 |
| 첫 의미 선택 | 3.9분 | 3.5분 | 7분 이내 |
| 최대 선택 공백 | 3.3분 | 2.7분 | 7.5분 이내 |
| 배경 / 초상 / CG | 15 / 11 / 4 | 15 / 11 / 4 | 한영 동일 |
| 장소음 / 사람층 / 음악 키 | 10 / 4 / 5 | 10 / 4 / 5 | 한영 동일 |
| 명시 음악 사건 / 최장 무음악 뿌리 | 8 / 4 | 8 / 4 | 4+ / 8 이하 |
| 직접 AP 사용 | 19 / 19 | 19 / 19 | 전량 사용 |
| 빠른 확인 입력 | 689 | 693 | 도달성 전용 |

한국어는 분당 390자, 영어는 분당 190단어를 기준으로 하며 문단 호흡, 선택 숙고, AP 및 차단 모달 시간을 별도 가산한다. 이는 비교 가능한 회귀 모델이지 실제 플레이타임 보장이 아니다.

## 수리 결과

- 상시 로파이를 복구하지 않고 마지막 상환, 첫 유혹, 1장 종결, 다은·지연 첫 각인, 직업 대 투자, 강남 문턱, 6개월 결산의 8장면에만 기존 5종 점음악을 배치했다. 각 곡은 장소음이 먼저 자리 잡은 뒤 시작한다.
- 실제 렌더 배경 ID를 장소음의 정본으로 승격했다. 번역된 제목·본문에 `비`, `카페`, `지하철` 같은 단어가 있어도 같은 화면은 같은 공간음을 낸다.
- 일반 사건 화면과 선택 결과 배경도 동일한 규칙을 사용한다. 텍스트 추론은 실제 배경 ID가 없는 레거시 사건의 폴백으로만 남는다.
- 체험 샘플러는 배경 또는 CG가 실제로 준비된 첫 안정 프레임에서 장소음을 한 번 기록한다. AP 화면으로 돌아간 뒤의 룸톤이 직전 사건을 덮어쓰지 않는다.

## 재현

```bash
/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot \
  --path . --resolution 1280x800 res://tools/ScreenshotQA.tscn -- \
  --qa=demo-experience --lang=ko --pad=playstation --demo-build \
  --output-dir=/tmp/gangnam_experience_ko

/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot \
  --path . --resolution 1280x800 res://tools/ScreenshotQA.tscn -- \
  --qa=demo-experience --lang=en --pad=xbox --demo-build \
  --output-dir=/tmp/gangnam_experience_en

python3 tools/demo_experience_audit.py \
  /tmp/gangnam_experience_ko/demo_experience_ko_gamepad.json \
  /tmp/gangnam_experience_en/demo_experience_en_gamepad.json
```

`tools/audit.sh`는 검증기 자체 테스트와 8개 점음악 앵커를 항상 검사한다. 장시간 실제 입력 주행은 릴리스 후보와 데모 체감 수렴 시 다시 실행한다.

## 열린 인간 게이트

사용자 재플레이에서 다음을 별도로 판정해야 한다.

- 첫 유혹 또는 6개월 피날레가 48시간 뒤 기억나는가.
- 36개 의미 선택 중 적어도 하나를 실제로 망설였는가.
- 장소음 중심의 정적 구간과 8개 점음악이 감정의 고저로 들리는가.
- 67.3/58.9분의 분량이 소설 체험으로 느껴지는가, 확인 노동으로 느껴지는가.

이 네 항목이 닫히기 전에는 ORDER-28/22와 사용자 Demo Round 2를 GO로 변경하지 않는다.
