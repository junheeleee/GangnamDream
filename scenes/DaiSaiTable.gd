extends Control
## DaiSaiTable — 정선 카지노 다이사이 테이블.
## 세 개의 주사위, 빅/스몰·홀짝·싱글·페어·트리플·합계 베팅을 제공한다.

signal closed

const DAI_SAI := preload("res://systems/DaiSai.gd")
const CASINO_BG_TEX := preload("res://assets/backgrounds/casino_interior.png")
const CHIP_TEX_BY_STAKE := {
	10_000: preload("res://assets/ui/chips/chip_10k.svg"),
	50_000: preload("res://assets/ui/chips/chip_50k.svg"),
	100_000: preload("res://assets/ui/chips/chip_100k.svg"),
	500_000: preload("res://assets/ui/chips/chip_500k.svg"),
	1_000_000: preload("res://assets/ui/chips/chip_1m.svg"),
}

enum Phase { IDLE, ROLLING, RESULT }

const STAKE_OPTIONS := [10_000, 50_000, 100_000, 500_000, 1_000_000]
const ROLL_DURATION := 1.35
const ROLL_TICK := 0.075
const HISTORY_MAX := 8

var _rng := RandomNumberGenerator.new()

var _phase: int = Phase.IDLE
var _bet_type: int = DAI_SAI.BET_BIG
var _selected: int = -1
var _stake: int = 50_000
var _dice: Array = [1, 2, 3]
var _pending_dice: Array = [1, 2, 3]
var _roll_elapsed: float = 0.0
var _roll_tick_elapsed: float = 0.0

var _rounds: int = 0
var _net: int = 0
var _wins: int = 0
var _losses: int = 0
var _history: Array = []

var _font: FontFile
var _font_bold: FontFile

var _hud_lbl: RichTextLabel
var _dice_ctrl: Control
var _msg_lbl: Label
var _balance_lbl: Label
var _roll_btn: Button
var _history_box: HBoxContainer
var _bet_info_lbl: Label
var _stake_btns: Array = []
var _bet_btns: Array = []

func _ready() -> void:
	_rng.randomize()
	_load_fonts()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 100
	visible = false
	_build_ui()
	set_process(false)

func _load_fonts() -> void:
	_font = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile

func _f(node: Object, bold: bool = false) -> void:
	var ft := _font_bold if bold else _font
	if ft and node:
		node.add_theme_font_override("font", ft)
		if node is RichTextLabel:
			node.add_theme_font_override("normal_font", ft)
			node.add_theme_font_override("bold_font", _font_bold if _font_bold else ft)

func open() -> void:
	_phase = Phase.IDLE
	_bet_type = DAI_SAI.BET_BIG
	_selected = -1
	_stake = 50_000
	_dice = [1, 2, 3]
	_pending_dice = [1, 2, 3]
	_roll_elapsed = 0.0
	_roll_tick_elapsed = 0.0
	_rounds = 0
	_net = 0
	_wins = 0
	_losses = 0
	_history = []
	visible = true
	set_process(false)
	TutorialOverlay.maybe_show("daisai", self)
	_refresh()

func _on_exit() -> void:
	MetaProgression.record_minigame_play("daisai")
	set_process(false)
	visible = false
	closed.emit()

func _process(delta: float) -> void:
	if _phase != Phase.ROLLING:
		set_process(false)
		return
	_roll_elapsed += delta
	_roll_tick_elapsed += delta
	if _roll_tick_elapsed >= ROLL_TICK:
		_roll_tick_elapsed = 0.0
		_dice = DAI_SAI.roll(_rng)
		AudioManager.play("casino_reel")
		if is_instance_valid(_dice_ctrl):
			_dice_ctrl.queue_redraw()
	if _roll_elapsed >= ROLL_DURATION:
		_dice = _pending_dice.duplicate()
		set_process(false)
		_finish_roll()

func _select_bet(t: int, selected: int = -1) -> void:
	if _phase != Phase.IDLE:
		return
	_bet_type = t
	_selected = selected
	AudioManager.play("casino_bet")
	_refresh()

func _select_stake(amount: int) -> void:
	if _phase == Phase.ROLLING:
		return
	_stake = amount
	AudioManager.play("casino_coin")
	_refresh()

