extends Node
## ORDER-76: portrait communication phone geometry, filtering, focus, and input.

const PHONE_SCRIPT := preload("res://scenes/CommunicationPhone.gd")
const CORE_LOOP := preload("res://systems/DemoCoreLoopV2.gd")
const FLAGSHIP_PATH := "res://assets/ui/phone/phone_frame_flagship.png"

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var original_language := LocaleManager.language
	GameState.start_new_game()
	_check_durable_offer_history()
	_prepare_contact_fixture()
	_check_surface_classifier()
	for language in ["ko", "en"]:
		for resolution in [Vector2i(1280, 800), Vector2i(960, 600)]:
			await _check_runtime_case(language, resolution)
	LocaleManager.language = original_language
	LocaleManager.language_changed.emit(original_language)
	if _failures.is_empty():
		print(
			"COMMUNICATION_PHONE_CHECK_OK geometry=1280x800/392+960x600/320 "
			+ "frame=flagship/portrait/90deg reveal=right_slide/reduced_static "
			+ "tabs=conversation/contacts "
			+ "filter=inbound_message+call_log/durable/no_system/no_self_note "
			+ "contacts=phone+kakao+business_card/no_known_place/no_none "
			+ "input=lb-rb/east/p-north focus=modal/cycle signal=existing_offer "
			+ "effects=none locales=ko/en")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("COMMUNICATION_PHONE_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)


func _prepare_contact_fixture() -> void:
	GameState.core_loop_v2_state = {
		"completed_bundles": ["hyunsu_first_meet"],
		"relationship_stages": {
			"father": "opening",
			"hyunsu": "met",
			"daeun": "opening",
			"jiyeon": "opening",
			"sangchul": "met",
			"jaehyuk": "opening",
		},
	}
	GameState.flags["artifact_sangchul_card"] = true
	GameState.flags["jaehyuk_message_welcomed"] = true


func _check_durable_offer_history() -> void:
	# Completing the Hanbit interview advances submitted -> interviewed, so the
	# bundle no longer satisfies available_offer_ids(). It must still remain in
	# the same month's conversation history through durable plan/completion data.
	GameState.turn = 14
	GameState.core_loop_v2_state = {
		"enabled": true,
		"plans": {
			"4": {
				"selected": ["m4_hanbit_interview"],
				"forgone": [],
				"schedule": {"14": "m4_hanbit_interview"},
			},
		},
		"completed_bundles": [
			"m3_hanbit_application", "m4_hanbit_interview",
		],
		"completed_bundle_turns": {
			"m3_hanbit_application": 9,
			"m4_hanbit_interview": 14,
		},
		"application_statuses": {
			"hanbit_ops_2026q1": "interviewed",
		},
	}
	_expect(not CORE_LOOP.available_offer_ids(4).has("m4_hanbit_interview"),
		"Hanbit durable-history fixture still satisfies the old availability predicate")
	_expect(CORE_LOOP.received_phone_offer_ids(4).has("m4_hanbit_interview"),
		"completed Hanbit interview vanished from the Month Four phone history")
	GameState.start_new_game()


func _check_surface_classifier() -> void:
	var phone := PHONE_SCRIPT.new()
	_expect(phone.call("_contact_surface_kind", {
		"phone_surface": "inbound_message"}) == "inbound_message",
		"inbound messages are not classified as conversations")
	_expect(phone.call("_contact_surface_kind", {
		"phone_surface": "call_log"}) == "call_log",
		"call logs are not classified as conversations")
	for forbidden in [
		"self_note", "world_encounter", "system_record", "known_place",
		"none", "", "calendar", "bank", "investment", "leisure", "games",
	]:
		_expect(phone.call("_contact_surface_kind", {
			"phone_surface": forbidden}) == "",
			"forbidden phone surface leaked into conversations: %s" % forbidden)
	phone.free()


func _check_runtime_case(language: String, resolution: Vector2i) -> void:
	LocaleManager.language = language
	LocaleManager.language_changed.emit(language)

	var viewport := SubViewport.new()
	viewport.name = "CommunicationPhoneViewport_%s_%s" % [language, resolution]
	viewport.size = resolution
	viewport.disable_3d = true
	viewport.gui_disable_input = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)

	var underlying := Button.new()
	underlying.name = "UnderlyingGameplayControl"
	underlying.text = "UNDERLYING"
	underlying.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	underlying.focus_mode = Control.FOCUS_ALL
	viewport.add_child(underlying)

	var context := "%s %dx%d" % [language, resolution.x, resolution.y]
	var phone = PHONE_SCRIPT.new()
	viewport.add_child(phone)
	await get_tree().process_frame
	await get_tree().process_frame
	underlying.grab_focus()
	SaveManager.set_setting("reduce_motion", false)
	_expect(phone.open(1), "%s %s could not open month one" % [language, resolution])
	var opening_drawer := phone.get("_drawer") as Control
	var opening_rest := phone.get("_drawer_rest_position") as Vector2
	_expect(is_instance_valid(opening_drawer) \
			and opening_drawer.position.x > opening_rest.x \
			and opening_drawer.modulate.a < 0.1,
		"%s normal-motion phone did not begin a right-edge slide" % context)
	await get_tree().process_frame
	await get_tree().process_frame
	# Normal motion slides the portrait drawer in from the right. Geometry is
	# contractual at rest, after the short reveal has completed.
	await get_tree().create_timer(0.20).timeout

	_check_geometry(phone, resolution, context)
	_check_conversation_filter(phone, context)
	_check_focus_contract(phone, viewport, context)
	if OS.get_cmdline_user_args().has("--capture-communication-phone") \
			and DisplayServer.get_name() != "headless":
		await get_tree().create_timer(0.16).timeout
		var capture_path := "/tmp/gangnamdream_communication_phone_%s_%dx%d.png" % [
			language, resolution.x, resolution.y]
		var capture_error := viewport.get_texture().get_image().save_png(
			capture_path)
		_expect(capture_error == OK,
			"%s visual QA capture failed: %s" % [context, capture_error])
	await _check_offer_and_input_contract(phone, viewport, context)
	SaveManager.set_setting("reduce_motion", true)
	_expect(phone.open(1),
		"%s could not reopen for reduced-motion geometry" % context)
	var static_drawer := phone.get("_drawer") as Control
	var static_rest := phone.get("_drawer_rest_position") as Vector2
	_expect(is_instance_valid(static_drawer) \
			and static_drawer.position.is_equal_approx(static_rest) \
			and is_equal_approx(static_drawer.modulate.a, 1.0),
		"%s reduced motion did not reveal the phone without movement" % context)
	phone.close()
	SaveManager.set_setting("reduce_motion", false)

	if phone.is_open():
		phone.close()
	phone.queue_free()
	underlying.queue_free()
	viewport.queue_free()
	await get_tree().process_frame
	_prepare_contact_fixture()


