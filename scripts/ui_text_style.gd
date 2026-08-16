extends Node

# One typography rule for every current and future black/white UI label.
# It mirrors the tutorial dialogue: Source Han Sans Heavy, a one-pixel shadow,
# and no competing outline. Coloured rarity/status text is intentionally left
# untouched.
const FONT: FontFile = preload("res://assets/fonts/SourceHanSansSC-Heavy.otf")
const DARK_TEXT := Color("282d35")
const LIGHT_TEXT := Color.WHITE
const DARK_SHADOW := Color("c9cbd0")
const LIGHT_SHADOW := Color(0.08, 0.10, 0.14, 0.72)


func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)
	_apply_branch(get_tree().root)


func _on_node_added(node: Node) -> void:
	_apply_control.call_deferred(node)


func _apply_branch(node: Node) -> void:
	_apply_control(node)
	for child in node.get_children():
		_apply_branch(child)


func _apply_control(node: Node) -> void:
	if not is_instance_valid(node):
		return
	if _shadow_disabled(node):
		return
	if node is Label:
		_style_label(node as Label)
	elif node is Button:
		_style_button(node as Button)
	elif node is RichTextLabel:
		_style_rich_text(node as RichTextLabel)


func _shadow_disabled(node: Node) -> bool:
	var current := node
	while current != null:
		if current.has_meta("disable_text_shadow") and bool(current.get_meta("disable_text_shadow")):
			return true
		current = current.get_parent()
	return false


func _style_label(label: Label) -> void:
	var color := label.get_theme_color("font_color")
	var mode := _neutral_mode(color)
	if mode == 0:
		return
	label.add_theme_font_override("font", FONT)
	_apply_shadow(label, mode > 0)


func _style_button(button: Button) -> void:
	var color := button.get_theme_color("font_color")
	var mode := _neutral_mode(color)
	if mode == 0:
		return
	button.add_theme_font_override("font", FONT)
	var shadow := LIGHT_SHADOW if mode > 0 else DARK_SHADOW
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
		var state_color := button.get_theme_color(state)
		if _neutral_mode(state_color) != 0:
			button.add_theme_color_override(state, state_color)
	button.add_theme_color_override("font_shadow_color", shadow)
	button.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	button.add_theme_constant_override("outline_size", 0)
	button.add_theme_constant_override("shadow_offset_x", 1)
	button.add_theme_constant_override("shadow_offset_y", 1)


func _style_rich_text(label: RichTextLabel) -> void:
	var color := label.get_theme_color("default_color")
	var mode := _neutral_mode(color)
	if mode == 0:
		return
	label.add_theme_font_override("normal_font", FONT)
	_apply_shadow(label, mode > 0)


func _apply_shadow(control: Control, light_text: bool) -> void:
	control.add_theme_color_override("font_shadow_color", LIGHT_SHADOW if light_text else DARK_SHADOW)
	control.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	control.add_theme_constant_override("outline_size", 0)
	control.add_theme_constant_override("shadow_offset_x", 1)
	control.add_theme_constant_override("shadow_offset_y", 1)


func _neutral_mode(color: Color) -> int:
	var highest := maxf(color.r, maxf(color.g, color.b))
	var lowest := minf(color.r, minf(color.g, color.b))
	if highest - lowest > 0.10:
		return 0
	var luminance := color.get_luminance()
	if luminance >= 0.78:
		return 1
	if luminance <= 0.38:
		return -1
	return 0
