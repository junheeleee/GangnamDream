extends Control
## BaccaratTable — 정선 카지노 바카라 테이블.
## Baccarat 수학 모델 위에 베팅·카드공개·로드맵·페어베팅·커미션 UI 구현.
## MainGame이 overlay로 붙이고 open()으로 호출. 닫으면 closed 시그널.

signal closed

const BAC := preload("res://systems/Baccarat.gd")
const CARD_BACK_TEX := preload("res://assets/ui/card_back.png")
const CARD_FRONT_TEX := preload("res://assets/ui/card_front_base.svg")
const CHIP_TEX_BY_STAKE := {
	10_000: preload("res://assets/ui/chips/chip_10k.svg"),
	50_000: preload("res://assets/ui/chips/chip_50k.svg"),
	100_000: preload("res://assets/ui/chips/chip_100k.svg"),
	500_000: preload("res://assets/ui/chips/chip_500k.svg"),
	1_000_000: preload("res://assets/ui/chips/chip_1m.svg"),
}

enum Phase { BETTING, DEALING, RESULT }

const PAYOUT_PLAYER  := 1.0    # 1:1
const PAYOUT_BANKER  := 0.95   # 0.95:1 (5% 커미션)
const PAYOUT_TIE     := 8.0    # 8:1
const PAYOUT_PAIR    := 11.0   # 11:1

const STAKE_OPTIONS  := [10_000, 50_000, 100_000, 500_000, 1_000_000]
const ROAD_MAX       := 36     # 로드맵 최대 기록 수
const REVEAL_DELAY   := 0.45   # 카드당 공개 딜레이(초)
const SHOE_CUT       := 0.25   # 남은 슈 비율 < 25%면 리셔플
const JOY_BUTTON_WEST := 2
const JOY_BUTTON_NORTH := 3
const PAD_TARGETS := ["P", "B", "T", "PP", "BP", "DEAL"]

# ── 상태 ──────────────────────────────────────────────────────
var _phase: int      = Phase.BETTING
var _shoe: Array     = []
var _result: Dictionary = {}

var _bet_p: int   = 0   # 플레이어 베팅
var _bet_b: int   = 0   # 뱅커 베팅
var _bet_t: int   = 0   # 타이 베팅
var _bet_pp: int  = 0   # 플레이어 페어
var _bet_bp: int  = 0   # 뱅커 페어

var _active_stake: int = 100_000  # 클릭당 추가 금액
var _commission: float = 0.0      # 누적 미납 커미션(뱅커 승)
var _pad_cursor_idx: int = 0
var _pad_navigation_active: bool = false

var _road: Array   = []   # Array of "P"/"B"/"T"
var _rounds: int   = 0
var _net: float    = 0.0
var _p_wins: int   = 0
var _b_wins: int   = 0
var _ties:  int    = 0

# 딜 애니메이션
var _deal_seq: Array   = []   # [{side, card}]
var _deal_idx: int     = 0
var _deal_p_visible: Array = []
var _deal_b_visible: Array = []
var _deal_timer: float = 0.0

var _rng := RandomNumberGenerator.new()

# UI
var _font: FontFile
var _font_bold: FontFile
var _content_root: Control
var _road_ctrl: Control
var _msg_lbl: Label
var _hud_lbl: RichTextLabel
var _flash_layer: ColorRect

# 로드맵 fade 제어
var _road_last_count: int = 0  # 직전 렌더 시 road 크기 (새 항목 감지용)

# ── 초기화 ────────────────────────────────────────────────────
func _ready() -> void:
	_rng.randomize()
	_load_fonts()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_skeleton()
	visible = false
	set_process(false)

func _load_fonts() -> void:
	_font      = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile

func _f(n, bold := false) -> void:
	var ft = _font_bold if bold else _font
	if ft and n:
		n.add_theme_font_override("font", ft)
		if n is RichTextLabel:
			n.add_theme_font_override("normal_font", ft)
			n.add_theme_font_override("bold_font", _font_bold if _font_bold else ft)

func _tr(ko: String, en: String) -> String:
	return LocaleManager.ui(ko, en)

# ── 진입/종료 ──────────────────────────────────────────────────
func open() -> void:
	_shoe = BAC.new_shoe(_rng)
	_road = []
	_rounds = 0; _net = 0.0; _p_wins = 0; _b_wins = 0; _ties = 0
	_commission = 0.0
	_pad_cursor_idx = 0
	_pad_navigation_active = false
	_reset_bets()
	_phase = Phase.BETTING
	visible = true
	TutorialOverlay.maybe_show("baccarat", self)
	set_process(false)
	_render()
	AudioManager.play("tab_open")

func _on_exit() -> void:
	# 커미션 정산
	if _commission > 0.0:
		GameState.add_money(-_commission)
		GameState.add_log(_tr("바카라 커미션 정산 -%s", "Baccarat commission paid -%s") % GameState.format_money(_commission), "money")
	MetaProgression.record_minigame_play("baccarat")
	set_process(false)
	visible = false
	closed.emit()

func _reset_bets() -> void:
	_bet_p = 0; _bet_b = 0; _bet_t = 0; _bet_pp = 0; _bet_bp = 0

# ── 딜 애니메이션 ──────────────────────────────────────────────
func _process(delta: float) -> void:
	if _phase != Phase.DEALING:
		return
	_deal_timer -= delta
	if _deal_timer > 0.0:
		return
	_deal_timer = REVEAL_DELAY
	if _deal_idx >= _deal_seq.size():
		set_process(false)
		_finish_result()
		return
	var step: Dictionary = _deal_seq[_deal_idx]
	if step["side"] == "player":
		_deal_p_visible.append(step["card"])
		_show_table_banner("PLAYER CARD", Color("#d4a020"), 0.28)
	else:
		_deal_b_visible.append(step["card"])
		_show_table_banner("BANKER CARD", Color("#e85d5d"), 0.28)
	_deal_idx += 1
	AudioManager.play("casino_card")
	_render()
	_screen_flash(Color("#d4a020") if step["side"] == "player" else Color("#e85d5d"), 0.06, 0.14)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey:
		var key := event as InputEventKey
		if key.echo:
			return

	var pad_navigation_event := event.is_action_pressed("gd_tab_prev") \
			or event.is_action_pressed("gd_tab_next") \
			or event.is_action_pressed("ui_left") \
			or event.is_action_pressed("ui_right") \
			or event.is_action_pressed("ui_up") \
			or event.is_action_pressed("ui_down") \
			or event.is_action_pressed("ui_accept") \
			or event.is_action_pressed("ui_cancel") \
			or _joy_button_pressed(event, JOY_BUTTON_WEST) \
			or _joy_button_pressed(event, JOY_BUTTON_NORTH)
	if pad_navigation_event:
		_pad_navigation_active = true

	var handled := false
	if event.is_action_pressed("gd_tab_prev"):
		handled = _pad_cycle_target(-1)
	elif event.is_action_pressed("gd_tab_next"):
		handled = _pad_cycle_target(1)
	elif event.is_action_pressed("ui_left"):
		handled = _pad_move(-1, 0)
	elif event.is_action_pressed("ui_right"):
		handled = _pad_move(1, 0)
	elif event.is_action_pressed("ui_up"):
		handled = _pad_move(0, -1)
	elif event.is_action_pressed("ui_down"):
		handled = _pad_move(0, 1)
	elif event.is_action_pressed("ui_accept"):
		handled = _pad_accept()
	elif event.is_action_pressed("ui_cancel"):
		handled = _pad_cancel()
	elif _joy_button_pressed(event, JOY_BUTTON_WEST):
		handled = _pad_cycle_stake(1)
	elif _joy_button_pressed(event, JOY_BUTTON_NORTH):
		handled = _pad_show_rules()

	if handled:
		get_viewport().set_input_as_handled()

