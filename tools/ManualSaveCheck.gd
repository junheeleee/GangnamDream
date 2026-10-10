extends Node
## ManualSaveCheck — 10슬롯과 StoryMode 중간 재개 계약을 실제 런타임으로 검증한다.

const CORE_LOOP := preload("res://systems/DemoCoreLoopV2.gd")
const CHAPTER5_CAUSAL_ROUTE := preload("res://systems/Chapter5CausalRoute.gd")
const CHAPTER5_FINALE_ROUTE := preload("res://systems/Chapter5FinaleRoute.gd")
const MAIN_GAME_SCENE := preload("res://scenes/MainGame.tscn")
const STORY_MODE_SCRIPT := preload("res://scenes/StoryMode.gd")
const INVESTMENT_SYSTEM_SCRIPT := preload("res://systems/InvestmentSystem.gd")
const FULL_STORY_FLOW := preload("res://systems/FullStoryFlow.gd")
const STORY_DEMO_CONTROLLER := preload("res://playtests/order124/StoryChoiceM1M6Playtest.gd")
const TEST_SLOT := 1
const LEGACY_SLOT := 9
const CONTRACT_SLOT := 10
const CHAPTER5_REQUIRED_ENTRY_FLAGS: Array[String] = [
	"arc_sangchul_met_seen",
	"arc_daeun_met",
	"daeun_romance_started",
	"arc_minseo_02_seen",
	"arc_jaehyuk_reunion_seen",
	"arc_jaehyuk_aftermath_seen",
]
const CHAPTER5_EXCLUDED_ENTRY_FLAGS: Array[String] = [
	"sangchul_reported", "sangchul_cut_ties", "sangchul_quietly_distanced",
	"daeun_let_her_go", "daeun_divorced", "arc_jaehyuk_mirror_seen",
	"refused_jaehyuk_guarantee", "vouched_jaehyuk_guarantee",
	"blocked_jaehyuk_guarantee", "jaehyuk_final_break",
]
const CHAPTER5_ENTRY_SNAPSHOT := {
	"route_id": "investment_property",
	"turn": 195,
	"economic_route": "investment",
	"asset_band": "at_least_2b",
	"actor_bindings": {
		"chooser": "player", "proposer": "sangchul", "reviewer": "sangchul",
		"protected_person": "daeun", "guarantee_party": "jaehyuk",
		"cost_witness": "minseo",
	},
}

var _story: Control = null
var _failures: Array[String] = []
var _backups: Dictionary = {}
var _settings_backup: Dictionary = {}
var _meta_file_backup: Dictionary = {}
var _meta_data_backup: Dictionary = {}
var _meta_new_this_run_backup: Dictionary = {}
var _monthly_economy_only := false
var _monthly_economy_checked := false
var _full_story_flow_only := false
var _full_story_flow_checked := false
var _full_story_third_month_checked := false
var _paycheck_window_only := false
var _paycheck_window_checked := false
var _full_story_production_only := false
var _full_story_production_checked := false
var _full_story_date_only := false
var _full_story_date_checked := false
var _full_story_date_exclusion := ""

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	_backup_settings_file()
	_backup_meta_progression()
	_backup_test_slots()
	_full_story_date_only = OS.get_cmdline_user_args().has("--full-story-date-only")
	if _full_story_date_only:
		await _check_full_story_meeting_date()
		await _finish()
		return
	_full_story_production_only = OS.get_cmdline_user_args().has("--full-story-production-only")
	if _full_story_production_only:
		await _check_full_story_production()
		await _finish()
		return
	_paycheck_window_only = OS.get_cmdline_user_args().has("--paycheck-window-only")
	if _paycheck_window_only:
		await _check_paycheck_window()
		await _finish()
		return
	_full_story_flow_only = OS.get_cmdline_user_args().has("--full-story-flow-only")
	if _full_story_flow_only:
		await _check_full_story_flow()
		await _finish()
		return
	_monthly_economy_only = OS.get_cmdline_user_args().has("--monthly-economy-only")
	if _monthly_economy_only:
		await _check_monthly_economy_resume()
		await _finish()
		return
	GameState.start_new_game()
	_check_chapter5_causal_disk_save_contract()
	GameState.start_new_game()
	_check_chapter5_finale_disk_save_contract()
	GameState.start_new_game()
	_check_chapter5_general_finale_disk_save_contract()
	GameState.start_new_game()
	_check_slot_and_legacy_contract()
	if not _failures.is_empty():
		await _finish()
		return
	await _check_main_game_save_failure_feedback()
	await _check_consumed_week_main_resume()
	await _check_monthly_economy_resume()
	await _check_full_story_flow()
	await _check_paycheck_window()
	await _check_full_story_production()
	await _check_full_story_meeting_date()
	if not _failures.is_empty():
		await _finish()
		return
	await _check_prose_resume()
	await _check_choice_and_result_resume()
	await _check_w207_result_presentation_resume_and_locale()
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

func _check_chapter5_causal_disk_save_contract() -> void:
	GameState.turn = 195
	GameState.money = 3_000_000_000.0
	var ineligible := GameState.record_chapter5_causal_choice(
		"arc_y5_contract_cover_investment", 2)
	_expect(not bool(ineligible.get("ok", false)) \
		and str(ineligible.get("error", "")) == "product_path_unavailable",
		"disk fixture manufactured Chapter 5 evidence for a career/default run")

	_prepare_chapter5_product_path()
	var committed := GameState.record_chapter5_causal_choice(
		"arc_y5_contract_cover_investment", 2)
	_expect(bool(committed.get("ok", false)),
		"Chapter 5 causal receipt could not be written before disk save")
	_expect(SaveManager.save_game(TEST_SLOT, {}, {"qa_fixture": true}),
		"Chapter 5 causal disk fixture could not be saved")
	GameState.start_new_game()
	_expect(SaveManager.load_game(TEST_SLOT),
		"Chapter 5 causal disk fixture could not be loaded")
	var receipt := GameState.chapter5_causal_receipt_snapshot(
		"arc_y5_contract_cover_investment")
	var entry := GameState.chapter5_causal_entry_snapshot()
	_expect(not receipt.is_empty() \
		and entry == CHAPTER5_ENTRY_SNAPSHOT \
		and typeof(entry.get("turn")) == TYPE_INT \
		and typeof(GameState.chapter5_causal_state.get("schema_version")) == TYPE_INT \
		and typeof(receipt.get("sequence")) == TYPE_INT \
		and typeof(receipt.get("turn")) == TYPE_INT \
		and typeof(receipt.get("choice_index")) == TYPE_INT \
		and GameState.chapter5_causal_receipt_matches(
			"arc_y5_contract_cover_investment", 2, 195),
		"Chapter 5 causal disk JSON roundtrip lost exact integer receipt evidence")
	GameState.turn = 196
	GameState.money = 0.0
	GameState.player_route = "직장형"
	GameState.flags.erase("route_invest")
	GameState.flags["daeun_let_her_go"] = true
	GameState.flags["sangchul_cut_ties"] = true
	_expect(GameState.chapter5_causal_product_path_available() \
		and GameState.chapter5_causal_next_event_for_turn() \
			== "arc_y5_contract_reviewer_delivery_sangchul",
		"loaded first receipt lost continuation after assets/entry context fell")
	SaveManager.clear_loaded_resume_context()

func _prepare_chapter5_product_path() -> void:
	GameState.start_new_game("김민준", "지방_상경", "투자형")
	GameState.turn = 195
	GameState.money = 2_100_000_000.0
	GameState.portfolio = {}
	GameState.loans = {"bank": 0.0, "second": 0.0}
	GameState.flags["route_invest"] = true
	for flag in CHAPTER5_REQUIRED_ENTRY_FLAGS:
		GameState.flags[flag] = true
	for flag in CHAPTER5_EXCLUDED_ENTRY_FLAGS:
		GameState.flags.erase(flag)

func _complete_chapter5_causal_product_route() -> bool:
	_prepare_chapter5_product_path()
	if not GameState.prepare_chapter5_causal_route_entry():
		return false
	var choices := {
		"arc_y5_jaehyuk_guarantee_decision_reference": 1,
		"arc_sangchul_final_door": 0,
		"arc_y5_three_in_room_decision": 1,
	}
	for turn_value in range(195, 221):
		GameState.turn = turn_value
		while true:
			var event_id := GameState.chapter5_causal_next_event_for_turn()
			if event_id.is_empty():
				break
			var result := GameState.record_chapter5_causal_choice(
				event_id, int(choices.get(event_id, 0)))
			if not bool(result.get("ok", false)):
				return false
	return CHAPTER5_CAUSAL_ROUTE.route_complete(
		GameState.chapter5_causal_state)

func _check_chapter5_finale_disk_save_contract() -> void:
	_expect(_complete_chapter5_causal_product_route(),
		"finale disk fixture could not complete its M49-M55 causal source")
	GameState.turn = 221
	_expect(GameState.prepare_chapter5_finale_route_entry(),
		"finale disk fixture could not lock its W221 entry")
	var first_event_id := GameState.chapter5_finale_next_event_for_turn()
	var committed := GameState.record_chapter5_finale_choice(first_event_id, 2)
	_expect(first_event_id == "arc_y5_father_trace_alive_exact" \
		and bool(committed.get("ok", false)),
		"finale disk fixture could not commit its exact father-trace choice")
	_expect(SaveManager.save_game(TEST_SLOT, {}, {"qa_fixture": true}),
		"Chapter 5 finale disk fixture could not be saved")
	GameState.start_new_game()
	_expect(SaveManager.load_game(TEST_SLOT),
		"Chapter 5 finale disk fixture could not be loaded")
	var entry := GameState.chapter5_finale_entry_snapshot()
	var receipt := CHAPTER5_FINALE_ROUTE.receipt_snapshot_for_event(
		GameState.chapter5_finale_state, first_event_id)
	_expect(str(entry.get("profile_id", "")) \
			== "investment_safe_no_execution" \
		and str(entry.get("source_route_id", "")) == "investment_property" \
		and typeof(entry.get("turn")) == TYPE_INT \
		and typeof(GameState.chapter5_finale_state.get("schema_version")) \
			== TYPE_INT \
		and typeof(receipt.get("turn")) == TYPE_INT \
		and typeof(receipt.get("choice_index")) == TYPE_INT \
		and GameState.chapter5_finale_receipt_matches(
			first_event_id, 2, 221),
		"finale disk JSON roundtrip lost exact entry/receipt integers")
	GameState.turn = 224
	_expect(GameState.chapter5_finale_next_event_for_turn() \
			== "arc_y5_father_trace_custody" \
		and GameState.chapter5_finale_holds_ending(),
		"loaded finale receipt did not continue to its exact W224 direct root")

	# A JSON-valid receipt mutation must fail closed instead of reopening a
	# choice or fabricating a later stage. The live state is replaced only by the
	# canonical closed state produced by load_from_dict.
	var tampered_payload: Dictionary = GameState.serialize().duplicate(true)
	var tampered_finale: Dictionary = (
		tampered_payload["chapter5_finale_state"] as Dictionary).duplicate(true)
	var tampered_receipts: Dictionary = (
		tampered_finale["receipts"] as Dictionary).duplicate(true)
	var tampered_receipt: Dictionary = (
		tampered_receipts[first_event_id] as Dictionary).duplicate(true)
	var original_choice_index := int(tampered_receipt["choice_index"])
	var tampered_choice_index := 0 if original_choice_index != 0 else 1
	var before_tamper_load := tampered_payload.duplicate(true)
	var expected_nonfinale := before_tamper_load.duplicate(true)
	expected_nonfinale.erase("chapter5_finale_state")
	tampered_receipt["choice_index"] = tampered_choice_index
	tampered_receipts[first_event_id] = tampered_receipt
	tampered_finale["receipts"] = tampered_receipts
	tampered_payload["chapter5_finale_state"] = tampered_finale
	GameState.start_new_game()
	GameState.load_from_dict(tampered_payload)
	var loaded_nonfinale: Dictionary = GameState.serialize().duplicate(true)
	loaded_nonfinale.erase("chapter5_finale_state")
	_expect(str(GameState.chapter5_finale_state.get("status", "")) == "closed" \
		and str(GameState.chapter5_finale_state.get("ending_check", "")) \
			== "consumed" \
		and GameState.chapter5_finale_entry_snapshot().is_empty() \
		and GameState.chapter5_finale_next_event_for_turn(224).is_empty() \
		and not GameState.chapter5_finale_holds_ending() \
		and loaded_nonfinale == expected_nonfinale,
		"tampered finale receipt did not fail closed without collateral state loss")

	# Missing-field legacy migration is only truthful through W220. At W221 the
	# missing father/source snapshot can no longer be invented.
	GameState.start_new_game()
	GameState.turn = 220
	var fresh_legacy: Dictionary = GameState.serialize().duplicate(true)
	fresh_legacy.erase("chapter5_finale_state")
	GameState.start_new_game()
	GameState.load_from_dict(fresh_legacy)
	_expect(str(GameState.chapter5_finale_state.get("status", "")) == "open" \
		and GameState.chapter5_finale_entry_snapshot().is_empty(),
		"through-W220 legacy save was not left eligible for truthful finale entry")
	var late_legacy: Dictionary = fresh_legacy.duplicate(true)
	late_legacy["turn"] = 221
	GameState.start_new_game()
	GameState.load_from_dict(late_legacy)
	_expect(str(GameState.chapter5_finale_state.get("status", "")) == "closed" \
		and str(GameState.chapter5_finale_state.get("closed_reason", "")) \
			== "legacy_missing" \
		and not GameState.chapter5_finale_holds_ending(),
		"W221+ legacy save fabricated a missing finale entry")
	SaveManager.clear_loaded_resume_context()


func _check_chapter5_general_finale_disk_save_contract() -> void:
	_seed_chapter5_general_sources()
	GameState.turn = 224
	_expect(GameState.prepare_chapter5_finale_route_entry(),
		"general finale disk fixture could not lock W224")
	var partial_events: Array[String] = [
		"arc_y5_general_father_legacy_voice_exact",
		"arc_y5_general_debt_memory_voice_exact",
		"arc_y5_general_pre_ending_summit_exact",
	]
	var partial_turns: Array[int] = [224, 229, 234]
	var partial_choices: Array[int] = [1, 0, 1]
	for index in range(partial_events.size()):
		GameState.turn = partial_turns[index]
		_expect(bool(GameState.record_chapter5_finale_choice(
			partial_events[index], partial_choices[index]).get("ok", false)),
			"general disk fixture could not commit %s" % partial_events[index])
	_expect(SaveManager.save_game(TEST_SLOT, {}, {"qa_fixture": true}),
		"general partial finale disk fixture could not be saved")
	GameState.start_new_game()
	_expect(SaveManager.load_game(TEST_SLOT),
		"general partial finale disk fixture could not be loaded")
	var entry := GameState.chapter5_finale_entry_snapshot()
	var first_receipt := CHAPTER5_FINALE_ROUTE.receipt_snapshot_for_event(
		GameState.chapter5_finale_state, partial_events[0])
	var summit_receipt := CHAPTER5_FINALE_ROUTE.receipt_snapshot_for_event(
		GameState.chapter5_finale_state, partial_events[2])
	_expect(str(entry.get("profile_id", "")) == CHAPTER5_FINALE_ROUTE.GENERAL_PROFILE_ID \
		and str(entry.get("source_route_id", "")) == CHAPTER5_FINALE_ROUTE.GENERAL_SOURCE_ROUTE_ID \
		and entry.get("actor_bindings", {}) == CHAPTER5_FINALE_ROUTE.GENERAL_ACTORS \
		and int(entry.get("turn", -1)) == 224 \
		and typeof(entry.get("turn")) == TYPE_INT \
		and typeof((entry.get("source_choices", {}) as Dictionary).get("m51_minseo_arrival")) == TYPE_INT \
		and typeof((entry.get("source_choices", {}) as Dictionary).get("w211_name_boundary")) == TYPE_INT \
		and typeof((entry.get("source_choices", {}) as Dictionary).get("w220_debt_memory_reconnect")) == TYPE_INT \
		and typeof(first_receipt.get("turn")) == TYPE_INT \
		and typeof(first_receipt.get("choice_index")) == TYPE_INT \
		and typeof(summit_receipt.get("choice_index")) == TYPE_INT \
		and (GameState.chapter5_finale_state.get("order", []) as Array).size() == 3,
		"general partial disk save lost exact entry/receipt integers")
	_expect(bool(GameState.flags.get("chapter5_general_minseo_arrival_1", false)) \
		and bool(GameState.flags.get("chapter5_general_name_boundary_0", false)) \
		and bool(GameState.flags.get("chapter5_general_debt_memory_reconnect_0", false)),
		"general partial disk save lost source choice flags")
	_expect(_general_source_log_is_exact(),
		"general partial disk save lost exact source event-log receipts: %s" \
		% JSON.stringify(GameState.event_log))
	var exact_source_log := GameState.event_log.duplicate(true)
	GameState.event_log.append((exact_source_log[0] as Dictionary).duplicate(true))
	_expect(not _general_source_log_is_exact(),
		"general source event-log matcher accepted a duplicate exact receipt")
	GameState.event_log = exact_source_log
	GameState.turn = 237
	_expect(GameState.chapter5_finale_next_event_for_turn() \
		== "arc_y5_general_final_record_seal" \
		and bool(GameState.record_chapter5_finale_choice(
			"arc_y5_general_final_record_seal", 1).get("ok", false)) \
		and GameState.chapter5_finale_week_completed(237),
		"general record disposition did not resume after disk save")
	GameState.turn = 240
	_expect(GameState.chapter5_finale_next_event_for_turn() \
		== "arc_final_countdown_general_near_goal_passed" \
		and bool(GameState.record_chapter5_finale_choice(
			"arc_final_countdown_general_near_goal_passed", 1).get("ok", false)) \
		and not GameState.chapter5_finale_ending_ready() \
		and GameState.chapter5_finale_next_event_for_turn() \
		== "arc_y5_final_week_general_people_outbound",
		"general sacrifice did not remain pending and expose same-turn outbound")
	_expect(bool(GameState.record_chapter5_finale_choice(
		"arc_y5_final_week_general_people_outbound", 0).get("ok", false)) \
		and GameState.chapter5_finale_ending_ready(),
		"general outbound did not reach ready before disk save")
	_expect(SaveManager.save_game(TEST_SLOT, {}, {"qa_fixture": true}),
		"general ready finale disk fixture could not be saved")
	GameState.start_new_game()
	_expect(SaveManager.load_game(TEST_SLOT) and GameState.chapter5_finale_ending_ready(),
		"general ready finale did not survive disk save")
	var consumed := GameState.consume_chapter5_finale_ending()
	_expect(bool(consumed.get("ok", false)) and GameState.chapter5_finale_ending_consumed(),
		"general ready finale did not consume before disk save")
	_expect(SaveManager.save_game(TEST_SLOT, {}, {"qa_fixture": true}),
		"general consumed finale disk fixture could not be saved")
	GameState.start_new_game()
	_expect(SaveManager.load_game(TEST_SLOT) \
		and GameState.chapter5_finale_ending_consumed() \
		and not GameState.chapter5_finale_holds_ending() \
		and bool(GameState.consume_chapter5_finale_ending().get("idempotent", false)),
		"general consumed finale did not survive disk save idempotently")
	SaveManager.clear_loaded_resume_context()


func _seed_chapter5_general_sources() -> void:
	GameState.start_new_game("김민준", "지방_상경", "투자형")
	GameState.money = 2_500_000_000.0
	GameState.flags["father_passed"] = true
	GameState.flags["chapter5_general_minseo_arrival_1"] = true
	GameState.flags["arc_y5_general_name_boundary_exact_seen"] = true
	GameState.flags["chapter5_general_name_boundary_0"] = true
	GameState.flags["arc_y5_general_debt_memory_reconnect_seen"] = true
	GameState.flags["chapter5_general_debt_memory_reconnect_0"] = true
	GameState.flags["arc_endgame_sixmonths_seen"] = true
	GameState.event_log = [
		{"event_id": "arc_minseo_03_arrival", "choice_index": 1, "turn": 203},
		{"event_id": "arc_y5_general_name_boundary_exact", "choice_index": 0, "turn": 211},
		{"event_id": "arc_y5_general_debt_memory_reconnect", "choice_index": 0, "turn": 220},
	]


func _general_source_log_is_exact() -> bool:
	var expected := {
		"arc_minseo_03_arrival": [1, 203],
		"arc_y5_general_name_boundary_exact": [0, 211],
		"arc_y5_general_debt_memory_reconnect": [0, 220],
	}
	var watched: Array = expected.keys()
	for raw in GameState.event_log:
		if not raw is Dictionary:
			continue
		var row: Dictionary = raw
		var event_id := str(row.get("event_id", ""))
		if event_id not in watched:
			continue
		if not expected.has(event_id):
			return false
		var values: Array = expected[event_id]
		if int(row.get("choice_index", -1)) != int(values[0]) \
				or int(row.get("turn", -1)) != int(values[1]):
			return false
		expected.erase(event_id)
	return expected.is_empty()

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
	_check_run_theme_disk_preservation()

func _check_run_theme_disk_preservation() -> void:
	var original: Dictionary = GameState.serialize().duplicate(true)
	var failures_before: int = _failures.size()
	for theme_case in [
		{"label": "explicit-free", "theme": "자유런", "categories": ["investment", "finance"],
			"missing": false, "expected": "자유런"},
		{"label": "explicit-investment", "theme": "투자런", "categories": ["social", "relationship"],
			"missing": false, "expected": "투자런"},
		{"label": "legacy-missing", "theme": "자유런", "categories": ["investment", "finance"],
			"missing": true, "expected": "투자런"},
	]:
		# Only the categories are made deterministic. The real selected starting
		# theme owns its original stats, money, flags, and logs; never reapply it.
		GameState.start_new_game("김민준", "지방_상경", "none", "백수", str(theme_case["theme"]))
		GameState.run_theme_categories = (theme_case["categories"] as Array).duplicate()
		var expected: Dictionary = GameState.serialize().duplicate(true)
		expected["run_theme"] = theme_case["expected"]
		_expect(SaveManager.save_game(CONTRACT_SLOT, {}, {"qa_fixture": true}),
			"%s theme fixture could not save" % theme_case["label"])
		if bool(theme_case["missing"]):
			# Missing-field compatibility is independent of the save envelope. Keep
			# the existing v4 contract and omit this one legacy state field only.
			var payload: Variant = JSON.parse_string(FileAccess.get_file_as_string(
				SaveManager.slot_path(CONTRACT_SLOT)))
			_expect(payload is Dictionary, "missing theme fixture could not read its payload")
			if not payload is Dictionary:
				continue
			(payload["state"] as Dictionary).erase("run_theme")
			var file := FileAccess.open(SaveManager.slot_path(CONTRACT_SLOT), FileAccess.WRITE)
			_expect(file != null, "missing theme fixture could not open its test slot")
			if file == null:
				continue
			file.store_string(JSON.stringify(payload))
			file.close()
		GameState.start_new_game()
		_expect(SaveManager.load_game(CONTRACT_SLOT),
			"%s theme fixture could not cold load" % theme_case["label"])
		_expect(_json_round_trip_dictionary(GameState.serialize()) \
				== _json_round_trip_dictionary(expected),
			"%s cold load changed its saved theme or rewrote another stat/log/money field" % theme_case["label"])
		_expect(SaveManager.save_game(CONTRACT_SLOT, {}, {"qa_fixture": true}) \
				and SaveManager.load_game(CONTRACT_SLOT) \
				and _json_round_trip_dictionary(GameState.serialize()) \
					== _json_round_trip_dictionary(expected),
			"%s theme reload reapplied starting rewards or lost its migration" % theme_case["label"])
	GameState.call("_restore_serialized_snapshot_exact", original)
	SaveManager.clear_loaded_resume_context()
	if _failures.size() == failures_before:
		print("MANUAL_SAVE_RUN_THEME_CHECK_OK cases=3 explicit=free/investment legacy=missing reload=twice other_state=exact-json")

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

