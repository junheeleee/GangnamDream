extends Node

const BUILD_FLAVOR := preload("res://systems/BuildFlavor.gd")
const DEMO_CORE_LOOP_V2 := preload("res://systems/DemoCoreLoopV2.gd")
# Compatibility constant for tools that explicitly inspect legacy retail
# data. Production persistence uses meta_save_path().
const META_SAVE_PATH = BUILD_FLAVOR.RETAIL_META_PATH
const LEGACY_ACHIEVEMENT_IDS: Array[String] = ["white_gangnam", "clean_gangnam"]
const SCENE_REPLAY_SNAPSHOT_MAX_BYTES := 32 * 1024
const SCENE_REPLAY_SNAPSHOT_MAX_DEPTH := 12
const SCENE_REPLAY_SNAPSHOT_MAX_COLLECTION_ITEMS := 96
const SCENE_REPLAY_SNAPSHOT_MAX_ID_LENGTH := 192
const SCENE_REPLAY_SCHEMA := 1
const GALLERY_REPLAY_ROOT_IDS: Array[String] = [
	"arc_date_namsan_daeun", "arc_date_namsan_jiyeon",
	"arc_date_park_daeun", "arc_date_park_jiyeon",
	"arc_daeun_hometown_1", "arc_jiyeon_narrow_room_1",
	"arc_season_cherry_daeun", "arc_season_cherry_jiyeon",
	"arc_season_sea_daeun", "arc_season_sea_jiyeon",
	"arc_season_fireworks_daeun", "arc_season_fireworks_jiyeon",
	"arc_season_snow_daeun", "arc_season_snow_jiyeon",
	"arc_daeun_first_kiss", "arc_jiyeon_first_kiss",
	"arc_daeun_first_night", "arc_daeun_wedding_night",
	"arc_jiyeon_wedding_night", "v2_demo_first_bill_opening",
]
const GALLERY_REPLAY_GENERIC_KEYS: Array[String] = [
	"schema", "scene_id", "player_name", "turn", "moral_tint", "housing",
	"selector_matches", "visible_choice_indices",
]
const GALLERY_REPLAY_HOUSING_IDS: Array[String] = [
	"gosiwon", "oneroom", "villa", "apartment", "gangnam",
]
const FIRST_BILL_REPLAY_ALLOWED_KEYS: Array[String] = [
	"schema", "scene_id", "turn", "player_name", "housing", "health",
	"mental", "addiction_tendency", "moral_tint", "money", "total_assets",
	"housing_expense", "required_cash", "context", "father_memory",
	"m3_ledger_memory", "dirty_receipt", "hyunsu_receipt",
	"obligation_receipt",
]

var data: Dictionary = {}
# NG+ 메타 플래그 접근용 alias (data와 동일 객체)
var meta: Dictionary :
	get: return data
