extends Control

const GangnamWordmarkScript := preload("res://scenes/ui/GangnamWordmark.gd")
const LivingSceneLayerScript := preload("res://scenes/ui/LivingSceneLayer.gd")
const DemoCoreLoopV2Script := preload("res://systems/DemoCoreLoopV2.gd")
const BuildInfoScript := preload("res://systems/BuildInfo.gd")
const BuildFlavorScript := preload("res://systems/BuildFlavor.gd")
const THIRD_PARTY_NOTICE_PATH := "res://content/meta/third_party_notices.json"

const LAUNCH_REQUIRED_INPUT_GATES := 1
const NEW_STORY_SCENE := "res://scenes/OpeningCinematic.tscn"

# 드라마 모드: 루트/특성 선택 없이 김민준 33세 백수로 고정 시작.
# 성향(직장/투자/창업)은 플레이 중 선택 누적으로 자연스럽게 결정된다.

var slot_container: VBoxContainer
var _settings_overlay: ColorRect
var _notices_overlay: ColorRect
var _notices_origin_focus: Control = null
var _third_party_notices_control: Control = null
var _notices_tabs: Array[Button] = []
var _notices_content_margin: MarginContainer = null
var _notices_content: VBoxContainer = null
var _notices_scroll: ScrollContainer = null
var _notices_scroll_frame: Panel = null
var _notices_data: Dictionary = {}
var _load_overlay: ColorRect
var _archive_overlay: ColorRect
var _archive_preview_layer: ColorRect
var _archive_grid: GridContainer
var _archive_progress_label: Label
var _archive_page_label: Label
var _archive_prev_button: Button
var _archive_next_button: Button
var _archive_tab_buttons: Array[Button] = []
var _archive_origin_focus: Control = null
var _settings_origin_focus: Control = null
var _load_slot_page: int = 0
var _load_page_label: Label = null
var _load_prev_button: Button = null
var _load_next_button: Button = null
var _archive_tab: int = 0
var _archive_page: int = 0
var _title_command_buttons: Array[Button] = []
var _new_run_core_loop_v2_test := false
var _playtest_release_entry_ready_reported := false

var _splash_layer: Control
var _splash_active: bool = true
var _splash_prompt_tween: Tween = null

# ── 내부 시작 기본값 ─────────────────────────────────────────────
# 시작 화면에서는 선택 UI를 노출하지 않는다. 플레이어의 성향은 런 중 선택으로 갈린다.
var _selected_theme: String = "자유런"
var _theme_row: HBoxContainer
var _theme_desc_label: Label

var _selected_diff: String = "현실"
var _diff_row: HBoxContainer
var _diff_desc_label: Label

const RUN_THEMES = [
	{
		"id": "자유런",
		"icon_id": "goal",
		"name": "자유런",
		"tagline": "매 판 다른 이야기",
		"desc": "런마다 랜덤 카테고리 2개 부스트. 아무 제약 없음.",
		"diff": "★★★☆☆",
	},
	{
		"id": "투자런",
		"icon_id": "invest",
		"name": "투자런",
		"tagline": "돈으로 돈을 번다",
		"desc": "투자·재정 이벤트 집중. 투자감각 +5 시작. 시장 파동에 올라타라.",
		"diff": "★★★★☆",
	},
	{
		"id": "인맥런",
		"icon_id": "relationship",
		"name": "인맥런",
		"tagline": "사람이 자본이다",
		"desc": "사회·관계 이벤트 집중. 사교력 +10 시작. 연결이 돈이 된다.",
		"diff": "★★★☆☆",
	},
	{
		"id": "청렴런",
		"icon_id": "title",
		"name": "청렴런",
		"tagline": "도박 없이, 실력으로만",
		"desc": "도박 이벤트 완전 차단. 평판 +10 시작. 정직하게 30억.",
		"diff": "★★★★★",
	},
]

const UI_ICON_PATHS := {
	"goal": "res://assets/ui/icons/icon_goal.svg",
	"invest": "res://assets/ui/icons/icon_invest.svg",
	"relationship": "res://assets/ui/icons/icon_relationship.svg",
	"title": "res://assets/ui/icons/icon_title.svg",
	"mental": "res://assets/ui/icons/icon_mental.svg",
	"housing": "res://assets/ui/icons/icon_housing.svg",
	"stress": "res://assets/ui/icons/icon_stress.svg",
	"menu": "res://assets/ui/icons/icon_menu.svg",
}
var _ui_icon_cache: Dictionary = {}

# 첫 화면도 본편의 MORAL_TINT 언어와 이어지도록 금색/초록 CTA 대신 무채색 팔레트를 쓴다.
const MENU_ACCENT := "#d8dee8"
const MENU_ACCENT_BRIGHT := "#f4f7fb"
const MENU_ACCENT_DIM := "#818b98"
const MENU_PANEL := "#0d1017"
const MENU_PANEL_SELECTED := "#171b20"
const MENU_PANEL_MUTED := "#11141b"
const MENU_BORDER := "#242a34"
const MENU_BORDER_ACTIVE := "#d8e1ec"
const MENU_TEXT := "#d6dce4"
const MENU_TEXT_DIM := "#7b8490"
const MENU_TEXT_FAINT := "#3f4752"
const MENU_DANGER := "#6b1f1f"
const TITLE_KEY_ART := "res://assets/keyart/gangnam_dream_keyart_cast_v1.png"

const ARCHIVE_SCENE_IDS: Array[String] = [
	"arc_date_namsan_daeun", "arc_date_namsan_jiyeon",
	"arc_date_park_daeun", "arc_date_park_jiyeon",
	"arc_daeun_hometown_1", "arc_jiyeon_narrow_room_1",
	"arc_season_cherry_daeun", "arc_season_cherry_jiyeon",
	"arc_season_sea_daeun", "arc_season_sea_jiyeon",
	"arc_season_fireworks_daeun", "arc_season_fireworks_jiyeon",
	"arc_season_snow_daeun", "arc_season_snow_jiyeon",
	"arc_daeun_first_kiss", "arc_jiyeon_first_kiss",
	"arc_daeun_first_night", "arc_daeun_wedding_night", "arc_jiyeon_wedding_night",
	"v2_demo_first_bill_opening",
]
const ARCHIVE_HIDDEN_ACHIEVEMENTS: Array[String] = [
	"four_seasons", "kept_evidence", "drawer_truth", "dawn_people",
]
const ARCHIVE_PAGE_SIZE := [6, 6, 4]

const RUN_THEME_TEXT_EN := {
	"자유런": {
		"name": "Free Run",
		"tagline": "A different story every run",
		"desc": "Two random categories get boosted each run. No restrictions.",
	},
	"투자런": {
		"name": "Investor Run",
		"tagline": "Money makes money",
		"desc": "More investment and finance events. Start with +5 investment sense. Ride the market waves.",
	},
	"인맥런": {
		"name": "Network Run",
		"tagline": "People are capital",
		"desc": "More social and relationship events. Start with +10 social skill. Connections become money.",
	},
	"청렴런": {
		"name": "Clean Run",
		"tagline": "No gambling. Skill only.",
		"desc": "Blocks gambling events. Start with +10 reputation. Reach 3 billion the honest way.",
	},
}

const DIFFICULTY_TEXT_EN := {
	"드라마": {
		"name": "Drama Mode",
		"tagline": "Story first",
		"desc": "Start with KRW 2M / lighter monthly pressure / betting odds +4pp. For players here for the drama.",
	},
	"현실": {
		"name": "Reality Mode",
		"tagline": "Seoul as intended",
		"desc": "Default balance. KRW 500K, 5 years, KRW 3B. The intended tension.",
	},
	"지옥고": {
		"name": "Hell Room Mode",
		"tagline": "Seoul is like this",
		"desc": "Start with KRW 300K / harsher monthly pressure / betting odds -4pp. From a basement room to Gangnam.",
	},
}

static func release_v2_entry_count(playtest_build: bool) -> int:
	# Pure release policy: debug affordances do not count as a shipped entry.
	return 1 if playtest_build else 0

func _ready():
	SceneTransition.set_playtest_marker_context(
		SceneTransition.PLAYTEST_MARKER_CONTEXT_DEFAULT)
	var playtest_build := BuildFlavorScript.is_core_loop_v2_playtest_build()
	var artifact_identity := BuildInfoScript.artifact_identity()
	set_meta("launch_required_input_gates", LAUNCH_REQUIRED_INPUT_GATES)
	set_meta("new_story_scene", NEW_STORY_SCENE)
	for key in artifact_identity:
		set_meta(str(key), artifact_identity[key])
	set_meta(
		"release_v2_entry_count", release_v2_entry_count(playtest_build))
	BuildInfoScript.apply_window_title(get_window(), false, not LocaleManager.is_korean())
	_build_ui()
	_build_splash()
	BGMPlayer.start_menu()
	SceneTransition.fade_in()

func _tr(ko_text: String, en_text: String) -> String:
	return LocaleManager.ui(ko_text, en_text)

func _theme_text(theme: Dictionary, key: String) -> String:
	return LocaleManager.ui(
		str(theme.get(key, "")),
		str(RUN_THEME_TEXT_EN.get(
			str(theme.get("id", "")), {}).get(key, theme.get(key, ""))))

func _difficulty_text(did: String, data: Dictionary, key: String) -> String:
	return LocaleManager.ui(
		str(data.get(key, "")),
		str(DIFFICULTY_TEXT_EN.get(did, {}).get(key, data.get(key, ""))))

func _slot_title(slot: int) -> String:
	if slot == 0:
		return _tr("자동저장", "Autosave")
	return LocaleManager.ui_format("슬롯 %d", "Slot %d", slot, slot)

func _format_start_money(amount: float) -> String:
	if abs(amount) >= 1_000_000_000.0:
		return "KRW %.1fB" % (amount / 1_000_000_000.0)
	if abs(amount) >= 1_000_000.0:
		return "KRW %.1fM" % (amount / 1_000_000.0)
	if abs(amount) >= 1_000.0:
		return "KRW %.0fK" % (amount / 1_000.0)
	return "KRW %.0f" % amount

func _rebuild_language_ui(show_splash: bool = false) -> void:
	if _splash_prompt_tween and _splash_prompt_tween.is_running():
		_splash_prompt_tween.kill()
	_splash_prompt_tween = null
	_settings_overlay = null
	_load_overlay = null
	_archive_overlay = null
	_archive_preview_layer = null
	_archive_grid = null
	_archive_tab_buttons.clear()
	_settings_origin_focus = null
	_title_command_buttons.clear()
	for child in get_children():
		remove_child(child)
		child.queue_free()
	await get_tree().process_frame
	_build_ui()
	BuildInfoScript.apply_window_title(
		get_window(), DemoCoreLoopV2Script.requested(),
		not LocaleManager.is_korean())
	if show_splash:
		_build_splash()
	else:
		_splash_active = false

func _build_splash():
	_splash_layer = Control.new()
	_splash_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_splash_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_splash_layer)
	_build_title_backdrop(_splash_layer, true)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 58)
	margin.add_theme_constant_override("margin_right", 58)
	margin.add_theme_constant_override("margin_top", 56)
	margin.add_theme_constant_override("margin_bottom", 60)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_splash_layer.add_child(margin)

	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(410, 0)
	column.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)

	var upper_spacer := Control.new()
	upper_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(upper_spacer)

	column.add_child(_title_wordmark(74))

	var premise := Label.new()
	premise.text = _tr("통장 50만원. 남은 시간 5년.", "KRW 500K. Five years left.")
	premise.add_theme_font_size_override("font_size", 17)
	premise.add_theme_color_override("font_color", Color("#aab1ba"))
	premise.autowrap_mode = TextServer.AUTOWRAP_OFF
	column.add_child(premise)

	var rule := HSeparator.new()
	rule.custom_minimum_size = Vector2(320, 1)
	rule.add_theme_color_override("color", Color("#d8dee8", 0.34))
	column.add_child(rule)

	var press_lbl := Label.new()
	press_lbl.text = ("[%s]  " % ControllerHints.south() + _tr("시작", "START")) \
		if ControllerHints.is_pad_active() else _tr("아무 키나 누르세요", "PRESS ANY KEY")
	press_lbl.add_theme_font_size_override("font_size", 15)
	press_lbl.add_theme_color_override("font_color", Color("#d8dee8"))
	press_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	column.add_child(press_lbl)

	_splash_prompt_tween = create_tween()
	_splash_prompt_tween.set_loops()
	_splash_prompt_tween.tween_property(press_lbl, "modulate:a", 0.12, 0.75)
	_splash_prompt_tween.tween_property(press_lbl, "modulate:a", 1.0, 0.75)

func _build_title_backdrop(parent: Control, splash: bool = false) -> void:
	var base := ColorRect.new()
	base.color = Color("#08090c")
	base.set_anchors_preset(Control.PRESET_FULL_RECT)
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(base)

	# The launch image is one owned scene. Keeping the cast, room, street, and
	# reflections in a single painting prevents the title screen from reading as
	# layered portrait cards and gives every Steam crop the same visual identity.
	var key_art := _title_texture(TITLE_KEY_ART)
	key_art.set_anchors_preset(Control.PRESET_FULL_RECT)
	key_art.modulate = Color(1, 1, 1, 0.88 if splash else 0.94)
	_apply_title_grade(key_art, 0.18, 0.84 if splash else 0.91, 0.08, 3.0)
	parent.add_child(key_art)

	var atmosphere: LivingSceneLayer = LivingSceneLayerScript.new()
	atmosphere.name = "TitleAtmosphere"
	parent.add_child(atmosphere)
	atmosphere.configure(
		{
			"id": "start_menu_title",
			"living_scene": {"effect": "city_light", "intensity": 0.09 if splash else 0.06},
		},
		"gangnam_night_street",
		"",
		{"channel": "memory", "portrait_role": "none"},
		0.0,
		false,
		bool(SaveManager.get_setting(
			"reduce_motion", SaveManager.get_setting("reduced_motion", false))))

	var scrim := TextureRect.new()
	scrim.texture = _horizontal_scrim_texture()
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	scrim.stretch_mode = TextureRect.STRETCH_SCALE
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(scrim)

	var lower := ColorRect.new()
	lower.color = Color(0.02, 0.025, 0.035, 0.30)
	lower.anchor_left = 0.0
	lower.anchor_right = 1.0
	lower.anchor_top = 0.88
	lower.anchor_bottom = 1.0
	lower.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(lower)

func _title_texture(path: String) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = load(path)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect

func _apply_title_grade(rect: TextureRect, desaturation: float, brightness: float, edge_burn: float, seed: float) -> void:
	var shader := load("res://assets/shaders/background_grade.gdshader") as Shader
	if shader == null:
		return
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("desaturation", desaturation)
	material.set_shader_parameter("brightness", brightness)
	material.set_shader_parameter("contrast", 0.96)
	material.set_shader_parameter("grain_amount", 0.016)
	material.set_shader_parameter("ink_bleed", 0.045)
	material.set_shader_parameter("paper_fade", 0.012)
	material.set_shader_parameter("edge_burn", edge_burn)
	material.set_shader_parameter("print_screen", 0.010)
	material.set_shader_parameter("seed", seed)
	rect.material = material