func _do_roll() -> void:
	if _phase != Phase.IDLE:
		return
	if int(GameState.money) < _stake:
		_flash_msg("현금이 부족합니다", "#e85d5d")
		return

	GameState.add_money(-float(_stake))
	_pending_dice = DAI_SAI.roll(_rng)
	_phase = Phase.ROLLING
	_roll_elapsed = 0.0
	_roll_tick_elapsed = 0.0
	_msg_lbl.text = "주사위가 굴러갑니다..."
	_msg_lbl.add_theme_color_override("font_color", Color("#e8c45d"))
	AudioManager.play("casino_spin")
	set_process(true)
	_refresh()

func _finish_roll() -> void:
	var multiplier := DAI_SAI.payout_multiplier(_bet_type, _selected, _dice)
	var won := multiplier > 0.0
	var gross := 0
	var net_round := -_stake

	if won:
		gross = int(float(_stake) * (multiplier + 1.0))
		GameState.add_money(float(gross))
		net_round = gross - _stake
		_wins += 1
		GameState.modify_hidden_stat("gambling_tendency", 2 if multiplier >= 8.0 else 1)
		AudioManager.play_casino_result(float(net_round), float(_stake), multiplier >= 24.0)
		_flash_msg("당첨! %s  +%s" % [_dice_label(), GameState.format_money(float(net_round))], "#3de87a")
		_pulse_dice()
	else:
		_losses += 1
		GameState.modify_hidden_stat("addiction_tendency", 2)
		AudioManager.play_casino_result(float(net_round), float(_stake))
		_flash_msg("패배  %s" % _dice_label(), "#e85d5d")
		_shake_dice()

	_rounds += 1
	_net += net_round
	_history.push_front({
		"dice": _dice.duplicate(),
		"bet": DAI_SAI.label_for_bet(_bet_type, _selected),
		"win": won,
		"net": net_round,
	})
	if _history.size() > HISTORY_MAX:
		_history.pop_back()

	GameState.add_log("다이사이 %s %s (%s)" % [
		DAI_SAI.label_for_bet(_bet_type, _selected),
		"+" + GameState.format_money(float(net_round)) if net_round > 0 else "-" + GameState.format_money(float(abs(net_round))),
		_dice_label()
	], "money")
	MetaProgression.record_minigame_play("daisai")
	GameState.stats_changed.emit()

	_phase = Phase.RESULT
	_refresh()
	get_tree().create_timer(2.2).timeout.connect(func():
		if is_instance_valid(self) and visible and _phase == Phase.RESULT:
			_phase = Phase.IDLE
			_refresh()
	)

