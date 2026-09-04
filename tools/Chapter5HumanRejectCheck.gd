extends Node
## ORDER-150 runtime regression proof for the two Chapter 5 human-play rejects.
##
## This check deliberately exercises the live autoload APIs and a real
## MainGame instance.  It complements static content audits; it is not a
## substitute for the required normal-speed M49-M60 human replay.

const MAIN_GAME_SCRIPT := preload("res://scenes/MainGame.gd")

var _failures: Array[String] = []


func _ready() -> void:
	# Match StoryPlayback's process-local isolation without changing full-mode
	# semantics, retail/manual slots, HOME, or the on-disk project settings.
	var qa_namespace := "GangnamDream_Chapter5HumanRejectQA_%d_%d" % [
		OS.get_process_id(), int(Time.get_unix_time_from_system())]
	ProjectSettings.set_setting("application/config/use_custom_user_dir", true)
	ProjectSettings.set_setting("application/config/custom_user_dir_name", qa_namespace)
	if not OS.get_user_data_dir().ends_with(qa_namespace) \
			or DirAccess.make_dir_recursive_absolute(OS.get_user_data_dir()) != OK:
		push_error("CHAPTER5_HUMAN_REJECT_CHECK_FAIL: refused to run outside a new isolated QA namespace")
		get_tree().quit(1)
		return
	print("CHAPTER5_HUMAN_REJECT_QA_USER_DIR=%s" % OS.get_user_data_dir())
	# Let deferred autoload settings load before the check selects KO/EN.
	call_deferred("_run")


