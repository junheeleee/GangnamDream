extends Node
## L2 only: real StoryMode nameplates, not independent human replay evidence.
## Launch with a SceneTree bootstrap that selects a NEW user:// namespace in
## _init(), before autoloads read settings/meta. Never borrow a player save.

const ROUTE := preload("res://systems/Chapter5CausalRoute.gd")
const TARGETS := ["arc_y5_burnout_check_reference", "arc_y5_after_goal_daeun"]
const NORMAL_CONTROL := "hyunsu_reunion_meet"
const REMOTE_CONTROL := "hyunsu_reunion_later"
const QA_PREFIX := "GangnamDream_StoryNameplateQA_"
const OBSERVED_PRIOR_CHOICES := [2, 1, 0, 1, 0, 1]

var _story: Control
var _failures := 0
var _cases := 0
var _pages := 0
var _refreshes := 0
var _locale_roundtrips := 0
var _controls := 0
var _quote_pages := 0
var _context := "bootstrap"
var _expected_id := ""
var _root_failures: Dictionary = {}
var _exercise_refresh := false

func _ready() -> void:
	Engine.max_fps = 60
	var bootstrap_script := get_tree().get_script() as Script
	if bootstrap_script == null \
			or bootstrap_script.resource_path != "res://tools/StoryNameplateBootstrap.gd":
		push_error("STORY_NAMEPLATE_CHECK_FAIL: exact pre-autoload bootstrap required; actual=%s" % [
			bootstrap_script.resource_path if bootstrap_script != null else "none"])
		get_tree().quit(1)
		return
	var qa_namespace := str(ProjectSettings.get_setting(
		"application/config/custom_user_dir_name", ""))
	if not bool(ProjectSettings.get_setting("application/config/use_custom_user_dir", false)) \
			or not qa_namespace.begins_with(QA_PREFIX) \
			or not OS.get_user_data_dir().ends_with(qa_namespace):
		push_error("STORY_NAMEPLATE_CHECK_FAIL: require pre-autoload isolated SceneTree bootstrap; prefix=%s actual=%s" % [QA_PREFIX, OS.get_user_data_dir()])
		get_tree().quit(1)
		return
	print("STORY_NAMEPLATE_QA_USER_DIR=%s" % OS.get_user_data_dir())
	print("STORY_NAMEPLATE_QA_SOURCE=%s rule_sha256=%s" % [
		ProjectSettings.globalize_path("res://"),
		FileAccess.get_sha256("res://content/meta/story_rules.json")])
	await get_tree().process_frame
	# Deferred autoload settings have now read only the bootstrap's empty dir.
	SaveManager.set_setting("story_text_size", "standard")
	for language in ["ko", "en"]:
		LocaleManager.set_language(language)
		for event_id in TARGETS:
			for choice_index in range(3):
				await _play_target(str(event_id), choice_index)
	await _remove_story()
	await _stop_audio()
	for event_id in TARGETS:
		print("STORY_NAMEPLATE_ROOT_RESULT root=%s failures=%d observation=%s" % [
			event_id, int(_root_failures.get(event_id, 0)),
			"hidden-contract-held-Codex-UI-observation-unresolved" \
				if event_id == TARGETS[0] and int(_root_failures.get(event_id, 0)) == 0 \
				else "targeted-L2-only"])
	if _cases != 12 or _pages < 60 or _locale_roundtrips != 24 or _controls != 20 \
			or _quote_pages != 12:
		_fail("fixture inventory incomplete: cases=%d pages=%d locale_roundtrips=%d controls=%d quote_pages=%d" % [
			_cases, _pages, _locale_roundtrips, _controls, _quote_pages])
	if _failures > 0:
		print("STORY_NAMEPLATE_CHECK_FAIL failures=%d cases=%d pages=%d refreshes=%d locale_roundtrips=%d controls=%d" % [
			_failures, _cases, _pages, _refreshes, _locale_roundtrips, _controls])
		get_tree().quit(1)
		return
	print("STORY_NAMEPLATE_CHECK_OK cases=%d pages=%d refreshes=%d locale_roundtrips=%d controls=%d quote_pages=%d ko_en=1 no_refresh_cases=4 sequential_pages=1 live_choices=1 loader_controls=1 human_gate=OPEN" % [
		_cases, _pages, _refreshes, _locale_roundtrips, _controls, _quote_pages])
	get_tree().quit(0)

