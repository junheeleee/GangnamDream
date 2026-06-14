extends Control
## BigWheelGame — 강원랜드 빅휠 (Big Six Wheel).
## 54칸 바퀴, 6가지 구역 베팅. 애니메이션 회전 후 결과 표시.
## GangwonLand 허브에서 open()으로 호출. 닫으면 closed 시그널.

signal closed

const BIG_WHEEL := preload("res://systems/BigWheel.gd")

enum Phase { IDLE, SPINNING, RESULT }

const STAKES: Array        = [10_000, 50_000, 100_000, 500_000, 1_000_000]
const SPIN_DURATION: float = 3.0      # 총 회전 시간
const SPIN_ROTATIONS: int  = 5        # 최소 완전 회전 수
const TOTAL_SLOTS: int     = 54

const COLOR_BG     := Color(0.06, 0.04, 0.02, 0.97)
const COLOR_HEADER := Color(0.12, 0.08, 0.03, 1.0)
const COLOR_GOLD   := Color(0.95, 0.80, 0.20, 1.0)

# 구역별 색상 (BigWheel.SEGMENT_COLORS 미러)
const SEG_COLORS: Array = ["#e74c3c","#3498db","#2ecc71","#f39c12","#9b59b6","#f1c40f"]
const SEG_LABELS: Array = ["1","2","5","10","20","🃏"]
const SEG_PAYOUTS: Array = [1.0, 2.0, 5.0, 10.0, 20.0, 45.0]
const SEG_SLOTS: Array   = [24, 15, 7, 4, 2, 2]

# ── 상태 ─────────────────────────────────────────────────────────
var _phase: int         = Phase.IDLE
var _bet_segment: int   = -1
var _stake: int         = 50_000
var _result_seg: int    = -1
var _rng := RandomNumberGenerator.new()

# 세션 통계
var _rounds: int = 0
var _net: int    = 0
var _history: Array = []   # Array of int (segment index)

# 애니메이션
var _wheel_angle: float  = 0.0
var _spin_speed: float   = 0.0
var _spin_elapsed: float = 0.0
var _target_angle: float = 0.0
var _initial_speed: float = 0.0

# UI 참조
var _font: FontFile
var _font_bold: FontFile
var _wheel_ctrl: Control
var _msg_lbl: Label
var _stats_lbl: Label
var _balance_lbl: Label
var _spin_btn: Button
var _stake_btns: Array  = []
var _seg_btns: Array    = []
var _result_lbl: Label
var _history_box: HBoxContainer

# ── 초기화 ────────────────────────────────────────────────────────
func _ready() -> void:
	_rng.randomize()
	_load_fonts()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 100
	visible = false
	_build_ui()

func _load_fonts() -> void:
	_font      = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile

func _f(n: Control, bold: bool = false) -> void:
	if not n: return
	var ft: FontFile = _font_bold if bold else _font
	if not ft: return
	if n is Label or n is Button:
		n.add_theme_font_override("font", ft)

func open() -> void:
	visible = true
	_phase = Phase.IDLE
	set_process(false)
	_refresh_ui()

func _on_exit() -> void:
	set_process(false)
	visible = false
	emit_signal("closed")

