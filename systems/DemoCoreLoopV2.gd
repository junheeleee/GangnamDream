extends RefCounted
## ORDER-57: 8주 수직 단면의 월간 계획·약속·놓친 길 저장 계약.
## 기존 240주 편성기는 사람 GO 전까지 그대로 두고 명시적 테스트 런만 활성화한다.

const SCHEMA := 2
const PROTOTYPE_MAX_WEEK := 8
const RELATIONSHIP_STAGE_ORDER := [
	"unmet",
	"met",
	"opening",
	"player_reached_out",
	"shared_commitment",
	"friction",
	"repair_or_distance",
	"reciprocal",
	"romantic_intent",
	"committed",
	"closed",
]
# Trigger-only story roots owned by this data-driven router. Keeping the
# literal IDs here also lets the dead-arc audit prove that these events have a
# runtime consumer even though their schedule lives in JSON.
const OWNED_STORY_ROOTS := ["v2_hyunsu_player_reachout"]
const ENABLE_ARGS := [
	"--core-loop-v2",
	"core-loop-v2",
	"--qa=core-loop-v2",
	"qa=core-loop-v2",
]

static func contract() -> Dictionary:
	return DataRegistry.demo_core_loop_v2

static func requested() -> bool:
	if bool(GameState.core_loop_v2_state.get("enabled", false)):
		return true
	for raw_arg in OS.get_cmdline_user_args():
		if str(raw_arg).strip_edges().to_lower() in ENABLE_ARGS:
			return true
	return false

static func initialize_for_run(force: bool = false) -> bool:
	if not force and not requested():
		return false
	var state := _normalized_state(GameState.core_loop_v2_state)
	state["enabled"] = true
	GameState.core_loop_v2_state = state
	return true

static func disable_for_run() -> void:
	var state := _normalized_state(GameState.core_loop_v2_state)
	state["enabled"] = false
	state["active_bundle"] = ""
	state["active_kind"] = ""
	state["active_turn"] = 0
	state["action_result_ready"] = false
	GameState.core_loop_v2_state = state

static func is_active() -> bool:
	return bool(GameState.core_loop_v2_state.get("enabled", false)) \
		and GameState.turn >= 1 and GameState.turn <= PROTOTYPE_MAX_WEEK

static func is_prototype_complete() -> bool:
	var state := _normalized_state(GameState.core_loop_v2_state)
	if not bool(state.get("enabled", false)):
		return false
	if bool(state.get("prototype_complete", false)):
		return true
	# Saves made by the first prototype could already be on week nine after
	# completing week eight. Recover those runs into the recap instead of
	# silently dropping them into the legacy director.
	return GameState.turn > PROTOTYPE_MAX_WEEK \
		and (state.get("completed_turns", []) as Array).has(PROTOTYPE_MAX_WEEK)

static func mark_prototype_complete() -> bool:
	var state := _normalized_state(GameState.core_loop_v2_state)
	if not bool(state.get("enabled", false)) \
			or GameState.turn <= PROTOTYPE_MAX_WEEK \
			or not (state.get("completed_turns", []) as Array).has(PROTOTYPE_MAX_WEEK):
		return false
	state["prototype_complete"] = true
	state["prototype_completed_at_turn"] = GameState.turn
	state["active_bundle"] = ""
	state["active_kind"] = ""
	state["active_turn"] = 0
	state["action_result_ready"] = false
	GameState.core_loop_v2_state = state
	return true

