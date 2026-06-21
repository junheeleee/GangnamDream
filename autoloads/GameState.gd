extends Node

signal stats_changed()
signal money_changed(new_amount: float)
signal turn_advanced(new_turn: int)
signal game_over(ending_id: String)
signal log_added(entry: Dictionary)
signal run_started()
signal stat_threshold_crossed(stat_name: String, threshold: int)
signal tendency_awakened(kind: String)

const STAT_THRESHOLDS: Array = [30, 50, 70]
var unlocked_stat_thresholds: Dictionary = {}

const IS_DEMO: bool = true
const DEMO_TURN_LIMIT: int = 24   # 6개월 × 4주

var player_name = "김민준"
var player_background = "지방_상경"  # legacy — 신규 런은 player_route 사용
var player_route = "직장형"  # 직장형 | 투자형 | 창업형
var age = 33
var year = 2026
var month = 1
var week_of_month: int = 1
var turn = 1
var is_game_over = false

const HOUSING_DATA = {
	# 주거 = '삶의 질' 단계 (스트레스/건강에 영향). 강남 입성과는 별개.
	# 진짜 목표는 자산 30억 달성 → 강남 아파트 매매 엔딩.
	# 주거는 월세/전세 개념이라 보증금은 나중에 돌려받지만, 여기선 단순화해
	# 이사 시점에 보증금만큼 묶이는 비용으로 처리.
	"gosiwon":   {"name": "고시원",     "emoji": "🏚", "expense": 650_000.0,   "deposit": 0.0,          "next": "oneroom",   "req_cash": 0.0},
	"oneroom":   {"name": "원룸",       "emoji": "🏠", "expense": 1_100_000.0, "deposit": 5_000_000.0,  "next": "villa",     "req_cash": 8_000_000.0},
	"villa":     {"name": "빌라 전세",  "emoji": "🏡", "expense": 900_000.0,   "deposit": 30_000_000.0, "next": "apartment", "req_cash": 40_000_000.0},
	"apartment": {"name": "아파트 전세","emoji": "🏢", "expense": 1_300_000.0, "deposit": 100_000_000.0,"next": "",          "req_cash": 130_000_000.0},
}

var housing: String = "gosiwon"

# ── 난이도 모드 ───────────────────────────────────────────────────
# 본편 밸런스(현실)는 불변 — 드라마/지옥고는 시작값과 월간 압박 계수만 다르다.
# 진입 장벽은 모드로 풀고, 의도된 긴장(현실)은 그대로 둔다.
const DIFFICULTY_DATA := {
	"드라마": {
		"name": "드라마 모드", "icon": "🎬", "stars": "★★☆☆☆",
		"tagline": "이야기가 먼저다",
		"desc": "시작 자금 200만 / 월간 압박 완화 / 베팅 성공률 +4%p. 드라마를 보러 온 사람을 위해.",
		"start_money": 2_000_000.0,
		"pressure_health": -1, "pressure_mental": -2,
		"opp_bonus": 0.04,
	},
	"현실": {
		"name": "현실 모드", "icon": "🌆", "stars": "★★★★☆",
		"tagline": "의도된 서울",
		"desc": "기본 밸런스. 통장 50만원, 5년, 30억. 개발자가 의도한 긴장 그대로.",
		"start_money": 500_000.0,
		"pressure_health": -2, "pressure_mental": -3,
		"opp_bonus": 0.0,
	},
	"지옥고": {
		"name": "지옥고 모드", "icon": "🔥", "stars": "★★★★★",
		"tagline": "서울은 원래 이렇다",
		"desc": "시작 자금 30만 / 월간 압박 강화 / 베팅 성공률 -4%p. 지옥고에서 강남까지.",
		"start_money": 300_000.0,
		"pressure_health": -3, "pressure_mental": -4,
		"opp_bonus": -0.04,
	},
}
var difficulty: String = "현실"

func get_difficulty_data() -> Dictionary:
	return DIFFICULTY_DATA.get(difficulty, DIFFICULTY_DATA["현실"])

# ── 대출 — 빚으로 판을 키운다 ─────────────────────────────────────
# 빚은 순자산(get_total_asset_value)에서 차감되고, 파산 판정도 순자산 기준.
# 빌린 돈을 베팅에 넣을 수 있지만, 날리면 순자산이 -1억(파산 라인)에 다가간다.
# 한도와 금리는 신용등급(get_credit_grade)이 결정한다. 금리는 변동금리 —
# 등급이 떨어지면(실직·자산 손실·과다 부채) 보유 중인 빚의 이자도 같이 오른다.
const LOAN_PRODUCTS := {
	"bank":   {"name": "1금융 신용대출", "emoji": "🏦"},
	"second": {"name": "제2금융 대출",   "emoji": "💳"},
}
var loans: Dictionary = {"bank": 0.0, "second": 0.0}

var money = 1_000_000.0
var monthly_income = 0.0
var fixed_expense = 650_000.0
var health = 70
var mental = 70
var intelligence = 50
var social_skill = 40
var appearance = 50
var investment_skill = 12
var luck = 45

var action_points = 2
var max_action_points = 2
var tutorial_step = 3

var route_orthodox: int = 0
var route_unorthodox: int = 0
var month_focus: String = ""
var housing_months: Dictionary = {}

# ── 성향(직장/투자/창업) — 플레이로 누적, 임계점에서 '자각' ──────────
# 죽은 트레이트 시스템을 대체: 선택이 아니라 행동이 정체성을 만든다.
const TENDENCY_KINDS := ["career", "invest", "found"]
const TENDENCY_NAMES := {"career": "직장형", "invest": "투자형", "found": "창업형"}
const TENDENCY_DESC := {
	"career": "성실하게 쌓아 올린다. 월급과 승진, 신용이 무기다.",
	"invest": "돈이 돈을 벌게 한다. 시장을 읽고 베팅한다.",
	"found":  "내 것을 만든다. 위험하지만 천장이 없다.",
}
const TENDENCY_REALIZE_THRESHOLD := 12   # 1위가 이 점수 넘고
const TENDENCY_REALIZE_GAP := 4          # 2위와 격차가 이 이상이면 자각
var tendency: Dictionary = {"career": 0, "invest": 0, "found": 0}
var tendency_realized: String = ""       # "" = 아직, 아니면 career/invest/found

var reputation = 10
var gambling_tendency = 0
var addiction_tendency = 0

var current_job: Dictionary = {}
var job_tenure = 0
var work_performance = 50

var milestones_reached: Dictionary = {}  # "10m","100m","500m","1b","2b"
var portfolio: Dictionary = {}
var relationships: Array = []

# ── 스토리 인물 관계 (드라마 시스템) ──────────────────────────────
# 각 인물: { stage: 단계, affinity: 호감도(-100~100), met: 만났는가, flags: 인물별 기억 }
# stage는 인물별로 정의됨 (STORY_BIBLE 참조)
var cast: Dictionary = {}

# ── StoryMode(비주얼노벨 화면) 연동 ──────────────────────────────
var pending_story_queue: Array = []   # StoryMode에서 재생할 이벤트 ID 목록
var story_return_scene: String = ""    # StoryMode 종료 후 복귀할 씬 경로
var returning_from_story: bool = false # true면 MainGame이 달을 다시 시작하지 않음

func _default_cast() -> Dictionary:
	return {
		"jiyeon":   {"stage": "unknown", "affinity": 0,  "met": false, "flags": {}},
		"daeun":    {"stage": "unknown", "affinity": 0,  "met": false, "flags": {}},
		"jaehyuk":  {"stage": "unknown", "affinity": 0,  "met": false, "flags": {}},
		"father":   {"stage": "distant", "affinity": 40, "met": true,  "flags": {}},
		"sangchul": {"stage": "unknown", "affinity": 0,  "met": false, "flags": {}},
	}