func _check_consumed_week_main_resume() -> void:
	# Synthetic isolated Main save: the foreground was read, but the older
	# ambient latch still belongs to last week. Never read a player's checkpoint.
	GameState.start_new_game()
	GameState.turn = 200
	GameState.year = 2030
	GameState.month = 2
	GameState.week_of_month = 4
	GameState.age = 37
	GameState.money = 1_000_000.0
	GameState.action_points = 0
	GameState.flags.merge({
		"prologue_done": true,
		"arc_37_reckoning_seen": true,
		"arc_final_year_start_seen": true,
		"foreground_story_turn": 200,
		"month_event_turn": 199,
		# Keep the real entry on its decision surface, not an auto-advanced week.
		"demo_director_kind_turn": 200,
		"demo_director_locked_kind": "decision",
	}, true)
	var saved := SaveManager.save_game(TEST_SLOT, {}, {"qa_fixture": true})
	_expect(saved, "consumed-week fixture could not save its Main checkpoint")
	if not saved:
		return
	GameState.start_new_game()
	var loaded := SaveManager.load_game(TEST_SLOT)
	_expect(loaded and SaveManager.peek_loaded_resume_context().is_empty() \
			and SaveManager.loaded_scene_path() == "res://scenes/MainGame.tscn" \
			and GameState.turn == 200 \
			and int(GameState.flags.get("foreground_story_turn", -1)) == 200 \
			and int(GameState.flags.get("month_event_turn", -1)) == 199,
		"consumed-week disk reload lost its empty-resume Main/foreground state")
	if not loaded:
		return

	var main_game: Control = MAIN_GAME_SCENE.instantiate()
	main_game.set_meta("_screenshot_qa_static_surface", true)
	add_child(main_game)
	await get_tree().process_frame
	await get_tree().process_frame
	# Bootstrap legitimately initializes market/UI/transient state. Snapshot
	# after it so the guard itself must leave the entire serialized state inert.
	var cooldown_probe := "manual_save_situation_guard"
	EventManager.event_cooldowns = {cooldown_probe: 5}
	GameState.pending_story_queue = ["yolo_morning_after"]
	var before_guard: Dictionary = GameState.serialize().duplicate(true)
	var guard_flags := GameState.flags.duplicate(true)
	var guard_queue := GameState.pending_story_queue.duplicate(true)
	var guard_cooldowns := EventManager.event_cooldowns.duplicate(true)
	_expect(not bool(main_game.call("_maybe_play_month_situation")) \
			and GameState.serialize() == before_guard \
			and GameState.flags == guard_flags \
			and GameState.pending_story_queue == guard_queue \
			and EventManager.event_cooldowns == guard_cooldowns,
		"consumed-current guard changed state/flags/queue or attempted a draw")

	GameState.pending_story_queue.clear()
	main_game.set_meta("_qa_core_loop_v2_begin_month_call_count", 0)
	main_game.call("_begin_month")
	_expect(int(main_game.get_meta("_qa_core_loop_v2_begin_month_call_count")) == 1 \
			and GameState.turn == 200 \
			and GameState.action_points == GameState.max_action_points \
			and GameState.flags == guard_flags \
			and GameState.pending_story_queue.is_empty() \
			and EventManager.event_cooldowns == guard_cooldowns \
			and (main_game.get("current_event") as Dictionary).is_empty() \
			and is_instance_valid(main_game.get("_ap_action_grid")),
		"saved consumed-week Main entry added a story/draw or failed to reach actions")

	# A single real eligible candidate makes each allowed draw's handoff exact;
	# restore the registry immediately after these synchronous calls. No event
	# text, conditions, selection policy, or persistent content is rewritten.
	var original_events: Array = DataRegistry.events
	var candidate: Dictionary = DataRegistry.find_event("yolo_spend_moment")
	_expect(not candidate.is_empty(), "ambient resume fixture lacks its real candidate")
	DataRegistry.events = [candidate]
	for guard_case in [
		{"name": "missing", "turn": 200, "foreground": -1},
		{"name": "stale", "turn": 200, "foreground": 199},
		{"name": "next-week", "turn": 201, "foreground": 200},
	]:
		GameState.turn = int(guard_case["turn"])
		GameState.flags.erase("foreground_story_turn")
		if int(guard_case["foreground"]) >= 0:
			GameState.flags["foreground_story_turn"] = int(guard_case["foreground"])
		GameState.flags["month_event_turn"] = 199
		GameState.pending_story_queue.clear()
		EventManager.event_cooldowns = {cooldown_probe: 5}
		_expect(bool(main_game.call("_maybe_play_month_situation")) \
				and GameState.pending_story_queue == ["yolo_spend_moment"] \
				and int(GameState.flags.get("foreground_story_turn", -1)) == GameState.turn \
				and int(GameState.flags.get("month_event_turn", -1)) == GameState.turn \
				and int(EventManager.event_cooldowns.get(cooldown_probe, -1)) == 4 \
				and int(EventManager.event_cooldowns.get("yolo_spend_moment", -1)) \
					== EventManager.cooldown_for_event(candidate),
			"%s foreground blocked the original ambient draw/handoff" % guard_case["name"])
		# Remove the new foreground guard to exercise the original ambient latch.
		GameState.flags.erase("foreground_story_turn")
		var after_draw: Dictionary = GameState.serialize().duplicate(true)
		var after_draw_queue := GameState.pending_story_queue.duplicate(true)
		var after_draw_cooldowns := EventManager.event_cooldowns.duplicate(true)
		_expect(not bool(main_game.call("_maybe_play_month_situation")) \
				and GameState.serialize() == after_draw \
				and GameState.pending_story_queue == after_draw_queue \
				and EventManager.event_cooldowns == after_draw_cooldowns,
			"%s foreground redrew through the same-turn ambient latch" % guard_case["name"])
	DataRegistry.events = original_events

	GameState.turn = 1
	GameState.flags["month_event_turn"] = 0
	var first_week_state: Dictionary = GameState.serialize().duplicate(true)
	var first_week_queue := GameState.pending_story_queue.duplicate(true)
	var first_week_cooldowns := EventManager.event_cooldowns.duplicate(true)
	_expect(not bool(main_game.call("_maybe_play_month_situation")) \
			and GameState.serialize() == first_week_state \
			and GameState.pending_story_queue == first_week_queue \
			and EventManager.event_cooldowns == first_week_cooldowns,
		"first-week ambient exclusion changed state or attempted a draw")
	main_game.get_parent().remove_child(main_game)
	main_game.free()
	BGMPlayer.stop()
	SaveManager.clear_loaded_resume_context()
	GameState.start_new_game()
	await get_tree().process_frame

func _check_monthly_economy_resume() -> void:
	# Synthetic isolated full/legacy checkpoint, not normal M07 play evidence.
	# Invoke production owners and durable v4 slots; static Main skips only the
	# unrelated story/AP ingress, never system initialization or this economy.
	GameState.start_new_game()
	_expect(not CORE_LOOP.requested(), "monthly economy fixture requires legacy/full, not --core-loop-v2")
	if CORE_LOOP.requested():
		return
	GameState.turn = 25
	GameState.month = 7
	GameState.week_of_month = 1
	GameState.money = 10_000_000.0
	GameState.market_context["cycle_timer"] = 8
	var dividend_id := ""
	var margin_id := ""
	for raw_asset in DataRegistry.assets:
		var asset: Dictionary = raw_asset
		if dividend_id.is_empty() and str(asset.get("category", "")) in ["korean_stock", "real_estate"]:
			dividend_id = str(asset.get("id", ""))
	for raw_asset in DataRegistry.assets:
		var asset: Dictionary = raw_asset
		if str(asset.get("id", "")) != dividend_id:
			margin_id = str(asset.get("id", ""))
			break
	_expect(not dividend_id.is_empty() and not margin_id.is_empty(),
		"monthly economy fixture lacks real dividend/margin assets")
	if dividend_id.is_empty() or margin_id.is_empty():
		return
	GameState.portfolio = {
		dividend_id: {"quantity": 100.0, "avg_price": GameState.market_prices[dividend_id]},
		# A zero-value leveraged position exercises production margin liquidation
		# without relying on an arbitrary asset's random monthly return.
		margin_id: {"quantity": 0.0, "avg_price": GameState.market_prices[margin_id], "leveraged_amount": 1_000_000.0},
	}
	var main_game: Control = await _spawn_monthly_economy_main()
	var investment: Node = main_game.get("investment_system")
	var before: Dictionary = _monthly_economy_snapshot()
	# Pick a deterministic real crisis through its pure production roll. Do not
	# replace NewsManager, InvestmentSystem, crisis effects or their signals.
	var crisis_seed := -1
	var crisis: Dictionary = {}
	for candidate_seed in range(1, 257):
		seed(candidate_seed)
		crisis = main_game.call("_roll_monthly_crisis")
		if str(crisis.get("type", "")) == "emergency_expense":
			crisis_seed = candidate_seed
			break
	_expect(crisis_seed >= 0, "monthly economy could not select its real expense crisis")
	if crisis_seed < 0:
		await _free_monthly_economy_main(main_game)
		return
	# The news signal fires before prices/dividends. Synchronous reentry must
	# see the reserved turn, not generate another set of news or crisis.
	var reentry_count := [0]
	var reenter := func(_news: Array) -> void:
		reentry_count[0] += 1
		if reentry_count[0] == 1:
			main_game.call("_run_week_start_economy")
	NewsManager.news_generated.connect(reenter)
	seed(crisis_seed)
	main_game.call("_run_week_start_economy")
	NewsManager.news_generated.disconnect(reenter)
	var dividend := GameState.settle_cash(
		100.0 * float(GameState.market_prices[dividend_id]) * 0.002)
	_expect(reentry_count[0] == 1 and GameState.news_log.size() >= 3 \
			and GameState.news_log.size() <= 5 \
			and int(GameState.flags.get("monthly_economy_turn", -1)) == 25 \
			and int(investment.get("cycle_timer")) == 7 \
			and int(GameState.market_context.get("cycle_timer", -1)) == 7,
		"monthly economy first call/reentrant signal did not consume exactly one month")
	_expect(GameState.market_prices != before["market_prices"] \
			and GameState.price_history.size() == DataRegistry.assets.size() \
			and (GameState.price_history.get(dividend_id, []) as Array).size() == 1,
		"monthly economy first call did not update real prices/history once")
	_expect(dividend >= 1.0 and GameState.money \
			== float(before["money"]) - float(crisis.get("amount", 0.0)) + dividend \
			and not GameState.portfolio.has(margin_id) \
			and bool(GameState.flags.get("margin_called_happened", false)) \
			and GameState.mental == int(before["mental"]) - 30,
		"monthly economy did not apply real expense/dividend/margin effects exactly once")
	for raw_news in GameState.news_log:
		_expect(raw_news is Dictionary and int(raw_news.get("year", -1)) == 2026 \
				and int(raw_news.get("month", -1)) == 7,
			"monthly economy first news lacks its actual calendar month")
	_expect_monthly_economy_inert(main_game, "same-turn duplicate")
	var processed: Dictionary = GameState.serialize().duplicate(true)
	var economic_processed: Dictionary = _monthly_economy_snapshot()
	_expect(SaveManager.save_game(TEST_SLOT, {}, {"qa_fixture": true}),
		"monthly economy could not write its processed v4 checkpoint")
	var disk: Variant = JSON.parse_string(FileAccess.get_file_as_string(SaveManager.slot_path(TEST_SLOT)))
	_expect(disk is Dictionary and int(disk.get("version", -1)) == 4 \
			and int(disk.get("state", {}).get("flags", {}).get("monthly_economy_turn", -1)) == 25 \
			and int(disk.get("state", {}).get("market_context", {}).get("cycle_timer", -1)) == 7,
		"monthly economy v4 disk payload lost its consumed turn/countdown")
	await _free_monthly_economy_main(main_game)
	GameState.start_new_game()
	var loaded := SaveManager.load_game(TEST_SLOT)
	_diagnose_monthly_economy_snapshot(economic_processed, "v4-cold-load")
	# Compare the exact durable representation: SaveManager's JSON codec
	# rounds doubles and parses nested integers as floats. No epsilon applies.
	_expect(loaded and SaveManager.loaded_scene_path() == "res://scenes/MainGame.tscn" \
			and _json_round_trip_dictionary(_monthly_economy_snapshot()) \
				== _json_round_trip_dictionary(economic_processed),
		"monthly economy v4 cold load changed market/cash/news/consumed turn")
	if not loaded:
		return
	main_game = await _spawn_monthly_economy_main()
	investment = main_game.get("investment_system")
	_diagnose_monthly_economy_snapshot(economic_processed, "v4-new-main")
	_expect(_json_round_trip_dictionary(_monthly_economy_snapshot()) \
			== _json_round_trip_dictionary(economic_processed) \
			and int(investment.get("cycle_timer")) == 7,
		"new MainGame rerolled the saved market/countdown or changed economic state")
	_expect_monthly_economy_inert(main_game, "cold-loaded same turn")
	# A subsequent real month and a December->January boundary must each run
	# once; old year/month news must not suppress that next economic opening.
	for calendar in [
		{"turn": 29, "year": 2026, "month": 8},
		{"turn": 45, "year": 2026, "month": 12},
		{"turn": 49, "year": 2027, "month": 1},
	]:
		GameState.turn = int(calendar["turn"])
		GameState.year = int(calendar["year"])
		GameState.month = int(calendar["month"])
		var news_count := GameState.news_log.size()
		var history_count := (GameState.price_history[dividend_id] as Array).size()
		main_game.call("_run_week_start_economy")
		_expect(int(GameState.flags.get("monthly_economy_turn", -1)) == GameState.turn \
				and GameState.news_log.size() > news_count \
				and (GameState.price_history[dividend_id] as Array).size() == history_count + 1,
			"next month/year did not consume one new economic opening: %s" % calendar)
		_expect_monthly_economy_inert(main_game, "next month/year duplicate %s" % calendar)
	# Missing old receipt accepts only exact current-calendar news. Corrupt
	# bool/string/fractional values must not become proof by int() coercion.
	for legacy_case in [
		{"name": "current-int", "news": [{"year": 2026, "month": 7}], "skip": true},
		{"name": "current-json-float", "news": [{"year": 2026.0, "month": 7.0}], "skip": true},
		{"name": "previous-month", "news": [{"year": 2026, "month": 6}], "skip": false},
		{"name": "previous-year", "news": [{"year": 2025, "month": 7}], "skip": false},
		{"name": "bad-entry", "news": [true, "2026/7", {}], "skip": false},
		{"name": "string-month", "news": [{"year": 2026, "month": "7"}], "skip": false},
		{"name": "bool-year", "news": [{"year": true, "month": 7}], "skip": false},
		{"name": "fractional-year", "news": [{"year": 2026.5, "month": 7}], "skip": false},
	]:
		GameState.load_from_dict(processed.duplicate(true))
		GameState.flags.erase("monthly_economy_turn")
		GameState.news_log = legacy_case["news"].duplicate(true)
		investment.call("initialize")
		var legacy_before: Dictionary = GameState.serialize().duplicate(true)
		if bool(legacy_case["skip"]):
			legacy_before["flags"]["monthly_economy_turn"] = 25
			seed(535)
			var expected_random := randi()
			seed(535)
			main_game.call("_run_week_start_economy")
			_expect(randi() == expected_random and GameState.serialize() == legacy_before,
				"current legacy news reran economy/RNG: %s" % legacy_case["name"])
		else:
			# Malformed non-Dictionary news is a guard boundary fixture, not a
			# renderable player checkpoint. Keep unrelated UI refresh listeners
			# from reading that synthetic corruption; economy owners still run.
			var signals_were_blocked := GameState.is_blocking_signals()
			if str(legacy_case["name"]) == "bad-entry":
				GameState.set_block_signals(true)
			main_game.call("_run_week_start_economy")
			GameState.set_block_signals(signals_were_blocked)
			_expect(GameState.news_log.size() > legacy_case["news"].size() \
					and int(GameState.flags.get("monthly_economy_turn", -1)) == 25,
				"stale/malformed legacy news suppressed real opening: %s" % legacy_case["name"])
		_expect_monthly_economy_inert(main_game, "legacy reentry %s" % legacy_case["name"])
	for bad_marker in [true, "25", 25.5, 24, null, [], {}]:
		GameState.load_from_dict(processed.duplicate(true))
		GameState.flags["monthly_economy_turn"] = bad_marker
		investment.call("initialize")
		var repaired: Dictionary = GameState.serialize().duplicate(true)
		repaired["flags"]["monthly_economy_turn"] = 25
		seed(535)
		var expected_random := randi()
		seed(535)
		main_game.call("_run_week_start_economy")
		_expect(randi() == expected_random and GameState.serialize() == repaired,
			"current-calendar news did not repair corrupt/stale marker without replay: %s" % [bad_marker])
		GameState.load_from_dict(processed.duplicate(true))
		GameState.news_log = [{"year": 2026, "month": 6}, {"year": "2026", "month": 7}]
		GameState.flags["monthly_economy_turn"] = bad_marker
		investment.call("initialize")
		main_game.call("_run_week_start_economy")
		_expect(GameState.news_log.size() >= 3 \
				and int(GameState.flags.get("monthly_economy_turn", -1)) == 25,
			"malformed/stale marker suppressed economic opening: %s" % [bad_marker])
	GameState.load_from_dict(processed.duplicate(true))
	GameState.flags["monthly_economy_turn"] = 25.0
	GameState.news_log.clear()
	investment.call("initialize")
	_expect_monthly_economy_inert(main_game, "JSON integral-float turn marker")
	for excluded in ["week-two", "v2-requested"]:
		GameState.load_from_dict(processed.duplicate(true))
		GameState.flags.erase("monthly_economy_turn")
		GameState.news_log.clear()
		if excluded == "week-two":
			GameState.week_of_month = 2
		else:
			GameState.core_loop_v2_state = {"enabled": true}
		investment.call("initialize")
		_expect_monthly_economy_inert(main_game, excluded)
	GameState.load_from_dict(processed.duplicate(true))
	await _free_monthly_economy_main(main_game)
	await _check_monthly_cycle_countdown(processed)
	SaveManager.clear_loaded_resume_context()
	GameState.start_new_game()
	_monthly_economy_checked = true
	await get_tree().process_frame


func _check_monthly_cycle_countdown(processed: Dictionary) -> void:
	for timer in range(12):
		for saved_timer in [timer, float(timer)]:
			GameState.load_from_dict(processed.duplicate(true))
			GameState.market_context["cycle_timer"] = saved_timer
			_expect_cycle_initialization_inert(timer, "valid %s" % [saved_timer])
	for saved_timer in [-1, 12, 3.5, true, false, "7", null, [], {}, INF, NAN]:
		GameState.load_from_dict(processed.duplicate(true))
		GameState.market_context["cycle_timer"] = saved_timer
		_expect_cycle_initialization_inert(0, "invalid %s" % [saved_timer])
	GameState.load_from_dict(processed.duplicate(true))
	GameState.market_context.erase("cycle_timer")
	_expect_cycle_initialization_inert(0, "missing legacy countdown")
	# A genuinely untouched new game rolls once; reopening that same initialized
	# market is inert. No lost legacy countdown is fabricated as a fresh 5..11.
	GameState.start_new_game()
	var fresh: Node = INVESTMENT_SYSTEM_SCRIPT.new()
	fresh.call("initialize")
	var first_timer := int(fresh.get("cycle_timer"))
	_expect(first_timer >= 5 and first_timer <= 11 \
			and int(GameState.market_context.get("cycle_timer", -1)) == first_timer,
		"fresh market did not persist its original 5..11 month roll")
	fresh.free()
	_expect_cycle_initialization_inert(first_timer, "already initialized first week")
	GameState.load_from_dict(processed.duplicate(true))
	GameState.market_context["cycle_timer"] = 1
	var expired: Node = INVESTMENT_SYSTEM_SCRIPT.new()
	expired.call("initialize")
	expired.call("process_month", [])
	var rolled_timer := int(expired.get("cycle_timer"))
	_expect(rolled_timer >= 5 and rolled_timer <= 11 \
			and int(GameState.market_context.get("cycle_timer", -1)) == rolled_timer,
		"expired countdown did not persist its next real monthly cycle roll")
	expired.free()
	# Shock countdown is durable, including an already-bear shock which must not
	# silently extend its remaining lifetime or consume another random draw.
	GameState.load_from_dict(processed.duplicate(true))
	GameState.market_context["cycle"] = "bull"
	var shock: Node = INVESTMENT_SYSTEM_SCRIPT.new()
	shock.call("initialize")
	shock.call("apply_market_shock")
	var shock_timer := int(shock.get("cycle_timer"))
	_expect(shock_timer >= 2 and shock_timer <= 4 \
			and str(GameState.market_context.get("cycle", "")) == "bear" \
			and int(GameState.market_context.get("cycle_timer", -1)) == shock_timer,
		"real market shock did not persist its 2..4 month countdown")
	seed(535)
	var expected_random := randi()
	seed(535)
	shock.call("apply_market_shock")
	_expect(randi() == expected_random and int(shock.get("cycle_timer")) == shock_timer \
			and int(GameState.market_context.get("cycle_timer", -1)) == shock_timer,
		"already-bear shock rerolled/extended its remaining countdown")
	var shocked: Dictionary = _monthly_economy_snapshot()
	_expect(SaveManager.save_game(TEST_SLOT, {}, {"qa_fixture": true}),
		"shock countdown could not be saved to a v4 slot")
	shock.free()
	GameState.start_new_game()
	var loaded := SaveManager.load_game(TEST_SLOT)
	_diagnose_monthly_economy_snapshot(shocked, "shock-cold-load")
	_expect(loaded and _json_round_trip_dictionary(_monthly_economy_snapshot()) \
			== _json_round_trip_dictionary(shocked),
		"shock v4 cold load changed countdown/market/cash")
	if loaded:
		var main_game: Control = await _spawn_monthly_economy_main()
		var investment: Node = main_game.get("investment_system")
		_diagnose_monthly_economy_snapshot(shocked, "shock-new-main")
		_expect(_json_round_trip_dictionary(_monthly_economy_snapshot()) \
				== _json_round_trip_dictionary(shocked) \
				and int(investment.get("cycle_timer")) == shock_timer,
			"new MainGame rerolled the saved market shock countdown")
		_expect_monthly_economy_inert(main_game, "cold-loaded market shock")
		await _free_monthly_economy_main(main_game)


func _expect_cycle_initialization_inert(expected_timer: int, label: String) -> void:
	var expected_state: Dictionary = GameState.serialize().duplicate(true)
	expected_state["market_context"]["cycle_timer"] = expected_timer
	var investment: Node = INVESTMENT_SYSTEM_SCRIPT.new()
	seed(535)
	var expected_random := randi()
	seed(535)
	investment.call("initialize")
	_expect(randi() == expected_random and GameState.serialize() == expected_state \
			and int(investment.get("cycle_timer")) == expected_timer,
		"market initialization changed RNG/market/prices/logs: %s" % label)
	investment.free()


func _expect_monthly_economy_inert(main_game: Control, label: String) -> void:
	var before: Dictionary = GameState.serialize().duplicate(true)
	var investment: Node = main_game.get("investment_system")
	var before_timer := int(investment.get("cycle_timer"))
	seed(535)
	var expected_random := randi()
	seed(535)
	main_game.call("_run_week_start_economy")
	_expect(randi() == expected_random and GameState.serialize() == before \
			and int(investment.get("cycle_timer")) == before_timer,
		"monthly economy changed state/countdown/RNG during %s" % label)


func _monthly_economy_snapshot() -> Dictionary:
	var serialized: Dictionary = GameState.serialize()
	var economic: Dictionary = {}
	for key in ["money", "health", "mental", "action_points", \
			"portfolio", "market_prices", "price_history", "market_context", \
			"news_log", "action_log"]:
		economic[key] = serialized[key]
	for key in ["monthly_economy_turn", "margin_called_happened", "demo_director_crisis_turn"]:
		if GameState.flags.has(key):
			economic[key] = GameState.flags[key]
	return economic.duplicate(true)


func _diagnose_monthly_economy_snapshot(expected: Dictionary, label: String) -> void:
	# Failure-only synthetic diagnostics: full-precision values distinguish a
	# real economic delta from JSON number representation/precision changes.
	var actual: Dictionary = _monthly_economy_snapshot()
	if _json_round_trip_dictionary(actual) == _json_round_trip_dictionary(expected):
		return
	for key in expected:
		if not actual.has(key) or expected[key] != actual[key]:
			print("MONTHLY_ECONOMY_SNAPSHOT_DIFF label=%s field=%s before_type=%d after_type=%d before=%s after=%s" % [
				label, key, typeof(expected[key]), typeof(actual.get(key)),
				JSON.stringify(expected[key], "", true, true),
				JSON.stringify(actual.get(key), "", true, true),
			])
	for key in actual:
		if not expected.has(key):
			print("MONTHLY_ECONOMY_SNAPSHOT_DIFF label=%s extra_field=%s value=%s" % [
				label, key, JSON.stringify(actual[key], "", true, true),
			])


func _spawn_monthly_economy_main() -> Control:
	var main_game: Control = MAIN_GAME_SCENE.instantiate()
	main_game.set_meta("_screenshot_qa_static_surface", true)
	add_child(main_game)
	await get_tree().process_frame
	await get_tree().process_frame
	return main_game