static func completion_snapshot() -> Dictionary:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var completed_turns: Array = state.get("completed_turns", [])
	var kept: Array = []
	for month_index in range(1, month_for_turn(PROTOTYPE_MAX_WEEK) + 1):
		var plan := plan_for_month(month_index)
		var raw_schedule: Variant = plan.get("schedule", {})
		if not raw_schedule is Dictionary:
			continue
		var weeks: Array[int] = []
		for raw_week in (raw_schedule as Dictionary):
			var week := int(raw_week)
			if week >= 1 and week <= PROTOTYPE_MAX_WEEK:
				weeks.append(week)
		weeks.sort()
		for week in weeks:
			if not completed_turns.has(week):
				continue
			var bundle_id := str((raw_schedule as Dictionary).get(str(week), ""))
			if bundle_id.is_empty():
				continue
			kept.append({
				"month": month_index,
				"week": week,
				"bundle_id": bundle_id,
			})

	var forgone: Array = []
	for raw_record in state.get("forgone", []):
		if not raw_record is Dictionary:
			continue
		var record: Dictionary = raw_record
		if int(record.get("month", 0)) < 1 \
				or int(record.get("month", 0)) > month_for_turn(PROTOTYPE_MAX_WEEK):
			continue
		forgone.append(record.duplicate(true))

	var temptation_branch := "unresolved"
	if bool(GameState.flags.get("lent_account", false)):
		if bool(GameState.flags.get("escaped_dirty_money", false)):
			temptation_branch = "returned_money"
		elif bool(GameState.flags.get("fell_to_darkness", false)):
			temptation_branch = "accepted_more"
		else:
			temptation_branch = "lent_account"
	elif bool(GameState.flags.get("kept_clean_hands", false)):
		temptation_branch = "refused_offer"

	return {
		"kept": kept,
		"forgone": forgone,
		"decline_receipts":
			(state.get("decline_receipts", []) as Array).duplicate(true),
		"routine_receipts":
			(state.get("routine_receipts", {}) as Dictionary).duplicate(true),
		"month_summaries":
			(state.get("month_summaries", {}) as Dictionary).duplicate(true),
		"player_initiated": (state.get("player_initiated", []) as Array).duplicate(),
		"relationship_stages":
			(state.get("relationship_stages", {}) as Dictionary).duplicate(true),
		"temptation_branch": temptation_branch,
		"completed_at_turn": int(state.get("prototype_completed_at_turn", 0)),
	}

static func month_for_turn(turn: int) -> int:
	return maxi(1, int(floor(float(maxi(turn, 1) - 1) / 4.0)) + 1)

static func month_spec(month_index: int = -1) -> Dictionary:
	var target_month := month_index if month_index > 0 else month_for_turn(GameState.turn)
	for raw_month in contract().get("months", []):
		if raw_month is Dictionary and int(raw_month.get("month", 0)) == target_month:
			return (raw_month as Dictionary).duplicate(true)
	return {}

static func bundle(bundle_id: String) -> Dictionary:
	var bundles: Variant = contract().get("scene_bundles", {})
	if not bundles is Dictionary:
		return {}
	var value: Variant = (bundles as Dictionary).get(bundle_id, {})
	return (value as Dictionary).duplicate(true) if value is Dictionary else {}

static func available_offer_ids(month_index: int = -1) -> Array[String]:
	var spec := month_spec(month_index)
	var result: Array[String] = []
	for raw_id in spec.get("offers", []):
		var bundle_id := str(raw_id)
		var offer := bundle(bundle_id)
		if offer.is_empty() or not _bundle_requirement_met(offer):
			continue
		result.append(bundle_id)
	return result

static func plan_for_month(month_index: int = -1) -> Dictionary:
	var target_month := month_index if month_index > 0 else month_for_turn(GameState.turn)
	var plans: Variant = GameState.core_loop_v2_state.get("plans", {})
	if not plans is Dictionary:
		return {}
	var plan: Variant = (plans as Dictionary).get(str(target_month), {})
	return (plan as Dictionary).duplicate(true) if plan is Dictionary else {}

static func needs_plan(month_index: int = -1) -> bool:
	return plan_for_month(month_index).is_empty()

static func routine_options() -> Dictionary:
	var raw_routine: Variant = contract().get("routine", {})
	if not raw_routine is Dictionary:
		return {}
	var raw_options: Variant = (raw_routine as Dictionary).get("options", {})
	return (raw_options as Dictionary).duplicate(true) \
		if raw_options is Dictionary else {}

static func default_routines() -> Dictionary:
	var options := routine_options()
	var ids: Array[String] = []
	for preferred in ["livelihood", "recovery", "growth"]:
		if options.has(preferred):
			ids.append(preferred)
	for raw_id in options:
		var option_id := str(raw_id)
		if not ids.has(option_id):
			ids.append(option_id)
	return {
		"primary": ids[0] if ids.size() > 0 else "",
		"secondary": ids[1] if ids.size() > 1 else "",
	}

static func validate_routines(raw_routines: Dictionary) -> Dictionary:
	var routines := raw_routines.duplicate(true)
	if routines.is_empty():
		# Schema-1 saves and the earliest A0 automated fixtures did not own
		# routine choices. Migrate them to a legal, survivable pair.
		routines = default_routines()
	var primary := str(routines.get("primary", "")).strip_edges()
	var secondary := str(routines.get("secondary", "")).strip_edges()
	var options := routine_options()
	if primary.is_empty() or secondary.is_empty():
		return {"ok": false, "error": "choose_two_routines"}
	if primary == secondary:
		return {"ok": false, "error": "routines_must_be_distinct"}
	if not options.has(primary) or not options.has(secondary):
		return {"ok": false, "error": "unknown_routine"}
	if not GameState.current_job.is_empty() and primary != "livelihood":
		return {"ok": false, "error": "job_requires_primary_livelihood"}
	return {
		"ok": true,
		"routines": {"primary": primary, "secondary": secondary},
	}

