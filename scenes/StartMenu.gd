extends Control

# 드라마 모드: 루트/특성 선택 없이 김민준 33세 백수로 고정 시작.
# 성향(직장/투자/창업)은 플레이 중 선택 누적으로 자연스럽게 결정된다.

var slot_container: VBoxContainer
var _settings_overlay: ColorRect

var _splash_layer: Control
var _splash_active: bool = true

func _ready():
	_build_ui()
	_build_splash()
	BGMPlayer.start_menu()
	SceneTransition.fade_in()

func _build_splash():
	_splash_layer = Control.new()
	_splash_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_splash_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_splash_layer)

	# 배경
	var bg = ColorRect.new()
	bg.color = Color("#0a0a0e")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_splash_layer.add_child(bg)

	var bg_img = TextureRect.new()
	bg_img.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_img.stretch_mode = TextureRect.STRETCH_SCALE
	bg_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_img.modulate = Color(1, 1, 1, 0.10)
	bg_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tex = load("res://assets/backgrounds/goshiwon_room.png")
	if tex:
		bg_img.texture = tex
	_splash_layer.add_child(bg_img)

	# 중앙 컨텐츠
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_splash_layer.add_child(center)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(vbox)

	# 로고
	var logo = Label.new()
	logo.text = "강남드림"
	logo.add_theme_font_size_override("font_size", 80)
	logo.add_theme_color_override("font_color", Color("#f0b429"))
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(logo)

	var sub = Label.new()
	sub.text = "KOREAN LIFE ROGUELIKE"
	sub.add_theme_font_size_override("font_size", 15)
	sub.add_theme_color_override("font_color", Color("#2e3050"))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sub)

	var sep = HSeparator.new()
	sep.modulate = Color("#1e1e2a")
	sep.custom_minimum_size = Vector2(320, 0)
	vbox.add_child(sep)

	var tagline = Label.new()
	tagline.text = "서울 고시원 100만원에서 강남드림까지"
	tagline.add_theme_font_size_override("font_size", 15)
	tagline.add_theme_color_override("font_color", Color("#4a5068"))
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(tagline)

	# 누적 기록 (런 있을 때만 표시)
	var meta = MetaProgression.data
	var total_runs = int(meta.get("total_runs", 0))
	if total_runs > 0:
		var stats_lbl = Label.new()
		stats_lbl.text = "누적 %d런  ·  최고 자산 %s" % [total_runs, _format_money(meta.get("best_asset", 0))]
		stats_lbl.add_theme_font_size_override("font_size", 12)
		stats_lbl.add_theme_color_override("font_color", Color("#2e3050"))
		stats_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(stats_lbl)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 52)
	vbox.add_child(spacer)

	# PRESS ANY KEY — 깜빡임
	var press_lbl = Label.new()
	press_lbl.text = "PRESS ANY KEY"
	press_lbl.add_theme_font_size_override("font_size", 17)
	press_lbl.add_theme_color_override("font_color", Color("#5a6075"))
	press_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(press_lbl)

	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(press_lbl, "modulate:a", 0.12, 0.75)
	tween.tween_property(press_lbl, "modulate:a", 1.0, 0.75)

func _input(event):
	if not _splash_active:
		return
	var dismiss = false
	if event is InputEventKey and event.pressed and not event.echo:
		dismiss = true
	elif event is InputEventMouseButton and event.pressed:
		dismiss = true
	if dismiss:
		get_viewport().set_input_as_handled()
		_dismiss_splash()

func _dismiss_splash():
	_splash_active = false
	AudioManager.play("click")
	var tween = create_tween()
	tween.tween_property(_splash_layer, "modulate:a", 0.0, 0.25)
	tween.tween_callback(_splash_layer.queue_free)