func _horizontal_scrim_texture() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.22, 0.39, 1.0])
	gradient.colors = PackedColorArray([
		Color(0.018, 0.020, 0.026, 0.84),
		Color(0.018, 0.020, 0.026, 0.58),
		Color(0.018, 0.020, 0.026, 0.10),
		Color(0.018, 0.020, 0.026, 0.03),
	])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 1280
	texture.height = 8
	texture.fill_from = Vector2(0.0, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	return texture

func _title_wordmark(font_size: int = 66) -> VBoxContainer:
	var subtitle := LocaleManager.ui(
		"GANGNAM DREAM", "A KOREAN SOCIAL-REALITY DRAMA")
	return GangnamWordmarkScript.new(font_size, subtitle)

func _input(event):
	if _splash_active:
		var dismiss := false
		if event is InputEventKey and event.pressed and not event.echo:
			dismiss = true
		elif event is InputEventMouseButton and event.pressed:
			dismiss = true
		elif event is InputEventJoypadButton and event.pressed:
			dismiss = true
		if dismiss:
			get_viewport().set_input_as_handled()
			_dismiss_splash()
		return
	var major_direction := ControllerHints.major_direction(event)
	if is_instance_valid(_notices_overlay) and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close_third_party_notices()
		return
	if is_instance_valid(_notices_overlay) and major_direction != 0:
		get_viewport().set_input_as_handled()
		return
	if is_instance_valid(_settings_overlay) and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close_settings_popup()
		return
	if is_instance_valid(_settings_overlay) and major_direction != 0:
		get_viewport().set_input_as_handled()
		return
	if is_instance_valid(_load_overlay) and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close_load_overlay()
		return
	if is_instance_valid(_load_overlay) and major_direction != 0:
		get_viewport().set_input_as_handled()
		_set_load_slot_page(_load_slot_page + major_direction)
		return
	if is_instance_valid(_archive_preview_layer) and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close_archive_cg_preview()
		return
	if is_instance_valid(_archive_preview_layer):
		if major_direction != 0 or (
				event is InputEventJoypadButton and event.pressed and event.button_index in [
					JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_RIGHT_SHOULDER]):
			get_viewport().set_input_as_handled()
		return
	if is_instance_valid(_archive_overlay):
		if event.is_action_pressed("ui_cancel"):
			get_viewport().set_input_as_handled()
			_close_archive_overlay()
			return
		if event is InputEventJoypadButton and event.pressed:
			if event.button_index == JOY_BUTTON_LEFT_SHOULDER:
				get_viewport().set_input_as_handled()
				_set_archive_tab((_archive_tab + 2) % 3)
			elif event.button_index == JOY_BUTTON_RIGHT_SHOULDER:
				get_viewport().set_input_as_handled()
				_set_archive_tab((_archive_tab + 1) % 3)
		if major_direction != 0:
			get_viewport().set_input_as_handled()
			_change_archive_page(major_direction)
		return
	if major_direction != 0:
		# Title commands have no page/coarse action until a paged overlay is open.
		get_viewport().set_input_as_handled()

func _dismiss_splash():
	_splash_active = false
	set_meta("launch_required_input_gates", 0)
	set_meta("launch_gate_dismissed", true)
	if _splash_prompt_tween and _splash_prompt_tween.is_running():
		_splash_prompt_tween.kill()
	_splash_prompt_tween = null
	AudioManager.play("click")
	var tween = create_tween()
	tween.tween_property(_splash_layer, "modulate:a", 0.0, 0.25)
	tween.tween_callback(_splash_layer.queue_free)

func _build_ui():
	var playtest_build := BuildFlavorScript.is_core_loop_v2_playtest_build()
	_build_title_backdrop(self)
	_title_command_buttons.clear()

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 56)
	margin.add_theme_constant_override("margin_right", 44)
	margin.add_theme_constant_override("margin_top", 48)
	margin.add_theme_constant_override("margin_bottom", 46)
	add_child(margin)
	_add_build_identity_label()

	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(390, 0)
	column.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)

	column.add_child(_title_wordmark(64))

	var premise := Label.new()
	premise.text = _tr(
		"김민준, 33세. 통장 50만원. 남은 시간 5년.",
		"Kim Minjun, 33. KRW 500K. Five years left.")
	premise.add_theme_font_size_override("font_size", 15)
	premise.add_theme_color_override("font_color", Color("#b3bac4"))
	premise.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	premise.custom_minimum_size = Vector2(370, 0)
	column.add_child(premise)

	var subpremise := Label.new()
	subpremise.text = _tr(
		"어떤 사람이 되어 도착할지는, 아직 모른다.",
		"Who he becomes along the way is still unwritten.")
	subpremise.add_theme_font_size_override("font_size", 12)
	subpremise.add_theme_color_override("font_color", Color("#707985"))
	subpremise.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(subpremise)
	_add_mod_status_label(column)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)

	var latest_slot := _latest_save_slot()
	if latest_slot >= 0:
		var latest: Dictionary = SaveManager.get_save_info(latest_slot)
		var resume := Label.new()
		resume.text = LocaleManager.ui_format(
			"최근 기록  ·  %d년 %d월  ·  %s",
			"LAST RECORD  ·  %d / %02d  ·  %s",
			[
				int(latest.get("year", 2026)), int(latest.get("month", 1)),
				_format_money(latest.get("total_assets", 0))],
			[
				int(latest.get("year", 2026)), int(latest.get("month", 1)),
				_format_start_money(float(latest.get("total_assets", 0)))])
		resume.add_theme_font_size_override("font_size", 11)
		resume.add_theme_color_override("font_color", Color("#747e89"))
		column.add_child(resume)

	var menu := VBoxContainer.new()
	menu.custom_minimum_size = Vector2(360, 0)
	menu.add_theme_constant_override("separation", 5)
	column.add_child(menu)

	var continue_btn := _title_command_button(_tr("계속하기", "Continue"))
	continue_btn.disabled = latest_slot < 0
	if latest_slot >= 0:
		continue_btn.pressed.connect(func(): _load_slot(latest_slot))
	menu.add_child(continue_btn)

	var core_loop_cap_week := DemoCoreLoopV2Script.development_cap_week()
	var new_btn := _title_command_button(
		LocaleManager.ui_format(
			"%d주 데모 시작", "Start %d-Week Demo",
			core_loop_cap_week, core_loop_cap_week)
		if playtest_build else _tr("새 이야기", "New Story"))
	if playtest_build:
		new_btn.tooltip_text = LocaleManager.ui_format(
			"1~%d주 V2 데모를 별도 테스트 저장으로 시작합니다.",
			"Start the Weeks 1–%d V2 demo in a separate playtest save.",
			core_loop_cap_week, core_loop_cap_week)
		new_btn.set_meta("core_loop_v2_test_entry", true)
		new_btn.set_meta("build_entry_kind", "core_loop_v2_playtest")
		new_btn.pressed.connect(_start_core_loop_v2_test_run)
	else:
		new_btn.set_meta("build_entry_kind", "legacy")
		new_btn.pressed.connect(_start_new_run)
	menu.add_child(new_btn)

	if playtest_build:
		if not _playtest_release_entry_ready_reported:
			_playtest_release_entry_ready_reported = true
			print(
				"PLAYTEST_RELEASE_ENTRY_READY flavor=%s weeks=%d entries=%d" % [
					BuildFlavorScript.PLAYTEST_FLAVOR_ID,
					core_loop_cap_week,
					release_v2_entry_count(playtest_build),
				])
	elif OS.is_debug_build():
		var core_loop_v2_btn := _title_command_button(
			LocaleManager.ui_format(
				"Core Loop V2  ·  %d주 테스트",
				"Core Loop V2  ·  %d-Week Test",
				core_loop_cap_week, core_loop_cap_week), true)
		core_loop_v2_btn.tooltip_text = LocaleManager.ui_format(
			"현재 열린 1~%d주 월간 약속 구조를 별도 저장 상태로 시작합니다.",
			"Start the currently available Weeks 1–%d monthly-commitment slice with separate test save data.",
			core_loop_cap_week, core_loop_cap_week)
		core_loop_v2_btn.set_meta("core_loop_v2_test_entry", true)
		core_loop_v2_btn.set_meta("build_entry_kind", "core_loop_v2_debug")
		core_loop_v2_btn.pressed.connect(_start_core_loop_v2_test_run)
		menu.add_child(core_loop_v2_btn)

	var load_btn := _title_command_button(_tr("불러오기", "Load Game"))
	load_btn.pressed.connect(_open_load_overlay)
	menu.add_child(load_btn)

	var archive_btn := _title_command_button(LocaleManager.ui_context(
		"ui.navigation.archive", "기록", "Archive"))
	archive_btn.pressed.connect(_open_archive_overlay)
	menu.add_child(archive_btn)

	var options_btn := _title_command_button(_tr("설정", "Options"))
	options_btn.pressed.connect(_open_settings_popup)
	menu.add_child(options_btn)

	var quit_btn := _title_command_button(_tr("게임 종료", "Quit"), true)
	quit_btn.pressed.connect(func(): get_tree().quit())
	menu.add_child(quit_btn)

	var hint := Label.new()
	hint.text = ("[%s] %s" % [ControllerHints.south(), _tr("선택", "Select")]) \
		if ControllerHints.is_pad_active() else _tr(
			"방향키 이동  ·  Enter 선택  ·  Esc 뒤로",
			"Arrow keys move  ·  Enter selects  ·  Esc goes back")
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color("#66707b"))
	hint.custom_minimum_size = Vector2(0, 18)
	column.add_child(hint)

	_wire_title_command_focus()
	if latest_slot >= 0:
		continue_btn.call_deferred("grab_focus")
	else:
		new_btn.call_deferred("grab_focus")

func _wire_title_command_focus() -> void:
	# Dynamic title buttons do not always receive a stable geometric neighbour
	# in exported builds. Own the vertical route explicitly so keyboard arrows
	# and the pad D-pad skip disabled Continue and wrap predictably.
	var enabled: Array[Button] = []
	for button in _title_command_buttons:
		if is_instance_valid(button) and not button.disabled and button.visible:
			enabled.append(button)
	for index in range(enabled.size()):
		var button := enabled[index]
		var previous := enabled[(index - 1 + enabled.size()) % enabled.size()]
		var following := enabled[(index + 1) % enabled.size()]
		button.focus_neighbor_top = button.get_path_to(previous)
		button.focus_neighbor_bottom = button.get_path_to(following)
		button.focus_neighbor_left = button.get_path_to(button)
		button.focus_neighbor_right = button.get_path_to(button)
		button.focus_previous = button.get_path_to(previous)
		button.focus_next = button.get_path_to(following)

func _add_build_identity_label() -> void:
	var identity := Label.new()
	identity.name = "BuildIdentity"
	identity.text = BuildInfoScript.identity_label(false)
	identity.tooltip_text = identity.text
	identity.anchor_left = 1.0
	identity.anchor_top = 1.0
	identity.anchor_right = 1.0
	identity.anchor_bottom = 1.0
	identity.offset_left = -390.0
	identity.offset_top = -42.0
	identity.offset_right = -28.0
	identity.offset_bottom = -18.0
	identity.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	identity.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	identity.add_theme_font_size_override("font_size", 12)
	identity.add_theme_color_override("font_color", Color("#929ba6"))
	identity.mouse_filter = Control.MOUSE_FILTER_IGNORE
	identity.z_index = 12
	identity.set_meta("build_identity", true)
	add_child(identity)

func _title_command_button(text: String, quiet: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(360, 50)
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.mouse_entered.connect(button.grab_focus)
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", Color("#cbd1d8") if quiet else Color("#eef1f4"))
	button.add_theme_color_override("font_hover_color", Color("#ffffff"))
	button.add_theme_color_override("font_focus_color", Color("#ffffff"))
	button.add_theme_color_override("font_disabled_color", Color("#4e5661"))

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.035, 0.041, 0.052, 0.46)
	normal.border_color = Color("#68727e", 0.34)
	normal.border_width_left = 2
	normal.content_margin_left = 17
	normal.content_margin_right = 14
	normal.set_corner_radius_all(2)

	var hover := normal.duplicate()
	hover.bg_color = Color(0.075, 0.085, 0.102, 0.76)
	hover.border_color = Color("#c8d0d9", 0.74)
	hover.border_width_left = 4

	var pressed := hover.duplicate()
	pressed.bg_color = Color(0.025, 0.030, 0.038, 0.92)

	var focus := hover.duplicate()
	focus.bg_color = Color(0.095, 0.107, 0.124, 0.86)
	focus.border_color = Color("#f0f3f6")
	focus.border_width_left = 5
	focus.border_width_top = 1
	focus.border_width_right = 1
	focus.border_width_bottom = 1

	var disabled := normal.duplicate()
	disabled.bg_color = Color(0.02, 0.024, 0.031, 0.24)
	disabled.border_color = Color("#343b45", 0.30)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_stylebox_override("disabled", disabled)
	_title_command_buttons.append(button)
	return button

func _latest_save_slot() -> int:
	var latest_slot := -1
	var latest_stamp := ""
	for slot in range(0, SaveManager.SLOT_COUNT + 1):
		var info: Dictionary = SaveManager.get_save_info(slot)
		if (
			bool(info.get("empty", true))
			or not bool(info.get("compatible", false))
		):
			continue
		var stamp := str(info.get("saved_at", ""))
		if latest_slot < 0 or stamp > latest_stamp:
			latest_slot = slot
			latest_stamp = stamp
	return latest_slot

func _save_source_label(info: Dictionary) -> String:
	var source: Dictionary = info.get("source_identity", {})
	var flavor := str(source.get("build_flavor", "unknown"))
	var flavor_label := ""
	match flavor:
		"full":
			flavor_label = _tr("정식판", "Full")
		"demo":
			flavor_label = _tr("24주 데모", "24-Week Demo")
		"core_loop_v2_playtest":
			flavor_label = _tr("V2 테스트", "V2 Playtest")
		_:
			flavor_label = _tr("이전 버전", "Legacy Build")
	var build_id := str(source.get("build_id", "unknown"))
	if build_id == "unknown":
		return flavor_label
	return "%s · BUILD %s" % [flavor_label, build_id]

func _save_compatibility_note(info: Dictionary) -> String:
	if bool(info.get("compatible", false)):
		var warnings: Array = info.get("warnings", [])
		if warnings.has("build_id_mismatch") or warnings.has("game_version_mismatch"):
			return _tr("다른 빌드에서 저장됨", "Saved by another build")
		if warnings.has("demo_save_in_full_build"):
			return _tr("데모 기록 · 정식판에서 이어갈 수 있음",
				"Demo record · can continue in the full game")
		if (
			warnings.has("legacy_identity_unknown")
			or warnings.has("partial_build_identity")
		):
			return _tr("이전 저장 형식 · 호환 모드", "Older save format · compatibility mode")
		return ""
	match str(info.get("reason", "incompatible")):
		"future_save_version":
			return _tr("더 최신 버전의 저장 파일이라 열 수 없음",
				"Requires a newer game version")
		"full_save_in_demo", "demo_turn_limit":
			return _tr("24주 데모에서는 이 기록을 열 수 없음",
				"This record cannot be opened in the 24-week demo")
		"save_namespace_mismatch", "build_flavor_mismatch":
			return _tr("다른 테스트판의 분리된 기록", "Record from a separate test build")
		_:
			return _tr("호환되지 않거나 손상된 기록", "Incompatible or damaged record")

