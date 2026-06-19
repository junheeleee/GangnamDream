extends Control
## HoldemClub — 지하 홀덤 클럽 시각 레이어.
## TexasHoldem 모델(순수 수학) 위에 UI+게임 흐름 구현.
## MainGame이 entered_network 플래그 확인 후 overlay로 붙이고 open()으로 표시.

signal closed

const TH := preload("res://systems/TexasHoldem.gd")
const CARD_BACK_TEX := preload("res://assets/ui/card_back.png")
const CARD_FRONT_TEX := preload("res://assets/ui/card_front_base.svg")
const CHIP_TEX := preload("res://assets/ui/poker_chip_icon.png")

const SMALL_BLIND := 5_000
const BIG_BLIND   := 10_000
const VALID_BUYINS := [50_000, 100_000, 200_000, 500_000]

enum Phase { SETUP, PREFLOP, FLOP, TURN, RIVER, SHOWDOWN, RESULT }

var _phase: int = Phase.SETUP
var _deck: Array = []
var _community: Array = []        # 공개된 커뮤니티 카드 0~5
var _hole: Array = []             # 플레이어 홀 카드 2장
var _opp: Array = [               # AI 상대 2명
	{"name": "조용한 남자", "hole": [], "folded": false, "stack": 0, "aggression": 0.25},
	{"name": "소란스러운 여자", "hole": [], "folded": false, "stack": 0, "aggression": 0.72},
]
var _pot: int = 0
var _player_stack: int = 0
var _player_bet: int = 0          # 이번 베팅 라운드에 낸 금액
var _opp_bets: Array = [0, 0]
var _max_bet: int = 0             # 이번 라운드 최고 베팅
var _player_folded: bool = false
var _buy_in: int = 100_000
var _net_session: int = 0         # 이번 방문 누적 수익
var _hands_played: int = 0
var _turn_order: Array = [0, 1, 2]  # 0=플레이어, 1,2=AI
var _action_idx: int = 0          # turn_order 내 현재 차례
var _rng := RandomNumberGenerator.new()

# 핸드 히스토리 (최근 8핸드)
var _hand_history: Array = []     # [{won, net, hand_rank, desc}]
var _session_won: int = 0
var _session_lost: int = 0
var _custom_raise_amount: int = 0  # 커스텀 레이즈 입력값 (0이면 미입력)

# UI 노드
var _header_lbl: RichTextLabel
var _pot_lbl: Label
var _community_row: HBoxContainer
var _hole_row: HBoxContainer
var _opp_rows: Array = []
var _msg_lbl: RichTextLabel
var _action_panel: Control
var _stack_lbl: Label
var _flash_layer: ColorRect
var _last_phase_banner := ""
var _font: FontFile
var _font_bold: FontFile

func _ready() -> void:
	_rng.randomize()
	_load_fonts()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)  # 오프셋까지 0 — 루트 0x0 collapse 방지
	_build_ui()
	visible = false

func _load_fonts() -> void:
	_font      = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile

func _f(n: Control, bold := false) -> void:
	var ft = _font_bold if bold else _font
	if ft and n:
		n.add_theme_font_override("font", ft)
		if n is RichTextLabel:
			n.add_theme_font_override("normal_font", ft)
			n.add_theme_font_override("bold_font", _font_bold if _font_bold else ft)

# ── 진입 ──────────────────────────────────────────────────────────
func open() -> void:
	_net_session = 0
	_hands_played = 0
	# 마스터리에 따라 AI 공격성 강화 (베테랑 플레이어 = 더 어려운 상대)
	var mastery: int = MetaProgression.get_mastery("holdem")
	if mastery >= 1:
		_opp[0]["aggression"] = 0.40  # 숙련: 조용한 남자가 더 과감해짐
	if mastery >= 2:
		_opp[1]["aggression"] = 0.85  # 고급: 소란스러운 여자 최대 공격성
	if mastery >= 3:
		_opp[0]["aggression"] = 0.55  # 마스터: 둘 다 강해짐
	_show_buyin_screen()
	visible = true
	TutorialOverlay.maybe_show("holdem", self)
	AudioManager.play("tab_open")

