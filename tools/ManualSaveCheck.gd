extends Node
## ManualSaveCheck — 10슬롯과 StoryMode 중간 재개 계약을 실제 런타임으로 검증한다.

const CORE_LOOP := preload("res://systems/DemoCoreLoopV2.gd")
const MAIN_GAME_SCENE := preload("res://scenes/MainGame.tscn")
const TEST_SLOT := 1
const LEGACY_SLOT := 9
const CONTRACT_SLOT := 10

var _story: Control = null
var _failures: Array[String] = []
var _backups: Dictionary = {}
var _settings_backup: Dictionary = {}
var _meta_file_backup: Dictionary = {}
var _meta_data_backup: Dictionary = {}
var _meta_new_this_run_backup: Dictionary = {}

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	_backup_settings_file()
	_backup_meta_progression()
	_backup_test_slots()
	GameState.start_new_game()
	_check_slot_and_legacy_contract()
	if not _failures.is_empty():
		await _finish()
		return
	await _check_main_game_save_failure_feedback()
	if not _failures.is_empty():
		await _finish()
		return
	await _check_prose_resume()
	await _check_choice_and_result_resume()
	await _check_result_choice_receipt_index_guard()
	await _check_year_scene_result_resume()
	await _check_father_passed_result_variant_resume()
	await _check_father_passed_result_variant_receipt_guard()
	await _check_father_passed_nonresult_variant_resume()
	await _check_father_stale_pending_story_queue()
	await _check_father_passing_terminal_result_resume()
	await _check_timed_choice_resume()
	await _check_cross_locale_resume_rewind()
	await _check_pre_dialogue_history_resume()
	await _check_first_bill_continuous_resume()
	await _check_story_save_surface()
	await _finish()

func _check_slot_and_legacy_contract() -> void:
	_expect(SaveManager.SLOT_COUNT == 10, "manual slot count is not 10")
	GameState.turn = 97
	var context := {
		"kind": "story",
		"scene": "res://scenes/StoryMode.tscn",
		"event_id": "chapter_card_35",
		"queue": [],
		"phase": "chapter",
	}
	_expect(SaveManager.save_game(CONTRACT_SLOT, context, {
		"label": "Chapter 3 QA", "qa_fixture": true,
	}), "slot 10 could not be written")
	var info := SaveManager.get_save_info(CONTRACT_SLOT)
	var current_identity := SaveManager.save_identity_fields()
	_expect(int(info.get("chapter", 0)) == 3, "slot metadata chapter is not derived from week 97")
	_expect(str(info.get("event_id", "")) == "chapter_card_35",
		"slot metadata lost the StoryMode event")
	_expect(bool(info.get("qa_fixture", false)), "slot metadata lost the QA marker")
	_expect(bool(info.get("compatible", false)),
		"current save was not marked compatible")
	_expect(info.get("source_identity", {}) == current_identity,
		"slot diagnostics drifted from the current artifact identity")
	_expect(SaveManager.load_game(CONTRACT_SLOT), "slot 10 could not be loaded")
	_expect(SaveManager.loaded_save_identity() == current_identity,
		"loaded save identity did not round-trip")
	_expect(SaveManager.loaded_scene_path() == "res://scenes/StoryMode.tscn",
		"StoryMode save routes to the wrong scene")
	_expect(str(SaveManager.peek_loaded_resume_context().get("phase", "")) == "chapter",
		"StoryMode resume payload was not retained")
	SaveManager.clear_loaded_resume_context()
	_check_durable_save_failure_and_retry()

	var legacy_payload := {
		"version": 3,
		"narrative_rhythm_version": SaveManager.NARRATIVE_RHYTHM_VERSION,
		"saved_at": "2026-07-24T00:00:00",
		"state": GameState.serialize(),
	}
	var legacy_file := FileAccess.open(SaveManager.slot_path(LEGACY_SLOT), FileAccess.WRITE)
	_expect(legacy_file != null, "legacy fixture could not be opened")
	if legacy_file != null:
		legacy_file.store_string(JSON.stringify(legacy_payload))
		legacy_file.close()
	_expect(SaveManager.load_game(LEGACY_SLOT), "v3 save no longer loads")
	_expect(SaveManager.loaded_scene_path() == "res://scenes/MainGame.tscn",
		"v3 save should fall back to MainGame")
	_expect(SaveManager.peek_loaded_resume_context().is_empty(),
		"v3 save invented a StoryMode resume payload")
	_check_build_identity_compatibility(legacy_payload)
	_check_legacy_father_reason_flag_migration()

func _check_legacy_father_reason_flag_migration() -> void:
	var current_state: Dictionary = GameState.serialize().duplicate(true)
	var legacy_state: Dictionary = current_state.duplicate(true)
	var legacy_flags: Dictionary = legacy_state.get("flags", {}).duplicate(true)
	legacy_flags.erase("father_heard_gangnam_reason")
	legacy_flags[GameState.LEGACY_FATHER_REASON_FLAG] = true
	legacy_state["flags"] = legacy_flags
	GameState.load_from_dict(legacy_state)
	_expect(bool(GameState.flags.get("father_heard_gangnam_reason", false)),
		"legacy father reflection did not migrate to the authored conversation receipt")
	_expect(not GameState.flags.has(GameState.LEGACY_FATHER_REASON_FLAG),
		"legacy father reflection alias survived normalization")
	GameState.load_from_dict(current_state)

func _check_build_identity_compatibility(legacy_payload: Dictionary) -> void:
	var full_identity := {
		"game_version": "0.1.0-dev",
		"build_id": "full-build",
		"build_flavor": "full",
		"save_namespace": "legacy",
	}
	var demo_identity := full_identity.duplicate(true)
	demo_identity["build_id"] = "demo-build"
	demo_identity["build_flavor"] = "demo"
	var playtest_identity := full_identity.duplicate(true)
	playtest_identity["build_id"] = "v2-build"
	playtest_identity["build_flavor"] = "core_loop_v2_playtest"
	playtest_identity["save_namespace"] = "core_loop_v2_playtest_v1"

	var demo_payload := {
		"version": SaveManager.SAVE_VERSION,
		"game_version": "0.1.0-dev",
		"build_id": "older-demo-build",
		"build_flavor": "demo",
		"save_namespace": "legacy",
	}
	var week_24_state := {"turn": 24}
	var demo_to_full := SaveManager.inspect_payload_compatibility(
		demo_payload, week_24_state, full_identity)
	_expect(bool(demo_to_full.get("compatible", false)),
		"full build rejected the intended 24-week demo carryover")
	_expect(demo_to_full.get("warnings", []).has("demo_save_in_full_build"),
		"demo-to-full carryover lost its diagnostic warning")

	var full_payload := demo_payload.duplicate(true)
	full_payload["build_flavor"] = "full"
	var full_to_demo := SaveManager.inspect_payload_compatibility(
		full_payload, week_24_state, demo_identity)
	_expect(not bool(full_to_demo.get("compatible", true))
			and str(full_to_demo.get("reason", "")) == "full_save_in_demo",
		"24-week demo accepted an explicitly full-build save")

	var old_to_demo := SaveManager.inspect_payload_compatibility(
		legacy_payload, week_24_state, demo_identity)
	_expect(bool(old_to_demo.get("compatible", false)),
		"24-week demo rejected an identity-less legacy save within its cutoff")
	var old_past_demo := SaveManager.inspect_payload_compatibility(
		legacy_payload, {"turn": 25}, demo_identity)
	_expect(not bool(old_past_demo.get("compatible", true))
			and str(old_past_demo.get("reason", "")) == "demo_turn_limit",
		"24-week demo accepted a legacy save beyond Week 24")

	var v2_payload := demo_payload.duplicate(true)
	v2_payload["build_flavor"] = "core_loop_v2_playtest"
	v2_payload["save_namespace"] = "core_loop_v2_playtest_v1"
	_expect(bool(SaveManager.inspect_payload_compatibility(
		v2_payload, week_24_state, playtest_identity).get("compatible", false)),
		"V2 playtest rejected its own namespace")
	var v2_past_demo := SaveManager.inspect_payload_compatibility(
		v2_payload, {"turn": 25}, playtest_identity)
	_expect(not bool(v2_past_demo.get("compatible", true))
			and str(v2_past_demo.get("reason", "")) == "demo_turn_limit",
		"V2 playtest accepted its own save beyond Week 24")
	var v2_completion_state := {
		"turn": GameState.DEMO_TURN_LIMIT + 1,
		"core_loop_v2_state": {
			"enabled": true,
			"prototype_complete": true,
			"development_cap_week": GameState.DEMO_TURN_LIMIT,
			"completed_through_week": GameState.DEMO_TURN_LIMIT,
			"completed_at_turn": GameState.DEMO_TURN_LIMIT + 1,
			"prototype_completed_at_turn": GameState.DEMO_TURN_LIMIT + 1,
			"completed_turns": range(1, GameState.DEMO_TURN_LIMIT + 1),
		},
	}
	_expect(bool(SaveManager.inspect_payload_compatibility(
			v2_payload, v2_completion_state,
			playtest_identity).get("compatible", false)),
		"V2 playtest rejected its sealed Week-24 completion save at turn 25")
	var persisted_completion_state: Variant = JSON.parse_string(
		JSON.stringify(v2_completion_state))
	_expect(persisted_completion_state is Dictionary \
			and bool(SaveManager.inspect_payload_compatibility(
				v2_payload, persisted_completion_state as Dictionary,
				playtest_identity).get("compatible", false)),
		"V2 completion cutoff did not survive JSON numeric round-trip")
	_expect(not bool(SaveManager.inspect_payload_compatibility(
			demo_payload, v2_completion_state,
			demo_identity).get("compatible", true)),
		"retail demo flavor accepted the playtest-only turn-25 completion exception")
	_expect(not bool(SaveManager.inspect_payload_compatibility(
			legacy_payload, v2_completion_state,
			demo_identity).get("compatible", true)),
		"identity-less legacy payload accepted the playtest-only completion exception")
	for missing_receipt in [
		"prototype_complete", "development_cap_week",
		"completed_through_week", "completed_at_turn",
		"prototype_completed_at_turn", "completed_turns",
	]:
		var malformed_completion := v2_completion_state.duplicate(true)
		(malformed_completion["core_loop_v2_state"] as Dictionary).erase(
			missing_receipt)
		_expect(not bool(SaveManager.inspect_payload_compatibility(
				v2_payload, malformed_completion,
				playtest_identity).get("compatible", true)),
			"V2 turn-25 save bypassed the cutoff without %s" % missing_receipt)
	var malformed_completion_values := [
		["turn", 25.5, false],
		["turn", "25", false],
		["enabled", "true", true],
		["prototype_complete", 1, true],
		["development_cap_week", 24.5, true],
		["completed_through_week", "24", true],
		["completed_at_turn", 25.5, true],
		["prototype_completed_at_turn", "25", true],
		["completed_turns", range(1, GameState.DEMO_TURN_LIMIT), true],
	]
	for malformed_spec in malformed_completion_values:
		var malformed_completion := v2_completion_state.duplicate(true)
		var key := str(malformed_spec[0])
		if bool(malformed_spec[2]):
			(malformed_completion["core_loop_v2_state"] as Dictionary)[key] = \
				malformed_spec[1]
		else:
			malformed_completion[key] = malformed_spec[1]
		_expect(not bool(SaveManager.inspect_payload_compatibility(
				v2_payload, malformed_completion,
				playtest_identity).get("compatible", true)),
			"V2 turn-25 exception coerced malformed %s" % key)
	var malformed_completed_turns := v2_completion_state.duplicate(true)
	var fractional_turns: Array = range(1, GameState.DEMO_TURN_LIMIT + 1)
	fractional_turns[-1] = float(GameState.DEMO_TURN_LIMIT) + 0.5
	(malformed_completed_turns["core_loop_v2_state"] as Dictionary)[
		"completed_turns"] = fractional_turns
	_expect(not bool(SaveManager.inspect_payload_compatibility(
			v2_payload, malformed_completed_turns,
			playtest_identity).get("compatible", true)),
		"V2 turn-25 exception coerced a fractional completed week")
	_expect(not bool(SaveManager.inspect_payload_compatibility(
		v2_payload, week_24_state, full_identity).get("compatible", true)),
		"retail/full accepted a V2 playtest save")
	_expect(not bool(SaveManager.inspect_payload_compatibility(
		demo_payload, week_24_state, playtest_identity).get("compatible", true)),
		"V2 playtest accepted a retail/demo namespace")

	var build_mismatch := SaveManager.inspect_payload_compatibility(
		demo_payload, week_24_state, demo_identity)
	_expect(bool(build_mismatch.get("compatible", false))
			and build_mismatch.get("warnings", []).has("build_id_mismatch"),
		"build-ID drift became a compatibility block or lost its warning")
	var malformed := demo_payload.duplicate(true)
	malformed["build_id"] = ""
	_expect(not bool(SaveManager.inspect_payload_compatibility(
		malformed, week_24_state, demo_identity).get("compatible", true)),
		"blank build identity was not rejected")
	var fractional_version := demo_payload.duplicate(true)
	fractional_version["version"] = 4.5
	var fractional_diagnostic := SaveManager.inspect_payload_compatibility(
		fractional_version, week_24_state, demo_identity)
	_expect(not bool(fractional_diagnostic.get("compatible", true))
			and str(fractional_diagnostic.get("reason", "")) == "invalid_save_version",
		"fractional save schema was silently rounded and accepted")
	var forged_unknown := demo_payload.duplicate(true)
	for key in ["game_version", "build_id", "build_flavor", "save_namespace"]:
		forged_unknown[key] = "unknown"
	var unknown_diagnostic := SaveManager.inspect_payload_compatibility(
		forged_unknown, week_24_state, full_identity)
	_expect(not bool(unknown_diagnostic.get("compatible", true))
			and str(unknown_diagnostic.get("reason", "")) == "invalid_identity_field",
		"explicit unknown identity values bypassed legacy-save warnings")

	var future_state: Dictionary = GameState.serialize()
	future_state["money"] = 987654321.0
	var future_payload := {
		"version": SaveManager.SAVE_VERSION + 1,
		"state": future_state,
	}
	var future_file := FileAccess.open(
		SaveManager.slot_path(LEGACY_SLOT), FileAccess.WRITE)
	_expect(future_file != null, "future-version fixture could not be opened")
	if future_file != null:
		future_file.store_string(JSON.stringify(future_payload))
		future_file.close()
	GameState.money = 123456.0
	_expect(not SaveManager.load_game(LEGACY_SLOT),
		"future save schema was loaded instead of rejected")
	_expect(is_equal_approx(GameState.money, 123456.0),
		"future save rejection mutated GameState before compatibility checks")

