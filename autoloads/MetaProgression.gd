extends Node

const META_SAVE_PATH = "user://gangnam_dream_meta.json"

var data: Dictionary = {}

const ALL_TITLES := [
	# ── 주거 ──
	{"id":"gosiwon_survivor",   "name":"고시원 생존자",     "cat":"주거", "rare":"common",
	 "desc":"고시원에서 12개월을 버텼다. 이 경험은 잊지 못할 것이다."},
	{"id":"first_move",         "name":"첫 이사",           "cat":"주거", "rare":"common",
	 "desc":"처음으로 고시원을 벗어나 새 공간으로 이사했다."},
	{"id":"apartment_life",     "name":"아파트 입성",       "cat":"주거", "rare":"uncommon",
	 "desc":"드디어 아파트에 살게 됐다. 경비 아저씨가 반겨준다."},
	{"id":"gangnam_resident",   "name":"강남 입성",         "cat":"주거", "rare":"rare",
	 "desc":"강남 아파트. 주소만으로도 사람들의 눈빛이 달라진다."},
	{"id":"long_gosiwon",       "name":"고시원 장기거주자", "cat":"주거", "rare":"uncommon",
	 "desc":"고시원 24개월. 이제 이 냄새도 집냄새처럼 느껴진다."},
	# ── 직업 ──
	{"id":"first_paycheck",     "name":"첫 월급의 무게",   "cat":"직업", "rare":"common",
	 "desc":"통장에 처음으로 월급이 찍혔다. 기쁘면서도 이상하게 허탈했다."},
	{"id":"one_year_worker",    "name":"1년 직장인",        "cat":"직업", "rare":"common",
	 "desc":"같은 회사를 1년 다녔다. 어느새 선배가 돼 있었다."},
	{"id":"three_year_worker",  "name":"베테랑 직장인",     "cat":"직업", "rare":"uncommon",
	 "desc":"3년. 회사 서류함에 내 이름이 녹아들었다."},
	{"id":"long_unemployed",    "name":"백수의 자유",       "cat":"직업", "rare":"uncommon",
	 "desc":"12개월을 무직으로 버텼다. 누군가는 백수라 하고 누군가는 자유인이라 한다."},
	# ── 투자 ──
	{"id":"first_investment",   "name":"첫 투자",           "cat":"투자", "rare":"common",
	 "desc":"처음으로 주식을 샀다. 그날부터 매일 앱을 열게 됐다."},
	{"id":"margin_called",      "name":"마진콜의 교훈",     "cat":"투자", "rare":"uncommon",
	 "desc":"레버리지 포지션이 강제청산됐다. 비싼 수업료였다."},
	{"id":"invest_master_title","name":"투자 고수",         "cat":"투자", "rare":"rare",
	 "desc":"투자 감각 70. 시장이 조금씩 다르게 보이기 시작했다."},
	{"id":"survived_broke",     "name":"통장 0원 생존자",  "cat":"투자", "rare":"common",
	 "desc":"잔고가 마이너스까지 내려갔다 돌아왔다."},
	# ── 성향/루트 ──
	{"id":"steady_youth",       "name":"착실한 청년",       "cat":"성향", "rare":"common",
	 "desc":"정석 선택 10회. 사회가 원하는 모습에 가까워지고 있다."},
	{"id":"elite_course",       "name":"엘리트 코스",       "cat":"성향", "rare":"uncommon",
	 "desc":"정석 행동 20회. 이 길의 끝에 무엇이 있는지는 아직 모른다."},
	{"id":"outsider_title",     "name":"이단아",            "cat":"성향", "rare":"common",
	 "desc":"비정석 선택 10회. 남들과 다른 길을 걷고 있다."},
	{"id":"dangerous_dreamer",  "name":"위험한 몽상가",     "cat":"성향", "rare":"uncommon",
	 "desc":"비정석 행동 20회. 꿈인지 무모함인지는 결과가 말해줄 것이다."},
	{"id":"my_own_way",         "name":"내 방식대로",       "cat":"성향", "rare":"rare",
	 "desc":"정석도 비정석도 각 10회 이상. 어느 길도 아닌 나만의 길."},
	{"id":"free_spirit",        "name":"자유 영혼",         "cat":"성향", "rare":"uncommon",
	 "desc":"자유시간 10회. 한강, 편의점, 산책. 이것이 내 삶이다."},
	# ── 관계/생활 ──
	{"id":"seoul_love",         "name":"서울에서 사랑",     "cat":"관계", "rare":"uncommon",
	 "desc":"이 복잡한 도시에서도 사람을 좋아하게 됐다."},
	{"id":"social_king_title",  "name":"인맥왕",            "cat":"관계", "rare":"rare",
	 "desc":"관계 5명 이상. 서울은 결국 사람이다."},
	{"id":"loner_title",        "name":"혼자가 편해",       "cat":"관계", "rare":"uncommon",
	 "desc":"관계 없이 30턴을 버텼다. 서울의 외로움에 익숙해졌다."},
	{"id":"stress_survivor",    "name":"스트레스 끝판왕",  "cat":"생활", "rare":"uncommon",
	 "desc":"스트레스 90을 넘어봤다. 그리고 살아남았다."},
	# ── 자산 ──
	{"id":"first_10m_title",    "name":"첫 1000만원",       "cat":"자산", "rare":"common",
	 "desc":"현금 1000만원. 서울에서 처음으로 숨이 트이는 느낌이었다."},
	{"id":"first_100m_title",   "name":"첫 1억",            "cat":"자산", "rare":"uncommon",
	 "desc":"총자산 1억. 뭔가 달라지는 것 같기도 하고 아닌 것 같기도 하다."},
	# ── 메타/런 ──
	{"id":"five_runs_title",    "name":"다섯 번의 인생",    "cat":"메타", "rare":"common",
	 "desc":"5번의 런을 완주했다. 매번 달랐다."},
	{"id":"ten_runs_title",     "name":"열 번의 인생",      "cat":"메타", "rare":"uncommon",
	 "desc":"10번의 런. 이제 이 게임의 패턴이 보이기 시작한다."},
	{"id":"gangnam_dream_title","name":"강남드림 달성자",   "cat":"메타", "rare":"legendary",
	 "desc":"총자산 20억. 강남드림을 이뤘다. 다음엔 뭘 꿈꿔야 할까."},
	{"id":"burnout_survivor",   "name":"번아웃 생존자",     "cat":"메타", "rare":"common",
	 "desc":"번아웃 엔딩을 경험했다. 열심히 사는 것의 대가를 배웠다."},
	{"id":"ordinary_end_title", "name":"평범한 행복",       "cat":"메타", "rare":"uncommon",
	 "desc":"ordinary_life 엔딩. 평범함도 하나의 성취다."},
]