func _play_target(event_id: String, choice_index: int) -> void:
	await _remove_story()
	_context = "%s/%s/choice%d" % [LocaleManager.language, event_id, choice_index]
	_expected_id = event_id
	_exercise_refresh = choice_index != 0
	if not _seed_target(event_id):
		return
	# Choice zero is cold. The other two enter the same real StoryMode node
	# after an ordinary or remote named control. The control's choice is NOT
	# committed: this explicitly probes the loader's state reset, not a claimed
	# authored edge or a normal-speed complete route.
	var preceding := "" if choice_index == 0 else (
		NORMAL_CONTROL if choice_index == 1 else REMOTE_CONTROL)
	var following := NORMAL_CONTROL if choice_index != 1 else REMOTE_CONTROL
	GameState.pending_story_queue = [event_id, following] if preceding.is_empty() \
		else [preceding, event_id, following]
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	await _settle()
	_story.call("_set_auto_mode", false, false, false)
	if not preceding.is_empty():
		_check_control(preceding, "previous-control")
		_story.call("_load_next_event")
		await _settle()
	if not _expect_live_root(event_id):
		return
	_observe_hidden("opening-settled")
	if not await _read_pages(false):
		return
	# This uses the actual in-scene language refresh path, not just the helper.
	if _exercise_refresh:
		await _language_roundtrip("intro-language")
	await _advance_to_choices()
	if not bool(_story.get("_showing_choices")):
		_fail("sequential introduction did not reach choices")
		return
	_observe_hidden("choices")
	if _exercise_refresh:
		await _language_roundtrip("choices-language")
	var choices: Array = (_story.get("_current") as Dictionary).get("choices", [])
	var visible: Array = _story.call("_visible_choice_indices", _story.get("_current"))
	if choices.size() != 3 or not visible.has(choice_index):
		_fail("target choice inventory is not the three authored choices")
		return
	_story.call("_on_choice", choice_index)
	await get_tree().process_frame
	if not bool(_story.get("_pending_after_result")) \
			or int(_story.get("_pending_result_choice_index")) != choice_index \
			or ROUTE.selected_choice(GameState.chapter5_causal_state, event_id) != choice_index:
		_fail("actual choice transaction did not produce its exact result/receipt")
		return
	if not await _read_pages(true):
		return
	if _exercise_refresh:
		await _language_roundtrip("result-language")
	# The final result's ordinary next action now traverses the queued control.
	_story.call("_on_advance")
	await _settle()
	_check_control(following, "following-control")
	_cases += 1

func _seed_target(event_id: String) -> bool:
	GameState.start_new_game()
	GameState.age = 37
	GameState.month = 3
	GameState.housing = "gosiwon"
	GameState.money = 2_800_000_000.0
	GameState.health = 80
	GameState.mental = 80
	GameState.flags = {"prologue_done": true}
	GameState.story_replay_mode = false
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	EventManager.current_event = {}
	var locked: Dictionary = ROUTE.lock_entry(
		ROUTE.default_state(), 195, "투자형", true, true, 2_800_000_000.0)
	if not bool(locked.get("ok", false)):
		_fail("synthetic prerequisite fixture could not lock existing reducer")
		return false
	var state: Dictionary = locked["state"]
	var target_index: int = ROUTE.OWNED_EVENT_IDS.find(event_id)
	for index in range(target_index):
		var committed: Dictionary = ROUTE.commit_choice(state,
			ROUTE.OWNED_EVENT_IDS[index], OBSERVED_PRIOR_CHOICES[index],
			ROUTE.OWNED_TURNS[index])
		if not bool(committed.get("ok", false)):
			_fail("synthetic predecessor transaction failed at %s" % ROUTE.OWNED_EVENT_IDS[index])
			return false
		state = committed["state"]
	GameState.chapter5_causal_state = state
	GameState.turn = ROUTE.OWNED_TURNS[target_index]
	if GameState.chapter5_causal_next_event_for_turn() != event_id:
		_fail("typed reducer did not admit exact target week/root")
		return false
	return true

