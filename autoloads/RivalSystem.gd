extends Node
## 라이벌 캐릭터 시스템
## 플레이어와 같은 처지에서 시작해 매달 독립적으로 성장.
## 비교 압박감과 경쟁 서사를 제공.

signal rival_message(message: String, color: String)

const RIVAL_NAMES := ["박재원", "이수진", "김태양", "최지혜", "오민석", "정하린"]
const HOUSING_DATA := GameState.HOUSING_DATA

var rival: Dictionary = {}
var _initialized: bool = false

func _ready():
	GameState.run_started.connect(_on_run_started)
	GameState.turn_advanced.connect(_on_turn_advanced)

func _on_run_started():
	_init_rival()

func _init_rival():
	rival = {
		"name": RIVAL_NAMES[randi() % RIVAL_NAMES.size()],
		"age": 33,
		"housing": "gosiwon",
		"job_name": "무직",
		"monthly_income": 0.0,
		"total_assets": 500_000.0,
		"intelligence": randi_range(38, 62),
		"social_skill": randi_range(33, 58),
		"investment_skill": randi_range(8, 22),
		"luck": randi_range(35, 65),
		"turn_first_job": -1,
		"turn_first_million": -1,
		"narrative_milestones": {},
	}
	_initialized = true

func _on_turn_advanced(turn: int):
	if not _initialized or rival.is_empty():
		return
	rival["age"] = GameState.age
	_process_rival(turn)

func _process_rival(turn: int):
	var r: Dictionary = rival

	# 턴 2: 라이벌 첫 소개
	if turn == 2:
		rival_message.emit(
			"👀 라이벌 등장  —  %s, %d세, 고시원.\n같은 출발선에서 시작했다. 누가 먼저 강남에 닿을까?" % [r["name"], r["age"]],
			"#a78bfa"
		)

	# 취업 판정
	if r["job_name"] == "무직":
		var hire_chance: float = 0.35 + float(r["intelligence"]) * 0.004
		if randf() < hire_chance:
			_rival_get_job(turn)
	else:
		# 이직/승진
		if randf() < 0.06 + float(r["intelligence"]) * 0.001:
			_rival_promote()

	# 자산 변화
	var expense: float = _rival_expense()
	var net: float = float(r["monthly_income"]) - expense
	r["total_assets"] = float(r["total_assets"]) + net

	# 투자 수익 (운 + 투자감각 기반)
	if float(r["total_assets"]) > 3_000_000.0 and randf() < 0.4:
		var inv_return: float = float(r["total_assets"]) * randf_range(-0.04, 0.10) * (float(r["investment_skill"]) / 25.0)
		r["total_assets"] = float(r["total_assets"]) + inv_return

	r["total_assets"] = max(float(r["total_assets"]), 0.0)

	# 주거 업그레이드
	_check_rival_housing()

	# 비교 메시지 (주기적)
	_maybe_compare(turn)

# ── 라이벌 취업 ──────────────────────────────────
func _rival_get_job(turn: int):
	var intel: int = int(rival["intelligence"])
	var job_name: String
	var salary: float
	if intel >= 60:
		job_name = "대기업 신입사원"
		salary = 3_200_000.0
	elif intel >= 50:
		job_name = "IT 스타트업 인턴"
		salary = 2_000_000.0
	elif intel >= 40:
		job_name = "카페 매니저"
		salary = 1_600_000.0
	else:
		job_name = "편의점 아르바이트"
		salary = 1_200_000.0

	rival["job_name"] = job_name
	rival["monthly_income"] = salary
	rival["turn_first_job"] = turn

	if turn <= GameState.turn + 2:
		rival_message.emit(
			"💼 %s도 취업했다 — %s, 월 %s" % [rival["name"], job_name, GameState.format_money(salary)],
			"#fbbf24"
		)

func _rival_promote():
	var bonus: float = float(rival["monthly_income"]) * randf_range(0.08, 0.18)
	rival["monthly_income"] += bonus

# ── 주거 업그레이드 ───────────────────────────────
func _check_rival_housing():
	var assets: float = float(rival["total_assets"])
	var prev: String = str(rival["housing"])
	var new_housing: String = prev

	if assets >= 120_000_000.0 and prev != "gangnam":
		new_housing = "gangnam"
	elif assets >= 35_000_000.0 and (prev == "gosiwon" or prev == "oneroom"):
		new_housing = "apartment"
	elif assets >= 7_000_000.0 and prev == "gosiwon":
		new_housing = "oneroom"

	if new_housing != prev:
		rival["housing"] = new_housing
		var info: Dictionary = HOUSING_DATA.get(new_housing, {})
		rival_message.emit(
			"%s %s이(가) %s으로 이사했다." % [info.get("emoji", "🏠"), rival["name"], info.get("name", "")],
			"#f0b429"
		)

