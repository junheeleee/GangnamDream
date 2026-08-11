extends Control
## SlotMachineGame — 슬롯머신 UI 씬.
## SlotMachine 수학 모델 위에 릴 애니메이션·베팅·히스토리 UI 구현.
## MainGame이 overlay로 붙이고 open()으로 호출. 닫으면 closed 시그널.

signal closed

const SLOT := preload("res://systems/SlotMachine.gd")

enum Phase { IDLE, SPINNING, RESULT }

const COLOR_BG       := Color(0.06, 0.04, 0.10, 1.0)
const COLOR_GOLD     := Color("#c9a227")
const COLOR_GREEN    := Color("#2ecc71")
const COLOR_RED      := Color("#e74c3c")
const COLOR_DARK     := Color("#1a1a2e")
const COLOR_PANEL    := Color(0.08, 0.06, 0.14, 1.0)
const COLOR_BORDER   := Color(0.20, 0.15, 0.35, 1.0)

const STAKE_OPTIONS: Array = [1_000, 5_000, 10_000, 50_000, 100_000]
const CHIP_TEX_BY_STAKE := {
	1_000: preload("res://assets/ui/chips/chip_1k.svg"),
	5_000: preload("res://assets/ui/chips/chip_5k.svg"),
	10_000: preload("res://assets/ui/chips/chip_10k.svg"),
	50_000: preload("res://assets/ui/chips/chip_50k.svg"),
	100_000: preload("res://assets/ui/chips/chip_100k.svg"),
}

const SPIN_DURATION  := 1.5   # 릴 애니메이션 총 시간(초)
const SHUFFLE_EVERY  := 0.05  # 릴 심볼 셔플 간격(초) — 빠른 스크롤 느낌
const REEL_STOP_GAP  := 0.3   # 릴 순차 정지 간격(초)

# ── 상태 ───────────────────────────────────────────────────────
var _phase: int         = Phase.IDLE
var _active_stake: int  = 10_000
var _pad_navigation_active: bool = false
var _rng := RandomNumberGenerator.new()
var _slot_machine       # SlotMachine 인스턴스

var _rounds: int        = 0
var _net: int           = 0
var _last_results: Array = []   # 최근 5개 {win:bool, label:str, amount:int}

# 스핀 애니메이션
var _spin_timer: float  = 0.0
var _spin_elapsed: float = 0.0
var _shuffle_acc: float  = 0.0
var _pending_result: Dictionary = {}

# 순차 릴 정지 상태
var _reel_stopped: Array = [false, false, false]   # 각 릴 정지 여부
var _reel_scroll_idx: Array = [0, 0, 0]            # 각 릴의 현재 심볼 순환 인덱스
var _reel_current_symbols: Array = [0, 1, 0]       # 각 릴 중앙 페이라인 심볼

# ── UI 참조 ────────────────────────────────────────────────────
var _font: Font
var _font_bold: Font

var _reel_labels: Array   = []   # Array[Label] — 3개
var _reel_top_labels: Array = []
var _reel_bottom_labels: Array = []
var _reel_faces: Array = []
var _reel_panels: Array   = []   # Array[PanelContainer] — 3개
var _win_line_lbl: RichTextLabel
var _win_flash: ColorRect
var _spin_btn: Button
var _stake_btns: Array    = []   # Array[Button]
var _pad_hint_lbl: RichTextLabel
var _lamp_nodes: Array = []
var _cabinet_overlay: Control
var _history_row: HBoxContainer
var _balance_lbl: Label
var _session_lbl: Label
var _credit_meter_lbl: Label
var _bet_meter_lbl: Label
var _win_meter_lbl: Label
var _flash_lbl: Label
var _payout_tray_lbl: Label
var _last_win_amount: int = 0
var _payout_anim: float = 0.0
var _payout_coin_count: int = 0

# 슬롯 심볼 표시. 실제 릴 타일처럼 보이도록 이모지 대신 고정 텍스트와 색으로 렌더한다.
const _ALL_SYMBOLS: Array = [0, 1, 2, 3, 4]
const _SYMBOL_LABELS: Array = ["7", "BAR", "CHERRY", "BELL", "LEMON"]
const _SYMBOL_COLORS: Array = ["#ffd84d", "#d8dbe8", "#e85d5d", "#f0b429", "#75d97a"]

# ── 초기화 ─────────────────────────────────────────────────────
func _ready() -> void:
	_rng.randomize()
	_slot_machine = SLOT.new()
	_load_fonts()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 100
	_build_ui()
	visible = false
	set_process(false)

func _load_fonts() -> void:
	_font      = FontKit.ui_regular()
	_font_bold = FontKit.ui_bold()

func _f(node, bold: bool = false) -> void:
	if not node:
		return
	var ft = _font_bold if bold else _font
	if not ft:
		return
	node.add_theme_font_override("font", ft)
	if node is RichTextLabel:
		node.add_theme_font_override("normal_font", ft)
		node.add_theme_font_override("bold_font", _font_bold if _font_bold else ft)

func _tr(ko: String, en: String) -> String:
	return LocaleManager.ui(ko, en)

# ── 진입/종료 ─────────────────────────────────────────────────
func open() -> void:
	_rounds = 0
	_net = 0
	_last_win_amount = 0
	_payout_anim = 0.0
	_payout_coin_count = 0
	_last_results = []
	_phase = Phase.IDLE
	_pad_navigation_active = false
	visible = true
	TutorialOverlay.maybe_show("slot", self)
	set_process(false)
	_set_reel_symbols([0, 1, 0])
	_set_win_line("")
	_refresh_ui()
	_refresh_cabinet_lights()
	if is_instance_valid(_cabinet_overlay):
		_cabinet_overlay.queue_redraw()

func _on_exit() -> void:
	set_process(false)
	visible = false
	closed.emit()

func get_session_summary() -> Dictionary:
	return {
		"game_id": "slot",
		"rounds": _rounds,
		"net": _net,
	}

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey:
		var key := event as InputEventKey
		if key.echo:
			return

	var major_direction := ControllerHints.major_direction(event)
	var pad_navigation_event := (major_direction != 0 and _phase == Phase.IDLE) \
			or event.is_action_pressed("ui_accept") \
			or event.is_action_pressed("ui_cancel") \
			or ControllerHints.secondary_pressed(event) \
			or ControllerHints.details_pressed(event)
	if pad_navigation_event:
		_pad_navigation_active = true

	var handled := false
	if major_direction != 0:
		if _phase == Phase.IDLE:
			handled = _pad_cycle_stake(major_direction)
		else:
			handled = true
	elif event.is_action_pressed("gd_tab_prev") or event.is_action_pressed("gd_tab_next"):
		handled = true
	elif ControllerHints.secondary_pressed(event):
		handled = _pad_cycle_stake(1)
	elif event.is_action_pressed("ui_accept"):
		handled = _pad_spin()
	elif event.is_action_pressed("ui_cancel"):
		handled = _pad_exit()
	elif ControllerHints.details_pressed(event):
		handled = _pad_show_rules()

	if handled:
		get_viewport().set_input_as_handled()

func _pad_cycle_stake(direction: int) -> bool:
	if _phase != Phase.IDLE:
		return true
	var idx := STAKE_OPTIONS.find(_active_stake)
	if idx < 0:
		idx = 2
	var next_idx := clampi(idx + direction, 0, STAKE_OPTIONS.size() - 1)
	if next_idx == idx:
		return true
	_on_stake_select(int(STAKE_OPTIONS[next_idx]))
	_flash_msg(_tr("베팅 금액: %s", "Stake: %s") % GameState.format_money(float(_active_stake)), "#d8dbe8")
	return true

func _pad_spin() -> bool:
	if _phase == Phase.SPINNING:
		return true
	_start_spin()
	return true

func _pad_exit() -> bool:
	if _phase == Phase.SPINNING:
		return true
	_on_exit()
	return true

func _pad_show_rules() -> bool:
	if _phase == Phase.SPINNING:
		return true
	AudioManager.play_ui_open()
	TutorialOverlay.force_show("slot", self)
	return true

func _should_show_pad_cursor() -> bool:
	return _pad_navigation_active or ControllerHints.is_pad_active()