func _joy_button_pressed(event: InputEvent, button_index: int) -> bool:
	if not (event is InputEventJoypadButton):
		return false
	var joy := event as InputEventJoypadButton
	return joy.pressed and int(joy.button_index) == button_index

func _pad_cycle_target(direction: int) -> bool:
	if _phase == Phase.DEALING:
		return true
	if _phase == Phase.RESULT:
		return true
	_pad_cursor_idx = int(posmod(_pad_cursor_idx + direction, PAD_TARGETS.size()))
	AudioManager.play_ui_click()
	_render()
	_flash(_tr("커서: %s", "Cursor: %s") % _pad_target_label(), "#d8dbe8")
	return true

func _pad_move(dx: int, dy: int) -> bool:
	if _phase != Phase.BETTING:
		return true
	if dx != 0:
		if _pad_cursor_idx <= 2:
			_pad_cursor_idx = int(posmod(_pad_cursor_idx + dx, 3))
		elif _pad_cursor_idx <= 4:
			_pad_cursor_idx = 3 + int(posmod(_pad_cursor_idx - 3 + dx, 2))
	elif dy != 0:
		if dy > 0:
			if _pad_cursor_idx <= 0:
				_pad_cursor_idx = 3
			elif _pad_cursor_idx <= 2:
				_pad_cursor_idx = 4
			elif _pad_cursor_idx <= 4:
				_pad_cursor_idx = 5
		else:
			if _pad_cursor_idx == 5:
				_pad_cursor_idx = 1
			elif _pad_cursor_idx == 3:
				_pad_cursor_idx = 0
			elif _pad_cursor_idx == 4:
				_pad_cursor_idx = 1
	AudioManager.play_ui_click()
	_render()
	_flash(_tr("커서: %s", "Cursor: %s") % _pad_target_label(), "#d8dbe8")
	return true

func _pad_accept() -> bool:
	match _phase:
		Phase.DEALING:
			return true
		Phase.RESULT:
			_next_round()
			return true
	var target := _pad_target()
	if target == "DEAL":
		_deal()
	else:
		_add_bet(target)
	return true

func _pad_cancel() -> bool:
	if _phase == Phase.DEALING:
		return true
	if _phase == Phase.RESULT:
		_on_exit()
		return true
	if _total_bet() > 0:
		_clear_bets()
	else:
		_on_exit()
	return true

func _pad_cycle_stake(direction: int) -> bool:
	if _phase != Phase.BETTING:
		return true
	var idx := STAKE_OPTIONS.find(_active_stake)
	if idx < 0:
		idx = 2
	idx = int(posmod(idx + direction, STAKE_OPTIONS.size()))
	_set_stake(int(STAKE_OPTIONS[idx]))
	_flash(_tr("베팅 단위: %s", "Stake: %s") % GameState.format_money(float(_active_stake)), "#d8dbe8")
	return true

func _pad_show_rules() -> bool:
	if _phase == Phase.DEALING:
		return true
	AudioManager.play_ui_open()
	TutorialOverlay.force_show("baccarat", self)
	return true

func _pad_target() -> String:
	return str(PAD_TARGETS[_pad_cursor_idx])

func _pad_target_label() -> String:
	match _pad_target():
		"P":
			return _tr("플레이어", "Player")
		"B":
			return _tr("뱅커", "Banker")
		"T":
			return _tr("타이", "Tie")
		"PP":
			return _tr("플레이어 페어", "Player Pair")
		"BP":
			return _tr("뱅커 페어", "Banker Pair")
		"DEAL":
			return _tr("딜 시작", "Deal")
	return ""

func _should_show_pad_cursor() -> bool:
	return _pad_navigation_active or ControllerHints.is_pad_active()

# ── 베팅 배치 ──────────────────────────────────────────────────
func _add_bet(type: String) -> void:
	var add: int = _active_stake
	if GameState.money < float(add + _total_bet()):
		_flash(_tr("현금 부족", "Insufficient cash"), "#e85d5d"); return
	match type:
		"P":  _bet_p  += add
		"B":  _bet_b  += add
		"T":  _bet_t  += add
		"PP": _bet_pp += add
		"BP": _bet_bp += add
	AudioManager.play("casino_bet")
	AudioManager.play_delayed("casino_coin", 0.08, -5.0)
	AudioManager.pulse_gamepad(0.06, 0.12, 0.06)
	_spawn_bet_chip(type, add)
	_show_table_banner("BET  %s" % type, Color("#f0b429"), 0.22)
	_render()

func _clear_bets() -> void:
	_reset_bets()
	AudioManager.play("click")
	_render()

func _total_bet() -> int:
	return _bet_p + _bet_b + _bet_t + _bet_pp + _bet_bp

# ── 딜 시작 ────────────────────────────────────────────────────
func _deal() -> void:
	if _total_bet() == 0:
		_flash(_tr("베팅을 먼저 해주세요", "Place a bet first"), "#e8c45d"); return
	if GameState.money < float(_total_bet()):
		_flash(_tr("현금 부족", "Insufficient cash"), "#e85d5d"); return

	# 슈 리셔플 체크
	if BAC.shoe_remaining_ratio(_shoe) < SHOE_CUT:
		_shoe = BAC.new_shoe(_rng)
		_flash(_tr("🔀 슈 리셔플", "🔀 Shoe reshuffled"), "#d4a020")

	GameState.add_money(-float(_total_bet()))
	_result = BAC.play(_shoe)
	if _result.is_empty():
		_shoe = BAC.new_shoe(_rng)
		_result = BAC.play(_shoe)

	# 딜 시퀀스: 플1 뱅1 플2 뱅2 (+3번째)
	var full_p: Array = _result["player"]
	var full_b: Array = _result["banker"]
	_deal_seq = []
	_deal_seq.append({"side": "player", "card": full_p[0]})
	_deal_seq.append({"side": "banker", "card": full_b[0]})
	_deal_seq.append({"side": "player", "card": full_p[1]})
	_deal_seq.append({"side": "banker", "card": full_b[1]})
	if full_p.size() == 3:
		_deal_seq.append({"side": "player", "card": full_p[2]})
	if full_b.size() == 3:
		_deal_seq.append({"side": "banker", "card": full_b[2]})

	_deal_p_visible = []
	_deal_b_visible = []
	_deal_idx = 0
	_deal_timer = 0.1
	_phase = Phase.DEALING
	AudioManager.play("event_new")
	AudioManager.pulse_gamepad(0.08, 0.18, 0.10)
	set_process(true)
	_render()
	_show_table_banner("NO MORE BETS", Color("#f0b429"), 0.52)
	_screen_flash(Color("#f0b429"), 0.12, 0.26)

