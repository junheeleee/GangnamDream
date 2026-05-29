extends PanelContainer

signal dismissed()

@onready var label: Label = Label.new()
var lifetime = 2.4

func _ready():
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#0f172a")
	style.border_color = Color("#f97316")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left   = 16
	style.content_margin_right  = 16
	style.content_margin_top    = 10
	style.content_margin_bottom = 10
	add_theme_stylebox_override("panel", style)
	add_child(label)
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color("#dbe7ff"))
	if UIStyle.font_regular:
		label.add_theme_font_override("font", UIStyle.font_regular)

func show_message(message, color):
	label.text = message
	label.add_theme_color_override("font_color", color)
	var tween = create_tween()
	modulate.a = 0.0
	tween.tween_property(self, "modulate:a", 1.0, 0.16)
	tween.tween_interval(lifetime)
	tween.tween_property(self, "modulate:a", 0.0, 0.22)
	tween.finished.connect(_dismiss)

func _dismiss():
	dismissed.emit()
	queue_free()
