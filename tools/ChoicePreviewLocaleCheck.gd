extends Node
## ORDER-220: actual MainGame caller-created preview labels in fresh storage.
## Headless component only; not screenshot, native or whole-play approval.
const MAIN_GAME := preload("res://scenes/MainGame.tscn")
const QA_PREFIX := "GangnamDream_StoryNameplateQA_"
# Immutable precode50 plus separately sealed declared addendum14.
const CASES := [
	{"id":"ko/missing_effects","locale":"ko","choice":{},"expected":"","mode":"normal"},
	{"id":"ko/empty_effects","locale":"ko","choice":{"effects":{}},"expected":"","mode":"normal"},
	{"id":"ko/positive_pair","locale":"ko","choice":{"effects":{"health":3,"mental":4}},"expected":"건강 +3  정신 +4","mode":"normal"},
	{"id":"ko/negative_pair","locale":"ko","choice":{"effects":{"health":-7,"mental":-2}},"expected":"건강 -7  정신 -2","mode":"normal"},
	{"id":"ko/stress_merge","locale":"ko","choice":{"effects":{"stress":6,"mental":2}},"expected":"정신 -4","mode":"normal"},
	{"id":"ko/stress_zero_cancel","locale":"ko","choice":{"effects":{"stress":6,"mental":6,"health":0,"money":0}},"expected":"","mode":"normal"},
	{"id":"ko/hidden_only","locale":"ko","choice":{"effects":{"social_skill":8,"reputation":-3,"intelligence":4}},"expected":"","mode":"normal"},
	{"id":"ko/mixed_priority","locale":"ko","choice":{"effects":{"mental":4,"money":5000,"health":3,"social_skill":8}},"expected":"₩ +5000원  건강 +3  정신 +4","mode":"normal"},
	{"id":"ko/negative_money","locale":"ko","choice":{"effects":{"money":-10000}},"expected":"₩ -1만원","mode":"normal"},
	{"id":"ko/reverse_input_order","locale":"ko","choice":{"effects":{"stress":2,"health":3,"mental":7}},"expected":"건강 +3  정신 +5","mode":"normal"},
	{"id":"en/missing_effects","locale":"en","choice":{},"expected":"","mode":"normal"},
	{"id":"en/empty_effects","locale":"en","choice":{"effects":{}},"expected":"","mode":"normal"},
	{"id":"en/positive_pair","locale":"en","choice":{"effects":{"health":3,"mental":4}},"expected":"Health +3  Mental +4","mode":"normal"},
	{"id":"en/negative_pair","locale":"en","choice":{"effects":{"health":-7,"mental":-2}},"expected":"Health -7  Mental -2","mode":"normal"},
	{"id":"en/stress_merge","locale":"en","choice":{"effects":{"stress":6,"mental":2}},"expected":"Mental -4","mode":"normal"},
	{"id":"en/stress_zero_cancel","locale":"en","choice":{"effects":{"stress":6,"mental":6,"health":0,"money":0}},"expected":"","mode":"normal"},
	{"id":"en/hidden_only","locale":"en","choice":{"effects":{"social_skill":8,"reputation":-3,"intelligence":4}},"expected":"","mode":"normal"},
	{"id":"en/mixed_priority","locale":"en","choice":{"effects":{"mental":4,"money":5000,"health":3,"social_skill":8}},"expected":"KRW +5 thousand won  Health +3  Mental +4","mode":"normal"},
	{"id":"en/negative_money","locale":"en","choice":{"effects":{"money":-10000}},"expected":"KRW -10 thousand won","mode":"normal"},
	{"id":"en/reverse_input_order","locale":"en","choice":{"effects":{"stress":2,"health":3,"mental":7}},"expected":"Health +3  Mental +5","mode":"normal"},
	{"id":"ja/missing_effects","locale":"ja","choice":{},"expected":"","mode":"normal"},
	{"id":"ja/empty_effects","locale":"ja","choice":{"effects":{}},"expected":"","mode":"normal"},
	{"id":"ja/positive_pair","locale":"ja","choice":{"effects":{"health":3,"mental":4}},"expected":"健康 +3  精神 +4","mode":"normal"},
	{"id":"ja/negative_pair","locale":"ja","choice":{"effects":{"health":-7,"mental":-2}},"expected":"健康 -7  精神 -2","mode":"normal"},
	{"id":"ja/stress_merge","locale":"ja","choice":{"effects":{"stress":6,"mental":2}},"expected":"精神 -4","mode":"normal"},
	{"id":"ja/stress_zero_cancel","locale":"ja","choice":{"effects":{"stress":6,"mental":6,"health":0,"money":0}},"expected":"","mode":"normal"},
	{"id":"ja/hidden_only","locale":"ja","choice":{"effects":{"social_skill":8,"reputation":-3,"intelligence":4}},"expected":"","mode":"normal"},
	{"id":"ja/mixed_priority","locale":"ja","choice":{"effects":{"mental":4,"money":5000,"health":3,"social_skill":8}},"expected":"KRW +5000ウォン  健康 +3  精神 +4","mode":"normal"},
	{"id":"ja/negative_money","locale":"ja","choice":{"effects":{"money":-10000}},"expected":"KRW -1万ウォン","mode":"normal"},
	{"id":"ja/reverse_input_order","locale":"ja","choice":{"effects":{"stress":2,"health":3,"mental":7}},"expected":"健康 +3  精神 +5","mode":"normal"},
	{"id":"zh-CN/missing_effects","locale":"zh-CN","choice":{},"expected":"","mode":"normal"},
	{"id":"zh-CN/empty_effects","locale":"zh-CN","choice":{"effects":{}},"expected":"","mode":"normal"},
	{"id":"zh-CN/positive_pair","locale":"zh-CN","choice":{"effects":{"health":3,"mental":4}},"expected":"Health +3  Mental +4","mode":"normal"},
	{"id":"zh-CN/negative_pair","locale":"zh-CN","choice":{"effects":{"health":-7,"mental":-2}},"expected":"Health -7  Mental -2","mode":"normal"},
	{"id":"zh-CN/stress_merge","locale":"zh-CN","choice":{"effects":{"stress":6,"mental":2}},"expected":"Mental -4","mode":"normal"},
	{"id":"zh-CN/stress_zero_cancel","locale":"zh-CN","choice":{"effects":{"stress":6,"mental":6,"health":0,"money":0}},"expected":"","mode":"normal"},
	{"id":"zh-CN/hidden_only","locale":"zh-CN","choice":{"effects":{"social_skill":8,"reputation":-3,"intelligence":4}},"expected":"","mode":"normal"},
	{"id":"zh-CN/mixed_priority","locale":"zh-CN","choice":{"effects":{"mental":4,"money":5000,"health":3,"social_skill":8}},"expected":"KRW +5000韩元  Health +3  Mental +4","mode":"normal"},
	{"id":"zh-CN/negative_money","locale":"zh-CN","choice":{"effects":{"money":-10000}},"expected":"KRW -1万韩元","mode":"normal"},
	{"id":"zh-CN/reverse_input_order","locale":"zh-CN","choice":{"effects":{"stress":2,"health":3,"mental":7}},"expected":"Health +3  Mental +5","mode":"normal"},
	{"id":"zh-TW/missing_effects","locale":"zh-TW","choice":{},"expected":"","mode":"normal"},
	{"id":"zh-TW/empty_effects","locale":"zh-TW","choice":{"effects":{}},"expected":"","mode":"normal"},
	{"id":"zh-TW/positive_pair","locale":"zh-TW","choice":{"effects":{"health":3,"mental":4}},"expected":"Health +3  Mental +4","mode":"normal"},
	{"id":"zh-TW/negative_pair","locale":"zh-TW","choice":{"effects":{"health":-7,"mental":-2}},"expected":"Health -7  Mental -2","mode":"normal"},
	{"id":"zh-TW/stress_merge","locale":"zh-TW","choice":{"effects":{"stress":6,"mental":2}},"expected":"Mental -4","mode":"normal"},
	{"id":"zh-TW/stress_zero_cancel","locale":"zh-TW","choice":{"effects":{"stress":6,"mental":6,"health":0,"money":0}},"expected":"","mode":"normal"},
	{"id":"zh-TW/hidden_only","locale":"zh-TW","choice":{"effects":{"social_skill":8,"reputation":-3,"intelligence":4}},"expected":"","mode":"normal"},
	{"id":"zh-TW/mixed_priority","locale":"zh-TW","choice":{"effects":{"mental":4,"money":5000,"health":3,"social_skill":8}},"expected":"KRW +5000韓元  Health +3  Mental +4","mode":"normal"},
	{"id":"zh-TW/negative_money","locale":"zh-TW","choice":{"effects":{"money":-10000}},"expected":"KRW -1萬韓元","mode":"normal"},
	{"id":"zh-TW/reverse_input_order","locale":"zh-TW","choice":{"effects":{"stress":2,"health":3,"mental":7}},"expected":"Health +3  Mental +5","mode":"normal"},
	{"id":"ko/spec_mixed","locale":"ko","choice":{"effects":{"health":3,"mental":2,"stress":5,"intelligence":99}},"expected":"건강 +3  정신 -3","mode":"normal"},
	{"id":"ko/reselect","locale":"ko","choice":{"effects":{"health":3,"mental":4}},"expected":"건강 +3  정신 +4","mode":"reselect"},
	{"id":"en/spec_mixed","locale":"en","choice":{"effects":{"health":3,"mental":2,"stress":5,"intelligence":99}},"expected":"Health +3  Mental -3","mode":"normal"},
	{"id":"en/reselect","locale":"en","choice":{"effects":{"health":3,"mental":4}},"expected":"Health +3  Mental +4","mode":"reselect"},
	{"id":"ja/spec_mixed","locale":"ja","choice":{"effects":{"health":3,"mental":2,"stress":5,"intelligence":99}},"expected":"健康 +3  精神 -3","mode":"normal"},
	{"id":"ja/reselect","locale":"ja","choice":{"effects":{"health":3,"mental":4}},"expected":"健康 +3  精神 +4","mode":"reselect"},
	{"id":"zh-CN/spec_mixed","locale":"zh-CN","choice":{"effects":{"health":3,"mental":2,"stress":5,"intelligence":99}},"expected":"Health +3  Mental -3","mode":"normal"},
	{"id":"zh-CN/reselect","locale":"zh-CN","choice":{"effects":{"health":3,"mental":4}},"expected":"Health +3  Mental +4","mode":"reselect"},
	{"id":"zh-TW/spec_mixed","locale":"zh-TW","choice":{"effects":{"health":3,"mental":2,"stress":5,"intelligence":99}},"expected":"Health +3  Mental -3","mode":"normal"},
	{"id":"zh-TW/reselect","locale":"zh-TW","choice":{"effects":{"health":3,"mental":4}},"expected":"Health +3  Mental +4","mode":"reselect"},
	{"id":"ja/community_health_only","locale":"ja","choice":{"effects":{"health":3,"mental":4}},"expected":"QA Health +3  精神 +4","mode":"community","community":{"건강":"QA Health"}},
	{"id":"ja/community_cleared","locale":"ja","choice":{"effects":{"health":3,"mental":4}},"expected":"健康 +3  精神 +4","mode":"community","community":{}},
	{"id":"zh-CN/community_health_only","locale":"zh-CN","choice":{"effects":{"health":3,"mental":4}},"expected":"QA Health +3  Mental +4","mode":"community","community":{"건강":"QA Health"}},
	{"id":"zh-CN/community_cleared","locale":"zh-CN","choice":{"effects":{"health":3,"mental":4}},"expected":"Health +3  Mental +4","mode":"community","community":{}},
]
var _game: Control
var _failures: Array[String] = []
var _observed := 0

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	Engine.max_fps = 60
	if not _isolated():
		get_tree().quit(1)
		return
	await _frames(3)
	GameState.start_new_game("김민준", "지방_상경", "none", "알바", "자유런", "현실")
	GameState.money = 500000.0
	GameState.health = 80
	GameState.mental = 80
	GameState.action_points = 1
	GameState.max_action_points = 1
	GameState.flags["prologue_done"] = true
	GameState.flags["story_flashforward_seen"] = true
	GameState.flags["tutorial_shown"] = true
	GameState.pending_story_queue.clear()
	EventManager.current_event = {}
	_game = MAIN_GAME.instantiate() as Control
	_game.set_meta("_screenshot_qa_static_surface", true)
	add_child(_game)
	await _frames(5)
	for fixture in CASES:
		await _check(fixture)
	await _shutdown()
	if _observed != 64:
		_failures.append("case count changed: %d" % _observed)
	if not _failures.is_empty():
		for failure in _failures:
			push_error("CHOICE_PREVIEW_LOCALE_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("CHOICE_PREVIEW_LOCALE_CHECK_OK cases=64 base=50 additional=14 locales=5 caller_labels=64 state_unchanged=64 isolation=preautoload rendered=0")
	get_tree().quit(0)

func _isolated() -> bool:
	var boot := get_tree().get_script() as Script
	var qa_namespace := str(ProjectSettings.get_setting("application/config/custom_user_dir_name", ""))
	var valid := boot != null and boot.resource_path == "res://tools/StoryNameplateBootstrap.gd" \
		and bool(ProjectSettings.get_setting("application/config/use_custom_user_dir", false)) \
		and qa_namespace.begins_with(QA_PREFIX) and OS.get_user_data_dir().get_file() == qa_namespace
	if not valid:
		push_error("CHOICE_PREVIEW_LOCALE_CHECK_FAIL pre-autoload isolation required")
		return false
	print("STORY_NAMEPLATE_QA_USER_DIR=%s" % OS.get_user_data_dir())
	return true

func _write_community(locale: String, values: Dictionary) -> void:
	var directory := "user://lang/" + locale
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory)) != OK:
		_failures.append("cannot create isolated community directory")
		return
	var file := FileAccess.open(directory + "/ui_" + locale + ".json", FileAccess.WRITE)
	if file == null:
		_failures.append("cannot write isolated community fixture")
		return
	file.store_string(JSON.stringify(values))
	file.close()
	LocaleManager.refresh_community_packs()

