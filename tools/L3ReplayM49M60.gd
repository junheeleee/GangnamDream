extends Node
## Authored foreground selector probe with a StoryMode transcript.
##
## Walks W193..W240 through MainGame's causal/finale/opening/arc/milestone
## selectors and the real StoryMode transaction surface. It deliberately does
## not run the weekly economy, EventManager, ambient/random scheduler, save/resume
## cycle, or human input timing. Therefore its rooted-week count and selector gap
## are diagnostics only, never full-run density or human-play evidence.
##
## Usage:
##   Godot --headless res://tools/L3ReplayM49M60.tscn -- \
##     --profile=property
##   Godot --headless res://tools/L3ReplayM49M60.tscn -- \
##     --profile=general \
##     --choices='{"arc_minseo_03_arrival":1,"arc_y5_general_name_boundary_exact":1,"arc_y5_general_debt_memory_reconnect":1}'

const STORY_MODE_SCENE := "res://scenes/StoryMode.tscn"
const MAIN_GAME_SCRIPT := "res://scenes/MainGame.gd"
const CHAPTER5_CAUSAL_ROUTE := preload("res://systems/Chapter5CausalRoute.gd")
const CHAPTER5_FINALE_ROUTE := preload("res://systems/Chapter5FinaleRoute.gd")
const HISTORY_FIXTURE_PATH := \
	"res://tools/fixtures/chapter5_history_base_w193.json"

const GENERAL_CHOICE_RECEIPTS := [
	{
		"event_id": "arc_minseo_03_arrival",
		"turn": 201,
		"source_key": "m51_minseo_arrival",
		"flag_prefix": "chapter5_general_minseo_arrival_",
	},
	{
		"event_id": "arc_y5_general_name_boundary_exact",
		"turn": 211,
		"source_key": "w211_name_boundary",
		"flag_prefix": "chapter5_general_name_boundary_",
	},
	{
		"event_id": "arc_y5_general_debt_memory_reconnect",
		"turn": 220,
		"source_key": "w220_debt_memory_reconnect",
		"flag_prefix": "chapter5_general_debt_memory_reconnect_",
	},
]

const CHAPTER5_REQUIRED_ENTRY_FLAGS: Array[String] = [
	"arc_sangchul_met_seen",
	"arc_daeun_met",
	"daeun_romance_started",
	"arc_minseo_02_seen",
	"arc_jaehyuk_reunion_seen",
	"arc_jaehyuk_aftermath_seen",
]
const CHAPTER5_EXCLUDED_ENTRY_FLAGS: Array[String] = [
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
]

var _profile := "property"
var _debug := false
var _lang := "ko"
var _from_turn := 193
var _to_turn := 240
var _choice_overrides: Dictionary = {}
var _default_choice := 0
var _errors: Array[String] = []
var _scene_count := 0
var _weeks_with_root: Array[int] = []
var _weeks_without_root: Array[int] = []
var _played_event_ids: Array[String] = []
var _played_turn_by_event: Dictionary = {}
var _played_choice_by_event: Dictionary = {}

func _ready() -> void:
	_parse_args()
	# This headless transcript verifies authored routing and visible prose, not
	# the audio mix. Prevent pooled SFX playbacks from outliving immediate quit.
	AudioManager.sfx_enabled = false
	_set_language(_lang)
	print("=== AUTHORED FOREGROUND SELECTOR PROBE profile=%s lang=%s turns=%d..%d ===" % [
		_profile, _lang, _from_turn, _to_turn])
	print("MODEL_LIMIT selector-only; no economy/random/ambient/save-resume/human timing")
	_seed_profile()
	await _walk_weeks()
	_validate_replay()
	_print_summary()
	await _release_audio_for_exit()
	get_tree().quit(1 if not _errors.is_empty() else 0)

func _parse_args() -> void:
	var args: Array = []
	args.append_array(OS.get_cmdline_user_args())
	args.append_array(OS.get_cmdline_args())
	for raw in args:
		var arg := str(raw).strip_edges()
		if arg.begins_with("--profile="):
			_profile = arg.substr(10)
		elif arg == "--debug":
			_debug = true
		elif arg.begins_with("--lang="):
			_lang = arg.substr(7)
		elif arg.begins_with("--from="):
			_from_turn = int(arg.substr(7))
		elif arg.begins_with("--to="):
			_to_turn = int(arg.substr(5))
		elif arg.begins_with("--default-choice="):
			_default_choice = int(arg.substr(17))
		elif arg.begins_with("--choices="):
			var parsed: Variant = JSON.parse_string(arg.substr(10))
			if parsed is Dictionary:
				_choice_overrides = parsed as Dictionary

