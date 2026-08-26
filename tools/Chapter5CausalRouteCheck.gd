extends Node
## ORDER-133: executable proof for the product-owned M49-M55 causal route.

const ROUTE := preload("res://systems/Chapter5CausalRoute.gd")
const STORY_MODE := preload("res://scenes/StoryMode.gd")
const LEDGER_PATH := "res://content/meta/chapter5_causal_ledger.json"
const KO_DRAMA_PATH := "res://content/events/arc_drama.json"
const ROOT_IDS: Array[String] = [
	"arc_y5_contract_cover_investment",
	"arc_y5_contract_reviewer_delivery_sangchul",
	"arc_y5_final_push_deadline_investment",
	"arc_y5_protection_boundary_daeun",
	"arc_y5_burnout_check_reference",
	"arc_y5_minseo_goal_cost_reference",
	"arc_y5_after_goal_daeun",
	"arc_y5_final_offer",
	"arc_y5_final_offer_reference_delivery",
	"arc_y5_jaehyuk_guarantee_request_reference",
	"arc_y5_jaehyuk_return_call_reference",
	"arc_y5_jaehyuk_father_document_reference",
	"arc_y5_guarantee_protected_show_daeun",
	"arc_y5_jaehyuk_guarantee_decision_reference",
	"arc_sangchul_final_door",
	"arc_y5_sangchul_review_receipt",
	"arc_y5_three_in_room",
	"arc_y5_three_in_room_decision",
	"arc_y5_room_consent_receipt",
]
const ROOT_TURNS: Array[int] = [
	195, 196, 197, 200, 201, 203, 204, 207, 208, 209,
	210, 210, 211, 212, 215, 216, 217, 219, 220,
]
const ROOT_MONTHS: Array[int] = [
	49, 49, 50, 50, 51, 51, 51, 52, 52, 53,
	53, 53, 53, 53, 54, 54, 55, 55, 55,
]
const CHOICE_COUNTS: Array[int] = [
	3, 3, 3, 3, 3, 3, 3, 3, 1, 1, 3, 1, 3, 3, 3, 1, 3, 3, 1,
]
const HAPPY_CHOICES: Array[int] = [
	2, 1, 0, 2, 1, 0, 2, 1, 0, 0, 2, 0, 1, 2, 0, 0, 1, 1, 0,
]
const READ_SOURCES := {
	"arc_y5_contract_reviewer_delivery_sangchul": ["arc_y5_contract_cover_investment"],
	"arc_y5_final_push_deadline_investment": ["arc_y5_contract_reviewer_delivery_sangchul"],
	"arc_y5_protection_boundary_daeun": ["arc_y5_final_push_deadline_investment"],
	"arc_y5_burnout_check_reference": ["arc_y5_protection_boundary_daeun"],
	"arc_y5_minseo_goal_cost_reference": ["arc_y5_burnout_check_reference"],
	"arc_y5_after_goal_daeun": ["arc_y5_minseo_goal_cost_reference"],
	"arc_y5_final_offer": ["arc_y5_after_goal_daeun"],
	"arc_y5_final_offer_reference_delivery": ["arc_y5_final_offer"],
	"arc_y5_jaehyuk_guarantee_request_reference": ["arc_y5_final_offer_reference_delivery"],
	"arc_y5_jaehyuk_return_call_reference": ["arc_y5_jaehyuk_guarantee_request_reference"],
	"arc_y5_jaehyuk_father_document_reference": ["arc_y5_jaehyuk_return_call_reference"],
	"arc_y5_guarantee_protected_show_daeun": ["arc_y5_jaehyuk_father_document_reference"],
	"arc_y5_jaehyuk_guarantee_decision_reference": ["arc_y5_guarantee_protected_show_daeun"],
	"arc_sangchul_final_door": ["arc_y5_jaehyuk_guarantee_decision_reference"],
	"arc_y5_three_in_room": [
		"arc_y5_jaehyuk_guarantee_decision_reference",
		"arc_sangchul_final_door",
		"arc_y5_sangchul_review_receipt",
	],
	"arc_y5_three_in_room_decision": ["arc_y5_three_in_room"],
}
const OPTIONAL_READ_SOURCES := {
	"arc_y5_three_in_room": ["arc_y5_sangchul_review_receipt"],
}
const REQUIRED_ENTRY_FLAGS: Array[String] = [
	"arc_sangchul_met_seen",
	"arc_daeun_met",
	"daeun_romance_started",
	"arc_minseo_02_seen",
	"arc_jaehyuk_reunion_seen",
	"arc_jaehyuk_aftermath_seen",
]
const EXCLUDED_ENTRY_FLAGS: Array[String] = [
	"sangchul_reported",
	"sangchul_cut_ties",
	"sangchul_quietly_distanced",
	"daeun_let_her_go",
	"daeun_divorced",
	"blocked_jaehyuk_guarantee",
	"jaehyuk_final_break",
	"arc_jaehyuk_mirror_seen",
	"refused_jaehyuk_guarantee",
	"vouched_jaehyuk_guarantee",
]
const W212_OUTCOMES: Array[Dictionary] = [
	{
		"effects": {"mental": -8, "tint": 7},
		"flags": ["arc_jaehyuk_mirror_seen", "refused_jaehyuk_guarantee"],
	},
	{
		"effects": {"mental": -15, "tint": -6},
		"flags": [
			"arc_jaehyuk_mirror_seen", "vouched_jaehyuk_guarantee",
			"jaehyuk_exploited", "crossed_line",
		],
	},
	{
		"effects": {"mental": -5, "tint": -2},
		"flags": ["arc_jaehyuk_mirror_seen", "blocked_jaehyuk_guarantee"],
	},
]
const ENTRY_SNAPSHOT := {
	"route_id": "investment_property",
	"turn": 195,
	"economic_route": "investment",
	"asset_band": "at_least_2b",
	"actor_bindings": {
		"chooser": "player",
		"proposer": "sangchul",
		"reviewer": "sangchul",
		"protected_person": "daeun",
		"guarantee_party": "jaehyuk",
		"cost_witness": "minseo",
	},
}

var _failures: Array[String] = []