func _show_buyin_screen() -> void:
	_phase = Phase.SETUP
	_clear_content()
	var vb := _content_vbox()

	var title := Label.new()
	title.text = "지하 홀덤 클럽"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("#f0b429"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_f(title, true)
	vb.add_child(title)

	var sub := Label.new()
	sub.text = "No-Limit Texas Hold'em  ·  5,000 / 10,000 블라인드"
	sub.add_theme_font_size_override("font_size", 12)
	sub.add_theme_color_override("font_color", Color("#5a6075"))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_f(sub)
	vb.add_child(sub)

	var money_lbl := Label.new()
	money_lbl.text = "보유 현금: %s" % _fmt(GameState.money)
	money_lbl.add_theme_font_size_override("font_size", 13)
	money_lbl.add_theme_color_override("font_color", Color("#a0c8a0"))
	money_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_f(money_lbl)
	vb.add_child(money_lbl)

	vb.add_child(_sep())

	var info := RichTextLabel.new()
	info.bbcode_enabled = true
	info.text = "[color=#7a8a9a]• 상대방 2명과 1:1:1 대결\n• 상금은 모두 테이블 위로\n• 언제든 자리를 뜰 수 있습니다[/color]"
	info.fit_content = true
	info.scroll_active = false
	_f(info)
	vb.add_child(info)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 12)
	vb.add_child(spacer)

	var buy_lbl := Label.new()
	buy_lbl.text = "바이인 금액 선택"
	buy_lbl.add_theme_font_size_override("font_size", 13)
	buy_lbl.add_theme_color_override("font_color", Color("#c0c8d0"))
	_f(buy_lbl, true)
	vb.add_child(buy_lbl)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_child(btn_row)

	for bi in VALID_BUYINS:
		var can_afford: bool = GameState.money >= float(bi)
		var b := _make_btn(_fmt(bi), func():
			_buy_in = bi
			_start_hand()
		, "#1a3a2a" if can_afford else "#1a1a1a")
		b.disabled = not can_afford
		b.custom_minimum_size = Vector2(90, 38)
		btn_row.add_child(b)

	vb.add_child(_sep())

	var rules_btn := _make_btn("게임 규칙 보기", func(): TutorialOverlay.force_show("holdem", self), "#0a0a1a")
	rules_btn.custom_minimum_size = Vector2(0, 38)
	vb.add_child(rules_btn)

	var leave := _make_btn("자리를 뜬다", _leave, "#2a1818")
	vb.add_child(leave)

# ── 핸드 시작 ─────────────────────────────────────────────────────
func _start_hand() -> void:
	_hands_played += 1
	_player_stack = _buy_in if _hands_played == 1 else _player_stack
	if _player_stack < BIG_BLIND:
		_show_result_screen()
		return

	for o in _opp:
		if _hands_played == 1:
			o["stack"] = _buy_in
		o["folded"] = false
		o["hole"] = []

	_deck = TH.new_deck()
	TH.shuffle(_deck, _rng)
	_community = []
	_hole = [_deck.pop_back(), _deck.pop_back()]
	for o in _opp:
		o["hole"] = [_deck.pop_back(), _deck.pop_back()]

	_player_folded = false
	_pot = 0
	_player_bet = 0
	_opp_bets = [0, 0]
	_max_bet = 0

	# 포스트 블라인드 (플레이어=SB, opp0=BB)
	_post_blind(0, SMALL_BLIND, true)   # 플레이어 SB
	_post_blind(1, BIG_BLIND, false)    # opp0 BB

	_phase = Phase.PREFLOP
	_action_idx = 0  # 플레이어 먼저 (SB acts first preflop in simplified version)
	_render_table()
	_show_table_banner("NEW HAND", Color("#c9a227"), 0.65)
	_spawn_chip_burst(Color("#f0b429"), Vector2(0.50, 0.47), 6)
	_screen_flash(Color("#c9a227"), 0.10, 0.22)
	# 홀 카드 딜 애니메이션 — 카드 2장 순서대로 scale 팝
	if is_instance_valid(_hole_row):
		var delay := 0.0
		for card in _hole_row.get_children():
			card.scale = Vector2(0.0, 0.0)
			var tw := create_tween()
			tw.tween_interval(delay)
			tw.tween_property(card, "scale", Vector2(1.0, 1.0), 0.20).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			delay += 0.18
	_process_action_turn()

func _post_blind(who: int, amount: int, is_player: bool) -> void:
	var actual := mini(amount, _player_stack if is_player else _opp[who if not is_player else 0]["stack"])
	if is_player:
		_player_stack -= actual
		_player_bet = actual
	else:
		_opp[who]["stack"] -= actual
		_opp_bets[who] = actual
	_pot += actual
	_max_bet = maxi(_max_bet, actual)