func _open_load_overlay() -> void:
	if is_instance_valid(_load_overlay):
		_load_overlay.queue_free()
	_load_slot_page = 0
	_delete_confirm_slot = -1

	_load_overlay = ColorRect.new()
	_load_overlay.color = Color(0.015, 0.018, 0.024, 0.90)
	_load_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_load_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_load_overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_load_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#0d1016", 0.98)
	panel_style.border_color = Color("#5d6773", 0.72)
	panel_style.set_border_width_all(1)
	panel_style.border_width_left = 4
	panel_style.set_corner_radius_all(4)
	panel_style.content_margin_left = 24
	panel_style.content_margin_right = 24
	panel_style.content_margin_top = 20
	panel_style.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	panel.add_child(body)

	var header := HBoxContainer.new()
	body.add_child(header)
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titles.add_theme_constant_override("separation", 2)
	header.add_child(titles)
	var title := Label.new()
	title.text = _tr("기록 불러오기", "Load Game")
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("#eef1f4"))
	titles.add_child(title)
	var note := Label.new()
	note.text = _tr("이어갈 시간을 선택하세요.", "Choose the life you want to continue.")
	note.add_theme_font_size_override("font_size", 12)
	note.add_theme_color_override("font_color", Color("#7b8490"))
	titles.add_child(note)

	var close_btn := Button.new()
	close_btn.text = "×"
	close_btn.tooltip_text = _tr("닫기", "Close")
	close_btn.custom_minimum_size = Vector2(44, 44)
	close_btn.add_theme_font_size_override("font_size", 22)
	close_btn.flat = true
	close_btn.pressed.connect(_close_load_overlay)
	header.add_child(close_btn)

	var rule := HSeparator.new()
	rule.add_theme_color_override("color", Color("#343b45"))
	body.add_child(rule)

	var pager := HBoxContainer.new()
	pager.custom_minimum_size = Vector2(0, 36)
	pager.add_theme_constant_override("separation", 8)
	body.add_child(pager)
	_load_prev_button = _title_command_button(
		"[%s]  %s" % [ControllerHints.trigger_l(), _tr("‹  슬롯 1–5", "‹  Slots 1–5")], true)
	_title_command_buttons.erase(_load_prev_button)
	_load_prev_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_load_prev_button.custom_minimum_size = Vector2(0, 36)
	_load_prev_button.pressed.connect(_set_load_slot_page.bind(0))
	pager.add_child(_load_prev_button)
	_load_page_label = Label.new()
	_load_page_label.custom_minimum_size = Vector2(92, 0)
	_load_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_load_page_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_load_page_label.add_theme_font_size_override("font_size", 12)
	_load_page_label.add_theme_color_override("font_color", Color(MENU_TEXT_DIM))
	pager.add_child(_load_page_label)
	_load_next_button = _title_command_button(
		"%s  [%s]" % [_tr("슬롯 6–10  ›", "Slots 6–10  ›"), ControllerHints.trigger_r()], true)
	_title_command_buttons.erase(_load_next_button)
	_load_next_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_load_next_button.custom_minimum_size = Vector2(0, 36)
	_load_next_button.pressed.connect(_set_load_slot_page.bind(1))
	pager.add_child(_load_next_button)

	slot_container = VBoxContainer.new()
	slot_container.add_theme_constant_override("separation", 6)
	body.add_child(slot_container)
	_rebuild_slots()

	var back := _title_command_button(_tr("뒤로", "Back"), true)
	_title_command_buttons.erase(back)
	back.custom_minimum_size = Vector2(0, 46)
	back.pressed.connect(_close_load_overlay)
	body.add_child(back)
	call_deferred("_focus_first_load_button")

func _focus_first_load_button() -> void:
	if not is_instance_valid(slot_container):
		return
	for row in slot_container.get_children():
		if row.is_queued_for_deletion():
			continue
		for node in row.find_children("*", "Button", true, false):
			if node is Button and not (node as Button).disabled:
				(node as Button).grab_focus()
				return
	# A fresh install can have no enabled load target. Keep keyboard/controller
	# focus inside the visible modal instead of leaving it on a hidden title CTA.
	var pager_fallback := _load_next_button if _load_slot_page == 0 else _load_prev_button
	if is_instance_valid(pager_fallback) and not pager_fallback.disabled:
		pager_fallback.grab_focus()

func _close_load_overlay() -> void:
	if is_instance_valid(_load_overlay):
		_load_overlay.queue_free()
	_load_overlay = null
	_load_page_label = null
	_load_prev_button = null
	_load_next_button = null
	for button in _title_command_buttons:
		if is_instance_valid(button) and not button.disabled:
			button.call_deferred("grab_focus")
			break

# ── 기록 / 회상 갤러리 ─────────────────────────────────────────
func _open_archive_overlay() -> void:
	if is_instance_valid(_archive_overlay):
		_archive_overlay.queue_free()
	_archive_origin_focus = get_viewport().gui_get_focus_owner()
	_archive_tab = 0
	_archive_page = 0
	_archive_tab_buttons.clear()

	_archive_overlay = ColorRect.new()
	_archive_overlay.name = "ArchiveOverlay"
	_archive_overlay.color = Color(0.008, 0.010, 0.014, 0.965)
	_archive_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_archive_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_archive_overlay.z_index = 60
	add_child(_archive_overlay)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 38)
	margin.add_theme_constant_override("margin_right", 38)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	_archive_overlay.add_child(margin)

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#0a0d12", 0.985)
	panel_style.border_color = Color("#59636f", 0.74)
	panel_style.set_border_width_all(1)
	panel_style.border_width_left = 4
	panel_style.set_corner_radius_all(4)
	panel_style.content_margin_left = 26
	panel_style.content_margin_right = 26
	panel_style.content_margin_top = 20
	panel_style.content_margin_bottom = 18
	panel.add_theme_stylebox_override("panel", panel_style)
	margin.add_child(panel)

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 11)
	panel.add_child(body)

	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 58)
	header.add_theme_constant_override("separation", 18)
	body.add_child(header)
	var heading := VBoxContainer.new()
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_theme_constant_override("separation", 2)
	header.add_child(heading)
	var title := _label(LocaleManager.ui_context(
		"ui.navigation.archive", "기록", "ARCHIVE"),
		27, "#f0f3f6", HORIZONTAL_ALIGNMENT_LEFT)
	title.add_theme_font_override("font", FontKit.ui_bold())
	heading.add_child(title)
	heading.add_child(_label(
		_tr("지나온 장면은 남지만, 다시 보는 선택은 현재를 바꾸지 않습니다.",
			"Scenes remain. Choices made here never rewrite the current life."),
		12, "#747e8a", HORIZONTAL_ALIGNMENT_LEFT))
	_archive_progress_label = _label("", 12, "#aeb7c2", HORIZONTAL_ALIGNMENT_RIGHT)
	_archive_progress_label.custom_minimum_size = Vector2(210, 0)
	_archive_progress_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(_archive_progress_label)
	var close_button := _archive_nav_button(_tr("닫기", "Close"), 92)
	close_button.pressed.connect(_close_archive_overlay)
	header.add_child(close_button)

	var tabs := HBoxContainer.new()
	tabs.custom_minimum_size = Vector2(0, 48)
	tabs.add_theme_constant_override("separation", 8)
	body.add_child(tabs)
	for tab_index in range(3):
		var tab_title: String = [
			_tr("CG", "CG"),
			_tr("명장면", "SCENE REPLAY"),
			_tr("비밀 기록", "HIDDEN RECORDS"),
		][tab_index]
		var tab_button := _archive_tab_button(tab_title, tab_index)
		_archive_tab_buttons.append(tab_button)
		tabs.add_child(tab_button)

	var rule := HSeparator.new()
	rule.add_theme_color_override("color", Color("#343b45", 0.85))
	body.add_child(rule)

	_archive_grid = GridContainer.new()
	_archive_grid.name = "ArchiveGrid"
	_archive_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_archive_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_archive_grid.add_theme_constant_override("h_separation", 12)
	_archive_grid.add_theme_constant_override("v_separation", 12)
	body.add_child(_archive_grid)

	var footer_rule := HSeparator.new()
	footer_rule.add_theme_color_override("color", Color("#252b34", 0.9))
	body.add_child(footer_rule)
	var footer := HBoxContainer.new()
	footer.custom_minimum_size = Vector2(0, 50)
	footer.add_theme_constant_override("separation", 10)
	body.add_child(footer)
	var pad_hint := _label(
		"[%s/%s] %s  ·  [%s/%s] %s" % [
			ControllerHints.shoulder_l(), ControllerHints.shoulder_r(),
			_tr("탭 이동", "Change tab"),
			ControllerHints.trigger_l(), ControllerHints.trigger_r(),
			_tr("페이지", "Page")],
		11, "#66707b", HORIZONTAL_ALIGNMENT_LEFT)
	pad_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	footer.add_child(pad_hint)
	_archive_prev_button = _archive_nav_button("[%s] %s" % [
		ControllerHints.trigger_l(), LocaleManager.ui_context(
			"ui.archive.previous_page", "이전", "Previous")], 128)
	_archive_prev_button.pressed.connect(_change_archive_page.bind(-1))
	footer.add_child(_archive_prev_button)
	_archive_page_label = _label("", 12, "#b9c1ca", HORIZONTAL_ALIGNMENT_CENTER)
	_archive_page_label.custom_minimum_size = Vector2(82, 0)
	_archive_page_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	footer.add_child(_archive_page_label)
	_archive_next_button = _archive_nav_button(
		"%s [%s]" % [_tr("다음", "Next"), ControllerHints.trigger_r()], 128)
	_archive_next_button.pressed.connect(_change_archive_page.bind(1))
	footer.add_child(_archive_next_button)

	_render_archive_page()

func _archive_tab_button(text: String, tab_index: int) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 46)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 14)
	button.pressed.connect(_set_archive_tab.bind(tab_index))
	return button

func _archive_apply_tab_styles() -> void:
	for index in range(_archive_tab_buttons.size()):
		var button := _archive_tab_buttons[index]
		if not is_instance_valid(button):
			continue
		var active := index == _archive_tab
		var normal := StyleBoxFlat.new()
		normal.bg_color = Color("#1a2028", 0.96) if active else Color("#0e1218", 0.84)
		normal.border_color = Color("#d9e0e8", 0.82) if active else Color("#343c47", 0.72)
		normal.set_border_width_all(1)
		normal.border_width_bottom = 3 if active else 1
		normal.set_corner_radius_all(3)
		var hover := normal.duplicate()
		hover.bg_color = Color("#202731", 0.98)
		hover.border_color = Color("#d9e0e8", 0.86)
		var focus := hover.duplicate()
		focus.set_border_width_all(2)
		button.add_theme_stylebox_override("normal", normal)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("pressed", hover)
		button.add_theme_stylebox_override("focus", focus)
		button.add_theme_color_override("font_color", Color("#f2f5f7") if active else Color("#818b97"))
		button.add_theme_color_override("font_focus_color", Color("#ffffff"))

func _archive_nav_button(text: String, width: int = 108) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(width, 42)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 13)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#10151c", 0.96)
	normal.border_color = Color("#3c4652", 0.86)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(3)
	var hover := normal.duplicate()
	hover.bg_color = Color("#1b222c", 0.98)
	hover.border_color = Color("#cfd6de", 0.82)
	var focus := hover.duplicate()
	focus.set_border_width_all(2)
	var disabled := normal.duplicate()
	disabled.bg_color = Color("#0a0d12", 0.72)
	disabled.border_color = Color("#252b33", 0.62)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", Color("#d8dee6"))
	button.add_theme_color_override("font_focus_color", Color("#ffffff"))
	button.add_theme_color_override("font_disabled_color", Color("#4c5560"))
	return button

func _set_archive_tab(tab_index: int) -> void:
	_archive_tab = clampi(tab_index, 0, 2)
	_archive_page = 0
	_render_archive_page()

func _change_archive_page(delta: int) -> void:
	var pages := _archive_page_count()
	var next_page := clampi(_archive_page + delta, 0, pages - 1)
	if next_page == _archive_page:
		return
	_archive_page = next_page
	_render_archive_page()

func _archive_page_count() -> int:
	var count := _archive_item_count()
	var page_size: int = ARCHIVE_PAGE_SIZE[_archive_tab]
	return maxi(1, int(ceili(float(count) / float(page_size))))

func _archive_item_count() -> int:
	match _archive_tab:
		0:
			return ImageRegistry.CG.size()
		1:
			return ARCHIVE_SCENE_IDS.size()
		_:
			return _archive_unlocked_hidden().size()

func _render_archive_page() -> void:
	if not is_instance_valid(_archive_grid):
		return
	for child in _archive_grid.get_children():
		child.queue_free()
	_archive_apply_tab_styles()
	_archive_page = clampi(_archive_page, 0, _archive_page_count() - 1)
	var page_size: int = ARCHIVE_PAGE_SIZE[_archive_tab]
	var start := _archive_page * page_size
	match _archive_tab:
		0:
			_archive_grid.columns = 3
			var cg_ids: Array = ImageRegistry.CG.keys()
			for index in range(start, mini(start + page_size, cg_ids.size())):
				_archive_grid.add_child(_archive_cg_card(str(cg_ids[index]), index))
		1:
			_archive_grid.columns = 2
			for index in range(start, mini(start + page_size, ARCHIVE_SCENE_IDS.size())):
				_archive_grid.add_child(_archive_scene_card(ARCHIVE_SCENE_IDS[index], index))
		_:
			var hidden := _archive_unlocked_hidden()
			if hidden.is_empty():
				_archive_grid.columns = 1
				_archive_grid.add_child(_archive_empty_hidden_state())
			else:
				_archive_grid.columns = 2
				for index in range(start, mini(start + page_size, hidden.size())):
					_archive_grid.add_child(_archive_hidden_card(hidden[index], index))
	_update_archive_status()
	call_deferred("_focus_first_archive_item")

func _update_archive_status() -> void:
	if is_instance_valid(_archive_progress_label):
		match _archive_tab:
			0:
				var unlocked := 0
				for cg_id in ImageRegistry.CG.keys():
					if MetaProgression.is_cg_unlocked(str(cg_id)):
						unlocked += 1
				_archive_progress_label.text = LocaleManager.ui_format(
					"CG  %d / %d", "CG  %d / %d",
					[unlocked, ImageRegistry.CG.size()],
					[unlocked, ImageRegistry.CG.size()])
			1:
				var seen := 0
				for scene_id in ARCHIVE_SCENE_IDS:
					if _archive_scene_has_valid_replay(scene_id):
						seen += 1
				_archive_progress_label.text = LocaleManager.ui_format(
					"회상  %d / %d", "SCENES  %d / %d",
					[seen, ARCHIVE_SCENE_IDS.size()],
					[seen, ARCHIVE_SCENE_IDS.size()])
			_:
				var hidden_count := _archive_unlocked_hidden().size()
				_archive_progress_label.text = LocaleManager.ui_format(
					"발견된 비밀  %d", "SECRETS FOUND  %d",
					hidden_count, hidden_count)
	var pages := _archive_page_count()
	if is_instance_valid(_archive_page_label):
		_archive_page_label.text = "%02d / %02d" % [_archive_page + 1, pages]
	if is_instance_valid(_archive_prev_button):
		_archive_prev_button.disabled = _archive_page <= 0
	if is_instance_valid(_archive_next_button):
		_archive_next_button.disabled = _archive_page >= pages - 1

