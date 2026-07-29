extends Control
## StoryMode — 전체화면 비주얼노벨 화면
##
## 스토리/아크 이벤트를 소설처럼 보여준다. 타이핑 효과, 배경, 인물 초상화,
## 선택지, 스탯/관계 변화 노출. 시뮬레이션 UI(스탯바/AP/버튼)는 전부 숨김.
##
## 사용법:
##   StoryMode.play_sequence([event_id1, event_id2, ...], return_scene)
##   또는 StoryMode.play_event(event_dict, on_done_callable)
##
## 전역 진입점: GameState.pending_story_queue 에 이벤트 ID 배열을 넣고
##   SceneTransition.go("res://scenes/StoryMode.tscn") 로 진입.

# ── 노출 색상 ─────────────────────────────────────────────────
const DEMO_CORE_LOOP_V2 := preload("res://systems/DemoCoreLoopV2.gd")
const C_NARRATION := "#d8dce8"
const C_DIM       := "#8892a4"
const C_CHOICE    := "#c8d0e0"
const STORY_TEXT_SIZE_DEFAULT := "standard"
const STORY_TEXT_SIZE_LEVELS: Array[String] = ["small", "standard", "large"]
const STORY_TEXT_SCALES := {
	"small": 0.90,
	"standard": 1.00,
	"large": 1.15,
}
const STORY_TEXT_SPEED_DEFAULT := "standard"
const STORY_TEXT_SPEED_LEVELS: Array[String] = ["slow", "standard", "fast"]
const STORY_TEXT_SPEED_INTERVAL_SCALES := {
	"slow": 1.65,
	"standard": 1.00,
	"fast": 0.50,
}

# ── 상태 ──────────────────────────────────────────────────────
var _queue: Array = []          # 재생할 이벤트 ID 목록
var _current: Dictionary = {}   # 현재 이벤트
var _paragraphs: Array = []     # 화면 높이에 맞춰 나눈 현재 이벤트 본문 페이지
var _paragraph_source_indices: Array = []  # 각 페이지가 속한 원문 문단 번호
var _para_index: int = 0
var _typing: bool = false
var _type_full: String = ""     # 현재 문단 전체 텍스트
var _type_pos: int = 0
var _showing_choices: bool = false
var _transitioning: bool = false
var _pending_after_result: bool = false
var _pending_result_choice_index: int = -1
var _pending_follow_up: String = ""
var _next_transition_mode: String = ""
var _current_transition_mode: String = ""
var _next_transition_contract: Dictionary = {}
var _current_transition_contract: Dictionary = {}
var _direction: Dictionary = {}
var _direction_camera_tween: Tween = null
var _portrait_idle_tween: Tween = null
var _direction_hold_active: bool = false
var _direction_hold_consumed: bool = false
var _direction_hold_remaining: float = 0.0
var _direction_beat_waiting: bool = false
var _direction_beat_remaining: float = 0.0
var _direction_pending_text: String = ""
var _story_visual_override_active: bool = false
var _story_visual_override_norm: float = 0.0
var _read_only_replay: bool = false

# ── 노드 ──────────────────────────────────────────────────────
var _bg_img: TextureRect
var _bg_dim: ColorRect
var _story_surface_overlay: ColorRect = null
var _story_surface_material: ShaderMaterial = null
var _story_bg_material: ShaderMaterial = null
var _story_portrait_material: ShaderMaterial = null
var _living_scene: LivingSceneLayer = null
var _living_profile: Dictionary = {}
var _portrait: TextureRect
var _portrait_frame: PanelContainer
var _name_panel: PanelContainer
var _name_tag: Label
var _communication_badge: PanelContainer
var _communication_label: Label
var _current_presentation: Dictionary = {}
var _portrait_remote_inset: bool = false
var _portrait_target_alpha: float = 1.0
var _title_lbl: Label
var _body_lbl: RichTextLabel
var _continue_hint: Label
var _text_rule: ColorRect
var _choice_box: VBoxContainer
var _toast_layer: VBoxContainer
var _hud_panel: Panel      # 챕터 카드 시 전체 HUD 바를 숨기기 위한 상단 패널 참조
var _hud_label: Label   # 얇은 상단 HUD — 자산/돈/컨디션/시간
var _text_panel: Panel           # 하단 텍스트 박스 (챕터 카드 시 숨김)
var _result_record_card: Control = null
var _chapter_overlay: Control = null  # 챕터 카드 전용 오버레이
var _is_chapter_card: bool = false    # 챕터 카드 모드 플래그
var _current_uses_cg: bool = false
var _event_cg_id: String = ""
var _event_cg_path: String = ""
var _event_cg_reveal_paragraph: int = 0
var _event_paragraph_backgrounds: Array = []
var _event_background_id: String = ""
var _event_portrait_reveal_paragraph: int = 0
var _event_portrait_revealed: bool = true
var _story_moral_norm: float = 0.0
var _story_moral_stage: int = 0
var _story_ink_transition_layer: Control = null
var _story_ink_transition_tween: Tween = null
var _story_ink_transition_progress: float = 0.0
var _story_ink_transition_kind: String = "scene"
var _story_transition_snapshot: TextureRect = null
var _story_transition_portrait_snapshot: TextureRect = null
var _story_transition_snapshot_base_scale := Vector2.ONE
var _story_transition_portrait_base_scale := Vector2.ONE
var _story_scene_transition_active: bool = false
var _story_scene_transition_duration: float = 0.0
var _story_text_panel_tween: Tween = null
var _auto_button: Button = null
var _auto_mode: bool = false
var _auto_wait: float = -1.0
var _auto_button_signature: String = ""
var _advance_hold_active: bool = false
var _advance_hold_wait: float = 0.0
var _advance_hold_event_id: String = ""
var _audio_settings_button: Button = null
var _audio_settings_popup: Control = null
var _audio_settings_previous_focus: Control = null
var _audio_bgm_slider: HSlider = null
var _audio_sfx_slider: HSlider = null
var _audio_reduce_motion_toggle: CheckButton = null
var _story_text_size: String = STORY_TEXT_SIZE_DEFAULT
var _story_text_size_buttons: Dictionary = {}
var _story_text_speed: String = STORY_TEXT_SPEED_DEFAULT
var _story_text_speed_buttons: Dictionary = {}
var _story_language_buttons: Dictionary = {}
var _settings_countdown_remaining_msec: int = -1
var _settings_countdown_total_msec: int = -1
var _settings_focus_key: String = ""
var _story_save_page: int = 0
var _story_save_notice: String = ""
var _pending_restore_context: Dictionary = {}
var _name_panel_visible_before_choices: bool = false
var _choice_countdown_timer: Timer = null
var _choice_countdown_row: HBoxContainer = null
var _choice_countdown_bar: ProgressBar = null
var _choice_countdown_label: Label = null
var _choice_countdown_deadline_msec: int = 0
var _choice_countdown_total_msec: int = 0
var _choice_countdown_default_index: int = 0

var _font: FontFile
var _font_bold: FontFile

const TYPE_SPEED := 0.018   # 글자당 초
const AUTO_CJK_CHARS_PER_MINUTE := 390.0
const AUTO_EN_WORDS_PER_MINUTE := 190.0
const AUTO_BREATH_SECONDS := 0.75
const AUTO_MIN_WAIT_SECONDS := 1.20
const AUTO_MAX_WAIT_SECONDS := 22.0
const ADVANCE_HOLD_INITIAL_DELAY := 0.34
const ADVANCE_HOLD_REPEAT_DELAY := 0.14
const JOY_BUTTON_NORTH := 3
const PORTRAIT_OFFSET_LEFT := -430
const PORTRAIT_OFFSET_RIGHT := -28
const PORTRAIT_OFFSET_TOP := -690
const PORTRAIT_OFFSET_BOTTOM := -40
const PORTRAIT_CHOICE_SHIFT_X := 72
const PORTRAIT_BLACK_PERIPHERY_SHIFT_X := 30
const PORTRAIT_WHITE_CLOSENESS_SHIFT_X := -10
const REMOTE_PORTRAIT_OFFSET_LEFT := -360
const REMOTE_PORTRAIT_OFFSET_RIGHT := -52
const REMOTE_PORTRAIT_OFFSET_TOP := -670
const REMOTE_PORTRAIT_OFFSET_BOTTOM := -286
const REMOTE_PORTRAIT_CHOICE_SHIFT_X := 34
const RESULT_ECONOMIC_KEYS: Array[String] = [
	"money", "monthly_income", "investment_skill", "work_performance", "reputation",
]
const RESULT_HUMAN_KEYS: Array[String] = [
	"health", "mental", "social_skill", "addiction_tendency", "gambling_tendency",
]
const RESULT_OTHER_KEYS: Array[String] = ["intelligence", "appearance", "luck"]

static var _auto_enabled_session: bool = false

func _ready():
	_read_only_replay = GameState.story_replay_mode
	_story_text_size = _normalized_story_text_size(str(
		SaveManager.get_setting("story_text_size", STORY_TEXT_SIZE_DEFAULT)))
	_story_text_speed = _normalized_story_text_speed(str(
		SaveManager.get_setting("story_text_speed", STORY_TEXT_SPEED_DEFAULT)))
	_load_fonts()
	_build_ui()
	_apply_story_text_size()
	# 본편은 소설처럼 흐르되, 회상은 감상자의 속도를 존중한다.
	# 회상의 일시 OFF가 본편 세션 취향을 덮어쓰지 않도록 영속하지 않는다.
	_set_auto_mode(_auto_enabled_session and not _read_only_replay, false, false)
	_refresh_hud()
	GameState.stats_changed.connect(_refresh_hud)
	if not GameState.moral_tint_changed.is_connected(_on_story_moral_tint_changed):
		GameState.moral_tint_changed.connect(_on_story_moral_tint_changed)
	SceneTransition.fade_in()
	var resume_context := SaveManager.consume_loaded_resume_context()
	if str(resume_context.get("kind", "")) == "story":
		_pending_restore_context = resume_context.duplicate(true)
		_queue = resume_context.get("queue", []).duplicate(true)
		var resume_event_id := str(resume_context.get("event_id", ""))
		if not resume_event_id.is_empty():
			_queue.push_front(resume_event_id)
		GameState.story_return_scene = str(resume_context.get(
			"return_scene", "res://scenes/MainGame.tscn"))
		GameState.story_replay_mode = false
		_read_only_replay = false
	else:
		# 일반 진입은 GameState에 예약된 사건 큐를 가져온다.
		_queue = GameState.pending_story_queue.duplicate()
	GameState.pending_story_queue.clear()
	if _queue.is_empty():
		_finish_all()
		return
	_load_next_event()

func _load_fonts():
	_font      = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile
	FontKit.attach_emoji_fallback(_font)
	FontKit.attach_emoji_fallback(_font_bold)

# ── Gangnam Ink 표면 팔레트 ───────────────────────────────────
func _on_story_moral_tint_changed(norm: float, stage: int) -> void:
	_story_moral_norm = clampf(norm, -1.0, 1.0)
	_story_moral_stage = stage
	_apply_story_surface_palette(_current_uses_cg)
	if is_instance_valid(_living_scene) and not _living_profile.is_empty():
		_living_scene.update_moral(_story_moral_norm)
		_living_profile = _living_scene.current_profile.duplicate(true)
		_set_living_background_blur(_showing_choices)
		_start_portrait_idle_motion()
	_pulse_story_moral_echo(norm, stage)

func _story_palette() -> Dictionary:
	var black := clampf(-_story_moral_norm, 0.0, 1.0)
	var white := clampf(_story_moral_norm, 0.0, 1.0)
	var ui_black := black * 0.24
	var ui_white := white * 0.18
	var palette := ModLoader.moral_palette("story", black, white)
	palette["black"] = ui_black
	palette["white"] = ui_white
	palette["moral_black"] = black
	palette["moral_white"] = white
	return palette

## 같은 사건도 민준이 무엇을 먼저 보는지에 따라 다르게 읽힌다.
## 장면 강제 필터(black_future)가 아니라 실제 플레이 상태만 사용한다.
func _moral_perception_keys() -> Array[String]:
	match GameState.moral_stage():
		-2:
			return ["deep_black", "black"]
		-1:
			return ["black"]
		1:
			return ["white"]
		2:
			return ["deep_white", "white"]
		_:
			return ["gray"]

func _moral_perception_text(raw_map: Variant, fallback: String) -> String:
	if not raw_map is Dictionary:
		return fallback
	var variants := raw_map as Dictionary
	for key in _moral_perception_keys():
		var candidate := str(variants.get(key, "")).strip_edges()
		if not candidate.is_empty():
			return candidate
	return fallback

func _story_panel_style(bg: Color, border: Color, radius: int, h_margin: int = 0, v_margin: int = 0, left_border: int = 0) -> StyleBoxFlat:
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

func _story_dim_color(has_cg: bool) -> Color:
	var black := clampf(-_story_moral_norm, 0.0, 1.0)
	var white := clampf(_story_moral_norm, 0.0, 1.0)
	# Text and choices already own local opaque surfaces. Keep the world readable;
	# moral collapse comes from damaged tone and focus, not a global black curtain.
	var alpha := (0.12 if not has_cg else 0.015)
	alpha += black * (0.13 if not has_cg else 0.055)
	alpha -= white * (0.10 if not has_cg else 0.01)
	var tone := Color("#050609").lerp(Color("#010202"), black)
	tone.a = clampf(alpha, 0.0, 0.40)
	return tone

func _apply_story_surface_palette(has_cg: bool = false, immediate: bool = false) -> void:
	if _story_visual_override_active:
		_story_moral_norm = clampf(_story_visual_override_norm, -1.0, 1.0)
		_story_moral_stage = -2 if _story_moral_norm <= -0.6 else (-1 if _story_moral_norm < -0.2 else 0)
	else:
		_story_moral_norm = clampf(GameState.moral_tint_norm(), -1.0, 1.0)
		_story_moral_stage = GameState.moral_stage()
	var palette := _story_palette()
	var black: float = float(palette["moral_black"])
	var white: float = float(palette["moral_white"])
	var panel_bg: Color = palette["panel_bg"]
	var panel_border: Color = palette["panel_border"]
	var hud_bg: Color = palette["hud_bg"]
	var text_col: Color = palette["text"]
	var dim_col: Color = palette["dim"]
	var dead_col: Color = palette["dead"]
	var focus_col: Color = palette["focus"]
	var line_col: Color = palette["line"]

	if is_instance_valid(_bg_dim):
		_bg_dim.color = _story_dim_color(has_cg)
	if _story_bg_material:
		# Reusable locations stay documentary. One-off CGs are the emotional
		# reward surface, so they keep color until Black-route damage earns its removal.
		var base_desaturation := 0.12 if has_cg else 0.68
		var black_desaturation := 0.76 if has_cg else 0.32
		var white_clearance := 0.08 if has_cg else 0.38
		_story_bg_material.set_shader_parameter("desaturation", clampf(base_desaturation + black * black_desaturation - white * white_clearance, 0.04, 1.0))
		_story_bg_material.set_shader_parameter("brightness", clampf((1.04 if has_cg else 1.06) - black * (0.04 if has_cg else 0.10) + white * 0.06, 0.90, 1.16))
		_story_bg_material.set_shader_parameter("contrast", clampf((0.98 if has_cg else 1.00) - black * 0.04 + white * 0.04, 0.90, 1.08))
		_story_bg_material.set_shader_parameter("mid_gamma", clampf((0.96 if has_cg else 0.86) + black * (0.02 if has_cg else -0.08) - white * 0.05, 0.72, 1.04))
		_story_bg_material.set_shader_parameter("tint_amount", clampf(black * 0.07 + white * 0.035, 0.0, 0.12))
		_story_bg_material.set_shader_parameter("tint_color", Color("#020303").lerp(Color("#f7fbff"), white))
		_story_bg_material.set_shader_parameter("grain_amount", clampf(0.012 + black * 0.038 - white * 0.009, 0.0, 0.075))
		_story_bg_material.set_shader_parameter("ink_bleed", clampf(0.035 + black * 0.165 - white * 0.025, 0.0, 0.24))
		_story_bg_material.set_shader_parameter("paper_fade", clampf(0.012 + white * 0.038, 0.0, 0.07))
		_story_bg_material.set_shader_parameter("edge_burn", clampf(0.045 + black * 0.180 - white * 0.035, 0.0, 0.25))
		_story_bg_material.set_shader_parameter("print_screen", clampf(0.006 + black * 0.034 - white * 0.004, 0.002, 0.052))
		_story_bg_material.set_shader_parameter("tone_quantize", clampf(0.008 + black * 0.112 - white * 0.006, 0.0, 0.14))
		_story_bg_material.set_shader_parameter("screen_scale", 620.0 + black * 80.0 - white * 40.0)
		_story_bg_material.set_shader_parameter("seed", float(GameState.turn % 131) + absf(_story_moral_norm) * 19.0)
	if _story_surface_material and is_instance_valid(_story_surface_overlay):
		_story_surface_overlay.visible = black > 0.01 or white > 0.01
		_story_surface_material.set_shader_parameter("black_intensity", black)
		_story_surface_material.set_shader_parameter("white_intensity", white)
		_story_surface_material.set_shader_parameter("print_screen", clampf(black * 0.045 - white * 0.010, 0.0, 0.055))
		_story_surface_material.set_shader_parameter("seed", float(GameState.turn % 97) + absf(_story_moral_norm) * 10.0)
	_apply_story_portrait_surface()
	if is_instance_valid(_text_panel):
		_text_panel.add_theme_stylebox_override("panel", _story_panel_style(panel_bg, panel_border, 8))
	if is_instance_valid(_name_panel):
		_name_panel.add_theme_stylebox_override("panel", _story_panel_style(palette["choice_bg"], panel_border, 6, 18, 5, 3))
	if is_instance_valid(_hud_panel):
		var hud_style := _story_panel_style(hud_bg, line_col, 0)
		hud_style.border_width_top = 0
		hud_style.border_width_left = 0
		hud_style.border_width_right = 0
		hud_style.border_width_bottom = 1
		_hud_panel.add_theme_stylebox_override("panel", hud_style)
	if is_instance_valid(_text_rule):
		_text_rule.color = line_col
	if is_instance_valid(_title_lbl):
		_title_lbl.add_theme_color_override("font_color", dim_col)
		UIStyle.apply_ink_text_depth(_title_lbl, "display")
	if is_instance_valid(_body_lbl):
		_body_lbl.add_theme_color_override("default_color", text_col)
		UIStyle.clear_ink_text_depth(_body_lbl)
	if is_instance_valid(_continue_hint):
		_continue_hint.add_theme_color_override("font_color", dead_col)
		UIStyle.clear_ink_text_depth(_continue_hint)
	if is_instance_valid(_name_tag):
		_name_tag.add_theme_color_override("font_color", focus_col)
		UIStyle.apply_ink_text_depth(_name_tag, "nameplate")
	if is_instance_valid(_hud_label):
		_hud_label.add_theme_color_override("font_color", dim_col)
		UIStyle.clear_ink_text_depth(_hud_label)

func _apply_story_portrait_surface() -> void:
	if not is_instance_valid(_portrait):
		return
	var black := clampf(-_story_moral_norm, 0.0, 1.0)
	var white := clampf(_story_moral_norm, 0.0, 1.0)
	if _story_portrait_material:
		_story_portrait_material.set_shader_parameter("desaturation", clampf(0.30 + black * 0.62 - white * 0.18, 0.08, 0.96))
		_story_portrait_material.set_shader_parameter("brightness", clampf(1.02 - black * 0.04 + white * 0.04, 0.92, 1.14))
		_story_portrait_material.set_shader_parameter("contrast", clampf(0.98 + black * 0.06 + white * 0.06, 0.90, 1.16))
		_story_portrait_material.set_shader_parameter("mid_gamma", clampf(0.96 + black * 0.06 - white * 0.03, 0.88, 1.06))
		_story_portrait_material.set_shader_parameter("tint_amount", clampf(black * 0.14 + white * 0.025, 0.0, 0.16))
		_story_portrait_material.set_shader_parameter("tint_color", Color("#020303").lerp(Color("#f6fbff"), white))
		_story_portrait_material.set_shader_parameter("grain_amount", clampf(0.003 + black * 0.027 - white * 0.003, 0.0, 0.055))
		_story_portrait_material.set_shader_parameter("ink_bleed", clampf(0.008 + black * 0.132 - white * 0.006, 0.0, 0.18))
		_story_portrait_material.set_shader_parameter("paper_fade", clampf(white * 0.022, 0.0, 0.05))
		_story_portrait_material.set_shader_parameter("edge_burn", clampf(0.012 + black * 0.123 - white * 0.010, 0.0, 0.16))
		_story_portrait_material.set_shader_parameter("print_screen", clampf(0.003 + black * 0.017 - white * 0.002, 0.0, 0.025))
		_story_portrait_material.set_shader_parameter("tone_quantize", clampf(black * 0.045 - white * 0.010, 0.0, 0.075))
		_story_portrait_material.set_shader_parameter("screen_scale", 700.0 + black * 90.0)
		_story_portrait_material.set_shader_parameter("seed", float(GameState.turn % 149) + absf(_story_moral_norm) * 23.0)
	# Black에서는 사람이 사라지는 게 아니라 시야의 주변부로 물러난다.
	# White에서는 얼굴이 조금 가까워진다. 텍스트/입력 영역은 움직이지 않는다.
	_portrait.modulate = Color(
		1.0 + white * 0.035 - black * 0.045,
		1.0 + white * 0.030 - black * 0.055,
		1.0 + white * 0.020 - black * 0.060,
		1.0 - black * 0.06
	)
	if is_instance_valid(_portrait_frame):
		var moral_shift := int(roundf(
			black * float(PORTRAIT_BLACK_PERIPHERY_SHIFT_X) +
			white * float(PORTRAIT_WHITE_CLOSENESS_SHIFT_X)
		))
		var choice_shift := _portrait_choice_shift() if _showing_choices else 0
		_portrait_frame.offset_left = _portrait_base_left() + moral_shift + choice_shift
		_portrait_frame.offset_right = _portrait_base_right() + moral_shift + choice_shift
		_portrait_frame.pivot_offset = _portrait_frame.size * 0.5
		var focus_scale := 1.0 - black * 0.030 + white * 0.010
		_portrait_frame.scale = Vector2.ONE * focus_scale

func _portrait_base_left() -> int:
	return REMOTE_PORTRAIT_OFFSET_LEFT if _portrait_remote_inset else PORTRAIT_OFFSET_LEFT

func _portrait_base_right() -> int:
	return REMOTE_PORTRAIT_OFFSET_RIGHT if _portrait_remote_inset else PORTRAIT_OFFSET_RIGHT

func _portrait_choice_shift() -> int:
	return REMOTE_PORTRAIT_CHOICE_SHIFT_X if _portrait_remote_inset else PORTRAIT_CHOICE_SHIFT_X

