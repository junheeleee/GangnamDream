extends Node
## Timing/state only. Headless execution is not pixel, rhythm, or hearing approval.
## Invoke through StoryNameplateBootstrap; this check never enters MainGame.

const OPENING := preload("res://scenes/OpeningCinematic.tscn")
const COPY := [
	["2026년, 서울.", "강남. 부와 지위가 주소가 되는 곳.\n아파트 한 채, 30억원.",
		"2026. Seoul.", "Gangnam. Where wealth becomes status.\nOne apartment: KRW 3 billion."],
	["김민준, 서른셋.", "통장 50만원. 월세 65만원짜리 고시원.",
		"Kim Minjun, 33.", "Bank balance: KRW 500K.\nA goshiwon room costs KRW 650K a month."],
	["목표 30억원. 남은 시간은 5년.", "첫 주가 시작된다.",
		"KRW 3 billion. Five years left.", "The first week begins."],
]
# Below the smallest old/new consumer difference (rule: 0.52*.75 - 0.44*.75 = .06).
const CURVE_TOLERANCE_SECONDS := 0.045
const MAX_SAMPLE_GAP_SECONDS := 0.10
var _failures: Array[String] = []
var _baseline := false
var _fades: Array = []
var _holds: Array = []
var _rows: Array = []
var _dispatch: Array = []
var _sfx_max_active := 0


func _ready() -> void:
	call_deferred("_run")


func _expect(condition: bool, message: String) -> void:
	if not condition and not _failures.has(message):
		_failures.append(message)


