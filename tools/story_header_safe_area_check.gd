extends Node
## Graphical, fixture-assisted regression check. A pre-autoload bootstrap must
## select a fresh StoryDemo RuntimeQA namespace before this Node is created.
## Earlier months use controller QA, not an end-to-end player-input claim.

const CONTROLLER := preload("res://playtests/order124/StoryChoiceM1M6Playtest.tscn")
const CONTROLLER_PATH := "res://playtests/order124/StoryChoiceM1M6Playtest.tscn"
const STORY_PATH := "res://scenes/StoryMode.tscn"
const M6 := "order124_m6_first_bill"
const SIZES := [Vector2i(1280, 800), Vector2i(1280, 720), Vector2i(960, 600)]
const SURFACES := ["home", "language", "home_resized", "story_body",
	"five_choices", "settings", "settings_return", "history", "history_return", "recap"]

var _out := ""
var _lang := ""
var _size := Vector2i.ZERO
var _controller: Node = null
var _failures: Array[String] = []
var _captures: Array[Dictionary] = []
var _inputs: Array[Dictionary] = []
var _fixture: Array[Dictionary] = []
var _boundaries: Array[Dictionary] = []
var _geometry: Array[Dictionary] = []
var _modal_results: Array[Dictionary] = []
var _resize_results: Array[Dictionary] = []
var _started := 0
var _finished := false

func _ready() -> void:
	_started = Time.get_ticks_msec()
	call_deferred("_run")

func _process(_delta: float) -> void:
	var active := get_tree().current_scene
	if is_instance_valid(active) and active.scene_file_path == CONTROLLER_PATH:
		_controller = active
		_controller.call("qa_set_auto_launch", false)

func _run() -> void:
	_out = OS.get_environment("ORDER315_OUT")
	_lang = OS.get_environment("ORDER315_LANG")
	var raw_size := OS.get_environment("ORDER315_SIZE").split("x")
	if raw_size.size() == 2:
		_size = Vector2i(int(raw_size[0]), int(raw_size[1]))
	var qa_namespace := str(ProjectSettings.get_setting("application/config/custom_user_dir_name", ""))
	var namespace_pattern := RegEx.new()
	namespace_pattern.compile("^GangnamDream_StoryDemo_RuntimeQA_[0-9a-f]{32}$")
	if not _out.is_absolute_path() or not DirAccess.dir_exists_absolute(_out) \
			or _lang not in ["ko", "en"] or _size not in SIZES \
			or DisplayServer.get_name() == "headless" \
			or namespace_pattern.search(qa_namespace) == null \
			or OS.get_user_data_dir() != OS.get_environment("ORDER315_EXPECTED_USER_PATH"):
		_fail("invalid graphical launch, output, locale, size, or pre-autoload isolation")
	for argument in OS.get_cmdline_user_args():
		if "smoke" in argument or "screenshot" in argument:
			_fail("another product automation must not run beside the header check")
	if not _failures.is_empty():
		await _finish()
		return
	_boundary_tests()
	DisplayServer.window_set_size(_size)
	await _frames(12)
	_controller = CONTROLLER.instantiate()
	get_tree().root.add_child(_controller)
	get_tree().current_scene = _controller
	_controller.call("qa_set_auto_launch", false)
	_expect(bool(_controller.call("qa_set_language", _lang)), "locale setup failed")
	await _capture("home", _size)
	if _failures.is_empty():
		await _language_surface()
	if _failures.is_empty():
		await _resize_shell()
	if _failures.is_empty():
		_expect(bool(_controller.call("qa_start_new_run")), "fixture start failed")
		for month in range(1, 6):
			if not _fixture_month(month):
				break
	if _failures.is_empty():
		_fixture.append({"boundary": "M06 transition", "state": _state()})
		await _frames(8)
		await _tap(KEY_ENTER, "launch actual M06 through focused transition button")
		await _reach_choices()
	if _failures.is_empty():
		await _tap(KEY_DOWN, "select non-default second choice")
		await _tap(KEY_DOWN, "select non-default third choice")
		_expect(_choice_focus_index() == 2, "non-default choice 2 was not focused")
		await _capture("five_choices", _size)
	if _failures.is_empty():
		await _modal_roundtrip("settings", KEY_F10, "_audio_settings_popup")
	if _failures.is_empty():
		await _modal_roundtrip("history", KEY_X, "_dialogue_log_popup")
	if _failures.is_empty():
		await _tap(KEY_UP, "return to second choice")
		await _tap(KEY_UP, "return to first choice")
		_expect(_choice_focus_index() == 0, "first choice was not focused before commit")
		await _tap(KEY_ENTER, "commit first M06 choice exactly once")
		await _reach_recap()
	if _failures.is_empty():
		await _capture("recap", _size)
		var ending := _state()
		_expect(int(ending.get("current_month", 0)) == 7 \
			and int(ending.get("monthly_pressure_count", 0)) == 6 \
			and int(ending.get("turn", 0)) == 25, "final month/settlement/turn mismatch")
		var receipt: Dictionary = ending.get("receipts", {})
		_expect(bool(receipt.get("order124_choice__%s__0" % M6, false)), "M06 selected receipt missing")
		for index in range(1, 5):
			_expect(not bool(receipt.get("order124_choice__%s__%d" % [M6, index], false)),
				"unselected M06 receipt was applied")
	for surface in SURFACES:
		var found := false
		for capture in _captures:
			found = found or str(capture.get("surface", "")) == surface
		_expect(found, "missing surface: %s" % surface)
	await _finish()

