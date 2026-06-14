extends RefCounted
class_name Roulette

# 베팅 타입 상수
const STRAIGHT = 0  # 한 숫자, 35:1
const RED     = 1   # 빨간색, 1:1
const BLACK   = 2   # 검은색, 1:1
const ODD     = 3   # 홀수, 1:1
const EVEN    = 4   # 짝수, 1:1
const LOW     = 5   # 1-18, 1:1
const HIGH    = 6   # 19-36, 1:1
const DOZEN_1 = 7   # 1-12, 2:1
const DOZEN_2 = 8   # 13-24, 2:1
const DOZEN_3 = 9   # 25-36, 2:1

# 유럽식 룰렛 빨간 숫자 (18개)
const RED_NUMBERS: Array = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]

# 유럽식 룰렛: 0~36, 총 37개 숫자 → 하우스엣지 1/37 ≈ 2.703%
func spin(rng: RandomNumberGenerator) -> int:
	return rng.randi_range(0, 36)

# 당첨 여부 반환
# chosen: STRAIGHT 베팅 시 선택한 숫자 (다른 베팅 타입에서는 무시)
func check_win(bet_type: int, chosen: int, result: int) -> bool:
	match bet_type:
		STRAIGHT:
			return result == chosen
		RED:
			return result in RED_NUMBERS
		BLACK:
			return result != 0 and result not in RED_NUMBERS
		ODD:
			return result != 0 and result % 2 == 1
		EVEN:
			return result != 0 and result % 2 == 0
		LOW:
			return result >= 1 and result <= 18
		HIGH:
			return result >= 19 and result <= 36
		DOZEN_1:
			return result >= 1 and result <= 12
		DOZEN_2:
			return result >= 13 and result <= 24
		DOZEN_3:
			return result >= 25 and result <= 36
	return false

# 순수 이익 배수 (원금 미포함)
# 예: STRAIGHT 당첨 시 베팅금 × 35를 추가로 받음
func payout_multiplier(bet_type: int) -> float:
	match bet_type:
		STRAIGHT:
			return 35.0
		RED, BLACK, ODD, EVEN, LOW, HIGH:
			return 1.0
		DOZEN_1, DOZEN_2, DOZEN_3:
			return 2.0
	return 0.0

# 숫자 색상 반환
func number_color(n: int) -> String:
	if n == 0:
		return "green"
	if n in RED_NUMBERS:
		return "red"
	return "black"