static func bundle_allowed_in_week(bundle_id: String, week: int) -> bool:
	var scene_bundle := bundle(bundle_id)
	if scene_bundle.is_empty():
		return false
	var raw_allowed: Variant = scene_bundle.get("allowed_weeks", [])
	if not raw_allowed is Array or (raw_allowed as Array).is_empty():
		return false
	for raw_week in raw_allowed:
		if int(raw_week) == week:
			return true
	return false

static func validate_plan(
		month_index: int, raw_schedule: Dictionary,
		raw_routines: Dictionary = {}) -> Dictionary:
	var spec := month_spec(month_index)
	if spec.is_empty():
		return {"ok": false, "error": "missing_month"}
	var weeks: Array = spec.get("weeks", [])
	if weeks.size() != 2:
		return {"ok": false, "error": "invalid_week_range"}
	var first_week := int(weeks[0])
	var last_week := int(weeks[1])
	var schedule := _normalized_schedule(raw_schedule)
	if schedule.size() != last_week - first_week + 1:
		return {"ok": false, "error": "fill_four_weeks"}

	var allowed: Array[String] = available_offer_ids(month_index)
	var locked_by_week: Dictionary = {}
	for raw_lock in spec.get("locked", []):
		if not raw_lock is Dictionary:
			continue
		var lock: Dictionary = raw_lock
		var locked_week := int(lock.get("week", 0))
		var locked_bundle := str(lock.get("bundle", ""))
		locked_by_week[str(locked_week)] = locked_bundle
		if not allowed.has(locked_bundle):
			allowed.append(locked_bundle)

	var selected: Array[String] = []
	for week in range(first_week, last_week + 1):
		var week_key := str(week)
		var bundle_id := str(schedule.get(week_key, ""))
		if bundle_id.is_empty():
			return {"ok": false, "error": "empty_week", "week": week}
		if not allowed.has(bundle_id):
			return {"ok": false, "error": "unavailable_bundle", "bundle": bundle_id}
		if not bundle_allowed_in_week(bundle_id, week):
			return {
				"ok": false,
				"error": "deadline_missed",
				"bundle": bundle_id,
				"week": week,
			}
		if locked_by_week.has(week_key) and bundle_id != str(locked_by_week[week_key]):
			return {"ok": false, "error": "locked_week_changed", "week": week}
		if selected.has(bundle_id):
			return {"ok": false, "error": "duplicate_bundle", "bundle": bundle_id}
		selected.append(bundle_id)

	for group_value in contract().get("exclusive_groups", {}).values():
		if not group_value is Dictionary:
			continue
		var group: Dictionary = group_value
		var count := 0
		for member in group.get("members", []):
			if selected.has(str(member)):
				count += 1
		if count > int(group.get("maximum_selected", 1)):
			return {"ok": false, "error": "exclusive_group"}
	var routine_validation := validate_routines(raw_routines)
	if not bool(routine_validation.get("ok", false)):
		return routine_validation
	return {
		"ok": true,
		"schedule": schedule,
		"selected": selected,
		"routines": routine_validation.get("routines", {}),
	}

