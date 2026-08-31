extends Node
## Fresh-title, product-flow W1 -> W240 occurrence recorder.
##
## This tool instantiates the real StartMenu, confirms the first-run content
## notice through a visible Button, traverses OpeningCinematic, then drives only
## visible and enabled StoryMode/MainGame controls with physical keyboard input.
## It never loads a save, jumps a week, sets money/flags, calls a hidden AP
## action function, or turns on a demo/playtest build flavor.
##
## JSONL is append-only runtime evidence. A successful structural trace keeps
## product_go=HOLD and human_density_gate=OPEN.

const TRACE_SCHEMA_VERSION := 1
const START_MENU_SCENE := "res://scenes/StartMenu.tscn"
const START_MENU_SCRIPT := "res://scenes/StartMenu.gd"
const OPENING_SCRIPT := "res://scenes/OpeningCinematic.gd"
const STORY_SCRIPT := "res://scenes/StoryMode.gd"
const MAIN_SCRIPT := "res://scenes/MainGame.gd"
const DEFAULT_PROFILES_PATH := "res://tools/full_game_runtime_trace_profiles.json"
const FORBIDDEN_USER_ARGS: Array[String] = [
	"--demo-build",
	"--core-loop-v2",
	"--core-loop-v2-playtest-build",
]
const VALID_PROVENANCE: Array[String] = [
	"main_ingress", "queued", "follow_up", "same_turn", "deferred",
]
const MAX_DRIVER_STEPS := 160000
const MAX_STAGNANT_STEPS := 2400

var _profile_id := ""
var _profiles_path := DEFAULT_PROFILES_PATH
var _trace_output_path := ""
var _candidate_commit := ""
var _candidate_tree := ""
var _candidate_dirty := true
var _expected_profile_hash := ""
var _profile_hash := ""
var _profile: Dictionary = {}
var _trace_file: FileAccess = null
var _sequence := 0
var _errors: Array[String] = []
var _fatal := false
var _run_start_recorded := false
var _run_started_observed := false
var _new_story_selected := false
var _content_notice_confirmed := false
var _opening_seen := false
var _ending_id := ""
var _ending_open_recorded := false
var _ending_pages_seen: Array[int] = []
var _ending_page_occurrences: Dictionary = {}

var _story_occurrence_counter := 0
var _story_signature := ""
var _story_occurrence_id := ""
var _story_occurrences: Array[Dictionary] = []
var _story_offer_recorded: Dictionary = {}
var _story_choice_recorded: Dictionary = {}
var _story_result_recorded: Dictionary = {}
var _story_choice_by_occurrence: Dictionary = {}
var _previous_story_event_id := ""
var _previous_story_occurrence_id := ""
var _previous_story_instance_id := 0
var _previous_story_turn := 0
var _previous_selected_follow_up := ""
var _last_main_deferred_ids: Array[String] = []

var _week_opened: Dictionary = {}
var _week_closed: Dictionary = {}
var _week_open_state: Dictionary = {}
var _last_open_week := 0
var _main_offer_signatures: Dictionary = {}
var _main_offer_counter := 0
var _main_commit_counter := 0
var _pending_main_action: Dictionary = {}
var _pending_main_action_state: Dictionary = {}


func _ready() -> void:
	_parse_args()
	if not _prepare_contract():
		_finish_run(false)
		return
	AudioServer.set_bus_mute(0, true)
	if GameState.run_started.is_connected(_on_run_started):
		GameState.run_started.disconnect(_on_run_started)
	GameState.run_started.connect(_on_run_started)
	if GameState.weekly_commitment_finalized.is_connected(
			_on_weekly_commitment_finalized):
		GameState.weekly_commitment_finalized.disconnect(
			_on_weekly_commitment_finalized)
	GameState.weekly_commitment_finalized.connect(
		_on_weekly_commitment_finalized)
	if GameState.game_over.is_connected(_on_game_over):
		GameState.game_over.disconnect(_on_game_over)
	GameState.game_over.connect(_on_game_over)
	seed(int(_profile.get("seed", 1)))
	_set_language(str(_profile.get("locale", "ko")))
	if not await _boot_fresh_title():
		_finish_run(false)
		return
	seed(int(_profile.get("seed", 1)))
	_record_run_start()
	await _drive_product_run()


func _parse_args() -> void:
	for raw_arg in OS.get_cmdline_user_args():
		var arg := str(raw_arg).strip_edges()
		if arg.begins_with("--profile="):
			_profile_id = arg.substr(10)
		elif arg.begins_with("--profiles="):
			_profiles_path = arg.substr(11)
		elif arg.begins_with("--trace-output="):
			_trace_output_path = arg.substr(15)
		elif arg.begins_with("--candidate-commit="):
			_candidate_commit = arg.substr(19)
		elif arg.begins_with("--candidate-tree="):
			_candidate_tree = arg.substr(17)
		elif arg.begins_with("--candidate-dirty="):
			_candidate_dirty = arg.substr(18).to_lower() != "false"
		elif arg.begins_with("--profile-hash="):
			_expected_profile_hash = arg.substr(15)


func _prepare_contract() -> bool:
	if _profile_id.is_empty() or _trace_output_path.is_empty() \
			or _candidate_commit.length() != 40 \
			or _candidate_tree.length() != 40 \
			or _candidate_dirty \
			or _expected_profile_hash.length() != 64:
		_errors.append("runtime trace identity arguments are incomplete or dirty")
		return false
	for raw_arg in OS.get_cmdline_user_args():
		if str(raw_arg) in FORBIDDEN_USER_ARGS:
			_errors.append("forbidden build/state argument: %s" % str(raw_arg))
			return false
	if not FileAccess.file_exists(_profiles_path):
		_errors.append("profile file is missing: %s" % _profiles_path)
		return false
	var profile_bytes := FileAccess.get_file_as_bytes(_profiles_path)
	var hash_bytes := profile_bytes.duplicate()
	hash_bytes.append(0)
	hash_bytes.append_array(_profile_id.to_utf8_buffer())
	_profile_hash = _sha256_bytes(hash_bytes)
	if _profile_hash != _expected_profile_hash:
		_errors.append("profile hash mismatch")
		return false
	var parsed: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(_profiles_path))
	if not parsed is Dictionary:
		_errors.append("profile document is not an object")
		return false
	var rows: Variant = (parsed as Dictionary).get("profiles", [])
	if not rows is Array:
		_errors.append("profile document has no profile array")
		return false
	for raw_profile in rows as Array:
		if raw_profile is Dictionary \
				and str((raw_profile as Dictionary).get("id", "")) == _profile_id:
			_profile = (raw_profile as Dictionary).duplicate(true)
			break
	if _profile.is_empty():
		_errors.append("unknown trace profile: %s" % _profile_id)
		return false
	if str(_profile.get("locale", "")) != "ko" \
			or str(_profile.get("input_mode", "")) != "keyboard":
		_errors.append("R1 trace profile must use Korean keyboard input")
		return false
	if not _trace_output_path.is_absolute_path():
		_errors.append("trace output must be an absolute path")
		return false
	if FileAccess.file_exists(_trace_output_path):
		_errors.append("trace output already exists")
		return false
	_trace_file = FileAccess.open(_trace_output_path, FileAccess.WRITE)
	if _trace_file == null:
		_errors.append("could not open trace output")
		return false
	return true