func _check_geometry(phone: Control, resolution: Vector2i, context: String) -> void:
	var drawer := phone.get("_drawer") as Control
	var holder := phone.get("_phone_holder") as Control
	var display := phone.get("_display_panel") as Control
	var content := phone.get("_content_margin") as Control
	var frame := phone.get("_frame_texture") as TextureRect
	var scroll := phone.get("_body_scroll") as ScrollContainer
	var expected_width := 320.0 if resolution.x == 960 else 392.0
	_expect(is_instance_valid(drawer), "%s has no portrait drawer" % context)
	if not is_instance_valid(drawer):
		return
	_expect(is_equal_approx(drawer.size.x, expected_width),
		"%s drawer width is %.1f, expected %.1f" % [
			context, drawer.size.x, expected_width])
	_expect(is_equal_approx(
		drawer.position.x, resolution.x - expected_width - 16.0),
		"%s drawer is not fixed to the right safe edge: %s" % [
			context, drawer.get_rect()])
	_expect(drawer.position.y >= 8.0 and drawer.get_rect().end.y <= resolution.y,
		"%s drawer escaped the vertical safe area: %s" % [context, drawer.get_rect()])
	_expect(is_instance_valid(holder) and holder.size.x < holder.size.y,
		"%s physical phone is not portrait: %s" % [
			context, holder.size if is_instance_valid(holder) else Vector2.ZERO])
	_expect(is_instance_valid(frame) and frame.texture != null \
			and frame.texture.resource_path == FLAGSHIP_PATH,
		"%s does not use the one approved flagship material" % context)
	_expect(is_instance_valid(frame) \
			and is_equal_approx(frame.rotation_degrees, 90.0) \
			and is_equal_approx(float(frame.get_meta(
				"source_rotation_degrees", 0.0)), 90.0),
		"%s flagship material is not rotated exactly 90 degrees" % context)
	_expect(is_instance_valid(display) and _rect_encloses(
		holder.get_global_rect(), display.get_global_rect(), 0.6),
		"%s live display escaped the physical phone" % context)
	_expect(is_instance_valid(content) and _rect_encloses(
		display.get_global_rect(), content.get_global_rect(), 0.6),
		"%s safe content escaped the glass opening" % context)
	_expect(is_instance_valid(display) and display.size.x >= 230.0 \
			and display.size.y >= 530.0,
		"%s live display collapsed below Deck-readable bounds: %s" % [
			context, display.size if is_instance_valid(display) else Vector2.ZERO])
	if is_instance_valid(scroll):
		var hbar := scroll.get_h_scroll_bar()
		_expect(not is_instance_valid(hbar) \
				or hbar.max_value <= hbar.page + 1.0,
			"%s communication body has hidden horizontal overflow" % context)
	_check_key_controls_fit(phone, display, context)


