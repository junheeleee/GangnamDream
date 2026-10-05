extends "res://tools/RoutineBackgroundContextCheck.gd"
## ORDER-456: prepared legacy/internal entry, real GUI keyboard delivery only.
## Parent utilities supply two authored fixtures, preparation and isolation;
## its callback/echo suite and accelerated tween helpers are never invoked.

const CASE_IDS456 := ["general_w230_save0", "general_w216_rest5"]
var _report456: Dictionary = {}
var _case456: Dictionary = {}
var _recording456: bool = false
var _report_path456: String = ""
var _screens_path456: String = ""

func _run() -> void:
	Engine.max_fps = 60
	var language: String = OS.get_environment("ROUTINE_INPUT_LOCALE")
	_report_path456 = OS.get_environment("ROUTINE_INPUT_REPORT_PATH")
	_screens_path456 = OS.get_environment("ROUTINE_INPUT_SCREENSHOT_DIR")
	_report456 = {"unit": "ORDER-456", "locale": language, "cases": [],
		"failures": [], "raw_events": [], "taps": [], "pressed": [],
		"boundary_pressed": [], "receipts": [], "pngs": [],
		"claim": "prepared legacy/internal synthetic keyboard; not natural play or physical pad"}
	if not _validate_isolation():
		get_tree().quit(1)
		return
	_report456["isolation_before"] = OS.get_user_data_dir()
	if language not in ["ko", "en"] or not _report_path456.is_absolute_path() \
			or not _screens_path456.is_absolute_path() \
			or not DirAccess.dir_exists_absolute(_screens_path456) \
			or not DirAccess.dir_exists_absolute(_report_path456.get_base_dir()):
		_fail("runner locale/output paths refused")
		get_tree().quit(1)
		return
	LocaleManager.set_language(language)
	SaveManager.set_setting("story_text_size", "standard")
	_connect_signals456()
	get_tree().node_added.connect(_node_added456)
	for wanted_id in CASE_IDS456:
		var fixture: Dictionary = {}
		for candidate in FIXTURES:
			if str(candidate["id"]) == wanted_id:
				fixture = candidate.duplicate(true)
		if fixture.is_empty():
			_fail("declared fixture missing")
			break
		await _play_input456(language, fixture)
		if _failures > 0:
			break
	_recording456 = false
	await _remove_game()
	# Teardown is after observations; killing remaining ambient/audio tweens here
	# is not evidence that a result transition naturally finished.
	await _stop_audio()
	_report456["isolation_after"] = OS.get_user_data_dir()
	_report456["pass"] = _failures == 0 and _report456["cases"].size() == 2
	var report_file := FileAccess.open(_report_path456, FileAccess.WRITE)
	if report_file == null:
		_fail("report write failed")
	else:
		report_file.store_string(JSON.stringify(_report456, "\t"))
		report_file.close()
	if _failures == 0:
		print("ROUTINE_BACKGROUND_INPUT_CHECK_OK cases=2 raw=12 taps=6 pressed=2 receipts=2 screenshots=2 locale=%s" % language)
	else:
		print("ROUTINE_BACKGROUND_INPUT_CHECK_FAIL failures=%d locale=%s" % [_failures, language])
	get_tree().quit(0 if _failures == 0 else 1)

func _typed456(value: Variant) -> Dictionary:
	var result: Dictionary = {"type": type_string(typeof(value))}
	if value is Dictionary:
		var items: Dictionary = {}
		for key in value:
			items[str(key)] = _typed456(value[key])
		result["value"] = items
	elif value is Array:
		var items: Array = []
		for item in value:
			items.append(_typed456(item))
		result["value"] = items
		result["typed_builtin"] = value.get_typed_builtin()
	elif value is PackedStringArray:
		result["value"] = Array(value)
	else:
		result["value"] = value
	return result

func _snapshot456() -> Dictionary:
	return {"game": _typed456(GameState.serialize()), "extra": _typed456({
		"pending_tint_vignette": GameState.pending_tint_vignette,
		"pending_scar_vignette": GameState.pending_scar_vignette,
		"unlocked_stat_thresholds": GameState.unlocked_stat_thresholds,
		"turn_action_log": _game.get("turn_action_log") if is_instance_valid(_game) else []}),
		"meta": _typed456({"data": MetaProgression.data, "new_this_run": MetaProgression.get("_new_this_run")}),
		"event": _typed456({"current_event": EventManager.current_event,
			"narrative_bridge_results": EventManager.narrative_bridge_results})}

