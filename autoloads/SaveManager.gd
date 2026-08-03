extends Node

const BUILD_FLAVOR := preload("res://systems/BuildFlavor.gd")
const BUILD_INFO := preload("res://systems/BuildInfo.gd")

signal save_completed(success: bool, slot: int)
signal load_completed(success: bool, slot: int)

const SAVE_VERSION = 4
const NARRATIVE_RHYTHM_VERSION = 1
const SLOT_COUNT = 10
const AUTOSAVE_SLOT = 0
# Compatibility constant for tests and tools that explicitly inspect the
# legacy retail file. Production reads and writes use settings_path().
const SETTINGS_PATH = BUILD_FLAVOR.RETAIL_SETTINGS_PATH
const MAIN_GAME_SCENE = "res://scenes/MainGame.tscn"
const STORY_MODE_SCENE = "res://scenes/StoryMode.tscn"

# ── 환경설정 (언어 등) — 슬롯 세이브와 분리된 영구 설정 ──────────
var _settings: Dictionary = {}
var _settings_loaded: bool = false
var _loaded_resume_context: Dictionary = {}
var _loaded_slot_metadata: Dictionary = {}
var _loaded_save_identity: Dictionary = {}
var _last_load_diagnostic: Dictionary = {}

func _load_settings() -> void:
	if _settings_loaded:
		return
	_settings_loaded = true
	var path := settings_path()
	if not FileAccess.file_exists(path):
		return
	var f = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return
	var txt = f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(txt)
	if parsed is Dictionary:
		_settings = parsed

func get_setting(key: String, default_value = null):
	_load_settings()
	return _settings.get(key, default_value)

func set_setting(key: String, value) -> void:
	_load_settings()
	_settings[key] = value
	var f = FileAccess.open(settings_path(), FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(_settings))
	f.close()

func save_game(
		slot: int,
		resume_context: Dictionary = {},
		metadata: Dictionary = {}) -> bool:
	if not _valid_slot(slot):
		push_error("SaveManager: invalid save slot %d (expected %d..%d)." % [
			slot, AUTOSAVE_SLOT, SLOT_COUNT])
		save_completed.emit(false, slot)
		return false
	var state = GameState.serialize()
	# 로그 크기 캡 — 파일 비대화 방지
	state["action_log"] = state["action_log"].slice(max(0, state["action_log"].size() - 100))
	state["news_log"]   = state["news_log"].slice(max(0, state["news_log"].size() - 60))
	state["event_log"]  = state["event_log"].slice(max(0, state["event_log"].size() - 100))
	var payload = {
		"version": SAVE_VERSION,
		"narrative_rhythm_version": NARRATIVE_RHYTHM_VERSION,
		"slot": slot,
		"saved_at": Time.get_datetime_string_from_system(),
		"mod_active": ModLoader.is_active(LocaleManager.language),
		"active_mods": ModLoader.active_mod_labels(LocaleManager.language),
		"state": state,
		"resume": resume_context.duplicate(true),
		"metadata": metadata.duplicate(true),
	}
	payload.merge(save_identity_fields(), true)
	var file = FileAccess.open(_slot_path(slot), FileAccess.WRITE)
	if file == null:
		save_completed.emit(false, slot)
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	save_completed.emit(true, slot)
	return true

func autosave(resume_context: Dictionary = {}) -> bool:
	return save_game(AUTOSAVE_SLOT, resume_context)

func load_game(slot: int) -> bool:
	_loaded_resume_context.clear()
	_loaded_slot_metadata.clear()
	_loaded_save_identity.clear()
	_last_load_diagnostic.clear()
	if not _valid_slot(slot):
		load_completed.emit(false, slot)
		return false
	if not has_save(slot):
		load_completed.emit(false, slot)
		return false
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(_slot_path(slot)))
	if not (parsed is Dictionary):
		load_completed.emit(false, slot)
		return false
	var state_value: Variant = parsed.get("state", parsed)
	if not state_value is Dictionary:
		load_completed.emit(false, slot)
		return false
	var compatibility := inspect_payload_compatibility(parsed, state_value)
	_last_load_diagnostic = compatibility.duplicate(true)
	if not bool(compatibility.get("compatible", false)):
		push_warning("SaveManager: rejected slot %d (%s)." % [
			slot, str(compatibility.get("reason", "incompatible"))])
		load_completed.emit(false, slot)
		return false
	for warning in compatibility.get("warnings", []):
		push_warning("SaveManager: slot %d: %s." % [slot, str(warning)])
	var state := migrate_narrative_rhythm_state(
			state_value, int(parsed.get("narrative_rhythm_version", 0)))
	GameState.load_from_dict(state)
	GameState.pending_story_queue.clear()
	GameState.story_return_scene = ""
	GameState.returning_from_story = false
	GameState.story_replay_mode = false
	var resume_value: Variant = parsed.get("resume", {})
	if resume_value is Dictionary:
		_loaded_resume_context = resume_value.duplicate(true)
	var metadata_value: Variant = parsed.get("metadata", {})
	if metadata_value is Dictionary:
		_loaded_slot_metadata = metadata_value.duplicate(true)
	_loaded_save_identity = compatibility.get("source_identity", {}).duplicate(true)
	LocaleManager.sync_player_name_for_current_language()
	load_completed.emit(true, slot)
	return true

