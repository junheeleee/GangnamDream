extends "res://tools/FullGameRuntimeTrace.gd"
## ORDER-838 D1 — new-story policy runner.
##
## Reuses the product-flow driver in FullGameRuntimeTrace.gd unchanged: fresh
## title, real StoryMode/MainGame controls, keyboard input, no save/flag/money
## injection. The only difference is how a story choice is picked: instead of a
## fixed index per event, a policy scores the *visible* choices from their
## authored effects and wording, with a seeded exploration rate so seeds spread.
##
## Output is the same JSONL trace; `tools/full_story_policy_summary.py` turns a
## set of traces into the ending distribution, M24/M48/M60 assets, gaps and
## decision-free months. This is a measurement tool, not a product gate.

const POLICY_MONEY_UNIT := 100000.0

var _policy_rng := RandomNumberGenerator.new()
var _policy_seeded := false
var _policy_pick_by_occurrence: Dictionary = {}


func _ensure_policy_seed() -> void:
	if _policy_seeded:
		return
	_policy_seeded = true
	_policy_rng.seed = int(_profile.get("seed", 1)) * 7919 + 17


func _choice_policy() -> Dictionary:
	var raw: Variant = _profile.get("choice_policy", {})
	return raw if raw is Dictionary else {}


func _score_choice(choice: Dictionary, policy: Dictionary) -> float:
	var score := 0.0
	var weights: Dictionary = policy.get("effect_weights", {})
	var effects: Variant = choice.get("effects", {})
	if effects is Dictionary:
		for key in (effects as Dictionary).keys():
			var value := float((effects as Dictionary)[key]) if \
					((effects as Dictionary)[key] is float \
					or (effects as Dictionary)[key] is int) else 0.0
			if str(key) == "money":
				value /= POLICY_MONEY_UNIT
			score += float(weights.get(str(key), 0.0)) * value
	var haystack := "%s %s %s" % [
		str(choice.get("text", "")),
		str(choice.get("follow_up_event", "")),
		JSON.stringify(choice.get("flags", [])),
	]
	var keywords: Dictionary = policy.get("keyword_weights", {})
	for word in keywords.keys():
		if haystack.contains(str(word)):
			score += float(keywords[word])
	return score


func _policy_index(current: Dictionary, visible_indices: Array[int]) -> int:
	_ensure_policy_seed()
	if visible_indices.is_empty():
		return -1
	if _policy_pick_by_occurrence.has(_story_occurrence_id):
		var cached := int(_policy_pick_by_occurrence[_story_occurrence_id])
		if cached in visible_indices:
			return cached
	var policy := _choice_policy()
	var choices: Array = current.get("choices", [])
	var pick := visible_indices[0]
	if _policy_rng.randf() < float(policy.get("explore_rate", 0.0)):
		pick = visible_indices[_policy_rng.randi_range(0, visible_indices.size() - 1)]
	else:
		var best := -INF
		for index in visible_indices:
			if index < 0 or index >= choices.size() \
					or not choices[index] is Dictionary:
				continue
			# Tiny seeded jitter breaks exact ties without favouring index 0.
			var value := _score_choice(choices[index], policy) \
					+ _policy_rng.randf() * 0.01
			if value > best:
				best = value
				pick = index
	_policy_pick_by_occurrence[_story_occurrence_id] = pick
	return pick


func _drive_story_choices(story: Node, current: Dictionary) -> void:
	if not _story_occurrence_id.is_empty() \
			and not _story_choice_recorded.has(_story_occurrence_id):
		var visible_indices: Array[int] = []
		for button in _visible_choice_buttons(story):
			visible_indices.append(int(button.get_meta("choice_index", -1)))
		var pick := _policy_index(current, visible_indices)
		if pick >= 0:
			var overrides: Dictionary = _profile.get("choice_overrides", {})
			overrides[str(current.get("id", ""))] = {
				"index": pick, "selection_mode": "policy",
			}
			_profile["choice_overrides"] = overrides
	await super(story, current)


func _drive_story_direct_choice(
		story: Node, current: Dictionary, direct_choice_index: int) -> void:
	if direct_choice_index >= 0:
		var overrides: Dictionary = _profile.get("choice_overrides", {})
		overrides[str(current.get("id", ""))] = {
			"index": direct_choice_index, "selection_mode": "direct",
		}
		_profile["choice_overrides"] = overrides
	await super(story, current, direct_choice_index)


# ── Racetrack activity (keyboard only, like a pad player) ─────────────────
# The base driver presses the first focusable button inside an activity; the
# racetrack betting board is pad/keyboard driven and exposes no focused button,
# so the base stalls there. Drive it with the same ui_accept/ui_cancel keys a
# player uses: accept picks the cursor horse, accept again places the smallest
# stake, accept on the result screen runs another race, cancel leaves.
const RACE_PHASE_BETTING := 0
const RACE_PHASE_RESULT := 2