func _set_language(locale: String) -> void:
	if SaveManager.has_method("set_setting"):
		SaveManager.set_setting("language", locale)
	if LocaleManager.has_method("set_language"):
		LocaleManager.set_language(locale)
	else:
		LocaleManager.language = locale
	DataRegistry.reload()


func _boot_fresh_title() -> bool:
	# A prior warning receipt means HOME/XDG isolation leaked. Do not erase it;
	# fail instead of manufacturing a fresh title.
	if bool(MetaProgression.data.get("content_warning_seen", false)):
		_fail("isolated fresh title already contains content_warning_seen")
		return false
	var packed := load(START_MENU_SCENE) as PackedScene
	if packed == null:
		_fail("could not load StartMenu.tscn")
		return false
	var menu := packed.instantiate()
	get_tree().root.add_child.call_deferred(menu)
	await get_tree().process_frame
	get_tree().current_scene = menu
	await get_tree().create_timer(0.30).timeout
	await _send_key(KEY_ENTER)
	await get_tree().create_timer(0.38).timeout
	if not is_instance_valid(menu):
		_fail("title splash and New Story were consumed by one input")
		return false
	var new_story := _find_visible_meta_value_button(
		menu, "build_entry_kind", "legacy")
	if new_story == null:
		_fail("actual StartMenu has no visible legacy New Story button")
		return false
	_new_story_selected = true
	await _activate_button(new_story)

	var notice_confirm: Button = null
	for _frame in range(240):
		await get_tree().process_frame
		if not is_instance_valid(menu):
			break
		notice_confirm = _find_button_with_any_text(
			menu, ["이해했습니다 ›", "Understood ›"])
		if notice_confirm != null:
			break
	if notice_confirm == null:
		_fail("fresh title did not expose the first-run content notice")
		return false
	_content_notice_confirmed = true
	await _activate_button(notice_confirm)

	var opening_input_sent := false
	var last_path := ""
	for _frame in range(2400):
		await get_tree().create_timer(0.01).timeout
		var current := get_tree().current_scene
		if not is_instance_valid(current):
			continue
		var path := _scene_script_path(current)
		if path != last_path:
			last_path = path
			print("FULL_GAME_RUNTIME_TRACE_BOOT profile=%s scene=%s" % [
				_profile_id, path])
		if path == OPENING_SCRIPT:
			_opening_seen = true
			if not opening_input_sent and not bool(current.get("_transitioning")):
				await get_tree().create_timer(0.30).timeout
				await _send_key(KEY_ENTER)
				opening_input_sent = true
		elif path in [STORY_SCRIPT, MAIN_SCRIPT]:
			if not _opening_seen or not _run_started_observed:
				_fail("fresh title skipped OpeningCinematic or run_started")
				return false
			if int(GameState.turn) != 1 or GameState.is_game_over:
				_fail("fresh title did not enter a live Week-1 run")
				return false
			return true
	_fail("fresh title boot stalled at %s" % last_path)
	return false


func _record_run_start() -> void:
	if _run_start_recorded:
		return
	_run_start_recorded = true
	_record("run_start", "run:%s:start" % _profile_id, {
		"state_source": "fresh_title",
		"fresh_title": true,
		"new_story_selected": _new_story_selected,
		"content_notice_confirmed": _content_notice_confirmed,
		"opening_seen": _opening_seen,
		"run_started_signal": _run_started_observed,
		"save_loaded": false,
		"user_args": OS.get_cmdline_user_args().duplicate(),
		"initial_state": _state_snapshot(),
	}, START_MENU_SCRIPT, 1)


func _drive_product_run() -> void:
	var last_signature := ""
	var stagnant_steps := 0
	for _step in range(MAX_DRIVER_STEPS):
		if _fatal:
			_finish_run(false)
			return
		await get_tree().create_timer(0.008).timeout
		var scene := get_tree().current_scene
		if not is_instance_valid(scene):
			continue
		var script_path := _scene_script_path(scene)
		var signature := "%s:%d" % [script_path, int(GameState.turn)]
		if script_path == STORY_SCRIPT:
			signature += _story_signature_for(scene)
			await _drive_story(scene)
		elif script_path == MAIN_SCRIPT:
			signature += _main_signature_for(scene)
			if await _drive_main(scene):
				return
		elif script_path == OPENING_SCRIPT:
			_fail("OpeningCinematic reopened after run_start")
		else:
			# A real action mini-game can temporarily become current_scene. Drive its
			# visible focused button, never a hidden function.
			var focused := get_viewport().gui_get_focus_owner() as Button
			if _button_is_usable(focused) and scene.is_ancestor_of(focused):
				await _activate_button(focused)

		if signature == last_signature:
			stagnant_steps += 1
		else:
			last_signature = signature
			stagnant_steps = 0
		if stagnant_steps > MAX_STAGNANT_STEPS:
			_fail("runtime driver stalled at %s" % signature)
			_finish_run(false)
			return
	_fail("runtime driver exceeded its safety step limit")
	_finish_run(false)


func _drive_story(story: Node) -> void:
	var current_raw: Variant = story.get("_current")
	if not current_raw is Dictionary:
		return
	var current: Dictionary = current_raw
	var event_id := str(current.get("id", ""))
	var event_serial := int(story.get("_dialogue_log_event_serial"))
	if event_id.is_empty() or event_serial <= 0:
		return
	var scene_instance_id := int(story.get_instance_id())
	var signature := "%d:%d:%s" % [scene_instance_id, event_serial, event_id]
	if signature != _story_signature:
		_story_signature = signature
		_begin_story_occurrence(story, current, event_id, event_serial)
	if bool(story.get("_transitioning")) \
			or bool(story.get("_story_scene_transition_active")) \
			or bool(story.get("_direction_hold_active")) \
			or bool(story.get("_direction_beat_waiting")):
		return
	var tutorial := story.get("_tutorial_popup") as Control
	if is_instance_valid(tutorial):
		var tutorial_button := _find_first_enabled_button(tutorial)
		if tutorial_button != null:
			await _activate_button(tutorial_button)
		return
	if bool(story.get("_showing_choices")):
		await _drive_story_choices(story, current)
		return
	if bool(story.get("_pending_after_result")):
		_record_story_result(story, current)
	var paragraphs_raw: Variant = story.get("_paragraphs")
	if not bool(story.get("_typing")) \
			and not bool(story.get("_pending_after_result")) \
			and paragraphs_raw is Array \
			and int(story.get("_para_index")) >= (paragraphs_raw as Array).size() - 1:
		var direct_choice_index := int(
			story.call("_direct_continue_choice_index"))
		if direct_choice_index >= 0:
			await _drive_story_direct_choice(
				story, current, direct_choice_index)
			return
	await _send_key(KEY_ENTER)


