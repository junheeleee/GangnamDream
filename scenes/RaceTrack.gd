extends Control
## RaceTrack — 경마 미니게임 시각 레이어. HorseRace 모델(증명된 스킬 뼈대)을
## 폼 읽기 → 베팅 → 레이스 애니메이션 → 정산으로 플레이 가능하게 한다.
## MainGame이 인스턴스해 overlay로 붙이고 open()으로 표시. 닫으면 closed 시그널.

signal closed

enum Phase { BETTING, RACE, RESULT }

var _phase: int = Phase.BETTING
var _race: Dictionary = {}
var _finish: Array = []          # 증명된 모델 simulate() 착순
var _bet_idx: int = -1
var _bet_stake: float = 0.0
var _rng := RandomNumberGenerator.new()
var _race_t: float = 0.0
var _race_dur: float = 0.0
var _last_lost: bool = false     # 직전 베팅 패배(추격 베팅 감지)
var _races_today: int = 0

var _font: FontFile
var _font_bold: FontFile

# 노드
var _header: RichTextLabel
var _hud: RichTextLabel
var _content: Control
var _track: Control
var _msg: Label

const COLORS := ["#e85d5d","#5d9ce8","#e8c45d","#5de89c","#c45de8","#e88d5d","#5de8e8","#b0b0b0"]

func _ready() -> void:
	_rng.randomize()
	_load_fonts()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_skeleton()
	visible = false
	set_process(false)

func _load_fonts() -> void:
	_font = FontFile.new()
	if _font.load_dynamic_font("res://assets/fonts/Pretendard-Regular.ttf") != OK: _font = null
	_font_bold = FontFile.new()
	if _font_bold.load_dynamic_font("res://assets/fonts/Pretendard-Bold.ttf") != OK: _font_bold = null
	FontKit.attach_emoji_fallback(_font)
	FontKit.attach_emoji_fallback(_font_bold)

func _f(lbl, bold := false) -> void:
	var ft = _font_bold if bold else _font
	if ft:
		lbl.add_theme_font_override("font", ft)
		if lbl is RichTextLabel:
			lbl.add_theme_font_override("normal_font", ft)
			lbl.add_theme_font_override("bold_font", _font_bold if _font_bold else ft)

# ── 골격 ──────────────────────────────────────────────────────
func _build_skeleton() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#0a0d12")
	add_child(bg)

	_header = RichTextLabel.new()
	_header.bbcode_enabled = true; _header.fit_content = true; _header.scroll_active = false
	_header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_header.offset_left = 26; _header.offset_top = 16; _header.offset_right = -26; _header.offset_bottom = 50
	_f(_header); _header.add_theme_font_size_override("normal_font_size", 19)
	add_child(_header)

	_hud = RichTextLabel.new()
	_hud.bbcode_enabled = true; _hud.fit_content = true; _hud.scroll_active = false
	_hud.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_hud.offset_left = 26; _hud.offset_top = 52; _hud.offset_right = -26; _hud.offset_bottom = 78
	_f(_hud); _hud.add_theme_font_size_override("normal_font_size", 14)
	add_child(_hud)

	var exit := Button.new()
	exit.text = "나가기"
	exit.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	exit.offset_left = -120; exit.offset_top = 14; exit.offset_right = -22; exit.offset_bottom = 46
	_style(exit, "#201217", "#7a3030")
	exit.pressed.connect(_on_exit)
	add_child(exit)

	_content = Control.new()
	_content.set_anchors_preset(Control.PRESET_FULL_RECT)
	_content.offset_top = 92; _content.offset_bottom = -16
	add_child(_content)

	_msg = Label.new()
	_msg.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_msg.offset_top = -38; _msg.offset_bottom = -10
	_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_f(_msg, true); _msg.add_theme_font_size_override("font_size", 16)
	_msg.visible = false
	add_child(_msg)