# ── 결과 정산 ──────────────────────────────────────────────────
func _finish_result() -> void:
	_phase = Phase.RESULT
	var res: String = str(_result.get("result", ""))
	var gain: float = 0.0

	match res:
		"player":
			gain += float(_bet_p) * PAYOUT_PLAYER
			if _bet_b > 0:   gain -= 0.0   # 뱅커 베팅 손실 (이미 차감)
			if _bet_t > 0:   gain -= 0.0
			_p_wins += 1
		"banker":
			var bwin := float(_bet_b) * PAYOUT_BANKER
			gain += bwin
			var comm := float(_bet_b) * 0.05
			_commission += comm
			if _bet_p > 0: gain -= 0.0
			if _bet_t > 0: gain -= 0.0
			_b_wins += 1
		"tie":
			gain += float(_bet_t) * PAYOUT_TIE
			gain += float(_bet_p)  # 타이 시 P/B 베팅 환불
			gain += float(_bet_b)
			_ties += 1

	# 원금 돌려받기
	match res:
		"player": gain += float(_bet_p)
		"banker": gain += float(_bet_b)

	# 페어 정산 (독립)
	if _result.get("p_pair", false) and _bet_pp > 0:
		gain += float(_bet_pp) * (PAYOUT_PAIR + 1.0)
	if _result.get("b_pair", false) and _bet_bp > 0:
		gain += float(_bet_bp) * (PAYOUT_PAIR + 1.0)

	if gain > 0:
		GameState.add_money(gain)
	var net_round := gain - float(_total_bet())
	_net += net_round
	_rounds += 1

	# 도박 성향 + SFX
	var is_win := net_round > 0
	var has_pair_win: bool = (bool(_result.get("p_pair", false)) and _bet_pp > 0) or (bool(_result.get("b_pair", false)) and _bet_bp > 0)
	if is_win:
		GameState.modify_hidden_stat("gambling_tendency", 2)
		AudioManager.play_casino_result(net_round, float(_total_bet()), res == "tie" or has_pair_win)
	else:
		GameState.modify_hidden_stat("addiction_tendency", 2)
		AudioManager.play_casino_result(net_round, float(_total_bet()))

	# 내추럴 배너
	var player_natural: bool = bool(_result.get("player_natural", false))
	var banker_natural: bool = bool(_result.get("banker_natural", false))
	if player_natural or banker_natural:
		var nat_val: int = int(_result.get("player_val" if player_natural else "banker_val", 0))
		_show_natural_banner(nat_val)

	# 로드맵 업데이트
	_road_last_count = _road.size()
	_road.append(res.substr(0, 1).to_upper())  # P/B/T
	if _road.size() > ROAD_MAX:
		_road.pop_front()
	_start_road_fade()

	GameState.add_log(_tr("바카라 %s%s %s", "Baccarat %s%s %s") % [
		res, _tr(" 내추럴", " natural") if (res == "player" and bool(_result.get("player_natural", false))) or
			(res == "banker" and bool(_result.get("banker_natural", false))) else "",
		("+%s" % GameState.format_money(net_round)) if net_round >= 0 else
		GameState.format_money(net_round)], "money")

	GameState.stats_changed.emit()
	_render()
	var res_ko := {"player": "PLAYER WINS", "banker": "BANKER WINS", "tie": "TIE"}
	var res_col := {"player": Color("#d4a020"), "banker": Color("#e85d5d"), "tie": Color("#f0b429")}
	var banner_text: String = str(res_ko.get(res, res))
	if net_round > 0.0:
		banner_text += "  +%s" % GameState.format_money(net_round)
	elif net_round < 0.0:
		banner_text += "  %s" % GameState.format_money(net_round)
	_show_table_banner(banner_text, res_col.get(res, Color("#e8eaf0")), 0.78)
	_screen_flash(res_col.get(res, Color("#e8eaf0")), 0.18, 0.36)
	if net_round < 0.0:
		_shake_node(_content_root, 8.0, 0.26)
	else:
		_pulse_node(_content_root, 1.025, 0.26)

# ── 렌더 ──────────────────────────────────────────────────────
func _render() -> void:
	_refresh_hud()
	_clear_content()
	match _phase:
		Phase.BETTING:  _render_betting()
		Phase.DEALING:  _render_dealing()
		Phase.RESULT:   _render_result_screen()
	_refresh_road()

func _refresh_hud() -> void:
	var shoe_pct: int = roundi(BAC.shoe_remaining_ratio(_shoe) * 100.0)
	var comm_str: String = ""
	if _commission > 0.0:
		var hud_comm_col: String = "#f0d020" if _commission >= 100_000.0 else "#e8a05d"
		comm_str = _tr("   커미션 [color=%s]%s[/color]", "   Commission [color=%s]%s[/color]") % [hud_comm_col, GameState.format_money(_commission)]
	_hud_lbl.text = _tr("[b]현금 %s[/b]   |   %d라운드   W%d B%d T%d   손익 [b]%s[/b]   슈 %d%%%s", "[b]Cash %s[/b]   |   Round %d   W%d B%d T%d   P/L [b]%s[/b]   Shoe %d%%%s") % [
		GameState.format_money(GameState.money), _rounds,
		_p_wins, _b_wins, _ties,
		("+%s" % GameState.format_money(_net)) if _net >= 0 else GameState.format_money(_net),
		shoe_pct, comm_str]

func _render_betting() -> void:
	var vb := _make_vbox(12)

	var title := Label.new()
	title.text = _tr("바카라", "Baccarat")
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("#f0b429"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_f(title, true); vb.add_child(title)

	# 베팅 현황
	var bet_rt := RichTextLabel.new()
	bet_rt.bbcode_enabled = true; bet_rt.fit_content = true; bet_rt.scroll_active = false
	bet_rt.custom_minimum_size = Vector2(0, 26)
	_f(bet_rt); bet_rt.add_theme_font_size_override("normal_font_size", 14)
	bet_rt.text = "[center]%s[/center]" % _bet_status_text()
	vb.add_child(bet_rt)

	_add_pad_hint(vb)
	_add_baccarat_betting_mat(vb)

	vb.add_child(_sep())

	# 메인 베팅 버튼 (Player / Banker / Tie)
	var row1 := HBoxContainer.new()
	row1.add_theme_constant_override("separation", 10)
	vb.add_child(row1)
	_add_bet_btn(row1, "PLAYER", _tr("플레이어", "Player"), "P", "#1a2a3a", "#3a6a9a")
	_add_bet_btn(row1, "BANKER", _tr("뱅커", "Banker"), "B", "#2a1a1a", "#9a3a3a")
	_add_bet_btn(row1, "TIE", _tr("타이  (8배)", "Tie  (8x)"), "T", "#1a2a1a", "#3a7a3a")

	# 페어 베팅 (선택)
	var pair_lbl := Label.new()
	pair_lbl.text = _tr("사이드 베팅 (선택)", "Side Bets (optional)")
	pair_lbl.add_theme_font_size_override("font_size", 11)
	pair_lbl.add_theme_color_override("font_color", Color("#4a5a6a"))
	_f(pair_lbl); vb.add_child(pair_lbl)
	var row2 := HBoxContainer.new()
	row2.add_theme_constant_override("separation", 10)
	vb.add_child(row2)
	_add_bet_btn(row2, _tr("플레이어 페어  (11배)", "Player Pair  (11x)"), _tr("PP베팅", "PP Bet"), "PP", "#18141e", "#5a3a7a")
	_add_bet_btn(row2, _tr("뱅커 페어  (11배)", "Banker Pair  (11x)"), _tr("BP베팅", "BP Bet"), "BP", "#18141e", "#7a3a4a")

	vb.add_child(_sep())

	# 베팅 단위 선택
	var stake_lbl := Label.new()
	stake_lbl.text = _tr("베팅 단위 (클릭당)", "Bet Unit (per click)")
	stake_lbl.add_theme_font_size_override("font_size", 11)
	stake_lbl.add_theme_color_override("font_color", Color("#6a7a8a"))
	_f(stake_lbl); vb.add_child(stake_lbl)
	var stake_row := HBoxContainer.new()
	stake_row.add_theme_constant_override("separation", 6)
	vb.add_child(stake_row)
	for s in STAKE_OPTIONS:
		var sb := _make_btn(GameState.format_money(float(s)),
			func(): _set_stake(s),
			"#1a2a1a" if s == _active_stake else "#0e141a",
			"#5de89c" if s == _active_stake else "#2a3a4a")
		if CHIP_TEX_BY_STAKE.has(s):
			sb.icon = CHIP_TEX_BY_STAKE[s]
			sb.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
			sb.expand_icon = false
			sb.add_theme_constant_override("h_separation", 6)
			sb.add_theme_constant_override("icon_max_width", 20)
		sb.custom_minimum_size = Vector2(102, 32)
		stake_row.add_child(sb)

	vb.add_child(_sep())

	# 액션
	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 10)
	vb.add_child(action_row)
	var deal_btn := _make_btn(_tr("딜 시작", "Deal"), _deal, "#1a3a1a", "#3de87a")
	deal_btn.custom_minimum_size = Vector2(0, 44)
	deal_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	deal_btn.disabled = (_total_bet() == 0)
	if _should_show_pad_cursor() and _pad_target() == "DEAL":
		_mark_pad_button(deal_btn)
	_f(deal_btn, true); action_row.add_child(deal_btn)
	var clear_btn := _make_btn(_tr("베팅 초기화", "Clear Bets"), _clear_bets, "#1a1a1a", "#4a4a5a")
	clear_btn.custom_minimum_size = Vector2(100, 44)
	action_row.add_child(clear_btn)
	var help_btn := _make_btn(_tr("규칙", "Rules"), func(): TutorialOverlay.force_show("baccarat", self), "#0a0a1a", "#5a4510")
	help_btn.custom_minimum_size = Vector2(60, 44)
	action_row.add_child(help_btn)

	var exit_btn := _make_btn(_tr("나가기", "Exit"), _on_exit, "#1a0e0e", "#5a2a2a")
	exit_btn.custom_minimum_size = Vector2(80, 44)
	action_row.add_child(exit_btn)

	# 규칙 안내
	var rules := RichTextLabel.new()
	rules.bbcode_enabled = true; rules.fit_content = true; rules.scroll_active = false
	_f(rules); rules.add_theme_font_size_override("normal_font_size", 11)
	rules.add_theme_color_override("default_color", Color("#3a4a5a"))
	rules.text = _tr("플레이어 1:1  ·  뱅커 0.95:1(커미션5%)  ·  타이 8:1  ·  페어 11:1  ·  6덱 슈  ·  내추럴(8·9) 시 추가 드로우 없음", "Player 1:1  ·  Banker 0.95:1 (5% commission)  ·  Tie 8:1  ·  Pair 11:1  ·  6-deck shoe  ·  Natural 8/9 stops drawing")
	vb.add_child(rules)

