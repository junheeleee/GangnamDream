extends Control
## BlackjackTable — 정선 카지노 블랙잭 테이블.
## Blackjack 모델(순수 수학) 위에 히트/스탠드/더블/스플릿 UI.
## 기본전략 힌트 표시 → "공부하면 EV 올라간다"를 실감하게.

signal closed

const BJ := preload("res://systems/Blackjack.gd")
const CARD_BACK_TEX := preload("res://assets/ui/card_back.png")
const CARD_FRONT_TEX := preload("res://assets/ui/card_front_base.svg")
const CHIP_TEX_BY_STAKE := {
	10_000: preload("res://assets/ui/chips/chip_10k.svg"),
	50_000: preload("res://assets/ui/chips/chip_50k.svg"),
	100_000: preload("res://assets/ui/chips/chip_100k.svg"),
	500_000: preload("res://assets/ui/chips/chip_500k.svg"),
	1_000_000: preload("res://assets/ui/chips/chip_1m.svg"),
}

enum Phase { BETTING, PLAYER_TURN, DEALER_TURN, RESULT }

const BJ_PAYOUT    := 1.5   # 블랙잭 3:2
const WIN_PAYOUT   := 1.0   # 일반 승 1:1
const PUSH_RETURN  := 1.0   # 타이: 베팅 반환
const SHOE_CUT     := 0.25

const STAKE_OPTIONS := [10_000, 50_000, 100_000, 500_000, 1_000_000]

# ── 상태 ──────────────────────────────────────────────────────
var _phase: int     = Phase.BETTING
var _shoe: Array    = []
var _dealer: Array  = []   # 딜러 핸드
var _player: Array  = []   # 플레이어 메인 핸드
var _split: Array   = []   # 스플릿 핸드 (비어있으면 스플릿 없음)
var _split_active: bool = false  # 현재 스플릿 핸드를 플레이 중
var _stake: int     = 100_000
var _dbl_down: bool = false
var _split_stake: int = 0

var _rounds: int    = 0
var _net: float     = 0.0
var _wins: int      = 0
var _losses: int    = 0
var _pushes: int    = 0
var _hand_history: Array = []  # 최근 10핸드

var _rng := RandomNumberGenerator.new()

# UI
var _font: FontFile
var _font_bold: FontFile
var _content_root: Control
var _msg_lbl: RichTextLabel
var _hud_lbl: RichTextLabel
var _flash_layer: ColorRect

# ── 초기화 ────────────────────────────────────────────────────
func _ready() -> void:
	_rng.randomize()
	_load_fonts()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_skeleton()
	visible = false

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

# ── 진입/종료 ──────────────────────────────────────────────────
func open() -> void:
	_shoe = BJ.new_shoe(_rng)
	_rounds = 0; _net = 0.0; _wins = 0; _losses = 0; _pushes = 0
	_hand_history = []
	_phase = Phase.BETTING
	visible = true
	TutorialOverlay.maybe_show("blackjack", self)
	_render()
	AudioManager.play("casino_card")

func _on_exit() -> void:
	MetaProgression.record_minigame_play("blackjack")
	visible = false
	closed.emit()

# ── 딜 ──────────────────────────────────────────────────────
func _deal() -> void:
	if GameState.money < float(_stake):
		_flash("현금 부족", "#e85d5d"); return
	if BJ.shoe_remaining_ratio(_shoe) < SHOE_CUT:
		_shoe = BJ.new_shoe(_rng)
		_flash("🔀 슈 리셔플", "#c9a227")

	GameState.add_money(-float(_stake))
	_dealer = [_shoe.pop_front(), _shoe.pop_front()]
	_player = [_shoe.pop_front(), _shoe.pop_front()]
	_split  = []
	_split_active = false
	_dbl_down = false
	_split_stake = 0
	_phase = Phase.PLAYER_TURN
	_rounds += 1

	# 즉시 블랙잭 체크
	if BJ.is_blackjack(_player):
		_resolve_hand()
		return

	AudioManager.play("casino_card")
	_render()
	_show_table_banner("DEAL", Color("#c9a227"), 0.48)
	if is_instance_valid(_content_root):
		_content_root.scale = Vector2(0.94, 0.94)
		var tw := create_tween()
		tw.tween_property(_content_root, "scale", Vector2(1.0, 1.0), 0.22).set_trans(Tween.TRANS_BACK)
	_screen_flash(Color("#c9a227"), 0.10, 0.22)

# ── 플레이어 액션 ──────────────────────────────────────────────
func _hit() -> void:
	var hand := _split_hand()
	hand.append(_shoe.pop_front())
	AudioManager.play("casino_card")
	_show_table_banner("HIT", Color("#c9a227"), 0.38)
	_screen_flash(Color("#c9a227"), 0.08, 0.16)
	if BJ.hand_value(hand) >= 21:
		_next_or_dealer()
	else:
		_render()
		_pulse_node(_content_root, 1.01, 0.14)

func _stand() -> void:
	AudioManager.play("click")
	_show_table_banner("STAND", Color("#5de89c"), 0.38)
	if _split_active and not _split.is_empty():
		# 스플릿 첫 핸드 스탠드 → 두 번째 핸드로
		_split_active = false
		_render()
	else:
		_phase = Phase.DEALER_TURN
		_dealer_play_and_resolve()