func _set_language(lang: String) -> void:
	if SaveManager.has_method("set_setting"):
		SaveManager.set_setting("language", lang)
		SaveManager.set_setting("language_gate_seen", true)
	if LocaleManager.has_method("set_language"):
		LocaleManager.set_language(lang)
	else:
		LocaleManager.language = lang
	if LocaleManager.language != lang:
		LocaleManager.language = lang
	DataRegistry.reload()

func _set_calendar(at_turn: int) -> void:
	GameState.turn = at_turn
	GameState.year = 2026 + int((at_turn - 1) / 48)
	GameState.month = int((at_turn - 1) / 4) % 12 + 1
	GameState.week_of_month = int((at_turn - 1) % 4) + 1
	GameState.age = 33 + int((at_turn - 1) / 48)

## Both profiles below start from the same reduced W193 selector fixture. It is
## not a full human save: it carries only state needed to probe authored routing.
## Profile overlays then change only the facts needed by the route under test.
func _seed_profile() -> void:
	if _profile == "property":
		_seed_property()
	elif _profile == "general":
		_seed_general()
	else:
		_errors.append("unknown profile %s" % _profile)

## A W193 selector probe must carry four completed chapters. Keep that reduced
## history in a locale-neutral, checked-in fixture instead of borrowing a
## developer save slot; otherwise a clean checkout silently re-opens Chapter 1
## arcs in Chapter 5 and manufactures false foreground roots.
func _load_history_base() -> bool:
	if not FileAccess.file_exists(HISTORY_FIXTURE_PATH):
		_errors.append("chapter-5 history fixture is missing")
		return false
	var parsed: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(HISTORY_FIXTURE_PATH))
	if not parsed is Dictionary:
		_errors.append("chapter-5 history fixture is not an object")
		return false
	var fixture: Dictionary = parsed
	var exact_keys: Array[String] = [
		"schema_version", "fixture_id", "turn", "flags", "cast",
		"year_scenes", "deferred_events", "inventory_ids", "clues",
		"current_job", "job_tenure", "work_performance",
	]
	if fixture.keys().size() != exact_keys.size():
		_errors.append("chapter-5 history fixture schema drifted")
		return false
	for key in exact_keys:
		if not fixture.has(key):
			_errors.append("chapter-5 history fixture lacks %s" % key)
			return false
	if int(fixture.get("schema_version", -1)) != 1 \
			or str(fixture.get("fixture_id", "")) \
				!= "chapter5_history_base_w193_v1" \
			or int(fixture.get("turn", -1)) != 193 \
			or not fixture.get("flags") is Dictionary \
			or not fixture.get("cast") is Dictionary \
			or not fixture.get("year_scenes") is Dictionary \
			or not fixture.get("deferred_events") is Array \
			or not fixture.get("inventory_ids") is Array \
			or not fixture.get("clues") is Array \
			or not fixture.get("current_job") is Dictionary:
		_errors.append("chapter-5 history fixture values are invalid")
		return false
	SaveManager.clear_loaded_resume_context()
	GameState.start_new_game()
	GameState.flags = (fixture["flags"] as Dictionary).duplicate(true)
	GameState.cast = (fixture["cast"] as Dictionary).duplicate(true)
	GameState.year_scenes = (fixture["year_scenes"] as Dictionary).duplicate(true)
	GameState.deferred_events = (fixture["deferred_events"] as Array).duplicate(true)
	GameState.clues = (fixture["clues"] as Array).duplicate(true)
	GameState.current_job = (fixture["current_job"] as Dictionary).duplicate(true)
	GameState.job_tenure = int(fixture.get("job_tenure", 0))
	GameState.work_performance = int(fixture.get("work_performance", 50))
	GameState.inventory.clear()
	for raw_item_id in fixture["inventory_ids"] as Array:
		if not raw_item_id is String or str(raw_item_id).is_empty():
			_errors.append("chapter-5 history fixture has an invalid item id")
			return false
		GameState.add_item(str(raw_item_id), 1)
	GameState.event_log.clear()
	GameState.pending_story_queue.clear()
	_set_calendar(193)
	return true