func _ready():
	load_meta()

func load_meta():
	data = DataRegistry.default_meta.duplicate(true)
	if FileAccess.file_exists(META_SAVE_PATH):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(META_SAVE_PATH))
		if parsed is Dictionary:
			data.merge(parsed, true)

func save_meta():
	var file = FileAccess.open(META_SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))

func get_unlocked_traits():
	return data.get("unlocked_traits", ["흙수저 생존본능"])

func get_trait_bonus(trait_name):
	for tr in DataRegistry.traits:
		if tr.get("id", "") == trait_name:
			return tr.get("bonus", {})
	return {}

func unlock_trait(trait_name):
	var traits: Array = data.get("unlocked_traits", [])
	if not traits.has(trait_name):
		traits.append(trait_name)
		data["unlocked_traits"] = traits
		save_meta()

func unlock_achievement(achievement_id):
	var achievements: Array = data.get("achievements", [])
	if not achievements.has(achievement_id):
		achievements.append(achievement_id)
		data["achievements"] = achievements
		save_meta()

# ── 칭호 시스템 ───────────────────────────────────────────────────
func get_unlocked_titles() -> Array:
	return data.get("unlocked_titles", [])

func unlock_title(title_id: String) -> bool:
	var titles: Array = data.get("unlocked_titles", [])
	if titles.has(title_id):
		return false
	titles.append(title_id)
	data["unlocked_titles"] = titles
	save_meta()
	return true

func get_title_info(title_id: String) -> Dictionary:
	for t in ALL_TITLES:
		if t["id"] == title_id:
			return t
	return {}

func check_and_unlock_titles() -> Array:
	var newly: Array = []
	for title in ALL_TITLES:
		var tid: String = title["id"]
		if get_unlocked_titles().has(tid):
			continue
		if _check_title_condition(tid):
			if unlock_title(tid):
				newly.append(title)
	return newly

