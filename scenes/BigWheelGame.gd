extends Control
## BigWheelGame — 빅식스 휠 카지노 게임.
## BigWheel 수학 모델(54칸, 6 세그먼트) 위에 회전 애니메이션·베팅 UI 구현.
## MainGame이 overlay로 붙이고 open()으로 호출. 닫으면 closed 시그널.

signal closed

const BIG_WHEEL := preload("res://systems/BigWheel.gd")

enum Phase { IDLE, SPINNING, RESULT }

const STAKE_OPTIONS: Array  = [10_000, 50_000, 100_000, 500_000, 1_000_000]
const CHIP_TEX_BY_STAKE := {
	10_000: preload("res://assets/ui/chips/chip_10k.svg"),
	50_000: preload("res://assets/ui/chips/chip_50k.svg"),
	100_000: preload("res://assets/ui/chips/chip_100k.svg"),
	500_000: preload("res://assets/ui/chips/chip_500k.svg"),
	1_000_000: preload("res://assets/ui/chips/chip_1m.svg"),
}
const TOTAL_SLOTS: int      = 54
const SPIN_DURATION: float  = 3.0          # 총 스핀 시간(초)
const SPIN_SPEED_INIT: float = TAU * 4.0   # 초기 각속도 (라디안/초)
const HISTORY_MAX: int      = 8
const WHEEL_RADIUS: float   = 130.0

# 세그먼트 슬롯/레이블/배당/색상 (BigWheel 미러)
const SEG_SLOTS: Array   = [24, 15, 7, 4, 2, 2]
const SEG_LABELS: Array  = ["1", "2", "5", "10", "20", "J"]
const SEG_PAYOUTS: Array = [1.0, 2.0, 5.0, 10.0, 20.0, 45.0]
const SEG_COLORS: Array  = ["#e74c3c", "#3498db", "#2ecc71", "#f39c12", "#9b59b6", "#f1c40f"]

# ── 상태 ──────────────────────────────────────────────────────
var _rng := RandomNumberGenerator.new()

var _phase: int         = Phase.IDLE
var _bet_segment: int   = -1
var _stake: int         = 50_000
var _result_seg: int    = -1
var _history: Array     = []   # Array of int (segment index)

var _rounds: int = 0
var _net: float  = 0.0
var _wins: int   = 0
var _losses: int = 0

# 애니메이션
var _wheel_angle: float  = 0.0
var _spin_elapsed: float = 0.0
var _target_angle: float = 0.0
var _flash_timer: float  = 0.0

# 세그먼트 tick SFX
var _prev_sector: int = -1

# 당첨 세그먼트 깜빡임 (0.0 = 어둡, 1.0 = 밝음)
var _flash_winner_bright: float = 0.0
var _flash_winner_active: bool  = false

# 포인터 pulse 스케일 (1.0 = 기본)
var _pointer_scale: float = 1.0

# 카운트업 대상 Label (animate_winnings 내부 참조)
var _count_label_ref: Label = null

# UI 참조
var _font: FontFile
var _font_bold: FontFile
var _hud_lbl: RichTextLabel
var _wheel_ctrl: Control
var _msg_lbl: Label
var _balance_lbl: Label
var _spin_btn: Button
var _stake_btns: Array = []   # Array of {btn, amount}
var _seg_btns: Array   = []   # Array of Button (6개)
var _history_box: HBoxContainer

# ── 초기화 ────────────────────────────────────────────────────
func _ready() -> void:
	_rng.randomize()
	_load_fonts()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 100
	visible = false
	_build_ui()
	set_process(false)

func _load_fonts() -> void:
	_font      = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile

func _f(n: Object, bold: bool = false) -> void:
	var ft: FontFile = _font_bold if bold else _font
	if ft and n:
		n.add_theme_font_override("font", ft)
		if n is RichTextLabel:
			n.add_theme_font_override("normal_font", ft)
			n.add_theme_font_override("bold_font", _font_bold if _font_bold else ft)

# ── 진입/종료 ──────────────────────────────────────────────────
func open() -> void:
	_phase               = Phase.IDLE
	_bet_segment         = -1
	_result_seg          = -1
	_wheel_angle         = 0.0
	_spin_elapsed        = 0.0
	_flash_timer         = 0.0
	_prev_sector         = -1
	_flash_winner_bright = 0.0
	_flash_winner_active = false
	_pointer_scale       = 1.0
	_count_label_ref     = null
	_rounds = 0; _net = 0.0; _wins = 0; _losses = 0
	_history = []
	set_process(false)
	visible = true
	TutorialOverlay.maybe_show("bigwheel", self)
	_refresh()