func _begin_story_occurrence(
		story: Node, current: Dictionary, event_id: String,
		event_serial: int) -> void:
	_story_occurrence_counter += 1
	_story_occurrence_id = "story:%s:%06d" % [
		_profile_id, _story_occurrence_counter]
	var scene_instance_id := int(story.get_instance_id())
	var provenance := "main_ingress"
	var parent_occurrence_id := ""
	var arrival_source := "pending_story_queue"
	if _previous_story_instance_id == scene_instance_id \
			and not _previous_story_occurrence_id.is_empty():
		parent_occurrence_id = _previous_story_occurrence_id
		if event_id == _previous_selected_follow_up \
				or event_id == str(DataRegistry.find_event(
					_previous_story_event_id).get("follow_up_event", "")):
			provenance = "follow_up"
			arrival_source = "choice_or_event_follow_up"
		elif _previous_story_turn == int(GameState.turn) \
				and _chapter5_same_turn_pair(_previous_story_event_id, event_id):
			provenance = "same_turn"
			arrival_source = "chapter5_reducer"
		else:
			provenance = "queued"
			arrival_source = "storymode_queue"
	elif event_id in _last_main_deferred_ids:
		provenance = "deferred"
		arrival_source = "deferred_queue"
	if provenance not in VALID_PROVENANCE:
		provenance = "main_ingress"
	var source_stats := _text_stats(_event_source_text(current))
	var runtime_stats := _text_stats(_runtime_story_pages(story))
	var volume_class := "control" if _story_is_control(story, current) else "narrative"
	var queue_snapshot: Array = []
	var raw_queue: Variant = story.get("_queue")
	if raw_queue is Array:
		queue_snapshot = (raw_queue as Array).duplicate(true)
	var payload := {
		"event_id": event_id,
		"event_serial": event_serial,
		"scene_instance_id": scene_instance_id,
		"provenance": provenance,
		"arrival_source": arrival_source,
		"parent_occurrence_id": parent_occurrence_id,
		"parent_event_id": _previous_story_event_id if not parent_occurrence_id.is_empty() else "",
		"entry_queue_after_pop": queue_snapshot,
		"source_paragraph_count": int(source_stats["paragraph_count"]),
		"source_char_count": int(source_stats["char_count"]),
		"source_sha256": str(source_stats["sha256"]),
		"runtime_page_count": int(runtime_stats["paragraph_count"]),
		"runtime_char_count": int(runtime_stats["char_count"]),
		"runtime_sha256": str(runtime_stats["sha256"]),
		"volume_class": volume_class,
		"narrative_volume_counted": volume_class == "narrative",
		"state_before": _state_snapshot(),
	}
	_record("story_enter", _story_occurrence_id, payload, STORY_SCRIPT)
	_story_occurrences.append({
		"event_id": event_id,
		"occurrence_id": _story_occurrence_id,
		"provenance": provenance,
	})
	_previous_story_event_id = event_id
	_previous_story_occurrence_id = _story_occurrence_id
	_previous_story_instance_id = scene_instance_id
	_previous_story_turn = int(GameState.turn)
	_previous_selected_follow_up = ""


func _drive_story_choices(story: Node, current: Dictionary) -> void:
	if _story_occurrence_id.is_empty():
		return
	var visible_buttons := _visible_choice_buttons(story)
	if visible_buttons.is_empty():
		_fail("StoryMode reports choices without visible enabled choice buttons")
		return
	if not _story_offer_recorded.has(_story_occurrence_id):
		var offer_rows: Array[Dictionary] = []
		for button in visible_buttons:
			offer_rows.append({
				"authored_index": int(button.get_meta("choice_index", -1)),
				"display_index": int(button.get_meta("choice_display_num", -1)),
				"text": str(button.text),
				"text_sha256": _sha256_text(str(button.text)),
			})
		_record("choice_offer", _story_occurrence_id, {
			"event_id": str(current.get("id", "")),
			"choices": offer_rows,
			"countdown_active": int(story.get("_choice_countdown_deadline_msec")) > 0,
		}, STORY_SCRIPT)
		_story_offer_recorded[_story_occurrence_id] = true
	if _story_choice_recorded.has(_story_occurrence_id):
		return
	var event_id := str(current.get("id", ""))
	var choice_contract: Dictionary = _profile.get(
		"choice_overrides", {}).get(
			event_id, _profile.get("default_choice", {}))
	var requested_index := int(choice_contract.get("index", 0))
	var selection_mode := str(choice_contract.get("selection_mode", "direct"))
	var selected_button: Button = null
	for button in visible_buttons:
		if int(button.get_meta("choice_index", -1)) == requested_index:
			selected_button = button
			break
	if selected_button == null:
		_fail("profile choice %d is not visible for %s" % [
			requested_index, event_id])
		return
	var choices: Array = current.get("choices", [])
	if requested_index < 0 or requested_index >= choices.size() \
			or not choices[requested_index] is Dictionary:
		_fail("profile choice index is outside authored choices for %s" % event_id)
		return
	var authored_choice: Dictionary = choices[requested_index]
	var before := _state_snapshot()
	# A real button press may free the entire StoryMode scene immediately. Keep
	# the displayed identity before input instead of dereferencing a dead node.
	var displayed_index := int(selected_button.get_meta(
		"choice_display_num", requested_index + 1))
	var displayed_text := str(selected_button.text)
	var countdown_active := int(story.get(
		"_choice_countdown_deadline_msec")) > 0
	_previous_selected_follow_up = str(
		authored_choice.get("follow_up_event", ""))
	await _activate_button(selected_button)
	await get_tree().process_frame
	var after := _state_snapshot()
	_record("story_choice", _story_occurrence_id, {
		"event_id": event_id,
		"authored_index": requested_index,
		"display_index": displayed_index,
		"selection_mode": selection_mode,
		"countdown_active": countdown_active,
		"choice_text": displayed_text,
		"choice_text_sha256": _sha256_text(displayed_text),
		"state_delta": _state_delta(before, after),
	}, STORY_SCRIPT)
	_story_choice_by_occurrence[_story_occurrence_id] = requested_index
	_story_choice_recorded[_story_occurrence_id] = true


