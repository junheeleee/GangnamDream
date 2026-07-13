extends Node

signal stats_changed()
signal money_changed(new_amount: float)
signal turn_advanced(new_turn: int)
signal game_over(ending_id: String)
signal log_added(entry: Dictionary)
signal run_started()
signal stat_threshold_crossed(stat_name: String, threshold: int)
signal tendency_awakened(kind: String)
signal clue_added(clue_id: String)
signal thought_completed(thought_id: String)
# Codex 테마색 구독용 — norm(-1~+1) 부드러운 보간, stage(-2~+2) 이산 효과
signal moral_tint_changed(norm: float, stage: int)

const STAT_THRESHOLDS: Array = [30, 50, 70]
var unlocked_stat_thresholds: Dictionary = {}

const DEMO_FEATURE := "gangnam_demo"
const DEMO_TEST_ARG := "--demo-build"
const DEMO_TURN_LIMIT: int = 24   # 6개월 × 4주

func is_demo_build() -> bool:
	# Export preset feature가 정본이다. 명시적 인자는 에디터/CI 게이트에서만 사용한다.
	return OS.has_feature(DEMO_FEATURE) or OS.get_cmdline_user_args().has(DEMO_TEST_ARG)

func has_reached_demo_limit() -> bool:
	return is_demo_build() and turn > DEMO_TURN_LIMIT

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
const DIFFICULTY_TEXT_EN := {
	"드라마": {
		"name": "Drama Mode",
		"tagline": "Story first",
		"desc": "Start with KRW 2M / lighter monthly pressure / betting odds +4pp. For players here for the drama.",
	},
	"현실": {
		"name": "Reality Mode",
		"tagline": "Seoul as intended",
		"desc": "Default balance. KRW 500K, 5 years, KRW 3B. The intended tension.",
	},
	"지옥고": {
		"name": "Hell Room Mode",
		"tagline": "Seoul is like this",
		"desc": "Start with KRW 300K / harsher monthly pressure / betting odds -4pp. From a basement room to Gangnam.",
	},
}
var difficulty: String = "현실"

func get_difficulty_data() -> Dictionary:
	var data: Dictionary = DIFFICULTY_DATA.get(difficulty, DIFFICULTY_DATA["현실"]).duplicate(true)
	if LocaleManager.is_english() and DIFFICULTY_TEXT_EN.has(difficulty):
		for key in DIFFICULTY_TEXT_EN[difficulty]:
			data[key] = DIFFICULTY_TEXT_EN[difficulty][key]
	return data

# ── 대출 — 빚으로 판을 키운다 ─────────────────────────────────────
# 빚은 순자산(get_total_asset_value)에서 차감되고, 파산 판정도 순자산 기준.
# 빌린 돈을 베팅에 넣을 수 있지만, 날리면 순자산이 -1억(파산 라인)에 다가간다.
# 한도와 금리는 신용등급(get_credit_grade)이 결정한다. 금리는 변동금리 —
# 등급이 떨어지면(실직·자산 손실·과다 부채) 보유 중인 빚의 이자도 같이 오른다.
const LOAN_PRODUCTS := {
	"bank":   {"name": "1금융 신용대출", "name_en": "Prime bank credit loan", "emoji": "🏦"},
	"second": {"name": "제2금융 대출",   "name_en": "Secondary lender loan",  "emoji": "💳"},
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
# AP 축 시스템 (돈 vs 사람) — docs/AP_REDESIGN.md Phase 1
var grind_streak_weeks: int = 0   # 연속 그라인드-only 주
var money_weeks_total: int = 0    # 통계: 돈축을 쓴 주
var human_weeks_total: int = 0    # 통계: 사람축을 챙긴 주
var loop_tint_spent: float = 0.0  # 루프 드립으로 깎은 tint 누적 (상한 -20)
# ── 몽타주 시간 압축 (docs/AP_REDESIGN.md Phase B) ──
# week_routine: 루틴 슬롯 2개 — "study"/"rest"/"save"/"network". 몽타주가 이 배분대로 주를 흘려보낸다.
var week_routine: Array = []
# 이 달의 축 배분 — 월말 몽타주 요약("돈에 N주, 사람에게 M주")용. 월말마다 last_*로 넘긴다.
var month_money_weeks: int = 0
var month_human_weeks: int = 0
var last_month_money_weeks: int = 0
var last_month_human_weeks: int = 0
var tutorial_step = 3

var route_orthodox: int = 0
var route_unorthodox: int = 0
var month_focus: String = ""
# ── MORAL_TINT — 색으로 보는 자기 파괴 (docs/MORAL_TINT.md) ──
# −100(새까망/돈) ↔ 0(회색/시작) ↔ +100(새하양/인간). 플레이어에겐 숫자 미노출, 색으로만.
var moral_tint: float = 0.0
var moral_band_last: int = 0   # 직전 밴드(−2~+2). 전이 비네트 트리거용
var pending_tint_vignette: Dictionary = {}  # transient: {"from":int,"to":int} — UI가 표시 후 비움
var pending_scar_vignette: String = ""     # transient: "crossed_line"|"chose_money_over_father" — 첫 설정 시 한 번만
var housing_months: Dictionary = {}

# ── AP 행동 축 — 돈을 좇는 주간 vs 사람/회복에 남긴 주간 ─────────────
# 플레이어에게 도덕 점수를 보여주지 않고, 반복 루프가 어떤 삶의 모양으로 굳는지만 기록한다.
var action_axis_this_week: Dictionary = {"money": 0, "human": 0}
# 서울 지도 M1 — 이번 주 실제로 시간을 쓴 장소와 최근 동선. 수치 평가는 노출하지 않는다.
var action_places_this_week: Dictionary = {}
var recent_action_places: Array = []
# 인물별 연락 기록 — 리캡 카드의 "잔인한 통계"용 원장 (person_id → 횟수 / 마지막 턴)
var contact_counts: Dictionary = {}
var last_contact_turn: Dictionary = {}
# 현재 런에서 실제로 본 장면을 연차별로 기록한다. 영구 갤러리의 seen_scenes와
# 분리해야 이전 런의 기억이 이번 런 연말 후보에 섞이지 않는다.
var run_seen_scenes_by_year: Dictionary = {}
# 플레이어가 각 연말에 직접 남긴 한 장면. key는 year_scene_1..5, value는 event id.
var year_scenes: Dictionary = {}

func note_contact(person_id: String) -> void:
	contact_counts[person_id] = int(contact_counts.get(person_id, 0)) + 1
	last_contact_turn[person_id] = turn

func get_run_year_index() -> int:
	return clampi(floori(float(maxi(turn, 1) - 1) / 48.0) + 1, 1, 5)

func record_run_scene_seen(scene_id: String) -> bool:
	if scene_id.is_empty():
		return false
	var key := str(get_run_year_index())
	var scenes: Array = run_seen_scenes_by_year.get(key, [])
	if scenes.has(scene_id):
		return false
	scenes.append(scene_id)
	run_seen_scenes_by_year[key] = scenes
	return true

func _year_scene_family(scene_id: String) -> String:
	for prefix in ["cafe_", "arc_intro_", "arc_daeun_", "arc_jiyeon_", "arc_father_", "arc_sangchul_", "arc_jaehyuk_", "arc_hyunsu_"]:
		if scene_id.begins_with(prefix):
			return prefix
	return scene_id

func _year_scene_score(event: Dictionary, order: int) -> int:
	var score := order
	var tags: Array = event.get("tags", [])
	if tags.has("arc"):
		score += 30
	if str(event.get("rarity", "")) == "story":
		score += 20
	if bool(event.get("timed", false)):
		score += 25
	for tag in ["romance", "father", "daeun", "jiyeon", "sangchul", "jaehyuk", "hyunsu", "hidden"]:
		if tags.has(tag):
			score += 18
	if not str(event.get("cg", "")).is_empty() or not str(event.get("result_cg", "")).is_empty():
		score += 120
	else:
		for choice in event.get("choices", []):
			if choice is Dictionary and not str(choice.get("result_cg", "")).is_empty():
				score += 100
				break
	return score

func get_year_scene_candidates(year_index: int, limit: int = 4) -> Array:
	var scenes: Array = run_seen_scenes_by_year.get(str(clampi(year_index, 1, 5)), [])
	var rows: Array = []
	var families: Dictionary = {}
	for order in range(scenes.size() - 1, -1, -1):
		var scene_id := str(scenes[order])
		var event: Dictionary = DataRegistry.find_event(scene_id)
		if event.is_empty():
			continue
		var tags: Array = event.get("tags", [])
		if tags.has("chapter_card") or tags.has("year_close") or tags.has("year_scene_curation"):
			continue
		var family := _year_scene_family(scene_id)
		if families.has(family):
			continue
		var title := str(event.get("title", "")).strip_edges()
		if title.is_empty():
			continue
		families[family] = true
		rows.append({
			"id": scene_id,
			"title": title,
			"score": _year_scene_score(event, order),
			"order": order,
		})
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_score := int(a.get("score", 0))
		var b_score := int(b.get("score", 0))
		if a_score == b_score:
			return int(a.get("order", 0)) > int(b.get("order", 0))
		return a_score > b_score)
	return rows.slice(0, mini(maxi(limit, 0), rows.size()))

