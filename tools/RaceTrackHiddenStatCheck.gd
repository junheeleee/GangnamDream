extends Node
## ORDER-840 G1 regression: addiction is a hidden stat. In a full run the
## racetrack HUD and its result warning never print the addiction level as a
## number or gauge; the habit shows in the hands instead. The approved demo
## keeps its gauge.

const FLOW := preload("res://systems/FullStoryFlow.gd")
const TRACK := preload("res://scenes/RaceTrack.gd")

var _failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	var language := str(LocaleManager.language)
	LocaleManager.set_language("ko")
	await _check(true, 82)
	await _check(true, 45)
	await _check(true, 10)
	await _check(false, 82)
	var source := FileAccess.get_file_as_string("res://scenes/RaceTrack.gd")
	var warn_at := source.find("'딱 한 번만 더'")
	var gate_at := source.rfind("FULL_STORY_FLOW.is_full_run()", warn_at)
	_expect(warn_at > 0 and gate_at > 0 and warn_at - gate_at < 400,
		"the result warning with the addiction number is not gated to the demo")
	GameState.flags.erase(FLOW.STATE_KEY)
	LocaleManager.set_language(language)
	if not _failures.is_empty():
		for failure in _failures:
			push_error("RACETRACK_HIDDEN_STAT_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("RACETRACK_HIDDEN_STAT_CHECK_OK full=3 demo=1 warning_gate=1")
	get_tree().quit(0)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _check(full_run: bool, addiction: int) -> void:
	GameState.start_new_game()
	GameState.flags.erase(FLOW.STATE_KEY)
	if full_run:
		GameState.flags[FLOW.STATE_KEY] = {"profile": FLOW.PROFILE_FULL}
	GameState.addiction_tendency = addiction
	var track: Control = TRACK.new()
	add_child(track)
	await get_tree().process_frame
	track.call("_refresh_top")
	var hud: String = str((track.get("_hud") as RichTextLabel).text)
	if full_run:
		_expect(not hud.contains("중독") and not hud.contains("/100") and not hud.contains("▰"),
			"full run addiction %d shows a gauge: %s" % [addiction, hud])
		_expect(hud.contains("손가락") == (addiction >= 40 and addiction < 70),
			"addiction %d hand line mismatch: %s" % [addiction, hud])
	else:
		_expect(hud.contains("%d/100" % addiction), "the demo lost its gauge: %s" % hud)
	track.queue_free()
	await get_tree().process_frame
