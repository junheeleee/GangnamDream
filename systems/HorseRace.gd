extends RefCounted
class_name HorseRace
## 경마 미니게임의 '수학적 뼈대' (순수 모델 — GameState 의존 없음, 헤드리스 테스트 가능).
##
## 핵심 설계:
##  - 말의 '진짜 강도(effective)'는 숨겨짐 → 레이스 결과를 결정.
##  - 가시 폼 신호(최근성적·기수·거리/마장 적성)는 effective의 노이즈 낀 단서.
##  - 배당(대중 추정)은 '화려한' 신호(기수·최근폼)에 쏠리고 '숨은' 적성을 저평가 → 밸류 발생.
##  - 정보력이 높으면 단서 노이즈↓ → 더 정확한 핸디캐핑.
## => "저평가된 말 찾기"가 스킬. 밸류 베팅 +EV, 인기마 추종 -EV.

const TAKE := 0.14   # 공제율 — 숙련+절제하면 이길 수 있되, 무지성·중독이면 나락
const NAMES := ["번개","질풍","흑운","천리마","불꽃","새벽별","강철","행운아","폭풍",
	"은하수","대박이","무쇠","칼바람","승리호","바람돌이","검은별"]

## 한 경주 생성. info_level 0~100 (지력/정보력) — 높을수록 가시 신호가 정확.
static func generate_race(rng: RandomNumberGenerator, info_level: float) -> Dictionary:
	var distances := [1200, 1400, 1600, 1800, 2000]
	var distance: int = distances[rng.randi() % distances.size()]
	var track: String = ["건조", "양호", "다습"][rng.randi() % 3]
	var n: int = rng.randi_range(5, 7)
	var names: Array = NAMES.duplicate()
	for i in range(names.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp = names[i]; names[i] = names[j]; names[j] = tmp

	var horses: Array = []
	for i in range(n):
		var base: float = rng.randf_range(0.55, 1.9)      # 클래스 (과거성적으로 가늠 가능)
		var dist_apt: float = rng.randf_range(0.78, 1.22) # 거리 적성 (숨은 강점 — 대중이 저평가)
		var cond_apt: float = rng.randf_range(0.82, 1.18) # 마장 적성 (숨은 강점)
		var jockey: float = rng.randf_range(0.85, 1.18)   # 기수 (관측 쉬움)
		# 이번 경주 진짜 강도
		var effective: float = base * dist_apt * cond_apt * jockey
		horses.append({
			"name": names[i], "effective": effective,    # effective 숨김
			"base": base, "dist_apt": dist_apt, "cond_apt": cond_apt, "jockey": jockey,
		})

	_compute_signals(horses, info_level, rng)
	_compute_odds(horses, rng)
	return {"distance": distance, "track": track, "horses": horses}

## 가시 신호 (★1~5). 클래스·기수는 비교적 잘 보이고(저노이즈),
## 적성(거리·마장)은 info_level에 따라 노이즈가 크게 갈린다 = 스킬·정보가 먹는 지점.
static func _compute_signals(horses: Array, info_level: float, rng: RandomNumberGenerator) -> void:
	var apt_noise: float = lerpf(0.26, 0.04, clampf(info_level / 100.0, 0.0, 1.0))
	for h in horses:
		# 클래스 신호: 과거 성적 — 모두에게 비교적 잘 보임 (작은 노이즈)
		var cl: float = clampf(float(h["base"]) * rng.randf_range(0.90, 1.10), 0.5, 2.0)
		h["sig_class"] = cl
		h["star_class"] = clampi(roundi((cl - 0.55) / 1.35 * 5.0), 1, 5)
		# 적성 신호: info_level이 정확도를 좌우
		var da: float = clampf(float(h["dist_apt"]) + rng.randf_range(-apt_noise, apt_noise), 0.6, 1.4)
		var ca: float = clampf(float(h["cond_apt"]) + rng.randf_range(-apt_noise, apt_noise), 0.6, 1.4)
		h["sig_dist"] = da
		h["sig_cond"] = ca
		h["star_dist"] = clampi(roundi((da - 0.6) / 0.8 * 5.0), 1, 5)
		h["star_cond"] = clampi(roundi((ca - 0.6) / 0.8 * 5.0), 1, 5)
		h["star_jockey"] = clampi(roundi((float(h["jockey"]) - 0.85) / 0.33 * 5.0), 1, 5)

## 배당 — 대중 추정. 클래스·기수는 잘 보지만 적성(거리·마장)을 ^0.35만 반영(저평가) → 밸류 발생.
static func _compute_odds(horses: Array, rng: RandomNumberGenerator) -> void:
	var pub: Array = []
	var sum_pub: float = 0.0
	for h in horses:
		var subtle: float = float(h["dist_apt"]) * float(h["cond_apt"])
		# 대중은 클래스·기수에 쏠리고(기수 과대), 적성은 ^0.22만 반영(크게 저평가) → 밸류 폭↑
		var public_score: float = float(h["base"]) * pow(float(h["jockey"]), 1.35) \
			* pow(subtle, 0.22) * rng.randf_range(0.90, 1.12)
		pub.append(public_score)
		sum_pub += public_score
	for i in range(horses.size()):
		var implied: float = pub[i] / max(sum_pub, 0.001)
		horses[i]["odds"] = (1.0 - TAKE) / max(implied, 0.001)   # 배당(단승)

## 레이스 시뮬 — effective 가중 순위 추첨(Plackett-Luce). 반환: 착순(말 dict 배열).
static func simulate(race: Dictionary, rng: RandomNumberGenerator) -> Array:
	var pool: Array = race["horses"].duplicate()
	var order: Array = []
	while not pool.is_empty():
		var total: float = 0.0
		for h in pool:
			total += float(h["effective"])
		var r: float = rng.randf() * total
		var acc: float = 0.0
		var picked: int = pool.size() - 1
		for i in range(pool.size()):
			acc += float(pool[i]["effective"])
			if r <= acc:
				picked = i
				break
		order.append(pool[picked])
		pool.remove_at(picked)
	return order

## 단승 정산. bet_idx = 베팅한 말 인덱스, finish = 착순.
static func payout_win(race: Dictionary, bet_idx: int, stake: float, finish: Array) -> float:
	if finish.is_empty():
		return 0.0
	var bet_horse = race["horses"][bet_idx]
	if finish[0] == bet_horse:
		return stake * float(bet_horse["odds"])
	return 0.0
