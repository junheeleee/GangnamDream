extends Node

const EVENT_PATHS = [
	"res://content/events/story_events.json",
	"res://content/events/arc_events.json",
	"res://content/events/arc_hyunsu.json",
	"res://content/events/arc_pre_ending.json",
	"res://content/events/easter_eggs.json",
	"res://content/events/viral_events.json",
	"res://content/events/arc_addiction_recovery.json",
	"res://content/events/social_independence.json",
	"res://content/events/arc_drama.json",
	"res://content/events/arc_midgame.json",
	"res://content/events/arc_housing_keepsake.json",
	"res://content/events/ng_plus_events.json",
	"res://content/events/arc_daeun.json",
	"res://content/events/arc_specialization.json",
	"res://content/events/chapter_cards.json",
	"res://content/events/scenario_cafe.json",
	"res://content/events/scenario_cafe_callback.json",
	"res://content/events/amb_scenarios.json",
	"res://content/events/amb_scenarios2.json",
	"res://content/events/amb_scenarios3.json",
	"res://content/events/amb_scenarios4.json",
	"res://content/events/amb_scenarios5.json",
	"res://content/events/amb_scenarios6.json",
	"res://content/events/life_events.json",
	"res://content/events/life_events2.json",
	"res://content/events/investment_events.json",
	"res://content/events/shadow_events.json",
	"res://content/events/relationship_events.json",
	"res://content/events/relationship_events2.json",
	"res://content/events/hidden_events.json",
	"res://content/events/drama_events.json",
	"res://content/events/drama_events2.json",
	"res://content/events/amb_scenarios7.json",
	"res://content/events/racetrack_events.json",
	"res://content/events/holdem_events.json",
	"res://content/events/gambling_narrative.json",
	"res://content/events/anxiety_events.json",
	"res://content/events/identity_events.json",
	"res://content/events/work_events.json",
	"res://content/events/korea_experience.json",
	"res://content/events/korea_leisure.json",
	"res://content/events/korea_fandom.json",
	"res://content/events/korea_food.json",
	"res://content/events/korea_survival.json",
	"res://content/events/korea_climate.json",
	"res://content/events/korea_geopolitics.json",
	"res://content/events/korea_fortune.json",
	"res://content/events/korea_admin.json",
	"res://content/events/korea_digital.json",
	"res://content/events/korea_education.json",
	"res://content/events/korea_holidays.json",
	"res://content/events/korea_workplace.json",
	"res://content/events/friendship_events.json",
	"res://content/events/rare_encounter_events.json",
	"res://content/events/butterfly_events.json",
	"res://content/events/chain_events.json",
	"res://content/events/callback_events.json",
	"res://content/events/callback_events_2.json",
	"res://content/events/callback_events_3.json",
	"res://content/events/callback_events_4.json",
	"res://content/events/callback_events_5.json",
	"res://content/events/callback_events_6.json",
	"res://content/events/callback_events_7.json",
	"res://content/events/callback_events_8.json",
	"res://content/events/callback_events_9.json",
	"res://content/events/callback_events_10.json",
	"res://content/events/callback_events_11.json",
	"res://content/events/callback_events_12.json",
	"res://content/events/callback_events_13.json",
	"res://content/events/callback_events_14.json",
	"res://content/events/callback_events_15.json",
	"res://content/events/callback_events_16.json",
	"res://content/events/callback_events_17.json",
	"res://content/events/callback_events_18.json",
	"res://content/events/callback_events_19.json",
	"res://content/events/callback_events_20.json",
	"res://content/events/callback_events_21.json",
	"res://content/events/callback_events_22.json",
	"res://content/events/callback_events_23.json",
	"res://content/events/callback_events_24.json",
	"res://content/events/callback_events_25.json",
	"res://content/events/callback_events_26.json",
	"res://content/events/callback_events_27.json",
	"res://content/events/callback_events_28.json",
	"res://content/events/callback_events_29.json",
	"res://content/events/callback_events_30.json",
	"res://content/events/callback_events_31.json",
	"res://content/events/callback_events_32.json",
	"res://content/events/callback_events_33.json",
	"res://content/events/callback_events_34.json",
	"res://content/events/callback_events_35.json",
	"res://content/events/callback_events_36.json",
	"res://content/events/callback_events_37.json",
	"res://content/events/callback_events_38.json",
	"res://content/events/callback_events_39.json",
	"res://content/events/callback_events_40.json",
	"res://content/events/callback_events_41.json",
	"res://content/events/callback_events_42.json",
	"res://content/events/callback_events_43.json",
	"res://content/events/callback_events_44.json",
	"res://content/events/callback_events_45.json",
	"res://content/events/callback_events_46.json",
	"res://content/events/callback_events_47.json",
	"res://content/events/callback_events_48.json",
	"res://content/events/callback_events_49.json",
	"res://content/events/callback_events_50.json",
	"res://content/events/callback_events_51.json",
	"res://content/events/callback_events_52.json",
	"res://content/events/callback_events_53.json",
	"res://content/events/callback_events_54.json",
	"res://content/events/callback_events_55.json",
	"res://content/events/callback_chapter_themes.json",
	"res://content/events/arc_new_characters.json",
	"res://content/events/arc_daeun_extension.json",
	"res://content/events/arc_daeun_romance.json",
	"res://content/events/arc_daeun_married.json",
	"res://content/events/arc_jiyeon_married.json",
	"res://content/events/arc_web_crossbeams.json",
	"res://content/events/arc_chapter_themes.json",
	"res://content/events/arc_year3_drama.json",
	"res://content/events/arc_year_close.json",
	"res://content/events/arc_romance_y5.json",
	"res://content/events/arc_h2_beats.json",
	"res://content/events/arc_date_milestones.json",
	"res://content/events/arc_season_dates.json",
	"res://content/events/arc_romance_specials.json",
]
const ASSETS_PATH = "res://content/assets.json"
const JOBS_PATH = "res://content/jobs.json"
const ITEMS_PATH = "res://content/items.json"
const ENDINGS_PATH = "res://content/endings.json"
const ENDINGS_EN_PATH = "res://content/endings_en.json"
const EVENT_LOCALE_DIR := "res://content/events_%s/"
const ENDINGS_LOCALE_PATH := "res://content/endings_%s.json"
const CATALOG_LOCALE_PATH := "res://locale/catalog_%s.json"
const EXTERNAL_EVENT_TEXT_FIELDS := [
	"title", "description", "subtitle", "description_orthodox",
	"description_unorthodox", "description_low_mental",
	"description_long_gosiwon", "description_long_apartment",
]
const EXTERNAL_EVENT_DICT_FIELDS := [
	"description_if_known", "description_memory_if_known", "description_if_moral",
]
const EXTERNAL_CHOICE_TEXT_FIELDS := ["text", "result_text", "tooltip", "bridge_summary"]
const EXTERNAL_CHOICE_DICT_FIELDS := ["text_if_moral"]
const EXTERNAL_ENDING_TEXT_FIELDS := [
	"title", "subtitle", "description", "detailed_description", "epilogue", "condition",
]
const EXTERNAL_ENDING_DICT_FIELDS := ["description_if_known"]
const NEWS_PATH = "res://content/news_templates.json"
const META_PATH = "res://content/meta/default_meta.json"
const ACHIEVEMENTS_PATH = "res://content/meta/achievements.json"
const CLUES_PATH = "res://content/meta/clues.json"
const THOUGHTS_PATH = "res://content/meta/thoughts.json"
const STORY_RULES_PATH = "res://content/meta/story_rules.json"
const SCENE_DIRECTION_MANIFEST_PATH = "res://assets/scene_direction_manifest.json"
const MOD_EVENT_ROOT_KEYS := [
	"id", "title", "description", "category", "rarity", "weight", "hidden",
	"conditions", "tags", "cooldown", "choices", "portrait", "portrait_if_known",
	"portrait_reveal_paragraph", "background", "paragraph_backgrounds", "cg",
	"cg_if_known", "cg_reveal_paragraph", "speaker", "one_time", "result_cg",
	"result_cg_reveal_paragraph", "result_background", "timed", "timer_seconds",
	"timer_default_choice", "description_orthodox", "description_unorthodox",
	"description_low_mental", "description_long_gosiwon", "description_if_known",
	"description_memory_if_known", "description_if_moral", "direction", "living_scene",
	"year_scene_year", "override",
]
const MOD_CHOICE_KEYS := [
	"text", "text_if_moral", "effects", "flags", "follow_up_event", "result_text",
	"result_cg", "result_cg_reveal_paragraph", "result_background", "result_ambience",
	"opportunity", "cast_effects", "relationship_effects", "investment_effects",
	"tendency", "route", "grant_job", "replace_current_job", "conditions_note", "deferred_follow_up",
	"deferred_delay", "foreshadow", "bridge_summary", "clues", "give_items",
	"requires_item", "housing_keepsake", "year_scene",
]
const MOD_EVENT_SCHEDULE_KEYS := [
	"id", "category", "rarity", "weight", "hidden", "conditions", "tags",
	"cooldown", "one_time", "timed", "timer_seconds", "timer_default_choice",
	"year_scene_year",
]
const MOD_CHOICE_SCHEDULE_KEYS := ["follow_up_event", "deferred_follow_up", "deferred_delay"]

