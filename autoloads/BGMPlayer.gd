extends Node
## BGMPlayer — 게임 상태에 따라 BGM과 낮은 ambience 레이어 자동 전환
## assets/audio의 Ogg Vorbis 트랙 우선 재생, 없으면 프로시저럴 폴백

# ── 트랙 정의 ─────────────────────────────────────────────────
const TRACKS = {
	"menu":        "res://assets/audio/bgm_menu.ogg",
	"early":       "res://assets/audio/bgm_gosiwon.ogg",
	"hustle":      "res://assets/audio/bgm_main.ogg",
	"late_tense":  "res://assets/audio/bgm_apartment.ogg",
	"crisis":      "res://assets/audio/bgm_crisis.ogg",
	"ending_good": "res://assets/audio/bgm_victory.ogg",
	"ending_bad":  "res://assets/audio/bgm_ending.ogg",
	"wedding_processional": "res://assets/audio/bgm_wedding_processional.ogg",
	"intimate":    "res://assets/audio/bgm_intimate.ogg",
	"reckoning":   "res://assets/audio/bgm_reckoning.ogg",
	"grief":       "res://assets/audio/bgm_grief.ogg",
	"wonder":      "res://assets/audio/bgm_wonder.ogg",
	"family":      "res://assets/audio/bgm_family.ogg",
	"survival":    "res://assets/audio/bgm_survival.ogg",
	"hyunsu":      "res://assets/audio/bgm_hyunsu.ogg",
	"ambition":    "res://assets/audio/bgm_ambition.ogg",
	"daeun":       "res://assets/audio/bgm_daeun.ogg",
	"jiyeon":      "res://assets/audio/bgm_jiyeon.ogg",
	"casino_floor": "res://assets/audio/bgm_casino_floor.ogg",
	"casino_table": "res://assets/audio/bgm_casino_table.ogg",
}

const CASINO_TRACK_KEYS = ["casino_floor", "casino_table"]

# These legacy lo-fi/routine masters may only be entered by the title/menu
# surface. StoryMode never requests them implicitly from an event category.
const LOBBY_ONLY_TRACK_KEYS = ["menu", "early", "hustle", "late_tense"]

# 선택적 출시용 테마 팩. 세 파일이 모두 있을 때만 컨텍스트 BGM 대신 밴드 변주를 쓴다.
# 일부 파일만 섞여 곡의 정체성이 흔들리는 상태는 AudioAssetCheck가 차단한다.
const MORAL_THEME_TRACKS = {
	"theme_neutral": "res://assets/audio/bgm_theme_neutral.ogg",
	"theme_dark":    "res://assets/audio/bgm_theme_dark.ogg",
	"theme_white":   "res://assets/audio/bgm_theme_white.ogg",
}

const AMBIENCE_TRACKS = {
	"room":        "res://assets/audio/amb_goshiwon_room.wav",
	"family_home": "res://assets/audio/amb_family_home.wav",
	"rain":        "res://assets/audio/amb_seoul_rain.wav",
	"rain_room":   "res://assets/audio/amb_rain_room.wav",
	"hangang":     "res://assets/audio/amb_hangang_riverside.wav",
	"office":      "res://assets/audio/amb_office_room.wav",
	"casino":      "res://assets/audio/amb_casino_floor.wav",
	"street":      "res://assets/audio/amb_seoul_street.wav",
	"subway":      "res://assets/audio/amb_subway_platform.wav",
	"racetrack":   "res://assets/audio/amb_racetrack_crowd.wav",
	"cafe":        "res://assets/audio/amb_cafe_room.wav",
	"pc_bang":     "res://assets/audio/amb_pc_bang.wav",
	"gym":         "res://assets/audio/amb_gym_room.wav",
	"convenience": "res://assets/audio/amb_convenience_store.wav",
	"hagwon":      "res://assets/audio/amb_hagwon_street.wav",
	"school":      "res://assets/audio/amb_school_hall.wav",
	"public_office": "res://assets/audio/amb_public_office.wav",
	"jjimjilbang": "res://assets/audio/amb_jjimjilbang.wav",
	"cherry":      "res://assets/audio/amb_cherry_blossom.wav",
	"saju":        "res://assets/audio/amb_saju_cafe.wav",
	"military_gate": "res://assets/audio/amb_military_gate.wav",
	"hoesik":      "res://assets/audio/amb_company_dinner.wav",
	"heatwave":    "res://assets/audio/amb_heatwave_city.wav",
	"fine_dust":   "res://assets/audio/amb_fine_dust_city.wav",
	"highway":     "res://assets/audio/amb_highway_traffic.wav",
	"open_chat":   "res://assets/audio/amb_open_chat_room.wav",
	"library":     "res://assets/audio/amb_library_room.wav",
	"oneroom":     "res://assets/audio/amb_oneroom_room.wav",
	"apartment":   "res://assets/audio/amb_apartment_room.wav",
	"summer":      "res://assets/audio/amb_summer_night.wav",
	"winter":      "res://assets/audio/amb_winter_wind.wav",
	"wedding_hall": "res://assets/audio/amb_wedding_hall.wav",
	"hospital":    "res://assets/audio/amb_hospital_room.wav",
	"seaside":     "res://assets/audio/amb_seaside.wav",
	"amusement":   "res://assets/audio/amb_amusement_park.wav",
	"car":         "res://assets/audio/amb_car_interior.wav",
	"night_bus":   "res://assets/audio/amb_night_bus.wav",
	"train":       "res://assets/audio/amb_train_interior.wav",
}

# Mechanical/environmental room tone stays in AMBIENCE_TRACKS. These separate,
# wordless human layers are the only part that recedes strongly on dark routes.
const HUMAN_AMBIENCE_TRACKS = {
	"thin_wall":      "res://assets/audio/amb_human_thin_wall.wav",
	"street":         "res://assets/audio/amb_human_street.wav",
	"public_interior": "res://assets/audio/amb_human_public_interior.wav",
	"cafe":           "res://assets/audio/amb_human_cafe.wav",
	"casino":         "res://assets/audio/amb_human_casino.wav",
	"racetrack":      "res://assets/audio/amb_human_racetrack.wav",
	"wedding":        "res://assets/audio/amb_human_wedding.wav",
	"transit":        "res://assets/audio/amb_human_transit.wav",
	"leisure":        "res://assets/audio/amb_human_leisure.wav",
}