var inventory: Array = []
var news_log: Array = []
var event_log: Array = []
var action_log: Array = []
var flags: Dictionary = {}
var deferred_events: Array = []  # [{event_id, trigger_turn}] — N턴 후 자동 발동 이벤트
var events_seen: int = 0   # 이번 런에서 플레이어가 실제 선택한 이벤트 수
var peak_asset: float = 0.0   # 이번 런 최고 자산 (분석요소 — 정점 대비 결말 비교)
var run_theme_categories: Array = []
var run_theme: String = "자유런"
var market_prices: Dictionary = {}
var price_history: Dictionary = {}
var market_context = {
	"fear_greed": 50,
	"cycle": "neutral",
	"bubble_assets": [],
	"crash_risk": 0.04,
	"momentum": 0.0,
}

func _ready():
	randomize()

func new_game():
	start_new_game()

func start_new_game(chosen_name: String = "김민준", chosen_background: String = "지방_상경", chosen_route: String = "직장형", starting_profile: String = "백수", chosen_theme: String = "자유런", chosen_difficulty: String = "현실"):
	player_name = chosen_name if not chosen_name.strip_edges().is_empty() else "김민준"
	player_background = chosen_background
	player_route = chosen_route
	difficulty = chosen_difficulty if DIFFICULTY_DATA.has(chosen_difficulty) else "현실"
	age = 33   # 김민준 33세 시작 → 38세(=5년/60턴)가 강남 입성 마감
	year = 2026
	month = 1
	turn = 1
	is_game_over = false

	housing = "gosiwon"
	var diff_data: Dictionary = get_difficulty_data()
	money = float(diff_data.get("start_money", 500_000.0))
	monthly_income = 0.0
	fixed_expense = 650_000.0
	health = 65
	mental = 60
	intelligence = 55
	social_skill = 45
	appearance = 50
	investment_skill = 15
	luck = 45
	week_of_month = 1
	action_points = 2
	max_action_points = 2
	tutorial_step = 3
	reputation = 5
	gambling_tendency = 0
	addiction_tendency = 0
	current_job = {}
	job_tenure = 0
	work_performance = 50
	milestones_reached = {}
	portfolio = {}
	loans = {"bank": 0.0, "second": 0.0}
	relationships = []
	cast = _default_cast()
	inventory = []
	news_log = []
	event_log = []
	action_log = []
	flags = {}
	deferred_events = []
	events_seen = 0
	peak_asset = 0.0
	run_theme_categories = []
	run_theme = "자유런"
	market_prices = {}
	price_history = {}
	unlocked_stat_thresholds = {}
	route_orthodox = 0
	route_unorthodox = 0
	month_focus = ""
	housing_months = {}
	tendency = {"career": 0, "invest": 0, "found": 0}
	tendency_realized = ""
	market_context = {
		"fear_greed": 50,
		"cycle": "neutral",
		"bubble_assets": [],
		"crash_risk": 0.04,
		"momentum": 0.0,
	}

	_apply_route_bonus(chosen_route)
	_apply_starting_profile(starting_profile)
	_apply_run_theme(chosen_theme)
	_apply_title_perks()
	_init_market_prices()
	# NG+ 자각 이스터에그 표식 — 반복 플레이어 보상 (회귀 데자뷔)
	var _prev_runs: int = int(MetaProgression.data.get("total_runs", 0))
	if _prev_runs >= 1:
		flags["is_repeat_run"] = true
	if _prev_runs >= 4:
		flags["is_veteran_run"] = true
	add_log("새 런 시작: %s / 출발점: %s" % [chosen_route, starting_profile], "system")
	stats_changed.emit()
	run_started.emit()

## 해금한 칭호가 다음 런 시작 보너스가 된다 — 수집의 실질 보상
func _apply_title_perks():
	var bonus: Dictionary = MetaProgression.get_run_start_bonus()
	if bonus.is_empty():
		return
	var parts: PackedStringArray = PackedStringArray()
	var stat_kr = {
		"investment_skill": "투자감각", "intelligence": "지력", "social_skill": "사교력",
		"luck": "운", "mental": "정신력", "money": "자금",
	}
	for stat in bonus:
		var amount = int(bonus[stat])
		if amount == 0:
			continue
		match str(stat):
			"money":            money += float(amount)
			"investment_skill": investment_skill += amount
			"intelligence":     intelligence += amount
			"social_skill":     social_skill += amount
			"stress":           mental = clampi(mental - amount, 0, 100)
			"luck":             luck += amount
			"mental":           mental = clampi(mental + amount, 0, 100)
		if str(stat) == "money":
			parts.append("자금 +%s" % format_money(float(amount)))
		else:
			parts.append("%s %+d" % [stat_kr.get(str(stat), str(stat)), amount])
	if not parts.is_empty():
		add_log("🏆 칭호 보너스: %s  (수집한 칭호가 힘이 된다)" % " · ".join(parts), "system")

func _apply_background_bonus(bg: String):
	pass  # legacy — 신규 런은 _apply_route_bonus 사용

func _apply_route_bonus(route: String):
	match route:
		"직장형":
			# 커리어 준비된 30대 — 사회성·지력 높고 취업 빠름
			intelligence   += 8
			social_skill   += 8
			mental         = clampi(mental + 5, 0, 100)
			flags["route_career"] = true
			flags["job_priority"] = true   # 첫 달 취업 이벤트 우선 노출
		"투자형":
			# 10년간 시장 공부한 30대 — 투자감각 높지만 불안감 큼
			investment_skill += 18
			intelligence     += 5
			mental           = clampi(mental - 10, 0, 100)
			money            -= 100_000.0  # 공부에 돈 씀
			flags["route_invest"] = true
			flags["has_received_paycheck"] = true  # 투자 즉시 가능
		"창업형":
			# 한방을 노리는 30대 — 운·사회성 높고 사업 빠름
			luck          += 12
			social_skill  += 10
			appearance    += 5
			mental        = clampi(mental - 8, 0, 100)
			money         -= 150_000.0  # 사업 준비에 씀
			flags["route_startup"] = true
			flags["startup_intent"] = true  # 창업 이벤트 해금

func _apply_starting_profile(profile: String):
	match profile:
		"알바":
			# 편의점 알바생 — 수입은 있지만 몸이 먼저 닳는다
			money          += 300_000.0    # 몇 달치 절약
			health         -= 8
			mental         = clampi(mental - 8, 0, 100)
			social_skill   += 5
			flags["part_time_worker"]      = true
			flags["has_received_paycheck"] = true
			var job = DataRegistry.get_job("job_01")
			if not job.is_empty():
				current_job    = job.duplicate(true)
				job_tenure     = 0
				monthly_income = float(job.get("base_salary", 1_320_000))
		"직장인":
			# 대기업 회사원 — 월급은 두둑하지만 삶이 없다
			money          += 2_000_000.0  # 2년치 저축
			intelligence   += 8
			social_skill   += 5
			appearance     += 3
			mental         = clampi(mental - 15, 0, 100)
			health         -= 5
			flags["corporate_worker"]      = true
			flags["has_received_paycheck"] = true
			var job = DataRegistry.get_job("job_08")
			if not job.is_empty():
				current_job    = job.duplicate(true)
				job_tenure     = 0
				monthly_income = float(job.get("base_salary", 4_550_000))
		"유튜버":
			# 유튜버 지망생 — 구독자 3천명, 가능성과 불안정성 공존
			money          += 200_000.0
			social_skill   += 15
			appearance     += 8
			luck           += 8
			intelligence   -= 5
			mental         = clampi(mental - 5, 0, 100)
			monthly_income  = 300_000.0   # 소액 광고 수입 (변동)
			flags["youtuber_start"]        = true
			flags["has_received_paycheck"] = true
		"코인폐인":
			# 코인 폐인 (히든) — 500만 시작, 중독 이미 진행 중
			money          += 4_500_000.0  # 코인으로 4배 갔다가 원금 회복
			mental         -= 15
			mental         = clampi(mental - 20, 0, 100)
			luck           -= 5
			investment_skill += 10         # 차트는 읽을 줄 안다
			addiction_tendency  = 30
			gambling_tendency   = 25
			flags["coin_maniac"]            = true
			flags["had_first_investment"]   = true
			flags["entered_network"]        = false  # 인맥은 없다

