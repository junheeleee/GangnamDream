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
	var saved := _write_save_payload(_slot_path(slot), payload, slot)
	save_completed.emit(saved, slot)
	return saved

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
	var path := _slot_path(slot)
	var selection: Dictionary = _select_save_candidate(path, slot)
	if not bool(selection.get("valid", false)):
		load_completed.emit(false, slot)
		return false
	var parsed: Dictionary = selection.get("payload", {})
	var state_value: Dictionary = selection.get("state", {})
	var compatibility: Dictionary = selection.get("compatibility", {})
	var recovered_from_backup := bool(selection.get(
		"recovered_from_backup", false))
	_last_load_diagnostic = compatibility.duplicate(true)
	if not bool(compatibility.get("compatible", false)):
		push_warning("SaveManager: rejected slot %d (%s)." % [
			slot, str(compatibility.get("reason", "incompatible"))])
		load_completed.emit(false, slot)
		return false
	for warning in compatibility.get("warnings", []):
		push_warning("SaveManager: slot %d: %s." % [slot, str(warning)])
	if recovered_from_backup and not _restore_primary_from_backup(path, slot):
		push_warning(("SaveManager: slot %d loaded from its verified backup, " \
			+ "but the primary file could not be restored.") % slot)
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
	var path := _slot_path(slot)
	return FileAccess.file_exists(path) \
			or FileAccess.file_exists(_backup_path(path))

func delete_save(slot: int) -> void:
	if not _valid_slot(slot):
		return
	var path := _slot_path(slot)
	for owned_path in [
		path, _backup_path(path), "%s.tmp" % path,
		"%s.tmp" % _backup_path(path), "%s.recovery.tmp" % path,
	]:
		_remove_save_temporary_file(str(owned_path))

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
	var path := _slot_path(slot)
	var selection: Dictionary = _select_save_candidate(path, slot)
	if not bool(selection.get("valid", false)):
		return {"slot": slot, "empty": true, "corrupt": true}
	var parsed: Dictionary = selection.get("payload", {})
	var state: Dictionary = selection.get("state", {})
	var resume_value: Variant = parsed.get("resume", {})
	var resume: Dictionary = resume_value if resume_value is Dictionary else {}
	var metadata_value: Variant = parsed.get("metadata", {})
	var metadata: Dictionary = metadata_value if metadata_value is Dictionary else {}
	var turn: int = maxi(1, int(state.get("turn", 1)))
	var compatibility: Dictionary = selection.get("compatibility", {})
	var recovered_from_backup := bool(selection.get(
		"recovered_from_backup", false))
	var recovery_reason := str(selection.get("recovery_reason", ""))
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
		"recovered_from_backup": recovered_from_backup,
		"recovery_reason": recovery_reason if recovered_from_backup else "",
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
	if not (raw_version is int or raw_version is float) \
			or not is_finite(float(raw_version)) \
			or float(raw_version) != float(int(raw_version)):
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

	var raw_turn: Variant = state.get("turn", 1)
	if not (raw_turn is int or raw_turn is float) \
			or not is_finite(float(raw_turn)) \
			or float(raw_turn) != float(int(raw_turn)) \
			or int(raw_turn) < 1:
		result["reason"] = "invalid_turn"
		return result
	var turn := int(raw_turn)
	if target_flavor in ["demo", BUILD_FLAVOR.PLAYTEST_FLAVOR_ID]:
		if source_flavor == "full":
			result["reason"] = "full_save_in_demo"
			return result
		var exact_playtest_completion := (
			target_flavor == BUILD_FLAVOR.PLAYTEST_FLAVOR_ID
			and target_namespace == BUILD_FLAVOR.PLAYTEST_SAVE_NAMESPACE
			and source_flavor == BUILD_FLAVOR.PLAYTEST_FLAVOR_ID
			and source_namespace == BUILD_FLAVOR.PLAYTEST_SAVE_NAMESPACE
			and _is_v2_demo_completion_boundary(state)
		)
		if turn > GameState.DEMO_TURN_LIMIT \
				and not exact_playtest_completion:
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