const HUMAN_AMBIENCE_BY_WORLD = {
	"room": "thin_wall",
	"family_home": "thin_wall",
	"rain": "street",
	"rain_room": "thin_wall",
	"hangang": "street",
	"office": "public_interior",
	"casino": "casino",
	"street": "street",
	"subway": "transit",
	"racetrack": "racetrack",
	"cafe": "cafe",
	"pc_bang": "leisure",
	"gym": "leisure",
	"convenience": "public_interior",
	"hagwon": "street",
	"school": "public_interior",
	"public_office": "public_interior",
	"jjimjilbang": "leisure",
	"cherry": "street",
	"saju": "cafe",
	"military_gate": "street",
	"hoesik": "leisure",
	"heatwave": "street",
	"fine_dust": "street",
	"highway": "transit",
	"library": "public_interior",
	"wedding_hall": "wedding",
	"hospital": "public_interior",
	"amusement": "leisure",
	"night_bus": "transit",
	"train": "transit",
}

const SCENE_AUDIO_MANIFEST_PATH = "res://assets/scene_audio_manifest.json"

# ── 상태 ──────────────────────────────────────────────────────
var volume: float       = 0.25
var _current_key: String = ""
var _active_key: String = ""
var _fade_target_key: String = ""
var _is_ending: bool    = false

var _player_a: AudioStreamPlayer  # 현재 재생
var _player_b: AudioStreamPlayer  # 크로스페이드 대상
var _ambience_player: AudioStreamPlayer
var _season_player: AudioStreamPlayer
var _human_ambience_player: AudioStreamPlayer
var _fade_tween: Tween
var _ambience_tween: Tween
var _season_tween: Tween
var _human_ambience_tween: Tween
var _moral_human_tween: Tween
var _moral_filter_tween: Tween
var _procedural_stream: AudioStreamWAV  # 폴백 스트림 (1회 생성)
var _current_ambience_key: String = ""
var _current_season_key: String = ""
var _current_human_ambience_key: String = ""
var _activity_ambience_key: String = ""
var _ambience_duck_db: float = 0.0
var _moral_filter: AudioEffectLowPassFilter
var _human_filter: AudioEffectLowPassFilter
var _bgm_bus_index: int = -1
var _human_bus_index: int = -1
var _last_moral_stage: int = 0
var _moral_target_cutoff_hz: float = 20500.0
var _moral_target_bus_db: float = 0.0
var _moral_ambience_gain_db: float = 0.0
var _moral_human_gain_db: float = -2.0
var _moral_human_cutoff_hz: float = 20500.0
var _moral_transition_count: int = 0
var _music_mode: String = "ambient"  # ambient | punctuation | activity | menu | ending
var _punctuation_token: int = 0
var _scene_audio_cg: Dictionary = {}
var _scene_audio_events: Dictionary = {}

const _FADE_TIME = 2.5  # 크로스페이드 초
const _AMBIENCE_VOLUME = 1.0
const _SEASON_VOLUME = 0.85
const _HUMAN_AMBIENCE_VOLUME = 1.0
const _AMBIENCE_TRIM_DB = 2.0
const _SEASON_TRIM_DB = 2.0
const _HUMAN_AMBIENCE_TRIM_DB = 6.0
const _BGM_BUS_NAME = "GangnamDreamBGM"
const _HUMAN_BUS_NAME = "GangnamDreamHumanAmbience"
const _MORAL_FILTER_TIME = 2.4
const _MORAL_HUMAN_TIME = 3.8
const _MORAL_CUTOFFS = {
	-2: 1450.0,
	-1: 4800.0,
	0: 20500.0,
	1: 20500.0,
	2: 20500.0,
}
const _MORAL_BUS_DB = {
	-2: -1.8,
	-1: -0.7,
	0: 0.0,
	1: 0.0,
	2: 0.0,
}
const _MORAL_AMBIENCE_DB = {
	-2: -5.0,
	-1: -2.2,
	0: 0.0,
	1: 1.0,
	2: 2.0,
}
const _MORAL_HUMAN_DB = {
	-2: -48.0,
	-1: -16.0,
	0: -2.0,
	1: 1.5,
	2: 3.5,
}
const _MORAL_HUMAN_CUTOFFS = {
	-2: 780.0,
	-1: 2600.0,
	0: 20500.0,
	1: 20500.0,
	2: 20500.0,
}

# ── 초기화 ────────────────────────────────────────────────────
func _ready():
	_load_scene_audio_manifest()
	_ensure_bgm_bus()
	_ensure_human_ambience_bus()
	_player_a = _make_player(_BGM_BUS_NAME)
	_player_b = _make_player(_BGM_BUS_NAME)
	_ambience_player = _make_player()
	_season_player = _make_player()
	_human_ambience_player = _make_player(_HUMAN_BUS_NAME)
	_procedural_stream = _bake_procedural()
	_last_moral_stage = GameState.moral_stage()
	_apply_moral_stage(_last_moral_stage, true)
	if not GameState.moral_tint_changed.is_connected(_on_moral_tint_changed):
		GameState.moral_tint_changed.connect(_on_moral_tint_changed)

func _make_player(bus_name: String = "Master") -> AudioStreamPlayer:
	var p = AudioStreamPlayer.new()
	p.bus = bus_name
	add_child(p)
	return p

func _ensure_bgm_bus() -> void:
	_bgm_bus_index = AudioServer.get_bus_index(_BGM_BUS_NAME)
	if _bgm_bus_index < 0:
		AudioServer.add_bus()
		_bgm_bus_index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(_bgm_bus_index, _BGM_BUS_NAME)
		AudioServer.set_bus_send(_bgm_bus_index, "Master")
	for effect_idx in range(AudioServer.get_bus_effect_count(_bgm_bus_index)):
		var existing: AudioEffect = AudioServer.get_bus_effect(_bgm_bus_index, effect_idx)
		if existing is AudioEffectLowPassFilter:
			_moral_filter = existing as AudioEffectLowPassFilter
			break
	if _moral_filter == null:
		_moral_filter = AudioEffectLowPassFilter.new()
		_moral_filter.cutoff_hz = 20500.0
		_moral_filter.resonance = 0.18
		AudioServer.add_bus_effect(_bgm_bus_index, _moral_filter)