# ── UI 빌드 ──────────────────────────────────────────────────────
func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = COLOR_BG
	add_child(bg)

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	add_child(root)

	# ── 헤더 ──
	var header_panel := _panel(COLOR_HEADER)
	header_panel.custom_minimum_size = Vector2(0, 60)
	root.add_child(header_panel)
	var hrow := HBoxContainer.new()
	hrow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hrow.add_theme_constant_override("separation", 12)
	header_panel.add_child(hrow)

	var title_lbl := Label.new()
	title_lbl.text = "🎯  빅휠"
	title_lbl.add_theme_font_size_override("font_size", 20)
	title_lbl.add_theme_color_override("font_color", COLOR_GOLD)
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_f(title_lbl, true)
	hrow.add_child(title_lbl)

	_stats_lbl = Label.new()
	_stats_lbl.add_theme_font_size_override("font_size", 13)
	_stats_lbl.add_theme_color_override("font_color", Color(0.7, 0.8, 0.7))
	_f(_stats_lbl)
	hrow.add_child(_stats_lbl)

	_balance_lbl = Label.new()
	_balance_lbl.add_theme_font_size_override("font_size", 14)
	_balance_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.6))
	_f(_balance_lbl, true)
	hrow.add_child(_balance_lbl)

	var exit_btn := _btn("나가기", "#505050")
	exit_btn.custom_minimum_size = Vector2(80, 36)
	exit_btn.pressed.connect(_on_exit)
	_f(exit_btn)
	hrow.add_child(exit_btn)

	# ── 휠 ──
	_wheel_ctrl = Control.new()
	_wheel_ctrl.custom_minimum_size = Vector2(0, 260)
	_wheel_ctrl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_wheel_ctrl.draw.connect(_draw_wheel)
	root.add_child(_wheel_ctrl)

	# ── 결과/메시지 ──
	_msg_lbl = Label.new()
	_msg_lbl.text = "베팅 구역을 선택하세요"
	_msg_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_msg_lbl.add_theme_font_size_override("font_size", 15)
	_msg_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	_f(_msg_lbl)
	root.add_child(_msg_lbl)

	_result_lbl = Label.new()
	_result_lbl.text = ""
	_result_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_lbl.add_theme_font_size_override("font_size", 22)
	_f(_result_lbl, true)
	root.add_child(_result_lbl)

	# ── 세그먼트 베팅 버튼 ──
	var seg_lbl := Label.new()
	seg_lbl.text = "베팅 구역"
	seg_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	seg_lbl.add_theme_font_size_override("font_size", 12)
	seg_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
	root.add_child(seg_lbl)

	var seg_row := HBoxContainer.new()
	seg_row.alignment = BoxContainer.ALIGNMENT_CENTER
	seg_row.add_theme_constant_override("separation", 8)
	var seg_mc := MarginContainer.new()
	seg_mc.add_theme_constant_override("margin_left", 12)
	seg_mc.add_theme_constant_override("margin_right", 12)
	seg_mc.add_theme_constant_override("margin_bottom", 4)
	seg_mc.add_child(seg_row)
	root.add_child(seg_mc)

	for i in range(6):
		var s_btn := _btn("%s\n%sx" % [SEG_LABELS[i], int(SEG_PAYOUTS[i])], SEG_COLORS[i])
		s_btn.custom_minimum_size = Vector2(72, 54)
		s_btn.add_theme_font_size_override("font_size", 14)
		s_btn.add_theme_color_override("font_color", Color(0.05, 0.05, 0.05))
		_f(s_btn, true)
		var seg_idx := i
		s_btn.pressed.connect(func(): _select_segment(seg_idx))
		seg_row.add_child(s_btn)
		_seg_btns.append(s_btn)

	# ── 베팅금액 ──
	var stake_lbl := Label.new()
	stake_lbl.text = "베팅 금액"
	stake_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stake_lbl.add_theme_font_size_override("font_size", 12)
	stake_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
	root.add_child(stake_lbl)

	var stake_row := HBoxContainer.new()
	stake_row.alignment = BoxContainer.ALIGNMENT_CENTER
	stake_row.add_theme_constant_override("separation", 6)
	var stake_mc := MarginContainer.new()
	stake_mc.add_theme_constant_override("margin_left", 12)
	stake_mc.add_theme_constant_override("margin_right", 12)
	stake_mc.add_theme_constant_override("margin_bottom", 6)
	stake_mc.add_child(stake_row)
	root.add_child(stake_mc)

	for amt in STAKES:
		var s_btn := _btn(_fmt_k(amt), "#1a1a3a")
		s_btn.custom_minimum_size = Vector2(80, 36)
		s_btn.add_theme_font_size_override("font_size", 12)
		_f(s_btn)
		var amount := amt
		s_btn.pressed.connect(func(): _set_stake(amount))
		stake_row.add_child(s_btn)
		_stake_btns.append(s_btn)

	# ── SPIN ──
	_spin_btn = _btn("🎯  SPIN", "#27ae60")
	_spin_btn.custom_minimum_size = Vector2(200, 52)
	_spin_btn.add_theme_font_size_override("font_size", 20)
	_spin_btn.add_theme_color_override("font_color", Color(0.05, 0.05, 0.05))
	_f(_spin_btn, true)
	_spin_btn.pressed.connect(_do_spin)
	var spin_mc := MarginContainer.new()
	spin_mc.add_theme_constant_override("margin_left", 12)
	spin_mc.add_theme_constant_override("margin_right", 12)
	spin_mc.add_theme_constant_override("margin_top", 4)
	spin_mc.add_theme_constant_override("margin_bottom", 4)
	var spin_hbox := HBoxContainer.new()
	spin_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	spin_hbox.add_child(_spin_btn)
	spin_mc.add_child(spin_hbox)
	root.add_child(spin_mc)

	# ── 히스토리 ──
	_history_box = HBoxContainer.new()
	_history_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_history_box.add_theme_constant_override("separation", 6)
	var hist_mc := MarginContainer.new()
	hist_mc.add_theme_constant_override("margin_left", 12)
	hist_mc.add_theme_constant_override("margin_right", 12)
	hist_mc.add_theme_constant_override("margin_bottom", 8)
	hist_mc.add_child(_history_box)
	root.add_child(hist_mc)

	_refresh_ui()

