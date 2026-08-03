extends Node
## DisplayManager — 데스크톱 디스플레이 설정
## 창 모드·해상도 영속화 + F11/Alt+Enter 전역 토글 + 창 최소 크기.
## 창 X 버튼으로 닫을 때 진행 중 런이 있으면 자동저장.

signal display_settings_changed(snapshot: Dictionary)

const BUILD_FLAVOR := preload("res://systems/BuildFlavor.gd")
# Compatibility constant for tools that explicitly inspect legacy retail
# data. Production persistence uses display_settings_path().
const SETTINGS_PATH = BUILD_FLAVOR.RETAIL_DISPLAY_SETTINGS_PATH
const MIN_WINDOW_SIZE = Vector2i(960, 600)
const WINDOW_MODES: Array[String] = ["windowed", "borderless", "fullscreen"]
const WINDOW_RESOLUTIONS: Array[Vector2i] = [
	Vector2i(960, 600),
	Vector2i(1280, 720),
	Vector2i(1280, 800),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3440, 1440),
	Vector2i(3840, 2160),
]

var fullscreen: bool = false
var window_mode: String = "windowed"
var window_resolution: Vector2i = Vector2i(1280, 800)

func _ready() -> void:
	if OS.has_feature("web"):
		# 웹은 브라우저가 전체화면을 관리한다 (F11 충돌 방지)
		set_process_input(false)
		return
	get_window().min_size = MIN_WINDOW_SIZE
	_load_settings()
	if not _is_qa_run():
		_apply_mode()

func _input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var is_f11: bool = event.keycode == KEY_F11
	var is_alt_enter: bool = event.keycode == KEY_ENTER and event.alt_pressed
	if is_f11 or is_alt_enter:
		toggle_fullscreen()
		get_viewport().set_input_as_handled()

func toggle_fullscreen() -> void:
	set_fullscreen(not fullscreen)

func set_fullscreen(on: bool) -> void:
	set_window_mode("fullscreen" if on else "windowed")

func set_window_mode(mode: String) -> void:
	if OS.has_feature("web"):
		return
	window_mode = mode if WINDOW_MODES.has(mode) else "windowed"
	fullscreen = window_mode == "fullscreen"
	_apply_mode()
	_save_settings()
	display_settings_changed.emit(settings_snapshot())

func set_window_mode_index(index: int) -> void:
	set_window_mode(WINDOW_MODES[clampi(index, 0, WINDOW_MODES.size() - 1)])

func window_mode_index() -> int:
	var index: int = WINDOW_MODES.find(window_mode)
	return maxi(index, 0)

func set_window_resolution(value: Vector2i) -> void:
	if OS.has_feature("web"):
		return
	window_resolution = _nearest_supported_resolution(value)
	if window_mode == "windowed":
		_apply_windowed_size()
	_save_settings()
	display_settings_changed.emit(settings_snapshot())

func set_resolution_index(index: int) -> void:
	set_window_resolution(WINDOW_RESOLUTIONS[clampi(index, 0, WINDOW_RESOLUTIONS.size() - 1)])

func resolution_index() -> int:
	var index: int = WINDOW_RESOLUTIONS.find(window_resolution)
	return maxi(index, 0)

func settings_snapshot() -> Dictionary:
	return {
		"window_mode": window_mode,
		"fullscreen": fullscreen,
		"width": window_resolution.x,
		"height": window_resolution.y,
	}

func resolution_label(index: int) -> String:
	var size: Vector2i = WINDOW_RESOLUTIONS[clampi(index, 0, WINDOW_RESOLUTIONS.size() - 1)]
	var aspect_label := ""
	if size in [Vector2i(960, 600), Vector2i(1280, 800)]:
		aspect_label = " (16:10)"
	elif size == Vector2i(3440, 1440):
		aspect_label = " (21:9)"
	return "%d × %d%s" % [
		size.x, size.y, aspect_label]

func tv_safe_rect(viewport_size: Vector2, margin_ratio: float = 0.025) -> Rect2:
	var margin := Vector2(
		maxf(16.0, viewport_size.x * margin_ratio),
		maxf(16.0, viewport_size.y * margin_ratio))
	return Rect2(margin, viewport_size - margin * 2.0)

func _apply_mode() -> void:
	if _is_headless() or _is_qa_process():
		return
	match window_mode:
		"fullscreen":
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		"borderless":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			var usable: Rect2i = _usable_screen_rect()
			DisplayServer.window_set_position(usable.position)
			DisplayServer.window_set_size(usable.size)
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			_apply_windowed_size()

func _apply_windowed_size() -> void:
	if _is_headless():
		return
	var usable: Rect2i = _usable_screen_rect()
	var margin := Vector2i(48, 72)
	var maximum := Vector2i(
		maxi(MIN_WINDOW_SIZE.x, usable.size.x - margin.x),
		maxi(MIN_WINDOW_SIZE.y, usable.size.y - margin.y))
	var target := Vector2i(
		clampi(window_resolution.x, MIN_WINDOW_SIZE.x, maximum.x),
		clampi(window_resolution.y, MIN_WINDOW_SIZE.y, maximum.y))
	DisplayServer.window_set_size(target)
	DisplayServer.window_set_position(usable.position + (usable.size - target) / 2)

func _usable_screen_rect() -> Rect2i:
	var screen: int = DisplayServer.window_get_current_screen()
	var usable: Rect2i = DisplayServer.screen_get_usable_rect(screen)
	if usable.size.x <= 0 or usable.size.y <= 0:
		return Rect2i(Vector2i.ZERO, window_resolution)
	return usable

func _is_headless() -> bool:
	return DisplayServer.get_name().to_lower() == "headless"

func _is_qa_process() -> bool:
	var args: PackedStringArray = OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	for raw in args:
		var arg := str(raw).to_lower()
		if "--qa" in arg or "qa=" in arg or "--scope" in arg:
			return true
	return false

func _is_qa_run() -> bool:
	for raw in OS.get_cmdline_user_args():
		var arg := str(raw).to_lower()
		if "--qa=" in arg or "--scope=" in arg or "--display-matrix" in arg:
			return true
	return false

func _nearest_supported_resolution(value: Vector2i) -> Vector2i:
	var best: Vector2i = WINDOW_RESOLUTIONS[0]
	var best_distance: int = abs(best.x - value.x) + abs(best.y - value.y)
	for candidate in WINDOW_RESOLUTIONS:
		var distance: int = abs(candidate.x - value.x) + abs(candidate.y - value.y)
		if distance < best_distance:
			best = candidate
			best_distance = distance
	return best

func _load_settings() -> void:
	var path := display_settings_path()
	if FileAccess.file_exists(path):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if parsed is Dictionary:
			var legacy_fullscreen: bool = bool(parsed.get("fullscreen", false))
			window_mode = str(parsed.get(
				"window_mode", "fullscreen" if legacy_fullscreen else "windowed"))
			if not WINDOW_MODES.has(window_mode):
				window_mode = "windowed"
			window_resolution = _nearest_supported_resolution(Vector2i(
				int(parsed.get("width", 1280)), int(parsed.get("height", 800))))
	fullscreen = window_mode == "fullscreen"

func _save_settings() -> void:
	var file := FileAccess.open(display_settings_path(), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings_snapshot()))

func display_settings_path() -> String:
	return BUILD_FLAVOR.display_settings_path()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		var scene := get_tree().current_scene
		if scene and scene.scene_file_path == "res://scenes/MainGame.tscn" and not GameState.is_game_over:
			SaveManager.autosave()
		get_tree().quit()