func _ensure_human_ambience_bus() -> void:
	_human_bus_index = AudioServer.get_bus_index(_HUMAN_BUS_NAME)
	if _human_bus_index < 0:
		AudioServer.add_bus()
		_human_bus_index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(_human_bus_index, _HUMAN_BUS_NAME)
		AudioServer.set_bus_send(_human_bus_index, "Master")
	for effect_idx in range(AudioServer.get_bus_effect_count(_human_bus_index)):
		var existing: AudioEffect = AudioServer.get_bus_effect(_human_bus_index, effect_idx)
		if existing is AudioEffectLowPassFilter:
			_human_filter = existing as AudioEffectLowPassFilter
			break
	if _human_filter == null:
		_human_filter = AudioEffectLowPassFilter.new()
		_human_filter.cutoff_hz = 20500.0
		_human_filter.resonance = 0.12
		AudioServer.add_bus_effect(_human_bus_index, _human_filter)

func _on_moral_tint_changed(_norm: float, stage: int) -> void:
	if stage == _last_moral_stage:
		return
	_last_moral_stage = stage
	_moral_transition_count += 1
	_apply_moral_stage(stage, false)

func _apply_moral_stage(stage: int, immediate: bool) -> void:
	_moral_target_cutoff_hz = float(_MORAL_CUTOFFS.get(stage, 20500.0))
	_moral_target_bus_db = float(_MORAL_BUS_DB.get(stage, 0.0))
	_moral_ambience_gain_db = float(_MORAL_AMBIENCE_DB.get(stage, 0.0))
	_moral_human_gain_db = float(_MORAL_HUMAN_DB.get(stage, -2.0))
	_moral_human_cutoff_hz = float(_MORAL_HUMAN_CUTOFFS.get(stage, 20500.0))
	if _moral_filter != null and _bgm_bus_index >= 0:
		if _moral_filter_tween and _moral_filter_tween.is_running():
			_moral_filter_tween.kill()
		if immediate:
			_moral_filter.cutoff_hz = _moral_target_cutoff_hz
			AudioServer.set_bus_volume_db(_bgm_bus_index, _moral_target_bus_db)
		else:
			var current_bus_db: float = AudioServer.get_bus_volume_db(_bgm_bus_index)
			_moral_filter_tween = create_tween()
			_moral_filter_tween.set_parallel(true)
			_moral_filter_tween.set_trans(Tween.TRANS_SINE)
			_moral_filter_tween.set_ease(Tween.EASE_IN_OUT)
			_moral_filter_tween.tween_property(_moral_filter, "cutoff_hz", _moral_target_cutoff_hz, _MORAL_FILTER_TIME)
			_moral_filter_tween.tween_method(_set_moral_bus_db, current_bus_db, _moral_target_bus_db, _MORAL_FILTER_TIME)
	_apply_moral_ambience_mix(immediate)
	_apply_moral_human_mix(immediate)

func _apply_moral_ambience_mix(immediate: bool) -> void:
	if _ambience_tween and _ambience_tween.is_running():
		_ambience_tween.kill()
	if _season_tween and _season_tween.is_running():
		_season_tween.kill()
	if _ambience_player and _ambience_player.playing:
		if immediate:
			_ambience_player.volume_db = _ambience_target_db()
		else:
			_ambience_tween = create_tween()
			_ambience_tween.set_trans(Tween.TRANS_SINE)
			_ambience_tween.set_ease(Tween.EASE_IN_OUT)
			_ambience_tween.tween_property(_ambience_player, "volume_db", _ambience_target_db(), _MORAL_FILTER_TIME)
	if _season_player and _season_player.playing:
		if immediate:
			_season_player.volume_db = _season_target_db()
		else:
			_season_tween = create_tween()
			_season_tween.set_trans(Tween.TRANS_SINE)
			_season_tween.set_ease(Tween.EASE_IN_OUT)
			_season_tween.tween_property(_season_player, "volume_db", _season_target_db(), _MORAL_FILTER_TIME)

func _apply_moral_human_mix(immediate: bool) -> void:
	if _moral_human_tween and _moral_human_tween.is_running():
		_moral_human_tween.kill()
	if _human_ambience_tween and _human_ambience_tween.is_running():
		_human_ambience_tween.kill()
	if immediate or not _human_ambience_player or not _human_ambience_player.playing:
		if _human_filter != null:
			_human_filter.cutoff_hz = _moral_human_cutoff_hz
		if _human_ambience_player and _human_ambience_player.playing:
			_human_ambience_player.volume_db = _human_ambience_target_db()
		return
	_moral_human_tween = create_tween()
	_moral_human_tween.set_parallel(true)
	_moral_human_tween.set_trans(Tween.TRANS_SINE)
	_moral_human_tween.set_ease(Tween.EASE_IN_OUT)
	_moral_human_tween.tween_property(
		_human_ambience_player, "volume_db", _human_ambience_target_db(), _MORAL_HUMAN_TIME)
	if _human_filter != null:
		_moral_human_tween.tween_property(
			_human_filter, "cutoff_hz", _moral_human_cutoff_hz, _MORAL_HUMAN_TIME)

func _set_moral_bus_db(value: float) -> void:
	if _bgm_bus_index >= 0:
		AudioServer.set_bus_volume_db(_bgm_bus_index, value)

func start():
	volume = AudioManager.bgm_volume
	_is_ending = false
	_activity_ambience_key = ""
	_last_moral_stage = GameState.moral_stage()
	_apply_moral_stage(_last_moral_stage, true)
	enter_ambient_bed(0.65)
	update_idle_ambience()

func start_menu():
	volume = AudioManager.bgm_volume
	_is_ending = false
	_activity_ambience_key = ""
	_music_mode = "menu"
	_punctuation_token += 1
	_last_moral_stage = 0
	_apply_moral_stage(0, true)
	_play_or_keep("menu")
	clear_ambience()

func stop():
	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()
	if _moral_filter_tween and _moral_filter_tween.is_running():
		_moral_filter_tween.kill()
	if _season_tween and _season_tween.is_running():
		_season_tween.kill()
	if _human_ambience_tween and _human_ambience_tween.is_running():
		_human_ambience_tween.kill()
	if _moral_human_tween and _moral_human_tween.is_running():
		_moral_human_tween.kill()
	_player_a.stop()
	_player_b.stop()
	if _ambience_player:
		_ambience_player.stop()
	if _season_player:
		_season_player.stop()
	if _human_ambience_player:
		_human_ambience_player.stop()
	_current_key = ""
	_active_key = ""
	_fade_target_key = ""
	_current_ambience_key = ""
	_current_season_key = ""
	_current_human_ambience_key = ""
	_activity_ambience_key = ""
	_ambience_duck_db = 0.0
	_music_mode = "ambient"
	_punctuation_token += 1

