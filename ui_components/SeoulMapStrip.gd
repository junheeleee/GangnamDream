extends Control
## Non-interactive Seoul trace used by the AP rail header.

var _locations: Array = []
var _visits: Dictionary = {}
var _recent: Array = []
var _gangnam_progress: float = 0.0
var _font_regular: Font = null
var _font_bold: Font = null
var _colors: Dictionary = {}

const _ROUTES: Array = [
	["home", "store"],
	["store", "work"],
	["work", "river"],
	["river", "city"],
	["city", "underground"],
	["city", "expedition"],
	["city", "gangnam"],
]

func setup(locations: Array, visits: Dictionary, recent: Array, gangnam_progress: float,
		regular_font: Font, bold_font: Font, colors: Dictionary) -> void:
	_locations = locations.duplicate(true)
	_visits = visits.duplicate(true)
	_recent = recent.duplicate()
	_gangnam_progress = clampf(gangnam_progress, 0.0, 1.0)
	_font_regular = regular_font
	_font_bold = bold_font
	_colors = colors.duplicate()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _ready() -> void:
	resized.connect(queue_redraw)
	queue_redraw()

func _draw() -> void:
	if _locations.is_empty() or size.x < 120.0:
		return
	var points: Dictionary = _node_points()
	var line_color: Color = _color("line", Color("#59616d", 0.46))
	line_color.a = 0.42
	for route in _ROUTES:
		var from_id: String = str(route[0])
		var to_id: String = str(route[1])
		if points.has(from_id) and points.has(to_id):
			draw_line(points[from_id], points[to_id], line_color, 1.0, true)
	_draw_recent_trace(points)
	for location in _locations:
		_draw_node(location, points[str(location.get("id", ""))])

func _node_points() -> Dictionary:
	var out: Dictionary = {}
	var y_pattern: Array[float] = [9.0, 13.0, 8.0, 12.0, 7.0, 14.0, 10.0, 6.0]
	var usable_width: float = maxf(1.0, size.x - 20.0)
	for i in range(_locations.size()):
		var location: Dictionary = _locations[i]
		var x: float = 10.0 + usable_width * float(i) / float(maxi(1, _locations.size() - 1))
		out[str(location.get("id", ""))] = Vector2(x, y_pattern[mini(i, y_pattern.size() - 1)])
	return out

func _draw_recent_trace(points: Dictionary) -> void:
	var path := PackedVector2Array()
	for raw_id in _recent:
		var place_id: String = str(raw_id)
		if place_id != "gangnam" and points.has(place_id):
			path.append(points[place_id])
	if path.size() < 2:
		return
	var trace_color: Color = _color("trace", Color("#9099a5"))
	trace_color.a = 0.34
	draw_polyline(path, trace_color, 1.4, true)

func _draw_node(location: Dictionary, point: Vector2) -> void:
	var place_id: String = str(location.get("id", ""))
	var locked: bool = bool(location.get("locked", false))
	var visit: Dictionary = _visits.get(place_id, {})
	var was_recent: bool = _recent.has(place_id)
	var current_id: String = _current_place_id()
	var node_color: Color = _visit_color(visit)
	if locked:
		node_color = _color("dim", Color("#5f6772"))
		node_color.a = 0.24
	elif visit.is_empty() and not was_recent:
		node_color = _color("dim", Color("#5f6772"))
		node_color.a = 0.48
	elif visit.is_empty():
		node_color.a = 0.66

	if place_id == "gangnam":
		var gangnam_color: Color = _color("current", Color("#edf2f7"))
		gangnam_color.a = 0.18 + _gangnam_progress * 0.72
		draw_arc(point, 5.2, -PI * 0.5, -PI * 0.5 + TAU * maxf(0.035, _gangnam_progress), 20, gangnam_color, 1.5, true)
		draw_circle(point, 2.1 + _gangnam_progress * 1.8, gangnam_color)
	else:
		draw_circle(point, 3.7 if not visit.is_empty() else 2.6, node_color)

	if place_id == current_id and not locked:
		var ring: Color = _color("current", Color("#edf2f7"))
		ring.a = 0.88
		draw_arc(point, 6.3, 0.0, TAU, 24, ring, 1.15, true)

	var font: Font = _font_bold if place_id == current_id and _font_bold != null else _font_regular
	if font == null:
		font = ThemeDB.fallback_font
	var font_size: int = 10 if size.x >= 560.0 else 9
	var label_color: Color = _color("text", Color("#aeb6c2"))
	if locked:
		label_color = _color("dim", Color("#5f6772"))
		label_color.a = 0.42
	elif place_id == current_id:
		label_color = _color("current", Color("#edf2f7"))
	elif place_id == "gangnam":
		label_color.a = 0.42 + _gangnam_progress * 0.52
	var label_width: float = minf(82.0, size.x / float(maxi(1, _locations.size())) + 8.0)
	var label_x: float = clampf(point.x - label_width * 0.5, 0.0, size.x - label_width)
	draw_string(font, Vector2(label_x, size.y - 2.0), str(location.get("label", "")),
		HORIZONTAL_ALIGNMENT_CENTER, label_width, font_size, label_color)

func _current_place_id() -> String:
	for i in range(_recent.size() - 1, -1, -1):
		var place_id: String = str(_recent[i])
		if _visits.has(place_id):
			return place_id
	return "home"

func _visit_color(visit: Dictionary) -> Color:
	var money: int = int(visit.get("money", 0))
	var human: int = int(visit.get("human", 0))
	if money > 0 and human > 0:
		return _color("mixed", Color("#d9e0e8"))
	if human > 0:
		return _color("human", Color("#c09b96"))
	if money > 0:
		return _color("money", Color("#c3a56b"))
	return _color("trace", Color("#9099a5"))

func _color(key: String, fallback: Color) -> Color:
	var value: Variant = _colors.get(key, fallback)
	return value if value is Color else fallback
