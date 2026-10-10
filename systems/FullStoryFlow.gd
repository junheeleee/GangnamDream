extends RefCounted
## Story-owned full-game flow and the unchanged explicit W1-W8/W1-W12 previews.
## Existing v4 flags own these receipts; old unmarked saves are never enrolled.
## Mutators return true when the exact request succeeds OR was already completed
## identically. A duplicate never mutates state; false means stop, not fall back.

const BuildFlavorScript := preload("res://systems/BuildFlavor.gd")
const DemoCoreLoopV2Script := preload("res://systems/DemoCoreLoopV2.gd")
const STATE_KEY := "full_story_flow_preview"
const PROFILE := "full_story_flow_preview"
const PROFILE_THIRD_MONTH := "full_story_flow_third_month_preview"
const PROFILE_FULL := "full_story_flow"
const SCHEMA_VERSION := 1
const PREVIEW_ARG := "--full-story-flow-preview"
const THIRD_MONTH_ARG := "--full-story-flow-third-month-preview"
const MAX_TURN := 8
const THIRD_MONTH_MAX_TURN := 12
# SaveManager.save_game retains this many event-log entries, not the full run.
const SAVED_EVENT_LOG_LIMIT := 100
const ROUTINE_SOURCE := "automatic_livelihood_recovery"
const APPROVED_UNEMPLOYED := {"money": 70000, "health": -1, "mental": 1}
const APPROVED_EMPLOYED := {"work_performance": 1, "mental": 1}
const APPROVED_RECOVERY := {"health": 1, "mental": 3}


static func initialize_fresh_preview() -> bool:
	if owns_session():
		return valid_session()
	if not OS.get_cmdline_user_args().has(PREVIEW_ARG) \
			or not _environment_allowed() or not _pristine_start():
		return false
	# Only a fresh, explicitly opted-in candidate gets the longer horizon.
	# A loaded eight-week marker returned above and is never promoted by args.
	var profile := PROFILE_THIRD_MONTH \
		if OS.get_cmdline_user_args().has(THIRD_MONTH_ARG) else PROFILE
	_store({
		"schema": SCHEMA_VERSION,
		"profile": profile,
		"start_turn": 1,
		"last_completed_turn": 0,
		"chain": {},
		"read_receipts": {},
		"routine_receipts": {},
		"completed_turns": {},
	})
	return true


static func initialize_fresh_run() -> bool:
	if owns_session():
		return is_full_run() and valid_session()
	# Explicit development entries retain their original initializer and horizon.
	if OS.get_cmdline_user_args().has(PREVIEW_ARG) \
			or OS.get_cmdline_user_args().has(THIRD_MONTH_ARG) \
			or not _environment_allowed(PROFILE_FULL) or not _pristine_start(PROFILE_FULL):
		return false
	_store({
		"schema": SCHEMA_VERSION,
		"profile": PROFILE_FULL,
		"start_turn": 1,
		"last_completed_turn": 0,
		"chain": {},
		"read_receipts": {},
		"routine_receipts": {},
		"completed_turns": {},
		"activity_receipts": {},
	})
	return true


static func owns_session() -> bool:
	# Even an invalid marker owns the failure. Never reinterpret a damaged
	# development checkpoint as an ordinary retail/AP run.
	return GameState.flags.has(STATE_KEY)


static func snapshot() -> Dictionary:
	var raw: Variant = GameState.flags.get(STATE_KEY, null)
	return (raw as Dictionary).duplicate(true) if raw is Dictionary else {}


static func valid_session() -> bool:
	var state := snapshot()
	return owns_session() \
		and _environment_allowed(str(state.get("profile", ""))) and _valid_state(state)


static func is_full_run() -> bool:
	return owns_session() and snapshot().get("profile", null) == PROFILE_FULL


static func last_turn() -> int:
	return _last_turn_for_state(snapshot())


static func _last_turn_for_state(state: Dictionary) -> int:
	match state.get("profile", null):
		PROFILE:
			return MAX_TURN
		PROFILE_THIRD_MONTH:
			return THIRD_MONTH_MAX_TURN
		PROFILE_FULL:
			return GameState.RUN_TURN_LIMIT
	return 0


static func pending_activity_id() -> String:
	var pending: Variant = GameState.flags.get("open_racetrack_after_story", false)
	return "racetrack" if pending is bool and pending else ""


static func begin_activity(activity_id: String) -> bool:
	if not is_full_run() or not valid_session() or activity_id != "racetrack" \
			or GameState.is_game_over or pending_activity_id() != activity_id:
		return false
	var state := snapshot()
	if not _current_uncompleted_turn(state) \
			or not _activity_source_closed(state, GameState.turn):
		return false
	var chain: Dictionary = state["chain"]
	if chain.is_empty() or not bool(chain["closed"]) \
			or (state["routine_receipts"] as Dictionary).has(str(GameState.turn)):
		return false
	var receipts: Dictionary = state.get("activity_receipts", {})
	var turn_key := str(GameState.turn)
	if receipts.has(turn_key):
		return str((receipts[turn_key] as Dictionary).get("status", "")) == "pending"
	receipts[turn_key] = {
		"turn": GameState.turn, "activity_id": activity_id,
		"source_event_id": "race_first_visit", "choice_index": 1,
		"status": "pending", "rounds": 0, "net": 0,
	}
	state["activity_receipts"] = receipts
	_store(state)
	return true


