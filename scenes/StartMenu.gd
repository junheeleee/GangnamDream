extends Control

# 드라마 모드: 루트/특성 선택 없이 김민준 33세 백수로 고정 시작.
# 성향(직장/투자/창업)은 플레이 중 선택 누적으로 자연스럽게 결정된다.

var slot_container: VBoxContainer
var _settings_overlay: ColorRect

var _splash_layer: Control
var _splash_active: bool = true

# ── 런 테마 선택 ─────────────────────────────────────────────────
var _selected_theme: String = "자유런"
var _theme_row: HBoxContainer
var _theme_desc_label: Label

# ── 난이도 선택 ─────────────────────────────────────────────────
var _selected_diff: String = "현실"
var _diff_row: HBoxContainer
var _diff_desc_label: Label

const RUN_THEMES = [
	{
		"id": "자유런",
		"icon": "🎲",
		"name": "자유런",
		"tagline": "매 판 다른 이야기",
		"desc": "런마다 랜덤 카테고리 2개 부스트. 아무 제약 없음.",
		"diff": "★★★☆☆",
	},
	{
		"id": "투자런",
		"icon": "📈",
		"name": "투자런",
		"tagline": "돈으로 돈을 번다",
		"desc": "투자·재정 이벤트 집중. 투자감각 +5 시작. 시장 파동에 올라타라.",
		"diff": "★★★★☆",
	},
	{
		"id": "인맥런",
		"icon": "🤝",
		"name": "인맥런",
		"tagline": "사람이 자본이다",
		"desc": "사회·관계 이벤트 집중. 사교력 +10 시작. 연결이 돈이 된다.",
		"diff": "★★★☆☆",
	},
	{
		"id": "청렴런",
		"icon": "✨",
		"name": "청렴런",
		"tagline": "도박 없이, 실력으로만",
		"desc": "도박 이벤트 완전 차단. 평판 +10 시작. 정직하게 30억.",
		"diff": "★★★★★",
	},
]

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
	tagline.text = "서울 고시원 50만원에서 강남드림까지"
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
	bg.color = Color("#080810")
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var scene_bg = TextureRect.new()
	scene_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	scene_bg.stretch_mode = TextureRect.STRETCH_SCALE
	scene_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	scene_bg.modulate = Color(1, 1, 1, 0.13)
	scene_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg_tex = load("res://assets/backgrounds/goshiwon_room.png")
	if bg_tex:
		scene_bg.texture = bg_tex
	add_child(scene_bg)

	# ── 메인 마진 ──
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 22)
	add_child(margin)

	var root = VBoxContainer.new()
	root.add_theme_constant_override("separation", 0)
	margin.add_child(root)

	# ── 헤더 행 (타이틀 + 설정) ──
	var header_row = HBoxContainer.new()
	header_row.custom_minimum_size = Vector2(0, 52)
	header_row.add_theme_constant_override("separation", 10)
	root.add_child(header_row)

	var title_vb = VBoxContainer.new()
	title_vb.add_theme_constant_override("separation", 2)
	title_vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_vb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header_row.add_child(title_vb)
	var title_lbl = _label("강남드림", 34, "#f0b429", HORIZONTAL_ALIGNMENT_LEFT)
	title_lbl.autowrap_mode = TextServer.AUTOWRAP_OFF
	title_lbl.clip_text = false
	title_vb.add_child(title_lbl)
	var sub_lbl = _label("한국 인생 시뮬레이션  ·  38세 전에 자산 30억", 10, "#2e3e50", HORIZONTAL_ALIGNMENT_LEFT)
	sub_lbl.autowrap_mode = TextServer.AUTOWRAP_OFF
	sub_lbl.clip_text = false
	title_vb.add_child(sub_lbl)

	var settings_btn = _button("⚙", "#1a1a28")
	settings_btn.custom_minimum_size = Vector2(44, 44)
	settings_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	settings_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	settings_btn.pressed.connect(_open_settings_popup)
	header_row.add_child(settings_btn)

	var hdr_sep = HSeparator.new()
	hdr_sep.add_theme_color_override("color", Color("#161622"))
	root.add_child(hdr_sep)

	var sp_top = Control.new(); sp_top.custom_minimum_size = Vector2(0, 14); root.add_child(sp_top)

	# ── 본문: 왼쪽(새 게임) + 구분 + 오른쪽(불러오기) ──
	var cols = HBoxContainer.new()
	cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cols.add_theme_constant_override("separation", 30)
	root.add_child(cols)

	# ═══ 왼쪽 컬럼 ═══════════════════════════════════════
	var left = VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 10)
	cols.add_child(left)

	# ── 스토리 텍스트 (큼직하게) ──
	var story_panel = PanelContainer.new()
	var sp_st = StyleBoxFlat.new()
	sp_st.bg_color = Color("#09091400")
	sp_st.border_color = Color("#f0b429")
	sp_st.border_width_left = 3
	sp_st.set_corner_radius_all(4)
	sp_st.content_margin_left = 16
	sp_st.content_margin_right = 12
	sp_st.content_margin_top = 14
	sp_st.content_margin_bottom = 14
	story_panel.add_theme_stylebox_override("panel", sp_st)
	var story_rtl = RichTextLabel.new()
	story_rtl.bbcode_enabled = true
	story_rtl.fit_content = true
	story_rtl.scroll_active = false
	story_rtl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	story_rtl.add_theme_font_size_override("normal_font_size", 15)
	story_rtl.add_theme_color_override("default_color", Color("#6a7888"))
	story_rtl.text = (
		"[color=#b0bcd0][b]김민준, 33세.[/b]  아버지의 빚 6년.  이제 통장에 50만원만 남았다.[/color]\n\n"
		+ "[color=#e8eaf0][b]38살이 되기 전에, 강남에 입성한다.[/b][/color]\n"
		+ "[color=#6a7888]불가능하다는 걸 안다.  그래서 시작한다.[/color]")
	story_panel.add_child(story_rtl)
	left.add_child(story_panel)

	var sp1 = Control.new(); sp1.custom_minimum_size = Vector2(0, 18); left.add_child(sp1)

	# ── 난이도 (compact 가로 카드) ──
	var diff_hdr_lbl = _label("난이도", 11, "#5a6a7a", HORIZONTAL_ALIGNMENT_LEFT)
	diff_hdr_lbl.autowrap_mode = TextServer.AUTOWRAP_OFF
	diff_hdr_lbl.clip_text = false
	left.add_child(diff_hdr_lbl)

	_diff_row = HBoxContainer.new()
	_diff_row.add_theme_constant_override("separation", 6)
	left.add_child(_diff_row)

	_diff_desc_label = Label.new()
	_diff_desc_label.add_theme_font_size_override("font_size", 11)
	_diff_desc_label.add_theme_color_override("font_color", Color("#4a6a54"))
	_diff_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_diff_desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_child(_diff_desc_label)

	_build_diff_cards()

	var sp_diff = Control.new(); sp_diff.custom_minimum_size = Vector2(0, 10); left.add_child(sp_diff)

	# ── 런 테마 (compact 가로 버튼) ──
	var theme_hdr = HBoxContainer.new()
	theme_hdr.add_theme_constant_override("separation", 8)
	left.add_child(theme_hdr)
	var theme_hdr_lbl = _label("런 테마", 11, "#5a6a7a", HORIZONTAL_ALIGNMENT_LEFT)
	theme_hdr_lbl.autowrap_mode = TextServer.AUTOWRAP_OFF
	theme_hdr_lbl.clip_text = false
	theme_hdr_lbl.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	theme_hdr.add_child(theme_hdr_lbl)
	var theme_hint_lbl = _label("(2회차 이상 추천 — 처음이라면 자유런)", 10, "#2a3a4a", HORIZONTAL_ALIGNMENT_LEFT)
	theme_hint_lbl.autowrap_mode = TextServer.AUTOWRAP_OFF
	theme_hint_lbl.clip_text = false
	theme_hdr.add_child(theme_hint_lbl)

	_theme_row = HBoxContainer.new()
	_theme_row.add_theme_constant_override("separation", 6)
	left.add_child(_theme_row)

	# 테마 설명 (작고 심플하게)
	_theme_desc_label = Label.new()
	_theme_desc_label.add_theme_font_size_override("font_size", 11)
	_theme_desc_label.add_theme_color_override("font_color", Color("#4a6a54"))
	_theme_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_theme_desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_child(_theme_desc_label)

	_build_theme_cards()

	# 스페이서 (시작 버튼을 항상 하단에 붙임)
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(spacer)

	# ── 새 게임 시작 버튼 ──
	var new_game = _button("새 이야기 시작  ▶", "#0d2a1a")
	var ng_st = StyleBoxFlat.new()
	ng_st.bg_color = Color("#0d2a1a")
	ng_st.border_color = Color("#00c896")
	ng_st.border_width_left = 4
	ng_st.set_corner_radius_all(5)
	ng_st.content_margin_left = 20
	ng_st.content_margin_right = 20
	ng_st.content_margin_top = 12
	ng_st.content_margin_bottom = 12
	new_game.add_theme_stylebox_override("normal", ng_st)
	var ng_hov = ng_st.duplicate()
	ng_hov.bg_color = Color("#133a24")
	new_game.add_theme_stylebox_override("hover", ng_hov)
	new_game.add_theme_color_override("font_color", Color("#00c896"))
	new_game.add_theme_font_size_override("font_size", 17)
	new_game.pressed.connect(_start_new_run)
	left.add_child(new_game)
	new_game.call_deferred("grab_focus")

	# ── 구분선 ──
	var vsep = VSeparator.new()
	vsep.add_theme_color_override("color", Color("#181828"))
	cols.add_child(vsep)

	# ═══ 오른쪽 컬럼 ═══════════════════════════════════════
	var right = VBoxContainer.new()
	right.custom_minimum_size = Vector2(232, 0)
	right.add_theme_constant_override("separation", 10)
	cols.add_child(right)

	right.add_child(_label("이어하기", 13, "#c9a227", HORIZONTAL_ALIGNMENT_LEFT))

	slot_container = VBoxContainer.new()
	slot_container.add_theme_constant_override("separation", 8)
	right.add_child(slot_container)
	_rebuild_slots()

	var right_spacer = Control.new()
	right_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(right_spacer)

	right.add_child(_sep())

	# 메타 한 줄 (업적 그리드 제거 — 첫 플레이어 혼란 방지)
	var meta = MetaProgression.data
	var unlocked_ach_count: int = MetaProgression.get_unlocked_achievements().size()
	var total_ach: int = DataRegistry.achievements.size()
	right.add_child(_label(
		"누적 %d런  ·  최고 자산 %s" % [meta.get("total_runs", 0), _format_money(meta.get("best_asset", 0))],
		10, "#2a3a4a", HORIZONTAL_ALIGNMENT_LEFT))
	right.add_child(_label(
		"업적 %d / %d 해금" % [unlocked_ach_count, total_ach],
		10, "#2a3a4a", HORIZONTAL_ALIGNMENT_LEFT))

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
func _build_theme_cards() -> void:
	if not is_instance_valid(_theme_row):
		return
	for ch in _theme_row.get_children():
		ch.queue_free()
	await get_tree().process_frame
	for t in RUN_THEMES:
		var tid: String = t["id"]
		var is_selected: bool = (_selected_theme == tid)
		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.custom_minimum_size = Vector2(0, 74)
		var st := StyleBoxFlat.new()
		st.bg_color = Color("#111e14") if is_selected else Color("#0d1017")
		st.border_color = Color("#3dba6a") if is_selected else Color("#1a2030")
		st.set_border_width_all(2 if is_selected else 1)
		st.set_corner_radius_all(7)
		st.content_margin_top = 6
		st.content_margin_bottom = 6
		card.add_theme_stylebox_override("panel", st)
		var vb := VBoxContainer.new()
		vb.add_theme_constant_override("separation", 3)
		vb.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_child(vb)
		var icon_lbl := Label.new()
		icon_lbl.text = t["icon"]
		icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_lbl.add_theme_font_size_override("font_size", 22)
		icon_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vb.add_child(icon_lbl)
		var name_lbl := Label.new()
		name_lbl.text = t["name"]
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 11)
		name_lbl.add_theme_color_override("font_color", Color("#b8e8c8") if is_selected else Color("#5a6a7a"))
		name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vb.add_child(name_lbl)
		var diff_lbl2 := Label.new()
		diff_lbl2.text = t["diff"]
		diff_lbl2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		diff_lbl2.add_theme_font_size_override("font_size", 9)
		diff_lbl2.add_theme_color_override("font_color", Color("#5a8a60") if is_selected else Color("#1e2830"))
		diff_lbl2.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vb.add_child(diff_lbl2)
		var btn := Button.new()
		btn.flat = true
		btn.set_anchors_preset(Control.PRESET_FULL_RECT)
		var empty_st := StyleBoxEmpty.new()
		btn.add_theme_stylebox_override("normal", empty_st)
		btn.add_theme_stylebox_override("pressed", empty_st)
		btn.add_theme_stylebox_override("focus", empty_st)
		var hover_st2 := StyleBoxFlat.new()
		hover_st2.bg_color = Color(1, 1, 1, 0.05)
		hover_st2.set_corner_radius_all(6)
		btn.add_theme_stylebox_override("hover", hover_st2)
		btn.pressed.connect(func(): _select_theme(tid))
		card.add_child(btn)
		_theme_row.add_child(card)
	_update_theme_desc()