static func commit_plan(
		month_index: int, raw_schedule: Dictionary,
		raw_routines: Dictionary = {}) -> Dictionary:
	var existing_state := _normalized_state(GameState.core_loop_v2_state)
	var existing_plan: Variant = existing_state["plans"].get(str(month_index), {})
	if existing_plan is Dictionary and not (existing_plan as Dictionary).is_empty():
		# A committed month is an immutable promise. Besides blocking edits after
		# its first week, this prevents a duplicate UI signal from producing a
		# second set of decline consequences.
		return {"ok": false, "error": "plan_already_committed"}
	var validation := validate_plan(month_index, raw_schedule, raw_routines)
	if not bool(validation.get("ok", false)):
		return validation
	var state := existing_state
	var schedule: Dictionary = validation.get("schedule", {})
	var selected: Array = validation.get("selected", [])
	var routines: Dictionary = validation.get("routines", {})
	var forgone_this_month: Array = []
	for bundle_id in available_offer_ids(month_index):
		if selected.has(bundle_id):
			continue
		var offer := bundle(bundle_id)
		var record := {
			"month": month_index,
			"bundle_id": bundle_id,
			"decline_consequence": str(offer.get("decline_consequence", "")),
			"planned_turn": GameState.turn,
		}
		forgone_this_month.append(record)
		state["forgone"].append(record)
		var consequence_id := str(record.get("decline_consequence", ""))
		var outcome := decline_outcome(consequence_id)
		if not consequence_id.is_empty() and not outcome.is_empty():
			state["pending_declines"].append({
				"id": consequence_id,
				"producer_bundle": bundle_id,
				"month": month_index,
				"visible_month": int(outcome.get("visible_month", month_index + 1)),
				"consumer_kind": str(outcome.get("consumer_kind", "")),
				"message_ko": str(outcome.get("message_ko", "")),
				"message_en": str(outcome.get("message_en", "")),
				"effects": (outcome.get("effects", {}) as Dictionary).duplicate(true)
					if outcome.get("effects", {}) is Dictionary else {},
			})
	while state["forgone"].size() > 48:
		state["forgone"].pop_front()
	state["plans"][str(month_index)] = {
		"schedule": schedule.duplicate(true),
		"selected": selected.duplicate(),
		"routines": routines.duplicate(true),
		"forgone": forgone_this_month,
		"planned_turn": GameState.turn,
	}
	GameState.core_loop_v2_state = state
	return {
		"ok": true,
		"schedule": schedule.duplicate(true),
		"routines": routines.duplicate(true),
	}

static func routine_selection_for_month(month_index: int = -1) -> Dictionary:
	var plan := plan_for_month(month_index)
	var raw_routines: Variant = plan.get("routines", {})
	if raw_routines is Dictionary and not (raw_routines as Dictionary).is_empty():
		return (raw_routines as Dictionary).duplicate(true)
	return default_routines()

static func apply_background_routines_for_turn(turn: int = -1) -> Dictionary:
	var target_turn := turn if turn > 0 else int(GameState.turn)
	var state := _normalized_state(GameState.core_loop_v2_state)
	var turn_key := str(target_turn)
	if state["routine_receipts"].has(turn_key):
		var prior: Dictionary = state["routine_receipts"][turn_key]
		return {
			"ok": true,
			"applied": false,
			"receipt": prior.duplicate(true),
		}
	var month_index := month_for_turn(target_turn)
	var plan := plan_for_month(month_index)
	if plan.is_empty():
		return {"ok": false, "error": "missing_plan"}
	var raw_planned: Variant = plan.get("routines", {})
	var planned: Dictionary = (raw_planned as Dictionary).duplicate(true) \
		if raw_planned is Dictionary else {}
	var effective := planned.duplicate(true)
	var employment_forced := false
	if not GameState.current_job.is_empty() \
			and str(effective.get("primary", "")) != "livelihood":
		# A job accepted after the monthly plan must not invalidate the run.
		# It becomes the persistent primary obligation immediately, while the
		# player's planned primary remains the one support routine.
		effective = {
			"primary": "livelihood",
			"secondary": str(effective.get("primary", "")),
		}
		employment_forced = true
	var validation := validate_routines(effective)
	if not bool(validation.get("ok", false)):
		return validation
	var routines: Dictionary = validation.get("routines", {})
	var receipt := {
		"turn": target_turn,
		"month": month_index,
		"primary": str(routines.get("primary", "")),
		"secondary": str(routines.get("secondary", "")),
		"planned_primary": str(planned.get("primary", "")),
		"planned_secondary": str(planned.get("secondary", "")),
		"employment_forced": employment_forced,
		"units": [],
		"effects": {},
	}
	for slot in ["primary", "secondary"]:
		var routine_id := str(routines.get(slot, ""))
		var effects := _routine_effects(routine_id)
		if effects.is_empty():
			return {
				"ok": false,
				"error": "missing_routine_effects",
				"routine": routine_id,
			}
		GameState.apply_effects(effects)
		receipt["units"].append({
			"slot": slot,
			"routine_id": routine_id,
			"effects": effects.duplicate(true),
		})
		for raw_key in effects:
			var key := str(raw_key)
			var value: Variant = effects[raw_key]
			if value is int or value is float:
				receipt["effects"][key] = float(
					receipt["effects"].get(key, 0.0)) + float(value)
	state["routine_receipts"][turn_key] = receipt.duplicate(true)
	GameState.core_loop_v2_state = state
	return {"ok": true, "applied": true, "receipt": receipt}