func _free_monthly_economy_main(main_game: Control) -> void:
	if main_game.get_parent() != null:
		main_game.get_parent().remove_child(main_game)
	main_game.free()
	BGMPlayer.stop()
	await get_tree().process_frame


func _check_full_story_meeting_date() -> void:
	# Prepared W1 consumer handoff, not natural W14 reach/native observation.
	# Disk reloads below create a new StoryMode in this same isolated process.
	await _free_story()
	var previous_language: String = LocaleManager.language
	var state_before: Dictionary = GameState.serialize().duplicate(true)
	var events_before: Dictionary = _full_story_event_snapshot()
	var resume_before: Dictionary = {}
	for key in ["_loaded_resume_context", "_loaded_slot_metadata", "_loaded_save_identity", "_last_load_diagnostic"]:
		resume_before[key] = (SaveManager.get(key) as Dictionary).duplicate(true)
	var failures_before: int = _failures.size()
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var excluded: bool = GameState.is_demo_build() or CORE_LOOP.requested() \
		or args.has(FULL_STORY_FLOW.PREVIEW_ARG) or args.has(FULL_STORY_FLOW.THIRD_MONTH_ARG)
	for locale in ["ko", "en", "ja", "zh-CN", "zh-TW"]:
		await _free_story()
		LocaleManager.set_language(locale)
		if excluded:
			GameState.start_new_game("DateFixture")
			var unmarked: Dictionary = GameState.serialize().duplicate(true)
			_expect(not FULL_STORY_FLOW.initialize_fresh_run() and GameState.serialize() == unmarked,
				"date exclusion issued a full owner in %s" % locale)
			if GameState.is_demo_build() or CORE_LOOP.requested():
				# Synthetic full-shaped marker proves the environment gate, not entry.
				GameState.flags[FULL_STORY_FLOW.STATE_KEY] = {
					"schema": 1, "profile": FULL_STORY_FLOW.PROFILE_FULL, "start_turn": 1,
					"last_completed_turn": 0, "chain": {}, "read_receipts": {},
					"routine_receipts": {}, "completed_turns": {}, "activity_receipts": {},
				}
				_expect(FULL_STORY_FLOW.is_full_run() and not FULL_STORY_FLOW.valid_session(),
					"date demo/V2 synthetic owner bypassed its environment")
			else:
				_expect(FULL_STORY_FLOW.initialize_fresh_preview() \
						and FULL_STORY_FLOW.valid_session() and not FULL_STORY_FLOW.is_full_run(),
					"date explicit preview was not the existing excluded profile")
			for key in ["pending_events", "current_event", "event_cooldowns", "recent_event_ids", "narrative_bridge_results"]:
				var value: Variant = EventManager.get(key)
				if value is Dictionary or value is Array:
					value.clear()
		else:
			await _production_fresh_start()
			GameState.player_name = "DateFixture"
			_expect(FULL_STORY_FLOW.is_full_run() and FULL_STORY_FLOW.valid_session() and GameState.turn == 1,
				"date fixture did not use the actual fresh full initializer")
			if not FULL_STORY_FLOW.valid_session():
				break
		var registry_before: Array = DataRegistry.events.duplicate(true)
		var by_id_before: Dictionary = DataRegistry.events_by_id.duplicate(true)
		var event: Dictionary = (DataRegistry.events_by_id.get("arc_sangchul_01_meet", {}) as Dictionary).duplicate(true)
		_expect(not event.is_empty(), "date fixture lacks localized meet %s" % locale)
		if event.is_empty():
			break
		var probe: Control = STORY_MODE_SCRIPT.new()
		for variant in ["description", "description_orthodox", "description_unorthodox"]:
			GameState.route_orthodox = 16 if variant == "description_orthodox" else 0
			GameState.route_unorthodox = 16 if variant == "description_unorthodox" else 0
			var raw: String = str(event.get(variant, ""))
			var projected: String = _full_story_date_expected(raw, locale)
			var expected: String = str(probe.call("_fmt", raw if excluded else projected))
			if excluded:
				var before: Dictionary = GameState.serialize().duplicate(true)
				_expect(str(probe.call("_resolved_story_description", event)) == expected \
						and GameState.serialize() == before,
					"date exclusion changed %s/%s" % [locale, variant])
			else:
				await _free_story()
				_expect(FULL_STORY_FLOW.begin_chain(["arc_sangchul_01_meet"]), "date prepared meet handoff failed")
				GameState.pending_story_queue = ["arc_sangchul_01_meet"]
				GameState.story_return_scene = "res://scenes/MainGame.tscn"
				if not await _spawn_full_story_fixture():
					break
				var before: Dictionary = GameState.serialize().duplicate(true)
				var pages: Dictionary = _story.call("_story_page_data", expected)
				_expect(str(_story.call("_resolved_story_description", _story.get("_current"))) == expected \
						and (_story.get("_paragraphs") as Array) == pages.get("pages", []) \
						and str(_story.get("_type_full")) == str((pages.get("pages", []) as Array)[0]) \
						and GameState.serialize() == before and FULL_STORY_FLOW.valid_session(),
					"date resolver/pages changed more than exact prefix %s/%s" % [locale, variant])
		if not excluded:
			await _free_story()
			GameState.route_orthodox = 0
			GameState.route_unorthodox = 0
			_check_full_story_date_exclusions(probe, str(event["description"]))
			GameState.pending_story_queue = ["arc_sangchul_01_meet"]
			GameState.story_return_scene = "res://scenes/MainGame.tscn"
			if await _spawn_full_story_fixture():
				await _check_full_story_date_prose(event, locale)
		probe.free()
		_expect(DataRegistry.events == registry_before and DataRegistry.events_by_id == by_id_before,
			"date projection rewrote localized registry %s" % locale)
	await _free_story()
	LocaleManager.set_language(previous_language)
	GameState.call("_restore_serialized_snapshot_exact", state_before)
	for key in events_before:
		EventManager.set(key, events_before[key].duplicate(true))
	for key in resume_before:
		SaveManager.set(key, resume_before[key].duplicate(true))
	_expect(GameState.serialize() == state_before and _full_story_event_snapshot() == events_before \
			and LocaleManager.language == previous_language,
		"date fixture failed to restore the previous whole-check state/context")
	if _failures.size() == failures_before:
		if excluded:
			_full_story_date_exclusion = "demo" if GameState.is_demo_build() else ("v2" if CORE_LOOP.requested() else "preview")
		else:
			_full_story_date_checked = true


func _full_story_date_expected(raw: String, locale: String) -> String:
	var prefixes: Dictionary = {"ko": "3월 끝, ", "en": "Late March, just", \
		"ja": "3月の終わり、", "zh-CN": "三月底，", "zh-TW": "3月底，"}
	var prefix: String = str(prefixes[locale])
	_expect(raw.begins_with(prefix), "date fixture source prefix differs in %s" % locale)
	return ("Just" if locale == "en" else "") + raw.substr(prefix.length())


func _check_full_story_date_exclusions(probe: Control, raw: String) -> void:
	# Pure probes: neither a public launch nor a real gallery replay (not a root).
	var before: Dictionary = GameState.serialize().duplicate(true)
	var custom_before: Variant = ProjectSettings.get_setting("application/config/use_custom_user_dir", false)
	var name_before: Variant = ProjectSettings.get_setting("application/config/custom_user_dir_name", "")
	for boundary in ["unmarked", "corrupt", "preview8", "preview12", "read-only", "public-return", "public-namespace"]:
		GameState.call("_restore_serialized_snapshot_exact", before)
		probe.set("_read_only_replay", false)
		match boundary:
			"unmarked":
				GameState.flags.erase(FULL_STORY_FLOW.STATE_KEY)
			"corrupt":
				GameState.flags[FULL_STORY_FLOW.STATE_KEY]["schema"] = "1"
			"preview8", "preview12":
				GameState.flags[FULL_STORY_FLOW.STATE_KEY]["profile"] = \
					FULL_STORY_FLOW.PROFILE if boundary == "preview8" else FULL_STORY_FLOW.PROFILE_THIRD_MONTH
				_expect(FULL_STORY_FLOW.valid_session() and not FULL_STORY_FLOW.is_full_run(),
					"date synthetic preview shape is not a valid excluded old owner")
			"read-only":
				probe.set("_read_only_replay", true)
			"public-return":
				GameState.story_return_scene = "res://playtests/order124/StoryChoiceM1M6Playtest.tscn"
			"public-namespace":
				ProjectSettings.set_setting("application/config/use_custom_user_dir", true)
				ProjectSettings.set_setting("application/config/custom_user_dir_name", STORY_DEMO_CONTROLLER.PUBLIC_CUSTOM_USER_DIR)
		var negative: Dictionary = GameState.serialize().duplicate(true)
		_expect(str(probe.call("_full_story_meeting_description", "arc_sangchul_01_meet", raw)) == raw \
				and GameState.serialize() == negative,
			"date projection changed excluded boundary %s/%s" % [LocaleManager.language, boundary])
		ProjectSettings.set_setting("application/config/use_custom_user_dir", custom_before)
		ProjectSettings.set_setting("application/config/custom_user_dir_name", name_before)
	GameState.call("_restore_serialized_snapshot_exact", before)
	probe.set("_read_only_replay", false)
	_expect(str(probe.call("_full_story_meeting_description", "arc_sangchul_01_measure", raw)) == raw \
			and str(probe.call("_full_story_meeting_description", "arc_sangchul_01_meet", " " + raw)) == " " + raw \
			and GameState.serialize() == before,
		"date projection changed another event/non-leading prefix")


func _check_full_story_date_prose(event: Dictionary, locale: String) -> void:
	var expected: String = str(_story.call("_fmt", _full_story_date_expected(str(event["description"]), locale)))
	var original_first: String = str(_story.call("_dialogue_log_plain_text", \
		_story.call("_fmt", str(event["description"]).split("\n\n")[0])))
	var source_pages: int = 0
	while int(_story.call("_story_source_paragraph_index", int(_story.get("_para_index")))) == 0 \
			and source_pages < 16:
		_story.call("_complete_typing")
		_story.call("_on_advance")
		source_pages += 1
	_expect(int(_story.call("_story_source_paragraph_index", int(_story.get("_para_index")))) == 1,
		"date prose did not consume exactly its first authored paragraph %s" % locale)
	var partial: int = mini(7, maxi(1, str(_story.get("_type_full")).length() - 1))
	_story.set("_type_pos", partial)
	_story.set("_typing", true)
	(_story.get("_body_lbl") as RichTextLabel).text = str(_story.get("_type_full")).substr(0, partial)
	var context: Dictionary = _story.call("build_save_resume_context")
	var entries: Array = ((context.get("dialogue_log", {}) as Dictionary).get("entries", []) as Array).duplicate(true)
	var expected_first: String = str(_story.call("_dialogue_log_plain_text", expected.split("\n\n")[0]))
	_expect(str(context.get("phase", "")) == "prose" and int(context.get("source_paragraph_index", -1)) == 1 \
			and bool(context.get("paragraph_was_typing", false)) and str(context.get("story_locale", "")) == locale \
			and entries.size() == 1 and str((entries[0] as Dictionary).get("text", "")) == expected_first \
			and expected_first != original_first,
		"date new history/source save did not contain only the undated first block %s" % locale)
	if entries.size() != 1 or context.is_empty():
		return
	var saved_state: Dictionary = GameState.serialize().duplicate(true)
	for historical in [false, true]:
		var saved_context: Dictionary = context.duplicate(true)
		var saved_entries: Array = entries.duplicate(true)
		if historical:
			# Explicit synthetic past text, not a migration of an actual user save.
			(saved_entries[0] as Dictionary)["text"] = original_first
			(saved_context["dialogue_log"] as Dictionary)["entries"] = saved_entries
		_expect(SaveManager.save_game(TEST_SLOT, saved_context), "date prose disk save failed %s" % locale)
		var disk: Variant = JSON.parse_string(FileAccess.get_file_as_string(SaveManager.slot_path(TEST_SLOT)))
		var disk_entries: Array = ((disk.get("resume", {}) as Dictionary).get("dialogue_log", {}) as Dictionary).get("entries", []) if disk is Dictionary else []
		# JSON numbers are parsed as floats; compare the unchanged serialized
		# representation, not its pre-serialization Dictionary number types.
		var expected_disk: Dictionary = _json_round_trip_dictionary({"entries": saved_entries})
		if not historical and disk_entries != saved_entries and {"entries": disk_entries} == expected_disk:
			var numeric_types: Array[String] = []
			for key in ["seq", "event_serial", "choice_index", "source_paragraph_index", "page_index"]:
				var memory_value: Variant = (saved_entries[0] as Dictionary).get(key)
				var disk_value: Variant = (disk_entries[0] as Dictionary).get(key)
				numeric_types.append("%s:%d/%s->%d/%s" % [key, typeof(memory_value), str(memory_value), typeof(disk_value), str(disk_value)])
			print("MANUAL_SAVE_FULL_STORY_DATE_JSON_HISTORY locale=%s exact_serialized=1 numeric_leaves=%s" % [locale, ",".join(numeric_types)])
		_expect(disk is Dictionary and int(disk.get("version", -1)) == 4 \
				and {"entries": disk_entries} == expected_disk,
			"date v4 disk omitted exact history %s old=%s" % [locale, historical])
		await _free_story()
		GameState.start_new_game("DateFixture")
		_expect(SaveManager.load_game(TEST_SLOT), "date v4 disk reload failed %s" % locale)
		if not await _spawn_full_story_fixture(true):
			return
		var resumed: Dictionary = _story.call("build_save_resume_context")
		_expect(FULL_STORY_FLOW.valid_session() and FULL_STORY_FLOW.is_full_run() \
				and _json_round_trip_dictionary(GameState.serialize()) == _json_round_trip_dictionary(saved_state) \
				and int(resumed.get("source_paragraph_index", -1)) == 1 and bool(_story.get("_typing")) \
				and (_story.get("_dialogue_log_entries") as Array) == saved_entries \
				and str(_story.call("_resolved_story_description", _story.get("_current"))) == expected \
				and (_story.get("_paragraphs") as Array) == (_story.call("_story_page_data", expected) as Dictionary).get("pages", []),
			"date new Story disk resume changed prose/history/owner/economy %s old=%s" % [locale, historical])
	if locale == "ko":
		var before: Dictionary = GameState.serialize().duplicate(true)
		var old_history: Array = (_story.get("_dialogue_log_entries") as Array).duplicate(true)
		for language in ["en", "ko"]:
			_story.call("_set_story_language", language)
			await get_tree().process_frame
			await get_tree().process_frame
			var localized: Dictionary = _story.get("_current")
			var localized_expected: String = str(_story.call("_fmt", \
				_full_story_date_expected(str(localized["description"]), language)))
			_expect(LocaleManager.language == language and GameState.serialize() == before \
					and (_story.get("_dialogue_log_entries") as Array) == old_history \
					and str(_story.call("_resolved_story_description", localized)) == localized_expected \
					and (_story.get("_paragraphs") as Array) == (_story.call("_story_page_data", localized_expected) as Dictionary).get("pages", []),
				"date actual KO/EN language consumer changed body/history/economy %s" % language)


func _check_full_story_production() -> void:
	# Actual product methods with deterministic choices, not native input,
	# natural M07 observation, or a 240-week playthrough. Old preview fixtures
	# below deliberately remain separate and unchanged.
	await _free_story()
	var previous_language: String = LocaleManager.language
	var events_before: Dictionary = _full_story_event_snapshot()
	var failures_before: int = _failures.size()
	LocaleManager.set_language("ko")
	GameState.start_new_game()
	var unmarked: Dictionary = GameState.serialize().duplicate(true)
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if GameState.is_demo_build() or CORE_LOOP.requested() \
			or args.has(FULL_STORY_FLOW.PREVIEW_ARG) or args.has(FULL_STORY_FLOW.THIRD_MONTH_ARG):
		_expect(not FULL_STORY_FLOW.initialize_fresh_run() \
				and GameState.serialize() == unmarked and not FULL_STORY_FLOW.is_full_run(),
			"normal full initializer promoted a demo/V2/explicit preview process")
		print("MANUAL_SAVE_FULL_STORY_PRODUCTION_EXCLUSION_CHECK_OK profile=%s activated=0" % [
			"demo" if GameState.is_demo_build() else ("v2" if CORE_LOOP.requested() else "preview")])
		LocaleManager.set_language(previous_language)
		return
	var checkpoint: Dictionary = {}
	var study_checkpoint: Dictionary = {}
	for study_choice in [0, 1]:
		await _production_fresh_start()
		_expect(FULL_STORY_FLOW.is_full_run() and FULL_STORY_FLOW.valid_session() \
				and FULL_STORY_FLOW.last_turn() == 240 and not FULL_STORY_FLOW.at_boundary() \
				and not FULL_STORY_FLOW.ready_to_advance(),
			"actual StartMenu fresh initializer did not issue the normal unread full owner")
		if not FULL_STORY_FLOW.valid_session():
			break
		var fresh: Dictionary = GameState.serialize().duplicate(true)
		_expect(FULL_STORY_FLOW.initialize_fresh_run() and GameState.serialize() == fresh,
			"duplicate fresh full initialization changed the run")
		var main_game: Control = await _spawn_monthly_economy_main()
		var reads: Array[String] = []
		for expected_turn in range(1, 29):
			_expect(GameState.turn == expected_turn and FULL_STORY_FLOW.valid_session(),
				"normal full skipped/repeated W%d" % expected_turn)
			if expected_turn == 11 and study_choice == 0:
				study_checkpoint = GameState.serialize().duplicate(true)
			main_game.call("_begin_month")
			var handoffs: int = 0
			while not GameState.pending_story_queue.is_empty() and handoffs < 12:
				if not await _spawn_full_story_fixture():
					break
				await _read_production_story(main_game, {
					"hyunsu_study_together": study_choice,
				}, reads)
				await _free_story()
				GameState.returning_from_story = false
				main_game.call("_continue_after_story")
				handoffs += 1
			_expect(handoffs < 12 and FULL_STORY_FLOW.ready_to_advance() \
					and _full_story_surface_is_sealed(main_game),
				"normal W%d did not close the actual roots or exposed AP fallback" % expected_turn)
			if not FULL_STORY_FLOW.ready_to_advance():
				break
			var before: Dictionary = GameState.serialize().duplicate(true)
			var payable: float = GameState.get_monthly_payable_income()
			var required: float = GameState.get_monthly_required_cash()
			var expected_cash: float = GameState.money \
				+ (70_000.0 if GameState.current_job.is_empty() else 0.0)
			if expected_turn % 4 == 0:
				expected_cash += payable - required
				if expected_turn == 4:
					expected_cash += 300_000.0
			if expected_turn in [24, 28] and study_choice == 0:
				await _check_full_story_calendar_save_retry(main_game, expected_turn)
			else:
				_expect(bool(main_game.call("_full_story_advance_week", expected_turn)),
					"normal full could not advance actual W%d" % expected_turn)
			_expect(GameState.turn == expected_turn + 1 and GameState.money == expected_cash \
					and GameState.action_points == int(before["action_points"]),
				"normal W%d lost/doubled livelihood/pay/bills/subsidy or spent AP" % expected_turn)
			var after: Dictionary = GameState.serialize().duplicate(true)
			seed(541_000 + expected_turn)
			var next_random: int = randi()
			seed(541_000 + expected_turn)
			_expect(not bool(main_game.call("_full_story_advance_week", expected_turn)) \
					and GameState.serialize() == after and randi() == next_random,
				"normal duplicate calendar advance changed state/RNG")
			if expected_turn in [20, 24, 28]:
				await _production_cold_checkpoint(main_game, "W%d" % (expected_turn + 1))
		_expect(GameState.turn == 29 and GameState.month == 8 and GameState.year == 2026 \
				and GameState.age == 33 and FULL_STORY_FLOW.valid_session() \
				and not FULL_STORY_FLOW.at_boundary(),
			"normal owner stopped at the old preview cap or missed M06/M07 durable resume")
		_expect(reads.has("story_flashforward") and reads.has("chapter_card_33") \
				and reads.has("arc_temptation_01") and reads.has("arc_temptation_clean") \
				and reads.has("arc_rescue_job") and reads.has("arc_first_job_week_convenience") \
				and reads.has("arc_paycheck_reality") \
				and str(GameState.current_job.get("id", "")) == "job_01" \
				and bool(GameState.flags.get("has_received_paycheck", false)),
			"normal actual selectors lost opening/hiring/first work/first paycheck")
		var encouraged: bool = bool(GameState.flags.get("hyunsu_encouraged", false))
		var study_read: bool = reads.has("hyunsu_study_together")
		var study_witness: bool = false
		for entry in GameState.event_log:
			if entry is Dictionary and entry.get("event_id") == "hyunsu_study_together" \
					and int(entry.get("choice_index", -1)) == study_choice:
				study_witness = true
		_expect((study_read and study_witness and encouraged == (study_choice == 0) \
				and bool(GameState.flags.get("hyunsu_talked_candidly", false)) == (study_choice == 1)) \
				or (not study_read and not study_witness and not encouraged \
					and not bool(GameState.flags.get("hyunsu_talked_candidly", false))),
			"normal Hyunsu study flags do not match the actual consumed choice witness")
		_expect(bool(GameState.flags.get("hyunsu_exam_day_seen", false)) \
				and bool(GameState.flags.get("hyunsu_passed", false)) == encouraged \
				and bool(GameState.flags.get("hyunsu_failed", false)) == not encouraged \
				and reads.has("hyunsu_result_pass" if encouraged else "hyunsu_result_fail"),
			"normal Hyunsu result no longer follows the actual study-choice flags")
		print("FULL_STORY_HYUNSU_NORMAL_PROOF requested_study_choice=%d study_read=%s exact_choice_witness=%s encouraged=%s exam=%s passed=%s failed=%s result=%s natural=0" % [
			study_choice, study_read, study_witness, encouraged,
			GameState.flags.get("hyunsu_exam_day_seen", false), GameState.flags.get("hyunsu_passed", false),
			GameState.flags.get("hyunsu_failed", false),
			"pass" if reads.has("hyunsu_result_pass") else ("fail" if reads.has("hyunsu_result_fail") else "unread")])
		if study_choice == 0 and GameState.turn == 29:
			checkpoint = GameState.serialize().duplicate(true)
		await _free_monthly_economy_main(main_game)
	if not checkpoint.is_empty():
		await _check_production_hyunsu_result(checkpoint, study_checkpoint)
		await _check_production_activity(checkpoint)
		_check_production_event_log_tail(checkpoint)
		_check_production_calendar_values()
		await _check_production_causal_handoff(checkpoint)
		await _check_production_year_and_terminal(checkpoint)
	GameState.start_new_game()
	for key in events_before:
		EventManager.set(key, events_before[key].duplicate(true))
	SaveManager.clear_loaded_resume_context()
	LocaleManager.set_language(previous_language)
	_full_story_production_checked = _failures.size() == failures_before


func _production_fresh_start() -> void:
	SaveManager.clear_loaded_resume_context()
	var menu: Control = load("res://scenes/StartMenu.tscn").instantiate() as Control
	add_child(menu)
	await get_tree().process_frame
	await get_tree().process_frame
	menu.call("_initialize_new_run_state", false)
	remove_child(menu)
	menu.free()
	for property in ["pending_events", "current_event", "event_cooldowns", "recent_event_ids",
			"narrative_bridge_results"]:
		var value: Variant = EventManager.get(property)
		if value is Dictionary or value is Array:
			value.clear()
	await get_tree().process_frame