# ── 테이블 렌더 ───────────────────────────────────────────────────
func _render_table() -> void:
	_clear_content()
	_opp_rows = []
	var root := _content_vbox()

	# 헤더 + 세션 통계
	var hdr := RichTextLabel.new()
	hdr.bbcode_enabled = true
	var phase_names := ["설정", "프리플랍", "플랍", "턴", "리버", "쇼다운", "결과"]
	var winrate_str: String = ""
	var total_hands := _session_won + _session_lost
	if total_hands > 0:
		winrate_str = "   [color=#5a6a7a]승률 %d%% (%dW/%dL)[/color]" % [
			roundi(float(_session_won) / float(total_hands) * 100.0), _session_won, _session_lost]
	hdr.text = "[b][color=#f0b429]지하 홀덤 클럽[/color][/b]   [color=#3a4a5a]%s[/color]%s" % [
		phase_names[_phase], winrate_str]
	hdr.fit_content = true
	hdr.scroll_active = false
	_f(hdr, true)
	root.add_child(hdr)

	# 핸드 히스토리 (최근 8핸드 컴팩트 표시)
	if not _hand_history.is_empty():
		var hist_rt := RichTextLabel.new()
		hist_rt.bbcode_enabled = true; hist_rt.fit_content = true; hist_rt.scroll_active = false
		_f(hist_rt); hist_rt.add_theme_font_size_override("normal_font_size", 11)
		var parts: Array = []
		for h in _hand_history:
			var col := "#5de89c" if h["won"] else "#e85d5d"
			var icon := "▲" if h["won"] else "▼"
			parts.append("[color=%s]%s%s[/color]" % [col, icon, str(h["hand"]).substr(0, 3)])
		hist_rt.text = "히스토리: " + "  ".join(parts)
		root.add_child(hist_rt)

	var pot_box := HBoxContainer.new()
	pot_box.alignment = BoxContainer.ALIGNMENT_CENTER
	pot_box.add_theme_constant_override("separation", 8)
	root.add_child(pot_box)
	if CHIP_TEX != null:
		var chip := TextureRect.new()
		chip.custom_minimum_size = Vector2(24, 24)
		chip.texture = CHIP_TEX
		chip.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		chip.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pot_box.add_child(chip)
	_pot_lbl = Label.new()
	_pot_lbl.text = "POT  %s" % _fmt(_pot)
	_pot_lbl.add_theme_font_size_override("font_size", 18)
	_pot_lbl.add_theme_color_override("font_color", Color("#f0b429"))
	_f(_pot_lbl, true)
	pot_box.add_child(_pot_lbl)

	root.add_child(_sep())

	# AI 상대들
	for i in range(2):
		var o = _opp[i]
		var opp_row := HBoxContainer.new()
		opp_row.add_theme_constant_override("separation", 8)
		root.add_child(opp_row)
		_opp_rows.append(opp_row)

		var name_lbl := Label.new()
		name_lbl.text = "[X] %s" % o["name"] if o["folded"] else o["name"]
		name_lbl.add_theme_font_size_override("font_size", 12)
		name_lbl.add_theme_color_override("font_color", Color("#5a5a5a") if o["folded"] else Color("#a0b0c0"))
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_f(name_lbl)
		opp_row.add_child(name_lbl)

		# 카드 (쇼다운 때만 공개)
		var card_row := HBoxContainer.new()
		card_row.add_theme_constant_override("separation", 4)
		opp_row.add_child(card_row)
		if _phase == Phase.SHOWDOWN and not o["folded"]:
			for c in o["hole"]:
				card_row.add_child(_card_label(c))
		else:
			for _j in range(2):
				card_row.add_child(_card_back())

		var stack_lbl := Label.new()
		stack_lbl.text = _fmt(o["stack"])
		stack_lbl.add_theme_font_size_override("font_size", 12)
		stack_lbl.add_theme_color_override("font_color", Color("#6a8a6a"))
		stack_lbl.custom_minimum_size = Vector2(80, 0)
		stack_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_f(stack_lbl)
		opp_row.add_child(stack_lbl)

	root.add_child(_sep())

	# 커뮤니티 카드
	var community_box := VBoxContainer.new()
	community_box.add_theme_constant_override("separation", 4)
	root.add_child(community_box)
	var comm_lbl := Label.new()
	comm_lbl.text = "커뮤니티"
	comm_lbl.add_theme_font_size_override("font_size", 10)
	comm_lbl.add_theme_color_override("font_color", Color("#4a5a6a"))
	_f(comm_lbl)
	community_box.add_child(comm_lbl)
	var comm_row := HBoxContainer.new()
	comm_row.add_theme_constant_override("separation", 6)
	community_box.add_child(comm_row)
	_community_row = comm_row
	for c in _community:
		comm_row.add_child(_card_label(c))
	for _j in range(5 - _community.size()):
		comm_row.add_child(_card_placeholder())

	root.add_child(_sep())

	# 내 카드 + 스택
	var my_box := HBoxContainer.new()
	my_box.add_theme_constant_override("separation", 10)
	root.add_child(my_box)
	var my_lbl := Label.new()
	my_lbl.text = "내 패"
	my_lbl.add_theme_font_size_override("font_size", 10)
	my_lbl.add_theme_color_override("font_color", Color("#4a5a6a"))
	my_lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_f(my_lbl)
	my_box.add_child(my_lbl)
	var my_card_row := HBoxContainer.new()
	my_card_row.add_theme_constant_override("separation", 6)
	my_box.add_child(my_card_row)
	_hole_row = my_card_row
	for c in _hole:
		my_card_row.add_child(_card_label(c, true))
	var my_spacer := Control.new()
	my_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	my_box.add_child(my_spacer)
	var my_stack := Label.new()
	my_stack.text = "🪙 %s" % _fmt(_player_stack)
	my_stack.add_theme_font_size_override("font_size", 13)
	my_stack.add_theme_color_override("font_color", Color("#a0c8a0"))
	my_stack.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_f(my_stack, true)
	my_box.add_child(my_stack)
	_stack_lbl = my_stack

	# 핸드 힌트 (현재 베스트 핸드)
	if not _community.is_empty() and not _player_folded:
		var hand := TH.best_hand(_hole + _community)
		var hint := Label.new()
		hint.text = "현재: %s" % TH.rank_name(hand[0])
		hint.add_theme_font_size_override("font_size", 11)
		hint.add_theme_color_override("font_color", Color("#c9a227"))
		_f(hint)
		root.add_child(hint)

	# 메시지 (BBCode 지원 RichTextLabel)
	_msg_lbl = RichTextLabel.new()
	_msg_lbl.bbcode_enabled = true
	_msg_lbl.text = ""
	_msg_lbl.add_theme_font_size_override("normal_font_size", 12)
	_msg_lbl.fit_content = true
	_msg_lbl.scroll_active = false
	_msg_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_f(_msg_lbl)
	root.add_child(_msg_lbl)

	# 액션 버튼 영역
	_action_panel = HBoxContainer.new()
	_action_panel.add_theme_constant_override("separation", 8)
	root.add_child(_action_panel)

