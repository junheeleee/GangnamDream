extends Node
## ORDER-134: pure reducer/save/ending proof for the M56-M60 finale ledger.

const ROUTE := preload("res://systems/Chapter5FinaleRoute.gd")
const CAUSAL_ROUTE := preload("res://systems/Chapter5CausalRoute.gd")
const STORY_MODE := preload("res://scenes/StoryMode.gd")
const W227_BALLPOINT_WRITE := preload("res://assets/w227_ballpoint_write.tres")
const W230_CAFE_WRITE := preload("res://assets/w230_cafe_write.tres")
const W230_CAFE := "arc_y5_people_verdict_daeun_exact"
const W235_NOTICE_RETURN := preload("res://assets/w235_notice_return.tres")
const W235_NOTICE := "arc_y5_property_not_executed_notice"
const W237_RECORD_PAGE_TURN := preload("res://assets/w237_record_page_turn.tres")
const W237_RECORD := "arc_y5_general_final_record_seal"
const W238_REMAINING := "arc_y5_remaining_jaehyuk_or_self"
const W239_FATHER_ALIVE := "arc_y5_final_father_answer_alive"
const W239_ALIVE_NAME_WRITE := preload("res://assets/w239_alive_name_write.tres")
const W239_FATHER_PASSED := "arc_y5_final_father_answer_passed"
const W239_PASSED_PAPER_ACTIONS := preload("res://assets/w239_passed_paper_actions.tres")
const W240_GENERAL_SACRIFICE := "arc_final_countdown_general_near_goal_passed"
const W240_GENERAL_SACRIFICE_WRITE := preload(
	"res://assets/w240_general_sacrifice_write.tres")
const W240_GENERAL_OUTBOUND := "arc_y5_final_week_general_people_outbound"
const W240_GENERAL_OUTBOUND_WRITE := preload(
	"res://assets/w240_general_outbound_write.tres")
const W240_FINAL_WEEK := "arc_final_week"
const W240_FINAL_WEEK_LIGHTS := preload(
	"res://assets/w240_final_week_lights.tres")
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
const GENERAL_TURNS: Array[int] = [224, 229, 234, 237, 240, 240]
const GENERAL_VOICE_EVENTS: Array[String] = [
	"arc_y5_general_father_legacy_voice_exact",
	"arc_y5_general_debt_memory_voice_exact",
	"arc_y5_general_pre_ending_summit_exact",
	"arc_y5_general_final_record_seal",
	"arc_final_countdown_general_near_goal_passed",
	"arc_y5_final_week_general_people_outbound",
]
const GENERAL_CAFE_EVENTS: Array[String] = [
	"arc_y5_general_father_legacy_cafe_exact",
	"arc_y5_general_debt_memory_cafe_exact",
	"arc_y5_general_pre_ending_summit_exact",
	"arc_y5_general_final_record_seal",
	"arc_final_countdown_general_near_goal_passed",
	"arc_y5_final_week_general_people_outbound",
]
const GENERAL_CHOICES: Array[int] = [1, 0, 1, 1, 1, 0]
const AUDIO_MIX_DRAIN_MARGIN_SECONDS := 0.02
const AUDIO_MIX_DRAIN_MAX_SECONDS := 0.25

var _failures: Array[String] = []
var _audio_mix_drain_timer: Timer


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
	_check_general_w211_source_contract()
	_check_general_w220_callbacks_to_v2_route()
	_check_father_trace_receipt_audio_alignment()
	_check_w227_ballpoint_audio_alignment()
	_check_w230_cafe_write_alignment()
	_check_w235_notice_return_alignment()
	_check_w237_final_record_alignment()
	_check_w238_remaining_silence_alignment()
	_check_w239_father_answer_alignment()
	_check_w239_passed_father_alignment()
	_check_w240_general_signature_alignment()
	_check_w240_general_outbound_alignment()
	_check_w240_final_week_lights_alignment()
	await _release_audio_for_exit()
	if _failures.is_empty():
		print(
			"CHAPTER5_FINALE_ROUTE_CHECK_OK roots=11 active=9 "
			+ "choices=30 active_choices=24 variants=father-life "
			+ "entry=source-choices/father/actors-exact "
			+ "receipts=stage-write-once economic=no-executable-zero "
			+ "save=int-roundtrip legacy=turn220-fresh/221-closed "
			+ "ending=pending-ready-consumed-exactly-once "
			+ "wrapper=game-state-json-release canonical-check=once "
			+ "general=source-w211-w220/branches2-w224-w229-w234/"
			+ "roots8-active6/choices17-active13-w237-w240-outbound-save-release "
			+ "general-gate=assets2.5b-exact/stale-generic/source-tamper/"
			+ "old-v1-closed/locked-durable "
			+ "terminal-axes=profiles2/cases4/once-json/no-extra-wear "
			+ "father-trace-audio=w221-contexts120/results360/"
			+ "w224-contexts30/results60/kept-result-cues8/"
			+ "w227-contexts60/results240/anchors10/manifest-result-cues1/"
			+ "w230-contexts80/results240/anchors25/manifest-description-cues1/"
			+ "w235-contexts120/results120/anchors5/manifest-cues0/"
			+ "w237-contexts80/results160/anchors5/manifest-description-cues2/"
			+ "w238-contexts30/results60/manifest-cues0/"
			+ "w239-contexts30/results90/anchors5/manifest-cues0/"
			+ "w239-passed-contexts30/results90/anchors10/manifest-cues0/"
			+ "w240-general-contexts10/results20/anchors10/manifest-cues0/"
			+ "w240-outbound-contexts40/results120/anchors5/manifest-cues0/"
			+ "w240-final-week-contexts15/results45/anchors10/manifest-cues0")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("CHAPTER5_FINALE_ROUTE_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)


func _release_audio_for_exit() -> void:
	for raw_tween in get_tree().get_processed_tweens():
		if raw_tween is Tween and (raw_tween as Tween).is_valid():
			(raw_tween as Tween).kill()
	BGMPlayer.stop()
	await AudioManager.drain_pending_timers_for_exit()
	await _await_physical_sfx_completion()
	_detach_audio_streams(get_tree().root)
	for raw_player in AudioManager._pool:
		if raw_player is AudioStreamPlayer:
			(raw_player as AudioStreamPlayer).stop()
			(raw_player as AudioStreamPlayer).stream = null
	AudioManager._sounds.clear()
	# Detach once more after all natural one-shots have crossed their real end,
	# then cross two measured audio-mix boundaries before quitting.
	BGMPlayer.stop()
	_detach_audio_streams(get_tree().root)
	for raw_player in AudioManager._pool:
		if raw_player is AudioStreamPlayer:
			(raw_player as AudioStreamPlayer).stop()
			(raw_player as AudioStreamPlayer).stream = null
	AudioManager._sounds.clear()
	await _drain_audio_server_after_stop()
	for _release_frame in range(4):
		await get_tree().process_frame


func _await_physical_sfx_completion() -> void:
	var active: Array[AudioStreamPlayer] = []
	var max_remaining_seconds := 0.0
	for raw_player in AudioManager._pool:
		if not raw_player is AudioStreamPlayer:
			continue
		var player := raw_player as AudioStreamPlayer
		if not player.playing or player.stream == null:
			continue
		active.append(player)
		max_remaining_seconds = maxf(max_remaining_seconds,
			maxf(0.0, player.stream.get_length() - player.get_playback_position()))
	if active.is_empty():
		return
	var mix_period_seconds := maxf(0.0,
		float(AudioServer.get_time_since_last_mix())) + maxf(0.0,
		float(AudioServer.get_time_to_next_mix()))
	var deadline_msec := Time.get_ticks_msec() + ceili(1000.0 * (
		max_remaining_seconds + minf(AUDIO_MIX_DRAIN_MAX_SECONDS,
			2.0 * mix_period_seconds + AUDIO_MIX_DRAIN_MARGIN_SECONDS)))
	while Time.get_ticks_msec() <= deadline_msec:
		var still_playing := false
		for player: AudioStreamPlayer in active:
			if is_instance_valid(player) and player.playing:
				still_playing = true
				break
		if not still_playing:
			return
		await get_tree().process_frame
	_failures.append("physical SFX did not finish within its stream-length boundary")


func _drain_audio_server_after_stop() -> void:
	if not is_instance_valid(_audio_mix_drain_timer):
		_audio_mix_drain_timer = Timer.new()
		_audio_mix_drain_timer.name = "AudioMixDrainTimer"
		_audio_mix_drain_timer.one_shot = true
		_audio_mix_drain_timer.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(_audio_mix_drain_timer)
	var time_since_last_mix := maxf(
		0.0, float(AudioServer.get_time_since_last_mix()))
	var time_to_next_mix := maxf(
		0.0, float(AudioServer.get_time_to_next_mix()))
	var mix_period_seconds := time_since_last_mix + time_to_next_mix
	var drain_seconds := clampf(
		time_to_next_mix + mix_period_seconds + AUDIO_MIX_DRAIN_MARGIN_SECONDS,
		AUDIO_MIX_DRAIN_MARGIN_SECONDS, AUDIO_MIX_DRAIN_MAX_SECONDS)
	_audio_mix_drain_timer.start(drain_seconds)
	await _audio_mix_drain_timer.timeout


func _detach_audio_streams(root: Node) -> void:
	if root is AudioStreamPlayer:
		(root as AudioStreamPlayer).stop()
		(root as AudioStreamPlayer).stream = null
	elif root is AudioStreamPlayer2D:
		(root as AudioStreamPlayer2D).stop()
		(root as AudioStreamPlayer2D).stream = null
	elif root is AudioStreamPlayer3D:
		(root as AudioStreamPlayer3D).stop()
		(root as AudioStreamPlayer3D).stream = null
	for child in root.get_children():
		_detach_audio_streams(child)


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
	var pending_save: Dictionary = {}
	for index in range(ALIVE_EVENTS.size()):
		GameState.turn = ACTIVE_TURNS[index]
		if index == ALIVE_EVENTS.size() - 1:
			pending_save = GameState.serialize().duplicate(true)
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
	_check_terminal_axis_release_matrix(
		GameState.serialize().duplicate(true), pending_save, "property")
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


func _check_terminal_axis_release_matrix(
		ready_save: Dictionary, pending_save: Dictionary, profile: String) -> void:
	# These are real wrapper-produced ready/pending states, not invented latches.
	for axes in [[2, 0], [0, 1], [2, 1], [0, 0]]:
		_load_terminal_axis_case(ready_save, int(axes[0]), int(axes[1]))
		var label := "%s terminal axes %s" % [profile, str(axes)]
		var before: Dictionary = GameState.serialize().duplicate(true)
		var assets_before: float = GameState.get_total_asset_value()
		var expected := before.duplicate(true)
		var money_used := int(axes[0]) > 0
		var human_used := int(axes[1]) > 0
		var bucket := "unmarked_weeks_total"
		if money_used and human_used:
			bucket = "both_axes_weeks_total"
		elif money_used:
			bucket = "money_only_weeks_total"
		elif human_used:
			bucket = "human_only_weeks_total"
		expected[bucket] = int(expected[bucket]) + 1
		expected["classified_weeks_total"] = 240
		if money_used:
			expected["money_weeks_total"] = int(expected["money_weeks_total"]) + 1
			expected["month_money_weeks"] = int(expected["month_money_weeks"]) + 1
		if human_used:
			expected["human_weeks_total"] = int(expected["human_weeks_total"]) + 1
			expected["month_human_weeks"] = int(expected["month_human_weeks"]) + 1
		var weeks: Array = expected["recent_action_weeks"]
		weeks.append({"turn": 240, "money": int(axes[0]), "human": int(axes[1]),
			"places": before["action_places_this_week"].duplicate(true),
			"actions": before["action_records_this_week"].duplicate(true)})
		while weeks.size() > 2:
			weeks.pop_front()
		expected["action_axis_this_week"] = {"money": 0, "human": 0}
		expected["action_places_this_week"] = {}
		expected["action_records_this_week"] = []
		expected["chapter5_finale_state"]["ending_check"] = "consumed"
		var first := GameState.consume_chapter5_finale_ending()
		var after: Dictionary = GameState.serialize().duplicate(true)
		_expect(bool(first.get("ok", false)) and not bool(first.get("idempotent", true)) \
			and GameState.chapter5_finale_ending_consumed() \
			and not GameState.chapter5_finale_holds_ending(),
			"%s did not consume its ready latch" % label)
		_expect(GameState.classified_weeks_total == 240 \
			and GameState.money_only_weeks_total + GameState.human_only_weeks_total \
				+ GameState.both_axes_weeks_total + GameState.unmarked_weeks_total == 240 \
			and GameState.get_total_asset_value() == assets_before \
			and _same(after, expected),
			"%s did not settle only the final week (wear/date/economy/AP/flags/receipts)" % label)
		var duplicate := GameState.consume_chapter5_finale_ending_check()
		_expect(bool(duplicate.get("ok", false)) and bool(duplicate.get("idempotent", false)) \
			and _same(GameState.serialize(), after),
			"%s duplicate alias consumption changed the whole state" % label)
		var disk: Variant = JSON.parse_string(JSON.stringify(after))
		GameState.start_new_game()
		GameState.load_from_dict(disk)
		var reloaded: Dictionary = GameState.serialize().duplicate(true)
		var again := GameState.consume_chapter5_finale_ending()
		_expect(GameState.classified_weeks_total == 240 \
			and bool(again.get("ok", false)) and bool(again.get("idempotent", false)) \
			and _same(GameState.serialize(), reloaded),
			"%s JSON-reloaded consumption settled the final week twice" % label)

	for closed in [false, true]:
		_load_terminal_axis_case(ready_save if closed else pending_save, 2, 1)
		if closed:
			var closure := GameState.close_chapter5_finale_route("source_route_invalid")
			_expect(bool(closure.get("ok", false)), "%s could not prepare closed negative" % profile)
		var before: Dictionary = GameState.serialize().duplicate(true)
		var rejected := GameState.consume_chapter5_finale_ending()
		_expect(not bool(rejected.get("ok", false)) \
			and _same(GameState.serialize(), before),
			"%s %s consumption changed pending axes or other state" \
				% [profile, "closed" if closed else "not-ready"])

	# The ordinary calendar path must retain its default weekly wear.
	_load_terminal_axis_case(ready_save, 2, 0)
	GameState.turn = 238
	GameState.week_of_month = 3
	var control: Dictionary = GameState.serialize().duplicate(true)
	var month_ended := GameState.advance_calendar()
	_expect(not month_ended and GameState.turn == 239 and GameState.week_of_month == 4 \
		and GameState.grind_streak_weeks == 4 \
		and GameState.mental == int(control["mental"]) - 1 \
		and is_equal_approx(GameState.moral_tint, float(control["moral_tint"]) - 1.0) \
		and is_equal_approx(GameState.loop_tint_spent, float(control["loop_tint_spent"]) - 1.0) \
		and GameState.action_log.size() == (control["action_log"] as Array).size() + 1 \
		and _same(GameState.chapter5_finale_state, control["chapter5_finale_state"]),
		"%s ordinary advance_calendar lost default money-only weekly wear" % profile)
	GameState.start_new_game()
	GameState.load_from_dict(ready_save)


func _load_terminal_axis_case(saved: Dictionary, money_actions: int, human_actions: int) -> void:
	GameState.start_new_game()
	GameState.load_from_dict(JSON.parse_string(JSON.stringify(saved)))
	GameState.turn = 240
	GameState.year = 2030
	GameState.month = 12
	GameState.week_of_month = 4
	GameState.mental = 60
	GameState.moral_tint = -30.0
	GameState.moral_band_last = -1
	GameState.loop_tint_spent = -3.0
	GameState.grind_streak_weeks = 3
	GameState.action_points = 1
	GameState.active_thought = {}
	GameState.money_only_weeks_total = 100
	GameState.human_only_weeks_total = 50
	GameState.both_axes_weeks_total = 60
	GameState.unmarked_weeks_total = 29
	GameState.classified_weeks_total = 239
	GameState.money_weeks_total = 160
	GameState.human_weeks_total = 110
	GameState.month_money_weeks = 2
	GameState.month_human_weeks = 1
	GameState.action_axis_this_week = {"money": 0, "human": 0}
	GameState.action_places_this_week = {}
	GameState.action_records_this_week = []
	GameState.recent_action_weeks = [
		{"turn": 238, "money": 1, "human": 0, "places": {}, "actions": []},
		{"turn": 239, "money": 1, "human": 0, "places": {}, "actions": []}]
	for index in range(money_actions):
		GameState.register_action_axis("money", "work", "side_shift")
	for index in range(human_actions):
		GameState.register_action_axis("human", "home", "rest")


func _check_general_ledger_and_reducer_contract() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(GENERAL_LEDGER_PATH))
	_expect(parsed is Dictionary, "general finale ledger is not a JSON object")
	if not parsed is Dictionary:
		return
	var ledger: Dictionary = parsed
	_expect(int(ledger.get("schema_version", -1)) == 1 \
		and str(ledger.get("ledger_id", "")) == ROUTE.GENERAL_LEDGER_ID \
		and int(ledger.get("expected_root_count", -1)) == 8 \
		and int(ledger.get("expected_active_root_count", -1)) == 6 \
		and int(ledger.get("expected_choice_count", -1)) == 17 \
		and int(ledger.get("expected_active_choice_count", -1)) == 13 \
		and _same(ledger.get("stages", []), ROUTE.GENERAL_STAGES),
		"general finale ledger inventory drifted")
	var roots: Array = ledger.get("roots", [])
	var events: Array[String] = []
	var total_choices := 0
	var receipt_ids: Dictionary = {}
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
		for raw_choice in root.get("choices", []) as Array:
			if not raw_choice is Dictionary:
				_expect(false, "%s general choice is not an object" % event_id)
				continue
			for raw_receipt_id in (raw_choice as Dictionary).get(
					"receipt_ids", []) as Array:
				var receipt_id := str(raw_receipt_id)
				_expect(not receipt_ids.has(receipt_id),
					"duplicate general receipt id %s" % receipt_id)
				receipt_ids[receipt_id] = true
	_expect(roots.size() == 8 and total_choices == 17 \
		and _same(events, ROUTE.GENERAL_OWNED_EVENT_IDS) \
		and _same(ROUTE.GENERAL_ACTORS, {
			"chooser": "player", "father": "father", "cost_witness": "minseo"}),
		"general finale roots/actors are not exact")

	var empty := ROUTE.default_state()
	for invalid in [
		ROUTE.lock_entry(empty, 223, ROUTE.ROUTE_ID, ROUTE.GENERAL_PROFILE_ID,
			_general_source_choices(), _father("passed", "records_only"), ROUTE.GENERAL_ACTORS),
		ROUTE.lock_entry(empty, 224, ROUTE.ROUTE_ID, ROUTE.PROFILE_ID,
			_general_source_choices(), _father("passed", "records_only"), ROUTE.GENERAL_ACTORS),
		ROUTE.lock_entry(empty, 224, ROUTE.ROUTE_ID, ROUTE.GENERAL_PROFILE_ID,
			_general_source_choices(), _father("alive", "records_only"), ROUTE.GENERAL_ACTORS),
	]:
		_expect(not bool((invalid as Dictionary).get("ok", false)) \
			and _same((invalid as Dictionary).get("state", {}), empty),
			"invalid general entry mutated reducer state")
	var malformed := _general_source_choices()
	malformed["w220_debt_memory_reconnect"] = 2
	_expect(not bool(ROUTE.lock_entry(empty, 224, ROUTE.ROUTE_ID,
		ROUTE.GENERAL_PROFILE_ID, malformed, _father("passed", "records_only"),
		ROUTE.GENERAL_ACTORS).get("ok", false)),
		"out-of-range general source entered finale")
	var extra_actors: Dictionary = ROUTE.GENERAL_ACTORS.duplicate(true)
	extra_actors["partner"] = "daeun"
	_expect(not bool(ROUTE.lock_entry(empty, 224, ROUTE.ROUTE_ID,
		ROUTE.GENERAL_PROFILE_ID, _general_source_choices(),
		_father("passed", "records_only"), extra_actors).get("ok", false)),
		"extra general actor entered finale")

	var final_state: Dictionary = {}
	for branch_choice in [0, 1]:
		var branch_events := _general_events(branch_choice)
		var state := _general_state_through(branch_choice, 0)
		var entry := ROUTE.entry_snapshot(state)
		_expect(ROUTE.entry_locked(state) and ROUTE.holds_ending(state) \
			and str(state.get("ledger_id", "")) == ROUTE.GENERAL_LEDGER_ID \
			and _same(entry, {
				"route_id": ROUTE.ROUTE_ID, "turn": 224,
				"profile_id": ROUTE.GENERAL_PROFILE_ID,
				"source_route_id": ROUTE.GENERAL_SOURCE_ROUTE_ID,
				"source_choices": _general_source_choices(branch_choice),
				"father": _father("passed", "records_only"),
				"actor_bindings": ROUTE.GENERAL_ACTORS,
			}) and ROUTE.next_event_for_turn(state, 224) == branch_events[0],
			"general branch %d W224 durable entry drifted" % branch_choice)
		var inactive_events := _general_events(1 - branch_choice)
		var wrong_order := ROUTE.commit_choice(state, branch_events[1], 0, 229)
		var inactive := ROUTE.commit_choice(state, inactive_events[0], 0, 224)
		var collision := ROUTE.commit_choice(state, ALIVE_EVENTS[0], 0, 224)
		var bad_index := ROUTE.commit_choice(state, branch_events[0], 2, 224)
		_expect(not bool(wrong_order.get("ok", false)) \
			and _same(wrong_order.get("state", {}), state) \
			and not bool(inactive.get("ok", false)) \
			and _same(inactive.get("state", {}), state) \
			and not bool(collision.get("ok", false)) \
			and _same(collision.get("state", {}), state) \
			and not bool(bad_index.get("ok", false)) \
			and _same(bad_index.get("state", {}), state),
			"general branch %d rejection mutated state" % branch_choice)
		for index in range(branch_events.size()):
			var event_id := branch_events[index]
			var choice_index := GENERAL_CHOICES[index]
			var committed := ROUTE.commit_choice(
				state, event_id, choice_index, GENERAL_TURNS[index])
			_expect(bool(committed.get("ok", false)),
				"general branch %d could not commit %s" \
				% [branch_choice, event_id])
			if not bool(committed.get("ok", false)):
				break
			state = (committed.get("state", state) as Dictionary).duplicate(true)
			var replay := ROUTE.commit_choice(
				state, event_id, choice_index, GENERAL_TURNS[index])
			var conflict := ROUTE.commit_choice(
				state, event_id, 1 - choice_index, GENERAL_TURNS[index])
			_expect(bool(replay.get("ok", false)) \
				and bool(replay.get("idempotent", false)) \
				and _same(replay.get("state", {}), state) \
				and not bool(conflict.get("ok", false)) \
				and _same(conflict.get("state", {}), state),
				"general %s write-once replay regressed" % event_id)
			if index <= 2:
				var stage_disk: Variant = JSON.parse_string(JSON.stringify(state))
				var stage_restored := ROUTE.state_from_save(
					stage_disk, true, GENERAL_TURNS[index])
				_expect(_same(stage_restored, state) \
					and typeof(ROUTE.receipt_snapshot_for_event(
						stage_restored, event_id).get("choice_index")) == TYPE_INT,
					"general %s save/load lost exact receipt" % event_id)
				state = stage_restored
			if index == 4:
				_expect(not ROUTE.week_completed(state, 240) \
					and not ROUTE.ending_ready(state) \
					and ROUTE.next_event_for_turn(state, 240) == branch_events[5],
					"general sacrifice did not expose same-turn outbound")
			elif index != 4:
				_expect(ROUTE.week_completed(state, GENERAL_TURNS[index]),
					"general %s did not complete its direct week" % event_id)
		_expect((state.get("order", []) as Array).size() == 6 \
			and ROUTE.week_completed(state, 240) \
			and ROUTE.route_complete(state) and ROUTE.ending_ready(state),
			"general branch %d did not finish six active roots" % branch_choice)
		if branch_choice == 1:
			final_state = state.duplicate(true)

	var disk: Variant = JSON.parse_string(JSON.stringify(final_state))
	var restored := ROUTE.state_from_save(disk, true, 240)
	_expect(_same(restored, final_state) \
		and typeof(restored.get("schema_version")) == TYPE_INT \
		and typeof((ROUTE.entry_snapshot(restored).get(
			"source_choices", {}) as Dictionary).get(
				"w211_name_boundary")) == TYPE_INT \
		and typeof((ROUTE.entry_snapshot(restored).get(
			"source_choices", {}) as Dictionary).get(
				"w220_debt_memory_reconnect")) == TYPE_INT \
		and typeof(ROUTE.receipt_snapshot_for_stage(
			restored, "outbound").get("choice_index")) == TYPE_INT,
		"general JSON save boundary lost exact integer evidence")
	for tamper_kind in ["ledger", "source", "receipt"]:
		var tampered := final_state.duplicate(true)
		if tamper_kind == "ledger":
			tampered["ledger_id"] = ROUTE.LEDGER_ID
		elif tamper_kind == "source":
			((tampered["entry"] as Dictionary)["source_choices"] as Dictionary).erase(
				"m51_minseo_arrival")
		else:
			((tampered["receipts"] as Dictionary)[GENERAL_CAFE_EVENTS[0]] \
				as Dictionary)["choice_index"] = 0
		_expect(str(ROUTE.state_from_save(
			tampered, true, 240).get("status", "")) == "closed",
			"general %s tamper did not fail closed" % tamper_kind)
	var old_v1 := _general_state_through(0, 1)
	old_v1["ledger_id"] = "chapter5_general_near_goal_passed_finale_v1"
	var old_v1_loaded := ROUTE.state_from_save(old_v1, true, 229)
	_expect(str(old_v1_loaded.get("status", "")) == "closed" \
		and (old_v1_loaded.get("entry", {}) as Dictionary).is_empty(),
		"old v1 in-progress general save did not fail closed")
	var consumed_result := ROUTE.consume_ending_check(final_state)
	var consumed: Dictionary = consumed_result.get("state", {})
	var second := ROUTE.consume_ending_check(consumed)
	_expect(bool(consumed_result.get("ok", false)) \
		and not bool(consumed_result.get("idempotent", true)) \
		and not ROUTE.holds_ending(consumed) \
		and bool(second.get("ok", false)) \
		and bool(second.get("idempotent", false)),
		"general ready latch did not consume exactly once")