func _animate_story_text_panel() -> void:
	if not is_instance_valid(_text_panel):
		return
	if not is_inside_tree():
		return
	if _story_text_panel_tween and _story_text_panel_tween.is_running():
		_story_text_panel_tween.kill()
	_text_panel.modulate = Color(1, 1, 1, 0.0)
	_story_text_panel_tween = create_tween()
	if _story_scene_transition_active:
		_story_text_panel_tween.tween_interval(_story_scene_transition_duration * 0.72)
	_story_text_panel_tween.tween_property(
		_text_panel, "modulate:a", 1.0,
		0.28 if _story_scene_transition_active else 0.22
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_story_text_panel_tween.tween_callback(func(): _story_text_panel_tween = null)

func _pulse_story_moral_echo(_norm: float, _stage: int) -> void:
	if not is_inside_tree() or not is_instance_valid(_text_panel):
		return
	var black := clampf(-_story_moral_norm, 0.0, 1.0)
	var white := clampf(_story_moral_norm, 0.0, 1.0)
	var target := Color("#080909").lerp(Color("#f6fbff"), white)
	target.a = 1.0
	var base := _text_panel.modulate
	var strength := clampf(maxf(black, white), 0.10, 0.32)
	var tw := create_tween()
	tw.tween_property(_text_panel, "modulate", base.lerp(target, strength), 0.12)
	tw.tween_property(_text_panel, "modulate", Color(1, 1, 1, 1), 0.38)

func _pulse_story_choice_commit() -> void:
	if not is_inside_tree() or not is_instance_valid(_text_panel):
		return
	var tw := create_tween()
	tw.tween_property(_text_panel, "modulate", Color(1.07, 1.07, 1.07, 1.0), 0.08)
	tw.tween_property(_text_panel, "modulate", Color(1, 1, 1, 1), 0.20)

func _bind_story_tactile_button(button: Button, strength: float = 1.0) -> void:
	if not is_instance_valid(button) or button.has_meta("_story_tactile_bound"):
		return
	button.set_meta("_story_tactile_bound", true)
	var hover_scale := Vector2.ONE * (1.0 + 0.002 * strength)
	var press_scale := Vector2(1.0 - 0.002 * strength, 1.0 - 0.014 * strength)
	button.mouse_entered.connect(func():
		if not button.disabled:
			_story_tactile_button_to(button, hover_scale, 0.10, Tween.TRANS_QUAD)
	)
	button.focus_entered.connect(func():
		if not button.disabled:
			_story_tactile_button_to(button, hover_scale, 0.10, Tween.TRANS_QUAD)
	)
	button.button_down.connect(func():
		if not button.disabled:
			_story_tactile_button_to(button, press_scale, UIStyle.MATERIAL_PRESS_DURATION_SEC, Tween.TRANS_QUAD)
	)
	button.button_up.connect(func():
		if not button.disabled:
			_story_tactile_button_to(button, hover_scale if button.has_focus() else Vector2.ONE, 0.12, Tween.TRANS_BACK)
	)
	button.mouse_exited.connect(func():
		_story_tactile_button_to(button, Vector2.ONE, 0.12, Tween.TRANS_QUAD)
	)
	button.focus_exited.connect(func():
		_story_tactile_button_to(button, Vector2.ONE, 0.12, Tween.TRANS_QUAD)
	)

func _story_tactile_button_to(button: Button, target_scale: Vector2, duration: float, trans: int) -> void:
	if not is_instance_valid(button) or not is_inside_tree():
		return
	if _living_reduced_motion():
		button.scale = Vector2.ONE
		return
	button.pivot_offset = button.size * 0.5
	var old: Variant = button.get_meta("_story_tactile_tween") if button.has_meta("_story_tactile_tween") else null
	if old is Tween and (old as Tween).is_running():
		(old as Tween).kill()
	var tw := create_tween()
	tw.bind_node(button)
	tw.tween_property(button, "scale", target_scale, duration).set_trans(trans).set_ease(Tween.EASE_OUT)
	button.set_meta("_story_tactile_tween", tw)

# ── UI 구성 ───────────────────────────────────────────────────
func _build_ui():
	# 1. 배경 이미지 (이벤트별 전환)
	_bg_img = TextureRect.new()
	_bg_img.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_bg_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	var bg_grade_shader = load("res://assets/shaders/background_grade.gdshader")
	if bg_grade_shader:
		_story_bg_material = ShaderMaterial.new()
		_story_bg_material.shader = bg_grade_shader
		_story_bg_material.set_shader_parameter("desaturation", 0.68)
		_story_bg_material.set_shader_parameter("brightness", 1.06)
		_story_bg_material.set_shader_parameter("contrast", 1.00)
		_story_bg_material.set_shader_parameter("mid_gamma", 0.86)
		_story_bg_material.set_shader_parameter("tint_color", Color("#020303"))
		_story_bg_material.set_shader_parameter("tint_amount", 0.0)
		_story_bg_material.set_shader_parameter("grain_amount", 0.012)
		_story_bg_material.set_shader_parameter("ink_bleed", 0.035)
		_story_bg_material.set_shader_parameter("paper_fade", 0.012)
		_story_bg_material.set_shader_parameter("edge_burn", 0.045)
		_story_bg_material.set_shader_parameter("print_screen", 0.006)
		_story_bg_material.set_shader_parameter("tone_quantize", 0.008)
		_story_bg_material.set_shader_parameter("screen_scale", 620.0)
		_story_bg_material.set_shader_parameter("blur_px", 0.0)
		_story_bg_material.set_shader_parameter("seed", 0.0)
		_bg_img.material = _story_bg_material
	_bg_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg_img)

	# 2. 어두운 오버레이 (텍스트 가독성)
	_bg_dim = ColorRect.new()
	_bg_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg_dim.color = Color(0.04, 0.04, 0.07, 0.16)
	_bg_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg_dim)

	# 3. MORAL_TINT 표면 필름 — 배경만 먼저 통과시켜 UI 가독성을 보존한다.
	_story_surface_overlay = ColorRect.new()
	_story_surface_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_story_surface_overlay.color = Color(1, 1, 1, 1)
	_story_surface_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_story_surface_overlay.visible = false
	var surface_shader = load("res://assets/shaders/moral_surface.gdshader")
	if surface_shader:
		_story_surface_material = ShaderMaterial.new()
		_story_surface_material.shader = surface_shader
		_story_surface_material.set_shader_parameter("black_intensity", 0.0)
		_story_surface_material.set_shader_parameter("white_intensity", 0.0)
		_story_surface_material.set_shader_parameter("print_screen", 0.0)
		_story_surface_material.set_shader_parameter("seed", 0.0)
		_story_surface_overlay.material = _story_surface_material
	add_child(_story_surface_overlay)

	# 4. 장면 공기 — 배경 필름 위, 입력·초상·텍스트 아래에서만 움직인다.
	_living_scene = LivingSceneLayer.new()
	_living_scene.name = "LivingScene"
	_living_scene.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_living_scene)
	_build_story_scene_transition_snapshots()

	# 5. 클릭 받는 전체 버튼 (타이핑 스킵/다음)
	var click_catcher = Button.new()
	click_catcher.flat = true
	click_catcher.set_anchors_preset(Control.PRESET_FULL_RECT)
	click_catcher.focus_mode = Control.FOCUS_NONE
	click_catcher.pressed.connect(_on_advance)
	add_child(click_catcher)

	# 6. 인물 초상화 — 우측 하단, 배경 위에 직접 표시.
	_portrait_frame = PanelContainer.new()
	_portrait_frame.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_portrait_frame.offset_left = PORTRAIT_OFFSET_LEFT
	_portrait_frame.offset_right = PORTRAIT_OFFSET_RIGHT
	_portrait_frame.offset_top = PORTRAIT_OFFSET_TOP
	_portrait_frame.offset_bottom = PORTRAIT_OFFSET_BOTTOM
	_portrait_frame.clip_contents = true
	_portrait_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait_frame.modulate = Color(1, 1, 1, 0)
	_portrait_frame.visible = false
	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = Color(0, 0, 0, 0)      # 배경 없음
	frame_style.set_border_width_all(0)             # 테두리 없음
	frame_style.shadow_size = 0                     # 그림자 없음
	frame_style.set_corner_radius_all(0)
	frame_style.set_content_margin_all(0)
	_portrait_frame.add_theme_stylebox_override("panel", frame_style)
	add_child(_portrait_frame)

	_portrait = TextureRect.new()
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if bg_grade_shader:
		_story_portrait_material = ShaderMaterial.new()
		_story_portrait_material.shader = bg_grade_shader
		_story_portrait_material.set_shader_parameter("desaturation", 0.30)
		_story_portrait_material.set_shader_parameter("brightness", 1.02)
		_story_portrait_material.set_shader_parameter("contrast", 0.98)
		_story_portrait_material.set_shader_parameter("mid_gamma", 0.96)
		_story_portrait_material.set_shader_parameter("tint_color", Color("#020303"))
		_story_portrait_material.set_shader_parameter("tint_amount", 0.0)
		_story_portrait_material.set_shader_parameter("grain_amount", 0.003)
		_story_portrait_material.set_shader_parameter("ink_bleed", 0.008)
		_story_portrait_material.set_shader_parameter("paper_fade", 0.0)
		_story_portrait_material.set_shader_parameter("edge_burn", 0.012)
		_story_portrait_material.set_shader_parameter("print_screen", 0.003)
		_story_portrait_material.set_shader_parameter("tone_quantize", 0.0)
		_story_portrait_material.set_shader_parameter("screen_scale", 700.0)
		_story_portrait_material.set_shader_parameter("blur_px", 0.0)
		_story_portrait_material.set_shader_parameter("seed", 0.0)
		_portrait.material = _story_portrait_material
	_portrait_frame.add_child(_portrait)

	# 원격 대화는 배경 속 실제 동석자로 오독되지 않도록 별도 통신 표면을 쓴다.
	_communication_badge = PanelContainer.new()
	_communication_badge.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_communication_badge.offset_left = -360
	_communication_badge.offset_right = -52
	_communication_badge.offset_top = -716
	_communication_badge.offset_bottom = -676
	_communication_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_communication_badge.visible = false
	var communication_style := StyleBoxFlat.new()
	communication_style.bg_color = Color("#090c11", 0.94)
	communication_style.border_color = Color("#718198", 0.86)
	communication_style.set_border_width_all(1)
	communication_style.border_width_left = 3
	communication_style.set_corner_radius_all(6)
	communication_style.content_margin_left = 14
	communication_style.content_margin_right = 14
	communication_style.content_margin_top = 7
	communication_style.content_margin_bottom = 7
	_communication_badge.add_theme_stylebox_override("panel", communication_style)
	add_child(_communication_badge)

	_communication_label = Label.new()
	_communication_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_communication_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_register_story_font(_communication_label, "font_size", 12)
	_communication_label.add_theme_color_override("font_color", Color("#c4cfde"))
	_apply_font(_communication_label, true)
	_communication_badge.add_child(_communication_label)

	# 6. 이름표 — 텍스트 박스(상단 -250) 위에 완전히 올림
	var name_panel = PanelContainer.new()
	name_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	name_panel.offset_left = 64
	name_panel.offset_top = -294
	name_panel.offset_bottom = -256
	name_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var name_style = StyleBoxFlat.new()
	name_style.bg_color = Color("#121318", 0.96)
	name_style.border_color = Color("#343841")
	name_style.set_border_width_all(1)
	name_style.border_width_left = 3
	name_style.set_corner_radius_all(6)
	name_style.content_margin_left = 18
	name_style.content_margin_right = 18
	name_style.content_margin_top = 5
	name_style.content_margin_bottom = 5
	name_panel.add_theme_stylebox_override("panel", name_style)
	add_child(name_panel)
	_name_tag = Label.new()
	_register_story_font(_name_tag, "font_size", 18)
	_name_tag.add_theme_color_override("font_color", Color("#e6e8ec"))
	_apply_font(_name_tag, true)
	name_panel.add_child(_name_tag)
	_name_panel = name_panel
	name_panel.visible = false

	# 7. 하단 텍스트 박스 — 고정 높이 (타이핑해도 흔들리지 않음)
	# PanelContainer(자식 크기 추종) 대신 고정 Panel + 절대 배치 사용.
	var text_panel = Panel.new()
	text_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	text_panel.offset_left = 50
	text_panel.offset_right = -50
	text_panel.offset_top = -250
	text_panel.offset_bottom = -40
	text_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color("#0d0d10", 0.92)
	panel_style.border_color = Color("#30343a")
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(8)
	text_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(text_panel)
	_text_panel = text_panel  # 챕터 카드 시 숨기기 위해 참조 보관

	_text_rule = ColorRect.new()
	_text_rule.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_text_rule.offset_left = 36
	_text_rule.offset_right = -36
	_text_rule.offset_top = 39
	_text_rule.offset_bottom = 40
	_text_rule.color = Color("#30343a", 0.75)
	_text_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_panel.add_child(_text_rule)

	# 제목 (이벤트 타이틀, 작게) — 박스 좌상단 고정
	_title_lbl = Label.new()
	_title_lbl.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_title_lbl.offset_left = 36
	_title_lbl.offset_top = 18
	_title_lbl.offset_right = -36
	_register_story_font(_title_lbl, "font_size", 13)
	_title_lbl.add_theme_color_override("font_color", Color(C_DIM))
	_title_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_font(_title_lbl)
	text_panel.add_child(_title_lbl)

	# 본문 (타이핑) — 박스 안 고정 영역. fit_content 끔 → 높이 불변.
	_body_lbl = RichTextLabel.new()
	_body_lbl.bbcode_enabled = true
	_body_lbl.fit_content = false
	_body_lbl.scroll_active = false
	_body_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	_body_lbl.offset_left = 36
	_body_lbl.offset_top = 44
	_body_lbl.offset_right = -36
	_body_lbl.offset_bottom = -34
	_register_story_font(_body_lbl, "normal_font_size", 20)
	_body_lbl.add_theme_color_override("default_color", Color(C_NARRATION))
	if _font:
		_body_lbl.add_theme_font_override("normal_font", _font)
	_body_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_panel.add_child(_body_lbl)

	# 계속 힌트 — 박스 우하단 고정
	_continue_hint = Label.new()
	_continue_hint.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_continue_hint.offset_left = -620
	_continue_hint.offset_top = -28
	_continue_hint.offset_right = -16
	_continue_hint.offset_bottom = -8
	_continue_hint.text = _tr("▼  Enter 또는 클릭", "▼  Enter or click")
	_register_story_font(_continue_hint, "font_size", 12)
	_continue_hint.add_theme_color_override("font_color", Color("#4a5468"))
	_continue_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_continue_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_font(_continue_hint)
	_continue_hint.visible = false
	text_panel.add_child(_continue_hint)

	# VN 본문 자동 재생. 선택지와 챕터 카드는 자동으로 확정하지 않는다.
	_auto_button = Button.new()
	_auto_button.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_auto_button.offset_left = 34
	_auto_button.offset_top = -30
	_auto_button.offset_right = 142
	_auto_button.offset_bottom = -7
	_auto_button.focus_mode = Control.FOCUS_NONE
	_register_story_font(_auto_button, "font_size", 11)
	_auto_button.add_theme_color_override("font_color", Color("#6f7886"))
	_auto_button.add_theme_color_override("font_hover_color", Color("#dce3eb"))
	var auto_normal := StyleBoxFlat.new()
	auto_normal.bg_color = Color("#0a0c10", 0.72)
	auto_normal.border_color = Color("#343a43", 0.78)
	auto_normal.set_border_width_all(1)
	auto_normal.set_corner_radius_all(2)
	var auto_hover := auto_normal.duplicate()
	auto_hover.bg_color = Color("#171b21", 0.92)
	auto_hover.border_color = Color("#788390")
	_auto_button.add_theme_stylebox_override("normal", auto_normal)
	_auto_button.add_theme_stylebox_override("hover", auto_hover)
	_auto_button.add_theme_stylebox_override("pressed", auto_hover)
	if _font_bold:
		_auto_button.add_theme_font_override("font", _font_bold)
	_auto_button.pressed.connect(func(): _set_auto_mode(not _auto_mode))
	text_panel.add_child(_auto_button)
	_refresh_auto_button()

	# 8. 선택지 도크 — 읽던 대화창을 접고 같은 하단 안전영역을 사용한다.
	# 배경과 인물을 동시에 가리는 두 겹 UI를 만들지 않는다.
	_choice_box = VBoxContainer.new()
	_choice_box.anchor_left = 0.08
	_choice_box.anchor_right = 0.74
	_choice_box.anchor_top = 1.0
	_choice_box.anchor_bottom = 1.0
	_choice_box.offset_left = 0
	_choice_box.offset_right = 0
	_choice_box.offset_top = -388
	_choice_box.offset_bottom = -48
	_choice_box.add_theme_constant_override("separation", 10)
	_choice_box.alignment = BoxContainer.ALIGNMENT_END
	_choice_box.visible = false
	add_child(_choice_box)

	# 9. 토스트 레이어 (스탯/관계 변화 노출) — 우측 상단 (HUD 아래로)
	_toast_layer = VBoxContainer.new()
	_toast_layer.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_toast_layer.offset_left = -340
	_toast_layer.offset_top = 50
	_toast_layer.offset_right = -24
	_toast_layer.add_theme_constant_override("separation", 6)
	_toast_layer.alignment = BoxContainer.ALIGNMENT_END
	_toast_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_toast_layer)

	# 10. 얇은 상단 HUD — 드라마 모드의 스테이크(자산/30억·돈·컨디션·시간) 상시 표시
	var hud_panel = Panel.new()
	_hud_panel = hud_panel
	hud_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hud_panel.offset_top = 0
	hud_panel.offset_bottom = 38
	hud_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hud_style = StyleBoxFlat.new()
	hud_style.bg_color = Color("#0b0c10", 0.86)
	hud_style.border_color = Color("#2e3239")
	hud_style.border_width_bottom = 1
	hud_panel.add_theme_stylebox_override("panel", hud_style)
	add_child(hud_panel)
	_hud_label = Label.new()
	_hud_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hud_label.offset_left = 24
	_hud_label.offset_right = -126
	_hud_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_register_story_font(_hud_label, "font_size", 14)
	_hud_label.add_theme_color_override("font_color", Color("#aeb6c8"))
	_hud_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_font(_hud_label)
	hud_panel.add_child(_hud_label)
	_build_story_audio_settings_button()
	_apply_story_surface_palette(false, true)
	_build_story_ink_transition_layer()

func _build_story_audio_settings_button() -> void:
	_audio_settings_button = Button.new()
	_audio_settings_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_audio_settings_button.offset_left = -108
	_audio_settings_button.offset_top = 5
	_audio_settings_button.offset_right = -14
	_audio_settings_button.offset_bottom = 33
	_audio_settings_button.text = _tr("설정", "Settings")
	_audio_settings_button.tooltip_text = _tr(
		"장면 설정 (%s)" % ControllerHints.start_btn(),
		"Scene settings (%s)" % ControllerHints.start_btn())
	_audio_settings_button.focus_mode = Control.FOCUS_NONE
	_audio_settings_button.z_index = 74
	_audio_settings_button.add_theme_font_size_override("font_size", 12)
	_audio_settings_button.add_theme_color_override("font_color", Color("#b8c0cc"))
	_audio_settings_button.add_theme_color_override("font_hover_color", Color("#f1f4f8"))
	if _font_bold:
		_audio_settings_button.add_theme_font_override("font", _font_bold)
	var normal := _story_panel_style(Color("#0a0c10", 0.82), Color("#343a43", 0.88), 4, 12, 4)
	var hover := normal.duplicate()
	hover.bg_color = Color("#171b21", 0.96)
	hover.border_color = Color("#8a949f")
	_audio_settings_button.add_theme_stylebox_override("normal", normal)
	_audio_settings_button.add_theme_stylebox_override("hover", hover)
	_audio_settings_button.add_theme_stylebox_override("pressed", hover)
	_audio_settings_button.pressed.connect(_open_audio_settings)
	add_child(_audio_settings_button)

func _open_audio_settings() -> void:
	if is_instance_valid(_audio_settings_popup):
		return
	_audio_settings_previous_focus = get_viewport().gui_get_focus_owner()
	_pause_story_countdown_for_settings()
	_create_story_settings_popup("text:%s" % _story_text_size, true)

func _create_story_settings_popup(focus_key: String, play_open_sound: bool) -> void:
	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.66)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 120
	add_child(overlay)
	_audio_settings_popup = overlay
	overlay.tree_exited.connect(func():
		if _audio_settings_popup == overlay:
			_audio_settings_popup = null)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -330
	panel.offset_right = 330
	panel.offset_top = -285
	panel.offset_bottom = 285
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var palette := _story_palette()
	panel.add_theme_stylebox_override("panel", _story_panel_style(
		palette["panel_bg"], palette["panel_border"], 7, 30, 24, 3))
	overlay.add_child(panel)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	panel.add_child(column)
	var title := Label.new()
	title.text = _tr("장면 설정", "Scene Settings")
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", palette["focus"])
	if _font_bold:
		title.add_theme_font_override("font", _font_bold)
	column.add_child(title)

	var separator := HSeparator.new()
	separator.modulate = palette["line"]
	column.add_child(separator)
	_story_text_size_buttons = _add_story_segmented_row(
		column,
		_tr("글자 크기", "Text Size"),
		[
			{"key": "small", "label": _tr("작게", "Small")},
			{"key": "standard", "label": _tr("기본", "Default")},
			{"key": "large", "label": _tr("크게", "Large")},
		],
		_story_text_size,
		func(level: String): _set_story_text_size(level))
	_story_text_speed_buttons = _add_story_segmented_row(
		column,
		_tr("출력 속도", "Text Speed"),
		[
			{"key": "slow", "label": _tr("느리게", "Slow")},
			{"key": "standard", "label": _tr("보통", "Normal")},
			{"key": "fast", "label": _tr("빠르게", "Fast")},
		],
		_story_text_speed,
		func(level: String): _set_story_text_speed(level))
	_story_language_buttons = _add_story_segmented_row(
		column,
		_tr("언어", "Language"),
		_story_language_options(),
		LocaleManager.language,
		func(lang: String): _set_story_language(lang))
	_audio_bgm_slider = _add_story_volume_row(
		column, _tr("음악 / 환경음", "Music / Ambience"), AudioManager.bgm_volume,
		func(value: float): AudioManager.set_bgm_volume(value))
	_audio_sfx_slider = _add_story_volume_row(
		column, _tr("효과음", "Sound Effects"), AudioManager.master_volume,
		func(value: float): AudioManager.set_sfx_volume(value))
	_audio_reduce_motion_toggle = _add_story_toggle_row(
		column,
		_tr("동작 감소", "Reduce Motion"),
		_tr("카메라·초상·날씨 움직임 최소화", "Minimize camera, portrait, and weather motion"),
		bool(SaveManager.get_setting("reduce_motion", false)),
		func(on: bool):
			SaveManager.set_setting("reduce_motion", on)
			_configure_living_scene())

	var save_load_button := Button.new()
	save_load_button.text = _tr("저장 / 불러오기  ›", "Save / Load  ›")
	save_load_button.custom_minimum_size = Vector2(0, 42)
	save_load_button.focus_mode = Control.FOCUS_ALL
	save_load_button.add_theme_font_size_override("font_size", 16)
	if _font_bold:
		save_load_button.add_theme_font_override("font", _font_bold)
	var save_normal := _story_panel_style(
		palette["choice_bg"], palette["panel_border"], 5, 16, 8)
	var save_focus := save_normal.duplicate()
	save_focus.bg_color = palette["choice_hover"]
	save_focus.border_color = palette["focus"]
	save_focus.set_border_width_all(2)
	save_load_button.add_theme_stylebox_override("normal", save_normal)
	save_load_button.add_theme_stylebox_override("hover", save_focus)
	save_load_button.add_theme_stylebox_override("focus", save_focus)
	save_load_button.add_theme_stylebox_override("pressed", save_focus)
	save_load_button.pressed.connect(_open_story_save_load)
	column.add_child(save_load_button)

	var close_button := Button.new()
	close_button.text = _tr("닫기", "Close")
	close_button.custom_minimum_size = Vector2(0, 42)
	close_button.focus_mode = Control.FOCUS_ALL
	close_button.add_theme_font_size_override("font_size", 16)
	if _font_bold:
		close_button.add_theme_font_override("font", _font_bold)
	var close_normal := _story_panel_style(palette["choice_bg"], palette["panel_border"], 5, 16, 8)
	var close_focus := close_normal.duplicate()
	close_focus.bg_color = palette["choice_hover"]
	close_focus.border_color = palette["focus"]
	close_focus.set_border_width_all(2)
	close_button.add_theme_stylebox_override("normal", close_normal)
	close_button.add_theme_stylebox_override("hover", close_focus)
	close_button.add_theme_stylebox_override("focus", close_focus)
	close_button.add_theme_stylebox_override("pressed", close_focus)
	close_button.pressed.connect(_close_audio_settings)
	column.add_child(close_button)

	_wire_story_settings_focus(save_load_button, close_button, focus_key)
	if play_open_sound:
		AudioManager.play_ui_open(-12.0)

	var close_from_backdrop := func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			_close_audio_settings()
	overlay.gui_input.connect(close_from_backdrop)

