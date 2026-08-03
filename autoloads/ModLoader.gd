class_name ModLoader
extends RefCounted
## Data-only community layer. It discovers translation JSON, exact-path
## image/audio replacements, random event packs, balance presets, and value-only
## moral palettes. Scripts are never scanned or loaded.

const BUILD_FLAVOR := preload("res://systems/BuildFlavor.gd")
const LANGUAGE_ROOT := "user://lang"
const MOD_ROOT := "user://mods"
const ASSET_ROOT := MOD_ROOT + "/assets"
const SETTINGS_PATH := BUILD_FLAVOR.RETAIL_SETTINGS_PATH
const BUILTIN_THEME_ROOT := "res://content/themes"
const BUILTIN_ASSET_PREFIX := "res://assets/"
const IMAGE_EXTENSIONS := ["png", "jpg", "jpeg", "webp", "svg"]
const AUDIO_EXTENSIONS := ["wav", "ogg", "mp3"]
const OFFICIAL_THEME_IDS := ["default", "colorblind", "high_contrast"]
const THEME_SURFACES := ["main", "story"]
const THEME_BANDS := ["black", "gray", "white"]
const THEME_COLOR_KEYS := {
	"main": [
		"panel_bg", "panel_border", "chip_bg", "choice_bg", "choice_hover",
		"disabled_bg", "text", "dim", "brand", "focus",
	],
	"story": [
		"panel_bg", "panel_border", "hud_bg", "choice_bg", "choice_hover",
		"text", "dim", "dead", "focus", "line",
	],
}

static var _language_root_override: String = ""
static var _asset_root_override: String = ""
static var _mod_root_override: String = ""
static var _settings_path_override: String = ""
static var _texture_cache: Dictionary = {}
static var _audio_cache: Dictionary = {}
static var _theme_cache: Dictionary = {}
static var _settings_cache: Dictionary = {}
static var _settings_cached := false

static func configure_test_roots(
		language_root: String,
		asset_root: String,
		mod_root_path: String = "",
		settings_file: String = "") -> void:
	_language_root_override = language_root
	_asset_root_override = asset_root
	_mod_root_override = mod_root_path if not mod_root_path.is_empty() else asset_root.get_base_dir()
	_settings_path_override = settings_file
	notify_settings_changed()
	clear_caches()

static func reset_test_roots() -> void:
	_language_root_override = ""
	_asset_root_override = ""
	_mod_root_override = ""
	_settings_path_override = ""
	notify_settings_changed()
	clear_caches()

static func clear_caches() -> void:
	_texture_cache.clear()
	_audio_cache.clear()
	_theme_cache.clear()

static func notify_settings_changed() -> void:
	_settings_cached = false
	_settings_cache.clear()
	clear_caches()

static func language_root() -> String:
	return _language_root_override if not _language_root_override.is_empty() else LANGUAGE_ROOT

static func asset_root() -> String:
	return _asset_root_override if not _asset_root_override.is_empty() else ASSET_ROOT

static func mod_root() -> String:
	return _mod_root_override if not _mod_root_override.is_empty() else MOD_ROOT

static func event_root() -> String:
	return mod_root().path_join("events")

static func preset_root() -> String:
	return mod_root().path_join("presets")

static func theme_root() -> String:
	return mod_root().path_join("themes")

static func settings_path() -> String:
	return _settings_path_override \
		if not _settings_path_override.is_empty() else BUILD_FLAVOR.settings_path()

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

static func discover_data_mods() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if _directory_has_supported_asset(asset_root(), 0):
		result.append({
			"id": "assets",
			"kind": "assets",
			"name": "Asset overrides",
			"path": asset_root(),
		})
	for path in _json_files(event_root()):
		result.append(_data_mod_info(path, "events"))
	for path in _json_files(preset_root()):
		result.append(_data_mod_info(path, "preset"))
	for path in _json_files(theme_root()):
		var info := _theme_info(path, false)
		if not info.is_empty():
			result.append(info)
	return _ordered_mod_entries(result)

static func enabled_event_pack_paths() -> Array[String]:
	return _enabled_paths_for_kind("events")

static func enabled_preset_paths() -> Array[String]:
	return _enabled_paths_for_kind("preset")

static func available_theme_infos() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for theme_id in OFFICIAL_THEME_IDS:
		var path := BUILTIN_THEME_ROOT.path_join("moral_ui_%s.json" % theme_id)
		var info := _theme_info(path, true)
		if not info.is_empty():
			result.append(info)
	for entry in discover_data_mods():
		if str(entry.get("kind", "")) == "theme" and is_mod_enabled(str(entry.get("id", ""))):
			result.append(entry)
	return result