func _state() -> Dictionary:
	return {
		"money": GameState.money, "health": GameState.health, "mental": GameState.mental,
		"turn": GameState.turn, "ap": GameState.action_points,
		"flags": GameState.flags.duplicate(true),
		"weekly": GameState.weekly_commitments.duplicate(true),
		"pending": GameState.pending_weekly_commitment.duplicate(true),
	}

func _check(fixture: Dictionary) -> void:
	var case_id: String = fixture["id"]
	var locale: String = fixture["locale"]
	if str(fixture["mode"]) == "community":
		_write_community(locale, fixture["community"])
	LocaleManager.set_language(locale)
	await _frames(2)
	if str(fixture["mode"]) == "reselect":
		LocaleManager.set_language(locale)
		await _frames(1)
	var choice: Dictionary = fixture["choice"].duplicate(true)
	choice["text"] = "Preview fixture"
	var original := choice.duplicate(true)
	var expected: String = fixture["expected"]
	var state_before := _state()
	var helper: String = _game.call("_choice_effects_preview", choice)
	var event := {
		"id": "order220_choice_preview_fixture", "title": "Preview fixture",
		"description": "Preview fixture.", "category": "daily", "choices": [choice],
	}
	_game.set("current_event", event)
	_game.call("_render_event")
	_game.call("_finish_typing")
	await _frames(2)
	var box: VBoxContainer = _game.get("choice_box")
	var groups: Array[Node] = []
	for child in box.get_children():
		if child is VBoxContainer and not child.is_queued_for_deletion():
			groups.append(child)
	var actual_labels: Array[String] = []
	var buttons := 0
	for group in groups:
		for child in group.get_children():
			if child is Button:
				buttons += 1
			if child is Label and str(child.get_meta("moral_role", "")) == "hint_text":
				actual_labels.append((child as Label).text)
	var expected_labels: Array[String] = []
	if not expected.is_empty():
		expected_labels.append("  " + expected)
	var passed := helper == expected and actual_labels == expected_labels \
		and groups.size() == 1 and buttons == 1 and choice == original \
		and state_before == _state()
	if not passed:
		_failures.append("%s helper=%s labels=%s expected=%s groups=%d buttons=%d choice_same=%s state_same=%s" % [
			case_id, JSON.stringify(helper), JSON.stringify(actual_labels),
			JSON.stringify(expected_labels), groups.size(), buttons,
			str(choice == original), str(state_before == _state())])
	print("CHOICE_PREVIEW_CASE " + JSON.stringify({
		"id": case_id, "helper": helper, "labels": actual_labels, "expected": expected,
		"pass": passed, "state_unchanged": state_before == _state(),
		"choice_unchanged": choice == original, "actual_caller": "_reveal_choices",
	}))
	_observed += 1

func _frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame

func _shutdown() -> void:
	if is_instance_valid(_game):
		_game.queue_free()
		await _frames(4)
	_game = null
	for raw_tween in get_tree().get_processed_tweens():
		if raw_tween is Tween and (raw_tween as Tween).is_valid():
			(raw_tween as Tween).kill()
	BGMPlayer.stop()
	_detach_audio(get_tree().root)
	for player in AudioManager._pool:
		if player is AudioStreamPlayer:
			(player as AudioStreamPlayer).stop()
			(player as AudioStreamPlayer).stream = null
	AudioManager._sounds.clear()
	await AudioManager.drain_pending_timers_for_exit()
	BGMPlayer.stop()
	_detach_audio(get_tree().root)
	await _frames(8)

func _detach_audio(node: Node) -> void:
	if node is AudioStreamPlayer:
		(node as AudioStreamPlayer).stop()
		(node as AudioStreamPlayer).stream = null
	elif node is AudioStreamPlayer2D:
		(node as AudioStreamPlayer2D).stop()
		(node as AudioStreamPlayer2D).stream = null
	for child in node.get_children():
		_detach_audio(child)