func _build_ui():
	# ── 배경 ──
	var bg = ColorRect.new()
	bg.color = Color("#0c0c10")
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var scene_bg = TextureRect.new()
	scene_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	scene_bg.stretch_mode = TextureRect.STRETCH_SCALE
	scene_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	scene_bg.modulate = Color(1, 1, 1, 0.18)
	scene_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg_tex = load("res://assets/backgrounds/goshiwon_room.png")
	if bg_tex:
		scene_bg.texture = bg_tex
	add_child(scene_bg)

	# ── 메인 레이아웃 (스크롤 없음) ──
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	add_child(margin)

	var root = VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	# ── 타이틀 행 ──
	var title_row = HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 12)
	root.add_child(title_row)
	var title_lbl = _label("강남드림", 40, "#f0b429", HORIZONTAL_ALIGNMENT_LEFT)
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title_lbl)
	title_row.add_child(_label("KOREAN LIFE ROGUELIKE", 12, "#3a3a5a", HORIZONTAL_ALIGNMENT_RIGHT))
	var settings_btn = _button("⚙", "#1e1e2a")
	settings_btn.custom_minimum_size = Vector2(40, 36)
	settings_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	settings_btn.pressed.connect(_open_settings_popup)
	title_row.add_child(settings_btn)

	root.add_child(_sep())

	# ── 본문: 왼쪽(새 게임) + 오른쪽(불러오기) ──
	var cols = HBoxContainer.new()
	cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cols.add_theme_constant_override("separation", 24)
	root.add_child(cols)

	# ── 왼쪽 컬럼: 새 게임 설정 ──
	var left = VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 10)
	cols.add_child(left)

	# ── 게임 소개 ──
	var intro = _label("김민준. 서른셋. 백수.", 22, "#e8eaf0", HORIZONTAL_ALIGNMENT_LEFT)
	intro.add_theme_font_size_override("font_size", 22)
	left.add_child(intro)

	var premise = _label(
		"아버지의 빚을 6년간 갚았다. 이제 통장엔 50만원뿐이다.\n\n남은 건 신촌 고시원 한 칸과, 5년이라는 시간.\n\n38살이 되기 전에 — 강남에 입성한다.\n불가능하다는 걸 안다. 그래서 시작한다.",
		14, "#a0aec0", HORIZONTAL_ALIGNMENT_LEFT)
	premise.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left.add_child(premise)

	var hint = _label(
		"※ 당신의 선택이 쌓여 어떤 사람이 될지 결정됩니다.\n   직장으로, 투자로, 사업으로 — 길은 정해져 있지 않습니다.",
		12, "#5a6075", HORIZONTAL_ALIGNMENT_LEFT)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left.add_child(hint)

	# 스페이서
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(spacer)

	# 시작 버튼
	var new_game = _button("새 이야기 시작  ▶", "#0e3a2a")
	new_game.pressed.connect(_start_new_run)
	left.add_child(new_game)

	# ── 구분선 ──
	var vsep = VSeparator.new()
	vsep.add_theme_color_override("color", Color("#1e1e2a"))
	cols.add_child(vsep)

	# ── 오른쪽 컬럼: 불러오기 ──
	var right = VBoxContainer.new()
	right.custom_minimum_size = Vector2(240, 0)
	right.add_theme_constant_override("separation", 8)
	cols.add_child(right)

	right.add_child(_label("불러오기", 14, "#5b9cf6", HORIZONTAL_ALIGNMENT_LEFT))

	slot_container = VBoxContainer.new()
	slot_container.add_theme_constant_override("separation", 8)
	right.add_child(slot_container)
	_rebuild_slots()

	var right_spacer = Control.new()
	right_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(right_spacer)

	right.add_child(_sep())

	# ── 업적 섹션 ──
	var meta = MetaProgression.data
	var unlocked_ach = MetaProgression.get_unlocked_achievements()
	var total_ach = DataRegistry.achievements.size()
	right.add_child(_label(
		"업적  %d / %d" % [unlocked_ach.size(), total_ach],
		12, "#5b9cf6", HORIZONTAL_ALIGNMENT_LEFT))

	var ach_grid = GridContainer.new()
	ach_grid.columns = 5
	ach_grid.add_theme_constant_override("h_separation", 6)
	ach_grid.add_theme_constant_override("v_separation", 6)
	right.add_child(ach_grid)

	for ach_data in DataRegistry.achievements:
		var ach_id = str(ach_data.get("id", ""))
		var is_unlocked = unlocked_ach.has(ach_id)
		var icon_lbl = Label.new()
		icon_lbl.text = ach_data.get("icon", "?")
		icon_lbl.add_theme_font_size_override("font_size", 22)
		icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_lbl.custom_minimum_size = Vector2(36, 36)
		icon_lbl.modulate = Color(1, 1, 1, 1.0) if is_unlocked else Color(1, 1, 1, 0.15)
		icon_lbl.tooltip_text = "%s\n%s" % [ach_data.get("name", ""), ach_data.get("description", "—")] if is_unlocked else "???\n%s" % ach_data.get("hint", "")
		ach_grid.add_child(icon_lbl)

	right.add_child(_label(
		"누적 %d런  ·  최고 자산 %s" % [meta.get("total_runs", 0), _format_money(meta.get("best_asset", 0))],
		10, "#3a3a5a", HORIZONTAL_ALIGNMENT_LEFT))

