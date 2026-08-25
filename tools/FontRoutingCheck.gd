extends Node

const JAPANESE_SAMPLE := "あア漢日本語「。」"
const CHINESE_SAMPLES := {
	"zh-CN": "汉语门里“，。”",
	"zh-TW": "漢語門裡「，。」",
}
const ROLE_WEIGHTS := [
	["regular", FontKit.WEIGHT_REGULAR, FontKit.PRETENDARD_REGULAR_PATH],
	["semibold", FontKit.WEIGHT_SEMIBOLD, FontKit.PRETENDARD_SEMIBOLD_PATH],
	["bold", FontKit.WEIGHT_BOLD, FontKit.PRETENDARD_BOLD_PATH],
]

var _failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	var original_language := LocaleManager.language
	var regular_identity := FontKit.ui_regular()
	_check_no_product_direct_font_loads()
	_check_variable_axis_source()
	_check_pretendard_primary("ko")
	_check_pretendard_primary("en")
	_check_japanese_primary()
	_check_chinese_primary("zh-CN", FontKit.ZH_CN_FONT_PATH)
	_check_chinese_primary("zh-TW", FontKit.ZH_TW_FONT_PATH)
	_check_legacy_fallback_weight()

	# UIStyle owns the runtime signal bridge. Prove that already-built resources
	# change in place instead of requiring every screen to reconstruct its labels.
	# Force the shared role away from JA first; otherwise the earlier static JA
	# inspection would let a disconnected language_changed signal pass vacuously.
	FontKit.configure_language("en")
	LocaleManager.language = "ja"
	LocaleManager.language_changed.emit("ja")
	await get_tree().process_frame
	_expect(FontKit.active_language() == "ja",
		"UIStyle did not route a runtime language change to FontKit.")
	_expect(FontKit.ui_regular() == regular_identity,
		"Locale change replaced the shared regular role resource.")
	_expect(_variation_weight(FontKit.ui_regular().get_rids(), 0)
			== FontKit.WEIGHT_REGULAR,
		"The runtime JA signal did not install Noto Sans JP wght=400 as primary.")
	_expect(ThemeDB.fallback_font == UIStyle.font_regular,
		"ThemeDB fallback stopped sharing UIStyle's locale-aware regular font.")

	LocaleManager.language = original_language
	LocaleManager.language_changed.emit(original_language)
	await get_tree().process_frame
	if not _failures.is_empty():
		for failure in _failures:
			push_error("FONT_ROUTING_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("FONT_ROUTING_CHECK_OK ko_en=Pretendard ja=NotoSansJP zh_cn=NotoSansSC zh_tw=NotoSansTC weights=400,600,700 emoji=last")
	get_tree().quit(0)

func _check_no_product_direct_font_loads() -> void:
	var files: Array[String] = []
	for root_path in [
		"res://autoloads", "res://scenes", "res://systems", "res://ui_components",
	]:
		_collect_gd_files(root_path, files)
	for path in files:
		if path == "res://autoloads/FontKit.gd":
			continue
		var source := FileAccess.get_file_as_string(path)
		for direct_path in [
			"res://assets/fonts/Pretendard-",
			"res://assets/fonts/NotoSansJP-",
			"res://assets/fonts/NotoSansSC-",
			"res://assets/fonts/NotoSansTC-",
			"res://assets/fonts/NotoColorEmoji",
		]:
			_expect(not source.contains(direct_path),
				"Product script bypasses FontKit with a direct font path: %s" % path)

func _collect_gd_files(directory_path: String, output: Array[String]) -> void:
	for filename in DirAccess.get_files_at(directory_path):
		if filename.ends_with(".gd"):
			output.append(directory_path.path_join(filename))
	for child in DirAccess.get_directories_at(directory_path):
		_collect_gd_files(directory_path.path_join(child), output)

func _check_variable_axis_source() -> void:
	for fixture in [
		["Noto Sans JP", FontKit.JP_FONT_PATH],
		["Noto Sans SC", FontKit.ZH_CN_FONT_PATH],
		["Noto Sans TC", FontKit.ZH_TW_FONT_PATH],
	]:
		var family := str(fixture[0])
		var source := load(str(fixture[1])) as Font
		_expect(source != null, "Bundled %s could not be loaded." % family)
		if source == null:
			continue
		var server := TextServerManager.get_primary_interface()
		var weight_tag := server.name_to_tag("wght")
		var supported := source.get_supported_variation_list()
		_expect(supported.has(weight_tag), "Bundled %s has no wght axis." % family)
		if not supported.has(weight_tag):
			continue
		var axis: Vector3 = supported[weight_tag]
		_expect(axis.x == 100.0 and axis.y == 900.0 and axis.z == 100.0,
			"%s wght axis is not min=100/max=900/default=100: %s" % [family, axis])

func _check_pretendard_primary(language: String) -> void:
	FontKit.configure_language(language)
	for fixture in ROLE_WEIGHTS:
		var role := _font_for_weight(int(fixture[1]))
		var pretendard := load(str(fixture[2])) as Font
		_expect(role != null and pretendard != null,
			"%s %s role or Pretendard source is missing." % [language, fixture[0]])
		if role == null or pretendard == null:
			continue
		var rids := role.get_rids()
		var source_rids := pretendard.get_rids()
		_expect(not rids.is_empty() and not source_rids.is_empty()
				and rids[0] == source_rids[0],
			"%s %s did not keep Pretendard as primary." % [language, fixture[0]])
		_expect(_variation_weight(rids, 1) == int(fixture[1]),
			"%s %s Japanese fallback has the wrong weight." % [language, fixture[0]])
		_expect(_last_rid_is_emoji(rids),
			"%s %s did not keep emoji as the final fallback." % [language, fixture[0]])

func _check_japanese_primary() -> void:
	FontKit.configure_language("ja")
	for fixture in ROLE_WEIGHTS:
		var weight := int(fixture[1])
		var role := _font_for_weight(weight)
		var rids := role.get_rids()
		_expect(not rids.is_empty(), "Japanese %s role has no font RID." % fixture[0])
		if rids.is_empty():
			continue
		_expect(_variation_weight(rids, 0) == weight,
			"Japanese %s primary is not Noto Sans JP wght=%d." % [fixture[0], weight])
		var pretendard := load(str(fixture[2])) as Font
		var pretendard_rids := pretendard.get_rids()
		_expect(rids.size() >= 3 and not pretendard_rids.is_empty()
				and rids[1] == pretendard_rids[0],
			"Japanese %s did not keep Pretendard behind the JP primary." % fixture[0])
		_expect(_last_rid_is_emoji(rids),
			"Japanese %s did not keep emoji as the final fallback." % fixture[0])
		var glyph_rids := _shape_font_rids(JAPANESE_SAMPLE, role, "ja")
		_expect(not glyph_rids.is_empty(),
			"Japanese %s representative text produced no glyphs." % fixture[0])
		_expect(glyph_rids.all(func(rid: RID): return rid == rids[0]),
			"Japanese %s mixed Pretendard/Noto glyphs inside one script run." % fixture[0])
		var emoji_rids := _shape_font_rids("🤝", role, "ja")
		_expect(not emoji_rids.is_empty()
				and emoji_rids.all(func(rid: RID): return rid == rids[rids.size() - 1]),
			"Japanese %s emoji did not use the bundled final fallback." % fixture[0])

func _check_chinese_primary(language: String, source_path: String) -> void:
	FontKit.configure_language(language)
	var source := load(source_path) as Font
	_expect(source != null, "%s dedicated font could not be loaded." % language)
	_expect(FontKit.dedicated_locale_font_precedes_jp(language),
		"%s dedicated font is not ordered before the JP fallback." % language)
	for fixture in ROLE_WEIGHTS:
		var weight := int(fixture[1])
		var role := _font_for_weight(weight)
		var rids := role.get_rids()
		_expect(rids.size() >= 4, "%s %s role has an incomplete font chain." % [language, fixture[0]])
		if rids.size() < 4:
			continue
		_expect(_variation_weight(rids, 0) == weight,
			"%s %s primary has the wrong weight." % [language, fixture[0]])
		var variation := role as FontVariation
		_expect(variation != null and variation.base_font == source,
			"%s %s did not keep its dedicated font as primary." % [language, fixture[0]])
		var pretendard := load(str(fixture[2])) as Font
		var pretendard_rids := pretendard.get_rids()
		_expect(not pretendard_rids.is_empty() and rids[1] == pretendard_rids[0],
			"%s %s did not keep Pretendard behind the locale primary." % [language, fixture[0]])
		_expect(_variation_weight(rids, 2) == weight,
			"%s %s JP fallback has the wrong weight." % [language, fixture[0]])
		_expect(_last_rid_is_emoji(rids),
			"%s %s did not keep emoji as the final fallback." % [language, fixture[0]])
		var glyph_rids := _shape_font_rids(str(CHINESE_SAMPLES[language]), role, language)
		_expect(not glyph_rids.is_empty(),
			"%s %s representative text produced no glyphs." % [language, fixture[0]])
		_expect(glyph_rids.all(func(rid: RID): return rid == rids[0]),
			"%s %s mixed fallback glyphs inside one script run." % [language, fixture[0]])

func _check_legacy_fallback_weight() -> void:
	var source := load(FontKit.PRETENDARD_REGULAR_PATH) as FontFile
	if source == null:
		_expect(false, "Pretendard regular could not be loaded for legacy fallback inspection.")
		return
	var legacy := source.duplicate(true) as FontFile
	legacy.fallbacks = []
	FontKit.attach_emoji_fallback(legacy)
	var rids := legacy.get_rids()
	_expect(rids.size() >= 3, "Legacy font chain is missing JP or emoji fallback.")
	_expect(_variation_weight(rids, 1) == FontKit.WEIGHT_REGULAR,
		"Legacy JP fallback used the variable font's Thin default instead of 400.")
	_expect(_last_rid_is_emoji(rids), "Legacy emoji fallback is not last.")

func _font_for_weight(weight: int) -> Font:
	match weight:
		FontKit.WEIGHT_SEMIBOLD:
			return FontKit.ui_semibold()
		FontKit.WEIGHT_BOLD:
			return FontKit.ui_bold()
	return FontKit.ui_regular()

func _variation_weight(rids: Array[RID], index: int) -> int:
	if index < 0 or index >= rids.size():
		return -1
	var server := TextServerManager.get_primary_interface()
	var coordinates := server.font_get_variation_coordinates(rids[index])
	return int(coordinates.get(server.name_to_tag("wght"), -1))

func _last_rid_is_emoji(rids: Array[RID]) -> bool:
	var emoji := load(FontKit.EMOJI_FONT_PATH) as Font
	if emoji == null or rids.is_empty():
		return false
	var emoji_rids := emoji.get_rids()
	return not emoji_rids.is_empty() and rids[rids.size() - 1] == emoji_rids[0]

func _shape_font_rids(text: String, font: Font, language: String) -> Array[RID]:
	var result: Array[RID] = []
	var server := TextServerManager.get_primary_interface()
	var shaped := server.create_shaped_text()
	server.shaped_text_add_string(shaped, text, font.get_rids(), 32, {}, language)
	for glyph in server.shaped_text_get_glyphs(shaped):
		var rid: RID = glyph.get("font_rid", RID())
		if rid.is_valid():
			result.append(rid)
	server.free_rid(shaped)
	return result

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
