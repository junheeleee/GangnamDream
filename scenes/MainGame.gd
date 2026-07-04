extends Control

# ── Steam 출시 설정 ───────────────────────────────────────────
# Steamworks에 앱 등록 후 STEAM_APP_ID를 실제 숫자 ID로 교체하면 위시리스트
# 버튼이 정식 상점 페이지로 연결된다. 그 전까지는 안전한 폴백(상점 검색)으로 연결.
const STEAM_APP_ID := "STEAM_APP_ID"  # TODO: Steamworks 등록 후 실제 App ID(숫자)로 교체
const STEAM_FALLBACK_URL := "https://store.steampowered.com/search/?term=Gangnam%20Dream"

var investment_system: Node
var job_system: Node
var relationship_system: Node
var inventory_system: Node

var top_labels: Dictionary = {}
var stat_labels: Dictionary = {}
var event_title: Label
var event_body: RichTextLabel
var choice_box: VBoxContainer
var news_box: VBoxContainer
var ticker_rtl: RichTextLabel
var relationship_box: VBoxContainer
var inventory_box: VBoxContainer
var arc_box: VBoxContainer
var log_box: RichTextLabel
var modal_layer: ColorRect
var modal_scroll: ScrollContainer
var modal_panel: PanelContainer
var modal_body: VBoxContainer
var modal_title_label: Label
var modal_pad_hint_label: Label
var next_button: Button
var shop_button: Button
var _modal_cancelable: bool = false
var _modal_kind: String = ""
var _invest_pad_asset_idx: int = 0
var _invest_pad_action_idx: int = 0
var _invest_pad_asset_ids: Array = []
var _invest_pad_asset_cards: Array = []
var _invest_pad_hint_label: RichTextLabel = null
var _invest_page_idx: int = 0
var _invest_page_body: VBoxContainer = null
var _invest_page_tab_buttons: Array = []
var _job_page_idx: int = 0
var _job_candidate_idx: int = 0
var _job_page_body: VBoxContainer = null
var _job_page_tab_buttons: Array = []
var _job_candidate_cards: Array = []
var _job_pad_hint_label: RichTextLabel = null
var _people_page_idx: int = 0
var _people_action_idx: int = 0
var _people_page_body: VBoxContainer = null
var _people_page_tab_buttons: Array = []
var _people_action_cards: Array = []
var _people_pad_hint_label: RichTextLabel = null
var _toast_container: VBoxContainer
var event_bg: TextureRect
var _feedback_flash: ColorRect
var _feedback_flash_tween: Tween = null
var _event_bg_path: String = ""   # 현재 표시 중인 배경 경로 (크로스페이드 중복 방지)
var _typing_tween: Tween = null   # 타이핑 효과 전용 트윈
var _choice_reveal_pending: bool = false  # 타이핑 완료 후 선택지 표시 대기
var _result_reveal_controls: Array[Control] = []
var _result_focus_button: Button = null
var _vignette_rect: ColorRect = null      # 스트레스/정신력 비네팅 레이어
var _ambient_overlay: ColorRect = null
var _category_tint: ColorRect = null  # 이벤트 카테고리 색 틴트
var _moral_tint_overlay: ColorRect = null  # MORAL_TINT: 배경 온도/채도 필터
var _moral_surface_overlay: ColorRect = null  # MORAL_TINT: 화면 표면의 부식/선명도 레이어
var _moral_surface_material: ShaderMaterial = null
var _moral_bg_material: ShaderMaterial = null
var _moral_portrait_material: ShaderMaterial = null
var _moral_tint_tween: Tween = null
var _moral_world_tween: Tween = null
var _moral_echo_tween: Tween = null
var _moral_visual_initialized: bool = false
var _moral_norm: float = 0.0
var _moral_stage: int = 0
var _ink_transition_layer: Control = null
var _ink_transition_tween: Tween = null
var _ink_transition_progress: float = 0.0
var _ink_transition_kind: String = "neutral"
var _event_bg_motion_tween: Tween = null
var _transient_bg_active: bool = false
var _main_ui_root: Control = null
var _minigame_overlay_active: bool = false
var character_portrait: TextureRect
var _story_container: Control
var info_panel: Control
var info_tabs: TabContainer
var _info_pad_hint_label: Label
var player_name_label: Label
var title_label: Label
var _ui_icon_cache: Dictionary = {}

# ── MORAL MONOCHROME 팔레트 ─────────────────────────────────────
# 이 게임의 중심 상태는 회색/진회색/검정/연회색/흰색이다.
# 금색·남색·갈색을 기본값으로 쓰면 MORAL_TINT와 충돌하므로 기본 UI는 무채색으로 둔다.
const COL_GOLD       := "#c5ccd5"   # 주강조 — 낡은 은빛
const COL_GOLD_BRIGHT := "#f4f7fb"  # 밝은 강조 — 거의 백색
const COL_GOLD_DIM   := "#6f7680"   # 어두운 강조 — 재빛
const COL_INK        := "#08090b"   # 잉크 — 패널 바닥
const COL_INK_RAISED := "#11151a"   # 살짝 뜬 패널
const COL_TEXT       := "#d6dce4"   # 본문 — 차가운 회백색
const COL_TEXT_DIM   := "#7b838d"   # 흐린 본문 — 회색
const COL_DANGER     := "#c0392b"   # 위험 — 딥레드
const UI_MIN_BODY_FONT := 14
const UI_MIN_BUTTON_FONT := 15
const UI_MIN_BUTTON_HEIGHT := 46
const UI_MIN_SMALL_BUTTON_HEIGHT := 38
const UI_FOCUS_BORDER := 3
const UI_INFO_PANEL_WIDTH := 440

const BG_PATHS = {
	"gosiwon":   "res://assets/backgrounds/goshiwon_room.png",
	"oneroom":   "res://assets/backgrounds/oneroom_apartment.png",
	"villa":     "res://assets/backgrounds/oneroom_apartment.png",
	"apartment": "res://assets/backgrounds/gangnam_apartment.png",
	"gangnam":   "res://assets/backgrounds/gangnam_apartment.png",
}
const BG_DEFAULT        = "res://assets/backgrounds/seoul_rainy_street.png"
const BG_OFFICE         = "res://assets/backgrounds/office_desk.png"
const BG_SUBWAY         = "res://assets/backgrounds/seoul_subway.png"
const BG_CONVENIENCE    = "res://assets/backgrounds/convenience_store_night.png"
const BG_CAFE           = "res://assets/backgrounds/cafe_seoul.png"
const BG_INVESTMENT     = "res://assets/backgrounds/investment_phone.png"
const BG_HOSPITAL       = "res://assets/backgrounds/hospital_corridor.png"
# Canonical 4am variant generated from goshiwon_room.png; same room layout.
const BG_NIGHT_ROOM     = "res://assets/backgrounds/late_night_room.png"
const BG_HOMETOWN       = "res://assets/backgrounds/hometown_train_station.png"
const BG_ROOFTOP_DAY    = "res://assets/backgrounds/rooftop_daytime.png"
const BG_GANGNAM_NIGHT  = "res://assets/backgrounds/gangnam_night_street.png"
const BG_PENTHOUSE      = "res://assets/backgrounds/penthouse_view.png"
const BG_BURNOUT        = "res://assets/backgrounds/burnout_hospital_room.png"
const BG_FAMILY         = "res://assets/backgrounds/family_living_room.png"
const BG_MILITARY       = "res://assets/backgrounds/military_training_ground.png"
const BG_TRADING        = "res://assets/backgrounds/trading_screen_night.png"
const BG_RACETRACK      = "res://assets/backgrounds/racetrack_betting_hall.png"
const BG_HOLDEM         = "res://assets/backgrounds/holdem_club_interior.png"
const BG_SCALPING       = "res://assets/backgrounds/scalping_trading_room.png"
const BG_PC_BANG        = "res://assets/backgrounds/pc_bang_interior.png"
const BG_GANGNAM_ST     = "res://assets/backgrounds/gangnam_station_exit.png"

const PORTRAIT_NEUTRAL    = "res://assets/characters/main_character_neutral_goshiwon.png"

const UI_ICON_PATHS := {
	"ap": "res://assets/ui/icons/icon_ap.svg",
	"money": "res://assets/ui/icons/icon_money.svg",
	"goal": "res://assets/ui/icons/icon_goal.svg",
	"health": "res://assets/ui/icons/icon_health.svg",
	"mental": "res://assets/ui/icons/icon_mental.svg",
	"job": "res://assets/ui/icons/icon_job.svg",
	"study": "res://assets/ui/icons/icon_study.svg",
	"rest": "res://assets/ui/icons/icon_rest.svg",
	"invest": "res://assets/ui/icons/icon_invest.svg",
	"leverage": "res://assets/ui/icons/icon_leverage.svg",
	"market": "res://assets/ui/icons/icon_scalping.svg",
	"racetrack": "res://assets/ui/icons/icon_racetrack.svg",
	"holdem": "res://assets/ui/icons/icon_holdem.svg",
	"scalping": "res://assets/ui/icons/icon_scalping.svg",
	"casino": "res://assets/ui/chips/chip_10k.svg",
	"people": "res://assets/ui/icons/icon_relationship.svg",
	"life": "res://assets/ui/icons/icon_housing.svg",
	"shop": "res://assets/ui/icons/icon_shop.svg",
	"info": "res://assets/ui/icons/icon_info.svg",
	"save": "res://assets/ui/icons/icon_save.svg",
	"menu": "res://assets/ui/icons/icon_menu.svg",
	"next": "res://assets/ui/icons/icon_next_month.svg",
}

var current_event: Dictionary = {}
var prev_prices: Dictionary = {}
var pending_result_text: String = ""
var _last_chosen_foreshadow: String = ""
var _choice_countdown_timer: Timer = null
var _choice_countdown_remaining: int = 0
var racetrack      # 경마 미니게임 오버레이
var holdem_club    # 홀덤 클럽 미니게임 오버레이
var scalping_game  # 스캘핑 아케이드 미니게임 오버레이
var aruba_game     # 아르바이트 시프트 미니게임 오버레이
var job_hunt_game  # 구직활동 미니게임 오버레이 (이력서/면접)
var life_skills_game  # (제거됨 — 서사 직접 처리로 교체)
var baccarat_table   # 정선 카지노 바카라 오버레이
var blackjack_table  # 정선 카지노 블랙잭 오버레이
var slot_machine_game  # 정선 카지노 슬롯머신 오버레이
var roulette_table     # 정선 카지노 룰렛 오버레이
var big_wheel_game     # 정선 카지노 빅휠 오버레이
var dai_sai_table      # 정선 카지노 다이사이 오버레이
var jeongseon_casino     # 정선 카지노 허브 오버레이
# 상황 카드 시스템 — 매 턴 뽑은 상황들 + 이번 턴 처리한 상황 id
var month_situations: Array = []
var month_situations_turn: int = -1
var engaged_situations: Dictionary = {}
var turn_action_log: Array = []
var _pending_month_summary: bool = false

# ── 목표 진행바 ──────────────────────────────────────────────────
var _goal_bar: ProgressBar
var _goal_pct_label: Label
var _goal_money_lbl: Label
var _goal_time_lbl: Label  # 남은 개월 표시

# ── Pretendard 폰트 (한국어 가독성) ─────────────────────────────
var _font_regular: FontFile
var _font_bold: FontFile

func _load_fonts():
	_font_regular = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold    = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile
	if _font_regular:
		FontKit.attach_emoji_fallback(_font_regular)
	if _font_bold:
		FontKit.attach_emoji_fallback(_font_bold)

func _ready():
	_load_fonts()
	_init_systems()
	_build_ui()
	_connect_signals()
	# 경마 미니게임 오버레이 (최상단)
	racetrack = load("res://scenes/RaceTrack.gd").new()
	add_child(racetrack)
	racetrack.closed.connect(_on_racetrack_closed)
	# 홀덤 클럽 오버레이
	holdem_club = load("res://scenes/HoldemClub.gd").new()
	add_child(holdem_club)
	holdem_club.closed.connect(_on_holdem_closed)
	# 스캘핑 아케이드 오버레이
	scalping_game = load("res://scenes/ScalpingGame.gd").new()
	add_child(scalping_game)
	scalping_game.closed.connect(_on_scalping_closed)
	# 아르바이트 시프트 오버레이
	aruba_game = load("res://scenes/ArubaGame.gd").new()
	add_child(aruba_game)
	aruba_game.closed.connect(_on_aruba_closed)
	# 구직활동 미니게임 오버레이
	job_hunt_game = load("res://scenes/JobHuntMiniGame.gd").new()
	add_child(job_hunt_game)
	job_hunt_game.closed.connect(_on_job_hunt_closed)
	life_skills_game = null  # 미니게임 제거 — 절약·인맥·자기계발은 서사 직접 처리
	# 정선 카지노 바카라 오버레이
	baccarat_table = load("res://scenes/BaccaratTable.gd").new()
	add_child(baccarat_table)
	# 정선 카지노 블랙잭 오버레이
	blackjack_table = load("res://scenes/BlackjackTable.gd").new()
	add_child(blackjack_table)
	# 정선 카지노 슬롯머신 오버레이
	slot_machine_game = load("res://scenes/SlotMachineGame.gd").new()
	add_child(slot_machine_game)
	# 정선 카지노 룰렛 오버레이
	roulette_table = load("res://scenes/RouletteTable.gd").new()
	add_child(roulette_table)
	# 정선 카지노 빅휠 오버레이
	big_wheel_game = load("res://scenes/BigWheelGame.gd").new()
	add_child(big_wheel_game)
	# 정선 카지노 다이사이 오버레이
	dai_sai_table = load("res://scenes/DaiSaiTable.gd").new()
	add_child(dai_sai_table)
	# 정선 카지노 허브 — 모든 카지노 게임 진입점
	jeongseon_casino = load("res://scenes/JeongseonCasino.gd").new()
	jeongseon_casino.baccarat_table   = baccarat_table
	jeongseon_casino.blackjack_table  = blackjack_table
	jeongseon_casino.slot_machine_game = slot_machine_game
	jeongseon_casino.roulette_table   = roulette_table
	jeongseon_casino.big_wheel_game   = big_wheel_game
	jeongseon_casino.dai_sai_table    = dai_sai_table
	add_child(jeongseon_casino)
	jeongseon_casino.closed.connect(_on_jeongseon_casino_closed)
	if GameState.action_log.is_empty():
		GameState.new_game()
	investment_system.initialize()
	BGMPlayer.start()
	SceneTransition.fade_in()
	if not LocaleManager.language_changed.is_connected(_on_language_changed):
		LocaleManager.language_changed.connect(_on_language_changed)
	_refresh_all()
	_apply_moral_visuals(GameState.moral_tint_norm(), GameState.moral_stage(), true)
	# StoryMode에서 복귀한 경우: 달을 다시 시작하지 않고 이어진 스토리만 체크
	if GameState.returning_from_story:
		GameState.returning_from_story = false
		_continue_after_story()
	else:
		_begin_month()

## 언어 전환 시 대시보드 전체 다시 그림 (인게임 토글 대응)
func _on_language_changed(_lang: String) -> void:
	_refresh_all()

## UI 문자열 번역 헬퍼 — 현재 언어에 맞는 문자열 반환
func _tr(ko: String, en: String) -> String:
	return LocaleManager.ui(ko, en)

func _quote_ui(text: String) -> String:
	return "\"%s\"" % text if LocaleManager.is_english() else "「%s」" % text

func _loc_dict(data: Dictionary, key: String, fallback := "") -> String:
	var en_key := "%s_en" % key
	if LocaleManager.is_english() and data.has(en_key):
		return str(data.get(en_key, fallback))
	return str(data.get(key, fallback))

func _run_theme_display(theme_id: String) -> String:
	match theme_id:
		"자유런": return _tr("자유런", "Free Run")
		"투자런": return _tr("투자런", "Investment Run")
		"인맥런": return _tr("인맥런", "Network Run")
		"청렴런": return _tr("청렴런", "Clean Run")
		"성실런": return _tr("성실런", "Diligent Run")
	return theme_id

## StoryMode 복귀 후: 같은 턴에 이어질 스토리가 더 있으면 다시 StoryMode로,
## 없으면 이번 달 행동(AP) 화면으로 진입.
## 앰비언트 이벤트(_maybe_play_month_situation)는 여기서 부르지 않는다.
## 아크/마일스톤/프롤로그가 이미 재생된 달에 랜덤 이벤트가 추가로 뜨는 것을 방지.
func _continue_after_story():
	var arc_id = _next_arc_id()
	if arc_id != "":
		_go_story_mode([arc_id])
		return
	var ms_id = _next_milestone_id()
	if ms_id != "":
		_go_story_mode([ms_id])
		return
	# 더 없으면 바로 루틴 행동 화면
	current_event = {}
	TutorialOverlay.maybe_show("main_game", self)
	_render_event()

func _init_systems():
	investment_system = load("res://systems/InvestmentSystem.gd").new()
	job_system = load("res://systems/JobSystem.gd").new()
	relationship_system = load("res://systems/RelationshipSystem.gd").new()
	inventory_system = load("res://systems/InventorySystem.gd").new()
	add_child(investment_system)
	add_child(job_system)
	add_child(relationship_system)
	add_child(inventory_system)

func _connect_signals():
	GameState.stats_changed.connect(_refresh_all)
	GameState.game_over.connect(_show_ending)
	if not GameState.moral_tint_changed.is_connected(_on_moral_tint_changed):
		GameState.moral_tint_changed.connect(_on_moral_tint_changed)
	job_system.promoted.connect(_on_promoted)
	GameState.stat_threshold_crossed.connect(_on_stat_threshold_crossed)
	GameState.tendency_awakened.connect(_on_tendency_awakened)

func _on_moral_tint_changed(norm: float, stage: int) -> void:
	var previous_norm := _moral_norm
	var previous_stage := _moral_stage
	var was_initialized := _moral_visual_initialized
	_apply_moral_visuals(norm, stage)
	if not was_initialized:
		return
	var actual_delta := _moral_norm - previous_norm
	if GameState.turn <= 1 and _moral_stage == 0 and absf(_moral_norm) < 0.001:
		return
	if absf(actual_delta) < 0.001 and previous_stage == _moral_stage:
		return
	_play_moral_choice_echo(actual_delta, previous_stage, _moral_stage)

func _apply_moral_visuals(norm: float, stage: int, immediate: bool = false) -> void:
	_moral_norm = clampf(norm, -1.0, 1.0)
	_moral_stage = stage
	var target := _moral_overlay_color(_moral_norm, _moral_stage)
	if is_instance_valid(_moral_tint_overlay):
		if _moral_tint_tween and _moral_tint_tween.is_running():
			_moral_tint_tween.kill()
		if immediate:
			_moral_tint_overlay.color = target
		else:
			_moral_tint_tween = create_tween()
			_moral_tint_tween.tween_property(_moral_tint_overlay, "color", target, 0.9).set_trans(Tween.TRANS_SINE)
	_apply_moral_world_state(immediate)
	_apply_moral_surface_shader()
	_apply_moral_portrait_state()
	_apply_story_moral_clarity()
	_apply_moral_ui_palette()
	_apply_money_moral_glow()
	_moral_visual_initialized = true

func _moral_overlay_color(norm: float, stage: int) -> Color:
	if stage <= -2:
		return Color(0.00, 0.018, 0.018, 0.34)
	if stage == -1:
		return Color(0.01, 0.028, 0.030, 0.20)
	if stage >= 2:
		return Color(0.96, 1.00, 0.98, 0.105)
	if stage == 1:
		return Color(0.92, 0.98, 0.96, 0.060)
	var gray_alpha: float = 0.055 + absf(norm) * 0.025
	return Color(0.28, 0.28, 0.30, gray_alpha)

func _apply_moral_world_state(immediate: bool = false) -> void:
	if not is_instance_valid(_main_ui_root):
		return
	var black := clampf(-_moral_norm, 0.0, 1.0)
	var white := clampf(_moral_norm, 0.0, 1.0)
	var target_rotation := deg_to_rad(-0.20 * black)
	var target_position := Vector2(-3.0 * black, 2.0 * black)
	var target_modulate := Color(1.0 + white * 0.035 - black * 0.035, 1.0 + white * 0.035 - black * 0.055, 1.0 + white * 0.025 - black * 0.055, 1.0)
	_main_ui_root.pivot_offset = get_viewport_rect().size * 0.5
	if _moral_world_tween and _moral_world_tween.is_running():
		_moral_world_tween.kill()
	if immediate:
		_main_ui_root.rotation = target_rotation
		_main_ui_root.position = target_position
		_main_ui_root.modulate = target_modulate
		return
	_moral_world_tween = create_tween()
	_moral_world_tween.set_parallel(true)
	_moral_world_tween.tween_property(_main_ui_root, "rotation", target_rotation, 0.95).set_trans(Tween.TRANS_SINE)
	_moral_world_tween.tween_property(_main_ui_root, "position", target_position, 0.95).set_trans(Tween.TRANS_SINE)
	_moral_world_tween.tween_property(_main_ui_root, "modulate", target_modulate, 0.95).set_trans(Tween.TRANS_SINE)

func _apply_moral_surface_shader() -> void:
	if not is_instance_valid(_moral_surface_overlay) or not _moral_surface_material:
		return
	var black := clampf(-_moral_norm, 0.0, 1.0)
	var white := clampf(_moral_norm, 0.0, 1.0)
	_moral_surface_overlay.visible = black > 0.01 or white > 0.01
	_moral_surface_material.set_shader_parameter("black_intensity", black)
	_moral_surface_material.set_shader_parameter("white_intensity", white)
	_moral_surface_material.set_shader_parameter("print_screen", clampf(black * 0.045 - white * 0.010, 0.0, 0.055))
	_moral_surface_material.set_shader_parameter("seed", float(GameState.turn % 97) + absf(_moral_norm) * 10.0)
	if _moral_bg_material:
		# Black is numbness: the world loses color, edges close in, money remains sharp.
		# White is not a beige skin; it is perception returning, so real image color comes back.
		_moral_bg_material.set_shader_parameter("desaturation", clampf(0.82 + black * 0.18 - white * 0.46, 0.28, 1.0))
		_moral_bg_material.set_shader_parameter("brightness", clampf(0.88 - black * 0.30 + white * 0.22, 0.35, 1.25))
		_moral_bg_material.set_shader_parameter("contrast", clampf(0.92 - black * 0.10 + white * 0.18, 0.65, 1.25))
		_moral_bg_material.set_shader_parameter("tint_amount", clampf(black * 0.14 + white * 0.035, 0.0, 0.18))
		_moral_bg_material.set_shader_parameter("tint_color", Color("#020303").lerp(Color("#f7fbff"), white))
		_moral_bg_material.set_shader_parameter("grain_amount", clampf(0.018 + black * 0.026 - white * 0.014, 0.0, 0.08))
		_moral_bg_material.set_shader_parameter("ink_bleed", clampf(0.055 + black * 0.130 - white * 0.046, 0.0, 0.25))
		_moral_bg_material.set_shader_parameter("paper_fade", clampf(0.018 + white * 0.030, 0.0, 0.07))
		_moral_bg_material.set_shader_parameter("edge_burn", clampf(0.070 + black * 0.130 - white * 0.070, 0.0, 0.24))
		_moral_bg_material.set_shader_parameter("print_screen", clampf(0.010 + black * 0.026 - white * 0.009, 0.002, 0.052))
		_moral_bg_material.set_shader_parameter("tone_quantize", clampf(0.018 + black * 0.095 - white * 0.014, 0.0, 0.14))
		_moral_bg_material.set_shader_parameter("screen_scale", 620.0 + black * 80.0 - white * 40.0)
		_moral_bg_material.set_shader_parameter("seed", float(GameState.turn % 131) + absf(_moral_norm) * 19.0)

func _apply_story_moral_clarity() -> void:
	var black := clampf(-_moral_norm, 0.0, 1.0)
	var white := clampf(_moral_norm, 0.0, 1.0)
	var title_color := Color("#e8eaf0").lerp(Color("#c4d2ca"), black * 0.75).lerp(Color("#ffffff"), white * 0.85)
	var body_color := Color("#c8d0df").lerp(Color("#89948f"), black * 0.72).lerp(Color("#e9f0fb"), white * 0.85)
	if is_instance_valid(event_title):
		event_title.add_theme_color_override("font_color", title_color)
	if is_instance_valid(event_body):
		event_body.add_theme_color_override("default_color", body_color)

func _apply_moral_portrait_state() -> void:
	if not is_instance_valid(character_portrait):
		return
	var black := clampf(-_moral_norm, 0.0, 1.0)
	var white := clampf(_moral_norm, 0.0, 1.0)
	if _moral_portrait_material:
		# Portraits carry the moral weight more than buttons do: numbness drains faces,
		# conscience lets human color return without turning the UI into a morality meter.
		_moral_portrait_material.set_shader_parameter("desaturation", clampf(0.36 + black * 0.54 - white * 0.24, 0.08, 0.96))
		_moral_portrait_material.set_shader_parameter("brightness", clampf(0.98 - black * 0.26 + white * 0.10, 0.56, 1.18))
		_moral_portrait_material.set_shader_parameter("contrast", clampf(0.98 - black * 0.06 + white * 0.12, 0.70, 1.24))
		_moral_portrait_material.set_shader_parameter("tint_amount", clampf(black * 0.14 + white * 0.025, 0.0, 0.16))
		_moral_portrait_material.set_shader_parameter("tint_color", Color("#020303").lerp(Color("#f6fbff"), white))
		_moral_portrait_material.set_shader_parameter("grain_amount", clampf(0.004 + black * 0.026 - white * 0.004, 0.0, 0.055))
		_moral_portrait_material.set_shader_parameter("ink_bleed", clampf(0.010 + black * 0.120 - white * 0.008, 0.0, 0.18))
		_moral_portrait_material.set_shader_parameter("paper_fade", clampf(white * 0.022, 0.0, 0.05))
		_moral_portrait_material.set_shader_parameter("edge_burn", clampf(0.020 + black * 0.115 - white * 0.020, 0.0, 0.16))
		_moral_portrait_material.set_shader_parameter("print_screen", clampf(0.004 + black * 0.014 - white * 0.003, 0.0, 0.025))
		_moral_portrait_material.set_shader_parameter("tone_quantize", clampf(black * 0.045 - white * 0.010, 0.0, 0.075))
		_moral_portrait_material.set_shader_parameter("screen_scale", 700.0 + black * 90.0)
		_moral_portrait_material.set_shader_parameter("seed", float(GameState.turn % 149) + absf(_moral_norm) * 23.0)
	character_portrait.modulate = Color(1.0 + white * 0.035 - black * 0.045, 1.0 + white * 0.030 - black * 0.055, 1.0 + white * 0.020 - black * 0.060, 1.0)

func _moral_ui_palette() -> Dictionary:
	var black := clampf(-_moral_norm, 0.0, 1.0)
	var white := clampf(_moral_norm, 0.0, 1.0)
	var ui_black := black * 0.24
	var ui_white := white * 0.18
	return {
		"panel_bg": Color("#0d0d14").lerp(Color("#050807"), ui_black).lerp(Color("#11191f"), ui_white),
		"panel_border": Color("#1a1a28").lerp(Color("#132018"), ui_black).lerp(Color("#5f7c8b"), ui_white),
		"chip_bg": Color("#0f1018").lerp(Color("#050a08"), ui_black).lerp(Color("#101a21"), ui_white),
		"choice_bg": Color("#101018").lerp(Color("#060907"), ui_black).lerp(Color("#111b22"), ui_white),
		"choice_hover": Color("#171723").lerp(Color("#0a110d"), ui_black).lerp(Color("#172630"), ui_white),
		"disabled_bg": Color("#0a0a0f").lerp(Color("#040605"), ui_black).lerp(Color("#0b1115"), ui_white),
		"text": Color("#c8d0df").lerp(Color("#87918b"), ui_black).lerp(Color("#edf7ff"), ui_white),
		"dim": Color("#9aa4b8").lerp(Color("#5f6a63"), ui_black).lerp(Color("#b7cbd6"), ui_white),
		"brand": Color(COL_GOLD).lerp(Color("#9aa29d"), ui_black).lerp(Color("#f8fbff"), ui_white),
		"focus": Color(COL_GOLD_BRIGHT).lerp(Color("#6f7a73"), ui_black).lerp(Color("#f8fbff"), ui_white),
		"black": ui_black,
		"white": ui_white,
		"moral_black": black,
		"moral_white": white,
	}

func _apply_moral_ui_palette() -> void:
	_apply_moral_tree_styles(self, _moral_ui_palette())
	_apply_money_moral_glow()

func _apply_moral_tree_styles(node: Node, palette: Dictionary) -> void:
	if node is Control and node.has_meta("moral_role"):
		_apply_moral_control_style(node as Control, palette)
	for child in node.get_children():
		_apply_moral_tree_styles(child, palette)

func _apply_moral_control_style(control: Control, palette: Dictionary) -> void:
	var role := str(control.get_meta("moral_role"))
	var accent := _moral_gray_accent(Color(str(control.get_meta("moral_accent", "#8b929c"))), palette)
	match role:
		"panel":
			if control is PanelContainer:
				(control as PanelContainer).add_theme_stylebox_override("panel", _moral_box(palette["panel_bg"], palette["panel_border"], 6, 12, 10))
		"hud_chip":
			if control is PanelContainer:
				var border := accent.lerp(palette["panel_border"], float(palette["black"]) * 0.55).lerp(Color("#d8f4ff"), float(palette["white"]) * 0.55)
				(control as PanelContainer).add_theme_stylebox_override("panel", _moral_box(palette["chip_bg"], border, 6, 9, 6))
		"hud_icon":
			if control is TextureRect:
				(control as TextureRect).modulate = accent.lerp(Color("#8b9490"), float(palette["black"]) * 0.55).lerp(Color("#e7faff"), float(palette["white"]) * 0.65)
		"hud_text":
			if control is Label:
				(control as Label).add_theme_color_override("font_color", palette["text"])
		"brand_text":
			if control is Label:
				(control as Label).add_theme_color_override("font_color", palette["brand"])
		"choice_card":
			if control is Button:
				_apply_moral_button_box(control as Button, accent, palette, true)
		"choice_icon":
			if control is PanelContainer:
				var icon_bg := accent.lerp(palette["choice_bg"], 0.72)
				icon_bg.a = 0.58
				(control as PanelContainer).add_theme_stylebox_override("panel", _moral_box(icon_bg, accent.lerp(palette["focus"], float(palette["white"]) * 0.45), 6, 0, 0))
		"choice_title":
			if control is Label:
				(control as Label).add_theme_color_override("font_color", palette["text"])
		"choice_subtitle":
			if control is Label:
				(control as Label).add_theme_color_override("font_color", palette["dim"])
		"choice_badge":
			if control is PanelContainer:
				(control as PanelContainer).add_theme_stylebox_override("panel", _moral_box(palette["chip_bg"], palette["panel_border"], 5, 8, 4))
		"choice_badge_text":
			if control is Label:
				(control as Label).add_theme_color_override("font_color", palette["dim"])
		"choice_arrow":
			if control is Label:
				(control as Label).add_theme_color_override("font_color", accent.lerp(palette["focus"], float(palette["white"]) * 0.35))
		"separator_line":
			if control is ColorRect:
				var sep_col: Color = palette["panel_border"]
				sep_col.a = 0.72
				(control as ColorRect).color = sep_col
		"separator_text", "hint_text":
			if control is Label:
				(control as Label).add_theme_color_override("font_color", palette["dim"])
		"tabs":
			if control is TabContainer:
				var selected := _moral_box(palette["choice_bg"], palette["focus"], 5, 12, 8)
				selected.border_width_bottom = 2
				var unselected := _moral_box(palette["disabled_bg"], palette["panel_border"], 5, 12, 8)
				unselected.set_border_width_all(0)
				var panel_st := StyleBoxFlat.new()
				panel_st.bg_color = palette["panel_bg"]
				panel_st.set_border_width_all(0)
				var tabs := control as TabContainer
				tabs.add_theme_stylebox_override("tab_selected", selected)
				tabs.add_theme_stylebox_override("tab_unselected", unselected)
				tabs.add_theme_stylebox_override("panel", panel_st)
				tabs.add_theme_color_override("font_selected_color", palette["text"])
				tabs.add_theme_color_override("font_unselected_color", palette["dim"])
		"button", "small_button", "action_button":
			if control is Button:
				_apply_moral_button_box(control as Button, accent, palette, false)

func _moral_gray_accent(color: Color, palette: Dictionary, boost: float = 0.0) -> Color:
	var lum := clampf(color.r * 0.299 + color.g * 0.587 + color.b * 0.114 + boost, 0.0, 1.0)
	var gray := Color(lum, lum, lum, color.a)
	return gray.lerp(Color("#303438"), float(palette["black"]) * 0.58).lerp(Color("#dce8f0"), float(palette["white"]) * 0.72)

func _moral_signal_color(color: Color, keep_saturation: float = 0.18) -> Color:
	var lum := clampf(color.r * 0.299 + color.g * 0.587 + color.b * 0.114, 0.0, 1.0)
	var gray := Color(lum, lum, lum, color.a)
	var black := clampf(-_moral_norm, 0.0, 1.0)
	var white := clampf(_moral_norm, 0.0, 1.0)
	var sat := clampf(keep_saturation - black * 0.08 + white * 0.04, 0.08, 0.28)
	var out := gray.lerp(color, sat)
	out = out.lerp(Color(0.01, 0.012, 0.012, color.a), black * 0.18)
	out = out.lerp(Color(0.90, 0.96, 1.0, color.a), white * 0.10)
	out.a = color.a
	return out

func _moral_text_accent(color: Color, boost: float = 0.0) -> Color:
	var lum := clampf(color.r * 0.299 + color.g * 0.587 + color.b * 0.114, 0.0, 1.0)
	var level := clampf(0.58 + lum * 0.32 + boost, 0.62, 0.96)
	var out := Color(level, level, level, color.a)
	var black := clampf(-_moral_norm, 0.0, 1.0)
	var white := clampf(_moral_norm, 0.0, 1.0)
	out = out.lerp(Color("#9ca5a0"), black * 0.42)
	out = out.lerp(Color("#f8fbff"), white * 0.56)
	out.a = color.a
	return out

func _moral_hex(color: Color) -> String:
	return "#" + color.to_html(false)

func _moral_box(bg: Color, border: Color, radius: int, h_margin: int, v_margin: int, left_border: int = 0) -> StyleBoxFlat:
	var st := StyleBoxFlat.new()
	st.bg_color = bg
	st.border_color = border
	st.set_border_width_all(1)
	if left_border > 0:
		st.border_width_left = left_border
	st.set_corner_radius_all(radius)
	st.content_margin_left = h_margin
	st.content_margin_right = h_margin
	st.content_margin_top = v_margin
	st.content_margin_bottom = v_margin
	return st

func _apply_moral_button_box(button: Button, accent: Color, palette: Dictionary, is_choice: bool) -> void:
	var bg: Color = palette["choice_bg"] if is_choice else palette["chip_bg"]
	var hover: Color = palette["choice_hover"]
	var pressed: Color = bg.darkened(0.12)
	var border := accent.lerp(palette["panel_border"], 0.28).lerp(palette["focus"], float(palette["white"]) * 0.35)
	var left_border := 3 if is_choice else 1
	var normal := _moral_box(bg, border, 6 if is_choice else 5, 16 if not is_choice else 0, 10 if not is_choice else 0, left_border)
	var hover_st := normal.duplicate()
	hover_st.bg_color = hover
	hover_st.border_color = border.lightened(0.15)
	var pressed_st := normal.duplicate()
	pressed_st.bg_color = pressed
	var focus_st := normal.duplicate()
	focus_st.border_color = palette["focus"]
	focus_st.set_border_width_all(UI_FOCUS_BORDER)
	var disabled_st := normal.duplicate()
	disabled_st.bg_color = palette["disabled_bg"]
	disabled_st.border_color = palette["panel_border"]
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover_st)
	button.add_theme_stylebox_override("pressed", pressed_st)
	button.add_theme_stylebox_override("focus", focus_st)
	button.add_theme_stylebox_override("disabled", disabled_st)
	button.add_theme_color_override("font_color", palette["text"])

func _apply_money_moral_glow() -> void:
	var money_col := Color("#cdd3dc")
	var goal_col := Color("#9aa4b0")
	var shadow_col := Color(0, 0, 0, 0)
	var shadow_size := 0
	if _moral_stage <= -2:
		money_col = Color("#ffffff")
		goal_col = Color("#f7fbff")
		shadow_col = Color(0.88, 0.96, 1.0, 0.56)
		shadow_size = 8
	elif _moral_stage == -1:
		money_col = Color("#edf4f7")
		goal_col = Color("#dce6eb")
		shadow_col = Color(0.75, 0.84, 0.88, 0.30)
		shadow_size = 4
	elif _moral_stage >= 2:
		money_col = Color("#f9fbff")
		goal_col = Color("#e9f2f7")
		shadow_col = Color(0.75, 0.95, 1.0, 0.18)
		shadow_size = 3
	elif _moral_stage == 1:
		money_col = Color("#e3eef5")
		goal_col = Color("#cddce5")
	_apply_money_label_style(top_labels.get("money", null) as Label, money_col, shadow_col, shadow_size)
	_apply_money_label_style(_goal_money_lbl, goal_col, shadow_col, shadow_size)

func _apply_money_label_style(label: Label, color: Color, shadow_color: Color, shadow_size: int) -> void:
	if not is_instance_valid(label):
		return
	label.add_theme_color_override("font_color", color)
	if shadow_size > 0:
		label.add_theme_color_override("font_shadow_color", shadow_color)
		label.add_theme_constant_override("shadow_outline_size", shadow_size)
		label.add_theme_constant_override("shadow_offset_x", 0)
		label.add_theme_constant_override("shadow_offset_y", 0)
	else:
		label.remove_theme_color_override("font_shadow_color")
		label.remove_theme_constant_override("shadow_outline_size")
		label.remove_theme_constant_override("shadow_offset_x")
		label.remove_theme_constant_override("shadow_offset_y")

func _play_moral_choice_echo(delta_norm: float, previous_stage: int, new_stage: int) -> void:
	# MORAL_TINT는 점수 표시가 아니라 "방금 선택 때문에 세계를 보는 렌즈가 변했다"는 체감이어야 한다.
	# 그래서 숫자/문구를 추가하지 않고, 색·표면·돈 HUD만 짧게 반응시킨다.
	var toward_black := delta_norm < 0.0 or new_stage < previous_stage
	var stage_crossed := previous_stage != new_stage
	var strength := clampf(absf(delta_norm) * 5.5, 0.08, 0.38)
	if stage_crossed:
		strength = maxf(strength, 0.30)
	if toward_black:
		_screen_flash(Color("#010202"), 0.10 + strength * 0.24, 0.42 + strength * 0.22)
		_pulse_moral_money_echo(strength)
	else:
		_screen_flash(Color("#f4fbff"), 0.05 + strength * 0.10, 0.34 + strength * 0.16)
		_pulse_moral_clarity_echo(strength)
	_pulse_moral_surface_echo(toward_black, strength)

func _pulse_moral_money_echo(strength: float) -> void:
	var scale_to := 1.035 + strength * 0.18
	var duration := 0.32 + strength * 0.28
	_pulse_node(top_labels.get("money", null), scale_to, duration)
	_pulse_node(_goal_money_lbl, 1.02 + strength * 0.12, duration)

func _pulse_moral_clarity_echo(strength: float) -> void:
	var duration := 0.30 + strength * 0.18
	_pulse_node(event_title, 1.015 + strength * 0.08, duration)
	if is_instance_valid(event_body):
		var base := event_body.modulate
		var tw := create_tween()
		tw.tween_property(event_body, "modulate", base.lerp(Color("#f7fbff"), 0.20 + strength * 0.24), duration * 0.42)
		tw.tween_property(event_body, "modulate", base, duration * 0.58)

func _pulse_moral_surface_echo(toward_black: bool, strength: float) -> void:
	if not is_instance_valid(_moral_surface_overlay) or not _moral_surface_material:
		return
	if _moral_echo_tween and _moral_echo_tween.is_running():
		_moral_echo_tween.kill()
		_apply_moral_surface_shader()
	var base_black := clampf(-_moral_norm, 0.0, 1.0)
	var base_white := clampf(_moral_norm, 0.0, 1.0)
	var peak_black := base_black
	var peak_white := base_white
	if toward_black:
		peak_black = clampf(base_black + 0.18 + strength * 0.55, 0.0, 1.0)
	else:
		peak_white = clampf(base_white + 0.12 + strength * 0.40, 0.0, 1.0)
	_moral_surface_overlay.visible = true
	_moral_echo_tween = create_tween()
	_moral_echo_tween.set_parallel(false)
	if toward_black:
		_moral_echo_tween.tween_method(
			func(v: float): _moral_surface_material.set_shader_parameter("black_intensity", v),
			base_black, peak_black, 0.09
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_moral_echo_tween.tween_method(
			func(v: float): _moral_surface_material.set_shader_parameter("black_intensity", v),
			peak_black, base_black, 0.42 + strength * 0.18
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		_moral_echo_tween.tween_method(
			func(v: float): _moral_surface_material.set_shader_parameter("white_intensity", v),
			base_white, peak_white, 0.10
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_moral_echo_tween.tween_method(
			func(v: float): _moral_surface_material.set_shader_parameter("white_intensity", v),
			peak_white, base_white, 0.36 + strength * 0.16
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_moral_echo_tween.tween_callback(func():
		_apply_moral_surface_shader()
		_moral_echo_tween = null
	)

func _build_ui():
	# ── 1. 최하단: 무채색 라디얼 그라디언트 배경 ──
	# MORAL_TINT의 중심축이 회색/흰색/검정이므로 기본 바닥부터 채도를 낮춘다.
	var bg_grad := Gradient.new()
	bg_grad.set_color(0, Color("#111316"))   # 중앙 — 차가운 흑회색
	bg_grad.set_color(1, Color("#050607"))   # 가장자리 — 거의 검정
	var bg_tex := GradientTexture2D.new()
	bg_tex.gradient = bg_grad
	bg_tex.fill = GradientTexture2D.FILL_RADIAL
	bg_tex.fill_from = Vector2(0.5, 0.40)
	bg_tex.fill_to = Vector2(1.05, 1.05)
	bg_tex.width = 256
	bg_tex.height = 160
	var bg = TextureRect.new()
	bg.texture = bg_tex
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# ── 2. 전체화면 배경 이미지 (이벤트별로 전환됨) ──
	event_bg = TextureRect.new()
	event_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	event_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	event_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	event_bg.modulate = Color(1, 1, 1, 0.0)   # 크로스페이드가 페이드인 처리
	var bg_grade_shader = load("res://assets/shaders/background_grade.gdshader")
	if bg_grade_shader:
		_moral_bg_material = ShaderMaterial.new()
		_moral_bg_material.shader = bg_grade_shader
		_moral_bg_material.set_shader_parameter("desaturation", 0.82)
		_moral_bg_material.set_shader_parameter("brightness", 0.88)
		_moral_bg_material.set_shader_parameter("contrast", 0.92)
		_moral_bg_material.set_shader_parameter("tint_color", Color("#020303"))
		_moral_bg_material.set_shader_parameter("tint_amount", 0.0)
		_moral_bg_material.set_shader_parameter("grain_amount", 0.018)
		_moral_bg_material.set_shader_parameter("ink_bleed", 0.055)
		_moral_bg_material.set_shader_parameter("paper_fade", 0.018)
		_moral_bg_material.set_shader_parameter("edge_burn", 0.070)
		_moral_bg_material.set_shader_parameter("print_screen", 0.010)
		_moral_bg_material.set_shader_parameter("tone_quantize", 0.018)
		_moral_bg_material.set_shader_parameter("screen_scale", 620.0)
		_moral_bg_material.set_shader_parameter("seed", 0.0)
		event_bg.material = _moral_bg_material
	event_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(event_bg)

	# ── 3. 어두운 오버레이 ──
	var dark_overlay = ColorRect.new()
	dark_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	dark_overlay.color = Color(0.022, 0.024, 0.028, 0.74)
	dark_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dark_overlay)

	# 시간대 앰비언트 틴트 (event_bg와 dark_overlay 사이)
	_ambient_overlay = ColorRect.new()
	_ambient_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ambient_overlay.color = Color(1.0, 1.0, 1.0, 0.0)
	_ambient_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_ambient_overlay)

	# 이벤트 카테고리 틴트 (Balatro 배경색 전환과 같은 역할 — 서브리미널 감정 신호)
	_category_tint = ColorRect.new()
	_category_tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	_category_tint.color = Color(0.0, 0.0, 0.0, 0.0)
	_category_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_category_tint)

	# MORAL_TINT 전역 필터. 숫자/게이지를 노출하지 않고 배경의 온도와 채도로만
	# 플레이어가 선택의 누적 방향을 느끼게 한다.
	_moral_tint_overlay = ColorRect.new()
	_moral_tint_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_moral_tint_overlay.color = Color(0.35, 0.35, 0.38, 0.025)
	_moral_tint_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_moral_tint_overlay)

	# ── 4. 메인 레이아웃 ──
	var root = VBoxContainer.new()
	_main_ui_root = root
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	add_child(root)

	_build_top_bar(root)
	_build_goal_bar(root)

	var main = HBoxContainer.new()
	main.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_theme_constant_override("separation", 0)
	root.add_child(main)

	_build_portrait_panel(main)
	_build_story_panel(main)

	_build_bottom_bar(root)

	# ── 5. 우측 슬라이드 정보 패널 (기본 숨김) ──
	_build_info_panel()

	_build_vignette_layer()
	_build_moral_surface_layer()
	_build_ink_transition_layer()
	_build_feedback_layer()
	_build_modal()
	_build_toast_layer()

func _build_moral_surface_layer():
	_moral_surface_overlay = ColorRect.new()
	_moral_surface_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_moral_surface_overlay.color = Color(1, 1, 1, 1)
	_moral_surface_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_moral_surface_overlay.visible = false
	var shader_res = load("res://assets/shaders/moral_surface.gdshader")
	if shader_res:
		_moral_surface_material = ShaderMaterial.new()
		_moral_surface_material.shader = shader_res
		_moral_surface_material.set_shader_parameter("black_intensity", 0.0)
		_moral_surface_material.set_shader_parameter("white_intensity", 0.0)
		_moral_surface_material.set_shader_parameter("print_screen", 0.0)
		_moral_surface_overlay.material = _moral_surface_material
	add_child(_moral_surface_overlay)

func _build_ink_transition_layer() -> void:
	_ink_transition_layer = Control.new()
	_ink_transition_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ink_transition_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ink_transition_layer.visible = false
	_ink_transition_layer.z_index = 86
	_ink_transition_layer.draw.connect(_draw_ink_transition)
	add_child(_ink_transition_layer)

func _play_ink_transition(kind: String = "neutral", strength: float = 1.0) -> void:
	if not is_instance_valid(_ink_transition_layer) or not is_inside_tree():
		return
	if _minigame_overlay_active:
		return
	if kind == "ap":
		return
	if _ink_transition_tween and _ink_transition_tween.is_running():
		_ink_transition_tween.kill()
	_ink_transition_kind = kind
	_ink_transition_progress = 0.0
	_ink_transition_layer.visible = true
	_ink_transition_layer.queue_redraw()
	var duration := clampf(0.16 + strength * 0.045, 0.14, 0.26)
	_ink_transition_tween = create_tween()
	_ink_transition_tween.tween_method(_set_ink_transition_progress, 0.0, 1.0, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_ink_transition_tween.tween_callback(func():
		_ink_transition_progress = 0.0
		if is_instance_valid(_ink_transition_layer):
			_ink_transition_layer.visible = false
			_ink_transition_layer.queue_redraw()
		_ink_transition_tween = null
	)

func _set_ink_transition_progress(value: float) -> void:
	_ink_transition_progress = clampf(value, 0.0, 1.0)
	if is_instance_valid(_ink_transition_layer):
		_ink_transition_layer.queue_redraw()

func _set_internal_transition_progress_for_qa(value: float, kind: String = "event") -> void:
	_ink_transition_kind = kind
	_ink_transition_progress = clampf(value, 0.0, 1.0)
	if is_instance_valid(_ink_transition_layer):
		_ink_transition_layer.visible = _ink_transition_progress > 0.01
		_ink_transition_layer.queue_redraw()

func _draw_ink_transition() -> void:
	if not is_instance_valid(_ink_transition_layer) or _ink_transition_progress <= 0.01:
		return
	var size := _ink_transition_layer.size
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var pulse := sin(_ink_transition_progress * PI)
	var black := clampf(-_moral_norm, 0.0, 1.0)
	var white := clampf(_moral_norm, 0.0, 1.0)
	var base := Color("#090a0d")
	if _ink_transition_kind == "result":
		base = Color("#0d0d10")
	elif _ink_transition_kind == "ap":
		base = Color("#111316")
	elif _ink_transition_kind == "moral":
		base = Color("#020303").lerp(Color("#f2f7ff"), white)
	base = base.lerp(Color("#020303"), black * 0.55).lerp(Color("#eef6ff"), white * 0.32)
	_ink_transition_layer.draw_rect(Rect2(Vector2.ZERO, size), Color(base.r, base.g, base.b, pulse * (0.045 + black * 0.055 + white * 0.025)), true)

	if black > 0.01:
		var burn := Color("#000000", pulse * (0.045 + black * 0.075))
		_ink_transition_layer.draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, 10.0 + black * 12.0)), burn, true)
		_ink_transition_layer.draw_rect(Rect2(Vector2(0.0, size.y - 10.0 - black * 12.0), Vector2(size.x, 10.0 + black * 12.0)), burn, true)
	if white > 0.01:
		_ink_transition_layer.draw_rect(Rect2(Vector2.ZERO, size), Color("#ffffff", pulse * white * 0.018), true)

func _build_vignette_layer():
	_vignette_rect = ColorRect.new()
	_vignette_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_vignette_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vignette_rect.z_index = 80
	_vignette_rect.visible = false
	var vshader_res = load("res://assets/shaders/vignette.gdshader")
	if vshader_res:
		var mat := ShaderMaterial.new()
		mat.shader = vshader_res
		_vignette_rect.material = mat
	add_child(_vignette_rect)

func _update_vignette():
	if not is_instance_valid(_vignette_rect) or not (_vignette_rect.material is ShaderMaterial):
		return
	var mat := _vignette_rect.material as ShaderMaterial
	var show_mental_edge: bool = GameState.mental <= 45
	var show_crisis_edge: bool = GameState.health <= 25 or GameState.mental <= 15
	_vignette_rect.visible = show_mental_edge or show_crisis_edge
	if not _vignette_rect.visible:
		mat.set_shader_parameter("stress_norm", 0.0)
		mat.set_shader_parameter("mental_norm", 1.0)
		return
	# 정신력 낮을수록 어두운(파란) 가장자리 강해짐 (70 이하부터)
	var m_norm := clampf(float(GameState.mental) / 70.0, 0.0, 1.0)
	# 빨간 가장자리 = 진짜 위급 상태 전용. 일반 피로/긴장에는 켜지지 않는다.
	var health_danger := clampf((25.0 - float(GameState.health)) / 25.0, 0.0, 1.0)
	var mental_danger := clampf((15.0 - float(GameState.mental)) / 15.0, 0.0, 1.0)
	var s_norm := maxf(health_danger, mental_danger)
	mat.set_shader_parameter("stress_norm", s_norm)
	mat.set_shader_parameter("mental_norm", m_norm)

func _update_ambient_tint():
	if not is_instance_valid(_ambient_overlay):
		return
	# turn%4: 0=밤, 1=아침, 2=낮, 3=저녁
	var phase: int = GameState.turn % 4
	var target: Color
	match phase:
		0: target = Color(0.58, 0.64, 0.74, 0.065)  # 밤 — 차가운 회청
		1: target = Color(0.88, 0.90, 0.88, 0.045)  # 아침 — 창백한 회백
		2: target = Color(1.00, 1.00, 1.00, 0.00)   # 낮 — 중립 (효과 없음)
		3: target = Color(0.72, 0.68, 0.62, 0.050)  # 저녁 — 낮은 채도의 먼지빛
	target = _moral_signal_color(target, 0.10)
	var tw := create_tween()
	tw.tween_property(_ambient_overlay, "color", target, 1.5).set_trans(Tween.TRANS_SINE)

## 이벤트 카테고리에 따라 전체 화면에 서브리미널 색조 적용 (Balatro 배경 전환 아이디어)
## 명시적 UI 없이 분위기로 카테고리를 전달 — alpha 매우 낮게 유지해야 함
func _apply_category_tint(category: String) -> void:
	if not is_instance_valid(_category_tint):
		return
	var target: Color
	match category:
		"disasters":
			target = Color(0.70, 0.05, 0.05, 0.045) # 빨강 — 재앙 전용, 낮은 알파
		"health":
			target = Color(0.70, 0.28, 0.05, 0.035) # 앰버 — 건강 이슈, 위기 비네팅과 분리
		"gambling":
			target = Color(0.70, 0.50, 0.00, 0.035) # 도박 — 낮은 황색 긴장
		"investment", "finance":
			target = Color(0.00, 0.50, 0.30, 0.035) # 투자 — 낮은 녹색 신호
		"social", "relationship", "romance":
			target = Color(0.40, 0.10, 0.60, 0.035) # 관계 — 낮은 보라 신호
		"family":
			target = Color(0.50, 0.30, 0.10, 0.030) # 가족 — 낮은 온기
		"politics":
			target = Color(0.10, 0.10, 0.50, 0.040) # 정치 — 낮은 청색
		"comedy":
			target = Color(0.50, 0.50, 0.00, 0.040) # 코미디 — 낮은 옐로
		_:
			target = Color(0.0, 0.0, 0.0, 0.0)      # 중립
	target = _moral_signal_color(target, 0.16)
	var tw := create_tween()
	tw.tween_property(_category_tint, "color", target, 0.5).set_trans(Tween.TRANS_SINE)

func _clear_category_tint(immediate: bool = false) -> void:
	if not is_instance_valid(_category_tint):
		return
	if immediate:
		_category_tint.color = Color(0.0, 0.0, 0.0, 0.0)
		return
	var tw := create_tween()
	tw.tween_property(_category_tint, "color", Color(0.0, 0.0, 0.0, 0.0), 0.6).set_trans(Tween.TRANS_SINE)

func _build_feedback_layer():
	_feedback_flash = ColorRect.new()
	_feedback_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_feedback_flash.color = Color(1, 1, 1, 1)
	_feedback_flash.modulate = Color(1, 1, 1, 0.0)
	_feedback_flash.visible = false
	_feedback_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_feedback_flash.z_index = 90
	add_child(_feedback_flash)

func _clear_feedback_flash() -> void:
	if not is_instance_valid(_feedback_flash):
		return
	if _feedback_flash_tween and _feedback_flash_tween.is_running():
		_feedback_flash_tween.kill()
	_feedback_flash_tween = null
	_feedback_flash.modulate = Color(1, 1, 1, 0.0)
	_feedback_flash.visible = false

func _build_top_bar(parent):
	var panel = _panel("#0d0d14", "#1a1a28")
	panel.custom_minimum_size = Vector2(0, 58)
	parent.add_child(panel)
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 6)
	panel.add_child(row)

	var title = _label(_tr("강남드림", "Gangnam Dream"), 18, COL_GOLD)
	title.set_meta("moral_role", "brand_text")
	title.custom_minimum_size = Vector2(132, 0)
	title.clip_text = false
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if _font_bold:
		title.add_theme_font_override("font", _font_bold)
	row.add_child(title)

	var date_lbl = _hud_chip(row, "", "#8892a4", 108, false)
	top_labels["date"] = date_lbl

	var ap_lbl = _hud_chip(row, "ap", "#b9bec7", 74, false)
	top_labels["ap"] = ap_lbl

	# ── 바이탈 HUD: 건강 / 정신 ──────────────────
	var vitals_row = HBoxContainer.new()
	vitals_row.add_theme_constant_override("separation", 6)
	row.add_child(vitals_row)

	var hp_lbl = _hud_chip(vitals_row, "health", "#aab2bc", 78, false)
	top_labels["vital_health"] = hp_lbl

	var mp_lbl = _hud_chip(vitals_row, "mental", "#9aa3ad", 78, false)
	top_labels["vital_mental"] = mp_lbl

	var money_lbl = _hud_chip(row, "money", "#d9dee6", 210, false)
	top_labels["money"] = money_lbl

	var info_btn = _small_button(_tr("정보", "Info"), "#1e2a3a")
	info_btn.custom_minimum_size = Vector2(58, 40)
	info_btn.add_theme_font_size_override("font_size", 14)
	info_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	info_btn.pressed.connect(_toggle_info_panel)
	row.add_child(info_btn)

	var save_btn = _small_button(_tr("저장", "Save"), "#1e2a3a")
	save_btn.custom_minimum_size = Vector2(58, 40)
	save_btn.add_theme_font_size_override("font_size", 14)
	save_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	save_btn.pressed.connect(Callable(self, "_on_save_pressed"))
	row.add_child(save_btn)

	var menu_btn = _small_button("≡", "#1e2a3a")
	menu_btn.custom_minimum_size = Vector2(42, 40)
	menu_btn.add_theme_font_size_override("font_size", 14)
	menu_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	menu_btn.pressed.connect(_open_system_menu)
	row.add_child(menu_btn)

	next_button = _button(_tr("다음 주 ›", "Next Week ›"), "#1a3a5a")
	next_button.custom_minimum_size = Vector2(96, 40)
	next_button.add_theme_font_size_override("font_size", 14)
	next_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	next_button.pressed.connect(_on_next_month)
	row.add_child(next_button)

	shop_button = _small_button(_tr("상점", "Shop"), "#173329")
	shop_button.custom_minimum_size = Vector2(56, 40)
	shop_button.add_theme_font_size_override("font_size", 14)
	shop_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	shop_button.pressed.connect(_open_shop)
	# 상점 버튼 비활성화 — 아이템 시스템은 서사 유물 방향으로 전환 예정 (DECISIONS.md 2026-06-24)

	var title_btn2 = _small_button(_tr("칭호", "Title"), "#1a2a1a")
	title_btn2.custom_minimum_size = Vector2(56, 40)
	title_btn2.add_theme_font_size_override("font_size", 14)
	title_btn2.size_flags_horizontal = Control.SIZE_SHRINK_END
	title_btn2.pressed.connect(_open_title_collection)
	row.add_child(title_btn2)

func _build_portrait_panel(parent):
	# 왼쪽 고정 초상화 패널
	var panel = _panel("#0d0d14", "#1a1a28")
	panel.custom_minimum_size = Vector2(224, 0)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	panel.add_child(vbox)

	# 초상화 — 고정 높이
	character_portrait = TextureRect.new()
	character_portrait.custom_minimum_size = Vector2(0, 310)
	character_portrait.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	character_portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	character_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	character_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	character_portrait.clip_contents = true
	var portrait_grade_shader = load("res://assets/shaders/background_grade.gdshader")
	if portrait_grade_shader:
		_moral_portrait_material = ShaderMaterial.new()
		_moral_portrait_material.shader = portrait_grade_shader
		_moral_portrait_material.set_shader_parameter("desaturation", 0.36)
		_moral_portrait_material.set_shader_parameter("brightness", 0.98)
		_moral_portrait_material.set_shader_parameter("contrast", 0.98)
		_moral_portrait_material.set_shader_parameter("tint_color", Color("#020303"))
		_moral_portrait_material.set_shader_parameter("tint_amount", 0.0)
		_moral_portrait_material.set_shader_parameter("grain_amount", 0.004)
		_moral_portrait_material.set_shader_parameter("ink_bleed", 0.010)
		_moral_portrait_material.set_shader_parameter("paper_fade", 0.0)
		_moral_portrait_material.set_shader_parameter("edge_burn", 0.020)
		_moral_portrait_material.set_shader_parameter("print_screen", 0.004)
		_moral_portrait_material.set_shader_parameter("tone_quantize", 0.0)
		_moral_portrait_material.set_shader_parameter("screen_scale", 700.0)
		_moral_portrait_material.set_shader_parameter("seed", 0.0)
		character_portrait.material = _moral_portrait_material
	if ResourceLoader.exists(PORTRAIT_NEUTRAL):
		character_portrait.texture = load(PORTRAIT_NEUTRAL)
	vbox.add_child(character_portrait)

	# 이름/직업 영역 — 초상화 아래 고정 높이
	var name_panel = PanelContainer.new()
	var name_style = StyleBoxFlat.new()
	name_style.bg_color = Color(0, 0, 0, 0.72)
	name_style.set_border_width_all(0)
	name_style.content_margin_top = 7
	name_style.content_margin_bottom = 7
	name_style.content_margin_left = 8
	name_style.content_margin_right = 8
	name_panel.add_theme_stylebox_override("panel", name_style)
	vbox.add_child(name_panel)

	player_name_label = _label("", 12, "#8892a4")
	player_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	player_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	player_name_label.clip_text = false
	name_panel.add_child(player_name_label)

	title_label = _label(_tr("서울 상경 초보", "Seoul Newcomer"), 11, COL_GOLD_DIM)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.clip_text = false
	vbox.add_child(title_label)

func _build_story_panel(parent):
	# 스토리 메인 영역 — 이벤트 제목/본문/선택지
	var container = Control.new()
	_story_container = container
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(container)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 20)
	container.add_child(margin)

	var layout = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 16)
	margin.add_child(layout)

	event_title = _label(_tr("이벤트 대기 중", "Awaiting Event"), 30, "#e8eaf0")
	event_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_title.clip_text = false
	layout.add_child(event_title)

	event_body = RichTextLabel.new()
	event_body.bbcode_enabled = true
	event_body.fit_content = true
	event_body.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	event_body.add_theme_font_size_override("normal_font_size", 18)
	event_body.add_theme_color_override("default_color", Color("#c8d0df"))
	layout.add_child(event_body)

	var choice_scroll = ScrollContainer.new()
	choice_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	choice_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	choice_scroll.vertical_scroll_mode   = ScrollContainer.SCROLL_MODE_AUTO
	layout.add_child(choice_scroll)

	choice_box = VBoxContainer.new()
	choice_box.add_theme_constant_override("separation", 10)
	choice_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	choice_scroll.add_child(choice_box)

func _build_info_panel():
	# ── 우측 슬라이드 통합 정보 패널 ──
	info_panel = PanelContainer.new()
	info_panel.set_meta("moral_role", "panel")
	info_panel.set_meta("moral_accent", "#303448")
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#090a0e", 0.985)
	style.border_color = Color("#323843")
	style.set_border_width_all(0)
	style.border_width_left = 2
	style.content_margin_left = 0
	style.content_margin_right = 0
	style.content_margin_top = 0
	style.content_margin_bottom = 0
	info_panel.add_theme_stylebox_override("panel", style)
	info_panel.set_anchor(SIDE_LEFT, 1.0)
	info_panel.set_anchor(SIDE_TOP, 0.0)
	info_panel.set_anchor(SIDE_RIGHT, 1.0)
	info_panel.set_anchor(SIDE_BOTTOM, 1.0)
	info_panel.offset_left = -UI_INFO_PANEL_WIDTH
	info_panel.offset_top = 48
	info_panel.offset_right = 0
	info_panel.offset_bottom = 0
	info_panel.visible = false
	add_child(info_panel)

	# ── VBox로 감싸서 헤더(닫기 버튼) + TabContainer 배치 ──
	var panel_vbox = VBoxContainer.new()
	panel_vbox.add_theme_constant_override("separation", 0)
	info_panel.add_child(panel_vbox)

	# 헤더: 패널 타이틀 + 닫기(X) 버튼
	var panel_header = HBoxContainer.new()
	panel_header.custom_minimum_size = Vector2(0, 46)
	var ph_style = StyleBoxFlat.new()
	ph_style.bg_color = Color("#0a0a12")
	ph_style.border_color = Color("#1e1e2a")
	ph_style.border_width_bottom = 1
	ph_style.content_margin_left = 14
	ph_style.content_margin_right = 8
	ph_style.content_margin_top = 7
	ph_style.content_margin_bottom = 7
	panel_header.add_theme_stylebox_override("panel", ph_style)
	panel_vbox.add_child(panel_header)

	var panel_title = _label(_tr("정보 기록", "Info Deck"), 16, "#e8eaf0")
	panel_title.set_meta("moral_role", "brand_text")
	if _font_bold:
		panel_title.add_theme_font_override("font", _font_bold)
	panel_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_header.add_child(panel_title)

	_info_pad_hint_label = _label("", 11, "#7f8794")
	_info_pad_hint_label.visible = false
	_info_pad_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_info_pad_hint_label.size_flags_horizontal = Control.SIZE_SHRINK_END
	panel_header.add_child(_info_pad_hint_label)

	var panel_close = _small_button("X", "#2a2a3a")
	panel_close.custom_minimum_size = Vector2(42, 34)
	panel_close.size_flags_horizontal = Control.SIZE_SHRINK_END
	panel_close.pressed.connect(_toggle_info_panel)
	panel_header.add_child(panel_close)

	# ── TabContainer: 스탯 / 시황 / 관계 ──
	info_tabs = TabContainer.new()
	var tabs = info_tabs
	tabs.set_meta("moral_role", "tabs")
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var tab_sel = StyleBoxFlat.new()
	tab_sel.bg_color = Color("#16202a")
	tab_sel.border_color = Color("#d9e2ea")
	tab_sel.border_width_bottom = 2
	tab_sel.content_margin_left = 12
	tab_sel.content_margin_right = 12
	tab_sel.content_margin_top = 8
	tab_sel.content_margin_bottom = 8
	var tab_unsel = StyleBoxFlat.new()
	tab_unsel.bg_color = Color("#0a0d12")
	tab_unsel.border_color = Color("#252b35")
	tab_unsel.set_border_width_all(1)
	tab_unsel.content_margin_left = 12
	tab_unsel.content_margin_right = 12
	tab_unsel.content_margin_top = 8
	tab_unsel.content_margin_bottom = 8
	var tab_panel_style = StyleBoxFlat.new()
	tab_panel_style.bg_color = Color("#090a0f")
	tab_panel_style.set_border_width_all(0)
	tabs.add_theme_stylebox_override("tab_selected", tab_sel)
	tabs.add_theme_stylebox_override("tab_unselected", tab_unsel)
	tabs.add_theme_stylebox_override("panel", tab_panel_style)
	tabs.add_theme_color_override("font_selected_color", Color("#e8eaf0"))
	tabs.add_theme_color_override("font_unselected_color", Color("#5a6075"))
	tabs.add_theme_font_size_override("font_size", 14)
	tabs.tab_changed.connect(func(idx):
		GameState.flags["_last_info_tab"] = idx
		_refresh_info_panel_hint()
	)
	panel_vbox.add_child(tabs)

	# ── Tab 0: 📊 스탯 ──
	var stat_scroll = ScrollContainer.new()
	stat_scroll.name = _tr("스탯", "Stats")
	stat_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tabs.add_child(stat_scroll)
	var stat_box = VBoxContainer.new()
	stat_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stat_box.add_theme_constant_override("separation", 8)
	var stat_margin = MarginContainer.new()
	stat_margin.add_theme_constant_override("margin_left", 16)
	stat_margin.add_theme_constant_override("margin_right", 16)
	stat_margin.add_theme_constant_override("margin_top", 12)
	stat_margin.add_theme_constant_override("margin_bottom", 12)
	stat_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stat_margin.add_child(stat_box)
	stat_scroll.add_child(stat_margin)

	# ── 배경 표시 ──
	var bg_row = HBoxContainer.new()
	bg_row.add_theme_constant_override("separation", 6)
	stat_box.add_child(bg_row)
	var bg_lbl = _label(_tr("배경", "Origin"), 13, "#7a8496")
	bg_lbl.custom_minimum_size = Vector2(46, 0)
	bg_row.add_child(bg_lbl)
	var bg_map = {"지방_상경": _tr("지방 상경", "Came from the provinces"), "명문대_중퇴": _tr("명문대 중퇴", "Elite school dropout"), "금수저": _tr("금수저", "Born wealthy")}
	var bg_name = bg_map.get(GameState.player_background, GameState.player_background)
	var bg_val = _label(bg_name, 14, "#c8d0df")
	bg_val.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bg_row.add_child(bg_val)

	var sep_line = HSeparator.new()
	sep_line.modulate = Color("#2a2a3a")
	stat_box.add_child(sep_line)

	var player_hdr := _label(_tr("인물", "Profile"), 14, COL_GOLD)
	if _font_bold:
		player_hdr.add_theme_font_override("font", _font_bold)
	stat_box.add_child(player_hdr)
	for key in ["housing", "job", "health", "mental", "asset"]:
		var stat_row = HBoxContainer.new()
		stat_box.add_child(stat_row)
		var name_label = _label(_stat_name(key), 14, "#7a8496")
		name_label.custom_minimum_size = Vector2(92, 0)
		stat_row.add_child(name_label)
		var value = _label("", 14, "#e8eaf0")
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stat_labels[key] = value
		stat_row.add_child(value)

	var log_hdr := _label(_tr("기록", "Log"), 14, COL_GOLD)
	if _font_bold:
		log_hdr.add_theme_font_override("font", _font_bold)
	stat_box.add_child(log_hdr)
	log_box = RichTextLabel.new()
	log_box.bbcode_enabled = true
	log_box.fit_content = true
	log_box.add_theme_font_size_override("normal_font_size", 13)
	log_box.add_theme_color_override("default_color", Color("#5a6075"))
	stat_box.add_child(log_box)

	# ── Tab 1: 시황 ──
	var news_scroll = ScrollContainer.new()
	news_scroll.name = _tr("시황", "Market")
	news_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tabs.add_child(news_scroll)
	var news_outer = VBoxContainer.new()
	news_outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	news_outer.add_theme_constant_override("separation", 8)
	var news_margin = MarginContainer.new()
	news_margin.add_theme_constant_override("margin_left", 16)
	news_margin.add_theme_constant_override("margin_right", 16)
	news_margin.add_theme_constant_override("margin_top", 12)
	news_margin.add_theme_constant_override("margin_bottom", 12)
	news_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	news_margin.add_child(news_outer)
	news_scroll.add_child(news_margin)

	news_box = VBoxContainer.new()
	news_box.add_theme_constant_override("separation", 8)
	news_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	news_outer.add_child(news_box)

	ticker_rtl = RichTextLabel.new()
	ticker_rtl.bbcode_enabled = true
	ticker_rtl.fit_content = true
	ticker_rtl.scroll_active = false
	ticker_rtl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ticker_rtl.add_theme_font_size_override("normal_font_size", 13)
	ticker_rtl.add_theme_color_override("default_color", Color("#8892a4"))
	news_outer.add_child(ticker_rtl)

	# ── Tab 2: 관계 ──
	var social_scroll = ScrollContainer.new()
	social_scroll.name = _tr("관계", "Relations")
	social_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tabs.add_child(social_scroll)
	var social_outer = VBoxContainer.new()
	social_outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	social_outer.add_theme_constant_override("separation", 8)
	var social_margin = MarginContainer.new()
	social_margin.add_theme_constant_override("margin_left", 16)
	social_margin.add_theme_constant_override("margin_right", 16)
	social_margin.add_theme_constant_override("margin_top", 12)
	social_margin.add_theme_constant_override("margin_bottom", 12)
	social_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	social_margin.add_child(social_outer)
	social_scroll.add_child(social_margin)

	relationship_box = VBoxContainer.new()
	relationship_box.add_theme_constant_override("separation", 8)
	relationship_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	social_outer.add_child(relationship_box)

	# ── Tab 3: 소지품 ──
	var inv_scroll = ScrollContainer.new()
	inv_scroll.name = _tr("소지품", "Items")
	inv_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tabs.add_child(inv_scroll)
	var inv_margin = MarginContainer.new()
	inv_margin.add_theme_constant_override("margin_left", 16)
	inv_margin.add_theme_constant_override("margin_right", 16)
	inv_margin.add_theme_constant_override("margin_top", 12)
	inv_margin.add_theme_constant_override("margin_bottom", 12)
	inv_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inv_scroll.add_child(inv_margin)
	inventory_box = VBoxContainer.new()
	inventory_box.add_theme_constant_override("separation", 8)
	inventory_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inv_margin.add_child(inventory_box)

	# ── Tab 4: 스토리 (퀘스트 트래커) ──
	var arc_scroll := ScrollContainer.new()
	arc_scroll.name = _tr("스토리", "Story")
	arc_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tabs.add_child(arc_scroll)
	var arc_margin := MarginContainer.new()
	arc_margin.add_theme_constant_override("margin_left", 16)
	arc_margin.add_theme_constant_override("margin_right", 16)
	arc_margin.add_theme_constant_override("margin_top", 12)
	arc_margin.add_theme_constant_override("margin_bottom", 12)
	arc_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arc_scroll.add_child(arc_margin)
	arc_box = VBoxContainer.new()
	arc_box.add_theme_constant_override("separation", 8)
	arc_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arc_margin.add_child(arc_box)

func _toggle_info_panel():
	if info_panel:
		info_panel.visible = not info_panel.visible
		if info_panel.visible and info_tabs:
			var last = GameState.flags.get("_last_info_tab", 0)
			info_tabs.current_tab = clampi(last, 0, info_tabs.get_tab_count() - 1)
		_refresh_info_panel_hint()

func _refresh_info_panel_hint() -> void:
	if not is_instance_valid(_info_pad_hint_label):
		return
	if not is_instance_valid(info_panel) or not info_panel.visible or not ControllerHints.is_pad_active():
		_info_pad_hint_label.visible = false
		return
	_info_pad_hint_label.visible = true
	_info_pad_hint_label.text = _tr(
		"%s/%s 탭 · %s 뒤로",
		"%s/%s Tabs · %s Back"
	) % [ControllerHints.shoulder_l(), ControllerHints.shoulder_r(), ControllerHints.east()]

# ══════════════════════════════════════════════════════════════
# 목표 진행바 — 상단 바 아래, 30억 달성률 시각화
# ══════════════════════════════════════════════════════════════
func _build_goal_bar(parent: Control) -> void:
	var row_panel = PanelContainer.new()
	var row_st = StyleBoxFlat.new()
	row_st.bg_color = Color("#07070d")
	row_st.border_width_bottom = 1
	row_st.border_color = Color("#18182a")
	row_st.content_margin_left = 12
	row_st.content_margin_right = 12
	row_st.content_margin_top = 4
	row_st.content_margin_bottom = 4
	row_panel.add_theme_stylebox_override("panel", row_st)
	parent.add_child(row_panel)

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.custom_minimum_size = Vector2(0, 18)
	row_panel.add_child(row)

	_goal_money_lbl = _label(_tr("자산 50만", "Assets KRW 500K"), 11, "#9aa4b8")
	_goal_money_lbl.custom_minimum_size = Vector2(210, 0)
	row.add_child(_goal_money_lbl)

	var bar_wrap = PanelContainer.new()
	var bw_st = StyleBoxFlat.new()
	bw_st.bg_color = Color("#151520")
	bw_st.set_corner_radius_all(5)
	bw_st.content_margin_top = 0
	bw_st.content_margin_bottom = 0
	bw_st.content_margin_left = 0
	bw_st.content_margin_right = 0
	bar_wrap.add_theme_stylebox_override("panel", bw_st)
	bar_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar_wrap.custom_minimum_size = Vector2(0, 10)
	row.add_child(bar_wrap)

	_goal_bar = ProgressBar.new()
	_goal_bar.min_value = 0.0
	_goal_bar.max_value = 100.0
	_goal_bar.value = 0.0
	_goal_bar.show_percentage = false
	_goal_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_goal_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pb_bg = StyleBoxFlat.new()
	pb_bg.bg_color = Color(0, 0, 0, 0)  # transparent — bar_wrap provides bg
	var pb_fill = StyleBoxFlat.new()
	pb_fill.bg_color = Color("#3a8a5a")
	pb_fill.set_corner_radius_all(5)
	_goal_bar.add_theme_stylebox_override("background", pb_bg)
	_goal_bar.add_theme_stylebox_override("fill", pb_fill)
	bar_wrap.add_child(_goal_bar)

	_goal_pct_label = _label("0.00%", 11, "#5a6075")
	_goal_pct_label.custom_minimum_size = Vector2(56, 0)
	_goal_pct_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(_goal_pct_label)

	var goal_lbl = _label(_tr("목표 30억", "Goal KRW 3B"), 11, COL_GOLD_DIM)
	goal_lbl.tooltip_text = _tr("강남 입성 목표", "Gangnam means Seoul's status district.")
	goal_lbl.custom_minimum_size = Vector2(92, 0)
	goal_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(goal_lbl)

	_goal_time_lbl = _label("", 10, "#5a6a7a")
	_goal_time_lbl.custom_minimum_size = Vector2(68, 0)
	_goal_time_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(_goal_time_lbl)

func _refresh_goal_bar() -> void:
	if _goal_bar == null or _goal_pct_label == null:
		return
	const GOAL: float = 3_000_000_000.0
	var total: float = float(GameState.get_total_asset_value())
	var pct: float = clampf(total / GOAL * 100.0, 0.0, 100.0)
	if _goal_bar.value == 0.0:
		_goal_bar.value = pct  # 게임 시작 시 즉시
	else:
		var _gb_tw := create_tween()
		_gb_tw.tween_property(_goal_bar, "value", pct, 0.7) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# 진행률도 무채색 축으로만 변화한다. 색은 위급/도덕성 연출에 양보한다.
	var fill_color: Color
	if pct < 5.0:
		fill_color = Color("#42474f")
	elif pct < 20.0:
		fill_color = Color("#646b73")
	elif pct < 60.0:
		fill_color = Color("#8b929b")
	else:
		fill_color = Color("#c5ccd5")
	var fill_st = StyleBoxFlat.new()
	fill_st.bg_color = fill_color
	fill_st.set_corner_radius_all(5)
	_goal_bar.add_theme_stylebox_override("fill", fill_st)

	# 퍼센트 레이블
	var pct_str: String
	if pct < 0.01:
		pct_str = "%.4f%%" % pct
	elif pct < 1.0:
		pct_str = "%.2f%%" % pct
	elif pct < 10.0:
		pct_str = "%.1f%%" % pct
	else:
		pct_str = "%.0f%%" % pct
	_goal_pct_label.text = pct_str
	var years_left: int = max(0, 38 - int(GameState.age))
	if years_left == 0:
		_goal_pct_label.add_theme_color_override("font_color", Color("#ff4444"))
	elif years_left == 1:
		_goal_pct_label.add_theme_color_override("font_color", Color("#c5ccd5"))
	else:
		_goal_pct_label.remove_theme_color_override("font_color")

	# 자산 레이블은 최종 목표 대비로 고정한다.
	# 다음 마일스톤은 아래 주간 판단 카드에서 따로 보여줘야 첫 화면이 덜 산만하다.
	if _goal_money_lbl:
		_goal_money_lbl.text = "%s / %s" % [GameState.format_money(total), GameState.format_money(3_000_000_000.0)]

	# 남은 시간 레이블 (시간 압박 가시화)
	if _goal_time_lbl:
		var months_left: int = (38 - GameState.age) * 12 - GameState.month + 1
		months_left = max(0, months_left)
		var time_color: String
		if months_left <= 12:
			time_color = "#ff4444"
		elif months_left <= 24:
			time_color = "#c5ccd5"
		else:
			time_color = "#5a6a7a"
		_goal_time_lbl.text = _tr("%d개월", "%d mo") % months_left
		_goal_time_lbl.add_theme_color_override("font_color", Color(time_color))

# ══════════════════════════════════════════════════════════════
# 튜토리얼 — 첫 런, 첫 AP 화면 진입 시 1회 표시
# ══════════════════════════════════════════════════════════════
func _maybe_show_tutorial() -> void:
	if GameState.flags.get("tutorial_shown", false):
		return
	GameState.flags["tutorial_shown"] = true
	# TutorialOverlay가 이미 main_game 슬라이드를 보여줬다면 중복 팝업 생략
	if TutorialOverlay._seen.get("main_game", false):
		return
	_show_tutorial()

func _show_tutorial() -> void:
	_open_modal(_tr("강남드림 — 시작 안내", "Gangnam Dream — Getting Started"))
	if modal_panel:
		modal_panel.custom_minimum_size = Vector2(580, 430)
		modal_panel.offset_left = -290
		modal_panel.offset_right  = 290
		modal_panel.offset_top    = -215
		modal_panel.offset_bottom = 215
	if modal_scroll:
		modal_scroll.custom_minimum_size = Vector2(0, 300)

	var intro_lbl := _wrap_label(
	_tr("33세, 통장 50만 원. 5년 안에 자산 30억을 만들고 강남에 입성하세요.",
		"Age 33, KRW 500K in the bank. Build KRW 3B in assets within 5 years and make it to Gangnam, Seoul's status district."),
	14, "#d8deea")
	if _font_bold:
		intro_lbl.add_theme_font_override("font", _font_bold)
	modal_body.add_child(intro_lbl)
	modal_body.add_child(_tutorial_card("goal", _tr("목표", "Goal"), _tr("자산 30억. 시간은 60개월뿐입니다.", "KRW 3B in assets. Gangnam is the status symbol. You have only 60 months."), "#f0b429"))
	modal_body.add_child(_tutorial_card("ap", _tr("행동", "Actions"), _tr("매주 AP로 구직, 투자, 자기계발, 휴식, 미니게임을 선택합니다.", "Each week, spend AP on Job Hunt, Invest, Self-Dev, Rest, or mini-games."), "#5b9cf6"))
	modal_body.add_child(_tutorial_card("invest", _tr("방향", "Approach"), _tr("안정 루트는 느리지만 버팁니다. 속도 루트는 빠르지만 한 번에 무너질 수 있습니다.", "The steady route is slow but durable. The fast route is quick but can collapse in one blow."), "#00c896"))
	modal_body.add_child(_tutorial_card("health", _tr("위험", "Danger"), _tr("건강/정신력이 0이 되거나 빚이 -1억을 넘으면 끝납니다.", "It's over if Health/Mental hits 0, or if debt exceeds -KRW 100M."), "#ff6b6b"))
	modal_body.add_child(_wrap_label(
		_tr("첫 주 추천: 구직활동으로 수입 0원 상태를 먼저 벗어나세요.",
			"Week 1 tip: use Job Hunt to first escape having zero income."),
		13, "#c9a227"))

	# ── 확인 버튼 ──
	var sep = HSeparator.new()
	sep.modulate = Color("#2a2a3a")
	modal_body.add_child(sep)
	var confirm_btn: Button = _button(_tr("시작하기 ›", "Start ›"), "#0d2a1a")
	confirm_btn.add_theme_color_override("font_color", Color("#00c896"))
	var conf_st = StyleBoxFlat.new()
	conf_st.bg_color = Color("#0d2a1a")
	conf_st.border_color = Color("#00c896")
	conf_st.border_width_left = 3
	conf_st.set_corner_radius_all(4)
	conf_st.content_margin_left = 16; conf_st.content_margin_right = 16
	conf_st.content_margin_top = 10; conf_st.content_margin_bottom = 10
	confirm_btn.add_theme_stylebox_override("normal", conf_st)
	confirm_btn.pressed.connect(_close_modal)
	modal_body.add_child(confirm_btn)

func _goal_sep() -> HSeparator:
	var s = HSeparator.new()
	s.modulate = Color("#1e1e2e")
	return s

func _tutorial_card(icon_id: String, title: String, body: String, accent: String) -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#101018")
	st.border_color = Color(accent, 0.35)
	st.border_width_left = 3
	st.set_corner_radius_all(6)
	st.content_margin_left = 12
	st.content_margin_right = 12
	st.content_margin_top = 9
	st.content_margin_bottom = 9
	panel.add_theme_stylebox_override("panel", st)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(26, 26)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = _ui_icon_texture(icon_id)
	icon.modulate = Color(accent)
	row.add_child(icon)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 2)
	row.add_child(col)

	var title_lbl := _label(title, 14, "#e8eaf0")
	if _font_bold:
		title_lbl.add_theme_font_override("font", _font_bold)
	col.add_child(title_lbl)
	col.add_child(_wrap_label(body, 12, "#aab3c5"))
	return panel

func _build_bottom_bar(parent):
	pass  # 다음 달/상점/도감은 상단 바로 이동됨

func _build_modal():
	modal_layer = ColorRect.new()
	modal_layer.color = Color(0, 0, 0, 0.70)
	modal_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	modal_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_layer.visible = false
	add_child(modal_layer)

	modal_panel = _panel("#13131a", "#252535")
	modal_panel.custom_minimum_size = Vector2(760, 610)
	modal_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	# 명시적 anchor로 화면 정중앙 고정
	modal_panel.anchor_left   = 0.5
	modal_panel.anchor_right  = 0.5
	modal_panel.anchor_top    = 0.5
	modal_panel.anchor_bottom = 0.5
	modal_panel.offset_left   = -380
	modal_panel.offset_right  =  380
	modal_panel.offset_top    = -305
	modal_panel.offset_bottom =  305
	modal_layer.add_child(modal_panel)
	var panel = modal_panel

	var outer = VBoxContainer.new()
	outer.add_theme_constant_override("separation", 8)
	panel.add_child(outer)

	# Header row with title + close button
	var header = HBoxContainer.new()
	outer.add_child(header)
	modal_title_label = _label("", 24, "#e8eaf0")
	modal_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(modal_title_label)
	modal_pad_hint_label = _label("", 12, "#7f8794")
	modal_pad_hint_label.visible = false
	modal_pad_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	modal_pad_hint_label.size_flags_horizontal = Control.SIZE_SHRINK_END
	header.add_child(modal_pad_hint_label)
	var close_x = _small_button("✕", "#242433")
	close_x.custom_minimum_size = Vector2(44, 42)
	close_x.size_flags_horizontal = Control.SIZE_SHRINK_END
	close_x.pressed.connect(_close_modal)
	header.add_child(close_x)

	# Scrollable content area
	modal_scroll = ScrollContainer.new()
	modal_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	modal_scroll.custom_minimum_size = Vector2(0, 468)
	outer.add_child(modal_scroll)

	modal_body = VBoxContainer.new()
	modal_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	modal_body.add_theme_constant_override("separation", 10)
	modal_scroll.add_child(modal_body)

func _build_toast_layer():
	_toast_container = VBoxContainer.new()
	_toast_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_container.add_theme_constant_override("separation", 6)
	_toast_container.size_flags_horizontal = Control.SIZE_SHRINK_END
	_toast_container.set_anchor(SIDE_LEFT, 1.0)
	_toast_container.set_anchor(SIDE_TOP, 0.0)
	_toast_container.set_anchor(SIDE_RIGHT, 1.0)
	_toast_container.set_anchor(SIDE_BOTTOM, 1.0)
	_toast_container.offset_left  = -320
	_toast_container.offset_top   = 60
	_toast_container.offset_right = -8
	_toast_container.offset_bottom = -60
	add_child(_toast_container)

func _show_toast(message: String, color: Color = Color("#8892a4")):
	var toast = load("res://ui_components/NotificationToast.gd").new()
	_toast_container.add_child(toast)
	toast.show_message(_clean_surface_message(message), color)

func _clean_surface_message(message: String) -> String:
	var out := str(message)
	for token in [
		"🚨", "⚠️", "⚠", "💾", "💳", "🔓", "⚡", "🤝",
		"🏦", "🏠", "📖", "📚", "👔", "📈", "📉", "🛒",
		"✨", "💼", "🎉", "💰", "🏇", "🃏", "🎰", "🚀",
		"🎬", "🖊", "🌊", "🔭", "🏃", "🧘", "📊", "🎯",
		"✅", "💡", "📋", "🔒", "🏆", "😰", "📱", "💙",
		"🍺", "💎", "👨", "⭐", "💭", "🔎", "🆘", "🔥",
		"💸", "🎲",
	]:
		out = out.replace(token + " ", "")
		out = out.replace(token, "")
	return out.strip_edges()

func _clean_log_surface_text(value: Variant) -> String:
	var out := _clean_surface_message(str(value))
	out = out.replace("✓ ", "• ")
	out = out.replace("✓", "•")
	out = out.replace("  ", " ")
	return out.strip_edges()

func _escape_bbcode_text(value: Variant) -> String:
	return str(value).replace("[", "(").replace("]", ")")

func _begin_month():
	GameState.restore_ap()
	_animate_ap_refill()
	turn_action_log.clear()
	prev_prices = GameState.market_prices.duplicate()
	# ── 월초 전용: 뉴스·시장·크라이시스는 새 달 첫 주(week_of_month==1)에만 ──
	if GameState.week_of_month == 1:
		if GameState.turn > 4:  # 튜토리얼 1달(4주) 이후부터 크라이시스
			var crisis = _roll_monthly_crisis()
			if not crisis.is_empty():
				_apply_monthly_event(crisis)
		if GameState.news_log.is_empty() or GameState.turn > 1:
			var news = NewsManager.generate_monthly_news()
			var had_margin_call_before: bool = GameState.flags.get("margin_called_happened", false)
			investment_system.process_month(news)
			# 마진콜 발생 시 전체 화면 흔들림 + 빨간 플래시
			if not had_margin_call_before and GameState.flags.get("margin_called_happened", false):
				_full_screen_shake(14.0, 0.55)
				_screen_flash(Color("#d73a49"), 0.35, 0.55)
	# ── 스토리 이벤트 트리거 ─────────────────────────
	# 턴 1: 프롤로그 → StoryMode(비주얼노벨)로 재생 (1회만)
	if GameState.turn == 1 and not GameState.flags.get("prologue_done", false):
		GameState.flags["prologue_done"] = true
		_go_story_mode(["story_arrival"])
		return
	# 아크 이벤트 (인물 스토리) — 마일스톤보다 우선
	var arc_id = _next_arc_id()
	if arc_id != "":
		_go_story_mode([arc_id])
		return
	# 마일스톤 이벤트 (스토리) → StoryMode
	var ms_id = _next_milestone_id()
	if ms_id != "":
		_go_story_mode([ms_id])
		return
	# 드라마 모드 — 이번 달의 핵심 사건을 풀스크린 VN으로 재생.
	# (재생했으면 거기서 돌아온 뒤 루틴 행동 화면으로 이어진다)
	current_event = {}
	if _maybe_play_month_situation():
		return
	_render_ap_actions()

## 이번 턴의 '사건' 하나를 VN(StoryMode)으로 재생한다. 재생했으면 true.
## 드라마 모드: 매달의 핵심 사건은 풀스크린 VN으로. (앰비언트 이벤트를 1개 뽑아 재생)
func _maybe_play_month_situation() -> bool:
	# 턴 1은 프롤로그 직후 — 앰비언트 이벤트 없이 바로 AP 화면으로.
	if GameState.turn == 1:
		return false
	# 주의: MainGame은 StoryMode 다녀오면 재생성되므로 인스턴스 변수로는 추적 불가.
	# GameState(오토로드)에 '이번 턴 사건 재생함'을 기록해야 무한 루프를 막는다.
	if int(GameState.flags.get("month_event_turn", -1)) == GameState.turn:
		return false
	GameState.flags["month_event_turn"] = GameState.turn
	var sits: Array = EventManager.draw_situations(1)
	if sits.is_empty():
		return false
	var sit: Dictionary = sits[0]
	var sid: String = str(sit.get("id", ""))
	if sid.is_empty():
		return false
	# StoryMode는 apply_choice 경유라 쿨다운을 안 박으므로 여기서 박아 재추첨 방지
	EventManager.event_cooldowns[sid] = int(sit.get("cooldown", 6))
	_go_story_mode([sid])
	return true

## 스토리/아크 이벤트들을 StoryMode 화면으로 보낸다.
func _go_story_mode(event_ids: Array):
	GameState.pending_story_queue = event_ids
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	SceneTransition.go("res://scenes/StoryMode.tscn")

## 아크 이벤트 트리거 — 조건 맞으면 이벤트 ID를 반환 (없으면 "").
## 우선순위: 위에서부터. 한 턴에 하나만 발동. StoryMode로 재생됨.
## 설계: 초반(턴1-8)은 주인공 몰입, 중반(9-16) 멘토/조연, 후반(17+) 여주인공.
func _next_arc_id() -> String:
	var t = GameState.turn
	var f = GameState.flags

	# 랜덤 sangchul_meet이 arc보다 먼저 발동한 경우 arc 플래그 동기화
	if f.get("sangchul_met", false) and not f.get("arc_sangchul_met_seen", false):
		GameState.flags["arc_sangchul_met_seen"] = true

	# ══ 챕터 전환 카드 — 연도(나이) 넘어가는 첫 턴 ══════════
	# 챕터 1: 프롤로그 직후 1회
	if f.get("prologue_done", false) and not f.get("chapter_33_seen", false):
		return "chapter_card_33"
	var _age = GameState.age
	if _age == 34 and not f.get("chapter_34_seen", false):
		return "chapter_card_34"
	if _age == 35 and not f.get("chapter_35_seen", false):
		return "chapter_card_35"
	if _age == 36 and not f.get("chapter_36_seen", false):
		return "chapter_card_36"
	if _age == 37 and not f.get("chapter_37_seen", false):
		return "chapter_card_37"

	# ══ 연말 클로징 씬 — 각 연도의 마지막 밤 (5권 구조의 마침표) ══
	if t >= 44 and t <= 48 and not f.get("arc_year1_close_seen", false):
		return "arc_year1_close"
	if t >= 92 and t <= 96 and not f.get("arc_year2_close_seen", false):
		return "arc_year2_close"
	if t >= 140 and t <= 144 and not f.get("arc_year3_close_seen", false):
		return "arc_year3_close"
	if t >= 188 and t <= 192 and not f.get("arc_year4_close_seen", false):
		return "arc_year4_close"

	# ══ 고시원 탈출 — 이사한 첫 턴에 감정 장면 (어느 턴이든) ══
	if GameState.housing != "gosiwon" \
			and not f.get("arc_goshiwon_goodbye_seen", false):
		return "arc_goshiwon_goodbye"

	# ══ 그림자 이벤트 — N턴 후 과거 선택이 되돌아온다 ══════════
	var shadow_events = GameState.pop_ready_deferred_events()
	for sid in shadow_events:
		if not sid.is_empty():
			EventManager.trigger_event_by_id(sid)
			return ""  # 이번 턴 arc는 그림자가 가져간다


	# ══ 1구간: 주인공 몰입 (턴 1-8, 인물 없음) ══════════
	if t >= 2 and not f.get("arc_intro_meal_seen", false):
		return "arc_intro_01_meal"
	if t >= 3 and not f.get("arc_intro_dad_seen", false):
		return "arc_intro_02_dad_call"
	# ★ 첫 유혹 (턴 4) — 정석 vs 위험한 지름길. 결말까지 갈리는 큰 분기.
	if t >= 4 and not f.get("arc_temptation_seen", false):
		return "arc_temptation_01"
	if t >= 5 and not f.get("arc_intro_sns_seen", false):
		return "arc_intro_03_sns"
	# ★ 깊은 분기 시나리오 데모 — '강남 카페' (꼬리에 꼬리를 무는 선택)
	if t >= 6 and not f.get("cafe_scenario_seen", false):
		return "cafe_00"
	if t >= 7 and not f.get("arc_intro_hyunsu_seen", false):
		return "arc_intro_04_hyunsu"
	# ★ 챕터1 클로즈 (턴 8) — 첫 주의 모든 씬이 끝난 뒤 잠깐의 반성. 데모 종료 포인트.
	if t >= 8 and f.get("arc_intro_hyunsu_seen", false) \
			and not f.get("chapter1_closed", false):
		return "arc_chapter1_close"
	# ★ 카페의 장기 파장 (턴 13) — 턴 6 선택이 되돌아온다. 위쳐3식 장기 결과.
	if t >= 13 and not f.get("cafe_callback_seen", false):
		if f.get("cafe_stole_lead", false):
			return "cafe_cb_stole_00"
		if f.get("cafe_got_card_honest", false):
			return "cafe_cb_honest_00"
		if f.get("cafe_humiliated", false):
			return "cafe_cb_humiliated_00"
		# 세 플래그 모두 없으면 카페 씬을 안 본 것 — 재검사 방지
		GameState.flags["cafe_callback_seen"] = true
	# ★ 첫 유혹의 후폭풍/보상 (턴 8) — 선택에 따라 갈림
	if f.get("lent_account", false) and not f.get("arc_temptation_fallout_seen", false) and t >= 8:
		return "arc_temptation_fallout"
	if f.get("kept_clean_hands", false) and not f.get("arc_temptation_clean_seen", false) and t >= 8:
		return "arc_temptation_clean"
	# 불합격 메일 — 구직 2주차(t>=8), 아직 무직, 첫 탈락 경험
	if t >= 8 and GameState.current_job.is_empty() \
			and not f.get("arc_job_rejection_seen", false):
		return "arc_job_first_rejection"

	# ── 챕터1 루트·테마별 반응 (t>=8) — 프롤로그 선택이 씬을 만든다 ──
	if t >= 8 and f.get("route_invest", false) \
			and not f.get("arc_ch1_invest_chart_seen", false):
		return "arc_ch1_invest_first_chart"
	if t >= 8 and f.get("route_career", false) \
			and not f.get("arc_ch1_career_spec_seen", false):
		return "arc_ch1_career_first_spec"
	if t >= 8 and f.get("route_startup", false) \
			and not f.get("arc_ch1_startup_idea_seen", false):
		return "arc_ch1_startup_first_idea"
	if t >= 8 and f.get("theme_network_run", false) \
			and not f.get("arc_ch1_network_first_seen", false):
		return "arc_ch1_theme_network_first"
	if t >= 8 and f.get("theme_invest_run", false) \
			and not f.get("arc_ch1_invest_deep_seen", false):
		return "arc_ch1_theme_invest_deep"

	# ── 첫 정산 (턴 9) — 자산 구간이 장면을 고른다. 선택/AP의 결과가 화면으로. ──
	if t >= 9 and not f.get("arc_money_check_seen", false):
		var nav: float = GameState.get_total_asset_value()
		if nav < 1_000_000.0:
			return "arc_money_check_low"      # 마이너스~빠듯: 통장 충격
		elif nav < 30_000_000.0:
			return "arc_money_check_mid"       # 쌓이는 중: 첫 결실
		else:
			return "arc_money_check_high"      # 3천만+: 이게 되네 (자신감/경고)

	# ── 얇은 벽 — 고시원 새벽 3시 (턴 11, 고시원 거주 중에만) ──
	if t >= 11 and GameState.housing == "gosiwon" \
			and not f.get("arc_gosiwon_wall_seen", false):
		return "arc_gosiwon_wall"

	# ★ 신규 유저 안전망 (턴 10+) — 아직 무직이면 고시원 주인이 일자리를 소개한다.
	#   거절 가능. 창업/크리에이터 의도가 있으면 안 뜸.
	if t >= 10 and GameState.current_job.is_empty() \
			and not f.get("arc_rescue_job_seen", false) \
			and not f.get("startup_intent", false) \
			and not f.get("creator_started", false):
		return "arc_rescue_job"

	# ── 전문화 분기 이벤트 — 성향 자각 직후 1회 ──
	if f.get("pending_spec_career", false) and not f.get("pending_spec_career_done", false):
		return "arc_spec_career"
	if f.get("pending_spec_invest", false) and not f.get("pending_spec_invest_done", false):
		return "arc_spec_invest"
	if f.get("pending_spec_found", false) and not f.get("pending_spec_found_done", false):
		return "arc_spec_found"

	# ── 첫 출근 주 — 취업 후 첫 1개월 안에 (1회) ──
	if not GameState.current_job.is_empty() \
			and GameState.job_tenure <= 1 \
			and not f.get("arc_first_job_week_seen", false):
		return "arc_first_job_week"

	# ── 경마 멘토 보장 — gambling_tempted + 100만원 이상이면 t=12에 확정 등장 ──
	if t >= 12 and f.get("gambling_tempted", false) \
			and GameState.money >= 1_000_000 \
			and not f.get("racetrack_mentor_done", false):
		return "racetrack_mentor_meet"

	# ══ NG+ 전용 아크 — MetaProgression 조건 체크 (2구간 첫 만남 교체) ══
	var _mp = MetaProgression.meta
	# 임상철 첫 만남 교체 (NG+: 상철 진실 알고 시작)
	if t >= 10 and _mp.get("sangchul_truth_ever_known", false) \
			and not f.get("arc_sangchul_ng_seen", false) \
			and not f.get("arc_sangchul_met_seen", false):
		return "arc_sangchul_ng_meet"
	# 다은 첫 만남 교체 (NG+: 다은 엔딩 경험)
	if t >= 9 and _mp.get("daeun_ending_ever_seen", false) \
			and not f.get("arc_daeun_ng_seen", false) \
			and not f.get("arc_daeun_met", false):
		return "arc_daeun_ng_meet"
	# 아버지 첫 전화 교체 (NG+: 아버지 잃은 경험)
	if t >= 11 and _mp.get("father_passed_ever", false) \
			and not f.get("arc_father_ng_seen", false) \
			and not f.get("arc_father_01_seen", false):
		return "arc_father_ng_call"
	# 도박 중독 회귀 구원 서사 (NG+: 전생에서 중독 극복 경험)
	# 카지노 첫 입장 장면 교체 — 몸이 기억하는 공포
	if t >= 14 and _mp.get("beat_addiction_ever", false) \
			and f.get("arc_sangchul_met_seen", false) \
			and not f.get("gambling_tempted", false):
		return "ng_gambling_premonition"
	# 회복 멘토 — 전생에서 중독을 이긴 사람이 다음 사람의 손을 잡는다 (pay it forward)
	if t >= 20 and _mp.get("beat_addiction_ever", false) \
			and f.get("ng_gambling_refused", false) \
			and not f.get("ng_recovery_mentor_seen", false):
		return "ng_recovery_mentor_moment"
	# 회복 잔상 — 중독에 빠지지 않은 clean 런에서, 고시원 조용한 밤 씬
	if t >= 30 and _mp.get("beat_addiction_ever", false) \
			and f.get("ng_gambling_refused", false) \
			and not f.get("ng_recovery_maintained", false):
		return "ng_recovery_echo"
	# 규율 전이 — 끊은 사람의 인내심이 자산으로 옮겨가는 씬
	if t >= 34 and _mp.get("beat_addiction_ever", false) \
			and f.get("ng_recovery_mentor_seen", false) \
			and not f.get("ng_recovery_discipline_seen", false):
		return "ng_recovery_discipline"

	# ══ 2구간: 멘토/세계 확장 (턴 9-16) ════════════════
	if t >= 10 and not f.get("arc_sangchul_met_seen", false):
		return "arc_sangchul_01_meet"

	# ── 임상철 투자 길잡이 — 첫 만남 2주 후 (30억 경로 안내) ──
	if t >= 12 and f.get("arc_sangchul_met_seen", false) \
			and not f.get("arc_invest_guidance_seen", false):
		return "arc_invest_guidance"

	# ── 김다은 아크 — 편의점 단골, 사랑 vs 야망 (슬로우번) ──
	if t >= 9 and not f.get("arc_daeun_met", false):
		return "arc_daeun_01_meet"
	if t >= 15 and f.get("arc_daeun_met", false) \
			and GameState.get_cast_affinity("daeun") >= 8 \
			and not f.get("arc_daeun_regular_seen", false):
		return "arc_daeun_02_regular"
	if t >= 23 and f.get("arc_daeun_regular_seen", false) \
			and GameState.get_cast_affinity("daeun") >= 12 \
			and not f.get("arc_daeun_fork_seen", false):
		return "arc_daeun_03_fork"
	# ── 다은 결말 — 붙잡은 경우 ──
	if t >= 28 and f.get("daeun_chose_her", false) \
			and not f.get("arc_daeun_03b_seen", false) \
			and not f.get("arc_daeun_04_seen", false):
		return "arc_daeun_03b_date"
	if t >= 33 and f.get("daeun_chose_her", false) \
			and not f.get("arc_daeun_04_seen", false):
		return "arc_daeun_04_morning"
	if t >= 42 and f.get("daeun_together_path", false) \
			and not f.get("arc_daeun_04b_seen", false):
		return "arc_daeun_04b_future"
	# ── 다은 에필로그 — 보낸 경우 ──
	if t >= 40 and f.get("daeun_let_her_go", false) \
			and not f.get("arc_daeun_ghost_seen", false):
		return "arc_daeun_ghost"
	if t >= 47 and f.get("daeun_let_her_go", false) \
			and f.get("arc_daeun_ghost_seen", false) \
			and not f.get("arc_daeun_regret_seen", false):
		return "arc_daeun_regret_draft"
	# ── 다은 05 — 함께 가는 경로 (committed 이후 일상) ──
	if t >= 50 and f.get("daeun_close_bond", false) \
			and not f.get("arc_daeun_05_together_seen", false):
		return "arc_daeun_05_together"
	# ── 조기 연인 특별씬 '그 밤' — 사귄 뒤 관계가 무르익은 시점 (성숙 페이드아웃) ──
	if t >= 70 and f.get("daeun_romance_started", false) \
			and GameState.get_cast_affinity("daeun") >= 45 \
			and not f.get("arc_daeun_first_night_seen", false):
		return "arc_daeun_first_night"
	# ── 프로포즈 — 최고 호감의 연인에게 (결혼 진엔딩 게이트). Y4(t≥150)부터 열어
	#    헌신한 커플은 36세에 결혼하고 남은 기간을 신혼으로 — 마지막까지 미루는 '질질 끄는' 느낌 제거. ──
	if t >= 150 and f.get("daeun_romance_started", false) \
			and GameState.get_cast_affinity("daeun") >= 55 \
			and not f.get("arc_daeun_proposal_seen", false):
		return "arc_daeun_proposal"
	# ── 약혼-이후 국면 (결혼=끝까지 잃을 수 있는 것) ──
	# ① 우리 집 — 강남이 '내 등기'에서 '두 부모 모실 집'으로 재정의
	if t >= 155 and f.get("daeun_married", false) \
			and not f.get("arc_daeun_our_home_seen", false):
		return "arc_daeun_our_home"
	# ② 상견례 — 두 가난한 부모(아버지 생존 시만). father_passed면 스킵(유령 등장 방지).
	if t >= 168 and f.get("arc_daeun_our_home_seen", false) \
			and not f.get("father_passed", false) \
			and not f.get("arc_daeun_families_seen", false):
		return "arc_daeun_families_meet"
	# ③ 시험 — 아내를 서류로 쓰는 지름길. our_home 기반(상견례 스킵돼도 체인 유지).
	#    상철 신고/절연 후엔 안 뜸(그가 제안할 리 없음).
	if t >= 182 and f.get("arc_daeun_our_home_seen", false) \
			and not f.get("sangchul_reported", false) \
			and not f.get("sangchul_cut_ties", false) \
			and not f.get("arc_daeun_test_seen", false):
		return "arc_daeun_the_test"
	# ④ 최종 선택 — 돈이냐 배우자냐. 30억 미달+마감 임박에만(정직-부자는 스킵→진엔딩).
	if t >= 228 and f.get("daeun_married", false) \
			and not f.get("daeun_divorced", false) \
			and not f.get("arc_daeun_final_choice_seen", false) \
			and GameState.get_total_asset_value() >= 1_800_000_000.0 \
			and GameState.get_total_asset_value() < 3_000_000_000.0:
		return "arc_daeun_final_choice"
	# ── 다은 05 — 기다려달라 한 뒤 이별 ──
	if t >= 50 and f.get("daeun_deferred", false) \
			and not f.get("arc_daeun_05_breaking_seen", false):
		return "arc_daeun_05_breaking"
	# ── 다은 05 — 모르겠다 한 뒤 자연 소멸 ──
	if t >= 50 and f.get("daeun_uncertain", false) \
			and not f.get("arc_daeun_05_uncertain_seen", false):
		return "arc_daeun_05_uncertain"

	# ── 아버지 아크 — 병환과 화해 (런 전체에 걸쳐 진행) ──
	if t >= 11 and not f.get("arc_father_01_seen", false):
		return "arc_father_01_call"
	# ── 아버지 평범한 통화 — 두 이벤트 사이 고요한 장면 ──
	if t >= 15 and t <= 19 \
			and f.get("arc_father_01_seen", false) \
			and not f.get("arc_father_quiet_call_seen", false):
		return "arc_father_quiet_call"
	if t >= 21 and f.get("arc_father_01_seen", false) \
			and not f.get("arc_father_02_done", false):
		return "arc_father_02_signal"
	if t >= 35 and f.get("arc_father_02_done", false) \
			and not f.get("arc_father_03_seen", false):
		return "arc_father_03_hospital"
	# ── 아버지 별세 — 병원 알고도 미방문 (t100 이후, medication 목격 후 타임아웃) ──
	# [유물 해금] 통화시간 23초를 가진 채 KTX를 타는 순간 — 별세 직전 전처리
	if t >= 100 and f.get("arc_father_03_seen", false) \
			and f.get("arc_father_medication_seen", false) \
			and not f.get("visited_father", false) \
			and not f.get("father_passed", false) \
			and GameState.has_item("artifact_father_call") \
			and not f.get("arc_father_call_on_ktx_seen", false):
		return "arc_father_call_on_ktx"
	if t >= 100 and f.get("arc_father_03_seen", false) \
			and f.get("arc_father_medication_seen", false) \
			and not f.get("visited_father", false) \
			and not f.get("father_passed", false):
		return "arc_father_passing"
	if t >= 43 and f.get("arc_father_03_seen", false) \
			and not f.get("visited_father", false) \
			and not f.get("father_passed", false):
		return "arc_father_04_visit"
	if t >= 52 and f.get("visited_father", false) \
			and not f.get("arc_father_05_seen", false):
		return "arc_father_05_after_visit"
	# ── 아버지 고백 — 빚의 소개인 임상철 (방문 + 상철 커피 이후면 충분)
	# arc_sangchul_02_seen: 커피 1회로 임상철 이름 인식 가능 (03 네트워크 불요)
	if t >= 56 and f.get("visited_father", false) \
			and f.get("arc_father_05_seen", false) \
			and f.get("arc_sangchul_02_seen", false) \
			and not f.get("arc_father_06_seen", false):
		return "arc_father_06_confession"

	# ══ 3구간: 여주인공 (턴 17+) ═══════════════════════
	if t >= 17 and not f.get("arc_jiyeon_crash_seen", false):
		return "arc_jiyeon_01_crash"
	if f.get("arc_jiyeon_crash_seen", false) and not f.get("arc_jiyeon_store_seen", false) and t >= 26:
		return "arc_jiyeon_02_store"
	if f.get("arc_jiyeon_store_seen", false) and not f.get("arc_jiyeon_offer_seen", false) and t >= 36:
		return "arc_jiyeon_03_offer"
	if t >= 40 and f.get("arc_jiyeon_offer_seen", false) \
			and not f.get("arc_jiyeon_03b_seen", false) \
			and not f.get("arc_sangchul_jiyeon_reveal_seen", false):
		return "arc_jiyeon_03b_lunch"

	# ── 추론 발견 경로 — 한PD건설 단서로 스스로 진실에 닿는 씬 (지력55+ 또는 비정통 경향) ──
	if t >= 26 and t <= 50 and f.get("arc_sangchul_03_seen", false) \
			and (GameState.intelligence >= 55 or GameState.route_unorthodox > 20) \
			and not f.get("sangchul_truth_known", false) \
			and not f.get("arc_sangchul_deduction_seen", false):
		return "arc_sangchul_deduction"

	# ── 임상철 인간적 면 — 아들 전화 이후 빈틈 (네트워크 이벤트 이후) ──
	if t >= 26 and f.get("arc_sangchul_03_seen", false) \
			and not f.get("arc_sangchul_offguard_seen", false):
		return "arc_sangchul_offguard"

	# ── 임상철의 이름 — 밥 한 번 먹고 처음 사람으로 보인 날 (턴 30~52) ──
	# 상한 52: 네트워크(03) 합류가 늦은(자산<100만 장기) 플레이어도 offguard→human을
	# 완주해 known_offer(t38~55)에 닿을 수 있도록 윈도우 확장. 일반 케이스는 t30에 발동.
	if t >= 30 and t <= 52 \
			and f.get("arc_sangchul_offguard_seen", false) \
			and not f.get("arc_sangchul_human_seen", false):
		return "arc_sangchul_human"
	# ── 임상철 거울 씬 — "당신은 나랑 비슷해요" (진실 발견 전, 관계 깊어진 후) ──
	if t >= 50 and t <= 90 \
			and GameState.get_cast_affinity("sangchul") >= 65 \
			and f.get("arc_sangchul_human_seen", false) \
			and not f.get("sangchul_truth_known", false) \
			and not f.get("arc_sangchul_mirror_seen", false):
		return "arc_sangchul_mirror"

	# ── 알면서도 — 진실을 안 채 상철을 계속 이용하는 구간 (대면 전 t38~55) ──
	# 사람이 도구가 되는 순간: 알고도 멈추지 않는다.
	if t >= 38 and t <= 55 and f.get("sangchul_truth_known", false) \
			and f.get("arc_sangchul_human_seen", false) \
			and not f.get("arc_sangchul_confrontation_seen", false) \
			and not f.get("arc_sangchul_known_offer_seen", false):
		return "arc_sangchul_known_offer"
	# ── 버릇 — 자기가 상철처럼 사람을 계산하는 걸 발견하는 거울 씬 (t50~59) ──
	if t >= 50 and t <= 59 and f.get("sangchul_truth_known", false) \
			and f.get("arc_sangchul_known_offer_seen", false) \
			and not f.get("arc_sangchul_confrontation_seen", false) \
			and not f.get("arc_sangchul_known_reflex_seen", false):
		return "arc_sangchul_known_reflex"

	# ── 인물망 크로스빔: 재혁 ↔ 상철 — 두 포식자가 한 종(種)임을 화면에서 ──
	# 재혁의 '피해자→운영자' 고백(01b)과 상철의 humanizing 씬을 둘 다 본 뒤,
	# 상철이 재혁에게서 자기 젊은 날을 알아본다. 거울이 플레이어 쪽으로도 돈다.
	if t >= 45 and f.get("arc_jaehyuk_01b_seen", false) \
			and f.get("arc_sangchul_human_seen", false) \
			and not f.get("arc_sangchul_confrontation_seen", false) \
			and not f.get("arc_jaehyuk_sangchul_echo_seen", false):
		return "arc_jaehyuk_sangchul_echo"

	# ── 임상철 대면 — 진실을 알게 된 후, 결정의 순간 ──
	# [유물 해금] 임상철 명함을 가진 채 대면 전날 밤 — 명함과 함께 서는 씬
	if t >= 60 and f.get("sangchul_truth_known", false) \
			and not f.get("sangchul_confronted", false) \
			and not f.get("sangchul_truth_buried", false) \
			and not f.get("sangchul_quietly_distanced", false) \
			and not f.get("arc_sangchul_confrontation_seen", false) \
			and GameState.has_item("artifact_sangchul_card") \
			and not f.get("arc_sangchul_card_at_confrontation_seen", false):
		return "arc_sangchul_card_at_confrontation"
	if t >= 60 and f.get("sangchul_truth_known", false) \
			and not f.get("sangchul_confronted", false) \
			and not f.get("sangchul_truth_buried", false) \
			and not f.get("sangchul_quietly_distanced", false) \
			and not f.get("arc_sangchul_confrontation_seen", false):
		return "arc_sangchul_confrontation"

	# ── 알면서 사는 값 — 대면/청산 이후 상철 망 사용 결정 (Y2 후반~Y3 초) ──
	if t >= 65 and t <= 90 \
			and f.get("arc_sangchul_reckoning_seen", false) \
			and not f.get("arc_y3_cost_of_knowing_seen", false):
		return "arc_y3_cost_of_knowing"

	# ── 임상철 관계 심화 ──
	if t >= 14 and f.get("arc_sangchul_met_seen", false) \
			and not f.get("arc_sangchul_02_seen", false):
		return "arc_sangchul_02_coffee"
	# 첫 만남 후 500만원 이상 모이면 VIP 투자 모임 초대 (데모 달성 가능 수준)
	# ★ 4개월째 한강 씬 — 데모 t=15, 상철 이후 정체감 구간 채움
	if t >= 15 and not f.get("arc_four_months_seen", false):
		return "arc_four_months_in"

	# ── t=14~19 공백 채우기 씬 3종 ──────────────────────────────────
	# 첫 월급날 밤 — 취직 후 첫 월급 수령 시 (t14~17 구간)
	if t >= 14 and t <= 17 \
			and not GameState.current_job.is_empty() \
			and f.get("has_received_paycheck", false) \
			and not f.get("arc_paycheck_reality_seen", false):
		return "arc_paycheck_reality"
	# 첫 투자 손실 — 상철 투자 안내 받고 투자감각이 생긴 플레이어 (t14~18)
	if t >= 14 and t <= 18 \
			and f.get("arc_invest_guidance_seen", false) \
			and GameState.investment_skill >= 5 \
			and not f.get("arc_invest_first_loss_seen", false):
		return "arc_invest_first_loss"
	# 야근 편의점 — 직장 3주 이상, 지연 등장 전 (t16~19)
	if t >= 16 and t <= 19 \
			and not GameState.current_job.is_empty() \
			and GameState.job_tenure >= 3 \
			and not f.get("arc_office_routine_seen", false):
		return "arc_office_routine"
	# ─────────────────────────────────────────────────────────────────

	if t >= 20 and f.get("arc_sangchul_02_seen", false) \
			and not f.get("arc_sangchul_03_seen", false) \
			and GameState.get_total_asset_value() >= 1_000_000:
		return "arc_sangchul_03_network"
	# ── 임상철 정선 카지노 초대 — 커피(02) 이후, 자금 300만 이상이면 초대 가능 ──
	if t >= 23 and f.get("arc_sangchul_02_seen", false) \
			and GameState.money >= 3_000_000 \
			and not f.get("arc_sangchul_casino_seen", false):
		return "arc_sangchul_casino_invite"
	# ── 임상철×지연 교차점 — 두 세계의 충돌 ──
	if t >= 48 and f.get("arc_jiyeon_offer_seen", false) \
			and f.get("arc_sangchul_03_seen", false) \
			and not f.get("arc_sangchul_jiyeon_reveal_seen", false):
		return "arc_sangchul_jiyeon_reveal"

	# ── 직장+투자 충돌 — 직장 있고 투자 시작했을 때 (턴 20~30) ──
	if t >= 20 and t <= 30 \
			and not GameState.current_job.is_empty() \
			and GameState.investment_skill >= 10 \
			and not f.get("arc_job_invest_clash_seen", false):
		return "arc_job_vs_invest"

	# ── 월급의 한계 — 반년 이상 재직 중반 (턴 28~38) ──
	if t >= 28 and t <= 38 \
			and not GameState.current_job.is_empty() \
			and GameState.job_tenure >= 6 \
			and not f.get("arc_career_ceiling_seen", false):
		return "arc_career_ceiling"

	# ── 첫 5천만원 달성 — 숫자가 아니라 감각의 변화 ──
	if t >= 15 \
			and GameState.get_total_asset_value() >= 50_000_000.0 \
			and not f.get("arc_first_real_win_seen", false):
		return "arc_first_real_win"

	# ── 반환점 — 5년의 절반 (턴 30) ──
	if t >= 30 and not f.get("arc_midpoint_reckoning_seen", false):
		return "arc_midpoint_reckoning"

	# ── 동창 조우 — 잘 나가는 동창, 나는? (턴 28~35) ──
	if t >= 28 and t <= 35 \
			and not f.get("arc_social_comparison_seen", false):
		return "arc_social_comparison"

	# ══ 4구간: 최재혁 — 군대 동기 사기 아크 (데모에서 t>=19으로 단축) ══
	# ── 현수 — 시험 불합격 (새벽 라면 이후) ──
	if t >= 25 and t <= 35 \
			and f.get("arc_hyunsu_night_seen", false) \
			and not f.get("arc_hyunsu_exam_fail_seen", false):
		return "arc_hyunsu_exam_fail"

	# ── 현수의 방황 — 불합격 후 떠남 직전 (턴 36~41) ──
	if t >= 36 and t <= 41 \
			and f.get("arc_hyunsu_exam_fail_seen", false) \
			and not f.get("arc_hyunsu_drift_seen", false) \
			and not f.get("arc_hyunsu_new_path_seen", false):
		return "arc_hyunsu_drift"

	# ── 현수의 새 길 — 불합격 이후 떠남 (턴 42~50) ──
	if t >= 42 and t <= 50 \
			and f.get("arc_hyunsu_exam_fail_seen", false) \
			and not f.get("arc_hyunsu_new_path_seen", false):
		return "arc_hyunsu_new_path"

	# ── 심야 루틴 — 현수와 같은 시간, 다른 방향 (턴 12~22, 고시원 거주 중) ──
	if t >= 12 and t <= 22 \
			and GameState.housing == "gosiwon" \
			and f.get("arc_intro_hyunsu_seen", false) \
			and not f.get("arc_night_routine_seen", false):
		return "arc_night_routine"

	# ── 30억이라는 숫자 — 반환점 이후 목표의 무게 (턴 32~42) ──
	if t >= 32 and t <= 42 \
			and f.get("arc_midpoint_reckoning_seen", false) \
			and not f.get("arc_goal_vertigo_seen", false):
		return "arc_goal_vertigo"

	# ── 새 집 첫날 밤 — 고시원 탈출 직후 (고시원 탈출 후 3턴 이내) ──
	if f.get("arc_goshiwon_goodbye_seen", false) \
			and not f.get("arc_housing_new_life_seen", false) \
			and t <= 35:
		return "arc_housing_new_life"

	# ── 처음 혼자 간 강남 (턴 22~28, 누구나) ──
	if t >= 22 and t <= 28 \
			and not f.get("arc_gangnam_visit_alone_seen", false):
		return "arc_gangnam_visit_alone"

	# ── 현수 — 같이 공부하는 사람 (턴 12~18, 첫 만남 이후) ──
	if t >= 12 and t <= 18 \
			and f.get("arc_intro_hyunsu_seen", false) \
			and not f.get("hyunsu_study_together_seen", false):
		return "hyunsu_study_together"

	# ── 현수 — 밤 라면 대화 (턴 20+, 만남 이후) ──
	if t >= 20 and f.get("arc_intro_hyunsu_seen", false) \
			and not f.get("arc_hyunsu_night_seen", false):
		return "arc_hyunsu_night_talk"

	# ── 현수 — 시험 날 (턴 22~28, 밤 대화 이후) ──
	if t >= 22 and t <= 28 \
			and f.get("arc_hyunsu_night_seen", false) \
			and not f.get("hyunsu_exam_day_seen", false):
		return "hyunsu_exam_day"

	# ── 현수 — 시험 결과 (불합격이 기본 스토리, 합격은 hyunsu_encouraged 선택 시) ──
	if f.get("hyunsu_exam_day_seen", false) \
			and not f.get("hyunsu_passed", false) \
			and not f.get("hyunsu_failed", false):
		if f.get("hyunsu_encouraged", false):
			return "hyunsu_result_pass"
		return "hyunsu_result_fail"
	# ── 현수 — 합격 후 발령 소식 ──
	if t >= 80 and f.get("hyunsu_passed", false) \
			and not f.get("hyunsu_pass_news_seen", false):
		return "hyunsu_pass_news"

	# ── 현수 Y4 — 자리잡은 사람 (안정 vs 야망 거울, 합격/피벗 둘 다) ──
	if t >= 150 and (f.get("hyunsu_passed", false) or f.get("hyunsu_pivoted", false)) \
			and not f.get("hyunsu_year4_echo_seen", false):
		return "hyunsu_year4_echo"
	# ── 현수 Y5 — 5년의 끝에서 온 전화 (moral_tint 반응형) ──
	if t >= 200 and f.get("hyunsu_year4_echo_seen", false) \
			and not f.get("hyunsu_year5_call_seen", false):
		return "hyunsu_year5_call"

	if t >= 19 and not f.get("arc_jaehyuk_reunion_seen", false):
		return "arc_jaehyuk_01_reunion"
	if t >= 29 and f.get("arc_jaehyuk_reunion_seen", false) \
			and not f.get("arc_jaehyuk_01b_seen", false) \
			and not f.get("arc_jaehyuk_bond_seen", false):
		return "arc_jaehyuk_01b_real_face"
	# 사기 씨앗(01b '피해자였다가 운영자가 됐다')을 반드시 유대 전에 심는다 —
	# 빠른 런에서 씨앗이 스킵되면 나중 투자 사기 폭로가 뜬금없어진다.
	if f.get("arc_jaehyuk_reunion_seen", false) and f.get("arc_jaehyuk_01b_seen", false) \
			and not f.get("arc_jaehyuk_bond_seen", false) and t >= 32:
		return "arc_jaehyuk_02_bond"
	if t >= 34 and f.get("arc_jaehyuk_bond_seen", false) \
			and not f.get("arc_jaehyuk_02b_seen", false) \
			and not f.get("arc_jaehyuk_pitch_seen", false):
		return "arc_jaehyuk_02b_favor"
	if f.get("arc_jaehyuk_bond_seen", false) and not f.get("arc_jaehyuk_pitch_seen", false) and t >= 37:
		return "arc_jaehyuk_03_pitch"
	# ── 재혁 수익 정산 대기 — 투자 후 불안의 일주일 ──
	if t >= 38 and t <= 41 \
			and f.get("arc_jaehyuk_pitch_seen", false) \
			and (f.get("jaehyuk_trusted_fully", false) or f.get("jaehyuk_partial", false)) \
			and not f.get("arc_jaehyuk_wait_seen", false):
		return "arc_jaehyuk_wait"

	# ── 현수의 경고 — 피치 이후, 아직 도주 전 ──
	if t >= 39 and f.get("arc_jaehyuk_pitch_seen", false) \
			and not f.get("arc_jaehyuk_ghost_seen", false) \
			and not f.get("arc_jaehyuk_hyunsu_warning_seen", false) \
			and (f.get("jaehyuk_trusted_fully", false) or f.get("jaehyuk_partial", false)):
		return "arc_jaehyuk_hyunsu_warning"
	if GameState.cast_has_flag("jaehyuk", "invested") and not f.get("arc_jaehyuk_ghost_seen", false) and t >= 42:
		return "arc_jaehyuk_04a_ghost"
	if GameState.cast_has_flag("jaehyuk", "suspected") and not f.get("arc_jaehyuk_counter_seen", false) and t >= 42:
		return "arc_jaehyuk_04b_counter"
	# ── 사기 당한 후 재기 — ghost 이후, 사후처리 전 ──
	# [유물 해금] 포장마차 셀카를 가진 채 ghost 발각 직후 — 그날 밤의 진실
	if t >= 42 and f.get("arc_jaehyuk_ghost_seen", false) \
			and GameState.has_item("artifact_jaehyuk_photo") \
			and not f.get("arc_jaehyuk_photo_in_dark_seen", false):
		return "arc_jaehyuk_photo_in_dark"
	if t >= 44 and f.get("arc_jaehyuk_ghost_seen", false) \
			and f.get("jaehyuk_scammed", false) \
			and not f.get("arc_jaehyuk_standup_seen", false):
		return "arc_jaehyuk_04c_stand_up"

	# ── 사기 당한 다음 날 — 재기 이벤트 직전 내적 독백 ──
	if t >= 40 and f.get("arc_jaehyuk_ghost_seen", false) \
			and f.get("jaehyuk_scammed", false) \
			and not f.get("arc_after_scam_seen", false):
		return "arc_after_scam"

	# ── 공유할 수 없는 숫자 — 자산 1억 돌파 후 고독 (턴 20+) ──
	if t >= 20 \
			and GameState.get_total_asset_value() >= 100_000_000.0 \
			and not f.get("arc_money_loneliness_seen", false):
		return "arc_money_loneliness"

	# ── 사표 — 자발적 퇴사 직후 드라마 장면 (1회) ──
	if f.get("just_quit_job", false) \
			and not f.get("arc_quit_job_seen", false):
		GameState.flags.erase("just_quit_job")
		return "arc_quit_job"

	# ── 아버지 약 이야기 — 병원 방문 전 중간 신호 (아버지 01 이후, 02 이전) ──
	if t >= 22 and t <= 32 \
			and f.get("arc_father_01_seen", false) \
			and not f.get("arc_father_medication_seen", false) \
			and not f.get("arc_father_02_done", false):
		return "arc_father_medication"

	# ── 막판 한 방 — 1년 남은 시점의 내적 정산 ──
	if t >= 45 \
			and GameState.get_total_asset_value() < 2_800_000_000.0 \
			and not f.get("arc_late_game_push_seen", false):
		return "arc_late_game_push"

	# ── 10억 돌파 — 중반 자산 이정표 (턴 25+) ──
	if t >= 25 \
			and GameState.get_total_asset_value() >= 1_000_000_000.0 \
			and not f.get("arc_almost_there_seen", false):
		return "arc_almost_there"

	# ── 다은이 모르는 것 — 함께하는 경로, 돈 격차 (턴 28~35) ──
	if t >= 28 and t <= 35 \
			and f.get("daeun_chose_her", false) \
			and not f.get("arc_daeun_money_gap_seen", false):
		return "arc_daeun_money_gap"

	# ── 다은의 흔적 — 보낸 경우 (턴 43~50) ──
	if t >= 43 and t <= 50 \
			and f.get("daeun_let_her_go", false) \
			and f.get("arc_daeun_ghost_seen", false) \
			and not f.get("arc_daeun_trace_seen", false):
		return "arc_daeun_trace"

	# ── 강남 집값 — 자산 25억 돌파, 목표가 손에 잡힌다 (턴 50+) ──
	if t >= 50 \
			and GameState.get_total_asset_value() >= 2_500_000_000.0 \
			and not f.get("arc_gangnam_real_estate_seen", false):
		return "arc_gangnam_real_estate"

	# ── 끝이 보인다 — 자산 20억, 마지막 스퍼트 (턴 47+) ──
	if t >= 47 \
			and GameState.get_total_asset_value() >= 2_000_000_000.0 \
			and not f.get("arc_final_stretch_seen", false):
		return "arc_final_stretch"

	# ══ 5구간: 인물 = 결정적 기회 (턴 40+, 30억 경로) ══════
	if GameState.get_cast_stage("sangchul") == "interested" \
			and not f.get("arc_opp_sangchul_seen", false) \
			and t >= 40 and GameState.get_total_asset_value() >= 50_000_000:
		return "arc_opp_sangchul_realty"
	# ── 임상철 베팅 결과 ──
	if f.get("arc_opp_sangchul_seen", false) \
			and not f.get("arc_opp_sangchul_result_seen", false) \
			and (f.get("sangchul_deal_won", false) or f.get("sangchul_deal_lost", false)):
		return "arc_opp_sangchul_win" if f.get("sangchul_deal_won", false) else "arc_opp_sangchul_lose"
	if GameState.get_cast_affinity("jiyeon") >= 25 \
			and not f.get("arc_opp_jiyeon_seen", false) \
			and t >= 45 and GameState.get_total_asset_value() >= 200_000_000:
		return "arc_opp_jiyeon_bunyang"
	# ── 한지연 베팅 결과 ──
	if f.get("arc_opp_jiyeon_seen", false) \
			and not f.get("arc_opp_jiyeon_result_seen", false) \
			and (f.get("jiyeon_deal_won", false) or f.get("jiyeon_deal_lost", false)):
		return "arc_opp_jiyeon_win" if f.get("jiyeon_deal_won", false) else "arc_opp_jiyeon_lose"
	# ── 지연의 고백 — 제안 이후, (임상철 경고 이후 OR t>=70 자연 발견) ──
	if t >= 56 and f.get("arc_jiyeon_offer_seen", false) \
			and (f.get("arc_sangchul_jiyeon_reveal_seen", false) or t >= 70) \
			and not f.get("arc_jiyeon_truth_seen", false):
		if f.get("warned_about_jiyeon", false):
			return "arc_jiyeon_truth_warned"
		return "arc_jiyeon_truth_moment"
	if t >= 64 and f.get("arc_jiyeon_truth_seen", false) \
			and not f.get("arc_jiyeon_epilogue_seen", false):
		return "arc_jiyeon_05_epilogue"

	# ══ 6구간: 전문화 결말 — 선택한 방식이 결실을 맺는다 (턴 25+) ══
	if t >= 25 and f.get("spec_elite", false) and not f.get("arc_spec_elite_result_seen", false):
		return "arc_spec_elite_result"
	if t >= 25 and f.get("spec_social_climber", false) and not f.get("arc_spec_climber_result_seen", false):
		return "arc_spec_climber_result"
	if t >= 25 and f.get("spec_quant", false) and not f.get("arc_spec_quant_result_seen", false):
		return "arc_spec_quant_result"
	if t >= 25 and f.get("spec_speculator", false) and not f.get("arc_spec_speculator_result_seen", false):
		return "arc_spec_speculator_result"
	if t >= 25 and f.get("spec_tech_founder", false) and not f.get("arc_spec_tech_result_seen", false):
		return "arc_spec_tech_result"
	if t >= 25 and f.get("spec_social_entrepreneur", false) and not f.get("arc_spec_social_result_seen", false):
		return "arc_spec_social_result"

	# ══ 7구간: 아크 에필로그 — 선택의 긴 그림자 (턴 50+) ══
	if t >= 50 and (f.get("arc_jaehyuk_ghost_seen", false) or f.get("arc_jaehyuk_counter_seen", false)) \
			and not f.get("arc_jaehyuk_aftermath_seen", false):
		return "arc_jaehyuk_aftermath"
	# ── 재혁 거울 — 보증 요청, 아버지 실수의 반복 (aftermath 이후) ──
	if t >= 60 and f.get("arc_jaehyuk_aftermath_seen", false) \
			and not f.get("refused_jaehyuk_guarantee", false) \
			and not f.get("vouched_jaehyuk_guarantee", false) \
			and not f.get("blocked_jaehyuk_guarantee", false) \
			and not f.get("arc_jaehyuk_mirror_seen", false):
		return "arc_jaehyuk_mirror"
	if t >= 55 and (f.get("arc_daeun_04_seen", false) or f.get("arc_daeun_ghost_seen", false)) \
			and not f.get("arc_daeun_later_echo_seen", false):
		return "arc_daeun_later_echo"

	# ── 현수 — 새 길 (턴 35~50, 불합격 이후) ──
	if t >= 35 and t <= 50 \
			and f.get("hyunsu_failed", false) \
			and not f.get("hyunsu_pivoted", false):
		return "hyunsu_pivot"
	# ── 현수 — 나중에 다시 만난 날 (턴 70+, 피벗 이후) ──
	if t >= 70 \
			and f.get("hyunsu_pivoted", false) \
			and not f.get("hyunsu_reconnected", false):
		return "hyunsu_reunion_later"
	# [유물 해금] 현수 명함 × 극도로 지친 Y4~Y5 — 연락해도 되는 사람
	if t >= 145 and f.get("hyunsu_reconnected", false) \
			and GameState.mental <= 35 \
			and GameState.has_item("artifact_hyunsu_card") \
			and not f.get("arc_hyunsu_lifeline_call_seen", false):
		return "arc_hyunsu_lifeline_call"

	# ══ 8구간: 연도 마커 + 챕터 내부 씬 — 5년의 흐름을 체감하는 무조건 씬 ══
	# t=52 = 13개월차(1년 1개월), t=72 = 18개월차(1년 6개월), t=96 = 24개월차(2년)
	# t=148 = 37개월차(3년 1개월), t=192 = 48개월차(4년), t=220 = 55개월차(마지막 6개월)
	if t >= 52 and t <= 68 and not f.get("arc_year_one_mark_seen", false):
		return "arc_year_one_mark"
	# ── 챕터2 "확장" — 돈이 돈을 부른다 (t54~74) ──
	if t >= 54 and t <= 74 and not f.get("arc_34_money_attracts_seen", false):
		return "arc_34_money_attracts_money"
	# ── 챕터2 "확장" — 문은 사람이 연다 (t74~94) ──
	if t >= 74 and t <= 94 and not f.get("arc_34_doors_open_seen", false):
		return "arc_34_doors_open"
	# ── 1년 반 마커 — t68-90 공백 구간 앵커 (무조건) ──
	if t >= 68 and t <= 90 and not f.get("arc_year_one_half_seen", false):
		return "arc_year_one_half"
	# ── 34세 루틴의 덫 (t62-76) ──
	if t >= 62 and t <= 76 and not f.get("arc_34_routine_trap_seen", false):
		return "arc_34_routine_trap"
	# ── 34세 부모님 서울 방문 (t77-88) ──
	if t >= 77 and t <= 88 and not f.get("arc_34_parents_visit_seen", false):
		return "arc_34_parents_visit"
	# ── 34세 서울 2년째 자각 (t89-96) ──
	if t >= 89 and t <= 100 and not f.get("arc_34_two_years_in_seen", false):
		return "arc_34_two_years_in"

	if t >= 96 and t <= 115 and not f.get("arc_year_two_pressure_seen", false):
		return "arc_year_two_pressure"
	# ── 35세 생일 (t100-112) ──
	if t >= 100 and t <= 112 and not f.get("arc_35_birthday_seen", false):
		return "arc_35_birthday"
	# ── 2년 반 마커 — t120-140 공백 구간 앵커 (무조건) ──
	if t >= 120 and t <= 140 and not f.get("arc_year_two_half_seen", false):
		return "arc_year_two_half"
	# ── 35세 고독 (t116-128) ──
	if t >= 116 and t <= 128 and not f.get("arc_35_alone_seen", false):
		return "arc_35_alone"
	# ── 왜 강남인가 — 테마 결정화 (Y3 중반, t115~140) ──
	if t >= 115 and t <= 140 and not f.get("arc_why_gangnam_real_seen", false):
		return "arc_why_gangnam_real"
	# ── 챕터3 "무게" — 선택한 길의 대가 (route 반응형, t108~138) ──
	if t >= 108 and t <= 138 \
			and not f.get("arc_35_orthodox_weight_seen", false) \
			and not f.get("arc_35_unorthodox_weight_seen", false) \
			and (GameState.route_orthodox + GameState.route_unorthodox) >= 4:
		if GameState.route_orthodox >= GameState.route_unorthodox:
			return "arc_35_orthodox_weight"
		else:
			return "arc_35_unorthodox_weight"
	# ── 챕터3 "무게" — 3년치 잃은 것의 영수증 (무조건, t124~144) ──
	if t >= 124 and t <= 144 and not f.get("arc_35_path_cost_seen", false):
		return "arc_35_path_cost"
	# ── 35세 루틴 점검 (t138-148) ──
	if t >= 138 and t <= 148 and not f.get("arc_35_habit_check_seen", false):
		return "arc_35_habit_check"
	# ── 36세 현실 점검 (t145-158) ──
	if t >= 145 and t <= 158 and not f.get("arc_36_reality_check_seen", false):
		return "arc_36_reality_check"
	if t >= 148 and t <= 165 and not f.get("arc_year_three_crossroads_seen", false):
		return "arc_year_three_crossroads"
	# ── 아버지 서울 방문 — 야망의 비용 (Y4 초반, 아버지와 연결된 플레이어) ──
	if t >= 155 and t <= 178 \
			and f.get("arc_father_01_seen", false) \
			and not f.get("father_passed", false) \
			and not f.get("arc_36_father_visit_seen", false):
		return "arc_36_father_comes_to_seoul"
	# ── 10억 고독 — 자산 10억 돌파 직후 (Y4 전반) ──
	if t >= 145 and t <= 185 \
			and GameState.get_total_asset_value() >= 1_000_000_000.0 \
			and not f.get("arc_1b_isolation_seen", false):
		return "arc_1b_isolation"
	# ── 36세 몸 신호 (t163-172) ──
	if t >= 163 and t <= 172 and not f.get("arc_36_body_signal_seen", false):
		return "arc_36_body_signal"
	# ── 챕터4 "균열" — 믿었던 사람이 흔든다 (t150~178) ──
	if t >= 150 and t <= 178 and not f.get("arc_36_trust_crack_seen", false):
		return "arc_36_trust_crack"
	# ── 챕터4 "균열" — 예상치 못한 사람이 잡는다 (흔들린 직후, t156~188) ──
	if t >= 156 and t <= 188 and f.get("arc_36_trust_crack_seen", false) \
			and not f.get("arc_36_unexpected_hand_seen", false):
		return "arc_36_unexpected_hand"
	# ── 3년 반 마커 — t168-188 공백 구간 앵커 (무조건) ──
	if t >= 168 and t <= 188 and not f.get("arc_year_three_half_seen", false):
		return "arc_year_three_half"
	# ── 36세 새벽 의심 (t176-190) ──
	if t >= 176 and t <= 190 and not f.get("arc_36_night_doubt_seen", false):
		return "arc_36_night_doubt"
	# ── 37세 마지막 정산 (t193-208) ──
	if t >= 193 and t <= 208 and not f.get("arc_37_reckoning_seen", false):
		return "arc_37_reckoning"
	if t >= 192 and t <= 215 and not f.get("arc_final_year_start_seen", false):
		return "arc_final_year_start"
	# ── 37세 번아웃 vs 불꽃 (t210-220) ──
	if t >= 210 and t <= 220 and not f.get("arc_37_burn_or_light_seen", false):
		return "arc_37_burn_or_light"
	# ── 37세 마지막 평화 (t222-236) ──
	if t >= 222 and t <= 236 and not f.get("arc_37_ending_peace_seen", false):
		return "arc_37_ending_peace"
	if t >= 216 and t <= 237 and not f.get("arc_endgame_sixmonths_seen", false):
		return "arc_endgame_sixmonths"

	# ══ 9구간: Year 3-5 인물 재등장 ══════════════════════════════
	# 임상철 Year 3 — 신문 기사 (대면 이후)
	if t >= 100 and f.get("arc_sangchul_confrontation_seen", false) \
			and not f.get("arc_sangchul_year3_seen", false):
		return "arc_sangchul_year3"
	# 한지연 Year 3 — 재연락 (에필로그 이후)
	if t >= 100 and f.get("arc_jiyeon_epilogue_seen", false) \
			and not f.get("arc_jiyeon_year3_seen", false):
		return "arc_jiyeon_year3"
	# 한지연 진짜 이유 — 독립 자격증 공부 (에필로그 이후, Y2후반~Y3)
	if t >= 75 and t <= 105 \
			and f.get("arc_jiyeon_epilogue_seen", false) \
			and not f.get("arc_jiyeon_real_reason_seen", false):
		return "arc_jiyeon_real_reason"
	# 한지연 각자의 방향 — 부산 독립 (진짜 이유 이후, Y3)
	if t >= 110 and t <= 135 \
			and f.get("arc_jiyeon_real_reason_seen", false) \
			and not f.get("arc_y3_jiyeon_departure_seen", false):
		return "arc_y3_jiyeon_departure"
	# 먼저 거는 전화 — 민준의 첫 능동적 연락 (Y3후반~Y4초)
	if t >= 130 and t <= 155 \
			and not f.get("arc_minjun_first_call_seen", false):
		return "arc_minjun_first_call"
	# 한지연 Y4 — 부산 첫 전화 (출발 이후 t>=145)
	if t >= 145 \
			and f.get("arc_y3_jiyeon_departure_seen", false) \
			and not f.get("arc_jiyeon_year4_call_seen", false):
		return "arc_jiyeon_year4_call"
	# 한지연 Y4 서울 방문 — 다은 연인 경로면 갈등 버전, 아니면 일반 버전
	if t >= 165 and t <= 192 \
			and f.get("arc_jiyeon_year4_call_seen", false) \
			and not f.get("arc_jiyeon_year4_seoul_seen", false):
		if f.get("daeun_together_path", false) \
				or f.get("daeun_close_bond", false) \
				or GameState.get_cast_stage("daeun") in ["lover", "together"]:
			return "arc_jiyeon_year4_seoul_daeun"
		elif f.get("jiyeon_year4_wants_more", false) \
				or GameState.get_cast_stage("jiyeon") in ["honest_together", "close", "lover", "respected", "trust"]:
			return "arc_jiyeon_year4_seoul"
	# 한지연 Y5 — 관계에 따라 분기 (귀환 vs 부산 소식)
	if t >= 193 \
			and f.get("arc_jiyeon_year4_call_seen", false) \
			and not f.get("arc_jiyeon_year5_return_seen", false) \
			and not f.get("arc_jiyeon_year5_news_seen", false):
		if f.get("jiyeon_lovers_acknowledged", false):
			return "arc_jiyeon_year5_return"
		else:
			return "arc_jiyeon_year5_news"
	# 김다은 Year 3 — 함께 2주년 (함께 궤적)
	if t >= 100 and (f.get("daeun_close_bond", false) or f.get("daeun_together_path", false)) \
			and not f.get("arc_daeun_year3_together_seen", false):
		return "arc_daeun_year3_together"
	# 김다은 Year 3 — 결혼 소식 (이별 궤적)
	if t >= 100 and (f.get("daeun_let_her_go", false) or f.get("daeun_breakup_accepted", false)) \
			and (f.get("arc_daeun_ghost_seen", false) or f.get("daeun_breakup_accepted", false)) \
			and not f.get("arc_daeun_year3_apart_seen", false):
		return "arc_daeun_year3_apart"
	# 이민서 — Year 4 신규 인물
	if t >= 145 and not f.get("arc_minseo_01_seen", false):
		return "arc_minseo_01_meet"
	if t >= 160 and f.get("arc_minseo_01_seen", false) \
			and not f.get("arc_minseo_02_seen", false):
		return "arc_minseo_02_real"
	# ── 인물망 크로스빔: 지연 ↔ 아버지 — 한PD건설이 아버지 사기 기록에 있다 ──
	# 진실을 알고(sangchul_truth_known) 지연이 한PD건설 딸임을 안(reveal) 플레이어가
	# 그 사실을 지연에게 말할지 결정한다. 지연의 편안함의 바닥을 보여주는 자율 비트.
	if t >= 100 and f.get("arc_sangchul_jiyeon_reveal_seen", false) \
			and f.get("sangchul_truth_known", false) \
			and GameState.get_cast_affinity("jiyeon") >= 40 \
			and not f.get("arc_jiyeon_father_records_seen", false):
		return "arc_jiyeon_father_records"

	# 이민서 — 강남 도착 페이오프 (Y5, 목표 근접 시 그녀의 경고가 회수된다)
	if t >= 200 and f.get("arc_minseo_02_seen", false) \
			and not f.get("arc_minseo_03_seen", false) \
			and GameState.get_total_asset_value() >= 2_000_000_000.0:
		return "arc_minseo_03_arrival"
	# 이민서 — 미달 런 변주 (도착 못 해도 '그 목표가 네 거였냐'는 주제는 똑같이 회수된다)
	if t >= 200 and f.get("arc_minseo_02_seen", false) \
			and not f.get("arc_minseo_03_seen", false) \
			and GameState.get_total_asset_value() < 2_000_000_000.0:
		return "arc_minseo_03b_not_arrived"
	# 김다은 Year 4 — 강남 취직 (함께 궤적)
	if t >= 145 and f.get("arc_daeun_year3_together_seen", false) \
			and not f.get("arc_daeun_year4_together_seen", false):
		return "arc_daeun_year4_together"
	# 아버지 기일
	if t >= 150 and f.get("father_passed", false) \
			and not f.get("arc_father_legacy_seen", false):
		return "arc_father_legacy"
	# 아버지 임종 — 약 복용 이후, 고백 들은 이후
	if t >= 150 and f.get("arc_father_medication_seen", false) \
			and f.get("father_confession_heard", false) \
			and not f.get("arc_father_passing_seen", false) \
			and not f.get("father_passed", false):
		return "arc_father_passing"
	# 김다은 Y4 후반 — 오늘의 서울 (함께 궤적, 강남 취직 이후 조용한 행복 비트)
	if t >= 170 and f.get("arc_daeun_year4_together_seen", false) \
			and not f.get("arc_daeun_year4_quiet_seen", false):
		return "arc_daeun_year4_quiet"
	# 김다은 Year 5 — 30억 전날 밤 (함께 궤적)
	# ★ Y5 로맨스 게이트 — moral_tint 경로 기반 첫 고백 (Y5 첫 주부터)
	if t >= 193 and (f.get("daeun_close_bond", false) or f.get("daeun_together_path", false)) \
			and not f.get("daeun_romance_started", false) \
			and not f.get("daeun_romance_blocked", false) \
			and not f.get("arc_daeun_y5_feelings_seen", false) \
			and GameState.moral_stage() >= 0:
		return "arc_daeun_y5_feelings"
	# 지연 Y5 고백 — 회색 경로 전용. 단, 부산 출발→Y4-Y5 귀환 아크를 탄 플레이어는
	# 그쪽(year5_return)이 연애를 formalize하므로 중복 방지.
	if t >= 193 and f.get("arc_jiyeon_03b_seen", false) \
			and not f.get("jiyeon_romance_started", false) \
			and not f.get("daeun_romance_started", false) \
			and not f.get("arc_jiyeon_y5_feelings_seen", false) \
			and not f.get("arc_jiyeon_year4_call_seen", false) \
			and not f.get("arc_jiyeon_year5_return_seen", false) \
			and not f.get("arc_jiyeon_year5_news_seen", false) \
			and GameState.moral_stage() <= -1:
		return "arc_jiyeon_y5_feelings"
	if t >= 193 and (f.get("daeun_romance_started", false) or f.get("arc_daeun_year4_together_seen", false)) \
			and not f.get("arc_daeun_year5_seen", false):
		return "arc_daeun_year5_ending"
	# 김다은 Year 5 — 강남대로에서 혼자 (이별 궤적)
	if t >= 193 and f.get("arc_daeun_year3_apart_seen", false) \
			and not f.get("arc_daeun_year5_apart_seen", false):
		return "arc_daeun_year5_apart"

	# ── 엔딩 직전 씬 (t>=234, 궤적별 분기) — 진짜 마지막 감정 비트 ──
	if t >= 234:
		var _asset: float = float(GameState.get_total_asset_value())
		# 강남 코앞 — 마지막 한 걸음
		if _asset >= 2_500_000_000.0 and not f.get("arc_pre_ending_summit_seen", false):
			return "arc_pre_ending_summit"
		# 강남 못 감 — 다섯 번째 겨울
		if _asset < 300_000_000.0 and not f.get("arc_pre_ending_winter_seen", false):
			return "arc_pre_ending_winter"
		# 아버지와 화해한 경우 — 마지막 통화 (중간 궤적 커버)
		if f.get("father_reconciled", false) \
				and not f.get("father_passed", false) \
				and not f.get("arc_pre_ending_father_call_seen", false):
			return "arc_pre_ending_father_call"

	# ── 마지막 주 — 38세 7일 전, 궤적 무관 (t237-240) ──
	# 마지막 두 달 — ending_peace(t≤236)와 final_week(t237+) 사이 authored 데드존(t223~233)을 닫는 카운트다운 비트
	if t >= 228 and t <= 236 and not f.get("arc_final_countdown_seen", false):
		return "arc_final_countdown"
	if t >= 237 and not f.get("arc_final_week_seen", false):
		return "arc_final_week"

	return ""

## 마일스톤 스토리 이벤트 — 조건 맞으면 ID 반환 (없으면 ""). StoryMode로 재생.
func _next_milestone_id() -> String:
	var f = GameState.flags
	# 경과 개월 (1=첫 달, 60=마지막 달) — turn(주)이 아닌 달력 기준
	var me: int = (GameState.age - 33) * 12 + GameState.month
	# 첫 출근 (직업 생긴 직후 턴)
	if not GameState.current_job.is_empty() and not f.get("story_first_workday_seen", false):
		return "story_first_workday"
	# 첫 월급 감정 이벤트
	if f.get("has_received_paycheck", false) and not f.get("story_first_paycheck_seen", false):
		return "story_first_paycheck_feel"
	# 첫 저축 마일스톤 — 통장 300만원 돌파
	if GameState.money >= 3_000_000 and not f.get("story_first_savings_seen", false):
		return "story_first_savings_milestone"
	# 5년 = 60개월 = 240턴(주). 마일스톤은 달력(me) 기준.
	if me == 6 and not f.get("story_six_months_seen", false):
		return "story_six_months"
	if me == 12 and not f.get("story_one_year_seen", false):
		return "story_one_year"
	if me == 18 and not f.get("story_one_half_year_seen", false):
		return "story_one_half_year"
	if me == 24 and not f.get("story_two_year_seen", false):
		return "story_two_year"
	if me == 30 and not f.get("age_35_reflected", false):
		return "age_35_checkpoint"
	if me == 36 and not f.get("story_three_year_seen", false):
		return "story_three_year"
	if me == 48 and not f.get("story_four_year_seen", false):
		return "story_four_year"
	if me == 54 and not f.get("age_39_seen", false):
		return "age_39_final"
	return ""

# ── 월별 위기/호재 시스템 ─────────────────────────────────

func _roll_monthly_crisis() -> Dictionary:
	var roll = randf()
	# 6% 호재 달
	if roll < 0.06:
		var bonus_type = randi() % 3
		match bonus_type:
			0:
				return {"type": "bonus_ap", "title": _tr("탄력 받은 달", "A Month on a Roll"),
					"desc": _tr("컨디션이 최고다. 이번 달 행동력 +1 보너스!", "You're in top form. +1 Action Point this month!"), "color": "#00c896"}
			1:
				var amt = float(randi_range(200_000, 600_000))
				return {"type": "bonus_income", "title": _tr("뜻밖의 수입", "Unexpected Income"),
					"desc": _tr("예상치 못한 %s이 들어왔다.", "An unexpected %s came in.") % GameState.format_money(amt), "amount": amt, "color": "#00c896"}
			_:
				return {"type": "market_boom", "title": _tr("시장 급등 신호", "Market Surge Signal"),
					"desc": _tr("이번 달 시장 전반에 강세 신호가 감지됐다. 투자 기회!", "Bullish signals are spreading across the market this month. An investing opportunity!"), "color": "#3fb950"}
	# 18% 위기 달
	if roll < 0.24:
		var crisis_type = randf()
		if crisis_type < 0.30:
			var amt = float(randi_range(150_000, 700_000))
			return {"type": "emergency_expense", "title": _tr("긴급 지출", "Emergency Expense"),
				"desc": _tr("갑작스럽게 %s이 빠져나갔다.", "Suddenly %s went out.") % GameState.format_money(amt), "amount": amt, "color": "#ff4444"}
		elif crisis_type < 0.55:
			return {"type": "ap_penalty", "title": _tr("여유 없는 달", "A Tight Month"),
				"desc": _tr("갑작스러운 사정으로 이번 달 행동력이 1 줄어든다.", "Unexpected circumstances cut your Action Points by 1 this month."), "color": "#f0b429"}
		elif crisis_type < 0.75:
			return {"type": "market_shock", "title": _tr("시장 충격", "Market Shock"),
				"desc": _tr("외부 충격으로 시장이 흔들렸다. 이번 달 투자 위험 대폭 상승.", "An external shock rattled the market. Investment risk spikes sharply this month."), "color": "#ff4444"}
		else:
			var hp_dmg = randi_range(8, 18)
			return {"type": "health_crisis", "title": _tr("몸의 경고", "Body Warning"),
				"desc": _tr("갑자기 몸이 안 좋아졌다. 건강 -%d, 정신력 -12.", "Your body suddenly broke down. Health -%d, Mental -12.") % hp_dmg, "hp": hp_dmg, "color": "#ef4444"}
	return {}

func _apply_monthly_event(ev: Dictionary):
	var t = ev.get("type", "")
	var title = ev.get("title", "")
	var desc = ev.get("desc", "")
	var color = Color(ev.get("color", "#8892a4"))
	match t:
		"bonus_ap":
			GameState.action_points = min(GameState.action_points + 1, GameState.max_action_points + 1)
			_show_toast("%s — %s" % [title, desc], color)
			GameState.add_log(desc, "system")
		"bonus_income":
			var amt = float(ev.get("amount", 300_000.0))
			GameState.add_money(amt)
			_show_toast("%s — %s" % [title, desc], color)
			GameState.add_log(desc, "system")
			AudioManager.play("money_gain")
		"market_boom":
			investment_system.apply_market_shock()  # opposite: boost
			GameState.market_context["fear_greed"] = min(90, int(GameState.market_context.get("fear_greed", 50)) + 20)
			GameState.market_context["cycle"] = "bull"
			GameState.market_context["crash_risk"] = 0.02
			_show_toast("%s — %s" % [title, desc], color)
			GameState.add_log(desc, "market")
		"emergency_expense":
			var amt = float(ev.get("amount", 300_000.0))
			GameState.add_money(-amt)
			GameState.modify_hidden_stat("stress", 10)
			_show_toast("%s — %s" % [title, desc], color)
			GameState.add_log(desc, "system")
		"ap_penalty":
			GameState.action_points = max(1, GameState.action_points - 1)
			_show_toast("%s — %s" % [title, desc], color)
			GameState.add_log(desc, "system")
		"market_shock":
			investment_system.apply_market_shock()
			_show_toast("%s — %s" % [title, desc], color)
			GameState.add_log(desc, "market")
		"health_crisis":
			var hp_dmg = int(ev.get("hp", 10))
			GameState.modify_stat("health", -hp_dmg)
			GameState.modify_hidden_stat("stress", 12)
			_show_toast("%s — %s" % [title, desc], color)
			GameState.add_log(desc, "system")

# ── RPG: 스탯 임계값 해금 알림 ──────────────────────────────────────────

func _on_stat_threshold_crossed(stat_name: String, threshold: int):
	var unlock_msgs = {
		"investment_skill": {
			30: _tr("레버리지 투자 해금. 2배 포지션으로 고수익을 노릴 수 있다.", "Leverage Investing unlocked. Go for high returns with 2x positions."),
			50: _tr("시장 분석(무료 행동) 해금. 매달 시장 방향을 미리 읽어라.", "Market Analysis (free action) unlocked. Read the market direction ahead each month."),
			70: _tr("선물 매매 해금. 극한의 투자가가 되었다.", "Futures Trading unlocked. You've become an extreme investor."),
		},
		"intelligence": {
			30: _tr("심화 독서 해금. 독서 효과가 2배로 강화된다.", "Deep Reading unlocked. Reading effects are doubled."),
			50: _tr("재무제표 분석 해금. 투자 결정에 정확도가 올라간다.", "Financial Statement Analysis unlocked. Your investment decisions get more accurate."),
			70: _tr("데이터 드리븐 투자 해금. 시장 예측 정확도 최고 수준.", "Data-Driven Investing unlocked. Top-tier market prediction accuracy."),
		},
		"social_skill": {
			30: _tr("관계 강화 효과 상승. 인맥활동 보너스가 커진다.", "Relationship effects boosted. Networking bonuses grow larger."),
			50: _tr("VIP 인맥 해금. 사회성 3배 상승, 대형 관계 이벤트 접근 가능.", "VIP Connections unlocked. Social x3, access to major relationship events."),
			70: _tr("엘리트 서클 해금. 최상위 직군 이벤트와 네트워크에 접근한다.", "Elite Circle unlocked. Access to top-tier career events and networks."),
		},
	}
	var stat_msg = unlock_msgs.get(stat_name, {})
	if stat_msg.has(threshold):
		var msg = stat_msg[threshold]
		_show_toast(msg, Color("#f0b429"))
		GameState.add_log(msg, "system")
		AudioManager.play("housing_up")

# ── 성향 자각 (직장/투자/창업) ─────────────────────────────────
func _on_tendency_awakened(kind: String):
	# 액션 중 동기 호출이면 그 액션의 _close_modal에 닫힐 수 있어 다음 idle로 미룬다
	call_deferred("_present_tendency_realization", kind)

func _present_tendency_realization(kind: String):
	if GameState.is_game_over:
		return
	var tname: String = GameState.tendency_name(kind)
	var desc: String = GameState.tendency_desc(kind)
	var accent: String = {"career": "#b8ad8a", "invest": "#8bb6a1", "found": "#aaa0bf"}.get(kind, "#b8ad8a")
	var passive: String = {
		"career": _tr("업무 성과 +12, 사회성 +3 — 승진과 신용이 너의 무기가 된다.", "Work Performance +12, Social +3 — promotions and credit become your weapons."),
		"invest": _tr("투자 감각 +6, 지력 +2 — 시장이 한층 선명하게 보인다.", "Investing +6, Intelligence +2 — the market comes into sharper focus."),
		"found":  _tr("운 +3, 지력 +2 — 창업가의 촉이 열렸다.", "Luck +3, Intelligence +2 — a founder's instinct has awakened."),
	}.get(kind, "")
	_open_modal(_tr("습관이 굳어진다", "A Pattern Emerges"))
	if modal_panel:
		modal_panel.custom_minimum_size = Vector2(760, 360)
		modal_panel.offset_top = -180
		modal_panel.offset_bottom = 180
	if modal_scroll:
		modal_scroll.custom_minimum_size = Vector2(0, 230)
	modal_body.add_child(_label(_tr("어느새 너는 — %s의 길로 움직이고 있다.", "Without noticing, you have begun moving toward the %s path.") % tname, 21, "#ffffff"))
	modal_body.add_child(_wrap_label(desc, 14, "#aab3c5"))
	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color("#252535"))
	modal_body.add_child(sep)
	modal_body.add_child(_wrap_label(passive, 14, accent))
	modal_body.add_child(_wrap_label(_tr("이 길이 옳은지는 아무도 모른다. 다만 같은 선택을 반복할수록, 선택도 너를 닮아간다.", "No one knows if this path is right. But the more you repeat a choice, the more your choices begin to resemble you."), 13, "#7a8496"))
	AudioManager.play("housing_up")
	GameState.add_log(_tr("습관이 굳어진다 — %s. %s", "A pattern emerges — %s. %s") % [tname, passive], "system")

func _on_next_month():
	if not current_event.is_empty():
		return
	if not pending_result_text.is_empty():
		pending_result_text = ""
		return
	if GameState.tutorial_step > 0:
		GameState.tutorial_step -= 1

	var is_month_end := (GameState.week_of_month == 4)

	if is_month_end:
		# ── 월말 처리 ─────────────────────────────────────────
		job_system.process_monthly_job()
		relationship_system.process_monthly_relationships()
		inventory_system.process_monthly_items()
		if not GameState.current_job.is_empty():
			GameState.add_tendency("career", 1)
		BGMPlayer.update_context()

		# 1개월만 정착 지원금 — 2개월차부터 진짜 생존 압박
		var subsidy_applied = GameState.month <= 1
		if subsidy_applied:
			GameState.add_money(300_000.0)
			GameState.add_log(_tr("초기 정착 지원금 30만원 수령", "Received KRW 300,000 initial settlement subsidy"), "system")

		var snap = {
			"date": GameState.get_date_string(),
			"money_before": GameState.money,
			"monthly_income": GameState.monthly_income,
			"fixed_expense": GameState.get_housing_expense(),
			"assets_before": GameState.get_total_asset_value(),
			"health_before": GameState.health,
			"mental_before": GameState.mental,
			"mental_before_pressure": GameState.mental,
			"actions": turn_action_log.duplicate(),
			"subsidy": subsidy_applied,
		}

		var had_paycheck_before: bool = GameState.flags.get("has_received_paycheck", false)
		GameState.apply_monthly_pressure()
		GameState.advance_calendar()
		_refresh_all()
		if not had_paycheck_before and GameState.flags.get("has_received_paycheck", false):
			_show_toast(_tr("첫 월급 수령! 투자·상점이 열렸습니다", "First paycheck received! Investing and the shop are now open"), Color("#00c896"))
		if GameState.is_game_over:
			return
		SaveManager.autosave()
		_check_title_unlocks()
		_show_month_summary(snap)
	else:
		# ── 주 전환 (월말 아님) ───────────────────────────────
		GameState.advance_calendar()
		_refresh_all()
		if GameState.is_game_over:
			return
		SaveManager.autosave()
		_begin_month()

func _choose(index):
	# 타이머가 돌고 있으면 취소 (수동 선택)
	if _choice_countdown_timer and is_instance_valid(_choice_countdown_timer):
		_choice_countdown_timer.queue_free()
		_choice_countdown_timer = null
	var choices: Array = current_event.get("choices", [])
	var selected_choice: Dictionary = {}
	var result_text = ""
	var effects: Dictionary = {}
	if index >= 0 and index < choices.size():
		selected_choice = choices[index]
		_last_chosen_foreshadow = str(selected_choice.get("foreshadow", ""))
		result_text = str(selected_choice.get("result_text", "")).strip_edges()
		effects = selected_choice.get("effects", {})
	EventManager.resolve_current_event(index)
	current_event = EventManager.get_next_event()
	_play_choice_feedback(effects, selected_choice)

	# 충격 이벤트 감지: 건강·정신 -15 이상 손실 또는 100만원 이상 갑작스러운 손실
	var effective_mental_delta = int(effects.get("mental", 0)) - int(effects.get("stress", 0))
	var is_critical = (int(effects.get("health", 0)) <= -15
		or effective_mental_delta <= -15
		or int(effects.get("money", 0)) <= -1_000_000)
	if is_critical:
		GameState.flags["just_critical_event"] = true
		_update_portrait()
		# 1.2초 후 플래그 해제
		var _t = get_tree().create_timer(1.2)
		_t.timeout.connect(func():
			GameState.flags["just_critical_event"] = false
			_update_portrait()
		)

	if not effects.is_empty():
		_show_effects_float(effects)
	if not result_text.is_empty() and current_event.is_empty():
		_show_result(result_text, effects, selected_choice)
	else:
		_render_event()
	_refresh_all()

func _show_result(result_text: String, effects: Dictionary = {}, selected_choice: Dictionary = {}):
	_play_ink_transition("result", 0.90)
	for child in choice_box.get_children():
		child.queue_free()
	_result_reveal_controls.clear()
	_result_focus_button = null
	pending_result_text = result_text
	_transient_bg_active = true
	event_title.text = _tr("결과", "Result")
	_pulse_node(event_title, 1.04, 0.28)
	event_body.modulate.a = 0.0
	var fade_tw := create_tween()
	fade_tw.tween_property(event_body, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_SINE)
	var rt_fmt := _fmt(result_text)
	# 긴장감 있는 결과 텍스트에 wave 적용
	if rt_fmt.count("...") > 0 and str(pending_result_text).length() < 200:
		rt_fmt = rt_fmt.replace("...", "[wave amp=3 freq=2]...[/wave]")
	_type_text(rt_fmt)
	# 복선 텍스트 — 타이핑 완료 후 흐릿하게 페이드인
	var fw := _last_chosen_foreshadow
	_last_chosen_foreshadow = ""
	var fw_lbl: Label = null
	if not fw.is_empty():
		fw_lbl = _wrap_label("…  " + fw, 11, "#3a4a60")
		fw_lbl.modulate.a = 0.0
		choice_box.add_child(fw_lbl)
		_result_reveal_controls.append(fw_lbl)
	var result_card: Control = _story_result_feedback_card(effects, selected_choice)
	if result_card:
		result_card.modulate.a = 0.0
		result_card.scale = Vector2(0.992, 0.992)
		choice_box.add_child(result_card)
		_result_reveal_controls.append(result_card)
	# 확인 버튼도 타이핑 완료 후 페이드인
	var confirm_btn = _button(_tr("확인", "Confirm"), "#1f6feb")
	confirm_btn.modulate.a = 0.0
	confirm_btn.pressed.connect(func(): _finish_typing(); _on_result_confirmed())
	choice_box.add_child(confirm_btn)
	_result_reveal_controls.append(confirm_btn)
	_result_focus_button = confirm_btn
	if _typing_tween:
		_typing_tween.tween_callback(func(): _reveal_result_controls(true))
	else:
		_reveal_result_controls(false)
	next_button.disabled = true

func _reveal_result_controls(animated: bool) -> void:
	if _result_reveal_controls.is_empty():
		return
	var delay := 0.0
	for node in _result_reveal_controls:
		if not is_instance_valid(node):
			continue
		if animated:
			var tw := create_tween()
			tw.tween_interval(delay)
			tw.tween_property(node, "modulate:a", 1.0, 0.20).set_trans(Tween.TRANS_SINE)
			if node is PanelContainer:
				tw.parallel().tween_property(node, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		else:
			node.modulate.a = 1.0
			if node is PanelContainer:
				node.scale = Vector2.ONE
		delay += 0.10
	if _result_focus_button and is_instance_valid(_result_focus_button):
		_result_focus_button.call_deferred("grab_focus")
	_result_reveal_controls.clear()
	_result_focus_button = null

func _on_result_confirmed():
	pending_result_text = ""
	_transient_bg_active = false
	# 흉터 비네트 — 삶의 선을 처음 넘는 순간 (band 전이보다 우선)
	if not GameState.pending_scar_vignette.is_empty():
		var scar := GameState.pending_scar_vignette
		GameState.pending_scar_vignette = ""
		_show_scar_beat(scar)
		return
	# MORAL_TINT 밴드 전이 비네트 — 선택의 결과 직후, 조용한 자각 한 장면
	if not GameState.pending_tint_vignette.is_empty():
		var v: Dictionary = GameState.pending_tint_vignette
		GameState.pending_tint_vignette = {}
		_show_moral_beat(int(v.get("from", 0)), int(v.get("to", 0)))
		return
	_render_event()

# 밴드를 넘을 때 터지는 짧은 자각 — 숫자·스탯 표시 없이 본문만. (docs/MORAL_TINT.md §6)
func _show_moral_beat(from_band: int, to_band: int):
	_play_ink_transition("moral", 1.15)
	for child in choice_box.get_children():
		child.queue_free()
	_transient_bg_active = true
	_clear_category_tint(true)
	_clear_feedback_flash()
	var body := _moral_beat_text(from_band, to_band)
	event_title.text = ""
	_type_text(_fmt(body), 42.0)
	var btn: Button = _button(_tr("…", "…"), "#3a3f4a")
	btn.pressed.connect(func(): _finish_typing(); _on_result_confirmed())
	choice_box.add_child(btn)
	next_button.disabled = true

# 흉터 비네트 — 삶의 선을 처음 넘은 날 밤, 한 장면. 숫자 없음. (docs/MORAL_TINT.md §7)
func _show_scar_beat(scar_flag: String) -> void:
	_play_ink_transition("moral", 1.25)
	for child in choice_box.get_children():
		child.queue_free()
	_transient_bg_active = true
	_clear_category_tint(true)
	_clear_feedback_flash()
	var body: String
	match scar_flag:
		"crossed_line":
			body = _tr(
				"잠에서 깼다.\n\n뭔가 없어진 것 같은 느낌이었다.\n어제 내린 결정이 생각났다.\n이전으로 돌아갈 수 없다는 것도.",
				"I woke up.\n\nSomething felt missing.\nI thought of the decision I'd made yesterday.\nAnd of the fact that there was no going back.")
		"chose_money_over_father":
			body = _tr(
				"아버지가 마지막으로 말했던 것을 기억하려 했다.\n\n그런데 기억이 나지 않았다.\n이상하게.",
				"I tried to remember the last thing my father said.\n\nI couldn't.\nStrangely.")
		_:
			body = _tr("...", "...")
	event_title.text = ""
	_type_text(_fmt(body), 36.0)
	var btn: Button = _button(_tr("…", "…"), "#2a2f3a")
	btn.pressed.connect(func(): _finish_typing(); _on_result_confirmed())
	choice_box.add_child(btn)
	next_button.disabled = true

func _moral_beat_text(from_band: int, to_band: int) -> String:
	# 검정 쪽으로 (잃어감)
	if to_band < from_band:
		if to_band <= -2:
			return _tr(
				"거울을 봤다.\n처음 이 방에 들어왔던 얼굴을 떠올리려 했는데 —\n낯설었다.",
				"I looked in the mirror.\nI tried to picture the face that first walked into this room —\nit felt unfamiliar.")
		if to_band == -1:
			return _tr(
				"밥을 먹는데 맛이 안 났다.\n그냥 연료 같았다.",
				"I was eating, but the food had no taste.\nIt was just fuel.")
		return _tr(
			"뭔가, 조금씩 식어가는 느낌이 들었다.\n뭔지는 몰랐다.",
			"Something felt like it was slowly going cold.\nI couldn't say what.")
	# 하양 쪽으로 (되찾음 — 불완전)
	if to_band >= 2:
		return _tr(
			"창밖의 간판 색이 이상하게 선명했다.\n원래 저렇게 많은 색이 있었나, 잠깐 생각했다.",
			"The signs outside the window looked strangely vivid.\nFor a moment I wondered whether there had always been that much color.")
	if to_band == 1:
		return _tr(
			"오랜만에 통화 끝에 웃었다.\n웃는 게 어색했다는 걸, 웃고 나서 알았다.",
			"For once I laughed at the end of a call.\nOnly after did I realize how unfamiliar laughing had become.")
	return _tr(
		"오늘은 조금, 사람 같았다.\n그게 얼마 만인지 세지 않기로 했다.",
		"Today I felt a little more like a person.\nI decided not to count how long it had been.")

func _fmt(text: String) -> String:
	return GameState.format_event_text(text)

# ── 타이핑 효과 ──────────────────────────────────────────────
func _type_text(formatted_text: String, cps: float = 38.0) -> void:
	if _typing_tween:
		_typing_tween.kill()
		_typing_tween = null
	event_body.text = formatted_text
	var n := maxi(event_body.get_total_character_count(), 1)
	event_body.visible_ratio = 0.0
	var dur := clampf(float(n) / cps, 0.15, 3.5)
	_typing_tween = create_tween()
	_typing_tween.tween_property(event_body, "visible_ratio", 1.0, dur) \
		.set_trans(Tween.TRANS_LINEAR)

# 타이핑 중이면 즉시 완료 후 선택지 표시, 이미 끝났으면 false 반환
func _finish_typing() -> bool:
	if _typing_tween and _typing_tween.is_running():
		_typing_tween.kill()
		_typing_tween = null
		event_body.visible_ratio = 1.0
		# 선택지가 아직 안 나왔으면 즉시 표시
		if _choice_reveal_pending:
			_reveal_choices()
		_reveal_result_controls(false)
		return true
	return false

func _render_event():
	for child in choice_box.get_children():
		child.queue_free()
	if current_event.is_empty():
		next_button.disabled = false
		_clear_category_tint()
		BGMPlayer.update_idle_ambience()
		_render_ap_actions()
		return
	_transient_bg_active = false
	_play_ink_transition("event", 0.80)
	next_button.disabled = true
	# 카테고리 틴트 적용 (분위기 신호 — Balatro 배경 전환 아이디어)
	_apply_category_tint(str(current_event.get("category", "")))
	event_title.text = _fmt(current_event.get("title", _tr("이벤트", "Event")))
	_update_event_bg()
	BGMPlayer.update_event_ambience(current_event)
	AudioManager.play_event_cue(current_event)
	_update_portrait()
	# 이벤트 패널 페이드인
	event_body.modulate.a = 0.0
	var fade_tw := create_tween()
	fade_tw.tween_property(event_body, "modulate:a", 1.0, 0.25).set_trans(Tween.TRANS_SINE)
	var desc: String = _fmt(current_event.get("description", ""))
	var ev_tags: Array = current_event.get("tags", [])
	# 도박/스트레스/불안 이벤트: "..." → [wave] (긴장감)
	if ev_tags.has("gambling") or ev_tags.has("stress") or ev_tags.has("anxiety"):
		desc = desc.replace("...", "[wave amp=3.5 freq=2.5]...[/wave]")
	# 재앙/건강 이벤트: "..." → [shake] (충격)
	elif ev_tags.has("disaster") or ev_tags.has("health"):
		desc = desc.replace("...", "[shake rate=5 level=2]...[/shake]")
	_type_text(desc)
	# 타이핑 완료 후 선택지 표시 — 콜백 예약
	_choice_reveal_pending = true
	if _typing_tween:
		_typing_tween.tween_callback(_reveal_choices)

func _reveal_choices():
	if not _choice_reveal_pending:
		return
	_choice_reveal_pending = false
	var choices: Array = current_event.get("choices", [])
	# ── 텍스트 / 선택지 구분선 ───────────────────────────
	var sep_row = HBoxContainer.new()
	sep_row.add_theme_constant_override("separation", 8)
	sep_row.custom_minimum_size = Vector2(0, 20)
	var line_l = ColorRect.new()
	line_l.set_meta("moral_role", "separator_line")
	line_l.color = Color("#1e2038")
	line_l.custom_minimum_size = Vector2(0, 1)
	line_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line_l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sep_row.add_child(line_l)
	var sep_lbl = _label(_tr("선택", "Choices"), 11, "#2e3a52")
	sep_lbl.set_meta("moral_role", "separator_text")
	sep_lbl.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	sep_row.add_child(sep_lbl)
	var line_r = ColorRect.new()
	line_r.set_meta("moral_role", "separator_line")
	line_r.color = Color("#1e2038")
	line_r.custom_minimum_size = Vector2(0, 1)
	line_r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line_r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sep_row.add_child(line_r)
	sep_row.modulate.a = 0.0
	choice_box.add_child(sep_row)
	var btn_accents = ["#3a6ea8", "#4a7a5a", "#6a4a7a"]
	var _first_choice_btn: Button = null
	var stagger_delay := 0.0
	for i in range(choices.size()):
		var choice: Dictionary = choices[i]
		var acc = btn_accents[i % btn_accents.size()]
		# 버튼+미리보기를 한 그룹 컨테이너에 묶어 시각적 연관 명확화
		var group := VBoxContainer.new()
		group.add_theme_constant_override("separation", 3)
		group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		group.modulate.a = 0.0
		group.scale = Vector2(0.986, 0.986)
		choice_box.add_child(group)
		var button = _action_button("  %d.  %s" % [i + 1, _fmt(choice.get("text", _tr("선택", "Choice")))], acc)
		button.custom_minimum_size = Vector2(0, 44)
		button.pressed.connect((func(idx): _choose(idx)).bind(i))
		group.add_child(button)
		if i == 0:
			_first_choice_btn = button
		# 효과 미리보기 (Disco Elysium 스타일 — 선택 전 결과 힌트)
		var preview_str := _choice_effects_preview(choice)
		if not preview_str.is_empty():
			var preview_lbl := _label("  " + preview_str, 11, "#5a6a80")
			preview_lbl.set_meta("moral_role", "hint_text")
			group.add_child(preview_lbl)
		# 그룹 전체 페이드인 (구분선은 첫 그룹 직전)
		if i == 0:
			var tw0 := create_tween()
			tw0.tween_property(sep_row, "modulate:a", 1.0, 0.18)
		var tw := create_tween()
		tw.tween_interval(stagger_delay)
		tw.tween_property(group, "modulate:a", 1.0, 0.22).set_trans(Tween.TRANS_SINE)
		tw.parallel().tween_property(group, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		stagger_delay += 0.10
	if ControllerHints.is_pad_active():
		var hint = _tr("[%s] 선택  [%s] 메뉴  (%s)", "[%s] Choose  [%s] Menu  (%s)") % [
			ControllerHints.south(), ControllerHints.start_btn(), ControllerHints.brand_name()]
		var hlbl = _label(hint, 11, "#3a4a5a")
		hlbl.set_meta("moral_role", "hint_text")
		hlbl.modulate.a = 0.0
		choice_box.add_child(hlbl)
		var twh := create_tween()
		twh.tween_interval(stagger_delay)
		twh.tween_property(hlbl, "modulate:a", 1.0, 0.18)
	if _first_choice_btn:
		_first_choice_btn.call_deferred("grab_focus")
	_apply_moral_tree_styles(choice_box, _moral_ui_palette())
	# ── 중요 분기 타이머 ──────────────────────────────────────
	if current_event.get("timed", false):
		_start_choice_countdown(current_event.get("timer_seconds", 12))

func _start_choice_countdown(secs: int):
	_choice_countdown_remaining = secs
	# 타이머 행 (프로그레스바 + 숫자)
	var timer_row := HBoxContainer.new()
	timer_row.name = "_timer_row"
	timer_row.add_theme_constant_override("separation", 8)
	var pbar := ProgressBar.new()
	pbar.name = "_countdown_bar"
	pbar.max_value = float(secs)
	pbar.value = float(secs)
	pbar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pbar.custom_minimum_size = Vector2(0, 6)
	pbar.show_percentage = false
	timer_row.add_child(pbar)
	var tlbl := _label(_tr("남은 시간 %d", "Time %d") % secs, 13, "#f97316")
	tlbl.name = "_countdown_lbl"
	tlbl.custom_minimum_size = Vector2(44, 0)
	timer_row.add_child(tlbl)
	choice_box.add_child(timer_row)
	# 프로그레스바 트윈
	var tw := create_tween()
	tw.tween_property(pbar, "value", 0.0, float(secs)).set_trans(Tween.TRANS_LINEAR)
	# 초당 레이블 갱신 + 자동 선택 타이머
	_choice_countdown_timer = Timer.new()
	_choice_countdown_timer.wait_time = 1.0
	_choice_countdown_timer.autostart = true
	add_child(_choice_countdown_timer)
	_choice_countdown_timer.timeout.connect(func():
		_choice_countdown_remaining -= 1
		if is_instance_valid(tlbl):
			tlbl.text = _tr("남은 시간 %d", "Time %d") % _choice_countdown_remaining
			if _choice_countdown_remaining <= 3:
				tlbl.remove_theme_color_override("font_color")
				tlbl.add_theme_color_override("font_color", Color("#ff4444"))
		if _choice_countdown_remaining <= 0:
			if is_instance_valid(_choice_countdown_timer):
				_choice_countdown_timer.queue_free()
				_choice_countdown_timer = null
			_choose(0)
	)

func _refresh_all():
	if not is_inside_tree():
		return
	_update_vignette()
	_update_ambient_tint()
	_refresh_goal_bar()
	top_labels["date"].text = GameState.get_date_string()
	var total_assets = GameState.get_total_asset_value()
	var cash_str = GameState.format_money(GameState.money)
	var asset_str = GameState.format_money(total_assets)
	if LocaleManager.is_english() and abs(total_assets - GameState.money) > 10000:
		top_labels["money"].text = "%s  |  %s" % [cash_str, asset_str]
	elif abs(total_assets - GameState.money) > 10000:
		top_labels["money"].text = _tr("현금 %s  |  자산 %s", "Cash %s  |  Assets %s") % [cash_str, asset_str]
	else:
		top_labels["money"].text = cash_str if LocaleManager.is_english() else (_tr("현금 %s", "Cash %s") % cash_str)
	_apply_money_moral_glow()
	# AP 도트 (이벤트 없을 때만 표시, _render_ap_actions에서도 갱신)
	var ap = GameState.action_points
	top_labels["ap"].text = "%d/%d" % [ap, GameState.max_action_points]
	# 초상화 하단 플레이어 정보 (이벤트 중 인물 표시 시에는 건드리지 않음)
	var showing_character = not current_event.is_empty() and str(current_event.get("portrait", "")) != ""
	if not showing_character:
		if player_name_label:
			var job_name = GameState.get_job_display_name()
			player_name_label.text = "%s\n%s" % [GameState.player_name, job_name]
		if title_label:
			var ttl := _quote_ui(GameState.get_current_title())
			if not GameState.get_dominant_tendency().is_empty():
				ttl += "\n· %s ·" % GameState.get_tendency_label()
			title_label.text = ttl

	stat_labels["job"].text = GameState.get_job_display_name()
	_set_stat_value("health", GameState.health, true, 50, 30)
	_set_stat_value("mental", GameState.mental, true, 50, 30)

	# ── 탑바 바이탈 HUD 갱신 ─────────────────────────
	_refresh_vitals()
	stat_labels["asset"].text = GameState.format_money(GameState.get_total_asset_value())
	stat_labels["housing"].text = GameState.get_housing_display_name(GameState.housing)

	# 배경 + 초상화 업데이트
	_update_event_bg()
	_update_portrait()

	# 자산 마일스톤 체크
	_check_milestones()

	_render_news()
	_render_sidebars()
	_render_log()

# ── 스탯 변화 플로팅 숫자 애니메이션 ──────────────────────────────
const _STAT_KR = {
	"health": "건강", "mental": "정신",
	"intelligence": "지력", "social_skill": "사회성",
	"investment_skill": "투자감각", "luck": "운",
	"appearance": "외모", "reputation": "평판",
	"money": "₩", "addiction_tendency": "중독도",
}
const _STAT_EN = {
	"health": "Health", "mental": "Mental",
	"intelligence": "Intelligence", "social_skill": "Social",
	"investment_skill": "Investing", "luck": "Luck",
	"appearance": "Appearance", "reputation": "Reputation",
	"money": "KRW", "addiction_tendency": "Addiction",
}

## 선택지 효과 미리보기 한 줄 요약 (Disco Elysium 스타일)
func _choice_effects_preview(choice: Dictionary) -> String:
	var eff: Dictionary = choice.get("effects", {})
	if eff.is_empty():
		return ""
	# stress → mental 병합
	var merged: Dictionary = {}
	for k in eff:
		if k == "stress":
			merged["mental"] = int(merged.get("mental", 0)) - int(eff[k])
		elif k == "mental":
			merged["mental"] = int(merged.get("mental", 0)) + int(eff[k])
		else:
			merged[k] = eff[k]
	# 즉각적으로 느껴지는 것만 표시 — 관계/스킬/평판은 숨김 (결과 텍스트로 전달)
	var priority = ["money", "health", "mental"]
	var parts: Array = []
	for key in priority:
		if not merged.has(key):
			continue
		var val: int = int(merged[key])
		if val == 0:
			continue
		var stat_name: String = str(_STAT_EN.get(key, key)) if LocaleManager.is_english() else str(_STAT_KR.get(key, key))
		var sign: String = "+" if val > 0 else ""
		if key == "money":
			parts.append("%s %s%s" % [stat_name, sign, GameState.format_money(float(val))])
		else:
			parts.append("%s %s%d" % [stat_name, sign, val])
		if parts.size() >= 4:
			break
	if parts.is_empty():
		return ""
	return "  ".join(parts)

func _show_effects_float(effects: Dictionary):
	# merge "stress" into "mental" for display (stress removed as user-visible stat)
	var merged: Dictionary = {}
	for k in effects:
		if k == "stress":
			merged["mental"] = int(merged.get("mental", 0)) - int(effects[k])
		elif k == "mental":
			merged["mental"] = int(merged.get("mental", 0)) + int(effects[k])
		else:
			merged[k] = effects[k]
	var idx = 0
	for key in merged:
		var val = int(merged[key])
		if val == 0 or key not in _STAT_KR:
			continue
		var label_kr = _tr(_STAT_KR[key], _STAT_EN[key])
		var sign = "+" if val > 0 else ""
		var text: String
		if key == "money":
			text = "%s%s" % [sign, GameState.format_money(float(val))]
		else:
			text = "%s%d %s" % [sign, val, label_kr]
		var is_good: bool
		if key == "addiction_tendency":
			is_good = val < 0
		elif key == "money":
			is_good = val > 0
		else:
			is_good = val > 0
		var color = Color("#34d399") if is_good else Color("#ff6b6b")
		if key == "money":
			color = Color("#f0b429")
		_spawn_float(text, color, idx)
		idx += 1

func _play_choice_feedback(effects: Dictionary, choice: Dictionary):
	AudioManager.play("choice_made")
	AudioManager.pulse_gamepad(0.035, 0.070, 0.055)
	_pulse_choice_surface()
	if choice.has("opportunity"):
		var result := str(GameState.flags.get("_last_opportunity_result", ""))
		if result == "win":
			AudioManager.play("money_big")
			_screen_flash(Color("#f0b429"), 0.22, 0.46)
			_pulse_node(top_labels.get("money", null), 1.12, 0.34)
		elif result == "lose":
			AudioManager.play("money_loss")
			_screen_flash(Color("#d73a49"), 0.24, 0.42)
			_shake_node(event_bg, 10.0, 0.32)
		return

	var money_delta := int(effects.get("money", 0))
	var health_delta := int(effects.get("health", 0))
	var mental_delta := int(effects.get("mental", 0))
	var big_loss := money_delta <= -1_000_000 or health_delta <= -15 or mental_delta <= -15
	var big_gain := money_delta >= 1_000_000
	if big_gain:
		AudioManager.play("money_big")
		_screen_flash(Color("#f0b429"), 0.20, 0.42)
		_pulse_node(top_labels.get("money", null), 1.12, 0.34)
		_spawn_coin_burst()
	elif big_loss:
		AudioManager.play("stat_down")
		_screen_flash(Color("#d73a49"), 0.24, 0.38)
		_shake_node(event_bg, 9.0, 0.30)
		_full_screen_shake(8.0, 0.38)
	elif money_delta > 0:
		AudioManager.play("money_gain")
		_pulse_node(top_labels.get("money", null), 1.08, 0.26)
	elif money_delta < 0:
		AudioManager.play("money_loss")
		_screen_flash(Color("#d73a49"), 0.12, 0.24)
	elif health_delta > 0 or mental_delta > 0 or int(effects.get("intelligence", 0)) > 0 \
			or int(effects.get("social_skill", 0)) > 0 or int(effects.get("investment_skill", 0)) > 0:
		AudioManager.play("stat_up")
		_screen_flash(Color("#34d399"), 0.10, 0.22)
	elif health_delta < 0 or mental_delta < 0:
		AudioManager.play("stat_down")
		_screen_flash(Color("#d73a49"), 0.10, 0.22)

func _screen_flash(color: Color, alpha: float = 0.16, duration: float = 0.3):
	if not is_instance_valid(_feedback_flash):
		return
	if _feedback_flash_tween and _feedback_flash_tween.is_running():
		_feedback_flash_tween.kill()
	_feedback_flash.color = Color(color.r, color.g, color.b, 1.0)
	_feedback_flash.modulate = Color(1, 1, 1, 0.0)
	_feedback_flash.visible = true
	_feedback_flash_tween = create_tween()
	_feedback_flash_tween.tween_property(_feedback_flash, "modulate:a", alpha, duration * 0.22)
	_feedback_flash_tween.tween_property(_feedback_flash, "modulate:a", 0.0, duration * 0.78)
	_feedback_flash_tween.tween_callback(func():
		if is_instance_valid(_feedback_flash):
			_feedback_flash.visible = false
		_feedback_flash_tween = null
	)

func _full_screen_shake(amount: float = 10.0, duration: float = 0.45):
	# story_container(메인 패널)를 흔들어서 화면 전체가 흔들리는 느낌
	if not is_instance_valid(_story_container):
		return
	var ctrl := _story_container as Control
	var base := ctrl.position
	var tw := create_tween()
	var steps := 8
	var cur_amt := amount
	for _i in range(steps):
		var offset := Vector2(randf_range(-cur_amt, cur_amt), randf_range(-cur_amt * 0.4, cur_amt * 0.4))
		tw.tween_property(ctrl, "position", base + offset, duration / float(steps))
		cur_amt *= 0.82  # 감쇠
	tw.tween_property(ctrl, "position", base, 0.06)

func _shake_node(node: Node, amount: float = 6.0, duration: float = 0.25):
	if not is_instance_valid(node) or not (node is Control):
		return
	var ctrl := node as Control
	var base := ctrl.position
	var tw := create_tween()
	var steps := 6
	for _i in range(steps):
		var offset := Vector2(randf_range(-amount, amount), randf_range(-amount * 0.45, amount * 0.45))
		tw.tween_property(ctrl, "position", base + offset, duration / float(steps))
	tw.tween_property(ctrl, "position", base, 0.04)

func _pulse_node(node: Variant, scale_to: float = 1.08, duration: float = 0.28):
	if not is_instance_valid(node) or not (node is Control):
		return
	var ctrl := node as Control
	var base := ctrl.scale
	ctrl.pivot_offset = ctrl.size * 0.5
	var tw := create_tween()
	tw.tween_property(ctrl, "scale", base * scale_to, duration * 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(ctrl, "scale", base, duration * 0.58).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _bind_tactile_button(button: Button, strength: float = 1.0) -> void:
	if not is_instance_valid(button) or button.has_meta("_tactile_bound"):
		return
	button.set_meta("_tactile_bound", true)
	var hover_scale := Vector2.ONE * (1.0 + 0.006 * strength)
	var press_scale := Vector2(1.0 - 0.010 * strength, 1.0 - 0.040 * strength)
	button.mouse_entered.connect(func():
		if not button.disabled:
			_tactile_button_to(button, hover_scale, 0.10, Tween.TRANS_QUAD)
	)
	button.focus_entered.connect(func():
		if not button.disabled:
			_tactile_button_to(button, hover_scale, 0.10, Tween.TRANS_QUAD)
	)
	button.button_down.connect(func():
		if not button.disabled:
			_tactile_button_to(button, press_scale, 0.055, Tween.TRANS_QUAD)
	)
	button.button_up.connect(func():
		if not button.disabled:
			_tactile_button_to(button, hover_scale if button.has_focus() else Vector2.ONE, 0.12, Tween.TRANS_BACK)
	)
	button.mouse_exited.connect(func():
		_tactile_button_to(button, Vector2.ONE, 0.12, Tween.TRANS_QUAD)
	)
	button.focus_exited.connect(func():
		_tactile_button_to(button, Vector2.ONE, 0.12, Tween.TRANS_QUAD)
	)

func _tactile_button_to(button: Button, target_scale: Vector2, duration: float, trans: int) -> void:
	if not is_instance_valid(button) or not is_inside_tree():
		return
	button.pivot_offset = button.size * 0.5
	var old: Variant = button.get_meta("_tactile_tween") if button.has_meta("_tactile_tween") else null
	if old is Tween and (old as Tween).is_running():
		(old as Tween).kill()
	var tw := create_tween()
	tw.bind_node(button)
	tw.tween_property(button, "scale", target_scale, duration).set_trans(trans).set_ease(Tween.EASE_OUT)
	button.set_meta("_tactile_tween", tw)

func _pulse_choice_surface() -> void:
	if is_instance_valid(choice_box):
		_pulse_node(choice_box, 1.006, 0.18)

func _spawn_coin_burst():
	var vp := get_viewport_rect().size
	var palette: Array[Color] = [Color("#f0b429"), Color("#e8e2d5"), Color("#8a6d2f")]
	for i in range(12):
		var shard := ColorRect.new()
		shard.color = palette[randi() % palette.size()]
		shard.size = Vector2(randf_range(8.0, 18.0), randf_range(2.0, 5.0))
		shard.pivot_offset = shard.size * 0.5
		var bx := vp.x * randf_range(0.35, 0.75)
		var by := vp.y * randf_range(0.35, 0.65)
		shard.position = Vector2(bx, by)
		shard.rotation = randf_range(-0.8, 0.8)
		shard.z_index = 200
		shard.mouse_filter = Control.MOUSE_FILTER_IGNORE
		shard.modulate.a = randf_range(0.72, 0.95)
		add_child(shard)
		var tw := create_tween()
		var rise := randf_range(-120.0, -60.0)
		var drift := randf_range(-40.0, 40.0)
		tw.tween_property(shard, "position", Vector2(bx + drift, by + rise), 0.9) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(shard, "rotation", shard.rotation + randf_range(-1.6, 1.6), 0.9) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(shard, "modulate:a", 0.0, 0.9) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_callback(shard.queue_free)

func _spawn_float(text: String, color: Color, index: int):
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", color)
	# 화면 중앙 우측 — 이벤트/행동 패널 위
	var vp = get_viewport_rect().size
	var base_x = vp.x * 0.58 + randf_range(-30.0, 30.0)
	var base_y = vp.y * 0.48 - index * 26.0
	lbl.position = Vector2(base_x, base_y)
	lbl.z_index = 200
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(lbl)
	# 위로 떠오르며 페이드아웃
	var tw = create_tween()
	tw.tween_property(lbl, "position:y", base_y - 70.0, 2.2).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 1.1).set_delay(1.1)
	tw.tween_callback(lbl.queue_free)

func _bar_str(value: int, max_val: int = 100, bars: int = 8) -> String:
	var filled = int(round(float(value) / float(max_val) * bars))
	filled = clampi(filled, 0, bars)
	return "█".repeat(filled) + "░".repeat(bars - filled)

## 그래픽 진행 바 (ColorRect) — 문자 블록보다 깔끔함.
## label + 진행바 + 값을 담은 VBox 반환.
func _make_progress_row(title: String, ratio: float, fill_color: String, value_text: String) -> Control:
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var top = HBoxContainer.new()
	var t = _label(title, 12, "#9aa4b8")
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(t)
	top.add_child(_label(value_text, 12, fill_color))
	box.add_child(top)

	# 바 트랙
	var track = PanelContainer.new()
	track.custom_minimum_size = Vector2(0, 10)
	var track_st = StyleBoxFlat.new()
	track_st.bg_color = Color("#1a1a26")
	track_st.set_corner_radius_all(5)
	track.add_theme_stylebox_override("panel", track_st)
	box.add_child(track)

	# 채움 — Control 안에 앵커로 비율 폭
	var fill_holder = Control.new()
	fill_holder.custom_minimum_size = Vector2(0, 10)
	track.add_child(fill_holder)
	var fill = ColorRect.new()
	fill.color = Color(fill_color)
	fill.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	fill.anchor_right = clampf(ratio, 0.0, 1.0)
	fill_holder.add_child(fill)
	return box

## AP 충전 애니메이션 — Citizen Sleeper의 다이스 등장과 같은 역할
## 각 AP 핍이 순서대로 깜빡이며 나타나 "새 기회 충전" 감각 전달
func _animate_ap_refill() -> void:
	if not top_labels.has("ap"):
		return
	var ap_lbl: Label = top_labels["ap"]
	var max_ap: int = GameState.max_action_points
	for pip_i in range(max_ap):
		var tw := create_tween()
		tw.tween_interval(pip_i * 0.12)
		tw.tween_callback(func():
			var filled: int = pip_i + 1
			ap_lbl.text = "%d/%d" % [filled, max_ap]
			ap_lbl.modulate = Color("#f4f7fb")
		)
		tw.tween_property(ap_lbl, "modulate", Color.WHITE, 0.15)
	# 최종 상태 보정
	var end_tw := create_tween()
	end_tw.tween_interval(max_ap * 0.12 + 0.2)
	end_tw.tween_callback(func():
		ap_lbl.text = "%d/%d" % [max_ap, max_ap]
		ap_lbl.modulate = Color.WHITE
	)

func _refresh_vitals():
	if not top_labels.has("vital_health"):
		return
	# 건강
	var hp = GameState.health
	var hp_bar = _bar_str(hp, 100, 6)
	var hp_color: Color
	if hp <= 30:
		hp_color = Color("#ff4444")
	elif hp <= 50:
		hp_color = Color("#b9bec7")
	else:
		hp_color = Color("#c8cdd4")
	var hp_lbl = top_labels["vital_health"]
	hp_lbl.text = "%d %s" % [hp, hp_bar]
	hp_lbl.add_theme_color_override("font_color", hp_color)
	if hp <= 15:
		_pulse_vital_critical(hp_lbl)
	elif hp <= 30:
		_pulse_vital_warning(hp_lbl)
	# 정신
	var mp = GameState.mental
	var mp_bar = _bar_str(mp, 100, 6)
	var mp_color: Color
	if mp <= 30:
		mp_color = Color("#ff4444")
	elif mp <= 50:
		mp_color = Color("#b9bec7")
	else:
		mp_color = Color("#c8cdd4")
	var mp_lbl = top_labels["vital_mental"]
	mp_lbl.text = "%d %s" % [mp, mp_bar]
	mp_lbl.add_theme_color_override("font_color", mp_color)
	if mp <= 15:
		_pulse_vital_critical(mp_lbl)
	elif mp <= 30:
		_pulse_vital_warning(mp_lbl)

func _pulse_vital_warning(lbl: Label) -> void:
	if not is_instance_valid(lbl):
		return
	var tw := create_tween()
	tw.tween_property(lbl, "modulate:a", 0.35, 0.4)
	tw.tween_property(lbl, "modulate:a", 1.0,  0.3)

## 위기 수준 펄스 — alpha + scale 동시 흔들림 (Hades 체력바 임박 플래시 참고)
func _pulse_vital_critical(lbl: Label) -> void:
	if not is_instance_valid(lbl):
		return
	var tw := create_tween()
	tw.set_loops(2)
	tw.tween_property(lbl, "modulate:a", 0.1, 0.2)
	tw.tween_property(lbl, "modulate:a", 1.0, 0.15)

func _set_stat_value(key: String, value: int, low_is_bad: bool, warn_thresh: int, danger_thresh: int):
	if not stat_labels.has(key):
		return
	var label = stat_labels[key]
	# 건강·정신 = 긴 바(10칸), 스킬류 = 짧은 바(5칸)으로 시각화
	var skill_stats := ["intelligence", "social_skill", "investment_skill", "luck", "appearance", "reputation"]
	if key in ["health", "mental"]:
		label.text = "%d  %s" % [value, _bar_str(value, 100, 10)]
	elif key in skill_stats:
		# 스킬 최대값 기준 80 (100 초과 가능하나 바는 80 기준)
		var bar_max := 80
		label.text = "%d  %s" % [value, _bar_str(clampi(value, 0, bar_max), bar_max, 5)]
	else:
		label.text = str(value)
	var is_danger: bool
	var is_warn: bool
	if low_is_bad:
		is_danger = value <= danger_thresh
		is_warn   = value <= warn_thresh and not is_danger
	else:
		is_danger = value >= danger_thresh
		is_warn   = value >= warn_thresh and not is_danger
	if is_danger:
		label.add_theme_color_override("font_color", Color("#ff4444"))
	elif is_warn:
		label.add_theme_color_override("font_color", Color("#f0b429"))
	else:
		label.add_theme_color_override("font_color", Color("#e8eaf0"))

func _render_news():
	for child in news_box.get_children():
		child.queue_free()
	news_box.add_child(_info_section_title(_tr("시장 뉴스", "Market News"), "#f97316"))
	var items = GameState.news_log.slice(max(0, GameState.news_log.size() - 4))
	if items.is_empty():
		news_box.add_child(_info_empty_card(_tr("아직 들어온 뉴스가 없습니다.", "No news yet."), "#64748b"))
	for news in items:
		var text = str(news.get("headline", "")).format({"topic": _random_topic(news)})
		var misleading = bool(news.get("misleading", false))
		var effect: Dictionary = news.get("market_effect", news.get("market_effects", {}))
		var power = float(effect.get("power", 0.0))
		var color = "#8892a4"
		var label_text = _tr("중립", "Neutral")
		if misleading:
			color = "#5a6075"
			label_text = _tr("루머", "Rumor")
		elif power >= 0.04:
			color = "#00c896"
			label_text = _tr("강한 호재", "Strong Up")
		elif power >= 0.01:
			color = "#6ee7b7"
			label_text = _tr("호재", "Up")
		elif power <= -0.04:
			color = "#ff6b6b"
			label_text = _tr("강한 악재", "Strong Down")
		elif power <= -0.01:
			color = "#fca5a5"
			label_text = _tr("악재", "Down")
		var muted_color := _info_signal_hex(color)
		var card: PanelContainer = _info_card(color, "#0b0f16")
		var box: VBoxContainer = VBoxContainer.new()
		box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		box.add_theme_constant_override("separation", 5)
		card.add_child(box)
		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		box.add_child(row)
		var tag: Label = _label(label_text, 13, muted_color)
		if _font_bold:
			tag.add_theme_font_override("font", _font_bold)
		tag.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(tag)
		var impact: Label = _label("%+.1f%%" % (power * 100.0), 13, muted_color)
		impact.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(impact)
		box.add_child(_wrap_label(text, 14, "#c8d0df"))
		news_box.add_child(card)

func _render_sidebars():
	# ── 시세 패널: RichTextLabel 단일 업데이트 ──
	if ticker_rtl:
		var lines: PackedStringArray = PackedStringArray()
		lines.append("[color=%s][b]MARKET TICKER[/b][/color]" % _info_signal_hex("#3fb950"))
		for row in investment_system.get_asset_rows().slice(0, 12):
			var asset_id = row["id"]
			var price = float(row["price"])
			var old_price = float(prev_prices.get(asset_id, price))
			var change_pct = 0.0
			if old_price > 0.0:
				change_pct = (price - old_price) / old_price * 100.0
			var pct_str = ""
			var color = "#8892a4"
			if change_pct > 0.05:
				pct_str = " +%.1f%%" % change_pct
				color = "#00c896"
			elif change_pct < -0.05:
				pct_str = " %.1f%%" % change_pct
				color = "#ff4444"
			var owned_str = ""
			if float(row["owned_value"]) > 0:
				owned_str = "  [color=%s]• %s[/color]" % [_info_signal_hex("#c9a227"), GameState.format_money(row["owned_value"])]
			var risk_dots = "●".repeat(int(row.get("risk_level", 1))) + "○".repeat(5 - int(row.get("risk_level", 1)))
			# 6개월 미니 스파크라인
			var spark_hist: Array = GameState.price_history.get(asset_id, [])
			var mini_spark = ""
			if spark_hist.size() >= 2:
				mini_spark = "  " + _price_sparkline(spark_hist.slice(max(0, spark_hist.size() - 6)))
			lines.append("[color=%s]%s  %s%s%s  %s%s[/color]" % [_info_signal_hex(color), row["name"], GameState.format_money(price), pct_str, owned_str, risk_dots, mini_spark])
		ticker_rtl.clear()
		ticker_rtl.append_text("\n".join(lines))

	_clear_box(relationship_box)
	relationship_box.add_child(_info_section_title(_tr("내 사람들", "Relationships"), "#d8b4fe"))
	if GameState.relationships.is_empty():
		relationship_box.add_child(_info_empty_card(_tr("아직 중요한 인연이 없습니다. 관계 행동이나 스토리 진행으로 인물이 기록됩니다.", "No important relationships yet. People appear here through relationship actions or story progress."), "#64748b"))
	for rel in GameState.relationships:
		var affection = int(rel.get("affection", 40))
		var trust = int(rel.get("trust", 40))
		var type_str = str(rel.get("type", "friends"))
		var type_kr: String = _relationship_type_label(type_str)
		var accent: String = _relationship_type_color(type_str)
		var affinity = relationship_system.get_affinity_label(affection)
		var card: PanelContainer = _info_card(accent, "#0d1018")
		var box: VBoxContainer = VBoxContainer.new()
		box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		box.add_theme_constant_override("separation", 8)
		card.add_child(box)
		var title_row: HBoxContainer = HBoxContainer.new()
		title_row.add_theme_constant_override("separation", 8)
		box.add_child(title_row)
		var name_lbl: Label = _label(str(rel.get("name", "?")), 16, "#e8eaf0")
		if _font_bold:
			name_lbl.add_theme_font_override("font", _font_bold)
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_row.add_child(name_lbl)
		var type_lbl: Label = _label(type_kr, 13, accent)
		type_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		title_row.add_child(type_lbl)
		box.add_child(_wrap_label(str(affinity), 13, "#a8b3c7"))
		box.add_child(_info_value_bar(_tr("호감도", "Affinity"), affection, 100, accent))
		box.add_child(_info_value_bar(_tr("신뢰", "Trust"), trust, 100, "#93c5fd"))
		if affection >= 45:
			var effect_hint = _rel_effect_hint(type_str, affection, trust)
			if not effect_hint.is_empty():
				box.add_child(_wrap_label(effect_hint, 13, "#8f9ab0"))
		relationship_box.add_child(card)

	_clear_box(inventory_box)
	inventory_box.add_child(_info_section_title(_tr("소지품 · 유물", "Keepsakes"), "#fbbf24"))
	if GameState.inventory.is_empty():
		inventory_box.add_child(_info_empty_card(_tr("아직 아무것도 없다.\n이야기 속에서 받거나 남긴 것들이 여기 남는다.", "Nothing yet.\nThings given or left behind through the story collect here."), "#64748b"))
	for item in GameState.inventory:
		var item_card: PanelContainer = _info_card("#fbbf24", "#0d1018")
		var item_box: VBoxContainer = VBoxContainer.new()
		item_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		item_box.add_theme_constant_override("separation", 8)
		item_card.add_child(item_box)
		var item_row: HBoxContainer = HBoxContainer.new()
		item_row.add_theme_constant_override("separation", 8)
		item_box.add_child(item_row)
		var item_label: Label = _label("%s x%d" % [item.get("name", _tr("아이템", "Item")), item.get("quantity", 1)], 15, "#e8eaf0")
		if _font_bold:
			item_label.add_theme_font_override("font", _font_bold)
		item_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		item_row.add_child(item_label)
		var has_immediate = not item.get("effects", {}).is_empty()
		var effect_parts: Array = []
		for k in item.get("effects", {}):
			var v: int = int(item["effects"][k])
			var sign: String = "+" if v >= 0 else ""
			effect_parts.append("%s %s%d" % [_stat_name(k), sign, v])
		for k in item.get("passive_effects", {}):
			var v2: int = int(item["passive_effects"][k])
			var sign2: String = "+" if v2 >= 0 else ""
			effect_parts.append(_tr("매달 %s %s%d", "monthly %s %s%d") % [_stat_name(k), sign2, v2])
		if not effect_parts.is_empty():
			item_box.add_child(_wrap_label(", ".join(effect_parts), 13, _info_signal_hex("#fbbf24")))
		if has_immediate:
			var use_btn = _small_button(_tr("사용 AP 1", "Use AP 1"), "#0f766e")
			if GameState.action_points <= 0:
				use_btn.disabled = true
			use_btn.pressed.connect(Callable(self, "_on_use_item").bind(item.get("id", "")))
			item_box.add_child(use_btn)
		else:
			item_box.add_child(_wrap_label(_tr("자동 활성", "Auto-active"), 13, "#34d399"))
		inventory_box.add_child(item_card)

	_refresh_arc_box()

func _on_start_thought(thought_id: String) -> void:
	if GameState.start_thought(thought_id):
		_refresh_arc_box()

func _refresh_arc_box() -> void:
	if not is_instance_valid(arc_box): return
	_clear_box(arc_box)
	arc_box.add_child(_info_section_title(_tr("스토리 아크", "Story Arcs"), "#86e4c0"))
	var f: Dictionary = GameState.flags
	var t: int = GameState.turn

	# ── 아크 정의: {name, icon, stages: [{label, done_flag, hint}], done_flag} ──
	var arcs := [
		{
			"name": _tr("김다은", "Kim Daeun"),
			"icon": "💙",
			"active": f.get("met_daeun", false),
			"done": f.get("arc_daeun_04_seen", false) or f.get("arc_daeun_ghost_seen", false),
			"stages": [
				{"label": _tr("첫 만남", "First Meeting"), "done": f.get("arc_daeun_01_seen", false)},
				{"label": _tr("거리 둠 / 가까워짐", "Distance / Closeness"), "done": f.get("arc_daeun_regular_seen", false)},
				{"label": _tr("기로", "Crossroads"), "done": f.get("arc_daeun_fork_seen", false)},
				{"label": _tr("결말", "Conclusion"), "done": f.get("arc_daeun_04_seen", false) or f.get("arc_daeun_ghost_seen", false)},
			],
			"hint": (_tr("T3+ 조건 충족 시 시작", "Starts when T3+ conditions met")) if not f.get("met_daeun", false) else "",
		},
		{
			"name": _tr("임상철 (인맥·투자)", "Im Sangchul (Network · Invest)"),
			"icon": "🤝",
			"active": f.get("arc_sangchul_met_seen", false),
			"done": f.get("arc_sangchul_03_seen", false),
			"stages": [
				{"label": _tr("첫 만남", "First Meeting"), "done": f.get("arc_sangchul_met_seen", false)},
				{"label": _tr("투자 조언", "Investment Advice"), "done": f.get("arc_invest_guidance_seen", false)},
				{"label": _tr("두 번째 커피", "Second Coffee"), "done": f.get("arc_sangchul_02_seen", false)},
				{"label": _tr("네트워크 입성 (자산 100만+ 필요)", "Join Network (KRW 1M+ assets needed)"), "done": f.get("arc_sangchul_03_seen", false)},
			],
			"hint": (_tr("자산 100만원 이상이면 다음 단계 진행 가능", "KRW 1M+ assets unlocks the next step") if f.get("arc_sangchul_02_seen", false) and not f.get("arc_sangchul_03_seen", false) and GameState.get_total_asset_value() < 1_000_000 else _tr("10개월차 이후 자동 만남", "Auto-meeting after month 10")) if not f.get("arc_sangchul_met_seen", false) else "",
		},
		{
			"name": _tr("강현수 (친구)", "Kang Hyunsu (Friend)"),
			"icon": "🍺",
			"active": f.get("arc_intro_hyunsu_seen", false),
			"done": f.get("arc_jaehyuk_hyunsu_warning_seen", false),
			"stages": [
				{"label": _tr("옆방 라면", "Ramen Next Door"), "done": f.get("arc_intro_hyunsu_seen", false)},
				{"label": _tr("그의 경고", "His Warning"), "done": f.get("arc_jaehyuk_hyunsu_warning_seen", false)},
			],
			"hint": "",
		},
		{
			"name": _tr("한지연 (투자·로맨스)", "Han Jiyeon (Invest · Romance)"),
			"icon": "💎",
			"active": f.get("arc_jiyeon_crash_seen", false),
			"done": f.get("arc_jiyeon_truth_seen", false) or f.get("arc_jiyeon_epilogue_seen", false),
			"stages": [
				{"label": _tr("접촉 (5개월차+)", "Contact (month 5+)"), "done": f.get("arc_jiyeon_crash_seen", false)},
				{"label": _tr("재회 (7개월차+)", "Reunion (month 7+)"), "done": f.get("arc_jiyeon_store_seen", false)},
				{"label": _tr("연결 (9개월차+)", "Connection (month 9+)"), "done": f.get("arc_jiyeon_offer_seen", false)},
				{"label": _tr("그녀의 세계 (10개월차+)", "Her World (month 10+)"), "done": f.get("arc_jiyeon_03b_seen", false)},
				{"label": _tr("진실", "Truth"), "done": f.get("arc_jiyeon_truth_seen", false)},
				{"label": _tr("Y4 부산 전화", "Y4 Busan Call"), "done": f.get("arc_jiyeon_year4_call_seen", false)},
				{"label": _tr("Y4 서울 방문", "Y4 Seoul Visit"), "done": f.get("arc_jiyeon_year4_seoul_seen", false)},
				{"label": _tr("Y5 마지막", "Y5 Finale"), "done": f.get("arc_jiyeon_year5_return_seen", false) or f.get("arc_jiyeon_year5_news_seen", false)},
			],
			"hint": _tr("5개월차 이후 자동 등장", "Auto-appears after month 5") if not f.get("arc_jiyeon_crash_seen", false) else "",
		},
		{
			"name": _tr("아버지", "Father"),
			"icon": "👨",
			"active": f.get("arc_father_01_seen", false),
			"done": f.get("arc_father_05_seen", false) or f.get("father_reconciled", false),
			"stages": [
				{"label": _tr("전화", "Phone Call"), "done": f.get("arc_father_01_seen", false)},
				{"label": _tr("이상 신호", "Warning Sign"), "done": f.get("arc_father_02_done", false)},
				{"label": _tr("병원 소식", "Hospital News"), "done": f.get("arc_father_03_seen", false)},
				{"label": _tr("방문", "Visit"), "done": f.get("visited_father", false)},
				{"label": _tr("화해 / 여운", "Reconciliation / Aftermath"), "done": f.get("arc_father_05_seen", false)},
			],
			"hint": "",
		},
		{
			"name": _tr("최재혁 (군대 동기)", "Choi Jaehyuk (Army Buddy)"),
			"icon": "⚠️",
			"active": f.get("arc_jaehyuk_reunion_seen", false),
			"done": f.get("arc_jaehyuk_aftermath_seen", false),
			"stages": [
				{"label": _tr("재회 (19개월차+)", "Reunion (month 19+)"), "done": f.get("arc_jaehyuk_reunion_seen", false)},
				{"label": _tr("유대", "Bond"), "done": f.get("arc_jaehyuk_bond_seen", false)},
				{"label": _tr("투자 제안", "Investment Pitch"), "done": f.get("arc_jaehyuk_pitch_seen", false)},
				{"label": _tr("도주 / 반격", "Flight / Counter"), "done": f.get("arc_jaehyuk_ghost_seen", false) or f.get("arc_jaehyuk_counter_seen", false)},
				{"label": _tr("사후처리", "Aftermath"), "done": f.get("arc_jaehyuk_aftermath_seen", false)},
			],
			"hint": _tr("19개월차 이후 자동 등장", "Auto-appears after month 19") if not f.get("arc_jaehyuk_reunion_seen", false) else "",
		},
		{
			"name": _tr("성향 자각 & 전문화", "Tendency Awareness & Specialization"),
			"icon": "⭐",
			"active": not GameState.tendency_realized.is_empty() or f.get("pending_spec_career", false) or f.get("pending_spec_invest", false) or f.get("pending_spec_found", false),
			"done": f.has("spec_elite") or f.has("spec_social_climber") or f.has("spec_quant") or f.has("spec_speculator") or f.has("spec_tech_founder") or f.has("spec_social_entrepreneur"),
			"stages": [
				{"label": _tr("성향 누적 중", "Tendency Building"), "done": not GameState.tendency_realized.is_empty()},
				{"label": _tr("전문화 선택", "Specialization Choice"), "done": f.has("spec_elite") or f.has("spec_social_climber") or f.has("spec_quant") or f.has("spec_speculator") or f.has("spec_tech_founder") or f.has("spec_social_entrepreneur")},
			],
			"hint": _tr("직장/투자/창업 성향 15 이상 달성 시 발동", "Triggers at 15+ Career/Invest/Startup tendency"),
		},
	]

	var any_active: bool = false
	for arc in arcs:
		if not bool(arc.get("active", false)) and not bool(arc.get("done", false)):
			continue
		any_active = true
		var done_all: bool = bool(arc.get("done", false))
		var hdr_color: String = "#5a6a6a" if done_all else "#86e4c0"
		var stages: Array = arc.get("stages", [])
		var done_count: int = 0
		for stage in stages:
			if bool(stage.get("done", false)):
				done_count += 1
		var card: PanelContainer = _info_card(hdr_color, "#0d1018")
		var box: VBoxContainer = VBoxContainer.new()
		box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		box.add_theme_constant_override("separation", 8)
		card.add_child(box)
		var header: HBoxContainer = HBoxContainer.new()
		header.add_theme_constant_override("separation", 8)
		box.add_child(header)
		var name_lbl: Label = _label(str(arc["name"]), 15, "#e8eaf0" if not done_all else "#94a3b8")
		if _font_bold:
			name_lbl.add_theme_font_override("font", _font_bold)
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		header.add_child(name_lbl)
		var status_lbl: Label = _label(_tr("완료", "Done") if done_all else "%d/%d" % [done_count, stages.size()], 13, hdr_color)
		status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		header.add_child(status_lbl)
		var progress_text: String = "■".repeat(done_count) + "□".repeat(maxi(stages.size() - done_count, 0))
		box.add_child(_label(progress_text, 14, hdr_color))
		for stage in stages:
			var done: bool = bool(stage.get("done", false))
			var prefix: String = _tr("완료", "Done") if done else _tr("대기", "Pending")
			var color: String = "#4a5a4a" if done else "#8ab4a0"
			box.add_child(_wrap_label("%s  %s" % [prefix, str(stage["label"])], 13, color))
		var hint: String = str(arc.get("hint", ""))
		if not hint.is_empty() and not done_all:
			box.add_child(_wrap_label(hint, 13, "#5fa080"))
		arc_box.add_child(card)

	if not any_active:
		arc_box.add_child(_info_empty_card(_tr("아직 발동된 아크가 없습니다. 이야기가 흘러가면 여기에 기록됩니다.", "No arcs yet. As the story unfolds, they will be tracked here."), "#64748b"))

	# ── 단서 / 생각 정리 (추리·분석) ──────────────────────────
	arc_box.add_child(_info_section_title(_tr("단서 / 생각 정리", "Clues / Deductions"), "#c8a96a"))
	# 정리 중인 생각
	if not GameState.active_thought.is_empty():
		var at_id: String = str(GameState.active_thought.get("id", ""))
		var at: Dictionary = DataRegistry.get_thought(at_id)
		var left: int = int(GameState.active_thought.get("turns_left", 0))
		var at_card: PanelContainer = _info_card("#c8a96a", "#0d1018")
		var at_box: VBoxContainer = VBoxContainer.new()
		at_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		at_box.add_theme_constant_override("separation", 6)
		at_card.add_child(at_box)
		at_box.add_child(_label(_tr("정리 중: %s", "Working it out: %s") % str(at.get("title", at_id)), 14, "#e8d3a0"))
		at_box.add_child(_wrap_label(_tr("%d주 남음 — 생각이 무르익는 중", "%d weeks left — still taking shape") % left, 13, "#a89668"))
		arc_box.add_child(at_card)
	# 정리 가능한 생각 (필요 단서 충족)
	var avail_thoughts: Array = GameState.available_thoughts()
	for th in avail_thoughts:
		var tid: String = str(th.get("id", ""))
		var t_card: PanelContainer = _info_card("#d4af6a", "#0d1018")
		var t_box: VBoxContainer = VBoxContainer.new()
		t_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		t_box.add_theme_constant_override("separation", 6)
		t_card.add_child(t_box)
		t_box.add_child(_label(str(th.get("title", tid)), 15, "#f0d9a8"))
		t_box.add_child(_wrap_label(str(th.get("description", "")), 13, "#b8a878"))
		var turns: int = int(th.get("processing_turns", 1))
		var start_btn: Button = _small_button(_tr("생각 정리 시작 (%d주)", "Start working it out (%d wk)") % turns, "#5a4a1e")
		if not GameState.active_thought.is_empty():
			start_btn.disabled = true
		start_btn.pressed.connect(Callable(self, "_on_start_thought").bind(tid))
		t_box.add_child(start_btn)
		arc_box.add_child(t_card)
	# 완료한 생각 (결론)
	for tid2 in GameState.thoughts_done:
		var t2: Dictionary = DataRegistry.get_thought(str(tid2))
		var d_card: PanelContainer = _info_card("#5a6a6a", "#0d1018")
		var d_box: VBoxContainer = VBoxContainer.new()
		d_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		d_box.add_theme_constant_override("separation", 4)
		d_card.add_child(d_box)
		d_box.add_child(_label(_tr("결론: %s", "Concluded: %s") % str(t2.get("title", tid2)), 13, "#94a3b8"))
		arc_box.add_child(d_card)
	# 수집한 단서
	if GameState.clues.is_empty():
		arc_box.add_child(_info_empty_card(_tr("아직 모은 단서가 없습니다. 대화와 선택 속에서 조각이 쌓입니다.", "No clues yet. Fragments accumulate through conversations and choices."), "#64748b"))
	else:
		for cid in GameState.clues:
			var c: Dictionary = DataRegistry.get_clue(str(cid))
			var c_card: PanelContainer = _info_card("#7a8a5a", "#0d1018")
			var c_box: VBoxContainer = VBoxContainer.new()
			c_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			c_box.add_theme_constant_override("separation", 4)
			c_card.add_child(c_box)
			c_box.add_child(_label(str(c.get("title", cid)), 14, "#cdd9a8"))
			c_box.add_child(_wrap_label(str(c.get("text", "")), 12, "#9aa888"))
			arc_box.add_child(c_card)

	# 런 테마 표시
	arc_box.add_child(_info_section_title(_tr("런 정보", "Run Info"), "#5a9ac8"))
	var theme_id: String = GameState.run_theme
	var run_card: PanelContainer = _info_card("#5a9ac8", "#0d1018")
	var run_box: VBoxContainer = VBoxContainer.new()
	run_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	run_box.add_theme_constant_override("separation", 6)
	run_card.add_child(run_box)
	run_box.add_child(_wrap_label(_tr("테마: %s", "Theme: %s") % _run_theme_display(theme_id), 14, "#8fb6d8"))
	var tendency_lbl := GameState.get_tendency_label()
	if not tendency_lbl.is_empty():
		run_box.add_child(_wrap_label(_tr("성향: %s", "Leaning: %s") % tendency_lbl, 14, "#8fb6d8"))
	# 마스터리 표시
	var mg_line: String = ""
	for gid in ["holdem", "racetrack", "scalping", "aruba"]:
		var grade: int = MetaProgression.get_mastery(gid)
		if grade > 0:
			mg_line += "%s:%s  " % [gid, MetaProgression.get_mastery_label(gid)]
	if not mg_line.is_empty():
		run_box.add_child(_wrap_label(_tr("미니게임: ", "Minigame: ") + mg_line.strip_edges(), 13, "#5fa080"))
	arc_box.add_child(run_card)

func _render_log():
	var lines: Array = []
	var type_colors = {
		"event": "#93c5fd",
		"trade": "#00c896",
		"job": "#fbbf24",
		"item": "#d8b4fe",
		"market": "#5a6075",
		"relationship": "#f9a8d4",
		"system": "#64748b",
		"money": "#f0b429",
	}
	for entry in GameState.action_log.slice(max(0, GameState.action_log.size() - 16)):
		var t = entry.get("type", "system")
		var color: String = _info_signal_hex(str(type_colors.get(t, "#5a6075")))
		var date_str: String = _escape_bbcode_text(entry.get("date", ""))
		var msg: String = _escape_bbcode_text(_clean_log_surface_text(entry.get("message", "")))
		lines.append("[color=%s][%s] %s[/color]" % [color, date_str, msg])
	log_box.text = "\n".join(lines)

func _render_ap_actions():
	_play_ink_transition("ap", 0.55)
	next_button.disabled = false
	_transient_bg_active = false
	_clear_category_tint(true)
	_clear_feedback_flash()
	_update_vignette()
	_update_event_bg()
	for child in choice_box.get_children():
		child.queue_free()
	var ap = GameState.action_points
	var ap_dots = "◆".repeat(ap) + "◇".repeat(max(0, GameState.max_action_points - ap))
	if top_labels.has("ap"):
		top_labels["ap"].text = "%s  %d/%d" % [ap_dots, ap, GameState.max_action_points]
	event_title.text = _tr("%d년 %d월 %d주차", "%d-%02d W%d") % [GameState.year, GameState.month, GameState.week_of_month]
	_maybe_show_tutorial()

	# ── 상황판 ────────────────────────────────────────────────────
	var net = GameState.monthly_income - GameState.get_housing_expense()
	var total = GameState.get_total_asset_value()
	var lines: PackedStringArray = PackedStringArray()
	# 분위기 내레이션 한 줄 (비주얼노벨 톤)
	lines.append("[i]%s[/i]" % _month_narration())
	if not turn_action_log.is_empty():
		lines.append(_ap_recent_action_line())
	# 월 현금흐름/마일스톤/목표까지의 압박은 아래 'This Week' 카드로 모아
	# 첫 AP 화면이 계산표처럼 시작하지 않게 한다.
	# ── 경고 ──
	var has_warning := false
	if GameState.current_job.is_empty():
		lines.append(_tr("[color=#ff7070]직업 없음[/color]  — 수입 0원. 구직활동을 먼저 하세요!", "[color=#ff7070]No job[/color]  — KRW 0 income. Do a Job Hunt first!"))
		has_warning = true
	if GameState.health <= 45:
		lines.append(_tr("[color=#ff4444]건강 %d / 100[/color]  — 위험!", "[color=#ff4444]Health %d / 100[/color]  — Danger!") % GameState.health)
		has_warning = true
	if GameState.mental <= 45:
		lines.append(_tr("[color=#ff4444]정신력 %d / 100[/color]  — 위험!", "[color=#ff4444]Mental %d / 100[/color]  — Danger!") % GameState.mental)
		has_warning = true
	if GameState.mental <= 55 and GameState.health > 45 and GameState.mental > 45:
		lines.append(_tr("[color=#b9bec7]정신력 %d[/color]  — 피로가 쌓이고 있습니다. 가끔 쉬세요.", "[color=#b9bec7]Mental %d[/color]  — Fatigue is building up. Rest sometimes.") % GameState.mental)
		has_warning = true
	if GameState.money < 0:
		lines.append(_tr("[color=#ff4444]잔고 마이너스  %s[/color]  — 빚이 생겼습니다!", "[color=#ff4444]Negative balance  %s[/color]  — You're in debt!") % GameState.format_money(GameState.money))
		has_warning = true
	# 추천 행동은 아래 '이번 주' 포커스 카드에서 더 크게 보여준다.
	# 새 주 첫 상황판은 짧게 타이핑 (60cps — 빠르게)
	var body_text := "\n".join(lines)
	# 위기 상황 내레이션에 wave 적용 (첫 줄이 이탤릭 내레이션)
	if GameState.mental <= 45 or GameState.money < 0:
		body_text = body_text.replace("[i]", "[i][wave amp=2.5 freq=1.8]") \
							 .replace("[/i]", "[/wave][/i]")
	_type_text(body_text, 60.0)

	var disabled = (ap <= 0)
	var has_paycheck: bool = GameState.flags.get("has_received_paycheck", false)
	var no_job = GameState.current_job.is_empty()
	var job_story_unlocked: bool = GameState.flags.get("story_job_unlocked", false)
	var warn_body = GameState.health <= 45 or GameState.mental <= 45

	# ── 행동력 소진 시 다음 달 버튼 강조 ──────────────
	if disabled:
		next_button.text = _tr("다음 주로 ›", "To Next Week ›")
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color("#10151a")
		btn_style.border_color = Color("#dce6ee")
		btn_style.border_width_left = 3
		btn_style.set_corner_radius_all(4)
		btn_style.content_margin_left = 20
		btn_style.content_margin_right = 20
		btn_style.content_margin_top = 8
		btn_style.content_margin_bottom = 8
		next_button.add_theme_stylebox_override("normal", btn_style)
		next_button.add_theme_color_override("font_color", Color("#f4f7fb"))
		next_button.call_deferred("grab_focus")
	else:
		next_button.text = _tr("다음 주 ›", "Next Week ›")
		next_button.remove_theme_stylebox_override("normal")
		next_button.remove_theme_color_override("font_color")

	# ── 튜토리얼 힌트 (1줄, 스타일박스 없음) ──────────
	var hint_text = ""
	var hint_color = "#b9bec7"
	var job_story_done: bool = GameState.flags.get("story_job_unlocked", false)
	var just_got_paycheck = GameState.flags.get("has_received_paycheck", false) \
		and not GameState.flags.get("invest_hint_shown", false)

	if GameState.turn == 1 and ap == GameState.max_action_points and turn_action_log.is_empty():
		hint_text = _tr("이번 주 상황에 반응하거나, 아래 [구직활동]으로 일자리부터 구하세요.", "React to this week's situation, or get a job first via [Job Hunt] below.")
		hint_color = "#c8cdd4"
	elif GameState.tutorial_step >= 1 and job_story_done and no_job:
		hint_text = _tr("수입 0원 — 아래 [구직활동]으로 취업하세요!", "KRW 0 income — get a job via [Job Hunt] below!")
		hint_color = "#ef4444"
	elif just_got_paycheck:
		GameState.flags["invest_hint_shown"] = true
		hint_text = _tr("첫 월급 수령 — 이제 투자 메뉴가 열렸습니다.", "First paycheck received — Invest is now available.")
		hint_color = "#c8cdd4"
	elif GameState.tutorial_step == 0 and GameState.turn <= 4:
		hint_text = _tr("목표: 자산 30억 → 강남 입성 (남은 시간 %d년)", "Goal: KRW 3B assets → reach Seoul's status district (%d years left)") % max(0, 38 - GameState.age)
		hint_color = "#b9bec7"

	_render_week_focus_panel(ap, net, total, has_warning, hint_text, hint_color)

	# ══════════════════════════════════════════════════════
	# 상황 카드 — 매 턴 '이번 달 상황'에 반응. (추상 메뉴 대체)
	# ══════════════════════════════════════════════════════
	_render_situation_cards()

	# ── 패드 힌트 (컨트롤러 연결 시에만 표시) ───────────────
	if ControllerHints.is_pad_active():
		_add_ap_controller_hint_strip(disabled)
	_apply_ap_focus_routes(disabled)

	# ── 상점 버튼 비활성화 (서사 유물로 전환 예정) ─────────────
	if shop_button:
		shop_button.disabled = true
	_apply_moral_ui_palette()

func _ap_recent_action_line() -> String:
	if turn_action_log.is_empty():
		return ""
	var parts: PackedStringArray = PackedStringArray()
	var start_idx: int = maxi(0, turn_action_log.size() - 3)
	for i in range(start_idx, turn_action_log.size()):
		var item: String = _clean_log_surface_text(str(turn_action_log[i])).strip_edges()
		item = item.replace("•", "").strip_edges()
		if item.length() > 34:
			item = item.substr(0, 33).strip_edges() + "…"
		if not item.is_empty():
			parts.append(_escape_bbcode_text(item))
	if parts.is_empty():
		return ""
	return _tr("[color=#7f8794]이번 주:[/color] %s", "[color=#7f8794]This week:[/color] %s") % "  ·  ".join(parts)

func _apply_ap_focus_routes(ap_empty: bool) -> void:
	if not ControllerHints.is_pad_active():
		return
	var buttons: Array[Button] = []
	for child in choice_box.get_children():
		if child is Button:
			var btn := child as Button
			if btn.visible and not btn.disabled and btn.focus_mode != Control.FOCUS_NONE:
				buttons.append(btn)
	for i in range(buttons.size()):
		var btn := buttons[i]
		var top := buttons[maxi(0, i - 1)]
		var bottom := buttons[mini(buttons.size() - 1, i + 1)]
		btn.focus_neighbor_top = btn.get_path_to(top)
		btn.focus_neighbor_bottom = btn.get_path_to(bottom)
		btn.focus_neighbor_left = btn.get_path_to(btn)
		btn.focus_neighbor_right = btn.get_path_to(btn)
		btn.focus_previous = btn.get_path_to(top)
		btn.focus_next = btn.get_path_to(bottom)
	if ap_empty:
		if is_instance_valid(next_button) and not next_button.disabled:
			next_button.call_deferred("grab_focus")
	elif not buttons.is_empty():
		buttons[0].call_deferred("grab_focus")

func _add_ap_controller_hint_strip(ap_empty: bool) -> void:
	var strip := PanelContainer.new()
	strip.set_meta("moral_role", "separator")
	strip.set_meta("moral_accent", "#7f8794")
	strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#07080b", 0.72)
	st.border_color = Color("#252b35", 0.86)
	st.set_border_width_all(1)
	st.set_corner_radius_all(2)
	st.content_margin_left = 10
	st.content_margin_right = 10
	st.content_margin_top = 6
	st.content_margin_bottom = 6
	strip.add_theme_stylebox_override("panel", st)
	choice_box.add_child(strip)

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 8)
	strip.add_child(row)

	var title := _label(_tr("패드", "PAD"), 10, "#7f8794")
	title.set_meta("moral_role", "hint_text")
	title.custom_minimum_size = Vector2(42, 0)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if _font_bold:
		title.add_theme_font_override("font", _font_bold)
	row.add_child(title)

	var body_text: String
	if ap_empty:
		body_text = _tr(
			"[%s] 확인 · [%s] 다음 주 · [%s] 메뉴",
			"[%s] Confirm · [%s] Next Week · [%s] Menu"
		) % [ControllerHints.south(), ControllerHints.r3(), ControllerHints.start_btn()]
	else:
		body_text = _tr(
			"↑↓ 행동 슬롯 · [%s] 선택 · [%s/%s] 탭 · [%s] 메뉴",
			"↑↓ Action Slot · [%s] Choose · [%s/%s] Tabs · [%s] Menu"
		) % [ControllerHints.south(), ControllerHints.shoulder_l(), ControllerHints.shoulder_r(), ControllerHints.start_btn()]
	var body := _label(body_text, 12, "#aeb6c8")
	body.set_meta("moral_role", "hint_text")
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(body)

func _render_week_focus_panel(ap: int, net: float, total: float, has_warning: bool,
		hint_text: String = "", hint_color: String = "#b9bec7") -> void:
	var card := PanelContainer.new()
	card.set_meta("moral_role", "info_card")
	card.set_meta("moral_accent", "#c5ccd5")
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(0, 142)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#08090d", 0.96)
	style.border_color = Color("#343a45")
	style.border_width_left = 0
	style.border_width_bottom = 2
	style.set_border_width(SIDE_TOP, 1)
	style.set_border_width(SIDE_RIGHT, 1)
	style.set_corner_radius_all(3)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	card.add_theme_stylebox_override("panel", style)
	choice_box.add_child(card)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(box)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 10)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(top)

	var title_col := VBoxContainer.new()
	title_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_col.add_theme_constant_override("separation", 1)
	top.add_child(title_col)

	var eyebrow := _label(_tr("주간 계획", "WEEK PLAN"), 10, "#7f8794")
	eyebrow.set_meta("moral_role", "hint_text")
	eyebrow.uppercase = true
	title_col.add_child(eyebrow)

	var title := _label(_tr("이번 주 압박", "This Week's Pressure"), 17, "#eef3f8")
	title.set_meta("moral_role", "choice_title")
	if _font_bold:
		title.add_theme_font_override("font", _font_bold)
	title_col.add_child(title)

	var slots_box := VBoxContainer.new()
	slots_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slots_box.custom_minimum_size = Vector2(92, 0)
	top.add_child(slots_box)
	_add_week_ap_slots(slots_box, ap)

	var ap_text := _tr("선택 완료", "Choices spent")
	if ap > 0:
		ap_text = _tr("선택 %d개 남음", "%d choices left") % ap
	var ap_lbl := _label(ap_text, 13, "#f4f7fb" if ap > 0 else "#7a8496")
	ap_lbl.custom_minimum_size = Vector2(118, 0)
	ap_lbl.clip_text = false
	ap_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top.add_child(ap_lbl)

	_render_week_pressure_row(box, net, total, has_warning)

	if not hint_text.is_empty():
		var hint_lbl := _wrap_label(hint_text, 13, hint_color)
		hint_lbl.set_meta("moral_role", "hint_text")
		box.add_child(hint_lbl)

	var focus_text := _tr("먼저 위험 신호를 줄여야 한다.", "Stabilize the immediate risk first.") if has_warning else _clean_focus_text(_recommend_action())
	_add_week_priority_strip(box, focus_text, has_warning)
	_apply_moral_tree_styles(card, _moral_ui_palette())

func _add_week_priority_strip(parent: Control, text: String, urgent: bool) -> void:
	var strip := PanelContainer.new()
	strip.set_meta("moral_role", "info_card")
	strip.set_meta("moral_accent", "#dce6ee")
	strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#101217", 0.84)
	st.border_color = Color("#6a4b4b", 0.92) if urgent else Color("#3a424d", 0.90)
	st.border_width_left = 3
	st.set_border_width(SIDE_TOP, 1)
	st.set_border_width(SIDE_RIGHT, 1)
	st.set_border_width(SIDE_BOTTOM, 1)
	st.set_corner_radius_all(3)
	st.content_margin_left = 10
	st.content_margin_right = 10
	st.content_margin_top = 6
	st.content_margin_bottom = 6
	strip.add_theme_stylebox_override("panel", st)
	parent.add_child(strip)

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 9)
	strip.add_child(row)

	var key := _label(_tr("우선순위", "PRIORITY"), 10, "#f0c1c1" if urgent else "#7f8794")
	key.set_meta("moral_role", "hint_text")
	key.custom_minimum_size = Vector2(76, 0)
	key.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if _font_bold:
		key.add_theme_font_override("font", _font_bold)
	row.add_child(key)

	var value := _wrap_label(text, 13, "#e8edf4")
	value.set_meta("moral_role", "choice_subtitle")
	value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(value)

func _render_week_pressure_row(parent: Control, net: float, total: float, has_warning: bool) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(row)

	var net_sign := "+" if net >= 0.0 else ""
	var cash_text := _tr("%s%s / 월", "%s%s / mo") % [net_sign, GameState.format_money(net)]
	var goal_gap := maxf(0.0, 3_000_000_000.0 - total)
	var condition := _tr("불안정", "Unstable") if has_warning else _tr("버티는 중", "Holding")
	if not has_warning and mini(GameState.health, GameState.mental) >= 65:
		condition = _tr("안정", "Steady")
	elif not has_warning and mini(GameState.health, GameState.mental) < 60:
		condition = _tr("피로 누적", "Strained")

	_add_week_pressure_cell(row, _tr("현금흐름", "CASHFLOW"), cash_text, net >= 0.0)
	_add_week_pressure_cell(row, _tr("강남까지", "TO GANGNAM"), GameState.format_money(goal_gap), goal_gap <= 1_000_000_000.0)
	_add_week_pressure_cell(row, _tr("몸과 마음", "CONDITION"), condition, not has_warning)

func _add_week_pressure_cell(parent: Control, label_text: String, value_text: String, good: bool) -> void:
	var cell := PanelContainer.new()
	cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cell.custom_minimum_size = Vector2(0, 34)
	cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#11141a", 0.68)
	st.border_color = Color("#3d4552", 0.88) if good else Color("#6a4b4b", 0.88)
	st.set_border_width_all(1)
	st.set_corner_radius_all(3)
	st.content_margin_left = 10
	st.content_margin_right = 10
	st.content_margin_top = 5
	st.content_margin_bottom = 5
	cell.add_theme_stylebox_override("panel", st)
	parent.add_child(cell)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 1)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(box)

	var key := _label(label_text, 9, "#7f8794")
	key.set_meta("moral_role", "hint_text")
	key.uppercase = true
	box.add_child(key)

	var value_col := "#dce4ee" if good else "#f0c1c1"
	var value := _label(value_text, 12, value_col)
	value.set_meta("moral_role", "choice_title" if good else "hint_text")
	if _font_bold:
		value.add_theme_font_override("font", _font_bold)
	value.clip_text = true
	value.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	box.add_child(value)

func _add_week_ap_slots(parent: Control, ap: int) -> void:
	var max_ap: int = maxi(1, GameState.max_action_points)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.custom_minimum_size = Vector2(0, 16)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.alignment = BoxContainer.ALIGNMENT_END
	parent.add_child(row)

	var slots := HBoxContainer.new()
	slots.add_theme_constant_override("separation", 4)
	slots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(slots)

	for i in range(max_ap):
		var filled := i < ap
		var slot := PanelContainer.new()
		slot.custom_minimum_size = Vector2(32, 12)
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var st := StyleBoxFlat.new()
		st.bg_color = Color("#dce4ee", 0.88) if filled else Color("#171b22", 0.86)
		st.border_color = Color("#f6f8fb", 0.72) if filled else Color("#343a45", 0.9)
		st.set_border_width_all(1)
		st.set_corner_radius_all(2)
		slot.add_theme_stylebox_override("panel", st)
		slots.add_child(slot)

func _clean_focus_text(text: String) -> String:
	var out := text
	for token in ["💼 ", "🌊 ", "📚 ", "🤝 ", "📈 ", "⏰ ", "🏙 "]:
		out = out.replace(token, "")
	return out.strip_edges()

## 상황 기반 이번 주 추천 행동 (경고 없을 때만 표시)
func _recommend_action() -> String:
	var no_job: bool = GameState.current_job.is_empty()
	var has_paycheck: bool = bool(GameState.flags.get("has_received_paycheck", false))
	var inv_skill: int = int(GameState.investment_skill)
	var social: int = int(GameState.social_skill)
	var total: float = float(GameState.get_total_asset_value())
	var intel: int = int(GameState.intelligence)
	var housing: String = GameState.housing
	var f = GameState.flags
	var me: int = (GameState.age - 33) * 12 + GameState.month

	# ── 위기 우선 ──
	if no_job:
		if intel >= 35:
			return _tr("구직활동  →  지력 %d이면 사무직 지원 가능. 이력서 작성부터", "Job Hunt  →  Intelligence %d qualifies for office jobs. Start with a resume") % intel
		return _tr("구직활동  →  수입 0원 탈출이 1순위. 알바라도 먼저", "Job Hunt  →  Escaping KRW 0 income is priority. Even a part-time job first")
	if GameState.mental <= 50:
		return _tr("휴식  →  정신력 %d. 번아웃 전에 멈추는 게 전략", "Rest  →  Mental %d. Stopping before burnout is strategy") % GameState.mental
	if not has_paycheck:
		return _tr("일 시작  →  첫 월급 수령 전까지 투자 계좌가 열리지 않습니다", "Start Working  →  Investing stays locked until your first paycheck")

	# ── 주거 업그레이드 힌트 ──
	if housing == "gosiwon" and total >= 8_000_000:
		return _tr("이사 고려  →  자산 %s, 원룸 이사 구간에 들어왔습니다 (AP 주거 메뉴)", "Consider Moving  →  Assets %s, you can move to a one-room (AP housing menu)") % GameState.format_money(total)
	if housing == "oneroom" and total >= 40_000_000:
		return _tr("이사 고려  →  자산 %s, 빌라 전세로 격상하면 정신력 보너스가 있습니다", "Consider Moving  →  Assets %s, upgrading to a villa (jeonse) gives a Mental bonus") % GameState.format_money(total)
	if housing == "villa" and total >= 130_000_000:
		return _tr("이사 고려  →  자산 %s, 아파트 전세 구간입니다. 투자 평판도 올라갑니다", "Consider Moving  →  Assets %s, apartment (jeonse) range. Reputation rises too") % GameState.format_money(total)

	# ── 투자감각 미성숙 ──
	if inv_skill < 10 and total >= 3_000_000:
		return _tr("자기계발(투자)  →  투자감각 %d. 공부 AP로 투자 지식을 먼저 쌓으세요", "Self-Dev (Invest)  →  Investing %d. Build investment knowledge with study AP first") % inv_skill

	# ── 인맥 미개척 ──
	if social < 15 and not f.get("entered_network", false) and me >= 10:
		return _tr("사교력  →  상철 네트워크(사교 AP)가 투자·직업·이벤트 경로를 엽니다", "Social  →  Sangchul's network (social AP) opens invest/job/event paths")

	# ── 투자 준비 완료 ──
	if total > 10_000_000 and inv_skill >= 15:
		if not f.get("arc_invest_guidance_seen", false):
			return _tr("투자  →  투자감각 %d, 자산 %s — 상철에게 투자 가이드를 받아보세요", "Invest  →  Investing %d, assets %s — get an investment guide from Sangchul") % [inv_skill, GameState.format_money(total)]
		return _tr("투자  →  자산 %s, 포트폴리오를 분산하면 위험이 줄어듭니다", "Invest  →  Assets %s, diversifying your portfolio reduces risk") % GameState.format_money(total)

	# ── 지력 부족 ──
	if intel < 40:
		return _tr("자기계발  →  지력 %d. 좋은 직장·투자이벤트는 지력 40+ 조건이 많습니다", "Self-Dev  →  Intelligence %d. Good jobs and invest events often need 40+") % intel

	# ── 후반 마무리 힌트 ──
	if me >= 48:
		var remaining: int = maxi(0, (38 - GameState.age) * 12 - GameState.month + 1)
		if total < 1_000_000_000:
			return _tr("남은 %d개월  →  투자 레버리지나 고수익 루트가 필요한 시점입니다", "%d months left  →  Time for investment leverage or a high-yield route") % remaining
		if total < 3_000_000_000:
			return _tr("남은 %d개월  →  30억까지 %s. 지금 루트를 유지하면 보입니다", "%d months left  →  %s to KRW 3B. Stay on course and it's in reach") % [remaining, GameState.format_money(3_000_000_000.0 - total)]

	if total < 1_000_000:
		return _tr("구직활동  →  자산 %s. 수입부터 늘려야 합니다", "Job Hunt  →  Assets %s. You need to grow income first") % GameState.format_money(total)
	return _tr("자기계발 또는 투자  →  꾸준히 스탯과 자산을 키우세요", "Self-Dev or Invest  →  Steadily grow your stats and assets")

## 매달 분위기 내레이션 한 줄 (계절 + 상태 + 아크 플래그 + 턴 기반)
func _month_narration() -> String:
	var m = GameState.month
	var f = GameState.flags
	var name = GameState.player_name
	var total = GameState.get_total_asset_value()
	# 경과 개월 (1 = 첫 달, 60 = 마지막 달) — turn(주)이 아닌 달력 기준
	var me: int = (GameState.age - 33) * 12 + GameState.month

	# ── 위기 우선 ──────────────────────────────────────
	if GameState.money < 0:
		return _tr("통장은 마이너스. 벼랑 끝에서 하루를 버틴다.", "The bank account is negative. Another day survived on the edge.")
	if GameState.mental <= 30:
		return _tr("마음이 바닥에 닿았다. 아무것도 하기 싫은 날이 늘어간다.", "My heart has hit bottom. Days of wanting to do nothing keep piling up.")
	if GameState.mental <= 40:
		return _tr("몸이 신호를 보내고 있다. 이 속도로는 오래 못 간다.", "My body is sending signals. I can't keep this pace for long.")
	if GameState.mental <= 45:
		return _tr("마음이 자꾸 가라앉는다. 버티는 것도 힘이 든다.", "My spirits keep sinking. Even holding on is hard.")
	if GameState.mental <= 50:
		return _tr("어깨가 무겁다. 잠깐의 숨 돌릴 틈도 없다.", "My shoulders are heavy. Not even a moment to catch my breath.")
	if GameState.current_job.is_empty() and me > 2:
		if me > 20:
			return _tr("아직도 직업이 없다. 서울은 기다려주지 않는다.", "Still no job. Seoul doesn't wait for anyone.")
		return _tr("수입은 0원. 통장은 매일 조금씩 줄어든다.", "Income is KRW 0. The bank account shrinks a little each day.")

	# ── 아버지 아크 ──────────────────────────────────
	if f.get("father_reconciled", false) and me >= 35:
		if m in [3, 4]:
			return _tr("아버지와 화해했다. 봄이 유독 따뜻하게 느껴지는 건 그래서인지 모른다.", "I made peace with my father. Maybe that's why this spring feels especially warm.")
	if f.get("visited_father", false) and not f.get("father_reconciled", false):
		return _tr("아버지를 만나고 왔다. 하고 싶은 말을 다 못 했다.", "I visited my father. I couldn't say everything I wanted to.")
	if f.get("arc_father_02_done", false) and not f.get("visited_father", false):
		return _tr("아버지가 편찮으시다는 소식이 마음 한구석에 걸려 있다.", "The news that my father is unwell sits in a corner of my mind.")

	# ── 관계 아크 ──────────────────────────────────
	if f.get("daeun_romance_started", false):
		if m in [12, 1, 2]:
			return _tr("다은이 따뜻한 국을 끓여줬다. 이 겨울은 작년보다 따뜻하다.", "Daeun made me warm soup. This winter is warmer than last year's.")
		return _tr("다은이 있다. 오늘 그것만으로 충분한 날이었다.", "Daeun is here. Today, that alone was enough.")
	if f.get("daeun_together_path", false):
		return _tr("다은이 생각난다. 연락하지 않아도 잘 있는지 알 것 같은 사람.", "Daeun comes to mind. The kind of person you know is doing fine without checking.")
	if f.get("startup_exit", false):
		return _tr("한 번은 해냈다. 그게 자신감이 됐다.", "I pulled it off once. That became confidence.")
	if f.get("creator_viral", false):
		return _tr("오늘도 알림이 울렸다. 낯선 누군가가 내 이야기를 보고 있다.", "The notifications buzzed again today. Strangers are watching my story.")

	# ── 자산 마일스톤 내레이션 ──────────────────────
	if total >= 2_500_000_000.0:
		return _tr("강남이 손에 잡힐 것 같다. 진짜 될 것 같다.", "Gangnam feels within reach. It might actually happen.")
	if total >= 1_000_000_000.0:
		return _tr("10억을 넘었다. 이 숫자가 현실인지 아직 믿기지 않는다.", "Passed KRW 1B. I still can't believe this number is real.")
	if total >= 500_000_000.0:
		return _tr("5억. 서울에서 이 숫자가 이렇게 무거울 줄 몰랐다.", "KRW 500M. I never knew this number could feel so heavy in Seoul.")
	if total >= 100_000_000.0:
		return _tr("1억을 넘었다. 작은 것 같지만, 여기서부터가 진짜다.", "Passed KRW 100M. It seems small, but the real game starts here.")

	# ── 경과 개월 기반 내레이션 (마일스톤 / 후반 긴장) ────
	if me >= 60:
		return _tr("마지막 달이다. 지금 여기, 이게 {name}의 5년이다.", "It's the final month. Right here, right now — this is {name}'s five years.").replace("{name}", name)
	if me >= 54:
		return _tr("6개월이 남았다. 아직 늦지 않았다고 — 믿어야 한다.", "Six months left. It's not too late yet — I have to believe that.")
	if me >= 48:
		return _tr("1년이 채 남지 않았다. 통장 숫자가 더 크게 보인다.", "Less than a year left. The bank balance looms larger now.")
	if me >= 42:
		return _tr("강남이 멀지 않다. 아니, 아직 멀다. 그 경계 어딘가.", "Gangnam isn't far. No, it's still far. Somewhere on that boundary.")
	if me == 24:
		return _tr("2년이 지났다. 서울이 조금 익숙해졌다.", "Two years have passed. Seoul feels a little more familiar.")
	if me == 12:
		return _tr("서울에 올라온 지 1년이 됐다. 통장 숫자와 체중이 다 줄었다.", "It's been a year since I came up to Seoul. Both my balance and my weight have dropped.")

	# ── 주거 기반 ──────────────────────────────────
	var housing = GameState.housing
	if housing == "gosiwon":
		if me > 24:
			return _tr("1평 반에서 2년이 넘었다. 이 방이 익숙해지는 게 무서워졌다.", "Over two years in 1.5 pyeong. It scares me how used to this room I've become.")
		if me > 12:
			return _tr("1평 반에서 1년이 넘었다. 좁지만, 그래도 내 방이다.", "Over a year in 1.5 pyeong. Cramped, but still my own room.")
	elif housing == "apartment":
		return _tr("아파트 창에서 보이는 서울은 다르다. 이 풍경에 익숙해지면 안 된다고 생각했다.", "Seoul looks different from an apartment window. I told myself not to get used to this view.")
	elif housing == "gangnam":
		return _tr("강남에 왔다. 그런데 강남에서도 여전히 올라가야 할 곳이 있었다.", "I made it to Gangnam. And yet even here, there was still higher to climb.")

	# ── 계절 × 게임 시기 내레이션 ──────────────────
	if me <= 15:
		# 초반: 낯섦과 의지
		if m in [12, 1, 2]:
			return _tr("겨울 서울. 고시원 창문에 성에가 꼈다. 오늘 하루도 버텼다.", "Winter in Seoul. Frost on the goshiwon window. I made it through another day.")
		elif m in [3, 4, 5]:
			return _tr("봄이 왔다. 취업 공고가 넘쳐났다. 이번엔 될 것 같았다.", "Spring came. Job postings flooded in. This time it felt like it would work out.")
		elif m in [6, 7, 8]:
			return _tr("여름. 고시원은 덥고, 에어컨은 사치다. 땀 흘리며 이력서를 수정했다.", "Summer. The goshiwon is hot, AC a luxury. I revised my resume, sweating.")
		else:
			return _tr("가을. 어딘가에서 금방 되겠다고 했던 1년 전의 자신이 생각났다.", "Autumn. I remembered myself a year ago, sure it would all come together soon.")
	elif me <= 35:
		# 중반: 지침과 성장
		if m in [12, 1, 2]:
			return _tr("겨울이 또 왔다. 작년보다 통장 숫자가 달라졌다.", "Winter came again. The number in my bank account is different from last year.")
		elif m in [3, 4, 5]:
			return _tr("봄. 1년 전 봄과 지금 봄이 다르다는 걸 느꼈다.", "Spring. I felt how different this spring is from the one a year ago.")
		elif m in [6, 7, 8]:
			return _tr("이 여름도 지나면 또 반년이 줄어든다.", "Once this summer passes, another half year is gone.")
		else:
			return _tr("가을. 한 해가 또 저문다. %s은 수첩의 숫자를 본다.", "Autumn. Another year fades. %s looks at the numbers in the notebook.") % name
	else:
		# 후반: 절박함과 선명해지는 목표
		if m in [12, 1, 2]:
			return _tr("겨울. 시간이 별로 없다는 걸 겨울이 되면 더 실감한다.", "Winter. When it comes, I feel even more how little time is left.")
		elif m in [3, 4, 5]:
			return _tr("봄이 왔다. 이 봄이 강남드림의 마지막 봄일 수도 있다.", "Spring came. This could be the last spring of the Gangnam Dream.")
		elif m in [6, 7, 8]:
			return _tr("더위가 기승이다. 땀 흘리는 것도 시간이고, 시간이 곧 돈이었다.", "The heat rages. Even sweating takes time, and time was money.")
		else:
			return _tr("가을. 이 가을을 어떻게 보내느냐가 결말을 바꿀지도 모른다.", "Autumn. How I spend this autumn might change the ending.")

# ══════════════════════════════════════════════════════════════
# 상황 카드 시스템 — 추상 메뉴 대신 '이번 달 상황'에 반응한다.
# ══════════════════════════════════════════════════════════════
func _situation_category_tag(category: String) -> String:
	match category:
		"finance":
			return _tr("돈", "FIN")
		"family":
			return _tr("가족", "FAM")
		"jobs":
			return _tr("일", "JOB")
		"social":
			return _tr("사회", "SOC")
		"gambling":
			return _tr("도박", "RISK")
		"health":
			return _tr("건강", "BODY")
		"investment":
			return _tr("투자", "INV")
		"relationship":
			return _tr("관계", "REL")
		"disasters":
			return _tr("위기", "CRISIS")
		"politics":
			return _tr("사회", "CIVIC")
		"comedy":
			return _tr("일상", "LIFE")
		"military":
			return _tr("예비군", "RES")
		_:
			return _tr("상황", "EVENT")

func _render_situation_cards():
	# 그 달의 '사건'은 풀스크린 VN으로 이미 재생됨(드라마 모드).
	# 여기선 남은 시간으로 할 '루틴 행동'만 고른다.
	var ap: int = GameState.action_points
	if ap > 0:
		_add_ap_section_header(_tr("행동 레일", "ACTION RAIL"), _tr("이번 주의 남은 시간을 어디에 쓸지 고른다", "Choose where this week's remaining time goes"))
	else:
		_add_ap_section_header(_tr("이번 주 종료", "WEEK CLOSED"), _tr("더 할 수 있는 행동이 없다. 다음 주로 넘긴다", "No actions left. Advance to next week"))
	_render_essential_actions(ap)

func _add_ap_section_header(title: String, subtitle: String) -> void:
	var panel := PanelContainer.new()
	panel.set_meta("moral_role", "separator")
	panel.set_meta("moral_accent", "#6f7788")
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#07080b", 0.72)
	st.border_color = Color("#252b35", 0.95)
	st.border_width_left = 3
	st.set_border_width(SIDE_TOP, 1)
	st.set_border_width(SIDE_BOTTOM, 1)
	st.set_corner_radius_all(2)
	st.content_margin_left = 11
	st.content_margin_right = 11
	st.content_margin_top = 7
	st.content_margin_bottom = 7
	panel.add_theme_stylebox_override("panel", st)
	choice_box.add_child(panel)

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 10)
	panel.add_child(row)

	var title_lbl := _label(title, 12, "#d8dee8")
	title_lbl.set_meta("moral_role", "choice_title")
	title_lbl.custom_minimum_size = Vector2(112, 0)
	title_lbl.uppercase = true
	if _font_bold:
		title_lbl.add_theme_font_override("font", _font_bold)
	row.add_child(title_lbl)

	var sub_lbl := _label(subtitle, 12, "#7f8794")
	sub_lbl.set_meta("moral_role", "hint_text")
	sub_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sub_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(sub_lbl)

func _situation_card(sit: Dictionary, engaged: bool, no_ap: bool) -> Button:
	var cat: String = str(sit.get("category", "social"))
	var tag: String = _situation_category_tag(cat)
	var title: String = _fmt(str(sit.get("title", _tr("상황", "Situation"))))
	var desc: String = _fmt(str(sit.get("description", "")))
	var hook: String = desc.split("\n")[0]
	if hook.length() > 40:
		hook = hook.substr(0, 40) + "…"
	var label_text: String = ""
	var accent: String = "#3a6ea8"
	if engaged:
		label_text = "  %s  %s  %s" % [_tr("완료", "DONE"), tag, title]
		accent = "#24242e"
	else:
		label_text = "  %s  %s\n        %s" % [tag, title, hook]
	var btn: Button = _action_button(label_text, accent)
	btn.custom_minimum_size = Vector2(0, 54)
	btn.disabled = engaged or no_ap
	if not engaged and not no_ap:
		var captured: Dictionary = sit
		btn.pressed.connect(func(): _engage_situation(captured))
	return btn

func _engage_situation(sit: Dictionary):
	if GameState.action_points <= 0:
		_show_toast(_tr("시간이 없습니다", "No time left"), Color("#ff4444"))
		return
	var sid: String = str(sit.get("id", ""))
	if engaged_situations.has(sid):
		return
	GameState.spend_ap()
	engaged_situations[sid] = true
	# 기존 이벤트 흐름 재활용 — follow_up 체인까지 자동 처리
	EventManager.current_event = sit
	current_event = sit
	_render_event()

func _render_essential_actions(ap: int):
	var disabled: bool = ap <= 0
	var no_job: bool = GameState.current_job.is_empty()
	var has_paycheck: bool = bool(GameState.flags.get("has_received_paycheck", false))
	if no_job:
		_essential_btn(_tr("구직활동", "Job Hunt"), _tr("일자리를 찾아 수입 0원에서 벗어난다", "Find work and escape zero income"), "job", "#dc6a2a", "_ap_job_hunt", disabled)
	if GameState.flags.get("arc_invest_guidance_seen", false):
		_essential_btn(_tr("투자", "Invest"), _tr("매수·매도와 포트폴리오 조정", "Buy, sell, rebalance your portfolio"), "invest", "#3a8a5a", "_ap_invest", disabled)
		if GameState.investment_skill >= 50:
			_essential_btn(_tr("시장 분석", "Market Analysis"), _tr("다음 달 시장 방향을 무료로 예측한다", "Predict next month's market for free"), "market", "#1e3a5f", "_ap_market_analysis", false, true)
	elif has_paycheck:
		_essential_locked(_tr("투자", "Invest"), _tr("상철과의 대화 이후 열림", "Unlocks after talking with Sangchul"), "invest", "#3a8a5a")
	_essential_btn(_tr("자기계발", "Self-Dev"), _tr("독서·운동·명상 중 한 가지", "One of: reading, exercise, meditation"), "study", "#5a6ea8", "_ap_study", disabled)
	_essential_btn(_tr("휴식", "Rest"), _tr("숨을 고르고 정신력을 회복한다", "Catch your breath and recover mental"), "rest", "#3a8a9a", "_ap_free_time", disabled)
	# 도박 회복 잠금: 회복을 시작/완료했고 아직 재발하지 않았으면 도박 입구를 닫는다.
	var _in_recovery: bool = GameState.flags.get("in_recovery_started", false) \
			or GameState.flags.get("recovery_holding", false) \
			or GameState.flags.get("beat_addiction", false)
	var _gambling_locked: bool = _in_recovery and not GameState.flags.get("relapsed", false)
	# 해금된 도박 장소가 하나라도 있으면 단일 "도박장" 버튼으로 통합
	var _has_racetrack: bool = GameState.flags.get("racetrack_guide_met", false) or GameState.flags.get("racetrack_visited", false)
	var _has_holdem: bool = GameState.flags.get("entered_network", false) and GameState.money >= 50000
	var _has_scalping: bool = GameState.flags.get("scalping_introduced", false) and GameState.investment_skill >= 15
	var _has_casino: bool = GameState.flags.get("casino_club_introduced", false)
	if _has_racetrack or _has_holdem or _has_scalping or _has_casino:
		var g_sub: String = _tr("회복 중 — 닫혀 있다", "In recovery — closed") if _gambling_locked else _tr("열린 장소를 고른다", "Choose from available venues")
		_essential_btn(_tr("도박장", "Gambling"), g_sub, "casino", "#7b3fd1", "_open_cat_gambling", disabled or _gambling_locked)
	_essential_btn(_tr("생활", "Life"), _tr("이사·상점. 시간 소모 없음", "Move and shop. No time cost"), "life", "#9a8a5a", "_open_cat_life", false, true)

func _mastery_badge(game_id: String) -> String:
	var grade: int = MetaProgression.get_mastery(game_id)
	if grade == 0: return ""
	var labels := ["", _tr(" ★숙련", " ★Skilled"), _tr(" ★★고급", " ★★Expert"), _tr(" ★★★마스터", " ★★★Master")]
	return labels[grade]

func _essential_btn(title: String, subtitle: String, icon_id: String, accent: String,
		fn: String, disabled: bool, free_action: bool = false):
	var rail_label := _next_ap_rail_label()
	var btn := _make_essential_action_card(title, subtitle, icon_id, accent, disabled, free_action, "", rail_label)
	if not disabled:
		var fn_name: String = fn
		btn.pressed.connect(func():
			AudioManager.play_ui_click()
			self.call(fn_name)
		)
	btn.set_meta("ap_rail_label", rail_label)
	choice_box.add_child(btn)
	_animate_ap_action_card(btn, choice_box.get_child_count())

func _essential_locked(title: String, subtitle: String, icon_id: String, accent: String) -> void:
	var btn := _make_essential_action_card(title, subtitle, icon_id, accent, true, false, _tr("잠금", "Locked"), _next_ap_rail_label())
	choice_box.add_child(btn)
	_animate_ap_action_card(btn, choice_box.get_child_count())

func _next_ap_rail_label() -> String:
	var count := 0
	for child in choice_box.get_children():
		if child is Button:
			count += 1
	return "%02d" % (count + 1)

func _animate_ap_action_card(card: Control, index: int) -> void:
	if not is_inside_tree() or not is_instance_valid(card):
		return
	var start_modulate := card.modulate
	start_modulate.a = 0.0
	card.modulate = start_modulate
	var tw := create_tween()
	tw.tween_property(card, "modulate:a", 1.0, 0.16) \
			.set_delay(minf(0.18, 0.025 * float(index))) \
			.set_trans(Tween.TRANS_SINE)

func _make_essential_action_card(title: String, subtitle: String, icon_id: String,
		accent: String, disabled: bool, free_action: bool, forced_badge: String,
		rail_label: String = "") -> Button:
	var btn := Button.new()
	btn.set_meta("moral_role", "choice_card")
	btn.set_meta("moral_accent", accent if not disabled else "#343446")
	btn.text = ""
	btn.custom_minimum_size = Vector2(0, 68)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.disabled = disabled
	btn.focus_mode = Control.FOCUS_ALL

	var accent_color := Color(accent if not disabled else "#343446")
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#0c0d11") if not disabled else Color("#09090d")
	normal.border_color = accent_color.darkened(0.04)
	normal.border_width_left = 5
	normal.set_border_width(SIDE_TOP, 1)
	normal.set_border_width(SIDE_RIGHT, 1)
	normal.set_border_width(SIDE_BOTTOM, 1)
	normal.set_corner_radius_all(3)
	normal.content_margin_left = 0
	normal.content_margin_right = 0
	normal.content_margin_top = 0
	normal.content_margin_bottom = 0
	var hover := normal.duplicate()
	hover.bg_color = Color("#15161c")
	hover.border_color = accent_color.lightened(0.38)
	var pressed_style := normal.duplicate()
	pressed_style.bg_color = Color("#08090c")
	var focus_style := normal.duplicate()
	focus_style.border_color = Color(COL_GOLD_BRIGHT)
	focus_style.set_border_width_all(2)
	var disabled_style := normal.duplicate()
	disabled_style.bg_color = Color("#0a0a0f")
	disabled_style.border_color = Color("#252535")
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed_style)
	btn.add_theme_stylebox_override("focus", focus_style)
	btn.add_theme_stylebox_override("disabled", disabled_style)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	btn.add_child(margin)

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)

	if not rail_label.is_empty():
		var rail := PanelContainer.new()
		rail.set_meta("moral_role", "choice_badge")
		rail.custom_minimum_size = Vector2(40, 46)
		rail.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		rail.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var rail_style := StyleBoxFlat.new()
		rail_style.bg_color = Color("#07080b", 0.92)
		rail_style.border_color = Color(accent, 0.42 if not disabled else 0.16)
		rail_style.set_border_width_all(1)
		rail_style.set_corner_radius_all(2)
		rail_style.content_margin_left = 5
		rail_style.content_margin_right = 5
		rail_style.content_margin_top = 6
		rail_style.content_margin_bottom = 6
		rail.add_theme_stylebox_override("panel", rail_style)
		row.add_child(rail)

		var rail_col := VBoxContainer.new()
		rail_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rail_col.alignment = BoxContainer.ALIGNMENT_CENTER
		rail_col.add_theme_constant_override("separation", 0)
		rail.add_child(rail_col)

		var rail_tag := _label(_tr("슬롯", "SLOT"), 8, "#667084" if not disabled else "#3e4350")
		rail_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rail_tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rail_col.add_child(rail_tag)

		var rail_num := _label(rail_label, 15, "#edf3f8" if not disabled else "#5a6070")
		rail_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rail_num.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if _font_bold:
			rail_num.add_theme_font_override("font", _font_bold)
		rail_col.add_child(rail_num)

	var icon_box := PanelContainer.new()
	icon_box.set_meta("moral_role", "choice_icon")
	icon_box.set_meta("moral_accent", accent if not disabled else "#343446")
	icon_box.custom_minimum_size = Vector2(46, 46)
	icon_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon_style := StyleBoxFlat.new()
	icon_style.bg_color = Color(accent, 0.20 if not disabled else 0.06)
	icon_style.border_color = accent_color
	icon_style.set_border_width_all(2 if not disabled else 1)
	icon_style.set_corner_radius_all(3)
	icon_box.add_theme_stylebox_override("panel", icon_style)
	row.add_child(icon_box)

	var icon_tex := TextureRect.new()
	icon_tex.set_meta("moral_role", "hud_icon")
	icon_tex.set_meta("moral_accent", accent if not disabled else "#343446")
	icon_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_tex.custom_minimum_size = Vector2(36, 36)
	icon_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_tex.texture = _ui_icon_texture(icon_id)
	icon_tex.modulate = Color(accent, 0.95 if not disabled else 0.35)
	icon_box.add_child(icon_tex)

	var text_col := VBoxContainer.new()
	text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text_col.add_theme_constant_override("separation", 2)
	row.add_child(text_col)

	var title_lbl := _label(title, 15, "#edf0f4" if not disabled else "#5f6372")
	title_lbl.set_meta("moral_role", "choice_title")
	title_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _font_bold:
		title_lbl.add_theme_font_override("font", _font_bold)
	text_col.add_child(title_lbl)

	var sub_lbl := _label(subtitle, 12, "#a6adba" if not disabled else "#484c5c")
	sub_lbl.set_meta("moral_role", "choice_subtitle")
	sub_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sub_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	text_col.add_child(sub_lbl)

	var badge_text := forced_badge
	if forced_badge == _tr("잠금", "Locked"):
		badge_text = _tr("잠금", "Locked")
	if badge_text.is_empty():
		badge_text = _tr("무료", "Free") if free_action else _tr("AP 1", "AP 1")
	var badge := PanelContainer.new()
	badge.set_meta("moral_role", "choice_badge")
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.custom_minimum_size = Vector2(62, 30)
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = Color("#101116") if not disabled else Color("#0e0e14")
	badge_style.border_color = Color("#2e3446") if not free_action else Color("#3d6f59")
	if forced_badge == _tr("잠금", "Locked"):
		badge_style.border_color = Color("#3a3a48")
	badge_style.set_border_width_all(1)
	badge_style.set_corner_radius_all(3)
	badge_style.content_margin_left = 8
	badge_style.content_margin_right = 8
	badge_style.content_margin_top = 4
	badge_style.content_margin_bottom = 4
	badge.add_theme_stylebox_override("panel", badge_style)
	row.add_child(badge)

	var badge_lbl := _label(badge_text, 11, "#a7f3d0" if free_action and not disabled else "#aab3c5")
	badge_lbl.set_meta("moral_role", "choice_badge_text")
	if forced_badge == _tr("잠금", "Locked"):
		badge_lbl.add_theme_color_override("font_color", Color("#6d7282"))
	badge_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_child(badge_lbl)

	if ControllerHints.is_pad_active() and not disabled:
		var keycap := PanelContainer.new()
		keycap.set_meta("moral_role", "choice_badge")
		keycap.custom_minimum_size = Vector2(38, 30)
		keycap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		keycap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var key_style := StyleBoxFlat.new()
		key_style.bg_color = Color("#14120b", 0.92)
		key_style.border_color = Color(COL_GOLD_BRIGHT, 0.82)
		key_style.set_border_width_all(1)
		key_style.set_corner_radius_all(3)
		key_style.content_margin_left = 8
		key_style.content_margin_right = 8
		key_style.content_margin_top = 4
		key_style.content_margin_bottom = 4
		keycap.add_theme_stylebox_override("panel", key_style)
		row.add_child(keycap)

		var key_lbl := _label(ControllerHints.south(), 12, "#f8f1cf")
		key_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		key_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		key_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if _font_bold:
			key_lbl.add_theme_font_override("font", _font_bold)
		keycap.add_child(key_lbl)

	var arrow_lbl := _label("›", 28, accent if not disabled else "#303040")
	arrow_lbl.set_meta("moral_role", "choice_arrow")
	arrow_lbl.set_meta("moral_accent", accent if not disabled else "#343446")
	arrow_lbl.custom_minimum_size = Vector2(14, 0)
	arrow_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	arrow_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(arrow_lbl)
	_apply_moral_tree_styles(btn, _moral_ui_palette())
	return btn

func _hud_chip(parent: Control, icon_id: String, accent: String,
		min_width: int, expand: bool) -> Label:
	var panel := PanelContainer.new()
	panel.set_meta("moral_role", "hud_chip")
	panel.set_meta("moral_accent", accent)
	panel.custom_minimum_size = Vector2(min_width, 40)
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL if expand else Control.SIZE_SHRINK_BEGIN
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#0c0d12")
	st.border_color = Color(accent, 0.24)
	st.set_border_width_all(1)
	st.set_corner_radius_all(3)
	st.content_margin_left = 9
	st.content_margin_right = 9
	st.content_margin_top = 6
	st.content_margin_bottom = 6
	panel.add_theme_stylebox_override("panel", st)
	parent.add_child(panel)

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 6)
	panel.add_child(row)

	if not icon_id.is_empty():
		var tex := TextureRect.new()
		tex.set_meta("moral_role", "hud_icon")
		tex.set_meta("moral_accent", accent)
		tex.custom_minimum_size = Vector2(18, 18)
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.texture = _ui_icon_texture(icon_id)
		tex.modulate = Color(accent)
		tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(tex)

	var lbl := _label("", 14, "#d8deea")
	lbl.set_meta("moral_role", "hud_text")
	lbl.set_meta("moral_accent", accent)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.clip_text = false
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(lbl)
	_apply_moral_tree_styles(panel, _moral_ui_palette())
	return lbl

func _ui_icon_texture(icon_id: String) -> Texture2D:
	if _ui_icon_cache.has(icon_id):
		return _ui_icon_cache[icon_id]
	var path: String = str(UI_ICON_PATHS.get(icon_id, ""))
	if path.is_empty() or not ResourceLoader.exists(path):
		_ui_icon_cache[icon_id] = null
		return null
	var res := load(path)
	var tex: Texture2D = res if res is Texture2D else null
	_ui_icon_cache[icon_id] = tex
	return tex

## 5개 카테고리 행동 카드 렌더링 (구버전 — 상황 카드로 대체됨)
func _render_action_cards(disabled: bool, no_job: bool, has_paycheck: bool, job_unlocked: bool, warn_body: bool):
	# [일/커리어] — 취업 후 일은 자동(월급·승진 패시브)이라 카드를 숨긴다.
	# 무직(구직 필요)이거나 능동적 사업(창업/콘텐츠)이 있을 때만 노출.
	var has_venture = (GameState.flags.get("startup_launched", false) and not GameState.flags.get("startup_exit", false)) \
		or (GameState.flags.get("creator_started", false) and not GameState.flags.get("creator_viral", false))
	if no_job or has_venture:
		var work_title = _tr("일 · 커리어", "Work · Career") if no_job else _tr("내 사업", "My Business")
		var work_sub = _tr("구직·자소서·면접", "Job hunt · cover letter · interview") if no_job else _tr("창업·콘텐츠 운영", "Startup · content")
		var work_urgent = no_job and job_unlocked
		_add_category_card(
			"💼", work_title, work_sub,
			"#3a6ea8", disabled, "_open_cat_work",
			not job_unlocked, _tr("스토리 진행 후", "After story progress") if not job_unlocked else "",
			work_urgent)

	# [돈/투자]
	var money_sub = _tr("단기 알바로 종잣돈", "Seed money via gigs") if not has_paycheck else _tr("투자·부업으로 자산 증식", "Grow assets via invest · side gigs")
	_add_category_card(
		"📈", _tr("돈 · 투자", "Money · Invest"), money_sub,
		"#4a8a5a", disabled, "_open_cat_money", false, "", false)

	# [자기계발]
	var dev_sub = _tr("체력·정신 회복 필요!", "Recover health · mental!") if warn_body else _tr("독서·운동·명상으로 성장", "Grow via reading · exercise · meditation")
	_add_category_card(
		"📚", _tr("자기계발", "Self-Dev"), dev_sub,
		"#5a6ea8", disabled, "_open_cat_dev", false, "", warn_body)

	# [사람/관계]
	_add_category_card(
		"🤝", _tr("사람 · 관계", "People · Relations"), _tr("내 사람 챙기기·인맥·휴식", "Care for people · network · rest"),
		"#8a5a9a", disabled, "_open_cat_people", false, "", false)

	# [생활] — AP 불필요 (이사/상점)
	var can_move = GameState.can_upgrade_housing()
	var life_sub = _tr("이사 가능!", "Can move!") if can_move else _tr("주거·생활 관리", "Housing · living")
	_add_category_card(
		"🏠", _tr("생활", "Living"), life_sub,
		"#9a8a5a", false, "_open_cat_life", false, "", can_move)

## 행동 카테고리 카드 1개 생성
func _add_category_card(icon: String, title: String, subtitle: String,
		accent: String, disabled: bool, fn: String,
		locked: bool, lock_note: String, highlight: bool):
	var card = Button.new()
	card.custom_minimum_size = Vector2(0, 56)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.disabled = disabled or locked
	card.focus_mode = Control.FOCUS_NONE

	var st = StyleBoxFlat.new()
	if highlight:
		st.bg_color = Color("#1a1410")
		st.border_color = Color("#f0b429")
		st.border_width_left = 5
	else:
		st.bg_color = Color("#111119")
		st.border_color = Color(accent)
		st.border_width_left = 4
	if locked:
		st.border_color = Color("#2a2a38")
	st.set_corner_radius_all(6)
	st.content_margin_left = 18
	st.content_margin_right = 16
	st.content_margin_top = 8
	st.content_margin_bottom = 8
	var hov = st.duplicate()
	hov.bg_color = Color("#1c1c2a")
	card.add_theme_stylebox_override("normal", st)
	card.add_theme_stylebox_override("hover", hov)
	card.add_theme_stylebox_override("pressed", st)
	card.add_theme_stylebox_override("disabled", st)

	# 카드 내부 레이아웃
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(row)

	var icon_lbl = _label(icon, 24, "#ffffff")
	icon_lbl.custom_minimum_size = Vector2(36, 0)
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(icon_lbl)

	var txt = VBoxContainer.new()
	txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	txt.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	txt.add_theme_constant_override("separation", 1)
	row.add_child(txt)
	var title_lbl = _label(title, 16, "#e8eaf0" if not locked else "#5a5a6a")
	txt.add_child(title_lbl)
	var sub_color = "#f0b429" if highlight else "#7a8496"
	if locked:
		sub_color = "#4a4a58"
	txt.add_child(_label((_tr("잠금: ", "Locked: ") + lock_note) if locked else subtitle, 12, sub_color))

	# AP 비용 표시 (생활 카테고리는 AP 무료)
	if fn != "_open_cat_life":
		var ap_lbl = _label(_tr("AP", "AP"), 12, accent if not disabled else "#3a3a48")
		ap_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(ap_lbl)
	else:
		row.add_child(_label(_tr("무료", "Free"), 11, "#5a6478"))

	if not (disabled or locked):
		card.pressed.connect(Callable(self, fn))
	choice_box.add_child(card)

# ══════════════════════════════════════════════════════════
# 카테고리 모달 — 세부 행동을 묶어서 보여줌. 기존 _ap_* 재사용.
# ══════════════════════════════════════════════════════════
func _cat_modal_button(label: String, accent: String, fn: String, arg = null):
	var split := _split_action_label(label)
	var free_action := fn in ["_ap_move_housing"]
	var btn := _make_essential_action_card(
		str(split.get("title", label)),
		str(split.get("subtitle", "")),
		_cat_modal_icon(fn),
		accent,
		false,
		free_action,
		"")
	btn.custom_minimum_size = Vector2(0, 74)
	var fn_name := fn
	var fn_arg = arg
	btn.pressed.connect(func():
		AudioManager.play("click")
		_close_modal()
		if fn_arg == null:
			self.call(fn_name)
		else:
			self.call(fn_name, fn_arg)
	)
	modal_body.add_child(btn)

func _cat_modal_status_card(title: String, subtitle: String, accent: String, icon_id: String, badge: String) -> void:
	var card := _make_essential_action_card(title, subtitle, icon_id, accent, true, true, badge)
	card.custom_minimum_size = Vector2(0, 74)
	modal_body.add_child(card)

func _split_action_label(label: String) -> Dictionary:
	var clean := label.strip_edges()
	var dash_idx := clean.find("  —  ")
	if dash_idx < 0:
		dash_idx = clean.find(" — ")
	if dash_idx < 0:
		dash_idx = clean.find("—")
	if dash_idx < 0:
		return {"title": clean, "subtitle": ""}
	var title := clean.substr(0, dash_idx).strip_edges()
	var subtitle := clean.substr(dash_idx + 1).strip_edges()
	while subtitle.begins_with("—") or subtitle.begins_with("-"):
		subtitle = subtitle.substr(1).strip_edges()
	return {"title": title, "subtitle": subtitle}

func _cat_modal_icon(fn: String) -> String:
	match fn:
		"_ap_job_hunt", "_ap_write_resume", "_ap_interview_prep", "_ap_startup_work", "_ap_create_content":
			return "job"
		"_ap_invest":
			return "invest"
		"_ap_side_job", "_ap_save_money":
			return "money"
		"_ap_network", "_ap_vip_network", "_ap_contact_person":
			return "people"
		"_ap_free_time":
			return "rest"
		"_ap_move_housing":
			return "life"
		"_open_shop":
			return "shop"
		_:
			return "ap"

func _open_cat_work():
	var no_job = GameState.current_job.is_empty()
	_open_modal(_tr("일 · 커리어", "Work · Career"), true)
	if no_job:
		modal_body.add_child(_wrap_label(_tr("아직 직업이 없다. 수입이 0원이다. 무엇이든 시작해야 한다.", "No job yet. Income is zero. You have to start something."), 13, "#c8a060"))
		_cat_modal_button(_tr("구직활동  —  일자리를 찾아 지원한다", "Job Hunt  —  find and apply for jobs"), "#dc6a2a", "_ap_job_hunt")
		_cat_modal_button(_tr("자소서 작성  —  지원서를 다듬는다", "Write cover letter  —  refine the application"), "#3a6ea8", "_ap_write_resume")
		if GameState.social_skill >= 20:
			_cat_modal_button(_tr("모의 면접  —  말하는 연습을 한다", "Mock interview  —  practice speaking"), "#3a6ea8", "_ap_interview_prep")
	else:
		var job_name = GameState.get_job_display_name()
		var tenure = GameState.job_tenure
		var threshold = int(GameState.current_job.get("promotion_threshold", 12))
		var promo_count = int(GameState.current_job.get("promotion_count", 0))
		var max_promo = int(GameState.current_job.get("max_promotions", 3))
		var perf = GameState.work_performance
		var salary = GameState.monthly_income
		modal_body.add_child(_wrap_label(
			_tr("%s — 월급 %s", "%s — Salary %s") % [job_name, GameState.format_money(salary)], 14, _info_text_hex("#c8a060", 0.02)))
		modal_body.add_child(_label(_tr("── 승진 현황 ──", "── Promotion Status ──"), 11, "#3a3a5a"))
		if promo_count >= max_promo:
			modal_body.add_child(_wrap_label(_tr("최고 직급 달성 — 더 높은 직종으로 이직을 고려하세요.", "Top rank reached — consider moving to a higher-tier job."), 13, _info_text_hex("#c9a227", 0.02)))
		else:
			var tenure_row = HBoxContainer.new()
			tenure_row.add_theme_constant_override("separation", 8)
			modal_body.add_child(tenure_row)
			var tenure_lbl = _label(_tr("근속", "Tenure"), 12, "#7a8496")
			tenure_lbl.custom_minimum_size = Vector2(36, 0)
			tenure_row.add_child(tenure_lbl)
			tenure_row.add_child(_mini_progress_meter(tenure, threshold, "#8f98a8"))
			var months_lbl = _label(_tr("%d / %d개월", "%d / %d mo") % [tenure, threshold], 12, "#aab3c5")
			months_lbl.custom_minimum_size = Vector2(72, 0)
			tenure_row.add_child(months_lbl)
			var perf_color = _info_signal_hex("#00c896" if perf >= 60 else "#ef4444")
			var perf_gate = _tr("승진 준비됨", "Promotion ready") if perf >= 60 else _tr("기준 미달", "Below requirement")
			modal_body.add_child(_wrap_label(
				_tr("업무 성과  %d / 100  [%s]  (기준: 60+)", "Performance  %d / 100  [%s]  (req: 60+)") % [perf, perf_gate], 12, perf_color))
			if tenure >= threshold and perf >= 60:
				modal_body.add_child(_wrap_label(_tr("이번 달 승진 판정 대상!  (35% 확률)", "Up for promotion this month!  (35% chance)"), 13, _info_text_hex("#f0b429", 0.02)))
			elif tenure >= threshold:
				modal_body.add_child(_wrap_label(_tr("근속 기간 충족. 업무 성과를 60 이상으로 올리세요.", "Tenure met. Raise performance above 60."), 13, _info_text_hex("#f0b429", 0.02)))
			else:
				var left = threshold - tenure
				modal_body.add_child(_wrap_label(
					_tr("%d개월 후 승진 판정 — 그때까지 성과를 쌓아라.", "Promotion review in %d mo — build performance until then.") % left, 13, "#7a8496"))
			var job_tier = int(GameState.current_job.get("tier", 1))
			var next_jobs: Array = []
			for j in DataRegistry.jobs:
				if int(j.get("tier", 0)) == job_tier + 1:
					next_jobs.append(GameState.get_job_display_name(j))
			if not next_jobs.is_empty():
				modal_body.add_child(_wrap_label(
					_tr("다음 직급 예시  ", "Next rank e.g.  ") + "  /  ".join(next_jobs.slice(0, 3)), 12, _info_signal_hex("#3a6ea8")))
		modal_body.add_child(_wrap_label(_tr("남는 행동력은 투자·자기계발·관계에 쓰자.", "Spend leftover AP on invest · self-dev · relations."), 12, "#3a3a5a"))
	# 창업/크리에이터 진행 중이면 노출
	if GameState.flags.get("startup_launched", false) and not GameState.flags.get("startup_exit", false):
		_cat_modal_button(_tr("창업 업무  —  내 사업을 키운다", "Startup work  —  grow your business"), "#6a3a9a", "_ap_startup_work")
	if GameState.flags.get("creator_started", false) and not GameState.flags.get("creator_viral", false):
		_cat_modal_button(_tr("콘텐츠 제작  —  채널을 키운다", "Make content  —  grow your channel"), "#4a7a3a", "_ap_create_content")

func _open_cat_money():
	var has_paycheck: bool = GameState.flags.get("has_received_paycheck", false)
	var no_job = GameState.current_job.is_empty()
	_open_modal(_tr("돈 · 투자", "Money · Invest"), true)
	modal_body.add_child(_wrap_label(_tr("월급만으론 30억에 닿을 수 없다. 돈이 돈을 벌게 해야 한다.", "A salary alone won't reach KRW 3B. Make money work for you."), 13, "#7a8496"))
	if GameState.flags.get("arc_invest_guidance_seen", false):
		_cat_modal_button(_tr("투자 집중  —  차트를 들여다본다", "Focus on investing  —  study the charts"), "#3a8a5a", "_ap_invest")
	elif has_paycheck:
		modal_body.add_child(_wrap_label(_tr("잠금: 투자는 상철과의 대화 후 가능하다.", "Locked: investing unlocks after talking with Sangchul."), 12, "#5a5a6a"))
	else:
		modal_body.add_child(_wrap_label(_tr("잠금: 투자는 첫 월급을 받은 뒤 가능하다.", "Locked: investing unlocks after your first paycheck."), 12, "#5a5a6a"))
	var side_label = _tr("단기 알바  —  40만원+ (건강-3, 정신력 변동)", "Gig work  —  KRW 400K+ (Health -3, Mental varies)") if no_job else _tr("부업/사이드  —  추가 수입 도전", "Side hustle  —  chase extra income")
	_cat_modal_button(side_label, "#3a8a5a", "_ap_side_job")
	_cat_modal_button(_tr("저축/절약  —  이번 달 지출을 줄인다", "Save/cut back  —  trim this month's spending"), "#3a6ea8", "_ap_save_money")

func _open_cat_dev():
	# _ap_study가 이미 세부 모달(독서/운동/명상)을 띄움 → 바로 호출
	_ap_study()

func _open_cat_people():
	_open_modal(_tr("사람 · 관계", "People · Relations"), true, "people_actions")
	_people_page_tab_buttons.clear()
	_people_action_cards.clear()
	_people_pad_hint_label = null
	_people_action_idx = 0
	if modal_scroll:
		modal_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
		modal_scroll.custom_minimum_size = Vector2(0, 500)
	if modal_panel:
		modal_panel.custom_minimum_size = Vector2(800, 660)
		modal_panel.offset_left = -400
		modal_panel.offset_right = 400
		modal_panel.offset_top = -330
		modal_panel.offset_bottom = 330
	modal_body.add_theme_constant_override("separation", 8)
	modal_body.add_child(_build_people_status_strip())
	_people_pad_hint_label = RichTextLabel.new()
	_people_pad_hint_label.bbcode_enabled = true
	_people_pad_hint_label.fit_content = true
	_people_pad_hint_label.scroll_active = false
	_people_pad_hint_label.custom_minimum_size = Vector2(0, 22)
	_people_pad_hint_label.add_theme_font_size_override("normal_font_size", 11)
	_people_pad_hint_label.add_theme_color_override("default_color", Color("#8f98a8"))
	if _font_bold:
		_people_pad_hint_label.add_theme_font_override("bold_font", _font_bold)
	modal_body.add_child(_people_pad_hint_label)
	modal_body.add_child(_build_people_page_tabs())
	_people_page_body = VBoxContainer.new()
	_people_page_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_people_page_body.add_theme_constant_override("separation", 7)
	modal_body.add_child(_people_page_body)
	_render_people_page()

func _people_pages() -> Array:
	return [
		{"id": "cast", "label": _tr("내 사람들", "My People")},
		{"id": "network", "label": _tr("인맥·휴식", "Network·Rest")},
	]

func _people_current_page_id() -> String:
	var pages := _people_pages()
	_people_page_idx = clampi(_people_page_idx, 0, pages.size() - 1)
	return str(pages[_people_page_idx].get("id", "cast"))

func _people_actions_for_page(page_id: String) -> Array:
	var actions: Array = []
	if page_id == "cast":
		for pid in ["father", "sangchul", "jiyeon", "daeun", "jaehyuk"]:
			if not GameState.cast_has_met(pid):
				continue
			var info: Dictionary = ImageRegistry.get_person_info(pid)
			var pname: String = str(info.get("name", _tr("인연", "Connection")))
			var accent: String = str(info.get("color", "#8a5a9a"))
			var aff: int = GameState.get_cast_affinity(pid)
			var verb := _tr("연락하기", "Reach out")
			if pid in ["jiyeon", "daeun"]:
				verb = _tr("만나기", "Meet up") if aff >= 50 else _tr("안부 묻기", "Check in")
			elif pid == "sangchul":
				verb = _tr("한 잔 하기", "Grab a drink")
			elif pid == "father":
				verb = _tr("전화드리기", "Call")
			elif pid == "jaehyuk":
				verb = _tr("만나기", "Meet up")
			var warmth: String
			if aff >= 75:
				warmth = _tr("가까운 사이", "Close")
			elif aff >= 45:
				warmth = _tr("알아가는 중", "Getting to know")
			elif aff >= 20:
				warmth = _tr("서먹한 편", "A bit distant")
			else:
				warmth = _tr("아직 낯선", "Still a stranger")
			actions.append({
				"title": "%s · %s" % [verb, pname],
				"subtitle": warmth,
				"accent": accent,
				"icon": "people",
				"fn": "_ap_contact_person",
				"arg": pid,
				"free": false,
			})
	else:
		actions.append({
			"title": _tr("인맥 넓히기", "Network"),
			"subtitle": _tr("모르는 사람들 사이로 섞인다", "mix with new people"),
			"accent": "#8a5a9a",
			"icon": "people",
			"fn": "_ap_network",
			"arg": null,
			"free": false,
		})
		if GameState.social_skill >= 50:
			actions.append({
				"title": _tr("VIP 인맥", "VIP network"),
				"subtitle": _tr("더 높은 곳의 사람들을 만난다", "meet people from a higher circle"),
				"accent": "#5a2a7a",
				"icon": "people",
				"fn": "_ap_vip_network",
				"arg": null,
				"free": false,
			})
		actions.append({
			"title": _tr("자유시간", "Free time"),
			"subtitle": _tr("한강을 걷거나 그냥 쉰다", "walk the Han River or just rest"),
			"accent": "#3a8a9a",
			"icon": "rest",
			"fn": "_ap_free_time",
			"arg": null,
			"free": false,
		})
	return actions

func _build_people_status_strip() -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#080b10")
	st.border_color = Color("#242a35")
	st.set_border_width_all(1)
	st.set_corner_radius_all(6)
	st.content_margin_left = 12
	st.content_margin_right = 12
	st.content_margin_top = 8
	st.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", st)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_theme_constant_override("separation", 2)
	row.add_child(copy)
	copy.add_child(_label(_tr("관계", "RELATIONS"), 10, "#6f7886"))
	copy.add_child(_label(_tr("혼자 강남에 가는 사람은 없다.", "No one reaches Gangnam alone."), 15, "#e8eaf0"))
	var met_count := 0
	for pid in ["father", "sangchul", "jiyeon", "daeun", "jaehyuk"]:
		if GameState.cast_has_met(pid):
			met_count += 1
	var stat := VBoxContainer.new()
	stat.custom_minimum_size = Vector2(190, 0)
	stat.add_theme_constant_override("separation", 2)
	row.add_child(stat)
	stat.add_child(_label(_tr("만난 사람", "KNOWN PEOPLE"), 10, "#6f7886"))
	stat.add_child(_label("%d / 5" % met_count, 15, "#cbd5e1"))
	var ap := VBoxContainer.new()
	ap.custom_minimum_size = Vector2(150, 0)
	ap.add_theme_constant_override("separation", 2)
	row.add_child(ap)
	ap.add_child(_label(_tr("행동력", "ACTION"), 10, "#6f7886"))
	ap.add_child(_label("%d / %d AP" % [GameState.action_points, GameState.max_action_points], 15, "#cbd5e1" if GameState.action_points > 0 else "#ff7070"))
	return panel

func _build_people_page_tabs() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var pages := _people_pages()
	for i in range(pages.size()):
		var idx := i
		var btn := _small_button("", "#111820")
		btn.focus_mode = Control.FOCUS_NONE
		btn.custom_minimum_size = Vector2(0, 36)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(Callable(self, "_set_people_page").bind(idx))
		row.add_child(btn)
		_people_page_tab_buttons.append(btn)
	_style_people_page_tabs()
	return row

func _style_people_page_tabs() -> void:
	var pages := _people_pages()
	for i in range(mini(_people_page_tab_buttons.size(), pages.size())):
		var btn := _people_page_tab_buttons[i] as Button
		if not is_instance_valid(btn):
			continue
		var selected := i == _people_page_idx
		btn.text = "%02d  %s" % [i + 1, str(pages[i].get("label", ""))]
		var normal := StyleBoxFlat.new()
		normal.bg_color = Color("#16202a" if selected else "#0c1118")
		normal.border_color = Color("#d9e2ea" if selected else "#252b35")
		normal.set_border_width_all(1)
		normal.border_width_bottom = 3 if selected else 1
		normal.set_corner_radius_all(3)
		normal.content_margin_left = 10
		normal.content_margin_right = 10
		normal.content_margin_top = 7
		normal.content_margin_bottom = 7
		var hover := normal.duplicate()
		hover.bg_color = normal.bg_color.lightened(0.10)
		btn.add_theme_stylebox_override("normal", normal)
		btn.add_theme_stylebox_override("hover", hover)
		btn.add_theme_stylebox_override("pressed", normal)
		btn.add_theme_stylebox_override("focus", normal)
		btn.add_theme_color_override("font_color", Color("#eef3f8" if selected else "#8f98a8"))

func _set_people_page(index: int) -> void:
	var pages := _people_pages()
	if pages.is_empty():
		return
	_people_page_idx = clampi(index, 0, pages.size() - 1)
	_people_action_idx = 0
	_render_people_page()

func _people_switch_page(delta: int) -> bool:
	var pages := _people_pages()
	if pages.is_empty():
		return true
	_people_page_idx = int(posmod(_people_page_idx + delta, pages.size()))
	_people_action_idx = 0
	AudioManager.play_ui_click()
	_render_people_page()
	return true

func _render_people_page() -> void:
	if not is_instance_valid(_people_page_body):
		return
	_clear_box(_people_page_body)
	_people_action_cards.clear()
	_style_people_page_tabs()
	var page_id := _people_current_page_id()
	var actions := _people_actions_for_page(page_id)
	_people_action_idx = clampi(_people_action_idx, 0, maxi(0, actions.size() - 1))
	var caption := _tr("곁에 있는 사람을 챙긴다", "Care for people near you") if page_id == "cast" else _tr("새 인맥과 회복 행동", "New contacts and recovery actions")
	_people_page_body.add_child(_build_job_page_caption(
		str(_people_pages()[_people_page_idx].get("label", "")),
		caption,
		"#9aa4b8"))
	if actions.is_empty():
		_people_page_body.add_child(_build_job_empty_card(_tr("아직 연락할 사람이 없습니다.", "No one to contact yet."), "#64748b"))
		_refresh_people_pad_hint()
		return
	for i in range(actions.size()):
		_people_page_body.add_child(_build_people_action_card(actions[i], i))
	_apply_people_cursor()

func _build_people_action_card(action: Dictionary, index: int) -> Button:
	var btn := _make_essential_action_card(
		str(action.get("title", "")),
		str(action.get("subtitle", "")),
		str(action.get("icon", "people")),
		str(action.get("accent", "#8a5a9a")),
		false,
		bool(action.get("free", false)),
		"")
	btn.custom_minimum_size = Vector2(0, 60)
	btn.focus_mode = Control.FOCUS_NONE
	btn.set_meta("people_action_idx", index)
	btn.set_meta("people_action_accent", str(action.get("accent", "#8a5a9a")))
	var fn_name := str(action.get("fn", ""))
	var fn_arg = action.get("arg", null)
	btn.pressed.connect(func():
		_run_people_action(fn_name, fn_arg)
	)
	_people_action_cards.append(btn)
	return btn

func _run_people_action(fn_name: String, fn_arg = null) -> void:
	if fn_name.is_empty():
		return
	AudioManager.play("click")
	_close_modal()
	if fn_arg == null:
		self.call(fn_name)
	else:
		self.call(fn_name, fn_arg)

func _people_selected_action() -> Dictionary:
	var actions := _people_actions_for_page(_people_current_page_id())
	if actions.is_empty():
		return {}
	_people_action_idx = clampi(_people_action_idx, 0, actions.size() - 1)
	return actions[_people_action_idx]

func _people_move_action(delta: int) -> bool:
	var actions := _people_actions_for_page(_people_current_page_id())
	if actions.is_empty():
		return true
	_people_action_idx = int(posmod(_people_action_idx + delta, actions.size()))
	AudioManager.play_ui_click()
	_apply_people_cursor()
	return true

func _people_confirm_action() -> bool:
	var action := _people_selected_action()
	if action.is_empty():
		return true
	_run_people_action(str(action.get("fn", "")), action.get("arg", null))
	return true

func _apply_people_cursor() -> void:
	for card in _people_action_cards:
		if not is_instance_valid(card):
			continue
		var btn := card as Button
		var selected := int(btn.get_meta("people_action_idx", -1)) == _people_action_idx and ControllerHints.is_pad_active()
		var accent := str(btn.get_meta("people_action_accent", "#8a5a9a"))
		var normal := StyleBoxFlat.new()
		normal.bg_color = Color("#0c0d11")
		normal.border_color = Color(COL_GOLD_BRIGHT if selected else accent)
		normal.border_width_left = 6 if selected else 5
		normal.set_border_width(SIDE_TOP, 2 if selected else 1)
		normal.set_border_width(SIDE_RIGHT, 2 if selected else 1)
		normal.set_border_width(SIDE_BOTTOM, 2 if selected else 1)
		normal.set_corner_radius_all(3)
		var hover := normal.duplicate()
		hover.bg_color = Color("#15161c")
		btn.add_theme_stylebox_override("normal", normal)
		btn.add_theme_stylebox_override("hover", hover)
		btn.add_theme_stylebox_override("pressed", normal)
		btn.add_theme_stylebox_override("focus", normal)
	_refresh_people_pad_hint()

func _refresh_people_pad_hint() -> void:
	if not is_instance_valid(_people_pad_hint_label):
		return
	if not ControllerHints.is_pad_active() or _modal_kind != "people_actions":
		_people_pad_hint_label.visible = false
		return
	_people_pad_hint_label.visible = true
	var action := _people_selected_action()
	var title := str(action.get("title", _tr("행동 없음", "No action")))
	_people_pad_hint_label.text = _tr(
		"[b]패드[/b]  LB/RB 페이지 · ↑↓ 행동 · %s 선택 · %s 뒤로  —  %s",
		"[b]Pad[/b]  LB/RB Page · ↑↓ Action · %s Select · %s Back  —  %s"
	) % [ControllerHints.south(), ControllerHints.east(), title]

func _handle_people_modal_input(event: InputEvent) -> bool:
	if event is InputEventKey and (event as InputEventKey).echo:
		return false
	if event.is_action_pressed("gd_tab_prev"):
		return _people_switch_page(-1)
	if event.is_action_pressed("gd_tab_next"):
		return _people_switch_page(1)
	if event.is_action_pressed("ui_up"):
		return _people_move_action(-1)
	if event.is_action_pressed("ui_down"):
		return _people_move_action(1)
	if event.is_action_pressed("ui_accept"):
		return _people_confirm_action()
	return false

func _open_cat_life():
	_open_modal(_tr("생활", "Living"), true)
	modal_body.add_child(_wrap_label(_tr("주거는 삶의 질이다. 더 나은 곳으로 갈수록 정신력에 여유가 생긴다.", "Housing is quality of life. A better place eases your Mental."), 13, "#7a8496"))
	var current_name: String = GameState.get_housing_display_name(GameState.housing)
	var current_expense: String = GameState.format_money(GameState.get_housing_expense())
	_cat_modal_status_card(
		_tr("현재 주거  —  %s", "Current home  —  %s") % current_name,
		_tr("월 고정비 %s · 현금 %s", "Monthly cost %s · Cash %s") % [current_expense, GameState.format_money(GameState.money)],
		"#64748b",
		"life",
		_tr("현재", "Now"))

	var next_id: String = str(GameState.get_housing_info().get("next", ""))
	if next_id.is_empty():
		_cat_modal_status_card(
			_tr("다음 주거 없음", "No further housing step"),
			_tr("이제 목표는 강남 입성 자산을 만드는 것이다.", "The goal now is building enough assets to reach Gangnam."),
			"#64748b",
			"life",
			_tr("완료", "Done"))
	elif GameState.can_upgrade_housing():
		var next_info = GameState.HOUSING_DATA.get(next_id, {})
		var move_label = _tr("이사  —  %s  (월 %s / 보증금 %s)", "Move  —  %s  (mo %s / deposit %s)") % [
			GameState.get_housing_display_name(next_id),
			GameState.format_money(float(next_info.get("expense", 0.0))),
			GameState.format_money(float(next_info.get("deposit", 0.0)))]
		_cat_modal_button(move_label, "#c8a040", "_ap_move_housing")
	else:
		var locked_info = GameState.HOUSING_DATA.get(next_id, {})
		_cat_modal_status_card(
			_tr("다음 이사  —  %s", "Next move  —  %s") % GameState.get_housing_display_name(next_id),
			_tr("필요 현금 %s · 부족액 %s", "Needs %s cash · Short %s") % [
				GameState.format_money(float(locked_info.get("req_cash", 0.0))),
				GameState.format_money(maxf(float(locked_info.get("req_cash", 0.0)) - GameState.money, 0.0)),
			],
			"#7a8496",
			"life",
			_tr("대기", "Need"))
	# 상점 항목 제거 — 서사 유물로 전환 예정

func _open_cat_gambling():
	var _in_recovery: bool = GameState.flags.get("in_recovery_started", false) \
			or GameState.flags.get("recovery_holding", false) \
			or GameState.flags.get("beat_addiction", false)
	var locked: bool = _in_recovery and not GameState.flags.get("relapsed", false)
	_open_modal(_tr("도박장", "Gambling Venues"), true)
	if locked:
		modal_body.add_child(_wrap_label(_tr("회복 중 — 지금은 들어가지 않기로 했다.", "In recovery — you decided not to go back in."), 13, "#7a8496"))
		return
	modal_body.add_child(_wrap_label(_tr("높은 수익, 더 높은 위험. 중독에 주의하라.", "High returns, higher risk. Watch for addiction."), 13, "#7a8496"))
	if GameState.flags.get("racetrack_guide_met", false) or GameState.flags.get("racetrack_visited", false):
		var rt_badge: String = _mastery_badge("racetrack")
		_cat_modal_button(_tr("경마장", "Racetrack") + rt_badge + _tr("  —  폼을 읽고 베팅한다", "  —  read the form and bet"), "#9a5a3a", "_open_racetrack")
	if GameState.flags.get("entered_network", false) and GameState.money >= 50000:
		var hm_badge: String = _mastery_badge("holdem")
		_cat_modal_button(_tr("지하 홀덤 클럽", "Underground Hold'em") + hm_badge + _tr("  —  인맥 있는 자만의 고위험 테이블", "  —  high-stakes, connections only"), "#6d4bd4", "_open_holdem")
	if GameState.flags.get("scalping_introduced", false) and GameState.investment_skill >= 15:
		var sc_badge: String = _mastery_badge("scalping")
		_cat_modal_button(_tr("스캘핑 트레이딩", "Scalp Trading") + sc_badge + _tr("  —  60초 실시간 매매", "  —  60-second live trading"), "#1a5f7a", "_open_scalping")
	if GameState.flags.get("casino_club_introduced", false):
		var cs_badge: String = _mastery_badge("casino")
		_cat_modal_button(_tr("정선 카지노", "Jeongseon Casino") + cs_badge + _tr("  —  바카라·블랙잭·다이사이 등", "  —  baccarat, blackjack, dai sai"), "#7b3fd1", "_open_jeongseon_casino")

func _add_action_section_header(parent: Control, title: String, _bg_hex: String):
	var lbl = _label("  " + title, 10, "#2e3a4e")
	lbl.custom_minimum_size = Vector2(0, 16)
	parent.add_child(lbl)

func _add_action_buttons(parent: Control, actions: Array, disabled: bool):
	for action in actions:
		var action_locked: bool = action.get("locked", false)
		var is_free: bool = action.get("free", false)
		var route_type: String = action.get("route", "")
		var focus_label: String = action.get("focus", "")
		var btn_color: String = action["color"]
		if action_locked or (disabled and not is_free):
			btn_color = "#1e1e2a"
		var btn = _action_button(action["label"], btn_color)
		btn.disabled = (disabled and not is_free) or action_locked
		var fn_name: String = action["fn"]
		btn.pressed.connect(func():
			if not route_type.is_empty():
				GameState.add_route_point(route_type, focus_label)
			call(fn_name)
		)
		parent.add_child(btn)

func _ap_study():
	if not GameState.spend_ap():
		return
	var study_type: int = randi() % 4
	var tag: String = [_tr("독서", "Reading"), _tr("운동", "Exercise"), _tr("명상", "Meditation"), _tr("투자공부", "Invest Study")][study_type]
	var pool: Array = [STUDY_READ_VIGNETTES, STUDY_EXERCISE_VIGNETTES, STUDY_MEDITATE_VIGNETTES, STUDY_INVEST_VIGNETTES][study_type]
	var v: Dictionary = pool[randi() % pool.size()]
	var eff: Dictionary = v.get("e", {}).duplicate()
	if study_type == 1:
		eff["appearance"] = eff.get("appearance", 0) + 1
	for k in eff:
		var val: int = int(eff[k])
		if k == "money":
			GameState.add_money(float(val))
		elif k == "stress" or k == "reputation":
			GameState.modify_hidden_stat(k, val)
		else:
			GameState.modify_stat(k, val)
	# 투자공부(type 3)는 invest 성향, 그 외(독서/운동/명상)는 career 성향으로 집계.
	# (기존엔 전부 career로 보내 invest 성향이 AP 행동에서 한 번도 안 쌓이던 버그)
	GameState.add_tendency("invest" if study_type == 3 else "career", 1)
	var _st_key := "et" if LocaleManager.is_english() else "t"
	var flavor: String = str(v.get(_st_key, v.get("t", "")))
	GameState.add_log(tag + " — " + flavor, "event")
	_show_vignette(_tr("자기계발", "Self-Dev"), flavor, eff, "#5a6ea8")
	turn_action_log.append("✓ " + tag + " — " + flavor.substr(0, 20))
	_render_ap_actions()
	_refresh_all()

func _ap_invest():
	if GameState.action_points <= 0:
		_show_toast(_tr("행동력이 없습니다", "No Action Points"), Color("#ff4444"))
		return
	_open_investments()

func _ap_job_hunt():
	if not GameState.spend_ap():
		return
	turn_action_log.append(_tr("구직활동 — 직업 목록 열람", "Job Hunt — browse job list"))
	_open_jobs()

func _ap_side_job():
	if not GameState.spend_ap():
		return
	_enter_minigame_overlay(aruba_game)
	aruba_game.open()

func _on_aruba_closed(earned: int, stress_delta: int, health_delta: int) -> void:
	_exit_minigame_overlay()
	var health_before: int = GameState.health
	GameState.add_money(float(earned))
	GameState.modify_hidden_stat("stress", stress_delta)
	var total_health_delta := -3 + health_delta
	GameState.modify_stat("health", total_health_delta)
	GameState.add_tendency("found", 1)   # 알바·부업 = 창업형 기질
	GameState.add_log(_tr("💼 알바 시프트 수입 %s (건강 %d→%d, 정신력 %+d)", "💼 Gig shift income %s (Health %d→%d, Mental %+d)") % [
		GameState.format_money(float(earned)), health_before, GameState.health, -stress_delta], "job")
	var _sj_v: Dictionary = SIDE_JOB_VIGNETTES[randi() % SIDE_JOB_VIGNETTES.size()]
	var mood: String = str(_sj_v.get("et" if LocaleManager.is_english() else "t", _sj_v.get("t", "")))
	turn_action_log.append(_tr("✓ 💼 알바 시프트 — ", "✓ 💼 Gig shift — ") + mood.substr(0, 22))
	AudioManager.play("money_gain")
	_show_effects_float({"money": earned, "health": total_health_delta, "mental": -stress_delta})
	_show_vignette(_tr("알바 시프트", "Gig Shift"), mood, {"money": earned, "health": total_health_delta, "mental": -stress_delta}, "#dc6a2a")
	_render_ap_actions()
	_refresh_all()

const _SAVE_SCENES = [
	{"t":"편의점 도시락 대신 집에서 밥을 했다. 재료비 이천 원으로 하루를 버텼다.", "et":"Cooked at home instead of a convenience store lunch box. Made it through the day on 2,000 won of ingredients."},
	{"t":"구독 서비스를 정리했다. 쓰지도 않는 것들이 매달 빠져나가고 있었다.", "et":"Cleared out subscriptions. Things I didn't even use had been going out every month."},
	{"t":"걸어서 한 시간. 교통비 2,800원이 아깝다는 생각을 세 번 했다.", "et":"Walked for an hour. Thought three times about whether 2,800 won in transit fare was worth it."},
	{"t":"커피 대신 편의점 아메리카노. 맛은 다르지만 잔액은 같아진다.", "et":"Convenience store americano instead of coffee. Different taste, but the balance ends up the same."},
	{"t":"외식을 참았다. 냉장고를 뒤졌다. 계란 두 개와 묵은 김치가 있었다.", "et":"Resisted eating out. Rummaged through the fridge. Two eggs and old kimchi."},
]

func _ap_save_money():
	if not GameState.spend_ap():
		return
	var saved: int = 30000 + randi() % 70000
	GameState.add_money(float(saved))
	GameState.modify_hidden_stat("stress", 2)
	GameState.add_tendency("career", 1)
	var _sv: Dictionary = _SAVE_SCENES[randi() % _SAVE_SCENES.size()]
	var scene: String = str(_sv.get("et" if LocaleManager.is_english() else "t", _sv.get("t", "")))
	GameState.add_log(_tr("💰 절약 — %s", "💰 Saving — %s") % scene, "event")
	_show_vignette(_tr("절약", "Saving"), scene + (_tr("\n\n%s 절약했다.", "\n\nSaved %s.") % GameState.format_money(saved)),
		{"money": saved, "stress": 2}, "#4a7a5a")
	turn_action_log.append(_tr("✓ 💰 절약 — %s", "✓ 💰 Saving — %s") % GameState.format_money(saved))
	AudioManager.play("money_gain")
	_render_ap_actions()
	_refresh_all()

func _ap_network():
	if not GameState.spend_ap():
		return
	GameState.flags["network_count"] = int(GameState.flags.get("network_count", 0)) + 1
	GameState.add_tendency("career", 1)
	var v: Dictionary = NETWORK_VIGNETTES[randi() % NETWORK_VIGNETTES.size()]
	var eff: Dictionary = v.get("e", {}).duplicate()
	eff["reputation"] = eff.get("reputation", 0) + 1
	for k in eff:
		var val: int = int(eff[k])
		if k == "money":
			GameState.add_money(float(val))
		elif k == "stress" or k == "reputation":
			GameState.modify_hidden_stat(k, val)
		else:
			GameState.modify_stat(k, val)
	var _nt_key := "et" if LocaleManager.is_english() else "t"
	var flavor: String = str(v.get(_nt_key, v.get("t", "")))
	GameState.add_log(_tr("🤝 인맥 — ", "🤝 Network — ") + flavor, "relationship")
	turn_action_log.append(_tr("✓ 🤝 인맥 넓히기 — ", "✓ 🤝 Networking — ") + flavor.substr(0, 20))
	GameState.stats_changed.emit()
	_show_vignette(_tr("인맥 넓히기", "Networking"), flavor, eff, "#8a5a9a")
	_render_ap_actions()
	_refresh_all()

func _ap_contact_person(person_id: String):
	if not GameState.spend_ap():
		return
	var info: Dictionary = ImageRegistry.PERSON_INFO.get(person_id, {})
	var pname: String = str(ImageRegistry.get_person_info(person_id).get("name", info.get("name", _tr("인연", "Connection"))))
	var accent: String = str(info.get("color", "#db2777"))
	var mental_before = GameState.mental
	GameState.modify_stat("mental", 5)
	GameState.modify_hidden_stat("stress", -3)
	GameState.apply_cast_effect(person_id, {"affinity": 4})
	var aff: int = GameState.get_cast_affinity(person_id)

	# 인물별 결과 텍스트 — 스토리 진행/관계 상태에 반응한다
	var flavor := _contact_flavor(person_id, aff)

	var msg = _tr("%s — 정신 %d→%d, 호감도 %d", "%s — Mental %d→%d, Affinity %d") % [pname, mental_before, GameState.mental, aff]
	GameState.add_log(msg + " / " + flavor, "relationship")
	turn_action_log.append("✓ " + msg)
	GameState.stats_changed.emit()
	_refresh_all()
	# A-1: 모달 닫고 스토리 영역에 인물 리액션 표시
	if not flavor.is_empty():
		_close_modal()
		_show_contact_reaction(pname, flavor, Color(accent))
	else:
		_show_toast(msg, Color(accent))
		_render_ap_actions()

## 연락하기 대사 — 스토리 플래그·호감도·자산 상태에 따라 달라진다
func _contact_flavor(person_id: String, aff: int) -> String:
	var f = GameState.flags
	var t = GameState.turn
	var rich: bool = GameState.get_total_asset_value() >= 500_000_000.0
	match person_id:
		"father":
			if f.get("father_reconciled", false):
				return _tr("아버지와의 통화가 더 이상 어색하지 않다. 시시콜콜한 동네 이야기가 이렇게 좋을 줄 몰랐다.", "Calls with my father aren't awkward anymore. I never knew small-town chatter could feel this good.")
			if f.get("visited_father", false):
				return _tr("병원에서 본 아버지의 야윈 손이 자꾸 떠오른다. 목소리라도 자주 들어야겠다.", "My father's frail hands at the hospital keep coming to mind. I should at least call him often.")
			if f.get("arc_father_02_done", false):
				return _tr("'밥은 먹었냐.' 그 말 뒤에 숨긴 것들이 들리는 것 같았다.", "'Did you eat?' I think I could hear all the things hidden behind those words.")
			if rich:
				return _tr("아버지는 여전히 돈 얘기를 먼저 꺼내지 않는다. '몸 상하면서 벌지 마라'는 말만 반복하신다.", "My father still never brings up money first. He just repeats, 'Don't earn it by wrecking your health.'")
			return _tr("아버지의 목소리는 늘 그대로다. 별일 없냐는 말에 괜히 코끝이 시큰하다.", "My father's voice is always the same. 'Everything okay?' — and my nose stings for no reason.")
		"sangchul":
			if f.get("arc_sangchul_jiyeon_reveal_seen", false):
				return _tr("임상철은 지연 이야기를 묻지 않았다. 다만 '네 판단을 믿어라'고만 했다.", "Sangchul didn't ask about Jiyeon. He only said, 'Trust your own judgment.'")
			if f.get("arc_sangchul_03_seen", false):
				return _tr("그의 네트워크 안에 들어온 뒤로, 임상철의 한 마디 한 마디가 다르게 들린다.", "Since I joined his network, every word from Sangchul lands differently.")
			if f.get("arc_sangchul_02_seen", false):
				return _tr("두 번째 커피 이후로 임상철은 진짜 이야기를 시작했다. 30년의 눈이 담긴 이야기들.", "After the second coffee, Sangchul started telling the real stories — ones holding 30 years of seeing.")
			return _tr("임상철은 소주잔을 기울이며 동네 부동산 돌아가는 얘기를 흘린다.", "Sangchul tilts his soju glass and lets slip how the local real estate is moving.")
		"jiyeon":
			if f.get("arc_jiyeon_truth_seen", false):
				return _tr("그날 이후, 한지연과의 대화에서 더 이상 숨기는 것이 없다. 그게 무엇보다 귀하다.", "Since that day, there's nothing left hidden in my talks with Jiyeon. That matters more than anything.")
			if aff >= 25:
				return _tr("한지연이 먼저 연락해오는 일이 잦아졌다. 다른 세계였던 그녀가, 조금씩 가까워진다.", "Jiyeon reaches out first more often now. A woman from another world is, little by little, getting closer.")
			return _tr("한지연과의 대화는 다른 세계를 들여다보는 창 같다.", "Talking with Jiyeon is like a window into another world.")
		"daeun":
			if f.get("daeun_together_path", false):
				return _tr("다은과는 이제 말이 필요 없는 사이가 됐다. 전화 너머의 숨소리만으로도 충분하다.", "Daeun and I no longer need words. Just her breathing on the other end of the line is enough.")
			if f.get("daeun_let_her_go", false):
				return _tr("다은은 고향에서 잘 지낸다고 했다. 잘된 일이다. 정말, 잘된 일이라고 생각하기로 했다.", "Daeun said she's doing well back home. That's good. Really — I've decided to think of it as a good thing.")
			if aff >= 12:
				return _tr("편의점 야간 조명 아래에서 나누는 대화가 어느새 하루의 끝 의식이 됐다.", "Our talks under the convenience store's night lights have somehow become my end-of-day ritual.")
			return _tr("김다은과 있으면 서울살이의 팍팍함이 잠깐 누그러진다.", "With Daeun, the harshness of life in Seoul softens for a while.")
		"jaehyuk":
			if f.get("jaehyuk_reported", false):
				return _tr("최재혁은 수사를 받고 있다고 한다. 옳은 일을 했다. 그런데 왜 아무 기분도 들지 않을까.", "They say Jaehyuk is under investigation. I did the right thing. So why don't I feel anything at all?")
			if f.get("jaehyuk_partnered", false):
				return _tr("재혁과의 통화는 점점 짧아지고, 단어는 점점 조심스러워진다. 이 길의 끝이 어딘지 둘 다 묻지 않는다.", "Calls with Jaehyuk grow shorter, the words more careful. Neither of us asks where this road ends.")
			if f.get("jaehyuk_exploited", false):
				return _tr("재혁은 약속한 돈을 보내온다. 침묵의 대가. 통장에 찍히는 숫자가 매번 차갑다.", "Jaehyuk sends the money he promised. The price of silence. The number on my bank account is cold every time.")
			if f.get("jaehyuk_scammed", false):
				return _tr("전화는 연결되지 않는다. '없는 번호'라는 안내음만. 그래도 가끔, 걸어보게 된다.", "The call won't connect. Just the 'number not in service' tone. Still, sometimes, I find myself dialing.")
			if f.get("hyunsu_warned", false):
				return _tr("재혁의 목소리는 여전히 자신만만하다. 현수의 말이 자꾸 겹쳐 들린다.", "Jaehyuk's voice is as confident as ever. Hyunsu's words keep echoing over it.")
			if t >= 32:
				return _tr("최재혁은 늘 큰 그림을 그린다. 듣고 있으면 가슴이 뛴다. 가끔은, 너무 잘 그려서 불안하다.", "Jaehyuk always paints the big picture. Listening makes my heart race. Sometimes, he paints it so well it unsettles me.")
			return _tr("최재혁은 늘 큰 그림을 그린다. 듣고 있으면 가슴이 뛴다.", "Jaehyuk always paints the big picture. Listening makes my heart race.")
		_:
			return _tr("사람을 챙기는 일에는 마음이 든다.", "Caring for people takes heart.")

# ── 변주되는 루틴 미니 장면 ──────────────────────────────────────
# 같은 행동도 매번 다른 짧은 장면(좋은 일·헛탕·소소한 행운)이 나온다.
const REST_VIGNETTES := [
	{"t":"한강을 걸었다. 강물이 도시의 소음을 잠시 데려갔다.", "et":"Walked along the Han River. For a moment, the water carried the city's noise away.", "e":{"mental":11,"stress":-9}},
	{"t":"알람 없이 푹 잤다. 며칠 만에 몸이 깃털처럼 가벼웠다.", "et":"Slept without an alarm. After days, the body felt light as a feather.", "e":{"health":6,"mental":7,"stress":-7}},
	{"t":"종일 누워 유튜브만 봤다. 쉰 건지 시간을 버린 건지 모르겠다.", "et":"Lay in bed watching YouTube all day. Not sure if it was rest or wasted time.", "e":{"mental":4,"stress":-2}},
	{"t":"쉬려고 누웠는데, 통장 잔고 생각에 도무지 잠이 안 왔다.", "et":"Lay down to rest, but couldn't sleep — kept thinking about the bank balance.", "e":{"mental":2,"stress":-1}},
	{"t":"동네 포장마차에서 혼술. 쓸쓸했지만, 따뜻했다.", "et":"Drinking alone at the neighborhood pojangmacha. Lonely, but warm.", "e":{"mental":6,"stress":-5,"money":-12000}},
	{"t":"공원 벤치에서 멍하니 사람들을 봤다. 다들 어딘가로 바쁘다.", "et":"Sat on a park bench watching people drift by. Everyone seems busy going somewhere.", "e":{"mental":5,"stress":-4}},
	{"t":"낮잠을 자다 강남 아파트에서 쫓겨나는 꿈을 꿨다. 식은땀.", "et":"Dozed off and dreamed of being evicted from a Gangnam apartment. Woke in a cold sweat.", "e":{"mental":3,"stress":-2}},
	{"t":"목욕탕에서 때를 밀었다. 묵은 피로가 조금 벗겨졌다.", "et":"Went to the bathhouse to scrub off the grime. Some of the accumulated fatigue peeled away too.", "e":{"health":4,"mental":5,"stress":-6,"money":-9000}},
	{"t":"길에서 꼬깃한 만원짜리를 주웠다. 오늘은 운이 좋다.", "et":"Found a crumpled ten-thousand won bill on the street. Today's a lucky day.", "e":{"mental":6,"stress":-5,"money":50000,"luck":1}},
	{"t":"쉬는 날인데 자꾸 일·돈 생각이 났다. 제대로 못 쉬었다.", "et":"Even on a day off, kept thinking about work and money. Couldn't truly rest.", "e":{"mental":3,"stress":-2}},
]
const SELFDEV_VIGNETTES := [
	{"t":"읽던 책의 한 구절이 오래 남았다. \"버티는 것도 재능이다.\"", "et":"A line from the book lingered. \"Enduring is also a talent.\"", "e":{"intelligence":3,"mental":2}},
	{"t":"집중이 안 됐다. 같은 페이지만 세 번 읽다 덮었다.", "et":"Couldn't focus. Read the same page three times and gave up.", "e":{"intelligence":1,"stress":2}},
	{"t":"투자 강의에서 무릎을 쳤다. 숫자 너머가 보이기 시작한다.", "et":"Had an 'aha' moment in an investing lecture. Starting to see beyond the numbers.", "e":{"investment_skill":3,"intelligence":1}},
	{"t":"운동을 했다. 땀이 머릿속 잡념까지 같이 씻어냈다.", "et":"Worked out. The sweat washed away the mental clutter too.", "e":{"health":5,"stress":-4}},
	{"t":"명상 앱을 켰는데 5분 만에 잠들었다. 그래도 개운했다.", "et":"Opened a meditation app and fell asleep in five minutes. Still felt refreshed.", "e":{"health":2,"mental":3,"stress":-2}},
	{"t":"강의를 듣다 문득, 내가 뭘 위해 이러나 싶었다.", "et":"Mid-lecture, suddenly wondered: what's all this even for?", "e":{"intelligence":2,"mental":-2}},
	{"t":"자격증 인강을 결제했다. 작심삼일이 될지, 발판이 될지.", "et":"Paid for a certification course online. Will it last three days, or become a stepping stone?", "e":{"intelligence":2,"money":-30000,"investment_skill":1}},
	{"t":"운동하다 거울 속 야윈 몸을 봤다. 그래도 조금은 가뿐해졌다.", "et":"Caught a glimpse of a thin body in the gym mirror. Still, felt a little lighter.", "e":{"health":4,"mental":-1,"stress":-2}},
	{"t":"도서관에서 부동산 책을 팠다. 용어가 조금씩 눈에 익는다.", "et":"Dug into a real estate book at the library. The terminology is slowly becoming familiar.", "e":{"investment_skill":2,"intelligence":1}},
	{"t":"새벽에 영어 단어를 외웠다. 쓸 일이 있을지는, 일단 모른다.", "et":"Memorized English vocabulary at dawn. Whether it'll ever come in handy, who knows.", "e":{"intelligence":2,"stress":1}},
]

const STUDY_READ_VIGNETTES := [
	{"t":"도서관에서 마감 직전까지 앉아 있었다. 창이 어두워질 때쯤 뭔가 연결이 됐다.", "et":"Sat at the library until closing. By the time the windows darkened, something clicked.", "e":{"intelligence":5,"stress":1}},
	{"t":"중고 서점에서 3,000원짜리 책을 집었다. 밑줄을 다섯 군데 그었다. 이걸로 됐다.", "et":"Picked up a 3,000-won book at a used bookstore. Made five underlines. That was enough.", "e":{"intelligence":4}},
	{"t":"공부 카페에서 네 시간. 집중이 안 됐는데 그냥 있었다. 어느 순간 됐다.", "et":"Four hours at a study café. Couldn't concentrate, but stayed put. At some point it clicked.", "e":{"intelligence":3,"stress":2}},
	{"t":"유튜브 알고리즘이 뜻밖의 강의를 추천했다. 한 시간 반을 멈추지 않고 봤다.", "et":"The YouTube algorithm recommended an unexpected lecture. Watched an hour and a half without stopping.", "e":{"intelligence":5,"mental":2}},
	{"t":"전자책 앱으로 지하철에서 서서 읽었다. 눈이 아팠지만 멈추지 않았다.", "et":"Read an e-book standing on the subway. Eyes ached, but couldn't stop.", "e":{"intelligence":4,"health":-1}},
	{"t":"좋아하던 작가 신간이 도서관에 있었다. 기분 좋은 날이었다.", "et":"Found a new release by a favorite author at the library. Good day.", "e":{"intelligence":3,"mental":4}},
	{"t":"읽다가 잠들었다. 일어나서 다시 폈다. 두 번 읽은 페이지가 더 잘 들어왔다.", "et":"Fell asleep reading, woke up and opened it again. The page I read twice stuck better.", "e":{"intelligence":3,"health":1}},
	{"t":"오늘은 진짜 집중이 안 됐다. 그래도 앉아있는 것 자체가 훈련이다.", "et":"Genuinely couldn't focus today. But sitting there is itself training.", "e":{"intelligence":2,"stress":3}},
	{"t":"책 한 구절이 내 얘기 같아서 접어뒀다. 나중에 다시 볼 것 같다.", "et":"Folded a page where a line felt like my own story. Will come back to it.", "e":{"intelligence":4,"mental":3}},
	{"t":"열람실. 옆 사람도 열심히 뭔가를 읽고 있었다. 덩달아 집중이 됐다.", "et":"Reading room. The person next to me was reading intently too. Focused without even trying.", "e":{"intelligence":4,"stress":-2}},
]

const STUDY_EXERCISE_VIGNETTES := [
	{"t":"한강을 달렸다. 처음 2km는 힘들었다. 그 다음부터는 생각이 없어졌다.", "et":"Ran along the Han River. The first 2km was hard. After that, thoughts disappeared.", "e":{"health":10,"stress":-7}},
	{"t":"헬스장. 오늘치를 다 채웠다. 샤워하고 나왔을 때 세상이 조금 달라 보였다.", "et":"Gym. Hit the day's quota. When I stepped out of the shower, the world looked a little different.", "e":{"health":12,"stress":-6,"mental":2}},
	{"t":"공원을 뛰었다. 할머니가 옆에서 걷고 있었다. 나도 저 나이까지 이러고 싶다.", "et":"Jogged in the park. An elderly woman was walking beside me. I want to still be doing this at her age.", "e":{"health":9,"stress":-5,"mental":3}},
	{"t":"어젯밤 술이 남아서 쉬엄쉬엄했다. 그래도 안 하는 것보다 낫다.", "et":"Still a bit hungover from last night, so took it easy. Still better than nothing.", "e":{"health":6,"stress":-4}},
	{"t":"줄넘기 500개. 땀이 통 빠졌다. 한강 바람이 차게 식혔다.", "et":"500 jump ropes. Sweated hard. The Han River breeze cooled it all down.", "e":{"health":11,"stress":-8}},
	{"t":"오늘은 몸이 안 좋아서 가볍게만 했다. 그래도 나왔다는 게 중요하다.", "et":"Body wasn't feeling great today, kept it light. But the fact I showed up matters.", "e":{"health":7,"stress":-3}},
	{"t":"PT 선생님이 자세를 고쳐줬다. 같은 무게인데 훨씬 힘들어졌다.", "et":"The trainer corrected my form. Same weight, but now it's much harder.", "e":{"health":10,"stress":-5,"intelligence":1}},
	{"t":"근처 공원 벤치 사이를 달렸다. 서울도 이렇게 보면 좁지 않다.", "et":"Ran between park benches nearby. Seoul doesn't feel so cramped from this angle.", "e":{"health":9,"stress":-6,"mental":2}},
	{"t":"헬스장 가는 게 귀찮았는데 막상 하니까 잘 했다. 항상 그렇다.", "et":"Dreaded going to the gym, but once started, glad I went. Always the same story.", "e":{"health":11,"stress":-7}},
	{"t":"운동하다 거울 속 자신을 봤다. 조금은 나아지고 있다.", "et":"Caught a glimpse of myself in the mirror mid-workout. Getting a little better.", "e":{"health":10,"stress":-6}},
]

const STUDY_MEDITATE_VIGNETTES := [
	{"t":"한강 벤치에서 눈을 감았다. 오리 우는 소리가 들렸다. 30분이 5분처럼 지나갔다.", "et":"Closed my eyes on a Han River bench. Could hear ducks. Thirty minutes passed like five.", "e":{"mental":11,"stress":-9}},
	{"t":"명상 앱을 따라했다. 숨을 세다가 잠들었다. 그래도 일어나니 개운했다.", "et":"Followed a meditation app. Started counting breaths and fell asleep. Still felt refreshed after.", "e":{"mental":9,"stress":-7,"health":2}},
	{"t":"아무것도 안 했다. 천장만 봤다. 그게 오늘은 필요했다.", "et":"Did nothing. Just stared at the ceiling. That's what I needed today.", "e":{"mental":10,"stress":-8}},
	{"t":"공원 벤치. 나뭇잎이 흔들리는 걸 아무 생각 없이 봤다. 귀가 트였다.", "et":"Park bench. Watched leaves swaying without thinking. Ears seemed to clear.", "e":{"mental":12,"stress":-9}},
	{"t":"일기를 썼다. 쓰다 보니 내가 무섭다고 느낀 게 뭔지 알았다.", "et":"Kept a journal. Figured out what I was afraid of by the time I finished writing.", "e":{"mental":10,"stress":-6,"intelligence":2}},
	{"t":"음악 없이 걸었다. 서울 소리가 잘 들렸다. 나쁘지 않았다.", "et":"Walked without music. Seoul's sounds came through clearly. Not bad.", "e":{"mental":8,"stress":-7}},
	{"t":"방 불을 끄고 그냥 누워 있었다. 잡념이 먼저 왔다가 나중에 떠났다.", "et":"Turned off the lights and just lay there. Stray thoughts came first, then left.", "e":{"mental":10,"stress":-8}},
	{"t":"찜질방에서 두 시간. 아무것도 안 하는 게 이렇게 비싼 일이었나.", "et":"Two hours at the jjimjilbang. So this is what 'doing nothing' actually costs.", "e":{"mental":11,"stress":-9,"health":3,"money":-12000}},
	{"t":"숨을 10번 깊게 쉬었다. 단순한데, 해보면 다르다.", "et":"Took ten deep breaths. Simple, but different when you actually do it.", "e":{"mental":9,"stress":-8}},
	{"t":"머릿속을 비우려고 했는데 오히려 정리가 됐다. 결정이 하나 났다.", "et":"Tried to clear my head, ended up organizing my thoughts instead. Made one decision.", "e":{"mental":12,"stress":-7,"intelligence":2}},
]

const STUDY_INVEST_VIGNETTES := [
	{"t":"유튜브 투자 채널 두 개를 봤다. 의견이 정반대였다. 그래서 더 생각하게 됐다.", "et":"Watched two YouTube investing channels. They had opposite opinions. Made me think more.", "e":{"investment_skill":3,"intelligence":1}},
	{"t":"PER, PBR, ROE. 단어가 점점 친숙해지고 있다. 그게 진짜 공부다.", "et":"PER, PBR, ROE. The terms are getting more familiar. That's the real education.", "e":{"investment_skill":4,"intelligence":1}},
	{"t":"증권사 리포트를 처음부터 끝까지 읽었다. 반밖에 이해 못 했지만 반은 됐다.", "et":"Read a brokerage report cover to cover. Understood half. That counts.", "e":{"investment_skill":3,"intelligence":2}},
	{"t":"차트를 봤다. 패턴이 보이기 시작한다. 아직 가설 수준이지만.", "et":"Studied charts. Starting to see patterns. Still hypothetical, but.", "e":{"investment_skill":3}},
	{"t":"경제 뉴스를 읽었다. 숫자가 이야기로 보이기 시작한다.", "et":"Read the economic news. Numbers are starting to look like stories.", "e":{"investment_skill":3,"intelligence":1}},
	{"t":"커뮤니티에서 고수들 글을 읽었다. 아는 만큼 보인다는 말이 이런 거구나.", "et":"Read expert posts in investing forums. So this is what 'you see as much as you know' means.", "e":{"investment_skill":4,"mental":1}},
	{"t":"시뮬레이션 계좌로 연습했다. 실제 돈이 아니었는데도 두근거렸다.", "et":"Practiced with a simulation account. Heart was pounding even though it wasn't real money.", "e":{"investment_skill":4,"stress":2}},
	{"t":"재무제표 기초 강의를 봤다. 숫자에 이야기가 있다는 걸 처음 알았다.", "et":"Watched a financial statement basics lecture. First time realizing numbers have stories.", "e":{"investment_skill":3,"intelligence":2}},
	{"t":"투자 책을 반쯤 읽다가 덮었다. 그래도 남은 게 있다.", "et":"Got halfway through an investing book and put it down. Something still stayed.", "e":{"investment_skill":2,"intelligence":1}},
	{"t":"오늘 배운 것 하나: 모르는 걸 모른다고 아는 것도 실력이다.", "et":"One thing learned today: knowing what you don't know is also skill.", "e":{"investment_skill":3,"intelligence":1}},
]

const NETWORK_VIGNETTES := [
	{"t":"업계 세미나. 명함을 세 개 받았다. 두 개는 언젠가 쓸 것 같다.", "et":"Industry seminar. Received three business cards. Two of them might actually be useful someday.", "e":{"social_skill":1,"reputation":1,"stress":2}},
	{"t":"단톡방에 글을 올렸다. 답이 두 개 달렸다. 그 중 한 명이 실제로 도움이 됐다.", "et":"Posted in a group chat. Two replies came in. One of them actually helped.", "e":{"social_skill":1,"reputation":1,"intelligence":1,"stress":1}},
	{"t":"전 직장 선배에게 커피를 샀다. 근황을 들었다. 정보가 됐다.", "et":"Bought coffee for a former senior colleague. Heard their news. It turned into useful information.", "e":{"social_skill":1,"reputation":2,"stress":2,"money":-6000}},
	{"t":"링크드인 프로필을 업데이트했다. 누군가 봐주길 바라는 마음으로.", "et":"Updated the LinkedIn profile. Hoping someone will notice.", "e":{"social_skill":1,"reputation":1,"stress":1}},
	{"t":"스터디 모임에 나갔다. 말 잘하는 사람을 봤다. 나도 저렇게 말하고 싶다.", "et":"Attended a study group. Saw someone who spoke really well. I want to speak like that.", "e":{"social_skill":2,"intelligence":1,"stress":2}},
	{"t":"선배 소개로 낯선 사람을 만났다. 어색했지만 끝날 때쯤엔 편했다.", "et":"Met a stranger through a senior's introduction. Awkward at first, comfortable by the end.", "e":{"social_skill":1,"reputation":1,"stress":3}},
	{"t":"오늘 만난 사람이 한 말이 머릿속에 남는다. 그게 인맥의 진짜 가치다.", "et":"Something the person I met today said is still in my head. That's the real value of connections.", "e":{"social_skill":1,"reputation":1,"intelligence":2,"stress":1}},
	{"t":"네트워킹 행사. 명함 교환하다가 내 명함이 없다는 걸 알았다.", "et":"Networking event. Started exchanging cards and realized I didn't have any.", "e":{"social_skill":1,"reputation":1,"stress":4}},
	{"t":"커피챗을 했다. 상대방이 먼저 연락하겠다고 했다. 그게 진짜인지는 모른다.", "et":"Had a coffee chat. They said they'd reach out first. Not sure if that was real.", "e":{"social_skill":1,"reputation":1,"stress":2}},
	{"t":"약속을 잡고 나갔다가 그 사람이 취소했다. 뭐 어때. 일단 나오긴 했다.", "et":"Made plans and headed out, but they cancelled. Whatever. I made it out.", "e":{"social_skill":1,"stress":1}},
]

const JOB_HUNT_VIGNETTES := [
	{"t":"원하는 자리는 없었다. 원할 수 있는 자리를 찾기 시작했다.", "et":"There were no positions I wanted. Started looking for positions I could want."},
	{"t":"지원 자격: 경력 3년 이상. 33세 신입은 없나.", "et":"Requirements: 3+ years experience. Is there really no entry-level for a 33-year-old?"},
	{"t":"스펙 조건을 읽었다. 하나씩 체크했다. 마지막 줄에서 멈췄다.", "et":"Read the qualifications. Checked them one by one. Stopped at the last line."},
	{"t":"오늘도 공고를 훑었다. 열두 개. 그 중 지원할 수 있는 건 셋.", "et":"Scrolled through postings again today. Twelve of them. Three were actually options."},
	{"t":"합격 문자 소리를 미리 상상했다. 기다리는 게 에너지 든다.", "et":"Pre-imagined the sound of an acceptance text. Waiting takes energy."},
	{"t":"JD를 읽다가 '우리 팀은 함께 성장합니다'라는 문구를 봤다. 뭔가 마음에 걸렸다.", "et":"Read a JD and saw 'our team grows together.' Something about it felt off."},
	{"t":"이력서를 첨부했다. 제출 버튼을 눌렀다. 답장이 올지는 모른다.", "et":"Attached the resume. Hit submit. Whether a reply comes is anyone's guess."},
	{"t":"이 회사 문화가 좋다고 들었다. 연봉은 낮다. 고민할 시간이 없다.", "et":"Heard the culture here was good. The salary is low. No time to think about it."},
	{"t":"공고 하나를 저장해뒀다. 마감이 내일이다. 오늘 지원한다.", "et":"Saved one posting. Deadline is tomorrow. Applying today."},
	{"t":"강남은 아직 멀지만, 일단 취직부터. 그게 첫 번째 계단이다.", "et":"Gangnam is still far, but first — get a job. That's the first step."},
]

const SIDE_JOB_VIGNETTES := [
	{"t":"편의점 야간. 새벽 세 시, 손님이 없었다. 그 시간이 가장 길었다.", "et":"Late-night convenience store shift. No customers at 3 AM. That hour felt the longest."},
	{"t":"배달을 돌았다. 비가 왔다. 우비가 없었다.", "et":"Did delivery runs. It rained. No raincoat."},
	{"t":"투잡이라는 말을 쓰기엔 부끄러운 금액이었다. 그래도 통장에 찍혔다.", "et":"Too embarrassing to call it a second job for that amount. Still, it showed up in the account."},
	{"t":"대리운전을 했다. 손님이 취해 있었다. 내가 더 멀쩡해 보였다.", "et":"Did a designated driving shift. The passenger was drunk. I looked more composed."},
	{"t":"카페 알바 마감 청소. 커피 찌꺼기를 치우면서 내일을 생각했다.", "et":"Closing cleanup at the café part-time. Thought about tomorrow while scrubbing out coffee grounds."},
	{"t":"주문이 폭발하는 금요일 저녁. 손이 빨라졌다. 몸이 기억하는 것들.", "et":"Orders exploding on Friday evening. Hands got faster. Things the body remembers."},
	{"t":"시급을 시간으로 나눴다. 안 나눴으면 더 좋았을 것 같다.", "et":"Divided the hourly wage by hours. Wish I hadn't."},
	{"t":"알바 끝나고 지하철을 탔다. 신발 바닥이 뜨거웠다.", "et":"Took the subway home after the part-time shift. Soles of my shoes were hot."},
	{"t":"30대 초반에 이러고 있다는 생각. 잠깐 했다. 지운다. 지금은 이게 맞다.", "et":"The thought of doing this in my early thirties. Had it for a moment. Erased it. This is right for now."},
	{"t":"작은 금액이지만, 내가 번 돈이다. 그 느낌은 크다.", "et":"Small amount, but money I earned myself. That feeling is big."},
]

const STARTUP_VIGNETTES := [
	{"t":"MVP를 만들었다. 아무도 안 쓰는 것 같지만, 이게 시작이다.", "et":"Built an MVP. Seems like no one is using it, but this is the beginning.", "e":{"reputation":2,"intelligence":1,"stress":5}},
	{"t":"피치덱을 고쳤다. 열두 번째다. 이번엔 좀 나은 것 같다.", "et":"Revised the pitch deck. Twelfth time. This one feels a bit better.", "e":{"reputation":2,"intelligence":2,"stress":5}},
	{"t":"아이디어를 노트에 적었다. 밤 세 시였다. 틀릴 수도 있다. 일단 적었다.", "et":"Wrote an idea in a notebook. It was 3 AM. Could be wrong. Wrote it anyway.", "e":{"reputation":2,"intelligence":1,"stress":4}},
	{"t":"공동창업자 없이 혼자 다 하고 있다. 그게 맞는 건지 모르겠다.", "et":"Running everything alone without a co-founder. Not sure if that's right.", "e":{"reputation":2,"intelligence":1,"stress":6,"mental":-2}},
	{"t":"첫 유저가 생겼다. 지인이었지만, 그래도 유저다.", "et":"Got the first user. It was someone I knew, but still — a user.", "e":{"reputation":3,"mental":3,"stress":3}},
	{"t":"경쟁사를 조사했다. 이미 잘 하고 있었다. 더 잘 하면 된다.", "et":"Researched the competition. They're already doing well. I'll just do better.", "e":{"reputation":2,"intelligence":2,"stress":5}},
	{"t":"투자자 미팅 자료를 만들었다. 내 꿈을 슬라이드에 넣는 게 쑥스러웠다.", "et":"Made investor meeting materials. Felt a bit embarrassed putting my dream into slides.", "e":{"reputation":2,"intelligence":1,"stress":5}},
	{"t":"세 달째다. 수익은 없다. 가능성은 있다. 그 차이로 버티고 있다.", "et":"Three months in. No revenue. Still possible. That gap is what I'm living on.", "e":{"reputation":2,"intelligence":1,"stress":6,"mental":-2}},
	{"t":"세무사에게 전화를 했다. 사업자 등록 얘기를 들었다. 실감이 났다.", "et":"Called an accountant. Got briefed on business registration. It felt real.", "e":{"reputation":2,"intelligence":2,"stress":4}},
	{"t":"오늘 한 일이 3개월 뒤 어떤 결과를 낼지 모른다. 그래도 했다.", "et":"No idea what today's work will produce in three months. Did it anyway.", "e":{"reputation":2,"intelligence":1,"stress":5}},
]

const CONTENT_VIGNETTES := [
	{"t":"영상을 올렸다. 조회수 17. 그 중 10개는 내가 새로고침했다.", "et":"Posted the video. 17 views. Ten of those were me refreshing.", "e":{"reputation":1,"mental":5,"luck":1}},
	{"t":"섬네일을 다섯 번 바꿨다. 올리고 나서 또 바꾸고 싶었다.", "et":"Changed the thumbnail five times. Wanted to change it again after posting.", "e":{"reputation":1,"mental":4,"stress":2}},
	{"t":"구독자가 한 명 늘었다. 누군지는 모른다. 오늘은 그게 충분했다.", "et":"One new subscriber. Don't know who. That was enough for today.", "e":{"reputation":2,"mental":6,"luck":1}},
	{"t":"댓글이 하나 달렸다. '좋아요'. 그게 오늘 하루를 버티게 했다.", "et":"One comment came in: 'Like.' That carried me through the rest of the day.", "e":{"reputation":2,"mental":7}},
	{"t":"오늘 편집이 생각보다 잘 됐다. 뿌듯한데 아무도 모른다.", "et":"Today's edit came out better than expected. Proud, but no one knows.", "e":{"reputation":1,"mental":5}},
	{"t":"알고리즘이 잠깐 봐줬다. 조회수가 튀었다가 다시 내려갔다.", "et":"The algorithm glanced at it briefly. Views jumped, then fell back.", "e":{"reputation":2,"mental":5,"luck":1}},
	{"t":"콘텐츠를 만들면서 내가 뭘 생각하는지 알게 됐다. 부산물이 주인공이 되기도 한다.", "et":"Making content helped me figure out what I actually think. The byproduct becomes the main thing.", "e":{"reputation":1,"mental":6,"intelligence":1}},
	{"t":"썸네일, 제목, 태그. 세 개 다 틀렸을 수도 있다. 올렸다.", "et":"Thumbnail, title, tags. Could have gotten all three wrong. Posted it anyway.", "e":{"reputation":1,"mental":4,"stress":2}},
	{"t":"예전 영상에 갑자기 조회수가 붙었다. 이유를 모르겠다. 그냥 기쁘다.", "et":"An old video suddenly got views. No idea why. Just happy.", "e":{"reputation":2,"mental":6,"luck":2}},
	{"t":"영상을 찍으면서 말이 꼬였다. 열다섯 번 다시 찍었다. 됐다.", "et":"Kept stumbling over words while filming. Took fifteen retakes. Got it.", "e":{"reputation":1,"mental":5,"stress":3}},
]

## ── 은행 — 대출/상환 (빚으로 판을 키운다, 행동력 무소비) ────────────
func _open_bank():
	_open_modal(_tr("은행", "Bank"), true)
	modal_body.add_child(_modal_section_header(
		_tr("대출 / 상환", "Borrow / Repay"),
		"money",
		"#f0b429",
		_tr("빚은 도구다. 다만 이자는 매달, 반드시, 먼저 나간다.", "Debt is a tool. But interest goes out every month, without fail, first.")))
	var bank_header_row := HBoxContainer.new()
	bank_header_row.add_theme_constant_override("separation", 8)
	modal_body.add_child(bank_header_row)
	var bank_desc_lbl := Label.new()
	bank_desc_lbl.text = _tr("행동력 소비 없음 — 대출은 즉시 현금, 상환은 즉시 부채 감소.", "No AP cost — borrowing is instant cash, repaying instantly cuts debt.")
	bank_desc_lbl.add_theme_font_size_override("font_size", 12)
	bank_desc_lbl.add_theme_color_override("font_color", Color("#8892a4"))
	bank_desc_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bank_desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bank_header_row.add_child(bank_desc_lbl)
	var bank_gloss_btn := _icon_small_button(_tr("용어", "Terms"), "info", "#2a3a5a")
	bank_gloss_btn.custom_minimum_size = Vector2(78, 32)
	bank_gloss_btn.pressed.connect(func(): _open_glossary(_tr("금융 용어", "Finance Terms"), "bank"))
	bank_header_row.add_child(bank_gloss_btn)
	var net: float = GameState.get_total_asset_value()
	modal_body.add_child(_label(_tr("현금 %s   |   순자산 %s", "Cash %s   |   Net Worth %s") % [
		GameState.format_money(GameState.money), GameState.format_money(net)], 13, "#c8d0df"))
	# ── 신용등급 — 한도와 금리를 정하는 숫자 ──
	var grade: int = GameState.get_credit_grade()
	var grade_label: String = GameState.get_credit_grade_label()
	var grade_color := "#34d399" if grade <= 3 else ("#f0b429" if grade <= 6 else ("#f97316" if grade <= 8 else "#ff4444"))
	modal_body.add_child(_label(_tr("신용등급  %d등급 (%s)  — 점수 %d/100", "Credit  Grade %d (%s)  — Score %d/100") % [grade, grade_label, GameState.get_credit_score()], 15, grade_color))
	modal_body.add_child(_wrap_label(_tr("직장·근속·소득·자산이 등급을 올리고, 부채 비율과 잔고 바닥 이력이 깎습니다.\n금리는 변동금리 — 등급이 떨어지면 보유한 빚의 이자도 같이 오릅니다.", "Job · tenure · income · assets raise your grade; debt ratio and a history of hitting zero lower it.\nRates are variable — if your grade drops, interest on existing debt rises too."), 11, "#6a7486"))
	if net < 0:
		modal_body.add_child(_wrap_label(_tr("위험: 순자산 마이너스 — -1억이면 파산, -2억이면 빚의 소용돌이입니다.", "Danger: negative net worth — -100M means bankruptcy, -200M a debt spiral."), 12, "#ff4444"))
	for product in GameState.LOAN_PRODUCTS:
		var info: Dictionary = GameState.LOAN_PRODUCTS[product]
		var owed: float = float(GameState.loans.get(product, 0.0))
		var limit: float = GameState.get_loan_limit(product)
		var rate: float = GameState.get_loan_rate(product)
		var sep := HSeparator.new()
		sep.add_theme_color_override("color", Color("#252535"))
		modal_body.add_child(sep)
		modal_body.add_child(_label(_tr("%s — 월 이자 %.2f%% (연 %.1f%%)", "%s — Monthly %.2f%% (Annual %.1f%%)") % [
			GameState.get_loan_name(product), rate * 100.0, rate * 1200.0], 15, "#e2e8f0"))
		if limit <= 0.0:
			if GameState.monthly_income <= 0:
				modal_body.add_child(_wrap_label(_tr("  직장(소득)이 있어야 신용대출이 가능합니다.", "  You need a job (income) to qualify for a credit loan."), 12, "#6a7486"))
			else:
				modal_body.add_child(_wrap_label(_tr("  신용 %d등급 — 1금융은 7등급 이내만 가능합니다. 등급을 올리세요.", "  Grade %d — prime banks require grade 7 or better. Raise your grade.") % grade, 12, "#f97316"))
			if owed <= 0.0:
				continue
		var month_cost: float = owed * rate
		var status := _tr("  잔액 %s / 한도 %s", "  Balance %s / Limit %s") % [GameState.format_money(owed), GameState.format_money(limit)]
		if owed > 0.0:
			status += _tr("  (월 이자 %s)", "  (Monthly interest %s)") % GameState.format_money(month_cost)
		modal_body.add_child(_wrap_label(status, 12, "#8892a4" if owed <= 0.0 else "#f59e0b"))
		# 대출 버튼
		if owed < limit:
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 8)
			modal_body.add_child(row)
			for amt in [5_000_000.0, 20_000_000.0]:
				if limit - owed >= amt:
					var b = _small_button("+%s" % GameState.format_money(amt), "#14532d")
					b.pressed.connect(_bank_borrow.bind(product, amt))
					row.add_child(b)
			var bmax = _small_button(_tr("한도까지", "Max"), "#7c2d12")
			bmax.pressed.connect(_bank_borrow.bind(product, limit - owed))
			row.add_child(bmax)
		# 상환 버튼
		if owed > 0.0:
			var rrow := HBoxContainer.new()
			rrow.add_theme_constant_override("separation", 8)
			modal_body.add_child(rrow)
			var r1 = _small_button(_tr("500만 상환", "Repay 5M"), "#1e3a5f")
			r1.pressed.connect(_bank_repay.bind(product, 5_000_000.0))
			rrow.add_child(r1)
			var r2 = _small_button(_tr("전액 상환", "Repay All"), "#1e3a5f")
			r2.pressed.connect(_bank_repay.bind(product, owed))
			rrow.add_child(r2)
	var back_btn := _icon_button(_tr("투자 화면으로", "To Invest Screen"), "invest", "#1a1a28")
	back_btn.pressed.connect(_open_investments)
	modal_body.add_child(back_btn)

func _bank_borrow(product: String, amount: float):
	var return_to_invest_page := _modal_kind == "investments"
	if GameState.borrow(product, amount):
		AudioManager.play("money_gain")
		_show_toast(_tr("대출 실행 +%s", "Loan disbursed +%s") % GameState.format_money(amount), Color("#00c896"))
	else:
		_show_toast(_tr("한도를 초과했습니다", "Exceeds your limit"), Color("#ff4444"))
	if return_to_invest_page:
		_invest_page_idx = _invest_page_index_for("bank")
		_open_investments()
	else:
		_open_bank()
	_refresh_all()

func _bank_repay(product: String, amount: float):
	var return_to_invest_page := _modal_kind == "investments"
	if GameState.repay(product, amount):
		_show_toast(_tr("상환 완료", "Repaid"), Color("#c9a227"))
	else:
		_show_toast(_tr("상환할 현금이 없습니다", "Not enough cash to repay"), Color("#ff4444"))
	if return_to_invest_page:
		_invest_page_idx = _invest_page_index_for("bank")
		_open_investments()
	else:
		_open_bank()
	_refresh_all()

## 경마장 — 시각 미니게임 오버레이를 연다 (방문 = 시간 1 소비)
func _open_racetrack():
	if not GameState.spend_ap():
		return
	_enter_minigame_overlay(racetrack)
	racetrack.open()

func _on_racetrack_closed():
	_exit_minigame_overlay()
	turn_action_log.append(_tr("✓ 🏇 경마장", "✓ 🏇 Racetrack"))
	GameState.add_log(_tr("🏇 경마장에 다녀왔다.", "🏇 Went to the racetrack."), "event")
	_check_addiction_warnings()
	_refresh_all()
	_render_ap_actions()

func _open_holdem():
	if not GameState.spend_ap():
		return
	_enter_minigame_overlay(holdem_club)
	holdem_club.open()

func _on_holdem_closed():
	_exit_minigame_overlay()
	turn_action_log.append(_tr("✓ 🃏 홀덤 클럽", "✓ 🃏 Hold'em Club"))
	GameState.add_log(_tr("🃏 지하 홀덤 클럽을 나왔다.", "🃏 Left the underground hold'em club."), "event")
	_check_addiction_warnings()
	_refresh_all()
	_render_ap_actions()


func _open_scalping():
	if not GameState.spend_ap():
		return
	_enter_minigame_overlay(scalping_game)
	scalping_game.open()

func _on_scalping_closed():
	_exit_minigame_overlay()
	turn_action_log.append(_tr("✓ 스캘핑 트레이딩", "✓ Scalping Trading"))
	GameState.add_log(_tr("스캘핑 트레이딩 세션을 마쳤다.", "Finished a scalping trading session."), "event")
	_check_addiction_warnings()
	_refresh_all()
	_render_ap_actions()

func _open_jeongseon_casino():
	if not GameState.spend_ap():
		return
	_enter_minigame_overlay(jeongseon_casino)
	BGMPlayer.set_ambience("casino")
	jeongseon_casino.open()

func _on_jeongseon_casino_closed():
	_exit_minigame_overlay()
	turn_action_log.append(_tr("✓ 🎰 정선 카지노", "✓ 🎰 Jeongseon Casino"))
	GameState.add_log(_tr("🎰 정선 카지노를 나왔다.", "🎰 Left the Jeongseon Casino."), "event")
	BGMPlayer.update_idle_ambience()
	_check_addiction_warnings()
	_refresh_all()
	_render_ap_actions()

# (구형 _open_baccarat/_open_blackjack + 핸들러 제거 — 정선 카지노 허브의
#  _launch_*로 일원화됨. baccarat_table/blackjack_table 노드는 허브가 사용.)

func _enter_minigame_overlay(overlay: Node = null) -> void:
	_minigame_overlay_active = true
	if is_instance_valid(_main_ui_root):
		_main_ui_root.visible = false
	if is_instance_valid(info_panel):
		info_panel.visible = false
	if is_instance_valid(modal_layer):
		modal_layer.visible = false
		modal_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if is_instance_valid(_vignette_rect):
		_vignette_rect.visible = false
	if is_instance_valid(_feedback_flash):
		_feedback_flash.visible = false
	if overlay is CanvasItem:
		(overlay as CanvasItem).move_to_front()

func _exit_minigame_overlay() -> void:
	if not _minigame_overlay_active:
		return
	_minigame_overlay_active = false
	if is_instance_valid(_main_ui_root):
		_main_ui_root.visible = true
	_update_vignette()

func _ap_selfdev():
	_ap_vignette(_tr("자기계발", "Self-Dev"), SELFDEV_VIGNETTES, "#5a6ea8")

func _ap_free_time():
	# 자유시간 누적 → 칭호 "자유로운 영혼" (MetaProgression free_spirit) 조건
	GameState.flags["free_time_count"] = int(GameState.flags.get("free_time_count", 0)) + 1
	_ap_vignette(_tr("휴식", "Rest"), REST_VIGNETTES, "#0891b2")

## 루틴 행동을 '변주되는 미니 장면'으로 처리. 풀에서 무작위 결과를 뽑아 적용.
func _ap_vignette(title: String, pool: Array, color: String):
	if not GameState.spend_ap():
		return
	var v: Dictionary = pool[randi() % pool.size()]
	var eff: Dictionary = v.get("e", {})
	for k in eff:
		var val: int = int(eff[k])
		if k == "money":
			GameState.add_money(float(val))
			if val > 0:
				AudioManager.play("money_gain")
		elif k == "stress" or k == "reputation":
			GameState.modify_hidden_stat(k, val)
		else:
			GameState.modify_stat(k, val)
	var t_key := "et" if LocaleManager.is_english() else "t"
	var flavor: String = str(v.get(t_key, v.get("t", "")))
	turn_action_log.append("✓ " + title + " — " + flavor.substr(0, 22))
	GameState.add_log(title + " — " + flavor, "event")
	GameState.stats_changed.emit()
	_show_vignette(title, flavor, eff, color)

func _show_vignette(title: String, body: String, eff: Dictionary, color: String):
	for child in choice_box.get_children():
		child.queue_free()
	_transient_bg_active = true
	_clear_category_tint(true)
	_clear_feedback_flash()
	_apply_event_bg_path(_get_bg_for_vignette(title, body, eff))
	event_title.text = title
	var disp: Dictionary = _ap_result_display_effects(eff)
	_type_text(_fmt(body), 50.0)

	var result_card: Control = _ap_result_feedback_card(disp, color)
	if result_card:
		result_card.modulate.a = 0.0
		result_card.scale = Vector2(0.992, 0.992)
		choice_box.add_child(result_card)
		var card_tw := create_tween()
		card_tw.tween_interval(0.10)
		card_tw.tween_property(result_card, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_SINE)
		card_tw.parallel().tween_property(result_card, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_row.add_theme_constant_override("separation", 0)
	choice_box.add_child(btn_row)

	var btn: Button = _button(_tr("확인", "OK"), color)
	btn.custom_minimum_size = Vector2(220, 46)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.pressed.connect(func(): _finish_typing(); _on_result_confirmed())
	btn_row.add_child(btn)
	btn.call_deferred("grab_focus")
	next_button.disabled = true

func _ap_result_display_effects(eff: Dictionary) -> Dictionary:
	var disp: Dictionary = {}
	for raw_key in eff:
		var key: String = str(raw_key)
		if not _result_effect_is_visible(key):
			continue
		if typeof(eff[raw_key]) != TYPE_INT and typeof(eff[raw_key]) != TYPE_FLOAT:
			continue
		var val: int = int(eff[raw_key])
		if key == "stress":
			disp["mental"] = int(disp.get("mental", 0)) - val
		elif key == "mental":
			disp["mental"] = int(disp.get("mental", 0)) + val
		else:
			disp[key] = int(disp.get(key, 0)) + val
	return disp

func _result_effect_is_visible(key: String) -> bool:
	return key not in ["tint", "route_orthodox", "route_unorthodox"]

func _ap_result_feedback_card(disp: Dictionary, accent_hex: String) -> Control:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#090c11", 0.96)
	style.border_color = _moral_signal_color(Color(accent_hex), 0.22)
	style.set_border_width_all(1)
	style.border_width_left = 4
	style.set_corner_radius_all(7)
	style.content_margin_left = 13
	style.content_margin_right = 13
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	card.add_theme_stylebox_override("panel", style)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	card.add_child(box)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 10)
	box.add_child(top)
	var overline := _label(_tr("행동 결과", "ACTION RESULT"), 10, "#6f7888")
	overline.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(overline)
	var tone := _ap_result_tone_label(disp)
	var tone_lbl := _label(str(tone["label"]), 11, str(tone["color"]))
	tone_lbl.custom_minimum_size = Vector2(110, 0)
	tone_lbl.clip_text = false
	tone_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if _font_bold:
		tone_lbl.add_theme_font_override("font", _font_bold)
	top.add_child(tone_lbl)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	box.add_child(grid)

	var added := 0
	for key in _ap_result_effect_order(disp):
		var val: int = int(disp.get(key, 0))
		if val == 0:
			continue
		grid.add_child(_ap_result_effect_badge(key, val))
		added += 1
	if added == 0:
		grid.add_child(_wrap_label(_tr("눈에 띄는 변화는 없었다.", "No visible stat change."), 12, "#8f98aa"))
	return card

func _ap_result_tone_label(disp: Dictionary) -> Dictionary:
	var positive := 0
	var negative := 0
	for key in disp:
		var val: int = int(disp[key])
		if val > 0:
			positive += 1
		elif val < 0:
			negative += 1
	if positive > 0 and negative > 0:
		return {"label": _tr("대가 있음", "TRADE-OFF"), "color": "#c8d0df"}
	if negative > 0:
		return {"label": _tr("손실", "COST"), "color": "#ff8a8a"}
	if positive > 0:
		return {"label": _tr("성장", "GAIN"), "color": "#7ee0b2"}
	return {"label": _tr("기록", "LOG"), "color": "#8f98aa"}

func _ap_result_effect_order(disp: Dictionary) -> Array[String]:
	var order: Array[String] = [
		"money", "health", "mental", "intelligence", "investment_skill",
		"social_skill", "appearance", "luck", "reputation", "addiction_tendency"
	]
	for key in disp.keys():
		var key_str: String = str(key)
		if not order.has(key_str):
			order.append(key_str)
	return order

func _ap_result_effect_badge(key: String, val: int) -> Control:
	var badge := PanelContainer.new()
	badge.custom_minimum_size = Vector2(0, 50)
	badge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var accent := _ap_result_effect_color(key, val)
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#0d1017", 0.96)
	st.border_color = _moral_signal_color(Color(accent), 0.18)
	st.set_border_width_all(1)
	st.set_corner_radius_all(6)
	st.content_margin_left = 10
	st.content_margin_right = 10
	st.content_margin_top = 7
	st.content_margin_bottom = 7
	badge.add_theme_stylebox_override("panel", st)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	badge.add_child(box)
	box.add_child(_label(str(_stat_name(key)).to_upper(), 10, "#6f7888"))
	var value_text := _ap_result_effect_value(key, val)
	var value_lbl := _label(value_text, 14, accent)
	value_lbl.clip_text = false
	if _font_bold:
		value_lbl.add_theme_font_override("font", _font_bold)
	box.add_child(value_lbl)
	return badge

func _ap_result_effect_color(key: String, val: int) -> String:
	if key in ["addiction_tendency", "gambling_tendency"]:
		return "#ff8a8a" if val > 0 else "#7ee0b2"
	if val < 0:
		return "#ff8a8a"
	if key == "money":
		return "#f0c56a"
	if key == "reputation":
		return "#b8c7d9"
	return "#7ee0b2"

func _ap_result_effect_value(key: String, val: int) -> String:
	if key in ["money", "monthly_income"]:
		if val >= 0:
			return "+%s" % GameState.format_money(float(val))
		return "-%s" % GameState.format_money(absf(float(val)))
	var sign := "+" if val > 0 else ""
	return "%s%d" % [sign, val]

func _story_result_feedback_card(effects: Dictionary, selected_choice: Dictionary) -> Control:
	var disp: Dictionary = _ap_result_display_effects(effects)
	var cast_effects: Dictionary = selected_choice.get("cast_effects", {})
	var visible_cast := _story_result_visible_cast_effects(cast_effects)
	if disp.is_empty() and visible_cast.is_empty():
		return null
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#080a0f", 0.94)
	style.border_color = _moral_signal_color(Color("#7f8896"), 0.18)
	style.set_border_width_all(1)
	style.border_width_left = 4
	style.set_corner_radius_all(6)
	style.content_margin_left = 13
	style.content_margin_right = 13
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	card.add_theme_stylebox_override("panel", style)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	card.add_child(box)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 10)
	box.add_child(top)
	var overline := _label(_tr("선택 기록", "CHOICE RESULT"), 10, "#6f7888")
	overline.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(overline)
	var tone := _ap_result_tone_label(disp)
	var tone_lbl := _label(str(tone["label"]), 11, str(tone["color"]))
	tone_lbl.custom_minimum_size = Vector2(110, 0)
	tone_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	tone_lbl.clip_text = false
	if _font_bold:
		tone_lbl.add_theme_font_override("font", _font_bold)
	top.add_child(tone_lbl)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	box.add_child(grid)
	var added := 0
	for key in _ap_result_effect_order(disp):
		var val: int = int(disp.get(key, 0))
		if val == 0:
			continue
		grid.add_child(_ap_result_effect_badge(key, val))
		added += 1
		if added >= 6:
			break
	for cast_item in visible_cast:
		grid.add_child(_story_result_cast_badge(str(cast_item["id"]), int(cast_item["affinity"])))
		added += 1
		if added >= 6:
			break
	if added == 0:
		grid.add_child(_wrap_label(_tr("눈에 띄는 변화는 없었다.", "No visible stat change."), 12, "#8f98aa"))
	return card

func _story_result_visible_cast_effects(cast_effects: Dictionary) -> Array:
	var visible: Array = []
	for pid in cast_effects:
		var item = cast_effects[pid]
		if not (item is Dictionary):
			continue
		var val := int(item.get("affinity", 0))
		if val == 0:
			continue
		visible.append({"id": str(pid), "affinity": val})
	return visible

func _story_result_cast_badge(pid: String, affinity_delta: int) -> Control:
	var badge := PanelContainer.new()
	badge.custom_minimum_size = Vector2(0, 50)
	badge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var accent := "#c8b6e6" if affinity_delta > 0 else "#ff8a8a"
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#0d1017", 0.96)
	st.border_color = _moral_signal_color(Color(accent), 0.16)
	st.set_border_width_all(1)
	st.set_corner_radius_all(6)
	st.content_margin_left = 10
	st.content_margin_right = 10
	st.content_margin_top = 7
	st.content_margin_bottom = 7
	badge.add_theme_stylebox_override("panel", st)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	badge.add_child(box)
	box.add_child(_label(_story_result_cast_name(pid).to_upper(), 10, "#6f7888"))
	var sign := "+" if affinity_delta > 0 else ""
	var value_lbl := _label(_tr("호감도 ", "Affinity ") + "%s%d" % [sign, affinity_delta], 14, accent)
	value_lbl.clip_text = false
	if _font_bold:
		value_lbl.add_theme_font_override("font", _font_bold)
	box.add_child(value_lbl)
	return badge

func _story_result_cast_name(pid: String) -> String:
	match pid:
		"father":
			return _tr("아버지", "Father")
		"jiyeon":
			return _tr("한지연", "Han Jiyeon")
		"daeun":
			return _tr("김다은", "Kim Daeun")
		"jaehyuk":
			return _tr("최재혁", "Choi Jaehyuk")
		"sangchul":
			return _tr("임상철", "Im Sangchul")
		"hyunsu":
			return _tr("현수", "Hyunsu")
		_:
			return pid

func _get_bg_for_vignette(title: String, body: String, eff: Dictionary) -> String:
	var lower_title := title.to_lower()
	var lower_body := body.to_lower()
	var bg_id := ""
	if lower_body.find("한강") >= 0 or lower_body.find("hangang") >= 0 \
			or lower_body.find("han river") >= 0:
		bg_id = "hangang_riverside"
	elif lower_body.find("남산") >= 0 or lower_body.find("namsan") >= 0 \
			or lower_body.find("seoul tower") >= 0:
		bg_id = "namsan_tower"
	elif lower_title.find("운동") >= 0 or lower_body.find("헬스장") >= 0 \
			or lower_body.find("운동") >= 0 or lower_body.find("running") >= 0 \
			or lower_body.find("gym") >= 0:
		bg_id = "gym"
	elif lower_title.find("재테크") >= 0 or eff.has("investment_skill"):
		bg_id = "investment_phone"
	elif lower_title.find("독서") >= 0 or eff.has("intelligence"):
		bg_id = "library"
	elif lower_title.find("명상") >= 0:
		bg_id = "rooftop_day"
	elif lower_title.find("저축") >= 0:
		bg_id = "investment_phone"
	elif lower_title.find("인맥") >= 0:
		bg_id = "cafe"

	if bg_id == "":
		var ev := {
			"title": title,
			"description": body,
			"category": "routine",
			"tags": []
		}
		bg_id = ImageRegistry.infer_background_id(ev, GameState.housing)
	return ImageRegistry.get_background(bg_id)

func _ap_startup_work():
	if not GameState.spend_ap():
		return
	var v: Dictionary = STARTUP_VIGNETTES[randi() % STARTUP_VIGNETTES.size()]
	var eff: Dictionary = v.get("e", {})
	for k in eff:
		var val: int = int(eff[k])
		if k == "stress" or k == "reputation":
			GameState.modify_hidden_stat(k, val)
		else:
			GameState.modify_stat(k, val)
	GameState.add_tendency("found", 1)
	var _su_key := "et" if LocaleManager.is_english() else "t"
	var flavor: String = str(v.get(_su_key, v.get("t", "")))
	turn_action_log.append("✓ " + _tr("🚀 창업 업무", "🚀 Startup Work") + " — " + flavor.substr(0, 22))
	GameState.add_log(_tr("🚀 창업 업무", "🚀 Startup Work") + " — " + flavor, "event")
	GameState.stats_changed.emit()
	_show_vignette(_tr("창업 업무", "Startup Work"), flavor, eff, "#7c3aed")
	_refresh_all()

func _ap_create_content():
	if not GameState.spend_ap():
		return
	var v: Dictionary = CONTENT_VIGNETTES[randi() % CONTENT_VIGNETTES.size()]
	var eff: Dictionary = v.get("e", {})
	var extra_eff: Dictionary = {}
	for k in eff:
		var val: int = int(eff[k])
		if k == "stress" or k == "reputation":
			GameState.modify_hidden_stat(k, val)
		else:
			GameState.modify_stat(k, val)
	GameState.add_tendency("found", 1)
	if GameState.flags.get("creator_monetized", false):
		var content_income = float(randi_range(50_000, 200_000))
		GameState.add_money(content_income)
		extra_eff["money"] = int(content_income)
	var _cc_key := "et" if LocaleManager.is_english() else "t"
	var flavor: String = str(v.get(_cc_key, v.get("t", "")))
	turn_action_log.append("✓ " + _tr("🎬 콘텐츠 제작", "🎬 Create Content") + " — " + flavor.substr(0, 22))
	GameState.add_log(_tr("🎬 콘텐츠 제작", "🎬 Create Content") + " — " + flavor, "event")
	GameState.stats_changed.emit()
	var display_eff = eff.duplicate()
	display_eff.merge(extra_eff, true)
	_show_vignette(_tr("콘텐츠 제작", "Create Content"), flavor, display_eff, "#3fb950")
	_refresh_all()

func _ap_write_resume():
	if not GameState.spend_ap():
		return
	turn_action_log.append(_tr("Resume writing — assessment started", "Resume Writing — assessment started"))
	_enter_minigame_overlay(job_hunt_game)
	job_hunt_game.open(0)  # Mode.RESUME = 0

func _ap_interview_prep():
	if not GameState.spend_ap():
		return
	turn_action_log.append(_tr("Mock interview — assessment started", "Mock Interview — assessment started"))
	_enter_minigame_overlay(job_hunt_game)
	job_hunt_game.open(1)  # Mode.INTERVIEW = 1

func _on_job_hunt_closed(stress_delta: int, quality: int) -> void:
	_exit_minigame_overlay()
	# quality: 0=재작성필요, 1=무난, 2=양호, 3=우수
	var is_resume: bool = job_hunt_game.current_mode == 0  # Mode.RESUME
	GameState.modify_hidden_stat("stress", stress_delta)
	GameState.add_tendency("career", 1)
	if is_resume:
		match quality:
			3:
				GameState.modify_stat("intelligence", 2)
				GameState.flags["resume_polished"] = true
				GameState.add_log(_tr("자소서 작성 완료 (평가 A) — 지력 +2, 이력서 완성", "Resume complete (Grade A) — Intelligence +2, resume complete"), "event")
			2:
				GameState.modify_stat("intelligence", 1)
				GameState.flags["resume_polished"] = true
				GameState.add_log(_tr("자소서 작성 완료 (평가 B) — 지력 +1, 이력서 완성", "Resume complete (Grade B) — Intelligence +1, resume complete"), "event")
			1:
				GameState.add_log(_tr("자소서 작성 완료 (평가 C) — 보완이 필요하다", "Resume complete (Grade C) — needs polish"), "event")
			0:
				GameState.modify_hidden_stat("stress", 1)
				GameState.add_log(_tr("자소서 작성 실패 (평가 D) — 정신력 -1", "Resume failed (Grade D) — Mental -1"), "event")
	else:
		match quality:
			3:
				GameState.modify_stat("social_skill", 2)
				GameState.modify_stat("luck", 1)
				GameState.flags["interview_practiced"] = true
				GameState.add_log(_tr("모의 면접 완료 (평가 A) — 사회성 +2, 운 +1", "Mock interview complete (Grade A) — Social +2, Luck +1"), "event")
			2:
				GameState.modify_stat("social_skill", 1)
				GameState.flags["interview_practiced"] = true
				GameState.add_log(_tr("모의 면접 완료 (평가 B) — 사회성 +1", "Mock interview complete (Grade B) — Social +1"), "event")
			1:
				GameState.modify_stat("luck", 1)
				GameState.add_log(_tr("모의 면접 완료 (평가 C) — 운 +1", "Mock interview complete (Grade C) — Luck +1"), "event")
			0:
				GameState.modify_hidden_stat("stress", 1)
				GameState.add_log(_tr("모의 면접 실패 (평가 D) — 정신력 -1", "Mock interview failed (Grade D) — Mental -1"), "event")
	GameState.stats_changed.emit()
	_refresh_all()

func _ap_move_housing():
	# AP 소비 없음 — 이사는 자금으로 하는 결정
	var result = GameState.upgrade_housing()
	if result["success"]:
		var info = result["housing"]
		var housing_name = GameState.get_housing_name(GameState.housing)
		var expense = GameState.format_money(float(info.get("expense", 0.0)))
		turn_action_log.append(_tr("✓ 이사 → %s (월 %s)", "✓ Moved → %s (monthly %s)") % [housing_name, expense])
		AudioManager.play("housing_up")
		_show_toast(_tr("%s 이사 완료!", "Moved to %s!") % housing_name, Color("#f0b429"))
	else:
		AudioManager.play("stat_down")
		_show_toast(result.get("message", _tr("이사 실패", "Move failed")), Color("#ff4444"))
	_render_ap_actions()
	_refresh_all()

# ── RPG 해금 행동 함수들 ───────────────────────────────────────────────

func _ap_deep_study():
	if not GameState.spend_ap():
		return
	var int_before = GameState.intelligence
	GameState.modify_stat("intelligence", 8)
	AudioManager.play("stat_up")
	turn_action_log.append(_tr("✓ 심화 독서 → 지력 %d→%d", "✓ Deep Reading → Intelligence %d→%d") % [int_before, GameState.intelligence])
	_show_toast(_tr("심화 독서 — 지력 %d → %d", "Deep Reading — Intelligence %d → %d") % [int_before, GameState.intelligence], Color("#1d4ed8"))
	_render_ap_actions()
	_refresh_all()

func _ap_market_analysis():
	# 무료 행동 — AP 소비 없음
	var forecast = investment_system.get_market_forecast()
	var cycle = str(GameState.market_context.get("cycle", "neutral"))
	var fg = int(GameState.market_context.get("fear_greed", 50))
	var crash_risk = float(GameState.market_context.get("crash_risk", 0.05))
	_open_modal(_tr("시장 분석", "Market Analysis"), true)
	modal_body.add_child(_modal_section_header(
		_tr("시장 리포트", "Market Report"),
		"market",
		"#38bdf8",
		_tr("행동력 소비 없음 — 현재 시장 국면과 다음 달 리스크를 확인합니다.", "No AP cost — review the current market phase and next month's risk.")))
	var sep = HSeparator.new(); sep.add_theme_color_override("color", Color("#252535")); modal_body.add_child(sep)
	modal_body.add_child(_label(_tr("현재 시장 상황", "Current Market"), 16, "#e8eaf0"))
	var cycle_kr = {"bull": _tr("상승장", "Bull"), "bear": _tr("하락장", "Bear"), "neutral": _tr("횡보", "Flat")}.get(cycle, cycle)
	modal_body.add_child(_wrap_label(_tr("시장 국면: %s  |  공포/탐욕: %d/100  |  폭락 위험도: %.0f%%", "Market phase: %s  |  Fear/Greed: %d/100  |  Crash risk: %.0f%%") % [cycle_kr, fg, crash_risk * 100.0], 14, "#f0b429"))
	var sep2 = HSeparator.new(); sep2.add_theme_color_override("color", Color("#252535")); modal_body.add_child(sep2)
	modal_body.add_child(_label(_tr("다음 달 예측", "Next Month Forecast"), 15, "#c9a227"))
	modal_body.add_child(_wrap_label(forecast, 15, "#e8eaf0"))
	if crash_risk > 0.08:
		modal_body.add_child(_wrap_label(_tr("폭락 경보: 레버리지 포지션 청산 검토. 현금 비중을 높이세요.", "Crash alert: consider liquidating leveraged positions. Raise your cash ratio."), 13, "#ff4444"))
	var ok_btn = _button(_tr("확인", "OK"), "#1e3a5f")
	ok_btn.pressed.connect(_close_modal)
	modal_body.add_child(ok_btn)
	GameState.add_log(_tr("🔭 시장 분석 — %s", "🔭 Market Analysis — %s") % forecast, "market")

# (_ap_leverage_invest 데드 래퍼 제거 — 호출처 0. 레버리지는 _open_investments가
#  _open_leverage_investments를 직접 연결해 진입함.)

func _open_leverage_investments():
	_open_modal(_tr("레버리지 투자", "Leverage Investing"), true)
	var ap_now = GameState.action_points
	modal_body.add_child(_modal_section_header(
		_tr("2배 포지션", "2x Position"),
		"leverage",
		"#ef4444",
		_tr("고위험 거래. 수익도 2배, 손실도 2배. 포지션 가치가 원금의 35% 이하로 하락하면 강제 청산됩니다.", "High-risk trade. Gains and losses both 2x. Position is force-liquidated if value drops below 35% of principal.")))
	modal_body.add_child(_wrap_label(_tr("행동력 %d/%d — 매수 실행 시 1 소비", "AP %d/%d — buying costs 1") % [ap_now, GameState.max_action_points],
		12, "#00c896" if ap_now > 0 else "#ff4444"))
	var sep = HSeparator.new(); sep.add_theme_color_override("color", Color("#252535")); modal_body.add_child(sep)
	for row in investment_system.get_asset_rows():
		var asset_id = row["id"]
		var price = float(row["price"])
		var hist: Array = GameState.price_history.get(asset_id, [])
		var sparkline = _price_sparkline(hist)
		var last_color = "#8892a4"
		if hist.size() >= 2:
			last_color = "#00c896" if float(hist[-1]) >= float(hist[-2]) else "#ff4444"
		var leveraged = GameState.portfolio.get(asset_id, {}).get("leveraged_amount", 0.0) > 0
		var lev_tag = _tr(" [레버리지]", " [Leverage]") if leveraged else ""
		modal_body.add_child(_label("%s  %s  %s%s" % [row["name"], GameState.format_money(price), sparkline, lev_tag], 14, last_color))
		var buy_row = HBoxContainer.new()
		buy_row.add_theme_constant_override("separation", 6)
		for amount in [200_000, 500_000, 1_000_000]:
			var can_afford = GameState.money >= float(amount)
			var btn: Button = _small_button("%s x2" % GameState.format_money(amount), "#7f1d1d" if can_afford else "#64748b")
			btn.disabled = not can_afford
			btn.pressed.connect(Callable(self, "_on_leverage_buy").bind(asset_id, float(amount)))
			buy_row.add_child(btn)
		modal_body.add_child(buy_row)
		var sep2 = HSeparator.new(); sep2.add_theme_color_override("color", Color("#252535")); modal_body.add_child(sep2)
	var back_lev := _icon_button(_tr("투자 화면으로", "Back to Investing"), "invest", "#1a1a28")
	back_lev.pressed.connect(_open_investments)
	modal_body.add_child(back_lev)

func _on_leverage_buy(asset_id: String, amount: float):
	if not GameState.spend_ap():
		_show_toast(_tr("행동력이 없습니다. 이번 달 거래 불가", "No Action Points. No trading this month."), Color("#ff4444"))
		_close_modal()
		return
	AudioManager.play("money_gain")
	var result = investment_system.buy_asset_leveraged(asset_id, amount)
	if result.get("success", false):
		var asset_name = asset_id
		for data in DataRegistry.assets:
			if data.get("id", "") == asset_id:
				asset_name = data.get("name", asset_id)
				break
		turn_action_log.append(_tr("✓ 레버리지 → %s ×2배  %s", "✓ Leverage → %s ×2  %s") % [asset_name, GameState.format_money(amount)])
		_close_modal()
		_refresh_all()
		_show_toast(_tr("레버리지 매수 — %s ×2배 포지션 확보", "Leverage buy — secured %s ×2 position") % GameState.format_money(amount * 2.0), Color("#ef4444"))
	else:
		_show_toast(result.get("message", _tr("오류", "Error")), Color("#ff4444"))

func _ap_vip_network():
	if not GameState.spend_ap():
		return
	var soc_before = GameState.social_skill
	var rep_before = GameState.reputation
	GameState.modify_stat("social_skill", 3)
	GameState.modify_hidden_stat("reputation", 2)
	var rel_names: Array = []
	for rel in GameState.relationships:
		var aff_before = int(rel.get("affection", 40))
		rel["affection"] = clamp(aff_before + 15, 0, 100)
		rel["trust"] = clamp(int(rel.get("trust", 30)) + 8, 0, 100)
		rel_names.append(str(rel.get("name", "?")))
	var rel_str = " · ".join(rel_names.slice(0, 3)) if not rel_names.is_empty() else _tr("인맥 없음", "No contacts")
	GameState.add_log(_tr("VIP 인맥: 사회성 %d→%d, 평판 %d→%d (%s)", "VIP Networking: Social %d→%d, Reputation %d→%d (%s)") % [soc_before, GameState.social_skill, rep_before, GameState.reputation, rel_str], "relationship")
	turn_action_log.append(_tr("✓ VIP 인맥 → 사회성 %d→%d, 평판+2", "✓ VIP Networking → Social %d→%d, Reputation +2") % [soc_before, GameState.social_skill])
	_show_toast(_tr("VIP 인맥 — 사회성 %d→%d, 모든 관계 친밀도 +15", "VIP Networking — Social %d→%d, all relations affection +15") % [soc_before, GameState.social_skill], Color("#a855f7"))
	GameState.stats_changed.emit()
	_render_ap_actions()
	_refresh_all()

func _open_jobs():
	_open_modal(_tr("직업 선택", "Choose a Job"), true, "jobs")
	_job_page_tab_buttons.clear()
	_job_candidate_cards.clear()
	_job_pad_hint_label = null
	_job_candidate_idx = 0
	var tiers := _job_tiers()
	var current_tier := int(GameState.current_job.get("tier", 1))
	var current_tier_idx := tiers.find(current_tier)
	_job_page_idx = current_tier_idx if current_tier_idx >= 0 else 0
	if modal_scroll:
		modal_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
		modal_scroll.custom_minimum_size = Vector2(0, 540)
	if modal_panel:
		modal_panel.custom_minimum_size = Vector2(840, 700)
		modal_panel.offset_left = -420
		modal_panel.offset_right = 420
		modal_panel.offset_top = -350
		modal_panel.offset_bottom = 350
	modal_body.add_theme_constant_override("separation", 8)
	modal_body.add_child(_build_job_status_strip())
	_job_pad_hint_label = RichTextLabel.new()
	_job_pad_hint_label.bbcode_enabled = true
	_job_pad_hint_label.fit_content = true
	_job_pad_hint_label.scroll_active = false
	_job_pad_hint_label.custom_minimum_size = Vector2(0, 24)
	_job_pad_hint_label.add_theme_font_size_override("normal_font_size", 11)
	_job_pad_hint_label.add_theme_color_override("default_color", Color("#8f98a8"))
	if _font_bold:
		_job_pad_hint_label.add_theme_font_override("bold_font", _font_bold)
	modal_body.add_child(_job_pad_hint_label)
	modal_body.add_child(_build_job_page_tabs())
	_job_page_body = VBoxContainer.new()
	_job_page_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_job_page_body.add_theme_constant_override("separation", 8)
	modal_body.add_child(_job_page_body)
	_render_job_page()

func _job_tiers() -> Array:
	var tiers: Array = []
	for job in job_system.get_available_jobs():
		var tier := int(job.get("tier", 1))
		if not tiers.has(tier):
			tiers.append(tier)
	tiers.sort()
	return tiers if not tiers.is_empty() else [1]

func _job_tier_label(tier: int) -> String:
	var tier_labels := {
		1: _tr("입문", "Entry"),
		2: _tr("성장", "Growth"),
		3: _tr("전문가", "Expert"),
		4: _tr("상위", "Top"),
	}
	return str(tier_labels.get(tier, "Tier %d" % tier))

func _job_current_tier() -> int:
	var tiers := _job_tiers()
	_job_page_idx = clampi(_job_page_idx, 0, tiers.size() - 1)
	return int(tiers[_job_page_idx])

func _job_rows_for_current_tier() -> Array:
	var rows: Array = []
	var tier := _job_current_tier()
	for job in job_system.get_available_jobs():
		if int(job.get("tier", 1)) == tier:
			rows.append(job)
	return rows

func _build_job_status_strip() -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#080b10")
	st.border_color = Color("#242a35")
	st.set_border_width_all(1)
	st.set_corner_radius_all(6)
	st.content_margin_left = 12
	st.content_margin_right = 12
	st.content_margin_top = 8
	st.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", st)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)

	var status_box := VBoxContainer.new()
	status_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_box.add_theme_constant_override("separation", 2)
	row.add_child(status_box)
	status_box.add_child(_label(_tr("현재 경력", "CURRENT CAREER"), 10, "#6f7886"))
	if GameState.current_job.is_empty():
		status_box.add_child(_label(_tr("무직 · 이번 주 구직 AP 사용됨", "Unemployed · job-search AP spent"), 15, "#e8eaf0"))
	else:
		var promo_count := int(GameState.current_job.get("promotion_count", 0))
		var max_promo := int(GameState.current_job.get("max_promotions", 3))
		status_box.add_child(_label(
			"%s · Tier %d · %s %d/%d" % [
				GameState.get_job_display_name(),
				int(GameState.current_job.get("tier", 1)),
				_tr("승진", "Promotions"),
				promo_count,
				max_promo,
			],
			15, "#e8eaf0"))

	var stat_box := VBoxContainer.new()
	stat_box.custom_minimum_size = Vector2(250, 0)
	stat_box.add_theme_constant_override("separation", 2)
	row.add_child(stat_box)
	stat_box.add_child(_label(_tr("지원 스탯", "APPLICATION STATS"), 10, "#6f7886"))
	stat_box.add_child(_label(_tr("지력 %d · 사회성 %d · 외모 %d", "INT %d · SOC %d · APP %d") % [
		GameState.intelligence, GameState.social_skill, GameState.appearance], 14, "#cbd5e1"))

	var prep_box := VBoxContainer.new()
	prep_box.custom_minimum_size = Vector2(230, 0)
	prep_box.add_theme_constant_override("separation", 2)
	row.add_child(prep_box)
	prep_box.add_child(_label(_tr("준비도", "READINESS"), 10, "#6f7886"))
	var resume_ok: bool = GameState.flags.get("resume_polished", false)
	var interview_ok: bool = GameState.flags.get("interview_practiced", false)
	var prep_color := "#cbd5e1" if resume_ok or interview_ok else "#7f8ea3"
	prep_box.add_child(_label(
		"%s · %s" % [
			_tr("이력서 OK", "Resume OK") if resume_ok else _tr("이력서 필요", "Resume needed"),
			_tr("면접 OK", "Interview OK") if interview_ok else _tr("면접 필요", "Interview needed"),
		],
		13, prep_color))
	return panel

func _build_job_page_tabs() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var tiers := _job_tiers()
	for i in range(tiers.size()):
		var tier_idx := i
		var tier := int(tiers[i])
		var btn := _small_button("", "#111820")
		btn.focus_mode = Control.FOCUS_NONE
		btn.custom_minimum_size = Vector2(0, 36)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(Callable(self, "_set_job_page").bind(tier_idx))
		row.add_child(btn)
		_job_page_tab_buttons.append(btn)
	_style_job_page_tabs()
	return row

func _style_job_page_tabs() -> void:
	var tiers := _job_tiers()
	for i in range(mini(_job_page_tab_buttons.size(), tiers.size())):
		var btn := _job_page_tab_buttons[i] as Button
		if not is_instance_valid(btn):
			continue
		var selected := i == _job_page_idx
		var tier := int(tiers[i])
		btn.text = "T%d  %s" % [tier, _job_tier_label(tier)]
		var normal := StyleBoxFlat.new()
		normal.bg_color = Color("#16202a" if selected else "#0c1118")
		normal.border_color = Color("#d9e2ea" if selected else "#252b35")
		normal.set_border_width_all(1)
		normal.border_width_bottom = 3 if selected else 1
		normal.set_corner_radius_all(3)
		normal.content_margin_left = 10
		normal.content_margin_right = 10
		normal.content_margin_top = 7
		normal.content_margin_bottom = 7
		var hover := normal.duplicate()
		hover.bg_color = normal.bg_color.lightened(0.10)
		var focus_st := normal.duplicate()
		focus_st.border_color = Color("#ffffff")
		focus_st.set_border_width_all(UI_FOCUS_BORDER)
		btn.add_theme_stylebox_override("normal", normal)
		btn.add_theme_stylebox_override("hover", hover)
		btn.add_theme_stylebox_override("pressed", normal)
		btn.add_theme_stylebox_override("focus", focus_st)
		btn.add_theme_color_override("font_color", Color("#eef3f8" if selected else "#8f98a8"))

func _set_job_page(index: int) -> void:
	var tiers := _job_tiers()
	if tiers.is_empty():
		return
	_job_page_idx = clampi(index, 0, tiers.size() - 1)
	_job_candidate_idx = 0
	_render_job_page()

func _job_switch_page(delta: int) -> bool:
	var tiers := _job_tiers()
	if tiers.is_empty():
		return true
	_job_page_idx = int(posmod(_job_page_idx + delta, tiers.size()))
	_job_candidate_idx = 0
	AudioManager.play_ui_click()
	_render_job_page()
	return true

func _render_job_page() -> void:
	if not is_instance_valid(_job_page_body):
		return
	_clear_box(_job_page_body)
	_job_candidate_cards.clear()
	_style_job_page_tabs()
	var tier := _job_current_tier()
	var rows := _job_rows_for_current_tier()
	_job_candidate_idx = clampi(_job_candidate_idx, 0, maxi(0, rows.size() - 1))
	_job_page_body.add_child(_build_job_page_caption(
		_tr("Tier %d · %s", "Tier %d · %s") % [tier, _job_tier_label(tier)],
		_tr("↑↓ 후보 · LB/RB 티어 · 확인 지원", "↑↓ role · LB/RB tier · confirm to apply"),
		"#9aa4b8"))
	if rows.is_empty():
		_job_page_body.add_child(_build_job_empty_card(_tr("이 티어의 직업 데이터가 없습니다.", "No jobs in this tier."), "#64748b"))
		_refresh_job_pad_hint()
		return
	var visible_count := mini(2, rows.size())
	var start_idx := clampi(_job_candidate_idx - 1, 0, maxi(0, rows.size() - visible_count))
	var end_idx := mini(rows.size(), start_idx + visible_count)
	for i in range(start_idx, end_idx):
		_job_page_body.add_child(_build_job_card(rows[i]))
	var window_lbl := _label(
		_tr("후보 %d-%d / %d — 스크롤 대신 후보 커서로 이동", "Roles %d-%d / %d — move the role cursor instead of scrolling")
		% [start_idx + 1, end_idx, rows.size()],
		11, "#6f7886")
	window_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_job_page_body.add_child(window_lbl)
	_apply_job_cursor()

func _build_job_page_caption(title: String, subtitle: String, accent: String) -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#090d13")
	st.border_color = Color(accent)
	st.set_border_width_all(1)
	st.border_width_left = 4
	st.set_corner_radius_all(6)
	st.content_margin_left = 12
	st.content_margin_right = 12
	st.content_margin_top = 7
	st.content_margin_bottom = 7
	panel.add_theme_stylebox_override("panel", st)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)
	var title_lbl := _label(title, 14, "#eef3f8")
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if _font_bold:
		title_lbl.add_theme_font_override("font", _font_bold)
	row.add_child(title_lbl)
	var sub_lbl := _label(subtitle, 11, "#8f98a8")
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	sub_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(sub_lbl)
	return panel

func _build_job_empty_card(text: String, accent: String) -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#0a0e14")
	st.border_color = Color(accent)
	st.set_border_width_all(1)
	st.set_corner_radius_all(6)
	st.content_margin_left = 14
	st.content_margin_right = 14
	st.content_margin_top = 14
	st.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", st)
	panel.add_child(_wrap_label(text, 13, "#9aa4b8"))
	return panel

func _job_needs_resume(job: Dictionary) -> bool:
	var tier := int(job.get("tier", 1))
	var is_current := str(job.get("id", "")) == str(GameState.current_job.get("id", ""))
	return tier >= 2 and not is_current and not GameState.flags.get("resume_polished", false)

func _job_requirements_string(job: Dictionary) -> String:
	var req: Dictionary = job.get("requirements", {})
	var req_parts: Array = []
	for k in req:
		match k:
			"min_intelligence":
				req_parts.append(_tr("지력 %d", "Intelligence %d") % int(req[k]))
			"min_appearance":
				req_parts.append(_tr("외모 %d", "Appearance %d") % int(req[k]))
			"min_social_skill", "min_social":
				req_parts.append(_tr("사회성 %d", "Social %d") % int(req[k]))
			"min_investment_skill":
				req_parts.append(_tr("투자감각 %d", "Investing %d") % int(req[k]))
			"min_money":
				req_parts.append(_tr("현금 %s", "Cash %s") % GameState.format_money(float(req[k])))
	return " · ".join(req_parts) if not req_parts.is_empty() else _tr("제한 없음", "No requirements")

func _job_lock_reason(job: Dictionary) -> String:
	var reason := str(job.get("lock_reason", _tr("경력 조건 미충족", "Career requirement not met")))
	var lock_icon := String.chr(0x1F512)
	return reason.replace(lock_icon + " ", "").replace(lock_icon, "").strip_edges()

func _job_can_apply(job: Dictionary) -> bool:
	if bool(job.get("locked", false)):
		return false
	if str(job.get("id", "")) == str(GameState.current_job.get("id", "")):
		return false
	if not bool(job.get("eligible", false)):
		return false
	if _job_needs_resume(job):
		return false
	return true

func _job_disabled_reason(job: Dictionary) -> String:
	if bool(job.get("locked", false)):
		return _job_lock_reason(job)
	if str(job.get("id", "")) == str(GameState.current_job.get("id", "")):
		return _tr("현재 직업", "Current role")
	if _job_needs_resume(job):
		return _tr("이력서 먼저 완성 필요", "Complete your resume first")
	if not bool(job.get("eligible", false)):
		return _tr("지원 조건 부족", "Requirements not met")
	return ""

func _build_job_card(job: Dictionary) -> Control:
	var job_id := str(job.get("id", ""))
	var can_apply := _job_can_apply(job)
	var disabled_reason := _job_disabled_reason(job)
	var base_border := "#8f98a8"
	if bool(job.get("locked", false)):
		base_border = "#424956"
	elif can_apply:
		base_border = "#d9e2ea"
	elif disabled_reason == _tr("현재 직업", "Current role"):
		base_border = "#9aa4b8"
	var panel := PanelContainer.new()
	panel.set_meta("job_id", job_id)
	panel.set_meta("job_base_border", base_border)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#0b1116")
	st.border_color = Color(base_border)
	st.set_border_width_all(1)
	st.border_width_left = 4
	st.set_corner_radius_all(7)
	st.content_margin_left = 14
	st.content_margin_right = 14
	st.content_margin_top = 10
	st.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", st)
	_job_candidate_cards.append(panel)

	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	box.add_child(header)
	var name_lbl := _label(GameState.get_job_display_name(job), 16, "#e8eaf0")
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if _font_bold:
		name_lbl.add_theme_font_override("font", _font_bold)
	header.add_child(name_lbl)
	var salary_lbl: Label = _label(GameState.format_money(float(job.get("base_salary", 0.0))) + _tr("/월", "/mo"), 14, "#cbd5e1")
	salary_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	salary_lbl.custom_minimum_size = Vector2(130, 0)
	header.add_child(salary_lbl)

	var stress_val := int(job.get("stress_per_month", 5))
	var req_str := _job_requirements_string(job)
	var meta_line := _tr("정신력 -%d/월 · 조건: %s", "Mental -%d/mo · Req: %s") % [int(stress_val / 2), req_str]
	box.add_child(_wrap_label(meta_line, 12, "#9aa4b8" if can_apply else "#64748b"))

	var desc := str(job.get("description", "")).replace("\n", " ")
	if desc.length() > 118:
		desc = desc.substr(0, 116) + "..."
	box.add_child(_wrap_label(desc, 12, "#7f8ea3"))

	var btn_text := _tr("지원하기", "Apply")
	if not can_apply:
		btn_text = disabled_reason.to_upper()
	var apply_btn := _small_button(btn_text, "#1c242c" if can_apply else "#26303c")
	apply_btn.focus_mode = Control.FOCUS_NONE
	apply_btn.custom_minimum_size = Vector2(0, 38)
	apply_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	apply_btn.disabled = not can_apply
	apply_btn.pressed.connect(Callable(self, "_on_job_selected").bind(job_id))
	box.add_child(apply_btn)
	return panel

func _job_selected_job() -> Dictionary:
	var rows := _job_rows_for_current_tier()
	if rows.is_empty():
		return {}
	_job_candidate_idx = clampi(_job_candidate_idx, 0, rows.size() - 1)
	return rows[_job_candidate_idx]

func _job_move_candidate(delta: int) -> bool:
	var rows := _job_rows_for_current_tier()
	if rows.is_empty():
		return true
	_job_candidate_idx = int(posmod(_job_candidate_idx + delta, rows.size()))
	AudioManager.play_ui_click()
	_render_job_page()
	return true

func _job_confirm_candidate() -> bool:
	var job := _job_selected_job()
	if job.is_empty():
		return true
	if not _job_can_apply(job):
		_show_toast(_job_disabled_reason(job), Color("#9aa4b8"))
		return true
	_on_job_selected(str(job.get("id", "")))
	return true

func _apply_job_cursor() -> void:
	var selected := _job_selected_job()
	var selected_id := str(selected.get("id", ""))
	for card in _job_candidate_cards:
		if not is_instance_valid(card):
			continue
		var panel := card as PanelContainer
		var job_id := str(panel.get_meta("job_id", ""))
		var is_selected := job_id == selected_id and ControllerHints.is_pad_active()
		var st := StyleBoxFlat.new()
		st.bg_color = Color("#0b1116")
		st.border_color = Color(COL_GOLD_BRIGHT if is_selected else str(panel.get_meta("job_base_border", "#8f98a8")))
		st.set_border_width_all(2 if is_selected else 1)
		st.border_width_left = 6 if is_selected else 4
		st.set_corner_radius_all(7)
		st.content_margin_left = 14
		st.content_margin_right = 14
		st.content_margin_top = 10
		st.content_margin_bottom = 10
		panel.add_theme_stylebox_override("panel", st)
	_refresh_job_pad_hint()

func _refresh_job_pad_hint() -> void:
	if not is_instance_valid(_job_pad_hint_label):
		return
	if not ControllerHints.is_pad_active() or _modal_kind != "jobs":
		_job_pad_hint_label.visible = false
		return
	_job_pad_hint_label.visible = true
	var job := _job_selected_job()
	var role := GameState.get_job_display_name(job) if not job.is_empty() else _tr("직업 없음", "No role")
	var action := _tr("지원", "Apply") if not job.is_empty() and _job_can_apply(job) else _tr("조건 확인", "Check")
	_job_pad_hint_label.text = _tr(
		"[b]패드[/b]  LB/RB 티어 · ↑↓ 후보 · %s %s · %s 뒤로  —  %s",
		"[b]Pad[/b]  LB/RB Tier · ↑↓ Role · %s %s · %s Back  —  %s"
	) % [ControllerHints.south(), action, ControllerHints.east(), role]

func _handle_job_modal_input(event: InputEvent) -> bool:
	if event is InputEventKey and (event as InputEventKey).echo:
		return false
	if event.is_action_pressed("gd_tab_prev"):
		return _job_switch_page(-1)
	if event.is_action_pressed("gd_tab_next"):
		return _job_switch_page(1)
	if event.is_action_pressed("ui_up"):
		return _job_move_candidate(-1)
	if event.is_action_pressed("ui_down"):
		return _job_move_candidate(1)
	if event.is_action_pressed("ui_accept"):
		return _job_confirm_candidate()
	return false

func _build_investment_market_board() -> Control:
	var fg: int = int(GameState.market_context.get("fear_greed", 50))
	var cycle: String = str(GameState.market_context.get("cycle", "neutral"))
	var cycle_map: Dictionary = {"bull": _tr("상승장", "Bull Market"), "bear": _tr("하락장", "Bear Market"), "neutral": _tr("횡보장", "Sideways")}
	var cycle_label: String = str(cycle_map.get(cycle, cycle))
	var accent: String = "#ff4444" if fg < 30 else ("#00c896" if fg > 70 else "#f0b429")
	var crash_risk: float = float(GameState.market_context.get("crash_risk", 0.05))

	var total_cost: float = 0.0
	var total_now: float = 0.0
	for aid in GameState.portfolio:
		var holding: Dictionary = GameState.portfolio[aid]
		var qty: float = float(holding.get("quantity", 0.0))
		var avg_price: float = float(holding.get("avg_price", 0.0))
		var now_price: float = float(GameState.market_prices.get(aid, avg_price))
		total_cost += qty * avg_price
		total_now += qty * now_price
	var return_pct: float = (total_now - total_cost) / maxf(total_cost, 0.01) * 100.0
	var has_position: bool = total_now > 0.0
	var return_color: String = "#00c896" if return_pct >= 0.0 else "#ff4444"

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#07100e")
	st.bg_color.a = 0.92
	st.border_color = Color(accent)
	st.set_border_width_all(1)
	st.set_corner_radius_all(7)
	st.content_margin_left = 14
	st.content_margin_right = 14
	st.content_margin_top = 12
	st.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", st)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	panel.add_child(row)

	var regime := VBoxContainer.new()
	regime.custom_minimum_size = Vector2(150, 0)
	regime.add_theme_constant_override("separation", 3)
	row.add_child(regime)
	regime.add_child(_label("MARKET BOARD", 10, "#7f8ea3"))
	var cycle_lbl := _label(cycle_label, 21, accent)
	if _font_bold:
		cycle_lbl.add_theme_font_override("font", _font_bold)
	regime.add_child(cycle_lbl)
	regime.add_child(_label(_tr("크래시 리스크 %.0f%%", "Crash risk %.0f%%") % (crash_risk * 100.0), 12, "#a8b3c7"))

	var gauge := Control.new()
	gauge.custom_minimum_size = Vector2(210, 68)
	gauge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var gauge_color := Color(accent)
	gauge.draw.connect(func():
		var sz := gauge.size
		if sz.x < 40.0:
			return
		var f := ThemeDB.fallback_font
		var track := Rect2(Vector2(0.0, 32.0), Vector2(sz.x, 14.0))
		gauge.draw_string(f, Vector2(0.0, 14.0), _tr("공포", "FEAR"), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#8e98ad"))
		gauge.draw_string(f, Vector2(sz.x - 46.0, 14.0), _tr("탐욕", "GREED"), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#8e98ad"))
		gauge.draw_rect(Rect2(track.position + Vector2(0.0, 3.0), track.size), Color(0, 0, 0, 0.32), true)
		gauge.draw_rect(track, Color("#111827"), true)
		var fill_w := track.size.x * clampf(float(fg) / 100.0, 0.0, 1.0)
		gauge.draw_rect(Rect2(track.position, Vector2(fill_w, track.size.y)), gauge_color, true)
		for i in range(11):
			var x := track.position.x + track.size.x * float(i) / 10.0
			gauge.draw_line(Vector2(x, track.position.y - 3.0), Vector2(x, track.end.y + 3.0), Color(1, 1, 1, 0.10), 1.0)
		var needle_x := track.position.x + fill_w
		gauge.draw_line(Vector2(needle_x, track.position.y - 8.0), Vector2(needle_x, track.end.y + 8.0), Color("#ffffff"), 2.0)
		gauge.draw_string(f, Vector2(maxf(0.0, needle_x - 14.0), track.end.y + 16.0), "%d" % fg, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#e8eaf0"))
	)
	row.add_child(gauge)

	var portfolio := VBoxContainer.new()
	portfolio.custom_minimum_size = Vector2(170, 0)
	portfolio.add_theme_constant_override("separation", 3)
	row.add_child(portfolio)
	portfolio.add_child(_label(_tr("내 계좌", "ACCOUNT"), 10, "#7f8ea3"))
	portfolio.add_child(_label(_tr("현금 %s", "Cash %s") % GameState.format_money(GameState.money), 13, "#cbd5e1"))
	if has_position:
		portfolio.add_child(_label(_tr("평가 %s", "Value %s") % GameState.format_money(total_now), 13, "#cbd5e1"))
		var ret_lbl := _label(_tr("수익률 %+.1f%%", "Return %+.1f%%") % return_pct, 18, return_color)
		if _font_bold:
			ret_lbl.add_theme_font_override("font", _font_bold)
		portfolio.add_child(ret_lbl)
	else:
		portfolio.add_child(_label(_tr("보유 자산 없음", "No positions"), 13, "#94a3b8"))
		portfolio.add_child(_label(_tr("소액 분산부터", "Start diversified"), 13, "#f0b429"))
	return panel

func _invest_pages() -> Array:
	return [
		{"id": "assets", "label": _tr("거래", "Trade")},
		{"id": "portfolio", "label": _tr("보유", "Holdings")},
		{"id": "market", "label": _tr("시장", "Market")},
		{"id": "bank", "label": _tr("은행", "Bank")},
	]

func _invest_page_index_for(page_id: String) -> int:
	var pages := _invest_pages()
	for i in range(pages.size()):
		if str(pages[i].get("id", "")) == page_id:
			return i
	return 0

func _invest_current_page_id() -> String:
	var pages := _invest_pages()
	if pages.is_empty():
		return ""
	_invest_page_idx = clampi(_invest_page_idx, 0, pages.size() - 1)
	return str(pages[_invest_page_idx].get("id", ""))

func _build_investment_status_strip() -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#080b10")
	st.border_color = Color("#242a35")
	st.set_border_width_all(1)
	st.set_corner_radius_all(6)
	st.content_margin_left = 12
	st.content_margin_right = 12
	st.content_margin_top = 8
	st.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", st)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)
	var ap_color := "#cbd5e1" if GameState.action_points > 0 else "#ff7070"
	var loan_total := GameState.get_loan_total()
	var metrics: Array = [
		[_tr("AP", "AP"), "%d/%d" % [GameState.action_points, GameState.max_action_points], ap_color],
		[_tr("현금", "Cash"), GameState.format_money(GameState.money), "#cbd5e1"],
		[_tr("순자산", "Net Worth"), GameState.format_money(GameState.get_total_asset_value()), "#cbd5e1"],
		[_tr("대출", "Debt"), GameState.format_money(loan_total), "#f59e0b" if loan_total > 0.0 else "#64748b"],
	]
	for metric in metrics:
		var box := VBoxContainer.new()
		box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		box.add_theme_constant_override("separation", 2)
		row.add_child(box)
		box.add_child(_label(str(metric[0]).to_upper(), 10, "#6f7886"))
		var value := _label(str(metric[1]), 14, str(metric[2]))
		if _font_bold:
			value.add_theme_font_override("font", _font_bold)
		box.add_child(value)
	var terms_btn := _icon_small_button(_tr("용어", "Terms"), "info", "#1a2438")
	terms_btn.custom_minimum_size = Vector2(88, 36)
	terms_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	terms_btn.pressed.connect(func(): _open_glossary(_tr("투자 용어", "Investing Terms"), "invest"))
	row.add_child(terms_btn)
	return panel

func _build_investment_page_tabs() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var pages := _invest_pages()
	for i in range(pages.size()):
		var page_idx := i
		var page: Dictionary = pages[i]
		var btn := _small_button("", "#111820")
		btn.custom_minimum_size = Vector2(0, 38)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(Callable(self, "_set_invest_page").bind(page_idx))
		row.add_child(btn)
		_invest_page_tab_buttons.append(btn)
	_style_invest_page_tabs()
	return row

func _style_invest_page_tabs() -> void:
	var pages := _invest_pages()
	for i in range(mini(_invest_page_tab_buttons.size(), pages.size())):
		var btn := _invest_page_tab_buttons[i] as Button
		if not is_instance_valid(btn):
			continue
		var selected := i == _invest_page_idx
		var page: Dictionary = pages[i]
		btn.text = "%02d  %s" % [i + 1, str(page.get("label", ""))]
		var bg := Color("#16202a" if selected else "#0c1118")
		var border := Color("#d9e2ea" if selected else "#252b35")
		var normal := StyleBoxFlat.new()
		normal.bg_color = bg
		normal.border_color = border
		normal.set_border_width_all(1)
		normal.border_width_bottom = 3 if selected else 1
		normal.set_corner_radius_all(3)
		normal.content_margin_left = 10
		normal.content_margin_right = 10
		normal.content_margin_top = 7
		normal.content_margin_bottom = 7
		var hover := normal.duplicate()
		hover.bg_color = bg.lightened(0.10)
		var focus_st := normal.duplicate()
		focus_st.border_color = Color("#ffffff")
		focus_st.set_border_width_all(UI_FOCUS_BORDER)
		btn.add_theme_stylebox_override("normal", normal)
		btn.add_theme_stylebox_override("hover", hover)
		btn.add_theme_stylebox_override("pressed", normal)
		btn.add_theme_stylebox_override("focus", focus_st)
		btn.add_theme_color_override("font_color", Color("#eef3f8" if selected else "#8f98a8"))

func _set_invest_page(index: int) -> void:
	var pages := _invest_pages()
	if pages.is_empty():
		return
	_invest_page_idx = clampi(index, 0, pages.size() - 1)
	_invest_pad_action_idx = 0
	_render_investment_page()

func _invest_switch_page(delta: int) -> bool:
	var pages := _invest_pages()
	if pages.is_empty():
		return true
	_invest_page_idx = int(posmod(_invest_page_idx + delta, pages.size()))
	_invest_pad_action_idx = 0
	AudioManager.play_ui_click()
	_render_investment_page()
	return true

func _render_investment_page() -> void:
	if not is_instance_valid(_invest_page_body):
		return
	_clear_box(_invest_page_body)
	_invest_pad_asset_ids.clear()
	_invest_pad_asset_cards.clear()
	_style_invest_page_tabs()
	match _invest_current_page_id():
		"assets":
			_render_investment_assets_page()
		"portfolio":
			_render_investment_portfolio_page()
		"market":
			_render_investment_market_page()
		"bank":
			_render_investment_bank_page()
		_:
			_render_investment_assets_page()
	_refresh_invest_pad_hint()

func _build_investment_page_caption(title: String, subtitle: String, accent: String) -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#090d13")
	st.border_color = Color(accent)
	st.set_border_width_all(1)
	st.border_width_left = 4
	st.set_corner_radius_all(6)
	st.content_margin_left = 12
	st.content_margin_right = 12
	st.content_margin_top = 8
	st.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", st)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)
	var title_lbl := _label(title, 15, "#eef3f8")
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if _font_bold:
		title_lbl.add_theme_font_override("font", _font_bold)
	row.add_child(title_lbl)
	var sub_lbl := _label(subtitle, 12, "#8f98a8")
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	sub_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(sub_lbl)
	return panel

func _render_investment_assets_page() -> void:
	var rows: Array = investment_system.get_asset_rows()
	for row in rows:
		_invest_pad_asset_ids.append(str(row.get("id", "")))
	if rows.is_empty():
		_invest_page_body.add_child(_build_investment_page_caption(_tr("거래 가능 자산 없음", "No Tradable Assets"), _tr("시장 데이터 없음", "No market data"), "#64748b"))
		return
	_invest_pad_asset_idx = clampi(_invest_pad_asset_idx, 0, rows.size() - 1)
	var page_no := _tr("자산 %d/%d", "Asset %d/%d") % [_invest_pad_asset_idx + 1, rows.size()]
	_invest_page_body.add_child(_build_investment_page_caption(
		page_no,
		_tr("↑↓ 자산 · ←→ 매수/매도 · LB/RB 페이지", "↑↓ asset · ←→ buy/sell · LB/RB page"),
		"#5b9cf6"))
	if not GameState.flags.get("investment_first_visited", false):
		GameState.flags["investment_first_visited"] = true
		_invest_page_body.add_child(_wrap_label(
			_tr("첫 투자: 낮은 리스크 자산에 10~20만원씩 작게 들어가고, 레버리지는 익숙해진 뒤에 쓰세요.",
			"First trade: start small, KRW 100k-200k in low-risk assets. Save leverage for later."),
			12, "#a7b0c2"))
	elif GameState.investment_skill < 25:
		_invest_page_body.add_child(_wrap_label(
			_tr("입문 팁: 투자감각이 낮으면 수수료가 높습니다. 낮은 리스크 자산부터 작게 시작하세요.",
			"Beginner tip: low Investing means higher fees. Start small with lower-risk assets."),
			12, "#f0b429"))
	var visible_count := mini(2, rows.size())
	var start_idx := clampi(_invest_pad_asset_idx - 1, 0, maxi(0, rows.size() - visible_count))
	var end_idx := mini(rows.size(), start_idx + visible_count)
	for i in range(start_idx, end_idx):
		_invest_page_body.add_child(_build_investment_asset_card(rows[i]))
	var window_lbl := _label(
		_tr("표시 %d-%d / %d — 스크롤 대신 자산 커서로 이동", "Showing %d-%d / %d — move the asset cursor instead of scrolling")
		% [start_idx + 1, end_idx, rows.size()],
		11, "#6f7886")
	window_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_invest_page_body.add_child(window_lbl)
	_apply_invest_pad_cursor()

func _render_investment_portfolio_page() -> void:
	_invest_page_body.add_child(_build_investment_page_caption(
		_tr("보유 포지션", "Holdings"),
		_tr("현재 들고 있는 자산만 요약", "Only positions you currently hold"),
		"#34d399"))
	if GameState.portfolio.is_empty():
		_invest_page_body.add_child(_build_investment_empty_card(
			_tr("아직 보유 자산이 없습니다. 거래 페이지에서 작은 금액으로 시작하세요.", "No positions yet. Start small on the Trade page."),
			"#64748b"))
		return
	var total_cost := 0.0
	var total_now := 0.0
	for aid in GameState.portfolio:
		var h: Dictionary = GameState.portfolio[aid]
		var qty := float(h.get("quantity", 0.0))
		var avg_p := float(h.get("avg_price", 0.0))
		var now_p := float(GameState.market_prices.get(aid, avg_p))
		total_cost += qty * avg_p
		total_now += qty * now_p
	var overall_pct := (total_now - total_cost) / maxf(total_cost, 0.01) * 100.0
	var overall_color := "#34d399" if overall_pct >= 0.0 else "#ff7070"
	_invest_page_body.add_child(_build_investment_empty_card(
		_tr("원금 %s → 현재 %s  (%+.1f%%)", "Cost %s → Value %s  (%+.1f%%)")
		% [GameState.format_money(total_cost), GameState.format_money(total_now), overall_pct],
		overall_color))
	var shown := 0
	for aid in GameState.portfolio:
		if shown >= 4:
			break
		_invest_page_body.add_child(_build_investment_holding_card(str(aid)))
		shown += 1
	if GameState.portfolio.size() > shown:
		_invest_page_body.add_child(_wrap_label(_tr("외 %d개 포지션", "%d more positions") % (GameState.portfolio.size() - shown), 11, "#6f7886"))

func _render_investment_market_page() -> void:
	_invest_page_body.add_child(_build_investment_market_board())
	_invest_page_body.add_child(_build_investment_page_caption(
		_tr("시장 움직임", "Market Moves"),
		_tr("변동폭이 큰 자산 4개", "Top 4 movers"),
		"#f0b429"))
	var movers: Array = []
	for row in investment_system.get_asset_rows():
		var aid := str(row.get("id", ""))
		var hist: Array = GameState.price_history.get(aid, [])
		if hist.size() < 2:
			continue
		var d1 := (float(hist[-1]) - float(hist[-2])) / maxf(float(hist[-2]), 0.01) * 100.0
		movers.append({"abs": absf(d1), "delta": d1, "row": row})
	movers.sort_custom(func(a, b): return float(a.get("abs", 0.0)) > float(b.get("abs", 0.0)))
	if movers.is_empty():
		_invest_page_body.add_child(_build_investment_empty_card(_tr("가격 기록 축적 중입니다.", "Price history is still building."), "#64748b"))
	else:
		for i in range(mini(4, movers.size())):
			var row: Dictionary = movers[i].get("row", {})
			var delta := float(movers[i].get("delta", 0.0))
			var color := "#34d399" if delta >= 0.0 else "#ff7070"
			_invest_page_body.add_child(_build_investment_empty_card(
				"%s   %s   %+.1f%%" % [str(row.get("name", row.get("id", ""))), GameState.format_money(float(row.get("price", 0.0))), delta],
				color))

func _render_investment_bank_page() -> void:
	_invest_page_body.add_child(_build_investment_page_caption(
		_tr("은행 / 레버리지", "Bank / Leverage"),
		_tr("대출은 행동력 무소비", "Loans do not cost AP"),
		"#f0b429"))
	var grade := GameState.get_credit_grade()
	var grade_label := GameState.get_credit_grade_label()
	var grade_color := "#34d399" if grade <= 3 else ("#f0b429" if grade <= 6 else ("#f97316" if grade <= 8 else "#ff7070"))
	_invest_page_body.add_child(_build_investment_empty_card(
		_tr("신용 %d등급 (%s) · 점수 %d/100", "Credit Grade %d (%s) · Score %d/100") % [grade, grade_label, GameState.get_credit_score()],
		grade_color))
	for product in GameState.LOAN_PRODUCTS:
		_invest_page_body.add_child(_build_investment_loan_card(str(product)))
	if GameState.investment_skill >= 30:
		var lev_btn := _icon_button(_tr("레버리지 투자 — 2배 포지션", "Leverage Investing — 2x Position"), "leverage", "#321516")
		lev_btn.custom_minimum_size = Vector2(0, 42)
		lev_btn.pressed.connect(_open_leverage_investments)
		_invest_page_body.add_child(lev_btn)
	else:
		_invest_page_body.add_child(_wrap_label(
			_tr("레버리지 잠금 — 투자감각 30 필요 (현재 %d)", "Leverage locked — Investing 30 required (current %d)") % GameState.investment_skill,
			12, "#64748b"))

func _build_investment_empty_card(text: String, accent: String) -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#0a0e14")
	st.border_color = Color(accent)
	st.set_border_width_all(1)
	st.border_width_left = 4
	st.set_corner_radius_all(6)
	st.content_margin_left = 12
	st.content_margin_right = 12
	st.content_margin_top = 8
	st.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", st)
	panel.add_child(_wrap_label(text, 13, "#cbd5e1"))
	return panel

func _investment_asset_row(asset_id: String) -> Dictionary:
	for row in investment_system.get_asset_rows():
		if str(row.get("id", "")) == asset_id:
			return row
	return {}

func _build_investment_holding_card(asset_id: String) -> Control:
	var row := _investment_asset_row(asset_id)
	var holding: Dictionary = GameState.portfolio.get(asset_id, {})
	var price := float(GameState.market_prices.get(asset_id, row.get("price", 0.0)))
	var qty := float(holding.get("quantity", 0.0))
	var avg := float(holding.get("avg_price", price))
	var value := qty * price
	var pct := (price - avg) / maxf(avg, 0.01) * 100.0
	var color := "#34d399" if pct >= 0.0 else "#ff7070"
	return _build_investment_empty_card(
		"%s   %s   %+.1f%%" % [str(row.get("name", asset_id)), GameState.format_money(value), pct],
		color)

func _build_investment_loan_card(product: String) -> Control:
	var info: Dictionary = GameState.LOAN_PRODUCTS.get(product, {})
	var owed := float(GameState.loans.get(product, 0.0))
	var limit := GameState.get_loan_limit(product)
	var rate := GameState.get_loan_rate(product)
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#0a0e14")
	st.border_color = Color("#f0b429" if owed > 0.0 else "#334155")
	st.set_border_width_all(1)
	st.border_width_left = 4
	st.set_corner_radius_all(6)
	st.content_margin_left = 12
	st.content_margin_right = 12
	st.content_margin_top = 8
	st.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", st)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	var name := GameState.get_loan_name(product)
	box.add_child(_label(_tr("%s · 월 %.2f%%", "%s · Monthly %.2f%%") % [name, rate * 100.0], 14, "#e8eaf0"))
	box.add_child(_wrap_label(_tr("잔액 %s / 한도 %s", "Balance %s / Limit %s") % [GameState.format_money(owed), GameState.format_money(limit)], 12, "#8f98a8"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	box.add_child(row)
	if limit - owed >= 5_000_000.0:
		var borrow_5 := _small_button("+%s" % GameState.format_money(5_000_000.0), "#143526")
		borrow_5.pressed.connect(_bank_borrow.bind(product, 5_000_000.0))
		row.add_child(borrow_5)
	if limit - owed >= 20_000_000.0:
		var borrow_20 := _small_button("+%s" % GameState.format_money(20_000_000.0), "#143526")
		borrow_20.pressed.connect(_bank_borrow.bind(product, 20_000_000.0))
		row.add_child(borrow_20)
	if owed > 0.0:
		var repay_5 := _small_button(_tr("500만 상환", "Repay 5M"), "#162436")
		repay_5.pressed.connect(_bank_repay.bind(product, 5_000_000.0))
		row.add_child(repay_5)
		var repay_all := _small_button(_tr("전액", "All"), "#162436")
		repay_all.pressed.connect(_bank_repay.bind(product, owed))
		row.add_child(repay_all)
	if row.get_child_count() == 0:
		box.add_child(_wrap_label(_tr("현재 실행 가능한 대출/상환 버튼이 없습니다.", "No borrow/repay action is currently available."), 12, "#64748b"))
	return panel

func _open_investments():
	_open_modal(_tr("투자 / 매수·매도", "Invest / Buy·Sell"), true, "investments")
	_invest_page_idx = clampi(_invest_page_idx, 0, _invest_pages().size() - 1)
	_invest_pad_asset_cards.clear()
	_invest_pad_asset_ids.clear()
	_invest_pad_action_idx = 0
	_invest_page_tab_buttons.clear()
	if modal_scroll:
		modal_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
		modal_scroll.custom_minimum_size = Vector2(0, 540)
	if modal_panel:
		modal_panel.custom_minimum_size = Vector2(840, 700)
		modal_panel.offset_left = -420
		modal_panel.offset_right = 420
		modal_panel.offset_top = -350
		modal_panel.offset_bottom = 350
	modal_body.add_theme_constant_override("separation", 8)
	modal_body.add_child(_modal_section_header(
		_tr("투자 데스크", "Investment Desk"),
		"invest",
		"#34d399",
		_tr("거래/보유/시장/은행을 페이지로 나눴습니다. 조회는 무료, 매수·매도만 행동력 1을 씁니다.", "Trade, holdings, market, and bank are paged. Browsing is free; buy/sell costs 1 AP.")))
	modal_body.add_child(_build_investment_status_strip())
	_invest_pad_hint_label = RichTextLabel.new()
	_invest_pad_hint_label.bbcode_enabled = true
	_invest_pad_hint_label.fit_content = true
	_invest_pad_hint_label.scroll_active = false
	_invest_pad_hint_label.custom_minimum_size = Vector2(0, 24)
	_invest_pad_hint_label.add_theme_font_size_override("normal_font_size", 11)
	_invest_pad_hint_label.add_theme_color_override("default_color", Color("#8f98a8"))
	if _font_bold:
		_invest_pad_hint_label.add_theme_font_override("bold_font", _font_bold)
	modal_body.add_child(_invest_pad_hint_label)
	modal_body.add_child(_build_investment_page_tabs())
	_invest_page_body = VBoxContainer.new()
	_invest_page_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_invest_page_body.add_theme_constant_override("separation", 8)
	modal_body.add_child(_invest_page_body)
	_render_investment_page()

func _handle_investment_modal_input(event: InputEvent) -> bool:
	if event is InputEventKey and (event as InputEventKey).echo:
		return false
	if event.is_action_pressed("gd_tab_prev"):
		return _invest_switch_page(-1)
	if event.is_action_pressed("gd_tab_next"):
		return _invest_switch_page(1)
	if _invest_current_page_id() != "assets":
		return false
	if event.is_action_pressed("ui_up"):
		return _invest_move_asset(-1)
	if event.is_action_pressed("ui_down"):
		return _invest_move_asset(1)
	if event.is_action_pressed("ui_left"):
		return _invest_cycle_action(-1)
	if event.is_action_pressed("ui_right"):
		return _invest_cycle_action(1)
	if event.is_action_pressed("ui_accept"):
		return _invest_confirm_action()
	return false

func _invest_selected_asset_id() -> String:
	if _invest_pad_asset_ids.is_empty():
		return ""
	_invest_pad_asset_idx = clampi(_invest_pad_asset_idx, 0, _invest_pad_asset_ids.size() - 1)
	return str(_invest_pad_asset_ids[_invest_pad_asset_idx])

func _invest_asset_display_name(asset_id: String) -> String:
	for row in investment_system.get_asset_rows():
		if str(row.get("id", "")) == asset_id:
			return str(row.get("name", asset_id))
	return asset_id

func _invest_pad_actions(asset_id: String) -> Array:
	var actions: Array = []
	if asset_id.is_empty() or GameState.action_points <= 0:
		return actions
	for amount in [100_000, 500_000, 1_000_000]:
		if GameState.money >= float(amount):
			actions.append({
				"label": _tr("매수 %s", "Buy %s") % GameState.format_money(float(amount)),
				"callback": Callable(self, "_on_buy_asset").bind(asset_id, amount)
			})
	if GameState.portfolio.has(asset_id):
		for sell_info in [["25%", 0.25], ["50%", 0.5], [_tr("전량", "All"), 1.0]]:
			actions.append({
				"label": _tr("매도 %s", "Sell %s") % sell_info[0],
				"callback": Callable(self, "_on_sell_asset").bind(asset_id, sell_info[1])
			})
	return actions

func _invest_move_asset(delta: int) -> bool:
	if _invest_pad_asset_ids.is_empty():
		return true
	_invest_pad_asset_idx = int(posmod(_invest_pad_asset_idx + delta, _invest_pad_asset_ids.size()))
	_invest_pad_action_idx = 0
	AudioManager.play_ui_click()
	if _invest_current_page_id() == "assets" and is_instance_valid(_invest_page_body):
		_render_investment_page()
	else:
		_apply_invest_pad_cursor()
	return true

func _invest_cycle_action(delta: int) -> bool:
	if _invest_current_page_id() != "assets":
		return false
	var actions := _invest_pad_actions(_invest_selected_asset_id())
	if actions.is_empty():
		_refresh_invest_pad_hint()
		return true
	_invest_pad_action_idx = int(posmod(_invest_pad_action_idx + delta, actions.size()))
	AudioManager.play_ui_click()
	_refresh_invest_pad_hint()
	return true

func _invest_confirm_action() -> bool:
	var actions := _invest_pad_actions(_invest_selected_asset_id())
	if actions.is_empty():
		_show_toast(_tr("가능한 거래가 없습니다", "No available trade"), Color("#9aa4b8"))
		return true
	_invest_pad_action_idx = clampi(_invest_pad_action_idx, 0, actions.size() - 1)
	var cb: Callable = actions[_invest_pad_action_idx].get("callback", Callable())
	if cb.is_valid():
		cb.call()
	return true

func _apply_invest_pad_cursor() -> void:
	if _invest_pad_asset_ids.is_empty():
		_refresh_invest_pad_hint()
		return
	var selected_id := _invest_selected_asset_id()
	for card in _invest_pad_asset_cards:
		if not is_instance_valid(card):
			continue
		var panel := card as PanelContainer
		var asset_id := str(panel.get_meta("invest_asset_id", ""))
		var selected := asset_id == selected_id and ControllerHints.is_pad_active()
		var st := StyleBoxFlat.new()
		st.bg_color = Color("#0b1116")
		st.border_color = Color(COL_GOLD_BRIGHT if selected else str(panel.get_meta("invest_base_border", "#8892a4")))
		st.set_border_width_all(2 if selected else 1)
		st.border_width_left = 6 if selected else 4
		st.set_corner_radius_all(7)
		st.content_margin_left = 14
		st.content_margin_right = 14
		st.content_margin_top = 12
		st.content_margin_bottom = 12
		panel.add_theme_stylebox_override("panel", st)
	_refresh_invest_pad_hint()

func _refresh_invest_pad_hint() -> void:
	if not is_instance_valid(_invest_pad_hint_label):
		return
	if not ControllerHints.is_pad_active() or _modal_kind != "investments":
		_invest_pad_hint_label.visible = false
		return
	_invest_pad_hint_label.visible = true
	var page_id := _invest_current_page_id()
	if page_id != "assets":
		var page_label := ""
		for page in _invest_pages():
			if str(page.get("id", "")) == page_id:
				page_label = str(page.get("label", ""))
				break
		_invest_pad_hint_label.text = _tr(
			"[b]패드[/b]  LB/RB 페이지 · %s 뒤로  —  %s",
			"[b]Pad[/b]  LB/RB Page · %s Back  —  %s"
		) % [ControllerHints.east(), page_label]
		return
	var asset_id := _invest_selected_asset_id()
	if asset_id.is_empty():
		_invest_pad_hint_label.text = _tr("[b]패드[/b]  LB/RB 페이지 · 거래 가능한 자산 없음", "[b]Pad[/b]  LB/RB Page · No tradable assets")
		return
	var actions := _invest_pad_actions(asset_id)
	var action_label := _tr("거래 불가", "No trade")
	if not actions.is_empty():
		_invest_pad_action_idx = clampi(_invest_pad_action_idx, 0, actions.size() - 1)
		action_label = str(actions[_invest_pad_action_idx].get("label", action_label))
	_invest_pad_hint_label.text = _tr(
		"[b]패드[/b]  LB/RB 페이지 · ↑↓ 자산 · ←→ 행동 · %s %s · %s 뒤로  —  %s",
		"[b]Pad[/b]  LB/RB Page · ↑↓ Asset · ←→ Action · %s %s · %s Back  —  %s"
	) % [ControllerHints.south(), action_label, ControllerHints.east(), _invest_asset_display_name(asset_id)]

func _build_investment_asset_card(row: Dictionary) -> Control:
	var asset_id: String = str(row.get("id", ""))
	var price: float = float(row.get("price", 0.0))
	var risk_level: int = int(row.get("risk_level", 1))
	var risk_str: String = _tr("리스크 %d/5", "Risk %d/5") % risk_level
	var hist: Array = GameState.price_history.get(asset_id, [])
	var sparkline: String = _price_sparkline(hist)
	var trend_color: String = "#8892a4"
	if hist.size() >= 2:
		trend_color = "#00c896" if float(hist[-1]) >= float(hist[-2]) else "#ff4444"

	var panel := PanelContainer.new()
	panel.set_meta("invest_asset_id", asset_id)
	panel.set_meta("invest_base_border", trend_color)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#0b1116")
	st.border_color = Color(trend_color)
	st.set_border_width_all(1)
	st.border_width_left = 4
	st.set_corner_radius_all(7)
	st.content_margin_left = 14
	st.content_margin_right = 14
	st.content_margin_top = 12
	st.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", st)
	_invest_pad_asset_cards.append(panel)

	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	box.add_child(header)

	var name_lbl: Label = _label(str(row.get("name", asset_id)), 16, "#e8eaf0")
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if _font_bold:
		name_lbl.add_theme_font_override("font", _font_bold)
	header.add_child(name_lbl)

	var risk_color: String = "#94a3b8"
	if risk_level >= 4:
		risk_color = "#ff7070"
	elif risk_level <= 2:
		risk_color = "#34d399"
	var risk_lbl := _label(risk_str, 13, risk_color)
	risk_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	risk_lbl.custom_minimum_size = Vector2(94, 0)
	header.add_child(risk_lbl)

	var price_lbl := _label(GameState.format_money(price), 15, trend_color)
	price_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	price_lbl.custom_minimum_size = Vector2(132, 0)
	if _font_bold:
		price_lbl.add_theme_font_override("font", _font_bold)
	header.add_child(price_lbl)

	var asset_tags: Array = row.get("tags", [])
	if not asset_tags.is_empty():
		var tag_str: String = "  ".join(asset_tags.map(func(t): return "[%s]" % t))
		box.add_child(_wrap_label(tag_str, 13, "#6b7c96"))

	var hist_parts: Array = []
	if hist.size() < 2:
		hist_parts.append(_tr("가격 기록 축적 중", "Price history building"))
	else:
		hist_parts.append(sparkline)
		var d1: float = (float(hist[-1]) - float(hist[-2])) / max(float(hist[-2]), 0.01) * 100.0
		hist_parts.append(_tr("1개월 %+.1f%%", "1mo %+.1f%%") % d1)
	if hist.size() >= 4:
		var d3: float = (float(hist[-1]) - float(hist[hist.size() - 4])) / max(float(hist[hist.size() - 4]), 0.01) * 100.0
		hist_parts.append(_tr("3개월 %+.1f%%", "3mo %+.1f%%") % d3)
	if hist.size() >= 12:
		var d12: float = (float(hist[-1]) - float(hist[0])) / max(float(hist[0]), 0.01) * 100.0
		hist_parts.append(_tr("12개월 %+.1f%%", "12mo %+.1f%%") % d12)
	box.add_child(_wrap_label("  |  ".join(hist_parts), 14, trend_color if hist.size() >= 2 else "#64748b"))

	var buy_row := HBoxContainer.new()
	buy_row.add_theme_constant_override("separation", 8)
	box.add_child(buy_row)
	for amount in [100_000, 500_000, 1_000_000]:
		var can_afford: bool = GameState.money >= amount
		var btn_color: String = "#00c896" if can_afford else "#64748b"
		var buy_btn := _small_button(_tr("매수 %s", "Buy %s") % GameState.format_money(float(amount)), btn_color)
		buy_btn.custom_minimum_size = Vector2(0, UI_MIN_BUTTON_HEIGHT)
		buy_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		buy_btn.disabled = not can_afford
		buy_btn.pressed.connect(Callable(self, "_on_buy_asset").bind(asset_id, amount))
		buy_row.add_child(buy_btn)

	if GameState.portfolio.has(asset_id):
		var holding: Dictionary = GameState.portfolio[asset_id]
		var owned_val: float = float(holding.get("quantity", 0.0)) * price
		var avg_price: float = float(holding.get("avg_price", price))
		var profit_pct: float = (price - avg_price) / max(avg_price, 0.01) * 100.0
		var profit_color: String = "#00c896" if profit_pct >= 0.0 else "#ff4444"
		box.add_child(_wrap_label(
			_tr("보유 평가액 %s  |  평단 %s  |  수익률 %+.1f%%", "Holdings %s  |  Avg %s  |  Return %+.1f%%")
			% [GameState.format_money(owned_val), GameState.format_money(avg_price), profit_pct],
			14, profit_color))
		var sell_row := HBoxContainer.new()
		sell_row.add_theme_constant_override("separation", 8)
		box.add_child(sell_row)
		for sell_info in [["25%", 0.25], ["50%", 0.5], [_tr("전량", "All"), 1.0]]:
			var sell_btn: Button = _small_button(_tr("매도 %s", "Sell %s") % sell_info[0], "#ff4444")
			sell_btn.custom_minimum_size = Vector2(0, UI_MIN_SMALL_BUTTON_HEIGHT)
			sell_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			sell_btn.pressed.connect(Callable(self, "_on_sell_asset").bind(asset_id, sell_info[1]))
			sell_row.add_child(sell_btn)

	return panel

func _open_shop():
	_open_modal(_tr("상점", "Shop"), true)
	modal_body.add_child(_modal_section_header(
		_tr("생활 / 자기관리 아이템", "Life / Self-Care Items"),
		"shop",
		"#34d399",
		_tr("구매한 아이템은 인벤토리에 보관되며 일부는 사용 시 행동력을 소비합니다.", "Purchased items go to your inventory; some cost AP to use.")))
	for item in inventory_system.get_shop_items():
		modal_body.add_child(_build_shop_item_card(item))

func _build_shop_item_card(item: Dictionary) -> Control:
	var price: float = float(item.get("price", 0.0))
	var can_buy: bool = GameState.money >= price
	var accent: Color = _moral_gray_accent(Color("#34d399" if can_buy else "#64748b"), _moral_ui_palette(), 0.04)

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#0b1116")
	st.border_color = accent
	st.set_border_width_all(1)
	st.border_width_left = 4
	st.set_corner_radius_all(7)
	st.content_margin_left = 14
	st.content_margin_right = 14
	st.content_margin_top = 12
	st.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", st)

	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	box.add_child(header)

	var item_name: String = str(item.get("name", ""))
	var name_lbl := _label(item_name, 16, "#e8eaf0")
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if _font_bold:
		name_lbl.add_theme_font_override("font", _font_bold)
	header.add_child(name_lbl)

	var price_lbl := _label(GameState.format_money(price), 15, "#e2e8f0" if can_buy else "#94a3b8")
	price_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	price_lbl.custom_minimum_size = Vector2(110, 0)
	if _font_bold:
		price_lbl.add_theme_font_override("font", _font_bold)
	header.add_child(price_lbl)

	var effect_parts: Array = []
	for k in item.get("effects", {}):
		var v: int = int(item["effects"][k])
		var sign: String = "+" if v >= 0 else ""
		effect_parts.append("%s %s%d" % [_stat_name(k), sign, v])
	for k in item.get("passive_effects", {}):
		var v2: int = int(item["passive_effects"][k])
		var sign2: String = "+" if v2 >= 0 else ""
		effect_parts.append(_tr("매달 %s %s%d", "monthly %s %s%d") % [_stat_name(k), sign2, v2])
	var one_time: bool = bool(item.get("one_time", true))
	var use_type: String = _tr("사용 시 소모", "Consumed on use") if one_time else _tr("보유 지속 효과", "Passive while held")
	if not effect_parts.is_empty():
		box.add_child(_wrap_label("%s  [%s]" % [", ".join(effect_parts), use_type], 14, "#cbd5e1" if can_buy else "#94a3b8"))
	if not item.get("description", "").is_empty():
		box.add_child(_wrap_label(str(item.get("description", "")), 14, "#7f8ea3"))

	var buy_btn := _small_button(_tr("구매", "Buy"), "#1c242c" if can_buy else "#334155")
	buy_btn.custom_minimum_size = Vector2(0, UI_MIN_BUTTON_HEIGHT)
	buy_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buy_btn.disabled = not can_buy
	buy_btn.pressed.connect(Callable(self, "_on_shop_item").bind(item.get("id", "")))
	box.add_child(buy_btn)

	return panel

func _on_save_pressed():
	SaveManager.save_game(1)
	GameState.add_log(_tr("게임 저장 완료", "Game saved"), "system")
	_show_toast(_tr("저장 완료", "Saved"), Color("#00c896"))

func _on_job_selected(job_id):
	var had_resume = GameState.flags.get("resume_polished", false)
	var had_interview = GameState.flags.get("interview_practiced", false)
	var is_first_job = GameState.current_job.is_empty()
	job_system.apply_for_job(job_id)
	var job_name = GameState.get_job_display_name()
	var salary = GameState.format_money(GameState.monthly_income)
	var prep_bonus = (10 if had_resume else 0) + (7 if had_interview else 0)
	var prep_note = (_tr("  (준비 보너스 +%d 업무능력)", "  (prep bonus +%d work skill)") % prep_bonus) if prep_bonus > 0 else ""
	# 구직 로그 항목 갱신
	for i in range(turn_action_log.size() - 1, -1, -1):
		var entry := str(turn_action_log[i])
		if entry.begins_with(_tr("구직활동", "Job Hunt")) or entry.begins_with("✓ 💼"):
			turn_action_log[i] = _tr("구직활동 → %s 취업%s", "Job Hunt → hired at %s%s") % [job_name, prep_note]
			break
	_close_modal()
	_refresh_all()
	if is_first_job:
		AudioManager.play("housing_up")
		_show_toast(_tr("첫 취업 — %s  월 %s%s", "First job — %s  monthly %s%s") % [job_name, salary, prep_note], Color("#9aa4b8"))
	else:
		_show_toast(_tr("%s  월 %s%s", "%s  monthly %s%s") % [job_name, salary, prep_note], Color("#9aa4b8"))

func _on_buy_asset(asset_id, amount):
	if not GameState.spend_ap():
		_show_toast(_tr("행동력이 없습니다. 이번 달 거래 불가", "No Action Points. No trading this month."), Color("#ff4444"))
		_close_modal()
		return
	AudioManager.play("money_gain")
	investment_system.buy_asset(asset_id, float(amount))
	GameState.add_tendency("invest", 1)   # 자산 매수 = 투자형
	var asset_name = asset_id
	for data in DataRegistry.assets:
		if data.get("id", "") == asset_id:
			asset_name = data.get("name", asset_id)
			break
	turn_action_log.append(_tr("✓ 투자 → %s 매수 %s", "✓ Invest → bought %s %s") % [asset_name, GameState.format_money(amount)])
	_close_modal()
	_refresh_all()
	_show_toast(_tr("매수 완료 %s", "Bought %s") % GameState.format_money(amount), Color("#00c896"))

func _on_sell_asset(asset_id, ratio):
	if not GameState.spend_ap():
		_show_toast(_tr("행동력이 없습니다. 이번 달 거래 불가", "No Action Points. No trading this month."), Color("#ff4444"))
		_close_modal()
		return
	AudioManager.play("money_loss")
	investment_system.sell_asset(asset_id, float(ratio))
	var asset_name = asset_id
	for data in DataRegistry.assets:
		if data.get("id", "") == asset_id:
			asset_name = data.get("name", asset_id)
			break
	turn_action_log.append(_tr("✓ 투자 → %s 매도", "✓ Invest → sold %s") % asset_name)
	_close_modal()
	_refresh_all()
	_show_toast(_tr("매도 완료", "Sold"), Color("#ff4444"))

func _on_shop_item(item_id):
	inventory_system.purchase_item(item_id)
	_close_modal()
	_refresh_all()
	_show_toast(_tr("아이템 구매 완료", "Item purchased"), Color("#d8b4fe"))

func _on_use_item(item_id):
	var result: Dictionary = inventory_system.use_item(item_id)
	_refresh_all()
	if result.get("success", false):
		_show_toast(_tr("아이템 사용 (행동력 -1)", "Item used (AP -1)"), Color("#fbbf24"))
	else:
		_show_toast(str(result.get("message", _tr("사용 불가", "Cannot use"))), Color("#ff4444"))

func _open_system_menu():
	_open_modal(_tr("시스템", "System"), true)
	modal_body.add_child(_modal_section_header(
		_tr("설정 / 저장", "Settings / Save"),
		"menu",
		"#60a5fa",
		_tr("오디오, 화면, 세이브 슬롯을 관리합니다.", "Manage audio, display, and save slots.")))

	_build_volume_sliders(modal_body)
	_build_fullscreen_toggle(modal_body)
	_build_save_load_section(modal_body)

	var sep = HSeparator.new()
	sep.modulate = Color("#2a2a3a")
	modal_body.add_child(sep)

	var menu_btn2 := _icon_button(_tr("메인 메뉴로", "Main Menu"), "menu", "#1e3a5f")
	menu_btn2.pressed.connect(_go_to_menu)
	modal_body.add_child(menu_btn2)

	var quit_btn := _icon_button(_tr("게임 종료", "Quit Game"), "menu", "#5a1a1a")
	quit_btn.pressed.connect(func():
		SaveManager.autosave()
		get_tree().quit()
	)
	modal_body.add_child(quit_btn)

	var cancel_btn = _button(_tr("취소", "Cancel"), "#2a2a3a")
	cancel_btn.pressed.connect(_close_modal)
	modal_body.add_child(cancel_btn)

func _build_volume_sliders(parent: Control):
	var _make_row = func(label_text: String, init_val: float, on_change: Callable):
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		parent.add_child(row)
		var lbl = Label.new()
		lbl.text = label_text
		lbl.add_theme_font_size_override("font_size", 13)
		lbl.add_theme_color_override("font_color", Color("#8892a4"))
		lbl.custom_minimum_size = Vector2(48, 0)
		row.add_child(lbl)
		var slider = HSlider.new()
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.05
		slider.value = init_val
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.custom_minimum_size = Vector2(0, 24)
		slider.value_changed.connect(on_change)
		row.add_child(slider)
		var pct = Label.new()
		pct.text = "%d%%" % int(init_val * 100)
		pct.add_theme_font_size_override("font_size", 12)
		pct.add_theme_color_override("font_color", Color("#5a6075"))
		pct.custom_minimum_size = Vector2(36, 0)
		pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(pct)
		slider.value_changed.connect(func(v): pct.text = "%d%%" % int(v * 100))

	_make_row.call("BGM", AudioManager.bgm_volume, func(v): AudioManager.set_bgm_volume(v))
	_make_row.call("SFX", AudioManager.master_volume, func(v): AudioManager.set_sfx_volume(v))

func _build_fullscreen_toggle(parent: Control):
	if OS.has_feature("web"):
		return
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	parent.add_child(row)
	var lbl = Label.new()
	lbl.text = _tr("전체화면", "Fullscreen")
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", Color("#8892a4"))
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl)
	var hint = Label.new()
	hint.text = "F11 / Alt+Enter"
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color("#5a6075"))
	row.add_child(hint)
	var toggle = CheckButton.new()
	toggle.button_pressed = DisplayManager.fullscreen
	toggle.toggled.connect(func(on): DisplayManager.set_fullscreen(on))
	row.add_child(toggle)

func _build_save_load_section(parent: Control):
	var sep = HSeparator.new()
	sep.modulate = Color("#2a2a3a")
	parent.add_child(sep)
	var header = _label(_tr("저장 / 불러오기", "Save / Load"), 12, "#5a6075")
	parent.add_child(header)
	for slot in range(1, 4):
		var info = SaveManager.get_save_info(slot)
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		parent.add_child(row)
		var slot_lbl = _label(_tr("슬롯 %d", "Slot %d") % slot, 12, "#8892a4")
		slot_lbl.custom_minimum_size = Vector2(48, 0)
		row.add_child(slot_lbl)
		var info_lbl = Label.new()
		info_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_lbl.add_theme_font_size_override("font_size", 11)
		if _font_regular:
			info_lbl.add_theme_font_override("font", _font_regular)
		if info.get("empty", true):
			info_lbl.text = _tr("빈 슬롯", "Empty slot")
			info_lbl.add_theme_color_override("font_color", Color("#3a3a5a"))
		else:
			info_lbl.text = _tr("%d년 %d월  %s", "Year %d Month %d  %s") % [
				info.get("year", 0), info.get("month", 0),
				GameState.format_money(float(info.get("total_assets", 0)))]
			info_lbl.add_theme_color_override("font_color", Color("#7a8496"))
		row.add_child(info_lbl)
		var save_btn = _small_button(_tr("저장", "Save"), "#3a5a8a")
		save_btn.custom_minimum_size = Vector2(52, 32)
		save_btn.pressed.connect(_save_to_slot.bind(slot))
		row.add_child(save_btn)
		var load_btn = _small_button(_tr("불러오기", "Load"), "#2a5a3a" if not info.get("empty", true) else "#242430")
		load_btn.custom_minimum_size = Vector2(72, 32)
		if info.get("empty", true):
			load_btn.disabled = true
		else:
			load_btn.pressed.connect(_load_from_slot.bind(slot))
		row.add_child(load_btn)

func _save_to_slot(slot: int):
	SaveManager.save_game(slot)
	_close_modal()
	_show_toast(_tr("슬롯 %d에 저장했습니다", "Saved to slot %d") % slot, Color("#c9a227"))

func _load_from_slot(slot: int):
	SaveManager.load_game(slot)
	SceneTransition.go("res://scenes/MainGame.tscn")

func _unhandled_input(event):
	if GameState.is_game_over:
		return
	# Space/Enter: 타이핑 스킵 (비주얼노벨 표준 — 모달 닫힌 상태에서만)
	if event.is_action_pressed("ui_accept") and not modal_layer.visible:
		if _typing_tween and _typing_tween.is_running():
			_finish_typing()
			get_viewport().set_input_as_handled()
			return
	# R1/RB/R: AP 소진 후 다음 달로 (패드 전용 빠른 진행)
	if event.is_action_pressed("gd_next_month"):
		if not modal_layer.visible and GameState.action_points <= 0:
			_on_next_month()
			get_viewport().set_input_as_handled()
		return
	# Start/Options/+: 시스템 메뉴 (ESC·B와 동일 역할, 패드에서 더 직관적)
	if event.is_action_pressed("gd_menu"):
		if not modal_layer.visible:
			_open_system_menu()
		get_viewport().set_input_as_handled()
		return
	# RB/LB: 정보 탭 순환 (모달 닫힌 상태에서만)
	if event.is_action_pressed("gd_tab_next") and not modal_layer.visible:
		if is_instance_valid(info_panel) and info_panel.visible and info_tabs:
			info_tabs.current_tab = (info_tabs.current_tab + 1) % info_tabs.get_tab_count()
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("gd_tab_prev") and not modal_layer.visible:
		if is_instance_valid(info_panel) and info_panel.visible and info_tabs:
			info_tabs.current_tab = (info_tabs.current_tab - 1 + info_tabs.get_tab_count()) % info_tabs.get_tab_count()
			get_viewport().set_input_as_handled()
		return
	if modal_layer and modal_layer.visible and _modal_kind == "investments":
		if _handle_investment_modal_input(event):
			get_viewport().set_input_as_handled()
			return
	if modal_layer and modal_layer.visible and _modal_kind == "jobs":
		if _handle_job_modal_input(event):
			get_viewport().set_input_as_handled()
			return
	if modal_layer and modal_layer.visible and _modal_kind == "people_actions":
		if _handle_people_modal_input(event):
			get_viewport().set_input_as_handled()
			return
	if not event.is_action_pressed("ui_cancel"):
		return
	if modal_layer and modal_layer.visible:
		# 메뉴형 모달만 ESC/B로 닫는다. 이벤트/결산/엔딩은 흐름 보호를 위해 명시 버튼으로만 닫는다.
		if _modal_cancelable:
			_close_modal()
			get_viewport().set_input_as_handled()
		return
	if is_instance_valid(info_panel) and info_panel.visible:
		_toggle_info_panel()
		get_viewport().set_input_as_handled()
		return
	_open_system_menu()
	get_viewport().set_input_as_handled()

func _go_to_menu():
	SaveManager.autosave()
	SceneTransition.go("res://scenes/StartMenu.tscn")

func _open_modal(title, cancelable: bool = false, kind: String = ""):
	_clear_box(modal_body)
	modal_title_label.text = title
	_modal_cancelable = cancelable
	_modal_kind = kind
	_invest_pad_hint_label = null
	_job_pad_hint_label = null
	_people_pad_hint_label = null
	if is_instance_valid(modal_pad_hint_label):
		modal_pad_hint_label.visible = cancelable and ControllerHints.is_pad_active()
		modal_pad_hint_label.text = _tr("[%s] 뒤로", "[%s] Back") % ControllerHints.east()
	modal_layer.visible = true
	modal_layer.color = Color(0, 0, 0, 0.70)
	modal_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	# 스크롤/크기/위치 기본값 복원
	if modal_scroll:
		modal_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		modal_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		modal_scroll.custom_minimum_size = Vector2(0, 468)
		modal_scroll.scroll_vertical = 0
	if modal_panel:
		modal_panel.add_theme_stylebox_override("panel", _modal_style("#13131a", "#252535", 6, 12, 10))
		modal_panel.custom_minimum_size = Vector2(760, 610)
		modal_panel.offset_left   = -380
		modal_panel.offset_right  =  380
		modal_panel.offset_top    = -305
		modal_panel.offset_bottom =  305
	AudioManager.play_ui_open()
	call_deferred("_reset_modal_scroll")
	call_deferred("_focus_first_in_modal_body")

func _modal_style(bg: String, border: String, radius: int = 6, h_margin: int = 12, v_margin: int = 10) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(bg)
	style.border_color = Color(border)
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = h_margin
	style.content_margin_right = h_margin
	style.content_margin_top = v_margin
	style.content_margin_bottom = v_margin
	return style

func _reset_modal_scroll() -> void:
	if is_instance_valid(modal_scroll):
		modal_scroll.scroll_vertical = 0

func _focus_first_in_modal_body():
	for child in modal_body.get_children():
		if child is Button and child.focus_mode != Control.FOCUS_NONE and not child.disabled:
			child.grab_focus()
			return

func _close_modal():
	modal_layer.visible = false
	modal_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_modal_cancelable = false
	_modal_kind = ""
	_invest_pad_hint_label = null
	_job_pad_hint_label = null
	_people_pad_hint_label = null
	if is_instance_valid(modal_pad_hint_label):
		modal_pad_hint_label.visible = false
	AudioManager.play_ui_close()
	if _pending_month_summary:
		_pending_month_summary = false
		_begin_month()
		_refresh_all()
		return
	if current_event.is_empty() and not GameState.is_game_over:
		_render_ap_actions()

func _show_demo_ending():
	BGMPlayer.on_ending("stable_success")
	AudioManager.play_ending_stinger("stable_success")
	var f = GameState.flags
	var total_assets = GameState.get_total_asset_value()

	# ── 개인화 요약 문장 ───────────────────────────────────
	var story_lines: Array = []
	# 도덕적 선택
	if f.get("kept_clean_hands", false):
		story_lines.append(_tr("대포통장 제안을 거절했다. 손은 깨끗하다.", "Turned down the burner account offer. Hands are clean."))
	elif f.get("lent_account", false):
		story_lines.append(_tr("선을 한 번 넘었다. 그 200만원은 아직도 기억한다.", "Crossed a line once. Still remember that 2M won."))
	# 직업
	if GameState.current_job.is_empty():
		story_lines.append(_tr("직장은 아직 없다. 그게 지금 가장 큰 과제다.", "Still no job. That's the biggest challenge right now."))
	else:
		story_lines.append(_tr("현재 직업: %s.", "Current work: %s.") % GameState.get_job_display_name())
	# 인물 관계
	# 인물(특히 두 사람)을 상철·재혁보다 앞에 둔다 — 데모 마지막 인상에 '사람이 남았다'는 여운이 오게.
	if f.get("arc_daeun_met", false):
		story_lines.append(_tr("새벽 편의점의 다은 씨. 삼각김밥을 하나 더 쥐여주던 사람. 언제부턴가 그 불빛이, 멀리서도 눈에 들어왔다.", "Daeun, at the late-night store — the one who slipped you an extra rice ball. At some point, that store's light started catching your eye from far off."))
	if f.get("arc_jiyeon_crash_seen", false):
		story_lines.append(_tr("한지연 씨를 우연히 만났다. 다른 세계의 사람인데 — 그날 이후 자꾸 머릿속에 남았다.", "Ran into Jiyeon by chance. A woman from another world — and somehow, she's stayed on your mind ever since."))
	if f.get("arc_sangchul_met_seen", false):
		if f.get("arc_sangchul_casino_seen", false):
			story_lines.append(_tr("임상철 씨의 정선 카지노 제안을 받았다.", "Got Sangchul's invitation to Jeongseon Casino."))
		elif f.get("arc_sangchul_02_seen", false):
			story_lines.append(_tr("임상철 씨와 커피를 마셨다. 그가 보는 세계가 조금 보이기 시작했다.", "Had coffee with Sangchul. His world is starting to come into focus."))
		else:
			story_lines.append(_tr("임상철이라는 사람을 만났다. 뭔가 다른 세계의 사람 같았다.", "Met someone named Sangchul. Felt like a man from another world."))
	if f.get("arc_jaehyuk_reunion_seen", false):
		story_lines.append(_tr("군대 동기 재혁을 만났다. 좋은 건지 나쁜 건지 모르겠다.", "Ran into Jaehyuk from the army. Hard to say if that's good or bad."))
	# 도박
	if f.get("racetrack_guide_met", false):
		story_lines.append(_tr("경마장 아저씨를 따라 과천까지 갔다왔다.", "Followed the racetrack man all the way to Gwacheon."))
	# 자산
	if total_assets >= 10_000_000:
		story_lines.append(_tr("총자산 %s. 작은 숫자지만 민준에게는 처음이다.", "Total assets %s. Small, but a first for Minjun.") % GameState.format_money(total_assets))
	elif total_assets < 0:
		story_lines.append(_tr("통장이 마이너스다. 6개월이 이랬다.", "Account is in the red. That's what six months looked like."))

	_open_modal(_tr("강남드림 — 6개월의 기록", "Gangnam Dream — A 6-Month Record"))
	var date_str = GameState.get_date_string()
	var asset_color = "#34d399" if total_assets >= 1_000_000 else "#c8d0df"
	var record_card := PanelContainer.new()
	record_card.set_meta("moral_role", "info_card")
	record_card.set_meta("moral_accent", "#dce6ee")
	var record_style := StyleBoxFlat.new()
	record_style.bg_color = Color("#0b0d12", 0.985)
	record_style.border_color = Color("#dce6ee", 0.58)
	record_style.set_border_width_all(1)
	record_style.border_width_left = 4
	record_style.set_corner_radius_all(6)
	record_style.content_margin_left = 14
	record_style.content_margin_right = 14
	record_style.content_margin_top = 13
	record_style.content_margin_bottom = 13
	record_card.add_theme_stylebox_override("panel", record_style)
	modal_body.add_child(record_card)

	var record_box := VBoxContainer.new()
	record_box.add_theme_constant_override("separation", 7)
	record_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	record_card.add_child(record_box)

	var record_header := HBoxContainer.new()
	record_header.add_theme_constant_override("separation", 12)
	record_box.add_child(record_header)
	var record_title_box := VBoxContainer.new()
	record_title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	record_title_box.add_theme_constant_override("separation", 2)
	record_header.add_child(record_title_box)
	record_title_box.add_child(_label(_tr("런 기록", "RUN RECORD"), 11, "#697386"))
	var act_lbl := _label(_tr("1막 종료", "Act 1 End"), 19, "#eef3f8")
	if _font_bold:
		act_lbl.add_theme_font_override("font", _font_bold)
	record_title_box.add_child(act_lbl)
	record_title_box.add_child(_wrap_label(
		_tr("%s. 민준은 여전히 33세다. 아직 4년 반이 남아있다.", "%s. Minjun is still 33. Four and a half years left.") % date_str, 13, "#aeb8c8"))
	var stamp := _demo_record_metric(_tr("기간", "Period"), _tr("6개월", "6 months"), _tr("데모 기록", "Demo record"), "#dce6ee")
	stamp.custom_minimum_size = Vector2(150, 0)
	stamp.size_flags_horizontal = Control.SIZE_SHRINK_END
	record_header.add_child(stamp)

	var metrics := HBoxContainer.new()
	metrics.add_theme_constant_override("separation", 8)
	record_box.add_child(metrics)
	metrics.add_child(_demo_record_metric(
		_tr("현재", "Current"),
		GameState.get_job_display_name() if not GameState.current_job.is_empty() else _tr("무직", "Unemployed"),
		_tr("생활 기반", "Life base"),
		"#9aa4b8"))
	metrics.add_child(_demo_record_metric(
		_tr("총자산", "Assets"),
		GameState.format_money(total_assets),
		_tr("6개월 결과", "6-month result"),
		asset_color))
	metrics.add_child(_demo_record_metric(
		_tr("남은 거리", "Distance"),
		GameState.format_money(max(0.0, 3_000_000_000.0 - total_assets)),
		_tr("강남까지", "To Gangnam"),
		"#aeb8c8"))

	record_box.add_child(_demo_record_separator())

	# 개인화 스토리 요약
	record_box.add_child(_label(_tr("지난 6개월", "Past 6 Months"), 14, _moral_hex(_moral_text_accent(Color("#c9a227"), 0.04))))
	var shown_story_count := 0
	for line in story_lines:
		if shown_story_count >= 3:
			break
		record_box.add_child(_wrap_label("• " + line, 13, "#a0aabf"))
		shown_story_count += 1
	if story_lines.size() > shown_story_count:
		record_box.add_child(_wrap_label(_tr("• 나머지는 아직 정리되지 않은 기록으로 남았다.", "• The rest remains an unfinished record."), 12, "#697386"))

	record_box.add_child(_demo_record_separator())
	# 자산 성적표
	var progress_pct = clampf(total_assets / 3_000_000_000.0 * 100.0, 0.0, 100.0)
	record_box.add_child(_make_progress_row(
		_tr("강남드림 (30억)", "Gangnam Dream (KRW 3B)"),
		progress_pct / 100.0,
		asset_color,
		_tr("%.3f%% 달성", "%.3f%% reached") % progress_pct))

	record_box.add_child(_demo_record_separator())
	# 풀버전 티저는 광고 문구가 아니라 기록장 하단의 미완 항목처럼 보이게 둔다.
	var next_card := PanelContainer.new()
	next_card.set_meta("moral_role", "info_card")
	next_card.set_meta("moral_accent", "#dce6ee")
	var next_style := StyleBoxFlat.new()
	next_style.bg_color = Color("#111820", 0.72)
	next_style.border_color = Color("#dce6ee", 0.42)
	next_style.set_border_width_all(1)
	next_style.border_width_left = 3
	next_style.set_corner_radius_all(5)
	next_style.content_margin_left = 10
	next_style.content_margin_right = 10
	next_style.content_margin_top = 7
	next_style.content_margin_bottom = 7
	next_card.add_theme_stylebox_override("panel", next_style)
	record_box.add_child(next_card)
	var next_box := VBoxContainer.new()
	next_box.add_theme_constant_override("separation", 2)
	next_card.add_child(next_box)
	var next_title := _label(_tr("아직 4년 반이 남아있다", "Four and a half years remain"), 14, "#f4f7fb")
	if _font_bold:
		next_title.add_theme_font_override("font", _font_bold)
	next_box.add_child(next_title)
	next_box.add_child(_wrap_label(
		_tr("이 기록은 끝난 게 아니라, 잠시 접힌 것이다.",
			"This record is not over. It is only folded shut for now."),
		12, "#aeb8c8"))
	_apply_moral_tree_styles(record_card, _moral_ui_palette())

	# ── Steam 위시리스트 CTA ───────────────────────────────────
	# App ID가 아직 플레이스홀더면 깨진 /app/STEAM_APP_ID/ URL 대신 상점 검색으로 폴백.
	var steam_url := STEAM_FALLBACK_URL
	if STEAM_APP_ID != "STEAM_APP_ID" and STEAM_APP_ID.is_valid_int():
		steam_url = "https://store.steampowered.com/app/%s/Gangnam_Dream/" % STEAM_APP_ID
	var wishlist_btn = _primary_cta_button(
		_tr("Steam 위시리스트에 추가  ›", "Add to Steam Wishlist  ›"))
	wishlist_btn.pressed.connect(func(): OS.shell_open(steam_url))
	wishlist_btn.call_deferred("grab_focus")
	modal_body.add_child(wishlist_btn)

	var sep4 = HSeparator.new()
	sep4.add_theme_color_override("color", Color("#252535"))
	modal_body.add_child(sep4)
	var end_buttons := HBoxContainer.new()
	end_buttons.add_theme_constant_override("separation", 8)
	modal_body.add_child(end_buttons)
	var restart_btn = _button(_tr("처음부터 다시  ▶", "Start Over  ▶"), "#0e3a2a")
	restart_btn.pressed.connect(_restart_run)
	end_buttons.add_child(restart_btn)
	var menu_btn = _button(_tr("메인 메뉴로", "Main Menu"), "#1a1a28")
	menu_btn.pressed.connect(_go_to_menu)
	end_buttons.add_child(menu_btn)

func _demo_record_separator() -> HSeparator:
	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color("#303545", 0.78))
	return sep

func _demo_record_metric(title: String, value: String, hint: String, accent: String) -> PanelContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.set_meta("moral_role", "info_card")
	card.set_meta("moral_accent", accent)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#11141b", 0.96)
	style.border_color = Color(accent, 0.38)
	style.set_border_width_all(1)
	style.border_width_top = 2
	style.set_corner_radius_all(5)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	card.add_theme_stylebox_override("panel", style)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(box)
	box.add_child(_label(title.to_upper(), 10, "#697386"))
	var value_lbl := _label(value, 15, _moral_hex(_moral_text_accent(Color(accent), 0.05)))
	if _font_bold:
		value_lbl.add_theme_font_override("font", _font_bold)
	box.add_child(value_lbl)
	box.add_child(_label(hint, 11, "#596274"))
	return card

func _show_ending(ending_id):
	BGMPlayer.on_ending(ending_id)  # BGM 엔딩 트랙으로 전환
	AudioManager.play_ending_stinger(ending_id)
	var ending: Dictionary = EndingSystem.get_ending(ending_id)
	var ending_cg_path := _get_ending_cg_path(ending)
	var bg_path := ending_cg_path
	if event_bg:
		var tex = load(bg_path) if bg_path != "" and ResourceLoader.exists(bg_path) else null
		if tex:
			var tw_end := create_tween()
			tw_end.tween_property(event_bg, "modulate:a", 0.0, 0.3)
			tw_end.tween_callback(func():
				event_bg.texture = tex
				var tw2 := create_tween()
				tw2.tween_property(event_bg, "modulate:a", 0.50, 0.5)
			)
		else:
			var tw_clear := create_tween()
			tw_clear.tween_property(event_bg, "modulate:a", 0.0, 0.3)
			tw_clear.tween_callback(func():
				event_bg.texture = null
			)

	_open_modal(_tr("최종 기록", "Finale"))
	_apply_ending_modal_layout()
	_apply_ending_moral_palette()
	var grade = ending.get("grade", "?")
	var grade_colors = {"S+": "#f8fbff", "S": "#e7edf5", "A+": "#dce5ee", "A": "#cbd5df", "B": "#aeb7c2", "C": "#8892a4", "F": "#ff4444", "?": "#aab3c5"}
	var grade_color = grade_colors.get(grade, "#ffffff")
	# 등급 헤더 행
	var ending_row = HBoxContainer.new()
	ending_row.add_theme_constant_override("separation", 14)
	modal_body.add_child(ending_row)
	var ending_text_col = VBoxContainer.new()
	ending_text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ending_row.add_child(ending_text_col)
	ending_text_col.add_child(_label(_fmt(str(ending.get("title", _tr("엔딩", "Ending")))), 24, _moral_hex(_moral_text_accent(Color("#f0b429"), 0.08))))
	ending_text_col.add_child(_label(_tr("등급  %s", "Grade  %s") % grade, 16, grade_color))
	var ending_sep = HSeparator.new()
	ending_sep.add_theme_color_override("color", Color("#252535"))
	modal_body.add_child(ending_sep)
	if ending_cg_path != "" and ResourceLoader.exists(ending_cg_path):
		_add_ending_art_preview(modal_body, ending_cg_path, true)
	else:
		_add_ending_mood_card(modal_body, ending, ending_id)
	# ── 드라마틱 한 줄 요약 ──
	modal_body.add_child(_wrap_label(_quote_ui(_ending_run_summary(ending_id)), 15, _moral_hex(_moral_text_accent(Color("#c8a060"), 0.04))))
	# ── 엔딩 설명 ── (지식 반응형: 같은 결말도 어떻게 거기 닿았는지 알면 다르게 읽힌다)
	var ending_desc := str(ending.get("description", ""))
	var ending_know = ending.get("description_if_known", null)
	if ending_know is Dictionary:
		for fl in ending_know.keys():
			if GameState.flags.get(str(fl), false):
				ending_desc = str(ending_know[fl])
				break
	modal_body.add_child(_wrap_label(_fmt(ending_desc), 13, _moral_hex(_moral_text_accent(Color("#6a7486")))))
	# ── 인연 에필로그 — 같은 결말이라도 곁에 누가 있었는지가 다르다 ──
	_ending_cast_epilogue(modal_body, ending_id)
	# ── 스탯 그리드 ──
	var stats_sep = HSeparator.new()
	stats_sep.add_theme_color_override("color", Color("#252535"))
	modal_body.add_child(stats_sep)
	_ending_stat_grid(modal_body)
	modal_body.add_child(_wrap_label(_ending_percentile_line(), 13, _moral_hex(_moral_text_accent(Color("#c9a227"), 0.04))))
	_ending_route_bar(modal_body)
	_ending_milestones(modal_body)
	_ending_playstyle(modal_body)
	# ── 이번 런 새 해금 표시 ──────────────────────────
	var new_unlocks = MetaProgression.get_new_unlocks()
	var new_ach: Array    = new_unlocks.get("achievements", [])
	if not new_ach.is_empty():
		var unlock_sep = HSeparator.new()
		unlock_sep.add_theme_color_override("color", Color("#252535"))
		modal_body.add_child(unlock_sep)
		modal_body.add_child(_label(_tr("이번 런 해금", "Unlocked This Run"), 15, "#f0b429"))
		var ach_names = {
			"first_billion":     _tr("첫 1억 달성", "First KRW 100M"),
			"stable_life":       _tr("안정적인 삶", "A Stable Life"),
			"gangnam_dream":     _tr("강남드림 달성", "Gangnam Dream Achieved"),
			"survived_burnout":  _tr("번아웃 생존", "Survived Burnout"),
			"startup_exit":      _tr("스타트업 엑싯", "Startup Exit"),
			"political_fix":     _tr("정계 입문", "Into Politics"),
			"investment_master": _tr("투자의 달인", "Investment Master"),
			"reputation_legend": _tr("평판 전설", "Reputation Legend"),
			"five_lives":        _tr("다섯 번의 인생", "Five Lives"),
			"ten_lives":         _tr("열 번의 인생", "Ten Lives"),
			"beat_addiction":    _tr("동그라미 서른 개 (중독 회복)", "Thirty Circles (Addiction Recovery)"),
			"white_gangnam":     _tr("사람으로 강남에 (0.1%의 길)", "Human Until Gangnam (The 0.1% Path)"),
		}
		for a in new_ach:
			var ach_name = ach_names.get(a, a)
			modal_body.add_child(_wrap_label(_tr("업적 달성: %s", "Achievement: %s") % ach_name, 13, "#fbbf24"))

	# 이번 런 새 칭호 해금
	var newly_titles: Array = MetaProgression.check_and_unlock_titles()
	if not newly_titles.is_empty():
		if new_ach.is_empty():
			var title_sep := HSeparator.new()
			title_sep.add_theme_color_override("color", Color("#252535"))
			modal_body.add_child(title_sep)
			modal_body.add_child(_label(_tr("이번 런 해금", "Unlocked This Run"), 15, "#f0b429"))
		var rare_colors := {"common": "#8892a4", "uncommon": "#c9a227", "rare": "#f0b429", "legendary": "#f97316"}
		for t in newly_titles:
			var col: String = rare_colors.get(str(t.get("rare", "common")), "#8892a4")
			modal_body.add_child(_wrap_label(_tr("칭호: 「%s」  %s", "Title: \"%s\"  %s") % [str(t.get("name","")), str(t.get("desc",""))], 12, col))

	# 런 테마 요약
	var theme_id: String = GameState.run_theme
	if theme_id != _tr("자유런", "자유런"):
		modal_body.add_child(_wrap_label(_tr("이번 런 테마: %s", "Run Theme: %s") % _run_theme_display(theme_id), 11, "#5a8a7a"))
	if GameState.difficulty != _tr("현실", "현실"):
		modal_body.add_child(_wrap_label(_tr("난이도: %s %s", "Difficulty: %s %s") % [
			str(GameState.get_difficulty_data().get("icon", "")),
			str(GameState.get_difficulty_data().get("name", ""))], 11, "#8a6a3a"))

	# 마스터리 요약
	var mg_summary: Array = []
	for gid in ["holdem", "racetrack", "scalping", "aruba"]:
		var g: int = MetaProgression.get_mastery(gid)
		if g >= 1:
			mg_summary.append("%s %s" % [gid, MetaProgression.get_mastery_label(gid)])
	if not mg_summary.is_empty():
		modal_body.add_child(_wrap_label(_tr("미니게임 마스터리: ", "Minigame Mastery: ") + ", ".join(mg_summary), 11, "#4a7a6a"))

	_ending_next_run_hints(modal_body)
	_ending_share_section(modal_body, ending_id)

	var restart_btn = _button(_tr("새 런 시작  ▶", "New Run  ▶"), "#0e3a2a")
	restart_btn.pressed.connect(_restart_run)
	modal_body.add_child(restart_btn)
	var menu_btn = _button(_tr("메인 메뉴로", "Main Menu"), "#1a1a28")
	menu_btn.pressed.connect(_go_to_menu)
	modal_body.add_child(menu_btn)

func _add_ending_cg_preview(parent: Control, cg_path: String) -> void:
	_add_ending_art_preview(parent, cg_path, true)

func _apply_ending_modal_layout() -> void:
	if modal_layer:
		modal_layer.color = Color(0, 0, 0, 0.82)
	if modal_panel:
		modal_panel.add_theme_stylebox_override("panel", _modal_style("#090a0d", "#5e6670", 8, 14, 12))
		modal_panel.custom_minimum_size = Vector2(980, 720)
		modal_panel.offset_left = -490
		modal_panel.offset_right = 490
		modal_panel.offset_top = -360
		modal_panel.offset_bottom = 360
	if modal_scroll:
		modal_scroll.custom_minimum_size = Vector2(0, 570)

func _apply_ending_moral_palette() -> void:
	var norm := GameState.moral_tint_norm()
	var stage := GameState.moral_stage()
	if stage <= -2:
		modal_layer.color = Color(0.0, 0.0, 0.0, 0.88)
		modal_panel.add_theme_stylebox_override("panel", _modal_style("#020303", "#59615d", 8, 14, 12))
		modal_title_label.add_theme_color_override("font_color", Color("#9aa39e"))
	elif stage == -1:
		modal_layer.color = Color(0.0, 0.015, 0.02, 0.78)
		modal_panel.add_theme_stylebox_override("panel", _modal_style("#070a0c", "#4b5654", 8, 14, 12))
		modal_title_label.add_theme_color_override("font_color", Color("#aab4b0"))
	elif stage >= 2:
		modal_layer.color = Color(0.010, 0.016, 0.020, 0.60)
		modal_panel.add_theme_stylebox_override("panel", _modal_style("#0f1418", "#d8f4ff", 8, 14, 12))
		modal_title_label.add_theme_color_override("font_color", Color("#f4fbff"))
	elif stage == 1:
		modal_layer.color = Color(0.012, 0.018, 0.022, 0.64)
		modal_panel.add_theme_stylebox_override("panel", _modal_style("#10161a", "#a9d8ea", 8, 14, 12))
		modal_title_label.add_theme_color_override("font_color", Color("#e3f5ff"))
	else:
		var alpha := 0.70 + minf(absf(norm) * 0.08, 0.08)
		modal_layer.color = Color(0, 0, 0, alpha)
		modal_panel.add_theme_stylebox_override("panel", _modal_style("#090a0d", "#5e6670", 8, 14, 12))
		modal_title_label.add_theme_color_override("font_color", Color("#e8eaf0"))

func _add_ending_art_preview(parent: Control, art_path: String, is_cg: bool = false) -> void:
	var frame := PanelContainer.new()
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.02, 0.02, 0.04, 0.96)
	st.border_color = _moral_gray_accent(Color("#c9a227" if is_cg else "#2a3450"), _moral_ui_palette(), 0.04)
	st.set_border_width_all(1)
	st.set_corner_radius_all(8)
	st.content_margin_left = 4
	st.content_margin_right = 4
	st.content_margin_top = 4
	st.content_margin_bottom = 4
	frame.add_theme_stylebox_override("panel", st)
	parent.add_child(frame)

	var img := TextureRect.new()
	img.custom_minimum_size = Vector2(0, 430 if is_cg else 360)
	img.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	img.texture = load(art_path)
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	img.clip_contents = true
	frame.add_child(img)

func _add_ending_mood_card(parent: Control, ending: Dictionary, ending_id: String) -> void:
	var palette := _moral_ui_palette()
	var stage := GameState.moral_stage()
	var black := float(palette.get("black", 0.0))
	var white := float(palette.get("white", 0.0))
	var accent := _moral_gray_accent(Color("#d6dde8"), palette, 0.05)
	if stage <= -1:
		accent = _moral_gray_accent(Color("#9aa39e"), palette, 0.05)
	elif stage >= 1:
		accent = _moral_gray_accent(Color("#f4fbff"), palette, 0.05)

	var frame := PanelContainer.new()
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame.custom_minimum_size = Vector2(0, 328)
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#0b0c10").lerp(Color("#020303"), black * 0.85).lerp(Color("#111820"), white * 0.55)
	st.border_color = accent
	st.set_border_width_all(1)
	st.set_corner_radius_all(8)
	st.content_margin_left = 22
	st.content_margin_right = 22
	st.content_margin_top = 18
	st.content_margin_bottom = 18
	frame.add_theme_stylebox_override("panel", st)
	parent.add_child(frame)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	frame.add_child(box)
	_add_ending_card_scene(box, ending_id, accent, black, white)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	box.add_child(header)

	var title_col := VBoxContainer.new()
	title_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_col.add_theme_constant_override("separation", 5)
	header.add_child(title_col)
	title_col.add_child(_label(_tr("최종 기록", "FINAL RECORD"), 10, _moral_hex(_moral_text_accent(Color("#7f8896"), 0.02))))
	var title_lbl: Label = _label(_fmt(str(ending.get("title", ending_id))), 26, _moral_hex(_moral_text_accent(Color("#eef2f8"), 0.06)))
	title_lbl.clip_text = false
	title_col.add_child(title_lbl)
	title_col.add_child(_wrap_label(_ending_card_signal_line(ending_id, str(ending.get("grade", "?"))), 13, _moral_hex(_moral_text_accent(Color("#aeb7c2"), 0.03))))

	var grade_box := PanelContainer.new()
	grade_box.custom_minimum_size = Vector2(128, 82)
	var grade_st := StyleBoxFlat.new()
	grade_st.bg_color = Color(1, 1, 1, 0.045).lerp(Color(0, 0, 0, 0.16), black)
	grade_st.border_color = accent
	grade_st.set_border_width_all(1)
	grade_st.set_corner_radius_all(6)
	grade_st.content_margin_left = 12
	grade_st.content_margin_right = 12
	grade_st.content_margin_top = 10
	grade_st.content_margin_bottom = 10
	grade_box.add_theme_stylebox_override("panel", grade_st)
	header.add_child(grade_box)
	var grade_col := VBoxContainer.new()
	grade_col.alignment = BoxContainer.ALIGNMENT_CENTER
	grade_box.add_child(grade_col)
	grade_col.add_child(_label(_tr("등급", "GRADE"), 10, "#7f8896"))
	var grade_lbl: Label = _label(str(ending.get("grade", "?")), 28, _moral_hex(accent))
	grade_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	grade_col.add_child(grade_lbl)

	var meta_row := HBoxContainer.new()
	meta_row.add_theme_constant_override("separation", 8)
	box.add_child(meta_row)
	_add_ending_card_chip(meta_row, _tr("마지막 거처", "Last Home"), _ending_last_home_label(), "#cbd5df")
	_add_ending_card_chip(meta_row, _tr("경로", "Path"), _ending_card_route_label(), "#aeb7c2")
	_add_ending_card_chip(meta_row, _tr("최종 자산", "Final Assets"), GameState.format_money(GameState.get_total_asset_value()), "#d9ffe8" if stage <= -1 else "#cbd5df")

	var bars := HBoxContainer.new()
	bars.add_theme_constant_override("separation", 5)
	bars.custom_minimum_size = Vector2(0, 16)
	box.add_child(bars)
	var goal_fill := clampf(GameState.get_total_asset_value() / GameState.GANGNAM_TARGET, 0.02, 1.0)
	_add_ending_card_bar(bars, goal_fill, accent)
	_add_ending_card_bar(bars, clampf(float(GameState.health) / 100.0, 0.0, 1.0), Color("#7d8794"))
	_add_ending_card_bar(bars, clampf(float(GameState.mental) / 100.0, 0.0, 1.0), Color("#9aa3ad"))

func _add_ending_card_scene(parent: Control, ending_id: String, accent: Color, black: float, white: float) -> void:
	var scene := Panel.new()
	scene.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scene.custom_minimum_size = Vector2(0, 104)
	scene.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#090a0d").lerp(Color("#020303"), black * 0.7).lerp(Color("#121a20"), white * 0.35)
	st.border_color = Color(accent.r, accent.g, accent.b, 0.42)
	st.set_border_width_all(1)
	st.set_corner_radius_all(6)
	scene.add_theme_stylebox_override("panel", st)
	parent.add_child(scene)

	var line_col := Color(accent.r, accent.g, accent.b, 0.12)
	_ending_scene_rect(scene, 0.04, 0.18, 0.96, 0.19, line_col)
	_ending_scene_rect(scene, 0.04, 0.76, 0.96, 0.77, Color("#ffffff", 0.045))
	_ending_scene_rect(scene, 0.08, 0.83, 0.92, 0.88, Color("#000000", 0.30))

	match _ending_card_scene_kind(ending_id):
		"debt":
			_ending_scene_rect(scene, 0.10, 0.30, 0.34, 0.68, Color("#d7d0bd", 0.055))
			_ending_scene_rect(scene, 0.13, 0.38, 0.30, 0.39, Color("#d7d0bd", 0.13))
			_ending_scene_rect(scene, 0.13, 0.49, 0.27, 0.50, Color("#d7d0bd", 0.10))
			_ending_scene_rect(scene, 0.40, 0.34, 0.55, 0.70, Color("#16181d", 0.95))
			for x in [0.425, 0.475, 0.525]:
				for y in [0.43, 0.52, 0.61]:
					_ending_scene_rect(scene, x, y, x + 0.025, y + 0.030, Color("#cbd5df", 0.075))
			_ending_scene_rect(scene, 0.65, 0.30, 0.82, 0.68, Color("#111217", 0.98))
			_ending_scene_rect(scene, 0.675, 0.36, 0.795, 0.37, Color("#ff4444", 0.22))
			_ending_scene_rect(scene, 0.675, 0.48, 0.755, 0.49, Color("#ff4444", 0.15))
			_ending_scene_rect(scene, 0.675, 0.60, 0.785, 0.61, Color("#ff4444", 0.11))
		"burnout":
			_ending_scene_rect(scene, 0.16, 0.46, 0.68, 0.58, Color("#d9e4ee", 0.055))
			_ending_scene_rect(scene, 0.16, 0.60, 0.70, 0.64, Color("#d9e4ee", 0.08))
			_ending_scene_rect(scene, 0.76, 0.24, 0.765, 0.70, Color("#d9e4ee", 0.16))
			_ending_scene_rect(scene, 0.765, 0.28, 0.83, 0.285, Color("#d9e4ee", 0.13))
			_ending_scene_rect(scene, 0.82, 0.285, 0.835, 0.40, Color("#d9e4ee", 0.10))
		"gangnam":
			for i in range(8):
				var x := 0.16 + float(i) * 0.075
				var h := 0.22 + float((i * 17) % 5) * 0.045
				_ending_scene_rect(scene, x, 0.72 - h, x + 0.045, 0.72, Color("#cbd5df", 0.055 + white * 0.06))
			_ending_scene_rect(scene, 0.12, 0.28, 0.88, 0.29, Color("#cbd5df", 0.10 + white * 0.06))
			_ending_scene_rect(scene, 0.12, 0.70, 0.88, 0.71, Color("#cbd5df", 0.10))
		"bond":
			_ending_scene_rect(scene, 0.18, 0.58, 0.82, 0.64, Color("#1f1b16", 0.74))
			_ending_scene_rect(scene, 0.33, 0.38, 0.39, 0.57, Color("#cbd5df", 0.08))
			_ending_scene_rect(scene, 0.60, 0.38, 0.66, 0.57, Color("#cbd5df", 0.08))
			_ending_scene_rect(scene, 0.42, 0.45, 0.58, 0.46, Color("#cbd5df", 0.11))
		"career":
			for i in range(5):
				var x := 0.22 + float(i) * 0.105
				_ending_scene_rect(scene, x, 0.24, x + 0.065, 0.72, Color("#cbd5df", 0.045))
				_ending_scene_rect(scene, x + 0.014, 0.34, x + 0.052, 0.35, Color("#cbd5df", 0.11))
				_ending_scene_rect(scene, x + 0.014, 0.48, x + 0.052, 0.49, Color("#cbd5df", 0.08))
		_:
			for i in range(7):
				var x := 0.18 + float(i) * 0.085
				_ending_scene_rect(scene, x, 0.40 + float(i % 3) * 0.055, x + 0.052, 0.72, Color("#cbd5df", 0.045))
			_ending_scene_rect(scene, 0.20, 0.34, 0.80, 0.35, Color("#cbd5df", 0.08))

func _ending_card_scene_kind(ending_id: String) -> String:
	if ending_id in ["bankruptcy", "debt_spiral", "crypto_ghost"]:
		return "debt"
	if ending_id in ["burnout", "mental_break", "career_burnout"]:
		return "burnout"
	if ending_id in ["gangnam_dream", "gangnam_dream_white", "empty_house", "jaehyuk_way", "lonely_rich", "instant_legend", "full_circle"]:
		return "gangnam"
	if ending_id in ["with_daeun", "second_love", "guardian", "late_call", "gambling_recovery", "sangchul_reckoning"]:
		return "bond"
	if ending_id in ["orthodox_pinnacle", "career_climber", "political_fix", "startup_exit", "reputation_king"]:
		return "career"
	return "city"

func _ending_scene_rect(parent: Control, left: float, top: float, right: float, bottom: float, color: Color) -> void:
	var rect := ColorRect.new()
	rect.anchor_left = left
	rect.anchor_top = top
	rect.anchor_right = right
	rect.anchor_bottom = bottom
	rect.offset_right = 1
	rect.offset_bottom = 1
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)

func _add_ending_card_chip(parent: Control, label_text: String, value_text: String, color: String) -> void:
	var chip := PanelContainer.new()
	chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chip.custom_minimum_size = Vector2(0, 54)
	var st := StyleBoxFlat.new()
	st.bg_color = Color(1, 1, 1, 0.035)
	st.border_color = _moral_gray_accent(Color("#30343a"), _moral_ui_palette(), 0.03)
	st.set_border_width_all(1)
	st.set_corner_radius_all(6)
	st.content_margin_left = 12
	st.content_margin_right = 12
	st.content_margin_top = 7
	st.content_margin_bottom = 7
	chip.add_theme_stylebox_override("panel", st)
	parent.add_child(chip)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	chip.add_child(box)
	box.add_child(_label(label_text, 10, "#707987"))
	var value_lbl := _label(value_text, 13, color)
	value_lbl.clip_text = false
	value_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(value_lbl)

func _add_ending_card_bar(parent: Control, ratio: float, color: Color) -> void:
	var holder := Control.new()
	holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	holder.custom_minimum_size = Vector2(0, 12)
	holder.clip_contents = true
	parent.add_child(holder)

	var track := ColorRect.new()
	track.color = Color("#15171b")
	track.set_anchors_preset(Control.PRESET_FULL_RECT)
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(track)

	var fill := ColorRect.new()
	fill.color = _moral_gray_accent(color, _moral_ui_palette(), 0.03)
	fill.anchor_left = 0.0
	fill.anchor_top = 0.0
	fill.anchor_right = clampf(ratio, 0.02, 1.0)
	fill.anchor_bottom = 1.0
	fill.offset_left = 0
	fill.offset_top = 0
	fill.offset_right = 0
	fill.offset_bottom = 0
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(fill)

func _ending_last_home_label() -> String:
	match GameState.housing:
		"gosiwon":
			return _tr("고시원", "Goshiwon")
		"oneroom":
			return _tr("원룸", "One-room")
		"villa":
			return _tr("빌라 전세", "Villa jeonse")
		"apartment":
			return _tr("아파트 전세", "Apartment jeonse")
		"gangnam":
			return _tr("강남 아파트", "Gangnam apartment")
		_:
			return str(GameState.housing)

func _ending_card_route_label() -> String:
	var raw := GameState.get_route_identity()
	raw = raw.replace("📍 ", "").replace("🏆 ", "").replace("📘 ", "").replace("⚖️ ", "").replace("🌊 ", "")
	if raw == _tr("방향 없음", "No Direction"):
		return _tr("아직 고정되지 않은 길", "Unfixed path")
	return raw

func _ending_plain_text(text: String) -> String:
	var cleaned := text
	for token in ["👨‍🦳", "👩", "💜", "☕", "🏢", "📱", "🎓", "📖", "💡", "🔍", "📈", "✨", "💼", "🏠", "🏙️", "🚀", "🎬", "🏛️", "📊", "💰", "🏆", "❤️", "🧠", "⭐", "🎂", "📅"]:
		cleaned = cleaned.replace(token + "  ", "")
		cleaned = cleaned.replace(token + " ", "")
	return cleaned.strip_edges()

func _ending_card_signal_line(ending_id: String, grade: String = "?") -> String:
	match ending_id:
		"jaehyuk_way":
			return _tr("강남은 왔지만, 화면은 닫힌다.", "He reached Gangnam, but the screen closes in.")
		"full_circle", "guardian", "gangnam_dream_white":
			return _tr("돈보다 먼저 지킨 것들이 남았다.", "What he kept matters before what he earned.")
		"with_daeun", "second_love":
			return _tr("목적지가 아니라 함께 있는 장면으로 끝난다.", "It ends not at a destination, but beside someone.")
		"jiyeon_man":
			return _tr("아름다운 승리와 위험한 공허가 같은 거울에 비친다.", "A beautiful victory and a dangerous emptiness share the mirror.")
		"sangchul_reckoning":
			return _tr("마지막 사다리를 치우고, 빚보다 무거운 것을 내려놓았다.", "He removed the last ladder and laid down something heavier than debt.")
		"gambling_recovery":
			return _tr("오늘도 동그라미 하나. 작지만 가장 어려운 승리.", "One more circle today. Small, and the hardest victory.")
	match grade:
		"S+", "S":
			return _tr("강남은 끝이 아니라, 무엇을 남겼는지 묻는 장면이 되었다.", "Gangnam is not the end. It asks what survived the climb.")
		"A+", "A":
			return _tr("성공은 도착했다. 이제 남은 것은 그 성공의 모양이다.", "Success arrived. What remains is the shape it took.")
		"B":
			return _tr("강남드림은 모양을 바꾸었다. 그래도 삶은 여기까지 왔다.", "The Gangnam Dream changed shape. Life still made it this far.")
		"C":
			return _tr("전설은 아니었다. 하지만 이 결말도 한 사람의 생활이다.", "Not a legend. Still, this ending is someone's life.")
		"F":
			return _tr("이번 런은 여기서 멈춘다. 남은 것은 대가의 기록이다.", "This run stops here. What remains is the record of its cost.")
		_:
			return _tr("도시는 이 결말에 아직 이름을 붙이지 못했다.", "The city does not quite know how to name this ending.")

func _get_ending_cg_path(ending: Dictionary) -> String:
	var cg_id := str(ending.get("cg", ""))
	if cg_id == "":
		return ""
	return ImageRegistry.get_cg(cg_id)

func _ending_run_summary(ending_id: String) -> String:
	var route_diff := GameState.route_orthodox - GameState.route_unorthodox
	var f = GameState.flags
	var is_orthodox = route_diff >= 7
	var is_unorthodox = route_diff <= -7
	match ending_id:
		"gangnam_dream_white":
			return _tr("아무도 밟지 않고 30억을 달성했다. 이 도시에서 사람으로 남은 강남입성.", "Reached ₩3B without stepping on anyone. Made it to Gangnam — and stayed human.")
		"gangnam_dream":
			if is_orthodox:
				return _tr("착실하게 살아온 청년이 마침내 강남에 입성했다", "A young man who lived diligently finally made it into Gangnam.")
			elif is_unorthodox:
				return _tr("아무도 믿지 않았던 아웃사이더가 강남의 문을 열었다", "An outsider no one believed in opened the door to Gangnam.")
			elif f.get("startup_exit", false):
				return _tr("작은 아이디어 하나가 강남드림으로 이어졌다", "One small idea led all the way to the Gangnam Dream.")
			else:
				return _tr("5년의 고군분투 끝에 강남드림을 이뤘다", "After five years of struggle, the Gangnam Dream came true.")
		"instant_legend":
			return _tr("고시원 백수가 첫 해에 30억을 만들었다 — 아무도 믿지 않을 것이다", "A jobless goshiwon dweller made KRW 3B in the first year — no one will believe it.")
		"burnout":
			return _tr("강남 야경보다 병실 천장을 먼저 봤다. 서울은 그런 도시다.", "He saw a hospital ceiling before the Gangnam skyline. Seoul is that kind of city.")
		"mental_break":
			return _tr("가장 강해야 할 때 마음이 제일 먼저 떠났다", "When he needed to be strongest, his mind left first.")
		"bankruptcy":
			return _tr("50만원으로 시작해서 -1억으로 끝났다. 레버리지는 양방향이다.", "Started with KRW 500K, ended at -KRW 100M. Leverage cuts both ways.")
		"stable_success":
			if is_orthodox:
				return _tr("강남은 아니었지만 흔들리지 않는 삶을 쌓았다", "Not Gangnam, but he built a life that doesn't waver.")
			else:
				return _tr("파란만장했지만 결국 자기만의 안정을 찾았다", "Turbulent, but in the end he found his own stability.")
		"ordinary_life":
			if f.get("startup_launched", false):
				return _tr("창업의 꿈을 꿨지만 결국 평범한 오늘을 선택했다", "He dreamed of a startup, but in the end chose an ordinary today.")
			return _tr("특별하지 않아도 괜찮다 — 그것도 하나의 삶이다", "It's okay to not be special — that too is a life.")
		"startup_exit":
			return _tr("작은 아이디어 하나가 억대 엑싯으로 이어졌다", "One small idea led to a billion-won exit.")
		"crypto_ghost":
			return _tr("차트가 현실이 되고, 현실이 배경이 됐다. 결국 전부를 가져갔다.", "The chart became reality, and reality became background. In the end it took everything.")
		"debt_spiral":
			return _tr("빚을 막으려고 빚을 냈다. 서울에서 자주 있는 일이다.", "He borrowed to cover debt. A common story in Seoul.")
		"lonely_rich":
			return _tr("돈은 모았지만 곁에 남은 사람이 없었다", "He gathered the money, but no one stayed by his side.")
		"political_fix":
			return _tr("강남이 아닌 더 높은 곳으로 — 정계에 발을 들였다", "Not Gangnam, but somewhere higher — he stepped into politics.")
		"investment_master":
			return _tr("돈이 돈을 버는 법을 깨달았다 — 투자의 달인", "He learned how money makes money — an investment master.")
		"healthy_retirement":
			return _tr("강남보다 건강을 택한 선택, 후회 없는 삶", "He chose health over Gangnam — a life without regret.")
		"reputation_legend":
			return _tr("자산보다 이름이 먼저 강남에 닿았다", "His name reached Gangnam before his assets did.")
		"empty_house":
			return _tr("30억을 쥐었다. 입성한 강남 아파트에 아무도 없었다.", "He held KRW 3B. But the Gangnam apartment he entered was empty.")
		"jaehyuk_way":
			return _tr("최재혁의 방식으로 강남에 입성했다. 거울을 자주 피하게 됐다.", "He entered Gangnam the Choi Jaehyuk way. He started avoiding mirrors.")
		"with_daeun":
			return _tr("30억보다 소중한 것을 알게 됐다. 그게 다은이었다.", "He learned what mattered more than KRW 3B. It was Daeun.")
		"jiyeon_man":
			return _tr("다른 세계의 사람이 나를 선택했다. 강남은 그렇게 왔다.", "Someone from another world chose me. That's how Gangnam came.")
		"orthodox_pinnacle":
			return _tr("가장 정직한 길이 결국 가장 높은 곳으로 이어졌다", "The most honest path led, in the end, to the highest place.")
		"unorthodox_legend":
			return _tr("모두가 실패라 했던 방식으로 서울을 뒤집었다", "He turned Seoul upside down with the method everyone called failure.")
		"early_retirement":
			return _tr("충분히 벌었다. 더 이상 돈을 위해 아침을 팔지 않기로 했다.", "He earned enough. He decided to stop selling his mornings for money.")
		"balanced_life":
			return _tr("정석도 비정석도 아닌 나만의 균형 — 그게 가장 어려운 길이었다", "Neither orthodox nor unorthodox, but my own balance — the hardest path of all.")
		"orthodox_hollow":
			return _tr("성공했다. 그런데 누가 왜 성공했냐고 물으면 대답이 없다.", "He succeeded. But if asked why, he has no answer.")
		"late_call":
			return _tr("화해는 늦었지만, 늦었다는 것을 알았기에 의미가 있었다", "The reconciliation was late, but it meant something because he knew it was late.")
		"sangchul_reckoning":
			return _tr("강남은 포기했다. 대신 아버지를 빚에서 해방시켰다.", "He gave up Gangnam. Instead, he freed his father from debt.")
		"creator_success":
			return _tr("구독자가 100만을 넘은 날, 강남보다 더 넓은 세계가 열렸다", "The day subscribers passed one million, a world wider than Gangnam opened.")
		"full_circle":
			return _tr("임상철에게서 아버지 빚을 되찾았다. 강남과 가족, 둘 다 지켰다.", "He reclaimed his father's debt from Im Sangchul. He kept both Gangnam and family.")
		"second_love":
			return _tr("다은과 함께 강남에 왔다. 이번엔 혼자가 아니었다.", "He came to Gangnam with Daeun. This time he wasn't alone.")
		"guardian":
			return _tr("강남은 아직 없었다. 하지만 아버지가 살아있었다.", "There was no Gangnam yet. But his father was alive.")
		"gambling_recovery":
			return _tr("도박의 바닥에서 올라왔다. 달력에 동그라미 30개. 강남보다 어려운 승리.", "He climbed up from the bottom of gambling. Thirty circles on the calendar. A win harder than Gangnam.")
		"writer":
			return _tr("강남에 닿지 못한 이야기가 가장 많은 사람에게 닿았다.", "A story that never reached Gangnam reached the most people of all.")
		"career_climber":
			return _tr("한자리에 머물지 않았다. 더 나은 사다리로 계속 갈아탔다.", "He never stayed put. He kept switching to a better ladder.")
		"career_burnout":
			return _tr("이직하고, 버텼다. 통장보다 무거운 것들을 들고 5년을 걸었다.", "He switched. He endured. He carried things heavier than his balance for five years.")
		"ng_gambling_premonition":
			return _tr("도박의 문 앞에서 멈췄다. 전생의 기억이 발을 붙잡았다.", "He stopped at the gambling door. A memory from a past life held his feet.")
		_:
			return _tr("그렇게 5년이 지나갔다", "And so five years passed.")

## ── 인연 에필로그 ──────────────────────────────────────────────
## 엔딩 티어는 숫자(자산·스탯)가 정하고, 엔딩의 표정은 관계가 정한다.
## 각 인물의 최종 stage에 따라 결말 직후의 한 장면을 보여준다.
func _ending_cast_epilogue(parent: Control, ending_id: String):
	var good := ending_id in [
		"gangnam_dream", "gangnam_dream_white", "stable_success", "investment_master",
		"startup_exit", "political_fix", "reputation_legend", "healthy_retirement",
		"instant_legend", "orthodox_pinnacle", "unorthodox_legend",
		"creator_success", "with_daeun", "jiyeon_man",
		"early_retirement", "balanced_life", "late_call", "sangchul_reckoning",
		"full_circle", "second_love", "guardian", "gambling_recovery",
		"writer", "career_climber", "career_burnout",
	]
	var bad := ending_id in ["burnout", "mental_break", "bankruptcy", "crypto_ghost", "debt_spiral"]
	var lines: Array = []

	# 아버지 — 화해했는가 (아버지는 항상 존재하는 인물이라 무조건 한 줄)
	var fs := GameState.get_cast_stage("father")
	if fs in ["reconciled", "connected", "hopeful", "close"]:
		if good:
			lines.append(_tr("아버지는 새 집 거실에 어색하게 앉아 「방이 너무 크다」고 하셨다. 그게 칭찬이라는 걸 안다.", "Father sat awkwardly in the new living room and said \"the room is too big.\" I know that's a compliment."))
		elif bad:
			lines.append(_tr("다 잃었다고 말했을 때, 아버지는 「내려와서 밥이나 먹자」고만 하셨다.", "When I said I'd lost everything, Father only said \"come home and eat.\""))
		else:
			lines.append(_tr("아버지와는 이제 한 달에 두 번 통화한다. 길지 않지만, 끊기지 않는다.", "I call Father twice a month now. Not long, but never broken off."))
	elif fs == "passed":
		if GameState.flags.get("chose_money_over_father", false):
			lines.append(_tr("아버지가 떠나던 밤, 나는 딜을 했다. 통장 숫자는 올라갔고 — 그 숫자를 볼 때마다, 창원행 기차를 타지 않은 내가 보인다.", "The night Father passed, I closed a deal. The number in my account went up — and every time I see it, I see the version of me who didn't board the train to Changwon."))
		elif GameState.flags.get("tried_to_go_to_father", false):
			lines.append(_tr("마지막 기차를 탔지만 한 시간 늦었다. 그래도 그 빈 병실에 앉아 있던 시간을, 가지 않은 것보다는 낫다고 믿기로 했다.", "I caught the last train but was an hour too late. Still, I've chosen to believe the time spent in that empty hospital room was better than not going at all."))
		else:
			lines.append(_tr("아버지가 떠난 후 창원에 한 번 내려갔다. 아무것도 없는 방에 한참 앉아 있었다.", "After Father passed, I went down to Changwon once. I sat for a long time in an empty room."))
	elif fs in ["worried", "health_crisis", "quiet"]:
		lines.append(_tr("아버지의 번호를 누르다 만 밤이 많았다. 다음에, 다음에 하다가 5년이 갔다.", "Many nights I dialed Father's number and stopped. Next time, next time — and five years passed."))
	else:
		lines.append(_tr("창원에는 끝내 한 번도 내려가지 못했다.", "I never once made it down to Changwon."))

	# 어머니 — 아버지 곁의 또 한 사람 (화해했을 때만 한 줄)
	if GameState.flags.get("mother_reconciled", false) or GameState.flags.get("mother_reconnected", false):
		if good:
			lines.append(_tr("어머니는 「니 아버지가 봤으면 좋아했을 텐데」라고 하셨다. 이제는 그 말이 아프지 않다.", "Mother said, \"Your father would have loved to see this.\" The words don't sting anymore."))
		else:
			lines.append(_tr("어머니와는 이제 길게 통화한다. 별 내용은 없다. 근데 그게 필요한 통화라는 걸 안다.", "Mother and I have long calls now. Nothing much to them. But I know they're the calls I needed."))

	# 한지연 — 세계가 다른 사람과 어디까지 갔는가
	var js := GameState.get_cast_stage("jiyeon")
	if GameState.flags.get("jiyeon_romance_started", false):
		if bad:
			lines.append(_tr("다 무너진 날에도 한지연은 떠나지 않았다. 「처음부터 돈 보고 만난 거 아니잖아.」", "Even the day everything collapsed, Jiyeon didn't leave. \"I never came for the money in the first place.\""))
		else:
			lines.append(_tr("한지연은 「그러게, 내 눈이 맞았지」라며 웃었다. 그 옆자리가 강남보다 좋다.", "Jiyeon smiled, \"See, my eye was right.\" That seat beside her is better than Gangnam."))
	elif js in ["honest_together", "respected", "trust", "close", "connected", "business_partner", "indebted"]:
		lines.append(_tr("한지연과는 가끔 만나 커피를 마신다. 서로의 세계를 인정한 사이로 남았다.", "I meet Jiyeon for coffee now and then. We remain people who acknowledged each other's worlds."))
	elif js in ["hurt", "disillusioned", "distant", "rejected_help"]:
		lines.append(_tr("한지연의 SNS를 가끔 본다. 연락은 하지 않는다. 그날의 말을 둘 다 기억하니까.", "I check Jiyeon's social media sometimes. I don't reach out. We both remember what was said that day."))
	elif js != "unknown":
		lines.append(_tr("한지연과는 그 이상 가까워지지 못했다. 인연은 거기까지였다.", "Jiyeon and I never grew closer than that. The connection ended there."))

	# 김다은 — 카페의 그 사람
	var ds := GameState.get_cast_stage("daeun")
	if GameState.flags.get("daeun_romance_started", false):
		if good:
			lines.append(_tr("다은은 「강남 가도 커피는 우리 집 와서 마셔」라고 했다. 그러기로 했다.", "Daeun said, \"Even in Gangnam, come drink your coffee at my place.\" I agreed."))
		elif bad:
			lines.append(_tr("통장이 비어도 다은의 카페 구석 자리는 비어 있지 않았다.", "Even when my bank account was empty, the corner seat at Daeun's cafe was not."))
		else:
			lines.append(_tr("다은의 카페는 이제 단골집이 아니라 돌아가는 곳이 됐다.", "Daeun's cafe became not just a regular spot, but a place to return to."))
	elif ds in ["together", "close", "warm", "interest", "acquaintance"]:
		lines.append(_tr("다은의 카페에는 지금도 가끔 간다. 주문하지 않아도 나오는 메뉴가 있다.", "I still drop by Daeun's cafe sometimes. There's a drink that comes without ordering."))
	elif ds in ["distant", "wary", "uncertain"]:
		lines.append(_tr("그 카페 앞을 지날 때면 걸음이 조금 빨라진다.", "When I pass that cafe, my pace quickens a little."))

	# 임상철 — 멘토였는가 / 도구였는가
	var ss := GameState.get_cast_stage("sangchul")
	# 진실을 알고도 그의 죄책감을 끝까지 자산으로 쓴 경우 — 관계 stage가 무엇이든 이 라인이 우선.
	# (stage 기반 따뜻한 라인이 착취 플레이어에게 잘못 뜨던 톤 버그 차단)
	if GameState.flags.get("sangchul_used_fully", false):
		lines.append(_tr("임상철과는 아직도 연락한다. 필요하면 또 쓸 것이다. 그는 그걸 알면서도 전화를 받는다.", "I still keep in touch with Im Sangchul. I'll use him again if I need to. He knows that, and still picks up the phone."))
	elif GameState.flags.get("sangchul_leveraged", false):
		lines.append(_tr("임상철의 죄책감은 좋은 지렛대였다. 그 사실이 가끔, 아주 가끔 마음에 걸린다.", "Im Sangchul's guilt made a good lever. That fact catches in my chest sometimes — just sometimes."))
	elif ss in ["trusted", "mentoring", "guardian"]:
		if good:
			lines.append(_tr("임상철은 「내가 사람 하나는 잘 본다」며 자기 일처럼 웃었다.", "Im Sangchul laughed as if it were his own. \"I sure know how to read people.\""))
		elif bad:
			lines.append(_tr("임상철은 「강남이 뭐라고. 살아 있으면 된 거야」라고 했다. 처음 듣는 부드러운 목소리였다.", "Im Sangchul said, \"Gangnam, who cares. As long as you're alive.\" It was the gentlest I'd ever heard him."))
		else:
			lines.append(_tr("임상철 사장과는 지금도 가끔 국밥을 먹는다. 계산은 번갈아 한다.", "I still grab gukbap with Boss Im Sangchul sometimes. We take turns paying."))
	elif ss == "cut_off":
		lines.append(_tr("임상철은 조사를 받고 업계에서 사라졌다. 그 카페 자리가 가끔 생각난다.", "Im Sangchul was investigated and vanished from the industry. That cafe seat comes to mind sometimes."))
	elif ss == "strained":
		lines.append(_tr("임상철 사장과는 그 일 이후 연락이 끊겼다.", "Boss Im Sangchul and I lost contact after that incident."))
	elif ss != "unknown":
		lines.append(_tr("부동산 앞을 지나면 임상철 사장이 보인다. 목례만 하는 사이로 남았다.", "When I pass the realty office, I see Boss Im Sangchul. We remain people who only nod."))

	# 최재혁 — 그 제안의 끝
	var hs := GameState.get_cast_stage("jaehyuk")
	var hf := GameState.flags
	if hs == "betrayed":
		if hf.get("jaehyuk_stood_up", false):
			lines.append(_tr("최재혁에게 배신당했다. 통장이 비었고, 바닥이었다. 그 뒤 그가 했던 말들을 노트에 받아 적었다 — 배신한 사람에게서 남은 유일한 것이었다. 거기서 다시 시작했다.", "Betrayed by Choi Jaehyuk. Account empty. Rock bottom. Afterward, I wrote down the things he used to say — the only thing left from someone who betrayed me. Started again from there."))
		elif hf.get("jaehyuk_night_was_real", false):
			lines.append(_tr("최재혁의 번호는 없는 번호가 됐다. 그 돈도, 그 사람도. 하지만 그날 밤 찍은 사진은 지우지 않았다. 진짜였다고 믿기로 했다.", "Choi Jaehyuk's number became a dead line. The money, and the man, both gone. But I kept the photo from that night. Chose to believe it was real."))
		else:
			lines.append(_tr("최재혁의 번호는 없는 번호가 됐다. 그 돈도, 그 사람도.", "Choi Jaehyuk's number became a dead line. The money, and the man, both gone."))
	elif hs == "reported":
		lines.append(_tr("최재혁이 결국 구속됐다는 기사를 봤다. 통쾌하지도, 슬프지도 않았다.", "I read that Choi Jaehyuk was finally arrested. I felt neither satisfaction nor sorrow."))
	elif hs in ["partner_in_crime", "blackmailed"]:
		lines.append(_tr("최재혁과의 일은 아무에게도 말하지 않았다. 앞으로도 그럴 것이다.", "I never told anyone about Choi Jaehyuk. I never will."))
	elif hs == "trusted":
		if hf.get("felt_jaehyuk_kindness", false):
			lines.append(_tr("최재혁이 조건 없이 명함을 내밀던 날이 있었다. 그게 진심이었는지는 모른다. 그래도 그날의 그 마음만은 — 진짜였다고 생각한다.", "There was a day Choi Jaehyuk handed me his card, no strings attached. I don't know if it was sincere. But I think that gesture, in that moment, was real."))
		else:
			lines.append(_tr("최재혁과는 그 뒤로 멀어졌다. 그가 아무 조건 없이 도와줬던 날이 가끔 생각난다.", "Choi Jaehyuk and I drifted apart. I still think sometimes about the day he helped without asking anything in return."))
	elif hs == "opening_up":
		lines.append(_tr("최재혁이 자기 이야기를 했던 날이 있었다. 아무한테도 못 했던 말이라고. 그 무게를 기억한다.", "There was a day Choi Jaehyuk told me his story. Said he'd never told anyone. I remember the weight of it."))
	elif hs in ["suspect", "retreating", "guarded"]:
		lines.append(_tr("최재혁과는 적당한 거리를 유지했다. 그게 맞았던 것 같다.", "I kept a careful distance from Choi Jaehyuk. I think that was right."))
	elif hs != "unknown":
		lines.append(_tr("최재혁에게서 가끔 연락이 온다. 받을지 말지는 그때그때 다르다.", "Choi Jaehyuk reaches out now and then. Whether I answer depends on the day."))

	# 강현수 — 고시원 옆방, 자기 길을 간 사람
	var hyunsu_stage := GameState.get_cast_stage("hyunsu")
	if hyunsu_stage in ["passed", "deployed", "friend"] or GameState.flags.get("hyunsu_reconnected", false):
		if GameState.flags.get("called_hyunsu_for_help", false):
			lines.append(_tr("바닥이었을 때 현수에게 전화했다. 그는 그냥 들어줬다. 말 없이 들어주는 사람이 그때 필요했다.", "I called Hyunsu when I'd hit bottom. He just listened. A person who could listen without words — that was what I needed."))
		elif GameState.flags.get("hyunsu_passed", false):
			lines.append(_tr("현수는 공무원이 됐다. 서로 잘 살고 있다. 그 이상도, 이하도 아니다.", "Hyunsu became a civil servant. We're both doing all right. No more, no less."))
		else:
			lines.append(_tr("현수는 회계법인에 자리를 잡았다. 서로 잘 살고 있다. 그 이상도, 이하도 아니다.", "Hyunsu landed a job at an accounting firm. We're both doing all right. No more, no less."))

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color("#252535"))
	parent.add_child(sep)
	parent.add_child(_label(_tr("그 사람들은", "As for Them"), 15, _moral_hex(_moral_text_accent(Color("#c8a060"), 0.04))))
	for l in lines:
		parent.add_child(_wrap_label(_ending_plain_text(str(l)), 12, "#8a93a6"))

## ── 런 요약 카드 텍스트 (클립보드 공유용) ──────────────────────────
func _run_card_text(ending_id: String) -> String:
	var total = GameState.get_total_asset_value()
	var pct = clampi(int(total / 3_000_000_000.0 * 100.0), 0, 999)
	var housing_labels = {
		"gosiwon": _tr("고시원", "goshiwon"), "oneroom": _tr("원룸", "one-room"),
		"villa": _tr("빌라 전세", "villa (jeonse)"), "apartment": _tr("아파트 전세", "apartment (jeonse)")
	}
	var housing_name = housing_labels.get(GameState.housing, GameState.housing)
	var o = GameState.route_orthodox
	var u = GameState.route_unorthodox
	var route_id = GameState.get_route_identity()
	var ending = EndingSystem.get_ending(ending_id)
	var ending_title = str(ending.get("title", ending_id))
	var ending_grade = str(ending.get("grade", "?"))
	var total_events = DataRegistry.events.size()
	var seen = GameState.events_seen
	var lines: PackedStringArray = PackedStringArray()
	lines.append(_tr("[강남드림 런 결과]", "[Gangnam Dream Run Result]"))
	lines.append("━━━━━━━━━━━━━━━━━━")
	lines.append(_tr("플레이어: %s  |  33세 → %d세  |  %d개월", "Player: %s  |  age 33 → %d  |  %d months") % [GameState.player_name, GameState.age, (GameState.age - 33) * 12 + GameState.month])
	lines.append(_tr("최종 자산: %s  (목표 달성률 %d%%)", "Final Assets: %s  (Goal %d%%)") % [GameState.format_money(total), pct])
	lines.append(_tr("마지막 거처: %s", "Last Home: %s") % housing_name)
	lines.append(_tr("경로: 정석 %d회 / 비정석 %d회  →  %s", "Path: Orthodox %d / Unorthodox %d  →  %s") % [o, u, route_id])
	lines.append(_tr("이번 런 이벤트: %d / %d개", "Events This Run: %d / %d") % [seen, total_events])
	if GameState.difficulty != _tr("현실", "현실"):
		lines.append(_tr("난이도: %s", "Difficulty: %s") % str(GameState.get_difficulty_data().get("name", GameState.difficulty)))
	lines.append(_tr("엔딩: \"%s\"  (등급 %s)", "Ending: \"%s\"  (Grade %s)") % [ending_title, ending_grade])
	lines.append("━━━━━━━━━━━━━━━━━━")
	lines.append(_tr("#강남드림 #GangnamDream", "#GangnamDream"))
	return "\n".join(lines)

## ── 공유 버튼 섹션 ─────────────────────────────────────────────
func _ending_share_section(parent: Control, ending_id: String):
	var sep = HSeparator.new()
	sep.add_theme_color_override("color", Color("#252535"))
	parent.add_child(sep)
	var share_btn = _button(_tr("결과 복사하기", "Copy Result"), "#122230")
	share_btn.pressed.connect(func():
		DisplayServer.clipboard_set(_run_card_text(ending_id))
		share_btn.text = _tr("복사됨", "Copied")
		var tw = create_tween()
		tw.tween_interval(1.8)
		tw.tween_callback(func(): share_btn.text = _tr("결과 복사하기", "Copy Result"))
	)
	parent.add_child(share_btn)

## ── 다음 런 힌트 섹션 ──────────────────────────────────────────
func _ending_next_run_hints(parent: Control):
	var f = GameState.flags
	var total = GameState.get_total_asset_value()
	var total_events = DataRegistry.events.size()
	var seen = GameState.events_seen
	var hints: Array = []

	hints.append(_tr("이번 런에서 못 본 이벤트가 %d개 더 있습니다.", "There are %d more events you didn't see this run.") % (total_events - seen))

	var o = GameState.route_orthodox
	var u = GameState.route_unorthodox
	if o > u + 10:
		hints.append(_tr("비정석 루트를 선택했다면 어떤 강남이었을까요?", "What kind of Gangnam would it have been on the unorthodox route?"))
	elif u > o + 10:
		hints.append(_tr("정석 루트로만 살았다면 어떤 결말이 됐을까요?", "What ending would you get living only the orthodox route?"))

	if not f.get("arc_jiyeon_crash_seen", false):
		hints.append(_tr("이번 런에서 한지연을 만나지 못했습니다.", "You didn't meet Jiyeon this run."))
	elif not f.get("arc_jiyeon_truth_seen", false):
		hints.append(_tr("한지연의 진실을 끝까지 보지 못했습니다.", "You didn't see Jiyeon's truth to the end."))

	if not f.get("arc_father_01_seen", false):
		hints.append(_tr("아버지 아크를 아직 시작하지 않았습니다.", "You haven't started Father's arc yet."))

	if not f.get("startup_launched", false) and not f.get("creator_started", false):
		hints.append(_tr("창업·크리에이터 루트, 둘 다 아직 가보지 않으셨네요.", "You haven't tried either the startup or creator route yet."))
	elif not f.get("startup_launched", false):
		hints.append(_tr("창업 루트 — 아이디어 하나로 엑싯까지, 아직 미탐험입니다.", "The startup route — one idea to an exit — still unexplored."))
	elif not f.get("creator_started", false):
		hints.append(_tr("크리에이터 루트 — 구독자 100만의 이야기, 아직 미탐험입니다.", "The creator route — the one-million-subscriber story — still unexplored."))

	if total < 1_000_000_000.0 and GameState.investment_skill < 50:
		hints.append(_tr("투자 기술을 먼저 키웠다면 결과가 달랐을까요?", "Would the result differ if you grew your investing skill first?"))

	# NG+ 힌트 — 1회차에서 특정 경험을 하면 2회차 암시
	var rc = MetaProgression.data.get("runs_completed", 0)
	if rc == 0:
		if f.get("sangchul_truth_known", false) or f.get("father_confession_heard", false):
			hints.append(_tr("다시 시작한다면, 임상철을 처음부터 다르게 대할 수 있을지 모른다...", "If you start over, maybe you can treat Im Sangchul differently from the start..."))
		if f.get("father_passed", false):
			hints.append(_tr("다시 시작한다면, 아버지 전화를 먼저 받을 수 있을지 모른다...", "If you start over, maybe you can answer Father's call first..."))
		if f.get("daeun_let_her_go", false):
			hints.append(_tr("다시 시작한다면, 다은을 처음부터 놓치지 않을 수 있을지 모른다...", "If you start over, maybe you won't lose Daeun from the start..."))

	if hints.is_empty():
		return
	var sep = HSeparator.new()
	sep.add_theme_color_override("color", Color("#252535"))
	parent.add_child(sep)
	parent.add_child(_label(_tr("다음 런에서", "Next Run"), 13, "#c9a227"))
	for i in range(mini(3, hints.size())):
		parent.add_child(_wrap_label(str(hints[i]), 12, "#5a7090"))

## 같은 조건으로 5년을 산 사람들 중 상위 몇 %인지 — 30억 실패를 '정상'으로 리프레이밍
func _ending_percentile_line() -> String:
	var total = GameState.get_total_asset_value()
	var pct: int
	if total >= 3_000_000_000.0:   pct = 1
	elif total >= 1_500_000_000.0: pct = 3
	elif total >= 800_000_000.0:   pct = 6
	elif total >= 400_000_000.0:   pct = 12
	elif total >= 200_000_000.0:   pct = 22
	elif total >= 100_000_000.0:   pct = 35
	elif total >= 50_000_000.0:    pct = 50
	elif total >= 20_000_000.0:    pct = 65
	elif total >= 0.0:             pct = 80
	else:                          pct = 95
	if pct <= 1:
		return _tr("같은 50만원으로 시작한 사람들 중 상위 1% — 강남드림은 원래 이런 확률이었다.", "Top 1% among those who started with the same KRW 500K — the Gangnam Dream was always these odds.")
	return _tr("같은 50만원으로 시작한 사람들 중 상위 %d%% — 강남 입성은 상위 1%%의 일이다.", "Top %d%% among those who started with the same KRW 500K — entering Gangnam is a top-1%% feat.") % pct

func _ending_stat_grid(parent: Control):
	var total = GameState.get_total_asset_value()
	var score = EndingSystem.get_score()
	var reward_col := _moral_hex(_moral_text_accent(Color("#f0b429"), 0.05))
	var good_col := _moral_hex(_moral_text_accent(Color("#34d399"), 0.04))
	var mental_col := _moral_hex(_moral_text_accent(Color("#c9a227"), 0.03))
	var stats = [
		[_tr("최종 자산", "Final Assets"), GameState.format_money(total), reward_col],
		[_tr("점수", "Score"), _tr("%d점", "%d pts") % score, good_col],
		[_tr("건강", "Health"), "%d / 100" % GameState.health,
			"#ef4444" if GameState.health <= 45 else good_col],
		[_tr("정신력", "Mental"), "%d / 100" % GameState.mental,
			"#ef4444" if GameState.mental <= 45 else mental_col],
		[_tr("명성", "Reputation"), "%d" % GameState.reputation, reward_col],
		[_tr("최종 나이", "Final Age"), _tr("%d세", "age %d") % GameState.age, "#aab3c5"],
		[_tr("총 턴", "Total Turns"), _tr("%d턴", "%d turns") % GameState.turn, "#5a6075"],
	]
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 5)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(grid)
	for s in stats:
		var cell = HBoxContainer.new()
		cell.add_theme_constant_override("separation", 6)
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.custom_minimum_size = Vector2(0, 24)
		grid.add_child(cell)
		var key_lbl = _label(str(s[0]), 11, "#5a6075")
		key_lbl.custom_minimum_size = Vector2(84, 0)
		cell.add_child(key_lbl)
		var value_lbl := _label(str(s[1]), 13, str(s[2]))
		value_lbl.clip_text = false
		value_lbl.custom_minimum_size = Vector2(96, 0)
		value_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		value_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		cell.add_child(value_lbl)

func _ending_route_bar(parent: Control):
	var o = GameState.route_orthodox
	var u = GameState.route_unorthodox
	if o + u == 0:
		return
	var route_sep = HSeparator.new()
	route_sep.add_theme_color_override("color", Color("#252535"))
	parent.add_child(route_sep)
	var info_row = HBoxContainer.new()
	info_row.add_theme_constant_override("separation", 8)
	parent.add_child(info_row)
	var id_lbl = _label(_ending_card_route_label(), 13, _moral_hex(_moral_text_accent(Color("#c8a060"), 0.04)))
	id_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_row.add_child(id_lbl)
	info_row.add_child(_label(_tr("정석 %d", "Orthodox %d") % o, 11, _moral_hex(_moral_text_accent(Color("#c9a227"), 0.03))))
	info_row.add_child(_label(" / ", 11, "#3a3a5a"))
	info_row.add_child(_label(_tr("비정석 %d", "Unorthodox %d") % u, 11, _moral_hex(_moral_text_accent(Color("#f97316")))))
	var bar_bg = PanelContainer.new()
	bar_bg.custom_minimum_size = Vector2(0, 10)
	bar_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var bar_row = HBoxContainer.new()
	bar_row.add_theme_constant_override("separation", 0)
	bar_bg.add_child(bar_row)
	parent.add_child(bar_bg)
	var o_ratio = float(o) / float(o + u)
	var o_bar = ColorRect.new()
	o_bar.color = _moral_gray_accent(Color("#3a5a9a"), _moral_ui_palette(), 0.03)
	o_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	o_bar.size_flags_stretch_ratio = o_ratio
	bar_row.add_child(o_bar)
	var u_bar = ColorRect.new()
	u_bar.color = _moral_gray_accent(Color("#8a4a1a"), _moral_ui_palette())
	u_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	u_bar.size_flags_stretch_ratio = 1.0 - o_ratio
	bar_row.add_child(u_bar)

func _ending_milestones(parent: Control):
	var f = GameState.flags
	var milestones: Array = []
	var job_name: String = GameState.get_job_display_name() if not GameState.current_job.is_empty() else ""
	var job_tier: int = int(GameState.current_job.get("tier", 0))
	if not job_name.is_empty():
		if job_tier >= 4:
			milestones.append(_tr("최고 티어 직장 달성: %s", "Top-tier job reached: %s") % job_name)
		elif job_tier >= 3:
			milestones.append(_tr("중견 직장인: %s", "Mid-career professional: %s") % job_name)
		else:
			milestones.append(_tr("직장: %s", "Job: %s") % job_name)
	var housing_labels = {
		"oneroom": _tr("원룸 이사 성공", "Moved into a one-room"),
		"apartment": _tr("아파트 입성", "Entered an apartment"),
		"gangnam": _tr("강남 아파트 입성", "Entered a Gangnam apartment"),
	}
	if housing_labels.has(GameState.housing):
		milestones.append(housing_labels[GameState.housing])
	if f.get("startup_exit", false):
		milestones.append(_tr("스타트업 엑싯 성공", "Startup exit succeeded"))
	elif f.get("startup_launched", false):
		milestones.append(_tr("창업 도전", "Attempted a startup"))
	if f.get("creator_viral", false):
		milestones.append(_tr("크리에이터 수익화 성공", "Creator monetization succeeded"))
	elif f.get("creator_started", false):
		milestones.append(_tr("크리에이터 활동 시작", "Started creator activity"))
	if GameState.investment_skill >= 50:
		milestones.append(_tr("투자 고수 레벨 달성", "Reached expert investor level"))
	elif GameState.investment_skill >= 25:
		milestones.append(_tr("투자 중수 달성", "Reached intermediate investor level"))
	if f.get("political_candidate", false):
		milestones.append(_tr("정계 진출", "Entered politics"))
	if milestones.is_empty():
		return
	var ms_sep = HSeparator.new()
	ms_sep.add_theme_color_override("color", Color("#252535"))
	parent.add_child(ms_sep)
	parent.add_child(_label(_tr("이번 런 발자취", "This Run's Footsteps"), 12, "#5a6075"))
	for m in milestones:
		parent.add_child(_wrap_label("  · %s" % m, 12, "#7a8496"))

func _ending_playstyle(parent: Control):
	# 플레이 스타일 한 줄 진단 (분석요소) — "어떻게 살았는가"의 거울
	var ps_sep = HSeparator.new()
	ps_sep.add_theme_color_override("color", Color("#252535"))
	parent.add_child(ps_sep)
	parent.add_child(_label(_tr("플레이 스타일 진단", "Playstyle Diagnosis"), 12, "#5a6075"))
	parent.add_child(_wrap_label("  %s" % GameState.get_playstyle_label(), 14, _moral_hex(_moral_text_accent(Color("#c8a060"), 0.04))))
	# 엔딩 도감 진행도 — 컴플리션 후크
	var coll: Dictionary = MetaProgression.get_ending_collection_progress()
	var coll_found: int = int(coll.get("found", 0))
	var coll_total: int = int(coll.get("total", 0))
	if coll_total > 0:
		var is_new: bool = (MetaProgression.get_new_unlocks().get("new_ending", "") != "")
		var coll_text: String = _tr("엔딩 도감  %d / %d 발견", "Ending Collection  %d / %d found") % [coll_found, coll_total]
		if is_new:
			coll_text += "   NEW"
		parent.add_child(_wrap_label(coll_text, 13, _moral_hex(_moral_text_accent(Color("#c9a227"), 0.04)) if is_new else "#7a8496"))
	# 정점 대비 결말 — 정점에서 얼마나 지켰는가
	var peak: float = float(GameState.peak_asset)
	var final_total: float = GameState.get_total_asset_value()
	if peak >= 100_000_000.0 and final_total < peak * 0.9:
		var kept_pct: int = int(round(clampf(final_total / peak, 0.0, 1.0) * 100.0))
		parent.add_child(_wrap_label(
			_tr("  최고 자산 %s 중 결말에 %d%% 지킴", "  Peak assets %s — kept %d%% at the end") % [GameState.format_money(peak), kept_pct],
			12, "#7a8496"))

func _show_month_summary(snap: Dictionary):
	_pending_month_summary = true
	_open_modal(_tr("%s 결산", "%s Summary") % snap["date"])
	# 결산: 스크롤바만 숨김 (넘치면 마우스 휠로 접근)
	if modal_scroll:
		modal_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	# 결산은 가운데 모달, 크기를 약간 더 넉넉하게
	if modal_panel:
		modal_panel.custom_minimum_size = Vector2(700, 640)
		modal_panel.offset_left   = -350
		modal_panel.offset_right  =  350
		modal_panel.offset_top    = -320
		modal_panel.offset_bottom =  320

	var income: float = float(snap["monthly_income"])
	var expense: float = float(snap["fixed_expense"])
	var net: float = income - expense
	var net_color  = "#00c896" if net >= 0 else "#ff4444"
	var assets_now: float = GameState.get_total_asset_value()
	var asset_delta: float = assets_now - float(snap["assets_before"])
	var asset_color = "#00c896" if asset_delta >= 0 else "#ff4444"
	var asset_sign  = "+" if asset_delta >= 0 else ""
	var goal: float = 3_000_000_000.0
	var pct: float = clampf(assets_now / goal, 0.0, 1.0)
	var pct_disp: String = "%.1f%%" % (pct * 100.0)

	# ── 이달 판정 / 재정 결과 — 월말 리듬의 첫 인상 ─────────────
	var grade = _calc_month_grade(snap)
	modal_body.add_child(_month_summary_result_card(grade, net, net_color, assets_now, pct_disp))

	var metric_grid := GridContainer.new()
	metric_grid.columns = 4
	metric_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	metric_grid.add_theme_constant_override("h_separation", 8)
	metric_grid.add_theme_constant_override("v_separation", 8)
	modal_body.add_child(metric_grid)
	metric_grid.add_child(_month_summary_metric_card(
		_tr("수입", "Income"),
		GameState.format_money(income),
		_tr("이번 달 들어온 돈", "Money in this month"),
		"#00c896"))
	metric_grid.add_child(_month_summary_metric_card(
		_tr("지출", "Expense"),
		"-%s" % GameState.format_money(expense),
		_tr("고정 생활비", "Fixed living cost"),
		"#ff6b6b"))
	metric_grid.add_child(_month_summary_metric_card(
		_tr("자산 변화", "Asset Change"),
		"%s%s" % [asset_sign, GameState.format_money(asset_delta)],
		_tr("투자 포함", "Including investments"),
		asset_color))
	metric_grid.add_child(_month_summary_metric_card(
		_tr("총자산", "Total Assets"),
		GameState.format_money(assets_now),
		_tr("현재 위치", "Current position"),
		"#8892a4"))
	if bool(snap.get("subsidy", false)):
		modal_body.add_child(_wrap_label(
			_tr("정착 지원금 +30만원이 이번 달 생존을 잠시 밀어줬다.", "The KRW 300K settlement subsidy quietly kept this month afloat."),
			11, "#7f8798"))

	var base_bar := Color("#00c896" if pct >= 0.5 else ("#f0b429" if pct >= 0.2 else "#c9a227"))
	var bar_color = _moral_hex(_moral_gray_accent(base_bar, _moral_ui_palette(), 0.04))
	modal_body.add_child(_make_progress_row(
		_tr("강남드림 (30억)", "Gangnam Dream (KRW 3B)"), pct, bar_color,
		"%s  (%s)" % [GameState.format_money(assets_now), pct_disp]))

	# ── 행동 요약 ─────────────────────────────────
	if not snap["actions"].is_empty():
		modal_body.add_child(_month_summary_action_card(snap["actions"]))

	# ── 스탯 변화 (한 줄) ─────────────────────────
	var stat_parts: Array = []
	var stat_map = [["health", _tr("건강", "Health")], ["mental", _tr("정신력", "Mental")]]
	for pair in stat_map:
		if GameState.get(pair[0]) != int(snap.get(pair[0] + "_before", GameState.get(pair[0]))):
			var d = GameState.get(pair[0]) - int(snap[pair[0] + "_before"])
			stat_parts.append("%s %s%d" % [pair[1], "+" if d > 0 else "", d])
	if not stat_parts.is_empty():
		modal_body.add_child(_wrap_label(_tr("스탯  ", "Stats  ") + "  ".join(stat_parts), 12, "#5a6075"))

	# ── 조언 ──────────────────────────────────────
	var advice = _get_month_advice()
	if not advice.is_empty():
		var div3 = HSeparator.new()
		div3.add_theme_color_override("color", Color("#252535"))
		modal_body.add_child(div3)
		modal_body.add_child(_wrap_label(advice, 12, "#8892a4"))

	# ── A-2: AP 사용 패턴 코멘트 ─────────────────
	var ap_comment = _get_ap_pattern_comment(snap["actions"])
	if not ap_comment.is_empty():
		modal_body.add_child(_wrap_label(_tr("기록 — ", "Note — ") + ap_comment, 12, "#7a8496"))

	# ── A-6: 월말 서사 내레이션 ───────────────────
	var narrative = _get_month_narrative()
	if not narrative.is_empty():
		modal_body.add_child(_wrap_label("— " + narrative, 13, "#a0aabf"))

	# ── A-3: 중독 90 경고 배너 ───────────────────
	if GameState.addiction_tendency >= 90:
		var warn_div = HSeparator.new()
		warn_div.add_theme_color_override("color", Color("#cc0000"))
		modal_body.add_child(warn_div)
		modal_body.add_child(_wrap_label(
			_tr("중독 위험 단계 — 매달 정신력 -2가 추가로 빠지고 있습니다. 도박을 즉시 중단하세요.", "Addiction danger level — you're losing an extra -2 Mental each month. Stop gambling immediately."), 13, "#ff4444"))
		var warn_div2 = HSeparator.new()
		warn_div2.add_theme_color_override("color", Color("#cc0000"))
		modal_body.add_child(warn_div2)

	# ── 목표 힌트 ─────────────────────────────────
	var ms = _next_milestone_hint(assets_now)
	if not ms.is_empty():
		var ms_plain := ms.replace("[color=#7a9ab0]", "").replace("[/color]", "")
		modal_body.add_child(_wrap_label(ms_plain, 11, "#9aa4b8"))

	# ── 확인 버튼 (하단) ──────────────────────────
	var div4 = HSeparator.new()
	div4.add_theme_color_override("color", Color("#252535"))
	modal_body.add_child(div4)
	if GameState.IS_DEMO and GameState.turn > GameState.DEMO_TURN_LIMIT:
		var demo_notice := PanelContainer.new()
		demo_notice.set_meta("moral_role", "info_card")
		demo_notice.set_meta("moral_accent", "#dce6ee")
		var notice_style := StyleBoxFlat.new()
		notice_style.bg_color = Color("#0b0d12", 0.96)
		notice_style.border_color = Color("#dce6ee", 0.72)
		notice_style.border_width_left = 4
		notice_style.set_border_width(SIDE_TOP, 1)
		notice_style.set_border_width(SIDE_RIGHT, 1)
		notice_style.set_border_width(SIDE_BOTTOM, 1)
		notice_style.set_corner_radius_all(7)
		notice_style.content_margin_left = 13
		notice_style.content_margin_right = 13
		notice_style.content_margin_top = 10
		notice_style.content_margin_bottom = 10
		demo_notice.add_theme_stylebox_override("panel", notice_style)
		modal_body.add_child(demo_notice)
		demo_notice.add_child(_wrap_label(
			_tr("데모는 여기까지입니다. 지난 6개월의 기록을 확인하고 풀버전에서 이어질 선택을 살펴보세요.",
				"This is the end of the demo. Review the past six months and see what your choices point toward next."),
			13, "#c8d0df"))
		_apply_moral_tree_styles(demo_notice, _moral_ui_palette())

		var demo_btn = _primary_cta_button(_tr("6개월 기록 보기  ›", "See 6-Month Record  ›"))
		demo_btn.pressed.connect(func():
			_close_modal()
			_show_demo_ending()
		)
		demo_btn.call_deferred("grab_focus")
		modal_body.add_child(demo_btn)
	else:
		var confirm_btn = _button(_tr("다음 달 시작  ▶", "Start Next Month  ▶"), "#0e2a3a")
		confirm_btn.pressed.connect(_close_modal)
		modal_body.add_child(confirm_btn)
		# 월 결산 닫기 후 _begin_month 호출은 _pending_month_summary 플래그로 처리됨

func _month_summary_result_card(grade: Dictionary, net: float, net_color: String, assets_now: float, pct_disp: String) -> Control:
	var grade_color: String = str(grade.get("color", "#8892a4"))
	var grade_badge_text: String = str(grade.get("badge", "LOG"))
	var grade_title_text: String = str(grade.get("title", ""))
	var grade_msg_text: String = str(grade.get("msg", ""))
	var card: PanelContainer = _info_card(grade_color, "#0b0d12")
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	card.add_child(row)

	var badge := PanelContainer.new()
	badge.custom_minimum_size = Vector2(58, 58)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = Color("#050608", 0.96)
	badge_style.border_color = _moral_signal_color(Color(grade_color), 0.22)
	badge_style.set_border_width_all(1)
	badge_style.set_corner_radius_all(7)
	badge_style.content_margin_left = 6
	badge_style.content_margin_right = 6
	badge_style.content_margin_top = 6
	badge_style.content_margin_bottom = 6
	badge.add_theme_stylebox_override("panel", badge_style)
	row.add_child(badge)

	var badge_lbl := Label.new()
	badge_lbl.text = grade_badge_text
	badge_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge_lbl.add_theme_font_size_override("font_size", 14)
	badge_lbl.add_theme_color_override("font_color", _moral_signal_color(Color(grade_color), 0.24))
	if _font_bold:
		badge_lbl.add_theme_font_override("font", _font_bold)
	badge.add_child(badge_lbl)

	var copy_col := VBoxContainer.new()
	copy_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy_col.add_theme_constant_override("separation", 3)
	row.add_child(copy_col)
	var overline := _label(_tr("이번 달 판정", "This Month"), 10, "#5f6878")
	copy_col.add_child(overline)
	var grade_title: Label = _label(grade_title_text, 18, _moral_hex(_moral_text_accent(Color(grade_color), 0.03)))
	if _font_bold:
		grade_title.add_theme_font_override("font", _font_bold)
	copy_col.add_child(grade_title)
	copy_col.add_child(_wrap_label(grade_msg_text, 12, "#8f98aa"))

	var result_col := VBoxContainer.new()
	result_col.custom_minimum_size = Vector2(190, 0)
	result_col.add_theme_constant_override("separation", 3)
	row.add_child(result_col)
	var net_label := _label(_tr("순이익", "Net Profit"), 10, "#5f6878")
	net_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	result_col.add_child(net_label)
	var net_value := _label(GameState.format_money(net), 22, net_color)
	net_value.clip_text = false
	net_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if _font_bold:
		net_value.add_theme_font_override("font", _font_bold)
	result_col.add_child(net_value)
	var asset_hint := _label(_tr("%s / 30억", "%s / KRW 3B") % GameState.format_money(assets_now), 11, "#7f8798")
	asset_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	result_col.add_child(asset_hint)
	var pct_hint := _label(pct_disp, 10, "#5f6878")
	pct_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	result_col.add_child(pct_hint)
	return card

func _month_summary_metric_card(title: String, value: String, hint: String, accent: String) -> Control:
	var card := _info_card(accent, "#090c11")
	card.custom_minimum_size = Vector2(0, 74)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	card.add_child(box)
	box.add_child(_label(title.to_upper(), 10, "#5f6878"))
	var value_lbl := _label(value, 15, _moral_hex(_moral_text_accent(Color(accent), 0.02)))
	value_lbl.clip_text = false
	if _font_bold:
		value_lbl.add_theme_font_override("font", _font_bold)
	box.add_child(value_lbl)
	box.add_child(_wrap_label(hint, 10, "#6f7888"))
	return card

func _month_summary_action_card(actions: Array) -> Control:
	var card := _info_card("#64748b", "#090c11")
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 5)
	card.add_child(box)
	box.add_child(_label(_tr("이번 달 선택", "This Month's Choices"), 11, "#7f8798"))
	var visible_count := mini(actions.size(), 3)
	for i in range(visible_count):
		box.add_child(_wrap_label("· %s" % _month_summary_action_text(actions[i]), 12, "#a0a8b8"))
	if actions.size() > visible_count:
		box.add_child(_label(_tr("외 %d개 기록", "%d more records") % (actions.size() - visible_count), 10, "#5f6878"))
	return card

func _month_summary_action_text(entry: Variant) -> String:
	var text := _clean_month_summary_entry(entry).strip_edges()
	while text.begins_with("•") or text.begins_with("·") or text.begins_with("-"):
		text = text.substr(1).strip_edges()
	return text

func _clean_month_summary_entry(entry: Variant) -> String:
	return _clean_log_surface_text(entry)

## A-1: 관계 연락 후 인물 리액션을 스토리 영역에 표시
func _show_contact_reaction(pname: String, flavor: String, accent: Color):
	for child in choice_box.get_children():
		child.queue_free()
	pending_result_text = flavor
	_transient_bg_active = true
	event_title.text = pname
	event_title.add_theme_color_override("font_color", accent)
	_pulse_node(event_title, 1.04, 0.28)
	_type_text(flavor)
	var confirm_btn2 = _button(_tr("확인", "OK"), "#1f6feb")
	confirm_btn2.pressed.connect(func():
		_finish_typing()
		event_title.remove_theme_color_override("font_color")
		_on_result_confirmed()
	)
	choice_box.add_child(confirm_btn2)
	confirm_btn2.call_deferred("grab_focus")
	next_button.disabled = true


## A-3: 도박 중독 임계값 경고 (50 / 70)
func _check_addiction_warnings():
	var addiction = GameState.addiction_tendency
	if addiction >= 50 and not GameState.flags.get("addiction_warn_50_shown", false):
		GameState.flags["addiction_warn_50_shown"] = true
	if addiction >= 70 and not GameState.flags.get("addiction_warn_70_shown", false):
		GameState.flags["addiction_warn_70_shown"] = true
		_screen_flash(Color("#cc0000"), 0.5, 1.0)
		_show_addiction_warning_popup()
	elif addiction >= 50 and not GameState.flags.get("addiction_warn_50_flash_done", false):
		GameState.flags["addiction_warn_50_flash_done"] = true
		_screen_flash(Color("#cc0000"), 0.35, 0.8)


func _show_addiction_warning_popup():
	_open_modal(_tr("경고", "Warning"))
	modal_body.add_child(_wrap_label(
		_tr("당신은 지금 문제가 생기고 있습니다.\n\n도박 의존도가 위험 수위에 달했습니다. 매달 정신력이 추가로 감소하고, 상태가 악화되면 되돌리기 어렵습니다.\n\n지금 멈출 수 있습니다.", "Something is going wrong right now.\n\nYour gambling dependence has reached a dangerous level. Your Mental drops further each month, and once it worsens it's hard to reverse.\n\nYou can stop now."), 14, "#ff6b6b"))
	var ok_btn = _button(_tr("확인했습니다", "I Understand"), "#7a1a1a")
	ok_btn.pressed.connect(_close_modal)
	modal_body.add_child(ok_btn)


## A-6: 현재 상태 기반 월말 서사 1줄
func _get_month_narrative() -> String:
	var mental = GameState.mental
	var money = GameState.money
	var job = GameState.current_job
	var f = GameState.flags
	var addiction = GameState.addiction_tendency
	var tenure = int(GameState.job_tenure)
	var umonths = int(f.get("unemployed_months", 0))
	var assets = GameState.get_total_asset_value()
	var t = GameState.turn

	# 위기 상황 (최우선)
	if mental <= 20:
		return _tr("정신이 한계에 왔다. 오늘 하루도 버텼다는 것만이 남는다.", "My mind hit its limit. All that's left is having survived one more day.")
	if mental <= 25:
		return _tr("이 달은 버티는 것만으로도 충분했다.", "This month, just holding on was enough.")
	if money < 0:
		return _tr("통장이 마이너스다. 숫자를 볼 때마다 숨이 막혔다.", "My bank account is negative. Every time I see the number, I can't breathe.")

	# 도박 중독
	if addiction >= 70:
		return _tr("카지노 생각이 멈추지 않는다. 이게 맞는 길인지 모르겠다.", "Thoughts of the casino won't stop. I don't know if this is the right path.")
	if addiction >= 50:
		return _tr("다음 판이 자꾸 눈에 밟힌다. 스스로 이상하다는 걸 안다.", "The next hand keeps haunting me. I know there's something wrong with me.")

	# 무직 상황
	if job.is_empty() and umonths == 1:
		return _tr("첫 달이 지났다. 아직 괜찮다고 스스로를 다독였다.", "The first month passed. I told myself I was still okay.")
	if job.is_empty() and umonths == 2:
		return _tr("두 달째다. 채용 공고를 보는 눈이 조금 달라졌다.", "Second month. The way I read job postings has shifted a little.")
	if job.is_empty() and umonths >= 6:
		return _tr("%d개월째 무직이다. 통장 잔고가 조용히 줄고 있다.", "%d months unemployed. My balance is quietly shrinking.") % umonths
	if job.is_empty() and umonths >= 3:
		return _tr("또 한 달이 지났다. 이력서 쓴 게 언제였는지 기억이 흐릿하다.", "Another month passed. I can barely remember when I last wrote a resume.")
	if job.is_empty() and f.get("resume_polished", false):
		return _tr("이력서는 완성했다. 이제 누군가가 읽어줄 차례다.", "The resume is done. Now it's someone's turn to read it.")

	# 취업/직장 상황
	if not job.is_empty() and tenure == 1:
		return _tr("첫 출근. 익숙하지 않은 것들로 가득 찬 하루하루였다.", "First day at work. Each day was full of unfamiliar things.")
	if not job.is_empty() and tenure == 2:
		return _tr("한 달 더 버텼다. 동료들 이름을 이제 외웠다.", "Held on another month. I've memorized my coworkers' names now.")
	if not job.is_empty() and tenure == 3:
		return _tr("석 달. 이 일이 어떤 건지 이제 조금 알 것 같다.", "Three months. I'm starting to understand what this job is.")
	if not job.is_empty() and tenure == 6:
		return _tr("반 년이 지났다. 후배가 생기면 어떤 선배가 될까 생각했다.", "Half a year passed. I wondered what kind of senior I'd be when a junior arrives.")
	if not job.is_empty() and tenure == 12:
		return _tr("1년이 지났다. 이 일이 조금씩 내 것이 되는 것 같다.", "A year passed. This work is slowly becoming my own.")
	# 첫 월급
	if f.get("has_received_paycheck", false) and not f.get("paycheck_narrative_done", false):
		GameState.flags["paycheck_narrative_done"] = true
		return _tr("처음으로 내가 번 돈이 통장에 찍혔다. 금액이 작아서 웃음도 작았다.", "For the first time, money I earned showed up in my account. The amount was small, so was my smile.")

	# 자산 이정표
	if assets >= 1_000_000_000.0:
		return _tr("10억. 그 숫자가 이제 현실로 느껴진다.", "KRW 1B. That number feels real now.")
	if assets >= 500_000_000.0:
		return _tr("5억. 강남이 조금씩 가까워지는 것 같다.", "KRW 500M. Gangnam feels a little closer.")
	if assets >= 100_000_000.0 and not f.get("narrative_100m_noted", false):
		GameState.flags["narrative_100m_noted"] = true
		return _tr("1억을 넘었다. 처음 시작했을 때 상상도 못 했던 숫자다.", "Crossed KRW 100M. A number I couldn't have imagined when I started.")
	if assets >= 10_000_000.0 and not f.get("narrative_10m_noted", false):
		GameState.flags["narrative_10m_noted"] = true
		return _tr("총자산 1천만원. 50만원에서 시작한 게 맞나 싶다.", "Total assets KRW 10M. Hard to believe I started with KRW 500K.")

	# 인물 관계 메아리
	if f.get("arc_sangchul_02_seen", false) and not f.get("narrative_sangchul_noted", false) and t <= 20:
		GameState.flags["narrative_sangchul_noted"] = true
		return _tr("임상철 씨가 한 말이 자꾸 생각난다. 그 사람은 뭘 보고 사는 걸까.", "What Im Sangchul said keeps coming back. What does that man live for?")
	if f.get("arc_jiyeon_crash_seen", false) and not f.get("narrative_jiyeon_noted", false):
		GameState.flags["narrative_jiyeon_noted"] = true
		return _tr("그날 카페 앞에서 마주쳤던 사람. 이름도 모르는데 자꾸 생각난다.", "The person I ran into outside the cafe that day. I don't even know her name, yet I keep thinking of her.")
	if f.get("arc_daeun_met", false) and not f.get("narrative_daeun_noted", false) and t >= 12:
		GameState.flags["narrative_daeun_noted"] = true
		return _tr("편의점을 지나칠 때마다 괜히 안을 들여다본다.", "Every time I pass the convenience store, I glance inside for no reason.")

	# 아버지
	if f.get("father_reconciled", false) and not f.get("father_narrative_noted", false):
		GameState.flags["father_narrative_noted"] = true
		return _tr("아버지와 화해한 뒤로, 전화가 더 자주 걸고 싶어진다.", "Since making up with Father, I want to call more often.")
	if f.get("arc_father_01_seen", false) and not f.get("narrative_father_noted", false):
		GameState.flags["narrative_father_noted"] = true
		return _tr("아버지한테 전화가 왔었다. 몸이 안 좋다고 했다. 그 생각이 계속 난다.", "Father called. He said he wasn't feeling well. The thought keeps coming back.")

	# 정신력 경고
	if mental <= 40:
		return _tr("피로가 쌓이고 있다. 이런 달이 쌓이면 어디로 가는 걸까.", "Fatigue is piling up. If months like this keep stacking, where does it lead?")

	# 도박 유혹 (초반)
	if f.get("gambling_tempted", false) and not f.get("narrative_gambling_noted", false) and addiction < 30:
		GameState.flags["narrative_gambling_noted"] = true
		return _tr("한 방에 뒤집을 수 있다는 생각이 머릿속에서 지워지지 않는다.", "The thought that one big hit could turn it all around won't leave my head.")

	return ""


## A-2: 이번 달 AP 사용 패턴 코멘트
func _get_ap_pattern_comment(actions: Array) -> String:
	if actions.is_empty():
		return ""
	var gambling := 0
	var selfdev := 0
	var social := 0
	var saving := 0
	var work := 0
	var resume_token := _tr("자소서", "Resume")
	var mock_interview_token := _tr("모의 면접", "Mock Interview")
	var job_hunt_token := _tr("구직활동", "Job Hunt")
	for entry in actions:
		var e: String = str(entry)
		if "🎰" in e or "🏇" in e or "🃏" in e:
			gambling += 1
		elif "📚" in e or "📖" in e or "🏃" in e or "🧘" in e or "📊" in e or "🎯" in e or "🖊" in e or "🌊" in e \
				or "Resume" in e or resume_token in e or "Mock Interview" in e or mock_interview_token in e:
			selfdev += 1
		elif "🤝" in e:
			social += 1
		elif "💰" in e:
			saving += 1
		elif "💼" in e or "Job Hunt" in e or job_hunt_token in e:
			work += 1
	var total = actions.size()
	if gambling >= total and total >= 2:
		return _tr("이번 달은 도박장에서 살았다. 스탯은 그대로다.", "This month I lived at the gambling table. Stats unchanged.")
	if gambling > 0 and gambling == total:
		return _tr("이번 달은 도박장에서 살았다.", "This month I lived at the gambling table.")
	if selfdev >= total and total >= 2:
		return _tr("꾸준한 한 달이었다. 조금씩 달라지고 있다.", "A steady month. Things are changing little by little.")
	if selfdev > 0 and selfdev == total:
		return _tr("자기계발에 집중한 달이었다.", "A month focused on self-development.")
	if social > 0 and selfdev > 0 and gambling == 0:
		return _tr("사람과 성장 사이에서 균형을 잡았다.", "Found a balance between people and growth.")
	if gambling > 0 and selfdev > 0:
		return _tr("도박과 자기계발 사이를 오갔다. 방향을 정해야 할 것 같다.", "Drifted between gambling and self-development. I should pick a direction.")
	if saving > 0 and gambling == 0:
		return _tr("소비를 줄이며 버텼다.", "Held on by cutting back on spending.")
	return ""


func _check_milestones():
	var total = GameState.get_total_asset_value()
	var milestones = [
		{"id": "10m",  "amount": 10_000_000.0,    "msg": _tr("💰 자산 1천만원 돌파!", "💰 Assets passed KRW 10M!"),            "color": "#fbbf24"},
		{"id": "50m",  "amount": 50_000_000.0,    "msg": _tr("💰 자산 5천만원 돌파!", "💰 Assets passed KRW 50M!"),            "color": "#fbbf24"},
		{"id": "100m", "amount": 100_000_000.0,   "msg": _tr("🏆 자산 1억 돌파! 진짜 시작이다.", "🏆 Assets passed KRW 100M! The real start."), "color": "#f0b429"},
		{"id": "500m", "amount": 500_000_000.0,   "msg": _tr("🔥 자산 5억! 강남이 보인다.", "🔥 Assets KRW 500M! Gangnam in sight."),      "color": "#f0b429"},
		{"id": "1b",   "amount": 1_000_000_000.0, "msg": _tr("⚡ 자산 10억! 절반 왔다.", "⚡ Assets KRW 1B! Halfway there."),         "color": "#00c896"},
		{"id": "2b",   "amount": 2_000_000_000.0, "msg": _tr("💎 자산 20억! 강남드림이 보인다.", "💎 Assets KRW 2B! The Gangnam Dream is in sight."), "color": "#00c896"},
	]
	for m in milestones:
		if total >= m["amount"] and not GameState.milestones_reached.has(m["id"]):
			GameState.milestones_reached[m["id"]] = true
			GameState.add_log(m["msg"], "system")
			_show_toast(m["msg"], Color(m["color"]))
			AudioManager.play("money_big")
			# 기쁜 표정 2초간 표시
			GameState.flags["just_hit_milestone"] = true
			_update_portrait()
			await get_tree().create_timer(2.0).timeout
			GameState.flags["just_hit_milestone"] = false
			_update_portrait()

func _on_promoted(job: Dictionary, bonus: float):
	var msg = _tr("⬆ 승진! %s  월급 +%s", "⬆ Promoted! %s  Salary +%s") % [GameState.get_job_display_name(job), GameState.format_money(bonus)]
	_show_toast(msg, Color("#fbbf24"))
	AudioManager.play("housing_up")

func _summary_row(label_text: String, value_text: String, value_color: String) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var lbl = _label(label_text, 13, "#5a6075")
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl)
	var val = _label(value_text, 13, value_color)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(val)
	return row

func _price_sparkline(history: Array) -> String:
	if history.size() < 2:
		return "——"
	var min_p = history.min()
	var max_p = history.max()
	var range_p = max_p - min_p
	if range_p < 0.001:
		return "━━━━━━"
	var blocks = ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"]
	var result = ""
	for p in history:
		var idx = int((float(p) - min_p) / range_p * 7.0)
		idx = clamp(idx, 0, 7)
		result += blocks[idx]
	return result

func _restart_run():
	_close_modal()
	GameState.new_game()
	investment_system.initialize()
	_begin_month()
	_refresh_all()

func _tab_box(tabs, title):
	var scroll = ScrollContainer.new()
	scroll.name = title
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tabs.add_child(scroll)
	var box = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 6)
	scroll.add_child(box)
	return box

func _clear_box(box):
	for child in box.get_children():
		child.queue_free()

func _panel(bg, border):
	var panel = PanelContainer.new()
	panel.set_meta("moral_role", "panel")
	panel.set_meta("moral_accent", border)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(bg)
	style.border_color = Color(border)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", style)
	_apply_moral_tree_styles(panel, _moral_ui_palette())
	return panel

func _info_signal_hex(color: String, boost: float = 0.02) -> String:
	return _moral_hex(_moral_gray_accent(Color(color), _moral_ui_palette(), boost))

func _info_text_hex(color: String, boost: float = 0.01) -> String:
	return _moral_hex(_moral_text_accent(Color(color), boost))

func _info_card(accent: String, bg: String = "#0b1018") -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(bg)
	style.border_color = Color(_info_signal_hex(accent))
	style.set_border_width_all(1)
	style.border_width_left = 4
	style.set_corner_radius_all(7)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 11
	style.content_margin_bottom = 11
	panel.add_theme_stylebox_override("panel", style)
	return panel

func _info_section_title(text: String, color: String) -> Label:
	var lbl: Label = _label(text, 15, _info_text_hex(color, 0.02))
	if _font_bold:
		lbl.add_theme_font_override("font", _font_bold)
	return lbl

func _info_empty_card(text: String, accent: String = "#64748b") -> Control:
	var card: PanelContainer = _info_card(accent, "#0b0f16")
	card.add_child(_wrap_label(text, 14, "#8f9ab0"))
	return card

func _mini_progress_meter(value: int, max_value: int, accent: String = "#8f98a8") -> Control:
	var ratio := clampf(float(value) / float(maxi(max_value, 1)), 0.0, 1.0)
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = Vector2(0, 18)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#0d0e14")
	style.border_color = Color("#242734")
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	panel.add_theme_stylebox_override("panel", style)
	var track := Control.new()
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	track.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(track)
	var fill := ColorRect.new()
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fill.color = Color(_info_signal_hex(accent, 0.03))
	fill.set_anchors_preset(Control.PRESET_FULL_RECT)
	fill.anchor_right = ratio
	fill.offset_left = 2
	fill.offset_top = 2
	fill.offset_right = -2
	fill.offset_bottom = -2
	track.add_child(fill)
	return panel

func _info_value_bar(label_text: String, value: int, max_value: int, color: String) -> Control:
	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 4)
	var top: HBoxContainer = HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	box.add_child(top)
	var lbl: Label = _label(label_text, 13, "#8f9ab0")
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(lbl)
	var muted_color := _info_signal_hex(color, 0.03)
	var val: Label = _label("%d/%d" % [value, max_value], 13, muted_color)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top.add_child(val)
	var bar_lbl: Label = _label(_bar_str(value, max_value, 12), 13, muted_color)
	bar_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(bar_lbl)
	return box

func _relationship_type_label(type_str: String) -> String:
	return {
		"romantic": _tr("연인", "Partner"),
		"mentor": _tr("멘토", "Mentor"),
		"business": _tr("비즈니스", "Business"),
		"family": _tr("가족", "Family"),
		"friends": _tr("친구", "Friend"),
	}.get(type_str, _tr("인연", "Bond"))

func _relationship_type_color(type_str: String) -> String:
	return {
		"romantic": "#e8a0c0",
		"mentor": "#5b9cf6",
		"business": "#34d399",
		"family": "#f0b429",
		"friends": "#a78bfa",
	}.get(type_str, "#94a3b8")

func _readable_font_size(size: int) -> int:
	if size <= 6:
		return size
	if size <= 10:
		return 12
	if size <= 12:
		return UI_MIN_BODY_FONT
	return size

func _label(text, size, color) -> Label:
	var label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.clip_text = true
	label.add_theme_font_size_override("font_size", _readable_font_size(int(size)))
	label.add_theme_color_override("font_color", Color(color))
	if _font_regular:
		label.add_theme_font_override("font", _font_regular)
	return label

func _wrap_label(text, size, color) -> Label:
	var label = _label(text, size, color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = false
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

func _button(text, color) -> Button:
	var button = Button.new()
	button.set_meta("moral_role", "button")
	button.set_meta("moral_accent", color)
	button.text = text
	button.custom_minimum_size = Vector2(0, UI_MIN_BUTTON_HEIGHT)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(color)
	normal.set_corner_radius_all(3)
	normal.content_margin_left = 16
	normal.content_margin_right = 16
	normal.content_margin_top = 10
	normal.content_margin_bottom = 10
	var hover = normal.duplicate()
	hover.bg_color = Color(color).lightened(0.14)
	var pressed_style = normal.duplicate()
	pressed_style.bg_color = Color(color).darkened(0.1)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_color_override("font_color", Color("#ffffff"))
	if _font_bold:
		button.add_theme_font_override("font", _font_bold)
	button.add_theme_font_size_override("font_size", UI_MIN_BUTTON_FONT)
	var focus_st = normal.duplicate()
	focus_st.border_color = Color("#f0b429")
	focus_st.set_border_width_all(UI_FOCUS_BORDER)
	button.add_theme_stylebox_override("focus", focus_st)
	button.pressed.connect(func(): AudioManager.play_ui_click())
	_apply_moral_tree_styles(button, _moral_ui_palette())
	_bind_tactile_button(button, 0.75)
	return button

func _primary_cta_button(text: String) -> Button:
	var button := _button(text, "#121820")
	button.set_meta("moral_role", "primary_cta_button")
	button.set_meta("moral_accent", "#dce6ee")
	button.custom_minimum_size = Vector2(0, 58)
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", Color("#eef3f8"))
	button.add_theme_color_override("font_hover_color", Color("#ffffff"))
	button.add_theme_color_override("font_pressed_color", Color("#dce6ee"))
	button.add_theme_color_override("font_focus_color", Color("#ffffff"))
	button.add_theme_color_override("font_hover_pressed_color", Color("#ffffff"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#111820", 0.98)
	normal.border_color = Color("#cbd5df", 0.72)
	normal.set_border_width_all(1)
	normal.border_width_left = 4
	normal.set_corner_radius_all(4)
	normal.content_margin_left = 18
	normal.content_margin_right = 18
	normal.content_margin_top = 12
	normal.content_margin_bottom = 12
	var hover := normal.duplicate()
	hover.bg_color = Color("#172331", 0.98)
	hover.border_color = Color("#eef3f8", 0.9)
	var pressed_style := normal.duplicate()
	pressed_style.bg_color = Color("#0b1018", 0.98)
	var focus_style := normal.duplicate()
	focus_style.border_color = Color("#ffffff")
	focus_style.set_border_width_all(UI_FOCUS_BORDER)
	focus_style.border_width_left = 5
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("focus", focus_style)
	return button

func _icon_button(text: String, icon_id: String, color: String) -> Button:
	var button: Button = _button(text, color)
	button.icon = _ui_icon_texture(icon_id)
	button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.expand_icon = false
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_constant_override("h_separation", 10)
	return button

func _action_button(text: String, accent_color: String) -> Button:
	var button = Button.new()
	button.set_meta("moral_role", "action_button")
	button.set_meta("moral_accent", accent_color)
	button.text = text
	button.custom_minimum_size = Vector2(0, UI_MIN_BUTTON_HEIGHT)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color("#111118")
	normal.border_color = Color(accent_color)
	normal.border_width_left = 4
	normal.set_corner_radius_all(3)
	normal.content_margin_left = 16
	normal.content_margin_right = 14
	normal.content_margin_top = 9
	normal.content_margin_bottom = 9
	var hover = normal.duplicate()
	hover.bg_color = Color("#1c1c2a")
	var pressed_style = normal.duplicate()
	pressed_style.bg_color = Color("#0d0d16")
	var focus_action = hover.duplicate()
	focus_action.border_color = Color("#f0b429")
	focus_action.border_width_left = 5
	focus_action.border_width_top = UI_FOCUS_BORDER
	focus_action.border_width_right = UI_FOCUS_BORDER
	focus_action.border_width_bottom = UI_FOCUS_BORDER
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("focus", focus_action)
	button.add_theme_color_override("font_color", Color("#c8d0e0"))
	button.add_theme_font_size_override("font_size", UI_MIN_BUTTON_FONT)
	if _font_regular:
		button.add_theme_font_override("font", _font_regular)
	button.pressed.connect(func(): AudioManager.play_ui_click())
	_apply_moral_tree_styles(button, _moral_ui_palette())
	_bind_tactile_button(button, 1.0)
	return button

func _small_button(text, color) -> Button:
	var button = Button.new()
	button.set_meta("moral_role", "small_button")
	button.set_meta("moral_accent", color)
	button.text = text
	button.custom_minimum_size = Vector2(0, UI_MIN_SMALL_BUTTON_HEIGHT)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(color)
	normal.set_corner_radius_all(3)
	normal.content_margin_left = 10
	normal.content_margin_right = 10
	normal.content_margin_top = 7
	normal.content_margin_bottom = 7
	var hover = normal.duplicate()
	hover.bg_color = Color(color).lightened(0.15)
	var focus_sm = normal.duplicate()
	focus_sm.border_color = Color("#f0b429")
	focus_sm.set_border_width_all(UI_FOCUS_BORDER)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", focus_sm)
	button.add_theme_color_override("font_color", Color("#ffffff"))
	button.add_theme_font_size_override("font_size", UI_MIN_BUTTON_FONT)
	if _font_regular:
		button.add_theme_font_override("font", _font_regular)
	button.pressed.connect(func(): AudioManager.play_ui_click(-7.0))
	_apply_moral_tree_styles(button, _moral_ui_palette())
	_bind_tactile_button(button, 0.65)
	return button

func _icon_small_button(text: String, icon_id: String, color: String) -> Button:
	var button: Button = _small_button(text, color)
	button.icon = _ui_icon_texture(icon_id)
	button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.expand_icon = false
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_constant_override("h_separation", 8)
	return button

func _modal_section_header(title: String, icon_id: String, accent: String, subtitle: String = "") -> Control:
	var accent_col := _moral_gray_accent(Color(accent), _moral_ui_palette(), 0.04)
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style := StyleBoxFlat.new()
	style.bg_color = Color(accent_col.r, accent_col.g, accent_col.b, 0.10)
	style.border_color = Color(accent_col.r, accent_col.g, accent_col.b, 0.45)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(32, 32)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = _ui_icon_texture(icon_id)
	icon.modulate = accent_col
	row.add_child(icon)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 2)
	row.add_child(col)

	var title_lbl := _label(title, 17, "#e8eaf0")
	if _font_bold:
		title_lbl.add_theme_font_override("font", _font_bold)
	col.add_child(title_lbl)
	if not subtitle.is_empty():
		col.add_child(_wrap_label(subtitle, 14, "#8f9ab0"))
	return panel

func _stat_name(key):
	return {
		"housing": _tr("주거", "Housing"),
		"job": _tr("직업", "Job"),
		"health": _tr("건강", "Health"),
		"mental": _tr("정신", "Mental"),
		"intelligence": _tr("지능", "Intelligence"),
		"social_skill": _tr("사회성", "Social"),
		"appearance": _tr("외모", "Appearance"),
		"investment_skill": _tr("투자감각", "Investing"),
		"luck": _tr("운", "Luck"),
		"reputation": _tr("평판", "Reputation"),
		"addiction_tendency": _tr("중독도", "Addiction"),
		"gambling_tendency": _tr("도박충동", "Gambling Urge"),
		"work_performance": _tr("업무성과", "Performance"),
		"monthly_income": _tr("월수입", "Monthly Income"),
		"asset": _tr("총자산", "Total Assets"),
	}.get(key, key)

func _rel_effect_hint(type_str: String, affection: int, trust: int) -> String:
	match type_str:
		"romantic":
			if affection >= 80: return _tr("매달 정신력 +6, 생활비 분담 기회", "+6 Mental/month, chance to split living costs")
			elif affection >= 60: return _tr("매달 정신력 +3", "+3 Mental/month")
			else: return _tr("매달 정신력 +1", "+1 Mental/month")
		"mentor":
			if affection >= 75 and trust >= 60: return _tr("매달 투자감각 +1, 지력 +1, 투자 인사이트 수익", "+1 Investing, +1 Intelligence/month, investment insight gains")
			elif affection >= 55: return _tr("매달 투자감각/지력 성장 기회", "Monthly chance to grow Investing/Intelligence")
			else: return _tr("매달 지력 성장 기회", "Monthly chance to grow Intelligence")
		"business":
			if affection >= 75 and trust >= 70: return _tr("매달 평판 +2, 수익 공유 기회", "+2 Reputation/month, profit-sharing chance")
			elif affection >= 55: return _tr("매달 평판 +1, 소액 수익 기회", "+1 Reputation/month, small income chance")
			else: return _tr("매달 평판 성장 기회", "Monthly chance to grow Reputation")
		"family":
			if affection >= 70: return _tr("매달 정신력 +4, 위기 시 지원금", "+4 Mental/month, support funds in crisis")
			elif affection >= 50: return _tr("매달 정신력 +2", "+2 Mental/month")
		"friends":
			if affection >= 70: return _tr("매달 정신력 +3, 사회성 성장 기회", "+3 Mental/month, chance to grow Social")
			elif affection >= 50: return _tr("매달 정신력 +1, 사회성 성장 기회", "+1 Mental/month, chance to grow Social")
	return ""

func _hint_box() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#1a2a0a")
	s.border_color = Color("#4a7a1a")
	s.set_border_width_all(1)
	s.set_corner_radius_all(5)
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s

func _random_topic(news):
	var topics: Array = news.get("topics", [_tr("시장", "market")])
	if topics.is_empty():
		return _tr("시장", "market")
	return topics.pick_random()

# ── 다음 마일스톤 힌트 ────────────────────────────────
func _next_milestone_hint(total: float) -> String:
	# [target, label, strategy_hint]
	var milestones: Array = [
		[8_000_000.0,     _tr("원룸 이사 구간", "One-room move range"),        _tr("→ 주거 AP에서 이사 가능. 정신력 보너스", "→ Move via Housing AP. Mental bonus")],
		[20_000_000.0,    _tr("종잣돈 2천만", "KRW 20M seed money"),              _tr("→ 투자 계좌 개설 & 주식·코인 시작 가능", "→ Open an investment account & start stocks/crypto")],
		[40_000_000.0,    _tr("빌라 전세 구간", "Villa jeonse range"),        _tr("→ 주거 AP에서 빌라 전세 선택 가능", "→ Choose villa jeonse via Housing AP")],
		[100_000_000.0,   _tr("자산 1억", "KRW 100M assets"),                 _tr("→ 레버리지 투자 & 고급 이벤트 해금", "→ Unlock leverage investing & advanced events")],
		[130_000_000.0,   _tr("아파트 전세 구간", "Apartment jeonse range"),      _tr("→ 아파트 입주 시 평판·투자감각 보너스", "→ Reputation & Investing bonus on moving in")],
		[500_000_000.0,   _tr("자산 5억", "KRW 500M assets"),                 _tr("→ 고수익 투자 루트 본격 가동 구간", "→ Time to run high-yield investment routes in earnest")],
		[1_000_000_000.0, _tr("자산 10억", "KRW 1B assets"),                "→ " + _tr("강남 오픈하우스 이벤트 + 엘리트 인맥", "Gangnam open-house event + elite connections")],
		[2_000_000_000.0, _tr("자산 20억", "KRW 2B assets"),                _tr("→ 마지막 10억 — 레버리지 or 집중 투자", "→ The last KRW 1B — leverage or concentrated investing")],
		[3_000_000_000.0, _tr("자산 30억 = 강남드림!", "KRW 3B assets = Gangnam Dream!"), ""],
	]
	for m in milestones:
		var target: float = float(m[0])
		if total < target:
			var needed = target - total
			var pct: int = int(total / target * 100.0)
			var hint: String = str(m[2])
			if hint.is_empty():
				return _tr("%s  까지  %s 남음  [%d%%]", "%s  —  %s to go  [%d%%]") % [str(m[1]), GameState.format_money(needed), pct]
			return _tr("%s  까지  %s  [%d%%]  [color=#7a9ab0]%s[/color]", "%s  —  %s  [%d%%]  [color=#7a9ab0]%s[/color]") % [str(m[1]), GameState.format_money(needed), pct, hint]
	return ""

func _months_to_goal_estimate() -> String:
	const GOAL: float = 3_000_000_000.0
	var total: float = float(GameState.get_total_asset_value())
	if total >= GOAL:
		return ""
	var net: float = float(GameState.monthly_income) - float(GameState.get_housing_expense())
	var remaining = GOAL - total
	if net <= 0.0:
		return _tr("[color=#ff7070]투자 없이는 달성 불가 — 자산을 굴려야 합니다[/color]", "[color=#ff7070]Impossible without investing — you need your assets to work[/color]")
	var months_needed = int(ceil(remaining / net))
	var turns_left: int = maxi(0, (38 - GameState.age) * 12 - GameState.month + 1)
	if months_needed <= turns_left:
		return _tr("[color=#7a8496]현재 수입만으로  약 %d개월 후 달성 가능 (투자 수익 제외)[/color]", "[color=#7a8496]Current income reaches the goal in about %d months (investment returns excluded)[/color]") % months_needed
	else:
		return _tr("[color=#b9bec7]현재 수입만으로  %d개월 필요 → 남은 시간 %d개월, 투자가 필수![/color]", "[color=#b9bec7]At current income: %d months needed → %d months left. Investing is essential.[/color]") % [months_needed, turns_left]

# ── 월 등급 계산 ─────────────────────────────────────
func _calc_month_grade(snap: Dictionary) -> Dictionary:
	var net = float(snap["monthly_income"]) - float(snap["fixed_expense"])
	var asset_delta = GameState.get_total_asset_value() - float(snap["assets_before"])
	var total = GameState.get_total_asset_value()
	var t = GameState.turn
	if asset_delta >= 10_000_000.0:
		var big_msgs = [
			_tr("자산이 %s 늘었습니다. 이 흐름을 유지하세요.", "Assets grew by %s. Keep this momentum.") % GameState.format_money(asset_delta),
			_tr("투자가 빛을 발하고 있습니다. 포지션을 점검하세요.", "Your investments are paying off. Review your positions."),
			_tr("이런 달이 쌓이면 강남드림이 가까워집니다.", "Enough months like this will bring Gangnam within reach."),
		]
		return {"badge": "TOP", "title": _tr("대박 달!", "Breakout Month!"), "msg": big_msgs[t % big_msgs.size()], "color": "#fbbf24"}
	elif asset_delta >= 2_000_000.0 and net >= 0.0:
		var good_msgs = [
			_tr("흑자에 자산 성장까지. 좋은 한 달이었습니다.", "Positive cash flow and asset growth. A good month."),
			_tr("수입과 투자 모두 순조롭습니다.", "Income and investments are both moving well."),
			_tr("꾸준히 이 방향으로 가면 됩니다.", "Keep moving steadily in this direction."),
		]
		return {"badge": "OK", "title": _tr("잘 했습니다", "Well Done"), "msg": good_msgs[t % good_msgs.size()], "color": "#00c896"}
	elif net >= 0.0:
		if total < 5_000_000.0:
			return {"badge": "LOG", "title": _tr("버티는 달", "Survival Month"), "msg": _tr("아직 초반입니다. 취업과 저축이 최우선입니다.", "It is still early. Jobs and savings come first."), "color": "#8892a4"}
		return {"badge": "LOG", "title": _tr("평범한 달", "Ordinary Month"), "msg": _tr("흑자 유지 중. 투자로 자산을 늘릴 타이밍을 찾아보세요.", "You stayed positive. Look for the right time to grow assets through investing."), "color": "#8892a4"}
	elif GameState.health > 55 and GameState.mental > 55:
		var tough_msgs = [
			_tr("재정은 적자지만 건강하게 버텼습니다. 곧 나아질 거예요.", "Finances were negative, but you stayed healthy. Things can improve soon."),
			_tr("어려운 달이었지만 쓰러지지 않았습니다.", "It was a hard month, but you did not collapse."),
			_tr("이 경험이 더 단단하게 만들어줄 겁니다.", "This experience will make you harder to break."),
		]
		return {"badge": "HOLD", "title": _tr("힘든 달", "Hard Month"), "msg": tough_msgs[t % tough_msgs.size()], "color": "#f0b429"}
	else:
		var crisis_msgs = [
			_tr("재정과 체력 모두 위험합니다. 전략을 바꾸세요.", "Both finances and stamina are in danger. Change strategy."),
			_tr("지금 방향을 바꾸지 않으면 무너집니다.", "If you do not change course now, you will break."),
			_tr("운동이나 명상으로 정신력부터 회복하세요.", "Recover Mental first through exercise or meditation."),
		]
		return {"badge": "RISK", "title": _tr("위기 상황", "Crisis"), "msg": crisis_msgs[t % crisis_msgs.size()], "color": "#ff4444"}

# ── 다음 달 조언 ─────────────────────────────────────
func _update_event_bg():
	if not event_bg:
		return
	if current_event.is_empty() and _transient_bg_active:
		return
	# 1순위: 이벤트가 명시한 background ID (ImageRegistry 경유)
	var new_path := ""
	var explicit_id = str(current_event.get("background", ""))
	if explicit_id != "":
		var reg_path = ImageRegistry.get_background(explicit_id)
		if reg_path != "" and ResourceLoader.exists(reg_path):
			new_path = reg_path
	# 2순위: 태그/카테고리 기반 자동 매핑
	if new_path == "":
		var bg_path = _get_bg_for_event(current_event)
		if bg_path != "" and ResourceLoader.exists(bg_path):
			new_path = bg_path
	_apply_event_bg_path(new_path)

func _apply_event_bg_path(new_path: String):
	if not event_bg:
		return
	if new_path == "" or new_path == _event_bg_path:
		return
	_event_bg_path = new_path
	var new_tex: Texture2D = load(new_path)
	# 처음 로드는 페이드인만, 이후는 크로스페이드
	if event_bg.texture == null:
		event_bg.texture = new_tex
		event_bg.modulate = Color(1, 1, 1, 0.0)
		var tw := create_tween()
		tw.tween_property(event_bg, "modulate:a", 0.25, 0.3)
		tw.tween_callback(_start_event_bg_motion)
	else:
		var tw := create_tween()
		tw.tween_property(event_bg, "modulate:a", 0.0, 0.15)
		tw.tween_callback(func():
			event_bg.texture = new_tex
			_start_event_bg_motion()
			var tw2 := create_tween()
			tw2.tween_property(event_bg, "modulate:a", 0.25, 0.25)
		)

func _start_event_bg_motion() -> void:
	if not is_instance_valid(event_bg):
		return
	if _event_bg_motion_tween and _event_bg_motion_tween.is_running():
		_event_bg_motion_tween.kill()
	var vp := get_viewport_rect().size
	event_bg.pivot_offset = vp * 0.5
	event_bg.scale = Vector2(1.012, 1.012)
	event_bg.position = Vector2.ZERO
	var dir := Vector2(randf_range(-1.0, 1.0), randf_range(-0.35, 0.35)).normalized()
	if dir.length() < 0.1:
		dir = Vector2(1.0, 0.0)
	_event_bg_motion_tween = create_tween()
	_event_bg_motion_tween.set_loops()
	_event_bg_motion_tween.tween_property(event_bg, "position", dir * 8.0, 9.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_event_bg_motion_tween.tween_property(event_bg, "position", -dir * 8.0, 9.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _get_bg_for_event(ev: Dictionary) -> String:
	var bg_id := ImageRegistry.infer_background_id(ev, GameState.housing)
	var bg_path := ImageRegistry.get_background(bg_id)
	if bg_path != "" and ResourceLoader.exists(bg_path):
		return bg_path
	return BG_PATHS.get(GameState.housing, BG_DEFAULT)

func _update_portrait():
	if not character_portrait:
		return
	# 이벤트가 인물 초상화를 명시하면 그 인물을 표시 (드라마 연출)
	if not current_event.is_empty():
		var pid = str(current_event.get("portrait", ""))
		if pid != "":
			_show_character_portrait(pid)
			return
	# 평상시 — 주인공 초상화 (ImageRegistry 우선, 없으면 기존 상수)
	_show_player_portrait()

func _show_character_portrait(portrait_id: String):
	var reg_path = ImageRegistry.get_portrait(portrait_id)
	if reg_path != "" and ResourceLoader.exists(reg_path):
		character_portrait.texture = load(reg_path)
		_apply_moral_portrait_state()
	else:
		# 파일 없음 → 플레이스홀더(이름+색상 박스) 표시
		_show_portrait_placeholder(portrait_id)
	# 이름표 업데이트
	var info = ImageRegistry.get_person_info(portrait_id)
	if player_name_label and not info.is_empty():
		player_name_label.text = str(info.get("name", ""))
	if title_label:
		title_label.text = _tr("이번 이야기", "This Episode")

func _show_player_portrait():
	var portrait_path = _get_portrait_path()
	if portrait_path != "" and ResourceLoader.exists(portrait_path):
		character_portrait.texture = load(portrait_path)
		_apply_moral_portrait_state()
	else:
		_show_portrait_placeholder("player_normal")

func _show_portrait_placeholder(portrait_id: String):
	# 이미지 파일이 없을 때: 인물 테마색 단색 텍스처로 대체
	var info = ImageRegistry.get_person_info(portrait_id)
	var col = Color(str(info.get("color", "#2a2a3a"))) if not info.is_empty() else Color("#2a2a3a")
	var img = Image.create(2, 3, false, Image.FORMAT_RGB8)
	img.fill(col.darkened(0.55))
	character_portrait.texture = ImageTexture.create_from_image(img)
	_apply_moral_portrait_state()

func _get_portrait_path() -> String:
	# 충격·위기 상황 (이벤트 직후 플래그)
	if GameState.flags.get("just_critical_event", false):
		return ImageRegistry.get_player_portrait_for_state("shocked")
	# 자산 마일스톤 달성 직후 — 기쁨
	if GameState.flags.get("just_hit_milestone", false):
		return ImageRegistry.get_player_portrait_for_state("happy")
	# 건강/정신 위험 — 피로
	if GameState.health <= 35 or GameState.mental <= 35:
		return ImageRegistry.get_player_portrait_for_state("tired")
	# 50대 이상
	if GameState.age >= 50:
		return ImageRegistry.get_player_portrait_for_state("hollow")
	# 평상시 — 직업/주거/자산 상태에 맞는 의상 포트레이트
	return ImageRegistry.get_player_portrait_for_state("normal")

func _get_month_advice() -> String:
	if GameState.health <= 40:
		return _tr("⚠ 건강 %d — 위험합니다. 당장 [운동]을 하세요. 건강이 0이 되면 '과로 엔딩'으로 종료됩니다.", "⚠ Health %d — danger zone. Exercise now. If Health reaches 0, you hit the overwork ending.") % GameState.health
	if GameState.mental <= 40:
		return _tr("⚠ 정신력 %d — 위험합니다. [명상]으로 회복하세요. 0이 되면 '정신 붕괴 엔딩'입니다.", "⚠ Mental %d — danger zone. Recover with meditation. If it reaches 0, you hit the breakdown ending.") % GameState.mental
	if GameState.mental <= 55:
		return _tr("정신력 %d — 피로가 쌓이고 있습니다. [명상]으로 회복하세요.", "Mental %d — fatigue is building. Use meditation to recover.") % GameState.mental
	if GameState.money < 500_000:
		return _tr("💸 잔고 %s — 위험 수위입니다. 알바나 투자로 당장 수입을 늘리세요.", "💸 Balance %s — danger zone. Raise income through gigs or investing.") % GameState.format_money(GameState.money)
	if GameState.current_job.is_empty():
		return _tr("직업이 없으면 매달 수입이 0원입니다. 생활비만큼 계속 줄어들어요. [구직활동]을 최우선으로 하세요.", "Without a job, monthly income is zero. Living costs will keep draining you. Prioritize Job Hunt.")
	if GameState.money < 0:
		return _tr("잔고가 마이너스입니다 (%s). 알바나 투자 수익으로 메우세요. 빚이 1억원을 넘으면 파산 엔딩입니다.", "Your balance is negative (%s). Cover it with gigs or investment gains. Debt over KRW 100M triggers bankruptcy.") % GameState.format_money(GameState.money)
	if GameState.can_upgrade_housing() and GameState.housing == "gosiwon":
		var next_id = str(GameState.get_housing_info().get("next", ""))
		return _tr("🏠 %s으로 이사할 자금이 생겼습니다 (현금 %s). 이사하면 정신력 패시브가 개선돼요!", "🏠 You can afford to move to a %s (cash %s). Moving improves your passive Mental pressure.") % [
			GameState.get_housing_name(next_id), GameState.format_money(GameState.money)]
	if GameState.investment_skill < 20 and GameState.get_total_asset_value() > 2_000_000.0 and GameState.turn > 4:
		return _tr("투자감각이 아직 낮습니다 (%d). [재테크 공부]로 올리면 투자 수익률이 올라갑니다.", "Your investing sense is still low (%d). Study finance to improve investment returns.") % GameState.investment_skill
	if not GameState.current_job.is_empty():
		var tenure = GameState.job_tenure
		var promo_count = int(GameState.current_job.get("promotion_count", 0))
		var max_promo = int(GameState.current_job.get("max_promotions", 3))
		if tenure >= 5 and promo_count < max_promo and GameState.work_performance >= 55:
			return _tr("근속 %d개월, 업무 성과 %d입니다. 승진 기회가 다가오고 있어요. 꾸준히 유지하세요.", "Tenure %d months, performance %d. Promotion chances are approaching. Stay consistent.") % [tenure, GameState.work_performance]
	return ""

func _check_title_unlocks():
	var newly = MetaProgression.check_and_unlock_titles()
	var rare_colors = {"common": "#8892a4", "uncommon": "#b8c0cc", "rare": "#dce5ee", "legendary": "#f8fbff"}
	for t in newly:
		var color = rare_colors.get(t.get("rare", "common"), "#8892a4")
		_show_toast(_tr("칭호 해금: 「%s」", "Title Unlocked: \"%s\"") % t.get("name", ""), Color(color))
		GameState.add_log(_tr("칭호 해금: %s", "Title Unlocked: %s") % t.get("name", ""), "system")

func _title_collection_badge(text: String, color: String, muted: bool = false) -> PanelContainer:
	var badge := PanelContainer.new()
	badge.custom_minimum_size = Vector2(98, 24)
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#11131a", 0.90) if not muted else Color("#090a0e", 0.80)
	st.border_color = Color(color, 0.62 if not muted else 0.26)
	st.set_border_width_all(1)
	st.set_corner_radius_all(5)
	st.content_margin_left = 8
	st.content_margin_right = 8
	st.content_margin_top = 3
	st.content_margin_bottom = 3
	badge.add_theme_stylebox_override("panel", st)
	var lbl := _label(text, 10, color if not muted else "#4f5665")
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if _font_bold and not muted:
		lbl.add_theme_font_override("font", _font_bold)
	badge.add_child(lbl)
	return badge

func _title_collection_row(name_text: String, desc_text: String, rare_label: String, rare_color: String, is_unlocked: bool) -> PanelContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(0, 62 if is_unlocked else 46)
	card.set_meta("moral_role", "info_card")
	card.set_meta("moral_accent", rare_color if is_unlocked else "#3a3f4f")
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#101116", 0.96) if is_unlocked else Color("#08090d", 0.82)
	st.border_color = Color(rare_color, 0.52) if is_unlocked else Color("#252935", 0.72)
	st.set_border_width_all(1)
	st.border_width_left = 3 if is_unlocked else 1
	st.set_corner_radius_all(7)
	st.content_margin_left = 12
	st.content_margin_right = 12
	st.content_margin_top = 8
	st.content_margin_bottom = 8
	card.add_theme_stylebox_override("panel", st)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	card.add_child(row)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.add_theme_constant_override("separation", 2)
	row.add_child(text_col)

	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 8)
	text_col.add_child(top_row)

	var name_lbl := _label(name_text, 13, "#e8eaf0" if is_unlocked else "#5b6372")
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	if _font_bold and is_unlocked:
		name_lbl.add_theme_font_override("font", _font_bold)
	top_row.add_child(name_lbl)
	top_row.add_child(_title_collection_badge(rare_label, rare_color, not is_unlocked))

	if is_unlocked and not desc_text.is_empty():
		var desc_lbl := _wrap_label(desc_text, 11, "#7f8794")
		text_col.add_child(desc_lbl)

	var status_text := _tr("획득", "OWNED") if is_unlocked else _tr("미발견", "HIDDEN")
	row.add_child(_title_collection_badge(status_text, "#c8d0df" if is_unlocked else "#4f5665", not is_unlocked))
	return card

func _open_title_collection():
	_open_modal(_tr("칭호 도감", "Title Collection"), true)
	if modal_panel:
		modal_panel.custom_minimum_size = Vector2(680, 600)
		modal_panel.offset_left  = -340
		modal_panel.offset_right =  340
		modal_panel.offset_top   = -300
		modal_panel.offset_bottom =  300

	var unlocked = MetaProgression.get_unlocked_titles()
	var total = MetaProgression.ALL_TITLES.size()
	modal_body.add_child(_wrap_label(
		_tr("해금 %d / %d  —  플레이를 거듭할수록 칭호가 늘어납니다.", "Unlocked %d / %d  —  More titles appear with each playthrough.") % [unlocked.size(), total],
		13, "#8892a4"))

	# 칭호 보유 보너스 (다음 런 시작 시 적용)
	var perk_bonus: Dictionary = MetaProgression.get_run_start_bonus()
	if not perk_bonus.is_empty():
		var stat_display: Dictionary = {
			"investment_skill": _tr("투자감각", "Invest Skill"), "intelligence": _tr("지력", "Intelligence"),
			"social_skill": _tr("사교력", "Social"), "luck": _tr("운", "Luck"),
			"mental": _tr("정신력", "Mental"), "money": _tr("자금", "Money"),
		}
		var perk_parts: PackedStringArray = PackedStringArray()
		for stat in perk_bonus:
			var amount = int(perk_bonus[stat])
			if amount == 0:
				continue
			if str(stat) == "money":
				perk_parts.append(_tr("자금 +%s", "Money +%s") % GameState.format_money(float(amount)))
			else:
				perk_parts.append("%s %+d" % [stat_display.get(str(stat), str(stat)), amount])
		if not perk_parts.is_empty():
			modal_body.add_child(_wrap_label(
				_tr("다음 런 시작 보너스:  ", "Next Run Start Bonus:  ") + " · ".join(perk_parts), 12, "#dce5ee"))

	var rare_colors = {"common": "#8892a4", "uncommon": "#b8c0cc", "rare": "#dce5ee", "legendary": "#f8fbff"}
	var rare_labels = {
		"common": _tr("일반", "COMMON"), "uncommon": _tr("희귀", "UNCOMMON"),
		"rare": _tr("레어", "RARE"), "legendary": _tr("전설", "LEGENDARY")
	}
	var cat_names: Dictionary = {
		"주거": _tr("주거", "Housing"), "직업": _tr("직업", "Career"), "투자": _tr("투자", "Investment"),
		"성향": _tr("성향", "Tendencies"), "관계": _tr("관계", "Relationships"), "생활": _tr("생활", "Lifestyle"),
		"자산": _tr("자산", "Assets"), "메타": _tr("메타", "Meta"), "미니게임": _tr("미니게임", "Mini-Games"),
		"이야기": _tr("이야기", "Story"),
	}
	for cat in ["주거", "직업", "투자", "성향", "관계", "생활", "자산", "메타", "미니게임", "이야기"]:
		var cat_titles: Array = []
		for t in MetaProgression.ALL_TITLES:
			if t.get("cat", "") == cat:
				cat_titles.append(t)
		if cat_titles.is_empty():
			continue
		var sep = HSeparator.new()
		sep.add_theme_color_override("color", Color("#252535"))
		modal_body.add_child(sep)
		var cat_text := str(cat_names.get(cat, cat))
		if LocaleManager.is_english():
			cat_text = cat_text.to_upper()
		modal_body.add_child(_label(cat_text, 12, "#7f8794"))
		for t in cat_titles:
			var tid: String = t["id"]
			var display_t: Dictionary = MetaProgression.get_title_info(tid)
			var is_unlocked: bool = unlocked.has(tid)
			var rare: String = t.get("rare", "common")
			var color: String = rare_colors.get(rare, "#8892a4")
			var name_text: String = str(display_t.get("name", tid)) if is_unlocked else _tr("미발견 칭호", "Undiscovered Title")
			var desc_text: String = str(display_t.get("desc", "")) if is_unlocked else ""
			modal_body.add_child(_title_collection_row(name_text, desc_text, str(rare_labels.get(rare, rare)), color, is_unlocked))

	var sep_end = HSeparator.new()
	sep_end.add_theme_color_override("color", Color("#252535"))
	modal_body.add_child(sep_end)
	var close_btn = _button(_tr("닫기", "Close"), "#2a2a3a")
	close_btn.pressed.connect(_close_modal)
	modal_body.add_child(close_btn)



## A-4: 금융 용어 설명 모달
const GLOSSARY_BANK := [
	{"term": "신용등급", "term_en": "Credit Grade", "desc": "1~10등급 (낮을수록 좋음). 직장·근속·소득·자산이 올리고 부채 비율·잔고 위기가 깎는다. 대출 한도와 금리를 결정한다.", "desc_en": "A 1-10 grade where lower is better. Jobs, tenure, income, and assets improve it; debt ratio and cash crises damage it. It determines loan limits and interest rates."},
	{"term": "변동금리", "term_en": "Variable Rate", "desc": "매달 달라질 수 있는 금리. 신용등급이 떨어지면 이미 빌린 대출의 이자도 같이 오른다. 이 게임의 모든 대출은 변동금리다.", "desc_en": "An interest rate that can change every month. If your credit grade worsens, existing loan interest rises too. All loans in this game use variable rates."},
	{"term": "레버리지", "term_en": "Leverage", "desc": "빌린 돈으로 더 큰 금액을 투자하는 것. 수익이 배로 나지만 손실도 배로 커진다. '레버리지 투자' 탭에서 2배 레버리지를 쓸 수 있다.", "desc_en": "Investing a larger amount with borrowed money. Gains multiply, but losses multiply too. The Leverage tab allows 2x leverage."},
	{"term": "마진콜", "term_en": "Margin Call", "desc": "레버리지 투자에서 원금 대비 손실이 65% 이상 나면 강제 전량 청산. 원금의 35% 이하로 떨어지는 순간 자동 발동된다.", "desc_en": "Forced liquidation when a leveraged position loses 65% or more of principal. It triggers automatically once value falls below 35% of principal."},
]
const GLOSSARY_INVEST := [
	{"term": "포트폴리오", "term_en": "Portfolio", "desc": "내가 보유한 모든 자산의 구성. 여러 자산에 나눠 투자하면 한 종목이 폭락해도 전체 타격이 줄어든다.", "desc_en": "The mix of all assets you own. Diversifying across assets reduces the damage if one position crashes."},
	{"term": "배당률", "term_en": "Dividend Yield", "desc": "자산 보유 중 정기적으로 지급받는 수익 비율. 리츠(월배당)·배당주(분기배당)는 보유만 해도 현금이 들어온다.", "desc_en": "The periodic income rate paid while holding an asset. REITs and dividend stocks generate cash just by being held."},
	{"term": "레버리지 ETF", "term_en": "Leveraged ETF", "desc": "지수 움직임의 2~3배로 등락하는 고위험 상품. 상승 시 3배 수익이지만 하락 시 3배 손실, 장기 보유 시 복리 손실이 누적된다.", "desc_en": "A high-risk product that moves 2-3x an index. It can triple gains on rises, but also triple losses, and compounding decay can hurt long holds."},
	{"term": "마진콜", "term_en": "Margin Call", "desc": "레버리지 투자 시 원금의 35% 이하로 떨어지면 강제 청산. 단기 급락으로도 전액 손실 가능.", "desc_en": "Forced liquidation when a leveraged position falls below 35% of principal. A short crash can wipe out the entire position."},
	{"term": "공포/탐욕 지수", "term_en": "Fear/Greed Index", "desc": "시장 분위기를 0~100으로 나타낸 지표. 30 이하(공포)일 때 사고 70 이상(탐욕)일 때 팔면 수익 확률이 높다.", "desc_en": "A 0-100 market sentiment indicator. Buying under 30 fear and selling over 70 greed improves your odds."},
	{"term": "하우스엣지", "term_en": "House Edge", "desc": "카지노가 장기적으로 가져가는 수익 비율. 바카라 1.06%, 블랙잭 0.5%, 룰렛 2.70%. 장기로 플레이할수록 이 비율만큼 손실이 쌓인다.", "desc_en": "The casino's long-term advantage. Baccarat 1.06%, blackjack 0.5%, roulette 2.70%. The longer you play, the more this edge accumulates against you."},
	{"term": "RTP", "term_en": "RTP", "desc": "Return To Player. 장기 플레이 시 플레이어에게 돌아가는 비율. 슬롯 RTP 90%면 100만원 투입 시 이론상 90만원 반환. 단기 결과는 크게 벗어날 수 있다.", "desc_en": "Return To Player. The long-term percentage returned to players. If slot RTP is 90%, KRW 1M wagered theoretically returns KRW 900K, though short-term results can swing wildly."},
]

func _open_glossary(title: String, category: String):
	_open_modal(title, true)
	var terms := GLOSSARY_BANK if category == "bank" else GLOSSARY_INVEST
	for pair in terms:
		var item: Dictionary = pair
		var term_row := VBoxContainer.new()
		term_row.add_theme_constant_override("separation", 2)
		modal_body.add_child(term_row)
		var term_lbl := Label.new()
		term_lbl.text = _loc_dict(item, "term")
		term_lbl.add_theme_font_size_override("font_size", 13)
		term_lbl.add_theme_color_override("font_color", Color("#f0b429"))
		if UIStyle.font_bold:
			term_lbl.add_theme_font_override("font", UIStyle.font_bold)
		term_row.add_child(term_lbl)
		term_row.add_child(_wrap_label(_loc_dict(item, "desc"), 12, "#8892a4"))
		var sep := HSeparator.new()
		sep.add_theme_color_override("color", Color("#1e1e2e"))
		modal_body.add_child(sep)
	var back_btn := _button(_tr("← 돌아가기", "← Back"), "#1a1a28")
	back_btn.pressed.connect(_close_modal)
	modal_body.add_child(back_btn)
