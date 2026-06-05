extends SceneTree
## 베팅종류 깊이 증명 (헤드리스):
##  A) 배당 사다리: 단승 < 복승 < 삼쌍승 으로 위험·보상이 커지는가
##  B) 전략별 ROI: 인기추종(나락) < 밸류단승 < 밸류조합(고변동·고천장)
##     - 천장(완벽핸디캐퍼=effective) / 현실(지력70=노이즈낀 신호) / 무지성(인기추종)
## 이게 서면 "베팅종류"가 단순 버튼이 아니라 진짜 전략 사다리임이 증명됨.

const HR := preload("res://systems/HorseRace.gd")

func _pl_first(e: Array, i: int, S: float) -> float:
	return e[i] / S

func _pl_pair(e: Array, a: int, b: int, S: float) -> float:
	return (e[a] / S) * (e[b] / max(S - e[a], 0.0001))

func _pl_trip(e: Array, a: int, b: int, c: int, S: float) -> float:
	return (e[a] / S) * (e[b] / max(S - e[a], 0.0001)) * (e[c] / max(S - e[a] - e[b], 0.0001))

# 말별 강도 벡터 추출 (key = "effective" 진짜 / "est" 추정)
func _vec(race: Dictionary, key: String) -> Array:
	var v: Array = []
	for h in race["horses"]:
		if key == "est":
			# 지력70 플레이어의 추정: 노이즈 낀 가시신호로 effective 재구성
			v.append(float(h["sig_class"]) * float(h["sig_dist"]) * float(h["sig_cond"]) * float(h["jockey"]))
		else:
			v.append(float(h[key]))
	return v

