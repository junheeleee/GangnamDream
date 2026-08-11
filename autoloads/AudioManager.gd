extends Node

var master_volume: float = 0.8
var bgm_volume: float    = 0.25
var sfx_enabled: bool    = true

var _pool: Array[AudioStreamPlayer] = []
const _POOL_SIZE = 12
var _sounds: Dictionary = {}
var _last_sfx_ms: Dictionary = {}
var _last_ending_stinger_id: String = ""
var _last_ending_stinger_ms: int = 0
var _last_event_cue_id: String = ""
var _last_event_cue_ms: int = 0
var _last_direction_sting_token: String = ""
var _last_direction_sting_ms: int = 0
var _story_audio_generation: int = 0
var _story_audio_seen: Dictionary = {}
var _pitch_rng := RandomNumberGenerator.new()
var _vibration_stop_serial: int = 0

# Scene code requests semantic profiles instead of owning motor strengths or timing.
# Vector3 stores weak motor, strong motor, and duration seconds in that order.
const HAPTIC_PROFILES: Dictionary = {
	&"commit_choice": Vector3(0.035, 0.070, 0.055),
	&"commit_action": Vector3(0.045, 0.110, 0.065),
	&"commit_wager": Vector3(0.070, 0.150, 0.080),
	&"danger_impact": Vector3(0.220, 0.200, 0.130),
	&"physical_card": Vector3(0.050, 0.120, 0.075),
	&"physical_dice_roll": Vector3(0.100, 0.220, 0.120),
	&"physical_reel_spin": Vector3(0.080, 0.180, 0.100),
	&"physical_reel_stop": Vector3(0.070, 0.160, 0.055),
	&"result_jackpot": Vector3(0.350, 0.900, 0.240),
	&"result_win": Vector3(0.180, 0.450, 0.140),
	&"result_loss": Vector3(0.320, 0.250, 0.180),
	&"result_push": Vector3(0.080, 0.080, 0.080),
}

const _SFX_COOLDOWN_MS = {
	"click": 45,
	"close": 90,
	"open_modal": 90,
	"tab_open": 70,
	"result_ledger": 120,
	"result_human": 120,
	"casino_coin": 24,
	"card_shuffle": 500,
	"card_deal": 24,
	"card_flip": 45,
	"chip_place": 35,
	"chip_collect": 250,
	"dice_cup_shake": 500,
	"dice_roll": 35,
	"roulette_wheel": 1000,
	"roulette_ball": 35,
	"roulette_land": 350,
	"slot_start": 500,
	"slot_reel_stop": 70,
	"big_wheel_tick": 25,
	"race_gate": 1000,
	"horse_gallop": 40,
	"race_crowd_rise": 2500,
	"race_finish": 1000,
	"civil_defense_siren": 5000,
	"monsoon_rain": 1800,
	"wedding_applause": 5000,
	"wedding_cheer": 5000,
	"distant_fireworks": 4500,
	"phone_vibrate": 650,
	"phone_notification": 650,
	"paper_handle": 350,
	"document_stamp": 700,
	"door_latch": 500,
	"footsteps_hall": 1200,
	"register_scan": 350,
	"keyboard_short": 650,
	"cup_set": 450,
	"pen_write": 650,
	"cloth_shift": 500,
	"page_turn": 650,
	"bicycle_impact": 1200,
	"traffic_pass": 1200,
	"kettle_pour": 1800,
	"bus_arrival": 1800,
	"queue_chime": 1200,
}

