extends Node

const SETTINGS_PATH = "user://gangnam_dream_settings.json"

var master_volume: float = 0.8
var bgm_volume: float    = 0.25
var sfx_enabled: bool    = true

var _pool: Array[AudioStreamPlayer] = []
const _POOL_SIZE = 8
var _sounds: Dictionary = {}
var _last_sfx_ms: Dictionary = {}
var _last_ending_stinger_id: String = ""
var _last_ending_stinger_ms: int = 0
var _last_event_cue_id: String = ""
var _last_event_cue_ms: int = 0
var _last_direction_sting_token: String = ""
var _last_direction_sting_ms: int = 0

const _SFX_COOLDOWN_MS = {
	"click": 45,
	"close": 90,
	"open_modal": 90,
	"tab_open": 70,
	"casino_coin": 24,
	"civil_defense_siren": 5000,
	"monsoon_rain": 1800,
}

# wav 파일 → AudioManager key 매핑
const _SFX_FILES = {
	"click":       "res://assets/audio/sfx_click.wav",
	"close":       "res://assets/audio/sfx_close.wav",
	"open_modal":  "res://assets/audio/sfx_open_modal.wav",
	"tab_open":    "res://assets/audio/sfx_tab_open.wav",
	"month":       "res://assets/audio/sfx_month.wav",
	"money_gain":  "res://assets/audio/sfx_money_gain.wav",
	"money_loss":  "res://assets/audio/sfx_money_loss.wav",
	"money_big":   "res://assets/audio/sfx_money_big.wav",
	"buy":         "res://assets/audio/sfx_buy.wav",
	"sell":        "res://assets/audio/sfx_sell.wav",
	"stat_up":     "res://assets/audio/sfx_stat_up.wav",
	"stat_down":   "res://assets/audio/sfx_stat_down.wav",
	"event_new":   "res://assets/audio/sfx_event_new.wav",
	"choice_made": "res://assets/audio/sfx_choice_made.wav",
	"housing_up":  "res://assets/audio/sfx_housing_up.wav",
	"game_over":   "res://assets/audio/sfx_game_over.wav",
	"success":     "res://assets/audio/sfx_success.wav",
	# 미니게임 전용
	"casino_win":   "res://assets/audio/sfx_casino_win.wav",
	"casino_lose":  "res://assets/audio/sfx_casino_lose.wav",
	"casino_bet":   "res://assets/audio/sfx_casino_bet.wav",
	"casino_coin":  "res://assets/audio/sfx_casino_coin.wav",
	"casino_spin":  "res://assets/audio/sfx_casino_spin.wav",
	"casino_card":  "res://assets/audio/sfx_casino_card.wav",
	"casino_jackpot": "res://assets/audio/sfx_casino_jackpot.wav",
	"casino_reel":  "res://assets/audio/sfx_casino_reel.wav",
	"civil_defense_siren": "res://assets/audio/sfx_civil_defense_siren.wav",
	"monsoon_rain": "res://assets/audio/sfx_monsoon_rain.wav",
	"ending_stinger_good": "res://assets/audio/sfx_ending_stinger_good.wav",
	"ending_stinger_bad": "res://assets/audio/sfx_ending_stinger_bad.wav",
	"ending_stinger_legend": "res://assets/audio/sfx_ending_stinger_legend.wav",
}

const _ENDING_AUDIO_LEGEND = [
	"instant_legend", "gangnam_dream", "gangnam_dream_white", "full_circle",
	"unorthodox_legend",
]

const _ENDING_AUDIO_DARK = [
	"empty_house", "jaehyuk_way", "lonely_rich", "orthodox_hollow",
	"burnout", "mental_break", "bankruptcy", "crypto_ghost", "debt_spiral",
]