func clear_loaded_resume_context() -> void:
	_loaded_resume_context.clear()
	_loaded_slot_metadata.clear()
	_loaded_save_identity.clear()
	_last_load_diagnostic.clear()

func peek_loaded_resume_context() -> Dictionary:
	return _loaded_resume_context.duplicate(true)

func consume_loaded_resume_context() -> Dictionary:
	var context := _loaded_resume_context.duplicate(true)
	_loaded_resume_context.clear()
	return context

func loaded_slot_metadata() -> Dictionary:
	return _loaded_slot_metadata.duplicate(true)

func loaded_save_identity() -> Dictionary:
	return _loaded_save_identity.duplicate(true)

func last_load_diagnostic() -> Dictionary:
	return _last_load_diagnostic.duplicate(true)

func loaded_scene_path() -> String:
	var requested := str(_loaded_resume_context.get("scene", ""))
	if requested == STORY_MODE_SCENE:
		return STORY_MODE_SCENE
	return MAIN_GAME_SCENE

func migrate_narrative_rhythm_state(state: Dictionary, source_version: int) -> Dictionary:
	var migrated := state.duplicate(true)
	if source_version >= NARRATIVE_RHYTHM_VERSION:
		return migrated
	# Old saves never classified the current week under the 52-decision cadence.
	# Preserve every authored/economy flag, but let the loaded week classify once.
	var state_flags: Dictionary = migrated.get("flags", {}).duplicate(true)
	state_flags.erase("demo_director_kind_turn")
	state_flags.erase("demo_director_locked_kind")
	migrated["flags"] = state_flags
	return migrated

func has_save(slot: int) -> bool:
	if not _valid_slot(slot):
		return false
	return FileAccess.file_exists(_slot_path(slot))

func delete_save(slot: int) -> void:
	if not _valid_slot(slot):
		return
	if has_save(slot):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(_slot_path(slot)))

func get_slots() -> Array:
	var slots: Array = []
	for slot in range(SLOT_COUNT + 1):
		slots.append(get_save_info(slot))
	return slots

func get_save_info(slot: int) -> Dictionary:
	if not _valid_slot(slot):
		return {"slot": slot, "empty": true, "invalid": true}
	if not has_save(slot):
		return {"slot": slot, "empty": true}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(_slot_path(slot)))
	if not (parsed is Dictionary):
		return {"slot": slot, "empty": true, "corrupt": true}
	var state_value: Variant = parsed.get("state", {})
	if not state_value is Dictionary:
		return {"slot": slot, "empty": true, "corrupt": true}
	var state: Dictionary = state_value
	var resume_value: Variant = parsed.get("resume", {})
	var resume: Dictionary = resume_value if resume_value is Dictionary else {}
	var metadata_value: Variant = parsed.get("metadata", {})
	var metadata: Dictionary = metadata_value if metadata_value is Dictionary else {}
	var turn: int = maxi(1, int(state.get("turn", 1)))
	var compatibility := inspect_payload_compatibility(parsed, state)
	var info := {
		"slot": slot,
		"empty": false,
		"version": int(parsed.get("version", 1)),
		"saved_at": parsed.get("saved_at", ""),
		"player_name": LocaleManager.localize_player_name(str(state.get("player_name", "김민준"))),
		"year": state.get("year", 2026),
		"month": state.get("month", 1),
		"week_of_month": state.get("week_of_month", 1),
		"age": state.get("age", 20),
		"turn": turn,
		"chapter": mini(5, floori(float(turn - 1) / 48.0) + 1),
		"money": state.get("money", 0.0),
		"total_assets": _estimate_total_assets(state),
		"mod_active": bool(parsed.get("mod_active", false)),
		"resume_kind": str(resume.get("kind", "")),
		"resume_scene": str(resume.get("scene", MAIN_GAME_SCENE)),
		"event_id": str(resume.get("event_id", "")),
		"phase": str(resume.get("phase", "")),
		"label": str(metadata.get("label", "")),
		"qa_fixture": bool(metadata.get("qa_fixture", false)),
	}
	info.merge(compatibility, true)
	return info

func slot_path(slot: int) -> String:
	return _slot_path(slot)

func settings_path() -> String:
	return BUILD_FLAVOR.settings_path()