func _archive_card_button(height: int) -> Button:
	var button := Button.new()
	button.text = ""
	button.clip_contents = true
	button.custom_minimum_size = Vector2(0, height)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#0f1319", 0.98)
	normal.border_color = Color("#343c47", 0.82)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(3)
	var hover := normal.duplicate()
	hover.bg_color = Color("#171d25", 0.99)
	hover.border_color = Color("#aeb8c3", 0.86)
	var focus := hover.duplicate()
	focus.border_color = Color("#f0f3f6")
	focus.set_border_width_all(3)
	var disabled := normal.duplicate()
	disabled.bg_color = Color("#090c10", 0.98)
	disabled.border_color = Color("#242a32", 0.76)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_stylebox_override("disabled", disabled)
	return button

func _archive_cg_card(cg_id: String, catalog_index: int) -> Button:
	var unlocked := MetaProgression.is_cg_unlocked(cg_id)
	var title := _archive_cg_title(cg_id, catalog_index)
	var button := _archive_card_button(210)
	button.name = "ArchiveCG_%02d" % (catalog_index + 1)
	button.disabled = not unlocked
	button.tooltip_text = title if unlocked else _tr("아직 보지 못한 장면", "A scene not yet witnessed")

	var path := ImageRegistry.get_cg(cg_id)
	if path != "" and ImageRegistry.has_texture(path):
		var preview := TextureRect.new()
		preview.texture = ImageRegistry.load_texture(path)
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		preview.set_anchors_preset(Control.PRESET_FULL_RECT)
		preview.offset_bottom = -50
		preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
		preview.modulate = Color.WHITE if unlocked else Color(0.10, 0.105, 0.115, 1.0)
		button.add_child(preview)
	var shade := ColorRect.new()
	shade.color = Color(0.005, 0.007, 0.010, 0.10 if unlocked else 0.76)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.offset_bottom = -50
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(shade)
	if not unlocked:
		var locked := _label(_tr("미해금", "LOCKED"), 13, "#59616c", HORIZONTAL_ALIGNMENT_CENTER)
		locked.set_anchors_preset(Control.PRESET_FULL_RECT)
		locked.offset_bottom = -50
		locked.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		locked.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(locked)

	var footer := ColorRect.new()
	footer.color = Color("#0b0e13", 0.98)
	footer.anchor_top = 1.0
	footer.anchor_right = 1.0
	footer.anchor_bottom = 1.0
	footer.offset_top = -50
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(footer)
	var footer_text := _label(
		("CG %02d  ·  %s" % [catalog_index + 1, title]) if unlocked else ("CG %02d  ·  ???" % [catalog_index + 1]),
		12, "#d8dee6" if unlocked else "#4c545e", HORIZONTAL_ALIGNMENT_LEFT)
	footer_text.set_anchors_preset(Control.PRESET_FULL_RECT)
	footer_text.offset_left = 14
	footer_text.offset_right = -12
	footer_text.clip_text = true
	footer_text.autowrap_mode = TextServer.AUTOWRAP_OFF
	footer_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	footer_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footer.add_child(footer_text)
	if unlocked:
		button.pressed.connect(_open_archive_cg_preview.bind(cg_id, title))
	return button

func _archive_scene_card(scene_id: String, catalog_index: int) -> Button:
	var event: Dictionary = DataRegistry.find_event(scene_id)
	var unlocked := _archive_scene_has_valid_replay(scene_id)
	var title := str(event.get("title", LocaleManager.ui_context(
		"ui.archive.record_fallback", "기록", "Record"))) if unlocked else "???"
	var button := _archive_card_button(142)
	button.name = "ArchiveScene_%02d" % (catalog_index + 1)
	button.disabled = not unlocked

	var image_path := _archive_event_visual_path(event, scene_id) \
		if unlocked else ""
	if image_path != "" and ImageRegistry.has_texture(image_path):
		var preview := TextureRect.new()
		preview.texture = ImageRegistry.load_texture(image_path)
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		preview.anchor_bottom = 1.0
		preview.custom_minimum_size = Vector2(176, 0)
		preview.offset_right = 176
		preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
		preview.modulate = Color(0.76, 0.78, 0.82, 1.0)
		button.add_child(preview)
		var image_shade := ColorRect.new()
		image_shade.color = Color(0.01, 0.015, 0.02, 0.24)
		image_shade.anchor_bottom = 1.0
		image_shade.offset_right = 176
		image_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(image_shade)

	var copy := VBoxContainer.new()
	copy.anchor_right = 1.0
	copy.anchor_bottom = 1.0
	copy.offset_left = 194 if image_path != "" else 18
	copy.offset_right = -18
	copy.offset_top = 18
	copy.offset_bottom = -16
	copy.add_theme_constant_override("separation", 7)
	copy.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(copy)
	copy.add_child(_label(_archive_scene_kind(scene_id), 10, "#77818d", HORIZONTAL_ALIGNMENT_LEFT))
	var title_label := _label(title, 18, "#edf1f5" if unlocked else "#4d5661", HORIZONTAL_ALIGNMENT_LEFT)
	title_label.add_theme_font_override("font", FontKit.ui_bold())
	title_label.clip_text = true
	title_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	copy.add_child(title_label)
	copy.add_child(_label(
		_tr("열람 전용 · 선택은 현재 기록을 바꾸지 않음", "READ ONLY · Choices do not alter the current life")
			if unlocked else _tr("이 장면을 본 뒤 열립니다.", "Unlocked after witnessing this scene."),
		11, "#8b95a1" if unlocked else "#4a525c", HORIZONTAL_ALIGNMENT_LEFT))
	if unlocked:
		button.pressed.connect(_replay_archive_scene.bind(scene_id))
	return button

func _archive_scene_has_valid_replay(scene_id: String) -> bool:
	if scene_id not in ARCHIVE_SCENE_IDS \
			or DataRegistry.find_event(scene_id).is_empty() \
			or not MetaProgression.has_valid_scene_replay_pair(scene_id):
		return false
	if scene_id == DemoCoreLoopV2Script.FIRST_BILL_OPENING_ID:
		return not DemoCoreLoopV2Script \
			.validated_complete_first_bill_replay_snapshot(
				MetaProgression.get_scene_replay_snapshot(scene_id)).is_empty()
	return true

func _archive_hidden_card(achievement: Dictionary, catalog_index: int) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 176)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#101319", 0.98)
	style.border_color = Color("#8e764c", 0.72)
	style.set_border_width_all(1)
	style.border_width_top = 3
	style.set_corner_radius_all(3)
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 18
	style.content_margin_bottom = 16
	card.add_theme_stylebox_override("panel", style)
	var copy := VBoxContainer.new()
	copy.add_theme_constant_override("separation", 8)
	card.add_child(copy)
	copy.add_child(_label(LocaleManager.ui_format(
		"비밀 기록 %02d", "HIDDEN RECORD %02d",
		catalog_index + 1, catalog_index + 1),
		10, "#9b8459", HORIZONTAL_ALIGNMENT_LEFT))
	var title: Label = _label(str(achievement.get("name", "")), 19, "#eef1f4", HORIZONTAL_ALIGNMENT_LEFT)
	title.add_theme_font_override("font", FontKit.ui_bold())
	copy.add_child(title)
	copy.add_child(_label(str(achievement.get("description", "")), 12, "#9ba4ae", HORIZONTAL_ALIGNMENT_LEFT))
	return card

func _archive_empty_hidden_state() -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 360)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#0b0e13", 0.96)
	style.border_color = Color("#252c35", 0.82)
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	card.add_theme_stylebox_override("panel", style)
	var empty := _label(
		_tr("아직 드러난 비밀 기록이 없습니다.", "No hidden records have surfaced."),
		15, "#59636f", HORIZONTAL_ALIGNMENT_CENTER)
	empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card.add_child(empty)
	return card

func _archive_unlocked_hidden() -> Array:
	var result: Array = []
	for achievement_id in ARCHIVE_HIDDEN_ACHIEVEMENTS:
		if not MetaProgression.is_achievement_unlocked(achievement_id):
			continue
		var info: Dictionary = DataRegistry.achievements_by_id.get(achievement_id, {})
		if not info.is_empty():
			result.append(info)
	return result

func _archive_cg_title(cg_id: String, catalog_index: int) -> String:
	for ending in DataRegistry.endings:
		if str(ending.get("cg", "")) == cg_id:
			return str(ending.get("title", _tr("엔딩 기록", "Finale Record")))
	for event in DataRegistry.events:
		if _archive_value_contains_cg(event, cg_id):
			return str(event.get("title", _tr("장면 기록", "Scene Record")))
	if cg_id == "cg_start":
		return _tr("시작의 기록", "The Beginning")
	return LocaleManager.ui_format(
		"장면 기록 %02d", "Scene Record %02d",
		catalog_index + 1, catalog_index + 1)

func _archive_value_contains_cg(value: Variant, cg_id: String) -> bool:
	if value is String:
		return str(value) == cg_id
	if value is Array:
		for item in value:
			if _archive_value_contains_cg(item, cg_id):
				return true
	elif value is Dictionary:
		for key in value:
			if _archive_value_contains_cg(value[key], cg_id):
				return true
	return false

func _archive_event_visual_path(
		event: Dictionary, scene_id: String = "") -> String:
	var cg_id := str(event.get("cg", ""))
	if cg_id != "":
		var cg_path := ImageRegistry.get_cg(cg_id)
		if cg_path != "":
			return cg_path
	var bg_id := str(event.get("background", ""))
	if bg_id == "current_housing":
		var snapshot := MetaProgression.get_scene_replay_snapshot(scene_id)
		if snapshot.is_empty():
			return ""
		match str(snapshot.get("housing", "")):
			"gangnam", "apartment":
				bg_id = "gangnam_apartment"
			"villa", "oneroom":
				bg_id = "apartment"
			"gosiwon":
				bg_id = "goshiwon_room"
			_:
				return ""
	elif bg_id == "current_workplace":
		# Gallery schema 1 has no frozen occupation. Never build an archive card
		# from whichever live job happens to be loaded behind the menu.
		return ""
	if bg_id != "":
		return ImageRegistry.get_background(bg_id)
	return ""

func _archive_scene_kind(scene_id: String) -> String:
	if "season_" in scene_id:
		return _tr("계절의 기록", "SEASONAL STORY")
	if "first_kiss" in scene_id:
		return _tr("첫 키스", "FIRST KISS")
	if "first_night" in scene_id or "wedding_night" in scene_id:
		return _tr("그 밤", "THE NIGHT")
	return _tr("특별한 이야기", "SPECIAL STORY")

func _open_archive_cg_preview(cg_id: String, title: String) -> void:
	if not is_instance_valid(_archive_overlay) or not MetaProgression.is_cg_unlocked(cg_id):
		return
	var path := ImageRegistry.get_cg(cg_id)
	if path == "" or not ImageRegistry.has_texture(path):
		return
	if is_instance_valid(_archive_preview_layer):
		_archive_preview_layer.queue_free()
	_archive_preview_layer = ColorRect.new()
	_archive_preview_layer.name = "ArchiveCGPreview"
	_archive_preview_layer.color = Color(0.002, 0.003, 0.005, 1.0)
	_archive_preview_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_archive_preview_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	_archive_preview_layer.z_index = 10
	_archive_overlay.add_child(_archive_preview_layer)
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 56)
	margin.add_theme_constant_override("margin_right", 56)
	margin.add_theme_constant_override("margin_top", 36)
	margin.add_theme_constant_override("margin_bottom", 32)
	_archive_preview_layer.add_child(margin)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	margin.add_child(body)
	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 48)
	body.add_child(header)
	var title_label := _label(title, 20, "#eef2f5", HORIZONTAL_ALIGNMENT_LEFT)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_label)
	var close_button := _archive_nav_button(_tr("돌아가기", "Back"), 118)
	close_button.pressed.connect(_close_archive_cg_preview)
	header.add_child(close_button)
	var image_panel := PanelContainer.new()
	image_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var frame := StyleBoxFlat.new()
	frame.bg_color = Color("#05070a")
	frame.border_color = Color("#56606b", 0.74)
	frame.set_border_width_all(1)
	frame.set_corner_radius_all(3)
	frame.content_margin_left = 8
	frame.content_margin_right = 8
	frame.content_margin_top = 8
	frame.content_margin_bottom = 8
	image_panel.add_theme_stylebox_override("panel", frame)
	body.add_child(image_panel)
	var image := TextureRect.new()
	image.texture = ImageRegistry.load_texture(path)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image_panel.add_child(image)
	close_button.call_deferred("grab_focus")

func _close_archive_cg_preview() -> void:
	if is_instance_valid(_archive_preview_layer):
		_archive_preview_layer.queue_free()
	_archive_preview_layer = null
	call_deferred("_focus_first_archive_item")

func _replay_archive_scene(scene_id: String) -> void:
	if not _archive_scene_has_valid_replay(scene_id):
		# Remain on the menu and remove any stale launch authority. A direct or
		# damaged replay request must not fall through into live StoryMode state.
		GameState.pending_story_queue.clear()
		GameState.story_return_scene = "res://scenes/StartMenu.tscn"
		GameState.returning_from_story = false
		GameState.story_replay_mode = false
		return
	GameState.pending_story_queue = [scene_id]
	GameState.story_return_scene = "res://scenes/StartMenu.tscn"
	GameState.returning_from_story = false
	GameState.story_replay_mode = true
	SceneTransition.go("res://scenes/StoryMode.tscn")

func _focus_first_archive_item() -> void:
	if not is_instance_valid(_archive_grid):
		return
	for node in _archive_grid.get_children():
		if node is Button and not (node as Button).disabled:
			(node as Button).grab_focus()
			return
	if _archive_tab < _archive_tab_buttons.size() and is_instance_valid(_archive_tab_buttons[_archive_tab]):
		_archive_tab_buttons[_archive_tab].grab_focus()

func _close_archive_overlay() -> void:
	if is_instance_valid(_archive_preview_layer):
		_archive_preview_layer.queue_free()
	_archive_preview_layer = null
	if is_instance_valid(_archive_overlay):
		_archive_overlay.queue_free()
	_archive_overlay = null
	_archive_grid = null
	_archive_tab_buttons.clear()
	if is_instance_valid(_archive_origin_focus):
		_archive_origin_focus.call_deferred("grab_focus")
	else:
		for button in _title_command_buttons:
			if is_instance_valid(button) and not button.disabled:
				button.call_deferred("grab_focus")
				break
	_archive_origin_focus = null

func _start_brief_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#0a0c12", 0.68)
	st.border_color = Color("#2a313d", 0.86)
	st.set_border_width_all(1)
	st.border_width_left = 3
	st.set_corner_radius_all(7)
	st.content_margin_left = 14
	st.content_margin_right = 14
	st.content_margin_top = 12
	st.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", st)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 9)
	panel.add_child(box)

	var eyebrow := _label(_tr("시작 기록", "STARTING RECORD"), 10, MENU_TEXT_FAINT, HORIZONTAL_ALIGNMENT_LEFT)
	eyebrow.autowrap_mode = TextServer.AUTOWRAP_OFF
	eyebrow.clip_text = false
	box.add_child(eyebrow)

	var title := _label(_tr("정해진 조건, 갈라지는 선택", "Fixed terms, branching choices"), 15, MENU_ACCENT, HORIZONTAL_ALIGNMENT_LEFT)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(title)

	box.add_child(_sep())
	box.add_child(_start_brief_row("housing", _tr("통장 50만원", "KRW 500,000"), _tr("빚을 다 갚고 남은 전부. 고시원 방 한 칸에서 시작한다", "All that's left after the debts. It starts in a goshiwon room")))
	box.add_child(_start_brief_row("goal", _tr("같은 시작, 다른 이야기", "Same start, different story"), _tr("사건과 사람은 매번 조금씩 다르게 찾아온다", "Events and people arrive a little differently every time")))
	box.add_child(_start_brief_row("mental", _tr("5년 안에 30억", "KRW 3B in five years"), _tr("강남은 목표지만, 사람은 선택으로 변한다", "Gangnam is the goal; choices change the person")))
	return panel

