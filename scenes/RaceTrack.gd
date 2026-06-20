extends Control
## RaceTrack — 경마 미니게임 시각 레이어. HorseRace 모델(증명된 스킬 뼈대)을
## 폼 읽기 → 베팅 → 레이스 애니메이션 → 정산으로 플레이 가능하게 한다.
## MainGame이 인스턴스해 overlay로 붙이고 open()으로 표시. 닫으면 closed 시그널.

signal closed

enum Phase { BETTING, RACE, RESULT }
enum BetType { PLACE, WIN, QUINELLA, TRIFECTA }

const BET_NAMES := ["연승", "단승", "복승", "삼쌍승"]
const BET_PICKS := [1, 1, 2, 3]           # 필요한 말 수
const BET_ORDERED := [false, false, false, true]   # 삼쌍승만 착순 순서 중요
const BET_DESC := [
	"고른 말이 1·2착 안에 들면 적중 — 안전, 낮은 배당",
	"고른 말이 1착이면 배당만큼 — 기본",
	"고른 2마리가 1·2착 (순서 무관) — 중간 배당",
	"1·2·3착을 순서까지 정확히 — 대박, 초고배당",
]
const PICK_BADGE := ["①", "②", "③"]
const HR := preload("res://systems/HorseRace.gd")   # class_name 글로벌 캐시 의존 제거(콜드런 크래시 방지)
const HW := preload("res://systems/HorseWorld.gd")  # 영속 명마 세계 + 정보상 팁
const HORSE_TEX := preload("res://assets/ui/horse_silhouette.png")  # 질주 실루엣 8프레임(128px) 아틀라스
const BG_BETTING_PATH := "res://assets/backgrounds/racetrack_betting_hall.png"
const BG_TRACK_PATH := "res://assets/backgrounds/racetrack_track_view.png"

var _phase: int = Phase.BETTING
var _race: Dictionary = {}
var _finish: Array = []          # 증명된 모델 simulate() 착순
var _bet_type: int = BetType.WIN
var _picks: Array = []           # 선택한 말 인덱스 (순서 보존 — 삼쌍승은 착순 예측)
var _bet_stake: float = 0.0
var _rng := RandomNumberGenerator.new()
var _race_t: float = 0.0
var _race_dur: float = 0.0
var _last_leader: int = -1
var _race_call_t: float = 0.0
var _hoof_sfx_t: float = 0.0
var _final_stretch_sfx_played: bool = false
var _last_lost: bool = false     # 직전 베팅 패배(추격 베팅 감지)
var _races_today: int = 0
var _world: Dictionary = {}      # 영속 로스터(GameState.flags["horse_world"] 참조)
var _tip: Dictionary = {}        # 이번 경주 정보상 팁
var _tip_seen: bool = false      # 이번 경주 팁을 샀는가
var skip_countdown_for_smoke: bool = false

var _font: FontFile
var _font_bold: FontFile

# 노드
var _header: RichTextLabel
var _hud: RichTextLabel
var _content: Control
var _track: Control
var _msg: Label
var _bg_img: TextureRect
var _bg_scrim: ColorRect
var _flash_layer: ColorRect

const COLORS := ["#e85d5d","#5d9ce8","#e8c45d","#5de89c","#c45de8","#e88d5d","#5de8e8","#b0b0b0"]

func _ready() -> void:
	_rng.randomize()
	_load_fonts()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)  # 오프셋까지 0으로 — 루트가 부모를 꽉 채움(0x0 collapse 방지)
	_build_skeleton()
	visible = false
	set_process(false)

func _load_fonts() -> void:
	_font      = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile
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
	# 풀스크린 미니게임은 뒤의 월간 대시보드가 비치지 않도록 불투명 베이스를 먼저 깐다.
	var base_bg := ColorRect.new()
	base_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	base_bg.color = Color("#07090d")
	base_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(base_bg)

	# 배경 이미지 (이미지 있으면 표시, 없으면 단색)
	_bg_img = TextureRect.new()
	_bg_img.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg_img.stretch_mode = TextureRect.STRETCH_SCALE
	_bg_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bg_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg_img)
	_bg_scrim = ColorRect.new()
	_bg_scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg_scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var _bg_color := Color("#0a0d12")
	_bg_color.a = 0.75
	_bg_scrim.color = _bg_color
	add_child(_bg_scrim)
	_set_background(BG_BETTING_PATH, 0.35, 0.75)

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

	var help := Button.new()
	help.text = "규칙"
	help.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	help.offset_left = -188; help.offset_top = 14; help.offset_right = -128; help.offset_bottom = 46
	_style(help, "#0a0a1a", "#5a4510")
	help.pressed.connect(func(): TutorialOverlay.force_show("racetrack", self))
	add_child(help)

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
	_msg.offset_top = -46; _msg.offset_bottom = -8
	_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_f(_msg, true); _msg.add_theme_font_size_override("font_size", 20)
	_msg.visible = false
	add_child(_msg)

	_flash_layer = ColorRect.new()
	_flash_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash_layer.color = Color(1, 1, 1, 1)
	_flash_layer.modulate = Color(1, 1, 1, 0.0)
	_flash_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash_layer.z_index = 80
	add_child(_flash_layer)

# ── 진입 ──────────────────────────────────────────────────────
func open() -> void:
	visible = true
	TutorialOverlay.maybe_show("racetrack", self)
	_races_today = 0
	_last_lost = false
	# 영속 명마 세계 — GameState.flags에 저장돼 씬 리로드·세이브를 견딘다
	if not (GameState.flags.get("horse_world") is Dictionary):
		GameState.flags["horse_world"] = {}
	_world = GameState.flags["horse_world"]
	HW.ensure(_world, _rng)
	_new_race()