static func _routine_effects(routine_id: String) -> Dictionary:
	var options := routine_options()
	var raw_option: Variant = options.get(routine_id, {})
	if not raw_option is Dictionary:
		return {}
	var raw_effects: Variant = (raw_option as Dictionary).get("weekly_effects", {})
	if not raw_effects is Dictionary:
		return {}
	var effects: Dictionary = raw_effects
	if effects.has("unemployed") or effects.has("employed"):
		var employment_key := "employed" \
			if not GameState.current_job.is_empty() else "unemployed"
		var branch: Variant = effects.get(employment_key, {})
		return (branch as Dictionary).duplicate(true) \
			if branch is Dictionary else {}
	return effects.duplicate(true)

static func decline_outcome(consequence_id: String) -> Dictionary:
	var raw_outcomes: Variant = contract().get("decline_outcomes", {})
	if not raw_outcomes is Dictionary:
		return {}
	var raw_outcome: Variant = (raw_outcomes as Dictionary).get(consequence_id, {})
	return (raw_outcome as Dictionary).duplicate(true) \
		if raw_outcome is Dictionary else {}

static func process_due_decline_outcomes(closing_month: int) -> Array:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var remaining: Array = []
	var resolved: Array = []
	for raw_record in state["pending_declines"]:
		if not raw_record is Dictionary:
			continue
		var record: Dictionary = (raw_record as Dictionary).duplicate(true)
		if int(record.get("month", 0)) > closing_month:
			remaining.append(record)
			continue
		if str(record.get("consumer_kind", "")) == "in_scene_choice":
			# Locked choice-owned consequences are consumed by the scene, never
			# by the monthly decline ledger.
			continue
		var effects: Dictionary = record.get("effects", {}) as Dictionary \
			if record.get("effects", {}) is Dictionary else {}
		if not effects.is_empty():
			GameState.apply_effects(effects)
		record["effects_applied"] = effects.duplicate(true)
		record["consumed_turn"] = int(GameState.turn)
		record["closing_month"] = closing_month
		state["decline_receipts"].append(record)
		resolved.append(record.duplicate(true))
	state["pending_declines"] = remaining
	GameState.core_loop_v2_state = state
	return resolved

static func decline_receipts_for_month(visible_month: int) -> Array:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var result: Array = []
	for raw_record in state["decline_receipts"]:
		if raw_record is Dictionary \
				and int((raw_record as Dictionary).get("visible_month", 0)) == visible_month:
			result.append((raw_record as Dictionary).duplicate(true))
	return result

static func decline_receipts_from_month(month_index: int) -> Array:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var result: Array = []
	for raw_record in state["decline_receipts"]:
		if raw_record is Dictionary \
				and int((raw_record as Dictionary).get("month", 0)) == month_index:
			result.append((raw_record as Dictionary).duplicate(true))
	return result

static func record_month_summary(
		month_index: int, before: Dictionary, after: Dictionary,
		extra: Dictionary = {}) -> Dictionary:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var month_key := str(month_index)
	if state["month_summaries"].has(month_key):
		return (state["month_summaries"][month_key] as Dictionary).duplicate(true)
	var plan := plan_for_month(month_index)
	var completed_turns: Array = state.get("completed_turns", [])
	var kept: Array = []
	var schedule: Dictionary = plan.get("schedule", {}) as Dictionary \
		if plan.get("schedule", {}) is Dictionary else {}
	for raw_week in schedule:
		var week := int(raw_week)
		if completed_turns.has(week):
			kept.append({
				"week": week,
				"bundle_id": str(schedule[raw_week]),
			})
	var summary := {
		"month": month_index,
		"before": before.duplicate(true),
		"after": after.duplicate(true),
		"fixed_expense": float(before.get("fixed_expense", 0.0)),
		"monthly_income": float(before.get("monthly_income", 0.0)),
		"kept": kept,
		"routines": (
			(plan.get("routines", {}) as Dictionary).duplicate(true)
			if plan.get("routines", {}) is Dictionary else default_routines()
		),
		"decline_receipts": decline_receipts_from_month(month_index),
		"acknowledged": false,
		"recorded_turn": int(GameState.turn),
	}
	for raw_key in extra:
		summary[str(raw_key)] = extra[raw_key]
	state["month_summaries"][month_key] = summary
	GameState.core_loop_v2_state = state
	return summary.duplicate(true)

static func month_summary(month_index: int) -> Dictionary:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var raw_summary: Variant = state["month_summaries"].get(str(month_index), {})
	return (raw_summary as Dictionary).duplicate(true) \
		if raw_summary is Dictionary else {}

