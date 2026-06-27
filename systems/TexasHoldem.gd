extends RefCounted
class_name TexasHoldem
## 텍사스 홀덤 수학 모델 — 순수 로직, GameState 의존 없음, 헤드리스 테스트 가능.
##
## 핵심 설계:
##  - 표준 52장 덱, 셔플, 패 평가 (베스트 5장)
##  - 핸드 강도(0-1) 추정 → AI 베팅 결정의 기반
##  - AI 3등급 (tight/balanced/loose) — 성향·운에 따라 행동 다름
##  => "팟 오즈 계산 + 핸드 리딩"이 스킬. 무지성 콜/폴드 → -EV.

const SUITS := ["♠","♥","♦","♣"]
const VAL_NAMES := ["","","2","3","4","5","6","7","8","9","10","J","Q","K","A"]

## ── 덱 ──────────────────────────────────────────────────────────
static func new_deck() -> Array:
	var deck: Array = []
	for s in range(4):
		for v in range(2, 15):
			deck.append({"suit": s, "value": v})
	return deck

static func shuffle(deck: Array, rng: RandomNumberGenerator) -> void:
	for i in range(deck.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp = deck[i]; deck[i] = deck[j]; deck[j] = tmp

## ── 카드 표시 ────────────────────────────────────────────────────
static func card_str(c: Dictionary) -> String:
	return VAL_NAMES[int(c["value"])] + SUITS[int(c["suit"])]

static func card_color(c: Dictionary) -> String:
	return "#e85d5d" if int(c["suit"]) in [1, 2] else "#e8eaf0"  # 하트·다이아 빨강

## ── 핸드 평가 ────────────────────────────────────────────────────
## best_hand(cards: 5~7장) → [rank, kicker1, kicker2, ...]
## rank: 0=하이카드, 1=원페어, 2=투페어, 3=트리플, 4=스트레이트,
##       5=플러시, 6=풀하우스, 7=포카드, 8=스트레이트플러시
static func best_hand(cards: Array) -> Array:
	if cards.size() <= 5:
		return _eval5(cards)
	var best: Array = [0]
	var n := cards.size()
	for i in range(n - 4):
		for j in range(i + 1, n - 3):
			for k in range(j + 1, n - 2):
				for l in range(k + 1, n - 1):
					for m in range(l + 1, n):
						var h := [cards[i], cards[j], cards[k], cards[l], cards[m]]
						var ev := _eval5(h)
						if ev > best:
							best = ev
	return best

static func rank_name(rank: int) -> String:
	match rank:
		0: return LocaleManager.ui("하이카드", "High Card")
		1: return LocaleManager.ui("원페어", "One Pair")
		2: return LocaleManager.ui("투페어", "Two Pair")
		3: return LocaleManager.ui("트리플", "Three of a Kind")
		4: return LocaleManager.ui("스트레이트", "Straight")
		5: return LocaleManager.ui("플러시", "Flush")
		6: return LocaleManager.ui("풀하우스", "Full House")
		7: return LocaleManager.ui("포카드", "Four of a Kind")
		8: return LocaleManager.ui("스트레이트 플러시", "Straight Flush")
	return "???"

static func _eval5(cards: Array) -> Array:
	var vals: Array = []
	var suits: Array = []
	for c in cards:
		vals.append(int(c["value"]))
		suits.append(int(c["suit"]))

	var is_flush: bool = (suits.count(suits[0]) == 5)
	var str_high: int = _straight_high(vals)

	# 카운트 테이블
	var cnt: Dictionary = {}
	for v in vals:
		cnt[v] = cnt.get(v, 0) + 1

	# (count, value) 내림차순 정렬
	var groups: Array = []
	for v in cnt:
		groups.append([cnt[v], v])
	groups.sort_custom(func(a, b):
		if a[0] != b[0]: return a[0] > b[0]
		return a[1] > b[1])

	var kickers: Array = []
	for g in groups:
		kickers.append(g[1])

	var rank: int = 0
	match groups[0][0]:
		4: rank = 7
		3: rank = 6 if groups[1][0] == 2 else 3
		2: rank = 2 if groups[1][0] == 2 else 1
		_: rank = 0

	if is_flush and str_high > 0:
		return [8, str_high]
	if is_flush:
		vals.sort(); vals.reverse()
		return [5] + vals
	if str_high > 0:
		return [4, str_high]
	return [rank] + kickers

## 스트레이트 최고 카드 반환 (없으면 0). A-low(5-high wheel) 지원.
static func _straight_high(vals: Array) -> int:
	var uniq: Array = []
	var seen: Dictionary = {}
	for v in vals:
		if not seen.has(v):
			seen[v] = true
			uniq.append(v)
	uniq.sort()
	# A-low: A-2-3-4-5
	if uniq.has(14) and uniq.has(2) and uniq.has(3) and uniq.has(4) and uniq.has(5):
		return 5
	for start in range(uniq.size() - 4):
		if uniq[start + 4] - uniq[start] == 4 and uniq.slice(start, start + 5).size() == 5:
			# verify all 5 unique
			var five: Array = uniq.slice(start, start + 5)
			var ok := true
			for fi in range(4):
				if five[fi + 1] - five[fi] != 1:
					ok = false; break
			if ok:
				return five[4]
	return 0

## ── 핸드 강도 추정 (0.0~1.0) ───────────────────────────────────
## hole 2장 + community 0~5장 → 현재 핸드 강도
static func hand_strength(hole: Array, community: Array) -> float:
	if community.is_empty():
		# 프리플랍: 홀 카드 휴리스틱
		var h0: int = hole[0]["value"]
		var h1: int = hole[1]["value"]
		var hi := maxi(h0, h1)
		var lo := mini(h0, h1)
		var suited: bool = hole[0]["suit"] == hole[1]["suit"]
		var paired: bool = h0 == h1
		var connected: bool = abs(h0 - h1) <= 2
		var score := (float(hi + lo) - 4.0) / 24.0   # 범위 맞춤
		if paired:   score += 0.25
		if suited:   score += 0.06
		if connected: score += 0.05
		return clampf(score, 0.0, 1.0)

	# 포스트플랍: 실제 핸드 랭크
	var all_cards: Array = hole + community
	var hand := best_hand(all_cards)
	var rank_score := float(hand[0]) / 8.0
	var kicker_bonus := float(hand[1] if hand.size() > 1 else 2) / 140.0
	return clampf(rank_score * 0.88 + kicker_bonus + 0.04, 0.0, 1.0)

## ── AI 행동 결정 ──────────────────────────────────────────────────
## aggression 0.0(tight)~1.0(loose/aggressive)
## → {"action": "fold"/"check"/"call"/"raise", "amount": int}
static func ai_decide(hole: Array, community: Array, pot: int, to_call: int,
		stack: int, aggression: float, rng: RandomNumberGenerator) -> Dictionary:
	var strength := hand_strength(hole, community)
	# 약간의 노이즈 — AI도 항상 완벽하지 않음
	var adj := strength + rng.randf_range(-0.09, 0.09)
	# 블러프
	if rng.randf() < aggression * 0.12:
		adj = maxf(adj, 0.55)
	adj = clampf(adj, 0.0, 1.0)

	var min_raise := mini(maxi(to_call * 2, 10_000), stack)

	if to_call == 0:
		if adj > 0.55 + aggression * 0.12:
			var raise_sz := mini(int(float(pot) * (0.4 + aggression * 0.4)), stack)
			raise_sz = maxi(raise_sz, min_raise)
			return {"action": "raise", "amount": raise_sz}
		return {"action": "check", "amount": 0}
	else:
		var pot_odds := float(to_call) / float(maxi(pot + to_call, 1))
		var fold_thr := pot_odds + 0.28 - aggression * 0.18
		if adj < fold_thr:
			return {"action": "fold", "amount": 0}
		if adj > 0.68 + aggression * 0.10:
			var raise_sz := mini(int(float(pot) * (0.6 + aggression * 0.4) + float(to_call)), stack)
			raise_sz = maxi(raise_sz, to_call + min_raise)
			return {"action": "raise", "amount": raise_sz}
		return {"action": "call", "amount": to_call}