# ── 진입 ──────────────────────────────────────────────────────
func open() -> void:
	visible = true
	_races_today = 0
	_last_lost = false
	_new_race()

func _new_race() -> void:
	var info: float = float(GameState.intelligence)
	_race = HorseRace.generate_race(_rng, info)
	_finish = []
	_bet_idx = -1
	_bet_stake = 0.0
	_phase = Phase.BETTING
	_races_today += 1
	_render()

func _on_exit() -> void:
	set_process(false)
	visible = false
	closed.emit()

# ── 렌더 ──────────────────────────────────────────────────────
func _clear() -> void:
	for c in _content.get_children():
		c.queue_free()

func _refresh_top() -> void:
	_header.text = "[b]🏇 경마장[/b]   ·   제%d경주   ·   %dm   ·   마장 %s" % [
		_races_today, int(_race.get("distance", 0)), str(_race.get("track", ""))]
	var addic: int = GameState.addiction_tendency
	var bars: int = clampi(addic / 10, 0, 10)
	var ac: String = "#5de89c" if addic < 40 else ("#e8c45d" if addic < 70 else "#e85d5d")
	_hud.text = "💰 현금 [b]%s[/b]      🎰 중독도 [color=%s]%s[/color] %d/100      🧠 안목(지력) %d" % [
		GameState.format_money(GameState.money),
		ac, ("▰".repeat(bars) + "▱".repeat(10 - bars)), addic, GameState.intelligence]

func _render() -> void:
	_refresh_top()
	_clear()
	match _phase:
		Phase.BETTING: _render_betting()
		Phase.RACE: _render_race()
		Phase.RESULT: _render_result()

func _stars(n: int) -> String:
	return "★".repeat(clampi(n, 0, 5)) + "☆".repeat(5 - clampi(n, 0, 5))

# 고지력이면 배당 대비 저평가 말을 짚어준다 (전문가 분석)
func _value_pick() -> int:
	if GameState.intelligence < 65:
		return -1
	var hs: Array = _race["horses"]
	var est: Array = []
	var s: float = 0.0
	for h in hs:
		var e: float = float(h["sig_class"]) * float(h["jockey"]) * float(h["sig_dist"]) * float(h["sig_cond"])
		est.append(e); s += e
	var best: float = -1.0
	var bi: int = -1
	for i in range(hs.size()):
		var ratio: float = (est[i] / s) / max(0.86 / float(hs[i]["odds"]), 0.001)
		if ratio > best:
			best = ratio; bi = i
	return bi if best > 1.15 else -1