func _on_exit() -> void:
	MetaProgression.record_minigame_play("bigwheel")
	set_process(false)
	visible = false
	closed.emit()

# ── 프로세스 (회전 애니메이션) ────────────────────────────────
func _process(delta: float) -> void:
	if _phase != Phase.SPINNING:
		set_process(false)
		return

	_spin_elapsed += delta
	if _flash_timer > 0.0:
		_flash_timer -= delta

	var t: float = clampf(_spin_elapsed / SPIN_DURATION, 0.0, 1.0)
	# ease-out cubic 감속
	var ease_t: float = 1.0 - pow(1.0 - t, 3.0)
	_wheel_angle = fmod(lerp(0.0, _target_angle, ease_t), TAU)
	if _wheel_angle < 0.0:
		_wheel_angle += TAU

	# 세그먼트 경계 통과 tick SFX
	var slot_angle: float = TAU / float(TOTAL_SLOTS)
	# 포인터(-PI/2)가 가리키는 슬롯 = (-PI/2 - _wheel_angle) / slot_angle (정규화)
	var pointer_offset: float = (-PI / 2.0) - _wheel_angle
	var raw_slot: float = pointer_offset / slot_angle
	var current_sector: int = int(floor(raw_slot)) % TOTAL_SLOTS
	if current_sector < 0:
		current_sector += TOTAL_SLOTS
	if _prev_sector >= 0 and current_sector != _prev_sector:
		AudioManager.play("casino_coin")
	_prev_sector = current_sector

	if is_instance_valid(_wheel_ctrl):
		_wheel_ctrl.queue_redraw()

	if _spin_elapsed >= SPIN_DURATION:
		_wheel_angle = fmod(_target_angle, TAU)
		if _wheel_angle < 0.0:
			_wheel_angle += TAU
		set_process(false)
		_finish_spin()

# ── 베팅 & 스핀 ───────────────────────────────────────────────
func _select_segment(seg: int) -> void:
	if _phase != Phase.IDLE:
		return
	_bet_segment = seg
	AudioManager.play("casino_bet")
	_refresh()

func _select_stake(s: int) -> void:
	_stake = s
	AudioManager.play("casino_coin")
	_refresh()

func _do_spin() -> void:
	if _phase != Phase.IDLE:
		return
	if _bet_segment < 0:
		_flash_msg("세그먼트를 먼저 선택해 주세요", "#e8c45d"); return
	if int(GameState.money) < _stake:
		_flash_msg("현금이 부족합니다", "#e85d5d"); return

	GameState.add_money(-float(_stake))

	_result_seg          = BigWheel.spin(_rng)
	_target_angle        = _compute_target(_result_seg)
	_spin_elapsed        = 0.0
	_wheel_angle         = 0.0
	_flash_timer         = 0.0
	_prev_sector         = -1
	_flash_winner_active = false
	_flash_winner_bright = 0.0
	_pointer_scale       = 1.0
	_phase               = Phase.SPINNING

	AudioManager.play("casino_spin")
	set_process(true)
	_refresh()

func _compute_target(seg: int) -> float:
	# 포인터는 위쪽(-PI/2). 목표 세그먼트 중앙이 포인터 아래 오도록.
	var slot_angle: float = TAU / float(TOTAL_SLOTS)
	var seg_start: int = 0
	for i in range(seg):
		seg_start += int(SEG_SLOTS[i])
	var seg_count: int = int(SEG_SLOTS[seg])
	# 세그먼트 내 임의 슬롯 선택 (자연스러운 느낌)
	var rand_offset: int = _rng.randi_range(0, seg_count - 1)
	var result_slot: int = seg_start + rand_offset
	# 이 슬롯이 -PI/2에 오게 하는 최종 wheel_angle.
	# 슬롯 i의 각도 = wheel_angle + i * slot_angle
	# 포인터(위 = -PI/2) → wheel_angle + result_slot * slot_angle = -PI/2 (mod TAU)
	# wheel_angle = -PI/2 - result_slot * slot_angle
	# SPIN_ROTATIONS바퀴(= 5) 추가하여 긴 회전 연출
	var final_pos: float = -PI / 2.0 - float(result_slot) * slot_angle
	return final_pos - TAU * 5.0   # 음수 = 시계방향