func _check_key_controls_fit(
		phone: Control, display: Control, context: String) -> void:
	var display_rect := display.get_global_rect()
	for variable in [
		"_header_title", "_back_button", "_close_button", "_footer_hint",
	]:
		var control := phone.get(variable) as Control
		if not is_instance_valid(control) or not control.is_visible_in_tree():
			continue
		_expect(_rect_encloses(display_rect, control.get_global_rect(), 1.0),
			"%s %s escaped the live display: %s" % [
				context, variable, control.get_global_rect()])
	var tabs: Array[Button] = phone.get("_tab_buttons")
	_expect(tabs.size() == 2, "%s does not expose exactly two tabs" % context)
	for tab in tabs:
		_expect(tab.custom_minimum_size.y >= 42.0 \
				and _rect_encloses(display_rect, tab.get_global_rect(), 1.0),
			"%s tab clipped or fell below the 42px focus target" % context)


func _check_conversation_filter(phone: Control, context: String) -> void:
	var expected_ids: Array[String] = phone.call("_received_contact_offer_ids")
	_expect(not expected_ids.is_empty(),
		"%s month one fixture produced no real conversation" % context)
	var shown_ids: Array[String] = []
	for control in _meta_controls(phone, "communication_surface"):
		var surface := str(control.get_meta("communication_surface", ""))
		var bundle_id := str(control.get_meta("bundle_id", ""))
		_expect(surface in ["inbound_message", "call_log"],
			"%s rendered forbidden conversation surface %s" % [context, surface])
		_expect(not bundle_id.is_empty(),
			"%s rendered a conversation without an authored offer id" % context)
		if not shown_ids.has(bundle_id):
			shown_ids.append(bundle_id)
	shown_ids.sort()
	expected_ids.sort()
	_expect(shown_ids == expected_ids,
		"%s rendered conversation ids %s, expected %s" % [
			context, shown_ids, expected_ids])
	for bundle_id in shown_ids:
		var surface := str(CORE_LOOP.bundle(bundle_id).get(
			"phone_surface", ""))
		_expect(surface in ["inbound_message", "call_log"],
			"%s %s is not a real message or call" % [context, bundle_id])
	var all_text := _collect_text(phone)
	for forbidden_copy in [
		"SYSTEM RECORDS", "지난달에 잡지 않은 제안", "은행", "BANKING",
		"DEVICE STORE", "기기 둘러보기", "INVESTING", "GAMES",
	]:
		_expect(all_text.find(forbidden_copy) < 0,
			"%s phone leaked non-communication copy: %s" % [
				context, forbidden_copy])


