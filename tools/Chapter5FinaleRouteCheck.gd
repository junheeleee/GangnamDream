extends Node
## ORDER-134: pure reducer/save/ending proof for the M56-M60 finale ledger.

const ROUTE := preload("res://systems/Chapter5FinaleRoute.gd")
const CAUSAL_ROUTE := preload("res://systems/Chapter5CausalRoute.gd")
const LEDGER_PATH := "res://content/meta/chapter5_finale_ledger.json"
const MAIN_GAME_PATH := "res://scenes/MainGame.gd"
const ACTIVE_TURNS: Array[int] = [221, 224, 227, 230, 235, 238, 239, 240, 240]
const ALIVE_EVENTS: Array[String] = [
	"arc_y5_father_trace_alive_exact",
	"arc_y5_father_trace_custody",
	"arc_y5_name_on_line_daeun_routed",
	"arc_y5_people_verdict_daeun_exact",
	"arc_y5_property_not_executed_notice",
	"arc_y5_remaining_jaehyuk_or_self",
	"arc_y5_final_father_answer_alive",
	"arc_final_countdown_property_not_executed",
	"arc_y5_final_week_daeun_outbound",
]
const PASSED_EVENTS: Array[String] = [
	"arc_y5_father_trace_passed_exact",
	"arc_y5_father_trace_custody",
	"arc_y5_name_on_line_daeun_routed",
	"arc_y5_people_verdict_daeun_exact",
	"arc_y5_property_not_executed_notice",
	"arc_y5_remaining_jaehyuk_or_self",
	"arc_y5_final_father_answer_passed",
	"arc_final_countdown_property_not_executed",
	"arc_y5_final_week_daeun_outbound",
]
const PATH_CHOICES: Array[int] = [2, 1, 3, 2, 0, 1, 1, 2, 0]
const GENERAL_LEDGER_PATH := "res://content/meta/chapter5_general_finale_ledger.json"
const GENERAL_TURNS: Array[int] = [237, 240, 240]
const GENERAL_EVENTS: Array[String] = [
	"arc_y5_general_final_record_seal",
	"arc_final_countdown_general_near_goal_passed",
	"arc_y5_final_week_general_people_outbound",
]
const GENERAL_CHOICES: Array[int] = [1, 2, 0]

var _failures: Array[String] = []


func _ready() -> void:
	_check_ledger_inventory_and_reads()
	_check_legacy_boundary_and_entry_lock()
	_check_alive_and_passed_paths()
	_check_write_once_order_and_variants()
	_check_disk_roundtrip_and_tamper()
	_check_ending_hold_ready_consume_close()
	_check_source_route_complete_api()
	_check_game_state_wrapper_save_and_single_release()
	_check_general_ledger_and_reducer_contract()
	_check_general_game_state_contract()
	if _failures.is_empty():
		print(
			"CHAPTER5_FINALE_ROUTE_CHECK_OK roots=11 active=9 "
			+ "choices=30 active_choices=24 variants=father-life "
			+ "entry=source-choices/father/actors-exact "
			+ "receipts=stage-write-once economic=no-executable-zero "
			+ "save=int-roundtrip legacy=turn220-fresh/221-closed "
			+ "ending=pending-ready-consumed-exactly-once "
			+ "wrapper=game-state-json-release canonical-check=once "
			+ "general=roots3/choices8-w237-w240-outbound-save-release "
			+ "general-gate=tuple-exact/source-tamper/locked-durable")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("CHAPTER5_FINALE_ROUTE_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)


func _check_ledger_inventory_and_reads() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LEDGER_PATH))
	_expect(parsed is Dictionary, "finale ledger is not a JSON object")
	if not parsed is Dictionary:
		return
	var ledger: Dictionary = parsed
	_expect(int(ledger.get("schema_version", -1)) == 1,
		"finale ledger schema drifted")
	_expect(str(ledger.get("ledger_id", "")) == ROUTE.LEDGER_ID,
		"finale ledger id drifted")
	_expect(int(ledger.get("expected_root_count", -1)) == 11 \
		and int(ledger.get("expected_active_root_count", -1)) == 9,
		"finale root inventory declarations drifted")
	_expect(int(ledger.get("expected_choice_count", -1)) == 30 \
		and int(ledger.get("expected_active_choice_count", -1)) == 24,
		"finale choice inventory declarations drifted")
	_expect(_same(ledger.get("stages", []), ROUTE.STAGES),
		"finale stage order drifted")
	var roots: Array = ledger.get("roots", [])
	_expect(roots.size() == 11, "finale ledger does not contain exact 11 variants")
	var choices := 0
	var events: Array[String] = []
	var receipt_ids: Dictionary = {}
	for raw_root in roots:
		_expect(raw_root is Dictionary, "finale root is not an object")
		if not raw_root is Dictionary:
			continue
		var root: Dictionary = raw_root
		var event_id := str(root.get("event_id", ""))
		events.append(event_id)
		var authored_choices: Array = root.get("choices", [])
		choices += authored_choices.size()
		_expect(authored_choices.size() == int(root.get("choice_count", -1)),
			"%s declared choice count drifted" % event_id)
		_expect(_same(ROUTE.expected_read_contract(event_id), {
			"sources": (root.get("read_sources", []) as Array).duplicate(true),
			"mode": str(root.get("read_mode", "")),
		}), "%s read contract is not ledger-exact" % event_id)
		for choice_index in range(authored_choices.size()):
			var choice: Dictionary = authored_choices[choice_index]
			_expect(int(choice.get("index", -1)) == choice_index,
				"%s choice index order drifted" % event_id)
			for raw_receipt_id in choice.get("receipt_ids", []) as Array:
				var receipt_id := str(raw_receipt_id)
				_expect(not receipt_ids.has(receipt_id),
					"duplicate finale receipt id %s" % receipt_id)
				receipt_ids[receipt_id] = true
	_expect(choices == 30, "finale ledger choice total is not exact 30")
	_expect(_same(events, ROUTE.OWNED_EVENT_IDS),
		"reducer event ownership drifted from ledger order")
	_expect(ROUTE.expected_read_contract("ordinary_event").is_empty(),
		"unowned event acquired a finale read contract")