func _start_brief_row(icon_id: String, top_text: String, sub_text: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_menu_icon(icon_id, Color(MENU_TEXT_DIM), 19))

	var text_box := VBoxContainer.new()
	text_box.add_theme_constant_override("separation", 1)
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text_box)

	var top := Label.new()
	top.text = top_text
	top.add_theme_font_size_override("font_size", 12)
	top.add_theme_color_override("font_color", Color(MENU_TEXT))
	top.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_box.add_child(top)

	var sub := Label.new()
	sub.text = sub_text
	sub.add_theme_font_size_override("font_size", 10)
	sub.add_theme_color_override("font_color", Color(MENU_TEXT_FAINT))
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_box.add_child(sub)
	return row

# ── 슬롯 목록 빌드 / 새로고침 ─────────────────────────────────
func _rebuild_slots():
	for child in slot_container.get_children():
		child.queue_free()

	for slot in _visible_load_slots():
		var info = SaveManager.get_save_info(slot)
		var top_line = _slot_title(slot)
		var sub_line = ""
		if info.get("empty", true):
			sub_line = _tr("비어 있음", "Empty")
		else:
			top_line += "  ·  " + _save_source_label(info)
			sub_line = LocaleManager.ui_format(
				"챕터 %d · %d주차  ·  %s",
				"Chapter %d · Week %d  ·  %s",
				[
					info.get("chapter", 1), info.get("turn", 1),
					_format_money(info.get("total_assets", 0))
				],
				[
					info.get("chapter", 1), info.get("turn", 1),
					_format_start_money(float(info.get("total_assets", 0)))
				])
			var label := str(info.get("label", "")).strip_edges()
			if not label.is_empty():
				top_line += "  ·  " + label
			var compatibility_note := _save_compatibility_note(info)
			if not compatibility_note.is_empty():
				sub_line = compatibility_note + "  ·  " + sub_line
		var occupied: bool = not bool(info.get("empty", true))
		var enabled: bool = occupied and bool(info.get("compatible", false))

		# 슬롯 행: [슬롯 버튼] + [삭제 버튼]
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		slot_container.add_child(row)

		var cb = Callable()
		if enabled:
			cb = func(): _load_slot(slot)
		var slot_panel = _slot_button(top_line, sub_line, enabled, cb)
		slot_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(slot_panel)

		# 삭제 버튼 (데이터가 있을 때만 표시)
		if occupied:
			var del_btn := _delete_slot_button(false)
			del_btn.pressed.connect(func(): _confirm_delete(slot))
			row.add_child(del_btn)
	_refresh_load_slot_pager()

var _delete_confirm_slot: int = -1

func _confirm_delete(slot: int):
	if _delete_confirm_slot == slot:
		# 두 번째 클릭 → 실제 삭제
		SaveManager.delete_save(slot)
		_delete_confirm_slot = -1
		_rebuild_slots()
	else:
		# 첫 번째 클릭 → 확인 대기 상태로 전환 후 슬롯 다시 그림
		_delete_confirm_slot = slot
		_rebuild_slots_with_confirm(slot)

func _rebuild_slots_with_confirm(confirm_slot: int):
	# _rebuild_slots와 동일하되, confirm_slot의 삭제 버튼을 "확인?" 상태로 표시
	for child in slot_container.get_children():
		child.queue_free()

	for slot in _visible_load_slots():
		var info = SaveManager.get_save_info(slot)
		var top_line = _slot_title(slot)
		var sub_line = ""
		if info.get("empty", true):
			sub_line = _tr("비어 있음", "Empty")
		else:
			top_line += "  ·  " + _save_source_label(info)
			sub_line = LocaleManager.ui_format(
				"챕터 %d · %d주차  ·  %s",
				"Chapter %d · Week %d  ·  %s",
				[
					info.get("chapter", 1), info.get("turn", 1),
					_format_money(info.get("total_assets", 0))
				],
				[
					info.get("chapter", 1), info.get("turn", 1),
					_format_start_money(float(info.get("total_assets", 0)))
				])
			var label := str(info.get("label", "")).strip_edges()
			if not label.is_empty():
				top_line += "  ·  " + label
			var compatibility_note := _save_compatibility_note(info)
			if not compatibility_note.is_empty():
				sub_line = compatibility_note + "  ·  " + sub_line
		var occupied: bool = not bool(info.get("empty", true))
		var enabled: bool = occupied and bool(info.get("compatible", false))

		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		slot_container.add_child(row)

		var cb = Callable()
		if enabled and slot != confirm_slot:
			cb = func(): _load_slot(slot)
		var slot_panel = _slot_button(top_line, sub_line, enabled and slot != confirm_slot, cb)
		slot_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(slot_panel)

		if occupied:
			var is_confirm = (slot == confirm_slot)
			var del_btn := _delete_slot_button(is_confirm)
			del_btn.pressed.connect(func(): _confirm_delete(slot))
			row.add_child(del_btn)

			# 확인 대기 중이면 취소 버튼 추가
			if is_confirm:
				var cancel_btn = Button.new()
				cancel_btn.text = _tr("취소", "Cancel")
				cancel_btn.custom_minimum_size = Vector2(44, 48)
				var cancel_st = StyleBoxFlat.new()
				cancel_st.bg_color = Color("#1a1a28")
				cancel_st.border_color = Color("#3a3a50")
				cancel_st.set_border_width_all(1)
				cancel_st.set_corner_radius_all(6)
				cancel_btn.add_theme_stylebox_override("normal", cancel_st)
				cancel_btn.add_theme_font_size_override("font_size", 11)
				cancel_btn.add_theme_color_override("font_color", Color("#6a7590"))
				cancel_btn.pressed.connect(func():
					_delete_confirm_slot = -1
					_rebuild_slots()
				)
				row.add_child(cancel_btn)
	_refresh_load_slot_pager()

func _visible_load_slots() -> Array[int]:
	var slots: Array[int] = []
	if _load_slot_page == 0:
		slots.append(SaveManager.AUTOSAVE_SLOT)
		for slot in range(1, 6):
			slots.append(slot)
	else:
		for slot in range(6, SaveManager.SLOT_COUNT + 1):
			slots.append(slot)
	return slots

func _set_load_slot_page(page: int) -> void:
	var next_page := clampi(page, 0, 1)
	if next_page == _load_slot_page:
		return
	_load_slot_page = next_page
	_delete_confirm_slot = -1
	_rebuild_slots()
	call_deferred("_focus_first_load_button")

func _refresh_load_slot_pager() -> void:
	if is_instance_valid(_load_page_label):
		_load_page_label.text = LocaleManager.ui_format(
			"페이지 %d / 2", "Page %d / 2",
			_load_slot_page + 1, _load_slot_page + 1)
	if is_instance_valid(_load_prev_button):
		_load_prev_button.disabled = _load_slot_page == 0
	if is_instance_valid(_load_next_button):
		_load_next_button.disabled = _load_slot_page == 1

func _delete_slot_button(is_confirm: bool) -> Button:
	var del_btn := Button.new()
	del_btn.text = _tr("삭제 확인", "Delete?") if is_confirm else "X"
	del_btn.tooltip_text = _tr("저장 삭제", "Delete save")
	del_btn.custom_minimum_size = Vector2(58, 48) if is_confirm else Vector2(36, 48)
	del_btn.flat = false

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#351515") if is_confirm else Color("#10131a")
	normal.border_color = Color("#e65a5a") if is_confirm else Color("#2c3440")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(6)

	var hover := normal.duplicate()
	hover.bg_color = Color("#4a1b1b") if is_confirm else Color("#17141a")
	hover.border_color = Color("#ff7777") if is_confirm else Color("#6f3a3a")

	var pressed := hover.duplicate()
	pressed.bg_color = Color("#2a1010") if is_confirm else Color("#0b0d12")

	var focus := normal.duplicate()
	focus.border_color = Color("#f4f7fb") if not is_confirm else Color("#ff9a9a")
	focus.set_border_width_all(2)

	del_btn.add_theme_stylebox_override("normal", normal)
	del_btn.add_theme_stylebox_override("hover", hover)
	del_btn.add_theme_stylebox_override("pressed", pressed)
	del_btn.add_theme_stylebox_override("focus", focus)
	del_btn.add_theme_font_size_override("font_size", 11 if is_confirm else 15)
	del_btn.add_theme_color_override("font_color", Color("#ffd6d6") if is_confirm else Color("#566171"))
	return del_btn

func _build_theme_cards() -> void:
	if not is_instance_valid(_theme_row):
		return
	for ch in _theme_row.get_children():
		ch.queue_free()
	await get_tree().process_frame
	for t in RUN_THEMES:
		var tid: String = t["id"]
		var is_selected: bool = (_selected_theme == tid)
		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.custom_minimum_size = Vector2(0, 74)
		var st := StyleBoxFlat.new()
		st.bg_color = Color(MENU_PANEL_SELECTED) if is_selected else Color(MENU_PANEL)
		st.border_color = Color(MENU_BORDER_ACTIVE) if is_selected else Color(MENU_BORDER)
		st.set_border_width_all(2 if is_selected else 1)
		st.set_corner_radius_all(7)
		st.content_margin_top = 6
		st.content_margin_bottom = 6
		card.add_theme_stylebox_override("panel", st)
		var vb := VBoxContainer.new()
		vb.add_theme_constant_override("separation", 3)
		vb.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_child(vb)
		var icon_tex: TextureRect = _menu_icon(str(t.get("icon_id", "goal")),
			Color(MENU_ACCENT_BRIGHT) if is_selected else Color(MENU_TEXT_FAINT), 24)
		vb.add_child(icon_tex)
		var name_lbl := Label.new()
		name_lbl.text = _theme_text(t, "name")
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 11)
		name_lbl.add_theme_color_override("font_color", Color(MENU_TEXT) if is_selected else Color(MENU_TEXT_DIM))
		name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vb.add_child(name_lbl)
		var diff_lbl2 := Label.new()
		diff_lbl2.text = t["diff"]
		diff_lbl2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		diff_lbl2.add_theme_font_size_override("font_size", 9)
		diff_lbl2.add_theme_color_override("font_color", Color(MENU_ACCENT_DIM) if is_selected else Color(MENU_TEXT_FAINT))
		diff_lbl2.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vb.add_child(diff_lbl2)
		var btn := Button.new()
		btn.flat = true
		btn.set_anchors_preset(Control.PRESET_FULL_RECT)
		var empty_st := StyleBoxEmpty.new()
		btn.add_theme_stylebox_override("normal", empty_st)
		btn.add_theme_stylebox_override("pressed", empty_st)
		btn.add_theme_stylebox_override("focus", empty_st)
		var hover_st2 := StyleBoxFlat.new()
		hover_st2.bg_color = Color(1, 1, 1, 0.05)
		hover_st2.set_corner_radius_all(6)
		btn.add_theme_stylebox_override("hover", hover_st2)
		btn.pressed.connect(func(): _select_theme(tid))
		card.add_child(btn)
		_theme_row.add_child(card)
	_update_theme_desc()

func _select_theme(tid: String) -> void:
	_selected_theme = tid
	AudioManager.play("click")
	_build_theme_cards()

# ── 난이도 카드 (테마 카드와 같은 패턴) ─────────────────────────
func _build_diff_cards() -> void:
	if not is_instance_valid(_diff_row):
		return
	for ch in _diff_row.get_children():
		ch.queue_free()
	await get_tree().process_frame
	for did in GameState.DIFFICULTY_DATA:
		var d: Dictionary = GameState.DIFFICULTY_DATA[did]
		var is_selected: bool = (_selected_diff == did)
		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.custom_minimum_size = Vector2(0, 74)
		var st := StyleBoxFlat.new()
		st.bg_color = Color(MENU_PANEL_SELECTED) if is_selected else Color(MENU_PANEL)
		st.border_color = Color(MENU_BORDER_ACTIVE) if is_selected else Color(MENU_BORDER)
		st.set_border_width_all(2 if is_selected else 1)
		st.set_corner_radius_all(7)
		st.content_margin_top = 6
		st.content_margin_bottom = 6
		card.add_theme_stylebox_override("panel", st)
		var vb := VBoxContainer.new()
		vb.add_theme_constant_override("separation", 3)
		vb.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_child(vb)
		var icon_id: String = _difficulty_icon_id(did)
		var icon_tex: TextureRect = _menu_icon(icon_id,
			Color(MENU_ACCENT_BRIGHT) if is_selected else Color(MENU_TEXT_FAINT), 24)
		vb.add_child(icon_tex)
		var name_lbl := Label.new()
		name_lbl.text = _difficulty_text(did, d, "name")
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 11)
		name_lbl.add_theme_color_override("font_color", Color(MENU_TEXT) if is_selected else Color(MENU_TEXT_DIM))
		name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vb.add_child(name_lbl)
		var stars_lbl := Label.new()
		stars_lbl.text = str(d["stars"])
		stars_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stars_lbl.add_theme_font_size_override("font_size", 9)
		stars_lbl.add_theme_color_override("font_color", Color(MENU_ACCENT_DIM) if is_selected else Color(MENU_TEXT_FAINT))
		stars_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vb.add_child(stars_lbl)
		var btn := Button.new()
		btn.flat = true
		btn.set_anchors_preset(Control.PRESET_FULL_RECT)
		var empty_st := StyleBoxEmpty.new()
		btn.add_theme_stylebox_override("normal", empty_st)
		btn.add_theme_stylebox_override("pressed", empty_st)
		btn.add_theme_stylebox_override("focus", empty_st)
		var hover_st := StyleBoxFlat.new()
		hover_st.bg_color = Color(1, 1, 1, 0.05)
		hover_st.set_corner_radius_all(6)
		btn.add_theme_stylebox_override("hover", hover_st)
		btn.pressed.connect(func(): _select_diff(did))
		card.add_child(btn)
		_diff_row.add_child(card)
	_update_diff_desc()

func _select_diff(did: String) -> void:
	_selected_diff = did
	AudioManager.play("click")
	_build_diff_cards()

func _update_diff_desc() -> void:
	if not is_instance_valid(_diff_desc_label):
		return
	var d: Dictionary = GameState.DIFFICULTY_DATA.get(_selected_diff, {})
	_diff_desc_label.text = "%s  —  %s" % [
		_difficulty_text(_selected_diff, d, "tagline"),
		_difficulty_text(_selected_diff, d, "desc")]

func _update_theme_desc() -> void:
	if not is_instance_valid(_theme_desc_label):
		return
	for t in RUN_THEMES:
		if t["id"] == _selected_theme:
			_theme_desc_label.text = "%s  %s" % [_theme_text(t, "tagline"), t["diff"]]
			return

# ── 시작 / 로드 ─────────────────────────────────────────────────
func _start_new_run():
	_request_new_run(false)

func _start_core_loop_v2_test_run() -> void:
	_request_new_run(true)

