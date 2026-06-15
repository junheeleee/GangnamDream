extends RefCounted
class_name BigWheel
## 빅식스 휠(Big Six Wheel) 수학 모델 — 54칸 표준 카지노 빅휠.
## GameState 의존 없음. 순수 정적 함수로 구성.
##
## 칸 구성:
##   1배(빨강)  : 24칸  HE 11.1%
##   2배(파랑)  : 15칸  HE 16.7%
##   5배(초록)  : 7칸   HE 22.2%
##   10배(주황) : 4칸   HE 18.5%
##   20배(보라) : 2칸   HE 22.2%
##   조커(금색) : 2칸   HE 14.8%  45:1 배당
## 합계: 54칸

# 세그먼트 인덱스 상수
const SEGMENT_1      := 0
const SEGMENT_2      := 1
const SEGMENT_5      := 2
const SEGMENT_10     := 3
const SEGMENT_20     := 4
const SEGMENT_JOKER  := 5

# 각 세그먼트의 칸 수 (합=54)
const SEGMENT_SLOTS: Array  = [24, 15, 7, 4, 2, 2]

# 순 배당 배수 (베팅 원금 제외, 즉 net payout)
const SEGMENT_PAYOUT: Array = [1.0, 2.0, 5.0, 10.0, 20.0, 45.0]

# 표시 레이블
const SEGMENT_LABELS: Array = ["1", "2", "5", "10", "20", "🃏"]

# 세그먼트별 색상 (hex)
const SEGMENT_COLORS: Array = [
	"#e74c3c",   # 1  — 빨강
	"#3498db",   # 2  — 파랑
	"#2ecc71",   # 5  — 초록
	"#f39c12",   # 10 — 주황
	"#9b59b6",   # 20 — 보라
	"#f1c40f",   # 조커 — 금색
]

## 휠을 돌려 세그먼트 인덱스(0~5)를 반환한다.
## 총 54칸 기준 가중 확률.
static func spin(rng: RandomNumberGenerator) -> int:
	var slot: int = rng.randi_range(0, total_slots() - 1)
	var cumulative: int = 0
	for i in range(SEGMENT_SLOTS.size()):
		cumulative += int(SEGMENT_SLOTS[i])
		if slot < cumulative:
			return i
	return SEGMENT_SLOTS.size() - 1

## 순 배당 배수 반환 (원금 제외).
## 예: 1칸 → 1.0 (즉 원금 포함 수익은 베팅 * 2)
static func payout(segment: int) -> float:
	if segment < 0 or segment >= SEGMENT_PAYOUT.size():
		return 0.0
	return float(SEGMENT_PAYOUT[segment])

## 표시 레이블 반환 ("1"/"2"/"5"/"10"/"20"/"🃏")
static func label(segment: int) -> String:
	if segment < 0 or segment >= SEGMENT_LABELS.size():
		return "?"
	return str(SEGMENT_LABELS[segment])

## 세그먼트 색상 hex 문자열 반환
static func color(segment: int) -> String:
	if segment < 0 or segment >= SEGMENT_COLORS.size():
		return "#ffffff"
	return str(SEGMENT_COLORS[segment])

## 이론 하우스엣지 반환 (소수, 예: 0.111 = 11.1%)
## HE = 1 - (slots / total) * (payout + 1)
static func house_edge(segment: int) -> float:
	if segment < 0 or segment >= SEGMENT_SLOTS.size():
		return 1.0
	var slots: float = float(int(SEGMENT_SLOTS[segment]))
	var total: float = float(total_slots())
	var pay: float   = float(SEGMENT_PAYOUT[segment])
	# EV per unit bet = (slots/total) * (pay + 1) - 1
	# HE = -EV
	return 1.0 - (slots / total) * (pay + 1.0)

## 총 슬롯 수 반환 (= 54)
static func total_slots() -> int:
	var t: int = 0
	for s in SEGMENT_SLOTS:
		t += int(s)
	return t