func _double_down() -> void:
	var hand := _split_hand()
	if GameState.money < float(_stake): return
	GameState.add_money(-float(_stake))
	AudioManager.play("casino_bet")
	_show_table_banner("DOUBLE DOWN", Color("#f0b429"), 0.55)
	_screen_flash(Color("#f0b429"), 0.13, 0.24)
	_shake_node(_content_root, 4.0, 3)
	if _split_active:
		_split_stake = _stake
	else:
		_dbl_down = true
	hand.append(_shoe.pop_front())
	_next_or_dealer()

func _do_split() -> void:
	if _player.size() != 2: return
	var v0: int = int(_player[0]) % 13
	var v1: int = int(_player[1]) % 13
	if (mini(v0 + 1, 10) != mini(v1 + 1, 10)) and not (v0 >= 9 and v1 >= 9): return
	if GameState.money < float(_stake): return
	GameState.add_money(-float(_stake))
	AudioManager.play("casino_bet")
	_show_table_banner("SPLIT", Color("#d4a0ff"), 0.52)
	_screen_flash(Color("#d4a0ff"), 0.11, 0.22)
	_split_stake = _stake
	_split = [_player.pop_back(), _shoe.pop_front()]
	_player.append(_shoe.pop_front())
	_split_active = true
	# AA 스플릿: 각 핸드에 카드 1장 → 자동 스탠드
	if (_player[0] % 13) == 0:
		_player.append(_shoe.pop_front())
		_split.append(_shoe.pop_front())
		_next_or_dealer()
		return
	_render()

func _split_hand() -> Array:
	return _split if _split_active else _player

func _next_or_dealer() -> void:
	if _split_active and not _split.is_empty():
		# 첫 핸드 완료 → 두 번째로
		_split_active = false
		_render()
	else:
		_phase = Phase.DEALER_TURN
		_dealer_play_and_resolve()

# ── 딜러 플레이 → 결과 ──────────────────────────────────────
func _dealer_play_and_resolve() -> void:
	# 딜러 두 번째 카드 공개 후 플레이
	AudioManager.play("casino_card")
	_show_table_banner("DEALER", Color("#e85d5d"), 0.40)
	BJ.dealer_play(_dealer, _shoe)
	_resolve_hand()

func _resolve_hand() -> void:
	_phase = Phase.RESULT
	var dv := BJ.hand_value(_dealer)
	var dealer_bj := BJ.is_blackjack(_dealer)

	var total_gain: float = 0.0
	var hand_results: Array = []
	var got_blackjack: bool = false
	var got_bust: bool = false

	for hi in range(2):
		var hand: Array = _player if hi == 0 else _split
		if hand.is_empty(): continue
		var stake_for: int = _split_stake if hi == 1 else _stake
		var is_dbl: bool = (_dbl_down and hi == 0) or (hi == 1 and _split_stake > 0 and _split.size() >= 2)
		var actual_stake: int = stake_for * 2 if (is_dbl and hi == 0 and _dbl_down) else stake_for

		var pv := BJ.hand_value(hand)
		var pj  := BJ.is_blackjack(hand) and hi == 0

		var gain: float = 0.0
		var label: String = ""

		if pv > 21:
			label = "버스트 -%s" % GameState.format_money(float(actual_stake))
			_losses += 1
			got_bust = true
		elif pj and dealer_bj:
			gain = float(actual_stake)
			label = "블랙잭 타이 (반환)"
			_pushes += 1
		elif pj:
			gain = float(actual_stake) * (1.0 + BJ_PAYOUT)
			label = "BLACKJACK  +%s" % GameState.format_money(gain - float(actual_stake))
			_wins += 1
			got_blackjack = true
		elif dealer_bj:
			label = "딜러 블랙잭 -%s" % GameState.format_money(float(actual_stake))
			_losses += 1
		elif dv > 21:
			gain = float(actual_stake) * 2.0
			label = "딜러 버스트 +%s" % GameState.format_money(float(actual_stake))
			_wins += 1
		elif pv > dv:
			gain = float(actual_stake) * 2.0
			label = "+%s" % GameState.format_money(float(actual_stake))
			_wins += 1
		elif pv == dv:
			gain = float(actual_stake)
			label = "타이 — 베팅 환불"
			_pushes += 1
		else:
			label = "-%s" % GameState.format_money(float(actual_stake))
			_losses += 1

		total_gain += gain
		hand_results.append({"label": label, "win": gain > 0})

	if total_gain > 0:
		GameState.add_money(total_gain)
	var net_round := total_gain - float(_stake + _split_stake + (_stake if _dbl_down else 0))
	_net += net_round

	# 핸드 히스토리
	var desc: String = str(hand_results[0]["label"]) if not hand_results.is_empty() else "?"
	_hand_history.append({"won": net_round > 0, "net": net_round, "desc": desc})
	if _hand_history.size() > 10:
		_hand_history.pop_front()

	if got_blackjack:
		AudioManager.play_casino_result(net_round, float(_stake), true)
		GameState.modify_hidden_stat("gambling_tendency", 2)
	elif net_round > 0:
		AudioManager.play_casino_result(net_round, float(_stake))
		GameState.modify_hidden_stat("gambling_tendency", 2)
	elif got_bust or net_round < 0:
		AudioManager.play_casino_result(net_round, float(_stake))
		GameState.modify_hidden_stat("addiction_tendency", 2)
	else:
		AudioManager.play_casino_result(0.0, float(_stake))
		GameState.modify_hidden_stat("addiction_tendency", 2)

	GameState.add_log("블랙잭 %s" % desc, "money")
	GameState.stats_changed.emit()
	_render()
	if got_blackjack:
		_show_table_banner_bj("BLACKJACK", Color("#f0b429"))
		_screen_flash(Color("#f0b429"), 0.22, 0.44)
		_pulse_node(_content_root, 1.04, 0.32)
	elif got_bust:
		_show_table_banner("버스트  %s" % GameState.format_money(net_round), Color("#e85d5d"), 0.72)
		_screen_flash(Color("#e85d5d"), 0.22, 0.40)
		_shake_node(_content_root, 6.0, 5)
	elif net_round > 0:
		_show_table_banner("WIN  +%s" % GameState.format_money(net_round), Color("#5de89c"), 0.72)
		_screen_flash(Color("#5de89c"), 0.18, 0.36)
		_pulse_node(_content_root, 1.025, 0.26)
	elif net_round == 0.0:
		_show_table_banner("타이 — 베팅 환불", Color("#9a9aaa"), 0.64)
		_screen_flash(Color("#9a9aaa"), 0.10, 0.22)
	else:
		_show_table_banner("LOSE  %s" % GameState.format_money(net_round), Color("#e85d5d"), 0.72)
		_screen_flash(Color("#e85d5d"), 0.18, 0.34)
		_shake_node(_content_root, 6.0, 5)