func _select_theme(tid: String) -> void:
	_selected_theme = tid
	AudioManager.play("click")
	_build_theme_cards()

# ── 난이도 카드 (테마 카드와 같은 패턴) ─────────────────────────
func _build_diff_cards() -> void:
	if not is_instance_valid(_diff_row):
		return
	for ch in _diff_row.get_children():
		ch.queue_free()
	await get_tree().process_frame
	for did in GameState.DIFFICULTY_DATA:
		var d: Dictionary = GameState.DIFFICULTY_DATA[did]
		var is_selected: bool = (_selected_diff == did)
		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.custom_minimum_size = Vector2(0, 74)
		var st := StyleBoxFlat.new()
		st.bg_color = Color("#1a1410") if is_selected else Color("#0d1017")
		st.border_color = Color("#f0b429") if is_selected else Color("#1a2030")
		st.set_border_width_all(2 if is_selected else 1)
		st.set_corner_radius_all(7)
		st.content_margin_top = 6
		st.content_margin_bottom = 6
		card.add_theme_stylebox_override("panel", st)
		var vb := VBoxContainer.new()
		vb.add_theme_constant_override("separation", 3)
		vb.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_child(vb)
		var icon_lbl := Label.new()
		icon_lbl.text = str(d["icon"])
		icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_lbl.add_theme_font_size_override("font_size", 22)
		icon_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vb.add_child(icon_lbl)
		var name_lbl := Label.new()
		name_lbl.text = str(d["name"])
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 11)
		name_lbl.add_theme_color_override("font_color", Color("#f0d8a8") if is_selected else Color("#5a6a7a"))
		name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vb.add_child(name_lbl)
		var stars_lbl := Label.new()
		stars_lbl.text = str(d["stars"])
		stars_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stars_lbl.add_theme_font_size_override("font_size", 9)
		stars_lbl.add_theme_color_override("font_color", Color("#8a7a50") if is_selected else Color("#1e2830"))
		stars_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vb.add_child(stars_lbl)
		var btn := Button.new()
		btn.flat = true
		btn.set_anchors_preset(Control.PRESET_FULL_RECT)
		var empty_st := StyleBoxEmpty.new()
		btn.add_theme_stylebox_override("normal", empty_st)
		btn.add_theme_stylebox_override("pressed", empty_st)
		btn.add_theme_stylebox_override("focus", empty_st)
		var hover_st := StyleBoxFlat.new()
		hover_st.bg_color = Color(1, 1, 1, 0.05)
		hover_st.set_corner_radius_all(6)
		btn.add_theme_stylebox_override("hover", hover_st)
		btn.pressed.connect(func(): _select_diff(did))
		card.add_child(btn)
		_diff_row.add_child(card)
	_update_diff_desc()