func _language_surface() -> void:
	var language_button: Control = _controller.get("_language_button")
	await _focus_by_tab(language_button)
	await _tap(KEY_ENTER, "open shell language selector")
	_expect(str(_controller.call("qa_screen")) == "language", "language selector did not open")
	await _capture("language", _size)
	var home_button: Control = _controller.get("_home_button")
	await _focus_by_tab(home_button)
	await _tap(KEY_ENTER, "close shell language selector without language mutation")
	_expect(str(_controller.call("qa_screen")) == "home" \
		and LocaleManager.language == _lang, "language selector did not return unchanged")

func _resize_shell() -> void:
	var old_title: Control = _controller.get("_title")
	var old_focus := get_viewport().gui_get_focus_owner()
	var old_compact := bool(_controller.get("_compact"))
	var before := old_title.get_global_rect()
	var wider := Vector2i(_size.x + 160, _size.y)
	DisplayServer.window_set_size(wider)
	await _capture("home_resized", wider)
	var after := old_title.get_global_rect()
	var preserved := _controller.get("_title") == old_title \
		and get_viewport().gui_get_focus_owner() == old_focus \
		and bool(_controller.get("_compact")) == old_compact
	_expect(preserved, "same-compact horizontal resize rebuilt title/focus/state")
	_expect(after.position.x > before.position.x + 1.0,
		"horizontal resize did not update safe horizontal margin")
	_resize_results.append({"from_output": [_size.x, _size.y], "to_output": [wider.x, wider.y],
		"same_title_focus_compact": preserved, "before_title": _rect_array(before),
		"after_title": _rect_array(after), "logical_size": _vector_array(get_viewport().get_visible_rect().size)})
	DisplayServer.window_set_size(_size)
	await _frames(40)
	_audit_header("home_resize_restored")
	_expect(_controller.get("_title") == old_title \
		and get_viewport().gui_get_focus_owner() == old_focus,
		"restoring width rebuilt title or changed focus")

func _fixture_month(month: int) -> bool:
	if not _failures.is_empty():
		return false
	if int(_controller.call("qa_current_month")) != month:
		_fail("fixture wrong month %d" % month)
		return false
	for _guard in range(8):
		var schedule: Dictionary = _controller.call("qa_schedule")
		var remaining: Array = schedule.get("current_event_ids", [])
		if remaining.is_empty():
			var closed: Dictionary = _controller.call("qa_close_month", month)
			_expect(bool(closed.get("closed", false)), "fixture close failed M%d" % month)
			_fixture.append({"closed_month": month, "state": _state()})
			return bool(closed.get("closed", false))
		var event_id := str(remaining[0])
		var index := 1 if event_id == "arc_daeun_01_meet" else 0
		var result: Dictionary = _controller.call("qa_choose_current", index)
		_fixture.append({"event_id": event_id, "choice_index": index,
			"applied": result.get("applied", false), "method": "earlier-month controller QA fixture"})
		if not bool(result.get("applied", false)):
			_fail("fixture choice rejected: %s" % event_id)
			return false
	_fail("fixture guard M%d" % month)
	return false