const JOB_TEXT_EN := {
	"job_01": {"name": "Convenience Store Night Shift", "description": "Hold the counter late at night: rude customers, parcels, cleaning, all alone. Minimum wage, but right now it is everything."},
	"job_02": {"name": "Delivery Rider", "description": "Ride until the phone battery and your body run out. Rainy-day bonuses help, but one accident can end everything."},
	"job_03": {"name": "SME Office Clerk", "description": "You check the clock more and more. Growth is uncertain, but the fixed paycheck keeps you standing."},
	"job_04": {"name": "Call Center Agent", "description": "Two hundred calls a day. Even when cursed at, you answer politely. Either your mind toughens or breaks."},
	"job_05": {"name": "Academy Teaching Assistant", "description": "Copying handouts, attendance, parent calls behind the instructor. The treatment is poor, but knowledge slowly accumulates."},
	"job_06": {"name": "Frontend Developer", "description": "A person who makes screens. Overtime is normal and CSS always strikes from behind. The salary curve is among the best."},
	"job_07": {"name": "Financial Analyst", "description": "Read the market every morning and publish investment views. Sometimes one report moves prices. The market is the teacher."},
	"job_08": {"name": "Corporate Entry-Level Employee", "description": "The brand name has weight. So does the internal competition. Survive office politics and company dinners, and stability follows."},
	"job_09": {"name": "Public Agency Contract Worker", "description": "More stable than private work, but the competition for a permanent seat is fierce. Stress is lower and knowledge builds steadily."},
	"job_10": {"name": "Real Estate Brokerage Assistant", "description": "Search listings, assist contracts, guide clients. The more ground you cover, the clearer the market becomes."},
	"job_11": {"name": "Startup Founder", "description": "A gamble to turn an idea into a product. No salary guarantee, but success has no ceiling. You live between investor meetings and code."},
	"job_12": {"name": "AI Automation Consultant", "description": "Sell AI solutions to companies. You need technical understanding and sales instinct. The market is hot, and so is the competition."},
	"job_13": {"name": "YouTube Creator", "description": "Content is the asset. Grow the channel and ads and sponsorships arrive. Riding trends is everything."},
	"job_14": {"name": "Insurance Salesperson", "description": "Start with acquaintances and expand outward. Network equals performance. Social skill rises, but relationships become products."},
	"job_15": {"name": "Global Company Sales", "description": "English meetings, global pressure, performance incentives. Commission matters more than base pay. Hit targets and Gangnam comes into view."},
}

const ASSET_TEXT_EN := {
	"samsung": {"name": "Hanseong Electronics", "tags": ["low volatility", "quarterly dividend", "Korean blue chip"], "description": "Hanseong Electronics asset. Volatility 8%, risk 2/5."},
	"kakao": {"name": "Daon", "tags": ["medium volatility", "no dividend", "domestic platform"], "description": "Daon asset. Volatility 13%, risk 3/5."},
	"hyundai": {"name": "Daehyeon Motor", "tags": ["medium volatility", "quarterly dividend", "export sensitive"], "description": "Daehyeon Motor asset. Volatility 10%, risk 3/5."},
	"kospi_etf": {"name": "KOSPI 200 ETF", "tags": ["low volatility", "diversified", "tracks KOSPI"], "description": "KOSPI 200 ETF asset. Volatility 6%, risk 2/5."},
	"sp500": {"name": "US Large-Cap ETF", "tags": ["low volatility", "USD asset", "US diversified"], "description": "US Large-Cap ETF asset. Volatility 7%, risk 2/5."},
	"nasdaq": {"name": "US Tech ETF", "tags": ["medium volatility", "USD asset", "tech concentrated"], "description": "US Tech ETF asset. Volatility 11%, risk 3/5."},
	"nvidia": {"name": "Encore", "tags": ["high volatility", "AI theme", "USD asset"], "description": "Encore asset. Volatility 20%, risk 4/5."},
	"ai_chip": {"name": "AI Semiconductor Theme", "tags": ["extreme volatility", "theme concentrated", "USD asset"], "description": "AI semiconductor theme asset. Volatility 24%, risk 5/5."},
	"bitcoin": {"name": "Corecoin", "tags": ["extreme volatility", "no dividend", "cycle sensitive"], "description": "Corecoin asset. Volatility 32%, risk 5/5."},
	"ethereum": {"name": "Novacoin", "tags": ["extreme volatility", "no dividend", "tech ecosystem"], "description": "Novacoin asset. Volatility 35%, risk 5/5."},
	"meme_coin": {"name": "Meme Coin", "tags": ["speculative", "no dividend", "social driven"], "description": "Meme coin asset. Volatility 90%, risk 5/5."},
	"reits": {"name": "REITs ETF", "tags": ["very low volatility", "monthly dividend", "indirect real estate"], "description": "REITs ETF asset. Volatility 4%, risk 2/5."},
	"gangnam_share": {"name": "Gangnam Apartment Fraction", "tags": ["very low volatility", "capital gain", "direct real estate"], "description": "Gangnam apartment fraction asset. Volatility 4%, risk 2/5."},
	"officetel": {"name": "Officetel Fractional Investment", "tags": ["low volatility", "rental income", "low liquidity"], "description": "Officetel fractional investment asset. Volatility 8%, risk 3/5."},
	"seed_startup": {"name": "Friend's Startup Seed", "tags": ["extreme volatility", "no dividend", "network dependent"], "description": "Friend's startup seed asset. Volatility 55%, risk 5/5."},
	"ai_startup": {"name": "AI Startup SAFE", "tags": ["extreme volatility", "no dividend", "long lock-up"], "description": "AI startup SAFE asset. Volatility 50%, risk 5/5."},
	"kospi_3x": {"name": "KOSPI 3x Leverage", "tags": ["extreme volatility", "amplified swings", "long-term danger"], "description": "KOSPI 3x leveraged asset. Volatility 28%, risk 5/5."},
	"nasdaq_3x": {"name": "US Tech 3x ETF", "tags": ["extreme volatility", "USD asset", "amplified swings"], "description": "US Tech 3x ETF asset. Volatility 34%, risk 5/5."},
}

