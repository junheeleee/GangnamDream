extends Node

const EVENT_PATHS = [
	"res://content/events/story_events.json",
	"res://content/events/arc_events.json",
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
]
const ASSETS_PATH = "res://content/assets.json"
const JOBS_PATH = "res://content/jobs.json"
const ITEMS_PATH = "res://content/items.json"
const ENDINGS_PATH = "res://content/endings.json"
const NEWS_PATH = "res://content/news_templates.json"
const META_PATH = "res://content/meta/default_meta.json"
const ACHIEVEMENTS_PATH = "res://content/meta/achievements.json"

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
	assets_by_id = _index_by_id(assets)
	jobs = _load_array(JOBS_PATH)
	jobs_by_id = _index_by_id(jobs)
	items = _load_array(ITEMS_PATH)
	items_by_id = _index_by_id(items)
	endings = _load_array(ENDINGS_PATH)
	endings_by_id = _index_by_id(endings)
	news_templates = _load_array(NEWS_PATH)
	default_meta = _load_dict(META_PATH)
	achievements = _load_array(ACHIEVEMENTS_PATH)
	achievements_by_id = _index_by_id(achievements)

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