func _build_ui() -> void:
	var bg_img := TextureRect.new()
	bg_img.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg_img.texture = CASINO_BG_TEX
	bg_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_img.modulate = Color(0.95, 0.90, 0.85, 1.0)
	bg_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg_img)

	var veil := ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.color = Color(0.02, 0.015, 0.035, 0.60)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(veil)

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	add_child(root)

	var top := PanelContainer.new()
	top.custom_minimum_size = Vector2(0, 58)
	top.add_theme_stylebox_override("panel", _panel_style(Color("#090d16"), Color("#182236"), 0, 0))
	root.add_child(top)

	var top_row := HBoxContainer.new()
	top_row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	top_row.add_theme_constant_override("separation", 14)
	top.add_child(top_row)

	_hud_lbl = RichTextLabel.new()
	_hud_lbl.bbcode_enabled = true
	_hud_lbl.scroll_active = false
	_hud_lbl.fit_content = true
	_hud_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hud_lbl.add_theme_font_size_override("normal_font_size", 15)
	_f(_hud_lbl, true)
	top_row.add_child(_hud_lbl)

	var rules_btn := _make_button("규칙", "#171a25", "#8a6cff", 82, 38)
	rules_btn.pressed.connect(func(): TutorialOverlay.force_show("daisai", self))
	top_row.add_child(rules_btn)

	var exit_btn := _make_button("나가기", "#2a151a", "#e85d5d", 98, 38)
	exit_btn.pressed.connect(_on_exit)
	top_row.add_child(exit_btn)

	var body_margin := MarginContainer.new()
	body_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for side in ["margin_left", "margin_right"]:
		body_margin.add_theme_constant_override(side, 28)
	body_margin.add_theme_constant_override("margin_top", 18)
	body_margin.add_theme_constant_override("margin_bottom", 18)
	root.add_child(body_margin)

	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_margin.add_child(center)

	var table_panel := PanelContainer.new()
	table_panel.custom_minimum_size = Vector2(1120, 650)
	table_panel.add_theme_stylebox_override("panel", _panel_style(Color("#0c261d"), Color("#c49a38"), 2, 14))
	center.add_child(table_panel)

	var table_margin := MarginContainer.new()
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		table_margin.add_theme_constant_override(side, 18)
	table_panel.add_child(table_margin)

	var table := VBoxContainer.new()
	table.add_theme_constant_override("separation", 9)
	table_margin.add_child(table)

	var title := Label.new()
	title.text = "다이사이"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 27)
	title.add_theme_color_override("font_color", Color("#f2c45f"))
	_f(title, true)
	table.add_child(title)

	var stage_row := HBoxContainer.new()
	stage_row.add_theme_constant_override("separation", 16)
	table.add_child(stage_row)

	var dice_panel := PanelContainer.new()
	dice_panel.custom_minimum_size = Vector2(520, 164)
	dice_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dice_panel.add_theme_stylebox_override("panel", _panel_style(Color("#101722"), Color("#3d4d64"), 1, 10))
	stage_row.add_child(dice_panel)

	var dice_v := VBoxContainer.new()
	dice_v.add_theme_constant_override("separation", 6)
	var dice_margin := MarginContainer.new()
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		dice_margin.add_theme_constant_override(side, 12)
	dice_margin.add_child(dice_v)
	dice_panel.add_child(dice_margin)

	_dice_ctrl = Control.new()
	_dice_ctrl.custom_minimum_size = Vector2(480, 120)
	_dice_ctrl.draw.connect(_draw_dice)
	dice_v.add_child(_dice_ctrl)

	_bet_info_lbl = Label.new()
	_bet_info_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bet_info_lbl.add_theme_font_size_override("font_size", 13)
	_bet_info_lbl.add_theme_color_override("font_color", Color("#cfd5e5"))
	_f(_bet_info_lbl)
	dice_v.add_child(_bet_info_lbl)

	var info_panel := PanelContainer.new()
	info_panel.custom_minimum_size = Vector2(520, 164)
	info_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_panel.add_theme_stylebox_override("panel", _panel_style(Color("#17121f"), Color("#5c3f83"), 1, 10))
	stage_row.add_child(info_panel)

	var info_v := VBoxContainer.new()
	info_v.add_theme_constant_override("separation", 8)
	var info_margin := MarginContainer.new()
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		info_margin.add_theme_constant_override(side, 12)
	info_margin.add_child(info_v)
	info_panel.add_child(info_margin)

	_msg_lbl = Label.new()
	_msg_lbl.text = "BIG, SMALL 또는 원하는 조합에 베팅하세요."
	_msg_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_msg_lbl.add_theme_font_size_override("font_size", 15)
	_msg_lbl.add_theme_color_override("font_color", Color("#d8dbe8"))
	_msg_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_f(_msg_lbl, true)
	info_v.add_child(_msg_lbl)

	_balance_lbl = Label.new()
	_balance_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_balance_lbl.add_theme_font_size_override("font_size", 13)
	_balance_lbl.add_theme_color_override("font_color", Color("#8fe3a2"))
	_f(_balance_lbl)
	info_v.add_child(_balance_lbl)

	_history_box = HBoxContainer.new()
	_history_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_history_box.add_theme_constant_override("separation", 6)
	_history_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_v.add_child(_history_box)

	_add_bet_rows(table)
	_add_stake_and_action_rows(table)