func _roll_run_theme():
	var pool = ["investment", "jobs", "social", "health", "relationship", "gambling", "finance"]
	pool.shuffle()
	run_theme_categories = [pool[0], pool[1]]
	var label_map = {
		"investment": "투자", "jobs": "직장", "social": "인간관계",
		"health": "건강", "relationship": "연애", "gambling": "도박", "finance": "재정"
	}
	var a = label_map.get(pool[0], pool[0])
	var b = label_map.get(pool[1], pool[1])
	add_log("🎲 이번 런 테마: [%s + %s] — 관련 이벤트가 더 자주 등장합니다." % [a, b], "system")

func _apply_run_theme(theme: String) -> void:
	run_theme = theme
	match theme:
		"자유런":
			_roll_run_theme()
		"투자런":
			run_theme_categories = ["investment", "finance"]
			investment_skill += 5
			flags["theme_invest_run"] = true
			add_log("📈 [투자런] 시작 — 투자·재정 이벤트가 집중 등장합니다. 투자감각 +5.", "system")
		"인맥런":
			run_theme_categories = ["social", "relationship"]
			social_skill += 10
			flags["theme_network_run"] = true
			add_log("🤝 [인맥런] 시작 — 사회·관계 이벤트가 집중 등장합니다. 사교력 +10.", "system")
		"청렴런":
			run_theme_categories = ["jobs", "health"]
			reputation += 10
			flags["theme_clean_run"] = true
			flags["no_gambling"] = true   # EventManager가 gambling 카테고리 이벤트 차단
			add_log("✨ [청렴런] 시작 — 도박 이벤트 없음. 평판 +10. 정직하게만 30억.", "system")
		_:
			_roll_run_theme()

func _init_market_prices():
	for asset in DataRegistry.assets:
		market_prices[asset.get("id", "")] = float(asset.get("initial_price", asset.get("base_price", 10_000.0)))

func advance_calendar() -> bool:
	if is_game_over:
		return false
	turn += 1
	week_of_month += 1
	var month_ended := false
	if week_of_month > 4:
		week_of_month = 1
		month += 1
		month_ended = true
		if month > 12:
			month = 1
			year += 1
			age += 1
	turn_advanced.emit(turn)
	return month_ended

func get_housing_expense() -> float:
	return float(HOUSING_DATA.get(housing, HOUSING_DATA["gosiwon"]).get("expense", 800_000.0))

func get_housing_info() -> Dictionary:
	return HOUSING_DATA.get(housing, HOUSING_DATA["gosiwon"])

func can_upgrade_housing() -> bool:
	var info = get_housing_info()
	var next_id = str(info.get("next", ""))
	if next_id.is_empty():
		return false
	var next_info = HOUSING_DATA.get(next_id, {})
	return money >= float(next_info.get("req_cash", 0.0))

func upgrade_housing() -> Dictionary:
	var info = get_housing_info()
	var next_id = str(info.get("next", ""))
	if next_id.is_empty():
		return {"success": false, "message": "이미 최고 등급 주거입니다."}
	var next_info = HOUSING_DATA.get(next_id, {})
	if money < float(next_info.get("req_cash", 0.0)):
		return {"success": false, "message": "자금이 부족합니다."}
	var deposit_diff = float(next_info.get("deposit", 0.0)) - float(info.get("deposit", 0.0))
	add_money(-deposit_diff)
	housing = next_id
	fixed_expense = get_housing_expense()
	flags["housing_moved_once"] = true
	add_log("이사: %s → %s (보증금 %s)" % [info.get("name",""), next_info.get("name",""), format_money(deposit_diff)], "system")
	stats_changed.emit()
	return {"success": true, "housing": next_info}

func apply_monthly_pressure():
	fixed_expense = get_housing_expense()
	add_money(monthly_income - fixed_expense)
	# 첫 월급 수령 플래그 — 투자 기능 잠금 해제 트리거
	if monthly_income > 0 and not flags.get("has_received_paycheck", false):
		flags["has_received_paycheck"] = true
		add_log("💳 첫 월급이 통장에 들어왔다. 이제 투자를 시작할 수 있다.", "job")

	# ── 대출 이자 — 빚은 숨만 쉬어도 매달 나간다 (변동금리: 현재 등급 기준) ──
	var loan_interest := 0.0
	for p in loans:
		loan_interest += float(loans[p]) * get_loan_rate(p)
	if loan_interest > 0.0:
		add_money(-loan_interest)
		modify_stat("mental", -1)
		add_log("🏦 대출 이자 %s 납부 (원금 %s, 신용 %d등급)." % [format_money(loan_interest), format_money(get_loan_total()), get_credit_grade()], "money")

	# ── 서울살이 기본 압박 (난이도별 계수) ───────────────────────────
	var diff_data: Dictionary = get_difficulty_data()
	modify_stat("health", int(diff_data.get("pressure_health", -2)))
	modify_stat("mental", int(diff_data.get("pressure_mental", -3)))

	# ── 주거 패시브 + 거주 기간 추적 ────────────────────────────────
	housing_months[housing] = housing_months.get(housing, 0) + 1
	match housing:
		"gosiwon":
			modify_stat("mental", -1)
			modify_stat("mental", -1)
			if randf() < 0.25:
				add_log("🏚 고시원 생활: 옆방 소음, 공용 화장실... 정신이 갉아먹힌다.", "event")
		"villa", "apartment":
			modify_stat("mental", 1)  # 더 나은 주거 = 삶의 질 ↑

	# ── 인연 패시브 — 깊어진 관계가 서울살이의 바닥을 받쳐준다 ──────
	# (아크 보상은 엔딩 분기가 아니라 런 중 유지비 절감으로 환류)
	if get_cast_stage("father") in ["reconciled", "connected", "hopeful", "close"]:
		modify_stat("mental", 1)
		if randf() < 0.18:
			add_log("📞 아버지와 짧은 통화. 별 말은 없었지만 바닥이 생긴 기분이다.", "relationship")
	if get_cast_stage("jiyeon") in ["lover", "honest_together"] \
			or get_cast_stage("daeun") in ["lover", "together", "committed", "dating"]:
		modify_stat("mental", 1)
		if randf() < 0.18:
			add_log("💬 잠들기 전 주고받은 메시지 몇 줄이 하루를 닫아준다.", "relationship")
	if get_cast_stage("sangchul") in ["trusted", "mentoring", "guardian"] and turn % 4 == 0:
		modify_stat("investment_skill", 1)
		add_log("🏢 임상철의 지나가는 말들이 어느새 감각이 되고 있다.", "relationship")

	# ── 칭호 조건 플래그 자동 추적 ───────────────────────────────
	if money < 0:
		flags["was_broke_once"] = true
	if mental <= 15:
		flags["reached_max_stress"] = true
	if monthly_income == 0:
		flags["unemployed_months"] = flags.get("unemployed_months", 0) + 1

	# 무직이면 정신/스트레스 추가 압박
	if monthly_income == 0:
		modify_stat("mental", -2)
		add_log("💸 수입이 없다. 통장 잔고가 줄어가는 게 느껴진다.", "event")


	# ── 중독 단계별 월간 압박 ────────────────────────────────────
	if addiction_tendency >= 70:
		modify_stat("mental", -2)
		if randf() < 0.5:
			add_log("🎰 '딱 한 번만 더.' 그 생각이 오늘도 머릿속을 맴돌았다.", "event")
	elif addiction_tendency >= 50:
		modify_stat("mental", -1)
		if randf() < 0.4:
			add_log("🎰 다음 판이 자꾸 눈에 밟힌다.", "event")

	# ── 전문화 성향 월간 패시브 (3~5턴마다 소량 누적) ─────────────
	if flags.get("spec_elite", false) and turn % 3 == 0:
		work_performance = mini(work_performance + 1, 100)
	if flags.get("spec_social_climber", false) and turn % 5 == 0:
		modify_stat("social_skill", 1)
	if flags.get("spec_quant", false) and turn % 4 == 0:
		modify_stat("investment_skill", 1)
	if flags.get("spec_speculator", false):
		modify_hidden_stat("gambling_tendency", 1)
	if flags.get("spec_tech_founder", false) and turn % 5 == 0:
		modify_stat("luck", 1)
	if flags.get("spec_social_entrepreneur", false) and turn % 4 == 0:
		modify_stat("reputation", 1)

	# 현금 위기 — 마이너스가 더 심각하므로 먼저 검사 (역순이면 도달 불가)
	if money < 0:
		modify_stat("mental", -4)
		add_log("🆘 잔고가 마이너스다. 이러다 진짜 쫓겨난다.", "money")
	elif money < 300_000:
		modify_stat("mental", -2)
		add_log("😰 통장 잔고가 30만원 아래다. 이번 달을 버틸 수 있을까.", "money")

	check_game_over()

