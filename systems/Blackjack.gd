extends RefCounted
class_name Blackjack
## 블랙잭 수학 모델 — 6덱 슈, 딜러 소프트17 히트, 표준 미국식 규칙.
##
## 기본 전략을 따르면 하우스엣지 ~0.5% (가장 낮은 카지노 게임 중 하나)
## 감각에 의존하면 하우스엣지 2~4% → "공부가 EV를 만든다"는 것을 플레이로 체득.

const DECKS := 6

## 카드값. A는 1 또는 11 (hand_value가 결정)
static func card_value(card: int) -> int:
	var rank := card % 13  # 0=A, 1=2, ..., 9=10, 10=J, 11=Q, 12=K
	if rank == 0: return 11  # A 초기값 11
	if rank >= 9: return 10  # 10, J, Q, K = 10
	return rank + 1

## 핸드 값 (소프트 계산: A를 11로 쓰되 버스트 시 1로 전환)
static func hand_value(cards: Array) -> int:
	var total := 0
	var aces := 0
	for c in cards:
		var rank := c % 13
		if rank == 0:
			aces += 1
			total += 11
		elif rank >= 9:
			total += 10
		else:
			total += rank + 1
	while total > 21 and aces > 0:
		total -= 10
		aces -= 1
	return total

## 소프트 핸드 여부 (A가 11로 계산되고 있는지)
static func is_soft(cards: Array) -> bool:
	var total := 0
	var aces := 0
	for c in cards:
		var rank := c % 13
		if rank == 0:
			aces += 1; total += 11
		elif rank >= 9: total += 10
		else: total += rank + 1
	var soft := false
	while total > 21 and aces > 0:
		total -= 10; aces -= 1
	if aces > 0 and total <= 21: soft = true
	return soft

## 블랙잭 여부 (A + 10점 카드 정확히 2장)
static func is_blackjack(cards: Array) -> bool:
	if cards.size() != 2: return false
	return hand_value(cards) == 21

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

## 딜러 플레이 (소프트17 히트 규칙)
## shoe에서 카드를 뽑아 17+ 까지 채운다. hand를 직접 수정.
static func dealer_play(hand: Array, shoe: Array) -> void:
	while true:
		var v := hand_value(hand)
		if v > 17: break
		if v == 17 and not is_soft(hand): break
		if shoe.is_empty(): break
		hand.append(shoe.pop_front())

## 카드 문자열
static func card_str(card: int) -> String:
	const RANKS := ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
	const SUITS := ["♠", "♥", "♦", "♣"]
	return RANKS[card % 13] + SUITS[card / 13]

## 빨강 카드 (하트/다이아)
static func is_red(card: int) -> bool:
	return (card / 13) in [1, 2]

## 슈 잔여 비율
static func shoe_remaining_ratio(shoe: Array) -> float:
	return float(shoe.size()) / float(DECKS * 52)

## 기본 전략 힌트 (플레이어 핸드 + 딜러 업카드)
## 반환: "H"히트/"S"스탠드/"D"더블/"P"스플릿
static func basic_strategy(player: Array, dealer_up: int) -> String:
	var pv := hand_value(player)
	var dv := dealer_up % 13
	if dv == 0: dv = 11   # A
	elif dv >= 9: dv = 10
	else: dv = dv + 1

	# 스플릿 (같은 값 2장)
	if player.size() == 2:
		var r0 := player[0] % 13
		var r1 := player[1] % 13
		var same_val := (r0 >= 9 and r1 >= 9) or r0 == r1
		if same_val:
			if r0 == 0: return "P"           # AA → 항상 스플릿
			var sv := mini(r0 + 1, 10)
			if sv == 8: return "P"            # 88 → 항상 스플릿
			if sv == 9 and dv not in [7, 10, 11]: return "P"
			if sv in [2, 3, 6, 7] and dv <= 7: return "P"
			if sv == 4 and dv in [5, 6]: return "P"

	# 소프트 핸드
	if is_soft(player):
		if pv >= 19: return "S"
		if pv == 18:
			if dv in [2,3,4,5,6]: return "D" if player.size() == 2 else "S"
			if dv in [7, 8]: return "S"
			return "H"
		if pv <= 17:
			if dv in [5, 6]: return "D" if player.size() == 2 else "H"
			return "H"

	# 하드 핸드
	if pv >= 17: return "S"
	if pv >= 13 and dv in [2,3,4,5,6]: return "S"
	if pv == 12 and dv in [4,5,6]: return "S"
	if pv == 11: return "D" if player.size() == 2 else "H"
	if pv == 10 and dv <= 9: return "D" if player.size() == 2 else "H"
	if pv == 9 and dv in [3,4,5,6]: return "D" if player.size() == 2 else "H"
	return "H"
