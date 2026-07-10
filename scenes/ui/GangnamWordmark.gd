class_name GangnamWordmark
extends VBoxContainer

const FONT_BOLD := preload("res://assets/fonts/Pretendard-Bold.ttf")
const FONT_REGULAR := preload("res://assets/fonts/Pretendard-Regular.ttf")

var _title_color := Color("#edf0f3")
var _detail_color := Color("#8e98a4")


func _init(font_size: int = 66, subtitle: String = "") -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	add_theme_constant_override("separation", 2)

	add_child(_make_window_rule(font_size))

	var rows: Array = ["GANGNAM", "DREAM"] if LocaleManager.is_english() else ["강남", "드림"]
	for row_index in rows.size():
		add_child(_make_letter_row(rows[row_index], font_size, row_index))

	add_child(_make_broken_baseline(font_size))

	if not subtitle.is_empty():
		var caption := Label.new()
		caption.text = subtitle
		caption.add_theme_font_override("font", FONT_REGULAR)
		caption.add_theme_font_size_override("font_size", clampi(font_size / 5, 7, 11))
		caption.add_theme_color_override("font_color", _detail_color)
		caption.autowrap_mode = TextServer.AUTOWRAP_OFF
		caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(caption)


func _make_letter_row(text: String, font_size: int, row_index: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	var max_spacing := 5 if LocaleManager.is_english() else 8
	row.add_theme_constant_override("separation", clampi(font_size / 12, 1, max_spacing))
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for index in text.length():
		var glyph := Label.new()
		glyph.text = text.substr(index, 1)
		glyph.add_theme_font_override("font", FONT_BOLD)
		glyph.add_theme_font_size_override("font_size", font_size)
		glyph.add_theme_color_override("font_color", _title_color)
		glyph.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.58))
		glyph.add_theme_constant_override("shadow_offset_x", 2)
		glyph.add_theme_constant_override("shadow_offset_y", 2)
		glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if row_index == 1 and index == text.length() - 1:
			glyph.add_theme_color_override("font_color", Color("#d7dce2"))
		row.add_child(glyph)
	return row


func _make_window_rule(font_size: int) -> HBoxContainer:
	var rule := HBoxContainer.new()
	rule.add_theme_constant_override("separation", 6)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rule.add_child(_segment(maxi(20, font_size / 2), 2, Color("#aeb6c0")))
	rule.add_child(_segment(5, 2, Color("#535d69")))
	rule.add_child(_segment(maxi(42, font_size), 2, Color("#697480")))
	return rule


func _make_broken_baseline(font_size: int) -> HBoxContainer:
	var rule := HBoxContainer.new()
	rule.add_theme_constant_override("separation", 7)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rule.add_child(_segment(maxi(74, font_size * 2), 1, Color("#77818c")))
	rule.add_child(_segment(9, 1, Color(0, 0, 0, 0)))
	rule.add_child(_segment(maxi(28, font_size / 2), 1, Color("#3e4752")))
	return rule


func _segment(width: int, height: int, color: Color) -> ColorRect:
	var segment := ColorRect.new()
	segment.color = color
	segment.custom_minimum_size = Vector2(width, height)
	segment.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return segment