# ── 드로우 함수 (휠) ─────────────────────────────────────────────
func _draw_wheel() -> void:
	if not _wheel_ctrl: return
	var size: Vector2 = _wheel_ctrl.size
	var cx: float = size.x * 0.5
	var cy: float = size.y * 0.5
	var radius: float = min(cx, cy) * 0.88

	var slot_angle: float = TAU / float(TOTAL_SLOTS)
	var seg_start: int = 0

	for seg in range(6):
		var col: Color = Color.html(SEG_COLORS[seg])
		var seg_count: int = SEG_SLOTS[seg]
		for slot_i in range(seg_count):
			var angle_start: float = _wheel_angle + float(seg_start + slot_i) * slot_angle
			var angle_end: float   = angle_start + slot_angle

			# 부채꼴 그리기 (CanvasItem.draw_arc로는 채워진 부채꼴 불가 → 다각형 사용)
			var points: PackedVector2Array = PackedVector2Array()
			points.append(Vector2(cx, cy))
			var steps := 3
			for step in range(steps + 1):
				var a: float = angle_start + (angle_end - angle_start) * float(step) / float(steps)
				points.append(Vector2(cx + cos(a) * radius, cy + sin(a) * radius))
			# 강조 효과: 결과 세그먼트 밝게
			var draw_col: Color = col
			if _phase == Phase.RESULT and seg == _result_seg:
				draw_col = col.lightened(0.4)
			_wheel_ctrl.draw_colored_polygon(points, draw_col)

		# 세그먼트 구분선
		var div_angle: float = _wheel_angle + float(seg_start) * slot_angle
		var lx: float = cx + cos(div_angle) * radius
		var ly: float = cy + sin(div_angle) * radius
		_wheel_ctrl.draw_line(Vector2(cx, cy), Vector2(lx, ly), Color(0.1, 0.1, 0.1, 0.8), 2.0)

		# 레이블
		var mid_slots: float = seg_start + float(seg_count) * 0.5
		var mid_angle: float = _wheel_angle + mid_slots * slot_angle
		var label_r: float = radius * 0.72
		var lbl_pos := Vector2(cx + cos(mid_angle) * label_r, cy + sin(mid_angle) * label_r)
		_wheel_ctrl.draw_string(_font if _font else ThemeDB.fallback_font,
			lbl_pos - Vector2(12, 8), SEG_LABELS[seg], HORIZONTAL_ALIGNMENT_CENTER, -1, 16,
			Color(1, 1, 1, 0.9))

		seg_start += seg_count

	# 외곽 원
	_wheel_ctrl.draw_arc(Vector2(cx, cy), radius, 0, TAU, 64, Color(0.8, 0.7, 0.2), 3.0)

	# 포인터 (상단 삼각형)
	var ptr_size: float = 18.0
	var ptr_pts := PackedVector2Array([
		Vector2(cx, cy - radius - 4),
		Vector2(cx - ptr_size * 0.5, cy - radius - ptr_size - 4),
		Vector2(cx + ptr_size * 0.5, cy - radius - ptr_size - 4),
	])
	_wheel_ctrl.draw_colored_polygon(ptr_pts, Color(0.95, 0.85, 0.1))
	_wheel_ctrl.draw_polyline(ptr_pts, Color(0.5, 0.4, 0.0), 1.5, true)

	# 중앙 원
	_wheel_ctrl.draw_circle(Vector2(cx, cy), radius * 0.12, Color(0.15, 0.10, 0.05))
	_wheel_ctrl.draw_arc(Vector2(cx, cy), radius * 0.12, 0, TAU, 32, Color(0.8, 0.7, 0.2), 2.0)