func _check_durable_save_failure_and_retry() -> void:
	var path := SaveManager.slot_path(CONTRACT_SLOT)
	var temporary_path := "%s.tmp" % path
	var backup_path := "%s.bak" % path
	var backup_temporary_path := "%s.tmp" % backup_path
	var temporary_absolute := ProjectSettings.globalize_path(temporary_path)
	_expect(not FileAccess.file_exists(temporary_path) \
			and not DirAccess.dir_exists_absolute(temporary_absolute),
		"save QA started with a stale slot-10 temporary path")
	if FileAccess.file_exists(temporary_path) \
			or DirAccess.dir_exists_absolute(temporary_absolute):
		return
	var before := FileAccess.get_file_as_bytes(path)
	var make_error := DirAccess.make_dir_absolute(temporary_absolute)
	_expect(make_error == OK,
		"save QA could not create its temporary-write blocker")
	if make_error != OK:
		return
	var original_money := float(GameState.money)
	GameState.money = original_money + 123_456.0
	var failure_signals: Array[bool] = []
	var failure_callback := func(success: bool, emitted_slot: int) -> void:
		if emitted_slot == CONTRACT_SLOT:
			failure_signals.append(success)
	SaveManager.save_completed.connect(failure_callback)
	var blocked_result := SaveManager.save_game(CONTRACT_SLOT)
	SaveManager.save_completed.disconnect(failure_callback)
	_expect(not blocked_result and failure_signals == [false],
		"blocked save did not return and signal one failure")
	_expect(FileAccess.get_file_as_bytes(path) == before,
		"failed save damaged the previous slot bytes")
	_expect(DirAccess.remove_absolute(temporary_absolute) == OK,
		"save QA could not remove its temporary-write blocker")

	var retry_signals: Array[bool] = []
	var retry_callback := func(success: bool, emitted_slot: int) -> void:
		if emitted_slot == CONTRACT_SLOT:
			retry_signals.append(success)
	SaveManager.save_completed.connect(retry_callback)
	var retry_result := SaveManager.save_game(CONTRACT_SLOT)
	SaveManager.save_completed.disconnect(retry_callback)
	var after := FileAccess.get_file_as_bytes(path)
	var retry_payload: Variant = JSON.parse_string(after.get_string_from_utf8())
	_expect(retry_result and retry_signals == [true],
		"save retry did not return and signal one success")
	_expect(after != before and not FileAccess.file_exists(temporary_path),
		"save retry did not replace the slot or left its temporary file")
	_expect(FileAccess.get_file_as_bytes(backup_path) == before,
		"save retry did not preserve the prior valid primary as a backup")
	_expect(retry_payload is Dictionary \
			and (retry_payload as Dictionary).get("state", null) is Dictionary \
			and is_equal_approx(float(((retry_payload as Dictionary)["state"] \
				as Dictionary).get("money", 0.0)), GameState.money),
		"save retry did not leave a readable current-state payload")

	# A backup-stage failure must stop before the primary replacement. This is
	# the deterministic counterpart of a Windows/cloud lock on the sidecar.
	var backup_temporary_absolute := ProjectSettings.globalize_path(
		backup_temporary_path)
	_expect(not FileAccess.file_exists(backup_temporary_path) \
			and not DirAccess.dir_exists_absolute(backup_temporary_absolute),
		"save QA started with a stale backup temporary path")
	if not FileAccess.file_exists(backup_temporary_path) \
			and not DirAccess.dir_exists_absolute(backup_temporary_absolute):
		var backup_block_error := DirAccess.make_dir_absolute(
			backup_temporary_absolute)
		_expect(backup_block_error == OK,
			"save QA could not create its backup-write blocker")
		if backup_block_error == OK:
			var preserved_primary := FileAccess.get_file_as_bytes(path)
			var preserved_backup := FileAccess.get_file_as_bytes(backup_path)
			GameState.money += 111_111.0
			var backup_failure_signals: Array[bool] = []
			var backup_failure_callback := func(
					success: bool, emitted_slot: int) -> void:
				if emitted_slot == CONTRACT_SLOT:
					backup_failure_signals.append(success)
			SaveManager.save_completed.connect(backup_failure_callback)
			var backup_blocked_result := SaveManager.save_game(CONTRACT_SLOT)
			SaveManager.save_completed.disconnect(backup_failure_callback)
			_expect(not backup_blocked_result \
					and backup_failure_signals == [false],
				"blocked backup stage did not return and signal one failure")
			_expect(FileAccess.get_file_as_bytes(path) == preserved_primary \
					and FileAccess.get_file_as_bytes(backup_path) == preserved_backup,
				"backup-stage failure changed the primary or last verified backup")
			_expect(DirAccess.remove_absolute(backup_temporary_absolute) == OK,
				"save QA could not remove its backup-write blocker")

	# Produce one newer primary so its sidecar is the exact state recovery must
	# load after the primary vanishes between DeleteFileW and MoveFileW.
	GameState.money = original_money + 234_567.0
	_expect(SaveManager.save_game(CONTRACT_SLOT),
		"recovery fixture could not advance the primary save")
	var recovery_backup := FileAccess.get_file_as_bytes(backup_path)
	var recovery_payload: Variant = JSON.parse_string(
		recovery_backup.get_string_from_utf8())
	_expect(recovery_payload is Dictionary \
			and (recovery_payload as Dictionary).get("state", null) is Dictionary,
		"recovery fixture backup is not a readable save payload")
	var recovery_money := float(
		((recovery_payload as Dictionary).get("state", {}) as Dictionary).get(
			"money", 0.0)) if recovery_payload is Dictionary else 0.0
	_expect(DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) == OK,
		"save QA could not simulate a missing primary after replacement failure")
	_expect(SaveManager.has_save(CONTRACT_SLOT),
		"a verified backup alone did not keep the slot discoverable")
	var recovery_info := SaveManager.get_save_info(CONTRACT_SLOT)
	_expect(bool(recovery_info.get("recovered_from_backup", false)),
		"slot info did not disclose that only the backup was readable")
	GameState.money = -987_654.0
	var recovery_signals: Array[bool] = []
	var recovery_callback := func(success: bool, emitted_slot: int) -> void:
		if emitted_slot == CONTRACT_SLOT:
			recovery_signals.append(success)
	SaveManager.load_completed.connect(recovery_callback)
	var recovered := SaveManager.load_game(CONTRACT_SLOT)
	SaveManager.load_completed.disconnect(recovery_callback)
	_expect(recovered and recovery_signals == [true],
		"missing-primary recovery did not return and signal one successful load")
	_expect(is_equal_approx(GameState.money, recovery_money),
		"missing-primary recovery loaded a state other than the verified backup")
	_expect(FileAccess.get_file_as_bytes(path) == recovery_backup,
		"missing-primary recovery did not restore the canonical primary bytes")
	_expect(bool(SaveManager.last_load_diagnostic().get(
		"recovered_from_backup", false)),
		"missing-primary recovery omitted its diagnostic")

	# A parse-corrupt primary follows the same recovery path. A well-formed but
	# incompatible future save remains a deliberate rejection in the next test.
	var corrupt_file := FileAccess.open(path, FileAccess.WRITE)
	_expect(corrupt_file != null,
		"save QA could not create its corrupt-primary recovery fixture")
	if corrupt_file != null:
		corrupt_file.store_string("{truncated")
		corrupt_file.close()
		GameState.money = -123_456.0
		_expect(SaveManager.load_game(CONTRACT_SLOT),
			"parse-corrupt primary did not recover from the verified backup")
		_expect(is_equal_approx(GameState.money, recovery_money) \
				and FileAccess.get_file_as_bytes(path) == recovery_backup,
			"parse-corrupt primary recovery did not restore the backup exactly")

	# Slot discovery and loading must select the same compatible candidate. A
	# JSON-valid primary with an unsupported identity must not disable a slot
	# whose verified backup is still compatible.
	var incompatible_payload_value: Variant = JSON.parse_string(
		recovery_backup.get_string_from_utf8())
	var incompatible_payload: Dictionary = (
		(incompatible_payload_value as Dictionary).duplicate(true)
		if incompatible_payload_value is Dictionary else {})
	incompatible_payload["build_flavor"] = "unsupported-fixture"
	var incompatible_file := FileAccess.open(path, FileAccess.WRITE)
	_expect(incompatible_file != null,
		"save QA could not create its compatibility-failing primary")
	if incompatible_file != null:
		incompatible_file.store_string(JSON.stringify(incompatible_payload))
		incompatible_file.close()
		var before_info_state: Dictionary = GameState.serialize().duplicate(true)
		var compatible_backup_info := SaveManager.get_save_info(CONTRACT_SLOT)
		_expect(bool(compatible_backup_info.get("compatible", false)) \
				and bool(compatible_backup_info.get(
					"recovered_from_backup", false)) \
				and str(compatible_backup_info.get("recovery_reason", "")) \
					== "unknown_build_flavor" \
				and is_equal_approx(float(compatible_backup_info.get(
					"money", 0.0)), recovery_money),
			"slot info hid a compatible backup behind an incompatible primary")
		_expect(GameState.serialize() == before_info_state,
			"slot info compatibility recovery mutated live GameState")
		GameState.money = -222_222.0
		_expect(SaveManager.load_game(CONTRACT_SLOT) \
				and is_equal_approx(GameState.money, recovery_money) \
				and FileAccess.get_file_as_bytes(path) == recovery_backup,
			"load and slot info disagreed on compatibility backup recovery")
		# A later save must never replace the compatible backup with the rejected
		# primary generation before the new primary is installed and verified. Force
		# the replacement boundary to fail after candidate selection, then retry.
		var incompatible_rewrite := FileAccess.open(path, FileAccess.WRITE)
		_expect(incompatible_rewrite != null,
			"save QA could not recreate its incompatible-primary fixture")
		if incompatible_rewrite != null:
			incompatible_rewrite.store_string(JSON.stringify(incompatible_payload))
			incompatible_rewrite.close()
			GameState.money = original_money + 345_678.0
			SaveManager.set_meta("_qa_fail_next_primary_replacement", true)
			var replacement_failed := SaveManager.save_game(CONTRACT_SLOT)
			_expect(not replacement_failed \
					and not SaveManager.has_meta(
						"_qa_fail_next_primary_replacement") \
					and FileAccess.get_file_as_bytes(backup_path) == recovery_backup \
					and FileAccess.get_file_as_bytes(path) == recovery_backup,
				"failed replacement destroyed the compatible backup generation")
			var incompatible_retry := FileAccess.open(path, FileAccess.WRITE)
			_expect(incompatible_retry != null,
				"save QA could not recreate its incompatible retry primary")
			if incompatible_retry != null:
				incompatible_retry.store_string(JSON.stringify(incompatible_payload))
				incompatible_retry.close()
				var retry_info := SaveManager.get_save_info(CONTRACT_SLOT)
				_expect(bool(retry_info.get("compatible", false)) \
						and bool(retry_info.get(
							"recovered_from_backup", false)) \
						and str(retry_info.get("recovery_reason", "")) \
							== "unknown_build_flavor",
					"failed replacement no longer exposed its compatible backup")
				GameState.money = original_money + 345_678.0
				_expect(SaveManager.save_game(CONTRACT_SLOT) \
						and FileAccess.get_file_as_bytes(backup_path) \
							== recovery_backup,
					"save retry overwrote the last compatible backup")
			# Restore the canonical recovery generation for the wrong-shape fixtures
			# below so each candidate check starts from the same verified backup.
			var recovery_restore := FileAccess.open(path, FileAccess.WRITE)
			_expect(recovery_restore != null,
				"save QA could not restore its canonical recovery primary")
			if recovery_restore != null:
				recovery_restore.store_buffer(recovery_backup)
				recovery_restore.close()

	# A structurally valid JSON object may still carry an impossible typed state.
	# Reject it before GameState.load_from_dict can assign Array into Dictionary,
	# while keeping the compatible backup visible and loadable.
	var wrong_shape_payload_value: Variant = JSON.parse_string(
		recovery_backup.get_string_from_utf8())
	var wrong_shape_payload: Dictionary = (
		(wrong_shape_payload_value as Dictionary).duplicate(true)
		if wrong_shape_payload_value is Dictionary else {})
	var wrong_shape_state: Dictionary = (
		(wrong_shape_payload.get("state", {}) as Dictionary).duplicate(true)
		if wrong_shape_payload.get("state", {}) is Dictionary else {})
	wrong_shape_state["core_loop_v2_state"] = []
	wrong_shape_payload["state"] = wrong_shape_state
	var wrong_shape_file := FileAccess.open(path, FileAccess.WRITE)
	_expect(wrong_shape_file != null,
		"save QA could not create its wrong-typed primary")
	if wrong_shape_file != null:
		wrong_shape_file.store_string(JSON.stringify(wrong_shape_payload))
		wrong_shape_file.close()
		GameState.money = -333_333.0
		var before_shape_info: Dictionary = GameState.serialize().duplicate(true)
		var wrong_shape_info := SaveManager.get_save_info(CONTRACT_SLOT)
		_expect(bool(wrong_shape_info.get("compatible", false)) \
				and bool(wrong_shape_info.get("recovered_from_backup", false)) \
				and str(wrong_shape_info.get("recovery_reason", "")) \
					== "invalid_state_field" \
				and str(wrong_shape_info.get("diagnostic", "")) \
					== "core_loop_v2_state:expected_dictionary" \
				and is_equal_approx(float(wrong_shape_info.get(
					"money", 0.0)), recovery_money),
			"slot info selected a JSON-valid primary with a wrong typed state")
		_expect(GameState.serialize() == before_shape_info,
			"wrong-shape slot inspection mutated live GameState")
		_expect(SaveManager.load_game(CONTRACT_SLOT) \
				and is_equal_approx(GameState.money, recovery_money) \
				and FileAccess.get_file_as_bytes(path) == recovery_backup,
			"wrong-shape primary did not recover through the verified backup")

	# `turn` also gates compatibility and direct assignment. Give its malformed
	# present value the same invalid_state_field recovery contract rather than
	# allowing invalid_turn to hide an otherwise compatible verified backup.
	var wrong_turn_payload_value: Variant = JSON.parse_string(
		recovery_backup.get_string_from_utf8())
	var wrong_turn_payload: Dictionary = (
		(wrong_turn_payload_value as Dictionary).duplicate(true)
		if wrong_turn_payload_value is Dictionary else {})
	var wrong_turn_state: Dictionary = (
		(wrong_turn_payload.get("state", {}) as Dictionary).duplicate(true)
		if wrong_turn_payload.get("state", {}) is Dictionary else {})
	wrong_turn_state["turn"] = "1"
	wrong_turn_payload["state"] = wrong_turn_state
	var wrong_turn_file := FileAccess.open(path, FileAccess.WRITE)
	_expect(wrong_turn_file != null,
		"save QA could not create its wrong-typed turn primary")
	if wrong_turn_file != null:
		wrong_turn_file.store_string(JSON.stringify(wrong_turn_payload))
		wrong_turn_file.close()
		GameState.money = -444_444.0
		var before_turn_info: Dictionary = GameState.serialize().duplicate(true)
		var wrong_turn_info := SaveManager.get_save_info(CONTRACT_SLOT)
		_expect(bool(wrong_turn_info.get("compatible", false)) \
				and bool(wrong_turn_info.get("recovered_from_backup", false)) \
				and str(wrong_turn_info.get("recovery_reason", "")) \
					== "invalid_state_field" \
				and str(wrong_turn_info.get("diagnostic", "")) \
					== "turn:expected_finite_integer",
			"wrong-typed turn hid its compatible verified backup")
		_expect(GameState.serialize() == before_turn_info,
			"wrong-turn slot inspection mutated live GameState")
		_expect(SaveManager.load_game(CONTRACT_SLOT) \
				and is_equal_approx(GameState.money, recovery_money) \
				and FileAccess.get_file_as_bytes(path) == recovery_backup,
			"wrong-typed turn did not recover through the verified backup")

	# Missing top-level fields remain a supported legacy shape; validation only
	# rejects a present field whose broad serialized type is impossible.
	var minimal_legacy_payload := {
		"version": SaveManager.SAVE_VERSION,
		"slot": CONTRACT_SLOT,
		"saved_at": "2026-08-11T00:00:00",
		"state": {"turn": 1},
	}
	minimal_legacy_payload.merge(SaveManager.save_identity_fields(), true)
	var minimal_legacy_file := FileAccess.open(path, FileAccess.WRITE)
	_expect(minimal_legacy_file != null,
		"save QA could not create its missing-key legacy primary")
	if minimal_legacy_file != null:
		minimal_legacy_file.store_string(JSON.stringify(minimal_legacy_payload))
		minimal_legacy_file.close()
		var minimal_legacy_info := SaveManager.get_save_info(CONTRACT_SLOT)
		_expect(bool(minimal_legacy_info.get("compatible", false)) \
				and not bool(minimal_legacy_info.get(
					"recovered_from_backup", true)) \
				and str(minimal_legacy_info.get("recovery_reason", "")).is_empty(),
			"missing-key legacy primary was rejected by typed-field validation")
	GameState.money = original_money

func _check_main_game_save_failure_feedback() -> void:
	var previous_language := LocaleManager.language
	LocaleManager.set_language("en")
	GameState.start_new_game()
	_expect(SaveManager.save_game(TEST_SLOT),
		"MainGame save feedback fixture could not create its durable slot")
	var main_game: Control = MAIN_GAME_SCENE.instantiate()
	main_game.set_meta("_screenshot_qa_static_surface", true)
	add_child(main_game)
	await get_tree().process_frame
	await get_tree().process_frame

	var log_size_before := GameState.action_log.size()
	SaveManager.set_meta("_qa_fail_next_primary_replacement", true)
	main_game.call("_on_save_pressed")
	await get_tree().process_frame
	_expect(GameState.action_log.size() == log_size_before \
			and _latest_main_game_toast(main_game) \
				== "Save failed. Please try again.",
		"quick-save failure reported success or wrote its success log")

	main_game.call("_open_modal", "Save fixture", false, "manual_save_fixture")
	SaveManager.set_meta("_qa_fail_next_primary_replacement", true)
	main_game.call("_save_to_slot", TEST_SLOT)
	await get_tree().process_frame
	var modal_layer := main_game.get("modal_layer") as Control
	_expect(is_instance_valid(modal_layer) and modal_layer.visible \
			and str(main_game.get("_modal_kind")) == "manual_save_fixture" \
			and _latest_main_game_toast(main_game) \
				== "Save failed. Please try again.",
		"slot-save failure closed its modal or reported success")

	main_game.call("_save_to_slot", TEST_SLOT)
	await get_tree().process_frame
	_expect(is_instance_valid(modal_layer) and not modal_layer.visible \
			and _latest_main_game_toast(main_game) == "Saved to slot 1",
		"successful slot save did not close the modal and report success")
	if main_game.get_parent() != null:
		main_game.get_parent().remove_child(main_game)
	main_game.free()
	BGMPlayer.stop()
	LocaleManager.set_language(previous_language)
	await get_tree().process_frame

func _latest_main_game_toast(main_game: Control) -> String:
	var container := main_game.get("_toast_container") as Control
	if not is_instance_valid(container) or container.get_child_count() == 0:
		return ""
	var toast := container.get_child(container.get_child_count() - 1)
	var label := toast.get("label") as Label if is_instance_valid(toast) else null
	return label.text if is_instance_valid(label) else ""

func _check_prose_resume() -> void:
	GameState.start_new_game()
	if not await _spawn_story("story_knee_choice"):
		return
	_story.call("_set_story_text_size", "large")
	_story.call("_complete_typing")
	_story.call("_on_advance")
	var partial_position := mini(
		7, maxi(1, str(_story.get("_type_full")).length() - 1))
	_story.set("_type_pos", partial_position)
	(_story.get("_body_lbl") as RichTextLabel).text = str(
		_story.get("_type_full")).substr(0, partial_position)
	var saved_prefix := str(_story.call(
		"_dialogue_log_source_text",
		_story.call("_story_source_paragraph_index", int(_story.get("_para_index"))),
		int(_story.get("_para_index")), true))
	var context: Dictionary = _story.call("build_save_resume_context")
	_expect(str(context.get("phase", "")) == "prose", "prose save reported the wrong phase")
	_expect(context.has("source_paragraph_index") and context.has("source_text_progress"),
		"prose save omitted source-based text progress")
	var saved_source_index := int(context.get("source_paragraph_index", -1))
	var saved_source_progress := float(context.get("source_text_progress", -1.0))
	var prose_log: Dictionary = context.get("dialogue_log", {})
	var prose_entries: Array = prose_log.get("entries", [])
	_expect(int(prose_log.get("schema", 0)) == 1 and prose_entries.size() == 1,
		"prose save did not retain the one fully read dialogue block")
	_expect(SaveManager.save_game(TEST_SLOT, context), "prose save failed")
	await _free_story()
	# Pagination is presentation state, not narrative state. Loading under a
	# different text size must return to the same authored source position.
	SaveManager.set_setting("story_text_size", "small")
	_expect(SaveManager.load_game(TEST_SLOT), "prose save could not be reloaded")
	if not await _spawn_loaded_story():
		return
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) == "story_knee_choice",
		"prose resume loaded the wrong event")
	var restored_page := int(_story.get("_para_index"))
	var restored_source_index := int(_story.call(
		"_story_source_paragraph_index", restored_page))
	_expect(restored_source_index == saved_source_index,
		"prose resume crossed into a different authored paragraph")
	_expect(bool(_story.get("_typing")), "partially typed prose did not resume typing")
	var restored_full := str(_story.get("_type_full"))
	var restored_ratio := (
		float(_story.get("_type_pos")) / float(maxi(1, restored_full.length())))
	var restored_source_progress := float(_story.call(
		"_story_source_page_progress", restored_page, restored_ratio))
	_expect(absf(restored_source_progress - saved_source_progress) <= 0.03,
		"text-size change moved the prose resume point")
	var restored_prefix := str(_story.call(
		"_dialogue_log_source_text", restored_source_index, restored_page, true))
	_expect(restored_prefix.length() <= saved_prefix.length() + 2,
		"text-size change exposed prose beyond the saved point")
	_expect((_story.get("_dialogue_log_entries") as Array) == prose_entries,
		"prose resume changed or duplicated Dialogue History")

func _check_choice_and_result_resume() -> void:
	if not is_instance_valid(_story):
		return
	_story.call("_finish_story_scene_transition")
	_story.set("_para_index", (_story.get("_paragraphs") as Array).size() - 1)
	_story.call("_complete_typing")
	_story.call("_show_choices")
	var choice_context: Dictionary = _story.call("build_save_resume_context")
	_expect(str(choice_context.get("phase", "")) == "choices",
		"choice save reported the wrong phase")
	var choice_log_before: Array = (
		(choice_context.get("dialogue_log", {}) as Dictionary).get("entries", []) as Array
	).duplicate(true)
	_expect(SaveManager.save_game(TEST_SLOT, choice_context), "choice save failed")
	await _free_story()
	_expect(SaveManager.load_game(TEST_SLOT), "choice save could not be reloaded")
	if not await _spawn_loaded_story():
		return
	_expect(bool(_story.get("_showing_choices")), "choice resume did not restore the choice rail")
	_expect((_story.get("_dialogue_log_entries") as Array) == choice_log_before,
		"choice resume changed Dialogue History")

	var mental_before := int(GameState.mental)
	_story.call("_on_choice", 0)
	var mental_after := int(GameState.mental)
	_expect(mental_after == mental_before - 2, "fixture choice did not apply its effect once")
	var result_context: Dictionary = _story.call("build_save_resume_context")
	_expect(str(result_context.get("phase", "")) == "result",
		"result save reported the wrong phase")
	var result_log_before: Array = (
		(result_context.get("dialogue_log", {}) as Dictionary).get("entries", []) as Array
	).duplicate(true)
	_expect(_count_dialogue_kind(result_log_before, "choice") == 1,
		"result save omitted or duplicated the chosen option in Dialogue History")
	_expect(SaveManager.save_game(TEST_SLOT, result_context), "result save failed")
	await _free_story()
	_expect(SaveManager.load_game(TEST_SLOT), "result save could not be reloaded")
	if not await _spawn_loaded_story():
		return
	_expect(bool(_story.get("_pending_after_result")), "result resume skipped the result prose")
	_expect(int(_story.get("_pending_result_choice_index")) == 0,
		"result resume lost the selected choice")
	_expect(int(GameState.mental) == mental_after,
		"result resume applied the selected choice a second time")
	_expect(bool(GameState.flags.get("knee_day_faced", false)),
		"result resume lost the selected route flag")
	_expect((_story.get("_dialogue_log_entries") as Array) == result_log_before,
		"result resume changed or duplicated Dialogue History")