func _new_race() -> void:
	_set_background(BG_BETTING_PATH, 0.35, 0.75)
	var info: float = float(GameState.intelligence)
	_race = HW.make_card(_world, _rng, info)
	_finish = []
	_picks = []
	_bet_stake = 0.0
	_tip = {}
	_tip_seen = false
	_phase = Phase.BETTING
	_races_today += 1
	_render()

func _on_exit() -> void:
	MetaProgression.record_minigame_play("racetrack")
	set_process(false)
	visible = false
	closed.emit()

# ── 렌더 ──────────────────────────────────────────────────────
func _clear() -> void:
	for c in _content.get_children():
		c.queue_free()

func _refresh_top() -> void:
	_header.text = "[b]경마장[/b]   ·   제%d경주   ·   %dm   ·   마장 %s" % [
		_races_today, int(_race.get("distance", 0)), str(_race.get("track", ""))]
	var addic: int = GameState.addiction_tendency
	var bars: int = clampi(addic / 10, 0, 10)
	var ac: String = "#5de89c" if addic < 40 else ("#e8c45d" if addic < 70 else "#e85d5d")
	_hud.text = "현금 [b]%s[/b]      중독도 [color=%s]%s[/color] %d/100      안목(지력) %d" % [
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
	var ordered: bool = BET_ORDERED[_bet_type]

	var head := RichTextLabel.new()
	head.bbcode_enabled = true; head.fit_content = true; head.scroll_active = false
	head.set_anchors_preset(Control.PRESET_TOP_WIDE)
	head.offset_left = 8; head.offset_top = 0; head.offset_right = -8; head.offset_bottom = 24
	_f(head); head.add_theme_font_size_override("normal_font_size", 12)
	head.add_theme_color_override("default_color", Color("#6a7488"))
	head.text = "   말 〔최근전적·선호〕  ·  클래스 거리 마장 기수  ·  단승배당   (★높은데 배당도 높으면 = 저평가)"
	_content.add_child(head)

	var tip_target: int = int(_tip.get("target", -1)) if _tip_seen else -1

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 30; scroll.offset_bottom = -188
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_content.add_child(scroll)
	var vb := VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_theme_constant_override("separation", 5)
	scroll.add_child(vb)

	for i in range(hs.size()):
		var h: Dictionary = hs[i]
		var pos: int = _picks.find(i)
		var sel: bool = pos >= 0
		var rt := RichTextLabel.new()
		rt.bbcode_enabled = true; rt.fit_content = true; rt.scroll_active = false
		rt.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rt.custom_minimum_size = Vector2(0, 52)
		_f(rt); rt.add_theme_font_size_override("normal_font_size", 15)
		var tag: String = ""
		if i == tip_target: tag += "  [color=#6cc5ff]정보상 지목[/color]"
		if i == vpick: tag += "  [color=#f0c45d]저평가[/color]"
		# 선택 배지: 삼쌍승은 착순(①②③), 그 외는 ✓
		var badge: String = ""
		if sel:
			badge = ("[color=#ffe14d]%s[/color] " % PICK_BADGE[pos]) if ordered else "[color=#ffe14d]✓[/color] "
		# 2줄: 1) 이름·★·배당  2) 최근전적·통산·선호
		var line2: String = "[color=#5a6478]    최근 %s · %s · 선호 %dm/%s/%s[/color]" % [
			str(h.get("recent", "신마")), str(h.get("record", "0전 0승")),
			int(h.get("dist_pref", 0)), HW.TRACKS[int(h.get("cond_pref", 0))],
			HW.STYLE_NAMES[int(h.get("style", 0))]]
		rt.text = "%s[color=%s]●[/color] [b]%s[/b]   [color=#c8a050]%s[/color] [color=#5d9ce8]%s[/color] [color=#5de89c]%s[/color] [color=#aaaaaa]%s[/color]   배당 [b]%.1f[/b]%s\n%s" % [
			badge, COLORS[i % COLORS.size()], str(h["name"]),
			_stars(int(h["star_class"])), _stars(int(h["star_dist"])),
			_stars(int(h["star_cond"])), _stars(int(h["star_jockey"])),
			float(h["odds"]), tag, line2]
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 54)
		var st := StyleBoxFlat.new()
		st.bg_color = Color("#141c28") if sel else Color("#0d1119")
		st.border_color = Color("#d0b04a") if sel else (Color("#2d5a7a") if i == tip_target else Color("#1a2230"))
		st.border_width_left = 4
		st.set_corner_radius_all(5)
		st.content_margin_left = 12
		var foc_pick := st.duplicate()
		foc_pick.border_color = Color("#f0b429")
		foc_pick.set_border_width_all(2)
		btn.add_theme_stylebox_override("normal", st)
		var hov := st.duplicate(); hov.bg_color = Color("#1a2433")
		btn.add_theme_stylebox_override("hover", hov)
		btn.add_theme_stylebox_override("pressed", st)
		btn.add_theme_stylebox_override("focus", foc_pick)
		var idx: int = i
		btn.pressed.connect(func(): _toggle_pick(idx))
		btn.add_child(rt)
		rt.set_anchors_preset(Control.PRESET_FULL_RECT)
		rt.offset_left = 12; rt.offset_top = 5
		vb.add_child(btn)

	# ── 베팅 컨트롤 ──
	var bet_panel := VBoxContainer.new()
	bet_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bet_panel.offset_left = 8; bet_panel.offset_top = -182; bet_panel.offset_right = -8
	bet_panel.add_theme_constant_override("separation", 7)
	_content.add_child(bet_panel)

	# 정보상 (오늘의 한 마리 — 진짜일까 함정일까)
	_build_dealer_row(bet_panel)

	# 베팅종류 선택 (연승/단승/복승/삼쌍승)
	var type_row := HBoxContainer.new()
	type_row.add_theme_constant_override("separation", 6)
	bet_panel.add_child(type_row)
	for t in range(BET_NAMES.size()):
		var tb := Button.new()
		tb.text = BET_NAMES[t]
		tb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if t == _bet_type:
			_style(tb, "#2a1e0e", "#d0a040")
			tb.add_theme_color_override("font_color", Color("#ffe7a0"))
		else:
			_style(tb, "#12161e", "#2a3242")
		var tt: int = t
		tb.pressed.connect(func(): _set_bet_type(tt))
		type_row.add_child(tb)

	var info := RichTextLabel.new()
	info.bbcode_enabled = true; info.fit_content = true; info.scroll_active = false
	info.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_f(info); info.add_theme_font_size_override("normal_font_size", 14)
	info.custom_minimum_size = Vector2(0, 24)
	info.text = _bet_info_text()
	bet_panel.add_child(info)

	var need: int = BET_PICKS[_bet_type]
	var ready: bool = _picks.size() >= need
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	bet_panel.add_child(row)
	for amt in [10000, 30000, 100000, 500000]:
		var b := Button.new()
		b.text = GameState.format_money(float(amt))
		_style(b, "#10231a", "#2a7a52")
		b.disabled = (not ready) or (GameState.money < float(amt))
		var a: int = amt
		b.pressed.connect(func(): _place_bet(float(a)))
		row.add_child(b)
	var skip := Button.new()
	skip.text = "이 경주 패스 ▷"
	_style(skip, "#1a1a22", "#3a3a4a")
	skip.pressed.connect(_new_race)
	row.add_child(skip)