static func selected_theme_id() -> String:
	var selected := str(_mod_settings().get("moral_palette", "default"))
	for info in available_theme_infos():
		if str(info.get("theme_id", "")) == selected:
			return selected
	return "default"

static func theme_display_name(theme_id: String, language_code: String = "en") -> String:
	for info in available_theme_infos():
		if str(info.get("theme_id", "")) != theme_id:
			continue
		if language_code == "ko":
			return str(info.get("name_ko", info.get("name", theme_id)))
		return str(info.get("name_en", info.get("name", theme_id)))
	return theme_id

static func moral_palette(
		surface: String,
		black_amount: float,
		white_amount: float,
		theme_id: String = "") -> Dictionary:
	var resolved_id := selected_theme_id() if theme_id.is_empty() else theme_id
	var document := _theme_document(resolved_id)
	if document.is_empty() and resolved_id != "default":
		document = _theme_document("default")
	var surfaces: Dictionary = document.get("surfaces", {})
	var surface_data: Dictionary = surfaces.get(surface, {})
	var gray: Dictionary = surface_data.get("gray", {})
	var black: Dictionary = surface_data.get("black", {})
	var white: Dictionary = surface_data.get("white", {})
	var result: Dictionary = {}
	for key in THEME_COLOR_KEYS.get(surface, []):
		var base: Color = Color(str(gray.get(key, "#ffffff")))
		var color: Color = base.lerp(Color(str(black.get(key, gray.get(key, "#ffffff")))), clampf(black_amount, 0.0, 1.0))
		color = color.lerp(Color(str(white.get(key, gray.get(key, "#ffffff")))), clampf(white_amount, 0.0, 1.0))
		result[key] = color
	return result

static func is_mod_enabled(mod_id: String) -> bool:
	if mod_id.is_empty():
		return false
	var raw: Variant = _mod_settings().get("mod_enabled", {})
	if not raw is Dictionary:
		return true
	return bool((raw as Dictionary).get(mod_id, true))

static func mod_load_order() -> Array[String]:
	var result: Array[String] = []
	var raw: Variant = _mod_settings().get("mod_load_order", [])
	if not raw is Array:
		return result
	for value in raw:
		var mod_id := str(value)
		if not mod_id.is_empty() and not result.has(mod_id):
			result.append(mod_id)
	return result

static func has_any_data_mods() -> bool:
	for entry in discover_data_mods():
		var mod_id := str(entry.get("id", ""))
		var kind := str(entry.get("kind", ""))
		if not is_mod_enabled(mod_id):
			continue
		if kind == "theme" and str(entry.get("theme_id", "")) != selected_theme_id():
			continue
		return true
	return false

static func _enabled_paths_for_kind(kind: String) -> Array[String]:
	var result: Array[String] = []
	for entry in discover_data_mods():
		if str(entry.get("kind", "")) != kind:
			continue
		if not is_mod_enabled(str(entry.get("id", ""))):
			continue
		result.append(str(entry.get("path", "")))
	return result

static func _data_mod_info(path: String, kind: String) -> Dictionary:
	var parsed: Variant = _read_json(path)
	var metadata: Dictionary = parsed if parsed is Dictionary else {}
	var stem := path.get_file().get_basename()
	var slug: String = _safe_mod_slug(str(metadata.get("id", stem)))
	if slug.is_empty():
		slug = _safe_mod_slug(stem)
	return {
		"id": "%s:%s" % [kind, slug],
		"kind": kind,
		"name": str(metadata.get("name", stem)),
		"version": str(metadata.get("version", "")),
		"path": path,
	}

static func _ordered_mod_entries(entries: Array[Dictionary]) -> Array[Dictionary]:
	var order := mod_load_order()
	var rank: Dictionary = {}
	for index in range(order.size()):
		rank[order[index]] = index
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var aid := str(a.get("id", ""))
		var bid := str(b.get("id", ""))
		var arank := int(rank.get(aid, 100000))
		var brank := int(rank.get(bid, 100000))
		if arank != brank:
			return arank < brank
		return aid < bid)
	return entries

static func _theme_info(path: String, official: bool) -> Dictionary:
	var parsed: Variant = _read_json(path)
	if not parsed is Dictionary:
		return {}
	var raw_id: String = _safe_mod_slug(str((parsed as Dictionary).get("id", path.get_file().get_basename())))
	if raw_id.is_empty():
		return {}
	if not official and raw_id in OFFICIAL_THEME_IDS:
		raw_id = "mod_%s" % raw_id
	var mod_id := "official_theme:%s" % raw_id if official else "theme:%s" % raw_id
	return {
		"id": mod_id,
		"theme_id": raw_id,
		"kind": "official_theme" if official else "theme",
		"name": str((parsed as Dictionary).get("name_en", raw_id)),
		"name_ko": str((parsed as Dictionary).get("name_ko", raw_id)),
		"name_en": str((parsed as Dictionary).get("name_en", raw_id)),
		"version": str((parsed as Dictionary).get("version", "")),
		"path": path,
	}