func _read_pages(result: bool) -> bool:
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	if pages.is_empty() or int(_story.get("_para_index")) != 0:
		_fail("phase did not start at decoded page zero")
		return false
	for page_index in range(pages.size()):
		if int(_story.get("_para_index")) != page_index \
				or bool(_story.get("_pending_after_result")) != result:
			_fail("normal advance skipped page %d or crossed phase" % page_index)
			return false
		await _finish_page()
		var body := _story.get("_body_lbl") as RichTextLabel
		if body.text != str(pages[page_index]) or body.text.is_empty():
			_fail("decoded page %d was not the displayed body" % page_index)
			return false
		_observe_hidden("result-page" if result else "intro-page")
		if not result and body.text == _target_quote():
			_quote_pages += 1
			print("STORY_NAMEPLATE_TARGET_QUOTE %s" % JSON.stringify(_diagnostic()))
		if _exercise_refresh:
			_story.call("_refresh_story_speaker_language")
			_refreshes += 1
			_observe_hidden("speaker-refresh")
		_pages += 1
		if page_index + 1 < pages.size():
			_story.call("_on_advance")
			await get_tree().process_frame
	return true

func _target_quote() -> String:
	if _expected_id == TARGETS[1]:
		return "“30억 다음에도 우리가 같이 지킬 하루가 뭐예요?”" if LocaleManager.language == "ko" \
			else "“After three billion won, what kind of day should we still protect together?”"
	return "“한 번 본 걸로 이름부터 붙이지 않겠습니다. 대신 빼지 말아야 할 정보를 고르세요. 잠, 떨림, 일한 시간 중 무엇을 먼저 보여 주실 겁니까.”" \
		if LocaleManager.language == "ko" \
		else "“I won't name this from one screen. Choose the information we must not leave out: sleep, tremors, or the hours you worked.”"

func _finish_page() -> void:
	if bool(_story.get("_direction_beat_waiting")):
		_story.call("_on_advance")
	_story.call("_complete_typing")
	# Real timing/transition consumers run in the tree; never force _para_index,
	# _current_presentation, name visibility, or cached choice visibility.
	for _frame in range(150):
		if not bool(_story.get("_direction_hold_active")) \
				and not bool(_story.get("_story_scene_transition_active")):
			break
		await get_tree().process_frame
	await get_tree().process_frame

func _advance_to_choices() -> void:
	await _finish_page()
	_story.call("_on_advance")
	await get_tree().process_frame

func _language_roundtrip(label: String) -> void:
	var original := LocaleManager.language
	var alternate := "en" if original == "ko" else "ko"
	var was_result := bool(_story.get("_pending_after_result"))
	var was_choices := bool(_story.get("_showing_choices"))
	var old_receipts: Dictionary = GameState.chapter5_causal_state.duplicate(true)
	for language in [alternate, original]:
		_story.call("_set_story_language", language)
		await get_tree().process_frame
		if LocaleManager.language != language \
				or bool(_story.get("_pending_after_result")) != was_result \
				or bool(_story.get("_showing_choices")) != was_choices \
				or GameState.chapter5_causal_state != old_receipts:
			_fail("%s changed phase/receipt or failed to select language" % label)
		_observe_hidden(label)
	_locale_roundtrips += 1

func _expect_live_root(event_id: String) -> bool:
	var current: Dictionary = _story.get("_current")
	if str(current.get("id", "")) != event_id \
			or bool(_story.get("_read_only_replay")):
		_fail("actual loaded StoryMode is not the intended live root")
		return false
	return true

func _observe_hidden(label: String) -> void:
	var panel := _story.get("_name_panel") as Control
	var presentation: Dictionary = _story.get("_current_presentation")
	var loaded: Dictionary = DataRegistry.get_story_presentation(_expected_id)
	var portrait := _story.get("_portrait") as TextureRect
	var frame := _story.get("_portrait_frame") as Control
	var portrait_id := "player_tired" if _expected_id == TARGETS[0] else "daeun_normal"
	if not _expect_live_root(_expected_id):
		return
	if presentation != loaded or str(presentation.get("nameplate_role", "auto")) != "hidden" \
			or not bool(_story.call("_story_nameplate_hidden")) \
			or not is_instance_valid(panel) or panel.visible or panel.is_visible_in_tree():
		_fail("%s: narrated/mixed speaker page exposed portrait name or lost loaded hidden contract" % label)
	if not is_instance_valid(portrait) or portrait.texture == null \
			or portrait.texture.resource_path != ImageRegistry.get_portrait(portrait_id) \
			or not is_instance_valid(frame) or not frame.visible \
			or bool(_story.get("_portrait_remote_inset")):
		_fail("%s: hiding the nameplate removed or replaced the authored local portrait" % label)