func _drive_story_direct_choice(
		story: Node, current: Dictionary, direct_choice_index: int) -> void:
	if _story_occurrence_id.is_empty() \
			or _story_choice_recorded.has(_story_occurrence_id):
		return
	var choices: Array = current.get("choices", [])
	if direct_choice_index < 0 or direct_choice_index >= choices.size() \
			or not choices[direct_choice_index] is Dictionary:
		_fail("direct continue lost authored choice identity")
		return
	var choice_contract: Dictionary = _profile.get(
		"choice_overrides", {}).get(
		str(current.get("id", "")), _profile.get("default_choice", {}))
	var requested_index := int(choice_contract.get("index", 0))
	if requested_index != direct_choice_index:
		_fail("profile choice %d does not match direct continue %d for %s" % [
			requested_index, direct_choice_index, str(current.get("id", ""))])
		return
	var choice: Dictionary = choices[direct_choice_index]
	var displayed_text := GameState.format_event_text(str(choice.get("text", "")))
	if not _story_offer_recorded.has(_story_occurrence_id):
		_record("choice_offer", _story_occurrence_id, {
			"event_id": str(current.get("id", "")),
			"choices": [{
				"authored_index": direct_choice_index,
				"display_index": 1,
				"text": displayed_text,
				"text_sha256": _sha256_text(displayed_text),
			}],
			"countdown_active": false,
			"surface_kind": "direct_continue",
		}, STORY_SCRIPT)
		_story_offer_recorded[_story_occurrence_id] = true
	var before := _state_snapshot()
	_previous_selected_follow_up = str(choice.get("follow_up_event", ""))
	await _send_key(KEY_ENTER)
	await get_tree().process_frame
	var after := _state_snapshot()
	_record("story_choice", _story_occurrence_id, {
		"event_id": str(current.get("id", "")),
		"authored_index": direct_choice_index,
		"display_index": 1,
		"selection_mode": str(choice_contract.get("selection_mode", "direct")),
		"countdown_active": false,
		"choice_text": displayed_text,
		"choice_text_sha256": _sha256_text(displayed_text),
		"surface_kind": "direct_continue",
		"state_delta": _state_delta(before, after),
	}, STORY_SCRIPT)
	_story_choice_by_occurrence[_story_occurrence_id] = direct_choice_index
	_story_choice_recorded[_story_occurrence_id] = true


func _record_story_result(story: Node, current: Dictionary) -> void:
	if _story_occurrence_id.is_empty() \
			or _story_result_recorded.has(_story_occurrence_id) \
			or not _story_choice_by_occurrence.has(_story_occurrence_id):
		return
	var choice_index := int(_story_choice_by_occurrence[_story_occurrence_id])
	var choices: Array = current.get("choices", [])
	if choice_index < 0 or choice_index >= choices.size() \
			or not choices[choice_index] is Dictionary:
		_fail("result lost authored choice identity")
		return
	var choice: Dictionary = choices[choice_index]
	var source_stats := _text_stats(str(choice.get("result_text", "")))
	var runtime_stats := _text_stats(_runtime_story_pages(story))
	_record("story_result", _story_occurrence_id, {
		"event_id": str(current.get("id", "")),
		"authored_index": choice_index,
		"source_paragraph_count": int(source_stats["paragraph_count"]),
		"source_char_count": int(source_stats["char_count"]),
		"source_sha256": str(source_stats["sha256"]),
		"runtime_page_count": int(runtime_stats["paragraph_count"]),
		"runtime_char_count": int(runtime_stats["char_count"]),
		"runtime_sha256": str(runtime_stats["sha256"]),
	}, STORY_SCRIPT)
	_story_result_recorded[_story_occurrence_id] = true


func _drive_main(main: Node) -> bool:
	var current_turn := int(GameState.turn)
	for raw_entry in GameState.deferred_events:
		if raw_entry is Dictionary:
			var deferred_id := str((raw_entry as Dictionary).get("event_id", ""))
			if not deferred_id.is_empty() and deferred_id not in _last_main_deferred_ids:
				_last_main_deferred_ids.append(deferred_id)
	if current_turn > 1 and _last_open_week > 0 \
			and current_turn > _last_open_week:
		_close_week(_last_open_week, main)
	if current_turn <= 240 and not _week_opened.has(current_turn):
		_open_week(current_turn, main)
	if GameState.is_game_over:
		return await _drive_ending(main)
	if current_turn > 240:
		_fail("product advanced past exact Week 240")
		return false
	# MainGame can render the next week's action board for a few frames before
	# handing an already-queued story to StoryMode. A human cannot reliably
	# commit an action during that transition. Pressing the briefly visible card
	# here would arm a weekly commitment on a MainGame instance that is about to
	# be freed, leaving the fresh replacement with no live activity surface.
	# Wait for the product-owned story handoff instead of racing it.
	if not GameState.pending_story_queue.is_empty():
		return false

	var modal := main.get("modal_layer") as Control
	if is_instance_valid(modal) and modal.visible:
		var modal_body := main.get("modal_body") as Control
		var modal_button := _focused_or_first_button(
			modal_body if is_instance_valid(modal_body) else modal)
		if modal_button != null:
			await _activate_button(modal_button)
		return false
	if bool(main.get("_minigame_overlay_active")):
		var active_overlay := _active_minigame_node(main)
		var minigame_button := _focused_or_first_button(
			active_overlay if is_instance_valid(active_overlay) else main)
		# Several real activities have an authored reveal/feedback delay during
		# which no control is enabled. The global stagnation guard owns a genuine
		# no-input stall; do not reject that valid interval on its first frame.
		if minigame_button != null:
			await _activate_button(minigame_button)
		return false
	var result_confirm := _find_visible_meta_button(main, "ap_result_confirm")
	if result_confirm != null:
		await _activate_button(result_confirm)
		return false
	if bool(main.get("_transient_bg_active")):
		var choice_surface := main.get("choice_box") as Control
		var transient_button := _focused_or_first_button(choice_surface)
		if transient_button != null:
			await _activate_button(transient_button)
		return false

	var cards_raw: Variant = main.get("_ap_grid_cards")
	var cards: Array[Button] = []
	if cards_raw is Array:
		for raw_card in cards_raw as Array:
			# MainGame rebuilds the action grid deferred; its backing array can
			# briefly retain a freed card between frames.
			if is_instance_valid(raw_card) and raw_card is Button \
					and _button_is_usable(raw_card as Button):
				cards.append(raw_card as Button)
	if not cards.is_empty():
		_record_main_action_offer(main, cards)
		if bool(main.call("_demo_director_requires_player_input")) \
				and int(GameState.action_points) > 0:
			var selected := _select_visible_main_action(cards)
			if selected == null:
				_fail("profile has no visible enabled MainGame action")
				return false
			_pending_main_action = _main_action_descriptor(selected)
			_pending_main_action["week"] = current_turn
			_pending_main_action_state = _state_snapshot()
			await _activate_button(selected)
		return false

	var focused := get_viewport().gui_get_focus_owner() as Button
	var next_button := main.get("next_button") as Button
	if _button_is_usable(focused) and main.is_ancestor_of(focused) \
			and focused != next_button:
		await _activate_button(focused)
	return false