func _is_v2_demo_completion_boundary(state: Dictionary) -> bool:
	# Week 24 is committed before the calendar advances to turn 25. That turn is
	# the sealed demo receipt, not playable Week 25, and is reloadable only in
	# the dedicated V2 playtest namespace. Keep arbitrary turn-25 states blocked.
	if not _is_exact_integer(
			state.get("turn", null), GameState.DEMO_TURN_LIMIT + 1):
		return false
	var raw_v2: Variant = state.get("core_loop_v2_state", {})
	if not raw_v2 is Dictionary:
		return false
	var v2: Dictionary = raw_v2
	var completed_turns: Variant = v2.get("completed_turns", [])
	if not completed_turns is Array \
			or (completed_turns as Array).size() != GameState.DEMO_TURN_LIMIT:
		return false
	var normalized_completed_turns: Array[int] = []
	for raw_week in completed_turns as Array:
		var completed_week := int(raw_week) \
				if raw_week is int or raw_week is float else 0
		if not _is_exact_integer(raw_week, completed_week) \
				or completed_week < 1 \
				or completed_week > GameState.DEMO_TURN_LIMIT \
				or normalized_completed_turns.has(completed_week):
			return false
		normalized_completed_turns.append(completed_week)
	for week in range(1, GameState.DEMO_TURN_LIMIT + 1):
		if not normalized_completed_turns.has(week):
			return false
	return v2.get("enabled", null) is bool \
			and v2.get("enabled", false) == true \
			and v2.get("prototype_complete", null) is bool \
			and v2.get("prototype_complete", false) == true \
			and _is_exact_integer(v2.get("development_cap_week", null),
				GameState.DEMO_TURN_LIMIT) \
			and _is_exact_integer(v2.get("completed_through_week", null),
				GameState.DEMO_TURN_LIMIT) \
			and _is_exact_integer(v2.get("completed_at_turn", null),
				GameState.DEMO_TURN_LIMIT + 1) \
			and _is_exact_integer(v2.get("prototype_completed_at_turn", null),
				GameState.DEMO_TURN_LIMIT + 1)

func _slot_path(slot: int) -> String:
	return BUILD_FLAVOR.slot_path(slot)

func _backup_path(path: String) -> String:
	return "%s.bak" % path

func _is_exact_integer(value: Variant, expected: int) -> bool:
	if value is int:
		return int(value) == expected
	if not value is float or not is_finite(float(value)):
		return false
	return float(value) == float(expected)

func _read_save_candidate(path: String, slot: int) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"valid": false, "reason": "missing", "path": path}
	var bytes := FileAccess.get_file_as_bytes(path)
	var json := JSON.new()
	if json.parse(bytes.get_string_from_utf8()) != OK:
		return {"valid": false, "reason": "invalid_json", "path": path}
	var parsed: Variant = json.data
	if not parsed is Dictionary:
		return {"valid": false, "reason": "invalid_json", "path": path}
	var payload: Dictionary = parsed
	if payload.has("slot") and not _is_exact_integer(payload.get("slot"), slot):
		return {"valid": false, "reason": "slot_mismatch", "path": path}
	if not payload.has("state") and (
			payload.has("version") or payload.has("slot")
			or payload.has("resume") or payload.has("metadata")
			or payload.has("build_flavor") or payload.has("save_namespace")
	):
		return {"valid": false, "reason": "invalid_state", "path": path}
	var state_value: Variant = payload.get("state", payload)
	if not state_value is Dictionary:
		return {"valid": false, "reason": "invalid_state", "path": path}
	var state_diagnostic := _save_state_field_diagnostic(
		state_value as Dictionary)
	if not state_diagnostic.is_empty():
		return {
			"valid": false,
			"reason": "invalid_state_field",
			"diagnostic": state_diagnostic,
			"path": path,
		}
	return {
		"valid": true,
		"reason": "ok",
		"path": path,
		"bytes": bytes,
		"payload": payload,
		"state": state_value,
	}