func apply_volume(v: float):
	volume = clampf(v, 0.0, 1.0)
	_player_a.volume_db = _db(volume)
	_player_b.volume_db = _db(0.0 if not _player_b.playing else volume)
	if _ambience_player and _ambience_player.playing:
		_ambience_player.volume_db = _ambience_target_db()
	if _season_player and _season_player.playing:
		_season_player.volume_db = _season_target_db()
	if _human_ambience_player and _human_ambience_player.playing:
		_human_ambience_player.volume_db = _human_ambience_target_db()

# ── 매월 상태 체크 ─────────────────────────────────────────────
func update_context():
	if _is_ending:
		return
	# Monthly state changes update the lived room, not the soundtrack. Generic
	# routine music belongs to the menu and must not bleed into story playback.
	enter_ambient_bed(0.65)
	update_idle_ambience()

func enter_ambient_bed(fade_seconds: float = 0.8) -> void:
	_is_ending = false
	_music_mode = "ambient"
	_punctuation_token += 1
	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()
		_fade_tween = null
	if not _player_a.playing and not _player_b.playing:
		_finish_music_bed()
		return
	if fade_seconds <= 0.0:
		_finish_music_bed()
		return
	_fade_tween = create_tween()
	_fade_tween.set_parallel(true)
	if _player_a.playing:
		_fade_tween.tween_property(_player_a, "volume_db", -80.0, fade_seconds)
	if _player_b.playing:
		_fade_tween.tween_property(_player_b, "volume_db", -80.0, fade_seconds)
	_fade_tween.chain().tween_callback(_finish_music_bed)

func _finish_music_bed() -> void:
	_player_a.stop()
	_player_b.stop()
	_current_key = ""
	_active_key = ""
	_fade_target_key = ""
	_fade_tween = null

func play_punctuation(key: String = "") -> void:
	if _is_ending:
		return
	var target := key if not key.is_empty() else _pick_track()
	if target in LOBBY_ONLY_TRACK_KEYS:
		enter_ambient_bed(0.35)
		return
	_music_mode = "punctuation"
	_punctuation_token += 1
	_play_or_keep(target)

func begin_story_event(ev: Dictionary, cg_id: String = "") -> void:
	var contract: Dictionary = scene_audio_contract(str(ev.get("id", "")), cg_id)
	if bool(contract.get("suppress_music", false)):
		enter_ambient_bed(0.4)
		return
	var authored_music: Variant = contract.get("music", null)
	if authored_music is Dictionary:
		var start_paragraph: int = maxi(0, int(authored_music.get("start_paragraph", 0)))
		var target_key: String = str(authored_music.get("key", ""))
		if start_paragraph > 0 and target_key != _current_key:
			enter_ambient_bed(0.4)
		# 저작 음악은 실제 문단 훅이 재생을 맡는다. 여기서 일반 아크 음악을
		# 예약하면 같은 곡으로 이어지는 체인도 이벤트 경계에서 끊긴다.
		return
	# Story importance is not a music cue. Unscored events keep only their
	# authored place, season, and human ambience; explicit manifest entries own
	# every cinematic score entrance.
	enter_ambient_bed(0.55)

func on_ending(ending_id: String, cg_id: String = ""):
	_is_ending = true
	_activity_ambience_key = ""
	_music_mode = "ending"
	_punctuation_token += 1
	clear_ambience()
	_crossfade_to(AudioManager.ending_bgm_key(ending_id))
	if not cg_id.is_empty():
		apply_ending_cg_ambience(cg_id)

func update_idle_ambience() -> void:
	if _is_ending:
		clear_ambience()
		return
	if not _activity_ambience_key.is_empty():
		set_ambience(_activity_ambience_key)
		set_season_ambience("")
		return
	match str(GameState.housing):
		"gangnam", "apartment":
			set_ambience("apartment")
		"villa", "oneroom":
			set_ambience("oneroom")
		_:
			set_ambience("room")
	set_season_ambience(_calendar_season_key())

func enter_activity_ambience(key: String) -> void:
	if key.is_empty() or not AMBIENCE_TRACKS.has(key):
		return
	_activity_ambience_key = key
	# 장소 룸톤은 모든 미니게임의 기본 베드다. 전용 음악을 소유한
	# 정선 카지노만 이 호출 직후 같은 장소 위에 activity score를 얹는다.
	var keep_activity_music := key == "casino" and _music_mode == "activity" \
			and _current_key in CASINO_TRACK_KEYS
	if not keep_activity_music:
		enter_ambient_bed(0.45)
	set_ambience(key)
	set_season_ambience("")

func leave_activity_ambience(key: String = "") -> void:
	if not key.is_empty() and _activity_ambience_key != key:
		return
	_activity_ambience_key = ""
	update_idle_ambience()

func activity_ambience_key() -> String:
	return _activity_ambience_key

func enter_casino_music(layer: String = "floor") -> void:
	if _is_ending:
		return
	var target_key := "casino_table" if layer == "table" else "casino_floor"
	_music_mode = "activity"
	_punctuation_token += 1
	if _current_key in CASINO_TRACK_KEYS and _player_a.playing:
		_crossfade_to(target_key, true)
	else:
		_play_or_keep(target_key)

func leave_casino_music() -> void:
	if _music_mode != "activity" and _current_key not in CASINO_TRACK_KEYS:
		return
	enter_ambient_bed(0.8)

func update_event_ambience(
		ev: Dictionary, cg_id: String = "", resolved_background_id: String = "") -> void:
	if _is_ending:
		clear_ambience()
		return
	var contract: Dictionary = scene_audio_contract(str(ev.get("id", "")), cg_id)
	var ambience_key: String = _resolve_dynamic_ambience_key(str(contract.get("ambience", "")))
	if ambience_key.is_empty():
		ambience_key = _pick_ambience(ev, resolved_background_id)
	set_ambience(ambience_key)
	set_season_ambience(_event_season_key(ambience_key))