static func _theme_document(theme_id: String) -> Dictionary:
	if _theme_cache.has(theme_id):
		return (_theme_cache[theme_id] as Dictionary).duplicate(true)
	var path := ""
	for info in available_theme_infos():
		if str(info.get("theme_id", "")) == theme_id:
			path = str(info.get("path", ""))
			break
	if path.is_empty():
		return {}
	var clean := _sanitize_theme_document(_read_json(path))
	if clean.is_empty():
		push_warning("Ignoring invalid moral palette mod: %s" % path)
		return {}
	_theme_cache[theme_id] = clean
	return clean.duplicate(true)

static func _sanitize_theme_document(raw: Variant) -> Dictionary:
	if not raw is Dictionary:
		return {}
	var source := raw as Dictionary
	var raw_surfaces: Variant = source.get("surfaces", {})
	if not raw_surfaces is Dictionary:
		return {}
	var clean_surfaces: Dictionary = {}
	for surface in THEME_SURFACES:
		var raw_surface: Variant = (raw_surfaces as Dictionary).get(surface, {})
		if not raw_surface is Dictionary:
			return {}
		var clean_surface: Dictionary = {}
		for band in THEME_BANDS:
			var raw_band: Variant = (raw_surface as Dictionary).get(band, {})
			if not raw_band is Dictionary:
				return {}
			var clean_band: Dictionary = {}
			for key in THEME_COLOR_KEYS[surface]:
				var value := str((raw_band as Dictionary).get(key, ""))
				if not value.begins_with("#") or not Color.html_is_valid(value):
					return {}
				clean_band[key] = value
			clean_surface[band] = clean_band
		clean_surfaces[surface] = clean_surface
	return {
		"id": str(source.get("id", "")),
		"name_ko": str(source.get("name_ko", "")),
		"name_en": str(source.get("name_en", "")),
		"version": str(source.get("version", "")),
		"surfaces": clean_surfaces,
	}

static func _json_files(path: String) -> Array[String]:
	var result: Array[String] = []
	var directory := _open_directory(path)
	if directory == null:
		return result
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		if not directory.current_is_dir() and not entry.begins_with(".") and entry.to_lower().ends_with(".json"):
			result.append(path.path_join(entry))
		entry = directory.get_next()
	directory.list_dir_end()
	result.sort()
	return result

static func _safe_mod_slug(value: String) -> String:
	var result := ""
	for i in range(value.length()):
		var cp := value.unicode_at(i)
		if (cp >= 48 and cp <= 57) or (cp >= 97 and cp <= 122) or cp == 45 or cp == 95:
			result += String.chr(cp)
		elif cp >= 65 and cp <= 90:
			result += String.chr(cp + 32)
	return result.trim_prefix("-").trim_prefix("_")

static func _mod_settings() -> Dictionary:
	if _settings_cached:
		return _settings_cache
	_settings_cached = true
	_settings_cache = {}
	var path := settings_path()
	if not FileAccess.file_exists(path):
		return _settings_cache
	var parsed: Variant = _read_json(path)
	if parsed is Dictionary:
		_settings_cache = parsed as Dictionary
	return _settings_cache

static func _read_json(path: String) -> Variant:
	if path.is_empty() or not FileAccess.file_exists(path):
		return null
	return JSON.parse_string(FileAccess.get_file_as_string(path))

static func resolve_asset_override(canonical_path: String) -> String:
	if not is_mod_enabled("assets"):
		return canonical_path
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
	return is_mod_enabled("assets") and _directory_has_supported_asset(asset_root(), 0)

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
	return (
		(not language_code.is_empty() and has_language_pack(language_code))
		or has_any_asset_overrides()
		or has_any_data_mods()
	)

static func active_mod_labels(language_code: String = "") -> Array[String]:
	var labels: Array[String] = []
	if not language_code.is_empty() and has_language_pack(language_code):
		labels.append("lang:%s" % language_code)
	for entry in discover_data_mods():
		var mod_id := str(entry.get("id", ""))
		var kind := str(entry.get("kind", ""))
		if not is_mod_enabled(mod_id):
			continue
		if kind == "theme" and str(entry.get("theme_id", "")) != selected_theme_id():
			continue
		labels.append(mod_id)
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