# ── 행동 순서 처리 ─────────────────────────────────────────────────
func _process_action_turn() -> void:
	# 남은 플레이어가 1명이면 즉시 쇼다운
	var active := _count_active()
	if active <= 1:
		_do_showdown()
		return

	# 이번 라운드 베팅이 모두 맞아있으면 다음 단계
	if _betting_complete():
		_advance_phase()
		return

	# 차례 찾기 (folded 건너뜀)
	while true:
		_action_idx = _action_idx % 3
		var who: int = _turn_order[_action_idx]
		if (who == 0 and _player_folded) or (who != 0 and _opp[who - 1]["folded"]):
			_action_idx += 1
			continue
		break

	var who: int = _turn_order[_action_idx]
	if who == 0:
		_show_player_actions()
	else:
		_do_ai_action(who - 1)

func _betting_complete() -> bool:
	if _player_folded and _opp[0]["folded"] and _opp[1]["folded"]:
		return true
	# 액티브 플레이어 모두 max_bet에 맞췄거나 all-in인지 확인
	if not _player_folded:
		if _player_bet < _max_bet and _player_stack > 0:
			return false
	for i in range(2):
		if not _opp[i]["folded"]:
			if _opp_bets[i] < _max_bet and _opp[i]["stack"] > 0:
				return false
	return true

func _count_active() -> int:
	var n := 0
	if not _player_folded: n += 1
	for o in _opp:
		if not o["folded"]: n += 1
	return n

# ── 플레이어 액션 UI ───────────────────────────────────────────────
func _show_player_actions() -> void:
	var to_call: int = _max_bet - _player_bet
	var pot_odds_pct: int = 0
	if to_call > 0:
		pot_odds_pct = roundi(float(to_call) / float(maxi(_pot + to_call, 1)) * 100.0)
	var strength := TH.hand_strength(_hole, _community)
	var win_pct: int = roundi(strength * 100.0)

	var msg := "당신의 차례"
	if to_call > 0:
		var equity_str: String
		if win_pct > pot_odds_pct + 10:
			equity_str = " — [color=#5de89c]+EV 콜 (승률%d%% > 팟오즈%d%%)[/color]" % [win_pct, pot_odds_pct]
		elif win_pct < pot_odds_pct - 5:
			equity_str = " — [color=#e85d5d]-EV 폴드 권장 (승률%d%% < 팟오즈%d%%)[/color]" % [win_pct, pot_odds_pct]
		else:
			equity_str = " — [color=#e8c45d]팟오즈 %d%% / 핸드강도 %d%%[/color]" % [pot_odds_pct, win_pct]
		msg += equity_str
	_set_msg(msg)

	for ch in _action_panel.get_children():
		ch.queue_free()

	# 액션 버튼을 VBox로 래핑
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_action_panel.add_child(vbox)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 6)
	vbox.add_child(btn_row)

	# Fold
	var fold_btn := _make_btn("폴드", func(): _player_action("fold", 0), "#3a1818")
	fold_btn.custom_minimum_size = Vector2(70, 36)
	btn_row.add_child(fold_btn)

	# Check or Call
	if to_call == 0:
		var check_btn := _make_btn("체크", func(): _player_action("check", 0), "#1a2a3a")
		check_btn.custom_minimum_size = Vector2(70, 36)
		btn_row.add_child(check_btn)
	else:
		var can_call := _player_stack > 0
		var call_lbl := "콜  %s" % _fmt(mini(to_call, _player_stack))
		var call_btn := _make_btn(call_lbl, func(): _player_action("call", to_call), "#1a3a2a")
		call_btn.disabled = not can_call
		call_btn.custom_minimum_size = Vector2(80, 36)
		btn_row.add_child(call_btn)

	# Raise / All-in 프리셋
	var min_raise := mini(to_call + BIG_BLIND, _player_stack)
	var third_pot  := mini(int(float(_pot) * 0.33) + to_call, _player_stack)
	var half_pot   := mini(int(float(_pot) * 0.5) + to_call, _player_stack)
	var pot_raise  := mini(_pot + to_call, _player_stack)

	if _player_stack > to_call:
		var raise_options: Array = []
		if third_pot > min_raise:
			raise_options.append(["1/3팟\n%s" % _fmt(third_pot), third_pot])
		if half_pot > third_pot:
			raise_options.append(["하프팟\n%s" % _fmt(half_pot), half_pot])
		if pot_raise > half_pot:
			raise_options.append(["팟\n%s" % _fmt(pot_raise), pot_raise])
		raise_options.append(["올인\n%s" % _fmt(_player_stack), _player_stack])

		for opt in raise_options:
			var amt: int = opt[1]
			var raise_btn := _make_btn(opt[0], func(): _player_action("raise", amt), "#3a2a18")
			raise_btn.custom_minimum_size = Vector2(72, 40)
			btn_row.add_child(raise_btn)

	# 나가기
	var leave_btn := _make_btn("자리를\n뜬다", _leave_mid, "#2a1a1a")
	leave_btn.custom_minimum_size = Vector2(70, 40)
	btn_row.add_child(leave_btn)