func _add_story_segmented_row(
		parent: Control,
		label_text: String,
		options: Array,
		selected_key: String,
		on_select: Callable) -> Dictionary:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 48)
	row.add_theme_constant_override("separation", 14)
	parent.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(160, 0)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", _story_palette()["text"])
	if _font:
		label.add_theme_font_override("font", _font)
	row.add_child(label)

	var segments := HBoxContainer.new()
	segments.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	segments.add_theme_constant_override("separation", 8)
	row.add_child(segments)
	var group := ButtonGroup.new()
	group.allow_unpress = false
	var buttons: Dictionary = {}
	var palette := _story_palette()
	for raw_option in options:
		var option: Dictionary = raw_option
		var key := str(option.get("key", ""))
		var button := Button.new()
		button.text = str(option.get("label", key))
		button.toggle_mode = true
		button.button_group = group
		button.button_pressed = key == selected_key
		button.focus_mode = Control.FOCUS_ALL
		button.custom_minimum_size = Vector2(0, 40)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 16)
		if _font_bold:
			button.add_theme_font_override("font", _font_bold)
		var normal := _story_panel_style(
			palette["choice_bg"], palette["panel_border"], 4, 12, 7)
		var hover := normal.duplicate()
		hover.bg_color = palette["choice_hover"]
		hover.border_color = palette["focus"]
		var active := hover.duplicate()
		active.border_width_bottom = 3
		button.add_theme_stylebox_override("normal", normal)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("focus", hover)
		button.add_theme_stylebox_override("pressed", active)
		button.add_theme_color_override("font_color", palette["dim"])
		button.add_theme_color_override("font_hover_color", palette["focus"])
		button.add_theme_color_override("font_focus_color", palette["focus"])
		button.add_theme_color_override("font_pressed_color", palette["focus"])
		button.set_meta("segment_key", key)
		button.pressed.connect(on_select.bind(key))
		segments.add_child(button)
		buttons[key] = button
	return buttons

func _wire_story_settings_focus(
		save_load_button: Button, close_button: Button, focus_key: String) -> void:
	var text_buttons: Array[Button] = []
	for level in STORY_TEXT_SIZE_LEVELS:
		var text_button: Button = _story_text_size_buttons.get(level) as Button
		if is_instance_valid(text_button):
			text_buttons.append(text_button)
	var speed_buttons: Array[Button] = []
	for level in STORY_TEXT_SPEED_LEVELS:
		var speed_button: Button = _story_text_speed_buttons.get(level) as Button
		if is_instance_valid(speed_button):
			speed_buttons.append(speed_button)
	var language_buttons: Array[Button] = []
	for lang in LocaleManager.get_selectable_languages():
		var language_button: Button = _story_language_buttons.get(lang) as Button
		if is_instance_valid(language_button):
			language_buttons.append(language_button)
	for index in range(text_buttons.size()):
		var button := text_buttons[index]
		button.focus_neighbor_left = text_buttons[maxi(0, index - 1)].get_path()
		button.focus_neighbor_right = text_buttons[mini(text_buttons.size() - 1, index + 1)].get_path()
		button.focus_neighbor_top = close_button.get_path()
		button.focus_neighbor_bottom = speed_buttons[mini(speed_buttons.size() - 1, index)].get_path()
	for index in range(speed_buttons.size()):
		var button := speed_buttons[index]
		button.focus_neighbor_left = speed_buttons[maxi(0, index - 1)].get_path()
		button.focus_neighbor_right = speed_buttons[mini(speed_buttons.size() - 1, index + 1)].get_path()
		button.focus_neighbor_top = text_buttons[mini(text_buttons.size() - 1, index)].get_path()
		button.focus_neighbor_bottom = language_buttons[mini(language_buttons.size() - 1, index)].get_path()
	for index in range(language_buttons.size()):
		var button := language_buttons[index]
		button.focus_neighbor_left = language_buttons[maxi(0, index - 1)].get_path()
		button.focus_neighbor_right = language_buttons[mini(language_buttons.size() - 1, index + 1)].get_path()
		button.focus_neighbor_top = speed_buttons[mini(speed_buttons.size() - 1, index)].get_path()
		button.focus_neighbor_bottom = _audio_bgm_slider.get_path()
	_audio_bgm_slider.focus_neighbor_top = language_buttons[0].get_path()
	_audio_bgm_slider.focus_neighbor_bottom = _audio_sfx_slider.get_path()
	_audio_sfx_slider.focus_neighbor_top = _audio_bgm_slider.get_path()
	_audio_sfx_slider.focus_neighbor_bottom = _audio_reduce_motion_toggle.get_path()
	_audio_reduce_motion_toggle.focus_neighbor_top = _audio_sfx_slider.get_path()
	_audio_reduce_motion_toggle.focus_neighbor_bottom = save_load_button.get_path()
	save_load_button.focus_neighbor_top = _audio_reduce_motion_toggle.get_path()
	save_load_button.focus_neighbor_bottom = close_button.get_path()
	close_button.focus_neighbor_top = save_load_button.get_path()
	close_button.focus_neighbor_bottom = text_buttons[0].get_path()
	var focus_control := _story_settings_focus_control(
		focus_key, save_load_button, close_button)
	if is_instance_valid(focus_control):
		focus_control.call_deferred("grab_focus")

func _story_settings_focus_control(
		focus_key: String, save_load_button: Button, close_button: Button) -> Control:
	if focus_key.begins_with("text:"):
		return _story_text_size_buttons.get(focus_key.trim_prefix("text:")) as Control
	if focus_key.begins_with("speed:"):
		return _story_text_speed_buttons.get(focus_key.trim_prefix("speed:")) as Control
	if focus_key.begins_with("language:"):
		return _story_language_buttons.get(focus_key.trim_prefix("language:")) as Control
	match focus_key:
		"bgm": return _audio_bgm_slider
		"sfx": return _audio_sfx_slider
		"motion": return _audio_reduce_motion_toggle
		"save": return save_load_button
		"close": return close_button
	return _story_text_size_buttons.get(_story_text_size) as Control

func _add_story_volume_row(
		parent: Control, label_text: String, initial_value: float, on_change: Callable) -> HSlider:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 50)
	row.add_theme_constant_override("separation", 14)
	parent.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(142, 0)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", _story_palette()["text"])
	if _font:
		label.add_theme_font_override("font", _font)
	row.add_child(label)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = initial_value
	slider.custom_minimum_size = Vector2(260, 42)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.focus_mode = Control.FOCUS_ALL
	var slider_focus := StyleBoxFlat.new()
	slider_focus.bg_color = Color(0, 0, 0, 0)
	slider_focus.border_color = _story_palette()["focus"]
	slider_focus.set_border_width_all(2)
	slider_focus.set_corner_radius_all(4)
	slider_focus.content_margin_left = 8
	slider_focus.content_margin_right = 8
	slider.add_theme_stylebox_override("focus", slider_focus)
	row.add_child(slider)
	var value_label := Label.new()
	value_label.text = "%d%%" % int(roundf(initial_value * 100.0))
	value_label.custom_minimum_size = Vector2(48, 0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	value_label.add_theme_font_size_override("font_size", 15)
	value_label.add_theme_color_override("font_color", _story_palette()["dim"])
	if _font:
		value_label.add_theme_font_override("font", _font)
	row.add_child(value_label)
	slider.value_changed.connect(func(value: float):
		value_label.text = "%d%%" % int(roundf(value * 100.0))
		on_change.call(value))
	return slider

func _add_story_toggle_row(
		parent: Control,
		label_text: String,
		hint_text: String,
		initial_value: bool,
		on_change: Callable) -> CheckButton:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 54)
	row.add_theme_constant_override("separation", 14)
	parent.add_child(row)
	var copy := VBoxContainer.new()
	copy.custom_minimum_size = Vector2(400, 0)
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_theme_constant_override("separation", 2)
	row.add_child(copy)
	var label := Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", _story_palette()["text"])
	if _font:
		label.add_theme_font_override("font", _font)
	copy.add_child(label)
	var hint := Label.new()
	hint.text = hint_text
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", _story_palette()["dim"])
	if _font:
		hint.add_theme_font_override("font", _font)
	copy.add_child(hint)
	var toggle := CheckButton.new()
	toggle.custom_minimum_size = Vector2(58, 46)
	toggle.button_pressed = initial_value
	toggle.focus_mode = Control.FOCUS_ALL
	toggle.set_meta("reduce_motion_control", true)
	toggle.toggled.connect(func(on: bool): on_change.call(on))
	row.add_child(toggle)
	return toggle

func _close_audio_settings() -> void:
	if not is_instance_valid(_audio_settings_popup):
		_audio_settings_popup = null
		return
	var popup := _audio_settings_popup
	_audio_settings_popup = null
	_audio_bgm_slider = null
	_audio_sfx_slider = null
	_audio_reduce_motion_toggle = null
	_story_text_size_buttons.clear()
	_story_text_speed_buttons.clear()
	_story_language_buttons.clear()
	popup.queue_free()
	_resume_story_countdown_after_settings()
	AudioManager.play_ui_close(-14.0)
	if is_instance_valid(_audio_settings_previous_focus):
		_audio_settings_previous_focus.call_deferred("grab_focus")
	_audio_settings_previous_focus = null
	_settings_focus_key = ""

func _rebuild_story_settings_popup(focus_key: String) -> void:
	if not is_instance_valid(_audio_settings_popup):
		return
	var old_popup := _audio_settings_popup
	_audio_settings_popup = null
	_audio_bgm_slider = null
	_audio_sfx_slider = null
	_audio_reduce_motion_toggle = null
	_story_text_size_buttons.clear()
	_story_text_speed_buttons.clear()
	_story_language_buttons.clear()
	old_popup.queue_free()
	_create_story_settings_popup(focus_key, false)

func _open_story_save_load() -> void:
	if not is_instance_valid(_audio_settings_popup):
		return
	_story_save_page = 0
	_story_save_notice = ""
	_replace_story_popup_with_save_page()

func _replace_story_popup_with_save_page() -> void:
	if is_instance_valid(_audio_settings_popup):
		var old_popup := _audio_settings_popup
		_audio_settings_popup = null
		_audio_bgm_slider = null
		_audio_sfx_slider = null
		_audio_reduce_motion_toggle = null
		_story_text_size_buttons.clear()
		_story_text_speed_buttons.clear()
		_story_language_buttons.clear()
		old_popup.queue_free()
	_create_story_save_popup()

func _create_story_save_popup() -> void:
	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.72)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 120
	add_child(overlay)
	_audio_settings_popup = overlay
	overlay.tree_exited.connect(func():
		if _audio_settings_popup == overlay:
			_audio_settings_popup = null)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -445
	panel.offset_right = 445
	panel.offset_top = -280
	panel.offset_bottom = 280
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var palette := _story_palette()
	panel.add_theme_stylebox_override("panel", _story_panel_style(
		palette["panel_bg"], palette["panel_border"], 7, 26, 20, 3))
	overlay.add_child(panel)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 9)
	panel.add_child(column)
	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 42)
	header.add_theme_constant_override("separation", 12)
	column.add_child(header)
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(titles)
	var title := Label.new()
	title.text = _tr("이야기 기록", "Story Records")
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", palette["focus"])
	if _font_bold:
		title.add_theme_font_override("font", _font_bold)
	titles.add_child(title)
	var note := Label.new()
	note.text = _tr(
		"현재 문단과 선택 대기 상태까지 기록됩니다.",
		"Saves the current paragraph and pending choice.")
	note.add_theme_font_size_override("font_size", 13)
	note.add_theme_color_override("font_color", palette["dim"])
	if _font:
		note.add_theme_font_override("font", _font)
	titles.add_child(note)
	var page_label := Label.new()
	page_label.text = "%d–%d / %d" % [
		_story_save_page * 5 + 1,
		mini(SaveManager.SLOT_COUNT, _story_save_page * 5 + 5),
		SaveManager.SLOT_COUNT,
	]
	page_label.custom_minimum_size = Vector2(116, 0)
	page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	page_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	page_label.add_theme_font_size_override("font_size", 14)
	page_label.add_theme_color_override("font_color", palette["dim"])
	if _font_bold:
		page_label.add_theme_font_override("font", _font_bold)
	header.add_child(page_label)

	var pager := HBoxContainer.new()
	pager.add_theme_constant_override("separation", 8)
	column.add_child(pager)
	for page in range(2):
		var page_button := Button.new()
		page_button.text = _tr(
			"슬롯 %d–%d" % [page * 5 + 1, page * 5 + 5],
			"Slots %d–%d" % [page * 5 + 1, page * 5 + 5])
		page_button.toggle_mode = true
		page_button.button_pressed = page == _story_save_page
		page_button.disabled = page == _story_save_page
		page_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		page_button.custom_minimum_size = Vector2(0, 34)
		page_button.focus_mode = Control.FOCUS_ALL
		page_button.add_theme_font_size_override("font_size", 14)
		var page_normal := _story_panel_style(
			palette["choice_bg"], palette["panel_border"], 4, 10, 5)
		var page_focus := page_normal.duplicate()
		page_focus.bg_color = palette["choice_hover"]
		page_focus.border_color = palette["focus"]
		page_button.add_theme_stylebox_override("normal", page_normal)
		page_button.add_theme_stylebox_override("hover", page_focus)
		page_button.add_theme_stylebox_override("focus", page_focus)
		page_button.add_theme_stylebox_override("pressed", page_focus)
		page_button.pressed.connect(_set_story_save_page.bind(page))
		pager.add_child(page_button)

	var list := VBoxContainer.new()
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 7)
	column.add_child(list)
	var first_slot := _story_save_page * 5 + 1
	for slot in range(first_slot, mini(SaveManager.SLOT_COUNT + 1, first_slot + 5)):
		_add_story_save_slot_row(list, slot, palette)

	var notice := Label.new()
	notice.text = _story_save_notice
	notice.custom_minimum_size = Vector2(0, 20)
	notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notice.add_theme_font_size_override("font_size", 13)
	notice.add_theme_color_override("font_color", palette["focus"])
	if _font:
		notice.add_theme_font_override("font", _font)
	column.add_child(notice)

	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 10)
	column.add_child(bottom)
	var settings_button := Button.new()
	settings_button.text = _tr("‹ 장면 설정", "‹ Scene Settings")
	settings_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_button.custom_minimum_size = Vector2(0, 40)
	settings_button.focus_mode = Control.FOCUS_ALL
	settings_button.pressed.connect(_return_to_story_settings)
	bottom.add_child(settings_button)
	var close_button := Button.new()
	close_button.text = _tr("닫기", "Close")
	close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close_button.custom_minimum_size = Vector2(0, 40)
	close_button.focus_mode = Control.FOCUS_ALL
	close_button.pressed.connect(_close_audio_settings)
	bottom.add_child(close_button)
	for button in [settings_button, close_button]:
		button.add_theme_font_size_override("font_size", 15)
		if _font_bold:
			button.add_theme_font_override("font", _font_bold)
		var normal := _story_panel_style(
			palette["choice_bg"], palette["panel_border"], 5, 14, 7)
		var focus := normal.duplicate()
		focus.bg_color = palette["choice_hover"]
		focus.border_color = palette["focus"]
		focus.set_border_width_all(2)
		button.add_theme_stylebox_override("normal", normal)
		button.add_theme_stylebox_override("hover", focus)
		button.add_theme_stylebox_override("focus", focus)
		button.add_theme_stylebox_override("pressed", focus)

	overlay.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			_close_audio_settings())
	call_deferred("_focus_first_story_save_control")

func _add_story_save_slot_row(
		parent: Control, slot: int, palette: Dictionary) -> void:
	var info := SaveManager.get_save_info(slot)
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 58)
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	var record := PanelContainer.new()
	record.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	record.add_theme_stylebox_override("panel", _story_panel_style(
		palette["choice_bg"], palette["panel_border"], 4, 14, 7, 3))
	row.add_child(record)
	var record_row := HBoxContainer.new()
	record_row.add_theme_constant_override("separation", 12)
	record.add_child(record_row)
	var slot_label := Label.new()
	slot_label.text = "%02d" % slot
	slot_label.custom_minimum_size = Vector2(38, 0)
	slot_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	slot_label.add_theme_font_size_override("font_size", 17)
	slot_label.add_theme_color_override("font_color", palette["focus"])
	if _font_bold:
		slot_label.add_theme_font_override("font", _font_bold)
	record_row.add_child(slot_label)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.alignment = BoxContainer.ALIGNMENT_CENTER
	copy.add_theme_constant_override("separation", 2)
	record_row.add_child(copy)
	var primary := Label.new()
	var secondary := Label.new()
	if bool(info.get("empty", true)):
		primary.text = _tr("빈 기록", "Empty record")
		secondary.text = _tr("현재 장면을 저장할 수 있습니다.", "Save the current scene here.")
	else:
		var label := str(info.get("label", "")).strip_edges()
		primary.text = label if not label.is_empty() else _tr(
			"챕터 %d · %d주차" % [int(info.get("chapter", 1)), int(info.get("turn", 1))],
			"Chapter %d · Week %d" % [int(info.get("chapter", 1)), int(info.get("turn", 1))])
		secondary.text = _tr(
			"%d년 %d월 · 자산 %s" % [
				int(info.get("year", 2026)), int(info.get("month", 1)),
				_story_money(float(info.get("total_assets", 0.0)))],
			"%d / %02d · Assets %s" % [
				int(info.get("year", 2026)), int(info.get("month", 1)),
				_story_money(float(info.get("total_assets", 0.0)))])
		if bool(info.get("qa_fixture", false)):
			secondary.text += _tr(" · 테스트 기록", " · QA record")
	primary.add_theme_font_size_override("font_size", 14)
	primary.add_theme_color_override("font_color", palette["text"])
	primary.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	secondary.add_theme_font_size_override("font_size", 12)
	secondary.add_theme_color_override("font_color", palette["dim"])
	secondary.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	if _font:
		primary.add_theme_font_override("font", _font)
		secondary.add_theme_font_override("font", _font)
	copy.add_child(primary)
	copy.add_child(secondary)

	var save_button := Button.new()
	save_button.text = _tr("저장", "Save")
	save_button.custom_minimum_size = Vector2(78, 58)
	save_button.focus_mode = Control.FOCUS_ALL
	save_button.disabled = not can_manual_save_story()
	save_button.set_meta("story_save_control", true)
	save_button.pressed.connect(_save_story_to_slot.bind(slot))
	row.add_child(save_button)
	var load_button := Button.new()
	load_button.text = _tr("불러오기", "Load")
	load_button.custom_minimum_size = Vector2(92, 58)
	load_button.focus_mode = Control.FOCUS_ALL
	load_button.disabled = bool(info.get("empty", true))
	load_button.set_meta("story_load_control", true)
	load_button.pressed.connect(_load_story_from_slot.bind(slot))
	row.add_child(load_button)
	for button in [save_button, load_button]:
		button.add_theme_font_size_override("font_size", 14)
		if _font_bold:
			button.add_theme_font_override("font", _font_bold)
		var normal := _story_panel_style(
			palette["choice_bg"], palette["panel_border"], 4, 10, 7)
		var focus := normal.duplicate()
		focus.bg_color = palette["choice_hover"]
		focus.border_color = palette["focus"]
		focus.set_border_width_all(2)
		var disabled := normal.duplicate()
		disabled.bg_color = palette["choice_bg"].darkened(0.18)
		disabled.border_color = palette["panel_border"].darkened(0.20)
		button.add_theme_stylebox_override("normal", normal)
		button.add_theme_stylebox_override("hover", focus)
		button.add_theme_stylebox_override("focus", focus)
		button.add_theme_stylebox_override("pressed", focus)
		button.add_theme_stylebox_override("disabled", disabled)

func _set_story_save_page(page: int) -> void:
	var clamped := clampi(page, 0, maxi(0, ceili(float(SaveManager.SLOT_COUNT) / 5.0) - 1))
	if clamped == _story_save_page:
		return
	_story_save_page = clamped
	_story_save_notice = ""
	AudioManager.play("click")
	_replace_story_popup_with_save_page()

func _save_story_to_slot(slot: int) -> void:
	var context := build_save_resume_context()
	if context.is_empty():
		_story_save_notice = _tr(
			"장면 전환 중이거나 회상 중에는 저장할 수 없습니다.",
			"Saving is unavailable during transitions or replay.")
		_replace_story_popup_with_save_page()
		return
	var event_title: String = _fmt(str(_current.get("title", ""))).strip_edges()
	var chapter := mini(5, floori(float(maxi(1, GameState.turn) - 1) / 48.0) + 1)
	var label := _tr(
		"챕터 %d · %s" % [chapter, event_title],
		"Chapter %d · %s" % [chapter, event_title])
	if SaveManager.save_game(slot, context, {"label": label, "qa_fixture": false}):
		_story_save_notice = _tr(
			"슬롯 %d에 현재 장면을 저장했습니다." % slot,
			"Current scene saved to slot %d." % slot)
		AudioManager.play("choice_made")
	else:
		_story_save_notice = _tr("저장에 실패했습니다.", "Save failed.")
	_replace_story_popup_with_save_page()

func _load_story_from_slot(slot: int) -> void:
	if not SaveManager.load_game(slot):
		_story_save_notice = _tr("불러오기에 실패했습니다.", "Load failed.")
		_replace_story_popup_with_save_page()
		return
	_transitioning = true
	_stop_story_choice_countdown()
	GameState.story_replay_mode = false
	SceneTransition.go(SaveManager.loaded_scene_path())

func _return_to_story_settings() -> void:
	if is_instance_valid(_audio_settings_popup):
		var old_popup := _audio_settings_popup
		_audio_settings_popup = null
		old_popup.queue_free()
	_create_story_settings_popup("save", false)

func _focus_first_story_save_control() -> void:
	if not is_instance_valid(_audio_settings_popup):
		return
	for node in _audio_settings_popup.find_children("*", "Button", true, false):
		if node is Button and bool((node as Button).get_meta("story_save_control", false)) \
				and not (node as Button).disabled:
			(node as Button).grab_focus()
			return

func _pause_story_countdown_for_settings() -> void:
	_settings_countdown_remaining_msec = -1
	_settings_countdown_total_msec = -1
	if _choice_countdown_deadline_msec <= 0:
		return
	_settings_countdown_remaining_msec = maxi(
		1, _choice_countdown_deadline_msec - Time.get_ticks_msec())
	_settings_countdown_total_msec = maxi(
		_settings_countdown_remaining_msec, _choice_countdown_total_msec)
	_stop_story_choice_countdown()

func _resume_story_countdown_after_settings() -> void:
	var remaining := _settings_countdown_remaining_msec
	var total := _settings_countdown_total_msec
	_settings_countdown_remaining_msec = -1
	_settings_countdown_total_msec = -1
	if remaining <= 0 or not _showing_choices or not bool(_current.get("timed", false)):
		return
	_start_story_choice_countdown_msec(remaining, _choice_countdown_default_index, total)

func can_manual_save_story() -> bool:
	return not _read_only_replay \
			and not _transitioning \
			and not _story_scene_transition_active \
			and not _current.is_empty()

func build_save_resume_context() -> Dictionary:
	if not can_manual_save_story():
		return {}
	var timer_remaining := -1
	var timer_total := -1
	if _settings_countdown_remaining_msec > 0:
		timer_remaining = _settings_countdown_remaining_msec
		timer_total = _settings_countdown_total_msec
	elif _choice_countdown_deadline_msec > 0:
		timer_remaining = maxi(1, _choice_countdown_deadline_msec - Time.get_ticks_msec())
		timer_total = maxi(timer_remaining, _choice_countdown_total_msec)
	return {
		"kind": "story",
		"scene": "res://scenes/StoryMode.tscn",
		"return_scene": GameState.story_return_scene if not GameState.story_return_scene.is_empty() \
				else "res://scenes/MainGame.tscn",
		"event_id": str(_current.get("id", "")),
		"queue": _queue.duplicate(true),
		"phase": _story_resume_phase(),
		"paragraph_index": _para_index,
		"paragraph_was_typing": _typing,
		"type_pos": _type_pos,
		"pending_result_choice_index": _pending_result_choice_index,
		"pending_follow_up": _pending_follow_up,
		"next_transition_mode": _next_transition_mode,
		"current_transition_mode": _current_transition_mode,
		"next_transition_contract": _next_transition_contract.duplicate(true),
		"current_transition_contract": _current_transition_contract.duplicate(true),
		"timer_remaining_msec": timer_remaining,
		"timer_total_msec": timer_total,
		"timer_default_choice": _choice_countdown_default_index,
	}

