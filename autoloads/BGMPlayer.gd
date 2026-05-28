extends Node
## 배경음악: AudioStreamWAV 미리 굽기 방식
## SFX와 동일한 원리라 안정적. 4바 루프 (Cm7→Ab→Eb→Bb)
## 게임 시작 시 _ready()에서 한 번 생성 (~0.3s), 이후 무한 루프

var _player: AudioStreamPlayer
var volume: float = 0.25

const SR  := 11025   # Hz — 낮을수록 생성 빠름, 배경음은 충분
const BPM := 80.0

func _ready():
	_player = AudioStreamPlayer.new()
	_player.bus = "Master"
	add_child(_player)
	_player.stream    = _bake()
	_player.volume_db = _db(volume)

func start():
	# AudioManager가 먼저 로드되므로 저장된 bgm_volume 적용
	volume = AudioManager.bgm_volume
	_player.volume_db = _db(volume)
	if not _player.finished.is_connected(_on_bgm_ended):
		_player.finished.connect(_on_bgm_ended)
	_player.play()

func _on_bgm_ended():
	if volume > 0.001:
		_player.play()

func stop():
	_player.stop()

func toggle():
	if _player.playing: stop()
	else: start()

func apply_volume(v: float):
	volume = clampf(v, 0.0, 1.0)
	_player.volume_db = _db(volume)

func _db(v: float) -> float:
	return -80.0 if v < 0.001 else 20.0 * log(v) / log(10.0)

# ── 루프 호환 주파수 스냅 ─────────────────────────
# freq × loop_samples / SR = 정수 → 루프 경계에서 위상 연속 → 클릭 없음
func _snap(f: float, loop_len: int) -> float:
	return round(f * float(loop_len) / float(SR)) * float(SR) / float(loop_len)

# ── WAV 굽기 ─────────────────────────────────────
func _bake() -> AudioStreamWAV:
	var beat := int(round(float(SR) * 60.0 / BPM))  # 한 비트 샘플 수
	var bar  := beat * 4                              # 한 바
	var loop := bar  * 4                              # 4바 루프

	# 루프 호환 주파수
	var C2  := _snap(65.41,  loop)
	var Eb2 := _snap(77.78,  loop)
	var Ab2 := _snap(103.83, loop)
	var Bb2 := _snap(116.54, loop)
	var C3  := _snap(130.81, loop)
	var Eb3 := _snap(155.56, loop)
	var G3  := _snap(196.00, loop)
	var Bb3 := _snap(233.08, loop)
	var Ab3 := _snap(207.65, loop)
	var C4  := _snap(261.63, loop)
	var Eb4 := _snap(311.13, loop)
	var G4  := _snap(392.00, loop)
	var D4  := _snap(293.66, loop)
	var F4  := _snap(349.23, loop)
	var Ab4 := _snap(415.30, loop)

	# 코드 진행 [베이스, 패드×4]
	# Cm7 → Ab → Eb → Bb  (K-pop i–VI–III–VII)
	var prog: Array = [
		[C2,  C3, Eb3, G3,  Bb3],
		[Ab2, Ab3, C4, Eb4, G4 ],
		[Eb2, Eb3, G3, Bb3, Eb4],
		[Bb2, Bb3, D4, F4,  Ab4],
	]

	# 사용되는 고유 주파수 목록 + 위상 누산기
	var freqs: Array = []
	for chord in prog:
		for f in chord:
			if not freqs.has(f):
				freqs.append(f)
	var phases: Array = []
	phases.resize(freqs.size())
	phases.fill(0.0)

	# 바별 인덱스 사전 계산 (내부 루프 O(1) 보장)
	var bar_idx_maps: Array = []
	for chord in prog:
		var bass_fi: int = freqs.find(chord[0])
		var pad_fis: Array = []
		for ci in range(1, chord.size()):
			pad_fis.append(freqs.find(chord[ci]))
		bar_idx_maps.append({"bass": bass_fi, "pads": pad_fis})

	# 샘플 생성
	var buf := PackedByteArray()
	buf.resize(loop * 2)

	for i in range(loop):
		var bi   := i / bar
		var bpos := float(i % bar) / float(bar)  # 0..1

		# 엔벨로프
		var pad_env  := smoothstep(0.0, 0.05, bpos) * smoothstep(1.0, 0.92, bpos)
		var bass_env := smoothstep(0.0, 0.01, bpos) * smoothstep(0.45, 0.12, bpos)

		# 위상 전체 업데이트 (연속성 유지)
		for fi in range(freqs.size()):
			var ph: float = phases[fi] + TAU * freqs[fi] / float(SR)
			if ph >= TAU:
				ph -= TAU
			phases[fi] = ph

		# 이 바의 믹스
		var bmap: Dictionary = bar_idx_maps[bi % 4]
		var s := 0.0
		s += sin(phases[bmap["bass"]]) * bass_env * 0.24
		for fi in bmap["pads"]:
			s += sin(phases[fi]) * pad_env * 0.068

		s = clamp(s, -1.0, 1.0)
		var samp := int(s * 28000)
		buf[i * 2]     = samp & 0xFF
		buf[i * 2 + 1] = (samp >> 8) & 0xFF

	var wav := AudioStreamWAV.new()
	wav.format     = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate   = SR
	wav.stereo     = false
	wav.data       = buf
	wav.loop_mode  = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end   = loop
	return wav
