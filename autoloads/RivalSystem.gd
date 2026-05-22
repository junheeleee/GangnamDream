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
		"age": 20,
		"housing": "gosiwon",
		"job_name": "무직",
		"monthly_income": 0.0,
		"total_assets": 1_000_000.0,
		"intelligence": randi_range(38, 62),
		"social_skill": randi_range(33, 58),
		"investment_skill": randi_range(8, 22),
		"luck": randi_range(35, 65),
		"turn_first_job": -1,
		"turn_first_million": -1,
	}
	_initialized = true

func _on_turn_advanced(turn: int):
	if not _initialized or rival.is_empty():
		return
	rival["age"] += 0  # 나이는 GameState 기준
	_process_rival(turn)

func _process_rival(turn: int):
	var r: Dictionary = rival

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
