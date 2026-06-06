extends SceneTree
## 경마 '세계' 증명:
##  A) 영속 로스터·전적 누적 — 같은 말이 재등장하며 전적이 쌓이는가
##  B) 정보 경제 — 팁 맹신은 -EV(함정+팁값), 안목 높아 신뢰도 간파 시 손실이 줄고
##     함정을 피하는가. 안목 낮으면(호구) 간파해도 함정에 걸리는가(정보 비대칭=스킬).

const HW := preload("res://systems/HorseWorld.gd")
const HR := preload("res://systems/HorseRace.gd")

func _init() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260605

	# ── A) 영속성·전적 누적 ──────────────────────────────────
	var world: Dictionary = {}
	HW.ensure(world, rng)
	for turn in range(40):
		var race := HW.make_card(world, rng, 60.0)
		var finish := HR.simulate(race, rng)
		HW.record(world, race, finish, turn)
	print("=== A. 영속 로스터/전적 (40 경주일 후) ===")
	var roster: Array = world["roster"]
	roster.sort_custom(func(a, b): return int(a["starts"]) > int(b["starts"]))
	for k in range(min(5, roster.size())):
		var r: Dictionary = roster[k]
		print("  %-5s 통산 %d전 %d승 (승률 %.0f%%)  최근:%s  선호 %dm/%s/%s" % [
			r["name"], int(r["starts"]), int(r["wins"]),
			(100.0 * float(r["wins"]) / max(int(r["starts"]), 1)),
			HW._recent_str(r["history"]), int(r["dist_pref"]),
			HW.TRACKS[int(r["cond_pref"])], HW.STYLE_NAMES[int(r["style"])]])

	# ── B) 정보 경제 (팁 진짜/가짜) ──────────────────────────
	var N := 40000
	var labels := ["팁 맹신(안목30)", "신뢰도≥0.6만(안목85·고수)",
		"신뢰도≥0.6만(안목30·호구)", "팁무시·밸류단승(안목85)"]
	var infos := [30.0, 85.0, 30.0, 85.0]
	var net := [0.0, 0.0, 0.0, 0.0]           # 순손익
	var risk := [0.0, 0.0, 0.0, 0.0]          # 투입(스테이크+팁값)
	var bets := [0, 0, 0, 0]
	var follow_true := [0, 0, 0, 0]           # 따라간 팁 중 진짜였던 횟수
	var edge_sum := [0.0, 0.0, 0.0, 0.0]      # 베팅 타깃의 trueP*odds 합(평균엣지용)
	var stake := 30000.0

	for n in range(N):
		for s in range(labels.size()):
			var race := HW.make_card(world, rng, infos[s])
			var finish := HR.simulate(race, rng)
			if s == 3:
				# 팁무시 밸류단승: effective 최댓값(밸류) 말에 단승 — 핸디캐핑 기준선
				var bi := _value_idx(race)
				var pay := HR.payout_win(race, bi, stake, finish)
				net[s] += pay - stake; risk[s] += stake; bets[s] += 1
				edge_sum[s] += _edge(race, bi)
				continue
			var tip := HW.gen_tip(race, rng, infos[s])
			risk[s] += float(tip["price"]); net[s] -= float(tip["price"])  # 팁값=듣는 비용
			var do_bet := true
			if s == 1 or s == 2:
				do_bet = float(tip["cred"]) >= 0.6
			if do_bet:
				var t: int = int(tip["target"])
				var pay := HR.payout_win(race, t, stake, finish)
				net[s] += pay - stake; risk[s] += stake; bets[s] += 1
				edge_sum[s] += _edge(race, t)
				if bool(tip["is_true"]): follow_true[s] += 1

	print("\n=== B. 정보 경제 (%d경주, 스테이크3만·팁값3천) ===" % N)
	print("  %-26s | ROI    | 베팅수 | 따라간팁중 진짜%% | 평균엣지" % "전략")
	for s in range(labels.size()):
		var roi: float = net[s] / max(risk[s], 1.0) * 100.0
		var truepct: float = (100.0 * float(follow_true[s]) / float(bets[s])) if (bets[s] > 0 and s < 3) else -1.0
		var tp_str: String = ("%5.0f%%" % truepct) if truepct >= 0 else "    -"
		var avg_edge: float = edge_sum[s] / max(bets[s], 1)
		print("  %-26s | %+5.1f%% | %6d | %s         | x%.2f" % [
			labels[s], roi, bets[s], tp_str, avg_edge])

	print("\n판정:")
	print("  · 팁 맹신(안목30) = ROI 마이너스 (절반은 함정 + 팁값)")
	print("  · 고수(안목85)는 따라간 팁 대부분 진짜 → 함정 회피, 손실 최소화")
	print("  · 호구(안목30)는 신뢰도가 노이즈 → 진짜 비율 ~50%, 함정에 걸림 = 정보 비대칭")
	print("  · 평균엣지 x>1.0 = +EV 타깃을 골랐다는 뜻 (고수>호구)")
	quit()

func _edge(race: Dictionary, i: int) -> float:
	var hs: Array = race["horses"]
	var s: float = 0.0
	for h in hs: s += float(h["effective"])
	return (float(hs[i]["effective"]) / s) * float(hs[i]["odds"])

# 현실적 핸디캐퍼: 진짜 effective(숨은 live 호조 포함)는 못 본다. 가시신호(★)로만 추정.
func _value_idx(race: Dictionary) -> int:
	var hs: Array = race["horses"]
	var s: float = 0.0
	var est: Array = []
	for h in hs:
		var e: float = float(h["sig_class"]) * float(h["jockey"]) * float(h["sig_dist"]) * float(h["sig_cond"])
		est.append(e); s += e
	var best: float = -1.0; var bi: int = 0
	for i in range(hs.size()):
		var ev: float = (float(est[i]) / s) * float(hs[i]["odds"])
		if ev > best: best = ev; bi = i
	return bi
