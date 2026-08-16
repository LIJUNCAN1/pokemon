class_name RarityTagStyle
extends RefCounted


const NAMES := ["普通", "优秀", "稀有", "史诗", "传说"]
const KEYS := ["common", "uncommon", "rare", "epic", "legendary"]
const TEXT_COLORS := [
	Color("607c9e"),
	Color("c7f8c9"),
	Color("5da6de"),
	Color("d0b5ff"),
	Color("ffd0a6"),
]
const ROOT := "res://assets/ui/rarity_tags/"


static func normalized_index(rarity: int) -> int:
	return clampi(rarity, 0, KEYS.size() - 1)


static func display_name(rarity: int) -> String:
	return NAMES[normalized_index(rarity)]


static func text_color(rarity: int) -> Color:
	return TEXT_COLORS[normalized_index(rarity)]


static func texture(rarity: int) -> Texture2D:
	return load(ROOT + KEYS[normalized_index(rarity)] + ".png") as Texture2D


static func style(rarity: int) -> StyleBoxTexture:
	var result := StyleBoxTexture.new()
	result.texture = texture(rarity)
	result.draw_center = true
	result.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	result.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	return result


static func apply(label: Label, rarity: int) -> void:
	label.text = display_name(rarity)
	label.add_theme_color_override("font_color", text_color(rarity))
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	label.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 0)
	label.add_theme_constant_override("outline_size", 0)
	label.add_theme_stylebox_override("normal", style(rarity))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