const _ENDING_AUDIO_HOPEFUL = [
	"stable_success", "ordinary_life", "with_daeun", "jiyeon_man",
	"startup_exit", "political_fix", "investment_master", "reputation_legend",
	"healthy_retirement", "orthodox_pinnacle", "balanced_life",
	"early_retirement", "creator_success", "late_call", "second_love",
	"guardian", "gambling_recovery", "career_climber", "career_burnout",
	"sangchul_reckoning", "writer",
]

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
		"tab_open":   return _chord([494, 659], 0.14, [0.0, 1.0, 0.0])
		"month":      return _chord([523, 659, 784], 0.25, [0.0, 0.8, 1.0, 0.0])
		"money_gain": return _chord([659, 784, 988], 0.20, [0.0, 0.8, 1.0, 0.0])
		"money_loss": return _tone(220, 0.28, [0.4, 1.0, 0.0])
		"money_big":  return _chord([523, 659, 784, 1047], 0.40, [0.0, 0.5, 1.0, 0.5, 0.0])
		"buy":        return _chord([440, 523], 0.14, [0.0, 1.0, 0.0])
		"sell":       return _chord([523, 440], 0.14, [0.0, 1.0, 0.0])
		"stat_up":    return _chord([523, 659], 0.16, [0.0, 1.0, 0.0])
		"stat_down":  return _tone(330, 0.20, [0.5, 1.0, 0.0])
		"event_new":  return _chord([440, 550], 0.14, [0.0, 1.0, 0.5, 0.0])
		"choice_made":return _tone(600, 0.09, [0.5, 1.0, 0.0])
		"housing_up": return _chord([523, 659, 784, 1047], 0.30, [0.0, 0.4, 1.0, 0.6, 0.0])
		"game_over":    return _tone(110, 0.70, [0.0, 0.5, 1.0, 0.8, 0.5, 0.0])
		"success":      return _chord([523, 659, 784, 1047], 0.55, [0.0, 0.3, 1.0, 0.8, 0.4, 0.0])
		"casino_win":   return _chord([659, 784, 988, 1319], 0.35, [0.0, 0.6, 1.0, 0.6, 0.0])
		"casino_lose":  return _tone(196, 0.32, [0.3, 1.0, 0.6, 0.0])
		"casino_bet":   return _tone(740, 0.07, [0.8, 1.0, 0.0])
		"casino_coin":  return _tone(1047, 0.06, [1.0, 0.8, 0.0])
		"casino_spin":  return _tone(330, 0.10, [0.5, 1.0, 0.0])
		"casino_card":  return _tone(880, 0.06, [1.0, 0.6, 0.0])
		"casino_jackpot": return _chord([523, 659, 784, 1047, 1319], 0.80, [0.0, 0.3, 0.8, 1.0, 0.8, 0.4, 0.0])
		"casino_reel":  return _tone(494, 0.04, [1.0, 0.0])
		"civil_defense_siren": return _chord([740, 988], 0.75, [0.0, 0.8, 1.0, 0.8, 0.0])
		"monsoon_rain": return _tone(180, 0.80, [0.0, 0.7, 1.0, 0.8, 0.0])
		"ending_stinger_good": return _chord([523, 659, 784, 1047], 1.10, [0.0, 0.4, 1.0, 0.6, 0.0])
		"ending_stinger_bad": return _tone(92, 1.25, [0.0, 0.7, 1.0, 0.4, 0.0])
		"ending_stinger_legend": return _chord([523, 659, 784, 1047, 1319], 1.55, [0.0, 0.3, 1.0, 0.8, 0.45, 0.0])
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
	play_ending_stinger(ending)

func play_ending_stinger(ending_id: String) -> void:
	var now := Time.get_ticks_msec()
	if ending_id == _last_ending_stinger_id and now - _last_ending_stinger_ms < 2000:
		return
	_last_ending_stinger_id = ending_id
	_last_ending_stinger_ms = now
	play(ending_stinger_key(ending_id))

func ending_audio_tone(ending_id: String) -> String:
	if ending_id in _ENDING_AUDIO_DARK:
		return "dark"
	if ending_id in _ENDING_AUDIO_LEGEND:
		return "legend"
	if ending_id in _ENDING_AUDIO_HOPEFUL:
		return "hopeful"
	var ending: Dictionary = DataRegistry.get_ending(ending_id)
	var grade := str(ending.get("grade", ""))
	if grade in ["?", "S+", "S"]:
		return "legend"
	if grade in ["A+", "A", "B"]:
		return "hopeful"
	return "dark"

func ending_bgm_key(ending_id: String) -> String:
	return "ending_bad" if ending_audio_tone(ending_id) == "dark" else "ending_good"

func ending_stinger_key(ending_id: String) -> String:
	match ending_audio_tone(ending_id):
		"legend":
			return "ending_stinger_legend"
		"hopeful":
			return "ending_stinger_good"
		_:
			return "ending_stinger_bad"

# ── 재생 ─────────────────────────────────────────────────────
func play(sound_id: String, volume_mod: float = 0.0):
	if not sfx_enabled or not _sounds.has(sound_id):
		return
	if _is_sfx_throttled(sound_id):
		return
	if sound_id == "click":
		volume_mod -= 8.0
	for p in _pool:
		if not p.playing:
			p.stream    = _sounds[sound_id]
			p.volume_db = _vol_db() + volume_mod
			p.pitch_scale = 1.0
			p.play()
			return