# 이번 런에서 새로 해금된 항목 (ending 화면에 표시용)
var _new_this_run: Dictionary = {"achievements": []}

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
	{"id":"invest_master_title","name":"닫힌 노트북",       "cat":"투자", "rare":"rare",
	 "desc":"새벽 시장을 지켜보다 스스로 정한 때에 화면을 닫을 수 있게 됐다."},
	{"id":"survived_broke",     "name":"통장 0원 생존자",  "cat":"투자", "rare":"common",
	 "desc":"잔고가 마이너스까지 내려갔다 돌아왔다."},
	# ── 성향/루트 ──
	{"id":"steady_youth",       "name":"놓인 계단",         "cat":"성향", "rare":"common",
	 "desc":"낯선 지름길보다 이미 놓인 계단을 골라, 한 걸음씩 올라왔다."},
	{"id":"elite_course",       "name":"오래 오른 계단",     "cat":"성향", "rare":"uncommon",
	 "desc":"같은 계단을 오래 올랐다. 익숙해진 풍경만큼 지나친 갈림길도 남았다."},
	{"id":"outsider_title",     "name":"다른 출구",         "cat":"성향", "rare":"common",
	 "desc":"사람들이 몰린 방향에서 벗어나, 다른 출구를 여러 번 골랐다."},
	{"id":"dangerous_dreamer",  "name":"지도 밖의 길",      "cat":"성향", "rare":"uncommon",
	 "desc":"지도에 없는 길을 오래 걸었다. 발밑이 흔들린 날에도 방향을 쉽게 바꾸지 않았다."},
	{"id":"my_own_way",         "name":"두 길 사이",        "cat":"성향", "rare":"rare",
	 "desc":"이미 놓인 길과 지도 밖의 길을 오갔다. 어느 한쪽만으로는 이 5년을 설명할 수 없다."},
	{"id":"free_spirit",        "name":"비어 있던 오후",     "cat":"성향", "rare":"uncommon",
	 "desc":"한강과 편의점, 오래 걷던 길에서 누구의 일정도 아닌 시간을 보냈다."},
	# ── 관계/생활 ──
	{"id":"seoul_love",         "name":"서울에서 사랑",     "cat":"관계", "rare":"uncommon",
	 "desc":"이 복잡한 도시에서도 사람을 좋아하게 됐다."},
	{"id":"social_king_title",  "name":"낯익은 자리들",     "cat":"관계", "rare":"rare",
	 "desc":"서울 곳곳에 먼저 인사를 건네고 자리를 내어 주는 사람들이 생겼다."},
	{"id":"loner_title",        "name":"혼자 걷는 저녁",    "cat":"관계", "rare":"uncommon",
	 "desc":"연락할 이름이 떠오르지 않는 저녁에도, 혼자 걷는 길은 어느새 익숙해졌다."},
	{"id":"stress_survivor",    "name":"다음 아침",         "cat":"생활", "rare":"uncommon",
	 "desc":"마음이 버티기 어려웠던 밤이 지나고도, 다음 아침은 왔다."},
	# ── 자산 ──
	{"id":"first_10m_title",    "name":"첫 1000만원",       "cat":"자산", "rare":"common",
	 "desc":"현금 1000만원. 서울에서 처음으로 숨이 트이는 느낌이었다."},
	{"id":"first_100m_title",   "name":"첫 1억",            "cat":"자산", "rare":"uncommon",
	 "desc":"총자산 1억. 뭔가 달라지는 것 같기도 하고 아닌 것 같기도 하다."},
	# ── 메타/런 ──
	{"id":"five_runs_title",    "name":"다섯 번의 인생",    "cat":"메타", "rare":"common",
	 "desc":"다섯 번의 삶을 끝까지 살아냈다. 매번 달랐다."},
	{"id":"ten_runs_title",     "name":"열 번의 인생",      "cat":"메타", "rare":"uncommon",
	 "desc":"열 번을 살았다. 이제 이 도시의 반복되는 얼굴이 보이기 시작한다."},
	{"id":"gangnam_dream_title","name":"강남드림 달성자",   "cat":"메타", "rare":"legendary",
	 "desc":"총자산 30억. 강남드림을 이뤘다. 다음엔 뭘 꿈꿔야 할까."},
	{"id":"burnout_survivor",   "name":"번아웃 생존자",     "cat":"메타", "rare":"common",
	 "desc":"번아웃 엔딩을 경험했다. 열심히 사는 것의 대가를 배웠다."},
	{"id":"ordinary_end_title", "name":"평범한 행복",       "cat":"메타", "rare":"uncommon",
	 "desc":"ordinary_life 엔딩. 평범함도 하나의 성취다."},
	# ── 미니게임 마스터리 ──
	{"id":"holdem_master_title","name":"홀덤 무법자",       "cat":"미니게임", "rare":"rare",
	 "desc":"지하 홀덤 클럽 15판 이상. 이제 패를 읽는다기보다, 상대를 읽는다."},
	{"id":"racetrack_master_title","name":"경마 귀신",      "cat":"미니게임", "rare":"rare",
	 "desc":"경마장 15판 이상. 폼지는 가끔 거짓말을 한다. 나는 이제 그것도 안다."},
	{"id":"scalping_master_title","name":"스캘퍼",          "cat":"미니게임", "rare":"uncommon",
	 "desc":"스캘핑 트레이딩 15회 이상. 1분 안에 사고 팔고. 손이 기억한다."},
	{"id":"baccarat_master_title","name":"정선 카지노 상주자",  "cat":"미니게임", "rare":"rare",
	 "desc":"바카라 15라운드 이상. 로드맵을 외웠지만 그게 아무 의미도 없다는 것도 안다."},
	{"id":"blackjack_master_title","name":"기본전략의 달인", "cat":"미니게임", "rare":"rare",
	 "desc":"블랙잭 15핸드 이상. 패를 보고 멈출지 받을지를 안다. 이게 이 게임의 전부다."},
	{"id":"slot_master_title","name":"잭팟 사냥꾼",      "cat":"미니게임", "rare":"uncommon",
	 "desc":"슬롯머신 20스핀 이상. 777이 나왔을 때 그 소리가 아직도 귓가에 맴돈다."},
	{"id":"roulette_master_title","name":"제로의 지배자", "cat":"미니게임", "rare":"rare",
	 "desc":"룰렛 15스핀 이상. 하우스엣지 2.7%는 알지만 멈출 수 없다."},
	{"id":"bigwheel_master_title","name":"바늘의 눈",     "cat":"미니게임", "rare":"uncommon",
	 "desc":"빅휠 15스핀 이상. 가장 단순한 게임이지만 45:1을 노린다."},
	{"id":"daisai_master_title","name":"주사위의 밤",      "cat":"미니게임", "rare":"uncommon",
	 "desc":"다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다."},
	# ── 전문화 ──
	{"id":"spec_elite_title",   "name":"엘리트의 길",       "cat":"성향", "rare":"uncommon",
	 "desc":"엘리트 전문화 선택. 정석의 끝에는 무엇이 있을까."},
	{"id":"spec_quant_title",   "name":"퀀트 마인드",       "cat":"성향", "rare":"uncommon",
	 "desc":"퀀트형 전문화 선택. 시장을 수식으로 본다."},
	{"id":"spec_founder_title", "name":"창업가 정신",       "cat":"성향", "rare":"rare",
	 "desc":"창업형 전문화 선택. 아무것도 없는 곳에서 시작한 사람."},
	# ── 런 테마 ──
	{"id":"clean_run_title",    "name":"청렴한 강남행",      "cat":"메타", "rare":"rare",
	 "desc":"도박 없이 30억에 도달했다. 이 도시에서 끝까지 원칙을 지켰다."},
	{"id":"network_run_title",  "name":"서울 인맥왕",        "cat":"메타", "rare":"uncommon",
	 "desc":"맺어 온 인연을 따라 강남에 들어섰다. 결국 사람이 가장 큰 자산이었다."},
	# ── 이야기의 선택 (스토리 분기 연동) ──
	{"id":"temptation_resist_title", "name":"그날 밤의 선택", "cat":"이야기", "rare":"common",
	 "desc":"가장 어려울 때 쉬운 돈을 거절했다. 그 선택이 모든 것의 시작이었다."},
	{"id":"high_road_title",    "name":"선을 지킨 사람",     "cat":"이야기", "rare":"rare",
	 "desc":"친구를 경찰에 넘겼다. 옳은 일은 가끔 가장 아픈 일이다."},
	{"id":"father_peace_title", "name":"마지막 봄",          "cat":"이야기", "rare":"uncommon",
	 "desc":"아버지와 화해했다. 벚꽃이 피기 전에, 늦지 않게."},
	{"id":"love_chosen_title",  "name":"사랑을 택한 사람",   "cat":"이야기", "rare":"uncommon",
	 "desc":"갈림길에서 다은을 붙잡았다. 강남보다 먼저 잡은 것."},
	{"id":"investigator_title", "name":"의심하는 자",        "cat":"이야기", "rare":"uncommon",
	 "desc":"친구의 경고를 흘려듣지 않았다. 의심은 때로 우정의 다른 이름이다."},
	{"id":"white_gangnam_title","name":"수첩의 다음 장",      "cat":"메타",   "rare":"legendary",
	 "desc":"30억과 강남의 등기를 손에 쥔 뒤, 하지 않았던 일들을 돌아보며 오래된 수첩의 다음 장을 폈다."},
]