func _check_focus_contract(
		phone: Control, viewport: SubViewport, context: String) -> void:
	var focused := viewport.gui_get_focus_owner()
	_expect(is_instance_valid(focused) and phone.is_ancestor_of(focused),
		"%s open did not move focus inside the modal phone" % context)
	var focusables: Array[Control] = []
	_collect_focusables(phone, focusables)
	_expect(not focusables.is_empty() and focusables.size() <= 12,
		"%s phone exposes %d focus targets (expected 1..12)" % [
			context, focusables.size()])
	for control in focusables:
		for neighbor in [
			control.focus_neighbor_top, control.focus_neighbor_bottom,
			control.focus_neighbor_left, control.focus_neighbor_right,
		]:
			var target := control.get_node_or_null(neighbor) as Control
			_expect(is_instance_valid(target) and phone.is_ancestor_of(target),
				"%s focus can escape the phone from %s via %s" % [
					context, control.name, neighbor])


func _check_offer_and_input_contract(
		phone: Control, viewport: SubViewport, context: String) -> void:
	var emitted: Array[String] = []
	var close_count := [0]
	phone.offer_requested.connect(func(bundle_id: String) -> void:
		emitted.append(bundle_id))
	phone.closed.connect(func() -> void:
		close_count[0] += 1)

	var rows := _meta_controls(phone, "communication_surface")
	_expect(not rows.is_empty(), "%s has no conversation row to open" % context)
	if not rows.is_empty() and rows[0] is Button:
		var row := rows[0] as Button
		var expected_bundle := str(row.get_meta("bundle_id", ""))
		row.pressed.emit()
		await get_tree().process_frame
		await get_tree().process_frame
		_expect(str(phone.get("_screen_mode")) == "thread",
			"%s conversation did not open a thread" % context)
		var thread_focus := viewport.gui_get_focus_owner()
		_expect(is_instance_valid(thread_focus) \
				and phone.is_ancestor_of(thread_focus) \
				and bool(thread_focus.get_meta("offer_request", false)),
			"%s thread opening lost focus with the removed inbox row" % context)
		var request := _first_meta_button(phone, "offer_request", true)
		_expect(is_instance_valid(request),
			"%s schedulable conversation has no wide-planner request" % context)
		if is_instance_valid(request):
			var before: Dictionary = GameState.serialize().duplicate(true)
			request.pressed.emit()
			_expect(emitted == [expected_bundle],
				"%s conversation emitted %s, expected %s" % [
					context, emitted, expected_bundle])
			_expect(GameState.serialize() == before,
				"%s conversation request created a gameplay effect" % context)

		await _push_joy(viewport, JOY_BUTTON_B)
		_expect(phone.is_open() and str(phone.get("_screen_mode")) == "list",
			"%s East did not return thread to conversation list" % context)
		var restored := viewport.gui_get_focus_owner()
		_expect(is_instance_valid(restored) \
				and str(restored.get_meta("bundle_id", "")) == expected_bundle,
			"%s thread Back did not restore the source conversation focus" % context)

	await _push_joy(viewport, JOY_BUTTON_RIGHT_SHOULDER)
	_expect(int(phone.get("_active_tab")) == 1,
		"%s RB did not open Contacts" % context)
	var contact_ids: Array[String] = phone.call("_actual_contact_ids")
	_expect(contact_ids == ["father", "hyunsu", "sangchul", "jaehyuk"],
		"%s actual contacts are %s" % [context, contact_ids])
	for control in _meta_controls(phone, "contact_method"):
		_expect(str(control.get_meta("contact_method", "")) \
				in ["phone", "kakao", "business_card"],
			"%s contact list contains a non-contact method" % context)
		_expect(str(control.get_meta("contact_id", "")) \
				not in ["daeun", "jiyeon"],
			"%s known-place/no-number person leaked into Contacts" % context)
	_expect(str(phone.call("_contact_method", "daeun")) == "none" \
			and str(phone.call("_contact_method", "jiyeon")) == "none",
		"%s Daeun or Jiyeon gained an invented contact method" % context)

	var contact_request := _first_meta_button(phone, "offer_request", true)
	_expect(is_instance_valid(contact_request),
		"%s contacts expose no authored offer request" % context)
	if is_instance_valid(contact_request):
		var contact_bundle := str(contact_request.get_meta("bundle_id", ""))
		var before_contact: Dictionary = GameState.serialize().duplicate(true)
		contact_request.pressed.emit()
		_expect(emitted.has(contact_bundle),
			"%s contact did not emit its existing offer id" % context)
		_expect(GameState.serialize() == before_contact,
			"%s contact request created a generic reward or state effect" % context)

	await _push_joy(viewport, JOY_BUTTON_LEFT_SHOULDER)
	_expect(int(phone.get("_active_tab")) == 0,
		"%s LB did not return to Conversations" % context)
	await _push_key(viewport, KEY_P)
	_expect(not phone.is_open() and close_count[0] == 1,
		"%s P did not close exactly once" % context)

	_expect(phone.open(1), "%s could not reopen for North input" % context)
	await get_tree().process_frame
	await _push_joy(viewport, JOY_BUTTON_Y)
	_expect(not phone.is_open() and close_count[0] == 2,
		"%s controller North did not toggle close exactly once" % context)

	_expect(phone.open(1), "%s could not reopen for list Back" % context)
	await get_tree().process_frame
	await _push_joy(viewport, JOY_BUTTON_B)
	_expect(not phone.is_open() and close_count[0] == 3,
		"%s East on a list did not close exactly once" % context)


