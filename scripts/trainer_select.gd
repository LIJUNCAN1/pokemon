extends Control

const FONT: FontFile = preload("res://assets/fonts/SourceHanSansSC-Heavy.otf")
const TRAINER_SELECT_ROOT := "res://assets/ui/trainer_select/"
const TRAINER_PSD_ROOT := "res://assets/ui/trainer_select/psd_exact/"
const TRAINER_CARD_TINT_SHADER: Shader = preload("res://shaders/trainer_card_hue.gdshader")
const MENU_BUTTON_NORMAL: Texture2D = preload("res://assets/ui/pixel_menu/controls/button-normal.png")
const MENU_BUTTON_PRESSED: Texture2D = preload("res://assets/ui/pixel_menu/controls/button-pressed.png")
const TRAIT_ICON_PATHS: Dictionary = {
	"火": "res://assets/ui/trait_icons/new_set/fire.png",
	"自然": "res://assets/ui/trait_icons/new_set/nature.png",
	"植物": "res://assets/ui/trait_icons/new_set/plant.png",
	"雷": "res://assets/ui/trait_icons/new_set/lightning.png",
}
const DESIGN_SIZE := Vector2(1280, 720)
const FULL_HD_SCALE := Vector2(0.5, 0.5)
const CARD_SOURCE_SIZE := Vector2(296, 407)
const CARD_SIZE := Vector2(339, 465)
const CARD_START := Vector2(92, 135)
const CARD_STEP_X := 379.0
const TRAINERS: Array[Dictionary] = [
	{
		"id": "researcher",
		"name": "森野博士",
		"title": "生态研究员",
		"art": TRAINER_PSD_ROOT + "portrait_green.png",
		"passive_prefix": "野外补给：初始金币 ",
		"passive_value": "+2",
		"passive_suffix": "",
		"color": Color("4f9d69"),
		"hue": 0.42,
		"element": "植物",
		"icon_offset": Vector2(-1, 0),
	},
	{
		"id": "vanguard",
		"name": "赤城",
		"title": "先锋训练家",
		"art": TRAINER_PSD_ROOT + "portrait_red.png",
		"passive_prefix": "斗志昂扬：本轮全队伤害 ",
		"passive_value": "+6%",
		"passive_suffix": "",
		"color": Color("c94e4e"),
		"hue": 0.0,
		"element": "火",
		"icon_offset": Vector2(0, -1),
	},
	{
		"id": "scout",
		"name": "紫苑",
		"title": "遗迹探索者",
		"art": TRAINER_PSD_ROOT + "portrait_yellow.png",
		"passive_prefix": "可靠伙伴：初始获得一只普通怪兽",
		"passive_value": "",
		"passive_suffix": "",
		"color": Color("b79338"),
		"hue": 0.13,
		"element": "雷",
		"icon_offset": Vector2(0, 2),
	},
]

var selected_index := 0
var cards: Array[Panel] = []
var confirm_button: Button


func _ready() -> void:
	set_meta("disable_text_shadow", true)
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = Vector2.ZERO
	size = DESIGN_SIZE
	scale = FULL_HD_SCALE
	MusicManager.play_music("res://assets/audio/pixel_mountain_quest.mp3", 1.2)
	_build_ui()
	_refresh_selection()


func _build_ui() -> void:
	var background := TextureRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.texture = load(TRAINER_SELECT_ROOT + "background.png") as Texture2D
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	background.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var title := _label("选择本次远征的训练家", Rect2(0, 28, 1280, 58), 36, Color.WHITE)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var subtitle := _label("每位训练家拥有不同的开局能力", Rect2(0, 84, 1280, 35), 19, Color("b9c5d2"))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for index in TRAINERS.size():
		_build_trainer_card(index)
	confirm_button = Button.new()
	confirm_button.position = Vector2(468, 632)
	confirm_button.size = Vector2(344, 64)
	confirm_button.text = "选择并开始远征"
	_style_button(confirm_button, Color("ef466f"))
	confirm_button.pressed.connect(_confirm_selection)
	add_child(confirm_button)