func _check_general_game_state_contract() -> void:
	_seed_general_sources(true, 1)
	GameState.turn = 224
	_expect(GameState.prepare_chapter5_finale_route_entry() \
		and GameState.chapter5_finale_next_event_for_turn() \
			== GENERAL_CAFE_EVENTS[0],
		"GameState could not lock exact general W224 entry")
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
	var pending_save: Dictionary = {}
	for index in range(GENERAL_CAFE_EVENTS.size()):
		GameState.turn = GENERAL_TURNS[index]
		if index == GENERAL_CAFE_EVENTS.size() - 1:
			pending_save = GameState.serialize().duplicate(true)
		var result := GameState.record_chapter5_finale_choice(
			GENERAL_CAFE_EVENTS[index], GENERAL_CHOICES[index])
		_expect(bool(result.get("ok", false)),
			"GameState could not commit general %s" % GENERAL_CAFE_EVENTS[index])
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
	_check_terminal_axis_release_matrix(
		GameState.serialize().duplicate(true), pending_save, "general")
	var first := GameState.consume_chapter5_finale_ending()
	var second := GameState.consume_chapter5_finale_ending()
	_expect(bool(first.get("ok", false)) and not bool(first.get("idempotent", true)) \
		and bool(second.get("ok", false)) and bool(second.get("idempotent", false)),
		"GameState general ending did not consume exactly once")
	_seed_general_sources(false, 1)
	GameState.turn = 224
	_expect(not GameState.prepare_chapter5_finale_route_entry() \
		and GameState.chapter5_finale_entry_snapshot().is_empty() \
		and not GameState.chapter5_finale_holds_ending(),
		"invalid general sources did not fall back without invented finale evidence")
	_check_general_game_state_exclusions()


func _check_general_w211_source_contract() -> void:
	DataRegistry.reload()
	_seed_general_w211_prechoice()
	GameState.turn = 211
	_expect(GameState.chapter5_general_finale_w211_available() \
		and not GameState.chapter5_general_finale_w211_available(210) \
		and not GameState.chapter5_general_finale_w211_available(212),
		"coherent near-goal profile did not expose exact W211")
	var w211_event: Dictionary = DataRegistry.find_event(
		"arc_y5_general_name_boundary_exact")
	var w211_choices: Array = w211_event.get("choices", [])
	_expect(str(w211_event.get("id", "")) \
		== "arc_y5_general_name_boundary_exact" and w211_choices.size() == 2,
		"W211 source event did not expose two authored choices")
	if w211_choices.size() == 2:
		_expect(GameState.apply_choice(w211_event, w211_choices[1] as Dictionary) \
			and _exact_general_source_receipt(
				"arc_y5_general_name_boundary_exact",
				"chapter5_general_name_boundary_", 2, 1, 211) \
			and not GameState.chapter5_general_finale_w211_available(),
			"W211 choice did not write one exact, non-replayable receipt")
		var disk: Variant = JSON.parse_string(JSON.stringify(GameState.serialize()))
		GameState.start_new_game()
		GameState.load_from_dict(disk)
		GameState.turn = 220
		_expect(GameState.chapter5_general_finale_w220_available() \
			and bool(GameState.flags.get(
				"chapter5_general_name_boundary_1", false)),
			"saved W211 receipt did not survive JSON load or authorize W220")
		var duplicate_log: Dictionary = {}
		for raw_entry in GameState.event_log:
			if raw_entry is Dictionary \
					and str((raw_entry as Dictionary).get("event_id", "")) \
						== "arc_y5_general_name_boundary_exact":
				duplicate_log = (raw_entry as Dictionary).duplicate(true)
				break
		if not duplicate_log.is_empty():
			GameState.event_log.append(duplicate_log)
		_expect(not GameState.chapter5_general_finale_w220_available(),
			"duplicate W211 receipt did not fail closed before W220")

	_seed_general_w211_prechoice()
	GameState.money = 2_499_999_999.0
	_expect(not GameState.chapter5_general_finale_w211_available(211),
		"below-threshold profile exposed W211")

	_seed_general_w211_prechoice()
	GameState.flags["father_passed"] = false
	GameState.cast["father"]["stage"] = "distant"
	_expect(not GameState.chapter5_general_finale_w211_available(211),
		"father-alive profile exposed W211")

	for route_case in [
		{"player_route": "직장형", "tendency": "career", "flag": "route_career"},
		{"player_route": "창업형", "tendency": "found", "flag": "route_startup"},
	]:
		_seed_general_w211_prechoice()
		GameState.player_route = str(route_case["player_route"])
		GameState.tendency_realized = str(route_case["tendency"])
		GameState.flags.erase("route_invest")
		GameState.flags[str(route_case["flag"])] = true
		_expect(not GameState.chapter5_general_finale_w211_available(211),
			"%s profile exposed W211" % route_case["flag"])

	_seed_general_w211_prechoice()
	GameState.flags["arc_y5_general_debt_memory_reconnect_seen"] = true
	_expect(not GameState.chapter5_general_finale_w211_available(211),
		"stale future source exposed W211")
	DataRegistry.reload()


func _check_general_w220_callbacks_to_v2_route() -> void:
	DataRegistry.reload()
	var cases: Array[Dictionary] = [
		{
			"w220_choice": 0,
			"events": GENERAL_VOICE_EVENTS,
			"choices": [0, 1, 0],
		},
		{
			"w220_choice": 1,
			"events": GENERAL_CAFE_EVENTS,
			"choices": [1, 0, 1],
		},
	]
	for route_case in cases:
		_seed_general_w220_prechoice()
		GameState.turn = 220
		var w220_choice := int(route_case["w220_choice"])
		var w220_event: Dictionary = DataRegistry.find_event(
			"arc_y5_general_debt_memory_reconnect")
		var w220_choices: Array = w220_event.get("choices", [])
		_expect(GameState.chapter5_general_finale_w220_available(220) \
			and str(w220_event.get("id", "")) \
				== "arc_y5_general_debt_memory_reconnect" \
			and w220_choice >= 0 and w220_choice < w220_choices.size(),
			"W220 branch %d did not expose its exact source root" \
			% w220_choice)
		if w220_choice < 0 or w220_choice >= w220_choices.size():
			continue
		_expect(GameState.apply_choice(
			w220_event, w220_choices[w220_choice] as Dictionary) \
			and _exact_general_source_receipt(
				"arc_y5_general_debt_memory_reconnect",
				"chapter5_general_debt_memory_reconnect_", 2,
				w220_choice, 220) \
			and GameState.flags.get("arc_endgame_sixmonths_seen", false) is bool \
			and bool(GameState.flags["arc_endgame_sixmonths_seen"]),
			"W220 branch %d did not write one exact source receipt" \
			% w220_choice)

		GameState.turn = 224
		var branch_events: Array = route_case["events"]
		var branch_choices: Array = route_case["choices"]
		var expected_sources := {
			"m51_minseo_arrival": 1,
			"w211_name_boundary": 0,
			"w220_debt_memory_reconnect": w220_choice,
		}
		_expect(GameState.prepare_chapter5_finale_route_entry() \
			and GameState.chapter5_finale_next_event_for_turn(224) \
				== str(branch_events[0]) \
			and _same(GameState.chapter5_finale_entry_snapshot().get(
				"source_choices", {}), expected_sources),
			"W220 branch %d did not lock its exact W224 root" \
			% w220_choice)
		for index in range(3):
			GameState.turn = GENERAL_TURNS[index]
			var event_id := str(branch_events[index])
			var choice_index := int(branch_choices[index])
			var result := GameState.record_chapter5_finale_choice(
				event_id, choice_index)
			_expect(bool(result.get("ok", false)) \
				and int(ROUTE.receipt_snapshot_for_event(
					GameState.chapter5_finale_state, event_id).get(
						"choice_index", -1)) == choice_index,
				"W220 branch %d did not write %s exact receipt" \
				% [w220_choice, event_id])
		_expect(GameState.chapter5_finale_next_event_for_turn(237) \
			== "arc_y5_general_final_record_seal",
			"W220 branch %d did not reach W237 through W224/W229/W234" \
			% w220_choice)
	DataRegistry.reload()


func _exact_general_source_receipt(
		event_id: String, flag_prefix: String, choice_count: int,
		choice_index: int, at_turn: int) -> bool:
	for candidate_index in range(choice_count):
		var flag_id := "%s%d" % [flag_prefix, candidate_index]
		if candidate_index == choice_index:
			if not GameState.flags.has(flag_id) \
					or not GameState.flags[flag_id] is bool \
					or not bool(GameState.flags[flag_id]):
				return false
		elif GameState.flags.has(flag_id):
			return false
	var matching_receipts := 0
	for raw_entry in GameState.event_log:
		if not raw_entry is Dictionary:
			continue
		var entry: Dictionary = raw_entry
		if str(entry.get("event_id", "")) != event_id:
			continue
		if typeof(entry.get("choice_index")) != TYPE_INT \
				or typeof(entry.get("turn")) != TYPE_INT \
				or int(entry["choice_index"]) != choice_index \
				or int(entry["turn"]) != at_turn:
			return false
		matching_receipts += 1
	return matching_receipts == 1