const TITLE_EN := {
	"gosiwon_survivor": {"name":"Gosiwon Survivor", "cat":"Housing", "desc":"Survived 12 months in a gosiwon. You will not forget that room."},
	"first_move": {"name":"First Move", "cat":"Housing", "desc":"Left the gosiwon for the first time and moved into a new space."},
	"apartment_life": {"name":"Apartment Life", "cat":"Housing", "desc":"Finally living in an apartment. Even the security guard greets you."},
	"gangnam_resident": {"name":"Gangnam Resident", "cat":"Housing", "desc":"A Gangnam apartment. The address alone changes how people look at you."},
	"long_gosiwon": {"name":"Long-Term Gosiwon Tenant", "cat":"Housing", "desc":"24 months in a gosiwon. Even the smell has started to feel like home."},
	"first_paycheck": {"name":"Weight of the First Paycheck", "cat":"Career", "desc":"Your first salary hit the account. It felt joyful and strangely hollow."},
	"one_year_worker": {"name":"One-Year Worker", "cat":"Career", "desc":"Stayed at the same company for a year. Somehow, you became senior to someone."},
	"three_year_worker": {"name":"Office Veteran", "cat":"Career", "desc":"Three years. Your name has seeped into the company's filing cabinets."},
	"long_unemployed": {"name":"Freedom of Unemployment", "cat":"Career", "desc":"Stayed unemployed for 12 months. Some call it joblessness. Some call it freedom."},
	"first_investment": {"name":"First Investment", "cat":"Investment", "desc":"Bought your first stock. From that day on, you opened the app every day."},
	"margin_called": {"name":"Lesson of the Margin Call", "cat":"Investment", "desc":"A leveraged position was liquidated. An expensive lesson."},
	"invest_master_title": {"name":"The Closed Laptop", "cat":"Investment", "desc":"After watching the market before dawn, you learned to close the screen at the moment you had set for yourself."},
	"survived_broke": {"name":"Zero-Balance Survivor", "cat":"Investment", "desc":"Your balance went below zero and came back."},
	"steady_youth": {"name":"The Stairs Already There", "cat":"Tendency", "desc":"You kept choosing the stairs already there over unfamiliar shortcuts, one step at a time."},
	"elite_course": {"name":"The Long Climb", "cat":"Tendency", "desc":"You stayed on the same staircase for a long time. The view grew familiar, and some turnoffs slipped behind you."},
	"outsider_title": {"name":"Another Exit", "cat":"Tendency", "desc":"More than once, you stepped away from the crowd and chose another exit."},
	"dangerous_dreamer": {"name":"Beyond the Map", "cat":"Tendency", "desc":"You stayed on roads the map did not show, even on days when the ground felt uncertain."},
	"my_own_way": {"name":"Between Two Roads", "cat":"Tendency", "desc":"You moved between the road already laid out and the road beyond the map. Neither one alone explains these five years."},
	"free_spirit": {"name":"An Afternoon of Your Own", "cat":"Tendency", "desc":"By the Han River, at convenience stores, and on long walks, you spent time that belonged to no one else's schedule."},
	"seoul_love": {"name":"Love in Seoul", "cat":"Relationships", "desc":"Even in this complicated city, you came to care for someone."},
	"social_king_title": {"name":"Familiar Seats", "cat":"Relationships", "desc":"Around Seoul, people began greeting you first and making room when you arrived."},
	"loner_title": {"name":"Evenings Walked Alone", "cat":"Relationships", "desc":"Even on evenings when no one came to mind to call, walking alone had become familiar."},
	"stress_survivor": {"name":"The Next Morning", "cat":"Lifestyle", "desc":"A night when it was hard to hold yourself together passed, and the next morning still came."},
	"first_10m_title": {"name":"First KRW 10M", "cat":"Assets", "desc":"KRW 10 million cash. For the first time in Seoul, you could breathe."},
	"first_100m_title": {"name":"First KRW 100M", "cat":"Assets", "desc":"KRW 100 million net worth. Something changed. Or maybe nothing did."},
	"five_runs_title": {"name":"Five Lives", "cat":"Meta", "desc":"Lived five lives all the way through. Each one was different."},
	"ten_runs_title": {"name":"Ten Lives", "cat":"Meta", "desc":"Lived ten lives. The city's recurring patterns are starting to show."},
	"gangnam_dream_title": {"name":"Gangnam Dream Achiever", "cat":"Meta", "desc":"KRW 3 billion net worth. You achieved the Gangnam Dream. What do you dream of next?"},
	"burnout_survivor": {"name":"Burnout Survivor", "cat":"Meta", "desc":"Experienced the burnout ending. You learned the price of trying too hard."},
	"ordinary_end_title": {"name":"Ordinary Happiness", "cat":"Meta", "desc":"Ordinary Life ending. Even normalcy can be an achievement."},
	"holdem_master_title": {"name":"Hold'em Outlaw", "cat":"Mini-Games", "desc":"Played 15 or more underground hold'em games. You read people now, not cards."},
	"racetrack_master_title": {"name":"Racetrack Ghost", "cat":"Mini-Games", "desc":"Bet on 15 or more races. Form lies sometimes. Now you know that too."},
	"scalping_master_title": {"name":"Scalper", "cat":"Mini-Games", "desc":"Scalped 15 or more times. Buy and sell within a minute. Your hands remember."},
	"baccarat_master_title": {"name":"Jeongseon Casino Regular", "cat":"Mini-Games", "desc":"Played 15 or more baccarat rounds. You memorized the roadmap and learned it means nothing."},
	"blackjack_master_title": {"name":"Basic Strategy Master", "cat":"Mini-Games", "desc":"Played 15 or more blackjack hands. Hit or stand. That is the whole game."},
	"slot_master_title": {"name":"Jackpot Hunter", "cat":"Mini-Games", "desc":"Spun slots 20 or more times. The sound of 777 still echoes."},
	"roulette_master_title": {"name":"Master of Zero", "cat":"Mini-Games", "desc":"Spun roulette 15 or more times. You know the 2.7% house edge and still cannot stop."},
	"bigwheel_master_title": {"name":"Eye of the Needle", "cat":"Mini-Games", "desc":"Spun the big wheel 15 or more times. The simplest game, still chasing 45:1."},
	"daisai_master_title": {"name":"Night of Dice", "cat":"Mini-Games", "desc":"Played 15 or more Dai Sai rounds. You remember the sound of three dice rolling."},
	"spec_elite_title": {"name":"Path of the Elite", "cat":"Tendency", "desc":"Chose the elite specialization. What waits at the end of the proper path?"},
	"spec_quant_title": {"name":"Quant Mind", "cat":"Tendency", "desc":"Chose the quant specialization. You see the market as equations."},
	"spec_founder_title": {"name":"Founder Spirit", "cat":"Tendency", "desc":"Chose the founder specialization. Someone who began from nothing."},
	"clean_run_title": {"name":"Clean Road to Gangnam", "cat":"Meta", "desc":"Reached 3 billion won without gambling and held to your principles in this city."},
	"network_run_title": {"name":"Seoul Network King", "cat":"Meta", "desc":"The people you came to know opened the way into Gangnam. In the end, people were the greatest asset."},
	"temptation_resist_title": {"name":"Choice That Night", "cat":"Story", "desc":"Refused easy money when things were hardest. That choice began everything."},
	"high_road_title": {"name":"One Who Held the Line", "cat":"Story", "desc":"Turned your friend over to the police. The right thing is sometimes the most painful thing."},
	"father_peace_title": {"name":"Last Spring", "cat":"Story", "desc":"Made peace with your father. Before the cherry blossoms. Before it was too late."},
	"love_chosen_title": {"name":"One Who Chose Love", "cat":"Story", "desc":"Held onto Daeun at the crossroads. Something you caught before Gangnam."},
	"investigator_title": {"name":"The Suspicious One", "cat":"Story", "desc":"Did not dismiss your friend's warning. Suspicion is sometimes another name for friendship."},
	"white_gangnam_title": {"name":"The Notebook's Next Page", "cat":"Meta", "desc":"With 3 billion won and a Gangnam deed in hand, you looked back on what you had refused to do and opened the old notebook to its next page."},
}