# ── 스핀 로직 ─────────────────────────────────────────────────
func _start_spin() -> void:
	if _phase != Phase.IDLE:
		return
	if GameState.money < _active_stake:
		_flash_msg(_tr("잔액 부족!", "Insufficient balance"), "#e74c3c")
		return

	# 베팅 즉시 차감
	GameState.add_money(-float(_active_stake))

	_phase = Phase.SPINNING
	_spin_elapsed = 0.0
	_spin_timer   = SPIN_DURATION
	_shuffle_acc  = 0.0
	_pending_result = _slot_machine.spin(_rng)

	# 릴 순차 정지 상태 초기화
	_reel_stopped = [false, false, false]
	_reel_scroll_idx = [0, 0, 0]

	set_process(true)
	_spin_btn.disabled = true
	_set_win_line("")
	_refresh_session_lbl()
	_refresh_balance_lbl()
	_refresh_cabinet_lights()
	if is_instance_valid(_cabinet_overlay):
		_cabinet_overlay.queue_redraw()

	AudioManager.play("slot_start")
	AudioManager.play_haptic(&"physical_reel_spin")

func _process(delta: float) -> void:
	if _phase != Phase.SPINNING:
		return

	_spin_elapsed += delta
	_shuffle_acc  += delta

	# 릴 심볼 스크롤 — SHUFFLE_EVERY마다 각 릴을 _ALL_SYMBOLS 순서대로 순환
	if _shuffle_acc >= SHUFFLE_EVERY:
		_shuffle_acc = 0.0
		var sz: int = _ALL_SYMBOLS.size()
		for i in range(3):
			if not _reel_stopped[i]:
				_reel_scroll_idx[i] = (_reel_scroll_idx[i] + 1) % sz
				_set_reel_symbol(i, int(_ALL_SYMBOLS[_reel_scroll_idx[i]]))
		_refresh_cabinet_lights()

	# 릴 1 정지: SPIN_DURATION - 0.6초
	var stop0_at: float = SPIN_DURATION - REEL_STOP_GAP * 2.0
	if not _reel_stopped[0] and _spin_elapsed >= stop0_at:
		_reel_stopped[0] = true
		var reels0: Array = _pending_result.get("reels", [4, 4, 4])
		_set_reel_symbol(0, int(reels0[0]))
		AudioManager.play_varied("slot_reel_stop", 0.0, 0.94, 0.98)
		_bump_reel(0)

	# 릴 2 정지: SPIN_DURATION - 0.3초
	var stop1_at: float = SPIN_DURATION - REEL_STOP_GAP
	if not _reel_stopped[1] and _spin_elapsed >= stop1_at:
		_reel_stopped[1] = true
		var reels1: Array = _pending_result.get("reels", [4, 4, 4])
		_set_reel_symbol(1, int(reels1[1]))
		AudioManager.play_varied("slot_reel_stop", 0.0, 0.99, 1.03)
		_bump_reel(1)

	# 릴 3 정지: SPIN_DURATION
	if not _reel_stopped[2] and _spin_elapsed >= _spin_timer:
		_reel_stopped[2] = true
		var reels2: Array = _pending_result.get("reels", [4, 4, 4])
		_set_reel_symbol(2, int(reels2[2]))
		AudioManager.play_varied("slot_reel_stop", 0.5, 1.04, 1.08)
		_bump_reel(2)
		set_process(false)
		_finish_spin()

func _finish_spin() -> void:
	_phase = Phase.RESULT

	var result: Dictionary = _pending_result
	var reels: Array = result.get("reels", [4, 4, 4])
	_set_reel_symbols(reels)

	var is_win: bool     = bool(result.get("is_win", false))
	var multiplier: float = float(result.get("multiplier", 0.0))
	var win_type: String = str(result.get("win_type", ""))

	var gain: int = 0
	if is_win and multiplier > 0.0:
		gain = int(float(_active_stake) * multiplier)
		GameState.add_money(float(gain))
	_last_win_amount = gain

	var net_round: int = gain - _active_stake
	_net += net_round
	_rounds += 1

	# 히스토리 저장 (최근 5개)
	var hist_label: String = win_type if win_type != "" else _tr("꽝", "Miss")
	_last_results.push_back({"win": is_win, "label": hist_label, "amount": net_round})
	if _last_results.size() > 5:
		_last_results.pop_front()

	# 도박 성향
	if is_win:
		GameState.modify_hidden_stat("gambling_tendency", 1)
	else:
		GameState.modify_hidden_stat("addiction_tendency", 1)

	# 로그
	var log_str: String
	if is_win:
		log_str = _tr("슬롯 %s +%s", "Slot %s +%s") % [win_type, GameState.format_money(float(gain))]
	else:
		log_str = _tr("슬롯 꽝 -%s", "Slot Miss -%s") % GameState.format_money(float(_active_stake))
	GameState.add_log(log_str, "money")
	GameState.stats_changed.emit()

	MetaProgression.record_minigame_play("slot")

	# 위 라인 표시 + 당첨 연출
	if is_win:
		if win_type.begins_with("777"):
			_set_win_line(_tr("[color=#ff0][b]JACKPOT 200배[/b][/color]", "[color=#ff0][b]JACKPOT 200x[/b][/color]"))
			_play_jackpot_celebration()
			_play_payout_tray(gain, multiplier)
			AudioManager.play_casino_result(float(net_round), float(_active_stake), true)
		elif multiplier >= 20.0:
			_set_win_line("[color=#f0b429][b]%s[/b][/color]" % win_type)
			_play_big_win_flash()
			_play_payout_tray(gain, multiplier)
			AudioManager.play_casino_result(float(net_round), float(_active_stake), true)
		else:
			_set_win_line("[color=#f0b429]%s[/color]" % win_type)
			_play_win_flash()
			_play_payout_tray(gain, multiplier)
			AudioManager.play_casino_result(float(net_round), float(_active_stake))
	else:
		_payout_coin_count = 0
		_payout_anim = 0.0
		# 니어미스 체크: 3개 심볼 중 2개가 같은 높은 가치 심볼이면 "아깝다!" 연출
		var syms: Array = result.get("reels", [])
		if syms.size() == 3:
			var near_miss := false
			if syms[0] == syms[1] and int(syms[0]) <= 2:   # 두 릴이 7, BAR, CHERRY
				near_miss = true
			elif syms[1] == syms[2] and int(syms[1]) <= 2:
				near_miss = true
			elif syms[0] == syms[2] and int(syms[0]) <= 2:
				near_miss = true
			if near_miss:
				_set_win_line(_tr("[color=#e88a30][b]아깝다! 한 끗 차이...[/b][/color]", "[color=#e88a30][b]So close... one symbol away[/b][/color]"))
				_flash_msg(_tr("아깝다!", "So close!"), "#e88a30")
				GameState.modify_hidden_stat("addiction_tendency", 1)
				_play_near_miss_shake()
				AudioManager.play_casino_result(float(net_round), float(_active_stake))
			else:
				_set_win_line(_tr("[color=#4a4a6a]— 꽝 —[/color]", "[color=#4a4a6a]— MISS —[/color]"))
				AudioManager.play_casino_result(float(net_round), float(_active_stake))
		else:
			_set_win_line(_tr("[color=#4a4a6a]— 꽝 —[/color]", "[color=#4a4a6a]— MISS —[/color]"))
			AudioManager.play_casino_result(float(net_round), float(_active_stake))

	_phase = Phase.IDLE
	_spin_btn.disabled = false
	_refresh_ui()
	_refresh_cabinet_lights()
	if is_instance_valid(_cabinet_overlay):
		_cabinet_overlay.queue_redraw()

# ── 애니메이션 헬퍼 ───────────────────────────────────────────
func _set_reel_symbols(symbols: Array) -> void:
	for i in range(mini(symbols.size(), _reel_labels.size())):
		_set_reel_symbol(i, int(symbols[i]))

func _set_reel_symbol(index: int, symbol: int) -> void:
	if index < 0 or index >= _reel_labels.size():
		return
	if not is_instance_valid(_reel_labels[index]):
		return
	var safe: int = clampi(symbol, 0, _SYMBOL_LABELS.size() - 1)
	if index < _reel_current_symbols.size():
		_reel_current_symbols[index] = safe
	var prev: int = (safe + _SYMBOL_LABELS.size() - 1) % _SYMBOL_LABELS.size()
	var next: int = (safe + 1) % _SYMBOL_LABELS.size()
	var spinning: bool = _phase == Phase.SPINNING and index < _reel_stopped.size() and not bool(_reel_stopped[index])
	_apply_symbol_to_label(_reel_labels[index], safe, true, spinning)
	if index < _reel_top_labels.size():
		_apply_symbol_to_label(_reel_top_labels[index], prev, false, spinning)
	if index < _reel_bottom_labels.size():
		_apply_symbol_to_label(_reel_bottom_labels[index], next, false, spinning)
	if index < _reel_faces.size() and is_instance_valid(_reel_faces[index]):
		_reel_faces[index].queue_redraw()
	if is_instance_valid(_cabinet_overlay):
		_cabinet_overlay.queue_redraw()

