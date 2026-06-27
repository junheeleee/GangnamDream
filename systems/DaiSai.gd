extends RefCounted
class_name DaiSai
## DaiSai — 다이사이/식보(Sic Bo) 수학 모델.
## 세 개의 6면체 주사위를 굴리고, 베팅 타입별 순배당을 계산한다.
## GameState 의존 없음. UI 씬에서 순수 모델로 사용한다.

const BET_BIG := 0
const BET_SMALL := 1
const BET_ODD := 2
const BET_EVEN := 3
const BET_SINGLE := 4
const BET_PAIR := 5
const BET_ANY_TRIPLE := 6
const BET_SPECIFIC_TRIPLE := 7
const BET_TOTAL := 8

# 총합 베팅 순배당. 원금 제외 배수다.
const TOTAL_PAYOUTS := {
	4: 60.0,
	5: 30.0,
	6: 17.0,
	7: 12.0,
	8: 8.0,
	9: 6.0,
	10: 6.0,
	11: 6.0,
	12: 6.0,
	13: 8.0,
	14: 12.0,
	15: 17.0,
	16: 30.0,
	17: 60.0,
}

static func roll(rng: RandomNumberGenerator) -> Array:
	return [
		rng.randi_range(1, 6),
		rng.randi_range(1, 6),
		rng.randi_range(1, 6),
	]

static func total(dice: Array) -> int:
	var sum := 0
	for die in dice:
		sum += int(die)
	return sum

static func is_triple(dice: Array) -> bool:
	return dice.size() >= 3 and int(dice[0]) == int(dice[1]) and int(dice[1]) == int(dice[2])

static func count_face(dice: Array, face: int) -> int:
	var c := 0
	for die in dice:
		if int(die) == face:
			c += 1
	return c

static func payout_multiplier(bet_type: int, selected: int, dice: Array) -> float:
	if dice.size() < 3:
		return 0.0

	var sum := total(dice)
	var triple := is_triple(dice)

	match bet_type:
		BET_BIG:
			return 1.0 if sum >= 11 and sum <= 17 and not triple else 0.0
		BET_SMALL:
			return 1.0 if sum >= 4 and sum <= 10 and not triple else 0.0
		BET_ODD:
			return 1.0 if sum % 2 == 1 and not triple else 0.0
		BET_EVEN:
			return 1.0 if sum % 2 == 0 and not triple else 0.0
		BET_SINGLE:
			var matches := count_face(dice, selected)
			return float(matches) if matches > 0 else 0.0
		BET_PAIR:
			return 8.0 if count_face(dice, selected) >= 2 else 0.0
		BET_ANY_TRIPLE:
			return 24.0 if triple else 0.0
		BET_SPECIFIC_TRIPLE:
			return 150.0 if triple and int(dice[0]) == selected else 0.0
		BET_TOTAL:
			return float(TOTAL_PAYOUTS.get(selected, 0.0)) if sum == selected else 0.0
	return 0.0

static func label_for_bet(bet_type: int, selected: int = -1) -> String:
	match bet_type:
		BET_BIG:
			return "BIG"
		BET_SMALL:
			return "SMALL"
		BET_ODD:
			return LocaleManager.ui("홀수", "ODD")
		BET_EVEN:
			return LocaleManager.ui("짝수", "EVEN")
		BET_SINGLE:
			return LocaleManager.ui("%d 싱글", "%d Single") % selected
		BET_PAIR:
			return LocaleManager.ui("%d 페어", "%d Pair") % selected
		BET_ANY_TRIPLE:
			return "ANY TRIPLE"
		BET_SPECIFIC_TRIPLE:
			return "%d%d%d" % [selected, selected, selected]
		BET_TOTAL:
			return LocaleManager.ui("합계 %d", "Total %d") % selected
	return LocaleManager.ui("베팅 없음", "No Bet")