func _request_new_run(core_loop_v2_test: bool) -> void:
	_new_run_core_loop_v2_test = core_loop_v2_test
	# 첫 실행 시 콘텐츠 경고 표시
	if not MetaProgression.data.get("content_warning_seen", false):
		_show_content_warning()
		return
	_do_start_run()

func _show_content_warning():
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.82)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(460, 0)
	var panel_st = StyleBoxFlat.new()
	panel_st.bg_color = Color("#0d1016", 0.98)
	panel_st.border_color = Color("#7b8591", 0.82)
	panel_st.set_border_width_all(1)
	panel_st.border_width_left = 4
	panel_st.set_corner_radius_all(4)
	panel_st.content_margin_left = 28
	panel_st.content_margin_right = 28
	panel_st.content_margin_top = 28
	panel_st.content_margin_bottom = 28
	panel.add_theme_stylebox_override("panel", panel_st)
	center.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)

	var title_lbl = Label.new()
	title_lbl.text = _tr("콘텐츠 안내", "Content Notice")
	title_lbl.add_theme_font_size_override("font_size", 17)
	title_lbl.add_theme_color_override("font_color", Color(MENU_ACCENT_BRIGHT))
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_lbl)

	var sep0 = HSeparator.new()
	sep0.add_theme_color_override("color", Color("#252535"))
	vbox.add_child(sep0)

	var body_lbl = Label.new()
	body_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_lbl.custom_minimum_size = Vector2(400, 0)
	body_lbl.text = _tr(
			"이 게임에는 다음과 같은 내용이 포함됩니다:\n\n"
			+ "• 재정적 어려움과 부채\n"
			+ "• 가족·사회적 압박과 비교\n"
			+ "• 직장 스트레스와 번아웃\n"
			+ "• 정신건강 관련 묘사\n\n"
			+ "강남드림은 현실적인 삶을 다룹니다. "
			+ "어려운 상황들은 이야기의 일부이며, 권장하는 내용이 아닙니다.",
			"This game contains depictions of:\n\n"
			+ "• Financial hardship and debt\n"
			+ "• Family pressure and social comparison\n"
			+ "• Workplace stress and burnout\n"
			+ "• Mental health struggles\n\n"
			+ "Gangnam Dream is a realistic portrayal of life. "
			+ "Difficult situations are part of the story — not endorsements.")
	body_lbl.add_theme_font_size_override("font_size", 15)
	body_lbl.add_theme_color_override("font_color", Color("#aeb6c0"))
	vbox.add_child(body_lbl)

	var sep1 = HSeparator.new()
	sep1.add_theme_color_override("color", Color("#252535"))
	vbox.add_child(sep1)

	var btn_row = HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 10)
	vbox.add_child(btn_row)

	var back_btn = Button.new()
	back_btn.text = _tr("뒤로", "Back")
	back_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back_btn.custom_minimum_size = Vector2(0, 44)
	var back_st = StyleBoxFlat.new()
	back_st.bg_color = Color("#1e1e2a")
	back_st.set_corner_radius_all(6)
	back_btn.add_theme_stylebox_override("normal", back_st)
	back_btn.add_theme_color_override("font_color", Color("#8892a4"))
	back_btn.add_theme_font_size_override("font_size", 14)
	back_btn.pressed.connect(overlay.queue_free)
	btn_row.add_child(back_btn)

	var ok_btn = Button.new()
	ok_btn.text = _tr("이해했습니다 ›", "Understood ›")
	ok_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ok_btn.custom_minimum_size = Vector2(0, 44)
	var ok_st = StyleBoxFlat.new()
	ok_st.bg_color = Color("#111820", 0.98)
	ok_st.border_color = Color(MENU_ACCENT_BRIGHT, 0.78)
	ok_st.set_border_width_all(1)
	ok_st.border_width_left = 4
	ok_st.set_corner_radius_all(6)
	var ok_hover = ok_st.duplicate()
	ok_hover.bg_color = Color("#172331", 0.98)
	ok_hover.border_color = Color("#ffffff", 0.9)
	var ok_pressed = ok_st.duplicate()
	ok_pressed.bg_color = Color("#0b1018", 0.98)
	var ok_focus = ok_st.duplicate()
	ok_focus.border_color = Color("#ffffff")
	ok_focus.set_border_width_all(2)
	ok_focus.border_width_left = 5
	ok_btn.add_theme_stylebox_override("normal", ok_st)
	ok_btn.add_theme_stylebox_override("hover", ok_hover)
	ok_btn.add_theme_stylebox_override("pressed", ok_pressed)
	ok_btn.add_theme_stylebox_override("focus", ok_focus)
	ok_btn.add_theme_color_override("font_color", Color("#eef3f8"))
	ok_btn.add_theme_color_override("font_hover_color", Color("#ffffff"))
	ok_btn.add_theme_color_override("font_pressed_color", Color("#dce6ee"))
	ok_btn.add_theme_color_override("font_focus_color", Color("#ffffff"))
	ok_btn.add_theme_font_size_override("font_size", 14)
	ok_btn.pressed.connect(func():
		MetaProgression.data["content_warning_seen"] = true
		MetaProgression.save_meta()
		overlay.queue_free()
		_do_start_run()
	)
	btn_row.add_child(ok_btn)
	back_btn.focus_neighbor_right = ok_btn.get_path()
	ok_btn.focus_neighbor_left = back_btn.get_path()
	ok_btn.call_deferred("grab_focus")

func _do_start_run():
	# 이름·루트 선택 없이 고정 시작 (드라마 모드)
	# 성향은 플레이 중 선택으로 자연스럽게 결정됨
	_initialize_new_run_state(_new_run_core_loop_v2_test)
	SceneTransition.go(NEW_STORY_SCENE)

func _initialize_new_run_state(core_loop_v2_test: bool) -> void:
	SaveManager.clear_loaded_resume_context()
	GameState.start_new_game(_tr("김민준", "Kim Minjun"), "지방_상경", "none", "백수", "자유런", "현실")
	if core_loop_v2_test:
		DemoCoreLoopV2Script.initialize_for_run(true)
	BuildInfoScript.apply_window_title(
		get_window(), core_loop_v2_test, not LocaleManager.is_korean())

func _load_slot(slot):
	if SaveManager.load_game(slot):
		BuildInfoScript.apply_window_title(
			get_window(), DemoCoreLoopV2Script.requested(),
			not LocaleManager.is_korean())
		SceneTransition.go(SaveManager.loaded_scene_path())

# ── UI 헬퍼 ────────────────────────────────────────────────────
func _label(text, size, color, align) -> Label:
	var lbl = Label.new()
	lbl.text = text
	lbl.horizontal_alignment = align
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", Color(color))
	return lbl

func _sep() -> HSeparator:
	var s = HSeparator.new()
	s.add_theme_color_override("color", Color("#1e1e2a"))
	return s

func _button(text, color) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 48)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(color)
	normal.set_corner_radius_all(6)
	var hover = normal.duplicate()
	hover.bg_color = Color(color).lightened(0.12)
	var focus_st = normal.duplicate()
	focus_st.border_color = Color(MENU_BORDER_ACTIVE)
	focus_st.set_border_width_all(2)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", focus_st)
	button.add_theme_color_override("font_color", Color("#ffffff"))
	button.add_theme_font_size_override("font_size", 15)
	return button

func _menu_icon(icon_id: String, tint: Color, size: int = 24) -> TextureRect:
	var tex_rect := TextureRect.new()
	tex_rect.custom_minimum_size = Vector2(size, size)
	tex_rect.texture = _ui_icon_texture(icon_id)
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.modulate = tint
	tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tex_rect

func _difficulty_icon_id(did: String) -> String:
	match did:
		"드라마":
			return "mental"
		"지옥고":
			return "stress"
		_:
			return "housing"

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

func _slot_button(top_line: String, sub_line: String, enabled: bool, on_press: Callable = Callable()) -> Control:
	var outer = PanelContainer.new()
	outer.custom_minimum_size = Vector2(0, 48)
	outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st = StyleBoxFlat.new()
	st.bg_color = Color("#1a1a26") if enabled else Color("#111118")
	st.border_color = Color("#3a3a5a") if enabled else Color("#1e1e2a")
	st.set_border_width_all(1)
	st.set_corner_radius_all(6)
	st.content_margin_left = 14
	st.content_margin_right = 14
	st.content_margin_top = 8
	st.content_margin_bottom = 8
	outer.add_theme_stylebox_override("panel", st)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	outer.add_child(vbox)

	var lbl1 = Label.new()
	lbl1.text = top_line
	lbl1.add_theme_font_size_override("font_size", 13)
	lbl1.add_theme_color_override("font_color", Color("#e8eaf0") if enabled else Color("#3a3a5a"))
	vbox.add_child(lbl1)

	var lbl2 = Label.new()
	lbl2.text = sub_line
	lbl2.add_theme_font_size_override("font_size", 11)
	lbl2.add_theme_color_override("font_color", Color(MENU_ACCENT_DIM) if enabled else Color("#2a2a3a"))
	vbox.add_child(lbl2)

	if enabled and on_press.is_valid():
		var btn = Button.new()
		btn.flat = true
		btn.set_anchors_preset(Control.PRESET_FULL_RECT)
		var empty_st = StyleBoxEmpty.new()
		var focus_slot = StyleBoxFlat.new()
		focus_slot.bg_color = Color(0, 0, 0, 0)
		focus_slot.border_color = Color(MENU_BORDER_ACTIVE)
		focus_slot.set_border_width_all(2)
		focus_slot.set_corner_radius_all(6)
		btn.add_theme_stylebox_override("normal", empty_st)
		btn.add_theme_stylebox_override("pressed", empty_st)
		btn.add_theme_stylebox_override("focus", focus_slot)
		var hover_st = StyleBoxFlat.new()
		hover_st.bg_color = Color(1.0, 1.0, 1.0, 0.06)
		hover_st.set_corner_radius_all(6)
		btn.add_theme_stylebox_override("hover", hover_st)
		btn.pressed.connect(on_press)
		outer.add_child(btn)

	return outer

func _open_settings_popup():
	if _settings_overlay and is_instance_valid(_settings_overlay):
		_close_settings_popup()
	_settings_origin_focus = get_viewport().gui_get_focus_owner()

	_settings_overlay = ColorRect.new()
	_settings_overlay.color = Color(0, 0, 0, 0.7)
	_settings_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_settings_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_settings_overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_settings_overlay.add_child(center)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(500, 0)
	var pst = StyleBoxFlat.new()
	pst.bg_color = Color("#13131f")
	pst.border_color = Color("#2a2a40")
	pst.set_border_width_all(1)
	pst.set_corner_radius_all(10)
	pst.content_margin_left = 24
	pst.content_margin_right = 24
	pst.content_margin_top = 20
	pst.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", pst)
	center.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)

	var title = Label.new()
	title.text = _tr("설정", "Settings")
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color("#e8eaf0"))
	vbox.add_child(title)

	var sep = HSeparator.new()
	sep.modulate = Color("#2a2a3a")
	vbox.add_child(sep)

	_build_volume_sliders_menu(vbox)
	_build_language_toggle(vbox)
	_build_moral_palette_selector(vbox)
	_build_mod_settings_entry(vbox)
	var notices_btn = _button(_tr("제3자 고지", "Third-Party Notices"), "#1b2430")
	notices_btn.set_meta("third_party_notices_control", true)
	_third_party_notices_control = notices_btn
	notices_btn.tooltip_text = _tr(
		"게임 엔진·서체·음원의 출처와 라이선스를 확인합니다.",
		"Review engine, font, and audio sources and licenses.")
	notices_btn.pressed.connect(_open_third_party_notices)
	notices_btn.mouse_entered.connect(notices_btn.grab_focus)
	vbox.add_child(notices_btn)

	var close_btn = _button(_tr("닫기", "Close"), "#1e2a3a")
	close_btn.pressed.connect(_close_settings_popup)
	vbox.add_child(close_btn)
	call_deferred("_focus_first_settings_control")

func _focus_first_settings_control() -> void:
	if not is_instance_valid(_settings_overlay):
		return
	for node in _settings_overlay.find_children("*", "Control", true, false):
		if not (node is Control):
			continue
		var control := node as Control
		if control.focus_mode == Control.FOCUS_NONE or not control.is_visible_in_tree():
			continue
		if control is BaseButton and (control as BaseButton).disabled:
			continue
		control.grab_focus()
		return

func _close_settings_popup() -> void:
	if is_instance_valid(_notices_overlay):
		var notices_parent := _notices_overlay.get_parent()
		if notices_parent != null:
			notices_parent.remove_child(_notices_overlay)
		_notices_overlay.queue_free()
	_notices_overlay = null
	_notices_origin_focus = null
	_third_party_notices_control = null
	_notices_content_margin = null
	_notices_content = null
	_notices_scroll = null
	_notices_scroll_frame = null
	SceneTransition.set_playtest_marker_context(
		SceneTransition.PLAYTEST_MARKER_CONTEXT_DEFAULT)
	if is_instance_valid(_settings_overlay):
		_settings_overlay.queue_free()
	_settings_overlay = null
	if is_instance_valid(_settings_origin_focus):
		_settings_origin_focus.call_deferred("grab_focus")
	else:
		for button in _title_command_buttons:
			if is_instance_valid(button) and not button.disabled:
				button.call_deferred("grab_focus")
				break
	_settings_origin_focus = null

func _notice_localized(value: Variant, fallback: String = "") -> String:
	if value is Dictionary:
		return LocaleManager.ui(
			str((value as Dictionary).get("ko", fallback)),
			str((value as Dictionary).get("en", fallback)))
	return str(value) if value != null else fallback

func _load_third_party_notice_data() -> Dictionary:
	if not _notices_data.is_empty():
		return _notices_data
	if not FileAccess.file_exists(THIRD_PARTY_NOTICE_PATH):
		push_error("StartMenu: third-party notice data is missing.")
		return {}
	var parsed: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(THIRD_PARTY_NOTICE_PATH))
	if not parsed is Dictionary or int(parsed.get("schema_version", 0)) != 1:
		push_error("StartMenu: third-party notice data is invalid.")
		return {}
	_notices_data = parsed
	return _notices_data