static func close_activity(activity_id: String, rounds: int, net: float) -> bool:
	# Racetrack already owns every wager and payout. This only closes its handoff.
	# Zero completed races can still include the existing tipster's real expense.
	if not is_full_run() or not valid_session() or activity_id != "racetrack" \
			or rounds < 0 or not is_finite(net) or net != floor(net):
		return false
	var state := snapshot()
	if not _current_uncompleted_turn(state):
		return false
	var receipts: Dictionary = state.get("activity_receipts", {})
	var turn_key := str(GameState.turn)
	if not receipts.has(turn_key):
		return false
	var receipt: Dictionary = receipts[turn_key]
	var status := "closed" if rounds > 0 else "cancelled"
	if receipt["status"] != "pending":
		return receipt["status"] == status \
			and _integer_equals(receipt["rounds"], rounds) \
			and float(receipt["net"]) == net
	if pending_activity_id() != activity_id:
		return false
	receipt["status"] = status
	receipt["rounds"] = rounds
	receipt["net"] = net
	receipts[turn_key] = receipt
	state["activity_receipts"] = receipts
	_store(state)
	GameState.flags.erase("open_racetrack_after_story")
	return true


static func at_boundary() -> bool:
	return owns_session() and GameState.turn > last_turn()


static func begin_chain(event_ids: Array) -> bool:
	if not valid_session():
		return false
	var state := snapshot()
	if not _current_uncompleted_turn(state) or event_ids.is_empty() \
			or event_ids.size() > 64:
		return false
	var roots: Array = []
	for raw_id in event_ids:
		if not raw_id is String or str(raw_id).is_empty() \
				or roots.has(raw_id) or DataRegistry.find_event(raw_id).is_empty():
			return false
		roots.append(raw_id)
	var chain: Dictionary = state["chain"]
	if not chain.is_empty() and chain["roots"] == roots:
		return true
	if not chain.is_empty() and not bool(chain["closed"]):
		return false
	if (state["routine_receipts"] as Dictionary).has(str(GameState.turn)):
		return false
	for root_id in roots:
		if _read_record(state, GameState.turn, str(root_id)) != {}:
			return false
	state["chain"] = {
		"turn": GameState.turn,
		"roots": roots,
		"pending_event_ids": roots.duplicate(),
		"closed_results": [],
		"closed": false,
	}
	_store(state)
	return true


static func append_causal_ingress(
		source_event_id: String, choice_index: int, event_id: String) -> bool:
	# W210's return call and father's document are separate same-week roots.
	# Only the actual causal ledger can authorize the latter after the call.
	if not is_full_run() or not valid_session() \
			or GameState.turn != 210 or GameState.is_game_over \
			or source_event_id == event_id \
			or not GameState.chapter5_causal_is_owned_event(source_event_id) \
			or not GameState.chapter5_causal_is_owned_event(event_id) \
			or GameState.chapter5_causal_next_event_for_turn() != event_id \
			or not GameState.chapter5_causal_receipt_matches(
				source_event_id, choice_index, GameState.turn) \
			or _applied_choice_witness(source_event_id, choice_index, GameState.turn).is_empty() \
			or DataRegistry.find_event(event_id).is_empty():
		return false
	var state := snapshot()
	if not _current_uncompleted_turn(state) \
			or (state["routine_receipts"] as Dictionary).has(str(GameState.turn)) \
			or not _read_record(state, GameState.turn, event_id).is_empty():
		return false
	var chain: Dictionary = state["chain"]
	if chain.is_empty() or bool(chain["closed"]):
		return false
	var pending: Array = chain["pending_event_ids"]
	var roots: Array = chain["roots"]
	if pending.is_empty() or pending.front() != source_event_id:
		return false
	if roots.has(event_id) or pending.has(event_id):
		return roots.count(event_id) == 1 and roots.back() == event_id \
			and pending == [source_event_id, event_id]
	if pending != [source_event_id] or roots.size() >= 64:
		return false
	roots.append(event_id)
	pending.append(event_id)
	_store(state)
	return true


static func append_finale_ingress(
		source_event_id: String, choice_index: int, event_id: String) -> bool:
	# The existing finale ledger, not authored follow_up_event, owns the second
	# W240 root. Admit it while the source's applied result is still unread.
	if not is_full_run() or not valid_session() \
			or GameState.turn != GameState.RUN_TURN_LIMIT or GameState.is_game_over \
			or source_event_id == event_id \
			or not GameState.chapter5_finale_is_owned_event(source_event_id) \
			or not GameState.chapter5_finale_is_owned_event(event_id) \
			or GameState.chapter5_finale_next_event_for_turn() != event_id \
			or not GameState.chapter5_finale_receipt_matches(
				source_event_id, choice_index, GameState.turn) \
			or _applied_choice_witness(source_event_id, choice_index, GameState.turn).is_empty() \
			or DataRegistry.find_event(event_id).is_empty():
		return false
	var state := snapshot()
	if not _current_uncompleted_turn(state) \
			or (state["routine_receipts"] as Dictionary).has(str(GameState.turn)) \
			or not _read_record(state, GameState.turn, event_id).is_empty():
		return false
	var chain: Dictionary = state["chain"]
	if chain.is_empty() or bool(chain["closed"]):
		return false
	var pending: Array = chain["pending_event_ids"]
	var roots: Array = chain["roots"]
	if pending.is_empty() or pending.front() != source_event_id:
		return false
	if roots.has(event_id) or pending.has(event_id):
		# A cold source result may ask again. Only the identical still-unread
		# source -> next pair is idempotent; it cannot reopen a consumed result.
		return roots.count(event_id) == 1 and roots.back() == event_id \
			and pending == [source_event_id, event_id]
	if pending != [source_event_id] or roots.size() >= 64:
		return false
	roots.append(event_id)
	pending.append(event_id)
	_store(state)
	return true