func _save_state_field_diagnostic(state: Dictionary) -> String:
	# Missing top-level fields are valid legacy input. Only fields that are
	# present are checked, and nested schemas remain owned by their migrations.
	var dictionary_fields := [
		"action_axis_this_week", "action_places_this_week",
		"pending_weekly_commitment", "forgone_path_debts",
		"core_loop_v2_state", "phone_state", "contact_counts",
		"last_contact_turn", "run_seen_scenes_by_year", "year_scenes",
		"tendency", "housing_months", "current_job",
		"milestones_reached", "portfolio", "loans", "cast", "flags",
		"active_thought", "market_prices", "price_history",
		"market_context", "unlocked_stat_thresholds",
		"random_event_counts", "random_event_last_turns",
	]
	for key in dictionary_fields:
		if state.has(key) and not state.get(key) is Dictionary:
			return "%s:expected_dictionary" % key
	var array_fields := [
		"week_routine", "action_records_this_week", "recent_action_places",
		"recent_action_weeks", "weekly_commitments", "relationships",
		"inventory", "news_log", "event_log", "action_log", "clues",
		"thoughts_done", "deferred_events", "run_theme_categories",
	]
	for key in array_fields:
		if state.has(key) and not state.get(key) is Array:
			return "%s:expected_array" % key
	var integer_fields := [
		"age", "year", "month", "week_of_month", "turn",
		"health", "mental", "intelligence", "social_skill", "appearance",
		"investment_skill", "luck", "reputation",
		"gambling_tendency", "addiction_tendency",
		"job_tenure", "work_performance",
		"action_points", "max_action_points", "tutorial_step",
		"grind_streak_weeks", "money_weeks_total",
		"human_weeks_total", "month_money_weeks", "month_human_weeks",
		"last_month_money_weeks", "last_month_human_weeks",
		"route_orthodox", "route_unorthodox", "moral_band_last",
		"events_seen", "health", "mental",
	]
	for key in integer_fields:
		if not state.has(key):
			continue
		var value: Variant = state.get(key)
		if not (value is int or value is float) \
				or not is_finite(float(value)) \
				or float(value) != float(int(value)):
			return "%s:expected_finite_integer" % key
		if key == "turn" and int(value) < 1:
			return "turn:expected_positive_integer"
	for key in [
		"loop_tint_spent", "moral_tint", "peak_asset", "money",
		"monthly_income", "fixed_expense",
	]:
		if state.has(key):
			var value: Variant = state.get(key)
			if not (value is int or value is float) \
					or not is_finite(float(value)):
				return "%s:expected_finite_number" % key
	for key in [
		"housing", "difficulty", "tendency_realized", "month_focus",
		"run_theme", "player_name", "player_background", "player_route",
	]:
		if state.has(key) and not state.get(key) is String:
			return "%s:expected_string" % key
	if state.has("is_game_over") and not state.get("is_game_over") is bool:
		return "is_game_over:expected_bool"
	return ""

func _select_save_candidate(path: String, slot: int) -> Dictionary:
	var candidate: Dictionary = _read_save_candidate(path, slot)
	var recovered_from_backup := false
	var recovery_reason := str(candidate.get("reason", "missing"))
	var recovery_diagnostic := str(candidate.get("diagnostic", ""))
	if not bool(candidate.get("valid", false)):
		candidate = _read_save_candidate(_backup_path(path), slot)
		recovered_from_backup = bool(candidate.get("valid", false))
	if not bool(candidate.get("valid", false)):
		return {
			"valid": false,
			"reason": str(candidate.get("reason", recovery_reason)),
			"diagnostic": str(candidate.get(
				"diagnostic", recovery_diagnostic)),
		}
	var parsed: Dictionary = candidate.get("payload", {})
	var state: Dictionary = candidate.get("state", {})
	var compatibility: Dictionary = inspect_payload_compatibility(parsed, state)
	if not bool(compatibility.get("compatible", false)) \
			and not recovered_from_backup \
			and _compatibility_failure_allows_backup(
				str(compatibility.get("reason", ""))):
		var backup_candidate: Dictionary = _read_save_candidate(
			_backup_path(path), slot)
		if bool(backup_candidate.get("valid", false)):
			var backup_payload: Dictionary = backup_candidate.get("payload", {})
			var backup_state: Dictionary = backup_candidate.get("state", {})
			var backup_compatibility: Dictionary = inspect_payload_compatibility(
				backup_payload, backup_state)
			if bool(backup_compatibility.get("compatible", false)):
				recovery_reason = str(compatibility.get(
					"reason", "invalid_primary"))
				candidate = backup_candidate
				parsed = backup_payload
				state = backup_state
				compatibility = backup_compatibility
				recovered_from_backup = true
	if recovered_from_backup:
		var recovery_warnings: Array = compatibility.get(
			"warnings", []).duplicate()
		if not recovery_warnings.has("recovered_from_backup"):
			recovery_warnings.append("recovered_from_backup")
		compatibility["warnings"] = recovery_warnings
		compatibility["compatibility_status"] = "compatible_with_warning"
		compatibility["recovered_from_backup"] = true
		compatibility["recovery_reason"] = recovery_reason
		if not recovery_diagnostic.is_empty():
			compatibility["diagnostic"] = recovery_diagnostic
	return {
		"valid": true,
		"candidate": candidate,
		"payload": parsed,
		"state": state,
		"compatibility": compatibility,
		"recovered_from_backup": recovered_from_backup,
		"recovery_reason": recovery_reason if recovered_from_backup else "",
		"diagnostic": recovery_diagnostic if recovered_from_backup else "",
	}