# ── 렌더 ──────────────────────────────────────────────────────
func _render() -> void:
	_refresh_hud()
	_clear_content()
	match _phase:
		Phase.BETTING:    _render_betting()
		Phase.PLAYER_TURN:_render_game()
		Phase.DEALER_TURN:_render_game()
		Phase.RESULT:     _render_result()

func _refresh_hud() -> void:
	var total_h := _wins + _losses + _pushes
	var wr: String = ""
	if total_h > 0:
		wr = "  승률 %d%% (%dW/%dL/%dP)" % [roundi(float(_wins)/float(total_h)*100), _wins, _losses, _pushes]
	_hud_lbl.text = "[b]현금 %s[/b]   |   블랙잭%s   손익 [b]%s[/b]" % [
		GameState.format_money(GameState.money), wr,
		("+%s" % GameState.format_money(_net)) if _net >= 0 else GameState.format_money(_net)]

func _render_betting() -> void:
	var vb := _make_vbox(12)

	var title := Label.new()
	title.text = "블랙잭"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("#f0b429"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_f(title, true); vb.add_child(title)

	var rules := RichTextLabel.new()
	rules.bbcode_enabled = true; rules.fit_content = true; rules.scroll_active = false
	_f(rules); rules.add_theme_font_size_override("normal_font_size", 12)
	rules.add_theme_color_override("default_color", Color("#4a5a6a"))
	rules.text = "블랙잭 3:2  ·  딜러 소프트17 히트  ·  더블·스플릿 가능  ·  6덱  ·  기본전략 힌트 제공"
	vb.add_child(rules)

	_add_blackjack_betting_mat(vb)

	# 핸드 히스토리
	if not _hand_history.is_empty():
		var hist := RichTextLabel.new()
		hist.bbcode_enabled = true; hist.fit_content = true; hist.scroll_active = false
		_f(hist); hist.add_theme_font_size_override("normal_font_size", 11)
		var parts: Array = []
		for h in _hand_history:
			var col := "#5de89c" if h["won"] else "#e85d5d"
			parts.append("[color=%s]%s[/color]" % [col, "▲" if h["won"] else "▼"])
		hist.text = "히스토리: " + " ".join(parts)
		vb.add_child(hist)

	vb.add_child(_sep())

	var stake_lbl := Label.new()
	stake_lbl.text = "베팅 금액 선택"
	stake_lbl.add_theme_font_size_override("font_size", 12)
	stake_lbl.add_theme_color_override("font_color", Color("#7a8a9a"))
	_f(stake_lbl); vb.add_child(stake_lbl)

	var stake_row := HBoxContainer.new()
	stake_row.add_theme_constant_override("separation", 8)
	stake_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_child(stake_row)
	for s in STAKE_OPTIONS:
		var can: bool = GameState.money >= float(s)
		var sb := _make_btn(GameState.format_money(float(s)), func(): _set_stake_and_deal(s),
			"#1a2a1a" if s == _stake else "#0e141a",
			"#5de89c" if s == _stake else "#2a3a4a")
		if CHIP_TEX_BY_STAKE.has(s):
			sb.icon = CHIP_TEX_BY_STAKE[s]
			sb.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
			sb.expand_icon = false
			sb.add_theme_constant_override("h_separation", 6)
			sb.add_theme_constant_override("icon_max_width", 22)
		sb.disabled = not can
		sb.custom_minimum_size = Vector2(102, 38)
		stake_row.add_child(sb)

	vb.add_child(_sep())

	var deal_btn := _make_btn("딜 시작  |  베팅 %s" % GameState.format_money(float(_stake)),
		func(): _set_stake_and_deal(_stake), "#1a3a1a", "#3de87a")
	deal_btn.custom_minimum_size = Vector2(0, 48)
	deal_btn.disabled = GameState.money < float(_stake)
	_f(deal_btn, true); vb.add_child(deal_btn)

	var help_btn := _make_btn("규칙", func(): TutorialOverlay.force_show("blackjack", self), "#0a0a1a", "#5a4510")
	help_btn.custom_minimum_size = Vector2(0, 44)
	vb.add_child(help_btn)

	var exit_btn := _make_btn("나가기", _on_exit, "#1a0e0e", "#5a2a2a")
	exit_btn.custom_minimum_size = Vector2(0, 44)
	vb.add_child(exit_btn)

func _set_stake_and_deal(s: int) -> void:
	_stake = s
	_deal()

func _render_game() -> void:
	var vb := _make_vbox(14)
	var cur_hand := _split_hand()
	var cv := BJ.hand_value(cur_hand)
	var phase_ko := "플레이어 차례" if _phase == Phase.PLAYER_TURN else "딜러 차례"
	if _split_active: phase_ko = "스플릿 핸드 1 플레이 중"
	elif not _split.is_empty() and _phase == Phase.PLAYER_TURN: phase_ko = "스플릿 핸드 2 플레이 중"

	_add_blackjack_table_display(vb, _phase != Phase.PLAYER_TURN)

	# 기본전략 힌트
	if _phase == Phase.PLAYER_TURN and _dealer.size() >= 1:
		var hint_action := BJ.basic_strategy(cur_hand, _dealer[0])
		var hint_ko := {"H": "히트", "S": "스탠드", "D": "더블다운", "P": "스플릿"}
		var hint_col := {"H": "#5b9cf6", "S": "#5de89c", "D": "#f0b429", "P": "#d4a0ff"}
		var hs: String = hint_ko.get(hint_action, "?")
		var hc: String = hint_col.get(hint_action, "#aaa")
		var hint_rt := RichTextLabel.new()
		hint_rt.bbcode_enabled = true; hint_rt.fit_content = true; hint_rt.scroll_active = false
		_f(hint_rt); hint_rt.add_theme_font_size_override("normal_font_size", 13)
		hint_rt.text = "기본전략: [color=%s][b]%s[/b][/color]  [color=#3a4a5a](이 힌트를 매번 따르면 기댓값 손실 ~0.5%%)[/color]" % [hc, hs]
		vb.add_child(hint_rt)

	vb.add_child(_sep())

	# 액션 버튼
	if _phase == Phase.PLAYER_TURN:
		var btn_row := HBoxContainer.new()
		btn_row.add_theme_constant_override("separation", 8)
		btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
		vb.add_child(btn_row)

		var hit_btn := _make_btn("히트", _hit, "#1a2a3a", "#3a7abf")
		hit_btn.custom_minimum_size = Vector2(80, 40)
		btn_row.add_child(hit_btn)

		var stand_btn := _make_btn("스탠드", _stand, "#1a3a1a", "#3a9a3a")
		stand_btn.custom_minimum_size = Vector2(80, 40)
		btn_row.add_child(stand_btn)

		# 더블다운: 첫 두 장이고 현금 있을 때
		var can_dbl: bool = cur_hand.size() == 2 and GameState.money >= float(_stake) and not _dbl_down
		var dbl_btn := _make_btn("더블 x2", _double_down, "#2a2a0a", "#9a9a2a")
		dbl_btn.custom_minimum_size = Vector2(80, 40)
		dbl_btn.disabled = not can_dbl
		btn_row.add_child(dbl_btn)

		# 스플릿: 첫 두 장 같은 값
		var can_split: bool = (_split.is_empty() and not _split_active and _player.size() == 2
			and GameState.money >= float(_stake))
		if can_split:
			var v0: int = int(_player[0]) % 13
			var v1: int = int(_player[1]) % 13
			can_split = (mini(v0+1,10) == mini(v1+1,10)) or (v0 >= 9 and v1 >= 9)
		var split_btn := _make_btn("스플릿", _do_split, "#2a0a2a", "#8a3a8a")
		split_btn.custom_minimum_size = Vector2(80, 40)
		split_btn.disabled = not can_split
		btn_row.add_child(split_btn)

		var exit_btn := _make_btn("나가기", _on_exit, "#1a0e0e", "#5a2a2a")
		exit_btn.custom_minimum_size = Vector2(70, 40)
		btn_row.add_child(exit_btn)

func _render_result() -> void:
	var vb := _make_vbox(14)

	_add_blackjack_table_display(vb, true)
	vb.add_child(_sep())

	# 손익
	if not _hand_history.is_empty():
		var last: Dictionary = _hand_history.back()
		var res_lbl := RichTextLabel.new()
		res_lbl.bbcode_enabled = true; res_lbl.fit_content = true; res_lbl.scroll_active = false
		_f(res_lbl, true); res_lbl.add_theme_font_size_override("normal_font_size", 22)
		var col: String = "#5de89c" if bool(last["won"]) else "#e85d5d"
		res_lbl.text = "[color=%s]%s[/color]" % [col, str(last["desc"])]
		vb.add_child(res_lbl)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 10)
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_child(btn_row)
	var again_btn := _make_btn("다음 핸드", func():
		_phase = Phase.BETTING; _render(), "#1a3a1a", "#3de87a")
	again_btn.custom_minimum_size = Vector2(0, 48)
	again_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_f(again_btn, true); btn_row.add_child(again_btn)
	var exit_btn := _make_btn("나가기", _on_exit, "#1a0e0e", "#5a2a2a")
	exit_btn.custom_minimum_size = Vector2(90, 48)
	btn_row.add_child(exit_btn)

