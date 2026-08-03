extends Node
## FlashforwardVisualCheck — 장면 로컬 Black 미래가 세이브와 다음 씬을 오염시키지 않는지 검증.

var _story: Node = null

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	GameState.start_new_game()
	var original_tint: float = GameState.moral_tint
	GameState.pending_story_queue = ["story_flashforward"]
	var packed := load("res://scenes/StoryMode.tscn") as PackedScene
	_story = packed.instantiate()
	get_tree().root.add_child(_story)
	await get_tree().process_frame
	await get_tree().create_timer(0.25).timeout

	var current: Dictionary = _story.get("_current")
	var direction: Dictionary = _story.get("_direction")
	if str(current.get("id", "")) != "story_flashforward" or str(direction.get("visual", "")) != "black_future":
		_fail("flashforward visual direction did not reach StoryMode")
		return
	if not bool(_story.get("_story_visual_override_active")):
		_fail("flashforward scene-local override is inactive")
		return
	var hud_panel := _story.get("_hud_panel") as Control
	if hud_panel == null or hud_panel.visible:
		_fail("flashforward exposed present-day HUD over the future scene")
		return
	var bg_img := _story.get("_bg_img") as TextureRect
	var expected_bg: String = ImageRegistry.get_background("penthouse")
	if bg_img == null or bg_img.texture == null or bg_img.texture.resource_path != expected_bg:
		_fail("flashforward did not use the high-floor interior background")
		return
	var portrait_frame := _story.get("_portrait_frame") as Control
	var portrait := _story.get("_portrait") as TextureRect
	var name_panel := _story.get("_name_panel") as Control
	if portrait_frame == null or not portrait_frame.visible or portrait == null or portrait.texture == null:
		_fail("flashforward did not render the suited silhouette")
		return
	if name_panel != null and name_panel.visible:
		_fail("flashforward silhouette exposed the protagonist name")
		return
	if portrait.modulate.r > 0.1 or portrait.modulate.a > 0.8:
		_fail("flashforward silhouette reveals too much of the face")
		return
	if not is_equal_approx(float(_story.get("_story_moral_norm")), -0.80):
		_fail("flashforward did not render at Black future intensity")
		return
	if not is_equal_approx(GameState.moral_tint, original_tint):
		_fail("flashforward mutated persistent moral_tint")
		return
	var bg_material := _story.get("_story_bg_material") as ShaderMaterial
	var surface_material := _story.get("_story_surface_material") as ShaderMaterial
	var black_brightness := (
		float(bg_material.get_shader_parameter("brightness"))
		if bg_material != null else 1.0)
	if bg_material == null or black_brightness <= 0.0 or black_brightness >= 1.0:
		_fail("flashforward background was not semantically darkened")
		return
	if surface_material == null or not is_equal_approx(float(surface_material.get_shader_parameter("black_intensity")), 0.80):
		_fail("flashforward surface shader did not receive Black override")
		return

	_story.call("_on_choice", 0)
	_story.call("_after_result")
	var transition_portrait := _story.get(
		"_story_transition_portrait_snapshot") as TextureRect
	if not bool(_story.get("_story_scene_transition_active")) \
			or str(_story.get("_story_ink_transition_kind")) != "time_cut":
		_fail("flashforward follow-up did not begin the authored time cut")
		return
	if transition_portrait == null or not transition_portrait.visible \
			or transition_portrait.texture == null:
		_fail("time cut did not preserve the outgoing silhouette snapshot")
		return
	var transition_treatment := transition_portrait.modulate
	if not _silhouette_treatment_is_safe(transition_treatment):
		_fail("time cut snapshot restored the protagonist face treatment")
		return
	_story.call("_set_story_ink_transition_progress", 0.50)
	transition_treatment = transition_portrait.modulate
	if not _silhouette_treatment_is_safe(transition_treatment):
		_fail("time cut midpoint brightened the protagonist face treatment")
		return
	await get_tree().process_frame
	current = _story.get("_current")
	if str(current.get("id", "")) != "story_arrival":
		_fail("flashforward did not continue to story_arrival")
		return
	if bool(_story.get("_story_visual_override_active")):
		_fail("scene-local override leaked into story_arrival")
		return
	if hud_panel == null or not hud_panel.visible:
		_fail("story_arrival did not restore the present-day HUD")
		return
	if portrait == null or portrait.modulate != Color.WHITE or name_panel == null or not name_panel.visible:
		_fail("story_arrival did not restore portrait identity treatment")
		return
	if not is_zero_approx(float(_story.get("_story_moral_norm"))):
		_fail("story_arrival did not return to persistent Gray state")
		return
	var arrival_brightness := float(bg_material.get_shader_parameter("brightness"))
	if arrival_brightness <= black_brightness + 0.05 or arrival_brightness > 1.16:
		_fail("story_arrival background did not restore a brighter Gray treatment")
		return
	if not is_equal_approx(GameState.moral_tint, original_tint):
		_fail("follow-up transition polluted persistent moral_tint")
		return

	_story.queue_free()
	await get_tree().process_frame
	print("FLASHFORWARD_VISUAL_OK local=-0.80 arrival=0.00 save_clean=1")
	get_tree().quit(0)

func _fail(message: String) -> void:
	push_error("FLASHFORWARD_VISUAL_FAIL " + message)
	get_tree().quit(1)

func _silhouette_treatment_is_safe(treatment: Color) -> bool:
	return treatment.r <= 0.1 and treatment.g <= 0.1 \
		and treatment.b <= 0.1 and treatment.a <= 0.8