func _check_general_game_state_exclusions() -> void:
	for route_case in [
		{"player_route": "직장형", "flag": "route_career"},
		{"player_route": "창업형", "flag": "route_startup"},
	]:
		_seed_general_sources(true, 0)
		GameState.player_route = str(route_case["player_route"])
		GameState.tendency_realized = (
			"career" if str(route_case["flag"]) == "route_career" else "found")
		GameState.flags.erase("route_invest")
		GameState.flags[str(route_case["flag"])] = true
		GameState.turn = 224
		var before_entry := GameState.chapter5_finale_state.duplicate(true)
		_expect(not GameState.prepare_chapter5_finale_route_entry() \
			and _same(GameState.chapter5_finale_state, before_entry) \
			and GameState.chapter5_finale_entry_snapshot().is_empty(),
			"%s profile entered the general W224 ledger" % route_case["flag"])

		_seed_general_w220_prechoice()
		GameState.player_route = str(route_case["player_route"])
		GameState.tendency_realized = (
			"career" if str(route_case["flag"]) == "route_career" else "found")
		GameState.flags.erase("route_invest")
		GameState.flags[str(route_case["flag"])] = true
		GameState.turn = 220
		_expect(not GameState.chapter5_general_finale_w220_available(),
			"%s profile exposed the general W220 source" % route_case["flag"])

	_seed_general_w220_prechoice()
	GameState.turn = 220
	_expect(GameState.chapter5_general_finale_w220_available(),
		"coherent exact source could not expose general W220")
	_expect(not GameState.chapter5_general_finale_w220_available(219) \
		and not GameState.chapter5_general_finale_w220_available(221),
		"general source escaped exact W220")

	_seed_general_w220_prechoice()
	var closed_w220 := ROUTE.close_route(
		GameState.chapter5_finale_state, "source_route_invalid")
	GameState.chapter5_finale_state = (
		closed_w220.get("state", GameState.chapter5_finale_state) \
		as Dictionary).duplicate(true)
	_expect(not GameState.chapter5_general_finale_w220_available(220),
		"closed finale reducer state exposed an orphan W220 source")

	_seed_general_w220_prechoice()
	GameState.flags["father_passed"] = false
	GameState.cast["father"]["stage"] = "distant"
	_expect(not GameState.chapter5_general_finale_w220_available(220),
		"father-alive route exposed general W220")

	_seed_general_w220_prechoice()
	GameState.flags.erase("chapter5_general_minseo_arrival_1")
	_expect(not GameState.chapter5_general_finale_w220_available(220),
		"missing M51 source exposed general W220")

	_seed_general_w220_prechoice()
	GameState.flags["chapter5_general_minseo_arrival_0"] = true
	_expect(not GameState.chapter5_general_finale_w220_available(220),
		"multiple M51 source flags exposed general W220")

	_seed_general_w220_prechoice()
	GameState.flags["chapter5_general_minseo_arrival_1"] = "true"
	_expect(not GameState.chapter5_general_finale_w220_available(220),
		"non-bool M51 source flag exposed general W220")

	_seed_general_w220_prechoice()
	GameState.flags.erase("chapter5_general_name_boundary_0")
	_expect(not GameState.chapter5_general_finale_w220_available(220),
		"missing W211 source exposed general W220")

	_seed_general_w220_prechoice()
	GameState.flags["chapter5_general_name_boundary_1"] = true
	_expect(not GameState.chapter5_general_finale_w220_available(220),
		"multiple W211 source flags exposed general W220")

	_seed_general_w220_prechoice()
	GameState.flags["chapter5_general_name_boundary_0"] = "true"
	_expect(not GameState.chapter5_general_finale_w220_available(220),
		"non-bool W211 source flag exposed general W220")

	for old_evidence in ["seen", "choice", "log"]:
		_seed_general_w220_prechoice()
		if old_evidence == "seen":
			GameState.flags["arc_y5_general_last_page_instruction_seen"] = true
		elif old_evidence == "choice":
			GameState.flags["chapter5_general_last_page_instruction_0"] = false
		else:
			GameState.event_log.append({
				"event_id": "arc_y5_general_last_page_instruction",
				"choice_index": 0,
				"turn": 229,
			})
		_expect(not GameState.chapter5_general_finale_w220_available(220),
			"old W229 %s evidence exposed general W220" % old_evidence)

	_seed_general_w220_prechoice()
	GameState.chapter5_causal_state = _complete_source_route_state()
	_expect(not GameState.chapter5_general_finale_w220_available(220),
		"property entry exposed general W220")

	var stale_cases: Array[Dictionary] = [
		{
			"event_id": "arc_y5_general_last_page_instruction",
			"flag_prefix": "chapter5_general_last_page_instruction_",
			"turn": 229,
		},
		{
			"event_id": "arc_father_legacy",
			"flag_prefix": "chapter5_general_father_legacy_",
			"turn": 224,
		},
		{
			"event_id": "arc_pre_ending_summit",
			"flag_prefix": "chapter5_general_summit_",
			"turn": 234,
		},
	]
	for stale_case in stale_cases:
		for stale_evidence in ["seen", "choice", "log"]:
			_seed_general_sources(true, 0)
			var stale_event_id := str(stale_case["event_id"])
			if stale_evidence == "seen":
				GameState.flags["%s_seen" % stale_event_id] = true
			elif stale_evidence == "choice":
				GameState.flags[
					"%s0" % str(stale_case["flag_prefix"])] = false
			else:
				GameState.event_log.append({
					"event_id": stale_event_id,
					"choice_index": 0,
					"turn": int(stale_case["turn"]),
				})
			GameState.turn = 224
			var stale_before := GameState.chapter5_finale_state.duplicate(true)
			_expect(not GameState.prepare_chapter5_finale_route_entry() \
				and _same(GameState.chapter5_finale_state, stale_before) \
				and GameState.chapter5_finale_entry_snapshot().is_empty(),
				"stale %s %s evidence entered W224 general ledger" \
				% [stale_event_id, stale_evidence])

	_seed_general_sources(true, 0)
	GameState.event_log.push_front({
		"event_id": "arc_endgame_sixmonths", "choice_index": 0, "turn": 216})
	GameState.turn = 224
	var duplicate_stop_before := GameState.chapter5_finale_state.duplicate(true)
	_expect(not GameState.prepare_chapter5_finale_route_entry() \
		and _same(GameState.chapter5_finale_state, duplicate_stop_before) \
		and GameState.chapter5_finale_entry_snapshot().is_empty(),
		"generic six-month event plus W220 source entered the general ledger")

	_seed_general_sources(true, 0)
	GameState.chapter5_causal_state = _complete_source_route_state()
	GameState.turn = 224
	var property_before := GameState.chapter5_finale_state.duplicate(true)
	_expect(not GameState.prepare_chapter5_finale_route_entry() \
		and _same(GameState.chapter5_finale_state, property_before) \
		and GameState.chapter5_finale_entry_snapshot().is_empty(),
		"property route entered W224 general ledger")

	_seed_general_sources(true, 0)
	GameState.player_route = "none"
	GameState.tendency_realized = ""
	GameState.flags.erase("route_invest")
	GameState.turn = 224
	_expect(GameState.prepare_chapter5_finale_route_entry() \
		and str(GameState.chapter5_finale_entry_snapshot().get("profile_id", "")) \
			== ROUTE.GENERAL_PROFILE_ID,
		"coherent neutral route could not enter the general W224 ledger")

	_seed_general_sources(true, 0)
	GameState.flags.erase("route_invest")
	GameState.turn = 224
	_expect(not GameState.prepare_chapter5_finale_route_entry(),
		"investment identity without route_invest entered the general ledger")

	_seed_general_sources(true, 0)
	GameState.player_route = "none"
	GameState.turn = 224
	_expect(not GameState.prepare_chapter5_finale_route_entry(),
		"neutral identity with sticky route_invest entered the general ledger")

	_seed_general_sources(true, 0)
	GameState.flags["route_career"] = true
	GameState.turn = 224
	_expect(not GameState.prepare_chapter5_finale_route_entry(),
		"hybrid investment/career identity entered the general ledger")

	_seed_general_sources(true, 0)
	GameState.player_route = "none"
	GameState.tendency_realized = "invest"
	GameState.flags.erase("route_invest")
	GameState.turn = 224
	_expect(not GameState.prepare_chapter5_finale_route_entry(),
		"neutral route with mismatched realized tendency entered the general ledger")

	_seed_general_sources(true, 0, 2_499_999_999.0)
	GameState.turn = 224
	var below_before := GameState.chapter5_finale_state.duplicate(true)
	_expect(not GameState.prepare_chapter5_finale_route_entry() \
		and _same(GameState.chapter5_finale_state, below_before) \
		and GameState.chapter5_finale_entry_snapshot().is_empty(),
		"2,499,999,999 asset profile entered W224 general ledger")

	_seed_general_sources(true, 0, 2_500_000_000.0)
	GameState.turn = 224
	_expect(GameState.prepare_chapter5_finale_route_entry() \
		and str(GameState.chapter5_finale_entry_snapshot().get(
			"profile_id", "")) == ROUTE.GENERAL_PROFILE_ID,
		"exact 2.5B asset threshold did not enter W224 general ledger")

	_seed_general_sources(true, 0)
	GameState.flags["father_passed"] = "false"
	GameState.cast["father"]["stage"] = "distant"
	GameState.turn = 224
	var malformed_father_before := GameState.chapter5_finale_state.duplicate(true)
	_expect(not GameState.prepare_chapter5_finale_route_entry() \
		and _same(GameState.chapter5_finale_state, malformed_father_before),
		"non-bool father_passed fabricated the general W224 father state")

	_seed_general_sources(true, 0)
	GameState.flags["chapter5_general_minseo_arrival_0"] = true
	GameState.turn = 224
	var multiple_source_before := GameState.chapter5_finale_state.duplicate(true)
	_expect(not GameState.prepare_chapter5_finale_route_entry() \
		and _same(GameState.chapter5_finale_state, multiple_source_before) \
		and GameState.chapter5_finale_entry_snapshot().is_empty(),
		"multiple true source flags did not reject W224 byte-identically")

	_seed_general_sources(true, 0)
	GameState.flags["chapter5_general_minseo_arrival_1"] = "true"
	GameState.turn = 224
	var non_bool_source_before := GameState.chapter5_finale_state.duplicate(true)
	_expect(not GameState.prepare_chapter5_finale_route_entry() \
		and _same(GameState.chapter5_finale_state, non_bool_source_before) \
		and GameState.chapter5_finale_entry_snapshot().is_empty(),
		"non-bool source flag did not reject W224 byte-identically")

	_seed_general_sources(true, 0)
	GameState.flags["route_career"] = "false"
	GameState.turn = 224
	_expect(not GameState.prepare_chapter5_finale_route_entry() \
		and GameState.chapter5_finale_entry_snapshot().is_empty(),
		"malformed career route flag entered the general W224 ledger")

	_seed_general_sources(true, 0)
	GameState.flags["father_crisis_contact_present"] = "false"
	GameState.turn = 224
	_expect(GameState.prepare_chapter5_finale_route_entry() \
		and str(GameState.chapter5_finale_entry_snapshot().get(
			"father", {}).get("contact_mode", "")) == "records_only",
		"non-bool father contact receipt was coerced into a witnessed contact")


func _check_father_trace_receipt_audio_alignment() -> void:
	var original_language: String = LocaleManager.language
	var story: Node = STORY_MODE.new()
	var source_states: Array[Dictionary] = []
	for meeting_choice in range(3):
		source_states.append(_father_trace_source_state(meeting_choice))
	var trace_contexts := 0
	var trace_results := 0
	var custody_contexts := 0
	var custody_results := 0
	var contacts: Array[String] = ["present", "called", "missed", "records_only"]
	var homes: Array[String] = ["gosiwon", "oneroom", "apartment"]
	var home_backgrounds: Array[String] = ["goshiwon_room", "apartment", "gangnam_apartment"]
	var home_beds: Array[String] = ["room", "oneroom", "apartment"]
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		LocaleManager.set_language(language)
		DataRegistry.reload()
		for life: String in ["alive", "passed"]:
			var event_id: String = ALIVE_EVENTS[0] if life == "alive" else PASSED_EVENTS[0]
			var inactive_id: String = PASSED_EVENTS[0] if life == "alive" else ALIVE_EVENTS[0]
			var raw_event: Dictionary = DataRegistry.find_event(event_id)
			for contact_index in range(contacts.size()):
				for meeting_choice in range(3):
					_seed_father_trace_entry(source_states[meeting_choice], life, contacts[contact_index])
					GameState.housing = homes[meeting_choice]
					var context := "%s W221 %s/%s/meeting%d" % [language, life, contacts[contact_index], meeting_choice]
					_expect(GameState.chapter5_finale_next_event_for_turn() == event_id \
						and GameState.chapter5_finale_ingress_available(event_id) \
						and not GameState.chapter5_finale_ingress_available(inactive_id),
						context + " did not retain the active father-life ingress")
					var resolved: Dictionary = story.call("_chapter5_finale_event_with_reads", raw_event)
					var rows: Array = (raw_event.get("chapter5_finale_reads", {}) as Dictionary).get("texts", [])
					var expected_description := str((rows[0] as Array)[meeting_choice]) + "\n\n" \
						+ str((rows[1] as Array)[contact_index]) + "\n\n" + str(raw_event.get("description", ""))
					_expect(str(resolved.get("description", "")) == expected_description \
						and _father_trace_source_indices(story, expected_description) == [0, 1, 2, 3] \
						and str(resolved.get("background", "")) == "current_housing" \
						and str(resolved.get("portrait", "")) == ("player_tired" if life == "alive" else "player_sad") \
						and not resolved.has("cg"), context + " changed exact receipt assembly, portrait, or home")
					_expect(str(story.call("_resolve_story_background_id", "current_housing")) == home_backgrounds[meeting_choice] \
						and str(BGMPlayer.call("_resolve_dynamic_ambience_key", "current_housing")) == home_beds[meeting_choice],
						context + " did not resolve the actual housing image and bed")
					var choices: Array = resolved.get("choices", [])
					_expect(choices.size() == 3, context + " lost its three authored choices")
					if choices.size() != 3:
						continue
					var expected_result_counts: Array[int] = [2, 1, 2]
					if life == "passed":
						expected_result_counts[2] = 1
					var result_sources: Array = []
					for choice_index in range(choices.size()):
						var indices := _father_trace_source_indices(story, str((choices[choice_index] as Dictionary).get("result_text", "")))
						_expect(indices == ([0, 1] if expected_result_counts[choice_index] == 2 else [0]),
							context + " changed result source counts for choice%d" % choice_index)
						result_sources.append(indices)
						trace_results += 1
					var result_sounds: Array[String] = ["pen_write", "pen_write", "pen_write"]
					if life == "passed":
						result_sounds[2] = "paper_handle"
					_assert_father_trace_audio(event_id, [0, 1, 2, 3], result_sources, result_sounds, context)
					trace_contexts += 1
			for trace_choice in range(3):
				_seed_father_trace_entry(source_states[1], life, "records_only")
				var committed: Dictionary = GameState.record_chapter5_finale_choice(event_id, trace_choice)
				_expect(bool(committed.get("ok", false)), "%s W224 could not commit father trace%d" % [language, trace_choice])
				GameState.turn = 224
				var custody_id: String = ALIVE_EVENTS[1]
				var context := "%s W224 %s/trace%d" % [language, life, trace_choice]
				_expect(GameState.chapter5_finale_next_event_for_turn() == custody_id \
					and GameState.chapter5_finale_ingress_available(custody_id), context + " lost its exact custody ingress")
				var custody_raw: Dictionary = DataRegistry.find_event(custody_id)
				var custody: Dictionary = story.call("_chapter5_finale_event_with_reads", custody_raw)
				var rows: Array = (custody_raw.get("chapter5_finale_reads", {}) as Dictionary).get("texts", [])
				var expected_description := str((rows[0] as Array)[trace_choice]) + "\n\n" + str(custody_raw.get("description", ""))
				_expect(str(custody.get("description", "")) == expected_description \
					and _father_trace_source_indices(story, expected_description) == [0, 1, 2] \
					and str(custody.get("background", "")) == "convenience_rear_comparison" \
					and str(custody.get("portrait", "")) == "player_tired" and not custody.has("cg"),
					context + " changed its exact prefix, comparison background, or portrait")
				var choices: Array = custody.get("choices", [])
				_expect(choices.size() == 2, context + " lost its two custody choices")
				if choices.size() != 2:
					continue
				var result_sources: Array = []
				for choice_index in range(choices.size()):
					var indices := _father_trace_source_indices(story, str((choices[choice_index] as Dictionary).get("result_text", "")))
					_expect(indices == ([0, 1] if choice_index == 0 else [0]),
						context + " changed result sources for custody choice%d" % choice_index)
					result_sources.append(indices)
					custody_results += 1
				_assert_father_trace_audio(custody_id, [0, 1, 2], result_sources, ["paper_handle", "paper_handle"], context)
				custody_contexts += 1
	_expect(trace_contexts == 120 and trace_results == 360 \
		and custody_contexts == 30 and custody_results == 60,
		"father trace audio did not cover exact W221 120/360 and W224 30/60 contexts/results")
	_expect(_same(BGMPlayer.scene_audio_contract(ALIVE_EVENTS[0]), {
		"ambience": "current_housing", "suppress_music": true,
		"result_paragraph_cues": {
			"0": {"0": [{"sfx": "pen_write", "volume_db": -6.0}]},
			"1": {"0": [{"sfx": "pen_write", "volume_db": -8.0}]},
			"2": {"0": [{"sfx": "pen_write", "volume_db": -10.0}]},
		},
	}), "W221 alive changed its room, silence, or three exact result cues")
	_expect(_same(BGMPlayer.scene_audio_contract(PASSED_EVENTS[0]), {
		"ambience": "current_housing", "music": {"key": "grief", "start_paragraph": 1.0},
		"result_paragraph_cues": {
			"0": {"0": [{"sfx": "pen_write", "volume_db": -7.0}]},
			"1": {"0": [{"sfx": "pen_write", "volume_db": -10.0}]},
			"2": {"0": [{"sfx": "paper_handle", "volume_db": -8.0}]},
		},
	}), "W221 passed changed its room, grief entrance, or three exact result cues")
	_expect(_same(BGMPlayer.scene_audio_contract(ALIVE_EVENTS[1]), {
		"ambience": "intentional_silence", "music": {"key": "reckoning", "start_paragraph": 1.0},
		"result_paragraph_cues": {
			"0": {"0": [{"sfx": "paper_handle", "volume_db": -6.0}]},
			"1": {"0": [{"sfx": "paper_handle", "volume_db": -8.0}]},
		},
	}), "W224 changed intentional silence, score entrance, or two exact result cues")
	LocaleManager.set_language(original_language)
	DataRegistry.reload()
	story.free()


