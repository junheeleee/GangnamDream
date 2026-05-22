extends CanvasLayer

# 전역 씬 전환 페이드인/아웃
# 사용: SceneTransition.go("res://scenes/MainGame.tscn")
# 새 씬에서 페이드인: SceneTransition.fade_in()

var _overlay: ColorRect
var _tween: Tween
const FADE_TIME := 0.35

func _ready():
	layer = 128  # 최상단 (모달 등 위)
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)

# 씬 전환: 페이드아웃 → 씬 변경
func go(scene_path: String):
	if _tween:
		_tween.kill()
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_tween = create_tween()
	_tween.tween_property(_overlay, "color", Color(0, 0, 0, 1.0), FADE_TIME)
	_tween.tween_callback(func():
		get_tree().change_scene_to_file(scene_path)
	)

# 새 씬 로드 후 페이드인 — 각 씬의 _ready() 마지막에 호출
func fade_in():
	if _tween:
		_tween.kill()
	_overlay.color = Color(0, 0, 0, 1.0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tween = create_tween()
	_tween.tween_property(_overlay, "color", Color(0, 0, 0, 0.0), FADE_TIME)