func _rect456(value: Rect2) -> Array:
	return [value.position.x, value.position.y, value.size.x, value.size.y]

func _focus456() -> Dictionary:
	var owner: Control = get_viewport().gui_get_focus_owner()
	if not is_instance_valid(owner):
		return {"valid": false}
	var owned: bool = is_instance_valid(_game) and _game.is_ancestor_of(owner)
	return {"valid": true, "owned": owned, "path": str(owner.get_path()),
		"instance_id": owner.get_instance_id(), "name": str(owner.name),
		"button": owner is Button, "visible": owner.is_visible_in_tree(),
		"queued": owner.is_queued_for_deletion(), "focus_mode": owner.focus_mode,
		"disabled": (owner as Button).disabled if owner is Button else true,
		"index": int(owner.get_meta("ap_grid_index", -1)),
		"action": str(owner.get_meta("demo_action_id", "")),
		"result_confirm": bool(owner.get_meta("ap_result_confirm", false))}

func _focus_is456(index: int, action: String) -> bool:
	var row: Dictionary = _focus456()
	_case456["focus_trace"].append(row)
	var okay: bool = bool(row.get("valid", false)) and bool(row.get("owned", false)) \
		and bool(row.get("button", false)) and bool(row.get("visible", false)) \
		and not bool(row.get("queued", true)) and not bool(row.get("disabled", true)) \
		and int(row.get("focus_mode", 0)) != Control.FOCUS_NONE \
		and int(row.get("index", -1)) == index and str(row.get("action", "")) == action
	_expect(okay, "actual live native focus did not match expected card %d/%s" % [index, action])
	return okay

func _input(event: InputEvent) -> void:
	if _recording456 and event is InputEventKey:
		var key := event as InputEventKey
		var row: Dictionary = {"keycode": int(key.keycode), "physical_keycode": int(key.physical_keycode),
			"pressed": key.pressed, "echo": key.echo, "ticks_usec": Time.get_ticks_usec(),
			"focus": _focus456()}
		_case456["raw_events"].append(row)
		_report456["raw_events"].append(row.duplicate(true))

func _tap456(code: Key) -> void:
	var row: Dictionary = {"keycode": int(code), "before": _focus456(), "started_usec": Time.get_ticks_usec()}
	for down in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = down
		event.echo = false
		Input.parse_input_event(event)
		await get_tree().process_frame
	await get_tree().process_frame
	row["after"] = _focus456()
	row["finished_usec"] = Time.get_ticks_usec()
	_case456["taps"].append(row)
	_report456["taps"].append(row.duplicate(true))

func _signal456(name: String, args: Array = []) -> void:
	if _recording456:
		_case456["signals"].append({"name": name, "args": _typed456(args), "ticks_usec": Time.get_ticks_usec()})

func _connect_signals456() -> void:
	GameState.stats_changed.connect(func(): _signal456("stats_changed"))
	GameState.money_changed.connect(func(value): _signal456("money_changed", [value]))
	GameState.moral_tint_changed.connect(func(norm, stage): _signal456("moral_tint_changed", [norm, stage]))
	GameState.weekly_commitment_finalized.connect(func(record): _signal456("weekly_commitment_finalized", [record]))
	GameState.log_added.connect(func(entry): _signal456("log_added", [entry]))
	GameState.turn_advanced.connect(func(turn): _signal456("turn_advanced", [turn]))
	GameState.stat_threshold_crossed.connect(func(stat, threshold): _signal456("stat_threshold_crossed", [stat, threshold]))
	GameState.tendency_awakened.connect(func(kind): _signal456("tendency_awakened", [kind]))
	SaveManager.save_completed.connect(func(okay, slot): _signal456("save_completed", [okay, slot]))
	SaveManager.load_completed.connect(func(okay, slot): _signal456("load_completed", [okay, slot]))

func _pressed456(action: String, index: int) -> void:
	var row: Dictionary = {"action": action, "index": index, "ticks_usec": Time.get_ticks_usec()}
	_case456["pressed"].append(row)
	_report456["pressed"].append(row.duplicate(true))