func play_scene_paragraph_music(ev: Dictionary, cg_id: String, paragraph_index: int) -> void:
	var contract: Dictionary = scene_audio_contract(str(ev.get("id", "")), cg_id)
	var authored_music: Variant = contract.get("music", null)
	if not (authored_music is Dictionary):
		return
	if maxi(0, int(authored_music.get("start_paragraph", 0))) != paragraph_index:
		return
	var key: String = str(authored_music.get("key", ""))
	if key.is_empty() or not TRACKS.has(key):
		return
	play_punctuation(key)

func apply_ending_cg_ambience(cg_id: String) -> void:
	var contract: Dictionary = scene_audio_contract("", cg_id)
	var ambience_key: String = _resolve_dynamic_ambience_key(str(contract.get("ambience", "")))
	if ambience_key.is_empty():
		return
	set_ambience(ambience_key)
	set_season_ambience("")

func _resolve_dynamic_ambience_key(key: String) -> String:
	if key != "current_housing":
		return key
	match str(GameState.housing):
		"gangnam", "apartment":
			return "apartment"
		"villa", "oneroom":
			return "oneroom"
		_:
			return "room"

func scene_audio_contract(event_id: String = "", cg_id: String = "") -> Dictionary:
	var merged: Dictionary = {}
	if not cg_id.is_empty() and _scene_audio_cg.has(cg_id):
		var cg_contract: Variant = _scene_audio_cg.get(cg_id, {})
		if cg_contract is Dictionary:
			merged = cg_contract.duplicate(true)
	if not event_id.is_empty() and _scene_audio_events.has(event_id):
		var event_contract: Variant = _scene_audio_events.get(event_id, {})
		if event_contract is Dictionary:
			for key in event_contract.keys():
				merged[key] = event_contract[key]
	return merged

func _load_scene_audio_manifest() -> void:
	_scene_audio_cg = {}
	_scene_audio_events = {}
	if not FileAccess.file_exists(SCENE_AUDIO_MANIFEST_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SCENE_AUDIO_MANIFEST_PATH))
	if not (parsed is Dictionary):
		return
	var cg_contracts: Variant = parsed.get("cg", {})
	var event_contracts: Variant = parsed.get("events", {})
	if cg_contracts is Dictionary:
		_scene_audio_cg = cg_contracts.duplicate(true)
	if event_contracts is Dictionary:
		_scene_audio_events = event_contracts.duplicate(true)

func set_ambience(key: String) -> void:
	if key == _current_ambience_key and _ambience_player and _ambience_player.playing:
		_set_human_ambience_for_world(key)
		return
	_current_ambience_key = key
	_set_human_ambience_for_world(key)
	if _ambience_tween and _ambience_tween.is_running():
		_ambience_tween.kill()
	if key == "" or not AMBIENCE_TRACKS.has(key):
		if _ambience_player and _ambience_player.playing:
			_ambience_tween = create_tween()
			_ambience_tween.tween_property(_ambience_player, "volume_db", -80.0, 0.45)
			_ambience_tween.tween_callback(_ambience_player.stop)
		return
	var stream := _load_ambience(key)
	if stream == null:
		return
	_ambience_player.stream = stream
	_ambience_player.volume_db = -80.0
	_ambience_player.play()
	_ambience_tween = create_tween()
	_ambience_tween.tween_property(_ambience_player, "volume_db", _ambience_target_db(), 0.65)

func _set_human_ambience_for_world(world_key: String) -> void:
	var human_key := str(HUMAN_AMBIENCE_BY_WORLD.get(world_key, ""))
	if human_key == _current_human_ambience_key \
			and _human_ambience_player and _human_ambience_player.playing:
		return
	_current_human_ambience_key = human_key
	if _human_ambience_tween and _human_ambience_tween.is_running():
		_human_ambience_tween.kill()
	if _moral_human_tween and _moral_human_tween.is_running():
		_moral_human_tween.kill()
	if human_key.is_empty() or not HUMAN_AMBIENCE_TRACKS.has(human_key):
		if _human_ambience_player and _human_ambience_player.playing:
			_human_ambience_tween = create_tween()
			_human_ambience_tween.tween_property(
				_human_ambience_player, "volume_db", -80.0, 0.55)
			_human_ambience_tween.tween_callback(_human_ambience_player.stop)
		return
	var stream := _load_human_ambience(human_key)
	if stream == null:
		return
	_human_ambience_player.stream = stream
	_human_ambience_player.volume_db = -80.0
	_human_ambience_player.play()
	if _human_filter != null:
		_human_filter.cutoff_hz = _moral_human_cutoff_hz
	_human_ambience_tween = create_tween()
	_human_ambience_tween.set_trans(Tween.TRANS_SINE)
	_human_ambience_tween.set_ease(Tween.EASE_IN_OUT)
	_human_ambience_tween.tween_property(
		_human_ambience_player, "volume_db", _human_ambience_target_db(), 1.1)

func set_season_ambience(key: String) -> void:
	if key == _current_season_key and _season_player and _season_player.playing:
		return
	_current_season_key = key
	if _season_tween and _season_tween.is_running():
		_season_tween.kill()
	if key == "" or not AMBIENCE_TRACKS.has(key):
		if _season_player and _season_player.playing:
			_season_tween = create_tween()
			_season_tween.tween_property(_season_player, "volume_db", -80.0, 0.45)
			_season_tween.tween_callback(_season_player.stop)
		return
	var stream := _load_ambience(key)
	if stream == null:
		return
	_season_player.stream = stream
	_season_player.volume_db = -80.0
	_season_player.play()
	_season_tween = create_tween()
	_season_tween.tween_property(_season_player, "volume_db", _season_target_db(), 0.85)

func clear_ambience() -> void:
	set_ambience("")
	set_season_ambience("")