func _check_legacy_boundary_and_entry_lock() -> void:
	var fresh := ROUTE.state_from_save(null, false, 220)
	var late := ROUTE.state_from_save(null, false, 221)
	_expect(_same(fresh, ROUTE.default_state()),
		"missing pre-entry save did not remain freshly eligible")
	_expect(str(late.get("status", "")) == "closed" \
		and str(late.get("closed_reason", "")) == "legacy_missing" \
		and str(late.get("ending_check", "")) == "consumed",
		"missing post-entry save did not fail closed")
	var invalid_raw := ROUTE.state_from_save([], true, 220)
	_expect(str(invalid_raw.get("status", "")) == "closed" \
		and str(invalid_raw.get("closed_reason", "")) == "state_schema",
		"non-object finale save did not fail closed")

	var empty := ROUTE.default_state()
	var wrong_turn := ROUTE.lock_entry(
		empty, 220, ROUTE.ROUTE_ID, ROUTE.PROFILE_ID,
		_source_choices(), _father("alive", "called"), _actors())
	_expect(not bool(wrong_turn.get("ok", false)) \
		and _same(wrong_turn.get("state", {}), empty),
		"wrong entry turn mutated finale state")
	var wrong_route := ROUTE.lock_entry(
		empty, 221, "ordinary", ROUTE.PROFILE_ID,
		_source_choices(), _father("alive", "called"), _actors())
	_expect(not bool(wrong_route.get("ok", false)) \
		and _same(wrong_route.get("state", {}), empty),
		"wrong source profile entered safe finale")
	var malformed_choices := _source_choices()
	malformed_choices["m55_decision"] = 3
	var bad_source := ROUTE.lock_entry(
		empty, 221, ROUTE.ROUTE_ID, ROUTE.PROFILE_ID,
		malformed_choices, _father("alive", "called"), _actors())
	_expect(not bool(bad_source.get("ok", false)),
		"out-of-range source choice entered finale")
	var extra_actor := _actors()
	extra_actor["invented_partner"] = "jiyeon"
	var bad_actor := ROUTE.lock_entry(
		empty, 221, ROUTE.ROUTE_ID, ROUTE.PROFILE_ID,
		_source_choices(), _father("alive", "called"), extra_actor)
	_expect(not bool(bad_actor.get("ok", false)),
		"invented actor entered finale binding")

	var locked_result := _lock("alive", "called")
	var locked: Dictionary = locked_result.get("state", {})
	_expect(bool(locked_result.get("ok", false)) \
		and not bool(locked_result.get("idempotent", true)) \
		and ROUTE.entry_locked(locked) \
		and ROUTE.holds_ending(locked),
		"eligible W221 context did not lock/hold finale")
	var entry := ROUTE.entry_snapshot(locked)
	_expect(str(entry.get("route_id", "")) == ROUTE.ROUTE_ID \
		and int(entry.get("turn", -1)) == 221 \
		and str(entry.get("profile_id", "")) == ROUTE.PROFILE_ID \
		and str(entry.get("source_route_id", "")) == ROUTE.SOURCE_ROUTE_ID \
		and _same(entry.get("source_choices", {}), _source_choices()) \
		and _same(entry.get("father", {}), _father("alive", "called")) \
		and _same(entry.get("actor_bindings", {}), _actors()),
		"durable finale entry snapshot drifted")
	entry["route_id"] = "tampered_copy"
	_expect(str(ROUTE.entry_snapshot(locked).get("route_id", "")) \
		== ROUTE.ROUTE_ID, "entry snapshot leaked mutable state")
	var replay := ROUTE.lock_entry(
		locked, 240, ROUTE.ROUTE_ID, ROUTE.PROFILE_ID,
		_source_choices(), _father("alive", "called"), _actors())
	_expect(bool(replay.get("ok", false)) \
		and bool(replay.get("idempotent", false)) \
		and _same(replay.get("state", {}), locked),
		"identical durable entry did not replay idempotently")
	var conflicting := ROUTE.lock_entry(
		locked, 221, ROUTE.ROUTE_ID, ROUTE.PROFILE_ID,
		_source_choices(), _father("passed", "called"), _actors())
	_expect(not bool(conflicting.get("ok", false)) \
		and str(conflicting.get("error", "")) == "entry_conflict" \
		and _same(conflicting.get("state", {}), locked),
		"later father state rebound the durable finale cast/facts")