func _story_resume_phase() -> String:
	if _is_chapter_card:
		return "chapter"
	if _pending_after_result:
		return "result"
	if _showing_choices:
		return "choices"
	return "prose"

func _apply_story_resume_context(context: Dictionary) -> void:
	if str(context.get("event_id", "")) != str(_current.get("id", "")):
		push_warning("StoryMode: resume event no longer matches the loaded event.")
		return
	_next_transition_mode = str(context.get("next_transition_mode", ""))
	_current_transition_mode = str(context.get("current_transition_mode", ""))
	var next_transition_variant: Variant = context.get("next_transition_contract", {})
	_next_transition_contract = (
		(next_transition_variant as Dictionary).duplicate(true)
		if next_transition_variant is Dictionary else {})
	var current_transition_variant: Variant = context.get("current_transition_contract", {})
	_current_transition_contract = (
		(current_transition_variant as Dictionary).duplicate(true)
		if current_transition_variant is Dictionary else {})
	var phase := str(context.get("phase", "prose"))
	if phase == "chapter" or _is_chapter_card:
		return
	match phase:
		"choices":
			_restore_story_paragraph(context, false)
			_show_choices()
			if bool(_current.get("timed", false)) and not _read_only_replay:
				var remaining := int(context.get("timer_remaining_msec", -1))
				if remaining > 0:
					var total: int = maxi(remaining, int(context.get(
						"timer_total_msec", remaining)))
					_stop_story_choice_countdown()
					_start_story_choice_countdown_msec(
						remaining,
						int(context.get("timer_default_choice", 0)),
						total)
		"result":
			_restore_story_result(context)
		_:
			_restore_story_paragraph(context, false)

func _restore_story_result(context: Dictionary) -> void:
	var choices: Array = _current.get("choices", [])
	var choice_index := int(context.get("pending_result_choice_index", -1))
	if choice_index < 0 or choice_index >= choices.size():
		push_warning("StoryMode: result resume choice is no longer valid.")
		_pending_follow_up = ""
		_load_next_event()
		return
	var choice: Dictionary = choices[choice_index]
	_pending_result_choice_index = choice_index
	_pending_follow_up = str(context.get(
		"pending_follow_up", _choice_follow_up_id(
			choice, str(_current.get("id", "")), choice_index)))
	_pending_after_result = true
	_showing_choices = false
	_choice_box.visible = false
	_set_choice_dock_active(false)
	_set_portrait_choice_focus(false)
	_apply_choice_result_visual(choice)
	if _story_choice_has_visible_result(choice):
		_show_story_result_record(choice, false)
	var result: String = _fmt(str(choice.get("result_text", "")))
	_apply_story_page_data(_story_page_data(result))
	_restore_story_paragraph(context, true)

func _restore_story_paragraph(context: Dictionary, result_phase: bool) -> void:
	if _paragraphs.is_empty():
		return
	_para_index = clampi(int(context.get("paragraph_index", 0)), 0, _paragraphs.size() - 1)
	var source_paragraph_index := _story_source_paragraph_index(_para_index)
	_maybe_change_event_background(source_paragraph_index)
	_maybe_reveal_event_portrait(source_paragraph_index)
	_maybe_reveal_event_cg(source_paragraph_index)
	if result_phase:
		AudioManager.play_scene_result_paragraph_cues(
			str(_current.get("id", "")), _event_cg_id,
			_pending_result_choice_index, source_paragraph_index)
	else:
		_play_current_paragraph_audio(source_paragraph_index)
	var paragraph := str(_paragraphs[_para_index])
	var was_typing := bool(context.get("paragraph_was_typing", false))
	var saved_type_pos: int = clampi(int(context.get("type_pos", paragraph.length())),
		0, paragraph.length())
	_type_full = paragraph
	_auto_wait = -1.0
	if was_typing and saved_type_pos < paragraph.length():
		_start_typing(paragraph)
		_type_pos = saved_type_pos
		_body_lbl.text = paragraph.substr(0, saved_type_pos)
		return
	_type_pos = paragraph.length()
	_typing = false
	_body_lbl.text = paragraph
	_refresh_continue_hint_text()
	_continue_hint.visible = true
	_arm_auto_advance(paragraph)

func _build_story_ink_transition_layer() -> void:
	_story_ink_transition_layer = Control.new()
	_story_ink_transition_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_story_ink_transition_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_story_ink_transition_layer.visible = false
	_story_ink_transition_layer.z_index = 86
	_story_ink_transition_layer.draw.connect(_draw_story_ink_transition)
	add_child(_story_ink_transition_layer)

func _build_story_scene_transition_snapshots() -> void:
	_story_transition_snapshot = TextureRect.new()
	_story_transition_snapshot.name = "StoryTransitionBackground"
	_story_transition_snapshot.set_anchors_preset(Control.PRESET_FULL_RECT)
	_story_transition_snapshot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_story_transition_snapshot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_story_transition_snapshot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_story_transition_snapshot.visible = false
	add_child(_story_transition_snapshot)

	_story_transition_portrait_snapshot = TextureRect.new()
	_story_transition_portrait_snapshot.name = "StoryTransitionPortrait"
	_story_transition_portrait_snapshot.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_story_transition_portrait_snapshot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_story_transition_portrait_snapshot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_story_transition_portrait_snapshot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_story_transition_portrait_snapshot.visible = false
	add_child(_story_transition_portrait_snapshot)

func _normalized_story_scene_transition(mode: String) -> String:
	if mode in [
		"none", "same_location", "remote", "memory_cut", "time_cut",
		"explicit_move", "activity_enter_return", "finale",
	]:
		return mode
	return "none"

func _story_scene_transition_seconds(mode: String) -> float:
	if _living_reduced_motion():
		return 0.24
	match mode:
		"memory_cut":
			return 0.78
		"time_cut":
			return 0.86
		"finale":
			return 1.02
		"activity_enter_return":
			return 0.42
		"explicit_move":
			return 0.54
		_:
			return 0.0

func _capture_story_transition_snapshot() -> bool:
	if not is_instance_valid(_story_transition_snapshot) \
			or not is_instance_valid(_bg_img) or _bg_img.texture == null:
		return false
	_story_transition_snapshot.texture = _bg_img.texture
	_story_transition_snapshot.material = (
		_bg_img.material.duplicate(true) if _bg_img.material != null else null)
	_story_transition_snapshot.position = _bg_img.position
	_story_transition_snapshot.pivot_offset = _bg_img.pivot_offset
	_story_transition_snapshot.scale = _bg_img.scale
	_story_transition_snapshot_base_scale = _bg_img.scale
	_story_transition_snapshot.modulate = Color.WHITE
	_story_transition_snapshot.visible = true

	_story_transition_portrait_snapshot.visible = false
	_story_transition_portrait_snapshot.texture = null
	_story_transition_portrait_snapshot.material = null
	if is_instance_valid(_portrait_frame) and _portrait_frame.visible \
			and is_instance_valid(_portrait) and _portrait.texture != null:
		_story_transition_portrait_snapshot.texture = _portrait.texture
		_story_transition_portrait_snapshot.material = (
			_portrait.material.duplicate(true) if _portrait.material != null else null)
		_story_transition_portrait_snapshot.offset_left = _portrait_frame.offset_left
		_story_transition_portrait_snapshot.offset_right = _portrait_frame.offset_right
		_story_transition_portrait_snapshot.offset_top = _portrait_frame.offset_top
		_story_transition_portrait_snapshot.offset_bottom = _portrait_frame.offset_bottom
		_story_transition_portrait_snapshot.pivot_offset = _portrait_frame.pivot_offset
		_story_transition_portrait_snapshot.scale = _portrait_frame.scale
		_story_transition_portrait_base_scale = _portrait_frame.scale
		_story_transition_portrait_snapshot.modulate = Color(
			1.0, 1.0, 1.0, _portrait_frame.modulate.a)
		_story_transition_portrait_snapshot.visible = true
	return true

func _begin_story_scene_transition(mode: String) -> void:
	var normalized := _normalized_story_scene_transition(mode)
	if normalized in ["none", "same_location", "remote"]:
		_story_scene_transition_active = false
		return
	if not is_inside_tree() or not _capture_story_transition_snapshot():
		_story_scene_transition_active = false
		return
	if _story_ink_transition_tween and _story_ink_transition_tween.is_running():
		_story_ink_transition_tween.kill()
	_story_scene_transition_active = true
	_story_scene_transition_duration = _story_scene_transition_seconds(normalized)
	_story_ink_transition_kind = normalized
	_story_ink_transition_progress = 0.0
	_story_ink_transition_layer.visible = true
	_story_ink_transition_layer.queue_redraw()
	set_meta("story_transition_mode", normalized)
	set_meta("story_transition_duration", _story_scene_transition_duration)
	set_meta("story_transition_reduced_motion", _living_reduced_motion())
	_story_ink_transition_tween = create_tween()
	_story_ink_transition_tween.tween_method(
		_set_story_ink_transition_progress, 0.0, 1.0,
		_story_scene_transition_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_story_ink_transition_tween.tween_callback(_finish_story_scene_transition.bind(false))

func _finish_story_scene_transition(kill_tween: bool = true) -> void:
	if kill_tween and _story_ink_transition_tween and _story_ink_transition_tween.is_running():
		_story_ink_transition_tween.kill()
	_story_ink_transition_tween = null
	_story_scene_transition_active = false
	_story_scene_transition_duration = 0.0
	_story_ink_transition_progress = 0.0
	if is_instance_valid(_story_transition_snapshot):
		_story_transition_snapshot.visible = false
		_story_transition_snapshot.texture = null
		_story_transition_snapshot.material = null
		_story_transition_snapshot.scale = Vector2.ONE
		_story_transition_snapshot.modulate = Color.WHITE
	if is_instance_valid(_story_transition_portrait_snapshot):
		_story_transition_portrait_snapshot.visible = false
		_story_transition_portrait_snapshot.texture = null
		_story_transition_portrait_snapshot.material = null
		_story_transition_portrait_snapshot.scale = Vector2.ONE
		_story_transition_portrait_snapshot.modulate = Color.WHITE
	if is_instance_valid(_story_ink_transition_layer):
		_story_ink_transition_layer.visible = false
		_story_ink_transition_layer.queue_redraw()

func _play_story_ink_transition(kind: String = "scene", strength: float = 1.0) -> void:
	if not is_instance_valid(_story_ink_transition_layer) or not is_inside_tree():
		return
	if _story_scene_transition_active:
		_finish_story_scene_transition()
	if _story_ink_transition_tween and _story_ink_transition_tween.is_running():
		_story_ink_transition_tween.kill()
	_story_ink_transition_kind = kind
	_story_ink_transition_progress = 0.0
	_story_ink_transition_layer.visible = true
	_story_ink_transition_layer.queue_redraw()
	var duration := clampf(0.30 + strength * 0.10, 0.24, 0.48)
	_story_ink_transition_tween = create_tween()
	_story_ink_transition_tween.tween_method(_set_story_ink_transition_progress, 0.0, 1.0, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_story_ink_transition_tween.tween_callback(func():
		_story_ink_transition_progress = 0.0
		if is_instance_valid(_story_ink_transition_layer):
			_story_ink_transition_layer.visible = false
			_story_ink_transition_layer.queue_redraw()
		_story_ink_transition_tween = null
	)

func _set_story_ink_transition_progress(value: float) -> void:
	_story_ink_transition_progress = clampf(value, 0.0, 1.0)
	if _story_scene_transition_active and is_instance_valid(_story_transition_snapshot):
		var old_alpha := 1.0
		match _story_ink_transition_kind:
			"memory_cut":
				old_alpha = 1.0 - _story_transition_smooth(0.10, 0.92, _story_ink_transition_progress)
			"time_cut":
				old_alpha = 1.0 - _story_transition_smooth(0.43, 0.67, _story_ink_transition_progress)
			"finale":
				old_alpha = 1.0 - _story_transition_smooth(0.14, 0.94, _story_ink_transition_progress)
			_:
				old_alpha = 1.0 - _story_transition_smooth(0.04, 0.88, _story_ink_transition_progress)
		_story_transition_snapshot.modulate.a = old_alpha
		if is_instance_valid(_story_transition_portrait_snapshot):
			_story_transition_portrait_snapshot.modulate.a = old_alpha
		if _living_reduced_motion():
			_story_transition_snapshot.scale = _story_transition_snapshot_base_scale
			_story_transition_portrait_snapshot.scale = _story_transition_portrait_base_scale
		elif _story_ink_transition_kind == "memory_cut":
			var memory_breath := 1.0 + 0.012 * _story_transition_smooth(
				0.0, 1.0, _story_ink_transition_progress)
			_story_transition_snapshot.scale = _story_transition_snapshot_base_scale * memory_breath
			_story_transition_portrait_snapshot.scale = (
				_story_transition_portrait_base_scale * memory_breath)
	if is_instance_valid(_story_ink_transition_layer):
		_story_ink_transition_layer.queue_redraw()

func _story_transition_smooth(from_value: float, to_value: float, value: float) -> float:
	if is_equal_approx(from_value, to_value):
		return 1.0 if value >= to_value else 0.0
	var t := clampf((value - from_value) / (to_value - from_value), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)

func _draw_story_ink_transition() -> void:
	if not is_instance_valid(_story_ink_transition_layer) or _story_ink_transition_progress <= 0.01:
		return
	var size := _story_ink_transition_layer.size
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var pulse := sin(_story_ink_transition_progress * PI)
	var black := clampf(-_story_moral_norm, 0.0, 1.0)
	var white := clampf(_story_moral_norm, 0.0, 1.0)
	var base := Color("#08090c").lerp(Color("#020303"), black * 0.60).lerp(Color("#eef6ff"), white * 0.32)
	var overlay_alpha := pulse * (0.075 + black * 0.070 + white * 0.035)
	match _story_ink_transition_kind:
		"choice":
			base = base.lerp(Color("#111216"), 0.25)
		"memory_cut":
			base = Color("#c6c8c3").lerp(Color("#8f9290"), black * 0.32)
			overlay_alpha = pulse * 0.30
		"time_cut":
			base = Color("#050608").lerp(Color("#010202"), black * 0.50)
			overlay_alpha = pow(pulse, 0.48) * 0.94
		"explicit_move":
			base = Color("#090b0e").lerp(Color("#020303"), black * 0.42)
			overlay_alpha = pulse * 0.24
	_story_ink_transition_layer.draw_rect(
		Rect2(Vector2.ZERO, size),
		Color(base.r, base.g, base.b, overlay_alpha), true)

	var is_scene_handoff := _story_ink_transition_kind in [
		"memory_cut", "time_cut", "explicit_move", "activity_enter_return", "finale"]
	if black > 0.01 and not is_scene_handoff:
		var burn := Color("#000000", pulse * (0.065 + black * 0.11))
		_story_ink_transition_layer.draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, 18.0 + black * 16.0)), burn, true)
		_story_ink_transition_layer.draw_rect(Rect2(Vector2(0.0, size.y - 18.0 - black * 16.0), Vector2(size.x, 18.0 + black * 16.0)), burn, true)
	if white > 0.01 and not is_scene_handoff:
		_story_ink_transition_layer.draw_rect(Rect2(Vector2.ZERO, size), Color("#ffffff", pulse * white * 0.026), true)

func _refresh_hud():
	if _hud_label == null:
		return
	var assets: float = GameState.get_total_asset_value()
	var pct: int = clampi(int(assets / 3_000_000_000.0 * 100.0), 0, 100)
	var months_left: int = max(0, (38 - GameState.age) * 12 - GameState.month + 1)
	_hud_label.text = _tr("자산 %s / 30억 (%d%%)      현금 %s      건강 %d  정신 %d      남은 %d개월", "Assets %s / 3 billion won (%d%%)      Cash %s      Health %d  Mental %d      %d mo left") % [
		_story_money(assets), pct,
		_story_money(GameState.money),
		GameState.health, GameState.mental, months_left]

func _story_money(amount: float) -> String:
	if not LocaleManager.is_english():
		return GameState.format_money(amount)
	var sign := "-" if amount < 0.0 else ""
	var value := absf(amount)
	if value >= 1_000_000_000.0:
		return "%s%s billion won" % [sign, _story_money_number(value / 1_000_000_000.0)]
	if value >= 1_000_000.0:
		return "%s%s million won" % [sign, _story_money_number(value / 1_000_000.0)]
	if value >= 1_000.0:
		return "%s%s thousand won" % [sign, _story_money_number(value / 1_000.0)]
	return "%s%d won" % [sign, int(roundf(value))]

func _story_money_number(value: float) -> String:
	var rounded := int(roundf(value))
	return str(rounded) if is_equal_approx(value, float(rounded)) else "%.1f" % value

func _apply_font(lbl: Label, bold: bool = false):
	var f = _font_bold if bold else _font
	if f:
		lbl.add_theme_font_override("font", f)

func _normalized_story_text_size(raw_level: String) -> String:
	return raw_level if raw_level in STORY_TEXT_SIZE_LEVELS else STORY_TEXT_SIZE_DEFAULT

func _story_font_size(base_size: int) -> int:
	var scale: float = float(STORY_TEXT_SCALES.get(_story_text_size, 1.0))
	return maxi(1, int(roundf(float(base_size) * scale)))

func _register_story_font(control: Control, theme_key: String, base_size: int) -> void:
	control.set_meta("story_font_theme_key", theme_key)
	control.set_meta("story_font_base_size", base_size)
	control.add_theme_font_size_override(theme_key, _story_font_size(base_size))

func _apply_story_text_size_to_tree(node: Node) -> void:
	if node is Control and node.has_meta("story_font_base_size"):
		var control := node as Control
		control.add_theme_font_size_override(
			str(control.get_meta("story_font_theme_key", "font_size")),
			_story_font_size(int(control.get_meta("story_font_base_size", 14))))
	for child in node.get_children():
		_apply_story_text_size_to_tree(child)

func _apply_story_text_size() -> void:
	if not is_inside_tree():
		return
	_apply_story_text_size_to_tree(self)
	var extra_height := 22.0 if _story_text_size == "large" else 0.0
	if is_instance_valid(_text_panel):
		_text_panel.offset_top = -250.0 - extra_height
	if is_instance_valid(_name_panel):
		_name_panel.offset_top = -294.0 - extra_height
		_name_panel.offset_bottom = -256.0 - extra_height
	for level in _story_text_size_buttons:
		var button := _story_text_size_buttons[level] as Button
		if is_instance_valid(button):
			button.button_pressed = str(level) == _story_text_size

func _set_story_text_size(level: String) -> void:
	var normalized := _normalized_story_text_size(level)
	if normalized == _story_text_size:
		return
	var source_paragraph_index := _story_source_paragraph_index(_para_index)
	var was_typing := _typing
	var old_type_length := maxi(1, _type_full.length())
	var type_ratio := clampf(float(_type_pos) / float(old_type_length), 0.0, 1.0)
	var source_page_progress := _story_source_page_progress(_para_index, type_ratio)
	var hint_was_visible := is_instance_valid(_continue_hint) and _continue_hint.visible
	var beat_was_waiting := _direction_beat_waiting
	_story_text_size = normalized
	SaveManager.set_setting("story_text_size", normalized)
	_apply_story_text_size()
	if not _current.is_empty() and not _is_chapter_card and not _showing_choices:
		var raw_text := _current_story_phase_text()
		if not raw_text.is_empty():
			_restore_localized_story_text(
				_story_page_data(raw_text), source_paragraph_index,
				source_page_progress, was_typing, type_ratio,
				hint_was_visible, beat_was_waiting)

func _normalized_story_text_speed(raw_level: String) -> String:
	return raw_level if raw_level in STORY_TEXT_SPEED_LEVELS else STORY_TEXT_SPEED_DEFAULT

func _set_story_text_speed(level: String) -> void:
	var normalized := _normalized_story_text_speed(level)
	if normalized == _story_text_speed:
		return
	_story_text_speed = normalized
	SaveManager.set_setting("story_text_speed", normalized)
	for speed_level in _story_text_speed_buttons:
		var button := _story_text_speed_buttons[speed_level] as Button
		if is_instance_valid(button):
			button.button_pressed = str(speed_level) == _story_text_speed

func _story_language_options() -> Array:
	var options: Array = []
	for code in LocaleManager.get_selectable_languages():
		var display_name := LocaleManager.get_language_display_name(code)
		if code == "ko":
			display_name = _tr("한국어", "Korean")
		options.append({
			"key": code,
			"label": display_name,
		})
	return options

func _set_story_language(raw_language: String) -> void:
	var language := LocaleManager.normalize_language(raw_language)
	if language not in LocaleManager.get_selectable_languages() or language == LocaleManager.language:
		return
	var event_id := str(_current.get("id", ""))
	var source_paragraph_index := _story_source_paragraph_index(_para_index)
	var was_typing := _typing
	var old_type_length := maxi(1, _type_full.length())
	var type_ratio := clampf(float(_type_pos) / float(old_type_length), 0.0, 1.0)
	var source_page_progress := _story_source_page_progress(_para_index, type_ratio)
	var hint_was_visible := is_instance_valid(_continue_hint) and _continue_hint.visible
	var beat_was_waiting := _direction_beat_waiting

	LocaleManager.set_language(language)
	var localized := _localized_story_event(event_id)
	if not localized.is_empty():
		_current = localized
		EventManager.current_event = _current
		_current_presentation = DataRegistry.get_story_presentation(event_id)
		_title_lbl.text = "— %s —" % _fmt(str(_current.get("title", "")))
		var localized_page_data: Dictionary
		if _pending_after_result and _pending_result_choice_index >= 0:
			localized_page_data = _localized_result_page_data(_pending_result_choice_index)
			var localized_choices: Array = _current.get("choices", [])
			if _pending_result_choice_index < localized_choices.size() \
					and is_instance_valid(_result_record_card):
				_show_story_result_record(
					localized_choices[_pending_result_choice_index] as Dictionary, false)
		else:
			localized_page_data = _story_page_data(_resolved_story_description(_current))
		_restore_localized_story_text(
			localized_page_data, source_paragraph_index, source_page_progress,
			was_typing, type_ratio, hint_was_visible, beat_was_waiting)
		_refresh_story_choice_language()
		_refresh_story_speaker_language()
		if _is_chapter_card:
			_refresh_chapter_card_language()

	_refresh_hud()
	_refresh_continue_hint_text()
	if is_instance_valid(_audio_settings_button):
		_audio_settings_button.text = _tr("설정", "Settings")
		_audio_settings_button.tooltip_text = _tr(
			"장면 설정 (%s)" % ControllerHints.start_btn(),
			"Scene settings (%s)" % ControllerHints.start_btn())
	_settings_focus_key = "language:%s" % language
	call_deferred("_rebuild_story_settings_popup", _settings_focus_key)

func _localized_story_event(event_id: String) -> Dictionary:
	if event_id.is_empty():
		return {}
	var localized: Dictionary = DataRegistry.find_event(event_id)
	if localized.is_empty():
		return {}
	var curation_year := int(localized.get("year_scene_year", 0))
	if curation_year > 0:
		localized = localized.duplicate(true)
		localized["choices"] = GameState.build_year_scene_choices(curation_year)
	return localized

func _localized_result_page_data(choice_index: int) -> Dictionary:
	var choices: Array = _current.get("choices", [])
	if choice_index < 0 or choice_index >= choices.size():
		return {
			"pages": _paragraphs.duplicate(),
			"source_indices": _paragraph_source_indices.duplicate(),
		}
	var result: String = _fmt(str((choices[choice_index] as Dictionary).get("result_text", "")))
	return _story_page_data(result)

func _restore_localized_story_text(
		page_data: Dictionary,
		source_paragraph_index: int,
		source_page_progress: float,
		was_typing: bool,
		type_ratio: float,
		hint_was_visible: bool,
		beat_was_waiting: bool) -> void:
	_apply_story_page_data(page_data)
	_para_index = _story_page_for_source_progress(
		source_paragraph_index, source_page_progress)
	if beat_was_waiting:
		_direction_pending_text = str(_paragraphs[_para_index])
		var previous_index := maxi(0, _para_index - 1)
		_type_full = str(_paragraphs[previous_index])
		_type_pos = _type_full.length()
		_typing = false
		_body_lbl.text = _type_full
		_continue_hint.visible = false
		return
	_type_full = str(_paragraphs[_para_index])
	if was_typing:
		_type_pos = clampi(int(roundf(float(_type_full.length()) * type_ratio)), 0, _type_full.length())
		_typing = _type_pos < _type_full.length()
		_body_lbl.text = _type_full.substr(0, _type_pos)
		_continue_hint.visible = false
		if not _typing:
			_body_lbl.text = _type_full
			_continue_hint.visible = hint_was_visible and not _showing_choices
	else:
		_type_pos = _type_full.length()
		_typing = false
		_body_lbl.text = _type_full
		_continue_hint.visible = hint_was_visible \
				and not _showing_choices and not _direction_hold_active

