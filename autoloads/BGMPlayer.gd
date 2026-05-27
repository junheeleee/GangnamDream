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

		# 베이스: 사인 + 삼각파 혼합 (삼각파 = 더 따뜻한 하모닉)
		var bp := phases[bmap["bass"]]
		var bass_sin := sin(bp)
		var bass_tri := (2.0 / PI) * asin(sin(bp))          # triangle wave
		s += (bass_sin * 0.6 + bass_tri * 0.4) * bass_env * 0.22

		# 패드: 사인 + 미세 디튜닝(±0.3%) → 자연스러운 코러스 감
		var pad_count := bmap["pads"].size()
		for pi2 in range(pad_count):
			var fi2: int = bmap["pads"][pi2]
			var detune_factor := 1.0 + (float(pi2 % 2) * 2.0 - 1.0) * 0.003
			var dp := phases[fi2] * detune_factor
			var pad_sin := sin(dp)
			var pad_tri := (2.0 / PI) * asin(clamp(sin(dp), -1.0, 1.0))
			s += (pad_sin * 0.7 + pad_tri * 0.3) * pad_env * 0.058

		# 하이햇: 8분음표 (beat의 절반) — 화이트노이즈 버스트로 리듬감
		var hihat_phase := float(i % (beat / 2)) / float(beat / 2)
		var hihat_env   := smoothstep(0.0, 0.01, hihat_phase) * smoothstep(1.0, 0.85, hihat_phase)
		# 결정론적 노이즈 (seed 기반, 매 런 동일)
		var noise_val := sin(float(i) * 127.1 + float(i * i) * 0.00317) * sin(float(i) * 311.7)
		s += noise_val * hihat_env * 0.018

		# 소프트 클리핑 (tanh 근사) — 따뜻한 아날로그 왜곡
		s = s / (1.0 + abs(s) * 0.6)

		s = clamp(s, -1.0, 1.0)
		var samp := int(s * 26000)
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