static func close_result(
		event_id: String, choice_index: int, expression: bool = false) -> bool:
	if not valid_session():
		return false
	var state := snapshot()
	if not _current_uncompleted_turn(state):
		return false
	var existing := _read_record(state, GameState.turn, event_id)
	if not existing.is_empty():
		return int(existing["choice_index"]) == choice_index \
			and bool(existing["expression"]) == expression
	var chain: Dictionary = state["chain"]
	if chain.is_empty() or bool(chain["closed"]):
		return false
	var pending: Array = chain["pending_event_ids"]
	if pending.is_empty() or str(pending.front()) != event_id:
		return false
	var event: Dictionary = DataRegistry.find_event(event_id)
	var choices: Variant = _event_choices(event)
	if not choices is Array or choice_index < 0 \
			or choice_index >= (choices as Array).size():
		return false
	var choice: Dictionary = choices[choice_index]
	if GameState.is_expression_choice(choice) != expression \
			or (not expression and not _applied_choice_exists(
				event_id, choice_index, GameState.turn)):
		return false
	var applied: Dictionary = {}
	if is_full_run() and not expression:
		applied = _applied_choice_witness(event_id, choice_index, GameState.turn)
		if applied.is_empty():
			return false
	var follow_up := _follow_up_id(choice)
	if not follow_up.is_empty() \
			and (DataRegistry.find_event(follow_up).is_empty() \
				or _read_record(state, GameState.turn, follow_up) != {} \
				or pending.has(follow_up)):
		return false
	var receipt := {
		"turn": GameState.turn,
		"event_id": event_id,
		"choice_index": choice_index,
		"expression": expression,
	}
	if not applied.is_empty():
		receipt["applied_tuple"] = applied["tuple"]
		receipt["applied_sequence"] = applied["sequence"]
	if is_full_run() and event.has("year_scene_year"):
		# Bind the actual curated scene, not the catalog's placeholder option.
		receipt["year_scene"] = (choice.get("year_scene", {}) as Dictionary).duplicate(true)
	var turn_key := str(GameState.turn)
	var reads: Dictionary = state["read_receipts"]
	var turn_reads: Array = reads.get(turn_key, [])
	turn_reads.append(receipt.duplicate(true))
	reads[turn_key] = turn_reads
	(chain["closed_results"] as Array).append(receipt.duplicate(true))
	pending.pop_front()
	if not follow_up.is_empty():
		pending.push_front(follow_up)
	_store(state)
	return true


static func close_chain() -> bool:
	# The reader calls this only after StoryMode's real queue has been exhausted.
	# Separately tracking authored follow-ups prevents a root result from serving
	# as proof that its still-unread follow-up was completed.
	if not valid_session():
		return false
	var state := snapshot()
	if not _current_uncompleted_turn(state):
		return false
	var chain: Dictionary = state["chain"]
	if chain.is_empty() or not (chain["pending_event_ids"] as Array).is_empty():
		return false
	if bool(chain["closed"]):
		return true
	chain["closed"] = true
	_store(state)
	return true


static func ready_to_advance() -> bool:
	if not valid_session():
		return false
	var state := snapshot()
	if not _current_uncompleted_turn(state) or GameState.is_game_over \
			or not pending_activity_id().is_empty():
		return false
	var chain: Dictionary = state["chain"]
	if not chain.is_empty() and not bool(chain["closed"]):
		return false
	return _required_reads_closed(state, GameState.turn)


static func _required_reads_closed(state: Dictionary, at_turn: int) -> bool:
	# These are actual product readers, not entry flags. Other weeks retain the
	# existing MainGame arc selector; an empty week needs no invented choice.
	if at_turn == 1:
		return not _read_record(state, 1, "story_flashforward").is_empty() \
			and not _read_record(state, 1, "chapter_card_33").is_empty()
	if at_turn == 4:
		return not _read_record(state, 4, "arc_temptation_01").is_empty()
	if at_turn == 8:
		var consequence_id := ""
		if bool(GameState.flags.get("lent_account", false)):
			consequence_id = "arc_temptation_fallout"
		elif bool(GameState.flags.get("kept_clean_hands", false)):
			consequence_id = "arc_temptation_clean"
		return not consequence_id.is_empty() \
			and not _read_record(state, 8, consequence_id).is_empty()
	if at_turn == 9 and state.get("profile", null) in [PROFILE_THIRD_MONTH, PROFILE_FULL]:
		return not _read_record(state, 9, "arc_intro_04_hyunsu").is_empty() \
			and not _read_record(state, 9, "arc_chapter1_close").is_empty()
	return true