func _render_betting() -> void:
	var hs: Array = _race["horses"]
	var vpick: int = _value_pick()

	var head := RichTextLabel.new()
	head.bbcode_enabled = true; head.fit_content = true; head.scroll_active = false
	head.set_anchors_preset(Control.PRESET_TOP_WIDE)
	head.offset_left = 8; head.offset_top = 0; head.offset_right = -8; head.offset_bottom = 24
	_f(head); head.add_theme_font_size_override("normal_font_size", 12)
	head.add_theme_color_override("default_color", Color("#6a7488"))
	head.text = "   말   ·   클래스   거리적성   마장적성   기수   ·   배당   (★ 높고 배당 높으면 = 저평가 노림수)"
	_content.add_child(head)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 30; scroll.offset_bottom = -132
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_content.add_child(scroll)
	var vb := VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_theme_constant_override("separation", 5)
	scroll.add_child(vb)

	for i in range(hs.size()):
		var h: Dictionary = hs[i]
		var sel: bool = (i == _bet_idx)
		var rt := RichTextLabel.new()
		rt.bbcode_enabled = true; rt.fit_content = true; rt.scroll_active = false
		rt.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rt.custom_minimum_size = Vector2(0, 40)
		_f(rt); rt.add_theme_font_size_override("normal_font_size", 15)
		var tag: String = "  [color=#f0c45d]💡저평가[/color]" if i == vpick else ""
		rt.text = "[color=%s]●[/color] [b]%s[/b]    [color=#c8a050]%s[/color]  [color=#5d9ce8]%s[/color]  [color=#5de89c]%s[/color]  [color=#aaaaaa]%s[/color]    배당 [b]%.1f[/b]%s" % [
			COLORS[i % COLORS.size()], str(h["name"]),
			_stars(int(h["star_class"])), _stars(int(h["star_dist"])),
			_stars(int(h["star_cond"])), _stars(int(h["star_jockey"])),
			float(h["odds"]), tag]
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 42)
		var st := StyleBoxFlat.new()
		st.bg_color = Color("#141c28") if sel else Color("#0d1119")
		st.border_color = Color("#4a7ad0") if sel else Color("#1a2230")
		st.border_width_left = 4
		st.set_corner_radius_all(5)
		st.content_margin_left = 12
		btn.add_theme_stylebox_override("normal", st)
		var hov := st.duplicate(); hov.bg_color = Color("#1a2433")
		btn.add_theme_stylebox_override("hover", hov)
		btn.add_theme_stylebox_override("pressed", st)
		btn.focus_mode = Control.FOCUS_NONE
		var idx: int = i
		btn.pressed.connect(func(): _bet_idx = idx; _render())
		btn.add_child(rt)
		rt.set_anchors_preset(Control.PRESET_FULL_RECT)
		rt.offset_left = 12; rt.offset_top = 9
		vb.add_child(btn)

	# 베팅 컨트롤
	var bet_panel := VBoxContainer.new()
	bet_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bet_panel.offset_left = 8; bet_panel.offset_top = -120; bet_panel.offset_right = -8
	bet_panel.add_theme_constant_override("separation", 8)
	_content.add_child(bet_panel)

	var info := Label.new()
	_f(info); info.add_theme_font_size_override("font_size", 14)
	if _bet_idx < 0:
		info.text = "베팅할 말을 고르세요. (단승 — 1착을 맞히면 배당만큼 받는다)"
		info.add_theme_color_override("font_color", Color("#9aa4b8"))
	else:
		var bh: Dictionary = hs[_bet_idx]
		info.text = "선택: %s  (배당 %.1f) — 단승 베팅액을 고르세요" % [str(bh["name"]), float(bh["odds"])]
		info.add_theme_color_override("font_color", Color("#cfe0ff"))
	bet_panel.add_child(info)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	bet_panel.add_child(row)
	for amt in [10000, 30000, 100000, 500000]:
		var b := Button.new()
		b.text = GameState.format_money(float(amt))
		_style(b, "#10231a", "#2a7a52")
		b.disabled = (_bet_idx < 0) or (GameState.money < float(amt))
		var a: int = amt
		b.pressed.connect(func(): _place_bet(float(a)))
		row.add_child(b)
	var skip := Button.new()
	skip.text = "이 경주 패스 ▷"
	_style(skip, "#1a1a22", "#3a3a4a")
	skip.pressed.connect(_new_race)
	row.add_child(skip)

func _place_bet(stake: float) -> void:
	if _bet_idx < 0: return
	if GameState.money < stake:
		_flash("현금이 부족하다", "#e85d5d"); return
	_bet_stake = stake
	GameState.add_money(-stake)
	# 도박 — 중독·도박성향 상승. 진 뒤 또 거는(추격)이면 가속.
	var add: int = 3 + (4 if _last_lost else 0)
	GameState.addiction_tendency = clampi(GameState.addiction_tendency + add, 0, 100)
	GameState.gambling_tendency = clampi(GameState.gambling_tendency + 2, 0, 100)
	GameState.stats_changed.emit()
	_start_race()