func _seed_property() -> void:
	if not _load_history_base():
		return
	# The property selector profile keeps the optional W220 custody receipt while
	# leaving W216 to the generic stop. Explicit CLI choices still override it.
	if not _choice_overrides.has("arc_sangchul_final_door"):
		_choice_overrides["arc_sangchul_final_door"] = 1
	if not _choice_overrides.has("arc_y5_three_in_room_decision"):
		_choice_overrides["arc_y5_three_in_room_decision"] = 1
	GameState.player_route = "투자형"
	GameState.tendency_realized = "invest"
	GameState.money = 2_100_000_000.0
	GameState.portfolio = {}
	GameState.loans = {"bank": 0.0, "second": 0.0}
	GameState.pending_story_queue = []
	GameState.flags["prologue_done"] = true
	GameState.flags.erase("route_career")
	GameState.flags.erase("route_startup")
	GameState.flags["route_invest"] = true
	# The preserved history came from a career save. A KRW 2.1B investment
	# profile necessarily crossed these earlier investment milestones before
	# Chapter 5; reopening them here would add counterfeit Year-1/wealth beats.
	for history_flag in [
		"arc_ch1_invest_chart_seen", "arc_almost_there_seen",
		"arc_final_stretch_seen", "calculated_final_push",
		"arc_gangnam_real_estate_seen",
		"asset_100m_reached", "asset_500m_reached",
		"asset_1b_reached", "asset_2b_reached",
	]:
		GameState.flags[history_flag] = true
	GameState.flags.erase("foreground_story_turn")
	for flag in CHAPTER5_REQUIRED_ENTRY_FLAGS:
		GameState.flags[flag] = true
	for flag in CHAPTER5_EXCLUDED_ENTRY_FLAGS:
		GameState.flags.erase(flag)
	for card in ["chapter_33_seen", "chapter_34_seen", "chapter_35_seen",
			"chapter_36_seen"]:
		GameState.flags[card] = true
	GameState.health = 62
	GameState.mental = 58
	GameState.chapter5_causal_state = CHAPTER5_CAUSAL_ROUTE.default_state()
	GameState.chapter5_finale_state = CHAPTER5_FINALE_ROUTE.default_state()
	_set_calendar(_from_turn)
	_diagnose_property_entry()

## MainGame locks the causal entry itself when W195 arrives. Print the exact
## preconditions up front so a fixture miss is visible instead of silently
## turning the property replay into a generic run.
func _diagnose_property_entry() -> void:
	print("[fixture] player_route=%s route_invest=%s assets=%.0f" % [
		str(GameState.player_route),
		str(GameState.flags.get("route_invest", false)),
		GameState.get_total_asset_value()])
	print("[fixture] daeun_path_live=%s participants_ready=%s relocation_reserved=%s" % [
		str(GameState.call("_chapter5_causal_daeun_path_live")),
		str(GameState.call("_chapter5_causal_entry_participants_ready")),
		str(GameState.chapter5_causal_guarantee_relocation_reserved())])
	print("[fixture] product_path_available=%s" % [
		str(GameState.chapter5_causal_product_path_available())])

func _seed_general() -> void:
	if not _load_history_base():
		return
	# Reproduce the rejected human run's actual Year-5 relationship fork. The
	# preserved history reaches W193 on Daeun's together path, then the player
	# explicitly keeps the Gangnam goal ahead of a new commitment at W195.
	if not _choice_overrides.has("arc_daeun_y5_feelings"):
		_choice_overrides["arc_daeun_y5_feelings"] = 1
	GameState.player_route = "투자형"
	# Near the goal, not over it: staying under 3B keeps the hidden/goal endings
	# from replacing the W237/W240 ledger.
	GameState.money = 2_600_000_000.0
	GameState.portfolio = {}
	GameState.loans = {"bank": 0.0, "second": 0.0}
	GameState.pending_story_queue = []
	GameState.tendency_realized = "invest"
	GameState.chapter5_causal_state = CHAPTER5_CAUSAL_ROUTE.default_state()
	GameState.chapter5_finale_state = CHAPTER5_FINALE_ROUTE.default_state()
	GameState.flags["prologue_done"] = true
	# This is already a KRW 2.6B investment run. Its Chapter-1 chart and wealth
	# milestones happened before the W193 fixture boundary; reopening them here
	# manufactures five counterfeit Year-5 selector stops.
	for history_flag in [
		"arc_ch1_invest_chart_seen", "arc_almost_there_seen",
		"arc_final_stretch_seen", "calculated_final_push",
		"arc_gangnam_real_estate_seen",
		"asset_100m_reached", "asset_500m_reached",
		"asset_1b_reached", "asset_2b_reached",
	]:
		GameState.flags[history_flag] = true
	for flag_id in [
		"route_career", "route_invest", "route_startup",
		"father_crisis_contact_present",
		"father_crisis_contact_called", "father_crisis_contact_missed",
		"arc_final_countdown_seen", "arc_final_week_seen",
		"final_signature_owned", "final_signature_collateral",
		"final_signature_people",
		"arc_minseo_03_seen",
		"chapter5_general_minseo_arrival_0",
		"chapter5_general_minseo_arrival_1",
		"arc_y5_general_debt_memory_reconnect_seen",
		"chapter5_general_debt_memory_reconnect_0",
		"chapter5_general_debt_memory_reconnect_1",
		"arc_endgame_sixmonths_seen",
		"arc_y5_general_last_page_instruction_seen",
		"chapter5_general_last_page_instruction_0",
		"chapter5_general_last_page_instruction_1",
	]:
		GameState.flags.erase(flag_id)
	GameState.flags["route_invest"] = true
	GameState.flags["father_passed"] = true
	for card in ["chapter_33_seen", "chapter_34_seen", "chapter_35_seen",
			"chapter_36_seen"]:
		GameState.flags[card] = true
	GameState.health = 62
	GameState.mental = 58
	_set_calendar(_from_turn)