# ── 칭호 보유 → 다음 런 시작 보너스 (카테고리별, 상한 있음) ────────
const PERK_RULES := {
	"투자":     {"stat": "investment_skill", "per": 1, "cap": 4},
	"직업":     {"stat": "intelligence",     "per": 1, "cap": 4},
	"관계":     {"stat": "social_skill",     "per": 1, "cap": 4},
	"주거":     {"stat": "mental",           "per": 1,  "cap": 4},
	"성향":     {"stat": "luck",             "per": 1, "cap": 4},
	"이야기":   {"stat": "mental",           "per": 1, "cap": 4},
	"메타":     {"stat": "money",            "per": 50_000, "cap": 250_000},
	"미니게임": {"stat": "money",            "per": 50_000, "cap": 150_000},
}

## 해금 칭호 수에 비례한 시작 보너스를 계산한다. {"investment_skill": 2, "money": 100000, ...}
func get_run_start_bonus() -> Dictionary:
	var counts: Dictionary = {}
	for tid in get_unlocked_titles():
		var info = _get_title_info_raw(str(tid))
		if info.is_empty():
			continue
		var cat = str(info.get("cat", ""))
		counts[cat] = int(counts.get(cat, 0)) + 1
	var bonus: Dictionary = {}
	for cat in counts:
		if not PERK_RULES.has(cat):
			continue
		var rule: Dictionary = PERK_RULES[cat]
		var stat = str(rule["stat"])
		var amount = int(rule["per"]) * int(counts[cat])
		var cap = int(rule["cap"])
		amount = clampi(amount, mini(cap, 0), maxi(cap, 0))
		bonus[stat] = int(bonus.get(stat, 0)) + amount
	return bonus

func _ready():
	load_meta()

func load_meta():
	data = DataRegistry.default_meta.duplicate(true)
	var path := meta_save_path()
	if FileAccess.file_exists(path):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
		if parsed is Dictionary:
			data.merge(parsed, true)
	var migrated := false
	if not data.get("seen_scenes", []) is Array:
		# Keep malformed history fail-closed, but normalize the container so the
		# next trusted live encounter can create a fresh atomic pair instead of
		# leaving gallery repair permanently impossible.
		data["seen_scenes"] = []
		migrated = true
	if not data.get("scene_replay_snapshots", {}) is Dictionary:
		data["scene_replay_snapshots"] = {}
		migrated = true
	# Do not manufacture a gallery pair from old scene history. Legacy seen-only
	# and orphan snapshot records stay intact but locked until a real live scene
	# can capture the missing half of the pair.
	var raw_seen_scenes: Variant = data.get("seen_scenes", [])
	var raw_replay_snapshots: Variant = data.get("scene_replay_snapshots", {})
	if raw_seen_scenes is Array and raw_replay_snapshots is Dictionary \
			and (raw_seen_scenes as Array).has(DEMO_CORE_LOOP_V2.FIRST_BILL_DECISION_ID) \
			and not (raw_seen_scenes as Array).has(
				DEMO_CORE_LOOP_V2.FIRST_BILL_OPENING_ID):
		# This is the one exact historical alias, not an orphan repair: the old
		# seen ID proves the encounter and the complete opening snapshot proves
		# the frozen frame. Keep the old ID and add its renamed gallery root.
		var legacy_snapshot := validate_scene_replay_snapshot(
			DEMO_CORE_LOOP_V2.FIRST_BILL_OPENING_ID,
			(raw_replay_snapshots as Dictionary).get(
				DEMO_CORE_LOOP_V2.FIRST_BILL_OPENING_ID, {}))
		if not legacy_snapshot.is_empty():
			var preserved_seen: Array = (raw_seen_scenes as Array).duplicate()
			preserved_seen.append(DEMO_CORE_LOOP_V2.FIRST_BILL_OPENING_ID)
			data["seen_scenes"] = preserved_seen
			migrated = true
	var achievements: Array = data.get("achievements", [])
	var sanitized: Array = []
	for raw_id in achievements:
		var achievement_id := str(raw_id)
		if achievement_id in LEGACY_ACHIEVEMENT_IDS or not DataRegistry.achievements_by_id.has(achievement_id):
			migrated = true
			continue
		if sanitized.has(achievement_id):
			migrated = true
			continue
		sanitized.append(achievement_id)
	if migrated:
		data["achievements"] = sanitized
		save_meta()

