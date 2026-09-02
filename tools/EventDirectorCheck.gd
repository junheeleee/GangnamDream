extends Node
## Runtime contract for hidden event curation, repeat policy, and save persistence.

var _failures: Array[String] = []

const CAUSAL_PRODUCER_ROOT_IDS := [
	"amb_idea_stolen_00",
	"anxiety_child_cost_calc",
	"anxiety_pension_crisis",
	"butterfly_mystery_info_result_scam",
	"butterfly_resume_lie_caught",
	"callback_jaehyuk_reported_witness",
	"callback_lied_interview_surfaces",
]

const DELAYED_PAYOFF_WIRING := [
	{"event": "amb_hoesik_00", "choice": 1, "target": "callback_hoesik_left_early_office", "delay": 12},
	{"event": "amb_hoesik_dodge", "choice": 1, "target": "callback_hoesik_caved_reputation", "delay": 8},
	{"event": "arc_daeun_02_regular", "choice": 0, "target": "callback_daeun_supportive_warmth", "delay": 12},
	{"event": "arc_invest_guidance", "choice": 0, "target": "callback_investment_lesson_echo", "delay": 16},
	{"event": "arc_temptation_fallout", "choice": 0, "target": "callback_escaped_dirty_trace", "delay": 16},
	{"event": "cafe_cb_stole_allin", "choice": 0, "target": "callback_cafe_stole_gambled_result", "delay": 10},
	{"event": "arc_daeun_money_gap", "choice": 2, "target": "callback_told_daeun_everything_echo", "delay": 12},
	{"event": "arc_daeun_money_gap", "choice": 1, "target": "callback_told_daeun_investing_echo", "delay": 12},
	{"event": "arc_father_03_hospital", "choice": 2, "target": "callback_sent_money_instead_echo", "delay": 10},
	{"event": "arc_father_03_hospital", "choice": 0, "target": "callback_rushed_to_father_echo", "delay": 14},
	{"event": "arc_father_medication", "choice": 2, "target": "callback_medication_visited_echo", "delay": 12},
	{"event": "arc_father_medication", "choice": 1, "target": "callback_medication_ignored_echo", "delay": 12},
	{"event": "arc_jiyeon_03_offer", "choice": 2, "target": "callback_jiyeon_honest_referral", "delay": 16},
	{"event": "arc_jiyeon_truth_moment", "choice": 0, "target": "callback_jiyeon_together_pressure", "delay": 16},
	{"event": "arc_jiyeon_truth_warned", "choice": 0, "target": "callback_jiyeon_together_pressure", "delay": 16},
	{"event": "arc_opp_jiyeon_bunyang", "choice": 0, "target": "callback_jiyeon_took_deal_consequence", "delay": 12},
	{"event": "arc_opp_sangchul_realty", "choice": 2, "target": "callback_declined_sangchul_deal_echo", "delay": 16},
	{"event": "arc_sangchul_03_network", "choice": 1, "target": "callback_shadow_investors_proposal", "delay": 12},
	{"event": "hyunsu_pass_news", "choice": 0, "target": "callback_hyunsu_departure_meal_echo", "delay": 16},
	{"event": "arc_daeun_04b_future", "choice": 1, "target": "callback_daeun_deferred_silence", "delay": 12},
	{"event": "arc_daeun_05_breaking", "choice": 1, "target": "callback_daeun_breakup_begged_echo", "delay": 12},
	{"event": "arc_daeun_05_together", "choice": 0, "target": "callback_daeun_daily_life_echo", "delay": 12},
	{"event": "arc_daeun_year3_apart", "choice": 0, "target": "callback_daeun_married_echo", "delay": 12},
	{"event": "arc_daeun_year3_apart", "choice": 1, "target": "callback_daeun_married_echo", "delay": 12},
	{"event": "arc_father_06_confession", "choice": 0, "target": "callback_father_confession_echo", "delay": 12},
	{"event": "arc_father_06_confession", "choice": 1, "target": "callback_father_confession_echo", "delay": 12},
	{"event": "arc_father_06_confession", "choice": 2, "target": "callback_father_confession_echo", "delay": 12},
	{"event": "arc_sangchul_buried_silence", "choice": 0, "target": "callback_sangchul_truth_buried_echo", "delay": 12},
	{"event": "arc_y3_jiyeon_departure", "choice": 0, "target": "callback_jiyeon_busan_postcard", "delay": 16},
	{"event": "arc_y3_jiyeon_departure", "choice": 1, "target": "callback_jiyeon_busan_postcard", "delay": 16},
	{"event": "arc_daeun_year4_together", "choice": 0, "target": "callback_daeun_gangnam_first_echo", "delay": 8},
	{"event": "arc_father_passing_deal_morning", "choice": 0, "target": "callback_chose_money_father_echo", "delay": 12},
	{"event": "arc_y3_cost_of_knowing", "choice": 0, "target": "callback_used_sangchul_after_echo", "delay": 10},
	{"event": "arc_daeun_y5_feelings", "choice": 0, "target": "callback_daeun_committed_gangnam_eve", "delay": 8},
]

const MULTI_DEFERRED_PAYOFF_WIRING := [
	{
		"event": "arc_jaehyuk_04b_counter", "choice": 1,
		"existing": "arc_jaehyuk_aftermath", "existing_delay": 1,
		"target": "callback_jaehyuk_exploited_retaliate", "delay": 12,
	},
	{
		"event": "arc_jaehyuk_04b_counter", "choice": 2,
		"existing": "arc_jaehyuk_aftermath", "existing_delay": 1,
		"target": "callback_jaehyuk_partnered_reckoning", "delay": 14,
	},
	{
		"event": "arc_sangchul_reckoning", "choice": 2,
		"existing": "arc_sangchul_year3", "existing_delay": 1,
		"target": "callback_sangchul_leveraged_cost", "delay": 12,
	},
]

const CHAIN_DEFERRED_PAYOFF_WIRING := [
	{"event": "rare_market_kind_stranger", "choice": 0, "target": "chain_banchan_reunion", "delay": 8},
	{"event": "rare_market_kind_stranger", "choice": 1, "target": "chain_banchan_reunion_declined", "delay": 8},
	{"event": "chain_banchan_reunion", "choice": 0, "target": "chain_banchan_son", "delay": 10},
	{"event": "chain_banchan_reunion_declined", "choice": 0, "target": "chain_banchan_son", "delay": 10},
	{"event": "rare_wallet_executive", "choice": 0, "target": "chain_exec_meal", "delay": 8},
	{"event": "chain_exec_meal_arrival", "choice": 0, "target": "chain_exec_interview", "delay": 10},
	{"event": "rare_night_alva_find", "choice": 0, "target": "chain_envelope_owner_return", "delay": 8},
	{"event": "rare_night_alva_find", "choice": 1, "target": "chain_envelope_guilt", "delay": 8},
	{"event": "chain_envelope_owner_return", "choice": 0, "target": "chain_interior_offer", "delay": 10},
	{"event": "rare_goshiwon_neighbor_success", "choice": 0, "target": "chain_neighbor_moving", "delay": 8},
	{"event": "chain_neighbor_moving", "choice": 0, "target": "chain_neighbor_civil_servant", "delay": 12},
	{"event": "rare_celeb_convenience", "choice": 0, "target": "chain_celeb_return", "delay": 8},
	{"event": "rare_celeb_convenience", "choice": 1, "target": "chain_celeb_return", "delay": 8},
	{"event": "butterfly_mystery_info_result_scam", "choice": 0, "target": "chain_scammer_again", "delay": 12},
]

