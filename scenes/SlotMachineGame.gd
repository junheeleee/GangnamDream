extends Control
## SlotMachineGame — 슬롯머신 UI 씬.
## SlotMachine 수학 모델 위에 릴 애니메이션·베팅·히스토리 UI 구현.
## MainGame이 overlay로 붙이고 open()으로 호출. 닫으면 closed 시그널.

signal closed

const SLOT := preload("res://systems/SlotMachine.gd")

enum Phase { IDLE, SPINNING, RESULT }

const COLOR_BG       := Color(0.06, 0.04, 0.10, 0.96)
const COLOR_GOLD     := Color("#f0b429")
const COLOR_GREEN    := Color("#2ecc71")
const COLOR_RED      := Color("#e74c3c")
const COLOR_BLUE     := Color("#4a9eff")
const COLOR_DARK     := Color("#1a1a2e")
const COLOR_PANEL    := Color(0.08, 0.06, 0.14, 1.0)
const COLOR_BORDER   := Color(0.20, 0.15, 0.35, 1.0)

const STAKE_OPTIONS: Array = [1_000, 5_000, 10_000, 50_000, 100_000]

const SPIN_DURATION  := 1.5   # 릴 애니메이션 총 시간(초)
const SHUFFLE_EVERY  := 0.08  # 릴 심볼 셔플 간격(초)

# ── 상태 ───────────────────────────────────────────────────────
var _phase: int         = Phase.IDLE
var _active_stake: int  = 10_000
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

# ── UI 참조 ────────────────────────────────────────────────────
var _font: FontFile
var _font_bold: FontFile

var _reel_labels: Array   = []   # Array[Label] — 3개
var _reel_panels: Array   = []   # Array[PanelContainer] — 3개
var _win_line_lbl: RichTextLabel
var _win_flash: ColorRect
var _spin_btn: Button
var _stake_btns: Array    = []   # Array[Button]
var _history_row: HBoxContainer
var _balance_lbl: Label
var _session_lbl: Label
var _flash_lbl: Label

# 모든 이모지 (릴 셔플용)
const _ALL_EMOJIS: Array = ["7️⃣", "🃏", "🍒", "🔔", "🍋"]

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
	_font      = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile

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

# ── 진입/종료 ─────────────────────────────────────────────────
func open() -> void:
	_rounds = 0
	_net = 0
	_last_results = []
	_phase = Phase.IDLE
	visible = true
	TutorialOverlay.maybe_show("slot", self)
	set_process(false)
	_set_reel_emojis(["🎰", "🎰", "🎰"])
	_refresh_ui()

func _on_exit() -> void:
	set_process(false)
	visible = false
	closed.emit()

# ── 스핀 로직 ─────────────────────────────────────────────────
func _start_spin() -> void:
	if _phase != Phase.IDLE:
		return
	if GameState.money < _active_stake:
		_flash_msg("잔액 부족!", "#e74c3c")
		return

	# 베팅 즉시 차감
	GameState.money -= _active_stake

	_phase = Phase.SPINNING
	_spin_elapsed = 0.0
	_spin_timer   = SPIN_DURATION
	_shuffle_acc  = 0.0
	_pending_result = _slot_machine.spin(_rng)

	set_process(true)
	_spin_btn.disabled = true
	_set_win_line("")
	_refresh_session_lbl()
	_refresh_balance_lbl()

func _process(delta: float) -> void:
	if _phase != Phase.SPINNING:
		return

	_spin_elapsed += delta
	_shuffle_acc  += delta

	# 릴 빠른 셔플 — 0.08초마다
	if _shuffle_acc >= SHUFFLE_EVERY:
		_shuffle_acc = 0.0
		_set_reel_emojis([
			_ALL_EMOJIS[_rng.randi_range(0, _ALL_EMOJIS.size() - 1)],
			_ALL_EMOJIS[_rng.randi_range(0, _ALL_EMOJIS.size() - 1)],
			_ALL_EMOJIS[_rng.randi_range(0, _ALL_EMOJIS.size() - 1)],
		])

	if _spin_elapsed >= _spin_timer:
		set_process(false)
		_finish_spin()