static func pending_month_summary() -> Dictionary:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var month_indexes: Array[int] = []
	for raw_key in state["month_summaries"]:
		month_indexes.append(int(raw_key))
	month_indexes.sort()
	for month_index in month_indexes:
		var raw_summary: Variant = state["month_summaries"].get(str(month_index), {})
		if raw_summary is Dictionary \
				and not bool((raw_summary as Dictionary).get("acknowledged", false)):
			return (raw_summary as Dictionary).duplicate(true)
	return {}

static func acknowledge_month_summary(month_index: int) -> bool:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var month_key := str(month_index)
	if not state["month_summaries"].has(month_key):
		return false
	var summary: Dictionary = state["month_summaries"][month_key]
	summary["acknowledged"] = true
	state["month_summaries"][month_key] = summary
	GameState.core_loop_v2_state = state
	return true

static func bundle_id_for_turn(turn: int = -1) -> String:
	var target_turn: int = turn if turn > 0 else int(GameState.turn)
	var plan := plan_for_month(month_for_turn(target_turn))
	var schedule: Variant = plan.get("schedule", {})
	if not schedule is Dictionary:
		return ""
	return str((schedule as Dictionary).get(str(target_turn), ""))

static func begin_bundle(bundle_id: String, active_kind: String = "schedule") -> bool:
	if bundle(bundle_id).is_empty():
		return false
	var state := _normalized_state(GameState.core_loop_v2_state)
	state["active_bundle"] = bundle_id
	state["active_kind"] = active_kind
	state["active_turn"] = GameState.turn
	state["action_result_ready"] = false
	GameState.core_loop_v2_state = state
	return true

static func active_bundle_id() -> String:
	return str(GameState.core_loop_v2_state.get("active_bundle", ""))

static func active_kind() -> String:
	return str(GameState.core_loop_v2_state.get("active_kind", ""))

static func action_result_ready() -> bool:
	return bool(GameState.core_loop_v2_state.get("action_result_ready", false))

static func turn_completed(turn: int = -1) -> bool:
	var target_turn: int = turn if turn > 0 else int(GameState.turn)
	var completed: Variant = GameState.core_loop_v2_state.get("completed_turns", [])
	return completed is Array and (completed as Array).has(target_turn)

static func has_completed_bundle(bundle_id: String) -> bool:
	var completed: Variant = GameState.core_loop_v2_state.get("completed_bundles", [])
	return completed is Array and (completed as Array).has(bundle_id)

static func note_action_commitment(record: Dictionary) -> bool:
	if active_kind() != "schedule":
		return false
	var active_id := active_bundle_id()
	var active_bundle := bundle(active_id)
	if active_bundle.is_empty() or not active_bundle.has("action_id"):
		return false
	var expected_action := str(active_bundle.get("action_id", ""))
	var actual_action := str(record.get("choice_id", ""))
	if expected_action != actual_action:
		return false
	var state := _normalized_state(GameState.core_loop_v2_state)
	state["action_result_ready"] = true
	GameState.core_loop_v2_state = state
	return true

static func complete_active_bundle() -> String:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var bundle_id := str(state.get("active_bundle", ""))
	var kind := str(state.get("active_kind", ""))
	if bundle_id.is_empty():
		return ""
	if kind == "consequence":
		if not state["shown_consequences"].has(bundle_id):
			state["shown_consequences"].append(bundle_id)
		state["shown_consequence_turns"][bundle_id] = GameState.turn
	else:
		if not state["completed_bundles"].has(bundle_id):
			state["completed_bundles"].append(bundle_id)
			state["completed_bundle_turns"][bundle_id] = GameState.turn
		if not state["completed_turns"].has(GameState.turn):
			state["completed_turns"].append(GameState.turn)
	state["active_bundle"] = ""
	state["active_kind"] = ""
	state["active_turn"] = 0
	state["action_result_ready"] = false
	GameState.core_loop_v2_state = state
	return bundle_id

static func cancel_active_bundle() -> void:
	var state := _normalized_state(GameState.core_loop_v2_state)
	state["active_bundle"] = ""
	state["active_kind"] = ""
	state["active_turn"] = 0
	state["action_result_ready"] = false
	GameState.core_loop_v2_state = state