const CHAIN_TERMINAL_FLAGS := [
	{"event": "chain_banchan_reunion", "choice": 1, "flag": "chain_banchan_passed_by"},
	{"event": "chain_banchan_reunion_declined", "choice": 1, "flag": "chain_banchan_refused_again"},
	{"event": "chain_banchan_son", "choice": 1, "flag": "chain_banchan_card_kept"},
	{"event": "chain_exec_meal_arrival", "choice": 1, "flag": "chain_exec_kept_distance"},
	{"event": "chain_exec_interview", "choice": 1, "flag": "chain_exec_interview_failed"},
	{"event": "chain_envelope_owner_return", "choice": 1, "flag": "chain_interior_gig_declined"},
	{"event": "chain_interior_offer", "choice": 1, "flag": "chain_interior_offer_declined"},
	{"event": "chain_neighbor_moving", "choice": 1, "flag": "chain_neighbor_kept_distance"},
	{"event": "chain_neighbor_civil_servant", "choice": 1, "flag": "chain_housing_deadline_missed"},
	{"event": "chain_celeb_return", "choice": 1, "flag": "chain_celeb_photo_kept"},
	{"event": "chain_scammer_again", "choice": 1, "flag": "chain_scam_victim_ignored"},
]

func _ready() -> void:
	GameState.start_new_game()
	_check_catalog_and_ranges()
	_check_content_diet()
	_check_context_gates()
	_check_once_and_repeat_policy()
	_check_authored_bypass()
	_check_delayed_payoff_wiring()
	_check_seed_harvest_chains()
	_check_demo_pacing()
	_check_full_run_pacing()
	_check_rhythm_save_migration()
	_check_father_life_contracts()
	if _failures.is_empty():
		print("EVENT_DIRECTOR_CHECK_OK directed=999 foreground=63 bridge=19 bridge_roots=6 causal_roots=7 auto_multi=0 once=996 repeatable=3 callbacks=37/32 chains=14/12 chapters=5 asset_bands=5 demo=9/2/4/3 authored=7 generic=2 full=77/6/19/21 save=legacy+demo+deferred")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("EVENT_DIRECTOR_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)

func _check_father_life_contracts() -> void:
	var required_tagged_living_only_ids := [
		"gambling_rock_bottom",
		"parents_bankbook",
		"v2_father_health_signal",
		"v2_demo_first_bill",
		"story_last_payment_exit",
		"story_prologue_dad",
		"amb_parent_hospital",
		"anxiety_parents_aging",
		"drama_addiction_warning",
		"father_wedding_call",
		"rel_family_proud_call",
		"arc_y3_father_deferred_call",
		"arc_y3_birthday_father_call",
		"arc_y3_relationship_departure_unattached",
		"arc_y3_truth_heard_by_father",
		"arc_y5_father_trace_alive_called",
		"arc_y3_father_after_visit_document",
		"arc_y3_father_avoidance_document",
		"arc_father_passing",
		"arc_father_passing_platform",
		"arc_father_passing_deal_room",
		"arc_father_passing_hospital_room",
		"arc_father_passing_deal_morning",
		"arc_intro_02_dad_call",
		"arc_father_ng_call",
		"arc_father_01_call",
		"arc_father_quiet_call",
		"arc_father_02_signal",
		"arc_father_medication",
		"arc_father_03_hospital",
		"arc_father_04_visit",
		"arc_father_05_after_visit",
		"arc_father_06_confession",
		"arc_34_parents_visit",
		"arc_35_birthday",
		"arc_36_father_comes_to_seoul",
		"arc_minjun_first_call",
		"arc_daeun_families_meet",
		"arc_pre_ending_father_call",
		"amb_holiday_home",
		"father_hospital_results",
		"arc_36_unexpected_hand",
		"arc_36_unexpected_hand_father_deal",
		"arc_y4_three_promises",
		"arc_y4_three_promises_jiyeon_and_deal",
		"arc_y4_three_promises_deal_only",
		"arc_y4_family_partner_collision",
		"arc_y4_family_partner_collision_jiyeon",
		"arc_y4_family_commitment_none",
		"arc_y4_family_table_missed",
		"arc_father_call_on_ktx",
		"arc_father_call_on_ktx_number",
		"arc_y4_father_call_answered_on_ktx",
		"arc_y4_bill_night",
		"arc_y4_bill_night_jiyeon",
		"arc_y4_bill_night_unattached",
		"arc_y4_father_crisis_contact",
		"arc_y4_father_final_contact_present",
		"arc_y4_father_final_contact_called",
		"arc_y4_father_final_contact_missed",
		"arc_y4_father_crisis_stabilized",
		"arc_y4_father_outcome_unknown",
	]
	var tagged_living_only_ids: Array[String] = []
	var condition_living_only_ids: Array[String] = []
	for event_value in DataRegistry.events:
		var catalog_event: Dictionary = event_value
		var catalog_event_id := str(catalog_event.get("id", ""))
		if catalog_event.get("tags", []).has("requires_living_father"):
			tagged_living_only_ids.append(catalog_event_id)
		var raw_no_flag: Variant = catalog_event.get("conditions", {}).get(
				"no_flag", "")
		var rejects_father_passed := false
		if raw_no_flag is String:
			rejects_father_passed = raw_no_flag == "father_passed"
		elif raw_no_flag is Array:
			rejects_father_passed = (raw_no_flag as Array).has(
					"father_passed")
		if rejects_father_passed:
			condition_living_only_ids.append(catalog_event_id)
	for event_id in required_tagged_living_only_ids:
		_expect(tagged_living_only_ids.has(event_id),
			"required living-Father event lost its hard-state tag: %s" \
					% event_id)
	var living_only_ids: Array[String] = tagged_living_only_ids.duplicate()
	for event_id in condition_living_only_ids:
		if not living_only_ids.has(event_id):
			living_only_ids.append(event_id)
	var father_passed_variants := {
		"arc_first_real_win": "arc_first_real_win_father_passed",
		"arc_money_loneliness": "arc_money_loneliness_father_passed",
		"arc_gangnam_real_estate": "arc_gangnam_real_estate_father_passed",
		"arc_year1_close": "arc_year1_close_father_passed",
		"arc_sangchul_year3": "arc_sangchul_year3_father_passed",
		"amb_mlm_aftermath": "amb_mlm_aftermath_father_passed",
		"callback_borrowed_parents_repay_moment": \
			"callback_borrowed_parents_repay_moment_father_passed",
		"callback_proactive_parent_care_echo": \
			"callback_proactive_parent_care_echo_father_passed",
		"callback_rushed_to_father_moment": \
			"callback_rushed_to_father_moment_father_passed",
		"first_paycheck_00": "first_paycheck_00_father_passed",
		"rel_family_visit_seoul": "rel_family_visit_seoul_father_passed",
		"story_first_paycheck_feel": \
			"story_first_paycheck_feel_father_passed",
		"story_hometown_nostalgia": \
			"story_hometown_nostalgia_father_passed",
		"arc_1b_isolation": "arc_1b_isolation_father_passed",
		"arc_why_gangnam_real": "arc_why_gangnam_real_father_passed",
		"arc_daeun_wedding_groom_side": \
			"arc_daeun_wedding_groom_side_father_passed",
		"arc_jiyeon_wedding_gap": \
			"arc_jiyeon_wedding_gap_father_passed",
		"arc_jiyeon_wedding_guest_list": \
			"arc_jiyeon_wedding_guest_list_father_passed",
		"arc_daeun_our_home": "arc_daeun_our_home_father_passed",
		"hyunsu_year5_call": "hyunsu_year5_call_father_passed",
		"arc_36_night_doubt": "arc_36_night_doubt_father_passed",
		"arc_year4_close": "arc_year4_close_father_passed",
		"arc_daeun_hometown_2": \
			"arc_daeun_hometown_2_father_passed",
	}
	var father_live_only_receipt_flags := [
		"called_dad_milestone",
		"called_at_1b_milestone",
		"father_heard_gangnam_reason",
		"father_mentally_updated",
		"sangchul_news_told_father",
		"told_father_win",
	]
	var audio_file := FileAccess.open(
		"res://assets/scene_audio_manifest.json", FileAccess.READ)
	_expect(audio_file != null,
		"Father-variant audio manifest could not be opened")
	var audio_manifest: Dictionary = {}
	if audio_file != null:
		var parsed_audio: Variant = JSON.parse_string(audio_file.get_as_text())
		audio_file.close()
		if parsed_audio is Dictionary:
			audio_manifest = parsed_audio as Dictionary
	var audio_events: Dictionary = (
		audio_manifest.get("events", {}) as Dictionary
		if audio_manifest.get("events", {}) is Dictionary else {})
	for original_id in father_passed_variants:
		living_only_ids.erase(original_id)
	GameState.start_new_game()
	for event_id in living_only_ids:
		var event: Dictionary = DataRegistry.find_event(event_id)
		_expect(not event.is_empty(),
			"living-Father contract event is missing: %s" % event_id)
		_expect(EventManager._event_passes_hard_state_contracts(event),
			"living Father was rejected from %s" % event_id)
	for event_id in tagged_living_only_ids:
		var event: Dictionary = DataRegistry.find_event(event_id)
		_expect(event.get("tags", []).has("requires_living_father"),
			"living-Father event lost its hard-state tag: %s" % event_id)
	for original_id in father_passed_variants:
		var passed_id := str(father_passed_variants[original_id])
		_expect(EventManager.live_event_variant_id(original_id) == original_id,
			"living Father was sent to passed variant %s" % passed_id)
		var passed_event: Dictionary = DataRegistry.find_event(passed_id)
		_expect(not passed_event.is_empty(),
			"Father-passed variant is missing: %s" % passed_id)
		var original_event: Dictionary = DataRegistry.find_event(original_id)
		if audio_events.has(original_id):
			_expect(audio_events.has(passed_id) \
					and audio_events.get(passed_id) \
						== audio_events.get(original_id),
				"Father-passed variant lost authored audio contract: %s" \
					% passed_id)
		if original_id == "arc_year1_close":
			_expect(original_event.get("description_if_known", {}) \
					== passed_event.get("description_if_known", {}),
				"Year-1 passed close lost route-specific narration")
			_expect(original_event.get(
					"description_memory_if_known", {}) \
					== passed_event.get("description_memory_if_known", {}),
				"Year-1 passed close lost additive receipt memories")
		var original_choices: Array = original_event.get("choices", [])
		var passed_choices: Array = passed_event.get("choices", [])
		_expect(original_choices.size() == passed_choices.size(),
			"Father-passed variant changed choice count: %s" % passed_id)
		for choice_index in range(mini(
				original_choices.size(), passed_choices.size())):
			var original_choice: Dictionary = original_choices[choice_index]
			var passed_choice: Dictionary = passed_choices[choice_index]
			_expect(original_choice.get("effects", {}) \
					== passed_choice.get("effects", {}),
				"Father-passed variant changed effects: %s[%d]" \
						% [passed_id, choice_index])
			var expected_passed_flags: Array = []
			for raw_flag in original_choice.get("flags", []):
				if str(raw_flag) not in father_live_only_receipt_flags:
					expected_passed_flags.append(raw_flag)
			_expect(expected_passed_flags \
					== passed_choice.get("flags", []),
				"Father-passed variant changed flags: %s[%d]" \
						% [passed_id, choice_index])
			_expect(str(original_choice.get("follow_up_event", "")) \
					== str(passed_choice.get("follow_up_event", "")),
				"Father-passed variant changed follow-up: %s[%d]" \
						% [passed_id, choice_index])
		_expect(EventManager.live_event_variant_id(passed_id).is_empty(),
			"living Father accepted passed-only variant %s" % passed_id)
		EventManager.pending_events.clear()
		EventManager.queue_event(passed_event)
		_expect(EventManager.pending_events.is_empty(),
			"living Father queued passed-only variant %s" % passed_id)
		EventManager.pending_events.append(passed_event)
		_expect(EventManager.get_next_event().is_empty(),
			"living Father restored passed-only variant %s" % passed_id)

	for evidence_case in ["canonical_flag", "legacy_receipt", "cast_stage"]:
		GameState.start_new_game()
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
		for event_id in living_only_ids:
			var event: Dictionary = DataRegistry.find_event(event_id)
			_expect(not EventManager._event_passes_hard_state_contracts(event),
				"%s reopened living-Father event %s" \
						% [evidence_case, event_id])
			EventManager.pending_events.clear()
			EventManager.queue_event(event)
			_expect(EventManager.pending_events.is_empty(),
				"%s queued living-Father event %s" \
						% [evidence_case, event_id])
			# A save may already contain a now-impossible pending event. The pop
			# path must re-check the same monotonic fact instead of trusting it.
			EventManager.pending_events.append(event)
			_expect(EventManager.get_next_event().is_empty(),
				"%s restored living-Father event %s" \
						% [evidence_case, event_id])
		EventManager.narrative_bridge_results.clear()
		_expect(not EventManager.resolve_narrative_bridge(
				"sangchul_becomes_primary", 0),
			"%s directly resolved a living-Father bridge" % evidence_case)
		_expect(EventManager.narrative_bridge_results.is_empty(),
			"%s recorded a blocked living-Father bridge" % evidence_case)
		for original_id in father_passed_variants:
			var passed_id := str(father_passed_variants[original_id])
			_expect(EventManager.live_event_variant_id(original_id) == passed_id,
				"%s did not remap %s to %s" \
						% [evidence_case, original_id, passed_id])
			var original_event: Dictionary = DataRegistry.find_event(original_id)
			EventManager.pending_events.clear()
			EventManager.queue_event(original_event)
			var queued_variant: Dictionary = EventManager.get_next_event()
			_expect(str(queued_variant.get("id", "")) == passed_id,
				"%s queued wrong variant for %s" \
						% [evidence_case, original_id])
			# Restored queues bypass queue_event, so the pop path must perform
			# the same variant migration.
			EventManager.pending_events.append(original_event)
			var restored_variant: Dictionary = EventManager.get_next_event()
			_expect(str(restored_variant.get("id", "")) == passed_id,
				"%s restored wrong variant for %s" \
						% [evidence_case, original_id])

	# A state-specific rendering of a random event still belongs to the source
	# event's once-per-run, recent, and cooldown identity.
	GameState.start_new_game()
	GameState.flags["father_passed"] = true
	EventManager.event_cooldowns.clear()
	EventManager.recent_event_ids.clear()
	var random_source: Dictionary = DataRegistry.find_event("first_paycheck_00")
	var random_variant: Dictionary = DataRegistry.find_event(
		"first_paycheck_00_father_passed")
	_expect(EventManager.is_directed_random_event(random_source),
		"random Father source lost director identity")
	_expect(not EventManager.is_directed_random_event(random_variant),
		"Father-passed variant became an independent random root")
	_expect(GameState.apply_choice(random_variant,
		random_variant.get("choices", [])[1]),
		"Father-passed random choice did not resolve")
	_expect(int(GameState.random_event_counts.get(
		"first_paycheck_00", 0)) == 1,
		"Father-passed random choice did not count its source")
	_expect(not GameState.random_event_counts.has(
		"first_paycheck_00_father_passed"),
		"Father-passed random choice created a second count identity")
	_expect(EventManager.event_cooldowns.has("first_paycheck_00"),
		"Father-passed random choice lost source cooldown")
	_expect(EventManager.recent_event_ids.has("first_paycheck_00"),
		"Father-passed random choice lost source recent identity")

	# Posthumous memory flags may still be recorded, but Father cannot regain a
	# living stage/affinity or satisfy a current close-relationship ending gate.
	GameState.start_new_game()
	GameState.apply_cast_effect("father", {
		"met": true,
		"affinity": 80,
		"stage": "close",
	})
	_expect(GameState.has_any_close_relationship(),
		"living close Father was excluded from relationship state")
	var affinity_before_death := GameState.get_cast_affinity("father")
	GameState.flags["father_passed"] = true
	GameState.apply_cast_effect("father", {
		"affinity": 20,
		"stage": "reconciled",
		"flags": ["posthumous_memory_test"],
	})
	_expect(GameState.get_cast_stage("father") == "passed",
		"posthumous cast effect restored a living Father stage")
	_expect(GameState.get_cast_affinity("father") == affinity_before_death,
		"posthumous cast effect changed Father affinity")
	_expect(GameState.cast_has_flag("father", "posthumous_memory_test"),
		"posthumous cast effect lost a historical memory flag")
	_expect(not GameState.has_any_close_relationship(),
		"passed Father satisfied a current close-relationship gate")
	GameState.start_new_game()
	EventManager.pending_events.clear()
	EventManager.current_event = {}

func _check_catalog_and_ranges() -> void:
	var directed_count := 0
	for event_value in DataRegistry.events:
		var event: Dictionary = event_value
		if EventManager.is_directed_random_event(event):
			directed_count += 1
	_expect(directed_count == 999, "runtime directed pool is %d, expected 999" % directed_count)
	var chapter_ids: Array[String] = []
	for turn_value in [1, 49, 97, 145, 193]:
		chapter_ids.append(EventManager.director_chapter_id(turn_value))
	_expect(chapter_ids == ["survival", "foothold", "leverage", "consequence", "reckoning"],
		"chapter windows do not cover the five-year run")
	var asset_ids: Array[String] = []
	for asset_value in [-1.0, 0.0, 5_000_000.0, 50_000_000.0, 300_000_000.0]:
		asset_ids.append(EventManager.director_asset_band_id(asset_value))
	_expect(asset_ids == ["negative", "survival", "foothold", "capital", "affluent"],
		"asset bands overlap or leave a gap")

func _check_content_diet() -> void:
	var foreground_count := 0
	var bridge_count := 0
	for event_value in DataRegistry.events:
		var event: Dictionary = event_value
		if EventManager.is_foreground_random_event(event):
			foreground_count += 1
		if EventManager.is_narrative_bridge_event(event):
			bridge_count += 1
			_expect((event.get("choices", []) as Array).size() == 1,
				"multi-choice event entered the automatic bridge pool: %s" \
				% str(event.get("id", "")))
	_expect(foreground_count == 63,
		"curated foreground pool is %d, expected 63" % foreground_count)
	_expect(bridge_count == 19,
		"safe one-choice bridge pool is %d, expected 19" % bridge_count)
	for root_id in CAUSAL_PRODUCER_ROOT_IDS:
		_expect(EventManager.is_foreground_random_event(
				DataRegistry.find_event(root_id)),
			"causal producer root left the foreground pool: %s" % root_id)

	var everyday: Dictionary = DataRegistry.find_event("convenience_store_meal")
	var substantial: Dictionary = DataRegistry.find_event("father_old_photo")
	var chained: Dictionary = DataRegistry.find_event("butterfly_mystery_info_offer")
	var comedy: Dictionary = DataRegistry.find_event("comedy_autocorrect")
	var implicit_chain_root: Dictionary = DataRegistry.find_event("amb_idea_stolen_00")
	var korea_explainer: Dictionary = DataRegistry.find_event("kx_tax_refund")
	var one_choice: Dictionary = DataRegistry.find_event("callback_formal_complaint_filed_echo")
	_expect(not EventManager.is_foreground_random_event(everyday),
		"short everyday card still owns a standalone StoryMode stop")
	_expect(EventManager.is_foreground_random_event(substantial),
		"substantial material-choice scene was removed from the foreground pool")
	_expect(EventManager.is_foreground_random_event(chained),
		"an existing causal chain lost its foreground entry point")
	_expect(not EventManager.is_foreground_random_event(comedy),
		"comedy filler still owns the novel foreground")
	_expect(EventManager.is_foreground_random_event(implicit_chain_root),
		"a material choice that creates a later bridge lost its chain entry point")
	_expect(not EventManager.is_foreground_random_event(korea_explainer),
		"a Korean explainer card entered the foreground through the bridge-root exception")
	_expect(EventManager.is_narrative_bridge_event(one_choice),
		"single-choice state callback did not enter the safe bridge pool")
	_expect(not EventManager.is_narrative_bridge_event(substantial),
		"multi-choice scene can be auto-resolved as a bridge")

	GameState.start_new_game()
	GameState.turn = 24
	GameState.flags["formal_complaint_filed"] = true
	_expect(EventManager.draw_narrative_bridge_event().is_empty(),
		"random bridge leaked into the curated 24-week demo")
	GameState.turn = 80
	var bridge_fixture: Dictionary = DataRegistry.find_event("callback_formal_complaint_filed_echo")
	_expect(EventManager._is_event_eligible(bridge_fixture, true),
		"eligible causal bridge fixture failed its deterministic state conditions")
	_expect(EventManager._event_has_causal_context(bridge_fixture),
		"eligible causal bridge fixture lost its state context")
	var bridge := EventManager.draw_narrative_bridge_event()
	_expect(str(bridge.get("id", "")) == "callback_formal_complaint_filed_echo",
		"eligible causal bridge was not selected after the demo: %s" \
		% str(bridge.get("id", "<empty>")))
	var seen_before := GameState.events_seen
	_expect(EventManager.resolve_narrative_bridge("callback_formal_complaint_filed_echo", 0),
		"safe bridge could not resolve through the original choice path")
	_expect(GameState.events_seen == seen_before + 1,
		"safe bridge did not retain the original event history")
	var bridge_results := EventManager.consume_narrative_bridge_results()
	_expect(bridge_results.size() == 1 \
			and str((bridge_results[0] as Dictionary).get("event_id", "")) \
			== "callback_formal_complaint_filed_echo",
		"safe bridge did not produce exactly one nonblocking result")

func _check_context_gates() -> void:
	GameState.turn = 12
	GameState.housing = "gosiwon"
	GameState.current_job = {}
	var delivery: Dictionary = DataRegistry.find_event("delivery_app_temptation")
	var rainy_night: Dictionary = DataRegistry.find_event("romance_034")
	_expect(EventManager.director_context_multiplier(delivery) == 0.0,
		"unemployed player can receive the after-work delivery scene")
	_expect(EventManager.director_context_multiplier(rainy_night) == 0.0,
		"unemployed player can receive the after-work Gangnam scene")
	var commute: Dictionary = DataRegistry.find_event("season_rainy_commute")
	_expect(not commute.is_empty(), "rainy commute fixture is missing")
	_expect(EventManager.director_context_multiplier(commute) == 0.0,
		"unemployed player can receive a commute scene")
	GameState.current_job = {"id": "job_01", "category": "part_time", "tier": 1}
	_expect(EventManager.director_context_multiplier(commute) > 0.0,
		"employed player cannot receive a commute scene")
	_expect(EventManager.director_context_multiplier(delivery) > 0.0,
		"employed player cannot receive the after-work delivery scene")
	_expect(EventManager.director_context_multiplier(rainy_night) > 0.0,
		"employed player cannot receive the after-work Gangnam scene")

	GameState.current_job = {}
	var gosiwon: Dictionary = DataRegistry.find_event("gosiwon_neighbor_first_meet")
	_expect(EventManager.director_context_multiplier(gosiwon) > 0.0,
		"goshiwon event is blocked in the goshiwon")
	GameState.housing = "apartment"
	_expect(EventManager.director_context_multiplier(gosiwon) == 0.0,
		"goshiwon event survives after moving to an apartment")
	GameState.housing = "gosiwon"
	var back_pain: Dictionary = DataRegistry.find_event("health_back_pain")
	var neighbor_success: Dictionary = DataRegistry.find_event("rare_goshiwon_neighbor_success")
	_expect(EventManager.director_context_multiplier(back_pain) > 0.0,
		"goshiwon mattress scene is blocked in the goshiwon")
	_expect(EventManager.director_context_multiplier(neighbor_success) > 0.0,
		"goshiwon neighbor scene is blocked in the goshiwon")
	GameState.housing = "apartment"
	_expect(EventManager.director_context_multiplier(back_pain) == 0.0,
		"goshiwon mattress scene survives after moving")
	_expect(EventManager.director_context_multiplier(neighbor_success) == 0.0,
		"goshiwon neighbor-success scene survives after moving")
	GameState.housing = "gosiwon"

	var six_month_romance: Dictionary = DataRegistry.find_event("romance_045")
	_expect(EventManager.director_context_multiplier(six_month_romance) == 0.0,
		"six-month partner scene can appear before any romance")
	GameState.flags["daeun_romance_started"] = true
	_expect(EventManager.director_context_multiplier(six_month_romance) > 0.0,
		"six-month partner scene stays blocked during an active romance")
	GameState.flags.erase("daeun_romance_started")

	var introduction: Dictionary = DataRegistry.find_event("sangchul_meet")
	var callback: Dictionary = DataRegistry.find_event("callback_told_sangchul_truth_echo")
	_expect(EventManager.director_context_multiplier(introduction) > 0.0,
		"Sangchul introduction was mistaken for a continuity contradiction")
	_expect(EventManager.director_context_multiplier(callback) == 0.0,
		"Sangchul callback can appear before Minjun meets him")
	GameState.apply_cast_effect("sangchul", {"met": true})
	_expect(EventManager.director_context_multiplier(callback) > 0.0,
		"Sangchul callback stays blocked after the meeting")

	GameState.current_job = {}
	var valid: Dictionary = DataRegistry.find_event("first_month_rent_pressure")
	var picked: Dictionary = EventManager._weighted_pick([commute, valid])
	_expect(str(picked.get("id", "")) == "first_month_rent_pressure",
		"zero-weight contradiction leaked through weighted selection")

func _check_once_and_repeat_policy() -> void:
	GameState.turn = 1
	GameState.money = 500_000.0
	GameState.housing = "gosiwon"
	GameState.current_job = {}
	GameState.random_event_counts = {}
	GameState.random_event_last_turns = {}
	EventManager.event_cooldowns.clear()
	EventManager.recent_event_ids.clear()

	var once_event: Dictionary = DataRegistry.find_event("first_month_rent_pressure")
	_expect(EventManager._is_event_eligible(once_event), "fresh once-per-run event is not eligible")
	EventManager.register_directed_event(once_event)
	EventManager.event_cooldowns.clear()
	EventManager.recent_event_ids.clear()
	GameState.turn = 120
	_expect(not EventManager._is_event_eligible(once_event),
		"default random event returned later in the same run")

	GameState.random_event_counts = {}
	GameState.random_event_last_turns = {}
	EventManager.event_cooldowns.clear()
	EventManager.recent_event_ids.clear()
	GameState.turn = 1
	var repeat_event: Dictionary = DataRegistry.find_event("convenience_store_meal")
	var first_weight := float(EventManager._effective_weight(repeat_event))
	EventManager.register_directed_event(repeat_event)
	_expect(int(GameState.random_event_counts.get("convenience_store_meal", 0)) == 1,
		"first repeatable event was not counted")
	var saved: Dictionary = GameState.serialize()
	GameState.random_event_counts = {}
	GameState.random_event_last_turns = {}
	GameState.load_from_dict(saved)
	_expect(int(GameState.random_event_counts.get("convenience_store_meal", 0)) == 1,
		"repeat history did not survive save/load")

	EventManager.event_cooldowns.clear()
	EventManager.recent_event_ids.clear()
	GameState.turn = 25
	_expect(EventManager._is_event_eligible(repeat_event),
		"repeatable event did not return after its 24-week cooldown")
	var second_weight := float(EventManager._effective_weight(repeat_event))
	_expect_close(second_weight / maxf(first_weight, 0.0001), 0.35,
		"second appearance did not decay to 35 percent")
	EventManager.register_directed_event(repeat_event)
	EventManager.event_cooldowns.clear()
	EventManager.recent_event_ids.clear()
	GameState.turn = 100
	_expect(not EventManager._is_event_eligible(repeat_event),
		"repeatable event exceeded its two-appearance cap")

func _check_authored_bypass() -> void:
	var story: Dictionary = DataRegistry.find_event("story_flashforward")
	var scheduled_arc: Dictionary = DataRegistry.find_event("arc_paycheck_reality")
	var direct_follow_up: Dictionary = DataRegistry.find_event("yolo_morning_after")
	var counts_before := GameState.random_event_counts.duplicate(true)
	_expect(not EventManager.is_directed_random_event(story), "authored story entered the random director")
	_expect(not EventManager.is_directed_random_event(scheduled_arc),
		"scheduled arc entered the random director")
	_expect(not EventManager.is_directed_random_event(direct_follow_up),
		"direct follow-up entered the random director")
	_expect_close(EventManager.director_context_multiplier(story), 1.0,
		"authored story received contextual weighting")
	EventManager.register_directed_event(story)
	_expect(GameState.random_event_counts == counts_before,
		"authored story changed random-event history")

func _check_delayed_payoff_wiring() -> void:
	var unique_targets: Dictionary = {}
	for row_value in DELAYED_PAYOFF_WIRING:
		var row: Dictionary = row_value
		var event_id := str(row["event"])
		var choice_index := int(row["choice"])
		var target_id := str(row["target"])
		var delay := int(row["delay"])
		var event: Dictionary = DataRegistry.find_event(event_id)
		var target: Dictionary = DataRegistry.find_event(target_id)
		_expect(not event.is_empty(), "delayed-payoff producer is missing: %s" % event_id)
		_expect(not target.is_empty(), "delayed-payoff target is missing: %s" % target_id)
		if event.is_empty():
			continue
		var choices: Array = event.get("choices", [])
		_expect(choice_index >= 0 and choice_index < choices.size(),
			"delayed-payoff choice index is invalid: %s#%d" % [event_id, choice_index])
		if choice_index < 0 or choice_index >= choices.size():
			continue
		var choice: Dictionary = choices[choice_index]
		_expect(choice.get("deferred_follow_up", "") is String,
			"legacy delayed-payoff row stopped using the compatible string shape: %s#%d" \
			% [event_id, choice_index])
		_expect(str(choice.get("deferred_follow_up", "")) == target_id,
			"delayed-payoff target drifted: %s#%d" % [event_id, choice_index])
		_expect(int(choice.get("deferred_delay", -1)) == delay,
			"delayed-payoff delay drifted: %s#%d" % [event_id, choice_index])
		unique_targets[target_id] = true

		GameState.start_new_game()
		GameState.turn = 40
		GameState.deferred_events.clear()
		GameState.apply_choice(event, choice)
		var scheduled := false
		for entry_value in GameState.deferred_events:
			var entry: Dictionary = entry_value
			if str(entry.get("event_id", "")) != target_id:
				continue
			scheduled = int(entry.get("trigger_turn", -1)) == 40 + delay
			break
		_expect(scheduled,
			"runtime did not schedule delayed payoff: %s#%d -> %s +%d" \
			% [event_id, choice_index, target_id, delay])
	_expect(DELAYED_PAYOFF_WIRING.size() == 34,
		"delayed-payoff wiring row count drifted")
	_expect(unique_targets.size() == 29,
		"delayed-payoff unique target count drifted: %d" % unique_targets.size())

	var multi_targets: Dictionary = {}
	for row_value in MULTI_DEFERRED_PAYOFF_WIRING:
		var row: Dictionary = row_value
		var event_id := str(row["event"])
		var choice_index := int(row["choice"])
		var existing_id := str(row["existing"])
		var existing_delay := int(row["existing_delay"])
		var target_id := str(row["target"])
		var target_delay := int(row["delay"])
		var event: Dictionary = DataRegistry.find_event(event_id)
		var choices: Array = event.get("choices", [])
		_expect(choice_index >= 0 and choice_index < choices.size(),
			"multi delayed-payoff choice index is invalid: %s#%d" % [event_id, choice_index])
		if choice_index < 0 or choice_index >= choices.size():
			continue
		var choice: Dictionary = choices[choice_index]
		var normalized: Array = DataRegistry.deferred_follow_ups(choice)
		_expect(_normalized_schedule_has(normalized, existing_id, existing_delay),
			"multi delayed-payoff lost existing schedule: %s#%d -> %s +%d" \
			% [event_id, choice_index, existing_id, existing_delay])
		_expect(_normalized_schedule_has(normalized, target_id, target_delay),
			"multi delayed-payoff lost added schedule: %s#%d -> %s +%d" \
			% [event_id, choice_index, target_id, target_delay])
		_expect(normalized.size() == 2,
			"multi delayed-payoff has an unexpected third schedule: %s#%d" \
			% [event_id, choice_index])
		multi_targets[target_id] = true

		GameState.start_new_game()
		GameState.turn = 40
		GameState.deferred_events.clear()
		GameState.apply_choice(event, choice)
		_expect(_runtime_schedule_has(existing_id, 40 + existing_delay),
			"runtime lost existing schedule beside added callback: %s#%d" \
			% [event_id, choice_index])
		_expect(_runtime_schedule_has(target_id, 40 + target_delay),
			"runtime did not schedule added delayed payoff: %s#%d" \
			% [event_id, choice_index])
		_expect(GameState.deferred_events.size() == 2,
			"one choice did not retain exactly two deferred schedules: %s#%d" \
			% [event_id, choice_index])
		GameState.turn = 40 + existing_delay
		var first_due: Array = GameState.pop_ready_deferred_events()
		_expect(first_due == [existing_id],
			"existing one-week follow-up did not fire first: %s#%d" \
			% [event_id, choice_index])
		_expect(GameState.has_deferred_event(target_id),
			"later callback was swallowed by the existing follow-up: %s#%d" \
			% [event_id, choice_index])
		GameState.turn = 40 + target_delay
		var second_due: Array = GameState.pop_ready_deferred_events()
		_expect(second_due == [target_id],
			"added callback did not fire at its own delay: %s#%d" \
			% [event_id, choice_index])
		_expect(GameState.deferred_events.is_empty(),
			"multi delayed-payoff left a duplicate schedule after both firings: %s#%d" \
			% [event_id, choice_index])
	_expect(MULTI_DEFERRED_PAYOFF_WIRING.size() == 3,
		"multi delayed-payoff wiring row count drifted")
	_expect(multi_targets.size() == 3,
		"multi delayed-payoff unique target count drifted: %d" % multi_targets.size())

	GameState.start_new_game()
	GameState.turn = 70
	var mixed_choice := {
		"deferred_follow_up": [
			"",
			"schema_shared_delay",
			{"id": "", "delay": 2},
			{"id": "schema_custom_delay", "delay": 3},
			{"id": "schema_shared_delay", "delay": 2},
		],
		"deferred_delay": 7,
	}
	_expect(DataRegistry.deferred_follow_up_shape_is_valid(mixed_choice),
		"valid mixed deferred schedule failed schema validation")
	_expect(not DataRegistry.deferred_follow_up_shape_is_valid({
			"deferred_follow_up": ["schema_bad_default"],
			"deferred_delay": 7.0,
		}), "floating-point default delay bypassed integer schema")
	_expect(not DataRegistry.deferred_follow_up_shape_is_valid({
			"deferred_follow_up": [{"id": "schema_bad_entry", "delay": 3.5}],
		}), "floating-point entry delay bypassed integer schema")
	_expect(not DataRegistry.deferred_follow_up_shape_is_valid({
			"deferred_follow_up": {"id": "schema_not_an_array"},
		}), "dictionary root bypassed string-or-array schema")
	GameState.apply_choice({"id": "deferred_schema_fixture"}, mixed_choice)
	_expect(_runtime_schedule_has("schema_shared_delay", 72),
		"duplicate deferred id did not preserve the earlier trigger turn")
	_expect(_runtime_schedule_has("schema_custom_delay", 73),
		"per-entry deferred delay was not honored")
	_expect(GameState.deferred_events.size() == 2,
		"empty ids or duplicate deferred ids leaked into storage")

	var saved: Dictionary = GameState.serialize()
	var saved_deferred: Array = GameState.deferred_events.duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	_expect(GameState.deferred_events == saved_deferred,
		"legacy deferred_events save format changed during array extension")
	GameState.start_new_game()

func _check_seed_harvest_chains() -> void:
	var unique_targets: Dictionary = {}
	for row_value in CHAIN_DEFERRED_PAYOFF_WIRING:
		var row: Dictionary = row_value
		var event_id := str(row["event"])
		var choice_index := int(row["choice"])
		var target_id := str(row["target"])
		var delay := int(row["delay"])
		var event: Dictionary = DataRegistry.find_event(event_id)
		var target: Dictionary = DataRegistry.find_event(target_id)
		_expect(not event.is_empty(), "seed-harvest producer is missing: %s" % event_id)
		_expect(not target.is_empty(), "seed-harvest target is missing: %s" % target_id)
		if event.is_empty():
			continue
		var choices: Array = event.get("choices", [])
		_expect(choice_index >= 0 and choice_index < choices.size(),
			"seed-harvest choice index is invalid: %s#%d" % [event_id, choice_index])
		if choice_index < 0 or choice_index >= choices.size():
			continue
		var choice: Dictionary = choices[choice_index]
		var normalized: Array = DataRegistry.deferred_follow_ups(choice)
		_expect(_normalized_schedule_has(normalized, target_id, delay),
			"seed-harvest schedule drifted: %s#%d -> %s +%d" \
			% [event_id, choice_index, target_id, delay])
		_expect(normalized.size() == 1,
			"seed-harvest choice gained an unintended second schedule: %s#%d" \
			% [event_id, choice_index])
		unique_targets[target_id] = true

		GameState.start_new_game()
		GameState.turn = 40
		GameState.deferred_events.clear()
		GameState.apply_choice(event, choice)
		_expect(_runtime_schedule_has(target_id, 40 + delay),
			"runtime did not schedule seed harvest: %s#%d -> %s +%d" \
			% [event_id, choice_index, target_id, delay])
	_expect(CHAIN_DEFERRED_PAYOFF_WIRING.size() == 14,
		"seed-harvest wiring row count drifted")
	_expect(unique_targets.size() == 12,
		"seed-harvest unique target count drifted: %d" % unique_targets.size())

	var final_winter: Dictionary = DataRegistry.find_event("final_last_winter")
	var final_memories: Dictionary = final_winter.get("description_memory_if_known", {})
	for row_value in CHAIN_TERMINAL_FLAGS:
		var row: Dictionary = row_value
		var event_id := str(row["event"])
		var choice_index := int(row["choice"])
		var flag_id := str(row["flag"])
		var event: Dictionary = DataRegistry.find_event(event_id)
		var choices: Array = event.get("choices", [])
		_expect(choice_index >= 0 and choice_index < choices.size(),
			"chain terminal choice index is invalid: %s#%d" % [event_id, choice_index])
		if choice_index < 0 or choice_index >= choices.size():
			continue
		var choice: Dictionary = choices[choice_index]
		_expect((choice.get("flags", []) as Array).has(flag_id),
			"chain terminal branch lost its memory flag: %s#%d -> %s" \
			% [event_id, choice_index, flag_id])
		_expect(not str(final_memories.get(flag_id, "")).strip_edges().is_empty(),
			"chain terminal branch has no last-winter memory: %s" % flag_id)
		GameState.start_new_game()
		GameState.apply_choice(event, choice)
		_expect(bool(GameState.flags.get(flag_id, false)),
			"chain terminal flag was not persisted at runtime: %s" % flag_id)

	var job_rows := [
		{"event": "chain_exec_interview", "from_job": "", "job": "job_08", "salary": 4_550_000.0},
		{"event": "chain_interior_offer", "from_job": "job_01", "job": "job_03", "salary": 2_240_000.0},
	]
	for row_value in job_rows:
		var row: Dictionary = row_value
		var event_id := str(row["event"])
		var event: Dictionary = DataRegistry.find_event(event_id)
		var choices: Array = event.get("choices", [])
		_expect(not choices.is_empty(), "chain job event has no choices: %s" % event_id)
		if choices.is_empty():
			continue
		GameState.start_new_game()
		GameState.turn = 100
		var from_job_id := str(row["from_job"])
		if not from_job_id.is_empty():
			GameState.current_job = DataRegistry.get_job(from_job_id).duplicate(true)
			var old_salary := float(GameState.current_job.get("base_salary", 0.0))
			GameState.current_job["effective_salary"] = old_salary
			GameState.monthly_income = old_salary
		GameState.apply_choice(event, choices[0] as Dictionary)
		_expect(str(GameState.current_job.get("id", "")) == str(row["job"]),
			"chain job result did not grant %s: %s" % [str(row["job"]), event_id])
		_expect_close(GameState.monthly_income, float(row["salary"]),
			"chain job result salary drifted: %s" % event_id)

	EventManager.pending_events.clear()
	EventManager.current_event = {}
	GameState.start_new_game()
	GameState.turn = 100
	GameState.flags["chain_interior_gig"] = true
	GameState.current_job = DataRegistry.get_job("job_08").duplicate(true)
	_expect(not EventManager.trigger_deferred_event_by_id("chain_interior_offer"),
		"employed player received the delayed interior job offer")
	_expect(EventManager.pending_events.is_empty(),
		"rejected interior offer still entered the event queue")
	GameState.current_job = DataRegistry.get_job("job_01").duplicate(true)
	_expect(EventManager.trigger_deferred_event_by_id("chain_interior_offer"),
		"convenience-store worker could not receive the delayed interior job offer")

	EventManager.pending_events.clear()
	GameState.start_new_game()
	GameState.turn = 100
	GameState.flags["met_celebrity"] = true
	GameState.current_job = DataRegistry.get_job("job_03").duplicate(true)
	_expect(not EventManager.trigger_deferred_event_by_id("chain_celeb_return"),
		"celebrity returned to a convenience store where Minjun no longer works")
	GameState.current_job = DataRegistry.get_job("job_01").duplicate(true)
	_expect(EventManager.trigger_deferred_event_by_id("chain_celeb_return"),
		"celebrity return was blocked during Minjun's convenience-store job")

	EventManager.pending_events.clear()
	GameState.start_new_game()
	GameState.turn = 100
	GameState.flags["congratulated_neighbor"] = true
	GameState.housing = "apartment"
	_expect(not EventManager.trigger_deferred_event_by_id("chain_neighbor_moving"),
		"goshiwon neighbor moved out after Minjun had already left the goshiwon")
	GameState.housing = "gosiwon"
	_expect(EventManager.trigger_deferred_event_by_id("chain_neighbor_moving"),
		"goshiwon neighbor move was blocked while Minjun still lived there")
	EventManager.pending_events.clear()
	GameState.housing = "apartment"
	_expect(not EventManager.trigger_deferred_event_by_id("rare_goshiwon_neighbor_success"),
		"goshiwon neighbor seed appeared after Minjun had already left the goshiwon")
	GameState.housing = "gosiwon"
	_expect(EventManager.trigger_deferred_event_by_id("rare_goshiwon_neighbor_success"),
		"goshiwon neighbor seed was blocked while Minjun still lived there")
	var housing_message: Dictionary = DataRegistry.find_event("chain_neighbor_civil_servant")
	_expect(str(housing_message.get("background", "")) == "current_housing",
		"the former neighbor's text does not follow Minjun's current housing")

	# MainGame consumes due reservations one at a time. An invalid first row must
	# not swallow a valid reservation due in the same week.
	EventManager.pending_events.clear()
	GameState.start_new_game()
	GameState.turn = 100
	GameState.flags["chain_interior_gig"] = true
	GameState.flags["congratulated_neighbor"] = true
	GameState.current_job = DataRegistry.get_job("job_08").duplicate(true)
	GameState.housing = "gosiwon"
	GameState.add_deferred_event("chain_interior_offer", 0)
	GameState.add_deferred_event("chain_neighbor_moving", 0)
	var first_due: Array = GameState.pop_ready_deferred_events()
	_expect(first_due == ["chain_interior_offer"],
		"same-week deferred fixture did not expose the invalid offer first")
	_expect(not EventManager.trigger_deferred_event_by_id(str(first_due[0])),
		"same-week invalid offer bypassed its job condition")
	var second_due: Array = GameState.pop_ready_deferred_events()
	_expect(second_due == ["chain_neighbor_moving"],
		"valid same-week deferred event was swallowed by the invalid offer")
	_expect(EventManager.trigger_deferred_event_by_id(str(second_due[0])),
		"valid same-week deferred event failed after skipping the invalid offer")
	_expect(GameState.deferred_events.is_empty(),
		"same-week deferred fixture left an unconsumed reservation")
	_expect(EventManager.pending_events.size() == 1 \
			and str((EventManager.pending_events[0] as Dictionary).get("id", "")) \
			== "chain_neighbor_moving",
		"same-week condition gate queued the wrong deferred event")
	EventManager.pending_events.clear()
	EventManager.current_event = {}
	GameState.start_new_game()

func _normalized_schedule_has(entries: Array, event_id: String, delay: int) -> bool:
	for value in entries:
		var entry: Dictionary = value
		if str(entry.get("event_id", "")) == event_id \
				and int(entry.get("delay", -1)) == delay:
			return true
	return false

func _runtime_schedule_has(event_id: String, trigger_turn: int) -> bool:
	for value in GameState.deferred_events:
		var entry: Dictionary = value
		if str(entry.get("event_id", "")) == event_id \
				and int(entry.get("trigger_turn", -1)) == trigger_turn:
			return true
	return false

func _check_demo_pacing() -> void:
	var kinds: Array[String] = []
	var decisions: Array[int] = []
	var bosses: Array[int] = []
	var echoes: Array[int] = []
	var summaries: Array[int] = []
	for turn_value in range(1, 25):
		var kind := EventManager.demo_week_kind(turn_value)
		kinds.append(kind)
		if kind in ["decision", "boss"]:
			decisions.append(turn_value)
		if kind == "boss":
			bosses.append(turn_value)
		elif kind == "echo":
			echoes.append(turn_value)
		if EventManager.demo_should_show_full_summary(turn_value):
			summaries.append(turn_value)
	_expect(decisions == [1, 4, 8, 10, 13, 16, 20, 23, 24],
		"demo decision schedule drifted: %s" % [decisions])
	_expect(bosses == [4, 24], "demo boss schedule drifted: %s" % [bosses])
	_expect(EventManager.narrative_boss_event_ids(4) == ["arc_temptation_01"],
		"week-four boss owner drifted")
	_expect(EventManager.narrative_event_owns_boss("arc_temptation_01", 4),
		"the burner-account scene does not own the week-four boss")
	_expect(not EventManager.narrative_event_owns_boss("arc_intro_02_dad_call", 4),
		"an unrelated scene can consume the week-four boss")
	_expect(EventManager.narrative_commitment_event_ids(8).is_empty(),
		"week eight must retain its separate generic decision")
	_expect(EventManager.narrative_commitment_event_ids(10).has("arc_ch1_career_first_spec"),
		"week ten route scene cannot own its weekly decision")
	_expect(EventManager.narrative_commitment_event_ids(13).has("cafe_cb_honest_00"),
		"week thirteen cafe callback cannot own its weekly decision")
	_expect(EventManager.narrative_commitment_event_ids(16) == ["arc_father_quiet_call"],
		"week sixteen father call owner drifted")
	_expect(EventManager.narrative_commitment_event_ids(20).has("arc_job_vs_invest"),
		"week twenty work-investment conflict cannot own its weekly decision")
	_expect(EventManager.narrative_commitment_event_ids(23) == ["story_first_savings_milestone"],
		"week twenty-three savings milestone cannot own its weekly decision")
	_expect(EventManager.narrative_boss_event_ids(24).has("hyunsu_exam_day"),
		"week twenty-four Hyunsu scene cannot own the closing boss week")
	var father_contract := EventManager.narrative_commitment_contract(
		"arc_father_quiet_call", 16)
	_expect(str(father_contract.get("axis", "")) == "human" \
			and str(father_contract.get("person_id", "")) == "father",
		"father commitment lost its human-axis relationship contract")
	_expect(not EventManager.narrative_event_owns_commitment("arc_father_quiet_call", 15),
		"authored ownership leaked into a quiet week")
	for owner_week in [4, 10, 13, 16, 20, 23, 24]:
		for owner_id in EventManager.narrative_commitment_event_ids(owner_week):
			var owner_event: Dictionary = DataRegistry.find_event(owner_id)
			_expect(not owner_event.is_empty(),
				"week %d owner does not exist: %s" % [owner_week, owner_id])
			_expect((owner_event.get("choices", []) as Array).size() >= 2,
				"week %d owner is not a real choice: %s" % [owner_week, owner_id])
			var owner_contract := EventManager.narrative_commitment_contract(
				owner_id, owner_week)
			_expect(str(owner_contract.get("axis", "")) in ["money", "human"],
				"week %d owner has no valid axis: %s" % [owner_week, owner_id])
	_expect(echoes == [6, 9, 17, 21], "demo echo schedule drifted: %s" % [echoes])
	_expect(summaries == [4, 12, 24], "demo summary schedule drifted: %s" % [summaries])
	_expect(EventManager.demo_week_kind(25) == "decision",
		"director leaked demo auto-flow beyond the cutoff")
	_expect(kinds.count("quiet") == 11, "demo must retain eleven quiet weeks")

func _check_full_run_pacing() -> void:
	var direct_by_chapter := [0, 0, 0, 0, 0]
	var bosses: Array[int] = []
	var echoes: Array[int] = []
	var summaries: Array[int] = []
	for turn_value in range(1, GameState.RUN_TURN_LIMIT + 1):
		var kind := EventManager.narrative_week_kind(turn_value)
		if kind in ["decision", "boss"]:
			direct_by_chapter[int((turn_value - 1) / 48)] += 1
		if kind == "boss":
			bosses.append(turn_value)
		elif kind == "echo":
			echoes.append(turn_value)
		if EventManager.narrative_should_show_full_summary(turn_value):
			summaries.append(turn_value)
	_expect(direct_by_chapter == [13, 9, 10, 15, 31],
		"full-run chapter decision cadence drifted: %s" % [direct_by_chapter])
	_expect(bosses == [4, 24, 45, 92, 140, 192, 237, 240],
		"full-run boss cadence drifted: %s" % [bosses])
	var chapter_four_owner_weeks := [
		153, 157, 161, 164, 167, 174, 177, 181, 185, 188, 190, 192]
	for owner_week in chapter_four_owner_weeks:
		var owner_ids := EventManager.narrative_commitment_event_ids(owner_week)
		_expect(not owner_ids.is_empty(),
			"chapter-four owner week %d has no authored action" % owner_week)
		for owner_id in owner_ids:
			var owner_event: Dictionary = DataRegistry.find_event(owner_id)
			var owner_choices: Array = owner_event.get("choices", [])
			_expect(not owner_event.is_empty() and owner_choices.size() >= 2,
				"chapter-four owner is not a real choice: %d/%s" % [
					owner_week, owner_id])
			for raw_choice in owner_choices:
				var owner_choice: Dictionary = raw_choice \
						if raw_choice is Dictionary else {}
				_expect(not GameState.is_expression_choice(owner_choice),
					"chapter-four owner choice became expression: %d/%s" % [
						owner_week, owner_id])
	_expect(EventManager.narrative_commitment_event_ids(169).is_empty(),
		"M43 consequence must not own a second weekly action")
	var chapter_five_finale_owner_weeks := [221, 224, 227, 230, 235, 238, 239, 240]
	for owner_week in chapter_five_finale_owner_weeks:
		var owner_ids := EventManager.narrative_commitment_event_ids(owner_week)
		_expect(not owner_ids.is_empty(),
			"chapter-five finale owner week %d has no authored action" % owner_week)
		for owner_id in owner_ids:
			var owner_event: Dictionary = DataRegistry.find_event(owner_id)
			var owner_choices: Array = owner_event.get("choices", [])
			if owner_id == "arc_y5_property_not_executed_notice":
				_expect(not owner_event.is_empty() and owner_choices.size() == 1,
					"chapter-five fixed follow-through drifted: %d/%s" % [
						owner_week, owner_id])
			else:
				_expect(not owner_event.is_empty() and owner_choices.size() >= 2,
					"chapter-five finale owner is not a real choice: %d/%s" % [
						owner_week, owner_id])
			var owner_contract := EventManager.narrative_commitment_contract(
				owner_id, owner_week)
			_expect(str(owner_contract.get("axis", "")) in ["money", "human"],
				"chapter-five finale owner has no valid axis: %d/%s" % [
					owner_week, owner_id])
	_expect(echoes == [
		6, 9, 17, 21, 33, 51, 63, 75, 86, 98, 109, 121, 136, 151,
		159, 171, 184, 199, 231,
	], "full-run echo schedule drifted: %s" % [echoes])
	_expect(summaries.size() == 21 and summaries.back() == 240,
		"full run must expose twenty-one gated summaries through week 240")
	_expect(EventManager.narrative_week_kind(241) == "decision",
		"narrative cadence leaked automatic time beyond the five-year run")

func _check_rhythm_save_migration() -> void:
	GameState.start_new_game()
	GameState.turn = 151
	GameState.money = 12_345_678.0
	GameState.flags["father_reconciled"] = true
	GameState.flags["demo_director_kind_turn"] = 151
	GameState.flags["demo_director_locked_kind"] = "quiet"
	var old_state: Dictionary = GameState.serialize()
	var migrated: Dictionary = SaveManager.migrate_narrative_rhythm_state(old_state, 0)
	var migrated_flags: Dictionary = migrated.get("flags", {})
	_expect(not migrated_flags.has("demo_director_kind_turn") \
			and not migrated_flags.has("demo_director_locked_kind"),
		"legacy save retained a stale week-kind lock")
	_expect(bool(migrated_flags.get("father_reconciled", false)) \
			and is_equal_approx(float(migrated.get("money", 0.0)), 12_345_678.0),
		"legacy rhythm migration changed authored or economy state")

	var demo_state: Dictionary = old_state.duplicate(true)
	demo_state["turn"] = GameState.DEMO_TURN_LIMIT + 1
	demo_state["money"] = 7_654_321.0
	var carried: Dictionary = SaveManager.migrate_narrative_rhythm_state(
			demo_state, SaveManager.NARRATIVE_RHYTHM_VERSION)
	_expect(int(carried.get("turn", 0)) == 25 \
			and is_equal_approx(float(carried.get("money", 0.0)), 7_654_321.0),
		"current demo state cannot carry into the full build")
	_expect(str(carried.get("flags", {}).get("demo_director_locked_kind", "")) == "quiet",
		"current-version save lost its in-progress week classification")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)

func _expect_close(actual: float, expected: float, message: String, tolerance: float = 0.002) -> void:
	if absf(actual - expected) > tolerance:
		_failures.append("%s (%.4f != %.4f)" % [message, actual, expected])