func _check_result_choice_receipt_index_guard() -> void:
	for receipt_case_value in [
		"wrong_index", "wrong_index_fatal", "missing_event_fatal",
		"legacy_duplicate",
	]:
		var receipt_case := str(receipt_case_value)
		var fatal_case: bool = receipt_case in [
			"wrong_index_fatal", "missing_event_fatal",
		]
		await _free_story()
		LocaleManager.set_language("ko")
		GameState.start_new_game()
		GameState.turn = 40
		if not await _spawn_story("story_knee_choice"):
			return
		_story.set("_para_index", (_story.get("_paragraphs") as Array).size() - 1)
		_story.call("_complete_typing")
		_story.call("_show_choices")
		_story.call("_on_choice", 0)
		var forged_context: Dictionary = _story.call(
			"build_save_resume_context")
		var choices: Array = (_story.get("_current") as Dictionary).get(
			"choices", [])
		_expect(choices.size() > 1 \
				and str(forged_context.get("phase", "")) == "result",
			"indexed result-guard fixture did not reach a multi-choice result")
		if receipt_case == "missing_event_fatal":
			forged_context["event_id"] = \
				"missing_result_resume_fixture"
		elif receipt_case == "legacy_duplicate":
			# Pre-index saves may use Dialogue History as their compatibility
			# receipt, but only when the current event serial owns one choice.
			var legacy_receipt := GameState.event_log[-1] as Dictionary
			legacy_receipt.erase("choice_index")
			var dialogue_log := (
				forged_context.get("dialogue_log", {}) as Dictionary).duplicate(true)
			var entries: Array = dialogue_log.get("entries", []).duplicate(true)
			for raw_entry in entries.duplicate(true):
				if raw_entry is Dictionary \
						and str((raw_entry as Dictionary).get(
							"kind", "")) == "choice":
					var duplicate_entry := (raw_entry as Dictionary).duplicate(true)
					duplicate_entry["choice_index"] = 1
					entries.append(duplicate_entry)
					break
			dialogue_log["entries"] = entries
			forged_context["dialogue_log"] = dialogue_log
		else:
			forged_context["pending_result_choice_index"] = 1
		forged_context["queue"] = ["chapter_card_35"]
		if fatal_case:
			GameState.health = 0
		_expect(SaveManager.save_game(TEST_SLOT, forged_context),
			"indexed result-guard fixture could not be saved")
		await _free_story()
		_expect(SaveManager.load_game(TEST_SLOT),
			"indexed result-guard fixture could not be loaded")
		var mental_before := int(GameState.mental)
		var health_before := int(GameState.health)
		var money_before := int(GameState.money)
		var tint_before := float(GameState.moral_tint)
		var events_before := int(GameState.events_seen)
		var flags_before: Dictionary = GameState.flags.duplicate(true)
		var event_log_before: Array = GameState.event_log.duplicate(true)
		var action_log_before: Array = GameState.action_log.duplicate(true)
		var commitments_before: Array = \
			GameState.weekly_commitments.duplicate(true)
		_expect(not event_log_before.is_empty() \
				and (
					not (event_log_before[-1] as Dictionary).has("choice_index")
					if receipt_case == "legacy_duplicate" else
					int((event_log_before[-1] as Dictionary).get(
						"choice_index", -1)) == 0),
			"%s receipt fixture had the wrong applied-choice identity" \
				% receipt_case)
		if not await _spawn_loaded_story():
			return
		var restored_id := str(
			(_story.get("_current") as Dictionary).get("id", ""))
		_expect(
			(restored_id.is_empty() and bool(_story.get("_transitioning")))
				if fatal_case else restored_id == "chapter_card_35",
			("fatal forged result rendered a queued sentinel" if fatal_case else
			"%s forged result was rendered or reopened" % receipt_case))
		_expect(not bool(_story.get("_pending_after_result")) \
				and not bool(_story.get("_showing_choices")),
			"forged same-event choice index retained a playable result")
		_expect(int(GameState.mental) == mental_before \
				and int(GameState.health) == health_before \
				and int(GameState.money) == money_before \
				and is_equal_approx(float(GameState.moral_tint), tint_before) \
				and int(GameState.events_seen) == events_before \
				and GameState.flags == flags_before \
				and GameState.event_log == event_log_before \
				and GameState.action_log == action_log_before \
				and GameState.weekly_commitments == commitments_before,
			"forged same-event choice index reapplied or changed run state")


func _check_year_scene_result_resume() -> void:
	await _free_story()
	LocaleManager.set_language("ko")
	GameState.start_new_game()
	GameState.turn = 40
	for scene_id in [
		"story_knee_choice", "arc_daeun_01_meet",
		"arc_sangchul_01_meet", "arc_father_01_call",
	]:
		GameState.record_run_scene_seen(scene_id)
	if not await _spawn_story("arc_year1_scene"):
		return
	var dynamic_choices: Array = (_story.get("_current") as Dictionary).get(
		"choices", [])
	_expect(dynamic_choices.size() >= 3,
		"year-scene result fixture did not materialize three candidates")
	_story.set("_para_index", (_story.get("_paragraphs") as Array).size() - 1)
	_story.call("_complete_typing")
	_story.call("_show_choices")
	_story.call("_on_choice", 2)
	var selected_scene := GameState.get_year_scene_selection(1)
	var result_context: Dictionary = _story.call("build_save_resume_context")
	_expect(not selected_scene.is_empty() \
			and str(result_context.get("phase", "")) == "result" \
			and int(result_context.get(
				"pending_result_choice_index", -1)) == 2,
		"year-scene index 2 did not create a result resume receipt")
	_expect(SaveManager.save_game(TEST_SLOT, result_context),
		"year-scene result fixture could not be saved")
	await _free_story()
	_expect(SaveManager.load_game(TEST_SLOT),
		"year-scene result fixture could not be loaded")
	var event_log_before: Array = GameState.event_log.duplicate(true)
	var events_before := int(GameState.events_seen)
	var year_scenes_before: Dictionary = GameState.year_scenes.duplicate(true)
	if not await _spawn_loaded_story():
		return
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) \
			== "arc_year1_scene" \
			and bool(_story.get("_pending_after_result")) \
			and int(_story.get("_pending_result_choice_index")) == 2,
		"year-scene dynamic result index was skipped on reload")
	_expect(GameState.get_year_scene_selection(1) == selected_scene \
			and GameState.year_scenes == year_scenes_before \
			and int(GameState.events_seen) == events_before \
			and GameState.event_log == event_log_before \
			and not event_log_before.is_empty() \
			and int((event_log_before[-1] as Dictionary).get(
				"choice_index", -1)) == 2,
		"year-scene result reload changed or lost its applied choice receipt")

func _check_father_passed_result_variant_resume() -> void:
	await _free_story()
	LocaleManager.set_language("ko")
	GameState.start_new_game()
	GameState.turn = 189
	GameState.flags.erase("father_passed")
	GameState.flags.erase("arc_father_passing_seen")
	var older_event_log_before := {
		"turn": 188,
		"event_id": "arc_sangchul_year3",
		"choice": "OLDER EVENT CHOICE MUST REMAIN",
		"result": "OLDER EVENT RESULT MUST REMAIN",
	}
	var older_action_log_before := {
		"turn": 188,
		"date": "OLDER ACTION DATE MUST REMAIN",
		"message": "OLDER ACTION MESSAGE MUST REMAIN",
		"type": "event",
	}
	GameState.event_log.append(older_event_log_before.duplicate(true))
	GameState.action_log.append(older_action_log_before.duplicate(true))
	var event_log_prefix_before_choice: Array = \
		GameState.event_log.duplicate(true)
	var action_log_prefix_before_choice: Array = \
		GameState.action_log.duplicate(true)
	if not await _spawn_story("arc_sangchul_year3"):
		return

	# Give this current event a prior serial receipt so the migration must keep
	# older history byte-for-byte while replacing only the stale live article.
	_story.set("_dialogue_log_event_serial", 2)
	_story.set("_dialogue_log_next_serial", 2)
	_story.call("_append_dialogue_log_entry", {
		"event_serial": 1,
		"event_id": "story_knee_choice",
		"kind": "prose",
		"choice_index": -1,
		"source_paragraph_index": 0,
		"page_index": 0,
		"title": "이전 장면",
		"speaker": "",
		"screen_context": "",
		"channel": "in_person",
		"locale": "ko",
		"text": "OLDER SERIAL MUST REMAIN",
	})
	var older_entry_before := (
		(_story.get("_dialogue_log_entries") as Array)[0] as Dictionary
	).duplicate(true)

	_story.set("_para_index", (_story.get("_paragraphs") as Array).size() - 1)
	_story.call("_complete_typing")
	_story.call("_show_choices")
	_story.call("_on_choice", 1)
	_expect(bool(_story.get("_pending_after_result")),
		"Sangchul live fixture did not enter its result phase")
	_expect(GameState.event_log.size() \
				== event_log_prefix_before_choice.size() + 1 \
			and str((GameState.event_log[-1] as Dictionary).get(
				"event_id", "")) == "arc_sangchul_year3" \
			and GameState.action_log.size() \
				== action_log_prefix_before_choice.size() + 1,
		"Sangchul live fixture did not create one current event/action log")
	# Complete every rendered page of the first authored result paragraph so
	# the saved log contains the live Father's spoken response, not only a choice.
	var first_result_source := int(_story.call(
		"_story_source_paragraph_index", int(_story.get("_para_index"))))
	while bool(_story.get("_pending_after_result")):
		_story.call("_complete_typing")
		var current_page := int(_story.get("_para_index"))
		var result_pages: Array = _story.get("_paragraphs")
		if current_page + 1 >= result_pages.size() \
				or int(_story.call(
					"_story_source_paragraph_index", current_page + 1)) \
					!= first_result_source:
			break
		_story.call("_on_advance")

	var live_context: Dictionary = _story.call("build_save_resume_context")
	var live_entries: Array = (
		(live_context.get("dialogue_log", {}) as Dictionary).get(
			"entries", []) as Array)
	var live_current_text := ""
	for raw_live_entry in live_entries:
		if raw_live_entry is Dictionary \
				and int((raw_live_entry as Dictionary).get(
					"event_serial", 0)) == 2:
			live_current_text += " " + str(
				(raw_live_entry as Dictionary).get("text", ""))
	_expect(str(live_context.get("phase", "")) == "result" \
			and int(live_context.get("pending_result_choice_index", -1)) == 1,
		"Sangchul fixture did not save the applied live choice as a result")
	_expect("아버지한테 전화했다" in live_current_text \
			and "아버지가 짧게" in live_current_text,
		"Sangchul fixture did not capture the stale live Father history")

	# This is the damaged/interrupted old-save shape: the result receipt belongs
	# to the living variant, but monotonic death evidence is already authoritative.
	GameState.flags["father_passed"] = true
	var mental_after_choice := int(GameState.mental)
	var tint_after_choice := float(GameState.moral_tint)
	var affinity_after_choice := GameState.get_cast_affinity("father")
	var events_after_choice := int(GameState.events_seen)
	var flags_after_choice := GameState.flags.duplicate(true)
	var commitments_after_choice := GameState.weekly_commitments.duplicate(true)
	_expect(SaveManager.save_game(TEST_SLOT, live_context),
		"Sangchul result-phase migration fixture could not be saved")
	await _free_story()
	_expect(SaveManager.load_game(TEST_SLOT),
		"Sangchul result-phase migration fixture could not be loaded")
	if not await _spawn_loaded_story():
		return

	var restored_event: Dictionary = _story.get("_current")
	_expect(str(restored_event.get("id", "")) \
			== "arc_sangchul_year3_father_passed",
		"Sangchul result save did not remap to the father-passed variant")
	_expect(bool(_story.get("_pending_after_result")) \
			and not bool(_story.get("_showing_choices")) \
			and not (_story.get("_choice_box") as Control).visible \
			and int(_story.get("_pending_result_choice_index")) == 1,
		"Sangchul migrated save reopened its choice or lost the result receipt")
	var restored_result_text := "\n".join(
		_story.get("_paragraphs") as Array)
	_expect("연락처에는 아버지 이름과 번호가" in restored_result_text \
			and not "아버지가 짧게 말씀하셨다" in restored_result_text,
		"Sangchul migrated result still rendered the living Father's response")
	_expect(str(_story.get("_pending_follow_up")) == "" \
			and str(_story.get("_next_transition_mode")) == "" \
			and str(_story.get("_current_transition_mode")) == "" \
			and (_story.get("_next_transition_contract") as Dictionary).is_empty() \
			and (_story.get("_current_transition_contract") as Dictionary).is_empty(),
		"Sangchul result migration retained an unsafe follow-up or transition")

	var restored_entries: Array = _story.get("_dialogue_log_entries")
	var older_entry_after: Dictionary = {}
	var restored_current_text := ""
	var current_history_is_safe := true
	var restored_current_entries: Array = []
	for raw_restored_entry in restored_entries:
		if not raw_restored_entry is Dictionary:
			continue
		var restored_entry := raw_restored_entry as Dictionary
		var serial := int(restored_entry.get("event_serial", 0))
		if serial == 1:
			older_entry_after = restored_entry.duplicate(true)
		elif serial == 2:
			restored_current_entries.append(restored_entry.duplicate(true))
			restored_current_text += " " + str(restored_entry.get("text", ""))
			if str(restored_entry.get("event_id", "")) \
					!= "arc_sangchul_year3_father_passed":
				current_history_is_safe = false
	_expect(older_entry_after == older_entry_before,
		"Sangchul result migration changed an older Dialogue History serial")
	_expect(current_history_is_safe \
			and "아버지 번호를 연다" in restored_current_text \
			and not "아버지한테 전화했다" in restored_current_text \
			and not "아버지가 짧게" in restored_current_text \
			and not "연락처에는 아버지 이름과 번호가" \
				in restored_current_text \
			and _count_dialogue_kind(restored_current_entries, "prose") > 0 \
			and _count_dialogue_kind(restored_current_entries, "choice") == 1 \
			and _count_dialogue_kind(restored_current_entries, "result") == 0,
		"Sangchul current Dialogue History retained living-Father prose")
	var original_current_history_count := 0
	for raw_current_entry in restored_current_entries:
		if raw_current_entry is Dictionary \
				and str((raw_current_entry as Dictionary).get(
					"event_id", "")) == "arc_sangchul_year3":
			original_current_history_count += 1
	_expect(original_current_history_count == 0,
		"Sangchul result migration retained an original-ID current entry")

	var replacement_choices: Array = restored_event.get("choices", [])
	var replacement_choice: Dictionary = (
		replacement_choices[1] as Dictionary
		if replacement_choices.size() > 1 else {})
	var expected_choice_text := GameState.format_event_text(str(
		replacement_choice.get("text", "")))
	var expected_result_text := GameState.format_event_text(str(
		replacement_choice.get("result_text", "")))
	var expected_title := GameState.format_event_text(str(
		restored_event.get("title", "")))
	var migrated_event_log: Dictionary = (
		GameState.event_log[-1] as Dictionary
		if not GameState.event_log.is_empty() else {})
	var migrated_action_log: Dictionary = (
		GameState.action_log[-1] as Dictionary
		if not GameState.action_log.is_empty() else {})
	var event_log_prefix_preserved := GameState.event_log.size() \
		== event_log_prefix_before_choice.size() + 1
	for index in range(event_log_prefix_before_choice.size()):
		if index >= GameState.event_log.size() \
				or GameState.event_log[index] != _json_round_trip_dictionary(
					event_log_prefix_before_choice[index] as Dictionary):
			event_log_prefix_preserved = false
	var action_log_prefix_preserved := GameState.action_log.size() \
		== action_log_prefix_before_choice.size() + 1
	for index in range(action_log_prefix_before_choice.size()):
		if index >= GameState.action_log.size() \
				or GameState.action_log[index] != _json_round_trip_dictionary(
					action_log_prefix_before_choice[index] as Dictionary):
			action_log_prefix_preserved = false
	_expect(event_log_prefix_preserved \
			and str(migrated_event_log.get("event_id", "")) \
				== "arc_sangchul_year3_father_passed" \
			and str(migrated_event_log.get("choice", "")) \
				== expected_choice_text \
			and str(migrated_event_log.get("result", "")) \
				== expected_result_text,
		"Sangchul result migration changed past event logs or left the current log live")
	_expect(action_log_prefix_preserved \
			and str(migrated_action_log.get("message", "")) \
				== "%s: %s" % [expected_title, expected_result_text] \
			and str(migrated_action_log.get("type", "")) == "event" \
			and int(migrated_action_log.get("turn", -1)) == GameState.turn,
		"Sangchul result migration changed past action logs or left the current title/result live")

	_expect(int(GameState.mental) == mental_after_choice \
			and is_equal_approx(float(GameState.moral_tint), tint_after_choice) \
			and GameState.get_cast_affinity("father") == affinity_after_choice \
			and int(GameState.events_seen) == events_after_choice \
			and GameState.flags == flags_after_choice \
			and GameState.weekly_commitments == commitments_after_choice,
		"Sangchul result migration re-applied effects, flags, or commitment")
	var event_log_after_restore: Array = GameState.event_log.duplicate(true)
	var action_log_after_restore: Array = GameState.action_log.duplicate(true)
	var state_after_restore: Dictionary = GameState.serialize().duplicate(true)
	_story.call("_complete_typing")
	var result_count_after_first_completion := _count_dialogue_kind(
		_dialogue_entries_for_serial(
			_story.get("_dialogue_log_entries") as Array, 2), "result")
	_story.call("_complete_typing")
	var result_count_after_second_completion := _count_dialogue_kind(
		_dialogue_entries_for_serial(
			_story.get("_dialogue_log_entries") as Array, 2), "result")
	_expect(result_count_after_first_completion == 1 \
			and result_count_after_second_completion == 1 \
			and GameState.event_log == event_log_after_restore \
			and GameState.action_log == action_log_after_restore \
			and GameState.serialize() == state_after_restore,
		"Sangchul migrated result duplicated its result receipt, logs, or effects on resume")
	var state_before_second_choice: Dictionary = \
		GameState.serialize().duplicate(true)
	_story.call("_on_choice", 1)
	_expect(GameState.serialize() == state_before_second_choice,
		"Sangchul migrated result allowed its choice to be applied twice")


