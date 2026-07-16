class_name LivingSceneLayer
extends Control
## StoryMode background atmosphere. This layer never owns narrative state; it
## derives a restrained visual profile from the current event contract.

enum EffectMode {
	NONE,
	RAIN,
	SNOW,
	MEMORY,
	CITY_LIGHT,
	FIREWORKS,
}

const EFFECT_NAMES: Array[String] = [
	"none", "rain", "snow", "memory", "city_light", "fireworks",
]
const EFFECT_BY_NAME := {
	"none": EffectMode.NONE,
	"rain": EffectMode.RAIN,
	"snow": EffectMode.SNOW,
	"memory": EffectMode.MEMORY,
	"city_light": EffectMode.CITY_LIGHT,
	"fireworks": EffectMode.FIREWORKS,
}
const RAIN_TOKENS: Array[String] = [
	"monsoon", "rainy", "street_rain", "rain_commute", "wallet_00",
]
const SNOW_TOKENS: Array[String] = [
	"first_snow", "season_snow", "snowfall",
]
const FIREWORK_TOKENS: Array[String] = [
	"fireworks", "firework_festival",
]
const CITY_TOKENS: Array[String] = [
	"gangnam_night", "namsan_", "rooftop_night", "hangang_night",
	"hangang_riverside", "night_street",
]

var current_profile: Dictionary = {}
var _fx_rect: ColorRect = null
var _fx_material: ShaderMaterial = null

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ensure_surface()

func _ensure_surface() -> void:
	if is_instance_valid(_fx_rect):
		return
	_fx_rect = ColorRect.new()
	_fx_rect.name = "Atmosphere"
	_fx_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fx_rect.color = Color.WHITE
	_fx_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader: Shader = load("res://assets/shaders/living_scene_fx.gdshader") as Shader
	if shader:
		_fx_material = ShaderMaterial.new()
		_fx_material.shader = shader
		_fx_rect.material = _fx_material
	add_child(_fx_rect)

func configure(
		event: Dictionary,
		background_id: String,
		cg_id: String,
		presentation: Dictionary,
		moral_norm: float,
		has_cg: bool,
		reduced_motion: bool = false) -> Dictionary:
	_ensure_surface()
	current_profile = build_profile(
		event, background_id, cg_id, presentation, moral_norm, has_cg, reduced_motion)
	_apply_profile(current_profile)
	return current_profile

func update_moral(moral_norm: float) -> void:
	if current_profile.is_empty():
		return
	var profile := current_profile.duplicate(true)
	var base_intensity := float(profile.get("base_intensity", 0.0))
	var black := clampf(-moral_norm, 0.0, 1.0)
	var white := clampf(moral_norm, 0.0, 1.0)
	var reduced_motion := bool(profile.get("reduced_motion", false))
	var accessibility_motion := 0.10 if reduced_motion else 1.0
	var accessibility_intensity := 0.58 if reduced_motion else 1.0
	profile["moral_black"] = black
	profile["moral_white"] = white
	profile["intensity"] = base_intensity * clampf(1.0 - black * 0.64 + white * 0.12, 0.24, 1.12) * accessibility_intensity
	profile["motion_scale"] = clampf(1.0 - black * 0.72 + white * 0.10, 0.16, 1.10) * accessibility_motion
	profile["afterimage"] = clampf(float(profile.get("memory_afterimage", 0.0)) + black * 0.055, 0.0, 0.10)
	profile["blur_px"] = clampf(float(profile.get("base_blur_px", 0.0)) + black * 0.35, 0.0, 2.0)
	profile["portrait_breath"] = float(profile.get("base_portrait_breath", 0.0)) \
		* clampf(1.0 - black * 0.78 + white * 0.12, 0.16, 1.12) \
		* (0.0 if reduced_motion else 1.0)
	current_profile = profile
	_apply_profile(current_profile)

func clear_profile() -> void:
	current_profile = {}
	visible = false
	set_meta("living_scene_profile", {})
	set_meta("living_scene_effect", "none")
	set_meta("living_scene_active", false)

func _apply_profile(profile: Dictionary) -> void:
	if not _fx_material:
		visible = false
		return
	var effect_mode := int(profile.get("effect_mode", EffectMode.NONE))
	var intensity := float(profile.get("intensity", 0.0))
	var afterimage := float(profile.get("afterimage", 0.0))
	visible = effect_mode != EffectMode.NONE or afterimage > 0.001
	_fx_material.set_shader_parameter("effect_mode", effect_mode)
	_fx_material.set_shader_parameter("intensity", intensity)
	_fx_material.set_shader_parameter("motion_scale", float(profile.get("motion_scale", 1.0)))
	_fx_material.set_shader_parameter("seed", float(profile.get("seed", 0.0)))
	_fx_material.set_shader_parameter("moral_black", float(profile.get("moral_black", 0.0)))
	_fx_material.set_shader_parameter("moral_white", float(profile.get("moral_white", 0.0)))
	_fx_material.set_shader_parameter("afterimage_strength", afterimage)
	_fx_material.set_shader_parameter("portrait_safe", float(profile.get("portrait_safe", 0.0)))
	set_meta("living_scene_profile", profile.duplicate(true))
	set_meta("living_scene_effect", str(profile.get("effect", "none")))
	set_meta("living_scene_active", visible)