func _compatibility_failure_allows_backup(reason: String) -> bool:
	return reason in [
		"invalid_payload", "invalid_save_version", "invalid_identity_field",
		"unknown_build_flavor", "invalid_state_field",
	]

func _write_save_payload(path: String, payload: Dictionary, slot: int) -> bool:
	# Never truncate the last known-good save in place. Godot's Windows rename
	# deletes an existing destination before MoveFileW, so a verified sidecar is
	# required even after a perfect temporary write. Load paths can recover that
	# sidecar if replacement loses the primary; macOS/Linux still get same-folder
	# POSIX rename semantics.
	var temporary_path := "%s.tmp" % path
	var serialized := JSON.stringify(payload, "\t")
	var serialized_bytes := serialized.to_utf8_buffer()
	var write_error := _write_exact_bytes(temporary_path, serialized_bytes)
	if write_error != OK:
		_remove_save_temporary_file(temporary_path)
		_save_write_warning(slot, "temporary file write", write_error)
		return false
	var readback := FileAccess.get_file_as_bytes(temporary_path)
	if readback != serialized_bytes or not _is_expected_save_payload(readback, slot):
		_remove_save_temporary_file(temporary_path)
		_save_write_warning(slot, "temporary file verification", ERR_FILE_CORRUPT)
		return false

	var primary_candidate := _read_save_candidate(path, slot)
	var backup_candidate := _read_save_candidate(_backup_path(path), slot)
	var primary_compatible := _save_candidate_is_compatible(primary_candidate)
	var backup_compatible := _save_candidate_is_compatible(backup_candidate)
	if primary_compatible:
		var previous_bytes: PackedByteArray = primary_candidate.get(
			"bytes", PackedByteArray())
		if not _prepare_verified_backup(path, previous_bytes, slot):
			_remove_save_temporary_file(temporary_path)
			_save_write_warning(slot, "verified backup preparation", FAILED)
			return false
	elif backup_compatible:
		# A prior interrupted replacement may already have left only the verified
		# backup, or a malformed/incompatible primary may sit beside a compatible
		# backup. Keep that last loadable generation untouched until the new current
		# primary is installed and verified.
		pass

	# ManualSaveCheck owns this one-shot seam to exercise the otherwise
	# platform/race-dependent failure between backup preservation and replacement.
	# It is removed before returning and cannot affect a later save attempt.
	if has_meta("_qa_fail_next_primary_replacement"):
		var fail_replacement := bool(get_meta(
			"_qa_fail_next_primary_replacement", false))
		remove_meta("_qa_fail_next_primary_replacement")
		if fail_replacement:
			_remove_save_temporary_file(temporary_path)
			_restore_primary_from_backup(path, slot)
			_save_write_warning(slot, "primary replacement", FAILED)
			return false

	var rename_error := DirAccess.rename_absolute(
			ProjectSettings.globalize_path(temporary_path),
			ProjectSettings.globalize_path(path))
	if rename_error != OK:
		_remove_save_temporary_file(temporary_path)
		_restore_primary_from_backup(path, slot)
		_save_write_warning(slot, "primary replacement", rename_error)
		return false
	var final_bytes := FileAccess.get_file_as_bytes(path)
	if final_bytes != serialized_bytes \
			or not _is_expected_save_payload(final_bytes, slot):
		_restore_primary_from_backup(path, slot)
		_save_write_warning(slot, "primary file verification", ERR_FILE_CORRUPT)
		return false
	return true