func _apply_symbol_to_label(lbl: Label, symbol: int, is_center: bool, spinning: bool) -> void:
	if not is_instance_valid(lbl):
		return
	var safe: int = clampi(symbol, 0, _SYMBOL_LABELS.size() - 1)
	var text: String = str(_SYMBOL_LABELS[safe])
	lbl.text = text
	var col := Color(str(_SYMBOL_COLORS[safe]))
	if not is_center:
		col.a = 0.34 if spinning else 0.22
	else:
		col.a = 0.90 if spinning else 1.0
	lbl.add_theme_color_override("font_color", col)
	var center_size := 54 if text.length() <= 3 else 30
	lbl.add_theme_font_size_override("font_size", center_size if is_center else 18)
	lbl.modulate = Color(1, 1, 1, 0.92 if is_center else 0.65)

func _set_win_line(bbtext: String) -> void:
	if is_instance_valid(_win_line_lbl):
		if bbtext.strip_edges().is_empty():
			_win_line_lbl.text = "[center][color=#64567a]PAYLINE[/color][/center]"
		else:
			_win_line_lbl.text = "[center]%s[/center]" % bbtext

func _play_win_flash() -> void:
	if not is_instance_valid(_win_flash):
		return
	_win_flash.color = Color(1.0, 0.85, 0.0, 0.3)
	_win_flash.modulate.a = 0.0
	_win_flash.visible = true
	var tw := create_tween()
	tw.tween_property(_win_flash, "modulate:a", 0.3, 0.18)
	tw.tween_property(_win_flash, "modulate:a", 0.0, 0.28)
	tw.tween_callback(func(): _win_flash.visible = false)

func _play_big_win_flash() -> void:
	if not is_instance_valid(_win_flash):
		return
	_win_flash.color = Color(1.0, 0.7, 0.0, 0.5)
	_win_flash.modulate.a = 0.0
	_win_flash.visible = true
	var tw := create_tween()
	tw.tween_property(_win_flash, "modulate:a", 0.6, 0.12)
	tw.tween_property(_win_flash, "modulate:a", 0.0, 0.2)
	tw.tween_property(_win_flash, "modulate:a", 0.5, 0.12)
	tw.tween_property(_win_flash, "modulate:a", 0.0, 0.25)
	tw.tween_callback(func(): _win_flash.visible = false)

func _play_jackpot_celebration() -> void:
	if not is_instance_valid(_win_flash):
		return
	# 강렬한 금색 배경 — 0.5초 ON, 0.5초 OFF, 3회 반복
	_win_flash.color = Color(1.0, 0.85, 0.0, 1.0)
	_win_flash.modulate.a = 0.0
	_win_flash.visible = true
	var tw := create_tween()
	for _i in range(3):
		tw.tween_property(_win_flash, "modulate:a", 0.85, 0.5)
		tw.tween_property(_win_flash, "modulate:a", 0.0,  0.5)
	tw.tween_callback(func(): _win_flash.visible = false)
	# 릴 패널 골드 테두리 강조
	for raw_panel in _reel_panels:
		var panel := raw_panel as PanelContainer
		if is_instance_valid(panel):
			var sty: StyleBoxFlat = panel.get_theme_stylebox("panel") as StyleBoxFlat
			if sty:
				sty.border_color = Color("#ffd700")
				sty.border_width_left   = 4
				sty.border_width_right  = 4
				sty.border_width_top    = 4
				sty.border_width_bottom = 4
				get_tree().create_timer(3.5).timeout.connect(func():
					if is_instance_valid(panel):
						sty.border_color = COLOR_BORDER
						sty.set_border_width_all(1))

func _play_payout_tray(amount: int, multiplier: float) -> void:
	if amount <= 0:
		return
	_payout_coin_count = clampi(int(ceil(multiplier * 0.7)) + 5, 7, 26)
	_payout_anim = 0.0
	_refresh_payout_tray_lbl()
	if is_instance_valid(_cabinet_overlay):
		_cabinet_overlay.queue_redraw()
	var tw := create_tween()
	tw.tween_method(_set_payout_anim, 0.0, 1.0, 0.58).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_interval(1.1)
	tw.tween_method(_set_payout_anim, 1.0, 0.35, 0.42).set_trans(Tween.TRANS_SINE)
	for i in range(mini(_payout_coin_count, 8)):
		get_tree().create_timer(0.08 + float(i) * 0.055).timeout.connect(func():
			if is_instance_valid(self):
				AudioManager.play("casino_coin", -5.0))

func _set_payout_anim(value: float) -> void:
	_payout_anim = value
	if is_instance_valid(_cabinet_overlay):
		_cabinet_overlay.queue_redraw()

func _play_near_miss_shake() -> void:
	if _reel_panels.is_empty():
		return
	# 결과 영역(릴 패널들의 부모 행)을 ±4px 좌우로 6번 흔들기
	# _reel_panels[0]의 부모 컨테이너(reel_row)를 직접 참조할 수 없으므로
	# 각 릴 패널을 개별적으로 흔든다
	for raw_panel in _reel_panels:
		var panel := raw_panel as PanelContainer
		if not is_instance_valid(panel):
			continue
		var origin: Vector2 = panel.position
		var tw: Tween = create_tween()
		tw.set_trans(Tween.TRANS_SINE)
		tw.set_ease(Tween.EASE_IN_OUT)
		for _i in range(3):
			tw.tween_property(panel, "position:x", origin.x + 4.0, 0.05)
			tw.tween_property(panel, "position:x", origin.x - 4.0, 0.05)
		tw.tween_property(panel, "position:x", origin.x, 0.05)

func _bump_reel(index: int) -> void:
	if index < 0 or index >= _reel_panels.size():
		return
	var panel := _reel_panels[index] as PanelContainer
	if not is_instance_valid(panel):
		return
	# The final reel resolves the wager in this same frame. Let that result own
	# the tactile beat instead of starting a stop pulse that is immediately replaced.
	if index < _reel_panels.size() - 1:
		AudioManager.play_haptic(&"physical_reel_stop")
	var base: Vector2 = panel.position
	var tw := create_tween()
	tw.tween_property(panel, "position:y", base.y + 5.0, 0.045)
	tw.tween_property(panel, "position:y", base.y - 2.0, 0.055)
	tw.tween_property(panel, "position:y", base.y, 0.055)

func _refresh_cabinet_lights() -> void:
	if _lamp_nodes.is_empty():
		return
	var active_idx := int(floor(_spin_elapsed * 18.0)) if _phase == Phase.SPINNING else -1
	for i in range(_lamp_nodes.size()):
		var lamp := _lamp_nodes[i] as Panel
		if not is_instance_valid(lamp):
			continue
		var hot := false
		if _phase == Phase.SPINNING:
			hot = (i + active_idx) % 4 != 1
		else:
			hot = i % 3 != 1
		var lamp_sty := StyleBoxFlat.new()
		lamp_sty.bg_color = Color("#ffd84d") if hot else Color("#3a2109")
		lamp_sty.border_color = Color("#fff0a8") if hot else Color("#6a4218")
		lamp_sty.set_border_width_all(1)
		lamp_sty.set_corner_radius_all(5)
		lamp.add_theme_stylebox_override("panel", lamp_sty)

func _fade(hex: String, alpha: float) -> Color:
	var c := Color(hex)
	c.a *= alpha
	return c

