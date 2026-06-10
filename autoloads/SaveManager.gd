extends Node

signal save_completed(success: bool, slot: int)
signal load_completed(success: bool, slot: int)

const SAVE_VERSION = 3
const SLOT_COUNT = 3
const AUTOSAVE_SLOT = 0

func save_game(slot):
	var state = GameState.serialize()
	# 로그 크기 캡 — 파일 비대화 방지
	state["action_log"] = state["action_log"].slice(max(0, state["action_log"].size() - 100))
	state["news_log"]   = state["news_log"].slice(max(0, state["news_log"].size() - 60))
	state["event_log"]  = state["event_log"].slice(max(0, state["event_log"].size() - 100))
	var payload = {
		"version": SAVE_VERSION,
		"slot": slot,
		"saved_at": Time.get_datetime_string_from_system(),
		"state": state,
	}
	var file = FileAccess.open(_slot_path(slot), FileAccess.WRITE)
	if file == null:
		save_completed.emit(false, slot)
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	save_completed.emit(true, slot)
	return true

func autosave():
	return save_game(AUTOSAVE_SLOT)

func load_game(slot):
	if not has_save(slot):
		load_completed.emit(false, slot)
		return false
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(_slot_path(slot)))
	if not (parsed is Dictionary):
		load_completed.emit(false, slot)
		return false
	# 버전 불일치 경고 (미래 마이그레이션 훅)
	var file_version = int(parsed.get("version", 1))
	if file_version < SAVE_VERSION:
		push_warning("SaveManager: save file version %d < current %d (slot %d). Loading anyway." % [file_version, SAVE_VERSION, slot])
	GameState.load_from_dict(parsed.get("state", parsed))
	load_completed.emit(true, slot)
	return true

func has_save(slot):
	return FileAccess.file_exists(_slot_path(slot))

func delete_save(slot):
	if has_save(slot):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(_slot_path(slot)))

func get_slots():
	var slots: Array = []
	for slot in range(SLOT_COUNT + 1):
		slots.append(get_save_info(slot))
	return slots

func get_save_info(slot):
	if not has_save(slot):
		return {"slot": slot, "empty": true}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(_slot_path(slot)))
	if not (parsed is Dictionary):
		return {"slot": slot, "empty": true, "corrupt": true}
	var state: Dictionary = parsed.get("state", {})
	return {
		"slot": slot,
		"empty": false,
		"saved_at": parsed.get("saved_at", ""),
		"player_name": state.get("player_name", "김민준"),
		"year": state.get("year", 2026),
		"month": state.get("month", 1),
		"age": state.get("age", 20),
		"turn": state.get("turn", 1),
		"money": state.get("money", 0.0),
		"total_assets": _estimate_total_assets(state),
	}

func _slot_path(slot):
	if slot == AUTOSAVE_SLOT:
		return "user://gangnam_dream_autosave.json"
	return "user://gangnam_dream_slot_%d.json" % slot

func _estimate_total_assets(state):
	var total = float(state.get("money", 0.0))
	var portfolio: Dictionary = state.get("portfolio", {})
	var prices: Dictionary = state.get("market_prices", {})
	for asset_id in portfolio:
		var holding: Dictionary = portfolio[asset_id]
		total += float(holding.get("quantity", 0.0)) * float(prices.get(asset_id, holding.get("avg_price", 0.0)))
	return total
