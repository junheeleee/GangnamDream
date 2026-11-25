extends Node
## ORDER-836 M1 regression: body/mind band scenes fire on a drop, once per band
## per chapter, never reuse a scene, respect the job premise, survive a JSON
## save round trip, and a steady slide to 0 always shows a danger scene first.

const BODY := preload("res://systems/BodyBandScenes.gd")

var _failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	_check_bands()
	_check_transitions()
	_check_job_premise()
	_check_json_round_trip()
	_check_slide_warns_before_collapse()
	_check_events_resolve()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("BODY_BAND_SCENES_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("BODY_BAND_SCENES_CHECK_OK bands=4 transitions=8 job=7 json=1 slides=2 events=9")
	get_tree().quit(0)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _exists(_event_id: String) -> bool:
	return true


func _take(flags: Dictionary, health: float, mental: float, turn: int,
		has_job: bool = false) -> String:
	return BODY.take_scene(flags, {"health": health, "mental": mental}, turn,
		has_job, _exists)


func _check_bands() -> void:
	_expect(BODY.band_of(60) == BODY.BAND_STABLE and BODY.band_of(59) == BODY.BAND_CAUTION
		and BODY.band_of(40) == BODY.BAND_CAUTION and BODY.band_of(39) == BODY.BAND_DANGER
		and BODY.band_of(20) == BODY.BAND_DANGER and BODY.band_of(19) == BODY.BAND_COLLAPSE
		and BODY.band_of(0) == BODY.BAND_COLLAPSE, "band thresholds drifted")


func _check_transitions() -> void:
	var flags := {}
	_expect(_take(flags, 65, 60, 2) == "", "stable start played a scene")
	_expect(_take(flags, 55, 60, 3) == "health_sleep_debt", "health caution did not speak")
	_expect(_take(flags, 55, 60, 4) == "", "same band spoke twice")
	_expect(_take(flags, 35, 60, 5) == "health_checkup_00", "unemployed health danger did not speak")
	# Recover and fall again inside the same chapter: no second danger scene.
	_expect(_take(flags, 70, 60, 6) == "" and _take(flags, 35, 60, 7) == "",
		"danger repeated within one chapter")
	# Next chapter: the band speaks again with an unused scene.
	_expect(_take(flags, 70, 60, 50) == "" and _take(flags, 35, 60, 51) == "health_burnout_signal",
		"next chapter did not use a fresh danger scene")
	# Danger scenes exhausted: the warning still speaks, oldest first, then rotates.
	_expect(_take(flags, 70, 60, 98) == "" and _take(flags, 35, 60, 99) == "health_checkup_00",
		"exhausted danger band went silent or reused the newest scene")
	_expect(_take(flags, 70, 60, 146) == "" and _take(flags, 35, 60, 147) == "health_burnout_signal",
		"reused danger scene did not rotate")


func _check_job_premise() -> void:
	var with_job := {}
	_take(with_job, 65, 60, 2, true)
	_expect(_take(with_job, 35, 60, 3, true) == "work_burnout_monday",
		"employed danger skipped the workplace scene")
	_expect(_take(with_job, 70, 60, 50, true) == "" and _take(with_job, 35, 60, 51, true) == "drama_burnout_warning",
		"employed second danger skipped the overtime scene")
	var no_job := {}
	for week in range(2, 240, 47):
		_take(no_job, 70, 60, week, false)
		var scene := _take(no_job, 35, 60, week + 1, false)
		_expect(not scene in BODY.NEEDS_JOB, "unemployed run got a workplace scene: " + scene)


func _check_json_round_trip() -> void:
	var flags := {}
	_take(flags, 65, 60, 2)
	_take(flags, 55, 60, 3)
	var loaded: Dictionary = JSON.parse_string(JSON.stringify(flags))
	_expect(_take(loaded, 55, 60, 4) == "" and _take(loaded, 35, 60, 5) == "health_checkup_00",
		"state lost its meaning after a JSON save/load")


func _check_slide_warns_before_collapse() -> void:
	# D1 burnout shapes: 48->1 over 91 weeks and 52->1 over 67 weeks, with
	# arcs owning two of every three weeks. A danger scene must come first.
	for slide: Array in [[65.0, 1.0, 91], [65.0, 1.0, 67]]:
		var flags := {}
		var danger_seen := false
		var start := float(slide[0])
		var weeks := int(slide[2])
		for week in range(2, weeks + 2):
			var health := start - (start - float(slide[1])) * float(week - 2) / float(weeks - 1)
			if week % 3 != 0:
				continue  # an arc owns this week
			var scene := _take(flags, health, 60, week)
			if scene in (BODY.SCENES["health"] as Dictionary)[BODY.BAND_DANGER]:
				danger_seen = true
			if health < 1.5:
				break
		_expect(danger_seen, "a %d-week slide reached collapse without a danger scene" % weeks)


func _check_events_resolve() -> void:
	var count := 0
	for stat: String in BODY.STATS:
		for band in (BODY.SCENES[stat] as Dictionary).keys():
			for event_id: String in (BODY.SCENES[stat] as Dictionary)[band]:
				count += 1
				var event: Dictionary = DataRegistry.find_event(event_id)
				_expect(not event.is_empty() and (event.get("choices", []) as Array).size() >= 2,
					"body scene %s is missing or has no decision" % event_id)
	_expect(count == 9, "body scene table changed size (%d)" % count)
