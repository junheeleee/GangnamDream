extends Node
## SceneDirectionCheck — 정점 장면 direction이 실제 타이밍/오디오/카메라에 연결되는지 검증.

var _story: Node = null

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	AudioManager.bgm_volume = 0.25
	GameState.start_new_game()
	GameState.flags["prologue_done"] = true
	BGMPlayer.start()
	await get_tree().create_timer(0.20).timeout
	var bgm_key_before: String = BGMPlayer._current_key
	var bgm_pos_before: float = BGMPlayer._player_a.get_playback_position()

	_story = await _boot_story("arc_sangchul_confrontation")
	if _story == null:
		return
	var direction: Dictionary = _story.get("_direction")
	if str(direction.get("pace", "")) != "slow" or str(direction.get("amb", "")) != "cut":
		_fail("confrontation direction did not reach StoryMode")
		return
	if float(_story.call("_direction_type_interval")) <= float(_story.TYPE_SPEED):
		_fail("slow pace did not reduce typing speed")
		return
	if BGMPlayer._current_ambience_key != "":
		_fail("ambience cut did not clear the scene ambience")
		return
	if AudioManager._last_direction_sting_token != "arc_sangchul_confrontation:cold":
		_fail("cold direction sting did not fire once")
		return
	if BGMPlayer._current_key != bgm_key_before:
		_fail("direction sting replaced the BGM track")
		return
	var bgm_pos_after: float = BGMPlayer._player_a.get_playback_position()
	if bgm_pos_after + 0.05 < bgm_pos_before:
		_fail("direction scene restarted BGM playback")
		return

	var paragraphs: Array = _story.get("_paragraphs")
	_story.set("_para_index", paragraphs.size() - 1)
	_story.set("_pending_after_result", false)
	_story.call("_start_typing", str(paragraphs[-1]))
	_story.call("_on_advance")
	if not bool(_story.get("_direction_hold_active")):
		_fail("confrontation hold did not begin after final paragraph")
		return
	_story.call("_on_advance")
	if not bool(_story.get("_direction_hold_active")):
		_fail("forced hold was skipped by advance input")
		return
	await get_tree().create_timer(1.65).timeout
	if not bool(_story.get("_showing_choices")):
		_fail("choices did not appear after direction hold")
		return
	await _remove_story()

	_story = await _boot_story("arc_daeun_proposal_answer")
	if _story == null:
		return
	var proposal_direction: Dictionary = _story.get("_direction")
	if str(proposal_direction.get("camera", "")) != "slow_zoom":
		_fail("proposal camera direction did not reach StoryMode")
		return
	var camera_tween: Tween = _story.get("_direction_camera_tween") as Tween
	if camera_tween == null or not camera_tween.is_running():
		_fail("proposal slow zoom tween is not running")
		return
	var bg_img: TextureRect = _story.get("_bg_img") as TextureRect
	if bg_img == null or bg_img.scale.x < 1.0 or bg_img.scale.x >= 1.045:
		_fail("proposal slow zoom scale is outside its animated range")
		return
	await _remove_story()

	_story = await _boot_story("arc_sangchul_deduction")
	if _story == null:
		return
	var beat_direction: Dictionary = _story.get("_direction")
	if str(beat_direction.get("pace", "")) != "beat":
		_fail("deduction beat direction did not reach StoryMode")
		return
	if AudioManager._last_direction_sting_token != "arc_sangchul_deduction:reveal":
		_fail("reveal direction sting did not fire once")
		return
	_story.call("_on_advance")
	_story.call("_on_advance")
	if not bool(_story.get("_direction_beat_waiting")):
		_fail("beat pause did not begin between paragraphs")
		return
	_story.call("_on_advance")
	if bool(_story.get("_direction_beat_waiting")) or not bool(_story.get("_typing")):
		_fail("advance input did not resolve the beat into the next paragraph")
		return
	await _remove_story()

	_story = await _boot_story("arc_father_06_confession")
	if _story == null:
		return
	var duck_direction: Dictionary = _story.get("_direction")
	if str(duck_direction.get("amb", "")) != "duck" or not is_equal_approx(BGMPlayer._ambience_duck_db, -8.0):
		_fail("father confession ambience duck did not engage")
		return

	await _remove_story()
	if not is_zero_approx(BGMPlayer._ambience_duck_db):
		_fail("ambience duck did not restore after leaving StoryMode")
		return
	BGMPlayer.stop()
	print("SCENE_DIRECTION_OK hold=1.5 camera=slow_zoom beat=0.65 duck=-8db")
	call_deferred("_quit_ok")

func _quit_ok() -> void:
	get_tree().quit(0)

func _boot_story(event_id: String) -> Node:
	GameState.pending_story_queue = [event_id]
	var packed: PackedScene = load("res://scenes/StoryMode.tscn")
	var story: Node = packed.instantiate()
	get_tree().root.add_child(story)
	await get_tree().process_frame
	await get_tree().create_timer(0.25).timeout
	if not is_instance_valid(story):
		_fail("StoryMode failed to boot for %s" % event_id)
		return null
	return story

func _remove_story() -> void:
	if is_instance_valid(_story):
		_story.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	_story = null
	GameState.pending_story_queue.clear()

func _fail(message: String) -> void:
	push_error("SCENE_DIRECTION_FAIL " + message)
	get_tree().quit(1)