func _player_action(action: String, amount: int) -> void:
	AudioManager.play("click")
	for ch in _action_panel.get_children():
		ch.queue_free()

	var to_call: int = _max_bet - _player_bet
	match action:
		"fold":
			_player_folded = true
			_set_msg("폴드했습니다.")
			_show_table_banner("FOLD", Color("#d73a49"), 0.48)
			_screen_flash(Color("#d73a49"), 0.08, 0.18)
		"check":
			_set_msg("체크.")
			_show_table_banner("CHECK", Color("#7a8a9a"), 0.42)
		"call":
			var actual := mini(to_call, _player_stack)
			_player_stack -= actual
			_player_bet += actual
			_pot += actual
			_set_msg("콜 (%s)." % _fmt(actual))
			AudioManager.play("sell", -6.0)
			_show_table_banner("CALL", Color("#5de89c"), 0.45)
			_spawn_chip_burst(Color("#5de89c"), Vector2(0.50, 0.56), 4)
			_pulse_node(_msg_lbl, 1.04, 0.18)
		"raise":
			var actual := mini(amount, _player_stack)
			_player_stack -= actual
			_player_bet += actual
			_pot += actual
			_max_bet = maxi(_max_bet, _player_bet)
			_set_msg("레이즈 → %s" % _fmt(_player_bet))
			AudioManager.play("money_big" if actual >= 200_000 else "sell")
			_show_table_banner("RAISE", Color("#f0b429"), 0.58)
			_spawn_chip_burst(Color("#f0b429"), Vector2(0.50, 0.56), 8)
			_screen_flash(Color("#f0b429"), 0.13, 0.22)
			_shake_node(_content_root, 4.0, 0.16)

	_action_idx += 1
	await get_tree().create_timer(0.3).timeout
	_render_table()
	_process_action_turn()

# ── AI 행동 ───────────────────────────────────────────────────────
func _do_ai_action(opp_idx: int) -> void:
	var o = _opp[opp_idx]
	var to_call: int = _max_bet - int(_opp_bets[opp_idx])
	var decision := TH.ai_decide(o["hole"], _community, _pot, to_call, o["stack"],
			float(o["aggression"]), _rng)

	_set_msg("%s: %s" % [o["name"], _action_to_korean(decision["action"])])

	match decision["action"]:
		"fold":
			o["folded"] = true
			_show_table_banner("%s  FOLD" % o["name"], Color("#8a5a5a"), 0.46)
		"check":
			_show_table_banner("%s  CHECK" % o["name"], Color("#7a8a9a"), 0.42)
		"call":
			var actual := mini(to_call, o["stack"])
			o["stack"] -= actual
			_opp_bets[opp_idx] += actual
			_pot += actual
			AudioManager.play("sell", -8.0)
			_show_table_banner("%s  CALL" % o["name"], Color("#5de89c"), 0.45)
			_spawn_chip_burst(Color("#5de89c"), Vector2(0.50, 0.40), 3)
		"raise":
			var actual := mini(int(decision["amount"]), o["stack"])
			o["stack"] -= actual
			_opp_bets[opp_idx] += actual
			_pot += actual
			_max_bet = maxi(_max_bet, _opp_bets[opp_idx])
			AudioManager.play("sell", -5.0)
			_show_table_banner("%s  RAISE" % o["name"], Color("#f0b429"), 0.55)
			_spawn_chip_burst(Color("#f0b429"), Vector2(0.50, 0.40), 6)
			_screen_flash(Color("#f0b429"), 0.08, 0.16)

	_action_idx += 1
	await get_tree().create_timer(0.6).timeout
	_render_table()
	_process_action_turn()