func _finish_spin() -> void:
	var seg: int      = _result_seg
	var won: bool     = (seg == _bet_segment)
	var payout: float = float(SEG_PAYOUTS[seg])
	var wagered: int  = _stake

	if won:
		var gain: int = int(float(wagered) * payout)
		GameState.add_money(float(wagered + gain))
		_net  += float(gain)
		_wins += 1
		if payout >= 45.0:
			AudioManager.play("casino_jackpot")
		else:
			AudioManager.play("casino_win")
		GameState.modify_hidden_stat("gambling_tendency", 2)
	else:
		_net    -= float(wagered)
		_losses += 1
		AudioManager.play("casino_lose")
		GameState.modify_hidden_stat("addiction_tendency", 2)

	_rounds += 1
	_flash_timer = 1.5
	_history.append(seg)
	if _history.size() > HISTORY_MAX:
		_history.pop_front()

	MetaProgression.record_minigame_play("bigwheel")
	GameState.stats_changed.emit()

	_phase = Phase.RESULT
	_refresh()

	# 포인터 pulse: 1.0 → 1.4 → 1.0 (0.3초)
	_pulse_pointer()

	# 당첨 세그먼트 깜빡임 연출 (스핀 완료 직후)
	_flash_winner_segment()

	if won:
		var win_amount: int = int(float(wagered) * payout)
		# 카운트업 애니메이션 (0.6초)
		_count_label_ref = _msg_lbl
		_msg_lbl.add_theme_color_override("font_color", Color("#3de87a"))
		_msg_lbl.text = "당첨!  %s배   +%s" % [_segment_display_label(seg), "0원"]
		_msg_lbl.visible = true
		_animate_winnings(win_amount, _msg_lbl)
	else:
		_flash_msg("꽝   결과: %s" % _segment_display_label(seg), "#e85d5d")

	get_tree().create_timer(2.4).timeout.connect(func():
		if is_instance_valid(self) and _phase == Phase.RESULT:
			_phase               = Phase.IDLE
			_flash_timer         = 0.0
			_flash_winner_active = false
			_flash_winner_bright = 0.0
			_pointer_scale       = 1.0
			_count_label_ref     = null
			_refresh()
			if is_instance_valid(_wheel_ctrl):
				_wheel_ctrl.queue_redraw())

# ── 연출 함수 ─────────────────────────────────────────────────

## 당첨 세그먼트 0.2초 깜빡임 × 3회 (modulate 1.0 → 0.3 → 1.0)
func _flash_winner_segment() -> void:
	_flash_winner_active = true
	var tw := create_tween()
	tw.set_loops(3)
	tw.tween_method(_set_flash_bright, 1.0, 0.3, 0.1)
	tw.tween_method(_set_flash_bright, 0.3, 1.0, 0.1)
	tw.finished.connect(func():
		_flash_winner_active = false
		_flash_winner_bright = 1.0
		if is_instance_valid(_wheel_ctrl):
			_wheel_ctrl.queue_redraw())

func _set_flash_bright(val: float) -> void:
	_flash_winner_bright = val
	if is_instance_valid(_wheel_ctrl):
		_wheel_ctrl.queue_redraw()

## 포인터 pulse: scale 1.0 → 1.4 → 1.0 (0.3초)
func _pulse_pointer() -> void:
	var tw := create_tween()
	tw.tween_method(_set_pointer_scale, 1.0, 1.4, 0.15)
	tw.tween_method(_set_pointer_scale, 1.4, 1.0, 0.15)

func _set_pointer_scale(val: float) -> void:
	_pointer_scale = val
	if is_instance_valid(_wheel_ctrl):
		_wheel_ctrl.queue_redraw()

## 카운트업: 0 → final (0.6초), 완료 후 최종 텍스트 고정
func _animate_winnings(final: int, label: Label) -> void:
	var tw := create_tween()
	tw.tween_method(_update_count_label, 0, final, 0.6)

func _update_count_label(val: int) -> void:
	if is_instance_valid(_count_label_ref):
		var seg: int = _result_seg
		var lbl_str: String = _segment_display_label(seg)
		_count_label_ref.text = "당첨!  %s배   +%s" % [
			lbl_str, GameState.format_money(float(val))]