## Script-only, never added to the tree: MainGame._ready() expects its real scene
## children. The shipped audits drive the same selectors this way.
func _new_main_game() -> Node:
	var game: Node = load(MAIN_GAME_SCRIPT).new()
	game.set_meta("_screenshot_qa_static_surface", true)
	return game

## Reproduces only the authored Chapter 5 priority slice in MainGame:
## causal route -> finale route -> opening chapter -> arc -> milestone.
## It intentionally omits EventManager/random/ambient/economy consumers.
func _roots_for_turn(at_turn: int) -> Array:
	GameState.pending_story_queue = []
	GameState.flags.erase("foreground_story_turn")
	GameState.flags.erase("month_event_turn")
	var game := _new_main_game()
	var roots: Array = []
	var claimed := false
	if game.has_method("_route_chapter5_causal_week"):
		claimed = bool(game.call("_route_chapter5_causal_week"))
	if not claimed and game.has_method("_route_chapter5_finale_week"):
		claimed = bool(game.call("_route_chapter5_finale_week"))
	if claimed:
		roots = GameState.pending_story_queue.duplicate()
	else:
		var arc_id := str(game.call("_next_arc_id", -1, false, true))
		if not arc_id.is_empty():
			# Let MainGame build the real queue. W193 appends the due reckoning
			# behind the chapter card here; assigning [arc_id] directly delays it.
			game.call("_go_story_mode", [arc_id])
			roots = GameState.pending_story_queue.duplicate()
		else:
			var ms_id := str(game.call("_next_milestone_id"))
			if not ms_id.is_empty():
				game.call("_go_story_mode", [ms_id])
				roots = GameState.pending_story_queue.duplicate()
	game.free()
	return roots

func _walk_weeks() -> void:
	for at_turn in range(_from_turn, _to_turn + 1):
		_set_calendar(at_turn)
		var roots: Array = await _roots_for_turn(at_turn)
		if roots.is_empty():
			_weeks_without_root.append(at_turn)
			print(("\n--- W%d (M%d) · authored selector root 없음 " +
				"(random/ambient 미측정) ---") % [
					at_turn, int((at_turn - 1) / 4) + 1])
			continue
		_weeks_with_root.append(at_turn)
		print("\n=========================================================")
		print("W%d (M%d) · roots=%s" % [
			at_turn, int((at_turn - 1) / 4) + 1, str(roots)])
		print("=========================================================")
		await _play_queue(roots, at_turn)

func _play_queue(roots: Array, at_turn: int) -> void:
	GameState.pending_story_queue = roots.duplicate()
	var packed: PackedScene = load(STORY_MODE_SCENE)
	var story: Node = packed.instantiate()
	add_child(story)
	await get_tree().process_frame
	if story.has_method("_set_auto_mode"):
		story.call("_set_auto_mode", false, false)
	await _settle(0.2)
	var guard := 0
	var last_id := ""
	while guard < 80:
		guard += 1
		if _story_is_leaving(story):
			break
		var current: Variant = story.get("_current")
		if not current is Dictionary or (current as Dictionary).is_empty():
			break
		var event_id := str((current as Dictionary).get("id", ""))
		if event_id.is_empty():
			break
		if event_id != last_id:
			last_id = event_id
			_print_scene(current as Dictionary, at_turn, story)
		if _debug:
			print("    [dbg] typing=%s choices=%s para=%s/%s after_result=%s transitioning=%s hold=%s beat=%s card=%s" % [
				str(story.get("_typing")),
				str(story.get("_showing_choices")),
				str(story.get("_para_index")),
				str((story.get("_paragraphs") as Array).size()),
				str(story.get("_pending_after_result")),
				str(story.get("_transitioning")),
				str(story.get("_direction_hold_active")),
				str(story.get("_direction_beat_waiting")),
				str(story.get("_is_chapter_card")),
			])
		# Walk prose to the choice rail (or to the end of a choiceless beat).
		var advanced := await _advance_to_stop(story, event_id)
		if not advanced:
			break
		if bool(story.get("_showing_choices")):
			var idx := _pick_choice(current as Dictionary, event_id, story)
			_print_choice_taken(current as Dictionary, idx)
			story.call("_on_choice", idx)
			await _settle(0.15)
			var shown_result := _story_screen_text(story)
			if not shown_result.is_empty():
				print("    --- 화면 결과 (%d자) ---" % shown_result.length())
				for line in shown_result.split("\n"):
					print("    | %s" % line)
			await _drain_result(story, event_id)
		elif story.has_method("_on_advance"):
			# A choiceless beat (chapter card, bridge) still hands off to the
			# next queued root; keep walking instead of ending the week early.
			story.call("_on_advance")
			await _settle(0.15)
		else:
			break
	if is_instance_valid(story):
		story.queue_free()
	await get_tree().process_frame
	GameState.pending_story_queue.clear()