func _check_production_hyunsu_result(checkpoint: Dictionary, study_checkpoint: Dictionary) -> void:
	# The normal W11-W18 selector can spend its weeks on higher-priority roots.
	# Exercise both study choices at a real W11 prefix, then prepare only the
	# later result inputs. This is not a claim that either study was selected
	# naturally, or that changing a reply ought to change the authored outcome.
	_expect(not study_checkpoint.is_empty() and int(study_checkpoint.get("turn", 0)) == 11 \
			and bool((study_checkpoint.get("flags", {}) as Dictionary).get("arc_intro_hyunsu_seen", false)),
		"prepared Hyunsu study has no actual eligible W11 prefix")
	if study_checkpoint.is_empty():
		return
	for choice_index in [0, 1]:
		GameState.call("_restore_serialized_snapshot_exact", study_checkpoint)
		SaveManager.clear_loaded_resume_context()
		var main_game: Control = await _spawn_monthly_economy_main()
		main_game.call("_go_story_mode", ["hyunsu_study_together"])
		if not await _spawn_full_story_fixture():
			await _free_monthly_economy_main(main_game)
			return
		var study_reads: Array[String] = []
		await _read_production_story(main_game, {"hyunsu_study_together": choice_index}, study_reads)
		await _free_story()
		var study_flags: Dictionary = GameState.flags.duplicate(true)
		_expect(study_reads == ["hyunsu_study_together"] and GameState.turn == 11 \
				and FULL_STORY_FLOW.ready_to_advance() \
				and bool(study_flags.get("hyunsu_encouraged", false)) == (choice_index == 0) \
				and bool(study_flags.get("hyunsu_talked_candidly", false)) == (choice_index == 1),
			"prepared actual Hyunsu study lost its original choice flags/result-close")
		await _free_monthly_economy_main(main_game)
		# The actual W29 prefix already supplies the exam producer. Replace its
		# hypothetical study/result inputs explicitly; erase only the old fail
		# callback, whose cause is being replaced in this prepared matrix.
		GameState.call("_restore_serialized_snapshot_exact", checkpoint)
		SaveManager.clear_loaded_resume_context()
		for flag in ["hyunsu_encouraged", "hyunsu_talked_candidly", "hyunsu_study_together_seen",
				"hyunsu_passed", "hyunsu_failed", "hyunsu_comforted", "hyunsu_relationship_close"]:
			GameState.flags.erase(flag)
		for flag in ["hyunsu_encouraged", "hyunsu_talked_candidly", "hyunsu_study_together_seen"]:
			if study_flags.has(flag):
				GameState.flags[flag] = study_flags[flag]
		for index in range(GameState.deferred_events.size() - 1, -1, -1):
			if (GameState.deferred_events[index] as Dictionary).get("event_id") == "arc_hyunsu_exam_fail":
				GameState.deferred_events.remove_at(index)
		_expect(bool(GameState.flags.get("hyunsu_exam_day_seen", false)) and FULL_STORY_FLOW.valid_session(),
			"prepared Hyunsu result lost the actual exam/full-owner evidence")
		main_game = await _spawn_monthly_economy_main()
		var expected_id: String = "hyunsu_result_pass" if choice_index == 0 else "hyunsu_result_fail"
		var before_query: Dictionary = GameState.serialize().duplicate(true)
		_expect(str(main_game.call("_next_arc_id", 29, false, false)) == expected_id \
				and GameState.serialize() == before_query,
			"prepared actual study flags did not select the original Hyunsu result")
		main_game.call("_go_story_mode", [expected_id])
		if await _spawn_full_story_fixture():
			var result_reads: Array[String] = []
			await _read_production_story(main_game, {}, result_reads)
			await _free_story()
			_expect(result_reads == [expected_id] and GameState.turn == 29 \
					and FULL_STORY_FLOW.ready_to_advance() \
					and bool(GameState.flags.get("hyunsu_passed", false)) == (choice_index == 0) \
					and bool(GameState.flags.get("hyunsu_failed", false)) == (choice_index == 1),
				"prepared Hyunsu selector/result/cold consumer changed original pass/fail effects")
		await _free_monthly_economy_main(main_game)
	GameState.call("_restore_serialized_snapshot_exact", checkpoint)
	SaveManager.clear_loaded_resume_context()
	print("MANUAL_SAVE_FULL_STORY_HYUNSU_CHECK_OK normal=actual-flags study=prepared-W11-actual-choices0/1 result=prepared-W29-actual-selector/pass/fail/cold original-flags=preserved natural=0")


func _read_production_story(main_game: Control, choices_by_id: Dictionary, reads: Array[String]) -> void:
	var fragments: int = 0
	while is_instance_valid(_story) and not bool(_story.get("_transitioning")) and fragments < 48:
		var event: Dictionary = _story.get("_current")
		var event_id: String = str(event.get("id", ""))
		reads.append(event_id)
		if bool(_story.get("_is_chapter_card")):
			_story.call("_chapter_card_advance")
			fragments += 1
			continue
		var choices: Array = event.get("choices", [])
		_show_current_story_choices()
		var visible: Array = _story.call("_visible_choice_indices", event)
		var choice_index: int = int(choices_by_id.get(event_id,
			visible[0] if not visible.is_empty() else -1))
		_expect(choice_index >= 0 and choice_index < choices.size() and visible.has(choice_index),
			"normal story lacks actual %s choice %d" % [event_id, choice_index])
		if choice_index < 0 or choice_index >= choices.size() or not visible.has(choice_index):
			return
		if not choices_by_id.has(event_id) and choice_index != 0:
			var rejected_before: Dictionary = GameState.serialize().duplicate(true)
			_story.call("_on_choice", 0)
			_expect(GameState.serialize() == rejected_before and not bool(_story.get("_pending_after_result")),
				"hidden default choice mutated its rejected opportunity/route")
			print("FULL_STORY_VISIBLE_CHOICE event=%s catalog0_visible=0 selected=%d visible=%s cash=%s rejected_state_exact=%s" % [
				event_id, choice_index, visible, GameState.money, GameState.serialize() == rejected_before])
		var has_result: bool = not str((choices[choice_index] as Dictionary).get("result_text", "")).is_empty()
		var choice_turn: int = GameState.turn
		_story.call("_on_choice", choice_index)
		var applied: Dictionary = GameState.serialize().duplicate(true)
		var causal_handoff: bool = event_id == "arc_y5_jaehyuk_return_call_reference"
		if causal_handoff:
			var target_id: String = "arc_y5_jaehyuk_father_document_reference"
			var chain: Dictionary = FULL_STORY_FLOW.snapshot()["chain"]
			_expect(chain["roots"] == [event_id, target_id] \
					and chain["pending_event_ids"] == [event_id, target_id] \
					and FULL_STORY_FLOW.append_causal_ingress(event_id, choice_index, target_id) \
					and not FULL_STORY_FLOW.append_causal_ingress(event_id, (choice_index + 1) % 3, target_id) \
					and not FULL_STORY_FLOW.append_causal_ingress(event_id, choice_index, event_id) \
					and GameState.serialize() == applied,
				"actual W210 causal handoff did not bind exact source/choice/next or duplicated it")
		if not bool(_story.get("_pending_after_result")):
			var read_found: bool = false
			var owner: Dictionary = FULL_STORY_FLOW.snapshot()
			for raw in (owner.get("read_receipts", {}) as Dictionary).get(str(choice_turn), []):
				if raw is Dictionary and raw.get("event_id") == event_id \
						and int(raw.get("choice_index", -1)) == choice_index:
					read_found = true
			_expect(not has_result and read_found and GameState.turn == choice_turn,
				"normal %s choice neither opened its authored result nor auto-closed an empty result" % event_id)
			if has_result or not read_found:
				return
			# The production no-result path already closed this receipt and loaded
			# its next consumer. Never close/apply that next event on its behalf.
			fragments += 1
			continue
		_story.call("_after_result")
		_expect(bool(_story.get("_pending_after_result")) \
				and not FULL_STORY_FLOW.ready_to_advance() \
				and not bool(main_game.call("_full_story_advance_week", GameState.turn)) \
				and GameState.serialize() == applied,
			"normal unread %s result advanced time/economy" % event_id)
		_story.call("_on_choice", choice_index)
		_expect(GameState.serialize() == applied,
			"normal duplicate %s choice reapplied effects" % event_id)
		if event_id in ["arc_paycheck_reality", "hyunsu_result_pass", "hyunsu_result_fail",
				"arc_year1_scene", "arc_y5_jaehyuk_return_call_reference",
				"arc_y5_jaehyuk_father_document_reference"]:
			var context: Dictionary = _story.call("build_save_resume_context")
			_expect(str(context.get("phase", "")) == "result" \
					and SaveManager.save_game(TEST_SLOT, context, {"qa_fixture": true}),
				"normal %s result could not reach v4 disk" % event_id)
			await _free_story()
			GameState.start_new_game()
			_expect(SaveManager.load_game(TEST_SLOT), "normal result cold load failed")
			if not await _spawn_full_story_fixture(true):
				return
			_expect(_json_round_trip_dictionary(GameState.serialize()) \
					== _json_round_trip_dictionary(applied) \
					and int(_story.get("_pending_result_choice_index")) == choice_index \
					and bool(_story.get("_pending_after_result")) and FULL_STORY_FLOW.valid_session(),
				"normal %s cold result changed applied effects/owner/index" % event_id)
		_story.call("_finish_story_scene_transition")
		_story.call("_complete_typing")
		_story.set("_para_index", (_story.get("_paragraphs") as Array).size())
		_story.call("_after_result")
		if causal_handoff:
			var after_handoff: Dictionary = GameState.serialize().duplicate(true)
			_expect(not FULL_STORY_FLOW.append_causal_ingress(event_id, choice_index,
					"arc_y5_jaehyuk_father_document_reference") \
					and GameState.serialize() == after_handoff,
				"consumed W210 source reopened its same-turn ingress")
		fragments += 1
	_expect(fragments < 48 and bool(_story.get("_transitioning")),
		"normal story failed to finish its actual direct follow-up chain")
	var closed: Dictionary = GameState.serialize().duplicate(true)
	_expect(FULL_STORY_FLOW.close_chain() and GameState.serialize() == closed,
		"normal duplicate chain close mutated its run")


func _production_cold_checkpoint(main_game: Control, label: String) -> void:
	var before: Dictionary = GameState.serialize().duplicate(true)
	_expect(SaveManager.save_game(TEST_SLOT, {}, {"qa_fixture": true}),
		"normal %s checkpoint disk write failed" % label)
	GameState.start_new_game()
	_expect(SaveManager.load_game(TEST_SLOT) \
			and _json_round_trip_dictionary(GameState.serialize()) == _json_round_trip_dictionary(before),
		"normal %s cold load lost actual state" % label)
	var loaded: Dictionary = GameState.serialize().duplicate(true)
	var expected: Dictionary = _full_story_expected_main_reentry(loaded, main_game)
	var resumed: Control = await _spawn_monthly_economy_main()
	_report_full_story_state_diff(expected, "production-" + label)
	_expect(FULL_STORY_FLOW.is_full_run() and FULL_STORY_FLOW.valid_session() \
			and GameState.serialize() == expected,
		"normal %s new Main changed settled state or inferred another profile" % label)
	await _free_monthly_economy_main(resumed)
	SaveManager.clear_loaded_resume_context()


func _check_production_activity(checkpoint: Dictionary) -> void:
	# W29's genuine W1-W28 prefix is preserved. The extra activity root is an
	# explicitly prepared method fixture, not proof of natural mentor eligibility.
	for mode in ["cancel", "tip-cancel", "round"]:
		GameState.call("_restore_serialized_snapshot_exact", checkpoint)
		SaveManager.clear_loaded_resume_context()
		var main_game: Control = await _spawn_monthly_economy_main()
		if mode == "cancel":
			var pristine: Dictionary = GameState.serialize().duplicate(true)
			for damaged in ["true", 1, {}, []]:
				GameState.flags["open_racetrack_after_story"] = damaged
				var invalid: Dictionary = GameState.serialize().duplicate(true)
				main_game.call("_begin_month")
				_expect(not FULL_STORY_FLOW.valid_session() \
						and not bool(main_game.call("_full_story_advance_week", GameState.turn)) \
						and GameState.serialize() == invalid \
						and GameState.flags["open_racetrack_after_story"] == damaged,
					"damaged truthy activity flag was consumed or advanced the full owner")
				GameState.call("_restore_serialized_snapshot_exact", pristine)
		main_game.call("_go_story_mode", ["race_first_visit"])
		if not await _spawn_full_story_fixture():
			await _free_monthly_economy_main(main_game)
			return
		var reads: Array[String] = []
		await _read_production_story(main_game, {"race_first_visit": 1}, reads)
		await _free_story()
		GameState.returning_from_story = false
		_expect(reads == ["race_first_visit"] \
				and FULL_STORY_FLOW.pending_activity_id() == "racetrack" \
				and not FULL_STORY_FLOW.ready_to_advance(),
			"actual race_first_visit choice 1 did not own its same-week pending activity")
		var at_turn: int = GameState.turn
		var stored_ap: int = GameState.action_points
		var money_before: float = GameState.money
		_expect(SaveManager.autosave(), "activity pre-entry checkpoint failed")
		var prior_disk: PackedByteArray = FileAccess.get_file_as_bytes(
			SaveManager.slot_path(SaveManager.AUTOSAVE_SLOT))
		if mode == "cancel":
			SaveManager.set_meta("_qa_fail_next_primary_replacement", true)
			main_game.call("_full_story_continue_activity", at_turn, "entry")
			_expect(bool(main_game.call("_full_story_pending_activity_save_is_valid")) \
					and not bool(main_game.get("_minigame_overlay_active")) \
					and GameState.money == money_before and GameState.action_points == stored_ap \
					and FileAccess.get_file_as_bytes(SaveManager.slot_path(SaveManager.AUTOSAVE_SLOT)) \
						== prior_disk,
				"failed entry save opened/spent activity or replaced the last successful disk")
			var failed: Dictionary = GameState.serialize().duplicate(true)
			_expect(not bool(main_game.call("_full_story_advance_week", at_turn)),
				"failed entry save allowed calendar progression")
			_expect(SaveManager.load_game(SaveManager.AUTOSAVE_SLOT) \
					and not GameState.flags.has("full_story_activity_save_pending") \
					and FULL_STORY_FLOW.pending_activity_id() == "racetrack",
				"failed entry cold restore did not use the successful pre-entry checkpoint")
			GameState.call("_restore_serialized_snapshot_exact", failed)
		main_game.call("_full_story_continue_activity", at_turn, "entry")
		_expect(bool(main_game.get("_minigame_overlay_active")) \
				and not GameState.flags.has("full_story_activity_save_pending") \
				and GameState.money == money_before and GameState.action_points == stored_ap,
			"authored full activity did not durably enter without AP/cash replay")
		# Cold reopening uses the successfully saved pre-overlay checkpoint, not
		# a serialization of an in-flight race. Existing overlay save policy stays.
		await _free_monthly_economy_main(main_game)
		GameState.start_new_game()
		_expect(SaveManager.load_game(SaveManager.AUTOSAVE_SLOT) \
				and FULL_STORY_FLOW.valid_session() \
				and FULL_STORY_FLOW.pending_activity_id() == "racetrack" \
				and str((FULL_STORY_FLOW.snapshot()["activity_receipts"] as Dictionary)[str(at_turn)]["status"]) == "pending",
			"actual pending activity did not survive cold v4 checkpoint load")
		main_game = await _spawn_monthly_economy_main()
		var pending: Dictionary = GameState.serialize().duplicate(true)
		main_game.call("_begin_month")
		_expect(GameState.serialize() == pending and not bool(main_game.get("_minigame_overlay_active")) \
				and not bool(main_game.call("_full_story_advance_week", at_turn)),
			"pending cold Main bypassed direct activity into another story/month/AP")
		main_game.call("_full_story_continue_activity", at_turn, "entry")
		var race: Control = main_game.get("racetrack") as Control
		_expect(is_instance_valid(race) and race.visible and GameState.turn == at_turn,
			"pending cold activity could not reopen its actual Racetrack overlay")
		money_before = GameState.money
		var addiction_before: int = GameState.addiction_tendency
		if mode == "tip-cancel":
			race.call("_consult_dealer")
			_expect(GameState.money == money_before - 3_000.0 \
					and GameState.addiction_tendency == addiction_before + 1,
				"actual pre-bet tip did not apply its original price/addiction producer")
		elif mode == "round":
			race.set_meta("skip_countdown_for_smoke", true)
			race.call("_toggle_pick", 0)
			race.call("_place_bet", 10_000.0)
			race.set_process(false)
			_expect(GameState.money == money_before - 10_000.0,
				"actual Racetrack wager did not debit exactly one stake")
			# Explicit elapsed-time injection through the actual phase-guarded
			# process method, not a new payout implementation or a forced winner.
			race.call("_process", float(race.get("_race_dur")) + 1.0)
			var payout: float = float(race.get("_payout_amt"))
			_expect(GameState.money == money_before - 10_000.0 + payout \
					and int(race.get("_completed_races")) == 1,
				"actual completed round lost/doubled its original payout")
			var paid: Dictionary = GameState.serialize().duplicate(true)
			race.call("_process", float(race.get("_race_dur")) + 1.0)
			_expect(GameState.serialize() == paid and int(race.get("_completed_races")) == 1,
				"completed race process reapplied its payout")
		var summary: Dictionary = race.call("get_session_summary")
		var cash_after_activity: float = GameState.money
		var rounds: int = int(summary["rounds"])
		var net: float = float(summary["net"])
		if mode == "tip-cancel":
			_expect(rounds == 0 and net == -3_000.0,
				"pre-bet information cost disappeared from actual cancelled-session summary")
		if mode == "round":
			SaveManager.set_meta("_qa_fail_next_primary_replacement", true)
		race.call("_on_exit")
		_expect(GameState.turn == at_turn and GameState.money == cash_after_activity \
				and GameState.action_points == stored_ap \
				and FULL_STORY_FLOW.pending_activity_id().is_empty() \
				and not bool(main_game.get("_minigame_overlay_active")),
			"actual activity close repaid net, consumed AP, or changed the same story week")
		if mode == "round":
			_expect(bool(main_game.call("_full_story_pending_activity_save_is_valid")) \
					and not bool(main_game.call("_full_story_advance_week", at_turn)),
				"failed completed activity save did not freeze calendar retry")
			var settled: Dictionary = GameState.serialize().duplicate(true)
			var expected: Dictionary = settled.duplicate(true)
			(expected["flags"] as Dictionary).erase("full_story_activity_save_pending")
			seed(541_029)
			var next_random: int = randi()
			seed(541_029)
			main_game.call("_full_story_continue_activity", at_turn, "closed")
			_expect(GameState.serialize() == expected and randi() == next_random,
				"completed activity write-only retry changed cash/axis/log/owner/RNG")
		var closed: Dictionary = GameState.serialize().duplicate(true)
		_expect(FULL_STORY_FLOW.close_activity("racetrack", rounds, net) \
				and not FULL_STORY_FLOW.close_activity("racetrack", rounds + 1, net) \
				and not FULL_STORY_FLOW.close_activity("racetrack", rounds, net + 1.0) \
				and not FULL_STORY_FLOW.begin_activity("racetrack") \
				and GameState.serialize() == closed,
			"closed activity duplicate/conflicting receipt replayed its real effects")
		main_game.call("_on_racetrack_closed")
		_expect(GameState.serialize() == closed,
			"duplicate actual closed callback repaid/logged the same session")
		await _production_cold_checkpoint(main_game, "activity-" + mode)
		main_game.call("_continue_after_story")
		_expect(FULL_STORY_FLOW.ready_to_advance(), "closed activity did not release its same-week owner")
		_expect(bool(main_game.call("_full_story_advance_week", at_turn)) \
				and GameState.turn == at_turn + 1 and GameState.action_points == stored_ap,
			"closed activity did not advance once without AP")
		await _free_monthly_economy_main(main_game)
	GameState.call("_restore_serialized_snapshot_exact", checkpoint)
	print("MANUAL_SAVE_FULL_STORY_ACTIVITY_CHECK_OK root=actual-choice1 modes=cancel/tip-cancel/one-round checkpoint=pending-cold/closed-cold fault=entry/closed-write-only duplicate=receipt/callback payout=original/AP-preserved prepared-W29-root=1 natural=0")


func _check_production_calendar_values() -> void:
	var before: Dictionary = GameState.serialize().duplicate(true)
	for values in [[1, 1, 1, 2026, 33], [48, 4, 12, 2026, 33],
			[49, 1, 1, 2027, 34], [240, 4, 12, 2030, 37], [241, 1, 1, 2031, 38]]:
		_expect(FULL_STORY_FLOW._calendar_values_match(FULL_STORY_FLOW.PROFILE_FULL,
			int(values[0]), values[1], values[2], values[3], values[4]),
			"normal full date formula rejected W%d" % int(values[0]))
		_expect(FULL_STORY_FLOW._calendar_values_match(FULL_STORY_FLOW.PROFILE_FULL,
			int(values[0]), float(values[1]), float(values[2]), float(values[3]), float(values[4])),
			"normal full date formula rejected JSON integral dates")
		for damaged in [str(values[1]), true, float(values[1]) + 0.5, NAN, -1, 5]:
			_expect(not FULL_STORY_FLOW._calendar_values_match(FULL_STORY_FLOW.PROFILE_FULL,
				int(values[0]), damaged, values[2], values[3], values[4]),
				"normal full date formula accepted a damaged week")
		_expect(not FULL_STORY_FLOW._calendar_values_match(FULL_STORY_FLOW.PROFILE_FULL,
			int(values[0]), values[1], int(values[2]) + 1, values[3], values[4]) \
			and not FULL_STORY_FLOW._calendar_values_match(FULL_STORY_FLOW.PROFILE_FULL,
			int(values[0]), values[1], values[2], int(values[3]) + 1, values[4]) \
			and not FULL_STORY_FLOW._calendar_values_match(FULL_STORY_FLOW.PROFILE_FULL,
			int(values[0]), values[1], values[2], values[3], int(values[4]) + 1),
			"normal full date formula accepted a mismatched month/year/age")
	_expect(GameState.serialize() == before, "pure full date matrix mutated the actual run")


func _check_production_event_log_tail(checkpoint: Dictionary) -> void:
	# Repeat a real catalog choice through the actual apply/close APIs on
	# explicitly prepared weeks. This is cap/receipt evidence, not story pacing.
	GameState.call("_restore_serialized_snapshot_exact", checkpoint)
	var event: Dictionary = DataRegistry.find_event("arc_paycheck_reality")
	var choice: Dictionary = (event.get("choices", []) as Array)[0]
	for iteration in range(105):
		var at_turn: int = GameState.turn
		_expect(FULL_STORY_FLOW.begin_chain(["arc_paycheck_reality"]) \
				and GameState.apply_choice(event, choice) \
				and FULL_STORY_FLOW.close_result("arc_paycheck_reality", 0) \
				and FULL_STORY_FLOW.close_chain() \
				and FULL_STORY_FLOW.apply_background_for_turn(at_turn),
			"tail-cap prepared actual apply/close failed at W%d" % at_turn)
		if not FULL_STORY_FLOW.ready_to_advance():
			return
		GameState.advance_calendar()
		_expect(FULL_STORY_FLOW.complete_turn(at_turn),
			"tail-cap prepared calendar completion failed")
	_expect(GameState.event_log.size() > 100 and FULL_STORY_FLOW.valid_session(),
		"tail-cap fixture did not produce over 100 real choice receipts")
	var owner_before: Dictionary = FULL_STORY_FLOW.snapshot()
	var seen_before: int = GameState.events_seen
	_expect(SaveManager.save_game(TEST_SLOT, {}, {"qa_fixture": true}),
		"full historical choice-cap checkpoint save failed")
	GameState.start_new_game()
	_expect(SaveManager.load_game(TEST_SLOT) and GameState.event_log.size() == 100 \
			and GameState.events_seen == seen_before and FULL_STORY_FLOW.valid_session() \
			and _json_round_trip_dictionary(FULL_STORY_FLOW.snapshot()) \
				== _json_round_trip_dictionary(owner_before),
		"cold tail100 rejected an actually completed historical choice prefix")
	var intact: Dictionary = GameState.serialize().duplicate(true)
	var owner: Dictionary = FULL_STORY_FLOW.snapshot()
	var old_read: Dictionary = (owner["read_receipts"] as Dictionary)["4"][0]
	(old_read["applied_tuple"] as Dictionary)["choice_index"] = 1
	GameState.flags[FULL_STORY_FLOW.STATE_KEY] = owner
	_expect(not FULL_STORY_FLOW.valid_session(),
		"tail100 accepted a tampered historical applied tuple")
	GameState.call("_restore_serialized_snapshot_exact", intact)
	var at_turn: int = GameState.turn
	_expect(FULL_STORY_FLOW.begin_chain(["arc_paycheck_reality"]) \
			and GameState.apply_choice(event, choice),
		"tail100 could not apply the next genuine current choice")
	var applied: Dictionary = GameState.serialize().duplicate(true)
	GameState.event_log.pop_back()
	var missing_before: Dictionary = GameState.serialize().duplicate(true)
	_expect(not FULL_STORY_FLOW.close_result("arc_paycheck_reality", 0) \
			and GameState.serialize() == missing_before,
		"tail100 archival path manufactured a missing current applied result")
	GameState.call("_restore_serialized_snapshot_exact", applied)
	_expect(FULL_STORY_FLOW.close_result("arc_paycheck_reality", 0) and FULL_STORY_FLOW.close_chain(),
		"tail100 next current result could not close against its real retained log")
	var closed: Dictionary = GameState.serialize().duplicate(true)
	GameState.event_log.pop_back()
	_expect(not FULL_STORY_FLOW.valid_session(),
		"tail100 archival fallback admitted an incomplete current-week missing receipt")
	GameState.call("_restore_serialized_snapshot_exact", closed)
	_expect(FULL_STORY_FLOW.apply_background_for_turn(at_turn), "tail100 next routine failed")
	GameState.advance_calendar()
	_expect(FULL_STORY_FLOW.complete_turn(at_turn), "tail100 next completion failed")
	owner_before = FULL_STORY_FLOW.snapshot()
	seen_before = GameState.events_seen
	_expect(SaveManager.save_game(TEST_SLOT, {}, {"qa_fixture": true}), "tail101 second save failed")
	GameState.start_new_game()
	_expect(SaveManager.load_game(TEST_SLOT) and GameState.event_log.size() == 100 \
			and GameState.events_seen == seen_before and FULL_STORY_FLOW.valid_session() \
			and _json_round_trip_dictionary(FULL_STORY_FLOW.snapshot()) \
				== _json_round_trip_dictionary(owner_before),
		"second tail100 cold load lost historical/current real receipt ownership")
	GameState.call("_restore_serialized_snapshot_exact", checkpoint)
	print("MANUAL_SAVE_FULL_STORY_TAIL_CHECK_OK choices=105+1-actual-apply/close cap=100/cold-twice current-missing=reject historical-tuple-tamper=reject prepared-calendar=1 natural=0")