func _open_week(week: int, main: Node) -> void:
	if _last_open_week > 0 and week != _last_open_week + 1:
		_fail("week sequence jumped from %d to %d" % [_last_open_week, week])
		return
	_week_opened[week] = true
	_last_open_week = week
	var snapshot := _state_snapshot()
	_week_open_state[week] = snapshot
	_record("week_open", "week:%03d:open" % week, {
		"state": snapshot,
		"pending_story_queue": GameState.pending_story_queue.duplicate(true),
	}, MAIN_SCRIPT, week)


func _close_week(week: int, main: Node) -> void:
	if week < 1 or week > 240 or _week_closed.has(week):
		return
	var before: Dictionary = _week_open_state.get(week, {})
	var after := _state_snapshot()
	_week_closed[week] = true
	_record("week_close", "week:%03d:close" % week, {
		"state_delta": _state_delta(before, after),
		"state_after": after,
	}, MAIN_SCRIPT, week)


func _record_main_action_offer(main: Node, cards: Array[Button]) -> void:
	var descriptors: Array[Dictionary] = []
	var node_ids: Array[String] = []
	for card in cards:
		descriptors.append(_main_action_descriptor(card))
		node_ids.append(str(card.get_instance_id()))
	var signature := "%d:%d:%s" % [
		int(GameState.turn), int(main.get_instance_id()), ",".join(node_ids)]
	if _main_offer_signatures.has(signature):
		return
	_main_offer_signatures[signature] = true
	_main_offer_counter += 1
	_record("main_action_offer", "main:%s:offer:%06d" % [
		_profile_id, _main_offer_counter], {
		"volume_class": "control",
		"narrative_volume_counted": false,
		"actions": descriptors,
		"visible_enabled_only": true,
	}, MAIN_SCRIPT)


func _select_visible_main_action(cards: Array[Button]) -> Button:
	var primary: Array[Button] = []
	for card in cards:
		if bool(card.get_meta("demo_pressure_primary", false)):
			primary.append(card)
	var candidates := primary if not primary.is_empty() else cards
	for raw_action_id in _profile.get("main_action_priority", []):
		for card in candidates:
			if str(card.get_meta("demo_action_id", "")) == str(raw_action_id):
				return card
	# Function names are metadata selectors only. They are never called.
	for raw_function in _profile.get("main_function_priority", []):
		for card in candidates:
			if str(card.get_meta("ap_action_fn", "")) == str(raw_function):
				return card
	return candidates[0] if not candidates.is_empty() else null


func _main_action_descriptor(card: Button) -> Dictionary:
	return {
		"action_id": str(card.get_meta("demo_action_id", "")),
		"function": str(card.get_meta("ap_action_fn", "")),
		"grid_index": int(card.get_meta("ap_grid_index", -1)),
		"primary": bool(card.get_meta("demo_pressure_primary", false)),
		"label": str(card.text),
		"button_instance_id": int(card.get_instance_id()),
	}


func _on_weekly_commitment_finalized(commitment: Dictionary) -> void:
	if _trace_file == null or _pending_main_action.is_empty():
		return
	if GameState.is_story_weekly_commitment_record(commitment):
		return
	var expected_week := int(_pending_main_action.get("week", -1))
	if int(commitment.get("turn", -1)) != expected_week:
		_fail("visible MainGame action finalized on a different week")
		return
	_main_commit_counter += 1
	var after := _state_snapshot()
	_record("main_action_commit", "main:%s:commit:%06d" % [
		_profile_id, _main_commit_counter], {
		"volume_class": "control",
		"narrative_volume_counted": false,
		"action_id": str(commitment.get(
			"choice_id", _pending_main_action.get("action_id", ""))),
		"visible_button": _pending_main_action.duplicate(true),
		"commitment": commitment.duplicate(true),
		"state_delta": _state_delta(_pending_main_action_state, after),
	}, MAIN_SCRIPT, expected_week)
	_pending_main_action.clear()
	_pending_main_action_state.clear()


func _drive_ending(main: Node) -> bool:
	var modal := main.get("modal_layer") as Control
	if not is_instance_valid(modal) or not modal.visible:
		return false
	if _last_open_week > 0 and not _week_closed.has(240):
		_close_week(240, main)
	if _ending_id.is_empty():
		_ending_id = _ending_id_from_history()
	var page_count := int(modal.get_meta("ending_page_count", 0))
	if not _ending_open_recorded:
		_ending_open_recorded = true
		_record("ending_open", "ending:%s:open" % _profile_id, {
			"ending_id": _ending_id,
			"page_count": page_count,
			"state": _state_snapshot(),
		}, MAIN_SCRIPT, 240)
	var page_index := int(main.get("_ending_page_index"))
	if not _ending_page_occurrences.has(page_index):
		_ending_page_occurrences[page_index] = true
		_ending_pages_seen.append(page_index)
		_record("ending_page", "ending:%s:page:%d" % [
			_profile_id, page_index], {
			"page_index": page_index,
			"page_count": page_count,
			"visible_text_sha256": _sha256_text(_collect_control_text(modal)),
		}, MAIN_SCRIPT, 240)
	if page_count != 6:
		_fail("ending exposed %d pages instead of six" % page_count)
		return false
	if page_index >= page_count - 1:
		var target_errors := _target_errors()
		for message in target_errors:
			_fail(message)
		_finish_run(target_errors.is_empty())
		return true
	var next_button := _find_visible_meta_button(modal, "ending_nav")
	if next_button == null:
		_fail("ending page %d has no visible next button" % page_index)
		return false
	await _activate_button(next_button)
	return false


