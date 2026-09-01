extends Node
## Throwaway play driver for the story demo human-play review (never committed).
##
## Boots alongside the shipped StoryChoiceM1M6Playtest scene and plays it with
## real injected input only - the same Input.parse_input_event() path the
## shipped route QA uses. No auto-advance, no skip, no direct calls into
## StoryMode's advance functions: every page turn and every choice is a key
## press, and every distinct beat is captured to PNG.
##
## env:
##   STORY_DEMO_PLAY_ROUTE = clean | restitution | escalation
##   STORY_DEMO_PLAY_OUT   = output directory
##   STORY_DEMO_PLAY_LANG  = ko (default) | en | ja | zh-CN | zh-TW
##   STORY_DEMO_PLAY_STOP  = optional beat cap

const CONTROLLER_SCRIPT := "res://playtests/order124/StoryChoiceM1M6Playtest.gd"
const STORY_SCRIPT := "res://scenes/StoryMode.gd"

var _route := "clean"
var _out := "/private/tmp/sd_play"
var _lang := "ko"
var _stop := 4000

var _shots := 0
var _beats := 0
var _log: Array[String] = []
var _seen_key := ""
var _last_event := ""
var _inputs := 0
var _choice_log: Array[Dictionary] = []
var _black_frames: Array[String] = []
var _transitions: Array[Dictionary] = []
var _route_done := false
var _quit_after := 0
var _resume_mode := false

## Exact per-route choice indices, transcribed from the shipped controller's
## _real_flow_expected_records(). Anything not listed falls back to the route
## default so an unexpected rail is still answered and reported.
func _choice_for(event_id: String) -> int:
	var m := {}
	match _route:
		"clean":
			m = {
				"arc_temptation_01": 0, "arc_temptation_clean": 0,
				"arc_daeun_01_meet": 0, "arc_jiyeon_01_crash": 0,
				"arc_jaehyuk_01_reunion": 0, "order124_m6_first_bill": 0,
			}
		"restitution":
			m = {
				"arc_temptation_01": 1, "arc_temptation_fallout": 0,
				"arc_daeun_01_meet": 0, "arc_jiyeon_01_crash": 0,
				"arc_jaehyuk_01_reunion": 0,
				"v2_dirty_trace_initial_call": 0, "order124_m6_first_bill": 0,
			}
		"escalation":
			m = {
				"arc_temptation_01": 1, "arc_temptation_fallout": 1,
				"arc_daeun_01_meet": 1, "arc_jiyeon_01_crash": 0,
				"arc_jaehyuk_01_reunion": 1,
				"v2_dirty_recruiter_week24": 0, "order124_m6_first_bill": 3,
			}
	if m.has(event_id):
		return int(m[event_id])
	return 1 if _route == "escalation" else 0

func _ready() -> void:
	_route = _env("STORY_DEMO_PLAY_ROUTE", "clean")
	_out = _env("STORY_DEMO_PLAY_OUT", "/private/tmp/sd_play")
	_lang = _env("STORY_DEMO_PLAY_LANG", "ko")
	_stop = int(_env("STORY_DEMO_PLAY_STOP", "4000"))
	_quit_after = int(_env("STORY_DEMO_PLAY_QUIT_AFTER", "0"))
	_resume_mode = _env("STORY_DEMO_PLAY_RESUME", "0") == "1"
	DirAccess.make_dir_recursive_absolute(_out)
	_say("=== STORY DEMO PLAY route=%s lang=%s ===" % [_route, _lang])
	call_deferred("_run")

func _env(key: String, fallback: String) -> String:
	var v := OS.get_environment(key).strip_edges()
	return v if not v.is_empty() else fallback

func _say(line: String) -> void:
	print(line)
	_log.append(line)

func _controller() -> Node:
	return _find_by_script(get_tree().root, CONTROLLER_SCRIPT)

func _story() -> Node:
	return _find_by_script(get_tree().root, STORY_SCRIPT)

func _find_by_script(node: Node, path: String) -> Node:
	var s := node.get_script() as Script
	if s != null and s.resource_path == path:
		return node
	for child in node.get_children():
		var hit := _find_by_script(child, path)
		if hit != null:
			return hit
	return null

# ---------------------------------------------------------------- real input
func _key(keycode: Key) -> void:
	var press := InputEventKey.new()
	press.keycode = keycode
	press.physical_keycode = keycode
	press.pressed = true
	Input.parse_input_event(press)
	await get_tree().process_frame
	var release := press.duplicate() as InputEventKey
	release.pressed = false
	Input.parse_input_event(release)
	await get_tree().process_frame
	_inputs += 1
	await _settle(0.12)

func _settle(t: float) -> void:
	await get_tree().create_timer(t).timeout
	await get_tree().process_frame

## A player waits for the fade to finish before pressing again. Without this the
## driver hammers a covered shell button and reports meaningless input counts.
func _transition_busy() -> bool:
	var alpha: Variant = SceneTransition.get("_transition_alpha")
	if alpha is float and float(alpha) > 0.02:
		return true
	var story := _story()
	return story != null and (bool(story.get("_transitioning")) \
		or bool(story.get("_story_scene_transition_active")))

