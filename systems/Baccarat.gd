extends RefCounted
class_name Baccarat
## 바카라 수학 모델 — 6덱 슈, 표준 드로우 규칙, GameState 의존 없음.
##
## 배당: 플레이어 1:1 / 뱅커 0.95:1(5% 커미션) / 타이 8:1 / 페어 11:1
## 하우스엣지: 플레이어 1.24% / 뱅커 1.06% / 타이 14.36%
## => "타이만 피하면 충분히 학습 가능한 베팅 게임"
##    뱅커에 꾸준히 걸면 가장 낮은 EV 손실.
##    스트릭·패턴 읽기 → 도박사의 오류 함정.

const DECKS := 6

## 카드값: A=1, 2-9=숫자, 10/J/Q/K=0
static func card_value(card: int) -> int:
	return mini((card % 13) + 1, 10) % 10

static func hand_value(cards: Array) -> int:
	var total := 0
	for c in cards:
		total += card_value(c)
	return total % 10

## 6덱 슈 생성 & 셔플
static func new_shoe(rng: RandomNumberGenerator) -> Array:
	var shoe: Array = []
	for _d in range(DECKS):
		for c in range(52):
			shoe.append(c)
	for i in range(shoe.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t = shoe[i]; shoe[i] = shoe[j]; shoe[j] = t
	return shoe

## 한 게임 처리 (shoe 배열을 직접 수정 — pop_front 사용)
## 반환: {player, banker, player_val, banker_val, result,
##        player_natural, banker_natural, p_pair, b_pair}
static func play(shoe: Array) -> Dictionary:
	if shoe.size() < 6:
		return {}

	# 딜 순서: 플1→뱅1→플2→뱅2
	var p: Array = [shoe.pop_front(), shoe.pop_front()]
	var b: Array = [shoe.pop_front(), shoe.pop_front()]

	var pv := hand_value(p)
	var bv := hand_value(b)

	var p_nat := pv >= 8
	var b_nat := bv >= 8

	if not (p_nat or b_nat):
		# 플레이어 드로우: 0~5
		if pv <= 5:
			p.append(shoe.pop_front())
			pv = hand_value(p)

		# 뱅커 드로우 규칙
		var drew_p: bool = p.size() == 3
		if not drew_p:
			# 플레이어 스탠드 → 뱅커 0~5에서 드로우
			if bv <= 5:
				b.append(shoe.pop_front())
				bv = hand_value(b)
		else:
			var p3v: int = card_value(p[2])
			var draw: bool = false
			match bv:
				0, 1, 2: draw = true
				3:        draw = p3v != 8
				4:        draw = p3v in [2, 3, 4, 5, 6, 7]
				5:        draw = p3v in [4, 5, 6, 7]
				6:        draw = p3v in [6, 7]
				7:        draw = false
				_:        draw = false
			if draw:
				b.append(shoe.pop_front())
				bv = hand_value(b)

	var result: String
	if   pv > bv: result = "player"
	elif bv > pv: result = "banker"
	else:         result = "tie"

	return {
		"player": p, "banker": b,
		"player_val": pv, "banker_val": bv,
		"result": result,
		"player_natural": p_nat,
		"banker_natural": b_nat,
		"p_pair": (p[0] % 13) == (p[1] % 13),
		"b_pair": (b[0] % 13) == (b[1] % 13),
	}

## 카드 문자열
static func card_str(card: int) -> String:
	const RANKS := ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
	const SUITS := ["♠", "♥", "♦", "♣"]
	return RANKS[card % 13] + SUITS[card / 13]

## 슈에 남은 덱 비율 (컷카드 판단)
static func shoe_remaining_ratio(shoe: Array) -> float:
	return float(shoe.size()) / float(DECKS * 52)