func _check_alive_and_passed_paths() -> void:
	for life in ["alive", "passed"]:
		var events := ALIVE_EVENTS if life == "alive" else PASSED_EVENTS
		var state := (_lock(life, "records_only").get("state", {}) as Dictionary)
		for index in range(events.size()):
			var event_id: String = events[index]
			var turn := ACTIVE_TURNS[index]
			_expect(ROUTE.next_event_for_turn(state, turn) == event_id,
				"%s path lost exact event %s at W%d" % [life, event_id, turn])
			_expect(ROUTE.ingress_available(state, event_id, turn),
				"%s did not expose exact ingress" % event_id)
			_expect(ROUTE.choice_count_for_stage(
				state, ROUTE.STAGES[index]) > PATH_CHOICES[index],
				"%s stage choice inventory is too small" % ROUTE.STAGES[index])
			var result := ROUTE.commit_choice(
				state, event_id, PATH_CHOICES[index], turn)
			_expect(bool(result.get("ok", false)),
				"%s path could not commit %s" % [life, event_id])
			state = (result.get("state", state) as Dictionary).duplicate(true)
			_expect(ROUTE.receipt_matches(
				state, event_id, PATH_CHOICES[index], turn),
				"%s did not write its exact receipt" % event_id)
			_expect(ROUTE.selected_choice_for_stage(
				state, ROUTE.STAGES[index]) == PATH_CHOICES[index],
				"%s selected stage choice drifted" % event_id)
			if index == 0:
				_expect(ROUTE.week_completed(state, 221),
					"W221 did not complete after its active father variant")
			if index == 7:
				_expect(not ROUTE.week_completed(state, 240) \
					and not ROUTE.ending_ready(state),
					"signature alone completed the W240 outbound/ending")
		_expect(ROUTE.week_completed(state, 240) \
			and ROUTE.route_complete(state) and ROUTE.ending_ready(state),
			"%s path did not finish both W240 stages" % life)
		var nontransaction := ROUTE.receipt_snapshot_for_stage(
			state, "nontransaction")
		_expect(_same(nontransaction.get("economic_outcome", {}),
			ROUTE.NO_EXECUTABLE_CONTRACT_OUTCOME),
			"%s path invented an M59 transaction" % life)
		_expect((state.get("order", []) as Array).size() == 9,
			"%s path did not write exact nine active roots" % life)


func _check_write_once_order_and_variants() -> void:
	var state := (_lock("alive", "present").get("state", {}) as Dictionary)
	var before := state.duplicate(true)
	var out_of_order := ROUTE.commit_choice(
		state, ALIVE_EVENTS[1], 0, ACTIVE_TURNS[1])
	_expect(not bool(out_of_order.get("ok", false)) \
		and str(out_of_order.get("error", "")) == "root_order" \
		and _same(out_of_order.get("state", {}), before),
		"out-of-order finale callback mutated state")
	var wrong_variant := ROUTE.commit_choice(
		state, PASSED_EVENTS[0], 0, ACTIVE_TURNS[0])
	_expect(not bool(wrong_variant.get("ok", false)) \
		and str(wrong_variant.get("error", "")) == "root_variant_inactive" \
		and _same(wrong_variant.get("state", {}), before),
		"inactive father variant committed")
	var bad_index := ROUTE.commit_choice(
		state, ALIVE_EVENTS[0], 3, ACTIVE_TURNS[0])
	_expect(not bool(bad_index.get("ok", false)) \
		and str(bad_index.get("error", "")) == "choice_invalid" \
		and _same(bad_index.get("state", {}), before),
		"invalid finale choice mutated state")
	var first := ROUTE.commit_choice(state, ALIVE_EVENTS[0], 1, 221)
	state = (first.get("state", state) as Dictionary).duplicate(true)
	var replay := ROUTE.commit_choice(state, ALIVE_EVENTS[0], 1, 221)
	_expect(bool(replay.get("ok", false)) \
		and bool(replay.get("idempotent", false)) \
		and _same(replay.get("state", {}), state),
		"same finale callback was not idempotent")
	var conflict := ROUTE.commit_choice(state, ALIVE_EVENTS[0], 2, 221)
	_expect(not bool(conflict.get("ok", false)) \
		and str(conflict.get("error", "")) == "callback_conflict" \
		and _same(conflict.get("state", {}), state),
		"conflicting finale replay overwrote write-once receipt")
	_expect(ROUTE.receipt_snapshot_for_stage(state, "father_trace") \
		== ROUTE.receipt_snapshot_for_event(state, ALIVE_EVENTS[0]),
		"stage/event receipt queries disagree")


func _check_disk_roundtrip_and_tamper() -> void:
	var state := _state_through("alive", 5)
	var disk_value: Variant = JSON.parse_string(JSON.stringify(state))
	var restored := ROUTE.state_from_save(disk_value, true, 230)
	_expect(_same(restored, state),
		"JSON disk roundtrip did not restore exact finale state")
	_expect(typeof(restored.get("schema_version")) == TYPE_INT \
		and typeof((restored.get("entry", {}) as Dictionary)
			.get("source_choices", {}).get("m55_decision")) == TYPE_INT,
		"save boundary did not normalize declared finale integers")
	var receipt := ROUTE.receipt_snapshot_for_stage(restored, "nontransaction")
	for key in ["cash_delta_krw", "asset_delta_krw", "debt_delta_krw"]:
		_expect(typeof((receipt.get("economic_outcome", {}) as Dictionary)
			.get(key)) == TYPE_INT,
			"save boundary did not normalize %s" % key)

	var extra := state.duplicate(true)
	extra["invented"] = true
	_expect(str(ROUTE.state_from_save(extra, true, 230).get(
		"status", "")) == "closed", "extra top-level key survived save load")
	var entry_tamper := state.duplicate(true)
	(entry_tamper["entry"] as Dictionary)["source_route_id"] = "ordinary"
	var closed_entry := ROUTE.state_from_save(entry_tamper, true, 230)
	_expect(str(closed_entry.get("status", "")) == "closed" \
		and str(closed_entry.get("closed_reason", "")) == "entry_tampered",
		"tampered source route did not fail closed")
	var receipt_tamper := state.duplicate(true)
	var event_id := str((receipt_tamper["order"] as Array)[0])
	((receipt_tamper["receipts"] as Dictionary)[event_id] \
		as Dictionary)["choice_index"] = 0
	var closed_receipt := ROUTE.state_from_save(receipt_tamper, true, 230)
	_expect(str(closed_receipt.get("status", "")) == "closed" \
		and str(closed_receipt.get("closed_reason", "")) == "receipt_tampered",
		"tampered finale choice receipt did not fail closed")
	var ending_tamper := state.duplicate(true)
	ending_tamper["ending_check"] = "ready"
	var closed_ending := ROUTE.state_from_save(ending_tamper, true, 230)
	_expect(str(closed_ending.get("status", "")) == "closed" \
		and str(closed_ending.get("closed_reason", "")) \
		== "ending_check_tampered",
		"early ready ending marker did not fail closed")