func _check_title_condition(tid: String) -> bool:
	match tid:
		"gosiwon_survivor":   return GameState.housing_months.get("gosiwon", 0) >= 12
		"long_gosiwon":       return GameState.housing_months.get("gosiwon", 0) >= 24
		"first_move":         return GameState.flags.get("housing_moved_once", false)
		"apartment_life":     return GameState.housing in ["apartment", "gangnam"]
		"gangnam_resident":   return GameState.housing == "gangnam"
		"first_paycheck":     return GameState.flags.get("has_received_paycheck", false)
		"one_year_worker":    return GameState.job_tenure >= 12
		"three_year_worker":  return GameState.job_tenure >= 36
		"long_unemployed":    return GameState.flags.get("unemployed_months", 0) >= 12
		"first_investment":   return GameState.flags.get("had_first_investment", false)
		"margin_called":      return GameState.flags.get("margin_called_happened", false)
		"invest_master_title":return GameState.investment_skill >= 70
		"survived_broke":     return GameState.flags.get("was_broke_once", false)
		"steady_youth":       return GameState.route_orthodox >= 10
		"elite_course":       return GameState.route_orthodox >= 20
		"outsider_title":     return GameState.route_unorthodox >= 10
		"dangerous_dreamer":  return GameState.route_unorthodox >= 20
		"my_own_way":         return GameState.route_orthodox >= 10 and GameState.route_unorthodox >= 10
		"free_spirit":        return GameState.flags.get("free_time_count", 0) >= 10
		"seoul_love":
			for rel in GameState.relationships:
				if rel.get("type","") == "romantic": return true
			return false
		"social_king_title":  return GameState.relationships.size() >= 5
		"loner_title":        return GameState.relationships.is_empty() and GameState.turn >= 30
		"stress_survivor":    return GameState.flags.get("reached_max_stress", false)
		"first_10m_title":    return GameState.money >= 10_000_000
		"first_100m_title":   return GameState.get_total_asset_value() >= 100_000_000
		"five_runs_title":    return int(data.get("total_runs", 0)) >= 5
		"ten_runs_title":     return int(data.get("total_runs", 0)) >= 10
		"gangnam_dream_title":return data.get("achievements", []).has("gangnam_dream")
		"burnout_survivor":   return data.get("achievements", []).has("survived_burnout")
		"ordinary_end_title":
			for run in data.get("run_history", []):
				if run.get("ending_id","") == "ordinary_life": return true
			return false
	return false

func is_hidden_event_unlocked(event_id):
	return data.get("rare_event_unlocks", []).has(event_id) or data.get("unlocked_hidden_events", []).has(event_id)

func record_run(summary):
	data["total_runs"] = int(data.get("total_runs", 0)) + 1
	data["best_asset"] = max(float(data.get("best_asset", 0.0)), float(summary.get("total_assets", 0.0)))
	var history: Array = data.get("run_history", [])
	history.append(summary)
	if history.size() > 50:
		history.pop_front()
	data["run_history"] = history
	_check_progression_unlocks(summary)
	save_meta()

func get_unlocked_achievements() -> Array:
	return data.get("achievements", [])

func is_achievement_unlocked(achievement_id: String) -> bool:
	return data.get("achievements", []).has(achievement_id)

func _check_progression_unlocks(summary):
	var total_assets = float(summary.get("total_assets", 0.0))
	var ending_id = str(summary.get("ending_id", ""))
	var total_runs = int(data.get("total_runs", 0))

	# 자산 기준 트레이트/업적
	if total_assets >= 50_000_000:
		unlock_trait("야근 면역자")
	if total_assets >= 100_000_000:
		unlock_achievement("first_billion")
	if total_assets >= 200_000_000:
		unlock_trait("리스크 중독자")

	# 엔딩 기준 트레이트/업적
	if ending_id in ["stable_success", "ordinary_life"]:
		unlock_trait("안정 지향형")
		unlock_achievement("stable_life")
	if ending_id == "gangnam_dream":
		unlock_trait("강남드림 계승자")
		unlock_achievement("gangnam_dream")
	if ending_id in ["burnout", "mental_break"]:
		unlock_trait("번아웃 생존자")
		unlock_achievement("survived_burnout")
	if ending_id in ["startup_exit", "political_fix"]:
		unlock_trait("인맥왕")
	if ending_id == "startup_exit":
		unlock_achievement("startup_exit")
	if ending_id == "political_fix":
		unlock_achievement("political_fix")
	if ending_id == "investment_master":
		unlock_achievement("investment_master")
	if ending_id == "reputation_legend":
		unlock_achievement("reputation_legend")

	# 런 횟수 기준
	if total_runs >= 5:
		unlock_achievement("five_lives")
	if total_runs >= 10:
		unlock_trait("강남 토박이")
		unlock_achievement("ten_lives")

	# 런 종료 시점 칭호 체크 (메타 칭호)
	check_and_unlock_titles()
