extends Node
## AudioAssetCheck — verifies BGM/SFX files referenced by audio managers.
##
## Run:
##   /Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot --headless res://tools/AudioAssetCheck.tscn

var _failures: Array[String] = []

func _ready() -> void:
	_check_bgm()
	_check_ambience()
	_check_sfx()
	_check_used_sfx_keys()
	if _failures.is_empty():
		print("AUDIO_ASSET_CHECK_OK bgm=%d ambience=%d sfx=%d" % [
			BGMPlayer.TRACKS.size(), BGMPlayer.AMBIENCE_TRACKS.size(), AudioManager._SFX_FILES.size()])
		get_tree().quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		get_tree().quit(1)

func _check_bgm() -> void:
	for key in BGMPlayer.TRACKS:
		_check_audio_stream("BGM:%s" % key, str(BGMPlayer.TRACKS[key]))

func _check_ambience() -> void:
	for key in BGMPlayer.AMBIENCE_TRACKS:
		_check_audio_stream("AMBIENCE:%s" % key, str(BGMPlayer.AMBIENCE_TRACKS[key]))

func _check_sfx() -> void:
	for key in AudioManager._SFX_FILES:
		_check_audio_stream("SFX:%s" % key, str(AudioManager._SFX_FILES[key]))

func _check_used_sfx_keys() -> void:
	var used := {}
	var re := RegEx.new()
	re.compile("AudioManager\\.play\\(\\\"([a-z_]+)\\\"")
	for dir in ["res://autoloads", "res://scenes", "res://systems", "res://ui_components", "res://tools"]:
		_scan_audio_calls(dir, re, used)
	for key in used.keys():
		if not AudioManager._SFX_FILES.has(key):
			_failures.append("AudioManager.play key is used but not mapped: %s" % key)

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
