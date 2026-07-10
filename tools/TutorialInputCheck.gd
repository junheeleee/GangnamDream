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

	_send_accept()
	await get_tree().process_frame
	await get_tree().process_frame
	if _underlying_pressed:
		_fail("accept leaked to the underlying action")
		return
	if int(overlay.get("_slide_idx")) != 1:
		_fail("accept did not advance exactly one tutorial slide")
		return

	for _i in range(3):
		_send_accept()
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

func _send_accept() -> void:
	var event := InputEventAction.new()
	event.action = "ui_accept"
	event.pressed = true
	Input.parse_input_event(event)

func _fail(message: String) -> void:
	push_error("TUTORIAL_INPUT_CHECK_FAIL: %s" % message)
	get_tree().quit(1)