func _check_ending_hold_ready_consume_close() -> void:
	var partial := _state_through("alive", 8)
	_expect(ROUTE.holds_ending(partial) and not ROUTE.ending_ready(partial),
		"locked W240 signature state did not hold ending pending outbound")
	var premature := ROUTE.consume_ending_check(partial)
	_expect(not bool(premature.get("ok", false)) \
		and str(premature.get("error", "")) == "ending_not_ready" \
		and _same(premature.get("state", {}), partial),
		"pending finale consumed ending early")
	var ready := _state_through("alive", 9)
	_expect(ROUTE.holds_ending(ready) and ROUTE.ending_ready(ready),
		"outbound did not move ending pending to ready")
	var consumed_result := ROUTE.consume_ending_check(ready)
	var consumed: Dictionary = consumed_result.get("state", {})
	_expect(bool(consumed_result.get("ok", false)) \
		and not bool(consumed_result.get("idempotent", true)) \
		and str(consumed.get("ending_check", "")) == "consumed" \
		and not ROUTE.holds_ending(consumed) \
		and not ROUTE.ending_ready(consumed) \
		and ROUTE.next_event_for_turn(consumed, 240).is_empty(),
		"ready finale did not consume ending exactly once")
	var replay := ROUTE.consume_ending_check(consumed)
	_expect(bool(replay.get("ok", false)) \
		and bool(replay.get("idempotent", false)) \
		and _same(replay.get("state", {}), consumed),
		"consumed ending check did not replay idempotently")

	var close_result := ROUTE.close_route(partial, "read_surface_invalid")
	var closed: Dictionary = close_result.get("state", {})
	_expect(bool(close_result.get("ok", false)) \
		and str(closed.get("status", "")) == "closed" \
		and str(closed.get("closed_reason", "")) == "read_surface_invalid" \
		and (closed.get("entry", {}) as Dictionary).is_empty() \
		and (closed.get("receipts", {}) as Dictionary).is_empty() \
		and (closed.get("order", []) as Array).is_empty() \
		and not ROUTE.holds_ending(closed),
		"read-surface close did not erase partial invented evidence")
	var close_replay := ROUTE.close_route(closed, "read_surface_invalid")
	_expect(bool(close_replay.get("ok", false)) \
		and bool(close_replay.get("idempotent", false)),
		"same finale close was not idempotent")
	var invalid_close := ROUTE.close_route(partial, "skip_to_ending")
	_expect(not bool(invalid_close.get("ok", false)) \
		and _same(invalid_close.get("state", {}), partial),
		"unknown close reason bypassed finale")


func _check_source_route_complete_api() -> void:
	var locked_state := CAUSAL_ROUTE.lock_entry(
		CAUSAL_ROUTE.default_state(), 195, "투자형", true, true,
		2_000_000_000.0).get("state", {}) as Dictionary
	var state := locked_state.duplicate(true)
	_expect(not CAUSAL_ROUTE.route_complete(state),
		"freshly locked M49 source route reported complete")
	state = _complete_source_route_state()
	_expect((state.get("order", []) as Array).size() == 18,
		"source choice-0 path did not write exact 18 roots")
	_expect(CAUSAL_ROUTE.route_complete(state),
		"terminal M49-M55 source route did not report complete")
	var tampered := state.duplicate(true)
	(tampered["order"] as Array).pop_back()
	_expect(not CAUSAL_ROUTE.route_complete(tampered),
		"tampered source route reported complete")