func _finish_spin() -> void:
	_phase = Phase.RESULT

	var result: Dictionary = _pending_result
	var emojis: Array = result.get("emojis", ["❓", "❓", "❓"])
	_set_reel_emojis(emojis)

	var is_win: bool     = bool(result.get("is_win", false))
	var multiplier: float = float(result.get("multiplier", 0.0))
	var win_type: String = str(result.get("win_type", ""))

	var gain: int = 0
	if is_win and multiplier > 0.0:
		gain = int(float(_active_stake) * multiplier)
		GameState.money += gain

	var net_round: int = gain - _active_stake
	_net += net_round
	_rounds += 1

	# 히스토리 저장 (최근 5개)
	var hist_label: String = win_type if win_type != "" else "꽝"
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
		log_str = "🎰 슬롯 %s +%s" % [win_type, GameState.format_money(float(gain))]
	else:
		log_str = "🎰 슬롯 꽝 -%s" % GameState.format_money(float(_active_stake))
	GameState.add_log(log_str, "money")
	GameState.stats_changed.emit()

	MetaProgression.record_minigame_play("slot")

	# 위 라인 표시 + 당첨 연출
	if is_win:
		if win_type == "JACKPOT 🎉":
			_set_win_line("[color=#ff0][b]🎉🎉 JACKPOT 200배 🎉🎉[/b][/color]")
			_play_jackpot_celebration()
		elif multiplier >= 20.0:
			_set_win_line("[color=#f0b429][b]🌟 %s 🌟[/b][/color]" % win_type)
			_play_big_win_flash()
		else:
			_set_win_line("[color=#f0b429]✨ %s ✨[/color]" % win_type)
			_play_win_flash()
	else:
		# 니어미스 체크: 3개 심볼 중 2개가 같은 높은 가치 심볼이면 "아깝다!" 연출
		var syms: Array = result.get("symbols", [])
		if syms.size() == 3:
			var near_miss := false
			if syms[0] == syms[1] and syms[0] <= 2:   # 두 릴이 7 or 바
				near_miss = true
			elif syms[1] == syms[2] and syms[1] <= 2:
				near_miss = true
			elif syms[0] == syms[2] and syms[0] <= 2:
				near_miss = true
			if near_miss:
				_set_win_line("[color=#e88a30][b]아깝다! 한 끗 차이...[/b][/color]")
				_flash_msg("💔 아깝다!", "#e88a30")
				GameState.modify_hidden_stat("addiction_tendency", 1)
			else:
				_set_win_line("[color=#4a4a6a]— 꽝 —[/color]")
		else:
			_set_win_line("[color=#4a4a6a]— 꽝 —[/color]")

	_spin_btn.disabled = false
	_refresh_ui()
	_phase = Phase.IDLE

# ── 애니메이션 헬퍼 ───────────────────────────────────────────
func _set_reel_emojis(emojis: Array) -> void:
	for i in range(mini(emojis.size(), _reel_labels.size())):
		if is_instance_valid(_reel_labels[i]):
			_reel_labels[i].text = str(emojis[i])

func _set_win_line(bbtext: String) -> void:
	if is_instance_valid(_win_line_lbl):
		_win_line_lbl.text = bbtext

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
	AudioManager.play("win")

func _play_jackpot_celebration() -> void:
	if not is_instance_valid(_win_flash):
		return
	_win_flash.color = Color(1.0, 0.9, 0.0, 0.7)
	_win_flash.modulate.a = 0.0
	_win_flash.visible = true
	# 3회 깜빡임 → 화면 전체 골드
	var tw := create_tween()
	for _i in range(3):
		tw.tween_property(_win_flash, "modulate:a", 0.8, 0.1)
		tw.tween_property(_win_flash, "modulate:a", 0.1, 0.1)
	tw.tween_property(_win_flash, "modulate:a", 0.0, 0.4)
	tw.tween_callback(func(): _win_flash.visible = false)
	# 릴 패널 골드로 잠깐 바꾸기
	for panel in _reel_panels:
		if is_instance_valid(panel):
			var sty := panel.get_theme_stylebox("panel") as StyleBoxFlat
			if sty:
				var orig := sty.bg_color
				sty.border_color = Color("#ffd700")
				sty.border_width_left   = 4
				sty.border_width_right  = 4
				sty.border_width_top    = 4
				sty.border_width_bottom = 4
				get_tree().create_timer(2.0).timeout.connect(func():
					if is_instance_valid(panel):
						sty.border_color = COLOR_BORDER
						sty.set_border_width_all(1))
	AudioManager.play("win")

