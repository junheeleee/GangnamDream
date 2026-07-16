class_name JunpacMark
extends Control
## Transparent, resolution-independent JUNPAC GAMES publisher lockup.
## The crescent and impact square are drawn in-engine so the launch mark stays
## crisp at Steam Deck, television, and 4K resolutions without a black JPEG box.

const DESIGN_SIZE := Vector2(430.0, 330.0)
const AMBER_DARK := Color("#b66f0b")
const AMBER_GOLD := Color("#ffc107")
const AMBER_LIGHT := Color("#ffe29a")
const EMBER_RED := Color("#e63946")
const INK_WHITE := Color("#eeeae1")

var _wordmark: Label
var _games: Label
var _font: FontFile
var _font_bold: FontFile

func _init() -> void:
	name = "JunpacMark"
	custom_minimum_size = DESIGN_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_meta("publisher_mark_kind", "code_native")
	set_meta("publisher_mark_transparent", true)

func _ready() -> void:
	_font = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile
	FontKit.attach_emoji_fallback(_font)
	FontKit.attach_emoji_fallback(_font_bold)
	_build_labels()
	resized.connect(_layout_mark)
	_layout_mark()
	queue_redraw()

func _build_labels() -> void:
	_wordmark = Label.new()
	_wordmark.name = "Wordmark"
	_wordmark.text = "J U N P A C"
	_wordmark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_wordmark.add_theme_font_size_override("font_size", 30)
	_wordmark.add_theme_color_override("font_color", INK_WHITE)
	if _font:
		_wordmark.add_theme_font_override("font", _font)
	add_child(_wordmark)

	_games = Label.new()
	_games.name = "Games"
	_games.text = "G A M E S"
	_games.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_games.add_theme_font_size_override("font_size", 14)
	_games.add_theme_color_override("font_color", AMBER_GOLD)
	if _font_bold:
		_games.add_theme_font_override("font", _font_bold)
	add_child(_games)

func _layout_mark() -> void:
	if not is_instance_valid(_wordmark):
		return
	var scale_factor := minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	var content_width := 330.0 * scale_factor
	var left := (size.x - content_width) * 0.5
	_wordmark.position = Vector2(left, 224.0 * scale_factor)
	_wordmark.size = Vector2(content_width, 48.0 * scale_factor)
	_wordmark.add_theme_font_size_override("font_size", maxi(18, int(30.0 * scale_factor)))
	_games.position = Vector2(left, 274.0 * scale_factor)
	_games.size = Vector2(content_width, 30.0 * scale_factor)
	_games.add_theme_font_size_override("font_size", maxi(10, int(14.0 * scale_factor)))
	queue_redraw()

func _draw() -> void:
	var scale_factor := minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	if scale_factor <= 0.0:
		return
	var design_offset := (size - DESIGN_SIZE * scale_factor) * 0.5
	# The reference mark is a tall, asymmetric crescent with two sharp tips,
	# rather than a circular C. A closed Bezier silhouette keeps its cutout
	# genuinely transparent at every output resolution.
	var crescent := _crescent_points(design_offset, scale_factor)
	draw_colored_polygon(crescent, AMBER_GOLD)
	var upper_highlight := _cubic_points(
		design_offset + Vector2(231.0, 19.0) * scale_factor,
		design_offset + Vector2(176.0, 29.0) * scale_factor,
		design_offset + Vector2(132.0, 68.0) * scale_factor,
		design_offset + Vector2(126.0, 116.0) * scale_factor,
		24)
	draw_polyline(upper_highlight, AMBER_LIGHT, maxf(1.0, 2.4 * scale_factor), true)
	var lower_shadow := _cubic_points(
		design_offset + Vector2(126.0, 116.0) * scale_factor,
		design_offset + Vector2(128.0, 170.0) * scale_factor,
		design_offset + Vector2(205.0, 213.0) * scale_factor,
		design_offset + Vector2(263.0, 202.0) * scale_factor,
		28)
	draw_polyline(lower_shadow, AMBER_DARK, maxf(1.0, 2.2 * scale_factor), true)
	var square_size := 18.0 * scale_factor
	var square_pos := design_offset + Vector2(278.0, 167.0) * scale_factor
	draw_rect(Rect2(square_pos, Vector2(square_size, square_size)), EMBER_RED, true)

func _crescent_points(design_offset: Vector2, scale_factor: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var top := design_offset + Vector2(231.0, 19.0) * scale_factor
	var left := design_offset + Vector2(126.0, 116.0) * scale_factor
	var bottom := design_offset + Vector2(263.0, 202.0) * scale_factor
	points.append_array(_cubic_points(
		top,
		design_offset + Vector2(176.0, 29.0) * scale_factor,
		design_offset + Vector2(132.0, 68.0) * scale_factor,
		left,
		24))
	var lower_outer := _cubic_points(
		left,
		design_offset + Vector2(128.0, 170.0) * scale_factor,
		design_offset + Vector2(205.0, 213.0) * scale_factor,
		bottom,
		28)
	for index in range(1, lower_outer.size()):
		points.append(lower_outer[index])
	# The inner boundary bows left at the waist, creating the heavy lower arc
	# and the fine upper point visible in the approved brand reference.
	var inner := _cubic_points(
		bottom,
		design_offset + Vector2(174.0, 190.0) * scale_factor,
		design_offset + Vector2(150.0, 66.0) * scale_factor,
		top,
		42)
	for index in range(1, inner.size()):
		points.append(inner[index])
	return points

func _cubic_points(
		start: Vector2,
		control_a: Vector2,
		control_b: Vector2,
		end: Vector2,
		segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(segments + 1):
		var t := float(index) / float(segments)
		var inverse := 1.0 - t
		points.append(
			inverse * inverse * inverse * start
			+ 3.0 * inverse * inverse * t * control_a
			+ 3.0 * inverse * t * t * control_b
			+ t * t * t * end)
	return points