func _add_blackjack_betting_mat(parent: VBoxContainer) -> void:
	var mat := Control.new()
	mat.custom_minimum_size = Vector2(1000, 174)
	mat.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mat.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mat.draw.connect(func(): _draw_blackjack_betting_mat(mat))
	parent.add_child(mat)

func _draw_blackjack_betting_mat(ctrl: Control) -> void:
	var sz: Vector2 = ctrl.size
	var font: Font = _font if _font else ThemeDB.fallback_font
	var bold: Font = _font_bold if _font_bold else font
	var felt := Rect2(Vector2(10, 8), sz - Vector2(20, 16))
	ctrl.draw_rect(Rect2(felt.position + Vector2(0, 6), felt.size), Color(0, 0, 0, 0.35), true)
	ctrl.draw_rect(felt, Color("#052512"), true)
	ctrl.draw_rect(felt, Color("#c58f36"), false, 2.0)
	ctrl.draw_string(bold, Vector2(sz.x * 0.5 - 110, 38), "BLACKJACK PAYS 3 TO 2",
		HORIZONTAL_ALIGNMENT_CENTER, 220, 15, Color("#f0d28a"))
	ctrl.draw_string(font, Vector2(sz.x * 0.5 - 140, 62), "Dealer hits soft 17 · Double · Split · Basic strategy",
		HORIZONTAL_ALIGNMENT_CENTER, 280, 10, Color(1, 1, 1, 0.40))
	var bet_center := Vector2(sz.x * 0.5, 118)
	var bet_box := Rect2(bet_center - Vector2(112.0, 38.0), Vector2(224.0, 76.0))
	ctrl.draw_rect(Rect2(bet_box.position + Vector2(0, 4), bet_box.size), Color(0, 0, 0, 0.32), true)
	ctrl.draw_rect(bet_box, Color("#092f18"), true)
	ctrl.draw_rect(bet_box, Color("#f0b429"), false, 1.6)
	ctrl.draw_string(font, bet_box.position + Vector2(0, 18), "BETTING SPOT",
		HORIZONTAL_ALIGNMENT_CENTER, bet_box.size.x, 10, Color(1, 1, 1, 0.42))
	_draw_bj_chip_stack(ctrl, bet_box.position + Vector2(58, 45), _bj_chip_color(_stake), _stake, 30.0)
	ctrl.draw_string(bold, bet_box.position + Vector2(88, 51), GameState.format_money(float(_stake)),
		HORIZONTAL_ALIGNMENT_LEFT, 120, 14, Color("#f0b429"))
	_draw_shoe_box(ctrl, Rect2(Vector2(sz.x - 152, 35), Vector2(92, 76)), font)
	var discard_box := Rect2(Vector2(54.0, 44.0), Vector2(170.0, 72.0))
	ctrl.draw_rect(discard_box, Color(0, 0, 0, 0.12), true)
	ctrl.draw_rect(discard_box, Color(1, 1, 1, 0.10), false, 1.0)
	ctrl.draw_string(font, discard_box.position + Vector2(0, 27), "DEALER AREA",
		HORIZONTAL_ALIGNMENT_CENTER, discard_box.size.x, 10, Color(1, 1, 1, 0.30))