func _production_prepared_owner(checkpoint: Dictionary, at_turn: int) -> void:
	# Prepared, internally well-formed historical shapes ONLY. These rows do
	# not claim those weeks were played or their scenes/economy were observed.
	GameState.call("_restore_serialized_snapshot_exact", checkpoint)
	var owner: Dictionary = FULL_STORY_FLOW.snapshot()
	var routines: Dictionary = owner["routine_receipts"]
	var completed: Dictionary = owner["completed_turns"]
	var template: Dictionary = routines["28"].duplicate(true)
	for prior_turn in range(29, at_turn):
		var receipt: Dictionary = template.duplicate(true)
		receipt["turn"] = prior_turn
		routines[str(prior_turn)] = receipt
		completed[str(prior_turn)] = {"turn": prior_turn, "next_turn": prior_turn + 1}
	owner["last_completed_turn"] = at_turn - 1
	owner["chain"] = {}
	GameState.flags[FULL_STORY_FLOW.STATE_KEY] = owner
	GameState.turn = at_turn
	GameState.week_of_month = (at_turn - 1) % 4 + 1
	GameState.month = int((at_turn - 1) / 4) % 12 + 1
	GameState.year = 2026 + int((at_turn - 1) / 48)
	GameState.age = 33 + int((at_turn - 1) / 48)
	GameState.pending_story_queue.clear()
	GameState.returning_from_story = false
	SaveManager.clear_loaded_resume_context()
	_expect(FULL_STORY_FLOW.valid_session(), "prepared full owner matrix is not well formed")


func _check_production_causal_handoff(checkpoint: Dictionary) -> void:
	# Only the prior causal ledger and elapsed owner are prepared. The two W210
	# roots, applied effects, exact handoff and result/cold consumers are live.
	_production_prepared_owner(checkpoint, 210)
	var owner: Dictionary = FULL_STORY_FLOW.snapshot()
	var prefix_flags: Dictionary = GameState.flags.duplicate(true)
	var prefix_log: Array = GameState.event_log.duplicate(true)
	var prefix_events_seen: int = GameState.events_seen
	_prepare_chapter5_product_path()
	for key in prefix_flags:
		if not GameState.flags.has(key):
			GameState.flags[key] = prefix_flags[key]
	GameState.event_log = prefix_log
	GameState.events_seen = prefix_events_seen
	_expect(GameState.prepare_chapter5_causal_route_entry(),
		"prepared W210 causal entry could not lock its original context")
	for turn_value in range(195, 210):
		GameState.turn = turn_value
		for _same_turn_guard in range(4):
			var event_id: String = GameState.chapter5_causal_next_event_for_turn()
			if event_id.is_empty():
				break
			_expect(bool(GameState.record_chapter5_causal_choice(event_id, 0).get("ok", false)),
				"prepared W210 predecessor ledger rejected original %s choice 0" % event_id)
	GameState.flags[FULL_STORY_FLOW.STATE_KEY] = owner
	GameState.turn = 210
	GameState.week_of_month = 2
	GameState.month = 5
	GameState.year = 2030
	GameState.age = 37
	var source_id: String = "arc_y5_jaehyuk_return_call_reference"
	var target_id: String = "arc_y5_jaehyuk_father_document_reference"
	_expect(FULL_STORY_FLOW.valid_session() \
			and GameState.chapter5_causal_next_event_for_turn() == source_id,
		"prepared W210 did not stop before its actual return-call root")
	var main_game: Control = await _spawn_monthly_economy_main()
	# The prepared 2.1B balance must carry the live milestone producer's
	# history before testing a settled cold boundary. Advance only its existing
	# presentation timeout; never ignore milestone/log deltas on re-entry.
	var wealth_before: Dictionary = GameState.serialize().duplicate(true)
	for _milestone_timeout in range(6):
		(main_game.get("_milestone_portrait_timer") as Timer).stop()
		main_game.call("_on_milestone_portrait_timeout")
		await get_tree().process_frame
	var wealth_settled: bool = not bool(main_game.get("_milestone_portrait_active")) \
			and not bool(GameState.flags.get("just_hit_milestone", false))
	for milestone_id in ["10m", "50m", "100m", "500m", "1b", "2b"]:
		wealth_settled = wealth_settled and GameState.milestones_reached.get(milestone_id) == true
	_expect(wealth_settled and GameState.money == float(wealth_before["money"]) \
			and GameState.mental == int(wealth_before["mental"]) \
			and GameState.action_points == int(wealth_before["action_points"]) \
			and GameState.events_seen == int(wealth_before["events_seen"]),
		"prepared W210 wealth history did not settle through its original milestone producer")
	_expect(bool(main_game.call("_route_chapter5_causal_week")) \
			and GameState.pending_story_queue == [source_id],
		"actual Main W210 causal route did not issue only the next exact root")
	if await _spawn_full_story_fixture():
		var before: Dictionary = GameState.serialize().duplicate(true)
		var reads: Array[String] = []
		await _read_production_story(main_game, {source_id: 1, target_id: 0}, reads)
		await _free_story()
		GameState.returning_from_story = false
		# event_director's W210 owner is the return call. Its actual existing
		# weekly commitment spends AP once even though both choices have no
		# authored numeric effects; the document root must not overwrite it.
		var commitments: Array = GameState.weekly_commitments
		var commitment: Dictionary = (commitments[-1] as Dictionary) if not commitments.is_empty() else {}
		var forgone: Variant = commitment.get("forgone_choice_indexes", null)
		var forgone_exact: bool = forgone is Array and (forgone as Array).size() == 2 \
				and typeof(forgone[0]) in [TYPE_INT, TYPE_FLOAT] \
				and typeof(forgone[1]) in [TYPE_INT, TYPE_FLOAT] \
				and float(forgone[0]) == 0.0 and float(forgone[1]) == 2.0
		var checks: Dictionary = {
			"roots": reads == [source_id, target_id],
			"turn": GameState.turn == 210,
			"source_receipt": GameState.chapter5_causal_receipt_matches(source_id, 1, 210),
			"target_receipt": GameState.chapter5_causal_receipt_matches(target_id, 0, 210),
			"causal_week": GameState.chapter5_causal_week_completed(),
			"owner_valid": FULL_STORY_FLOW.valid_session(),
			"ready": FULL_STORY_FLOW.ready_to_advance(),
			"money": GameState.money == float(before["money"]),
			"mental": GameState.mental == int(before["mental"]),
			"ap_once": GameState.action_points == 0,
			"events_once": GameState.events_seen == int(before["events_seen"]) + 2,
			"commitment_once": commitments.size() == (before["weekly_commitments"] as Array).size() + 1,
			"commitment_owner": commitment.get("source") == "story_event" \
					and commitment.get("story_event_id") == source_id \
					and int(commitment.get("story_choice_index", -1)) == 1 \
					and int(commitment.get("turn", -1)) == 210 \
					and commitment.get("axis") == "human" \
					and commitment.get("person_id") == "jaehyuk" \
					and commitment.get("actual_action_id") == "story_choice" \
					and forgone_exact,
		}
		var causal_exact: bool = not checks.values().has(false)
		if not causal_exact:
			print("FULL_STORY_CAUSAL_COMPONENT_DIAGNOSTIC checks=%s reads=%s money=%s/%s mental=%s/%s ap=%s/%s events=%s/%s commitment=%s" % [
				JSON.stringify(checks), reads, GameState.money, before["money"], GameState.mental,
				before["mental"], GameState.action_points, before["action_points"], GameState.events_seen,
				int(before["events_seen"]) + 2, JSON.stringify(commitment)])
		_expect(causal_exact,
			"actual W210 two-root causal consumer lost a result, receipt or original gameplay effect")
		await _production_cold_checkpoint(main_game, "prepared-W210-two-root")
		_expect(bool(main_game.call("_full_story_advance_week", 210)) and GameState.turn == 211,
			"closed W210 two-root chain did not release exactly one calendar edge")
		var after: Dictionary = GameState.serialize().duplicate(true)
		_expect(not bool(main_game.call("_full_story_advance_week", 210)) \
				and GameState.serialize() == after,
			"W210 causal duplicate released a second calendar edge")
	await _free_monthly_economy_main(main_game)
	GameState.call("_restore_serialized_snapshot_exact", checkpoint)
	SaveManager.clear_loaded_resume_context()
	print("MANUAL_SAVE_FULL_STORY_CAUSAL_CHECK_OK week=210 roots=actual-return-call1/father-document0 handoff=exact/duplicate/conflict/front-closed result=cold-both/unread-blocked calendar=once prepared-owner/prior-ledger=1 natural=0")


func _check_production_year_and_terminal(checkpoint: Dictionary) -> void:
	_production_prepared_owner(checkpoint, 48)
	for scene_id in ["story_knee_choice", "arc_daeun_01_meet", "arc_sangchul_01_meet", "arc_father_01_call"]:
		GameState.record_run_scene_seen(scene_id)
	var main_game: Control = await _spawn_monthly_economy_main()
	main_game.call("_go_story_mode", ["arc_year1_scene"])
	if await _spawn_full_story_fixture():
		var choices: Array = (_story.get("_current") as Dictionary).get("choices", [])
		_expect(choices.size() >= 3, "prepared full year scene did not materialize dynamic choices")
		var reads: Array[String] = []
		await _read_production_story(main_game, {"arc_year1_scene": 2}, reads)
		await _free_story()
		_expect(FULL_STORY_FLOW.valid_session() and FULL_STORY_FLOW.ready_to_advance() \
				and not GameState.get_year_scene_selection(1).is_empty(),
			"actual dynamic year index 2 did not close its full-owner receipt")
		var year_owner: Dictionary = FULL_STORY_FLOW.snapshot()
		for bad_year_scene in [
			{"year": 2, "scene_id": GameState.get_year_scene_selection(1)},
			{"year": 1.5, "scene_id": GameState.get_year_scene_selection(1)},
			{"year": true, "scene_id": GameState.get_year_scene_selection(1)},
			{"year": "1", "scene_id": GameState.get_year_scene_selection(1)},
			{"year": 1, "scene_id": "order541_wrong_scene"},
			{"year": 1, "scene_id": GameState.get_year_scene_selection(1), "extra": true},
		]:
			var damaged: Dictionary = year_owner.duplicate(true)
			(damaged["read_receipts"]["48"][0] as Dictionary)["year_scene"] = bad_year_scene
			GameState.flags[FULL_STORY_FLOW.STATE_KEY] = damaged
			var before_reject: Dictionary = GameState.serialize().duplicate(true)
			_expect(not FULL_STORY_FLOW.valid_session() and not FULL_STORY_FLOW.ready_to_advance() \
					and GameState.serialize() == before_reject,
				"dynamic full year receipt accepted wrong/type-bad/extra-field binding")
		GameState.flags[FULL_STORY_FLOW.STATE_KEY] = year_owner
		_expect(bool(main_game.call("_full_story_advance_week", 48)) \
				and GameState.turn == 49 and GameState.month == 1 and GameState.year == 2027 \
				and GameState.age == 34 and FULL_STORY_FLOW.valid_session(),
			"actual W48 month-end missed full year/age rollover")
		await _production_cold_checkpoint(main_game, "prepared-W49")
	await _free_monthly_economy_main(main_game)
	_production_prepared_owner(checkpoint, 240)
	GameState.flags["foreground_story_turn"] = 240
	GameState.flags["arc_final_countdown_seen"] = true
	GameState.flags["arc_final_week_seen"] = true
	main_game = await _spawn_monthly_economy_main()
	_expect(bool(main_game.call("_complete_generic_finale_week_after_story")),
		"prepared generic W240 lost its original completion handoff")
	_expect(SaveManager.autosave(), "prepared generic pre-terminal checkpoint failed")
	var generic_disk: PackedByteArray = FileAccess.get_file_as_bytes(
		SaveManager.slot_path(SaveManager.AUTOSAVE_SLOT))
	SaveManager.set_meta("_qa_fail_next_primary_replacement", true)
	main_game.call("_full_story_advance_week", 240)
	_expect(GameState.turn == 241 and GameState.week_of_month == 1 and GameState.month == 1 \
			and GameState.year == 2031 and GameState.age == 38 and GameState.is_game_over \
			and FULL_STORY_FLOW.valid_session() \
			and int(FULL_STORY_FLOW.snapshot()["last_completed_turn"]) == 240,
		"generic terminal failed its original month-end/age-rollover or did not seal once")
	_expect(GameState.flags.has("full_story_calendar_save_pending") \
			and FileAccess.get_file_as_bytes(SaveManager.slot_path(SaveManager.AUTOSAVE_SLOT)) == generic_disk,
		"failed generic terminal write replaced its prior durable checkpoint")
	await _check_production_terminal_resume(main_game, "generic")
	var terminal: Dictionary = GameState.serialize().duplicate(true)
	main_game.call("_full_story_advance_week", 240)
	_expect(GameState.serialize() == terminal, "generic terminal repeated bills/calendar/ending")
	await _free_monthly_economy_main(main_game)
	await _check_production_typed_terminal(checkpoint)
	GameState.call("_restore_serialized_snapshot_exact", checkpoint)
	print("MANUAL_SAVE_FULL_STORY_MATRIX_CHECK_OK dates=pure-W49/W241 year=dynamic-index2/cold/W48-rollover terminal=typed-no-rollover/generic-rollover prepared-owner-matrix=1 natural-240=0")


func _check_production_typed_terminal(checkpoint: Dictionary) -> void:
	_production_prepared_owner(checkpoint, 240)
	var owner: Dictionary = FULL_STORY_FLOW.snapshot()
	var prefix_flags: Dictionary = GameState.flags.duplicate(true)
	var prefix_log: Array = GameState.event_log.duplicate(true)
	_seed_chapter5_general_sources()
	var prepared_source_log: Array = GameState.event_log.duplicate(true)
	for key in prefix_flags:
		if not GameState.flags.has(key):
			GameState.flags[key] = prefix_flags[key]
	GameState.event_log = prefix_log.duplicate(true)
	GameState.event_log.append_array(prepared_source_log)
	GameState.events_seen = int(checkpoint["events_seen"]) + prepared_source_log.size()
	GameState.turn = 224
	_expect(GameState.prepare_chapter5_finale_route_entry(), "prepared typed finale entry failed")
	for item in [
		[224, "arc_y5_general_father_legacy_voice_exact", 1],
		[229, "arc_y5_general_debt_memory_voice_exact", 0],
		[234, "arc_y5_general_pre_ending_summit_exact", 1],
		[237, "arc_y5_general_final_record_seal", 1],
	]:
		GameState.turn = int(item[0])
		_expect(bool(GameState.record_chapter5_finale_choice(str(item[1]), int(item[2])).get("ok", false)),
			"prepared typed finale could not consume original %s choice" % str(item[1]))
	GameState.flags[FULL_STORY_FLOW.STATE_KEY] = owner
	GameState.turn = 240
	GameState.week_of_month = 4
	GameState.month = 12
	GameState.year = 2030
	GameState.age = 37
	_expect(FULL_STORY_FLOW.valid_session() and not GameState.chapter5_finale_ending_ready(),
		"prepared typed terminal fabricated the unread outbound latch/full owner")
	var main_game: Control = await _spawn_monthly_economy_main()
	main_game.call("_go_story_mode", ["arc_final_countdown_general_near_goal_passed"])
	if not await _spawn_full_story_fixture():
		await _free_monthly_economy_main(main_game)
		return
	var reads: Array[String] = []
	await _read_production_story(main_game, {
		"arc_final_countdown_general_near_goal_passed": 1,
		"arc_y5_final_week_general_people_outbound": 0,
	}, reads)
	await _free_story()
	GameState.returning_from_story = false
	_expect(reads == ["arc_final_countdown_general_near_goal_passed",
			"arc_y5_final_week_general_people_outbound"] \
			and GameState.chapter5_finale_ending_ready() and FULL_STORY_FLOW.valid_session(),
		"actual typed signature/outbound ingress failed to close its original same-week chain")
	_expect(SaveManager.autosave(), "prepared typed pre-terminal checkpoint failed")
	var typed_disk: PackedByteArray = FileAccess.get_file_as_bytes(
		SaveManager.slot_path(SaveManager.AUTOSAVE_SLOT))
	SaveManager.set_meta("_qa_fail_next_primary_replacement", true)
	_expect(bool(main_game.call("_complete_chapter5_finale_week_after_story")) \
			and GameState.turn == 240 and GameState.week_of_month == 4 and GameState.month == 12 \
			and GameState.year == 2030 and GameState.age == 37 and GameState.is_game_over \
			and GameState.chapter5_finale_ending_consumed(),
		"typed terminal changed its original ending latch or advanced the calendar")
	_expect(GameState.flags.has("full_story_ending_save_pending") \
			and FileAccess.get_file_as_bytes(SaveManager.slot_path(SaveManager.AUTOSAVE_SLOT)) == typed_disk,
		"failed typed terminal write replaced its prior durable checkpoint")
	await _check_production_terminal_resume(main_game, "typed")
	var terminal: Dictionary = GameState.serialize().duplicate(true)
	main_game.call("_complete_chapter5_finale_week_after_story")
	_expect(GameState.serialize() == terminal, "typed duplicate terminal reran latch/ending/calendar")
	await _free_monthly_economy_main(main_game)


func _check_production_terminal_resume(main_game: Control, label: String) -> void:
	var pending: Dictionary = GameState.serialize().duplicate(true)
	var ending_id: String = str(GameState.flags.get("full_story_ending_id", ""))
	var meta_before: Dictionary = MetaProgression.data.duplicate(true)
	var unlocks_before: Dictionary = (MetaProgression.get("_new_this_run") as Dictionary).duplicate(true)
	_expect(not ending_id.is_empty() and not DataRegistry.get_ending(ending_id).is_empty(),
		"%s terminal did not retain the actual selected ending ID" % label)
	var expected: Dictionary = pending.duplicate(true)
	(expected["flags"] as Dictionary).erase("full_story_calendar_save_pending")
	(expected["flags"] as Dictionary).erase("full_story_ending_save_pending")
	seed(541_240)
	var next_random: int = randi()
	seed(541_240)
	_expect(bool(main_game.call("_full_story_resume_ending")) \
			and GameState.serialize() == expected and randi() == next_random \
			and MetaProgression.data == meta_before \
			and MetaProgression.get("_new_this_run") == unlocks_before,
		"%s terminal write-only retry reran ending/finish_run/calendar/RNG" % label)
	_expect(SaveManager.load_game(SaveManager.AUTOSAVE_SLOT) \
			and _json_round_trip_dictionary(GameState.serialize()) == _json_round_trip_dictionary(expected),
		"%s terminal successful retry did not persist its exact ended state" % label)
	var loaded: Dictionary = GameState.serialize().duplicate(true)
	var cold_expected: Dictionary = _full_story_expected_main_reentry(loaded, main_game)
	# MainGame._init_transient_portrait_timers clears only this instance-owned
	# celebration on entry. The successful retry/disk comparison above still
	# requires the original saved value; all other cold state remains exact.
	(cold_expected["flags"] as Dictionary)["just_hit_milestone"] = false
	var resumed: Control = await _spawn_monthly_economy_main()
	var resumed_handled: bool = bool(resumed.call("_full_story_resume_ending"))
	var cold_matches: bool = resumed_handled \
			and str(resumed.get("_ending_id")) == ending_id \
			and GameState.serialize() == cold_expected \
			and MetaProgression.data == meta_before \
			and MetaProgression.get("_new_this_run") == unlocks_before
	if not cold_matches:
		print("FULL_STORY_TERMINAL_COLD_DIAGNOSTIC kind=%s handled=%s ending_expected=%s ending_actual=%s helper_valid=%s state_exact=%s meta_exact=%s new_unlocks_exact=%s" % [
			label, resumed_handled, ending_id, resumed.get("_ending_id"), FULL_STORY_FLOW.valid_session(),
			GameState.serialize() == cold_expected, MetaProgression.data == meta_before,
			MetaProgression.get("_new_this_run") == unlocks_before])
		_report_full_story_state_diff(cold_expected, label + "-terminal-cold")
	_expect(cold_matches,
		"%s terminal cold Main did not restore the same ending without recording another run" % label)
	var cold: Dictionary = GameState.serialize().duplicate(true)
	seed(541_241)
	next_random = randi()
	seed(541_241)
	_expect(bool(resumed.call("_full_story_resume_ending")) \
			and GameState.serialize() == cold and randi() == next_random \
			and MetaProgression.data == meta_before,
		"%s duplicate cold ending replayed state/meta/RNG" % label)
	await _free_monthly_economy_main(resumed)
	# A valid terminal marker, not a nonempty presentation log, owns this save.
	# Exercise the actual disk reader and new Main with an explicitly prepared
	# empty log; preserve every other settled field and the selected ending.
	GameState.action_log.clear()
	var empty_log: Dictionary = GameState.serialize().duplicate(true)
	_expect(SaveManager.save_game(TEST_SLOT, {}, {"qa_fixture": true}),
		"%s empty-log terminal could not reach v4 disk" % label)
	GameState.call("_restore_serialized_snapshot_exact", cold)
	_expect(SaveManager.load_game(TEST_SLOT) \
			and _json_round_trip_dictionary(GameState.serialize()) == _json_round_trip_dictionary(empty_log) \
			and FULL_STORY_FLOW.valid_session(),
		"%s empty-log terminal cold load changed its settled state" % label)
	var empty_log_expected: Dictionary = _full_story_expected_main_reentry(
		GameState.serialize().duplicate(true), main_game)
	resumed = await _spawn_monthly_economy_main()
	var empty_log_handled: bool = bool(resumed.call("_full_story_resume_ending"))
	var empty_log_matches: bool = empty_log_handled \
			and str(resumed.get("_ending_id")) == ending_id \
			and FULL_STORY_FLOW.is_full_run() and FULL_STORY_FLOW.valid_session() \
			and GameState.serialize() == empty_log_expected \
			and MetaProgression.data == meta_before \
			and MetaProgression.get("_new_this_run") == unlocks_before
	if not empty_log_matches:
		print("FULL_STORY_TERMINAL_EMPTY_LOG_DIAGNOSTIC kind=%s handled=%s ending_expected=%s ending_actual=%s helper_valid=%s state_exact=%s meta_exact=%s new_unlocks_exact=%s" % [
			label, empty_log_handled, ending_id, resumed.get("_ending_id"), FULL_STORY_FLOW.valid_session(),
			GameState.serialize() == empty_log_expected, MetaProgression.data == meta_before,
			MetaProgression.get("_new_this_run") == unlocks_before])
		_report_full_story_state_diff(empty_log_expected, label + "-terminal-empty-log")
	_expect(empty_log_matches,
		"%s empty-log terminal Main reset its owner/ending/state or recorded another run" % label)
	await _free_monthly_economy_main(resumed)
	var damaged_owner: Dictionary = FULL_STORY_FLOW.snapshot()
	damaged_owner["schema"] = "order541_bad_schema"
	GameState.flags[FULL_STORY_FLOW.STATE_KEY] = damaged_owner
	var damaged_empty_log: Dictionary = GameState.serialize().duplicate(true)
	resumed = await _spawn_monthly_economy_main()
	_expect(FULL_STORY_FLOW.owns_session() and not FULL_STORY_FLOW.valid_session() \
			and GameState.flags[FULL_STORY_FLOW.STATE_KEY] == damaged_owner \
			and GameState.serialize() == damaged_empty_log \
			and str(resumed.get("_ending_id")).is_empty() \
			and MetaProgression.data == meta_before \
			and MetaProgression.get("_new_this_run") == unlocks_before,
		"%s damaged-owner empty-log Main reset or silently reinterpreted its saved state" % label)
	await _free_monthly_economy_main(resumed)
	for bad_id in [null, "order541_missing_ending"]:
		GameState.call("_restore_serialized_snapshot_exact", cold)
		if bad_id == null:
			GameState.flags.erase("full_story_ending_id")
		else:
			GameState.flags["full_story_ending_id"] = bad_id
		var invalid: Dictionary = GameState.serialize().duplicate(true)
		resumed = await _spawn_monthly_economy_main()
		var invalid_expected: Dictionary = _full_story_expected_main_reentry(invalid, main_game)
		var invalid_handled: bool = bool(resumed.call("_full_story_resume_ending"))
		var invalid_matches: bool = invalid_handled \
				and str(resumed.get("_ending_id")).is_empty() \
				and GameState.serialize() == invalid_expected \
				and MetaProgression.data == meta_before
		if not invalid_matches:
			print("FULL_STORY_TERMINAL_BAD_ID_DIAGNOSTIC kind=%s bad_id=%s handled=%s ending_actual=%s helper_valid=%s state_exact=%s meta_exact=%s new_unlocks_exact=%s" % [
				label, bad_id, invalid_handled, resumed.get("_ending_id"), FULL_STORY_FLOW.valid_session(),
				GameState.serialize() == invalid_expected, MetaProgression.data == meta_before,
				MetaProgression.get("_new_this_run") == unlocks_before])
			_report_full_story_state_diff(invalid_expected, label + "-terminal-bad-id")
		_expect(invalid_matches,
			"%s missing/bad terminal ID reopened/reselected/recorded an ending" % label)
		await _free_monthly_economy_main(resumed)
	GameState.call("_restore_serialized_snapshot_exact", cold)
	SaveManager.clear_loaded_resume_context()
	print("MANUAL_SAVE_FULL_STORY_TERMINAL_CHECK_OK kind=%s cold=same-ending/meta-exact retry=write-only/rng missing-id=sealed wrong-id=sealed prepared-owner-matrix=1 natural=0" % label)