## Sample the screen *while* the fade runs. A cover that goes fully black, or
## one that overstays, is exactly the defect this review is asked to find, and
## waiting it out silently would hide both.
func _wait_for_transition() -> void:
	if not _transition_busy():
		return
	var start := Time.get_ticks_msec()
	var darkest := 1.0
	var frames := 0
	for _i in range(400):
		if not _transition_busy():
			break
		frames += 1
		if frames % 3 == 1:
			darkest = minf(darkest, _screen_brightness())
		await _settle(0.05)
	var ms := Time.get_ticks_msec() - start
	_transitions.append({
		"ms": ms, "darkest": darkest, "after": _last_event})
	if ms > 1500 or darkest < 0.02:
		_say("    [transition] %dms darkest=%.3f after=%s%s" % [
			ms, darkest, _last_event,
			"  << 지연/암전 의심" if (ms > 1500 or darkest < 0.02) else ""])

func _screen_brightness() -> float:
	var tex := get_viewport().get_texture()
	if tex == null:
		return 1.0
	var img := tex.get_image()
	var size := img.get_size()
	var best := 0.0
	for y in range(0, size.y, 40):
		for x in range(0, size.x, 40):
			var c := img.get_pixel(x, y)
			best = maxf(best, (c.r + c.g + c.b) / 3.0)
	return best

# ------------------------------------------------------------------ capture
func _shot(tag: String) -> void:
	await _settle(0.2)
	for _i in range(3):
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
	var tex := get_viewport().get_texture()
	if tex == null:
		return
	var img := tex.get_image()
	_shots += 1
	var name := "%s_%03d_%s.png" % [_route, _shots, tag]
	img.save_png(_out.path_join(name))
	# A black or near-black frame is a defect this review exists to catch.
	var bright := 0.0
	var size := img.get_size()
	for y in range(0, size.y, 24):
		for x in range(0, size.x, 24):
			var c := img.get_pixel(x, y)
			bright = maxf(bright, (c.r + c.g + c.b) / 3.0)
	if bright < 0.06:
		_black_frames.append(name)
		_say("    !! BLACK FRAME %s (max=%.3f)" % [name, bright])

func _run() -> void:
	await _settle(1.0)
	var ctl := _controller()
	if ctl == null:
		_say("FAIL: story demo controller not found")
		_finish(1)
		return
	_say("[boot] controller=%s public=%s" % [
		ctl.name, str(ctl.get_meta("story_demo_public", false))])
	await _shot("boot")
	await _drive()
	_finish(0)

## Walk the app the way a player does: press accept, look at what changed,
## answer any rail that appears, and never call the scene's own advance.
func _drive() -> void:
	var idle := 0
	for step in range(_stop):
		var story := _story()
		if story != null:
			var current: Variant = story.get("_current")
			if current is Dictionary and not (current as Dictionary).is_empty():
				idle = 0
				await _observe(story, current as Dictionary)
				continue
		# No story on screen: this is the controller shell / language gate.
		await _wait_for_transition()
		if _story() != null:
			continue
		var handled := await _press_focused_or_first()
		if handled:
			idle = 0
		else:
			idle += 1
			await _key(KEY_ENTER)
		if idle > 40:
			_say("[end] no progress for 40 steps; stopping")
			return

func _observe(story: Node, current: Dictionary) -> void:
	var event_id := str(current.get("id", ""))
	var key := "%d:%s:%s:%s" % [
		story.get_instance_id(), event_id,
		str(story.get("_para_index")), str(story.get("_showing_choices"))]
	if key != _seen_key:
		_seen_key = key
		if event_id != _last_event and not event_id.is_empty():
			_last_event = event_id
			_beats += 1
			_say("")
			_say("### [%d] %s" % [_beats, event_id])
			_say("    STATE turn=%d month=%d week=%d cash=%.0f health=%d mental=%d flags=%d" % [
				GameState.turn, GameState.month, GameState.week_of_month,
				GameState.money, GameState.health, GameState.mental,
				GameState.flags.size()])
			_say("    bg=%s portrait=%s speaker=%s" % [
				str(current.get("background", "")),
				str(current.get("portrait", "")),
				str(current.get("speaker", ""))])
			var paras: Variant = story.get("_paragraphs")
			if paras is Array:
				for p in (paras as Array):
					_say("    | %s" % str(p))
			await _shot("%s_open" % event_id)
			if _quit_after > 0 and _beats >= _quit_after:
				_say("[quit] stopping mid-run after beat %d for the resume test"
					% _beats)
				_finish(0)
				return
	if bool(story.get("_showing_choices")):
		await _answer(story, current, event_id)
		return
	# Never let AUTO advance for us: this review is a manual read.
	if bool(story.get("_auto_mode")) and story.has_method("_set_auto_mode"):
		story.call("_set_auto_mode", false, false)
		_say("    [driver] AUTO was on; forced off")
	await _wait_for_transition()
	await _key(KEY_ENTER)