# ── 프로세스 (회전 애니메이션) ───────────────────────────────────
func _process(delta: float) -> void:
	if _phase != Phase.SPINNING: return

	_spin_elapsed += delta
	var t: float = clampf(_spin_elapsed / SPIN_DURATION, 0.0, 1.0)
	# ease-out cubic
	var ease_t: float = 1.0 - pow(1.0 - t, 3.0)
	_wheel_angle = lerp(0.0, _target_angle, ease_t)
	_wheel_ctrl.queue_redraw()

	if _spin_elapsed >= SPIN_DURATION:
		_wheel_angle = _target_angle
		_phase = Phase.RESULT
		set_process(false)
		_wheel_ctrl.queue_redraw()
		_show_result()

# ── 게임 로직 ────────────────────────────────────────────────────
func _select_segment(seg: int) -> void:
	if _phase != Phase.IDLE: return
	_bet_segment = seg
	_refresh_ui()
	_msg_lbl.text = "%s 구역 베팅 선택 (배당 %sx)" % [SEG_LABELS[seg], int(SEG_PAYOUTS[seg])]

func _set_stake(amount: int) -> void:
	if _phase != Phase.IDLE: return
	_stake = amount
	_refresh_ui()

func _do_spin() -> void:
	if _phase != Phase.IDLE: return
	if _bet_segment < 0:
		_msg_lbl.text = "먼저 베팅 구역을 선택하세요!"
		return
	if GameState.money < _stake:
		_msg_lbl.text = "잔액이 부족합니다."
		return

	GameState.money -= _stake
	_phase = Phase.SPINNING

	_result_seg = BIG_WHEEL.spin(_rng)

	# 목표 각도 계산: 결과 세그먼트 중앙이 포인터(상단, -PI/2) 아래 오도록
	var slot_angle: float = TAU / float(TOTAL_SLOTS)
	var seg_offset: int = 0
	for s in range(_result_seg):
		seg_offset += SEG_SLOTS[s]
	# 세그먼트 내 임의 위치
	var rand_slot: int = _rng.randi_range(0, SEG_SLOTS[_result_seg] - 1)
	var result_slot: int = seg_offset + rand_slot
	# 휠이 이 슬롯이 상단(-PI/2)에 오려면
	var final_wheel_angle: float = -PI / 2.0 - float(result_slot) * slot_angle
	# 현재 각도에서 SPIN_ROTATIONS바퀴 추가 회전
	_target_angle = _wheel_angle - TAU * float(SPIN_ROTATIONS) + (final_wheel_angle - _wheel_angle)
	# 현재 wheel_angle을 0 기준으로 초기화
	_wheel_angle = 0.0
	_target_angle = final_wheel_angle - TAU * float(SPIN_ROTATIONS)

	_spin_elapsed = 0.0
	_msg_lbl.text = "돌아가고 있습니다..."
	_result_lbl.text = ""
	_spin_btn.disabled = true
	set_process(true)

	MetaProgression.record_minigame_play("bigwheel")
	GameState.emit_signal("stats_changed")

func _show_result() -> void:
	var seg := _result_seg
	var label_str: String = SEG_LABELS[seg]
	var col: Color = Color.html(SEG_COLORS[seg])
	var won := (_bet_segment == seg)

	_rounds += 1
	_history.append(seg)
	if _history.size() > 8:
		_history.pop_front()

	if won:
		var payout: int = int(_stake * SEG_PAYOUTS[seg])
		GameState.money += _stake + payout  # 원금 반환 + 이익
		_net += payout
		_msg_lbl.text = "🎉 당첨! %s 구역 (배당 %sx)" % [label_str, int(SEG_PAYOUTS[seg])]
		_result_lbl.text = "▲ +₩%s" % _fmt(_net if _net > 0 else payout)
		_result_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
	else:
		_net -= _stake
		_msg_lbl.text = "😞 꽝. 결과: %s 구역" % label_str
		_result_lbl.text = "▼ -₩%s" % _fmt(_stake)
		_result_lbl.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))

	GameState.emit_signal("stats_changed")
	_phase = Phase.IDLE
	_refresh_ui()