func _check_paycheck_window() -> void:
	# Explicit synthetic weeks and production method calls, not natural ingress,
	# a new preview cap, or evidence that the monthly transition is idempotent.
	await _free_story()
	var previous_language: String = LocaleManager.language
	var events_before: Dictionary = _full_story_event_snapshot()
	LocaleManager.set_language("ko")
	GameState.start_new_game()
	var main_game: Control = await _spawn_monthly_economy_main()
	if GameState.is_demo_build() or CORE_LOOP.requested():
		GameState.current_job = DataRegistry.get_job("job_01").duplicate(true)
		GameState.flags["has_received_paycheck"] = true
		if CORE_LOOP.requested():
			GameState.core_loop_v2_state["enabled"] = true
		var excluded: Dictionary = GameState.serialize().duplicate(true)
		_expect(bool(main_game.call("_paycheck_reality_available", GameState.flags, 14)) \
				and bool(main_game.call("_paycheck_reality_available", GameState.flags, 17)) \
				and not bool(main_game.call("_paycheck_reality_available", GameState.flags, 18)) \
				and not bool(main_game.call("_paycheck_reality_available", GameState.flags, 25)) \
				and GameState.serialize() == excluded,
			"demo/V2 paycheck window no longer preserves W14-W17 without mutation")
		print("MANUAL_SAVE_PAYCHECK_WINDOW_EXCLUSION_CHECK_OK profile=%s window=W14-W17 synthetic=1" % [
			"demo" if GameState.is_demo_build() else "v2"])
	else:
		for hire_choice in [0, 1]:
			await _free_monthly_economy_main(main_game)
			GameState.start_new_game()
			EventManager.pending_events.clear()
			EventManager.current_event = {}
			EventManager.narrative_bridge_results.clear()
			GameState.turn = 14
			GameState.month = 4
			GameState.week_of_month = 2
			main_game = await _spawn_monthly_economy_main()
			_expect(not FULL_STORY_FLOW.owns_session(),
				"paycheck fixture manufactured or extended a preview profile")
			var before_hire: Dictionary = GameState.serialize().duplicate(true)
			if not await _paycheck_story_choice(main_game, "arc_rescue_job", hire_choice):
				break
			_expect(GameState.money == float(before_hire["money"]) \
					and bool(GameState.flags.get("arc_rescue_job_seen", false)) \
					and not GameState.flags.get("has_received_paycheck", false),
				"rescue choice paid a salary before the real monthly producer")
			if hire_choice == 1:
				_expect(GameState.current_job.is_empty() and GameState.monthly_income == 0.0 \
						and bool(GameState.flags.get("rejected_rescue_job", false)) \
						and str(main_game.call("_first_job_week_arc_id", GameState.flags, 15)).is_empty() \
						and not bool(main_game.call("_paycheck_reality_available", GameState.flags, 18)),
					"refused rescue job invented employment, first work, or a paycheck reader")
				await _paycheck_cold_main(main_game, "refused")
				continue
			var job: Dictionary = DataRegistry.get_job("job_01")
			var salary: float = float(job.get("base_salary", 0.0))
			_expect(str(GameState.current_job.get("id", "")) == "job_01" \
					and GameState.job_tenure == 0 and GameState.work_performance == 50 \
					and GameState.monthly_income == salary \
					and float(GameState.current_job.get("effective_salary", -1.0)) == salary \
					and not GameState.current_job.has("pending_first_paycheck_ratio") \
					and int(GameState.flags.get("job_started_turn", -1)) == 14 \
					and bool(GameState.flags.get("has_job", false)) \
					and str(main_game.call("_first_job_week_arc_id", GameState.flags, 14)).is_empty(),
				"authored rescue accept changed its catalog job/salary or opened first work in the hire week")
			_check_paycheck_eligibility(main_game)
			GameState.turn = 15
			GameState.week_of_month = 3
			var first_work: String = main_game.call("_first_job_week_arc_id", GameState.flags)
			_expect(first_work == "arc_first_job_week_convenience",
				"actual rescue job did not select the convenience first-work scene")
			if not await _paycheck_story_choice(main_game, first_work, 0):
				break
			_expect(bool(GameState.flags.get("arc_first_job_week_seen", false)) \
					and str(main_game.call("_first_job_week_arc_id", GameState.flags)).is_empty() \
					and not bool(main_game.call("_paycheck_reality_available", GameState.flags, 18)),
				"first work replayed or fabricated the unpaid paycheck flag")
			GameState.turn = 16
			GameState.week_of_month = 4
			var before_pay: Dictionary = GameState.serialize().duplicate(true)
			var payable: float = GameState.get_monthly_payable_income()
			var required_cash: float = GameState.get_monthly_required_cash()
			_expect(payable == salary, "rescue job unexpectedly prorated its unauthored first paycheck")
			seed(540_016)
			main_game.call("_run_month_end_transition", false, false)
			_expect(GameState.turn == 17 and GameState.month == 5 and GameState.week_of_month == 1 \
					and GameState.money == float(before_pay["money"]) + payable - required_cash \
					and GameState.monthly_income == salary and GameState.job_tenure == 1 \
					and int(GameState.flags.get("career_months_total", 0)) == 1 \
					and bool(GameState.flags.get("has_received_paycheck", false)),
				"one real month-end transition lost/doubled salary, bills, tenure, or the first-paycheck producer")
			await _paycheck_cold_main(main_game, "paid")
			# These prior-scene flags are synthetic selector prerequisites, not a
			# claim that this fixture played the preceding sixteen weeks.
			for flag in ["arc_intro_dad_seen", "arc_temptation_seen", "arc_intro_sns_seen",
					"cafe_scenario_seen", "arc_intro_hyunsu_seen", "chapter1_closed", "cafe_callback_seen",
					"arc_money_check_seen", "arc_gosiwon_wall_seen", "arc_sangchul_met_seen",
					"arc_invest_guidance_seen", "arc_daeun_met", "arc_father_01_seen",
					"arc_father_quiet_call_seen", "arc_father_02_done"]:
				GameState.flags[flag] = true
			var before_query: Dictionary = GameState.serialize().duplicate(true)
			_expect(str(main_game.call("_next_arc_id", 17, false, false)) == "arc_jiyeon_01_crash" \
					and GameState.serialize() == before_query,
				"paycheck repair preempted the higher-priority W17 Jiyeon scene")
			GameState.flags["arc_jiyeon_crash_seen"] = true
			GameState.turn = 18
			GameState.week_of_month = 2
			before_query = GameState.serialize().duplicate(true)
			_expect(bool(main_game.call("_paycheck_reality_available", GameState.flags)) \
					and str(main_game.call("_next_arc_id", 18, false, false)) == "arc_paycheck_reality" \
					and str(main_game.call("_next_arc_id", 25, false, true)) == "arc_paycheck_reality" \
					and GameState.serialize() == before_query,
				"unread paid full-game paycheck expired at W18/W25 or live query consumed its bridge")
			var before_reader_money: float = GameState.money
			if not await _paycheck_story_choice(main_game, "arc_paycheck_reality", 0, true):
				break
			_expect(GameState.money == before_reader_money - 3_800.0 \
					and GameState.monthly_income == salary and GameState.job_tenure == 1 \
					and bool(GameState.flags.get("arc_paycheck_reality_seen", false)) \
					and not bool(main_game.call("_paycheck_reality_available", GameState.flags, 18)) \
					and not bool(main_game.call("_paycheck_reality_available", GameState.flags, 25)),
				"paycheck reader reapplied salary or lost its original choice effect/seen guard")
			await _paycheck_cold_main(main_game, "read")
			_paycheck_window_checked = true
	await _free_monthly_economy_main(main_game)
	GameState.start_new_game()
	for key in events_before:
		EventManager.set(key, events_before[key].duplicate(true))
	SaveManager.clear_loaded_resume_context()
	LocaleManager.set_language(previous_language)


func _check_paycheck_eligibility(main_game: Control) -> void:
	var before: Dictionary = GameState.serialize().duplicate(true)
	var paid: Dictionary = GameState.flags.duplicate(true)
	paid["has_received_paycheck"] = true
	seed(540_014)
	var next_random: int = randi()
	seed(540_014)
	_expect(not bool(main_game.call("_paycheck_reality_available", paid, 13)) \
			and bool(main_game.call("_paycheck_reality_available", paid, 14)) \
			and bool(main_game.call("_paycheck_reality_available", paid, 17)) \
			and bool(main_game.call("_paycheck_reality_available", paid, 18)) \
			and not bool(main_game.call("_paycheck_reality_available", GameState.flags, 18)),
		"full paycheck helper changed minimum week/current job/lifetime paid prerequisites")
	paid["arc_paycheck_reality_seen"] = true
	_expect(not bool(main_game.call("_paycheck_reality_available", paid, 18)),
		"already read paycheck became eligible again")
	paid.erase("arc_paycheck_reality_seen")
	GameState.current_job = {}
	_expect(not bool(main_game.call("_paycheck_reality_available", paid, 18)),
		"lifetime paycheck history manufactured a reader without a current job")
	GameState.call("_restore_serialized_snapshot_exact", before)
	GameState.core_loop_v2_state["enabled"] = true
	_expect(bool(main_game.call("_paycheck_reality_available", paid, 17)) \
			and not bool(main_game.call("_paycheck_reality_available", paid, 18)) \
			and not bool(main_game.call("_paycheck_reality_available", paid, 25)),
		"loaded V2 ownership lost its original paycheck deadline beyond its active cap")
	GameState.call("_restore_serialized_snapshot_exact", before)
	_expect(GameState.serialize() == before and randi() == next_random,
		"paycheck availability queries mutated the actual job/flags or global RNG")


func _paycheck_story_choice(
		main_game: Control, event_id: String, choice_index: int, cold_result: bool = false) -> bool:
	main_game.call("_go_story_mode", [event_id])
	if not await _spawn_full_story_fixture():
		return false
	var event: Dictionary = _story.get("_current")
	var choices: Array = event.get("choices", [])
	_expect(str(event.get("id", "")) == event_id and choice_index < choices.size(),
		"paycheck production handoff loaded the wrong event/choice")
	if choice_index >= choices.size():
		await _free_story()
		return false
	var before: Dictionary = GameState.serialize().duplicate(true)
	_show_current_story_choices()
	_story.call("_on_choice", choice_index)
	var after: Dictionary = GameState.serialize().duplicate(true)
	_expect(GameState.event_log.size() == (before["event_log"] as Array).size() + 1 \
			and GameState.event_log.slice(0, (before["event_log"] as Array).size()) \
				== before["event_log"] \
			and str(GameState.event_log[-1].get("event_id", "")) == event_id \
			and int(GameState.event_log[-1].get("choice_index", -1)) == choice_index,
		"%s failed to produce exactly one real authored choice receipt" % event_id)
	var effects: Dictionary = (choices[choice_index] as Dictionary).get("effects", {})
	_expect(GameState.money == float(before["money"]) + float(effects.get("money", 0.0)),
		"%s manufactured a salary deposit outside its authored cash effect" % event_id)
	for key in effects:
		var expected_value: float = float(before[key]) + float(effects[key])
		if str(key) != "money":
			expected_value = clampf(expected_value, 0.0, 100.0)
		_expect(float(GameState.get(str(key))) == expected_value,
			"%s changed authored %s choice effects" % [event_id, key])
	_story.call("_on_choice", choice_index)
	_expect(GameState.serialize() == after,
		"%s repeated result input reapplied its job/cash/choice" % event_id)
	if cold_result:
		var context: Dictionary = _story.call("build_save_resume_context")
		_expect(str(context.get("phase", "")) == "result" \
				and SaveManager.save_game(TEST_SLOT, context, {"qa_fixture": true}),
			"paycheck result could not save its original v4 context")
		await _free_story()
		GameState.start_new_game()
		_expect(SaveManager.load_game(TEST_SLOT), "paycheck result cold load failed")
		if not await _spawn_full_story_fixture(true):
			return false
		_expect(bool(_story.get("_pending_after_result")) \
				and int(_story.get("_pending_result_choice_index")) == choice_index \
				and _json_round_trip_dictionary(GameState.serialize()) == _json_round_trip_dictionary(after),
			"paycheck result cold resume replayed salary/choice or lost its exact saved choice")
	_story.call("_finish_story_scene_transition")
	_story.call("_complete_typing")
	_story.set("_para_index", (_story.get("_paragraphs") as Array).size())
	_story.call("_after_result")
	_expect(bool(_story.get("_transitioning")), "%s result did not close through StoryMode" % event_id)
	await _free_story()
	GameState.returning_from_story = false
	SaveManager.clear_loaded_resume_context()
	return true


func _paycheck_cold_main(main_game: Control, label: String) -> void:
	var before: Dictionary = GameState.serialize().duplicate(true)
	_expect(SaveManager.save_game(TEST_SLOT, {}, {"qa_fixture": true}),
		"%s paycheck checkpoint could not save" % label)
	var disk: Variant = JSON.parse_string(FileAccess.get_file_as_string(SaveManager.slot_path(TEST_SLOT)))
	_expect(disk is Dictionary and int(disk.get("version", -1)) == 4,
		"paycheck checkpoint changed the existing v4 save schema")
	GameState.start_new_game()
	_expect(SaveManager.load_game(TEST_SLOT) \
			and _json_round_trip_dictionary(GameState.serialize()) == _json_round_trip_dictionary(before),
		"%s paycheck disk cold load regranted employment/salary or changed saved effects" % label)
	var expected: Dictionary = _full_story_expected_main_reentry(before, main_game)
	# Diagnostic run isolated one existing AP-presentation write, not an
	# economic delta. Predict that exact reader only under its original guards;
	# every other state field remains covered by the complete comparison below.
	var expected_flags: Dictionary = expected["flags"]
	if bool(expected_flags.get("has_received_paycheck", false)) \
			and not bool(expected_flags.get("invest_hint_shown", false)):
		var earlier_hint: bool = int(expected["turn"]) == 1 \
			or (int(expected["tutorial_step"]) >= 1 \
				and bool(expected_flags.get("story_job_unlocked", false)) \
				and (expected["current_job"] as Dictionary).is_empty())
		_expect(not earlier_hint,
			"paycheck UI expectation may not skip an earlier week-one/unemployed hint")
		if not earlier_hint:
			expected_flags["invest_hint_shown"] = true
			print("PAYCHECK_WINDOW_HINT_REENTRY_PROOF label=%s paid=1 previously_shown=0 earlier_hint=0 expected_ui_flag=invest_hint_shown" % label)
	var cold_main: Control = await _spawn_monthly_economy_main()
	if _json_round_trip_dictionary(GameState.serialize()) != _json_round_trip_dictionary(expected):
		_report_full_story_state_diff(expected, "paycheck-%s-new-main" % label, true)
	if FULL_STORY_FLOW.owns_session():
		print("PAYCHECK_WINDOW_OWNER_DIFF label=%s owner=%s" % [
			label, JSON.stringify(FULL_STORY_FLOW.snapshot(), "", true, true)])
	_expect(_json_round_trip_dictionary(GameState.serialize()) == _json_round_trip_dictionary(expected) \
			and not FULL_STORY_FLOW.owns_session(),
		"%s new Main regranted salary/job or promoted an unmarked save" % label)
	await _free_monthly_economy_main(cold_main)
	SaveManager.clear_loaded_resume_context()


func _check_full_story_flow() -> void:
	# Synthetic, isolated production calls, not natural reading or M07 evidence.
	await _free_story()
	var previous_language := LocaleManager.language
	LocaleManager.set_language("ko")
	GameState.start_new_game()
	var legacy_before: Dictionary = GameState.serialize().duplicate(true)
	_expect(not FULL_STORY_FLOW.owns_session(),
		"full story preview claimed an unmarked legacy/new run")
	if not OS.get_cmdline_user_args().has("--full-story-flow-preview"):
		_expect(not FULL_STORY_FLOW.initialize_fresh_preview() \
				and GameState.serialize() == legacy_before,
			"full story preview activated without its explicit fresh opt-in")
		if _full_story_flow_only:
			_fail("positive full-story-flow-only requires preview opt-in and pre-autoload isolation")
		print("MANUAL_SAVE_FULL_STORY_EXCLUSION_CHECK_OK profile=unmarked activated=0")
		LocaleManager.set_language(previous_language)
		return
	if GameState.is_demo_build() or CORE_LOOP.requested():
		_expect(not FULL_STORY_FLOW.initialize_fresh_preview() \
				and GameState.serialize() == legacy_before,
			"full story preview activated in a demo/V2 process")
		print("MANUAL_SAVE_FULL_STORY_EXCLUSION_CHECK_OK profile=%s activated=0" % [
			"v2" if CORE_LOOP.requested() else "demo"])
		LocaleManager.set_language(previous_language)
		return
	_expect(FULL_STORY_FLOW.initialize_fresh_preview(),
		"full story fixture requires explicit preview and proven isolated full environment")
	if not FULL_STORY_FLOW.valid_session():
		LocaleManager.set_language(previous_language)
		return
	var initial: Dictionary = GameState.serialize().duplicate(true)
	_expect(FULL_STORY_FLOW.initialize_fresh_preview() \
			and GameState.serialize() == initial \
			and not FULL_STORY_FLOW.ready_to_advance(),
		"fresh preview initialization reran or skipped unread W1 prologue/card")
	if OS.get_cmdline_user_args().has(FULL_STORY_FLOW.THIRD_MONTH_ARG):
		await _check_full_story_third_month_flow(previous_language)
		return
	for route_case in [
		{"label": "clean", "first": 0, "later": 0},
		{"label": "return", "first": 1, "later": 0},
		{"label": "deeper", "first": 1, "later": 1},
	]:
		GameState.start_new_game()
		EventManager.pending_events.clear()
		EventManager.current_event = {}
		EventManager.event_cooldowns.clear()
		EventManager.recent_event_ids.clear()
		EventManager.narrative_bridge_results.clear()
		_expect(FULL_STORY_FLOW.initialize_fresh_preview(),
			"%s fresh preview could not initialize" % route_case["label"])
		var main_game: Control = await _spawn_monthly_economy_main()
		var roots: Array[String] = []
		for expected_turn in range(1, 9):
			_expect(GameState.turn == expected_turn,
				"%s skipped/repeated entry week %d" % [route_case["label"], expected_turn])
			main_game.call("_begin_month")
			var handoffs := 0
			while not GameState.pending_story_queue.is_empty() and handoffs < 8:
				roots.append(str(GameState.pending_story_queue[0]))
				if not await _spawn_full_story_fixture():
					break
				await _read_full_story_fixture(main_game, route_case)
				await _free_story()
				GameState.returning_from_story = false
				main_game.call("_continue_after_story")
				handoffs += 1
			_expect(handoffs < 8 and FULL_STORY_FLOW.ready_to_advance(),
				"%s W%d did not close its actual roots/follow-up chain" % [
					route_case["label"], expected_turn])
			if not FULL_STORY_FLOW.ready_to_advance():
				break
			if expected_turn == 2 and str(route_case["label"]) == "clean":
				_check_full_story_background_once()
			_expect(bool(main_game.call("_full_story_route_week")) \
					and GameState.turn == expected_turn \
					and int(main_game.get_meta("_full_story_ready_turn", -1)) == expected_turn,
				"static full router escaped ownership or advanced without its test caller")
			var before: Dictionary = GameState.serialize().duplicate(true)
			var required_cash := GameState.get_monthly_required_cash()
			var payable_income := GameState.get_monthly_payable_income()
			if expected_turn == 4 and str(route_case["label"]) == "clean":
				_check_full_story_owner_guards(main_game)
				await _check_full_story_calendar_save_retry(main_game)
			else:
				_expect(bool(main_game.call("_full_story_advance_week", expected_turn)),
					"%s W%d production advance failed" % [route_case["label"], expected_turn])
			_expect(GameState.turn == expected_turn + 1 \
					and GameState.week_of_month == expected_turn % 4 + 1,
				"full story calendar did not advance exactly one week")
			var expected_money := float(before["money"]) + 70_000.0
			if expected_turn % 4 == 0:
				expected_money += payable_income - required_cash
				if expected_turn == 4:
					expected_money += 300_000.0
			_expect(GameState.money == expected_money \
					and GameState.current_job.is_empty() and GameState.monthly_income == 0.0,
				"%s W%d lost/doubled background, subsidy, or real month-end bills" % [
					route_case["label"], expected_turn])
			_expect(GameState.action_axis_this_week == {"money": 0, "human": 0} \
					and GameState.action_records_this_week.is_empty() \
					and GameState.tendency == before["tendency"],
				"automatic background fabricated a player action or identity score")
			var after: Dictionary = GameState.serialize().duplicate(true)
			seed(536)
			var next_random := randi()
			seed(536)
			_expect(not bool(main_game.call("_full_story_advance_week", expected_turn)) \
					and randi() == next_random and GameState.serialize() == after,
				"duplicate/stale full advance changed state or RNG")
		_expect(roots.size() >= 4 and roots[0] == "story_flashforward" \
				and roots[1] == "chapter_card_33" \
				and roots.has("arc_temptation_01") \
				and roots.has("arc_temptation_clean" if int(route_case["first"]) == 0 \
					else "arc_temptation_fallout"),
			"%s production roots lost prologue/card, W4 decision, or W8 consequence" % route_case["label"])
		_expect(GameState.turn == 9 and GameState.month == 3 \
				and FULL_STORY_FLOW.at_boundary() \
				and bool(GameState.flags.get("settlement_subsidy_received", false)),
			"full preview did not stop after eight weeks/two real settlements")
		if str(route_case["label"]) == "return":
			var reservations := 0
			for raw_entry in GameState.deferred_events:
				if raw_entry is Dictionary \
						and str(raw_entry.get("event_id", "")) == "callback_escaped_dirty_trace" \
						and int(raw_entry.get("trigger_turn", -1)) == 24:
					reservations += 1
			_expect(reservations == 1,
				"W8 return lost/doubled its authored W24 reservation")
		await _check_full_story_boundary_resume(main_game)
		await _free_monthly_economy_main(main_game)
	GameState.start_new_game()
	GameState.core_loop_v2_state = {"enabled": true}
	var excluded: Dictionary = GameState.serialize().duplicate(true)
	_expect(not FULL_STORY_FLOW.initialize_fresh_preview() \
			and not FULL_STORY_FLOW.owns_session() and GameState.serialize() == excluded,
		"full preview reissued an existing V2 run as a fresh full session")
	GameState.start_new_game()
	SaveManager.clear_loaded_resume_context()
	LocaleManager.set_language(previous_language)
	_full_story_flow_checked = true