func _ready() -> void:
	_check_ledger_inventory()
	_check_product_path_eligibility()
	_check_entry_lock_integrity()
	_check_w212_singular_guarantee_outcomes()
	_check_happy_path_and_idempotence()
	_check_conditional_receipts()
	_check_malformed_and_legacy_fail_closed()
	_check_game_state_save_and_effect_isolation()
	_check_localized_causal_reads()
	_check_canonical_read_surface_close()
	_check_owned_variant_loop_breakers()
	if _failures.is_empty():
		print(
			"CHAPTER5_CAUSAL_ROUTE_CHECK_OK roots=19 choices=47 "
			+ "entry=investment/2b/participants/durable-lock continuation=entry-ratchet "
			+ "w212=singular-mirror-semantics "
			+ "w210=ordered conditional=2 write_once=1 idempotent=1 "
			+ "save=disk_roundtrip corrupt=closed legacy=closed effects=none "
			+ "reads=ko_en_selected optional=skip gallery=state_free close=canonical "
			+ "variant=closed")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("CHAPTER5_CAUSAL_ROUTE_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)


func _check_ledger_inventory() -> void:
	var parsed: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(LEDGER_PATH))
	_expect(parsed is Dictionary, "causal ledger is not a JSON object")
	if not parsed is Dictionary:
		return
	var ledger: Dictionary = parsed
	_expect(int(ledger.get("schema_version", -1)) == 1,
		"causal ledger schema is not 1")
	_expect(str(ledger.get("ledger_id", "")) \
		== "chapter5_m49_m55_causal_route_v1",
		"causal ledger id drifted")
	_expect(int(ledger.get("choice_index_base", -1)) == 0,
		"causal ledger choice index is not zero-based")
	_expect(int(ledger.get("expected_root_count", -1)) == 19,
		"causal ledger declared root count drifted")
	_expect(int(ledger.get("expected_choice_count", -1)) == 47,
		"causal ledger declared choice count drifted")
	var ledger_entry: Dictionary = (
		ledger.get("entry_contract", {}) as Dictionary).duplicate(true)
	if ledger_entry.has("turn"):
		ledger_entry["turn"] = int(ledger_entry["turn"])
	_expect(_same(ledger_entry, ENTRY_SNAPSHOT),
		"causal ledger durable entry contract drifted")
	var roots: Array = ledger.get("roots", [])
	_expect(roots.size() == 19, "causal ledger does not contain exact 19 roots")
	var choice_total := 0
	for index in range(mini(roots.size(), ROOT_IDS.size())):
		var raw_root: Variant = roots[index]
		_expect(raw_root is Dictionary,
			"root %d is not an object" % (index + 1))
		if not raw_root is Dictionary:
			continue
		var root: Dictionary = raw_root
		_expect(int(root.get("sequence", -1)) == index + 1,
			"root %d sequence drifted" % (index + 1))
		_expect(str(root.get("event_id", "")) == ROOT_IDS[index],
			"root %d event id drifted" % (index + 1))
		_expect(int(root.get("turn", -1)) == ROOT_TURNS[index],
			"%s exact week drifted" % ROOT_IDS[index])
		_expect(int(root.get("month", -1)) == ROOT_MONTHS[index],
			"%s exact month drifted" % ROOT_IDS[index])
		var actors: Variant = root.get("actor_bindings")
		_expect(actors is Dictionary and not (actors as Dictionary).is_empty() \
			and str((actors as Dictionary).get("chooser", "")) == "player",
			"%s lost its exact actor bindings" % ROOT_IDS[index])
		var choices: Array = root.get("choices", [])
		choice_total += choices.size()
		_expect(choices.size() == CHOICE_COUNTS[index],
			"%s authored choice count drifted" % ROOT_IDS[index])
		for choice_index in range(choices.size()):
			var raw_choice: Variant = choices[choice_index]
			_expect(raw_choice is Dictionary,
				"%s choice %d is not an object" % [ROOT_IDS[index], choice_index])
			if not raw_choice is Dictionary:
				continue
			var choice: Dictionary = raw_choice
			_expect(int(choice.get("index", -1)) == choice_index,
				"%s choice index order drifted" % ROOT_IDS[index])
			var receipts: Array = choice.get("receipts", [])
			_expect(not receipts.is_empty(),
				"%s choice %d has no document receipt" % [ROOT_IDS[index], choice_index])
			for raw_receipt in receipts:
				_expect(raw_receipt is Dictionary \
					and not str((raw_receipt as Dictionary).get("receipt_type", "")).is_empty() \
					and not str((raw_receipt as Dictionary).get("receipt_id", "")).is_empty() \
					and (raw_receipt as Dictionary).get("document_ids", []) is Array \
					and not ((raw_receipt as Dictionary).get("document_ids", []) as Array).is_empty(),
					"%s choice %d has a malformed document/custody receipt" % [
						ROOT_IDS[index], choice_index])
	_expect(choice_total == 47,
		"causal ledger choice population is %d, expected 47" % choice_total)
	var review_condition: Dictionary = (
		roots[15].get("condition", {}) if roots.size() > 15 else {})
	var consent_condition: Dictionary = (
		roots[18].get("condition", {}) if roots.size() > 18 else {})
	_expect(str(review_condition.get("event_id", "")) \
		== "arc_sangchul_final_door" \
		and int(review_condition.get("choice_index", -1)) == 0 \
		and str(consent_condition.get("event_id", "")) \
		== "arc_y5_three_in_room_decision" \
		and int(consent_condition.get("choice_index", -1)) == 1,
		"conditional receipt producer choices drifted")