static func apply_background_for_turn(expected_turn: int) -> bool:
	if GameState.turn != expected_turn or not ready_to_advance():
		return false
	var state := snapshot()
	var receipts: Dictionary = state["routine_receipts"]
	var turn_key := str(expected_turn)
	if receipts.has(turn_key):
		return str((receipts[turn_key] as Dictionary).get("status", "")) == "applied"
	var effects := _approved_background_effects()
	if effects.is_empty() or not _valid_background_snapshot(_background_stat_snapshot()):
		return false
	var job_id := str(GameState.current_job.get("id", ""))
	if not GameState.current_job.is_empty() \
			and (not GameState.current_job.get("id", null) is String or job_id.is_empty()):
		return false
	var receipt := {
		"turn": expected_turn,
		"source": ROUTINE_SOURCE,
		"job_id": job_id,
		"status": "reserved",
		"units": [],
		"effects": {},
	}
	# Reserve before stats_changed can re-enter a consumer. A reserved/corrupt
	# receipt fails closed; it never licenses a second application.
	receipts[turn_key] = receipt.duplicate(true)
	_store(state)
	var total: Dictionary = {}
	for kind in ["livelihood", "recovery"]:
		var requested: Dictionary = effects[kind]
		var before := _background_stat_snapshot()
		GameState.apply_effects(requested)
		var after := _background_stat_snapshot()
		var actual: Dictionary = {}
		for key in requested:
			actual[key] = after[key] - before[key]
			total[key] = total.get(key, 0) + actual[key]
		(receipt["units"] as Array).append({
			"kind": kind,
			"requested_effects": requested.duplicate(true),
			"effects": actual,
			"before": before,
			"after": after,
		})
	receipt["effects"] = total
	receipt["status"] = "applied"
	# Preserve any independently emitted flags. Only this owned marker is written.
	state = snapshot()
	(state["routine_receipts"] as Dictionary)[turn_key] = receipt
	_store(state)
	return true


static func complete_turn(expected_turn: int) -> bool:
	if not valid_session() or expected_turn < 1 or expected_turn > last_turn() \
			or GameState.turn != expected_turn + 1 \
			or not pending_activity_id().is_empty():
		return false
	var state := snapshot()
	var completed: Dictionary = state["completed_turns"]
	if completed.has(str(expected_turn)):
		return int(state["last_completed_turn"]) == expected_turn
	if int(state["last_completed_turn"]) != expected_turn - 1:
		return false
	var routines: Dictionary = state["routine_receipts"]
	if not routines.has(str(expected_turn)) \
			or str((routines[str(expected_turn)] as Dictionary).get(
				"status", "")) != "applied":
		return false
	var chain: Dictionary = state["chain"]
	if not chain.is_empty() and not bool(chain["closed"]):
		return false
	completed[str(expected_turn)] = {
		"turn": expected_turn, "next_turn": expected_turn + 1,
	}
	state["last_completed_turn"] = expected_turn
	state["chain"] = {}
	_store(state)
	return true


static func _environment_allowed(profile: String = PROFILE) -> bool:
	if BuildFlavorScript.build_flavor_id() != "full" \
			or DemoCoreLoopV2Script.requested():
		return false
	if profile == PROFILE_FULL:
		return true
	if profile not in [PROFILE, PROFILE_THIRD_MONTH]:
		return false
	var qa_namespace := OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	var pattern := RegEx.new()
	return pattern.compile(
		"^GangnamDream_StoryNameplateQA_[0-9a-f]{32}$") == OK \
		and pattern.search(qa_namespace) != null \
		and bool(ProjectSettings.get_setting(
			"application/config/use_custom_user_dir", false)) \
		and str(ProjectSettings.get_setting(
			"application/config/custom_user_dir_name", "")) == qa_namespace \
		and OS.get_user_data_dir().get_file() == qa_namespace


static func _pristine_start(profile: String = PROFILE) -> bool:
	return GameState.turn == 1 and GameState.week_of_month == 1 \
		and GameState.month == 1 and GameState.year == 2026 \
		and GameState.age == 33 and not GameState.is_game_over \
		and GameState.events_seen == 0 and GameState.event_log.is_empty() \
		and _pristine_flags(profile) and GameState.current_job.is_empty() \
		and float(GameState.monthly_income) == 0.0 \
		and GameState.pending_story_queue.is_empty() \
		and GameState.pending_weekly_commitment.is_empty() \
		and GameState.weekly_commitments.is_empty() \
		and GameState.action_records_this_week.is_empty() \
		and not GameState.returning_from_story


static func _pristine_flags(profile: String) -> bool:
	if profile != PROFILE_FULL:
		return GameState.flags.is_empty()
	# Match start_new_game's exact NG+ producer; do not erase its rewards or
	# accept unrelated flags. Existing owned saves never enter this fresh check.
	var expected: Dictionary = {}
	var previous_runs := int(MetaProgression.data.get("total_runs", 0))
	if previous_runs >= 1:
		expected["is_repeat_run"] = true
	if previous_runs >= 4:
		expected["is_veteran_run"] = true
	if GameState.flags.size() != expected.size():
		return false
	for key in expected:
		var value: Variant = GameState.flags.get(key, null)
		if not value is bool or not value:
			return false
	return true


