extends CanvasLayer

# 전역 씬 전환 페이드인/아웃.
# Gangnam Ink: 검정/회색/흰색 moral surface를 씬 이동에서도 유지한다.
# 사용: SceneTransition.go("res://scenes/MainGame.tscn")
# 새 씬에서 페이드인: SceneTransition.fade_in()

const BuildFlavorScript := preload("res://systems/BuildFlavor.gd")

var _overlay: ColorRect
var _texture_layer: Control
var _playtest_marker: PanelContainer
var _playtest_marker_text: Label
var _playtest_marker_context := "default"
var _tween: Tween
var _transition_alpha: float = 0.0
const FADE_TIME := 0.35
const PLAYTEST_MARKER_CONTEXT_DEFAULT := "default"
const PLAYTEST_MARKER_CONTEXT_STORY := "story"
const PLAYTEST_MARKER_CONTEXT_NOTICE := "notice"
const PLAYTEST_MARKER_CONTEXT_PLANNER := "planner"

func _ready():
	layer = 128  # 최상단 (모달 등 위)
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)
	_texture_layer = Control.new()
	_texture_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_texture_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_texture_layer.visible = false
	_texture_layer.draw.connect(_draw_transition_texture)
	add_child(_texture_layer)
	_build_playtest_marker()

func _build_playtest_marker() -> void:
	if not BuildFlavorScript.is_core_loop_v2_playtest_build():
		return
	_playtest_marker = UIStyle.make_panel(
		UIStyle.C_BG_PANEL, UIStyle.C_ACCENT_GOLD)
	_playtest_marker.name = "CoreLoopV2PlaytestMarker"
	_playtest_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_playtest_marker.z_index = 1000
	_playtest_marker.set_meta(
		"build_flavor", BuildFlavorScript.PLAYTEST_FLAVOR_ID)
	_playtest_marker.set_meta(
		"save_namespace", BuildFlavorScript.PLAYTEST_SAVE_NAMESPACE)
	add_child(_playtest_marker)

	_playtest_marker_text = UIStyle.make_label(
		"", 12, UIStyle.C_ACCENT_GOLD, true,
		HORIZONTAL_ALIGNMENT_CENTER)
	_playtest_marker_text.name = "PlaytestMarkerText"
	_playtest_marker_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_playtest_marker_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_playtest_marker.add_child(_playtest_marker_text)
	_apply_playtest_marker_context()
	_refresh_playtest_marker()

	var language_callback := Callable(self, "_on_playtest_marker_language_changed")
	if not LocaleManager.language_changed.is_connected(language_callback):
		LocaleManager.language_changed.connect(language_callback)

func _on_playtest_marker_language_changed(_lang: String) -> void:
	_refresh_playtest_marker()

func set_playtest_marker_context(context: String) -> void:
	if context not in [
		PLAYTEST_MARKER_CONTEXT_DEFAULT,
		PLAYTEST_MARKER_CONTEXT_STORY,
		PLAYTEST_MARKER_CONTEXT_NOTICE,
		PLAYTEST_MARKER_CONTEXT_PLANNER,
	]:
		context = PLAYTEST_MARKER_CONTEXT_DEFAULT
	_playtest_marker_context = context
	_apply_playtest_marker_context()
	_refresh_playtest_marker()

func _apply_playtest_marker_context() -> void:
	if not is_instance_valid(_playtest_marker):
		return
	_playtest_marker.set_meta("marker_context", _playtest_marker_context)
	# The legal notice already prints the canonical build identity in its header.
	# The planner fills its header and footer with navigation controls. Hiding the
	# floating badge on those two self-contained surfaces prevents it from
	# covering player input without weakening the title-screen build disclosure.
	_playtest_marker.visible = _playtest_marker_context not in [
		PLAYTEST_MARKER_CONTEXT_NOTICE,
		PLAYTEST_MARKER_CONTEXT_PLANNER,
	]
	match _playtest_marker_context:
		PLAYTEST_MARKER_CONTEXT_STORY:
			# StoryMode already owns the right side of its 48px HUD with two
			# commands. Dock a compact badge in a reserved left slot instead.
			_playtest_marker.set_anchors_preset(Control.PRESET_TOP_LEFT)
			_playtest_marker.offset_left = 18.0
			_playtest_marker.offset_top = 10.0
			_playtest_marker.offset_right = 118.0
			_playtest_marker.offset_bottom = 38.0
		PLAYTEST_MARKER_CONTEXT_NOTICE:
			# The notice header's top-right corner contains its Close command.
			# Its footer keeps a dedicated empty right edge for this compact badge.
			_playtest_marker.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
			_playtest_marker.offset_left = -132.0
			_playtest_marker.offset_top = -42.0
			_playtest_marker.offset_right = -18.0
			_playtest_marker.offset_bottom = -12.0
		PLAYTEST_MARKER_CONTEXT_PLANNER:
			# Hidden above; keep deterministic geometry for metadata/QA inspection.
			_playtest_marker.set_anchors_preset(Control.PRESET_TOP_RIGHT)
			_playtest_marker.offset_left = -132.0
			_playtest_marker.offset_top = 12.0
			_playtest_marker.offset_right = -18.0
			_playtest_marker.offset_bottom = 40.0
		_:
			_playtest_marker.set_anchors_preset(Control.PRESET_TOP_RIGHT)
			_playtest_marker.offset_left = -316.0
			_playtest_marker.offset_top = 18.0
			_playtest_marker.offset_right = -18.0
			_playtest_marker.offset_bottom = 52.0