func _check_product_path_eligibility() -> void:
	var empty := ROUTE.default_state()
	_expect(not ROUTE.product_path_available(
		empty, "직장형", true, true, 2_000_000_000.0),
		"career route entered the investment property vertical")
	_expect(not ROUTE.product_path_available(
		empty, "창업형", true, true, 2_000_000_000.0),
		"startup route entered the investment property vertical")
	_expect(not ROUTE.product_path_available(
		empty, "투자형", false, true, 2_000_000_000.0),
		"unearned investment identity entered the property vertical")
	_expect(not ROUTE.product_path_available(
		empty, "투자형", true, false, 2_000_000_000.0),
		"missing participant history entered the property vertical")
	_expect(not ROUTE.product_path_available(
		empty, "투자형", true, true, 1_999_999_999.0),
		"sub-2-billion run entered the near-goal property vertical")
	_expect(not ROUTE.product_path_available(
		empty, "투자형", true, true, INF),
		"nonfinite assets entered the property vertical")
	_expect(ROUTE.product_path_available(
		empty, "투자형", true, true, 2_000_000_000.0),
		"exact eligible investment path could not enter at 2 billion")

	var first_receipt := _commit_exact(empty, 0, 2)
	_expect(ROUTE.product_path_available(
		first_receipt, "직장형", false, false, 0.0),
		"first receipt did not ratchet route continuation")

	# Exercise the actual GameState prerequisite surface, not only reducer inputs.
	_prepare_chapter5_product_path()
	_expect(GameState.chapter5_causal_product_path_available() \
		and GameState.chapter5_causal_next_event_for_turn() == ROOT_IDS[0],
		"committed investment Path B with actual cast context was rejected")
	for route_name in ["직장형", "창업형"]:
		_prepare_chapter5_product_path()
		GameState.player_route = route_name
		_expect(not GameState.chapter5_causal_product_path_available() \
			and GameState.chapter5_causal_next_event_for_turn().is_empty(),
			"%s GameState route received the 19-root investment vertical" % route_name)

	_prepare_chapter5_product_path()
	GameState.flags.erase("route_invest")
	_expect(not GameState.chapter5_causal_product_path_available(),
		"GameState player_route alone invented earned investment identity")
	_prepare_chapter5_product_path()
	GameState.money = 1_999_999_999.0
	_expect(not GameState.chapter5_causal_product_path_available(),
		"GameState accepted a run below the exact 2-billion ingress floor")

	for missing_flag in REQUIRED_ENTRY_FLAGS:
		_prepare_chapter5_product_path()
		GameState.flags.erase(missing_flag)
		_expect(not GameState.chapter5_causal_product_path_available(),
			"missing participant prerequisite was accepted: %s" % missing_flag)
	for excluded_flag in EXCLUDED_ENTRY_FLAGS:
		_prepare_chapter5_product_path()
		GameState.flags[excluded_flag] = true
		_expect(not GameState.chapter5_causal_product_path_available(),
			"excluded participant outcome was accepted: %s" % excluded_flag)

	# Path A sent Daeun away. Even a wealthy earned investment run must not
	# manufacture her as an active participant in the fixed three-person room.
	_prepare_chapter5_product_path()
	GameState.flags["daeun_let_her_go"] = true
	_expect(not GameState.chapter5_causal_product_path_available() \
		and GameState.chapter5_causal_next_event_for_turn().is_empty(),
		"Daeun-sent-away Path A received the property vertical")

	# Once the first paper exists, later market/relationship changes cannot erase
	# the already-started chain. This is continuation, not a new ingress bypass.
	_prepare_chapter5_product_path()
	var unlocked := GameState.chapter5_causal_state.duplicate(true)
	var bad_index := GameState.record_chapter5_causal_choice(ROOT_IDS[0], 3)
	_expect(not bool(bad_index.get("ok", false)) \
		and _same(GameState.chapter5_causal_state, unlocked) \
		and GameState.chapter5_causal_entry_snapshot().is_empty(),
		"bad direct choice left a durable entry without a receipt")
	var wrong_root := GameState.record_chapter5_causal_choice(ROOT_IDS[1], 0)
	_expect(not bool(wrong_root.get("ok", false)) \
		and _same(GameState.chapter5_causal_state, unlocked) \
		and GameState.chapter5_causal_entry_snapshot().is_empty(),
		"out-of-order direct callback left an entry-only partial state")
	var committed := GameState.record_chapter5_causal_choice(ROOT_IDS[0], 2)
	GameState.turn = 196
	GameState.player_route = "직장형"
	GameState.flags.erase("route_invest")
	GameState.flags["daeun_let_her_go"] = true
	GameState.flags["sangchul_cut_ties"] = true
	GameState.money = 0.0
	_expect(bool(committed.get("ok", false)) \
		and GameState.chapter5_causal_product_path_available() \
		and GameState.chapter5_causal_next_event_for_turn() == ROOT_IDS[1],
		"first receipt did not preserve W196 continuation after external gates fell")


func _check_entry_lock_integrity() -> void:
	var empty := ROUTE.default_state()
	_expect(not ROUTE.entry_locked(empty) \
		and ROUTE.entry_snapshot(empty).is_empty(),
		"fresh route invented a durable entry context")
	for rejected in [
		ROUTE.lock_entry(empty, 194, "투자형", true, true, 2_000_000_000.0),
		ROUTE.lock_entry(empty, 195, "직장형", true, true, 2_000_000_000.0),
		ROUTE.lock_entry(empty, 195, "창업형", true, true, 2_000_000_000.0),
		ROUTE.lock_entry(empty, 195, "투자형", false, true, 2_000_000_000.0),
		ROUTE.lock_entry(empty, 195, "투자형", true, false, 2_000_000_000.0),
		ROUTE.lock_entry(empty, 195, "투자형", true, true, 1_999_999_999.0),
	]:
		_expect(not bool((rejected as Dictionary).get("ok", false)) \
			and _same((rejected as Dictionary).get("state", {}), empty),
			"ineligible entry lock mutated the fresh route")
	var locked_result := ROUTE.lock_entry(
		empty, 195, "투자형", true, true, 2_000_000_000.0)
	var locked: Dictionary = locked_result.get("state", {})
	_expect(bool(locked_result.get("ok", false)) \
		and not bool(locked_result.get("idempotent", true)) \
		and ROUTE.entry_locked(locked) \
		and ROUTE.entry_snapshot(locked) == ENTRY_SNAPSHOT,
		"eligible W195 context did not become the exact durable entry lock")
	var replay := ROUTE.lock_entry(
		locked, 220, "직장형", false, false, 0.0)
	_expect(bool(replay.get("ok", false)) \
		and bool(replay.get("idempotent", false)) \
		and _same(replay.get("state", {}), locked),
		"locked entry was not sticky/idempotent after external context changed")

	var tampered_entries: Array[Dictionary] = []
	var route_tamper := locked.duplicate(true)
	(route_tamper["entry"] as Dictionary)["route_id"] = "career_property"
	tampered_entries.append(route_tamper)
	var turn_tamper := locked.duplicate(true)
	(turn_tamper["entry"] as Dictionary)["turn"] = 196
	tampered_entries.append(turn_tamper)
	var actor_tamper := locked.duplicate(true)
	((actor_tamper["entry"] as Dictionary)["actor_bindings"] \
		as Dictionary)["protected_person"] = "jiyeon"
	tampered_entries.append(actor_tamper)
	for index in range(tampered_entries.size()):
		var closed := ROUTE.state_from_save(tampered_entries[index], true)
		_expect(str(closed.get("status", "")) == "closed" \
			and (closed.get("entry", {}) as Dictionary).is_empty() \
			and ROUTE.next_event_for_turn(closed, 195).is_empty(),
			"tampered durable entry %d did not fail closed" % index)


