class_name ModLoader
extends RefCounted
## Data-only community layer. It discovers translation JSON and exact-path
## image/audio replacements; scripts are never scanned or loaded.

const LANGUAGE_ROOT := "user://lang"
const ASSET_ROOT := "user://mods/assets"
const BUILTIN_ASSET_PREFIX := "res://assets/"
const IMAGE_EXTENSIONS := ["png", "jpg", "jpeg", "webp", "svg"]
const AUDIO_EXTENSIONS := ["wav", "ogg", "mp3"]

static var _language_root_override: String = ""
static var _asset_root_override: String = ""
static var _texture_cache: Dictionary = {}
static var _audio_cache: Dictionary = {}

static func configure_test_roots(language_root: String, asset_root: String) -> void:
	_language_root_override = language_root
	_asset_root_override = asset_root
	clear_caches()

static func reset_test_roots() -> void:
	_language_root_override = ""
	_asset_root_override = ""
	clear_caches()

static func clear_caches() -> void:
	_texture_cache.clear()
	_audio_cache.clear()

static func language_root() -> String:
	return _language_root_override if not _language_root_override.is_empty() else LANGUAGE_ROOT

static func asset_root() -> String:
	return _asset_root_override if not _asset_root_override.is_empty() else ASSET_ROOT

static func discover_language_codes() -> Array[String]:
	var codes: Array[String] = []
	var root := language_root()
	var directory := _open_directory(root)
	if directory == null:
		return codes
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		if directory.current_is_dir() and _is_safe_language_code(entry) and _language_pack_has_content(entry):
			codes.append(entry)
		entry = directory.get_next()
	directory.list_dir_end()
	codes.sort()
	return codes

static func has_language_pack(code: String) -> bool:
	return code in discover_language_codes()

static func language_pack_root(code: String) -> String:
	if not _is_safe_language_code(code):
		return ""
	return language_root().path_join(code)

static func language_events_dir(code: String) -> String:
	var root := language_pack_root(code)
	return "" if root.is_empty() else root.path_join("events_%s" % code)

static func language_endings_path(code: String) -> String:
	var root := language_pack_root(code)
	return "" if root.is_empty() else root.path_join("endings_%s.json" % code)

static func language_ui_path(code: String) -> String:
	var root := language_pack_root(code)
	return "" if root.is_empty() else root.path_join("ui_%s.json" % code)

static func language_pack_info(code: String) -> Dictionary:
	var result := {
		"code": code,
		"name": code,
		"native_name": code,
		"author": "",
		"version": "",
	}
	var root := language_pack_root(code)
	if root.is_empty():
		return result
	var metadata_path := root.path_join("pack.json")
	if not FileAccess.file_exists(metadata_path):
		return result
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(metadata_path))
	if not parsed is Dictionary:
		return result
	for key in ["name", "native_name", "author", "version"]:
		var value := str((parsed as Dictionary).get(key, "")).strip_edges()
		if not value.is_empty():
			result[key] = value
	return result

static func resolve_asset_override(canonical_path: String) -> String:
	if not canonical_path.begins_with(BUILTIN_ASSET_PREFIX):
		return canonical_path
	var relative := canonical_path.trim_prefix(BUILTIN_ASSET_PREFIX)
	if relative.is_empty() or relative.contains("..") or relative.begins_with("/") or relative.contains("\\"):
		return canonical_path
	var candidate := asset_root().path_join(relative)
	if FileAccess.file_exists(candidate) and _is_allowed_asset_extension(candidate.get_extension()):
		return candidate
	return canonical_path

static func has_asset_override(canonical_path: String) -> bool:
	return resolve_asset_override(canonical_path) != canonical_path

static func has_any_asset_overrides() -> bool:
	return _directory_has_supported_asset(asset_root(), 0)

static func image_exists(canonical_path: String) -> bool:
	if canonical_path.is_empty() or not canonical_path.get_extension().to_lower() in IMAGE_EXTENSIONS:
		return false
	return has_asset_override(canonical_path) or ResourceLoader.exists(canonical_path)

static func audio_exists(canonical_path: String) -> bool:
	if canonical_path.is_empty() or not canonical_path.get_extension().to_lower() in AUDIO_EXTENSIONS:
		return false
	return has_asset_override(canonical_path) or ResourceLoader.exists(canonical_path)