func _render_dealing() -> void:
	var vb := _make_vbox(16)
	_add_table_display(vb, true)
	var dealing_lbl := Label.new()
	dealing_lbl.text = _tr("카드를 배분하는 중...", "Dealing cards...")
	dealing_lbl.add_theme_font_size_override("font_size", 14)
	dealing_lbl.add_theme_color_override("font_color", Color("#7a9abf"))
	dealing_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_f(dealing_lbl); vb.add_child(dealing_lbl)

func _render_result_screen() -> void:
	var vb := _make_vbox(16)
	_add_table_display(vb, false)
	vb.add_child(_sep())

	# 결과 타이틀
	var res := str(_result.get("result", ""))
	var res_ko := {"player": _tr("플레이어 승", "Player Wins"), "banker": _tr("뱅커 승", "Banker Wins"), "tie": _tr("타이!", "Tie!")}
	var res_col := {"player": "#d4a020", "banker": "#e85d5d", "tie": "#f0b429"}
	var nat_str := ""
	if res == "player" and bool(_result.get("player_natural", false)): nat_str = "  [Natural!]"
	elif res == "banker" and bool(_result.get("banker_natural", false)): nat_str = "  [Natural!]"
	var res_lbl := RichTextLabel.new()
	res_lbl.bbcode_enabled = true; res_lbl.fit_content = true; res_lbl.scroll_active = false
	_f(res_lbl, true); res_lbl.add_theme_font_size_override("normal_font_size", 24)
	res_lbl.text = "[color=%s]%s%s[/color]" % [res_col.get(res, "#e8eaf0"), res_ko.get(res, res), nat_str]
	vb.add_child(res_lbl)

	# 페어 결과
	var pair_parts: Array = []
	if bool(_result.get("p_pair", false)): pair_parts.append(_tr("플레이어 페어!", "Player Pair!"))
	if bool(_result.get("b_pair", false)): pair_parts.append(_tr("뱅커 페어!", "Banker Pair!"))
	if not pair_parts.is_empty():
		var pair_lbl := Label.new()
		pair_lbl.text = "  /  ".join(pair_parts)
		pair_lbl.add_theme_font_size_override("font_size", 14)
		pair_lbl.add_theme_color_override("font_color", Color("#d4a0ff"))
		_f(pair_lbl); vb.add_child(pair_lbl)

	# 커미션 안내
	if _commission > 0.0:
		var comm_lbl := Label.new()
		comm_lbl.text = _tr("누적 커미션: %s (나갈 때 정산)", "Accumulated commission: %s (paid on exit)") % GameState.format_money(_commission)
		comm_lbl.add_theme_font_size_override("font_size", 12)
		# 10만원 이상이면 노란색으로 강조
		var comm_color: Color = Color("#f0d020") if _commission >= 100_000.0 else Color("#e8a05d")
		comm_lbl.add_theme_color_override("font_color", comm_color)
		_f(comm_lbl); vb.add_child(comm_lbl)

	vb.add_child(_sep())

	# 버튼
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 10)
	vb.add_child(btn_row)
	var again_btn := _make_btn(_tr("다음 라운드", "Next Round"), _next_round, "#1a2a1a", "#3de87a")
	again_btn.custom_minimum_size = Vector2(0, 48)
	again_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_f(again_btn, true); btn_row.add_child(again_btn)
	var exit_btn := _make_btn(_tr("나가기", "Exit"), _on_exit, "#1a0e0e", "#5a2a2a")
	exit_btn.custom_minimum_size = Vector2(100, 48)
	btn_row.add_child(exit_btn)

func _add_baccarat_betting_mat(parent: VBoxContainer) -> void:
	var mat := Control.new()
	mat.custom_minimum_size = Vector2(860, 162)
	mat.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mat.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mat.draw.connect(func(): _draw_baccarat_betting_mat(mat))
	parent.add_child(mat)

func _draw_baccarat_betting_mat(ctrl: Control) -> void:
	var sz: Vector2 = ctrl.size
	var font: Font = _font if _font else ThemeDB.fallback_font
	var bold: Font = _font_bold if _font_bold else font
	var felt := Rect2(Vector2(8, 8), sz - Vector2(16, 16))
	ctrl.draw_rect(Rect2(felt.position + Vector2(0, 5), felt.size), Color(0, 0, 0, 0.34), true)
	ctrl.draw_rect(felt, Color("#052615"), true)
	ctrl.draw_rect(felt, Color("#d2a341"), false, 2.0)
	ctrl.draw_line(Vector2(sz.x * 0.5, felt.position.y + 14), Vector2(sz.x * 0.5, felt.end.y - 14), Color(1, 1, 1, 0.08), 1.0)
	var player_zone := Rect2(Vector2(34, 34), Vector2(250, 86))
	var tie_zone := Rect2(Vector2((sz.x - 172.0) * 0.5, 24), Vector2(172, 98))
	var banker_zone := Rect2(Vector2(sz.x - 284, 34), Vector2(250, 86))
	_draw_bet_zone(ctrl, player_zone, "PLAYER", _bet_p, Color("#3a7abf"), font, bold)
	_draw_bet_zone(ctrl, tie_zone, "TIE  8:1", _bet_t, Color("#3abf5a"), font, bold)
	_draw_bet_zone(ctrl, banker_zone, "BANKER", _bet_b, Color("#bf3a3a"), font, bold)
	var pp_zone := Rect2(Vector2(48, 126), Vector2(236, 24))
	var bp_zone := Rect2(Vector2(sz.x - 284, 126), Vector2(236, 24))
	_draw_side_bet_strip(ctrl, pp_zone, "PLAYER PAIR 11:1", _bet_pp, Color("#b478ff"), font)
	_draw_side_bet_strip(ctrl, bp_zone, "BANKER PAIR 11:1", _bet_bp, Color("#d47898"), font)
	if _should_show_pad_cursor():
		match _pad_target():
			"P":
				_draw_pad_cursor_zone(ctrl, player_zone)
			"B":
				_draw_pad_cursor_zone(ctrl, banker_zone)
			"T":
				_draw_pad_cursor_zone(ctrl, tie_zone)
			"PP":
				_draw_pad_cursor_zone(ctrl, pp_zone)
			"BP":
				_draw_pad_cursor_zone(ctrl, bp_zone)
	ctrl.draw_string(bold, Vector2(sz.x * 0.5 - 54, 145), "NO COMMISSION ON TABLE UNTIL BANKER WINS",
		HORIZONTAL_ALIGNMENT_CENTER, 108, 8, Color(1, 1, 1, 0.26))