static func pending_consequence_id(month_index: int = -1) -> String:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var scheduled_id := bundle_id_for_turn()
	var scheduled_bundle := bundle(scheduled_id)
	if str(scheduled_bundle.get("kind", "")) == "boss":
		return ""
	for shown_turn in state["shown_consequence_turns"].values():
		if int(shown_turn) == GameState.turn:
			return ""
	for consequence_id in _eligible_consequence_ids(month_index):
		if state["shown_consequences"].has(consequence_id):
			continue
		var consequence := bundle(consequence_id)
		if not bundle_allowed_in_week(consequence_id, int(GameState.turn)):
			continue
		var required := str(consequence.get("requires_prior_choice", ""))
		if required.is_empty() or not state["completed_bundles"].has(required):
			continue
		var completed_turn := int(state["completed_bundle_turns"].get(required, 0))
		if completed_turn >= GameState.turn:
			continue
		if consequence_id == "opening_interview_math" \
				and not bool(GameState.flags.get("opening_interview_application_sent", false)):
			continue
		return consequence_id
	return ""

static func _eligible_consequence_ids(month_index: int = -1) -> Array[String]:
	var current_month := month_index if month_index > 0 else month_for_turn(GameState.turn)
	var result: Array[String] = []
	for raw_month in contract().get("months", []):
		if not raw_month is Dictionary:
			continue
		var month: Dictionary = raw_month
		if int(month.get("month", 0)) > current_month:
			continue
		for raw_id in month.get("conditional_consequences", []):
			var consequence_id := str(raw_id)
			if not consequence_id.is_empty() and not result.has(consequence_id):
				result.append(consequence_id)
	return result

static func resolved_event_roots(bundle_id: String) -> Array:
	var scene_bundle := bundle(bundle_id)
	if bundle_id == "temptation_consequence":
		if bool(GameState.flags.get("lent_account", false)):
			return ["arc_temptation_fallout"]
		return ["arc_temptation_clean"]
	var roots: Variant = scene_bundle.get("existing_roots", [])
	return (roots as Array).duplicate() if roots is Array else []

static func prepare_story_bundle(bundle_id: String) -> void:
	var scene_bundle := bundle(bundle_id)
	var suppressed: Array = scene_bundle.get("suppress_follow_up_events", [])
	if suppressed.is_empty():
		return
	var state := _normalized_state(GameState.core_loop_v2_state)
	for event_id in resolved_event_roots(bundle_id):
		var event: Dictionary = DataRegistry.find_event(str(event_id))
		var choices: Array = event.get("choices", [])
		for choice_index in range(choices.size()):
			var choice: Dictionary = choices[choice_index]
			var follow_up := str(choice.get("follow_up_event", ""))
			if follow_up.is_empty() or not suppressed.has(follow_up):
				continue
			var key := "%s:%d" % [str(event_id), choice_index]
			state["suppressed_followups"][key] = follow_up
			choice.erase("follow_up_event")
	GameState.core_loop_v2_state = state

static func restore_story_bundle_followups() -> void:
	var state := _normalized_state(GameState.core_loop_v2_state)
	for raw_key in state["suppressed_followups"]:
		var key := str(raw_key)
		var split := key.rsplit(":", true, 1)
		if split.size() != 2:
			continue
		var event: Dictionary = DataRegistry.find_event(split[0])
		var choices: Array = event.get("choices", [])
		var choice_index := int(split[1])
		if choice_index < 0 or choice_index >= choices.size():
			continue
		var choice: Dictionary = choices[choice_index]
		choice["follow_up_event"] = str(state["suppressed_followups"][raw_key])
	state["suppressed_followups"] = {}
	GameState.core_loop_v2_state = state

static func forgone_for_month(month_index: int = -1) -> Array:
	var target_month := month_index if month_index > 0 else month_for_turn(GameState.turn)
	var result: Array = []
	for raw_record in GameState.core_loop_v2_state.get("forgone", []):
		if raw_record is Dictionary and int(raw_record.get("month", 0)) == target_month:
			result.append((raw_record as Dictionary).duplicate(true))
	return result

static func relationship_stage(character_id: String) -> String:
	var stages: Variant = GameState.core_loop_v2_state.get("relationship_stages", {})
	if not stages is Dictionary:
		return "unmet"
	return str((stages as Dictionary).get(character_id, "unmet"))

static func was_player_initiated(character_id: String) -> bool:
	var initiated: Variant = GameState.core_loop_v2_state.get("player_initiated", [])
	return initiated is Array and (initiated as Array).has(character_id)