func _check_full_story_third_month_flow(previous_language: String) -> void:
	# A separate explicit profile; the existing eight-week fixture/marker keeps
	# its own base-only process. All reading here is synthetic production calls.
	_expect(FULL_STORY_FLOW.last_turn() == 12 \
			and FULL_STORY_FLOW.snapshot().get("profile") == FULL_STORY_FLOW.PROFILE_THIRD_MONTH,
		"third-month companion did not create its separately bounded profile")
	for route_case in [
		{"label": "clean", "first": 0, "later": 0, "hyunsu": 0},
		{"label": "return", "first": 1, "later": 0, "hyunsu": 1},
		{"label": "deeper", "first": 1, "later": 1, "hyunsu": 0},
	]:
		GameState.start_new_game()
		EventManager.pending_events.clear()
		EventManager.current_event = {}
		EventManager.event_cooldowns.clear()
		EventManager.recent_event_ids.clear()
		EventManager.narrative_bridge_results.clear()
		_expect(FULL_STORY_FLOW.initialize_fresh_preview() \
				and FULL_STORY_FLOW.last_turn() == 12,
			"third-month %s could not initialize its fresh opt-in" % route_case["label"])
		var main_game: Control = await _spawn_monthly_economy_main()
		var roots: Array[String] = []
		var first_eight: Dictionary = {}
		for expected_turn in range(1, 13):
			_expect(GameState.turn == expected_turn,
				"third-month %s skipped/repeated W%d" % [route_case["label"], expected_turn])
			if expected_turn == 9:
				first_eight = FULL_STORY_FLOW.snapshot()
				await _check_full_story_old_profile_checkpoint(main_game)
				main_game = await _cold_full_story_third_month_checkpoint(main_game)
			var news_before: int = GameState.news_log.size()
			main_game.call("_begin_month")
			if expected_turn == 9:
				_expect(int(GameState.flags.get("monthly_economy_turn", -1)) == 9 \
						and GameState.news_log.size() > news_before,
					"W9 cold continuation skipped its first third-month economic opening")
				_expect_full_story_prefix(first_eight, "W9 opening")
				_expect_monthly_economy_inert(main_game, "third-month W9 cold duplicate")
			if expected_turn >= 9:
				var allowed_roots: Array = {
					9: ["arc_intro_04_hyunsu"],
					10: ["arc_job_first_rejection"],
					11: ["arc_money_check_low", "arc_money_check_mid"],
					12: ["arc_gosiwon_wall"],
				}[expected_turn]
				_expect(GameState.pending_story_queue.size() == 1 \
						and allowed_roots.has(str(GameState.pending_story_queue[0])),
					"W%d lost its actual one-root priority/bridge exclusion: %s" % [
						expected_turn, GameState.pending_story_queue])
			var handoffs := 0
			while not GameState.pending_story_queue.is_empty() and handoffs < 8:
				roots.append(str(GameState.pending_story_queue[0]))
				if not await _spawn_full_story_fixture():
					break
				await _read_full_story_fixture(main_game, route_case)
				await _free_story()
				GameState.returning_from_story = false
				main_game.call("_continue_after_story")
				handoffs += 1
			_expect(handoffs < 8 and FULL_STORY_FLOW.ready_to_advance(),
				"third-month %s W%d left an unfinished actual root/follow-up" % [
					route_case["label"], expected_turn])
			if not FULL_STORY_FLOW.ready_to_advance():
				break
			if expected_turn == 9:
				var reads: Array = FULL_STORY_FLOW.snapshot()["read_receipts"].get("9", [])
				_expect(reads.size() == 2 \
						and reads[0].get("event_id") == "arc_intro_04_hyunsu" \
						and int(reads[0].get("choice_index", -1)) == int(route_case["hyunsu"]) \
						and reads[1].get("event_id") == "arc_chapter1_close" \
						and bool(GameState.flags.get("chapter1_closed", false)),
					"W9 did not read the chosen Hyunsu result followed by its actual chapter close")
				_check_full_story_unknown_profile(main_game)
				if str(route_case["label"]) == "clean":
					await _check_full_story_pending_activity(main_game)
			var before: Dictionary = GameState.serialize().duplicate(true)
			var required_cash: float = GameState.get_monthly_required_cash()
			var payable_income: float = GameState.get_monthly_payable_income()
			if expected_turn in [9, 12] and str(route_case["label"]) == "clean":
				await _check_full_story_calendar_save_retry(main_game, expected_turn)
			else:
				_expect(bool(main_game.call("_full_story_advance_week", expected_turn)),
					"third-month %s W%d production advance failed" % [
						route_case["label"], expected_turn])
			var expected_money: float = float(before["money"]) + 70_000.0
			if expected_turn % 4 == 0:
				expected_money += payable_income - required_cash
				if expected_turn == 4:
					expected_money += 300_000.0
			_expect(GameState.turn == expected_turn + 1 \
					and GameState.week_of_month == expected_turn % 4 + 1 \
					and GameState.money == expected_money \
					and GameState.current_job.is_empty() and GameState.monthly_income == 0.0,
				"third-month W%d lost/doubled calendar, real bills, subsidy, or background" % expected_turn)
			_expect(GameState.action_points == int(before["action_points"]) \
					and GameState.action_axis_this_week == {"money": 0, "human": 0} \
					and GameState.action_records_this_week.is_empty() \
					and GameState.tendency == before["tendency"],
				"third-month automatic time fabricated AP/actions/identity")
			var after: Dictionary = GameState.serialize().duplicate(true)
			seed(538)
			var next_random: int = randi()
			seed(538)
			_expect(not bool(main_game.call("_full_story_advance_week", expected_turn)) \
					and randi() == next_random and GameState.serialize() == after,
				"third-month duplicate/stale advance changed state or RNG")
			if expected_turn >= 9:
				_expect_full_story_prefix(first_eight, "after W%d" % expected_turn)
		_expect(roots.size() >= 8 and roots[0] == "story_flashforward" \
				and roots[1] == "chapter_card_33" and roots.has("arc_temptation_01") \
				and roots.has("arc_temptation_clean" if int(route_case["first"]) == 0 \
					else "arc_temptation_fallout") \
				and roots.has("arc_intro_04_hyunsu") and roots.has("arc_job_first_rejection") \
				and roots.has("arc_gosiwon_wall"),
			"third-month production roots changed the first-eight prefix or skipped month three")
		_expect(GameState.turn == 13 and GameState.month == 4 \
				and FULL_STORY_FLOW.last_turn() == 12 and FULL_STORY_FLOW.at_boundary() \
				and int(FULL_STORY_FLOW.snapshot().get("last_completed_turn", -1)) == 12 \
				and int(GameState.flags.get("monthly_economy_turn", -1)) == 9 \
				and bool(GameState.flags.get("settlement_subsidy_received", false)),
			"third-month preview did not stop after exactly twelve weeks/three settlements")
		if str(route_case["label"]) == "return":
			var reservations := 0
			for raw_entry in GameState.deferred_events:
				if raw_entry is Dictionary \
						and raw_entry.get("event_id") == "callback_escaped_dirty_trace" \
						and int(raw_entry.get("trigger_turn", -1)) == 24:
					reservations += 1
			_expect(reservations == 1, "third month lost/doubled the original W8-to-W24 reservation")
		await _check_full_story_boundary_resume(main_game, 13)
		await _free_monthly_economy_main(main_game)
	GameState.start_new_game()
	SaveManager.clear_loaded_resume_context()
	LocaleManager.set_language(previous_language)
	_full_story_third_month_checked = true


func _expect_full_story_prefix(first_eight: Dictionary, label: String) -> void:
	var current: Dictionary = FULL_STORY_FLOW.snapshot()
	for section in ["read_receipts", "routine_receipts", "completed_turns"]:
		var prefix: Dictionary = first_eight.get(section, {})
		var actual: Dictionary = current.get(section, {})
		for key in prefix:
			_expect(_json_round_trip_dictionary({"value": actual.get(key)}) \
					== _json_round_trip_dictionary({"value": prefix[key]}),
				"%s changed the durable W1-W8 %s.%s prefix" % [label, section, key])


func _check_full_story_old_profile_checkpoint(main_game: Control) -> void:
	# Shape-only compatibility sample from the real first-eight receipts. It is
	# not an old-profile run; the unchanged base-only fixture proves that path.
	var before: Dictionary = GameState.serialize().duplicate(true)
	var events_before: Dictionary = _full_story_event_snapshot()
	var old_owner: Dictionary = FULL_STORY_FLOW.snapshot()
	old_owner["profile"] = FULL_STORY_FLOW.PROFILE
	GameState.flags[FULL_STORY_FLOW.STATE_KEY] = old_owner
	var old_state: Dictionary = GameState.serialize().duplicate(true)
	_expect(FULL_STORY_FLOW.valid_session() and FULL_STORY_FLOW.last_turn() == 8 \
			and FULL_STORY_FLOW.at_boundary() and FULL_STORY_FLOW.initialize_fresh_preview() \
			and GameState.serialize() == old_state,
		"third-month companion promoted an existing eight-week profile")
	await _check_full_story_boundary_resume(main_game)
	_expect(FULL_STORY_FLOW.last_turn() == 8 \
			and FULL_STORY_FLOW.snapshot().get("profile") == FULL_STORY_FLOW.PROFILE,
		"old-profile disk/new Main silently acquired the twelve-week profile")
	GameState.call("_restore_serialized_snapshot_exact", before)
	for key in events_before:
		EventManager.set(key, events_before[key].duplicate(true))
	SaveManager.clear_loaded_resume_context()


func _cold_full_story_third_month_checkpoint(main_game: Control) -> Control:
	var before: Dictionary = GameState.serialize().duplicate(true)
	_expect(GameState.turn == 9 and int(FULL_STORY_FLOW.snapshot()["last_completed_turn"]) == 8 \
			and SaveManager.save_game(TEST_SLOT, {}, {"qa_fixture": true}),
		"third-month first-eight checkpoint could not save through existing v4")
	await _free_monthly_economy_main(main_game)
	GameState.start_new_game()
	_expect(SaveManager.load_game(TEST_SLOT) and FULL_STORY_FLOW.valid_session() \
			and FULL_STORY_FLOW.last_turn() == 12 and not FULL_STORY_FLOW.at_boundary() \
			and _json_round_trip_dictionary(GameState.serialize()) \
				== _json_round_trip_dictionary(before),
		"W9 third-month cold load changed the actual first-eight checkpoint/profile")
	var new_main: Control = await _spawn_monthly_economy_main()
	_expect(_json_round_trip_dictionary(GameState.serialize()) \
			== _json_round_trip_dictionary(before),
		"new W9 Main processed economy/story before its explicit production entry")
	return new_main


func _check_full_story_unknown_profile(main_game: Control) -> void:
	var before: Dictionary = GameState.serialize().duplicate(true)
	var unknown: Dictionary = FULL_STORY_FLOW.snapshot()
	unknown["profile"] = "unknown_full_preview"
	GameState.flags[FULL_STORY_FLOW.STATE_KEY] = unknown
	var damaged: Dictionary = GameState.serialize().duplicate(true)
	seed(538_990)
	var next_random: int = randi()
	seed(538_990)
	_expect(FULL_STORY_FLOW.owns_session() and FULL_STORY_FLOW.last_turn() == 0 \
			and not FULL_STORY_FLOW.valid_session() and not FULL_STORY_FLOW.initialize_fresh_preview() \
			and not bool(main_game.call("_full_story_advance_week", 9)) \
			and GameState.serialize() == damaged and randi() == next_random,
		"unknown profile escaped ownership, acquired a cap, or advanced economics/RNG")
	GameState.call("_restore_serialized_snapshot_exact", before)


func _check_full_story_pending_activity(main_game: Control) -> void:
	# An explicitly synthetic unsupported-activity boundary, not a new authored
	# racetrack choice/visit receipt or proof of native minigame play.
	var before: Dictionary = GameState.serialize().duplicate(true)
	var events_before: Dictionary = _full_story_event_snapshot()
	GameState.flags["open_racetrack_after_story"] = true
	var pending: Dictionary = GameState.serialize().duplicate(true)
	_expect(FULL_STORY_FLOW.pending_activity_id() == "racetrack" \
			and not FULL_STORY_FLOW.ready_to_advance() \
			and SaveManager.save_game(TEST_SLOT, {}, {"qa_fixture": true}),
		"pending direct activity did not seal its exact saved owner")
	var disk_before := FileAccess.get_file_as_bytes(SaveManager.slot_path(TEST_SLOT))
	GameState.start_new_game()
	_expect(SaveManager.load_game(TEST_SLOT) \
			and _json_round_trip_dictionary(GameState.serialize()) == _json_round_trip_dictionary(pending) \
			and FULL_STORY_FLOW.pending_activity_id() == "racetrack",
		"cold direct-activity checkpoint consumed/lost its pending flag or prior receipts")
	for reentry in range(2):
		var expected: Dictionary = _full_story_expected_main_reentry(GameState.serialize(), main_game)
		seed(538_900 + reentry)
		var next_random: int = randi()
		seed(538_900 + reentry)
		var new_main: Control = await _spawn_monthly_economy_main()
		new_main.call("_begin_month")
		new_main.call("_continue_after_story")
		new_main.call("_continue_after_story")
		_expect(bool(new_main.call("_full_story_route_week")) \
				and not bool(new_main.call("_full_story_advance_week", 9)) \
				and not bool(new_main.call("_full_story_advance_week", 9)) \
				and FULL_STORY_FLOW.pending_activity_id() == "racetrack" \
				and new_main.get_meta("_full_story_waiting_for_activity", "") == "racetrack" \
				and GameState.serialize() == expected and randi() == next_random \
				and GameState.pending_story_queue.is_empty() and _full_story_surface_is_sealed(new_main) \
				and FileAccess.get_file_as_bytes(SaveManager.slot_path(TEST_SLOT)) == disk_before,
			"pending activity new Main %d consumed flag/receipts/disk or entered AP/economics/RNG" % reentry)
		await _free_monthly_economy_main(new_main)
	GameState.call("_restore_serialized_snapshot_exact", before)
	for key in events_before:
		EventManager.set(key, events_before[key].duplicate(true))
	SaveManager.clear_loaded_resume_context()


func _spawn_full_story_fixture(loaded: bool = false) -> bool:
	if not loaded:
		SaveManager.clear_loaded_resume_context()
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	_story.set_meta("_screenshot_qa_static_surface", true)
	add_child(_story)
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(_story) or (_story.get("_current") as Dictionary).is_empty():
		_fail("full story production handoff did not load its actual scene")
		return false
	_story.call("_set_auto_mode", false, false, false)
	_story.call("_finish_story_scene_transition")
	return true


func _read_full_story_fixture(main_game: Control, route_case: Dictionary) -> void:
	var fragments := 0
	while is_instance_valid(_story) and not bool(_story.get("_transitioning")) \
			and fragments < 48:
		var event: Dictionary = _story.get("_current")
		var event_id := str(event.get("id", ""))
		if bool(_story.get("_is_chapter_card")):
			_story.call("_chapter_card_advance")
			fragments += 1
			continue
		var choice_index := 0
		if event_id == "arc_temptation_01":
			choice_index = int(route_case["first"])
		elif event_id == "arc_temptation_fallout":
			choice_index = int(route_case["later"])
		elif event_id == "arc_intro_04_hyunsu":
			choice_index = int(route_case.get("hyunsu", 0))
		var choices: Array = event.get("choices", [])
		_expect(choice_index < choices.size(), "full story fixture lacks %s choice" % event_id)
		if choice_index >= choices.size():
			return
		var choice: Dictionary = choices[choice_index]
		_show_current_story_choices()
		var before: Dictionary = GameState.serialize().duplicate(true)
		_story.call("_on_choice", choice_index)
		var after_choice: Dictionary = GameState.serialize().duplicate(true)
		_story.call("_after_result")
		_expect(not FULL_STORY_FLOW.ready_to_advance() \
				and not bool(main_game.call("_full_story_advance_week", GameState.turn)) \
				and bool(_story.get("_pending_after_result")) \
				and GameState.serialize() == after_choice,
			"%s unread result allowed calendar/economic progress" % event_id)
		if event_id in ["arc_temptation_01", "arc_temptation_clean", "arc_temptation_fallout",
				"arc_intro_04_hyunsu", "arc_chapter1_close"]:
			var effects: Dictionary = choice.get("effects", {})
			_expect(GameState.money == float(before["money"]) + float(effects.get("money", 0)) \
					and GameState.mental == clampi(int(before["mental"]) + int(effects.get("mental", 0)), 0, 100) \
					and GameState.health == clampi(int(before["health"]) + int(effects.get("health", 0)), 0, 100),
				"%s changed the authored immediate choice effects" % event_id)
			_expect(not FULL_STORY_FLOW.close_result(event_id, choice_index + 99) \
					and not FULL_STORY_FLOW.close_result(event_id, choice_index, true) \
					and not FULL_STORY_FLOW.close_chain() \
					and GameState.serialize() == after_choice,
				"%s accepted a forged result/expression or unfinished chain" % event_id)
			_story.call("_on_choice", choice_index)
			_expect(GameState.serialize() == after_choice,
				"%s duplicate result input reapplied its chosen effect" % event_id)
		if event_id == "arc_temptation_01" and str(route_case["label"]) == "clean":
			var context: Dictionary = _story.call("build_save_resume_context")
			_expect(str(context.get("phase", "")) == "result" \
					and SaveManager.save_game(TEST_SLOT, context, {"qa_fixture": true}),
				"W4 full result could not be saved to v4 disk")
			await _free_story()
			GameState.start_new_game()
			_expect(SaveManager.load_game(TEST_SLOT), "W4 full result disk load failed")
			if not await _spawn_full_story_fixture(true):
				return
			_report_full_story_state_diff(after_choice, "W4-cold-result", true)
			if not bool(_story.get("_pending_after_result")) \
					or int(_story.get("_pending_result_choice_index")) != choice_index \
					or FULL_STORY_FLOW.ready_to_advance():
				print("FULL_STORY_RESUME_DIFF pending=%s index=%s expected_index=%d owns=%s valid=%s ready=%s" % [
					_story.get("_pending_after_result"), _story.get("_pending_result_choice_index"),
					choice_index, FULL_STORY_FLOW.owns_session(),
					FULL_STORY_FLOW.valid_session(), FULL_STORY_FLOW.ready_to_advance()])
			_expect(bool(_story.get("_pending_after_result")) \
					and int(_story.get("_pending_result_choice_index")) == choice_index \
					and _json_round_trip_dictionary(GameState.serialize()) \
						== _json_round_trip_dictionary(after_choice) \
					and not FULL_STORY_FLOW.ready_to_advance(),
				"W4 cold result lost owner, applied twice, or auto-closed unread prose")
		_story.call("_finish_story_scene_transition")
		_story.call("_complete_typing")
		_story.set("_para_index", (_story.get("_paragraphs") as Array).size())
		_story.call("_after_result")
		if not bool(_story.get("_transitioning")):
			_expect(not FULL_STORY_FLOW.ready_to_advance() \
					and not FULL_STORY_FLOW.close_chain(),
				"%s closed the calendar before its authored follow-up was read" % event_id)
		fragments += 1
	_expect(fragments < 48 and bool(_story.get("_transitioning")),
		"full story chain failed to finish through its production return")
	var closed: Dictionary = GameState.serialize().duplicate(true)
	_expect(FULL_STORY_FLOW.close_chain() and GameState.serialize() == closed,
		"duplicate full chain close changed the durable run")


func _check_full_story_calendar_save_retry(main_game: Control, expected_turn: int = 4) -> void:
	var before: Dictionary = GameState.serialize().duplicate(true)
	var event_before := _full_story_event_snapshot()
	_expect(SaveManager.autosave(), "full save-fault fixture could not create its prior checkpoint")
	var durable_before := FileAccess.get_file_as_bytes(SaveManager.slot_path(SaveManager.AUTOSAVE_SLOT))
	seed(536_000 + expected_turn)
	_expect(bool(main_game.call("_full_story_advance_week", expected_turn)),
		"no-fault full W%d control could not advance" % expected_turn)
	var control: Dictionary = GameState.serialize().duplicate(true)
	var next_random := randi()
	GameState.call("_restore_serialized_snapshot_exact", before)
	for key in event_before:
		EventManager.set(key, event_before[key].duplicate(true))
	_expect(SaveManager.autosave(), "full save-fault fixture could not restore its durable checkpoint")
	durable_before = FileAccess.get_file_as_bytes(SaveManager.slot_path(SaveManager.AUTOSAVE_SLOT))
	SaveManager.set_meta("_qa_fail_next_primary_replacement", true)
	seed(536_000 + expected_turn)
	_expect(not bool(main_game.call("_full_story_advance_week", expected_turn)) \
			and GameState.turn == expected_turn + 1 \
			and GameState.flags.has("full_story_calendar_save_pending") \
			and FileAccess.get_file_as_bytes(SaveManager.slot_path(SaveManager.AUTOSAVE_SLOT)) \
				== durable_before,
		"failed calendar save advanced the disk or discarded its settled in-memory checkpoint")
	var pending: Dictionary = GameState.serialize().duplicate(true)
	var pending_events := _full_story_event_snapshot()
	for damaged in ["invalid", {},
			{"from_turn": str(expected_turn), "target_turn": expected_turn + 1},
			{"from_turn": expected_turn - 1, "target_turn": expected_turn + 1},
			{"from_turn": expected_turn, "target_turn": expected_turn + 2}]:
		GameState.flags["full_story_calendar_save_pending"] = damaged
		var damaged_before: Dictionary = GameState.serialize().duplicate(true)
		_expect(not bool(main_game.call("_full_story_pending_save_is_valid")) \
				and not bool(main_game.call("_full_story_advance_week", expected_turn)) \
				and GameState.serialize() == damaged_before,
			"damaged/mismatched pending calendar save admitted an economic retry")
		GameState.call("_restore_serialized_snapshot_exact", pending)
	_expect(bool(main_game.call("_full_story_route_week")) \
			and GameState.serialize() == pending and GameState.pending_story_queue.is_empty(),
		"pending calendar save opened another story/economic month")
	_expect(SaveManager.load_game(SaveManager.AUTOSAVE_SLOT) \
			and GameState.turn == expected_turn \
			and not GameState.flags.has("full_story_calendar_save_pending") \
			and _json_round_trip_dictionary(GameState.serialize()) \
				== _json_round_trip_dictionary(before),
		"cold failed-save disk did not recover the last successful checkpoint")
	GameState.call("_restore_serialized_snapshot_exact", pending)
	for key in pending_events:
		EventManager.set(key, pending_events[key].duplicate(true))
	var expected_pending := _full_story_expected_main_reentry(pending, main_game)
	var expected_control := _full_story_expected_main_reentry(control, main_game)
	var new_main: Control = await _spawn_monthly_economy_main()
	new_main.call("_begin_month")
	_report_full_story_state_diff(expected_pending, "pending-new-main")
	if GameState.serialize() != expected_pending or not GameState.pending_story_queue.is_empty() \
			or (new_main.get("next_button") as Control).visible:
		print("FULL_STORY_PENDING_DIFF state_equal=%s queue_empty=%s next_visible=%s next_disabled=%s owns=%s valid=%s pending_valid=%s" % [
			GameState.serialize() == expected_pending, GameState.pending_story_queue.is_empty(),
			(new_main.get("next_button") as Control).visible,
			(new_main.get("next_button") as BaseButton).disabled,
			FULL_STORY_FLOW.owns_session(), FULL_STORY_FLOW.valid_session(),
			new_main.call("_full_story_pending_save_is_valid")])
	_expect(GameState.serialize() == expected_pending \
			and GameState.pending_story_queue.is_empty() \
			and not (new_main.get("next_button") as Control).visible,
		"new MainGame bypassed pending save into another month/story/AP")
	var retry_succeeded: bool = new_main.call("_full_story_advance_week", expected_turn)
	var retry_random: int = randi()
	_report_full_story_state_diff(expected_control, "pending-retry-control")
	if not retry_succeeded or retry_random != next_random:
		print("FULL_STORY_RETRY_DIFF succeeded=%s expected_next_rng=%d actual_next_rng=%d" % [
			retry_succeeded, next_random, retry_random])
	_expect(retry_succeeded and GameState.serialize() == expected_control and retry_random == next_random,
		"failed calendar save retry reran background/month-end RNG or differed from no-fault state")
	await _free_monthly_economy_main(new_main)


func _full_story_expected_main_reentry(expected: Dictionary, main_game: Control) -> Dictionary:
	# full4 raw isolated the new-Main delta to exactly these pre-existing JSON
	# integer readers. Do not normalize any other economic/receipt field here.
	var result: Dictionary = expected.duplicate(true)
	var tab_count: int = (main_game.get("info_tabs") as TabContainer).get_tab_count()
	for field in [
		{"section": "flags", "key": "_last_info_tab", "maximum": tab_count - 1},
		{"section": "market_context", "key": "cycle_timer", "maximum": 11},
	]:
		var section: String = field["section"]
		var key: String = field["key"]
		var raw: Variant = result[section].get(key)
		var valid: bool = (raw is int or raw is float) and is_finite(float(raw)) \
			and float(raw) == floor(float(raw)) and float(raw) >= 0.0 \
			and float(raw) <= float(field["maximum"])
		_expect(valid, "new-Main expected normalization requires a valid integral %s.%s" % [section, key])
		if valid:
			result[section][key] = int(raw)
			print("FULL_STORY_MAIN_REENTRY_INTEGER_PROOF field=%s.%s before_type=%d value=%s after_type=%d" % [
				section, key, typeof(raw), JSON.stringify(raw), TYPE_INT])
	return result