func _build_trainer_card(index: int) -> void:
	var data := TRAINERS[index]
	var card := Panel.new()
	card.name = "TrainerCard%d" % index
	card.position = CARD_START + Vector2(index * CARD_STEP_X, 0)
	card.size = CARD_SIZE
	card.pivot_offset = card.size * 0.5
	card.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	add_child(card)
	cards.append(card)
	var psd_rect := Rect2(Vector2.ZERO, CARD_SIZE)
	var base := _texture(card, TRAINER_PSD_ROOT + "layer_02.png", psd_rect)
	var inner_background := _texture(card, TRAINER_PSD_ROOT + "layer_08.png", psd_rect)
	var tint_material := _tint_material(data["color"])
	base.material = _tint_material(data["color"])
	inner_background.material = tint_material
	base.z_index = 1
	inner_background.z_index = 2
	var watermark := _texture(card, TRAIT_ICON_PATHS[data["element"]], _card_rect(Rect2(30, 75, 92, 120)))
	watermark.modulate = Color(data["color"], 0.18)
	watermark.z_index = 3
	var portrait_clip := Control.new()
	portrait_clip.name = "PortraitClip"
	portrait_clip.position = Vector2.ZERO
	portrait_clip.size = card.size
	portrait_clip.clip_contents = true
	portrait_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# The updated PSD places the trainer artwork above every authored frame.
	portrait_clip.z_index = 20
	card.add_child(portrait_clip)
	var art := TextureRect.new()
	art.name = "Portrait"
	# Use a deliberately oversized portrait and let the clip container cut the
	# lower half.  This matches the supplied reference card: the head/torso
	# rises above the inner frame while the lower body never enters the white
	# name area.
	art.position = Vector2.ZERO
	art.size = card.size
	art.texture = load(String(data["art"])) as Texture2D
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_clip.add_child(art)
	var inner_frame := _texture(card, TRAINER_PSD_ROOT + "layer_07.png", psd_rect)
	inner_frame.material = _tint_material(data["color"])
	inner_frame.z_index = 5
	var badge_border := _texture(card, TRAINER_PSD_ROOT + "layer_06.png", psd_rect)
	badge_border.material = _tint_material(data["color"])
	badge_border.z_index = 6
	var badge_fill := _texture(card, TRAINER_PSD_ROOT + "layer_05.png", psd_rect)
	badge_fill.material = _tint_material(data["color"])
	badge_fill.z_index = 7
	var icon_position := Vector2(23, 23) + Vector2(data["icon_offset"])
	var element_icon := _texture(card, TRAIT_ICON_PATHS[data["element"]], _card_rect(Rect2(icon_position, Vector2(20, 20))))
	element_icon.texture = load(TRAIT_ICON_PATHS[data["element"]]) as Texture2D
	element_icon.modulate = Color.WHITE
	element_icon.z_index = 30
	var name_label := _label(String(data["name"]), _card_rect(Rect2(46, 278, 204, 31)), 22, Color("252a32"))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.reparent(card, false)
	var title_label := _label(String(data["title"]), _card_rect(Rect2(46, 307, 204, 23)), 14, data["color"])
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.reparent(card, false)
	var passive_frame := _texture(card, TRAINER_PSD_ROOT + "layer_03.png", psd_rect)
	passive_frame.material = _tint_material(data["color"])
	passive_frame.z_index = 6
	var outer_accent := _texture(card, TRAINER_PSD_ROOT + "layer_04.png", psd_rect)
	outer_accent.material = _tint_material(data["color"])
	outer_accent.z_index = 7
	var passive := _rich_label(_passive_bbcode(data), _card_rect(Rect2(27, 359, 242, 18)), 11, Color("252a32"))
	passive.reparent(card, false)
	var hit := Button.new()
	hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hit.flat = true
	# The hit target must not paint its default white button surface over the
	# card labels and icons.  Keep it behind the authored layers while it still
	# receives pointer input.
	hit.z_index = -10
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		hit.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	hit.focus_mode = Control.FOCUS_NONE
	hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hit.pressed.connect(_select_trainer.bind(index))
	card.add_child(hit)
	card.move_child(hit, card.get_child_count() - 1)
	name_label.z_index = 9
	title_label.z_index = 9
	passive.z_index = 9
	element_icon.z_index = 9
	var selection := Panel.new()
	selection.position = Vector2(2, 2)
	selection.size = CARD_SIZE - Vector2(4, 4)
	selection.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selection.z_index = 12
	selection.add_theme_stylebox_override("panel", _panel_style(Color.TRANSPARENT, data["color"], 5))
	selection.visible = false
	card.add_child(selection)
	card.set_meta("selection", selection)
	card.set_meta("tint_materials", [tint_material])


func _select_trainer(index: int) -> void:
	selected_index = index
	_refresh_selection()