func _draw_pad_cursor_zone(ctrl: Control, rect: Rect2) -> void:
	var cursor_rect := rect.grow(5.0)
	ctrl.draw_rect(cursor_rect, Color(0.95, 0.77, 0.27, 0.13), true)
	ctrl.draw_rect(cursor_rect, Color("#f0b429"), false, 3.0)

func _draw_bet_zone(ctrl: Control, rect: Rect2, label: String, amount: int, col: Color, font: Font, bold: Font) -> void:
	ctrl.draw_rect(rect, Color(0.0, 0.0, 0.0, 0.18), true)
	ctrl.draw_rect(rect, Color(col.r, col.g, col.b, 0.55 if amount > 0 else 0.34), false, 2.0 if amount > 0 else 1.0)
	ctrl.draw_string(bold, rect.position + Vector2(0, 28), label,
		HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 18, col.lightened(0.34))
	var amount_text: String = GameState.format_money(float(amount)) if amount > 0 else _tr("베팅 없음", "No Bet")
	ctrl.draw_string(font, rect.position + Vector2(0, 57), amount_text,
		HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 12, Color("#dce4f0") if amount > 0 else Color(1, 1, 1, 0.30))
	if amount > 0:
		_draw_chip_stack(ctrl, rect.position + Vector2(rect.size.x * 0.5, rect.size.y + 4.0), col)

func _draw_side_bet_strip(ctrl: Control, rect: Rect2, label: String, amount: int, col: Color, font: Font) -> void:
	ctrl.draw_rect(rect, Color(0, 0, 0, 0.20), true)
	ctrl.draw_rect(rect, Color(col.r, col.g, col.b, 0.52 if amount > 0 else 0.28), false, 1.0)
	var text := label
	if amount > 0:
		text += "  " + GameState.format_money(float(amount))
	ctrl.draw_string(font, rect.position + Vector2(8, 16), text,
		HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 16, 10, col.lightened(0.36))

func _draw_chip_stack(ctrl: Control, center: Vector2, col: Color) -> void:
	for i in range(3):
		var p := center + Vector2(float(i - 1) * 14.0, -float(i) * 3.0)
		ctrl.draw_circle(p + Vector2(0, 2), 10.0, Color(0, 0, 0, 0.34))
		ctrl.draw_circle(p, 10.0, col)
		ctrl.draw_arc(p, 7.2, 0.0, TAU, 24, Color("#f7f2df"), 2.0)
		ctrl.draw_circle(p, 4.0, col.darkened(0.22))

func _add_table_display(parent: VBoxContainer, partial: bool) -> void:
	var table := Control.new()
	table.custom_minimum_size = Vector2(860, 260)
	table.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	table.mouse_filter = Control.MOUSE_FILTER_IGNORE
	table.draw.connect(func(): _draw_baccarat_table(table, partial))
	parent.add_child(table)

	var p_cards: Array = (_deal_p_visible if partial else _result.get("player", []))
	var b_cards: Array = (_deal_b_visible if partial else _result.get("banker", []))
	var player_rect := _baccarat_player_rect(860.0)
	var banker_rect := _baccarat_banker_rect(860.0)
	_place_baccarat_cards(table, p_cards, _baccarat_card_start(player_rect, p_cards.size(), partial), partial, false)
	_place_baccarat_cards(table, b_cards, _baccarat_card_start(banker_rect, b_cards.size(), partial), partial, true)
	if not partial:
		_add_score_badge(table, _baccarat_score_pos(player_rect), int(_result.get("player_val", 0)), Color("#d4a020"))
		_add_score_badge(table, _baccarat_score_pos(banker_rect), int(_result.get("banker_val", 0)), Color("#e85d5d"))

func _baccarat_player_rect(_table_w: float) -> Rect2:
	return Rect2(Vector2(48, 48), Vector2(342, 156))

func _baccarat_banker_rect(table_w: float) -> Rect2:
	return Rect2(Vector2(table_w - 390.0, 48), Vector2(342, 156))

func _baccarat_card_start(rect: Rect2, card_count: int, fill_placeholders: bool) -> Vector2:
	var count: int = 3 if fill_placeholders else clampi(card_count, 1, 3)
	var card_size := Vector2(66, 92)
	var gap: float = 8.0
	var block_w: float = card_size.x * float(count) + gap * float(maxi(count - 1, 0))
	return Vector2(
		rect.position.x + (rect.size.x - block_w) * 0.5,
		rect.position.y + (rect.size.y - card_size.y) * 0.5 + 2.0
	)

func _baccarat_score_pos(rect: Rect2) -> Vector2:
	return rect.position + Vector2(rect.size.x - 58.0, rect.size.y * 0.5 - 23.0)

func _draw_baccarat_table(ctrl: Control, partial: bool) -> void:
	var sz: Vector2 = ctrl.size
	var font: Font = _font if _font else ThemeDB.fallback_font
	var bold: Font = _font_bold if _font_bold else font
	var felt := Rect2(Vector2(8, 8), sz - Vector2(16, 16))
	ctrl.draw_rect(Rect2(felt.position + Vector2(0, 7), felt.size), Color(0, 0, 0, 0.38), true)
	ctrl.draw_rect(felt, Color("#042413"), true)
	ctrl.draw_rect(felt, Color("#c49a38"), false, 2.2)
	ctrl.draw_line(Vector2(sz.x * 0.5, felt.position.y + 22), Vector2(sz.x * 0.5, felt.end.y - 22), Color(1, 1, 1, 0.08), 1.0)
	var player_rect := _baccarat_player_rect(sz.x)
	var banker_rect := _baccarat_banker_rect(sz.x)
	ctrl.draw_rect(player_rect, Color("#0a1d2e"), true)
	ctrl.draw_rect(player_rect, Color("#3a7abf"), false, 2.0)
	ctrl.draw_rect(banker_rect, Color("#2c0d0d"), true)
	ctrl.draw_rect(banker_rect, Color("#bf3a3a"), false, 2.0)
	ctrl.draw_string(bold, player_rect.position + Vector2(18, 29), "PLAYER",
		HORIZONTAL_ALIGNMENT_LEFT, 180, 15, Color("#8fc7ff"))
	ctrl.draw_string(bold, banker_rect.position + Vector2(18, 29), "BANKER",
		HORIZONTAL_ALIGNMENT_LEFT, 180, 15, Color("#ff9a9a"))
	var status: String = "DEALING" if partial else str(_result.get("result", "")).to_upper()
	ctrl.draw_string(bold, Vector2(sz.x * 0.5 - 86, 36), status,
		HORIZONTAL_ALIGNMENT_CENTER, 172, 16, Color("#f0b429"))
	ctrl.draw_string(font, Vector2(sz.x * 0.5 - 68, 224), "PLAYER 1:1   BANKER 0.95:1   TIE 8:1",
		HORIZONTAL_ALIGNMENT_CENTER, 136, 10, Color(1, 1, 1, 0.34))