static func note_story_choice(event_id: String, choice_index: int) -> bool:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var bundle_id := str(state.get("active_bundle", ""))
	if bundle_id.is_empty():
		return false
	var scene_bundle := bundle(bundle_id)
	var raw_outcomes: Variant = scene_bundle.get("relationship_outcomes", [])
	if not raw_outcomes is Array:
		return false
	for raw_outcome in raw_outcomes:
		if not raw_outcome is Dictionary:
			continue
		var outcome: Dictionary = raw_outcome
		if str(outcome.get("event_id", "")) != event_id:
			continue
		var choices: Variant = outcome.get("choices", [])
		if not choices is Array:
			continue
		var choice_matches := false
		for raw_choice in choices:
			if int(raw_choice) == choice_index:
				choice_matches = true
				break
		if not choice_matches:
			continue
		var receipt_key := "%s:%s:%d:%d" % [
			bundle_id, event_id, choice_index, int(GameState.turn)]
		if state["relationship_choice_receipts"].has(receipt_key):
			return true
		var character_id := str(outcome.get("character", ""))
		if character_id.is_empty():
			var characters: Array = scene_bundle.get("characters", [])
			if not characters.is_empty():
				character_id = str(characters[0])
		var target_stage := str(outcome.get("stage", ""))
		if character_id.is_empty() or target_stage.is_empty():
			return false
		var current_stage := str(
			state["relationship_stages"].get(character_id, "unmet"))
		var current_rank := RELATIONSHIP_STAGE_ORDER.find(current_stage)
		var target_rank := RELATIONSHIP_STAGE_ORDER.find(target_stage)
		if target_rank < 0 or current_rank < 0 or target_rank < current_rank:
			return false
		if target_stage != current_stage:
			state["relationship_stages"][character_id] = target_stage
		state["relationship_history"].append({
			"character": character_id,
			"from": current_stage,
			"to": target_stage,
			"bundle_id": bundle_id,
			"event_id": event_id,
			"choice_index": choice_index,
			"turn": int(GameState.turn),
		})
		if str(scene_bundle.get("initiated_by", "")) == "player" \
				and not state["player_initiated"].has(character_id):
			state["player_initiated"].append(character_id)
		state["relationship_choice_receipts"][receipt_key] = true
		GameState.core_loop_v2_state = state
		return true
	return false

static func _bundle_requirement_met(scene_bundle: Dictionary) -> bool:
	var required := str(scene_bundle.get("requires_completed_bundle", ""))
	if not required.is_empty():
		var completed: Variant = GameState.core_loop_v2_state.get(
			"completed_bundles", [])
		if not completed is Array or not (completed as Array).has(required):
			return false
	if bool(scene_bundle.get("requires_player_initiated", false)) \
			and str(scene_bundle.get("initiated_by", "")) != "player":
		for raw_character in scene_bundle.get("characters", []):
			if not was_player_initiated(str(raw_character)):
				return false
	if str(scene_bundle.get("initiated_by", "")) == "player":
		for raw_character in scene_bundle.get("characters", []):
			if relationship_stage(str(raw_character)) == "unmet":
				return false
	return true

static func _normalized_schedule(raw_schedule: Dictionary) -> Dictionary:
	var schedule: Dictionary = {}
	for raw_week in raw_schedule:
		var week := int(raw_week)
		if week <= 0:
			continue
		var bundle_id := str(raw_schedule.get(raw_week, "")).strip_edges()
		if not bundle_id.is_empty():
			schedule[str(week)] = bundle_id
	return schedule

static func _normalized_state(raw_state: Dictionary) -> Dictionary:
	var state := raw_state.duplicate(true)
	state["schema"] = SCHEMA
	state["enabled"] = bool(state.get("enabled", false))
	for key in [
		"plans", "completed_bundle_turns", "shown_consequence_turns",
		"relationship_stages", "relationship_choice_receipts",
		"suppressed_followups", "routine_receipts", "month_summaries",
	]:
		if not state.has(key) or not state[key] is Dictionary:
			state[key] = {}
	for key in [
		"forgone", "completed_turns", "completed_bundles",
		"shown_consequences", "player_initiated", "pending_declines",
		"decline_receipts", "relationship_history",
	]:
		if not state.has(key) or not state[key] is Array:
			state[key] = []
	state["active_bundle"] = str(state.get("active_bundle", ""))
	state["active_kind"] = str(state.get("active_kind", ""))
	state["active_turn"] = int(state.get("active_turn", 0))
	state["action_result_ready"] = bool(state.get("action_result_ready", false))
	state["prototype_complete"] = bool(state.get("prototype_complete", false))
	state["prototype_completed_at_turn"] = int(
		state.get("prototype_completed_at_turn", 0))
	return state