func _check_w227_ballpoint_audio_alignment() -> void:
	var original_language: String = LocaleManager.language
	var story: Node = STORY_MODE.new()
	var source_states: Array[Dictionary] = []
	for meeting_choice in range(3):
		source_states.append(_father_trace_source_state(meeting_choice))
	var raw_anchor_metadata: Variant = W227_BALLPOINT_WRITE.get_meta(
		"write_anchors", {})
	_expect(raw_anchor_metadata is Dictionary,
		"W227 ballpoint asset lost its write-anchor dictionary")
	var anchors: Dictionary = raw_anchor_metadata as Dictionary \
		if raw_anchor_metadata is Dictionary else {}
	_expect(anchors.size() == 2 and anchors.has("1") and anchors.has("3"),
		"W227 ballpoint asset must own only choice1/choice3 write anchors")
	for choice_key: String in ["1", "3"]:
		var raw_locales: Variant = anchors.get(choice_key, {})
		_expect(raw_locales is Dictionary,
			"W227 choice%s write anchors are not a locale map" % choice_key)
		if raw_locales is Dictionary:
			var locales: Dictionary = raw_locales
			_expect(locales.size() == LocaleManager.SUPPORTED_LANGUAGES.size(),
				"W227 choice%s write anchors lost the exact locale inventory" % choice_key)
			for language: String in LocaleManager.SUPPORTED_LANGUAGES:
				_expect(locales.get(language, "") is String \
					and not str(locales.get(language, "")).strip_edges().is_empty(),
					"W227 choice%s has no exact %s write anchor" % [choice_key, language])

	var contexts := 0
	var results := 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		LocaleManager.set_language(language)
		DataRegistry.reload()
		for life: String in ["alive", "passed"]:
			var trace_id: String = ALIVE_EVENTS[0] if life == "alive" else PASSED_EVENTS[0]
			for meeting_choice in range(3):
				for custody_choice in range(2):
					_seed_father_trace_entry(
						source_states[meeting_choice], life, "records_only")
					var trace_commit: Dictionary = GameState.record_chapter5_finale_choice(
						trace_id, PATH_CHOICES[0])
					_expect(bool(trace_commit.get("ok", false)),
						"%s W227 could not commit its W221 father trace" % language)
					GameState.turn = 224
					var custody_commit: Dictionary = GameState.record_chapter5_finale_choice(
						ALIVE_EVENTS[1], custody_choice)
					_expect(bool(custody_commit.get("ok", false)),
						"%s W227 could not commit custody choice%d" % [language, custody_choice])
					GameState.turn = 227
					var context := "%s W227 %s/meeting%d/custody%d" % [
						language, life, meeting_choice, custody_choice]
					_expect(GameState.chapter5_finale_next_event_for_turn() == ALIVE_EVENTS[2] \
						and GameState.chapter5_finale_ingress_available(ALIVE_EVENTS[2]) \
						and ROUTE.selected_choice_by_event(
							GameState.chapter5_finale_state, trace_id) == PATH_CHOICES[0] \
						and ROUTE.selected_choice_by_event(
							GameState.chapter5_finale_state, ALIVE_EVENTS[1]) == custody_choice,
						context + " lost its exact W219/W224 receipt ingress")
					var raw_event: Dictionary = DataRegistry.find_event(ALIVE_EVENTS[2])
					var resolved: Dictionary = story.call(
						"_chapter5_finale_event_with_reads", raw_event)
					var rows: Array = (
						raw_event.get("chapter5_finale_reads", {}) as Dictionary).get("texts", [])
					var expected_description := str((rows[0] as Array)[meeting_choice]) \
						+ "\n\n" + str((rows[1] as Array)[custody_choice]) \
						+ "\n\n" + str(raw_event.get("description", ""))
					_expect(str(resolved.get("description", "")) == expected_description \
						and _father_trace_source_indices(
							story, expected_description) == [0, 1, 2, 3] \
						and str(resolved.get("background", "")) == "finale_intake_blue_pen" \
						and str(resolved.get("portrait", "")).is_empty() \
						and not resolved.has("cg"),
						context + " changed its exact receipt assembly or filing-counter art")
					var choices: Array = resolved.get("choices", [])
					_expect(choices.size() == 4,
						context + " lost its four authored filing choices")
					if choices.size() != 4:
						continue
					var result_sources: Array = []
					for choice_index in range(choices.size()):
						var formatted_result: String = str(story.call(
							"_fmt", str((choices[choice_index] as Dictionary).get(
								"result_text", ""))))
						var indices := _father_trace_source_indices(story, formatted_result)
						var expected_indices: Array[int] = []
						expected_indices.append(0)
						if choice_index != 1:
							expected_indices.append(1)
						_expect(indices == expected_indices,
							context + " changed result source counts for choice%d" % choice_index)
						result_sources.append(indices)
						_check_w227_result_anchor(
							story, anchors, language, choice_index, formatted_result, context)
						results += 1
					_assert_w227_manifest_audio(
						[0, 1, 2, 3], result_sources, context)
					contexts += 1
	_expect(contexts == 60 and results == 240,
		"W227 ballpoint audio did not cover exact 60 contexts and 240 results")
	_expect(_same(BGMPlayer.scene_audio_contract(ALIVE_EVENTS[2]), {
		"ambience": "intentional_silence",
		"music": {"key": "reckoning", "start_paragraph": 1.0},
		"result_paragraph_cues": {
			"0": {"0": [{"sfx": "paper_handle", "volume_db": -6.0}]},
		},
	}), "W227 changed intentional silence, reckoning entrance, or c0 paper cue")
	LocaleManager.set_language(original_language)
	DataRegistry.reload()
	story.free()


func _check_w227_result_anchor(
		story: Node, anchors: Dictionary, language: String,
		choice_index: int, formatted_result: String, context: String) -> void:
	var source_paragraphs := formatted_result.split("\n\n")
	var source_zero := str(source_paragraphs[0]) \
		if not source_paragraphs.is_empty() else ""
	var localized_anchors: Array[String] = []
	for choice_key: String in ["1", "3"]:
		var locales: Dictionary = anchors.get(choice_key, {}) \
			if anchors.get(choice_key, {}) is Dictionary else {}
		localized_anchors.append(str(story.call(
			"_fmt", str(locales.get(language, "")))))
	if choice_index in [1, 3]:
		var expected_anchor: String = localized_anchors[0 if choice_index == 1 else 1]
		var anchor_at := source_zero.find(expected_anchor)
		_expect(not expected_anchor.is_empty() \
			and formatted_result.count(expected_anchor) == 1 \
			and source_zero.count(expected_anchor) == 1 \
			and anchor_at > 0 \
			and anchor_at + expected_anchor.length() <= source_zero.length(),
			context + " choice%d lost its unique in-clause write boundary" % choice_index)
		return
	for anchor: String in localized_anchors:
		_expect(anchor.is_empty() or anchor not in formatted_result,
			context + " choice%d inherited a ballpoint write anchor" % choice_index)


func _assert_w227_manifest_audio(
		sources: Array[int], result_sources: Array, context: String) -> void:
	var before: Dictionary = GameState.serialize().duplicate(true)
	var tracked: Array[String] = [
		"phone_notification", "page_turn", "paper_handle", "cup_set",
		"register_scan", "traffic_pass", "pen_write", "pen_ballpoint", "door_latch",
	]
	var last_play: Dictionary = {}
	for sound_id: String in tracked:
		last_play[sound_id] = AudioManager._last_sfx_ms.get(sound_id, -1)
	AudioManager.begin_story_audio_event(ALIVE_EVENTS[2])
	for source_index in sources:
		AudioManager.play_scene_paragraph_cues(ALIVE_EVENTS[2], "", source_index)
	for choice_index in range(result_sources.size()):
		for raw_index in result_sources[choice_index] as Array:
			AudioManager.play_scene_result_paragraph_cues(
				ALIVE_EVENTS[2], "", choice_index, int(raw_index))
	var expected: Array[String] = [
		"%s::result:0:0:0:paper_handle" % ALIVE_EVENTS[2],
	]
	_expect(AudioManager._story_audio_seen.keys() == expected,
		"%s dispatched wrong W227 manifest cues: %s (expected %s)" % [
			context, JSON.stringify(AudioManager._story_audio_seen), JSON.stringify(expected)])
	for sound_id: String in tracked:
		if sound_id != "paper_handle":
			_expect(AudioManager._last_sfx_ms.get(sound_id, -1) == last_play[sound_id],
				context + " played forbidden manifest sound " + sound_id)
	var seen: Dictionary = AudioManager._story_audio_seen.duplicate(true)
	var timestamps: Dictionary = AudioManager._last_sfx_ms.duplicate(true)
	for source_index in sources:
		AudioManager.play_scene_paragraph_cues(ALIVE_EVENTS[2], "", source_index)
	for choice_index in range(result_sources.size()):
		for raw_index in result_sources[choice_index] as Array:
			AudioManager.play_scene_result_paragraph_cues(
				ALIVE_EVENTS[2], "", choice_index, int(raw_index))
	_expect(_same(AudioManager._story_audio_seen, seen) \
		and _same(AudioManager._last_sfx_ms, timestamps),
		context + " replayed W227 manifest cues on a repeated paragraph bind")
	_expect(_same(GameState.serialize(), before),
		context + " W227 manifest audio rewrote the finale receipts or game state")


func _check_w230_cafe_write_alignment() -> void:
	var original_language: String = LocaleManager.language
	var story: Node = STORY_MODE.new()
	var raw_anchor_metadata: Variant = W230_CAFE_WRITE.get_meta("write_anchors", {})
	_expect(raw_anchor_metadata is Dictionary,
		"W230 cafe write asset lost its write-anchor dictionary")
	var anchors: Dictionary = raw_anchor_metadata as Dictionary \
		if raw_anchor_metadata is Dictionary else {}
	var choice_keys: Array = anchors.keys()
	choice_keys.sort()
	_expect(choice_keys == ["0", "1", "2"],
		"W230 cafe write asset must own exact choice0/choice1/choice2 rows")
	var expected_action_sources := {
		"0": ["0", "1"],
		"1": ["0", "1"],
		"2": ["0"],
	}
	var anchor_count := 0
	for choice_key: String in ["0", "1", "2"]:
		var raw_sources: Variant = anchors.get(choice_key, {})
		_expect(raw_sources is Dictionary,
			"W230 choice%s write anchors are not a source map" % choice_key)
		if not raw_sources is Dictionary:
			continue
		var source_rows: Dictionary = raw_sources
		var source_keys: Array = source_rows.keys()
		source_keys.sort()
		_expect(source_keys == expected_action_sources[choice_key],
			"W230 choice%s lost its exact writing-source inventory" % choice_key)
		for source_key: String in expected_action_sources[choice_key]:
			var raw_locales: Variant = source_rows.get(source_key, {})
			_expect(raw_locales is Dictionary,
				"W230 choice%s source%s anchors are not a locale map" % [
					choice_key, source_key])
			if not raw_locales is Dictionary:
				continue
			var locales: Dictionary = raw_locales
			_expect(locales.size() == LocaleManager.SUPPORTED_LANGUAGES.size(),
				"W230 choice%s source%s lost its exact locale inventory" % [
					choice_key, source_key])
			for language: String in LocaleManager.SUPPORTED_LANGUAGES:
				_expect(locales.get(language, "") is String \
					and not str(locales.get(language, "")).strip_edges().is_empty(),
					"W230 choice%s source%s has no exact %s write anchor" % [
						choice_key, source_key, language])
				anchor_count += 1
	_expect(anchor_count == 25, "W230 cafe write metadata lost its exact 25 anchors")

	var source_state: Dictionary = _father_trace_source_state(1)
	var contexts := 0
	var results := 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		LocaleManager.set_language(language)
		DataRegistry.reload()
		for life: String in ["alive", "passed"]:
			var trace_id: String = ALIVE_EVENTS[0] if life == "alive" else PASSED_EVENTS[0]
			for custody_choice in range(2):
				for filing_choice in range(4):
					_seed_father_trace_entry(source_state, life, "records_only")
					var trace_commit: Dictionary = GameState.record_chapter5_finale_choice(
						trace_id, PATH_CHOICES[0])
					_expect(bool(trace_commit.get("ok", false)),
						"%s W230 could not commit its W221 father trace" % language)
					GameState.turn = 224
					var custody_commit: Dictionary = GameState.record_chapter5_finale_choice(
						ALIVE_EVENTS[1], custody_choice)
					_expect(bool(custody_commit.get("ok", false)),
						"%s W230 could not commit custody choice%d" % [
							language, custody_choice])
					GameState.turn = 227
					var filing_commit: Dictionary = GameState.record_chapter5_finale_choice(
						ALIVE_EVENTS[2], filing_choice)
					_expect(bool(filing_commit.get("ok", false)),
						"%s W230 could not commit filing choice%d" % [
							language, filing_choice])
					GameState.turn = 230
					var context := "%s W230 %s/custody%d/filing%d" % [
						language, life, custody_choice, filing_choice]
					_expect(GameState.chapter5_finale_next_event_for_turn() == W230_CAFE \
						and GameState.chapter5_finale_ingress_available(W230_CAFE) \
						and ROUTE.selected_choice_by_event(
							GameState.chapter5_finale_state, ALIVE_EVENTS[1]) == custody_choice \
						and ROUTE.selected_choice_by_event(
							GameState.chapter5_finale_state, ALIVE_EVENTS[2]) == filing_choice,
						context + " lost its exact custody/filing receipt ingress")
					var raw_event: Dictionary = DataRegistry.find_event(W230_CAFE)
					var resolved: Dictionary = story.call(
						"_chapter5_finale_event_with_reads", raw_event)
					var rows: Array = (
						raw_event.get("chapter5_finale_reads", {}) as Dictionary).get("texts", [])
					var expected_description := str((rows[0] as Array)[custody_choice]) \
						+ "\n\n" + str((rows[1] as Array)[filing_choice]) \
						+ "\n\n" + str(raw_event.get("description", ""))
					_expect(str(resolved.get("description", "")) == expected_description \
						and _father_trace_source_indices(
							story, expected_description) == [0, 1, 2, 3] \
						and str(resolved.get("background", "")) == "finale_cafe_rear_papers" \
						and str(resolved.get("portrait", "")).is_empty() \
						and not resolved.has("cg"),
						context + " changed its four-source receipt assembly or cafe art")
					var choices: Array = resolved.get("choices", [])
					_expect(choices.size() == 3,
						context + " lost its three authored verdict choices")
					if choices.size() != 3:
						continue
					var result_sources: Array = []
					for choice_index in range(choices.size()):
						var formatted_result: String = str(story.call(
							"_fmt", str((choices[choice_index] as Dictionary).get(
								"result_text", ""))))
						var indices := _father_trace_source_indices(story, formatted_result)
						_expect(indices == [0, 1],
							context + " changed result sources for choice%d" % choice_index)
						result_sources.append(indices)
						_check_w230_result_anchors(
							story, anchors, language, choice_index, formatted_result, context)
						results += 1
					_assert_w230_manifest_audio([0, 1, 2, 3], result_sources, context)
					contexts += 1
	_expect(contexts == 80 and results == 240,
		"W230 cafe write audio did not cover exact 80 contexts and 240 results")
	_expect(_same(BGMPlayer.scene_audio_contract(W230_CAFE), {
		"ambience": "intentional_silence",
		"music": {"key": "reckoning", "start_paragraph": 1.0},
		"paragraph_cues": {
			"0": [{"sfx": "paper_handle", "volume_db": -7.0}],
		},
	}), "W230 changed intentional silence, reckoning entrance, or intro paper-only cue")
	LocaleManager.set_language(original_language)
	DataRegistry.reload()
	story.free()


func _check_w230_result_anchors(
		story: Node, anchors: Dictionary, language: String,
		choice_index: int, formatted_result: String, context: String) -> void:
	var sources := formatted_result.split("\n\n")
	if sources.size() != 2:
		_expect(false, context + " choice%d lost its exact two result sources" % choice_index)
		return
	var raw_source_rows: Variant = anchors.get(str(choice_index), {})
	if not raw_source_rows is Dictionary:
		_expect(false, context + " choice%d has no write-anchor source map" % choice_index)
		return
	var source_rows: Dictionary = raw_source_rows
	for source_key: Variant in source_rows:
		var source_index := int(str(source_key))
		var raw_locales: Variant = source_rows[source_key]
		if source_index < 0 or source_index >= sources.size() or not raw_locales is Dictionary:
			_expect(false,
				context + " choice%d has a malformed write-anchor source" % choice_index)
			continue
		var anchor: String = str(story.call(
			"_fmt", str((raw_locales as Dictionary).get(language, ""))))
		var source := str(sources[source_index])
		var anchor_at := source.find(anchor)
		_expect(not anchor.is_empty() \
			and formatted_result.count(anchor) == 1 \
			and source.count(anchor) == 1 \
			and anchor_at >= 0 \
			and anchor_at + anchor.length() <= source.length(),
			context + " choice%d/source%d lost its unique in-clause write boundary" % [
				choice_index, source_index])


func _assert_w230_manifest_audio(
		sources: Array[int], result_sources: Array, context: String) -> void:
	var before: Dictionary = GameState.serialize().duplicate(true)
	var tracked: Array[String] = [
		"phone_notification", "page_turn", "paper_handle", "cup_set",
		"register_scan", "traffic_pass", "pen_write", "pen_ballpoint", "door_latch",
	]
	var last_play: Dictionary = {}
	for sound_id: String in tracked:
		last_play[sound_id] = AudioManager._last_sfx_ms.get(sound_id, -1)
	AudioManager.begin_story_audio_event(W230_CAFE)
	for source_index in sources:
		AudioManager.play_scene_paragraph_cues(W230_CAFE, "", source_index)
	for choice_index in range(result_sources.size()):
		for raw_index in result_sources[choice_index] as Array:
			AudioManager.play_scene_result_paragraph_cues(
				W230_CAFE, "", choice_index, int(raw_index))
	var expected: Array[String] = [
		W230_CAFE + "::description:0:0:paper_handle",
	]
	_expect(AudioManager._story_audio_seen.keys() == expected,
		"%s dispatched wrong W230 manifest cues: %s (expected %s)" % [
			context, JSON.stringify(AudioManager._story_audio_seen), JSON.stringify(expected)])
	for sound_id: String in tracked:
		if sound_id != "paper_handle":
			_expect(AudioManager._last_sfx_ms.get(sound_id, -1) == last_play[sound_id],
				context + " played forbidden W230 manifest sound " + sound_id)
	var seen: Dictionary = AudioManager._story_audio_seen.duplicate(true)
	var timestamps: Dictionary = AudioManager._last_sfx_ms.duplicate(true)
	for source_index in sources:
		AudioManager.play_scene_paragraph_cues(W230_CAFE, "", source_index)
	for choice_index in range(result_sources.size()):
		for raw_index in result_sources[choice_index] as Array:
			AudioManager.play_scene_result_paragraph_cues(
				W230_CAFE, "", choice_index, int(raw_index))
	_expect(_same(AudioManager._story_audio_seen, seen) \
		and _same(AudioManager._last_sfx_ms, timestamps),
		context + " replayed W230 manifest cues on a repeated paragraph bind")
	_expect(_same(GameState.serialize(), before),
		context + " W230 manifest audio rewrote finale receipts or game state")