func _advance_to_stop(story: Node, event_id: String) -> bool:
	for _step in range(64):
		if _story_is_leaving(story):
			return false
		var current: Variant = story.get("_current")
		if not current is Dictionary:
			return false
		if str((current as Dictionary).get("id", "")) != event_id:
			return true
		if bool(story.get("_showing_choices")):
			return true
		if bool(story.get("_pending_after_result")):
			return true
		if bool(story.get("_typing")) and story.has_method("_complete_typing"):
			story.call("_complete_typing")
		elif story.has_method("_on_advance"):
			story.call("_on_advance")
		else:
			return false
		await _settle(0.05)
	return true

func _drain_result(story: Node, event_id: String) -> void:
	for _step in range(48):
		if _story_is_leaving(story):
			return
		if bool(story.get("_typing")) and story.has_method("_complete_typing"):
			story.call("_complete_typing")
			await _settle(0.05)
			continue
		var current: Variant = story.get("_current")
		if current is Dictionary \
				and str((current as Dictionary).get("id", "")) != event_id:
			return
		if bool(story.get("_showing_choices")):
			return
		if not bool(story.get("_pending_after_result")):
			return
		if story.has_method("_on_advance"):
			story.call("_on_advance")
		await _settle(0.05)

func _pick_choice(current: Dictionary, event_id: String, story: Node) -> int:
	var choices: Array = current.get("choices", [])
	var wanted := int(_choice_overrides.get(event_id, _default_choice))
	if wanted < 0 or wanted >= choices.size():
		wanted = 0
	# Never report a choice the shipped visibility rule would hide.
	for offset in range(choices.size()):
		var candidate := (wanted + offset) % choices.size()
		if story.has_method("_choice_visible"):
			if bool(story.call("_choice_visible", choices[candidate], candidate)):
				return candidate
		else:
			return candidate
	return 0

func _sub(text: String) -> String:
	return text.replace("{name}", str(GameState.player_name))

## StoryMode composes the on-screen prose (causal frame + memory callbacks +
## route variants) into _paragraphs and never writes it back to
## _current["description"]. Read the paragraphs, or the transcript silently drops
## exactly the callback text this replay exists to judge.
func _story_screen_text(story: Node) -> String:
	var raw: Variant = story.get("_paragraphs")
	if raw is Array and not (raw as Array).is_empty():
		var lines: Array[String] = []
		for paragraph in (raw as Array):
			lines.append(str(paragraph))
		return "\n\n".join(lines)
	return ""

func _print_scene(current: Dictionary, at_turn: int, story: Node) -> void:
	_scene_count += 1
	var event_id := str(current.get("id", ""))
	if event_id not in _played_event_ids:
		_played_event_ids.append(event_id)
		_played_turn_by_event[event_id] = at_turn
	print("")
	print("### [%d] W%d · %s" % [_scene_count, at_turn, event_id])
	print("    title      : %s" % str(current.get("title", "")))
	print("    background : %s" % str(current.get("background", "")))
	print("    portrait   : %s" % str(current.get("portrait", "")))
	print("    speaker    : %s" % str(current.get("speaker", "")))
	print("    ambience   : %s" % str(current.get("ambience", "")))
	var body := _story_screen_text(story)
	if body.is_empty():
		body = _sub(str(current.get("description", "")))
	var authored := _sub(str(current.get("description", "")))
	print("    --- 화면 본문 (%d자, 원고 %d자) ---" % [
		body.length(), authored.length()])
	for line in body.split("\n"):
		print("    | %s" % line)
	var choices: Array = current.get("choices", [])
	if choices.is_empty():
		print("    --- 선택 없음 ---")
		return
	print("    --- 선택 %d개 ---" % choices.size())
	for i in range(choices.size()):
		var choice: Dictionary = choices[i]
		print("    [%d] %s" % [i, _sub(str(choice.get("text", "")))])