func _target_errors() -> Array[String]:
	var result: Array[String] = []
	var target: Dictionary = _profile.get("target", {})
	if int(GameState.turn) != int(target.get("minimum_week", 240)):
		result.append("profile ended outside exact Week 240")
	if _ending_pages_seen != [0, 1, 2, 3, 4, 5]:
		result.append("ending pages were not traversed exactly 0..5")
	var event_ids: Array[String] = []
	for occurrence in _story_occurrences:
		event_ids.append(str(occurrence.get("event_id", "")))
	var required_sequence: Array = _profile.get("required_event_sequence", [])
	var cursor := 0
	for event_id in event_ids:
		if cursor < required_sequence.size() \
				and event_id == str(required_sequence[cursor]):
			cursor += 1
	if cursor != required_sequence.size():
		result.append("required story sequence is incomplete at %d/%d" % [
			cursor, required_sequence.size()])
	var counts: Dictionary = {}
	for event_id in event_ids:
		counts[event_id] = int(counts.get(event_id, 0)) + 1
	for raw_event_id in _profile.get("required_event_occurrences", {}).keys():
		var required_count := int(_profile[
			"required_event_occurrences"][raw_event_id])
		if int(counts.get(raw_event_id, 0)) < required_count:
			result.append("missing repeated occurrence %s %d/%d" % [
				raw_event_id, int(counts.get(raw_event_id, 0)), required_count])
	var total_assets := float(GameState.get_total_asset_value())
	var minimum_assets: Variant = target.get("minimum_total_assets")
	var maximum_assets: Variant = target.get("maximum_total_assets")
	if minimum_assets != null and total_assets < float(minimum_assets):
		result.append("asset floor missed: %.0f < %.0f" % [
			total_assets, float(minimum_assets)])
	if maximum_assets != null and total_assets > float(maximum_assets):
		result.append("asset ceiling missed: %.0f > %.0f" % [
			total_assets, float(maximum_assets)])
	for raw_flag in target.get("required_flags_true", []):
		if not bool(GameState.flags.get(str(raw_flag), false)):
			result.append("required final flag is false: %s" % str(raw_flag))
	for raw_flag in target.get("required_flags_false", []):
		if bool(GameState.flags.get(str(raw_flag), false)):
			result.append("required final flag is true: %s" % str(raw_flag))
	var required_endings: Array = target.get("required_ending_ids", [])
	if not required_endings.is_empty() and _ending_id not in required_endings:
		result.append("ending is outside profile allowlist: %s" % _ending_id)
	if _ending_id in target.get("forbidden_ending_ids", []):
		result.append("profile reached forbidden ending: %s" % _ending_id)
	for week in range(1, 241):
		if not _week_opened.has(week) or not _week_closed.has(week):
			result.append("week %d lacks exact open/close occurrence" % week)
			break
	return result


func _finish_run(success: bool) -> void:
	if _trace_file != null:
		if not success and _errors.is_empty():
			_fail("runtime trace ended without success")
		_record("run_end", "run:%s:end" % _profile_id, {
			"status": "pass" if success and _errors.is_empty() else "fail",
			"errors": _errors.duplicate(),
			"product_go": "HOLD",
			"human_density_gate": "OPEN",
			"state_injection_detected": false,
			"final_state": {
				"week": int(GameState.turn),
				"total_assets": float(GameState.get_total_asset_value()),
				"flags": GameState.flags.duplicate(true),
				"ending_id": _ending_id,
			},
		}, _scene_script_path(get_tree().current_scene), 240)
		_trace_file.flush()
		_trace_file.close()
		_trace_file = null
	if success and _errors.is_empty():
		print("FULL_GAME_RUNTIME_TRACE_RUN_OK profile=%s weeks=240 story_occurrences=%d ending=%s product_go=HOLD human_density_gate=OPEN" % [
			_profile_id, _story_occurrences.size(), _ending_id])
		get_tree().quit(0)
	else:
		print("FULL_GAME_RUNTIME_TRACE_RUN_FAIL profile=%s errors=%s product_go=HOLD human_density_gate=OPEN" % [
			_profile_id, str(_errors)])
		get_tree().quit(1)


func _fail(message: String) -> void:
	if message.is_empty() or message in _errors:
		return
	_errors.append(message)
	_fatal = true
	if _trace_file != null:
		_record("trace_error", "error:%s:%06d" % [
			_profile_id, _errors.size()], {
			"message": message,
			"state": _state_snapshot(),
		}, _scene_script_path(get_tree().current_scene))


func _record(
		record_type: String, occurrence_id: String, payload: Dictionary,
		scene_path: String = "", forced_week: int = -1) -> void:
	if _trace_file == null:
		return
	_sequence += 1
	var week := forced_week if forced_week > 0 else int(GameState.turn)
	var resolved_scene_path := scene_path
	if resolved_scene_path.is_empty():
		resolved_scene_path = "res://tools/FullGameRuntimeTrace.gd"
	var row := {
		"schema_version": TRACE_SCHEMA_VERSION,
		"record_type": record_type,
		"sequence": _sequence,
		"candidate_commit": _candidate_commit,
		"candidate_tree": _candidate_tree,
		"candidate_dirty": _candidate_dirty,
		"profile_id": _profile_id,
		"profile_hash": _profile_hash,
		"seed": int(_profile.get("seed", 0)),
		"locale": str(_profile.get("locale", "ko")),
		"week": week,
		"month": mini(60, int((week - 1) / 4) + 1),
		"chapter": mini(5, int((week - 1) / 48) + 1),
		"scene_path": resolved_scene_path,
		"occurrence_id": occurrence_id,
		"state_injection": false,
		"payload": payload,
	}
	_trace_file.store_line(JSON.stringify(row))
	_trace_file.flush()


func _state_snapshot() -> Dictionary:
	return {
		"turn": int(GameState.turn),
		"money": float(GameState.money),
		"total_assets": float(GameState.get_total_asset_value()),
		"health": int(GameState.health),
		"mental": int(GameState.mental),
		"flags": GameState.flags.duplicate(true),
		"event_log": GameState.event_log.duplicate(true),
		"deferred_events": GameState.deferred_events.duplicate(true),
		"pending_story_queue": GameState.pending_story_queue.duplicate(true),
		"pending_weekly_commitment": GameState.pending_weekly_commitment.duplicate(true),
		"weekly_commitments": GameState.weekly_commitments.duplicate(true),
		"chapter5_causal": GameState.chapter5_causal_state.duplicate(true),
		"chapter5_finale": GameState.chapter5_finale_state.duplicate(true),
	}