func apply_choice(event, choice):
	if not event.is_empty() and event.has("id"):
		events_seen += 1
	apply_effects(choice.get("effects", {}))
	for rel_effect in choice.get("relationship_effects", []):
		apply_relationship_effect(rel_effect)
	for investment_effect in choice.get("investment_effects", []):
		apply_investment_effect(investment_effect)
	for flag_id in choice.get("flags", []):
		flags[str(flag_id)] = true
		# 마인드셋 선택(arc_intro_02) → 성향 초기 시드
		match str(flag_id):
			"mindset_saver":    add_tendency("career", 6)
			"mindset_investor": add_tendency("invest", 6)
			"mindset_founder":  add_tendency("found", 6)
	# 선택지가 직접 성향 포인트를 줄 수도 있다: "tendency": {"invest": 2}
	for tk in choice.get("tendency", {}):
		add_tendency(str(tk), int(choice["tendency"][tk]))
	# 선택지가 루트 포인트를 줄 수도 있다: "route": "orthodox" | "unorthodox"
	if choice.has("route"):
		add_route_point(str(choice["route"]))
	# 선택지가 직접 직업을 줄 수도 있다: "grant_job": "job_01" (이미 직업이 있으면 무시)
	if choice.has("grant_job") and current_job.is_empty():
		var gj = DataRegistry.get_job(str(choice["grant_job"]))
		if not gj.is_empty():
			current_job    = gj.duplicate(true)
			job_tenure     = 0
			work_performance = 50
			monthly_income = float(gj.get("base_salary", 0))
			add_log("💼 취업: %s" % str(gj.get("name", "")), "job")
	# 스토리 인물 관계 변화 (cast_effects)
	# 예: "cast_effects": { "jiyeon": { "affinity": 10, "stage": "interest", "met": true } }
	for person_id in choice.get("cast_effects", {}):
		apply_cast_effect(str(person_id), choice["cast_effects"][person_id])
	# 결정적 기회 — 큰 베팅 (인물이 제공하는 30억 경로의 핵심)
	if choice.has("opportunity"):
		_resolve_opportunity(choice["opportunity"])
	event_log.append({
		"turn": turn,
		"event_id": event.get("id", ""),
		"choice": format_event_text(str(choice.get("text", ""))),
		"result": format_event_text(str(choice.get("result_text", ""))),
	})
	add_log("%s: %s" % [
		format_event_text(str(event.get("title", "이벤트"))),
		format_event_text(str(choice.get("result_text", choice.get("text", "")))),
	], "event")

# ── 스토리 인물 관계 조작 ─────────────────────────────────────────
func _ensure_cast(person_id: String):
	if not cast.has(person_id):
		cast[person_id] = {"stage": "unknown", "affinity": 0, "met": false, "flags": {}}

func apply_cast_effect(person_id: String, effect: Dictionary):
	_ensure_cast(person_id)
	var c: Dictionary = cast[person_id]
	if effect.has("affinity"):
		c["affinity"] = clampi(int(c.get("affinity", 0)) + int(effect["affinity"]), -100, 100)
	if effect.has("stage"):
		c["stage"] = str(effect["stage"])
	if effect.has("met"):
		c["met"] = bool(effect["met"])
	for fk in effect.get("flags", []):
		(c["flags"] as Dictionary)[str(fk)] = true
	stats_changed.emit()

func get_cast_stage(person_id: String) -> String:
	_ensure_cast(person_id)
	return str(cast[person_id].get("stage", "unknown"))

func get_cast_affinity(person_id: String) -> int:
	_ensure_cast(person_id)
	return int(cast[person_id].get("affinity", 0))

func cast_has_met(person_id: String) -> bool:
	_ensure_cast(person_id)
	return bool(cast[person_id].get("met", false))

func cast_has_flag(person_id: String, flag: String) -> bool:
	_ensure_cast(person_id)
	return bool((cast[person_id].get("flags", {}) as Dictionary).get(flag, false))

## 의미 있는 인연이 하나라도 있는가 (옛 relationships[] 또는 cast 호감도 60+)
func has_any_close_relationship() -> bool:
	if not relationships.is_empty():
		return true
	for pid in cast:
		if int(cast[pid].get("affinity", 0)) >= 60:
			return true
	return false

# ── 결정적 기회 (큰 베팅) ─────────────────────────────────────────
## 인물이 제공하는 30억 경로의 핵심 메커니즘.
## 가진 돈의 일부/전부를 걸고, 성공 확률에 따라 크게 불리거나 잃는다.
## opportunity = {
##   "cost": 금액 or "stake_ratio": 0.0~1.0(현재현금 비율),
##   "success_rate": 0.0~1.0,        # luck 스탯이 보정
##   "win_multiplier": 3.0,          # 성공 시 베팅금 x배 (순이익)
##   "loss_ratio": 1.0,              # 실패 시 베팅금 x비율 손실
##   "luck_factor": 0.001,           # luck 1당 성공률 가산
##   "win_flag": "...", "lose_flag": "...",  # 결과 플래그(선택)
##   "skill_gain": 5                 # 결과 무관 투자감각 상승(선택)
## }
## 결과를 flags["_last_opportunity_result"]에 "win"/"lose"로 남겨 UI/후속이 참조.
func _resolve_opportunity(opp: Dictionary) -> String:
	var stake: float = 0.0
	if opp.has("stake_ratio"):
		stake = max(0.0, money) * float(opp["stake_ratio"])
	else:
		stake = float(opp.get("cost", 0.0))
	# 돈이 부족하면 가진 만큼만 (마이너스 베팅 방지)
	stake = min(stake, max(0.0, money)) if opp.has("stake_ratio") else stake

	# 성공 확률 = 기본 + luck 보정 + 난이도 보정
	var rate: float = float(opp.get("success_rate", 0.5))
	rate += float(luck) * float(opp.get("luck_factor", 0.0015))
	rate += float(get_difficulty_data().get("opp_bonus", 0.0))
	rate = clampf(rate, 0.02, 0.98)

	# 베팅금 차감
	add_money(-stake)

	# 투자감각 상승 (결과 무관 — 배움)
	if opp.has("skill_gain"):
		modify_stat("investment_skill", int(opp["skill_gain"]))

	var result := ""
	if randf() < rate:
		# 성공 — 베팅금 + 베팅금 x 배수
		var win = stake * float(opp.get("win_multiplier", 2.0))
		add_money(stake + win)
		modify_stat("mental", 2)
		result = "win"
		if opp.has("win_flag"):
			flags[str(opp["win_flag"])] = true
		add_log("📈 베팅 성공! %s 벌었다." % format_money(win), "money")
	else:
		# 실패 — 베팅금 x 손실비율 만큼 날림 (이미 차감됐으니 나머지 환급)
		var loss_ratio = clampf(float(opp.get("loss_ratio", 1.0)), 0.0, 1.0)
		var refund = stake * (1.0 - loss_ratio)
		add_money(refund)
		modify_stat("mental", -9)
		result = "lose"
		if opp.has("lose_flag"):
			flags[str(opp["lose_flag"])] = true
		add_log("📉 베팅 실패. %s 잃었다." % format_money(stake - refund), "money")
	flags["_last_opportunity_result"] = result
	return result

