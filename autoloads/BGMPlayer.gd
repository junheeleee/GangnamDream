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
}

const AMBIENCE_TRACKS = {
	"room":        "res://assets/audio/amb_goshiwon_room.wav",
	"rain":        "res://assets/audio/amb_seoul_rain.wav",
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
}

# ── 상태 ──────────────────────────────────────────────────────
var volume: float       = 0.25
var _current_key: String = ""
var _active_key: String = ""
var _fade_target_key: String = ""
var _is_ending: bool    = false

var _player_a: AudioStreamPlayer  # 현재 재생
var _player_b: AudioStreamPlayer  # 크로스페이드 대상
var _ambience_player: AudioStreamPlayer
var _fade_tween: Tween
var _ambience_tween: Tween
var _procedural_stream: AudioStreamWAV  # 폴백 스트림 (1회 생성)
var _current_ambience_key: String = ""

const _FADE_TIME = 2.5  # 크로스페이드 초
const _AMBIENCE_VOLUME = 0.18

# ── 초기화 ────────────────────────────────────────────────────
func _ready():
	_player_a = _make_player()
	_player_b = _make_player()
	_ambience_player = _make_player()
	_procedural_stream = _bake_procedural()

func _make_player() -> AudioStreamPlayer:
	var p = AudioStreamPlayer.new()
	p.bus = "Master"
	add_child(p)
	return p

func start():
	volume = AudioManager.bgm_volume
	_is_ending = false
	_play_or_keep(_pick_track())
	update_idle_ambience()

func start_menu():
	volume = AudioManager.bgm_volume
	_is_ending = false
	_play_or_keep("menu")
	clear_ambience()

func stop():
	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()
	_player_a.stop()
	_player_b.stop()
	if _ambience_player:
		_ambience_player.stop()
	_current_key = ""
	_active_key = ""
	_fade_target_key = ""
	_current_ambience_key = ""

func apply_volume(v: float):
	volume = clampf(v, 0.0, 1.0)
	_player_a.volume_db = _db(volume)
	_player_b.volume_db = _db(0.0 if not _player_b.playing else volume)
	if _ambience_player and _ambience_player.playing:
		_ambience_player.volume_db = _db(volume * _AMBIENCE_VOLUME)

# ── 매월 상태 체크 ─────────────────────────────────────────────
func update_context():
	if _is_ending:
		return
	var target = _pick_track()
	if target != _current_key:
		_crossfade_to(target)

func on_ending(ending_id: String):
	_is_ending = true
	clear_ambience()
	_crossfade_to(AudioManager.ending_bgm_key(ending_id))

func update_idle_ambience() -> void:
	if _is_ending:
		clear_ambience()
		return
	match str(GameState.housing):
		"gangnam", "apartment":
			set_ambience("rain")
		"villa", "oneroom":
			set_ambience("room")
		_:
			set_ambience("room")

func update_event_ambience(ev: Dictionary) -> void:
	if _is_ending:
		clear_ambience()
		return
	set_ambience(_pick_ambience(ev))

func set_ambience(key: String) -> void:
	if key == _current_ambience_key and _ambience_player and _ambience_player.playing:
		return
	_current_ambience_key = key
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
	_ambience_tween.tween_property(_ambience_player, "volume_db", _db(volume * _AMBIENCE_VOLUME), 0.65)

func clear_ambience() -> void:
	set_ambience("")

func _pick_ambience(ev: Dictionary) -> String:
	var tags: Array = ev.get("tags", [])
	var bg_id := _event_background_id(ev)
	var category := str(ev.get("category", "")).to_lower()
	var event_id := str(ev.get("id", ""))
	var hay: String = (str(ev.get("title", "")) + " " + str(ev.get("description", ""))).to_lower()
	if event_id == "callback_hoesik_payoff":
		return "office"
	if event_id in ["arc_36_body_signal", "arc_gangnam_real_estate"]:
		return "room"
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
	if "chuseok_highway" in bg_id \
			or "추석 귀성길" in hay or "귀성길" in hay or "고속도로" in hay or "시외버스" in hay \
			or "chuseok traffic" in hay or "homecoming traffic" in hay or "intercity bus" in hay:
		return "highway"
	if "open_chat_screen" in bg_id or str(ev.get("id", "")) == "kx_open_chat" \
			or "오픈채팅" in hay or "오픈 채팅" in hay or "open chat" in hay or "chat room" in hay:
		return "open_chat"
	if "library" in bg_id or "도서관" in hay or "열람실" in hay \
			or "public library" in hay or "reading room" in hay:
		return "library"
	if "rain" in tags or "street_rainy" in bg_id or "비" in hay or "빗" in hay or "장마" in hay or "monsoon" in hay:
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
	if "cafe" in tags or "date" in tags or "cafe" in bg_id or "카페" in hay or "커피" in hay:
		return "cafe"
	if "pojangmacha" in tags or "pojangmacha" in bg_id or "포장마차" in hay:
		return "street"
	if "hangang" in tags or "hangang" in bg_id or "한강" in hay:
		return "hangang"
	if "meeting" in bg_id or "세미나" in hay or "seminar" in hay:
		return "office"
	if "office" in tags or "work" in tags or "jobs" in tags or category == "jobs" \
			or "office" in bg_id or "회사" in hay or "사무실" in hay:
		return "office"
	if bg_id in ["street", "street_day"] or "gangnam_station" in bg_id \
			or "거리" in hay or "street" in hay:
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
	# 후반 긴장 — 마감 2년 이내(36세부터)
	if GameState.age >= 36:
		return "late_tense"
	# 초중반 — 취직 후 1년(12개월) 이상 경과
	var _me: int = (GameState.age - 33) * 12 + GameState.month
	if _me >= 12 and not GameState.current_job.is_empty():
		return "hustle"
	return "early"

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

func _crossfade_to(key: String):
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
	_player_b.play()

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
	var path = TRACKS.get(key, "")
	if path != "" and ResourceLoader.exists(path):
		return load(path)
	# 파일 없으면 프로시저럴 폴백
	return _procedural_stream

func _load_ambience(key: String) -> AudioStream:
	var path = AMBIENCE_TRACKS.get(key, "")
	if path == "" or not ResourceLoader.exists(path):
		return null
	var stream = load(path)
	if stream is AudioStreamWAV:
		stream = stream.duplicate()
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = int(round((stream as AudioStreamWAV).get_length() * float((stream as AudioStreamWAV).mix_rate)))
	return stream

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