func _open_third_party_notices() -> void:
	var data := _load_third_party_notice_data()
	if data.is_empty():
		return
	if is_instance_valid(_notices_overlay):
		_notices_overlay.queue_free()
	_notices_origin_focus = _third_party_notices_control \
		if is_instance_valid(_third_party_notices_control) \
		else get_viewport().gui_get_focus_owner()
	_notices_tabs.clear()
	SceneTransition.set_playtest_marker_context(
		SceneTransition.PLAYTEST_MARKER_CONTEXT_NOTICE)

	_notices_overlay = ColorRect.new()
	_notices_overlay.name = "ThirdPartyNoticesOverlay"
	_notices_overlay.color = Color(0.008, 0.010, 0.014, 0.97)
	_notices_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_notices_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_notices_overlay.z_index = 120
	add_child(_notices_overlay)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	UIStyle.apply_notice_margin(margin)
	_notices_overlay.add_child(margin)

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	UIStyle.apply_notice_panel(panel)
	margin.add_child(panel)

	var body := VBoxContainer.new()
	UIStyle.apply_notice_spacing(body, 10)
	panel.add_child(body)

	var header := HBoxContainer.new()
	UIStyle.apply_notice_spacing(header, 16)
	body.add_child(header)
	var heading := VBoxContainer.new()
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(heading)
	var surface: Dictionary = data.get("surface", {})
	var title := _label(
		_notice_localized(surface.get("title", {}), _tr("제3자 고지", "Third-Party Notices")),
		26, "#f0f3f6", HORIZONTAL_ALIGNMENT_LEFT)
	title.name = "ThirdPartyNoticesTitle"
	heading.add_child(title)
	var identity := _label(
		BuildInfoScript.identity_label(false), 12, "#8b95a1",
		HORIZONTAL_ALIGNMENT_LEFT)
	heading.add_child(identity)
	var close_button := _button(_tr("닫기", "Close"), "#1e2a3a")
	close_button.custom_minimum_size = Vector2(120, 46)
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	close_button.set_meta("third_party_notice_close", true)
	close_button.pressed.connect(_close_third_party_notices)
	close_button.mouse_entered.connect(close_button.grab_focus)
	header.add_child(close_button)

	var intro := _label(
		_notice_localized(surface.get("intro", {})), 14, "#c2c9d1",
		HORIZONTAL_ALIGNMENT_LEFT)
	intro.name = "ThirdPartyNoticesIntro"
	body.add_child(intro)
	var summary: Dictionary = data.get("summary", {})
	var summary_text := LocaleManager.ui_format(
		"엔진 %d · 서체 %d패밀리/%d파일 · 오디오 출처 %d개/%d파일",
		"Engine %d · Fonts %d families/%d files · Audio %d sources/%d files",
		[
			int(summary.get("component_entries", 0)),
			int(summary.get("font_families", 0)),
			int(summary.get("font_files", 0)),
			int(summary.get("audio_sources", 0)),
			int(summary.get("audio_assets", 0)),
		],
		[
			int(summary.get("component_entries", 0)),
			int(summary.get("font_families", 0)),
			int(summary.get("font_files", 0)),
			int(summary.get("audio_sources", 0)),
			int(summary.get("audio_assets", 0)),
		])
	var summary_label := _label(
		summary_text, 13, "#909aa6", HORIZONTAL_ALIGNMENT_LEFT)
	summary_label.name = "ThirdPartyNoticesSummary"
	body.add_child(summary_label)

	var tabs := HBoxContainer.new()
	UIStyle.apply_notice_spacing(tabs, 8)
	body.add_child(tabs)
	var sections: Array = data.get("sections", [])
	for index in range(sections.size()):
		var section: Dictionary = sections[index]
		var tab := _button(
			_notice_localized(section.get("title", {})), "#171e28")
		tab.toggle_mode = true
		tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab.custom_minimum_size = Vector2(0, 46)
		tab.set_meta("third_party_notice_section", str(section.get("id", "")))
		tab.pressed.connect(_set_third_party_notice_section.bind(index))
		tab.mouse_entered.connect(tab.grab_focus)
		tabs.add_child(tab)
		_notices_tabs.append(tab)

	# A plain Control owns the remaining VBox slot. Unlike another Container, it
	# does not propagate the changing legal-text minimum height into the fixed
	# title/tabs. This keeps the chrome pinned while each ledger becomes scrollable.
	var scroll_host := Control.new()
	scroll_host.name = "ThirdPartyNoticesScrollHost"
	scroll_host.custom_minimum_size = Vector2(0, 160)
	scroll_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll_host)

	_notices_scroll = ScrollContainer.new()
	_notices_scroll.name = "ThirdPartyNoticesScroll"
	_notices_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_notices_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_notices_scroll.focus_mode = Control.FOCUS_ALL
	_notices_scroll.set_meta("third_party_notice_scroll_focus", true)
	_notices_scroll.mouse_entered.connect(_notices_scroll.grab_focus)
	_notices_scroll.focus_entered.connect(
		_set_third_party_notice_scroll_focus_visual.bind(true))
	_notices_scroll.focus_exited.connect(
		_set_third_party_notice_scroll_focus_visual.bind(false))
	_notices_scroll.gui_input.connect(
		_on_third_party_notice_scroll_input.bind(_notices_scroll))
	scroll_host.add_child(_notices_scroll)
	_notices_content_margin = MarginContainer.new()
	_notices_content_margin.name = "ThirdPartyNoticesContentMargin"
	_notices_content_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UIStyle.apply_notice_content_margin(_notices_content_margin)
	_notices_scroll.add_child(_notices_content_margin)
	_notices_content = VBoxContainer.new()
	_notices_content.name = "ThirdPartyNoticesContent"
	_notices_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UIStyle.apply_notice_spacing(_notices_content, 10)
	_notices_content_margin.add_child(_notices_content)

	_notices_scroll_frame = Panel.new()
	_notices_scroll_frame.name = "ThirdPartyNoticesScrollFrame"
	_notices_scroll_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_notices_scroll_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_notices_scroll_frame.z_index = 2
	_notices_scroll_frame.set_meta("third_party_notice_focus_frame", true)
	UIStyle.apply_notice_scroll_frame(_notices_scroll_frame, false)
	scroll_host.add_child(_notices_scroll_frame)

	var package_note := _label(
		_notice_localized(surface.get("package_note", {})), 12, "#7c8793",
		HORIZONTAL_ALIGNMENT_LEFT)
	package_note.name = "ThirdPartyNoticesPackageNote"
	body.add_child(package_note)
	var hint_text := (
		"[%s] %s" % [ControllerHints.east(), _tr("닫기", "Close")]
		if ControllerHints.is_pad_active()
		else _tr("방향키로 이동·스크롤  ·  Esc 닫기",
			"Move and scroll with arrow keys  ·  Esc closes")
	)
	var hint := _label(
		hint_text,
		12, "#68727e", HORIZONTAL_ALIGNMENT_LEFT)
	body.add_child(hint)

	_notices_overlay.set_meta("notice_schema", int(data.get("schema_version", 0)))
	for key in summary:
		_notices_overlay.set_meta(str(key), summary[key])
	_set_third_party_notice_section(0)
	_wire_third_party_notice_focus(close_button)
	if not _notices_tabs.is_empty():
		_notices_tabs[0].call_deferred("grab_focus")

func _set_third_party_notice_section(index: int) -> void:
	if not is_instance_valid(_notices_scroll):
		return
	var sections: Array = _notices_data.get("sections", [])
	if index < 0 or index >= sections.size():
		return
	for tab_index in range(_notices_tabs.size()):
		_notices_tabs[tab_index].button_pressed = tab_index == index
	# Assemble the variable-height ledger off-tree and swap it atomically. Adding
	# thousands of lines one child at a time while attached can make the parent
	# VBox publish a transient oversized transform to the renderer, which shifts
	# the fixed title/tabs for one rendered frame on macOS OpenGL.
	var next_content := VBoxContainer.new()
	next_content.name = "ThirdPartyNoticesContent"
	next_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UIStyle.apply_notice_spacing(next_content, 10)
	var section: Dictionary = sections[index]
	var section_title := _label(
		_notice_localized(section.get("title", {})), 20, "#edf1f5",
		HORIZONTAL_ALIGNMENT_LEFT)
	next_content.add_child(section_title)
	var notice_text_paths: Dictionary = {}
	for raw_entry in section.get("entries", []):
		if not raw_entry is Dictionary:
			continue
		var entry: Dictionary = raw_entry
		next_content.add_child(_third_party_notice_entry(entry))
		for path_field in ["license_text_path", "copyright_text_path"]:
			var notice_path := str(entry.get(path_field, ""))
			if not notice_path.is_empty():
				notice_text_paths[notice_path] = true
	if not notice_text_paths.is_empty():
		var rule := HSeparator.new()
		UIStyle.apply_notice_separator(rule)
		next_content.add_child(rule)
		next_content.add_child(_label(
			_tr("라이선스·저작권 전문", "Full License and Copyright Texts"),
			18, "#e4e9ef",
			HORIZONTAL_ALIGNMENT_LEFT))
		for notice_path in notice_text_paths:
			next_content.add_child(
				_third_party_license_text(str(notice_path)))
	if is_instance_valid(_notices_content):
		var old_content := _notices_content
		var old_parent := old_content.get_parent()
		if old_parent != null:
			old_parent.remove_child(old_content)
		# The detached legal text can own thousands of glyph RIDs. Destroy it
		# before attaching the replacement so the render thread never observes
		# both layout generations during the same OpenGL frame.
		old_content.free()
	_notices_content = next_content
	if is_instance_valid(_notices_content_margin):
		_notices_content_margin.add_child(_notices_content)
	else:
		_notices_scroll.add_child(_notices_content)
	_notices_scroll.scroll_vertical = 0
	if index < _notices_tabs.size():
		_notices_scroll.focus_neighbor_top = _notices_scroll.get_path_to(
			_notices_tabs[index])
		_notices_tabs[index].grab_focus()

func _third_party_notice_entry(entry: Dictionary) -> Control:
	var panel := PanelContainer.new()
	panel.set_meta("third_party_notice_id", str(entry.get("id", "")))
	UIStyle.apply_notice_panel(panel, true)
	var column := VBoxContainer.new()
	UIStyle.apply_notice_spacing(column, 4)
	panel.add_child(column)
	var name := str(entry.get("name", ""))
	var version := str(entry.get("version", ""))
	column.add_child(_label(name, 16, "#edf1f5", HORIZONTAL_ALIGNMENT_LEFT))
	if not version.is_empty():
		var version_label := _label(
			"%s  ·  %s" % [_tr("버전", "Version"), version],
			14, "#98a6b5", HORIZONTAL_ALIGNMENT_LEFT)
		version_label.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
		column.add_child(version_label)
	var surface: Dictionary = _notices_data.get("surface", {})
	var labels: Dictionary = surface.get("labels", {})
	for field in ["provider", "copyright", "license"]:
		var value := str(entry.get(field, ""))
		if value.is_empty():
			continue
		var field_label: String = _notice_localized(
			labels.get(field, {}), field.capitalize())
		column.add_child(_label(
			"%s  ·  %s" % [field_label, value], 14, "#bac2cb",
			HORIZONTAL_ALIGNMENT_LEFT))
	var status := str(entry.get("notice_status", ""))
	if not status.is_empty():
		var status_label: String = _notice_localized(labels.get(status, {}), status)
		column.add_child(_label(
			status_label, 14, "#98a6b5", HORIZONTAL_ALIGNMENT_LEFT))
	var source_url := str(entry.get("source_url", ""))
	if not source_url.is_empty():
		var source_label: String = _notice_localized(labels.get("source", {}), "Source")
		var source := _label(
			"%s  ·  %s" % [source_label, source_url], 14, "#8190a0",
			HORIZONTAL_ALIGNMENT_LEFT)
		source.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
		column.add_child(source)
	var license_url := str(entry.get("license_url", ""))
	if not license_url.is_empty():
		var license_terms := _label(
			"%s  ·  %s" % [
				_notice_localized(
					labels.get("license_terms", {}), _tr("라이선스 원문", "License terms")),
				license_url,
			],
			14, "#8190a0", HORIZONTAL_ALIGNMENT_LEFT)
		license_terms.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
		column.add_child(license_terms)
	var copyright_path := str(entry.get("copyright_text_path", ""))
	if not copyright_path.is_empty():
		column.add_child(_label(
			_tr("엔진 내장 구성요소 고지 동봉", "Bundled engine component notices included")
				+ "  ·  " + copyright_path.get_file(),
			14, "#98a6b5", HORIZONTAL_ALIGNMENT_LEFT))
	if entry.has("shipping_asset_count"):
		column.add_child(_label(
			LocaleManager.ui_format(
				"이 출처를 사용한 게임 파일 · %d개",
				"Game files using this source · %d",
				int(entry.get("shipping_asset_count", 0)),
				int(entry.get("shipping_asset_count", 0))),
			13, "#73808d", HORIZONTAL_ALIGNMENT_LEFT))
	return panel

func _third_party_license_text(path: String) -> Control:
	var column := VBoxContainer.new()
	column.set_meta("license_text_path", path)
	UIStyle.apply_notice_spacing(column, 4)
	column.add_child(_label(
		path.get_file(), 15, "#d8dee6", HORIZONTAL_ALIGNMENT_LEFT))
	var text := _tr(
		"라이선스 전문을 불러오지 못했습니다.",
		"Full license text could not be loaded.")
	if FileAccess.file_exists(path):
		text = FileAccess.get_file_as_string(path)
	var license_body := _label(
		text, 14, "#8f99a5", HORIZONTAL_ALIGNMENT_LEFT)
	license_body.set_meta("third_party_notice_legal_body", true)
	license_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(license_body)
	return column

func _on_third_party_notice_scroll_input(
		event: InputEvent, scroll: ScrollContainer) -> void:
	var delta := 0
	if event.is_action_pressed("ui_down"):
		delta = 64
	elif event.is_action_pressed("ui_up"):
		if scroll.scroll_vertical <= 0:
			for tab in _notices_tabs:
				if tab.button_pressed:
					tab.grab_focus()
					scroll.accept_event()
					return
		delta = -64
	elif event.is_action_pressed("ui_page_down"):
		delta = maxi(120, int(scroll.size.y * 0.72))
	elif event.is_action_pressed("ui_page_up"):
		delta = -maxi(120, int(scroll.size.y * 0.72))
	if delta != 0:
		scroll.scroll_vertical += delta
		scroll.accept_event()

func _set_third_party_notice_scroll_focus_visual(focused: bool) -> void:
	if is_instance_valid(_notices_scroll_frame):
		UIStyle.apply_notice_scroll_frame(_notices_scroll_frame, focused)

func _wire_third_party_notice_focus(close_button: Button) -> void:
	if not is_instance_valid(_notices_scroll) or _notices_tabs.is_empty():
		return
	var controls: Array[Control] = [close_button]
	controls.append_array(_notices_tabs)
	controls.append(_notices_scroll)
	for index in range(controls.size()):
		var control := controls[index]
		var previous := controls[(index - 1 + controls.size()) % controls.size()]
		var following := controls[(index + 1) % controls.size()]
		control.focus_previous = control.get_path_to(previous)
		control.focus_next = control.get_path_to(following)
	close_button.focus_neighbor_bottom = close_button.get_path_to(_notices_tabs[0])
	for index in range(_notices_tabs.size()):
		var tab := _notices_tabs[index]
		tab.focus_neighbor_top = tab.get_path_to(close_button)
		tab.focus_neighbor_bottom = tab.get_path_to(_notices_scroll)
		tab.focus_neighbor_left = tab.get_path_to(
			_notices_tabs[(index - 1 + _notices_tabs.size()) % _notices_tabs.size()])
		tab.focus_neighbor_right = tab.get_path_to(
			_notices_tabs[(index + 1) % _notices_tabs.size()])
	_notices_scroll.focus_neighbor_bottom = _notices_scroll.get_path_to(close_button)

func _close_third_party_notices() -> void:
	if is_instance_valid(_notices_overlay):
		var notices_parent := _notices_overlay.get_parent()
		if notices_parent != null:
			notices_parent.remove_child(_notices_overlay)
		_notices_overlay.queue_free()
	_notices_overlay = null
	_notices_tabs.clear()
	_notices_content_margin = null
	_notices_content = null
	_notices_scroll = null
	_notices_scroll_frame = null
	SceneTransition.set_playtest_marker_context(
		SceneTransition.PLAYTEST_MARKER_CONTEXT_DEFAULT)
	var focus_target := _notices_origin_focus
	_notices_origin_focus = null
	if is_instance_valid(focus_target):
		focus_target.call_deferred("grab_focus")

