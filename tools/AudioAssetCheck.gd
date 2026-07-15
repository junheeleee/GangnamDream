extends Node
## AudioAssetCheck — verifies BGM/SFX files referenced by audio managers.
##
## Run:
##   /Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot --headless res://tools/AudioAssetCheck.tscn

var _failures: Array[String] = []

func _ready() -> void:
	_check_bgm()
	_check_optional_moral_theme_pack()
	_check_ambience()
	_check_human_ambience()
	_check_sfx()
	_check_used_sfx_keys()
	_check_ending_audio_tones()
	if _failures.is_empty():
		print("AUDIO_ASSET_CHECK_OK bgm=%d ambience=%d sfx=%d" % [
			BGMPlayer.TRACKS.size(),
			BGMPlayer.AMBIENCE_TRACKS.size() + BGMPlayer.HUMAN_AMBIENCE_TRACKS.size(),
			AudioManager._SFX_FILES.size()])
		get_tree().quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		get_tree().quit(1)

func _check_bgm() -> void:
	for key in BGMPlayer.TRACKS:
		_check_audio_stream("BGM:%s" % key, str(BGMPlayer.TRACKS[key]))

func _check_optional_moral_theme_pack() -> void:
	var present: Array[String] = []
	for key_value in BGMPlayer.MORAL_THEME_TRACKS.keys():
		var key: String = str(key_value)
		var path: String = str(BGMPlayer.MORAL_THEME_TRACKS.get(key, ""))
		if ResourceLoader.exists(path):
			present.append(key)
	if present.is_empty():
		return
	if present.size() != BGMPlayer.MORAL_THEME_TRACKS.size():
		_failures.append("Moral theme pack must be all-or-none; found %d/%d tracks" % [
			present.size(), BGMPlayer.MORAL_THEME_TRACKS.size()])
		return
	for key_value in BGMPlayer.MORAL_THEME_TRACKS.keys():
		var key: String = str(key_value)
		_check_audio_stream("MORAL_BGM:%s" % key, str(BGMPlayer.MORAL_THEME_TRACKS.get(key, "")))

func _check_ambience() -> void:
	for key in BGMPlayer.AMBIENCE_TRACKS:
		_check_audio_stream("AMBIENCE:%s" % key, str(BGMPlayer.AMBIENCE_TRACKS[key]))

func _check_human_ambience() -> void:
	for key in BGMPlayer.HUMAN_AMBIENCE_TRACKS:
		_check_audio_stream(
			"HUMAN_AMBIENCE:%s" % key, str(BGMPlayer.HUMAN_AMBIENCE_TRACKS[key]))
	for world_key in BGMPlayer.HUMAN_AMBIENCE_BY_WORLD:
		var human_key := str(BGMPlayer.HUMAN_AMBIENCE_BY_WORLD[world_key])
		if not BGMPlayer.AMBIENCE_TRACKS.has(world_key):
			_failures.append("Human ambience world key is not a room tone: %s" % world_key)
		if not BGMPlayer.HUMAN_AMBIENCE_TRACKS.has(human_key):
			_failures.append("Human ambience profile is missing: %s -> %s" % [world_key, human_key])

func _check_sfx() -> void:
	for key in AudioManager._SFX_FILES:
		_check_audio_stream("SFX:%s" % key, str(AudioManager._SFX_FILES[key]))

func _check_used_sfx_keys() -> void:
	var used := {}
	var re := RegEx.new()
	re.compile("AudioManager\\.play(?:_delayed|_varied|_delayed_varied)?\\(\\\"([a-z_]+)\\\"")
	for dir in ["res://autoloads", "res://scenes", "res://systems", "res://ui_components", "res://tools"]:
		_scan_audio_calls(dir, re, used)
	for key in used.keys():
		if not AudioManager._SFX_FILES.has(key):
			_failures.append("AudioManager.play key is used but not mapped: %s" % key)

func _check_ending_audio_tones() -> void:
	var expected := {
		"empty_house": "dark",
		"jaehyuk_way": "dark",
		"lonely_rich": "dark",
		"bankruptcy": "dark",
		"debt_spiral": "dark",
		"burnout": "dark",
		"mental_break": "dark",
		"crypto_ghost": "dark",
		"gangnam_dream": "legend",
		"gangnam_dream_white": "legend",
		"full_circle": "legend",
		"stable_success": "hopeful",
		"late_call": "hopeful",
		"gambling_recovery": "hopeful",
		"sangchul_reckoning": "hopeful",
		"career_burnout": "hopeful",
	}
	for ending_id in expected.keys():
		var actual := AudioManager.ending_audio_tone(str(ending_id))
		if actual != str(expected[ending_id]):
			_failures.append("Ending audio tone mismatch: %s expected %s got %s" % [
				ending_id, expected[ending_id], actual])

	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://content/endings.json"))
	if not (parsed is Array):
		_failures.append("Cannot parse endings.json for ending audio tone check")
		return
	for ending in parsed:
		if not (ending is Dictionary):
			continue
		var ending_id := str(ending.get("id", ""))
		if ending_id == "":
			continue
		var bgm_key := AudioManager.ending_bgm_key(ending_id)
		var stinger_key := AudioManager.ending_stinger_key(ending_id)
		if not BGMPlayer.TRACKS.has(bgm_key):
			_failures.append("Ending %s maps to missing BGM key: %s" % [ending_id, bgm_key])
		if not AudioManager._SFX_FILES.has(stinger_key):
			_failures.append("Ending %s maps to missing stinger key: %s" % [ending_id, stinger_key])

func _scan_audio_calls(dir_path: String, re: RegEx, used: Dictionary) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	dir.list_dir_begin()
	while true:
		var name := dir.get_next()
		if name == "":
			break
		if name.begins_with("."):
			continue
		var path := "%s/%s" % [dir_path, name]
		if dir.current_is_dir():
			_scan_audio_calls(path, re, used)
		elif name.ends_with(".gd"):
			var text := FileAccess.get_file_as_string(path)
			for result in re.search_all(text):
				used[result.get_string(1)] = true
	dir.list_dir_end()

func _check_audio_stream(label: String, path: String) -> void:
	if path == "":
		_failures.append("%s has empty path" % label)
		return
	if not ResourceLoader.exists(path):
		_failures.append("%s missing: %s" % [label, path])
		return
	var stream := load(path)
	if stream == null or not (stream is AudioStream):
		_failures.append("%s is not an AudioStream: %s" % [label, path])