func _draw_reel_face(face: Control) -> void:
	var sz := face.size
	if sz.x <= 2.0 or sz.y <= 2.0:
		return
	var reel_idx: int = int(face.get_meta("reel_index", 0))
	var safe: int = 0
	if reel_idx >= 0 and reel_idx < _reel_current_symbols.size():
		safe = clampi(int(_reel_current_symbols[reel_idx]), 0, _SYMBOL_LABELS.size() - 1)
	var spinning: bool = _phase == Phase.SPINNING and reel_idx < _reel_stopped.size() and not bool(_reel_stopped[reel_idx])
	var tile_h: float = sz.y * 0.40
	var strip_offset: float = 0.0
	if spinning:
		strip_offset = fmod(_spin_elapsed * (260.0 + float(reel_idx) * 58.0), tile_h) - tile_h * 0.5

	face.draw_rect(Rect2(Vector2.ZERO, sz), Color("#101015"), true)
	face.draw_rect(Rect2(Vector2(7, 4), Vector2(sz.x - 14, sz.y - 8)), Color("#efe7d3"), true)
	face.draw_rect(Rect2(Vector2(7, 4), Vector2(sz.x - 14, sz.y - 8)), Color("#a89a76"), false, 2.0)
	for x in [sz.x * 0.18, sz.x * 0.50, sz.x * 0.82]:
		face.draw_line(Vector2(x, 8), Vector2(x, sz.y - 8), Color(0, 0, 0, 0.06), 1.0)

	for step in range(-3, 4):
		var symbol_idx: int = (safe + step + _SYMBOL_LABELS.size()) % _SYMBOL_LABELS.size()
		var y: float = sz.y * 0.5 - tile_h * 0.5 + float(step) * tile_h + strip_offset
		var tile := Rect2(Vector2(12, y), Vector2(sz.x - 24, tile_h - 4.0))
		if tile.end.y < 0.0 or tile.position.y > sz.y:
			continue
		var dist: float = abs((tile.position.y + tile.size.y * 0.5) - sz.y * 0.5)
		var is_center: bool = dist < tile_h * 0.48
		var alpha: float = 1.0 if is_center else 0.36
		if spinning:
			alpha = 0.72 if is_center else 0.24
		_draw_reel_symbol_tile(face, tile, symbol_idx, alpha, is_center)

	if spinning:
		for i in range(6):
			var yy: float = fmod(_spin_elapsed * 420.0 + float(i) * 23.0, sz.y)
			face.draw_line(Vector2(12, yy), Vector2(sz.x - 12, yy + 5.0), Color(1, 1, 1, 0.08), 2.0)

	face.draw_rect(Rect2(Vector2(8, 0), Vector2(sz.x - 16, sz.y * 0.20)), Color(0, 0, 0, 0.24), true)
	face.draw_rect(Rect2(Vector2(8, sz.y * 0.80), Vector2(sz.x - 16, sz.y * 0.20)), Color(0, 0, 0, 0.30), true)
	face.draw_rect(Rect2(Vector2(8, sz.y * 0.34), Vector2(sz.x - 16, sz.y * 0.32)), Color(1, 1, 1, 0.12), true)
	face.draw_line(Vector2(4, sz.y * 0.50), Vector2(sz.x - 4, sz.y * 0.50), _fade("#d83f3f", 0.62), 1.5)
	face.draw_line(Vector2(4, sz.y * 0.50 - 7), Vector2(sz.x - 4, sz.y * 0.50 - 7), _fade("#d83f3f", 0.16), 1.0)
	face.draw_line(Vector2(4, sz.y * 0.50 + 7), Vector2(sz.x - 4, sz.y * 0.50 + 7), _fade("#d83f3f", 0.16), 1.0)
	face.draw_line(Vector2(2, 0), Vector2(2, sz.y), Color(0, 0, 0, 0.28), 2.0)
	face.draw_line(Vector2(sz.x - 2, 0), Vector2(sz.x - 2, sz.y), Color(0, 0, 0, 0.28), 2.0)

func _draw_reel_symbol_tile(ctrl: Control, rect: Rect2, symbol: int, alpha: float, is_center: bool) -> void:
	var tile_bg := Color("#f9f1d8")
	tile_bg.a = alpha
	ctrl.draw_rect(rect, tile_bg, true)
	ctrl.draw_rect(rect, Color(0, 0, 0, 0.12 * alpha), false, 1.0)
	var inset := Rect2(rect.position + Vector2(5, 4), rect.size - Vector2(10, 8))
	if is_center:
		ctrl.draw_rect(inset, Color(1, 1, 1, 0.16), false, 2.0)
	_draw_slot_symbol(ctrl, inset, symbol, alpha, is_center)

func _draw_slot_symbol(ctrl: Control, rect: Rect2, symbol: int, alpha: float, is_center: bool) -> void:
	var font: Font = _font_bold if _font_bold else _font
	var center := rect.position + rect.size * 0.5
	var size_big: int = 50 if is_center else 22
	var size_mid: int = 34 if is_center else 16
	match symbol:
		0:
			var col := Color("#ffd84d")
			col.a = alpha
			ctrl.draw_string(font, Vector2(rect.position.x, rect.position.y + rect.size.y * 0.74), "7",
				HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, size_big, col)
			ctrl.draw_string(font, Vector2(rect.position.x + 2, rect.position.y + rect.size.y * 0.74 + 2), "7",
				HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, size_big, Color(0, 0, 0, 0.16 * alpha))
		1:
			var bar_rect := Rect2(rect.position + Vector2(rect.size.x * 0.16, rect.size.y * 0.25), Vector2(rect.size.x * 0.68, rect.size.y * 0.46))
			ctrl.draw_rect(bar_rect, Color(0.03, 0.03, 0.04, 0.88 * alpha), true)
			ctrl.draw_rect(bar_rect, _fade("#d8dbe8", 0.76 * alpha), false, 1.5)
			ctrl.draw_string(font, Vector2(bar_rect.position.x, bar_rect.position.y + bar_rect.size.y * 0.70), "BAR",
				HORIZONTAL_ALIGNMENT_CENTER, bar_rect.size.x, size_mid, _fade("#d8dbe8", alpha))
		2:
			var red := Color("#e85d5d")
			red.a = alpha
			var green := Color("#75d97a")
			green.a = alpha
			var fruit_r: float = 15.0 if is_center else 6.0
			ctrl.draw_line(center + Vector2(-7, -9), center + Vector2(4, -26 if is_center else -13), green, 2.0)
			ctrl.draw_line(center + Vector2(7, -9), center + Vector2(4, -26 if is_center else -13), green, 2.0)
			ctrl.draw_circle(center + Vector2(-10, 6), fruit_r, red)
			ctrl.draw_circle(center + Vector2(10, 6), fruit_r, red)
			ctrl.draw_circle(center + Vector2(-14, 0), 4.0 if is_center else 1.8, Color(1, 1, 1, 0.22 * alpha))
		3:
			var gold := Color("#f0b429")
			gold.a = alpha
			var dark := Color("#72520d")
			dark.a = alpha
			var bell_pts := PackedVector2Array([
				center + Vector2(-24, 16),
				center + Vector2(24, 16),
				center + Vector2(17, -11),
				center + Vector2(8, -24),
				center + Vector2(-8, -24),
				center + Vector2(-17, -11),
			])
			if not is_center:
				bell_pts = PackedVector2Array([
					center + Vector2(-10, 7),
					center + Vector2(10, 7),
					center + Vector2(7, -5),
					center + Vector2(3, -10),
					center + Vector2(-3, -10),
					center + Vector2(-7, -5),
				])
			ctrl.draw_polygon(bell_pts, PackedColorArray([gold]))
			ctrl.draw_circle(center + Vector2(0, 18 if is_center else 8), 5.0 if is_center else 2.2, dark)
			ctrl.draw_line(center + Vector2(-16, 15), center + Vector2(16, 15), _fade("#fff0a8", 0.38 * alpha), 1.0)
		_:
			var lemon := Color("#d8e853")
			lemon.a = alpha
			var lemon_dark := Color("#6b7d1f")
			lemon_dark.a = alpha
			var w: float = 82.0 if is_center else 30.0
			var h: float = 34.0 if is_center else 14.0
			var body := Rect2(center - Vector2(w * 0.5, h * 0.5), Vector2(w, h))
			ctrl.draw_rect(body, lemon, true)
			ctrl.draw_circle(body.position + Vector2(0, h * 0.5), h * 0.5, lemon)
			ctrl.draw_circle(body.position + Vector2(w, h * 0.5), h * 0.5, lemon)
			ctrl.draw_rect(body, Color(1, 1, 1, 0.18 * alpha), false, 1.0)
			ctrl.draw_line(center + Vector2(-w * 0.34, -h * 0.10), center + Vector2(w * 0.34, -h * 0.10), lemon_dark, 1.3)
			ctrl.draw_line(center + Vector2(-w * 0.25, h * 0.13), center + Vector2(w * 0.25, h * 0.13), Color(1, 1, 1, 0.24 * alpha), 1.0)
			ctrl.draw_string(font, Vector2(body.position.x, body.position.y + h * 0.68), "LEMON",
				HORIZONTAL_ALIGNMENT_CENTER, body.size.x, 12 if is_center else 6, lemon_dark)