# ── UI 빌드 ───────────────────────────────────────────────────
func _build_ui() -> void:
	# ── 배경 오버레이
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = COLOR_BG
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# ── 중앙 컨테이너 (최대 폭 560px, 세로 스크롤 가능)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var center_wrap := CenterContainer.new()
	center_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_wrap.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	scroll.add_child(center_wrap)

	var main_box := VBoxContainer.new()
	main_box.custom_minimum_size = Vector2(520, 0)
	main_box.add_theme_constant_override("separation", 14)
	center_wrap.add_child(main_box)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   20)
	margin.add_theme_constant_override("margin_right",  20)
	margin.add_theme_constant_override("margin_top",    18)
	margin.add_theme_constant_override("margin_bottom", 24)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_box.add_child(margin)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 14)
	margin.add_child(inner)

	# ── 헤더 ──────────────────────────────────────────────────
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	inner.add_child(header)

	var title_lbl := Label.new()
	title_lbl.text = "🎰 슬롯머신"
	title_lbl.add_theme_font_size_override("font_size", 22)
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

	var help_btn := _make_btn("❓", func(): TutorialOverlay.force_show("slot", self), "#0a0a1a", "#4a6aaa")
	help_btn.custom_minimum_size = Vector2(42, 32)
	header.add_child(help_btn)

	var exit_btn := _make_btn("나가기", _on_exit, "#1a0e0e", "#5a2a2a")
	exit_btn.custom_minimum_size = Vector2(80, 32)
	header.add_child(exit_btn)

	inner.add_child(_sep())

	# ── 릴 디스플레이 ─────────────────────────────────────────
	var reel_row := HBoxContainer.new()
	reel_row.add_theme_constant_override("separation", 12)
	reel_row.alignment = BoxContainer.ALIGNMENT_CENTER
	inner.add_child(reel_row)

	_reel_labels = []
	_reel_panels = []

	for i in range(3):
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(120, 120)
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var sty := StyleBoxFlat.new()
		sty.bg_color          = Color(0.10, 0.07, 0.18, 1.0)
		sty.border_color      = COLOR_BORDER
		sty.set_border_width_all(2)
		sty.set_corner_radius_all(10)
		panel.add_theme_stylebox_override("panel", sty)
		reel_row.add_child(panel)
		_reel_panels.append(panel)

		var reel_lbl := Label.new()
		reel_lbl.text = "🎰"
		reel_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		reel_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		reel_lbl.add_theme_font_size_override("font_size", 64)
		reel_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
		panel.add_child(reel_lbl)
		_reel_labels.append(reel_lbl)

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
	_win_line_lbl.custom_minimum_size = Vector2(0, 28)
	_win_line_lbl.add_theme_font_size_override("normal_font_size", 18)
	_win_line_lbl.add_theme_color_override("default_color", Color("#5a5a7a"))
	_f(_win_line_lbl, true)
	# 중앙 정렬 wrapper
	var wl_center := CenterContainer.new()
	wl_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wl_center.add_child(_win_line_lbl)
	inner.add_child(wl_center)

	inner.add_child(_sep())

	# ── 베팅 단위 선택 ─────────────────────────────────────────
	var stake_header := Label.new()
	stake_header.text = "베팅 금액"
	stake_header.add_theme_font_size_override("font_size", 12)
	stake_header.add_theme_color_override("font_color", Color("#6a7a8a"))
	_f(stake_header)
	inner.add_child(stake_header)

	var stake_row := HBoxContainer.new()
	stake_row.add_theme_constant_override("separation", 6)
	inner.add_child(stake_row)
	_stake_btns = []

	for s in STAKE_OPTIONS:
		var is_sel: bool = (s == _active_stake)
		var sb := _make_btn(
			GameState.format_money(float(s)),
			func(): _on_stake_select(s),
			"#1a2a3a" if is_sel else "#0e0e1a",
			"#4a9eff" if is_sel else "#2a2a3a"
		)
		sb.custom_minimum_size = Vector2(0, 34)
		sb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_stake_btns.append(sb)
		stake_row.add_child(sb)

	# ── SPIN 버튼 ──────────────────────────────────────────────
	_spin_btn = _make_btn("🎰  SPIN", _start_spin, "#0d2a15", "#2ecc71")
	_spin_btn.custom_minimum_size = Vector2(0, 56)
	_spin_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_spin_btn.add_theme_font_size_override("font_size", 20)
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
	inner.add_child(_spin_btn)

	inner.add_child(_sep())

	# ── 히스토리 (최근 5판) ────────────────────────────────────
	var hist_header := Label.new()
	hist_header.text = "최근 결과"
	hist_header.add_theme_font_size_override("font_size", 11)
	hist_header.add_theme_color_override("font_color", Color("#4a5a6a"))
	_f(hist_header)
	inner.add_child(hist_header)

	_history_row = HBoxContainer.new()
	_history_row.add_theme_constant_override("separation", 6)
	inner.add_child(_history_row)

	inner.add_child(_sep())

	# ── 잔액 표시 ──────────────────────────────────────────────
	_balance_lbl = Label.new()
	_balance_lbl.add_theme_font_size_override("font_size", 15)
	_balance_lbl.add_theme_color_override("font_color", Color("#c0cce0"))
	_balance_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_f(_balance_lbl, true)
	inner.add_child(_balance_lbl)

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
	_refresh_stake_btns()
	_refresh_history()
	_refresh_balance_lbl()