static func _store(state: Dictionary) -> void:
	GameState.flags[STATE_KEY] = state.duplicate(true)


static func _current_uncompleted_turn(state: Dictionary) -> bool:
	return GameState.turn >= 1 and GameState.turn <= _last_turn_for_state(state) \
		and GameState.turn == int(state["last_completed_turn"]) + 1


static func _read_record(state: Dictionary, at_turn: int, event_id: String) -> Dictionary:
	var reads: Dictionary = state.get("read_receipts", {})
	for raw_record in reads.get(str(at_turn), []):
		if raw_record is Dictionary \
				and str((raw_record as Dictionary).get("event_id", "")) == event_id:
			return raw_record as Dictionary
	return {}


static func _applied_choice_exists(event_id: String, choice_index: int, at_turn: int) -> bool:
	for raw_record in GameState.event_log:
		if not raw_record is Dictionary:
			continue
		var record: Dictionary = raw_record
		if str(record.get("event_id", "")) == event_id \
				and _integer_equals(record.get("turn", null), at_turn) \
				and _integer_equals(record.get("choice_index", null), choice_index):
			return true
	return false


static func _applied_choice_witness(
		event_id: String, choice_index: int, at_turn: int) -> Dictionary:
	# events_seen is the existing cumulative non-expression choice counter. The
	# retained log may start later after a cold load; its absolute ordinal does not.
	var log_size := GameState.event_log.size()
	if GameState.events_seen < log_size:
		return {}
	var witness: Dictionary = {}
	for log_index in range(log_size):
		var raw: Variant = GameState.event_log[log_index]
		if not raw is Dictionary:
			continue
		var record: Dictionary = raw
		if record.get("event_id", null) != event_id \
				or not _integer_equals(record.get("turn", null), at_turn) \
				or not _integer_equals(record.get("choice_index", null), choice_index):
			continue
		if not witness.is_empty():
			return {}
		witness = {
			"tuple": {"turn": at_turn, "event_id": event_id, "choice_index": choice_index},
			"sequence": GameState.events_seen - log_size + log_index + 1,
		}
	return witness


static func _read_application_valid(record: Dictionary, at_turn: int) -> bool:
	if bool(record.get("expression", false)):
		return true
	var event_id := str(record.get("event_id", ""))
	var choice_index := int(record.get("choice_index", -1))
	if not is_full_run():
		return _applied_choice_exists(event_id, choice_index, at_turn)
	var raw_tuple: Variant = record.get("applied_tuple", null)
	var sequence: Variant = record.get("applied_sequence", null)
	if not raw_tuple is Dictionary or (raw_tuple as Dictionary).size() != 3 \
			or not _integer_equals((raw_tuple as Dictionary).get("turn", null), at_turn) \
			or (raw_tuple as Dictionary).get("event_id", null) != event_id \
			or not _integer_equals((raw_tuple as Dictionary).get("choice_index", null), choice_index) \
			or not _bounded_integer(sequence, 1, GameState.events_seen):
		return false
	var witness := _applied_choice_witness(event_id, choice_index, at_turn)
	if not witness.is_empty():
		return _integer_equals(sequence, int(witness["sequence"]))
	# A conflicting retained entry is never replaced by a historical assertion.
	if _applied_choice_exists(event_id, choice_index, at_turn):
		return false
	var last: Variant = snapshot().get("last_completed_turn", null)
	if not _bounded_integer(last, 0, GameState.RUN_TURN_LIMIT) \
			or at_turn > int(last) or GameState.event_log.size() < SAVED_EVENT_LOG_LIMIT:
		return false
	var lost_prefix := GameState.events_seen - GameState.event_log.size()
	if lost_prefix <= 0 or int(sequence) > lost_prefix:
		return false
	# Only the genuinely truncated prefix is historical. Current/open-chain
	# results and entries still inside the retained suffix require the real log.
	var previous_turn := at_turn
	for raw in GameState.event_log:
		if not raw is Dictionary:
			return false
		var logged: Dictionary = raw
		if not _bounded_integer(logged.get("turn", null), previous_turn, GameState.turn) \
				or not logged.get("event_id", null) is String \
				or str(logged["event_id"]).is_empty() \
				or not _bounded_integer(logged.get("choice_index", null), 0, 2147483647):
			return false
		previous_turn = int(logged["turn"])
	return true


static func _follow_up_id(choice: Dictionary) -> String:
	var required: Variant = choice.get("follow_up_requires_flags", [])
	if not required is Array:
		return ""
	for raw_flag in required as Array:
		if not raw_flag is String or str(raw_flag).is_empty() \
				or not bool(GameState.flags.get(raw_flag, false)):
			return ""
	return str(choice.get("follow_up_event", ""))


static func _event_choices(event: Dictionary) -> Array:
	if is_full_run() and event.has("year_scene_year"):
		var year_index: Variant = event.get("year_scene_year", null)
		return GameState.build_year_scene_choices(int(year_index)) \
			if _bounded_integer(year_index, 1, 5) else []
	var choices: Variant = event.get("choices", [])
	return choices if choices is Array else []


