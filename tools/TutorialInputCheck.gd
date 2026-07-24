extends Node

var _underlying_pressed := false
var _parent: Control
var _underlying: Button

func _ready() -> void:
	_parent = Control.new()
	_parent.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_parent)

	_underlying = Button.new()
	_underlying.text = "Underlying action"
	_underlying.focus_mode = Control.FOCUS_ALL
	_underlying.pressed.connect(func(): _underlying_pressed = true)
	_parent.add_child(_underlying)
	_underlying.grab_focus()

	TutorialOverlay.force_show("main_game", _parent)
	await get_tree().process_frame
	await get_tree().process_frame
	var overlay := _find_overlay()
	if overlay == null:
		_fail("tutorial overlay did not open")
		return
	var focus_owner := get_viewport().gui_get_focus_owner()
	if focus_owner == null or not overlay.is_ancestor_of(focus_owner):
		_fail("tutorial did not trap focus")
		return

	_send_keyboard_accept()
	await get_tree().process_frame
	await get_tree().process_frame
	if _underlying_pressed:
		_fail("accept leaked to the underlying action")
		return
	if int(overlay.get("_slide_idx")) != 1:
		_fail("physical Enter did not advance exactly one tutorial slide")
		return

	_send_pad_accept()
	await get_tree().process_frame
	await get_tree().process_frame
	if int(overlay.get("_slide_idx")) != 2:
		_fail("pad South did not advance exactly one tutorial slide")
		return

	var next_button := overlay.get("_next_btn") as Button
	next_button.emit_signal("pressed")
	await get_tree().process_frame
	await get_tree().process_frame
	if int(overlay.get("_slide_idx")) != 3:
		_fail("tutorial button click did not advance exactly one slide")
		return

	_send_keyboard_accept()
	await get_tree().process_frame
	await get_tree().process_frame
	if _underlying_pressed:
		_fail("tutorial dismissal activated the underlying action")
		return
	if _find_overlay() != null:
		_fail("tutorial did not dismiss after the final slide")
		return
	await get_tree().process_frame
	if get_viewport().gui_get_focus_owner() != _underlying:
		_fail("tutorial did not restore the previous focus")
		return
	print("TUTORIAL_INPUT_CHECK_OK")
	get_tree().quit(0)

func _find_overlay() -> TutorialOverlay:
	for child in _parent.get_children():
		if child is TutorialOverlay and not child.is_queued_for_deletion():
			return child as TutorialOverlay
	return null

func _send_keyboard_accept() -> void:
	var press := InputEventKey.new()
	press.keycode = KEY_ENTER
	press.physical_keycode = KEY_ENTER
	press.pressed = true
	Input.parse_input_event(press)
	var release := press.duplicate() as InputEventKey
	release.pressed = false
	Input.parse_input_event(release)

func _send_pad_accept() -> void:
	# Headless CI has no physical joypad device, so feed the mapped South action.
	# Raw brand/button mapping is covered by InputMatrixCheck.
	var press := InputEventAction.new()
	press.action = "ui_accept"
	press.pressed = true
	Input.parse_input_event(press)
	var release := press.duplicate() as InputEventAction
	release.pressed = false
	Input.parse_input_event(release)

func _fail(message: String) -> void:
	push_error("TUTORIAL_INPUT_CHECK_FAIL: %s" % message)
	get_tree().quit(1)