func _check_game_state_wrapper_save_and_single_release() -> void:
	GameState.start_new_game()
	GameState.chapter5_causal_state = _complete_source_route_state()
	GameState.turn = 221
	_expect(GameState.prepare_chapter5_finale_route_entry() \
		and GameState.chapter5_finale_holds_ending() \
		and GameState.chapter5_finale_next_event_for_turn() == ALIVE_EVENTS[0],
		"GameState wrapper could not bind completed source route at W221")
	for index in range(ALIVE_EVENTS.size()):
		GameState.turn = ACTIVE_TURNS[index]
		_expect(GameState.chapter5_finale_choice_available(
			ALIVE_EVENTS[index], PATH_CHOICES[index]),
			"GameState preflight rejected %s" % ALIVE_EVENTS[index])
		var result := GameState.record_chapter5_finale_choice(
			ALIVE_EVENTS[index], PATH_CHOICES[index])
		_expect(bool(result.get("ok", false)),
			"GameState wrapper could not commit %s" % ALIVE_EVENTS[index])
	_expect(GameState.chapter5_finale_ending_ready() \
		and GameState.chapter5_finale_week_completed(240),
		"GameState wrapper did not expose ready after outbound")

	var serialized: Dictionary = GameState.serialize()
	var disk_value: Variant = JSON.parse_string(JSON.stringify(serialized))
	_expect(disk_value is Dictionary,
		"GameState finale fixture did not serialize to a JSON object")
	if disk_value is Dictionary:
		GameState.start_new_game()
		GameState.load_from_dict(disk_value)
	_expect(GameState.turn == 240 \
		and GameState.chapter5_finale_ending_ready() \
		and GameState.chapter5_finale_holds_ending(),
		"GameState JSON save/load lost ready finale latch")
	var first := GameState.consume_chapter5_finale_ending()
	var consumed_snapshot := GameState.chapter5_finale_state.duplicate(true)
	var second := GameState.consume_chapter5_finale_ending()
	_expect(bool(first.get("ok", false)) \
		and not bool(first.get("idempotent", true)) \
		and GameState.chapter5_finale_ending_consumed() \
		and not GameState.chapter5_finale_holds_ending() \
		and bool(second.get("ok", false)) \
		and bool(second.get("idempotent", false)) \
		and _same(GameState.chapter5_finale_state, consumed_snapshot),
		"GameState ending wrapper did not consume ready latch exactly once")

	var main_source := FileAccess.get_file_as_string(MAIN_GAME_PATH)
	var start := main_source.find(
		"func _complete_chapter5_finale_week_after_story()")
	var finish := main_source.find("\nfunc ", start + 1) if start >= 0 else -1
	var block := main_source.substr(start, finish - start) \
		if start >= 0 and finish > start else ""
	var public_consume_count := block.count(
		"GameState.consume_chapter5_finale_ending()")
	var alias_consume_count := block.count(
		"GameState.consume_chapter5_finale_ending_check()")
	var canonical_check_count := block.count(
		"_check_game_over_with_monotonic_story_state()")
	var consume_position := block.find("consume_chapter5_finale_ending")
	var canonical_position := block.find(
		"_check_game_over_with_monotonic_story_state()")
	_expect(not block.is_empty() \
		and public_consume_count + alias_consume_count == 1 \
		and canonical_check_count == 1 \
		and consume_position >= 0 and canonical_position > consume_position,
		"MainGame W240 release is not consume-first then one canonical check")