# ── 슬롯 목록 빌드 / 새로고침 ─────────────────────────────────
func _rebuild_slots():
	for child in slot_container.get_children():
		child.queue_free()

	for slot in range(0, 4):
		var info = SaveManager.get_save_info(slot)
		var top_line = "자동저장" if slot == 0 else "슬롯 %d" % slot
		var sub_line = ""
		if info.get("empty", true):
			sub_line = "비어 있음"
		else:
			sub_line = "%d년 %d월  ·  %s" % [
				info.get("year", 2026), info.get("month", 1),
				_format_money(info.get("total_assets", 0))
			]
		var enabled = not info.get("empty", true)

		# 슬롯 행: [슬롯 버튼] + [삭제 버튼]
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		slot_container.add_child(row)

		var cb = Callable()
		if enabled:
			cb = func(): _load_slot(slot)
		var slot_panel = _slot_button(top_line, sub_line, enabled, cb)
		slot_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(slot_panel)

		# 삭제 버튼 (데이터가 있을 때만 표시)
		if enabled:
			var del_btn = Button.new()
			del_btn.text = "🗑"
			del_btn.custom_minimum_size = Vector2(36, 56)
			del_btn.flat = false
			var del_st = StyleBoxFlat.new()
			del_st.bg_color = Color("#2a1010")
			del_st.border_color = Color("#5a1a1a")
			del_st.set_border_width_all(1)
			del_st.set_corner_radius_all(6)
			var del_hover = del_st.duplicate()
			del_hover.bg_color = Color("#3d1515")
			del_btn.add_theme_stylebox_override("normal", del_st)
			del_btn.add_theme_stylebox_override("hover", del_hover)
			del_btn.add_theme_stylebox_override("pressed", del_hover)
			del_btn.add_theme_font_size_override("font_size", 16)
			del_btn.pressed.connect(func(): _confirm_delete(slot))
			row.add_child(del_btn)

var _delete_confirm_slot: int = -1

func _confirm_delete(slot: int):
	if _delete_confirm_slot == slot:
		# 두 번째 클릭 → 실제 삭제
		SaveManager.delete_save(slot)
		_delete_confirm_slot = -1
		_rebuild_slots()
	else:
		# 첫 번째 클릭 → 확인 대기 상태로 전환 후 슬롯 다시 그림
		_delete_confirm_slot = slot
		_rebuild_slots_with_confirm(slot)