# ── 레이스 ────────────────────────────────────────────────────
func _start_race() -> void:
	_phase = Phase.RACE
	# 증명된 모델로 공정한 착순 결정
	_finish = HorseRace.simulate(_race, _rng)
	# 착순대로 결승 시간 배정 (1착이 가장 빠름, 약간 겹쳐 사진판정 긴장)
	var base: float = 3.2
	for rank in range(_finish.size()):
		var h: Dictionary = _finish[rank]
		h["_ftime"] = base * (1.0 + float(rank) * 0.05) * _rng.randf_range(0.97, 1.03)
	_race_dur = 0.0
	for h in _race["horses"]:
		_race_dur = max(_race_dur, float(h.get("_ftime", base)))
	_race_t = 0.0
	_clear()
	_render_race()
	AudioManager.play("open_modal")
	set_process(true)

func _render_race() -> void:
	if _track == null or not is_instance_valid(_track):
		_track = Control.new()
		_track.set_anchors_preset(Control.PRESET_FULL_RECT)
		_track.offset_top = 10; _track.offset_bottom = -10
		_track.draw.connect(_draw_track)
		_content.add_child(_track)
	_track.queue_redraw()

func _process(delta: float) -> void:
	if _phase != Phase.RACE:
		return
	_race_t += delta
	if is_instance_valid(_track):
		_track.queue_redraw()
	if _race_t >= _race_dur + 0.4:
		set_process(false)
		_finish_race()

func _draw_track() -> void:
	var sz: Vector2 = _track.size
	if sz.x < 40 or sz.y < 40: return
	var hs: Array = _race["horses"]
	var n: int = hs.size()
	var pad_l: float = 30.0
	var pad_r: float = 70.0
	var fin_x: float = sz.x - pad_r
	var lane_h: float = (sz.y - 20.0) / float(n)
	var f := ThemeDB.fallback_font
	# 결승선
	_track.draw_line(Vector2(fin_x, 6), Vector2(fin_x, sz.y - 6), Color("#e0e0e0"), 2.0)
	for k in range(0, int(sz.y), 14):
		_track.draw_rect(Rect2(fin_x - 3, float(k), 6, 7), Color(1,1,1,0.5) if (k/14)%2==0 else Color(0,0,0,0))
	for i in range(n):
		var h: Dictionary = hs[i]
		var y: float = 14.0 + lane_h * float(i) + lane_h * 0.5
		# 레인
		_track.draw_line(Vector2(pad_l, y + lane_h*0.45), Vector2(fin_x, y + lane_h*0.45), Color(1,1,1,0.04), 1.0)
		var ft: float = float(h.get("_ftime", _race_dur))
		var prog: float = clampf(_race_t / max(ft, 0.1), 0.0, 1.0)
		var x: float = pad_l + (fin_x - pad_l) * prog
		var col := Color(COLORS[i % COLORS.size()])
		# 말 (캡슐 + 번호)
		_track.draw_circle(Vector2(x, y), 9.0, col)
		if i == _bet_idx:
			_track.draw_arc(Vector2(x, y), 13.0, 0, TAU, 24, Color("#ffe14d"), 2.0)
		_track.draw_string(f, Vector2(pad_l - 2, y - 12), str(h["name"]),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, col)

func _finish_race() -> void:
	_phase = Phase.RESULT
	var payout: float = HorseRace.payout_win(_race, _bet_idx, _bet_stake, _finish)
	if payout > 0:
		GameState.add_money(payout)
		AudioManager.play("money_gain")
		_last_lost = false
	else:
		AudioManager.play("money_loss")
		_last_lost = true
	GameState.stats_changed.emit()
	_payout_amt = payout
	_render()

var _payout_amt: float = 0.0