func _check_father_passed_result_variant_receipt_guard() -> void:
	for receipt_case in ["missing", "wrong_event"]:
		await _free_story()
		LocaleManager.set_language("ko")
		GameState.start_new_game()
		GameState.turn = 189
		GameState.flags.erase("father_passed")
		GameState.flags.erase("arc_father_passing_seen")
		if not await _spawn_story("arc_sangchul_year3"):
			return
		var forged_context: Dictionary = _story.call(
			"build_save_resume_context")
		forged_context["phase"] = "result"
		forged_context["pending_result_choice_index"] = 1
		forged_context["pending_follow_up"] = ""
		forged_context["queue"] = ["chapter_card_35"]
		forged_context["paragraph_index"] = 0
		forged_context["source_paragraph_index"] = 0
		forged_context["source_text_progress"] = 0.0
		GameState.flags["father_passed"] = true
		if receipt_case == "wrong_event":
			GameState.event_log.append({
				"turn": 188,
				"event_id": "story_knee_choice",
				"choice": "UNRELATED CHOICE MUST REMAIN",
				"result": "UNRELATED RESULT MUST REMAIN",
			})
		_expect(SaveManager.save_game(TEST_SLOT, forged_context),
			"%s variant receipt-guard fixture could not be saved" \
				% receipt_case)
		await _free_story()
		_expect(SaveManager.load_game(TEST_SLOT),
			"%s variant receipt-guard fixture could not be loaded" \
				% receipt_case)
		# Save loading owns its own schema normalization. Snapshot after that
		# boundary so this assertion isolates whether StoryMode invented a choice
		# while rejecting the forged result-phase context.
		var mental_before := int(GameState.mental)
		var money_before := int(GameState.money)
		var tint_before := float(GameState.moral_tint)
		var affinity_before := GameState.get_cast_affinity("father")
		var events_before := int(GameState.events_seen)
		var event_log_before: Array = GameState.event_log.duplicate(true)
		var action_log_before: Array = GameState.action_log.duplicate(true)
		if not await _spawn_loaded_story():
			return
		var restored_event: Dictionary = _story.get("_current")
		_expect(str(restored_event.get("id", "")) \
				== "chapter_card_35" \
				and not bool(_story.get("_pending_after_result")) \
				and not bool(_story.get("_showing_choices")),
			"%s forged result receipt did not skip the already-applied scene" \
				% receipt_case)
		_expect(int(GameState.mental) == mental_before \
				and int(GameState.money) == money_before \
				and is_equal_approx(float(GameState.moral_tint), tint_before) \
				and GameState.get_cast_affinity("father") == affinity_before \
				and int(GameState.events_seen) == events_before \
				and GameState.event_log == event_log_before \
				and GameState.action_log == action_log_before,
			"%s forged result receipt invented or applied a choice" \
				% receipt_case)


func _check_father_passed_nonresult_variant_resume() -> void:
	for saved_phase in ["prose", "choices"]:
		await _free_story()
		LocaleManager.set_language("ko")
		GameState.start_new_game()
		GameState.turn = 125
		GameState.flags.erase("father_passed")
		GameState.flags.erase("arc_father_passing_seen")
		if not await _spawn_story("arc_money_loneliness"):
			return

		_story.set("_dialogue_log_event_serial", 2)
		_story.set("_dialogue_log_next_serial", 2)
		_story.call("_append_dialogue_log_entry", {
			"event_serial": 1,
			"event_id": "story_knee_choice",
			"kind": "prose",
			"choice_index": -1,
			"source_paragraph_index": 0,
			"page_index": 0,
			"title": "이전 장면",
			"speaker": "",
			"screen_context": "",
			"channel": "in_person",
			"locale": "ko",
			"text": "OLDER NONRESULT SERIAL MUST REMAIN",
		})
		var older_entry_before := (
			(_story.get("_dialogue_log_entries") as Array)[0] as Dictionary
		).duplicate(true)
		# This is the current serial from an interrupted living-Father article.
		# Keep it explicit so both prose and choices fixtures carry the same stale
		# sentence regardless of pagination or text-size settings.
		_story.call("_append_dialogue_log_entry", {
			"event_serial": 2,
			"event_id": "arc_money_loneliness",
			"kind": "prose",
			"choice_index": -1,
			"source_paragraph_index": 1,
			"page_index": 1,
			"title": "돈이 늘수록",
			"speaker": "",
			"screen_context": "",
			"channel": "in_person",
			"locale": "ko",
			"text": "부모님께 말하면 먼저 위험한 일은 아닌지 물을 것이다.",
		})
		if saved_phase == "choices":
			_show_current_story_choices()
		var live_context: Dictionary = _story.call(
			"build_save_resume_context")
		_expect(str(live_context.get("phase", "")) == saved_phase,
			"%s Father-variant fixture reported the wrong phase" % saved_phase)
		var live_current_entries := _dialogue_entries_for_serial(
			((live_context.get("dialogue_log", {}) as Dictionary).get(
				"entries", []) as Array), 2)
		_expect(not live_current_entries.is_empty() \
				and "부모님께 말하면" in _dialogue_entries_text(
					live_current_entries),
			"%s Father-variant fixture omitted its stale current serial" \
				% saved_phase)

		GameState.flags["father_passed"] = true
		_expect(SaveManager.save_game(TEST_SLOT, live_context),
			"%s Father-variant migration fixture could not be saved" \
				% saved_phase)
		await _free_story()
		_expect(SaveManager.load_game(TEST_SLOT),
			"%s Father-variant migration fixture could not be loaded" \
				% saved_phase)
		if not await _spawn_loaded_story():
			return

		_expect(str((_story.get("_current") as Dictionary).get("id", "")) \
				== "arc_money_loneliness_father_passed" \
				and not bool(_story.get("_showing_choices")) \
				and not bool(_story.get("_pending_after_result")),
			"%s Father-variant migration did not restart safe prose" \
				% saved_phase)
		var restored_entries: Array = _story.get("_dialogue_log_entries")
		var older_entry_after: Dictionary = {}
		var stale_original_entries := 0
		var stale_serial_entries := 0
		for raw_entry in restored_entries:
			if not raw_entry is Dictionary:
				continue
			var entry := raw_entry as Dictionary
			if int(entry.get("event_serial", 0)) == 1:
				older_entry_after = entry.duplicate(true)
			if int(entry.get("event_serial", 0)) == 2:
				stale_serial_entries += 1
			if str(entry.get("event_id", "")) == "arc_money_loneliness":
				stale_original_entries += 1
		_expect(older_entry_after == older_entry_before \
				and stale_original_entries == 0 \
				and stale_serial_entries == 0,
			"%s Father-variant migration changed past history or retained the stale serial" \
				% saved_phase)

		# The old source offset is unsafe after a topology change. The replacement
		# must author its own prose from the beginning; stop as soon as the
		# father-passed description's distinguishing sentence is recorded.
		var safe_text := ""
		var page_budget := maxi(
			16, (_story.get("_paragraphs") as Array).size() * 3)
		while page_budget > 0 \
				and not "그 번호는 이제 연결되지 않았다" in safe_text \
				and not bool(_story.get("_showing_choices")):
			_story.call("_on_advance")
			var current_serial := int(_story.get(
				"_dialogue_log_event_serial"))
			safe_text = _dialogue_entries_text(
				_dialogue_entries_for_serial(
					_story.get("_dialogue_log_entries") as Array,
					current_serial))
			page_budget -= 1
		var replacement_serial := int(_story.get(
			"_dialogue_log_event_serial"))
		var replacement_entries := _dialogue_entries_for_serial(
			_story.get("_dialogue_log_entries") as Array,
			replacement_serial)
		var replacement_entries_are_safe := not replacement_entries.is_empty()
		for raw_replacement_entry in replacement_entries:
			if not raw_replacement_entry is Dictionary \
					or str((raw_replacement_entry as Dictionary).get(
						"event_id", "")) \
						!= "arc_money_loneliness_father_passed":
				replacement_entries_are_safe = false
		_expect(replacement_entries_are_safe \
				and "그 번호는 이제 연결되지 않았다" in safe_text \
				and not "부모님께 말하면" in safe_text \
				and _count_dialogue_kind(replacement_entries, "prose") > 0 \
				and _count_dialogue_kind(replacement_entries, "choice") == 0 \
				and _count_dialogue_kind(replacement_entries, "result") == 0 \
				and not bool(_story.get("_showing_choices")),
			"%s Father-variant restart did not record safe prose only: %s" \
				% [saved_phase, safe_text])


func _check_father_stale_pending_story_queue() -> void:
	await _free_story()
	LocaleManager.set_language("ko")
	var milestone_cases: Array[Dictionary] = [
		{
			"alive": "arc_first_real_win",
			"passed": "arc_first_real_win_father_passed",
		},
		{
			"alive": "arc_money_loneliness",
			"passed": "arc_money_loneliness_father_passed",
		},
		{
			"alive": "arc_gangnam_real_estate",
			"passed": "arc_gangnam_real_estate_father_passed",
		},
	]

	# An old queue is not itself proof of death. Every original milestone must
	# remain on its living article while the Father timeline is still living.
	for milestone_case in milestone_cases:
		GameState.start_new_game()
		var alive_id: String = str(milestone_case.get("alive", ""))
		if not await _spawn_pending_story_queue([alive_id], alive_id):
			return
		_expect(not bool(_story.get("_read_only_replay")),
			"living milestone queue unexpectedly entered read-only replay")
		await _free_story()

	# Cover each monotonic evidence shape against a different old milestone. The
	# queue retains the original ID; StoryMode must select the safe authored copy.
	var evidence_cases: Array[String] = [
		"canonical_flag", "legacy_receipt", "cast_stage",
	]
	for index in range(milestone_cases.size()):
		GameState.start_new_game()
		var evidence_case: String = evidence_cases[index]
		match evidence_case:
			"canonical_flag":
				GameState.flags["father_passed"] = true
			"legacy_receipt":
				GameState.flags["arc_father_passing_seen"] = true
			"cast_stage":
				GameState.apply_cast_effect("father", {
					"met": true,
					"stage": "passed",
				})
		var milestone_case: Dictionary = milestone_cases[index]
		var original_id: String = str(milestone_case.get("alive", ""))
		var passed_id: String = str(milestone_case.get("passed", ""))
		_expect(EventManager.father_death_is_monotonic(),
			"%s fixture did not establish monotonic Father death" % evidence_case)
		if not await _spawn_pending_story_queue([original_id], passed_id):
			return
		_expect(not bool(_story.get("_read_only_replay")),
			"%s milestone migration unexpectedly became a replay" % evidence_case)
		await _free_story()

	# A living-only current call can be stranded ahead of a valid event in an old
	# queue. It must disappear without consuming the valid event behind it.
	GameState.start_new_game()
	GameState.flags["father_passed"] = true
	if not await _spawn_pending_story_queue([
		"arc_father_medication", "story_knee_choice",
	], "story_knee_choice"):
		return
	_expect(str(EventManager.current_event.get("id", "")) \
			== "story_knee_choice" \
			and not (_story.get("_queue") as Array).has(
				"arc_father_medication"),
		"stale living-Father event was rendered or retained in the live queue")
	await _free_story()

	# A damaged save can carry hundreds of deleted IDs and living-only roots.
	# Recovery is an iterative queue scan: the final valid event must still load
	# without making queue length a recursion-depth input.
	GameState.start_new_game()
	GameState.flags["father_passed"] = true
	var long_stale_queue: Array = []
	for index in range(384):
		long_stale_queue.append(
			"missing_father_queue_fixture_%03d" % index)
		long_stale_queue.append("arc_father_medication")
	long_stale_queue.append("story_knee_choice")
	if not await _spawn_pending_story_queue(
			long_stale_queue, "story_knee_choice"):
		return
	_expect(str(EventManager.current_event.get("id", "")) \
			== "story_knee_choice" \
			and (_story.get("_queue") as Array).is_empty(),
		"long stale/missing/living queue did not reach its final valid event")
	await _free_story()

	# Dynamic year-scene roots can also become stale when an old save has fewer
	# than three eligible memories. They share the same iterative recovery
	# contract, including queues long enough to overflow the former recursion.
	GameState.start_new_game()
	var long_invalid_curation_queue: Array = []
	for index in range(768):
		long_invalid_curation_queue.append("arc_year1_scene")
	long_invalid_curation_queue.append("story_knee_choice")
	if not await _spawn_pending_story_queue(
			long_invalid_curation_queue, "story_knee_choice"):
		return
	_expect(str(EventManager.current_event.get("id", "")) \
			== "story_knee_choice" \
			and (_story.get("_queue") as Array).is_empty(),
		"long invalid year-curation queue did not reach its final valid event")
	await _free_story()

	# Read-only replay is historical evidence, not a live queue. Even with current
	# death evidence, it must show the original article and original Father choice
	# without applying that choice to the current run.
	GameState.start_new_game()
	GameState.flags["father_passed"] = true
	if not await _spawn_pending_story_queue(
			["arc_first_real_win"], "arc_first_real_win", true):
		return
	_expect(bool(_story.get("_read_only_replay")),
		"historical milestone did not remain in read-only replay")
	var replay_state_before: Dictionary = GameState.serialize().duplicate(true)
	var replay_meta_before: Dictionary = MetaProgression.data.duplicate(true)
	_show_current_story_choices()
	_story.call("_on_choice", 1)
	_story.call("_finish_story_scene_transition")
	var replay_history_text: String = ""
	var replay_page_budget: int = (_story.get("_paragraphs") as Array).size()
	while bool(_story.get("_pending_after_result")) \
			and replay_page_budget > 0 \
			and not "아버지는 잠깐 조용했다가" in replay_history_text:
		_story.call("_complete_typing")
		replay_history_text = ""
		for raw_entry in _story.get("_dialogue_log_entries") as Array:
			if raw_entry is Dictionary:
				replay_history_text += " " + str(
					(raw_entry as Dictionary).get("text", ""))
		replay_page_budget -= 1
		if not "아버지는 잠깐 조용했다가" in replay_history_text:
			_story.call("_on_advance")
	var replay_result_text: String = _current_story_text()
	_expect(bool(_story.get("_pending_after_result")) \
			and "아버지에게 전화한다" in replay_history_text \
			and not "아버지 번호를 누른다" in replay_history_text \
			and "아버지는 잠깐 조용했다가" in replay_history_text \
			and "아버지는 잠깐 조용했다가" in replay_result_text \
			and not "연결할 수 없는 번호" in replay_result_text,
		"read-only milestone replay replaced its original Father history: log=%s result=%s" \
			% [replay_history_text, replay_result_text])
	_expect(GameState.serialize() == replay_state_before \
			and MetaProgression.data == replay_meta_before,
		"read-only milestone replay mutated the current run or meta history")