func _push_joy(viewport: SubViewport, button_index: int) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = button_index
	event.pressed = true
	viewport.push_input(event)
	await get_tree().process_frame
	await get_tree().process_frame


func _push_key(viewport: SubViewport, keycode: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	event.pressed = true
	viewport.push_input(event)
	await get_tree().process_frame
	await get_tree().process_frame


func _meta_controls(root: Node, key: String) -> Array[Control]:
	var result: Array[Control] = []
	_collect_meta_controls(root, key, result)
	return result


func _collect_meta_controls(
		root: Node, key: String, output: Array[Control]) -> void:
	if root is Control and root.has_meta(key):
		output.append(root as Control)
	for child in root.get_children():
		_collect_meta_controls(child, key, output)


func _first_meta_button(
		root: Node, key: String, value: Variant) -> Button:
	for control in _meta_controls(root, key):
		if control is Button and control.get_meta(key) == value \
				and control.is_visible_in_tree():
			return control as Button
	return null


func _collect_focusables(root: Node, output: Array[Control]) -> void:
	if root is Control:
		var control := root as Control
		if control.is_visible_in_tree() and control.focus_mode != Control.FOCUS_NONE \
				and not (control is BaseButton and (control as BaseButton).disabled):
			output.append(control)
	for child in root.get_children():
		_collect_focusables(child, output)


func _collect_text(root: Node) -> String:
	var parts: Array[String] = []
	_collect_text_parts(root, parts)
	return "\n".join(parts)


func _collect_text_parts(root: Node, output: Array[String]) -> void:
	if root is Label:
		output.append((root as Label).text)
	elif root is Button:
		output.append((root as Button).text)
	for child in root.get_children():
		_collect_text_parts(child, output)


func _rect_encloses(outer: Rect2, inner: Rect2, tolerance: float) -> bool:
	return inner.position.x >= outer.position.x - tolerance \
		and inner.position.y >= outer.position.y - tolerance \
		and inner.end.x <= outer.end.x + tolerance \
		and inner.end.y <= outer.end.y + tolerance


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