func _add_blackjack_table_display(parent: VBoxContainer, show_dealer_all: bool) -> void:
	var table := Control.new()
	table.custom_minimum_size = Vector2(1000, 340)
	table.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	table.mouse_filter = Control.MOUSE_FILTER_IGNORE
	table.draw.connect(func(): _draw_blackjack_table(table, show_dealer_all))
	parent.add_child(table)

	var dealer_cards: Array = _dealer
	var table_w: float = 1000.0
	var dealer_rect := Rect2(Vector2(74, 32), Vector2(table_w - 148.0, 126))
	var player_rect := Rect2(Vector2(74, 188), Vector2(table_w - 148.0, 126))
	var dealer_start := _bj_card_start(dealer_rect, dealer_cards.size())
	if dealer_cards.size() > 0:
		_place_bj_cards(table, dealer_cards, dealer_start, show_dealer_all, false)
		var dealer_value: int = BJ.hand_value(dealer_cards) if show_dealer_all else BJ.hand_value([dealer_cards[0]])
		var dealer_text := str(dealer_value) if show_dealer_all else (str(dealer_value) + " + ?")
		_add_bj_score_badge(table, _bj_score_pos(dealer_rect), dealer_text, Color("#e85d5d"))

	if _split.is_empty():
		_place_bj_cards(table, _player, _bj_card_start(player_rect, _player.size()), true, _phase == Phase.PLAYER_TURN)
		_add_bj_score_badge(table, _bj_score_pos(player_rect), _bj_score_text(_player), _score_color(_player))
	else:
		var left_rect := Rect2(player_rect.position, Vector2(player_rect.size.x * 0.5, player_rect.size.y))
		var right_rect := Rect2(player_rect.position + Vector2(player_rect.size.x * 0.5, 0), Vector2(player_rect.size.x * 0.5, player_rect.size.y))
		_place_bj_cards(table, _player, _bj_card_start(left_rect, _player.size()), true, _phase == Phase.PLAYER_TURN and not _split_active)
		_add_bj_score_badge(table, _bj_score_pos(left_rect), _bj_score_text(_player), _score_color(_player))
		_place_bj_cards(table, _split, _bj_card_start(right_rect, _split.size()), true, _phase == Phase.PLAYER_TURN and _split_active)
		_add_bj_score_badge(table, _bj_score_pos(right_rect), _bj_score_text(_split), _score_color(_split))