func _print_choice_taken(current: Dictionary, idx: int) -> void:
	var choices: Array = current.get("choices", [])
	if idx < 0 or idx >= choices.size():
		return
	_played_choice_by_event[str(current.get("id", ""))] = idx
	var choice: Dictionary = choices[idx]
	print("    >>> 선택 [%d] %s" % [idx, _sub(str(choice.get("text", "")))])
	var result := _sub(str(choice.get("result_text", "")))
	if not result.is_empty():
		print("    --- 결과 (%d자) ---" % result.length())
		for line in result.split("\n"):
			print("    | %s" % line)
	# ORDER-137 moved result presentation onto the choice. Print it so a
	# prose/screen mismatch is visible in the transcript, not only in a render.
	for key in ["result_background", "result_ambience", "result_portrait",
			"result_speaker"]:
		if choice.has(key):
			print("    %s: %s" % [key, str(choice.get(key))])
	var effects: Dictionary = choice.get("effects", {})
	if not effects.is_empty():
		print("    effects: %s" % str(effects))
	var flags: Array = choice.get("flags", [])
	if not flags.is_empty():
		print("    flags: %s" % str(flags))
	var follow_up := str(choice.get("follow_up_event", ""))
	if not follow_up.is_empty():
		print("    follow_up: %s" % follow_up)

## StoryMode._finish_all() hands the tree back to MainGame through
## SceneTransition, which would free this driver mid-run. The shipped QA closes
## its story nodes before that point; here we kill the queued fade callback the
## moment a transition starts and tear the scene down ourselves.
func _cancel_scene_transition() -> void:
	var raw_tween: Variant = SceneTransition.get("_tween")
	if raw_tween is Tween and (raw_tween as Tween).is_valid():
		(raw_tween as Tween).kill()
	SceneTransition.set("_tween", null)

func _story_is_leaving(story: Node) -> bool:
	if not is_instance_valid(story):
		return true
	if bool(story.get("_transitioning")):
		_cancel_scene_transition()
		return true
	return false

func _settle(t: float = 0.1) -> void:
	await get_tree().create_timer(t).timeout
	await get_tree().process_frame


func _release_audio_for_exit() -> void:
	# Headless replay exits immediately after the last choice. Stop and detach
	# pooled streams first so active WAV playbacks do not survive the test tree.
	if BGMPlayer.has_method("stop"):
		BGMPlayer.stop()
	for tween_key in [
		"_fade_tween", "_ambience_tween", "_season_tween",
		"_human_ambience_tween", "_moral_human_tween",
		"_moral_filter_tween",
	]:
		var raw_tween: Variant = BGMPlayer.get(tween_key)
		if raw_tween is Tween and (raw_tween as Tween).is_valid():
			(raw_tween as Tween).kill()
	for player_key in [
		"_player_a", "_player_b", "_ambience_player", "_season_player",
		"_human_ambience_player",
	]:
		var raw_bgm_player: Variant = BGMPlayer.get(player_key)
		if raw_bgm_player is AudioStreamPlayer:
			var bgm_player := raw_bgm_player as AudioStreamPlayer
			bgm_player.stop()
			bgm_player.stream = null
	var raw_pool: Variant = AudioManager.get("_pool")
	if raw_pool is Array:
		for raw_player in raw_pool:
			if raw_player is AudioStreamPlayer:
				var player := raw_player as AudioStreamPlayer
				player.stop()
				player.stream = null
	var raw_sounds: Variant = AudioManager.get("_sounds")
	if raw_sounds is Dictionary:
		(raw_sounds as Dictionary).clear()
	# Playback objects are released on the audio mix thread, not on the same
	# frame that stop()/stream=null runs. Give that thread one bounded drain.
	await get_tree().create_timer(0.25).timeout
	await get_tree().process_frame
	await get_tree().process_frame


func _validate_replay() -> void:
	if not _errors.is_empty():
		return
	_validate_no_reopened_investment_history()
	if _profile == "property":
		_validate_property_replay()
	elif _profile == "general":
		_validate_general_replay()


## The reduced fixture closes these historical investment milestones before W193.
## Seeing one here means the fixture fabricated a Year-1/wealth scene in Year 5.
func _validate_no_reopened_investment_history() -> void:
	var forbidden := {
		"arc_ch1_invest_first_chart": true,
		"arc_almost_there": true,
		"arc_final_stretch": true,
		"arc_gangnam_real_estate_father_passed": true,
	}
	for event_id in _played_event_ids:
		if forbidden.has(event_id):
			_errors.append(
				"selector probe reopened a historical investment scene: %s" \
				% event_id)