func _draw_cabinet_overlay(ctrl: Control) -> void:
	var sz := ctrl.size
	if sz.x <= 8.0 or sz.y <= 8.0:
		return
	var side_col := Color("#48103b")
	var chrome := Color(0.84, 0.76, 0.55, 0.55)
	ctrl.draw_rect(Rect2(Vector2(8, 30), Vector2(14, sz.y - 64)), side_col.darkened(0.2), true)
	ctrl.draw_rect(Rect2(Vector2(sz.x - 22, 30), Vector2(14, sz.y - 64)), side_col.darkened(0.2), true)
	ctrl.draw_line(Vector2(22, 44), Vector2(22, sz.y - 52), chrome, 2.0)
	ctrl.draw_line(Vector2(sz.x - 22, 44), Vector2(sz.x - 22, sz.y - 52), chrome, 2.0)
	for p in [Vector2(28, 44), Vector2(sz.x - 28, 44), Vector2(28, sz.y - 56), Vector2(sz.x - 28, sz.y - 56)]:
		ctrl.draw_circle(p, 4.0, Color("#d8dbe8"))
		ctrl.draw_circle(p, 1.8, Color("#2a2e38"))

	var lever_base := Vector2(sz.x - 10.0, sz.y * 0.42)
	var pulled := _phase == Phase.SPINNING
	var handle := lever_base + (Vector2(54, 42) if pulled else Vector2(48, -36))
	ctrl.draw_circle(lever_base, 17.0, Color("#11121a"))
	ctrl.draw_circle(lever_base, 11.0, Color("#d0c6a0"))
	ctrl.draw_line(lever_base, handle, Color("#d0c6a0"), 8.0)
	ctrl.draw_line(lever_base, handle, Color(1, 1, 1, 0.24), 2.0)
	ctrl.draw_circle(handle, 18.0, Color("#d83f3f") if pulled else Color("#f0b429"))
	ctrl.draw_circle(handle + Vector2(-5, -6), 5.5, Color(1, 1, 1, 0.32))

	var tray_rect := Rect2(Vector2(78, sz.y - 34), Vector2(sz.x - 156, 18))
	ctrl.draw_rect(tray_rect, Color("#050609"), true)
	ctrl.draw_rect(tray_rect, Color("#3a4250"), false, 2.0)
	if _payout_anim > 0.01 and _payout_coin_count > 0:
		for i in range(_payout_coin_count):
			var delay: float = float(i) * 0.028
			var t: float = clampf((_payout_anim - delay) * 1.24, 0.0, 1.0)
			if t <= 0.0:
				continue
			var end := Vector2(
				tray_rect.position.x + 32.0 + fmod(float(i) * 37.0, tray_rect.size.x - 64.0),
				tray_rect.position.y + 9.0 + sin(float(i) * 0.74) * 3.0
			)
			var p := end + Vector2(sin(float(i) * 0.81) * (1.0 - t) * 18.0, -6.0 * (1.0 - t))
			var alpha: float = clampf(0.22 + t, 0.0, 1.0)
			var r: float = lerpf(3.0, 7.0, t)
			ctrl.draw_circle(p + Vector2(0, 2), r, Color(0, 0, 0, 0.28 * alpha))
			ctrl.draw_circle(p, r, _fade("#f0b429", alpha))
			ctrl.draw_circle(p, r * 0.45, _fade("#68480d", alpha))
	if _last_win_amount > 0:
		for i in range(8):
			var px := tray_rect.position.x + 42.0 + float(i) * 34.0
			var py := tray_rect.position.y + 9.0 + sin(float(i)) * 2.0
			ctrl.draw_circle(Vector2(px, py), 8.0, Color("#f0b429"))
			ctrl.draw_circle(Vector2(px, py), 4.0, Color("#604414"))

