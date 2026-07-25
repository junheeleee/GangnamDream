# 엔딩 35종 감사

Updated: 2026-07-26
Scope: `content/endings.json`, `content/endings_en.json`, 35개 전용 CG,
`ImageRegistry`, 실제 엔딩 UI, KO/EN 1280x800

## 현재 판정

구현 감사 결과 35개 엔딩 모두 고유한 `cg` 키와 전용 16:10 이미지를 소유한다.
공용 무드 카드, 코드 도형 심벌, 다른 사건 CG 폴백은 엔딩 런타임에서 제거했다.

| Gate | Result |
|---|---:|
| 엔딩 수 | 35 |
| 고유 CG 키 | 35 |
| 고유 파일 경로 | 35 |
| 고유 SHA-256 | 35 |
| 정확한 1280x800 PNG | 35 |
| 코드 도형·엔딩 심벌 폴백 | 0 |
| 공용 배경 카드 | 0 |
| 명시적 카메라·시선·손 계약 | 35 |
| KO/EN 전수 런타임 캡처 | PASS (35+35) |
| S+ White 회수 변주 | 4 |
| 핵심 무변주 결말 회수 추가 | 9 (`empty_house`·`mental_break`·`career_burnout`) |
| 자산 결산 코다 본문 복제 | 0 (대상 34개 전부 압축) |

시각 정본과 파일 전수표는
[`assets/ENDING_COMPLETE_VISUAL_BIBLE.md`](../assets/ENDING_COMPLETE_VISUAL_BIBLE.md)가
소유한다. 이 문서는 결과와 실패 이력만 기록한다.

## ORDER-48 산문 밀도 수리

- `gangnam_dream_white`는 추상적인 무결 선언 대신 이삿짐 상자·등기·오래된
  수첩으로 현재 행동을 만들고, 아버지의 약속·상철의 빚과 거리·첫 불법
  제안 거절을 네 개 dik로 회수한다. 다른 경로의 선 넘음을 지우는
  “아무도 밟지 않고” 절대 문구는 엔딩·요약·칭호에서 제거했다.
- `stable_success`·`orthodox_pinnacle`·`investment_master`·
  `unorthodox_legend`·`balanced_life`·`early_retirement`는 각각
  침대 끝의 폰, 회식 불판, 매매 수첩, 반대편 신호, 빈 수첩 칸, 울리지
  않는 알람으로 끝난다. 기존 dik가 본문 전체를 복제한 뒤 두 줄을 붙이던
  구조는 짧은 장면 코다로 바꿨다.
- `empty_house`는 화해·고백·약속을, `mental_break`는 다은·아버지·현수를,
  `career_burnout`은 이직·열린 문·아버지를 회수한다. 기본 결말과 변주가
  서로 다른 5년을 실제 사물과 행동으로 기억한다.
- `ScreenshotQA --qa=order-48 --lang=ko/en`에서 로맨스 경첩 7패널과
  엔딩 기본·변주 14경로를 각각 1280×800로 렌더했다. 긴 산문은 장면
  페이지로 분할됐고 텍스트·버튼·CG 경계 충돌은 없었다.

## 이번 전수 수리

- 전용 이미지가 없던 14종을 신규 제작했다:
  `ordinary_life`, `mental_break`, `political_fix`, `investment_master`,
  `reputation_legend`, `healthy_retirement`, `orthodox_hollow`,
  `balanced_life`, `unorthodox_legend`, `early_retirement`,
  `creator_success`, `career_climber`, `career_burnout`, `writer`.
- 불합격 기존 CG 4종을 교체했다:
  `gangnam_dream_white`의 불가능한 반사,
  `bankruptcy`의 모호한 파산 행동,
  `debt_spiral`의 단계 구분 부족,
  `gambling_recovery`의 회복 행동 가림.
- 재대조 중 `orthodox_hollow`가 본문상 55세 거실인데 38세 사무실로 제작된 것을
  발견해 `ending_orthodox_hollow_v2.png`로 다시 교체했다.
- 모든 프레임을 캡션 아래로 aspect-cover 하지 않고 전체 비율로 보이게 했다.
- 왼쪽 아래 캡션만 어둡게 하는 2차원 스크림으로 오른쪽 행동 소품을 살렸다.
- 엔딩 전용 SVG 심벌 4개와 런타임 심벌 경로를 제거했다.

## 의미 중복 방지

| 비교군 | 구분 기준 |
|---|---|
| `bankruptcy` / `debt_spiral` | 첫 파산의 전화 거절 / 회복 불능 단계의 바닥 정지 |
| `burnout` / `mental_break` / `career_burnout` | 응급 신체 실패 / 도움 요청 / 계속 일하는 소진 |
| `gangnam_dream` / `empty_house` / `lonely_rich` / `gangnam_dream_white` | 함께 도착 / 부친 상실 / 스스로 비운 관계 / 선을 넘지 않은 도착 |
| `stable_success` / `orthodox_pinnacle` / `orthodox_hollow` | 생활 안도 / 조직의 질문 / 55세의 무감각 |
| `with_daeun` / `second_love` | 외곽의 함께 사는 일상 / NG+ 뒤 강남에서 다시 택한 관계 |
| `full_circle` / `sangchul_reckoning` | 30억과 부친의 이름 회복 / 강남보다 빚 청산을 택한 결말 |

## 런타임 판정

KO와 EN의 35장을 각각 실제 엔딩 표면으로 렌더했다. 전용
`ScreenshotQA --qa=ending-all`은 원본과 표시 영역의 종횡비 오차를 `0.02`
이하로 고정하며, 70장 모두 텍스트·버튼·이미지 경계를 통과했다. EN 35장
연속 접촉면을 추가로 눈으로 대조해 얼굴, 손, 시선 목표, 결말 소품의 가림과
잘못된 크롭이 없음을 확인했다.

- 35개 결말의 장소와 핵심 행동이 첫 프레임에서 서로 구분된다.
- 캡션은 왼쪽 아래만 어둡게 하며 얼굴·손·핵심 소품을 피한다.
- 영어 장문에서도 다음 버튼과 이미지가 충돌하지 않는다.
- `orthodox_hollow`는 본문에 맞춰 55세 민준과 거실로 재제작했다.
- 실패 엔딩은 자해·공포 이미지로 과장하지 않고 실제 행동으로 구분한다.
- 가짜 숫자, 읽히는 기업 로고, 코드 도형은 활성 엔딩에 없다.

## 검증 명령

```bash
python3 tools/ending_distinctness_audit.py
python3 tools/art_ai_audit.py
python3 tools/cg_acting_contract_check.py
GODOT=/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot ./tools/audit.sh
```

최종 전체 감사는 사건 1,565개, 엔딩 35개, 영어 한글 누출 0, 활성 CG 74개,
GDScript 55개 컴파일을 포함해 `✅ 감사 통과`로 종료됐다.
