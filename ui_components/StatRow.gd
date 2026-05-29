extends HBoxContainer

var name_label  = Label.new()
var value_label = Label.new()

func _ready():
	add_theme_constant_override("separation", 8)

	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.add_theme_color_override("font_color", Color("#a0aec0"))

	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.custom_minimum_size   = Vector2(60, 0)
	value_label.add_theme_font_size_override("font_size", 13)

	if UIStyle.font_regular:
		name_label.add_theme_font_override("font",  UIStyle.font_regular)
		value_label.add_theme_font_override("font", UIStyle.font_regular)

	add_child(name_label)
	add_child(value_label)

func configure(label_text, value_text, color):
	name_label.text  = label_text
	value_label.text = value_text
	value_label.add_theme_color_override("font_color", color)