const ITEM_TEXT_EN := {
	"artifact_sangchul_card": {"name": "Lim Sangchul's Business Card", "description": "He handed it over the first day you met.\nA private number was written on the back.\nOnly later did you understand what that meant."},
	"artifact_daeun_note": {"name": "Daeun's Post-it Note", "description": "She left it on the fridge before going out.\n'Eat properly.' Three words."},
	"artifact_father_call": {"name": "23-Second Call", "description": "Saved as a screenshot of the call log.\nExplaining why it was saved is difficult."},
	"artifact_jiyeon_text": {"name": "That Morning's Text", "description": "It was the first text she sent.\n'Am I kind of strange?'\nYou answered that she was not."},
	"artifact_jaehyuk_photo": {"name": "Pojangmacha Selfie", "description": "Taken together on the night you met again.\nWhatever happened after, that night he was truly an old friend."},
	"artifact_hyunsu_card": {"name": "Hyunsu's Business Card", "description": "After four years studying for exams.\nSuit. Card. 'It's thanks to you, hyung.'\nYou kept it."},
	"gift_can_coffee": {"name": "Canned Coffee Set", "description": "Inexpensive, gentle, and made for someone enduring another long night."},
	"gift_socks": {"name": "Sock Set", "description": "A practical gift that reveals more care precisely because it is practical."},
	"gift_essay_book": {"name": "Essay Collection", "description": "A book with plenty of room for underlining. The giver's time is part of the gift."},
	"gift_exhibit_catalog": {"name": "Exhibition Catalog", "description": "Something you can only choose if you remember which exhibitions they loved."},
	"gift_scarf": {"name": "Scarf", "description": "Something chosen while thinking of a person who spends too long out in the cold."},
	"gift_perfume": {"name": "Perfume", "description": "A gift whose price arrives first. The pressure may reach them before the feeling does."},
	"gift_wallet": {"name": "Designer Wallet", "description": "A good gift for almost anyone, which may be why it feels special to no one."},
	"gift_necklace": {"name": "Necklace", "description": "The most expensive answer, and the one that misses hardest when it is not the right answer."},
}

const ACHIEVEMENT_TEXT_EN := {
	"five_lives": {"name": "Five Lives", "description": "Completed five total runs. Seoul is not easy.", "hint": "Play 5 runs"},
	"first_billion": {"name": "First KRW 100M", "description": "Reached at least KRW 100M in assets during one run.", "hint": "Reach KRW 100M assets"},
	"gangnam_dream": {"name": "Gangnam Dream", "description": "Reached the Gangnam Dream ending. Dream or reality?", "hint": "Reach the Gangnam Dream ending"},
	"survived_burnout": {"name": "Burnout Survivor", "description": "Hit bottom and lived through a burnout or mental break ending.", "hint": "Burnout / mental break ending"},
	"startup_exit": {"name": "Successful Exit", "description": "Pulled off a startup exit. A massive contract before forty.", "hint": "Reach the startup exit ending"},
	"political_fix": {"name": "Power of Information", "description": "Profited from a political theme. The world belongs to those who know.", "hint": "Reach the political theme ending"},
	"stable_life": {"name": "Small Certain Happiness", "description": "Chose an ordinary but stable life. That takes courage too.", "hint": "Stable or ordinary life ending"},
	"investment_master": {"name": "Investment Master", "description": "Made investing the defining craft of five years. Learned to survive the market, not merely guess it.", "hint": "Reach the investment master ending"},
	"reputation_legend": {"name": "Beginning of a Legend", "description": "Your reputation became legendary. Your name is a brand.", "hint": "Reach the reputation legend ending"},
	"ten_lives": {"name": "Ten Lives", "description": "Lived ten lives. Gangnam no longer feels unfamiliar.", "hint": "Play 10 runs"},
	"beat_addiction": {"name": "Thirty Circles", "description": "Hit the bottom of gambling addiction and climbed back up. The strongest graduation.", "hint": "Complete the addiction recovery arc"},
	"four_seasons": {"name": "Four Seasons", "description": "Spent spring, summer, fall, and winter — all four — with one person.", "hint": "Some years are beautiful four times"},
	"kept_evidence": {"name": "What He Kept", "description": "At the moment of reckoning, drew out something he'd never thrown away — of his own will.", "hint": "Some things are kept for a decisive moment"},
	"drawer_truth": {"name": "The Truth in the Drawer", "description": "Some things only show after the credits end. She had known from the very beginning.", "hint": "Never say it, to the very end — and past the end"},
	"dawn_people": {"name": "Dawn People", "description": "Awake in her hours, five times. People awake at dawn recognize each other.", "hint": "Her time flows differently from everyone else's"},
}

const CLUE_TEXT_EN := {
	"clue_hanpd_name": {"title": "Han PD Construction", "text": "At the Gangnam network meeting, someone mentioned 'Han PD Construction.' Lim Sangchul changed the subject without moving a muscle. It is a name he wants to avoid."},
	"clue_father_broker": {"title": "The Lim Who Introduced the Debt", "text": "Behind Father's guarantee debt was an introducer. A real estate man in Gangnam, a 'Lim,' who vouched that Park Sangjin could be trusted."},
	"clue_sangchul_past": {"title": "Sangchul's Road Up", "text": "A dock worker's son from a coastal town in Chungcheong. Night college, then Gangnam. On the way from poverty to the top, he opened doors for some and stepped on others."},
}

const THOUGHT_TEXT_EN := {
	"thought_whole_picture": {
		"title": "The Whole Picture",
		"description": "The pieces keep gathering in the same place in your head. Han PD Construction. The introducer who ruined Father. Sangchul's road up.\n\nIf you sit with them long enough, they may become one picture.",
		"conclusion": "Three nights. You matched registry records, old articles, and memory.\n\nThe name that avoided Han PD Construction. The 'Lim' who introduced Park Sangjin to Father. The man who came up from Chungcheong by stepping over people.\n\nThey were one person. Lim Sangchul.\n\nNo one told Minjun. He built a person from fragments himself.\nThat made it heavier.",
	},
}