func _check_w235_notice_return_alignment() -> void:
	var original_language: String = LocaleManager.language
	var story: Node = STORY_MODE.new()
	var raw_anchor_metadata: Variant = W235_NOTICE_RETURN.get_meta("return_anchors", {})
	_expect(raw_anchor_metadata is Dictionary,
		"W235 notice return asset lost its return-anchor dictionary")
	var anchors: Dictionary = raw_anchor_metadata as Dictionary \
		if raw_anchor_metadata is Dictionary else {}
	var anchor_languages: Array = anchors.keys()
	anchor_languages.sort()
	var expected_languages: Array = LocaleManager.SUPPORTED_LANGUAGES.duplicate()
	expected_languages.sort()
	_expect(anchor_languages == expected_languages,
		"W235 notice return asset lost its exact five-locale inventory")
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		_expect(anchors.get(language, "") is String \
			and not str(anchors.get(language, "")).strip_edges().is_empty(),
			"W235 notice return has no exact %s anchor" % language)

	var source_state: Dictionary = _father_trace_source_state(1)
	var contexts := 0
	var results := 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		LocaleManager.set_language(language)
		DataRegistry.reload()
		for life: String in ["alive", "passed"]:
			var trace_id: String = ALIVE_EVENTS[0] if life == "alive" else PASSED_EVENTS[0]
			for filing_choice in range(4):
				for verdict_choice in range(3):
					_seed_father_trace_entry(source_state, life, "records_only")
					var trace_commit: Dictionary = GameState.record_chapter5_finale_choice(
						trace_id, PATH_CHOICES[0])
					GameState.turn = 224
					var custody_commit: Dictionary = GameState.record_chapter5_finale_choice(
						ALIVE_EVENTS[1], PATH_CHOICES[1])
					GameState.turn = 227
					var filing_commit: Dictionary = GameState.record_chapter5_finale_choice(
						ALIVE_EVENTS[2], filing_choice)
					GameState.turn = 230
					var verdict_commit: Dictionary = GameState.record_chapter5_finale_choice(
						W230_CAFE, verdict_choice)
					GameState.turn = 235
					var context := "%s W235 %s/filing%d/verdict%d" % [
						language, life, filing_choice, verdict_choice]
					_expect(bool(trace_commit.get("ok", false)) \
						and bool(custody_commit.get("ok", false)) \
						and bool(filing_commit.get("ok", false)) \
						and bool(verdict_commit.get("ok", false)) \
						and GameState.chapter5_finale_next_event_for_turn() == W235_NOTICE \
						and GameState.chapter5_finale_ingress_available(W235_NOTICE) \
						and ROUTE.selected_choice_by_event(
							GameState.chapter5_finale_state, ALIVE_EVENTS[2]) == filing_choice \
						and ROUTE.selected_choice_by_event(
							GameState.chapter5_finale_state, W230_CAFE) == verdict_choice,
						context + " lost its exact father/custody/filing/verdict ingress")
					var raw_event: Dictionary = DataRegistry.find_event(W235_NOTICE)
					var resolved: Dictionary = story.call(
						"_chapter5_finale_event_with_reads", raw_event)
					var rows: Array = (
						raw_event.get("chapter5_finale_reads", {}) as Dictionary).get("texts", [])
					var expected_description := str((rows[0] as Array)[filing_choice]) \
						+ "\n\n" + str((rows[1] as Array)[verdict_choice]) \
						+ "\n\n" + str(raw_event.get("description", ""))
					_expect(str(resolved.get("description", "")) == expected_description \
						and _father_trace_source_indices(
							story, expected_description) == [0, 1, 2, 3] \
						and str(resolved.get("background", "")) == "current_housing" \
						and str(resolved.get("portrait", "")) == "player_tired" \
						and not resolved.has("cg"),
						context + " changed its four-source receipt assembly or home surface")
					var choices: Array = resolved.get("choices", [])
					_expect(choices.size() == 1,
						context + " lost its one direct-progress notice choice")
					if choices.size() != 1:
						continue
					var formatted_result: String = str(story.call(
						"_fmt", str((choices[0] as Dictionary).get("result_text", ""))))
					var result_indices: Array[int] = []
					result_indices.assign(_father_trace_source_indices(story, formatted_result))
					_expect(result_indices == [0, 1],
						context + " changed its exact two-source result")
					_check_w235_result_anchor(
						story, anchors, language, formatted_result, context)
					_assert_w235_manifest_audio([0, 1, 2, 3], result_indices, context)
					contexts += 1
					results += 1
	_expect(contexts == 120 and results == 120,
		"W235 notice return did not cover exact 120 contexts and 120 results")
	_expect(_same(BGMPlayer.scene_audio_contract(W235_NOTICE), {
		"ambience": "apartment",
		"suppress_human_ambience": true,
		"suppress_season_ambience": true,
		"suppress_music": true,
	}), "W235 changed its apartment bed or immediate people/season/music suppression")
	LocaleManager.set_language(original_language)
	DataRegistry.reload()
	story.free()


func _check_w235_result_anchor(
		story: Node, anchors: Dictionary, language: String,
		formatted_result: String, context: String) -> void:
	var sources := formatted_result.split("\n\n")
	var anchor: String = str(story.call(
		"_fmt", str(anchors.get(language, ""))))
	if sources.size() != 2:
		_expect(false, context + " lost its exact two result sources")
		return
	var source_zero := str(sources[0])
	var source_one := str(sources[1])
	var anchor_at := source_one.find(anchor)
	_expect(not anchor.is_empty() \
		and formatted_result.count(anchor) == 1 \
		and source_zero.count(anchor) == 0 \
		and source_one.count(anchor) == 1 \
		and anchor_at > 0 \
		and anchor_at + anchor.length() == source_one.length(),
		context + " lost its unique final source1 physical-return clause")


func _assert_w235_manifest_audio(
		sources: Array[int], result_sources: Array[int], context: String) -> void:
	var before: Dictionary = GameState.serialize().duplicate(true)
	var tracked: Array[String] = [
		"phone_notification", "page_turn", "paper_handle", "cup_set",
		"register_scan", "traffic_pass", "pen_write", "pen_ballpoint", "door_latch",
	]
	var last_play: Dictionary = {}
	for sound_id: String in tracked:
		last_play[sound_id] = AudioManager._last_sfx_ms.get(sound_id, -1)
	AudioManager.begin_story_audio_event(W235_NOTICE)
	for source_index in sources:
		AudioManager.play_scene_paragraph_cues(W235_NOTICE, "", source_index)
	for source_index in result_sources:
		AudioManager.play_scene_result_paragraph_cues(
			W235_NOTICE, "", 0, source_index)
	_expect(AudioManager._story_audio_seen.is_empty(),
		context + " retained a paragraph-entry cue instead of the live return action")
	for sound_id: String in tracked:
		_expect(AudioManager._last_sfx_ms.get(sound_id, -1) == last_play[sound_id],
			context + " played forbidden W235 manifest sound " + sound_id)
	var timestamps: Dictionary = AudioManager._last_sfx_ms.duplicate(true)
	for source_index in sources:
		AudioManager.play_scene_paragraph_cues(W235_NOTICE, "", source_index)
	for source_index in result_sources:
		AudioManager.play_scene_result_paragraph_cues(
			W235_NOTICE, "", 0, source_index)
	_expect(AudioManager._story_audio_seen.is_empty() \
		and _same(AudioManager._last_sfx_ms, timestamps),
		context + " replayed a W235 manifest cue on repeated paragraph binding")
	_expect(_same(GameState.serialize(), before),
		context + " W235 manifest audio rewrote finale receipts or game state")


func _check_w237_final_record_alignment() -> void:
	var original_language: String = LocaleManager.language
	var story: Node = STORY_MODE.new()
	var raw_anchor_metadata: Variant = W237_RECORD_PAGE_TURN.get_meta(
		"page_turn_anchors", {})
	_expect(raw_anchor_metadata is Dictionary,
		"W237 page-turn asset lost its page-turn anchor dictionary")
	var anchors: Dictionary = raw_anchor_metadata as Dictionary \
		if raw_anchor_metadata is Dictionary else {}
	var anchor_languages: Array = anchors.keys()
	anchor_languages.sort()
	var expected_languages: Array = LocaleManager.SUPPORTED_LANGUAGES.duplicate()
	expected_languages.sort()
	_expect(anchor_languages == expected_languages,
		"W237 page-turn asset lost its exact five-locale inventory")
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		_expect(anchors.get(language, "") is String \
			and not str(anchors.get(language, "")).strip_edges().is_empty(),
			"W237 page turn has no exact %s anchor" % language)

	var father_receipts: Array = [
		[
			["m56_general_father_legacy_voice_spoken",
				"Y5-GENERAL-FATHER-LEGACY-VOICE-SPOKEN"],
			["m56_general_father_legacy_voice_silence_beside_chair",
				"Y5-GENERAL-FATHER-LEGACY-VOICE-SILENCE-BESIDE-CHAIR"],
		],
		[
			["m56_general_father_legacy_cafe_copy_read_aloud",
				"Y5-GENERAL-FATHER-LEGACY-CAFE-COPY-READ-ALOUD"],
			["m56_general_father_legacy_cafe_copy_left_folded_in_silence",
				"Y5-GENERAL-FATHER-LEGACY-CAFE-COPY-LEFT-FOLDED-IN-SILENCE"],
		],
	]
	var debt_receipts: Array = [
		[
			["m58_general_voice_memo_kept_private",
				"Y5-GENERAL-VOICE-MEMO-KEPT-PRIVATE"],
			["m58_general_voice_memo_deleted_timestamp_kept",
				"Y5-GENERAL-VOICE-MEMO-DELETED-TIMESTAMP-KEPT"],
		],
		[
			["m58_general_cafe_copy_carried_forward",
				"Y5-GENERAL-CAFE-COPY-CARRIED-FORWARD"],
			["m58_general_cafe_copy_left_with_father_record",
				"Y5-GENERAL-CAFE-COPY-LEFT-WITH-FATHER-RECORD"],
		],
	]
	var summit_receipts: Array = [
		["m59_general_summit_father_contact_opened",
			"Y5-GENERAL-SUMMIT-FATHER-CONTACT"],
		["m59_general_summit_one_block_walked",
			"Y5-GENERAL-SUMMIT-ONE-BLOCK"],
	]
	var contexts := 0
	var results := 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		LocaleManager.set_language(language)
		DataRegistry.reload()
		for branch_choice in range(2):
			var events := _general_events(branch_choice)
			for father_choice in range(2):
				for debt_choice in range(2):
					for summit_choice in range(2):
						var context := "%s W237 branch%d/father%d/debt%d/summit%d" % [
							language, branch_choice, father_choice, debt_choice, summit_choice]
						var locked: Dictionary = _general_lock(branch_choice)
						var state: Dictionary = (locked.get(
							"state", {}) as Dictionary).duplicate(true)
						var selected_choices: Array[int] = [
							father_choice, debt_choice, summit_choice]
						var expected_receipts: Array = [
							(father_receipts[branch_choice] as Array)[father_choice],
							(debt_receipts[branch_choice] as Array)[debt_choice],
							summit_receipts[summit_choice],
						]
						for stage_index in range(3):
							var committed: Dictionary = ROUTE.commit_choice(
								state, events[stage_index], selected_choices[stage_index],
								GENERAL_TURNS[stage_index])
							_expect(bool(committed.get("ok", false)),
								context + " could not commit " + events[stage_index])
							if not bool(committed.get("ok", false)):
								break
							state = (committed.get("state", state) as Dictionary).duplicate(true)
							_assert_w237_predecessor_receipt(
								state, events[stage_index], selected_choices[stage_index],
								expected_receipts[stage_index] as Array, context)
						GameState.start_new_game()
						GameState.chapter5_finale_state = state.duplicate(true)
						GameState.turn = 237
						_expect(bool(locked.get("ok", false)) \
							and GameState.chapter5_finale_next_event_for_turn() == W237_RECORD \
							and GameState.chapter5_finale_ingress_available(W237_RECORD),
							context + " lost its exact W224/W229/W234 receipt ingress")

						var raw_event: Dictionary = DataRegistry.find_event(W237_RECORD)
						var resolved: Dictionary = story.call(
							"_chapter5_finale_event_with_reads", raw_event)
						var read_contract: Dictionary = raw_event.get(
							"chapter5_finale_reads", {}) as Dictionary
						var rows: Array = read_contract.get("texts", [])
						var expected_description := str(raw_event.get("description", ""))
						if rows.size() == 3:
							for source_index in range(3):
								expected_description = expected_description.replace(
									"[[c5read:%d]]" % source_index,
									str((rows[source_index] as Array)[selected_choices[source_index]]))
						_expect(rows.size() == 3 \
							and str(read_contract.get("mode", "")) == "inline_slots" \
							and "[[c5read:" not in expected_description \
							and str(resolved.get("description", "")) == expected_description \
							and _father_trace_source_indices(
								story, expected_description) == [0, 1, 2, 3] \
							and str(resolved.get("background", "")) == "current_housing" \
							and str(resolved.get("portrait", "")) == "player_tired" \
							and not resolved.has("cg"),
							context + " changed its inline receipts, four sources, or home surface")
						var choices: Array = resolved.get("choices", [])
						_expect(choices.size() == 2,
							context + " lost its two final-record choices")
						if choices.size() != 2:
							continue
						var result_sources: Array = []
						for choice_index in range(2):
							var formatted_result: String = str(story.call(
								"_fmt", str((choices[choice_index] as Dictionary).get(
									"result_text", ""))))
							var indices: Array[int] = []
							indices.assign(_father_trace_source_indices(story, formatted_result))
							_expect(indices == [0, 1],
								context + " changed result sources for choice%d" % choice_index)
							result_sources.append(indices)
							_check_w237_result_anchor(
								story, anchors, language, choice_index,
								formatted_result, context)
							results += 1
						_assert_w237_manifest_audio(
							[0, 1, 2, 3], result_sources, context)
						contexts += 1
	_expect(contexts == 80 and results == 160,
		"W237 page-turn audio did not cover exact 80 contexts and 160 results")
	_expect(_same(BGMPlayer.scene_audio_contract(W237_RECORD), {
		"ambience": "apartment",
		"suppress_human_ambience": true,
		"suppress_season_ambience": true,
		"music": {"key": "reckoning", "start_paragraph": 1.0},
		"paragraph_cues": {
			"0": [{"sfx": "phone_vibrate", "volume_db": -8.0}],
			"3": [{"sfx": "phone_vibrate", "volume_db": -8.0}],
		},
	}), "W237 changed its apartment bed, lower-layer suppression, score entrance, or two vibrations")
	LocaleManager.set_language(original_language)
	DataRegistry.reload()
	story.free()


func _assert_w237_predecessor_receipt(
		state: Dictionary, event_id: String, choice_index: int,
		expected: Array, context: String) -> void:
	var receipt: Dictionary = ROUTE.receipt_snapshot_for_event(state, event_id)
	_expect(int(receipt.get("choice_index", -1)) == choice_index \
		and _same(receipt.get("receipt_ids", []), [str(expected[0])]) \
		and _same(receipt.get("document_ids", []), [str(expected[1])]) \
		and (receipt.get("economic_outcome", {}) as Dictionary).is_empty(),
		context + " changed predecessor receipt evidence for " + event_id)


func _check_w237_result_anchor(
		story: Node, anchors: Dictionary, language: String,
		choice_index: int, formatted_result: String, context: String) -> void:
	var sources := formatted_result.split("\n\n")
	var anchor: String = str(story.call(
		"_fmt", str(anchors.get(language, ""))))
	if sources.size() != 2:
		_expect(false,
			context + " choice%d lost its exact two result sources" % choice_index)
		return
	var source_zero := str(sources[0])
	var source_one := str(sources[1])
	if choice_index == 0:
		var anchor_at := source_one.find(anchor)
		_expect(not anchor.is_empty() \
			and formatted_result.count(anchor) == 1 \
			and source_zero.count(anchor) == 0 \
			and source_one.count(anchor) == 1 \
			and anchor_at > 0 \
			and anchor_at + anchor.length() == source_one.length(),
			context + " choice0 lost its unique final source1 page-turn clause")
		return
	_expect(anchor.is_empty() or anchor not in formatted_result,
		context + " choice1 inherited the page-turn action")


func _assert_w237_manifest_audio(
		sources: Array[int], result_sources: Array, context: String) -> void:
	var before: Dictionary = GameState.serialize().duplicate(true)
	var tracked: Array[String] = [
		"phone_notification", "phone_vibrate", "page_turn", "paper_handle",
		"cup_set", "register_scan", "traffic_pass", "pen_write",
		"pen_ballpoint", "door_latch",
	]
	var last_play: Dictionary = {}
	for sound_id: String in tracked:
		last_play[sound_id] = AudioManager._last_sfx_ms.get(sound_id, -1)
	AudioManager.begin_story_audio_event(W237_RECORD)
	for source_index in sources:
		AudioManager.play_scene_paragraph_cues(W237_RECORD, "", source_index)
	for choice_index in range(result_sources.size()):
		for raw_index in result_sources[choice_index] as Array:
			AudioManager.play_scene_result_paragraph_cues(
				W237_RECORD, "", choice_index, int(raw_index))
	var expected: Array[String] = [
		W237_RECORD + "::description:0:0:phone_vibrate",
		W237_RECORD + "::description:3:0:phone_vibrate",
	]
	_expect(AudioManager._story_audio_seen.keys() == expected,
		"%s dispatched wrong W237 manifest cues: %s (expected %s)" % [
			context, JSON.stringify(AudioManager._story_audio_seen), JSON.stringify(expected)])
	for sound_id: String in tracked:
		if sound_id != "phone_vibrate":
			_expect(AudioManager._last_sfx_ms.get(sound_id, -1) == last_play[sound_id],
				context + " played forbidden W237 manifest sound " + sound_id)
	var seen: Dictionary = AudioManager._story_audio_seen.duplicate(true)
	var timestamps: Dictionary = AudioManager._last_sfx_ms.duplicate(true)
	for source_index in sources:
		AudioManager.play_scene_paragraph_cues(W237_RECORD, "", source_index)
	for choice_index in range(result_sources.size()):
		for raw_index in result_sources[choice_index] as Array:
			AudioManager.play_scene_result_paragraph_cues(
				W237_RECORD, "", choice_index, int(raw_index))
	_expect(_same(AudioManager._story_audio_seen, seen) \
		and _same(AudioManager._last_sfx_ms, timestamps),
		context + " replayed W237 manifest cues on repeated paragraph binding")
	_expect(_same(GameState.serialize(), before),
		context + " W237 manifest audio rewrote finale receipts or game state")