# 파일별 체감 라우드니스가 다른 큰 소리만 보정한다. 공용 UI음은 각 래퍼의
# 기존 감쇄를 유지해 클릭 촉감까지 함께 죽이지 않는다.
const _SFX_MIX_TRIM_DB = {
	"game_over": -4.0,
	"casino_lose": -2.0,
	"casino_spin": -2.0,
	"casino_jackpot": -4.0,
	"civil_defense_siren": -3.0,
	"ending_stinger_good": -7.0,
	"ending_stinger_bad": -7.0,
	"ending_stinger_legend": -9.0,
	"wedding_applause": -2.0,
	"wedding_cheer": -4.0,
	"distant_fireworks": -3.0,
	"publisher_sting": -4.0,
	"card_shuffle": 0.0,
	"card_deal": 2.0,
	"card_flip": 2.0,
	"chip_place": -1.0,
	"chip_collect": 1.0,
	"dice_cup_shake": 0.0,
	"dice_roll": 1.0,
	"roulette_wheel": 2.0,
	"roulette_ball": 2.0,
	"roulette_land": 0.0,
	"slot_start": 1.0,
	"slot_reel_stop": 0.0,
	"big_wheel_tick": -1.0,
	"race_gate": -2.0,
	"horse_gallop": -4.0,
	"race_crowd_rise": -2.0,
	"race_finish": -2.0,
	"phone_vibrate": -2.0,
	"phone_notification": -3.0,
	"paper_handle": -1.0,
	"document_stamp": -3.0,
	"door_latch": -2.0,
	"footsteps_hall": -2.0,
	"register_scan": -4.0,
	"keyboard_short": -2.0,
	"cup_set": -3.0,
	"pen_write": -3.0,
	"cloth_shift": -4.0,
	"page_turn": -3.0,
	"bicycle_impact": -4.0,
	"traffic_pass": -2.0,
	"kettle_pour": -2.0,
	"bus_arrival": -4.0,
	"queue_chime": 0.0,
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
	"result_ledger": "res://assets/audio/sfx_result_ledger.wav",
	"result_human":  "res://assets/audio/sfx_result_human.wav",
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
	"wedding_applause": "res://assets/audio/sfx_wedding_applause.wav",
	"wedding_cheer": "res://assets/audio/sfx_wedding_cheer.wav",
	"distant_fireworks": "res://assets/audio/sfx_distant_fireworks.wav",
	"publisher_sting": "res://assets/audio/sfx_publisher_sting.wav",
	# 카드·칩·기계 단계별 물리음. 공용 카지노 전자음은 결과 피드백에만 남긴다.
	"card_shuffle": "res://assets/audio/sfx_card_shuffle.wav",
	"card_deal": "res://assets/audio/sfx_card_deal.wav",
	"card_flip": "res://assets/audio/sfx_card_flip.wav",
	"chip_place": "res://assets/audio/sfx_chip_place.wav",
	"chip_collect": "res://assets/audio/sfx_chip_collect.wav",
	"dice_cup_shake": "res://assets/audio/sfx_dice_cup_shake.wav",
	"dice_roll": "res://assets/audio/sfx_dice_roll.wav",
	"roulette_wheel": "res://assets/audio/sfx_roulette_wheel.wav",
	"roulette_ball": "res://assets/audio/sfx_roulette_ball.wav",
	"roulette_land": "res://assets/audio/sfx_roulette_land.wav",
	"slot_start": "res://assets/audio/sfx_slot_start.wav",
	"slot_reel_stop": "res://assets/audio/sfx_slot_reel_stop.wav",
	"big_wheel_tick": "res://assets/audio/sfx_big_wheel_tick.wav",
	"race_gate": "res://assets/audio/sfx_race_gate.wav",
	"horse_gallop": "res://assets/audio/sfx_horse_gallop.wav",
	"race_crowd_rise": "res://assets/audio/sfx_race_crowd_rise.wav",
	"race_finish": "res://assets/audio/sfx_race_finish.wav",
	# 장면 물리음. 텍스트의 의미 문단에만 매니페스트로 배치한다.
	"phone_vibrate": "res://assets/audio/sfx_phone_vibrate.wav",
	"phone_notification": "res://assets/audio/sfx_phone_notification.wav",
	"paper_handle": "res://assets/audio/sfx_paper_handle.wav",
	"document_stamp": "res://assets/audio/sfx_document_stamp.wav",
	"door_latch": "res://assets/audio/sfx_door_latch.wav",
	"footsteps_hall": "res://assets/audio/sfx_footsteps_hall.wav",
	"register_scan": "res://assets/audio/sfx_register_scan.wav",
	"keyboard_short": "res://assets/audio/sfx_keyboard_short.wav",
	"cup_set": "res://assets/audio/sfx_cup_set.wav",
	"pen_write": "res://assets/audio/sfx_pen_write.wav",
	"cloth_shift": "res://assets/audio/sfx_cloth_shift.wav",
	"page_turn": "res://assets/audio/sfx_page_turn.wav",
	"bicycle_impact": "res://assets/audio/sfx_bicycle_impact.wav",
	"traffic_pass": "res://assets/audio/sfx_traffic_pass.wav",
	"kettle_pour": "res://assets/audio/sfx_kettle_pour.wav",
	"bus_arrival": "res://assets/audio/sfx_bus_arrival.wav",
	"queue_chime": "res://assets/audio/sfx_queue_chime.wav",
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
	# Pitch variation is presentation-only. Keep it off the global stream used by
	# jobs, events, and the economy so input frequency cannot change a run.
	_pitch_rng.randomize()
	load_settings()
	for i in range(_POOL_SIZE):
		var p = AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_pool.append(p)
	_load_sounds()
	_connect_signals()

func _load_sounds():
	# 출시 오디오는 녹음/실악기 샘플 파일만 사용한다. 누락 시 합성하지 않는다.
	_sounds.clear()
	for key in _SFX_FILES:
		var path: String = str(_SFX_FILES[key])
		if not ModLoader.audio_exists(path):
			push_error("Missing recorded/sample-based SFX '%s': %s" % [key, path])
			continue
		var stream := ModLoader.load_audio(path)
		if stream == null:
			push_error("Failed to load recorded/sample-based SFX '%s': %s" % [key, path])
			continue
		_sounds[key] = stream

func load_settings():
	master_volume = clampf(float(SaveManager.get_setting("sfx_volume", 0.8)), 0.0, 1.0)
	bgm_volume = clampf(float(SaveManager.get_setting("bgm_volume", 0.25)), 0.0, 1.0)

func save_settings():
	# SaveManager owns the shared settings dictionary. Writing the JSON directly here
	# would erase accessibility and vibration preferences saved by other systems.
	SaveManager.set_setting("sfx_volume", master_volume)
	SaveManager.set_setting("bgm_volume", bgm_volume)

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
	# `turn_advanced`는 주마다 온다. 결산음은 실제 달이 바뀐 첫 주에만 울린다.
	if GameState.week_of_month == 1:
		play("month", -3.0)

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
	_play_from_pool(sound_id, volume_mod, 1.0)

func play_varied(sound_id: String, volume_mod: float = 0.0,
		pitch_min: float = 0.94, pitch_max: float = 1.06) -> void:
	if not sfx_enabled or not _sounds.has(sound_id):
		return
	if _is_sfx_throttled(sound_id):
		return
	var low := minf(pitch_min, pitch_max)
	var high := maxf(pitch_min, pitch_max)
	_play_from_pool(sound_id, volume_mod, _pitch_rng.randf_range(low, high))

func _play_from_pool(sound_id: String, volume_mod: float, pitch: float) -> void:
	volume_mod += sfx_mix_trim_db(sound_id)
	for p in _pool:
		if not p.playing:
			p.stream    = _sounds[sound_id]
			p.volume_db = _vol_db() + volume_mod
			p.pitch_scale = clampf(pitch, 0.5, 2.0)
			p.play()
			return

func has_sound(sound_id: String) -> bool:
	return _sounds.has(sound_id)

func sfx_mix_trim_db(sound_id: String) -> float:
	return float(_SFX_MIX_TRIM_DB.get(sound_id, 0.0))

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

func begin_story_audio_event(_event_id: String) -> void:
	_story_audio_generation += 1
	_story_audio_seen.clear()

func play_scene_paragraph_cues(event_id: String, cg_id: String, paragraph_index: int) -> void:
	var contract := BGMPlayer.scene_audio_contract(event_id, cg_id)
	var paragraph_cues: Variant = contract.get("paragraph_cues", null)
	if not (paragraph_cues is Dictionary):
		return
	var raw_cues: Variant = paragraph_cues.get(str(paragraph_index), null)
	_play_story_cue_list(
		event_id, cg_id, "description:%d" % paragraph_index, raw_cues)

func play_scene_result_paragraph_cues(
		event_id: String,
		cg_id: String,
		choice_index: int,
		paragraph_index: int) -> void:
	var contract := BGMPlayer.scene_audio_contract(event_id, cg_id)
	var result_cues: Variant = contract.get("result_paragraph_cues", null)
	if not (result_cues is Dictionary):
		return
	var choice_cues: Variant = result_cues.get(str(choice_index), null)
	if not (choice_cues is Dictionary):
		return
	var raw_cues: Variant = choice_cues.get(str(paragraph_index), null)
	_play_story_cue_list(
		event_id, cg_id, "result:%d:%d" % [choice_index, paragraph_index], raw_cues)

func _play_story_cue_list(
		event_id: String,
		cg_id: String,
		scope: String,
		raw_cues: Variant) -> void:
	if not (raw_cues is Array):
		return
	for cue_index in range(raw_cues.size()):
		var raw_cue: Variant = raw_cues[cue_index]
		if not (raw_cue is Dictionary):
			continue
		var sound_id := str(raw_cue.get("sfx", ""))
		if sound_id.is_empty() or not _sounds.has(sound_id):
			continue
		var cue_token := "%s:%s:%s:%d:%s" % [
			event_id, cg_id, scope, cue_index, sound_id]
		if _story_audio_seen.has(cue_token):
			continue
		_story_audio_seen[cue_token] = true
		var delay: float = maxf(0.0, float(raw_cue.get("delay", 0.0)))
		var volume_mod: float = float(raw_cue.get("volume_db", 0.0))
		_play_story_cue(sound_id, delay, volume_mod, _story_audio_generation)

func _play_story_cue(sound_id: String, delay: float, volume_mod: float, generation: int) -> void:
	if delay <= 0.0:
		play(sound_id, volume_mod)
		return
	get_tree().create_timer(delay).timeout.connect(func():
		if generation == _story_audio_generation:
			play(sound_id, volume_mod))

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

func play_ui_close(volume_mod: float = -8.0) -> void:
	play("close", volume_mod)

func play_ui_open(volume_mod: float = -5.0) -> void:
	play("open_modal", volume_mod)

func play_delayed(sound_id: String, delay: float, volume_mod: float = 0.0) -> void:
	if delay <= 0.0:
		play(sound_id, volume_mod)
		return
	get_tree().create_timer(delay).timeout.connect(func():
		play(sound_id, volume_mod))

func play_delayed_varied(sound_id: String, delay: float, volume_mod: float = 0.0,
		pitch_min: float = 0.94, pitch_max: float = 1.06) -> void:
	if delay <= 0.0:
		play_varied(sound_id, volume_mod, pitch_min, pitch_max)
		return
	get_tree().create_timer(delay).timeout.connect(func():
		play_varied(sound_id, volume_mod, pitch_min, pitch_max))

func play_casino_result(net_amount: float, stake: float = 0.0, force_jackpot: bool = false) -> void:
	var stake_abs: float = maxf(absf(stake), 1.0)
	if force_jackpot or net_amount >= maxf(stake_abs * 10.0, 1_000_000.0):
		play("casino_jackpot")
		play_haptic(&"result_jackpot")
	elif net_amount > 0.0:
		play("casino_win")
		play_haptic(&"result_win")
	elif net_amount < 0.0:
		play("casino_lose")
		play_haptic(&"result_loss")
	else:
		play("casino_card", -4.0)
		play_haptic(&"result_push")

func haptic_profile(profile_id: StringName) -> Vector3:
	var profile: Variant = HAPTIC_PROFILES.get(profile_id, Vector3.ZERO)
	return profile if profile is Vector3 else Vector3.ZERO

func play_haptic(profile_id: StringName) -> bool:
	var profile := haptic_profile(profile_id)
	if profile == Vector3.ZERO:
		return false
	return _pulse_gamepad(profile.x, profile.y, profile.z)

func _pulse_gamepad(weak: float, strong: float, duration: float = 0.12) -> bool:
	if duration <= 0.0:
		return false
	if not vibration_enabled():
		return false
	var intensity := vibration_intensity()
	if intensity <= 0.0:
		return false
	var pulsed := false
	for device in Input.get_connected_joypads():
		Input.start_joy_vibration(
			int(device),
			clampf(weak * intensity, 0.0, 1.0),
			clampf(strong * intensity, 0.0, 1.0),
			duration
		)
		pulsed = true
	return pulsed

func stop_gamepad_vibration() -> void:
	_vibration_stop_serial += 1
	for device in Input.get_connected_joypads():
		Input.stop_joy_vibration(int(device))

func set_vibration_enabled(enabled: bool) -> void:
	SaveManager.set_setting("vibration_enabled", enabled)
	if not enabled:
		stop_gamepad_vibration()

func set_vibration_intensity(value: float) -> void:
	var clamped_value := clampf(value, 0.0, 1.0)
	SaveManager.set_setting("vibration_intensity", clamped_value)
	if clamped_value <= 0.0:
		stop_gamepad_vibration()

func vibration_enabled() -> bool:
	return bool(SaveManager.get_setting("vibration_enabled", true))

func vibration_intensity() -> float:
	return clampf(float(SaveManager.get_setting("vibration_intensity", 0.70)), 0.0, 1.0)

func vibration_profile(weak: float, strong: float) -> Vector2:
	if not vibration_enabled():
		return Vector2.ZERO
	var intensity := vibration_intensity()
	return Vector2(
		clampf(weak * intensity, 0.0, 1.0),
		clampf(strong * intensity, 0.0, 1.0))

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