func _check_control(event_id: String, label: String) -> void:
	var current: Dictionary = _story.get("_current")
	var panel := _story.get("_name_panel") as Control
	var name_label := _story.get("_name_tag") as Label
	if not is_instance_valid(panel) or not is_instance_valid(name_label):
		_fail("%s: control nameplate nodes are missing" % label)
		return
	var presentation: Dictionary = _story.get("_current_presentation")
	var remote := event_id == REMOTE_CONTROL
	var expected_name := str(ImageRegistry.get_person_info("hyunsu_accounting").get("name", ""))
	var suffix := "메시지" if LocaleManager.language == "ko" else "Message"
	var expected := "%s  ·  %s" % [expected_name, suffix] if remote else expected_name
	if str(current.get("id", "")) != event_id or not is_instance_valid(panel) \
			or not panel.visible or not panel.is_visible_in_tree() \
			or not is_instance_valid(name_label) or name_label.text != expected \
			or bool(_story.call("_story_nameplate_hidden")) \
			or bool(_story.get("_portrait_remote_inset")) != remote \
			or str(presentation.get("channel", "")) != ("message" if remote else "in_person"):
		_fail("%s: ordinary/remote control did not restore its own truthful nameplate" % label)
	_story.call("_refresh_story_speaker_language")
	if panel.visible != true or not panel.is_visible_in_tree() or name_label.text != expected:
		_fail("%s: ordinary/remote control failed speaker refresh" % label)
	_controls += 1

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	_story.call("_set_auto_mode", false, false, false)
	await _finish_page()

func _diagnostic() -> Dictionary:
	var data := {"context": _context, "expected_root": _expected_id,
		"language": LocaleManager.language, "turn": GameState.turn,
		"exercise_refresh": _exercise_refresh,
		"loaded_presentation": DataRegistry.get_story_presentation(_expected_id)}
	if not is_instance_valid(_story):
		return data
	var panel := _story.get("_name_panel") as Control
	var name_label := _story.get("_name_tag") as Label
	var body := _story.get("_body_lbl") as RichTextLabel
	data.merge({"root": (_story.get("_current") as Dictionary).get("id", ""),
		"story_script": _story.get_script().resource_path,
		"story_node": str(_story.get_path()), "instance_id": _story.get_instance_id(),
		"presentation": _story.get("_current_presentation"),
		"phase": _story.call("_story_resume_phase"),
		"page": _story.get("_para_index"),
		"source_paragraph": _story.call("_story_source_paragraph_index", _story.get("_para_index")),
		"name_panel_visible": panel.visible if is_instance_valid(panel) else null,
		"name_panel_visible_in_tree": panel.is_visible_in_tree() if is_instance_valid(panel) else null,
		"name_panel_path": str(panel.get_path()) if is_instance_valid(panel) else "",
		"name_text": name_label.text if is_instance_valid(name_label) else "",
		"cached_visible_before_choices": _story.get("_name_panel_visible_before_choices"),
		"transition": _story.get("_story_scene_transition_active"),
		"body": body.text if is_instance_valid(body) else ""})
	return data

func _fail(message: String) -> void:
	_failures += 1
	_root_failures[_expected_id] = int(_root_failures.get(_expected_id, 0)) + 1
	# Keep a complete machine-readable receipt even when engine error messages
	# are rate-limited. Accumulate presentation failures to distinguish a held
	# burnout contract from the independently failing Daeun presentation.
	print("STORY_NAMEPLATE_CHECK_FAIL %s %s" % [message, JSON.stringify(_diagnostic())])

func _remove_story() -> void:
	if is_instance_valid(_story):
		_story.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame
	_story = null
	GameState.pending_story_queue.clear()
	EventManager.current_event = {}

func _stop_audio() -> void:
	await AudioManager.drain_pending_timers_for_exit()
	BGMPlayer.stop()
	for owner in [AudioManager, BGMPlayer]:
		for child in owner.get_children():
			if child is AudioStreamPlayer:
				(child as AudioStreamPlayer).stop()
				(child as AudioStreamPlayer).stream = null
	for _frame in range(4):
		await get_tree().process_frame
