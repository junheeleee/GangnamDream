extends Node

const SETTINGS_PATH = "user://gangnam_dream_settings.json"

# 볼륨 설정 (0.0 ~ 1.0)
var master_volume: float = 0.8
var bgm_volume: float = 0.25
var sfx_enabled: bool = true

var _pool: Array[AudioStreamPlayer] = []
const _POOL_SIZE = 8
var _sounds: Dictionary = {}

func _ready():
	load_settings()
	for i in range(_POOL_SIZE):
		var p = AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_pool.append(p)
	_generate_sounds()
	_connect_signals()

func load_settings():
	if FileAccess.file_exists(SETTINGS_PATH):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(SETTINGS_PATH))
		if parsed is Dictionary:
			master_volume = float(parsed.get("sfx_volume", 0.8))
			bgm_volume    = float(parsed.get("bgm_volume", 0.25))

func save_settings():
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({
		"sfx_volume": master_volume,
		"bgm_volume": bgm_volume,
	}))

func set_sfx_volume(v: float):
	master_volume = clampf(v, 0.0, 1.0)
	save_settings()

func set_bgm_volume(v: float):
	bgm_volume = clampf(v, 0.0, 1.0)
	BGMPlayer.apply_volume(bgm_volume)
	save_settings()

func _connect_signals():
	GameState.money_changed.connect(_on_money_changed)
	GameState.turn_advanced.connect(_on_turn_advanced)
	GameState.game_over.connect(_on_game_over)

func _on_money_changed(_new_amount: float):
	pass  # 버튼 클릭 시 play() 직접 호출로 대신함

func _on_turn_advanced(_turn: int):
	play("month")

func _on_game_over(ending: String):
	if ending == "gangnam_dream" or ending == "stable_success":
		play("success")
	else:
		play("game_over")

# ── 재생 ────────────────────────────────────────
func play(sound_id: String, volume_mod: float = 0.0):
	if not sfx_enabled:
		return
	if not _sounds.has(sound_id):
		return
	for p in _pool:
		if not p.playing:
			p.stream = _sounds[sound_id]
			p.volume_db = _vol_db() + volume_mod
			p.play()
			return

func _vol_db() -> float:
	# 0.0~1.0 → -40dB~0dB (log scale 근사)
	if master_volume <= 0.0:
		return -80.0
	return lerp(-20.0, 0.0, master_volume)

# ── 사운드 생성 ─────────────────────────────────
func _generate_sounds():
	# UI
	_sounds["click"]       = _tone(880, 0.04, [1.0, 0.0])
	_sounds["close"]       = _tone(440, 0.06, [0.8, 0.0])
	_sounds["open_modal"]  = _tone(660, 0.08, [0.3, 1.0, 0.0])

	# 월 전환
	_sounds["month"]       = _chord([523, 659, 784], 0.22, [0.0, 0.7, 1.0, 0.0])

	# 돈
	_sounds["money_gain"]  = _chord([659, 784, 988], 0.18, [0.0, 0.8, 1.0, 0.0])
	_sounds["money_loss"]  = _tone(220, 0.25, [0.4, 1.0, 0.8, 0.0])
	_sounds["money_big"]   = _chord([523, 659, 784, 1047], 0.35, [0.0, 0.5, 1.0, 0.5, 0.0])

	# 스탯
	_sounds["stat_up"]     = _chord([523, 659], 0.15, [0.0, 1.0, 0.0])
	_sounds["stat_down"]   = _tone(330, 0.18, [0.5, 1.0, 0.0])

	# 이벤트
	_sounds["event_new"]   = _chord([440, 550], 0.12, [0.0, 1.0, 0.5, 0.0])
	_sounds["choice_made"] = _tone(600, 0.08, [0.5, 1.0, 0.0])

	# 이사
	_sounds["housing_up"]  = _chord([523, 659, 784, 1047], 0.28, [0.0, 0.4, 1.0, 0.6, 0.0])

	# 게임오버 / 성공
	_sounds["game_over"]   = _tone(110, 0.6, [0.0, 0.5, 1.0, 0.8, 0.5, 0.0])
	_sounds["success"]     = _chord([523, 659, 784, 1047], 0.5, [0.0, 0.3, 1.0, 0.8, 0.4, 0.0])

const _SAMPLE_RATE = 22050

func _tone(freq: float, duration: float, envelope: Array) -> AudioStreamWAV:
	return _chord([freq], duration, envelope)

func _chord(freqs: Array, duration: float, envelope: Array) -> AudioStreamWAV:
	var samples = int(_SAMPLE_RATE * duration)
	var data = PackedByteArray()
	data.resize(samples * 2)
	var env_count = envelope.size()
	for i in range(samples):
		var t = float(i) / float(samples)
		# 엔벨로프 선형 보간
		var seg = t * (env_count - 1)
		var seg_i = int(seg)
		var seg_f = seg - float(seg_i)
		var amp = lerp(float(envelope[seg_i]), float(envelope[min(seg_i + 1, env_count - 1)]), seg_f)
		# 여러 주파수 합산
		var s = 0.0
		for freq in freqs:
			s += sin(2.0 * PI * float(freq) * float(i) / float(_SAMPLE_RATE))
		s /= float(freqs.size())
		var sample = clamp(int(s * amp * 28000), -32768, 32767)
		data[i * 2]     = sample & 0xFF
		data[i * 2 + 1] = (sample >> 8) & 0xFF
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = _SAMPLE_RATE
	wav.stereo = false
	wav.data = data
	return wav
