extends RefCounted
## ORDER-57: 단계별 데모의 월간 계획·약속·놓친 길 저장 계약.
## 기존 240주 편성기는 사람 GO 전까지 그대로 두고 명시적 테스트 런만 활성화한다.

const SCHEMA := 3
const DEFAULT_DEVELOPMENT_CAP_WEEK := 12
# Compatibility only. New callers must use development_cap_week(), because the
# internal gate advances 8 → 12 → 16 → 20 → 24 without rewriting this script.
const PROTOTYPE_MAX_WEEK := DEFAULT_DEVELOPMENT_CAP_WEEK
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
const OWNED_STORY_ROOTS := [
	"v2_mirae_result_message",
	"v2_seorin_result_message",
	"v2_hyunsu_player_reachout",
	"v2_hyunsu_first_study",
	"v2_hyunsu_study_followup",
	"v2_hanbit_interview",
	"v2_daeun_return_named",
	"v2_daeun_return_after_distance",
	"v2_sangchul_housing_lead",
	"v2_jaehyuk_message",
]
const ENABLE_ARGS := [
	"--core-loop-v2",
	"core-loop-v2",
	"--qa=core-loop-v2",
	"qa=core-loop-v2",
]

static func contract() -> Dictionary:
	return DataRegistry.demo_core_loop_v2

static func development_cap_week() -> int:
	var raw_scope: Variant = contract().get("scope", {})
	if not raw_scope is Dictionary:
		return DEFAULT_DEVELOPMENT_CAP_WEEK
	var scope: Dictionary = raw_scope
	var minimum: int = maxi(1, int(scope.get("min_week", 1)))
	var maximum: int = maxi(minimum, int(scope.get("max_week", 24)))
	return clampi(
		int(scope.get("development_cap_week", DEFAULT_DEVELOPMENT_CAP_WEEK)),
		minimum,
		maximum)

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
	var state := _normalized_state(GameState.core_loop_v2_state)
	return bool(state.get("enabled", false)) \
		and GameState.turn >= 1 and GameState.turn <= development_cap_week()

static func is_development_complete() -> bool:
	var state := _normalized_state(GameState.core_loop_v2_state)
	if not bool(state.get("enabled", false)):
		return false
	return int(state.get("completed_through_week", 0)) \
		>= development_cap_week()

static func is_prototype_complete() -> bool:
	return is_development_complete()

static func mark_development_complete() -> bool:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var cap := development_cap_week()
	if not bool(state.get("enabled", false)) \
			or GameState.turn != cap + 1 \
			or not (state.get("completed_turns", []) as Array).has(cap):
		return false
	state["completed_through_week"] = maxi(
		int(state.get("completed_through_week", 0)), cap)
	state["development_cap_week"] = cap
	state["prototype_complete"] = true
	state["prototype_completed_at_turn"] = GameState.turn
	state["completed_at_turn"] = GameState.turn
	state["active_bundle"] = ""
	state["active_kind"] = ""
	state["active_turn"] = 0
	state["action_result_ready"] = false
	GameState.core_loop_v2_state = state
	return true

static func mark_prototype_complete() -> bool:
	return mark_development_complete()

static func completion_snapshot() -> Dictionary:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var cap := development_cap_week()
	var final_month := month_for_turn(cap)
	var completed_turns: Array = state.get("completed_turns", [])
	var kept: Array = []
	for month_index in range(1, final_month + 1):
		var plan := plan_for_month(month_index)
		var raw_schedule: Variant = plan.get("schedule", {})
		if not raw_schedule is Dictionary:
			continue
		var weeks: Array[int] = []
		for raw_week in (raw_schedule as Dictionary):
			var week := int(raw_week)
			if week >= 1 and week <= cap:
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
				or int(record.get("month", 0)) > final_month:
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

	var closing_money := float(GameState.money)
	var final_summary_raw: Variant = (
		state.get("month_summaries", {}) as Dictionary
	).get(str(final_month), {})
	if final_summary_raw is Dictionary:
		var final_after_raw: Variant = (
			final_summary_raw as Dictionary
		).get("after", {})
		if final_after_raw is Dictionary:
			closing_money = float(
				(final_after_raw as Dictionary).get("money", closing_money))

	return {
		"kept": kept,
		"forgone": forgone,
		"decline_receipts":
			(state.get("decline_receipts", []) as Array).duplicate(true),
		"routine_receipts":
			(state.get("routine_receipts", {}) as Dictionary).duplicate(true),
		"month_summaries":
			(state.get("month_summaries", {}) as Dictionary).duplicate(true),
		"month_opening_snapshots":
			(state.get("month_opening_snapshots", {}) as Dictionary).duplicate(true),
		"player_initiated": (state.get("player_initiated", []) as Array).duplicate(),
		"relationship_stages":
			(state.get("relationship_stages", {}) as Dictionary).duplicate(true),
		"relationship_memories":
			(state.get("relationship_memories", []) as Array).duplicate(true),
		"application_statuses":
			(state.get("application_statuses", {}) as Dictionary).duplicate(true),
		"application_transition_receipts":
			(state.get("application_transition_receipts", {}) as Dictionary).duplicate(true),
		"legacy_callback_resolutions":
			(state.get("legacy_callback_resolutions", {}) as Dictionary).duplicate(true),
		"action_receipts":
			(state.get("action_receipts", {}) as Dictionary).duplicate(true),
		"consequence_receipts":
			(state.get("consequence_receipts", {}) as Dictionary).duplicate(true),
		"temptation_branch": temptation_branch,
		"cash_shortfall": cash_shortfall_for_money(closing_money),
		"completed_through_week": int(
			state.get("completed_through_week", 0)),
		"development_cap_week": cap,
		"completed_at_turn": int(state.get("completed_at_turn",
			state.get("prototype_completed_at_turn", 0))),
	}

static func month_for_turn(turn: int) -> int:
	return maxi(1, int(floor(float(maxi(turn, 1) - 1) / 4.0)) + 1)

static func cash_shortfall_for_money(money: float) -> float:
	return maxf(0.0, -money)

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
	var raw_surface: Variant = contract().get("surface", {})
	var fill_target := 4
	if raw_surface is Dictionary:
		var surface: Dictionary = raw_surface
		var slot_count: int = maxi(1, int(surface.get(
			"foreground_slots_per_month", fill_target)))
		var minimum_offers: int = maxi(1, int(surface.get(
			"minimum_offers_per_month", slot_count)))
		fill_target = maxi(slot_count, minimum_offers)
	if result.size() < fill_target:
		for raw_id in spec.get("fallback_offers", []):
			var bundle_id := str(raw_id)
			if result.has(bundle_id):
				continue
			var offer := bundle(bundle_id)
			if offer.is_empty() or not _bundle_requirement_met(offer):
				continue
			result.append(bundle_id)
			if result.size() >= fill_target:
				break
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

	for raw_group_id in contract().get("exclusive_groups", {}):
		var group_value: Variant = contract().get(
			"exclusive_groups", {}).get(raw_group_id, {})
		if not group_value is Dictionary:
			continue
		var group: Dictionary = group_value
		var count := 0
		for member in group.get("members", []):
			if selected.has(str(member)):
				count += 1
		if count > int(group.get("maximum_selected", 1)):
			return {
				"ok": false,
				"error": "exclusive_group",
				"group": str(raw_group_id),
			}
	var named_validation := _validate_named_character_cap(spec, selected)
	if not named_validation.is_empty():
		return named_validation
	var routine_validation := validate_routines(raw_routines)
	if not bool(routine_validation.get("ok", false)):
		return routine_validation
	return {
		"ok": true,
		"schedule": schedule,
		"selected": selected,
		"routines": routine_validation.get("routines", {}),
	}