func _node_added456(node: Node) -> void:
	if node is Button and bool(node.get_meta("ap_result_confirm", false)) \
			and is_instance_valid(_game) and _game.is_ancestor_of(node):
		(node as Button).pressed.connect(_boundary_pressed456.bind("result_confirm", str(node.get_path())))

func _boundary_pressed456(kind: String, path: String) -> void:
	if _recording456:
		var row: Dictionary = {"kind": kind, "path": path, "ticks_usec": Time.get_ticks_usec()}
		_case456["boundary_pressed"].append(row)
		_report456["boundary_pressed"].append(row.duplicate(true))

func _running456(value: Variant) -> bool:
	return value is Tween and value.is_valid() and value.is_running()

func _settled456() -> Dictionary:
	var body: RichTextLabel = _game.get("event_body") as RichTextLabel
	return {"typing": _running456(_game.get("_typing_tween")),
		"fade": _running456(_game.get("_event_bg_fade_tween")),
		"commit": _running456(_game.get("_ap_commit_tween")),
		"milestone": bool(_game.get("_milestone_portrait_active")),
		"visible_ratio": body.visible_ratio, "ticks_usec": Time.get_ticks_usec()}

func _wait_natural456() -> Dictionary:
	var started: int = Time.get_ticks_usec()
	var consecutive: int = 0
	var last: Dictionary = {}
	while Time.get_ticks_usec() - started < 15_000_000:
		await get_tree().process_frame
		last = _settled456()
		if not last["typing"] and not last["fade"] and not last["commit"] \
				and not last["milestone"] and float(last["visible_ratio"]) >= 1.0:
			consecutive += 1
			if consecutive == 3:
				last["elapsed_usec"] = Time.get_ticks_usec() - started
				return last
		else:
			consecutive = 0
	_fail("natural typing/fade/finite milestone wait timed out")
	last["elapsed_usec"] = Time.get_ticks_usec() - started
	return last

func _surface456() -> Dictionary:
	var node: TextureRect = _game.get("event_bg") as TextureRect
	return {"background_id": str(_game.get("_event_bg_id")),
		"texture": node.texture.resource_path if node.texture != null else "",
		"visible": node.is_visible_in_tree(), "alpha": node.modulate.a,
		"target_alpha": float(_game.call("_event_bg_target_alpha")),
		"ambience": str(BGMPlayer.get("_current_ambience_key")), "rect": _rect456(node.get_global_rect())}