# ── UI 빌드 ───────────────────────────────────────────────────
func _build_ui() -> void:
	# ── 배경 오버레이
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#05040a")
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	const _BG_PATH := "res://assets/backgrounds/casino_interior.png"
	if ResourceLoader.exists(_BG_PATH):
		var bg_img := TextureRect.new()
		bg_img.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg_img.texture = load(_BG_PATH) as Texture2D
		bg_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg_img.stretch_mode = TextureRect.STRETCH_SCALE
		bg_img.modulate = Color(1, 1, 1, 0.35)
		bg_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(bg_img)

	var floor_veil := ColorRect.new()
	floor_veil.set_anchors_preset(Control.PRESET_FULL_RECT)
	floor_veil.color = Color(0.02, 0.01, 0.035, 0.58)
	floor_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(floor_veil)

	# ── 중앙 슬롯머신 캐비닛
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var center_wrap := CenterContainer.new()
	center_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_wrap.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	scroll.add_child(center_wrap)

	var main_box := VBoxContainer.new()
	main_box.custom_minimum_size = Vector2(700, 0)
	main_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	main_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	main_box.add_theme_constant_override("separation", 10)
	center_wrap.add_child(main_box)

	var cabinet := PanelContainer.new()
	cabinet.custom_minimum_size = Vector2(760, 0)
	cabinet.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cabinet.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var cabinet_sty := StyleBoxFlat.new()
	cabinet_sty.bg_color = Color("#22061d")
	cabinet_sty.border_color = Color("#c9a227")
	cabinet_sty.set_border_width_all(5)
	cabinet_sty.set_corner_radius_all(30)
	cabinet_sty.content_margin_left = 0
	cabinet_sty.content_margin_right = 0
	cabinet_sty.content_margin_top = 0
	cabinet_sty.content_margin_bottom = 0
	cabinet_sty.shadow_color = Color(0, 0, 0, 0.55)
	cabinet_sty.shadow_size = 24
	cabinet_sty.shadow_offset = Vector2(0, 10)
	cabinet.add_theme_stylebox_override("panel", cabinet_sty)
	main_box.add_child(cabinet)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   24)
	margin.add_theme_constant_override("margin_right",  24)
	margin.add_theme_constant_override("margin_top",    8)
	margin.add_theme_constant_override("margin_bottom", 10)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cabinet.add_child(margin)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 7)
	margin.add_child(inner)

	_cabinet_overlay = Control.new()
	_cabinet_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cabinet_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cabinet_overlay.z_index = 20
	_cabinet_overlay.draw.connect(func(): _draw_cabinet_overlay(_cabinet_overlay))
	cabinet.add_child(_cabinet_overlay)

	var lamp_row := HBoxContainer.new()
	lamp_row.alignment = BoxContainer.ALIGNMENT_CENTER
	lamp_row.add_theme_constant_override("separation", 8)
	inner.add_child(lamp_row)
	_lamp_nodes = []
	for i in range(15):
		var lamp := Panel.new()
		lamp.custom_minimum_size = Vector2(16, 7)
		lamp_row.add_child(lamp)
		_lamp_nodes.append(lamp)
	_refresh_cabinet_lights()

	var marquee := PanelContainer.new()
	var marquee_sty := StyleBoxFlat.new()
	marquee_sty.bg_color = Color("#310817")
	marquee_sty.border_color = Color("#f0b429")
	marquee_sty.set_border_width_all(3)
	marquee_sty.set_corner_radius_all(18)
	marquee_sty.content_margin_left = 18
	marquee_sty.content_margin_right = 18
	marquee_sty.content_margin_top = 6
	marquee_sty.content_margin_bottom = 6
	marquee.add_theme_stylebox_override("panel", marquee_sty)
	inner.add_child(marquee)

	var marquee_vb := VBoxContainer.new()
	marquee_vb.add_theme_constant_override("separation", 2)
	marquee.add_child(marquee_vb)

	var marquee_lbl := Label.new()
	marquee_lbl.text = "LUCKY 7"
	marquee_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	marquee_lbl.add_theme_font_size_override("font_size", 28)
	marquee_lbl.add_theme_color_override("font_color", Color("#ffd84d"))
	_f(marquee_lbl, true)
	marquee_vb.add_child(marquee_lbl)

	var subtitle_lbl := Label.new()
	subtitle_lbl.text = "JEONGSEON SLOT MACHINE"
	subtitle_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_lbl.add_theme_font_size_override("font_size", 9)
	subtitle_lbl.add_theme_color_override("font_color", Color("#d58a45"))
	_f(subtitle_lbl)
	marquee_vb.add_child(subtitle_lbl)

	var meter_panel := PanelContainer.new()
	var meter_sty := StyleBoxFlat.new()
	meter_sty.bg_color = Color("#060a0f")
	meter_sty.border_color = Color("#5d4b24")
	meter_sty.set_border_width_all(2)
	meter_sty.set_corner_radius_all(10)
	meter_sty.content_margin_left = 12
	meter_sty.content_margin_right = 12
	meter_sty.content_margin_top = 5
	meter_sty.content_margin_bottom = 5
	meter_panel.add_theme_stylebox_override("panel", meter_sty)
	inner.add_child(meter_panel)
	var meter_row := HBoxContainer.new()
	meter_row.add_theme_constant_override("separation", 10)
	meter_panel.add_child(meter_row)
	_credit_meter_lbl = _make_meter_label("CREDIT", "0")
	_bet_meter_lbl = _make_meter_label("BET", "0")
	_win_meter_lbl = _make_meter_label("WIN", "0")
	meter_row.add_child(_credit_meter_lbl)
	meter_row.add_child(_bet_meter_lbl)
	meter_row.add_child(_win_meter_lbl)

	# ── 헤더 ──────────────────────────────────────────────────
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	inner.add_child(header)

	var title_lbl := Label.new()
	title_lbl.text = _tr("정선 슬롯", "Jeongseon Slots")
	title_lbl.add_theme_font_size_override("font_size", 16)
	title_lbl.add_theme_color_override("font_color", COLOR_GOLD)
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_f(title_lbl, true)
	header.add_child(title_lbl)

	_session_lbl = Label.new()
	_session_lbl.add_theme_font_size_override("font_size", 12)
	_session_lbl.add_theme_color_override("font_color", Color("#7a8a9a"))
	_session_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_f(_session_lbl)
	header.add_child(_session_lbl)

	var help_btn := _make_btn(_tr("규칙", "Rules"), func(): TutorialOverlay.force_show("slot", self), "#0a0a1a", "#5a4510")
	help_btn.custom_minimum_size = Vector2(58, 26)
	header.add_child(help_btn)

	var exit_btn := _make_btn(_tr("나가기", "Exit"), _on_exit, "#1a0e0e", "#5a2a2a")
	exit_btn.custom_minimum_size = Vector2(80, 26)
	header.add_child(exit_btn)

	var paytable := GridContainer.new()
	paytable.columns = 5
	paytable.add_theme_constant_override("h_separation", 6)
	paytable.add_theme_constant_override("v_separation", 4)
	inner.add_child(paytable)
	_add_paytable_cell(paytable, "777", _tr("200배", "200x"), "#ffd84d")
	_add_paytable_cell(paytable, "BAR", _tr("50배", "50x"), "#d8dbe8")
	_add_paytable_cell(paytable, "CHERRY", _tr("20배", "20x"), "#e85d5d")
	_add_paytable_cell(paytable, "BELL", _tr("15배", "15x"), "#f0b429")
	_add_paytable_cell(paytable, "CHERRY x1", _tr("1.5배", "1.5x"), "#75d97a")

	# ── 릴 디스플레이 ─────────────────────────────────────────
	var reel_window := PanelContainer.new()
	reel_window.custom_minimum_size = Vector2(0, 148)
	reel_window.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var reel_window_sty := StyleBoxFlat.new()
	reel_window_sty.bg_color = Color("#030509")
	reel_window_sty.border_color = Color("#b9902f")
	reel_window_sty.set_border_width_all(4)
	reel_window_sty.set_corner_radius_all(18)
	reel_window_sty.content_margin_left = 16
	reel_window_sty.content_margin_right = 16
	reel_window_sty.content_margin_top = 12
	reel_window_sty.content_margin_bottom = 12
	reel_window.add_theme_stylebox_override("panel", reel_window_sty)
	inner.add_child(reel_window)

	var reel_row := HBoxContainer.new()
	reel_row.add_theme_constant_override("separation", 12)
	reel_row.alignment = BoxContainer.ALIGNMENT_CENTER
	reel_window.add_child(reel_row)

	_reel_labels = []
	_reel_top_labels = []
	_reel_bottom_labels = []
	_reel_faces = []
	_reel_panels = []

	for i in range(3):
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(188, 124)
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var sty := StyleBoxFlat.new()
		sty.bg_color = Color("#08060c")
		sty.border_color = Color("#24142f")
		sty.set_border_width_all(5)
		sty.set_corner_radius_all(12)
		sty.shadow_color = Color(0, 0, 0, 0.35)
		sty.shadow_size = 8
		sty.shadow_offset = Vector2(0, 3)
		sty.content_margin_left = 7
		sty.content_margin_right = 7
		sty.content_margin_top = 7
		sty.content_margin_bottom = 7
		panel.add_theme_stylebox_override("panel", sty)
		reel_row.add_child(panel)
		_reel_panels.append(panel)

		var face := Control.new()
		face.custom_minimum_size = Vector2(176, 110)
		face.clip_contents = true
		face.set_meta("reel_index", i)
		face.draw.connect(func(): _draw_reel_face(face))
		panel.add_child(face)
		_reel_faces.append(face)

		var top_lbl := Label.new()
		top_lbl.visible = false
		top_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		top_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		top_lbl.anchor_left = 0.0
		top_lbl.anchor_top = 0.02
		top_lbl.anchor_right = 1.0
		top_lbl.anchor_bottom = 0.28
		_f(top_lbl, true)
		face.add_child(top_lbl)
		_reel_top_labels.append(top_lbl)

		var reel_lbl := Label.new()
		reel_lbl.visible = false
		reel_lbl.text = "7"
		reel_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		reel_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		reel_lbl.anchor_left = 0.0
		reel_lbl.anchor_top = 0.26
		reel_lbl.anchor_right = 1.0
		reel_lbl.anchor_bottom = 0.74
		reel_lbl.add_theme_font_size_override("font_size", 54)
		reel_lbl.add_theme_color_override("font_color", Color("#ffd84d"))
		_f(reel_lbl, true)
		face.add_child(reel_lbl)
		_reel_labels.append(reel_lbl)

		var bottom_lbl := Label.new()
		bottom_lbl.visible = false
		bottom_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		bottom_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		bottom_lbl.anchor_left = 0.0
		bottom_lbl.anchor_top = 0.72
		bottom_lbl.anchor_right = 1.0
		bottom_lbl.anchor_bottom = 0.98
		_f(bottom_lbl, true)
		face.add_child(bottom_lbl)
		_reel_bottom_labels.append(bottom_lbl)

	var payline_bar := Panel.new()
	payline_bar.custom_minimum_size = Vector2(0, 4)
	var payline_sty := StyleBoxFlat.new()
	payline_sty.bg_color = Color("#d83f3f")
	payline_sty.set_corner_radius_all(2)
	payline_bar.add_theme_stylebox_override("panel", payline_sty)
	inner.add_child(payline_bar)

	# 당첨 플래시 오버레이 (릴 위에 겹침)
	_win_flash = ColorRect.new()
	_win_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_win_flash.color = Color(1.0, 0.85, 0.0, 0.3)
	_win_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_win_flash.visible = false
	# reel_row에 자식으로 추가하되 레이아웃 무시하도록 CanvasItem 방식 대신
	# 부모를 inner로 해서 씬 위에 올림 — 단순하게 inner에 붙이고 reel_row 크기 추종
	# 실용적으로는 full_rect로 전체 오버레이에 살짝 띄움
	add_child(_win_flash)

	# ── 당첨 라인 ──────────────────────────────────────────────
	_win_line_lbl = RichTextLabel.new()
	_win_line_lbl.bbcode_enabled  = true
	_win_line_lbl.fit_content     = true
	_win_line_lbl.scroll_active   = false
	_win_line_lbl.custom_minimum_size = Vector2(320, 30)
	_win_line_lbl.add_theme_font_size_override("normal_font_size", 14)
	_win_line_lbl.add_theme_color_override("default_color", Color("#5a5a7a"))
	_f(_win_line_lbl, true)
	# 중앙 정렬 wrapper
	var wl_center := CenterContainer.new()
	wl_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wl_center.add_child(_win_line_lbl)
	inner.add_child(wl_center)

	var control_deck := PanelContainer.new()
	var deck_sty := StyleBoxFlat.new()
	deck_sty.bg_color = Color("#11121a")
	deck_sty.border_color = Color("#4a3f25")
	deck_sty.set_border_width_all(2)
	deck_sty.set_corner_radius_all(18)
	deck_sty.content_margin_left = 14
	deck_sty.content_margin_right = 14
	deck_sty.content_margin_top = 8
	deck_sty.content_margin_bottom = 8
	control_deck.add_theme_stylebox_override("panel", deck_sty)
	inner.add_child(control_deck)

	var deck_inner := VBoxContainer.new()
	deck_inner.add_theme_constant_override("separation", 6)
	control_deck.add_child(deck_inner)

	# ── 베팅 단위 선택 ─────────────────────────────────────────
	var stake_header := Label.new()
	stake_header.text = _tr("베팅 금액", "Stake")
	stake_header.add_theme_font_size_override("font_size", 10)
	stake_header.add_theme_color_override("font_color", Color("#6a7a8a"))
	_f(stake_header)
	deck_inner.add_child(stake_header)

	var stake_row := HBoxContainer.new()
	stake_row.add_theme_constant_override("separation", 6)
	deck_inner.add_child(stake_row)
	_stake_btns = []

	for s in STAKE_OPTIONS:
		var captured_s: int = int(s)
		var is_sel: bool = (s == _active_stake)
		var sb := _make_btn(
			GameState.format_money(float(s)),
			func(): _on_stake_select(captured_s),
			"#1a2a3a" if is_sel else "#0e0e1a",
			"#c9a227" if is_sel else "#2a2a3a"
		)
		_apply_chip_icon(sb, captured_s, 18)
		sb.custom_minimum_size = Vector2(0, 28)
		sb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_stake_btns.append(sb)
		stake_row.add_child(sb)

	# ── MAX BET 버튼 (최대 베팅 바로 선택) ───────────────────────
	var physical_row := HBoxContainer.new()
	physical_row.add_theme_constant_override("separation", 10)
	deck_inner.add_child(physical_row)
	var max_bet_btn := _make_btn("MAX BET", func(): _on_stake_select(STAKE_OPTIONS[-1]), "#2a1a00", "#f39c12")
	max_bet_btn.custom_minimum_size = Vector2(0, 38)
	max_bet_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	max_bet_btn.add_theme_font_size_override("font_size", 12)
	_f(max_bet_btn, true)
	physical_row.add_child(max_bet_btn)

	var bet_one_btn := _make_btn("BET ONE", func():
		var idx := STAKE_OPTIONS.find(_active_stake)
		_on_stake_select(int(STAKE_OPTIONS[(idx + 1) % STAKE_OPTIONS.size()]))
	, "#182638", "#3c8fd9")
	bet_one_btn.custom_minimum_size = Vector2(0, 38)
	bet_one_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bet_one_btn.add_theme_font_size_override("font_size", 12)
	physical_row.add_child(bet_one_btn)

	_spin_btn = _make_btn("SPIN", _start_spin, "#0d2a15", "#2ecc71")
	_spin_btn.custom_minimum_size = Vector2(0, 38)
	_spin_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_spin_btn.add_theme_font_size_override("font_size", 16)
	_f(_spin_btn, true)
	# 초록 강조
	var spin_sty := StyleBoxFlat.new()
	spin_sty.bg_color = Color("#0d2a15")
	spin_sty.border_color = COLOR_GREEN
	spin_sty.set_border_width_all(2)
	spin_sty.set_corner_radius_all(10)
	spin_sty.content_margin_top    = 12
	spin_sty.content_margin_bottom = 12
	var spin_hov := spin_sty.duplicate()
	spin_hov.bg_color = Color("#143d1e")
	var spin_dis := spin_sty.duplicate()
	spin_dis.bg_color     = Color("#0a0a12")
	spin_dis.border_color = Color("#1a1a22")
	var spin_foc := spin_sty.duplicate()
	spin_foc.border_color = COLOR_GOLD
	spin_foc.set_border_width_all(2)
	_spin_btn.add_theme_stylebox_override("normal",   spin_sty)
	_spin_btn.add_theme_stylebox_override("hover",    spin_hov)
	_spin_btn.add_theme_stylebox_override("pressed",  spin_hov)
	_spin_btn.add_theme_stylebox_override("disabled", spin_dis)
	_spin_btn.add_theme_stylebox_override("focus",    spin_foc)
	_spin_btn.add_theme_color_override("font_color", COLOR_GREEN)
	_spin_btn.add_theme_color_override("font_disabled_color", Color("#2a3a2a"))
	physical_row.add_child(_spin_btn)

	_pad_hint_lbl = RichTextLabel.new()
	_pad_hint_lbl.bbcode_enabled = true
	_pad_hint_lbl.fit_content = true
	_pad_hint_lbl.scroll_active = false
	_pad_hint_lbl.visible = false
	_pad_hint_lbl.custom_minimum_size = Vector2(0, 18)
	_pad_hint_lbl.add_theme_font_size_override("normal_font_size", 11)
	_pad_hint_lbl.add_theme_color_override("default_color", Color("#aeb6ca"))
	_f(_pad_hint_lbl, true)
	deck_inner.add_child(_pad_hint_lbl)

	deck_inner.add_child(_sep())

	# ── 히스토리 (최근 5판) ────────────────────────────────────
	var hist_header := Label.new()
	hist_header.text = _tr("최근 결과", "Recent Results")
	hist_header.add_theme_font_size_override("font_size", 9)
	hist_header.add_theme_color_override("font_color", Color("#4a5a6a"))
	_f(hist_header)
	deck_inner.add_child(hist_header)

	_history_row = HBoxContainer.new()
	_history_row.add_theme_constant_override("separation", 6)
	deck_inner.add_child(_history_row)

	deck_inner.add_child(_sep())

	# ── 잔액 표시 ──────────────────────────────────────────────
	_balance_lbl = Label.new()
	_balance_lbl.add_theme_font_size_override("font_size", 12)
	_balance_lbl.add_theme_color_override("font_color", Color("#c0cce0"))
	_balance_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_f(_balance_lbl, true)
	deck_inner.add_child(_balance_lbl)

	var tray := PanelContainer.new()
	tray.z_index = 25
	var tray_sty := StyleBoxFlat.new()
	tray_sty.bg_color = Color("#050609")
	tray_sty.border_color = Color("#242a34")
	tray_sty.set_border_width_all(2)
	tray_sty.set_corner_radius_all(10)
	tray_sty.content_margin_top = 4
	tray_sty.content_margin_bottom = 4
	tray.add_theme_stylebox_override("panel", tray_sty)
	inner.add_child(tray)
	var tray_lbl := Label.new()
	tray_lbl.text = "PAYOUT TRAY"
	tray_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tray_lbl.add_theme_font_size_override("font_size", 11)
	tray_lbl.add_theme_color_override("font_color", Color("#596270"))
	_f(tray_lbl, true)
	tray.add_child(tray_lbl)
	_payout_tray_lbl = tray_lbl

	# ── 플래시 메시지 ───────────────────────────────────────────
	_flash_lbl = Label.new()
	_flash_lbl.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_flash_lbl.offset_top    = -40
	_flash_lbl.offset_bottom = -10
	_flash_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_flash_lbl.add_theme_font_size_override("font_size", 15)
	_flash_lbl.visible = false
	_f(_flash_lbl, true)
	add_child(_flash_lbl)

	_refresh_ui()