func _select_diff(did: String) -> void:
	_selected_diff = did
	AudioManager.play("click")
	_build_diff_cards()

func _update_diff_desc() -> void:
	if not is_instance_valid(_diff_desc_label):
		return
	var d: Dictionary = GameState.DIFFICULTY_DATA.get(_selected_diff, {})
	_diff_desc_label.text = "%s  —  %s" % [str(d.get("tagline", "")), str(d.get("desc", ""))]

func _update_theme_desc() -> void:
	if not is_instance_valid(_theme_desc_label):
		return
	for t in RUN_THEMES:
		if t["id"] == _selected_theme:
			_theme_desc_label.text = "%s  %s" % [t["tagline"], t["diff"]]
			return

# ── 시작 / 로드 ─────────────────────────────────────────────────
func _start_new_run():
	# 첫 실행 시 콘텐츠 경고 표시
	if not MetaProgression.data.get("content_warning_seen", false):
		_show_content_warning()
		return
	_do_start_run()

func _show_content_warning():
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.82)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(460, 0)
	var panel_st = StyleBoxFlat.new()
	panel_st.bg_color = Color("#12121e")
	panel_st.border_color = Color("#f0b429")
	panel_st.set_border_width_all(1)
	panel_st.set_corner_radius_all(10)
	panel_st.content_margin_left = 28
	panel_st.content_margin_right = 28
	panel_st.content_margin_top = 28
	panel_st.content_margin_bottom = 28
	panel.add_theme_stylebox_override("panel", panel_st)
	overlay.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)

	var title_lbl = Label.new()
	if LocaleManager.language == "en":
		title_lbl.text = "⚠  Content Notice"
	else:
		title_lbl.text = "⚠  콘텐츠 안내"
	title_lbl.add_theme_font_size_override("font_size", 17)
	title_lbl.add_theme_color_override("font_color", Color("#f0b429"))
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_lbl)

	var sep0 = HSeparator.new()
	sep0.add_theme_color_override("color", Color("#252535"))
	vbox.add_child(sep0)

	var body_lbl = Label.new()
	body_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_lbl.custom_minimum_size = Vector2(400, 0)
	if LocaleManager.language == "en":
		body_lbl.text = (
			"This game contains depictions of:\n\n"
			+ "• Financial hardship and debt\n"
			+ "• Family pressure and social comparison\n"
			+ "• Workplace stress and burnout\n"
			+ "• Mental health struggles\n\n"
			+ "Gangnam Dream is a realistic portrayal of life. "
			+ "Difficult situations are part of the story — not endorsements."
		)
	else:
		body_lbl.text = (
			"이 게임에는 다음과 같은 내용이 포함됩니다:\n\n"
			+ "• 재정적 어려움과 부채\n"
			+ "• 가족·사회적 압박과 비교\n"
			+ "• 직장 스트레스와 번아웃\n"
			+ "• 정신건강 관련 묘사\n\n"
			+ "강남드림은 현실적인 삶을 다룹니다. "
			+ "어려운 상황들은 이야기의 일부이며, 권장하는 내용이 아닙니다."
		)
	body_lbl.add_theme_font_size_override("font_size", 13)
	body_lbl.add_theme_color_override("font_color", Color("#8892a4"))
	vbox.add_child(body_lbl)

	var sep1 = HSeparator.new()
	sep1.add_theme_color_override("color", Color("#252535"))
	vbox.add_child(sep1)

	var btn_row = HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 10)
	vbox.add_child(btn_row)

	var back_btn = Button.new()
	back_btn.text = "← 뒤로" if LocaleManager.language != "en" else "← Back"
	back_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back_btn.custom_minimum_size = Vector2(0, 44)
	var back_st = StyleBoxFlat.new()
	back_st.bg_color = Color("#1e1e2a")
	back_st.set_corner_radius_all(6)
	back_btn.add_theme_stylebox_override("normal", back_st)
	back_btn.add_theme_color_override("font_color", Color("#8892a4"))
	back_btn.add_theme_font_size_override("font_size", 14)
	back_btn.pressed.connect(overlay.queue_free)
	btn_row.add_child(back_btn)

	var ok_btn = Button.new()
	ok_btn.text = "이해했습니다 →" if LocaleManager.language != "en" else "Understood →"
	ok_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ok_btn.custom_minimum_size = Vector2(0, 44)
	var ok_st = StyleBoxFlat.new()
	ok_st.bg_color = Color("#f0b429")
	ok_st.set_corner_radius_all(6)
	var ok_hover = ok_st.duplicate()
	ok_hover.bg_color = Color("#f0b429").lightened(0.1)
	ok_btn.add_theme_stylebox_override("normal", ok_st)
	ok_btn.add_theme_stylebox_override("hover", ok_hover)
	ok_btn.add_theme_color_override("font_color", Color("#0a0a0e"))
	ok_btn.add_theme_font_size_override("font_size", 14)
	ok_btn.pressed.connect(func():
		MetaProgression.data["content_warning_seen"] = true
		MetaProgression.save_meta()
		overlay.queue_free()
		_do_start_run()
	)
	btn_row.add_child(ok_btn)

