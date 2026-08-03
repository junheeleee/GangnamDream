extends Node
## ManualSaveCheck — 10슬롯과 StoryMode 중간 재개 계약을 실제 런타임으로 검증한다.

const CORE_LOOP := preload("res://systems/DemoCoreLoopV2.gd")
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
	await _check_prose_resume()
	await _check_choice_and_result_resume()
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
			and ledger_text.contains("마감을 놓친 일 — 오후 6시 30분") \
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
		_backups[slot] = {
			"existed": FileAccess.file_exists(path),
			"bytes": FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) \
					else PackedByteArray(),
		}

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
		var path := SaveManager.slot_path(int(slot))
		var backup: Dictionary = _backups[slot]
		if bool(backup.get("existed", false)):
			var file := FileAccess.open(path, FileAccess.WRITE)
			if file != null:
				file.store_buffer(backup.get("bytes", PackedByteArray()))
				file.close()
		elif FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	_backups.clear()

func _finish() -> void:
	await _free_story()
	_restore_test_slots()
	_restore_settings_file()
	_restore_meta_progression()
	SaveManager.clear_loaded_resume_context()
	await get_tree().process_frame
	await get_tree().process_frame
	if _failures.is_empty():
		print("MANUAL_SAVE_CHECK_OK slots=10 legacy=v3/v4 identity=current/partial/unknown build_mismatch=warning flavor=full-demo/v2-isolated/cutoff future=reject-before-state prose=source_progress locale_mismatch=rewind choices=1 result_once=1 timer=1 pages=2 dialogue_history=prose/choice/result/legacy_notice first_bill=expression/decision/ledger+preclamp_H3_H99+fatal_short_circuit+frozen_replay+local_ledger+hyunsu+legacy_atomic+nonstory_root_only/no_synthetic_archive archive=opening1/decision0 meta=restored")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("MANUAL_SAVE_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)

func _exit_tree() -> void:
	_restore_test_slots()
	_restore_settings_file()
	_restore_meta_progression()