func _run() -> void:
	var qa_namespace: String = OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	if not qa_namespace.begins_with("GangnamDream_StoryNameplateQA_") or OS.get_user_data_dir().get_file() != qa_namespace:
		push_error("OPENING_RHYTHM_CHECK_FAIL pre-autoload isolation missing")
		get_tree().quit(1)
		return
	_baseline = "--opening-baseline" in OS.get_cmdline_user_args()
	_fades = [0.52, 0.52, 0.52] if _baseline else [0.44, 0.76, 0.36]
	_holds = [3.10, 3.10, 3.00] if _baseline else [2.80, 3.50, 2.90]
	var opening_script: Script = load("res://scenes/OpeningCinematic.gd")
	var constants: Dictionary = opening_script.get_script_constant_map()
	var beats: Array = constants.get("BEATS", [])
	_expect(beats.size() == 3, "source beat population")
	_expect(is_equal_approx(float(constants.get("FADE_SECONDS", -1.0)), 0.52), "fallback constant")
	for index in range(mini(3, beats.size())):
		_expect(is_equal_approx(float(beats[index].get("hold", -1.0)), float(_holds[index])), "source hold %d" % index)
		for pair in [["title_ko", 0], ["body_ko", 1], ["title_en", 2], ["body_en", 3]]:
			_expect(beats[index].get(pair[0]) == COPY[index][pair[1]], "source copy %d/%s" % [index, pair[0]])
	var source: String = FileAccess.get_file_as_string("res://scenes/OpeningCinematic.gd")
	_expect(source.count("AudioManager.") == 0, "opening source added direct AudioManager access")
	var fallback: Dictionary = {"status": "NOT_APPLICABLE_BASELINE"}
	if not _baseline:
		var reader: Control = OPENING.instantiate()
		_expect(reader.has_method("_beat_fade_seconds"), "duration getter missing")
		if reader.has_method("_beat_fade_seconds"):
			var missing: Dictionary = beats[0].duplicate(true)
			missing.erase("fade")
			fallback = {"missing": reader.call("_beat_fade_seconds", missing), "empty": reader.call("_beat_fade_seconds", {}), "authored": []}
			_expect(is_equal_approx(float(fallback["missing"]), 0.52) and is_equal_approx(float(fallback["empty"]), 0.52), "missing fade fallback")
			for index in range(3):
				var value: float = float(reader.call("_beat_fade_seconds", beats[index]))
				fallback["authored"].append(value)
				_expect(is_equal_approx(value, float(_fades[index])), "authored duration %d" % index)
		reader.free()
	var before_settings: Dictionary = {"locale": LocaleManager.language, "reduce_motion": SaveManager.get_setting("reduce_motion", false)}
	await _autoplay(false, "ko")
	await _autoplay(true, "en")
	var skip: Dictionary = await _skip()
	SaveManager.set_setting("reduce_motion", before_settings["reduce_motion"])
	LocaleManager.set_language(str(before_settings["locale"]))
	_stop_audio()
	await get_tree().create_timer(0.25, true, false, true).timeout
	await get_tree().process_frame
	await get_tree().process_frame
	var mode: String = "baseline" if _baseline else "current"
	var report: Dictionary = {"unit": "ORDER-149", "mode": mode, "pass": _failures.is_empty(), "errors": _failures,
		"source_sha256": FileAccess.get_sha256("res://scenes/OpeningCinematic.gd"), "nominal_seconds": 10.76,
		"autoplay": _rows, "fallback": fallback, "skip": skip, "input_dispatch": _dispatch,
		"direct_audio_manager_source_accesses": source.count("AudioManager."), "sfx_max_active_sampled": _sfx_max_active,
		"curve_tolerance_seconds": CURVE_TOLERANCE_SECONDS, "max_allowed_sample_gap_seconds": MAX_SAMPLE_GAP_SECONDS,
		"render": "NOT_RUN", "black_frames": "NOT_OBSERVED", "human_rhythm": "NOT_OBSERVED", "physical_input": "NOT_OBSERVED"}
	print("OPENING_RHYTHM_REPORT " + JSON.stringify(report))
	if not _failures.is_empty():
		for failure in _failures:
			push_error("OPENING_RHYTHM_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("OPENING_RHYTHM_CHECK_OK mode=%s autoplay=2 skip=1 render=NOT_RUN" % mode)
	get_tree().quit(0)


func _create_opening(reduced: bool, language: String) -> Control:
	SaveManager.set_setting("reduce_motion", reduced)
	LocaleManager.set_language(language)
	var opening: Control = OPENING.instantiate()
	opening.set("_qa_disable_autoplay", false)
	opening.set("_qa_force_reduced_motion", false)
	opening.set("_qa_suppress_transition", true)
	return opening


func _curve(row: Dictionary, key: String, progress: float, now: float, camera: bool = false) -> void:
	if not row["curves"].has(key):
		row["curves"][key] = {"samples": 0, "first": {}, "last": {}, "completed_at": -1.0}
	var curve: Dictionary = row["curves"][key]
	curve["samples"] += 1
	if progress >= 0.999999 and float(curve["completed_at"]) < 0.0:
		curve["completed_at"] = now
	if progress < 0.05 or progress > 0.95:
		return
	var fraction: float = asin(clampf(progress, 0.0, 1.0)) / (PI * 0.5) if camera else acos(1.0 - 2.0 * progress) / PI
	var sample: Dictionary = {"seconds": now, "progress": progress, "easing_fraction": fraction}
	if curve["first"].is_empty():
		curve["first"] = sample
	curve["last"] = sample


func _observe(opening: Control, rows: Array, started: int, reduced: bool, language: String) -> void:
	var image: TextureRect = opening.get("_current_image") as TextureRect
	var index: int = int(opening.get_meta("opening_beat_index", -1))
	if not is_instance_valid(image) or index < 0 or index > 2 or image.name != "OpeningImage%d" % (index + 1):
		return
	var title: Label = opening.get("_title_label") as Label
	var body: Label = opening.get("_body_label") as Label
	var rule: ColorRect = opening.get("_beat_rule") as ColorRect
	var now: float = float(Time.get_ticks_usec() - started) / 1000000.0
	if rows.is_empty() or int(rows[-1]["index"]) != index:
		_expect(index == rows.size(), "autoplay beat order %s/%s" % [language, index])
		var offset: int = 0 if language == "ko" else 2
		_expect(title.text == COPY[index][offset] and body.text == COPY[index][offset + 1], "actual copy %s/%d" % [language, index])
		var atmosphere: Node = opening.find_child("OpeningAtmosphere", true, false)
		var profile: Dictionary = atmosphere.get("current_profile")
		_expect(str(profile.get("camera", "")) == "none" if reduced else str(profile.get("camera", "")).begins_with("living_"), "motion profile %s/%d" % [language, index])
		rows.append({"index": index, "first_observed_at": now, "title": title.text, "body": body.text,
			"texture": image.texture.resource_path if image.texture != null else "", "camera": profile.get("camera"),
			"scale_first": [image.scale.x, image.scale.y], "scale_last": [], "curves": {}, "old_image_freed": false})
	var row: Dictionary = rows[-1]
	row["scale_last"] = [image.scale.x, image.scale.y]
	_expect(image.texture != null and image.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_COVERED, "actual image %s/%d" % [language, index])
	_curve(row, "image", image.modulate.a, now)
	_curve(row, "title", title.modulate.a, now)
	_curve(row, "body", body.modulate.a, now)
	_curve(row, "rule", rule.modulate.a, now)
	if reduced:
		_expect(image.scale.is_equal_approx(Vector2.ONE), "reduced motion scale %d" % index)
	else:
		_curve(row, "camera", (1.045 - image.scale.x) / 0.045, now, true)
		if image.scale.is_equal_approx(Vector2.ONE):
			row["curves"]["camera"]["completed_at"] = now
	var old: TextureRect = null
	for child in (opening.get("_visual_frame") as Control).get_children():
		if child is TextureRect and child != image:
			old = child as TextureRect
	if is_instance_valid(old):
		_curve(row, "old_image", 1.0 - old.modulate.a, now)
	elif index > 0:
		row["old_image_freed"] = true
	var active: int = 0
	for child in AudioManager.get_children():
		if child is AudioStreamPlayer and (child as AudioStreamPlayer).playing:
			active += 1
	_sfx_max_active = maxi(_sfx_max_active, active)


func _check_curves(rows: Array, reduced: bool, language: String) -> void:
	for row in rows:
		var index: int = int(row["index"])
		var expected: Dictionary = {"image": _fades[index], "title": float(_fades[index]) * 0.85,
			"body": _fades[index], "rule": float(_fades[index]) * 0.75}
		if not reduced:
			expected["camera"] = float(_fades[index]) + float(_holds[index])
		if index > 0:
			expected["old_image"] = _fades[index]
		_expect(row["curves"].size() == expected.size(), "curve population %s/%d" % [language, index])
		for key in expected:
			var curve: Dictionary = row["curves"].get(key, {})
			var first: Dictionary = curve.get("first", {})
			var last: Dictionary = curve.get("last", {})
			if first.is_empty() or last.is_empty() or float(last["easing_fraction"]) <= float(first["easing_fraction"]):
				_expect(false, "curve samples missing %s/%d/%s" % [language, index, key])
				continue
			var seconds: float = (float(last["seconds"]) - float(first["seconds"])) / (float(last["easing_fraction"]) - float(first["easing_fraction"]))
			curve["estimated_seconds"] = seconds
			curve["expected_seconds"] = expected[key]
			_expect(absf(seconds - float(expected[key])) <= CURVE_TOLERANCE_SECONDS, "curve duration %s/%d/%s" % [language, index, key])
			_expect(bool(row["old_image_freed"]) if key == "old_image" else float(curve.get("completed_at", -1.0)) >= 0.0, "curve incomplete %s/%d/%s" % [language, index, key])


func _settle_before_autoplay() -> float:
	# Exclude autoload/settings startup delta smoothing from wall-clock samples.
	var began: int = Time.get_ticks_usec()
	var frames: int = 0
	while frames < 15 or Time.get_ticks_usec() - began < 250000:
		await get_tree().process_frame
		frames += 1
	return float(Time.get_ticks_usec() - began) / 1000000.0


func _autoplay(reduced: bool, language: String) -> void:
	var opening: Control = _create_opening(reduced, language)
	var preparation_seconds: float = await _settle_before_autoplay()
	var started: int = Time.get_ticks_usec()
	add_child(opening)
	var rows: Array = []
	var last_tick: int = Time.get_ticks_usec()
	var max_gap: float = 0.0
	while Time.get_ticks_usec() - started < 18000000:
		_observe(opening, rows, started, reduced, language)
		if int(opening.get_meta("opening_transition_requests", 0)) > 0:
			break
		await get_tree().process_frame
		var tick: int = Time.get_ticks_usec()
		max_gap = maxf(max_gap, float(tick - last_tick) / 1000000.0)
		last_tick = tick
	var elapsed: float = float(Time.get_ticks_usec() - started) / 1000000.0
	var transitions: int = int(opening.get_meta("opening_transition_requests", 0))
	_expect(rows.size() == 3 and transitions == 1, "autoplay completion " + language)
	_expect(bool(opening.get_meta("opening_reduced_motion", not reduced)) == reduced, "actual reduce-motion setting " + language)
	_expect(elapsed >= 10.76 * 0.85 and elapsed <= 10.76 * 1.15, "autoplay nominal time envelope " + language)
	_expect(max_gap <= MAX_SAMPLE_GAP_SECONDS, "sampling stall " + language)
	_check_curves(rows, reduced, language)
	_rows.append({"locale": language, "reduce_motion": reduced, "elapsed_seconds": elapsed, "max_frame_gap_seconds": max_gap,
		"preparation_seconds_excluded": preparation_seconds, "timing_scope": "warmed fixture, not cold boot",
		"transition_requests": transitions, "beats": rows})
	opening.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


func _send_key(opening: Control, pressed: bool, echo_event: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = KEY_ENTER
	event.physical_keycode = KEY_ENTER
	event.pressed = pressed
	event.echo = echo_event
	Input.parse_input_event(event)
	_dispatch.append({"ticks_usec": Time.get_ticks_usec(), "pressed": pressed, "echo": echo_event,
		"transition_requests_after_dispatch": opening.get_meta("opening_transition_requests", 0)})


func _skip() -> Dictionary:
	var opening: Control = _create_opening(false, "ko")
	var preparation_seconds: float = await _settle_before_autoplay()
	var started: int = Time.get_ticks_usec()
	add_child(opening)
	var second_started: int = 0
	while Time.get_ticks_usec() - started < 8000000:
		var current: TextureRect = opening.get("_current_image") as TextureRect
		if int(opening.get_meta("opening_beat_index", -1)) == 1 and is_instance_valid(current) and current.name == "OpeningImage2":
			second_started = Time.get_ticks_usec()
			break
		await get_tree().process_frame
	if second_started == 0:
		_expect(false, "skip second beat was not reached")
		opening.queue_free()
		await get_tree().process_frame
		return {"error": "second beat not reached", "dispatch_count": 0}
	while Time.get_ticks_usec() - second_started < 150000:
		await get_tree().process_frame
	var before: int = int(opening.get_meta("opening_beat_index", -1))
	var generation: int = int(opening.get("_sequence_generation"))
	var ignored_transitions: Array = []
	for edge in [[false, false], [true, true]]:
		_send_key(opening, edge[0], edge[1])
		await get_tree().process_frame
		ignored_transitions.append(int(opening.get_meta("opening_transition_requests", 0)))
		_expect(ignored_transitions[-1] == 0, "release/echo skipped before accepted input")
	var alpha_before: float = (opening.get("_current_image") as TextureRect).modulate.a
	var input_offset: float = float(Time.get_ticks_usec() - second_started) / 1000000.0
	_expect(before == 1 and alpha_before > 0.0 and alpha_before < 1.0
		and Time.get_ticks_msec() > int(opening.get("_accept_input_after_ms")), "skip must enter second beat during its fade after input unlock")
	for edge in [[true, false], [false, false], [true, false], [false, false]]:
		_send_key(opening, edge[0], edge[1])
		await get_tree().process_frame
	var deadline: int = second_started + int((float(_fades[1]) + float(_holds[1]) + 0.25) * 1000000.0)
	while Time.get_ticks_usec() < deadline:
		_expect(int(opening.get_meta("opening_beat_index", -1)) == before, "skip entered a later beat")
		await get_tree().process_frame
	var result: Dictionary = {"first_beat": before, "last_beat": opening.get_meta("opening_beat_index", -1),
		"preparation_seconds_excluded": preparation_seconds,
		"window": "second_beat_fade", "alpha_before_input": alpha_before, "input_offset_seconds": input_offset,
		"ignored_input_transition_counts": ignored_transitions,
		"second_beat_first_observed_seconds": float(second_started - started) / 1000000.0,
		"transition_requests": opening.get_meta("opening_transition_requests", 0),
		"generation_before": generation, "generation_after": opening.get("_sequence_generation"),
		"observed_seconds": float(Time.get_ticks_usec() - started) / 1000000.0,
		"dispatch_count": _dispatch.size(), "claim": "synthetic keyboard requests and actual scene response; physical input not observed"}
	_expect(before == 1 and int(result["last_beat"]) == 1 and int(result["transition_requests"]) == 1
		and int(result["generation_after"]) == generation + 1, "skip must request one transition only")
	opening.queue_free()
	await get_tree().process_frame
	return result


func _stop_audio() -> void:
	BGMPlayer.stop()
	for owner in [AudioManager, BGMPlayer]:
		for child in owner.get_children():
			if child is AudioStreamPlayer:
				(child as AudioStreamPlayer).stop()
				(child as AudioStreamPlayer).stream = null