func _check_w212_singular_guarantee_outcomes() -> void:
	var raw_rows: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(KO_DRAMA_PATH))
	var raw_event: Variant = null
	if raw_rows is Array:
		for candidate in raw_rows as Array:
			if candidate is Dictionary \
					and str((candidate as Dictionary).get("id", "")) == ROOT_IDS[13]:
				raw_event = (candidate as Dictionary).duplicate(true)
				break
	_expect(raw_event is Dictionary,
		"W212 relocated guarantee decision event is missing")
	if not raw_event is Dictionary:
		return
	var event: Dictionary = raw_event
	var choices: Array = event.get("choices", [])
	_expect(choices.size() == W212_OUTCOMES.size(),
		"W212 guarantee decision lost its exact three outcomes")
	for index in range(mini(choices.size(), W212_OUTCOMES.size())):
		var raw_choice: Variant = choices[index]
		_expect(raw_choice is Dictionary,
			"W212 choice %d is malformed" % index)
		if not raw_choice is Dictionary:
			continue
		var choice: Dictionary = raw_choice
		var expected: Dictionary = W212_OUTCOMES[index]
		var actual_effects: Dictionary = choice.get("effects", {})
		var expected_effects: Dictionary = expected["effects"]
		_expect(actual_effects.keys().size() == 2 \
			and actual_effects.has("mental") and actual_effects.has("tint") \
			and int(actual_effects.get("mental", 0)) \
				== int(expected_effects["mental"]) \
			and is_equal_approx(float(actual_effects.get("tint", 0.0)), \
				float(expected_effects["tint"])) \
			and choice.get("flags", []) == expected["flags"],
			"W212 choice %d drifted from the singular mirror outcome" % index)

		# Apply through the same GameState path StoryMode uses. Start below the
		# crossed-line cap so choice 1 exposes its authored -6 tint delta exactly.
		GameState.start_new_game()
		GameState.mental = 60
		GameState.moral_tint = -30.0
		var applied := GameState.apply_choice(event, choice)
		_expect(applied \
			and GameState.mental == 60 + int(expected_effects["mental"]) \
			and is_equal_approx(
				GameState.moral_tint, -30.0 + float(expected_effects["tint"])),
			"W212 choice %d did not apply canonical mental/tint state" % index)
		for raw_flag in expected["flags"]:
			var flag := str(raw_flag)
			_expect(bool(GameState.flags.get(flag, false)),
				"W212 choice %d did not write canonical flag %s" % [index, flag])
		for exclusive_flag in [
			"refused_jaehyuk_guarantee",
			"vouched_jaehyuk_guarantee",
			"blocked_jaehyuk_guarantee",
		]:
			_expect(bool(GameState.flags.get(exclusive_flag, false)) \
				== (exclusive_flag in (expected["flags"] as Array)),
				"W212 choice %d wrote a conflicting guarantee outcome" % index)


func _check_happy_path_and_idempotence() -> void:
	var state := ROUTE.default_state()
	_expect(ROUTE.next_event_for_turn(state, 194).is_empty(),
		"route opened before W195")
	_expect(not ROUTE.is_owned_event("arc_y5_contract_cover_career"),
		"reference-only career root became product-owned")
	for event_id in ROOT_IDS:
		_expect(ROUTE.is_owned_event(event_id),
			"owned root missing from immutable safety boundary: %s" % event_id)

	var out_of_order := ROUTE.commit_choice(
		state, ROOT_IDS[1], 0, ROOT_TURNS[1])
	_expect(not bool(out_of_order.get("ok", false)) \
		and _same(out_of_order.get("state", {}), state),
		"out-of-order root mutated the empty ledger")
	var wrong_turn := ROUTE.commit_choice(state, ROOT_IDS[0], 0, 196)
	_expect(not bool(wrong_turn.get("ok", false)) \
		and _same(wrong_turn.get("state", {}), state),
		"wrong-week choice mutated the empty ledger")
	var wrong_index := ROUTE.commit_choice(state, ROOT_IDS[0], 3, 195)
	_expect(not bool(wrong_index.get("ok", false)) \
		and _same(wrong_index.get("state", {}), state),
		"out-of-range choice mutated the empty ledger")
	var locked_result := ROUTE.lock_entry(
		state, 195, "투자형", true, true, 2_000_000_000.0)
	_expect(bool(locked_result.get("ok", false)),
		"happy path could not lock its exact W195 entry: %s" \
			% str(locked_result.get("error", "")))
	if not bool(locked_result.get("ok", false)):
		return
	state = (locked_result.get("state", state) as Dictionary).duplicate(true)

	for index in range(ROOT_IDS.size()):
		var event_id := ROOT_IDS[index]
		var at_turn := ROOT_TURNS[index]
		var choice_index := HAPPY_CHOICES[index]
		_expect(ROUTE.next_event_for_turn(state, at_turn) == event_id,
			"%s was not next at W%d" % [event_id, at_turn])
		_expect(ROUTE.ingress_available(state, event_id, at_turn),
			"%s exact ingress was unavailable" % event_id)
		_expect(ROUTE.choice_commit_available(
			state, event_id, choice_index, at_turn),
			"%s valid choice was unavailable" % event_id)
		var before := state.duplicate(true)
		var result := ROUTE.commit_choice(
			state, event_id, choice_index, at_turn)
		_expect(bool(result.get("ok", false)) \
			and not bool(result.get("idempotent", true)),
			"%s first commit was not a write-once success" % event_id)
		state = (result.get("state", before) as Dictionary).duplicate(true)
		_expect(not _same(state, before),
			"%s first commit did not write a receipt" % event_id)
		_expect(ROUTE.receipt_matches(
			state, event_id, choice_index, at_turn),
			"%s committed receipt does not match actor/document evidence" % event_id)

		var replay_before := state.duplicate(true)
		var replay := ROUTE.commit_choice(
			state, event_id, choice_index, at_turn)
		_expect(bool(replay.get("ok", false)) \
			and bool(replay.get("idempotent", false)) \
			and _same(replay.get("state", {}), replay_before),
			"%s exact duplicate was not idempotent" % event_id)
		if CHOICE_COUNTS[index] > 1:
			var conflicting_index := (choice_index + 1) % CHOICE_COUNTS[index]
			var conflict := ROUTE.commit_choice(
				state, event_id, conflicting_index, at_turn)
			_expect(not bool(conflict.get("ok", false)) \
				and _same(conflict.get("state", {}), state),
				"%s conflicting callback overwrote its receipt" % event_id)

		if index == 10:
			_expect(not ROUTE.week_completed(state, 210) \
				and ROUTE.next_event_for_turn(state, 210) == ROOT_IDS[11],
				"W210 return call did not preserve father-document root ordering")
		elif index == 11:
			_expect(ROUTE.week_completed(state, 210),
				"W210 did not close after its ordered second root")
		else:
			_expect(ROUTE.week_completed(state, at_turn),
				"%s did not complete its owned week" % event_id)

	_expect((state.get("order", []) as Array).size() == 19 \
		and (state.get("receipts", {}) as Dictionary).size() == 19,
		"happy route did not end with exact 19 write-once receipts")
	_expect(ROUTE.next_event_for_turn(state, 220).is_empty(),
		"completed route still exposed a root")