static func _activity_source_closed(state: Dictionary, at_turn: int) -> bool:
	var read := _read_record(state, at_turn, "race_first_visit")
	return not read.is_empty() and _integer_equals(read.get("choice_index", null), 1) \
		and read.get("expression", null) is bool and not bool(read["expression"]) \
		and _read_application_valid(read, at_turn)


static func _valid_activity_receipts(state: Dictionary, last: int) -> bool:
	if state.get("profile", null) != PROFILE_FULL:
		return true
	var raw_receipts: Variant = state.get("activity_receipts", {})
	if not raw_receipts is Dictionary:
		return false
	var receipts: Dictionary = raw_receipts
	for raw_key in receipts:
		if not raw_key is String or not str(raw_key).is_valid_int() \
				or str(int(raw_key)) != raw_key:
			return false
		var at_turn := int(raw_key)
		var raw_receipt: Variant = receipts[raw_key]
		if at_turn < 1 or at_turn > mini(last + 1, GameState.RUN_TURN_LIMIT) \
				or not raw_receipt is Dictionary \
				or not _activity_source_closed(state, at_turn):
			return false
		var receipt: Dictionary = raw_receipt
		if not _integer_equals(receipt.get("turn", null), at_turn) \
				or receipt.get("activity_id", null) != "racetrack" \
				or receipt.get("source_event_id", null) != "race_first_visit" \
				or not _integer_equals(receipt.get("choice_index", null), 1) \
				or not _bounded_integer(receipt.get("rounds", null), 0, 2147483647):
			return false
		var net: Variant = receipt.get("net", null)
		if not (net is int or net is float) or not is_finite(float(net)) \
				or float(net) != floor(float(net)):
			return false
		var rounds := int(receipt["rounds"])
		match receipt.get("status", null):
			"pending":
				var chain: Dictionary = state["chain"]
				if at_turn != last + 1 or GameState.turn != at_turn \
						or rounds != 0 or float(net) != 0.0 \
						or pending_activity_id() != "racetrack" \
						or chain.is_empty() or not bool(chain["closed"]) \
						or (state["routine_receipts"] as Dictionary).has(raw_key):
					return false
			"closed":
				if rounds <= 0 or not pending_activity_id().is_empty():
					return false
			"cancelled":
				if rounds != 0 or not pending_activity_id().is_empty():
					return false
			_:
				return false
	return true


static func _calendar_values_match(profile: String, at_turn: int, week: Variant,
		month: Variant, year: Variant, age: Variant) -> bool:
	if profile == PROFILE_FULL:
		var month_index := int((at_turn - 1) / 4.0)
		var years_elapsed := int(month_index / 12.0)
		return at_turn >= 1 and at_turn <= GameState.RUN_TURN_LIMIT + 1 \
			and _integer_equals(week, (at_turn - 1) % 4 + 1) \
			and _integer_equals(month, month_index % 12 + 1) \
			and _integer_equals(year, 2026 + years_elapsed) \
			and _integer_equals(age, 33 + years_elapsed)
	if profile in [PROFILE, PROFILE_THIRD_MONTH]:
		var preview_limit := MAX_TURN if profile == PROFILE else THIRD_MONTH_MAX_TURN
		return at_turn >= 1 and at_turn <= preview_limit + 1 \
			and week == (at_turn - 1) % 4 + 1 \
			and month == 1 + int((at_turn - 1) / 4.0) and year == 2026 and age == 33
	return false


static func _approved_background_effects() -> Dictionary:
	# Reuse the approved balance data, never V2's plan/controller/receipt engine.
	var routine: Variant = DataRegistry.demo_core_loop_v2.get("routine", {})
	if not routine is Dictionary:
		return {}
	var options: Variant = (routine as Dictionary).get("options", {})
	if not options is Dictionary:
		return {}
	var livelihood: Variant = (options as Dictionary).get("livelihood", {})
	var recovery: Variant = (options as Dictionary).get("recovery", {})
	if not livelihood is Dictionary or not recovery is Dictionary:
		return {}
	var branches: Variant = (livelihood as Dictionary).get("weekly_effects", {})
	var recovery_effects: Variant = (recovery as Dictionary).get("weekly_effects", {})
	if not branches is Dictionary \
			or not _effect_values_match((branches as Dictionary).get(
				"unemployed", null), APPROVED_UNEMPLOYED) \
			or not _effect_values_match((branches as Dictionary).get(
				"employed", null), APPROVED_EMPLOYED) \
			or not _effect_values_match(recovery_effects, APPROVED_RECOVERY):
		return {}
	var employment_key := "unemployed" \
		if GameState.current_job.is_empty() else "employed"
	return {
		"livelihood": ((branches as Dictionary)[employment_key] as Dictionary).duplicate(true),
		"recovery": (recovery_effects as Dictionary).duplicate(true),
	}


static func _background_stat_snapshot() -> Dictionary:
	return {
		"money": float(GameState.money), "health": int(GameState.health),
		"mental": int(GameState.mental),
		"work_performance": int(GameState.work_performance),
	}