func _reach_choices() -> void:
	var body_captured := false
	for _guard in range(1800):
		if not _guard_ok():
			return
		var story := _story()
		if story == null or _blocked(story):
			await _frames(3)
			continue
		var event: Dictionary = story.get("_current")
		_expect(str(event.get("id", "")) == M6, "unexpected event before five-choice surface")
		if bool(story.get("_typing")):
			await _tap(KEY_ENTER, "complete current prose through synthetic key")
			continue
		if bool(story.get("_showing_choices")):
			await _frames(40)
			_audit_story_content("five_choices")
			return
		await _frames(40)
		if _blocked(story) or bool(story.get("_showing_choices")):
			continue
		_audit_story_content("M06 prose page")
		if not body_captured:
			await _capture("story_body", _size)
			body_captured = true
		await _tap(KEY_ENTER, "advance M06 prose through synthetic key")
	_fail("M06 choice wait guard")

func _modal_roundtrip(surface: String, open_key: Key, popup_property: String) -> void:
	var story := _story()
	var selected := get_viewport().gui_get_focus_owner()
	var before := JSON.stringify(GameState.serialize(), "", true)
	var before_phase := _story_phase()
	await _tap(open_key, "open %s from selected choice 2" % surface)
	_expect(is_instance_valid(story.get(popup_property)), "%s did not open" % surface)
	await _capture(surface, _size)
	await _tap(KEY_ENTER, "%s modal confirm must not commit underlying story choice" % surface)
	await _frames(6)
	_expect(JSON.stringify(GameState.serialize(), "", true) == before,
		"%s confirm mutated gameplay behind modal" % surface)
	await _tap(KEY_ESCAPE, "close %s and restore selected choice" % surface)
	await _frames(8)
	var restored := not is_instance_valid(story.get(popup_property)) \
		and get_viewport().gui_get_focus_owner() == selected \
		and _choice_focus_index() == 2
	var state_unchanged := JSON.stringify(GameState.serialize(), "", true) == before
	var phase_unchanged := _story_phase() == before_phase
	_expect(restored, "%s did not restore exact selected choice node" % surface)
	_expect(state_unchanged and phase_unchanged, "%s changed choice/prose/gameplay state" % surface)
	_modal_results.append({"surface": surface, "selected_choice": 2,
		"exact_focus_restored": restored, "gameplay_unchanged": state_unchanged,
		"story_phase_unchanged": phase_unchanged, "phase": before_phase})
	await _capture("%s_return" % surface, _size)

func _reach_recap() -> void:
	for _guard in range(1800):
		if not _guard_ok():
			return
		var story := _story()
		if story == null:
			if is_instance_valid(_controller) and get_tree().current_scene == _controller \
					and str(_controller.call("qa_screen")) == "recap":
				var overlay: Dictionary = _controller.call("qa_transition_overlay_state")
				if float(overlay.get("alpha", 1.0)) < 0.001 \
						and not bool(overlay.get("blocks_input", true)):
					return
			await _frames(3)
			continue
		if _blocked(story):
			await _frames(3)
			continue
		if bool(story.get("_showing_choices")):
			_fail("unexpected second multi-choice decision after M06 commit")
			return
		await _tap(KEY_ENTER, "advance chosen result or direct ledger continuation")
	_fail("recap wait guard")

func _capture(surface: String, output_size: Vector2i) -> void:
	await _frames(40)
	_audit_header(surface)
	if _story() != null and surface not in ["settings", "history"]:
		_audit_story_content(surface)
	await RenderingServer.frame_post_draw
	var screenshot := get_viewport().get_texture().get_image()
	if screenshot == null:
		_fail("no viewport image: %s" % surface)
		return
	var path := _out.path_join("%02d_%s.png" % [_captures.size() + 1, surface])
	if FileAccess.file_exists(path) or screenshot.save_png(path) != OK:
		_fail("refused screenshot overwrite/write: %s" % path)
		return
	_expect(screenshot.get_size() == output_size, "raw PNG output size mismatch: %s" % surface)
	var labels: Array[Dictionary] = []
	_collect_visible(get_tree().current_scene, labels)
	_captures.append({"surface": surface, "file": path.get_file(), "path": path,
		"output_size": [screenshot.get_width(), screenshot.get_height()],
		"expected_output": [output_size.x, output_size.y],
		"logical_size": _vector_array(get_viewport().get_visible_rect().size),
		"safe_rect": _rect_array(_safe_rect()), "visible_labels": labels,
		"focus": _focus_snapshot(), "story": _story_phase(), "state": _state(),
		"synthetic_key_edges": _inputs.size()})
	_write_report(false)
	print("STORY_HEADER_SAFE_AREA_CAPTURE language=%s surface=%s path=%s" % [_lang, surface, path])