func _check_conditional_receipts() -> void:
	for producer_choice in range(3):
		var state := ROUTE.default_state()
		for index in range(14):
			state = _commit_exact(state, index, 0)
		state = _commit_exact(state, 14, producer_choice)
		var should_open := producer_choice == 0
		_expect(ROUTE.next_event_for_turn(state, 216) \
			== (ROOT_IDS[15] if should_open else ""),
			"W216 review receipt activation drifted for door choice %d" \
				% producer_choice)
		_expect(ROUTE.ingress_available(state, ROOT_IDS[15], 216) \
			== should_open,
			"W216 ingress invented or lost the red-circle receipt for door choice %d" \
				% producer_choice)

	for producer_choice in range(3):
		var state := ROUTE.default_state()
		for index in range(15):
			var choice_index := 1 if index == 14 else 0
			state = _commit_exact(state, index, choice_index)
		# Door choice 1 skips conditional root 16; continue at the room roots.
		state = _commit_exact(state, 16, 0)
		state = _commit_exact(state, 17, producer_choice)
		var should_open := producer_choice == 1
		_expect(ROUTE.next_event_for_turn(state, 220) \
			== (ROOT_IDS[18] if should_open else ""),
			"W220 consent receipt activation drifted for room choice %d" \
				% producer_choice)
		_expect(ROUTE.ingress_available(state, ROOT_IDS[18], 220) \
			== should_open,
			"W220 ingress invented or lost handwritten consent for room choice %d" \
				% producer_choice)


func _check_malformed_and_legacy_fail_closed() -> void:
	var legacy := ROUTE.state_from_save(null, false)
	_expect(str(legacy.get("status", "")) == "closed" \
		and str(legacy.get("closed_reason", "")) == "legacy_missing" \
		and (legacy.get("receipts", {}) as Dictionary).is_empty() \
		and ROUTE.next_event_for_turn(legacy, 195).is_empty(),
		"legacy save did not fail closed without inferred receipts")
	var malformed_type := ROUTE.state_from_save("not-a-ledger", true)
	_expect(str(malformed_type.get("status", "")) == "closed" \
		and ROUTE.next_event_for_turn(malformed_type, 195).is_empty(),
		"non-dictionary save did not fail closed")

	var valid := _commit_exact(ROUTE.default_state(), 0, 2)
	if not (valid.get("receipts", {}) as Dictionary).has(ROOT_IDS[0]):
		_expect(false, "tamper fixture has no first receipt")
		return
	var damaged_states: Array[Dictionary] = []
	var event_tamper := valid.duplicate(true)
	(event_tamper["receipts"][ROOT_IDS[0]] as Dictionary)["event_id"] = "forged"
	damaged_states.append(event_tamper)
	var turn_tamper := valid.duplicate(true)
	(turn_tamper["receipts"][ROOT_IDS[0]] as Dictionary)["turn"] = 196
	damaged_states.append(turn_tamper)
	var choice_tamper := valid.duplicate(true)
	(choice_tamper["receipts"][ROOT_IDS[0]] as Dictionary)["choice_index"] = 1
	damaged_states.append(choice_tamper)
	var actor_tamper := valid.duplicate(true)
	var actors: Dictionary = actor_tamper["receipts"][ROOT_IDS[0]]["actor_bindings"]
	actors["protected_person"] = "jaehyuk"
	damaged_states.append(actor_tamper)
	var document_tamper := valid.duplicate(true)
	var evidence: Dictionary = document_tamper["receipts"][ROOT_IDS[0]]["receipts"][0]
	evidence["document_ids"] = ["FORGED-DOCUMENT"]
	damaged_states.append(document_tamper)
	var custody_tamper := valid.duplicate(true)
	var custody: Dictionary = custody_tamper["receipts"][ROOT_IDS[0]]["receipts"][0]
	custody["receipt_id"] = "forged_custody"
	damaged_states.append(custody_tamper)
	var order_tamper := valid.duplicate(true)
	(order_tamper["order"] as Array).append(ROOT_IDS[0])
	damaged_states.append(order_tamper)
	var schema_tamper := valid.duplicate(true)
	schema_tamper["invented_key"] = true
	damaged_states.append(schema_tamper)

	for index in range(damaged_states.size()):
		var damaged := damaged_states[index]
		var closed := ROUTE.state_from_save(damaged, true)
		_expect(str(closed.get("status", "")) == "closed" \
			and (closed.get("receipts", {}) as Dictionary).is_empty() \
			and ROUTE.next_event_for_turn(closed, 196).is_empty(),
			"damaged state %d did not fail closed" % index)
		var rejected := ROUTE.commit_choice(damaged, ROOT_IDS[1], 0, 196)
		_expect(not bool(rejected.get("ok", false)) \
			and _same(rejected.get("state", {}), damaged),
			"damaged state %d gained a receipt during rejection" % index)