func _do_start_run():
	# 이름·루트 선택 없이 고정 시작 (드라마 모드)
	# 성향은 플레이 중 선택으로 자연스럽게 결정됨
	GameState.start_new_game("김민준", "지방_상경", "none", "백수", _selected_theme, _selected_diff)
	SceneTransition.go("res://scenes/MainGame.tscn")

func _load_slot(slot):
	if SaveManager.load_game(slot):
		SceneTransition.go("res://scenes/MainGame.tscn")

# ── UI 헬퍼 ────────────────────────────────────────────────────
func _section_header(text: String) -> Label:
	var lbl = Label.new()
	lbl.text = text
	lbl.autowrap_mode = TextServer.AUTOWRAP_OFF
	lbl.clip_text = false
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", Color("#c9a227"))
	return lbl

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
	var focus_st = normal.duplicate()
	focus_st.border_color = Color("#f0b429")
	focus_st.set_border_width_all(2)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", focus_st)
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
	lbl2.add_theme_color_override("font_color", Color("#7a6830") if enabled else Color("#2a2a3a"))
	vbox.add_child(lbl2)

	if enabled and on_press.is_valid():
		var btn = Button.new()
		btn.flat = true
		btn.set_anchors_preset(Control.PRESET_FULL_RECT)
		var empty_st = StyleBoxEmpty.new()
		var focus_slot = StyleBoxFlat.new()
		focus_slot.bg_color = Color(0, 0, 0, 0)
		focus_slot.border_color = Color("#f0b429")
		focus_slot.set_border_width_all(2)
		focus_slot.set_corner_radius_all(6)
		btn.add_theme_stylebox_override("normal", empty_st)
		btn.add_theme_stylebox_override("pressed", empty_st)
		btn.add_theme_stylebox_override("focus", focus_slot)
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
	_build_language_toggle(vbox)

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
	_build_fullscreen_toggle(parent)

