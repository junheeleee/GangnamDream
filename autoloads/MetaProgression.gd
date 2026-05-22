extends Node

const META_SAVE_PATH = "user://gangnam_dream_meta.json"

var data: Dictionary = {}

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

func _check_progression_unlocks(summary):
	var total_assets = float(summary.get("total_assets", 0.0))
	var ending_id = str(summary.get("ending_id", ""))
	var total_runs = int(data.get("total_runs", 0))
	# 자산 기준 언락
	if total_assets >= 50_000_000:
		unlock_trait("야근 면역자")
	if total_assets >= 200_000_000:
		unlock_trait("리스크 중독자")
	# 엔딩 기준 언락
	if ending_id in ["stable_success", "ordinary_life"]:
		unlock_trait("안정 지향형")
	if ending_id == "gangnam_dream":
		unlock_trait("강남드림 계승자")
	if ending_id in ["burnout", "mental_break"]:
		unlock_trait("번아웃 생존자")
	if ending_id in ["startup_exit", "political_fix"]:
		unlock_trait("인맥왕")
	# 런 횟수 기준 언락
	if total_runs >= 5:
		unlock_achievement("five_lives")
	if total_runs >= 10:
		unlock_trait("강남 토박이")