# ── UI 갱신 ───────────────────────────────────────────────────
func _refresh_ui() -> void:
	_refresh_session_lbl()
	_refresh_meters()
	_refresh_stake_btns()
	_refresh_history()
	_refresh_balance_lbl()
	_refresh_payout_tray_lbl()
	_refresh_pad_hint()
	_refresh_spin_button_surface()

func _refresh_session_lbl() -> void:
	if not is_instance_valid(_session_lbl):
		return
	var net_str: String
	if _net >= 0:
		net_str = "+%s" % GameState.format_money(float(_net))
	else:
		net_str = GameState.format_money(float(_net))
	_session_lbl.text = _tr("%d판  |  수익: %s", "%d spins  |  Profit: %s") % [_rounds, net_str]
	if _net > 0:
		_session_lbl.add_theme_color_override("font_color", Color("#3de87a"))
	elif _net < 0:
		_session_lbl.add_theme_color_override("font_color", Color("#e85d5d"))
	else:
		_session_lbl.add_theme_color_override("font_color", Color("#7a8a9a"))

func _refresh_balance_lbl() -> void:
	if not is_instance_valid(_balance_lbl):
		return
	_balance_lbl.text = _tr("현재 잔액  %s", "Current balance  %s") % GameState.format_money(GameState.money)

func _refresh_meters() -> void:
	if is_instance_valid(_credit_meter_lbl):
		_credit_meter_lbl.text = "CREDIT\n%s" % GameState.format_money(float(GameState.money))
	if is_instance_valid(_bet_meter_lbl):
		_bet_meter_lbl.text = "BET\n%s" % GameState.format_money(float(_active_stake))
	if is_instance_valid(_win_meter_lbl):
		_win_meter_lbl.text = "WIN\n%s" % GameState.format_money(float(_last_win_amount))

func _refresh_payout_tray_lbl() -> void:
	if not is_instance_valid(_payout_tray_lbl):
		return
	if _last_win_amount > 0:
		_payout_tray_lbl.text = "PAYOUT TRAY   +%s" % GameState.format_money(float(_last_win_amount))
		_payout_tray_lbl.add_theme_color_override("font_color", Color("#f0b429"))
	else:
		_payout_tray_lbl.text = "PAYOUT TRAY"
		_payout_tray_lbl.add_theme_color_override("font_color", Color("#596270"))