func _check_father_passing_terminal_result_resume() -> void:
	await _free_story()
	LocaleManager.set_language("ko")
	var passing_event_ids: Array[String] = [
		"arc_father_passing",
		"arc_father_passing_platform",
		"arc_father_passing_deal_room",
		"arc_father_passing_hospital_room",
		"arc_father_passing_deal_morning",
	]
	var terminal_ids: Array[String] = [
		"arc_father_passing_hospital_room",
		"arc_father_passing_deal_morning",
	]

	# Every article is living-only. The terminal tag grants one narrow exception
	# to an already-applied result save; it must not become a new post-death entry.
	for event_id in passing_event_ids:
		var event: Dictionary = DataRegistry.find_event(event_id)
		var tags: Array = event.get("tags", [])
		_expect(not event.is_empty() \
				and tags.has("requires_living_father") \
				and tags.has("father_passing_terminal") \
					== terminal_ids.has(event_id),
			"Father-passing tag contract drifted for %s" % event_id)

	GameState.start_new_game()
	GameState.flags["father_passed"] = true
	EventManager.pending_events.clear()
	EventManager.current_event = {}
	var direct_queue_rejected := true
	for event_id in passing_event_ids:
		var pending_count_before := EventManager.pending_events.size()
		EventManager.queue_event(DataRegistry.find_event(event_id))
		if EventManager.pending_events.size() != pending_count_before:
			direct_queue_rejected = false
	_expect(direct_queue_rejected and EventManager.pending_events.is_empty(),
		"post-death EventManager queue accepted a Father-passing article")

	# Also exercise the pop-time guard: old saves can already contain these five
	# dictionaries even when new queue_event calls are correctly rejected.
	for event_id in passing_event_ids:
		EventManager.pending_events.append(DataRegistry.find_event(event_id))
	EventManager.pending_events.append(DataRegistry.find_event(
		"story_knee_choice"))
	var first_valid_after_stale: Dictionary = EventManager.get_next_event()
	_expect(str(first_valid_after_stale.get("id", "")) \
			== "story_knee_choice" \
			and EventManager.pending_events.is_empty(),
		"post-death EventManager stale queue rendered a Father-passing article")

	# StoryMode has a second direct ingress through pending_story_queue. The same
	# five IDs must be consumed without rendering before the valid sentinel.
	var direct_story_queue: Array = passing_event_ids.duplicate()
	direct_story_queue.append("story_knee_choice")
	if not await _spawn_pending_story_queue(
			direct_story_queue, "story_knee_choice"):
		return
	_expect((_story.get("_queue") as Array).is_empty(),
		"post-death StoryMode direct queue retained a Father-passing article")
	await _free_story()

	var terminal_cases: Array[Dictionary] = [
		{
			"event_id": "arc_father_passing_hospital_room",
			"result_marker": "텅 빈 병실 침대 옆에 앉았다",
			"route_flag": "tried_to_go_to_father",
			"deferred_id": "",
		},
		{
			"event_id": "arc_father_passing_deal_morning",
			"result_marker": "정확히 5백만원",
			"route_flag": "chose_money_over_father",
			"deferred_id": "callback_chose_money_father_echo",
		},
	]
	for terminal_case in terminal_cases:
		await _free_story()
		GameState.start_new_game()
		GameState.turn = 189
		GameState.flags.erase("father_passed")
		GameState.flags.erase("arc_father_passing_seen")
		var terminal_id := str(terminal_case.get("event_id", ""))
		var terminal_event: Dictionary = DataRegistry.find_event(terminal_id)
		var terminal_choices: Array = terminal_event.get("choices", [])
		var terminal_choice: Dictionary = (
			terminal_choices[0] as Dictionary
			if not terminal_choices.is_empty() else {})
		var effects: Dictionary = terminal_choice.get("effects", {})
		var mental_before := int(GameState.mental)
		var money_before := float(GameState.money)
		var events_seen_before := int(GameState.events_seen)
		var event_log_size_before := GameState.event_log.size()
		var action_log_size_before := GameState.action_log.size()
		if not await _spawn_story(terminal_id):
			return
		_show_current_story_choices()
		_story.call("_on_choice", 0)
		var terminal_context: Dictionary = _story.call(
			"build_save_resume_context")
		# Keep a valid sentinel behind the restored current event so a broken
		# exception remains observable instead of replacing this QA scene.
		terminal_context["queue"] = ["story_knee_choice"]
		var route_flag := str(terminal_case.get("route_flag", ""))
		_expect(str(terminal_context.get("phase", "")) == "result" \
				and int(terminal_context.get(
					"pending_result_choice_index", -1)) == 0 \
				and bool(GameState.flags.get("father_passed", false)) \
				and bool(GameState.flags.get(
					"arc_father_passing_seen", false)) \
				and bool(GameState.flags.get(route_flag, false)) \
				and EventManager.father_death_is_monotonic() \
				and GameState.get_cast_stage("father") == "passed",
			"%s did not create an applied terminal result receipt" % terminal_id)
		_expect(int(GameState.mental) == clampi(
				mental_before + int(effects.get("mental", 0)), 0, 100) \
				and is_equal_approx(float(GameState.money),
					money_before + float(effects.get("money", 0.0))) \
				and int(GameState.events_seen) == events_seen_before + 1 \
				and GameState.event_log.size() == event_log_size_before + 1 \
				and GameState.action_log.size() == action_log_size_before + 1,
			"%s terminal choice did not apply exactly once before saving" \
				% terminal_id)
		var flags_after_choice: Dictionary = GameState.flags.duplicate(true)
		var mental_after_choice := int(GameState.mental)
		var money_after_choice := float(GameState.money)
		var tint_after_choice := float(GameState.moral_tint)
		var events_seen_after_choice := int(GameState.events_seen)
		var event_log_after_choice: Array = GameState.event_log.duplicate(true)
		var action_log_after_choice: Array = GameState.action_log.duplicate(true)
		var deferred_after_choice: Array = GameState.deferred_events.duplicate(true)
		var weekly_after_choice: Array = \
			GameState.weekly_commitments.duplicate(true)
		var expected_event_log: Variant = JSON.parse_string(
			JSON.stringify(event_log_after_choice))
		var expected_action_log: Variant = JSON.parse_string(
			JSON.stringify(action_log_after_choice))
		var expected_deferred: Variant = JSON.parse_string(
			JSON.stringify(deferred_after_choice))
		var expected_weekly: Variant = JSON.parse_string(
			JSON.stringify(weekly_after_choice))
		var deferred_id := str(terminal_case.get("deferred_id", ""))
		var deferred_count_after_choice := 0
		for raw_deferred in GameState.deferred_events:
			if raw_deferred is Dictionary \
					and str((raw_deferred as Dictionary).get(
						"event_id", "")) == deferred_id:
				deferred_count_after_choice += 1
		_expect((deferred_id.is_empty() \
				and deferred_count_after_choice == 0) \
				or (not deferred_id.is_empty() \
					and deferred_count_after_choice == 1),
			"%s terminal choice created the wrong deferred receipt count" \
				% terminal_id)

		_expect(SaveManager.save_game(TEST_SLOT, terminal_context),
			"%s terminal result fixture could not be saved" % terminal_id)
		await _free_story()
		_expect(SaveManager.load_game(TEST_SLOT),
			"%s terminal result fixture could not be loaded" % terminal_id)
		if not await _spawn_loaded_story():
			return
		var resumed_terminal := str(
			(_story.get("_current") as Dictionary).get("id", "")) \
				== terminal_id \
			and bool(_story.get("_pending_after_result")) \
			and int(_story.get("_pending_result_choice_index")) == 0 \
			and not bool(_story.get("_showing_choices"))
		_expect(resumed_terminal,
			"%s applied result save was blocked instead of resumed" % terminal_id)
		if not resumed_terminal:
			continue
		_expect(str(terminal_case.get("result_marker", "")) \
				in _current_story_text(),
			"%s result resume rendered description instead of result prose" \
				% terminal_id)
		_expect(int(GameState.mental) == mental_after_choice \
				and is_equal_approx(float(GameState.money), money_after_choice) \
				and is_equal_approx(
					float(GameState.moral_tint), tint_after_choice) \
				and int(GameState.events_seen) == events_seen_after_choice \
				and GameState.flags == \
					_json_round_trip_dictionary(flags_after_choice) \
				and GameState.get_cast_stage("father") == "passed" \
				and GameState.event_log == expected_event_log \
				and GameState.action_log == expected_action_log \
				and GameState.deferred_events == expected_deferred \
				and GameState.weekly_commitments == expected_weekly,
			"%s terminal result load re-applied effects, flags, logs, or receipts" \
				% terminal_id)

		var restored_serial := int(_story.get(
			"_dialogue_log_event_serial"))
		var restored_current_entries := _dialogue_entries_for_serial(
			_story.get("_dialogue_log_entries") as Array, restored_serial)
		_expect(_count_dialogue_kind(restored_current_entries, "choice") == 1 \
				and _count_dialogue_kind(
					restored_current_entries, "result") == 0,
			"%s terminal result load changed pre-result Dialogue History" \
				% terminal_id)
		var state_before_result_read: Dictionary = \
			GameState.serialize().duplicate(true)
		_story.call("_complete_typing")
		var result_count_once := _count_dialogue_kind(
			_dialogue_entries_for_serial(
				_story.get("_dialogue_log_entries") as Array,
				restored_serial), "result")
		_story.call("_complete_typing")
		_story.call("_on_choice", 0)
		var result_count_twice := _count_dialogue_kind(
			_dialogue_entries_for_serial(
				_story.get("_dialogue_log_entries") as Array,
				restored_serial), "result")
		_expect(result_count_once == 1 and result_count_twice == 1 \
				and GameState.serialize() == state_before_result_read,
			"%s terminal result continuation duplicated prose or reapplied state" \
				% terminal_id)

	# Cross-splices forge the latest receipt to match the requested article, so
	# only the target choice's missing route flag can reject them. The final two
	# fixtures keep every authored flag correct and isolate the latest-receipt ID.
	await _check_father_passing_terminal_result_rejection(
		"arc_father_passing_deal_morning",
		"arc_father_passing_hospital_room",
		"arc_father_passing_hospital_room",
		"deal-state/hospital-result cross-splice")
	await _check_father_passing_terminal_result_rejection(
		"arc_father_passing_hospital_room",
		"arc_father_passing_deal_morning",
		"arc_father_passing_deal_morning",
		"hospital-state/deal-result cross-splice")
	await _check_father_passing_terminal_result_rejection(
		"arc_father_passing_hospital_room",
		"arc_father_passing_hospital_room",
		"arc_father_passing_deal_morning",
		"hospital latest-receipt mismatch")
	await _check_father_passing_terminal_result_rejection(
		"arc_father_passing_deal_morning",
		"arc_father_passing_deal_morning",
		"arc_father_passing_hospital_room",
		"deal latest-receipt mismatch")


func _check_father_passing_terminal_result_rejection(
		state_event_id: String, context_event_id: String,
		latest_receipt_event_id: String, fixture_label: String) -> void:
	await _free_story()
	GameState.start_new_game()
	GameState.turn = 189
	GameState.flags.erase("father_passed")
	GameState.flags.erase("arc_father_passing_seen")
	if not await _spawn_story(state_event_id):
		return
	_show_current_story_choices()
	_story.call("_on_choice", 0)
	var damaged_context: Dictionary = _story.call(
		"build_save_resume_context")
	_expect(str(damaged_context.get("phase", "")) == "result" \
			and bool(GameState.flags.get("father_passed", false)) \
			and not GameState.event_log.is_empty(),
		"%s could not build its applied terminal source" % fixture_label)
	if GameState.event_log.is_empty():
		return
	# Keep the damaged current event ahead of a safe sentinel. Rejection is then
	# directly visible as the sentinel loading, without replacing this QA scene.
	damaged_context["event_id"] = context_event_id
	damaged_context["queue"] = ["story_knee_choice"]
	var latest_receipt := (
		GameState.event_log[-1] as Dictionary).duplicate(true)
	latest_receipt["event_id"] = latest_receipt_event_id
	GameState.event_log[-1] = latest_receipt
	_expect(SaveManager.save_game(TEST_SLOT, damaged_context),
		"%s fixture could not be saved" % fixture_label)
	await _free_story()
	_expect(SaveManager.load_game(TEST_SLOT),
		"%s fixture could not be loaded" % fixture_label)
	if not await _spawn_loaded_story():
		return
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) \
			== "story_knee_choice" \
			and str(EventManager.current_event.get("id", "")) \
				== "story_knee_choice" \
			and not bool(_story.get("_pending_after_result")),
		"%s was accepted as an applied terminal result" % fixture_label)


func _check_timed_choice_resume() -> void:
	await _free_story()
	GameState.start_new_game()
	if not await _spawn_story("cafe_listen_01"):
		return
	_story.set("_para_index", (_story.get("_paragraphs") as Array).size() - 1)
	_story.call("_complete_typing")
	_story.call("_show_choices")
	var timer_context: Dictionary = _story.call("build_save_resume_context")
	var remaining := int(timer_context.get("timer_remaining_msec", -1))
	_expect(str(timer_context.get("phase", "")) == "choices",
		"timed choice save reported the wrong phase")
	_expect(remaining > 0 and remaining <= 12000,
		"timed choice save lost its remaining duration")
	_expect(SaveManager.save_game(TEST_SLOT, timer_context), "timed choice save failed")
	await _free_story()
	_expect(SaveManager.load_game(TEST_SLOT), "timed choice save could not be reloaded")
	if not await _spawn_loaded_story():
		return
	_expect(bool(_story.get("_showing_choices")), "timed choice resume hid the choices")
	var deadline := int(_story.get("_choice_countdown_deadline_msec"))
	var restored_remaining := deadline - Time.get_ticks_msec()
	_expect(deadline > 0 and restored_remaining > 0,
		"timed choice resume did not restart the countdown")
	_expect(restored_remaining <= remaining + 250,
		"timed choice resume reset the countdown to its full duration")

func _check_cross_locale_resume_rewind() -> void:
	await _free_story()
	GameState.start_new_game()
	LocaleManager.set_language("en")
	if not await _spawn_story("story_prologue_dad"):
		return
	_story.call("_finish_story_scene_transition")
	var english_source_count := int(_story.call("_story_source_paragraph_count"))
	var late_source_index := 4
	var late_page := int(_story.call(
		"_first_story_page_for_source", late_source_index))
	var paragraphs: Array = _story.get("_paragraphs")
	if english_source_count <= late_source_index \
			or late_page < 0 or late_page >= paragraphs.size():
		_fail("cross-locale fixture has no late English source paragraph")
		return
	var late_text := str(paragraphs[late_page])
	var late_type_pos := clampi(
		int(roundf(float(late_text.length()) * 0.90)), 1,
		maxi(1, late_text.length() - 1))
	_story.set("_para_index", late_page)
	_story.set("_type_full", late_text)
	_story.set("_type_pos", late_type_pos)
	_story.set("_typing", true)
	(_story.get("_body_lbl") as RichTextLabel).text = late_text.substr(
		0, late_type_pos)
	var context: Dictionary = _story.call("build_save_resume_context")
	_expect(str(context.get("story_locale", "")) == "en",
		"cross-locale save omitted its source language")
	_expect(int(context.get("source_paragraph_count", 0)) == english_source_count,
		"cross-locale save omitted its source structure")
	_expect(SaveManager.save_game(TEST_SLOT, context),
		"cross-locale StoryMode save failed")
	await _free_story()

	LocaleManager.set_language("ko")
	_expect(SaveManager.load_game(TEST_SLOT),
		"cross-locale StoryMode save could not be loaded")
	if not await _spawn_loaded_story():
		return
	var korean_source_count := int(_story.call("_story_source_paragraph_count"))
	_expect(korean_source_count != english_source_count,
		"cross-locale fixture no longer exercises a paragraph mismatch")
	var restored_page := int(_story.get("_para_index"))
	_expect(int(_story.call(
		"_story_source_paragraph_index", restored_page)) == 0,
		"cross-locale load mapped into a potentially unseen paragraph")
	# 타자기는 실제 델타 시간으로 진행하므로 로드 직후 프레임이 길어지면 스스로
	# 앞서 나간다. 절대 문자 수로 판정하면 되감기가 정상인데도 실패한다.
	# 이 가드가 잡으려는 회귀는 저장된 90% 지점에서의 재개이므로, 복원 위치가
	# 그 문단의 절반 앞이면 되감기가 일어난 것으로 판정한다.
	var restored_full := str(_story.get("_type_full"))
	var rewind_ceiling := maxi(7, int(floor(float(restored_full.length()) * 0.5)))
	_expect(bool(_story.get("_typing")) \
			and int(_story.get("_type_pos")) < rewind_ceiling,
		"cross-locale load did not rewind the current prose phase")
	var rewind_entries: Array = _story.call("_dialogue_log_display_entries")
	var rewind_is_safe := rewind_entries.size() <= 1
	for raw_entry in rewind_entries:
		if not raw_entry is Dictionary \
				or int((raw_entry as Dictionary).get(
					"source_paragraph_index", -1)) != 0:
			rewind_is_safe = false
	_expect(rewind_is_safe,
		"cross-locale rewind exposed a later source in Dialogue History")

func _check_pre_dialogue_history_resume() -> void:
	await _free_story()
	GameState.start_new_game()
	if not await _spawn_story("story_knee_choice"):
		return
	_story.call("_complete_typing")
	var old_context: Dictionary = _story.call("build_save_resume_context")
	old_context.erase("dialogue_log")
	# This is the exact shape of a v4 StoryMode save created before the
	# Dialogue History payload was introduced.
	_expect(SaveManager.save_game(TEST_SLOT, old_context, {
		"label": "Pre-Dialogue-History v4 QA",
		"qa_fixture": true,
	}), "pre-Dialogue-History v4 fixture could not be written")
	await _free_story()
	_expect(SaveManager.load_game(TEST_SLOT),
		"pre-Dialogue-History v4 fixture could not be loaded")
	if not await _spawn_loaded_story():
		return
	_expect(bool(_story.get("_dialogue_log_resume_history_unavailable")),
		"old StoryMode save silently presented an empty complete history")
	_story.call("_open_dialogue_log")
	await get_tree().process_frame
	var popup := _story.get("_dialogue_log_popup") as Control
	_expect(is_instance_valid(popup),
		"Dialogue History did not open for an old StoryMode save")
	if is_instance_valid(popup):
		var notice_found := false
		for label in popup.find_children("*", "Label", true, false):
			if label is Label:
				var notice_text := (label as Label).text
				if "불러온 시점 이전" in notice_text \
						or "before the loaded point" in notice_text:
					notice_found = true
					break
		_expect(notice_found,
			"old StoryMode save did not explain that earlier history is unavailable")
		_story.call("_close_dialogue_log")
		await get_tree().process_frame


func _check_first_bill_continuous_resume() -> void:
	await _free_story()
	LocaleManager.set_language("ko")
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	GameState.turn = 24
	GameState.year = 1
	GameState.month = 6
	GameState.week_of_month = 4
	GameState.health = 20
	GameState.money = 500_000.0
	_expect(CORE_LOOP.begin_bundle("demo_collision", "schedule"),
		"First Bill save fixture could not begin")
	var prepared := CORE_LOOP.prepare_demo_collision()
	_expect(bool(prepared.get("ok", false)) \
			and (prepared.get("context", {}) as Dictionary).get(
				"candidate_ids", []) == [
					"father_call", "urgent_paid_shift", "body_rest",
				],
		"First Bill save fixture did not freeze its live candidates")
	if not await _spawn_story("v2_demo_first_bill_opening"):
		return
	_story.set("_para_index", (_story.get("_paragraphs") as Array).size() - 1)
	_story.call("_complete_typing")
	_story.call("_show_choices")
	var before_expression: Dictionary = GameState.serialize().duplicate(true)
	# Save files pass through JSON, which restores every numeric value as a
	# float. Compare against the same lossless JSON round-trip so this assertion
	# detects state changes instead of int/float representation changes.
	var before_expression_v2_variant: Variant = JSON.parse_string(
		JSON.stringify(GameState.core_loop_v2_state))
	var before_expression_v2: Dictionary = (
		before_expression_v2_variant as Dictionary)
	var before_expression_values := [
		float(GameState.money), int(GameState.health), int(GameState.mental),
		int(GameState.events_seen), GameState.flags.duplicate(true),
	]
	_story.call("_on_choice", 1)
	_expect(bool(_story.get("_pending_after_result")) \
			and int(_story.get("_pending_result_choice_index")) == 1 \
			and GameState.serialize() == before_expression,
		"First Bill expression result changed the run before saving")
	var expression_context: Dictionary = _story.call(
		"build_save_resume_context")
	_expect(str(expression_context.get("phase", "")) == "result" \
			and str(expression_context.get("event_id", "")) \
				== "v2_demo_first_bill_opening",
		"First Bill expression save reported the wrong phase or event")
	_expect(SaveManager.save_game(TEST_SLOT, expression_context),
		"First Bill expression result save failed")
	await _free_story()
	_expect(SaveManager.load_game(TEST_SLOT),
		"First Bill expression result could not be reloaded")
	if not await _spawn_loaded_story():
		return
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) \
			== "v2_demo_first_bill_opening",
		"First Bill expression result reloaded the wrong event")
	_expect(bool(_story.get("_pending_after_result")) \
			and int(_story.get("_pending_result_choice_index")) == 1,
		"First Bill expression result reloaded the wrong choice phase")
	_expect(GameState.core_loop_v2_state == before_expression_v2,
		"First Bill expression result changed V2 state across save/load: %s != %s" \
			% [GameState.core_loop_v2_state, before_expression_v2])
	_expect([
			float(GameState.money), int(GameState.health), int(GameState.mental),
			int(GameState.events_seen), GameState.flags.duplicate(true),
		] == before_expression_values,
		"First Bill expression result changed core state across save/load: %s != %s" \
			% [[
				float(GameState.money), int(GameState.health), int(GameState.mental),
				int(GameState.events_seen), GameState.flags.duplicate(true),
			], before_expression_values])
	_story.call("_complete_typing")
	_story.call("_after_result")
	await get_tree().process_frame
	_story.call("_finish_story_scene_transition")
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) \
			== "v2_demo_first_bill",
		"First Bill expression resume did not rejoin the shared decision")

	_story.set("_para_index", (_story.get("_paragraphs") as Array).size() - 1)
	_story.call("_complete_typing")
	_story.call("_show_choices")
	var decision_context: Dictionary = _story.call(
		"build_save_resume_context")
	_expect(str(decision_context.get("phase", "")) == "choices" \
			and SaveManager.save_game(TEST_SLOT, decision_context),
		"First Bill decision choices could not be saved")
	await _free_story()
	_expect(SaveManager.load_game(TEST_SLOT),
		"First Bill decision choices could not be reloaded")
	if not await _spawn_loaded_story():
		return
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) \
			== "v2_demo_first_bill" \
			and bool(_story.get("_showing_choices")),
		"First Bill decision did not resume on its choice rail")
	var mental_before := int(GameState.mental)
	_story.call("_on_choice", 0)
	var mental_after := int(GameState.mental)
	var receipt_count_before := _v2_story_receipt_count(
		"v2_demo_first_bill", 0)
	_expect(mental_after == mental_before - 1 \
			and receipt_count_before == 1 \
			and str(((GameState.core_loop_v2_state.get(
				"obligation_receipts", {}) as Dictionary).get(
					"demo_collision", {}) as Dictionary).get(
						"selected_obligation_id", "")) == "father_call",
		"First Bill durable decision did not apply exactly once")
	var decision_result_context: Dictionary = _story.call(
		"build_save_resume_context")
	_expect(SaveManager.save_game(TEST_SLOT, decision_result_context),
		"First Bill decision result save failed")
	await _free_story()
	_expect(SaveManager.load_game(TEST_SLOT),
		"First Bill decision result could not be reloaded")
	if not await _spawn_loaded_story():
		return
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) \
			== "v2_demo_first_bill" \
			and bool(_story.get("_pending_after_result")) \
			and int(GameState.mental) == mental_after \
			and _v2_story_receipt_count("v2_demo_first_bill", 0) == 1,
		"First Bill decision result replayed its effect or receipt after load")
	_story.call("_complete_typing")
	_story.call("_after_result")
	await get_tree().process_frame
	_story.call("_finish_story_scene_transition")
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) \
			== "v2_demo_first_bill_ledger",
		"First Bill decision result did not enter the shared ledger")
	var seen_first_bill: Array[String] = []
	for raw_id in GameState.run_seen_scenes_by_year.get("1", []):
		var event_id := str(raw_id)
		if event_id.begins_with("v2_demo_first_bill"):
			seen_first_bill.append(event_id)
	_expect(seen_first_bill == ["v2_demo_first_bill_opening"],
		"First Bill internal fragments leaked into the run gallery")
	var ledger_context: Dictionary = _story.call("build_save_resume_context")
	_expect(SaveManager.save_game(TEST_SLOT, ledger_context),
		"First Bill ledger prose save failed")
	await _free_story()
	_expect(SaveManager.load_game(TEST_SLOT),
		"First Bill ledger prose could not be reloaded")
	if not await _spawn_loaded_story():
		return
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) \
			== "v2_demo_first_bill_ledger",
		"First Bill ledger reloaded the wrong event")
	_story.set("_para_index", (_story.get("_paragraphs") as Array).size() - 1)
	_story.call("_complete_typing")
	_story.call("_show_choices")
	var before_ledger_close: Dictionary = GameState.serialize().duplicate(true)
	_story.call("_on_choice", 0)
	_expect(bool(_story.get("_pending_after_result")) \
			and GameState.serialize() == before_ledger_close,
		"First Bill notebook close changed persistent state after reload")

	await _check_first_bill_fatal_clamp_snapshot_and_replay()
	await _check_first_bill_rest_clamp_snapshot_and_replay()
	await _check_first_bill_legacy_resume_matrix()
	await _check_first_bill_nonstory_legacy_state_migration()
	_check_first_bill_archive_catalog_source()