func _refresh_session_lbl() -> void:
	if not is_instance_valid(_session_lbl):
		return
	var net_str: String
	if _net >= 0:
		net_str = "+%s" % GameState.format_money(float(_net))
	else:
		net_str = GameState.format_money(float(_net))
	_session_lbl.text = "%d판  |  수익: %s" % [_rounds, net_str]
	if _net > 0:
		_session_lbl.add_theme_color_override("font_color", Color("#3de87a"))
	elif _net < 0:
		_session_lbl.add_theme_color_override("font_color", Color("#e85d5d"))
	else:
		_session_lbl.add_theme_color_override("font_color", Color("#7a8a9a"))

func _refresh_balance_lbl() -> void:
	if not is_instance_valid(_balance_lbl):
		return
	_balance_lbl.text = "현재 잔액  ₩%s" % GameState.format_money(GameState.money)

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
		sty.border_color = Color("#4a9eff") if is_sel else Color("#2a2a3a")
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
			btn.add_theme_color_override("font_color", COLOR_BLUE)
		else:
			btn.add_theme_color_override("font_color", Color("#dce4f0"))

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
			chip_lbl.text = "▼ 꽝"
			chip_lbl.add_theme_color_override("font_color", Color("#e85d5d"))
		chip_lbl.add_theme_font_size_override("font_size", 11)
		_f(chip_lbl)
		chip.add_child(chip_lbl)
		_history_row.add_child(chip)

# ── 베팅 선택 ─────────────────────────────────────────────────
func _on_stake_select(s: int) -> void:
	_active_stake = s
	_refresh_stake_btns()

# ── UI 헬퍼 ───────────────────────────────────────────────────
func _make_btn(lbl: String, cb: Callable, bg: String, border: String) -> Button:
	var btn := Button.new()
	btn.text = lbl
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sty := StyleBoxFlat.new()
	sty.bg_color = Color(bg)
	sty.border_color = Color(border)
	sty.set_border_width_all(1)
	sty.set_corner_radius_all(6)
	sty.content_margin_left   = 12
	sty.content_margin_right  = 12
	sty.content_margin_top    = 8
	sty.content_margin_bottom = 8
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
	btn.add_theme_font_size_override("font_size", 14)
	if _font:
		btn.add_theme_font_override("font", _font)
	btn.pressed.connect(cb)
	return btn

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