# ── 비교 메시지 ───────────────────────────────────
func _maybe_compare(turn: int):
	_check_rival_narrative(turn)
	if turn % 4 != 0:
		return
	var player_assets: float = GameState.get_total_asset_value()
	var rival_assets: float = float(rival["total_assets"])
	var diff: float = player_assets - rival_assets
	var rival_name: String = str(rival["name"])

	var msg: String
	var color: String
	if diff >= 100_000_000.0:
		msg = "📊 %s보다 %s 앞서고 있다. 차이를 유지하라." % [rival_name, GameState.format_money(diff)]
		color = "#00c896"
	elif diff >= 20_000_000.0:
		msg = "📊 %s보다 %s 우위. 방심은 금물." % [rival_name, GameState.format_money(diff)]
		color = "#00c896"
	elif diff >= -10_000_000.0:
		msg = "📊 %s와(과) 접전 중 — 격차를 벌려야 한다." % rival_name
		color = "#f0b429"
	elif diff >= -50_000_000.0:
		msg = "📊 %s에게 %s 뒤처지고 있다. 서둘러." % [rival_name, GameState.format_money(-diff)]
		color = "#ff4444"
	else:
		msg = "📊 %s이(가) 크게 앞서가고 있다. 전략을 바꿔야 한다!" % rival_name
		color = "#ff4444"

	rival_message.emit(msg, color)

# ── 라이벌 서사 이벤트 ────────────────────────────
func _check_rival_narrative(turn: int):
	var n: String = str(rival["name"])
	var assets: float = float(rival["total_assets"])
	var milestones: Dictionary = rival.get("narrative_milestones", {})

	# 첫 취업 후 첫 월급 한 턴
	if rival.get("turn_first_job", -1) == turn - 1 and not milestones.get("first_paycheck_mentioned", false):
		milestones["first_paycheck_mentioned"] = true
		rival["narrative_milestones"] = milestones
		rival_message.emit(
			"💼 %s이(가) 첫 월급을 받았다고 한다. 치킨 샀대." % n, "#fbbf24")
		return

	# 2년차 — 이직 고민
	if turn == 24 and not milestones.get("two_year_mentioned", false):
		milestones["two_year_mentioned"] = true
		rival["narrative_milestones"] = milestones
		if assets > GameState.get_total_asset_value():
			rival_message.emit(
				"📱 %s이(가) 요즘 날아다닌다는 소문이 들린다. 이직 성공했대." % n, "#f97316")
		else:
			rival_message.emit(
				"📱 %s도 요즘 이직 고민 중이라고 한다. 다들 그렇지." % n, "#8892a4")
		return

	# 3년차 — 투자 소문
	if turn == 36 and not milestones.get("three_year_mentioned", false):
		milestones["three_year_mentioned"] = true
		rival["narrative_milestones"] = milestones
		if assets >= 30_000_000.0:
			rival_message.emit(
				"💰 %s이(가) 주식으로 꽤 벌었다고 카톡 단체방이 시끄럽다." % n, "#f97316")
		else:
			rival_message.emit(
				"💬 %s이(가) 요즘 코인 얘기를 달고 산다더라. 아직 수익은 없대." % n, "#8892a4")
		return

	# 5년차 — 인생의 갈림길
	if turn == 60 and not milestones.get("five_year_mentioned", false):
		milestones["five_year_mentioned"] = true
		rival["narrative_milestones"] = milestones
		if assets >= 100_000_000.0:
			rival_message.emit(
				"🏆 %s이(가) 서울 온 지 5년 만에 1억을 넘었다고 한다. FOMO 온다." % n, "#ff4444")
		elif rival.get("housing", "gosiwon") in ["apartment", "gangnam"]:
			rival_message.emit(
				"🏠 %s이(가) 아파트로 이사했다고 SNS에 올렸다. 부럽다." % n, "#f97316")
		else:
			rival_message.emit(
				"📊 서울 5년. %s도 아직 고군분투 중이라고 한다. 다들 그렇구나." % n, "#5a6075")
		return

	# 10년차 — 30대 진입
	if turn == 120 and not milestones.get("ten_year_mentioned", false):
		milestones["ten_year_mentioned"] = true
		rival["narrative_milestones"] = milestones
		if assets >= 500_000_000.0:
			rival_message.emit(
				"💎 %s이(가) 30대가 되자마자 자산 5억을 넘었다고 한다. 격차가 벌어진다." % n, "#ff4444")
		else:
			rival_message.emit(
				"🎂 %s도 30대가 됐다. 서울에서 10년. 다들 어른이 됐네." % n, "#8892a4")
		return

# ── 유틸 ─────────────────────────────────────────
func _rival_expense() -> float:
	return float(HOUSING_DATA.get(rival.get("housing", "gosiwon"), {}).get("expense", 800_000.0))

func get_summary() -> String:
	if rival.is_empty():
		return "—"
	var housing_info: Dictionary = HOUSING_DATA.get(rival.get("housing", "gosiwon"), {})
	return "%s  %s  %s" % [
		rival["name"],
		housing_info.get("name", "고시원"),
		GameState.format_money(rival["total_assets"])
	]

func get_rival() -> Dictionary:
	return rival

# ── 세이브/로드 ───────────────────────────────────
func serialize() -> Dictionary:
	return rival.duplicate(true)

func load_from_dict(data: Dictionary):
	if data.is_empty():
		return
	rival = data.duplicate(true)
	_initialized = true