func _refresh_story_choice_language() -> void:
	if not is_instance_valid(_choice_box):
		return
	var choices: Array = _current.get("choices", [])
	for group in _choice_box.get_children():
		for child in group.get_children():
			if not child is Button or not child.has_meta("choice_index"):
				continue
			var button := child as Button
			var choice_index := int(button.get_meta("choice_index", -1))
			if choice_index < 0 or choice_index >= choices.size():
				continue
			var choice: Dictionary = choices[choice_index]
			var base_text := str(choice.get("text", _tr("선택", "Choose")))
			var perceived: String = _moral_perception_text(choice.get("text_if_moral", {}), base_text)
			var shown := int(button.get_meta("choice_display_num", choice_index + 1))
			button.text = "  %02d  %s" % [shown, _fmt(perceived)]
	if is_instance_valid(_choice_countdown_label) and _choice_countdown_deadline_msec > 0:
		var remaining := maxf(
			0.0, float(_choice_countdown_deadline_msec - Time.get_ticks_msec()) / 1000.0)
		_choice_countdown_label.text = _tr("남은 시간  %d", "TIME LEFT  %d") % ceili(remaining)

func _refresh_story_speaker_language() -> void:
	if _is_chapter_card:
		return
	_update_communication_badge(
		str(_current_presentation.get("channel", "in_person")),
		str(_current_presentation.get("state", "")))
	if _story_nameplate_hidden():
		if is_instance_valid(_name_panel):
			_name_panel.visible = false
		return
	var info := ImageRegistry.get_person_info(_resolved_event_portrait_id())
	if info.is_empty() or str(info.get("name", "")).is_empty():
		if is_instance_valid(_name_panel):
			_name_panel.visible = false
		return
	var display_name := str(info.get("name", ""))
	var suffix := _remote_name_suffix()
	_name_tag.text = display_name if suffix.is_empty() else "%s  ·  %s" % [display_name, suffix]
	if is_instance_valid(_name_panel):
		_name_panel.visible = true

func _refresh_continue_hint_text() -> void:
	if not is_instance_valid(_continue_hint):
		return
	var direct_action := _direct_continue_action_text()
	if ControllerHints.is_pad_active():
		var has_more_prose := _para_index >= 0 and _para_index < _paragraphs.size() - 1
		if has_more_prose:
			_continue_hint.text = _tr("[%s] 진행 · 길게 읽기", "[%s] Advance · Hold to read") \
					% ControllerHints.south()
		elif not direct_action.is_empty():
			_continue_hint.text = "[%s] %s" % [ControllerHints.south(), direct_action]
		else:
			_continue_hint.text = _tr("[%s] 진행", "[%s] Advance") % ControllerHints.south()
	elif not direct_action.is_empty():
		_continue_hint.text = _tr(
				"Enter/클릭 · {action}", "Enter/click · {action}").format({"action": direct_action})
	else:
		_continue_hint.text = _tr("▼  Enter 또는 클릭", "▼  Enter or click")

func _direct_continue_choice_index() -> int:
	if _pending_after_result or _showing_choices or _is_chapter_card \
			or bool(_current.get("timed", false)):
		return -1
	var choices: Array = _current.get("choices", [])
	if choices.size() != 1 or not _choice_visible(choices[0] as Dictionary):
		return -1
	return 0

func _direct_continue_action_text() -> String:
	var choice_index := _direct_continue_choice_index()
	if choice_index < 0:
		return ""
	var choices: Array = _current.get("choices", [])
	var choice: Dictionary = choices[choice_index]
	var base_text := str(choice.get("text", _tr("계속", "Continue")))
	return _fmt(_moral_perception_text(choice.get("text_if_moral", {}), base_text))

# ── 이벤트 로딩 ───────────────────────────────────────────────
func _load_next_event():
	_reset_advance_hold()
	_stop_story_choice_countdown()
	if _queue.is_empty():
		_finish_all()
		return
	var event_id = str(_queue.pop_front())
	_current = DataRegistry.find_event(event_id)
	if _current.is_empty():
		_next_transition_mode = ""
		_next_transition_contract = {}
		_load_next_event()
		return
	_current_transition_mode = _next_transition_mode
	_next_transition_mode = ""
	_current_transition_contract = _next_transition_contract.duplicate(true)
	_next_transition_contract = {}
	if not _read_only_replay:
		MetaProgression.record_scene_seen(event_id)
		GameState.record_run_scene_seen(event_id)
	var curation_year := int(_current.get("year_scene_year", 0))
	if curation_year > 0:
		_current = _current.duplicate(true)
		var curation_choices := GameState.build_year_scene_choices(curation_year)
		if curation_choices.size() < 3:
			_load_next_event()
			return
		_current["choices"] = curation_choices
	EventManager.current_event = _current
	_render_current()
	if not _pending_restore_context.is_empty():
		var restore_context := _pending_restore_context.duplicate(true)
		_pending_restore_context.clear()
		_apply_story_resume_context(restore_context)

func _resolved_event_portrait_id() -> String:
	var portrait_id := str(_current.get("portrait", ""))
	var known_map: Variant = _current.get("portrait_if_known", null)
	if known_map is Dictionary:
		# First match wins. Compound facts use the same ampersand syntax as CGs.
		for condition_key in known_map.keys():
			if _known_flag_condition_matches(str(condition_key)):
				return str(known_map[condition_key])
	return portrait_id

func _resolved_event_cg_id() -> String:
	var cg_id := str(_current.get("cg", ""))
	var known_map: Variant = _current.get("cg_if_known", null)
	if known_map is Dictionary:
		# Use the same first-known ordering as description and portrait variants.
		# Ampersand joins route facts that must all be true. Compound entries must
		# remain before their simpler fallbacks in authored JSON order.
		for condition_key in known_map.keys():
			if _known_flag_condition_matches(str(condition_key)):
				return str(known_map[condition_key])
	return cg_id

func _known_flag_condition_matches(condition_key: String) -> bool:
	for raw_flag_id in condition_key.split("&", false):
		var flag_id := str(raw_flag_id).strip_edges()
		if flag_id.is_empty() or not GameState.flags.get(flag_id, false):
			return false
	return true

func _story_memory_condition_matches(condition_key: String) -> bool:
	for raw_condition in condition_key.split("&", false):
		var condition := str(raw_condition).strip_edges()
		if condition.begins_with("relationship_memory:"):
			var receipt_id := condition.trim_prefix(
				"relationship_memory:")
			var separator := receipt_id.find(":")
			if separator <= 0 or separator >= receipt_id.length() - 1:
				return false
			var character_id := receipt_id.substr(0, separator).strip_edges()
			var memory_id := receipt_id.substr(separator + 1).strip_edges()
			if character_id.is_empty() or memory_id.is_empty() \
					or not DEMO_CORE_LOOP_V2.has_relationship_memory(
						character_id, memory_id):
				return false
		elif condition.is_empty() \
				or not GameState.flags.get(condition, false):
			return false
	return true

func _resolved_story_description(event: Dictionary) -> String:
	var desc_raw: String = str(event.get("description", ""))
	var ortho: int = int(GameState.route_orthodox)
	var unorth: int = int(GameState.route_unorthodox)
	var mental: int = int(GameState.mental)
	var housing: String = str(GameState.housing)
	var housing_months: int = int(GameState.housing_months.get(housing, 0))
	var know_variant := ""
	var know_map = event.get("description_if_known", null)
	if know_map is Dictionary:
		for condition_key in know_map.keys():
			if _known_flag_condition_matches(str(condition_key)):
				know_variant = str(know_map[condition_key])
				break
	if know_variant.is_empty():
		var held_map = event.get("description_if_held", null)
		if held_map is Dictionary:
			for item_id in held_map.keys():
				if GameState.has_item(str(item_id)):
					know_variant = str(held_map[item_id])
					break
	if not know_variant.is_empty():
		desc_raw = know_variant
	elif event.has("description_if_moral"):
		desc_raw = _moral_perception_text(event.get("description_if_moral", {}), desc_raw)
	elif mental <= 20 and event.has("description_low_mental"):
		desc_raw = str(event["description_low_mental"])
	elif housing == "gosiwon" and housing_months >= 6 and event.has("description_long_gosiwon"):
		desc_raw = str(event["description_long_gosiwon"])
	elif ortho > unorth + 15 and event.has("description_orthodox"):
		desc_raw = str(event["description_orthodox"])
	elif unorth > ortho + 15 and event.has("description_unorthodox"):
		desc_raw = str(event["description_unorthodox"])
	var memory_map = event.get("description_memory_if_known", null)
	if memory_map is Dictionary:
		for condition_key in memory_map.keys():
			if _story_memory_condition_matches(str(condition_key)):
				var memory_text := str(memory_map[condition_key]).strip_edges()
				if not memory_text.is_empty():
					desc_raw += "\n\n" + memory_text
				break
	var desc := _fmt(desc_raw)
	var causal_frame := EventManager.causal_frame_for(event)
	if not causal_frame.is_empty():
		desc = "[color=#9aa4b2][i]%s[/i][/color]\n%s" % [_fmt(causal_frame), desc]
	return desc

func _current_story_phase_text() -> String:
	if _pending_after_result and _pending_result_choice_index >= 0:
		var choices: Array = _current.get("choices", [])
		if _pending_result_choice_index < choices.size():
			return _fmt(str((choices[_pending_result_choice_index] as Dictionary).get(
				"result_text", "")))
	return _resolved_story_description(_current)

func _split_story_paragraphs(text: String) -> Array:
	return (_story_page_data(text).get("pages", [""]) as Array)

func _story_page_data(text: String) -> Dictionary:
	var pages: Array = []
	var source_indices: Array = []
	var source_index := 0
	for para in text.split("\n\n"):
		var paragraph := str(para).strip_edges()
		if paragraph.is_empty():
			source_index += 1
			continue
		for page in _paginate_story_paragraph(paragraph):
			pages.append(str(page))
			source_indices.append(source_index)
		source_index += 1
	if pages.is_empty():
		pages = [""]
		source_indices = [0]
	return {
		"pages": pages,
		"source_indices": source_indices,
	}

func _apply_story_page_data(page_data: Dictionary) -> void:
	_paragraphs = (page_data.get("pages", [""]) as Array).duplicate()
	_paragraph_source_indices = (
		page_data.get("source_indices", [0]) as Array).duplicate()
	if _paragraphs.is_empty():
		_paragraphs = [""]
	if _paragraph_source_indices.size() != _paragraphs.size():
		_paragraph_source_indices.clear()
		for index in range(_paragraphs.size()):
			_paragraph_source_indices.append(index)

func _paginate_story_paragraph(paragraph: String) -> Array:
	var pages: Array = []
	var remaining := paragraph.strip_edges()
	while not remaining.is_empty():
		if _story_page_fits(remaining):
			pages.append(remaining)
			break
		var low := 1
		var high := remaining.length()
		var best := 1
		while low <= high:
			var midpoint := int((low + high) / 2)
			if _story_page_fits(remaining.substr(0, midpoint)):
				best = midpoint
				low = midpoint + 1
			else:
				high = midpoint - 1
		var split_at := _story_safe_page_break(remaining, best)
		var page := remaining.substr(0, split_at).strip_edges()
		if page.is_empty():
			split_at = maxi(1, best)
			page = remaining.substr(0, split_at).strip_edges()
		pages.append(page)
		remaining = remaining.substr(split_at).strip_edges()
	return pages if not pages.is_empty() else [paragraph]

func _story_page_fits(text: String) -> bool:
	if _font == null:
		return text.count("\n") < 5
	var viewport_width := get_viewport_rect().size.x
	var body_width := maxf(420.0, viewport_width - 172.0)
	var body_height := 132.0 + (22.0 if _story_text_size == "large" else 0.0)
	var measured := _font.get_multiline_string_size(
		_story_visible_text(text), HORIZONTAL_ALIGNMENT_LEFT, body_width,
		_story_font_size(20))
	return measured.y <= body_height - 8.0

func _story_visible_text(text: String) -> String:
	var visible := ""
	var inside_tag := false
	for index in range(text.length()):
		var character := text.substr(index, 1)
		if character == "[":
			inside_tag = true
		elif character == "]" and inside_tag:
			inside_tag = false
		elif not inside_tag:
			visible += character
	return visible

func _story_safe_page_break(text: String, best: int) -> int:
	var tag_depth := 0
	var safe_breaks: Array[int] = []
	var index := 0
	while index < mini(best, text.length()):
		if text.substr(index, 1) == "[":
			var close := text.find("]", index)
			if close < 0 or close >= best:
				break
			var tag := text.substr(index + 1, close - index - 1).strip_edges()
			if tag.begins_with("/"):
				tag_depth = maxi(0, tag_depth - 1)
			elif not tag.ends_with("/") and not tag.begins_with("br"):
				tag_depth += 1
			index = close + 1
			continue
		var character := text.substr(index, 1)
		if tag_depth == 0 and (character in [" ", "\n", ".", ",", "!", "?", "。", "！", "？"]):
			safe_breaks.append(index + 1)
		index += 1
	var minimum_break := maxi(1, int(float(best) * 0.55))
	for safe_index in range(safe_breaks.size() - 1, -1, -1):
		var candidate := int(safe_breaks[safe_index])
		if candidate >= minimum_break:
			return candidate
	return maxi(1, best)

func _story_source_paragraph_index(page_index: int) -> int:
	if page_index >= 0 and page_index < _paragraph_source_indices.size():
		return int(_paragraph_source_indices[page_index])
	return maxi(0, page_index)

func _first_story_page_for_source(source_index: int) -> int:
	for page_index in range(_paragraph_source_indices.size()):
		if int(_paragraph_source_indices[page_index]) == source_index:
			return page_index
	return clampi(source_index, 0, _paragraphs.size() - 1)

func _story_source_page_progress(page_index: int, within_page: float) -> float:
	var source_index := _story_source_paragraph_index(page_index)
	var source_pages: Array[int] = []
	for candidate in range(_paragraph_source_indices.size()):
		if int(_paragraph_source_indices[candidate]) == source_index:
			source_pages.append(candidate)
	if source_pages.is_empty():
		return 0.0
	var ordinal := source_pages.find(page_index)
	if ordinal < 0:
		ordinal = 0
	return clampf(
		(float(ordinal) + clampf(within_page, 0.0, 1.0)) /
			float(source_pages.size()), 0.0, 0.999)

func _story_page_for_source_progress(source_index: int, progress: float) -> int:
	var source_pages: Array[int] = []
	for page_index in range(_paragraph_source_indices.size()):
		if int(_paragraph_source_indices[page_index]) == source_index:
			source_pages.append(page_index)
	if source_pages.is_empty():
		return _first_story_page_for_source(source_index)
	var ordinal := mini(
		source_pages.size() - 1,
		int(floor(clampf(progress, 0.0, 0.999) * float(source_pages.size()))))
	return int(source_pages[ordinal])

func _render_current():
	_reset_advance_hold()
	var continues_same_location := _current_transition_mode in [
		"", "none", "same_location", "remote"]
	if not continues_same_location:
		# 이전 배경을 실제로 붙잡아 둔 뒤에 새 장면을 아래에서 교체한다.
		# 장면을 먼저 갈고 펄스를 덮는 방식은 하드컷을 숨기지 못한다.
		_begin_story_scene_transition(_current_transition_mode)
	set_meta("story_transition_contract", _current_transition_contract.duplicate(true))
	set_meta("story_transition_mode", _normalized_story_scene_transition(
		_current_transition_mode))
	_reset_scene_direction()
	_prepare_scene_direction()
	_current_presentation = {}
	_portrait_remote_inset = false
	if is_instance_valid(_communication_badge):
		_communication_badge.visible = false
	_showing_choices = false
	_clear_result_record_card()
	_current_uses_cg = false
	_event_cg_id = ""
	_event_cg_path = ""
	_event_cg_reveal_paragraph = 0
	_event_paragraph_backgrounds = []
	_event_background_id = ""
	_event_portrait_reveal_paragraph = 0
	_event_portrait_revealed = true
	_choice_box.visible = false
	for c in _choice_box.get_children():
		c.queue_free()

	# 챕터 카드 오버레이 정리 + 일반 UI 복원
	_is_chapter_card = false
	if _chapter_overlay != null and is_instance_valid(_chapter_overlay):
		_chapter_overlay.queue_free()
		_chapter_overlay = null
	if _text_panel != null:
		_text_panel.visible = true
	if _hud_panel != null and is_instance_valid(_hud_panel):
		_hud_panel.visible = true

	# 챕터 카드 전용 시네마틱 연출
	if str(_current.get("id", "")).begins_with("chapter_card_"):
		_is_chapter_card = true
		_render_chapter_card_cinematic()
		return
	if _story_visual_override_active and _hud_panel != null:
		_hud_panel.visible = false

	var cg_path := ""
	var cg_id := _resolved_event_cg_id()
	if cg_id != "":
		cg_path = ImageRegistry.get_cg(cg_id)
	_event_cg_id = cg_id
	_event_cg_path = cg_path
	_event_cg_reveal_paragraph = maxi(0, int(_current.get("cg_reveal_paragraph", 0)))
	var raw_paragraph_backgrounds: Variant = _current.get("paragraph_backgrounds", [])
	if raw_paragraph_backgrounds is Array:
		for raw_background_id in raw_paragraph_backgrounds:
			_event_paragraph_backgrounds.append(str(raw_background_id))
	_event_portrait_reveal_paragraph = maxi(0, int(_current.get("portrait_reveal_paragraph", 0)))
	_event_portrait_revealed = _event_portrait_reveal_paragraph == 0
	var cg_active_at_start := cg_path != "" and _event_cg_reveal_paragraph == 0

	# CG가 있는 장면은 CG를 최우선 전체화면 배경으로 사용한다.
	# 문단 reveal이 있으면 지정 문단 전까지 명시 background와 초상화를 유지한다.
	if cg_active_at_start and ImageRegistry.has_texture(cg_path):
		_bg_img.texture = ImageRegistry.load_texture(cg_path)
		_current_uses_cg = true
		if not _read_only_replay:
			MetaProgression.record_cg_unlocked(cg_id)
	else:
		var bg_id := _event_background_id_for_paragraph(0)
		if bg_id == "":
			bg_id = str(_current.get("background", ""))
		if bg_id == "":
			bg_id = ImageRegistry.infer_background_id(_current, GameState.housing)
		bg_id = _resolve_story_background_id(bg_id)
		if bg_id != "":
			var bp = ImageRegistry.get_background(bg_id)
			if bp != "" and ImageRegistry.has_texture(bp):
				_bg_img.texture = ImageRegistry.load_texture(bp)
				_event_background_id = bg_id
	_current_presentation = DataRegistry.get_story_presentation(str(_current.get("id", "")))
	_apply_story_surface_palette(_current_uses_cg)
	var audio_contract: Dictionary = BGMPlayer.scene_audio_contract(
		str(_current.get("id", "")), _event_cg_id)
	var has_authored_ambience: bool = not str(audio_contract.get("ambience", "")).is_empty()
	if str(_current.get("background", "")) == "current_housing" \
			and not _current_uses_cg and not has_authored_ambience:
		BGMPlayer.update_idle_ambience()
	else:
		BGMPlayer.update_event_ambience(_current, _event_cg_id, _event_background_id)
	BGMPlayer.begin_story_event(_current, _event_cg_id)
	AudioManager.begin_story_audio_event(str(_current.get("id", "")))
	AudioManager.play_event_cue(_current)
	_configure_living_scene()
	_apply_scene_direction_entry()

	# 초상화 + 이름표 — bg_focus:true 장면은 배경만(초상화 생략)
	var pid := _resolved_event_portrait_id()
	var bg_only := bool(_current.get("bg_focus", false)) or _current_uses_cg
	if _event_portrait_revealed:
		_show_portrait(pid, bg_only)
	else:
		# 인물이 실제로 등장하기 전에는 이름표도 함께 감춘다.
		_show_portrait("", true)
	if _current_uses_cg and _hud_panel != null and is_instance_valid(_hud_panel):
		_hud_panel.visible = false

	# 제목
	_title_lbl.text = "— %s —" % _fmt(str(_current.get("title", "")))
	if continues_same_location:
		if _story_text_panel_tween and _story_text_panel_tween.is_running():
			_story_text_panel_tween.kill()
		_story_text_panel_tween = null
		_text_panel.modulate = Color.WHITE
	else:
		_animate_story_text_panel()

	# 본문 문단 분할. 언어 즉시 전환도 같은 해석 함수를 사용해 현재 장면만 다시 바인딩한다.
	_apply_story_page_data(_story_page_data(_resolved_story_description(_current)))
	_para_index = 0
	_play_current_paragraph_audio(_story_source_paragraph_index(_para_index))
	_start_typing(_paragraphs[0])

func _play_current_paragraph_audio(paragraph_index: int) -> void:
	var event_id := str(_current.get("id", ""))
	BGMPlayer.play_scene_paragraph_music(_current, _event_cg_id, paragraph_index)
	AudioManager.play_scene_paragraph_cues(event_id, _event_cg_id, paragraph_index)

func _event_background_id_for_paragraph(paragraph_index: int) -> String:
	if _event_paragraph_backgrounds.is_empty():
		return ""
	var index := clampi(paragraph_index, 0, _event_paragraph_backgrounds.size() - 1)
	return _resolve_story_background_id(str(_event_paragraph_backgrounds[index]))

func _resolve_story_background_id(background_id: String) -> String:
	return ImageRegistry.resolve_contextual_background_id(background_id.strip_edges())

func _maybe_change_event_background(paragraph_index: int) -> void:
	if _current_uses_cg or _pending_after_result:
		return
	var bg_id := _event_background_id_for_paragraph(paragraph_index)
	if bg_id.is_empty() or bg_id == _event_background_id:
		return
	var path := ImageRegistry.get_background(bg_id)
	if path.is_empty() or not ImageRegistry.has_texture(path):
		return
	_event_background_id = bg_id
	_begin_story_scene_transition("explicit_move")
	_bg_img.texture = ImageRegistry.load_texture(path)
	_apply_story_surface_palette(false)
	_configure_living_scene()

func _maybe_reveal_event_cg(paragraph_index: int) -> void:
	if _current_uses_cg or _event_cg_path.is_empty():
		return
	if _event_cg_reveal_paragraph <= 0 or paragraph_index < _event_cg_reveal_paragraph:
		return
	if not ImageRegistry.has_texture(_event_cg_path):
		return
	_current_uses_cg = true
	if not _read_only_replay:
		MetaProgression.record_cg_unlocked(_event_cg_id)
	# The ledger has already landed on the prior result paragraph. Once the
	# authored CG opens, release the middle of the frame to its acting/object.
	_clear_result_record_card()
	var reveal_mode := (
		"finale"
		if DataRegistry.get_scene_direction_event_intent(
			str(_current.get("id", ""))) == "finale"
		else "time_cut")
	_begin_story_scene_transition(reveal_mode)
	_bg_img.texture = ImageRegistry.load_texture(_event_cg_path)
	_apply_story_surface_palette(true)
	_configure_living_scene()
	BGMPlayer.update_event_ambience(_current, _event_cg_id)
	_show_portrait(_resolved_event_portrait_id(), true)
	if _hud_panel != null and is_instance_valid(_hud_panel):
		_hud_panel.visible = false

func _maybe_reveal_event_portrait(paragraph_index: int) -> void:
	if _event_portrait_revealed or _current_uses_cg:
		return
	if _event_portrait_reveal_paragraph <= 0 or paragraph_index < _event_portrait_reveal_paragraph:
		return
	_event_portrait_revealed = true
	_show_portrait(_resolved_event_portrait_id(), bool(_current.get("bg_focus", false)))