func _check_first_bill_fatal_clamp_snapshot_and_replay() -> void:
	await _free_story()
	_clear_first_bill_meta_fixture()
	var prepared := _prepare_first_bill_fixture(
		3, false, "치명경계민준", "gosiwon", 333_333.0)
	if prepared.is_empty() \
			or not await _spawn_story(CORE_LOOP.FIRST_BILL_DECISION_ID):
		return
	_show_current_story_choices()
	var mental_before := int(GameState.mental)
	_story.call("_on_choice", 6)
	_story.call("_finish_story_scene_transition")
	var live_snapshot: Dictionary = _validated_story_first_bill_snapshot()
	var saved_context: Dictionary = _story.call("build_save_resume_context")
	var context_snapshot: Dictionary = CORE_LOOP \
		.validated_complete_first_bill_replay_snapshot(
			saved_context.get("first_bill_replay_snapshot", {}) as Dictionary)
	var meta_snapshot := _stored_complete_first_bill_snapshot()
	_expect(int(GameState.health) == 0 \
			and int(GameState.mental) == mental_before - 4 \
			and bool(_story.get("_pending_after_result")),
		"First Bill H3 urgent fixture did not stop at its result on H0")
	_expect(str(saved_context.get("phase", "")) == "result" \
			and int(saved_context.get("pending_result_choice_index", -1)) == 6 \
			and not context_snapshot.is_empty() \
			and int(context_snapshot.get("health", -1)) == 3 \
			and int(live_snapshot.get("health", -1)) == 3 \
			and int(meta_snapshot.get("health", -1)) == 3,
		"First Bill H3 urgent result did not preserve the exact pre-clamp health")
	_expect(str((context_snapshot.get(
			"obligation_receipt", {}) as Dictionary).get(
				"selected_obligation_id", "")) == "urgent_paid_shift",
		"First Bill H3 urgent snapshot lost its chosen obligation")
	var receipt_count := _v2_story_receipt_count(
		CORE_LOOP.FIRST_BILL_DECISION_ID, 6)
	_expect(receipt_count == 1,
		"First Bill H3 urgent result did not own exactly one receipt")
	_expect(SaveManager.save_game(TEST_SLOT, saved_context),
		"First Bill H3 urgent result save failed")
	await _free_story()
	_expect(SaveManager.load_game(TEST_SLOT),
		"First Bill H3 urgent result could not be loaded")
	if not await _spawn_loaded_story():
		return
	var loaded_snapshot := _validated_story_first_bill_snapshot()
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) \
			== CORE_LOOP.FIRST_BILL_DECISION_ID \
			and bool(_story.get("_pending_after_result")) \
			and int(GameState.health) == 0 \
			and int(GameState.mental) == mental_before - 4 \
			and int(loaded_snapshot.get("health", -1)) == 3 \
			and int(_stored_complete_first_bill_snapshot().get(
				"health", -1)) == 3 \
			and _v2_story_receipt_count(
				CORE_LOOP.FIRST_BILL_DECISION_ID, 6) == receipt_count,
		"First Bill H3 urgent result load lost its exact snapshot or replayed effects")
	# Keep this component test in its own scene while exercising the production
	# fatal guard. _after_result must still erase every authored continuation.
	_story.set("_transitioning", true)
	_story.call("_after_result")
	_expect((_story.get("_queue") as Array).is_empty() \
			and str(_story.get("_pending_follow_up")).is_empty() \
			and str((_story.get("_current") as Dictionary).get("id", "")) \
				== CORE_LOOP.FIRST_BILL_DECISION_ID,
		"Loaded H0 First Bill result entered the ledger instead of short-circuiting")
	await _free_story()

	# The same frozen H3 record must remain fatal in read-only replay even though
	# the unrelated current run has healthy stats.
	GameState.start_new_game()
	GameState.turn = 25
	GameState.health = 88
	GameState.money = 8_888_888.0
	if not await _spawn_first_bill_replay():
		return
	var replay_state_before: Dictionary = GameState.serialize().duplicate(true)
	var replay_meta_before: Dictionary = MetaProgression.data.duplicate(true)
	_advance_opening_expression_to_decision(0)
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) \
			== CORE_LOOP.FIRST_BILL_DECISION_ID \
			and (_story.call("_visible_choice_indices", _story.get(
				"_current")) as Array) == [0, 6, 7],
		"Frozen H3 replay did not restore its exact decision candidates")
	_show_current_story_choices()
	_story.call("_on_choice", 6)
	_expect(bool(_story.get("_pending_after_result")) \
			and GameState.serialize() == replay_state_before \
			and MetaProgression.data == replay_meta_before,
		"Frozen H3 urgent replay mutated the current run or stored snapshot")
	_story.set("_transitioning", true)
	_story.call("_after_result")
	_expect((_story.get("_queue") as Array).is_empty() \
			and str(_story.get("_pending_follow_up")).is_empty() \
			and str((_story.get("_current") as Dictionary).get("id", "")) \
				== CORE_LOOP.FIRST_BILL_DECISION_ID \
			and GameState.serialize() == replay_state_before \
			and MetaProgression.data == replay_meta_before,
		"Frozen H3 urgent replay entered the ledger or Hyunsu continuation")


func _check_first_bill_rest_clamp_snapshot_and_replay() -> void:
	await _free_story()
	_clear_first_bill_meta_fixture()
	var frozen_name := "과거민준"
	var frozen_money := 987_654.0
	var prepared := _prepare_first_bill_fixture(
		99, true, frozen_name, "oneroom", frozen_money)
	var prepared_context: Dictionary = prepared.get("context", {})
	_expect(prepared_context.get("roots", []) == [
			CORE_LOOP.FIRST_BILL_OPENING_ID,
			"v2_hyunsu_exam_morning_echo",
		],
		"First Bill H99 fixture did not freeze its Hyunsu continuation")
	if prepared.is_empty() \
			or not await _spawn_story(CORE_LOOP.FIRST_BILL_DECISION_ID):
		return
	_show_current_story_choices()
	var mental_before := int(GameState.mental)
	_story.call("_on_choice", 7)
	var saved_context: Dictionary = _story.call("build_save_resume_context")
	var context_snapshot: Dictionary = CORE_LOOP \
		.validated_complete_first_bill_replay_snapshot(
			saved_context.get("first_bill_replay_snapshot", {}) as Dictionary)
	var meta_snapshot := _stored_complete_first_bill_snapshot()
	_expect(int(GameState.health) == 100 \
			and int(GameState.mental) == mental_before + 1 \
			and str(saved_context.get("phase", "")) == "result" \
			and int(context_snapshot.get("health", -1)) == 99 \
			and int(meta_snapshot.get("health", -1)) == 99,
		"First Bill H99 rest result did not preserve the exact pre-clamp health")
	_expect(str((meta_snapshot.get(
			"obligation_receipt", {}) as Dictionary).get(
				"selected_obligation_id", "")) == "body_rest",
		"First Bill H99 snapshot lost its original rest decision")
	var receipt_count := _v2_story_receipt_count(
		CORE_LOOP.FIRST_BILL_DECISION_ID, 7)
	_expect(receipt_count == 1 \
			and SaveManager.save_game(TEST_SLOT, saved_context),
		"First Bill H99 rest result save or receipt failed")
	await _free_story()
	_expect(SaveManager.load_game(TEST_SLOT),
		"First Bill H99 rest result could not be loaded")
	if not await _spawn_loaded_story():
		return
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) \
			== CORE_LOOP.FIRST_BILL_DECISION_ID \
			and bool(_story.get("_pending_after_result")) \
			and int(GameState.health) == 100 \
			and int(GameState.mental) == mental_before + 1 \
			and int(_validated_story_first_bill_snapshot().get(
				"health", -1)) == 99 \
			and _v2_story_receipt_count(
				CORE_LOOP.FIRST_BILL_DECISION_ID, 7) == receipt_count,
		"First Bill H99 rest result load drifted or replayed its effects")
	_story.call("_complete_typing")
	_story.call("_after_result")
	await get_tree().process_frame
	_story.call("_finish_story_scene_transition")
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) \
			== CORE_LOOP.FIRST_BILL_LEDGER_ID,
		"Loaded nonfatal H99 rest result did not enter the ledger")
	await _free_story()

	# Move to an unrelated current life. Every replay line and choice below must
	# still come from the frozen Week-24 record, never these current HUD values.
	GameState.start_new_game()
	GameState.turn = 25
	GameState.player_name = "현재인물"
	GameState.money = 12.0
	GameState.health = 11
	GameState.housing = "gosiwon"
	if not await _spawn_first_bill_replay():
		return
	var replay_snapshot := _validated_story_first_bill_snapshot()
	var opening_text := _current_story_text()
	var hud := _story.get("_hud_panel") as Control
	_expect(str(replay_snapshot.get("player_name", "")) == frozen_name \
			and is_equal_approx(float(replay_snapshot.get("money", 0.0)), frozen_money) \
			and str(replay_snapshot.get("housing", "")) == "oneroom" \
			and int(replay_snapshot.get("health", -1)) == 99 \
			and replay_snapshot.get("context", {}) is Dictionary \
			and (replay_snapshot.get("context", {}) as Dictionary).get(
				"candidate_ids", []) == [
					"father_call", "urgent_paid_shift", "body_rest",
				],
		"Read-only replay did not load the frozen name, money, housing, health, and candidates")
	_expect(opening_text.contains(frozen_name) \
			and not opening_text.contains("현재인물") \
			and opening_text.contains(GameState.format_money(frozen_money)) \
			and opening_text.contains(GameState.format_money(float(
				replay_snapshot.get("housing_expense", 0.0)))) \
			and opening_text.contains("뚜렷한 통증은 없었다") \
			and opening_text.contains("당일 대타") \
			and not opening_text.contains("한빛유통") \
			and not opening_text.contains("도시시설운영단") \
			and str(_story.call("_first_bill_replay_housing_ambience")) \
				== "oneroom" \
			and is_instance_valid(hud) and not hud.visible,
		"Read-only opening mixed current HUD data into its frozen rendered prose")
	var replay_state_before: Dictionary = GameState.serialize().duplicate(true)
	var replay_meta_before: Dictionary = MetaProgression.data.duplicate(true)
	_advance_opening_expression_to_decision(1)
	var visible_indices: Array = _story.call(
		"_visible_choice_indices", _story.get("_current"))
	_expect(visible_indices == [0, 6, 7],
		"Read-only decision exposed a candidate outside the frozen three")
	_show_current_story_choices()
	_story.call("_on_choice", 0)
	var replay_log: Array = _story.get("_dialogue_log_entries")
	var replay_choice_speaker := ""
	for raw_entry in replay_log:
		if raw_entry is Dictionary \
				and str((raw_entry as Dictionary).get("kind", "")) == "choice":
			replay_choice_speaker = str(
				(raw_entry as Dictionary).get("speaker", ""))
	_expect(replay_choice_speaker == frozen_name,
		"Read-only choice log used the current run name instead of the frozen player name")
	var local_snapshot := _validated_story_first_bill_snapshot()
	var local_receipt: Dictionary = local_snapshot.get(
		"obligation_receipt", {})
	_expect(str(local_receipt.get("selected_obligation_id", "")) \
			== "father_call" \
			and local_receipt.get("deferred_obligation_ids", []) == [
				"urgent_paid_shift", "body_rest",
			] \
			and str((_stored_complete_first_bill_snapshot().get(
				"obligation_receipt", {}) as Dictionary).get(
					"selected_obligation_id", "")) == "body_rest" \
			and GameState.serialize() == replay_state_before \
			and MetaProgression.data == replay_meta_before,
		"Read-only alternate choice mutated the run or overwrote the stored decision")
	_story.call("_complete_typing")
	_story.call("_after_result")
	await get_tree().process_frame
	_story.call("_finish_story_scene_transition")
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) \
			== CORE_LOOP.FIRST_BILL_LEDGER_ID,
		"Read-only alternate choice did not enter its local ledger")
	var ledger_text := _current_story_text()
	_expect(ledger_text.contains("끝낸 일 — 아버지") \
			and ledger_text.contains("미룬 일 — 알람을 맞추고 누워 쉬지 못했다") \
			and ledger_text.contains("마감을 놓친 일 — 18:30") \
			and GameState.serialize() == replay_state_before \
			and MetaProgression.data == replay_meta_before,
		"Read-only ledger did not render the alternate local done/deferred partition")
	_show_current_story_choices()
	_story.call("_on_choice", 0)
	_story.call("_complete_typing")
	_story.call("_after_result")
	await get_tree().process_frame
	_story.call("_finish_story_scene_transition")
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) \
			== "v2_hyunsu_exam_morning_echo" \
			and GameState.serialize() == replay_state_before \
			and MetaProgression.data == replay_meta_before,
		"Read-only ledger lost its frozen Hyunsu continuation or changed persistent state")