static func load_texture(canonical_path: String) -> Texture2D:
	if canonical_path.is_empty():
		return null
	var resolved := resolve_asset_override(canonical_path)
	if _texture_cache.has(resolved):
		return _texture_cache[resolved] as Texture2D
	var texture: Texture2D = null
	if resolved != canonical_path:
		var image := Image.new()
		var error := image.load(ProjectSettings.globalize_path(resolved))
		if error == OK and not image.is_empty():
			texture = ImageTexture.create_from_image(image)
		else:
			push_warning("Ignoring invalid image mod; using built-in asset: %s" % resolved)
	if texture == null and ResourceLoader.exists(canonical_path):
		var resource := load(canonical_path)
		if resource is Texture2D:
			texture = resource as Texture2D
	_texture_cache[resolved] = texture
	return texture

static func load_audio(canonical_path: String, looped: bool = false) -> AudioStream:
	if canonical_path.is_empty():
		return null
	var resolved := resolve_asset_override(canonical_path)
	var cache_key := "%s|loop=%s" % [resolved, looped]
	if _audio_cache.has(cache_key):
		return _audio_cache[cache_key] as AudioStream
	var stream: AudioStream = null
	if resolved != canonical_path:
		var global_path := ProjectSettings.globalize_path(resolved)
		match resolved.get_extension().to_lower():
			"wav":
				stream = AudioStreamWAV.load_from_file(global_path)
			"ogg":
				stream = AudioStreamOggVorbis.load_from_file(global_path)
			"mp3":
				stream = AudioStreamMP3.load_from_file(global_path)
		if stream == null:
			push_warning("Ignoring invalid audio mod; using built-in asset: %s" % resolved)
	if stream == null and ResourceLoader.exists(canonical_path):
		stream = load(canonical_path) as AudioStream
	stream = _configure_loop(stream, looped)
	_audio_cache[cache_key] = stream
	return stream

static func is_active(language_code: String = "") -> bool:
	return (not language_code.is_empty() and has_language_pack(language_code)) or has_any_asset_overrides()

static func active_mod_labels(language_code: String = "") -> Array[String]:
	var labels: Array[String] = []
	if not language_code.is_empty() and has_language_pack(language_code):
		labels.append("lang:%s" % language_code)
	if has_any_asset_overrides():
		labels.append("assets")
	return labels

static func _language_pack_has_content(code: String) -> bool:
	var event_dir := language_events_dir(code)
	if not event_dir.is_empty() and _open_directory(event_dir) != null:
		return true
	var endings_path := language_endings_path(code)
	var ui_path := language_ui_path(code)
	return (
		(not endings_path.is_empty() and FileAccess.file_exists(endings_path))
		or (not ui_path.is_empty() and FileAccess.file_exists(ui_path))
	)

static func _is_safe_language_code(code: String) -> bool:
	if code.length() < 2 or code.length() > 24:
		return false
	for i in range(code.length()):
		var cp := code.unicode_at(i)
		var allowed := (
			(cp >= 48 and cp <= 57)
			or (cp >= 65 and cp <= 90)
			or (cp >= 97 and cp <= 122)
			or cp == 45
		)
		if not allowed:
			return false
	return true

static func _is_allowed_asset_extension(extension: String) -> bool:
	var normalized := extension.to_lower()
	return normalized in IMAGE_EXTENSIONS or normalized in AUDIO_EXTENSIONS

static func _directory_has_supported_asset(path: String, depth: int) -> bool:
	if depth > 12:
		return false
	var directory := _open_directory(path)
	if directory == null:
		return false
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		if entry.begins_with("."):
			entry = directory.get_next()
			continue
		var child := path.path_join(entry)
		if directory.current_is_dir():
			if _directory_has_supported_asset(child, depth + 1):
				directory.list_dir_end()
				return true
		elif _is_allowed_asset_extension(entry.get_extension()):
			directory.list_dir_end()
			return true
		entry = directory.get_next()
	directory.list_dir_end()
	return false

static func _open_directory(path: String) -> DirAccess:
	var resolved := ProjectSettings.globalize_path(path) if path.begins_with("user://") else path
	return DirAccess.open(resolved)

static func _configure_loop(stream: AudioStream, looped: bool) -> AudioStream:
	if stream == null or not looped:
		return stream
	var result := stream.duplicate() as AudioStream
	if result is AudioStreamWAV:
		var wav := result as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = int(round(wav.get_length() * float(wav.mix_rate)))
	elif result is AudioStreamOggVorbis:
		(result as AudioStreamOggVorbis).loop = true
	elif result is AudioStreamMP3:
		(result as AudioStreamMP3).loop = true
	return result