func _refresh_stake_btns() -> void:
	if _stake_btns.size() != STAKE_OPTIONS.size():
		return
	for i in range(STAKE_OPTIONS.size()):
		var s: int = int(STAKE_OPTIONS[i])
		var is_sel: bool = (s == _active_stake)
		var btn: Button = _stake_btns[i]
		if not is_instance_valid(btn):
			continue
		# 배경/테두리 색 갱신
		var sty := StyleBoxFlat.new()
		sty.bg_color     = Color("#1a2a3a") if is_sel else Color("#0e0e1a")
		sty.border_color = Color("#c9a227") if is_sel else Color("#2a2a3a")
		sty.set_border_width_all(1)
		sty.set_corner_radius_all(6)
		sty.content_margin_left   = 8
		sty.content_margin_right  = 8
		sty.content_margin_top    = 6
		sty.content_margin_bottom = 6
		var hov := sty.duplicate()
		hov.bg_color = sty.bg_color.lightened(0.12)
		btn.add_theme_stylebox_override("normal",  sty)
		btn.add_theme_stylebox_override("hover",   hov)
		btn.add_theme_stylebox_override("pressed", hov)
		if is_sel:
			btn.add_theme_color_override("font_color", COLOR_GOLD)
		else:
			btn.add_theme_color_override("font_color", Color("#dce4f0"))

func _refresh_pad_hint() -> void:
	if not is_instance_valid(_pad_hint_lbl):
		return
	var show_hint := _should_show_pad_cursor()
	_pad_hint_lbl.visible = show_hint
	if not show_hint:
		return
	_pad_hint_lbl.bbcode_text = _tr(
		"[b]SPIN[/b]  [%s] 돌리기  [%s/%s] 금액 −/+  [%s] 금액 +  [%s] 규칙  [%s] 나가기",
		"[b]SPIN[/b]  [%s] Spin  [%s/%s] Stake −/+  [%s] Stake +  [%s] Rules  [%s] Exit"
	) % [
		ControllerHints.south(),
		ControllerHints.trigger_l(),
		ControllerHints.trigger_r(),
		ControllerHints.west(),
		ControllerHints.north(),
		ControllerHints.east(),
	]

func _refresh_spin_button_surface() -> void:
	if not is_instance_valid(_spin_btn):
		return
	if _phase == Phase.SPINNING:
		return
	if _should_show_pad_cursor():
		_mark_pad_button(_spin_btn)

func _refresh_history() -> void:
	if not is_instance_valid(_history_row):
		return
	for c in _history_row.get_children():
		c.queue_free()

	if _last_results.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "—"
		empty_lbl.add_theme_font_size_override("font_size", 12)
		empty_lbl.add_theme_color_override("font_color", Color("#2a2a3a"))
		_f(empty_lbl)
		_history_row.add_child(empty_lbl)
		return

	for entry in _last_results:
		var is_win: bool = bool(entry.get("win", false))
		var lbl_str: String = str(entry.get("label", "?"))
		var amount: int = int(entry.get("amount", 0))

		var chip := PanelContainer.new()
		var chip_sty := StyleBoxFlat.new()
		chip_sty.bg_color = Color("#0d2a15") if is_win else Color("#2a0d0d")
		chip_sty.border_color = Color("#2ecc71") if is_win else Color("#e74c3c")
		chip_sty.set_border_width_all(1)
		chip_sty.set_corner_radius_all(12)
		chip_sty.content_margin_left   = 10
		chip_sty.content_margin_right  = 10
		chip_sty.content_margin_top    = 4
		chip_sty.content_margin_bottom = 4
		chip.add_theme_stylebox_override("panel", chip_sty)

		var chip_lbl := Label.new()
		if is_win:
			chip_lbl.text = "▲ %s" % lbl_str
			chip_lbl.add_theme_color_override("font_color", Color("#3de87a"))
		else:
			chip_lbl.text = _tr("▼ 꽝", "▼ Miss")
			chip_lbl.add_theme_color_override("font_color", Color("#e85d5d"))
		chip_lbl.add_theme_font_size_override("font_size", 11)
		_f(chip_lbl)
		chip.add_child(chip_lbl)
		_history_row.add_child(chip)

# ── 베팅 선택 ─────────────────────────────────────────────────
func _on_stake_select(s: int) -> void:
	_active_stake = s
	AudioManager.play("casino_coin")
	_refresh_ui()

# ── UI 헬퍼 ───────────────────────────────────────────────────
func _apply_chip_icon(btn: Button, stake: int, max_width: int) -> void:
	if not CHIP_TEX_BY_STAKE.has(stake):
		return
	btn.icon = CHIP_TEX_BY_STAKE[stake]
	btn.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.expand_icon = false
	btn.add_theme_constant_override("h_separation", 5)
	btn.add_theme_constant_override("icon_max_width", max_width)

func _make_meter_label(title: String, value: String) -> Label:
	var lbl := Label.new()
	lbl.text = "%s\n%s" % [title, value]
	lbl.custom_minimum_size = Vector2(0, 34)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color("#7cff9a"))
	if _font_bold:
		lbl.add_theme_font_override("font", _font_bold)
	return lbl

func _add_paytable_cell(parent: Control, symbol: String, payout: String, color_hex: String) -> void:
	var cell := PanelContainer.new()
	cell.custom_minimum_size = Vector2(0, 30)
	cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sty := StyleBoxFlat.new()
	sty.bg_color = Color("#0b0d14")
	sty.border_color = Color(color_hex).darkened(0.2)
	sty.set_border_width_all(1)
	sty.set_corner_radius_all(7)
	sty.content_margin_left = 7
	sty.content_margin_right = 7
	sty.content_margin_top = 2
	sty.content_margin_bottom = 2
	cell.add_theme_stylebox_override("panel", sty)
	parent.add_child(cell)

	var lbl := Label.new()
	lbl.text = "%s\n%s" % [symbol, payout]
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 9)
	lbl.add_theme_color_override("font_color", Color(color_hex))
	_f(lbl, true)
	cell.add_child(lbl)

func _make_btn(lbl: String, cb: Callable, bg: String, border: String) -> Button:
	var btn := Button.new()
	btn.text = lbl
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.focus_mode = Control.FOCUS_NONE
	var sty := StyleBoxFlat.new()
	sty.bg_color = Color(bg)
	sty.border_color = Color(border)
	sty.set_border_width_all(1)
	sty.set_corner_radius_all(6)
	sty.content_margin_left   = 12
	sty.content_margin_right  = 12
	sty.content_margin_top    = 6
	sty.content_margin_bottom = 6
	var hov := sty.duplicate()
	hov.bg_color = Color(bg).lightened(0.12)
	var dis := sty.duplicate()
	dis.bg_color     = Color("#0e0e14")
	dis.border_color = Color("#1a1a22")
	var foc := sty.duplicate()
	foc.border_color = COLOR_GOLD
	foc.set_border_width_all(2)
	btn.add_theme_stylebox_override("normal",   sty)
	btn.add_theme_stylebox_override("hover",    hov)
	btn.add_theme_stylebox_override("pressed",  hov)
	btn.add_theme_stylebox_override("disabled", dis)
	btn.add_theme_stylebox_override("focus",    foc)
	btn.add_theme_color_override("font_color", Color("#dce4f0"))
	btn.add_theme_color_override("font_disabled_color", Color("#3a3a48"))
	btn.add_theme_font_size_override("font_size", 12)
	if _font:
		btn.add_theme_font_override("font", _font)
	btn.pressed.connect(cb)
	return btn

func _mark_pad_button(btn: Button) -> void:
	var base := btn.get_theme_stylebox("normal")
	if not base:
		return
	var st := base.duplicate()
	if st is StyleBoxFlat:
		var flat := st as StyleBoxFlat
		flat.bg_color = flat.bg_color.lightened(0.08)
		flat.border_color = COLOR_GOLD
		flat.set_border_width_all(3)
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_stylebox_override("hover", st)
	btn.add_theme_stylebox_override("pressed", st)
	btn.add_theme_stylebox_override("focus", st)
	btn.add_theme_stylebox_override("disabled", st)

func _sep() -> HSeparator:
	var s := HSeparator.new()
	s.add_theme_color_override("color", Color("#151825"))
	return s

func _flash_msg(msg: String, color_hex: String) -> void:
	if not is_instance_valid(_flash_lbl):
		return
	_flash_lbl.text = msg
	_flash_lbl.add_theme_color_override("font_color", Color(color_hex))
	_flash_lbl.visible = true
	get_tree().create_timer(1.8).timeout.connect(func():
		if is_instance_valid(_flash_lbl):
			_flash_lbl.visible = false)