func _place_baccarat_cards(parent: Control, cards: Array, start: Vector2, fill_placeholders: bool, from_right := false) -> void:
	var visible_cards: int = mini(cards.size(), 3)
	for i in range(visible_cards):
		var card_ctrl := _card_widget(int(cards[i]))
		_place_table_child(parent, card_ctrl, start + Vector2(float(i) * 74.0, 0), float(i) * 0.035, from_right)
	if not fill_placeholders:
		return
	for i in range(visible_cards, 3):
		var back := _card_back()
		back.modulate = Color(1, 1, 1, 0.42)
		_place_table_child(parent, back, start + Vector2(float(i) * 74.0, 0))

func _add_score_badge(parent: Control, pos: Vector2, value: int, col: Color) -> void:
	var lbl := Label.new()
	lbl.text = str(value)
	lbl.position = pos
	lbl.size = Vector2(46, 46)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 26)
	lbl.add_theme_color_override("font_color", col.lightened(0.28))
	_f(lbl, true)
	parent.add_child(lbl)

func _place_table_child(parent: Control, child: Control, pos: Vector2, delay := 0.0, from_right := false) -> void:
	child.position = pos
	child.size = child.custom_minimum_size
	parent.add_child(child)
	if child.modulate.a >= 0.95:
		_animate_table_card(child, pos, delay, from_right)