func _build_volume_sliders_menu(parent: Control):
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
		row.add_child(slider)
		var pct = Label.new()
		pct.text = "%d%%" % int(init_val * 100)
		pct.add_theme_font_size_override("font_size", 12)
		pct.add_theme_color_override("font_color", Color("#5a6075"))
		pct.custom_minimum_size = Vector2(36, 0)
		pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(pct)
		slider.value_changed.connect(func(v):
			pct.text = "%d%%" % int(v * 100)
			on_change.call(v)
		)

	_make_row.call(_tr("BGM", "Music"), AudioManager.bgm_volume, func(v): AudioManager.set_bgm_volume(v))
	_make_row.call(_tr("효과음", "SFX"), AudioManager.master_volume, func(v): AudioManager.set_sfx_volume(v))
	_build_display_settings_menu(parent)

func _build_language_toggle(parent: Control):
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	parent.add_child(row)
	var lbl = Label.new()
	lbl.text = _tr("언어", "Language")
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", Color("#8892a4"))
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl)
	var selector := OptionButton.new()
	selector.custom_minimum_size = Vector2(190, 38)
	selector.focus_mode = Control.FOCUS_ALL
	selector.set_meta("language_control", true)
	var languages := LocaleManager.get_selectable_languages()
	var selected_index := 0
	for lang_code in languages:
		var index := selector.item_count
		selector.add_item(LocaleManager.get_language_display_name(lang_code))
		selector.set_item_metadata(index, lang_code)
		if lang_code == LocaleManager.language:
			selected_index = index
	selector.select(selected_index)
	selector.item_selected.connect(func(index: int):
		var lang_code := str(selector.get_item_metadata(index))
		if lang_code == LocaleManager.language:
			return
		var show_splash := _splash_active
		LocaleManager.set_language(lang_code)
		if is_instance_valid(_settings_overlay):
			_settings_overlay.queue_free()
		call_deferred("_rebuild_language_ui", show_splash)
	)
	row.add_child(selector)

func _add_mod_status_label(parent: Control) -> void:
	if not ModLoader.is_active(LocaleManager.language):
		return
	var status := Label.new()
	status.text = "MODDED"
	status.tooltip_text = ", ".join(ModLoader.active_mod_labels(LocaleManager.language))
	status.add_theme_font_size_override("font_size", 10)
	status.add_theme_color_override("font_color", Color("#747d88"))
	status.mouse_filter = Control.MOUSE_FILTER_PASS
	status.set_meta("mod_status", true)
	parent.add_child(status)

func _build_moral_palette_selector(parent: Control) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 42)
	row.add_theme_constant_override("separation", 10)
	parent.add_child(row)
	var label := Label.new()
	label.text = _tr("색각 접근성", "Color Accessibility")
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color("#8892a4"))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	var selector := OptionButton.new()
	selector.custom_minimum_size = Vector2(190, 38)
	selector.focus_mode = Control.FOCUS_ALL
	selector.set_meta("moral_palette_control", true)
	var selected_id := ModLoader.selected_theme_id()
	var selected_index := 0
	for info in ModLoader.available_theme_infos():
		var theme_id := str(info.get("theme_id", "default"))
		var index := selector.item_count
		selector.add_item(ModLoader.theme_display_name(theme_id, LocaleManager.language))
		selector.set_item_metadata(index, theme_id)
		if theme_id == selected_id:
			selected_index = index
	selector.select(selected_index)
	selector.item_selected.connect(func(index: int):
		SaveManager.set_setting("moral_palette", str(selector.get_item_metadata(index)))
		ModLoader.notify_settings_changed())
	row.add_child(selector)

func _build_mod_settings_entry(parent: Control) -> void:
	var mods := ModLoader.discover_data_mods()
	if mods.is_empty():
		return
	var button := _button(_tr("모드 관리", "Manage Mods"), "#1b2430")
	button.set_meta("mod_manager_control", true)
	button.tooltip_text = _tr(
		"데이터 모드의 활성화와 로드 순서를 변경합니다.",
		"Change data mod activation and load order.")
	button.pressed.connect(_open_mod_manager)
	parent.add_child(button)

func _open_mod_manager() -> void:
	if is_instance_valid(_settings_overlay):
		_settings_overlay.queue_free()
	_settings_overlay = ColorRect.new()
	_settings_overlay.color = Color(0, 0, 0, 0.76)
	_settings_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_settings_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_settings_overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_settings_overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(760, 640)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#11151c")
	style.border_color = Color("#35404d")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 24
	style.content_margin_bottom = 22
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	panel.add_child(body)
	var title := Label.new()
	title.text = _tr("모드 관리", "Manage Mods")
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("#eef2f6"))
	body.add_child(title)
	var note := Label.new()
	note.text = _tr(
		"변경은 다음 실행부터 적용됩니다. 위에 있는 모드가 먼저 로드됩니다.",
		"Changes apply on the next launch. Mods higher in the list load first.")
	note.add_theme_font_size_override("font_size", 12)
	note.add_theme_color_override("font_color", Color("#8d98a6"))
	body.add_child(note)
	var divider := HSeparator.new()
	divider.add_theme_color_override("color", Color("#303946"))
	body.add_child(divider)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 7)
	scroll.add_child(list)
	var mods := ModLoader.discover_data_mods()
	for index in range(mods.size()):
		list.add_child(_mod_manager_row(mods[index], index, mods.size()))

	var close_button := _button(_tr("닫기", "Close"), "#1e2a3a")
	close_button.pressed.connect(_close_settings_popup)
	body.add_child(close_button)
	call_deferred("_focus_first_settings_control")

func _mod_manager_row(info: Dictionary, index: int, count: int) -> Control:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 58)
	row.add_theme_constant_override("separation", 10)
	row.set_meta("mod_id", str(info.get("id", "")))
	var toggle := CheckButton.new()
	toggle.custom_minimum_size = Vector2(54, 44)
	toggle.button_pressed = ModLoader.is_mod_enabled(str(info.get("id", "")))
	toggle.focus_mode = Control.FOCUS_ALL
	toggle.set_meta("mod_toggle", true)
	toggle.toggled.connect(func(enabled: bool):
		_set_mod_enabled(str(info.get("id", "")), enabled))
	row.add_child(toggle)

	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_theme_constant_override("separation", 2)
	row.add_child(copy)
	var name_label := Label.new()
	name_label.text = str(info.get("name", info.get("id", "")))
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color("#e1e7ed"))
	copy.add_child(name_label)
	var kind_label := Label.new()
	kind_label.text = _mod_kind_label(str(info.get("kind", "")))
	var version := str(info.get("version", ""))
	if not version.is_empty():
		kind_label.text += "  v%s" % version
	kind_label.add_theme_font_size_override("font_size", 11)
	kind_label.add_theme_color_override("font_color", Color("#768291"))
	copy.add_child(kind_label)

	var up := _button("↑", "#18212c")
	up.custom_minimum_size = Vector2(44, 42)
	up.disabled = index <= 0
	up.tooltip_text = _tr("먼저 로드", "Load earlier")
	up.pressed.connect(func(): _move_mod_entry(str(info.get("id", "")), -1))
	row.add_child(up)
	var down := _button("↓", "#18212c")
	down.custom_minimum_size = Vector2(44, 42)
	down.disabled = index >= count - 1
	down.tooltip_text = _tr("나중에 로드", "Load later")
	down.pressed.connect(func(): _move_mod_entry(str(info.get("id", "")), 1))
	row.add_child(down)
	return row

func _mod_kind_label(kind: String) -> String:
	match kind:
		"assets":
			return _tr("이미지·오디오 교체", "Image / audio override")
		"events":
			return _tr("커스텀 이벤트", "Custom events")
		"preset":
			return _tr("밸런스 프리셋", "Balance preset")
		"theme":
			return _tr("색 테마", "Color theme")
		_:
			return kind

func _set_mod_enabled(mod_id: String, enabled: bool) -> void:
	var values: Dictionary = SaveManager.get_setting("mod_enabled", {}).duplicate(true)
	values[mod_id] = enabled
	SaveManager.set_setting("mod_enabled", values)
	ModLoader.notify_settings_changed()

func _move_mod_entry(mod_id: String, delta: int) -> void:
	var mods := ModLoader.discover_data_mods()
	var order: Array = []
	for info in mods:
		order.append(str(info.get("id", "")))
	var from := order.find(mod_id)
	var target := clampi(from + delta, 0, order.size() - 1)
	if from < 0 or from == target:
		return
	var swap_value: Variant = order[target]
	order[target] = order[from]
	order[from] = swap_value
	SaveManager.set_setting("mod_load_order", order)
	ModLoader.notify_settings_changed()
	if is_instance_valid(_settings_overlay):
		_settings_overlay.queue_free()
	call_deferred("_open_mod_manager")

func _build_display_settings_menu(parent: Control) -> void:
	if not OS.has_feature("web"):
		var mode_row := HBoxContainer.new()
		mode_row.custom_minimum_size = Vector2(0, 42)
		mode_row.add_theme_constant_override("separation", 10)
		parent.add_child(mode_row)
		var mode_label := Label.new()
		mode_label.text = _tr("화면 모드", "Display Mode")
		mode_label.add_theme_font_size_override("font_size", 13)
		mode_label.add_theme_color_override("font_color", Color("#8892a4"))
		mode_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mode_row.add_child(mode_label)
		var mode_selector := OptionButton.new()
		mode_selector.custom_minimum_size = Vector2(190, 38)
		mode_selector.set_meta("display_mode_control", true)
		for label_text in [
			_tr("창모드", "Windowed"),
			_tr("테두리 없음", "Borderless"),
			_tr("전체화면", "Fullscreen"),
		]:
			mode_selector.add_item(label_text)
		mode_selector.select(DisplayManager.window_mode_index())
		mode_row.add_child(mode_selector)

		var resolution_row := HBoxContainer.new()
		resolution_row.custom_minimum_size = Vector2(0, 42)
		resolution_row.add_theme_constant_override("separation", 10)
		parent.add_child(resolution_row)
		var resolution_label := Label.new()
		resolution_label.text = _tr("창 해상도", "Window Resolution")
		resolution_label.add_theme_font_size_override("font_size", 13)
		resolution_label.add_theme_color_override("font_color", Color("#8892a4"))
		resolution_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		resolution_row.add_child(resolution_label)
		var resolution_selector := OptionButton.new()
		resolution_selector.custom_minimum_size = Vector2(190, 38)
		resolution_selector.set_meta("resolution_control", true)
		for index in range(DisplayManager.WINDOW_RESOLUTIONS.size()):
			resolution_selector.add_item(DisplayManager.resolution_label(index))
		resolution_selector.select(DisplayManager.resolution_index())
		resolution_selector.disabled = DisplayManager.window_mode != "windowed"
		resolution_selector.item_selected.connect(func(index: int):
			DisplayManager.set_resolution_index(index))
		resolution_row.add_child(resolution_selector)
		mode_selector.item_selected.connect(func(index: int):
			DisplayManager.set_window_mode_index(index)
			resolution_selector.disabled = DisplayManager.window_mode != "windowed")

	var motion_row := HBoxContainer.new()
	motion_row.custom_minimum_size = Vector2(0, 46)
	motion_row.add_theme_constant_override("separation", 10)
	parent.add_child(motion_row)
	var motion_copy := VBoxContainer.new()
	motion_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	motion_copy.add_theme_constant_override("separation", 2)
	motion_row.add_child(motion_copy)
	var motion_label := Label.new()
	motion_label.text = _tr("동작 감소", "Reduce Motion")
	motion_label.add_theme_font_size_override("font_size", 13)
	motion_label.add_theme_color_override("font_color", Color("#8892a4"))
	motion_copy.add_child(motion_label)
	var motion_hint := Label.new()
	motion_hint.text = _tr(
		"카메라·초상·날씨 움직임을 최소화합니다.",
		"Minimizes camera, portrait, and weather movement.")
	motion_hint.add_theme_font_size_override("font_size", 11)
	motion_hint.add_theme_color_override("font_color", Color("#5a6075"))
	motion_copy.add_child(motion_hint)
	var motion_toggle := CheckButton.new()
	motion_toggle.custom_minimum_size = Vector2(54, 40)
	motion_toggle.button_pressed = bool(SaveManager.get_setting("reduce_motion", false))
	motion_toggle.set_meta("reduce_motion_control", true)
	motion_toggle.toggled.connect(func(on: bool): SaveManager.set_setting("reduce_motion", on))
	motion_row.add_child(motion_toggle)

	var vibration_row := HBoxContainer.new()
	vibration_row.custom_minimum_size = Vector2(0, 42)
	vibration_row.add_theme_constant_override("separation", 10)
	parent.add_child(vibration_row)
	var vibration_label := Label.new()
	vibration_label.text = _tr("진동", "Vibration")
	vibration_label.add_theme_font_size_override("font_size", 13)
	vibration_label.add_theme_color_override("font_color", Color("#8892a4"))
	vibration_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vibration_row.add_child(vibration_label)
	var vibration_toggle := CheckButton.new()
	vibration_toggle.custom_minimum_size = Vector2(54, 40)
	vibration_toggle.button_pressed = AudioManager.vibration_enabled()
	vibration_toggle.set_meta("vibration_control", true)
	vibration_row.add_child(vibration_toggle)

	var intensity_row := HBoxContainer.new()
	intensity_row.custom_minimum_size = Vector2(0, 42)
	intensity_row.add_theme_constant_override("separation", 10)
	parent.add_child(intensity_row)
	var intensity_label := Label.new()
	intensity_label.text = _tr("진동 강도", "Vibration Strength")
	intensity_label.add_theme_font_size_override("font_size", 13)
	intensity_label.add_theme_color_override("font_color", Color("#8892a4"))
	intensity_label.custom_minimum_size = Vector2(132, 0)
	intensity_row.add_child(intensity_label)
	var intensity_slider := HSlider.new()
	intensity_slider.min_value = 0.0
	intensity_slider.max_value = 1.0
	intensity_slider.step = 0.10
	intensity_slider.value = AudioManager.vibration_intensity()
	intensity_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	intensity_slider.custom_minimum_size = Vector2(170, 32)
	intensity_slider.editable = vibration_toggle.button_pressed
	intensity_slider.focus_mode = Control.FOCUS_ALL \
		if vibration_toggle.button_pressed else Control.FOCUS_NONE
	intensity_slider.set_meta("vibration_intensity_control", true)
	intensity_slider.value_changed.connect(func(value: float):
		AudioManager.set_vibration_intensity(value))
	intensity_row.add_child(intensity_slider)
	var intensity_value := Label.new()
	intensity_value.text = "%d%%" % int(roundf(intensity_slider.value * 100.0))
	intensity_value.custom_minimum_size = Vector2(44, 0)
	intensity_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	intensity_value.add_theme_font_size_override("font_size", 12)
	intensity_value.add_theme_color_override("font_color", Color("#5a6075"))
	intensity_slider.value_changed.connect(func(value: float):
		intensity_value.text = "%d%%" % int(roundf(value * 100.0)))
	intensity_row.add_child(intensity_value)
	vibration_toggle.toggled.connect(func(on: bool):
		AudioManager.set_vibration_enabled(on)
		intensity_slider.editable = on
		intensity_slider.focus_mode = Control.FOCUS_ALL if on else Control.FOCUS_NONE
		if not on and get_viewport().gui_get_focus_owner() == intensity_slider:
			vibration_toggle.grab_focus())

func _format_money(amount) -> String:
	return GameState.format_money(float(amount))