static func _validate_named_character_cap(
		spec: Dictionary, selected: Array[String]) -> Dictionary:
	var named_character_cap := maxi(
		0, int(spec.get("active_named_characters_max", 0)))
	var relationship_contract: Variant = contract().get("relationship", {})
	var global_named_cap := 0
	if relationship_contract is Dictionary:
		global_named_cap = maxi(0, int(
			(relationship_contract as Dictionary).get(
				"maximum_active_named_threads", 0)))
	if named_character_cap <= 0:
		named_character_cap = global_named_cap
	elif global_named_cap > 0:
		named_character_cap = mini(named_character_cap, global_named_cap)
	if named_character_cap <= 0:
		return {}

	var named_characters: Dictionary = {}
	var existing_stages: Variant = GameState.core_loop_v2_state.get(
		"relationship_stages", {})
	if existing_stages is Dictionary:
		for raw_character in (existing_stages as Dictionary):
			var existing_character := str(raw_character).strip_edges()
			var stage := str(
				(existing_stages as Dictionary).get(
					raw_character, "unmet")).strip_edges()
			if not existing_character.is_empty() \
					and stage not in ["", "unmet", "closed"]:
				named_characters[existing_character] = true
	for selected_bundle_id in selected:
		for raw_character in bundle(selected_bundle_id).get(
				"characters", []):
			var character_id := str(raw_character).strip_edges()
			if not character_id.is_empty():
				named_characters[character_id] = true
	if named_characters.size() <= named_character_cap:
		return {}
	return {
		"ok": false,
		"error": "active_named_characters_cap",
		"maximum": named_character_cap,
		"characters": named_characters.keys(),
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
			var pending_record := {
				"id": consequence_id,
				"producer_bundle": bundle_id,
				"month": month_index,
				"visible_month": int(outcome.get("visible_month", month_index + 1)),
				"consumer_kind": str(outcome.get("consumer_kind", "")),
				"message_ko": str(outcome.get("message_ko", "")),
				"message_en": str(outcome.get("message_en", "")),
				"effects": (outcome.get("effects", {}) as Dictionary).duplicate(true)
					if outcome.get("effects", {}) is Dictionary else {},
			}
			for dispatch_key in [
				"target_bundle", "consumer_bundle", "matching_bundle",
				"target_kinds", "consumer_bundles", "fallback",
				"application_transition",
			]:
				if outcome.has(dispatch_key):
					var dispatch_value: Variant = outcome[dispatch_key]
					pending_record[dispatch_key] = (
						dispatch_value.duplicate(true)
						if dispatch_value is Dictionary or dispatch_value is Array
						else dispatch_value
					)
			state["pending_declines"].append(pending_record)
	while state["forgone"].size() > 48:
		state["forgone"].pop_front()
	state["plans"][str(month_index)] = {
		"schedule": schedule.duplicate(true),
		"selected": selected.duplicate(),
		"routines": routines.duplicate(true),
		"forgone": forgone_this_month,
		"planned_turn": GameState.turn,
	}
	var month_key := str(month_index)
	if not state["month_opening_snapshots"].has(month_key):
		state["month_opening_snapshots"][month_key] = {
			"turn": int(GameState.turn),
			"date": GameState.get_date_string(),
			"money": float(GameState.money),
			"cash_shortfall": cash_shortfall_for_money(float(GameState.money)),
			"monthly_income": float(GameState.monthly_income),
			"fixed_expense": float(GameState.get_monthly_required_cash()),
			"health": int(GameState.health),
			"mental": int(GameState.mental),
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

static func process_declines_before_bundle(bundle_id: String) -> Array:
	var target := bundle(bundle_id)
	if target.is_empty():
		return []
	var state := _normalized_state(GameState.core_loop_v2_state)
	var remaining: Array = []
	var resolved: Array = []
	for raw_record in state["pending_declines"]:
		if not raw_record is Dictionary:
			continue
		var record: Dictionary = (raw_record as Dictionary).duplicate(true)
		if int(record.get("visible_month", 0)) \
				> month_for_turn(GameState.turn) \
				or str(record.get("consumer_kind", "")) \
					!= "next_matching_bundle" \
				or not _decline_matches_bundle(record, bundle_id, target):
			remaining.append(record)
			continue
		_consume_decline_record(
			state, record, "before_bundle", {"consumer_bundle": bundle_id})
		resolved.append(record.duplicate(true))
	state["pending_declines"] = remaining
	GameState.core_loop_v2_state = state
	return resolved

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
		var is_matching_fallback := (
			str(record.get("consumer_kind", "")) == "next_matching_bundle")
		if is_matching_fallback:
			var raw_fallback: Variant = record.get("fallback", {})
			if not raw_fallback is Dictionary:
				remaining.append(record)
				continue
			var fallback: Dictionary = raw_fallback
			if str(fallback.get("consumer_kind", "")) != "closing_month" \
					or int(fallback.get(
						"visible_month", record.get("visible_month", 0)
					)) > closing_month:
				remaining.append(record)
				continue
		_consume_decline_record(
			state, record,
			"closing_month_fallback" if is_matching_fallback else "closing_month",
			{"closing_month": closing_month})
		resolved.append(record.duplicate(true))
	state["pending_declines"] = remaining
	GameState.core_loop_v2_state = state
	return resolved

static func _decline_matches_bundle(
		record: Dictionary, bundle_id: String, target: Dictionary) -> bool:
	var explicit_target := str(record.get("target_bundle",
		record.get("consumer_bundle",
			record.get("matching_bundle", "")))).strip_edges()
	if not explicit_target.is_empty() and explicit_target != bundle_id:
		return false
	var raw_target_bundles: Variant = record.get("consumer_bundles", [])
	if raw_target_bundles is Array and not (raw_target_bundles as Array).is_empty():
		var target_bundles: Array[String] = []
		for raw_id in raw_target_bundles:
			target_bundles.append(str(raw_id))
		if not target_bundles.has(bundle_id):
			return false
	var raw_kinds: Variant = record.get("target_kinds", [])
	if raw_kinds is Array and not (raw_kinds as Array).is_empty():
		var target_kind := str(target.get("kind", ""))
		var kind_matches := false
		for raw_kind in raw_kinds:
			if str(raw_kind) == target_kind:
				kind_matches = true
				break
		if not kind_matches:
			return false
	return not explicit_target.is_empty() \
		or (raw_target_bundles is Array
			and not (raw_target_bundles as Array).is_empty()) \
		or (raw_kinds is Array and not (raw_kinds as Array).is_empty())

static func _consume_decline_record(
		state: Dictionary, record: Dictionary, dispatch: String,
		extra: Dictionary = {}) -> void:
	var effects: Dictionary = record.get("effects", {}) as Dictionary \
		if record.get("effects", {}) is Dictionary else {}
	if not effects.is_empty():
		GameState.apply_effects(effects)
	record["effects_applied"] = effects.duplicate(true)
	var raw_transition: Variant = record.get("application_transition", {})
	if raw_transition is Dictionary:
		var transition: Dictionary = raw_transition
		var application_id := str(
			transition.get("application_id", "")).strip_edges()
		var from_status := str(transition.get("from", "")).strip_edges()
		var to_status := str(transition.get("to", "")).strip_edges()
		var current_status := str(
			state["application_statuses"].get(
				application_id, application_status(application_id)))
		if not application_id.is_empty() \
				and not from_status.is_empty() \
				and not to_status.is_empty() \
				and current_status == from_status:
			state["application_statuses"][application_id] = to_status
			var transition_receipt := {
				"application_id": application_id,
				"from": from_status,
				"to": to_status,
				"bundle_id": str(record.get("producer_bundle", "")),
				"decline_id": str(record.get("id", "")),
				"turn": int(GameState.turn),
			}
			record["application_transition_applied"] = \
				transition_receipt.duplicate(true)
			state["application_transition_receipts"][
				"decline:%s:%d" % [
					str(record.get("id", "")), int(GameState.turn)
				]
			] = transition_receipt
	record["consumed_turn"] = int(GameState.turn)
	record["dispatch"] = dispatch
	for raw_key in extra:
		record[str(raw_key)] = extra[raw_key]
	state["decline_receipts"].append(record)

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
	# The closing balance remains untouched. This receipt gives the notebook a
	# non-negative, display-safe amount for unpaid cash obligations.
	summary["cash_shortfall"] = cash_shortfall_for_money(
		float(after.get("money", 0.0)))
	state["month_summaries"][month_key] = summary
	GameState.core_loop_v2_state = state
	return summary.duplicate(true)

static func month_summary(month_index: int) -> Dictionary:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var raw_summary: Variant = state["month_summaries"].get(str(month_index), {})
	return (raw_summary as Dictionary).duplicate(true) \
		if raw_summary is Dictionary else {}

static func month_opening_snapshot(month_index: int) -> Dictionary:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var raw_snapshot: Variant = state["month_opening_snapshots"].get(
		str(month_index), {})
	return (raw_snapshot as Dictionary).duplicate(true) \
		if raw_snapshot is Dictionary else {}

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
	if bundle(bundle_id).is_empty() \
			or active_kind not in ["schedule", "consequence"]:
		return false
	var state := _normalized_state(GameState.core_loop_v2_state)
	var existing_id := str(state.get("active_bundle", "")).strip_edges()
	if not existing_id.is_empty():
		# Scene re-entry may ask the same owner to resume, but no second
		# foreground bundle may replace it during the same calendar week.
		return existing_id == bundle_id \
			and str(state.get("active_kind", "")) == active_kind \
			and int(state.get("active_turn", 0)) == int(GameState.turn)
	if active_kind == "schedule" and turn_completed():
		return false
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
	var state := _normalized_state(GameState.core_loop_v2_state)
	GameState.core_loop_v2_state = state
	return bool(state.get("action_result_ready", false))

static func turn_completed(turn: int = -1) -> bool:
	var target_turn: int = turn if turn > 0 else int(GameState.turn)
	var completed: Variant = GameState.core_loop_v2_state.get("completed_turns", [])
	return completed is Array and (completed as Array).has(target_turn)

static func has_completed_bundle(bundle_id: String) -> bool:
	var completed: Variant = GameState.core_loop_v2_state.get("completed_bundles", [])
	return completed is Array and (completed as Array).has(bundle_id)

static func action_receipt(bundle_id: String) -> Dictionary:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var raw_receipt: Variant = state["action_receipts"].get(bundle_id, {})
	return (raw_receipt as Dictionary).duplicate(true) \
		if raw_receipt is Dictionary else {}

## A saved result screen is presentation state, not permission to execute the
## action again. Return the durable receipt only when the active bundle, turn,
## and finalized weekly commitment still describe the same action.
static func recover_action_result() -> Dictionary:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var bundle_id := str(state.get("active_bundle", "")).strip_edges()
	var active_turn := int(state.get("active_turn", 0))
	if not bool(state.get("action_result_ready", false)) \
			or str(state.get("active_kind", "")) != "schedule" \
			or bundle_id.is_empty() \
			or active_turn != int(GameState.turn):
		return {}
	var scene_bundle := bundle(bundle_id)
	var expected_action := str(
		scene_bundle.get("action_id", "")).strip_edges().to_lower()
	var raw_receipt: Variant = state["action_receipts"].get(bundle_id, {})
	if expected_action.is_empty() or not raw_receipt is Dictionary:
		return {}
	var receipt: Dictionary = raw_receipt
	if int(receipt.get("turn", -1)) != active_turn \
			or str(receipt.get("action_id", "")).strip_edges().to_lower() \
				!= expected_action:
		return {}
	var commitment := GameState.get_weekly_commitment_for_turn(active_turn)
	var actual_action := str(
		commitment.get("actual_action_id", "")).strip_edges().to_lower()
	if commitment.is_empty() \
			or str(commitment.get("pressure_id", "")) != bundle_id \
			or str(commitment.get("choice_id", "")).strip_edges().to_lower() \
				!= expected_action \
			or not GameState.weekly_commitment_action_matches(
				expected_action, actual_action):
		return {}
	GameState.core_loop_v2_state = state
	var result := receipt.duplicate(true)
	result["bundle_id"] = bundle_id
	return result

static func application_status(application_id: String) -> String:
	var normalized_id := application_id.strip_edges()
	if normalized_id.is_empty():
		return ""
	var state := _normalized_state(GameState.core_loop_v2_state)
	var stored := str(state["application_statuses"].get(normalized_id, ""))
	if not stored.is_empty():
		return stored
	# Schema-2 saves did not own action receipts. Preserve causal applications
	# already represented by their production flags when extending them to B.
	if normalized_id in ["mirae", "mirae_industrial_tech"] \
			and bool(GameState.flags.get(
				"opening_interview_application_sent", false)):
		return "submitted"
	if bool(GameState.flags.get(
			"core_loop_%s_application_sent" % normalized_id, false)):
		return "submitted"
	return ""

static func has_relationship_memory(
		character_id: String, memory: String) -> bool:
	var normalized_character := character_id.strip_edges()
	var normalized_memory := memory.strip_edges()
	if normalized_character.is_empty() or normalized_memory.is_empty():
		return false
	var state := _normalized_state(GameState.core_loop_v2_state)
	for raw_receipt in state["relationship_memories"]:
		if raw_receipt is Dictionary \
				and str((raw_receipt as Dictionary).get(
					"character", "")) == normalized_character \
				and str((raw_receipt as Dictionary).get(
					"memory", "")) == normalized_memory:
			return true
	return false

static func legacy_callback_is_superseded(callback_id: String) -> bool:
	var normalized_id := callback_id.strip_edges()
	if normalized_id.is_empty():
		return false
	var state := _normalized_state(GameState.core_loop_v2_state)
	var raw_receipt: Variant = state["legacy_callback_resolutions"].get(
		normalized_id, {})
	return raw_receipt is Dictionary \
		and str((raw_receipt as Dictionary).get(
			"policy", "")) == "superseded"

static func _action_receipt_from_record(
		bundle_id: String, scene_bundle: Dictionary,
		record: Dictionary) -> Dictionary:
	var expected_action := str(
		scene_bundle.get("action_id", "")).strip_edges().to_lower()
	var choice_id := str(
		record.get("choice_id", "")).strip_edges().to_lower()
	var actual_action := str(
		record.get("actual_action_id", "")).strip_edges().to_lower()
	var pressure_id := str(
		record.get("pressure_id", "")).strip_edges()
	var record_turn := int(record.get("turn", -1))
	if bundle_id.is_empty() or expected_action.is_empty() \
			or pressure_id != bundle_id \
			or choice_id != expected_action \
			or not GameState.weekly_commitment_action_matches(
				expected_action, actual_action) \
			or record_turn < 1:
		return {}
	var details: Dictionary = (
		(record.get("details", {}) as Dictionary).duplicate(true)
		if record.get("details", {}) is Dictionary else {}
	)
	var config: Dictionary = (
		(scene_bundle.get("action_config", {}) as Dictionary).duplicate(true)
		if scene_bundle.get("action_config", {}) is Dictionary else {}
	)
	var execution := str(details.get(
		"execution", config.get("execution", ""))).strip_edges()
	if execution.is_empty():
		match expected_action:
			"apply":
				execution = "application"
			"rest":
				execution = "rest"
	if not execution.is_empty():
		details["execution"] = execution
	var application_id := str(details.get(
		"application_id", config.get("application_id", ""))).strip_edges()
	var status := str(details.get(
		"status", config.get(
			"application_status", config.get("status", "")))).strip_edges()
	return {
		"bundle_id": bundle_id,
		"action_id": expected_action,
		"actual_action_id": actual_action,
		"turn": record_turn,
		"application_id": application_id,
		"application_status": status,
		"config": config,
		"result_details": details,
		"outcome": (
			(record.get("outcome", {}) as Dictionary).duplicate(true)
			if record.get("outcome", {}) is Dictionary else {}
		),
	}

static func note_action_commitment(record: Dictionary) -> bool:
	if active_kind() != "schedule":
		return false
	var active_id := active_bundle_id()
	var active_bundle := bundle(active_id)
	if active_bundle.is_empty() or not active_bundle.has("action_id"):
		return false
	var expected_action := str(
		active_bundle.get("action_id", "")).strip_edges().to_lower()
	var choice_id := str(
		record.get("choice_id", "")).strip_edges().to_lower()
	var actual_action := str(
		record.get("actual_action_id", "")).strip_edges().to_lower()
	if str(record.get("pressure_id", "")).strip_edges() != active_id \
			or choice_id != expected_action \
			or not GameState.weekly_commitment_action_matches(
				expected_action, actual_action) \
			or int(record.get("turn", -1)) != int(GameState.turn) \
			or not record.get("outcome", {}) is Dictionary:
		return false
	var state := _normalized_state(GameState.core_loop_v2_state)
	if state["action_receipts"].has(active_id):
		var existing: Dictionary = state["action_receipts"][active_id]
		if int(existing.get("turn", -1)) != int(GameState.turn) \
				or str(existing.get("action_id", "")) != expected_action:
			return false
		state["action_result_ready"] = true
		GameState.core_loop_v2_state = state
		return true
	var receipt := _action_receipt_from_record(
		active_id, active_bundle, record)
	if receipt.is_empty() or int(receipt.get("turn", -1)) != int(GameState.turn):
		return false
	var application_id := str(receipt.get("application_id", ""))
	var status := str(receipt.get("application_status", ""))
	state["action_receipts"][active_id] = receipt
	if not application_id.is_empty() and not status.is_empty():
		state["application_statuses"][application_id] = status
	state["action_result_ready"] = true
	GameState.core_loop_v2_state = state
	return true

static func complete_active_bundle() -> String:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var bundle_id := str(state.get("active_bundle", ""))
	var kind := str(state.get("active_kind", ""))
	if bundle_id.is_empty():
		return ""
	var active_spec := bundle(bundle_id)
	if kind == "schedule":
		var prelude_receipt := _scheduled_prelude_receipt_from_state(
			state, bundle_id, int(GameState.turn))
		if not prelude_receipt.is_empty() \
				and str(prelude_receipt.get("status", "")) != "consumed":
			return ""
		var relationship_outcomes: Variant = active_spec.get(
			"relationship_outcomes", [])
		if relationship_outcomes is Array \
				and not (relationship_outcomes as Array).is_empty() \
				and not _has_current_relationship_receipt(state, bundle_id):
			return ""
		var application_outcomes: Variant = active_spec.get(
			"application_outcomes", [])
		if application_outcomes is Array \
				and not (application_outcomes as Array).is_empty() \
				and not _has_current_application_receipt(state, bundle_id):
			return ""
		if int(contract().get("schema_version", 1)) >= 3 \
				and not str(active_spec.get("action_id", "")).is_empty():
			var raw_action_receipt: Variant = state["action_receipts"].get(
				bundle_id, {})
			if not raw_action_receipt is Dictionary \
					or int((raw_action_receipt as Dictionary).get(
						"turn", -1)) != int(GameState.turn):
				return ""
	if kind == "consequence":
		var consequence_application_outcomes: Variant = active_spec.get(
			"application_outcomes", [])
		if consequence_application_outcomes is Array \
				and not (consequence_application_outcomes as Array).is_empty() \
				and not _has_current_application_receipt(state, bundle_id):
			return ""
		if not state["shown_consequences"].has(bundle_id):
			state["shown_consequences"].append(bundle_id)
		state["shown_consequence_turns"][bundle_id] = GameState.turn
		var legacy_receipt: Dictionary = {
			"consequence_id": bundle_id,
			"scheduled_bundle": "",
			"turn": int(GameState.turn),
			"status": "consumed",
			"surface_kind": "legacy_separate",
			"roots": resolved_event_roots(bundle_id),
			"presented_turn": int(GameState.turn),
			"consumed_turn": int(GameState.turn),
			"legacy_separate_owner": true,
		}
		state["consequence_receipts"][bundle_id] = legacy_receipt
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

static func _has_current_relationship_receipt(
		state: Dictionary, bundle_id: String) -> bool:
	for raw_receipt in state["relationship_choice_receipts"].values():
		if raw_receipt is Dictionary \
				and str((raw_receipt as Dictionary).get(
					"bundle_id", "")) == bundle_id \
				and int((raw_receipt as Dictionary).get(
					"turn", -1)) == int(GameState.turn):
			return true
	return false

static func _has_current_application_receipt(
		state: Dictionary, bundle_id: String) -> bool:
	for raw_receipt in state["application_transition_receipts"].values():
		if raw_receipt is Dictionary \
				and str((raw_receipt as Dictionary).get(
					"bundle_id", "")) == bundle_id \
				and int((raw_receipt as Dictionary).get(
					"turn", -1)) == int(GameState.turn):
			return true
	return false

static func cancel_active_bundle() -> void:
	var state := _normalized_state(GameState.core_loop_v2_state)
	state["active_bundle"] = ""
	state["active_kind"] = ""
	state["active_turn"] = 0
	state["action_result_ready"] = false
	GameState.core_loop_v2_state = state

## Attach at most one eligible conditional consequence to this week's
## scheduled owner. The receipt is written before StoryMode opens, so a save
## inside the prelude cannot replay it or create another foreground owner.
static func claim_scheduled_prelude(scheduled_bundle: String) -> Dictionary:
	var state := _normalized_state(GameState.core_loop_v2_state)
	if scheduled_bundle.is_empty() \
			or str(state.get("active_bundle", "")) != scheduled_bundle \
			or str(state.get("active_kind", "")) != "schedule" \
			or int(state.get("active_turn", 0)) != int(GameState.turn):
		return {"ok": false, "error": "scheduled_owner_mismatch"}
	var existing := _scheduled_prelude_receipt_from_state(
		state, scheduled_bundle, int(GameState.turn))
	if not existing.is_empty():
		return {
			"ok": true,
			"claimed": false,
			"receipt": existing,
		}
	var consequence_id := pending_consequence_id()
	if consequence_id.is_empty():
		return {"ok": true, "claimed": false, "receipt": {}}
	var roots := resolved_event_roots(consequence_id)
	if roots.is_empty():
		return {
			"ok": false,
			"error": "missing_consequence_roots",
			"consequence_id": consequence_id,
		}
	var scheduled_spec := bundle(scheduled_bundle)
	var surface_kind := ""
	if scheduled_spec.get("existing_roots", []) is Array \
			and not (scheduled_spec.get("existing_roots", []) as Array).is_empty():
		surface_kind = "story"
	elif not str(scheduled_spec.get("action_id", "")).is_empty():
		surface_kind = "action"
	if surface_kind.is_empty():
		return {
			"ok": false,
			"error": "missing_scheduled_surface",
			"scheduled_bundle": scheduled_bundle,
		}
	var receipt := {
		"consequence_id": consequence_id,
		"scheduled_bundle": scheduled_bundle,
		"turn": int(GameState.turn),
		"status": "presented",
		"surface_kind": surface_kind,
		"roots": roots.duplicate(),
		"presented_turn": int(GameState.turn),
		"consumed_turn": 0,
		"legacy_separate_owner": false,
	}
	state["consequence_receipts"][consequence_id] = receipt
	if not state["shown_consequences"].has(consequence_id):
		state["shown_consequences"].append(consequence_id)
	state["shown_consequence_turns"][consequence_id] = int(GameState.turn)
	GameState.core_loop_v2_state = state
	return {
		"ok": true,
		"claimed": true,
		"receipt": receipt.duplicate(true),
	}

static func scheduled_prelude_receipt(
		scheduled_bundle: String = "", target_turn: int = -1) -> Dictionary:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var owner := scheduled_bundle.strip_edges()
	if owner.is_empty():
		owner = str(state.get("active_bundle", "")).strip_edges()
	var receipt_turn := target_turn if target_turn > 0 else int(GameState.turn)
	return _scheduled_prelude_receipt_from_state(
		state, owner, receipt_turn)

## StoryMode's return consumes the attached prelude. Repeated callbacks return
## the same receipt without changing state, applying effects, or opening roots.
static func consume_scheduled_prelude(
		scheduled_bundle: String) -> Dictionary:
	var state := _normalized_state(GameState.core_loop_v2_state)
	if scheduled_bundle.is_empty() \
			or str(state.get("active_bundle", "")) != scheduled_bundle \
			or str(state.get("active_kind", "")) != "schedule" \
			or int(state.get("active_turn", 0)) != int(GameState.turn):
		return {"ok": false, "error": "scheduled_owner_mismatch"}
	var receipt := _scheduled_prelude_receipt_from_state(
		state, scheduled_bundle, int(GameState.turn))
	if receipt.is_empty():
		return {"ok": false, "error": "missing_prelude_receipt"}
	if str(receipt.get("status", "")) == "consumed":
		return {
			"ok": true,
			"consumed": false,
			"receipt": receipt,
		}
	if str(receipt.get("status", "")) != "presented":
		return {"ok": false, "error": "invalid_prelude_status"}
	var consequence_id := str(receipt.get("consequence_id", ""))
	if consequence_id.is_empty():
		return {"ok": false, "error": "missing_consequence_id"}
	var consequence_spec := bundle(consequence_id)
	var application_outcomes: Variant = consequence_spec.get(
		"application_outcomes", [])
	if application_outcomes is Array \
			and not (application_outcomes as Array).is_empty() \
			and not _has_current_application_receipt(
				state, consequence_id):
		return {
			"ok": false,
			"error": "missing_application_transition_receipt",
			"consequence_id": consequence_id,
		}
	receipt["status"] = "consumed"
	receipt["consumed_turn"] = int(GameState.turn)
	state["consequence_receipts"][consequence_id] = receipt
	GameState.core_loop_v2_state = state
	return {
		"ok": true,
		"consumed": true,
		"receipt": receipt.duplicate(true),
	}

static func _scheduled_prelude_receipt_from_state(
		state: Dictionary, scheduled_bundle: String,
		target_turn: int) -> Dictionary:
	if scheduled_bundle.is_empty() or target_turn < 1:
		return {}
	for raw_receipt in state["consequence_receipts"].values():
		if raw_receipt is Dictionary \
				and str((raw_receipt as Dictionary).get(
					"scheduled_bundle", "")) == scheduled_bundle \
				and int((raw_receipt as Dictionary).get(
					"turn", 0)) == target_turn:
			return (raw_receipt as Dictionary).duplicate(true)
	return {}

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
		# Typed completed_bundle predicates are evaluated against the strictly
		# earlier turns here. A scheduled action can never summon its own
		# consequence during the same foreground week.
		if not _bundle_requirement_met(consequence, int(GameState.turn)):
			continue
		# Schema-2 contracts used one hard-coded application producer. Keep the
		# old save route until every authored consequence owns typed predicates.
		if int(contract().get("schema_version", 1)) < 3 \
				and consequence_id == "opening_interview_math" \
				and not bool(GameState.flags.get(
					"opening_interview_application_sent", false)):
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
	GameState.core_loop_v2_state = state

static func story_follow_up_is_suppressed(
		event_id: String, choice_index: int, follow_up_id: String) -> bool:
	if event_id.is_empty() or choice_index < 0 or follow_up_id.is_empty():
		return false
	var state := _normalized_state(GameState.core_loop_v2_state)
	var key := "%s:%d" % [event_id, choice_index]
	return str(state["suppressed_followups"].get(key, "")) == follow_up_id

static func restore_story_bundle_followups() -> void:
	var state := _normalized_state(GameState.core_loop_v2_state)
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
	var relationship_recorded := _note_relationship_story_choice(
		state, event_id, choice_index)
	if relationship_recorded:
		state = _normalized_state(GameState.core_loop_v2_state)
	var application_recorded := _note_application_story_choice(
		state, event_id, choice_index)
	return relationship_recorded or application_recorded

static func _note_relationship_story_choice(
		state: Dictionary, event_id: String, choice_index: int) -> bool:
	var bundle_id := _story_outcome_owner_id(
		state, event_id, "relationship_outcomes")
	if bundle_id.is_empty():
		return false
	var scene_bundle := bundle(bundle_id)
	var raw_outcomes: Variant = scene_bundle.get(
		"relationship_outcomes", [])
	if not raw_outcomes is Array:
		return false
	for raw_outcome in raw_outcomes:
		if not raw_outcome is Dictionary:
			continue
		var outcome: Dictionary = raw_outcome
		if str(outcome.get("event_id", "")) != event_id:
			continue
		var choices: Variant = outcome.get("choices", [])
		if not choices is Array and outcome.has("choice_index"):
			choices = [int(outcome.get("choice_index", -1))]
		if not choices is Array:
			return false
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
			return state["relationship_choice_receipts"][receipt_key] is Dictionary
		var character_id := str(outcome.get("character", ""))
		if character_id.is_empty():
			var characters: Array = scene_bundle.get("characters", [])
			if not characters.is_empty():
				character_id = str(characters[0])
		var contract_schema := int(contract().get("schema_version", 1))
		var from_stage := str(outcome.get("from", ""))
		var target_stage := str(outcome.get("to", ""))
		var initiative := str(outcome.get("initiative", ""))
		var memory := str(outcome.get("memory", "")).strip_edges()
		if contract_schema < 3:
			if target_stage.is_empty():
				target_stage = str(outcome.get("stage", ""))
			if from_stage.is_empty():
				from_stage = str(
					state["relationship_stages"].get(character_id, "unmet"))
			if initiative.is_empty():
				initiative = str(scene_bundle.get("initiated_by", "system"))
			if memory.is_empty():
				memory = "%s:%d" % [event_id, choice_index]
		if character_id.is_empty() or from_stage.is_empty() \
				or target_stage.is_empty() or initiative.is_empty() \
				or memory.is_empty():
			return false
		var current_stage := str(
			state["relationship_stages"].get(character_id, "unmet"))
		if current_stage != from_stage:
			return false
		var current_rank := RELATIONSHIP_STAGE_ORDER.find(current_stage)
		var target_rank := RELATIONSHIP_STAGE_ORDER.find(target_stage)
		if target_rank < 0 or current_rank < 0 or target_rank < current_rank:
			return false
		if target_stage != current_stage \
				and _relationship_advanced_in_month(
					state, character_id, month_for_turn(GameState.turn)):
			return false
		if target_stage != current_stage:
			state["relationship_stages"][character_id] = target_stage
		var receipt := {
			"receipt_key": receipt_key,
			"character": character_id,
			"from": current_stage,
			"to": target_stage,
			"initiative": initiative,
			"memory": memory,
			"bundle_id": bundle_id,
			"event_id": event_id,
			"choice_index": choice_index,
			"turn": int(GameState.turn),
		}
		state["relationship_history"].append(receipt.duplicate(true))
		state["relationship_memories"].append(receipt.duplicate(true))
		if initiative == "player" \
				and not state["player_initiated"].has(character_id):
			state["player_initiated"].append(character_id)
		state["relationship_choice_receipts"][receipt_key] = receipt
		for raw_callback_id in outcome.get("supersedes_callbacks", []):
			var callback_id := str(raw_callback_id).strip_edges()
			if callback_id.is_empty():
				continue
			state["legacy_callback_resolutions"][callback_id] = {
				"policy": "superseded",
				"source_bundle": bundle_id,
				"source_event_id": event_id,
				"choice_index": choice_index,
				"relationship_memory": memory,
				"replacement_bundle": str(
					outcome.get("replacement_bundle", "")),
				"turn": int(GameState.turn),
			}
		GameState.core_loop_v2_state = state
		return true
	return false

static func _relationship_advanced_in_month(
		state: Dictionary, character_id: String, month_index: int) -> bool:
	for raw_receipt in state["relationship_history"]:
		if not raw_receipt is Dictionary:
			continue
		var receipt: Dictionary = raw_receipt
		if str(receipt.get("character", "")) != character_id \
				or str(receipt.get("from", "")) == str(receipt.get("to", "")):
			continue
		if month_for_turn(int(receipt.get("turn", 0))) == month_index:
			return true
	return false

static func _note_application_story_choice(
		state: Dictionary, event_id: String, choice_index: int) -> bool:
	var bundle_id := _story_outcome_owner_id(
		state, event_id, "application_outcomes")
	if bundle_id.is_empty():
		return false
	var scene_bundle := bundle(bundle_id)
	var raw_outcomes: Variant = scene_bundle.get(
		"application_outcomes", [])
	if not raw_outcomes is Array:
		return false
	for raw_outcome in raw_outcomes:
		if not raw_outcome is Dictionary:
			continue
		var outcome: Dictionary = raw_outcome
		if str(outcome.get("event_id", "")) != event_id \
				or not _outcome_choice_matches(outcome, choice_index):
			continue
		var receipt_key := "%s:%s:%d:%d" % [
			bundle_id, event_id, choice_index, int(GameState.turn)]
		if state["application_transition_receipts"].has(receipt_key):
			return state["application_transition_receipts"][
				receipt_key] is Dictionary
		var application_id := str(
			outcome.get("application_id", "")).strip_edges()
		var from_status := str(outcome.get("from", "")).strip_edges()
		var to_status := str(outcome.get("to", "")).strip_edges()
		if application_id.is_empty() or from_status.is_empty() \
				or to_status.is_empty() or from_status == to_status:
			return false
		var current_status := application_status(application_id)
		if current_status != from_status:
			return false
		var receipt := {
			"receipt_key": receipt_key,
			"application_id": application_id,
			"from": from_status,
			"to": to_status,
			"bundle_id": bundle_id,
			"event_id": event_id,
			"choice_index": choice_index,
			"turn": int(GameState.turn),
		}
		state["application_statuses"][application_id] = to_status
		state["application_transition_receipts"][receipt_key] = receipt
		GameState.core_loop_v2_state = state
		return true
	return false

static func _story_outcome_owner_id(
		state: Dictionary, event_id: String, outcome_field: String) -> String:
	var candidate_ids: Array[String] = []
	var active_id := str(state.get("active_bundle", "")).strip_edges()
	if _bundle_declares_event_outcome(active_id, event_id, outcome_field):
		candidate_ids.append(active_id)
	var prelude := _scheduled_prelude_receipt_from_state(
		state, active_id, int(GameState.turn))
	var consequence_id := str(
		prelude.get("consequence_id", "")).strip_edges()
	if not consequence_id.is_empty() \
			and consequence_id != active_id \
			and _bundle_declares_event_outcome(
				consequence_id, event_id, outcome_field):
		candidate_ids.append(consequence_id)
	# Never search every bundle globally: the same event root may be reused by
	# another month. A story choice is valid only when exactly one live owner
	# declares it.
	return candidate_ids[0] if candidate_ids.size() == 1 else ""

static func _bundle_declares_event_outcome(
		bundle_id: String, event_id: String, outcome_field: String) -> bool:
	if bundle_id.is_empty() or event_id.is_empty():
		return false
	var raw_outcomes: Variant = bundle(bundle_id).get(outcome_field, [])
	if not raw_outcomes is Array:
		return false
	for raw_outcome in raw_outcomes:
		if raw_outcome is Dictionary \
				and str((raw_outcome as Dictionary).get(
					"event_id", "")) == event_id:
			return true
	return false

static func _outcome_choice_matches(
		outcome: Dictionary, choice_index: int) -> bool:
	var choices: Variant = outcome.get("choices", [])
	if not choices is Array and outcome.has("choice_index"):
		choices = [int(outcome.get("choice_index", -1))]
	if not choices is Array:
		return false
	for raw_choice in choices:
		if int(raw_choice) == choice_index:
			return true
	return false

static func _bundle_requirement_met(
		scene_bundle: Dictionary, completed_before_turn: int = -1) -> bool:
	if scene_bundle.has("prerequisites"):
		var raw_prerequisites: Variant = scene_bundle.get("prerequisites", {})
		if not raw_prerequisites is Dictionary:
			return false
		var prerequisites: Dictionary = raw_prerequisites
		var has_all := prerequisites.has("all")
		var has_any := prerequisites.has("any")
		if not has_all and not has_any:
			return false
		var predicate_count := 0
		if has_all:
			var raw_all: Variant = prerequisites.get("all", [])
			if not raw_all is Array:
				return false
			predicate_count += (raw_all as Array).size()
			for raw_predicate in raw_all:
				if not raw_predicate is Dictionary \
						or not _predicate_met(
							raw_predicate, completed_before_turn):
					return false
		if has_any:
			var raw_any: Variant = prerequisites.get("any", [])
			if not raw_any is Array or (raw_any as Array).is_empty():
				return false
			predicate_count += (raw_any as Array).size()
			var any_met := false
			for raw_predicate in raw_any:
				if raw_predicate is Dictionary \
						and _predicate_met(
							raw_predicate, completed_before_turn):
					any_met = true
					break
			if not any_met:
				return false
		if predicate_count <= 0:
			return false

	# Schema-2 compatibility. B and later contracts must express these facts
	# through the typed prerequisite DSL above.
	if int(contract().get("schema_version", 1)) < 3:
		var required := str(scene_bundle.get("requires_completed_bundle", ""))
		if required.is_empty():
			required = str(scene_bundle.get("requires_prior_choice", ""))
		if not required.is_empty():
			var completed: Variant = GameState.core_loop_v2_state.get(
				"completed_bundles", [])
			if not completed is Array or not (completed as Array).has(required):
				return false
			if completed_before_turn > 0:
				var completed_turns: Variant = GameState.core_loop_v2_state.get(
					"completed_bundle_turns", {})
				if not completed_turns is Dictionary \
						or int((completed_turns as Dictionary).get(
							required, 0)) >= completed_before_turn:
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

static func _predicate_met(
		predicate: Dictionary, completed_before_turn: int = -1) -> bool:
	var kind := str(predicate.get("kind", "")).strip_edges()
	match kind:
		"completed_bundle":
			var bundle_id := str(predicate.get("bundle_id", "")).strip_edges()
			if bundle_id.is_empty() or not has_completed_bundle(bundle_id):
				return false
			if completed_before_turn > 0:
				var state := _normalized_state(GameState.core_loop_v2_state)
				var completed_turn := int(
					state["completed_bundle_turns"].get(bundle_id, 0))
				return completed_turn > 0 \
					and completed_turn < completed_before_turn
			return true
		"routine_selected":
			var track := str(predicate.get("track", "")).strip_edges()
			if track.is_empty():
				return false
			var state := _normalized_state(GameState.core_loop_v2_state)
			for raw_plan in state["plans"].values():
				if not raw_plan is Dictionary:
					continue
				var raw_routines: Variant = (raw_plan as Dictionary).get(
					"routines", {})
				if not raw_routines is Dictionary:
					continue
				if str((raw_routines as Dictionary).get("primary", "")) == track \
						or str((raw_routines as Dictionary).get(
							"secondary", "")) == track:
					return true
			return false
		"relationship_at_least":
			var character := str(predicate.get("character", "")).strip_edges()
			var required_stage := str(predicate.get("stage", "")).strip_edges()
			var current_stage := relationship_stage(character)
			# `closed` is a terminal route, not a rank above committed. Treating
			# it as the largest ordinal resurrects every earlier relationship
			# card after the player has explicitly ended that path.
			if current_stage == "closed":
				return false
			var current_rank := RELATIONSHIP_STAGE_ORDER.find(
				current_stage)
			var required_rank := RELATIONSHIP_STAGE_ORDER.find(required_stage)
			return not character.is_empty() and current_rank >= 0 \
				and required_rank >= 0 and current_rank >= required_rank
		"relationship_stage_is":
			var character := str(predicate.get("character", "")).strip_edges()
			var required_stage := str(predicate.get("stage", "")).strip_edges()
			return not character.is_empty() \
				and RELATIONSHIP_STAGE_ORDER.has(required_stage) \
				and relationship_stage(character) == required_stage
		"relationship_memory":
			var character := str(predicate.get("character", "")).strip_edges()
			var memory := str(predicate.get("memory", "")).strip_edges()
			if character.is_empty() or memory.is_empty():
				return false
			var state := _normalized_state(GameState.core_loop_v2_state)
			for raw_receipt in state["relationship_memories"]:
				if raw_receipt is Dictionary \
						and str((raw_receipt as Dictionary).get(
							"character", "")) == character \
						and str((raw_receipt as Dictionary).get(
							"memory", "")) == memory:
					return true
			return false
		"player_initiated":
			var character := str(predicate.get("character", "")).strip_edges()
			return not character.is_empty() and was_player_initiated(character)
		"current_job_id":
			var job_id := str(predicate.get("job_id", "")).strip_edges()
			return not job_id.is_empty() \
				and str(GameState.current_job.get("id", "")) == job_id
		"application_status":
			var application_id := str(
				predicate.get("application_id", "")).strip_edges()
			var expected_status := str(
				predicate.get("status", "")).strip_edges()
			return not application_id.is_empty() \
				and not expected_status.is_empty() \
				and application_status(application_id) == expected_status
		"application_status_not_in":
			var application_id := str(
				predicate.get("application_id", "")).strip_edges()
			var raw_statuses: Variant = predicate.get("statuses", [])
			if application_id.is_empty() or not raw_statuses is Array \
					or (raw_statuses as Array).is_empty():
				return false
			var current_status := application_status(application_id)
			for raw_status in raw_statuses:
				if current_status == str(raw_status).strip_edges():
					return false
			return true
	return false

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
	var source_schema := int(state.get("schema", 1))
	var legacy_prototype_complete := bool(
		state.get("prototype_complete", false))
	state["schema"] = SCHEMA
	state["enabled"] = bool(state.get("enabled", false))
	for key in [
		"plans", "completed_bundle_turns", "shown_consequence_turns",
		"relationship_stages", "relationship_choice_receipts",
		"suppressed_followups", "routine_receipts", "month_summaries",
		"month_opening_snapshots",
		"action_receipts", "application_statuses", "consequence_receipts",
		"application_transition_receipts",
		"legacy_callback_resolutions",
	]:
		if not state.has(key) or not state[key] is Dictionary:
			state[key] = {}
	for key in [
		"forgone", "completed_turns", "completed_bundles",
		"shown_consequences", "player_initiated", "pending_declines",
		"decline_receipts", "relationship_history", "relationship_memories",
	]:
		if not state.has(key) or not state[key] is Array:
			state[key] = []
	var normalized_summaries: Dictionary = {}
	for raw_month_key in state["month_summaries"]:
		var raw_summary: Variant = state["month_summaries"][raw_month_key]
		if not raw_summary is Dictionary:
			continue
		var summary: Dictionary = (raw_summary as Dictionary).duplicate(true)
		var after_raw: Variant = summary.get("after", {})
		var closing_money := 0.0
		if after_raw is Dictionary:
			closing_money = float(
				(after_raw as Dictionary).get("money", 0.0))
		summary["cash_shortfall"] = cash_shortfall_for_money(closing_money)
		normalized_summaries[str(raw_month_key)] = summary
	state["month_summaries"] = normalized_summaries
	for raw_consequence_id in state["shown_consequences"]:
		var consequence_id := str(raw_consequence_id).strip_edges()
		if consequence_id.is_empty() \
				or state["consequence_receipts"].has(consequence_id):
			continue
		state["consequence_receipts"][consequence_id] = {
			"consequence_id": consequence_id,
			"scheduled_bundle": "",
			"turn": int(state["shown_consequence_turns"].get(
				consequence_id, 0)),
			"status": "consumed",
			"surface_kind": "legacy_separate",
			"roots": resolved_event_roots(consequence_id),
			"presented_turn": int(state["shown_consequence_turns"].get(
				consequence_id, 0)),
			"consumed_turn": int(state["shown_consequence_turns"].get(
				consequence_id, 0)),
			"legacy_separate_owner": true,
		}
	if source_schema <= 2:
		_migrate_schema_two_relationship_state(state)
	state["active_bundle"] = str(state.get("active_bundle", ""))
	state["active_kind"] = str(state.get("active_kind", ""))
	state["active_turn"] = int(state.get("active_turn", 0))
	state["action_result_ready"] = bool(state.get("action_result_ready", false))
	_recover_finalized_action_state(state, source_schema)
	var completed_through := maxi(0, int(
		state.get("completed_through_week", 0)))
	if source_schema <= 2 and legacy_prototype_complete:
		completed_through = maxi(completed_through, 8)
	state["completed_through_week"] = completed_through
	state["development_cap_week"] = development_cap_week()
	state["prototype_complete"] = completed_through >= development_cap_week()
	state["prototype_completed_at_turn"] = int(
		state.get("prototype_completed_at_turn", 0))
	state["completed_at_turn"] = int(state.get(
		"completed_at_turn", state.get("prototype_completed_at_turn", 0)))
	return state

static func _recover_finalized_action_state(
		state: Dictionary, source_schema: int) -> void:
	# A finalized same-turn weekly commitment is the durable proof that AP and
	# effects already ran. Rebuild only the missing presentation receipt when a
	# signal consumer was disconnected, or when loading a schema-2 result save.
	# This path never invokes the action executor.
	if str(state.get("active_kind", "")) != "schedule":
		return
	var bundle_id := str(state.get("active_bundle", "")).strip_edges()
	var scene_bundle := bundle(bundle_id)
	var expected_action := str(
		scene_bundle.get("action_id", "")).strip_edges().to_lower()
	if bundle_id.is_empty() or expected_action.is_empty():
		return
	var active_turn := int(state.get("active_turn", 0))
	if active_turn < 1 and source_schema <= 2:
		active_turn = int(GameState.turn)
	state["active_turn"] = active_turn
	if active_turn < 1 or active_turn != int(GameState.turn) \
			or (state.get("completed_turns", []) as Array).has(active_turn):
		return
	var commitment := GameState.get_weekly_commitment_for_turn(active_turn)
	if str(commitment.get("pressure_id", "")) != bundle_id:
		return
	var recovered := _action_receipt_from_record(
		bundle_id, scene_bundle, commitment)
	if recovered.is_empty() \
			or int(recovered.get("turn", -1)) != active_turn \
			or str(recovered.get("action_id", "")).strip_edges().to_lower() \
				!= expected_action:
		return
	var existing: Variant = state["action_receipts"].get(bundle_id, {})
	if existing is Dictionary and not (existing as Dictionary).is_empty():
		if int((existing as Dictionary).get("turn", -1)) != active_turn \
				or str((existing as Dictionary).get(
					"action_id", "")).strip_edges().to_lower() \
					!= expected_action:
			return
		var prior_application_id := str(
			(existing as Dictionary).get("application_id", ""))
		var prior_status := str(
			(existing as Dictionary).get("application_status", ""))
		if not prior_application_id.is_empty() and not prior_status.is_empty():
			state["application_statuses"][prior_application_id] = prior_status
	else:
		state["action_receipts"][bundle_id] = recovered
	var receipt: Dictionary = state["action_receipts"][bundle_id]
	var application_id := str(receipt.get("application_id", ""))
	var status := str(receipt.get("application_status", ""))
	if not application_id.is_empty() and not status.is_empty():
		state["application_statuses"][application_id] = status
	state["action_result_ready"] = true

static func _migrate_schema_two_relationship_state(state: Dictionary) -> void:
	var completed: Array = state.get("completed_bundles", [])
	var stages: Dictionary = state.get("relationship_stages", {})
	# A1's shortest father-call result used `met`. B standardized every actual
	# first-call result as an `opening`; without this one-time lift, the visible
	# quiet-call card could never satisfy its strict opening→result mapping.
	if completed.has("father_first_call") \
			and str(stages.get("father", "unmet")) == "met":
		stages["father"] = "opening"
		state["relationship_stages"] = stages

	var old_receipts: Dictionary = state.get(
		"relationship_choice_receipts", {})
	var histories: Array = state.get("relationship_history", [])
	var identities: Dictionary = {}
	for raw_key in old_receipts:
		var key := str(raw_key)
		var identity := _legacy_relationship_receipt_identity(key)
		if not identity.is_empty():
			identities[key] = identity
	for raw_history in histories:
		if not raw_history is Dictionary:
			continue
		var history: Dictionary = raw_history
		var bundle_id := str(history.get("bundle_id", ""))
		var event_id := str(history.get("event_id", ""))
		var choice_index := int(history.get("choice_index", -1))
		var turn := int(history.get("turn", -1))
		if bundle_id.is_empty() or event_id.is_empty() \
				or choice_index < 0 or turn < 1:
			continue
		var key := "%s:%s:%d:%d" % [
			bundle_id, event_id, choice_index, turn]
		identities[key] = {
			"bundle_id": bundle_id,
			"event_id": event_id,
			"choice_index": choice_index,
			"turn": turn,
		}

	var migrated_receipts := old_receipts.duplicate(true)
	var memories: Array = state.get("relationship_memories", [])
	var memory_keys: Array[String] = []
	for raw_memory in memories:
		if raw_memory is Dictionary:
			memory_keys.append(str((raw_memory as Dictionary).get(
				"receipt_key", "")))
	for raw_key in identities:
		var key := str(raw_key)
		var identity: Dictionary = identities[raw_key]
		var outcome := _relationship_outcome_for_choice(
			str(identity.get("bundle_id", "")),
			str(identity.get("event_id", "")),
			int(identity.get("choice_index", -1)))
		if outcome.is_empty():
			continue
		var receipt := {
			"receipt_key": key,
			"character": str(outcome.get("character", "")),
			"from": str(outcome.get("from", "")),
			"to": str(outcome.get("to", outcome.get("stage", ""))),
			"initiative": str(outcome.get("initiative", "")),
			"memory": str(outcome.get("memory", "")),
			"bundle_id": str(identity.get("bundle_id", "")),
			"event_id": str(identity.get("event_id", "")),
			"choice_index": int(identity.get("choice_index", -1)),
			"turn": int(identity.get("turn", -1)),
		}
		if str(receipt.get("character", "")).is_empty() \
				or str(receipt.get("from", "")).is_empty() \
				or str(receipt.get("to", "")).is_empty() \
				or str(receipt.get("initiative", "")).is_empty() \
				or str(receipt.get("memory", "")).is_empty():
			continue
		migrated_receipts[key] = receipt
		if not memory_keys.has(key):
			memories.append(receipt.duplicate(true))
			memory_keys.append(key)
		for history_index in range(histories.size()):
			var raw_history: Variant = histories[history_index]
			if not raw_history is Dictionary:
				continue
			var history: Dictionary = (raw_history as Dictionary).duplicate(true)
			if str(history.get("bundle_id", "")) \
						!= str(receipt.get("bundle_id", "")) \
					or str(history.get("event_id", "")) \
						!= str(receipt.get("event_id", "")) \
					or int(history.get("choice_index", -1)) \
						!= int(receipt.get("choice_index", -1)) \
					or int(history.get("turn", -1)) \
						!= int(receipt.get("turn", -1)):
				continue
			history["initiative"] = str(receipt.get("initiative", ""))
			history["memory"] = str(receipt.get("memory", ""))
			histories[history_index] = history
			break
	state["relationship_choice_receipts"] = migrated_receipts
	state["relationship_memories"] = memories
	state["relationship_history"] = histories

static func _legacy_relationship_receipt_identity(key: String) -> Dictionary:
	var parts := key.split(":")
	if parts.size() != 4:
		return {}
	var choice_index := int(parts[2])
	var turn := int(parts[3])
	if str(parts[0]).is_empty() or str(parts[1]).is_empty() \
			or choice_index < 0 or turn < 1:
		return {}
	return {
		"bundle_id": str(parts[0]),
		"event_id": str(parts[1]),
		"choice_index": choice_index,
		"turn": turn,
	}

static func _relationship_outcome_for_choice(
		bundle_id: String, event_id: String, choice_index: int) -> Dictionary:
	var scene_bundle := bundle(bundle_id)
	var raw_outcomes: Variant = scene_bundle.get("relationship_outcomes", [])
	if not raw_outcomes is Array:
		return {}
	for raw_outcome in raw_outcomes:
		if not raw_outcome is Dictionary:
			continue
		var outcome: Dictionary = raw_outcome
		if str(outcome.get("event_id", "")) != event_id:
			continue
		var raw_choices: Variant = outcome.get("choices", [])
		if not raw_choices is Array:
			continue
		for raw_choice in raw_choices:
			if int(raw_choice) == choice_index:
				return outcome.duplicate(true)
	return {}
