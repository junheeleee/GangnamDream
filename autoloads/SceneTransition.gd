extends CanvasLayer

# 전역 씬 전환 페이드인/아웃.
# Gangnam Ink: 검정/회색/흰색 moral surface를 씬 이동에서도 유지한다.
# 사용: SceneTransition.go("res://scenes/MainGame.tscn")
# 새 씬에서 페이드인: SceneTransition.fade_in()

var _overlay: ColorRect
var _texture_layer: Control
var _tween: Tween
var _transition_alpha: float = 0.0
const FADE_TIME := 0.35

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
	var line_alpha: float = 0.07 + black * 0.10 + white * 0.06
	var line_color := Color(1, 1, 1, line_alpha)
	if stage <= -1:
		line_color = Color("#8e9892", line_alpha)
	elif stage >= 1:
		line_color = Color("#ffffff", line_alpha)

	# Thin paper/receipt lines. They make scene changes feel like a page sliding under glass.
	var gap: int = 26
	var offset: float = fmod(float(GameState.turn * 7), float(gap))
	for y in range(-gap, int(size.y) + gap, gap):
		var yy: float = float(y) + offset
		var jitter: float = sin(yy * 0.037 + float(GameState.turn)) * (1.0 + black * 3.0)
		_texture_layer.draw_line(Vector2(0.0, yy + jitter), Vector2(size.x, yy - jitter), line_color, 1.0)

	# Neutral routes keep the transition matte; Black routes add edge burn, White routes add clarity.
	if neutral > 0.15:
		_texture_layer.draw_rect(Rect2(Vector2.ZERO, size), Color(1, 1, 1, 0.018 * neutral), false, 1.0)
	if black > 0.01:
		var edge_alpha: float = (0.10 + black * 0.18) * _transition_alpha
		var edge := Color("#000000", edge_alpha)
		_texture_layer.draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, 18.0 + black * 18.0)), edge, true)
		_texture_layer.draw_rect(Rect2(Vector2(0.0, size.y - 18.0 - black * 18.0), Vector2(size.x, 18.0 + black * 18.0)), edge, true)
		_texture_layer.draw_rect(Rect2(Vector2.ZERO, Vector2(16.0 + black * 18.0, size.y)), edge, true)
		_texture_layer.draw_rect(Rect2(Vector2(size.x - 16.0 - black * 18.0, 0.0), Vector2(16.0 + black * 18.0, size.y)), edge, true)
		for i in range(8):
			var x: float = size.x * (float(i) + 0.5) / 8.0
			var h: float = 26.0 + 18.0 * sin(float(i) * 1.7 + float(GameState.turn))
			_texture_layer.draw_line(Vector2(x, 0.0), Vector2(x + sin(float(i)) * 10.0, h), Color("#151817", 0.14 * black), 2.0)
	if white > 0.01:
		var glow_alpha: float = (0.055 + white * 0.10) * _transition_alpha
		_texture_layer.draw_rect(Rect2(Vector2.ZERO, size), Color("#ffffff", glow_alpha), false, 2.0)
