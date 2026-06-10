extends Node
## DisplayManager — 데스크톱 디스플레이 설정
## 전체화면 상태 영속화 + F11/Alt+Enter 전역 토글 + 창 최소 크기.
## 창 X 버튼으로 닫을 때 진행 중 런이 있으면 자동저장.

const SETTINGS_PATH = "user://gangnam_dream_display.json"
const MIN_WINDOW_SIZE = Vector2i(960, 600)

var fullscreen: bool = false

func _ready():
	if OS.has_feature("web"):
		# 웹은 브라우저가 전체화면을 관리한다 (F11 충돌 방지)
		set_process_input(false)
		return
	get_window().min_size = MIN_WINDOW_SIZE
	_load_settings()
	if fullscreen:
		_apply_mode()

func _input(event):
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var is_f11 = event.keycode == KEY_F11
	var is_alt_enter = event.keycode == KEY_ENTER and event.alt_pressed
	if is_f11 or is_alt_enter:
		toggle_fullscreen()
		get_viewport().set_input_as_handled()

func toggle_fullscreen():
	set_fullscreen(not fullscreen)

func set_fullscreen(on: bool):
	if OS.has_feature("web"):
		return
	fullscreen = on
	_apply_mode()
	_save_settings()

func _apply_mode():
	var mode = DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)

func _load_settings():
	if FileAccess.file_exists(SETTINGS_PATH):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(SETTINGS_PATH))
		if parsed is Dictionary:
			fullscreen = bool(parsed.get("fullscreen", false))

func _save_settings():
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"fullscreen": fullscreen}))

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		var scene = get_tree().current_scene
		if scene and scene.scene_file_path == "res://scenes/MainGame.tscn" and not GameState.is_game_over:
			SaveManager.autosave()