func _check_game_state_save_and_effect_isolation() -> void:
	_prepare_chapter5_product_path()
	GameState.money = 2_012_345_678.0
	GameState.action_points = 1
	GameState.is_game_over = false
	_expect(GameState.chapter5_causal_next_event_for_turn() == ROOT_IDS[0] \
		and GameState.chapter5_causal_ingress_available(ROOT_IDS[0]) \
		and GameState.chapter5_causal_choice_available(ROOT_IDS[0], 2),
		"GameState wrapper did not expose exact W195 ingress")
	var before: Dictionary = GameState.serialize().duplicate(true)
	var result: Dictionary = GameState.record_chapter5_causal_choice(ROOT_IDS[0], 2)
	var after: Dictionary = GameState.serialize().duplicate(true)
	var written_state: Dictionary = GameState.chapter5_causal_state.duplicate(true)
	before.erase("chapter5_causal_state")
	after.erase("chapter5_causal_state")
	_expect(bool(result.get("ok", false)) \
		and GameState.chapter5_causal_receipt_matches(ROOT_IDS[0], 2, 195),
		"GameState wrapper did not commit the exact W195 receipt")
	_expect(_same(before, after),
		"Chapter 5 receipt changed money/AP/stats/transactions/ending state")

	var replay := GameState.record_chapter5_causal_choice(ROOT_IDS[0], 2)
	_expect(bool(replay.get("ok", false)) \
		and bool(replay.get("idempotent", false)) \
		and _same(GameState.chapter5_causal_state, written_state),
		"GameState duplicate callback was not idempotent")

	var saved: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	_expect(_same(GameState.chapter5_causal_state, written_state) \
		and GameState.chapter5_causal_receipt_matches(ROOT_IDS[0], 2, 195),
		"Chapter 5 receipt did not survive GameState save/load")

	# SaveManager's real boundary is JSON, not a duplicate(true) dictionary.
	# Parsed whole numbers arrive as floats and must be normalized only in the
	# declared Chapter 5 integer slots before canonical validation.
	var disk_parsed: Variant = JSON.parse_string(JSON.stringify(saved))
	_expect(disk_parsed is Dictionary,
		"serialized GameState did not survive JSON parsing")
	if disk_parsed is Dictionary:
		GameState.start_new_game()
		GameState.load_from_dict(disk_parsed as Dictionary)
		var disk_entry: Dictionary = GameState.chapter5_causal_entry_snapshot()
		var disk_receipt: Dictionary = GameState.chapter5_causal_receipt_snapshot(
			ROOT_IDS[0])
		_expect(not disk_receipt.is_empty() \
			and disk_entry == ENTRY_SNAPSHOT \
			and typeof(disk_entry.get("turn")) == TYPE_INT \
			and typeof(GameState.chapter5_causal_state.get("schema_version")) == TYPE_INT \
			and typeof(disk_receipt.get("sequence")) == TYPE_INT \
			and typeof(disk_receipt.get("turn")) == TYPE_INT \
			and typeof(disk_receipt.get("choice_index")) == TYPE_INT \
			and GameState.chapter5_causal_receipt_matches(ROOT_IDS[0], 2, 195),
			"whole-number JSON disk receipt did not normalize to exact ints")

	var fractional_state := written_state.duplicate(true)
	(fractional_state["receipts"][ROOT_IDS[0]] as Dictionary)["turn"] = 195.5
	var fractional_closed := ROUTE.state_from_save(fractional_state, true)
	_expect(str(fractional_closed.get("status", "")) == "closed" \
		and (fractional_closed.get("receipts", {}) as Dictionary).is_empty(),
		"fractional JSON-like receipt integer was accepted")
	var nonfinite_state := written_state.duplicate(true)
	(nonfinite_state["receipts"][ROOT_IDS[0]] as Dictionary)["sequence"] = INF
	var nonfinite_closed := ROUTE.state_from_save(nonfinite_state, true)
	_expect(str(nonfinite_closed.get("status", "")) == "closed" \
		and (nonfinite_closed.get("receipts", {}) as Dictionary).is_empty(),
		"nonfinite receipt integer was accepted")
	var wrong_integer_state := written_state.duplicate(true)
	(wrong_integer_state["receipts"][ROOT_IDS[0]] as Dictionary)["choice_index"] = "2"
	var wrong_integer_closed := ROUTE.state_from_save(wrong_integer_state, true)
	_expect(str(wrong_integer_closed.get("status", "")) == "closed" \
		and (wrong_integer_closed.get("receipts", {}) as Dictionary).is_empty(),
		"string receipt integer was accepted")

	var corrupt_save := saved.duplicate(true)
	var corrupt_state: Dictionary = corrupt_save["chapter5_causal_state"]
	if not (corrupt_state.get("receipts", {}) as Dictionary).has(ROOT_IDS[0]):
		_expect(false, "save fixture has no first Chapter 5 receipt")
		return
	var corrupt_receipt: Dictionary = corrupt_state["receipts"][ROOT_IDS[0]]
	corrupt_receipt["actor_bindings"] = {"chooser": "player"}
	GameState.start_new_game()
	GameState.load_from_dict(corrupt_save)
	_expect(str(GameState.chapter5_causal_state.get("status", "")) == "closed" \
		and GameState.chapter5_causal_next_event_for_turn(196).is_empty(),
		"corrupt Chapter 5 save did not fail closed in GameState")

	var tampered_entry_save := saved.duplicate(true)
	var tampered_entry_state: Dictionary = \
		tampered_entry_save["chapter5_causal_state"]
	(tampered_entry_state["entry"] as Dictionary)["economic_route"] = "career"
	GameState.start_new_game()
	GameState.load_from_dict(tampered_entry_save)
	_expect(str(GameState.chapter5_causal_state.get("status", "")) == "closed" \
		and (GameState.chapter5_causal_state.get("entry", {}) \
			as Dictionary).is_empty() \
		and GameState.chapter5_causal_next_event_for_turn(196).is_empty(),
		"tampered durable entry did not fail closed in GameState")

	var legacy_save := saved.duplicate(true)
	legacy_save.erase("chapter5_causal_state")
	GameState.start_new_game()
	GameState.load_from_dict(legacy_save)
	_expect(str(GameState.chapter5_causal_state.get("status", "")) == "closed" \
		and str(GameState.chapter5_causal_state.get("closed_reason", "")) \
			== "legacy_missing" \
		and GameState.chapter5_causal_next_event_for_turn(196).is_empty(),
		"legacy GameState save inferred Chapter 5 evidence")


