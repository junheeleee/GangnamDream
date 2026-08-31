extends Node
## 유물 제시 3경로와 히든 3경로를 실제 런타임 코드로 실행한다.

const StoryModeScript = preload("res://scenes/StoryMode.gd")
const MainGameScript = preload("res://scenes/MainGame.gd")
const MainGameScene = preload("res://scenes/MainGame.tscn")
const ARTIFACT_IDS: Array[String] = [
	"artifact_sangchul_card",
	"artifact_daeun_note",
	"artifact_father_call",
	"artifact_jiyeon_text",
	"artifact_jaehyuk_photo",
	"artifact_hyunsu_card",
]

var _failures: Array[String] = []
var _original_language := "en"
var _original_time_scale := 1.0
var _had_meta_file := false
var _original_meta_text := ""
var _captured_ending := ""
var _drawer_callback_count := 0

func _ready() -> void:
	_had_meta_file = FileAccess.file_exists(MetaProgression.META_SAVE_PATH)
	if _had_meta_file:
		_original_meta_text = FileAccess.get_file_as_string(MetaProgression.META_SAVE_PATH)
	_original_language = LocaleManager.language
	_original_time_scale = Engine.time_scale

	_check_artifact_choice_visibility()
	_check_choice_item_grants()
	_check_jaehyuk_follow_up()
	_check_father_medication_follow_up_gate()
	_check_route_safe_father_and_lease_receipts()
	_check_jiyeon_third_path()
	_check_daeun_post_it_route()
	_check_dawn_people()
	await _check_drawer_truth_cut()
	_check_kept_artifact_ledger()

	Engine.time_scale = _original_time_scale
	_restore_meta_file()
	LocaleManager.language = _original_language
	DataRegistry.reload()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("HIDDEN_FEATURE_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("HIDDEN_FEATURE_CHECK_OK artifact_choices=3 choice_grants=3 follow_up=1 typed_delay=medication_blocked+w85_route_priority jiyeon_dik=1 daeun_route=1 dawn=5 drawer=1 keepsakes=6")
	get_tree().quit(0)

func _check_artifact_choice_visibility() -> void:
	var story = StoryModeScript.new()
	var cases := [
		{"event": "arc_jaehyuk_ghost_decision", "item": "artifact_jaehyuk_photo"},
		{"event": "arc_jiyeon_verdict_decision", "item": "artifact_jiyeon_text"},
		{"event": "arc_daeun_final_choice_decision", "item": "artifact_daeun_note"},
	]
	for language in ["ko", "en"]:
		LocaleManager.language = language
		DataRegistry.reload()
		for test_case in cases:
			_reset_run()
			var event_id := str(test_case["event"])
			var item_id := str(test_case["item"])
			var event: Dictionary = DataRegistry.find_event(event_id)
			if event.is_empty():
				_fail("%s event is missing in %s" % [event_id, language])
				continue
			_assert_int_array(
				"%s/%s without artifact" % [language, event_id],
				story._visible_choice_indices(event), [0, 1])
			GameState.add_item(item_id, 1)
			_assert_int_array(
				"%s/%s with artifact" % [language, event_id],
				story._visible_choice_indices(event), [0, 1, 2])
			var third: Dictionary = event.get("choices", [])[2]
			if str(third.get("requires_item", "")) != item_id:
				_fail("%s third choice is not gated by %s" % [event_id, item_id])
	print("HIDDEN_FEATURE_EVIDENCE artifact_choices KO_EN=3x2 hidden_without_item=1 visible_with_item=1")
	story.free()

func _check_choice_item_grants() -> void:
	LocaleManager.language = "ko"
	DataRegistry.reload()
	var event: Dictionary = DataRegistry.find_event("arc_sangchul_01_answer")
	var choices: Array = event.get("choices", []) as Array
	if choices.size() != 3:
		_fail("Sangchul first-meeting grant fixture must have three answers")
		return
	for index in range(choices.size()):
		_reset_run()
		GameState.apply_choice(event, choices[index] as Dictionary)
		var quantity := 0
		for owned in GameState.inventory:
			if str(owned.get("id", "")) == "artifact_sangchul_card":
				quantity = int(owned.get("quantity", 0))
		if quantity != 1:
			_fail("Sangchul answer %d granted card quantity %d instead of 1" % [index, quantity])
	print("HIDDEN_FEATURE_EVIDENCE choice_grants sangchul_card=3x1")

func _check_route_safe_father_and_lease_receipts() -> void:
	for language in ["ko", "en"]:
		LocaleManager.language = language
		DataRegistry.reload()
		var father: Dictionary = DataRegistry.find_event("arc_father_04_visit")
		var default_text := str(father.get("description", ""))
		var network_text := str((father.get("description_if_known", {}) as Dictionary).get(
			"arc_sangchul_03_seen", ""))
		if default_text.contains("상철") or default_text.contains("Sangchul") \
				or network_text.is_empty():
			_fail("%s father door lost route-safe network surface" % language)
		var year_close: Dictionary = DataRegistry.find_event("arc_year2_close")
		var variants: Dictionary = year_close.get("description_if_known", {})
		for flag_id in ["y2_lease_renewed_one_year", "y2_lease_renewed_six_months", "y2_lease_move_out_scheduled"]:
			if str(variants.get(flag_id, "")).is_empty():
				_fail("%s Year 2 close lost lease reader %s" % [language, flag_id])
	print("HIDDEN_FEATURE_EVIDENCE route_safe_father+lease_receipts KO_EN")

func _check_jaehyuk_follow_up() -> void:
	LocaleManager.language = "ko"
	DataRegistry.reload()
	_reset_run()
	GameState.add_item("artifact_jaehyuk_photo", 1)
	var story = StoryModeScript.new()
	var event: Dictionary = DataRegistry.find_event("arc_jaehyuk_ghost_decision")
	var choice: Dictionary = event.get("choices", [])[2]
	var follow_up: String = story._choice_follow_up_id(choice)
	if follow_up != "arc_jaehyuk_photo_in_dark":
		_fail("Jaehyuk photo choice follow-up was %s" % follow_up)
	if DataRegistry.find_event(follow_up).is_empty():
		_fail("Jaehyuk photo follow-up target is missing")
	GameState.apply_choice(event, choice)
	for flag_id in ["arc_jaehyuk_ghost_seen", "jaehyuk_scammed", "presented_artifact_correct"]:
		if not GameState.flags.get(flag_id, false):
			_fail("Jaehyuk photo route did not set %s" % flag_id)
	print("HIDDEN_FEATURE_EVIDENCE jaehyuk follow_up=%s flags=3" % follow_up)
	story.free()

func _check_father_medication_follow_up_gate() -> void:
	LocaleManager.language = "ko"
	DataRegistry.reload()
	_reset_run()
	var story = StoryModeScript.new()
	var event: Dictionary = DataRegistry.find_event(
		"arc_father_medication")
	var choices: Array = event.get("choices", []) as Array
	if choices.size() != 3:
		_fail("Father medication fixture must have three choices")
		story.free()
		return
	for choice_index in range(choices.size()):
		var choice: Dictionary = choices[choice_index]
		if story._choice_follow_up_id(
				choice, "arc_father_medication", choice_index) != "":
			_fail(
				"Father medication choice %d bypassed Jiyeon's reunion gate"
					% choice_index)
	GameState.flags["arc_jiyeon_store_seen"] = true
	for choice_index in range(choices.size()):
		var choice: Dictionary = choices[choice_index]
		if story._choice_follow_up_id(
				choice, "arc_father_medication", choice_index) != "":
			_fail(
				"Father medication choice %d restored the old immediate Jiyeon chain"
					% choice_index)
	GameState.flags["arc_father_medication_seen"] = true
	GameState.flags.erase("arc_jiyeon_offer_seen")
	GameState.flags["chapter_33_seen"] = true
	GameState.flags["chapter_34_seen"] = true
	var game = MainGameScript.new()
	if game._next_arc_id(58, true, false) == "arc_jiyeon_03_offer":
		_fail("Father medication still opened Jiyeon in the M15 source week")
	game.free()

	# Jiyeon's reunion is a typed M22 ingress. It opens only when Daeun's
	# established route does not own the month, and Daeun retains priority when
	# both people's historical facts exist.
	GameState.flags.erase("arc_daeun_regular_seen")
	GameState.flags.erase("arc_daeun_fork_seen")
	game = MainGameScript.new()
	if game._next_arc_id(85, true, false) != "arc_jiyeon_03_offer":
		_fail("Eligible Jiyeon history did not open in the exact M22 window")
	game.free()
	GameState.flags["arc_daeun_regular_seen"] = true
	GameState.apply_cast_effect("daeun", {"affinity": 20})
	game = MainGameScript.new()
	if game._next_arc_id(85, true, false) != "arc_daeun_03_fork":
		_fail("M22 route priority did not preserve Daeun before Jiyeon")
	game.free()
	var health_call: Dictionary = DataRegistry.find_event(
		"father_health_call")
	var no_flags: Variant = (
		health_call.get("conditions", {}) as Dictionary
	).get("no_flag", [])
	if not no_flags is Array \
			or not (no_flags as Array).has(
				"arc_father_medication_seen"):
		_fail("Father's random health call can repeat known medication news")
	print(
		"HIDDEN_FEATURE_EVIDENCE father_medication "
		+ "raw_follow_up=blocked source_week=blocked m22_jiyeon=eligible "
		+ "m22_daeun=priority repeated_health_news=blocked")
	story.free()

func _check_jiyeon_third_path() -> void:
	LocaleManager.language = "ko"
	DataRegistry.reload()
	var ending_ids: Array[String] = []
	for choice_index in range(3):
		var ending_id := _jiyeon_ending_after_choice(choice_index, choice_index == 2)
		ending_ids.append(ending_id)
		match choice_index:
			0:
				if not GameState.flags.get("jiyeon_kept_by_diminishing", false) \
						or not GameState.flags.get("crossed_line", false) \
						or GameState.flags.get("jiyeon_left", false):
					_fail("Jiyeon diminishing route did not preserve its terminal state")
			1:
				if not GameState.flags.get("jiyeon_left", false):
					_fail("Jiyeon release route did not set jiyeon_left")
			2:
				if not GameState.flags.get("jiyeon_stayed_as_selves", false) \
						or GameState.flags.get("jiyeon_left", false) \
						or not GameState.flags.get("presented_artifact_correct", false):
					_fail("Jiyeon artifact route did not preserve its terminal state")
	var expected_endings: Array[String] = ["jiyeon_man", "ordinary_life", "jiyeon_man"]
	if ending_ids != expected_endings:
		_fail("Jiyeon verdict routes were %s instead of %s" % [ending_ids, expected_endings])
	if not GameState.flags.get("jiyeon_stayed_as_selves", false):
		_fail("Jiyeon third path did not set jiyeon_stayed_as_selves")
	if GameState.flags.get("jiyeon_left", false):
		_fail("Jiyeon third path incorrectly set jiyeon_left")
	var game = MainGameScript.new()
	for language in ["ko", "en"]:
		LocaleManager.language = language
		DataRegistry.reload()
		var ending: Dictionary = EndingSystem.get_ending("jiyeon_man")
		var known: Dictionary = ending.get("description_if_known", {})
		var expected := str(known.get("jiyeon_stayed_as_selves", ""))
		var actual := game._resolved_ending_description(ending)
		if expected.is_empty() or actual != expected:
			_fail("Jiyeon stayed-as-selves DIK did not resolve in %s" % language)
	print("HIDDEN_FEATURE_EVIDENCE jiyeon endings=%s dik=jiyeon_stayed_as_selves KO_EN=1" % [ending_ids])
	game.free()

func _jiyeon_ending_after_choice(choice_index: int, with_artifact: bool) -> String:
	_reset_run()
	GameState.age = 38
	GameState.flags["jiyeon_romance_started"] = true
	if with_artifact:
		GameState.add_item("artifact_jiyeon_text", 1)
	var event: Dictionary = DataRegistry.find_event("arc_jiyeon_verdict_decision")
	GameState.apply_choice(event, event.get("choices", [])[choice_index])
	return _capture_game_over()

func _check_daeun_post_it_route() -> void:
	LocaleManager.language = "ko"
	DataRegistry.reload()
	var refusal_ending := _daeun_ending_after_choice(0, false)
	var betrayal_ending := _daeun_ending_after_choice(1, false)
	if betrayal_ending != "ordinary_life" \
			or not GameState.flags.get("daeun_divorced", false) \
			or not GameState.flags.get("crossed_line", false):
		_fail("Daeun betrayal route did not reach the sub-target divorce ending")
	var post_it_ending := _daeun_ending_after_choice(2, true)
	var ending_ids: Array[String] = [refusal_ending, betrayal_ending, post_it_ending]
	var expected_endings: Array[String] = ["with_daeun", "ordinary_life", "with_daeun"]
	if ending_ids != expected_endings:
		_fail("Daeun final routes were %s instead of %s" % [ending_ids, expected_endings])
	if GameState.flags.get("daeun_divorced", false) or GameState.flags.get("crossed_line", false):
		_fail("Daeun post-it route incorrectly marked divorce or crossed_line")
	if not GameState.flags.get("presented_artifact_correct", false):
		_fail("Daeun post-it route did not record artifact presentation")
	print("HIDDEN_FEATURE_EVIDENCE daeun endings=%s post_it_divorced=0" % [ending_ids])

func _daeun_ending_after_choice(choice_index: int, with_artifact: bool) -> String:
	_reset_run()
	GameState.age = 38
	GameState.flags["daeun_romance_started"] = true
	GameState.flags["daeun_married"] = true
	if with_artifact:
		GameState.add_item("artifact_daeun_note", 1)
	var event: Dictionary = DataRegistry.find_event("arc_daeun_final_choice_decision")
	GameState.apply_choice(event, event.get("choices", [])[choice_index])
	return _capture_game_over()

func _check_dawn_people() -> void:
	LocaleManager.language = "ko"
	DataRegistry.reload()
	_reset_run()
	var game = MainGameScript.new()
	game._qa_real_dawn_hour_override = 2
	if not game._is_real_dawn():
		_fail("dawn override hour 2 was not recognized")
	game._qa_real_dawn_hour_override = 12
	if game._is_real_dawn():
		_fail("dawn override hour 12 was recognized as dawn")
	game._qa_real_dawn_hour_override = 2
	var first_lines: Array[String] = []
	for _i in range(4):
		var line := game._contact_flavor("daeun", 20)
		if line.is_empty() or first_lines.has(line):
			_fail("Daeun dawn line cycle repeated or returned empty before meeting five")
		first_lines.append(line)
	if MetaProgression.is_achievement_unlocked("dawn_people"):
		_fail("dawn_people unlocked before meeting five")
	var deep_line := game._contact_flavor("daeun", 20)
	if deep_line.is_empty() or first_lines.has(deep_line):
		_fail("Daeun fifth dawn line was not the unique deepest line")
	if int(GameState.flags.get("daeun_dawn_meetings", 0)) != 5 \
			or not GameState.flags.get("daeun_dawn_deep_seen", false) \
			or not MetaProgression.is_achievement_unlocked("dawn_people"):
		_fail("Daeun fifth dawn meeting did not set terminal state and achievement")
	print("HIDDEN_FEATURE_EVIDENCE dawn lines=4 deepest=5 achievement=dawn_people")
	game.free()

func _check_drawer_truth_cut() -> void:
	LocaleManager.language = "en"
	DataRegistry.reload()
	_reset_run()
	GameState.flags["arc_jiyeon_wedding_gap_seen"] = true
	var game = MainGameScene.instantiate()
	game.set_meta("_screenshot_qa_static_surface", true)
	add_child(game)
	await get_tree().process_frame
	if not game._should_show_drawer_truth():
		_fail("drawer truth positive predicate did not open")
	GameState.flags["jiyeon_left"] = true
	if game._should_show_drawer_truth():
		_fail("drawer truth ignored jiyeon_left")
	GameState.flags.erase("jiyeon_left")
	GameState.flags["told_jiyeon_about_records"] = true
	if game._should_show_drawer_truth():
		_fail("drawer truth ignored told_jiyeon_about_records")
	GameState.flags.erase("told_jiyeon_about_records")

	_drawer_callback_count = 0
	game._after_ending_exit(_on_drawer_cut_complete)
	var found_black_cut := false
	for child in game.get_children():
		if child is CanvasLayer and int(child.layer) == 99:
			found_black_cut = true
			break
	if not found_black_cut:
		_fail("drawer truth did not create its black cut layer")
	if game._drawer_truth_tween == null:
		_fail("drawer truth did not retain its cut tween")
	else:
		game._drawer_truth_tween.custom_step(12.0)
	await get_tree().process_frame
	if _drawer_callback_count != 1:
		_fail("drawer truth completion callback count was %d" % _drawer_callback_count)
	var achievement_unlocked := MetaProgression.is_achievement_unlocked("drawer_truth")
	if not achievement_unlocked:
		_fail("drawer truth cut completed without achievement")
	if game._should_show_drawer_truth():
		_fail("drawer truth could replay in the same ending surface")
	print("HIDDEN_FEATURE_EVIDENCE drawer black_cut=%d callback=%d achievement=%s" % [
		int(found_black_cut), _drawer_callback_count,
		"drawer_truth" if achievement_unlocked else "missing"])
	game.queue_free()
	await get_tree().process_frame

func _check_kept_artifact_ledger() -> void:
	_reset_run()
	for artifact_id in ARTIFACT_IDS:
		GameState.add_item(artifact_id, 1)
	var game = MainGameScript.new()
	for language in ["ko", "en"]:
		LocaleManager.language = language
		DataRegistry.reload()
		var names: PackedStringArray = game._kept_artifact_names()
		if names.size() != ARTIFACT_IDS.size():
			_fail("%s kept artifact list expected 6, got %d" % [language, names.size()])
		var card: PanelContainer = game._build_time_ledger_card("QA", "S", false)
		var surface_text := "\n".join(_collect_control_text(card))
		var header := "간직한 것들" if language == "ko" else "WHAT HE KEPT"
		if not surface_text.contains(header):
			_fail("%s ending ledger omitted %s" % [language, header])
		for artifact_name in names:
			if not surface_text.contains(artifact_name):
				_fail("%s ending ledger omitted artifact %s" % [language, artifact_name])
		card.free()
	print("HIDDEN_FEATURE_EVIDENCE keepsakes KO_EN=6 header=WHAT_HE_KEPT")
	game.free()

func _capture_game_over() -> String:
	_captured_ending = ""
	var callback := Callable(self, "_on_game_over")
	if GameState.game_over.is_connected(callback):
		GameState.game_over.disconnect(callback)
	GameState.game_over.connect(callback, CONNECT_ONE_SHOT)
	GameState.check_game_over()
	if GameState.game_over.is_connected(callback):
		GameState.game_over.disconnect(callback)
	return _captured_ending

func _on_game_over(ending_id: String) -> void:
	_captured_ending = ending_id

func _on_drawer_cut_complete() -> void:
	_drawer_callback_count += 1

func _collect_control_text(node: Node) -> PackedStringArray:
	var values := PackedStringArray()
	if node is Label or node is Button:
		values.append(str(node.text))
	elif node is RichTextLabel:
		values.append(str(node.text))
	for child in node.get_children():
		values.append_array(_collect_control_text(child))
	return values

func _assert_int_array(label: String, actual: Array[int], expected: Array[int]) -> void:
	if actual != expected:
		_fail("%s expected=%s actual=%s" % [label, expected, actual])

func _reset_run() -> void:
	GameState.start_new_game()
	MetaProgression.data = DataRegistry.default_meta.duplicate(true)
	MetaProgression._new_this_run = {"achievements": []}

func _restore_meta_file() -> void:
	if _had_meta_file:
		var file := FileAccess.open(MetaProgression.META_SAVE_PATH, FileAccess.WRITE)
		if file == null:
			_fail("could not restore the pre-check meta file")
			return
		file.store_string(_original_meta_text)
		file.close()
		var restored = JSON.parse_string(_original_meta_text)
		if restored is Dictionary:
			MetaProgression.data = restored
		return
	var absolute_path := ProjectSettings.globalize_path(MetaProgression.META_SAVE_PATH)
	if FileAccess.file_exists(MetaProgression.META_SAVE_PATH):
		DirAccess.remove_absolute(absolute_path)
	MetaProgression.data = DataRegistry.default_meta.duplicate(true)

func _fail(message: String) -> void:
	_failures.append(message)
