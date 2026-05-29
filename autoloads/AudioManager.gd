extends Node

const SETTINGS_PATH = "user://gangnam_dream_settings.json"

var master_volume: float = 0.8
var bgm_volume: float    = 0.25
var sfx_enabled: bool    = true

var _pool: Array[AudioStreamPlayer] = []
const _POOL_SIZE = 8
var _sounds: Dictionary = {}

# wav 파일 → AudioManager key 매핑
const _SFX_FILES = {
	"click":       "res://assets/audio/sfx_click.wav",
	"close":       "res://assets/audio/sfx_close.wav",
	"open_modal":  "res://assets/audio/sfx_open_modal.wav",
	"month":       "res://assets/audio/sfx_month.wav",
	"money_gain":  "res://assets/audio/sfx_money_gain.wav",
	"money_loss":  "res://assets/audio/sfx_money_loss.wav",
	"money_big":   "res://assets/audio/sfx_money_big.wav",
	"stat_up":     "res://assets/audio/sfx_stat_up.wav",
	"stat_down":   "res://assets/audio/sfx_stat_down.wav",
	"event_new":   "res://assets/audio/sfx_event_new.wav",
	"choice_made": "res://assets/audio/sfx_choice_made.wav",
	"housing_up":  "res://assets/audio/sfx_housing_up.wav",
	"game_over":   "res://assets/audio/sfx_game_over.wav",
	"success":     "res://assets/audio/sfx_success.wav",
}

func _ready():
	load_settings()
	for i in range(_POOL_SIZE):
		var p = AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_pool.append(p)
	_load_sounds()
	_connect_signals()

func _load_sounds():
	# 실제 wav 파일 우선 로드, 없으면 프로시저럴 폴백
	for key in _SFX_FILES:
		var path = _SFX_FILES[key]
		if ResourceLoader.exists(path):
			_sounds[key] = load(path)
		else:
			_sounds[key] = _make_fallback(key)

func _make_fallback(key: String) -> AudioStreamWAV:
	# 파일 없을 때 간단한 비프로 대체
	match key:
		"click":      return _tone(880, 0.05, [1.0, 0.0])
		"close":      return _tone(440, 0.10, [0.8, 0.0])
		"open_modal": return _tone(660, 0.12, [0.3, 1.0, 0.0])
		"month":      return _chord([523, 659, 784], 0.25, [0.0, 0.8, 1.0, 0.0])
		"money_gain": return _chord([659, 784, 988], 0.20, [0.0, 0.8, 1.0, 0.0])
		"money_loss": return _tone(220, 0.28, [0.4, 1.0, 0.0])
		"money_big":  return _chord([523, 659, 784, 1047], 0.40, [0.0, 0.5, 1.0, 0.5, 0.0])
		"stat_up":    return _chord([523, 659], 0.16, [0.0, 1.0, 0.0])
		"stat_down":  return _tone(330, 0.20, [0.5, 1.0, 0.0])
		"event_new":  return _chord([440, 550], 0.14, [0.0, 1.0, 0.5, 0.0])
		"choice_made":return _tone(600, 0.09, [0.5, 1.0, 0.0])
		"housing_up": return _chord([523, 659, 784, 1047], 0.30, [0.0, 0.4, 1.0, 0.6, 0.0])
		"game_over":  return _tone(110, 0.70, [0.0, 0.5, 1.0, 0.8, 0.5, 0.0])
		"success":    return _chord([523, 659, 784, 1047], 0.55, [0.0, 0.3, 1.0, 0.8, 0.4, 0.0])
	return _tone(440, 0.1, [1.0, 0.0])

func load_settings():
	if FileAccess.file_exists(SETTINGS_PATH):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(SETTINGS_PATH))
		if parsed is Dictionary:
			master_volume = float(parsed.get("sfx_volume", 0.8))
			bgm_volume    = float(parsed.get("bgm_volume", 0.25))

func save_settings():
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"sfx_volume": master_volume, "bgm_volume": bgm_volume}))

func set_sfx_volume(v: float):
	master_volume = clampf(v, 0.0, 1.0)
	save_settings()

func set_bgm_volume(v: float):
	bgm_volume = clampf(v, 0.0, 1.0)
	BGMPlayer.apply_volume(bgm_volume)
	save_settings()

func _connect_signals():
	GameState.turn_advanced.connect(_on_turn_advanced)
	GameState.game_over.connect(_on_game_over)

func _on_turn_advanced(_turn: int):
	play("month")

func _on_game_over(ending: String):
	var good = ["gangnam_dream", "stable_success", "investment_master",
				"startup_exit", "reputation_legend", "healthy_retirement", "political_fix"]
	play("success" if ending in good else "game_over")

# ── 재생 ─────────────────────────────────────────────────────
func play(sound_id: String, volume_mod: float = 0.0):
	if not sfx_enabled or not _sounds.has(sound_id):
		return
	for p in _pool:
		if not p.playing:
			p.stream    = _sounds[sound_id]
			p.volume_db = _vol_db() + volume_mod
			p.play()
			return

func _vol_db() -> float:
	if master_volume <= 0.0: return -80.0
	return lerp(-20.0, 0.0, master_volume)

# ── 프로시저럴 폴백용 합성 ────────────────────────────────────
const _SAMPLE_RATE = 22050

func _tone(freq: float, duration: float, envelope: Array) -> AudioStreamWAV:
	return _chord([freq], duration, envelope)

func _chord(freqs: Array, duration: float, envelope: Array) -> AudioStreamWAV:
	var samples = int(_SAMPLE_RATE * duration)
	var data    = PackedByteArray()
	data.resize(samples * 2)
	var env_count = envelope.size()
	for i in range(samples):
		var t     = float(i) / float(samples)
		var seg   = t * (env_count - 1)
		var seg_i = int(seg)
		var seg_f = seg - float(seg_i)
		var amp   = lerp(float(envelope[seg_i]), float(envelope[min(seg_i + 1, env_count - 1)]), seg_f)
		var s     = 0.0
		for freq in freqs:
			s += sin(2.0 * PI * float(freq) * float(i) / float(_SAMPLE_RATE))
		s /= float(freqs.size())
		s = s / (1.0 + abs(s) * 0.4)
		data[i * 2]     = clamp(int(s * amp * 26000), -32768, 32767) & 0xFF
		data[i * 2 + 1] = (clamp(int(s * amp * 26000), -32768, 32767) >> 8) & 0xFF
	var wav = AudioStreamWAV.new()
	wav.format   = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = _SAMPLE_RATE
	wav.stereo   = false
	wav.data     = data
	return wav