func _check_w238_remaining_silence_alignment() -> void:
	var original_language: String = LocaleManager.language
	var story: Node = STORY_MODE.new()
	var source_states: Array[Dictionary] = []
	for guarantee_choice in range(3):
		source_states.append(_father_trace_source_state(1, guarantee_choice))
	var contexts := 0
	var results := 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		LocaleManager.set_language(language)
		DataRegistry.reload()
		for life: String in ["alive", "passed"]:
			var trace_id: String = ALIVE_EVENTS[0] if life == "alive" else PASSED_EVENTS[0]
			for guarantee_choice in range(3):
				var source_state: Dictionary = source_states[guarantee_choice]
				_seed_father_trace_entry(source_state, life, "records_only")
				var trace_commit: Dictionary = GameState.record_chapter5_finale_choice(
					trace_id, PATH_CHOICES[0])
				GameState.turn = 224
				var custody_commit: Dictionary = GameState.record_chapter5_finale_choice(
					ALIVE_EVENTS[1], PATH_CHOICES[1])
				GameState.turn = 227
				var filing_commit: Dictionary = GameState.record_chapter5_finale_choice(
					ALIVE_EVENTS[2], PATH_CHOICES[2])
				GameState.turn = 230
				var verdict_commit: Dictionary = GameState.record_chapter5_finale_choice(
					W230_CAFE, PATH_CHOICES[3])
				GameState.turn = 235
				var notice_commit: Dictionary = GameState.record_chapter5_finale_choice(
					W235_NOTICE, PATH_CHOICES[4])
				GameState.turn = 238
				var context := "%s W238 %s/guarantee%d" % [
					language, life, guarantee_choice]
				var entry: Dictionary = GameState.chapter5_finale_entry_snapshot()
				_expect(bool(trace_commit.get("ok", false)) \
					and bool(custody_commit.get("ok", false)) \
					and bool(filing_commit.get("ok", false)) \
					and bool(verdict_commit.get("ok", false)) \
					and bool(notice_commit.get("ok", false)) \
					and int((entry.get("source_choices", {}) as Dictionary).get(
						"w212_guarantee", -1)) == guarantee_choice \
					and GameState.chapter5_finale_next_event_for_turn() == W238_REMAINING \
					and GameState.chapter5_finale_ingress_available(W238_REMAINING),
					context + " lost its exact causal/finale receipt ingress")
				var guarantee_receipt: Dictionary = CAUSAL_ROUTE.receipt_snapshot(
					source_state, "arc_y5_jaehyuk_guarantee_decision_reference")
				var notice_receipt: Dictionary = ROUTE.receipt_snapshot_for_event(
					GameState.chapter5_finale_state, W235_NOTICE)
				_expect(int(guarantee_receipt.get("choice_index", -1)) == guarantee_choice \
					and int(notice_receipt.get("choice_index", -1)) == 0 \
					and _same(notice_receipt.get("receipt_ids", []), [
						"m59_property_no_executable_contract"]) \
					and _same(notice_receipt.get("document_ids", []), [
						"Y5-PROPERTY-NOT-EXECUTED-NOTICE"]),
					context + " changed its selected guarantee or nontransaction evidence")

				var raw_event: Dictionary = DataRegistry.find_event(W238_REMAINING)
				var resolved: Dictionary = story.call(
					"_chapter5_finale_event_with_reads", raw_event)
				var reads: Dictionary = raw_event.get(
					"chapter5_finale_reads", {}) as Dictionary
				var rows: Array = reads.get("texts", [])
				var expected_description := ""
				if rows.size() == 2 and rows[0] is Array and rows[1] is Array:
					expected_description = str((rows[0] as Array)[guarantee_choice]) \
						+ "\n\n" + str((rows[1] as Array)[0]) \
						+ "\n\n" + str(raw_event.get("description", ""))
				_expect(str(reads.get("mode", "")) == "prepend" \
					and rows.size() == 2 \
					and (rows[0] as Array).size() == 3 \
					and (rows[1] as Array).size() == 1 \
					and str(resolved.get("description", "")) == expected_description \
					and _father_trace_source_indices(
						story, expected_description) == [0, 1, 2, 3] \
					and str(resolved.get("background", "")) == "current_housing" \
					and str(resolved.get("portrait", "")) == "player_tired" \
					and not resolved.has("cg"),
					context + " changed its four-source channel assembly or home surface")
				var choices: Array = resolved.get("choices", [])
				_expect(choices.size() == 2,
					context + " lost its two guarantee-result choices")
				if choices.size() != 2:
					continue
				var result_sources: Array = []
				for choice_index in range(2):
					var formatted_result: String = str(story.call(
						"_fmt", str((choices[choice_index] as Dictionary).get(
							"result_text", ""))))
					var indices: Array[int] = []
					indices.assign(_father_trace_source_indices(story, formatted_result))
					var expected_indices: Array[int] = []
					expected_indices.assign([0] if choice_index == 0 else [0, 1])
					_expect(indices == expected_indices,
						context + " changed result sources for choice%d" % choice_index)
					result_sources.append(indices)
					results += 1
				_assert_w238_manifest_audio([0, 1, 2, 3], result_sources, context)
				contexts += 1
	_expect(contexts == 30 and results == 60,
		"W238 remaining-result silence did not cover exact 30 contexts and 60 results")
	_expect(_same(BGMPlayer.scene_audio_contract(W238_REMAINING), {
		"ambience": "apartment",
		"suppress_human_ambience": true,
		"suppress_season_ambience": true,
		"music": {"key": "reckoning", "start_paragraph": 1.0},
	}), "W238 changed its apartment bed, lower-layer suppression, score entrance, or silence")
	LocaleManager.set_language(original_language)
	DataRegistry.reload()
	story.free()


func _check_w239_father_answer_alignment() -> void:
	var original_language: String = LocaleManager.language
	var story: Node = STORY_MODE.new()
	var raw_anchor_metadata: Variant = W239_ALIVE_NAME_WRITE.get_meta(
		"write_anchors", {})
	_expect(raw_anchor_metadata is Dictionary,
		"W239 alive name-write asset lost its locale anchor dictionary")
	var anchors: Dictionary = raw_anchor_metadata as Dictionary \
		if raw_anchor_metadata is Dictionary else {}
	_expect(anchors.size() == LocaleManager.SUPPORTED_LANGUAGES.size(),
		"W239 alive name-write asset lost the exact locale inventory")
	var pen_lay_tails := {
		"ko": " 펜을 놓았다.",
		"en": " and set down the pen.",
		"ja": "、ペンを置いた。",
		"zh-CN": "，放下笔。",
		"zh-TW": "，放下筆。",
	}
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		_expect(anchors.get(language, "") is String \
			and not str(anchors.get(language, "")).strip_edges().is_empty() \
			and pen_lay_tails.has(language),
			"W239 alive name-write asset has no exact %s clause/tail" % language)

	var contexts := 0
	var results := 0
	var source_state: Dictionary = _father_trace_source_state(1, 0)
	var expected_remaining_receipts: Array[Dictionary] = [
		{
			"receipt_ids": ["m60_guarantee_result_channel_state_preserved"],
			"document_ids": ["Y5-GUARANTEE-RESULT-CHANNEL-STATE"],
		},
		{
			"receipt_ids": ["m60_guarantee_result_self_custody"],
			"document_ids": ["Y5-GUARANTEE-RESULT-SELF-COPY"],
		},
	]
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		LocaleManager.set_language(language)
		DataRegistry.reload()
		for trace_choice in range(3):
			for remaining_choice in range(2):
				_seed_father_trace_entry(source_state, "alive", "records_only")
				var trace_commit: Dictionary = GameState.record_chapter5_finale_choice(
					ALIVE_EVENTS[0], trace_choice)
				GameState.turn = 224
				var custody_commit: Dictionary = GameState.record_chapter5_finale_choice(
					ALIVE_EVENTS[1], PATH_CHOICES[1])
				GameState.turn = 227
				var filing_commit: Dictionary = GameState.record_chapter5_finale_choice(
					ALIVE_EVENTS[2], PATH_CHOICES[2])
				GameState.turn = 230
				var verdict_commit: Dictionary = GameState.record_chapter5_finale_choice(
					W230_CAFE, PATH_CHOICES[3])
				GameState.turn = 235
				var notice_commit: Dictionary = GameState.record_chapter5_finale_choice(
					W235_NOTICE, PATH_CHOICES[4])
				GameState.turn = 238
				var remaining_commit: Dictionary = GameState.record_chapter5_finale_choice(
					W238_REMAINING, remaining_choice)
				GameState.turn = 239
				var context := "%s W239 trace%d/remaining%d" % [
					language, trace_choice, remaining_choice]
				var remaining_receipt: Dictionary = ROUTE.receipt_snapshot_for_event(
					GameState.chapter5_finale_state, W238_REMAINING)
				var expected_remaining: Dictionary = expected_remaining_receipts[
					remaining_choice]
				_expect(bool(trace_commit.get("ok", false)) \
					and bool(custody_commit.get("ok", false)) \
					and bool(filing_commit.get("ok", false)) \
					and bool(verdict_commit.get("ok", false)) \
					and bool(notice_commit.get("ok", false)) \
					and bool(remaining_commit.get("ok", false)) \
					and ROUTE.selected_choice_by_event(
						GameState.chapter5_finale_state, ALIVE_EVENTS[0]) == trace_choice \
					and int(remaining_receipt.get("choice_index", -1)) == remaining_choice \
					and _same(remaining_receipt.get("receipt_ids", []),
						expected_remaining["receipt_ids"]) \
					and _same(remaining_receipt.get("document_ids", []),
						expected_remaining["document_ids"]) \
					and _same(remaining_receipt.get("economic_outcome", {}), {}) \
					and ROUTE.selected_choice_for_stage(
						GameState.chapter5_finale_state, "nontransaction") == 0 \
					and str(GameState.chapter5_finale_entry_snapshot().get(
						"father", {}).get("life", "")) == "alive" \
					and GameState.chapter5_finale_next_event_for_turn() == W239_FATHER_ALIVE \
					and GameState.chapter5_finale_ingress_available(W239_FATHER_ALIVE) \
					and not GameState.chapter5_finale_ingress_available(
						PASSED_EVENTS[6]),
					context + " lost its actual father/W238 receipt ingress")

				var raw_event: Dictionary = DataRegistry.find_event(W239_FATHER_ALIVE)
				var resolved: Dictionary = story.call(
					"_chapter5_finale_event_with_reads", raw_event)
				var reads: Dictionary = raw_event.get(
					"chapter5_finale_reads", {}) as Dictionary
				var rows: Array = reads.get("texts", [])
				var expected_description := ""
				if rows.size() == 2 and rows[0] is Array and rows[1] is Array:
					expected_description = str((rows[0] as Array)[trace_choice]) \
						+ "\n\n" + str((rows[1] as Array)[0]) \
						+ "\n\n" + str(raw_event.get("description", ""))
				_expect(str(reads.get("mode", "")) == "prepend" \
					and rows.size() == 2 \
					and (rows[0] as Array).size() == 3 \
					and (rows[1] as Array).size() == 1 \
					and str(resolved.get("description", "")) == expected_description \
					and _father_trace_source_indices(
						story, expected_description) == [0, 1, 2, 3] \
					and str(resolved.get("background", "")) == "current_housing" \
					and str(resolved.get("portrait", "")) == "player_tired" \
					and not resolved.has("cg"),
					context + " changed its four-source alive-father home surface")
				var choices: Array = resolved.get("choices", [])
				_expect(choices.size() == 3,
					context + " lost its three authored father-answer choices")
				if choices.size() != 3:
					continue
				var result_sources: Array = []
				for choice_index in range(3):
					var formatted_result: String = str(story.call(
						"_fmt", str((choices[choice_index] as Dictionary).get(
							"result_text", ""))))
					var indices: Array[int] = []
					indices.assign(_father_trace_source_indices(story, formatted_result))
					var expected_indices: Array[int] = []
					expected_indices.assign([0] if choice_index == 1 else [0, 1])
					_expect(indices == expected_indices,
						context + " changed result sources for choice%d" % choice_index)
					result_sources.append(indices)
					_check_w239_result_anchor(
						story, anchors, pen_lay_tails, language, choice_index,
						formatted_result, context)
					results += 1
				_assert_w239_manifest_audio([0, 1, 2, 3], result_sources, context)
				contexts += 1
	_expect(contexts == 30 and results == 90,
		"W239 father answer did not cover exact 30 contexts and 90 results")
	_expect(_same(BGMPlayer.scene_audio_contract(W239_FATHER_ALIVE), {
		"ambience": "apartment",
		"suppress_human_ambience": true,
		"suppress_season_ambience": true,
		"music": {"key": "grief", "start_paragraph": 1.0},
	}), "W239 changed its neutral bed, lower-layer suppression, grief entrance, or manifest silence")
	LocaleManager.set_language(original_language)
	DataRegistry.reload()
	story.free()


func _check_w239_result_anchor(
		story: Node, anchors: Dictionary, pen_lay_tails: Dictionary,
		language: String, choice_index: int, formatted_result: String,
		context: String) -> void:
	var anchor: String = str(story.call(
		"_fmt", str(anchors.get(language, ""))))
	var tail: String = str(pen_lay_tails.get(language, ""))
	var sources := formatted_result.split("\n\n")
	if choice_index != 2:
		_expect(not anchor.is_empty() and formatted_result.count(anchor) == 0,
			context + " choice%d gained the c2 name-writing clause" % choice_index)
		return
	var anchor_at := str(sources[0]).find(anchor) if sources.size() == 2 else -1
	_expect(sources.size() == 2 \
		and not anchor.is_empty() and not tail.is_empty() \
		and formatted_result.count(anchor) == 1 \
		and str(sources[0]).count(anchor) == 1 \
		and str(sources[1]).count(anchor) == 0 \
		and anchor_at >= 0 \
		and anchor_at + anchor.length() < str(sources[0]).length() \
		and str(sources[0]).ends_with(anchor + tail) \
		and not str(sources[0]).ends_with(anchor),
		context + " c2 lost the unique name-write boundary before pen lay")


func _check_w239_passed_father_alignment() -> void:
	var original_language: String = LocaleManager.language
	var story: Node = STORY_MODE.new()
	var raw_anchor_metadata: Variant = W239_PASSED_PAPER_ACTIONS.get_meta(
		"paper_anchors", {})
	_expect(raw_anchor_metadata is Dictionary,
		"W239 passed paper asset lost its choice/locale anchor dictionary")
	var anchors: Dictionary = raw_anchor_metadata as Dictionary \
		if raw_anchor_metadata is Dictionary else {}
	_expect(anchors.size() == 2 and anchors.has("0") and anchors.has("2"),
		"W239 passed paper asset must own only c0/c2 actions")
	var insertion_tails := {
		"ko": ", 두 장 사이의 구분지에 오늘 날짜를 적었다.",
		"en": " and wrote today's date on the divider between them.",
		"ja": "、二枚の間の仕切り紙に今日の日付を書いた。",
		"zh-CN": "，在两张纸之间的分隔页上写下今天的日期。",
		"zh-TW": "，在兩張紙之間的分隔頁寫下今天的日期。",
	}
	for choice_key: String in ["0", "2"]:
		var raw_locales: Variant = anchors.get(choice_key, {})
		_expect(raw_locales is Dictionary,
			"W239 passed c%s paper anchors are not a locale map" % choice_key)
		if raw_locales is Dictionary:
			var locales: Dictionary = raw_locales
			_expect(locales.size() == LocaleManager.SUPPORTED_LANGUAGES.size(),
				"W239 passed c%s lost the exact locale inventory" % choice_key)
			for language: String in LocaleManager.SUPPORTED_LANGUAGES:
				_expect(locales.get(language, "") is String \
					and not str(locales.get(language, "")).strip_edges().is_empty() \
					and insertion_tails.has(language),
					"W239 passed c%s has no exact %s paper anchor" % [
						choice_key, language])

	var contexts := 0
	var results := 0
	var source_state: Dictionary = _father_trace_source_state(1, 0)
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		LocaleManager.set_language(language)
		DataRegistry.reload()
		for trace_choice in range(3):
			for remaining_choice in range(2):
				_seed_father_trace_entry(source_state, "passed", "records_only")
				var trace_commit: Dictionary = GameState.record_chapter5_finale_choice(
					PASSED_EVENTS[0], trace_choice)
				GameState.turn = 224
				var custody_commit: Dictionary = GameState.record_chapter5_finale_choice(
					ALIVE_EVENTS[1], PATH_CHOICES[1])
				GameState.turn = 227
				var filing_commit: Dictionary = GameState.record_chapter5_finale_choice(
					ALIVE_EVENTS[2], PATH_CHOICES[2])
				GameState.turn = 230
				var verdict_commit: Dictionary = GameState.record_chapter5_finale_choice(
					W230_CAFE, PATH_CHOICES[3])
				GameState.turn = 235
				var notice_commit: Dictionary = GameState.record_chapter5_finale_choice(
					W235_NOTICE, PATH_CHOICES[4])
				GameState.turn = 238
				var remaining_commit: Dictionary = GameState.record_chapter5_finale_choice(
					W238_REMAINING, remaining_choice)
				GameState.turn = 239
				var context := "%s W239 passed trace%d/remaining%d" % [
					language, trace_choice, remaining_choice]
				var remaining_receipt: Dictionary = ROUTE.receipt_snapshot_for_event(
					GameState.chapter5_finale_state, W238_REMAINING)
				_expect(bool(trace_commit.get("ok", false)) \
					and bool(custody_commit.get("ok", false)) \
					and bool(filing_commit.get("ok", false)) \
					and bool(verdict_commit.get("ok", false)) \
					and bool(notice_commit.get("ok", false)) \
					and bool(remaining_commit.get("ok", false)) \
					and ROUTE.selected_choice_by_event(
						GameState.chapter5_finale_state, PASSED_EVENTS[0]) == trace_choice \
					and int(remaining_receipt.get("choice_index", -1)) == remaining_choice \
					and ROUTE.selected_choice_for_stage(
						GameState.chapter5_finale_state, "nontransaction") == 0 \
					and str(GameState.chapter5_finale_entry_snapshot().get(
						"father", {}).get("life", "")) == "passed" \
					and GameState.chapter5_finale_next_event_for_turn() == W239_FATHER_PASSED \
					and GameState.chapter5_finale_ingress_available(W239_FATHER_PASSED) \
					and not GameState.chapter5_finale_ingress_available(W239_FATHER_ALIVE),
					context + " lost its actual passed-father/W238 receipt ingress")

				var raw_event: Dictionary = DataRegistry.find_event(W239_FATHER_PASSED)
				var resolved: Dictionary = story.call(
					"_chapter5_finale_event_with_reads", raw_event)
				var reads: Dictionary = raw_event.get(
					"chapter5_finale_reads", {}) as Dictionary
				var rows: Array = reads.get("texts", [])
				var expected_description := ""
				if rows.size() == 2 and rows[0] is Array and rows[1] is Array:
					expected_description = str((rows[0] as Array)[trace_choice]) \
						+ "\n\n" + str((rows[1] as Array)[0]) \
						+ "\n\n" + str(raw_event.get("description", ""))
				_expect(str(reads.get("mode", "")) == "prepend" \
					and rows.size() == 2 \
					and (rows[0] as Array).size() == 3 \
					and (rows[1] as Array).size() == 1 \
					and str(resolved.get("description", "")) == expected_description \
					and _father_trace_source_indices(
						story, expected_description) == [0, 1, 2, 3] \
					and str(resolved.get("background", "")) == "current_housing" \
					and str(resolved.get("portrait", "")) == "player_sad" \
					and not resolved.has("cg"),
					context + " changed its four-source passed-father home surface")
				var choices: Array = resolved.get("choices", [])
				_expect(choices.size() == 3,
					context + " lost its three authored passed-father choices")
				if choices.size() != 3:
					continue
				var result_sources: Array = []
				var expected_source_indices: Array = [[0, 1], [0, 1, 2], [0]]
				for choice_index in range(3):
					var formatted_result: String = str(story.call(
						"_fmt", str((choices[choice_index] as Dictionary).get(
							"result_text", ""))))
					var indices: Array[int] = []
					indices.assign(_father_trace_source_indices(story, formatted_result))
					_expect(indices == expected_source_indices[choice_index],
						context + " changed passed result sources for choice%d" % choice_index)
					result_sources.append(indices)
					_check_w239_passed_result_anchor(
						story, anchors, insertion_tails, language, choice_index,
						formatted_result, context)
					results += 1
				_assert_w239_manifest_audio(
					[0, 1, 2, 3], result_sources, context, W239_FATHER_PASSED)
				contexts += 1
	_expect(contexts == 30 and results == 90,
		"W239 passed father did not cover exact 30 contexts and 90 results")
	_expect(_same(BGMPlayer.scene_audio_contract(W239_FATHER_PASSED), {
		"ambience": "apartment",
		"suppress_human_ambience": true,
		"suppress_season_ambience": true,
		"music": {"key": "grief", "start_paragraph": 0.0},
	}), "W239 passed changed its neutral bed, grief entrance, or manifest silence")
	LocaleManager.set_language(original_language)
	DataRegistry.reload()
	story.free()