func _refresh_selection() -> void:
	for index in cards.size():
		var selected := index == selected_index
		var selection: Panel = cards[index].get_meta("selection") as Panel
		selection.visible = false
		cards[index].z_index = 40 if selected else 0
		var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(cards[index], "scale", Vector2(1.055, 1.055) if selected else Vector2.ONE, 0.18)


func _confirm_selection() -> void:
	confirm_button.disabled = true
	var data := TRAINERS[selected_index]
	GameState.apply_trainer_choice(String(data["id"]))
	GameState.save_run()
	await SceneManager.change_scene("res://map.tscn")


func _label(text: String, rect: Rect2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.text = text
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	label.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	label.add_theme_constant_override("outline_size", 0)
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 0)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label


func _rich_label(bbcode: String, rect: Rect2, font_size: int, color: Color) -> RichTextLabel:
	var label := RichTextLabel.new()
	label.position = rect.position
	label.size = rect.size
	label.bbcode_enabled = true
	label.text = "[center]%s[/center]" % bbcode
	label.fit_content = false
	label.scroll_active = false
	label.add_theme_font_override("normal_font", FONT)
	label.add_theme_font_override("bold_font", FONT)
	label.add_theme_font_size_override("normal_font_size", font_size)
	label.add_theme_font_size_override("bold_font_size", font_size)
	label.add_theme_color_override("default_color", color)
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	label.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	label.add_theme_constant_override("outline_size", 0)
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 0)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label


func _passive_bbcode(data: Dictionary) -> String:
	var value := String(data["passive_value"])
	var highlighted := ""
	if not value.is_empty():
		highlighted = "[color=#%s]%s[/color]" % [Color(data["color"]).to_html(false), value]
	return "%s%s%s" % [data["passive_prefix"], highlighted, data["passive_suffix"]]


func _card_rect(source_rect: Rect2) -> Rect2:
	var ratio := CARD_SIZE / CARD_SOURCE_SIZE
	return Rect2(source_rect.position * ratio, source_rect.size * ratio)


func _texture(parent: Control, path: String, rect: Rect2) -> TextureRect:
	var layer := TextureRect.new()
	layer.position = rect.position
	layer.size = rect.size
	layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	layer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	layer.texture = load(path if path.begins_with("res://") else TRAINER_SELECT_ROOT + path) as Texture2D
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(layer)
	return layer


func _tint_material(color: Color) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = TRAINER_CARD_TINT_SHADER
	material.set_shader_parameter("accent_color", color)
	return material


func _style_button(button: Button, color: Color) -> void:
	button.add_theme_font_override("font", FONT)
	button.add_theme_font_size_override("font_size", 24)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	button.add_theme_constant_override("outline_size", 0)
	button.add_theme_constant_override("shadow_offset_x", 0)
	button.add_theme_constant_override("shadow_offset_y", 0)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.focus_mode = Control.FOCUS_NONE
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	_install_main_menu_button_visual(button)


func _install_main_menu_button_visual(button: Button) -> void:
	var button_text := button.text
	button.text = ""
	var display_scale := button.size.x / MENU_BUTTON_NORMAL.get_width()
	var visual := TextureRect.new()
	visual.name = "PixelBackground"
	visual.texture = MENU_BUTTON_NORMAL
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	visual.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	visual.stretch_mode = TextureRect.STRETCH_KEEP
	visual.size = MENU_BUTTON_NORMAL.get_size()
	visual.scale = Vector2.ONE * display_scale
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual.show_behind_parent = true
	button.add_child(visual)
	var label := _label(button_text, Rect2(Vector2.ZERO, button.size), 22, Color.WHITE)
	label.name = "PixelLabel"
	label.reparent(button, false)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var center_visual := func(pressed := false) -> void:
		var texture := MENU_BUTTON_PRESSED if pressed else MENU_BUTTON_NORMAL
		visual.texture = texture
		visual.position.x = (button.size.x - texture.get_width() * display_scale) * 0.5
		visual.position.y = (button.size.y - texture.get_height() * display_scale) * 0.5 + (1.0 if pressed else 0.0)
		label.position.y = 1.0 if pressed else 0.0
	button.button_down.connect(center_visual.bind(true))
	button.button_up.connect(center_visual.bind(false))
	button.mouse_exited.connect(func() -> void: center_visual.call(false))
	center_visual.call(false)


func _panel_style(fill: Color, border: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	return style