func duck_ambience(amount_db: float = -8.0, duration: float = 0.45) -> void:
	_ambience_duck_db = minf(0.0, amount_db)
	if not _ambience_player or not _ambience_player.playing:
		return
	if _ambience_tween and _ambience_tween.is_running():
		_ambience_tween.kill()
	_ambience_tween = create_tween()
	_ambience_tween.tween_property(_ambience_player, "volume_db", _ambience_target_db(), maxf(0.05, duration))
	if _season_player and _season_player.playing:
		if _season_tween and _season_tween.is_running():
			_season_tween.kill()
		_season_tween = create_tween()
		_season_tween.tween_property(_season_player, "volume_db", _season_target_db(), maxf(0.05, duration))
	if _human_ambience_player and _human_ambience_player.playing:
		if _human_ambience_tween and _human_ambience_tween.is_running():
			_human_ambience_tween.kill()
		if _moral_human_tween and _moral_human_tween.is_running():
			_moral_human_tween.kill()
		_human_ambience_tween = create_tween()
		_human_ambience_tween.tween_property(
			_human_ambience_player, "volume_db", _human_ambience_target_db(), maxf(0.05, duration))

func restore_ambience(duration: float = 0.35) -> void:
	if is_zero_approx(_ambience_duck_db):
		return
	_ambience_duck_db = 0.0
	if not _ambience_player or not _ambience_player.playing:
		return
	if _ambience_tween and _ambience_tween.is_running():
		_ambience_tween.kill()
	_ambience_tween = create_tween()
	_ambience_tween.tween_property(_ambience_player, "volume_db", _ambience_target_db(), maxf(0.05, duration))
	if _season_player and _season_player.playing:
		if _season_tween and _season_tween.is_running():
			_season_tween.kill()
		_season_tween = create_tween()
		_season_tween.tween_property(_season_player, "volume_db", _season_target_db(), maxf(0.05, duration))
	if _human_ambience_player and _human_ambience_player.playing:
		if _human_ambience_tween and _human_ambience_tween.is_running():
			_human_ambience_tween.kill()
		if _moral_human_tween and _moral_human_tween.is_running():
			_moral_human_tween.kill()
		_human_ambience_tween = create_tween()
		_human_ambience_tween.tween_property(
			_human_ambience_player, "volume_db", _human_ambience_target_db(), maxf(0.05, duration))

func _ambience_target_db() -> float:
	return _db(volume * _AMBIENCE_VOLUME) + _AMBIENCE_TRIM_DB \
			+ _ambience_duck_db + _moral_ambience_gain_db

func _season_target_db() -> float:
	return _db(volume * _SEASON_VOLUME) + _SEASON_TRIM_DB \
			+ _ambience_duck_db + _moral_ambience_gain_db

func _human_ambience_target_db() -> float:
	return _db(volume * _HUMAN_AMBIENCE_VOLUME) + _HUMAN_AMBIENCE_TRIM_DB \
			+ _ambience_duck_db + _moral_human_gain_db

func _calendar_season_key() -> String:
	if GameState.month in [6, 7, 8]:
		return "summer"
	if GameState.month in [12, 1, 2]:
		return "winter"
	return ""

func _event_season_key(ambience_key: String) -> String:
	if ambience_key in ["rain", "rain_room", "heatwave", "fine_dust", "casino", "office", "cafe", \
			"pc_bang", "gym", "convenience", "library", "school", "public_office", \
			"jjimjilbang", "open_chat", "room", "oneroom", "apartment", "wedding_hall", \
			"hospital", "seaside", "amusement", "car", "night_bus", "train"]:
		return ""
	return _calendar_season_key()

