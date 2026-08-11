extends Node
## ControllerHints — 연결된 패드 브랜드를 감지해 올바른 버튼 레이블을 반환한다.
## Xbox A/B/X/Y · PS ✕/○/□/△ · Nintendo B/A/Y/X · Steam Deck(= Xbox 레이블)

enum Brand { GENERIC, XBOX, PLAYSTATION, NINTENDO }
enum InputMode { KEYBOARD_MOUSE, GAMEPAD }

signal input_mode_changed(mode: InputMode, brand: Brand)

var _brand: Brand = Brand.GENERIC
var _input_mode: InputMode = InputMode.KEYBOARD_MOUSE
var _qa_brand_override: int = -1
var _major_trigger_down: Dictionary = {}
var _major_last_event_id: int = 0
var _major_last_direction: int = 0
var _major_last_consumed: bool = true

# [south, east, west, north, r_shoulder, start, l_shoulder, l_trigger, r_trigger]
const _LABELS: Dictionary = {
	Brand.XBOX:        ["A",  "B",  "X",  "Y",  "RB", "Menu",    "LB", "LT", "RT"],
	Brand.PLAYSTATION: ["✕",  "○",  "□",  "△",  "R1", "Options", "L1", "L2", "R2"],
	Brand.NINTENDO:    ["B",  "A",  "Y",  "X",  "R",  "+",       "L",  "ZL", "ZR"],
	Brand.GENERIC:     ["A",  "B",  "X",  "Y",  "RB", "Menu",    "LB", "LT", "RT"],
}
const _KEYBOARD_LABELS := [
	"Enter", "Esc", "X", "Y", "E", "F10", "Q", "PageUp", "PageDown",
]
const _KEYBOARD_ACTIONS: Dictionary = {
	"gd_tab_prev": KEY_Q,
	"gd_tab_next": KEY_E,
	"gd_major_prev": KEY_PAGEUP,
	"gd_major_next": KEY_PAGEDOWN,
	"gd_secondary": KEY_X,
	"gd_details": KEY_Y,
	"gd_menu": KEY_F10,
	"gd_next_month": KEY_N,
}
const MAJOR_TRIGGER_PRESS_THRESHOLD := 0.55
const MAJOR_TRIGGER_RELEASE_THRESHOLD := 0.35
const _MAJOR_TRIGGER_AXES: Dictionary = {
	"gd_major_prev": JOY_AXIS_TRIGGER_LEFT,
	"gd_major_next": JOY_AXIS_TRIGGER_RIGHT,
}

func _ready() -> void:
	_ensure_keyboard_actions()
	_ensure_major_trigger_actions()
	Input.joy_connection_changed.connect(_on_joy_changed)
	_detect()
	_input_mode = InputMode.GAMEPAD if not Input.get_connected_joypads().is_empty() else InputMode.KEYBOARD_MOUSE

func _on_joy_changed(device: int, connected: bool) -> void:
	if connected:
		# Seed from the physical state instead of assuming both triggers are held.
		# A held reconnect remains suppressed until release, while a neutral
		# reconnect keeps the first intentional press available.
		_seed_major_trigger_connection_state(
			device,
			Input.get_joy_axis(device, JOY_AXIS_TRIGGER_LEFT),
			Input.get_joy_axis(device, JOY_AXIS_TRIGGER_RIGHT))
	else:
		for direction in [-1, 1]:
			_major_trigger_down.erase("%d:%d" % [device, direction])
	_detect()
	if connected:
		_set_input_mode(InputMode.GAMEPAD)
	elif Input.get_connected_joypads().is_empty():
		_set_input_mode(InputMode.KEYBOARD_MOUSE)

func _seed_major_trigger_connection_state(
		device: int, left_value: float, right_value: float) -> void:
	_major_trigger_down["%d:-1" % device] = \
		left_value > MAJOR_TRIGGER_RELEASE_THRESHOLD
	_major_trigger_down["%d:1" % device] = \
		right_value > MAJOR_TRIGGER_RELEASE_THRESHOLD

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

func _ensure_major_trigger_actions() -> void:
	for action_name in _MAJOR_TRIGGER_AXES:
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name, MAJOR_TRIGGER_PRESS_THRESHOLD)
		InputMap.action_set_deadzone(action_name, MAJOR_TRIGGER_PRESS_THRESHOLD)
		var expected_axis := int(_MAJOR_TRIGGER_AXES[action_name])
		var has_axis := false
		for mapped_event in InputMap.action_get_events(action_name):
			if mapped_event is InputEventJoypadMotion \
					and int((mapped_event as InputEventJoypadMotion).axis) == expected_axis \
					and (mapped_event as InputEventJoypadMotion).axis_value > 0.0:
				has_axis = true
				break
		if not has_axis:
			var motion := InputEventJoypadMotion.new()
			motion.device = -1
			motion.axis = expected_axis as JoyAxis
			motion.axis_value = 1.0
			InputMap.action_add_event(action_name, motion)

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

## L2/R2 또는 PageUp/PageDown의 한 번짜리 큰 단위 입력.
## analog trigger는 0.55에서 눌리고 0.35 아래로 놓인 뒤에만 다시 반응한다.
func major_direction(event: InputEvent) -> int:
	_process_major_event(event)
	if _major_last_direction == 0 or _major_last_consumed:
		return 0
	_major_last_consumed = true
	return _major_last_direction

func _process_major_event(event: InputEvent) -> void:
	var event_id := int(event.get_instance_id())
	if event_id == _major_last_event_id:
		return
	_major_last_event_id = event_id
	_major_last_direction = 0
	_major_last_consumed = false
	if event is InputEventJoypadMotion:
		var motion := event as InputEventJoypadMotion
		var direction := 0
		if motion.axis == JOY_AXIS_TRIGGER_LEFT:
			direction = -1
		elif motion.axis == JOY_AXIS_TRIGGER_RIGHT:
			direction = 1
		if direction == 0:
			return
		var gate_key := "%d:%d" % [motion.device, direction]
		var down := bool(_major_trigger_down.get(gate_key, false))
		if motion.axis_value <= MAJOR_TRIGGER_RELEASE_THRESHOLD:
			_major_trigger_down[gate_key] = false
		elif motion.axis_value >= MAJOR_TRIGGER_PRESS_THRESHOLD and not down:
			_major_trigger_down[gate_key] = true
			_major_last_direction = direction
		return
	if event is InputEventKey:
		var key := event as InputEventKey
		if not key.pressed or key.echo:
			return
		if event.is_action_pressed("gd_major_prev"):
			_major_last_direction = -1
		elif event.is_action_pressed("gd_major_next"):
			_major_last_direction = 1
		return
	if event is InputEventJoypadButton:
		var joy := event as InputEventJoypadButton
		for action_data in [["gd_major_prev", -1], ["gd_major_next", 1]]:
			var action_name := str(action_data[0])
			var direction := int(action_data[1])
			if not event.is_action(action_name):
				continue
			var gate_key := "%d:%d" % [joy.device, direction]
			if not joy.pressed:
				_major_trigger_down[gate_key] = false
			elif not bool(_major_trigger_down.get(gate_key, false)):
				_major_trigger_down[gate_key] = true
				_major_last_direction = direction
			return

func reset_major_input_state() -> void:
	_major_trigger_down.clear()
	_major_last_event_id = 0
	_major_last_direction = 0
	_major_last_consumed = true

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
## 왼쪽 트리거 (LT/L2/ZL)
func trigger_l() -> String: return _active_labels()[7]
## 오른쪽 트리거 (RT/R2/ZR)
func trigger_r() -> String: return _active_labels()[8]
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
	_process_major_event(event)
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