func _draw_blackjack_table(ctrl: Control, show_dealer_all: bool) -> void:
	var sz: Vector2 = ctrl.size
	var font: Font = _font if _font else ThemeDB.fallback_font
	var bold: Font = _font_bold if _font_bold else font
	var felt := Rect2(Vector2(10, 8), sz - Vector2(20, 16))
	ctrl.draw_rect(Rect2(felt.position + Vector2(0, 7), felt.size), Color(0, 0, 0, 0.38), true)
	ctrl.draw_rect(felt, Color("#041d0d"), true)
	ctrl.draw_rect(felt, Color("#c58f36"), false, 2.2)
	var dealer_rect := Rect2(Vector2(74, 32), Vector2(sz.x - 148, 126))
	var player_rect := Rect2(Vector2(74, 188), Vector2(sz.x - 148, 126))
	ctrl.draw_rect(dealer_rect, Color(0, 0, 0, 0.16), true)
	ctrl.draw_rect(dealer_rect, Color("#e85d5d"), false, 1.4)
	ctrl.draw_rect(player_rect, Color(0, 0, 0, 0.16), true)
	ctrl.draw_rect(player_rect, Color("#f0b429"), false, 1.8)
	ctrl.draw_string(bold, dealer_rect.position + Vector2(20, 24), "DEALER",
		HORIZONTAL_ALIGNMENT_LEFT, 160, 15, Color("#ff9c9c"))
	ctrl.draw_string(bold, player_rect.position + Vector2(20, 24), "PLAYER",
		HORIZONTAL_ALIGNMENT_LEFT, 160, 15, Color("#ffe48a"))
	var phase_text := "DEALER REVEAL" if show_dealer_all else "PLAYER ACTION"
	ctrl.draw_string(bold, Vector2(sz.x * 0.5 - 96, 180), phase_text,
		HORIZONTAL_ALIGNMENT_CENTER, 192, 13, Color(1, 1, 1, 0.36))
	var chip_center := player_rect.position + Vector2(132, 96)
	_draw_bj_chip_stack(ctrl, chip_center, _bj_chip_color(_stake), _stake, 28.0)
	ctrl.draw_string(font, chip_center + Vector2(34, 7), "ON TABLE  " + GameState.format_money(float(_stake + _split_stake + (_stake if _dbl_down else 0))),
		HORIZONTAL_ALIGNMENT_LEFT, 240, 11, Color(1, 1, 1, 0.42))
	_draw_shoe_box(ctrl, Rect2(Vector2(sz.x - 150, 52), Vector2(80, 64)), font)

func _bj_card_start(rect: Rect2, card_count: int) -> Vector2:
	var count: int = clampi(card_count, 1, 6)
	var card_size := Vector2(72, 100)
	var gap: float = 6.0
	var block_w: float = card_size.x * float(count) + gap * float(maxi(count - 1, 0))
	return Vector2(
		rect.position.x + (rect.size.x - block_w) * 0.5,
		rect.position.y + (rect.size.y - card_size.y) * 0.5
	)

func _bj_score_pos(rect: Rect2) -> Vector2:
	return rect.position + Vector2(rect.size.x - 238.0, rect.size.y * 0.5 - 22.0)

func _place_bj_cards(parent: Control, cards: Array, start: Vector2, show_all: bool, highlight: bool) -> void:
	for i in range(cards.size()):
		var card_ctrl: Control
		if i == 1 and not show_all:
			card_ctrl = _card_back()
		else:
			card_ctrl = _card_widget(int(cards[i]), highlight)
		_place_bj_child(parent, card_ctrl, start + Vector2(float(i) * 78.0, 0))

func _place_bj_child(parent: Control, child: Control, pos: Vector2) -> void:
	child.position = pos
	child.size = child.custom_minimum_size
	parent.add_child(child)

func _add_bj_score_badge(parent: Control, pos: Vector2, text: String, col: Color) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.position = pos
	lbl.size = Vector2(92, 44)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.add_theme_color_override("font_color", col.lightened(0.24))
	_f(lbl, true)
	parent.add_child(lbl)

func _bj_score_text(hand: Array) -> String:
	if hand.is_empty():
		return "-"
	var value: int = BJ.hand_value(hand)
	var text := str(value)
	if BJ.is_soft(hand):
		text += " soft"
	if value > 21:
		text += " BUST"
	return text

func _score_color(hand: Array) -> Color:
	var value: int = BJ.hand_value(hand)
	if value > 21:
		return Color("#e85d5d")
	if value == 21:
		return Color("#f0b429")
	return Color("#5de89c")

func _bj_chip_color(stake: int) -> Color:
	match stake:
		10_000:
			return Color("#d33a35")
		50_000:
			return Color("#2f65d9")
		100_000:
			return Color("#23a66f")
		500_000:
			return Color("#7a4fd9")
		1_000_000:
			return Color("#d9a12f")
		_:
			return Color("#d33a35")

func _draw_bj_chip_stack(ctrl: Control, center: Vector2, col: Color, stake: int = 0, chip_size: float = 30.0) -> void:
	var raw_tex = CHIP_TEX_BY_STAKE.get(stake, null)
	if raw_tex is Texture2D:
		var tex := raw_tex as Texture2D
		for i in range(3):
			var pos := center + Vector2(float(i) * 2.0, -float(i) * 4.0) - Vector2(chip_size * 0.5, chip_size * 0.5)
			ctrl.draw_texture_rect(tex, Rect2(pos + Vector2(0, 2), Vector2(chip_size, chip_size)), false, Color(0, 0, 0, 0.20))
			ctrl.draw_texture_rect(tex, Rect2(pos, Vector2(chip_size, chip_size)), false)
		return
	for i in range(3):
		var p := center + Vector2(float(i) * 2.0, -float(i) * 4.0)
		ctrl.draw_circle(p + Vector2(0, 2), chip_size * 0.32, Color(0, 0, 0, 0.30))
		ctrl.draw_circle(p, chip_size * 0.32, col)
		ctrl.draw_arc(p, chip_size * 0.23, 0.0, TAU, 24, Color("#f7f2df"), 2.0)
		ctrl.draw_circle(p, chip_size * 0.13, col.darkened(0.20))