# ── UI 빌드 ──────────────────────────────────────────────────
func _build_ui() -> void:
	# 배경
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.06, 0.04, 0.02, 1.0)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# HUD 상단 바
	var hud_panel := Panel.new()
	hud_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hud_panel.offset_bottom = 44
	var hs := StyleBoxFlat.new()
	hs.bg_color = Color("#100a04")
	hs.border_color = Color("#2e1a0a")
	hs.border_width_bottom = 1
	hud_panel.add_theme_stylebox_override("panel", hs)
	add_child(hud_panel)

	_hud_lbl = RichTextLabel.new()
	_hud_lbl.bbcode_enabled = true
	_hud_lbl.fit_content = true
	_hud_lbl.scroll_active = false
	_hud_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hud_lbl.offset_left = 16
	_hud_lbl.offset_top = 10
	_hud_lbl.offset_right = -16
	_f(_hud_lbl)
	_hud_lbl.add_theme_font_size_override("normal_font_size", 13)
	hud_panel.add_child(_hud_lbl)

	# 스크롤 컨테이너
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 50
	scroll.offset_bottom = -10
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var outer := MarginContainer.new()
	outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.add_theme_constant_override("margin_left", 20)
	outer.add_theme_constant_override("margin_right", 20)
	outer.add_theme_constant_override("margin_top", 10)
	outer.add_theme_constant_override("margin_bottom", 10)
	scroll.add_child(outer)

	var root_vbox := VBoxContainer.new()
	root_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_vbox.add_theme_constant_override("separation", 10)
	outer.add_child(root_vbox)

	# ── 휠 그리기 영역 ──
	_wheel_ctrl = Control.new()
	_wheel_ctrl.custom_minimum_size = Vector2(0, 300)
	_wheel_ctrl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_wheel_ctrl.draw.connect(_on_wheel_draw)
	root_vbox.add_child(_wheel_ctrl)

	# ── 세그먼트 베팅 버튼 (6개) ──
	var bet_title := Label.new()
	bet_title.text = "베팅 구역 선택"
	bet_title.add_theme_font_size_override("font_size", 11)
	bet_title.add_theme_color_override("font_color", Color("#7a5a2a"))
	_f(bet_title)
	root_vbox.add_child(bet_title)

	_seg_btns.clear()
	var seg_row := HBoxContainer.new()
	seg_row.add_theme_constant_override("separation", 5)
	root_vbox.add_child(seg_row)
	for i in range(6):
		var lbl_str: String  = str(SEG_LABELS[i])
		var pay_val: float   = float(SEG_PAYOUTS[i])
		var slots_n: int     = int(SEG_SLOTS[i])
		var btn_text: String
		if i == 5:
			btn_text = "JOKER\n(%.0f:1)\n%d칸" % [pay_val, slots_n]
		else:
			btn_text = "%s배당\n(%.0f:1)\n%d칸" % [lbl_str, pay_val, slots_n]
		var btn := _make_seg_btn(btn_text, i)
		_seg_btns.append(btn)
		seg_row.add_child(btn)

	# ── 스테이크 버튼 ──
	var stake_title := Label.new()
	stake_title.text = "베팅 금액"
	stake_title.add_theme_font_size_override("font_size", 11)
	stake_title.add_theme_color_override("font_color", Color("#7a5a2a"))
	_f(stake_title)
	root_vbox.add_child(stake_title)

	_stake_btns.clear()
	var stake_row := HBoxContainer.new()
	stake_row.add_theme_constant_override("separation", 5)
	root_vbox.add_child(stake_row)
	for s in STAKE_OPTIONS:
		var captured_s: int    = s
		var selected_now: bool = (s == _stake)
		var sb := _make_btn(
			GameState.format_money(float(s)),
			func(): _select_stake(captured_s),
			"#2a1a0a" if selected_now else "#100a04",
			"#f39c12" if selected_now else "#2a1a08"
		)
		_apply_chip_icon(sb, captured_s, 20)
		sb.custom_minimum_size = Vector2(94, 34)
		_f(sb)
		_stake_btns.append({"btn": sb, "amount": s})
		stake_row.add_child(sb)

	# ── 스핀 + 나가기 버튼 ──
	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 8)
	root_vbox.add_child(action_row)

	_spin_btn = _make_btn("SPIN", _do_spin, "#0a2a0a", "#27ae60")
	_spin_btn.custom_minimum_size = Vector2(0, 50)
	_spin_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if _font_bold: _spin_btn.add_theme_font_override("font", _font_bold)
	_spin_btn.add_theme_font_size_override("font_size", 18)
	action_row.add_child(_spin_btn)

	var help_btn := _make_btn("규칙", func(): TutorialOverlay.force_show("bigwheel", self), "#0a0a1a", "#5a4510")
	help_btn.custom_minimum_size = Vector2(64, 50)
	_f(help_btn)
	action_row.add_child(help_btn)

	var exit_btn := _make_btn("나가기", _on_exit, "#1a0e0e", "#5a2a2a")
	exit_btn.custom_minimum_size = Vector2(90, 50)
	_f(exit_btn)
	action_row.add_child(exit_btn)

	# ── 최근 결과 ──
	var hist_title := Label.new()
	hist_title.text = "최근 결과"
	hist_title.add_theme_font_size_override("font_size", 11)
	hist_title.add_theme_color_override("font_color", Color("#5a3a1a"))
	_f(hist_title)
	root_vbox.add_child(hist_title)

	_history_box = HBoxContainer.new()
	_history_box.add_theme_constant_override("separation", 5)
	root_vbox.add_child(_history_box)

	# ── 잔액 ──
	_balance_lbl = Label.new()
	_balance_lbl.text = ""
	_balance_lbl.add_theme_font_size_override("font_size", 14)
	_balance_lbl.add_theme_color_override("font_color", Color("#f0b429"))
	_balance_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if _font_bold: _balance_lbl.add_theme_font_override("font", _font_bold)
	root_vbox.add_child(_balance_lbl)

	# ── 플래시 메시지 ──
	_msg_lbl = Label.new()
	_msg_lbl.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_msg_lbl.offset_top = -38
	_msg_lbl.offset_bottom = -8
	_msg_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if _font_bold: _msg_lbl.add_theme_font_override("font", _font_bold)
	_msg_lbl.add_theme_font_size_override("font_size", 17)
	_msg_lbl.visible = false
	add_child(_msg_lbl)