func _build_language_toggle(parent: Control):
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	parent.add_child(row)
	var lbl = Label.new()
	lbl.text = "🌐 언어 / Lang"
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", Color("#8892a4"))
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl)
	for lang_code in ["ko", "en"]:
		var btn = Button.new()
		btn.text = "한국어" if lang_code == "ko" else "EN"
		btn.custom_minimum_size = Vector2(64, 28)
		var is_active = LocaleManager.language == lang_code
		var st = StyleBoxFlat.new()
		st.bg_color = Color("#1a2a3a") if is_active else Color("#0d1017")
		st.border_color = Color("#c9a227") if is_active else Color("#2a2a40")
		st.set_border_width_all(1)
		st.set_corner_radius_all(4)
		var hov = st.duplicate()
		hov.bg_color = Color("#1e3040") if is_active else Color("#141a22")
		btn.add_theme_stylebox_override("normal", st)
		btn.add_theme_stylebox_override("hover", hov)
		btn.add_theme_color_override("font_color", Color("#e8eaf0") if is_active else Color("#5a6075"))
		btn.add_theme_font_size_override("font_size", 12)
		btn.pressed.connect((func(lc):
			LocaleManager.set_language(lc)
			if is_instance_valid(_settings_overlay):
				_settings_overlay.queue_free()
		).bind(lang_code))
		row.add_child(btn)

func _build_fullscreen_toggle(parent: Control):
	if OS.has_feature("web"):
		return
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	parent.add_child(row)
	var lbl = Label.new()
	lbl.text = "🖥️ 전체화면"
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", Color("#8892a4"))
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl)
	var hint = Label.new()
	hint.text = "F11 / Alt+Enter"
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color("#5a6075"))
	row.add_child(hint)
	var toggle = CheckButton.new()
	toggle.button_pressed = DisplayManager.fullscreen
	toggle.toggled.connect(func(on): DisplayManager.set_fullscreen(on))
	row.add_child(toggle)

func _format_money(amount) -> String:
	if abs(amount) >= 100_000_000:
		return "%.1f억원" % (amount / 100_000_000.0)
	if abs(amount) >= 10_000:
		return "%.0f만원" % (amount / 10_000.0)
	return "%.0f원" % amount