func apply_effects(effects):
	for key in effects:
		var value = effects[key]
		match key:
			"money":
				add_money(float(value))
			"monthly_income":
				monthly_income += float(value)
			"fixed_expense":
				fixed_expense = max(0.0, fixed_expense + float(value))
			"health", "mental", "intelligence", "social_skill", "appearance", "investment_skill", "luck":
				modify_stat(key, int(value))
			"stress":
				modify_stat("mental", -int(value))
			"reputation", "gambling_tendency", "addiction_tendency":
				modify_hidden_stat(key, int(value))
			"work_performance":
				work_performance = clampi(work_performance + int(value), 0, 100)
			"flag":
				flags[str(value)] = true
			"unflag":
				flags.erase(str(value))
			"action_points":
				action_points = clamp(action_points + int(value), 0, max_action_points + 2)
			"route_orthodox":
				route_orthodox = maxi(0, route_orthodox + int(value))
			"route_unorthodox":
				route_unorthodox = maxi(0, route_unorthodox + int(value))
	stats_changed.emit()

func apply_relationship_effect(effect):
	var rel_id = str(effect.get("id", effect.get("type", "unknown")))
	var found = false
	for rel in relationships:
		if rel.get("id", "") == rel_id:
			rel["affection"] = clamp(int(rel.get("affection", 40)) + int(effect.get("affection", 0)), 0, 100)
			rel["trust"] = clamp(int(rel.get("trust", 40)) + int(effect.get("trust", 0)), 0, 100)
			found = true
			break
	if not found:
		relationships.append({
			"id": rel_id,
			"name": effect.get("name", "새 인연"),
			"type": effect.get("type", "friends"),
			"affection": clamp(int(effect.get("affection", 45)), 0, 100),
			"trust": clamp(int(effect.get("trust", 40)), 0, 100),
			"met_turn": turn,
		})
	stats_changed.emit()

func apply_investment_effect(effect):
	var asset_id = str(effect.get("asset_id", ""))
	if asset_id.is_empty():
		return
	if not market_prices.has(asset_id):
		return
	market_prices[asset_id] *= 1.0 + float(effect.get("price_delta", 0.0))
	if bool(effect.get("bubble", false)):
		var bubble_assets: Array = market_context.get("bubble_assets", [])
		if not bubble_assets.has(asset_id):
			bubble_assets.append(asset_id)
		market_context["bubble_assets"] = bubble_assets

func add_money(amount):
	money += amount
	money_changed.emit(money)
	stats_changed.emit()

func modify_stat(stat_name, amount):
	var old_val: int = int(get(stat_name)) if get(stat_name) != null else 0
	match stat_name:
		"health":
			health = clamp(health + amount, 0, 100)
		"mental":
			mental = clamp(mental + amount, 0, 100)
		"intelligence":
			intelligence = clamp(intelligence + amount, 0, 100)
		"social_skill":
			social_skill = clamp(social_skill + amount, 0, 100)
		"appearance":
			appearance = clamp(appearance + amount, 0, 100)
		"investment_skill":
			investment_skill = clamp(investment_skill + amount, 0, 100)
		"luck":
			luck = clamp(luck + amount, 0, 100)
	# RPG 임계값 해금 감지 (상승할 때만)
	if amount > 0 and stat_name in ["investment_skill", "intelligence", "social_skill"]:
		var new_val: int = int(get(stat_name))
		for threshold in STAT_THRESHOLDS:
			var key = "%s_%d" % [stat_name, threshold]
			if old_val < threshold and new_val >= threshold and not unlocked_stat_thresholds.has(key):
				unlocked_stat_thresholds[key] = true
				stat_threshold_crossed.emit(stat_name, threshold)

func modify_hidden_stat(stat_name, amount):
	match stat_name:
		"stress":
			modify_stat("mental", -amount)
		"reputation":
			reputation = clamp(reputation + amount, -100, 100)
		"gambling_tendency":
			gambling_tendency = clamp(gambling_tendency + amount, 0, 100)
		"addiction_tendency":
			addiction_tendency = clamp(addiction_tendency + amount, 0, 100)

func spend_ap(amount: int = 1) -> bool:
	if action_points < amount:
		return false
	action_points -= amount
	stats_changed.emit()
	return true

func restore_ap():
	action_points = max_action_points
	month_focus = ""
	stats_changed.emit()

func get_current_title() -> String:
	if mental <= 20: return "벼랑 끝의 청년"
	if mental <= 12: return "번아웃 직전"
	if get_total_asset_value() < -50_000_000: return "파산 위기자"
	var total = get_total_asset_value()
	if total >= 3_000_000_000: return "강남드림 달성자"
	if total >= 500_000_000: return "신흥 자산가"
	if total >= 100_000_000: return "중산층 진입"
	# 비정석 특수 상태
	if flags.get("creator_viral", false): return "크리에이터"
	if flags.get("startup_exit", false): return "스타트업 엑시터"
	if flags.get("startup_launched", false): return "창업가"
	if flags.get("creator_monetized", false): return "유튜버"
	if flags.get("creator_started", false): return "콘텐츠 크리에이터"
	var diff = route_orthodox - route_unorthodox
	if diff >= 18: return "엘리트 코스"
	if diff >= 8: return "착실한 청년"
	if diff <= -18: return "위험한 몽상가"
	if diff <= -8: return "이단아"
	if route_orthodox >= 10 and route_unorthodox >= 10: return "내 방식대로"
	if get_total_asset_value() >= 3_000_000_000: return "강남 입성자"
	if housing == "apartment" and job_tenure >= 12: return "안정적인 직장인"
	if current_job.is_empty() and turn >= 8 and (flags.get("resume_polished", false) or flags.get("mindset_investor", false) or flags.get("mindset_saver", false)): return "취업 준비생"
	if housing == "gosiwon" and turn >= 18: return "고시원 장기거주자"
	if turn <= 4: return "서울 상경 초보"
	return "서울 생존자"

func add_route_point(route_type: String, focus_label: String = ""):
	if route_type == "orthodox":
		route_orthodox += 1
	elif route_type == "unorthodox":
		route_unorthodox += 1
	if month_focus.is_empty() and not focus_label.is_empty():
		month_focus = focus_label

func get_route_identity() -> String:
	var diff = route_orthodox - route_unorthodox
	var total = route_orthodox + route_unorthodox
	if total == 0: return "📍 방향 없음"
	if diff >= 15: return "🏆 정석 엘리트"
	if diff >= 7:  return "📘 정석 지향"
	if diff <= -15: return "🔥 완전 아웃사이더"
	if diff <= -7:  return "🌊 비정석 지향"
	return "⚖️ 균형형"

func get_route_label() -> String:
	return "%s  (정석 %d / 비정석 %d)" % [get_route_identity(), route_orthodox, route_unorthodox]

# ── 플레이 스타일 진단 (분석요소) ──────────────────────────────
# 런 종료 시 플레이어의 행동 패턴을 한 줄로 분류. 도달 자산이 아니라
# "어떻게 살았는가"를 비춰주는 거울. 리플레이 동기 부여.
func get_playstyle_label() -> String:
	var total: float = float(get_total_asset_value())
	var gamble: int = int(gambling_tendency)
	var addict: int = int(addiction_tendency)
	var diff: int = route_orthodox - route_unorthodox
	# 우선순위: 극단 패턴부터
	if addict >= 60 or gamble >= 60:
		return "🎰 승부사 — 한 방에 모든 걸 건 사람"
	if peak_asset >= 1_000_000_000 and total < peak_asset * 0.4:
		return "📉 롤러코스터 — 정점에서 미끄러진 사람"
	if has_any_close_relationship() and reputation >= 60:
		return "🤝 관계형 — 사람으로 버틴 사람"
	if diff >= 12:
		return "📘 원칙주의자 — 규칙대로 끝까지 간 사람"
	if diff <= -12:
		return "🔥 개척자 — 남들 안 가는 길로 간 사람"
	if health <= 35 or mental <= 35:
		return "🥀 소진형 — 자신을 갈아 넣은 사람"
	if housing == "gosiwon" and turn >= 120:
		return "🪨 생존형 — 바닥에서 끝까지 버틴 사람"
	if events_seen >= 80:
		return "🧭 탐험가 — 모든 문을 열어본 사람"
	return "⚖️ 균형형 — 중심을 잃지 않은 사람"