func _draw_shoe_box(ctrl: Control, rect: Rect2, font: Font) -> void:
	ctrl.draw_rect(Rect2(rect.position + Vector2(0, 4), rect.size), Color(0, 0, 0, 0.28), true)
	ctrl.draw_rect(rect, Color("#171b25"), true)
	ctrl.draw_rect(rect, Color("#566070"), false, 1.2)
	for i in range(4):
		ctrl.draw_line(rect.position + Vector2(12 + i * 14, 12), rect.position + Vector2(22 + i * 14, rect.size.y - 10), Color(1, 1, 1, 0.20), 1.0)
	ctrl.draw_string(font, rect.position + Vector2(0, rect.size.y - 8), "SHOE",
		HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 9, Color(1, 1, 1, 0.38))

func _draw_dealer_silhouette(ctrl: Control, pos: Vector2) -> void:
	ctrl.draw_circle(pos + Vector2(0, -12), 14.0, Color(0, 0, 0, 0.24))
	ctrl.draw_rect(Rect2(pos + Vector2(-30, 5), Vector2(60, 34)), Color(0, 0, 0, 0.20), true)
	ctrl.draw_line(pos + Vector2(20, 14), pos + Vector2(96, 52), Color(0, 0, 0, 0.20), 5.0)

# ── UI 헬퍼 ───────────────────────────────────────────────────
func _build_skeleton() -> void:
	const _BG = "res://assets/backgrounds/casino_interior.png"
	var base_bg := ColorRect.new()
	base_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	base_bg.color = Color("#06090e")
	base_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(base_bg)
	if ResourceLoader.exists(_BG):
		var bg_img := TextureRect.new()
		bg_img.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg_img.stretch_mode = TextureRect.STRETCH_SCALE
		bg_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bg_img.texture = load(_BG) as Texture2D
		bg_img.modulate = Color(1, 1, 1, 0.48)
		add_child(bg_img)
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#06090e")
	bg.color.a = 0.62 if ResourceLoader.exists(_BG) else 1.0
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var hud_p := Panel.new()
	hud_p.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hud_p.offset_bottom = 42
	var hs := StyleBoxFlat.new()
	hs.bg_color = Color("#0a0e18"); hs.border_color = Color("#1a2438"); hs.border_width_bottom = 1
	hud_p.add_theme_stylebox_override("panel", hs)
	add_child(hud_p)
	_hud_lbl = RichTextLabel.new()
	_hud_lbl.bbcode_enabled = true; _hud_lbl.fit_content = true; _hud_lbl.scroll_active = false
	_hud_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hud_lbl.offset_left = 20; _hud_lbl.offset_top = 10
	_f(_hud_lbl); _hud_lbl.add_theme_font_size_override("normal_font_size", 14)
	hud_p.add_child(_hud_lbl)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 50; scroll.offset_bottom = -10
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	_content_root = CenterContainer.new()
	_content_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(_content_root)

	_msg_lbl = RichTextLabel.new()
	_msg_lbl.bbcode_enabled = true
	_msg_lbl.fit_content = true
	_msg_lbl.scroll_active = false
	_msg_lbl.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_msg_lbl.offset_top = -40
	_msg_lbl.offset_bottom = -10
	_msg_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_f(_msg_lbl, true)
	_msg_lbl.add_theme_font_size_override("normal_font_size", 16)
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
	var table := PanelContainer.new()
	table.custom_minimum_size = Vector2(1080, 0)
	table.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	table.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var table_sty := StyleBoxFlat.new()
	table_sty.bg_color = Color("#041609")
	table_sty.border_color = Color("#c58f36")
	table_sty.set_border_width_all(3)
	table_sty.set_corner_radius_all(18)
	table_sty.shadow_color = Color(0, 0, 0, 0.55)
	table_sty.shadow_size = 16
	table_sty.shadow_offset = Vector2(0, 8)
	table.add_theme_stylebox_override("panel", table_sty)
	_content_root.add_child(table)

	var m := MarginContainer.new()
	m.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	m.add_theme_constant_override("margin_left", 24)
	m.add_theme_constant_override("margin_right", 24)
	m.add_theme_constant_override("margin_top", 22)
	m.add_theme_constant_override("margin_bottom", 22)
	table.add_child(m)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", sep)
	m.add_child(vb)
	return vb