func play_direction_sting(kind: String, event_id: String = "") -> void:
	var token: String = "%s:%s" % [event_id, kind]
	var now: int = Time.get_ticks_msec()
	if token == _last_direction_sting_token and now - _last_direction_sting_ms < 3500:
		return
	_last_direction_sting_token = token
	_last_direction_sting_ms = now
	match kind:
		"reveal":
			_play_shaped("ending_stinger_good", -11.0, 0.78)
		"loss":
			_play_shaped("ending_stinger_bad", -4.0, 0.90)
		"cold":
			_play_shaped("ending_stinger_bad", -10.0, 1.12)

func _play_shaped(sound_id: String, volume_mod: float, pitch: float) -> void:
	if not sfx_enabled or not _sounds.has(sound_id):
		return
	for p in _pool:
		if not p.playing:
			p.stream = _sounds[sound_id]
			p.volume_db = _vol_db() + volume_mod
			p.pitch_scale = clampf(pitch, 0.5, 2.0)
			p.play()
			return

func play_event_cue(ev: Dictionary) -> void:
	var cue_key := _event_cue_key(ev)
	if cue_key == "":
		return
	var event_id := str(ev.get("id", ""))
	var now := Time.get_ticks_msec()
	if event_id == _last_event_cue_id and now - _last_event_cue_ms < 3500:
		return
	_last_event_cue_id = event_id
	_last_event_cue_ms = now
	match cue_key:
		"civil_defense_siren":
			play(cue_key, -5.0)
		"monsoon_rain":
			play(cue_key, -8.0)
		_:
			play(cue_key)

func _event_cue_key(ev: Dictionary) -> String:
	var event_id := str(ev.get("id", "")).to_lower()
	if event_id == "kx_civil_defense_siren":
		return "civil_defense_siren"
	if event_id == "kx_monsoon":
		return "monsoon_rain"
	var hay := (
		str(ev.get("title", "")) + " " +
		str(ev.get("description", ""))
	).to_lower()
	if "민방위" in hay or "civil defense siren" in hay:
		return "civil_defense_siren"
	if "장마" in hay or "monsoon" in hay:
		return "monsoon_rain"
	return ""

func play_ui_click(volume_mod: float = -4.0) -> void:
	play("click", volume_mod)
	pulse_gamepad(0.022, 0.045, 0.045)

func play_ui_close(volume_mod: float = -8.0) -> void:
	play("close", volume_mod)
	pulse_gamepad(0.035, 0.060, 0.070)

func play_ui_open(volume_mod: float = -5.0) -> void:
	play("open_modal", volume_mod)
	pulse_gamepad(0.030, 0.075, 0.060)

func play_delayed(sound_id: String, delay: float, volume_mod: float = 0.0) -> void:
	if delay <= 0.0:
		play(sound_id, volume_mod)
		return
	get_tree().create_timer(delay).timeout.connect(func():
		play(sound_id, volume_mod))

func play_casino_result(net_amount: float, stake: float = 0.0, force_jackpot: bool = false) -> void:
	var stake_abs: float = maxf(absf(stake), 1.0)
	if force_jackpot or net_amount >= maxf(stake_abs * 10.0, 1_000_000.0):
		play("casino_jackpot")
		pulse_gamepad(0.35, 0.90, 0.24)
	elif net_amount > 0.0:
		play("casino_win")
		pulse_gamepad(0.18, 0.45, 0.14)
	elif net_amount < 0.0:
		play("casino_lose")
		pulse_gamepad(0.32, 0.25, 0.18)
	else:
		play("casino_card", -4.0)
		pulse_gamepad(0.08, 0.08, 0.08)

func pulse_gamepad(weak: float, strong: float, duration: float = 0.12) -> void:
	if duration <= 0.0:
		return
	for device in Input.get_connected_joypads():
		Input.start_joy_vibration(
			int(device),
			clampf(weak, 0.0, 1.0),
			clampf(strong, 0.0, 1.0),
			duration
		)

func _vol_db() -> float:
	if master_volume <= 0.0: return -80.0
	return lerp(-20.0, 0.0, master_volume)

func _is_sfx_throttled(sound_id: String) -> bool:
	if not _SFX_COOLDOWN_MS.has(sound_id):
		return false
	var now := Time.get_ticks_msec()
	var last := int(_last_sfx_ms.get(sound_id, -1000000))
	if now - last < int(_SFX_COOLDOWN_MS[sound_id]):
		return true
	_last_sfx_ms[sound_id] = now
	return false

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