func _validate_general_replay() -> void:
	# The rejected human run chose the W195 boundary. Any later romance,
	# proposal, wedding, or hometown chain is counterfeit for this exact profile.
	for event_id in _played_event_ids:
		if event_id == "callback_daeun_committed_gangnam_eve" \
				or event_id.begins_with("arc_daeun_first_night") \
				or event_id.begins_with("arc_daeun_proposal") \
				or event_id.begins_with("arc_daeun_our_home") \
				or event_id.begins_with("arc_daeun_wedding") \
				or event_id.begins_with("arc_daeun_hometown"):
			_errors.append(
				"general selector probe fabricated a blocked romance scene: %s" \
				% event_id)
	var daeun_choice := int(_played_choice_by_event.get(
		"arc_daeun_y5_feelings", -1))
	if int(_played_turn_by_event.get("arc_daeun_y5_feelings", -1)) != 195 \
			or daeun_choice != 1 \
			or not bool(GameState.flags.get("daeun_romance_blocked", false)):
		_errors.append(
			"general selector probe did not preserve the human W195 Daeun boundary")

	var choices_by_source: Dictionary = {}
	for raw_spec in GENERAL_CHOICE_RECEIPTS:
		var spec: Dictionary = raw_spec
		choices_by_source[str(spec.get("source_key", ""))] = \
			_validate_general_choice_receipt(spec)

	var entry_sources: Dictionary = GameState.chapter5_finale_entry_snapshot().get(
		"source_choices", {})
	for source_key in choices_by_source:
		var played_choice := int(choices_by_source[source_key])
		if int(entry_sources.get(source_key, -1)) != played_choice:
			_errors.append(
				"general entry source %s=%s, expected played choice %d" % [
					source_key,
					str(entry_sources.get(source_key, "missing")),
					played_choice,
				])

	var w220_choice := int(choices_by_source.get(
		"w220_debt_memory_reconnect", -1))
	var branch_events: Array[String] = []
	var opposite_branch_events: Array[String] = []
	if w220_choice == 0:
		branch_events = [
			"arc_y5_general_father_legacy_voice_exact",
			"arc_y5_general_debt_memory_voice_exact",
		]
		opposite_branch_events = [
			"arc_y5_general_father_legacy_cafe_exact",
			"arc_y5_general_debt_memory_cafe_exact",
		]
	elif w220_choice == 1:
		branch_events = [
			"arc_y5_general_father_legacy_cafe_exact",
			"arc_y5_general_debt_memory_cafe_exact",
		]
		opposite_branch_events = [
			"arc_y5_general_father_legacy_voice_exact",
			"arc_y5_general_debt_memory_voice_exact",
		]
	else:
		_errors.append("general selector probe did not record an exact W220 choice")
	for opposite_event_id in opposite_branch_events:
		if opposite_event_id in _played_event_ids:
			_errors.append("W220 choice %d also played opposite branch %s" % [
				w220_choice, opposite_event_id])

	# This exact authored spine is the probe's contract. It is a subsequence of
	# selector output, not a claim about all events shown during a shipped week.
	var required_spine: Array[Dictionary] = [
		{"turn": 201, "event_ids": ["arc_minseo_03_arrival"]},
		{"turn": 211, "event_ids": ["arc_y5_general_name_boundary_exact"]},
		{"turn": 220, "event_ids": ["arc_y5_general_debt_memory_reconnect"]},
		{"turn": 224, "event_ids": [branch_events[0]] if not branch_events.is_empty() else []},
		{"turn": 229, "event_ids": [branch_events[1]] if branch_events.size() > 1 else []},
		{"turn": 234, "event_ids": ["arc_y5_general_pre_ending_summit_exact"]},
		{"turn": 237, "event_ids": ["arc_y5_general_final_record_seal"]},
		{"turn": 240, "event_ids": ["arc_final_countdown_general_near_goal_passed"]},
		{"turn": 240, "event_ids": ["arc_y5_final_week_general_people_outbound"]},
	]
	_validate_ordered_authored_spine("general", required_spine)
	print("GENERAL_RECEIPT_COMBO m51=%d w211=%d w220=%d" % [
		int(choices_by_source.get("m51_minseo_arrival", -1)),
		int(choices_by_source.get("w211_name_boundary", -1)),
		w220_choice,
	])


func _validate_general_choice_receipt(spec: Dictionary) -> int:
	var event_id := str(spec.get("event_id", ""))
	var expected_turn := int(spec.get("turn", -1))
	var flag_prefix := str(spec.get("flag_prefix", ""))
	var played_turn := int(_played_turn_by_event.get(event_id, -1))
	var played_choice := int(_played_choice_by_event.get(event_id, -1))
	if played_turn != expected_turn:
		_errors.append("general selector probe played %s at W%d, expected W%d" % [
			event_id, played_turn, expected_turn])
	if played_choice < 0 or played_choice > 1:
		_errors.append("general selector probe lacks a binary choice for %s" % event_id)

	var matching_receipts := 0
	for raw_entry in GameState.event_log:
		if not raw_entry is Dictionary:
			continue
		var entry: Dictionary = raw_entry
		if str(entry.get("event_id", "")) != event_id:
			continue
		matching_receipts += 1
		if int(entry.get("choice_index", -1)) != played_choice \
				or int(entry.get("turn", -1)) != expected_turn:
			_errors.append(
				"general receipt for %s does not match played choice/turn" % event_id)
	if matching_receipts != 1:
		_errors.append("general %s requires one exact runtime receipt, got %d" % [
			event_id, matching_receipts])

	if played_choice == 0 or played_choice == 1:
		if not bool(GameState.flags.get(flag_prefix + str(played_choice), false)):
			_errors.append("general %s did not write selected branch flag %s%d" % [
				event_id, flag_prefix, played_choice])
		var opposite_choice := 1 - played_choice
		if bool(GameState.flags.get(flag_prefix + str(opposite_choice), false)):
			_errors.append("general %s also wrote opposite branch flag %s%d" % [
				event_id, flag_prefix, opposite_choice])
	return played_choice