const NEWS_TOPICS_EN := {
	"korean_stocks": ["Hanseong Electronics", "Daehyeon Motor", "Daon", "KOSPI", "Korean blue chips", "battery stocks"],
	"us_stocks": ["Nasdaq", "S&P 500", "Encore", "Apple", "big tech", "growth stocks"],
	"real_estate": ["Gangnam", "Seoul apartments", "jeonse market", "new districts", "redevelopment zones"],
	"politics": ["tax policy", "financial regulation", "housing policy", "startup incentives", "crypto regulation"],
	"social_trends": ["young investors", "salary workers", "side hustlers", "online communities", "retail traders"],
	"ai_boom": ["AI chips", "data centers", "generative AI", "cloud infrastructure", "automation"],
	"startup_culture": ["AI startups", "fintech startups", "Series A companies", "venture capital", "founder exits"],
	"employment_crisis": ["job seekers", "IT hiring", "contract workers", "restructuring", "career switching"],
	"cryptocurrency": ["Corecoin", "Novacoin", "altcoins", "crypto exchanges", "DeFi tokens"],
	"market": ["markets", "risk assets", "investors", "asset prices", "the economy"],
}

const NEWS_HEADLINES_EN := {
	"greed": [
		"{topic} surges as retail money rushes back in",
		"{topic} draws fresh institutional buying amid recovery hopes",
		"Analysts raise targets for {topic} as momentum builds",
	],
	"fear": [
		"{topic} sells off sharply as risk warnings spread",
		"Regulatory pressure weighs on {topic}; investors turn cautious",
		"{topic} hit by bad headlines as fear returns to the market",
	],
	"panic": [
		"{topic} plunges in a broad panic; liquidity dries up",
		"Emergency warnings spread around {topic} after sudden crash",
		"{topic} faces forced selling as confidence collapses",
	],
	"euphoria": [
		"{topic} mania returns as traders call it a new cycle",
		"{topic} hits fresh highs; FOMO spreads across forums",
		"Speculation explodes around {topic} after another record move",
	],
	"neutral": [
		"{topic} remains mixed as investors wait for clearer signals",
		"Debate grows over whether {topic} is opportunity or bubble",
		"Market watches {topic} while volatility stays elevated",
	],
}

var events: Array = []
var events_by_id: Dictionary = {}
var assets: Array = []
var assets_by_id: Dictionary = {}
var jobs: Array = []
var jobs_by_id: Dictionary = {}
var items: Array = []
var items_by_id: Dictionary = {}
var endings: Array = []
var endings_by_id: Dictionary = {}
var news_templates: Array = []
var default_meta: Dictionary = {}
var achievements: Array = []
var achievements_by_id: Dictionary = {}
var clues: Array = []
var clues_by_id: Dictionary = {}
var thoughts: Array = []
var thoughts_by_id: Dictionary = {}
var story_rules: Dictionary = {}
var story_rules_by_event: Dictionary = {}
var scene_direction_manifest: Dictionary = {}
var scene_direction_event_intents_by_id: Dictionary = {}

## 한 선택지의 지연 예약을 저장 포맷과 같은 {event_id, delay} 목록으로 정규화한다.
## 기존 문자열과 문자열/객체 혼합 배열을 함께 받으며 빈 id는 예약하지 않는다.
func deferred_follow_ups(owner: Dictionary) -> Array:
	var raw: Variant = owner.get("deferred_follow_up", "")
	var default_delay: int = int(owner.get("deferred_delay", 6))
	var values: Array = raw if raw is Array else [raw]
	var result: Array = []
	for value in values:
		var event_id := ""
		var delay := default_delay
		if value is String:
			event_id = str(value).strip_edges()
		elif value is Dictionary:
			event_id = str((value as Dictionary).get("id", "")).strip_edges()
			delay = int((value as Dictionary).get("delay", default_delay))
		if not event_id.is_empty():
			result.append({"event_id": event_id, "delay": delay})
	return result

func deferred_follow_up_shape_is_valid(owner: Dictionary) -> bool:
	var raw: Variant = owner.get("deferred_follow_up", "")
	if owner.has("deferred_delay") and typeof(owner["deferred_delay"]) != TYPE_INT:
		return false
	if raw is String:
		return true
	if not raw is Array:
		return false
	for value in raw:
		if value is String:
			continue
		if not value is Dictionary:
			return false
		var entry: Dictionary = value
		if not entry.keys().all(func(key): return str(key) in ["id", "delay"]):
			return false
		if not entry.get("id", "") is String:
			return false
		if entry.has("delay") and typeof(entry["delay"]) != TYPE_INT:
			return false
	return true

func _ready():
	reload()

func reload():
	var lang := LocaleManager.language
	var target_catalog := _load_locale_catalog(lang)
	events.clear()
	events_by_id.clear()
	for path in EVENT_PATHS:
		for event in _load_array(path):
			events.append(event)
			events_by_id[event.get("id", "")] = event

	# 비한국어는 완성된 EN을 안전망으로 먼저 적용한다. 준비 언어 오버레이가
	# 비어 있거나 일부만 번역돼도 한국어 본문이 화면에 새지 않는다.
	if lang != "ko":
		_apply_event_overlay("en")
		if lang != "en":
			_apply_event_overlay(lang)
	# Data mods are applied after localization so an explicit story rewrite is
	# never silently replaced by the built-in language overlay.
	_apply_event_mods()

	assets = _load_array(ASSETS_PATH)
	if lang != "ko":
		_apply_catalog_en_overlay(assets, ASSET_TEXT_EN)
		_apply_catalog_locale_overlay(assets, target_catalog, "assets")
	_apply_catalog_presets(assets, "assets")
	assets_by_id = _index_by_id(assets)
	jobs = _load_array(JOBS_PATH)
	if lang != "ko":
		_apply_catalog_en_overlay(jobs, JOB_TEXT_EN)
		_apply_catalog_locale_overlay(jobs, target_catalog, "jobs")
	_apply_catalog_presets(jobs, "jobs")
	jobs_by_id = _index_by_id(jobs)
	items = _load_array(ITEMS_PATH)
	if lang != "ko":
		_apply_catalog_en_overlay(items, ITEM_TEXT_EN)
		_apply_catalog_locale_overlay(items, target_catalog, "items")
	_apply_catalog_presets(items, "items")
	items_by_id = _index_by_id(items)
	endings = _load_array(ENDINGS_PATH)
	endings_by_id = _index_by_id(endings)
	if lang != "ko":
		_apply_endings_overlay("en")
		if lang != "en":
			_apply_endings_overlay(lang)
	news_templates = _load_array(NEWS_PATH)
	if lang != "ko":
		_apply_news_en_overlay()
		_apply_catalog_locale_overlay(news_templates, target_catalog, "news")
	_apply_catalog_presets(news_templates, "news_templates")
	default_meta = _load_dict(META_PATH)
	achievements = _load_array(ACHIEVEMENTS_PATH)
	if lang != "ko":
		_apply_catalog_en_overlay(achievements, ACHIEVEMENT_TEXT_EN)
		_apply_catalog_locale_overlay(achievements, target_catalog, "achievements")
	achievements_by_id = _index_by_id(achievements)
	clues = _load_array(CLUES_PATH)
	if lang != "ko":
		_apply_catalog_en_overlay(clues, CLUE_TEXT_EN)
		_apply_catalog_locale_overlay(clues, target_catalog, "clues")
	clues_by_id = _index_by_id(clues)
	thoughts = _load_array(THOUGHTS_PATH)
	if lang != "ko":
		_apply_catalog_en_overlay(thoughts, THOUGHT_TEXT_EN)
		_apply_catalog_locale_overlay(thoughts, target_catalog, "thoughts")
	thoughts_by_id = _index_by_id(thoughts)
	story_rules = _load_dict(STORY_RULES_PATH)
	var raw_event_rules: Variant = story_rules.get("events", {})
	story_rules_by_event = raw_event_rules if raw_event_rules is Dictionary else {}
	scene_direction_manifest = _load_dict(SCENE_DIRECTION_MANIFEST_PATH)
	scene_direction_event_intents_by_id.clear()
	var raw_intents: Variant = scene_direction_manifest.get("event_intents", {})
	if raw_intents is Dictionary:
		for intent_variant in raw_intents:
			var intent := str(intent_variant)
			var event_ids: Variant = (raw_intents as Dictionary).get(intent_variant, [])
			if not event_ids is Array:
				continue
			for event_id_variant in event_ids:
				scene_direction_event_intents_by_id[str(event_id_variant)] = intent

