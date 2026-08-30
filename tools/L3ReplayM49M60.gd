extends Node
## L3 replay transcript driver (throwaway QA harness, never committed).
##
## Walks W193..W240 through the real MainGame weekly priority chain and the real
## StoryMode surface, then prints an ordered, readable transcript of everything a
## player would actually see. It makes real choices through the shipped
## transaction paths; it does not re-implement gating.
##
## Usage:
##   Godot --headless res://tools/L3ReplayM49M60.gd.tscn -- \
##     --profile=property --choices='{"arc_y5_final_offer":2}'

const STORY_MODE_SCENE := "res://scenes/StoryMode.tscn"
const MAIN_GAME_SCRIPT := "res://scenes/MainGame.gd"
const CHAPTER5_CAUSAL_ROUTE := preload("res://systems/Chapter5CausalRoute.gd")
const CHAPTER5_FINALE_ROUTE := preload("res://systems/Chapter5FinaleRoute.gd")

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
var _base_slot := 10
## The reference run's real cash at each chapter boundary. Interpolating between
## two adjacent chapter saves keeps asset-gated arcs firing on the same curve the
## actual 240-week route walked, without re-simulating crises and market rolls.
var _money_from := -1.0
var _money_to := -1.0
var _ambient_weeks: Array[int] = []
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

func _ready() -> void:
	_parse_args()
	_set_language(_lang)
	print("=== L3 REPLAY profile=%s lang=%s turns=%d..%d ===" % [
		_profile, _lang, _from_turn, _to_turn])
	_seed_profile()
	await _walk_weeks()
	_print_summary()
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
		elif arg.begins_with("--base-slot="):
			_base_slot = int(arg.substr(12))
		elif arg.begins_with("--money-from="):
			_money_from = float(arg.substr(13))
		elif arg.begins_with("--money-to="):
			_money_to = float(arg.substr(11))
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

## Both fixtures below mirror the shipped audit fixtures exactly
## (CoreChoiceSliceCheck._prepare_chapter5_product_path and
## ScreenshotQA._prepare_chapter5_general_source_state) so the replay starts from
## the same state the candidate's own evidence used.
func _seed_profile() -> void:
	if _profile == "property":
		_seed_property()
	elif _profile == "general":
		_seed_general()
	elif _profile == "chapter":
		_seed_chapter_walk()
	else:
		_errors.append("unknown profile %s" % _profile)

## A real W193 save carries 192 weeks of "already seen" history. Starting from
## start_new_game() instead re-opens Chapter 1 arcs inside Chapter 5, which would
## make the density read meaningless. Load the genuine chapter-5 save first, then
## overlay only what the target profile requires.
func _load_history_base() -> bool:
	if not SaveManager.load_game(_base_slot):
		_errors.append("could not load history base slot %d" % _base_slot)
		return false
	print("[base] slot=%d turn=%d age=%d money=%.0f route=%s flags=%d" % [
		_base_slot, GameState.turn, GameState.age, GameState.money,
		str(GameState.player_route), GameState.flags.size()])
	return true

## Chapter profiles seed Chapter 5 explicitly. A plain chapter walk keeps the
## loaded run exactly as it was and only moves the calendar.
func _seed_chapter_walk() -> void:
	if not _load_history_base():
		return
	GameState.pending_story_queue = []
	GameState.flags.erase("foreground_story_turn")
	_set_calendar(_from_turn)

func _apply_money_curve(at_turn: int) -> void:
	if _money_from < 0.0 or _money_to < 0.0:
		return
	var span := float(max(1, _to_turn - _from_turn))
	var t := clampf(float(at_turn - _from_turn) / span, 0.0, 1.0)
	GameState.money = _money_from + (_money_to - _money_from) * t

func _seed_property() -> void:
	if not _load_history_base():
		return
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
	for flag_id in [
		"route_career", "route_invest", "route_startup",
		"father_crisis_contact_present",
		"father_crisis_contact_called", "father_crisis_contact_missed",
		"arc_final_countdown_seen", "arc_final_week_seen",
		"final_signature_owned", "final_signature_collateral",
		"final_signature_people",
	]:
		GameState.flags.erase(flag_id)
	GameState.flags["route_invest"] = true
	GameState.flags["father_passed"] = true
	GameState.flags["arc_minseo_03_seen"] = true
	GameState.flags["chapter5_general_minseo_arrival_1"] = true
	# The M51 arrival receipt is the exact W220 source. Append it to the real
	# history log rather than replacing 192 weeks of it.
	GameState.event_log.append(
		{"event_id": "arc_minseo_03_arrival", "choice_index": 1, "turn": 203})
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

## Reproduces the Chapter 5 weekly priority order in MainGame:
## causal route -> finale route -> opening chapter -> arc -> milestone.
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
	if not claimed and game.has_method("_route_opening_chapter_if_pending"):
		game.set_meta("_qa_suppress_opening_chapter_transition", true)
		claimed = bool(game.call("_route_opening_chapter_if_pending"))
	if claimed:
		roots = GameState.pending_story_queue.duplicate()
	else:
		var arc_id := str(game.call("_next_arc_id", -1, false, true))
		if not arc_id.is_empty():
			roots = [arc_id]
		else:
			var ms_id := str(game.call("_next_milestone_id"))
			if not ms_id.is_empty():
				roots = [ms_id]
	game.free()
	# No authored root: MainGame falls through to the ambient month situation
	# before the generic surface. Draw it the same way so the transcript shows
	# what actually fills the week instead of reporting a blank.
	if roots.is_empty() and at_turn > 1:
		var sits: Array = EventManager.draw_situations(1)
		if not sits.is_empty():
			var sit: Dictionary = sits[0]
			var sid := str(sit.get("id", ""))
			if not sid.is_empty():
				EventManager.event_cooldowns[sid] = \
					EventManager.cooldown_for_event(sit)
				_ambient_weeks.append(at_turn)
				roots = [sid]
	return roots

func _walk_weeks() -> void:
	for at_turn in range(_from_turn, _to_turn + 1):
		_set_calendar(at_turn)
		_apply_money_curve(at_turn)
		var roots: Array = await _roots_for_turn(at_turn)
		if roots.is_empty():
			_weeks_without_root.append(at_turn)
			print("\n--- W%d (M%d) · 사건 없음 ---" % [
				at_turn, int((at_turn - 1) / 4) + 1])
			continue
		var is_ambient := _ambient_weeks.has(at_turn)
		if is_ambient:
			_weeks_without_root.append(at_turn)
		else:
			_weeks_with_root.append(at_turn)
		print("\n=========================================================")
		print("W%d (M%d) · %s roots=%s · 자산 %.0f" % [
			at_turn, int((at_turn - 1) / 4) + 1,
			"[앰비언트]" if is_ambient else "[작성]",
			str(roots), GameState.money])
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

func _print_summary() -> void:
	print("\n\n=== L3 REPLAY SUMMARY profile=%s ===" % _profile)
	print("scenes            : %d" % _scene_count)
	print("weeks with a root : %d %s" % [
		_weeks_with_root.size(), str(_weeks_with_root)])
	print("weeks w/o authored: %d %s" % [
		_weeks_without_root.size(), str(_weeks_without_root)])
	print("ambient-filled    : %d %s" % [
		_ambient_weeks.size(), str(_ambient_weeks)])
	print("longest empty run : %d" % _longest_empty_run())
	if not _errors.is_empty():
		for err in _errors:
			print("ERROR %s" % err)
	print("L3_REPLAY_DONE profile=%s scenes=%d" % [_profile, _scene_count])

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