# ── 휠 드로우 콜백 ────────────────────────────────────────────
func _on_wheel_draw() -> void:
	if not is_instance_valid(_wheel_ctrl):
		return
	var sz: Vector2 = _wheel_ctrl.size
	var cx: float   = sz.x * 0.5
	var cy: float   = sz.y * 0.5
	var r: float    = minf(WHEEL_RADIUS, minf(cx, cy) - 22.0)
	if r < 20.0:
		return

	var slot_angle: float = TAU / float(TOTAL_SLOTS)
	var f: Font = _font if _font else ThemeDB.fallback_font
	var seg_start_slot: int = 0

	for seg in range(6):
		var seg_count: int   = int(SEG_SLOTS[seg])
		var col_hex: String  = str(SEG_COLORS[seg])
		var seg_col: Color   = Color(col_hex)
		var lbl_str: String  = str(SEG_LABELS[seg])

		# 결과 세그먼트 플래시
		var is_result: bool = (_phase == Phase.RESULT and seg == _result_seg and _result_seg >= 0)
		if is_result and _flash_winner_active:
			seg_col = seg_col.lightened(0.45 * _flash_winner_bright)
		elif is_result and _flash_timer > 0.0:
			seg_col = seg_col.lightened(0.45)

		# 슬롯별 부채꼴 그리기
		for slot_i in range(seg_count):
			var a0: float = _wheel_angle + float(seg_start_slot + slot_i) * slot_angle
			var a1: float = a0 + slot_angle
			var steps: int = 4
			var points := PackedVector2Array()
			points.append(Vector2(cx, cy))
			for step in range(steps + 1):
				var a: float = lerp(a0, a1, float(step) / float(steps))
				points.append(Vector2(cx + cos(a) * r, cy + sin(a) * r))
			_wheel_ctrl.draw_colored_polygon(points, seg_col)

		# 당첨 세그먼트 — 외곽 하이라이트 아크
		if is_result:
			var arc_a0: float = _wheel_angle + float(seg_start_slot) * slot_angle
			var arc_a1: float = _wheel_angle + float(seg_start_slot + seg_count) * slot_angle
			_wheel_ctrl.draw_arc(Vector2(cx, cy), r * 0.96, arc_a0, arc_a1, 16, Color(1.0, 1.0, 1.0, 0.85), 3.5)

		# 세그먼트 구분선
		var div_a: float = _wheel_angle + float(seg_start_slot) * slot_angle
		var lx: float    = cx + cos(div_a) * r
		var ly: float    = cy + sin(div_a) * r
		_wheel_ctrl.draw_line(Vector2(cx, cy), Vector2(lx, ly), Color(0.05, 0.05, 0.05, 0.85), 2.0)

		# 세그먼트 레이블 (중앙)
		var mid_slot_f: float = float(seg_start_slot) + float(seg_count) * 0.5
		var mid_a: float = _wheel_angle + mid_slot_f * slot_angle
		var lr: float    = r * 0.68
		var lx2: float   = cx + cos(mid_a) * lr
		var ly2: float   = cy + sin(mid_a) * lr
		var fs: int      = 12 if lbl_str.length() <= 2 else 9
		_wheel_ctrl.draw_string(f,
			Vector2(lx2 - float(fs) * float(lbl_str.length()) * 0.28, ly2 + float(fs) * 0.4),
			lbl_str, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)

		seg_start_slot += seg_count

	# 외곽 테두리
	_wheel_ctrl.draw_arc(Vector2(cx, cy), r, 0.0, TAU, 64, Color("#8a6a3a"), 3.0)

	# 허브 (중심)
	_wheel_ctrl.draw_circle(Vector2(cx, cy), 16.0, Color("#0a0804"))
	_wheel_ctrl.draw_arc(Vector2(cx, cy), 16.0, 0.0, TAU, 32, Color("#f39c12"), 2.0)

	# 포인터 (위쪽 삼각형) — _pointer_scale로 pulse 크기 적용
	var ps: float  = _pointer_scale
	var base_w: float = 10.0 * ps
	var base_h: float = 18.0 * ps
	var pt_tip := Vector2(cx, cy - r - 4.0 * ps)
	var pt_l   := Vector2(cx - base_w, cy - r + base_h - 4.0 * ps)
	var pt_r   := Vector2(cx + base_w, cy - r + base_h - 4.0 * ps)
	_wheel_ctrl.draw_colored_polygon(PackedVector2Array([pt_tip, pt_l, pt_r]), Color("#e74c3c"))
	_wheel_ctrl.draw_polyline(PackedVector2Array([pt_tip, pt_l, pt_r, pt_tip]), Color(1, 1, 1, 0.7), 1.5 * ps)

	# 스핀 중 / 결과 텍스트
	if _phase == Phase.SPINNING:
		_wheel_ctrl.draw_string(f, Vector2(cx - 35.0, cy + r + 22.0),
			"스핀 중...", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#f0b429"))
	elif _phase == Phase.RESULT and _result_seg >= 0:
		var rl: String  = str(SEG_LABELS[_result_seg])
		var rc: Color   = Color(str(SEG_COLORS[_result_seg]))
		_wheel_ctrl.draw_string(f, Vector2(cx - 28.0, cy + r + 22.0),
			"결과: %s" % rl, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, rc)

# ── 리프레시 ──────────────────────────────────────────────────
func _refresh() -> void:
	_refresh_hud()
	_refresh_seg_btns()
	_refresh_stake_btns()
	_refresh_history()
	_refresh_spin_btn()
	_refresh_balance()

func _refresh_hud() -> void:
	var phase_str: String = ""
	if _phase == Phase.SPINNING:
		phase_str = "   [color=#f0b429]스핀 중...[/color]"
	_hud_lbl.text = (
		"[b]빅휠[/b]   |   현금 [b]%s[/b]   |   %d라운드   W[color=#3de87a]%d[/color] L[color=#e85d5d]%d[/color]   손익 [b]%s[/b]%s"
		% [
			GameState.format_money(GameState.money),
			_rounds, _wins, _losses,
			("+%s" % GameState.format_money(_net)) if _net >= 0 else GameState.format_money(_net),
			phase_str
		]
	)

func _refresh_seg_btns() -> void:
	for i in range(_seg_btns.size()):
		var btn: Button = _seg_btns[i]
		if not is_instance_valid(btn):
			continue
		var selected: bool   = (i == _bet_segment)
		var is_result_seg: bool = (_phase == Phase.RESULT and i == _result_seg and _result_seg >= 0)
		var col_hex: String  = str(SEG_COLORS[i])
		var seg_col: Color   = Color(col_hex)
		var st := StyleBoxFlat.new()
		if is_result_seg:
			st.bg_color = seg_col.lightened(0.25)
			st.border_color = Color("#ffffff")
			st.set_border_width_all(4)
		elif selected:
			st.bg_color = seg_col.darkened(0.25)
			st.border_color = Color("#f39c12")
			st.set_border_width_all(3)
		else:
			st.bg_color = seg_col.darkened(0.60)
			st.border_color = seg_col.darkened(0.1)
			st.set_border_width_all(1)
		st.set_corner_radius_all(8)
		st.content_margin_left = 8; st.content_margin_right = 8
		st.content_margin_top = 8; st.content_margin_bottom = 8
		var hov := st.duplicate() as StyleBoxFlat
		hov.bg_color = seg_col.darkened(0.40)
		btn.add_theme_stylebox_override("normal", st)
		btn.add_theme_stylebox_override("hover", hov)
		btn.add_theme_stylebox_override("pressed", hov)
		btn.add_theme_color_override("font_color", Color.WHITE if (selected or is_result_seg) else Color(1, 1, 1, 0.65))

func _refresh_stake_btns() -> void:
	for entry in _stake_btns:
		var btn: Button = entry["btn"]
		var amount: int = entry["amount"]
		if not is_instance_valid(btn):
			continue
		var sel: bool = (amount == _stake)
		var st := StyleBoxFlat.new()
		st.bg_color = Color("#2a1a0a") if sel else Color("#100a04")
		st.border_color = Color("#f39c12") if sel else Color("#2a1a08")
		st.set_border_width_all(2 if sel else 1)
		st.set_corner_radius_all(6)
		st.content_margin_left = 8; st.content_margin_right = 8
		st.content_margin_top = 6; st.content_margin_bottom = 6
		var hov := st.duplicate() as StyleBoxFlat
		hov.bg_color = (Color("#2a1a0a") if sel else Color("#100a04")).lightened(0.1)
		btn.add_theme_stylebox_override("normal", st)
		btn.add_theme_stylebox_override("hover", hov)
		btn.add_theme_stylebox_override("pressed", hov)
		btn.add_theme_color_override("font_color", Color("#f0b429") if sel else Color("#8a6a3a"))

func _refresh_spin_btn() -> void:
	if not is_instance_valid(_spin_btn):
		return
	var can_spin: bool = (_phase == Phase.IDLE and _bet_segment >= 0 and int(GameState.money) >= _stake)
	_spin_btn.disabled = not can_spin
	var st := StyleBoxFlat.new()
	if can_spin:
		st.bg_color = Color("#0a2a0a")
		st.border_color = Color("#27ae60")
		st.set_border_width_all(2)
	else:
		st.bg_color = Color("#0e140e")
		st.border_color = Color("#1a2a1a")
		st.set_border_width_all(1)
	st.set_corner_radius_all(8)
	st.content_margin_left = 14; st.content_margin_right = 14
	st.content_margin_top = 10; st.content_margin_bottom = 10
	var hov := st.duplicate() as StyleBoxFlat
	hov.bg_color = Color("#0a2a0a").lightened(0.15)
	var dis := StyleBoxFlat.new()
	dis.bg_color = Color("#0e140e"); dis.border_color = Color("#1a2a1a")
	dis.set_border_width_all(1); dis.set_corner_radius_all(8)
	dis.content_margin_left = 14; dis.content_margin_right = 14
	dis.content_margin_top = 10; dis.content_margin_bottom = 10
	_spin_btn.add_theme_stylebox_override("normal", st)
	_spin_btn.add_theme_stylebox_override("hover", hov)
	_spin_btn.add_theme_stylebox_override("pressed", hov)
	_spin_btn.add_theme_stylebox_override("disabled", dis)

func _refresh_history() -> void:
	for c in _history_box.get_children():
		c.queue_free()
	for seg_idx in _history:
		var col_hex: String  = str(SEG_COLORS[seg_idx])
		var lbl_str: String  = str(SEG_LABELS[seg_idx])
		var chip_panel := PanelContainer.new()
		chip_panel.custom_minimum_size = Vector2(36, 36)
		var cst := StyleBoxFlat.new()
		cst.bg_color = Color(col_hex).darkened(0.15)
		cst.border_color = Color(col_hex).lightened(0.3)
		cst.set_border_width_all(1)
		cst.set_corner_radius_all(18)
		chip_panel.add_theme_stylebox_override("panel", cst)
		var lbl := Label.new()
		lbl.text = lbl_str
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
		lbl.add_theme_font_size_override("font_size", 11)
		lbl.add_theme_color_override("font_color", Color.WHITE)
		if _font: lbl.add_theme_font_override("font", _font)
		chip_panel.add_child(lbl)
		_history_box.add_child(chip_panel)

func _refresh_balance() -> void:
	if is_instance_valid(_balance_lbl):
		_balance_lbl.text = "잔액: %s   |   베팅: %s" % [
			GameState.format_money(GameState.money),
			GameState.format_money(float(_stake))
		]

# ── UI 헬퍼 ──────────────────────────────────────────────────
func _segment_display_label(seg: int) -> String:
	if seg == 5:
		return "JOKER"
	if seg >= 0 and seg < SEG_LABELS.size():
		return str(SEG_LABELS[seg])
	return "?"

func _apply_chip_icon(btn: Button, stake: int, max_width: int) -> void:
	if not CHIP_TEX_BY_STAKE.has(stake):
		return
	btn.icon = CHIP_TEX_BY_STAKE[stake]
	btn.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.expand_icon = false
	btn.add_theme_constant_override("h_separation", 6)
	btn.add_theme_constant_override("icon_max_width", max_width)

func _make_seg_btn(label_text: String, seg: int) -> Button:
	var col_hex: String  = str(SEG_COLORS[seg])
	var seg_col: Color   = Color(col_hex)
	var btn := Button.new()
	btn.text = label_text
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(0, 68)
	var st := StyleBoxFlat.new()
	st.bg_color = seg_col.darkened(0.60)
	st.border_color = seg_col.darkened(0.1)
	st.set_border_width_all(1)
	st.set_corner_radius_all(8)
	st.content_margin_left = 8; st.content_margin_right = 8
	st.content_margin_top = 8; st.content_margin_bottom = 8
	var hov := st.duplicate() as StyleBoxFlat
	hov.bg_color = seg_col.darkened(0.40)
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_stylebox_override("hover", hov)
	btn.add_theme_stylebox_override("pressed", hov)
	btn.add_theme_color_override("font_color", Color(1, 1, 1, 0.65))
	btn.add_theme_font_size_override("font_size", 12)
	if _font: btn.add_theme_font_override("font", _font)
	btn.pressed.connect(func(): _select_segment(seg))
	return btn

func _make_btn(label_text: String, cb: Callable, bg: String, border: String) -> Button:
	var btn := Button.new()
	btn.text = label_text
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color(bg)
	st.border_color = Color(border)
	st.set_border_width_all(1)
	st.set_corner_radius_all(6)
	st.content_margin_left = 12; st.content_margin_right = 12
	st.content_margin_top = 8; st.content_margin_bottom = 8
	var hov := st.duplicate() as StyleBoxFlat
	hov.bg_color = Color(bg).lightened(0.12)
	var dis := StyleBoxFlat.new()
	dis.bg_color = Color("#100a04"); dis.border_color = Color("#1a1008")
	dis.set_border_width_all(1); dis.set_corner_radius_all(6)
	dis.content_margin_left = 12; dis.content_margin_right = 12
	dis.content_margin_top = 8; dis.content_margin_bottom = 8
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_stylebox_override("hover", hov)
	btn.add_theme_stylebox_override("pressed", hov)
	btn.add_theme_stylebox_override("disabled", dis)
	btn.add_theme_color_override("font_color", Color("#dce4f0"))
	btn.add_theme_color_override("font_disabled_color", Color("#3a3a2a"))
	btn.add_theme_font_size_override("font_size", 14)
	if _font: btn.add_theme_font_override("font", _font)
	btn.pressed.connect(cb)
	return btn

func _flash_msg(msg: String, color: String) -> void:
	if not is_instance_valid(_msg_lbl):
		return
	_msg_lbl.text = msg
	_msg_lbl.add_theme_color_override("font_color", Color(color))
	_msg_lbl.visible = true
	get_tree().create_timer(2.2).timeout.connect(func():
		if is_instance_valid(_msg_lbl): _msg_lbl.visible = false)