static func _effect_values_match(raw: Variant, expected: Dictionary) -> bool:
	if not raw is Dictionary or (raw as Dictionary).size() != expected.size():
		return false
	for key in expected:
		if not _integer_equals((raw as Dictionary).get(key, null), int(expected[key])):
			return false
	return true


static func _integer_equals(value: Variant, expected: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) \
		and float(value) == float(expected)


static func _bounded_integer(value: Variant, minimum: int, maximum: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) \
		and float(value) == floor(float(value)) \
		and float(value) >= minimum and float(value) <= maximum


static func _valid_routine_receipt(receipt: Dictionary, at_turn: int) -> bool:
	if not _integer_equals(receipt.get("turn", null), at_turn) \
			or receipt.get("source", null) != ROUTINE_SOURCE \
			or not receipt.get("job_id", null) is String \
			or receipt.get("status", null) != "applied" \
			or not receipt.get("effects", null) is Dictionary \
			or not receipt.get("units", null) is Array \
			or (receipt["units"] as Array).size() != 2:
		return false
	var approved: Dictionary = APPROVED_UNEMPLOYED \
		if str(receipt["job_id"]).is_empty() else APPROVED_EMPLOYED
	var total: Dictionary = {}
	var previous_after: Dictionary = {}
	for unit_index in range(2):
		var raw_unit: Variant = (receipt["units"] as Array)[unit_index]
		if not raw_unit is Dictionary:
			return false
		var unit: Dictionary = raw_unit
		var kind := "livelihood" if unit_index == 0 else "recovery"
		var requested: Dictionary = approved if unit_index == 0 else APPROVED_RECOVERY
		if unit.get("kind", null) != kind \
				or not _effect_values_match(unit.get("requested_effects", null), requested) \
				or not unit.get("effects", null) is Dictionary \
				or not _valid_background_snapshot(unit.get("before", null)) \
				or not _valid_background_snapshot(unit.get("after", null)):
			return false
		var before: Dictionary = unit["before"]
		var after: Dictionary = unit["after"]
		var actual: Dictionary = unit["effects"]
		if actual.size() != requested.size() \
				or (unit_index > 0 and before != previous_after):
			return false
		for key in before:
			var delta := int(requested.get(key, 0))
			var expected := float(before[key]) + delta
			if key != "money":
				expected = clampf(expected, 0.0, 100.0)
			if not _integer_equals(after[key], int(expected)):
				return false
			if requested.has(key):
				var actual_delta := int(after[key]) - int(before[key])
				if not _integer_equals(actual.get(key, null), actual_delta):
					return false
				total[key] = int(total.get(key, 0)) + actual_delta
		previous_after = after
	return _effect_values_match(receipt["effects"], total)


static func _valid_background_snapshot(raw: Variant) -> bool:
	if not raw is Dictionary or (raw as Dictionary).size() != 4:
		return false
	var values: Dictionary = raw
	var cash: Variant = values.get("money", null)
	if not (cash is int or cash is float) or not is_finite(float(cash)) \
			or float(cash) != floor(float(cash)):
		return false
	for key in ["health", "mental", "work_performance"]:
		if not _bounded_integer(values.get(key, null), 0, 100):
			return false
	return true