func _render_result() -> void:
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_TOP_WIDE)
	box.offset_left = 24; box.offset_top = 8; box.offset_right = -24
	box.add_theme_constant_override("separation", 8)
	_content.add_child(box)

	var title := Label.new()
	_f(title, true); title.add_theme_font_size_override("font_size", 20)
	title.text = "🏁 결과"
	title.add_theme_color_override("font_color", Color("#e8eaf0"))
	box.add_child(title)

	for rank in range(min(_finish.size(), 4)):
		var h: Dictionary = _finish[rank]
		var medal: String = ["🥇", "🥈", "🥉", "  "][rank]
		var lbl := Label.new()
		_f(lbl); lbl.add_theme_font_size_override("font_size", 16)
		var mine: String = "   ← 내 베팅" if _race["horses"][_bet_idx] == h and _bet_idx >= 0 else ""
		lbl.text = "%s %d착   %s   (배당 %.1f)%s" % [medal, rank + 1, str(h["name"]), float(h["odds"]), mine]
		lbl.add_theme_color_override("font_color", Color("#f0c45d") if rank == 0 else Color("#aab3c5"))
		box.add_child(lbl)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color("#252535"))
	box.add_child(sep)

	var res := Label.new()
	_f(res, true); res.add_theme_font_size_override("font_size", 22)
	if _payout_amt > 0:
		var profit: float = _payout_amt - _bet_stake
		res.text = "🎉 적중!  +%s  (배당금 %s)" % [GameState.format_money(profit), GameState.format_money(_payout_amt)]
		res.add_theme_color_override("font_color", Color("#5de89c"))
	else:
		res.text = "💸 꽝.  -%s" % GameState.format_money(_bet_stake)
		res.add_theme_color_override("font_color", Color("#e85d5d"))
	box.add_child(res)

	if GameState.addiction_tendency >= 70:
		var warn := Label.new()
		_f(warn); warn.add_theme_font_size_override("font_size", 13)
		warn.text = "⚠ 손이 떨린다. '딱 한 번만 더'가 가장 위험하다. (중독도 %d)" % GameState.addiction_tendency
		warn.add_theme_color_override("font_color", Color("#e8a05d"))
		box.add_child(warn)

	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	row.offset_top = -56; row.offset_left = 24; row.offset_right = -24
	row.add_theme_constant_override("separation", 10)
	_content.add_child(row)
	var again := Button.new()
	again.text = "🔥 다음 경주 (한 번 더)"
	_style(again, "#231016", "#a03a4a")
	again.pressed.connect(_new_race)
	row.add_child(again)
	var leave := Button.new()
	leave.text = "🚪 오늘은 그만, 나간다"
	_style(leave, "#10231a", "#2a7a52")
	leave.pressed.connect(_on_exit)
	row.add_child(leave)

# ── 유틸 ──────────────────────────────────────────────────────
func _flash(msg: String, color: String) -> void:
	_msg.text = msg
	_msg.add_theme_color_override("font_color", Color(color))
	_msg.visible = true
	var t := get_tree().create_timer(1.4)
	t.timeout.connect(func():
		if is_instance_valid(_msg): _msg.visible = false)

func _style(b: Button, bg: String, border: String) -> void:
	var st := StyleBoxFlat.new()
	st.bg_color = Color(bg); st.border_color = Color(border)
	st.set_border_width_all(1); st.set_corner_radius_all(5)
	st.content_margin_left = 14; st.content_margin_right = 14
	st.content_margin_top = 8; st.content_margin_bottom = 8
	var hov := st.duplicate(); hov.bg_color = Color(bg).lightened(0.1)
	var dis := st.duplicate(); dis.bg_color = Color("#141419"); dis.border_color = Color("#222")
	b.add_theme_stylebox_override("normal", st)
	b.add_theme_stylebox_override("hover", hov)
	b.add_theme_stylebox_override("pressed", st)
	b.add_theme_stylebox_override("disabled", dis)
	b.add_theme_color_override("font_color", Color("#dce4f0"))
	b.add_theme_color_override("font_disabled_color", Color("#4a4a58"))
	b.add_theme_font_size_override("font_size", 14)
	_f(b)
	b.focus_mode = Control.FOCUS_NONE