func _set_bet_type(t: int) -> void:
	if t == _bet_type: return
	_bet_type = t
	_picks = []
	_render()

# ── 정보상 (오늘의 한 마리 — 진짜 정보 vs 작전 함정) ──────────────
func _build_dealer_row(parent) -> void:
	if not _tip_seen:
		var b := Button.new()
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if GameState.money < 3000:
			b.text = "정보상에게 듣기  (현금 부족)"
			_style(b, "#1a1620", "#3a2a3a"); b.disabled = true
		else:
			b.text = "정보상에게 듣기   -3,000   (오늘의 한 마리...)"
			_style(b, "#1c1726", "#5a4a7a")
			b.pressed.connect(_consult_dealer)
		parent.add_child(b)
		return
	# 팁 표시 — claim + 신뢰도(안목 낮으면 노이즈). 진짜/가짜는 숨긴다.
	var cred: float = float(_tip.get("cred", 0.5))
	var rt := RichTextLabel.new()
	rt.bbcode_enabled = true; rt.fit_content = true; rt.scroll_active = false
	rt.custom_minimum_size = Vector2(0, 30)
	_f(rt); rt.add_theme_font_size_override("normal_font_size", 14)
	var hint: String = ""
	if GameState.intelligence < 40:
		hint = "  [color=#6a7080](안목이 낮아 진위를 가늠하기 어렵다)[/color]"
	rt.text = "[color=#6cc5ff]\"%s\"[/color]   신뢰도 %s [color=#9aa4b8]%d%%[/color]%s" % [
		str(_tip.get("claim", "")), _cred_bar(cred), roundi(cred * 100.0), hint]
	parent.add_child(rt)

func _consult_dealer() -> void:
	if _tip_seen: return
	if GameState.money < 3000:
		_flash("현금이 부족하다", "#e85d5d"); return
	GameState.add_money(-3000)
	GameState.addiction_tendency = clampi(GameState.addiction_tendency + 1, 0, 100)
	GameState.stats_changed.emit()
	_tip = HW.gen_tip(_race, _rng, float(GameState.intelligence))
	# 마스터리 2+: 정보상 함정 없음 (진짜 정보만)
	if MetaProgression.get_mastery("racetrack") >= 2:
		_tip["is_true"] = true
	_tip_seen = true
	AudioManager.play("open_modal")
	_render()

func _cred_bar(cred: float) -> String:
	var n: int = clampi(roundi(cred * 5.0), 0, 5)
	var col: String = "#5de89c" if cred >= 0.6 else ("#e8c45d" if cred >= 0.4 else "#e85d5d")
	return "[color=%s]%s[/color][color=#39414f]%s[/color]" % [col, "●".repeat(n), "○".repeat(5 - n)]

func _toggle_pick(i: int) -> void:
	AudioManager.play("click")
	var need: int = BET_PICKS[_bet_type]
	var pos: int = _picks.find(i)
	if pos >= 0:
		_picks.remove_at(pos)
	elif need == 1:
		_picks = [i]                       # 단일 선택은 교체
	elif _picks.size() >= need:
		_flash("%s은 %d마리까지" % [BET_NAMES[_bet_type], need], "#e8c45d")
		return
	else:
		_picks.append(i)
	_render()

# 현재 선택 조합의 배당 (선택 완료 시)
func _current_odds() -> float:
	var need: int = BET_PICKS[_bet_type]
	if _picks.size() < need: return 0.0
	match _bet_type:
		BetType.PLACE: return HR.place_odds(_race, _picks[0])
		BetType.WIN: return float(_race["horses"][_picks[0]]["odds"])
		BetType.QUINELLA: return HR.quinella_odds(_race, _picks[0], _picks[1])
		BetType.TRIFECTA: return HR.trifecta_odds(_race, _picks[0], _picks[1], _picks[2])
	return 0.0

func _bet_info_text() -> String:
	var need: int = BET_PICKS[_bet_type]
	var hs: Array = _race["horses"]
	if _picks.size() < need:
		var left: int = need - _picks.size()
		var how: String = "착순대로 " if BET_ORDERED[_bet_type] else ""
		return "[color=#9aa4b8][b]%s[/b] · %s  →  %s%d마리 더 고르세요[/color]" % [
			BET_NAMES[_bet_type], BET_DESC[_bet_type], how, left]
	var names: Array = []
	for p in _picks: names.append(str(hs[p]["name"]))
	var joiner: String = " → " if BET_ORDERED[_bet_type] else " + "
	return "[color=#cfe0ff][b]%s[/b]  %s   →   배당 [color=#ffe14d][b]×%.1f[/b][/color]  (베팅액을 고르세요)[/color]" % [
		BET_NAMES[_bet_type], joiner.join(names), _current_odds()]