func _configure_portrait_presentation() -> void:
	var channel := str(_current_presentation.get("channel", "in_person"))
	var portrait_role := str(_current_presentation.get("portrait_role", "present"))
	_portrait_remote_inset = portrait_role == "remote" and channel in [
		"phone", "video_call", "message", "memory"
	]
	_portrait_target_alpha = 0.80 if channel == "memory" else 1.0

	_portrait_frame.offset_left = _portrait_base_left()
	_portrait_frame.offset_right = _portrait_base_right()
	_portrait_frame.offset_top = REMOTE_PORTRAIT_OFFSET_TOP if _portrait_remote_inset else PORTRAIT_OFFSET_TOP
	_portrait_frame.offset_bottom = REMOTE_PORTRAIT_OFFSET_BOTTOM if _portrait_remote_inset else PORTRAIT_OFFSET_BOTTOM
	_portrait_frame.scale = Vector2.ONE

	var frame_style := StyleBoxFlat.new()
	if _portrait_remote_inset:
		frame_style.bg_color = Color("#080b10", 0.90)
		frame_style.border_color = Color("#718198", 0.78)
		frame_style.set_border_width_all(1)
		frame_style.border_width_left = 3
		frame_style.set_corner_radius_all(6)
		frame_style.set_content_margin_all(5)
	else:
		frame_style.bg_color = Color(0, 0, 0, 0)
		frame_style.set_border_width_all(0)
		frame_style.shadow_size = 0
		frame_style.set_corner_radius_all(0)
		frame_style.set_content_margin_all(0)
	_portrait_frame.add_theme_stylebox_override("panel", frame_style)
	_update_communication_badge(channel, str(_current_presentation.get("state", "")))

func _update_communication_badge(channel: String, state: String) -> void:
	if not is_instance_valid(_communication_badge) or not is_instance_valid(_communication_label):
		return
	var label := ""
	match channel:
		"phone":
			match state:
				"missed": label = _tr("부재중 전화", "MISSED CALL")
				"incoming": label = _tr("수신 전화", "INCOMING CALL")
				"dialing": label = _tr("연결 중", "CALLING")
				_: label = _tr("통화 중", "VOICE CALL")
		"video_call":
			label = _tr("영상통화", "VIDEO CALL")
		"message":
			label = _tr("메시지", "MESSAGE")
		"memory":
			label = _tr("기억", "MEMORY")
	_communication_label.text = label
	_communication_badge.visible = not label.is_empty() and not _story_visual_override_active

func _remote_name_suffix() -> String:
	if not _portrait_remote_inset:
		return ""
	match str(_current_presentation.get("channel", "")):
		"phone": return _tr("전화 너머", "Voice call")
		"video_call": return _tr("영상통화", "Video call")
		"message": return _tr("메시지", "Message")
		"memory": return _tr("기억", "Memory")
	return ""

func _story_nameplate_hidden() -> bool:
	return str(_current_presentation.get("nameplate_role", "auto")) == "hidden"

func _show_portrait(portrait_id: String, bg_only: bool = false):
	_configure_portrait_presentation()
	var info := {}
	var path := ""
	# bg_only 장면(배경이 주연)에선 초상화 id가 있어도 인물 정보만 쓰고 그림은 띄우지 않는다.
	if portrait_id != "":
		info = ImageRegistry.get_person_info(portrait_id)
		if not bg_only and str(_current_presentation.get("portrait_role", "present")) != "none":
			path = ImageRegistry.get_portrait(portrait_id)

	# 초상화 이미지가 실제로 있을 때만 액자 표시. 없으면(배경전용/플레이스홀더) 프레임 통째로 숨김.
	if path != "" and ImageRegistry.has_texture(path):
		_portrait.texture = ImageRegistry.load_texture(path)
		_portrait.modulate = Color.WHITE
		_apply_story_portrait_surface()
		_portrait_frame.visible = true
		_portrait_frame.modulate = Color(1, 1, 1, 0)
		var tw = create_tween()
		if _story_scene_transition_active:
			tw.tween_interval(_story_scene_transition_duration * 0.50)
		tw.tween_property(_portrait_frame, "modulate", Color(1, 1, 1, _portrait_target_alpha), 0.4)
		_start_portrait_idle_motion()
	else:
		_stop_portrait_idle_motion()
		_portrait.texture = null
		_portrait_frame.visible = false

	# 이름표 — 인물 정보가 있으면 표시 (이미지 없어도 누구 대사인지 알려줌)
	if not _story_nameplate_hidden() \
			and not info.is_empty() and str(info.get("name", "")) != "":
		var display_name := str(info.get("name", ""))
		var remote_suffix := _remote_name_suffix()
		_name_tag.text = display_name if remote_suffix.is_empty() else "%s  ·  %s" % [display_name, remote_suffix]
		if _name_panel:
			_name_panel.visible = true
	else:
		if _name_panel:
			_name_panel.visible = false
	if is_instance_valid(_name_panel):
		if _story_scene_transition_active and _name_panel.visible:
			_name_panel.modulate = Color(1, 1, 1, 0)
			var name_tw := create_tween()
			name_tw.tween_interval(_story_scene_transition_duration * 0.62)
			name_tw.tween_property(_name_panel, "modulate:a", 1.0, 0.22) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		else:
			_name_panel.modulate = Color.WHITE
	if is_instance_valid(_communication_badge):
		if _story_scene_transition_active and _communication_badge.visible:
			_communication_badge.modulate = Color(1, 1, 1, 0)
			var badge_tw := create_tween()
			badge_tw.tween_interval(_story_scene_transition_duration * 0.62)
			badge_tw.tween_property(_communication_badge, "modulate:a", 1.0, 0.22) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		else:
			_communication_badge.modulate = Color.WHITE
	if _story_visual_override_active:
		_portrait.modulate = Color(0.08, 0.085, 0.09, 0.70)
		if _name_panel:
			_name_panel.visible = false

func _set_portrait_choice_focus(choices_visible: bool) -> void:
	if not is_inside_tree() or not is_instance_valid(_portrait_frame) or not _portrait_frame.visible:
		return
	# 선택지에서 살짝 물러나는 동작은 유지하되 인물이 유령처럼 비치지 않게 한다.
	var target_alpha := _portrait_target_alpha * (0.94 if choices_visible else 1.0)
	var black := clampf(-_story_moral_norm, 0.0, 1.0)
	var white := clampf(_story_moral_norm, 0.0, 1.0)
	var moral_shift := int(roundf(
		black * float(PORTRAIT_BLACK_PERIPHERY_SHIFT_X) +
		white * float(PORTRAIT_WHITE_CLOSENESS_SHIFT_X)
	))
	var target_shift := moral_shift + (_portrait_choice_shift() if choices_visible else 0)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_portrait_frame, "modulate:a", target_alpha, 0.18).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_portrait_frame, "offset_left", _portrait_base_left() + target_shift, 0.22).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_portrait_frame, "offset_right", _portrait_base_right() + target_shift, 0.22).set_trans(Tween.TRANS_SINE)

func _set_choice_dock_active(active: bool) -> void:
	_set_living_background_blur(active)
	if active:
		_name_panel_visible_before_choices = is_instance_valid(_name_panel) and _name_panel.visible
		if is_instance_valid(_text_panel):
			_text_panel.visible = false
		if is_instance_valid(_name_panel):
			_name_panel.visible = false
		return
	if is_instance_valid(_text_panel):
		_text_panel.visible = not _is_chapter_card
	if is_instance_valid(_name_panel):
		_name_panel.visible = _name_panel_visible_before_choices and not _story_visual_override_active

# ── 장면 연출 디렉션 ─────────────────────────────────────────
func _prepare_scene_direction() -> void:
	var raw: Variant = _current.get("direction", {})
	_direction = raw.duplicate(true) if raw is Dictionary else {}
	_direction_hold_consumed = false
	if str(_direction.get("visual", "")) == "black_future":
		_story_visual_override_active = true
		_story_visual_override_norm = -0.80

func _reset_scene_direction() -> void:
	if _direction_camera_tween and _direction_camera_tween.is_running():
		_direction_camera_tween.kill()
	_direction_camera_tween = null
	_stop_portrait_idle_motion()
	_living_profile = {}
	if is_instance_valid(_living_scene):
		_living_scene.clear_profile()
	if _story_bg_material:
		_story_bg_material.set_shader_parameter("blur_px", 0.0)
	if is_instance_valid(_bg_img):
		_bg_img.scale = Vector2.ONE
		_bg_img.position = Vector2.ZERO
		_bg_img.pivot_offset = _bg_img.size * 0.5
	_direction_hold_active = false
	_direction_hold_consumed = false
	_direction_hold_remaining = 0.0
	_direction_beat_waiting = false
	_direction_beat_remaining = 0.0
	_direction_pending_text = ""
	_direction = {}
	_story_visual_override_active = false
	_story_visual_override_norm = 0.0
	BGMPlayer.restore_ambience()

func _apply_scene_direction_entry() -> void:
	if _direction.is_empty():
		return
	var ambience_mode: String = str(_direction.get("amb", ""))
	if ambience_mode == "cut":
		BGMPlayer.clear_ambience()
	elif ambience_mode == "duck":
		BGMPlayer.duck_ambience(-8.0, 0.45)
	var sting: String = str(_direction.get("sting", ""))
	if not sting.is_empty():
		AudioManager.play_direction_sting(sting, str(_current.get("id", "")))
	var camera: String = str(_direction.get("camera", ""))
	if not camera.is_empty() and not _living_reduced_motion():
		_start_scene_direction_camera(camera)

func _living_reduced_motion() -> bool:
	return bool(SaveManager.get_setting(
		"reduce_motion", SaveManager.get_setting("reduced_motion", false)))

func _configure_living_scene(event_override: Dictionary = {}) -> void:
	if not is_instance_valid(_living_scene):
		return
	var profile_event := event_override if not event_override.is_empty() else _current
	var background_id := _event_background_id
	if background_id.is_empty():
		background_id = str(profile_event.get("background", ""))
	_living_profile = _living_scene.configure(
		profile_event,
		background_id,
		_event_cg_id,
		_current_presentation,
		_story_moral_norm,
		_current_uses_cg,
		_living_reduced_motion())
	_set_living_background_blur(_showing_choices)
	set_meta("living_scene_profile", _living_profile.duplicate(true))
	set_meta("living_scene_effect", str(_living_profile.get("effect", "none")))
	if str(_direction.get("camera", "")).is_empty():
		_start_scene_direction_camera(str(_living_profile.get("camera", "none")))
	_start_portrait_idle_motion()

func _set_living_background_blur(choices_visible: bool) -> void:
	if not _story_bg_material:
		return
	var blur_px := float(_living_profile.get("blur_px", 0.0))
	if choices_visible:
		blur_px += 0.16 if _current_uses_cg else 0.30
	_story_bg_material.set_shader_parameter("blur_px", clampf(blur_px, 0.0, 2.0))

func _stop_portrait_idle_motion() -> void:
	if _portrait_idle_tween and _portrait_idle_tween.is_running():
		_portrait_idle_tween.kill()
	_portrait_idle_tween = null