func _check_general_ledger_and_reducer_contract() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(GENERAL_LEDGER_PATH))
	_expect(parsed is Dictionary, "general finale ledger is not a JSON object")
	if not parsed is Dictionary:
		return
	var ledger: Dictionary = parsed
	_expect(int(ledger.get("schema_version", -1)) == 1 \
		and str(ledger.get("ledger_id", "")) == ROUTE.GENERAL_LEDGER_ID \
		and int(ledger.get("expected_root_count", -1)) == 3 \
		and int(ledger.get("expected_active_root_count", -1)) == 3 \
		and int(ledger.get("expected_choice_count", -1)) == 8 \
		and int(ledger.get("expected_active_choice_count", -1)) == 8 \
		and _same(ledger.get("stages", []), ROUTE.GENERAL_STAGES),
		"general finale ledger inventory drifted")
	var roots: Array = ledger.get("roots", [])
	var events: Array[String] = []
	var total_choices := 0
	for raw_root in roots:
		if not raw_root is Dictionary:
			_expect(false, "general finale root is not an object")
			continue
		var root: Dictionary = raw_root
		var event_id := str(root.get("event_id", ""))
		events.append(event_id)
		total_choices += (root.get("choices", []) as Array).size()
		_expect(_same(ROUTE.expected_read_contract(event_id), {
			"sources": (root.get("read_sources", []) as Array).duplicate(true),
			"mode": str(root.get("read_mode", "")),
		}), "%s general read contract drifted" % event_id)
	_expect(roots.size() == 3 and total_choices == 8 \
		and _same(events, ROUTE.GENERAL_OWNED_EVENT_IDS) \
		and _same(ROUTE.GENERAL_ACTORS, {
			"chooser": "player", "father": "father", "cost_witness": "minseo"}),
		"general finale roots/actors are not exact")

	var empty := ROUTE.default_state()
	for invalid in [
		ROUTE.lock_entry(empty, 236, ROUTE.ROUTE_ID, ROUTE.GENERAL_PROFILE_ID,
			_general_source_choices(), _father("passed", "records_only"), ROUTE.GENERAL_ACTORS),
		ROUTE.lock_entry(empty, 237, ROUTE.ROUTE_ID, ROUTE.PROFILE_ID,
			_general_source_choices(), _father("passed", "records_only"), ROUTE.GENERAL_ACTORS),
		ROUTE.lock_entry(empty, 237, ROUTE.ROUTE_ID, ROUTE.GENERAL_PROFILE_ID,
			_general_source_choices(), _father("alive", "records_only"), ROUTE.GENERAL_ACTORS),
	]:
		_expect(not bool((invalid as Dictionary).get("ok", false)) \
			and _same((invalid as Dictionary).get("state", {}), empty),
			"invalid general entry mutated reducer state")
	var malformed := _general_source_choices()
	malformed["m59_summit"] = 2
	_expect(not bool(ROUTE.lock_entry(empty, 237, ROUTE.ROUTE_ID,
		ROUTE.GENERAL_PROFILE_ID, malformed, _father("passed", "records_only"),
		ROUTE.GENERAL_ACTORS).get("ok", false)),
		"out-of-range general source entered finale")
	var extra_actors: Dictionary = ROUTE.GENERAL_ACTORS.duplicate(true)
	extra_actors["partner"] = "daeun"
	_expect(not bool(ROUTE.lock_entry(empty, 237, ROUTE.ROUTE_ID,
		ROUTE.GENERAL_PROFILE_ID, _general_source_choices(),
		_father("passed", "records_only"), extra_actors).get("ok", false)),
		"extra general actor entered finale")

	var state := _general_state_through(0)
	var entry := ROUTE.entry_snapshot(state)
	_expect(ROUTE.entry_locked(state) and ROUTE.holds_ending(state) \
		and str(state.get("ledger_id", "")) == ROUTE.GENERAL_LEDGER_ID \
		and _same(entry, {
			"route_id": ROUTE.ROUTE_ID, "turn": 237,
			"profile_id": ROUTE.GENERAL_PROFILE_ID,
			"source_route_id": ROUTE.GENERAL_SOURCE_ROUTE_ID,
			"source_choices": _general_source_choices(),
			"father": _father("passed", "records_only"),
			"actor_bindings": ROUTE.GENERAL_ACTORS,
		}), "general W237 durable entry snapshot drifted")
	var wrong_order := ROUTE.commit_choice(state, GENERAL_EVENTS[1], 0, 240)
	var collision := ROUTE.commit_choice(state, ALIVE_EVENTS[0], 0, 237)
	var bad_index := ROUTE.commit_choice(state, GENERAL_EVENTS[0], 2, 237)
	_expect(not bool(wrong_order.get("ok", false)) and _same(wrong_order.get("state", {}), state) \
		and not bool(collision.get("ok", false)) and _same(collision.get("state", {}), state) \
		and not bool(bad_index.get("ok", false)) and _same(bad_index.get("state", {}), state),
		"general order/collision/index rejection mutated state")
	var first := ROUTE.commit_choice(state, GENERAL_EVENTS[0], GENERAL_CHOICES[0], 237)
	state = (first.get("state", state) as Dictionary).duplicate(true)
	var replay := ROUTE.commit_choice(state, GENERAL_EVENTS[0], GENERAL_CHOICES[0], 237)
	var conflict := ROUTE.commit_choice(state, GENERAL_EVENTS[0], 0, 237)
	_expect(bool(replay.get("ok", false)) and bool(replay.get("idempotent", false)) \
		and _same(replay.get("state", {}), state) \
		and not bool(conflict.get("ok", false)) and _same(conflict.get("state", {}), state),
		"general write-once callback contract regressed")
	var signature := ROUTE.commit_choice(state, GENERAL_EVENTS[1], GENERAL_CHOICES[1], 240)
	state = (signature.get("state", state) as Dictionary).duplicate(true)
	_expect(not ROUTE.week_completed(state, 240) and not ROUTE.ending_ready(state) \
		and ROUTE.next_event_for_turn(state, 240) == GENERAL_EVENTS[2],
		"general signature did not expose same-turn outbound while pending")
	var outbound := ROUTE.commit_choice(state, GENERAL_EVENTS[2], GENERAL_CHOICES[2], 240)
	state = (outbound.get("state", state) as Dictionary).duplicate(true)
	_expect(ROUTE.week_completed(state, 240) and ROUTE.route_complete(state) \
		and ROUTE.ending_ready(state), "general outbound did not make ending ready")
	var disk: Variant = JSON.parse_string(JSON.stringify(state))
	var restored := ROUTE.state_from_save(disk, true, 240)
	_expect(_same(restored, state) \
		and typeof(restored.get("schema_version")) == TYPE_INT \
		and typeof((ROUTE.entry_snapshot(restored).get("source_choices", {}) as Dictionary).get("m59_summit")) == TYPE_INT \
		and typeof(ROUTE.receipt_snapshot_for_stage(restored, "outbound").get("choice_index")) == TYPE_INT,
		"general JSON save boundary lost exact integer evidence")
	for tamper_kind in ["ledger", "source", "receipt"]:
		var tampered := state.duplicate(true)
		if tamper_kind == "ledger":
			tampered["ledger_id"] = ROUTE.LEDGER_ID
		elif tamper_kind == "source":
			((tampered["entry"] as Dictionary)["source_choices"] as Dictionary).erase(
				"m51_minseo_arrival")
		else:
			((tampered["receipts"] as Dictionary)[GENERAL_EVENTS[0]] as Dictionary)["choice_index"] = 0
		_expect(str(ROUTE.state_from_save(tampered, true, 240).get("status", "")) == "closed",
			"general %s tamper did not fail closed" % tamper_kind)
	var consumed_result := ROUTE.consume_ending_check(state)
	var consumed: Dictionary = consumed_result.get("state", {})
	var second := ROUTE.consume_ending_check(consumed)
	_expect(bool(consumed_result.get("ok", false)) and not bool(consumed_result.get("idempotent", true)) \
		and not ROUTE.holds_ending(consumed) \
		and bool(second.get("ok", false)) and bool(second.get("idempotent", false)),
		"general ready latch did not consume exactly once")