# ── 성향 시스템 ────────────────────────────────────────────────
func add_tendency(kind: String, amount: int = 1):
	if not tendency.has(kind):
		return
	tendency[kind] = int(tendency[kind]) + amount
	stats_changed.emit()
	check_tendency_realization()   # 임계점 넘으면 tendency_awakened 시그널 발생

func get_dominant_tendency() -> String:
	var best := ""
	var best_v := -1
	for k in TENDENCY_KINDS:
		var v := int(tendency.get(k, 0))
		if v > best_v:
			best_v = v
			best = k
	return best if best_v > 0 else ""

func tendency_name(kind: String) -> String:
	return str(TENDENCY_NAMES.get(kind, ""))

## 현재 성향 라벨 (자각했으면 확정, 아니면 '~ 기질')
func get_tendency_label() -> String:
	if not tendency_realized.is_empty():
		return tendency_name(tendency_realized)
	var dom := get_dominant_tendency()
	if dom.is_empty():
		return "아직 모르는 길"
	return tendency_name(dom) + " 기질"

## 자각 판정: 1위가 임계점 넘고 2위와 격차 충분 + 아직 미자각 → 자각한 kind 반환(없으면 "")
func check_tendency_realization() -> String:
	if not tendency_realized.is_empty():
		return ""
	var ranked: Array = []
	for k in TENDENCY_KINDS:
		ranked.append([int(tendency.get(k, 0)), k])
	ranked.sort_custom(func(a, b): return a[0] > b[0])
	var top: Array = ranked[0]
	var second: Array = ranked[1]
	if top[0] >= TENDENCY_REALIZE_THRESHOLD and (top[0] - second[0]) >= TENDENCY_REALIZE_GAP:
		tendency_realized = top[1]
		_apply_tendency_passive(top[1])
		tendency_awakened.emit(top[1])
		return top[1]
	return ""

## 자각 시 1회 보상(드라마식 정체성 = 실제 능력). 죽은 트레이트 패시브를 대체.
func _apply_tendency_passive(kind: String):
	# 자각 = '성향(route) 정체성' 확정. player_route/route 플래그를 켜서
	# 이후 route 전용 이벤트(EventManager의 player_route 조건)가 반응하게 한다.
	match kind:
		"career":
			player_route = "직장형"
			flags["route_career"] = true
			work_performance = clampi(work_performance + 12, 0, 100)
			modify_stat("social_skill", 3)
			flags["pending_spec_career"] = true  # 전문화 분기 이벤트 큐
		"invest":
			player_route = "투자형"
			flags["route_invest"] = true
			modify_stat("investment_skill", 6)
			modify_stat("intelligence", 2)
			flags["pending_spec_invest"] = true
		"found":
			player_route = "창업형"
			flags["route_startup"] = true
			flags["founder_awakened"] = true
			modify_stat("luck", 3)
			modify_stat("intelligence", 2)
			flags["pending_spec_found"] = true

func add_item(item_id, quantity):
	var item = DataRegistry.get_item(item_id)
	if item.is_empty():
		return
	for owned in inventory:
		if owned.get("id", "") == item_id:
			owned["quantity"] = int(owned.get("quantity", 0)) + quantity
			stats_changed.emit()
			return
	var owned_item = item.duplicate(true)
	owned_item["quantity"] = quantity
	inventory.append(owned_item)
	stats_changed.emit()

func remove_item(item_id, quantity):
	for i in range(inventory.size()):
		if inventory[i].get("id", "") == item_id:
			inventory[i]["quantity"] = int(inventory[i].get("quantity", 1)) - quantity
			if int(inventory[i]["quantity"]) <= 0:
				inventory.remove_at(i)
			stats_changed.emit()
			return true
	return false

func add_log(message, log_type):
	var entry = {
		"turn": turn,
		"date": get_date_string(),
		"message": message,
		"type": log_type,
	}
	action_log.append(entry)
	if action_log.size() > 120:
		action_log.pop_front()
	log_added.emit(entry)

func get_date_string():
	return "%d년 %d월 %d주차" % [year, month, week_of_month]

func format_money(amount):
	var sign = ""
	if amount < 0:
		sign = "-"
	var abs_amount = abs(amount)
	if abs_amount >= 100_000_000:
		return "%s%.1f억원" % [sign, abs_amount / 100_000_000.0]
	if abs_amount >= 10_000:
		return "%s%.0f만원" % [sign, abs_amount / 10_000.0]
	return "%s%.0f원" % [sign, abs_amount]

func format_event_text(text: String) -> String:
	var job_name: String = str(current_job.get("name", "무직"))
	var housing_info: Dictionary = get_housing_info()
	var total_assets: float = get_total_asset_value()
	var loan_total: float = get_loan_total()
	return text \
		.replace("{name}", player_name) \
		.replace("{job}", job_name) \
		.replace("{housing}", str(housing_info.get("name", "고시원"))) \
		.replace("{month}", str(month)) \
		.replace("{year}", str(year)) \
		.replace("{week}", str(week_of_month)) \
		.replace("{turn}", str(turn)) \
		.replace("{money}", format_money(money)) \
		.replace("{cash}", format_money(money)) \
		.replace("{assets}", format_money(total_assets)) \
		.replace("{total_assets}", format_money(total_assets)) \
		.replace("{net_worth}", format_money(total_assets)) \
		.replace("{income}", format_money(monthly_income)) \
		.replace("{expense}", format_money(fixed_expense)) \
		.replace("{debt}", format_money(loan_total)) \
		.replace("{loan}", format_money(loan_total))

func get_total_asset_value():
	var total = money
	for asset_id in portfolio:
		var holding: Dictionary = portfolio[asset_id]
		total += float(holding.get("quantity", 0.0)) * float(market_prices.get(asset_id, holding.get("avg_price", 0.0)))
	return total - get_loan_total()

# ── 신용등급 — 자산·직장·부채가 대출의 조건을 정한다 ──────────────
## 신용점수 1~100. 고용·근속·소득·순자산이 올리고, 부채 비율·신용 사건이 깎는다.
func get_credit_score() -> int:
	var s := 30.0
	if monthly_income > 0:
		s += 15.0                                            # 고용 상태
		s += minf(float(job_tenure) * 0.5, 12.0)             # 근속 (최대 +12)
		s += minf(monthly_income / 1_000_000.0 * 2.0, 14.0)  # 소득 (최대 +14)
	var net: float = get_total_asset_value()
	s += clampf(net / 10_000_000.0, 0.0, 20.0)               # 순자산 1천만당 +1 (최대 +20)
	var debt: float = get_loan_total()
	if debt > 0.0:
		var ratio: float = debt / maxf(1.0, maxf(0.0, net) + debt)
		s -= ratio * 25.0                                    # 부채 비율 (최대 -25)
	if flags.get("was_broke_once", false):
		s -= 8.0                                             # 잔고 바닥 이력
	s += clampf(float(reputation) * 0.1, 0.0, 5.0)           # 평판 (최대 +5)
	return clampi(int(s), 1, 100)

## 1(우량)~10(위험) 등급. 1~3 우량 / 4~6 보통 / 7~8 주의 / 9~10 위험.
func get_credit_grade() -> int:
	return clampi(10 - (get_credit_score() - 5) / 10, 1, 10)

func get_credit_grade_label() -> String:
	var g := get_credit_grade()
	if g <= 3: return "우량"
	if g <= 6: return "보통"
	if g <= 8: return "주의"
	return "위험"

## 변동금리 — 매달 현재 등급으로 이자를 계산한다.
func get_loan_rate(product: String) -> float:
	var g := get_credit_grade()
	match product:
		"bank":   return 0.004 + float(g - 1) * 0.0008   # 1등급 월 0.4% ~ 7등급 0.88%
		"second": return 0.012 + float(g) * 0.0008       # 1등급 월 1.28% ~ 10등급 2.0%
	return 0.02

# ── 대출 조작 ─────────────────────────────────────────────────────
func get_loan_total() -> float:
	var t := 0.0
	for p in loans:
		t += float(loans[p])
	return t