func _state_delta(before: Dictionary, after: Dictionary) -> Dictionary:
	return {
		"scalar": _dictionary_delta(
			{
				"turn": before.get("turn"),
				"money": before.get("money"),
				"total_assets": before.get("total_assets"),
				"health": before.get("health"),
				"mental": before.get("mental"),
			},
			{
				"turn": after.get("turn"),
				"money": after.get("money"),
				"total_assets": after.get("total_assets"),
				"health": after.get("health"),
				"mental": after.get("mental"),
			}),
		"flags": _dictionary_delta(
			before.get("flags", {}), after.get("flags", {})),
		"event_log": _array_delta(
			before.get("event_log", []), after.get("event_log", [])),
		"deferred": _array_delta(
			before.get("deferred_events", []), after.get("deferred_events", [])),
		"commitment": {
			"pending": _dictionary_delta(
				before.get("pending_weekly_commitment", {}),
				after.get("pending_weekly_commitment", {})),
			"ledger": _array_delta(
				before.get("weekly_commitments", []),
				after.get("weekly_commitments", [])),
		},
		"chapter5_causal": _dictionary_delta(
			before.get("chapter5_causal", {}),
			after.get("chapter5_causal", {})),
		"chapter5_finale": _dictionary_delta(
			before.get("chapter5_finale", {}),
			after.get("chapter5_finale", {})),
	}


func _dictionary_delta(before_raw: Variant, after_raw: Variant) -> Dictionary:
	var before: Dictionary = before_raw if before_raw is Dictionary else {}
	var after: Dictionary = after_raw if after_raw is Dictionary else {}
	var added := {}
	var removed: Array[String] = []
	var changed := {}
	for raw_key in after.keys():
		var key := str(raw_key)
		if not before.has(raw_key):
			added[key] = after[raw_key]
		elif JSON.stringify(before[raw_key]) != JSON.stringify(after[raw_key]):
			changed[key] = {"before": before[raw_key], "after": after[raw_key]}
	for raw_key in before.keys():
		if not after.has(raw_key):
			removed.append(str(raw_key))
	removed.sort()
	return {"added": added, "removed": removed, "changed": changed}


func _array_delta(before_raw: Variant, after_raw: Variant) -> Dictionary:
	var before: Array = before_raw if before_raw is Array else []
	var after: Array = after_raw if after_raw is Array else []
	var prefix := 0
	while prefix < before.size() and prefix < after.size() \
			and JSON.stringify(before[prefix]) == JSON.stringify(after[prefix]):
		prefix += 1
	return {
		"before_count": before.size(),
		"after_count": after.size(),
		"common_prefix_count": prefix,
		"removed_tail": before.slice(prefix),
		"appended_tail": after.slice(prefix),
	}


func _event_source_text(event: Dictionary) -> String:
	var fragments: Array[String] = []
	for key in ["description", "text"]:
		if event.has(key):
			_collect_variant_text(event[key], fragments)
	return "\n\n".join(fragments)


func _runtime_story_pages(story: Node) -> String:
	var fragments: Array[String] = []
	var raw_pages: Variant = story.get("_paragraphs")
	if raw_pages is Array:
		for raw_page in raw_pages as Array:
			_collect_variant_text(raw_page, fragments)
	return "\n\n".join(fragments)


func _collect_variant_text(value: Variant, output: Array[String]) -> void:
	if value is String:
		if not str(value).strip_edges().is_empty():
			output.append(str(value))
	elif value is Array:
		for item in value as Array:
			_collect_variant_text(item, output)
	elif value is Dictionary:
		var row: Dictionary = value
		for key in ["text", "body", "description"]:
			if row.has(key):
				_collect_variant_text(row[key], output)


func _text_stats(text: String) -> Dictionary:
	var normalized := text.replace("\r\n", "\n").replace("\r", "\n")
	var paragraphs: Array[String] = []
	for raw_paragraph in normalized.split("\n\n", false):
		var paragraph := str(raw_paragraph).strip_edges()
		if not paragraph.is_empty():
			paragraphs.append(paragraph)
	var joined := "\n\n".join(paragraphs)
	return {
		"paragraph_count": paragraphs.size(),
		"char_count": joined.length(),
		"sha256": _sha256_text(joined),
	}


func _story_is_control(story: Node, event: Dictionary) -> bool:
	var event_id := str(event.get("id", ""))
	return bool(story.get("_is_chapter_card")) \
		or event_id.begins_with("chapter_card_") \
		or str(event.get("category", "")) in ["chapter", "system", "tutorial"]


func _chapter5_same_turn_pair(previous_id: String, event_id: String) -> bool:
	if previous_id.is_empty() or event_id.is_empty():
		return false
	var previous_owned := GameState.chapter5_causal_is_owned_event(previous_id) \
		or GameState.chapter5_finale_is_owned_event(previous_id)
	var current_owned := GameState.chapter5_causal_is_owned_event(event_id) \
		or GameState.chapter5_finale_is_owned_event(event_id)
	return previous_owned and current_owned


func _ending_id_from_history() -> String:
	var history: Variant = MetaProgression.data.get("run_history", [])
	if history is Array and not (history as Array).is_empty() \
			and (history as Array)[-1] is Dictionary:
		return str(((history as Array)[-1] as Dictionary).get("ending_id", ""))
	return _ending_id


func _scene_script_path(scene: Node) -> String:
	if not is_instance_valid(scene):
		return "res://tools/FullGameRuntimeTrace.gd"
	var script := scene.get_script() as Script
	return script.resource_path if script != null \
		else "res://tools/FullGameRuntimeTrace.gd"


func _story_signature_for(story: Node) -> String:
	var current: Variant = story.get("_current")
	return ":%s:%d:%d:%s:%s:%s:%s" % [
		str((current as Dictionary).get("id", "")) if current is Dictionary else "",
		int(story.get("_dialogue_log_event_serial")),
		int(story.get("_para_index")),
		str(story.get("_typing")),
		str(story.get("_showing_choices")),
		str(story.get("_pending_after_result")),
		str(story.get("_transitioning")),
	]


func _main_signature_for(main: Node) -> String:
	var modal := main.get("modal_layer") as Control
	var cards_raw: Variant = main.get("_ap_grid_cards")
	return ":%s:%s:%d:%d:%s:%s%s" % [
		str(is_instance_valid(modal) and modal.visible),
		str(main.get("_modal_kind")),
		(cards_raw as Array).size() if cards_raw is Array else 0,
		int(GameState.action_points),
		str(main.get("pending_result_text")),
		str(GameState.is_game_over),
		_active_minigame_signature(main),
	]


func _active_minigame_node(main: Node) -> Node:
	if not bool(main.get("_minigame_overlay_active")):
		return null
	match str(main.get("_active_activity_id")):
		"commitment_task":
			return main.get("_commitment_task") as Node
		"job_hunt":
			return main.get("job_hunt_game") as Node
		"delivery":
			return main.get("aruba_game") as Node
		"racetrack":
			return main.get("racetrack") as Node
		"holdem":
			return main.get("holdem_club") as Node
		"scalping":
			return main.get("scalping_game") as Node
		"casino":
			return main.get("jeongseon_casino") as Node
	return null