static func _valid_state(state: Dictionary) -> bool:
	var final_turn := _last_turn_for_state(state)
	if state.get("profile", null) == PROFILE_FULL \
			and (not _bounded_integer(GameState.turn, 1, GameState.RUN_TURN_LIMIT + 1) \
				or (GameState.flags.has("open_racetrack_after_story") \
					and not GameState.flags["open_racetrack_after_story"] is bool)):
		return false
	if final_turn == 0 or GameState.turn < 1 or GameState.turn > final_turn + 1 \
			or not _calendar_values_match(str(state.get("profile", "")), GameState.turn,
				GameState.week_of_month, GameState.month, GameState.year, GameState.age) \
			or not _integer_equals(state.get("schema", null), SCHEMA_VERSION) \
			or not _integer_equals(state.get("start_turn", null), 1) \
			or not _bounded_integer(state.get("last_completed_turn", null), 0, final_turn):
		return false
	for key in ["chain", "read_receipts", "routine_receipts", "completed_turns"]:
		if not state.get(key, null) is Dictionary:
			return false
	var last := int(state["last_completed_turn"])
	var routines: Dictionary = state["routine_receipts"]
	var completed: Dictionary = state["completed_turns"]
	if completed.size() != last or routines.size() < last \
			or routines.size() > last + 1:
		return false
	for at_turn in range(1, last + 1):
		var raw: Variant = completed.get(str(at_turn), null)
		if not raw is Dictionary \
				or not _integer_equals((raw as Dictionary).get("turn", null), at_turn) \
				or not _integer_equals((raw as Dictionary).get("next_turn", null), at_turn + 1) \
				or not routines.has(str(at_turn)):
			return false
	for raw_key in routines:
		if not raw_key is String or not str(raw_key).is_valid_int():
			return false
		var at_turn := int(raw_key)
		if str(at_turn) != raw_key or at_turn < 1 or at_turn > final_turn \
				or at_turn > last + 1:
			return false
		var raw: Variant = routines[raw_key]
		if not raw is Dictionary:
			return false
		if not _valid_routine_receipt(raw as Dictionary, at_turn):
			return false
	var reads: Dictionary = state["read_receipts"]
	var applied_sequences: Dictionary = {}
	for raw_key in reads:
		if not raw_key is String or not str(raw_key).is_valid_int() \
				or str(int(raw_key)) != raw_key:
			return false
		var at_turn := int(raw_key)
		var raw_records: Variant = reads[raw_key]
		if at_turn < 1 or at_turn > mini(last + 1, final_turn) \
				or not raw_records is Array or (raw_records as Array).size() > 64:
			return false
		var seen: Array = []
		for raw_record in raw_records as Array:
			if not _valid_read_record(raw_record, at_turn):
				return false
			var event_id := str((raw_record as Dictionary)["event_id"])
			if seen.has(event_id):
				return false
			seen.append(event_id)
			if state.get("profile", null) == PROFILE_FULL \
					and not bool((raw_record as Dictionary)["expression"]):
				var sequence := int((raw_record as Dictionary)["applied_sequence"])
				if applied_sequences.has(sequence):
					return false
				applied_sequences[sequence] = true
	for at_turn in range(1, last + 1):
		if not _required_reads_closed(state, at_turn):
			return false
	var chain: Dictionary = state["chain"]
	if not chain.is_empty() and not _valid_chain(chain, state, last + 1):
		return false
	if not _valid_activity_receipts(state, last):
		return false
	if routines.has(str(last + 1)) \
			and (not _required_reads_closed(state, last + 1) \
				or (not chain.is_empty() and not bool(chain["closed"]))):
		return false
	if GameState.turn == last + 1:
		return GameState.turn >= 1 and GameState.turn <= final_turn + 1
	# A save may observe the existing calendar producer after advance_calendar
	# but before complete_turn. The already-applied routine licenses completion,
	# not another calendar advance or another income deposit.
	return last < final_turn and GameState.turn == last + 2 \
		and routines.has(str(last + 1)) \
		and (chain.is_empty() or bool(chain["closed"]))


static func _valid_read_record(raw: Variant, at_turn: int) -> bool:
	if not raw is Dictionary:
		return false
	var record: Dictionary = raw
	if not _integer_equals(record.get("turn", null), at_turn) \
			or not record.get("event_id", null) is String \
			or not record.get("expression", null) is bool:
		return false
	var event: Dictionary = DataRegistry.find_event(record["event_id"])
	var choices: Variant = _event_choices(event)
	if not choices is Array or not _bounded_integer(
			record.get("choice_index", null), 0, (choices as Array).size() - 1):
		return false
	var choice_index := int(record["choice_index"])
	if is_full_run() and event.has("year_scene_year"):
		var year_scene: Variant = choices[choice_index].get("year_scene", null)
		var saved_year_scene: Variant = record.get("year_scene", null)
		if not year_scene is Dictionary or (year_scene as Dictionary).size() != 2 \
				or not saved_year_scene is Dictionary \
				or (saved_year_scene as Dictionary).size() != 2 \
				or not _bounded_integer((year_scene as Dictionary).get("year", null), 1, 5) \
				or not _integer_equals((saved_year_scene as Dictionary).get("year", null),
					int((year_scene as Dictionary)["year"])) \
				or not (saved_year_scene as Dictionary).get("scene_id", null) is String \
				or (saved_year_scene as Dictionary)["scene_id"] \
					!= (year_scene as Dictionary).get("scene_id", null) \
				or GameState.get_year_scene_selection(int(event["year_scene_year"])) \
					!= str((year_scene as Dictionary).get("scene_id", "")):
			return false
	return GameState.is_expression_choice(choices[choice_index]) == record["expression"] \
		and _read_application_valid(record, at_turn)


static func _valid_chain(chain: Dictionary, state: Dictionary, at_turn: int) -> bool:
	if not _integer_equals(chain.get("turn", null), at_turn) \
			or not chain.get("closed", null) is bool:
		return false
	for key in ["roots", "pending_event_ids", "closed_results"]:
		if not chain.get(key, null) is Array or (chain[key] as Array).size() > 64:
			return false
	var pending: Array = (chain["roots"] as Array).duplicate()
	if pending.is_empty():
		return false
	var unique_roots: Array = []
	for raw_id in pending:
		if not raw_id is String or str(raw_id).is_empty() \
				or unique_roots.has(raw_id) or DataRegistry.find_event(raw_id).is_empty():
			return false
		unique_roots.append(raw_id)
	for raw_record in chain["closed_results"] as Array:
		if not _valid_read_record(raw_record, at_turn) or pending.is_empty():
			return false
		var record: Dictionary = raw_record
		if pending.pop_front() != record["event_id"] \
				or _read_record(state, at_turn, str(record["event_id"])) != record:
			return false
		var event: Dictionary = DataRegistry.find_event(record["event_id"])
		var choice: Dictionary = _event_choices(event)[int(record["choice_index"])]
		var follow_up := _follow_up_id(choice)
		if not follow_up.is_empty():
			pending.push_front(follow_up)
	return pending == chain["pending_event_ids"] \
		and (not bool(chain["closed"]) or pending.is_empty())