static func build_profile(
		event: Dictionary,
		background_id: String,
		cg_id: String,
		presentation: Dictionary,
		moral_norm: float,
		has_cg: bool,
		reduced_motion: bool = false) -> Dictionary:
	var event_id := str(event.get("id", "")).to_lower()
	var channel := str(presentation.get("channel", "in_person")).to_lower()
	var token_blob := _visual_token_blob(event, background_id, cg_id)
	var authored: Dictionary = event.get("living_scene", {}) if event.get("living_scene", {}) is Dictionary else {}
	var effect := str(authored.get("effect", "")).to_lower()
	if not EFFECT_BY_NAME.has(effect):
		if _contains_any(token_blob, FIREWORK_TOKENS):
			effect = "fireworks"
		elif _contains_any(token_blob, SNOW_TOKENS):
			effect = "snow"
		elif _contains_any(token_blob, RAIN_TOKENS):
			effect = "rain"
		elif channel == "memory" or bool(authored.get("memory", false)):
			effect = "memory"
		elif _contains_any(token_blob, CITY_TOKENS):
			effect = "city_light"
		else:
			effect = "none"

	var base_intensity := 0.0
	var base_blur_px := 0.0
	var memory_afterimage := 0.0
	match effect:
		"rain":
			base_intensity = 0.29 if not has_cg else 0.20
		"snow":
			base_intensity = 0.27 if not has_cg else 0.18
		"memory":
			base_intensity = 0.24
			base_blur_px = 1.10 if not has_cg else 0.65
			memory_afterimage = 0.025
		"city_light":
			base_intensity = 0.14 if not has_cg else 0.08
		"fireworks":
			base_intensity = 0.18 if not has_cg else 0.10
	base_intensity = clampf(float(authored.get("intensity", base_intensity)), 0.0, 0.65)
	base_blur_px = clampf(float(authored.get("blur_px", base_blur_px)), 0.0, 2.0)

	var black := clampf(-moral_norm, 0.0, 1.0)
	var white := clampf(moral_norm, 0.0, 1.0)
	var intensity := base_intensity * clampf(1.0 - black * 0.64 + white * 0.12, 0.24, 1.12)
	var motion_scale := clampf(1.0 - black * 0.72 + white * 0.10, 0.16, 1.10)
	if reduced_motion:
		motion_scale *= 0.10
		intensity *= 0.58

	var raw_direction: Variant = event.get("direction", {})
	var direction: Dictionary = raw_direction if raw_direction is Dictionary else {}
	var authored_camera := str(direction.get("camera", "")).strip_edges()
	var camera := authored_camera
	var camera_source := "authored" if not authored_camera.is_empty() else "inferred"
	if camera.is_empty():
		match effect:
			"rain", "city_light": camera = "living_drift"
			"snow", "memory", "fireworks": camera = "living_push"
			_:
				camera = "living_push" if abs(event_id.hash()) % 2 == 0 else "living_drift"
	if reduced_motion:
		camera = "none"
		camera_source = "accessibility"

	var portrait_role := str(presentation.get("portrait_role", "present"))
	var base_portrait_breath := 0.003
	if channel != "in_person" or portrait_role in ["remote", "none"] or has_cg or reduced_motion:
		base_portrait_breath = 0.0
	var portrait_breath := base_portrait_breath \
		* clampf(1.0 - black * 0.78 + white * 0.12, 0.16, 1.12)

	var seed_value := float(abs(event_id.hash()) % 997) / 997.0
	return {
		"effect": effect,
		"effect_mode": int(EFFECT_BY_NAME.get(effect, EffectMode.NONE)),
		"base_intensity": base_intensity,
		"intensity": intensity,
		"base_blur_px": base_blur_px,
		"blur_px": clampf(base_blur_px + black * 0.35, 0.0, 2.0),
		"memory_afterimage": memory_afterimage,
		"afterimage": clampf(memory_afterimage + black * 0.055, 0.0, 0.10),
		"motion_scale": motion_scale,
		"camera": camera,
		"camera_source": camera_source,
		"camera_amount": (0.010 if has_cg else 0.015) * clampf(1.0 - black * 0.58 + white * 0.08, 0.30, 1.08),
		"base_portrait_breath": base_portrait_breath,
		"portrait_breath": portrait_breath,
		"portrait_safe": 0.0 if has_cg or portrait_role == "none" else 1.0,
		"moral_black": black,
		"moral_white": white,
		"seed": seed_value,
		"reduced_motion": reduced_motion,
	}

static func _visual_token_blob(event: Dictionary, background_id: String, cg_id: String) -> String:
	var parts: Array[String] = [
		str(event.get("id", "")), background_id, cg_id,
		str(event.get("background", "")), str(event.get("cg", "")),
	]
	var tags: Variant = event.get("tags", [])
	if tags is Array:
		for raw_tag in tags:
			parts.append(str(raw_tag))
	return " ".join(parts).to_lower()

static func _contains_any(haystack: String, tokens: Array[String]) -> bool:
	for token in tokens:
		if token in haystack:
			return true
	return false