func find_event(event_id):
	return events_by_id.get(event_id, {})

func find_story_rule(event_id: String) -> Dictionary:
	var rule: Variant = story_rules_by_event.get(event_id, {})
	return rule if rule is Dictionary else {}

func story_prerequisites_met(event_id: String, context: Dictionary) -> bool:
	var logic: Variant = find_story_rule(event_id).get("logic", {})
	if not logic is Dictionary:
		return true
	var prerequisites: Variant = (logic as Dictionary).get("prerequisites", {})
	if not prerequisites is Dictionary or (prerequisites as Dictionary).is_empty():
		return true
	var all_clauses: Variant = (prerequisites as Dictionary).get("all", [])
	if all_clauses is Array:
		for clause in all_clauses:
			if not clause is Dictionary or not _story_clause_met(clause, context):
				return false
	var any_clauses: Variant = (prerequisites as Dictionary).get("any", [])
	if any_clauses is Array and not (any_clauses as Array).is_empty():
		for clause in any_clauses:
			if clause is Dictionary and _story_clause_met(clause, context):
				return true
		return false
	return true

func _story_clause_met(clause: Dictionary, context: Dictionary) -> bool:
	var actual: Variant = _story_context_value(context, str(clause.get("path", "")))
	var expected: Variant = clause.get("value")
	match str(clause.get("op", "eq")):
		"eq":
			return actual == expected
		"neq":
			return actual != expected
		"in":
			return expected is Array and (expected as Array).has(actual)
		"not_in":
			return expected is Array and not (expected as Array).has(actual)
		"gte":
			return (actual is int or actual is float) \
					and (expected is int or expected is float) \
					and float(actual) >= float(expected)
		"lte":
			return (actual is int or actual is float) \
					and (expected is int or expected is float) \
					and float(actual) <= float(expected)
		"truthy":
			return bool(actual)
		"falsy":
			return not bool(actual)
	return false

func _story_context_value(context: Dictionary, path: String) -> Variant:
	if path.is_empty():
		return null
	var value: Variant = context
	for segment in path.split("."):
		if not value is Dictionary:
			return null
		value = (value as Dictionary).get(segment)
	return value

func get_story_presentation(event_id: String) -> Dictionary:
	var presentation: Variant = find_story_rule(event_id).get("presentation", {})
	return presentation if presentation is Dictionary else {}

func get_story_transition(from_event_id: String, to_event_id: String) -> Dictionary:
	var contracts: Variant = scene_direction_manifest.get("transition_edges", {})
	if contracts is Dictionary:
		var contract: Variant = (contracts as Dictionary).get(
			"%s->%s" % [from_event_id, to_event_id], {})
		if contract is Dictionary and not (contract as Dictionary).is_empty():
			return (contract as Dictionary).duplicate(true)
	# Unknown/modded edges must never inherit a decorative wipe. Shipping data
	# is required to be exhaustive by scene_direction_catalog.py.
	return {
		"mode": "none",
		"audio_policy": "continue",
		"reduced_motion": "static_update",
		"unclassified": true,
	}

func get_scene_direction_event_intent(event_id: String) -> String:
	return str(scene_direction_event_intents_by_id.get(event_id, "none"))

func get_scene_direction_background_profile(background_id: String) -> Dictionary:
	var profiles: Variant = scene_direction_manifest.get("background_profiles", {})
	if not profiles is Dictionary:
		return {}
	var profile: Variant = (profiles as Dictionary).get(background_id, {})
	return (profile as Dictionary).duplicate(true) if profile is Dictionary else {}

func get_scene_direction_activity_contract(activity_id: String) -> Dictionary:
	var contracts: Variant = scene_direction_manifest.get("activity_contracts", {})
	if not contracts is Dictionary:
		return {}
	var contract: Variant = (contracts as Dictionary).get(activity_id, {})
	return (contract as Dictionary).duplicate(true) if contract is Dictionary else {}

func get_scene_direction_ending_contract(ending_id: String) -> Dictionary:
	var contracts: Variant = scene_direction_manifest.get("ending_contracts", {})
	if not contracts is Dictionary:
		return {}
	var contract: Variant = (contracts as Dictionary).get(ending_id, {})
	return (contract as Dictionary).duplicate(true) if contract is Dictionary else {}

func get_all_events():
	return events

func get_events(category):
	if category.is_empty():
		return events
	var filtered: Array = []
	for event in events:
		if event.get("category", "") == category:
			filtered.append(event)
	return filtered

func _apply_event_mods() -> void:
	for path in ModLoader.enabled_event_pack_paths():
		var parsed: Variant = _parse_json(path)
		var raw_events: Variant = parsed.get("events", []) if parsed is Dictionary else parsed
		if not raw_events is Array:
			push_warning("Skipping event mod without an events array: %s" % path)
			continue
		var pack_ids: Dictionary = {}
		for raw_event in raw_events:
			if raw_event is Dictionary:
				pack_ids[str((raw_event as Dictionary).get("id", ""))] = true
		for raw_event in raw_events:
			if not raw_event is Dictionary:
				push_warning("Skipping non-object event in mod: %s" % path)
				continue
			var source := raw_event as Dictionary
			var event_id := str(source.get("id", ""))
			if event_id.is_empty() or not _is_safe_mod_event_id(event_id):
				push_warning("Skipping event mod with unsafe id '%s': %s" % [event_id, path])
				continue
			if events_by_id.has(event_id):
				if not bool(source.get("override", false)):
					push_warning("Built-in event id wins; add override=true to rewrite it: %s" % event_id)
					continue
				var base: Dictionary = events_by_id[event_id]
				var merged := _merge_mod_event_override(base, source, path)
				if merged.is_empty():
					continue
				var index := events.find(base)
				if index >= 0:
					events[index] = merged
				events_by_id[event_id] = merged
				continue
			var clean := _sanitize_new_mod_event(source, pack_ids, path)
			if clean.is_empty():
				continue
			events.append(clean)
			events_by_id[event_id] = clean