func _active_minigame_signature(main: Node) -> String:
	if not bool(main.get("_minigame_overlay_active")):
		return ":mini:none"
	var activity_id := str(main.get("_active_activity_id"))
	var overlay := _active_minigame_node(main)
	if not is_instance_valid(overlay):
		return ":mini:%s:missing" % activity_id
	var focused := get_viewport().gui_get_focus_owner()
	var focus_identity := "none"
	if is_instance_valid(focused) and focused is Button \
			and overlay.is_ancestor_of(focused):
		focus_identity = "%d:%s" % [
			int(focused.get_instance_id()), str((focused as Button).text)]
	var state_bits: Array[String] = []
	match activity_id:
		"delivery":
			state_bits = [
				str(overlay.get("_mode")),
				str(overlay.get("_card_idx")),
				str(overlay.get("_card_waiting")),
				str(overlay.get("_conv_served")),
				str(overlay.get("_conv_selected")),
				str(overlay.get("_conv_feedback_slot")),
				str((overlay.get("_del_selected") as Array).size()),
			]
		"job_hunt":
			state_bits = [
				str(overlay.get("current_mode")),
				str(overlay.get("_q_idx")),
				str(overlay.get("_waiting")),
			]
	return ":mini:%s:%s:%s:%s" % [
		activity_id,
		focus_identity,
		",".join(state_bits),
		_sha256_text(_collect_control_text(overlay)),
	]


func _visible_choice_buttons(story: Node) -> Array[Button]:
	var result: Array[Button] = []
	var choice_box := story.get("_choice_box") as Control
	if is_instance_valid(choice_box):
		_collect_choice_buttons(choice_box, result)
	result.sort_custom(func(left: Button, right: Button) -> bool:
		return int(left.get_meta("choice_display_num", 0)) \
			< int(right.get_meta("choice_display_num", 0)))
	return result


func _collect_choice_buttons(root: Node, output: Array[Button]) -> void:
	if root is Button:
		var button := root as Button
		if _button_is_usable(button) and button.has_meta("choice_index"):
			output.append(button)
	if root is Control and not (root as Control).is_visible_in_tree():
		return
	for child in root.get_children():
		_collect_choice_buttons(child, output)


func _button_is_usable(button_raw: Variant) -> bool:
	# A deferred UI rebuild can leave a freed Object in focus/card bookkeeping
	# for one frame. Validate before the `is Button` test: Godot itself errors
	# when a freed Object is used as the left operand of `is`.
	if not is_instance_valid(button_raw):
		return false
	if not button_raw is Button:
		return false
	var button := button_raw as Button
	return button.is_inside_tree() \
		and button.is_visible_in_tree() \
		and not button.disabled \
		and button.focus_mode != Control.FOCUS_NONE


func _focused_or_first_button(root: Node) -> Button:
	if not is_instance_valid(root):
		return null
	var focused := get_viewport().gui_get_focus_owner() as Button
	if _button_is_usable(focused) and root.is_ancestor_of(focused):
		return focused
	return _find_first_enabled_button(root)


func _find_first_enabled_button(root: Node) -> Button:
	if root is Button and _button_is_usable(root as Button):
		return root as Button
	if root is Control and not (root as Control).is_visible_in_tree():
		return null
	for child in root.get_children():
		var found := _find_first_enabled_button(child)
		if found != null:
			return found
	return null


func _find_button_with_any_text(root: Node, candidates: Array[String]) -> Button:
	if root is Button and _button_is_usable(root as Button) \
			and str((root as Button).text) in candidates:
		return root as Button
	if root is Control and not (root as Control).is_visible_in_tree():
		return null
	for child in root.get_children():
		var found := _find_button_with_any_text(child, candidates)
		if found != null:
			return found
	return null


func _find_visible_meta_button(root: Node, meta_key: String) -> Button:
	if root is Button and _button_is_usable(root as Button) \
			and bool(root.get_meta(meta_key, false)):
		return root as Button
	if root is Control and not (root as Control).is_visible_in_tree():
		return null
	for child in root.get_children():
		var found := _find_visible_meta_button(child, meta_key)
		if found != null:
			return found
	return null


func _find_visible_meta_value_button(
		root: Node, meta_key: String, expected: Variant) -> Button:
	if root is Button and _button_is_usable(root as Button) \
			and root.has_meta(meta_key) \
			and root.get_meta(meta_key) == expected:
		return root as Button
	if root is Control and not (root as Control).is_visible_in_tree():
		return null
	for child in root.get_children():
		var found := _find_visible_meta_value_button(child, meta_key, expected)
		if found != null:
			return found
	return null


func _activate_button(button_raw: Variant) -> void:
	if not _button_is_usable(button_raw):
		# The product may rebuild the same visible surface between discovery and
		# this coroutine. Let the next driver frame discover its replacement.
		return
	var button := button_raw as Button
	button.grab_focus()
	if not _button_is_usable(button):
		return
	if not button.has_focus():
		button.grab_focus()
	await _send_key(KEY_ENTER)


func _send_key(keycode: Key) -> void:
	var pressed := InputEventKey.new()
	pressed.keycode = keycode
	pressed.physical_keycode = keycode
	pressed.pressed = true
	Input.parse_input_event(pressed)
	await get_tree().process_frame
	var released := pressed.duplicate() as InputEventKey
	released.pressed = false
	Input.parse_input_event(released)
	await get_tree().process_frame


func _collect_control_text(root: Node) -> String:
	var fragments: Array[String] = []
	_collect_control_text_recursive(root, fragments)
	return "\n".join(fragments)


func _collect_control_text_recursive(root: Node, output: Array[String]) -> void:
	if root is Label and (root as Label).is_visible_in_tree():
		output.append(str((root as Label).text))
	elif root is Button and (root as Button).is_visible_in_tree():
		output.append(str((root as Button).text))
	elif root is RichTextLabel and (root as RichTextLabel).is_visible_in_tree():
		output.append(str((root as RichTextLabel).get_parsed_text()))
	for child in root.get_children():
		_collect_control_text_recursive(child, output)


func _sha256_text(text: String) -> String:
	return _sha256_bytes(text.to_utf8_buffer())


func _sha256_bytes(bytes: PackedByteArray) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	# Godot reports an engine error for update(PackedByteArray()) even though
	# SHA-256 of the empty message is well-defined. finish() directly yields it.
	if not bytes.is_empty():
		context.update(bytes)
	return context.finish().hex_encode()


func _on_run_started() -> void:
	_run_started_observed = true


func _on_game_over(ending_id: String) -> void:
	_ending_id = ending_id