func save_meta():
	var file = FileAccess.open(meta_save_path(), FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))

func meta_save_path() -> String:
	return BUILD_FLAVOR.meta_path()

func is_gallery_replay_root(scene_id: String) -> bool:
	return scene_id in GALLERY_REPLAY_ROOT_IDS

## State-free authored closure used by capture and QA. Every branch follow-up is
## included once in authored order; missing/malformed events fail closed.
func gallery_replay_closure_ids(root_id: String) -> Array[String]:
	if not is_gallery_replay_root(root_id):
		return []
	var closure: Array[String] = []
	var pending: Array[String] = [root_id]
	while not pending.is_empty():
		if closure.size() + pending.size() > 64:
			return []
		var event_id: String = pending.pop_front()
		if closure.has(event_id):
			continue
		var event: Dictionary = DataRegistry.find_event(event_id)
		var raw_choices: Variant = event.get("choices", null)
		if event.is_empty() or not raw_choices is Array:
			return []
		closure.append(event_id)
		for raw_choice in raw_choices as Array:
			if not raw_choice is Dictionary:
				return []
			var follow_up_id := str(
				(raw_choice as Dictionary).get("follow_up_event", "")).strip_edges()
			if not follow_up_id.is_empty() \
					and not closure.has(follow_up_id) \
					and not pending.has(follow_up_id):
				pending.append(follow_up_id)
	return closure

## StoryMode owns the exact authored closure because it owns selector and choice
## visibility semantics. MetaProgression adds only the locale-neutral live frame
## and rejects partial or unbounded maps before anything can be persisted.
func build_scene_replay_snapshot(
		scene_id: String,
		selector_matches: Dictionary,
		visible_choice_indices: Dictionary) -> Dictionary:
	if not is_gallery_replay_root(scene_id) \
			or scene_id == DEMO_CORE_LOOP_V2.FIRST_BILL_OPENING_ID:
		return {}
	return validate_scene_replay_snapshot(scene_id, {
		"schema": SCENE_REPLAY_SCHEMA,
		"scene_id": scene_id,
		"player_name": str(GameState.player_name),
		"turn": int(GameState.turn),
		"moral_tint": float(GameState.moral_tint),
		"housing": str(GameState.housing),
		"selector_matches": selector_matches.duplicate(true),
		"visible_choice_indices": visible_choice_indices.duplicate(true),
	})

## Compatibility name retained for existing First Bill callers. Recording a
## gallery snapshot now always means recording the valid seen+snapshot pair.
func record_scene_replay_snapshot(scene_id: String, snapshot: Dictionary) -> bool:
	return record_scene_replay_pair(scene_id, snapshot)

## A trusted live encounter is the sole writer. Build both halves on a detached
## candidate and persist once; an already-valid pair is permanently write-once.
## A seen-only, orphan, or corrupt record is not a pair, so the next real live
## encounter may repair it without deleting any historical scene IDs.
func record_scene_replay_pair(scene_id: String, snapshot: Dictionary) -> bool:
	if not is_gallery_replay_root(scene_id):
		return false
	var validated := validate_scene_replay_snapshot(scene_id, snapshot)
	if validated.is_empty():
		return false
	if has_valid_scene_replay_pair(scene_id):
		return true
	var candidate := data.duplicate(true)
	var raw_seen: Variant = candidate.get("seen_scenes", [])
	if not raw_seen is Array:
		return false
	var scenes: Array = (raw_seen as Array).duplicate()
	if not scenes.has(scene_id):
		scenes.append(scene_id)
	var raw_snapshots: Variant = candidate.get("scene_replay_snapshots", {})
	var snapshots: Dictionary = (raw_snapshots as Dictionary).duplicate(true) \
		if raw_snapshots is Dictionary else {}
	snapshots[scene_id] = validated.duplicate(true)
	candidate["seen_scenes"] = scenes
	candidate["scene_replay_snapshots"] = snapshots
	data = candidate
	save_meta()
	return true

func has_valid_scene_replay_pair(scene_id: String) -> bool:
	if not is_gallery_replay_root(scene_id):
		return false
	var raw_seen: Variant = data.get("seen_scenes", [])
	if not raw_seen is Array or not (raw_seen as Array).has(scene_id):
		return false
	return not get_scene_replay_snapshot(scene_id).is_empty()

func get_scene_replay_snapshot(scene_id: String) -> Dictionary:
	if not is_gallery_replay_root(scene_id):
		return {}
	var snapshots: Variant = data.get("scene_replay_snapshots", {})
	if not snapshots is Dictionary or not snapshots.has(scene_id):
		return {}
	return validate_scene_replay_snapshot(scene_id, snapshots.get(scene_id, {}))

func validate_scene_replay_snapshot(scene_id: String, snapshot: Variant) -> Dictionary:
	if not is_gallery_replay_root(scene_id) or not snapshot is Dictionary:
		return {}
	if not _is_json_safe(snapshot):
		return {}
	var encoded := JSON.stringify(snapshot)
	if encoded.to_utf8_buffer().size() > SCENE_REPLAY_SNAPSHOT_MAX_BYTES:
		return {}
	var decoded: Variant = JSON.parse_string(encoded)
	if not decoded is Dictionary:
		return {}
	var common := _validated_scene_replay_common(scene_id, decoded as Dictionary)
	if common.is_empty():
		return {}
	if scene_id == DEMO_CORE_LOOP_V2.FIRST_BILL_OPENING_ID:
		if not _dictionary_has_only_string_keys(
				decoded as Dictionary, FIRST_BILL_REPLAY_ALLOWED_KEYS):
			return {}
		return DEMO_CORE_LOOP_V2.validated_complete_first_bill_replay_snapshot(
			decoded as Dictionary)
	return _validated_generic_scene_replay_snapshot(decoded as Dictionary)