func save_identity_fields() -> Dictionary:
	return BUILD_INFO.artifact_identity()

func inspect_payload_compatibility(
		payload: Dictionary,
		state: Dictionary = {},
		target_identity: Dictionary = {}) -> Dictionary:
	var current := (
		target_identity.duplicate(true)
		if not target_identity.is_empty()
		else save_identity_fields()
	)
	var result := {
		"compatible": false,
		"compatibility_status": "incompatible",
		"reason": "invalid_payload",
		"warnings": [],
		"source_identity": {},
		"target_identity": current,
	}
	var raw_version: Variant = payload.get("version", 1)
	if not (raw_version is int or raw_version is float):
		result["reason"] = "invalid_save_version"
		return result
	if raw_version is float and not is_equal_approx(
			float(raw_version), float(int(raw_version))):
		result["reason"] = "invalid_save_version"
		return result
	var file_version := int(raw_version)
	if file_version < 1:
		result["reason"] = "invalid_save_version"
		return result
	if file_version > SAVE_VERSION:
		result["reason"] = "future_save_version"
		return result

	var identity_keys := [
		"game_version", "build_id", "build_flavor", "save_namespace"]
	var source: Dictionary = {}
	var present_count := 0
	for key in identity_keys:
		if not payload.has(key):
			source[key] = "unknown"
			continue
		present_count += 1
		var raw_value: Variant = payload.get(key)
		if (
			not raw_value is String
			or str(raw_value).strip_edges().is_empty()
			or str(raw_value).strip_edges() == "unknown"
		):
			result["reason"] = "invalid_identity_field"
			result["source_identity"] = source
			return result
		source[key] = str(raw_value).strip_edges()
	result["source_identity"] = source

	var warnings: Array[String] = []
	if file_version < SAVE_VERSION:
		warnings.append("older_save_version")
	if present_count == 0:
		warnings.append("legacy_identity_unknown")
	elif present_count < identity_keys.size():
		warnings.append("partial_build_identity")

	var source_flavor := str(source.get("build_flavor", "unknown"))
	var source_namespace := str(source.get("save_namespace", "unknown"))
	var target_flavor := str(current.get("build_flavor", "full"))
	var target_namespace := str(current.get("save_namespace", "legacy"))
	var known_flavors := [
		"unknown", "full", "demo", BUILD_FLAVOR.PLAYTEST_FLAVOR_ID]
	if not known_flavors.has(source_flavor):
		result["reason"] = "unknown_build_flavor"
		return result

	if target_namespace == BUILD_FLAVOR.PLAYTEST_SAVE_NAMESPACE:
		if (
			source_namespace != target_namespace
			or source_flavor != BUILD_FLAVOR.PLAYTEST_FLAVOR_ID
		):
			result["reason"] = "save_namespace_mismatch"
			return result
	else:
		if source_namespace != "unknown" and source_namespace != target_namespace:
			result["reason"] = "save_namespace_mismatch"
			return result
		if source_flavor == BUILD_FLAVOR.PLAYTEST_FLAVOR_ID:
			result["reason"] = "build_flavor_mismatch"
			return result

	var turn: int = maxi(1, int(state.get("turn", 1)))
	if target_flavor in ["demo", BUILD_FLAVOR.PLAYTEST_FLAVOR_ID]:
		if source_flavor == "full":
			result["reason"] = "full_save_in_demo"
			return result
		if turn > GameState.DEMO_TURN_LIMIT:
			result["reason"] = "demo_turn_limit"
			return result
	elif target_flavor == "full" and source_flavor == "demo":
		warnings.append("demo_save_in_full_build")

	for key in ["game_version", "build_id"]:
		var source_value := str(source.get(key, "unknown"))
		var target_value := str(current.get(key, "unknown"))
		if source_value != "unknown" and source_value != target_value:
			warnings.append("%s_mismatch" % key)

	result["warnings"] = warnings
	result["compatible"] = true
	result["reason"] = "ok"
	result["compatibility_status"] = (
		"compatible" if warnings.is_empty() else "compatible_with_warning"
	)
	return result

func _valid_slot(slot: int) -> bool:
	return slot >= AUTOSAVE_SLOT and slot <= SLOT_COUNT

func _slot_path(slot: int) -> String:
	return BUILD_FLAVOR.slot_path(slot)

func _estimate_total_assets(state: Dictionary) -> float:
	var total = float(state.get("money", 0.0))
	var portfolio: Dictionary = state.get("portfolio", {})
	var prices: Dictionary = state.get("market_prices", {})
	for asset_id in portfolio:
		var holding: Dictionary = portfolio[asset_id]
		total += float(holding.get("quantity", 0.0)) * float(prices.get(asset_id, holding.get("avg_price", 0.0)))
	return total