func _answer(story: Node, current: Dictionary, event_id: String) -> void:
	var choices: Array = current.get("choices", [])
	var want := _choice_for(event_id)
	if want >= choices.size():
		want = 0
	_say("    --- 선택 %d개 ---" % choices.size())
	for i in range(choices.size()):
		_say("    [%d] %s" % [i, str((choices[i] as Dictionary).get("text", ""))])
	await _shot("%s_choices" % event_id)
	# Move focus with real arrow keys, then accept. No direct _on_choice call.
	var box := story.get("_choice_box") as Control
	var buttons: Array[Button] = []
	if box != null:
		_collect_buttons(box, buttons)
	var focused := -1
	for i in range(buttons.size()):
		if buttons[i].has_focus():
			focused = i
	if focused < 0 and not buttons.is_empty():
		buttons[0].grab_focus()
		await get_tree().process_frame
		focused = 0
	var guard := 0
	while focused != want and focused >= 0 and guard < 12:
		await _key(KEY_DOWN if want > focused else KEY_UP)
		guard += 1
		focused = -1
		for i in range(buttons.size()):
			if is_instance_valid(buttons[i]) and buttons[i].has_focus():
				focused = i
	_say("    >>> 선택 [%d] %s" % [
		want, str((choices[want] as Dictionary).get("text", ""))])
	_choice_log.append({"event": event_id, "index": want})
	await _key(KEY_ENTER)
	await _settle(0.3)
	await _shot("%s_result" % event_id)
	var shown: Variant = story.get("_paragraphs")
	if shown is Array:
		for p in (shown as Array):
			_say("    R| %s" % str(p))

func _shell_text_lines(node: Node) -> Array[String]:
	var out: Array[String] = []
	_gather_labels(node, out)
	return out

func _gather_labels(node: Node, out: Array[String]) -> void:
	if node is Label and (node as Label).visible:
		var t := str((node as Label).text).strip_edges()
		if not t.is_empty():
			out.append(t)
	for c in node.get_children():
		_gather_labels(c, out)

func _collect_buttons(node: Node, out: Array[Button]) -> void:
	if node is Button and (node as Button).visible:
		out.append(node as Button)
	for c in node.get_children():
		_collect_buttons(c, out)

func _press_focused_or_first() -> bool:
	var ctl := _controller()
	if ctl == null:
		return false
	var buttons: Array[Button] = []
	_collect_buttons(ctl, buttons)
	if buttons.is_empty():
		return false
	var live: Array[Button] = []
	for b in buttons:
		if not b.disabled and b.visible and b.is_visible_in_tree():
			live.append(b)
	if live.is_empty():
		return false
	var target: Button = null
	if _resume_mode:
		for b in live:
			if b.text.contains("이어하기") or b.text.contains("Continue"):
				target = b
				_say("[resume] pressing %s (enabled=%s)" % [b.text, str(not b.disabled)])
	for b in live:
		if target == null and b.has_focus():
			target = b
	if target == null:
		target = live[0]
		target.grab_focus()
		await get_tree().process_frame
	# The recap screen ("여섯 달의 흔적") is the demo's closing statement of what
	# was chosen and what was given up. Capture it and stop there rather than
	# looping home -> continue forever.
	var title_node: Variant = ctl.get("_title")
	var title_text := ""
	if title_node is Label:
		title_text = str((title_node as Label).text)
	var sub_node: Variant = ctl.get("_subtitle")
	var sub_text := ""
	if sub_node is Label:
		sub_text = str((sub_node as Label).text)
	if title_text.contains("여섯 달의 흔적") or title_text.contains("What Six Months Left"):
		await _shot("recap")
		_say("[recap] %s / %s" % [title_text, sub_text])
		for line in _shell_text_lines(ctl):
			_say("    RECAP| %s" % line)
		_route_done = true
		return false
	await _shot("shell_%s" % target.text.substr(0, 14).replace(" ", "_"))
	_say("[shell] %s | %s" % [title_text, target.text])
	for line in _shell_text_lines(ctl):
		_say("    S| %s" % line)
	await _key(KEY_ENTER)
	return true

func _finish(code: int) -> void:
	_say("")
	_say("=== SUMMARY route=%s ===" % _route)
	_say("beats=%d shots=%d inputs=%d choices=%d black_frames=%d" % [
		_beats, _shots, _inputs, _choice_log.size(), _black_frames.size()])
	for b in _black_frames:
		_say("  BLACK %s" % b)
	var slow := 0
	var dark := 0
	var worst := 0
	for t in _transitions:
		if int(t["ms"]) > 1500:
			slow += 1
		if float(t["darkest"]) < 0.02:
			dark += 1
		worst = maxi(worst, int(t["ms"]))
	_say("transitions=%d slow(>1.5s)=%d fully_dark=%d worst=%dms" % [
		_transitions.size(), slow, dark, worst])
	var f := FileAccess.open(_out.path_join("%s_transcript.txt" % _route),
		FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(_log))
	print("STORY_DEMO_PLAY_DONE route=%s beats=%d shots=%d" % [
		_route, _beats, _shots])
	get_tree().quit(code)