func _add_bet_rows(table: VBoxContainer) -> void:
	var quick := HBoxContainer.new()
	quick.add_theme_constant_override("separation", 8)
	table.add_child(quick)
	quick.add_child(_bet_btn("BIG 11-17\n1:1", DAI_SAI.BET_BIG, -1, "#17313d", "#48b4ff", 154, 48))
	quick.add_child(_bet_btn("SMALL 4-10\n1:1", DAI_SAI.BET_SMALL, -1, "#173d2a", "#57d987", 154, 48))
	quick.add_child(_bet_btn("홀수\n1:1", DAI_SAI.BET_ODD, -1, "#2b213a", "#b78cff", 130, 48))
	quick.add_child(_bet_btn("짝수\n1:1", DAI_SAI.BET_EVEN, -1, "#2b213a", "#b78cff", 130, 48))
	quick.add_child(_bet_btn("ANY TRIPLE\n24:1", DAI_SAI.BET_ANY_TRIPLE, -1, "#3a1f1f", "#f07f55", 184, 48))

	var single := HBoxContainer.new()
	single.add_theme_constant_override("separation", 6)
	table.add_child(single)
	for face in range(1, 7):
		var f := int(face)
		single.add_child(_bet_btn("%d 싱글\n1~3:1" % f, DAI_SAI.BET_SINGLE, f, "#142026", "#75d6ff", 118, 44))

	var pair := HBoxContainer.new()
	pair.add_theme_constant_override("separation", 6)
	table.add_child(pair)
	for face in range(1, 7):
		var f := int(face)
		pair.add_child(_bet_btn("%d%d 페어\n8:1" % [f, f], DAI_SAI.BET_PAIR, f, "#171a25", "#d8dbe8", 118, 44))

	var triple := HBoxContainer.new()
	triple.add_theme_constant_override("separation", 6)
	table.add_child(triple)
	for face in range(1, 7):
		var f := int(face)
		triple.add_child(_bet_btn("%d%d%d\n150:1" % [f, f, f], DAI_SAI.BET_SPECIFIC_TRIPLE, f, "#2e1726", "#ff7ac8", 118, 44))

	var totals := GridContainer.new()
	totals.columns = 7
	totals.add_theme_constant_override("h_separation", 6)
	totals.add_theme_constant_override("v_separation", 6)
	table.add_child(totals)
	for total in range(4, 18):
		var t := int(total)
		var pay := int(DAI_SAI.TOTAL_PAYOUTS.get(t, 0.0))
		totals.add_child(_bet_btn("합계 %d\n%d:1" % [t, pay], DAI_SAI.BET_TOTAL, t, "#1a1825", "#e8c45d", 118, 42))

func _add_stake_and_action_rows(table: VBoxContainer) -> void:
	var stake_row := HBoxContainer.new()
	stake_row.add_theme_constant_override("separation", 8)
	table.add_child(stake_row)

	var stake_label := Label.new()
	stake_label.text = "베팅 단위"
	stake_label.custom_minimum_size = Vector2(96, 42)
	stake_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stake_label.add_theme_font_size_override("font_size", 13)
	stake_label.add_theme_color_override("font_color", Color("#aeb6ca"))
	_f(stake_label, true)
	stake_row.add_child(stake_label)

	for amount in STAKE_OPTIONS:
		var a := int(amount)
		var btn := _make_chip_button(a)
		btn.pressed.connect(func(): _select_stake(a))
		_stake_btns.append({"btn": btn, "amount": a})
		stake_row.add_child(btn)

	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 10)
	table.add_child(action_row)
	_roll_btn = _make_button("ROLL", "#142a1c", "#4be37d", 220, 54)
	_roll_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_roll_btn.add_theme_font_size_override("font_size", 20)
	_roll_btn.pressed.connect(_do_roll)
	action_row.add_child(_roll_btn)

	var reset_btn := _make_button("기본 베팅", "#161a25", "#8a93a8", 160, 54)
	reset_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reset_btn.pressed.connect(func():
		_select_bet(DAI_SAI.BET_BIG, -1)
		_select_stake(50_000)
	)
	action_row.add_child(reset_btn)

	var close_btn := _make_button("카지노 허브로", "#2a151a", "#e85d5d", 180, 54)
	close_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close_btn.pressed.connect(_on_exit)
	action_row.add_child(close_btn)

func _bet_btn(text: String, t: int, selected: int, bg_hex: String, accent_hex: String, w: int, h: int) -> Button:
	var btn := _make_button(text, bg_hex, accent_hex, w, h)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.add_theme_font_size_override("font_size", 12)
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.pressed.connect(func(): _select_bet(t, selected))
	_bet_btns.append({
		"btn": btn,
		"type": t,
		"selected": selected,
		"bg": bg_hex,
		"accent": accent_hex,
	})
	return btn

func _make_chip_button(amount: int) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(150, 42)
	btn.text = "%s" % GameState.format_money(float(amount))
	btn.icon = CHIP_TEX_BY_STAKE.get(amount, null)
	btn.expand_icon = true
	btn.add_theme_font_size_override("font_size", 13)
	_f(btn, true)
	return btn