func _play_input456(language: String, fixture: Dictionary) -> void:
	await _remove_game()
	_context = "%s/%s" % [language, fixture["id"]]
	_case456 = {"id": fixture["id"], "fixture": fixture.duplicate(true),
		"preparation_before": _snapshot456(), "focus_trace": [], "cards": [],
		"raw_events": [], "taps": [], "pressed": [], "boundary_pressed": [],
		"signals": [], "errors": []}
	_report456["cases"].append(_case456)
	_seed_state(fixture)
	_case456["prepared_seeded"] = _snapshot456()
	_game = MAIN_GAME_SCENE.instantiate() as Control
	_game.set_meta("_screenshot_qa_static_surface", true)
	add_child(_game)
	await _wait_frames(5)
	_game.call("_render_ap_actions")
	await _wait_frames(4)
	_case456["ready_settled"] = await _wait_natural456()
	var pressure: Dictionary = _game.call("_demo_week_pressure")
	_case456["pressure"] = pressure.duplicate(true)
	_expect(str(pressure.get("id", "")) == str(fixture["pressure"]), "prepared pressure mismatch")
	var actions: Array = ["side_shift", "study", "save"] if fixture["action"] == "save" else ["contact", "side_shift", "rest"]
	var cards: Array = _game.get("_ap_grid_cards")
	_expect(cards.size() == 3, "prepared actual card count differs")
	for index in range(cards.size()):
		var button: Button = cards[index] as Button
		if not is_instance_valid(button):
			_fail("actual card is not a Button")
			return
		var action: String = str(button.get_meta("demo_action_id", ""))
		_case456["cards"].append({"index": int(button.get_meta("ap_grid_index", -1)),
			"action": action, "path": str(button.get_path()), "instance_id": button.get_instance_id(),
			"disabled": button.disabled, "visible": button.is_visible_in_tree(),
			"focus_mode": button.focus_mode, "rect": _rect456(button.get_global_rect())})
		_expect(index < actions.size() and action == actions[index], "actual action order differs")
		button.pressed.connect(_pressed456.bind(action, index))
	_case456["ready_before"] = _snapshot456()
	var next_button: Button = _game.get("next_button") as Button
	_expect(is_instance_valid(next_button), "actual next button missing")
	if is_instance_valid(next_button):
		next_button.pressed.connect(_boundary_pressed456.bind("next_button", str(next_button.get_path())))
	if _failures > 0 or not _focus_is456(0, actions[0]):
		return
	_recording456 = true
	await _tap456(KEY_RIGHT)
	if not _focus_is456(1, actions[1]):
		_recording456 = false
		return
	await _tap456(KEY_RIGHT)
	if not _focus_is456(2, actions[2]):
		_recording456 = false
		return
	var roll_seed: int = _find_roll_seed(str(fixture["action"]), int(fixture["index"]))
	_expect(roll_seed >= 0, "prepared random seed not found")
	seed(roll_seed)
	var draw1: int = randi()
	var draw2: int = randi() if fixture["action"] == "save" else -1
	var saved: int = 30000 + draw1 % 70000 if fixture["action"] == "save" else 0
	var chosen: int = draw2 % 5 if fixture["action"] == "save" else draw1 % 10
	_case456["roll"] = {"seed": roll_seed, "draw1": draw1, "draw2": draw2, "saved": saved, "index": chosen}
	seed(roll_seed)
	await _tap456(KEY_ENTER)
	_case456["settled"] = await _wait_natural456()
	_case456["after"] = _snapshot456()
	_recording456 = false
	var record: Dictionary = GameState.get_weekly_commitment_for_turn(int(fixture["turn"]))
	_case456["receipt"] = record.duplicate(true)
	if not record.is_empty():
		_report456["receipts"].append(record.duplicate(true))
	_expect(record.get("choice_id", "") == fixture["action"], "receipt action mismatch")
	var details: Dictionary = record.get("details", {})
	_expect(details.get("receipt_prose_ko", "") == fixture["ko"], "receipt Korean source mismatch")
	_expect(details.get("receipt_prose_en", "") == fixture["en"], "receipt English source mismatch")
	_expect(record.get("scene_background_id", "") == fixture["expected_background"], "receipt settled place mismatch")
	_expect(_case456["raw_events"].size() == 6 and _case456["taps"].size() == 3, "raw input population differs")
	_expect(_case456["pressed"].size() == 1, "action button was not pressed exactly once")
	_expect(_case456["boundary_pressed"].is_empty(), "result confirm or next-week button received input")
	_expect(GameState.action_points == 0 and GameState.turn == int(fixture["turn"]), "AP or turn differs")
	_expect(not _game.has_meta("_qa_scene_first_advance_requested"), "confirm leaked into next-week request")
	_expect_surface(str(fixture["expected_background"]), str(fixture["expected_ambience"]))
	_case456["surface"] = _surface456()
	var body: RichTextLabel = _game.get("event_body") as RichTextLabel
	_case456["body"] = {"raw": body.text, "parsed": body.get_parsed_text(),
		"visible_ratio": body.visible_ratio, "rect": _rect456(body.get_global_rect()),
		"content_height": body.get_content_height(), "line_count": body.get_line_count(),
		"title": str((_game.get("event_title") as Label).text)}
	_expect(body.get_parsed_text().contains(str(fixture[language])), "visible body lacks selected authored prose")
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	var png_path: String = _screens_path456.path_join("%s-%s.png" % [language, fixture["id"]])
	_expect(image.get_width() == 1280 and image.get_height() == 800, "capture resolution differs")
	var saved_png: Error = image.save_png(png_path)
	_expect(saved_png == OK, "PNG write failed")
	_case456["png"] = png_path
	_report456["pngs"].append(png_path)

func _fail(message: String) -> void:
	_failures += 1
	var text: String = "[%s] %s" % [_context, message]
	if not _report456.is_empty():
		_report456["failures"].append(text)
	if not _case456.is_empty():
		_case456["errors"].append(text)
	push_error("ROUTINE_BACKGROUND_INPUT_CHECK_FAIL %s" % text)