func _place_bet(stake: float) -> void:
	if _picks.size() < BET_PICKS[_bet_type]: return
	if GameState.money < stake:
		_flash("현금이 부족하다", "#e85d5d"); return
	_bet_stake = stake
	GameState.add_money(-stake)
	AudioManager.play("sell")
	# 도박 — 중독·도박성향 상승. 진 뒤 또 거는(추격) + 엑조틱(고변동)이면 가속.
	var add: int = 3 + (4 if _last_lost else 0)
	if _bet_type == BetType.TRIFECTA: add += 2
	GameState.addiction_tendency = clampi(GameState.addiction_tendency + add, 0, 100)
	GameState.gambling_tendency = clampi(GameState.gambling_tendency + 2, 0, 100)
	GameState.stats_changed.emit()
	_start_race()

# ── 레이스 ────────────────────────────────────────────────────
func _start_race() -> void:
	_phase = Phase.RACE
	# 증명된 모델로 공정한 착순 결정
	_finish = HR.simulate(_race, _rng)
	# 영속 세계에 결과 기록 (재등장 시 전적으로 쌓임)
	HW.record(_world, _race, _finish, GameState.turn)
	# 착순대로 결승 시간 배정 (1착이 가장 빠름, 약간 겹쳐 사진판정 긴장)
	var base: float = 3.2
	for rank in range(_finish.size()):
		var h: Dictionary = _finish[rank]
		h["_ftime"] = base * (1.0 + float(rank) * 0.05) * _rng.randf_range(0.97, 1.03)
	_race_dur = 0.0
	for h in _race["horses"]:
		_race_dur = max(_race_dur, float(h.get("_ftime", base)))
	_race_t = 0.0
	_race_call_t = 0.0
	_hoof_sfx_t = 0.0
	_final_stretch_sfx_played = false
	_last_leader = -1
	_set_background(BG_TRACK_PATH, 0.50, 0.62)
	_clear()
	_render_race()
	if skip_countdown_for_smoke:
		set_process(true)
	else:
		_run_countdown()

func _run_countdown() -> void:
	var overlay := Label.new()
	overlay.set_anchors_preset(Control.PRESET_CENTER)
	overlay.offset_left = -100; overlay.offset_right = 100
	overlay.offset_top  = -60;  overlay.offset_bottom = 60
	overlay.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	overlay.add_theme_font_size_override("font_size", 72)
	overlay.add_theme_color_override("font_color", Color("#f0c45d"))
	_f(overlay, true)
	add_child(overlay)
	var steps := ["3", "2", "1", "출발!"]
	var colors := [Color("#e85d5d"), Color("#e8a05d"), Color("#e8e05d"), Color("#5de8a0")]
	_play_countdown_step(overlay, steps, colors, 0)

func _play_countdown_step(overlay: Label, steps: Array, colors: Array, idx: int) -> void:
	if not is_instance_valid(overlay):
		return
	if idx >= steps.size():
		overlay.queue_free()
		_flash("출발!", "#f0c45d")
		_screen_flash(Color("#f0c45d"), 0.14, 0.28)
		_shake_node(_content, 4.0, 0.18)
		AudioManager.play("event_new")
		set_process(true)
		return
	overlay.text = str(steps[idx])
	overlay.add_theme_color_override("font_color", colors[idx])
	var tw := create_tween()
	tw.tween_property(overlay, "scale", Vector2(1.3, 1.3), 0.0)
	tw.tween_property(overlay, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_BACK)
	var next_idx: int = idx + 1
	var delay: float = 0.9 if next_idx < steps.size() else 0.6
	get_tree().create_timer(delay).timeout.connect(
		func(): _play_countdown_step(overlay, steps, colors, next_idx),
		CONNECT_ONE_SHOT)

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
	_update_race_sfx(delta)
	if is_instance_valid(_track):
		_track.queue_redraw()
	_update_race_call(delta)
	if _race_t >= _race_dur + 0.4:
		set_process(false)
		_finish_race()

func _update_race_call(delta: float) -> void:
	_race_call_t += delta
	if _race_call_t < 0.35:
		return
	_race_call_t = 0.0
	var leader := _current_display_leader()
	if leader < 0:
		return
	var hs: Array = _race["horses"]
	var leader_name := str(hs[leader].get("name", "선두"))
	if _race_dur - _race_t <= 0.85:
		_set_race_msg("마지막 직선!  %s 버틴다!" % leader_name, "#f0c45d")
		if not _final_stretch_sfx_played:
			_final_stretch_sfx_played = true
			AudioManager.play("event_new", -2.0)
			_shake_node(_content, 3.0, 0.16)
		if is_instance_valid(_msg):
			_pulse_node(_msg, 1.12, 0.22)
	elif leader != _last_leader:
		_last_leader = leader
		_set_race_msg("선두 교체 — %s!" % leader_name, COLORS[leader % COLORS.size()])
		if is_instance_valid(_msg):
			_pulse_node(_msg, 1.08, 0.18)

func _update_race_sfx(delta: float) -> void:
	_hoof_sfx_t += delta
	var phase_prog := clampf(_race_t / maxf(_race_dur, 0.1), 0.0, 1.0)
	var interval := lerpf(0.17, 0.08, phase_prog)
	if _hoof_sfx_t >= interval:
		_hoof_sfx_t = 0.0
		AudioManager.play("casino_reel", -7.0)

func _current_display_leader() -> int:
	if not _race.has("horses"):
		return -1
	var hs: Array = _race["horses"]
	var best := -1
	var best_prog := -INF
	for i in range(hs.size()):
		var prog := _display_progress(hs[i], i)
		if prog > best_prog:
			best_prog = prog
			best = i
	return best