func _pick_ambience(ev: Dictionary, resolved_background_id: String = "") -> String:
	var bg_id := resolved_background_id.strip_edges().to_lower()
	var has_resolved_background := not bg_id.is_empty()
	if not has_resolved_background:
		bg_id = _event_background_id(ev)
	# 실제 렌더된 장소가 있으면 번역 본문과 장르 태그가 그 장소를
	# 덮어쓰지 못한다. 두 값은 배경 ID조차 없는 레거시 사건의 폴백이다.
	var tags: Array = [] if has_resolved_background else ev.get("tags", [])
	var category: String = "" if has_resolved_background else \
		str(ev.get("category", "")).to_lower()
	var event_id := str(ev.get("id", ""))
	var hay := "" if has_resolved_background else \
		(str(ev.get("title", "")) + " " + str(ev.get("description", ""))).to_lower()
	var padded_hay := " " + hay.replace("\n", " ") + " "
	var rain_in_text := " rain " in padded_hay or " rainy " in padded_hay \
			or " raining " in padded_hay or " rainfall " in padded_hay \
			or "비가" in hay or "비를" in hay or "비에" in hay \
			or "비 오는" in hay or "비 내" in hay or "빗" in hay or "장마" in hay or "monsoon" in hay
	if event_id == "callback_hoesik_payoff":
		return "office"
	if event_id in ["arc_36_body_signal", "arc_gangnam_real_estate"]:
		return "room"
	if event_id in ["story_knee_door", "story_knee_witness", "story_knee_choice"]:
		return "family_home"
	if "casino" in tags or "jeongseon" in tags or "jeongseon_casino" in tags \
			or "casino" in bg_id or "카지노" in hay or "바카라" in hay or "블랙잭" in hay:
		return "casino"
	if "racetrack" in tags or "race" in tags or "racetrack" in bg_id or "경마" in hay or "마권" in hay:
		return "racetrack"
	if "subway" in tags or "commute" in tags or "subway" in bg_id or "지하철" in hay:
		return "subway"
	if "pc_bang" in tags or "gaming" in tags or "pc_bang" in bg_id \
			or "pc방" in hay or "피시방" in hay or "pc bang" in hay or "internet cafe" in hay:
		return "pc_bang"
	if "cherry_blossom" in tags or "spring_cherry" in tags or "cherry_blossom" in bg_id \
			or "벚꽃" in hay or "꽃잎" in hay or "cherry blossom" in hay or "petals" in hay:
		return "cherry"
	if "saju" in tags or "saju" in bg_id \
			or "사주" in hay or "fortune-reading" in hay or "fortune cafe" in hay:
		return "saju"
	if "hoesik" in tags or "company_dinner" in bg_id \
			or "회식" in hay or "삼겹살" in hay or "company dinner" in hay or "hoesik" in hay:
		return "hoesik"
	if "heatwave" in tags or "heatwave" in bg_id \
			or "폭염" in hay or "아스팔트 열기" in hay or "heatwave" in hay or "heat wave" in hay:
		return "heatwave"
	if "fine_dust" in tags or "fine_dust" in bg_id \
			or "미세먼지" in hay or "황사" in hay or "fine dust" in hay or "yellow dust" in hay or "air pollution" in hay:
		return "fine_dust"
	if "bus_terminal" in bg_id or "chuseok_highway" in bg_id \
			or "추석 귀성길" in hay or "귀성길" in hay or "고속도로" in hay or "시외버스" in hay \
			or "chuseok traffic" in hay or "homecoming traffic" in hay or "intercity bus" in hay:
		return "highway"
	if "open_chat_screen" in bg_id or str(ev.get("id", "")) == "kx_open_chat" \
			or "오픈채팅" in hay or "오픈 채팅" in hay or "open chat" in hay or "chat room" in hay:
		return "open_chat"
	if "library" in bg_id or "도서관" in hay or "열람실" in hay \
			or "public library" in hay or "reading room" in hay:
		return "library"
	if "rain" in tags or "street_rainy" in bg_id or rain_in_text:
		return "rain"
	if "hagwon" in tags or "hagwon" in bg_id \
			or "학원가" in hay or "대치동" in hay or "hagwon" in hay or "private academy" in hay:
		return "hagwon"
	if "suneung" in tags or "suneung" in bg_id or "test_hall" in bg_id \
			or "수능" in hay or "시험장" in hay or "고사장" in hay or "csat" in hay or "exam hall" in hay:
		return "school"
	if "community_center" in tags or "community_center" in bg_id \
			or "주민센터" in hay or "동사무소" in hay or "community center" in hay or "district office" in hay:
		return "public_office"
	if "jjimjilbang" in tags or "jjimjilbang" in bg_id \
			or "찜질방" in hay or "사우나" in hay or "korean sauna" in hay:
		return "jjimjilbang"
	if "reserve_duty" in tags or "military_base_gate" in bg_id \
			or "예비군" in hay or "reserve forces" in hay or "reserve duty" in hay or "reserve training" in hay:
		return "military_gate"
	if "gym" in tags or "exercise" in tags or "gym" in bg_id or "헬스장" in hay or "운동" in hay:
		return "gym"
	if "convenience" in tags or "convenience" in bg_id or "편의점" in hay:
		return "convenience"
	if "private_dining" in bg_id:
		return "cafe"
	if "cafe" in tags or "date" in tags or "cafe" in bg_id or "카페" in hay or "커피" in hay:
		return "cafe"
	if "pojangmacha" in tags or "pojangmacha" in bg_id or "포장마차" in hay:
		return "street"
	if "hangang" in tags or "hangang" in bg_id or "한강" in hay:
		return "hangang"
	if "meeting" in bg_id or "세미나" in hay or "seminar" in hay:
		return "office"
	if "hospital" in bg_id:
		return "hospital"
	if "wedding" in bg_id:
		return "wedding_hall"
	if "seaside" in bg_id or "beach" in bg_id:
		return "seaside"
	if "amusement" in bg_id:
		return "amusement"
	if "car_" in bg_id or bg_id.begins_with("car"):
		return "car"
	if "ktx" in bg_id or "train" in bg_id:
		return "train"
	if "oneroom" in bg_id:
		return "oneroom"
	if "apartment" in bg_id:
		return "apartment"
	if "office" in tags or "work" in tags or "jobs" in tags or category == "jobs" \
			or "office" in bg_id or "회사" in hay or "사무실" in hay:
		return "office"
	if "street" in tags or "street" in bg_id \
			or bg_id in ["gangnam_day", "gangnam_night", "gangnam_station"] \
			or "거리" in hay or "street" in hay:
		return "street"
	if "rooftop" in tags or "rooftop" in bg_id:
		return "street"
	if "night" in tags:
		return "rain"
	return "room"

func _event_background_id(ev: Dictionary) -> String:
	var explicit_bg := str(ev.get("background", "")).strip_edges()
	if explicit_bg != "":
		return explicit_bg.to_lower()
	if ImageRegistry and ImageRegistry.has_method("infer_background_id"):
		return str(ImageRegistry.infer_background_id(ev, GameState.housing)).to_lower()
	return ""

# ── 트랙 선택 로직 ─────────────────────────────────────────────
func _pick_track() -> String:
	# 위기 우선 — 건강 ≤35 OR 정신력 ≤25
	if GameState.health <= 35 or GameState.mental <= 25:
		return "crisis"
	# 출시용 3변주 팩이 완성되면 평상시 컨텍스트 대신 moral 밴드 테마를 사용한다.
	if _moral_theme_pack_ready():
		return _moral_theme_key(_last_moral_stage)
	# 후반 긴장 — 마감 2년 이내(36세부터)
	if GameState.age >= 36:
		return "late_tense"
	# 초중반 — 취직 후 1년(12개월) 이상 경과
	var _me: int = (GameState.age - 33) * 12 + GameState.month
	if _me >= 12 and not GameState.current_job.is_empty():
		return "hustle"
	return "early"

func _moral_theme_pack_ready() -> bool:
	for path_value in MORAL_THEME_TRACKS.values():
		if not ModLoader.audio_exists(str(path_value)):
			return false
	return true

func _moral_theme_key(stage: int) -> String:
	if stage <= -1:
		return "theme_dark"
	if stage >= 1:
		return "theme_white"
	return "theme_neutral"

# ── 크로스페이드 ──────────────────────────────────────────────
func _switch_to(key: String, immediate: bool = false):
	if key == _active_key and _player_a.playing:
		_current_key = key
		_player_a.volume_db = _db(volume)
		return
	_current_key = key
	_active_key = key
	_fade_target_key = ""
	var stream = _load_track(key)
	_player_a.stream    = stream
	_player_a.volume_db = _db(volume)
	_player_a.play()

func _play_or_keep(key: String) -> void:
	if key == _current_key and (_player_a.playing or _player_b.playing):
		if _fade_tween and _fade_tween.is_running():
			return
		if key == _active_key and _player_a.playing:
			_player_a.volume_db = _db(volume)
		return
	if _current_key != "" and _player_a.playing:
		_crossfade_to(key)
	else:
		_switch_to(key, true)

