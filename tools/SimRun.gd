extends Node
## 척추 증명 — 헤드리스 240주 완주 시뮬레이터.
## 실제 GameState 경제(apply_monthly_pressure/_resolve_opportunity/check_game_over/
## advance_calendar)를 정책 봇으로 구동해: ①루프가 항상 끝나는가(데드락/크래시)
## ②실패 경제가 공정한가 ③30억(승리)이 도달 가능하되 적절히 어려운가 를 검증.
## 주의: 이벤트(스탯 노이즈)·정밀 AP는 미모델. 급여=고정, 휴식=대표값으로 생존 유지.

const OPPS := [
	# 부동산 신중 (상철 conservative, buffed) — EV +57%/stake
	{"stake_ratio":0.30,"success_rate":0.44,"win_multiplier":2.0,"loss_ratio":0.55,"luck_factor":0.0015},
	# 부동산 올인 (상철 all-in, buffed) — EV +116%/stake
	{"stake_ratio":0.70,"success_rate":0.42,"win_multiplier":2.8,"loss_ratio":0.55,"luck_factor":0.0015},
	# 분양권 올인 (지연, buffed) — EV +105%/stake
	{"stake_ratio":0.80,"success_rate":0.38,"win_multiplier":4.0,"loss_ratio":0.75,"luck_factor":0.0015},
	# 공모주 (mid-game IPO, 새 이벤트) — EV +88%/stake
	{"stake_ratio":0.60,"success_rate":0.36,"win_multiplier":3.5,"loss_ratio":0.60,"luck_factor":0.0015},
]
# 재개발 올인: 고자산(>200M) 전용, mode 4에서 드물게 활성화
const OPP_MEGA := {"stake_ratio":0.65,"success_rate":0.40,"win_multiplier":7.0,"loss_ratio":0.70,"luck_factor":0.0015}
const SALARY := 2_240_000.0   # 중소기업 사무직(중간값)
const CASH_CHECKPOINTS := [24, 48, 240]
const CASH_CHECKPOINT_EXPECTED := {
	24: 10_040_000.0,
	48: 19_580_000.0,
	240: 95_900_000.0,
}
const ISOLATED_RUN_ENV := "GANGNAM_SIMRUN_ISOLATED"
var _eid := ""
var _cash_invariant_failures := 0
var _cash_checkpoint_hits := {24: 0, 48: 0, 240: 0}
var _cash_probe_values := {}

func _ready() -> void:
	# finish_run() records metaprogression. Refuse local execution unless the
	# caller explicitly placed HOME in a disposable sandbox; CI runners are
	# already ephemeral. This prevents a balance probe from touching a player's
	# real title/ending history.
	if OS.get_environment("CI").strip_edges().to_lower() != "true" \
			and OS.get_environment(ISOLATED_RUN_ENV) != "1":
		push_error(
			"SimRun requires an isolated HOME. Set %s=1 only with a disposable HOME."
			% ISOLATED_RUN_ENV)
		get_tree().quit(2)
		return
	_prepare_clean_meta()
	GameState.game_over.connect(func(e): _eid = str(e))
	var names := ["①무직 방치", "②성실 직장(무베팅)", "③현실 혼합(가끔 베팅)", "④공격 올인"]
	print("=== 척추 증명: 240주 완주 시뮬 (정책별 3000런) ===")
	_run_cash_checkpoint_probe()
	for mode in range(names.size()):
		_run_policy(names[mode], mode, 3000)
	for checkpoint in CASH_CHECKPOINTS:
		if int(_cash_checkpoint_hits.get(checkpoint, 0)) <= 0:
			_cash_invariant_failures += 1
			push_error("SimRun cash checkpoint was never reached: Week %d" % checkpoint)
		var actual := float(_cash_probe_values.get(checkpoint, NAN))
		var expected := float(CASH_CHECKPOINT_EXPECTED[checkpoint])
		if actual != expected:
			_cash_invariant_failures += 1
			push_error(
				"SimRun cash checkpoint drift at Week %d: expected=%s actual=%s"
				% [checkpoint, str(expected), str(actual)])
	if _cash_invariant_failures > 0:
		get_tree().quit(1)
		return
	print(
		"SIMRUN_CASH_INTEGRITY_OK checkpoints=24/48/240 values=%s unit=whole_won"
		% str(_cash_probe_values))
	get_tree().quit(0)

func _run_cash_checkpoint_probe() -> void:
	seed(84)
	_prepare_clean_meta()
	GameState.start_new_game()
	GameState.monthly_income = SALARY
	GameState.current_job = {"name": "사무직", "base_salary": SALARY}
	for at_week in range(1, 241):
		# Keep the probe alive without inventing an economy outcome. Alternating
		# half-won transactions exercise both signed tie boundaries over five years.
		GameState.health = 100
		GameState.mental = 100
		GameState.add_money(0.5 if at_week % 2 == 1 else -0.5)
		if GameState.week_of_month == 4:
			GameState.apply_monthly_pressure()
		_record_cash_checkpoint(at_week)
		if at_week < 240:
			GameState.advance_calendar()