func _audit_header(context: String) -> void:
	var active := get_tree().current_scene
	if not is_instance_valid(active):
		_fail("missing active scene at %s" % context)
		return
	var fields: Array[String] = ["_title", "_subtitle", "_home_button", "_language_button"]
	if active.scene_file_path == STORY_PATH:
		fields = ["_hud_label", "_dialogue_log_button", "_audio_settings_button"]
	var controls: Array[Control] = []
	var visible_fields: Array[String] = []
	var items: Array[Dictionary] = []
	for field in fields:
		var control: Control = active.get(field)
		if not is_instance_valid(control):
			_fail("header field absent: %s" % field)
			continue
		var expected_visible := true
		if active.scene_file_path == CONTROLLER_PATH:
			if field == "_home_button":
				expected_visible = context in ["language", "recap"]
			elif field == "_language_button":
				expected_visible = context != "language"
		_expect(control.is_visible_in_tree() == expected_visible,
			"%s header visibility changed: %s" % [context, field])
		if not control.is_visible_in_tree():
			continue
		controls.append(control)
		visible_fields.append(field)
		var rect := control.get_global_rect()
		var measured := _text_measure(control)
		items.append({"field": field, "rect": _rect_array(rect), "text": str(control.get("text")),
			"measured_text": _vector_array(measured), "alpha": _effective_alpha(control)})
		_expect(_rect_inside_safe(rect, _safe_rect()), "%s %s exceeds safe area: %s" % [context, field, rect])
		_expect(_inside_clipping_ancestors(control), "%s header clips at an ancestor: %s" % [context, field])
		_expect(measured.x <= control.size.x + 1.0 and measured.y <= control.size.y + 1.0,
			"%s header text clips: %s" % [context, field])
	for first in range(controls.size()):
		for second in range(first + 1, controls.size()):
			_expect(not controls[first].get_global_rect().intersects(controls[second].get_global_rect()),
				"%s header controls overlap: %s/%s" % [context, visible_fields[first], visible_fields[second]])
	_geometry.append({"context": context, "safe_rect": _rect_array(_safe_rect()), "headers": items})

func _audit_story_content(context: String) -> void:
	var story := _story()
	if story == null:
		return
	var body: RichTextLabel = story.get("_body_lbl")
	if body.is_visible_in_tree():
		_expect(get_viewport().get_visible_rect().encloses(body.get_global_rect()) \
			and _inside_clipping_ancestors(body), "%s body outside viewport/clipped by ancestor" % context)
		_expect(body.get_content_height() <= body.size.y + 1.0, "%s body text height clipped" % context)
	if not bool(story.get("_showing_choices")):
		return
	var choices: Control = story.get("_choice_box")
	var buttons: Array[Button] = []
	for candidate in choices.find_children("*", "Button", true, false):
		if (candidate as Button).is_visible_in_tree():
			buttons.append(candidate as Button)
	_expect(buttons.size() == 5, "%s expected five visible M06 choices" % context)
	for index in range(buttons.size()):
		var button := buttons[index]
		_expect(int(button.get_meta("choice_index", -1)) == index, "choice index/order mismatch")
		_expect(_rect_inside_safe(button.get_global_rect(), _safe_rect()) \
			and _inside_clipping_ancestors(button), "choice %d outside safe area/clipped" % index)
		var style := button.get_theme_stylebox("normal")
		var inner := button.size - Vector2(style.get_content_margin(SIDE_LEFT) + style.get_content_margin(SIDE_RIGHT),
			style.get_content_margin(SIDE_TOP) + style.get_content_margin(SIDE_BOTTOM))
		var font := button.get_theme_font("font")
		var measured := font.get_multiline_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT,
			maxf(1.0, inner.x), button.get_theme_font_size("font_size"))
		_expect(measured.y <= inner.y + 1.0, "choice %d text height clipped" % index)
		_expect(_effective_alpha(button) >= 0.99, "choice %d captured before reveal settled" % index)
		if index > 0:
			_expect(not button.get_global_rect().intersects(buttons[index - 1].get_global_rect()), "choice buttons overlap")
	_expect(_choice_focus_index() >= 0, "five-choice surface lacks selected focus")

