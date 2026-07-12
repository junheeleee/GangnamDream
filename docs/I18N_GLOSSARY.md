# 강남드림 영어 번역 용어집 (i18n glossary)

> UI 문자열 번역 일관성 기준. `LocaleManager.ui(ko, en)` 또는 씬의 `_tr(ko, en)` 헬퍼로 감싼다.

## 핵심 용어
| 한국어 | English |
|---|---|
| 강남드림 | Gangnam Dream |
| 강남 | Gangnam |
| 김민준 | Kim Minjun |
| 카페의 남자 | Man at the Cafe |
| 김 부장 (카페 브로커) | Manager Kim |
| 행동력(AP) | Action Points (AP) |
| 구직활동 | Job Hunt |
| 자기계발 | Self-Dev |
| 휴식 | Rest |
| 투자 | Invest |
| 시장 분석 | Market Analysis |
| 사람·관계 | People · Relations |
| 네트워킹 / 인맥 | Networking |
| 다음 주 | Next Week |
| 다음 달 | Next Month |
| 자산 | Assets |
| 순자산 | Net Worth |
| 수입 | Income |
| 지출 | Expense |
| 정신력 | Mental |
| 건강 | Health |
| 지력 | Intelligence |
| 사교력 | Social |
| 투자감각 | Investing |
| 평판 | Reputation |
| 외모 | Appearance |
| 운 | Luck |
| 고시원 | goshiwon |
| 원룸 | one-room |
| 빌라 전세 | villa (jeonse) |
| 아파트 전세 | apartment (jeonse) |
| 통장 | bank account |
| 마일스톤 | milestone |
| 챕터 | Chapter |
| 엔딩 | Ending |
| 도감 | Collection |
| 칭호 | Title |
| 업적 | Achievement |

## 금액 표기
- `format_money()`는 그대로 사용 (자체 처리). 라벨만 번역.
- 억 = "00M" (1억 = 100M), 30억 = 3 billion / ₩3B.

## 톤
- 간결한 게임 UI 영어. 마침표 최소화.
- 이모지·BBCode `[color]`·`%d/%s` 포맷 지정자·`\n`는 **절대 변경 금지**, 위치 보존.
- `{name}` `{housing}` 토큰 보존.
- 카페 시나리오의 `김 부장`은 항상 `Manager Kim`이다. `Kim Bujang`을 혼용하지 않는다.

## 문화 설명 원칙
- `Gangnam`은 고유명사로 유지한다.
- 외국인 초견 구간의 첫 주요 노출에서는 짧게 의미를 풀어준다: `Gangnam, Seoul's status district`, `Seoul's status symbol`, `wealth, status, arrival`.
- 이후 반복 UI에서는 설명을 계속 늘이지 말고 `Gangnam` 또는 `Gangnam Dream`으로 돌아간다.