func _make_button(text: String, bg_hex: String, accent_hex: String, w: int, h: int) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(w, h)
	btn.add_theme_font_size_override("font_size", 13)
	_apply_button_style(btn, bg_hex, accent_hex, false)
	btn.add_theme_color_override("font_color", Color("#eef2ff"))
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	_f(btn, true)
	return btn

func _apply_button_style(btn: Button, bg_hex: String, accent_hex: String, selected: bool) -> void:
	var base := Color.html(bg_hex)
	var accent := Color.html(accent_hex)
	var sb := StyleBoxFlat.new()
	sb.bg_color = base.lightened(0.16) if selected else base
	sb.border_color = accent if selected else accent.darkened(0.25)
	sb.set_border_width_all(2 if selected else 1)
	sb.set_corner_radius_all(7)
	var hover := sb.duplicate()
	hover.bg_color = sb.bg_color.lightened(0.12)
	var pressed := sb.duplicate()
	pressed.bg_color = sb.bg_color.darkened(0.10)
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", sb)

func _panel_style(bg: Color, border: Color, border_w: int, radius: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	return sb

func _refresh() -> void:
	if _hud_lbl:
		var net_color := "#3de87a" if _net >= 0 else "#e85d5d"
		_hud_lbl.bbcode_text = "[b]현금[/b] %s   |   [b]라운드[/b] %d   승%d 패%d   |   [color=%s][b]손익[/b] %s%s[/color]" % [
			GameState.format_money(float(GameState.money)),
			_rounds,
			_wins,
			_losses,
			net_color,
			"+" if _net >= 0 else "-",
			GameState.format_money(float(abs(_net))),
		]
	if _balance_lbl:
		_balance_lbl.text = "현재 현금 %s" % GameState.format_money(float(GameState.money))
	if _bet_info_lbl:
		_bet_info_lbl.text = "선택: %s   |   베팅액: %s   |   결과: %s" % [
			DAI_SAI.label_for_bet(_bet_type, _selected),
			GameState.format_money(float(_stake)),
			_dice_label(),
		]
	if _roll_btn:
		_roll_btn.disabled = _phase != Phase.IDLE
		_roll_btn.text = "ROLLING..." if _phase == Phase.ROLLING else "ROLL"
	_update_bet_buttons()
	_update_stake_buttons()
	_refresh_history()
	if is_instance_valid(_dice_ctrl):
		_dice_ctrl.queue_redraw()

func _update_bet_buttons() -> void:
	for entry in _bet_btns:
		var btn := entry["btn"] as Button
		var selected := int(entry["type"]) == _bet_type and int(entry["selected"]) == _selected
		_apply_button_style(btn, str(entry["bg"]), str(entry["accent"]), selected)

func _update_stake_buttons() -> void:
	for entry in _stake_btns:
		var btn := entry["btn"] as Button
		var selected := int(entry["amount"]) == _stake
		_apply_button_style(btn, "#111827", "#4be37d" if selected else "#4a5568", selected)

func _refresh_history() -> void:
	if not is_instance_valid(_history_box):
		return
	for child in _history_box.get_children():
		child.queue_free()
	if _history.is_empty():
		var empty := Label.new()
		empty.text = "최근 결과 없음"
		empty.add_theme_font_size_override("font_size", 11)
		empty.add_theme_color_override("font_color", Color("#6f7788"))
		_f(empty)
		_history_box.add_child(empty)
		return
	for item in _history:
		var lbl := Label.new()
		var dice_arr: Array = item.get("dice", [])
		lbl.text = "%d-%d-%d" % [int(dice_arr[0]), int(dice_arr[1]), int(dice_arr[2])] if dice_arr.size() >= 3 else "---"
		lbl.custom_minimum_size = Vector2(70, 28)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Color("#3de87a") if bool(item.get("win", false)) else Color("#e85d5d"))
		lbl.add_theme_stylebox_override("normal", _panel_style(Color("#0d1118"), Color("#2b3448"), 1, 5))
		_f(lbl, true)
		_history_box.add_child(lbl)