func get_loan_limit(product: String) -> float:
	var g := get_credit_grade()
	match product:
		"bank":
			# 1금융은 직장 + 신용 7등급 이내. 무직·저신용은 문턱을 못 넘는다.
			if monthly_income <= 0 or g >= 8:
				return 0.0
			return monthly_income * float(20 - 2 * g)        # 1등급 소득 18배 ~ 7등급 6배
		"second":
			# 제2금융은 누구나 — 대신 등급이 낮을수록 한도도 작고 이자는 비싸다.
			return 10_000_000.0 + float(10 - g) * 4_000_000.0  # 1등급 4,600만 ~ 10등급 1,000만
	return 0.0

func borrow(product: String, amount: float) -> bool:
	if amount <= 0 or not LOAN_PRODUCTS.has(product):
		return false
	var owed := float(loans.get(product, 0.0))
	if owed + amount > get_loan_limit(product) + 1.0:
		return false
	loans[product] = owed + amount
	add_money(amount)
	var info: Dictionary = LOAN_PRODUCTS[product]
	add_log("%s %s %s 대출 실행 — 매달 이자가 먼저 나간다." % [info["emoji"], info["name"], format_money(amount)], "money")
	stats_changed.emit()
	return true

func repay(product: String, amount: float) -> bool:
	var owed := float(loans.get(product, 0.0))
	if owed <= 0.0 or amount <= 0.0:
		return false
	amount = minf(amount, owed)
	amount = minf(amount, maxf(0.0, money))
	if amount <= 0.0:
		return false
	loans[product] = owed - amount
	add_money(-amount)
	var info: Dictionary = LOAN_PRODUCTS[product]
	add_log("%s %s %s 상환 — 남은 원금 %s." % [info["emoji"], info["name"], format_money(amount), format_money(loans[product])], "money")
	stats_changed.emit()
	return true

func get_wealth_tier():
	var total = get_total_asset_value()
	if total >= 600_000_000:
		return "강남 입성권"
	if total >= 200_000_000:
		return "내 집 마련"
	if total >= 80_000_000:
		return "전세 탈출"
	if total >= 20_000_000:
		return "종잣돈 모으는 중"
	return "고시원 생존자"

func check_game_over():
	if is_game_over:
		return
	# 자산 마일스톤 플래그 자동 추적 (이벤트 조건용)
	var total_now = get_total_asset_value()
	if total_now > peak_asset:
		peak_asset = total_now
	if total_now >= 100_000_000 and not flags.get("asset_100m_reached", false):
		flags["asset_100m_reached"] = true
		add_log("💰 자산 1억 돌파 — 종잣돈이 생겼다.", "money")
	if total_now >= 500_000_000 and not flags.get("asset_500m_reached", false):
		flags["asset_500m_reached"] = true
		add_log("💰 자산 5억 돌파 — 길이 보이기 시작한다.", "money")
	if total_now >= 1_000_000_000 and not flags.get("asset_1b_reached", false):
		flags["asset_1b_reached"] = true
		add_log("💰 자산 10억 돌파 — 30억의 3분의 1. 이제부터 가속이 붙는다.", "money")
	if total_now >= 2_000_000_000 and not flags.get("asset_2b_reached", false):
		flags["asset_2b_reached"] = true
		add_log("🔥 자산 20억 돌파 — 강남이 손에 잡힐 듯하다. 남은 건 10억.", "money")
	if total_now >= 2_700_000_000 and not flags.get("asset_2_7b_reached", false):
		flags["asset_2_7b_reached"] = true
		add_log("🔥 자산 27억 — 마지막 고비다. 강남 입성이 코앞이다.", "money")
	# ── 즉시 게임오버 (실패) ──────────────────────────
	if health <= 0:
		finish_run("burnout"); return
	if mental <= 0:
		finish_run("mental_break"); return
	# 파산 = 순자산 기준 (현금 + 포트폴리오 - 대출원금). 빌린 돈을 날리면 여기로 온다.
	if total_now < -200_000_000:
		finish_run("debt_spiral"); return
	if total_now < -100_000_000:
		finish_run("bankruptcy"); return
	if addiction_tendency >= 90:
		finish_run("crypto_ghost"); return

	# ══ NG+ 전용 엔딩 — MetaProgression 조건 필요 ══════════
	var _mp_meta = MetaProgression.data

	# full_circle: 상철 진실 알고 시작, 30억, 아버지 생존, 상철 청산 or 정면돌파
	if _mp_meta.get("sangchul_truth_ever_known", false) \
			and total_now >= 3_000_000_000.0 \
			and flags.get("father_reconciled", false) \
			and not flags.get("father_passed", false) \
			and (flags.get("ng_confronted_sangchul_early", false) or flags.get("sangchul_reported", false)):
		finish_run("full_circle"); return

	# second_love: 다은 경험 후 재도전, 다은과 함께 + 자산 10억
	if _mp_meta.get("daeun_ending_ever_seen", false) \
			and flags.get("ng_committed_to_daeun", false) \
			and flags.get("arc_daeun_04b_seen", false) \
			and total_now >= 1_000_000_000.0:
		finish_run("second_love"); return

	# guardian: 아버지 잃은 경험 후 재도전, 아버지 우선으로 지킴
	if _mp_meta.get("father_passed_ever", false) \
			and flags.get("ng_father_priority", false) \
			and flags.get("father_reconciled", false) \
			and not flags.get("father_passed", false):
		finish_run("guardian"); return

	# ── 강남 입성 = 자산 30억 달성 = 즉시 성공 엔딩 ──────
	# 30억으로 강남 아파트를 매매한다. 게임의 최종 목표.
	if total_now >= 3_000_000_000:
		# ★ 히든 이스터에그 — 첫 해(33세=챕터1)에 30억은 거의 불가능한 초고속 달성.
		#   변칙 플레이(경마/투자 대박)에 대한 보상 엔딩. 인물 아크는 챕터2+라
		#   아직 아무도 못 만난 상태 → 빈 집 대신 '신화' 엔딩으로 인정해준다.
		if age <= 33:
			finish_run("instant_legend"); return
		# 어떤 사람이 되어 입성했는가로 엔딩 분기
		if flags.get("fell_to_darkness", false) or flags.get("crossed_line", false):
			finish_run("jaehyuk_way"); return        # 최재혁의 방식
		if relationships.is_empty() and not has_any_close_relationship():
			# 아버지와도 화해 못 했으면 진짜 아무도 없는 집
			if not flags.get("father_reconciled", false):
				finish_run("empty_house"); return     # 빈 집
			finish_run("lonely_rich"); return         # 외로운 부자 — 돈만 남음
		finish_run("gangnam_dream"); return           # 강남드림 (정상)

	# 특수 성공 엔딩 (강남 외 경로)
	if flags.get("startup_exit", false):
		finish_run("startup_exit"); return
	# 크리에이터 성공 (바이럴 + 3억 달성 — 강남보다 낮아도 인정)
	if flags.get("creator_viral", false) and total_now >= 300_000_000:
		finish_run("creator_success"); return
	# 정계 입성 (보좌관 → 국회의원 당선 — 강남 대신 여의도)
	if flags.get("political_winner", false):
		finish_run("political_fix"); return

	# ── 38세 = 타임리밋 (5년 종료) ────────────────────
	if age >= 38:
		var total = get_total_asset_value()
		# 연인 엔딩
		if get_cast_stage("daeun") in ["lover", "together"]:
			finish_run("with_daeun"); return          # 다은과 함께
		if get_cast_stage("jiyeon") in ["lover", "honest_together"]:
			finish_run("jiyeon_man"); return          # 한지연의 남자
		# 도박 중독을 이겨낸 사람 — 강남엔 못 갔어도, 가장 깊은 구덩이에서 올라왔다.
		# 30억 도달자는 이미 위에서 gangnam_dream 분기 → 여기 오는 건 미달자.
		# 이 런의 진짜 서사가 '회복'이었던 사람에게 주는 구원 엔딩.
		if flags.get("beat_addiction", false):
			finish_run("gambling_recovery"); return
		# 평판 전설 (평판 80+)
		if reputation >= 80:
			finish_run("reputation_legend"); return
		# 갈아탄 사다리 (이직/커리어 성장 — 직장 유지 + 이직 성공 or 최고 직급 + 1억+)
		# 30억/10억/5억 대박은 위에서 이미 분기 → 여기 오는 건 "직장으로 착실히 올라온" 사람.
		if not current_job.is_empty() and total >= 100_000_000 \
				and (flags.get("job_changed_success", false) or int(flags.get("max_job_tier", 0)) >= 4):
			finish_run("career_climber"); return
		# 정석의 정점 (1B+, 정석 압도)
		if total >= 1_000_000_000 and route_orthodox - route_unorthodox >= 15:
			finish_run("orthodox_pinnacle"); return
		# 아웃사이더의 승리 (500M+, 비정석 압도)
		if total >= 500_000_000 and route_unorthodox - route_orthodox >= 15:
			finish_run("unorthodox_legend"); return
		# 조기 은퇴 (500M+, 무직 선택)
		if total >= 500_000_000 and current_job.is_empty():
			finish_run("early_retirement"); return
		# 재테크 달인 (500M+, 투자감각 고수)
		if total >= 500_000_000 and investment_skill >= 55:
			finish_run("investment_master"); return
		# 안정 성공 (1B+, 위 조건 미해당)
		if total >= 1_000_000_000:
			finish_run("stable_success"); return
		# 나만의 균형 (1억+, 정석·비정석 균등 10+ each)
		if total >= 100_000_000 and route_orthodox >= 8 and route_unorthodox >= 8 \
				and abs(route_orthodox - route_unorthodox) <= 5:
			finish_run("balanced_life"); return
		# 건강한 삶 (건강+정신 양호, 관계 있음)
		if health >= 70 and mental >= 70 and has_any_close_relationship():
			finish_run("healthy_retirement"); return
		# 공허한 성공 (정석 많이 쌓았는데 자산 없음 — 허탈한 결말)
		if route_orthodox >= 20 and total < 300_000_000:
			finish_run("orthodox_hollow"); return
		# 아버지 화해
		if flags.get("father_reconciled", false):
			finish_run("late_call"); return           # 늦은 전화 (화해)
		# 기록자 — 강남드림 실패 수기가 소설이 됐다
		# 조건: 이벤트 90개 이상 경험(탐험가 성향) + 지력 65+ + 고시원 + 자산 3억 미만
		# 실패의 기록이 가장 많은 사람에게 닿는 아이러니한 A 엔딩
		if events_seen >= 90 and intelligence >= 65 \
				and housing == "gosiwon" and total < 300_000_000:
			finish_run("writer"); return
		finish_run("ordinary_life")                   # 평범한 결말

