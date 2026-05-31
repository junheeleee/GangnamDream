extends Node
## BGMPlayer — 게임 상태에 따라 6트랙 자동 전환
## Suno .mp3 파일 우선 재생, 없으면 프로시저럴 폴백

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

# ── 상태 ──────────────────────────────────────────────────────
var volume: float       = 0.25
var _current_key: String = ""
var _is_ending: bool    = false

var _player_a: AudioStreamPlayer  # 현재 재생
var _player_b: AudioStreamPlayer  # 크로스페이드 대상
var _procedural_stream: AudioStreamWAV  # 폴백 스트림 (1회 생성)

const _FADE_TIME = 2.5  # 크로스페이드 초

# ── 초기화 ────────────────────────────────────────────────────
func _ready():
	_player_a = _make_player()
	_player_b = _make_player()
	_procedural_stream = _bake_procedural()

func _make_player() -> AudioStreamPlayer:
	var p = AudioStreamPlayer.new()
	p.bus = "Master"
	add_child(p)
	return p

func start():
	volume = AudioManager.bgm_volume
	_switch_to(_pick_track(), true)

func start_menu():
	volume = AudioManager.bgm_volume
	_switch_to("menu", true)

func stop():
	_player_a.stop()
	_player_b.stop()

func apply_volume(v: float):
	volume = clampf(v, 0.0, 1.0)
	_player_a.volume_db = _db(volume)

# ── 매월 상태 체크 ─────────────────────────────────────────────
func update_context():
	if _is_ending:
		return
	var target = _pick_track()
	if target != _current_key:
		_crossfade_to(target)

func on_ending(ending_id: String):
	_is_ending = true
	var good = ["gangnam_dream", "stable_success", "investment_master",
				"startup_exit", "reputation_legend", "healthy_retirement", "political_fix"]
	_crossfade_to("ending_good" if ending_id in good else "ending_bad")

# ── 트랙 선택 로직 ─────────────────────────────────────────────
func _pick_track() -> String:
	# 위기 우선 — 건강 ≤35 OR 스트레스 ≥75
	if GameState.health <= 35 or GameState.stress >= 75 or GameState.mental <= 30:
		return "crisis"
	# 후반 긴장 — 후반부(턴 36+) 또는 마감 1년 전(37세, 38세가 데드라인)
	if GameState.turn >= 36 or GameState.age >= 37:
		return "late_tense"
	# 초중반 — 취직 여부로 분기
	if GameState.turn >= 12 and not GameState.current_job.is_empty():
		return "hustle"
	return "early"

# ── 크로스페이드 ──────────────────────────────────────────────
func _switch_to(key: String, immediate: bool = false):
	_current_key = key
	var stream = _load_track(key)
	_player_a.stream    = stream
	_player_a.volume_db = _db(volume)
	_player_a.play()

func _crossfade_to(key: String):
	if key == _current_key:
		return
	_current_key = key

	# B에 새 트랙 준비 (0 볼륨)
	var stream = _load_track(key)
	_player_b.stream    = stream
	_player_b.volume_db = _db(0.0)
	_player_b.play()

	# A 페이드아웃, B 페이드인
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_method(_set_vol_a, volume, 0.0, _FADE_TIME)
	tw.tween_method(_set_vol_b, 0.0, volume, _FADE_TIME)
	tw.chain().tween_callback(_swap_players)

func _set_vol_a(v: float): _player_a.volume_db = _db(v)
func _set_vol_b(v: float): _player_b.volume_db = _db(v)

func _swap_players():
	_player_a.stop()
	# A ↔ B 교체
	var tmp = _player_a
	_player_a = _player_b
	_player_b = tmp

# ── 스트림 로딩 ───────────────────────────────────────────────
func _load_track(key: String) -> AudioStream:
	var path = TRACKS.get(key, "")
	if path != "" and ResourceLoader.exists(path):
		return load(path)
	# 파일 없으면 프로시저럴 폴백
	return _procedural_stream

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