func _run() -> void:
	GameState.start_new_game()
	_check_presentation_home_runtime()
	_check_home_name_surface_runtime()
	_check_shared_home_living_runtime()
	_check_shadow_promise_and_legacy_runtime()
	_check_legacy_guarantee_window_runtime()
	_check_wallet_meal_consent_runtime()
	_check_main_game_runtime_contracts()
	_check_jiyeon_truth_contact_runtime()
	_check_loaded_story_contracts()
	_check_minseo_outbound_results_runtime()
	_check_scene_context_repair_runtime()

	# No audio needs to start for this proof.  Stop any inherited bed anyway so
	# strict headless teardown cannot be confused with a runtime-contract error.
	BGMPlayer.stop()
	await get_tree().process_frame
	await get_tree().process_frame

	if _failures.is_empty():
		print(
			"CHAPTER5_HUMAN_REJECT_CHECK_OK "
			+ "home=proposal-wedding-divorce/raw-gosiwon-save-roundtrip "
			+ "names=5x-raw-display-ko-en/legacy-gangnam-ending/shared-display-vs-narrative/consumer-split "
			+ "living=shared-menu-contract/no-move-hints/no-raw-month/no-keepsake/no-old-ingress "
			+ "visual=current-housing bgm=room-oneroom-room "
			+ "tutorial=turn1-only credits=1of6-plus-beat "
			+ "winter=september-w225-w227 "
			+ "minseo=remote-message/no-portrait/player-only/2x-outbound-ko-en "
			+ "shadow=proposal-only/legacy-joined-roundtrip/sns-closed "
			+ "guarantee=w192-open/w193+w237-closed/ko-en/old-save-roundtrip/w238-authored "
			+ "wallet=accept-flag/arrival-gated/decline-closes/interview+10 "
			+ "scene-context=m54-seven-months/5x-variants/3x-home/w224-store/casino-remote-direction "
			+ "jiyeon=truth-contact-3x-ko-en/no-repeat")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error("CHAPTER5_HUMAN_REJECT_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)


func _check_presentation_home_runtime() -> void:
	GameState.housing = "gosiwon"
	GameState.flags = {
		"daeun_married": true,
		"arc_daeun_proposal_seen": true,
	}
	var proposal_state := _serialized_bytes()
	_expect(not GameState.uses_daeun_shared_home_presentation(),
		"proposal-only state entered the completed-wedding presentation home")
	_expect(GameState.get_presentation_home_background_id().is_empty(),
		"proposal-only state emitted a shared-home background override")
	_expect(GameState.get_presentation_home_name() == GameState.get_housing_name(),
		"proposal-only state replaced the raw housing display name")
	_expect(
		ImageRegistry.resolve_contextual_background_id("current_housing") \
				== "goshiwon_room",
		"proposal-only current_housing did not resolve the raw goshiwon room")
	_expect(GameState.get_presentation_home_ambience_housing_id() == "gosiwon",
		"proposal-only ambience changed the raw housing id")
	_expect(BGMPlayer._active_housing_id() == "gosiwon",
		"proposal-only BGM context changed the raw housing id")
	_expect(
		BGMPlayer._resolve_dynamic_ambience_key("current_housing") == "room",
		"proposal-only current_housing did not resolve the room ambience")
	_expect(_serialized_bytes() == proposal_state,
		"proposal presentation lookup mutated serialized game state")

	# The wedding is a presentation fact only.  Economic housing remains the
	# raw gosiwon both in memory and on disk while visuals and ambience agree on
	# the authored newlywed home.
	GameState.flags = {"arc_daeun_wedding_day_seen": true}
	var wedding_economics := _economic_bytes()
	var wedding_state := _serialized_bytes()
	_expect(GameState.uses_daeun_shared_home_presentation(),
		"completed wedding did not activate the shared-home presentation")
	_expect(
		GameState.get_presentation_home_background_id() \
				== "daeun_newlywed_home",
		"completed wedding did not expose the newlywed-home background")
	_expect(
		ImageRegistry.resolve_contextual_background_id("current_housing") \
				== "daeun_newlywed_home",
		"ImageRegistry did not resolve current_housing to the newlywed home")
	_expect(GameState.get_presentation_home_name() != GameState.get_housing_name(),
		"completed wedding kept the raw goshiwon presentation name")
	_expect(GameState.get_presentation_home_ambience_housing_id() == "oneroom",
		"completed wedding did not expose the shared-home ambience id")
	_expect(BGMPlayer._active_housing_id() == "oneroom",
		"BGM did not consume the completed-wedding presentation home")
	_expect(
		BGMPlayer._resolve_dynamic_ambience_key("current_housing") == "oneroom",
		"completed-wedding current_housing did not resolve one-room ambience")
	_expect(GameState.housing == "gosiwon",
		"completed-wedding presentation rewrote economic housing")
	_expect(_economic_bytes() == wedding_economics,
		"completed-wedding presentation lookup mutated economic values")
	_expect(_serialized_bytes() == wedding_state,
		"completed-wedding presentation lookup mutated serialized state")

	var wedding_save: Dictionary = GameState.serialize().duplicate(true)
	var wedding_save_text := JSON.stringify(wedding_save)
	_expect(str(wedding_save.get("housing", "")) == "gosiwon",
		"wedding save did not retain raw gosiwon housing")
	_expect(wedding_save_text.find("daeun_newlywed_home") < 0,
		"derived newlywed-home id leaked into serialized economic state")
	_expect(not wedding_save.has("presentation_home") \
			and not wedding_save.has("presentation_housing"),
		"derived presentation home acquired a persisted save field")

	# A disk-style roundtrip must recompute presentation from the wedding flag,
	# not silently promote the raw housing value.
	GameState.housing = "apartment"
	GameState.flags = {}
	GameState.load_from_dict(wedding_save.duplicate(true))
	_expect(GameState.housing == "gosiwon",
		"save roundtrip promoted raw housing away from gosiwon")
	_expect(bool(GameState.flags.get("arc_daeun_wedding_day_seen", false)),
		"save roundtrip lost the completed-wedding presentation receipt")
	_expect(GameState.uses_daeun_shared_home_presentation(),
		"save roundtrip did not re-derive the shared-home presentation")
	_expect(
		ImageRegistry.resolve_contextual_background_id("current_housing") \
				== "daeun_newlywed_home",
		"save roundtrip did not re-derive the shared-home background")
	_expect(BGMPlayer._active_housing_id() == "oneroom" \
			and BGMPlayer._resolve_dynamic_ambience_key("current_housing") \
				== "oneroom",
		"save roundtrip did not re-derive the shared-home ambience")
	_expect(_economic_bytes() == wedding_economics,
		"wedding save roundtrip changed economic values")

	# Divorce removes only the presentation override.  It cannot manufacture an
	# apartment or keep the married ambience alive.
	GameState.flags = {
		"arc_daeun_wedding_day_seen": true,
		"daeun_divorced": true,
	}
	var divorce_state := _serialized_bytes()
	_expect(not GameState.uses_daeun_shared_home_presentation(),
		"divorce kept the completed-wedding presentation active")
	_expect(GameState.get_presentation_home_background_id().is_empty(),
		"divorce kept a shared-home background override")
	_expect(
		ImageRegistry.resolve_contextual_background_id("current_housing") \
				== "goshiwon_room",
		"divorce did not return current_housing to the raw goshiwon room")
	_expect(GameState.get_presentation_home_ambience_housing_id() == "gosiwon" \
			and BGMPlayer._active_housing_id() == "gosiwon" \
			and BGMPlayer._resolve_dynamic_ambience_key("current_housing") == "room",
		"divorce did not return BGM ambience to the raw room")
	_expect(GameState.housing == "gosiwon",
		"divorce changed the raw economic housing")
	_expect(_serialized_bytes() == divorce_state,
		"divorce presentation lookup mutated serialized state")


func _check_home_name_surface_runtime() -> void:
	var original_language := LocaleManager.language
	var raw_display_names := {
		"ko": {
			"gosiwon": "고시원",
			"oneroom": "원룸",
			"villa": "빌라 전세",
			"apartment": "아파트 전세",
			"gangnam": "강남 아파트",
		},
		"en": {
			"gosiwon": "Goshiwon Room",
			"oneroom": "One-room Studio",
			"villa": "Villa Jeonse",
			"apartment": "Apartment Jeonse",
			"gangnam": "Gangnam Apartment",
		},
	}
	var raw_narrative_names := {
		"ko": {
			"gosiwon": "고시원",
			"oneroom": "원룸",
			"villa": "빌라 전세",
			"apartment": "아파트 전세",
			"gangnam": "강남 아파트",
		},
		"en": {
			"gosiwon": "goshiwon",
			"oneroom": "one-room studio",
			"villa": "villa jeonse",
			"apartment": "apartment jeonse",
			"gangnam": "Gangnam apartment",
		},
	}
	GameState.start_new_game()
	GameState.flags = {}
	for language_value in raw_display_names:
		var language := str(language_value)
		LocaleManager.language = language
		var localized_names: Dictionary = raw_display_names.get(language, {})
		var localized_narratives: Dictionary = raw_narrative_names.get(
			language, {})
		for housing_value in localized_names:
			var housing_id := str(housing_value)
			GameState.housing = housing_id
			var expected_display := str(localized_names.get(housing_id, ""))
			var expected_narrative := str(localized_narratives.get(
				housing_id, ""))
			_expect(GameState.get_presentation_home_display_name() \
					== expected_display,
				"%s non-married %s display name drifted: %s" % [
					language, housing_id,
					GameState.get_presentation_home_display_name()])
			_expect(GameState.get_presentation_home_name() == expected_narrative,
				"%s non-married %s narrative name drifted: %s" % [
					language, housing_id,
					GameState.get_presentation_home_name()])

	# `gangnam` is a retired economic-ladder value but remains legal in old
	# saves and ending snapshots.  A cold-style load must not relabel it as the
	# fallback gosiwon when the ending asks for the last home.
	GameState.start_new_game()
	GameState.housing = "gangnam"
	GameState.flags = {}
	var legacy_gangnam_save: Dictionary = GameState.serialize().duplicate(true)
	GameState.housing = "gosiwon"
	GameState.load_from_dict(legacy_gangnam_save)
	_expect(GameState.housing == "gangnam",
		"legacy Gangnam housing value did not survive save roundtrip")
	var legacy_ending_game: Control = MAIN_GAME_SCRIPT.new()
	for language in ["ko", "en"]:
		LocaleManager.language = language
		var expected_names: Dictionary = raw_display_names.get(language, {})
		var expected_ending := str(expected_names.get("gangnam", ""))
		_expect(str(legacy_ending_game.call("_ending_last_home_label")) \
				== expected_ending,
			"%s legacy Gangnam ending display drifted: %s" % [
				language,
				legacy_ending_game.call("_ending_last_home_label")])
	legacy_ending_game.free()

	var shared_names := {
		"ko": {
			"display": "다은과 사는 신혼집",
			"narrative": "다은과 사는 작은 서울 신혼집",
		},
		"en": {
			"display": "Shared Home with Daeun",
			"narrative": "small Seoul newlywed home with Daeun",
		},
	}
	GameState.flags = {"arc_daeun_wedding_day_seen": true}
	for language_value in shared_names:
		var language := str(language_value)
		LocaleManager.language = language
		var expected: Dictionary = shared_names.get(language, {})
		var display_name := GameState.get_presentation_home_display_name()
		var narrative_name := GameState.get_presentation_home_name()
		_expect(display_name == str(expected.get("display", "")),
			"%s shared-home display name drifted: %s" % [
				language, display_name])
		_expect(narrative_name == str(expected.get("narrative", "")),
			"%s shared-home narrative name drifted: %s" % [
				language, narrative_name])
		_expect(display_name != narrative_name,
			"%s shared-home display and narrative names collapsed" % language)

	# Exercise representative consumers.  Compact ending facts take the display
	# label, while the contextual sentence and shareable run card keep the
	# sentence-ready narrative phrase.  HUD/living wiring is statically protected.
	LocaleManager.language = "en"
	GameState.start_new_game()
	GameState.flags = {"arc_daeun_wedding_day_seen": true}
	GameState.housing = "gosiwon"
	GameState.turn = 1
	var expected_display := "Shared Home with Daeun"
	var expected_narrative := "small Seoul newlywed home with Daeun"
	var main_game: Control = MAIN_GAME_SCRIPT.new()
	_expect(str(main_game.call("_ending_last_home_label")) == expected_display,
		"ending last-home label did not consume the display helper")
	var run_card := str(main_game.call("_run_card_text", "ordinary_life"))
	_expect(run_card.find("Last Home: %s" % expected_narrative) >= 0 \
			and run_card.find("Last Home: %s" % expected_display) < 0,
		"run card did not retain the narrative helper: %s" % run_card)
	var pressure: Dictionary = main_game.call(
		"_contextual_week_pressure", "", "")
	var pressure_title := str(pressure.get("title", ""))
	_expect(str(pressure.get("family", "")) == "housing" \
			and pressure_title.find(expected_narrative) >= 0 \
			and pressure_title.find(expected_display) < 0,
		"contextual housing prose did not retain the narrative helper: %s" \
			% JSON.stringify(pressure))
	var stat_parent := VBoxContainer.new()
	main_game.add_child(stat_parent)
	main_game.call("_ending_stat_grid", stat_parent)
	var stat_labels: Array[String] = []
	_collect_label_text(stat_parent, stat_labels)
	var stat_text := " | ".join(stat_labels)
	_expect(stat_text.find(expected_display) >= 0 \
			and stat_text.find(expected_narrative) < 0,
		"ending stat grid did not consume only the display helper: %s" % stat_text)
	main_game.free()
	LocaleManager.language = original_language


func _check_shared_home_living_runtime() -> void:
	var original_language := LocaleManager.language
	var main_game: Node = MAIN_GAME_SCRIPT.new()

	# A real pre-upgrade fixture proves each raw-housing hint is reachable, then
	# proves the completed wedding suppresses it in both shipped UI languages.
	GameState.start_new_game()
	GameState.current_job = {
		"id": "order150_runtime_job",
		"promotion_count": 0,
		"max_promotions": 3,
	}
	GameState.health = 100
	GameState.mental = 100
	GameState.intelligence = 80
	GameState.investment_skill = 30
	GameState.social_skill = 30
	GameState.money = 200_000_000.0
	GameState.flags = {
		"has_received_paycheck": true,
		"entered_network": true,
		"arc_invest_guidance_seen": true,
	}
	var recommendation_housing := ["gosiwon", "oneroom", "villa"]
	for language in ["ko", "en"]:
		LocaleManager.language = language
		for housing_id in recommendation_housing:
			GameState.housing = housing_id
			GameState.flags.erase("arc_daeun_wedding_day_seen")
			var raw_recommendation := str(main_game.call("_recommend_action"))
			var expected_move := "이사 고려" if language == "ko" \
					else "Consider Moving"
			_expect(raw_recommendation.find(expected_move) >= 0,
				"%s %s control did not reach its raw move recommendation: %s" % [
					language, housing_id, raw_recommendation])
			GameState.flags["arc_daeun_wedding_day_seen"] = true
			var shared_recommendation := str(main_game.call("_recommend_action"))
			_expect(_contains_none(shared_recommendation,
				["이사 고려", "Consider Moving"]),
				"%s %s shared home exposed a raw move recommendation: %s" % [
					language, housing_id, shared_recommendation])

	# The month advice has a separate path from the recommendation card.  Its
	# non-married control must be reachable before the shared-home exclusion is
	# credited with suppressing the move prompt.
	GameState.housing = "gosiwon"
	GameState.money = 20_000_000.0
	GameState.turn = 1
	for language in ["ko", "en"]:
		LocaleManager.language = language
		GameState.flags.erase("arc_daeun_wedding_day_seen")
		var raw_advice := str(main_game.call("_get_month_advice"))
		var expected_advice := "이사할 자금" if language == "ko" \
				else "You can afford to move"
		_expect(raw_advice.find(expected_advice) >= 0,
			"%s control did not reach raw housing advice: %s" % [
				language, raw_advice])
		GameState.flags["arc_daeun_wedding_day_seen"] = true
		var shared_advice := str(main_game.call("_get_month_advice"))
		_expect(_contains_none(shared_advice,
			["이사할 자금", "You can afford to move"]),
			"%s shared home exposed raw housing advice: %s" % [
				language, shared_advice])

	# Exercise raw-room month prose with a synthetic M16 state.  Each control
	# reaches the housing-specific line; adding the wedding receipt must route to
	# neutral seasonal prose instead of describing a room the couple does not use.
	GameState.age = 34
	GameState.month = 4
	GameState.turn = 64
	GameState.money = 1_000_000.0
	var raw_month_fragments := {
		"ko": {
			"gosiwon": "1평 반에서 1년이 넘었다",
			"apartment": "아파트 창에서 보이는 서울은 다르다",
			"gangnam": "강남에 왔다",
		},
		"en": {
			"gosiwon": "Over a year in 1.5 pyeong",
			"apartment": "Seoul looks different from an apartment window",
			"gangnam": "I made it to Gangnam",
		},
	}
	for language_value in raw_month_fragments:
		var language := str(language_value)
		LocaleManager.language = language
		var localized_fragments: Dictionary = raw_month_fragments.get(language, {})
		for housing_value in localized_fragments:
			var housing_id := str(housing_value)
			GameState.housing = housing_id
			GameState.flags = {}
			var raw_narration := str(main_game.call("_month_narration"))
			var raw_fragment := str(localized_fragments.get(housing_id, ""))
			_expect(raw_narration.find(raw_fragment) >= 0,
				"%s %s control did not reach raw month narration: %s" % [
					language, housing_id, raw_narration])
			GameState.flags = {"arc_daeun_wedding_day_seen": true}
			var shared_narration := str(main_game.call("_month_narration"))
			_expect(_contains_none(shared_narration,
				localized_fragments.values()),
				"%s %s shared home exposed raw month narration: %s" % [
					language, housing_id, shared_narration])

	# The living-menu action remains an economic contract update.  It must not
	# prepare the old move-keepsake scene, alter the shared presentation, or send
	# either legacy moving scene through the generic/closure routers.
	LocaleManager.language = "ko"
	GameState.start_new_game()
	GameState.housing = "gosiwon"
	GameState.money = 20_000_000.0
	GameState.inventory = [{
		"id": "artifact_order150_runtime_keepsake",
		"quantity": 1,
	}]
	GameState.flags = {"arc_daeun_wedding_day_seen": true}
	var presentation_name := GameState.get_presentation_home_name()
	var presentation_background := GameState.get_presentation_home_background_id()
	var presentation_ambience := GameState.get_presentation_home_ambience_housing_id()
	var before_keepsake := _serialized_bytes()
	_expect(str(main_game.call("_housing_keepsake_event_id")).is_empty(),
		"shared-home contract update routed to the move-keepsake scene")
	_expect(not GameState.flags.has("pending_housing_keepsake_id"),
		"shared-home contract update prepared a move keepsake")
	_expect(_serialized_bytes() == before_keepsake,
		"shared-home keepsake bypass mutated serialized state")
	var money_before_upgrade: float = float(GameState.money)
	var upgrade_result: Dictionary = GameState.upgrade_housing()
	_expect(bool(upgrade_result.get("success", false)),
		"shared-home economic contract update failed")
	_expect(GameState.housing == "oneroom",
		"shared-home contract update did not advance raw housing to oneroom")
	_expect(is_equal_approx(GameState.money, money_before_upgrade - 5_000_000.0),
		"shared-home contract update did not apply the raw deposit delta")
	_expect(GameState.uses_daeun_shared_home_presentation() \
			and GameState.get_presentation_home_name() == presentation_name \
			and GameState.get_presentation_home_background_id() \
				== presentation_background \
			and GameState.get_presentation_home_ambience_housing_id() \
				== presentation_ambience,
		"economic contract update replaced the completed-wedding presentation")
	_expect(not GameState.flags.has("pending_housing_keepsake_id"),
		"economic contract update manufactured a pending keepsake")

	# Prove both legacy moving routes are otherwise reachable from this upgraded
	# raw state, then restore the wedding fact and require each to stay closed.
	GameState.flags.erase("arc_daeun_wedding_day_seen")
	GameState.flags.erase("arc_goshiwon_goodbye_seen")
	GameState.flags.erase("arc_housing_new_life_seen")
	var raw_generic_ingress := str(main_game.call(
		"_next_arc_id", 999, true, false))
	_expect(raw_generic_ingress == "arc_goshiwon_goodbye",
		"raw-upgrade control did not reach arc_goshiwon_goodbye: %s" \
			% raw_generic_ingress)
	GameState.flags["arc_daeun_wedding_day_seen"] = true
	var shared_generic_ingress := str(main_game.call(
		"_next_arc_id", 999, true, false))
	_expect(shared_generic_ingress != "arc_goshiwon_goodbye",
		"shared-home contract update re-entered arc_goshiwon_goodbye")

	GameState.flags.erase("arc_daeun_wedding_day_seen")
	GameState.flags["arc_goshiwon_goodbye_seen"] = true
	GameState.flags.erase("arc_housing_new_life_seen")
	var raw_closure := str(main_game.call(
		"_story_graph_contract_event_id", 25, GameState.flags, false))
	_expect(raw_closure == "arc_housing_new_life",
		"raw-upgrade control did not reach arc_housing_new_life: %s" % raw_closure)
	GameState.flags["arc_daeun_wedding_day_seen"] = true
	var shared_closure := str(main_game.call(
		"_story_graph_contract_event_id", 25, GameState.flags, false))
	_expect(shared_closure != "arc_housing_new_life",
		"shared-home contract update re-entered arc_housing_new_life")

	LocaleManager.language = original_language
	main_game.free()


func _check_shadow_promise_and_legacy_runtime() -> void:
	# Generic flags serialization must retain a truthful legacy collaboration
	# receipt.  No one-off migration is involved: inject the old value into a
	# normal save payload, load it, and save it again.
	GameState.start_new_game()
	_expect(not bool(GameState.flags.get("startup_collab_joined", false)),
		"fresh run manufactured legacy startup_collab_joined")
	var legacy_save: Dictionary = GameState.serialize().duplicate(true)
	var legacy_flags: Dictionary = (
		legacy_save.get("flags", {}) as Dictionary).duplicate(true)
	legacy_flags["startup_collab_joined"] = true
	legacy_save["flags"] = legacy_flags
	GameState.load_from_dict(legacy_save.duplicate(true))
	_expect(bool(GameState.flags.get("startup_collab_joined", false)),
		"generic old-save load lost startup_collab_joined")
	_expect(not bool(GameState.flags.get("startup_collab_proposed", false)),
		"old joined receipt was silently converted into a new proposal")
	var legacy_resave: Dictionary = GameState.serialize().duplicate(true)
	var legacy_resave_flags: Dictionary = (
		legacy_resave.get("flags", {}) as Dictionary)
	_expect(bool(legacy_resave_flags.get("startup_collab_joined", false)),
		"generic old-save roundtrip erased startup_collab_joined")

	# Exercise the actual authored choices through GameState.apply_choice.  Both
	# current accept paths may record only the player's outbound proposal; neither
	# may invent the other person's read, reply, agreement, or collaboration.
	var proposal_choices: Array[Dictionary] = [
		{"event_id": "shadow_old_promise", "choice_index": 2},
		{"event_id": "shadow_promise_again", "choice_index": 0},
	]
	for spec in proposal_choices:
		GameState.start_new_game()
		var event_id := str(spec.get("event_id", ""))
		var event: Dictionary = DataRegistry.find_event(event_id)
		_expect(not event.is_empty(), "%s was not loaded" % event_id)
		if event.is_empty():
			continue
		_expect(_condition_has(event, "no_flag", "sns_detoxed"),
			"%s can re-enter after sns_detoxed" % event_id)
		_expect(_condition_has(event, "no_flag", "startup_collab_proposed"),
			"%s is not terminal after the player's proposal" % event_id)
		var choices: Array = event.get("choices", [])
		var authored_joined_count := 0
		var authored_proposed_count := 0
		for choice_value in choices:
			if not choice_value is Dictionary:
				continue
			var authored_flags: Array = (choice_value as Dictionary).get("flags", [])
			authored_joined_count += authored_flags.count("startup_collab_joined")
			authored_proposed_count += authored_flags.count("startup_collab_proposed")
		_expect(authored_joined_count == 0,
			"%s still authors startup_collab_joined" % event_id)
		_expect(authored_proposed_count == 1,
			"%s does not author exactly one terminal proposal" % event_id)
		var choice_index := int(spec.get("choice_index", -1))
		_expect(choice_index >= 0 and choice_index < choices.size(),
			"%s proposal choice index is invalid" % event_id)
		if choice_index < 0 or choice_index >= choices.size():
			continue
		var applied := GameState.apply_choice(event, choices[choice_index])
		_expect(applied, "%s proposal choice was rejected at runtime" % event_id)
		_expect(bool(GameState.flags.get("startup_collab_proposed", false)),
			"%s proposal choice did not write startup_collab_proposed" % event_id)
		_expect(not bool(GameState.flags.get("startup_collab_joined", false)),
			"%s proposal choice manufactured startup_collab_joined" % event_id)


func _check_legacy_guarantee_window_runtime() -> void:
	var original_language := LocaleManager.language
	var contracts: Array[Dictionary] = [
		{"id": "amb_guarantee_00", "flag": ""},
		{"id": "callback_guarantee_default", "flag": "guarantee_signed"},
		{"id": "callback_guarantee_refused_news", "flag": "guarantee_refused"},
	]
	for language in ["ko", "en"]:
		LocaleManager.language = language
		DataRegistry.reload()
		for contract in contracts:
			var event_id := str(contract["id"])
			var required_flag := str(contract["flag"])
			var event: Dictionary = DataRegistry.find_event(event_id)
			_expect(not event.is_empty(),
				"%s %s guarantee event was not loaded" % [language, event_id])
			if event.is_empty():
				continue
			var conditions: Dictionary = event.get("conditions", {})
			_expect(int(conditions.get("min_turn", -1)) == 8 \
					and int(conditions.get("max_turn", -1)) == 192,
				"%s %s did not load the exact W8-W192 window: %s" % [
					language, event_id, JSON.stringify(conditions)])
			_expect(str(conditions.get("flag", "")) == required_flag,
				"%s %s changed its legacy flag receipt" % [language, event_id])
			_expect(EventManager.is_foreground_random_event(event),
				"%s %s left the authored foreground allowlist" % [language, event_id])
			_expect(not EventManager.is_narrative_bridge_event(event),
				"%s %s entered the narrative bridge allowlist" % [language, event_id])

			for turn_value in [192, 193, 237]:
				GameState.start_new_game()
				GameState.turn = turn_value
				if not required_flag.is_empty():
					GameState.flags[required_flag] = true
				GameState.recent_action_weeks = [{
					"turn": turn_value - 1,
					"money": 1,
					"human": 0,
					"places": {},
					"actions": [],
				}]
				var expected: bool = turn_value == 192
				_expect(EventManager._event_has_causal_context(event),
					"%s %s lost its W%d causal foreground context" % [
						language, event_id, turn_value])
				_expect(EventManager._is_event_eligible(event, true) == expected,
					"%s %s direct eligibility at W%d was not %s" % [
						language, event_id, turn_value, str(expected)])
				_expect(EventManager.deferred_event_is_eligible(event_id) == expected,
					"%s %s deferred eligibility at W%d was not %s" % [
						language, event_id, turn_value, str(expected)])

			# Reproduce the late foreground candidate surface.  The generic root
			# needs a recent money-axis action; callbacks carry their own flag/chain
			# context.  The time window, not cooldown or occurrence count, must close it.
			GameState.start_new_game()
			GameState.turn = 237
			if not required_flag.is_empty():
				GameState.flags[required_flag] = true
			GameState.recent_action_weeks = [{
				"turn": 236,
				"money": 1,
				"human": 0,
				"places": {},
				"actions": [],
			}]
			var foreground_ids: Array[String] = []
			for candidate_value in DataRegistry.events:
				if not candidate_value is Dictionary:
					continue
				var candidate: Dictionary = candidate_value
				if EventManager.is_foreground_random_event(candidate) \
						and EventManager._is_event_eligible(candidate, true) \
						and EventManager._event_has_causal_context(candidate):
					foreground_ids.append(str(candidate.get("id", "")))
			_expect(not foreground_ids.has(event_id),
				"%s W237 foreground pool still contains %s" % [language, event_id])

	# Old saves retain the anonymous friend's exact receipts and history.  After
	# roundtrip, even clearing once-per-run counts cannot reopen a late callback.
	LocaleManager.language = "ko"
	DataRegistry.reload()
	for save_case in [
		{"flag": "guarantee_refused", "callback": "callback_guarantee_refused_news"},
		{"flag": "guarantee_signed", "callback": "callback_guarantee_default"},
	]:
		var legacy_flag := str(save_case["flag"])
		var callback_id := str(save_case["callback"])
		GameState.start_new_game()
		GameState.turn = 237
		GameState.events_seen = 17
		GameState.flags[legacy_flag] = true
		GameState.random_event_counts["amb_guarantee_00"] = 1
		GameState.random_event_counts[callback_id] = 1
		GameState.random_event_last_turns["amb_guarantee_00"] = 44
		GameState.random_event_last_turns[callback_id] = 88
		var encoded := JSON.stringify(GameState.serialize())
		var parsed: Variant = JSON.parse_string(encoded)
		_expect(parsed is Dictionary,
			"%s old-save fixture did not survive JSON encoding" % legacy_flag)
		if not parsed is Dictionary:
			continue
		var parsed_state: Dictionary = parsed
		var history_before := {
			"counts": (parsed_state.get("random_event_counts", {}) as Dictionary).duplicate(true),
			"last_turns": (parsed_state.get("random_event_last_turns", {}) as Dictionary).duplicate(true),
		}
		GameState.start_new_game()
		GameState.load_from_dict(parsed_state.duplicate(true))
		var restored: Dictionary = GameState.serialize()
		var restored_flags: Dictionary = restored.get("flags", {})
		var restored_counts: Dictionary = restored.get("random_event_counts", {})
		var restored_turns: Dictionary = restored.get("random_event_last_turns", {})
		_expect(GameState.turn == 237 and GameState.events_seen == 17 \
				and bool(restored_flags.get(legacy_flag, false)) \
				and int(restored_counts.get("amb_guarantee_00", 0)) == 1 \
				and int(restored_counts.get(callback_id, 0)) == 1 \
				and int(restored_turns.get("amb_guarantee_00", -1)) == 44 \
				and int(restored_turns.get(callback_id, -1)) == 88 \
				and _same({"counts": restored_counts, "last_turns": restored_turns},
					history_before),
			"%s old-save history changed during load/resave" % legacy_flag)
		GameState.random_event_counts.erase("amb_guarantee_00")
		GameState.random_event_counts.erase(callback_id)
		GameState.random_event_last_turns.erase("amb_guarantee_00")
		GameState.random_event_last_turns.erase(callback_id)
		EventManager.event_cooldowns.clear()
		EventManager.recent_event_ids.clear()
		var root_event: Dictionary = DataRegistry.find_event("amb_guarantee_00")
		var callback_event: Dictionary = DataRegistry.find_event(callback_id)
		_expect(not EventManager._is_event_eligible(root_event, true) \
				and not EventManager.deferred_event_is_eligible("amb_guarantee_00") \
				and not EventManager._is_event_eligible(callback_event, true) \
				and not EventManager.deferred_event_is_eligible(callback_id),
			"%s old save reopened anonymous guarantee roots at W237 after count clearing" \
				% legacy_flag)

	var decision: Dictionary = DataRegistry.find_event(
		"arc_y5_jaehyuk_guarantee_decision_reference")
	var finale: Dictionary = DataRegistry.find_event("arc_y5_remaining_jaehyuk_or_self")
	var decision_choices: Array = decision.get("choices", [])
	_expect(decision_choices.size() == 3,
		"authored Jaehyuk guarantee lost its three-way decision")
	if decision_choices.size() == 3:
		var refusal: Dictionary = decision_choices[0]
		var refusal_flags: Array = refusal.get("flags", [])
		_expect(refusal_flags.has("refused_jaehyuk_guarantee") \
				and not refusal_flags.has("guarantee_refused") \
				and not refusal_flags.has("guarantee_signed") \
				and not refusal_flags.has("guarantee_compromise") \
				and str(refusal.get("result_text", "")).contains(
					"대화방은 닫히지 않았다"),
			"authored Jaehyuk refusal lost its distinct open-channel receipt")
	_expect(JSON.stringify(finale).contains(
		"보증을 거절한 밤의 대화방은 열린 채 남아 있었다"),
		"W238 no longer reads the authored Jaehyuk open channel")
	_check_authored_jaehyuk_w238_runtime()
	LocaleManager.language = original_language
	DataRegistry.reload()


func _check_authored_jaehyuk_w238_runtime() -> void:
	GameState.start_new_game("김민준", "지방_상경", "투자형")
	GameState.turn = 195
	GameState.money = 2_100_000_000.0
	GameState.portfolio = {}
	GameState.loans = {"bank": 0.0, "second": 0.0}
	GameState.pending_story_queue = []
	GameState.flags.erase("foreground_story_turn")
	GameState.flags["route_invest"] = true
	for required_flag in [
		"arc_sangchul_met_seen",
		"arc_daeun_met",
		"daeun_romance_started",
		"arc_minseo_02_seen",
		"arc_jaehyuk_reunion_seen",
		"arc_jaehyuk_aftermath_seen",
	]:
		GameState.flags[required_flag] = true
	for excluded_flag in [
		"sangchul_reported",
		"sangchul_cut_ties",
		"sangchul_quietly_distanced",
		"daeun_let_her_go",
		"daeun_divorced",
		"arc_jaehyuk_mirror_seen",
		"refused_jaehyuk_guarantee",
		"vouched_jaehyuk_guarantee",
		"blocked_jaehyuk_guarantee",
		"jaehyuk_final_break",
	]:
		GameState.flags.erase(excluded_flag)
	_expect(GameState.prepare_chapter5_causal_route_entry(),
		"authored Jaehyuk source route did not enter at W195")
	var source_choice_indices := {
		"arc_y5_jaehyuk_guarantee_decision_reference": 0,
		"arc_sangchul_final_door": 0,
		"arc_y5_three_in_room_decision": 1,
	}
	for turn_value in range(195, 221):
		GameState.turn = turn_value
		while true:
			var source_event_id := GameState.chapter5_causal_next_event_for_turn()
			if source_event_id.is_empty():
				break
			var source_result := GameState.record_chapter5_causal_choice(
				source_event_id, int(source_choice_indices.get(source_event_id, 0)))
			_expect(bool(source_result.get("ok", false)),
				"authored Jaehyuk source receipt failed at W%d/%s" % [
					turn_value, source_event_id])
			if not bool(source_result.get("ok", false)):
				return

	GameState.turn = 221
	_expect(GameState.prepare_chapter5_finale_route_entry(),
		"authored Jaehyuk refusal did not lock the property finale")
	for turn_value in [221, 224, 227, 230, 235]:
		GameState.turn = turn_value
		var event_id := GameState.chapter5_finale_next_event_for_turn()
		_expect(not event_id.is_empty() \
				and GameState.chapter5_finale_ingress_available(event_id),
			"property finale ingress failed before W238 at W%d" % turn_value)
		if event_id.is_empty():
			return
		var result := GameState.record_chapter5_finale_choice(event_id, 0)
		_expect(bool(result.get("ok", false)),
			"property finale receipt failed before W238 at W%d/%s" % [
				turn_value, event_id])
		if not bool(result.get("ok", false)):
			return

	GameState.turn = 238
	var w238_id := GameState.chapter5_finale_next_event_for_turn()
	_expect(w238_id == "arc_y5_remaining_jaehyuk_or_self" \
			and GameState.chapter5_finale_ingress_available(w238_id),
		"W238 did not enter the authored Jaehyuk guarantee return")
	var w238: Dictionary = DataRegistry.find_event(w238_id)
	var reads: Dictionary = w238.get("chapter5_finale_reads", {})
	var sources: Array = reads.get("sources", [])
	_expect(sources.size() == 2,
		"W238 authored Jaehyuk return lost its two exact read sources")
	if sources.size() != 2:
		return
	var jaehyuk_source := GameState.chapter5_finale_read_source_snapshot(sources[0])
	var nontransaction_source := GameState.chapter5_finale_read_source_snapshot(sources[1])
	_expect(bool(jaehyuk_source.get("ok", false)) \
			and int(jaehyuk_source.get("index", -1)) == 0 \
			and int(jaehyuk_source.get("count", 0)) == 3,
		"W238 did not read the exact authored Jaehyuk refusal receipt")
	_expect(bool(nontransaction_source.get("ok", false)) \
			and int(nontransaction_source.get("index", -1)) == 0 \
			and int(nontransaction_source.get("count", 0)) == 1,
		"W238 did not read the no-executable-contract receipt")


func _check_wallet_meal_consent_runtime() -> void:
	var invitation: Dictionary = DataRegistry.find_event("chain_exec_meal")
	var arrival: Dictionary = DataRegistry.find_event("chain_exec_meal_arrival")
	_expect(not invitation.is_empty(), "wallet meal invitation was not loaded")
	_expect(not arrival.is_empty(), "wallet meal arrival was not loaded")
	if invitation.is_empty() or arrival.is_empty():
		return
	_expect(str(invitation.get("background", "")) == "current_housing",
		"wallet meal invitation does not begin at current_housing")
	_expect(_condition_has(invitation, "flag", "returned_wallet"),
		"wallet meal invitation lost the returned_wallet receipt")
	_expect(str(arrival.get("background", "")) == "hanjeongsik_restaurant_day",
		"wallet meal arrival does not move to the daytime Hanjeongsik restaurant")
	_expect(_condition_has(arrival, "flag", "chain_exec_meal_accepted"),
		"wallet meal arrival can occur without the acceptance receipt")

	var invitation_choices: Array = invitation.get("choices", [])
	var arrival_choices: Array = arrival.get("choices", [])
	_expect(invitation_choices.size() == 2,
		"wallet meal invitation lost accept/decline ownership")
	_expect(arrival_choices.size() == 2,
		"wallet meal arrival lost honest/distance ownership")
	if invitation_choices.size() != 2 or arrival_choices.size() != 2:
		return
	var accept: Dictionary = invitation_choices[0]
	var decline: Dictionary = invitation_choices[1]
	_expect(str(accept.get("follow_up_event", "")) \
			== "chain_exec_meal_arrival",
		"wallet meal acceptance lost its visible restaurant arrival")
	_expect(str(decline.get("follow_up_event", "")).is_empty() \
			and not decline.has("deferred_follow_up"),
		"wallet meal decline still schedules a meeting")

	GameState.start_new_game()
	GameState.turn = 40
	GameState.flags["returned_wallet"] = true
	_expect(GameState.apply_choice(invitation, decline),
		"wallet meal decline was rejected at runtime")
	_expect(not bool(GameState.flags.get("chain_exec_meal_accepted", false)),
		"wallet meal decline manufactured acceptance")
	_expect(not EventManager.deferred_event_is_eligible(
			"chain_exec_meal_arrival"),
		"wallet meal arrival became eligible after decline")
	_expect(GameState.deferred_events.is_empty(),
		"wallet meal decline queued a deferred meeting")

	GameState.start_new_game()
	GameState.turn = 40
	GameState.flags["returned_wallet"] = true
	_expect(GameState.apply_choice(invitation, accept),
		"wallet meal acceptance was rejected at runtime")
	_expect(bool(GameState.flags.get("chain_exec_meal_accepted", false)),
		"wallet meal acceptance did not persist consent")
	_expect(EventManager.deferred_event_is_eligible(
			"chain_exec_meal_arrival"),
		"wallet meal arrival stayed closed after acceptance")
	_expect(GameState.deferred_events.is_empty(),
		"wallet meal acceptance skipped the visible arrival with a deferred edge")

	var honest: Dictionary = arrival_choices[0]
	_expect(GameState.apply_choice(arrival, honest),
		"wallet meal honest disclosure was rejected at runtime")
	_expect(bool(GameState.flags.get("chain_exec_referral", false)),
		"wallet meal honest disclosure lost the referral receipt")
	var interview_scheduled := false
	for deferred_value in GameState.deferred_events:
		var deferred: Dictionary = deferred_value
		if str(deferred.get("event_id", "")) == "chain_exec_interview" \
				and int(deferred.get("trigger_turn", -1)) == 50:
			interview_scheduled = true
			break
	_expect(interview_scheduled,
		"wallet meal arrival did not schedule the interview at +10")


func _condition_has(event: Dictionary, key: String, expected: String) -> bool:
	var conditions: Dictionary = event.get("conditions", {})
	var raw: Variant = conditions.get(key, null)
	if raw is Array:
		return expected in (raw as Array)
	return raw != null and str(raw) == expected


func _check_main_game_runtime_contracts() -> void:
	var main_game: Node = MAIN_GAME_SCRIPT.new()
	GameState.turn = 1
	_expect(bool(main_game.call("_main_game_tutorial_allowed")),
		"MainGame rejected the tutorial on the first playable turn")
	for late_turn in [2, 193, 240]:
		GameState.turn = late_turn
		_expect(not bool(main_game.call("_main_game_tutorial_allowed")),
			"MainGame allowed the onboarding tutorial at turn %d" % late_turn)
	main_game.free()

	# Render the actual finale page twice.  This checks the user-visible label,
	# rather than merely searching source for a format string.
	var first_progress := _render_finale_progress(0, 2)
	var last_progress := _render_finale_progress(1, 2)
	_expect(first_progress.find("1 / 6") >= 0 \
			and first_progress.find("1 / 2") >= 0,
		"first finale beat did not render page 1/6 plus scene 1/2: %s" \
				% first_progress)
	_expect(last_progress.find("1 / 6") >= 0 \
			and last_progress.find("2 / 2") >= 0,
		"last finale beat did not render page 1/6 plus scene 2/2: %s" \
				% last_progress)


func _render_finale_progress(beat_index: int, beat_count: int) -> String:
	var main_game: Control = MAIN_GAME_SCRIPT.new()
	var modal_body := VBoxContainer.new()
	main_game.add_child(modal_body)
	main_game.set("modal_body", modal_body)
	main_game.set("_ending_id", "ordinary_life")
	main_game.set("_ending_data", {
		"title": "ORDER-150 runtime fixture",
		"grade": "C",
	})
	main_game.set("_ending_cg_path", "")
	var beats: Array[String] = []
	for index in range(beat_count):
		beats.append("Runtime finale beat %d" % [index + 1])
	main_game.set("_ending_finale_beats", beats)
	main_game.set("_ending_finale_beat_index", beat_index)
	main_game.call("_ending_build_finale_page")

	var labels: Array[String] = []
	_collect_label_text(modal_body, labels)
	var progress := " | ".join(labels)
	main_game.free()
	return progress


func _collect_label_text(root: Node, labels: Array[String]) -> void:
	if root is Label:
		labels.append((root as Label).text)
	for child in root.get_children():
		_collect_label_text(child, labels)


func _check_jiyeon_truth_contact_runtime() -> void:
	var original_language := LocaleManager.language
	var main_game: Node = MAIN_GAME_SCRIPT.new()
	GameState.start_new_game()
	GameState.flags = {"arc_jiyeon_truth_seen": true}
	var expected_by_language := {
		"ko": [
			"오늘은 잘 지낸다는 말부터 꺼내지 않았다. 지연에게 지금 감당할 수 있는 사정 하나를 먼저 말했다. 숨기지 않는 연습은 매번 다른 데서 시작됐다.",
			"예전 같으면 숫자를 크게 말했을 대목에서, 오늘은 모르는 것을 모른다고 말했다. 지연과의 대화는 그렇게 한 겹 덜 꾸며졌다.",
			"그날 털어놓은 진실을 되풀이하는 대신, 이번 주에 실제로 놓친 일을 하나 말했다. 숨기지 않는다는 건 같은 말을 반복하는 일이 아니었다.",
		],
		"en": [
			"Today I didn't begin by saying everything was fine. I told Jiyeon one circumstance I could actually face. Practicing honesty began somewhere different each time.",
			"Where I once would have made the numbers sound bigger, today I said I didn't know. That left one less layer of performance in my conversation with Jiyeon.",
			"Instead of repeating the truth we had already laid bare, I named one thing I had actually missed this week. Hiding nothing did not mean repeating the same words.",
		],
	}
	for language_value in expected_by_language:
		var language := str(language_value)
		# Direct assignment avoids persisting a QA-only language setting.  _tr reads
		# this value synchronously, and DataRegistry does not need a reload here.
		LocaleManager.language = language
		var actual: Array[String] = []
		for contact_number in range(1, 4):
			GameState.contact_counts["jiyeon"] = contact_number
			actual.append(str(main_game.call("_contact_flavor", "jiyeon", 30)))
		var expected: Array = expected_by_language.get(language, [])
		_expect(_same(actual, expected),
			"Jiyeon truth-contact %s variants drifted: %s" % [
				language, JSON.stringify(actual)])
		var unique: Dictionary = {}
		for line in actual:
			unique[line] = true
		_expect(actual.size() == 3 and unique.size() == 3,
			"Jiyeon truth-contact %s repeated within three consecutive contacts" \
				% language)
		GameState.contact_counts["jiyeon"] = 4
		var fourth := str(main_game.call("_contact_flavor", "jiyeon", 30))
		_expect(not actual.is_empty() and fourth == actual[0],
			"Jiyeon truth-contact %s rotation is not exactly three variants" \
				% language)
	LocaleManager.language = original_language
	main_game.free()


func _check_loaded_story_contracts() -> void:
	# These assertions read DataRegistry after its locale overlay and mod pass,
	# which is the object StoryMode receives at runtime.
	var final_winter: Dictionary = DataRegistry.find_event("final_last_winter")
	_expect(not final_winter.is_empty(),
		"DataRegistry did not load final_last_winter")
	var winter_conditions: Dictionary = final_winter.get("conditions", {})
	_expect(int(winter_conditions.get("min_turn", -1)) == 224 \
			and int(winter_conditions.get("max_turn", -1)) == 227 \
			and int(winter_conditions.get("month", -1)) == 9,
		"final_last_winter is not the September W225-W227 window")
	_expect(str(winter_conditions.get("no_flag", "")) \
			== "arc_pre_ending_winter_seen",
		"final_last_winter lost its late-scene exclusion flag")
	_expect(str(final_winter.get("background", "")) == "current_housing",
		"final_last_winter is not staged in current_housing")
	_expect(_portrait_is_empty(final_winter),
		"final_last_winter acquired a physical portrait")
	var winter_presentation: Dictionary = DataRegistry.get_story_presentation(
		"final_last_winter")
	_expect(str(winter_presentation.get("channel", "")) == "narration" \
			and str(winter_presentation.get("portrait_role", "")) == "none" \
			and str(winter_presentation.get("scene_location", "")) \
				== "current_housing",
		"final_last_winter runtime presentation contract drifted")

	var minseo: Dictionary = DataRegistry.find_event("arc_minseo_03_arrival")
	_expect(not minseo.is_empty(),
		"DataRegistry did not load arc_minseo_03_arrival")
	_expect(str(minseo.get("background", "")) == "current_housing",
		"remote Minseo event left the player's current housing")
	_expect(_portrait_is_empty(minseo),
		"remote Minseo event loaded a physical Minseo portrait")
	_expect(int((minseo.get("conditions", {}) as Dictionary).get(
		"min_turn", -1)) == 9999,
		"legacy ambient ingress for arc_minseo_03_arrival reopened")
	var minseo_presentation: Dictionary = DataRegistry.get_story_presentation(
		"arc_minseo_03_arrival")
	_expect(str(minseo_presentation.get("channel", "")) == "message" \
			and str(minseo_presentation.get("remote_actor", "")) == "minseo" \
			and str(minseo_presentation.get("remote_location", "")) \
				== "minseo_current_location",
		"Minseo's runtime channel is not an explicit remote message")
	_expect(_same(minseo_presentation.get("participants", []), ["player"]),
		"remote Minseo event gained an unstaged local participant")
	_expect(str(minseo_presentation.get("portrait_role", "")) == "none" \
			and str(minseo_presentation.get("nameplate_role", "")) == "hidden",
		"remote Minseo message gained a portrait or visible speaker nameplate")
	_expect(str(minseo_presentation.get("expected_background", "")) \
			== "current_housing",
		"remote Minseo message expects a non-player location")

	# Later general-route callbacks may show Minjun locally, but never Minseo.
	# Their loaded story rules must continue to make the player the sole staged
	# participant and bind the local portrait to Minjun.
	for event_id in [
		"arc_y5_general_debt_memory_reconnect",
		"arc_y5_final_week_general_people_outbound",
	]:
		var event: Dictionary = DataRegistry.find_event(event_id)
		var presentation: Dictionary = DataRegistry.get_story_presentation(event_id)
		_expect(not event.is_empty(), "%s was not loaded" % event_id)
		_expect(str(event.get("background", "")) == "current_housing",
			"%s left the player's current housing" % event_id)
		_expect(str(event.get("portrait", "")).find("minseo") < 0,
			"%s loaded a physical Minseo portrait" % event_id)
		_expect(str(presentation.get("channel", "")) == "internal" \
				and _same(presentation.get("participants", []), ["player"]) \
				and str(presentation.get("portrait_role", "")) == "local" \
				and str(presentation.get("expected_portrait", "")) \
					== "player_tired",
			"%s no longer stages a player-only internal scene: %s" % [
				event_id, JSON.stringify(presentation)])


func _check_minseo_outbound_results_runtime() -> void:
	var original_language := LocaleManager.language
	var required_by_language := {
		"ko": [
			["적어 보냈다", "자기 말풍선 아래에는 발신 시각만 남았다",
				"읽음도 답장도, 다음 약속도 생기지 않았다"],
			["적어 보냈다", "화면에는 자기 쪽 발신 시각만 생겼다",
				"읽음도 답장도 없었다"],
		],
		"en": [
			["pressed send", "Only the sent time remained beneath his bubble",
				"No read receipt, reply, or next appointment appeared"],
			["pressed send", "The screen showed only his sent time",
				"No read receipt or reply appeared"],
		],
	}
	var forbidden_by_language := {
		"ko": ["민서가 답", "민서가 웃", "민서가 고개를 끄덕",
			"읽음 표시가 떴", "답장이 왔다", "다음 약속을 잡"],
		"en": ["Minseo replied", "Minseo smiled", "Minseo nodded",
			"A read receipt appeared", "A reply came", "They set the next"],
	}
	for language_value in required_by_language:
		var language := str(language_value)
		LocaleManager.language = language
		DataRegistry.reload()
		var event: Dictionary = DataRegistry.find_event("arc_minseo_03_arrival")
		var choices: Array = event.get("choices", [])
		_expect(choices.size() == 2,
			"M51 Minseo %s overlay does not expose exactly two choices" % language)
		if choices.size() != 2:
			continue
		var expected_choices: Array = required_by_language.get(language, [])
		var forbidden: Array = forbidden_by_language.get(language, [])
		for index in range(2):
			var choice: Dictionary = choices[index]
			var result_text := str(choice.get("result_text", ""))
			_expect(_contains_all(result_text, expected_choices[index]),
				"M51 Minseo %s choice %d is not outbound/no-reply: %s" % [
					language, index, result_text])
			_expect(_contains_none(result_text, forbidden),
				"M51 Minseo %s choice %d invented a remote reaction: %s" % [
					language, index, result_text])
	LocaleManager.language = original_language
	DataRegistry.reload()


func _check_scene_context_repair_runtime() -> void:
	# Loaded KO and EN event objects are the actual StoryMode input. This does
	# not replace the separate paragraph-by-paragraph StoryPlayback regression.
	var original_language := LocaleManager.language
	var home_events := ["age_39_final", "casino_comp_offer",
		"callback_casino_declined_comp_echo", "callback_casino_accepted_comp_echo"]
	var expected_channels := {
		"age_39_final": "internal", "casino_comp_offer": "message",
		"callback_casino_declined_comp_echo": "internal",
		"callback_casino_accepted_comp_echo": "internal",
	}
	var expected_portraits := {
		"casino_comp_offer": "player_normal",
		"callback_casino_declined_comp_echo": "player_determined",
		"callback_casino_accepted_comp_echo": "player_tired",
	}
	var variant_keys := ["final_year_resolve", "final_year_realistic",
		"final_year_open", "accepted_current_path", "final_push_decided"]
	var casino_reply_required := {
		"ko": [
			["가지 않겠습니다", "적어 보냈다", "전송 시각만 남았다", "답장은 아직 없었다",
				"달력에는 날짜를 더하지 않았다", "방 안의 물건들은 제자리에 있었다"],
			["이용 가능한 날짜를 알려주세요", "적어 보냈다", "전송 시각이 떴다",
				"답장은 아직 없었다", "예약된 날짜도 없었다", "방을 나선 것도, 돈을 건 것도 아닌데"],
		],
		"en": [
			["won't be going this time", "and sends it", "Only a sent timestamp",
				"No reply has arrived", "adds no date to the calendar", "everything in the room stays"],
			["Please let me know the available dates", "and sends it", "A sent timestamp appears",
				"No reply has arrived", "no date is booked", "neither left the room nor placed a bet"],
		],
	}
	for language in ["ko", "en"]:
		LocaleManager.language = language
		DataRegistry.reload()
		GameState.start_new_game()
		GameState.age = 37
		GameState.month = 6
		GameState.turn = 213
		var milestone: Dictionary = DataRegistry.find_event("age_39_final")
		var expected_title := "마지막 일곱 달" if language == "ko" else "The Last Seven Months"
		var opening := "서른여덟 생일까지 이번 달을 포함해 일곱 달이 남았다." \
			if language == "ko" else \
			"Thirty-eight is seven months away, counting this month."
		_expect(str(milestone.get("title", "")) == expected_title,
			"%s M54 title lost the seven-month boundary" % language)
		_expect(str(milestone.get("description", "")).begins_with(opening),
			"%s M54 base description lost the inclusive seven-month opening" % language)
		var variants: Dictionary = milestone.get("description_if_known", {})
		_expect(variants.size() == variant_keys.size(),
			"%s M54 must retain all five description variants" % language)
		for variant in variant_keys:
			_expect(str(variants.get(variant, "")).begins_with(opening),
				"%s M54 variant %s contradicts the seven-month HUD" % [language, variant])
		var old_duration := ["반년", "스물네", "24주", "24칸", "여섯 달"] \
			if language == "ko" else ["half year", "half-year", "six months", "twenty-four", "24 weeks"]
		_expect(_contains_none(JSON.stringify(milestone).to_lower(), old_duration),
			"%s M54 still contains fixed half-year/24-week prose" % language)
		_expect((milestone.get("choices", []) as Array).size() == 3,
			"%s M54 choice count changed" % language)
		var milestone_choices: Array = milestone.get("choices", [])
		if milestone_choices.size() == 3:
			var plan_result := str((milestone_choices[0] as Dictionary).get("result_text", ""))
			_expect(plan_result.contains("주문창은 열지 않고" if language == "ko" else "leaves the order screen closed"),
				"%s M54 planning result became an executed trade" % language)

		for event_id in home_events:
			var event: Dictionary = DataRegistry.find_event(event_id)
			var presentation: Dictionary = DataRegistry.get_story_presentation(event_id)
			_expect(str(event.get("background", "")) == "current_housing",
				"%s %s does not load its live home background" % [language, event_id])
			_expect(str(presentation.get("scene_location", "")) == "current_housing" \
					and str(presentation.get("expected_background", "")) == "current_housing" \
					and str(presentation.get("channel", "")) == str(expected_channels[event_id]),
				"%s %s loaded an incompatible location/channel contract" % [language, event_id])
			var expected_participants: Array = ["player", "casino_manager"] \
				if event_id == "casino_comp_offer" else ["player"]
			_expect(_same(presentation.get("participants", []), expected_participants),
				"%s %s participants drifted" % [language, event_id])
			_expect(str(presentation.get("portrait_role", "")) == "local" \
					and str(presentation.get("nameplate_role", "")) == "hidden",
				"%s %s local portrait/nameplate ownership drifted" % [language, event_id])
			if expected_portraits.has(event_id):
				_expect(str(event.get("portrait", "")) == str(expected_portraits[event_id]) \
						and str(presentation.get("expected_portrait", "")) == str(expected_portraits[event_id]),
					"%s %s local acting changed" % [language, event_id])
			if str(event_id).begins_with("callback_casino_"):
				var recalled_travel := ["막차 타고", "막차에 오른", "하룻밤 더 머문", "더 잃었다"] \
					if language == "ko" else ["catch the last train", "catching the last train",
					"the night they stayed longer", "they lost more"]
				_expect(_contains_none(JSON.stringify(event).to_lower(), recalled_travel),
					"%s %s invents a past journey or cash loss" % [language, event_id])
			for home_case in ["single", "married", "divorced"]:
				GameState.housing = "gosiwon"
				GameState.flags = {}
				if home_case != "single":
					GameState.flags["arc_daeun_wedding_day_seen"] = true
				if home_case == "divorced":
					GameState.flags["daeun_divorced"] = true
				var expected_home := "daeun_newlywed_home" if home_case == "married" else "goshiwon_room"
				var resolved := ImageRegistry.resolve_contextual_background_id(str(event.get("background", "")))
				_expect(resolved == expected_home,
					"%s %s %s resolved to %s" % [language, event_id, home_case, resolved])
				var audio: Dictionary = BGMPlayer.scene_audio_contract(event_id)
				var authored_ambience := str(audio.get("ambience", ""))
				var ambience := BGMPlayer._resolve_dynamic_ambience_key(authored_ambience) \
					if not authored_ambience.is_empty() else BGMPlayer._pick_ambience(event, resolved)
				_expect(ambience == ("oneroom" if home_case == "married" else "room"),
					"%s %s %s kept non-home ambience: %s" % [language, event_id, home_case, ambience])

		var casino: Dictionary = DataRegistry.find_event("casino_comp_offer")
		var casino_presence: Dictionary = DataRegistry.get_story_presentation("casino_comp_offer")
		_expect(DataRegistry.get_scene_direction_event_intent("casino_comp_offer") == "remote",
			"%s casino message loaded non-remote scene direction" % language)
		_expect(str(casino_presence.get("remote_actor", "")) == "casino_manager" \
				and str(casino_presence.get("remote_location", "")) == "jeongseon_casino",
			"%s casino sender is not explicitly remote" % language)
		var forbidden_visit := ["오늘 많이 즐기셨네요", "버스 터미널로 걸었다",
			"막차는 빠듯했다", "방은 좋았다", "다시 칩을 바꿨다", "체크아웃할 때 통장에 찍혔다"] \
			if language == "ko" else ["you've enjoyed yourself today", "manager approached",
			"walked to the bus terminal", "the room was nice", "exchanged chips again", "account at checkout"]
		_expect(_contains_none(JSON.stringify(casino).to_lower(), forbidden_visit),
			"%s casino message invented an on-site visit or betting outcome" % language)
		var casino_choices: Array = casino.get("choices", [])
		_expect(casino_choices.size() == 2, "%s casino offer lost a choice" % language)
		for index in range(casino_choices.size()):
			if index < 2:
				_expect(_contains_all(str((casino_choices[index] as Dictionary).get("result_text", "")),
					casino_reply_required[language][index]),
					"%s casino reply %d lost sent-only/no-booking/no-travel scope" % [language, index])
			GameState.start_new_game()
			GameState.turn = 212
			GameState.flags = {"casino_club_introduced": true}
			var choice: Dictionary = casino_choices[index]
			var expected_flag := "casino_declined_comp" if index == 0 else "casino_accepted_comp"
			var money_before: float = GameState.money
			var turn_before: int = GameState.turn
			_expect(GameState.apply_choice(casino, choice),
				"%s casino reply choice %d did not apply" % [language, index])
			_expect(bool(GameState.flags.get(expected_flag, false)) \
					and GameState.money == money_before and GameState.turn == turn_before,
				"%s casino reply choice %d changed cash/time or lost its existing flag" % [language, index])
			_expect(str(choice.get("follow_up_event", "")).is_empty() \
					and str(choice.get("deferred_follow_up", "")).is_empty() \
					and str(choice.get("result_background", "")).is_empty(),
				"%s casino reply choice %d schedules a trip or leaves the room" % [language, index])

		var custody: Dictionary = DataRegistry.find_event("arc_y5_father_trace_custody")
		var custody_presence: Dictionary = DataRegistry.get_story_presentation("arc_y5_father_trace_custody")
		_expect(str(custody.get("background", "")) == "convenience_night" \
				and str(custody_presence.get("scene_location", "")) == "convenience_store" \
				and str(custody_presence.get("expected_background", "")) == "convenience_night",
			"%s W224 custody text does not use the convenience-store background" % language)
		_expect(str(BGMPlayer.scene_audio_contract("arc_y5_father_trace_custody").get("ambience", "")) == "convenience",
			"%s W224 custody retained room ambience" % language)

		# Same milestone ingress and HUD calendar semantics for every M54 week.
		var main_game: Node = MAIN_GAME_SCRIPT.new()
		GameState.age = 37
		GameState.month = 6
		GameState.money = 0
		GameState.flags = {"story_first_savings_seen": true}
		for week in range(213, 217):
			GameState.turn = week
			GameState.week_of_month = week - 212
			_expect(str(main_game.call("_next_milestone_id")) == "age_39_final" \
					and (38 - GameState.age) * 12 - GameState.month + 1 == 7,
				"%s M54 W%d ingress/seven-month calendar moved" % [language, week])
		main_game.free()
	LocaleManager.language = original_language
	DataRegistry.reload()


func _contains_all(source: String, tokens: Array) -> bool:
	for token in tokens:
		if source.find(str(token)) < 0:
			return false
	return true


func _contains_none(source: String, tokens: Array) -> bool:
	for token in tokens:
		if source.find(str(token)) >= 0:
			return false
	return true


func _portrait_is_empty(event: Dictionary) -> bool:
	var portrait: Variant = event.get("portrait", null)
	return portrait == null or str(portrait).strip_edges().is_empty()


func _economic_bytes() -> String:
	return JSON.stringify({
		"housing": GameState.housing,
		"housing_info": GameState.get_housing_info(),
		"housing_expense": GameState.get_housing_expense(),
		"fixed_expense": GameState.fixed_expense,
		"money": GameState.money,
		"monthly_income": GameState.monthly_income,
		"loans": GameState.loans,
		"portfolio": GameState.portfolio,
		"inventory": GameState.inventory,
		"market_prices": GameState.market_prices,
		"price_history": GameState.price_history,
		"total_assets": GameState.get_total_asset_value(),
	})


func _serialized_bytes() -> String:
	return JSON.stringify(GameState.serialize())


func _same(left: Variant, right: Variant) -> bool:
	return JSON.stringify(left) == JSON.stringify(right)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