func build_year_scene_choices(year_index: int) -> Array:
	var choices: Array = []
	for row in get_year_scene_candidates(year_index, 4):
		var title := str(row.get("title", row.get("id", "")))
		choices.append({
			"text": LocaleManager.ui("「%s」", "“%s”") % title,
			"effects": {},
			"year_scene": {"year": year_index, "scene_id": str(row.get("id", ""))},
			"result_text": LocaleManager.ui(
				"그 해를 접으면, 「%s」이 가장 먼저 남았다." % title,
				"When that year folded shut, “%s” was the scene that remained." % title),
		})
	return choices

func record_year_scene(year_index: int, scene_id: String) -> bool:
	if year_index < 1 or year_index > 5 or scene_id.is_empty():
		return false
	for row in get_year_scene_candidates(year_index, 4):
		if str(row.get("id", "")) == scene_id:
			year_scenes["year_scene_%d" % year_index] = scene_id
			stats_changed.emit()
			return true
	return false

func get_year_scene_selection(year_index: int) -> String:
	return str(year_scenes.get("year_scene_%d" % clampi(year_index, 1, 5), ""))

func get_selected_year_scenes() -> Array:
	var selected: Array = []
	for year_index in range(1, 6):
		var scene_id := get_year_scene_selection(year_index)
		if scene_id.is_empty():
			continue
		var event: Dictionary = DataRegistry.find_event(scene_id)
		selected.append({
			"year": year_index,
			"id": scene_id,
			"title": str(event.get("title", scene_id)),
		})
	return selected

