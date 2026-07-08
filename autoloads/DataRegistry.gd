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
	"res://content/events/arc_new_characters.json",
	"res://content/events/arc_daeun_extension.json",
	"res://content/events/arc_year3_drama.json",
	"res://content/events/arc_year_close.json",
	"res://content/events/arc_romance_y5.json",
	"res://content/events/arc_h2_beats.json",
	"res://content/events/arc_date_milestones.json",
	"res://content/events/arc_season_dates.json",
]
const ASSETS_PATH = "res://content/assets.json"
const JOBS_PATH = "res://content/jobs.json"
const ITEMS_PATH = "res://content/items.json"
const ENDINGS_PATH = "res://content/endings.json"
const ENDINGS_EN_PATH = "res://content/endings_en.json"
const NEWS_PATH = "res://content/news_templates.json"
const META_PATH = "res://content/meta/default_meta.json"
const ACHIEVEMENTS_PATH = "res://content/meta/achievements.json"
const CLUES_PATH = "res://content/meta/clues.json"
const THOUGHTS_PATH = "res://content/meta/thoughts.json"

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
}

const ACHIEVEMENT_TEXT_EN := {
	"five_lives": {"name": "Five Lives", "description": "Completed five total runs. Seoul is not easy.", "hint": "Play 5 runs"},
	"first_billion": {"name": "First KRW 100M", "description": "Reached at least KRW 100M in assets during one run.", "hint": "Reach KRW 100M assets"},
	"gangnam_dream": {"name": "Gangnam Dream", "description": "Reached the Gangnam Dream ending. Dream or reality?", "hint": "Reach the Gangnam Dream ending"},
	"survived_burnout": {"name": "Burnout Survivor", "description": "Hit bottom and lived through a burnout or mental break ending.", "hint": "Burnout / mental break ending"},
	"startup_exit": {"name": "Successful Exit", "description": "Pulled off a startup exit. A massive contract before forty.", "hint": "Reach the startup exit ending"},
	"political_fix": {"name": "Power of Information", "description": "Profited from a political theme. The world belongs to those who know.", "hint": "Reach the political theme ending"},
	"stable_life": {"name": "Small Certain Happiness", "description": "Chose an ordinary but stable life. That takes courage too.", "hint": "Stable or ordinary life ending"},
	"investment_master": {"name": "Investment Master", "description": "Succeeded through investing alone. Numbers put food on the table.", "hint": "Reach the investment master ending"},
	"reputation_legend": {"name": "Beginning of a Legend", "description": "Your reputation became legendary. Your name is a brand.", "hint": "Reach the reputation legend ending"},
	"ten_lives": {"name": "Ten Lives", "description": "Lived ten lives. Gangnam no longer feels unfamiliar.", "hint": "Play 10 runs"},
	"beat_addiction": {"name": "Thirty Circles", "description": "Hit the bottom of gambling addiction and climbed back up. The strongest graduation.", "hint": "Complete the addiction recovery arc"},
	"four_seasons": {"name": "Four Seasons", "description": "Spent spring, summer, fall, and winter — all four — with one person.", "hint": "Some years are beautiful four times"},
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

func _ready():
	reload()

func reload():
	events.clear()
	events_by_id.clear()
	for path in EVENT_PATHS:
		for event in _load_array(path):
			events.append(event)
			events_by_id[event.get("id", "")] = event

	# 영어 이벤트 오버레이 — 같은 id를 영어 버전으로 교체
	if LocaleManager.language == "en":
		_apply_en_overlay()

	assets = _load_array(ASSETS_PATH)
	if LocaleManager.language == "en":
		_apply_catalog_en_overlay(assets, ASSET_TEXT_EN)
	assets_by_id = _index_by_id(assets)
	jobs = _load_array(JOBS_PATH)
	if LocaleManager.language == "en":
		_apply_catalog_en_overlay(jobs, JOB_TEXT_EN)
	jobs_by_id = _index_by_id(jobs)
	items = _load_array(ITEMS_PATH)
	if LocaleManager.language == "en":
		_apply_catalog_en_overlay(items, ITEM_TEXT_EN)
	items_by_id = _index_by_id(items)
	endings = _load_array(ENDINGS_PATH)
	endings_by_id = _index_by_id(endings)
	# 영어 엔딩 오버레이 — 같은 id의 텍스트 필드(title/description/condition 등)를 교체
	if LocaleManager.language == "en":
		_apply_endings_en_overlay()
	news_templates = _load_array(NEWS_PATH)
	if LocaleManager.language == "en":
		_apply_news_en_overlay()
	default_meta = _load_dict(META_PATH)
	achievements = _load_array(ACHIEVEMENTS_PATH)
	if LocaleManager.language == "en":
		_apply_catalog_en_overlay(achievements, ACHIEVEMENT_TEXT_EN)
	achievements_by_id = _index_by_id(achievements)
	clues = _load_array(CLUES_PATH)
	if LocaleManager.language == "en":
		_apply_catalog_en_overlay(clues, CLUE_TEXT_EN)
	clues_by_id = _index_by_id(clues)
	thoughts = _load_array(THOUGHTS_PATH)
	if LocaleManager.language == "en":
		_apply_catalog_en_overlay(thoughts, THOUGHT_TEXT_EN)
	thoughts_by_id = _index_by_id(thoughts)

func find_event(event_id):
	return events_by_id.get(event_id, {})

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

func _apply_en_overlay() -> void:
	var en_dir = "res://content/events_en/"
	var da := DirAccess.open(en_dir)
	if not da:
		return
	da.list_dir_begin()
	var fname := da.get_next()
	while fname != "":
		if fname.ends_with(".json"):
			for ev in _load_array(en_dir + fname):
				var eid: String = str(ev.get("id", ""))
				if eid == "":
					fname = da.get_next()
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
		else:
			merged[key] = overlay_event[key]
	return merged

func _apply_endings_en_overlay() -> void:
	# endings_en.json의 같은 id 엔딩으로 텍스트 필드를 덮어쓴다(없으면 KR 유지).
	if not ResourceLoader.exists(ENDINGS_EN_PATH) and not FileAccess.file_exists(ENDINGS_EN_PATH):
		return
	for ev in _load_array(ENDINGS_EN_PATH):
		var eid: String = str(ev.get("id", ""))
		if eid == "" or not endings_by_id.has(eid):
			continue
		var merged: Dictionary = (endings_by_id[eid] as Dictionary).duplicate(true)
		for key in ev.keys():
			merged[key] = ev[key]
		if _contains_hangul(str(merged.get("condition", ""))):
			merged["condition"] = "Discover this ending through play."
		var idx = endings.find(endings_by_id[eid])
		if idx >= 0:
			endings[idx] = merged
		endings_by_id[eid] = merged

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