func _crossfade_to(key: String, preserve_phase: bool = false):
	if key == _current_key:
		return

	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()
		_fade_tween = null
		_player_b.stop()
		_player_a.volume_db = _db(volume)
		if key == _active_key:
			_current_key = key
			_fade_target_key = ""
			return

	_current_key = key
	_fade_target_key = key

	# B에 새 트랙 준비 (0 볼륨)
	var stream = _load_track(key)
	_player_b.stream    = stream
	_player_b.volume_db = _db(0.0)
	var start_position := 0.0
	if preserve_phase and _player_a.playing and stream != null:
		var stream_length: float = stream.get_length()
		if stream_length > 0.0:
			start_position = fmod(_player_a.get_playback_position(), stream_length)
	_player_b.play(start_position)

	# A 페이드아웃, B 페이드인
	_fade_tween = create_tween()
	_fade_tween.set_parallel(true)
	_fade_tween.tween_method(_set_vol_a, volume, 0.0, _FADE_TIME)
	_fade_tween.tween_method(_set_vol_b, 0.0, volume, _FADE_TIME)
	_fade_tween.chain().tween_callback(_swap_players)

func _set_vol_a(v: float): _player_a.volume_db = _db(v)
func _set_vol_b(v: float): _player_b.volume_db = _db(v)

func _swap_players():
	_player_a.stop()
	# A ↔ B 교체
	var tmp = _player_a
	_player_a = _player_b
	_player_b = tmp
	_active_key = _fade_target_key
	_fade_target_key = ""
	_fade_tween = null

# ── 스트림 로딩 ───────────────────────────────────────────────
func _load_track(key: String) -> AudioStream:
	var path: String = str(MORAL_THEME_TRACKS.get(key, TRACKS.get(key, "")))
	if path != "" and ModLoader.audio_exists(path):
		var stream := ModLoader.load_audio(path, true)
		if stream != null:
			return stream
	# 파일 없으면 프로시저럴 폴백
	return _procedural_stream

func _load_ambience(key: String) -> AudioStream:
	var path = AMBIENCE_TRACKS.get(key, "")
	return _load_looping_wav(str(path))

func _load_human_ambience(key: String) -> AudioStream:
	var path = HUMAN_AMBIENCE_TRACKS.get(key, "")
	return _load_looping_wav(str(path))

func _load_looping_wav(path: String) -> AudioStream:
	if path == "" or not ModLoader.audio_exists(path):
		return null
	return ModLoader.load_audio(path, true)

func _db(v: float) -> float:
	return -80.0 if v < 0.001 else 20.0 * log(v) / log(10.0)

# ── 프로시저럴 폴백 BGM (Suno 파일 없을 때) ─────────────────────
const SR  := 11025
const BPM := 80.0

func _bake_procedural() -> AudioStreamWAV:
	var beat := int(round(float(SR) * 60.0 / BPM))
	var bar  := beat * 4
	var loop := bar  * 4

	var _snap := func(f: float) -> float:
		return round(f * float(loop) / float(SR)) * float(SR) / float(loop)

	var C2: float  = float(_snap.call(65.41));  var Eb2: float = float(_snap.call(77.78))
	var Ab2: float = float(_snap.call(103.83)); var Bb2: float = float(_snap.call(116.54))
	var C3: float  = float(_snap.call(130.81)); var Eb3: float = float(_snap.call(155.56))
	var G3: float  = float(_snap.call(196.00)); var Bb3: float = float(_snap.call(233.08))
	var Ab3: float = float(_snap.call(207.65)); var C4: float  = float(_snap.call(261.63))
	var Eb4: float = float(_snap.call(311.13)); var G4: float  = float(_snap.call(392.00))
	var D4: float  = float(_snap.call(293.66)); var F4: float  = float(_snap.call(349.23)); var Ab4: float = float(_snap.call(415.30))

	var prog = [
		[C2, C3, Eb3, G3, Bb3], [Ab2, Ab3, C4, Eb4, G4],
		[Eb2, Eb3, G3, Bb3, Eb4], [Bb2, Bb3, D4, F4, Ab4],
	]
	var freqs: Array = []
	for chord in prog:
		for f in chord:
			if not freqs.has(f): freqs.append(f)
	var phases: Array = []; phases.resize(freqs.size()); phases.fill(0.0)

	var bar_maps: Array = []
	for chord in prog:
		var pad_fis: Array = []
		for ci in range(1, chord.size()): pad_fis.append(freqs.find(chord[ci]))
		bar_maps.append({"bass": freqs.find(chord[0]), "pads": pad_fis})

	var buf := PackedByteArray(); buf.resize(loop * 2)
	for i in range(loop):
		var bi   := i / bar
		var bpos := float(i % bar) / float(bar)
		var pad_env  := smoothstep(0.0, 0.05, bpos) * smoothstep(1.0, 0.92, bpos)
		var bass_env := smoothstep(0.0, 0.01, bpos) * smoothstep(0.45, 0.12, bpos)
		for fi in range(freqs.size()):
			var ph: float = phases[fi] + TAU * freqs[fi] / float(SR)
			if ph >= TAU: ph -= TAU
			phases[fi] = ph
		var bmap: Dictionary = bar_maps[bi % 4]
		var s := 0.0
		var bp: float = phases[bmap["bass"]]
		s += (sin(bp) * 0.6 + (2.0/PI)*asin(sin(bp)) * 0.4) * bass_env * 0.22
		for pi2 in range((bmap["pads"] as Array).size()):
			var fi2: int = (bmap["pads"] as Array)[pi2]
			var dp: float = phases[fi2] * (1.0 + float(pi2 % 2) * 0.003)
			s += (sin(dp) * 0.7 + (2.0/PI)*asin(clamp(sin(dp),-1.0,1.0)) * 0.3) * pad_env * 0.058
		var hihat_env := smoothstep(0.0,0.01,float(i%(beat/2))/float(beat/2)) * smoothstep(1.0,0.85,float(i%(beat/2))/float(beat/2))
		s += sin(float(i)*127.1+float(i*i)*0.00317)*sin(float(i)*311.7) * hihat_env * 0.018
		s = s / (1.0 + abs(s) * 0.6)
		s = clamp(s, -1.0, 1.0)
		var samp := int(s * 26000)
		buf[i*2] = samp & 0xFF; buf[i*2+1] = (samp>>8) & 0xFF

	var wav := AudioStreamWAV.new()
	wav.format=AudioStreamWAV.FORMAT_16_BITS; wav.mix_rate=SR
	wav.stereo=false; wav.data=buf
	wav.loop_mode=AudioStreamWAV.LOOP_FORWARD; wav.loop_begin=0; wav.loop_end=loop
	return wav