func _validate_ordered_authored_spine(
		profile_name: String, specs: Array[Dictionary]) -> void:
	var previous_index := -1
	for spec in specs:
		var expected_turn := int(spec.get("turn", -1))
		var event_ids: Array = spec.get("event_ids", [])
		if event_ids.is_empty():
			_errors.append("%s authored spine has an unresolved W%d slot" % [
				profile_name, expected_turn])
			continue
		var matching_ids: Array[String] = []
		for raw_event_id in event_ids:
			var event_id := str(raw_event_id)
			if event_id in _played_event_ids:
				matching_ids.append(event_id)
		if matching_ids.size() != 1:
			_errors.append("%s authored spine W%d matched %d of %s" % [
				profile_name, expected_turn, matching_ids.size(), str(event_ids)])
			continue
		var matched_id := matching_ids[0]
		var actual_turn := int(_played_turn_by_event.get(matched_id, -1))
		if actual_turn != expected_turn:
			_errors.append("%s authored spine played %s at W%d, expected W%d" % [
				profile_name, matched_id, actual_turn, expected_turn])
		var event_index := _played_event_ids.find(matched_id)
		if event_index <= previous_index:
			_errors.append("%s authored spine is out of order at %s" % [
				profile_name, matched_id])
		previous_index = event_index


func _validate_property_replay() -> void:
	# Protect only the known property route sequence. The selector probe does not
	# assert 39/48 density or a four-week gap: random/ambient/full weekly systems
	# are outside this driver and those numbers require the human run.
	var protected_spine: Array[Dictionary] = [
		{"turn": 207, "event_ids": ["arc_y5_final_offer"]},
		{"turn": 217, "event_ids": ["arc_y5_three_in_room"]},
		{"turn": 220, "event_ids": ["arc_y5_room_consent_receipt"]},
		{"turn": 221, "event_ids": ["arc_y5_father_trace_passed_exact"]},
		{"turn": 224, "event_ids": ["arc_y5_father_trace_custody"]},
		{"turn": 227, "event_ids": ["arc_y5_name_on_line_daeun_routed"]},
		{"turn": 230, "event_ids": ["arc_y5_people_verdict_daeun_exact"]},
		{"turn": 235, "event_ids": ["arc_y5_property_not_executed_notice"]},
		{"turn": 238, "event_ids": ["arc_y5_remaining_jaehyuk_or_self"]},
		{"turn": 239, "event_ids": ["arc_y5_final_father_answer_passed"]},
		{"turn": 240, "event_ids": ["arc_final_countdown_property_not_executed"]},
		{"turn": 240, "event_ids": ["arc_y5_final_week_daeun_outbound"]},
	]
	_validate_ordered_authored_spine("property", protected_spine)


func _print_summary() -> void:
	print("\n\n=== AUTHORED SELECTOR PROBE SUMMARY profile=%s ===" % _profile)
	print("scenes            : %d" % _scene_count)
	print("selector root weeks (diagnostic only): %d %s" % [
		_weeks_with_root.size(), str(_weeks_with_root)])
	print("selector-empty weeks (random/ambient not sampled): %d %s" % [
		_weeks_without_root.size(), str(_weeks_without_root)])
	print("selector-only longest gap (not route density): %d" % _longest_empty_run())
	print("played event ids  : %s" % str(_played_event_ids))
	if not _errors.is_empty():
		for err in _errors:
			print("ERROR %s" % err)
	print("HUMAN_REPLAY_REQUIRED profile=%s scope=M49-M60 normal-speed exact-candidate" \
		% _profile)
	print("AUTHORED_SELECTOR_PROBE_DONE profile=%s scenes=%d errors=%d" % [
		_profile, _scene_count, _errors.size()])

func _longest_empty_run() -> int:
	var best := 0
	var run := 0
	for at_turn in range(_from_turn, _to_turn + 1):
		if _weeks_without_root.has(at_turn):
			run += 1
			best = max(best, run)
		else:
			run = 0
	return best