func finish_run(ending_id):
	is_game_over = true
	var _final_total = get_total_asset_value()
	if _final_total > peak_asset:
		peak_asset = _final_total
	MetaProgression.record_run({
		"ending_id": ending_id,
		"turn": turn,
		"age": age,
		"total_assets": _final_total,
		"trait": "",
		"run_theme": run_theme,
		"tendency_realized": tendency_realized,
		"route_orthodox": route_orthodox,
		"route_unorthodox": route_unorthodox,
		"events_seen": events_seen,
		"peak_asset": peak_asset,
		"playstyle": get_playstyle_label(),
	})
	game_over.emit(ending_id)

func serialize():
	return {
		"player_name": player_name,
		"player_background": player_background,
		"age": age,
		"year": year,
		"month": month,
		"week_of_month": week_of_month,
		"turn": turn,
		"is_game_over": is_game_over,
		"housing": housing,
		"money": money,
		"monthly_income": monthly_income,
		"fixed_expense": fixed_expense,
		"health": health,
		"mental": mental,
		"intelligence": intelligence,
		"social_skill": social_skill,
		"appearance": appearance,
		"investment_skill": investment_skill,
		"luck": luck,
		"reputation": reputation,
		"action_points": action_points,
		"max_action_points": max_action_points,
		"tutorial_step": tutorial_step,
		"route_orthodox": route_orthodox,
		"route_unorthodox": route_unorthodox,
		"tendency": tendency,
		"tendency_realized": tendency_realized,
		"month_focus": month_focus,
		"housing_months": housing_months,
		"gambling_tendency": gambling_tendency,
		"addiction_tendency": addiction_tendency,
		"current_job": current_job,
		"job_tenure": job_tenure,
		"work_performance": work_performance,
		"milestones_reached": milestones_reached,
		"portfolio": portfolio,
		"loans": loans,
		"relationships": relationships,
		"cast": cast,
		"player_route": player_route,
		"inventory": inventory,
		"news_log": news_log,
		"event_log": event_log,
		"action_log": action_log,
		"flags": flags,
		"deferred_events": deferred_events,
		"market_prices": market_prices,
		"price_history": price_history,
		"market_context": market_context,
		"run_theme_categories": run_theme_categories,
		"run_theme": run_theme,
		"unlocked_stat_thresholds": unlocked_stat_thresholds,
		"difficulty": difficulty,
		"events_seen": events_seen,
		"peak_asset": peak_asset,
	}

func load_from_dict(data):
	var int_fields = [
		"age", "year", "month", "week_of_month", "turn",
		"health", "mental", "intelligence", "social_skill", "appearance",
		"investment_skill", "luck", "reputation",
		"gambling_tendency", "addiction_tendency",
		"job_tenure", "work_performance",
		"action_points", "max_action_points", "tutorial_step",
		"route_orthodox", "route_unorthodox", "events_seen",
	]
	var allowed = serialize().keys()
	for key in data:
		if not allowed.has(key):
			continue
		var value = data[key]
		if int_fields.has(key) and value is float:
			value = int(value)
		set(key, value)
	# 구버전 세이브 호환 — cast 없으면 기본값 채움
	if cast == null or cast.is_empty():
		cast = _default_cast()
	# 구버전 세이브 호환 — tendency 없으면 기본값
	if typeof(tendency) != TYPE_DICTIONARY or tendency.is_empty():
		tendency = {"career": 0, "invest": 0, "found": 0}
	# 구버전 세이브 호환 — run_theme 없으면 run_theme_categories로 역추론
	if run_theme == "자유런" and not run_theme_categories.is_empty():
		var cat_str = ",".join(run_theme_categories)
		if "investment" in cat_str and "finance" in cat_str:
			run_theme = "투자런"
		elif "social" in cat_str and "relationship" in cat_str:
			run_theme = "인맥런"
		elif "jobs" in cat_str and "health" in cat_str:
			run_theme = "성실런"
	# 구버전 세이브 호환 — unlocked_stat_thresholds 없으면 빈 딕셔너리 유지 (기본값)
	if typeof(unlocked_stat_thresholds) != TYPE_DICTIONARY:
		unlocked_stat_thresholds = {}
	# 구버전 세이브 호환 — loans 없으면 무대출 상태
	if typeof(loans) != TYPE_DICTIONARY or loans.is_empty():
		loans = {"bank": 0.0, "second": 0.0}
	# 구버전 세이브 호환 — difficulty 없거나 미지 값이면 현실 모드
	if not DIFFICULTY_DATA.has(difficulty):
		difficulty = "현실"
	# 구버전 세이브 호환 — deferred_events 없으면 빈 배열
	if typeof(deferred_events) != TYPE_ARRAY:
		deferred_events = []
	stats_changed.emit()

## 그림자 이벤트 — N턴 후 자동 발동 예약
func add_deferred_event(event_id: String, delay: int) -> void:
	deferred_events.append({"event_id": event_id, "trigger_turn": turn + delay})

## 현재 턴에 발동할 그림자 이벤트 목록 반환 (소비 처리 포함)
func pop_ready_deferred_events() -> Array:
	var ready: Array = []
	var remaining: Array = []
	for entry in deferred_events:
		if int(entry.get("trigger_turn", 9999)) <= turn:
			ready.append(str(entry.get("event_id", "")))
		else:
			remaining.append(entry)
	deferred_events = remaining
	return ready
