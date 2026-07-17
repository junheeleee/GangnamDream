extends Node
## LivingSceneCheck — semantic effect routing, moral behavior, and motion safety.

var _failures: Array[String] = []

func _ready() -> void:
	_check_effect_routing()
	_check_precipitation_direction_contract()
	_check_camera_and_accessibility()
	_check_moral_behavior()
	_check_runtime_layer()
	if _failures.is_empty():
		print("LIVING_SCENE_CHECK_OK profiles=5 blur_cap=2.0 semantic_only=true")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("LIVING_SCENE_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)

func _check_precipitation_direction_contract() -> void:
	var source := FileAccess.get_file_as_string(
		"res://assets/shaders/living_scene_fx.gdshader")
	_expect(source.contains("p.y -= t * 8.5;"),
		"rain shader does not move visible streaks down in canvas UV")
	_expect(source.contains("p.y -= t * fall_speed;"),
		"snow shader does not move visible flakes down in canvas UV")

func _check_effect_routing() -> void:
	_expect_effect(
		{"id": "kx_monsoon", "background": "street_rainy", "tags": ["season"]},
		"street_rainy", "", {}, "rain")
	_expect_effect(
		{"id": "arc_season_snow_daeun", "background": "convenience_first_snow_exterior"},
		"convenience_first_snow_exterior", "cg_romance_first_snow_daeun", {}, "snow")
	_expect_effect(
		DataRegistry.find_event("arc_season_fireworks_jiyeon"),
		"hangang_riverside", "", {}, "none")
	_expect_effect(
		DataRegistry.find_event("arc_season_fireworks_jiyeon_decision"),
		"hangang_riverside", "cg_romance_fireworks_jiyeon", {}, "fireworks")
	_expect_effect(
		{"id": "qa_memory", "background": "goshiwon_room"},
		"goshiwon_room", "", {"channel": "memory", "portrait_role": "remote"}, "memory")
	_expect_effect(
		{"id": "qa_office", "background": "office", "description": "The rain comparison is only a sentence."},
		"office", "", {"channel": "in_person", "portrait_role": "present"}, "none")

func _check_camera_and_accessibility() -> void:
	var explicit := LivingSceneLayer.build_profile(
		{"id": "qa_authored", "direction": {"camera": "slow_zoom"}},
		"office", "", {}, 0.0, false, false)
	_expect(str(explicit.get("camera")) == "slow_zoom", "authored camera was replaced")
	_expect(str(explicit.get("camera_source")) == "authored", "authored camera source was lost")

	var reduced := LivingSceneLayer.build_profile(
		{"id": "kx_monsoon", "background": "street_rainy"},
		"street_rainy", "", {"channel": "in_person", "portrait_role": "present"},
		0.0, false, true)
	_expect(str(reduced.get("camera")) == "none", "reduced motion kept camera travel")
	_expect(float(reduced.get("motion_scale", 1.0)) <= 0.11, "reduced motion kept full particle speed")
	_expect(float(reduced.get("portrait_breath", 1.0)) == 0.0, "reduced motion kept portrait breathing")

	var in_person := LivingSceneLayer.build_profile(
		{"id": "qa_person"}, "cafe", "",
		{"channel": "in_person", "portrait_role": "present"}, 0.0, false, false)
	var phone := LivingSceneLayer.build_profile(
		{"id": "qa_phone"}, "goshiwon_room", "",
		{"channel": "phone", "portrait_role": "remote"}, 0.0, false, false)
	_expect(float(in_person.get("portrait_breath", 0.0)) > 0.0, "in-person portrait has no restrained idle")
	_expect(float(phone.get("portrait_breath", 1.0)) == 0.0, "remote portrait breathes like a local body")

func _check_moral_behavior() -> void:
	var event := {"id": "kx_monsoon", "background": "street_rainy"}
	var neutral := LivingSceneLayer.build_profile(event, "street_rainy", "", {}, 0.0, false, false)
	var black := LivingSceneLayer.build_profile(event, "street_rainy", "", {}, -1.0, false, false)
	var white := LivingSceneLayer.build_profile(event, "street_rainy", "", {}, 1.0, false, false)
	_expect(float(black.get("intensity")) < float(neutral.get("intensity")), "Black added decorative weather life")
	_expect(float(black.get("motion_scale")) < float(neutral.get("motion_scale")), "Black did not still the human world")
	_expect(float(black.get("afterimage")) > float(neutral.get("afterimage")), "Black has no mechanical afterimage")
	_expect(float(white.get("intensity")) >= float(neutral.get("intensity")), "White did not restore living air")
	for profile in [neutral, black, white]:
		_expect(float(profile.get("blur_px", 99.0)) <= 2.0, "background blur exceeded 2px")

func _check_runtime_layer() -> void:
	var layer := LivingSceneLayer.new()
	add_child(layer)
	var profile := layer.configure(
		DataRegistry.find_event("arc_season_fireworks_daeun_decision"),
		"hangang_riverside", "cg_romance_fireworks_daeun",
		{"channel": "in_person", "portrait_role": "present"}, 0.0, true, false)
	_expect(layer.visible, "active runtime layer is hidden")
	_expect(str(layer.get_meta("living_scene_effect", "")) == "fireworks", "runtime metadata lost effect")
	_expect(int(profile.get("effect_mode", -1)) == LivingSceneLayer.EffectMode.FIREWORKS, "runtime shader mode mismatch")
	var surface := layer.get_node_or_null("Atmosphere") as ColorRect
	_expect(is_instance_valid(surface) and surface.material is ShaderMaterial, "runtime shader surface missing")
	layer.clear_profile()
	_expect(not layer.visible, "cleared runtime layer stayed visible")
	layer.queue_free()

func _expect_effect(
		event: Dictionary,
		background_id: String,
		cg_id: String,
		presentation: Dictionary,
		expected: String) -> void:
	var profile := LivingSceneLayer.build_profile(
		event, background_id, cg_id, presentation, 0.0, not cg_id.is_empty(), false)
	_expect(str(profile.get("effect", "")) == expected,
		"%s expected %s, got %s" % [str(event.get("id", "<none>")), expected, str(profile.get("effect", ""))])

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