func _set_race_msg(text: String, color: String) -> void:
	_msg.text = text
	_msg.add_theme_color_override("font_color", Color(color))
	_msg.visible = true

func _draw_track() -> void:
	var sz: Vector2 = _track.size
	if sz.x < 40 or sz.y < 40: return
	var hs: Array = _race["horses"]
	var n: int = hs.size()
	var pad_l: float = 126.0
	var pad_r: float = 78.0
	var fin_x: float = sz.x - pad_r
	var lane_h: float = (sz.y - 20.0) / float(n)
	var f := ThemeDB.fallback_font
	var track_rect := Rect2(Vector2(pad_l - 24.0, 8.0), Vector2(fin_x - pad_l + 54.0, sz.y - 18.0))
	_draw_racecourse_base(track_rect, pad_l, fin_x, sz, f)
	# 결승선
	_draw_finish_gate(fin_x, sz, f)
	_draw_start_gate(pad_l, sz, lane_h)
	for i in range(n):
		var h: Dictionary = hs[i]
		var y: float = 14.0 + lane_h * float(i) + lane_h * 0.5
		# 레인
		var lane_y := y + lane_h * 0.45
		var lane_color := Color(0.45, 0.27, 0.13, 0.30 if i % 2 == 0 else 0.22)
		_track.draw_rect(Rect2(pad_l, lane_y - lane_h * 0.31, fin_x - pad_l, lane_h * 0.62), lane_color)
		_track.draw_line(Vector2(pad_l, lane_y), Vector2(fin_x, lane_y), Color(1,1,1,0.12), 1.0)
		var prog: float = _display_progress(h, i)
		var x: float = pad_l + (fin_x - pad_l) * prog
		var col := Color(COLORS[i % COLORS.size()])
		# 말: 질주 실루엣(레인별 프레임 오프셋으로 애니) + 레인색 새들 마커
		#     텍스처 없으면 색 원으로 폴백
		if HORSE_TEX != null:
			var hsz: float = clampf(lane_h * 1.55, 44.0, 68.0)
			var frame: int = (int(_race_t * 14.0) + i) % 8
			var src := Rect2(float(frame) * 128.0, 0.0, 128.0, 128.0)
			var dst := Rect2(x - hsz * 0.5, lane_y - hsz, hsz, hsz)
			_draw_speed_fx(Vector2(x, lane_y), hsz, col, prog)
			_track.draw_texture_rect_region(HORSE_TEX, dst.grow(2.0), src, Color(col.r, col.g, col.b, 0.45))
			_track.draw_texture_rect_region(HORSE_TEX, dst, src, Color(0.02, 0.018, 0.015, 0.96))
			_draw_jockey(dst, col, i)
			_draw_saddle_number(dst, i + 1, col, f)
		else:
			_track.draw_circle(Vector2(x, y), 9.0, col)
		var ppos: int = _picks.find(i)
		if ppos >= 0:
			_track.draw_arc(Vector2(x, y), 13.0, 0, TAU, 24, Color("#ffe14d"), 2.0)
			if BET_ORDERED[_bet_type]:
				_track.draw_string(f, Vector2(x + 14, y + 5), PICK_BADGE[ppos],
					HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#ffe14d"))
		_track.draw_string(f, Vector2(26.0, lane_y - 10.0), str(h["name"]),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, col)
	_draw_live_board(hs, f, sz)

func _draw_racecourse_base(track_rect: Rect2, pad_l: float, fin_x: float, sz: Vector2, f: Font) -> void:
	_track.draw_rect(Rect2(track_rect.position + Vector2(0.0, 8.0), track_rect.size), Color(0, 0, 0, 0.28), true)
	_track.draw_rect(track_rect, Color(0.30, 0.19, 0.10, 0.42), true)
	_track.draw_rect(track_rect, Color(0.82, 0.62, 0.36, 0.23), false, 2.0)
	for marker in [0.25, 0.50, 0.75]:
		var mx := lerpf(pad_l, fin_x, float(marker))
		_track.draw_line(Vector2(mx, track_rect.position.y + 6.0), Vector2(mx, track_rect.end.y - 6.0), Color(1, 1, 1, 0.08), 1.0)
		_track.draw_string(f, Vector2(mx - 16.0, track_rect.position.y + 18.0), "%d%%" % int(marker * 100.0),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1, 1, 1, 0.18))

	var rail_top := track_rect.position.y + 12.0
	var rail_bottom := track_rect.end.y - 12.0
	for y in [rail_top, rail_bottom]:
		_track.draw_line(Vector2(pad_l - 8.0, y), Vector2(fin_x + 10.0, y), Color(0.92, 0.86, 0.72, 0.44), 3.0)
		_track.draw_line(Vector2(pad_l - 8.0, y + 4.0), Vector2(fin_x + 10.0, y + 4.0), Color(0.05, 0.04, 0.03, 0.28), 1.0)
	for post_i in range(18):
		var px := lerpf(pad_l - 8.0, fin_x + 10.0, float(post_i) / 17.0)
		_track.draw_line(Vector2(px, rail_top - 5.0), Vector2(px, rail_top + 8.0), Color(0.86, 0.76, 0.58, 0.30), 1.0)
		_track.draw_line(Vector2(px, rail_bottom - 8.0), Vector2(px, rail_bottom + 5.0), Color(0.86, 0.76, 0.58, 0.30), 1.0)

	var grandstand := Rect2(Vector2(0.0, sz.y - 92.0), Vector2(sz.x, 92.0))
	_track.draw_rect(grandstand, Color(0.02, 0.025, 0.035, 0.36), true)
	for i in range(24):
		var px := float(i) / 23.0 * sz.x
		var head_y := sz.y - 70.0 + sin(float(i) * 1.7) * 10.0
		_track.draw_circle(Vector2(px, head_y), 3.0, Color(0, 0, 0, 0.42))
		_track.draw_line(Vector2(px, head_y + 3.0), Vector2(px + randf_range(-4.0, 4.0), head_y + 18.0), Color(0, 0, 0, 0.32), 1.0)