func _check_localized_causal_reads() -> void:
	var original_language: String = LocaleManager.language
	var story: Node = STORY_MODE.new()
	for language in ["ko", "en"]:
		LocaleManager.set_language(language)
		DataRegistry.reload()
		for raw_target_id in READ_SOURCES:
			var target_id := str(raw_target_id)
			var target_index := ROOT_IDS.find(target_id)
			var raw_event: Variant = DataRegistry.find_event(target_id)
			_expect(raw_event is Dictionary,
				"%s %s causal-read event is missing" % [language, target_id])
			if not raw_event is Dictionary:
				continue
			var event: Dictionary = (raw_event as Dictionary).duplicate(true)
			var expected_contract: Dictionary = ROUTE.expected_read_contract(target_id)
			var source_ids: Array = READ_SOURCES[target_id]
			_expect(expected_contract.get("source_event_ids", []) == source_ids \
				and expected_contract.get("optional_source_event_ids", []) \
					== OPTIONAL_READ_SOURCES.get(target_id, []),
				"%s runtime read mapping drifted" % target_id)
			for raw_source_id in source_ids:
				var source_id := str(raw_source_id)
				var source_index := ROOT_IDS.find(source_id)
				_expect(source_index >= 0,
					"%s read source is not owned" % source_id)
				if source_index < 0:
					continue
				for selected_choice in range(CHOICE_COUNTS[source_index]):
					var overrides := {source_id: selected_choice}
					if source_id == ROOT_IDS[15]:
						# The optional W216 receipt exists only through W215 choice 0.
						overrides[ROOT_IDS[14]] = 0
					var state := _state_before_target(target_index, overrides)
					GameState.chapter5_causal_state = state.duplicate(true)
					_expect(ROUTE.selected_choice(state, source_id) == selected_choice,
						"%s fixture did not preserve source choice %d" % [
							source_id, selected_choice])
					var raw_resolved: Variant = story.call(
						"_chapter5_causal_event_with_reads", event)
					_expect(raw_resolved is Dictionary \
						and not (raw_resolved as Dictionary).is_empty(),
						"%s %s choice %d did not resolve causal prose" % [
							language, source_id, selected_choice])
					if raw_resolved is Dictionary:
						var expected_description := _expected_read_description(event, state)
						_expect(str((raw_resolved as Dictionary).get(
							"description", "")) == expected_description,
							"%s %s choice %d selected the wrong localized prefix" % [
								language, source_id, selected_choice])

	# A required predecessor must never be invented from gallery/global state.
	LocaleManager.set_language("ko")
	DataRegistry.reload()
	var required_event: Dictionary = (
		DataRegistry.find_event(ROOT_IDS[1]) as Dictionary).duplicate(true)
	GameState.chapter5_causal_state = ROUTE.default_state()
	var missing_required: Variant = story.call(
		"_chapter5_causal_event_with_reads", required_event)
	_expect(missing_required is Dictionary \
		and (missing_required as Dictionary).is_empty(),
		"missing required receipt invented a causal prefix")

	var valid_required_state := _state_before_target(1, {ROOT_IDS[0]: 1})
	var malformed_receipt_state := valid_required_state.duplicate(true)
	(malformed_receipt_state["receipts"][ROOT_IDS[0]] as Dictionary)[
		"choice_index"] = 2
	GameState.chapter5_causal_state = malformed_receipt_state
	var malformed_receipt_read: Variant = story.call(
		"_chapter5_causal_event_with_reads", required_event)
	_expect(malformed_receipt_read is Dictionary \
		and (malformed_receipt_read as Dictionary).is_empty(),
		"malformed required receipt did not fail the read surface closed")

	var malformed_event := required_event.duplicate(true)
	var malformed_reads: Dictionary = malformed_event["chapter5_causal_reads"]
	var malformed_rows: Array = malformed_reads["texts"]
	var malformed_first_row: Array = malformed_rows[0]
	malformed_first_row[1] = malformed_first_row[0]
	malformed_rows[0] = malformed_first_row
	malformed_reads["texts"] = malformed_rows
	malformed_event["chapter5_causal_reads"] = malformed_reads
	GameState.chapter5_causal_state = valid_required_state.duplicate(true)
	var malformed_authored_read: Variant = story.call(
		"_chapter5_causal_event_with_reads", malformed_event)
	_expect(malformed_authored_read is Dictionary \
		and (malformed_authored_read as Dictionary).is_empty(),
		"duplicate authored read prefixes were accepted")

	# W216 is optional for the W217 ensemble ingress. Door choice 1 skips it;
	# the two required predecessor echoes must still render in exact order.
	var room_event: Dictionary = (
		DataRegistry.find_event(ROOT_IDS[16]) as Dictionary).duplicate(true)
	var optional_absent_state := _state_before_target(
		16, {ROOT_IDS[14]: 1})
	GameState.chapter5_causal_state = optional_absent_state.duplicate(true)
	var optional_absent: Variant = story.call(
		"_chapter5_causal_event_with_reads", room_event)
	_expect(optional_absent is Dictionary \
		and not (optional_absent as Dictionary).is_empty() \
		and str((optional_absent as Dictionary).get("description", "")) \
			== _expected_read_description(room_event, optional_absent_state),
		"absent optional W216 receipt did not skip cleanly")
	var room_reads: Dictionary = room_event["chapter5_causal_reads"]
	var optional_text: String = str((room_reads["texts"] as Array)[2][0])
	_expect(not str((optional_absent as Dictionary).get(
		"description", "")).contains(optional_text),
		"absent optional W216 receipt invented its localized prefix")

	# Gallery replay is deliberately state-free: it preserves the authored event
	# byte shape and must neither infer a receipt nor mutate/close the live route.
	GameState.chapter5_causal_state = ROUTE.default_state()
	var gallery_before := GameState.chapter5_causal_state.duplicate(true)
	story.set("_read_only_replay", true)
	var gallery_result: Variant = story.call(
		"_chapter5_causal_event_with_reads", required_event)
	_expect(gallery_result is Dictionary \
		and _same(gallery_result, required_event) \
		and _same(GameState.chapter5_causal_state, gallery_before),
		"gallery replay invented a causal read or changed live state")
	story.set("_read_only_replay", false)

	LocaleManager.set_language(original_language)
	DataRegistry.reload()
	story.free()


func _check_canonical_read_surface_close() -> void:
	var partial := _state_before_target(1, {ROOT_IDS[0]: 2})
	var closed_result := ROUTE.close_route(
		partial, ROUTE.CLOSE_REASON_READ_SURFACE_INVALID)
	var closed: Dictionary = closed_result.get("state", {})
	_expect(bool(closed_result.get("ok", false)) \
		and not bool(closed_result.get("idempotent", true)) \
		and closed.size() == 7 \
		and typeof(closed.get("schema_version")) == TYPE_INT \
		and str(closed.get("ledger_id", "")) \
			== "chapter5_m49_m55_causal_route_v1" \
		and str(closed.get("status", "")) == "closed" \
		and str(closed.get("closed_reason", "")) == "read_surface_invalid" \
		and (closed.get("entry", {}) as Dictionary).is_empty() \
		and (closed.get("receipts", {}) as Dictionary).is_empty() \
		and (closed.get("order", []) as Array).is_empty(),
		"read-surface close did not return the canonical empty closed state")
	var closed_again := ROUTE.close_route(
		closed, ROUTE.CLOSE_REASON_READ_SURFACE_INVALID)
	_expect(bool(closed_again.get("ok", false)) \
		and bool(closed_again.get("idempotent", false)) \
		and _same(closed_again.get("state", {}), closed),
		"canonical route close was not idempotent")
	var closed_reload := ROUTE.state_from_save(closed, true)
	_expect(_same(closed_reload, closed) \
		and ROUTE.next_event_for_turn(closed_reload, 196).is_empty() \
		and not ROUTE.ingress_available(closed_reload, ROOT_IDS[1], 196),
		"closed route reopened after save normalization")
	var rejected_reopen := ROUTE.commit_choice(closed, ROOT_IDS[1], 0, 196)
	_expect(not bool(rejected_reopen.get("ok", false)) \
		and _same(rejected_reopen.get("state", {}), closed),
		"closed route accepted a later receipt")

	var malformed_closed := ROUTE.close_route(
		{"schema_version": INF, "invented": true},
		ROUTE.CLOSE_REASON_READ_SURFACE_INVALID)
	_expect(bool(malformed_closed.get("ok", false)) \
		and _same(malformed_closed.get("state", {}), closed),
		"malformed state could not reach the canonical loop-breaking close")
	var invalid_reason := ROUTE.close_route(partial, "invented_reason")
	_expect(not bool(invalid_reason.get("ok", false)) \
		and _same(invalid_reason.get("state", {}), partial),
		"unallowlisted close reason mutated the route")

	GameState.start_new_game()
	GameState.turn = 196
	GameState.money = 9_876_543.0
	GameState.action_points = 2
	GameState.chapter5_causal_state = partial.duplicate(true)
	var before: Dictionary = GameState.serialize().duplicate(true)
	before.erase("chapter5_causal_state")
	var wrapper_close := GameState.close_chapter5_causal_route(
		ROUTE.CLOSE_REASON_READ_SURFACE_INVALID)
	var after: Dictionary = GameState.serialize().duplicate(true)
	after.erase("chapter5_causal_state")
	_expect(bool(wrapper_close.get("ok", false)) \
		and _same(before, after) \
		and _same(GameState.chapter5_causal_state, closed),
		"GameState read-surface close changed non-route state")
	var wrapper_reopen := GameState.record_chapter5_causal_choice(
		ROOT_IDS[1], 0)
	_expect(not bool(wrapper_reopen.get("ok", false)) \
		and _same(GameState.chapter5_causal_state, closed),
		"GameState reopened the route after a read-surface failure")

	# Exercise the exact live failure sequence used by StoryMode: malformed
	# localized prose is rejected, then the allowlisted close breaks future loops.
	var original_language: String = LocaleManager.language
	LocaleManager.set_language("ko")
	DataRegistry.reload()
	var story: Node = STORY_MODE.new()
	var live_event: Dictionary = (
		DataRegistry.find_event(ROOT_IDS[1]) as Dictionary).duplicate(true)
	(live_event["chapter5_causal_reads"] as Dictionary).erase("texts")
	GameState.chapter5_causal_state = partial.duplicate(true)
	var rejected_live: Variant = story.call(
		"_chapter5_causal_event_with_reads", live_event)
	_expect(rejected_live is Dictionary \
		and (rejected_live as Dictionary).is_empty(),
		"malformed live read surface was rendered")
	var loop_breaker := GameState.close_chapter5_causal_route(
		ROUTE.CLOSE_REASON_READ_SURFACE_INVALID)
	_expect(bool(loop_breaker.get("ok", false)) \
		and GameState.chapter5_causal_next_event_for_turn(196).is_empty() \
		and not GameState.chapter5_causal_ingress_available(ROOT_IDS[1]),
		"malformed live read did not terminate future ingress loops")
	var loop_breaker_again := GameState.close_chapter5_causal_route(
		ROUTE.CLOSE_REASON_READ_SURFACE_INVALID)
	_expect(bool(loop_breaker_again.get("ok", false)) \
		and bool(loop_breaker_again.get("idempotent", false)),
		"repeated malformed-read close was not idempotent")
	story.free()
	LocaleManager.set_language(original_language)
	DataRegistry.reload()


