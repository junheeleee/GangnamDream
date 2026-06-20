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

# ── 진입/종료 ──────────────────────────────────────────────────
func open() -> void:
	_shoe = BAC.new_shoe(_rng)
	_road = []
	_rounds = 0; _net = 0.0; _p_wins = 0; _b_wins = 0; _ties = 0
	_commission = 0.0
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
		GameState.add_log("바카라 커미션 정산 -%s" % GameState.format_money(_commission), "money")
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

# ── 베팅 배치 ──────────────────────────────────────────────────
func _add_bet(type: String) -> void:
	var add: int = _active_stake
	if GameState.money < float(add + _total_bet()):
		_flash("현금 부족", "#e85d5d"); return
	match type:
		"P":  _bet_p  += add
		"B":  _bet_b  += add
		"T":  _bet_t  += add
		"PP": _bet_pp += add
		"BP": _bet_bp += add
	AudioManager.play("casino_bet")
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
		_flash("베팅을 먼저 해주세요", "#e8c45d"); return
	if GameState.money < float(_total_bet()):
		_flash("현금 부족", "#e85d5d"); return

	# 슈 리셔플 체크
	if BAC.shoe_remaining_ratio(_shoe) < SHOE_CUT:
		_shoe = BAC.new_shoe(_rng)
		_flash("🔀 슈 리셔플", "#d4a020")

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
	if is_win:
		GameState.modify_hidden_stat("gambling_tendency", 2)
		match res:
			"player":
				AudioManager.play("casino_win")
			"banker":
				AudioManager.play("casino_win")
			"tie":
				AudioManager.play("casino_jackpot")
			_:
				AudioManager.play("casino_win")
	else:
		GameState.modify_hidden_stat("addiction_tendency", 2)
		AudioManager.play("casino_lose")

	# 페어 당첨 SFX
	if (_result.get("p_pair", false) and _bet_pp > 0) or (_result.get("b_pair", false) and _bet_bp > 0):
		AudioManager.play("casino_jackpot")

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

	GameState.add_log("바카라 %s%s %s" % [
		res, " 내추럴" if (res == "player" and bool(_result.get("player_natural", false))) or
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
		comm_str = "   커미션 [color=%s]%s[/color]" % [hud_comm_col, GameState.format_money(_commission)]
	_hud_lbl.text = "[b]현금 %s[/b]   |   %d라운드   W%d B%d T%d   손익 [b]%s[/b]   슈 %d%%%s" % [
		GameState.format_money(GameState.money), _rounds,
		_p_wins, _b_wins, _ties,
		("+%s" % GameState.format_money(_net)) if _net >= 0 else GameState.format_money(_net),
		shoe_pct, comm_str]

func _render_betting() -> void:
	var vb := _make_vbox(12)

	var title := Label.new()
	title.text = "바카라"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("#f0b429"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_f(title, true); vb.add_child(title)

	# 베팅 현황
	var bet_rt := RichTextLabel.new()
	bet_rt.bbcode_enabled = true; bet_rt.fit_content = true; bet_rt.scroll_active = false
	_f(bet_rt); bet_rt.add_theme_font_size_override("normal_font_size", 14)
	bet_rt.text = _bet_status_text()
	vb.add_child(bet_rt)

	vb.add_child(_sep())

	# 메인 베팅 버튼 (Player / Banker / Tie)
	var row1 := HBoxContainer.new()
	row1.add_theme_constant_override("separation", 10)
	vb.add_child(row1)
	_add_bet_btn(row1, "PLAYER", "플레이어", "P", "#1a2a3a", "#3a6a9a")
	_add_bet_btn(row1, "BANKER", "뱅커", "B", "#2a1a1a", "#9a3a3a")
	_add_bet_btn(row1, "TIE", "타이  (8배)", "T", "#1a2a1a", "#3a7a3a")

	# 페어 베팅 (선택)
	var pair_lbl := Label.new()
	pair_lbl.text = "사이드 베팅 (선택)"
	pair_lbl.add_theme_font_size_override("font_size", 11)
	pair_lbl.add_theme_color_override("font_color", Color("#4a5a6a"))
	_f(pair_lbl); vb.add_child(pair_lbl)
	var row2 := HBoxContainer.new()
	row2.add_theme_constant_override("separation", 10)
	vb.add_child(row2)
	_add_bet_btn(row2, "플레이어 페어  (11배)", "PP베팅", "PP", "#18141e", "#5a3a7a")
	_add_bet_btn(row2, "뱅커 페어  (11배)", "BP베팅", "BP", "#18141e", "#7a3a4a")

	vb.add_child(_sep())

	# 베팅 단위 선택
	var stake_lbl := Label.new()
	stake_lbl.text = "베팅 단위 (클릭당)"
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
	var deal_btn := _make_btn("딜 시작", _deal, "#1a3a1a", "#3de87a")
	deal_btn.custom_minimum_size = Vector2(0, 44)
	deal_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	deal_btn.disabled = (_total_bet() == 0)
	_f(deal_btn, true); action_row.add_child(deal_btn)
	var clear_btn := _make_btn("베팅 초기화", _clear_bets, "#1a1a1a", "#4a4a5a")
	clear_btn.custom_minimum_size = Vector2(100, 44)
	action_row.add_child(clear_btn)
	var help_btn := _make_btn("규칙", func(): TutorialOverlay.force_show("baccarat", self), "#0a0a1a", "#5a4510")
	help_btn.custom_minimum_size = Vector2(60, 44)
	action_row.add_child(help_btn)

	var exit_btn := _make_btn("나가기", _on_exit, "#1a0e0e", "#5a2a2a")
	exit_btn.custom_minimum_size = Vector2(80, 44)
	action_row.add_child(exit_btn)

	# 규칙 안내
	var rules := RichTextLabel.new()
	rules.bbcode_enabled = true; rules.fit_content = true; rules.scroll_active = false
	_f(rules); rules.add_theme_font_size_override("normal_font_size", 11)
	rules.add_theme_color_override("default_color", Color("#3a4a5a"))
	rules.text = "플레이어 1:1  ·  뱅커 0.95:1(커미션5%)  ·  타이 8:1  ·  페어 11:1  ·  6덱 슈  ·  내추럴(8·9) 시 추가 드로우 없음"
	vb.add_child(rules)

func _render_dealing() -> void:
	var vb := _make_vbox(16)
	_add_table_display(vb, true)
	var dealing_lbl := Label.new()
	dealing_lbl.text = "카드를 배분하는 중..."
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
	var res_ko := {"player": "플레이어 승", "banker": "뱅커 승", "tie": "타이!"}
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
	if bool(_result.get("p_pair", false)): pair_parts.append("플레이어 페어!")
	if bool(_result.get("b_pair", false)): pair_parts.append("뱅커 페어!")
	if not pair_parts.is_empty():
		var pair_lbl := Label.new()
		pair_lbl.text = "  /  ".join(pair_parts)
		pair_lbl.add_theme_font_size_override("font_size", 14)
		pair_lbl.add_theme_color_override("font_color", Color("#d4a0ff"))
		_f(pair_lbl); vb.add_child(pair_lbl)

	# 커미션 안내
	if _commission > 0.0:
		var comm_lbl := Label.new()
		comm_lbl.text = "누적 커미션: %s (나갈 때 정산)" % GameState.format_money(_commission)
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
	var again_btn := _make_btn("다음 라운드", _next_round, "#1a2a1a", "#3de87a")
	again_btn.custom_minimum_size = Vector2(0, 48)
	again_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_f(again_btn, true); btn_row.add_child(again_btn)
	var exit_btn := _make_btn("나가기", _on_exit, "#1a0e0e", "#5a2a2a")
	exit_btn.custom_minimum_size = Vector2(100, 48)
	btn_row.add_child(exit_btn)

func _add_table_display(parent: VBoxContainer, partial: bool) -> void:
	# 플레이어 카드 행
	var p_row := HBoxContainer.new()
	p_row.add_theme_constant_override("separation", 8)
	parent.add_child(p_row)
	var p_lbl := Label.new()
	p_lbl.text = "플레이어"
	p_lbl.add_theme_font_size_override("font_size", 13)
	p_lbl.add_theme_color_override("font_color", Color("#d4a020"))
	p_lbl.custom_minimum_size = Vector2(80, 0)
	_f(p_lbl, true); p_row.add_child(p_lbl)
	var p_cards: Array = (_deal_p_visible if partial else _result.get("player", []))
	for c in p_cards:
		p_row.add_child(_card_widget(c))
	for _j in range(3 - p_cards.size()):
		p_row.add_child(_card_back())
	if not partial:
		var pv_lbl := Label.new()
		pv_lbl.text = str(int(_result.get("player_val", 0)))
		pv_lbl.add_theme_font_size_override("font_size", 22)
		pv_lbl.add_theme_color_override("font_color", Color("#d4a020"))
		_f(pv_lbl, true); p_row.add_child(pv_lbl)

	# 뱅커 카드 행
	var b_row := HBoxContainer.new()
	b_row.add_theme_constant_override("separation", 8)
	parent.add_child(b_row)
	var b_lbl := Label.new()
	b_lbl.text = "뱅커"
	b_lbl.add_theme_font_size_override("font_size", 13)
	b_lbl.add_theme_color_override("font_color", Color("#e85d5d"))
	b_lbl.custom_minimum_size = Vector2(80, 0)
	_f(b_lbl, true); b_row.add_child(b_lbl)
	var b_cards: Array = (_deal_b_visible if partial else _result.get("banker", []))
	for c in b_cards:
		b_row.add_child(_card_widget(c))
	for _k in range(3 - b_cards.size()):
		b_row.add_child(_card_back())
	if not partial:
		var bv_lbl := Label.new()
		bv_lbl.text = str(int(_result.get("banker_val", 0)))
		bv_lbl.add_theme_font_size_override("font_size", 22)
		bv_lbl.add_theme_color_override("font_color", Color("#e85d5d"))
		_f(bv_lbl, true); b_row.add_child(bv_lbl)

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

	# 메인 컨텐츠 (스크롤)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 50; scroll.offset_right = -164; scroll.offset_bottom = -10
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	_content_root = Control.new()
	_content_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.add_child(_content_root)

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
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	_content_root.add_child(margin)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", sep)
	margin.add_child(vb)
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
	vb.add_child(btn)

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
	if _bet_p  > 0: parts.append("[color=#d4a020]플 %s[/color]" % GameState.format_money(float(_bet_p)))
	if _bet_b  > 0: parts.append("[color=#e85d5d]뱅 %s[/color]" % GameState.format_money(float(_bet_b)))
	if _bet_t  > 0: parts.append("[color=#f0b429]타이 %s[/color]" % GameState.format_money(float(_bet_t)))
	if _bet_pp > 0: parts.append("[color=#d4a0ff]PP %s[/color]" % GameState.format_money(float(_bet_pp)))
	if _bet_bp > 0: parts.append("[color=#d4a0ff]BP %s[/color]" % GameState.format_money(float(_bet_bp)))
	if parts.is_empty():
		return "[color=#3a4a5a]베팅 없음[/color]"
	var total := "[b]총 %s[/b]" % GameState.format_money(float(_total_bet()))
	return "  ".join(parts) + "   " + total

func _card_widget(card: int) -> Control:
	var root := Control.new()
	root.custom_minimum_size = Vector2(54, 76)

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
	corner.offset_right = 24; corner.offset_bottom = 34
	corner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	corner.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	corner.add_theme_font_size_override("font_size", 11)
	corner.add_theme_color_override("font_color", col)
	if _font_bold: corner.add_theme_font_override("font", _font_bold)
	root.add_child(corner)

	var center := Label.new()
	center.text = suit
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	center.add_theme_font_size_override("font_size", 30)
	center.add_theme_color_override("font_color", col)
	if _font_bold: center.add_theme_font_override("font", _font_bold)
	root.add_child(center)

	var bottom := Label.new()
	bottom.text = rank
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	bottom.offset_left = -25; bottom.offset_top = -21
	bottom.offset_right = -5; bottom.offset_bottom = -3
	bottom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bottom.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bottom.add_theme_font_size_override("font_size", 10)
	bottom.add_theme_color_override("font_color", col.darkened(0.08))
	if _font_bold: bottom.add_theme_font_override("font", _font_bold)
	root.add_child(bottom)

	_animate_card_appear(root)
	return root

func _animate_card_appear(node: Control) -> void:
	node.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(node, "modulate:a", 1.0, 0.2)

func _card_back() -> Control:
	if CARD_BACK_TEX != null:
		var tex := TextureRect.new()
		tex.custom_minimum_size = Vector2(54, 76)
		tex.texture = CARD_BACK_TEX
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		return tex
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(54, 76)
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
	_road_ctrl.draw_string(f, Vector2(6, 18), "로드맵",
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