func _check_first_bill_legacy_resume_matrix() -> void:
	await _free_story()
	LocaleManager.set_language("ko")

	# A payload can have the old root shape while the rest of its collision
	# context is corrupt. Migration must validate the proposed new state before
	# assigning any part of it, and the resume payload must remain untouched too.
	_prepare_first_bill_fixture(
		40, false, "김민준", "gosiwon", 500_000.0)
	_downgrade_first_bill_context_to_legacy()
	var corrupt_state_before: Dictionary = \
		GameState.core_loop_v2_state.duplicate(true)
	var corrupt_context: Dictionary = corrupt_state_before.get(
		"demo_collision_context", {}).duplicate(true)
	corrupt_context["dirty_source"] = "fell_to_darkness"
	corrupt_context["dirty_root"] = "v2_dirty_recruiter_week24"
	corrupt_context["roots"] = [
		"v2_dirty_recruiter_week24",
		CORE_LOOP.FIRST_BILL_DECISION_ID,
	]
	corrupt_state_before["demo_collision_context"] = corrupt_context
	GameState.core_loop_v2_state = corrupt_state_before.duplicate(true)
	var corrupt_resume := _legacy_story_context(
		CORE_LOOP.FIRST_BILL_DECISION_ID, "choices", [])
	var corrupt_resume_after := CORE_LOOP \
		.migrate_legacy_first_bill_resume_context(corrupt_resume)
	_expect(corrupt_resume_after == corrupt_resume \
			and GameState.core_loop_v2_state == corrupt_state_before,
		"Corrupt legacy First Bill migration partially changed state or resume data")

	# The collision state itself may be sound while the saved story cursor is
	# not. Unknown phases must not consume the one-shot root migration.
	_prepare_first_bill_fixture(
		40, false, "김민준", "gosiwon", 500_000.0)
	_downgrade_first_bill_context_to_legacy()
	var unknown_phase_state := GameState.core_loop_v2_state.duplicate(true)
	var unknown_phase_resume := _legacy_story_context(
		CORE_LOOP.FIRST_BILL_DECISION_ID, "unknown_phase", [])
	var unknown_phase_after := CORE_LOOP \
		.migrate_legacy_first_bill_resume_context(unknown_phase_resume)
	_expect(unknown_phase_after == unknown_phase_resume \
			and GameState.core_loop_v2_state == unknown_phase_state,
		"Unknown legacy First Bill phase consumed the root migration")

	# Reaching Hyunsu means the First Bill decision must already own its exact
	# obligation receipt. A cursor that claims otherwise is malformed and must
	# leave both payloads byte-identical.
	_prepare_first_bill_fixture(
		40, true, "김민준", "gosiwon", 500_000.0)
	_downgrade_first_bill_context_to_legacy()
	var missing_receipt_state := GameState.core_loop_v2_state.duplicate(true)
	var missing_receipt_resume := _legacy_story_context(
		"v2_hyunsu_exam_morning_echo", "result", [], 0, "")
	var missing_receipt_after := CORE_LOOP \
		.migrate_legacy_first_bill_resume_context(missing_receipt_resume)
	_expect(missing_receipt_after == missing_receipt_resume \
			and GameState.core_loop_v2_state == missing_receipt_state,
		"Receipt-less legacy Hyunsu cursor consumed the First Bill root migration")

	# Conversely, an old decision cursor that still claims to be before the
	# choice cannot coexist with an already-written obligation receipt. Rewinding
	# that cursor would offer the same state-changing choice a second time.
	_prepare_first_bill_fixture(
		40, false, "김민준", "gosiwon", 500_000.0)
	_apply_first_bill_story_choice_once(CORE_LOOP.FIRST_BILL_DECISION_ID, 0)
	_downgrade_first_bill_context_to_legacy()
	var duplicate_choice_state := GameState.core_loop_v2_state.duplicate(true)
	var duplicate_choice_resume := _legacy_story_context(
		CORE_LOOP.FIRST_BILL_DECISION_ID, "choices", [])
	var duplicate_choice_after := CORE_LOOP \
		.migrate_legacy_first_bill_resume_context(duplicate_choice_resume)
	_expect(duplicate_choice_after == duplicate_choice_resume \
			and GameState.core_loop_v2_state == duplicate_choice_state,
		"Receipt-bearing legacy pre-choice cursor could replay the First Bill decision")

	# A result cursor must identify the same choice as the canonical obligation
	# receipt. Otherwise it can display one branch's result and continue through
	# another branch's ledger.
	var mismatched_result_resume := _legacy_story_context(
		CORE_LOOP.FIRST_BILL_DECISION_ID, "result", [], 1, "")
	var mismatched_result_after := CORE_LOOP \
		.migrate_legacy_first_bill_resume_context(mismatched_result_resume)
	_expect(mismatched_result_after == mismatched_result_resume \
			and GameState.core_loop_v2_state == duplicate_choice_state,
		"Mismatched legacy First Bill result index consumed the root migration")

	# Any cursor located before the decision is also incompatible with an
	# already-written decision receipt, even when the cursor is a dirty callback
	# rather than the decision card itself.
	_prepare_first_bill_fixture(
		40, false, "김민준", "gosiwon", 500_000.0, true)
	_apply_first_bill_story_choice_once(CORE_LOOP.FIRST_BILL_DECISION_ID, 0)
	_downgrade_first_bill_context_to_legacy()
	var predecision_receipt_state := \
		GameState.core_loop_v2_state.duplicate(true)
	var predecision_receipt_resume := _legacy_story_context(
		"v2_dirty_recruiter_week24", "prose",
		[CORE_LOOP.FIRST_BILL_DECISION_ID])
	var predecision_receipt_after := CORE_LOOP \
		.migrate_legacy_first_bill_resume_context(predecision_receipt_resume)
	_expect(predecision_receipt_after == predecision_receipt_resume \
			and GameState.core_loop_v2_state == predecision_receipt_state,
		"Receipt-bearing pre-decision callback consumed the First Bill root migration")

	# Old dirty-prose saves queued the decision card directly. The dirty result
	# stays current, while only that queued root becomes the new opening.
	var dirty_prepared := _prepare_first_bill_fixture(
		40, false, "김민준", "gosiwon", 500_000.0, true)
	var dirty_context: Dictionary = dirty_prepared.get("context", {})
	_expect(dirty_context.get("roots", []) == [
			"v2_dirty_recruiter_week24",
			CORE_LOOP.FIRST_BILL_OPENING_ID,
		],
		"Legacy dirty-prose fixture did not begin from the expected roots")
	_downgrade_first_bill_context_to_legacy()
	var dirty_resume := _legacy_story_context(
		"v2_dirty_recruiter_week24", "prose",
		[CORE_LOOP.FIRST_BILL_DECISION_ID])
	var migrated_dirty: Dictionary = CORE_LOOP \
		.migrate_legacy_first_bill_resume_context(dirty_resume)
	_expect(str(migrated_dirty.get("event_id", "")) \
			== "v2_dirty_recruiter_week24" \
			and migrated_dirty.get("queue", []) == [
				CORE_LOOP.FIRST_BILL_OPENING_ID,
			] \
			and (GameState.core_loop_v2_state.get(
				"demo_collision_context", {}) as Dictionary).get(
					"roots", []) == [
						"v2_dirty_recruiter_week24",
						CORE_LOOP.FIRST_BILL_OPENING_ID,
					],
		"Legacy dirty-prose queue did not replace decision with opening exactly once")

	# Early playtest saves could already be paused on the dirty result with both
	# the exact callback receipt and a readerless generic story receipt. The new
	# runtime never creates that duplicate, but loading must preserve it byte for
	# byte and must not replay the already-applied choice effect.
	_prepare_first_bill_fixture(
		40, false, "김민준", "gosiwon", 500_000.0, true)
	_apply_first_bill_story_choice_once("v2_dirty_recruiter_week24", 1)
	_expect(_v2_story_receipt_count(
			"v2_dirty_recruiter_week24", 1) == 0,
		"Fresh dirty result unexpectedly created a retired generic receipt")
	var old_generic_key := \
		"demo_collision:v2_dirty_recruiter_week24:1:24"
	var old_generic_receipt := {
		"receipt_key": old_generic_key,
		"bundle_id": "demo_collision",
		"active_kind": "schedule",
		"event_id": "v2_dirty_recruiter_week24",
		"choice_index": 1,
		"turn": 24,
	}
	var old_generic_state: Dictionary = \
		GameState.core_loop_v2_state.duplicate(true)
	var old_generic_receipts: Dictionary = (
		old_generic_state.get(
			"story_choice_receipts", {}) as Dictionary).duplicate(true)
	old_generic_receipts[old_generic_key] = old_generic_receipt
	old_generic_state["story_choice_receipts"] = old_generic_receipts
	GameState.core_loop_v2_state = old_generic_state
	var expected_old_generic := _json_round_trip_dictionary(
		old_generic_receipts)
	var dirty_result_stats := [
		int(GameState.intelligence), int(GameState.mental),
	]
	_downgrade_first_bill_context_to_legacy()
	var old_dirty_result_resume := _legacy_story_context(
		"v2_dirty_recruiter_week24", "result",
		[CORE_LOOP.FIRST_BILL_DECISION_ID], 1, "")
	_expect(SaveManager.save_game(TEST_SLOT, old_dirty_result_resume),
		"Old dirty-result generic receipt fixture could not be saved")
	_expect(SaveManager.load_game(TEST_SLOT),
		"Old dirty-result generic receipt fixture could not be loaded")
	if not await _spawn_loaded_story():
		return
	var loaded_dirty_callback: Dictionary = (
		(GameState.core_loop_v2_state.get(
			"deferred_callback_receipts", {}) as Dictionary).get(
				"fell_to_darkness", {}) as Dictionary).duplicate(true)
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) \
			== "v2_dirty_recruiter_week24" \
			and bool(_story.get("_pending_after_result")) \
			and int(_story.get("_pending_result_choice_index")) == 1 \
			and [int(GameState.intelligence), int(GameState.mental)] \
				== dirty_result_stats \
			and GameState.core_loop_v2_state.get(
				"story_choice_receipts", {}) == expected_old_generic \
			and _v2_story_receipt_count(
				"v2_dirty_recruiter_week24", 1) == 1 \
			and str(loaded_dirty_callback.get("source", "")) \
				== "fell_to_darkness" \
			and str(loaded_dirty_callback.get("root", "")) \
				== "v2_dirty_recruiter_week24" \
			and str(loaded_dirty_callback.get("status", "")) == "resolved" \
			and bool(loaded_dirty_callback.get("synthetic", false)) \
			and str(loaded_dirty_callback.get("event_id", "")) \
				== "v2_dirty_recruiter_week24" \
			and int(loaded_dirty_callback.get("choice_index", -1)) == 1 \
			and int(loaded_dirty_callback.get("resolved_turn", -1)) == 24,
		"Old dirty-result save replayed effects, erased generic state, or changed exact transport")
	await _free_story()

	# Saving on the old decision choices must rewind to the authored opening,
	# not attempt to map pagination into a scene the player never read.
	_prepare_first_bill_fixture(
		40, false, "김민준", "gosiwon", 500_000.0)
	_downgrade_first_bill_context_to_legacy()
	var choices_resume := _legacy_story_context(
		CORE_LOOP.FIRST_BILL_DECISION_ID, "choices", [])
	var migrated_choices: Dictionary = CORE_LOOP \
		.migrate_legacy_first_bill_resume_context(choices_resume)
	_expect(str(migrated_choices.get("event_id", "")) \
			== CORE_LOOP.FIRST_BILL_OPENING_ID \
			and str(migrated_choices.get("phase", "")) == "prose" \
			and (migrated_choices.get("queue", []) as Array).is_empty() \
			and not migrated_choices.has("paragraph_index") \
			and not migrated_choices.has("pending_result_choice_index"),
		"Legacy decision choices were not conservatively rewound to opening prose")

	# A result save already owns its effects and receipt. An empty old follow-up
	# is repaired to one ledger and loading the result must not apply either again.
	_prepare_first_bill_fixture(
		40, false, "김민준", "gosiwon", 500_000.0)
	_apply_first_bill_story_choice_once(CORE_LOOP.FIRST_BILL_DECISION_ID, 0)
	var decision_mental := int(GameState.mental)
	var decision_receipts := _v2_story_receipt_count(
		CORE_LOOP.FIRST_BILL_DECISION_ID, 0)
	_downgrade_first_bill_context_to_legacy()
	var decision_result_resume := _legacy_story_context(
		CORE_LOOP.FIRST_BILL_DECISION_ID, "result", [], 0, "")
	var migrated_result: Dictionary = CORE_LOOP \
		.migrate_legacy_first_bill_resume_context(decision_result_resume)
	_expect(str(migrated_result.get("event_id", "")) \
			== CORE_LOOP.FIRST_BILL_DECISION_ID \
			and str(migrated_result.get("pending_follow_up", "")) \
				== CORE_LOOP.FIRST_BILL_LEDGER_ID,
		"Legacy decision result with an empty follow-up did not gain one ledger")
	# Restore the old shape before serializing so StoryMode itself, not this pure
	# probe, owns the migration exercised below.
	_downgrade_first_bill_context_to_legacy()
	_expect(SaveManager.save_game(TEST_SLOT, decision_result_resume),
		"Legacy First Bill decision-result fixture could not be saved")
	_expect(SaveManager.load_game(TEST_SLOT),
		"Legacy First Bill decision-result fixture could not be loaded")
	if not await _spawn_loaded_story():
		return
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) \
			== CORE_LOOP.FIRST_BILL_DECISION_ID \
			and bool(_story.get("_pending_after_result")) \
			and str(_story.get("_pending_follow_up")) \
				== CORE_LOOP.FIRST_BILL_LEDGER_ID \
			and int(GameState.mental) == decision_mental \
			and _v2_story_receipt_count(
				CORE_LOOP.FIRST_BILL_DECISION_ID, 0) == decision_receipts,
		"Legacy First Bill decision result replayed its effect or lost the repaired ledger")
	_story.call("_complete_typing")
	_story.call("_after_result")
	await get_tree().process_frame
	_story.call("_finish_story_scene_transition")
	var decision_queue: Array = _story.get("_queue")
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) \
			== CORE_LOOP.FIRST_BILL_LEDGER_ID \
			and not decision_queue.has(CORE_LOOP.FIRST_BILL_LEDGER_ID) \
			and int(GameState.mental) == decision_mental \
			and _v2_story_receipt_count(
				CORE_LOOP.FIRST_BILL_DECISION_ID, 0) == decision_receipts,
		"Legacy decision result entered the repaired ledger more than once")
	await _free_story()

	# In the old order Hyunsu could already be showing his result before the new
	# ledger existed. Insert the ledger first, then restore that exact result phase
	# without applying its flag or V2 receipt a second time.
	var hyunsu_prepared := _prepare_first_bill_fixture(
		40, true, "김민준", "gosiwon", 500_000.0)
	_expect((hyunsu_prepared.get("context", {}) as Dictionary).get(
			"roots", []) == [
				CORE_LOOP.FIRST_BILL_OPENING_ID,
				"v2_hyunsu_exam_morning_echo",
			],
		"Legacy Hyunsu result fixture did not begin from the expected roots")
	_apply_first_bill_story_choice_once(CORE_LOOP.FIRST_BILL_DECISION_ID, 0)
	_apply_first_bill_story_choice_once("v2_hyunsu_exam_morning_echo", 0)
	var hyunsu_receipts := _v2_story_receipt_count(
		"v2_hyunsu_exam_morning_echo", 0)
	var state_after_hyunsu: Dictionary = GameState.serialize().duplicate(true)
	_downgrade_first_bill_context_to_legacy()
	var hyunsu_result_resume := _legacy_story_context(
		"v2_hyunsu_exam_morning_echo", "result", [], 0, "")
	_expect(SaveManager.save_game(TEST_SLOT, hyunsu_result_resume),
		"Legacy Hyunsu result fixture could not be saved")
	_expect(SaveManager.load_game(TEST_SLOT),
		"Legacy Hyunsu result fixture could not be loaded")
	if not await _spawn_loaded_story():
		return
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) \
			== CORE_LOOP.FIRST_BILL_LEDGER_ID \
			and not bool(_story.get("_pending_after_result")) \
			and bool(GameState.flags.get("hyunsu_exam_day_seen", false)) \
			and _v2_story_receipt_count(
				"v2_hyunsu_exam_morning_echo", 0) == hyunsu_receipts,
		"Legacy Hyunsu result did not insert ledger before its saved result")
	var normalized_after_load := _json_round_trip_dictionary(state_after_hyunsu)
	# Root migration is the one intentional GameState difference; effects and
	# receipts below are compared directly around the ledger/result restoration.
	var hyunsu_effect_state_before := [
		int(GameState.health), int(GameState.mental), float(GameState.money),
		int(GameState.events_seen), GameState.flags.duplicate(true),
		_v2_story_receipt_count("v2_hyunsu_exam_morning_echo", 0),
	]
	_expect(bool(normalized_after_load.get("flags", {}).get(
		"hyunsu_exam_day_seen", false)),
		"Legacy Hyunsu saved state lost its already-applied exam-day flag")
	# Saving on the newly inserted ledger must also persist the hidden original
	# Hyunsu result position. Otherwise the second load would replay its choice.
	var inserted_ledger_resume: Dictionary = _story.call(
		"build_save_resume_context")
	_expect(inserted_ledger_resume.get(
			"first_bill_post_ledger_resume", {}) is Dictionary \
			and not (inserted_ledger_resume.get(
				"first_bill_post_ledger_resume", {}) as Dictionary).is_empty(),
		"Inserted ledger save omitted the original Hyunsu result position")
	_expect(SaveManager.save_game(TEST_SLOT, inserted_ledger_resume),
		"Inserted First Bill ledger fixture could not be re-saved")
	await _free_story()
	_expect(SaveManager.load_game(TEST_SLOT),
		"Inserted First Bill ledger fixture could not be reloaded")
	if not await _spawn_loaded_story():
		return
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) \
			== CORE_LOOP.FIRST_BILL_LEDGER_ID \
			and not (_story.get(
				"_first_bill_post_ledger_resume_context") as Dictionary).is_empty(),
		"Reloading the inserted ledger lost the saved Hyunsu result position")
	_show_current_story_choices()
	_story.call("_on_choice", 0)
	_story.call("_complete_typing")
	_story.call("_after_result")
	await get_tree().process_frame
	_story.call("_finish_story_scene_transition")
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) \
			== "v2_hyunsu_exam_morning_echo" \
			and bool(_story.get("_pending_after_result")) \
			and int(_story.get("_pending_result_choice_index")) == 0 \
			and [
				int(GameState.health), int(GameState.mental), float(GameState.money),
				int(GameState.events_seen), GameState.flags.duplicate(true),
				_v2_story_receipt_count("v2_hyunsu_exam_morning_echo", 0),
			] == hyunsu_effect_state_before,
		"Legacy Hyunsu result was not restored after ledger or replayed its effects")


func _check_first_bill_nonstory_legacy_state_migration() -> void:
	await _free_story()
	_clear_first_bill_meta_fixture()
	var prepared := _prepare_first_bill_fixture(
		40, false, "구저장민준", "gosiwon", 654_321.0)
	if prepared.is_empty():
		_fail("Non-story legacy First Bill fixture could not prepare")
		return
	_apply_first_bill_story_choice_once(CORE_LOOP.FIRST_BILL_DECISION_ID, 0)
	var postchoice_mental := int(GameState.mental)
	_downgrade_first_bill_context_to_legacy()
	var state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	state["active_bundle"] = ""
	state["active_kind"] = ""
	state["active_turn"] = 0
	GameState.core_loop_v2_state = state
	GameState.turn = 25
	_expect(CORE_LOOP.migrate_legacy_first_bill_state(),
		"Completed legacy First Bill state did not migrate without a story resume")
	var migrated_context: Dictionary = GameState.core_loop_v2_state.get(
		"demo_collision_context", {})
	var recovered := _stored_complete_first_bill_snapshot()
	_expect(migrated_context.get("roots", []) == [
			CORE_LOOP.FIRST_BILL_OPENING_ID,
		] and int(GameState.mental) == postchoice_mental \
			and recovered.is_empty() \
			and not MetaProgression.has_seen_scene(
				CORE_LOOP.FIRST_BILL_OPENING_ID),
		"Completed non-story legacy save lost its root or invented an archive frame")
	_expect(not CORE_LOOP.migrate_legacy_first_bill_state() \
			and _stored_complete_first_bill_snapshot() == recovered,
		"Completed non-story legacy migration was not idempotent")

	# If the old story session did capture an exact pre-choice frame, root
	# migration must preserve it verbatim rather than replacing it with a
	# reconstructed post-close inverse.
	_clear_first_bill_meta_fixture()
	var exact_prepared := _prepare_first_bill_fixture(
		40, false, "정확기록민준", "gosiwon", 765_432.0)
	if exact_prepared.is_empty():
		_fail("Exact non-story First Bill fixture could not prepare")
		return
	var exact_prechoice := CORE_LOOP.build_first_bill_replay_snapshot(false)
	var exact_complete := CORE_LOOP.first_bill_replay_snapshot_with_choice(
		exact_prechoice, 0)
	_apply_first_bill_story_choice_once(CORE_LOOP.FIRST_BILL_DECISION_ID, 0)
	_expect(not exact_complete.is_empty() \
			and MetaProgression.record_scene_replay_snapshot(
				CORE_LOOP.FIRST_BILL_OPENING_ID, exact_complete),
		"Exact legacy First Bill snapshot could not be stored")
	MetaProgression.record_scene_seen(CORE_LOOP.FIRST_BILL_OPENING_ID)
	var exact_stored_before := _stored_complete_first_bill_snapshot()
	_downgrade_first_bill_context_to_legacy()
	state = GameState.core_loop_v2_state.duplicate(true)
	state["active_bundle"] = ""
	state["active_kind"] = ""
	state["active_turn"] = 0
	GameState.core_loop_v2_state = state
	GameState.turn = 25
	var exact_root_migrated := CORE_LOOP.migrate_legacy_first_bill_state()
	var exact_after := _stored_complete_first_bill_snapshot()
	_expect(exact_root_migrated \
			and not exact_stored_before.is_empty() \
			and exact_after == exact_stored_before \
			and MetaProgression.has_seen_scene(
				CORE_LOOP.FIRST_BILL_OPENING_ID),
		"Exact legacy First Bill archive changed during root-only migration: " \
			+ "migrated=%s stored=%s expected=%s seen=%s" % [
				str(exact_root_migrated), str(exact_after),
				str(exact_stored_before),
				str(MetaProgression.has_seen_scene(
					CORE_LOOP.FIRST_BILL_OPENING_ID)),
			])