func _draw_dice() -> void:
	if not is_instance_valid(_dice_ctrl):
		return
	var dice_size := 78.0
	var gap := 24.0
	var total_w := dice_size * 3.0 + gap * 2.0
	var x := (_dice_ctrl.size.x - total_w) * 0.5
	var y := (_dice_ctrl.size.y - dice_size) * 0.5
	var tray_rect := Rect2(Vector2(x - 30.0, y - 20.0), Vector2(total_w + 60.0, dice_size + 40.0))
	_dice_ctrl.draw_rect(Rect2(tray_rect.position + Vector2(0.0, 7.0), tray_rect.size), Color(0, 0, 0, 0.35), true)
	_dice_ctrl.draw_rect(tray_rect, Color("#07110f"), true)
	_dice_ctrl.draw_rect(tray_rect, Color("#31413d"), false, 2.0)

	var dome_center := tray_rect.get_center()
	_dice_ctrl.draw_set_transform(dome_center, 0.0, Vector2(1.75, 0.72))
	_dice_ctrl.draw_circle(Vector2.ZERO, 74.0, Color(0.78, 0.92, 1.0, 0.10))
	_dice_ctrl.draw_arc(Vector2.ZERO, 74.0, PI * 1.06, PI * 1.94, 48, Color(0.95, 1.0, 1.0, 0.32), 2.0)
	_dice_ctrl.draw_arc(Vector2.ZERO, 53.0, PI * 1.12, PI * 1.70, 32, Color(1.0, 1.0, 1.0, 0.20), 2.0)
	_dice_ctrl.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	for i in range(3):
		_draw_single_die(Vector2(x + float(i) * (dice_size + gap), y), dice_size, int(_dice[i]))

func _draw_single_die(pos: Vector2, size: float, value: int) -> void:
	var rect := Rect2(pos, Vector2(size, size))
	_dice_ctrl.draw_rect(Rect2(pos + Vector2(4.0, 5.0), Vector2(size, size)), Color(0, 0, 0, 0.30), true)
	_dice_ctrl.draw_rect(rect, Color("#f2f4f8"), true)
	_dice_ctrl.draw_rect(Rect2(pos + Vector2(5.0, 5.0), Vector2(size - 10.0, size - 10.0)), Color("#ffffff"), false, 1.0)
	_dice_ctrl.draw_rect(rect, Color("#9aa3b7"), false, 3.0)
	var pip_color := Color("#101722")
	var r := size * 0.055
	var p := {
		"tl": pos + Vector2(size * 0.28, size * 0.28),
		"tr": pos + Vector2(size * 0.72, size * 0.28),
		"ml": pos + Vector2(size * 0.28, size * 0.50),
		"mr": pos + Vector2(size * 0.72, size * 0.50),
		"bl": pos + Vector2(size * 0.28, size * 0.72),
		"br": pos + Vector2(size * 0.72, size * 0.72),
		"c": pos + Vector2(size * 0.50, size * 0.50),
	}
	var keys: Array = []
	match value:
		1:
			keys = ["c"]
		2:
			keys = ["tl", "br"]
		3:
			keys = ["tl", "c", "br"]
		4:
			keys = ["tl", "tr", "bl", "br"]
		5:
			keys = ["tl", "tr", "c", "bl", "br"]
		6:
			keys = ["tl", "tr", "ml", "mr", "bl", "br"]
	for k in keys:
		_dice_ctrl.draw_circle(p[k], r, pip_color)

func _dice_label() -> String:
	return "%d-%d-%d / 합계 %d" % [int(_dice[0]), int(_dice[1]), int(_dice[2]), DAI_SAI.total(_dice)]

func _flash_msg(text: String, color_hex: String) -> void:
	if not _msg_lbl:
		return
	_msg_lbl.text = text
	_msg_lbl.add_theme_color_override("font_color", Color.html(color_hex))

func _pulse_dice() -> void:
	if not is_instance_valid(_dice_ctrl):
		return
	var tw := create_tween()
	tw.tween_property(_dice_ctrl, "scale", Vector2(1.06, 1.06), 0.12)
	tw.tween_property(_dice_ctrl, "scale", Vector2.ONE, 0.16)

func _shake_dice() -> void:
	if not is_instance_valid(_dice_ctrl):
		return
	var base := _dice_ctrl.position
	var tw := create_tween()
	for i in range(5):
		var offset := Vector2(_rng.randf_range(-7.0, 7.0), _rng.randf_range(-3.0, 3.0))
		tw.tween_property(_dice_ctrl, "position", base + offset, 0.035)
	tw.tween_property(_dice_ctrl, "position", base, 0.05)