func _validated_scene_replay_common(
		scene_id: String, snapshot: Dictionary) -> Dictionary:
	if snapshot.get("scene_id", null) != scene_id \
			or not _valid_scene_replay_schema(snapshot.get("schema", null)):
		return {}
	var raw_name: Variant = snapshot.get("player_name", null)
	var raw_turn: Variant = snapshot.get("turn", null)
	var raw_moral: Variant = snapshot.get("moral_tint", null)
	var raw_housing: Variant = snapshot.get("housing", null)
	if not raw_name is String or (raw_name as String).strip_edges().is_empty() \
			or (raw_name as String).length() > 64 \
			or not _valid_integral_number(raw_turn, 1, 240) \
			or typeof(raw_moral) not in [TYPE_INT, TYPE_FLOAT] \
			or not is_finite(float(raw_moral)) \
			or float(raw_moral) < -100.0 or float(raw_moral) > 100.0 \
			or not raw_housing is String \
			or str(raw_housing) not in GALLERY_REPLAY_HOUSING_IDS:
		return {}
	return snapshot

func _validated_generic_scene_replay_snapshot(snapshot: Dictionary) -> Dictionary:
	if not _dictionary_has_exact_string_keys(snapshot, GALLERY_REPLAY_GENERIC_KEYS):
		return {}
	var raw_selectors: Variant = snapshot.get("selector_matches", null)
	var raw_choices: Variant = snapshot.get("visible_choice_indices", null)
	if not raw_selectors is Dictionary or not raw_choices is Dictionary:
		return {}
	var selectors: Dictionary = raw_selectors
	var choices: Dictionary = raw_choices
	var closure: Array[String] = gallery_replay_closure_ids(
		str(snapshot.get("scene_id", "")))
	if closure.is_empty() or selectors.size() != closure.size() \
			or selectors.size() != choices.size():
		return {}
	var normalized_selectors: Dictionary = {}
	var normalized_choices: Dictionary = {}
	for event_id in closure:
		if not selectors.has(event_id) or not choices.has(event_id):
			return {}
	for raw_event_id in selectors:
		if not raw_event_id is String:
			return {}
		var event_id := str(raw_event_id)
		var authored_event: Dictionary = DataRegistry.find_event(event_id)
		var authored_choices: Variant = authored_event.get("choices", null)
		if authored_event.is_empty() or not authored_choices is Array:
			return {}
		if not _valid_locale_neutral_id(event_id) \
				or not choices.has(event_id) \
				or not _valid_snapshot_id_array(
					selectors[event_id],
					_gallery_authored_selector_ids(authored_event)) \
				or not _valid_snapshot_choice_array(
					choices[event_id], (authored_choices as Array).size()):
			return {}
		var selector_ids: Array[String] = []
		for raw_selector_id in selectors[event_id] as Array:
			selector_ids.append(str(raw_selector_id))
		normalized_selectors[event_id] = selector_ids
		var choice_indices: Array[int] = []
		for raw_choice_index in choices[event_id] as Array:
			choice_indices.append(int(raw_choice_index))
		normalized_choices[event_id] = choice_indices
	var normalized := snapshot.duplicate(true)
	normalized["schema"] = SCENE_REPLAY_SCHEMA
	normalized["turn"] = int(snapshot["turn"])
	normalized["moral_tint"] = float(snapshot["moral_tint"])
	normalized["selector_matches"] = normalized_selectors
	normalized["visible_choice_indices"] = normalized_choices
	return normalized

func _valid_scene_replay_schema(value: Variant) -> bool:
	return _valid_integral_number(value, SCENE_REPLAY_SCHEMA, SCENE_REPLAY_SCHEMA)

func _valid_integral_number(value: Variant, minimum: int, maximum: int) -> bool:
	if typeof(value) not in [TYPE_INT, TYPE_FLOAT]:
		return false
	var numeric := float(value)
	return is_finite(numeric) and numeric == floorf(numeric) \
		and numeric >= float(minimum) and numeric <= float(maximum)

func _dictionary_has_exact_string_keys(
		dictionary: Dictionary, expected_keys: Array[String]) -> bool:
	if dictionary.size() != expected_keys.size():
		return false
	for key in expected_keys:
		if not dictionary.has(key):
			return false
	return true

func _dictionary_has_only_string_keys(
		dictionary: Dictionary, allowed_keys: Array[String]) -> bool:
	for raw_key in dictionary:
		if not raw_key is String or str(raw_key) not in allowed_keys:
			return false
	return true

func _gallery_authored_selector_ids(event: Dictionary) -> Dictionary:
	var authored: Dictionary = {}
	for map_key in [
		"portrait_if_known", "cg_if_known", "description_if_known",
		"description_if_held", "description_memory_if_known",
	]:
		var raw_map: Variant = event.get(map_key, {})
		if not raw_map is Dictionary:
			continue
		for raw_selector_id in (raw_map as Dictionary).keys():
			if raw_selector_id is String:
				authored[str(raw_selector_id).strip_edges()] = true
	for field_key in [
		"description_low_mental", "description_long_gosiwon",
		"description_orthodox", "description_unorthodox",
	]:
		if event.has(field_key):
			authored[field_key] = true
	var raw_choices: Variant = event.get("choices", [])
	if raw_choices is Array:
		for raw_choice in raw_choices as Array:
			if not raw_choice is Dictionary:
				continue
			var raw_flags: Variant = (raw_choice as Dictionary).get(
				"follow_up_requires_flags", [])
			if not raw_flags is Array:
				continue
			for raw_flag in raw_flags as Array:
				if raw_flag is String:
					authored[str(raw_flag).strip_edges()] = true
	authored.erase("")
	return authored

func _valid_snapshot_id_array(
		value: Variant, authored_ids: Dictionary) -> bool:
	if not value is Array or (value as Array).size() > 32:
		return false
	var seen: Dictionary = {}
	for raw_id in value as Array:
		if not raw_id is String:
			return false
		var condition_id := str(raw_id)
		if not _valid_locale_neutral_id(condition_id) \
				or not authored_ids.has(condition_id) or seen.has(condition_id):
			return false
		seen[condition_id] = true
	return true

func _valid_locale_neutral_id(value: String) -> bool:
	if value.is_empty() or value.length() > SCENE_REPLAY_SNAPSHOT_MAX_ID_LENGTH:
		return false
	for index in range(value.length()):
		var codepoint := value.unicode_at(index)
		if codepoint < 33 or codepoint > 126:
			return false
	return true