func _text_measure(control: Control) -> Vector2:
	var font := control.get_theme_font("font")
	var font_size := control.get_theme_font_size("font_size")
	var text_value := str(control.get("text"))
	var measured := font.get_multiline_string_size(text_value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	if control is Button:
		var style := control.get_theme_stylebox("normal")
		measured += Vector2(style.get_content_margin(SIDE_LEFT) + style.get_content_margin(SIDE_RIGHT),
			style.get_content_margin(SIDE_TOP) + style.get_content_margin(SIDE_BOTTOM))
	return measured

func _boundary_tests() -> void:
	var safe := Rect2(32, 20, 1216, 760)
	for entry in [
		["exact_edges", safe, true], ["interior", Rect2(40, 28, 100, 40), true],
		["left_1px", Rect2(31, 20, 100, 40), false],
		["top_1px", Rect2(32, 19, 100, 40), false],
		["right_1px", Rect2(1149, 20, 100, 40), false],
		["bottom_1px", Rect2(32, 741, 100, 40), false],
		["old_story_settings", Rect2(1172, 4, 94, 40), false],
		["old_shell_title", Rect2(20, 20, 400, 30), false],
	]:
		var actual := _rect_inside_safe(entry[1], safe)
		_boundaries.append({"name": entry[0], "actual": actual, "expected": entry[2],
			"rect": _rect_array(entry[1]), "safe_rect": _rect_array(safe)})
		_expect(actual == bool(entry[2]), "safe rectangle boundary self-test: %s" % entry[0])
	for entry in [["touching_edges", Rect2(132, 20, 100, 40), false],
		["one_pixel_overlap", Rect2(131, 20, 100, 40), true]]:
		var actual := Rect2(32, 20, 100, 40).intersects(entry[1])
		_boundaries.append({"name": entry[0], "actual": actual, "expected": entry[2]})
		_expect(actual == bool(entry[2]), "header overlap boundary self-test: %s" % entry[0])

func _safe_rect() -> Rect2:
	var viewport_size := get_viewport().get_visible_rect().size
	return Rect2(viewport_size * 0.025, viewport_size * 0.95)

func _rect_inside_safe(rect: Rect2, safe: Rect2) -> bool:
	return rect.size.x > 0.0 and rect.size.y > 0.0 and safe.grow(0.01).encloses(rect)

func _inside_clipping_ancestors(control: Control) -> bool:
	var ancestor := control.get_parent()
	while ancestor != null:
		if ancestor is Control and (ancestor as Control).clip_contents \
				and not (ancestor as Control).get_global_rect().grow(0.01).encloses(control.get_global_rect()):
			return false
		ancestor = ancestor.get_parent()
	return true

func _effective_alpha(item: CanvasItem) -> float:
	var alpha := item.self_modulate.a
	var ancestor: Node = item
	while ancestor != null:
		if ancestor is CanvasItem:
			alpha *= (ancestor as CanvasItem).modulate.a
		ancestor = ancestor.get_parent()
	return alpha

func _collect_visible(node: Node, output: Array[Dictionary]) -> void:
	if node is CanvasItem and not (node as CanvasItem).is_visible_in_tree():
		return
	if node is Label or node is RichTextLabel or node is Button:
		var control := node as Control
		output.append({"path": str(node.get_path()), "text": str(node.get("text")),
			"rect": _rect_array(control.get_global_rect()), "alpha": _effective_alpha(control)})
	for child in node.get_children():
		_collect_visible(child, output)

func _story() -> Node:
	var active := get_tree().current_scene
	return active if is_instance_valid(active) and active.scene_file_path == STORY_PATH else null

func _blocked(story: Node) -> bool:
	return bool(story.get("_transitioning")) or bool(story.get("_story_scene_transition_active")) \
		or bool(story.get("_direction_hold_active")) or bool(story.get("_direction_beat_waiting"))

func _story_phase() -> Dictionary:
	var story := _story()
	if story == null:
		return {}
	var event: Dictionary = story.get("_current")
	return {"event_id": event.get("id", ""), "paragraph": story.get("_para_index"),
		"typing": story.get("_typing"), "choices": story.get("_showing_choices"),
		"result": story.get("_pending_after_result"), "result_choice": story.get("_pending_result_choice_index")}

func _choice_focus_index() -> int:
	var focused := get_viewport().gui_get_focus_owner()
	return int(focused.get_meta("choice_index", -1)) if is_instance_valid(focused) else -1

func _focus_snapshot() -> Dictionary:
	var focused := get_viewport().gui_get_focus_owner()
	return {"path": str(focused.get_path()), "choice_index": focused.get_meta("choice_index", -1)} \
		if is_instance_valid(focused) else {}

func _focus_by_tab(target: Control) -> void:
	for _guard in range(16):
		if get_viewport().gui_get_focus_owner() == target:
			return
		await _tap(KEY_TAB, "navigate to visible shell control")
	_fail("tab navigation did not reach requested shell control")

func _tap(code: Key, purpose: String) -> void:
	for pressed in [true, false]:
		var before := _focus_snapshot()
		var event := InputEventKey.new()
		event.keycode = code
		event.pressed = pressed
		event.echo = false
		Input.parse_input_event(event)
		_inputs.append({"sequence": _inputs.size() + 1, "keycode": int(code), "pressed": pressed,
			"purpose": purpose, "method": "Input.parse_input_event synthetic",
			"focus_before": before, "focus_after": _focus_snapshot(), "story": _story_phase()})
		await _frames(2)

func _state() -> Dictionary:
	var result := {"turn": GameState.turn, "money": GameState.money,
		"health": GameState.health, "mental": GameState.mental, "receipts": {}}
	for key in GameState.flags:
		if str(key).begins_with("order124_choice__"):
			result["receipts"][str(key)] = GameState.flags[key]
	if is_instance_valid(_controller):
		var session: Dictionary = _controller.call("qa_session_snapshot")
		for key in ["current_month", "phase", "elapsed_weeks", "monthly_pressure_count", "choices", "settlements"]:
			if session.has(key):
				result[key] = session[key]
	return result

func _rect_array(rect: Rect2) -> Array:
	return [rect.position.x, rect.position.y, rect.size.x, rect.size.y]

func _vector_array(value: Vector2) -> Array:
	return [value.x, value.y]

func _guard_ok() -> bool:
	if Time.get_ticks_msec() - _started > 180000:
		_fail("180 second overall guard")
	return _failures.is_empty()

func _frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame

func _expect(condition: bool, reason: String) -> void:
	if not condition:
		_fail(reason)

func _fail(reason: String) -> void:
	_failures.append(reason)
	push_error("STORY_HEADER_SAFE_AREA_CHECK_FAIL %s" % reason)

func _write_report(complete: bool) -> void:
	if not _out.is_absolute_path() or not DirAccess.dir_exists_absolute(_out):
		return
	var report := {"language": _lang, "requested_output": [_size.x, _size.y], "complete": complete,
		"pass": complete and _failures.is_empty(),
		"claim": "graphical geometry and synthetic input; earlier-month fixtures; not visual taste, native reader, human or physical controller approval",
		"user_dir": OS.get_user_data_dir(), "failures": _failures, "captures": _captures,
		"geometry": _geometry, "boundary_cases": _boundaries, "resize": _resize_results,
		"modal_roundtrips": _modal_results, "inputs": _inputs, "fixture_operations": _fixture,
		"final_state": _state(), "milliseconds": Time.get_ticks_msec() - _started}
	var file := FileAccess.open(_out.path_join("telemetry.json"), FileAccess.WRITE)
	if file == null:
		_fail("could not write telemetry")
		return
	file.store_string(JSON.stringify(report, "\t"))
	file.close()

func _finish() -> void:
	if _finished:
		return
	_finished = true
	_write_report(true)
	if not is_instance_valid(_controller):
		var story := _story()
		if story != null:
			get_tree().current_scene = null
			story.queue_free()
			await _frames(2)
			_controller = CONTROLLER.instantiate()
			get_tree().root.add_child(_controller)
			_controller.call("qa_set_auto_launch", false)
			(_controller as Control).hide()
	if is_instance_valid(_controller):
		await _controller.call("qa_cleanup_transient_story_runtime")
	await _frames(3)
	if _failures.is_empty():
		print("STORY_HEADER_SAFE_AREA_CHECK_OK language=%s size=%dx%d" % [_lang, _size.x, _size.y])
	else:
		print("STORY_HEADER_SAFE_AREA_CHECK_FAILED language=%s failures=%d" % [_lang, _failures.size()])
	get_tree().quit(0 if _failures.is_empty() else 1)