func _check_general_game_state_contract() -> void:
	_seed_general_sources()
	GameState.turn = 237
	_expect(GameState.prepare_chapter5_finale_route_entry() \
		and GameState.chapter5_finale_next_event_for_turn() == GENERAL_EVENTS[0],
		"GameState could not lock exact general W237 entry")
	var locked_state := GameState.chapter5_finale_state.duplicate(true)
	var original_flags := GameState.flags.duplicate(true)
	var original_cast := GameState.cast.duplicate(true)
	var original_player_route: Variant = GameState.player_route
	var original_tendency := GameState.tendency_realized
	GameState.player_route = "직장형"
	GameState.tendency_realized = "career"
	GameState.flags.erase("route_invest")
	GameState.flags["route_career"] = true
	GameState.flags["father_passed"] = false
	GameState.flags["arc_father_passing_seen"] = "false"
	GameState.flags["father_crisis_contact_present"] = "false"
	GameState.flags["chapter5_general_minseo_arrival_0"] = true
	GameState.cast["father"]["stage"] = "distant"
	_expect(GameState.prepare_chapter5_finale_route_entry() \
		and _same(GameState.chapter5_finale_state, locked_state) \
		and _same(GameState.chapter5_finale_entry_snapshot(),
			ROUTE.entry_snapshot(locked_state)),
		"locked general entry was re-evaluated after route/father/source drift")
	GameState.flags = original_flags
	GameState.cast = original_cast
	GameState.player_route = original_player_route
	GameState.tendency_realized = original_tendency
	for index in range(GENERAL_EVENTS.size()):
		GameState.turn = GENERAL_TURNS[index]
		var result := GameState.record_chapter5_finale_choice(
			GENERAL_EVENTS[index], GENERAL_CHOICES[index])
		_expect(bool(result.get("ok", false)),
			"GameState could not commit general %s" % GENERAL_EVENTS[index])
	_expect(GameState.chapter5_finale_ending_ready() \
		and GameState.chapter5_finale_week_completed(240),
		"GameState general outbound did not release ending")
	var disk: Variant = JSON.parse_string(JSON.stringify(GameState.serialize()))
	GameState.start_new_game()
	GameState.load_from_dict(disk)
	_expect(GameState.chapter5_finale_ending_ready() \
		and str(GameState.chapter5_finale_entry_snapshot().get("profile_id", "")) \
		== ROUTE.GENERAL_PROFILE_ID,
		"GameState general ready save did not roundtrip")
	var first := GameState.consume_chapter5_finale_ending()
	var second := GameState.consume_chapter5_finale_ending()
	_expect(bool(first.get("ok", false)) and not bool(first.get("idempotent", true)) \
		and bool(second.get("ok", false)) and bool(second.get("idempotent", false)),
		"GameState general ending did not consume exactly once")
	_seed_general_sources(false)
	GameState.turn = 237
	_expect(not GameState.prepare_chapter5_finale_route_entry() \
		and GameState.chapter5_finale_entry_snapshot().is_empty() \
		and not GameState.chapter5_finale_holds_ending(),
		"invalid general sources did not fall back without invented finale evidence")
	_check_general_game_state_exclusions()


func _check_general_game_state_exclusions() -> void:
	for route_case in [
		{"player_route": "직장형", "flag": "route_career"},
		{"player_route": "창업형", "flag": "route_startup"},
	]:
		_seed_general_sources()
		GameState.player_route = str(route_case["player_route"])
		GameState.tendency_realized = (
			"career" if str(route_case["flag"]) == "route_career" else "found")
		GameState.flags.erase("route_invest")
		GameState.flags[str(route_case["flag"])] = true
		GameState.turn = 237
		var before_w237 := GameState.chapter5_finale_state.duplicate(true)
		_expect(not GameState.prepare_chapter5_finale_route_entry() \
			and _same(GameState.chapter5_finale_state, before_w237) \
			and GameState.chapter5_finale_entry_snapshot().is_empty(),
			"%s profile entered the general W237 ledger" % route_case["flag"])

		_seed_general_sources()
		GameState.flags.erase("chapter5_general_last_page_instruction_0")
		GameState.flags.erase("chapter5_general_summit_1")
		GameState.event_log.resize(2)
		GameState.player_route = str(route_case["player_route"])
		GameState.tendency_realized = (
			"career" if str(route_case["flag"]) == "route_career" else "found")
		GameState.flags.erase("route_invest")
		GameState.flags[str(route_case["flag"])] = true
		GameState.turn = 229
		_expect(not GameState.chapter5_general_finale_w229_available(),
			"%s profile exposed the general W229 source" % route_case["flag"])

	_seed_general_sources()
	GameState.player_route = "none"
	GameState.tendency_realized = ""
	GameState.flags.erase("route_invest")
	GameState.turn = 237
	_expect(GameState.prepare_chapter5_finale_route_entry() \
		and str(GameState.chapter5_finale_entry_snapshot().get("profile_id", "")) \
			== ROUTE.GENERAL_PROFILE_ID,
		"coherent neutral route could not enter the general W237 ledger")

	_seed_general_sources()
	GameState.flags.erase("route_invest")
	GameState.turn = 237
	_expect(not GameState.prepare_chapter5_finale_route_entry(),
		"investment identity without route_invest entered the general ledger")

	_seed_general_sources()
	GameState.player_route = "none"
	GameState.turn = 237
	_expect(not GameState.prepare_chapter5_finale_route_entry(),
		"neutral identity with sticky route_invest entered the general ledger")

	_seed_general_sources()
	GameState.flags["route_career"] = true
	GameState.turn = 237
	_expect(not GameState.prepare_chapter5_finale_route_entry(),
		"hybrid investment/career identity entered the general ledger")

	_seed_general_sources()
	GameState.player_route = "none"
	GameState.tendency_realized = "invest"
	GameState.flags.erase("route_invest")
	GameState.turn = 237
	_expect(not GameState.prepare_chapter5_finale_route_entry(),
		"neutral route with mismatched realized tendency entered the general ledger")

	_seed_general_sources()
	GameState.flags["father_passed"] = "false"
	GameState.cast["father"]["stage"] = "distant"
	GameState.turn = 237
	var malformed_father_before := GameState.chapter5_finale_state.duplicate(true)
	_expect(not GameState.prepare_chapter5_finale_route_entry() \
		and _same(GameState.chapter5_finale_state, malformed_father_before),
		"non-bool father_passed fabricated the general W237 father state")

	_seed_general_sources()
	GameState.flags["chapter5_general_minseo_arrival_0"] = true
	GameState.turn = 237
	var multiple_source_before := GameState.chapter5_finale_state.duplicate(true)
	_expect(not GameState.prepare_chapter5_finale_route_entry() \
		and _same(GameState.chapter5_finale_state, multiple_source_before) \
		and GameState.chapter5_finale_entry_snapshot().is_empty(),
		"multiple true source flags did not reject W237 byte-identically")

	_seed_general_sources()
	GameState.flags["chapter5_general_minseo_arrival_1"] = "true"
	GameState.turn = 237
	var non_bool_source_before := GameState.chapter5_finale_state.duplicate(true)
	_expect(not GameState.prepare_chapter5_finale_route_entry() \
		and _same(GameState.chapter5_finale_state, non_bool_source_before) \
		and GameState.chapter5_finale_entry_snapshot().is_empty(),
		"non-bool source flag did not reject W237 byte-identically")

	_seed_general_sources()
	GameState.flags["route_career"] = "false"
	GameState.turn = 237
	_expect(not GameState.prepare_chapter5_finale_route_entry() \
		and GameState.chapter5_finale_entry_snapshot().is_empty(),
		"malformed career route flag entered the general W237 ledger")

	_seed_general_sources()
	GameState.flags["father_crisis_contact_present"] = "false"
	GameState.turn = 237
	_expect(GameState.prepare_chapter5_finale_route_entry() \
		and str(GameState.chapter5_finale_entry_snapshot().get(
			"father", {}).get("contact_mode", "")) == "records_only",
		"non-bool father contact receipt was coerced into a witnessed contact")


