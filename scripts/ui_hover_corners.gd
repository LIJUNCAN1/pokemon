class_name UIHoverCorners
extends Control

const CORNER_TEXTURES: Array[Texture2D] = [
	preload("res://assets/ui/pixel_menu/hover_corners/corner-top-left.png"),
	preload("res://assets/ui/pixel_menu/hover_corners/corner-top-right.png"),
	preload("res://assets/ui/pixel_menu/hover_corners/corner-bottom-left.png"),
	preload("res://assets/ui/pixel_menu/hover_corners/corner-bottom-right.png"),
]

var animation: Tween
var hovering := false


func configure(coordinate_scale := 1.0) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 20
	modulate.a = 0.0
	scale = Vector2(0.82, 0.82)
	pivot_offset = size * 0.5

	for child in get_children():
		child.queue_free()

	for index in CORNER_TEXTURES.size():
		var texture := CORNER_TEXTURES[index]
		var corner := TextureRect.new()
		corner.texture = texture
		corner.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		corner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		corner.stretch_mode = TextureRect.STRETCH_KEEP
		corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		corner.size = texture.get_size() * coordinate_scale
		match index:
			0:
				corner.position = Vector2.ZERO
			1:
				corner.position = Vector2(size.x - corner.size.x, 0.0)
			2:
				corner.position = Vector2(0.0, size.y - corner.size.y)
			3:
				corner.position = size - corner.size
		add_child(corner)


func show_animated() -> void:
	if hovering:
		return
	hovering = true
	if animation and animation.is_valid():
		animation.kill()
	visible = true
	pivot_offset = size * 0.5
	scale = Vector2(0.82, 0.82)
	modulate.a = 1.0
	animation = create_tween().set_loops()
	animation.tween_property(self, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	animation.tween_property(self, "scale", Vector2(0.82, 0.82), 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func hide_animated() -> void:
	hovering = false
	if animation and animation.is_valid():
		animation.kill()
	scale = Vector2(0.82, 0.82)
	modulate.a = 0.0
	visible = false