func _check_w239_passed_result_anchor(
		story: Node, anchors: Dictionary, insertion_tails: Dictionary,
		language: String, choice_index: int, formatted_result: String,
		context: String) -> void:
	var sources := formatted_result.split("\n\n")
	for action_choice in [0, 2]:
		var locale_anchors: Dictionary = anchors.get(str(action_choice), {})
		var anchor: String = str(story.call(
			"_fmt", str(locale_anchors.get(language, ""))))
		if choice_index != action_choice:
			_expect(not anchor.is_empty() and formatted_result.count(anchor) == 0,
				context + " choice%d gained c%d paper action" % [
					choice_index, action_choice])
			continue
		var expected_sources := 2 if choice_index == 0 else 1
		var source0 := str(sources[0]) if sources.size() == expected_sources else ""
		var anchor_at := source0.find(anchor)
		var position_ok := source0.ends_with(anchor) if choice_index == 0 else (
			anchor_at >= 0 and anchor_at + anchor.length() < source0.length() \
			and source0.substr(anchor_at + anchor.length()).begins_with(
				str(insertion_tails.get(language, ""))))
		_expect(sources.size() == expected_sources \
			and not anchor.is_empty() \
			and formatted_result.count(anchor) == 1 \
			and source0.count(anchor) == 1 \
			and anchor_at >= 0 and position_ok,
			context + " c%d lost its unique paper-action boundary" % choice_index)


func _check_w240_general_signature_alignment() -> void:
	var original_language: String = LocaleManager.language
	var story: Node = STORY_MODE.new()
	var raw_anchor_metadata: Variant = W240_GENERAL_SACRIFICE_WRITE.get_meta(
		"write_anchors", {})
	_expect(raw_anchor_metadata is Dictionary,
		"W240 general write asset lost its choice/locale anchor dictionary")
	var anchors: Dictionary = raw_anchor_metadata as Dictionary \
		if raw_anchor_metadata is Dictionary else {}
	_expect(anchors.size() == 2 and anchors.has("0") and anchors.has("1"),
		"W240 general write asset must own exactly c0/c1")
	var later_signature_clauses := {
		"ko": "그 시각을 적고 아래에 자기 이름을 썼다.",
		"en": "He wrote the time and signed his name beneath it.",
		"ja": "その時刻を書き、下に自分の名前を書いた。",
		"zh-CN": "记下那个时间，在下面写上自己的名字。",
		"zh-TW": "他記下那個時間，在下面寫上自己的名字。",
	}
	for choice_key: String in ["0", "1"]:
		var raw_locales: Variant = anchors.get(choice_key, {})
		_expect(raw_locales is Dictionary,
			"W240 general c%s write anchors are not a locale map" % choice_key)
		if raw_locales is Dictionary:
			var locales: Dictionary = raw_locales
			_expect(locales.size() == LocaleManager.SUPPORTED_LANGUAGES.size(),
				"W240 general c%s lost the exact locale inventory" % choice_key)
			for language: String in LocaleManager.SUPPORTED_LANGUAGES:
				_expect(locales.get(language, "") is String \
					and not str(locales.get(language, "")).strip_edges().is_empty() \
					and later_signature_clauses.has(language),
					"W240 general c%s has no exact %s write clause" % [
						choice_key, language])

	var contexts := 0
	var results := 0
	var expected_record_receipts: Array[Dictionary] = [
		{
			"receipt_ids": ["m60_general_record_disposition_people_night"],
			"document_ids": ["Y5-GENERAL-RECORD-DISPOSITION-PEOPLE-NIGHT"],
		},
		{
			"receipt_ids": ["m60_general_record_disposition_price_night"],
			"document_ids": ["Y5-GENERAL-RECORD-DISPOSITION-PRICE-NIGHT"],
		},
	]
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		LocaleManager.set_language(language)
		DataRegistry.reload()
		for record_choice in range(2):
			var context := "%s W240 general record%d" % [language, record_choice]
			var locked: Dictionary = _general_lock(0)
			var state: Dictionary = (locked.get(
				"state", {}) as Dictionary).duplicate(true)
			var events := _general_events(0)
			for stage_index in range(3):
				var committed: Dictionary = ROUTE.commit_choice(
					state, events[stage_index], GENERAL_CHOICES[stage_index],
					GENERAL_TURNS[stage_index])
				_expect(bool(committed.get("ok", false)),
					context + " could not commit " + events[stage_index])
				if not bool(committed.get("ok", false)):
					break
				state = (committed.get("state", state) as Dictionary).duplicate(true)
			var record_commit: Dictionary = ROUTE.commit_choice(
				state, events[3], record_choice, GENERAL_TURNS[3])
			_expect(bool(locked.get("ok", false)) \
				and bool(record_commit.get("ok", false)),
				context + " could not commit its actual W237 record receipt")
			if not bool(record_commit.get("ok", false)):
				continue
			state = (record_commit.get("state", state) as Dictionary).duplicate(true)
			GameState.start_new_game()
			GameState.chapter5_finale_state = state
			GameState.turn = 240
			var record_receipt: Dictionary = ROUTE.receipt_snapshot_for_event(
				state, W237_RECORD)
			var expected_receipt: Dictionary = expected_record_receipts[record_choice]
			_expect(ROUTE.selected_choice_for_stage(
					state, "record_disposition") == record_choice \
				and int(record_receipt.get("choice_index", -1)) == record_choice \
				and _same(record_receipt.get("receipt_ids", []),
					expected_receipt["receipt_ids"]) \
				and _same(record_receipt.get("document_ids", []),
					expected_receipt["document_ids"]) \
				and _same(record_receipt.get("economic_outcome", {}), {}) \
				and GameState.chapter5_finale_next_event_for_turn() \
					== W240_GENERAL_SACRIFICE \
				and GameState.chapter5_finale_ingress_available(
					W240_GENERAL_SACRIFICE),
				context + " lost its actual general-profile W237 receipt ingress")

			var raw_event: Dictionary = DataRegistry.find_event(
				W240_GENERAL_SACRIFICE)
			var resolved: Dictionary = story.call(
				"_chapter5_finale_event_with_reads", raw_event)
			var reads: Dictionary = raw_event.get(
				"chapter5_finale_reads", {}) as Dictionary
			var rows: Array = reads.get("texts", [])
			var expected_description := ""
			if rows.size() == 1 and rows[0] is Array:
				expected_description = str((rows[0] as Array)[record_choice]) \
					+ "\n\n" + str(raw_event.get("description", ""))
			_expect(str(reads.get("mode", "")) == "prepend" \
				and rows.size() == 1 and rows[0] is Array \
				and (rows[0] as Array).size() == 2 \
				and str(resolved.get("description", "")) == expected_description \
				and _father_trace_source_indices(
					story, expected_description) == [0, 1, 2, 3] \
				and str(resolved.get("background", "")) == "current_housing" \
				and str(resolved.get("portrait", "")) == "player_tired" \
				and not resolved.has("cg"),
				context + " changed its one receipt, four sources, or home surface")
			var choices: Array = resolved.get("choices", [])
			_expect(choices.size() == 2,
				context + " lost its two general sacrifice choices")
			if choices.size() != 2:
				continue
			var result_sources: Array = []
			for choice_index in range(2):
				var formatted_result: String = str(story.call(
					"_fmt", str((choices[choice_index] as Dictionary).get(
						"result_text", ""))))
				var indices: Array[int] = []
				indices.assign(_father_trace_source_indices(story, formatted_result))
				_expect(indices == [0, 1],
					context + " changed result sources for choice%d" % choice_index)
				result_sources.append(indices)
				_check_w240_general_result_anchor(
					story, anchors, later_signature_clauses, language,
					choice_index, formatted_result, context)
				results += 1
			_assert_w239_manifest_audio(
				[0, 1, 2, 3], result_sources, context,
				W240_GENERAL_SACRIFICE)
			contexts += 1
	_expect(contexts == 10 and results == 20,
		"W240 general signature did not cover exact 10 contexts and 20 results")
	_expect(_same(BGMPlayer.scene_audio_contract(W240_GENERAL_SACRIFICE), {
		"ambience": "apartment",
		"suppress_human_ambience": true,
		"suppress_season_ambience": true,
		"music": {"key": "reckoning", "start_paragraph": 1.0},
	}), "W240 general changed its neutral bed, suppression, score entrance, or silence")
	LocaleManager.set_language(original_language)
	DataRegistry.reload()
	story.free()


func _check_w240_general_result_anchor(
		story: Node, anchors: Dictionary, later_signature_clauses: Dictionary,
		language: String, choice_index: int, formatted_result: String,
		context: String) -> void:
	var sources := formatted_result.split("\n\n")
	for action_choice in [0, 1]:
		var locale_anchors: Dictionary = anchors.get(str(action_choice), {})
		var anchor: String = str(story.call(
			"_fmt", str(locale_anchors.get(language, ""))))
		if choice_index != action_choice:
			_expect(not anchor.is_empty() and formatted_result.count(anchor) == 0,
				context + " choice%d gained c%d write action" % [
					choice_index, action_choice])
			continue
		var source0 := str(sources[0]) if sources.size() == 2 else ""
		var source1 := str(sources[1]) if sources.size() == 2 else ""
		var anchor_at := source0.find(anchor)
		var endpoint_ok := source0.ends_with(anchor) if choice_index == 0 else (
			anchor_at >= 0 and anchor_at + anchor.length() < source0.length() \
			and source0.find(str(later_signature_clauses.get(language, "")),
				anchor_at + anchor.length()) >= anchor_at + anchor.length())
		_expect(sources.size() == 2 \
			and not anchor.is_empty() \
			and formatted_result.count(anchor) == 1 \
			and source0.count(anchor) == 1 and source1.count(anchor) == 0 \
			and anchor_at >= 0 and endpoint_ok,
			context + " c%d lost its exact write endpoint" % choice_index)


func _check_w240_general_outbound_alignment() -> void:
	var original_language: String = LocaleManager.language
	var story: Node = STORY_MODE.new()
	var raw_anchor_metadata: Variant = W240_GENERAL_OUTBOUND_WRITE.get_meta(
		"write_anchors", {})
	_expect(raw_anchor_metadata is Dictionary,
		"W240 outbound write asset lost its locale anchor dictionary")
	var anchors: Dictionary = raw_anchor_metadata as Dictionary \
		if raw_anchor_metadata is Dictionary else {}
	var anchor_languages: Array = anchors.keys()
	anchor_languages.sort()
	var expected_languages: Array = LocaleManager.SUPPORTED_LANGUAGES.duplicate()
	expected_languages.sort()
	_expect(anchor_languages == expected_languages,
		"W240 outbound write asset lost its exact five-locale inventory")
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		_expect(anchors.get(language, "") is String \
			and not str(anchors.get(language, "")).strip_edges().is_empty(),
			"W240 outbound has no exact %s envelope anchor" % language)

	var contexts := 0
	var results := 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		LocaleManager.set_language(language)
		DataRegistry.reload()
		for sacrifice_choice in range(2):
			for m51_choice in range(2):
				for father_legacy_choice in range(2):
					var context := "%s W240 outbound sacrifice%d/m51%d/father%d" % [
						language, sacrifice_choice, m51_choice,
						father_legacy_choice]
					var source_choices := {
						"m51_minseo_arrival": m51_choice,
						"w211_name_boundary": 0,
						"w220_debt_memory_reconnect": 0,
					}
					var locked: Dictionary = ROUTE.lock_entry(
						ROUTE.default_state(), 224, ROUTE.ROUTE_ID,
						ROUTE.GENERAL_PROFILE_ID, source_choices,
						_father("passed", "records_only"), ROUTE.GENERAL_ACTORS)
					var state: Dictionary = (locked.get(
						"state", {}) as Dictionary).duplicate(true)
					var events := _general_events(0)
					var choices: Array[int] = [
						father_legacy_choice, 0, 1, 1, sacrifice_choice]
					for stage_index in range(choices.size()):
						var committed: Dictionary = ROUTE.commit_choice(
							state, events[stage_index], choices[stage_index],
							GENERAL_TURNS[stage_index])
						_expect(bool(committed.get("ok", false)),
							context + " could not commit " + events[stage_index])
						if not bool(committed.get("ok", false)):
							break
						state = (committed.get(
							"state", state) as Dictionary).duplicate(true)
					GameState.start_new_game()
					GameState.chapter5_finale_state = state
					GameState.turn = 240
					var father_receipt: Dictionary = ROUTE.receipt_snapshot_for_event(
						state, events[0])
					var sacrifice_receipt: Dictionary = ROUTE.receipt_snapshot_for_event(
						state, W240_GENERAL_SACRIFICE)
					var entry: Dictionary = ROUTE.entry_snapshot(state)
					_expect(bool(locked.get("ok", false)) \
						and int(father_receipt.get(
							"choice_index", -1)) == father_legacy_choice \
						and int(sacrifice_receipt.get(
							"choice_index", -1)) == sacrifice_choice \
						and int((entry.get(
							"source_choices", {}) as Dictionary).get(
								"m51_minseo_arrival", -1)) == m51_choice \
						and str(entry.get("profile_id", "")) \
							== ROUTE.GENERAL_PROFILE_ID \
						and GameState.chapter5_finale_next_event_for_turn() \
							== W240_GENERAL_OUTBOUND \
						and GameState.chapter5_finale_ingress_available(
							W240_GENERAL_OUTBOUND),
						context + " lost its actual three-axis general ingress")

					var raw_event: Dictionary = DataRegistry.find_event(
						W240_GENERAL_OUTBOUND)
					var resolved: Dictionary = story.call(
						"_chapter5_finale_event_with_reads", raw_event)
					var reads: Dictionary = raw_event.get(
						"chapter5_finale_reads", {}) as Dictionary
					var rows: Array = reads.get("texts", [])
					var selected: Array[int] = [
						sacrifice_choice, m51_choice, father_legacy_choice]
					var expected_description := ""
					if rows.size() == 3:
						for source_index in range(3):
							expected_description += (
								"\n\n" if not expected_description.is_empty() else "") \
								+ str((rows[source_index] as Array)[
									selected[source_index]])
						expected_description += "\n\n" + str(
							raw_event.get("description", ""))
					_expect(str(reads.get("mode", "")) == "prepend" \
						and rows.size() == 3 \
						and rows[0] is Array and (rows[0] as Array).size() == 2 \
						and rows[1] is Array and (rows[1] as Array).size() == 2 \
						and rows[2] is Array and (rows[2] as Array).size() == 2 \
						and str(resolved.get("description", "")) \
							== expected_description \
						and _father_trace_source_indices(
							story, expected_description) == [0, 1, 2, 3, 4, 5] \
						and str(resolved.get("background", "")) == "current_housing" \
						and str(resolved.get("portrait", "")) == "player_tired" \
						and not resolved.has("cg"),
						context + " changed its three receipts, six sources, or home")
					var event_choices: Array = resolved.get("choices", [])
					_expect(event_choices.size() == 3,
						context + " lost its three outbound choices")
					if event_choices.size() != 3:
						continue
					var result_sources: Array = []
					for choice_index in range(3):
						var formatted_result: String = str(story.call(
							"_fmt", str((event_choices[choice_index] as Dictionary).get(
								"result_text", ""))))
						var indices: Array[int] = []
						indices.assign(_father_trace_source_indices(
							story, formatted_result))
						_expect(indices == [0, 1, 2],
							context + " changed result sources for choice%d" % choice_index)
						result_sources.append(indices)
						_check_w240_outbound_result_anchor(
							story, anchors, language, choice_index,
							formatted_result, context)
						results += 1
					_assert_w239_manifest_audio(
						[0, 1, 2, 3, 4, 5], result_sources, context,
						W240_GENERAL_OUTBOUND)
					contexts += 1
	_expect(contexts == 40 and results == 120,
		"W240 outbound did not cover exact 40 contexts and 120 results")
	_expect(_same(BGMPlayer.scene_audio_contract(W240_GENERAL_OUTBOUND), {
		"ambience": "apartment",
		"suppress_human_ambience": true,
		"suppress_season_ambience": true,
		"music": {"key": "reckoning", "start_paragraph": 0.0},
	}), "W240 outbound changed its bed, suppression, score, or manifest silence")
	LocaleManager.set_language(original_language)
	DataRegistry.reload()
	story.free()


func _check_w240_outbound_result_anchor(
		story: Node, anchors: Dictionary, language: String,
		choice_index: int, formatted_result: String, context: String) -> void:
	var anchor: String = str(story.call(
		"_fmt", str(anchors.get(language, ""))))
	var sources := formatted_result.split("\n\n")
	if choice_index != 1:
		_expect(not anchor.is_empty() and formatted_result.count(anchor) == 0,
			context + " choice%d gained the c1 envelope write" % choice_index)
		return
	var source0 := str(sources[0]) if sources.size() == 3 else ""
	_expect(sources.size() == 3 \
		and not anchor.is_empty() \
		and formatted_result.count(anchor) == 1 \
		and source0.count(anchor) == 1 \
		and str(sources[1]).count(anchor) == 0 \
		and str(sources[2]).count(anchor) == 0 \
		and source0.ends_with(anchor),
		context + " c1 lost its unique final source0 envelope-write endpoint")