func _complete_source_route_state() -> Dictionary:
	var state := CAUSAL_ROUTE.default_state()
	var locked := CAUSAL_ROUTE.lock_entry(
		state, 195, "투자형", true, true, 2_000_000_000.0)
	state = (locked.get("state", state) as Dictionary).duplicate(true)
	var committed := 0
	for turn in range(195, 221):
		for same_turn_index in range(3):
			var event_id := CAUSAL_ROUTE.next_event_for_turn(state, turn)
			if event_id.is_empty():
				break
			var result := CAUSAL_ROUTE.commit_choice(state, event_id, 0, turn)
			_expect(bool(result.get("ok", false)),
				"source route could not commit %s" % event_id)
			if not bool(result.get("ok", false)):
				return state
			state = (result.get("state", state) as Dictionary).duplicate(true)
			committed += 1
			if same_turn_index == 2:
				_expect(false, "source route exposed more than three same-turn roots")
	_expect(committed == 18,
		"source choice-0 path wrote %d roots, expected 18" % committed)
	return state


func _lock(life: String, contact_mode: String) -> Dictionary:
	return ROUTE.lock_entry(
		ROUTE.default_state(), 221, ROUTE.ROUTE_ID, ROUTE.PROFILE_ID,
		_source_choices(), _father(life, contact_mode), _actors())


func _general_lock() -> Dictionary:
	return ROUTE.lock_entry(
		ROUTE.default_state(), 237, ROUTE.ROUTE_ID, ROUTE.GENERAL_PROFILE_ID,
		_general_source_choices(), _father("passed", "records_only"),
		ROUTE.GENERAL_ACTORS)


func _general_state_through(count: int) -> Dictionary:
	var state := (_general_lock().get("state", {}) as Dictionary).duplicate(true)
	for index in range(mini(count, GENERAL_EVENTS.size())):
		var result := ROUTE.commit_choice(
			state, GENERAL_EVENTS[index], GENERAL_CHOICES[index], GENERAL_TURNS[index])
		if not bool(result.get("ok", false)):
			_expect(false, "general fixture could not commit %s" % GENERAL_EVENTS[index])
			break
		state = (result.get("state", state) as Dictionary).duplicate(true)
	return state


func _general_source_choices() -> Dictionary:
	return {
		"m51_minseo_arrival": 1,
		"m56_father_legacy": 2,
		"w229_last_page_instruction": 0,
		"m59_summit": 1,
	}


func _seed_general_sources(valid: bool = true) -> void:
	GameState.start_new_game("김민준", "지방_상경", "투자형")
	GameState.flags["father_passed"] = true
	GameState.flags["chapter5_general_minseo_arrival_1"] = true
	GameState.flags["chapter5_general_father_legacy_2"] = true
	GameState.flags["chapter5_general_last_page_instruction_0"] = true
	GameState.flags["chapter5_general_summit_1"] = true
	GameState.event_log = [
		{"event_id": "arc_minseo_03_arrival", "choice_index": 1, "turn": 203},
		{"event_id": "arc_father_legacy", "choice_index": 2, "turn": 224},
		{"event_id": "arc_y5_general_last_page_instruction", "choice_index": 0, "turn": 229},
		{"event_id": "arc_pre_ending_summit", "choice_index": 1, "turn": 235},
	]
	if not valid:
		GameState.event_log.pop_back()


func _state_through(life: String, count: int) -> Dictionary:
	var events := ALIVE_EVENTS if life == "alive" else PASSED_EVENTS
	var state := (_lock(life, "records_only").get("state", {}) as Dictionary)
	for index in range(mini(count, events.size())):
		var result := ROUTE.commit_choice(
			state, events[index], PATH_CHOICES[index], ACTIVE_TURNS[index])
		if not bool(result.get("ok", false)):
			_expect(false, "fixture could not commit %s" % events[index])
			break
		state = (result.get("state", state) as Dictionary).duplicate(true)
	return state


func _source_choices() -> Dictionary:
	return {
		"m55_decision": 1,
		"w212_guarantee": 2,
		"w215_final_door": 0,
	}


func _father(life: String, contact_mode: String) -> Dictionary:
	return {"life": life, "contact_mode": contact_mode}


func _actors() -> Dictionary:
	return ROUTE.ACTORS.duplicate(true)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _same(left: Variant, right: Variant) -> bool:
	return JSON.stringify(left, "", true) == JSON.stringify(right, "", true)