func _run_policy(pname: String, mode: int, runs: int) -> void:
	var endings := {}
	var assets := []
	var reached30 := 0
	var stuck := 0           # 64턴 안에 종료 안 된 런(데드락 의심)
	var crash := 0
	for r in range(runs):
		seed(r * 7919 + mode * 131)
		_prepare_clean_meta()
		GameState.start_new_game()
		_eid = ""
		var employed := false
		var guard := 0
		while not GameState.is_game_over and GameState.turn <= 244:
			guard += 1
			if guard > 260: crash += 1; break
			var t: int = GameState.turn
			# 생존 유지: 위험하면 이번 달은 휴식(대표값)
			if GameState.mental <= 35:
				GameState.modify_stat("mental", 10)
				GameState.modify_stat("health", 5)
				GameState.modify_hidden_stat("stress", -20)
			else:
				# 취업 정책
				if mode >= 1 and not employed and t >= 2:
					GameState.monthly_income = SALARY
					GameState.current_job = {"name":"사무직","base_salary":SALARY}
					employed = true
				# 베팅 정책
				if mode == 2 and employed and GameState.money > 3_000_000.0 and randf() < 0.25:
					GameState._resolve_opportunity(OPPS[randi() % OPPS.size()])
				elif mode == 3 and employed and GameState.money > 1_000_000.0 and randf() < 0.6:
					# 고자산 시 재개발 메가베팅 우선 (실제 게임 inv_redev_zone_tip 반영)
					if GameState.money > 200_000_000.0 and t >= 28 and randf() < 0.5:
						GameState._resolve_opportunity(OPP_MEGA)
					else:
						GameState._resolve_opportunity(OPPS[randi() % OPPS.size()])
			# 월말
			if GameState.turn <= 3: GameState.add_money(300_000.0)
			GameState.apply_monthly_pressure()
			_record_cash_checkpoint(t)
			if GameState.is_game_over: break
			GameState.advance_calendar()
		if not GameState.is_game_over:
			stuck += 1
			GameState.age = 38
			GameState.check_game_over()
		var a: float = GameState.get_total_asset_value()
		assets.append(a)
		if a >= 3_000_000_000.0: reached30 += 1
		var k := _eid if _eid != "" else "(미종료)"
		endings[k] = int(endings.get(k, 0)) + 1
	_report(pname, runs, endings, assets, reached30, stuck, crash)

func _prepare_clean_meta() -> void:
	# A simulator run is a first-run economy sample. Resetting every policy run
	# also prevents earlier simulated endings from changing later NG+ routing.
	MetaProgression.data = DataRegistry.default_meta.duplicate(true)
	MetaProgression.set("_new_this_run", {"achievements": []})

func _record_cash_checkpoint(at_week: int) -> void:
	if at_week not in CASH_CHECKPOINTS:
		return
	_cash_checkpoint_hits[at_week] = int(_cash_checkpoint_hits.get(at_week, 0)) + 1
	var serialized_cash := float(GameState.serialize().get("money", NAN))
	if not _cash_probe_values.has(at_week):
		_cash_probe_values[at_week] = serialized_cash
	var live_cash := float(GameState.money)
	if is_finite(live_cash) and live_cash == floor(live_cash) \
			and is_finite(serialized_cash) and serialized_cash == floor(serialized_cash):
		return
	_cash_invariant_failures += 1
	if _cash_invariant_failures <= 8:
		push_error(
			"SimRun fractional cash at Week %d: live=%s serialized=%s"
			% [at_week, str(live_cash), str(serialized_cash)])

func _report(pname, runs, endings, assets, reached30, stuck, crash) -> void:
	assets.sort()
	var med = assets[int(runs/2)]
	var p90 = assets[int(runs*0.9)]
	var mx = assets[runs-1]
	print("\n[%s]  런 %d" % [pname, runs])
	print("  완주(종료): %d/%d  | 데드락의심: %d | 크래시(가드): %d" % [runs - stuck, runs, stuck, crash])
	print("  자산 중앙값 %s | p90 %s | 최대 %s | 30억도달 %d (%.1f%%)" % [
		_won(med), _won(p90), _won(mx), reached30, 100.0*reached30/runs])
	var keys = endings.keys()
	keys.sort_custom(func(a,b): return endings[a] > endings[b])
	var line := "  엔딩: "
	for k in keys:
		line += "%s %d(%.0f%%)  " % [k, endings[k], 100.0*endings[k]/runs]
	print(line)

func _won(v: float) -> String:
	if abs(v) >= 100_000_000: return "%.1f억" % (v/100_000_000.0)
	if abs(v) >= 10_000: return "%.0f만" % (v/10_000.0)
	return "%.0f" % v