func _valid_snapshot_choice_array(value: Variant, authored_count: int) -> bool:
	if not value is Array or (value as Array).size() > 32:
		return false
	var previous := -1
	for raw_index in value as Array:
		if not _valid_integral_number(raw_index, 0, authored_count - 1):
			return false
		var index := int(raw_index)
		if index <= previous:
			return false
		previous = index
	return true

func _is_json_safe(value: Variant, depth: int = 0) -> bool:
	if depth > SCENE_REPLAY_SNAPSHOT_MAX_DEPTH:
		return false
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING:
			return true
		TYPE_FLOAT:
			var numeric := float(value)
			return not is_nan(numeric) and not is_inf(numeric)
		TYPE_ARRAY:
			if (value as Array).size() > SCENE_REPLAY_SNAPSHOT_MAX_COLLECTION_ITEMS:
				return false
			for item in value:
				if not _is_json_safe(item, depth + 1):
					return false
			return true
		TYPE_DICTIONARY:
			if (value as Dictionary).size() > SCENE_REPLAY_SNAPSHOT_MAX_COLLECTION_ITEMS:
				return false
			for key in value:
				if not key is String \
						or (key as String).length() > SCENE_REPLAY_SNAPSHOT_MAX_ID_LENGTH \
						or not _is_json_safe(value[key], depth + 1):
					return false
			return true
		_:
			return false

func unlock_achievement(achievement_id: String) -> bool:
	if not DataRegistry.achievements_by_id.has(achievement_id):
		push_warning("Unknown achievement id rejected: %s" % achievement_id)
		return false
	var achievements: Array = data.get("achievements", [])
	if not achievements.has(achievement_id):
		achievements.append(achievement_id)
		data["achievements"] = achievements
		save_meta()
		# 이번 런 해금 목록에 추가
		if not _new_this_run["achievements"].has(achievement_id):
			_new_this_run["achievements"].append(achievement_id)
		return true
	return false

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
	var raw := _get_title_info_raw(title_id)
	return _localized_title(raw)

func _get_title_info_raw(title_id: String) -> Dictionary:
	for t in ALL_TITLES:
		if t["id"] == title_id:
			return t
	return {}

func _localized_title(title: Dictionary) -> Dictionary:
	if title.is_empty() or not LocaleManager.is_english():
		return title
	var title_id := str(title.get("id", ""))
	if not TITLE_EN.has(title_id):
		return title
	var localized := title.duplicate(true)
	var en_info: Dictionary = TITLE_EN[title_id]
	for key in en_info:
		localized[key] = en_info[key]
	return localized

func check_and_unlock_titles() -> Array:
	var newly: Array = []
	for title in ALL_TITLES:
		var tid: String = title["id"]
		if get_unlocked_titles().has(tid):
			continue
		if _check_title_condition(tid):
			if unlock_title(tid):
				newly.append(_localized_title(title))
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
		"loner_title":        return GameState.relationships.is_empty() and (GameState.age - 33) * 12 + GameState.month >= 30
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
		# ── 미니게임 마스터리 칭호 ──
		"holdem_master_title":    return int(data.get("mg_plays_holdem", 0)) >= 15
		"racetrack_master_title": return int(data.get("mg_plays_racetrack", 0)) >= 15
		"scalping_master_title":  return int(data.get("mg_plays_scalping", 0)) >= 15
		"baccarat_master_title":   return int(data.get("mg_plays_baccarat", 0)) >= 15
		"blackjack_master_title":  return int(data.get("mg_plays_blackjack", 0)) >= 15
		"slot_master_title":       return int(data.get("mg_plays_slot", 0)) >= 20
		"roulette_master_title":   return int(data.get("mg_plays_roulette", 0)) >= 15
		"bigwheel_master_title":   return int(data.get("mg_plays_bigwheel", 0)) >= 15
		"daisai_master_title":     return int(data.get("mg_plays_daisai", 0)) >= 15
		# ── 전문화 칭호 ──
		"spec_elite_title":   return GameState.flags.get("spec_elite", false)
		"spec_quant_title":   return GameState.flags.get("spec_quant", false)
		"spec_founder_title": return GameState.flags.get("spec_tech_founder", false) or GameState.flags.get("spec_social_entrepreneur", false)
		# ── 런 테마 달성 칭호 ──
		"clean_run_title":
			for run in data.get("run_history", []):
				if run.get("run_theme","") == "청렴런" and float(run.get("total_assets",0)) >= 3_000_000_000: return true
			return false
		"network_run_title":
			for run in data.get("run_history", []):
				if run.get("run_theme","") == "인맥런" and run.get("ending_id","") == "gangnam_dream": return true
			return false
		# ── 이야기의 선택 칭호 ──
		"temptation_resist_title": return GameState.flags.get("kept_clean_hands", false)
		"high_road_title":         return GameState.flags.get("took_high_road", false)
		"father_peace_title":      return GameState.flags.get("father_reconciled", false)
		"love_chosen_title":       return GameState.flags.get("daeun_chose_her", false)
		"investigator_title":      return GameState.flags.get("started_investigating", false)
		"white_gangnam_title":     return has_discovered_ending("gangnam_dream_white")
	return false

func is_hidden_event_unlocked(event_id):
	return data.get("rare_event_unlocks", []).has(event_id) or data.get("unlocked_hidden_events", []).has(event_id)

func is_starting_profile_unlocked(profile_id: String) -> bool:
	match profile_id:
		"코인폐인": return int(data.get("total_runs", 0)) >= 1
	return true

# ── 미니게임 마스터리 트랙 ────────────────────────────────────────
# 등급: 0(입문) → 1(숙련) → 2(고급) → 3(마스터)
const MASTERY_THRESHOLDS := [0, 5, 15, 30]  # 플레이 횟수 → 해당 등급 해금

func record_minigame_play(game_id: String) -> int:
	## 미니게임 플레이를 기록하고 현재 마스터리 등급을 반환한다.
	## game_id: "holdem" | "racetrack" | "scalping" | "aruba"
	var key: String = "mg_plays_" + game_id
	var plays: int = int(data.get(key, 0)) + 1
	data[key] = plays
	save_meta()
	return get_mastery(game_id)

func get_mastery(game_id: String) -> int:
	## 현재 마스터리 등급 반환 (0~3).
	var plays: int = int(data.get("mg_plays_" + game_id, 0))
	var grade: int = 0
	for i in range(MASTERY_THRESHOLDS.size()):
		if plays >= MASTERY_THRESHOLDS[i]:
			grade = i
	return grade