func _animate_table_card(child: Control, final_pos: Vector2, delay: float, from_right: bool) -> void:
	if not is_instance_valid(child):
		return
	var drift := Vector2(58.0 if from_right else -58.0, -22.0)
	child.position = final_pos + drift
	child.scale = Vector2(0.88, 0.88)
	child.pivot_offset = child.custom_minimum_size * 0.5
	child.rotation_degrees = 4.0 if from_right else -4.0
	child.modulate.a = 0.0
	var tw := create_tween()
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.set_parallel(true)
	tw.tween_property(child, "position", final_pos, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(child, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(child, "rotation_degrees", 0.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(child, "modulate:a", 1.0, 0.12)
	tw.set_parallel(false)

func _next_round() -> void:
	_reset_bets()
	_phase = Phase.BETTING
	AudioManager.play("click")
	_render()

func _set_stake(s: int) -> void:
	_active_stake = s
	AudioManager.play("click")
	_render()

# ── UI 헬퍼 ───────────────────────────────────────────────────
func _build_skeleton() -> void:
	# 배경 — MainGame HUD/시스템 창이 뒤에서 비치지 않도록 먼저 불투명 베이스를 깐다.
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#050810")
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	const _BG = "res://assets/backgrounds/casino_interior.png"
	if ResourceLoader.exists(_BG):
		var bg_img := TextureRect.new()
		bg_img.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg_img.stretch_mode = TextureRect.STRETCH_SCALE
		bg_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bg_img.texture = load(_BG) as Texture2D
		bg_img.modulate = Color(1, 1, 1, 0.52)
		add_child(bg_img)
	var veil := ColorRect.new()
	veil.set_anchors_preset(Control.PRESET_FULL_RECT)
	veil.color = Color(0.015, 0.02, 0.035, 0.42 if ResourceLoader.exists(_BG) else 0.0)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(veil)

	# HUD (최상단)
	var hud_panel := Panel.new()
	hud_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hud_panel.offset_bottom = 42
	var hs := StyleBoxFlat.new()
	hs.bg_color = Color("#0a0e18"); hs.border_color = Color("#1a2438"); hs.border_width_bottom = 1
	hud_panel.add_theme_stylebox_override("panel", hs)
	add_child(hud_panel)
	_hud_lbl = RichTextLabel.new()
	_hud_lbl.bbcode_enabled = true; _hud_lbl.fit_content = true; _hud_lbl.scroll_active = false
	_hud_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hud_lbl.offset_left = 20; _hud_lbl.offset_top = 10; _hud_lbl.offset_right = -20
	_f(_hud_lbl); _hud_lbl.add_theme_font_size_override("normal_font_size", 14)
	hud_panel.add_child(_hud_lbl)

	# 로드맵 (우측 패널)
	_road_ctrl = Control.new()
	_road_ctrl.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	_road_ctrl.offset_left = -160; _road_ctrl.offset_top = 50; _road_ctrl.offset_bottom = -10
	_road_ctrl.draw.connect(_draw_road)
	add_child(_road_ctrl)

	_content_root = Control.new()
	_content_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_content_root.offset_top = 50
	_content_root.offset_bottom = -10
	add_child(_content_root)

	# 메시지 플래시
	_msg_lbl = Label.new()
	_msg_lbl.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_msg_lbl.offset_top = -36; _msg_lbl.offset_bottom = -8
	_msg_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_f(_msg_lbl, true); _msg_lbl.add_theme_font_size_override("font_size", 16)
	_msg_lbl.visible = false
	add_child(_msg_lbl)

	_flash_layer = ColorRect.new()
	_flash_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash_layer.color = Color(1, 1, 1, 1)
	_flash_layer.modulate = Color(1, 1, 1, 0.0)
	_flash_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash_layer.z_index = 80
	add_child(_flash_layer)

func _clear_content() -> void:
	if not is_instance_valid(_content_root): return
	for c in _content_root.get_children():
		c.queue_free()

func _make_vbox(sep: int) -> VBoxContainer:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.offset_left = 20
	center.offset_top = 14
	center.offset_right = -20
	center.offset_bottom = -14
	_content_root.add_child(center)

	var table_panel := PanelContainer.new()
	table_panel.custom_minimum_size = Vector2(920, 0)
	table_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	table_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var table_st := StyleBoxFlat.new()
	table_st.bg_color = Color("#062214")
	table_st.border_color = Color("#c49a38")
	table_st.set_border_width_all(3)
	table_st.set_corner_radius_all(24)
	table_st.content_margin_left = 20
	table_st.content_margin_right = 20
	table_st.content_margin_top = 18
	table_st.content_margin_bottom = 18
	table_st.shadow_color = Color(0, 0, 0, 0.55)
	table_st.shadow_size = 18
	table_st.shadow_offset = Vector2(0, 8)
	table_panel.add_theme_stylebox_override("panel", table_st)
	center.add_child(table_panel)

	var vb := VBoxContainer.new()
	vb.custom_minimum_size = Vector2(860, 0)
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_theme_constant_override("separation", sep)
	table_panel.add_child(vb)
	return vb

func _add_bet_btn(parent: HBoxContainer, header: String, label: String, type: String,
		bg: String, border: String) -> void:
	var cur_bet: int = _get_bet_for_type(type)
	var vb := VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_theme_constant_override("separation", 4)
	parent.add_child(vb)
	var h := Label.new()
	h.text = header
	h.add_theme_font_size_override("font_size", 11)
	h.add_theme_color_override("font_color", Color("#6a7a8a"))
	h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_f(h); vb.add_child(h)
	var btn := _make_btn(label + ("\n[%s]" % GameState.format_money(float(cur_bet)) if cur_bet > 0 else ""),
		func(): _add_bet(type), bg, border)
	btn.custom_minimum_size = Vector2(0, 52)
	if _should_show_pad_cursor() and _pad_target() == type:
		_mark_pad_button(btn)
	vb.add_child(btn)

func _add_pad_hint(parent: VBoxContainer) -> void:
	if not _should_show_pad_cursor():
		return
	var hint := RichTextLabel.new()
	hint.bbcode_enabled = true
	hint.fit_content = true
	hint.scroll_active = false
	hint.custom_minimum_size = Vector2(0, 18)
	hint.add_theme_font_size_override("normal_font_size", 11)
	hint.add_theme_color_override("default_color", Color("#aeb6ca"))
	_f(hint, true)
	hint.bbcode_text = _tr(
		"[b]%s[/b]   [%s/%s] 존  [%s] 칩 놓기/딜  [%s] 단위  [%s] 규칙  [%s] 취소",
		"[b]%s[/b]   [%s/%s] Zone  [%s] Bet/Deal  [%s] Stake  [%s] Rules  [%s] Cancel"
	) % [
		_pad_target_label(),
		ControllerHints.shoulder_l(),
		ControllerHints.shoulder_r(),
		ControllerHints.south(),
		ControllerHints.west(),
		ControllerHints.north(),
		ControllerHints.east(),
	]
	parent.add_child(hint)

func _get_bet_for_type(type: String) -> int:
	match type:
		"P":  return _bet_p
		"B":  return _bet_b
		"T":  return _bet_t
		"PP": return _bet_pp
		"BP": return _bet_bp
	return 0

func _bet_status_text() -> String:
	var parts: Array = []
	if _bet_p  > 0: parts.append(_tr("[color=#d4a020]플 %s[/color]", "[color=#d4a020]P %s[/color]") % GameState.format_money(float(_bet_p)))
	if _bet_b  > 0: parts.append(_tr("[color=#e85d5d]뱅 %s[/color]", "[color=#e85d5d]B %s[/color]") % GameState.format_money(float(_bet_b)))
	if _bet_t  > 0: parts.append(_tr("[color=#f0b429]타이 %s[/color]", "[color=#f0b429]Tie %s[/color]") % GameState.format_money(float(_bet_t)))
	if _bet_pp > 0: parts.append("[color=#d4a0ff]PP %s[/color]" % GameState.format_money(float(_bet_pp)))
	if _bet_bp > 0: parts.append("[color=#d4a0ff]BP %s[/color]" % GameState.format_money(float(_bet_bp)))
	if parts.is_empty():
		return _tr("[color=#3a4a5a]베팅 없음[/color]", "[color=#3a4a5a]No Bet[/color]")
	var total := _tr("[b]총 %s[/b]", "[b]Total %s[/b]") % GameState.format_money(float(_total_bet()))
	return "  ".join(parts) + "   " + total

func _card_widget(card: int) -> Control:
	var root := Control.new()
	root.custom_minimum_size = Vector2(66, 92)

	if CARD_FRONT_TEX != null:
		var tex := TextureRect.new()
		tex.set_anchors_preset(Control.PRESET_FULL_RECT)
		tex.texture = CARD_FRONT_TEX
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_SCALE
		root.add_child(tex)
	else:
		var panel := Panel.new()
		panel.set_anchors_preset(Control.PRESET_FULL_RECT)
		var st := StyleBoxFlat.new()
		st.bg_color = Color("#f8f4e8")
		st.border_color = Color("#b8aa8a")
		st.set_border_width_all(1)
		st.set_corner_radius_all(7)
		st.shadow_color = Color(0, 0, 0, 0.35)
		st.shadow_size = 5
		st.shadow_offset = Vector2(0, 2)
		panel.add_theme_stylebox_override("panel", st)
		root.add_child(panel)

	var col := Color("#d73939") if _card_is_red(card) else Color("#141827")
	var rank := _card_rank_text(card)
	var suit := _card_suit_text(card)

	var corner := Label.new()
	corner.text = rank + "\n" + suit
	corner.set_anchors_preset(Control.PRESET_TOP_LEFT)
	corner.offset_left = 5; corner.offset_top = 4
	corner.offset_right = 28; corner.offset_bottom = 38
	corner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	corner.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	corner.add_theme_font_size_override("font_size", 12)
	corner.add_theme_color_override("font_color", col)
	if _font_bold: corner.add_theme_font_override("font", _font_bold)
	root.add_child(corner)

	var center := Label.new()
	center.text = suit
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	center.add_theme_font_size_override("font_size", 34)
	center.add_theme_color_override("font_color", col)
	if _font_bold: center.add_theme_font_override("font", _font_bold)
	root.add_child(center)

	var bottom := Label.new()
	bottom.text = rank
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	bottom.offset_left = -28; bottom.offset_top = -24
	bottom.offset_right = -6; bottom.offset_bottom = -4
	bottom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bottom.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bottom.add_theme_font_size_override("font_size", 11)
	bottom.add_theme_color_override("font_color", col.darkened(0.08))
	if _font_bold: bottom.add_theme_font_override("font", _font_bold)
	root.add_child(bottom)

	_animate_card_appear(root)
	return root

func _animate_card_appear(node: Control) -> void:
	node.modulate.a = 1.0

func _card_back() -> Control:
	if CARD_BACK_TEX != null:
		var tex := TextureRect.new()
		tex.custom_minimum_size = Vector2(66, 92)
		tex.texture = CARD_BACK_TEX
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		return tex
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(66, 92)
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#12244a")
	st.border_color = Color("#2a4a8a")
	st.set_border_width_all(1)
	st.set_corner_radius_all(5)
	panel.add_theme_stylebox_override("panel", st)
	var lbl := Label.new()
	lbl.text = "🂠"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl.add_theme_font_size_override("font_size", 20)
	panel.add_child(lbl)
	return panel

func _card_rank_text(card: int) -> String:
	const RANKS := ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
	return RANKS[card % 13]

func _card_suit_text(card: int) -> String:
	const SUITS := ["♠", "♥", "♦", "♣"]
	return SUITS[int(card / 13)]

func _card_is_red(card: int) -> bool:
	return int(card / 13) in [1, 2]

func _make_btn(label: String, cb: Callable, bg: String, border: String) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.focus_mode = Control.FOCUS_NONE
	var st := StyleBoxFlat.new()
	st.bg_color = Color(bg); st.border_color = Color(border)
	st.set_border_width_all(1); st.set_corner_radius_all(6)
	st.content_margin_left = 12; st.content_margin_right = 12
	st.content_margin_top = 8; st.content_margin_bottom = 8
	var hov := st.duplicate(); hov.bg_color = Color(bg).lightened(0.12)
	var dis := st.duplicate(); dis.bg_color = Color("#0e0e14"); dis.border_color = Color("#1a1a22")
	var foc := st.duplicate(); foc.border_color = Color("#f0b429"); foc.set_border_width_all(2)
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_stylebox_override("hover", hov)
	btn.add_theme_stylebox_override("pressed", hov)
	btn.add_theme_stylebox_override("disabled", dis)
	btn.add_theme_stylebox_override("focus", foc)
	btn.add_theme_color_override("font_color", Color("#dce4f0"))
	btn.add_theme_color_override("font_disabled_color", Color("#3a3a48"))
	btn.add_theme_font_size_override("font_size", 14)
	if _font: btn.add_theme_font_override("font", _font)
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
		flat.border_color = Color("#f0b429")
		flat.set_border_width_all(3)
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_stylebox_override("hover", st)
	btn.add_theme_stylebox_override("pressed", st)
	btn.add_theme_stylebox_override("focus", st)

func _sep() -> HSeparator:
	var s := HSeparator.new()
	s.add_theme_color_override("color", Color("#151825"))
	return s

func _flash(msg: String, color: String) -> void:
	_msg_lbl.text = msg
	_msg_lbl.add_theme_color_override("font_color", Color(color))
	_msg_lbl.visible = true
	get_tree().create_timer(1.8).timeout.connect(func():
		if is_instance_valid(_msg_lbl): _msg_lbl.visible = false)

func _screen_flash(color: Color, alpha: float = 0.16, duration: float = 0.3) -> void:
	if not is_instance_valid(_flash_layer):
		return
	_flash_layer.color = Color(color.r, color.g, color.b, 1.0)
	_flash_layer.modulate = Color(1, 1, 1, 0.0)
	_flash_layer.visible = true
	var tw := create_tween()
	tw.tween_property(_flash_layer, "modulate:a", alpha, duration * 0.22)
	tw.tween_property(_flash_layer, "modulate:a", 0.0, duration * 0.78)
	tw.tween_callback(func():
		if is_instance_valid(_flash_layer):
			_flash_layer.visible = false
	)

func _show_table_banner(text: String, color: Color, duration: float = 0.5) -> void:
	var root_size := size
	if root_size.x <= 1.0 or root_size.y <= 1.0:
		root_size = get_viewport_rect().size
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.z_index = 75
	panel.size = Vector2(minf(390.0, root_size.x - 48.0), 54.0)
	panel.position = Vector2((root_size.x - panel.size.x) * 0.5, maxf(88.0, root_size.y * 0.28))
	panel.modulate = Color(1, 1, 1, 0.0)
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.02, 0.03, 0.04, 0.86)
	st.border_color = color
	st.set_border_width_all(2)
	st.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", st)
	add_child(panel)
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", color)
	_f(lbl, true)
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(lbl)
	var tw := create_tween()
	tw.tween_property(panel, "modulate:a", 1.0, 0.08)
	tw.tween_interval(duration)
	tw.tween_property(panel, "modulate:a", 0.0, 0.16)
	tw.tween_callback(panel.queue_free)

func _shake_node(node: Node, amount: float = 6.0, duration: float = 0.25) -> void:
	if not is_instance_valid(node) or not (node is Control):
		return
	var ctrl := node as Control
	var base := ctrl.position
	var tw := create_tween()
	for _i in range(6):
		var offset := Vector2(randf_range(-amount, amount), randf_range(-amount * 0.45, amount * 0.45))
		tw.tween_property(ctrl, "position", base + offset, duration / 6.0)
	tw.tween_property(ctrl, "position", base, 0.04)

func _pulse_node(node: Node, scale_to: float = 1.08, duration: float = 0.28) -> void:
	if not is_instance_valid(node) or not (node is Control):
		return
	var ctrl := node as Control
	var base := ctrl.scale
	ctrl.pivot_offset = ctrl.size * 0.5
	var tw := create_tween()
	tw.tween_property(ctrl, "scale", base * scale_to, duration * 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(ctrl, "scale", base, duration * 0.58).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _spawn_bet_chip(type: String, stake: int) -> void:
	var root_size := size
	if root_size.x <= 1.0 or root_size.y <= 1.0:
		root_size = get_viewport_rect().size
	var target_ratio := Vector2(0.50, 0.48)
	match type:
		"P":
			target_ratio = Vector2(0.38, 0.47)
		"B":
			target_ratio = Vector2(0.62, 0.47)
		"T":
			target_ratio = Vector2(0.50, 0.43)
		"PP":
			target_ratio = Vector2(0.39, 0.56)
		"BP":
			target_ratio = Vector2(0.61, 0.56)
	var start := Vector2(root_size.x * 0.50, root_size.y * 0.78)
	var target := Vector2(root_size.x * target_ratio.x, root_size.y * target_ratio.y)
	var chip := _floating_chip(stake, 34.0)
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.z_index = 74
	chip.position = start - chip.size * 0.5
	chip.scale = Vector2(0.70, 0.70)
	chip.modulate.a = 0.95
	add_child(chip)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(chip, "position", target - chip.size * 0.5, 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(chip, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(chip, "modulate:a", 0.0, 0.18).set_delay(0.26)
	tw.set_parallel(false)
	tw.tween_callback(chip.queue_free)

func _floating_chip(stake: int, chip_size: float) -> Control:
	var raw_tex = CHIP_TEX_BY_STAKE.get(stake, null)
	if raw_tex is Texture2D:
		var tex := TextureRect.new()
		tex.texture = raw_tex as Texture2D
		tex.size = Vector2(chip_size, chip_size)
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_SCALE
		return tex
	var panel := PanelContainer.new()
	panel.size = Vector2(chip_size, chip_size)
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#d4a020")
	st.border_color = Color("#fff3b0")
	st.set_border_width_all(2)
	st.set_corner_radius_all(99)
	panel.add_theme_stylebox_override("panel", st)
	return panel

# ── 로드맵 드로우 콜백 ─────────────────────────────────────────
func _refresh_road() -> void:
	if is_instance_valid(_road_ctrl):
		_road_ctrl.queue_redraw()

# 로드맵 마지막 셀 fade alpha (0.0→1.0, _road_fade_alpha 로 제어)
var _road_fade_alpha: float = 1.0

func _start_road_fade() -> void:
	_road_fade_alpha = 0.0
	var tw := create_tween()
	tw.tween_method(_set_road_fade_alpha, 0.0, 1.0, 0.3)

func _set_road_fade_alpha(v: float) -> void:
	_road_fade_alpha = v
	if is_instance_valid(_road_ctrl):
		_road_ctrl.queue_redraw()

func _draw_road() -> void:
	var sz := _road_ctrl.size
	if sz.x < 10 or sz.y < 10: return

	var f := _font if _font else ThemeDB.fallback_font
	# 제목
	_road_ctrl.draw_string(f, Vector2(6, 18), _tr("로드맵", "Roadmap"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#5a6a7a"))

	# 격자 (6열 x 6행)
	const COLS := 6; const ROWS := 6
	var cell_w := (sz.x - 8) / float(COLS)
	var cell_h := (sz.y - 28) / float(ROWS)
	var results := _road.slice(maxi(_road.size() - COLS * ROWS, 0))
	var last_idx := results.size() - 1
	for idx in range(results.size()):
		var col := idx % COLS
		var row := idx / COLS
		var cx := 4.0 + col * cell_w + cell_w * 0.5
		var cy := 26.0 + row * cell_h + cell_h * 0.5
		var r := minf(cell_w, cell_h) * 0.38
		var res: String = str(results[idx])
		var col_c: Color
		match res:
			"P": col_c = Color("#3a7abf")
			"B": col_c = Color("#bf3a3a")
			_:   col_c = Color("#3abf5a")
		# 새로 추가된 마지막 셀은 fade alpha 적용
		var cell_alpha: float = _road_fade_alpha if idx == last_idx and _road.size() > _road_last_count else 1.0
		var draw_col := Color(col_c.r, col_c.g, col_c.b, cell_alpha)
		var arc_col := Color(col_c.lightened(0.3).r, col_c.lightened(0.3).g, col_c.lightened(0.3).b, cell_alpha)
		_road_ctrl.draw_circle(Vector2(cx, cy), r, draw_col)
		_road_ctrl.draw_arc(Vector2(cx, cy), r, 0, TAU, 16, arc_col, 1.0)
		if res != "T":
			_road_ctrl.draw_string(f, Vector2(cx - 3, cy + 4), res,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(1, 1, 1, cell_alpha))

# ── 내추럴 배너 ───────────────────────────────────────────────
func _show_natural_banner(val: int) -> void:
	var root_size := size
	if root_size.x <= 1.0 or root_size.y <= 1.0:
		root_size = get_viewport_rect().size
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.z_index = 90
	panel.size = Vector2(minf(420.0, root_size.x - 48.0), 68.0)
	panel.position = Vector2((root_size.x - panel.size.x) * 0.5, maxf(60.0, root_size.y * 0.18))
	panel.modulate = Color(1, 1, 1, 0.0)
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#7a5500")
	st.border_color = Color("#f0b429")
	st.set_border_width_all(3)
	st.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", st)
	add_child(panel)
	var lbl := Label.new()
	lbl.text = "NATURAL %d !" % val
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 26)
	lbl.add_theme_color_override("font_color", Color("#ffe566"))
	_f(lbl, true)
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(lbl)
	AudioManager.play("casino_jackpot")
	var tw := create_tween()
	tw.tween_property(panel, "modulate:a", 1.0, 0.12)
	tw.tween_interval(1.5)
	tw.tween_property(panel, "modulate:a", 0.0, 0.2)
	tw.tween_callback(panel.queue_free)