func _sanitize_new_mod_event(source: Dictionary, pack_ids: Dictionary, path: String) -> Dictionary:
	if not _mod_event_root_keys_valid(source, path):
		return {}
	if str(source.get("title", "")).strip_edges().is_empty() \
			or str(source.get("description", "")).strip_edges().is_empty():
		push_warning("Skipping event mod with empty title/description: %s" % path)
		return {}
	if str(source.get("category", "")) == "story" \
			or str(source.get("rarity", "common")) == "story" \
			or float(source.get("weight", 1.0)) <= 0.0 \
			or bool(source.get("hidden", false)):
		push_warning("Skipping non-random event mod '%s'; custom events must join the random pool" % source.get("id", ""))
		return {}
	if not source.get("conditions", {}) is Dictionary or not source.get("tags", []) is Array:
		push_warning("Skipping event mod with invalid conditions/tags: %s" % source.get("id", ""))
		return {}
	var raw_choices: Variant = source.get("choices", [])
	if not raw_choices is Array or (raw_choices as Array).is_empty():
		push_warning("Skipping event mod without choices: %s" % source.get("id", ""))
		return {}
	var clean_choices: Array = []
	for raw_choice in raw_choices:
		if not raw_choice is Dictionary:
			push_warning("Skipping event mod with a non-object choice: %s" % source.get("id", ""))
			return {}
		var choice := (raw_choice as Dictionary).duplicate(true)
		if not _mod_choice_valid(choice, {}, pack_ids, path):
			return {}
		clean_choices.append(choice)
	var clean := source.duplicate(true)
	clean.erase("override")
	clean["hidden"] = false
	clean["rarity"] = str(clean.get("rarity", "common"))
	clean["weight"] = maxf(0.01, float(clean.get("weight", 1.0)))
	clean["cooldown"] = maxi(3, int(clean.get("cooldown", 3)))
	var tags: Array = clean.get("tags", []).duplicate()
	if not tags.has("modded"):
		tags.append("modded")
	clean["tags"] = tags
	clean["choices"] = clean_choices
	return clean

func _merge_mod_event_override(
		base: Dictionary,
		source: Dictionary,
		path: String) -> Dictionary:
	if not _mod_event_root_keys_valid(source, path):
		return {}
	var base_choices: Variant = base.get("choices", [])
	var source_choices: Variant = source.get("choices", [])
	if not base_choices is Array or not source_choices is Array \
			or (base_choices as Array).size() != (source_choices as Array).size():
		push_warning("Skipping event override with changed choice count: %s" % base.get("id", ""))
		return {}
	var merged := base.duplicate(true)
	for key in source.keys():
		var key_name := str(key)
		if key_name == "override" or key_name == "choices" or key_name in MOD_EVENT_SCHEDULE_KEYS:
			continue
		merged[key_name] = source[key]
	var merged_choices: Array = []
	for index in range((source_choices as Array).size()):
		var base_choice: Dictionary = (base_choices as Array)[index]
		if not (source_choices as Array)[index] is Dictionary:
			push_warning("Skipping event override with a non-object choice: %s" % base.get("id", ""))
			return {}
		var choice := ((source_choices as Array)[index] as Dictionary).duplicate(true)
		var allowed_core := _choice_produced_flags(base_choice)
		if not _mod_choice_valid(choice, allowed_core, {}, path):
			return {}
		for schedule_key in MOD_CHOICE_SCHEDULE_KEYS:
			if base_choice.has(schedule_key):
				choice[schedule_key] = base_choice[schedule_key]
			else:
				choice.erase(schedule_key)
		choice["flags"] = _merged_choice_flags(base_choice, choice)
		_preserve_nested_choice_flags(base_choice, choice)
		merged_choices.append(choice)
	merged["choices"] = merged_choices
	return merged

func _mod_event_root_keys_valid(source: Dictionary, path: String) -> bool:
	for key in source.keys():
		if not str(key) in MOD_EVENT_ROOT_KEYS:
			push_warning("Skipping event mod with unsupported root key '%s': %s" % [key, path])
			return false
	return true

func _mod_choice_valid(
		choice: Dictionary,
		allowed_core_flags: Dictionary,
		pack_ids: Dictionary,
		path: String) -> bool:
	for key in choice.keys():
		if not str(key) in MOD_CHOICE_KEYS:
			push_warning("Skipping event mod with unsupported choice key '%s': %s" % [key, path])
			return false
	if str(choice.get("text", "")).strip_edges().is_empty() \
			or str(choice.get("result_text", "")).strip_edges().is_empty():
		push_warning("Skipping event mod with empty choice text/result: %s" % path)
		return false
	for flag in _choice_produced_flags(choice).keys():
		if not str(flag).begins_with("mod_") and not allowed_core_flags.has(flag):
			push_warning("Skipping event mod with unnamespaced flag '%s': %s" % [flag, path])
			return false
	var immediate_target := str(choice.get("follow_up_event", ""))
	if not immediate_target.is_empty() and not pack_ids.is_empty() \
			and not pack_ids.has(immediate_target):
		push_warning("Skipping event mod with cross-pack follow-up '%s': %s" \
			% [immediate_target, path])
		return false
	if not deferred_follow_up_shape_is_valid(choice):
		push_warning("Skipping event mod with malformed deferred follow-up: %s" % path)
		return false
	for entry_value in deferred_follow_ups(choice):
		var target := str((entry_value as Dictionary).get("event_id", ""))
		if not pack_ids.is_empty() and not pack_ids.has(target):
			push_warning("Skipping event mod with cross-pack follow-up '%s': %s" % [target, path])
			return false
	return true