func _start_portrait_idle_motion() -> void:
	_stop_portrait_idle_motion()
	if not is_inside_tree() or not is_instance_valid(_portrait_frame) or not _portrait_frame.visible:
		return
	var breath := float(_living_profile.get("portrait_breath", 0.0))
	if breath <= 0.0001:
		return
	var black := clampf(-_story_moral_norm, 0.0, 1.0)
	var white := clampf(_story_moral_norm, 0.0, 1.0)
	var base_scale := Vector2.ONE * (1.0 - black * 0.030 + white * 0.010)
	_portrait_frame.pivot_offset = _portrait_frame.size * 0.5
	_portrait_frame.scale = base_scale
	_portrait_idle_tween = create_tween()
	_portrait_idle_tween.bind_node(_portrait_frame)
	_portrait_idle_tween.set_loops()
	_portrait_idle_tween.tween_property(
		_portrait_frame, "scale", base_scale * (1.0 + breath), 3.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_portrait_idle_tween.tween_property(
		_portrait_frame, "scale", base_scale, 4.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _start_scene_direction_camera(mode: String) -> void:
	if not is_instance_valid(_bg_img) or _bg_img.texture == null:
		return
	if _living_reduced_motion():
		return
	if mode.is_empty() or mode == "none":
		return
	if _direction_camera_tween and _direction_camera_tween.is_running():
		_direction_camera_tween.kill()
	_bg_img.pivot_offset = _bg_img.size * 0.5
	_bg_img.position = Vector2.ZERO
	var text_length: int = str(_current.get("description", "")).length()
	var living_camera := mode in ["living_push", "living_drift"]
	var duration: float = clampf(7.0 + float(text_length) * 0.012, 7.0, 16.0)
	if living_camera:
		duration = clampf(12.0 + float(text_length) * 0.008, 12.0, 20.0)
	_direction_camera_tween = create_tween()
	_direction_camera_tween.set_trans(Tween.TRANS_SINE)
	_direction_camera_tween.set_ease(Tween.EASE_IN_OUT)
	if mode == "slow_zoom":
		_bg_img.scale = Vector2.ONE
		_direction_camera_tween.tween_property(_bg_img, "scale", Vector2(1.045, 1.045), duration)
	elif mode == "drift":
		_bg_img.scale = Vector2(1.04, 1.04)
		_bg_img.position = Vector2(-12.0, 0.0)
		_direction_camera_tween.tween_property(_bg_img, "position", Vector2(12.0, 0.0), duration)
	elif mode == "living_push":
		var amount: float = clampf(float(_living_profile.get("camera_amount", 0.012)), 0.004, 0.020)
		_bg_img.scale = Vector2.ONE
		_direction_camera_tween.tween_property(
			_bg_img, "scale", Vector2.ONE * (1.0 + amount), duration)
	elif mode == "living_drift":
		var amount: float = clampf(float(_living_profile.get("camera_amount", 0.012)), 0.004, 0.020)
		var travel := clampf(get_viewport_rect().size.x * amount * 0.34, 4.0, 12.0)
		_bg_img.scale = Vector2.ONE * (1.0 + amount)
		_bg_img.position = Vector2(-travel, 0.0)
		_direction_camera_tween.set_loops()
		_direction_camera_tween.tween_property(
			_bg_img, "position", Vector2(travel, 0.0), duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_direction_camera_tween.tween_property(
			_bg_img, "position", Vector2(-travel, 0.0), duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _direction_type_interval() -> float:
	var user_scale: float = float(STORY_TEXT_SPEED_INTERVAL_SCALES.get(
		_story_text_speed, STORY_TEXT_SPEED_INTERVAL_SCALES[STORY_TEXT_SPEED_DEFAULT]))
	var authored_scale: float = (
		1.0 / 0.60 if str(_direction.get("pace", "")) == "slow" else 1.0)
	return TYPE_SPEED * user_scale * authored_scale

func _begin_direction_beat(text: String) -> void:
	_direction_beat_waiting = true
	_direction_beat_remaining = 0.65
	_direction_pending_text = text
	_continue_hint.visible = false

func _finish_direction_beat() -> void:
	if not _direction_beat_waiting:
		return
	var text: String = _direction_pending_text
	_direction_beat_waiting = false
	_direction_beat_remaining = 0.0
	_direction_pending_text = ""
	_start_typing(text)

func _should_begin_direction_hold() -> bool:
	if _direction_hold_consumed or _pending_after_result:
		return false
	if _para_index != _paragraphs.size() - 1:
		return false
	var choices: Array = _current.get("choices", [])
	return not choices.is_empty() and float(_direction.get("hold", 0.0)) >= 0.5

func _begin_direction_hold() -> void:
	_direction_hold_consumed = true
	_direction_hold_active = true
	_direction_hold_remaining = clampf(float(_direction.get("hold", 0.0)), 0.5, 2.0)
	_continue_hint.visible = false

func _complete_typing() -> void:
	_type_pos = _type_full.length()
	_typing = false
	_body_lbl.text = _type_full
	if _should_begin_direction_hold():
		_begin_direction_hold()
		return
	_refresh_continue_hint_text()
	_continue_hint.visible = true
	_arm_auto_advance(_type_full)
	# 길게 읽기는 현재 사건의 마지막 문장에서 멈춘다. 같은 물리 입력이
	# 선택지를 열거나 결과 뒤의 다음 사건까지 넘기지 않게 하는 경계다.
	if _advance_hold_active and _para_index >= _paragraphs.size() - 1:
		_reset_advance_hold()

# ── 타이핑 효과 ───────────────────────────────────────────────
var _type_accum: float = 0.0

func _start_typing(full_text: String):
	_type_full = full_text
	_type_pos = 0
	_type_accum = 0.0
	_typing = true
	_auto_wait = -1.0
	_body_lbl.text = ""
	_continue_hint.visible = false

func _process(delta):
	_refresh_auto_button()
	# 설정을 읽는 동안 장면도 함께 멈춘다. 타이핑·AUTO·연출 홀드가
	# 모달 뒤에서 진행되면 언어/글자 크기를 확인할 시간이 사라진다.
	if is_instance_valid(_audio_settings_popup):
		return
	# 새 장소가 완전히 드러나기 전에는 첫 문장과 AUTO를 진행하지 않는다.
	if _story_scene_transition_active:
		return
	if _direction_hold_active:
		_direction_hold_remaining -= delta
		if _direction_hold_remaining <= 0.0:
			_direction_hold_active = false
			_direction_hold_remaining = 0.0
			if _direct_continue_choice_index() >= 0:
				_refresh_continue_hint_text()
				_continue_hint.visible = true
				_arm_auto_advance(_type_full)
			else:
				_show_choices()
		return
	if _direction_beat_waiting:
		_direction_beat_remaining -= delta
		if _direction_beat_remaining <= 0.0:
			_finish_direction_beat()
		return
	_process_advance_hold(delta)
	if not _typing:
		if _can_auto_advance():
			_auto_wait -= delta
			if _auto_wait <= 0.0:
				_auto_wait = -1.0
				_on_advance()
		return
	_type_accum += delta
	var interval: float = _direction_type_interval()
	while _type_accum >= interval and _type_pos < _type_full.length():
		_type_accum -= interval
		_type_pos += 1
	if _type_pos >= _type_full.length():
		_complete_typing()
	else:
		_body_lbl.text = _type_full.substr(0, _type_pos)

func _begin_advance_hold() -> void:
	if _showing_choices or _is_chapter_card or _auto_mode \
			or _story_scene_transition_active \
			or _direction_hold_active or _direction_beat_waiting \
			or is_instance_valid(_audio_settings_popup):
		return
	_advance_hold_active = true
	_advance_hold_wait = ADVANCE_HOLD_INITIAL_DELAY
	_advance_hold_event_id = str(_current.get("id", ""))

func _reset_advance_hold() -> void:
	_advance_hold_active = false
	_advance_hold_wait = 0.0
	_advance_hold_event_id = ""

func _process_advance_hold(delta: float) -> void:
	if not _advance_hold_active:
		return
	if _transitioning or _showing_choices or _is_chapter_card \
			or _story_scene_transition_active \
			or _direction_hold_active or _direction_beat_waiting \
			or is_instance_valid(_audio_settings_popup) \
			or str(_current.get("id", "")) != _advance_hold_event_id:
		_reset_advance_hold()
		return
	_advance_hold_wait -= delta
	if _advance_hold_wait > 0.0:
		return
	# 마지막 문단은 타이핑만 완성하고 정지한다. 선택 확정과 장면 이동은
	# 언제나 새로 누른 한 번의 입력을 요구한다.
	if _para_index >= _paragraphs.size() - 1:
		if _typing:
			_complete_typing()
		else:
			_reset_advance_hold()
		return
	_on_advance()
	_advance_hold_wait = ADVANCE_HOLD_REPEAT_DELAY

# ── 입력: 클릭하여 진행 ───────────────────────────────────────
func _on_advance():
	if _transitioning or _story_scene_transition_active \
			or _showing_choices or is_instance_valid(_audio_settings_popup):
		return
	if _direction_hold_active:
		return
	if _direction_beat_waiting:
		_finish_direction_beat()
		return
	# 챕터 카드 모드 — 클릭하면 첫 번째 선택지 자동 적용 후 진행
	if _is_chapter_card:
		_chapter_card_advance()
		return
	# 타이핑 중이면 즉시 완성
	if _typing:
		_complete_typing()
		return
	# 다음 문단
	var previous_source_index := _story_source_paragraph_index(_para_index)
	_para_index += 1
	if _para_index < _paragraphs.size():
		var source_index := _story_source_paragraph_index(_para_index)
		var entered_new_authored_paragraph := source_index != previous_source_index
		if entered_new_authored_paragraph:
			_maybe_change_event_background(source_index)
			_maybe_reveal_event_portrait(source_index)
			_maybe_reveal_event_cg(source_index)
			if _pending_after_result:
				AudioManager.play_scene_result_paragraph_cues(
					str(_current.get("id", "")), _event_cg_id,
					_pending_result_choice_index, source_index)
			else:
				_play_current_paragraph_audio(source_index)
		if entered_new_authored_paragraph and str(_direction.get("pace", "")) == "beat":
			_begin_direction_beat(str(_paragraphs[_para_index]))
		else:
			_start_typing(str(_paragraphs[_para_index]))
		return
	# 문단 끝에 도달
	if _pending_after_result:
		# 결과 텍스트를 다 읽음 → 다음 이벤트로
		_after_result()
	else:
		# 선택지가 하나뿐인 사건은 별도 선택 레일을 열지 않는다. 마지막 문단에
		# 이미 보인 행동을 새 입력으로 바로 확정해 가짜 결정과 확인 한 번을 없앤다.
		var direct_choice_index := _direct_continue_choice_index()
		if direct_choice_index >= 0:
			_on_choice(direct_choice_index)
		else:
			_show_choices()

# ── 컨트롤러 입력 ─────────────────────────────────────────────
func _unhandled_input(event: InputEvent):
	if event.is_action_released("ui_accept"):
		_reset_advance_hold()
	if _transitioning or _story_scene_transition_active:
		return
	if is_instance_valid(_audio_settings_popup):
		if event.is_action_pressed("gd_menu") or event.is_action_pressed("ui_cancel"):
			_close_audio_settings()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("gd_menu"):
		_open_audio_settings()
		get_viewport().set_input_as_handled()
		return
	if _is_auto_toggle_event(event):
		_set_auto_mode(not _auto_mode)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_accept"):
		if _showing_choices:
			return  # 포커스된 선택지 버튼이 직접 처리
		if event is InputEventKey and (event as InputEventKey).echo:
			get_viewport().set_input_as_handled()
			return
		_begin_advance_hold()
		_on_advance()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		# B/○/East: 이야기 도중엔 뒤로 가지 않음 (실수 방지)
		get_viewport().set_input_as_handled()

func _is_auto_toggle_event(event: InputEvent) -> bool:
	if event is InputEventKey:
		var key := event as InputEventKey
		return key.pressed and not key.echo and key.keycode == KEY_A \
				and not key.ctrl_pressed and not key.alt_pressed and not key.meta_pressed
	if event is InputEventJoypadButton:
		var joy := event as InputEventJoypadButton
		return joy.pressed and int(joy.button_index) == JOY_BUTTON_NORTH
	return false

func _set_auto_mode(
		enabled: bool, announce: bool = true, persist_session: bool = true) -> void:
	_auto_mode = enabled
	if persist_session:
		_auto_enabled_session = enabled
	if enabled and not _typing and not _showing_choices:
		_arm_auto_advance(_type_full)
	else:
		_auto_wait = -1.0
	_refresh_auto_button(true)
	if announce and is_instance_valid(_text_panel):
		_pulse_story_choice_commit()

func _arm_auto_advance(text: String) -> void:
	if not _auto_mode:
		_auto_wait = -1.0
		return
	_auto_wait = _auto_reading_delay(text)

func _auto_reading_delay(text: String) -> float:
	var normalized := text.strip_edges()
	if normalized.is_empty():
		return AUTO_MIN_WAIT_SECONDS
	var reading_seconds: float
	if LocaleManager.language in ["ko", "ja"]:
		reading_seconds = float(normalized.length()) / AUTO_CJK_CHARS_PER_MINUTE * 60.0
	else:
		var words := normalized.replace("\n", " ").split(" ", false).size()
		reading_seconds = float(maxi(words, 1)) / AUTO_EN_WORDS_PER_MINUTE * 60.0
	# 자동 타이핑 중 읽은 시간을 빼고 호흡을 더해, 짧은 문장과 긴 문단이
	# 같은 속도로 휠럭이지 않게 한다. 수동 입력은 언제든 이 대기를 넘길 수 있다.
	var typing_seconds := float(normalized.length()) * _direction_type_interval()
	return clampf(
			reading_seconds - typing_seconds + AUTO_BREATH_SECONDS,
			AUTO_MIN_WAIT_SECONDS,
			AUTO_MAX_WAIT_SECONDS)

func _can_auto_advance() -> bool:
	return _auto_mode \
			and _auto_wait >= 0.0 \
			and not _typing \
			and not _showing_choices \
			and not _is_chapter_card \
			and not _transitioning \
			and not _direction_hold_active \
			and not _direction_beat_waiting \
			and not is_instance_valid(_audio_settings_popup) \
			and is_instance_valid(_continue_hint) \
			and _continue_hint.visible

func _refresh_auto_button(force: bool = false) -> void:
	if not is_instance_valid(_auto_button):
		return
	var key_name := ControllerHints.north() if ControllerHints.is_pad_active() else "A"
	var signature := "%s:%s" % ["on" if _auto_mode else "off", key_name]
	if not force and signature == _auto_button_signature:
		return
	_auto_button_signature = signature
	_auto_button.text = "%s  [%s]" % ["AUTO ON" if _auto_mode else "AUTO", key_name]
	_auto_button.add_theme_color_override("font_color", Color("#dce3eb") if _auto_mode else Color("#6f7886"))

# ── 선택지 ────────────────────────────────────────────────────
func _clear_result_record_card() -> void:
	if _result_record_card != null and is_instance_valid(_result_record_card):
		_result_record_card.queue_free()
	_result_record_card = null

func _show_story_result_record(choice: Dictionary, play_feedback: bool = true) -> void:
	_clear_result_record_card()
	var disp: Dictionary = _story_result_display_effects(choice.get("effects", {}))
	var cast_items: Array = _story_result_visible_cast_effects(choice.get("cast_effects", {}))
	if disp.is_empty() and cast_items.is_empty():
		return
	var palette := _story_palette()
	var panel_bg: Color = palette["choice_bg"]
	var panel_border: Color = palette["panel_border"]
	var focus_col: Color = palette["focus"]
	var dim_col: Color = palette["dim"]

	var card := PanelContainer.new()
	card.name = "StoryResultRecord"
	card.anchor_left = 0.20
	card.anchor_right = 0.76
	card.anchor_top = 1.0
	card.anchor_bottom = 1.0
	card.offset_left = 0
	card.offset_right = 0
	card.offset_top = -342
	card.offset_bottom = -260
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var st := _story_panel_style(panel_bg, panel_border, 6, 12, 9, 4)
	st.border_color = panel_border.lerp(focus_col, 0.16)
	UIStyle.apply_ink_surface_depth(st, 1, 0.30, 1)
	card.add_theme_stylebox_override("panel", st)
	add_child(card)
	_result_record_card = card

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	card.add_child(row)

	var head := VBoxContainer.new()
	head.custom_minimum_size = Vector2(132, 0)
	head.add_theme_constant_override("separation", 2)
	row.add_child(head)
	head.add_child(_story_record_label(_tr("선택 기록", "CHOICE RESULT"), 10, dim_col, false))
	var tone := _story_result_tone_label(disp, cast_items)
	head.add_child(_story_record_label(str(tone["label"]), 13, tone["color"], true, "state"))

	var grid := GridContainer.new()
	grid.name = "StoryResultGrid"
	grid.columns = 4
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 7)
	grid.add_theme_constant_override("v_separation", 5)
	row.add_child(grid)

	var stage := GameState.moral_stage()
	var result_items := _story_result_visible_items(
		_story_result_ordered_items(disp, cast_items, stage), stage, 4)
	var badges: Array[Control] = []
	var added := 0
	for item in result_items:
		var kind := str(item.get("kind", "stat"))
		var key := str(item.get("key", ""))
		var val := int(item.get("value", 0))
		var is_primary := added == 0 and _story_result_item_is_attended(item, stage)
		var badge: Control
		if kind == "cast":
			var cast_name := _cast_display_name(key).to_upper()
			var sign := "+" if val > 0 else ""
			badge = _story_result_badge(
				cast_name, _tr("호감도 ", "Affinity ") + "%s%d" % [sign, val],
				Color("#c9b6df") if val > 0 else Color("#d99494"), is_primary)
		else:
			badge = _story_result_badge(
				str(_stat_display_name(key, str(STAT_INFO.get(key, {}).get("name", key)))).to_upper(),
				_story_result_value_text(key, val), _story_result_effect_color(key, val), is_primary)
		badge.name = "StoryResultBadge_%02d_%s" % [added + 1, ("cast_" + key) if kind == "cast" else key]
		badge.set_meta("attention_key", ("cast:" + key) if kind == "cast" else key)
		badge.set_meta("attention_kind", str(item.get("attention_kind", "other")))
		badge.set_meta("target_alpha", _story_result_item_alpha(item, stage))
		grid.add_child(badge)
		badges.append(badge)
		added += 1
	if added == 0:
		var empty_badge := _story_result_badge(
			_tr("기록", "LOG"), _tr("변화 없음", "No visible change"), dim_col)
		empty_badge.name = "StoryResultBadge_01_log"
		empty_badge.set_meta("attention_key", "log")
		empty_badge.set_meta("attention_kind", "other")
		empty_badge.set_meta("target_alpha", 1.0)
		grid.add_child(empty_badge)
		badges.append(empty_badge)

	if play_feedback:
		_animate_story_result_attention(card, badges, stage)
		_play_story_result_attention_cue(result_items, stage)
	else:
		card.modulate = Color.WHITE
		card.scale = Vector2.ONE
		for badge in badges:
			badge.modulate.a = float(badge.get_meta("target_alpha", 1.0))

func _story_choice_has_visible_result(choice: Dictionary) -> bool:
	var disp: Dictionary = _story_result_display_effects(choice.get("effects", {}))
	if not disp.is_empty():
		return true
	var cast_items: Array = _story_result_visible_cast_effects(choice.get("cast_effects", {}))
	return not cast_items.is_empty()

func _story_record_label(text: String, size: int, color: Color, bold: bool = false,
		depth_role: String = "") -> Label:
	var lbl := Label.new()
	lbl.text = text
	_register_story_font(lbl, "font_size", size)
	lbl.add_theme_color_override("font_color", color)
	lbl.clip_text = true
	lbl.autowrap_mode = TextServer.AUTOWRAP_OFF
	_apply_font(lbl, bold)
	if depth_role.is_empty():
		UIStyle.clear_ink_text_depth(lbl)
	else:
		UIStyle.apply_ink_text_depth(lbl, depth_role)
	return lbl

func _story_result_badge(label_text: String, value_text: String, accent: Color, primary: bool = false) -> Control:
	var badge := PanelContainer.new()
	badge.custom_minimum_size = Vector2(0, 46)
	badge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var palette := _story_palette()
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#0a0c11", 0.72).lerp(palette["choice_bg"], 0.30)
	st.border_color = accent.lerp(palette["panel_border"], 0.38 if primary else 0.58)
	st.set_border_width_all(1)
	if primary:
		st.border_width_left = 3
	st.set_corner_radius_all(5)
	st.content_margin_left = 9
	st.content_margin_right = 9
	st.content_margin_top = 6
	st.content_margin_bottom = 6
	UIStyle.apply_ink_surface_depth(st, 1, 0.28, 1)
	badge.add_theme_stylebox_override("panel", st)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 1)
	badge.add_child(box)
	box.add_child(_story_record_label(label_text, 9, palette["dead"], false))
	box.add_child(_story_record_label(value_text, 14 if primary else 13, accent, true, "state"))
	return badge

func _story_result_ordered_items(disp: Dictionary, cast_items: Array, stage: int) -> Array:
	var economic: Array = []
	var human: Array = []
	var other: Array = []
	var cast: Array = []
	var seen: Dictionary = {}
	_append_story_result_stat_items(economic, disp, RESULT_ECONOMIC_KEYS, "economic", seen)
	_append_story_result_stat_items(human, disp, RESULT_HUMAN_KEYS, "human", seen)
	_append_story_result_stat_items(other, disp, RESULT_OTHER_KEYS, "other", seen)
	for raw_key in disp.keys():
		var key := str(raw_key)
		if seen.has(key) or int(disp.get(key, 0)) == 0:
			continue
		other.append({"kind": "stat", "key": key, "value": int(disp[key]), "attention_kind": "other"})
	for raw_item in cast_items:
		cast.append({
			"kind": "cast",
			"key": str(raw_item.get("id", "")),
			"value": int(raw_item.get("affinity", 0)),
			"attention_kind": "human",
		})

	var ordered: Array = []
	if stage < 0:
		ordered.append_array(economic)
		ordered.append_array(other)
		ordered.append_array(human)
		ordered.append_array(cast)
	elif stage > 0:
		ordered.append_array(cast)
		ordered.append_array(human)
		ordered.append_array(other)
		ordered.append_array(economic)
	else:
		# Gray keeps the game's material premise first, but lets people enter before
		# the remaining utility ledger. No item receives a moral emphasis treatment.
		if not economic.is_empty():
			ordered.append(economic.pop_front())
		ordered.append_array(cast)
		ordered.append_array(human)
		ordered.append_array(economic)
		ordered.append_array(other)
	return ordered

func _append_story_result_stat_items(
		target: Array, disp: Dictionary, keys: Array[String], attention_kind: String,
		seen: Dictionary) -> void:
	for key in keys:
		var val := int(disp.get(key, 0))
		if val == 0:
			continue
		target.append({"kind": "stat", "key": key, "value": val, "attention_kind": attention_kind})
		seen[key] = true

func _story_result_visible_items(items: Array, stage: int, limit: int) -> Array:
	if items.size() <= limit:
		return items
	var visible: Array = []
	for index in range(mini(limit, items.size())):
		visible.append(items[index])
	# A perspective may delay a consequence, never erase it. Reserve the final
	# slot for the category this route is inclined to overlook.
	var counter_kind := "human" if stage < 0 else "economic" if stage > 0 else ""
	if counter_kind.is_empty():
		return visible
	for item in visible:
		if str(item.get("attention_kind", "")) == counter_kind:
			return visible
	for item in items:
		if str(item.get("attention_kind", "")) == counter_kind:
			visible[limit - 1] = item
			break
	return visible

func _story_result_item_is_attended(item: Dictionary, stage: int) -> bool:
	var kind := str(item.get("attention_kind", "other"))
	return (stage < 0 and kind == "economic") or (stage > 0 and kind == "human")

func _story_result_item_alpha(item: Dictionary, stage: int) -> float:
	if stage == 0 or _story_result_item_is_attended(item, stage):
		return 1.0
	var kind := str(item.get("attention_kind", "other"))
	var overlooked := (stage < 0 and kind == "human") or (stage > 0 and kind == "economic")
	if not overlooked:
		return 0.96
	return 0.82 if absi(stage) >= 2 else 0.89

func _animate_story_result_attention(card: Control, badges: Array[Control], stage: int) -> void:
	card.modulate = Color(1, 1, 1, 0)
	card.scale = Vector2(0.992, 0.992)
	for badge in badges:
		badge.modulate.a = 0.0
	var card_tw := create_tween()
	card_tw.tween_interval(0.05)
	card_tw.tween_property(card, "modulate:a", 1.0, 0.15).set_trans(Tween.TRANS_SINE)
	card_tw.parallel().tween_property(card, "scale", Vector2.ONE, 0.20).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	for index in range(badges.size()):
		var badge := badges[index]
		var target_alpha := float(badge.get_meta("target_alpha", 1.0))
		var badge_tw := create_tween()
		badge_tw.tween_interval(0.08 + float(index) * (0.095 if stage != 0 else 0.065))
		badge_tw.tween_property(badge, "modulate:a", target_alpha, 0.16).set_trans(Tween.TRANS_SINE)

func _play_story_result_attention_cue(items: Array, stage: int) -> void:
	if stage == 0 or items.is_empty():
		return
	var first_kind := str(items[0].get("attention_kind", "other"))
	var cue := ""
	if stage < 0 and first_kind == "economic":
		cue = "result_ledger"
	elif stage > 0 and first_kind == "human":
		cue = "result_human"
	if cue.is_empty():
		return
	var cue_tw := create_tween()
	cue_tw.tween_interval(0.11)
	cue_tw.tween_callback(func(): AudioManager.play(cue))

func _story_result_display_effects(eff: Dictionary) -> Dictionary:
	var disp: Dictionary = {}
	for raw_key in eff:
		var key := str(raw_key)
		if not _story_result_effect_visible(key):
			continue
		if typeof(eff[raw_key]) != TYPE_INT and typeof(eff[raw_key]) != TYPE_FLOAT:
			continue
		var val := int(eff[raw_key])
		if key == "stress":
			disp["mental"] = int(disp.get("mental", 0)) - val
		elif key == "mental":
			disp["mental"] = int(disp.get("mental", 0)) + val
		else:
			disp[key] = int(disp.get(key, 0)) + val
	return disp

func _story_result_effect_visible(key: String) -> bool:
	return key not in ["tint", "route_orthodox", "route_unorthodox"]

func _story_result_visible_cast_effects(_cast_effects: Dictionary) -> Array:
	# 관계는 표정·대사·후속 행동으로 읽힌다. 숫자를 공개하면 인물을
	# 공략식으로 환원하고, 다음 선택의 정답까지 미리 가르치게 된다.
	return []

func _story_result_tone_label(disp: Dictionary, cast_items: Array = []) -> Dictionary:
	var positive := 0
	var negative := 0
	for key in disp:
		var val := int(disp[key])
		if key in ["addiction_tendency", "gambling_tendency"]:
			val = -val
		if val > 0:
			positive += 1
		elif val < 0:
			negative += 1
	for cast_item in cast_items:
		var affinity := int(cast_item.get("affinity", 0))
		if affinity > 0:
			positive += 1
		elif affinity < 0:
			negative += 1
	if positive > 0 and negative > 0:
		return {"label": _tr("대가 있음", "TRADE-OFF"), "color": Color("#c8d0df")}
	if negative > 0:
		return {"label": _tr("손실", "COST"), "color": Color("#d99494")}
	if positive > 0:
		return {"label": _tr("성장", "GAIN"), "color": Color("#a9d8c1")}
	return {"label": _tr("기록", "LOG"), "color": Color("#8f98aa")}

func _story_result_effect_color(key: String, val: int) -> Color:
	if key in ["addiction_tendency", "gambling_tendency"]:
		return Color("#d99494") if val > 0 else Color("#a9d8c1")
	if val < 0:
		return Color("#d99494")
	if key == "money" or key == "monthly_income":
		return Color("#d8c48a")
	if key == "reputation":
		return Color("#b8c7d9")
	return Color("#a9d8c1")

func _story_result_value_text(key: String, val: int) -> String:
	if key == "money" or key == "monthly_income":
		if val >= 0:
			return "+%s" % _story_money(float(val))
		return "-%s" % _story_money(absf(float(val)))
	var sign := "+" if val > 0 else ""
	return "%s%d" % [sign, val]

func _choice_effect_preview(choice: Dictionary) -> String:
	var eff: Dictionary = choice.get("effects", {})
	if eff.is_empty():
		return ""
	var merged: Dictionary = {}
	for k in eff:
		if k == "stress":
			merged["mental"] = int(merged.get("mental", 0)) - int(eff[k])
		elif k == "mental":
			merged["mental"] = int(merged.get("mental", 0)) + int(eff[k])
		else:
			merged[k] = eff[k]
	# 즉각적으로 느껴지는 것만 표시 — 관계/스킬/평판은 숨김
	var priority := ["money", "health", "mental"]
	var parts: Array = []
	for key in priority:
		if not merged.has(key):
			continue
		var val: int = int(merged[key])
		if val == 0:
			continue
		var stat_name: String = _stat_display_name(key, str(STAT_INFO.get(key, {}).get("name", key)))
		var sign: String = "+" if val > 0 else ""
		if key == "money":
			parts.append("%s %s%s" % [stat_name, sign, _story_money(float(val))])
		else:
			parts.append("%s %s%d" % [stat_name, sign, val])
		if parts.size() >= 4:
			break
	return "  ".join(parts)

func _show_choices():
	_reset_advance_hold()
	_stop_story_choice_countdown()
	_clear_result_record_card()
	var choices: Array = _current.get("choices", [])
	if choices.is_empty():
		# 선택지 없는 이벤트 → 바로 다음
		_load_next_event()
		return
	_apply_story_surface_palette(_current_uses_cg)
	_showing_choices = true
	_set_choice_dock_active(true)
	_continue_hint.visible = false
	_choice_box.visible = true
	_choice_box.modulate = Color(1, 1, 1, 0)
	_set_portrait_choice_focus(true)
	# 유물 제시(역전재판식): requires_item 게이팅 — 보유한 유물만 선택지로 노출.
	# 표시 번호는 순차, 바인딩은 원래 인덱스 유지(_on_choice가 choices[idx]를 씀).
	var display_n := 0
	for i in _visible_choice_indices(_current):
		var ch: Dictionary = choices[i]
		display_n += 1
		# 버튼+미리보기를 묶어 그룹 컨테이너에 넣기
		var group := VBoxContainer.new()
		group.add_theme_constant_override("separation", 3)
		group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		group.modulate = Color(1, 1, 1, 0)
		group.scale = Vector2(0.986, 0.986)
		_choice_box.add_child(group)
		var base_text := str(ch.get("text", _tr("선택", "Choose")))
		var perceived_text: String = _moral_perception_text(ch.get("text_if_moral", {}), base_text)
		var btn = _make_choice_button(_fmt(perceived_text), i, display_n)
		group.add_child(btn)
	var tw := create_tween()
	tw.tween_property(_choice_box, "modulate:a", 1.0, 0.12)
	for i in range(_choice_box.get_child_count()):
		var group_node := _choice_box.get_child(i)
		tw.parallel().tween_property(group_node, "modulate:a", 1.0, 0.20).set_delay(0.04 * float(i))
		tw.parallel().tween_property(group_node, "scale", Vector2.ONE, 0.24).set_delay(0.04 * float(i)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# 컨트롤러: 첫 번째 그룹의 버튼에 포커스 (A 버튼으로 즉시 선택 가능)
	if _choice_box.get_child_count() > 0:
		var first_group = _choice_box.get_child(0)
		if first_group.get_child_count() > 0:
			first_group.get_child(0).grab_focus()
	if bool(_current.get("timed", false)) and not _read_only_replay:
		_start_story_choice_countdown(
			maxi(1, int(_current.get("timer_seconds", 12))),
			int(_current.get("timer_default_choice", 0)))

func _start_story_choice_countdown(seconds: int, default_index: int) -> void:
	_start_story_choice_countdown_msec(seconds * 1000, default_index, seconds * 1000)

func _start_story_choice_countdown_msec(
		duration_msec: int, default_index: int, total_msec: int = -1) -> void:
	var visible := _visible_choice_indices(_current)
	if visible.is_empty() or duration_msec <= 0:
		return
	_choice_countdown_default_index = default_index if visible.has(default_index) else int(visible[0])
	_choice_countdown_total_msec = maxi(duration_msec, total_msec if total_msec > 0 else duration_msec)
	_choice_countdown_deadline_msec = Time.get_ticks_msec() + duration_msec
	var duration_seconds := float(duration_msec) / 1000.0
	var total_seconds := float(_choice_countdown_total_msec) / 1000.0

	var timer_row := HBoxContainer.new()
	timer_row.name = "StoryChoiceCountdown"
	timer_row.add_theme_constant_override("separation", 14)
	timer_row.custom_minimum_size = Vector2(0, 36)
	_choice_box.add_child(timer_row)
	_choice_countdown_row = timer_row

	_choice_countdown_bar = ProgressBar.new()
	_choice_countdown_bar.name = "CountdownBar"
	_choice_countdown_bar.max_value = maxf(0.05, total_seconds)
	_choice_countdown_bar.value = duration_seconds
	_choice_countdown_bar.show_percentage = false
	_choice_countdown_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_choice_countdown_bar.custom_minimum_size = Vector2(0, 12)
	var timer_track := StyleBoxFlat.new()
	timer_track.bg_color = Color("#121820e6")
	timer_track.border_color = Color("#59616dbf")
	timer_track.set_border_width_all(1)
	timer_track.set_corner_radius_all(4)
	_choice_countdown_bar.add_theme_stylebox_override("background", timer_track)
	var timer_fill := StyleBoxFlat.new()
	timer_fill.bg_color = Color("#e0b35a")
	timer_fill.set_corner_radius_all(4)
	_choice_countdown_bar.add_theme_stylebox_override("fill", timer_fill)
	timer_row.add_child(_choice_countdown_bar)

	_choice_countdown_label = Label.new()
	_choice_countdown_label.name = "CountdownLabel"
	_choice_countdown_label.text = _tr("남은 시간  %d", "TIME LEFT  %d") % ceili(duration_seconds)
	_choice_countdown_label.custom_minimum_size = Vector2(168, 0)
	_choice_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_choice_countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_register_story_font(_choice_countdown_label, "font_size", 17)
	_choice_countdown_label.add_theme_color_override("font_color", Color("#f2c66d"))
	if _font_bold:
		_choice_countdown_label.add_theme_font_override("font", _font_bold)
	timer_row.add_child(_choice_countdown_label)

	_choice_countdown_timer = Timer.new()
	_choice_countdown_timer.wait_time = 0.05
	_choice_countdown_timer.autostart = true
	add_child(_choice_countdown_timer)
	_choice_countdown_timer.timeout.connect(_tick_story_choice_countdown)

func _tick_story_choice_countdown() -> void:
	if not _showing_choices or _transitioning:
		_stop_story_choice_countdown()
		return
	var remaining := maxf(0.0, float(_choice_countdown_deadline_msec - Time.get_ticks_msec()) / 1000.0)
	if is_instance_valid(_choice_countdown_bar):
		_choice_countdown_bar.value = remaining
	if is_instance_valid(_choice_countdown_label):
		var seconds_left := maxi(0, ceili(remaining))
		_choice_countdown_label.text = _tr("남은 시간  %d", "TIME LEFT  %d") % seconds_left
		if seconds_left <= 3:
			_choice_countdown_label.add_theme_color_override("font_color", Color("#ff7070"))
			if is_instance_valid(_choice_countdown_bar):
				var urgent_fill := StyleBoxFlat.new()
				urgent_fill.bg_color = Color("#d94b4b")
				urgent_fill.set_corner_radius_all(4)
				_choice_countdown_bar.add_theme_stylebox_override("fill", urgent_fill)
	if remaining <= 0.0:
		var default_index := _choice_countdown_default_index
		_stop_story_choice_countdown()
		_on_choice(default_index)

func _stop_story_choice_countdown() -> void:
	if is_instance_valid(_choice_countdown_timer):
		_choice_countdown_timer.stop()
		_choice_countdown_timer.queue_free()
	if is_instance_valid(_choice_countdown_row):
		_choice_countdown_row.queue_free()
	_choice_countdown_timer = null
	_choice_countdown_row = null
	_choice_countdown_bar = null
	_choice_countdown_label = null
	_choice_countdown_deadline_msec = 0
	_choice_countdown_total_msec = 0

## 선택지 노출 게이트 — requires_item 보유 시에만 표시(유물 제시 메커니즘).
## 향후 requires_flag/requires_not_flag 확장 여지. 없으면 항상 표시.
func _choice_visible(ch: Dictionary) -> bool:
	var need_item := str(ch.get("requires_item", ""))
	if need_item != "" and not GameState.has_item(need_item):
		return false
	return true

## 원본 선택지 인덱스를 유지한 채 현재 플레이어에게 보이는 선택지만 반환한다.
## UI와 히든 경로 QA가 이 함수를 공유해, 표시 번호와 실제 선택 배선이 갈라지지 않게 한다.
func _visible_choice_indices(event: Dictionary) -> Array[int]:
	var visible: Array[int] = []
	var choices: Array = event.get("choices", [])
	for i in range(choices.size()):
		var choice: Dictionary = choices[i]
		if _choice_visible(choice):
			visible.append(i)
	return visible

func _choice_follow_up_id(
		choice: Dictionary, event_id: String = "",
		choice_index: int = -1) -> String:
	var follow_up_id := str(choice.get("follow_up_event", ""))
	if DEMO_CORE_LOOP_V2.is_active() \
			and DEMO_CORE_LOOP_V2.story_follow_up_is_suppressed(
				event_id, choice_index, follow_up_id):
		return ""
	return follow_up_id

func _make_choice_button(text: String, idx: int, display_num: int = -1) -> Button:
	var btn = Button.new()
	var shown := display_num if display_num > 0 else idx + 1
	btn.text = "  %02d  %s" % [shown, text]
	btn.custom_minimum_size = Vector2(0, 60)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var palette := _story_palette()
	var choice_bg: Color = palette["choice_bg"]
	var choice_hover: Color = palette["choice_hover"]
	var panel_border: Color = palette["panel_border"]
	var focus_col: Color = palette["focus"]
	var text_col: Color = palette["text"]
	var normal = _story_panel_style(choice_bg, panel_border, 6, 18, 9, 3)
	var hover = normal.duplicate()
	hover.bg_color = choice_hover
	hover.border_color = focus_col
	var focus = normal.duplicate()
	focus.bg_color = choice_hover.lightened(0.05)
	focus.border_color = focus_col
	focus.border_width_left = 4
	focus.set_border_width_all(2)
	var pressed = normal.duplicate()
	pressed.bg_color = choice_bg.darkened(0.14)
	pressed.border_color = focus_col.darkened(0.12)
	UIStyle.apply_ink_surface_depth(normal, 1, 0.32, 1)
	UIStyle.apply_ink_surface_depth(hover, 2, 0.42, 1)
	UIStyle.apply_ink_surface_depth(focus, 2, 0.46, 1)
	UIStyle.apply_ink_pressed_depth(pressed, 1)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", focus)
	btn.add_theme_color_override("font_color", text_col)
	btn.add_theme_color_override("font_hover_color", focus_col)
	btn.add_theme_color_override("font_focus_color", focus_col)
	_register_story_font(btn, "font_size", 18)
	btn.set_meta("choice_index", idx)
	btn.set_meta("choice_display_num", shown)
	if _font:
		btn.add_theme_font_override("font", _font)
	UIStyle.apply_ink_text_depth(btn, "choice")
	btn.pressed.connect(_on_choice.bind(idx))
	_bind_story_tactile_button(btn, 1.0)
	return btn

## 선택 결과에만 속하는 CG/배경은 선택 전에 스포일러하지 않는다.
## 선택 키가 이벤트 공통 결과 키보다 우선한다. 지연 CG는 해당 결과 문단까지 현재 장면을 유지한다.
## result_cg가 result_background보다 우선하며, 배경 결과는 현재 인물 초상을 복원한다.
func _apply_choice_result_visual(choice: Dictionary) -> void:
	var result_cg_id := str(choice.get("result_cg", _current.get("result_cg", "")))
	if result_cg_id != "":
		var result_cg_path := ImageRegistry.get_cg(result_cg_id)
		if result_cg_path != "" and ImageRegistry.has_texture(result_cg_path):
			var reveal_paragraph: int = maxi(0, int(choice.get(
				"result_cg_reveal_paragraph",
				_current.get("result_cg_reveal_paragraph", 0))))
			if reveal_paragraph > 0:
				_event_cg_id = result_cg_id
				_event_cg_path = result_cg_path
				_event_cg_reveal_paragraph = reveal_paragraph
				return
			var result_cg_mode := (
				"finale"
				if DataRegistry.get_scene_direction_event_intent(
					str(_current.get("id", ""))) == "finale"
				else "time_cut")
			_begin_story_scene_transition(result_cg_mode)
			_bg_img.texture = ImageRegistry.load_texture(result_cg_path)
			_current_uses_cg = true
			_event_cg_id = result_cg_id
			_event_cg_path = result_cg_path
			if not _read_only_replay:
				MetaProgression.record_cg_unlocked(result_cg_id)
			_apply_story_surface_palette(true)
			_configure_living_scene()
			BGMPlayer.update_event_ambience(_current, result_cg_id)
			_show_portrait(_resolved_event_portrait_id(), true)
			if _hud_panel != null and is_instance_valid(_hud_panel):
				_hud_panel.visible = false
		return

	var result_background_id := _resolve_story_background_id(
		str(choice.get("result_background", _current.get("result_background", ""))))
	if result_background_id == "":
		return
	var result_background_path := ImageRegistry.get_background(result_background_id)
	if result_background_path == "" or not ImageRegistry.has_texture(result_background_path):
		return
	_begin_story_scene_transition("explicit_move")
	_bg_img.texture = ImageRegistry.load_texture(result_background_path)
	_event_background_id = result_background_id
	_current_uses_cg = false
	_apply_story_surface_palette(false)
	var result_event: Dictionary = _current.duplicate(true)
	result_event["background"] = result_background_id
	_configure_living_scene(result_event)
	_show_portrait(_resolved_event_portrait_id(), bool(_current.get("bg_focus", false)))
	var result_ambience := str(choice.get("result_ambience", "")).strip_edges()
	if result_ambience == "current_housing":
		BGMPlayer.update_idle_ambience()
	elif not result_ambience.is_empty():
		BGMPlayer.set_ambience(result_ambience)
		BGMPlayer.set_season_ambience("")
	else:
		BGMPlayer.update_event_ambience(result_event, "", result_background_id)
	if _hud_panel != null and is_instance_valid(_hud_panel):
		_hud_panel.visible = not _story_visual_override_active

func _on_choice(idx: int):
	if _transitioning or _story_scene_transition_active:
		return
	var choices: Array = _current.get("choices", [])
	if idx < 0 or idx >= choices.size():
		return
	_stop_story_choice_countdown()
	var choice: Dictionary = choices[idx]
	var current_event_id := str(_current.get("id", ""))
	var commitment_contract: Dictionary = EventManager.narrative_commitment_contract(
		current_event_id, GameState.turn) if not _read_only_replay else {}
	var owns_weekly_commitment := not commitment_contract.is_empty() \
			and not GameState.has_weekly_commitment_for_turn(GameState.turn)
	var commitment_person_id := str(commitment_contract.get("person_id", ""))
	var commitment_baseline: Dictionary = GameState.weekly_commitment_snapshot(
		commitment_person_id) if owns_weekly_commitment else {}
	_pending_result_choice_index = idx
	AudioManager.play("choice_made")
	AudioManager.pulse_gamepad(0.035, 0.070, 0.055)
	_play_story_ink_transition("choice", 0.65)
	_pulse_story_choice_commit()

	# follow_up_event를 직접 읽어 큐에 이어붙임 (StoryMode는 자체 큐 사용)
	_pending_follow_up = _choice_follow_up_id(
		choice, current_event_id, idx)
	var result: String = _fmt(str(choice.get("result_text", "")))
	var has_result_record: bool = not _read_only_replay \
		and result != "" and _story_choice_has_visible_result(choice)

	# 변화 스냅샷 (노출용) — 스탯 + 인물 관계
	var before = _snapshot_stats()
	var cast_before := {}
	for pid in choice.get("cast_effects", {}):
		cast_before[str(pid)] = GameState.get_cast_affinity(str(pid))
	if not _read_only_replay:
		GameState.apply_choice(_current, choice)
		if DEMO_CORE_LOOP_V2.is_active():
			DEMO_CORE_LOOP_V2.note_story_choice(current_event_id, idx)
		if owns_weekly_commitment:
			var forgone_choice_indexes: Array[int] = []
			for alternative_index in _visible_choice_indices(_current):
				if alternative_index != idx:
					forgone_choice_indexes.append(alternative_index)
			GameState.record_story_weekly_commitment(
				current_event_id, idx, commitment_baseline,
				forgone_choice_indexes, commitment_contract)
		# 서사 결과를 범용 튜토리얼로 가리지 않는다. 자원·AP 설명은 첫 AP 화면이 맡는다.
		# 결과 기록판이 있는 선택은 같은 변화를 우측 토스트로 반복 노출하지 않는다.
		if not has_result_record:
			_show_change_toasts(before)
			_show_cast_toasts(cast_before)

	# 결과 텍스트 표시
	_showing_choices = false
	_choice_box.visible = false
	_set_choice_dock_active(false)
	_set_portrait_choice_focus(false)
	for c in _choice_box.get_children():
		c.queue_free()
	_apply_choice_result_visual(choice)

	if result != "":
		if has_result_record:
			_show_story_result_record(choice)
		_apply_story_page_data(_story_page_data(result))
		_para_index = 0
		_pending_after_result = true
		AudioManager.play_scene_result_paragraph_cues(
			current_event_id, _event_cg_id, idx,
			_story_source_paragraph_index(_para_index))
		_start_typing(_paragraphs[0])
	else:
		_after_result()

func _after_result():
	_pending_after_result = false
	_pending_result_choice_index = -1
	_clear_result_record_card()
	_next_transition_mode = ""
	_next_transition_contract = {}
	# 선택의 follow_up_event가 있으면 큐 맨 앞에 끼워 이어서 재생한다. 정본
	# 전환 원장이 same_location으로 묶은 직접 후속만 새 장면 페이드를 생략한다.
	if _pending_follow_up != "" and not DataRegistry.find_event(_pending_follow_up).is_empty():
		var transition := DataRegistry.get_story_transition(
				str(_current.get("id", "")), _pending_follow_up)
		_next_transition_contract = transition.duplicate(true)
		_next_transition_mode = str(transition.get("mode", ""))
		_queue.push_front(_pending_follow_up)
	_pending_follow_up = ""
	# EventManager가 중복으로 쌓아둔 follow_up은 비워준다 (apply_choice 경유 안 함)
	_load_next_event()

func _chapter_card_advance():
	AudioManager.play("choice_made")
	var choices: Array = _current.get("choices", [])
	if choices.size() > 0 and not _read_only_replay:
		GameState.apply_choice(_current, choices[0])
	_load_next_event()

func _add_chapter_ink_frame(ov: Control, palette: Dictionary) -> void:
	var black: float = float(palette["black"])
	var white: float = float(palette["white"])
	var line_col: Color = palette["line"]
	var text_col: Color = palette["dim"]
	var rule_col := Color(line_col.r, line_col.g, line_col.b, 0.055 + black * 0.035 + white * 0.030)
	for x in [0.18, 0.50, 0.82]:
		var rule := ColorRect.new()
		rule.color = rule_col
		rule.anchor_left = x
		rule.anchor_right = x
		rule.anchor_top = 0.12
		rule.anchor_bottom = 0.88
		rule.offset_left = -0.5
		rule.offset_right = 0.5
		rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ov.add_child(rule)
	for y in [0.18, 0.34, 0.66, 0.82]:
		var rule := ColorRect.new()
		rule.color = rule_col
		rule.anchor_left = 0.16
		rule.anchor_right = 0.84
		rule.anchor_top = y
		rule.anchor_bottom = y
		rule.offset_top = -0.5
		rule.offset_bottom = 0.5
		rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ov.add_child(rule)

	var file_box := VBoxContainer.new()
	file_box.anchor_left = 0.08
	file_box.anchor_right = 0.32
	file_box.anchor_top = 0.12
	file_box.anchor_bottom = 0.24
	file_box.add_theme_constant_override("separation", 5)
	file_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ov.add_child(file_box)

	var case_lbl := Label.new()
	case_lbl.text = _tr("기록 번호", "CASE FILE")
	_register_story_font(case_lbl, "font_size", 11)
	case_lbl.add_theme_color_override("font_color", text_col)
	case_lbl.modulate.a = 0.42
	_apply_font(case_lbl)
	file_box.add_child(case_lbl)

	var run_lbl := Label.new()
	run_lbl.text = _tr("50만원 / 30억 / 5년", "500 thousand won / 3 billion won / 5 YEARS")
	_register_story_font(run_lbl, "font_size", 13)
	run_lbl.add_theme_color_override("font_color", Color("#d7dce5").lerp(Color("#f8fbff"), white * 0.45))
	run_lbl.modulate.a = 0.48
	_apply_font(run_lbl, true)
	file_box.add_child(run_lbl)

func _render_chapter_card_cinematic():
	_apply_story_surface_palette(false, true)
	var palette := _story_palette()
	var black: float = float(palette["black"])
	var white: float = float(palette["white"])
	var focus_col: Color = palette["focus"]
	var text_col: Color = palette["text"]
	var dim_col: Color = palette["dim"]
	var line_col: Color = palette["line"]
	# 배경: Gangnam Ink 챕터 카드
	_bg_img.texture = null
	_bg_dim.color = Color("#030405", 0.98).lerp(Color("#000000", 0.99), black).lerp(Color("#101820", 0.96), white)
	# 일반 UI 숨김
	_portrait_frame.visible = false
	_name_panel.visible = false
	_text_panel.visible = false
	_continue_hint.visible = false
	if _hud_panel != null and is_instance_valid(_hud_panel):
		_hud_panel.visible = false
	BGMPlayer.update_event_ambience(_current)

	# 오버레이 컨테이너
	var ov := Control.new()
	ov.set_anchors_preset(Control.PRESET_FULL_RECT)
	ov.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ov)
	_chapter_overlay = ov
	_add_chapter_ink_frame(ov, palette)

	# 중앙 VBox
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.anchor_left = 0.12
	vbox.anchor_right = 0.88
	vbox.anchor_top = 0.22
	vbox.anchor_bottom = 0.78
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 28)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ov.add_child(vbox)

	# ① 챕터 번호 — 작게, 차갑게
	var num_lbl := Label.new()
	num_lbl.name = "ChapterTitle"
	num_lbl.text = _fmt(str(_current.get("title", "")))
	num_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_register_story_font(num_lbl, "font_size", 15)
	num_lbl.add_theme_color_override("font_color", focus_col)
	num_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_font(num_lbl)
	num_lbl.modulate.a = 0.0
	vbox.add_child(num_lbl)

	# ② 구분선
	var sep := HSeparator.new()
	var sep_style := StyleBoxFlat.new()
	sep_style.bg_color = line_col
	sep_style.set_content_margin_all(0)
	sep.add_theme_stylebox_override("separator", sep_style)
	sep.custom_minimum_size.y = 1
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sep.modulate.a = 0.0
	vbox.add_child(sep)

	# ③ 본문 파싱 — 첫 줄 = 부제(크게), 나머지 = 설명(작게)
	var desc: String = _fmt(str(_current.get("description", "")))
	var all_lines: PackedStringArray = desc.split("\n")
	var subtitle: String = all_lines[0].strip_edges() if all_lines.size() > 0 else ""
	var body_parts: Array = []
	for i in range(1, all_lines.size()):
		var l: String = all_lines[i].strip_edges()
		if l != "":
			body_parts.append(l)
	var body_text: String = "\n".join(body_parts)

	# 부제 레이블 (크게)
	var sub_lbl := Label.new()
	sub_lbl.name = "ChapterSubtitle"
	sub_lbl.text = subtitle
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_register_story_font(sub_lbl, "font_size", 52)
	sub_lbl.add_theme_color_override("font_color", text_col)
	sub_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_font(sub_lbl, true)
	sub_lbl.modulate.a = 0.0
	vbox.add_child(sub_lbl)

	# 설명 레이블 (작게)
	var desc_lbl: RichTextLabel = null
	if body_text != "":
		desc_lbl = RichTextLabel.new()
		desc_lbl.name = "ChapterDescription"
		desc_lbl.bbcode_enabled = true
		desc_lbl.fit_content = true
		desc_lbl.scroll_active = false
		desc_lbl.text = "[center]" + body_text + "[/center]"
		_register_story_font(desc_lbl, "normal_font_size", 19)
		desc_lbl.add_theme_color_override("default_color", dim_col)
		if _font:
			desc_lbl.add_theme_font_override("normal_font", _font)
		desc_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		desc_lbl.modulate.a = 0.0
		vbox.add_child(desc_lbl)

	# 클릭 힌트 — 하단 고정
	var hint := Label.new()
	hint.name = "ChapterHint"
	hint.text = _tr("▼  Enter 또는 클릭", "▼  Enter or click")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_register_story_font(hint, "font_size", 13)
	hint.add_theme_color_override("font_color", palette["dead"])
	_apply_font(hint)
	hint.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hint.offset_bottom = -32
	hint.offset_top = -64
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.modulate.a = 0.0
	ov.add_child(hint)

	# 순차 페이드인 애니메이션
	var tw := create_tween()
	tw.tween_interval(0.15)
	tw.tween_property(num_lbl, "modulate:a", 1.0, 0.55).set_trans(Tween.TRANS_SINE)
	tw.tween_property(sep, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE)
	tw.tween_interval(0.1)
	tw.tween_property(sub_lbl, "modulate:a", 1.0, 0.75).set_trans(Tween.TRANS_SINE)
	if desc_lbl != null:
		tw.tween_interval(0.3)
		tw.tween_property(desc_lbl, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)
	tw.tween_interval(0.5)
	tw.tween_property(hint, "modulate:a", 0.55, 0.4).set_trans(Tween.TRANS_SINE)

func _refresh_chapter_card_language() -> void:
	if not is_instance_valid(_chapter_overlay):
		return
	var title := _chapter_overlay.find_child("ChapterTitle", true, false) as Label
	var subtitle := _chapter_overlay.find_child("ChapterSubtitle", true, false) as Label
	var description := _chapter_overlay.find_child("ChapterDescription", true, false) as RichTextLabel
	var hint := _chapter_overlay.find_child("ChapterHint", true, false) as Label
	if is_instance_valid(title):
		title.text = _fmt(str(_current.get("title", "")))
	var desc: String = _fmt(str(_current.get("description", "")))
	var lines: PackedStringArray = desc.split("\n")
	var subtitle_text := lines[0].strip_edges() if not lines.is_empty() else ""
	var body_parts: Array = []
	for index in range(1, lines.size()):
		var line := lines[index].strip_edges()
		if not line.is_empty():
			body_parts.append(line)
	if is_instance_valid(subtitle):
		subtitle.text = subtitle_text
	if is_instance_valid(description):
		description.text = "[center]%s[/center]" % "\n".join(body_parts)
	if is_instance_valid(hint):
		hint.text = _tr("▼  Enter 또는 클릭", "▼  Enter or click")

# ── 스탯 변화 노출 ────────────────────────────────────────────
func _snapshot_stats() -> Dictionary:
	return {
		"money": GameState.money,
		"health": GameState.health,
		"mental": GameState.mental,
		"intelligence": GameState.intelligence,
		"social_skill": GameState.social_skill,
		"investment_skill": GameState.investment_skill,
		"luck": GameState.luck,
	}

# 스탯 표시 정보: 한글/영문 이름
const STAT_INFO = {
	"money":            {"name": "돈", "name_en": "Money"},
	"health":           {"name": "건강", "name_en": "Health"},
	"mental":           {"name": "정신력", "name_en": "Mental"},
	"intelligence":     {"name": "지력", "name_en": "Intelligence"},
	"social_skill":     {"name": "사회성", "name_en": "Social"},
	"investment_skill": {"name": "투자감각", "name_en": "Investing"},
	"luck":             {"name": "운", "name_en": "Luck"},
	"reputation":       {"name": "평판", "name_en": "Reputation"},
	"appearance":       {"name": "외모", "name_en": "Appearance"},
	"addiction_tendency": {"name": "중독도", "name_en": "Addiction"},
	"gambling_tendency": {"name": "도박충동", "name_en": "Gambling Urge"},
	"work_performance": {"name": "업무성과", "name_en": "Performance"},
	"monthly_income":   {"name": "월수입", "name_en": "Monthly Income"},
}
const CAST_NAME_EN = {
	"father": "Father", "jiyeon": "Han Jiyeon", "daeun": "Kim Daeun",
	"jaehyuk": "Choi Jaehyuk", "sangchul": "Im Sangchul", "hyunsu": "Hyunsu",
}

## 스탯 표시 이름 — 현재 언어에 맞게
func _stat_display_name(key: String, ko_name: String) -> String:
	if LocaleManager.language == "en":
		return str(STAT_INFO.get(key, {}).get("name_en", key))
	return ko_name

## 인물 표시 이름 — 현재 언어에 맞게
func _cast_display_name(pid: String) -> String:
	if LocaleManager.language == "en":
		return str(CAST_NAME_EN.get(pid, pid))
	match pid:
		"father": return _tr("아버지", "Father")
		"jiyeon": return _tr("한지연", "Han Jiyeon")
		"daeun": return _tr("김다은", "Kim Daeun")
		"jaehyuk": return _tr("최재혁", "Choi Jaehyuk")
		"sangchul": return _tr("임상철", "Im Sangchul")
		"hyunsu": return _tr("현수", "Hyunsu")
	return pid

func _show_change_toasts(before: Dictionary):
	for key in before:
		var now = GameState.get(key)
		var diff = now - before[key]
		if abs(diff) < 0.01:
			continue
		var info = STAT_INFO.get(key, {"name": key})
		var disp_name = _stat_display_name(key, str(info["name"]))
		var txt = ""
		if key == "money":
			txt = "%s  %s%s" % [disp_name, "+" if diff > 0 else "-", _story_money(abs(diff))]
		else:
			txt = "%s  %s%d" % [disp_name, "+" if diff > 0 else "", int(diff)]
		# 스트레스는 +가 나쁨
		var good = diff > 0
		if key == "stress":
			good = diff < 0
		_spawn_toast(txt, Color("#00c896") if good else Color("#ff6b6b"))

## 관계 수치는 숨긴다. 변화는 같은 장면의 연기와 후속 사건이 회수한다.
func _show_cast_toasts(_before: Dictionary):
	pass

func _spawn_toast(text: String, color: Color):
	var palette := _story_palette()
	var chip_bg: Color = palette["choice_bg"]
	var panel_border: Color = palette["panel_border"]
	# 어두운 배경 칩 + 라벨 (배경에 안 묻히게)
	var chip = PanelContainer.new()
	chip.size_flags_horizontal = Control.SIZE_SHRINK_END
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var st = StyleBoxFlat.new()
	st.bg_color = chip_bg
	st.border_color = color.lerp(panel_border, 0.22)
	st.border_width_left = 3
	st.set_corner_radius_all(5)
	st.content_margin_left = 12
	st.content_margin_right = 14
	st.content_margin_top = 5
	st.content_margin_bottom = 5
	chip.add_theme_stylebox_override("panel", st)

	var lbl = Label.new()
	lbl.text = text
	_register_story_font(lbl, "font_size", 15)
	lbl.add_theme_color_override("font_color", color)
	lbl.autowrap_mode = TextServer.AUTOWRAP_OFF
	if _font_bold:
		lbl.add_theme_font_override("font", _font_bold)
	chip.add_child(lbl)

	_toast_layer.add_child(chip)
	var tw = create_tween()
	chip.modulate.a = 0
	tw.tween_property(chip, "modulate:a", 1.0, 0.2)
	tw.tween_interval(2.0)
	tw.tween_property(chip, "modulate:a", 0.0, 0.5)
	tw.tween_callback(chip.queue_free)

# ── 종료 ──────────────────────────────────────────────────────
func _finish_all():
	if _transitioning:
		return
	_transitioning = true
	_stop_story_choice_countdown()
	EventManager.current_event = {}
	_reset_scene_direction()
	BGMPlayer.enter_ambient_bed(0.75)
	BGMPlayer.update_idle_ambience()
	# MainGame 복귀만 주간 재시작을 막는다. 메인 메뉴 회상은 런 상태를 건드리지 않는다.
	GameState.returning_from_story = not _read_only_replay
	# 복귀 대상 (기본: MainGame)
	var ret = GameState.story_return_scene
	if ret == "":
		ret = "res://scenes/MainGame.tscn"
	GameState.story_return_scene = ""
	GameState.story_replay_mode = false
	SceneTransition.go(ret)

func _exit_tree() -> void:
	_stop_story_choice_countdown()
	GameState.story_replay_mode = false
	BGMPlayer.restore_ambience()

func _fmt(s: String) -> String:
	return GameState.format_event_text(s)

## UI 문자열 번역 헬퍼
func _tr(ko: String, en: String) -> String:
	return LocaleManager.ui(ko, en)