func _save_candidate_is_compatible(candidate: Dictionary) -> bool:
	if not bool(candidate.get("valid", false)):
		return false
	var payload: Dictionary = candidate.get("payload", {})
	var state: Dictionary = candidate.get("state", {})
	return bool(inspect_payload_compatibility(
		payload, state).get("compatible", false))

func _is_expected_save_payload(bytes: PackedByteArray, slot: int) -> bool:
	var parsed: Variant = JSON.parse_string(bytes.get_string_from_utf8())
	if not parsed is Dictionary:
		return false
	var payload: Dictionary = parsed
	if not _is_exact_integer(payload.get("version", null), SAVE_VERSION) \
			or not _is_exact_integer(payload.get("slot", null), slot) \
			or not payload.get("state", null) is Dictionary:
		return false
	var expected_identity := save_identity_fields()
	for key in ["game_version", "build_id", "build_flavor", "save_namespace"]:
		if not payload.get(key, null) is String \
				or str(payload.get(key, "")) != str(expected_identity.get(key, "")):
			return false
	return true

func _write_exact_bytes(path: String, bytes: PackedByteArray) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var wrote_all := file.store_buffer(bytes)
	file.flush()
	var write_error := file.get_error()
	file.close()
	if not wrote_all and write_error == OK:
		write_error = ERR_FILE_CANT_WRITE
	if write_error != OK:
		return write_error
	return OK if FileAccess.get_file_as_bytes(path) == bytes else ERR_FILE_CORRUPT

func _prepare_verified_backup(
		path: String, previous_bytes: PackedByteArray, slot: int) -> bool:
	var backup_path := _backup_path(path)
	var existing := _read_save_candidate(backup_path, slot)
	if bool(existing.get("valid", false)) \
			and existing.get("bytes", PackedByteArray()) == previous_bytes:
		return true
	var backup_temporary_path := "%s.tmp" % backup_path
	var write_error := _write_exact_bytes(backup_temporary_path, previous_bytes)
	if write_error != OK \
			or not bool(_read_save_candidate(
				backup_temporary_path, slot).get("valid", false)):
		_remove_save_temporary_file(backup_temporary_path)
		return false
	var rename_error := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(backup_temporary_path),
		ProjectSettings.globalize_path(backup_path))
	if rename_error != OK:
		_remove_save_temporary_file(backup_temporary_path)
		return false
	var verified := _read_save_candidate(backup_path, slot)
	return bool(verified.get("valid", false)) \
			and verified.get("bytes", PackedByteArray()) == previous_bytes

func _restore_primary_from_backup(path: String, slot: int) -> bool:
	var backup := _read_save_candidate(_backup_path(path), slot)
	if not bool(backup.get("valid", false)):
		return false
	var backup_bytes: PackedByteArray = backup.get("bytes", PackedByteArray())
	var primary := _read_save_candidate(path, slot)
	if bool(primary.get("valid", false)) \
			and primary.get("bytes", PackedByteArray()) == backup_bytes:
		return true
	var recovery_path := "%s.recovery.tmp" % path
	if _write_exact_bytes(recovery_path, backup_bytes) != OK \
			or not bool(_read_save_candidate(recovery_path, slot).get("valid", false)):
		_remove_save_temporary_file(recovery_path)
		return false
	var rename_error := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(recovery_path),
		ProjectSettings.globalize_path(path))
	if rename_error != OK:
		_remove_save_temporary_file(recovery_path)
		return false
	var restored := _read_save_candidate(path, slot)
	return bool(restored.get("valid", false)) \
			and restored.get("bytes", PackedByteArray()) == backup_bytes

func _remove_save_temporary_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _save_write_warning(slot: int, stage: String, error: Error) -> void:
	push_warning("SaveManager: slot %d save failed during %s (error %d)." % [
		slot, stage, error])

func _estimate_total_assets(state: Dictionary) -> float:
	var total = float(state.get("money", 0.0))
	var portfolio: Dictionary = state.get("portfolio", {})
	var prices: Dictionary = state.get("market_prices", {})
	for asset_id in portfolio:
		var holding: Dictionary = portfolio[asset_id]
		total += float(holding.get("quantity", 0.0)) * float(prices.get(asset_id, holding.get("avg_price", 0.0)))
	return total