func _state_before_target(target_index: int, overrides: Dictionary) -> Dictionary:
	var state := ROUTE.default_state()
	for index in range(target_index):
		var event_id := ROOT_IDS[index]
		var at_turn := ROOT_TURNS[index]
		var next_event := ROUTE.next_event_for_turn(state, at_turn)
		if next_event.is_empty():
			# Only the two declared conditional roots may be absent.
			_expect(index in [15, 18],
				"fixture unexpectedly skipped %s" % event_id)
			continue
		_expect(next_event == event_id,
			"fixture expected %s before %s" % [event_id, next_event])
		if next_event != event_id:
			return state
		var selected_choice := int(overrides.get(event_id, 0))
		state = _commit_exact(state, index, selected_choice)
	return state


func _check_owned_variant_loop_breakers() -> void:
	var story: Node = STORY_MODE.new()
	var partial := _state_before_target(1, {ROOT_IDS[0]: 0})
	# _load_next_event routes both an empty live variant and a different unowned
	# variant through this exact helper before skipping the owned source ID.
	for scenario in ["empty", "different"]:
		GameState.chapter5_causal_state = partial.duplicate(true)
		story.call("_close_chapter5_causal_invalid_read_surface", ROOT_IDS[1])
		_expect(str(GameState.chapter5_causal_state.get("status", "")) == "closed" \
			and str(GameState.chapter5_causal_state.get("closed_reason", "")) \
				== "read_surface_invalid" \
			and GameState.chapter5_causal_next_event_for_turn(196).is_empty(),
			"owned %s live variant left its source reopening" % scenario)
	var gallery_before := partial.duplicate(true)
	GameState.chapter5_causal_state = gallery_before.duplicate(true)
	story.set("_read_only_replay", true)
	story.call("_close_chapter5_causal_invalid_read_surface", ROOT_IDS[1])
	_expect(_same(GameState.chapter5_causal_state, gallery_before),
		"gallery variant handling closed the live route")
	story.free()


func _expected_read_description(event: Dictionary, state: Dictionary) -> String:
	var reads: Dictionary = event.get("chapter5_causal_reads", {})
	var source_ids: Array = reads.get("source_event_ids", [])
	var optional_ids: Array = reads.get("optional_source_event_ids", [])
	var text_rows: Array = reads.get("texts", [])
	var prefixes: Array[String] = []
	for source_index in range(source_ids.size()):
		var source_id := str(source_ids[source_index])
		var selected_choice := ROUTE.selected_choice(state, source_id)
		if selected_choice < 0:
			if optional_ids.has(source_id):
				continue
			return ""
		var text_row: Array = text_rows[source_index]
		if selected_choice >= text_row.size():
			return ""
		prefixes.append(str(text_row[selected_choice]).strip_edges())
	var body := str(event.get("description", "")).strip_edges()
	return "\n\n".join(prefixes) \
		+ ("\n\n" + body if not body.is_empty() else "")


func _commit_exact(state: Dictionary, index: int, choice_index: int) -> Dictionary:
	if not ROUTE.entry_locked(state):
		var locked := ROUTE.lock_entry(
			state, 195, "투자형", true, true, 2_000_000_000.0)
		_expect(bool(locked.get("ok", false)),
			"fixture could not establish the durable W195 entry lock: %s" \
				% str(locked.get("error", "")))
		if not bool(locked.get("ok", false)):
			return state
		state = (locked.get("state", state) as Dictionary).duplicate(true)
	var event_id := ROOT_IDS[index]
	var at_turn := ROOT_TURNS[index]
	var result := ROUTE.commit_choice(
		state, event_id, choice_index, at_turn)
	_expect(bool(result.get("ok", false)),
		"fixture could not commit %s choice %d: %s" % [
			event_id, choice_index, str(result.get("error", ""))])
	if not bool(result.get("ok", false)):
		return state
	return (result.get("state", state) as Dictionary).duplicate(true)


func _prepare_chapter5_product_path() -> void:
	GameState.start_new_game("김민준", "지방_상경", "투자형")
	GameState.turn = 195
	GameState.money = 2_100_000_000.0
	GameState.portfolio = {}
	GameState.loans = {"bank": 0.0, "second": 0.0}
	GameState.flags["route_invest"] = true
	for flag in REQUIRED_ENTRY_FLAGS:
		GameState.flags[flag] = true
	for flag in EXCLUDED_ENTRY_FLAGS:
		GameState.flags.erase(flag)


func _same(left: Variant, right: Variant) -> bool:
	return JSON.stringify(left, "", true) == JSON.stringify(right, "", true)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