func get_mastery_label(game_id: String) -> String:
	match get_mastery(game_id):
		0: return LocaleManager.ui("입문", "Novice")
		1: return LocaleManager.ui("숙련", "Skilled")
		2: return LocaleManager.ui("고급", "Advanced")
		3: return LocaleManager.ui("마스터", "Master")
	return LocaleManager.ui("입문", "Novice")

func get_new_unlocks() -> Dictionary:
	return _new_this_run.duplicate(true)

func record_run(summary):
	# 이번 런 해금 목록 초기화
	_new_this_run = {"achievements": []}
	data["total_runs"] = int(data.get("total_runs", 0)) + 1
	data["best_asset"] = max(float(data.get("best_asset", 0.0)), float(summary.get("total_assets", 0.0)))
	var history: Array = data.get("run_history", [])
	history.append(summary)
	if history.size() > 50:
		history.pop_front()
	data["run_history"] = history

	# ── 엔딩 도감 — 발견한 엔딩 영구 누적 (run_history 50캡과 무관하게 보존) ──
	var eid = str(summary.get("ending_id", ""))
	if eid != "":
		var discovered: Array = data.get("discovered_endings", [])
		if not discovered.has(eid):
			discovered.append(eid)
			data["discovered_endings"] = discovered
			_new_this_run["new_ending"] = eid

	# ── NG+ 영구 메타 플래그 저장 ──────────────────────────────
	# 런 종료 시점의 GameState.flags 스냅샷에서 NG+ 조건 플래그를 meta에 누적 저장
	var rf = GameState.flags
	# 임상철 진실을 알았는가 (아버지 빚 관련)
	if rf.get("sangchul_truth_known", false) or rf.get("father_confession_heard", false):
		data["sangchul_truth_ever_known"] = true
	# 아버지가 별세했는가
	if rf.get("father_passed", false):
		data["father_passed_ever"] = true
	# 다은 엔딩을 경험했는가 (선택하거나 놓쳤거나)
	if rf.get("daeun_chose_her", false) or rf.get("daeun_let_her_go", false):
		data["daeun_ending_ever_seen"] = true
	# 도박 중독을 이겨냈는가 (회복 아크 완주) — 향후 NG+ 구원 서사 토대
	if rf.get("beat_addiction", false):
		data["beat_addiction_ever"] = true
		unlock_achievement("beat_addiction")
	# 히든 업적 "사계" — 한 런에서 계절 스페셜 데이트 4종(벚꽃·바다·불꽃·첫눈)을 모두 경험
	if int(rf.get("last_cherry_date_year", 0)) > 0 and int(rf.get("last_sea_date_year", 0)) > 0 \
			and int(rf.get("last_fireworks_date_year", 0)) > 0 and int(rf.get("last_snow_date_year", 0)) > 0:
		unlock_achievement("four_seasons")
	# 히든 업적 "증거 제출" — 대면 장면에서 간직한 유물을 스스로 꺼내 보임(역전재판식 제시)
	if rf.get("presented_artifact_correct", false):
		unlock_achievement("kept_evidence")

	_check_progression_unlocks(summary)
	save_meta()

func get_unlocked_achievements() -> Array:
	return data.get("achievements", [])

# ── 엔딩 도감 (분석요소 — 컴플리션 후크) ──────────────────────
func get_discovered_endings() -> Array:
	return data.get("discovered_endings", [])

func has_discovered_ending(ending_id: String) -> bool:
	return get_discovered_endings().has(ending_id)

# 전체 엔딩 수 대비 발견 수. 숨겨진(?) 엔딩은 발견 전까지 카운트에서 가린다.
func get_ending_collection_progress() -> Dictionary:
	var total := DataRegistry.endings.size()
	var found := 0
	for e in DataRegistry.endings:
		if get_discovered_endings().has(str(e.get("id", ""))):
			found += 1
	return {"found": found, "total": total}

func is_achievement_unlocked(achievement_id: String) -> bool:
	return data.get("achievements", []).has(achievement_id)

# ── 회상 갤러리 ──────────────────────────────────────────────────
func record_scene_seen(scene_id: String) -> bool:
	if scene_id.is_empty() or is_gallery_replay_root(scene_id):
		return false
	var scenes: Array = data.get("seen_scenes", [])
	if scenes.has(scene_id):
		return false
	scenes.append(scene_id)
	data["seen_scenes"] = scenes
	save_meta()
	return true

func has_seen_scene(scene_id: String) -> bool:
	return data.get("seen_scenes", []).has(scene_id)

func get_seen_scenes() -> Array:
	return data.get("seen_scenes", []).duplicate()

func record_cg_unlocked(cg_id: String) -> bool:
	if cg_id.is_empty():
		return false
	var cgs: Array = data.get("unlocked_cgs", [])
	if cgs.has(cg_id):
		return false
	cgs.append(cg_id)
	data["unlocked_cgs"] = cgs
	save_meta()
	return true

func is_cg_unlocked(cg_id: String) -> bool:
	return data.get("unlocked_cgs", []).has(cg_id)

func get_unlocked_cgs() -> Array:
	return data.get("unlocked_cgs", []).duplicate()

func _check_progression_unlocks(summary):
	var total_assets = float(summary.get("total_assets", 0.0))
	var ending_id = str(summary.get("ending_id", ""))
	var total_runs = int(data.get("total_runs", 0))

	# 자산 기준 업적
	if total_assets >= 100_000_000:
		unlock_achievement("first_billion")

	# 엔딩 기준 업적
	if ending_id in ["stable_success", "ordinary_life"]:
		unlock_achievement("stable_life")
	if ending_id == "gangnam_dream":
		unlock_achievement("gangnam_dream")
	if ending_id == "gangnam_dream_white":
		unlock_achievement("gangnam_dream")    # 강남드림 기본 업적도 함께
	if ending_id in ["burnout", "mental_break"]:
		unlock_achievement("survived_burnout")
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
		unlock_achievement("ten_lives")

	# 런 종료 시점 칭호 체크 (메타 칭호)
	check_and_unlock_titles()
