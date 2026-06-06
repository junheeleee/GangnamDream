extends Node
## 척추 증명 — 헤드리스 60턴 완주 시뮬레이터.
## 실제 GameState 경제(apply_monthly_pressure/_resolve_opportunity/check_game_over/
## advance_calendar)를 정책 봇으로 구동해: ①루프가 항상 끝나는가(데드락/크래시)
## ②실패 경제가 공정한가 ③30억(승리)이 도달 가능하되 적절히 어려운가 를 검증.
## 주의: 이벤트(스탯 노이즈)·정밀 AP는 미모델. 급여=고정, 휴식=대표값으로 생존 유지.

const OPPS := [
	{"stake_ratio":0.70,"success_rate":0.62,"win_multiplier":2.4,"loss_ratio":0.45,"luck_factor":0.0015},
	{"stake_ratio":0.80,"success_rate":0.46,"win_multiplier":2.6,"loss_ratio":1.00,"luck_factor":0.0015},
	{"stake_ratio":0.85,"success_rate":0.40,"win_multiplier":2.6,"loss_ratio":1.00,"luck_factor":0.0015},
	{"stake_ratio":0.70,"success_rate":0.72,"win_multiplier":1.6,"loss_ratio":0.45,"luck_factor":0.0015},
]
const SALARY := 2_240_000.0   # 중소기업 사무직(중간값)
var _eid := ""

func _ready() -> void:
	GameState.game_over.connect(func(e): _eid = str(e))
	var names := ["①무직 방치", "②성실 직장(무베팅)", "③현실 혼합(가끔 베팅)", "④공격 올인"]
	print("=== 척추 증명: 60턴 완주 시뮬 (정책별 3000런) ===")
	for mode in range(names.size()):
		_run_policy(names[mode], mode, 3000)
	get_tree().quit(0)

func _run_policy(pname: String, mode: int, runs: int) -> void:
	var endings := {}
	var assets := []
	var reached30 := 0
	var stuck := 0           # 64턴 안에 종료 안 된 런(데드락 의심)
	var crash := 0
	for r in range(runs):
		seed(r * 7919 + mode * 131)
		GameState.start_new_game()
		_eid = ""
		var employed := false
		var guard := 0
		while not GameState.is_game_over and GameState.turn <= 64:
			guard += 1
			if guard > 300: crash += 1; break
			var t: int = GameState.turn
			# 생존 유지: 위험하면 이번 달은 휴식(대표값)
			if GameState.mental <= 30 or GameState.stress >= 58:
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
					GameState._resolve_opportunity(OPPS[randi() % OPPS.size()])
			# 월말
			if GameState.turn <= 3: GameState.add_money(300_000.0)
			GameState.apply_monthly_pressure()
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