func _choice_produced_flags(choice: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for flag in choice.get("flags", []):
		if not str(flag).is_empty():
			result[str(flag)] = true
	var opportunity: Variant = choice.get("opportunity", {})
	if opportunity is Dictionary:
		for key in ["win_flag", "lose_flag"]:
			var flag := str((opportunity as Dictionary).get(key, ""))
			if not flag.is_empty():
				result[flag] = true
	var cast_effects: Variant = choice.get("cast_effects", {})
	if cast_effects is Dictionary:
		for cast_value in (cast_effects as Dictionary).values():
			if cast_value is Dictionary:
				for flag in (cast_value as Dictionary).get("flags", []):
					if not str(flag).is_empty():
						result[str(flag)] = true
	return result

func _merged_choice_flags(base_choice: Dictionary, mod_choice: Dictionary) -> Array:
	var result: Array = []
	for flag in base_choice.get("flags", []):
		if not result.has(flag):
			result.append(flag)
	for flag in mod_choice.get("flags", []):
		if str(flag).begins_with("mod_") and not result.has(flag):
			result.append(flag)
	return result

func _preserve_nested_choice_flags(base_choice: Dictionary, mod_choice: Dictionary) -> void:
	var base_opportunity: Variant = base_choice.get("opportunity", {})
	if base_opportunity is Dictionary:
		var opportunity: Dictionary = mod_choice.get("opportunity", {}).duplicate(true) \
				if mod_choice.get("opportunity", {}) is Dictionary else {}
		for key in ["win_flag", "lose_flag"]:
			if (base_opportunity as Dictionary).has(key):
				opportunity[key] = (base_opportunity as Dictionary)[key]
		if not opportunity.is_empty():
			mod_choice["opportunity"] = opportunity
	var base_cast: Variant = base_choice.get("cast_effects", {})
	if not base_cast is Dictionary:
		return
	var mod_cast: Dictionary = mod_choice.get("cast_effects", {}).duplicate(true) \
			if mod_choice.get("cast_effects", {}) is Dictionary else {}
	for cast_id in (base_cast as Dictionary).keys():
		var base_row: Variant = (base_cast as Dictionary)[cast_id]
		if not base_row is Dictionary or not (base_row as Dictionary).has("flags"):
			continue
		var mod_row: Dictionary = mod_cast.get(cast_id, {}).duplicate(true) \
				if mod_cast.get(cast_id, {}) is Dictionary else {}
		var flags: Array = (base_row as Dictionary).get("flags", []).duplicate()
		for flag in mod_row.get("flags", []):
			if str(flag).begins_with("mod_") and not flags.has(flag):
				flags.append(flag)
		mod_row["flags"] = flags
		mod_cast[cast_id] = mod_row
	if not mod_cast.is_empty():
		mod_choice["cast_effects"] = mod_cast

func _is_safe_mod_event_id(event_id: String) -> bool:
	if event_id.is_empty() or event_id.length() > 96:
		return false
	for i in range(event_id.length()):
		var cp := event_id.unicode_at(i)
		if not ((cp >= 97 and cp <= 122) or (cp >= 48 and cp <= 57) or cp == 95):
			return false
	return true

func _apply_catalog_presets(rows: Array, section: String) -> void:
	var index: Dictionary = _index_by_id(rows)
	for path in ModLoader.enabled_preset_paths():
		var parsed: Variant = _parse_json(path)
		if not parsed is Dictionary:
			push_warning("Skipping non-object balance preset: %s" % path)
			continue
		var patches: Variant = (parsed as Dictionary).get(section, [])
		if not patches is Array:
			push_warning("Skipping invalid preset section '%s': %s" % [section, path])
			continue
		for raw_patch in patches:
			if not raw_patch is Dictionary:
				continue
			var patch := raw_patch as Dictionary
			var row_id := str(patch.get("id", ""))
			if row_id.is_empty() or not index.has(row_id):
				push_warning("Preset cannot add unknown %s id '%s': %s" % [section, row_id, path])
				continue
			var base: Dictionary = index[row_id]
			var merged := _merge_existing_catalog_row(base, patch, path)
			var row_index := rows.find(base)
			if row_index >= 0:
				rows[row_index] = merged
			index[row_id] = merged

func _merge_existing_catalog_row(base: Dictionary, patch: Dictionary, path: String) -> Dictionary:
	var merged := base.duplicate(true)
	for key in patch.keys():
		var key_name := str(key)
		if key_name == "id":
			continue
		if not base.has(key_name):
			push_warning("Ignoring unknown preset field '%s' for %s in %s" % [key_name, base.get("id", ""), path])
			continue
		if patch[key] is Dictionary and base[key_name] is Dictionary:
			merged[key_name] = _merge_existing_catalog_dictionary(
				base[key_name] as Dictionary,
				patch[key] as Dictionary,
				path,
				"%s.%s" % [base.get("id", ""), key_name])
		elif not _catalog_values_compatible(base[key_name], patch[key]):
			push_warning("Ignoring preset type mismatch for '%s.%s' in %s" % [base.get("id", ""), key_name, path])
		else:
			merged[key_name] = patch[key]
	return merged

func _merge_existing_catalog_dictionary(
		base: Dictionary,
		patch: Dictionary,
		path: String,
		field_path: String) -> Dictionary:
	var merged := base.duplicate(true)
	for key in patch.keys():
		var key_name := str(key)
		if not base.has(key_name):
			push_warning("Ignoring unknown preset field '%s.%s' in %s" % [field_path, key_name, path])
			continue
		if patch[key] is Dictionary and base[key_name] is Dictionary:
			merged[key_name] = _merge_existing_catalog_dictionary(
				base[key_name] as Dictionary,
				patch[key] as Dictionary,
				path,
				"%s.%s" % [field_path, key_name])
		elif not _catalog_values_compatible(base[key_name], patch[key]):
			push_warning("Ignoring preset type mismatch for '%s.%s' in %s" % [field_path, key_name, path])
		else:
			merged[key_name] = patch[key]
	return merged

func _catalog_values_compatible(base_value: Variant, patch_value: Variant) -> bool:
	var base_type := typeof(base_value)
	var patch_type := typeof(patch_value)
	if base_type in [TYPE_INT, TYPE_FLOAT] and patch_type in [TYPE_INT, TYPE_FLOAT]:
		return true
	if base_type != patch_type:
		return false
	if base_type != TYPE_ARRAY:
		return true
	var base_array := base_value as Array
	var patch_array := patch_value as Array
	if patch_array.is_empty():
		return true
	if base_array.is_empty():
		return false
	for value in patch_array:
		if not _catalog_values_compatible(base_array[0], value):
			return false
	return true

func _apply_event_overlay(lang: String) -> void:
	_apply_event_overlay_dir(EVENT_LOCALE_DIR % lang, false)
	var community_dir := ModLoader.language_events_dir(lang)
	if not community_dir.is_empty():
		_apply_event_overlay_dir(community_dir, true)

func _apply_event_overlay_dir(overlay_dir: String, external: bool) -> void:
	var directory_path := ProjectSettings.globalize_path(overlay_dir) if overlay_dir.begins_with("user://") else overlay_dir
	var da := DirAccess.open(directory_path)
	if not da:
		return
	da.list_dir_begin()
	var fname := da.get_next()
	while fname != "":
		if fname.ends_with(".json"):
			for raw_event in _load_array(overlay_dir.path_join(fname)):
				var ev: Dictionary = _sanitize_external_event_overlay(raw_event) if external else raw_event
				var eid: String = str(ev.get("id", ""))
				if eid == "":
					continue
				if events_by_id.has(eid):
					var old = events_by_id[eid]
					var merged := _merge_event_overlay(old, ev)
					var idx = events.find(old)
					if idx >= 0:
						events[idx] = merged
					events_by_id[eid] = merged
		fname = da.get_next()

func _merge_event_overlay(base_event: Dictionary, overlay_event: Dictionary) -> Dictionary:
	var merged: Dictionary = base_event.duplicate(true)
	for key in overlay_event.keys():
		if str(key) == "choices" and base_event.get("choices", []) is Array and overlay_event.get("choices", []) is Array:
			merged["choices"] = _merge_choice_overlay(base_event.get("choices", []), overlay_event.get("choices", []))
		elif overlay_event[key] is Dictionary and base_event.get(key, {}) is Dictionary:
			var nested: Dictionary = (base_event.get(key, {}) as Dictionary).duplicate(true)
			for nested_key in (overlay_event[key] as Dictionary).keys():
				nested[nested_key] = (overlay_event[key] as Dictionary)[nested_key]
			merged[key] = nested
		else:
			merged[key] = overlay_event[key]
	return merged

func _apply_endings_overlay(lang: String) -> void:
	var path := ENDINGS_EN_PATH if lang == "en" else ENDINGS_LOCALE_PATH % lang
	_apply_endings_overlay_path(path, false)
	var community_path := ModLoader.language_endings_path(lang)
	if not community_path.is_empty():
		_apply_endings_overlay_path(community_path, true)

func _apply_endings_overlay_path(path: String, external: bool) -> void:
	if not FileAccess.file_exists(path):
		return
	for raw_ending in _load_array(path):
		var ev: Dictionary = _sanitize_external_ending_overlay(raw_ending) if external else raw_ending
		var eid: String = str(ev.get("id", ""))
		if eid == "" or not endings_by_id.has(eid):
			continue
		var merged: Dictionary = (endings_by_id[eid] as Dictionary).duplicate(true)
		for key in ev.keys():
			if ev[key] is Dictionary and merged.get(key, {}) is Dictionary:
				var nested: Dictionary = (merged.get(key, {}) as Dictionary).duplicate(true)
				for nested_key in (ev[key] as Dictionary).keys():
					nested[nested_key] = (ev[key] as Dictionary)[nested_key]
				merged[key] = nested
			else:
				merged[key] = ev[key]
		if _contains_hangul(str(merged.get("condition", ""))):
			merged["condition"] = "Discover this ending through play."
		var idx = endings.find(endings_by_id[eid])
		if idx >= 0:
			endings[idx] = merged
		endings_by_id[eid] = merged

func _sanitize_external_event_overlay(raw_event: Variant) -> Dictionary:
	if not raw_event is Dictionary:
		return {}
	var source := raw_event as Dictionary
	var result: Dictionary = {"id": str(source.get("id", ""))}
	for key in EXTERNAL_EVENT_TEXT_FIELDS:
		if source.get(key) is String:
			result[key] = str(source[key])
	for key in EXTERNAL_EVENT_DICT_FIELDS:
		var clean: Dictionary = _text_dictionary(source.get(key))
		if not clean.is_empty():
			result[key] = clean
	var raw_choices: Variant = source.get("choices", [])
	if raw_choices is Array:
		var choices: Array = []
		for raw_choice in raw_choices:
			var choice: Dictionary = {}
			if raw_choice is Dictionary:
				for key in EXTERNAL_CHOICE_TEXT_FIELDS:
					if (raw_choice as Dictionary).get(key) is String:
						choice[key] = str((raw_choice as Dictionary)[key])
				for key in EXTERNAL_CHOICE_DICT_FIELDS:
					var clean: Dictionary = _text_dictionary((raw_choice as Dictionary).get(key))
					if not clean.is_empty():
						choice[key] = clean
			choices.append(choice)
		result["choices"] = choices
	return result

func _sanitize_external_ending_overlay(raw_ending: Variant) -> Dictionary:
	if not raw_ending is Dictionary:
		return {}
	var source := raw_ending as Dictionary
	var result: Dictionary = {"id": str(source.get("id", ""))}
	for key in EXTERNAL_ENDING_TEXT_FIELDS:
		if source.get(key) is String:
			result[key] = str(source[key])
	for key in EXTERNAL_ENDING_DICT_FIELDS:
		var clean: Dictionary = _text_dictionary(source.get(key))
		if not clean.is_empty():
			result[key] = clean
	return result

func _text_dictionary(raw_value: Variant) -> Dictionary:
	var result: Dictionary = {}
	if not raw_value is Dictionary:
		return result
	for key in (raw_value as Dictionary).keys():
		var value: Variant = (raw_value as Dictionary)[key]
		if key is String and value is String:
			result[str(key)] = str(value)
	return result

func _load_locale_catalog(lang: String) -> Dictionary:
	if lang in ["ko", "en"]:
		return {}
	var path := CATALOG_LOCALE_PATH % lang
	if not FileAccess.file_exists(path):
		return {}
	return _load_dict(path)

func _apply_catalog_locale_overlay(rows: Array, catalog: Dictionary, section: String) -> void:
	var overlay = catalog.get(section, {})
	if overlay is Dictionary and not overlay.is_empty():
		_apply_catalog_en_overlay(rows, overlay)

func _apply_catalog_en_overlay(rows: Array, overlay: Dictionary) -> void:
	for i in range(rows.size()):
		if not rows[i] is Dictionary:
			continue
		var row: Dictionary = (rows[i] as Dictionary).duplicate(true)
		var row_id := str(row.get("id", ""))
		if not overlay.has(row_id):
			rows[i] = row
			continue
		var data: Dictionary = overlay[row_id]
		for key in data:
			row[key] = data[key]
		rows[i] = row

func _apply_news_en_overlay() -> void:
	for i in range(news_templates.size()):
		if not news_templates[i] is Dictionary:
			continue
		var row: Dictionary = (news_templates[i] as Dictionary).duplicate(true)
		var category := str(row.get("category", "market"))
		var sentiment := str(row.get("sentiment", "neutral"))
		var topics: Array = NEWS_TOPICS_EN.get(category, NEWS_TOPICS_EN["market"])
		var templates: Array = NEWS_HEADLINES_EN.get(sentiment, NEWS_HEADLINES_EN["neutral"])
		row["topics"] = topics.duplicate(true)
		row["headline"] = str(templates[i % templates.size()])
		news_templates[i] = row

func _contains_hangul(text: String) -> bool:
	for i in range(text.length()):
		var cp := text.unicode_at(i)
		if (cp >= 0xAC00 and cp <= 0xD7A3) or (cp >= 0x1100 and cp <= 0x11FF) or (cp >= 0x3130 and cp <= 0x318F):
			return true
	return false

func _merge_choice_overlay(base_choices: Array, overlay_choices: Array) -> Array:
	var merged_choices: Array = []
	var max_count := maxi(base_choices.size(), overlay_choices.size())
	for i in range(max_count):
		var base_choice: Dictionary = {}
		if i < base_choices.size() and base_choices[i] is Dictionary:
			base_choice = (base_choices[i] as Dictionary).duplicate(true)
		var overlay_choice: Dictionary = {}
		if i < overlay_choices.size() and overlay_choices[i] is Dictionary:
			overlay_choice = overlay_choices[i] as Dictionary
		for key in overlay_choice.keys():
			base_choice[key] = overlay_choice[key]
		merged_choices.append(base_choice)
	return merged_choices

func get_assets_by_category(category):
	var filtered: Array = []
	for asset in assets:
		if asset.get("category", "") == category:
			filtered.append(asset)
	return filtered

func get_asset(asset_id):
	return assets_by_id.get(asset_id, {})

func get_job(job_id):
	return jobs_by_id.get(job_id, {})

func get_item(item_id):
	return items_by_id.get(item_id, {})

func get_achievement(achievement_id):
	return achievements_by_id.get(achievement_id, {})

func get_ending(ending_id):
	return endings_by_id.get(ending_id, {})

func get_clue(clue_id):
	return clues_by_id.get(clue_id, {})

func get_thought(thought_id):
	return thoughts_by_id.get(thought_id, {})

func _index_by_id(rows):
	var indexed: Dictionary = {}
	for row in rows:
		indexed[row.get("id", "")] = row
	return indexed

func _load_array(path):
	var parsed = _parse_json(path)
	if parsed is Array:
		return parsed
	if parsed is Dictionary and parsed.has("items"):
		return parsed["items"]
	push_warning("Expected JSON array at %s" % path)
	return []

func _load_dict(path):
	var parsed = _parse_json(path)
	if parsed is Dictionary:
		return parsed
	push_warning("Expected JSON object at %s" % path)
	return {}

func _parse_json(path):
	if not FileAccess.file_exists(path):
		push_warning("Missing content file: %s" % path)
		return null
	var text = FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	if parsed == null:
		push_warning("Invalid JSON file: %s" % path)
	return parsed