# ── UI 갱신 ──────────────────────────────────────────────────────
func _refresh_ui() -> void:
	if _stats_lbl:
		var net_str: String = ("+₩%s" if _net >= 0 else "-₩%s") % _fmt(abs(_net))
		_stats_lbl.text = "%d회  %s" % [_rounds, net_str]
	if _balance_lbl:
		_balance_lbl.text = "₩%s" % _fmt(GameState.money)
	if _spin_btn:
		_spin_btn.disabled = (_phase != Phase.IDLE or GameState.money < _stake or _bet_segment < 0)

	for i in range(_stake_btns.size()):
		var s_btn: Button = _stake_btns[i]
		if STAKES[i] == _stake:
			var sb := StyleBoxFlat.new()
			sb.bg_color = Color(0.3, 0.5, 0.9)
			sb.corner_radius_top_left     = 4
			sb.corner_radius_top_right    = 4
			sb.corner_radius_bottom_left  = 4
			sb.corner_radius_bottom_right = 4
			s_btn.add_theme_stylebox_override("normal", sb)
		else:
			var sb := StyleBoxFlat.new()
			sb.bg_color = Color.html("#1a1a3a")
			sb.corner_radius_top_left     = 4
			sb.corner_radius_top_right    = 4
			sb.corner_radius_bottom_left  = 4
			sb.corner_radius_bottom_right = 4
			s_btn.add_theme_stylebox_override("normal", sb)

	for i in range(_seg_btns.size()):
		var s_btn: Button = _seg_btns[i]
		var is_selected: bool = (i == _bet_segment)
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color.html(SEG_COLORS[i])
		if is_selected:
			sb.border_color = Color.WHITE
			sb.border_width_left   = 3
			sb.border_width_right  = 3
			sb.border_width_top    = 3
			sb.border_width_bottom = 3
		sb.corner_radius_top_left     = 6
		sb.corner_radius_top_right    = 6
		sb.corner_radius_bottom_left  = 6
		sb.corner_radius_bottom_right = 6
		s_btn.add_theme_stylebox_override("normal", sb)

	# 히스토리 갱신
	for child in _history_box.get_children():
		child.queue_free()
	for seg_idx in _history:
		var chip := Label.new()
		chip.text = SEG_LABELS[seg_idx]
		chip.add_theme_font_size_override("font_size", 14)
		chip.add_theme_color_override("font_color", Color(0.05, 0.05, 0.05))
		chip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		chip.custom_minimum_size = Vector2(32, 32)
		var chip_panel := PanelContainer.new()
		var chip_sb := StyleBoxFlat.new()
		chip_sb.bg_color = Color.html(SEG_COLORS[seg_idx])
		chip_sb.corner_radius_top_left     = 16
		chip_sb.corner_radius_top_right    = 16
		chip_sb.corner_radius_bottom_left  = 16
		chip_sb.corner_radius_bottom_right = 16
		chip_panel.add_theme_stylebox_override("panel", chip_sb)
		chip_panel.add_child(chip)
		_history_box.add_child(chip_panel)

# ── 헬퍼 ──────────────────────────────────────────────────────────
func _panel(col: Color) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	p.add_theme_stylebox_override("panel", sb)
	return p

func _btn(text: String, hex: String) -> Button:
	var b := Button.new()
	b.text = text
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color.html(hex)
	sb.corner_radius_top_left     = 4
	sb.corner_radius_top_right    = 4
	sb.corner_radius_bottom_left  = 4
	sb.corner_radius_bottom_right = 4
	b.add_theme_stylebox_override("normal", sb)
	_f(b)
	return b

func _fmt(n: int) -> String:
	var s := str(abs(n))
	var result: String = ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	return result

func _fmt_k(n: int) -> String:
	if n >= 1_000_000:
		return "%d만" % (n / 10000)
	if n >= 10_000:
		return "%d만" % (n / 10000)
	return "%d" % n