func _report_full_story_state_diff(
		expected: Dictionary, label: String, durable: bool = false) -> void:
	var actual: Dictionary = GameState.serialize().duplicate(true)
	if durable:
		expected = _json_round_trip_dictionary(expected)
		actual = _json_round_trip_dictionary(actual)
	_report_full_story_value_diff(expected, actual, label, "state")


func _report_full_story_value_diff(
		expected: Variant, actual: Variant, label: String, path: String) -> void:
	if expected == actual and typeof(expected) == typeof(actual):
		return
	if expected is Dictionary and actual is Dictionary:
		for key in expected:
			_report_full_story_value_diff(expected[key], actual.get(key), label, "%s.%s" % [path, key])
		for key in actual:
			if not expected.has(key):
				_report_full_story_value_diff(null, actual[key], label, "%s.%s" % [path, key])
		return
	if expected is Array and actual is Array and expected.size() == actual.size():
		for index in range(expected.size()):
			_report_full_story_value_diff(expected[index], actual[index], label, "%s[%d]" % [path, index])
		return
	print("FULL_STORY_STATE_DIFF label=%s field=%s before_type=%d after_type=%d before=%s after=%s" % [
		label, path, typeof(expected), typeof(actual),
		JSON.stringify(expected, "", true, true), JSON.stringify(actual, "", true, true)])


func _check_full_story_owner_guards(main_game: Control) -> void:
	var before: Dictionary = GameState.serialize().duplicate(true)
	GameState.is_game_over = true
	var fatal_before: Dictionary = GameState.serialize().duplicate(true)
	_expect(not FULL_STORY_FLOW.ready_to_advance() \
			and not bool(main_game.call("_full_story_advance_week", 4)) \
			and GameState.serialize() == fatal_before,
		"full preview revived or economically advanced an actual fatal boundary")
	GameState.call("_restore_serialized_snapshot_exact", before)
	var marker := FULL_STORY_FLOW.snapshot()
	var missing_reads: Dictionary = marker.duplicate(true)
	missing_reads.erase("read_receipts")
	var mismatched_completed: Dictionary = marker.duplicate(true)
	mismatched_completed["last_completed_turn"] = 0
	for damaged in ["invalid", {}, missing_reads, mismatched_completed]:
		GameState.flags[FULL_STORY_FLOW.STATE_KEY] = damaged
		var damaged_before: Dictionary = GameState.serialize().duplicate(true)
		seed(536_003)
		var next_random := randi()
		seed(536_003)
		_expect(FULL_STORY_FLOW.owns_session() and not FULL_STORY_FLOW.valid_session() \
				and not bool(main_game.call("_full_story_advance_week", 4)) \
				and GameState.serialize() == damaged_before and randi() == next_random,
			"damaged full owner escaped its saved boundary or mutated economics/RNG")
		GameState.call("_restore_serialized_snapshot_exact", before)


func _check_full_story_background_once() -> void:
	# A real catalog job is an explicitly synthetic boundary, not an authored
	# hire receipt. The automatic routine must not create such a receipt either.
	var before: Dictionary = GameState.serialize().duplicate(true)
	_expect(not DataRegistry.jobs.is_empty(), "full background fixture lacks a real job")
	if DataRegistry.jobs.is_empty():
		return
	GameState.current_job = (DataRegistry.jobs[0] as Dictionary).duplicate(true)
	GameState.monthly_income = float(GameState.current_job.get("base_salary", 0.0))
	var employed: Dictionary = GameState.serialize().duplicate(true)
	var reentry := [0, false]
	var reenter := func() -> void:
		reentry[0] += 1
		if reentry[0] == 1:
			reentry[1] = FULL_STORY_FLOW.apply_background_for_turn(2)
	GameState.stats_changed.connect(reenter)
	_expect(FULL_STORY_FLOW.apply_background_for_turn(2),
		"employed full background could not apply its approved band")
	GameState.stats_changed.disconnect(reenter)
	_expect(reentry[0] > 0 and not reentry[1] \
			and GameState.money == float(employed["money"]) \
			and GameState.health == clampi(int(employed["health"]) + 1, 0, 100) \
			and GameState.mental == clampi(int(employed["mental"]) + 4, 0, 100) \
			and GameState.work_performance == clampi(int(employed["work_performance"]) + 1, 0, 100) \
			and GameState.current_job == employed["current_job"] \
			and GameState.monthly_income == float(employed["monthly_income"]) \
			and GameState.job_tenure == int(employed["job_tenure"]) \
			and GameState.action_points == int(employed["action_points"]) \
			and GameState.action_axis_this_week == employed["action_axis_this_week"] \
			and GameState.action_records_this_week == employed["action_records_this_week"] \
			and GameState.tendency == employed["tendency"],
		"employed/reentrant automatic background changed income, hire, AP, or action identity")
	var applied: Dictionary = GameState.serialize().duplicate(true)
	seed(536_002)
	var next_random := randi()
	seed(536_002)
	_expect(FULL_STORY_FLOW.apply_background_for_turn(2) \
			and GameState.serialize() == applied and randi() == next_random,
		"duplicate full background changed its applied state or RNG")
	GameState.call("_restore_serialized_snapshot_exact", before)


func _full_story_event_snapshot() -> Dictionary:
	return {
		"pending_events": EventManager.pending_events.duplicate(true),
		"current_event": EventManager.current_event.duplicate(true),
		"event_cooldowns": EventManager.event_cooldowns.duplicate(true),
		"recent_event_ids": EventManager.recent_event_ids.duplicate(true),
		"narrative_bridge_results": EventManager.narrative_bridge_results.duplicate(true),
	}


func _check_full_story_boundary_resume(main_game: Control, boundary_turn: int = 9) -> void:
	var stored_ap: int = GameState.action_points
	_expect(bool(main_game.call("_full_story_route_week")) \
			and not bool(main_game.call("_full_story_advance_week", boundary_turn)) \
			and GameState.action_points == stored_ap and GameState.pending_story_queue.is_empty() \
			and int(main_game.get_meta("_full_story_preview_boundary", -1)) == boundary_turn \
			and _full_story_surface_is_sealed(main_game),
		"W%d internal checkpoint fell into AP/planning or advanced past its declared boundary" % boundary_turn)
	var before: Dictionary = GameState.serialize().duplicate(true)
	_expect(SaveManager.save_game(TEST_SLOT, {}, {"qa_fixture": true}),
		"full W%d checkpoint could not save" % boundary_turn)
	var disk: Variant = JSON.parse_string(FileAccess.get_file_as_string(SaveManager.slot_path(TEST_SLOT)))
	_expect(disk is Dictionary and int(disk.get("version", -1)) == 4,
		"full preview changed the existing v4 disk format")
	GameState.start_new_game()
	_expect(SaveManager.load_game(TEST_SLOT) and FULL_STORY_FLOW.valid_session() \
			and FULL_STORY_FLOW.at_boundary(),
		"full W%d v4 cold load lost its owner/boundary" % boundary_turn)
	var cold_main: Control = await _spawn_monthly_economy_main()
	cold_main.call("_begin_month")
	_expect(_json_round_trip_dictionary(GameState.serialize()) \
			== _json_round_trip_dictionary(before) \
			and GameState.action_points == stored_ap and GameState.pending_story_queue.is_empty() \
			and int(cold_main.get_meta("_full_story_preview_boundary", -1)) == boundary_turn \
			and _full_story_surface_is_sealed(cold_main),
		"new MainGame changed W%d economics/receipts or restored the AP surface" % boundary_turn)
	await _free_monthly_economy_main(cold_main)


func _full_story_surface_is_sealed(main_game: Control) -> bool:
	# Compatibility AP data remains intact. This owner hides its action surface,
	# rather than spending or erasing points that it did not produce.
	if (main_game.get("next_button") as Control).visible \
			or main_game.get("_ap_action_grid") != null \
			or not (main_game.get("_ap_grid_cards") as Array).is_empty():
		return false
	var labels: Dictionary = main_game.get("top_labels")
	if labels.has("ap_chip") and (labels["ap_chip"] as Control).visible:
		return false
	for child in (main_game.get("choice_box") as Control).get_children():
		if child is CanvasItem and (child as CanvasItem).visible:
			return false
	return true


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


func _check_w207_result_presentation_resume_and_locale() -> void:
	# Choices 0/1 must retain the meeting and Sangchul.  Rebuild the exact
	# predecessor route for each choice so the assertions exercise StoryMode's
	# live transaction instead of calling the visual helper in isolation.
	for retained_choice in [0, 1]:
		await _free_story()
		LocaleManager.set_language("ko")
		if not _prepare_chapter5_causal_w207_route():
			_fail("W207 retained-result fixture could not reach its exact root")
			return
		if not await _spawn_story("arc_y5_final_offer"):
			return
		_advance_story_fixture_to_choices()
		_story.call("_on_choice", retained_choice)
		await get_tree().process_frame
		_story.call("_finish_story_scene_transition")
		_assert_w207_result_presentation(
			retained_choice, "ko", "live retained choice %d" % retained_choice)

	await _free_story()
	LocaleManager.set_language("ko")
	if not _prepare_chapter5_causal_w207_route():
		_fail("W207 cafe-result fixture could not reach its exact root")
		return
	if not await _spawn_story("arc_y5_final_offer"):
		return
	_advance_story_fixture_to_choices()
	_story.call("_on_choice", 2)
	await get_tree().process_frame
	_story.call("_finish_story_scene_transition")
	_assert_w207_result_presentation(2, "ko", "live cafe result")
	var result_context: Dictionary = _story.call("build_save_resume_context")
	_expect(str(result_context.get("phase", "")) == "result" \
			and int(result_context.get("pending_result_choice_index", -1)) == 2 \
			and str(result_context.get("story_locale", "")) == "ko",
		"W207 cafe result did not build an exact Korean result resume context")
	var receipt_after_choice: Dictionary = \
		GameState.chapter5_causal_receipt_snapshot("arc_y5_final_offer")
	var event_log_count_after_choice := _w207_exact_event_log_count(2)
	_expect(SaveManager.save_game(TEST_SLOT, result_context),
		"W207 cafe result save failed")
	await _free_story()
	_expect(SaveManager.load_game(TEST_SLOT),
		"W207 cafe result save could not be reloaded")
	if not await _spawn_loaded_story():
		return
	_expect(str((_story.get("_current") as Dictionary).get("id", "")) \
			== "arc_y5_final_offer",
		"W207 result reload opened the wrong event")
	_assert_w207_result_presentation(2, "ko", "reloaded cafe result")
	_expect(GameState.chapter5_causal_receipt_snapshot(
			"arc_y5_final_offer") == receipt_after_choice \
			and event_log_count_after_choice == 1 \
			and _w207_exact_event_log_count(2) == event_log_count_after_choice,
		"W207 result reload replayed or lost its exact choice transaction")

	_story.call("_set_story_language", "en")
	for _frame in range(3):
		await get_tree().process_frame
	_assert_w207_result_presentation(2, "en", "in-place English result")
	_expect(GameState.chapter5_causal_receipt_snapshot(
			"arc_y5_final_offer") == receipt_after_choice \
			and _w207_exact_event_log_count(2) == event_log_count_after_choice,
		"W207 English result switch replayed or rewrote its choice transaction")

	_story.call("_set_story_language", "ko")
	for _frame in range(3):
		await get_tree().process_frame
	_assert_w207_result_presentation(2, "ko", "in-place Korean result")
	_expect(GameState.chapter5_causal_receipt_snapshot(
			"arc_y5_final_offer") == receipt_after_choice \
			and _w207_exact_event_log_count(2) == event_log_count_after_choice,
		"W207 Korean result switch replayed or rewrote its choice transaction")


func _prepare_chapter5_causal_w207_route() -> bool:
	_prepare_chapter5_product_path()
	if not GameState.prepare_chapter5_causal_route_entry():
		return false
	var predecessor_choices := {
		"arc_y5_jaehyuk_guarantee_decision_reference": 1,
		"arc_sangchul_final_door": 0,
		"arc_y5_three_in_room_decision": 1,
	}
	for turn_value in range(195, 208):
		GameState.turn = turn_value
		for _same_turn_guard in range(4):
			var event_id := GameState.chapter5_causal_next_event_for_turn()
			if event_id == "arc_y5_final_offer":
				return true
			if event_id.is_empty():
				break
			var result := GameState.record_chapter5_causal_choice(
				event_id, int(predecessor_choices.get(event_id, 0)))
			if not bool(result.get("ok", false)):
				return false
	return false


func _advance_story_fixture_to_choices() -> void:
	_story.call("_finish_story_scene_transition")
	_story.set("_para_index", (_story.get("_paragraphs") as Array).size() - 1)
	_story.call("_complete_typing")
	_story.call("_show_choices")


func _w207_exact_event_log_count(choice_index: int) -> int:
	var count := 0
	for raw_entry in GameState.event_log:
		if raw_entry is Dictionary \
				and str((raw_entry as Dictionary).get("event_id", "")) \
					== "arc_y5_final_offer" \
				and int((raw_entry as Dictionary).get("choice_index", -1)) \
					== choice_index:
			count += 1
	return count


func _assert_w207_result_presentation(
		choice_index: int, language: String, stage: String) -> void:
	if not is_instance_valid(_story):
		_fail("W207 %s has no live StoryMode" % stage)
		return
	var current: Dictionary = _story.get("_current")
	var expected_background_id := ImageRegistry.resolve_contextual_background_id(
		"cafe" if choice_index == 2 else "meeting")
	var expected_background_path := ImageRegistry.get_background(
		expected_background_id)
	var background := _story.get("_bg_img") as TextureRect
	var actual_background_path := (
		background.texture.resource_path
		if is_instance_valid(background) and background.texture != null else "")
	var expected_portrait_id := (
		"daeun_normal" if choice_index == 2 else "sangchul_serious")
	var expected_portrait_path := ImageRegistry.get_portrait_for_turn(
		expected_portrait_id, GameState.turn)
	var portrait := _story.get("_portrait") as TextureRect
	var portrait_frame := _story.get("_portrait_frame") as Control
	var actual_portrait_path := (
		portrait.texture.resource_path
		if is_instance_valid(portrait) and portrait.texture != null else "")
	var name_panel := _story.get("_name_panel") as Control
	var name_tag := _story.get("_name_tag") as Label
	var expected_name := (
		("Kim Daeun" if language == "en" else "김다은")
		if choice_index == 2 else
		("Im Sangchul" if language == "en" else "임상철"))
	_expect(str(current.get("id", "")) == "arc_y5_final_offer" \
			and str(current.get("background", "")) == "meeting" \
			and str(current.get("portrait", "")) == "sangchul_serious" \
			and bool(_story.get("_pending_after_result")) \
			and int(_story.get("_pending_result_choice_index")) == choice_index \
			and GameState.chapter5_causal_receipt_matches(
				"arc_y5_final_offer", choice_index) \
			and str(_story.get("_event_background_id")) == expected_background_id \
			and not expected_background_path.is_empty() \
			and actual_background_path == expected_background_path \
			and not expected_portrait_path.is_empty() \
			and actual_portrait_path == expected_portrait_path \
			and is_instance_valid(portrait_frame) and portrait_frame.visible \
			and is_instance_valid(name_panel) and name_panel.visible \
			and is_instance_valid(name_tag) and name_tag.text == expected_name \
			and (choice_index != 2 \
				or str(BGMPlayer.get("_current_ambience_key")) == "cafe"),
		"W207 %s presentation drifted: %s" % [stage, str({
			"background": _story.get("_event_background_id"),
			"background_path": actual_background_path,
			"portrait": actual_portrait_path,
			"name": name_tag.text if is_instance_valid(name_tag) else "",
			"ambience": BGMPlayer.get("_current_ambience_key"),
		})])


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

	# Read-only replay is historical evidence, not a generic live queue. Capture
	# one of the exact gallery roots with its earlier route fact, then invert the
	# current run and prove the frozen variant and choice do not mutate anything.
	GameState.start_new_game()
	GameState.player_name = "과거기록민준"
	GameState.turn = 200
	GameState.year = 5
	GameState.month = 2
	GameState.week_of_month = 4
	GameState.flags["arc_y3_jiyeon_departure_seen"] = true
	var replay_root := "arc_jiyeon_narrow_room_1"
	_clear_gallery_pair_fixture(replay_root)
	_expect(_seed_gallery_replay_pair(replay_root),
		"historical gallery fixture could not persist a valid pair")
	GameState.flags.erase("arc_y3_jiyeon_departure_seen")
	GameState.player_name = "현재런민준"
	GameState.turn = 1
	GameState.year = 1
	GameState.month = 1
	GameState.week_of_month = 1
	var replay_state_before: Dictionary = GameState.serialize().duplicate(true)
	var replay_meta_before: Dictionary = MetaProgression.data.duplicate(true)
	if not await _spawn_pending_story_queue(
			[replay_root], replay_root, true):
		return
	_expect(bool(_story.get("_read_only_replay")),
		"historical gallery scene did not remain in read-only replay")
	var replay_event: Dictionary = _story.get("_current")
	var replay_description := str(_story.call(
		"_resolved_story_description", replay_event))
	_expect("부산의 넓은 집을 두고" in replay_description \
			and not "현재런민준의 좁은 방문" in replay_description,
		"historical gallery scene read the inverted live route/name")
	_show_current_story_choices()
	_story.call("_on_choice", 1)
	_story.call("_finish_story_scene_transition")
	_expect(bool(_story.get("_pending_after_result")) \
			and not _current_story_text().is_empty(),
		"read-only gallery choice did not enter its authored result")
	_expect(GameState.serialize() == replay_state_before \
			and MetaProgression.data == replay_meta_before,
		"read-only gallery replay mutated the current run or meta history")


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


func _seed_gallery_replay_pair(root_id: String) -> bool:
	var producer := STORY_MODE_SCRIPT.new()
	var selectors: Dictionary = {}
	var choices: Dictionary = {}
	for event_id in MetaProgression.gallery_replay_closure_ids(root_id):
		var event: Dictionary = DataRegistry.find_event(event_id)
		if event.is_empty():
			producer.free()
			return false
		selectors[event_id] = producer.call(
			"_live_gallery_selector_matches", event)
		choices[event_id] = producer.call(
			"_live_gallery_visible_choice_indices", event)
	producer.free()
	var snapshot := MetaProgression.build_scene_replay_snapshot(
		root_id, selectors, choices)
	return not snapshot.is_empty() \
		and MetaProgression.record_scene_replay_pair(root_id, snapshot)


func _clear_gallery_pair_fixture(root_id: String) -> void:
	var raw_seen: Variant = MetaProgression.data.get("seen_scenes", [])
	var seen: Array = (raw_seen as Array).duplicate() if raw_seen is Array else []
	while seen.has(root_id):
		seen.erase(root_id)
	MetaProgression.data["seen_scenes"] = seen
	var raw_snapshots: Variant = MetaProgression.data.get(
		"scene_replay_snapshots", {})
	var snapshots: Dictionary = (raw_snapshots as Dictionary).duplicate(true) \
		if raw_snapshots is Dictionary else {}
	snapshots.erase(root_id)
	MetaProgression.data["scene_replay_snapshots"] = snapshots

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
	for slot in [SaveManager.AUTOSAVE_SLOT, TEST_SLOT, LEGACY_SLOT, CONTRACT_SLOT]:
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
		if _full_story_date_checked:
			print("MANUAL_SAVE_FULL_STORY_DATE_CHECK_OK variants=15 locales=5 prose=v4-disk/new-Story/source/history-new/old-preserved language=actual-ko-en excluded=public/preview8/12/unmarked/corrupt/read-only/other-id/mismatch owner/economy/registry=unchanged prepared_W1=1 natural=0 new_OS_process=0")
		if not _full_story_date_exclusion.is_empty():
			print("MANUAL_SAVE_FULL_STORY_DATE_EXCLUSION_CHECK_OK profile=%s variants=15 rendered=unchanged synthetic_owner=1" % _full_story_date_exclusion)
		if _full_story_date_only:
			get_tree().quit(0)
			return
		if _full_story_production_checked:
			print("MANUAL_SAVE_FULL_STORY_PRODUCTION_CHECK_OK entry=actual-StartMenu roots=actual-Main/Story-W1-W28 hyunsu=normal-flags/prepared-study-pass/fail hire/first-work/paycheck=actual cold=W21/W25/W29/v4/new-main calendar=fault-W25/W29-once/rng activity=actual-choice/cancel/tip-cancel/round/cold/fault/AP0 dates=prepared-W49/W241 year=dynamic2 causal=prepared-W210-two-actual-roots terminal=typed/generic/cold tail=105+1/cap100-twice synthetic_not_m07=1 natural_240=0")
		if _full_story_production_only:
			get_tree().quit(0)
			return
		if _paycheck_window_checked:
			print("MANUAL_SAVE_PAYCHECK_WINDOW_CHECK_OK hire=authored-accept/refuse first-work=actual-selector/choice salary=one-production-month-end reader=W17-priority/W18/W25/cold-result resume=v4-disk/new-main unpaid/current-job/seen/v2-window=preserved synthetic_not_m07=1")
		if _paycheck_window_only:
			get_tree().quit(0)
			return
		if _full_story_third_month_checked:
			print("MANUAL_SAVE_FULL_STORY_THIRD_MONTH_CHECK_OK scope=internal-preview-W1-W12 roots=production-main prefix=W1-W8 hyunsu=two-choices/follow-up/result-close month3=cold/once save=fault-W10-W13/disk/pending/new-main/retry/rng profile=old8-not-promoted/unknown-rejected activity=pending-cold/new-main-twice/inert boundary=W13-no-AP-surface synthetic_not_m07=1")
		if _full_story_flow_checked:
			print("MANUAL_SAVE_FULL_STORY_FLOW_CHECK_OK scope=internal-preview-W1-W8 roots=production-main story=actual-choice/result-close/follow-up/card branches=clean/return/deeper economy=background-once/employed-reentry/subsidy-before-pressure/month2 resume=v4-result/disk/new-main new-main-int=tab/timer-only duplicate=turn/result/chain save=fault-pending/once-retry/rng boundary=W9-no-AP-surface synthetic_not_m07=1")
		if _full_story_flow_only:
			get_tree().quit(0)
			return
		if _monthly_economy_checked:
			print("MANUAL_SAVE_MONTHLY_ECONOMY_CHECK_OK production=news/prices/dividend/expense/margin reentry=signal+same-turn+rng resume=v4-disk/new-main/static calendar=next-month/year legacy=current/stale/type-boundary excluded=week2/v2 timer=0..11/integral-float/missing/corrupt/fresh/expiry/shock-cold synthetic_not_m07=1")
		if _monthly_economy_only:
			get_tree().quit(0)
			return
		print("MANUAL_SAVE_CHECK_OK slots=10 chapter5=causal-disk-json-exact-int/eligible-entry/durable-lock-ratchet+finale-disk-exact-int/tamper-closed/legacy-W220-open-W221-closed+w207-live-retained2/cafe-save-reload-ko-en durability=temp-readback/verified-backup/primary-preserved/retry/recovery/compatible-backup-preserved/wrong-type/missing-key manual_feedback=failure-stays/success-close month_situation_resume=consumed-disk/main-entry/state-inert+missing/stale/next-week-one-draw+same-turn-latch+first-week-inert identity=current/partial/unknown/full-demo/v2-isolated/completion-turn25-exact/cutoff future=reject-before-state prose=source_progress locale_mismatch=rewind choices=1 result_once=1 result_variant=sangchul-father-passed/result-once/current-serial-history/event-action-logs/nonresult-prose+choices-restart stale_queue=alive-original/death-canonical+legacy+cast/passed-variants/living-only-skip/769-iterative-skip/769-curation-iterative-skip/read-only-history father_passing=blocked5/event-manager+story-queue/terminal-result2/once/cross-splice2-reject/latest-receipt2-reject timer=1 pages=2 dialogue_history=prose/choice/result/legacy_notice first_bill=expression/decision/ledger+preclamp_H3_H99+fatal_short_circuit+frozen_replay+local_ledger+hyunsu+legacy_atomic+old_dirty_generic_inert+nonstory_root_only/no_synthetic_archive archive=opening1/decision0 meta=restored")
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