func _drive_main(main: Node) -> bool:
	if bool(main.get("_minigame_overlay_active")) \
			and str(main.get("_active_activity_id")) == "racetrack" \
			and _active_main_tutorial_overlay(main) == null:
		var track := main.get("racetrack") as Node
		if is_instance_valid(track) and bool(track.get("visible")):
			await _drive_racetrack(track)
			return false
	return await super(main)


func _drive_racetrack(track: Node) -> void:
	var limit := int(_profile.get("race_bets_per_visit", 1))
	var completed := int(track.get("_completed_races"))
	var phase := int(track.get("_phase"))
	var min_stake := 10000.0
	if phase == RACE_PHASE_BETTING:
		if completed >= limit or float(GameState.money) < min_stake:
			await _send_key(KEY_ESCAPE)
		else:
			await _send_key(KEY_ENTER)
	elif phase == RACE_PHASE_RESULT:
		await _send_key(KEY_ESCAPE if completed >= limit else KEY_ENTER)
	# RACE phase: the product animates the race; wait.
	await get_tree().create_timer(0.05).timeout


# ── Watchdog (diagnosis only) ─────────────────────────────────────────────
# The base stall check counts driver steps, so a coroutine that never returns
# (or a surface that keeps changing without progress) can hang a run until the
# outer timeout with no clue. This timer is independent of the driver loop:
# if no trace record lands for WATCHDOG_SECONDS, it writes what the player
# would see (scene, story/main flags, focus, visible buttons) and ends the run.
const WATCHDOG_SECONDS := 300.0
var _watchdog_last_sequence := -1
var _watchdog_quiet := 0.0


func _record_run_start() -> void:
	super()
	var timer := Timer.new()
	timer.wait_time = 30.0
	timer.process_callback = Timer.TIMER_PROCESS_IDLE
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	timer.timeout.connect(_on_policy_watchdog.bind(timer))
	add_child(timer)
	timer.start()


func _on_policy_watchdog(timer: Timer) -> void:
	if _fatal or _shutdown_started:
		timer.stop()
		return
	if _sequence != _watchdog_last_sequence:
		_watchdog_last_sequence = _sequence
		_watchdog_quiet = 0.0
		return
	_watchdog_quiet += timer.wait_time
	if _watchdog_quiet < WATCHDOG_SECONDS:
		return
	timer.stop()
	var diag := _watchdog_snapshot()
	print("FULL_STORY_POLICY_WATCHDOG ", JSON.stringify(diag))
	_record("policy_watchdog", "watchdog:%s" % _profile_id, diag,
		_scene_script_path(get_tree().current_scene))
	_fail("policy watchdog: no trace progress for %ds" % int(WATCHDOG_SECONDS))
	_finish_run(false)


func _watchdog_snapshot() -> Dictionary:
	var scene := get_tree().current_scene
	var out := {
		"scene": _scene_script_path(scene),
		"turn": int(GameState.turn),
		"paused": get_tree().paused,
	}
	if not is_instance_valid(scene):
		return out
	var focus := get_viewport().gui_get_focus_owner()
	out["focus"] = str(scene.get_path_to(focus)) if is_instance_valid(focus) \
			and scene.is_ancestor_of(focus) else ("<outside>" if is_instance_valid(focus) else "")
	var flags := {}
	for key in ["_transitioning", "_story_scene_transition_active",
			"_direction_hold_active", "_direction_beat_waiting", "_showing_choices",
			"_pending_after_result", "_typing", "_para_index", "_read_only_replay",
			"_dialogue_log_event_serial", "_modal_kind", "_minigame_overlay_active",
			"_active_activity_id", "pending_result_text"]:
		var value: Variant = scene.get(key)
		if value != null:
			flags[key] = str(value).left(120)
	var current: Variant = scene.get("_current")
	if current is Dictionary:
		flags["_current.id"] = str((current as Dictionary).get("id", ""))
	var paragraphs: Variant = scene.get("_paragraphs")
	if paragraphs is Array:
		flags["_paragraphs.size"] = (paragraphs as Array).size()
	out["flags"] = flags
	var buttons: Array = []
	_watchdog_buttons(scene, scene, buttons)
	out["visible_buttons"] = buttons
	return out


func _watchdog_buttons(scene: Node, node: Node, out: Array) -> void:
	if out.size() >= 24:
		return
	if node is CanvasItem and not (node as CanvasItem).is_visible_in_tree():
		return
	if node is BaseButton:
		var button := node as BaseButton
		out.append({
			"path": str(scene.get_path_to(button)).right(90),
			"text": str(button.get("text")).left(40),
			"disabled": button.disabled,
			"usable": _button_is_usable(button) if button is Button else false,
		})
	for child in node.get_children():
		_watchdog_buttons(scene, child, out)