func _rebuild_slots_with_confirm(confirm_slot: int):
	# _rebuild_slots와 동일하되, confirm_slot의 삭제 버튼을 "확인?" 상태로 표시
	for child in slot_container.get_children():
		child.queue_free()

	for slot in range(0, 4):
		var info = SaveManager.get_save_info(slot)
		var top_line = "자동저장" if slot == 0 else "슬롯 %d" % slot
		var sub_line = ""
		if info.get("empty", true):
			sub_line = "비어 있음"
		else:
			sub_line = "%d년 %d월  ·  %s" % [
				info.get("year", 2026), info.get("month", 1),
				_format_money(info.get("total_assets", 0))
			]
		var enabled = not info.get("empty", true)

		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		slot_container.add_child(row)

		var cb = Callable()
		if enabled and slot != confirm_slot:
			cb = func(): _load_slot(slot)
		var slot_panel = _slot_button(top_line, sub_line, enabled and slot != confirm_slot, cb)
		slot_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(slot_panel)

		if enabled:
			var del_btn = Button.new()
			var is_confirm = (slot == confirm_slot)
			del_btn.text = "삭제!" if is_confirm else "🗑"
			del_btn.custom_minimum_size = Vector2(44, 56)
			var del_st = StyleBoxFlat.new()
			del_st.bg_color = Color("#5a1a1a") if is_confirm else Color("#2a1010")
			del_st.border_color = Color("#ff4444") if is_confirm else Color("#5a1a1a")
			del_st.set_border_width_all(1)
			del_st.set_corner_radius_all(6)
			var del_hover = del_st.duplicate()
			del_hover.bg_color = Color("#7a2020") if is_confirm else Color("#3d1515")
			del_btn.add_theme_stylebox_override("normal", del_st)
			del_btn.add_theme_stylebox_override("hover", del_hover)
			del_btn.add_theme_stylebox_override("pressed", del_hover)
			del_btn.add_theme_font_size_override("font_size", 11)
			del_btn.add_theme_color_override("font_color", Color("#ff6666") if is_confirm else Color("#884444"))
			del_btn.pressed.connect(func(): _confirm_delete(slot))
			row.add_child(del_btn)

			# 확인 대기 중이면 취소 버튼 추가
			if is_confirm:
				var cancel_btn = Button.new()
				cancel_btn.text = "취소"
				cancel_btn.custom_minimum_size = Vector2(44, 56)
				var cancel_st = StyleBoxFlat.new()
				cancel_st.bg_color = Color("#1a1a28")
				cancel_st.border_color = Color("#3a3a50")
				cancel_st.set_border_width_all(1)
				cancel_st.set_corner_radius_all(6)
				cancel_btn.add_theme_stylebox_override("normal", cancel_st)
				cancel_btn.add_theme_font_size_override("font_size", 11)
				cancel_btn.add_theme_color_override("font_color", Color("#6a7590"))
				cancel_btn.pressed.connect(func():
					_delete_confirm_slot = -1
					_rebuild_slots()
				)
				row.add_child(cancel_btn)


# ── 시작 / 로드 ─────────────────────────────────────────────────
func _start_new_run():
	# 이름·루트·특성 선택 없이 고정 시작 (드라마 모드)
	# 성향은 플레이 중 선택으로 자연스럽게 결정됨
	GameState.start_new_game("none", "김민준", "지방_상경", "none")
	SceneTransition.go("res://scenes/MainGame.tscn")

func _load_slot(slot):
	if SaveManager.load_game(slot):
		SceneTransition.go("res://scenes/MainGame.tscn")

# ── UI 헬퍼 ────────────────────────────────────────────────────
func _label(text, size, color, align) -> Label:
	var lbl = Label.new()
	lbl.text = text
	lbl.horizontal_alignment = align
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", Color(color))
	return lbl

func _sep() -> HSeparator:
	var s = HSeparator.new()
	s.add_theme_color_override("color", Color("#1e1e2a"))
	return s

func _button(text, color) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 48)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(color)
	normal.set_corner_radius_all(6)
	var hover = normal.duplicate()
	hover.bg_color = Color(color).lightened(0.12)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_color_override("font_color", Color("#ffffff"))
	button.add_theme_font_size_override("font_size", 15)
	return button