func _refresh_playtest_marker() -> void:
	if not is_instance_valid(_playtest_marker_text):
		return
	var compact := _playtest_marker_context in [
		PLAYTEST_MARKER_CONTEXT_STORY,
		PLAYTEST_MARKER_CONTEXT_NOTICE,
		PLAYTEST_MARKER_CONTEXT_PLANNER,
	]
	if compact:
		_playtest_marker_text.text = (
			"V2 TEST" if LocaleManager.is_english() else "V2 테스트")
	else:
		_playtest_marker_text.text = (
			"V2 TEST BUILD · SEPARATE SAVE"
			if LocaleManager.is_english()
			else "V2 테스트 빌드 · 별도 저장"
		)

# 씬 전환: 페이드아웃 → 씬 변경
func go(scene_path: String):
	if _tween:
		_tween.kill()
	AudioManager.play_ui_close(-12.0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_tween = create_tween()
	_tween.tween_method(_set_transition_alpha, _transition_alpha, 1.0, _fade_time_for_state())
	_tween.tween_callback(func():
		get_tree().change_scene_to_file(scene_path)
	)

## 이미 화면이 완전히 덮인 상태에서 중간 씬을 노출하지 않고 다음 씬으로 넘긴다.
## 연속 StoryMode 큐가 MainGame/AP 화면을 한 프레임 비추는 것을 막는 용도다.
func go_covered(scene_path: String) -> void:
	if _tween:
		_tween.kill()
		_tween = null
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_set_transition_alpha(1.0)
	get_tree().call_deferred("change_scene_to_file", scene_path)

# 새 씬 로드 후 페이드인 — 각 씬의 _ready() 마지막에 호출
func fade_in():
	if _tween:
		_tween.kill()
	_set_transition_alpha(1.0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tween = create_tween()
	_tween.tween_method(_set_transition_alpha, 1.0, 0.0, _fade_time_for_state())
	_tween.tween_callback(func():
		_texture_layer.visible = false
	)

func _set_transition_alpha(alpha: float) -> void:
	_transition_alpha = clampf(alpha, 0.0, 1.0)
	_overlay.color = _transition_color(_transition_alpha)
	if _texture_layer:
		_texture_layer.visible = _transition_alpha > 0.01
		_texture_layer.modulate.a = _transition_alpha
		_texture_layer.queue_redraw()

func _transition_color(alpha: float) -> Color:
	var stage: int = GameState.moral_stage()
	var norm: float = GameState.moral_tint_norm()
	var black: float = clampf(-norm, 0.0, 1.0)
	var white: float = clampf(norm, 0.0, 1.0)
	var base := Color("#050609")
	if stage <= -2:
		base = Color("#020303")
	elif stage == -1:
		base = Color("#050807")
	elif stage >= 2:
		base = Color("#eef6ff")
	elif stage == 1:
		base = Color("#cfd8df")
	else:
		base = Color("#0a0b0f")
	var cover_alpha: float = alpha
	if white > 0.01:
		cover_alpha = alpha * lerpf(0.92, 0.98, white)
	if black > 0.01:
		cover_alpha = alpha * lerpf(0.96, 1.0, black)
	base.a = cover_alpha
	return base

func _fade_time_for_state() -> float:
	var stage: int = GameState.moral_stage()
	if stage <= -2:
		return 0.44
	if stage >= 2:
		return 0.42
	return FADE_TIME

func _draw_transition_texture() -> void:
	if _transition_alpha <= 0.01:
		return
	var size: Vector2 = _texture_layer.size
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var stage: int = GameState.moral_stage()
	var norm: float = GameState.moral_tint_norm()
	var black: float = clampf(-norm, 0.0, 1.0)
	var white: float = clampf(norm, 0.0, 1.0)
	var neutral: float = 1.0 - maxf(black, white)
	# Keep transitions matte. Visible scan/page lines looked like a rendering glitch during play.
	if neutral > 0.15:
		_texture_layer.draw_rect(Rect2(Vector2.ZERO, size), Color(1, 1, 1, 0.010 * neutral * _transition_alpha), true)
	if black > 0.01:
		var edge_alpha: float = (0.10 + black * 0.18) * _transition_alpha
		var edge := Color("#000000", edge_alpha)
		_texture_layer.draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, 18.0 + black * 18.0)), edge, true)
		_texture_layer.draw_rect(Rect2(Vector2(0.0, size.y - 18.0 - black * 18.0), Vector2(size.x, 18.0 + black * 18.0)), edge, true)
		_texture_layer.draw_rect(Rect2(Vector2.ZERO, Vector2(16.0 + black * 18.0, size.y)), edge, true)
		_texture_layer.draw_rect(Rect2(Vector2(size.x - 16.0 - black * 18.0, 0.0), Vector2(16.0 + black * 18.0, size.y)), edge, true)
	if white > 0.01:
		var glow_alpha: float = (0.055 + white * 0.10) * _transition_alpha
		_texture_layer.draw_rect(Rect2(Vector2.ZERO, size), Color("#ffffff", glow_alpha), true)