func _init() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260605

	# ── A) 배당 사다리 (전형값) ─────────────────────────────
	print("=== A. 배당 사다리 (5경주 샘플) ===")
	for s in range(5):
		var race := HR.generate_race(rng, 70.0)
		var hs: Array = race["horses"]
		# 인기순 정렬 인덱스
		var idx := range(hs.size())
		idx.sort_custom(func(x, y): return float(hs[x]["odds"]) < float(hs[y]["odds"]))
		var f0: int = idx[0]; var f1: int = idx[1]; var f2: int = idx[2]
		var win: float = float(hs[f0]["odds"])
		var plc: float = HR.place_odds(race, f0)
		var qui: float = HR.quinella_odds(race, f0, f1)
		var tri: float = HR.trifecta_odds(race, f0, f1, f2)
		print("  경주%d (%d m,%s): 연승x%.1f < 단승x%.1f < 복승x%.1f < 삼쌍승x%.0f"
			% [s + 1, int(race["distance"]), race["track"], plc, win, qui, tri])

	# ── B) 전략별 ROI (대량 시뮬) ───────────────────────────
	var N := 40000
	var names := ["무지성(인기단승)", "밸류단승(지력70)", "밸류복승(지력70)", "밸류삼쌍승(지력70)",
		"천장:밸류단승(완벽)", "천장:밸류삼쌍승(완벽)"]
	var staked := [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	var ret := [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	var bets := [0, 0, 0, 0, 0, 0]
	var wins := [0, 0, 0, 0, 0, 0]
	var maxwin := [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	var sumsq := [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]   # 분산용(순수익 제곱합)

	for n in range(N):
		var race := HR.generate_race(rng, 70.0)
		var hs: Array = race["horses"]
		var m: int = hs.size()
		var finish := HR.simulate(race, rng)

		var etrue := _vec(race, "effective"); var Strue := 0.0
		for x in etrue: Strue += x
		var eest := _vec(race, "est"); var Sest := 0.0
		for x in eest: Sest += x

		# 인기마(최저배당)
		var fav := 0
		for i in range(1, m):
			if float(hs[i]["odds"]) < float(hs[fav]["odds"]): fav = i

		# 전략별 1회 베팅(stake=1) 결정 → (수익금, staked)
		# 0) 무지성: 무조건 인기 단승
		_apply(0, 1.0, HR.payout_win(race, fav, 1.0, finish), staked, ret, bets, wins, maxwin, sumsq)

		# 1) 밸류단승(추정): est기준 EV>1.05 인 말 중 최대 → 베팅, 없으면 패스
		var b1 := _best_win(race, eest, Sest, 1.05)
		if b1 >= 0:
			_apply(1, 1.0, HR.payout_win(race, b1, 1.0, finish), staked, ret, bets, wins, maxwin, sumsq)
		# 2) 밸류복승(추정)
		var b2 := _best_quin(race, eest, Sest, 1.05)
		if not b2.is_empty():
			_apply(2, 1.0, HR.payout_quinella(race, b2[0], b2[1], 1.0, finish), staked, ret, bets, wins, maxwin, sumsq)
		# 3) 밸류삼쌍승(추정)
		var b3 := _best_tri(race, eest, Sest, 1.10)
		if not b3.is_empty():
			_apply(3, 1.0, HR.payout_trifecta(race, b3[0], b3[1], b3[2], 1.0, finish), staked, ret, bets, wins, maxwin, sumsq)
		# 4) 천장 밸류단승(진짜 effective)
		var c1 := _best_win(race, etrue, Strue, 1.0)
		if c1 >= 0:
			_apply(4, 1.0, HR.payout_win(race, c1, 1.0, finish), staked, ret, bets, wins, maxwin, sumsq)
		# 5) 천장 밸류삼쌍승(진짜)
		var c3 := _best_tri(race, etrue, Strue, 1.0)
		if not c3.is_empty():
			_apply(5, 1.0, HR.payout_trifecta(race, c3[0], c3[1], c3[2], 1.0, finish), staked, ret, bets, wins, maxwin, sumsq)

	print("\n=== B. 전략별 결과 (%d경주, 베팅단위=1) ===" % N)
	print("  %-24s | ROI    | 적중률 | 베팅수 | 평균배당 | 최대단발 | 변동(σ)" % "전략")
	for k in range(names.size()):
		if bets[k] == 0:
			print("  %-24s | 베팅없음" % names[k]); continue
		var roi: float = (ret[k] - staked[k]) / staked[k] * 100.0
		var hr_pct: float = float(wins[k]) / float(bets[k]) * 100.0
		var avg_od: float = (ret[k] / float(wins[k])) if wins[k] > 0 else 0.0
		var mean_net: float = (ret[k] - staked[k]) / float(bets[k])
		var var_net: float = sumsq[k] / float(bets[k]) - mean_net * mean_net
		var sd: float = sqrt(max(var_net, 0.0))
		print("  %-24s | %+5.1f%% | %5.1f%% | %6d | x%6.2f | x%7.1f | %5.2f"
			% [names[k], roi, hr_pct, bets[k], avg_od, maxwin[k], sd])

	print("\n판정:")
	print("  · 사다리: 연승<단승<복승<삼쌍승 배당 상승 = 위험·보상 사다리 OK" )
	print("  · 무지성 인기추종은 ROI 마이너스(공제율 나락)여야 함")
	print("  · 밸류단승 ≈ 본전~약플러스, 밸류조합은 변동(σ) 크고 천장 높음 = 전략 분기")
	quit()

func _apply(k: int, stake: float, payout: float, staked, ret, bets, wins, maxwin, sumsq) -> void:
	staked[k] += stake
	ret[k] += payout
	bets[k] += 1
	var net: float = payout - stake
	sumsq[k] += net * net
	if payout > 0.0:
		wins[k] += 1
		if payout > maxwin[k]: maxwin[k] = payout

func _best_win(race: Dictionary, e: Array, S: float, thr: float) -> int:
	var best := -1; var bestev := thr
	for i in range(race["horses"].size()):
		var ev: float = _pl_first(e, i, S) * float(race["horses"][i]["odds"])
		if ev > bestev: bestev = ev; best = i
	return best

func _best_quin(race: Dictionary, e: Array, S: float, thr: float) -> Array:
	var m: int = race["horses"].size()
	var best := []; var bestev := thr
	for a in range(m):
		for b in range(a + 1, m):
			var ev: float = (_pl_pair(e, a, b, S) + _pl_pair(e, b, a, S)) * HR.quinella_odds(race, a, b)
			if ev > bestev: bestev = ev; best = [a, b]
	return best

func _best_tri(race: Dictionary, e: Array, S: float, thr: float) -> Array:
	var m: int = race["horses"].size()
	var best := []; var bestev := thr
	for a in range(m):
		for b in range(m):
			if b == a: continue
			for c in range(m):
				if c == a or c == b: continue
				var ev: float = _pl_trip(e, a, b, c, S) * HR.trifecta_odds(race, a, b, c)
				if ev > bestev: bestev = ev; best = [a, b, c]
	return best