func _draw_start_gate(pad_l: float, sz: Vector2, lane_h: float) -> void:
	var gate_x := pad_l - 24.0
	_track.draw_rect(Rect2(Vector2(gate_x - 7.0, 18.0), Vector2(14.0, sz.y - 54.0)), Color("#111820"), true)
	_track.draw_rect(Rect2(Vector2(gate_x - 7.0, 18.0), Vector2(14.0, sz.y - 54.0)), Color(0.70, 0.78, 0.86, 0.28), false, 1.0)
	for i in range(int(maxf(1.0, floor((sz.y - 48.0) / lane_h)))):
		var y := 22.0 + lane_h * float(i)
		_track.draw_rect(Rect2(Vector2(gate_x - 14.0, y), Vector2(28.0, 16.0)), Color(0.10, 0.16, 0.20, 0.72), true)
		_track.draw_line(Vector2(gate_x - 14.0, y + 8.0), Vector2(gate_x + 14.0, y + 8.0), Color(0.80, 0.90, 1.0, 0.18), 1.0)

func _draw_finish_gate(fin_x: float, sz: Vector2, f: Font) -> void:
	_track.draw_line(Vector2(fin_x, 8.0), Vector2(fin_x, sz.y - 10.0), Color("#f0f0f0"), 3.0)
	for k in range(0, int(sz.y), 12):
		var tile_col := Color(1, 1, 1, 0.70) if (k / 12) % 2 == 0 else Color(0.02, 0.02, 0.02, 0.62)
		_track.draw_rect(Rect2(fin_x - 5.0, float(k), 10.0, 6.0), tile_col, true)
	_track.draw_rect(Rect2(Vector2(fin_x - 44.0, 10.0), Vector2(88.0, 22.0)), Color("#0a0d12"), true)
	_track.draw_rect(Rect2(Vector2(fin_x - 44.0, 10.0), Vector2(88.0, 22.0)), Color("#f0c45d"), false, 1.0)
	_track.draw_string(f, Vector2(fin_x - 29.0, 26.0), "FINISH", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#f0c45d"))

func _draw_saddle_number(dst: Rect2, num: int, lane_color: Color, f: Font) -> void:
	var hsz := dst.size.x
	var cloth := Rect2(
		Vector2(dst.position.x + hsz * 0.39, dst.position.y + hsz * 0.48),
		Vector2(hsz * 0.28, hsz * 0.18)
	)
	_track.draw_rect(cloth, lane_color.darkened(0.12), true)
	_track.draw_rect(cloth, Color(1, 1, 1, 0.65), false, 1.0)
	_track.draw_string(f, cloth.position + Vector2(cloth.size.x * 0.30, cloth.size.y * 0.78), str(num),
		HORIZONTAL_ALIGNMENT_LEFT, -1, int(maxf(8.0, hsz * 0.16)), Color.WHITE)

func _draw_live_board(hs: Array, f: Font, sz: Vector2) -> void:
	var order: Array = []
	for i in range(hs.size()):
		order.append(i)
	order.sort_custom(func(a, b):
		return _display_progress(hs[int(a)], int(a)) > _display_progress(hs[int(b)], int(b))
	)
	var board := Rect2(Vector2(sz.x - 330.0, 18.0), Vector2(290.0, 104.0))
	_track.draw_rect(Rect2(board.position + Vector2(0, 5), board.size), Color(0, 0, 0, 0.30), true)
	_track.draw_rect(board, Color(0.02, 0.025, 0.035, 0.70), true)
	_track.draw_rect(board, Color("#f0c45d"), false, 1.0)
	_track.draw_string(f, board.position + Vector2(14.0, 22.0), "LIVE ORDER",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#f0c45d"))
	for rank in range(min(3, order.size())):
		var idx := int(order[rank])
		var h: Dictionary = hs[idx]
		var col := Color(COLORS[idx % COLORS.size()])
		var y := board.position.y + 45.0 + float(rank) * 20.0
		_track.draw_circle(Vector2(board.position.x + 18.0, y - 5.0), 4.0, col)
		_track.draw_string(f, Vector2(board.position.x + 30.0, y), "%d  %s" % [rank + 1, str(h["name"])],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#dce4f0"))

func _display_progress(h: Dictionary, index: int) -> float:
	var ft: float = float(h.get("_ftime", _race_dur))
	var raw := clampf(_race_t / max(ft, 0.1), 0.0, 1.0)
	var wobble := sin(_race_t * (4.0 + float(index) * 0.33) + float(index) * 1.7) * 0.026 * sin(raw * PI)
	var kick := sin(_race_t * 9.0 + float(index)) * 0.007 * sin(raw * PI)
	return clampf(raw + wobble + kick, 0.0, 1.0)

func _draw_speed_fx(hoof: Vector2, hsz: float, lane_color: Color, prog: float) -> void:
	if prog <= 0.01:
		return
	var speed_alpha := clampf(0.08 + prog * 0.18, 0.08, 0.26)
	for d in range(3):
		var back := hoof + Vector2(-hsz * (0.44 + float(d) * 0.36), randf_range(-2.0, 2.0))
		var dust := Color(0.86, 0.68, 0.42, speed_alpha * (1.0 - float(d) * 0.22))
		_track.draw_circle(back, hsz * (0.08 + float(d) * 0.025), dust)
	_track.draw_line(hoof + Vector2(-hsz * 0.22, -hsz * 0.20), hoof + Vector2(-hsz * 0.95, -hsz * 0.18), Color(lane_color.r, lane_color.g, lane_color.b, 0.28), 2.0)
	_track.draw_line(hoof + Vector2(-hsz * 0.26, -hsz * 0.42), hoof + Vector2(-hsz * 0.82, -hsz * 0.46), Color(1, 1, 1, 0.13), 1.0)

func _draw_jockey(dst: Rect2, lane_color: Color, index: int) -> void:
	var hsz := dst.size.x
	var saddle := Vector2(dst.position.x + hsz * 0.48, dst.position.y + hsz * 0.45)
	var silk := lane_color.lightened(0.28)
	var helmet := saddle + Vector2(hsz * 0.08, -hsz * 0.18)
	var body := saddle + Vector2(hsz * 0.02, -hsz * 0.05)
	var lean := Vector2(hsz * 0.20, -hsz * 0.08)
	_track.draw_rect(Rect2(saddle.x - hsz * 0.18, saddle.y - hsz * 0.03, hsz * 0.34, hsz * 0.10), Color("#1a1410"))
	_track.draw_line(body, body + lean, silk, max(2.0, hsz * 0.09))
	_track.draw_line(body + Vector2(-hsz * 0.02, hsz * 0.02), body + Vector2(-hsz * 0.14, hsz * 0.14), Color("#f0d2a0"), max(1.5, hsz * 0.035))
	_track.draw_circle(helmet, hsz * 0.09, Color("#f7e2a0") if index % 2 == 0 else Color("#f8f8f2"))
	_track.draw_circle(helmet + Vector2(hsz * 0.025, hsz * 0.015), hsz * 0.045, Color("#2a221a"))
	_track.draw_line(helmet + Vector2(hsz * 0.01, -hsz * 0.02), helmet + Vector2(hsz * 0.18, -hsz * 0.03), silk, max(1.0, hsz * 0.025))

func _finish_race() -> void:
	_phase = Phase.RESULT
	if is_instance_valid(_msg):
		_msg.visible = false
	var payout: float = 0.0
	match _bet_type:
		BetType.PLACE: payout = HR.payout_place(_race, _picks[0], _bet_stake, _finish)
		BetType.WIN: payout = HR.payout_win(_race, _picks[0], _bet_stake, _finish)
		BetType.QUINELLA: payout = HR.payout_quinella(_race, _picks[0], _picks[1], _bet_stake, _finish)
		BetType.TRIFECTA: payout = HR.payout_trifecta(_race, _picks[0], _picks[1], _picks[2], _bet_stake, _finish)
	if payout > 0:
		GameState.add_money(payout)
		var profit := payout - _bet_stake
		AudioManager.play_casino_result(profit, float(_bet_stake), profit >= float(_bet_stake) * 10.0)
		_screen_flash(Color("#f0b429"), 0.22, 0.44)
		_shake_node(_content, 5.0, 0.22)
		_last_lost = false
	else:
		AudioManager.play_casino_result(-float(_bet_stake), float(_bet_stake))
		_screen_flash(Color("#d73a49"), 0.22, 0.38)
		_shake_node(_content, 10.0, 0.30)
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
	title.text = "결과"
	title.add_theme_color_override("font_color", Color("#e8eaf0"))
	box.add_child(title)

	for rank in range(min(_finish.size(), 4)):
		var h: Dictionary = _finish[rank]
		var medal: String = ["1", "2", "3", "4"][rank]
		var lbl := Label.new()
		_f(lbl); lbl.add_theme_font_size_override("font_size", 16)
		var hidx: int = _race["horses"].find(h)
		var mine: String = "   ← 내 픽" if hidx in _picks else ""
		lbl.text = "%s위 / %d착   %s   (배당 %.1f)%s" % [medal, rank + 1, str(h["name"]), float(h["odds"]), mine]
		lbl.add_theme_color_override("font_color", Color("#f0c45d") if rank == 0 else Color("#aab3c5"))
		box.add_child(lbl)

	var photo := Control.new()
	photo.custom_minimum_size = Vector2(0, 168)
	photo.draw.connect(func(): _draw_finish_photo(photo))
	box.add_child(photo)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color("#252535"))
	box.add_child(sep)

	var res := Label.new()
	_f(res, true); res.add_theme_font_size_override("font_size", 22)
	if _payout_amt > 0:
		var profit: float = _payout_amt - _bet_stake
		res.text = "적중!  +%s  (배당금 %s)" % [GameState.format_money(profit), GameState.format_money(_payout_amt)]
		res.add_theme_color_override("font_color", Color("#5de89c"))
	else:
		res.text = "꽝.  -%s" % GameState.format_money(_bet_stake)
		res.add_theme_color_override("font_color", Color("#e85d5d"))
	box.add_child(res)
	_pulse_node(res, 1.12, 0.34)

	# 정보상 팁을 샀다면 진위 공개 — 다음엔 안목을 믿을지 학습
	if _tip_seen:
		var won_h: Dictionary = _finish[0] if not _finish.is_empty() else {}
		var hit: bool = (not won_h.is_empty()) and int(won_h.get("rid", -99)) == int(_race["horses"][int(_tip["target"])]["rid"])
		var verdict := Label.new()
		_f(verdict); verdict.add_theme_font_size_override("font_size", 14)
		if bool(_tip.get("is_true", false)):
			verdict.text = "정보상은 진짜였다 — '%s' (지목마 %s)" % [
				str(_tip.get("name", "")), "1착 적중" if hit else "이번엔 안 풀림"]
			verdict.add_theme_color_override("font_color", Color("#6cc5ff"))
		else:
			verdict.text = "정보상은 함정이었다 — '%s'는 작전이었다" % str(_tip.get("name", ""))
			verdict.add_theme_color_override("font_color", Color("#c47a7a"))
		box.add_child(verdict)

	if GameState.addiction_tendency >= 70:
		var warn := Label.new()
		_f(warn); warn.add_theme_font_size_override("font_size", 13)
		warn.text = "위험 신호: '딱 한 번만 더'가 가장 위험하다. (중독도 %d)" % GameState.addiction_tendency
		warn.add_theme_color_override("font_color", Color("#e8a05d"))
		box.add_child(warn)

	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	row.offset_top = -56; row.offset_left = 24; row.offset_right = -24
	row.add_theme_constant_override("separation", 10)
	_content.add_child(row)
	var again := Button.new()
	again.text = "다음 경주"
	_style(again, "#231016", "#a03a4a")
	again.pressed.connect(_new_race)
	row.add_child(again)
	var leave := Button.new()
	leave.text = "오늘은 그만, 나간다"
	_style(leave, "#10231a", "#2a7a52")
	leave.pressed.connect(_on_exit)
	row.add_child(leave)

func _draw_finish_photo(ctrl: Control) -> void:
	var sz := ctrl.size
	if sz.x < 60.0 or sz.y < 60.0:
		return
	var f := ThemeDB.fallback_font
	var rect := Rect2(Vector2(0.0, 8.0), Vector2(sz.x, sz.y - 16.0))
	ctrl.draw_rect(Rect2(rect.position + Vector2(0.0, 5.0), rect.size), Color(0, 0, 0, 0.28), true)
	ctrl.draw_rect(rect, Color(0.025, 0.030, 0.040, 0.72), true)
	ctrl.draw_rect(rect, Color("#f0c45d"), false, 1.0)
	ctrl.draw_string(f, rect.position + Vector2(16.0, 24.0), "PHOTO FINISH",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#f0c45d"))
	var finish_x := rect.end.x - 110.0
	ctrl.draw_line(Vector2(finish_x, rect.position.y + 28.0), Vector2(finish_x, rect.end.y - 12.0), Color("#ffffff"), 2.0)
	for k in range(0, int(rect.size.y - 40.0), 10):
		var tile := Color(1, 1, 1, 0.68) if (k / 10) % 2 == 0 else Color(0, 0, 0, 0.62)
		ctrl.draw_rect(Rect2(Vector2(finish_x - 4.0, rect.position.y + 30.0 + float(k)), Vector2(8.0, 5.0)), tile, true)
	for rank in range(min(3, _finish.size())):
		var h: Dictionary = _finish[rank]
		var hidx: int = _race["horses"].find(h)
		var col := Color(COLORS[hidx % COLORS.size()])
		var y := rect.position.y + 58.0 + float(rank) * 34.0
		var x := finish_x - float(rank) * 52.0 - 32.0
		ctrl.draw_line(Vector2(rect.position.x + 28.0, y + 14.0), Vector2(rect.end.x - 28.0, y + 14.0), Color(1, 1, 1, 0.08), 1.0)
		ctrl.draw_circle(Vector2(x - 20.0, y + 8.0), 9.0, Color(col.r, col.g, col.b, 0.22))
		if HORSE_TEX != null:
			var src := Rect2(0.0, 0.0, 128.0, 128.0)
			var dst := Rect2(Vector2(x - 26.0, y - 12.0), Vector2(54.0, 54.0))
			ctrl.draw_texture_rect_region(HORSE_TEX, dst.grow(2.0), src, Color(col.r, col.g, col.b, 0.45))
			ctrl.draw_texture_rect_region(HORSE_TEX, dst, src, Color(0.02, 0.018, 0.015, 0.96))
		else:
			ctrl.draw_circle(Vector2(x, y + 8.0), 9.0, col)
		ctrl.draw_rect(Rect2(Vector2(x - 8.0, y + 10.0), Vector2(20.0, 14.0)), col.darkened(0.08), true)
		ctrl.draw_string(f, Vector2(x - 2.0, y + 22.0), str(rank + 1),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		ctrl.draw_string(f, Vector2(rect.position.x + 58.0, y + 17.0), "%d위  %s" % [rank + 1, str(h["name"])],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#dce4f0"))

# ── 유틸 ──────────────────────────────────────────────────────
func _flash(msg: String, color: String) -> void:
	_msg.text = msg
	_msg.add_theme_color_override("font_color", Color(color))
	_msg.visible = true
	var t := get_tree().create_timer(1.4)
	t.timeout.connect(func():
		if is_instance_valid(_msg): _msg.visible = false)

func _set_background(path: String, image_alpha: float, scrim_alpha: float) -> void:
	if is_instance_valid(_bg_img) and ResourceLoader.exists(path):
		_bg_img.texture = load(path) as Texture2D
		_bg_img.modulate = Color(1, 1, 1, image_alpha)
	elif is_instance_valid(_bg_img):
		_bg_img.texture = null
	if is_instance_valid(_bg_scrim):
		var bg_color := Color("#0a0d12")
		bg_color.a = scrim_alpha if is_instance_valid(_bg_img) and _bg_img.texture else 1.0
		_bg_scrim.color = bg_color

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

func _style(b: Button, bg: String, border: String) -> void:
	var st := StyleBoxFlat.new()
	st.bg_color = Color(bg); st.border_color = Color(border)
	st.set_border_width_all(1); st.set_corner_radius_all(5)
	st.content_margin_left = 14; st.content_margin_right = 14
	st.content_margin_top = 8; st.content_margin_bottom = 8
	var hov := st.duplicate(); hov.bg_color = Color(bg).lightened(0.1)
	var dis := st.duplicate(); dis.bg_color = Color("#141419"); dis.border_color = Color("#222")
	var foc := st.duplicate()
	foc.border_color = Color("#f0b429")
	foc.set_border_width_all(2)
	b.add_theme_stylebox_override("normal", st)
	b.add_theme_stylebox_override("hover", hov)
	b.add_theme_stylebox_override("pressed", st)
	b.add_theme_stylebox_override("disabled", dis)
	b.add_theme_stylebox_override("focus", foc)
	b.add_theme_color_override("font_color", Color("#dce4f0"))
	b.add_theme_color_override("font_disabled_color", Color("#4a4a58"))
	b.add_theme_font_size_override("font_size", 14)
	_f(b)