func _slot_button(top_line: String, sub_line: String, enabled: bool, on_press: Callable = Callable()) -> Control:
	var outer = PanelContainer.new()
	outer.custom_minimum_size = Vector2(0, 56)
	outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st = StyleBoxFlat.new()
	st.bg_color = Color("#1a1a26") if enabled else Color("#111118")
	st.border_color = Color("#3a3a5a") if enabled else Color("#1e1e2a")
	st.set_border_width_all(1)
	st.set_corner_radius_all(6)
	st.content_margin_left = 14
	st.content_margin_right = 14
	st.content_margin_top = 8
	st.content_margin_bottom = 8
	outer.add_theme_stylebox_override("panel", st)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	outer.add_child(vbox)

	var lbl1 = Label.new()
	lbl1.text = top_line
	lbl1.add_theme_font_size_override("font_size", 13)
	lbl1.add_theme_color_override("font_color", Color("#e8eaf0") if enabled else Color("#3a3a5a"))
	vbox.add_child(lbl1)

	var lbl2 = Label.new()
	lbl2.text = sub_line
	lbl2.add_theme_font_size_override("font_size", 11)
	lbl2.add_theme_color_override("font_color", Color("#5b7a9a") if enabled else Color("#2a2a3a"))
	vbox.add_child(lbl2)

	if enabled and on_press.is_valid():
		var btn = Button.new()
		btn.flat = true
		btn.set_anchors_preset(Control.PRESET_FULL_RECT)
		var empty_st = StyleBoxEmpty.new()
		btn.add_theme_stylebox_override("normal", empty_st)
		btn.add_theme_stylebox_override("pressed", empty_st)
		btn.add_theme_stylebox_override("focus", empty_st)
		var hover_st = StyleBoxFlat.new()
		hover_st.bg_color = Color(1.0, 1.0, 1.0, 0.06)
		hover_st.set_corner_radius_all(6)
		btn.add_theme_stylebox_override("hover", hover_st)
		btn.pressed.connect(on_press)
		outer.add_child(btn)

	return outer

func _open_settings_popup():
	if _settings_overlay and is_instance_valid(_settings_overlay):
		_settings_overlay.queue_free()

	_settings_overlay = ColorRect.new()
	_settings_overlay.color = Color(0, 0, 0, 0.7)
	_settings_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_settings_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_settings_overlay)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(340, 0)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	var pst = StyleBoxFlat.new()
	pst.bg_color = Color("#13131f")
	pst.border_color = Color("#2a2a40")
	pst.set_border_width_all(1)
	pst.set_corner_radius_all(10)
	pst.content_margin_left = 24
	pst.content_margin_right = 24
	pst.content_margin_top = 20
	pst.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", pst)
	_settings_overlay.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)

	var title = Label.new()
	title.text = "⚙️ 설정"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color("#e8eaf0"))
	vbox.add_child(title)

	var sep = HSeparator.new()
	sep.modulate = Color("#2a2a3a")
	vbox.add_child(sep)

	_build_volume_sliders_menu(vbox)

	var close_btn = _button("닫기", "#1e2a3a")
	close_btn.pressed.connect(func(): _settings_overlay.queue_free())
	vbox.add_child(close_btn)

func _build_volume_sliders_menu(parent: Control):
	var _make_row = func(label_text: String, init_val: float, on_change: Callable):
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		parent.add_child(row)
		var lbl = Label.new()
		lbl.text = label_text
		lbl.add_theme_font_size_override("font_size", 13)
		lbl.add_theme_color_override("font_color", Color("#8892a4"))
		lbl.custom_minimum_size = Vector2(48, 0)
		row.add_child(lbl)
		var slider = HSlider.new()
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.05
		slider.value = init_val
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.custom_minimum_size = Vector2(0, 24)
		row.add_child(slider)
		var pct = Label.new()
		pct.text = "%d%%" % int(init_val * 100)
		pct.add_theme_font_size_override("font_size", 12)
		pct.add_theme_color_override("font_color", Color("#5a6075"))
		pct.custom_minimum_size = Vector2(36, 0)
		pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(pct)
		slider.value_changed.connect(func(v):
			pct.text = "%d%%" % int(v * 100)
			on_change.call(v)
		)

	_make_row.call("🎵 BGM", AudioManager.bgm_volume, func(v): AudioManager.set_bgm_volume(v))
	_make_row.call("🔊 SFX", AudioManager.master_volume, func(v): AudioManager.set_sfx_volume(v))

func _format_money(amount) -> String:
	if abs(amount) >= 100_000_000:
		return "%.1f억원" % (amount / 100_000_000.0)
	if abs(amount) >= 10_000:
		return "%.0f만원" % (amount / 10_000.0)
	return "%.0f원" % amount