func _check_first_bill_archive_catalog_source() -> void:
	var source := FileAccess.get_file_as_string("res://scenes/StartMenu.gd")
	var catalog_start := source.find("const ARCHIVE_SCENE_IDS")
	var catalog_end := source.find("]\n", catalog_start)
	var catalog := source.substr(
		catalog_start, catalog_end - catalog_start + 2) \
		if catalog_start >= 0 and catalog_end > catalog_start else ""
	_expect(not catalog.is_empty() \
			and catalog.count('"v2_demo_first_bill_opening"') == 1 \
			and catalog.count('"v2_demo_first_bill"') == 0,
		"StartMenu archive catalog does not contain opening once and decision zero times")
	var complete := _stored_complete_first_bill_snapshot()
	var empty_receipt := complete.duplicate(true)
	empty_receipt["obligation_receipt"] = {}
	var malformed_receipt := complete.duplicate(true)
	malformed_receipt["obligation_receipt"] = "not-a-receipt"
	_expect(not complete.is_empty() \
			and CORE_LOOP.validated_complete_first_bill_replay_snapshot(
				empty_receipt).is_empty() \
			and CORE_LOOP.validated_complete_first_bill_replay_snapshot(
				malformed_receipt).is_empty(),
		"First Bill archive completion gate accepted an empty or malformed receipt")


func _prepare_first_bill_fixture(
		health: int, include_hyunsu: bool, player_name: String,
		housing: String, money: float, dirty_recruiter: bool = false) -> Dictionary:
	GameState.start_new_game()
	CORE_LOOP.initialize_for_run(true)
	GameState.turn = 24
	GameState.year = 1
	GameState.month = 6
	GameState.week_of_month = 4
	GameState.health = health
	GameState.player_name = player_name
	GameState.housing = housing
	GameState.money = money
	if dirty_recruiter:
		GameState.flags["fell_to_darkness"] = true
	if include_hyunsu:
		var state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
		var completed: Array = state.get("completed_bundles", []).duplicate()
		if not completed.has("hyunsu_study_followup"):
			completed.append("hyunsu_study_followup")
		state["completed_bundles"] = completed
		var stages: Dictionary = state.get(
			"relationship_stages", {}).duplicate(true)
		stages["hyunsu"] = "shared_commitment"
		state["relationship_stages"] = stages
		GameState.core_loop_v2_state = state
	if not CORE_LOOP.begin_bundle("demo_collision", "schedule"):
		_fail("First Bill fixture could not begin at Week 24")
		return {}
	var prepared: Dictionary = CORE_LOOP.prepare_demo_collision()
	if not bool(prepared.get("ok", false)):
		_fail("First Bill fixture preparation failed: %s" % prepared)
		return {}
	return prepared


func _clear_first_bill_meta_fixture() -> void:
	var snapshots: Dictionary = MetaProgression.data.get(
		"scene_replay_snapshots", {}).duplicate(true)
	snapshots.erase(CORE_LOOP.FIRST_BILL_OPENING_ID)
	MetaProgression.data["scene_replay_snapshots"] = snapshots
	var raw_seen: Variant = MetaProgression.data.get("seen_scenes", [])
	var seen: Array = (raw_seen as Array).duplicate() if raw_seen is Array else []
	while seen.has(CORE_LOOP.FIRST_BILL_OPENING_ID):
		seen.erase(CORE_LOOP.FIRST_BILL_OPENING_ID)
	while seen.has(CORE_LOOP.FIRST_BILL_DECISION_ID):
		seen.erase(CORE_LOOP.FIRST_BILL_DECISION_ID)
	MetaProgression.data["seen_scenes"] = seen
	MetaProgression.save_meta()


func _stored_complete_first_bill_snapshot() -> Dictionary:
	return CORE_LOOP.validated_complete_first_bill_replay_snapshot(
		MetaProgression.get_scene_replay_snapshot(
			CORE_LOOP.FIRST_BILL_OPENING_ID))


func _validated_story_first_bill_snapshot() -> Dictionary:
	if not is_instance_valid(_story):
		return {}
	var raw_snapshot: Variant = _story.get("_first_bill_replay_snapshot")
	if not raw_snapshot is Dictionary:
		return {}
	return CORE_LOOP.validated_complete_first_bill_replay_snapshot(
		raw_snapshot as Dictionary)


func _show_current_story_choices() -> void:
	if not is_instance_valid(_story):
		return
	_story.call("_finish_story_scene_transition")
	_story.set("_para_index", (_story.get("_paragraphs") as Array).size() - 1)
	_story.call("_complete_typing")
	_story.call("_show_choices")


func _advance_opening_expression_to_decision(choice_index: int) -> void:
	if not is_instance_valid(_story) \
			or str((_story.get("_current") as Dictionary).get("id", "")) \
				!= CORE_LOOP.FIRST_BILL_OPENING_ID:
		_fail("First Bill replay was not on its opening before expression choice")
		return
	_show_current_story_choices()
	_story.call("_on_choice", choice_index)
	_story.call("_complete_typing")
	_story.call("_after_result")
	_story.call("_finish_story_scene_transition")


func _current_story_text() -> String:
	if not is_instance_valid(_story):
		return ""
	var combined := ""
	for raw_paragraph in _story.get("_paragraphs") as Array:
		combined += str(raw_paragraph) + "\n"
	return combined


func _spawn_first_bill_replay() -> bool:
	SaveManager.clear_loaded_resume_context()
	GameState.pending_story_queue = [CORE_LOOP.FIRST_BILL_OPENING_ID]
	GameState.story_return_scene = "res://scenes/StartMenu.tscn"
	GameState.story_replay_mode = true
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(_story) or not _story.has_method("_set_auto_mode"):
		_fail("First Bill read-only replay fixture could not be instantiated")
		return false
	_story.call("_set_auto_mode", false, false, false)
	_story.call("_finish_story_scene_transition")
	var actual := str((_story.get("_current") as Dictionary).get("id", ""))
	if actual != CORE_LOOP.FIRST_BILL_OPENING_ID:
		_fail("First Bill read-only replay loaded %s instead of opening" % actual)
		return false
	return true


func _apply_first_bill_story_choice_once(event_id: String, choice_index: int) -> void:
	var event: Dictionary = DataRegistry.find_event(event_id)
	var choices: Array = event.get("choices", [])
	if event.is_empty() or choice_index < 0 or choice_index >= choices.size():
		_fail("First Bill legacy fixture has no %s choice %d" % [
			event_id, choice_index,
		])
		return
	GameState.apply_choice(event, choices[choice_index] as Dictionary)
	_expect(CORE_LOOP.note_story_choice(event_id, choice_index),
		"First Bill legacy fixture could not record %s choice %d" % [
			event_id, choice_index,
		])


func _downgrade_first_bill_context_to_legacy() -> void:
	var state: Dictionary = GameState.core_loop_v2_state.duplicate(true)
	var context: Dictionary = state.get(
		"demo_collision_context", {}).duplicate(true)
	var roots: Array = context.get("roots", []).duplicate()
	for index in range(roots.size()):
		if str(roots[index]) == CORE_LOOP.FIRST_BILL_OPENING_ID:
			roots[index] = CORE_LOOP.FIRST_BILL_DECISION_ID
	context["roots"] = roots
	state["demo_collision_context"] = context
	GameState.core_loop_v2_state = state


func _legacy_story_context(
		event_id: String, phase: String, queue: Array,
		choice_index: int = -1, pending_follow_up: String = "") -> Dictionary:
	return {
		"kind": "story",
		"scene": "res://scenes/StoryMode.tscn",
		"return_scene": "res://scenes/MainGame.tscn",
		"event_id": event_id,
		"queue": queue.duplicate(true),
		"phase": phase,
		"story_locale": LocaleManager.language,
		"pending_result_choice_index": choice_index,
		"pending_follow_up": pending_follow_up,
	}


func _json_round_trip_dictionary(source: Dictionary) -> Dictionary:
	var parsed: Variant = JSON.parse_string(JSON.stringify(source))
	return parsed as Dictionary if parsed is Dictionary else {}


func _check_story_save_surface() -> void:
	if not is_instance_valid(_story):
		return
	_story.call("_open_audio_settings")
	await get_tree().process_frame
	_story.call("_open_story_save_load")
	await get_tree().process_frame
	var popup := _story.get("_audio_settings_popup") as Control
	_expect(is_instance_valid(popup), "StoryMode save popup did not open")
	if not is_instance_valid(popup):
		return
	var save_controls := _find_meta_buttons(popup, "story_save_control")
	var load_controls := _find_meta_buttons(popup, "story_load_control")
	_expect(save_controls.size() == 5 and load_controls.size() == 5,
		"StoryMode save page is not a five-row no-scroll surface")
	var panel := _find_panel(popup)
	if panel != null:
		_expect(panel.size.x <= 900.0 and panel.size.y <= 570.0,
			"StoryMode save panel does not fit the 960x600 contract")
	_story.call("_set_story_save_page", 1)
	await get_tree().process_frame
	popup = _story.get("_audio_settings_popup") as Control
	save_controls = _find_meta_buttons(popup, "story_save_control")
	_expect(save_controls.size() == 5, "StoryMode second page does not expose slots 6-10")

func _spawn_story(event_id: String) -> bool:
	SaveManager.clear_loaded_resume_context()
	GameState.pending_story_queue = [event_id]
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(_story) or not _story.has_method("_set_auto_mode"):
		_fail("StoryMode fixture could not be instantiated")
		return false
	_story.call("_set_auto_mode", false, false, false)
	_story.call("_finish_story_scene_transition")
	var actual := str((_story.get("_current") as Dictionary).get("id", ""))
	if actual != event_id:
		_fail("StoryMode fixture loaded %s instead of %s" % [actual, event_id])
		return false
	return true


func _spawn_pending_story_queue(
		queue: Array, expected_event_id: String,
		read_only_replay: bool = false) -> bool:
	SaveManager.clear_loaded_resume_context()
	GameState.pending_story_queue = queue.duplicate(true)
	GameState.story_return_scene = (
		"res://scenes/StartMenu.tscn" if read_only_replay \
		else "res://scenes/MainGame.tscn")
	GameState.story_replay_mode = read_only_replay
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(_story) or not _story.has_method("_set_auto_mode"):
		_fail("stale pending StoryMode fixture could not be instantiated")
		return false
	_story.call("_set_auto_mode", false, false, false)
	_story.call("_finish_story_scene_transition")
	var actual: String = str(
		(_story.get("_current") as Dictionary).get("id", ""))
	if actual != expected_event_id:
		_fail("stale pending StoryMode fixture loaded %s instead of %s" % [
			actual, expected_event_id,
		])
		return false
	return true

func _spawn_loaded_story() -> bool:
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(_story) or not _story.has_method("_set_auto_mode"):
		_fail("loaded StoryMode fixture could not be instantiated")
		return false
	_story.call("_set_auto_mode", false, false, false)
	_story.call("_finish_story_scene_transition")
	return true

func _free_story() -> void:
	if is_instance_valid(_story):
		_story.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame
	_story = null

func _stop_test_audio() -> void:
	# StoryMode exit restores ambience and delayed paragraph cues may still own
	# playback objects for a frame. Invalidate those cues and release every test
	# player before the headless process exits so leak diagnostics stay actionable.
	AudioManager.begin_story_audio_event("manual_save_check_cleanup")
	AudioManager.stop_gamepad_vibration()
	var pool_value: Variant = AudioManager.get("_pool")
	if pool_value is Array:
		for raw_player in pool_value as Array:
			if raw_player is AudioStreamPlayer:
				var player := raw_player as AudioStreamPlayer
				player.stop()
				player.stream = null
	var sounds_value: Variant = AudioManager.get("_sounds")
	if sounds_value is Dictionary:
		(sounds_value as Dictionary).clear()
	BGMPlayer.stop()
	for property_name in [
		"_player_a", "_player_b", "_ambience_player", "_season_player",
		"_human_ambience_player",
	]:
		var value: Variant = BGMPlayer.get(property_name)
		if value is AudioStreamPlayer:
			var player := value as AudioStreamPlayer
			player.stop()
			player.stream = null

func _find_meta_buttons(root: Control, key: String) -> Array[Button]:
	var buttons: Array[Button] = []
	for node in root.find_children("*", "Button", true, false):
		if node is Button and bool((node as Button).get_meta(key, false)):
			buttons.append(node as Button)
	return buttons

func _find_panel(root: Control) -> PanelContainer:
	for node in root.find_children("*", "PanelContainer", true, false):
		if node is PanelContainer:
			return node as PanelContainer
	return null

func _count_dialogue_kind(entries: Array, kind: String) -> int:
	var count := 0
	for raw_entry in entries:
		if raw_entry is Dictionary \
				and str((raw_entry as Dictionary).get("kind", "")) == kind:
			count += 1
	return count

func _dialogue_entries_for_serial(entries: Array, event_serial: int) -> Array:
	var matching: Array = []
	for raw_entry in entries:
		if raw_entry is Dictionary \
				and int((raw_entry as Dictionary).get(
					"event_serial", 0)) == event_serial:
			matching.append((raw_entry as Dictionary).duplicate(true))
	return matching

func _dialogue_entries_text(entries: Array) -> String:
	var pieces: Array[String] = []
	for raw_entry in entries:
		if raw_entry is Dictionary:
			pieces.append(str((raw_entry as Dictionary).get("text", "")))
	return " ".join(pieces)

func _v2_story_receipt_count(event_id: String, choice_index: int) -> int:
	var count := 0
	var raw_receipts: Variant = GameState.core_loop_v2_state.get(
		"story_choice_receipts", {})
	if not raw_receipts is Dictionary:
		return 0
	for raw_receipt in (raw_receipts as Dictionary).values():
		if raw_receipt is Dictionary \
				and str((raw_receipt as Dictionary).get("event_id", "")) \
					== event_id \
				and int((raw_receipt as Dictionary).get("choice_index", -1)) \
					== choice_index:
			count += 1
	return count

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)

func _fail(message: String) -> void:
	_failures.append(message)

func _backup_test_slots() -> void:
	for slot in [TEST_SLOT, LEGACY_SLOT, CONTRACT_SLOT]:
		var path := SaveManager.slot_path(slot)
		var owned_paths := [
			path, "%s.bak" % path, "%s.tmp" % path,
			"%s.bak.tmp" % path, "%s.recovery.tmp" % path,
		]
		var slot_backup: Dictionary = {}
		for owned_path in owned_paths:
			slot_backup[str(owned_path)] = {
				"existed": FileAccess.file_exists(str(owned_path)),
				"bytes": FileAccess.get_file_as_bytes(str(owned_path)) \
					if FileAccess.file_exists(str(owned_path)) \
					else PackedByteArray(),
			}
		_backups[slot] = slot_backup

func _backup_settings_file() -> void:
	var path := SaveManager.SETTINGS_PATH
	_settings_backup = {
		"existed": FileAccess.file_exists(path),
		"bytes": FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) \
				else PackedByteArray(),
	}

func _backup_meta_progression() -> void:
	var path := MetaProgression.META_SAVE_PATH
	_meta_file_backup = {
		"existed": FileAccess.file_exists(path),
		"bytes": FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) \
				else PackedByteArray(),
	}
	_meta_data_backup = MetaProgression.data.duplicate(true)
	var new_this_run: Variant = MetaProgression.get("_new_this_run")
	_meta_new_this_run_backup = (
		(new_this_run as Dictionary).duplicate(true)
		if new_this_run is Dictionary else {"achievements": []})

func _restore_meta_progression() -> void:
	if _meta_file_backup.is_empty():
		return
	var path := MetaProgression.META_SAVE_PATH
	if bool(_meta_file_backup.get("existed", false)):
		var file := FileAccess.open(path, FileAccess.WRITE)
		if file != null:
			file.store_buffer(_meta_file_backup.get("bytes", PackedByteArray()))
			file.close()
	elif FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	MetaProgression.data = _meta_data_backup.duplicate(true)
	MetaProgression.set(
		"_new_this_run", _meta_new_this_run_backup.duplicate(true))
	_meta_file_backup.clear()
	_meta_data_backup.clear()
	_meta_new_this_run_backup.clear()

func _restore_settings_file() -> void:
	if _settings_backup.is_empty():
		return
	var path := SaveManager.SETTINGS_PATH
	if bool(_settings_backup.get("existed", false)):
		var file := FileAccess.open(path, FileAccess.WRITE)
		if file != null:
			file.store_buffer(_settings_backup.get("bytes", PackedByteArray()))
			file.close()
	elif FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	_settings_backup.clear()

func _restore_test_slots() -> void:
	for slot in _backups:
		var slot_backup: Dictionary = _backups[slot]
		for raw_path in slot_backup:
			var path := str(raw_path)
			var backup: Dictionary = slot_backup[raw_path]
			if bool(backup.get("existed", false)):
				var file := FileAccess.open(path, FileAccess.WRITE)
				if file != null:
					file.store_buffer(backup.get("bytes", PackedByteArray()))
					file.close()
			elif FileAccess.file_exists(path):
				DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
			elif DirAccess.dir_exists_absolute(
					ProjectSettings.globalize_path(path)):
				DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	_backups.clear()

func _finish() -> void:
	await _free_story()
	_stop_test_audio()
	_restore_test_slots()
	_restore_settings_file()
	_restore_meta_progression()
	SaveManager.clear_loaded_resume_context()
	await get_tree().process_frame
	await get_tree().process_frame
	_stop_test_audio()
	# The dummy/headless audio driver releases playback references on its own
	# mix tick rather than on a rendered frame, so give it one short real-time
	# interval after stop/stream detachment before asserting a clean shutdown.
	await get_tree().create_timer(0.25).timeout
	_stop_test_audio()
	await get_tree().create_timer(0.10).timeout
	if _failures.is_empty():
		print("MANUAL_SAVE_CHECK_OK slots=10 durability=temp-readback/verified-backup/primary-preserved/retry/recovery/compatible-backup-preserved/wrong-type/missing-key manual_feedback=failure-stays/success-close identity=current/partial/unknown/full-demo/v2-isolated/completion-turn25-exact/cutoff future=reject-before-state prose=source_progress locale_mismatch=rewind choices=1 result_once=1 result_variant=sangchul-father-passed/result-once/current-serial-history/event-action-logs/nonresult-prose+choices-restart stale_queue=alive-original/death-canonical+legacy+cast/passed-variants/living-only-skip/769-iterative-skip/769-curation-iterative-skip/read-only-history father_passing=blocked5/event-manager+story-queue/terminal-result2/once/cross-splice2-reject/latest-receipt2-reject timer=1 pages=2 dialogue_history=prose/choice/result/legacy_notice first_bill=expression/decision/ledger+preclamp_H3_H99+fatal_short_circuit+frozen_replay+local_ledger+hyunsu+legacy_atomic+old_dirty_generic_inert+nonstory_root_only/no_synthetic_archive archive=opening1/decision0 meta=restored")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("MANUAL_SAVE_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)

func _exit_tree() -> void:
	_stop_test_audio()
	_restore_test_slots()
	_restore_settings_file()
	_restore_meta_progression()