func _card_widget(card: int, highlight := false) -> Control:
	var root := Control.new()
	root.custom_minimum_size = Vector2(72, 100)

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
		st.bg_color = Color("#f8f4e8") if not highlight else Color("#fff8e0")
		st.border_color = Color("#f0b429") if highlight else Color("#b8aa8a")
		st.set_border_width_all(2 if highlight else 1)
		st.set_corner_radius_all(7)
		st.shadow_color = Color(0, 0, 0, 0.35)
		st.shadow_size = 5
		st.shadow_offset = Vector2(0, 2)
		panel.add_theme_stylebox_override("panel", st)
		root.add_child(panel)

	if highlight:
		var ring := Panel.new()
		ring.set_anchors_preset(Control.PRESET_FULL_RECT)
		var ring_st := StyleBoxFlat.new()
		ring_st.bg_color = Color(1.0, 0.92, 0.45, 0.12)
		ring_st.border_color = Color("#f0b429")
		ring_st.set_border_width_all(2)
		ring_st.set_corner_radius_all(7)
		ring.add_theme_stylebox_override("panel", ring_st)
		root.add_child(ring)

	var col := Color("#d73939") if BJ.is_red(card) else Color("#141827")
	var rank := _card_rank_text(card)
	var suit := _card_suit_text(card)

	var corner := Label.new()
	corner.text = rank + "\n" + suit
	corner.set_anchors_preset(Control.PRESET_TOP_LEFT)
	corner.offset_left = 7; corner.offset_top = 5
	corner.offset_right = 32; corner.offset_bottom = 42
	corner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	corner.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	corner.add_theme_font_size_override("font_size", 13)
	corner.add_theme_color_override("font_color", col)
	if _font_bold: corner.add_theme_font_override("font", _font_bold)
	root.add_child(corner)

	var center := Label.new()
	center.text = suit
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	center.add_theme_font_size_override("font_size", 38)
	center.add_theme_color_override("font_color", col)
	if _font_bold: center.add_theme_font_override("font", _font_bold)
	root.add_child(center)

	var bottom := Label.new()
	bottom.text = rank
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	bottom.offset_left = -32; bottom.offset_top = -26
	bottom.offset_right = -7; bottom.offset_bottom = -4
	bottom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bottom.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bottom.add_theme_font_size_override("font_size", 12)
	bottom.add_theme_color_override("font_color", col.darkened(0.08))
	if _font_bold: bottom.add_theme_font_override("font", _font_bold)
	root.add_child(bottom)

	_animate_card_appear(root)
	return root

func _card_back() -> Control:
	if CARD_BACK_TEX != null:
		var tex := TextureRect.new()
		tex.custom_minimum_size = Vector2(72, 100)
		tex.texture = CARD_BACK_TEX
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		return tex
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(72, 100)
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#12244a"); st.border_color = Color("#2a4a8a")
	st.set_border_width_all(1); st.set_corner_radius_all(5)
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

func _make_btn(label: String, cb: Callable, bg: String, border: String) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color(bg); st.border_color = Color(border)
	st.set_border_width_all(1); st.set_corner_radius_all(6)
	st.content_margin_left = 10; st.content_margin_right = 10
	st.content_margin_top = 6; st.content_margin_bottom = 6
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

func _sep() -> HSeparator:
	var s := HSeparator.new()
	s.add_theme_color_override("color", Color("#151825"))
	return s

func _flash(msg: String, color: String) -> void:
	if not is_instance_valid(_msg_lbl): return
	_msg_lbl.text = msg
	_msg_lbl.add_theme_color_override("default_color", Color(color))
	_msg_lbl.visible = true
	get_tree().create_timer(2.0).timeout.connect(func():
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
	panel.position = Vector2((root_size.x - panel.size.x) * 0.5, maxf(520.0, root_size.y - 190.0))
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

func _shake_node(node: Node, amount: float = 6.0, count: int = 5) -> void:
	if not is_instance_valid(node) or not (node is Control):
		return
	var ctrl := node as Control
	var base := ctrl.position
	var step_dur: float = 0.06
	var tw := create_tween()
	for _i in range(count):
		var offset := Vector2(randf_range(-amount, amount), randf_range(-amount * 0.45, amount * 0.45))
		tw.tween_property(ctrl, "position", base + offset, step_dur)
	tw.tween_property(ctrl, "position", base, 0.04)

func _animate_card_appear(ctrl: Control) -> void:
	ctrl.modulate = Color(1, 1, 1, 0)
	var tw := create_tween()
	tw.tween_property(ctrl, "modulate", Color(1, 1, 1, 1), 0.15)

func _show_table_banner_bj(text: String, color: Color) -> void:
	var root_size := size
	if root_size.x <= 1.0 or root_size.y <= 1.0:
		root_size = get_viewport_rect().size
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.z_index = 76
	panel.size = Vector2(minf(420.0, root_size.x - 48.0), 72.0)
	panel.position = Vector2((root_size.x - panel.size.x) * 0.5, maxf(510.0, root_size.y - 210.0))
	panel.modulate = Color(1, 1, 1, 0.0)
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.36, 0.28, 0.02, 0.92)
	st.border_color = color
	st.set_border_width_all(3)
	st.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", st)
	add_child(panel)
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 32)
	lbl.add_theme_color_override("font_color", color)
	_f(lbl, true)
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(lbl)
	panel.scale = Vector2(0.8, 0.8)
	panel.pivot_offset = panel.size * 0.5
	var tw := create_tween()
	tw.tween_property(panel, "modulate:a", 1.0, 0.06)
	tw.tween_property(panel, "scale", Vector2(1.2, 1.2), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.72)
	tw.tween_property(panel, "modulate:a", 0.0, 0.18)
	tw.tween_callback(panel.queue_free)

func _pulse_node(node: Node, scale_to: float = 1.08, duration: float = 0.28) -> void:
	if not is_instance_valid(node) or not (node is Control):
		return
	var ctrl := node as Control
	var base := ctrl.scale
	ctrl.pivot_offset = ctrl.size * 0.5
	var tw := create_tween()
	tw.tween_property(ctrl, "scale", base * scale_to, duration * 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(ctrl, "scale", base, duration * 0.58).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
