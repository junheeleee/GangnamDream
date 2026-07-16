extends Node
## ControllerHints — 연결된 패드 브랜드를 감지해 올바른 버튼 레이블을 반환한다.
## Xbox A/B/X/Y · PS ✕/○/□/△ · Nintendo B/A/Y/X · Steam Deck(= Xbox 레이블)

enum Brand { GENERIC, XBOX, PLAYSTATION, NINTENDO }
enum InputMode { KEYBOARD_MOUSE, GAMEPAD }

signal input_mode_changed(mode: InputMode, brand: Brand)

var _brand: Brand = Brand.GENERIC
var _input_mode: InputMode = InputMode.KEYBOARD_MOUSE
var _qa_brand_override: int = -1

# [south, east, west, north, r_shoulder, start, l_shoulder]
const _LABELS: Dictionary = {
	Brand.XBOX:        ["A",  "B",  "X",  "Y",  "RB", "Menu",    "LB"],
	Brand.PLAYSTATION: ["✕",  "○",  "□",  "△",  "R1", "Options", "L1"],
	Brand.NINTENDO:    ["B",  "A",  "Y",  "X",  "R",  "+",       "L"],
	Brand.GENERIC:     ["A",  "B",  "X",  "Y",  "RB", "Menu",    "LB"],
}
const _KEYBOARD_LABELS := ["Enter", "Esc", "X", "Y", "E", "F10", "Q"]
const _KEYBOARD_ACTIONS: Dictionary = {
	"gd_tab_prev": KEY_Q,
	"gd_tab_next": KEY_E,
	"gd_secondary": KEY_X,
	"gd_details": KEY_Y,
	"gd_menu": KEY_F10,
	"gd_next_month": KEY_N,
}

func _ready() -> void:
	_ensure_keyboard_actions()
	Input.joy_connection_changed.connect(_on_joy_changed)
	_detect()
	_input_mode = InputMode.GAMEPAD if not Input.get_connected_joypads().is_empty() else InputMode.KEYBOARD_MOUSE

func _on_joy_changed(_device: int, connected: bool) -> void:
	_detect()
	if connected:
		_set_input_mode(InputMode.GAMEPAD)
	elif Input.get_connected_joypads().is_empty():
		_set_input_mode(InputMode.KEYBOARD_MOUSE)

func _detect() -> void:
	_brand = Brand.GENERIC
	for i in Input.get_connected_joypads():
		_brand = brand_from_device_name(Input.get_joy_name(i))
		return

static func brand_from_device_name(device_name: String) -> Brand:
	var name := device_name.to_lower()
	if "playstation" in name or "dualshock" in name or "dualsense" in name or "sony" in name \
			or "ps3" in name or "ps4" in name or "ps5" in name:
		return Brand.PLAYSTATION
	if "nintendo" in name or "switch" in name or "pro controller" in name or "joycon" in name:
		return Brand.NINTENDO
	# Xbox, Steam Deck, XInput, and unknown standard pads use the physical Xbox layout.
	return Brand.XBOX

func is_pad_active() -> bool:
	if _qa_brand_override >= 0:
		return true
	return _input_mode == InputMode.GAMEPAD and not Input.get_connected_joypads().is_empty()

func input_mode_name() -> String:
	return "gamepad" if is_pad_active() else "keyboard_mouse"

func force_brand_for_qa(brand: Brand) -> void:
	_qa_brand_override = int(brand)
	_set_input_mode(InputMode.GAMEPAD)

func clear_qa_override() -> void:
	_qa_brand_override = -1
	_detect()
	_set_input_mode(
		InputMode.GAMEPAD if not Input.get_connected_joypads().is_empty() else InputMode.KEYBOARD_MOUSE)

func _active_brand() -> Brand:
	match _qa_brand_override:
		int(Brand.XBOX): return Brand.XBOX
		int(Brand.PLAYSTATION): return Brand.PLAYSTATION
		int(Brand.NINTENDO): return Brand.NINTENDO
		int(Brand.GENERIC): return Brand.GENERIC
	return _brand

func _ensure_keyboard_actions() -> void:
	for action_name in _KEYBOARD_ACTIONS:
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		var physical_key := int(_KEYBOARD_ACTIONS[action_name])
		var has_key := false
		for mapped_event in InputMap.action_get_events(action_name):
			if mapped_event is InputEventKey:
				var mapped_key := mapped_event as InputEventKey
				if int(mapped_key.physical_keycode) == physical_key \
						or int(mapped_key.keycode) == physical_key:
					has_key = true
					break
		if not has_key:
			var key_event := InputEventKey.new()
			key_event.physical_keycode = physical_key
			InputMap.action_add_event(action_name, key_event)

func secondary_pressed(event: InputEvent) -> bool:
	return event.is_action_pressed("gd_secondary") \
			or _joy_button_pressed(event, JOY_BUTTON_X)

func details_pressed(event: InputEvent) -> bool:
	return event.is_action_pressed("gd_details") \
			or _joy_button_pressed(event, JOY_BUTTON_Y)

func _joy_button_pressed(event: InputEvent, button_index: int) -> bool:
	if not (event is InputEventJoypadButton):
		return false
	var joy := event as InputEventJoypadButton
	return joy.pressed and int(joy.button_index) == button_index

func _active_labels() -> Array:
	return _LABELS[_active_brand()] if is_pad_active() else _KEYBOARD_LABELS

## 확인 버튼 (South): A / ✕ / B
func south()     -> String: return _active_labels()[0]
## 취소 버튼 (East): B / ○ / A
func east()      -> String: return _active_labels()[1]
## 보조 버튼 (West): X / □ / Y
func west()      -> String: return _active_labels()[2]
## 상세/규칙 버튼 (North): Y / △ / X
func north()     -> String: return _active_labels()[3]
## 오른쪽 어깨 (RB/R1/R)
func shoulder_r()-> String: return _active_labels()[4]
## 스타트/옵션/+ 버튼
func start_btn() -> String: return _active_labels()[5]
## 왼쪽 어깨 (LB/L1/L)
func shoulder_l()-> String: return _active_labels()[6]
## 오른쪽 스틱 클릭 (R3 — 모든 패드 동일)
func r3()        -> String: return "R3" if is_pad_active() else "N"

## 현재 브랜드 이름 (UI 디버그용)
func brand_name() -> String:
	match _active_brand():
		Brand.XBOX:        return "Xbox"
		Brand.PLAYSTATION: return "PlayStation"
		Brand.NINTENDO:    return "Nintendo"
	return "Generic"

## 패드 조작 시 마우스 커서 자동 숨김 / 마우스 이동 시 다시 표시
func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or \
			(event is InputEventJoypadMotion and abs(event.axis_value) > 0.3):
		_set_input_mode(InputMode.GAMEPAD)
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	elif event is InputEventMouseButton or \
			(event is InputEventMouseMotion and event.relative.length_squared() > 4.0):
		_set_input_mode(InputMode.KEYBOARD_MOUSE)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event is InputEventKey and event.pressed and not event.echo:
		_set_input_mode(InputMode.KEYBOARD_MOUSE)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _set_input_mode(mode: InputMode) -> void:
	if _input_mode == mode:
		return
	_input_mode = mode
	input_mode_changed.emit(_input_mode, _active_brand())
