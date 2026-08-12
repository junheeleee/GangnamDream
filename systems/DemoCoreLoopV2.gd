extends RefCounted
## 단계별 데모의 월간 계획·약속·놓친 길 저장 계약.
## fresh 실행은 24주 서울 사이클을 쓰고, 구 저장과 25~240주 편성은 호환 폴백한다.

const SCHEMA := 3
const ACTIVITY_TASK_SESSION_SCHEMA := 1
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
	"v2_opening_application_send",
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
	"v2_father_health_signal",
	"v2_dodam_result_message",
	"v2_city_service_work_sample_message",
	"v2_city_service_result_message",
	"v2_daeun_tuesday_followthrough",
	"v2_hyunsu_exam_eve",
	"v2_hyunsu_exam_morning_echo",
	"v2_gangnam_receipt_walk",
	"v2_dirty_trace_initial_call",
	"v2_dirty_recruiter_week24",
	"v2_demo_first_bill_opening",
	"v2_demo_first_bill",
	"v2_m3_room_ledger_anchor",
	"v2_m4_housing_consultation_anchor",
	"v2_opening_return_math",
]
const ENABLE_ARGS := [
	"--core-loop-v2",
	"core-loop-v2",
	"--qa=core-loop-v2",
	"qa=core-loop-v2",
]
const HYUNSU_EXAM_OUTCOME_RECEIPT_ID := "hyunsu_exam_2026"
const CITY_RESULT_RECEIPT_ID := "city_facility_ops_2026h1_result"
const OPENING_INTERVIEW_BUNDLE_ID := "opening_interview_math"
const OPENING_APPLICATION_EVENT_ID := "v2_opening_application_send"
const LEGACY_OPENING_INTERVIEW_ROOT := "arc_intro_01_meal"
const W1_ONBOARDING_STATE_KEY := "w1_resume_onboarding"
const W1_ONBOARDING_SCHEMA := 1
const W1_ONBOARDING_ORIGIN := "fresh_order101"
const W1_ONBOARDING_NODE_ID := "resume"
const W1_ONBOARDING_BUNDLE_ID := "m1_youth_center_resume_clinic"
const W1_ONBOARDING_APPLICATION_ID := "mirae_industrial_tech"
const FIRST_BILL_OPENING_ID := "v2_demo_first_bill_opening"
const FIRST_BILL_DECISION_ID := "v2_demo_first_bill"
const FIRST_BILL_LEDGER_ID := "v2_demo_first_bill_ledger"
const FIRST_BILL_REPLAY_SCHEMA := 1
const FIRST_BILL_FATHER_MEMORY_IDS := [
	"father_neighbor_detail_checked",
	"father_called_again_that_evening",
	"father_health_warning_postponed",
]
# These Week-24 callbacks already own an exact deferred receipt. Their generic
# story-choice receipts were a second, readerless copy of the same choice.
const EXACT_DEFERRED_CHOICE_ROOTS := [
	"v2_dirty_trace_initial_call",
	"v2_dirty_recruiter_week24",
]
const MONTH_ONE_EPISODE_MODE := "month_one_episode_v1"
const SEOUL_CYCLE_SCHEMA := 1
const SEOUL_CYCLE_MODE := "seoul_cycle_v1"
const SEOUL_CYCLE_TRIGGER_PLAYER_REQUIRED := "player_required"
const SEOUL_CYCLE_STATE_KEY := "seoul_cycle"
const MONTH_ONE_EPISODE_TOKEN := "{v2_month_one_episode_echo}"
const FIRST_BILL_STORY_TOKENS := [
	MONTH_ONE_EPISODE_TOKEN,
	"{v2_first_bill_body}",
	"{v2_first_bill_trace}",
	"{v2_first_bill_evidence}",
	"{v2_first_bill_after_bills}",
	"{v2_first_bill_tradeoffs}",
	"{v2_first_bill_return}",
	"{v2_first_bill_done}",
	"{v2_first_bill_not_done}",
	"{v2_first_bill_deadline_missed}",
	"{v2_hyunsu_exam_eve_memory}",
]

static func contract() -> Dictionary:
	return DataRegistry.demo_core_loop_v2

static func _hyunsu_exam_contract() -> Dictionary:
	var raw_contracts: Variant = contract().get(
		"future_story_contracts", {})
	if not raw_contracts is Dictionary:
		return {}
	var raw_spec: Variant = (raw_contracts as Dictionary).get(
		HYUNSU_EXAM_OUTCOME_RECEIPT_ID, {})
	if not raw_spec is Dictionary:
		return {}
	var spec: Dictionary = (raw_spec as Dictionary).duplicate(true)
	var raw_memories: Variant = spec.get("required_memories", [])
	if not raw_memories is Array:
		return {}
	var memories: Array[String] = []
	for raw_memory in raw_memories:
		var memory_id := str(raw_memory).strip_edges()
		if not memory_id.is_empty() and not memories.has(memory_id):
			memories.append(memory_id)
	var producer_bundle := str(
		spec.get("producer_bundle", "")).strip_edges()
	var trigger_event := str(
		spec.get("trigger_event", "")).strip_edges()
	var trigger_flag := str(
		spec.get("trigger_flag", "")).strip_edges()
	var canonical_outcome := str(
		spec.get("canonical_outcome", "")).strip_edges()
	var result_event := str(
		spec.get("result_event", "")).strip_edges()
	var unanswered_source := str(
		spec.get("unanswered_source", "")).strip_edges()
	var decline_outcome := str(
		spec.get("decline_outcome", "")).strip_edges()
	var exam_week := int(spec.get("exam_week", 0))
	var available_week := int(spec.get(
		"result_available_week", 0))
	if memories.is_empty() \
			or producer_bundle.is_empty() \
			or trigger_event.is_empty() \
			or trigger_flag.is_empty() \
			or canonical_outcome.is_empty() \
			or result_event.is_empty() \
			or unanswered_source.is_empty() \
			or memories.has(unanswered_source) \
			or decline_outcome.is_empty() \
			or exam_week < 1 \
			or available_week <= exam_week \
			or bool(spec.get("choice_changes_outcome", true)):
		return {}
	spec["required_memories"] = memories
	spec["producer_bundle"] = producer_bundle
	spec["trigger_event"] = trigger_event
	spec["trigger_flag"] = trigger_flag
	spec["canonical_outcome"] = canonical_outcome
	spec["result_event"] = result_event
	spec["unanswered_source"] = unanswered_source
	spec["decline_outcome"] = decline_outcome
	spec["exam_week"] = exam_week
	spec["result_available_week"] = available_week
	return spec

static func _city_result_contract() -> Dictionary:
	var raw_contracts: Variant = contract().get(
		"post_demo_application_contracts", {})
	if not raw_contracts is Dictionary:
		return {}
	var raw_spec: Variant = (raw_contracts as Dictionary).get(
		CITY_RESULT_RECEIPT_ID, {})
	if not raw_spec is Dictionary:
		return {}
	var spec: Dictionary = (raw_spec as Dictionary).duplicate(true)
	for field in [
		"producer_bundle", "producer_event",
		"selected_obligation_id", "application_id",
		"from", "to", "result_event", "result_flag",
	]:
		var value := str(spec.get(field, "")).strip_edges()
		if value.is_empty():
			return {}
		spec[field] = value
	var producer_choice := int(spec.get(
		"producer_choice", -1))
	var not_before_week := int(spec.get(
		"not_before_week", 0))
	var not_after_week := int(spec.get(
		"not_after_week", 0))
	if producer_choice < 0 or not_before_week <= 24 \
			or not_after_week < not_before_week \
			or str(spec["from"]) == str(spec["to"]):
		return {}
	spec["producer_choice"] = producer_choice
	spec["not_before_week"] = not_before_week
	spec["not_after_week"] = not_after_week
	return spec

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
	# The retail switch lives in the data contract. It remains false until the
	# unchanged 24-week candidate receives its human GO; the playtest build
	# feature deliberately does not bypass the dedicated StartMenu entry.
	return bool(contract().get("runtime_default", false))

static func initialize_for_run(force: bool = false) -> bool:
	if not force and not requested():
		return false
	migrate_legacy_first_bill_state()
	var state := _normalized_state(GameState.core_loop_v2_state)
	state["enabled"] = true
	_apply_legacy_callback_retirements(state)
	GameState.core_loop_v2_state = state
	return true

## ORDER-101 fresh-only onboarding owner. The marker is deliberately created
## before the prologue queue starts, so the legacy pre-plan recovery path can
## continue to identify older saves by the absence of this exact provenance.
static func begin_fresh_w1_onboarding() -> bool:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var existing: Dictionary = state.get(W1_ONBOARDING_STATE_KEY, {})
	if not existing.is_empty():
		return str(existing.get("origin", "")) == W1_ONBOARDING_ORIGIN \
			and int(existing.get("turn", 0)) == 1
	if not bool(state.get("enabled", false)) \
			or int(GameState.turn) != 1 \
			or str(state.get("run_generation", "")) \
				!= GameState.CORE_LOOP_V2_ELIGIBLE_RUN_GENERATION \
			or not (state.get("plans", {}) as Dictionary).is_empty() \
			or bool(GameState.flags.get("story_job_unlocked", false)) \
			or bool(GameState.flags.get(
				"opening_interview_application_sent", false)) \
			or not application_status(W1_ONBOARDING_APPLICATION_ID).is_empty():
		return false
	state[W1_ONBOARDING_STATE_KEY] = {
		"schema": W1_ONBOARDING_SCHEMA,
		"origin": W1_ONBOARDING_ORIGIN,
		"turn": 1,
		"node_id": W1_ONBOARDING_NODE_ID,
		"bundle_id": W1_ONBOARDING_BUNDLE_ID,
		"application_id": W1_ONBOARDING_APPLICATION_ID,
		"phase": "prologue",
		"selected_capacity_id": "",
		"selected_capacity_value": 0,
		"quality": -1,
	}
	GameState.core_loop_v2_state = state
	return true

static func fresh_w1_onboarding_snapshot() -> Dictionary:
	var state := _normalized_state(GameState.core_loop_v2_state)
	return (state.get(W1_ONBOARDING_STATE_KEY, {}) as Dictionary).duplicate(true)

static func fresh_w1_onboarding_phase() -> String:
	return str(fresh_w1_onboarding_snapshot().get("phase", ""))

static func fresh_w1_onboarding_pending() -> bool:
	var phase := fresh_w1_onboarding_phase()
	return not phase.is_empty() and phase != "consumed"

static func _fresh_w1_onboarding_allocation_gate(
		state: Dictionary, month_index: int, node_id: String = "") -> bool:
	var onboarding: Dictionary = state.get(W1_ONBOARDING_STATE_KEY, {})
	return month_index == 1 and int(GameState.turn) == 1 \
		and str(onboarding.get("origin", "")) == W1_ONBOARDING_ORIGIN \
		and str(onboarding.get("phase", "")) in ["prologue", "board"] \
		and (node_id.is_empty() \
			or node_id == str(onboarding.get("node_id", "")))

## V2 does not infer a permanent saver/investor/founder identity from the old
## pre-action declaration. Keep every legacy flag and tendency intact for save
## compatibility, but persist the contract-owned callback retirement so the
## 25+ week fallback cannot narrate an action that never happened in this run.
static func _apply_legacy_callback_retirements(state: Dictionary) -> void:
	var raw_retirements: Variant = contract().get(
		"legacy_callback_retirements", {})
	if not raw_retirements is Dictionary:
		return
	for raw_callback_id in raw_retirements:
		var callback_id := str(raw_callback_id).strip_edges()
		var raw_policy: Variant = (raw_retirements as Dictionary).get(
			raw_callback_id, {})
		if callback_id.is_empty() or not raw_policy is Dictionary:
			continue
		var policy: Dictionary = raw_policy
		if str(policy.get("policy", "")) != "superseded" \
				or str(policy.get("scope", "")) != "core_loop_v2" \
				or not bool(policy.get("preserve_legacy", false)):
			continue
		var raw_existing: Variant = state[
			"legacy_callback_resolutions"].get(callback_id, {})
		if raw_existing is Dictionary \
				and not (raw_existing as Dictionary).is_empty():
			continue
		state["legacy_callback_resolutions"][callback_id] = {
			"policy": "superseded",
			"source": "core_loop_v2_contract",
			"scope": "core_loop_v2",
			"preserve_legacy": true,
			"reason_ko": str(policy.get("reason_ko", "")),
			"reason_en": str(policy.get("reason_en", "")),
			"turn": int(GameState.turn),
		}

static func disable_for_run() -> void:
	var state := _normalized_state(GameState.core_loop_v2_state)
	state["enabled"] = false
	state["active_bundle"] = ""
	state["active_kind"] = ""
	state["active_turn"] = 0
	state["action_result_ready"] = false
	state["activity_task_session"] = {}
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
	var boundary_was_already_complete := (
		bool(state.get("prototype_complete", false))
		or int(state.get("completed_through_week", 0)) >= cap
		or int(state.get("completed_at_turn", 0)) == cap + 1
		or int(state.get("prototype_completed_at_turn", 0)) == cap + 1
	)
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
	state["activity_task_session"] = {}
	GameState.core_loop_v2_state = state
	# Freeze the completed boundary after every receipt and the final month
	# summary exist. Later chapters may extend relationships, applications, and
	# callbacks; reopening this recap must still show the exact Week-24 record.
	var frozen_snapshot := completion_snapshot(not boundary_was_already_complete)
	state = _normalized_state(GameState.core_loop_v2_state)
	state["completion_snapshots"][str(cap)] = frozen_snapshot.duplicate(true)
	GameState.core_loop_v2_state = state
	return true

static func mark_prototype_complete() -> bool:
	return mark_development_complete()

static func completion_snapshot(trusted_fresh_boundary: bool = false) -> Dictionary:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var cap := development_cap_week()
	var raw_frozen: Variant = (
		state.get("completion_snapshots", {}) as Dictionary
	).get(str(cap), {})
	if raw_frozen is Dictionary \
			and _completion_snapshot_is_valid(raw_frozen as Dictionary, cap):
		return (raw_frozen as Dictionary).duplicate(true)
	var final_month := month_for_turn(cap)
	var completed_through := int(state.get("completed_through_week", 0))
	# Only mark_development_complete() may identify the exact transaction that
	# just produced the final month summary. A loaded pre-snapshot completion at
	# turn 25 looks identical numerically but must remain explicitly incomplete.
	var late_unfrozen_boundary := completed_through >= cap \
		and not trusted_fresh_boundary
	var completed_turns: Array = state.get("completed_turns", [])
	var kept: Array = []
	for month_index in range(1, final_month + 1):
		var plan := plan_for_month(month_index)
		if plan_uses_seoul_cycle(plan):
			var raw_cycle_summary: Variant = (
				state.get("month_summaries", {}) as Dictionary
			).get(str(month_index), {})
			if raw_cycle_summary is Dictionary:
				for raw_kept in (raw_cycle_summary as Dictionary).get("kept", []):
					if not raw_kept is Dictionary:
						continue
					var cycle_record: Dictionary = (
						raw_kept as Dictionary).duplicate(true)
					var cycle_week := int(cycle_record.get("week", 0))
					var cycle_bundle := str(cycle_record.get(
						"bundle_id", "")).strip_edges()
					if cycle_week >= 1 and cycle_week <= cap \
							and completed_turns.has(cycle_week) \
							and not cycle_bundle.is_empty():
						cycle_record["month"] = month_index
						kept.append(cycle_record)
			continue
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
	# Cycle plans do not own a pre-authored `forgone` card list. Their missed
	# opportunities are the deadline receipts produced by the player's actual
	# allocations, so the terminal notebook must read those receipts directly.
	for month_index in range(1, final_month + 1):
		var raw_cycle_summary: Variant = (
			state.get("month_summaries", {}) as Dictionary
		).get(str(month_index), {})
		if not raw_cycle_summary is Dictionary \
				or str((raw_cycle_summary as Dictionary).get(
					"planning_mode", "")) != SEOUL_CYCLE_MODE:
			continue
		var node_states: Dictionary = (
			raw_cycle_summary as Dictionary).get("node_states", {}) \
			if (raw_cycle_summary as Dictionary).get(
				"node_states", {}) is Dictionary else {}
		var expiry_receipts: Dictionary = (
			raw_cycle_summary as Dictionary).get("expiry_receipts", {}) \
			if (raw_cycle_summary as Dictionary).get(
				"expiry_receipts", {}) is Dictionary else {}
		var expiry_keys: Array[String] = []
		for raw_expiry_key in expiry_receipts:
			expiry_keys.append(str(raw_expiry_key))
		expiry_keys.sort()
		for expiry_key in expiry_keys:
			var raw_receipt: Variant = expiry_receipts.get(expiry_key, {})
			if not raw_receipt is Dictionary:
				continue
			var receipt: Dictionary = raw_receipt
			var bundle_id := str(receipt.get(
				"trigger_bundle", "")).strip_edges()
			if bundle_id.is_empty():
				var node_id := str(receipt.get("node_id", ""))
				var raw_node: Variant = node_states.get(node_id, {})
				if raw_node is Dictionary:
					bundle_id = str((raw_node as Dictionary).get(
						"summary_bundle", "")).strip_edges()
			if bundle_id.is_empty():
				continue
			forgone.append({
				"month": month_index,
				"week": int(receipt.get("turn", month_index * 4)),
				"bundle_id": bundle_id,
				"reason": str(receipt.get("consequence_id", "")),
			})

	var closing_state: Dictionary = {}
	var final_summary_raw: Variant = (
		state.get("month_summaries", {}) as Dictionary
	).get(str(final_month), {})
	if final_summary_raw is Dictionary:
		var final_after_raw: Variant = (
			final_summary_raw as Dictionary
		).get("after", {})
		if final_after_raw is Dictionary:
			closing_state = (final_after_raw as Dictionary).duplicate(true)

	# The recap must remain an immutable Week-24 record when later chapters are
	# added. Read the four branch facts captured in the final month receipt,
	# never today's global HUD/flags. Older receipts without that evidence stay
	# explicitly unresolved instead of receiving a plausible but invented past.
	var closing_temptation_flags: Dictionary = (
		closing_state.get("temptation_flags", {}) as Dictionary
		if closing_state.get("temptation_flags", {}) is Dictionary else {}
	)
	var temptation_branch := "unresolved"
	if bool(closing_temptation_flags.get("lent_account", false)):
		if bool(closing_temptation_flags.get("escaped_dirty_money", false)):
			temptation_branch = "returned_money"
		elif bool(closing_temptation_flags.get("fell_to_darkness", false)):
			temptation_branch = "accepted_more"
		else:
			temptation_branch = "lent_account"
	elif bool(closing_temptation_flags.get("kept_clean_hands", false)):
		temptation_branch = "refused_offer"
	elif not late_unfrozen_boundary:
		# A pre-completion diagnostic or an old save still parked exactly on the
		# cap+1 boundary can safely read the live flags. Once later weeks exist,
		# the absence of a frozen receipt must remain visibly unresolved.
		if bool(GameState.flags.get("lent_account", false)):
			if bool(GameState.flags.get("escaped_dirty_money", false)):
				temptation_branch = "returned_money"
			elif bool(GameState.flags.get("fell_to_darkness", false)):
				temptation_branch = "accepted_more"
			else:
				temptation_branch = "lent_account"
		elif bool(GameState.flags.get("kept_clean_hands", false)):
			temptation_branch = "refused_offer"

	var cycle_allocations: Array = []
	for month_index in range(1, final_month + 1):
		var raw_cycle_summary: Variant = (
			state.get("month_summaries", {}) as Dictionary
		).get(str(month_index), {})
		if not raw_cycle_summary is Dictionary \
				or str((raw_cycle_summary as Dictionary).get(
					"planning_mode", "")) != SEOUL_CYCLE_MODE:
			continue
		var node_states: Dictionary = (
			raw_cycle_summary as Dictionary).get("node_states", {}) \
			if (raw_cycle_summary as Dictionary).get(
				"node_states", {}) is Dictionary else {}
		for raw_receipt in (raw_cycle_summary as Dictionary).get(
				"allocation_receipts", []):
			if not raw_receipt is Dictionary:
				continue
			var allocation: Dictionary = (
				raw_receipt as Dictionary).duplicate(true)
			var node_id := str(allocation.get("node_id", ""))
			var raw_node: Variant = node_states.get(node_id, {})
			allocation["month"] = month_index
			if raw_node is Dictionary:
				allocation["label_ko"] = str((raw_node as Dictionary).get(
					"label_ko", node_id))
				allocation["label_en"] = str((raw_node as Dictionary).get(
					"label_en", node_id))
			cycle_allocations.append(allocation)
	cycle_allocations.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		var left_key := "%04d|%s|%s" % [
			int(left.get("turn", 0)), str(left.get("node_id", "")),
			str(left.get("capacity_id", ""))]
		var right_key := "%04d|%s|%s" % [
			int(right.get("turn", 0)), str(right.get("node_id", "")),
			str(right.get("capacity_id", ""))]
		return left_key < right_key)
	forgone.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		var left_key := "%03d|%04d|%s|%s" % [
			int(left.get("month", 0)), int(left.get("week", 0)),
			str(left.get("bundle_id", "")), str(left.get("reason", ""))]
		var right_key := "%03d|%04d|%s|%s" % [
			int(right.get("month", 0)), int(right.get("week", 0)),
			str(right.get("bundle_id", "")), str(right.get("reason", ""))]
		return left_key < right_key)

	var closing_money := float(closing_state.get("money", 0.0))
	var closing_shortfall := cash_shortfall_for_money(closing_money)
	if final_summary_raw is Dictionary:
		closing_shortfall = maxf(closing_shortfall, float(
			(final_summary_raw as Dictionary).get(
				"cash_shortfall", closing_shortfall)))
	var boundary_month_summaries: Dictionary = {}
	var boundary_opening_snapshots: Dictionary = {}
	for month_index in range(1, final_month + 1):
		var month_key := str(month_index)
		var raw_summary: Variant = (
			state.get("month_summaries", {}) as Dictionary
		).get(month_key, {})
		if raw_summary is Dictionary:
			boundary_month_summaries[month_key] = (
				raw_summary as Dictionary).duplicate(true)
		var raw_opening: Variant = (
			state.get("month_opening_snapshots", {}) as Dictionary
		).get(month_key, {})
		if raw_opening is Dictionary:
			boundary_opening_snapshots[month_key] = (
				raw_opening as Dictionary).duplicate(true)
	var boundary_routine_receipts: Dictionary = {}
	for raw_turn_key in (state.get("routine_receipts", {}) as Dictionary):
		var turn := int(str(raw_turn_key))
		if turn < 1 or turn > cap:
			continue
		var raw_routine: Variant = (
			state.get("routine_receipts", {}) as Dictionary
		).get(raw_turn_key, {})
		if raw_routine is Dictionary:
			boundary_routine_receipts[str(turn)] = (
				raw_routine as Dictionary).duplicate(true)
	var boundary_decline_receipts: Array = []
	for raw_decline in state.get("decline_receipts", []):
		if not raw_decline is Dictionary:
			continue
		var decline: Dictionary = raw_decline
		var visible_month := int(decline.get(
			"visible_month", decline.get("month", 0)))
		var consumed_turn := int(decline.get(
			"consumed_turn", decline.get("turn", 0)))
		if visible_month in range(1, final_month + 1) \
				and (consumed_turn <= 0 or consumed_turn <= cap + 1):
			# Month-end advances the calendar before it consumes that month's
			# declines, so Month 6 correctly owns a turn-25 rollover receipt.
			# Anything consumed after that exact boundary belongs to later play.
			boundary_decline_receipts.append(decline.duplicate(true))
	boundary_decline_receipts.sort_custom(
		func(left: Dictionary, right: Dictionary) -> bool:
			var left_key := "%03d|%04d|%s" % [
				int(left.get("visible_month", left.get("month", 0))),
				int(left.get("consumed_turn", left.get("turn", 0))),
				str(left.get("id", ""))]
			var right_key := "%03d|%04d|%s" % [
				int(right.get("visible_month", right.get("month", 0))),
				int(right.get("consumed_turn", right.get("turn", 0))),
				str(right.get("id", ""))]
			return left_key < right_key)
	var empty_dictionary := {}
	var empty_array: Array = []

	return {
		"snapshot_schema": 1,
		"frozen_at_turn": int(GameState.turn),
		"kept": kept,
		"cycle_allocations": cycle_allocations,
		"forgone": forgone,
		"decline_receipts": boundary_decline_receipts,
		"routine_receipts": boundary_routine_receipts,
		"month_summaries": boundary_month_summaries,
		"month_opening_snapshots": boundary_opening_snapshots,
		"player_initiated": (
			empty_array.duplicate()
			if late_unfrozen_boundary else
			(state.get("player_initiated", []) as Array).duplicate()),
		"relationship_stages":
			(empty_dictionary.duplicate()
			if late_unfrozen_boundary else
			(state.get("relationship_stages", {}) as Dictionary).duplicate(true)),
		"relationship_memories":
			(empty_array.duplicate()
			if late_unfrozen_boundary else
			(state.get("relationship_memories", []) as Array).duplicate(true)),
		"application_statuses":
			(empty_dictionary.duplicate()
			if late_unfrozen_boundary else
			(state.get("application_statuses", {}) as Dictionary).duplicate(true)),
		"application_transition_receipts":
			(empty_dictionary.duplicate()
			if late_unfrozen_boundary else
			(state.get("application_transition_receipts", {}) as Dictionary).duplicate(true)),
		"legacy_callback_resolutions":
			(empty_dictionary.duplicate()
			if late_unfrozen_boundary else
			(state.get("legacy_callback_resolutions", {}) as Dictionary).duplicate(true)),
		"future_story_receipts":
			(empty_dictionary.duplicate()
			if late_unfrozen_boundary else
			(state.get("future_story_receipts", {}) as Dictionary).duplicate(true)),
		"future_application_receipts":
			(empty_dictionary.duplicate()
			if late_unfrozen_boundary else
			(state.get("future_application_receipts", {}) as Dictionary).duplicate(true)),
		"action_receipts":
			(empty_dictionary.duplicate()
			if late_unfrozen_boundary else
			(state.get("action_receipts", {}) as Dictionary).duplicate(true)),
		"action_story_acknowledgements":
			(empty_dictionary.duplicate()
			if late_unfrozen_boundary else
			(state.get(
				"action_story_acknowledgements", {}) as Dictionary
			).duplicate(true)),
		"consequence_receipts":
			(empty_dictionary.duplicate()
			if late_unfrozen_boundary else
			(state.get("consequence_receipts", {}) as Dictionary).duplicate(true)),
		"story_choice_receipts":
			(empty_dictionary.duplicate()
			if late_unfrozen_boundary else
			(state.get("story_choice_receipts", {}) as Dictionary).duplicate(true)),
		"obligation_receipts":
			(empty_dictionary.duplicate()
			if late_unfrozen_boundary else
			(state.get("obligation_receipts", {}) as Dictionary).duplicate(true)),
		"deferred_callback_receipts":
			(empty_dictionary.duplicate()
			if late_unfrozen_boundary else
			(state.get("deferred_callback_receipts", {}) as Dictionary).duplicate(true)),
		"demo_collision_context":
			(empty_dictionary.duplicate()
			if late_unfrozen_boundary else
			(state.get("demo_collision_context", {}) as Dictionary).duplicate(true)),
		"legacy_boundary_incomplete": late_unfrozen_boundary,
		"temptation_branch": temptation_branch,
		"closing_state": closing_state,
		"cash_shortfall": closing_shortfall,
		"completed_through_week": completed_through,
		"development_cap_week": cap,
		"completed_at_turn": int(state.get("completed_at_turn",
			state.get("prototype_completed_at_turn", 0))),
	}

static func _completion_snapshot_is_valid(
		snapshot: Dictionary, cap: int) -> bool:
	if int(snapshot.get("snapshot_schema", 0)) != 1 \
			or int(snapshot.get("development_cap_week", 0)) != cap \
			or int(snapshot.get("completed_through_week", 0)) < cap \
			or int(snapshot.get("completed_at_turn", 0)) != cap + 1 \
			or int(snapshot.get("frozen_at_turn", 0)) != cap + 1:
		return false
	for key in [
		"kept", "cycle_allocations", "forgone", "decline_receipts",
		"player_initiated", "relationship_memories",
	]:
		if not snapshot.get(key) is Array:
			return false
	for key in [
		"closing_state", "routine_receipts", "month_summaries",
		"relationship_stages", "application_statuses",
		"application_transition_receipts", "consequence_receipts",
		"legacy_callback_resolutions", "action_receipts",
		"action_story_acknowledgements",
		"story_choice_receipts", "obligation_receipts",
		"future_story_receipts", "future_application_receipts",
		"deferred_callback_receipts", "demo_collision_context",
	]:
		if not snapshot.get(key) is Dictionary:
			return false
	if not snapshot.get("legacy_boundary_incomplete", false) is bool:
		return false
	var closing_state: Dictionary = snapshot.get("closing_state", {})
	for key in ["money", "fixed_expense", "health", "mental"]:
		if not closing_state.has(key):
			if bool(snapshot.get("legacy_boundary_incomplete", false)):
				continue
			return false
		var value: Variant = closing_state.get(key)
		if not (value is int or value is float):
			return false
	return (snapshot.get("month_summaries", {}) as Dictionary).size() \
		>= month_for_turn(cap)

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

## Month One is the vertical slice for the episode-shaped planning loop. The
## player chooses two promises; chronology and unplanned pressure stay owned by
## the story. Later months deliberately keep the legacy planner until this
## slice has been played and approved.
static func episode_plan_spec() -> Dictionary:
	var raw_spec: Variant = contract().get("episode_plan", {})
	return (raw_spec as Dictionary).duplicate(true) \
		if raw_spec is Dictionary else {}

## One reusable state machine owns Months One through Six after a fresh
## Month-One enrollment. Existing episode and legacy plans remain valid save
## identities and never opt in at a later month boundary.
static func seoul_cycle_spec() -> Dictionary:
	var raw_spec: Variant = contract().get("seoul_cycle", {})
	return (raw_spec as Dictionary).duplicate(true) \
		if raw_spec is Dictionary else {}

## Shared capacity/routine rules live at the Seoul-cycle root, while every
## month owns its four playable nodes and world clock. The legacy top-level
## Month-One shape remains readable so an in-progress test save cannot be
## invalidated by the 24-week rollout.
static func seoul_cycle_month_spec(month_index: int = -1) -> Dictionary:
	var target_month := month_index \
		if month_index > 0 else month_for_turn(GameState.turn)
	var root := seoul_cycle_spec()
	var raw_months: Variant = root.get("months", {})
	if raw_months is Dictionary:
		var raw_month: Variant = (raw_months as Dictionary).get(
			str(target_month), {})
		if raw_month is Dictionary and not (raw_month as Dictionary).is_empty():
			var month_spec: Dictionary = (raw_month as Dictionary).duplicate(true)
			month_spec["month"] = target_month
			return month_spec
	if target_month == int(root.get("prototype_month", 1)) \
			and root.get("nodes", {}) is Dictionary:
		return {
			"month": target_month,
			"nodes": (root.get("nodes", {}) as Dictionary).duplicate(true),
			"world_clock": (root.get("world_clock", {}) as Dictionary).duplicate(true) \
				if root.get("world_clock", {}) is Dictionary else {},
		}
	return {}

static func _seoul_cycle_month_start_turn(month_index: int) -> int:
	return ((month_index - 1) * 4) + 1

static func _seoul_cycle_month_end_turn(month_index: int) -> int:
	return month_index * 4

static func plan_uses_seoul_cycle(raw_plan: Dictionary) -> bool:
	if str(raw_plan.get("planning_mode", "")) != SEOUL_CYCLE_MODE:
		return false
	var month_index := int(raw_plan.get("month", 0))
	var spec := seoul_cycle_month_spec(month_index)
	if spec.is_empty() \
			or int(raw_plan.get("cycle_schema", 0)) != SEOUL_CYCLE_SCHEMA:
		return false
	var raw_nodes: Variant = raw_plan.get("node_ids", [])
	var raw_spec_nodes: Variant = spec.get("nodes", {})
	if not raw_nodes is Array or not raw_spec_nodes is Dictionary:
		return false
	var expected: Array[String] = []
	for raw_node_id in (raw_spec_nodes as Dictionary):
		expected.append(str(raw_node_id))
	expected.sort()
	var actual: Array[String] = []
	for raw_node_id in (raw_nodes as Array):
		var node_id := str(raw_node_id).strip_edges()
		if node_id.is_empty() or actual.has(node_id):
			return false
		actual.append(node_id)
	actual.sort()
	return actual == expected

static func _fresh_seoul_cycle_gate(
		state: Dictionary, month_index: int) -> bool:
	var spec := seoul_cycle_month_spec(month_index)
	if spec.is_empty() \
			or int(GameState.turn) \
				!= _seoul_cycle_month_start_turn(month_index) \
			or not bool(state.get("enabled", false)) \
			or not bool(GameState.flags.get("prologue_done", false)):
		return false
	var existing: Variant = state["plans"].get(str(month_index), {})
	if existing is Dictionary and not (existing as Dictionary).is_empty():
		return false
	# The 24-week board is one explicit save identity. A run that planned the
	# previous month with the episode prototype or legacy calendar must keep
	# that mode instead of being silently converted at the next month boundary.
	if month_index > 1:
		var previous_plan: Variant = state["plans"].get(
			str(month_index - 1), {})
		if not previous_plan is Dictionary \
				or not plan_uses_seoul_cycle(previous_plan as Dictionary):
			return false
	# The opening application is available only on the old pre-interview state.
	# Once the real Send/interview path has changed its application status, a
	# fresh run is eligible. This is the same discriminator that protected the
	# prior episode prototype from relabelling legacy Month-One saves.
	if month_index == 1:
		if str(state.get("run_generation", "")) \
				!= GameState.CORE_LOOP_V2_ELIGIBLE_RUN_GENERATION:
			return false
		# Fresh ORDER-101 is identified before Story and deliberately leaves the
		# old application offer available. Only that exact marker bypasses the
		# legacy discriminator; old pre-plan saves retain the prior behavior.
		if not _fresh_w1_onboarding_allocation_gate(state, month_index):
			for raw_id in episode_plan_spec().get("incompatible_if_available", []):
				if available_offer_ids(month_index).has(str(raw_id).strip_edges()):
					return false
	return true

static func seoul_cycle_available(month_index: int = -1) -> bool:
	var target_month := month_index \
		if month_index > 0 else month_for_turn(GameState.turn)
	var state := _normalized_state(GameState.core_loop_v2_state)
	var existing: Variant = state["plans"].get(str(target_month), {})
	if existing is Dictionary and not (existing as Dictionary).is_empty():
		var active_cycle: Dictionary = state.get(SEOUL_CYCLE_STATE_KEY, {})
		return int(GameState.turn) \
				>= _seoul_cycle_month_start_turn(target_month) \
			and int(GameState.turn) \
				<= _seoul_cycle_month_end_turn(target_month) \
			and month_for_turn(GameState.turn) == target_month \
			and plan_uses_seoul_cycle(existing as Dictionary) \
			and not active_cycle.is_empty() \
			and int(active_cycle.get("month", 0)) == target_month
	return _fresh_seoul_cycle_gate(state, target_month)

static func initialize_seoul_cycle(month_index: int = 1) -> Dictionary:
	var target_month := month_index \
		if month_index > 0 else month_for_turn(GameState.turn)
	var spec := seoul_cycle_month_spec(target_month)
	if spec.is_empty():
		return {"ok": false, "error": "seoul_cycle_unavailable"}
	var state := _normalized_state(GameState.core_loop_v2_state)
	var existing_plan_raw: Variant = state["plans"].get(
		str(target_month), {})
	if existing_plan_raw is Dictionary \
			and not (existing_plan_raw as Dictionary).is_empty():
		if not plan_uses_seoul_cycle(existing_plan_raw as Dictionary):
			return {"ok": false, "error": "plan_mode_already_committed"}
		if int(GameState.turn) \
				< _seoul_cycle_month_start_turn(target_month) \
				or int(GameState.turn) \
				> _seoul_cycle_month_end_turn(target_month) \
				or month_for_turn(GameState.turn) != target_month:
			return {"ok": false, "error": "seoul_cycle_inactive"}
		var existing_cycle: Dictionary = state.get(
			SEOUL_CYCLE_STATE_KEY, {})
		if existing_cycle.is_empty():
			return {"ok": false, "error": "seoul_cycle_state_missing"}
		return {
			"ok": true,
			"error": "",
			"planning_mode": SEOUL_CYCLE_MODE,
			"state": seoul_cycle_snapshot(target_month),
			"resumed": true,
		}
	if not _fresh_seoul_cycle_gate(state, target_month):
		return {"ok": false, "error": "seoul_cycle_unavailable"}
	var cycle := _new_seoul_cycle_state(target_month)
	if cycle.is_empty():
		return {"ok": false, "error": "invalid_seoul_cycle_contract"}
	var raw_nodes: Dictionary = spec.get("nodes", {})
	var node_ids: Array[String] = []
	for raw_node_id in raw_nodes:
		node_ids.append(str(raw_node_id))
	node_ids.sort()
	state["plans"][str(target_month)] = {
		"planning_mode": SEOUL_CYCLE_MODE,
		"cycle_schema": SEOUL_CYCLE_SCHEMA,
		"month": target_month,
		"node_ids": node_ids,
		"schedule": {},
		"selected": [],
		"routines": {},
		"forgone": [],
		"planned_turn": int(GameState.turn),
	}
	var month_key := str(target_month)
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
	state[SEOUL_CYCLE_STATE_KEY] = cycle
	if _fresh_w1_onboarding_allocation_gate(state, target_month):
		var onboarding: Dictionary = state[W1_ONBOARDING_STATE_KEY]
		onboarding["phase"] = "board"
		state[W1_ONBOARDING_STATE_KEY] = onboarding
	GameState.core_loop_v2_state = state
	return {
		"ok": true,
		"error": "",
		"planning_mode": SEOUL_CYCLE_MODE,
		"state": seoul_cycle_snapshot(target_month),
		"resumed": false,
	}

static func _new_seoul_cycle_state(month_index: int) -> Dictionary:
	var root_spec := seoul_cycle_spec()
	var spec := seoul_cycle_month_spec(month_index)
	var capacities := _generated_seoul_cycle_capacities(
		month_index, int(GameState.health), int(GameState.mental),
		str(GameState.player_name))
	var capacity_spec: Variant = root_spec.get("capacity", {})
	if not capacity_spec is Dictionary \
			or capacities.size() != int(
				(capacity_spec as Dictionary).get("count", 4)):
		return {}
	var raw_nodes: Variant = spec.get("nodes", {})
	if not raw_nodes is Dictionary or (raw_nodes as Dictionary).is_empty():
		return {}
	var nodes: Dictionary = {}
	for raw_node_id in (raw_nodes as Dictionary):
		var node_id := str(raw_node_id).strip_edges()
		var raw_node: Variant = (raw_nodes as Dictionary).get(raw_node_id, {})
		if node_id.is_empty() or not raw_node is Dictionary:
			return {}
		var node := _resolved_seoul_cycle_node(
			(raw_node as Dictionary).duplicate(true), month_index)
		if node.is_empty():
			return {}
		var threshold: int = maxi(1, int(node.get("threshold", 1)))
		node["id"] = node_id
		node["threshold"] = threshold
		node["deadline_week"] = clampi(
			int(node.get("deadline_week", 4)), 1, 4)
		node["progress"] = 0
		var player_trigger_required := _seoul_cycle_player_trigger_required(node)
		var no_player_trigger_candidates := player_trigger_required \
			and (node.get("eligible_trigger_bundle_ids", []) as Array).is_empty()
		node["status"] = (
			"locked"
			if no_player_trigger_candidates \
				or (not player_trigger_required \
					and bool(node.get("disable_without_trigger", false)) \
					and str(node.get("trigger_bundle", "")).is_empty())
			else "open"
		)
		if not str(node.get("trigger_bundle", "")).is_empty():
			node["featured_status"] = "open"
		node["completed_turn"] = 0
		node["last_allocation_turn"] = 0
		nodes[node_id] = node
	return {
		"schema": SEOUL_CYCLE_SCHEMA,
		"planning_mode": SEOUL_CYCLE_MODE,
		"month": month_index,
		"initialized_turn": int(GameState.turn),
		"seed_signature": _seoul_cycle_seed_signature(
			month_index, int(GameState.health), int(GameState.mental),
			str(GameState.player_name)),
		"source_health": clampi(int(GameState.health), 0, 100),
		"source_mental": clampi(int(GameState.mental), 0, 100),
		"condition_band": _seoul_cycle_condition_band(
			int(GameState.health), int(GameState.mental)),
		"capacities": capacities,
		"nodes": nodes,
		"world_clock": 0,
		"allocation_receipts": {},
		"trigger_receipts": {},
		"world_receipts": {},
		"expiry_receipts": {},
		"pending_trigger": {},
		"pending_world": {},
		"completed_turns": [],
		"expired_nodes": [],
	}

static func _resolved_seoul_cycle_node(
		node_spec: Dictionary, month_index: int) -> Dictionary:
	var node := node_spec.duplicate(true)
	if _seoul_cycle_player_trigger_required(node):
		if str(node.get("selection_owner", "")).strip_edges() != "player":
			return {}
		var eligible_ids := _eligible_seoul_cycle_player_trigger_ids(
			node, month_index)
		node["eligible_trigger_bundle_ids"] = eligible_ids
		node["selected_trigger_bundle_id"] = ""
		node["trigger_bundle"] = ""
		node["summary_bundle"] = ""
		node["trigger_selection_origin"] = "unselected_player"
		node["trigger_selection_migrated_legacy"] = false
		return node
	var candidates := _seoul_cycle_node_trigger_candidates(node)
	var available := available_offer_ids(month_index)
	var resolved_trigger := ""
	for bundle_id in candidates:
		var scene_bundle := bundle(bundle_id)
		if scene_bundle.is_empty() or not _bundle_requirement_met(scene_bundle):
			continue
		if available.has(bundle_id) or candidates.size() == 1:
			resolved_trigger = bundle_id
			break
	if resolved_trigger.is_empty():
		var fallback_trigger := str(node.get(
			"fallback_trigger_bundle", "")).strip_edges()
		var fallback_bundle := bundle(fallback_trigger)
		if not fallback_trigger.is_empty() \
				and not fallback_bundle.is_empty() \
			and _bundle_requirement_met(fallback_bundle):
			resolved_trigger = fallback_trigger
	return _seoul_cycle_node_with_resolved_trigger(
		node, resolved_trigger, month_index)

## Rebuild every value derived from a trigger without re-evaluating its
## prerequisites. New months choose the trigger dynamically once; subsequent
## normalization must reproduce its threshold/window/owner from that saved ID
## or a reload would silently change the branch.
static func _seoul_cycle_node_with_resolved_trigger(
		node_spec: Dictionary, resolved_trigger: String,
		month_index: int) -> Dictionary:
	var node := node_spec.duplicate(true)
	node["trigger_bundle"] = resolved_trigger
	if _seoul_cycle_player_trigger_required(node):
		node["selected_trigger_bundle_id"] = resolved_trigger
	if resolved_trigger.is_empty():
		return node
	var chosen_bundle := bundle(resolved_trigger)
	if chosen_bundle.is_empty():
		return node
	node["summary_bundle"] = resolved_trigger
	if bool(node.get("label_from_bundle", false)):
		node["label_ko"] = str(chosen_bundle.get(
			"offer_ko", node.get("label_ko", "")))
		node["label_en"] = str(chosen_bundle.get(
			"offer_en", node.get("label_en", "")))
	var raw_thresholds: Variant = node.get("threshold_by_trigger", {})
	if raw_thresholds is Dictionary \
			and (raw_thresholds as Dictionary).has(resolved_trigger):
		node["threshold"] = maxi(1, int(
			(raw_thresholds as Dictionary).get(resolved_trigger, 1)))
	var month_start := _seoul_cycle_month_start_turn(month_index)
	var month_end := _seoul_cycle_month_end_turn(month_index)
	var relative_weeks: Array[int] = []
	for raw_week in chosen_bundle.get("allowed_weeks", []):
		var absolute_week := int(raw_week)
		if absolute_week >= month_start and absolute_week <= month_end:
			relative_weeks.append(absolute_week - month_start + 1)
	if not relative_weeks.is_empty():
		relative_weeks.sort()
		node["trigger_min_week"] = relative_weeks.front()
		node["trigger_deadline_week"] = relative_weeks.back()
		if bool(node.get("deadline_follows_trigger", false)):
			node["deadline_week"] = relative_weeks.back()
	if str(node.get("owner", "")).strip_edges().to_lower() == "people":
		node["commitment_action_id"] = "contact"
		node["axis"] = "human"
		var characters: Variant = chosen_bundle.get("characters", [])
		if characters is Array and not (characters as Array).is_empty():
			var person_id := str((characters as Array).front()).strip_edges()
			# The authored trigger is the durable identity owner. Some supporting
			# characters (notably Hyunsu) are added to GameState.cast only when an
			# earlier scene applies its first cast effect, so checking the transient
			# cast dictionary here would erase the owner during normalization or an
			# isolated save recovery.
			if not person_id.is_empty():
				node["owner"] = person_id
	return node

static func _seoul_cycle_player_trigger_required(node: Dictionary) -> bool:
	return str(node.get("trigger_selection_mode", "")).strip_edges() \
		== SEOUL_CYCLE_TRIGGER_PLAYER_REQUIRED

static func _eligible_seoul_cycle_player_trigger_ids(
		node_spec: Dictionary, month_index: int) -> Array[String]:
	var eligible: Array[String] = []
	var available := available_offer_ids(month_index)
	for bundle_id in _seoul_cycle_node_trigger_candidates(node_spec):
		var scene_bundle := bundle(bundle_id)
		if scene_bundle.is_empty() \
				or not available.has(bundle_id) \
				or not _bundle_requirement_met(scene_bundle):
			continue
		eligible.append(bundle_id)
	eligible.sort()
	return eligible

static func _seoul_cycle_player_trigger_candidate_records(
		node: Dictionary, at_turn: int = -1) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	var raw_ids: Variant = node.get("eligible_trigger_bundle_ids", [])
	if not raw_ids is Array:
		return candidates
	for raw_id in raw_ids:
		var bundle_id := str(raw_id).strip_edges()
		var scene_bundle := bundle(bundle_id)
		if bundle_id.is_empty() or scene_bundle.is_empty():
			continue
		if at_turn > 0:
			var latest_allowed_turn := 0
			for raw_week in scene_bundle.get("allowed_weeks", []):
				latest_allowed_turn = maxi(latest_allowed_turn, int(raw_week))
			if latest_allowed_turn < at_turn:
				continue
		candidates.append({
			"id": bundle_id,
			"label_ko": str(scene_bundle.get("offer_ko", "")),
			"label_en": str(scene_bundle.get("offer_en", "")),
			"detail_ko": str(scene_bundle.get("detail_ko", "")),
			"detail_en": str(scene_bundle.get("detail_en", "")),
		})
	candidates.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return str(left.get("id", "")) < str(right.get("id", "")))
	return candidates

static func _seoul_cycle_node_trigger_candidates(
		node_spec: Dictionary) -> Array[String]:
	var candidates: Array[String] = []
	var raw_options: Variant = node_spec.get("trigger_options", [])
	if raw_options is Array:
		for raw_id in raw_options:
			var bundle_id := str(raw_id).strip_edges()
			if not bundle_id.is_empty() and not candidates.has(bundle_id):
				candidates.append(bundle_id)
	var authored_trigger := str(
		node_spec.get("trigger_bundle", "")).strip_edges()
	if not authored_trigger.is_empty() and not candidates.has(authored_trigger):
		candidates.append(authored_trigger)
	var fallback_trigger := str(
		node_spec.get("fallback_trigger_bundle", "")).strip_edges()
	if not fallback_trigger.is_empty() and not candidates.has(fallback_trigger):
		candidates.append(fallback_trigger)
	return candidates

static func _generated_seoul_cycle_capacities(
		month_index: int, health: int, mental: int,
		player_name: String) -> Array:
	var capacity_spec: Variant = seoul_cycle_spec().get("capacity", {})
	if not capacity_spec is Dictionary:
		return []
	var values: Array[int] = []
	var total := clampi(health, 0, 100) + clampi(mental, 0, 100)
	for raw_band in (capacity_spec as Dictionary).get(
			"condition_bands", []):
		if not raw_band is Dictionary:
			continue
		if total > int((raw_band as Dictionary).get(
				"maximum_total", 200)):
			continue
		for raw_value in (raw_band as Dictionary).get("values", []):
			values.append(clampi(
				int(raw_value),
				int((capacity_spec as Dictionary).get("minimum", 1)),
				int((capacity_spec as Dictionary).get("maximum", 6))))
		break
	var count := int((capacity_spec as Dictionary).get("count", 4))
	if values.size() != count:
		return []
	var seed := _stable_seoul_cycle_seed(_seoul_cycle_seed_signature(
		month_index, health, mental, player_name))
	for index in range(values.size() - 1, 0, -1):
		seed = int((seed * 1103515245 + 12345) % 2147483647)
		var swap_index := int(seed % (index + 1))
		var held := values[index]
		values[index] = values[swap_index]
		values[swap_index] = held
	var result: Array = []
	for index in range(values.size()):
		var value := int(values[index])
		result.append({
			"id": "m%d_capacity_%d" % [month_index, index + 1],
			"value": value,
			"quality": _seoul_cycle_capacity_quality(value),
			"consumed": false,
			"consumed_turn": 0,
			"node_id": "",
		})
	return result

static func _seoul_cycle_seed_signature(
		month_index: int, health: int, mental: int,
		player_name: String) -> String:
	return "%s|%d|%d|%d" % [
		player_name.strip_edges(), month_index,
		clampi(health, 0, 100), clampi(mental, 0, 100),
	]

static func _stable_seoul_cycle_seed(signature: String) -> int:
	var seed: int = 2166136261
	for index in range(signature.length()):
		seed = int((seed * 16777619 + signature.unicode_at(index)) \
			% 2147483647)
	return maxi(1, seed)

static func _seoul_cycle_condition_band(health: int, mental: int) -> String:
	var raw_capacity: Variant = seoul_cycle_spec().get("capacity", {})
	if not raw_capacity is Dictionary:
		return ""
	var total := clampi(health, 0, 100) + clampi(mental, 0, 100)
	for raw_band in (raw_capacity as Dictionary).get(
			"condition_bands", []):
		if raw_band is Dictionary and total <= int(
				(raw_band as Dictionary).get("maximum_total", 200)):
			return str((raw_band as Dictionary).get("id", ""))
	return ""

static func _seoul_cycle_capacity_quality(value: int) -> String:
	var raw_capacity: Variant = seoul_cycle_spec().get("capacity", {})
	if not raw_capacity is Dictionary:
		return ""
	for raw_band in (raw_capacity as Dictionary).get("progress_bands", []):
		if raw_band is Dictionary \
				and value >= int((raw_band as Dictionary).get("minimum", 1)) \
				and value <= int((raw_band as Dictionary).get("maximum", 6)):
			return str((raw_band as Dictionary).get("quality", ""))
	return ""

static func _seoul_cycle_progress_for_capacity(value: int) -> int:
	var raw_capacity: Variant = seoul_cycle_spec().get("capacity", {})
	if not raw_capacity is Dictionary:
		return 0
	for raw_band in (raw_capacity as Dictionary).get("progress_bands", []):
		if raw_band is Dictionary \
				and value >= int((raw_band as Dictionary).get("minimum", 1)) \
				and value <= int((raw_band as Dictionary).get("maximum", 6)):
			return maxi(1, int((raw_band as Dictionary).get("progress", 1)))
	return 0

static func seoul_cycle_snapshot(month_index: int = -1) -> Dictionary:
	var target_month := month_index \
		if month_index > 0 else month_for_turn(GameState.turn)
	var state := _normalized_state(GameState.core_loop_v2_state)
	var raw_plan: Variant = state["plans"].get(str(target_month), {})
	var cycle: Dictionary = state.get(SEOUL_CYCLE_STATE_KEY, {})
	if not raw_plan is Dictionary \
			or not plan_uses_seoul_cycle(raw_plan as Dictionary) \
			or cycle.is_empty() \
			or int(cycle.get("month", 0)) != target_month:
		return {
			"active": false,
			"planning_mode": "",
			"month": target_month,
			"turn": int(GameState.turn),
			"week_index": 0,
			"capacities": [],
			"nodes": {},
			"world_clock": 0,
			"allocation_receipts": {},
			"expiry_receipts": {},
			"pending_trigger": {},
			"pending_world": {},
			"turn_ready": false,
		}
	var snapshot := cycle.duplicate(true)
	snapshot["active"] = int(GameState.turn) \
			>= _seoul_cycle_month_start_turn(target_month) \
		and int(GameState.turn) <= _seoul_cycle_month_end_turn(target_month) \
		and month_for_turn(GameState.turn) == target_month
	snapshot["turn"] = int(GameState.turn)
	snapshot["week_index"] = int(GameState.turn) \
		- ((target_month - 1) * 4)
	snapshot["turn_ready"] = _seoul_cycle_turn_ready(
		cycle, int(GameState.turn))
	return snapshot

static func preview_seoul_cycle_allocation(
		capacity_id: String, node_id: String,
		month_index: int = -1,
		selected_bundle_id: String = "") -> Dictionary:
	var snapshot := seoul_cycle_snapshot(month_index)
	if not bool(snapshot.get("active", false)):
		return {"ok": false, "error": "seoul_cycle_inactive"}
	var turn := int(snapshot.get("turn", 0))
	var week_index := int(snapshot.get("week_index", 0))
	# Once a player-owned branch is durable, a sibling request is an identity
	# mutation regardless of whether another weekly gate would also reject the
	# call. Give that invariant precedence so retries and stale UI callbacks can
	# never disguise a branch-change attempt as an ordinary duplicate commit.
	var early_raw_node: Variant = (snapshot.get("nodes", {}) as Dictionary).get(
		node_id, {})
	if early_raw_node is Dictionary \
			and _seoul_cycle_player_trigger_required(
				early_raw_node as Dictionary):
		var early_persisted := str((early_raw_node as Dictionary).get(
			"selected_trigger_bundle_id", "")).strip_edges()
		var early_requested := selected_bundle_id.strip_edges()
		if not early_persisted.is_empty() \
				and not early_requested.is_empty() \
				and early_requested != early_persisted:
			return {
				"ok": false,
				"error": "trigger_branch_change_rejected",
				"trigger_selection_required": false,
				"trigger_candidates": \
					_seoul_cycle_player_trigger_candidate_records(
						early_raw_node as Dictionary, turn),
				"selected_trigger_bundle_id": early_persisted,
			}
	if (snapshot.get("completed_turns", []) as Array).has(turn):
		return {"ok": false, "error": "cycle_turn_already_completed"}
	if (snapshot.get("allocation_receipts", {}) as Dictionary).has(str(turn)):
		return {"ok": false, "error": "allocation_already_committed"}
	if not (snapshot.get("pending_trigger", {}) as Dictionary).is_empty() \
			or not (snapshot.get("pending_world", {}) as Dictionary).is_empty() \
			or not active_bundle_id().is_empty():
		return {"ok": false, "error": "cycle_entry_unresolved"}
	var outer_state := _normalized_state(GameState.core_loop_v2_state)
	var fresh_onboarding := _fresh_w1_onboarding_allocation_gate(
		outer_state, int(snapshot.get("month", 0)))
	if fresh_onboarding and node_id != W1_ONBOARDING_NODE_ID:
		return {"ok": false, "error": "onboarding_resume_required"}
	var selected_capacity: Dictionary = {}
	for raw_capacity in snapshot.get("capacities", []):
		if raw_capacity is Dictionary \
				and str((raw_capacity as Dictionary).get("id", "")) \
					== capacity_id:
			selected_capacity = (raw_capacity as Dictionary).duplicate(true)
			break
	if selected_capacity.is_empty():
		return {"ok": false, "error": "unknown_capacity"}
	if bool(selected_capacity.get("consumed", false)):
		return {"ok": false, "error": "capacity_already_consumed"}
	var raw_node: Variant = (snapshot.get("nodes", {}) as Dictionary).get(
		node_id, {})
	if not raw_node is Dictionary or (raw_node as Dictionary).is_empty():
		return {"ok": false, "error": "unknown_node"}
	var node: Dictionary = (raw_node as Dictionary).duplicate(true)
	var player_trigger_required := _seoul_cycle_player_trigger_required(node)
	var trigger_candidates: Array[Dictionary] = []
	if player_trigger_required:
		trigger_candidates = _seoul_cycle_player_trigger_candidate_records(
			node, turn)
	var persisted_trigger := str(node.get(
		"selected_trigger_bundle_id",
		node.get("trigger_bundle", ""))).strip_edges()
	var requested_trigger := selected_bundle_id.strip_edges()
	var eligible_ids: Array[String] = []
	if player_trigger_required:
		var raw_eligible_ids: Variant = node.get(
			"eligible_trigger_bundle_ids", [])
		if not raw_eligible_ids is Array:
			return {
				"ok": false,
				"error": "invalid_trigger_selection_state",
				"trigger_selection_required": true,
				"trigger_candidates": trigger_candidates,
			}
		for raw_id in raw_eligible_ids:
			eligible_ids.append(str(raw_id).strip_edges())
		eligible_ids.sort()
		var active_candidate_ids: Array[String] = []
		for candidate in trigger_candidates:
			active_candidate_ids.append(str(candidate.get("id", "")))
		if not persisted_trigger.is_empty():
			if not eligible_ids.has(persisted_trigger) \
					or not active_candidate_ids.has(persisted_trigger) \
					or (not requested_trigger.is_empty() \
						and requested_trigger != persisted_trigger):
				return {
					"ok": false,
					"error": "trigger_branch_change_rejected",
					"trigger_selection_required": false,
					"trigger_candidates": trigger_candidates,
					"selected_trigger_bundle_id": persisted_trigger,
				}
			node = _seoul_cycle_node_with_resolved_trigger(
				node, persisted_trigger, int(snapshot.get("month", 0)))
		elif not requested_trigger.is_empty():
			if not eligible_ids.has(requested_trigger) \
					or not active_candidate_ids.has(requested_trigger):
				return {
					"ok": false,
					"error": "invalid_trigger_selection",
					"trigger_selection_required": true,
					"trigger_candidates": trigger_candidates,
				}
			node = _seoul_cycle_node_with_resolved_trigger(
				node, requested_trigger, int(snapshot.get("month", 0)))
	var node_status := str(node.get("status", "open"))
	var repeatable := bool(node.get("repeatable_after_completion", false))
	if node_status in ["expired", "awaiting_trigger", "locked"] \
			or (node_status == "completed" and not repeatable):
		return {"ok": false, "error": "node_closed"}
	var deadline := int(node.get("deadline_week", 4))
	if week_index > deadline:
		return {"ok": false, "error": "node_deadline_passed"}
	var capacity_value := int(selected_capacity.get("value", 0))
	var gain := _seoul_cycle_progress_for_capacity(capacity_value)
	if gain <= 0:
		return {"ok": false, "error": "invalid_capacity_value"}
	var authored_threshold: int = maxi(1, int(node.get("threshold", 1)))
	var onboarding_override := fresh_onboarding \
		and node_id == W1_ONBOARDING_NODE_ID
	var threshold: int = 1 if onboarding_override else authored_threshold
	var progress_before: int = clampi(int(node.get("progress", 0)), 0, threshold)
	var authored_trigger := str(node.get("trigger_bundle", "")).strip_edges()
	var fallback_allocation := bool(node.get("fallback_mode", false)) \
		and repeatable \
		and node_status in ["open", "in_progress"]
	var trigger_min_week := clampi(
		int(node.get("trigger_min_week", 1)), 1, 4)
	var progress_ceiling := threshold
	if not authored_trigger.is_empty() and week_index < trigger_min_week:
		# Preparation can advance early, but its authored appointment/shift may
		# not be cashed in before the scene actually exists on the calendar.
		progress_ceiling = maxi(0, threshold - 1)
	var progress_after := progress_before if fallback_allocation else mini(
		progress_ceiling, progress_before + gain)
	var applied_progress := progress_after - progress_before
	var completed_now := not fallback_allocation \
		and progress_before < threshold \
		and progress_after >= threshold
	var repeat_allocation := node_status == "completed" and repeatable
	if applied_progress <= 0 and not repeat_allocation \
			and not fallback_allocation:
		return {
			"ok": false,
			"error": "no_progress_this_week",
			"month": int(snapshot.get("month", 0)),
			"turn": turn,
			"week_index": week_index,
			"capacity_id": capacity_id,
			"node_id": node_id,
		}
	var trigger_bundle := authored_trigger \
		if completed_now \
			and week_index <= clampi(int(node.get(
				"trigger_deadline_week", deadline)), 1, 4) \
			and bundle_allowed_in_week(authored_trigger, turn) \
		else ""
	var allocation_effects: Variant = node.get("allocation_effects", {})
	var raw_tier_effects: Variant = node.get(
		"allocation_effects_by_progress", {})
	if raw_tier_effects is Dictionary \
			and (raw_tier_effects as Dictionary).get(str(gain), {}) is Dictionary:
		allocation_effects = _merged_seoul_cycle_effects(
			allocation_effects,
			(raw_tier_effects as Dictionary).get(str(gain), {}))
	# A milestone action can be the work represented by this week's
	# allocation, rather than a second job stacked on top of it. In that case
	# its authored action surface is the sole owner of the milestone week's
	# effects; earlier and later repeatable allocations still use the ordinary
	# weekly effects.
	if not trigger_bundle.is_empty() and bool(node.get(
			"completion_replaces_allocation_effects", false)):
		allocation_effects = {}
	var immediate_effects := _merged_seoul_cycle_effects(
		allocation_effects,
		node.get("completion_effects", {}) if completed_now else {})
	var selection_missing := player_trigger_required \
		and persisted_trigger.is_empty() and requested_trigger.is_empty()
	return {
		"ok": not selection_missing,
		"error": "trigger_selection_required" if selection_missing else "",
		"month": int(snapshot.get("month", 0)),
		"turn": turn,
		"week_index": week_index,
		"capacity_id": capacity_id,
		"capacity_value": capacity_value,
		"capacity_quality": str(selected_capacity.get("quality", "")),
		"node_id": node_id,
		"node_status_before": node_status,
		"progress_before": progress_before,
		"base_progress": gain,
		"progress_gain": applied_progress,
		"progress_after": progress_after,
		"threshold": threshold,
		"authored_threshold": authored_threshold,
		"onboarding_completion_override": onboarding_override,
		"completed_now": completed_now,
		"repeat_allocation": repeat_allocation,
		"fallback_allocation": fallback_allocation,
		"deadline_week": deadline,
		"expires_after_turn": ((int(snapshot.get("month", 1)) - 1) * 4) \
			+ deadline,
		"will_expire": week_index >= deadline \
			and progress_after < threshold,
		"immediate_effects": immediate_effects,
		"trigger_bundle": trigger_bundle,
		"trigger_selection_required": selection_missing,
		"trigger_candidates": trigger_candidates,
		"selected_trigger_bundle_id": str(node.get(
			"selected_trigger_bundle_id", "")),
	}

static func commit_seoul_cycle_allocation(
		capacity_id: String, node_id: String,
		month_index: int = -1,
		selected_bundle_id: String = "") -> Dictionary:
	var preview := preview_seoul_cycle_allocation(
		capacity_id, node_id, month_index, selected_bundle_id)
	if not bool(preview.get("ok", false)):
		return preview
	var state := _normalized_state(GameState.core_loop_v2_state)
	var cycle: Dictionary = state.get(SEOUL_CYCLE_STATE_KEY, {})
	var turn := int(preview.get("turn", 0))
	var week_index := int(preview.get("week_index", 0))
	var capacity_index := -1
	for index in range((cycle.get("capacities", []) as Array).size()):
		var raw_capacity: Variant = cycle["capacities"][index]
		if raw_capacity is Dictionary \
				and str((raw_capacity as Dictionary).get("id", "")) \
					== capacity_id:
			capacity_index = index
			break
	if capacity_index < 0:
		return {"ok": false, "error": "unknown_capacity"}
	var capacity: Dictionary = cycle["capacities"][capacity_index]
	capacity["consumed"] = true
	capacity["consumed_turn"] = turn
	capacity["node_id"] = node_id
	cycle["capacities"][capacity_index] = capacity
	var node: Dictionary = cycle["nodes"].get(node_id, {})
	var selected_trigger_bundle_id := str(preview.get(
		"selected_trigger_bundle_id", "")).strip_edges()
	if _seoul_cycle_player_trigger_required(node):
		var migrated_legacy_selection := bool(node.get(
			"trigger_selection_migrated_legacy", false))
		var existing_trigger_bundle_id := str(node.get(
			"selected_trigger_bundle_id",
			node.get("trigger_bundle", ""))).strip_edges()
		var raw_eligible_ids: Variant = node.get(
			"eligible_trigger_bundle_ids", [])
		if not raw_eligible_ids is Array \
				or selected_trigger_bundle_id.is_empty() \
				or not (raw_eligible_ids as Array).has(
					selected_trigger_bundle_id) \
				or (not existing_trigger_bundle_id.is_empty() \
					and existing_trigger_bundle_id \
						!= selected_trigger_bundle_id):
			return {"ok": false, "error": "invalid_trigger_selection"}
		node = _seoul_cycle_node_with_resolved_trigger(
			node, selected_trigger_bundle_id,
			int(preview.get("month", 0)))
		# A migrated save may already contain allocation/weekly rows from before
		# selected identity was duplicated into every receipt. Preserve that
		# provenance for the lifetime of the node: new rows carry the exact saved
		# branch, while old blank rows remain historical rather than being
		# retroactively fabricated or invalidated on the next reload.
		node["trigger_selection_origin"] = (
			"legacy_persisted_trigger"
			if migrated_legacy_selection else "player_selection"
		)
		node["trigger_selection_migrated_legacy"] = \
			migrated_legacy_selection
	if bool(preview.get("onboarding_completion_override", false)):
		node["onboarding_completion_override_applied"] = true
		node["authored_threshold"] = int(preview.get(
			"authored_threshold", node.get("threshold", 1)))
		node["completion_threshold"] = int(preview.get("threshold", 1))
		node["onboarding_capacity_id"] = capacity_id
		node["onboarding_capacity_value"] = int(preview.get(
			"capacity_value", 0))
	node["progress"] = int(preview.get("progress_after", 0))
	node["last_allocation_turn"] = turn
	var trigger_bundle := str(preview.get("trigger_bundle", ""))
	if bool(preview.get("completed_now", false)):
		node["completed_turn"] = turn
		node["status"] = "awaiting_trigger" \
			if not trigger_bundle.is_empty() else "completed"
	elif not bool(preview.get("fallback_allocation", false)) \
			and str(node.get("status", "")) != "completed":
		node["status"] = "in_progress"
	cycle["nodes"][node_id] = node
	var effects: Dictionary = preview.get("immediate_effects", {})
	var before_effects := {
		"health": int(GameState.health),
		"mental": int(GameState.mental),
		"money": float(GameState.money),
	}
	var commitment := _seoul_cycle_commitment_payload(
		cycle, node_id, capacity_id, preview)
	if commitment.is_empty():
		return {"ok": false, "error": "weekly_commitment_conflict"}
	var commitment_axis := str(
		commitment.get("axis", "")).strip_edges()
	var transaction := GameState.finalize_seoul_cycle_weekly_commitment(
		commitment,
		effects,
		commitment_axis,
		str(node.get("place", "")))
	if not bool(transaction.get("ok", false)):
		return {"ok": false, "error": str(transaction.get(
			"error", "weekly_commitment_failed"))}
	var receipt := {
		"id": "seoul_cycle_m%d_w%d" % [
			int(preview.get("month", 1)), week_index],
		"status": "allocated",
		"planning_mode": SEOUL_CYCLE_MODE,
		"month": int(preview.get("month", 1)),
		"turn": turn,
		"week_index": week_index,
		"capacity_id": capacity_id,
		"capacity_value": int(preview.get("capacity_value", 0)),
		"node_id": node_id,
		"progress_before": int(preview.get("progress_before", 0)),
		"progress_gain": int(preview.get("progress_gain", 0)),
		"progress_after": int(preview.get("progress_after", 0)),
		"threshold": int(preview.get("threshold", 1)),
		"authored_threshold": int(preview.get(
			"authored_threshold", preview.get("threshold", 1))),
		"onboarding_completion_override": bool(preview.get(
			"onboarding_completion_override", false)),
		"completed_now": bool(preview.get("completed_now", false)),
		"repeat_allocation": bool(preview.get("repeat_allocation", false)),
		"fallback_allocation": bool(preview.get(
			"fallback_allocation", false)),
		"selected_trigger_bundle_id": selected_trigger_bundle_id,
		"trigger_bundle": trigger_bundle,
		"effects": effects.duplicate(true),
		"weekly_commitment": (
			transaction.get("record", {}) as Dictionary).duplicate(true),
		"before": before_effects,
		"after": {
			"health": int(GameState.health),
			"mental": int(GameState.mental),
			"money": float(GameState.money),
		},
	}
	cycle["allocation_receipts"][str(turn)] = receipt
	if bool(preview.get("onboarding_completion_override", false)):
		var onboarding: Dictionary = state.get(W1_ONBOARDING_STATE_KEY, {})
		onboarding["phase"] = "allocation_pending"
		onboarding["selected_capacity_id"] = capacity_id
		onboarding["selected_capacity_value"] = int(preview.get(
			"capacity_value", 0))
		state[W1_ONBOARDING_STATE_KEY] = onboarding
	var raw_world_clock: Variant = seoul_cycle_month_spec(
		int(preview.get("month", 1))).get("world_clock", {})
	var world_maximum := 4
	if raw_world_clock is Dictionary:
		world_maximum = maxi(1, int(
			(raw_world_clock as Dictionary).get("maximum", 4)))
	cycle["world_clock"] = mini(
		world_maximum, int(cycle.get("world_clock", 0)) + 1)
	if not trigger_bundle.is_empty():
		cycle["pending_trigger"] = {
			"kind": "node_trigger",
			"node_id": node_id,
			"bundle_id": trigger_bundle,
			"selected_trigger_bundle_id": selected_trigger_bundle_id,
			"turn": turn,
			"status": "pending",
		}
	var world_event := _seoul_cycle_world_event_for_week(
		int(preview.get("month", 1)), week_index)
	if not world_event.is_empty() \
			and not cycle["world_receipts"].has(str(week_index)):
		cycle["pending_world"] = {
			"kind": str(world_event.get("kind", "world")),
			"node_id": "",
			"bundle_id": str(world_event.get("bundle_id", "")),
			"turn": turn,
			"week_index": week_index,
			"status": "pending",
		}
	state[SEOUL_CYCLE_STATE_KEY] = cycle
	GameState.core_loop_v2_state = state
	var result := preview.duplicate(true)
	result["receipt"] = receipt.duplicate(true)
	result["pending_trigger"] = (
		cycle["pending_trigger"] as Dictionary).duplicate(true)
	result["pending_world"] = (
		cycle["pending_world"] as Dictionary).duplicate(true)
	result["turn_ready"] = _seoul_cycle_turn_ready(cycle, turn)
	return result

static func _seoul_cycle_commitment_payload(
		cycle: Dictionary, node_id: String, capacity_id: String,
		preview: Dictionary) -> Dictionary:
	var node: Dictionary = (cycle.get("nodes", {}) as Dictionary).get(
		node_id, {})
	if node.is_empty():
		return {}
	var action_id := str(node.get(
		"commitment_action_id",
		_seoul_cycle_default_action_id(str(node.get("owner", "")))
	)).strip_edges().to_lower()
	var axis := str(node.get(
		"axis", "money" if action_id == "side_shift" else "human"
	)).strip_edges().to_lower()
	if action_id.is_empty() or axis not in ["money", "human"]:
		return {}
	var owner := str(node.get("owner", "")).strip_edges().to_lower()
	# A contact commitment keeps the authored person even before that person's
	# first cast-effect record exists. Generic/unresolved people nodes are locked
	# at initialization and must never manufacture a person_id.
	var person_id := owner \
		if action_id == "contact" and owner != "people" else ""
	var forgone_ids: Array[String] = []
	var forgone_nodes: Array = []
	for raw_other_id in (cycle.get("nodes", {}) as Dictionary):
		var other_id := str(raw_other_id)
		if other_id == node_id:
			continue
		var other: Dictionary = cycle["nodes"].get(other_id, {})
		var other_status := str(other.get("status", "open"))
		if other_status in ["expired", "locked"] \
				or (other_status == "completed" and not bool(other.get(
					"repeatable_after_completion", false))):
			continue
		var other_action := str(other.get(
			"commitment_action_id",
			_seoul_cycle_default_action_id(str(other.get("owner", "")))
		)).strip_edges().to_lower()
		if not other_action.is_empty() and not forgone_ids.has(other_action):
			forgone_ids.append(other_action)
		forgone_nodes.append({
			"node_id": other_id,
			"label_ko": str(other.get("label_ko", "")),
			"label_en": str(other.get("label_en", "")),
		})
	return {
		"turn": int(preview.get("turn", GameState.turn)),
		"pressure_id": "seoul_cycle:m%d:w%d" % [
			int(preview.get("month", 1)), int(preview.get("week_index", 1))],
		"pressure_family": "seoul_cycle",
		"choice_id": action_id,
		"person_id": person_id,
		"forgone_ids": forgone_ids,
		"axis": axis,
		"details": {
			"execution": "seoul_cycle",
			"month": int(preview.get("month", 1)),
			"week_index": int(preview.get("week_index", 1)),
			"node_id": node_id,
			"capacity_id": capacity_id,
			"capacity_value": int(preview.get("capacity_value", 0)),
			"progress_gain": int(preview.get("progress_gain", 0)),
			"progress_after": int(preview.get("progress_after", 0)),
			"threshold": int(preview.get("threshold", 1)),
			"completed_now": bool(preview.get("completed_now", false)),
			"repeat_allocation": bool(preview.get(
				"repeat_allocation", false)),
			"fallback_allocation": bool(preview.get(
				"fallback_allocation", false)),
			"selected_trigger_bundle_id": str(preview.get(
				"selected_trigger_bundle_id", "")),
			"label_ko": str(node.get("label_ko", "")),
			"label_en": str(node.get("label_en", "")),
			"place": str(node.get("place", "")),
			"forgone_nodes": forgone_nodes,
			"followups": [],
		},
	}

static func _seoul_cycle_default_action_id(owner: String) -> String:
	match owner.strip_edges().to_lower():
		"livelihood":
			return "side_shift"
		"career":
			return "resume"
		"father", "mother", "hyunsu", "daeun", "jiyeon", "sangchul", "jaehyuk":
			return "contact"
		"self", "recovery":
			return "rest"
		"growth":
			return "study"
	return "study"

static func _merged_seoul_cycle_effects(
		first_raw: Variant, second_raw: Variant) -> Dictionary:
	var merged: Dictionary = {}
	for raw_effects in [first_raw, second_raw]:
		if not raw_effects is Dictionary:
			continue
		for raw_key in (raw_effects as Dictionary):
			var key := str(raw_key).strip_edges()
			if key not in ["health", "mental", "money"]:
				continue
			merged[key] = float(merged.get(key, 0.0)) \
				+ float((raw_effects as Dictionary).get(raw_key, 0.0))
			if key != "money":
				merged[key] = int(merged[key])
	return merged

static func _apply_seoul_cycle_effects(effects: Dictionary) -> void:
	for key in ["health", "mental", "money"]:
		if not effects.has(key):
			continue
		if key == "money":
			GameState.add_money(float(effects[key]))
		else:
			GameState.modify_stat(key, int(effects[key]))

static func _seoul_cycle_world_event_for_week(
		month_index: int, week_index: int) -> Dictionary:
	var raw_world: Variant = seoul_cycle_month_spec(
		month_index).get("world_clock", {})
	if not raw_world is Dictionary:
		return {}
	for raw_event in (raw_world as Dictionary).get("events", []):
		if not raw_event is Dictionary \
				or int((raw_event as Dictionary).get("week_index", 0)) \
					!= week_index:
			continue
		var event: Dictionary = (raw_event as Dictionary).duplicate(true)
		var candidates: Array[String] = []
		for raw_bundle_id in event.get("bundle_options", []):
			var candidate := str(raw_bundle_id).strip_edges()
			if not candidate.is_empty() and not candidates.has(candidate):
				candidates.append(candidate)
		var fixed_bundle := str(event.get("bundle_id", "")).strip_edges()
		if not fixed_bundle.is_empty() and not candidates.has(fixed_bundle):
			candidates.append(fixed_bundle)
		var absolute_turn := _seoul_cycle_month_start_turn(month_index) \
			+ week_index - 1
		for bundle_id in candidates:
			var scene_bundle := bundle(bundle_id)
			if scene_bundle.is_empty() \
					or not _bundle_requirement_met(scene_bundle) \
					or not bundle_allowed_in_week(bundle_id, absolute_turn):
				continue
			event["bundle_id"] = bundle_id
			return event
		return {}
	return {}

static func pending_seoul_cycle_trigger() -> Dictionary:
	var snapshot := seoul_cycle_snapshot()
	return (snapshot.get("pending_trigger", {}) as Dictionary).duplicate(true)

static func pending_seoul_cycle_world() -> Dictionary:
	var snapshot := seoul_cycle_snapshot()
	return (snapshot.get("pending_world", {}) as Dictionary).duplicate(true)

static func claim_seoul_cycle_trigger() -> Dictionary:
	return _claim_seoul_cycle_entry("pending_trigger")

static func claim_seoul_cycle_world() -> Dictionary:
	return _claim_seoul_cycle_entry("pending_world")

static func _claim_seoul_cycle_entry(pending_key: String) -> Dictionary:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var cycle: Dictionary = state.get(SEOUL_CYCLE_STATE_KEY, {})
	var raw_entry: Variant = cycle.get(pending_key, {})
	if not raw_entry is Dictionary or (raw_entry as Dictionary).is_empty():
		return {"ok": false, "error": "no_pending_cycle_entry", "entry": {}}
	var entry: Dictionary = (raw_entry as Dictionary).duplicate(true)
	if int(entry.get("turn", 0)) != int(GameState.turn):
		return {"ok": false, "error": "cycle_entry_turn_mismatch", "entry": {}}
	var status := str(entry.get("status", ""))
	if status == "claimed":
		return {
			"ok": true,
			"error": "",
			"entry": entry,
			"resumed": true,
		}
	if status != "pending":
		return {"ok": false, "error": "cycle_entry_not_pending", "entry": {}}
	entry["status"] = "claimed"
	entry["claimed_turn"] = int(GameState.turn)
	cycle[pending_key] = entry
	state[SEOUL_CYCLE_STATE_KEY] = cycle
	GameState.core_loop_v2_state = state
	return {
		"ok": true,
		"error": "",
		"entry": entry.duplicate(true),
		"resumed": false,
	}

static func begin_seoul_cycle_trigger(bundle_id: String) -> bool:
	return _begin_seoul_cycle_entry("pending_trigger", bundle_id)

static func begin_seoul_cycle_world(bundle_id: String) -> bool:
	return _begin_seoul_cycle_entry("pending_world", bundle_id)

static func _begin_seoul_cycle_entry(
		pending_key: String, bundle_id: String) -> bool:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var cycle: Dictionary = state.get(SEOUL_CYCLE_STATE_KEY, {})
	var raw_entry: Variant = cycle.get(pending_key, {})
	if not raw_entry is Dictionary:
		return false
	var entry: Dictionary = raw_entry
	if str(entry.get("status", "")) != "claimed" \
			or str(entry.get("bundle_id", "")) != bundle_id \
			or int(entry.get("turn", 0)) != int(GameState.turn):
		return false
	return begin_bundle(bundle_id, "schedule")

static func active_bundle_is_seoul_cycle_trigger() -> bool:
	return _active_bundle_matches_cycle_entry("pending_trigger")

static func active_bundle_is_seoul_cycle_world() -> bool:
	return _active_bundle_matches_cycle_entry("pending_world")

static func _active_bundle_matches_cycle_entry(pending_key: String) -> bool:
	var state := _normalized_state(GameState.core_loop_v2_state)
	if str(state.get("active_kind", "")) != "schedule" \
			or int(state.get("active_turn", 0)) != int(GameState.turn):
		return false
	var cycle: Dictionary = state.get(SEOUL_CYCLE_STATE_KEY, {})
	var raw_entry: Variant = cycle.get(pending_key, {})
	return raw_entry is Dictionary \
		and str((raw_entry as Dictionary).get("status", "")) == "claimed" \
		and str((raw_entry as Dictionary).get("bundle_id", "")) \
			== str(state.get("active_bundle", "")) \
		and int((raw_entry as Dictionary).get("turn", 0)) \
			== int(GameState.turn)

static func resolve_seoul_cycle_trigger(bundle_id: String) -> bool:
	return _resolve_seoul_cycle_entry_public(
		"pending_trigger", "trigger_receipts", bundle_id)

static func resolve_seoul_cycle_world(bundle_id: String) -> bool:
	return _resolve_seoul_cycle_entry_public(
		"pending_world", "world_receipts", bundle_id)

static func _resolve_seoul_cycle_entry_public(
		pending_key: String, receipt_key: String,
		bundle_id: String) -> bool:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var cycle: Dictionary = state.get(SEOUL_CYCLE_STATE_KEY, {})
	var receipt_id := _seoul_cycle_entry_receipt_id(
		cycle, pending_key, bundle_id)
	var raw_existing: Variant = cycle.get(receipt_key, {}).get(
		receipt_id, {}) if cycle.get(receipt_key, {}) is Dictionary else {}
	if _seoul_cycle_resolved_receipt_matches(
			raw_existing, pending_key, receipt_id,
			bundle_id, int(GameState.turn)):
		return true
	if not active_bundle_id().is_empty() \
			or int(state["completed_bundle_turns"].get(bundle_id, 0)) \
				!= int(GameState.turn):
		return false
	if not _resolve_seoul_cycle_entry_in_state(
			state, pending_key, receipt_key, bundle_id,
			int(GameState.turn)):
		return false
	GameState.core_loop_v2_state = state
	return true

static func _seoul_cycle_entry_receipt_id(
		cycle: Dictionary, pending_key: String,
		bundle_id: String) -> String:
	var raw_entry: Variant = cycle.get(pending_key, {})
	if raw_entry is Dictionary and not (raw_entry as Dictionary).is_empty():
		if pending_key == "pending_trigger":
			return str((raw_entry as Dictionary).get("node_id", ""))
		return _seoul_cycle_world_receipt_id(raw_entry as Dictionary)
	if pending_key == "pending_trigger":
		for raw_node_id in cycle.get("nodes", {}):
			var raw_node: Variant = cycle["nodes"].get(raw_node_id, {})
			if raw_node is Dictionary \
					and str((raw_node as Dictionary).get(
						"trigger_bundle", "")) == bundle_id:
				return str(raw_node_id)
	var month := int(cycle.get("month", 0))
	var week_index := int(GameState.turn) \
		- _seoul_cycle_month_start_turn(month) + 1
	return str(week_index) if week_index >= 1 and week_index <= 4 else ""

static func _seoul_cycle_resolved_receipt_matches(
		raw_receipt: Variant, pending_key: String,
		receipt_id: String, bundle_id: String, turn: int) -> bool:
	if receipt_id.is_empty() or not raw_receipt is Dictionary:
		return false
	var receipt: Dictionary = raw_receipt
	if str(receipt.get("status", "")) != "resolved" \
			or str(receipt.get("bundle_id", "")) != bundle_id \
			or int(receipt.get("turn", 0)) != turn \
			or int(receipt.get("claimed_turn", 0)) != turn \
			or int(receipt.get("resolved_turn", 0)) != turn:
		return false
	if pending_key == "pending_trigger":
		return str(receipt.get("node_id", "")) == receipt_id
	return _seoul_cycle_world_receipt_id(receipt) == receipt_id

static func _resolve_seoul_cycle_entry_in_state(
		state: Dictionary, pending_key: String,
		receipt_key: String, bundle_id: String,
		turn: int) -> bool:
	var cycle: Dictionary = state.get(SEOUL_CYCLE_STATE_KEY, {})
	var raw_entry: Variant = cycle.get(pending_key, {})
	if not raw_entry is Dictionary or (raw_entry as Dictionary).is_empty():
		return false
	var entry: Dictionary = (raw_entry as Dictionary).duplicate(true)
	if str(entry.get("status", "")) != "claimed" \
			or str(entry.get("bundle_id", "")) != bundle_id \
			or int(entry.get("turn", 0)) != turn:
		return false
	var receipt_id := str(entry.get("node_id", "")) \
		if pending_key == "pending_trigger" \
		else _seoul_cycle_world_receipt_id(entry)
	if receipt_id.is_empty():
		return false
	if pending_key == "pending_trigger":
		var node_id := str(entry.get("node_id", ""))
		var node: Dictionary = cycle["nodes"].get(node_id, {})
		if node.is_empty():
			return false
	if not GameState.append_weekly_commitment_followup(turn, {
		"kind": "node_trigger" if pending_key == "pending_trigger" else "world",
		"source_kind": str(entry.get("kind", "")),
		"bundle_id": bundle_id,
		"node_id": str(entry.get("node_id", "")),
		"selected_trigger_bundle_id": str(entry.get(
			"selected_trigger_bundle_id", "")),
		"week_index": int(entry.get("week_index", 0)),
	}):
		return false
	entry["status"] = "resolved"
	entry["resolved_turn"] = turn
	cycle[receipt_key][receipt_id] = entry.duplicate(true)
	if pending_key == "pending_trigger":
		var node_id := str(entry.get("node_id", ""))
		var node: Dictionary = cycle["nodes"].get(node_id, {})
		node["status"] = "completed"
		node["completed_turn"] = turn
		cycle["nodes"][node_id] = node
	cycle[pending_key] = {}
	state[SEOUL_CYCLE_STATE_KEY] = cycle
	return true

static func _seoul_cycle_world_receipt_id(entry: Dictionary) -> String:
	var raw_week: Variant = entry.get("week_index", null)
	if not (raw_week is int or raw_week is float) \
			or not is_finite(float(raw_week)):
		return ""
	var week_index := int(raw_week)
	if week_index < 1 or week_index > 4 \
			or float(raw_week) != float(week_index):
		return ""
	return str(week_index)

static func complete_seoul_cycle_turn(
		month_index: int = -1) -> Dictionary:
	var snapshot := seoul_cycle_snapshot(month_index)
	if not bool(snapshot.get("active", false)):
		return {"ok": false, "error": "seoul_cycle_inactive"}
	var turn := int(snapshot.get("turn", 0))
	var week_index := int(snapshot.get("week_index", 0))
	if (snapshot.get("completed_turns", []) as Array).has(turn) \
			or turn_completed(turn):
		return {"ok": false, "error": "cycle_turn_already_completed"}
	if not active_bundle_id().is_empty():
		return {"ok": false, "error": "cycle_entry_active"}
	if not _seoul_cycle_turn_ready(snapshot, turn):
		return {"ok": false, "error": "cycle_turn_not_ready"}
	var weekly_commitment := GameState.get_weekly_commitment_for_turn(turn)
	var weekly_details: Dictionary = weekly_commitment.get("details", {}) \
		if weekly_commitment.get("details", {}) is Dictionary else {}
	if str(weekly_details.get("execution", "")) != "seoul_cycle" \
			or str(weekly_details.get("node_id", "")) \
				!= str((snapshot.get("allocation_receipts", {}) as Dictionary).get(
					str(turn), {}).get("node_id", "")):
		return {"ok": false, "error": "cycle_weekly_commitment_missing"}
	var state := _normalized_state(GameState.core_loop_v2_state)
	var cycle: Dictionary = state.get(SEOUL_CYCLE_STATE_KEY, {})
	var expired_this_turn: Array[String] = []
	var expiry_receipts_this_turn: Array = []
	for raw_node_id in cycle.get("nodes", {}):
		var node_id := str(raw_node_id)
		var node: Dictionary = cycle["nodes"].get(node_id, {})
		var trigger_deadline: int = clampi(int(node.get(
			"trigger_deadline_week", node.get("deadline_week", 4))), 1, 4)
		var trigger_receipt_id := "%s:trigger" % node_id
		if bool(node.get("fallback_after_trigger_expiry", false)) \
				and str(node.get("featured_status", "open")) == "open" \
				and not str(node.get("trigger_bundle", "")).is_empty() \
				and str(node.get("status", "")) in ["open", "in_progress"] \
				and week_index >= trigger_deadline \
				and not cycle["expiry_receipts"].has(trigger_receipt_id):
			var trigger_expiry_effects: Dictionary = node.get(
				"trigger_expiry_effects", {}) \
				if node.get("trigger_expiry_effects", {}) is Dictionary else {}
			var trigger_before := {
				"money": float(GameState.money),
				"health": int(GameState.health),
				"mental": int(GameState.mental),
			}
			_apply_seoul_cycle_effects(trigger_expiry_effects)
			var missed_trigger := str(node.get("trigger_bundle", ""))
			var trigger_expiry_receipt := {
				"scope": "trigger",
				"node_id": node_id,
				"trigger_bundle": missed_trigger,
				"turn": turn,
				"week_index": week_index,
				"status": "consumed",
				"consequence_id": str(node.get(
					"trigger_expiry_consequence",
					"%s_opportunity_missed" % node_id)),
				"effects": trigger_expiry_effects.duplicate(true),
				"before": trigger_before,
				"after": {
					"money": float(GameState.money),
					"health": int(GameState.health),
					"mental": int(GameState.mental),
				},
			}
			cycle["expiry_receipts"][trigger_receipt_id] = (
				trigger_expiry_receipt)
			expiry_receipts_this_turn.append(
				trigger_expiry_receipt.duplicate(true))
			node["featured_status"] = "expired"
			node["missed_trigger_bundle"] = missed_trigger
			node["trigger_bundle"] = ""
			# Closing the featured opportunity is not the same as completing work
			# the player never did. Keep the real clock/status, and let a declared
			# fallback produce a separate zero-progress weekly receipt.
			node["fallback_mode"] = true
			cycle["nodes"][node_id] = node
		if str(node.get("status", "")) in ["open", "in_progress"] \
				and int(node.get("deadline_week", 4)) <= week_index:
			node["status"] = "expired"
			node["expired_turn"] = turn
			cycle["nodes"][node_id] = node
			expired_this_turn.append(node_id)
			if not cycle["expired_nodes"].has(node_id):
				cycle["expired_nodes"].append(node_id)
			if not cycle["expiry_receipts"].has(node_id):
				var expiry_effects: Dictionary = node.get("expiry_effects", {}) \
					if node.get("expiry_effects", {}) is Dictionary else {}
				var expiry_before := {
					"money": float(GameState.money),
					"health": int(GameState.health),
					"mental": int(GameState.mental),
				}
				_apply_seoul_cycle_effects(expiry_effects)
				var expiry_receipt := {
					"node_id": node_id,
					"turn": turn,
					"week_index": week_index,
					"status": "consumed",
					"consequence_id": str(node.get(
						"expiry_consequence", "%s_expired" % node_id)),
					"effects": expiry_effects.duplicate(true),
					"before": expiry_before,
					"after": {
						"money": float(GameState.money),
						"health": int(GameState.health),
						"mental": int(GameState.mental),
					},
				}
				cycle["expiry_receipts"][node_id] = expiry_receipt
				expiry_receipts_this_turn.append(expiry_receipt.duplicate(true))
	var receipt: Dictionary = cycle["allocation_receipts"].get(str(turn), {})
	receipt["status"] = "turn_completed"
	receipt["completed_turn"] = turn
	receipt["expired_nodes"] = expired_this_turn.duplicate()
	cycle["allocation_receipts"][str(turn)] = receipt
	cycle["completed_turns"].append(turn)
	if not state["completed_turns"].has(turn):
		state["completed_turns"].append(turn)
	state[SEOUL_CYCLE_STATE_KEY] = cycle
	GameState.core_loop_v2_state = state
	if not GameState.refresh_seoul_cycle_weekly_commitment(turn):
		push_error("Seoul cycle could not refresh its weekly commitment")
	return {
		"ok": true,
		"error": "",
		"turn": turn,
		"receipt": receipt.duplicate(true),
		"expired_nodes": expired_this_turn,
		"expiry_receipts": expiry_receipts_this_turn,
		"next_turn": turn + 1,
	}

static func _seoul_cycle_turn_ready(
		cycle: Dictionary, turn: int) -> bool:
	if cycle.is_empty() \
			or (cycle.get("completed_turns", []) as Array).has(turn) \
			or not (cycle.get("allocation_receipts", {}) as Dictionary).has(
				str(turn)) \
			or not (cycle.get("pending_trigger", {}) as Dictionary).is_empty() \
			or not (cycle.get("pending_world", {}) as Dictionary).is_empty():
		return false
	var month := int(cycle.get("month", 1))
	var week_index := turn - ((month - 1) * 4)
	var world_event := _seoul_cycle_world_event_for_week(month, week_index)
	if not world_event.is_empty():
		var raw_receipt: Variant = (
			cycle.get("world_receipts", {}) as Dictionary).get(
				str(week_index), {})
		if not _seoul_cycle_resolved_receipt_matches(
				raw_receipt, "pending_world", str(week_index),
				str(world_event.get("bundle_id", "")), turn):
			return false
	for raw_node in (cycle.get("nodes", {}) as Dictionary).values():
		if raw_node is Dictionary \
				and str((raw_node as Dictionary).get("status", "")) \
					== "awaiting_trigger":
			return false
	return true

static func episode_selection_enabled(month_index: int = -1) -> bool:
	var target_month := (
		month_index if month_index > 0 else month_for_turn(GameState.turn))
	var spec := episode_plan_spec()
	if spec.is_empty() \
			or target_month != int(spec.get("prototype_month", 0)):
		return false
	var existing := plan_for_month(target_month)
	if not existing.is_empty():
		# Only plans born through the new commit path may reopen on the episode
		# surface. A legacy Month-One plan can change application eligibility
		# after Week One, but that must never relabel its W1/W2 slots as promises.
		return plan_uses_episode_selection(existing)
	var state := _normalized_state(GameState.core_loop_v2_state)
	if _fresh_seoul_cycle_gate(state, target_month):
		return false
	var available := available_offer_ids(target_month)
	for raw_id in spec.get("incompatible_if_available", []):
		if available.has(str(raw_id).strip_edges()):
			# A legacy save may still own the old Month-One application card. It
			# must finish with the legacy planner rather than silently lose it.
			return false
	var offers := episode_offer_ids(target_month)
	return offers.size() >= maxi(1, int(spec.get("selection_count", 2)))

static func episode_offer_ids(month_index: int = -1) -> Array[String]:
	var target_month := (
		month_index if month_index > 0 else month_for_turn(GameState.turn))
	var spec := episode_plan_spec()
	var result: Array[String] = []
	if target_month != int(spec.get("prototype_month", 0)):
		return result
	var available := available_offer_ids(target_month)
	for raw_id in spec.get("player_offers", []):
		var bundle_id := str(raw_id).strip_edges()
		if available.has(bundle_id) and not result.has(bundle_id):
			result.append(bundle_id)
	return result

static func plan_uses_episode_selection(raw_plan: Dictionary) -> bool:
	if str(raw_plan.get("planning_mode", "")) != MONTH_ONE_EPISODE_MODE:
		return false
	var raw_commitments: Variant = raw_plan.get("player_commitments", [])
	if not raw_commitments is Array:
		return false
	var commitments: Array = raw_commitments
	if commitments.size() != 2:
		return false
	var typed_commitments: Array[String] = []
	var raw_allowed: Variant = episode_plan_spec().get("player_offers", [])
	if not raw_allowed is Array:
		return false
	for raw_id in commitments:
		var bundle_id := str(raw_id).strip_edges()
		if bundle_id.is_empty() or not (raw_allowed as Array).has(bundle_id) \
				or typed_commitments.has(bundle_id):
			return false
		typed_commitments.append(bundle_id)
	var expected := _episode_schedule_for_selection(1, typed_commitments)
	var raw_schedule: Variant = raw_plan.get("schedule", {})
	if expected.is_empty() or not raw_schedule is Dictionary:
		return false
	var actual := _normalized_schedule(raw_schedule as Dictionary)
	if actual.size() != expected.size():
		return false
	for week_key in expected:
		if str(actual.get(week_key, "")) != str(expected[week_key]):
			return false
	return true

static func episode_commitments_from_plan(raw_plan: Dictionary) -> Array[String]:
	var result: Array[String] = []
	if not plan_uses_episode_selection(raw_plan):
		return result
	for raw_id in raw_plan.get("player_commitments", []):
		result.append(str(raw_id).strip_edges())
	return result

static func _episode_schedule_for_selection(
		month_index: int, ordered_ids: Array[String]) -> Dictionary:
	var spec := episode_plan_spec()
	var month := month_spec(month_index)
	var weeks: Array = month.get("weeks", [])
	if weeks.size() != 2 or ordered_ids.size() != 2:
		return {}
	var first_week := int(weeks[0])
	var schedule := {
		str(first_week): ordered_ids[0],
		str(first_week + 1): ordered_ids[1],
	}
	for raw_entry in spec.get("automatic_schedule", []):
		if not raw_entry is Dictionary:
			return {}
		var entry: Dictionary = raw_entry
		var week := int(entry.get("week", 0))
		var bundle_id := str(entry.get("bundle", "")).strip_edges()
		if week < first_week or week > int(weeks[1]) \
				or bundle_id.is_empty() or schedule.has(str(week)):
			return {}
		schedule[str(week)] = bundle_id
	return schedule

static func validate_episode_selection(
		month_index: int, raw_ordered_ids: Array) -> Dictionary:
	if not episode_selection_enabled(month_index):
		return {"ok": false, "error": "episode_selection_unavailable"}
	var selection_count := maxi(
		1, int(episode_plan_spec().get("selection_count", 2)))
	if raw_ordered_ids.size() != selection_count:
		return {"ok": false, "error": "choose_two_commitments"}
	var allowed := episode_offer_ids(month_index)
	var ordered_ids: Array[String] = []
	for raw_id in raw_ordered_ids:
		var bundle_id := str(raw_id).strip_edges()
		if not allowed.has(bundle_id):
			return {
				"ok": false,
				"error": "unavailable_bundle",
				"bundle": bundle_id,
			}
		if ordered_ids.has(bundle_id):
			return {
				"ok": false,
				"error": "duplicate_bundle",
				"bundle": bundle_id,
			}
		ordered_ids.append(bundle_id)
	var schedule := _episode_schedule_for_selection(month_index, ordered_ids)
	if schedule.is_empty():
		return {"ok": false, "error": "invalid_episode_schedule"}
	var routines := default_routines()
	var plan_validation := validate_plan(month_index, schedule, routines)
	if not bool(plan_validation.get("ok", false)):
		return plan_validation
	return {
		"ok": true,
		"ordered_ids": ordered_ids,
		"schedule": plan_validation.get("schedule", {}).duplicate(true),
		"routines": plan_validation.get("routines", {}).duplicate(true),
	}

static func commit_episode_selection(
		month_index: int, raw_ordered_ids: Array) -> Dictionary:
	var validation := validate_episode_selection(month_index, raw_ordered_ids)
	if not bool(validation.get("ok", false)):
		return validation
	var result := commit_plan(
		month_index,
		validation.get("schedule", {}),
		validation.get("routines", {}))
	if not bool(result.get("ok", false)):
		return result
	var state := _normalized_state(GameState.core_loop_v2_state)
	var plan: Dictionary = state["plans"].get(str(month_index), {})
	var ordered_ids: Array = validation.get("ordered_ids", [])
	plan["planning_mode"] = MONTH_ONE_EPISODE_MODE
	plan["player_commitments"] = ordered_ids.duplicate()
	state["plans"][str(month_index)] = plan
	GameState.core_loop_v2_state = state
	result["planning_mode"] = MONTH_ONE_EPISODE_MODE
	result["player_commitments"] = ordered_ids.duplicate()
	return result

static func month_one_episode_echo(replay_snapshot: Dictionary = {}) -> String:
	# The first-month crisis is not part of gallery replay today. Keeping the
	# argument makes the formatter contract explicit and avoids leaking current
	# run state into a future replay if that event is added to the archive.
	if not replay_snapshot.is_empty():
		return ""
	var state := _normalized_state(GameState.core_loop_v2_state)
	if str(state.get("active_bundle", "")) != "first_temptation_boss" \
			or str(state.get("active_kind", "")) != "schedule" \
			or int(state.get("active_turn", 0)) != 4 \
			or int(GameState.turn) != 4:
		return ""
	var plan := plan_for_month(1)
	if plan_uses_seoul_cycle(plan):
		return _seoul_cycle_month_one_echo(state)
	var commitments := episode_commitments_from_plan(plan)
	if commitments.is_empty():
		return ""
	var completed_turn := int(
		state["completed_bundle_turns"].get(commitments[0], 0))
	if completed_turn < 1 or completed_turn > 3:
		return ""
	var raw_echoes: Variant = episode_plan_spec().get("primary_echo", {})
	if not raw_echoes is Dictionary:
		return ""
	var raw_copy: Variant = (raw_echoes as Dictionary).get(commitments[0], {})
	if not raw_copy is Dictionary:
		return ""
	var copy := LocaleManager.ui(
		str((raw_copy as Dictionary).get("copy_ko", "")),
		str((raw_copy as Dictionary).get("copy_en", "")))
	return "\n\n%s" % copy if not copy.is_empty() else ""

static func _seoul_cycle_month_one_echo(state: Dictionary) -> String:
	var cycle: Dictionary = state.get(SEOUL_CYCLE_STATE_KEY, {})
	if cycle.is_empty() or int(cycle.get("month", 0)) != 1:
		return ""
	var nodes: Dictionary = cycle.get("nodes", {})
	var receipts: Dictionary = cycle.get("allocation_receipts", {})
	# The crisis reads the material trace from the week that just happened,
	# never the month's numerically strongest clock. This keeps the room detail
	# aligned with the player's actual W4 allocation.
	var raw_receipt: Variant = receipts.get("4", {})
	if not raw_receipt is Dictionary:
		return ""
	var node_id := str((raw_receipt as Dictionary).get("node_id", ""))
	var raw_node: Variant = nodes.get(node_id, {})
	if not raw_node is Dictionary \
			or int((raw_receipt as Dictionary).get("turn", 0)) != 4:
		return ""
	var chosen_node: Dictionary = raw_node
	var copy := LocaleManager.ui(
		str(chosen_node.get("echo_ko", "")),
		str(chosen_node.get("echo_en", "")))
	return "\n\n%s" % copy if not copy.is_empty() else ""

static func needs_plan(month_index: int = -1) -> bool:
	return plan_for_month(month_index).is_empty()

## Compatibility API for pre-ORDER-101 saves that still own the old
## prologue -> Send -> interview queue. A fresh run has an explicit onboarding
## marker and must never reserve these legacy roots ahead of its W1 action.
static func fresh_preplan_opening_roots() -> Array:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var onboarding: Dictionary = state.get(W1_ONBOARDING_STATE_KEY, {})
	if str(onboarding.get("origin", "")) == W1_ONBOARDING_ORIGIN:
		return []
	if not _preplan_opening_base_available(state) \
			or not bool(GameState.flags.get("prologue_done", false)) \
			or not str(state.get("active_bundle", "")).is_empty():
		return []
	var roots: Array = []
	for raw_root in resolved_event_roots(OPENING_INTERVIEW_BUNDLE_ID):
		var root_id := str(raw_root).strip_edges()
		if not root_id.is_empty() and not roots.has(root_id):
			roots.append(root_id)
	return roots

static func _legacy_preplan_opening_queue_matches(
		reserved_queue: Array) -> bool:
	var roots := resolved_event_roots(OPENING_INTERVIEW_BUNDLE_ID)
	if roots.is_empty() or reserved_queue.size() < roots.size() \
			or reserved_queue.size() > roots.size() + 1:
		return false
	for root_index in range(roots.size()):
		if str(reserved_queue[root_index]) != str(roots[root_index]):
			return false
	return reserved_queue.size() == roots.size() \
		or str(reserved_queue.back()) == "chapter_card_33"

static func _legacy_preplan_opening_send_available(
		state: Dictionary, event_id: String, choice_index: int,
		reserved_queue: Array) -> bool:
	var onboarding: Dictionary = state.get(W1_ONBOARDING_STATE_KEY, {})
	var trigger := _preplan_opening_trigger()
	var raw_choices: Variant = trigger.get("choices", [])
	var choice_matches := false
	if raw_choices is Array:
		for raw_choice in raw_choices as Array:
			if int(raw_choice) == choice_index:
				choice_matches = true
				break
	if not onboarding.is_empty() \
			or trigger.is_empty() \
			or trigger.get("legacy_only", false) != true \
			or event_id != str(trigger.get("event_id", "")) \
			or not raw_choices is Array \
			or not choice_matches \
			or not _legacy_preplan_opening_queue_matches(reserved_queue) \
			or not _preplan_opening_base_available(state) \
			or not str(state.get("active_bundle", "")).is_empty() \
			or not bool(GameState.flags.get("prologue_done", false)) \
			or bool(GameState.flags.get("story_job_unlocked", false)) \
			or bool(GameState.flags.get(
				"opening_interview_application_sent", false)) \
			or bool(GameState.flags.get(
				"opening_preplan_application_sent", false)) \
			or GameState.has_pending_weekly_commitment(int(GameState.turn)) \
			or GameState.has_weekly_commitment_for_turn(int(GameState.turn)):
		return false
	var application_id := str(trigger.get(
		"application_id", "")).strip_edges()
	var transition_key := "%s:%s:%d:%d" % [
		OPENING_INTERVIEW_BUNDLE_ID, event_id, choice_index,
		int(GameState.turn)]
	return not application_id.is_empty() \
		and str(trigger.get("status", "")) == "submitted" \
		and application_status(application_id).is_empty() \
		and not state["application_transition_receipts"].has(
			transition_key) \
		and not state["action_receipts"].has(W1_ONBOARDING_BUNDLE_ID)

## Fresh V2 replaces the legacy app-open card with one deeper scene that ends
## in an actual Send. The replacement is allowed only while StoryMode still
## holds both reserved opening roots, so an old save paused in the legacy
## prologue cannot be silently rewritten into a submitted application.
static func opening_follow_up_event(
		event_id: String, follow_up_id: String,
		reserved_queue: Array) -> String:
	if event_id != "story_prologue_meal" \
			or follow_up_id != "story_pressure":
		return follow_up_id
	var state := _normalized_state(GameState.core_loop_v2_state)
	var onboarding: Dictionary = state.get(W1_ONBOARDING_STATE_KEY, {})
	if str(onboarding.get("origin", "")) == W1_ONBOARDING_ORIGIN \
			and str(onboarding.get("phase", "")) == "prologue" \
			and int(GameState.turn) == 1:
		# End StoryMode after the meal. The next owner is the guided W1 board;
		# neither the legacy pressure card nor the former Send preview may enter
		# the fresh queue.
		return ""
	if not _preplan_opening_base_available(state) \
			or not bool(GameState.flags.get("prologue_done", false)) \
			or bool(GameState.flags.get("story_job_unlocked", false)) \
			or bool(GameState.flags.get(
				"opening_interview_application_sent", false)):
		return follow_up_id
	if not onboarding.is_empty() \
			or not _legacy_preplan_opening_queue_matches(reserved_queue):
		return follow_up_id
	var trigger_event_id := str(_preplan_opening_trigger().get(
		"event_id", "")).strip_edges()
	return OPENING_APPLICATION_EVENT_ID \
		if trigger_event_id == OPENING_APPLICATION_EVENT_ID else follow_up_id

## Recovery entry for V2 saves made after the old prologue but before Month 1
## was planned. A consumed/shown interview receipt or an already-interviewed
## application is authoritative and is never replayed or rewritten.
static func needs_preplan_opening() -> bool:
	var state := _normalized_state(GameState.core_loop_v2_state)
	if not _preplan_opening_base_available(state) \
			or not str(state.get("active_bundle", "")).is_empty() \
			or not bool(GameState.flags.get("prologue_done", false)) \
			or not bool(GameState.flags.get("story_job_unlocked", false)):
		return false
	var application_id := _preplan_opening_application_id()
	if application_id.is_empty():
		return false
	var status := application_status(application_id)
	if not bool(GameState.flags.get(
			"opening_interview_application_sent", false)) \
			and status != "submitted":
		return false
	return status.is_empty() or status == "submitted"

static func claim_saved_preplan_opening() -> bool:
	if not needs_preplan_opening():
		return false
	return _claim_preplan_opening("saved_preplan_recovery")

static func _preplan_opening_base_available(state: Dictionary) -> bool:
	if not (state.get(W1_ONBOARDING_STATE_KEY, {}) as Dictionary).is_empty() \
			or not bool(state.get("enabled", false)) \
			or int(GameState.turn) != 1:
		return false
	var raw_plan: Variant = state["plans"].get("1", {})
	if raw_plan is Dictionary and not (raw_plan as Dictionary).is_empty():
		return false
	if state["shown_consequences"].has(OPENING_INTERVIEW_BUNDLE_ID) \
			or state["consequence_receipts"].has(
				OPENING_INTERVIEW_BUNDLE_ID) \
			or bool(GameState.flags.get("arc_intro_meal_seen", false)):
		return false
	var opening := bundle(OPENING_INTERVIEW_BUNDLE_ID)
	return not opening.is_empty() \
		and str(opening.get("kind", "")) == "consequence" \
		and bundle_allowed_in_week(
			OPENING_INTERVIEW_BUNDLE_ID, int(GameState.turn)) \
		and not resolved_event_roots(
			OPENING_INTERVIEW_BUNDLE_ID).is_empty()

static func _preplan_opening_trigger() -> Dictionary:
	var raw_trigger: Variant = bundle(
		OPENING_INTERVIEW_BUNDLE_ID).get("preplan_trigger", {})
	return (raw_trigger as Dictionary).duplicate(true) \
		if raw_trigger is Dictionary else {}

static func _preplan_opening_application_id() -> String:
	return str(_preplan_opening_trigger().get(
		"application_id", "")).strip_edges()

static func claim_preplan_opening_from_trigger(
		event_id: String, choice_index: int) -> bool:
	var trigger := _preplan_opening_trigger()
	var raw_choices: Variant = trigger.get("choices", [])
	if trigger.is_empty() or event_id != str(trigger.get("event_id", "")) \
			or not raw_choices is Array:
		return false
	var choice_matches := false
	for raw_choice in raw_choices:
		if int(raw_choice) == choice_index:
			choice_matches = true
			break
	if not choice_matches \
			or not bool(GameState.flags.get("prologue_done", false)) \
			or not bool(GameState.flags.get("story_job_unlocked", false)) \
			or not bool(GameState.flags.get(
				"opening_interview_application_sent", false)):
		return false
	return _claim_preplan_opening("story_choice")

## Old saves paused on the former Story-owned Send surface have no onboarding
## marker but do retain the adjacent interview/math queue. The state-free
## authored choice proves the click; this exact origin-gated transaction then
## restores the legacy application provenance and consequence owner without a
## weekly/action receipt. A failed postcondition restores the pre-click state.
static func claim_legacy_preplan_opening_from_send(
		event_id: String, choice_index: int,
		reserved_queue: Array) -> bool:
	var state := _normalized_state(GameState.core_loop_v2_state)
	if not _legacy_preplan_opening_send_available(
			state, event_id, choice_index, reserved_queue):
		return false
	var snapshot: Dictionary = GameState.serialize().duplicate(true)
	GameState.flags["story_job_unlocked"] = true
	GameState.flags["opening_interview_application_sent"] = true
	GameState.flags["opening_preplan_application_sent"] = true
	if not _claim_preplan_opening("story_choice"):
		GameState.call("_restore_serialized_snapshot_exact", snapshot)
		return false
	state = _normalized_state(GameState.core_loop_v2_state)
	var application_id := _preplan_opening_application_id()
	var transition_key := "%s:%s:%d:%d" % [
		OPENING_INTERVIEW_BUNDLE_ID, event_id, choice_index,
		int(GameState.turn)]
	state["application_transition_receipts"][transition_key] = {
		"receipt_key": transition_key,
		"application_id": application_id,
		"from": "not_submitted",
		"to": "submitted",
		"bundle_id": OPENING_INTERVIEW_BUNDLE_ID,
		"event_id": event_id,
		"choice_index": choice_index,
		"turn": int(GameState.turn),
		"source": "legacy_story_send",
	}
	GameState.core_loop_v2_state = state
	state = _normalized_state(GameState.core_loop_v2_state)
	var raw_receipt: Variant = state["consequence_receipts"].get(
		OPENING_INTERVIEW_BUNDLE_ID, {})
	var raw_transition: Variant = state[
		"application_transition_receipts"].get(transition_key, {})
	var valid: bool = raw_receipt is Dictionary \
		and str((raw_receipt as Dictionary).get("status", "")) \
			== "presented" \
		and str((raw_receipt as Dictionary).get("claim_source", "")) \
			== "story_choice" \
		and (raw_receipt as Dictionary).get("roots", []) \
			== resolved_event_roots(OPENING_INTERVIEW_BUNDLE_ID) \
		and str(state.get("active_bundle", "")) \
			== OPENING_INTERVIEW_BUNDLE_ID \
		and str(state.get("active_kind", "")) == "consequence" \
		and int(state.get("active_turn", 0)) == int(GameState.turn) \
		and str(state["application_statuses"].get(application_id, "")) \
			== "submitted" \
		and raw_transition is Dictionary \
		and str((raw_transition as Dictionary).get("receipt_key", "")) \
			== transition_key \
		and str((raw_transition as Dictionary).get("source", "")) \
			== "legacy_story_send" \
		and str((raw_transition as Dictionary).get("from", "")) \
			== "not_submitted" \
		and str((raw_transition as Dictionary).get("to", "")) \
			== "submitted" \
		and bool(GameState.flags.get("story_job_unlocked", false)) \
		and bool(GameState.flags.get(
			"opening_interview_application_sent", false)) \
		and bool(GameState.flags.get(
			"opening_preplan_application_sent", false)) \
		and not GameState.has_pending_weekly_commitment(int(GameState.turn)) \
		and not GameState.has_weekly_commitment_for_turn(int(GameState.turn)) \
		and not state["action_receipts"].has(W1_ONBOARDING_BUNDLE_ID)
	if not valid:
		GameState.call("_restore_serialized_snapshot_exact", snapshot)
		return false
	return true

static func _claim_preplan_opening(source: String) -> bool:
	var state := _normalized_state(GameState.core_loop_v2_state)
	if not _preplan_opening_base_available(state) \
			or not str(state.get("active_bundle", "")).is_empty():
		return false
	var trigger := _preplan_opening_trigger()
	var application_id := str(trigger.get(
		"application_id", "")).strip_edges()
	var submitted_status := str(trigger.get("status", "")).strip_edges()
	if application_id.is_empty() or submitted_status != "submitted":
		return false
	var current_status := application_status(application_id)
	if (not bool(GameState.flags.get(
			"opening_interview_application_sent", false)) \
			and current_status != submitted_status) \
			or (not current_status.is_empty() \
			and current_status != submitted_status):
		return false
	# Recovery is allowed only after a durable, actually submitted application.
	# Old saves that merely opened the job app keep their Month-One planner and
	# may submit the legacy application there; never invent a click on load.
	if not GameState.flags.has("opening_interview_application_turn"):
		GameState.flags["opening_interview_application_turn"] = int(GameState.turn)
	state["application_statuses"][application_id] = submitted_status
	state["active_bundle"] = OPENING_INTERVIEW_BUNDLE_ID
	state["active_kind"] = "consequence"
	state["active_turn"] = int(GameState.turn)
	state["action_result_ready"] = false
	var roots := resolved_event_roots(OPENING_INTERVIEW_BUNDLE_ID)
	var receipt := {
		"consequence_id": OPENING_INTERVIEW_BUNDLE_ID,
		"scheduled_bundle": "",
		"turn": int(GameState.turn),
		"status": "presented",
		"surface_kind": (
			"preplan_continuous" if source == "story_choice" \
			else "preplan_recovery"),
		"roots": roots.duplicate(),
		"presented_turn": int(GameState.turn),
		"consumed_turn": 0,
		"legacy_separate_owner": false,
		"claim_source": source,
	}
	state["consequence_receipts"][OPENING_INTERVIEW_BUNDLE_ID] = receipt
	if not state["shown_consequences"].has(OPENING_INTERVIEW_BUNDLE_ID):
		state["shown_consequences"].append(OPENING_INTERVIEW_BUNDLE_ID)
	state["shown_consequence_turns"][OPENING_INTERVIEW_BUNDLE_ID] = int(
		GameState.turn)
	GameState.core_loop_v2_state = state
	prepare_story_bundle(OPENING_INTERVIEW_BUNDLE_ID)
	return true

## 월간 계획을 열기 전에 반드시 도착해야 하는 비슬롯 장면을 반환한다.
## 표시 여부는 조건식이 아니라 영구 consequence receipt가 소유하므로,
## 저장 뒤 다시 들어와도 같은 전화나 메시지가 두 번 재생되지 않는다.
static func pending_month_prelude(month_index: int = -1) -> String:
	var target_month := (
		month_index if month_index > 0 else month_for_turn(GameState.turn))
	var state := _normalized_state(GameState.core_loop_v2_state)
	for raw_id in month_spec(target_month).get("prelude", []):
		var prelude_id := str(raw_id).strip_edges()
		if prelude_id.is_empty() \
				or state["shown_consequences"].has(prelude_id) \
				or state["consequence_receipts"].has(prelude_id):
			continue
		var prelude_spec := bundle(prelude_id)
		if prelude_spec.is_empty() \
				or not bundle_allowed_in_week(prelude_id, int(GameState.turn)) \
				or not _bundle_requirement_met(
					prelude_spec, int(GameState.turn) + 1):
			continue
		return prelude_id
	return ""

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
	if plan_uses_seoul_cycle(plan):
		# The board nodes own livelihood, growth, care, and recovery directly.
		# Returning legacy defaults here would make the invisible +KRW 280K/+16
		# mental Month-One baseline survive beneath the player's four allocations.
		return {}
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
			"suppressed": bool(prior.get("suppressed", false)),
			"receipt": prior.duplicate(true),
		}
	var month_index := month_for_turn(target_turn)
	var plan := plan_for_month(month_index)
	if plan.is_empty():
		return {"ok": false, "error": "missing_plan"}
	if plan_uses_seoul_cycle(plan):
		var raw_cycle_routines: Variant = seoul_cycle_spec().get(
			"background_routines", {})
		if not raw_cycle_routines is Dictionary \
				or str((raw_cycle_routines as Dictionary).get(
					"policy", "")) != "absorbed_by_nodes" \
				or bool((raw_cycle_routines as Dictionary).get(
					"automatic_effects", true)) \
				or not bool((raw_cycle_routines as Dictionary).get(
					"durable_suppressed_receipt", false)):
			return {"ok": false, "error": "invalid_cycle_routine_contract"}
		var suppressed_receipt := {
			"turn": target_turn,
			"month": month_index,
			"planning_mode": SEOUL_CYCLE_MODE,
			"status": "suppressed",
			"suppressed": true,
			"suppression_policy": "absorbed_by_nodes",
			"primary": "",
			"secondary": "",
			"planned_primary": "",
			"planned_secondary": "",
			"employment_forced": false,
			"units": [],
			"effects": {},
		}
		state["routine_receipts"][turn_key] = suppressed_receipt.duplicate(true)
		GameState.core_loop_v2_state = state
		return {
			"ok": true,
			"applied": false,
			"suppressed": true,
			"receipt": suppressed_receipt,
		}
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
	var cycle_summary: Dictionary = {}
	if plan_uses_seoul_cycle(plan):
		cycle_summary = _seoul_cycle_month_summary_payload(
			state, month_index)
		kept = (cycle_summary.get("kept", []) as Array).duplicate(true)
	else:
		for raw_week in schedule:
			var week := int(raw_week)
			if completed_turns.has(week):
				kept.append({
					"week": week,
					"bundle_id": str(schedule[raw_week]),
				})
	var summary := {
		"month": month_index,
		"planning_mode": str(plan.get("planning_mode", "legacy_monthly_plan")),
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
	if not cycle_summary.is_empty():
		for cycle_key in [
			"allocation_receipts", "node_states", "expired_nodes",
			"expiry_receipts",
			"cycle_completed_turns", "world_clock",
			"trigger_receipts", "world_receipts",
		]:
			summary[cycle_key] = cycle_summary.get(cycle_key).duplicate(true) \
				if cycle_summary.get(cycle_key) is Dictionary \
					or cycle_summary.get(cycle_key) is Array \
				else cycle_summary.get(cycle_key)
	for raw_key in extra:
		summary[str(raw_key)] = extra[raw_key]
	# The closing balance remains untouched. This receipt gives the notebook a
	# non-negative, display-safe amount for unpaid cash obligations.
	summary["cash_shortfall"] = cash_shortfall_for_money(
		float(after.get("money", 0.0)))
	state["month_summaries"][month_key] = summary
	GameState.core_loop_v2_state = state
	return summary.duplicate(true)

static func _seoul_cycle_month_summary_payload(
		state: Dictionary, month_index: int) -> Dictionary:
	var cycle: Dictionary = state.get(SEOUL_CYCLE_STATE_KEY, {})
	if cycle.is_empty() or int(cycle.get("month", 0)) != month_index:
		return {}
	var first_turn := ((month_index - 1) * 4) + 1
	var last_turn := first_turn + 3
	var allocation_receipts: Array = []
	var kept: Array = []
	var nodes: Dictionary = cycle.get("nodes", {})
	for turn in range(first_turn, last_turn + 1):
		var raw_receipt: Variant = (
			cycle.get("allocation_receipts", {}) as Dictionary).get(
				str(turn), {})
		if not raw_receipt is Dictionary \
				or (raw_receipt as Dictionary).is_empty():
			continue
		var receipt: Dictionary = (raw_receipt as Dictionary).duplicate(true)
		allocation_receipts.append(receipt)
		var node_id := str(receipt.get("node_id", ""))
		var raw_node: Variant = nodes.get(node_id, {})
		var summary_bundle := ""
		if raw_node is Dictionary:
			summary_bundle = str((raw_node as Dictionary).get(
				"summary_bundle", (raw_node as Dictionary).get(
					"trigger_bundle", ""))).strip_edges()
		kept.append({
			"week": turn,
			"bundle_id": summary_bundle,
			"node_id": node_id,
			"capacity_id": str(receipt.get("capacity_id", "")),
			"capacity_value": int(receipt.get("capacity_value", 0)),
			"progress_gain": int(receipt.get("progress_gain", 0)),
			"completed_now": bool(receipt.get("completed_now", false)),
			"repeat_allocation": bool(receipt.get(
				"repeat_allocation", false)),
			"fallback_allocation": bool(receipt.get(
				"fallback_allocation", false)),
		})
	var node_states: Dictionary = {}
	for raw_node_id in nodes:
		var node_id := str(raw_node_id)
		var raw_node: Variant = nodes.get(raw_node_id, {})
		if not raw_node is Dictionary:
			continue
		var node: Dictionary = raw_node
		var node_state := {
			"id": node_id,
			"owner": str(node.get("owner", "")),
			"place": str(node.get("place", "")),
			"summary_bundle": str(node.get("summary_bundle", "")),
			"label_ko": str(node.get("label_ko", "")),
			"label_en": str(node.get("label_en", "")),
			"progress": int(node.get("progress", 0)),
			"threshold": int(node.get("threshold", 1)),
			"status": str(node.get("status", "open")),
			"deadline_week": int(node.get("deadline_week", 4)),
			"completed_turn": int(node.get("completed_turn", 0)),
			"last_allocation_turn": int(node.get("last_allocation_turn", 0)),
			"expired_turn": int(node.get("expired_turn", 0)),
			"featured_status": str(node.get("featured_status", "")),
			"missed_trigger_bundle": str(node.get(
				"missed_trigger_bundle", "")),
			"fallback_mode": bool(node.get("fallback_mode", false)),
		}
		node_states[node_id] = node_state
	return {
		"kept": kept,
		"allocation_receipts": allocation_receipts,
		"node_states": node_states,
		"expired_nodes": (cycle.get("expired_nodes", []) as Array).duplicate(),
		"expiry_receipts": (
			cycle.get("expiry_receipts", {}) as Dictionary).duplicate(true),
		"cycle_completed_turns": (
			cycle.get("completed_turns", []) as Array).duplicate(),
		"world_clock": int(cycle.get("world_clock", 0)),
		"trigger_receipts": (
			cycle.get("trigger_receipts", {}) as Dictionary).duplicate(true),
		"world_receipts": (
			cycle.get("world_receipts", {}) as Dictionary).duplicate(true),
	}

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
	# A new foreground owner can never inherit another task's unfinished local
	# choices. Same-owner re-entry returned above and preserves its session.
	state["activity_task_session"] = {}
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

## ORDER-92 keeps the monthly promise as the sole calendar decision, then
## gives eligible practical promises one small, resumable task. This query
## validates the generic N-of-(N+1) contract without retaining localized copy
## or scene controls in the save.
static func activity_task_config(bundle_id: String = "") -> Dictionary:
	var target_id := bundle_id.strip_edges()
	if target_id.is_empty():
		target_id = active_bundle_id().strip_edges()
	if target_id.is_empty():
		return {}
	var scene_bundle := bundle(target_id)
	var raw_config: Variant = scene_bundle.get("action_config", {})
	if not raw_config is Dictionary:
		return {}
	var config := _normalized_activity_task_config(raw_config as Dictionary)
	if config.is_empty():
		return {}
	config["bundle_id"] = target_id
	config["action_id"] = str(
		scene_bundle.get("action_id", "")).strip_edges().to_lower()
	return config

## Begin a fresh task only for the current schedule owner. Calling this again
## for the same bundle and turn returns the durable session instead of
## resetting its chosen order. No effects or weekly commitment are finalized
## here.
static func begin_or_resume_activity_task(
		bundle_id: String = "") -> Dictionary:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var target_id := bundle_id.strip_edges()
	if target_id.is_empty():
		target_id = str(state.get("active_bundle", "")).strip_edges()
	if target_id.is_empty() \
			or str(state.get("active_bundle", "")) != target_id \
			or str(state.get("active_kind", "")) != "schedule" \
			or int(state.get("active_turn", 0)) != int(GameState.turn):
		return {"ok": false, "error": "activity_task_owner_mismatch"}
	var config: Dictionary = activity_task_config(target_id)
	if config.is_empty():
		return {"ok": false, "error": "invalid_activity_task_config"}
	var raw_receipt: Variant = state["action_receipts"].get(target_id, {})
	if raw_receipt is Dictionary \
			and int((raw_receipt as Dictionary).get(
				"turn", -1)) == int(GameState.turn):
		state["activity_task_session"] = {}
		GameState.core_loop_v2_state = state
		return {"ok": false, "error": "activity_task_already_finalized"}
	var raw_session: Variant = state.get("activity_task_session", {})
	if raw_session is Dictionary and not (raw_session as Dictionary).is_empty():
		var session: Dictionary = raw_session
		if str(session.get("bundle_id", "")) != target_id \
				or int(session.get("turn", -1)) != int(GameState.turn) \
				or str(session.get("task_id", "")) \
					!= str(config.get("task_id", "")):
			return {"ok": false, "error": "activity_task_session_mismatch"}
		GameState.core_loop_v2_state = state
		return {
			"ok": true,
			"resumed": true,
			"session": session.duplicate(true),
			"config": config.duplicate(true),
		}
	var session := {
		"schema": ACTIVITY_TASK_SESSION_SCHEMA,
		"bundle_id": target_id,
		"turn": int(GameState.turn),
		"task_id": str(config.get("task_id", "")),
		"phase": "selecting",
		"normal_steps": int(config.get("normal_steps", 0)),
		"selected_requirements": [],
		"remaining_steps": int(config.get("normal_steps", 0)),
	}
	state["activity_task_session"] = session
	GameState.core_loop_v2_state = state
	return {
		"ok": true,
		"resumed": false,
		"session": session.duplicate(true),
		"config": config.duplicate(true),
	}

static func activity_task_session() -> Dictionary:
	var state := _normalized_state(GameState.core_loop_v2_state)
	GameState.core_loop_v2_state = state
	var raw_session: Variant = state.get("activity_task_session", {})
	return (raw_session as Dictionary).duplicate(true) \
		if raw_session is Dictionary else {}

## Replace the current ordered selection. This gives controller Back a safe
## way to undo or reorder before resolution while rejecting duplicates and
## unknown requirements. The remaining-count UI derives from normal_steps
## minus this array size; it is not another persistent resource.
static func update_activity_task_requirements(
		selected_requirements: Array) -> Dictionary:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var raw_session: Variant = state.get("activity_task_session", {})
	if not raw_session is Dictionary or (raw_session as Dictionary).is_empty():
		return {"ok": false, "error": "missing_activity_task_session"}
	var session: Dictionary = raw_session
	if str(session.get("phase", "")) != "selecting":
		return {"ok": false, "error": "activity_task_already_resolved"}
	var config: Dictionary = activity_task_config(
		str(session.get("bundle_id", "")))
	if config.is_empty():
		return {"ok": false, "error": "invalid_activity_task_config"}
	var normal_steps := int(config.get("normal_steps", 0))
	if selected_requirements.size() > normal_steps:
		return {"ok": false, "error": "activity_task_normal_steps_exceeded"}
	var requirement_ids: Array = config.get("requirement_ids", [])
	var normalized := _activity_task_requirement_ids(
		selected_requirements, requirement_ids)
	if normalized.size() != selected_requirements.size():
		return {"ok": false, "error": "invalid_activity_task_requirements"}
	session["selected_requirements"] = normalized
	session["remaining_steps"] = normal_steps - normalized.size()
	state["activity_task_session"] = session
	GameState.core_loop_v2_state = state
	return {
		"ok": true,
		"remaining_steps": normal_steps - normalized.size(),
		"session": session.duplicate(true),
	}

static func select_activity_task_requirement(
		requirement_id: String) -> Dictionary:
	var session := activity_task_session()
	if session.is_empty():
		return {"ok": false, "error": "missing_activity_task_session"}
	var normalized_id := requirement_id.strip_edges()
	var selected: Array = (
		(session.get("selected_requirements", []) as Array).duplicate()
		if session.get("selected_requirements", []) is Array else []
	)
	if normalized_id.is_empty() or selected.has(normalized_id):
		return {"ok": false, "error": "duplicate_activity_task_requirement"}
	selected.append(normalized_id)
	return update_activity_task_requirements(selected)

## Resolve the chosen two requirements, or append the one remaining
## requirement through the explicitly priced overreach. Resolution remains
## effect-free and durable until GameState finalizes the weekly transaction.
static func resolve_activity_task(overreach: bool = false) -> Dictionary:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var raw_session: Variant = state.get("activity_task_session", {})
	if not raw_session is Dictionary or (raw_session as Dictionary).is_empty():
		return {"ok": false, "error": "missing_activity_task_session"}
	var session: Dictionary = raw_session
	if str(session.get("phase", "")) == "resolved":
		var raw_resolution: Variant = session.get("resolution", {})
		if raw_resolution is Dictionary \
				and bool((raw_resolution as Dictionary).get(
					"overreached", false)) == overreach:
			return (raw_resolution as Dictionary).duplicate(true)
		return {"ok": false, "error": "activity_task_already_resolved"}
	if str(session.get("phase", "")) != "selecting":
		return {"ok": false, "error": "invalid_activity_task_phase"}
	var config: Dictionary = activity_task_config(
		str(session.get("bundle_id", "")))
	if config.is_empty():
		return {"ok": false, "error": "invalid_activity_task_config"}
	var selected: Array = (
		(session.get("selected_requirements", []) as Array).duplicate()
		if session.get("selected_requirements", []) is Array else []
	)
	var resolution := _activity_task_resolution(config, selected, overreach)
	if not bool(resolution.get("ok", false)):
		return resolution
	session["phase"] = "resolved"
	session["selected_requirements"] = (
		resolution.get("selected_requirements", []) as Array
	).duplicate()
	session["outcome_id"] = str(resolution.get("outcome_id", ""))
	session["overreached"] = bool(resolution.get("overreached", false))
	session["remaining_steps"] = 0
	session["resolution"] = resolution.duplicate(true)
	state["activity_task_session"] = session
	GameState.core_loop_v2_state = state
	return resolution

## Public cancellation is intentionally narrower than cancel_active_bundle:
## the caller may discard a task session before the weekly transaction, while
## the calendar owner and its armed commitment remain under MainGame control.
static func clear_activity_task_session() -> bool:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var raw_session: Variant = state.get("activity_task_session", {})
	if not raw_session is Dictionary or (raw_session as Dictionary).is_empty():
		return false
	state["activity_task_session"] = {}
	GameState.core_loop_v2_state = state
	return true

## StoryMode readers receive only the single finalized outcome receipt, never
## the transient clicks that led to it.
static func activity_task_receipt(bundle_id: String) -> Dictionary:
	var target_id := bundle_id.strip_edges()
	if target_id.is_empty():
		return {}
	var receipt := action_receipt(target_id)
	if receipt.is_empty():
		return {}
	var raw_details: Variant = receipt.get("result_details", {})
	if not raw_details is Dictionary:
		return {}
	var details: Dictionary = raw_details as Dictionary
	# Before ORDER-92 this promise finalized the same -4/-3 baseline as a
	# one-click `instant_effect`. Preserve that historical receipt byte-for-byte,
	# but project it onto the explicitly declared equivalent outcome when new
	# story copy asks what work was done.
	if str(details.get("execution", "")) == "instant_effect":
		return _legacy_instant_activity_task_receipt(
			target_id, receipt, details)
	# Read against the config snapshot finalized with the receipt. A later
	# content rebalance must not rewrite which requirements an old save handled.
	var raw_config: Variant = receipt.get("config", {})
	if not raw_config is Dictionary:
		return {}
	var config := _normalized_activity_task_config(raw_config as Dictionary)
	if config.is_empty():
		return {}
	var result := _validated_activity_task_result(
		config, details)
	if result.is_empty():
		return {}
	result["bundle_id"] = target_id
	result["action_id"] = str(receipt.get("action_id", ""))
	result["turn"] = int(receipt.get("turn", 0))
	return result

static func _legacy_instant_activity_task_receipt(
		bundle_id: String, receipt: Dictionary,
		details: Dictionary) -> Dictionary:
	var config: Dictionary = activity_task_config(bundle_id)
	if config.is_empty():
		return {}
	var raw_legacy: Variant = config.get("legacy_instant_effect", {})
	if not raw_legacy is Dictionary:
		return {}
	var legacy: Dictionary = raw_legacy as Dictionary
	var outcome_id := str(legacy.get("outcome_id", "")).strip_edges()
	var selected: Array = (
		(legacy.get("requirements", []) as Array).duplicate()
		if legacy.get("requirements", []) is Array else []
	)
	var expected_effects: Dictionary = (
		(legacy.get("effects", {}) as Dictionary).duplicate(true)
		if legacy.get("effects", {}) is Dictionary else {}
	)
	if outcome_id.is_empty() or expected_effects.is_empty():
		return {}
	var raw_snapshot: Variant = receipt.get("config", {})
	if not raw_snapshot is Dictionary:
		return {}
	var snapshot: Dictionary = raw_snapshot as Dictionary
	var snapshot_effects: Dictionary = (
		(snapshot.get("effects", {}) as Dictionary).duplicate(true)
		if snapshot.get("effects", {}) is Dictionary else {}
	)
	if str(snapshot.get("execution", "")) != "instant_effect" \
			or snapshot_effects.is_empty() \
			or snapshot_effects != expected_effects:
		return {}
	var legacy_effects: Dictionary = details.get("effects", {}) \
		if details.get("effects", {}) is Dictionary else {}
	if legacy_effects.is_empty() and receipt.get("outcome", {}) is Dictionary:
		var public_outcome: Dictionary = receipt.get("outcome", {})
		for effect_key in expected_effects:
			if public_outcome.has(effect_key):
				legacy_effects[effect_key] = public_outcome[effect_key]
	if legacy_effects != snapshot_effects:
		return {}
	var skipped: Array = []
	for requirement_id in config.get("requirement_ids", []) as Array:
		if not selected.has(requirement_id):
			skipped.append(requirement_id)
	var resolution := {
		"ok": true,
		"execution": "activity_task",
		"task_id": str(config.get("task_id", "")),
		"outcome_id": outcome_id,
		"selected_requirements": selected,
		"skipped_requirements": skipped,
		"overreached": false,
		"effects": snapshot_effects,
		"axis": str(details.get(
			"axis", snapshot.get("axis", config.get("axis", "")))),
		"place_id": str(details.get(
			"place_id", snapshot.get("place_id", config.get("place_id", "")))),
	}
	resolution["bundle_id"] = bundle_id
	resolution["action_id"] = str(receipt.get("action_id", ""))
	resolution["turn"] = int(receipt.get("turn", 0))
	resolution["legacy_execution"] = "instant_effect"
	return resolution

static func activity_task_receipt_has_requirement(
		bundle_id: String, requirement_id: String) -> bool:
	var result := activity_task_receipt(bundle_id)
	var normalized_id := requirement_id.strip_edges()
	return not normalized_id.is_empty() \
		and result.get("selected_requirements", []) is Array \
		and (result.get("selected_requirements", []) as Array).has(
			normalized_id)

static func activity_task_receipt_outcome_id(bundle_id: String) -> String:
	return str(activity_task_receipt(bundle_id).get("outcome_id", ""))

static func _normalized_activity_task_config(
		raw_config: Dictionary) -> Dictionary:
	var config := raw_config.duplicate(true)
	if str(config.get("execution", "")).strip_edges() != "activity_task":
		return {}
	var task_id := str(config.get("task_id", "")).strip_edges()
	var axis := str(config.get("axis", "")).strip_edges().to_lower()
	var place_id := str(config.get("place_id", "")).strip_edges()
	var raw_requirements: Variant = config.get("requirements", [])
	if task_id.is_empty() or axis not in ["money", "human"] \
			or place_id.is_empty() or not raw_requirements is Array:
		return {}
	var requirement_ids := _activity_task_requirement_ids(raw_requirements)
	if requirement_ids.size() != (raw_requirements as Array).size():
		return {}
	var normal_steps := int(config.get("normal_steps", 0))
	if normal_steps < 1 or requirement_ids.size() != normal_steps + 1:
		return {}

	var raw_outcomes: Variant = config.get("outcomes", {})
	if not raw_outcomes is Dictionary:
		return {}
	var normalized_outcomes: Dictionary = {}
	var seen_signatures: Dictionary = {}
	for raw_outcome_id in raw_outcomes as Dictionary:
		var outcome_id := str(raw_outcome_id).strip_edges()
		var raw_outcome: Variant = (raw_outcomes as Dictionary).get(
			raw_outcome_id, {})
		if outcome_id.is_empty() or not raw_outcome is Dictionary:
			return {}
		var outcome: Dictionary = (raw_outcome as Dictionary).duplicate(true)
		var declared_id := str(
			outcome.get("outcome_id", outcome_id)).strip_edges()
		var outcome_requirements := _activity_task_requirement_ids(
			outcome.get("requirements", []), requirement_ids, normal_steps)
		var raw_effects: Variant = outcome.get("effects", {})
		if declared_id != outcome_id \
				or outcome_requirements.size() != normal_steps \
				or not raw_effects is Dictionary:
			return {}
		var signature := _activity_task_requirement_signature(
			outcome_requirements)
		if seen_signatures.has(signature):
			return {}
		seen_signatures[signature] = true
		outcome["outcome_id"] = outcome_id
		outcome["requirements"] = outcome_requirements
		outcome["effects"] = (raw_effects as Dictionary).duplicate(true)
		normalized_outcomes[outcome_id] = outcome
	if normalized_outcomes.size() != requirement_ids.size():
		return {}
	for skipped_id in requirement_ids:
		var expected_pair := requirement_ids.duplicate()
		expected_pair.erase(skipped_id)
		if not seen_signatures.has(
				_activity_task_requirement_signature(expected_pair)):
			return {}

	var raw_overreach: Variant = config.get("overreach", {})
	if not raw_overreach is Dictionary:
		return {}
	var overreach: Dictionary = (raw_overreach as Dictionary).duplicate(true)
	var overreach_id := str(overreach.get("outcome_id", "")).strip_edges()
	var overreach_requirements := _activity_task_requirement_ids(
		overreach.get("requirements", []), requirement_ids,
		requirement_ids.size())
	var raw_overreach_effects: Variant = overreach.get("effects", {})
	if overreach_id.is_empty() or normalized_outcomes.has(overreach_id) \
			or overreach_requirements.size() != requirement_ids.size() \
			or _activity_task_requirement_signature(overreach_requirements) \
				!= _activity_task_requirement_signature(requirement_ids) \
			or not raw_overreach_effects is Dictionary:
		return {}
	overreach["outcome_id"] = overreach_id
	overreach["requirements"] = overreach_requirements
	overreach["effects"] = (
		raw_overreach_effects as Dictionary).duplicate(true)

	# Old saves finalized this promise before the task surface existed. Their
	# prose proved only one recount and a discrepancy mark, so keep that
	# evidence in a separate reader outcome instead of inventing a modern pair.
	var legacy: Dictionary = {}
	if config.has("legacy_instant_effect"):
		var raw_legacy: Variant = config.get("legacy_instant_effect", {})
		if not raw_legacy is Dictionary:
			return {}
		legacy = (raw_legacy as Dictionary).duplicate(true)
		var legacy_id := str(legacy.get("outcome_id", "")).strip_edges()
		var raw_legacy_requirements: Variant = legacy.get("requirements", [])
		if not raw_legacy_requirements is Array:
			return {}
		var legacy_requirements := _activity_task_requirement_ids(
			raw_legacy_requirements, requirement_ids)
		var raw_legacy_effects: Variant = legacy.get("effects", {})
		if legacy_id.is_empty() or normalized_outcomes.has(legacy_id) \
				or legacy_id == overreach_id \
				or legacy_requirements.size() \
					!= (raw_legacy_requirements as Array).size() \
				or legacy_requirements.size() > normal_steps \
				or not raw_legacy_effects is Dictionary \
				or (raw_legacy_effects as Dictionary).is_empty():
			return {}
		legacy["outcome_id"] = legacy_id
		legacy["requirements"] = legacy_requirements
		legacy["effects"] = (raw_legacy_effects as Dictionary).duplicate(true)

	config["task_id"] = task_id
	config["axis"] = axis
	config["place_id"] = place_id
	config["normal_steps"] = normal_steps
	config["requirement_ids"] = requirement_ids
	config["outcomes"] = normalized_outcomes
	config["overreach"] = overreach
	if legacy.is_empty():
		config.erase("legacy_instant_effect")
	else:
		config["legacy_instant_effect"] = legacy
	return config

static func _activity_task_requirement_ids(
		raw_requirements: Variant, allowed_ids: Array = [],
		expected_count: int = -1) -> Array:
	if not raw_requirements is Array:
		return []
	var result: Array = []
	for raw_requirement in raw_requirements as Array:
		var requirement_id := ""
		if raw_requirement is Dictionary:
			requirement_id = str((raw_requirement as Dictionary).get(
				"id", "")).strip_edges()
		else:
			requirement_id = str(raw_requirement).strip_edges()
		if requirement_id.is_empty() or result.has(requirement_id) \
				or (not allowed_ids.is_empty() \
					and not allowed_ids.has(requirement_id)):
			return []
		result.append(requirement_id)
	if expected_count >= 0 and result.size() != expected_count:
		return []
	return result

static func _activity_task_requirement_signature(
		requirement_ids: Array) -> String:
	var ordered: Array[String] = []
	for raw_id in requirement_ids:
		ordered.append(str(raw_id))
	ordered.sort()
	return "|".join(ordered)

static func _activity_task_resolution(
		config: Dictionary, selected_requirements: Array,
		overreach: bool) -> Dictionary:
	var normal_steps := int(config.get("normal_steps", 0))
	var requirement_ids: Array = config.get("requirement_ids", [])
	var selected := _activity_task_requirement_ids(
		selected_requirements, requirement_ids, normal_steps)
	if selected.size() != normal_steps:
		return {"ok": false, "error": "activity_task_requires_normal_steps"}
	var outcome: Dictionary = {}
	var final_selected := selected.duplicate()
	if overreach:
		var raw_overreach: Variant = config.get("overreach", {})
		if not raw_overreach is Dictionary:
			return {"ok": false, "error": "missing_activity_task_overreach"}
		outcome = (raw_overreach as Dictionary).duplicate(true)
		for raw_id in outcome.get("requirements", []):
			var requirement_id := str(raw_id)
			if not final_selected.has(requirement_id):
				final_selected.append(requirement_id)
	else:
		var signature := _activity_task_requirement_signature(selected)
		for raw_outcome in (config.get("outcomes", {}) as Dictionary).values():
			if not raw_outcome is Dictionary:
				continue
			if _activity_task_requirement_signature(
					(raw_outcome as Dictionary).get(
						"requirements", []) as Array) == signature:
				outcome = (raw_outcome as Dictionary).duplicate(true)
				break
	if outcome.is_empty():
		return {"ok": false, "error": "missing_activity_task_outcome"}
	var skipped: Array = []
	for requirement_id in requirement_ids:
		if not final_selected.has(requirement_id):
			skipped.append(requirement_id)
	return {
		"ok": true,
		"execution": "activity_task",
		"task_id": str(config.get("task_id", "")),
		"outcome_id": str(outcome.get("outcome_id", "")),
		"selected_requirements": final_selected,
		"skipped_requirements": skipped,
		"overreached": overreach,
		"effects": (
			(outcome.get("effects", {}) as Dictionary).duplicate(true)
			if outcome.get("effects", {}) is Dictionary else {}
		),
		"axis": str(config.get("axis", "")),
		"place_id": str(config.get("place_id", "")),
	}

static func _validated_activity_task_result(
		config: Dictionary, raw_result: Dictionary) -> Dictionary:
	if str(raw_result.get("execution", "")) != "activity_task" \
			or str(raw_result.get("task_id", "")) \
				!= str(config.get("task_id", "")):
		return {}
	var overreached := bool(raw_result.get("overreached", false))
	var raw_selected: Variant = raw_result.get("selected_requirements", [])
	if not raw_selected is Array:
		return {}
	var selected: Array = (raw_selected as Array).duplicate()
	var normal_steps := int(config.get("normal_steps", 0))
	var base_selection: Array = selected.slice(0, normal_steps) \
		if overreached else selected
	var expected := _activity_task_resolution(
		config, base_selection, overreached)
	if not bool(expected.get("ok", false)) \
			or selected != expected.get("selected_requirements", []) \
			or str(raw_result.get("outcome_id", "")) \
				!= str(expected.get("outcome_id", "")) \
			or raw_result.get("skipped_requirements", []) \
				!= expected.get("skipped_requirements", []) \
			or raw_result.get("effects", {}) != expected.get("effects", {}) \
			or str(raw_result.get("axis", "")) \
				!= str(expected.get("axis", "")) \
			or str(raw_result.get("place_id", "")) \
				!= str(expected.get("place_id", "")):
		return {}
	return expected

static func _normalized_activity_task_session(
		raw_session: Variant, state: Dictionary) -> Dictionary:
	if not raw_session is Dictionary or (raw_session as Dictionary).is_empty():
		return {}
	var session: Dictionary = raw_session
	var bundle_id := str(session.get("bundle_id", "")).strip_edges()
	var session_turn := int(session.get("turn", 0))
	if int(session.get("schema", 0)) != ACTIVITY_TASK_SESSION_SCHEMA \
			or bundle_id.is_empty() \
			or str(state.get("active_bundle", "")) != bundle_id \
			or str(state.get("active_kind", "")) != "schedule" \
			or int(state.get("active_turn", 0)) != session_turn \
			or session_turn != int(GameState.turn):
		return {}
	var config: Dictionary = activity_task_config(bundle_id)
	if config.is_empty() or str(session.get("task_id", "")) \
			!= str(config.get("task_id", "")):
		return {}
	var phase := str(session.get("phase", ""))
	var raw_selected: Variant = session.get("selected_requirements", [])
	if not raw_selected is Array:
		return {}
	var selected := _activity_task_requirement_ids(
		raw_selected, config.get("requirement_ids", []) as Array)
	if selected.size() != (raw_selected as Array).size():
		return {}
	var normalized := {
		"schema": ACTIVITY_TASK_SESSION_SCHEMA,
		"bundle_id": bundle_id,
		"turn": session_turn,
		"task_id": str(config.get("task_id", "")),
		"phase": phase,
		"normal_steps": int(config.get("normal_steps", 0)),
		"selected_requirements": selected,
		"remaining_steps": maxi(
			0, int(config.get("normal_steps", 0)) - selected.size()),
	}
	if phase == "selecting":
		if selected.size() > int(config.get("normal_steps", 0)):
			return {}
		return normalized
	if phase != "resolved":
		return {}
	var overreached := bool(session.get("overreached", false))
	var normal_steps := int(config.get("normal_steps", 0))
	var base_selection: Array = selected.slice(0, normal_steps) \
		if overreached else selected
	var resolution := _activity_task_resolution(
		config, base_selection, overreached)
	if not bool(resolution.get("ok", false)) \
			or selected != resolution.get("selected_requirements", []) \
			or str(session.get("outcome_id", "")) \
				!= str(resolution.get("outcome_id", "")):
		return {}
	normalized["outcome_id"] = str(resolution.get("outcome_id", ""))
	normalized["overreached"] = overreached
	normalized["remaining_steps"] = 0
	normalized["resolution"] = resolution
	return normalized

static func _clear_activity_task_session_for_owner(
		state: Dictionary, bundle_id: String, turn: int) -> void:
	var raw_session: Variant = state.get("activity_task_session", {})
	if not raw_session is Dictionary:
		state["activity_task_session"] = {}
		return
	var session: Dictionary = raw_session
	if session.is_empty() \
			or (str(session.get("bundle_id", "")) == bundle_id \
				and int(session.get("turn", -1)) == turn):
		state["activity_task_session"] = {}

## Most action+story bundles keep the atomic result card before their authored
## beat. Only an explicit data contract lets the story own that presentation.
## This query is intentionally side-effect free so routing and save recovery
## can ask the same question without acknowledging or completing anything.
static func story_owns_action_result(bundle_id: String = "") -> bool:
	var target_id := bundle_id.strip_edges()
	if target_id.is_empty():
		target_id = active_bundle_id().strip_edges()
	if target_id.is_empty():
		return false
	var scene_bundle := bundle(target_id)
	var roots: Variant = scene_bundle.get("existing_roots", [])
	return str(scene_bundle.get(
		"action_result_presentation", "")).strip_edges() == "story_owned" \
		and not str(scene_bundle.get("action_id", "")).strip_edges().is_empty() \
		and roots is Array and not (roots as Array).is_empty()

## A dual-surface schedule keeps the existing atomic action as its gameplay
## owner, then opens an authored story beat after the action result is
## acknowledged. The stage is durable so MainGame can resume without
## reapplying the action or skipping the story after a save/load boundary.
static func action_story_stage(bundle_id: String = "") -> String:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var target_id := bundle_id.strip_edges()
	if target_id.is_empty():
		target_id = str(state.get("active_bundle", "")).strip_edges()
	if target_id.is_empty() \
			or str(state.get("active_bundle", "")) != target_id \
			or str(state.get("active_kind", "")) != "schedule" \
			or int(state.get("active_turn", 0)) != int(GameState.turn):
		return ""
	var scene_bundle := bundle(target_id)
	if not _is_action_story_bundle(scene_bundle):
		return ""
	var raw_action_receipt: Variant = state["action_receipts"].get(
		target_id, {})
	if not raw_action_receipt is Dictionary \
			or int((raw_action_receipt as Dictionary).get(
				"turn", -1)) != int(GameState.turn) \
			or str((raw_action_receipt as Dictionary).get(
				"action_id", "")).strip_edges().to_lower() \
				!= str(scene_bundle.get(
					"action_id", "")).strip_edges().to_lower():
		return "action"
	if _has_current_action_story_acknowledgement(state, target_id) \
			and _has_current_bundle_story_receipt(state, target_id):
		return "complete"
	return "story"

## Result acknowledgement is separate from action execution. Clearing only
## this presentation flag lets a resumed MainGame route into the authored
## story beat while the durable action receipt prevents a second effect pass.
static func acknowledge_action_story_result(
		bundle_id: String = "") -> bool:
	var target_id := bundle_id.strip_edges()
	var state := _normalized_state(GameState.core_loop_v2_state)
	if target_id.is_empty():
		target_id = str(state.get("active_bundle", "")).strip_edges()
	if action_story_stage(target_id) != "story":
		return false
	state = _normalized_state(GameState.core_loop_v2_state)
	state["action_story_acknowledgements"][target_id] = {
		"bundle_id": target_id,
		"action_id": str(bundle(target_id).get("action_id", "")),
		"turn": int(GameState.turn),
		"status": "acknowledged",
	}
	state["action_result_ready"] = false
	GameState.core_loop_v2_state = state
	return true

## A saved result screen is presentation state, not permission to execute the
## action again. Return the durable receipt only when the active bundle, turn,
## and finalized weekly commitment still describe the same action.
static func _action_record_for_bundle_from_weekly_commitment(
		commitment: Dictionary, bundle_id: String,
		expected_action: String) -> Dictionary:
	if commitment.is_empty() \
			or int(commitment.get("turn", -1)) != int(GameState.turn):
		return {}
	if str(commitment.get("pressure_id", "")) == bundle_id:
		return commitment.duplicate(true)
	var cycle_details: Dictionary = (
		(commitment.get("details", {}) as Dictionary).duplicate(true)
		if commitment.get("details", {}) is Dictionary else {}
	)
	if str(commitment.get("source", "")) != "seoul_cycle" \
			or str(cycle_details.get("execution", "")) != "seoul_cycle" \
			or not cycle_details.get("action_followups", []) is Array:
		return {}
	var match_record: Dictionary = {}
	for raw_followup in cycle_details.get("action_followups", []):
		if not raw_followup is Dictionary:
			continue
		var followup: Dictionary = raw_followup
		if str(followup.get("bundle_id", "")) != bundle_id \
				or str(followup.get("action_id", "")).strip_edges().to_lower() \
					!= expected_action \
				or int(followup.get("turn", -1)) != int(GameState.turn):
			continue
		if not match_record.is_empty():
			return {}
		match_record = {
			"turn": int(followup.get("turn", -1)),
			"pressure_id": bundle_id,
			"choice_id": expected_action,
			"actual_action_id": str(followup.get("action_id", "")),
			"outcome": (
				(followup.get("outcome", {}) as Dictionary).duplicate(true)
				if followup.get("outcome", {}) is Dictionary else {}),
			"details": (
				(followup.get("details", {}) as Dictionary).duplicate(true)
				if followup.get("details", {}) is Dictionary else {}),
		}
	return match_record

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
	var commitment := _action_record_for_bundle_from_weekly_commitment(
		GameState.get_weekly_commitment_for_turn(active_turn),
		bundle_id, expected_action)
	var actual_action := str(
		commitment.get("actual_action_id", "")).strip_edges().to_lower()
	if commitment.is_empty() \
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

## 24주 충돌 영수증에서 실제로 고른 의무와 실제 후보였지만 미룬 의무를
## 구분해 읽는다. 후보에 없던 의무는 deferred로 간주하지 않는다.
static func obligation_receipt_matches(
		bundle_id: String, obligation_id: String,
		disposition: String) -> bool:
	var normalized_bundle := bundle_id.strip_edges()
	var normalized_obligation := obligation_id.strip_edges()
	var normalized_disposition := disposition.strip_edges().to_lower()
	if normalized_bundle.is_empty() or normalized_obligation.is_empty() \
			or normalized_disposition not in ["selected", "deferred"]:
		return false
	var state := _normalized_state(GameState.core_loop_v2_state)
	var raw_receipt: Variant = state["obligation_receipts"].get(
		normalized_bundle, {})
	if not raw_receipt is Dictionary:
		return false
	var receipt: Dictionary = raw_receipt
	var raw_candidates: Variant = receipt.get("candidate_ids", [])
	var raw_deferred: Variant = receipt.get(
		"deferred_obligation_ids", [])
	var selected_id := str(receipt.get(
		"selected_obligation_id", "")).strip_edges()
	if str(receipt.get("bundle_id", "")) != normalized_bundle \
			or selected_id.is_empty() \
			or not raw_candidates is Array \
			or not raw_deferred is Array \
			or not (raw_candidates as Array).has(selected_id) \
			or not (raw_candidates as Array).has(normalized_obligation):
		return false
	if normalized_disposition == "selected":
		return selected_id == normalized_obligation
	return selected_id != normalized_obligation \
		and (raw_deferred as Array).has(normalized_obligation)

static func has_hyunsu_exam_memory() -> bool:
	var spec := _hyunsu_exam_contract()
	if spec.is_empty():
		return false
	var state := _normalized_state(GameState.core_loop_v2_state)
	for memory_id in spec["required_memories"]:
		if _has_relationship_memory(state, "hyunsu", memory_id):
			return true
	return false

static func has_hyunsu_exam_outcome_receipt() -> bool:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var raw_receipt: Variant = state["future_story_receipts"].get(
		HYUNSU_EXAM_OUTCOME_RECEIPT_ID, {})
	return raw_receipt is Dictionary \
		and _hyunsu_exam_outcome_receipt_valid(
			raw_receipt as Dictionary)

static func future_story_source_matches(
		receipt_id: String, source_id: String) -> bool:
	var normalized_receipt := receipt_id.strip_edges()
	var normalized_source := source_id.strip_edges()
	if normalized_receipt != HYUNSU_EXAM_OUTCOME_RECEIPT_ID \
			or normalized_source.is_empty():
		return false
	var state := _normalized_state(GameState.core_loop_v2_state)
	var raw_receipt: Variant = state["future_story_receipts"].get(
		normalized_receipt, {})
	return raw_receipt is Dictionary \
		and _hyunsu_exam_outcome_receipt_valid(
			raw_receipt as Dictionary) \
		and str((raw_receipt as Dictionary).get(
			"source_memory", "")) == normalized_source

static func post_demo_application_result_event_id(
		at_turn: int = -1,
		resolve_missing_receipt: bool = true) -> String:
	var spec := _city_result_contract()
	if spec.is_empty():
		return ""
	var state := _normalized_state(GameState.core_loop_v2_state)
	var raw_receipt: Variant = state[
		"future_application_receipts"].get(
			CITY_RESULT_RECEIPT_ID, {})
	if (
		not raw_receipt is Dictionary
		or not _city_result_receipt_valid(
			raw_receipt as Dictionary)
	) and resolve_missing_receipt \
			and int(GameState.turn) > 24:
		raw_receipt = _recover_missing_city_result_receipt(state)
		state = _normalized_state(GameState.core_loop_v2_state)
	if not raw_receipt is Dictionary \
			or not _city_result_receipt_valid(
				raw_receipt as Dictionary) \
			or str((raw_receipt as Dictionary).get(
				"status", "")) != "pending" \
			or str(state["application_statuses"].get(
				str(spec["application_id"]), "")) \
				!= str(spec["from"]):
		return ""
	var query_turn := int(GameState.turn) \
		if at_turn < 0 else at_turn
	# The future result is a bounded inbox opportunity, not a permanent poll:
	# after its authored Week 28–32 window the unresolved receipt stays silent.
	if query_turn < int(spec["not_before_week"]) \
			or query_turn > int(spec["not_after_week"]):
		return ""
	return str(spec["result_event"])

static func note_post_demo_application_result(
		event_id: String, choice_index: int) -> bool:
	var spec := _city_result_contract()
	if spec.is_empty() \
			or event_id != str(spec["result_event"]) \
			or choice_index != 0 \
			or int(GameState.turn) < int(
				spec["not_before_week"]):
		return false
	var event: Dictionary = DataRegistry.find_event(event_id)
	var choices: Variant = event.get("choices", [])
	if event.is_empty() or not choices is Array \
			or choice_index >= (choices as Array).size() \
			or not (choices as Array)[choice_index] is Dictionary:
		return false
	var choice: Dictionary = (choices as Array)[
		choice_index]
	if not choice.get("flags", []) is Array \
			or not (choice.get("flags", []) as Array).has(
				str(spec["result_flag"])) \
			or not bool(GameState.flags.get(
				str(spec["result_flag"]), false)):
		return false
	var state := _normalized_state(
		GameState.core_loop_v2_state)
	var raw_receipt: Variant = state[
		"future_application_receipts"].get(
			CITY_RESULT_RECEIPT_ID, {})
	if not raw_receipt is Dictionary \
			or not _city_result_receipt_valid(
				raw_receipt as Dictionary):
		return false
	var receipt: Dictionary = (
		raw_receipt as Dictionary).duplicate(true)
	if str(receipt.get("status", "")) == "resolved":
		return int(receipt.get(
			"choice_index", -1)) == choice_index
	if str(receipt.get("status", "")) != "pending" \
			or str(state["application_statuses"].get(
				str(spec["application_id"]), "")) \
				!= str(spec["from"]):
		return false
	receipt["status"] = "resolved"
	receipt["resolved_turn"] = int(GameState.turn)
	receipt["choice_index"] = choice_index
	state["future_application_receipts"][
		CITY_RESULT_RECEIPT_ID] = receipt
	state["application_statuses"][
		str(spec["application_id"])] = str(spec["to"])
	var transition_key := "future:%s:%d:%d" % [
		CITY_RESULT_RECEIPT_ID, choice_index,
		int(GameState.turn)]
	state["application_transition_receipts"][
		transition_key] = {
			"receipt_key": transition_key,
			"application_id": str(spec["application_id"]),
			"from": str(spec["from"]),
			"to": str(spec["to"]),
			"bundle_id": CITY_RESULT_RECEIPT_ID,
			"event_id": event_id,
			"choice_index": choice_index,
			"turn": int(GameState.turn),
		}
	GameState.core_loop_v2_state = state
	return true

static func hyunsu_exam_result_event_id(
		at_turn: int = -1,
		resolve_missing_receipt: bool = true) -> String:
	var spec := _hyunsu_exam_contract()
	if spec.is_empty():
		return ""
	var query_turn := int(GameState.turn) if at_turn < 0 else at_turn
	var state := _normalized_state(GameState.core_loop_v2_state)
	var raw_receipt: Variant = state["future_story_receipts"].get(
		HYUNSU_EXAM_OUTCOME_RECEIPT_ID, {})
	if (
		not raw_receipt is Dictionary
		or not _hyunsu_exam_outcome_receipt_valid(
			raw_receipt as Dictionary)
	):
		if not resolve_missing_receipt \
				or int(GameState.turn) <= int(spec["exam_week"]):
			return ""
		raw_receipt = _recover_missing_hyunsu_exam_outcome_receipt(
			state)
	if not raw_receipt is Dictionary \
			or not _hyunsu_exam_outcome_receipt_valid(
				raw_receipt as Dictionary):
		return ""
	if query_turn < int((raw_receipt as Dictionary).get(
			"available_turn", 0)):
		return ""
	if str((raw_receipt as Dictionary).get(
			"outcome", "")) != str(spec["canonical_outcome"]):
		return ""
	return str(spec["result_event"])

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
	# Runtime details, not today's authored config, prove which executor actually
	# ran. In particular, the same resume bundle remains a normal minigame for
	# non-onboarding/legacy play even though fresh W1 derives its typed
	# application executor from the onboarding marker.
	var execution := str(details.get("execution", "")).strip_edges()
	if execution.is_empty():
		match expected_action:
			"apply":
				execution = "application"
			"rest":
				execution = "rest"
	if not execution.is_empty():
		details["execution"] = execution
	if execution == "job_hunt_application":
		var fresh_origin := str(details.get(
			"onboarding_origin", "")) == W1_ONBOARDING_ORIGIN
		var typed_quality := int(details.get("quality", -1))
		if not fresh_origin \
				or bundle_id != W1_ONBOARDING_BUNDLE_ID \
				or record_turn != 1 \
				or typed_quality not in range(0, 4) \
				or str(details.get("application_id", "")) \
					!= W1_ONBOARDING_APPLICATION_ID \
				or str(details.get("status", "")) != "submitted" \
				or not bool(details.get(
					"onboarding_completion_override", false)):
			return {}
	elif str(config.get("execution", "")) == "job_hunt_application":
		# The authored bundle advertises the fresh-only executor, but a legacy
		# record may prove an ordinary resume minigame (or predate execution
		# details entirely). Do not snapshot application copy or identity into
		# that receipt merely because current content changed after the save.
		config = {}
		if not execution.is_empty():
			config["execution"] = execution
	# A schema-two record can outlive the content conversion from instant effect
	# to activity task. Rebuild the receipt with the historical execution and
	# effects that the record actually proves; keeping today's activity config as
	# its snapshot would make later readers mistake it for a modern task result.
	if execution == "instant_effect" \
			and str(config.get("execution", "")) == "activity_task":
		var raw_legacy: Variant = config.get("legacy_instant_effect", {})
		if not raw_legacy is Dictionary:
			return {}
		var legacy: Dictionary = raw_legacy as Dictionary
		var expected_legacy_effects: Dictionary = (
			(legacy.get("effects", {}) as Dictionary).duplicate(true)
			if legacy.get("effects", {}) is Dictionary else {}
		)
		var recorded_effects: Dictionary = (
			(details.get("effects", {}) as Dictionary).duplicate(true)
			if details.get("effects", {}) is Dictionary else {}
		)
		if recorded_effects.is_empty() and record.get("outcome", {}) is Dictionary:
			var recorded_outcome: Dictionary = record.get("outcome", {})
			for effect_key in expected_legacy_effects:
				if recorded_outcome.has(effect_key):
					recorded_effects[effect_key] = recorded_outcome[effect_key]
		if expected_legacy_effects.is_empty() \
				or recorded_effects != expected_legacy_effects:
			return {}
		config = {
			"execution": "instant_effect",
			"effects": recorded_effects,
			"axis": str(details.get("axis", config.get("axis", ""))),
			"place_id": str(details.get(
				"place_id", config.get("place_id", ""))),
		}
	if execution == "activity_task":
		var activity_config := _normalized_activity_task_config(config)
		if activity_config.is_empty():
			return {}
		var activity_result := _validated_activity_task_result(
			activity_config, details)
		if activity_result.is_empty():
			return {}
		for result_key in activity_result:
			if str(result_key) != "ok":
				details[result_key] = activity_result[result_key]
		details.erase("ok")
	var config_owns_application := str(config.get(
		"execution", "")) != "job_hunt_application"
	var application_id := str(details.get(
		"application_id", config.get("application_id", "") \
			if config_owns_application else "")).strip_edges()
	var status := str(details.get(
		"status", config.get(
			"application_status", config.get("status", "")) \
			if config_owns_application else "")).strip_edges()
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

static func _apply_action_application_receipt(
		state: Dictionary, bundle_id: String, receipt: Dictionary) -> bool:
	var application_id := str(receipt.get("application_id", ""))
	var status := str(receipt.get("application_status", ""))
	if application_id.is_empty() or status.is_empty():
		return true
	var details: Dictionary = receipt.get("result_details", {}) \
		if receipt.get("result_details", {}) is Dictionary else {}
	if str(details.get("execution", "")) != "job_hunt_application":
		state["application_statuses"][application_id] = status
		return true
	if bundle_id != W1_ONBOARDING_BUNDLE_ID \
			or application_id != W1_ONBOARDING_APPLICATION_ID \
			or status != "submitted":
		return false
	var transition_key := "%s:application:1" % bundle_id
	var transition := {
		"receipt_key": transition_key,
		"application_id": application_id,
		"from": "not_submitted",
		"to": status,
		"bundle_id": bundle_id,
		"event_id": "",
		"choice_index": -1,
		"turn": 1,
		"source": "typed_action_receipt",
		"quality": int(details.get("quality", -1)),
	}
	var raw_existing: Variant = state[
		"application_transition_receipts"].get(transition_key, {})
	if raw_existing is Dictionary and not (raw_existing as Dictionary).is_empty() \
			and raw_existing != transition:
		return false
	var prior_status := str(state["application_statuses"].get(
		application_id, ""))
	if prior_status not in ["", status]:
		return false
	state["application_transition_receipts"][transition_key] = transition
	state["application_statuses"][application_id] = status
	return true

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
		_clear_activity_task_session_for_owner(
			state, active_id, int(GameState.turn))
		if not _apply_action_application_receipt(state, active_id, existing):
			return false
		state["action_result_ready"] = not (
			_is_action_story_bundle(active_bundle)
			and _has_current_action_story_acknowledgement(
				state, active_id)
		)
		GameState.core_loop_v2_state = state
		return true
	var receipt := _action_receipt_from_record(
		active_id, active_bundle, record)
	if receipt.is_empty() or int(receipt.get("turn", -1)) != int(GameState.turn):
		return false
	state["action_receipts"][active_id] = receipt
	_clear_activity_task_session_for_owner(
		state, active_id, int(GameState.turn))
	if not _apply_action_application_receipt(state, active_id, receipt):
		return false
	state["action_result_ready"] = true
	GameState.core_loop_v2_state = state
	return true

static func _fresh_w1_application_postcondition(
		state: Dictionary, record: Dictionary, quality: int) -> bool:
	var onboarding: Dictionary = state.get(W1_ONBOARDING_STATE_KEY, {})
	var raw_receipt: Variant = state["action_receipts"].get(
		W1_ONBOARDING_BUNDLE_ID, {})
	if not raw_receipt is Dictionary:
		return false
	var receipt: Dictionary = raw_receipt
	var details: Dictionary = receipt.get("result_details", {}) \
		if receipt.get("result_details", {}) is Dictionary else {}
	var transition_key := "%s:application:1" % W1_ONBOARDING_BUNDLE_ID
	var raw_transition: Variant = state[
		"application_transition_receipts"].get(transition_key, {})
	return str(onboarding.get("phase", "")) == "result_committed" \
		and int(onboarding.get("quality", -1)) == quality \
		and int(receipt.get("turn", -1)) == 1 \
		and str(receipt.get("application_id", "")) \
			== W1_ONBOARDING_APPLICATION_ID \
		and str(receipt.get("application_status", "")) == "submitted" \
		and str(details.get("execution", "")) == "job_hunt_application" \
		and int(details.get("quality", -1)) == quality \
		and str(details.get("onboarding_origin", "")) \
			== W1_ONBOARDING_ORIGIN \
		and str(details.get("capacity_id", "")) \
			== str(onboarding.get("selected_capacity_id", "")) \
		and int(details.get("capacity_value", 0)) \
			== int(onboarding.get("selected_capacity_value", 0)) \
		and str(state["application_statuses"].get(
			W1_ONBOARDING_APPLICATION_ID, "")) == "submitted" \
		and raw_transition is Dictionary \
		and str((raw_transition as Dictionary).get("from", "")) \
			== "not_submitted" \
		and str((raw_transition as Dictionary).get("to", "")) == "submitted" \
		and not record.is_empty()

## The final Send is the single owner of effects, the cycle followup, the typed
## action receipt, and Mirae's submission transition. Any failed postcondition
## restores the serialized pre-Send state, including the armed commitment.
static func finalize_fresh_w1_application(
		stress_delta: int, quality: int) -> Dictionary:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var onboarding: Dictionary = state.get(W1_ONBOARDING_STATE_KEY, {})
	var capacity_id := str(onboarding.get(
		"selected_capacity_id", "")).strip_edges()
	var capacity_value := int(onboarding.get("selected_capacity_value", 0))
	if quality not in range(0, 4) \
			or str(onboarding.get("origin", "")) != W1_ONBOARDING_ORIGIN \
			or str(onboarding.get("phase", "")) != "minigame" \
			or int(GameState.turn) != 1 \
			or active_bundle_id() != W1_ONBOARDING_BUNDLE_ID \
			or active_kind() != "schedule" \
			or capacity_id.is_empty() or capacity_value not in range(1, 7) \
			or not GameState.has_pending_weekly_commitment(1) \
			or state["action_receipts"].has(W1_ONBOARDING_BUNDLE_ID) \
			or not application_status(W1_ONBOARDING_APPLICATION_ID).is_empty():
		return {"ok": false, "error": "fresh_application_preflight_failed"}
	var snapshot: Dictionary = GameState.serialize().duplicate(true)
	var effects := {"stress": stress_delta}
	var flag_updates: Dictionary = {}
	if quality >= 2:
		flag_updates["resume_polished"] = true
		if quality == 3:
			effects["intelligence"] = 2
		else:
			effects["intelligence"] = 1
	var details := {
		"execution": "job_hunt_application",
		"quality": quality,
		"effects": effects.duplicate(true),
		"application_id": W1_ONBOARDING_APPLICATION_ID,
		"status": "submitted",
		"onboarding_origin": W1_ONBOARDING_ORIGIN,
		"node_id": W1_ONBOARDING_NODE_ID,
		"capacity_id": capacity_id,
		"capacity_value": capacity_value,
		"onboarding_completion_override": true,
	}
	var transaction := GameState.finalize_weekly_effect_action(
		"resume", effects, "money", "youth_center", "", details,
		flag_updates)
	if not bool(transaction.get("ok", false)):
		return transaction
	var raw_record: Variant = transaction.get("record", {})
	if not raw_record is Dictionary \
			or not note_action_commitment(raw_record as Dictionary):
		GameState.call("_restore_serialized_snapshot_exact", snapshot)
		return {
			"ok": false,
			"error": "fresh_application_receipt_failed",
			"rolled_back": true,
		}
	state = _normalized_state(GameState.core_loop_v2_state)
	onboarding = state.get(W1_ONBOARDING_STATE_KEY, {})
	onboarding["phase"] = "result_committed"
	onboarding["quality"] = quality
	state[W1_ONBOARDING_STATE_KEY] = onboarding
	GameState.core_loop_v2_state = state
	state = _normalized_state(GameState.core_loop_v2_state)
	if not _fresh_w1_application_postcondition(
			state, raw_record as Dictionary, quality):
		GameState.call("_restore_serialized_snapshot_exact", snapshot)
		return {
			"ok": false,
			"error": "fresh_application_postcondition_failed",
			"rolled_back": true,
		}
	return {
		"ok": true,
		"record": (raw_record as Dictionary).duplicate(true),
		"effects": effects.duplicate(true),
		"quality": quality,
	}

static func stage_fresh_w1_application_draft(
		_stress_delta: int, quality: int) -> bool:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var onboarding: Dictionary = state.get(W1_ONBOARDING_STATE_KEY, {})
	if quality not in range(0, 4) \
			or str(onboarding.get("phase", "")) != "minigame" \
			or active_bundle_id() != W1_ONBOARDING_BUNDLE_ID \
			or not GameState.has_pending_weekly_commitment(1):
		return false
	# Draft score/stress is intentionally memory-only in MainGame. A manual save
	# before Send therefore reloads this same minigame from question one.
	return true

static func restart_fresh_w1_minigame() -> bool:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var onboarding: Dictionary = state.get(W1_ONBOARDING_STATE_KEY, {})
	if str(onboarding.get("phase", "")) not in [
			"allocation_pending", "minigame", "draft"] \
			or active_bundle_id() != W1_ONBOARDING_BUNDLE_ID \
			or not active_bundle_is_seoul_cycle_trigger():
		return false
	onboarding["phase"] = "minigame"
	onboarding["quality"] = -1
	onboarding["stress_delta"] = 0
	state[W1_ONBOARDING_STATE_KEY] = onboarding
	GameState.core_loop_v2_state = state
	return true

static func claim_fresh_w1_opening_interview() -> bool:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var onboarding: Dictionary = state.get(W1_ONBOARDING_STATE_KEY, {})
	var raw_receipt: Variant = state["action_receipts"].get(
		W1_ONBOARDING_BUNDLE_ID, {})
	if str(onboarding.get("phase", "")) != "action_completed" \
			or not raw_receipt is Dictionary \
			or str((raw_receipt as Dictionary).get(
				"application_id", "")) != W1_ONBOARDING_APPLICATION_ID \
			or str((raw_receipt as Dictionary).get(
				"application_status", "")) != "submitted" \
			or state["consequence_receipts"].has(
				OPENING_INTERVIEW_BUNDLE_ID) \
			or not str(state.get("active_bundle", "")).is_empty():
		return false
	var roots := resolved_event_roots(OPENING_INTERVIEW_BUNDLE_ID)
	if roots.is_empty():
		return false
	state["active_bundle"] = OPENING_INTERVIEW_BUNDLE_ID
	state["active_kind"] = "consequence"
	state["active_turn"] = int(GameState.turn)
	state["action_result_ready"] = false
	state["consequence_receipts"][OPENING_INTERVIEW_BUNDLE_ID] = {
		"consequence_id": OPENING_INTERVIEW_BUNDLE_ID,
		"scheduled_bundle": W1_ONBOARDING_BUNDLE_ID,
		"turn": int(GameState.turn),
		"status": "presented",
		"surface_kind": "fresh_w1_action",
		"roots": roots.duplicate(),
		"presented_turn": int(GameState.turn),
		"consumed_turn": 0,
		"legacy_separate_owner": false,
		"claim_source": "typed_action_receipt",
	}
	if not state["shown_consequences"].has(OPENING_INTERVIEW_BUNDLE_ID):
		state["shown_consequences"].append(OPENING_INTERVIEW_BUNDLE_ID)
	state["shown_consequence_turns"][OPENING_INTERVIEW_BUNDLE_ID] = int(
		GameState.turn)
	onboarding["phase"] = "consequence_presented"
	state[W1_ONBOARDING_STATE_KEY] = onboarding
	GameState.core_loop_v2_state = state
	prepare_story_bundle(OPENING_INTERVIEW_BUNDLE_ID)
	return true

## Continue is one transaction boundary for the fresh W1 Send. Completing the
## action first and claiming its interview second would otherwise strand a save
## as action_completed if the late consequence claim collided or lost its roots.
static func complete_fresh_w1_action_and_claim_interview() -> Dictionary:
	var snapshot: Dictionary = GameState.serialize().duplicate(true)
	var expected_roots := resolved_event_roots(OPENING_INTERVIEW_BUNDLE_ID)
	if expected_roots.is_empty():
		GameState.call("_restore_serialized_snapshot_exact", snapshot)
		return {
			"ok": false,
			"error": "fresh_w1_interview_roots_missing",
			"rolled_back": true,
		}
	var completed_id := complete_active_bundle()
	if completed_id != W1_ONBOARDING_BUNDLE_ID:
		GameState.call("_restore_serialized_snapshot_exact", snapshot)
		return {
			"ok": false,
			"error": "fresh_w1_action_completion_failed",
			"rolled_back": true,
		}
	if not claim_fresh_w1_opening_interview():
		GameState.call("_restore_serialized_snapshot_exact", snapshot)
		return {
			"ok": false,
			"error": "fresh_w1_interview_claim_failed",
			"rolled_back": true,
		}
	var state: Dictionary = GameState.core_loop_v2_state
	var onboarding: Dictionary = state.get(W1_ONBOARDING_STATE_KEY, {})
	var raw_receipt: Variant = state.get(
		"consequence_receipts", {}).get(OPENING_INTERVIEW_BUNDLE_ID, {})
	var valid: bool = str(onboarding.get("phase", "")) == "consequence_presented" \
		and str(state.get("active_bundle", "")) == OPENING_INTERVIEW_BUNDLE_ID \
		and str(state.get("active_kind", "")) == "consequence" \
		and int(state.get("active_turn", 0)) == int(GameState.turn) \
		and not bool(state.get("action_result_ready", true)) \
		and raw_receipt is Dictionary \
		and str((raw_receipt as Dictionary).get("status", "")) == "presented" \
		and str((raw_receipt as Dictionary).get("scheduled_bundle", "")) \
			== W1_ONBOARDING_BUNDLE_ID \
		and (raw_receipt as Dictionary).get("roots", []) == expected_roots \
		and (state.get("completed_bundles", []) as Array).count(
			W1_ONBOARDING_BUNDLE_ID) == 1
	if not valid:
		GameState.call("_restore_serialized_snapshot_exact", snapshot)
		return {
			"ok": false,
			"error": "fresh_w1_interview_handoff_postcondition_failed",
			"rolled_back": true,
		}
	return {
		"ok": true,
		"completed_bundle": W1_ONBOARDING_BUNDLE_ID,
		"interview_bundle": OPENING_INTERVIEW_BUNDLE_ID,
		"roots": expected_roots.duplicate(),
	}

static func complete_active_bundle() -> String:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var bundle_id := str(state.get("active_bundle", ""))
	var kind := str(state.get("active_kind", ""))
	if bundle_id.is_empty():
		return ""
	var cycle_pending_key := _seoul_cycle_pending_key_for_active(
		state, bundle_id, int(GameState.turn))
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
				and _selected_choice_requires_outcome_receipt(
					state, bundle_id, "application_outcomes") \
				and not _has_current_application_receipt(state, bundle_id):
			return ""
		if bundle_id == "demo_collision":
			var validated_context := _validated_demo_collision_context(state)
			if validated_context.is_empty():
				return ""
			var raw_obligation: Variant = state["obligation_receipts"].get(
				bundle_id, {})
			if not raw_obligation is Dictionary \
					or int((raw_obligation as Dictionary).get(
						"turn", -1)) != int(GameState.turn):
				return ""
			var dirty_root := str(validated_context.get(
				"dirty_root", "")).strip_edges()
			if not dirty_root.is_empty():
				var dirty_source := str(validated_context.get(
					"dirty_source", "")).strip_edges()
				var raw_dirty: Variant = state[
					"deferred_callback_receipts"].get(dirty_source, {})
				if not raw_dirty is Dictionary \
						or str((raw_dirty as Dictionary).get(
							"root", "")) != dirty_root \
						or str((raw_dirty as Dictionary).get(
							"status", "")) != "resolved":
					return ""
		if int(contract().get("schema_version", 1)) >= 3 \
				and not str(active_spec.get("action_id", "")).is_empty():
			var raw_action_receipt: Variant = state["action_receipts"].get(
				bundle_id, {})
			if not raw_action_receipt is Dictionary \
					or int((raw_action_receipt as Dictionary).get(
						"turn", -1)) != int(GameState.turn):
				return ""
		if _is_action_story_bundle(active_spec) \
				and (
					not _has_current_action_story_acknowledgement(
						state, bundle_id)
					or not _has_current_bundle_story_receipt(
						state, bundle_id)
				):
			return ""
	if kind == "consequence":
		var consequence_application_outcomes: Variant = active_spec.get(
			"application_outcomes", [])
		if consequence_application_outcomes is Array \
				and not (consequence_application_outcomes as Array).is_empty() \
				and _selected_choice_requires_outcome_receipt(
					state, bundle_id, "application_outcomes") \
				and not _has_current_application_receipt(state, bundle_id):
			return ""
		if not state["shown_consequences"].has(bundle_id):
			state["shown_consequences"].append(bundle_id)
		state["shown_consequence_turns"][bundle_id] = GameState.turn
		var raw_existing_receipt: Variant = state[
			"consequence_receipts"].get(bundle_id, {})
		var completion_receipt: Dictionary = {}
		if raw_existing_receipt is Dictionary \
				and str((raw_existing_receipt as Dictionary).get(
					"status", "")) == "presented":
			completion_receipt = (
				raw_existing_receipt as Dictionary).duplicate(true)
		else:
			completion_receipt = {
				"consequence_id": bundle_id,
				"scheduled_bundle": "",
				"turn": int(GameState.turn),
				"surface_kind": "legacy_separate",
				"roots": resolved_event_roots(bundle_id),
				"presented_turn": int(GameState.turn),
				"legacy_separate_owner": true,
			}
		completion_receipt["status"] = "consumed"
		completion_receipt["consumed_turn"] = int(GameState.turn)
		state["consequence_receipts"][bundle_id] = completion_receipt
	else:
		if not state["completed_bundles"].has(bundle_id):
			state["completed_bundles"].append(bundle_id)
			state["completed_bundle_turns"][bundle_id] = GameState.turn
		if cycle_pending_key.is_empty() \
				and not state["completed_turns"].has(GameState.turn):
			state["completed_turns"].append(GameState.turn)
		if not cycle_pending_key.is_empty():
			var cycle_receipt_key := "trigger_receipts" \
				if cycle_pending_key == "pending_trigger" \
				else "world_receipts"
			if not _resolve_seoul_cycle_entry_in_state(
					state, cycle_pending_key, cycle_receipt_key,
					bundle_id, int(GameState.turn)):
				return ""
	var onboarding: Dictionary = state.get(W1_ONBOARDING_STATE_KEY, {})
	if bundle_id == W1_ONBOARDING_BUNDLE_ID \
			and kind == "schedule" \
			and str(onboarding.get("phase", "")) == "result_committed":
		onboarding["phase"] = "action_completed"
		state[W1_ONBOARDING_STATE_KEY] = onboarding
	elif bundle_id == OPENING_INTERVIEW_BUNDLE_ID \
			and kind == "consequence" \
			and str(onboarding.get("phase", "")) == "consequence_presented":
		onboarding["phase"] = "consumed"
		state[W1_ONBOARDING_STATE_KEY] = onboarding
	state["active_bundle"] = ""
	state["active_kind"] = ""
	state["active_turn"] = 0
	state["action_result_ready"] = false
	state["activity_task_session"] = {}
	GameState.core_loop_v2_state = state
	return bundle_id

static func _seoul_cycle_pending_key_for_active(
		state: Dictionary, bundle_id: String, turn: int) -> String:
	if str(state.get("active_kind", "")) != "schedule" \
			or int(state.get("active_turn", 0)) != turn:
		return ""
	var cycle: Dictionary = state.get(SEOUL_CYCLE_STATE_KEY, {})
	if cycle.is_empty():
		return ""
	for pending_key in ["pending_trigger", "pending_world"]:
		var raw_entry: Variant = cycle.get(pending_key, {})
		if raw_entry is Dictionary \
				and str((raw_entry as Dictionary).get("status", "")) \
					== "claimed" \
				and str((raw_entry as Dictionary).get("bundle_id", "")) \
					== bundle_id \
				and int((raw_entry as Dictionary).get("turn", 0)) == turn:
			return pending_key
	return ""

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

static func _is_action_story_bundle(scene_bundle: Dictionary) -> bool:
	var roots: Variant = scene_bundle.get("existing_roots", [])
	return not str(scene_bundle.get("action_id", "")).strip_edges().is_empty() \
		and roots is Array and not (roots as Array).is_empty()

static func _has_current_action_story_acknowledgement(
		state: Dictionary, bundle_id: String) -> bool:
	var scene_bundle := bundle(bundle_id)
	if not _is_action_story_bundle(scene_bundle):
		return false
	var raw_acknowledgement: Variant = state[
		"action_story_acknowledgements"].get(bundle_id, {})
	if not raw_acknowledgement is Dictionary:
		return false
	var acknowledgement: Dictionary = raw_acknowledgement
	return str(acknowledgement.get("bundle_id", "")) == bundle_id \
		and str(acknowledgement.get(
			"action_id", "")).strip_edges().to_lower() \
			== str(scene_bundle.get(
				"action_id", "")).strip_edges().to_lower() \
		and int(acknowledgement.get("turn", -1)) == int(GameState.turn) \
		and str(acknowledgement.get("status", "")) == "acknowledged"

static func _has_current_bundle_story_receipt(
		state: Dictionary, bundle_id: String) -> bool:
	var event_ids := _bundle_story_event_ids(bundle_id)
	if event_ids.is_empty():
		return false
	for raw_story_receipt in state["story_choice_receipts"].values():
		if not raw_story_receipt is Dictionary:
			continue
		var receipt: Dictionary = raw_story_receipt
		if str(receipt.get("bundle_id", "")) == bundle_id \
				and str(receipt.get("active_kind", "")) == "schedule" \
				and int(receipt.get("turn", -1)) == int(GameState.turn) \
				and event_ids.has(str(receipt.get("event_id", ""))):
			return true
	return false

static func _bundle_story_event_ids(bundle_id: String) -> Array:
	var result: Array = []
	var pending: Array = resolved_event_roots(bundle_id)
	while not pending.is_empty():
		var event_id := str(pending.pop_front()).strip_edges()
		if event_id.is_empty() or result.has(event_id):
			continue
		result.append(event_id)
		var event: Dictionary = DataRegistry.find_event(event_id)
		var choices: Variant = event.get("choices", [])
		if not choices is Array:
			continue
		for raw_choice in choices:
			if not raw_choice is Dictionary:
				continue
			var follow_up := str((raw_choice as Dictionary).get(
				"follow_up_event", "")).strip_edges()
			if not follow_up.is_empty() and not result.has(follow_up):
				pending.append(follow_up)
	return result

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

static func _selected_choice_requires_outcome_receipt(
		state: Dictionary, bundle_id: String, outcome_field: String) -> bool:
	var raw_outcomes: Variant = bundle(bundle_id).get(outcome_field, [])
	if not raw_outcomes is Array or (raw_outcomes as Array).is_empty():
		return false
	var declared_event_was_chosen := false
	var applicable_outcomes := 0
	for raw_outcome in raw_outcomes:
		if raw_outcome is Dictionary \
				and _outcome_runtime_applicable(
					state, bundle_id, raw_outcome as Dictionary):
			applicable_outcomes += 1
	if applicable_outcomes == 0:
		return false
	for raw_story_receipt in state["story_choice_receipts"].values():
		if not raw_story_receipt is Dictionary:
			continue
		var story_receipt: Dictionary = raw_story_receipt
		if int(story_receipt.get("turn", -1)) != int(GameState.turn):
			continue
		var event_id := str(story_receipt.get("event_id", ""))
		var choice_index := int(story_receipt.get("choice_index", -1))
		for raw_outcome in raw_outcomes:
			if not raw_outcome is Dictionary \
					or not _outcome_runtime_applicable(
						state, bundle_id, raw_outcome as Dictionary) \
					or str((raw_outcome as Dictionary).get(
						"event_id", "")) != event_id:
				continue
			declared_event_was_chosen = true
			if _outcome_choice_matches(
					raw_outcome as Dictionary, choice_index):
				return true
	# No choice receipt means the declared transition scene has not been read
	# yet and must still block completion. A receipt for the same event on a
	# deliberately unmapped choice means that choice carries no transition.
	return not declared_event_was_chosen

static func _outcome_runtime_applicable(
		state: Dictionary, bundle_id: String,
		outcome: Dictionary) -> bool:
	if bundle_id != "demo_collision" \
			or str(outcome.get("application_id", "")) \
				!= "city_facility_ops_2026h1":
		return true
	var raw_context: Variant = state.get("demo_collision_context", {})
	if not raw_context is Dictionary \
			or not (raw_context as Dictionary).get(
				"candidate_ids", []) is Array:
		return false
	return ((raw_context as Dictionary).get(
		"candidate_ids", []) as Array).has("city_work_sample")

static func cancel_active_bundle() -> void:
	var state := _normalized_state(GameState.core_loop_v2_state)
	state["active_bundle"] = ""
	state["active_kind"] = ""
	state["active_turn"] = 0
	state["action_result_ready"] = false
	state["activity_task_session"] = {}
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
	if not str(scheduled_spec.get("action_id", "")).is_empty():
		surface_kind = "action"
	elif scheduled_spec.get("existing_roots", []) is Array \
			and not (scheduled_spec.get("existing_roots", []) as Array).is_empty():
		surface_kind = "story"
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
			and _selected_choice_requires_outcome_receipt(
				state, consequence_id, "application_outcomes") \
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
		# Compatibility: an old V2 Month-One plan can still submit Mirae as its
		# Week-One foreground action.  The fresh route owns this interview before
		# planning, but the old action must keep its established Week-Two prelude;
		# never attach the result to the producer's own week.
		if consequence_id == OPENING_INTERVIEW_BUNDLE_ID \
				and int(GameState.flags.get(
					"opening_interview_application_turn", 0)) \
					>= int(GameState.turn):
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

## Received phone history is proven by the durable presentation receipt, not
## by a still-pending predicate. A hiring choice changes its application
## status, but the text message must remain in the same month's inbox.
static func received_phone_consequence_ids(
		month_index: int = -1) -> Array[String]:
	var target_month := (
		month_index if month_index > 0 else month_for_turn(GameState.turn))
	var state := _normalized_state(GameState.core_loop_v2_state)
	var result: Array[String] = []
	var receipt_candidates: Array = []
	receipt_candidates.append_array(month_spec(target_month).get(
		"prelude", []))
	receipt_candidates.append_array(month_spec(target_month).get(
		"conditional_consequences", []))
	for raw_id in receipt_candidates:
		var consequence_id := str(raw_id).strip_edges()
		if consequence_id.is_empty() or result.has(consequence_id):
			continue
		var consequence := bundle(consequence_id)
		if str(consequence.get("phone_surface", "")) \
				not in ["inbound_message", "call_log"]:
			continue
		var raw_receipt: Variant = state["consequence_receipts"].get(
			consequence_id, {})
		if not raw_receipt is Dictionary:
			continue
		var receipt: Dictionary = raw_receipt
		if str(receipt.get("consequence_id", "")) != consequence_id \
				or str(receipt.get("status", "")) \
					not in ["presented", "consumed"]:
			continue
		var presented_turn := int(receipt.get(
			"presented_turn", receipt.get("turn", 0)))
		if presented_turn < 1 \
				or month_for_turn(presented_turn) != target_month \
				or not state["shown_consequences"].has(consequence_id) \
				or int(state["shown_consequence_turns"].get(
					consequence_id, 0)) != presented_turn:
			continue
		result.append(consequence_id)
	return result

## Offer-shaped calls and messages need a durable inbox history too. Once the
## monthly plan is committed, a choice may change the very predicate that made
## the contact available (for example submitted -> interviewed). The plan and
## completion receipts prove that the communication really arrived even when
## it is no longer returned by available_offer_ids().
static func received_phone_offer_ids(
		month_index: int = -1) -> Array[String]:
	var target_month := (
		month_index if month_index > 0 else month_for_turn(GameState.turn))
	var candidates: Array[String] = []
	for bundle_id in available_offer_ids(target_month):
		if not candidates.has(bundle_id):
			candidates.append(bundle_id)

	var plan := plan_for_month(target_month)
	for raw_id in plan.get("selected", []):
		var selected_id := str(raw_id).strip_edges()
		if not selected_id.is_empty() and not candidates.has(selected_id):
			candidates.append(selected_id)
	for raw_record in plan.get("forgone", []):
		if not raw_record is Dictionary:
			continue
		var forgone_id := str((raw_record as Dictionary).get(
			"bundle_id", "")).strip_edges()
		if not forgone_id.is_empty() and not candidates.has(forgone_id):
			candidates.append(forgone_id)

	var state := _normalized_state(GameState.core_loop_v2_state)
	for raw_id in state["completed_bundles"]:
		var completed_id := str(raw_id).strip_edges()
		var completed_turn := int(
			state["completed_bundle_turns"].get(completed_id, 0))
		if completed_id.is_empty() \
				or month_for_turn(completed_turn) != target_month \
				or candidates.has(completed_id):
			continue
		candidates.append(completed_id)

	var result: Array[String] = []
	for bundle_id in candidates:
		if str(bundle(bundle_id).get("phone_surface", "")) \
				in ["inbound_message", "call_log"]:
			result.append(bundle_id)
	return result

static func resolved_event_roots(bundle_id: String) -> Array:
	var scene_bundle := bundle(bundle_id)
	if bundle_id == "demo_collision":
		var state := _normalized_state(GameState.core_loop_v2_state)
		var context := _validated_demo_collision_context(state)
		if context.is_empty():
			return []
		var stored_roots: Variant = context.get("roots", [])
		return (stored_roots as Array).duplicate() \
			if stored_roots is Array else []
	if bundle_id == "temptation_consequence":
		if bool(GameState.flags.get("lent_account", false)):
			return ["arc_temptation_fallout"]
		return ["arc_temptation_clean"]
	var roots: Variant = scene_bundle.get("existing_roots", [])
	return (roots as Array).duplicate() if roots is Array else []

## Formats both ordinary event tokens and the First Bill's story-only tokens.
## Gallery replay uses the exact Week-24 snapshot instead of whichever new run
## happens to be loaded behind the archive. Rendering remains strictly
## read-only: it never repairs, infers, or creates gameplay state.
static func format_first_bill_story_text(
		source_text: String, replay_snapshot: Dictionary = {}) -> String:
	var snapshot := validated_first_bill_replay_snapshot(replay_snapshot)
	var formatted := source_text
	if snapshot.is_empty():
		formatted = GameState.format_event_text(formatted)
	else:
		var replay_money := float(snapshot.get("money", 0.0))
		formatted = formatted \
			.replace("{name}", _first_bill_localized_player_name(
				str(snapshot.get("player_name", "")))) \
			.replace("{cash_position}",
				_first_bill_cash_position_sentence(replay_money)) \
			.replace("{expense}", GameState.format_money(
				float(snapshot.get("housing_expense", 0.0))))
		# First Bill does not currently use the remaining generic tokens, but
		# resolving them keeps the formatter safe if a non-dynamic line gains one.
		formatted = GameState.format_event_text(formatted)
	formatted = format_first_bill_story_tokens(formatted, snapshot)
	var player_name: String = _first_bill_localized_player_name(str(snapshot.get(
		"player_name", GameState.player_name)))
	return formatted.replace(
		"{name}", player_name if not player_name.is_empty() else GameState.player_name)

## Expands the First Bill's story-only tokens from frozen candidates and durable
## receipts. Kept public for focused QA and other story surfaces.
static func format_first_bill_story_tokens(
		source_text: String, replay_snapshot: Dictionary = {}) -> String:
	var needs_format := false
	for token in FIRST_BILL_STORY_TOKENS:
		if source_text.contains(token):
			needs_format = true
			break
	if not needs_format:
		return source_text

	var replacements: Dictionary = {}
	for token in FIRST_BILL_STORY_TOKENS:
		replacements[token] = ""
	replacements[MONTH_ONE_EPISODE_TOKEN] = month_one_episode_echo(
		replay_snapshot)
	var finale := _first_bill_finale_contract()
	var snapshot := validated_first_bill_replay_snapshot(replay_snapshot)
	var state := _normalized_state(GameState.core_loop_v2_state)
	var context := _validated_demo_collision_context(state)
	var candidates: Array[String] = []
	var health := int(GameState.health)
	var cash := float(GameState.money)
	var required_cash := float(GameState.get_monthly_required_cash())
	if not snapshot.is_empty():
		state = _first_bill_replay_state(snapshot)
		context = (snapshot.get("context", {}) as Dictionary).duplicate(true)
		candidates = _first_bill_candidate_ids_from_raw(
			context.get("candidate_ids", []))
		health = int(snapshot.get("health", health))
		cash = float(snapshot.get("money", cash))
		required_cash = float(snapshot.get("required_cash", required_cash))
	if not finale.is_empty() and not context.is_empty():
		if candidates.is_empty():
			candidates = _first_bill_candidate_ids(state, context)
		if not candidates.is_empty():
			var raw_copy: Variant = finale.get("candidate_copy", {})
			var copy_contract: Dictionary = raw_copy \
				if raw_copy is Dictionary else {}
			replacements["{v2_first_bill_body}"] = \
				_first_bill_body_copy(finale, health)
			replacements["{v2_first_bill_trace}"] = \
				_first_bill_trace_copy(state, context, finale)
			replacements["{v2_first_bill_evidence}"] = \
				_first_bill_candidate_copy_lines(
					copy_contract, "evidence", candidates)
			replacements["{v2_first_bill_after_bills}"] = \
				_first_bill_after_bills_copy(finale, cash, required_cash)
			replacements["{v2_first_bill_tradeoffs}"] = \
				_first_bill_candidate_copy_lines(
					copy_contract, "tradeoff", candidates)
			replacements["{v2_hyunsu_exam_eve_memory}"] = \
				_first_bill_hyunsu_memory_copy(state, context, finale)

			var receipt := _first_bill_obligation_receipt(
				state, context, candidates, finale)
			if not receipt.is_empty():
				var selected_id := str(receipt.get(
					"selected_obligation_id", ""))
				var selected_ids: Array[String] = [selected_id]
				replacements["{v2_first_bill_return}"] = \
					_first_bill_candidate_copy_lines(
						copy_contract, "return", selected_ids)
				replacements["{v2_first_bill_done}"] = \
					_first_bill_candidate_copy_lines(
						copy_contract, "done", selected_ids)
				var ordinary_deferred: Array[String] = []
				var deadline_deferred: Array[String] = []
				var deadline_ids: Array = finale.get(
					"deadline_missed_ids", []) \
					if finale.get("deadline_missed_ids", []) is Array \
					else []
				for raw_id in receipt.get("deferred_obligation_ids", []):
					var obligation_id := str(raw_id)
					if deadline_ids.has(obligation_id):
						deadline_deferred.append(obligation_id)
					else:
						ordinary_deferred.append(obligation_id)
				replacements["{v2_first_bill_not_done}"] = \
					_first_bill_candidate_copy_lines(
						copy_contract, "not_done", ordinary_deferred)
				replacements["{v2_first_bill_deadline_missed}"] = \
					_first_bill_candidate_copy_lines(
						copy_contract, "deadline_missed", deadline_deferred)

	var formatted := source_text
	for token in FIRST_BILL_STORY_TOKENS:
		formatted = formatted.replace(token, str(replacements[token]))
	var player_name: String = _first_bill_localized_player_name(str(snapshot.get(
		"player_name", GameState.player_name)))
	return formatted.replace(
		"{name}", player_name if not player_name.is_empty() else GameState.player_name)

static func _first_bill_finale_contract() -> Dictionary:
	var raw_finale: Variant = bundle(
		"demo_collision").get("first_bill_finale", {})
	return (raw_finale as Dictionary).duplicate(true) \
		if raw_finale is Dictionary else {}

static func build_first_bill_replay_snapshot(
		allow_completed_legacy: bool = false) -> Dictionary:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var context := _validated_demo_collision_context(
		state, not allow_completed_legacy)
	if context.is_empty():
		return {}
	var finale := _first_bill_finale_contract()
	var candidates := _first_bill_candidate_ids(
		state, context, not allow_completed_legacy)
	if candidates.is_empty() or finale.is_empty():
		return {}
	var obligation := _first_bill_obligation_receipt(
		state, context, candidates, finale)
	if allow_completed_legacy and obligation.is_empty():
		return {}
	var snapshot_health := int(GameState.health)
	var snapshot_mental := int(GameState.mental)
	var snapshot_addiction := int(GameState.addiction_tendency)
	var snapshot_money := float(GameState.money)
	var snapshot_assets := float(GameState.get_total_asset_value())
	# A result-phase save contains post-choice GameState. Replay needs the
	# opening values so trying a different read-only choice starts from the same
	# body and balance that the original decision did.
	if not obligation.is_empty():
		var decision: Dictionary = DataRegistry.find_event(FIRST_BILL_DECISION_ID)
		var choices: Variant = decision.get("choices", [])
		var selected_index := int(obligation.get("choice_index", -1))
		if choices is Array and selected_index >= 0 \
				and selected_index < (choices as Array).size() \
				and (choices as Array)[selected_index] is Dictionary:
			var effects: Dictionary = (
				(choices as Array)[selected_index] as Dictionary).get("effects", {})
			snapshot_health -= int(effects.get("health", 0))
			snapshot_mental -= int(effects.get("mental", 0)) \
				- int(effects.get("stress", 0))
			snapshot_addiction -= int(effects.get("addiction_tendency", 0))
			snapshot_money -= float(effects.get("money", 0.0))
			snapshot_assets -= float(effects.get("money", 0.0))
	var snapshot := {
		"schema": FIRST_BILL_REPLAY_SCHEMA,
		"scene_id": FIRST_BILL_OPENING_ID,
		"turn": 24,
		"player_name": str(GameState.player_name),
		"housing": str(GameState.housing),
		"health": snapshot_health,
		"mental": snapshot_mental,
		"addiction_tendency": snapshot_addiction,
		"moral_tint": float(GameState.moral_tint),
		"money": snapshot_money,
		"total_assets": snapshot_assets,
		"housing_expense": float(GameState.get_housing_expense()),
		"required_cash": float(GameState.get_monthly_required_cash()),
		"context": context.duplicate(true),
		"father_memory": _first_bill_father_memory_id(state),
		"dirty_receipt": {},
		"hyunsu_receipt": {},
		"obligation_receipt": {},
	}
	var dirty_source := str(context.get("dirty_source", "")).strip_edges()
	if not dirty_source.is_empty():
		var raw_dirty: Variant = state["deferred_callback_receipts"].get(
			dirty_source, {})
		if raw_dirty is Dictionary:
			snapshot["dirty_receipt"] = (raw_dirty as Dictionary).duplicate(true)
	var roots: Array = context.get("roots", [])
	if roots.has("v2_hyunsu_exam_morning_echo"):
		var raw_hyunsu: Variant = state["future_story_receipts"].get(
			HYUNSU_EXAM_OUTCOME_RECEIPT_ID, {})
		if raw_hyunsu is Dictionary:
			snapshot["hyunsu_receipt"] = (raw_hyunsu as Dictionary).duplicate(true)
	if not obligation.is_empty():
		snapshot["obligation_receipt"] = obligation
	return validated_first_bill_replay_snapshot(snapshot)

static func validated_first_bill_replay_snapshot(
		raw_snapshot: Dictionary) -> Dictionary:
	if raw_snapshot.is_empty() \
			or int(raw_snapshot.get("schema", 0)) != FIRST_BILL_REPLAY_SCHEMA \
			or str(raw_snapshot.get("scene_id", "")) != FIRST_BILL_OPENING_ID \
			or int(raw_snapshot.get("turn", -1)) != 24:
		return {}
	var player_name := str(raw_snapshot.get("player_name", "")).strip_edges()
	var housing := str(raw_snapshot.get("housing", "")).strip_edges()
	if player_name.is_empty() or player_name.length() > 64 \
			or housing not in [
				"gosiwon", "oneroom", "villa", "apartment", "gangnam",
			]:
		return {}
	for key in ["health", "mental", "addiction_tendency", "moral_tint", "money",
			"total_assets", "housing_expense", "required_cash"]:
		if not raw_snapshot.has(key) \
				or typeof(raw_snapshot[key]) not in [TYPE_INT, TYPE_FLOAT]:
			return {}
	var health := int(raw_snapshot.get("health", 0))
	var mental := int(raw_snapshot.get("mental", 0))
	var addiction := int(raw_snapshot.get("addiction_tendency", 0))
	var moral_tint := float(raw_snapshot.get("moral_tint", 0.0))
	var money := float(raw_snapshot.get("money", 0.0))
	var total_assets := float(raw_snapshot.get("total_assets", 0.0))
	var housing_expense := float(raw_snapshot.get("housing_expense", 0.0))
	var required_cash := float(raw_snapshot.get("required_cash", 0.0))
	if not is_finite(moral_tint) or not is_finite(money) \
			or moral_tint < -100.0 or moral_tint > 100.0 \
			or not is_finite(total_assets) \
			or not is_finite(housing_expense) or not is_finite(required_cash) \
			or health < 0 or health > 100 \
			or mental < 0 or mental > 100 \
			or addiction < 0 or addiction > 100 \
			or absf(money) > 10_000_000_000_000.0 \
			or absf(total_assets) > 10_000_000_000_000.0 \
			or housing_expense < 0.0 \
			or required_cash < housing_expense \
			or required_cash > 10_000_000_000_000.0:
		return {}
	var raw_context: Variant = raw_snapshot.get("context", {})
	if not raw_context is Dictionary:
		return {}
	var context: Dictionary = raw_context
	if str(context.get("bundle_id", "")) != "demo_collision" \
			or int(context.get("turn", -1)) != 24 \
			or not context.get("roots", []) is Array:
		return {}
	var candidates := _first_bill_candidate_ids_from_raw(
		context.get("candidate_ids", []))
	if candidates.size() < 2 or candidates.size() > 4 \
			or not candidates.has("father_call"):
		return {}
	var dirty_source := str(context.get("dirty_source", "")).strip_edges()
	var dirty_root := str(context.get("dirty_root", "")).strip_edges()
	var expected_roots: Array[String] = []
	if dirty_source.is_empty() != dirty_root.is_empty() \
			or dirty_root not in [
				"", "v2_dirty_trace_initial_call", "v2_dirty_recruiter_week24",
			]:
		return {}
	var raw_dirty: Variant = raw_snapshot.get("dirty_receipt", {})
	if not raw_dirty is Dictionary:
		return {}
	if not dirty_root.is_empty():
		var expected_source := (
			"callback_escaped_dirty_trace"
			if dirty_root == "v2_dirty_trace_initial_call"
			else "fell_to_darkness")
		if dirty_source != expected_source or not raw_dirty is Dictionary:
			return {}
		var dirty_receipt: Dictionary = raw_dirty
		if str(dirty_receipt.get("source", "")) != dirty_source \
				or str(dirty_receipt.get("root", "")) != dirty_root \
				or int(dirty_receipt.get("claimed_turn", -1)) != 24 \
				or str(dirty_receipt.get("status", "")) \
					not in ["claimed", "resolved"]:
			return {}
		if str(dirty_receipt.get("status", "")) == "resolved":
			var dirty_event: Dictionary = DataRegistry.find_event(dirty_root)
			var dirty_choices: Variant = dirty_event.get("choices", [])
			var dirty_choice_index := int(dirty_receipt.get("choice_index", -1))
			if str(dirty_receipt.get("event_id", "")) != dirty_root \
					or int(dirty_receipt.get("resolved_turn", -1)) != 24 \
					or not dirty_choices is Array \
					or dirty_choice_index < 0 \
					or dirty_choice_index >= (dirty_choices as Array).size():
				return {}
		expected_roots.append(dirty_root)
	elif raw_dirty is Dictionary and not (raw_dirty as Dictionary).is_empty():
		return {}
	expected_roots.append(FIRST_BILL_OPENING_ID)
	var raw_hyunsu: Variant = raw_snapshot.get("hyunsu_receipt", {})
	if not raw_hyunsu is Dictionary:
		return {}
	if raw_hyunsu is Dictionary and not (raw_hyunsu as Dictionary).is_empty():
		if not _hyunsu_exam_outcome_receipt_valid(raw_hyunsu as Dictionary):
			return {}
		expected_roots.append("v2_hyunsu_exam_morning_echo")
	var roots: Array = context.get("roots", [])
	if roots.size() != expected_roots.size():
		return {}
	for index in range(expected_roots.size()):
		if str(roots[index]) != expected_roots[index]:
			return {}
	var snapshot := raw_snapshot.duplicate(true)
	snapshot["context"] = context.duplicate(true)
	# Schema-1 archives created before ORDER-88 have no frozen Father memory.
	# Normalize that absence to an explicit empty value so replay can never
	# fall back to a later run's live relationship state.
	var raw_father_memory: Variant = raw_snapshot.get("father_memory", "")
	if not raw_father_memory is String:
		return {}
	var father_memory := str(raw_father_memory).strip_edges()
	if not father_memory.is_empty() \
			and father_memory not in FIRST_BILL_FATHER_MEMORY_IDS:
		return {}
	snapshot["father_memory"] = father_memory
	var raw_obligation: Variant = snapshot.get("obligation_receipt", {})
	if not raw_obligation is Dictionary:
		return {}
	if raw_obligation is Dictionary and not (raw_obligation as Dictionary).is_empty():
		var replay_state := _first_bill_replay_state(snapshot)
		if _first_bill_obligation_receipt(
				replay_state, context, candidates,
				_first_bill_finale_contract()).is_empty():
			return {}
	return snapshot

static func validated_complete_first_bill_replay_snapshot(
		raw_snapshot: Dictionary) -> Dictionary:
	var snapshot := validated_first_bill_replay_snapshot(raw_snapshot)
	if snapshot.is_empty():
		return {}
	var raw_obligation: Variant = snapshot.get("obligation_receipt", {})
	if not raw_obligation is Dictionary \
			or (raw_obligation as Dictionary).is_empty():
		return {}
	return snapshot

static func first_bill_replay_choice_available(
		replay_snapshot: Dictionary, obligation_id: String) -> bool:
	var snapshot := validated_first_bill_replay_snapshot(replay_snapshot)
	if snapshot.is_empty():
		return false
	return _first_bill_candidate_ids_from_raw(
		(snapshot.get("context", {}) as Dictionary).get(
			"candidate_ids", [])).has(obligation_id.strip_edges())

static func first_bill_replay_has_relationship_memory(
		replay_snapshot: Dictionary,
		character_id: String,
		memory_id: String) -> bool:
	var snapshot := validated_first_bill_replay_snapshot(replay_snapshot)
	if snapshot.is_empty() \
			or character_id.strip_edges() != "father":
		return false
	var frozen_memory := str(snapshot.get("father_memory", ""))
	return not frozen_memory.is_empty() \
		and memory_id.strip_edges() == frozen_memory

static func first_bill_replay_snapshot_with_choice(
		replay_snapshot: Dictionary, choice_index: int) -> Dictionary:
	var snapshot := validated_first_bill_replay_snapshot(replay_snapshot)
	if snapshot.is_empty():
		return {}
	var context: Dictionary = snapshot.get("context", {})
	var candidates := _first_bill_candidate_ids_from_raw(
		context.get("candidate_ids", []))
	var selected_id := _obligation_id_for_choice(
		"demo_collision", FIRST_BILL_DECISION_ID, choice_index)
	if selected_id.is_empty() or not candidates.has(selected_id):
		return {}
	var deferred: Array[String] = []
	for candidate_id in candidates:
		if candidate_id != selected_id:
			deferred.append(candidate_id)
	snapshot["obligation_receipt"] = {
		"bundle_id": "demo_collision",
		"event_id": FIRST_BILL_DECISION_ID,
		"turn": 24,
		"candidate_ids": candidates.duplicate(),
		"selected_obligation_id": selected_id,
		"choice_index": choice_index,
		"deferred_obligation_ids": deferred,
	}
	return validated_first_bill_replay_snapshot(snapshot)

static func first_bill_replay_choice_is_fatal(
		replay_snapshot: Dictionary, choice_index: int) -> bool:
	var snapshot := validated_first_bill_replay_snapshot(replay_snapshot)
	var event: Dictionary = DataRegistry.find_event(FIRST_BILL_DECISION_ID)
	var choices: Variant = event.get("choices", [])
	if snapshot.is_empty() or not choices is Array \
			or choice_index < 0 or choice_index >= (choices as Array).size() \
			or not (choices as Array)[choice_index] is Dictionary:
		return false
	var effects: Dictionary = ((choices as Array)[choice_index] as Dictionary).get(
		"effects", {})
	var health := int(snapshot.get("health", 0)) + int(effects.get("health", 0))
	var mental := int(snapshot.get("mental", 0)) \
		+ int(effects.get("mental", 0)) - int(effects.get("stress", 0))
	var assets := float(snapshot.get("total_assets", 0.0)) \
		+ float(effects.get("money", 0.0))
	var addiction := int(snapshot.get("addiction_tendency", 0)) \
		+ int(effects.get("addiction_tendency", 0))
	return health <= 0 or mental <= 0 \
		or assets < -100_000_000.0 or addiction >= 90

static func first_bill_replay_follow_up_roots(
		replay_snapshot: Dictionary) -> Array[String]:
	var snapshot := validated_first_bill_replay_snapshot(replay_snapshot)
	if snapshot.is_empty():
		return []
	var roots: Array = (snapshot.get("context", {}) as Dictionary).get(
		"roots", [])
	var result: Array[String] = []
	for raw_root in roots:
		var root_id := str(raw_root)
		if root_id == "v2_hyunsu_exam_morning_echo":
			result.append(root_id)
	return result

static func _first_bill_replay_state(snapshot: Dictionary) -> Dictionary:
	var state := _normalized_state({})
	var context: Dictionary = snapshot.get("context", {})
	state["demo_collision_context"] = context.duplicate(true)
	var dirty_source := str(context.get("dirty_source", "")).strip_edges()
	var raw_dirty: Variant = snapshot.get("dirty_receipt", {})
	if not dirty_source.is_empty() and raw_dirty is Dictionary:
		state["deferred_callback_receipts"][dirty_source] = (
			raw_dirty as Dictionary).duplicate(true)
	var raw_hyunsu: Variant = snapshot.get("hyunsu_receipt", {})
	if raw_hyunsu is Dictionary and not (raw_hyunsu as Dictionary).is_empty():
		state["future_story_receipts"][HYUNSU_EXAM_OUTCOME_RECEIPT_ID] = (
			raw_hyunsu as Dictionary).duplicate(true)
	var raw_obligation: Variant = snapshot.get("obligation_receipt", {})
	if raw_obligation is Dictionary \
			and not (raw_obligation as Dictionary).is_empty():
		state["obligation_receipts"]["demo_collision"] = (
			raw_obligation as Dictionary).duplicate(true)
	return state

static func _first_bill_father_memory_id(state: Dictionary) -> String:
	var found := ""
	for raw_receipt in state.get("relationship_memories", []):
		if not raw_receipt is Dictionary:
			continue
		var receipt: Dictionary = raw_receipt
		var memory_id := str(receipt.get("memory", "")).strip_edges()
		var choice_index := int(receipt.get("choice_index", -1))
		if str(receipt.get("character", "")) != "father" \
				or str(receipt.get("bundle_id", "")) != "father_health_signal" \
				or str(receipt.get("event_id", "")) \
					!= "v2_father_health_signal" \
				or int(receipt.get("turn", -1)) != 21 \
				or memory_id not in FIRST_BILL_FATHER_MEMORY_IDS:
			continue
		var outcome := _relationship_outcome_for_choice(
			"father_health_signal", "v2_father_health_signal", choice_index,
			state)
		if str(outcome.get("memory", "")) != memory_id:
			continue
		if not found.is_empty() and found != memory_id:
			return ""
		found = memory_id
	return found

static func _first_bill_cash_position_sentence(money: float) -> String:
	var arrears := maxf(0.0, -money)
	if arrears > 0.0:
		return LocaleManager.ui(
			"계좌 잔액은 %s이고, 밀린 비용은 %s이었다",
			"The account balance was %s, with %s in arrears") \
			% [GameState.format_money(0.0), GameState.format_money(arrears)]
	return LocaleManager.ui(
		"계좌 잔액은 %s이었다", "The account balance was %s") \
		% GameState.format_money(maxf(0.0, money))

static func first_bill_replay_player_name(
		replay_snapshot: Dictionary) -> String:
	var snapshot := validated_first_bill_replay_snapshot(replay_snapshot)
	return _first_bill_localized_player_name(str(snapshot.get(
		"player_name", ""))) if not snapshot.is_empty() else ""

static func _first_bill_localized_player_name(raw_name: String) -> String:
	var player_name := raw_name.strip_edges()
	return LocaleManager.localize_player_name(player_name)

static func _validated_demo_collision_context(
		state: Dictionary, require_current_turn: bool = true) -> Dictionary:
	var raw_context: Variant = state.get("demo_collision_context", {})
	if not raw_context is Dictionary or (raw_context as Dictionary).is_empty():
		return {}
	var context: Dictionary = raw_context
	var context_turn := int(context.get("turn", -1))
	if str(context.get("bundle_id", "")) != "demo_collision" \
			or context_turn != 24 \
			or (require_current_turn and context_turn != int(GameState.turn)) \
			or not context.get("roots", []) is Array \
			or not context.get("candidate_ids", []) is Array:
		return {}

	var dirty_source := str(context.get("dirty_source", "")).strip_edges()
	var dirty_root := str(context.get("dirty_root", "")).strip_edges()
	var expected_dirty_source := ""
	var expected_dirty_root := ""
	if bool(GameState.flags.get("escaped_dirty_money", false)):
		expected_dirty_source = "callback_escaped_dirty_trace"
		expected_dirty_root = "v2_dirty_trace_initial_call"
	elif bool(GameState.flags.get("fell_to_darkness", false)):
		expected_dirty_source = "fell_to_darkness"
		expected_dirty_root = "v2_dirty_recruiter_week24"
	if dirty_source.is_empty() != dirty_root.is_empty() \
			or dirty_source != expected_dirty_source \
			or dirty_root != expected_dirty_root \
			or dirty_root not in [
				"", "v2_dirty_trace_initial_call", "v2_dirty_recruiter_week24",
			]:
		return {}
	var expected_roots: Array[String] = []
	if not dirty_root.is_empty():
		var expected_source := (
			"callback_escaped_dirty_trace"
			if dirty_root == "v2_dirty_trace_initial_call"
			else "fell_to_darkness")
		if dirty_source != expected_source:
			return {}
		var raw_dirty_receipt: Variant = state[
			"deferred_callback_receipts"].get(dirty_source, {})
		if not raw_dirty_receipt is Dictionary:
			return {}
		var dirty_receipt: Dictionary = raw_dirty_receipt
		if str(dirty_receipt.get("source", "")) != dirty_source \
				or str(dirty_receipt.get("root", "")) != dirty_root \
				or int(dirty_receipt.get("claimed_turn", -1)) != context_turn \
				or str(dirty_receipt.get("status", "")) \
					not in ["claimed", "resolved"]:
			return {}
		if str(dirty_receipt.get("status", "")) == "resolved":
			var dirty_event: Dictionary = DataRegistry.find_event(dirty_root)
			var dirty_choices: Variant = dirty_event.get("choices", [])
			var dirty_choice_index := int(dirty_receipt.get("choice_index", -1))
			if str(dirty_receipt.get("event_id", "")) != dirty_root \
					or int(dirty_receipt.get("resolved_turn", -1)) \
						!= context_turn \
					or not dirty_choices is Array \
					or dirty_choice_index < 0 \
					or dirty_choice_index >= (dirty_choices as Array).size():
				return {}
		expected_roots.append(dirty_root)

	var finale := _first_bill_finale_contract()
	var raw_root_contract: Variant = finale.get("root_contract", {})
	if not raw_root_contract is Dictionary:
		return {}
	var opening_root := str((raw_root_contract as Dictionary).get(
		"opening_root", "")).strip_edges()
	if opening_root.is_empty() or DataRegistry.find_event(opening_root).is_empty():
		return {}
	expected_roots.append(opening_root)
	var roots: Array = context.get("roots", [])
	var hyunsu_expected: bool = state["completed_bundles"].has(
		"hyunsu_study_followup") \
		and str(state["relationship_stages"].get(
			"hyunsu", "unmet")) == "shared_commitment"
	if hyunsu_expected:
		var raw_hyunsu: Variant = state["future_story_receipts"].get(
			HYUNSU_EXAM_OUTCOME_RECEIPT_ID, {})
		if not raw_hyunsu is Dictionary \
				or not _hyunsu_exam_outcome_receipt_valid(
					raw_hyunsu as Dictionary):
			return {}
		expected_roots.append("v2_hyunsu_exam_morning_echo")
	if roots.size() != expected_roots.size():
		return {}
	for index in range(expected_roots.size()):
		if str(roots[index]) != expected_roots[index]:
			return {}

	var candidates := _first_bill_candidate_ids(
		state, context, require_current_turn)
	if candidates.size() < 2 or candidates.size() > 4 \
			or not candidates.has("father_call"):
		return {}
	var canonical_order := [
		"father_call", "hanbit_month_close", "city_work_sample",
		"daeun_checkin", "jaehyuk_reply", "sangchul_ledger",
		"urgent_paid_shift", "body_rest",
	]
	var expected_candidates: Array[String] = []
	for obligation_id in canonical_order:
		if candidates.has(obligation_id):
			expected_candidates.append(obligation_id)
	if candidates != expected_candidates:
		return {}
	var raw_obligation: Variant = state["obligation_receipts"].get(
		"demo_collision", {})
	if raw_obligation is Dictionary \
			and not (raw_obligation as Dictionary).is_empty():
		if _first_bill_obligation_receipt(
				state, context, candidates, finale).is_empty():
			return {}
	else:
		# Before the decision receipt exists, the frozen list must be the exact
		# list derived from this run. A canonical-looking subset would otherwise
		# let a damaged save silently erase one of the finale's real obligations.
		var live_candidates := _demo_collision_candidate_ids(state)
		if candidates != live_candidates:
			return {}
	return context.duplicate(true)

static func _first_bill_candidate_ids(
		state: Dictionary, context: Dictionary,
		require_current_turn: bool = true) -> Array[String]:
	if str(context.get("bundle_id", "")) != "demo_collision" \
			or int(context.get("turn", -1)) != 24 \
			or (require_current_turn \
				and int(context.get("turn", -1)) != int(GameState.turn)):
		return []
	return _first_bill_candidate_ids_from_raw(
		context.get("candidate_ids", []))

static func _first_bill_candidate_ids_from_raw(
		raw_candidates: Variant) -> Array[String]:
	if not raw_candidates is Array:
		return []
	var allowed: Dictionary = {}
	for raw_outcome in bundle("demo_collision").get(
			"obligation_outcomes", []):
		if raw_outcome is Dictionary:
			var obligation_id := str((raw_outcome as Dictionary).get(
				"selected_obligation_id", "")).strip_edges()
			if not obligation_id.is_empty():
				allowed[obligation_id] = true
	var candidates: Array[String] = []
	for raw_candidate in raw_candidates as Array:
		var candidate_id := str(raw_candidate).strip_edges()
		# Treat a corrupt or injected context as unusable instead of letting a
		# noncandidate line leak into the finale prose.
		if not allowed.has(candidate_id) or candidates.has(candidate_id):
			return []
		candidates.append(candidate_id)
	var canonical_order := [
		"father_call", "hanbit_month_close", "city_work_sample",
		"daeun_checkin", "jaehyuk_reply", "sangchul_ledger",
		"urgent_paid_shift", "body_rest",
	]
	var ordered: Array[String] = []
	for obligation_id in canonical_order:
		if candidates.has(obligation_id):
			ordered.append(obligation_id)
	if candidates != ordered:
		return []
	return candidates

static func _first_bill_obligation_receipt(
		state: Dictionary, context: Dictionary,
		candidates: Array[String], finale: Dictionary) -> Dictionary:
	var raw_root_contract: Variant = finale.get("root_contract", {})
	var root_contract: Dictionary = raw_root_contract \
		if raw_root_contract is Dictionary else {}
	var receipt_owner := str(root_contract.get(
		"receipt_owner", "demo_collision")).strip_edges()
	var decision_event := str(root_contract.get(
		"decision_event", "v2_demo_first_bill")).strip_edges()
	if receipt_owner != "demo_collision" or decision_event.is_empty():
		return {}
	var raw_receipt: Variant = state["obligation_receipts"].get(
		receipt_owner, {})
	if not raw_receipt is Dictionary:
		return {}
	var receipt: Dictionary = raw_receipt
	var raw_receipt_candidates: Variant = receipt.get("candidate_ids", [])
	var raw_deferred: Variant = receipt.get("deferred_obligation_ids", [])
	if str(receipt.get("bundle_id", "")) != receipt_owner \
			or str(receipt.get("event_id", "")) != decision_event \
			or int(receipt.get("turn", -1)) != int(context.get("turn", -2)) \
			or not raw_receipt_candidates is Array \
			or not raw_deferred is Array \
			or (raw_receipt_candidates as Array).size() != candidates.size():
		return {}
	for index in range(candidates.size()):
		if str((raw_receipt_candidates as Array)[index]) != candidates[index]:
			return {}
	var selected_id := str(receipt.get(
		"selected_obligation_id", "")).strip_edges()
	if not candidates.has(selected_id) \
			or _obligation_id_for_choice(
				receipt_owner, decision_event,
				int(receipt.get("choice_index", -1))) != selected_id:
		return {}
	var expected_deferred: Array[String] = []
	for candidate_id in candidates:
		if candidate_id != selected_id:
			expected_deferred.append(candidate_id)
	if (raw_deferred as Array).size() != expected_deferred.size():
		return {}
	for index in range(expected_deferred.size()):
		if str((raw_deferred as Array)[index]) != expected_deferred[index]:
			return {}
	return receipt.duplicate(true)

static func _first_bill_candidate_copy_lines(
		copy_contract: Dictionary, copy_kind: String,
		obligation_ids: Array[String]) -> String:
	var raw_section: Variant = copy_contract.get(copy_kind, {})
	if not raw_section is Dictionary:
		return ""
	var section: Dictionary = raw_section
	var lines: Array[String] = []
	for obligation_id in obligation_ids:
		var line: String = _first_bill_localized_copy(
			section.get(obligation_id, {}))
		if not line.is_empty():
			lines.append(line)
	return "\n".join(lines)

static func _first_bill_localized_copy(raw_copy: Variant) -> String:
	if not raw_copy is Dictionary:
		return ""
	return LocaleManager.ui(
		str((raw_copy as Dictionary).get("ko", "")),
		str((raw_copy as Dictionary).get("en", "")))

static func _first_bill_body_copy(
		finale: Dictionary, health: int = -1) -> String:
	var raw_checks: Variant = finale.get("body_check", [])
	if not raw_checks is Array:
		return ""
	var current_health := int(GameState.health) if health < 0 else health
	for raw_check in raw_checks as Array:
		if not raw_check is Dictionary:
			continue
		var check: Dictionary = raw_check
		if current_health <= int(check.get("max_health", 100)):
			return _first_bill_localized_copy(check.get("copy", {})).replace(
				"{health}", str(current_health))
	return ""

static func _first_bill_after_bills_copy(
		finale: Dictionary, cash: float = NAN,
		required_cash: float = NAN) -> String:
	var raw_copy: Variant = finale.get("after_bills_copy", {})
	if not raw_copy is Dictionary:
		return ""
	var copy_contract: Dictionary = raw_copy
	var actual_cash := float(GameState.money) if is_nan(cash) else cash
	var fixed_expense := float(GameState.get_monthly_required_cash()) \
		if is_nan(required_cash) else required_cash
	var after_bills := actual_cash - fixed_expense
	var copy_key := "covered"
	if actual_cash < 0.0:
		copy_key = "arrears"
	elif after_bills < 0.0:
		copy_key = "short"
	var result: String = _first_bill_localized_copy(
		copy_contract.get(copy_key, {}))
	return result \
		.replace("{cash}", GameState.format_money(maxf(0.0, actual_cash))) \
		.replace("{arrears}", GameState.format_money(maxf(0.0, -actual_cash))) \
		.replace("{fixed_expense}", GameState.format_money(fixed_expense)) \
		.replace("{after_bills}", GameState.format_money(absf(after_bills)))

static func _first_bill_trace_copy(
		state: Dictionary, context: Dictionary, finale: Dictionary) -> String:
	var dirty_source := str(context.get("dirty_source", "")).strip_edges()
	var dirty_root := str(context.get("dirty_root", "")).strip_edges()
	if dirty_source.is_empty() or dirty_root.is_empty():
		return ""
	var raw_receipt: Variant = state["deferred_callback_receipts"].get(
		dirty_source, {})
	if not raw_receipt is Dictionary:
		return ""
	var receipt: Dictionary = raw_receipt
	if str(receipt.get("source", "")) != dirty_source \
			or str(receipt.get("root", "")) != dirty_root \
			or int(receipt.get("claimed_turn", -1)) \
				!= int(context.get("turn", -2)) \
			or str(receipt.get("status", "")) not in ["claimed", "resolved"]:
		return ""
	var raw_trace_copy: Variant = finale.get("trace_copy", {})
	if not raw_trace_copy is Dictionary:
		return ""
	var raw_root_copy: Variant = (raw_trace_copy as Dictionary).get(
		dirty_root, {})
	if not raw_root_copy is Dictionary:
		return ""
	var root_copy: Dictionary = raw_root_copy
	if str(receipt.get("status", "")) == "resolved":
		var choice_index := int(receipt.get("choice_index", -1))
		var event: Dictionary = DataRegistry.find_event(dirty_root)
		var choices: Variant = event.get("choices", [])
		if str(receipt.get("event_id", "")) != dirty_root \
				or int(receipt.get("resolved_turn", -1)) \
					!= int(context.get("turn", -2)) \
				or not choices is Array or choice_index < 0 \
				or choice_index >= (choices as Array).size():
			return ""
		var raw_choices: Variant = root_copy.get("choices", {})
		if raw_choices is Dictionary:
			return _first_bill_localized_copy(
				(raw_choices as Dictionary).get(str(choice_index), {}))
	return _first_bill_localized_copy(root_copy.get("claimed", {}))

static func _first_bill_hyunsu_memory_copy(
		state: Dictionary, context: Dictionary, finale: Dictionary) -> String:
	var raw_roots: Variant = context.get("roots", [])
	if not raw_roots is Array \
			or not (raw_roots as Array).has("v2_hyunsu_exam_morning_echo"):
		return ""
	var raw_receipt: Variant = state["future_story_receipts"].get(
		HYUNSU_EXAM_OUTCOME_RECEIPT_ID, {})
	if not raw_receipt is Dictionary \
			or not _hyunsu_exam_outcome_receipt_valid(
				raw_receipt as Dictionary):
		return ""
	var raw_copy: Variant = finale.get("hyunsu_memory_copy", {})
	if not raw_copy is Dictionary:
		return ""
	var source_memory := str((raw_receipt as Dictionary).get(
		"source_memory", "")).strip_edges()
	return _first_bill_localized_copy(
		(raw_copy as Dictionary).get(source_memory, {}))

## 24주 보스의 실제 충돌 후보와 예약 콜백을 한 번만 확정한다.
## 이 함수가 성공한 뒤에는 저장/재진입 모두 같은 roots와 후보를 읽으며,
## 이미 인수한 예약 사건을 다시 큐에서 찾거나 제거하지 않는다.
static func prepare_demo_collision() -> Dictionary:
	var state := _normalized_state(GameState.core_loop_v2_state)
	if str(state.get("active_bundle", "")) != "demo_collision" \
			or str(state.get("active_kind", "")) != "schedule" \
			or int(state.get("active_turn", 0)) != int(GameState.turn) \
			or int(GameState.turn) != 24:
		return {"ok": false, "error": "demo_collision_owner_mismatch"}
	var raw_existing: Variant = state.get("demo_collision_context", {})
	if raw_existing is Dictionary \
			and not (raw_existing as Dictionary).is_empty():
		var existing := _validated_demo_collision_context(state)
		if existing.is_empty():
			return {"ok": false, "error": "invalid_demo_collision_context"}
		GameState.core_loop_v2_state = state
		return {
			"ok": true,
			"prepared": false,
			"context": existing.duplicate(true),
		}

	var roots: Array[String] = []

	var dirty_source := ""
	var dirty_root := ""
	if bool(GameState.flags.get("escaped_dirty_money", false)):
		dirty_source = "callback_escaped_dirty_trace"
		dirty_root = "v2_dirty_trace_initial_call"
		var raw_dirty_receipt: Variant = state[
			"deferred_callback_receipts"].get(dirty_source, {})
		if raw_dirty_receipt is Dictionary \
				and not (raw_dirty_receipt as Dictionary).is_empty():
			var existing_dirty: Dictionary = raw_dirty_receipt
			if str(existing_dirty.get("root", "")) != dirty_root \
					or int(existing_dirty.get("claimed_turn", -1)) != 24 \
					or str(existing_dirty.get("status", "")) \
						not in ["claimed", "resolved"]:
				return {"ok": false, "error": "invalid_dirty_callback_receipt"}
		else:
			var claimed := GameState.claim_deferred_event(
				"callback_escaped_dirty_trace", 24)
			if claimed.is_empty():
				return {"ok": false, "error": "missing_due_dirty_callback"}
			state["deferred_callback_receipts"][dirty_source] = {
				"source": dirty_source,
				"trigger_turn": int(claimed.get("trigger_turn", 24)),
				"claimed_turn": int(GameState.turn),
				"root": dirty_root,
				"status": "claimed",
				"synthetic": false,
			}
	elif bool(GameState.flags.get("fell_to_darkness", false)):
		dirty_source = "fell_to_darkness"
		dirty_root = "v2_dirty_recruiter_week24"
		state["deferred_callback_receipts"][dirty_source] = {
			"source": dirty_source,
			"trigger_turn": int(GameState.turn),
			"claimed_turn": int(GameState.turn),
			"root": dirty_root,
			"status": "claimed",
			"synthetic": true,
		}
	if not dirty_root.is_empty():
		roots.append(dirty_root)
	var raw_demo_roots: Variant = bundle(
		"demo_collision").get("existing_roots", [])
	if not raw_demo_roots is Array or (raw_demo_roots as Array).is_empty():
		return {"ok": false, "error": "missing_demo_collision_root"}
	var opening_root := str((raw_demo_roots as Array)[0]).strip_edges()
	if opening_root.is_empty() \
			or DataRegistry.find_event(opening_root).is_empty():
		return {"ok": false, "error": "missing_demo_collision_root"}
	roots.append(opening_root)
	# 금요일 18시 작업표 마감과 월말 선택을 먼저 닫은 뒤, 토요일 아침
	# 현수의 시험장 앞 장면으로 데모의 마지막 시간을 보낸다.
	if has_completed_bundle("hyunsu_study_followup") \
			and relationship_stage("hyunsu") == "shared_commitment":
		if not has_completed_bundle(str(
				_hyunsu_exam_contract().get(
					"producer_bundle", ""))):
			var unanswered_receipt := (
				_ensure_hyunsu_exam_outcome_receipt(
					state, true))
			if unanswered_receipt.is_empty():
				return {
					"ok": false,
					"error":
						"missing_hyunsu_unanswered_future_receipt",
				}
			state = _normalized_state(
				GameState.core_loop_v2_state)
		roots.append("v2_hyunsu_exam_morning_echo")

	var candidates := _demo_collision_candidate_ids(state)
	if candidates.is_empty() or not candidates.has("father_call"):
		return {"ok": false, "error": "missing_demo_collision_candidates"}
	var context := {
		"bundle_id": "demo_collision",
		"turn": int(GameState.turn),
		"roots": roots.duplicate(),
		"candidate_ids": candidates.duplicate(),
		"dirty_source": dirty_source,
		"dirty_root": dirty_root,
		"prepared": true,
	}
	state["demo_collision_context"] = context
	GameState.core_loop_v2_state = state
	return {
		"ok": true,
		"prepared": true,
		"context": context.duplicate(true),
	}

## Moves the frozen Week-24 root from the former standalone decision card to the
## new opening card even when the loaded save resumes in MainGame (or has
## already completed the demo). Only the exact legacy root shape is touched.
## A pre-decision context polluted by the old shared job_03 test is narrowly
## re-frozen only when removing Hanbit yields the exact current candidate list.
## Validation and assignment are atomic: a legacy-shaped but otherwise damaged
## context must remain byte-for-byte untouched so a later recovery path can
## still diagnose or handle the original payload.
static func migrate_legacy_first_bill_state() -> bool:
	var state := _normalized_state(GameState.core_loop_v2_state)
	var raw_context: Variant = state.get("demo_collision_context", {})
	if not raw_context is Dictionary or (raw_context as Dictionary).is_empty():
		return false
	var context: Dictionary = (raw_context as Dictionary).duplicate(true)
	if str(context.get("bundle_id", "")) != "demo_collision" \
			or int(context.get("turn", -1)) != 24:
		return false
	var raw_roots: Variant = context.get("roots", [])
	var candidates := _first_bill_candidate_ids_from_raw(
		context.get("candidate_ids", []))
	if not raw_roots is Array or candidates.size() < 2 \
			or not candidates.has("father_call"):
		return false
	var roots: Array = (raw_roots as Array).duplicate()
	var changed := false
	if roots.has(FIRST_BILL_DECISION_ID) \
			and not roots.has(FIRST_BILL_OPENING_ID):
		var expected_legacy_roots: Array[String] = []
		var dirty_root := str(context.get("dirty_root", "")).strip_edges()
		if not dirty_root.is_empty():
			expected_legacy_roots.append(dirty_root)
		expected_legacy_roots.append(FIRST_BILL_DECISION_ID)
		if roots.has("v2_hyunsu_exam_morning_echo"):
			expected_legacy_roots.append("v2_hyunsu_exam_morning_echo")
		if roots.size() != expected_legacy_roots.size():
			return false
		for index in range(expected_legacy_roots.size()):
			if str(roots[index]) != expected_legacy_roots[index]:
				return false
		for index in range(roots.size()):
			if str(roots[index]) == FIRST_BILL_DECISION_ID:
				roots[index] = FIRST_BILL_OPENING_ID
		context["roots"] = roots
		changed = true
	elif not roots.has(FIRST_BILL_OPENING_ID):
		return false

	var raw_obligation: Variant = state["obligation_receipts"].get(
		"demo_collision", {})
	if not raw_obligation is Dictionary:
		return false
	if not (raw_obligation as Dictionary).is_empty():
		if _first_bill_obligation_receipt(
				state, context, candidates,
				_first_bill_finale_contract()).is_empty():
			return false
	else:
		var live_candidates := _demo_collision_candidate_ids(state)
		if candidates != live_candidates and candidates.has(
				"hanbit_month_close") \
				and not has_hanbit_employment_provenance(state):
			var without_false_hanbit: Array[String] = []
			for candidate_id in candidates:
				if candidate_id != "hanbit_month_close":
					without_false_hanbit.append(candidate_id)
			if without_false_hanbit == live_candidates:
				context["candidate_ids"] = live_candidates.duplicate()
				candidates = live_candidates
				changed = true

	if changed:
		var migrated_state := state.duplicate(true)
		migrated_state["demo_collision_context"] = context
		if _validated_demo_collision_context(
				migrated_state, false).is_empty():
			return false
		GameState.core_loop_v2_state = migrated_state

	# A completed Week-25 legacy save has only post-choice body/cash values. The
	# decision receipt proves what was chosen, but it cannot reconstruct the
	# exact pre-choice frame shown in the archive. Preserve any snapshot captured
	# by the original story session, but never synthesize a new archive card from
	# an inverse of clamped or otherwise lossy effects.
	return changed

## 이전 playtest save는 decision을 Week-24 root로 저장했다. 새
## opening→decision→ledger 연속 장면으로 안전하게 옮기되, 이미 적용된 선택
## 결과는 절대 재적용하지 않는다. 알 수 없는/손상 payload는 건드리지 않는다.
static func migrate_legacy_first_bill_resume_context(
		resume_context: Dictionary) -> Dictionary:
	if str(resume_context.get("kind", "")) != "story" \
			or int(GameState.turn) != 24:
		return resume_context.duplicate(true)
	var original_state := GameState.core_loop_v2_state.duplicate(true)
	var before_state := _normalized_state(original_state)
	var raw_context: Variant = before_state.get("demo_collision_context", {})
	if not raw_context is Dictionary:
		return resume_context.duplicate(true)
	var legacy_context: Dictionary = raw_context as Dictionary
	var old_roots: Variant = (raw_context as Dictionary).get("roots", [])
	if not old_roots is Array \
			or not (old_roots as Array).has(FIRST_BILL_DECISION_ID) \
			or (old_roots as Array).has(FIRST_BILL_OPENING_ID):
		return resume_context.duplicate(true)

	# Preflight the saved story cursor before changing the run state. A valid
	# collision context can still be paired with a damaged resume payload; in
	# that case even the otherwise-safe decision→opening root migration must not
	# commit by itself.
	var event_id := str(resume_context.get("event_id", "")).strip_edges()
	var phase := str(resume_context.get("phase", "prose")).strip_edges()
	var raw_queue: Variant = resume_context.get("queue", [])
	if event_id.is_empty() or not (old_roots as Array).has(event_id) \
			or phase not in ["prose", "choices", "result"] \
			or not raw_queue is Array:
		return resume_context.duplicate(true)
	var legacy_candidates := _first_bill_candidate_ids(
		before_state, legacy_context)
	var legacy_receipt := _first_bill_obligation_receipt(
		before_state, legacy_context, legacy_candidates,
		_first_bill_finale_contract())
	var decision_root_index := (old_roots as Array).find(
		FIRST_BILL_DECISION_ID)
	var resume_root_index := (old_roots as Array).find(event_id)
	if resume_root_index >= 0 and resume_root_index < decision_root_index \
			and not legacy_receipt.is_empty():
		return resume_context.duplicate(true)
	if event_id == FIRST_BILL_DECISION_ID \
			and phase in ["prose", "choices"] \
			and not legacy_receipt.is_empty():
		return resume_context.duplicate(true)
	if (event_id == "v2_hyunsu_exam_morning_echo" \
			or (event_id == FIRST_BILL_DECISION_ID and phase == "result")) \
			and legacy_receipt.is_empty():
		return resume_context.duplicate(true)
	if event_id == FIRST_BILL_DECISION_ID and phase == "result":
		var raw_result_choice: Variant = resume_context.get(
			"pending_result_choice_index", null)
		if typeof(raw_result_choice) not in [TYPE_INT, TYPE_FLOAT]:
			return resume_context.duplicate(true)
		var result_choice_index := int(raw_result_choice)
		var decision_event: Dictionary = DataRegistry.find_event(
			FIRST_BILL_DECISION_ID)
		var raw_decision_choices: Variant = decision_event.get("choices", [])
		if not is_equal_approx(
				float(raw_result_choice), float(result_choice_index)) \
				or not raw_decision_choices is Array \
				or result_choice_index < 0 \
				or result_choice_index >= (raw_decision_choices as Array).size() \
				or result_choice_index != int(legacy_receipt.get(
					"choice_index", -1)):
			return resume_context.duplicate(true)
	if not migrate_legacy_first_bill_state():
		return resume_context.duplicate(true)
	var state := _normalized_state(GameState.core_loop_v2_state)
	var new_context := _validated_demo_collision_context(state)
	if new_context.is_empty():
		GameState.core_loop_v2_state = original_state
		return resume_context.duplicate(true)

	var migrated := resume_context.duplicate(true)
	var queue: Array = (raw_queue as Array).duplicate(true) \
		if raw_queue is Array else []
	for index in range(queue.size()):
		if str(queue[index]) == FIRST_BILL_DECISION_ID:
			queue[index] = FIRST_BILL_OPENING_ID
	migrated["queue"] = queue
	migrated["first_bill_legacy_migrated"] = true

	if event_id == FIRST_BILL_DECISION_ID:
		if phase in ["prose", "choices"]:
			migrated = _first_bill_legacy_rewind_to_opening(migrated, queue)
		elif phase == "result":
			var candidates := _first_bill_candidate_ids(state, new_context)
			var receipt := _first_bill_obligation_receipt(
				state, new_context, candidates, _first_bill_finale_contract())
			if receipt.is_empty():
				GameState.core_loop_v2_state = original_state
				return resume_context.duplicate(true)
			if not _first_bill_game_state_is_fatal():
				migrated["pending_follow_up"] = FIRST_BILL_LEDGER_ID
		return migrated

	if event_id == "v2_hyunsu_exam_morning_echo":
		var candidates := _first_bill_candidate_ids(state, new_context)
		var receipt := _first_bill_obligation_receipt(
			state, new_context, candidates, _first_bill_finale_contract())
		if receipt.is_empty():
			GameState.core_loop_v2_state = original_state
			return resume_context.duplicate(true)
		var post_ledger_resume := migrated.duplicate(true)
		post_ledger_resume["event_id"] = "v2_hyunsu_exam_morning_echo"
		var ledger_queue: Array = ["v2_hyunsu_exam_morning_echo"]
		for raw_id in queue:
			var queued_id := str(raw_id)
			if not queued_id.is_empty() and not ledger_queue.has(queued_id):
				ledger_queue.append(queued_id)
		migrated = _first_bill_legacy_minimal_resume(
			migrated, FIRST_BILL_LEDGER_ID, ledger_queue)
		migrated["first_bill_post_ledger_resume"] = post_ledger_resume
	return migrated

static func _first_bill_legacy_rewind_to_opening(
		resume_context: Dictionary, queue: Array) -> Dictionary:
	var trailing: Array = []
	for raw_id in queue:
		var event_id := str(raw_id)
		if event_id in [FIRST_BILL_OPENING_ID, FIRST_BILL_DECISION_ID]:
			continue
		if not event_id.is_empty() and not trailing.has(event_id):
			trailing.append(event_id)
	return _first_bill_legacy_minimal_resume(
		resume_context, FIRST_BILL_OPENING_ID, trailing)

static func _first_bill_legacy_minimal_resume(
		resume_context: Dictionary, event_id: String,
		queue: Array) -> Dictionary:
	return {
		"kind": "story",
		"event_id": event_id,
		"phase": "prose",
		"queue": queue.duplicate(true),
		"return_scene": str(resume_context.get(
			"return_scene", "res://scenes/MainGame.tscn")),
		"story_locale": str(resume_context.get(
			"story_locale", LocaleManager.language)),
		"first_bill_legacy_migrated": true,
	}

static func _first_bill_game_state_is_fatal() -> bool:
	return bool(GameState.is_game_over) \
		or int(GameState.health) <= 0 \
		or int(GameState.mental) <= 0 \
		or float(GameState.get_total_asset_value()) < -100_000_000.0 \
		or int(GameState.addiction_tendency) >= 90

static func story_choice_available(
		event_id: String, obligation_id: String) -> bool:
	var normalized_obligation := obligation_id.strip_edges()
	if event_id != "v2_demo_first_bill" \
			or normalized_obligation.is_empty():
		return false
	var state := _normalized_state(GameState.core_loop_v2_state)
	var context := _validated_demo_collision_context(state)
	if context.is_empty():
		return false
	return str(context.get("bundle_id", "")) == "demo_collision" \
		and int(context.get("turn", -1)) == int(GameState.turn) \
		and context.get("candidate_ids", []) is Array \
		and (context.get("candidate_ids", []) as Array).has(
			normalized_obligation)

## Week-24 exact callback choices must prove their claimed transport before
## StoryMode applies any authored effect. Other story choices retain their
## existing availability contract.
static func story_choice_commit_available(
		event_id: String, choice_index: int,
		reserved_queue: Array = []) -> bool:
	if event_id == OPENING_APPLICATION_EVENT_ID:
		return _legacy_preplan_opening_send_available(
			_normalized_state(GameState.core_loop_v2_state),
			event_id, choice_index, reserved_queue)
	if event_id not in EXACT_DEFERRED_CHOICE_ROOTS:
		return true
	var state := _normalized_state(GameState.core_loop_v2_state)
	return _exact_deferred_story_choice_matches(
		state, event_id, choice_index, false)

static func _demo_collision_candidate_ids(state: Dictionary) -> Array[String]:
	var priority: Array[String] = ["father_call"]
	if application_status("city_facility_ops_2026h1") == "submitted" \
			and _consequence_was_presented(
				state, "m6_city_service_response"):
		priority.append("city_work_sample")
	if has_hanbit_employment_provenance(state):
		priority.append("hanbit_month_close")
	var person_obligation := _demo_person_obligation(state)
	if not person_obligation.is_empty():
		priority.append(person_obligation)
	if GameState.current_job.is_empty():
		priority.append("urgent_paid_shift")
	priority.append("body_rest")

	var selected: Array[String] = []
	for obligation_id in priority:
		if not selected.has(obligation_id) and selected.size() < 4:
			selected.append(obligation_id)
	var canonical_order := [
		"father_call",
		"hanbit_month_close",
		"city_work_sample",
		"daeun_checkin",
		"jaehyuk_reply",
		"sangchul_ledger",
		"urgent_paid_shift",
		"body_rest",
	]
	var ordered: Array[String] = []
	for obligation_id in canonical_order:
		if selected.has(obligation_id):
			ordered.append(obligation_id)
	return ordered

static func has_hanbit_employment_provenance(
		raw_state: Dictionary = {}) -> bool:
	var state := _normalized_state(
		raw_state if not raw_state.is_empty() \
		else GameState.core_loop_v2_state)
	if str(GameState.current_job.get("id", "")) != "job_03" \
			or str(state["application_statuses"].get(
				"hanbit_ops_2026q1", "")) != "resolved":
		return false
	var expected_key := \
		"m5_hanbit_offer_message:v2_hanbit_offer_message:0:17"
	var raw_receipts: Variant = state.get(
		"application_transition_receipts", {})
	if not raw_receipts is Dictionary \
			or not (raw_receipts as Dictionary).has(expected_key):
		return false
	var raw_expected: Variant = (raw_receipts as Dictionary).get(
		expected_key, {})
	if not raw_expected is Dictionary:
		return false
	var expected: Dictionary = raw_expected
	if str(expected.get("receipt_key", "")) != expected_key \
			or str(expected.get("application_id", "")) \
				!= "hanbit_ops_2026q1" \
			or str(expected.get("from", "")) != "interviewed" \
			or str(expected.get("to", "")) != "resolved" \
			or str(expected.get("bundle_id", "")) \
				!= "m5_hanbit_offer_message" \
			or str(expected.get("event_id", "")) \
				!= "v2_hanbit_offer_message" \
			or int(expected.get("choice_index", -1)) != 0 \
			or int(expected.get("turn", -1)) != 17:
		return false
	# A second terminal receipt for the same Week-17 offer can only be damaged
	# or injected state. Never guess whether acceptance or refusal was real.
	for raw_key in raw_receipts as Dictionary:
		var raw_receipt: Variant = (raw_receipts as Dictionary).get(raw_key, {})
		if not raw_receipt is Dictionary:
			continue
		var receipt: Dictionary = raw_receipt
		var same_terminal_offer: bool = str(receipt.get(
			"bundle_id", "")) == "m5_hanbit_offer_message" \
			or str(receipt.get("event_id", "")) \
				== "v2_hanbit_offer_message" \
			or (str(receipt.get("application_id", "")) \
					== "hanbit_ops_2026q1" \
				and int(receipt.get("turn", -1)) == 17 \
				and str(receipt.get("to", "")) == "resolved")
		if same_terminal_offer and str(raw_key) != expected_key:
			return false
	return true

static func _demo_person_obligation(state: Dictionary) -> String:
	if has_completed_bundle("daeun_shared_dream") \
			and not _has_relationship_memory(
				state, "daeun", "daeun_same_tuesday_promised") \
			and _has_relationship_memory(
				state, "daeun", "daeun_late_meal_promised"):
		return "daeun_checkin"
	if has_completed_bundle("jaehyuk_plain_reunion_echo") \
			and (
				_has_relationship_memory(
					state, "jaehyuk", "jaehyuk_reunion_warm")
				or _has_relationship_memory(
					state, "jaehyuk", "jaehyuk_reunion_guarded")
			):
		return "jaehyuk_reply"
	if has_completed_bundle("sangchul_second_coffee") \
			and (
				_has_relationship_memory(
					state, "sangchul", "sangchul_own_pace_stated")
				or _has_relationship_memory(
					state, "sangchul", "sangchul_numbers_first_recorded")
			):
		return "sangchul_ledger"
	return ""

static func _has_relationship_memory(
		state: Dictionary, character_id: String, memory_id: String) -> bool:
	for raw_receipt in state["relationship_memories"]:
		if raw_receipt is Dictionary \
				and str((raw_receipt as Dictionary).get(
					"character", "")) == character_id \
				and str((raw_receipt as Dictionary).get(
					"memory", "")) == memory_id:
			return true
	return false

static func _consequence_was_presented(
		state: Dictionary, consequence_id: String) -> bool:
	var raw_receipt: Variant = state["consequence_receipts"].get(
		consequence_id, {})
	if raw_receipt is Dictionary \
		and str((raw_receipt as Dictionary).get(
			"consequence_id", "")) == consequence_id \
		and str((raw_receipt as Dictionary).get(
			"status", "")) in ["presented", "consumed"]:
		return true

	# Seoul Cycle world beats intentionally complete through the schedule
	# transaction so the player's allocation and its world response share one
	# weekly ledger.  They therefore own a cycle world receipt rather than a
	# legacy consequence receipt.  Accept only a resolved receipt whose saved
	# calendar position is internally consistent and whose bundle was authored
	# for that exact month/week; do not infer presentation from completed bundle
	# ids alone.
	var raw_cycle: Variant = state.get(SEOUL_CYCLE_STATE_KEY, {})
	if not raw_cycle is Dictionary:
		return false
	var cycle: Dictionary = raw_cycle
	var month := int(cycle.get("month", 0))
	if month < 1:
		return false
	var raw_world_receipts: Variant = cycle.get("world_receipts", {})
	if not raw_world_receipts is Dictionary:
		return false
	for raw_receipt_key in (raw_world_receipts as Dictionary):
		var raw_world_receipt: Variant = (
			raw_world_receipts as Dictionary).get(raw_receipt_key, {})
		if not raw_world_receipt is Dictionary:
			continue
		var world_receipt: Dictionary = raw_world_receipt
		var turn := int(world_receipt.get("turn", 0))
		var week_index := int(world_receipt.get("week_index", 0))
		if str(world_receipt.get("bundle_id", "")) == consequence_id \
				and str(world_receipt.get("status", "")) == "resolved" \
				and str(raw_receipt_key) == str(week_index) \
				and int(world_receipt.get("claimed_turn", 0)) == turn \
				and int(world_receipt.get("resolved_turn", 0)) == turn \
				and turn == _seoul_cycle_month_start_turn(month) \
					+ week_index - 1 \
				and _seoul_cycle_world_bundle_authored_for_week(
					month, week_index, consequence_id):
			return true
	return false

static func consequence_receipt_has_root(
		consequence_id: String, root_id: String) -> bool:
	var normalized_consequence := consequence_id.strip_edges()
	var normalized_root := root_id.strip_edges()
	if normalized_consequence.is_empty() or normalized_root.is_empty():
		return false
	var raw_receipts: Variant = GameState.core_loop_v2_state.get(
		"consequence_receipts", {})
	if not raw_receipts is Dictionary:
		return false
	var raw_receipt: Variant = (raw_receipts as Dictionary).get(
		normalized_consequence, {})
	if not raw_receipt is Dictionary \
			or str((raw_receipt as Dictionary).get(
				"status", "")) not in ["presented", "consumed"]:
		return false
	var raw_roots: Variant = (raw_receipt as Dictionary).get("roots", [])
	return raw_roots is Array and (raw_roots as Array).has(normalized_root)

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

static func note_story_choice(
		event_id: String, choice_index: int,
		reserved_queue: Array = []) -> bool:
	# ORDER-101 fresh runs never show the old Story Send. Only an exact legacy
	# queue may restore that state-free click's application/consequence owner.
	if claim_legacy_preplan_opening_from_send(
			event_id, choice_index, reserved_queue):
		return true
	# Preserve already-materialized pre-ORDER-101 choices whose old authored
	# flags were applied before this runtime hook.
	if claim_preplan_opening_from_trigger(event_id, choice_index):
		return true
	var state := _normalized_state(GameState.core_loop_v2_state)
	# Expression choices are dialogue-local branches. Validate that the exact
	# authored choice belongs to the active story owner, then acknowledge it
	# without creating any V2 receipt or assigning the normalized state back.
	var expression_event: Dictionary = DataRegistry.find_event(event_id)
	var expression_choices: Variant = expression_event.get("choices", [])
	if not expression_event.is_empty() \
			and expression_choices is Array \
			and choice_index >= 0 \
			and choice_index < (expression_choices as Array).size() \
			and (expression_choices as Array)[choice_index] is Dictionary \
			and GameState.is_expression_choice(
				(expression_choices as Array)[choice_index]):
		var active_owner := str(
			state.get("active_bundle", "")).strip_edges()
		var active_kind := str(
			state.get("active_kind", "")).strip_edges()
		return not active_owner.is_empty() \
			and active_kind in ["schedule", "consequence"] \
			and int(state.get("active_turn", 0)) == int(GameState.turn) \
			and _bundle_story_event_ids(active_owner).has(event_id)
	if event_id == "v2_demo_first_bill":
		var selected_obligation := _obligation_id_for_choice(
			"demo_collision", event_id, choice_index)
		if selected_obligation.is_empty() \
				or not story_choice_available(
					event_id, selected_obligation):
			return false
	var expects_deferred := _story_choice_is_deferred_callback(
		state, event_id)
	var expects_obligation := _story_choice_declares_outcome(
		state, event_id, choice_index, "obligation_outcomes")
	var expects_relationship := _story_choice_declares_outcome(
		state, event_id, choice_index, "relationship_outcomes")
	var expects_application := _story_choice_declares_outcome(
		state, event_id, choice_index, "application_outcomes")
	var story_recorded := _note_generic_story_choice(
		state, event_id, choice_index)
	if not story_recorded:
		return false
	state = _normalized_state(GameState.core_loop_v2_state)
	var deferred_recorded := _note_deferred_callback_story_choice(
		state, event_id, choice_index)
	if deferred_recorded:
		state = _normalized_state(GameState.core_loop_v2_state)
	var obligation_recorded := _note_obligation_story_choice(
		state, event_id, choice_index)
	if obligation_recorded:
		state = _normalized_state(GameState.core_loop_v2_state)
	var relationship_recorded := _note_relationship_story_choice(
		state, event_id, choice_index)
	if relationship_recorded:
		state = _normalized_state(GameState.core_loop_v2_state)
		var hyunsu_exam_spec := _hyunsu_exam_contract()
		if not hyunsu_exam_spec.is_empty() \
				and str(state.get("active_bundle", "")) \
					== str(hyunsu_exam_spec["producer_bundle"]):
			_ensure_hyunsu_exam_outcome_receipt(state)
			state = _normalized_state(GameState.core_loop_v2_state)
	var application_recorded := _note_application_story_choice(
		state, event_id, choice_index)
	if expects_deferred and not deferred_recorded:
		return false
	if expects_obligation and not obligation_recorded:
		return false
	if expects_relationship and not relationship_recorded:
		return false
	if expects_application and not application_recorded:
		return false
	return story_recorded

static func _ensure_hyunsu_exam_outcome_receipt(
		state: Dictionary,
		allow_unanswered: bool = false) -> Dictionary:
	var spec := _hyunsu_exam_contract()
	if spec.is_empty():
		return {}
	var raw_existing: Variant = state["future_story_receipts"].get(
		HYUNSU_EXAM_OUTCOME_RECEIPT_ID, {})
	if raw_existing is Dictionary \
			and _hyunsu_exam_outcome_receipt_valid(
				raw_existing as Dictionary):
		return (raw_existing as Dictionary).duplicate(true)
	var source_memory := ""
	var source_kind := "relationship_memory"
	for memory_id in spec["required_memories"]:
		if _has_relationship_memory(state, "hyunsu", memory_id):
			source_memory = memory_id
			break
	if source_memory.is_empty() and allow_unanswered \
			and bool(state.get("enabled", false)) \
			and int(GameState.turn) == int(spec["exam_week"]) \
			and state["completed_bundles"].has(
				"hyunsu_study_followup") \
			and not state["completed_bundles"].has(
				str(spec["producer_bundle"])):
		source_memory = str(spec["unanswered_source"])
		source_kind = "declined"
	if source_memory.is_empty():
		return {}
	# The chapter-one spine owns failure, drift, and the later new path. V2's
	# last-night choice changes how that failure is remembered, not the score.
	# The result stays unavailable through Weeks 25–26 and opens in Week 27.
	var receipt := {
		"receipt_id": HYUNSU_EXAM_OUTCOME_RECEIPT_ID,
		"character": "hyunsu",
		"producer_bundle": str(spec["producer_bundle"]),
		"source_memory": source_memory,
		"source_kind": source_kind,
		"outcome": str(spec["canonical_outcome"]),
		"recorded_turn": int(GameState.turn),
		"exam_turn": int(spec["exam_week"]),
		"available_turn": int(spec["result_available_week"]),
		"result_event": str(spec["result_event"]),
	}
	if source_kind == "declined":
		receipt["decline_outcome"] = str(
			spec["decline_outcome"])
	state["future_story_receipts"][
		HYUNSU_EXAM_OUTCOME_RECEIPT_ID] = receipt
	GameState.core_loop_v2_state = state
	return receipt.duplicate(true)

static func _recover_missing_hyunsu_exam_outcome_receipt(
		state: Dictionary) -> Dictionary:
	var spec := _hyunsu_exam_contract()
	if spec.is_empty() \
			or int(GameState.turn) <= int(spec["exam_week"]):
		return {}
	# An exact choice memory is already durable proof of the Week-23 reply,
	# even when a partial save lost the derived future-story receipt.
	var source_memory := ""
	var source_kind := "relationship_memory"
	for memory_id in spec["required_memories"]:
		if _has_relationship_memory(state, "hyunsu", memory_id):
			source_memory = str(memory_id)
			break
	# With no choice memory, infer "unanswered" only after the deadline and only
	# from the completed shared-study route. If the Month-6 plan survived, its
	# explicit forgone record is required; a scheduled-but-incomplete producer
	# stays ambiguous and must not be rewritten as a decline.
	if source_memory.is_empty() \
			and _hyunsu_unanswered_recovery_is_proven(state, spec):
		source_memory = str(spec["unanswered_source"])
		source_kind = "declined"
	if source_memory.is_empty():
		return {}
	var exam_turn := int(spec["exam_week"])
	var receipt := {
		"receipt_id": HYUNSU_EXAM_OUTCOME_RECEIPT_ID,
		"character": "hyunsu",
		"producer_bundle": str(spec["producer_bundle"]),
		"source_memory": source_memory,
		"source_kind": source_kind,
		"outcome": str(spec["canonical_outcome"]),
		# Recovery restores the canonical exam checkpoint; it does not invent
		# a new event in whichever later week happened to load the save.
		"recorded_turn": exam_turn,
		"exam_turn": exam_turn,
		"available_turn": int(spec["result_available_week"]),
		"result_event": str(spec["result_event"]),
	}
	if source_kind == "declined":
		receipt["decline_outcome"] = str(spec["decline_outcome"])
	state["future_story_receipts"][
		HYUNSU_EXAM_OUTCOME_RECEIPT_ID] = receipt
	GameState.core_loop_v2_state = state
	return receipt.duplicate(true)

static func _hyunsu_unanswered_recovery_is_proven(
		state: Dictionary, spec: Dictionary) -> bool:
	var producer_bundle := str(spec["producer_bundle"])
	if not bool(state.get("enabled", false)) \
			or not state["completed_bundles"].has(
				"hyunsu_study_followup") \
			or str(state["relationship_stages"].get(
				"hyunsu", "")) != "shared_commitment" \
			or state["completed_bundles"].has(producer_bundle):
		return false
	if _forgone_bundle_recorded(
			state.get("forgone", []), producer_bundle):
		return true
	var month_key := str(month_for_turn(int(spec["exam_week"])))
	var raw_plan: Variant = state["plans"].get(month_key, {})
	if raw_plan is Dictionary \
			and not (raw_plan as Dictionary).is_empty():
		return _forgone_bundle_recorded(
			(raw_plan as Dictionary).get("forgone", []),
			producer_bundle)
	# Older partial saves may retain the completed relationship route but lose
	# the Month-6 plan. Past the Week-23 deadline, absence of the producer is
	# then sufficient only because both eligibility proofs above survived.
	return true

static func _forgone_bundle_recorded(
		raw_records: Variant, bundle_id: String) -> bool:
	if not raw_records is Array:
		return false
	for raw_record in raw_records as Array:
		if raw_record is Dictionary \
				and str((raw_record as Dictionary).get(
					"bundle_id", "")) == bundle_id:
			return true
	return false

static func _hyunsu_exam_outcome_receipt_valid(
		receipt: Dictionary) -> bool:
	var spec := _hyunsu_exam_contract()
	if spec.is_empty():
		return false
	var source_memory := str(receipt.get(
		"source_memory", ""))
	var source_kind := str(receipt.get(
		"source_kind", ""))
	var selected_memory := (
		spec["required_memories"] as Array
	).has(source_memory)
	var unanswered := source_memory \
		== str(spec["unanswered_source"])
	var source_valid := (
		selected_memory
			and source_kind == "relationship_memory"
	) or (
		unanswered
			and source_kind == "declined"
			and str(receipt.get("decline_outcome", "")) \
				== str(spec["decline_outcome"])
	)
	return str(receipt.get("receipt_id", "")) \
			== HYUNSU_EXAM_OUTCOME_RECEIPT_ID \
		and str(receipt.get("character", "")) == "hyunsu" \
		and str(receipt.get("producer_bundle", "")) \
			== str(spec["producer_bundle"]) \
		and source_valid \
		and str(receipt.get("outcome", "")) \
			== str(spec["canonical_outcome"]) \
		and int(receipt.get("recorded_turn", 0)) >= 1 \
		and int(receipt.get("exam_turn", 0)) \
			== int(spec["exam_week"]) \
		and int(receipt.get("available_turn", 0)) \
			== int(spec["result_available_week"]) \
		and str(receipt.get("result_event", "")) \
			== str(spec["result_event"])

static func _ensure_city_result_receipt(
		state: Dictionary,
		selected_obligation: String,
		event_id: String,
		choice_index: int) -> Dictionary:
	var spec := _city_result_contract()
	if spec.is_empty() \
			or selected_obligation \
				!= str(spec["selected_obligation_id"]) \
			or event_id != str(spec["producer_event"]) \
			or choice_index != int(spec["producer_choice"]) \
			or int(GameState.turn) != 24 \
			or str(state["application_statuses"].get(
				str(spec["application_id"]), "")) \
				!= str(spec["from"]):
		return {}
	var raw_existing: Variant = state[
		"future_application_receipts"].get(
			CITY_RESULT_RECEIPT_ID, {})
	if raw_existing is Dictionary \
			and _city_result_receipt_valid(
				raw_existing as Dictionary):
		return (raw_existing as Dictionary).duplicate(true)
	var receipt := {
		"receipt_id": CITY_RESULT_RECEIPT_ID,
		"application_id": str(spec["application_id"]),
		"producer_bundle": str(spec["producer_bundle"]),
		"producer_event": event_id,
		"producer_choice": choice_index,
		"selected_obligation_id": selected_obligation,
		"from": str(spec["from"]),
		"to": str(spec["to"]),
		"recorded_turn": int(GameState.turn),
		"available_turn": int(spec["not_before_week"]),
		"result_event": str(spec["result_event"]),
		"status": "pending",
	}
	state["future_application_receipts"][
		CITY_RESULT_RECEIPT_ID] = receipt
	GameState.core_loop_v2_state = state
	return receipt.duplicate(true)

static func _recover_missing_city_result_receipt(
		state: Dictionary) -> Dictionary:
	var spec := _city_result_contract()
	if spec.is_empty() \
			or int(GameState.turn) <= 24 \
			or str(state["application_statuses"].get(
				str(spec["application_id"]), "")) \
				!= str(spec["from"]):
		return {}
	var raw_obligation: Variant = state["obligation_receipts"].get(
		str(spec["producer_bundle"]), {})
	if not raw_obligation is Dictionary \
			or not _exact_city_obligation_receipt_matches(
				raw_obligation as Dictionary, spec):
		return {}
	var receipt := {
		"receipt_id": CITY_RESULT_RECEIPT_ID,
		"application_id": str(spec["application_id"]),
		"producer_bundle": str(spec["producer_bundle"]),
		"producer_event": str(spec["producer_event"]),
		"producer_choice": int(spec["producer_choice"]),
		"selected_obligation_id":
			str(spec["selected_obligation_id"]),
		"from": str(spec["from"]),
		"to": str(spec["to"]),
		"recorded_turn": 24,
		"available_turn": int(spec["not_before_week"]),
		"result_event": str(spec["result_event"]),
		"status": "pending",
	}
	state["future_application_receipts"][
		CITY_RESULT_RECEIPT_ID] = receipt
	GameState.core_loop_v2_state = state
	return receipt.duplicate(true)

static func _exact_city_obligation_receipt_matches(
		receipt: Dictionary, spec: Dictionary) -> bool:
	var raw_candidates: Variant = receipt.get("candidate_ids", [])
	var raw_deferred: Variant = receipt.get(
		"deferred_obligation_ids", [])
	if not raw_candidates is Array or not raw_deferred is Array:
		return false
	var candidates: Array[String] = []
	for raw_candidate in raw_candidates as Array:
		var candidate_id := str(raw_candidate).strip_edges()
		if candidate_id.is_empty() or candidates.has(candidate_id):
			return false
		candidates.append(candidate_id)
	var expected_selected := str(spec["selected_obligation_id"])
	var expected_deferred: Array[String] = []
	for candidate_id in candidates:
		if candidate_id != expected_selected:
			expected_deferred.append(candidate_id)
	var deferred: Array[String] = []
	for raw_deferred_id in raw_deferred as Array:
		deferred.append(str(raw_deferred_id).strip_edges())
	return str(receipt.get("bundle_id", "")) \
				== str(spec["producer_bundle"]) \
			and str(receipt.get("event_id", "")) \
				== str(spec["producer_event"]) \
			and int(receipt.get("turn", 0)) == 24 \
			and int(receipt.get("choice_index", -1)) \
				== int(spec["producer_choice"]) \
			and str(receipt.get(
				"selected_obligation_id", "")) \
				== expected_selected \
			and candidates.has(expected_selected) \
			and deferred == expected_deferred

static func _city_result_receipt_valid(
		receipt: Dictionary) -> bool:
	var spec := _city_result_contract()
	if spec.is_empty():
		return false
	return str(receipt.get("receipt_id", "")) \
			== CITY_RESULT_RECEIPT_ID \
		and str(receipt.get("application_id", "")) \
			== str(spec["application_id"]) \
		and str(receipt.get("producer_bundle", "")) \
			== str(spec["producer_bundle"]) \
		and str(receipt.get("producer_event", "")) \
			== str(spec["producer_event"]) \
		and int(receipt.get("producer_choice", -1)) \
			== int(spec["producer_choice"]) \
		and str(receipt.get(
			"selected_obligation_id", "")) \
			== str(spec["selected_obligation_id"]) \
		and str(receipt.get("from", "")) \
			== str(spec["from"]) \
		and str(receipt.get("to", "")) \
			== str(spec["to"]) \
		and int(receipt.get("recorded_turn", 0)) == 24 \
		and int(receipt.get("available_turn", 0)) \
			== int(spec["not_before_week"]) \
		and str(receipt.get("result_event", "")) \
			== str(spec["result_event"]) \
		and str(receipt.get("status", "")) \
			in ["pending", "resolved"]

static func _story_choice_declares_outcome(
		state: Dictionary, event_id: String, choice_index: int,
		outcome_field: String) -> bool:
	var owner_id := _story_outcome_owner_id(
		state, event_id, outcome_field)
	if owner_id.is_empty():
		return false
	var raw_outcomes: Variant = bundle(owner_id).get(
		outcome_field, [])
	if not raw_outcomes is Array:
		return false
	for raw_outcome in raw_outcomes:
		if raw_outcome is Dictionary \
				and _outcome_runtime_applicable(
					state, owner_id, raw_outcome as Dictionary) \
				and str((raw_outcome as Dictionary).get(
					"event_id", "")) == event_id \
				and _outcome_choice_matches(
					raw_outcome as Dictionary, choice_index):
			return true
	return false

static func _story_choice_is_deferred_callback(
		state: Dictionary, event_id: String) -> bool:
	for raw_receipt in state["deferred_callback_receipts"].values():
		if raw_receipt is Dictionary \
				and str((raw_receipt as Dictionary).get(
					"root", "")) == event_id:
			return true
	return false

static func _exact_deferred_story_choice_matches(
		state: Dictionary,
		event_id: String,
		choice_index: int,
		allow_resolved: bool) -> bool:
	if event_id not in EXACT_DEFERRED_CHOICE_ROOTS \
			or str(state.get("active_bundle", "")) != "demo_collision" \
			or str(state.get("active_kind", "")) != "schedule" \
			or int(state.get("active_turn", 0)) != int(GameState.turn) \
			or int(GameState.turn) != 24:
		return false
	var event: Dictionary = DataRegistry.find_event(event_id)
	var choices: Variant = event.get("choices", [])
	if event.is_empty() or not choices is Array \
			or choice_index < 0 or choice_index >= (choices as Array).size() \
			or not (choices as Array)[choice_index] is Dictionary:
		return false
	var context := _validated_demo_collision_context(state)
	if context.is_empty() \
			or str(context.get("dirty_root", "")) != event_id:
		return false
	var source := str(context.get("dirty_source", "")).strip_edges()
	var raw_receipt: Variant = state["deferred_callback_receipts"].get(
		source, {})
	if source.is_empty() or not raw_receipt is Dictionary:
		return false
	var receipt: Dictionary = raw_receipt
	var raw_synthetic: Variant = receipt.get("synthetic", null)
	var expected_synthetic := source == "fell_to_darkness"
	if str(receipt.get("source", "")) != source \
			or str(receipt.get("root", "")) != event_id \
			or int(receipt.get("trigger_turn", -1)) != 24 \
			or int(receipt.get("claimed_turn", -1)) != int(GameState.turn) \
			or not raw_synthetic is bool \
			or bool(raw_synthetic) != expected_synthetic:
		return false
	var status := str(receipt.get("status", ""))
	if status == "claimed":
		return true
	return allow_resolved and status == "resolved" \
		and str(receipt.get("event_id", "")) == event_id \
		and int(receipt.get("choice_index", -1)) == choice_index \
		and int(receipt.get("resolved_turn", -1)) == int(GameState.turn)

static func _note_generic_story_choice(
		state: Dictionary, event_id: String, choice_index: int) -> bool:
	var owner_id := str(state.get("active_bundle", "")).strip_edges()
	var owner_kind := str(state.get("active_kind", "")).strip_edges()
	var owner_turn := int(state.get("active_turn", 0))
	if owner_id.is_empty() or owner_kind not in ["schedule", "consequence"] \
			or owner_turn != int(GameState.turn) \
			or event_id.is_empty() or choice_index < 0:
		return false
	var event: Dictionary = DataRegistry.find_event(event_id)
	var choices: Variant = event.get("choices", [])
	if event.is_empty() or not choices is Array \
			or choice_index >= (choices as Array).size():
		return false
	var raw_choice: Variant = (choices as Array)[choice_index]
	if not raw_choice is Dictionary:
		return false
	var initiated_character := str(
		(raw_choice as Dictionary).get(
			"v2_player_initiated_character", "")).strip_edges()
	if not initiated_character.is_empty() \
			and not GameState.cast.has(initiated_character):
		return false
	# Validate the live owner/event/choice above, then require the exact callback
	# transport. Do not fall through to a generic receipt when that transport is
	# absent or corrupt. Existing generic receipts in old saves remain inert and
	# untouched because normalization deliberately preserves them.
	if event_id in EXACT_DEFERRED_CHOICE_ROOTS:
		return _exact_deferred_story_choice_matches(
			state, event_id, choice_index, true)
	var receipt_key := "%s:%s:%d:%d" % [
		owner_id, event_id, choice_index, int(GameState.turn)]
	var raw_existing: Variant = state["story_choice_receipts"].get(
		receipt_key, {})
	if raw_existing is Dictionary \
			and not (raw_existing as Dictionary).is_empty():
		var existing: Dictionary = (
			raw_existing as Dictionary).duplicate(true)
		var exact_match := str(existing.get("bundle_id", "")) == owner_id \
			and str(existing.get("active_kind", "")) == owner_kind \
			and str(existing.get("event_id", "")) == event_id \
			and int(existing.get("choice_index", -1)) == choice_index \
			and int(existing.get("turn", -1)) == int(GameState.turn)
		if not exact_match:
			return false
		if not initiated_character.is_empty():
			var stored_character := str(existing.get(
				"player_initiated_character", "")).strip_edges()
			if not stored_character.is_empty() \
					and stored_character != initiated_character:
				return false
			existing["player_initiated_character"] = initiated_character
			state["story_choice_receipts"][receipt_key] = existing
			if not state["player_initiated"].has(initiated_character):
				state["player_initiated"].append(initiated_character)
			GameState.core_loop_v2_state = state
		return true
	var receipt := {
		"receipt_key": receipt_key,
		"bundle_id": owner_id,
		"active_kind": owner_kind,
		"event_id": event_id,
		"choice_index": choice_index,
		"turn": int(GameState.turn),
	}
	if not initiated_character.is_empty():
		receipt["player_initiated_character"] = initiated_character
		if not state["player_initiated"].has(initiated_character):
			state["player_initiated"].append(initiated_character)
	state["story_choice_receipts"][receipt_key] = receipt
	GameState.core_loop_v2_state = state
	return true

static func _note_deferred_callback_story_choice(
		state: Dictionary, event_id: String, choice_index: int) -> bool:
	if event_id in EXACT_DEFERRED_CHOICE_ROOTS:
		if not _exact_deferred_story_choice_matches(
				state, event_id, choice_index, true):
			return false
		var context := _validated_demo_collision_context(state)
		var source := str(context.get("dirty_source", "")).strip_edges()
		var receipt: Dictionary = state[
			"deferred_callback_receipts"].get(source, {}).duplicate(true)
		if str(receipt.get("status", "")) == "resolved":
			return true
		receipt["status"] = "resolved"
		receipt["event_id"] = event_id
		receipt["choice_index"] = choice_index
		receipt["resolved_turn"] = int(GameState.turn)
		state["deferred_callback_receipts"][source] = receipt
		GameState.core_loop_v2_state = state
		return true
	for raw_source in state["deferred_callback_receipts"]:
		var source := str(raw_source)
		var raw_receipt: Variant = state[
			"deferred_callback_receipts"].get(source, {})
		if not raw_receipt is Dictionary:
			continue
		var receipt: Dictionary = raw_receipt
		if str(receipt.get("root", "")) != event_id:
			continue
		if str(receipt.get("status", "")) == "resolved":
			return int(receipt.get("choice_index", -1)) == choice_index \
				and int(receipt.get("resolved_turn", -1)) \
					== int(GameState.turn)
		if str(receipt.get("status", "")) != "claimed" \
				or int(receipt.get("claimed_turn", -1)) \
					!= int(GameState.turn):
			return false
		receipt["status"] = "resolved"
		receipt["event_id"] = event_id
		receipt["choice_index"] = choice_index
		receipt["resolved_turn"] = int(GameState.turn)
		state["deferred_callback_receipts"][source] = receipt
		GameState.core_loop_v2_state = state
		return true
	return false

static func _note_obligation_story_choice(
		state: Dictionary, event_id: String, choice_index: int) -> bool:
	var bundle_id := _story_outcome_owner_id(
		state, event_id, "obligation_outcomes")
	if bundle_id.is_empty():
		return false
	var selected_obligation := _obligation_id_for_choice(
		bundle_id, event_id, choice_index)
	if selected_obligation.is_empty() \
			or not story_choice_available(
				event_id, selected_obligation):
		return false
	var raw_context: Variant = state.get("demo_collision_context", {})
	if not raw_context is Dictionary:
		return false
	var context: Dictionary = raw_context
	var raw_candidates: Variant = context.get("candidate_ids", [])
	if not raw_candidates is Array:
		return false
	var candidate_ids: Array = (raw_candidates as Array).duplicate()
	var deferred_ids: Array = []
	for raw_candidate in candidate_ids:
		var candidate_id := str(raw_candidate)
		if candidate_id != selected_obligation:
			deferred_ids.append(candidate_id)
	var receipt := {
		"bundle_id": bundle_id,
		"event_id": event_id,
		"turn": int(GameState.turn),
		"candidate_ids": candidate_ids,
		"selected_obligation_id": selected_obligation,
		"choice_index": choice_index,
		"deferred_obligation_ids": deferred_ids,
	}
	var raw_existing: Variant = state["obligation_receipts"].get(
		bundle_id, {})
	if raw_existing is Dictionary \
			and not (raw_existing as Dictionary).is_empty():
		var existing: Dictionary = raw_existing
		var exact_existing: bool = (
			str(existing.get("event_id", "")) == event_id \
			and int(existing.get("turn", -1)) == int(GameState.turn) \
			and str(existing.get("selected_obligation_id", "")) \
				== selected_obligation \
			and int(existing.get("choice_index", -1)) == choice_index \
			and existing.get("candidate_ids", []) == candidate_ids
		)
		if not exact_existing:
			return false
		if selected_obligation == "city_work_sample" \
				and _ensure_city_result_receipt(
					state, selected_obligation,
					event_id, choice_index).is_empty():
			return false
		return true
	state["obligation_receipts"][bundle_id] = receipt
	if selected_obligation == "city_work_sample" \
			and _ensure_city_result_receipt(
				state, selected_obligation,
				event_id, choice_index).is_empty():
		return false
	state = _normalized_state(
		GameState.core_loop_v2_state) \
		if selected_obligation == "city_work_sample" \
		else state
	GameState.core_loop_v2_state = state
	return true

static func _obligation_id_for_choice(
		bundle_id: String, event_id: String, choice_index: int) -> String:
	var raw_outcomes: Variant = bundle(bundle_id).get(
		"obligation_outcomes", [])
	if not raw_outcomes is Array:
		return ""
	for raw_outcome in raw_outcomes:
		if not raw_outcome is Dictionary:
			continue
		var outcome: Dictionary = raw_outcome
		if str(outcome.get("event_id", "")) == event_id \
				and _outcome_choice_matches(outcome, choice_index):
			var obligation_id := str(outcome.get(
				"selected_obligation_id", "")).strip_edges()
			var event: Dictionary = DataRegistry.find_event(event_id)
			var choices: Variant = event.get("choices", [])
			if obligation_id.is_empty() or not choices is Array \
					or choice_index < 0 \
					or choice_index >= (choices as Array).size() \
					or not (choices as Array)[choice_index] is Dictionary:
				return ""
			var choice: Dictionary = (choices as Array)[choice_index]
			return obligation_id \
				if str(choice.get(
					"v2_obligation_id", "")).strip_edges() \
					== obligation_id else ""
	return ""

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
		# Resolve compatibility-sensitive initiative from the same helper used by
		# save migration. Old planned runs received Father's incoming call; only
		# the new pre-plan missed-call route records a player callback.
		var resolved_outcome := _relationship_outcome_for_choice(
			bundle_id, event_id, choice_index, state)
		if resolved_outcome.is_empty():
			return false
		outcome = resolved_outcome
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
		var allow_already_at_target := bool(
			outcome.get("allow_already_at_target", false))
		var already_at_target := allow_already_at_target \
			and current_stage == target_stage \
			and current_stage != from_stage
		if current_stage != from_stage and not already_at_target:
			return false
		var current_rank := RELATIONSHIP_STAGE_ORDER.find(current_stage)
		var target_rank := RELATIONSHIP_STAGE_ORDER.find(target_stage)
		if target_rank < 0 or current_rank < 0 or target_rank < current_rank:
			return false
		# A first encounter may establish an opening immediately, but once two
		# people know each other a single authored choice may advance at most
		# one relationship step. This keeps later month data from silently
		# skipping the player-initiation or shared-commitment beats.
		if current_stage != "unmet" and target_rank > current_rank + 1:
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
		if not _outcome_runtime_applicable(
				state, bundle_id, outcome) \
				or str(outcome.get("event_id", "")) != event_id \
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
			# Seoul Cycle absorbs legacy routines into actual node allocations.
			# Preserve authored prerequisites such as Daeun's livelihood encounter
			# by reading what the player really spent weeks on, not an empty hidden
			# routine dictionary.
			var active_cycle: Dictionary = state.get(SEOUL_CYCLE_STATE_KEY, {})
			if _seoul_cycle_receipts_include_track(
				active_cycle.get("allocation_receipts", {}),
				active_cycle.get("nodes", {}), track):
				return true
			for raw_summary in state["month_summaries"].values():
				if not raw_summary is Dictionary:
					continue
				if _seoul_cycle_receipts_include_track(
						(raw_summary as Dictionary).get(
							"allocation_receipts", []),
						(raw_summary as Dictionary).get("node_states", {}),
						track):
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

static func _seoul_cycle_receipts_include_track(
		raw_receipts: Variant, raw_nodes: Variant,
		track: String) -> bool:
	if not raw_nodes is Dictionary:
		return false
	var receipts: Array = []
	if raw_receipts is Dictionary:
		receipts.assign((raw_receipts as Dictionary).values())
	elif raw_receipts is Array:
		receipts = (raw_receipts as Array).duplicate()
	else:
		return false
	for raw_receipt in receipts:
		if not raw_receipt is Dictionary:
			continue
		var node_id := str((raw_receipt as Dictionary).get("node_id", ""))
		var raw_node: Variant = (raw_nodes as Dictionary).get(node_id, {})
		if not raw_node is Dictionary:
			continue
		var node: Dictionary = raw_node
		if str(node.get("routine_track", node.get("owner", ""))) == track:
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

static func _normalized_player_trigger_ids(
		raw_ids: Variant, authored_ids: Array[String]) -> Dictionary:
	if not raw_ids is Array or (raw_ids as Array).size() > 2:
		return {"ok": false, "ids": []}
	var ids: Array[String] = []
	for raw_id in raw_ids:
		var bundle_id := str(raw_id).strip_edges()
		if bundle_id.is_empty() or ids.has(bundle_id) \
				or not authored_ids.has(bundle_id) \
				or bundle(bundle_id).is_empty():
			return {"ok": false, "ids": []}
		ids.append(bundle_id)
	ids.sort()
	return {"ok": true, "ids": ids}

## Public for save migration tests and recovery callers. It never creates new
## capacities: an old/malformed save cannot gain a reroll by normalization.
static func normalize_seoul_cycle_state(raw_state: Dictionary) -> Dictionary:
	if raw_state.is_empty():
		return {}
	var root_spec := seoul_cycle_spec()
	var month := int(raw_state.get("month", 0))
	var month_spec := seoul_cycle_month_spec(month)
	var raw_capacity_spec: Variant = root_spec.get("capacity", {})
	var raw_node_specs: Variant = month_spec.get("nodes", {})
	if root_spec.is_empty() or month_spec.is_empty() \
			or not raw_capacity_spec is Dictionary \
			or not raw_node_specs is Dictionary \
			or int(raw_state.get("schema", 0)) != SEOUL_CYCLE_SCHEMA \
			or str(raw_state.get("planning_mode", "")) != SEOUL_CYCLE_MODE:
		return {}
	var month_start_turn := _seoul_cycle_month_start_turn(month)
	var month_end_turn := _seoul_cycle_month_end_turn(month)
	var raw_capacities: Variant = raw_state.get("capacities", [])
	var capacity_count := int(
		(raw_capacity_spec as Dictionary).get("count", 4))
	if not raw_capacities is Array \
			or (raw_capacities as Array).size() != capacity_count:
		return {}
	var capacities: Array = []
	var capacity_ids: Array[String] = []
	for index in range((raw_capacities as Array).size()):
		var raw_capacity: Variant = (raw_capacities as Array)[index]
		if not raw_capacity is Dictionary:
			return {}
		var capacity: Dictionary = (raw_capacity as Dictionary).duplicate(true)
		var capacity_id := str(capacity.get("id", "")).strip_edges()
		var expected_id := "m%d_capacity_%d" % [month, index + 1]
		var value := int(capacity.get("value", 0))
		if capacity_id != expected_id or capacity_ids.has(capacity_id) \
				or value < int((raw_capacity_spec as Dictionary).get(
					"minimum", 1)) \
				or value > int((raw_capacity_spec as Dictionary).get(
					"maximum", 6)):
			return {}
		capacity_ids.append(capacity_id)
		capacity["id"] = capacity_id
		capacity["value"] = value
		capacity["quality"] = _seoul_cycle_capacity_quality(value)
		capacity["consumed"] = bool(capacity.get("consumed", false))
		capacity["consumed_turn"] = clampi(
			int(capacity.get("consumed_turn", 0)),
			month_start_turn, month_end_turn) \
			if bool(capacity["consumed"]) else 0
		capacity["node_id"] = str(capacity.get("node_id", "")) \
			if bool(capacity["consumed"]) else ""
		capacities.append(capacity)
	var raw_nodes: Variant = raw_state.get("nodes", {})
	if not raw_nodes is Dictionary:
		return {}
	var nodes: Dictionary = {}
	for raw_node_id in (raw_node_specs as Dictionary):
		var node_id := str(raw_node_id).strip_edges()
		var raw_node_spec: Variant = (
			raw_node_specs as Dictionary).get(raw_node_id, {})
		if node_id.is_empty() or not raw_node_spec is Dictionary:
			return {}
		# Normalization must be a pure save-shape operation. Re-running dynamic
		# prerequisite resolution here would recurse through available_offer_ids
		# back into _normalized_state and could also rewrite an old save's chosen
		# relationship branch.
		var node: Dictionary = (raw_node_spec as Dictionary).duplicate(true)
		var raw_runtime_node: Variant = (raw_nodes as Dictionary).get(
			node_id, {})
		var player_trigger_required := _seoul_cycle_player_trigger_required(node)
		if raw_runtime_node is Dictionary:
			var persisted_trigger := str(
				(raw_runtime_node as Dictionary).get(
					"trigger_bundle", "")).strip_edges()
			if player_trigger_required:
				var authored_ids := _seoul_cycle_node_trigger_candidates(
					raw_node_spec as Dictionary)
				authored_ids.sort()
				if not persisted_trigger.is_empty() \
						and not authored_ids.has(persisted_trigger):
					return {}
				var selected_trigger := str(
					(raw_runtime_node as Dictionary).get(
						"selected_trigger_bundle_id", "")).strip_edges()
				var has_durable_eligibility := (
					raw_runtime_node as Dictionary).has(
						"eligible_trigger_bundle_ids")
				var durable_selection_fields := [
					"selected_trigger_bundle_id",
					"trigger_selection_origin",
					"trigger_selection_migrated_legacy",
				]
				var has_any_player_selection_field := false
				var has_all_player_selection_fields := true
				for field in durable_selection_fields:
					has_any_player_selection_field = \
						has_any_player_selection_field \
						or (raw_runtime_node as Dictionary).has(field)
					has_all_player_selection_fields = \
						has_all_player_selection_fields \
						and (raw_runtime_node as Dictionary).has(field)
				if not has_durable_eligibility \
						and has_any_player_selection_field:
					return {}
				if has_durable_eligibility \
						and (not has_all_player_selection_fields \
							or not (raw_runtime_node as Dictionary).has(
								"trigger_bundle") \
							or not (raw_runtime_node as Dictionary).has(
								"summary_bundle")):
					return {}
				var persisted_origin := str(
					(raw_runtime_node as Dictionary).get(
						"trigger_selection_origin", "")).strip_edges()
				var eligible_ids: Array[String] = []
				if has_durable_eligibility:
					var raw_eligible_ids: Variant = (
						raw_runtime_node as Dictionary).get(
							"eligible_trigger_bundle_ids", [])
					var normalized_ids := _normalized_player_trigger_ids(
						raw_eligible_ids,
						authored_ids)
					if not bool(normalized_ids.get("ok", false)) \
							or raw_eligible_ids != normalized_ids.get("ids", []) \
							or selected_trigger != persisted_trigger \
							or persisted_origin not in [
								"unselected_player", "player_selection",
								"legacy_persisted_trigger",
							]:
						return {}
					eligible_ids.assign(normalized_ids.get("ids", []))
					var raw_migrated: Variant = (
						raw_runtime_node as Dictionary).get(
							"trigger_selection_migrated_legacy", null)
					if not raw_migrated is bool \
							or bool(raw_migrated) \
								!= (persisted_origin \
									== "legacy_persisted_trigger"):
						return {}
					if persisted_origin == "legacy_persisted_trigger":
						if (not selected_trigger.is_empty() \
								and (eligible_ids.size() != 1 \
									or eligible_ids[0] != selected_trigger)) \
								or (selected_trigger.is_empty() \
									and not eligible_ids.is_empty()):
							return {}
						node["trigger_selection_migrated_legacy"] = true
					else:
						if (selected_trigger.is_empty() \
								and persisted_origin != "unselected_player") \
								or (not selected_trigger.is_empty() \
									and persisted_origin != "player_selection"):
							return {}
						node["trigger_selection_migrated_legacy"] = false
				else:
					# Legacy cycle nodes had already persisted the runtime-picked
					# trigger. That exact ID is the only migration authority: do not
					# re-run today's predicates or invent its former sibling list.
					selected_trigger = persisted_trigger
					if not selected_trigger.is_empty():
						eligible_ids.append(selected_trigger)
					persisted_origin = "legacy_persisted_trigger"
					node["trigger_selection_migrated_legacy"] = true
				if not selected_trigger.is_empty():
					if not eligible_ids.has(selected_trigger):
						return {}
					node = _seoul_cycle_node_with_resolved_trigger(
						node, selected_trigger, month)
				else:
					node["trigger_bundle"] = ""
					node["selected_trigger_bundle_id"] = ""
					node["summary_bundle"] = ""
				node["eligible_trigger_bundle_ids"] = eligible_ids
				node["trigger_selection_origin"] = persisted_origin
			elif persisted_trigger.is_empty() \
					or _seoul_cycle_node_trigger_candidates(
						raw_node_spec as Dictionary).has(persisted_trigger):
				node = _seoul_cycle_node_with_resolved_trigger(
					node, persisted_trigger, month)
			else:
				return {}
			for key in [
				"progress", "status", "completed_turn",
				"last_allocation_turn", "expired_turn", "featured_status",
				"missed_trigger_bundle", "fallback_mode",
				"onboarding_completion_override_applied", "authored_threshold",
				"completion_threshold", "onboarding_capacity_id",
				"onboarding_capacity_value",
			]:
				if (raw_runtime_node as Dictionary).has(key):
					node[key] = (raw_runtime_node as Dictionary)[key]
		elif player_trigger_required:
			# A malformed/very old unresolved node cannot gain relationship
			# choices merely by being loaded under today's prerequisites.
			node["eligible_trigger_bundle_ids"] = []
			node["selected_trigger_bundle_id"] = ""
			node["trigger_bundle"] = ""
			node["summary_bundle"] = ""
			node["trigger_selection_origin"] = "legacy_persisted_trigger"
			node["trigger_selection_migrated_legacy"] = true
		var threshold: int = maxi(1, int(node.get("threshold", 1)))
		var completion_threshold := threshold
		if node.get("onboarding_completion_override_applied", false) == true:
			completion_threshold = clampi(int(node.get(
				"completion_threshold", threshold)), 1, threshold)
		node["id"] = node_id
		node["threshold"] = threshold
		node["deadline_week"] = clampi(
			int(node.get("deadline_week", 4)), 1, 4)
		node["progress"] = clampi(int(node.get("progress", 0)), 0, threshold)
		var status := str(node.get("status", "open"))
		if status not in [
			"open", "in_progress", "awaiting_trigger", "completed", "expired",
			"locked",
		]:
			status = "open" if int(node["progress"]) == 0 else "in_progress"
		if status in ["awaiting_trigger", "completed"] \
				and int(node["progress"]) < completion_threshold:
			status = "in_progress"
		if player_trigger_required:
			var selected_trigger := str(node.get(
				"selected_trigger_bundle_id", "")).strip_edges()
			var eligible_ids: Array = node.get(
				"eligible_trigger_bundle_ids", [])
			if selected_trigger.is_empty():
				if not eligible_ids.is_empty() and status == "locked":
					return {}
				if eligible_ids.is_empty():
					status = "locked"
				elif int(node["progress"]) > 0 \
						or status not in ["open", "expired"]:
					return {}
			elif str(node.get("trigger_bundle", "")) != selected_trigger \
					or str(node.get("summary_bundle", "")) != selected_trigger \
					or not eligible_ids.has(selected_trigger):
				return {}
		node["status"] = status
		node["completed_turn"] = clampi(
			int(node.get("completed_turn", 0)),
			0, month_end_turn)
		node["last_allocation_turn"] = clampi(
			int(node.get("last_allocation_turn", 0)),
			0, month_end_turn)
		if node.has("expired_turn"):
			node["expired_turn"] = clampi(
				int(node.get("expired_turn", 0)),
				0, month_end_turn)
		nodes[node_id] = node
	for capacity in capacities:
		if bool(capacity.get("consumed", false)) \
				and not nodes.has(str(capacity.get("node_id", ""))):
			return {}
	var normalized_world_receipts := \
		_seoul_cycle_world_receipt_dictionary(
			raw_state.get("world_receipts", {}), month)
	if not bool(normalized_world_receipts.get("ok", false)):
		return {}
	var allocation_receipts := _seoul_cycle_receipt_dictionary(
		raw_state.get("allocation_receipts", {}))
	for raw_turn_key in allocation_receipts:
		var raw_allocation: Variant = allocation_receipts.get(
			raw_turn_key, {})
		if not raw_allocation is Dictionary:
			return {}
		var allocation: Dictionary = raw_allocation
		var allocation_node_id := str(allocation.get("node_id", ""))
		var allocation_node: Dictionary = nodes.get(
			allocation_node_id, {})
		if allocation_node.is_empty() \
				or not _seoul_cycle_player_trigger_required(allocation_node):
			continue
		var allocation_capacity_id := str(
			allocation.get("capacity_id", ""))
		var matched_capacity := false
		for capacity in capacities:
			if str(capacity.get("id", "")) == allocation_capacity_id \
					and bool(capacity.get("consumed", false)) \
					and int(capacity.get("consumed_turn", 0)) \
						== int(allocation.get("turn", 0)) \
					and str(capacity.get("node_id", "")) \
						== allocation_node_id:
				matched_capacity = true
				break
		if not matched_capacity:
			return {}
	for capacity in capacities:
		if not bool(capacity.get("consumed", false)):
			continue
		var consumed_turn := int(capacity.get("consumed_turn", 0))
		var raw_allocation: Variant = allocation_receipts.get(
			str(consumed_turn), {})
		if not raw_allocation is Dictionary \
				or str((raw_allocation as Dictionary).get(
					"capacity_id", "")) != str(capacity.get("id", "")) \
				or str((raw_allocation as Dictionary).get(
					"node_id", "")) != str(capacity.get("node_id", "")):
			return {}
	var trigger_receipts := _seoul_cycle_receipt_dictionary(
		raw_state.get("trigger_receipts", {}))
	var pending_trigger := _normalized_seoul_cycle_pending(
		raw_state.get("pending_trigger", {}), "node_trigger", month)
	if raw_state.get("pending_trigger", {}) is Dictionary \
			and not (raw_state.get("pending_trigger", {}) as Dictionary).is_empty() \
			and pending_trigger.is_empty():
		return {}
	if not _normalize_seoul_cycle_player_trigger_identity(
			nodes, allocation_receipts, trigger_receipts, pending_trigger):
		return {}
	var state := {
		"schema": SEOUL_CYCLE_SCHEMA,
		"planning_mode": SEOUL_CYCLE_MODE,
		"month": month,
		"initialized_turn": clampi(
			int(raw_state.get("initialized_turn", month_start_turn)),
			month_start_turn, month_end_turn),
		"seed_signature": str(raw_state.get("seed_signature", "")),
		"source_health": clampi(int(raw_state.get("source_health", 0)), 0, 100),
		"source_mental": clampi(int(raw_state.get("source_mental", 0)), 0, 100),
		"condition_band": str(raw_state.get("condition_band", "")),
		"capacities": capacities,
		"nodes": nodes,
		"world_clock": clampi(
			int(raw_state.get("world_clock", 0)), 0,
			maxi(1, int((month_spec.get("world_clock", {}) as Dictionary).get(
				"maximum", 4))) if month_spec.get("world_clock", {}) is Dictionary \
				else 4),
		"allocation_receipts": allocation_receipts,
		"trigger_receipts": trigger_receipts,
		"world_receipts": (
			normalized_world_receipts.get("receipts", {}) as Dictionary),
		"expiry_receipts": _seoul_cycle_receipt_dictionary(
			raw_state.get("expiry_receipts", {})),
		"pending_trigger": pending_trigger,
		"pending_world": _normalized_seoul_cycle_pending(
			raw_state.get("pending_world", {}), "world", month),
		"completed_turns": [],
		"expired_nodes": [],
	}
	for raw_turn in raw_state.get("completed_turns", []):
		var completed_turn := int(raw_turn)
		if completed_turn >= month_start_turn \
				and completed_turn <= month_end_turn \
				and not state["completed_turns"].has(completed_turn):
			state["completed_turns"].append(completed_turn)
	state["completed_turns"].sort()
	for raw_node_id in raw_state.get("expired_nodes", []):
		var node_id := str(raw_node_id).strip_edges()
		if nodes.has(node_id) and not state["expired_nodes"].has(node_id):
			state["expired_nodes"].append(node_id)
	return state

static func _seoul_cycle_receipt_dictionary(raw_receipts: Variant) -> Dictionary:
	var receipts: Dictionary = {}
	if not raw_receipts is Dictionary:
		return receipts
	for raw_key in (raw_receipts as Dictionary):
		var raw_receipt: Variant = (raw_receipts as Dictionary).get(raw_key, {})
		if raw_receipt is Dictionary and not (raw_receipt as Dictionary).is_empty():
			receipts[str(raw_key)] = (raw_receipt as Dictionary).duplicate(true)
	return receipts

static func _normalize_seoul_cycle_player_trigger_identity(
		nodes: Dictionary, allocation_receipts: Dictionary,
		trigger_receipts: Dictionary, pending_trigger: Dictionary) -> bool:
	for raw_node_id in nodes:
		var node_id := str(raw_node_id)
		var raw_node: Variant = nodes.get(raw_node_id, {})
		if not raw_node is Dictionary \
				or not _seoul_cycle_player_trigger_required(raw_node as Dictionary):
			continue
		var node: Dictionary = raw_node
		var selected := str(node.get(
			"selected_trigger_bundle_id", "")).strip_edges()
		var migrated_legacy := bool(node.get(
			"trigger_selection_migrated_legacy", false))
		var matching_allocations: Array[Dictionary] = []
		for raw_receipt in allocation_receipts.values():
			if raw_receipt is Dictionary \
					and str((raw_receipt as Dictionary).get(
						"node_id", "")) == node_id:
				matching_allocations.append(raw_receipt as Dictionary)
		matching_allocations.sort_custom(func(
				left: Dictionary, right: Dictionary) -> bool:
			return int(left.get("turn", 0)) < int(right.get("turn", 0)))
		if not migrated_legacy \
				and ((not selected.is_empty() and matching_allocations.is_empty()) \
					or (selected.is_empty() and not matching_allocations.is_empty())):
			return false
		var completion_receipt_count := 0
		for receipt in matching_allocations:
			var receipt_selected := str(receipt.get(
				"selected_trigger_bundle_id", "")).strip_edges()
			var weekly: Dictionary = receipt.get("weekly_commitment", {}) \
				if receipt.get("weekly_commitment", {}) is Dictionary else {}
			var details: Dictionary = weekly.get("details", {}) \
				if weekly.get("details", {}) is Dictionary else {}
			var weekly_selected := str(details.get(
				"selected_trigger_bundle_id", "")).strip_edges()
			if migrated_legacy and receipt_selected.is_empty() \
					and weekly_selected.is_empty():
				continue
			if selected.is_empty() or receipt_selected != selected \
					or weekly_selected != selected:
				return false
			var completed_now := bool(receipt.get("completed_now", false))
			var receipt_trigger := str(receipt.get(
				"trigger_bundle", "")).strip_edges()
			if completed_now:
				completion_receipt_count += 1
				if receipt_trigger != selected:
					return false
			elif not receipt_trigger.is_empty():
				return false
		if completion_receipt_count > 1:
			return false
		var raw_pending: Variant = pending_trigger
		var has_pending := false
		if raw_pending is Dictionary \
				and str((raw_pending as Dictionary).get(
					"node_id", "")) == node_id:
			has_pending = true
			var pending_selected := str(
				(raw_pending as Dictionary).get(
					"selected_trigger_bundle_id", "")).strip_edges()
			var pending_bundle := str(
				(raw_pending as Dictionary).get("bundle_id", "")).strip_edges()
			if selected.is_empty() or pending_bundle != selected \
					or (not migrated_legacy and pending_selected != selected) \
					or (migrated_legacy and not pending_selected.is_empty() \
						and pending_selected != selected):
				return false
		var has_resolved := false
		for raw_receipt_key in trigger_receipts:
			var raw_trigger_receipt: Variant = trigger_receipts.get(
				raw_receipt_key, {})
			if not raw_trigger_receipt is Dictionary \
					or str((raw_trigger_receipt as Dictionary).get(
						"node_id", "")) != node_id:
				continue
			if str(raw_receipt_key) != node_id:
				return false
			has_resolved = true
			var resolved_selected := str(
				(raw_trigger_receipt as Dictionary).get(
					"selected_trigger_bundle_id", "")).strip_edges()
			var resolved_bundle := str(
				(raw_trigger_receipt as Dictionary).get(
					"bundle_id", "")).strip_edges()
			if selected.is_empty() or resolved_bundle != selected \
					or (not migrated_legacy and resolved_selected != selected) \
					or (migrated_legacy and not resolved_selected.is_empty() \
						and resolved_selected != selected):
				return false
		if not migrated_legacy:
			if has_pending and has_resolved:
				return false
			if completion_receipt_count == 0 \
					and (has_pending or has_resolved):
				return false
			if completion_receipt_count == 1 \
					and not has_pending and not has_resolved:
				return false
			if has_pending and str(node.get("status", "")) \
					!= "awaiting_trigger":
				return false
			if has_resolved and str(node.get("status", "")) != "completed":
				return false
	return true

## The allocation receipt keeps the transaction-time weekly record, while
## GameState.weekly_commitments is the live echo/review ledger. Both durable
## copies must name the same player-owned branch. Follow-up arrays and outcome
## snapshots legitimately evolve after a scene resolves, so compare only the
## immutable allocation identity instead of requiring byte equality forever.
static func _seoul_cycle_outer_weekly_identity_valid(
		cycle: Dictionary, raw_weekly_commitments: Variant) -> bool:
	if cycle.is_empty():
		return true
	if not raw_weekly_commitments is Array:
		return false
	var nodes: Dictionary = cycle.get("nodes", {}) \
		if cycle.get("nodes", {}) is Dictionary else {}
	var allocation_receipts: Dictionary = cycle.get(
		"allocation_receipts", {}) \
		if cycle.get("allocation_receipts", {}) is Dictionary else {}
	for raw_receipt in allocation_receipts.values():
		if not raw_receipt is Dictionary:
			return false
		var receipt: Dictionary = raw_receipt
		var node_id := str(receipt.get("node_id", "")).strip_edges()
		var raw_node: Variant = nodes.get(node_id, {})
		if not raw_node is Dictionary \
				or not _seoul_cycle_player_trigger_required(
					raw_node as Dictionary):
			continue
		var node: Dictionary = raw_node
		var migrated_legacy := bool(node.get(
			"trigger_selection_migrated_legacy", false))
		var selected := str(node.get(
			"selected_trigger_bundle_id", "")).strip_edges()
		var turn := int(receipt.get("turn", 0))
		var capacity_id := str(receipt.get("capacity_id", "")).strip_edges()
		var raw_embedded: Variant = receipt.get("weekly_commitment", {})
		if selected.is_empty() or turn <= 0 or capacity_id.is_empty() \
				or not raw_embedded is Dictionary:
			return false
		var embedded: Dictionary = raw_embedded
		var embedded_details: Dictionary = embedded.get("details", {}) \
			if embedded.get("details", {}) is Dictionary else {}
		var matches: Array[Dictionary] = []
		for raw_weekly in raw_weekly_commitments as Array:
			if raw_weekly is Dictionary \
					and int((raw_weekly as Dictionary).get("turn", -1)) == turn:
				matches.append(raw_weekly as Dictionary)
		if matches.size() != 1:
			return false
		var outer: Dictionary = matches.front()
		var outer_details: Dictionary = outer.get("details", {}) \
			if outer.get("details", {}) is Dictionary else {}
		var receipt_selected := str(receipt.get(
			"selected_trigger_bundle_id", "")).strip_edges()
		var embedded_selected := str(embedded_details.get(
			"selected_trigger_bundle_id", "")).strip_edges()
		var outer_selected := str(outer_details.get(
			"selected_trigger_bundle_id", "")).strip_edges()
		var legacy_blank_identity := migrated_legacy \
			and receipt_selected.is_empty() \
			and embedded_selected.is_empty() \
			and outer_selected.is_empty()
		if not legacy_blank_identity \
				and (receipt_selected != selected \
					or embedded_selected != selected \
					or outer_selected != selected):
			return false
		var expected_person := str(node.get("owner", "")).strip_edges() \
			if str(node.get("commitment_action_id", "")) == "contact" \
				and str(node.get("owner", "")).strip_edges() != "people" \
			else ""
		for weekly in [embedded, outer]:
			var details: Dictionary = weekly.get("details", {}) \
				if weekly.get("details", {}) is Dictionary else {}
			if str(weekly.get("source", "")) != "seoul_cycle" \
					or str(weekly.get("person_id", "")).strip_edges() \
						!= expected_person \
					or str(details.get("execution", "")) != "seoul_cycle" \
					or int(details.get("month", 0)) \
						!= int(cycle.get("month", 0)) \
					or str(details.get("node_id", "")) != node_id \
					or str(details.get("capacity_id", "")) != capacity_id:
				return false
		for stable_key in [
			"pressure_id", "pressure_family", "choice_id",
			"actual_action_id", "person_id",
		]:
			if str(outer.get(stable_key, "")) \
					!= str(embedded.get(stable_key, "")):
				return false
		for stable_detail_key in [
			"execution", "month", "week_index", "node_id", "capacity_id",
			"capacity_value", "progress_gain", "progress_after", "threshold",
			"completed_now", "repeat_allocation", "fallback_allocation",
			"selected_trigger_bundle_id", "place",
		]:
			if outer_details.get(stable_detail_key, null) \
					!= embedded_details.get(stable_detail_key, null):
				return false
	return true

## Godot's JSON round-trip restores every number as a float. A world beat
## saved while pending can therefore resolve under the legacy alias `"4.0"`,
## while the calendar asks for the canonical integer week key `"4"`. Repair
## only that exact integral alias; arbitrary mismatched keys remain invalid,
## and a collision fails closed instead of merging two receipts.
static func _seoul_cycle_world_receipt_dictionary(
		raw_receipts: Variant, month: int) -> Dictionary:
	if raw_receipts is Dictionary:
		var raw_keys: Dictionary = {}
		for raw_key in (raw_receipts as Dictionary).keys():
			var key := str(raw_key)
			if raw_keys.has(key):
				return {"ok": false, "receipts": {}}
			raw_keys[key] = true
		for week_index in range(1, 5):
			if raw_keys.has(str(week_index)) \
					and raw_keys.has("%d.0" % week_index):
				return {"ok": false, "receipts": {}}
	var receipts := _seoul_cycle_receipt_dictionary(raw_receipts)
	for raw_key in receipts.keys():
		var key := str(raw_key)
		var raw_receipt: Variant = receipts.get(raw_key, {})
		if not raw_receipt is Dictionary:
			continue
		var raw_week: Variant = (raw_receipt as Dictionary).get(
			"week_index", null)
		if not (raw_week is int or raw_week is float) \
				or not is_finite(float(raw_week)):
			continue
		var week_index := int(raw_week)
		if week_index < 1 or week_index > 4 \
				or float(raw_week) != float(week_index):
			continue
		var canonical_key := str(week_index)
		if key != "%s.0" % canonical_key:
			continue
		var receipt: Dictionary = raw_receipt
		var turn := _seoul_cycle_month_start_turn(month) + week_index - 1
		var bundle_id := str(receipt.get("bundle_id", ""))
		if not _seoul_cycle_resolved_receipt_matches(
				receipt, "pending_world", canonical_key,
				bundle_id, turn) \
				or not _seoul_cycle_world_bundle_authored_for_week(
					month, week_index, bundle_id):
			continue
		if receipts.has(canonical_key):
			return {"ok": false, "receipts": {}}
		receipts[canonical_key] = receipt.duplicate(true)
		receipts.erase(raw_key)
	return {"ok": true, "receipts": receipts}

static func _normalized_seoul_cycle_pending(
		raw_pending: Variant, expected_kind: String,
		month_index: int) -> Dictionary:
	if not raw_pending is Dictionary or (raw_pending as Dictionary).is_empty():
		return {}
	var pending: Dictionary = (raw_pending as Dictionary).duplicate(true)
	var kind := str(pending.get("kind", ""))
	var bundle_id := str(pending.get("bundle_id", "")).strip_edges()
	var turn := int(pending.get("turn", 0))
	var status := str(pending.get("status", ""))
	if bundle_id.is_empty() or bundle(bundle_id).is_empty() \
			or turn < _seoul_cycle_month_start_turn(month_index) \
			or turn > _seoul_cycle_month_end_turn(month_index) \
			or status not in ["pending", "claimed"]:
		return {}
	if expected_kind == "node_trigger":
		if kind != expected_kind \
				or str(pending.get("node_id", "")).is_empty():
			return {}
	else:
		# World receipts preserve their authored kind (`encounter`,
		# `fixed_crisis`, ...); `expected_kind` describes the pending slot,
		# not that source label.
		if not _seoul_cycle_world_bundle_authored_for_week(
					month_index,
					int(pending.get("week_index", 0)),
					bundle_id):
			return {}
	return pending

## Save normalization must be a pure shape check. Calling the dynamic world
## resolver here would evaluate bundle predicates, which read application
## state through `_normalized_state()` and recurse back into this function.
## Eligibility was already decided when the pending receipt was created; on
## load we only prove that the saved bundle is an authored option for that
## exact calendar week.
static func _seoul_cycle_world_bundle_authored_for_week(
		month_index: int, week_index: int, bundle_id: String) -> bool:
	if week_index < 1 or week_index > 4 or bundle_id.is_empty():
		return false
	var raw_world: Variant = seoul_cycle_month_spec(
		month_index).get("world_clock", {})
	if not raw_world is Dictionary:
		return false
	var absolute_turn := _seoul_cycle_month_start_turn(month_index) \
		+ week_index - 1
	for raw_event in (raw_world as Dictionary).get("events", []):
		if not raw_event is Dictionary \
				or int((raw_event as Dictionary).get("week_index", 0)) \
					!= week_index:
			continue
		var authored: Array[String] = []
		var fixed_bundle := str((raw_event as Dictionary).get(
			"bundle_id", "")).strip_edges()
		if not fixed_bundle.is_empty():
			authored.append(fixed_bundle)
		for raw_option in (raw_event as Dictionary).get(
			"bundle_options", []):
			var option_id := str(raw_option).strip_edges()
			if not option_id.is_empty() and not authored.has(option_id):
				authored.append(option_id)
		return authored.has(bundle_id) \
			and bundle_allowed_in_week(bundle_id, absolute_turn)
	return false

static func _normalized_w1_onboarding(raw_state: Variant) -> Dictionary:
	if not raw_state is Dictionary:
		return {}
	var onboarding: Dictionary = (raw_state as Dictionary).duplicate(true)
	if int(onboarding.get("schema", 0)) != W1_ONBOARDING_SCHEMA \
			or str(onboarding.get("origin", "")) != W1_ONBOARDING_ORIGIN \
			or int(onboarding.get("turn", 0)) != 1 \
			or str(onboarding.get("node_id", "")) != W1_ONBOARDING_NODE_ID \
			or str(onboarding.get("bundle_id", "")) != W1_ONBOARDING_BUNDLE_ID \
			or str(onboarding.get("application_id", "")) \
				!= W1_ONBOARDING_APPLICATION_ID:
		return {}
	var phase := str(onboarding.get("phase", ""))
	# A short-lived early implementation wrote the unsent confirmation draft.
	# Treat it exactly like any other pre-result save: restart the minigame.
	if phase == "draft":
		phase = "minigame"
		onboarding["quality"] = -1
		onboarding["stress_delta"] = 0
	if phase not in [
		"prologue", "board", "allocation_pending", "minigame",
		"result_committed", "action_completed", "consequence_presented",
		"consumed",
	]:
		return {}
	return {
		"schema": W1_ONBOARDING_SCHEMA,
		"origin": W1_ONBOARDING_ORIGIN,
		"turn": 1,
		"node_id": W1_ONBOARDING_NODE_ID,
		"bundle_id": W1_ONBOARDING_BUNDLE_ID,
		"application_id": W1_ONBOARDING_APPLICATION_ID,
		"phase": phase,
		"selected_capacity_id": str(onboarding.get(
			"selected_capacity_id", "")).strip_edges(),
		"selected_capacity_value": clampi(int(onboarding.get(
			"selected_capacity_value", 0)), 0, 6),
		"quality": clampi(int(onboarding.get("quality", -1)), -1, 3),
		"stress_delta": clampi(int(onboarding.get("stress_delta", 0)), -20, 20),
	}

static func _validate_w1_onboarding_cycle_override(state: Dictionary) -> void:
	var onboarding: Dictionary = state.get(W1_ONBOARDING_STATE_KEY, {})
	var cycle: Dictionary = state.get(SEOUL_CYCLE_STATE_KEY, {})
	if cycle.is_empty():
		return
	var nodes: Dictionary = cycle.get("nodes", {})
	var raw_node: Variant = nodes.get(W1_ONBOARDING_NODE_ID, {})
	if not raw_node is Dictionary:
		return
	var node: Dictionary = (raw_node as Dictionary).duplicate(true)
	if node.get("onboarding_completion_override_applied", false) != true:
		return
	var selected_capacity_id := str(onboarding.get(
		"selected_capacity_id", "")).strip_edges()
	var selected_capacity_value := int(onboarding.get(
		"selected_capacity_value", 0))
	var raw_receipt: Variant = (cycle.get(
		"allocation_receipts", {}) as Dictionary).get("1", {})
	var valid := str(onboarding.get("origin", "")) == W1_ONBOARDING_ORIGIN \
		and str(onboarding.get("phase", "")) in [
			"allocation_pending", "minigame", "draft", "result_committed",
			"action_completed", "consequence_presented", "consumed"] \
		and int(cycle.get("month", 0)) == 1 \
		and int(node.get("threshold", 0)) == 3 \
		and int(node.get("authored_threshold", 0)) == 3 \
		and int(node.get("completion_threshold", 0)) == 1 \
		and str(node.get("onboarding_capacity_id", "")) \
			== selected_capacity_id \
		and int(node.get("onboarding_capacity_value", 0)) \
			== selected_capacity_value \
		and not selected_capacity_id.is_empty() \
		and selected_capacity_value in range(1, 7) \
		and raw_receipt is Dictionary \
		and str((raw_receipt as Dictionary).get("node_id", "")) \
			== W1_ONBOARDING_NODE_ID \
		and str((raw_receipt as Dictionary).get("capacity_id", "")) \
			== selected_capacity_id \
		and int((raw_receipt as Dictionary).get("capacity_value", 0)) \
			== selected_capacity_value \
		and bool((raw_receipt as Dictionary).get(
			"onboarding_completion_override", false))
	if not valid:
		for key in [
			"onboarding_completion_override_applied", "authored_threshold",
			"completion_threshold", "onboarding_capacity_id",
			"onboarding_capacity_value",
		]:
			node.erase(key)
		if str(node.get("status", "")) in ["awaiting_trigger", "completed"] \
				and int(node.get("progress", 0)) < int(node.get("threshold", 1)):
			node["status"] = "in_progress"
		nodes[W1_ONBOARDING_NODE_ID] = node
		cycle["nodes"] = nodes
		state[SEOUL_CYCLE_STATE_KEY] = cycle

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
		"completion_snapshots",
		"month_opening_snapshots",
		"action_receipts", "action_story_acknowledgements",
		"application_statuses", "consequence_receipts",
		"application_transition_receipts",
		"legacy_callback_resolutions",
		"story_choice_receipts", "obligation_receipts",
		"deferred_callback_receipts", "demo_collision_context",
		"future_story_receipts", "future_application_receipts",
		"activity_task_session", SEOUL_CYCLE_STATE_KEY,
		W1_ONBOARDING_STATE_KEY,
	]:
		if not state.has(key) or not state[key] is Dictionary:
			state[key] = {}
	state[SEOUL_CYCLE_STATE_KEY] = normalize_seoul_cycle_state(
		state.get(SEOUL_CYCLE_STATE_KEY, {}))
	if not _seoul_cycle_outer_weekly_identity_valid(
			state[SEOUL_CYCLE_STATE_KEY], GameState.weekly_commitments):
		# A split identity must not leave an apparently playable partial cycle.
		# Clearing this isolated subsystem is the existing load-time fail-closed
		# behavior for malformed Seoul-cycle saves.
		state[SEOUL_CYCLE_STATE_KEY] = {}
	state[W1_ONBOARDING_STATE_KEY] = _normalized_w1_onboarding(
		state.get(W1_ONBOARDING_STATE_KEY, {}))
	_validate_w1_onboarding_cycle_override(state)
	for key in [
		"forgone", "completed_turns", "completed_bundles",
		"shown_consequences", "player_initiated", "pending_declines",
		"decline_receipts", "relationship_history", "relationship_memories",
	]:
		if not state.has(key) or not state[key] is Array:
			state[key] = []
	for raw_receipt in state["story_choice_receipts"].values():
		if not raw_receipt is Dictionary:
			continue
		var initiated_character := str(
			(raw_receipt as Dictionary).get(
				"player_initiated_character", "")).strip_edges()
		if not initiated_character.is_empty() \
				and GameState.cast.has(initiated_character) \
				and not state["player_initiated"].has(
					initiated_character):
			state["player_initiated"].append(initiated_character)
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
		var historical_roots := resolved_event_roots(consequence_id)
		# Before this order, every persisted opening_interview_math entry owned
		# only the interview. The new path writes shown+receipt atomically, so a
		# shown entry with no receipt is always legacy regardless of save schema.
		if consequence_id == OPENING_INTERVIEW_BUNDLE_ID:
			historical_roots = [LEGACY_OPENING_INTERVIEW_ROOT]
		state["consequence_receipts"][consequence_id] = {
			"consequence_id": consequence_id,
			"scheduled_bundle": "",
			"turn": int(state["shown_consequence_turns"].get(
				consequence_id, 0)),
			"status": "consumed",
			"surface_kind": "legacy_separate",
			"roots": historical_roots,
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
	# This backward-compatible optional field keeps the outer V2 schema at 3;
	# old saves normalize to an empty session, while malformed or stale owners
	# are discarded before any action can use them.
	state["activity_task_session"] = _normalized_activity_task_session(
		state.get("activity_task_session", {}), state)
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
	var commitment := _action_record_for_bundle_from_weekly_commitment(
		GameState.get_weekly_commitment_for_turn(active_turn),
		bundle_id, expected_action)
	if commitment.is_empty():
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
		if not _apply_action_application_receipt(
				state, bundle_id, existing as Dictionary):
			return
	else:
		state["action_receipts"][bundle_id] = recovered
	var receipt: Dictionary = state["action_receipts"][bundle_id]
	if not _apply_action_application_receipt(state, bundle_id, receipt):
		return
	state["action_result_ready"] = not (
		_is_action_story_bundle(scene_bundle)
		and _has_current_action_story_acknowledgement(state, bundle_id)
	)
	_clear_activity_task_session_for_owner(state, bundle_id, active_turn)

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
			int(identity.get("choice_index", -1)), state)
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
		var migrated_character := str(receipt.get(
			"character", "")).strip_edges()
		if str(receipt.get("initiative", "")) == "player" \
				and GameState.cast.has(migrated_character) \
				and not state["player_initiated"].has(migrated_character):
			state["player_initiated"].append(migrated_character)
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

static func opening_application_provenance_valid() -> bool:
	return _opening_application_provenance_valid(
		_normalized_state(GameState.core_loop_v2_state))

static func _opening_application_provenance_valid(state: Dictionary) -> bool:
	var onboarding: Dictionary = state.get(W1_ONBOARDING_STATE_KEY, {})
	if str(onboarding.get("origin", "")) == W1_ONBOARDING_ORIGIN:
		var raw_receipt: Variant = state["action_receipts"].get(
			W1_ONBOARDING_BUNDLE_ID, {})
		if not raw_receipt is Dictionary:
			return false
		var receipt: Dictionary = raw_receipt
		var details: Dictionary = receipt.get("result_details", {}) \
			if receipt.get("result_details", {}) is Dictionary else {}
		var transition_key := "%s:application:1" % W1_ONBOARDING_BUNDLE_ID
		var raw_transition: Variant = state[
			"application_transition_receipts"].get(transition_key, {})
		var live_status := str(state["application_statuses"].get(
			W1_ONBOARDING_APPLICATION_ID, ""))
		return int(receipt.get("turn", -1)) == 1 \
			and str(receipt.get("bundle_id", "")) \
				== W1_ONBOARDING_BUNDLE_ID \
			and str(receipt.get("action_id", "")) == "resume" \
			and str(receipt.get("application_id", "")) \
				== W1_ONBOARDING_APPLICATION_ID \
			and str(receipt.get("application_status", "")) == "submitted" \
			and str(details.get("execution", "")) \
				== "job_hunt_application" \
			and str(details.get("onboarding_origin", "")) \
				== W1_ONBOARDING_ORIGIN \
			and int(details.get("quality", -1)) in range(0, 4) \
			and str(details.get("capacity_id", "")) \
				== str(onboarding.get("selected_capacity_id", "")) \
			and int(details.get("capacity_value", 0)) \
				== int(onboarding.get("selected_capacity_value", 0)) \
			and live_status in ["submitted", "interviewed"] \
			and raw_transition is Dictionary \
			and str((raw_transition as Dictionary).get("source", "")) \
				== "typed_action_receipt" \
			and str((raw_transition as Dictionary).get("from", "")) \
				== "not_submitted" \
			and str((raw_transition as Dictionary).get("to", "")) \
				== "submitted"
	# Old pre-plan saves have no ORDER-101 marker. Preserve their exact authored
	# provenance; a free application status without that legacy write is not
	# enough to rewrite Father's incoming-call history.
	return bool(GameState.flags.get(
		"opening_preplan_application_sent", false))

static func _relationship_outcome_for_choice(
		bundle_id: String, event_id: String, choice_index: int,
		evidence_state: Dictionary = {}) -> Dictionary:
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
				var resolved: Dictionary = outcome.duplicate(true)
				# Before the 125-year return scene existed, Father initiated the
				# first call. Preserve that actual schema-2/schema-3 history and
				# in-progress plan; only the new missed-call route is player-led.
				if bundle_id == "father_first_call" \
						and event_id == "arc_father_01_call" \
						and not _opening_application_provenance_valid(
							evidence_state if not evidence_state.is_empty() else
							GameState.core_loop_v2_state):
					resolved["initiative"] = "reciprocal"
				return resolved
	return {}