# ── 성향(직장/투자/창업) — 플레이로 누적, 임계점에서 '자각' ──────────
# 죽은 트레이트 시스템을 대체: 선택이 아니라 행동이 정체성을 만든다.
const TENDENCY_KINDS := ["career", "invest", "found"]
const TENDENCY_NAMES := {"career": "직장형", "invest": "투자형", "found": "창업형"}
const TENDENCY_NAMES_EN := {"career": "Career", "invest": "Investor", "found": "Founder"}
const TENDENCY_DESC := {
	"career": "성실하게 쌓아 올린다. 월급과 승진, 신용이 무기다.",
	"invest": "돈이 돈을 벌게 한다. 시장을 읽고 베팅한다.",
	"found":  "내 것을 만든다. 위험하지만 천장이 없다.",
}
const TENDENCY_DESC_EN := {
	"career": "Build steadily. Salary, promotions, and credit are your weapons.",
	"invest": "Let money make money. Read the market and place the bet.",
	"found":  "Build something of your own. Risky, but the ceiling disappears.",
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
var story_replay_mode: bool = false    # 회상 갤러리 열람 중에는 선택 효과를 적용하지 않음

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
# 발견 레이어 — 단서/생각정리 (추리·분석의 재미)
var clues: Array = []              # 획득한 단서 id 목록
var thoughts_done: Array = []      # 완료한 생각(추론) id 목록
var active_thought: Dictionary = {}  # {"id": String, "turns_left": int} — 현재 정리 중인 생각 (1슬롯)
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
	var fallback_name := LocaleManager.ui("김민준", "Kim Minjun")
	if LocaleManager.is_english() and chosen_name == "김민준":
		chosen_name = fallback_name
	player_name = chosen_name if not chosen_name.strip_edges().is_empty() else fallback_name
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
	grind_streak_weeks = 0
	money_weeks_total = 0
	human_weeks_total = 0
	loop_tint_spent = 0.0
	week_routine = []
	month_money_weeks = 0
	month_human_weeks = 0
	last_month_money_weeks = 0
	last_month_human_weeks = 0
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
	moral_tint = 0.0
	moral_band_last = 0
	month_focus = ""
	housing_months = {}
	action_axis_this_week = {"money": 0, "human": 0}
	action_places_this_week = {}
	recent_action_places = []
	contact_counts = {}
	last_contact_turn = {}
	run_seen_scenes_by_year = {}
	year_scenes = {}
	tendency ={"career": 0, "invest": 0, "found": 0}
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
	add_log(LocaleManager.ui("새 런 시작: %s / 출발점: %s", "New run: %s / Start: %s") % [
		_localized_route_label(chosen_route),
		_localized_profile_label(starting_profile)
	], "system")
	stats_changed.emit()
	run_started.emit()
	moral_tint_changed.emit(moral_tint_norm(), moral_stage())  # Codex 초기 시각 상태 설정

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
	var stat_en = {
		"investment_skill": "Investing", "intelligence": "Intelligence", "social_skill": "Social",
		"luck": "Luck", "mental": "Mental", "money": "Funds",
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
			parts.append(LocaleManager.ui("자금 +%s", "Funds +%s") % format_money(float(amount)))
		else:
			var stat_label: String = str((stat_en if LocaleManager.is_english() else stat_kr).get(str(stat), str(stat)))
			parts.append("%s %+d" % [stat_label, amount])
	if not parts.is_empty():
		add_log(LocaleManager.ui(
			"🏆 칭호 보너스: %s  (수집한 칭호가 힘이 된다)",
			"🏆 Title bonus: %s  (collected titles give you strength)"
		) % " · ".join(parts), "system")

func _localized_route_label(route: String) -> String:
	if not LocaleManager.is_english():
		return route
	var labels := {
		"직장형": "Career",
		"투자형": "Investor",
		"창업형": "Founder",
		"none": "Default",
	}
	return str(labels.get(route, route))

func _localized_profile_label(profile: String) -> String:
	if not LocaleManager.is_english():
		return profile
	var labels := {
		"백수": "Unemployed",
	}
	return str(labels.get(profile, profile))

func tendency_desc(kind: String) -> String:
	if LocaleManager.is_english():
		return str(TENDENCY_DESC_EN.get(kind, TENDENCY_DESC.get(kind, "")))
	return str(TENDENCY_DESC.get(kind, ""))

func get_loan_name(product: String) -> String:
	var info: Dictionary = LOAN_PRODUCTS.get(product, {})
	var key := "name_en" if LocaleManager.is_english() else "name"
	return str(info.get(key, info.get("name", product)))

func get_job_display_name(job: Dictionary = {}) -> String:
	var source: Dictionary = current_job if job.is_empty() else job
	if source.is_empty():
		return LocaleManager.ui("무직", "Unemployed")
	var job_id := str(source.get("id", ""))
	if not job_id.is_empty():
		var localized: Dictionary = DataRegistry.get_job(job_id)
		if not localized.is_empty():
			return str(localized.get("name", source.get("name", job_id)))
	return str(source.get("name", LocaleManager.ui("직장", "Job")))

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
				flags["has_job"] = true
				flags["job_started_turn"] = 0
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
				flags["has_job"] = true
				flags["job_started_turn"] = 0
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
	if LocaleManager.is_english():
		label_map = {
			"investment": "Investing", "jobs": "Jobs", "social": "Social",
			"health": "Health", "relationship": "Relationships", "gambling": "Gambling", "finance": "Finance"
		}
	var a = label_map.get(pool[0], pool[0])
	var b = label_map.get(pool[1], pool[1])
	add_log(LocaleManager.ui(
		"🎲 이번 런 테마: [%s + %s] — 관련 이벤트가 더 자주 등장합니다.",
		"🎲 Run Theme: [%s + %s] — related events will appear more often."
	) % [a, b], "system")

func _apply_run_theme(theme: String) -> void:
	run_theme = theme
	match theme:
		"자유런":
			_roll_run_theme()
		"투자런":
			run_theme_categories = ["investment", "finance"]
			investment_skill += 5
			flags["theme_invest_run"] = true
			add_log(LocaleManager.ui("📈 [투자런] 시작 — 투자·재정 이벤트가 집중 등장합니다. 투자감각 +5.", "📈 [Investment Run] begins — investment and finance events appear more often. Investing +5."), "system")
		"인맥런":
			run_theme_categories = ["social", "relationship"]
			social_skill += 10
			flags["theme_network_run"] = true
			add_log(LocaleManager.ui("🤝 [인맥런] 시작 — 사회·관계 이벤트가 집중 등장합니다. 사교력 +10.", "🤝 [Network Run] begins — social and relationship events appear more often. Social +10."), "system")
		"청렴런":
			run_theme_categories = ["jobs", "health"]
			reputation += 10
			flags["theme_clean_run"] = true
			flags["no_gambling"] = true   # EventManager가 gambling 카테고리 이벤트 차단
			add_log(LocaleManager.ui("✨ [청렴런] 시작 — 도박 이벤트 없음. 평판 +10. 정직하게만 30억.", "✨ [Clean Run] begins — no gambling events. Reputation +10. Reach KRW 3B honestly."), "system")
		_:
			_roll_run_theme()

func _init_market_prices():
	for asset in DataRegistry.assets:
		market_prices[asset.get("id", "")] = float(asset.get("initial_price", asset.get("base_price", 10_000.0)))

func advance_calendar() -> bool:
	if is_game_over:
		return false
	finalize_action_axis_week()   # 지난 주를 무엇에 썼는지 정산 (돈 vs 사람)
	turn += 1
	week_of_month += 1
	var month_ended := false
	if week_of_month > 4:
		week_of_month = 1
		month += 1
		month_ended = true
		# 지난 달의 축 배분을 몽타주/월말 요약이 읽을 수 있게 넘기고 새 달을 위해 리셋
		last_month_money_weeks = month_money_weeks
		last_month_human_weeks = month_human_weeks
		month_money_weeks = 0
		month_human_weeks = 0
		if month > 12:
			month = 1
			year += 1
			age += 1
	_tick_active_thought()
	turn_advanced.emit(turn)
	return month_ended

func get_housing_expense() -> float:
	return float(HOUSING_DATA.get(housing, HOUSING_DATA["gosiwon"]).get("expense", 800_000.0))

func get_housing_info() -> Dictionary:
	return HOUSING_DATA.get(housing, HOUSING_DATA["gosiwon"])

func get_housing_name(housing_id: String = "") -> String:
	var id := housing if housing_id.is_empty() else housing_id
	if LocaleManager.is_english():
		var names_en := {
			"gosiwon": "goshiwon",
			"oneroom": "one-room studio",
			"villa": "villa jeonse",
			"apartment": "apartment jeonse",
			"gangnam": "Gangnam apartment",
		}
		return str(names_en.get(id, id))
	return str(HOUSING_DATA.get(id, HOUSING_DATA["gosiwon"]).get("name", id))

func get_housing_display_name(housing_id: String = "") -> String:
	var id := housing if housing_id.is_empty() else housing_id
	if LocaleManager.is_english():
		var names_en := {
			"gosiwon": "Goshiwon Room",
			"oneroom": "One-room Studio",
			"villa": "Villa Jeonse",
			"apartment": "Apartment Jeonse",
			"gangnam": "Gangnam Apartment",
		}
		return str(names_en.get(id, id.capitalize()))
	return get_housing_name(id)

func can_upgrade_housing() -> bool:
	var info = get_housing_info()
	var next_id = str(info.get("next", ""))
	if next_id.is_empty():
		return false
	var next_info = HOUSING_DATA.get(next_id, {})
	return money >= float(next_info.get("req_cash", 0.0))

## 이사 직전, 획득 순서가 가장 오래된 유물 하나를 선택 비트에 예약한다.
## inventory 배열은 획득 순서를 보존하므로 별도 시각/턴 카운터를 만들지 않는다.
func prepare_housing_keepsake() -> String:
	if not can_upgrade_housing() or flags.get("arc_housing_keepsake_seen", false):
		return ""
	var pending_id := str(flags.get("pending_housing_keepsake_id", ""))
	if pending_id != "" and has_item(pending_id):
		return pending_id
	flags.erase("pending_housing_keepsake_id")
	for owned in inventory:
		var item_id := str(owned.get("id", ""))
		if item_id.begins_with("artifact_") and int(owned.get("quantity", 0)) > 0:
			flags["pending_housing_keepsake_id"] = item_id
			return item_id
	return ""

func get_pending_housing_keepsake_name() -> String:
	var item_id := str(flags.get("pending_housing_keepsake_id", ""))
	var item: Dictionary = DataRegistry.get_item(item_id)
	return str(item.get("name", item_id))

## StoryMode의 보존/처분 선택이 끝나는 순간, 사용자가 원래 요청했던 이사를 완료한다.
func resolve_housing_keepsake(decision: String) -> Dictionary:
	var item_id := str(flags.get("pending_housing_keepsake_id", ""))
	if item_id == "" or not has_item(item_id) or decision not in ["keep", "leave"]:
		return {"success": false, "message": LocaleManager.ui("남겨 둔 유물을 찾을 수 없습니다.", "The selected keepsake could not be found.")}
	var result := upgrade_housing()
	if not result.get("success", false):
		flags.erase("arc_housing_keepsake_seen")
		return result
	if decision == "leave":
		remove_item(item_id, 1)
	flags.erase("pending_housing_keepsake_id")
	return result

func upgrade_housing() -> Dictionary:
	var info = get_housing_info()
	var current_id := housing
	var next_id = str(info.get("next", ""))
	if next_id.is_empty():
		return {"success": false, "message": LocaleManager.ui("이미 최고 등급 주거입니다.", "You already have the best available housing.")}
	var next_info = HOUSING_DATA.get(next_id, {})
	if money < float(next_info.get("req_cash", 0.0)):
		return {"success": false, "message": LocaleManager.ui("자금이 부족합니다.", "Not enough cash.")}
	var deposit_diff = float(next_info.get("deposit", 0.0)) - float(info.get("deposit", 0.0))
	add_money(-deposit_diff)
	housing = next_id
	fixed_expense = get_housing_expense()
	flags["housing_moved_once"] = true
	add_log(LocaleManager.ui("이사: %s → %s (보증금 %s)", "Moved: %s → %s (deposit %s)") % [
		get_housing_name(current_id), get_housing_name(next_id), format_money(deposit_diff)
	], "system")
	stats_changed.emit()
	return {"success": true, "housing": next_info}

func apply_monthly_pressure():
	fixed_expense = get_housing_expense()
	add_money(monthly_income - fixed_expense)
	# 첫 월급 수령 플래그 — 투자 기능 잠금 해제 트리거
	if monthly_income > 0 and not flags.get("has_received_paycheck", false):
		flags["has_received_paycheck"] = true
		add_log(LocaleManager.ui("💳 첫 월급이 통장에 들어왔다. 이제 투자를 시작할 수 있다.", "💳 Your first paycheck hit the account. Investing is now available."), "job")

	# ── 대출 이자 — 빚은 숨만 쉬어도 매달 나간다 (변동금리: 현재 등급 기준) ──
	var loan_interest := 0.0
	for p in loans:
		loan_interest += float(loans[p]) * get_loan_rate(p)
	if loan_interest > 0.0:
		add_money(-loan_interest)
		modify_stat("mental", -1)
		add_log(LocaleManager.ui(
			"🏦 대출 이자 %s 납부 (원금 %s, 신용 %d등급).",
			"🏦 Loan interest paid: %s (principal %s, credit grade %d)."
		) % [format_money(loan_interest), format_money(get_loan_total()), get_credit_grade()], "money")

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
				add_log(LocaleManager.ui("🏚 고시원 생활: 옆방 소음, 공용 화장실... 정신이 갉아먹힌다.", "🏚 Goshiwon life: next-room noise, shared bathrooms... it wears down the mind."), "event")
		"villa", "apartment":
			modify_stat("mental", 1)  # 더 나은 주거 = 삶의 질 ↑

	# ── 인연 패시브 — 깊어진 관계가 서울살이의 바닥을 받쳐준다 ──────
	# (아크 보상은 엔딩 분기가 아니라 런 중 유지비 절감으로 환류)
	if get_cast_stage("father") in ["reconciled", "connected", "hopeful", "close"]:
		modify_stat("mental", 1)
		if randf() < 0.18:
			add_log(LocaleManager.ui("📞 아버지와 짧은 통화. 별 말은 없었지만 바닥이 생긴 기분이다.", "📞 A short call with Dad. Not much was said, but it felt like finding solid ground."), "relationship")
	if get_cast_stage("jiyeon") in ["honest_together", "lover"] \
			or get_cast_stage("daeun") in ["lover", "together", "close"]:
		modify_stat("mental", 1)
		if randf() < 0.18:
			add_log(LocaleManager.ui("💬 잠들기 전 주고받은 메시지 몇 줄이 하루를 닫아준다.", "💬 A few messages before sleep help close the day."), "relationship")
	if get_cast_stage("sangchul") in ["trusted", "mentoring", "guardian"] and turn % 4 == 0:
		modify_stat("investment_skill", 1)
		add_log(LocaleManager.ui("🏢 임상철의 지나가는 말들이 어느새 감각이 되고 있다.", "🏢 Lim Sangchul's offhand comments are slowly becoming instinct."), "relationship")

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
		add_log(LocaleManager.ui("💸 수입이 없다. 통장 잔고가 줄어가는 게 느껴진다.", "💸 No income. You can feel the account balance shrinking."), "event")


	# ── 중독 단계별 월간 압박 ────────────────────────────────────
	if addiction_tendency >= 70:
		modify_stat("mental", -2)
		if randf() < 0.5:
			add_log(LocaleManager.ui("🎰 '딱 한 번만 더.' 그 생각이 오늘도 머릿속을 맴돌았다.", "🎰 'Just one more.' The thought circled your head again today."), "event")
	elif addiction_tendency >= 50:
		modify_stat("mental", -1)
		if randf() < 0.4:
			add_log(LocaleManager.ui("🎰 다음 판이 자꾸 눈에 밟힌다.", "🎰 The next hand keeps pulling at your attention."), "event")

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
		add_log(LocaleManager.ui("🆘 잔고가 마이너스다. 이러다 진짜 쫓겨난다.", "🆘 Your balance is negative. At this rate, you could really get pushed out."), "money")
	elif money < 300_000:
		modify_stat("mental", -2)
		add_log(LocaleManager.ui("😰 통장 잔고가 30만원 아래다. 이번 달을 버틸 수 있을까.", "😰 Your balance is under KRW 300K. Can you survive this month?"), "money")

	check_game_over()

func apply_choice(event, choice):
	if not event.is_empty() and event.has("id"):
		events_seen += 1
	apply_effects(choice.get("effects", {}))
	for rel_effect in choice.get("relationship_effects", []):
		apply_relationship_effect(rel_effect)
	for investment_effect in choice.get("investment_effects", []):
		apply_investment_effect(investment_effect)
	# 발견 레이어 — 선택지가 단서를 줄 수 있다: "clues": ["clue_x"]
	for clue_id in choice.get("clues", []):
		add_clue(str(clue_id))
	for flag_id in choice.get("flags", []):
		var fid := str(flag_id)
		var _was_set: bool = flags.get(fid, false)
		flags[fid] = true
		# 마인드셋 선택(arc_intro_02) → 성향 초기 시드
		match fid:
			"mindset_saver":    add_tendency("career", 6)
			"mindset_investor": add_tendency("invest", 6)
			"mindset_founder":  add_tendency("found", 6)
		# 흉터 플래그 최초 설정 → 비네트 대기 + 즉시 tint 상한 적용
		if not _was_set and fid in ["crossed_line", "chose_money_over_father"]:
			pending_scar_vignette = fid
			shift_moral_tint(0.0)  # delta=0, 상한만 즉시 적용
	# 이사 전 유물 비트 — 선택 결과와 원래 요청한 주거 상승을 한 원자적 장면으로 마친다.
	if choice.has("housing_keepsake"):
		resolve_housing_keepsake(str(choice["housing_keepsake"]))
	# 연말 큐레이션은 수치 효과 없이, 플레이어가 고른 실제 장면 ID만 런 기록에 남긴다.
	var year_scene: Variant = choice.get("year_scene", null)
	if year_scene is Dictionary:
		record_year_scene(int(year_scene.get("year", 0)), str(year_scene.get("scene_id", "")))
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
			flags["has_job"] = true
			flags["job_started_turn"] = turn
			add_log(LocaleManager.ui("💼 취업: %s", "💼 Hired: %s") % get_job_display_name(gj), "job")
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
		format_event_text(str(event.get("title", LocaleManager.ui("이벤트", "Event")))),
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

	# 성공 확률 = 기본 + luck 보정 + 난이도 보정 + 멘토(임상철) affinity 보정
	var rate: float = float(opp.get("success_rate", 0.5))
	rate += float(luck) * float(opp.get("luck_factor", 0.002))
	rate += float(get_difficulty_data().get("opp_bonus", 0.0))
	# 임상철 affinity 보정: 관계가 깊을수록 기회 성공률 상승
	var sangchul_aff: int = get_cast_affinity("sangchul")
	if sangchul_aff >= 35:
		rate += 0.15
	elif sangchul_aff >= 25:
		rate += 0.10
	elif sangchul_aff >= 15:
		rate += 0.05
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
		add_log(LocaleManager.ui("📈 베팅 성공! %s 벌었다.", "📈 Bet won! You earned %s.") % format_money(win), "money")
	else:
		# 실패 — 베팅금 x 손실비율 만큼 날림 (이미 차감됐으니 나머지 환급)
		var loss_ratio = clampf(float(opp.get("loss_ratio", 1.0)), 0.0, 1.0)
		var refund = stake * (1.0 - loss_ratio)
		add_money(refund)
		modify_stat("mental", -9)
		result = "lose"
		if opp.has("lose_flag"):
			flags[str(opp["lose_flag"])] = true
		add_log(LocaleManager.ui("📉 베팅 실패. %s 잃었다.", "📉 Bet lost. You lost %s.") % format_money(stake - refund), "money")
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
			"tint":
				shift_moral_tint(float(value))
			"give_items":
				for item_id in value:
					add_item(str(item_id), 1)
	stats_changed.emit()

# ── MORAL_TINT 엔진 (docs/MORAL_TINT.md) ──
# 인간성=하양(+) / 돈=검정(−). 누적식. 흉터(crossed_line·죽음 외면)는 상한을 영구 고정.
func shift_moral_tint(delta: float) -> void:
	var old_band: int = moral_stage()
	moral_tint = clampf(moral_tint + delta, -100.0, 100.0)
	# 영구 얼룩 — 상한 고정 (아무리 착하게 굴어도 완전히는 못 돌아온다)
	if flags.get("crossed_line", false):
		moral_tint = minf(moral_tint, -20.0)        # 상철 끝까지 이용·재혁의 방식 → 양수 불가
	elif flags.get("chose_money_over_father", false):
		moral_tint = minf(moral_tint, 0.0)           # 죽음 외면 → 하양 불가
	# 밴드 전이 감지 — 넘었으면 비네트 대기열에 기록(표시는 UI가). from은 시작 밴드 유지.
	var new_band: int = moral_stage()
	if new_band != old_band:
		if pending_tint_vignette.is_empty():
			pending_tint_vignette = {"from": old_band, "to": new_band}
		else:
			pending_tint_vignette["to"] = new_band
		moral_band_last = new_band
	moral_tint_changed.emit(moral_tint_norm(), moral_stage())

# −2(새까망) ~ +2(새하양). 이산 효과(틀어짐·돈 글로우)용.
func moral_stage() -> int:
	if moral_tint >= 60.0: return 2
	if moral_tint >= 20.0: return 1
	if moral_tint <= -60.0: return -2
	if moral_tint <= -20.0: return -1
	return 0

# −1.0 ~ +1.0. Codex 테마색 부드러운 보간용.
func moral_tint_norm() -> float:
	return clampf(moral_tint / 100.0, -1.0, 1.0)

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
			"name": effect.get("name", LocaleManager.ui("새 인연", "New Connection")),
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

# AP 축 기록 — 각 행동이 돈축("money")인지 사람·자기축("human")인지 알린다.
# docs/AP_REDESIGN.md Phase 1. 숫자는 도덕 점수가 아니라 시간의 모양 — UI는 칩/서술로만 보여준다.
func register_action_axis(axis: String, place_id: String = "") -> void:
	match axis:
		"money":
			action_axis_this_week["money"] = int(action_axis_this_week.get("money", 0)) + 1
		"human":
			action_axis_this_week["human"] = int(action_axis_this_week.get("human", 0)) + 1
		_:
			return
	_register_action_place(place_id, axis)
	stats_changed.emit()

func _register_action_place(place_id: String, axis: String) -> void:
	if not place_id in ["home", "store", "work", "river", "city", "underground", "expedition"]:
		return
	var visit: Dictionary = action_places_this_week.get(place_id, {
		"count": 0,
		"money": 0,
		"human": 0,
	}).duplicate(true)
	visit["count"] = int(visit.get("count", 0)) + 1
	visit[axis] = int(visit.get(axis, 0)) + 1
	action_places_this_week[place_id] = visit
	if recent_action_places.is_empty() or str(recent_action_places[-1]) != place_id:
		recent_action_places.append(place_id)
		while recent_action_places.size() > 8:
			recent_action_places.pop_front()

# 주가 끝날 때(advance_calendar) 한 번 호출 — 그 주를 무엇에 썼는지 정산한다.
# 사람축을 한 번이라도 챙긴 주는 마모를 리셋. 돈에만 갈아넣은 주가 쌓이면 서서히 마모.
func finalize_action_axis_week() -> void:
	var money_count := int(action_axis_this_week.get("money", 0))
	var human_count := int(action_axis_this_week.get("human", 0))
	if money_count > 0:
		money_weeks_total += 1
		month_money_weeks += 1
	if human_count > 0:
		human_weeks_total += 1
		month_human_weeks += 1
		grind_streak_weeks = 0
	elif money_count > 0:
		grind_streak_weeks += 1
		if grind_streak_weeks % 4 == 0:
			modify_stat("mental", -1)
			# 루프 드립은 총 -20까지만 — 240주 그라인더가 도덕 예산을 루프만으로 태우지 못하게
			if loop_tint_spent > -20.0:
				shift_moral_tint(-1.0)
				loop_tint_spent -= 1.0
			add_log(LocaleManager.ui(
				"한 달 내내 돈 쪽으로만 시간이 흘렀다. 피로가 조금 남았다.",
				"A full month went only toward money. A little fatigue remained."
			), "system")
	action_axis_this_week = {"money": 0, "human": 0}
	action_places_this_week = {}

func restore_ap():
	action_points = max_action_points
	month_focus = ""
	stats_changed.emit()

func get_current_title() -> String:
	if mental <= 12: return LocaleManager.ui("번아웃 직전", "Near Burnout")
	if mental <= 20: return LocaleManager.ui("벼랑 끝의 청년", "On the Edge")
	if get_total_asset_value() < -50_000_000: return LocaleManager.ui("파산 위기자", "Bankruptcy Risk")
	# 삶의 모양 티어 — 자산보다 먼저. 칭호가 잔고가 아니라 삶의 모양을 비춘다.
	# 결혼 판정은 예식 아크 기준(_romance_is_married 미러) — 잃었으면(이혼/떠남) 내려간다.
	if (flags.get("arc_daeun_wedding_day_seen", false) and not flags.get("daeun_divorced", false)) \
			or (flags.get("arc_jiyeon_wedding_gap_seen", false) and not flags.get("jiyeon_left", false)):
		return LocaleManager.ui("가정을 이룬 사람", "Built a Home")
	if (flags.get("daeun_romance_started", false) and not flags.get("daeun_divorced", false)) \
			or (flags.get("jiyeon_romance_started", false) and not flags.get("jiyeon_left", false)):
		return LocaleManager.ui("누군가의 사람", "Someone's Person")
	var total = get_total_asset_value()
	if total >= 3_000_000_000: return LocaleManager.ui("강남드림 달성자", "Gangnam Dreamer")
	if total >= 500_000_000: return LocaleManager.ui("신흥 자산가", "Emerging Wealth")
	if total >= 100_000_000: return LocaleManager.ui("중산층 진입", "Middle Class")
	# 비정석 특수 상태
	if flags.get("creator_viral", false): return LocaleManager.ui("크리에이터", "Creator")
	if flags.get("startup_exit", false): return LocaleManager.ui("스타트업 엑시터", "Startup Exiter")
	if flags.get("startup_launched", false): return LocaleManager.ui("창업가", "Founder")
	if flags.get("creator_monetized", false): return LocaleManager.ui("유튜버", "YouTuber")
	if flags.get("creator_started", false): return LocaleManager.ui("콘텐츠 크리에이터", "Content Creator")
	# 루틴 누적 티어 (AP_REDESIGN 루틴 심화) — 몸과 머리에 쌓인 시간이 이름이 된다.
	if int(flags.get("study_count_exercise", 0)) >= 12: return LocaleManager.ui("몸이 기억하는 사람", "Kept the Habit")
	if int(flags.get("study_count_read", 0)) >= 20: return LocaleManager.ui("읽는 사람", "The Reader")
	var diff = route_orthodox - route_unorthodox
	if diff >= 18: return LocaleManager.ui("엘리트 코스", "Elite Track")
	if diff >= 8: return LocaleManager.ui("착실한 청년", "Diligent Striver")
	if diff <= -18: return LocaleManager.ui("위험한 몽상가", "Dangerous Dreamer")
	if diff <= -8: return LocaleManager.ui("이단아", "Outlier")
	if route_orthodox >= 10 and route_unorthodox >= 10: return LocaleManager.ui("내 방식대로", "My Own Way")
	if get_total_asset_value() >= 3_000_000_000: return LocaleManager.ui("강남 입성자", "Gangnam Resident")
	if housing == "apartment" and job_tenure >= 12: return LocaleManager.ui("안정적인 직장인", "Stable Worker")
	if current_job.is_empty() and turn >= 8 and (flags.get("resume_polished", false) or flags.get("mindset_investor", false) or flags.get("mindset_saver", false)): return LocaleManager.ui("취업 준비생", "Job Seeker")
	if housing == "gosiwon" and turn >= 18: return LocaleManager.ui("고시원 장기거주자", "Long-Term Goshiwon Tenant")
	if turn <= 4: return LocaleManager.ui("서울 상경 초보", "Seoul Newcomer")
	return LocaleManager.ui("서울 생존자", "Seoul Survivor")

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
	if total == 0: return LocaleManager.ui("📍 방향 없음", "📍 No Direction")
	if diff >= 15: return LocaleManager.ui("🏆 정석 엘리트", "🏆 Orthodox Elite")
	if diff >= 7:  return LocaleManager.ui("📘 정석 지향", "📘 Orthodox Leaning")
	if diff <= -15: return LocaleManager.ui("🔥 완전 아웃사이더", "🔥 Full Outsider")
	if diff <= -7:  return LocaleManager.ui("🌊 비정석 지향", "🌊 Unorthodox Leaning")
	return LocaleManager.ui("⚖️ 균형형", "⚖️ Balanced")

func get_route_label() -> String:
	return LocaleManager.ui("%s  (정석 %d / 비정석 %d)", "%s  (Orthodox %d / Unorthodox %d)") % [
		get_route_identity(), route_orthodox, route_unorthodox
	]

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
		return LocaleManager.ui("🎰 승부사 — 한 방에 모든 걸 건 사람", "🎰 Gambler — staked everything on one hit")
	if peak_asset >= 1_000_000_000 and total < peak_asset * 0.4:
		return LocaleManager.ui("📉 롤러코스터 — 정점에서 미끄러진 사람", "📉 Rollercoaster — slid down from the peak")
	if has_any_close_relationship() and reputation >= 60:
		return LocaleManager.ui("🤝 관계형 — 사람으로 버틴 사람", "🤝 Relationship-Driven — survived through people")
	if diff >= 12:
		return LocaleManager.ui("📘 원칙주의자 — 규칙대로 끝까지 간 사람", "📘 Principled — stayed with the rules to the end")
	if diff <= -12:
		return LocaleManager.ui("🔥 개척자 — 남들 안 가는 길로 간 사람", "🔥 Trailblazer — took the road others avoided")
	if health <= 35 or mental <= 35:
		return LocaleManager.ui("🥀 소진형 — 자신을 갈아 넣은 사람", "🥀 Burnout Type — spent yourself to keep going")
	if housing == "gosiwon" and turn >= 120:
		return LocaleManager.ui("🪨 생존형 — 바닥에서 끝까지 버틴 사람", "🪨 Survivor — endured from the bottom to the end")
	if events_seen >= 80:
		return LocaleManager.ui("🧭 탐험가 — 모든 문을 열어본 사람", "🧭 Explorer — opened every door")
	return LocaleManager.ui("⚖️ 균형형 — 중심을 잃지 않은 사람", "⚖️ Balanced — kept your center")

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
	if LocaleManager.is_english():
		return str(TENDENCY_NAMES_EN.get(kind, ""))
	return str(TENDENCY_NAMES.get(kind, ""))

## 현재 성향 라벨 (자각했으면 확정, 아니면 '~ 기질')
func get_tendency_label() -> String:
	if not tendency_realized.is_empty():
		return tendency_name(tendency_realized)
	var dom := get_dominant_tendency()
	if dom.is_empty():
		return LocaleManager.ui("아직 모르는 길", "Unknown Path")
	return tendency_name(dom) + LocaleManager.ui(" 기질", " Leaning")

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

func has_item(item_id: String) -> bool:
	for owned in inventory:
		if owned.get("id", "") == item_id and int(owned.get("quantity", 0)) > 0:
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
	if LocaleManager.is_english():
		return "%04d-%02d W%d" % [year, month, week_of_month]
	return "%d년 %d월 %d주차" % [year, month, week_of_month]

func format_money(amount):
	var sign = ""
	if amount < 0:
		sign = "-"
	var abs_amount = abs(amount)
	if LocaleManager.is_english():
		if abs_amount >= 1_000_000_000:
			return "%sKRW %.1fB" % [sign, abs_amount / 1_000_000_000.0]
		if abs_amount >= 1_000_000:
			return "%sKRW %.1fM" % [sign, abs_amount / 1_000_000.0]
		if abs_amount >= 1_000:
			return "%sKRW %.0fK" % [sign, abs_amount / 1_000.0]
		return "%sKRW %.0f" % [sign, abs_amount]
	if abs_amount >= 100_000_000:
		return "%s%.1f억원" % [sign, abs_amount / 100_000_000.0]
	if abs_amount >= 10_000:
		return "%s%.0f만원" % [sign, abs_amount / 10_000.0]
	return "%s%.0f원" % [sign, abs_amount]

func format_event_text(text: String) -> String:
	var job_name: String = get_job_display_name()
	var total_assets: float = get_total_asset_value()
	var loan_total: float = get_loan_total()
	return text \
		.replace("{name}", player_name) \
		.replace("{job}", job_name) \
		.replace("{housing}", get_housing_name(housing)) \
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
		.replace("{loan}", format_money(loan_total)) \
		.replace("{keepsake}", get_pending_housing_keepsake_name())

func get_total_asset_value():
	var total = money
	for asset_id in portfolio:
		var holding: Dictionary = portfolio[asset_id]
		total += float(holding.get("quantity", 0.0)) * float(market_prices.get(asset_id, holding.get("avg_price", 0.0)))
	return total - get_loan_total()

## ── 경제 런 궤적/페이스 — 척추(경제 런)의 심장 ──────────────────
## 30억까지 얼마나 왔고, "우승 궤적" 대비 앞서/뒤처져 있는가.
## 매주 "안전 vs 한 방" 결정을 살리는 압박 신호. (UI 가시화는 별도)
##
## 절대 needed_cagr(50만→30억)는 시작부터 ~470%/년이라 거의 항상 포화 →
## 변별력이 없다. 그래서 상태는 *현실적 우승 궤적 벤치마크* 대비로 잡는다:
##   - 시드 단계(0~24개월): 시작자금 → 8천만(종잣돈) 선형
##   - 성장 단계(24~60개월): 8천만 → 30억 지수 성장 (후반 가속 = 베팅/복리)
## ratio = 현재자산 / 벤치마크. 중앙값 런(~2억 종착)은 'behind', 우승 런은 'on_track'으로 갈리도록 보정.
## 반환: { target, current, progress_pct, months_elapsed, months_left,
##         benchmark, ratio, needed_cagr(참고용), status, via }
const GANGNAM_TARGET := 3_000_000_000.0
const PACE_SEED := 80_000_000.0       # 종잣돈 기준 (24개월 목표)
const PACE_SEED_MONTH := 24.0
const PACE_START := 500_000.0
func get_run_pace() -> Dictionary:
	var current: float = get_total_asset_value()
	var me: int = max(1, (age - 33) * 12 + month)          # 경과 개월 (시작=1)
	var months_left: int = max(0, (38 - age) * 12 - month + 1)
	var years_left: float = float(months_left) / 12.0

	# 우승 궤적 벤치마크
	var benchmark: float = 0.0
	if me <= int(PACE_SEED_MONTH):
		var t: float = float(me - 1) / max(1.0, PACE_SEED_MONTH - 1.0)   # 0..1
		benchmark = PACE_START + (PACE_SEED - PACE_START) * t
	else:
		var t2: float = float(me - PACE_SEED_MONTH) / max(1.0, 60.0 - PACE_SEED_MONTH)  # 0..1
		benchmark = PACE_SEED * pow(GANGNAM_TARGET / PACE_SEED, clampf(t2, 0.0, 1.0))
	benchmark = max(benchmark, PACE_START)
	var ratio: float = current / benchmark

	# 참고용 절대 수익률 (표시/디버그)
	var needed_cagr: float = -1.0
	if current > 0.0 and years_left > 0.0 and current < GANGNAM_TARGET:
		needed_cagr = pow(GANGNAM_TARGET / current, 1.0 / years_left) - 1.0

	var status: String = "danger"
	if current >= GANGNAM_TARGET:
		status = "achieved"
	elif current <= 0.0:
		status = "danger"            # 빚더미 — 기적이 필요
	elif ratio >= 1.3:
		status = "ahead"
	elif ratio >= 0.7:
		status = "on_track"          # 우승 궤적 위
	elif ratio >= 0.35:
		status = "behind"            # 공격적 운용/레버리지 필요
	elif ratio >= 0.12:
		status = "long_shot"         # 큰 베팅·운이 필요
	else:
		status = "danger"

	var via := "balanced"
	if route_orthodox - route_unorthodox >= 6:
		via = "orthodox"
	elif route_unorthodox - route_orthodox >= 6:
		via = "unorthodox"
	return {
		"target": GANGNAM_TARGET,
		"current": current,
		"progress_pct": current / GANGNAM_TARGET * 100.0,
		"months_elapsed": me,
		"months_left": months_left,
		"benchmark": benchmark,
		"ratio": ratio,
		"needed_cagr": needed_cagr,
		"status": status,
		"via": via,
	}

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
	if g <= 3: return LocaleManager.ui("우량", "Prime")
	if g <= 6: return LocaleManager.ui("보통", "Standard")
	if g <= 8: return LocaleManager.ui("주의", "Watch")
	return LocaleManager.ui("위험", "Risk")

## 변동금리 — 매달 현재 등급으로 이자를 계산한다.
## 한국 법정 최고금리(연 20%, 2021.7~) 초과 금지 — 월 환산 상한으로 클램프.
const LEGAL_MAX_MONTHLY_RATE := 0.0153   # (1+0.0153)^12 ≈ 1.200 → 연 ~20%
func get_loan_rate(product: String) -> float:
	var g := get_credit_grade()
	var r := 0.02
	match product:
		# 1금융 은행 신용대출: 1등급 월 0.4%(연 ~4.9%) ~ 7등급 월 0.88%(연 ~11.1%)
		"bank":   r = 0.004 + float(g - 1) * 0.0008
		# 2금융 저축은행: 1등급 월 ~1.10%(연 ~14%) ~ 저신용 법정상한(연 ~20%)
		"second": r = 0.011 + float(g - 1) * 0.0005
	return minf(r, LEGAL_MAX_MONTHLY_RATE)   # 법정 최고금리 초과 차단

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
	add_log(LocaleManager.ui("%s %s %s 대출 실행 — 매달 이자가 먼저 나간다.", "%s %s borrowed: %s — interest comes first every month.") % [
		info["emoji"], get_loan_name(product), format_money(amount)
	], "money")
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
	add_log(LocaleManager.ui("%s %s %s 상환 — 남은 원금 %s.", "%s %s repaid: %s — remaining principal %s.") % [
		info["emoji"], get_loan_name(product), format_money(amount), format_money(loans[product])
	], "money")
	stats_changed.emit()
	return true

func get_wealth_tier():
	var total = get_total_asset_value()
	if total >= 600_000_000:
		return LocaleManager.ui("강남 입성권", "Gangnam Threshold")
	if total >= 200_000_000:
		return LocaleManager.ui("내 집 마련", "Homeowner Track")
	if total >= 80_000_000:
		return LocaleManager.ui("전세 탈출", "Beyond Jeonse")
	if total >= 20_000_000:
		return LocaleManager.ui("종잣돈 모으는 중", "Building Seed Money")
	return LocaleManager.ui("고시원 생존자", "Goshiwon Survivor")

func _divorce_ending_for_assets(total_assets: float) -> String:
	# 외로운 부자는 실제 강남 입성 결말이다. 다은을 잃었어도 목표 미달이면
	# 부자 엔딩을 꾸며내지 않고 그냥 사람의 전용 결별 변주로 회수한다.
	return "lonely_rich" if total_assets >= GANGNAM_TARGET else "ordinary_life"

func check_game_over():
	if is_game_over:
		return
	# 자산 마일스톤 플래그 자동 추적 (이벤트 조건용)
	var total_now = get_total_asset_value()
	if total_now > peak_asset:
		peak_asset = total_now
	if total_now >= 100_000_000 and not flags.get("asset_100m_reached", false):
		flags["asset_100m_reached"] = true
		add_log(LocaleManager.ui("💰 자산 1억 돌파 — 종잣돈이 생겼다.", "💰 Assets passed KRW 100M — real seed money has formed."), "money")
	if total_now >= 500_000_000 and not flags.get("asset_500m_reached", false):
		flags["asset_500m_reached"] = true
		add_log(LocaleManager.ui("💰 자산 5억 돌파 — 길이 보이기 시작한다.", "💰 Assets passed KRW 500M — the path is starting to appear."), "money")
	if total_now >= 1_000_000_000 and not flags.get("asset_1b_reached", false):
		flags["asset_1b_reached"] = true
		add_log(LocaleManager.ui("💰 자산 10억 돌파 — 30억의 3분의 1. 이제부터 가속이 붙는다.", "💰 Assets passed KRW 1B — one third of the goal. Acceleration starts now."), "money")
	if total_now >= 2_000_000_000 and not flags.get("asset_2b_reached", false):
		flags["asset_2b_reached"] = true
		add_log(LocaleManager.ui("🔥 자산 20억 돌파 — 강남이 손에 잡힐 듯하다. 남은 건 10억.", "🔥 Assets passed KRW 2B — Gangnam feels close. KRW 1B left."), "money")
	if total_now >= 2_700_000_000 and not flags.get("asset_2_7b_reached", false):
		flags["asset_2_7b_reached"] = true
		add_log(LocaleManager.ui("🔥 자산 27억 — 마지막 고비다. 강남 입성이 코앞이다.", "🔥 Assets reached KRW 2.7B — the final wall. Gangnam is right there."), "money")
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

	# full_circle: 상철 진실 알고 시작, 30억, 아버지 생존, 상철에게서 아버지 빚을 실제로 받아냄.
	# 엔딩 본문이 "그 사람한테서 빚을 갚았다"고 말하므로, 그 행위(배상 요구)를 실제로 한 런만 도달한다.
	if _mp_meta.get("sangchul_truth_ever_known", false) \
			and total_now >= 3_000_000_000.0 \
			and flags.get("father_reconciled", false) \
			and not flags.get("father_passed", false) \
			and flags.get("cleared_father_debt_from_sangchul", false):
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
		# ── 결혼 분기 (배우자 실을 강남 엔딩에서 회수) ──
		# 아내를 배신하고(이혼) 강남 = 직접 버린 '외로운 부자'. crossed_line보다 먼저.
		if flags.get("daeun_divorced", false):
			finish_run(_divorce_ending_for_assets(total_now)); return
		# 결혼 유지한 채 강남 = 따뜻하게 온 진엔딩(두 부모 방 있는 집, 둘이 함께).
		if flags.get("daeun_married", false):
			finish_run("gangnam_dream"); return       # dik: daeun_married 변주
		# 지연과 강남 도달 = 그녀 세계에 진입 성공(보내지 않았을 때). dik: jiyeon_reached 변주.
		if flags.get("jiyeon_romance_started", false) and not flags.get("jiyeon_left", false):
			finish_run("gangnam_dream"); return       # dik: jiyeon_reached 변주
		# 어떤 사람이 되어 입성했는가로 엔딩 분기
		if flags.get("fell_to_darkness", false) or flags.get("crossed_line", false):
			finish_run("jaehyuk_way"); return        # 최재혁의 방식
		if relationships.is_empty() and not has_any_close_relationship():
			# 아버지도 없거나(별세/미화해) → 진짜 빈 집
			if not flags.get("father_reconciled", false) or flags.get("father_passed", false):
				finish_run("empty_house"); return     # 빈 집
			finish_run("lonely_rich"); return         # 외로운 부자 — 돈만 남음
		# 진엔딩: White 밴드(tint ≥ +60) 유지한 채로 30억 — 극악 난이도 0.1%
		if moral_stage() >= 2:
			finish_run("gangnam_dream_white"); return
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
		# 이혼(강남 미달 엣지 — 서명했으나 끝내 못 닿음): 버렸는데 얻지도 못한 결말
		if flags.get("daeun_divorced", false):
			finish_run(_divorce_ending_for_assets(total)); return
		# 연인 엔딩
		if flags.get("daeun_romance_started", false):
			finish_run("with_daeun"); return          # 다은과 연인 (Y5 고백)
		# 지연이 떠남(안주를 견디지 못함) = 자기를 지키고 그녀를 잃음. ordinary에 jiyeon_left 변주.
		if flags.get("jiyeon_left", false):
			finish_run("ordinary_life"); return       # dik: jiyeon_left 변주
		if flags.get("jiyeon_romance_started", false):
			finish_run("jiyeon_man"); return          # 한지연의 남자 (Y5 formalize)
		# 도박 중독을 이겨낸 사람 — 강남엔 못 갔어도, 가장 깊은 구덩이에서 올라왔다.
		# 30억 도달자는 이미 위에서 gangnam_dream 분기 → 여기 오는 건 미달자.
		# 이 런의 진짜 서사가 '회복'이었던 사람에게 주는 구원 엔딩.
		if flags.get("beat_addiction", false):
			finish_run("gambling_recovery"); return
		# 임상철 청산 — 신고로 아버지를 빚에서 해방시킨 사람.
		# 강남(30억)은 위에서 이미 분기 → 여기 오는 건 강남을 포기하고 진실을 택한 사람.
		# 이 런의 진짜 결말이 '아버지'였던 사람에게 닿는 도덕적 B 엔딩 (late_call 형제).
		if (flags.get("sangchul_reported", false) or flags.get("cleared_father_debt_from_sangchul", false)) \
				and not flags.get("father_passed", false):
			finish_run("sangchul_reckoning"); return
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
		# 버텨온 것들 (직장 유지 + 번아웃 경험 or 이직 시도 — 낮은 자산의 직장인 결산)
		# career_climber(A)는 위에서 1억+ 잡음 → 여기 오면 1억 미만의 직장인
		if not current_job.is_empty() \
				and (flags.get("burnout_acknowledged", false) or flags.get("job_change_trigger", false)):
			finish_run("career_burnout"); return
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
		"grind_streak_weeks": grind_streak_weeks,
		"money_weeks_total": money_weeks_total,
		"human_weeks_total": human_weeks_total,
		"loop_tint_spent": loop_tint_spent,
		"week_routine": week_routine,
		"month_money_weeks": month_money_weeks,
		"month_human_weeks": month_human_weeks,
		"last_month_money_weeks": last_month_money_weeks,
		"last_month_human_weeks": last_month_human_weeks,
		"tutorial_step": tutorial_step,
		"route_orthodox": route_orthodox,
		"route_unorthodox": route_unorthodox,
		"moral_tint": moral_tint,
		"moral_band_last": moral_band_last,
		"action_axis_this_week": action_axis_this_week,
		"action_places_this_week": action_places_this_week,
		"recent_action_places": recent_action_places,
		"contact_counts": contact_counts,
		"last_contact_turn": last_contact_turn,
		"run_seen_scenes_by_year": run_seen_scenes_by_year,
		"year_scenes": year_scenes,
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
		"clues": clues,
		"thoughts_done": thoughts_done,
		"active_thought": active_thought,
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
		"grind_streak_weeks", "money_weeks_total", "human_weeks_total",
		"month_money_weeks", "month_human_weeks",
		"last_month_money_weeks", "last_month_human_weeks",
		"route_orthodox", "route_unorthodox", "events_seen",
		"moral_band_last",
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
	# 구버전 세이브 호환 — AP 행동 축
	if typeof(action_axis_this_week) != TYPE_DICTIONARY or action_axis_this_week.is_empty():
		action_axis_this_week = {"money": 0, "human": 0}
	if not data.has("action_places_this_week") or typeof(action_places_this_week) != TYPE_DICTIONARY:
		action_places_this_week = {}
	if not data.has("recent_action_places") or typeof(recent_action_places) != TYPE_ARRAY:
		recent_action_places = []
	if not data.has("run_seen_scenes_by_year") or typeof(run_seen_scenes_by_year) != TYPE_DICTIONARY:
		run_seen_scenes_by_year = {}
	if not data.has("year_scenes") or typeof(year_scenes) != TYPE_DICTIONARY:
		year_scenes = {}
	# 구버전 세이브 호환 — 몽타주 루틴
	if typeof(week_routine) != TYPE_ARRAY:
		week_routine = []
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
	# 구버전 세이브 호환 — 발견 레이어 필드
	if typeof(clues) != TYPE_ARRAY:
		clues = []
	if typeof(thoughts_done) != TYPE_ARRAY:
		thoughts_done = []
	if typeof(active_thought) != TYPE_DICTIONARY:
		active_thought = {}
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

# ── 발견 레이어: 단서/생각정리 엔진 (추리·분석의 재미) ──────────────
## 단서 획득 (이미 있으면 무시). 신규면 true.
func add_clue(clue_id: String) -> bool:
	if clue_id == "" or clues.has(clue_id):
		return false
	clues.append(clue_id)
	var c: Dictionary = DataRegistry.get_clue(clue_id)
	var title: String = str(c.get("title", clue_id))
	add_log(LocaleManager.ui("🔎 단서 발견: %s" % title, "🔎 Clue found: %s" % title), "system")
	clue_added.emit(clue_id)
	stats_changed.emit()
	return true

func has_clue(clue_id: String) -> bool:
	return clues.has(clue_id)

func is_thought_done(thought_id: String) -> bool:
	return thoughts_done.has(thought_id)

## 필요한 단서를 모두 모았고, 아직 정리/완료하지 않은 생각 목록
func available_thoughts() -> Array:
	var out: Array = []
	for t in DataRegistry.thoughts:
		var tid: String = str(t.get("id", ""))
		if tid == "" or thoughts_done.has(tid):
			continue
		if str(active_thought.get("id", "")) == tid:
			continue
		var ok: bool = true
		for req in t.get("required_clues", []):
			if not clues.has(str(req)):
				ok = false
				break
		if ok:
			out.append(t)
	return out

## 생각정리 시작 (1슬롯 — 이미 정리 중이면 실패). 시간이 걸린다 = 기회비용.
func start_thought(thought_id: String) -> bool:
	if not active_thought.is_empty():
		return false
	if thoughts_done.has(thought_id):
		return false
	var t: Dictionary = DataRegistry.get_thought(thought_id)
	if t.is_empty():
		return false
	for req in t.get("required_clues", []):
		if not clues.has(str(req)):
			return false
	var turns: int = max(1, int(t.get("processing_turns", 1)))
	active_thought = {"id": thought_id, "turns_left": turns}
	var title: String = str(t.get("title", thought_id))
	add_log(LocaleManager.ui("💭 생각 정리 시작: %s (%d주)" % [title, turns], "💭 Started working it out: %s (%d weeks)" % [title, turns]), "system")
	stats_changed.emit()
	return true

## 매주 호출 (advance_calendar) — 정리 중인 생각 진행, 완료 시 결론 적용
func _tick_active_thought() -> void:
	if active_thought.is_empty():
		return
	var left: int = int(active_thought.get("turns_left", 0)) - 1
	if left <= 0:
		var tid: String = str(active_thought.get("id", ""))
		active_thought = {}
		_complete_thought(tid)
	else:
		active_thought["turns_left"] = left

func _complete_thought(thought_id: String) -> void:
	if thought_id == "" or thoughts_done.has(thought_id):
		return
	thoughts_done.append(thought_id)
	var t: Dictionary = DataRegistry.get_thought(thought_id)
	var oc: Dictionary = t.get("on_complete", {})
	for fk in oc.get("flags", []):
		flags[str(fk)] = true
	var eff = oc.get("effects", {})
	if eff is Dictionary and not eff.is_empty():
		apply_effects(eff)
	var unlock: String = str(oc.get("unlock_event", ""))
	if unlock != "":
		add_deferred_event(unlock, 0)
	var title: String = str(t.get("title", thought_id))
	add_log(LocaleManager.ui("💡 결론에 도달: %s" % title, "💡 Reached a conclusion: %s" % title), "system")
	thought_completed.emit(thought_id)
	stats_changed.emit()