func _check_w240_final_week_lights_alignment() -> void:
	var original_language: String = LocaleManager.language
	var story: Node = STORY_MODE.new()
	var raw_dark: Variant = W240_FINAL_WEEK_LIGHTS.get_meta(
		"lights_out_anchors", {})
	var raw_green: Variant = W240_FINAL_WEEK_LIGHTS.get_meta(
		"charging_green_anchors", {})
	_expect(raw_dark is Dictionary and raw_green is Dictionary,
		"W240 final-week light asset lost its two locale anchor maps")
	var dark_anchors: Dictionary = raw_dark as Dictionary \
		if raw_dark is Dictionary else {}
	var green_anchors: Dictionary = raw_green as Dictionary \
		if raw_green is Dictionary else {}
	var expected_languages: Array = LocaleManager.SUPPORTED_LANGUAGES.duplicate()
	expected_languages.sort()
	var dark_languages: Array = dark_anchors.keys()
	var green_languages: Array = green_anchors.keys()
	dark_languages.sort()
	green_languages.sort()
	_expect(dark_languages == expected_languages \
		and green_languages == expected_languages,
		"W240 final-week light asset lost its exact five-locale inventory")
	_expect(str(W240_FINAL_WEEK_LIGHTS.get_meta("dark_cg", "")) \
			== "cg_final_week_phone_dark" \
		and str(W240_FINAL_WEEK_LIGHTS.get_meta("green_cg", "")) \
			== "cg_final_week_phone_green",
		"W240 final-week light asset changed its exact dark/green CG ids")
	var narrative_only_cgs: Array = [
		"cg_final_week_phone_dark", "cg_final_week_phone_green"]
	var expected_gallery_cgs: Array = []
	for raw_cg_id: Variant in ImageRegistry.CG.keys():
		var cg_id := str(raw_cg_id)
		if not narrative_only_cgs.has(cg_id):
			expected_gallery_cgs.append(cg_id)
	var actual_gallery_cgs: Array = ImageRegistry.get_gallery_cg_ids()
	_expect(ImageRegistry.CG.size() == 83 \
		and ImageRegistry.NARRATIVE_ONLY_CG_IDS == narrative_only_cgs \
		and actual_gallery_cgs.size() == 81 \
		and actual_gallery_cgs == expected_gallery_cgs,
		"W240 final-week inserts changed the ordered 81-card CG gallery")
	for cg_id: String in narrative_only_cgs:
		var cg_path := ImageRegistry.get_cg(cg_id)
		_expect(not actual_gallery_cgs.has(cg_id) \
			and not cg_path.is_empty() \
			and cg_path == str(ImageRegistry.CG.get(cg_id, "")) \
			and FileAccess.file_exists(cg_path),
			"W240 final-week narrative CG lost runtime-only availability: " + cg_id)

	var signature_flags: Array[String] = [
		"final_signature_owned",
		"final_signature_collateral",
		"final_signature_people",
	]
	var contexts := 0
	var results := 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		LocaleManager.set_language(language)
		DataRegistry.reload()
		var predecessor: Dictionary = DataRegistry.find_event(
			"arc_final_countdown")
		var predecessor_choices: Array = predecessor.get("choices", [])
		_expect(predecessor_choices.size() == 3,
			language + " W240 final-week predecessor lost its three signatures")
		if predecessor_choices.size() != 3:
			continue
		for signature_choice in range(3):
			var context := "%s W240 final-week signature%d" % [
				language, signature_choice]
			GameState.start_new_game()
			_expect(GameState.apply_choice(predecessor,
				predecessor_choices[signature_choice] as Dictionary),
				context + " could not apply its actual final signature")
			for flag_index in range(signature_flags.size()):
				_expect(bool(GameState.flags.get(
					signature_flags[flag_index], false)) \
					== (flag_index == signature_choice),
					context + " changed its exclusive signature flag")

			var raw_event: Dictionary = DataRegistry.find_event(W240_FINAL_WEEK)
			var description: String = str(story.call(
				"_resolved_story_description", raw_event))
			_expect(_father_trace_source_indices(story, description) \
					== [0, 1, 2, 3] \
				and str(raw_event.get("background", "")) == "current_housing" \
				and str(raw_event.get("portrait", "")) == "player_normal" \
				and not raw_event.has("cg"),
				context + " changed its four-source home opening")
			var choices: Array = raw_event.get("choices", [])
			_expect(choices.size() == 3,
				context + " lost its three final-week choices")
			if choices.size() != 3:
				continue
			var result_sources: Array = []
			for choice_index in range(3):
				var formatted_result: String = str(story.call(
					"_fmt", str((choices[choice_index] as Dictionary).get(
						"result_text", ""))))
				var indices: Array[int] = []
				indices.assign(_father_trace_source_indices(
					story, formatted_result))
				_expect(indices == [0, 1, 2],
					context + " changed result sources for choice%d" % choice_index)
				result_sources.append(indices)
				_check_w240_final_week_result_lights(
					story, dark_anchors, green_anchors, language,
					choice_index, formatted_result, context)
				results += 1
			_assert_w239_manifest_audio(
				[0, 1, 2, 3], result_sources, context, W240_FINAL_WEEK)
			contexts += 1
	_expect(contexts == 15 and results == 45,
		"W240 final-week lights did not cover exact 15 contexts and 45 results")
	_expect(_same(BGMPlayer.scene_audio_contract(W240_FINAL_WEEK), {
		"ambience": "apartment",
		"music": {"key": "reckoning", "start_paragraph": 0.0},
	}), "W240 final-week lights changed the existing bed, score, or silence")
	LocaleManager.set_language(original_language)
	DataRegistry.reload()
	story.free()


func _check_w240_final_week_result_lights(
		story: Node, dark_anchors: Dictionary, green_anchors: Dictionary,
		language: String, choice_index: int, formatted_result: String,
		context: String) -> void:
	var dark_anchor: String = str(story.call(
		"_fmt", str(dark_anchors.get(language, ""))))
	var green_anchor: String = str(story.call(
		"_fmt", str(green_anchors.get(language, ""))))
	var sources := formatted_result.split("\n\n")
	if choice_index != 2:
		_expect(not dark_anchor.is_empty() and not green_anchor.is_empty() \
			and formatted_result.count(dark_anchor) == 0 \
			and formatted_result.count(green_anchor) == 0,
			context + " choice%d gained the c2 light transition" % choice_index)
		return
	var source2 := str(sources[2]) if sources.size() == 3 else ""
	var dark_at := source2.find(dark_anchor)
	var green_at := source2.find(green_anchor)
	var dark_end := dark_at + dark_anchor.length()
	var green_end := green_at + green_anchor.length()
	var gap := source2.substr(dark_end, green_at - dark_end) \
		if dark_at >= 0 and green_at >= dark_end else "not-adjacent"
	_expect(sources.size() == 3 \
		and not dark_anchor.is_empty() and not green_anchor.is_empty() \
		and formatted_result.count(dark_anchor) == 1 \
		and formatted_result.count(green_anchor) == 1 \
		and str(sources[0]).count(dark_anchor) == 0 \
		and str(sources[0]).count(green_anchor) == 0 \
		and str(sources[1]).count(dark_anchor) == 0 \
		and str(sources[1]).count(green_anchor) == 0 \
		and source2.count(dark_anchor) == 1 \
		and source2.count(green_anchor) == 1 \
		and dark_at >= 0 and dark_end <= green_at \
		and dark_end < green_end \
		and gap.strip_edges().is_empty() \
		and green_end < source2.length(),
		context + " c2 lost its ordered source2 dark-to-green sentence endpoints")


func _assert_w239_manifest_audio(
		sources: Array[int], result_sources: Array, context: String,
		event_id: String = W239_FATHER_ALIVE) -> void:
	var before: Dictionary = GameState.serialize().duplicate(true)
	var tracked: Array[String] = [
		"phone_notification", "phone_vibrate", "page_turn", "paper_handle",
		"pen_ballpoint", "pen_write", "document_scan", "register_scan",
		"cup_set", "traffic_pass", "door_latch",
	]
	var last_play: Dictionary = {}
	for sound_id: String in tracked:
		last_play[sound_id] = AudioManager._last_sfx_ms.get(sound_id, -1)
	AudioManager.begin_story_audio_event(event_id)
	for source_index in sources:
		AudioManager.play_scene_paragraph_cues(
			event_id, "", source_index)
	for choice_index in range(result_sources.size()):
		for raw_index in result_sources[choice_index] as Array:
			AudioManager.play_scene_result_paragraph_cues(
				event_id, "", choice_index, int(raw_index))
	_expect(AudioManager._story_audio_seen.is_empty(),
		context + " retained a paragraph-entry cue before the name-write boundary")
	for sound_id: String in tracked:
		_expect(AudioManager._last_sfx_ms.get(sound_id, -1) == last_play[sound_id],
			context + " played forbidden W239 manifest sound " + sound_id)
	var timestamps: Dictionary = AudioManager._last_sfx_ms.duplicate(true)
	for source_index in sources:
		AudioManager.play_scene_paragraph_cues(
			event_id, "", source_index)
	for choice_index in range(result_sources.size()):
		for raw_index in result_sources[choice_index] as Array:
			AudioManager.play_scene_result_paragraph_cues(
				event_id, "", choice_index, int(raw_index))
	_expect(AudioManager._story_audio_seen.is_empty() \
		and _same(AudioManager._last_sfx_ms, timestamps),
		context + " replayed a W239 manifest cue on repeated paragraph binding")
	_expect(_same(GameState.serialize(), before),
		context + " W239 manifest audio rewrote finale receipts or game state")


func _assert_w238_manifest_audio(
		sources: Array[int], result_sources: Array, context: String) -> void:
	var before: Dictionary = GameState.serialize().duplicate(true)
	var tracked: Array[String] = [
		"phone_notification", "phone_vibrate", "page_turn", "paper_handle",
		"cup_set", "register_scan", "traffic_pass", "pen_write",
		"pen_ballpoint", "door_latch",
	]
	var last_play: Dictionary = {}
	for sound_id: String in tracked:
		last_play[sound_id] = AudioManager._last_sfx_ms.get(sound_id, -1)
	AudioManager.begin_story_audio_event(W238_REMAINING)
	for source_index in sources:
		AudioManager.play_scene_paragraph_cues(W238_REMAINING, "", source_index)
	for choice_index in range(result_sources.size()):
		for raw_index in result_sources[choice_index] as Array:
			AudioManager.play_scene_result_paragraph_cues(
				W238_REMAINING, "", choice_index, int(raw_index))
	_expect(AudioManager._story_audio_seen.is_empty(),
		context + " retained a physical cue for channel or abstract ledger prose")
	for sound_id: String in tracked:
		_expect(AudioManager._last_sfx_ms.get(sound_id, -1) == last_play[sound_id],
			context + " played forbidden W238 manifest sound " + sound_id)
	var timestamps: Dictionary = AudioManager._last_sfx_ms.duplicate(true)
	for source_index in sources:
		AudioManager.play_scene_paragraph_cues(W238_REMAINING, "", source_index)
	for choice_index in range(result_sources.size()):
		for raw_index in result_sources[choice_index] as Array:
			AudioManager.play_scene_result_paragraph_cues(
				W238_REMAINING, "", choice_index, int(raw_index))
	_expect(AudioManager._story_audio_seen.is_empty() \
		and _same(AudioManager._last_sfx_ms, timestamps),
		context + " replayed a W238 manifest cue on repeated paragraph binding")
	_expect(_same(GameState.serialize(), before),
		context + " W238 manifest audio rewrote finale receipts or game state")


func _father_trace_source_state(
		meeting_choice: int, guarantee_choice: int = 0) -> Dictionary:
	var locked: Dictionary = CAUSAL_ROUTE.lock_entry(
		CAUSAL_ROUTE.default_state(), 195, "투자형", true, true, 2_000_000_000.0)
	var state: Dictionary = (locked.get("state", {}) as Dictionary).duplicate(true)
	var committed := 0
	for turn in range(195, 221):
		for same_turn_index in range(3):
			var event_id: String = CAUSAL_ROUTE.next_event_for_turn(state, turn)
			if event_id.is_empty():
				break
			var choice_index := meeting_choice if event_id == "arc_y5_three_in_room_decision" \
				else (guarantee_choice if event_id \
					== "arc_y5_jaehyuk_guarantee_decision_reference" else 0)
			var result: Dictionary = CAUSAL_ROUTE.commit_choice(state, event_id, choice_index, turn)
			_expect(bool(result.get("ok", false)), "father audio source could not commit %s" % event_id)
			if not bool(result.get("ok", false)):
				return state
			state = (result.get("state", state) as Dictionary).duplicate(true)
			committed += 1
			_expect(same_turn_index < 2, "father audio source exposed more than three same-turn roots")
	_expect(CAUSAL_ROUTE.route_complete(state) and committed == (19 if meeting_choice == 1 else 18) \
		and CAUSAL_ROUTE.selected_choice(state, "arc_y5_three_in_room_decision") == meeting_choice \
		and CAUSAL_ROUTE.selected_choice(
			state, "arc_y5_jaehyuk_guarantee_decision_reference") == guarantee_choice \
		and CAUSAL_ROUTE.receipt_snapshot(state, "arc_y5_room_consent_receipt").is_empty() == (meeting_choice != 1),
		"father audio source lost W212/W219 exact choices or conditional W220 receipt")
	return state


func _seed_father_trace_entry(source: Dictionary, life: String, contact_mode: String) -> void:
	GameState.start_new_game()
	GameState.chapter5_causal_state = source.duplicate(true)
	if life == "passed":
		GameState.flags["father_passed"] = true
	if contact_mode != "records_only":
		GameState.flags["father_crisis_contact_" + contact_mode] = true
	GameState.turn = 221
	_expect(GameState.prepare_chapter5_finale_route_entry(), "father audio could not prepare its real wrapper entry")
	var entry: Dictionary = GameState.chapter5_finale_entry_snapshot()
	_expect(_same(entry.get("father", {}), {"life": life, "contact_mode": contact_mode}) \
		and _same(entry.get("source_choices", {}), {
			"m55_decision": CAUSAL_ROUTE.selected_choice(source, "arc_y5_three_in_room_decision"),
			"w212_guarantee": CAUSAL_ROUTE.selected_choice(
				source, "arc_y5_jaehyuk_guarantee_decision_reference"),
			"w215_final_door": 0,
		}), "father audio entry rewrote exact life, contact, or predecessor choices")


func _father_trace_source_indices(story: Node, text: String) -> Array[int]:
	var page_data: Dictionary = story.call("_story_page_data", text)
	var indices: Array[int] = []
	for raw_index in page_data.get("source_indices", []):
		var source_index := int(raw_index)
		if source_index not in indices:
			indices.append(source_index)
	return indices


func _assert_father_trace_audio(
		event_id: String, sources: Array[int], result_sources: Array,
		result_sounds: Array[String], context: String) -> void:
	var before: Dictionary = GameState.serialize().duplicate(true)
	var tracked: Array[String] = ["phone_notification", "page_turn", "paper_handle", "cup_set", "register_scan", "traffic_pass", "pen_write", "pen_ballpoint", "door_latch"]
	var last_play: Dictionary = {}
	for sound_id: String in tracked:
		last_play[sound_id] = AudioManager._last_sfx_ms.get(sound_id, -1)
	AudioManager.begin_story_audio_event(event_id)
	for source_index in sources:
		AudioManager.play_scene_paragraph_cues(event_id, "", source_index)
	var expected: Array[String] = []
	for choice_index in range(result_sources.size()):
		expected.append("%s::result:%d:0:0:%s" % [event_id, choice_index, result_sounds[choice_index]])
		for raw_index in result_sources[choice_index] as Array:
			AudioManager.play_scene_result_paragraph_cues(event_id, "", choice_index, int(raw_index))
	_expect(AudioManager._story_audio_seen.keys() == expected,
		"%s dispatched wrong cues: %s (expected %s)" % [context, JSON.stringify(AudioManager._story_audio_seen), JSON.stringify(expected)])
	for sound_id: String in tracked:
		if sound_id not in result_sounds:
			_expect(AudioManager._last_sfx_ms.get(sound_id, -1) == last_play[sound_id], context + " played forbidden " + sound_id)
	var seen: Dictionary = AudioManager._story_audio_seen.duplicate(true)
	var timestamps: Dictionary = AudioManager._last_sfx_ms.duplicate(true)
	for source_index in sources:
		AudioManager.play_scene_paragraph_cues(event_id, "", source_index)
	for choice_index in range(result_sources.size()):
		for raw_index in result_sources[choice_index] as Array:
			AudioManager.play_scene_result_paragraph_cues(event_id, "", choice_index, int(raw_index))
	_expect(_same(AudioManager._story_audio_seen, seen) and _same(AudioManager._last_sfx_ms, timestamps), context + " replayed cues on a repeated paragraph bind")
	_expect(_same(GameState.serialize(), before), context + " audio rewrote game state, life/contact, or predecessor receipts")


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


func _general_lock(branch_choice: int = 1) -> Dictionary:
	return ROUTE.lock_entry(
		ROUTE.default_state(), 224, ROUTE.ROUTE_ID, ROUTE.GENERAL_PROFILE_ID,
		_general_source_choices(branch_choice), _father("passed", "records_only"),
		ROUTE.GENERAL_ACTORS)


func _general_state_through(branch_choice: int, count: int) -> Dictionary:
	var events := _general_events(branch_choice)
	var state := (_general_lock(branch_choice).get(
		"state", {}) as Dictionary).duplicate(true)
	for index in range(mini(count, events.size())):
		var result := ROUTE.commit_choice(
			state, events[index], GENERAL_CHOICES[index], GENERAL_TURNS[index])
		if not bool(result.get("ok", false)):
			_expect(false, "general fixture could not commit %s" % events[index])
			break
		state = (result.get("state", state) as Dictionary).duplicate(true)
	return state


func _general_events(branch_choice: int) -> Array[String]:
	return GENERAL_VOICE_EVENTS.duplicate() \
		if branch_choice == 0 else GENERAL_CAFE_EVENTS.duplicate()


func _general_source_choices(branch_choice: int = 1) -> Dictionary:
	return {
		"m51_minseo_arrival": 1,
		"w211_name_boundary": 0,
		"w220_debt_memory_reconnect": branch_choice,
	}


func _seed_general_sources(
		valid: bool = true, branch_choice: int = 1,
		assets: float = 2_500_000_000.0) -> void:
	GameState.start_new_game("김민준", "지방_상경", "투자형")
	GameState.money = assets
	GameState.flags["father_passed"] = true
	GameState.flags["chapter5_general_minseo_arrival_1"] = true
	GameState.flags["arc_y5_general_name_boundary_exact_seen"] = true
	GameState.flags["chapter5_general_name_boundary_0"] = true
	GameState.flags["arc_y5_general_debt_memory_reconnect_seen"] = true
	GameState.flags[
		"chapter5_general_debt_memory_reconnect_%d" % branch_choice] = true
	GameState.flags["arc_endgame_sixmonths_seen"] = true
	GameState.event_log = [
		{"event_id": "arc_minseo_03_arrival", "choice_index": 1, "turn": 203},
		{
			"event_id": "arc_y5_general_name_boundary_exact",
			"choice_index": 0,
			"turn": 211,
		},
		{
			"event_id": "arc_y5_general_debt_memory_reconnect",
			"choice_index": branch_choice,
			"turn": 220,
		},
	]
	if not valid:
		GameState.event_log.pop_back()


func _seed_general_w220_prechoice() -> void:
	GameState.start_new_game("김민준", "지방_상경", "투자형")
	GameState.money = 2_500_000_000.0
	GameState.flags["father_passed"] = true
	GameState.flags["chapter5_general_minseo_arrival_1"] = true
	GameState.flags["arc_y5_general_name_boundary_exact_seen"] = true
	GameState.flags["chapter5_general_name_boundary_0"] = true
	GameState.event_log = [
		{"event_id": "arc_minseo_03_arrival", "choice_index": 1, "turn": 203},
		{
			"event_id": "arc_y5_general_name_boundary_exact",
			"choice_index": 0,
			"turn": 211,
		},
	]


func _seed_general_w211_prechoice() -> void:
	GameState.start_new_game("김민준", "지방_상경", "투자형")
	GameState.money = 2_500_000_000.0
	GameState.flags["father_passed"] = true
	GameState.flags["chapter5_general_minseo_arrival_1"] = true
	GameState.event_log = [
		{"event_id": "arc_minseo_03_arrival", "choice_index": 1, "turn": 203},
	]


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