func _action_to_korean(action: String) -> String:
	match action:
		"fold": return "폴드"
		"check": return "체크"
		"call": return "콜"
		"raise": return "레이즈"
	return action

# ── 페이즈 전환 ────────────────────────────────────────────────────
func _advance_phase() -> void:
	# 라운드 베팅 초기화
	_player_bet = 0
	_opp_bets = [0, 0]
	_max_bet = 0
	_action_idx = 0
	var banner := ""

	match _phase:
		Phase.PREFLOP:
			_community.append(_deck.pop_back())
			_community.append(_deck.pop_back())
			_community.append(_deck.pop_back())
			_phase = Phase.FLOP
			banner = "FLOP"
		Phase.FLOP:
			_community.append(_deck.pop_back())
			_phase = Phase.TURN
			banner = "TURN"
		Phase.TURN:
			_community.append(_deck.pop_back())
			_phase = Phase.RIVER
			banner = "RIVER"
		Phase.RIVER:
			_do_showdown()
			return

	var new_cards := 1 if banner in ["TURN", "RIVER"] else 3
	_render_table()
	AudioManager.play("tab_open", -4.0)
	_show_table_banner(banner, Color("#c9a227"), 0.62)
	_screen_flash(Color("#c9a227"), 0.09, 0.20)
	# 새로 공개된 카드들 scale 0→1 순차 팝인
	if is_instance_valid(_community_row):
		var total: int = _community_row.get_child_count()
		var start_idx: int = total - new_cards - (5 - _community.size())
		var delay := 0.0
		for ci in range(new_cards):
			var idx := start_idx + ci
			if idx >= 0 and idx < total:
				var card = _community_row.get_child(idx)
				card.scale = Vector2(0.0, 0.0)
				var tw := create_tween()
				tw.tween_interval(delay)
				tw.tween_property(card, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				delay += 0.14
	_process_action_turn()

func _do_showdown() -> void:
	_phase = Phase.SHOWDOWN

	# 승자 결정
	var winner_idx := -1   # -1=플레이어 1등, 0,1=AI index
	var best_hand: Array = []
	if not _player_folded:
		best_hand = TH.best_hand(_hole + _community)
		winner_idx = -1

	for i in range(2):
		if not _opp[i]["folded"]:
			var opp_hand := TH.best_hand(_opp[i]["hole"] + _community)
			if best_hand.is_empty() or opp_hand > best_hand:
				best_hand = opp_hand
				winner_idx = i

	# 팟 분배
	var msg_parts: Array = []
	var hand_net: int = 0
	if winner_idx == -1:
		# 플레이어 승
		_player_stack += _pot
		hand_net = _pot
		_net_session += _pot - _buy_in if _hands_played == 1 else _pot
		_session_won += 1
		msg_parts.append("🎉 %s으로 승리! +%s" % [TH.rank_name(best_hand[0]), _fmt(_pot)])
		GameState.modify_hidden_stat("gambling_tendency", 3)
		AudioManager.play("money_big" if _pot >= 1_000_000 else "money_gain")
		_screen_flash(Color("#f0b429"), 0.22, 0.42)
	else:
		# AI 승
		_opp[winner_idx]["stack"] += _pot
		hand_net = -_pot
		_net_session -= _pot if _hands_played == 1 else 0
		_session_lost += 1
		msg_parts.append("😔 %s가 이겼습니다 (%s)" % [_opp[winner_idx]["name"], TH.rank_name(best_hand[0])])
		GameState.modify_hidden_stat("addiction_tendency", 2)
		AudioManager.play("money_loss")
		_screen_flash(Color("#d73a49"), 0.22, 0.38)
		_shake_node(_content_root, 8.0, 0.28)

	# 핸드 히스토리 기록
	var hand_rank_name: String = TH.rank_name(best_hand[0]) if not best_hand.is_empty() else "?"
	_hand_history.append({
		"won": winner_idx == -1,
		"net": hand_net,
		"hand": hand_rank_name,
	})
	if _hand_history.size() > 8:
		_hand_history.pop_front()

	_render_table()
	_show_table_banner("SHOWDOWN", Color("#f0b429"), 0.70)
	_set_msg(" ".join(msg_parts))
	_pulse_node(_msg_lbl, 1.08, 0.30)
	_pulse_node(_community_row, 1.05, 0.28)
	_pulse_node(_hole_row, 1.07, 0.30)
	_show_showdown_buttons()

func _show_showdown_buttons() -> void:
	for ch in _action_panel.get_children():
		ch.queue_free()
	var next_btn := _make_btn("다음 핸드", func(): _start_hand(), "#1a3a1a")
	next_btn.custom_minimum_size = Vector2(100, 36)
	_action_panel.add_child(next_btn)
	var leave_btn := _make_btn("자리를 뜬다", _leave_mid, "#2a1a1a")
	leave_btn.custom_minimum_size = Vector2(100, 36)
	_action_panel.add_child(leave_btn)

# ── 결과 화면 ─────────────────────────────────────────────────────
func _show_result_screen() -> void:
	_phase = Phase.RESULT
	_clear_content()
	var vb := _content_vbox()

	var title := Label.new()
	title.text = "세션 종료"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color("#f0b429"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_f(title, true)
	vb.add_child(title)

	var played_lbl := Label.new()
	played_lbl.text = "%d핸드 플레이" % _hands_played
	played_lbl.add_theme_font_size_override("font_size", 13)
	played_lbl.add_theme_color_override("font_color", Color("#8a9ab0"))
	played_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_f(played_lbl)
	vb.add_child(played_lbl)

	var net := _player_stack - _buy_in
	var net_lbl := Label.new()
	net_lbl.text = ("%s +%s" % ["💰", _fmt(net)]) if net >= 0 else ("💸 %s" % _fmt(net))
	net_lbl.add_theme_font_size_override("font_size", 22)
	net_lbl.add_theme_color_override("font_color", Color("#5de89c") if net >= 0 else Color("#e85d5d"))
	net_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_f(net_lbl, true)
	vb.add_child(net_lbl)
	_pulse_node(net_lbl, 1.12, 0.34)

	vb.add_child(_sep())

	# GameState 반영
	GameState.money += float(_player_stack - _buy_in)
	if net > 0:
		GameState.add_log("🃏 홀덤 클럽에서 %s 땄다." % _fmt(net), "money")
		GameState.modify_hidden_stat("gambling_tendency", 5)
		if GameState.addiction_tendency < 50:
			GameState.modify_hidden_stat("addiction_tendency", 3)
	else:
		GameState.add_log("🃏 홀덤 클럽에서 %s 잃었다." % _fmt(-net), "money")
		GameState.modify_hidden_stat("stress", 5)
		if net < -200_000:
			GameState.modify_hidden_stat("addiction_tendency", 4)
	# 마스터리 기록
	MetaProgression.record_minigame_play("holdem")

	var close_btn := _make_btn("돌아가기", _leave, "#1a2a3a")
	close_btn.custom_minimum_size = Vector2(0, 44)
	vb.add_child(close_btn)

func _leave_mid() -> void:
	_show_result_screen()

func _leave() -> void:
	visible = false
	AudioManager.play("click")
	closed.emit()

# ── UI 헬퍼 ───────────────────────────────────────────────────────
var _content_root: Control

func _build_ui() -> void:
	# 배경 이미지 (이미지 있으면 위에, 없으면 단색만)
	const _BG_HOLDEM = "res://assets/backgrounds/holdem_club_interior.png"
	if ResourceLoader.exists(_BG_HOLDEM):
		var bg_img := TextureRect.new()
		bg_img.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg_img.stretch_mode = TextureRect.STRETCH_SCALE
		bg_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bg_img.texture = load(_BG_HOLDEM) as Texture2D
		bg_img.modulate = Color(1, 1, 1, 0.3)
		add_child(bg_img)
	var bg := ColorRect.new()
	var _bg_color := Color("#070a0e")
	_bg_color.a = 0.8 if ResourceLoader.exists(_BG_HOLDEM) else 1.0
	bg.color = _bg_color
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	_content_root = Control.new()
	_content_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.add_child(_content_root)

	_flash_layer = ColorRect.new()
	_flash_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash_layer.color = Color(1, 1, 1, 1)
	_flash_layer.modulate = Color(1, 1, 1, 0.0)
	_flash_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash_layer.z_index = 80
	add_child(_flash_layer)

func _clear_content() -> void:
	if not is_instance_valid(_content_root): return
	for ch in _content_root.get_children():
		ch.queue_free()

func _content_vbox() -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	_content_root.add_child(margin)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	margin.add_child(vb)
	return vb

func _set_msg(text: String) -> void:
	if is_instance_valid(_msg_lbl):
		_msg_lbl.text = text

func _card_label(card: Dictionary, highlight := false) -> Control:
	var root := Control.new()
	root.custom_minimum_size = Vector2(44, 60)

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
		st.border_color = Color("#f0b429") if highlight else Color("#c0b090")
		st.set_border_width_all(1 if not highlight else 2)
		st.set_corner_radius_all(5)
		panel.add_theme_stylebox_override("panel", st)
		root.add_child(panel)

	if highlight:
		var ring := Panel.new()
		ring.set_anchors_preset(Control.PRESET_FULL_RECT)
		var ring_st := StyleBoxFlat.new()
		ring_st.bg_color = Color(1.0, 0.92, 0.45, 0.10)
		ring_st.border_color = Color("#f0b429")
		ring_st.set_border_width_all(2)
		ring_st.set_corner_radius_all(5)
		ring.add_theme_stylebox_override("panel", ring_st)
		root.add_child(ring)

	var lbl := Label.new()
	lbl.text = TH.card_str(card)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", Color(TH.card_color(card)))
	if _font_bold: lbl.add_theme_font_override("font", _font_bold)
	root.add_child(lbl)
	return root

func _card_back() -> Control:
	# 이미지 카드 뒷면 (로드 실패 시 절차적 패널로 폴백)
	if CARD_BACK_TEX != null:
		var tex := TextureRect.new()
		tex.custom_minimum_size = Vector2(44, 60)
		tex.texture = CARD_BACK_TEX
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		return tex
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(38, 52)
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#1a3a5a")
	st.border_color = Color("#2a5a8a")
	st.set_border_width_all(1)
	st.set_corner_radius_all(5)
	panel.add_theme_stylebox_override("panel", st)
	var lbl := Label.new()
	lbl.text = "🂠"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl.add_theme_font_size_override("font_size", 18)
	panel.add_child(lbl)
	return panel

func _card_placeholder() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(44, 60)
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#0a1520")
	st.border_color = Color("#1a2530")
	st.set_border_width_all(1)
	st.set_corner_radius_all(5)
	panel.add_theme_stylebox_override("panel", st)
	return panel

func _make_btn(text: String, callback: Callable, bg_color: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color(bg_color)
	st.set_corner_radius_all(6)
	var hover_st := st.duplicate()
	hover_st.bg_color = Color(bg_color).lightened(0.15)
	var focus_st := st.duplicate()
	focus_st.border_color = Color("#f0b429")
	focus_st.set_border_width_all(2)
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_stylebox_override("hover", hover_st)
	btn.add_theme_stylebox_override("pressed", hover_st)
	btn.add_theme_stylebox_override("focus", focus_st)
	btn.add_theme_color_override("font_color", Color("#e8eaf0"))
	btn.add_theme_font_size_override("font_size", 13)
	if _font: btn.add_theme_font_override("font", _font)
	btn.pressed.connect(callback)
	return btn

func _sep() -> HSeparator:
	var s := HSeparator.new()
	s.add_theme_color_override("color", Color("#1a2030"))
	return s

func _fmt(amount) -> String:
	var a := int(amount)
	if abs(a) >= 100_000_000: return "%.1f억" % (float(a) / 100_000_000.0)
	if abs(a) >= 10_000:      return "%d만" % (a / 10_000)
	return "%d원" % a

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

func _show_table_banner(text: String, color: Color, duration: float = 0.55) -> void:
	if text.is_empty():
		return
	var root_size := size
	if root_size.x <= 1.0 or root_size.y <= 1.0:
		root_size = get_viewport_rect().size
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.z_index = 75
	panel.size = Vector2(minf(360.0, root_size.x - 48.0), 54.0)
	panel.position = Vector2((root_size.x - panel.size.x) * 0.5, maxf(86.0, root_size.y * 0.30))
	panel.modulate = Color(1, 1, 1, 0.0)
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.02, 0.03, 0.04, 0.82)
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
	tw.tween_property(panel, "modulate:a", 0.0, 0.18)
	tw.tween_callback(panel.queue_free)

func _spawn_chip_burst(color: Color, center_ratio: Vector2 = Vector2(0.5, 0.5), count: int = 5) -> void:
	var root_size := size
	if root_size.x <= 1.0 or root_size.y <= 1.0:
		root_size = get_viewport_rect().size
	var center := Vector2(root_size.x * center_ratio.x, root_size.y * center_ratio.y)
	for i in range(count):
		var chip := PanelContainer.new()
		chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		chip.z_index = 74
		var chip_size := randf_range(10.0, 16.0)
		chip.size = Vector2(chip_size, chip_size)
		chip.position = center + Vector2(randf_range(-42.0, 42.0), randf_range(-18.0, 18.0))
		var st := StyleBoxFlat.new()
		st.bg_color = color.darkened(randf_range(0.0, 0.18))
		st.border_color = Color("#fff3b0")
		st.set_border_width_all(1)
		st.set_corner_radius_all(99)
		chip.add_theme_stylebox_override("panel", st)
		add_child(chip)
		var end := center + Vector2(randf_range(-70.0, 70.0), randf_range(-72.0, -26.0))
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(chip, "position", end, 0.34).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(chip, "modulate:a", 0.0, 0.34).set_delay(0.08)
		tw.tween_property(chip, "scale", Vector2(0.55, 0.55), 0.34)
		tw.set_parallel(false)
		tw.tween_callback(chip.queue_free)
