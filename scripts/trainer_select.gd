extends Control

const FONT: FontFile = preload("res://assets/fonts/SourceHanSansSC-Heavy.otf")
const DESIGN_SIZE := Vector2(1280, 720)
const FULL_HD_SCALE := Vector2(0.5, 0.5)
const TRAINERS: Array[Dictionary] = [
	{
		"id": "researcher",
		"name": "森野博士",
		"title": "生态研究员",
		"art": "res://assets/characters/trainers/trainer_green.png",
		"passive": "野外补给：初始金币 +2",
		"color": Color("4f9d69"),
	},
	{
		"id": "vanguard",
		"name": "赤城",
		"title": "先锋训练家",
		"art": "res://assets/characters/trainers/trainer_red.png",
		"passive": "斗志昂扬：本轮全队伤害 +6%",
		"color": Color("c94e4e"),
	},
	{
		"id": "scout",
		"name": "紫苑",
		"title": "遗迹探索者",
		"art": "res://assets/characters/trainers/trainer_yellow.png",
		"passive": "可靠伙伴：初始获得一只普通怪兽",
		"color": Color("b79338"),
	},
]

var selected_index := 0
var cards: Array[Panel] = []
var confirm_button: Button


func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = Vector2.ZERO
	size = DESIGN_SIZE
	scale = FULL_HD_SCALE
	MusicManager.play_music("res://assets/audio/pixel_mountain_quest.mp3", 1.2)
	_build_ui()
	_refresh_selection()


func _build_ui() -> void:
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("101923")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var title := _label("选择本次远征的训练家", Rect2(0, 35, 1280, 58), 36, Color.WHITE)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var subtitle := _label("每位训练家拥有不同的开局能力", Rect2(0, 92, 1280, 35), 19, Color("b9c5d2"))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for index in TRAINERS.size():
		_build_trainer_card(index)
	confirm_button = Button.new()
	confirm_button.position = Vector2(470, 626)
	confirm_button.size = Vector2(340, 64)
	confirm_button.text = "选择并开始远征"
	_style_button(confirm_button, Color("ef466f"))
	confirm_button.pressed.connect(_confirm_selection)
	add_child(confirm_button)


func _build_trainer_card(index: int) -> void:
	var data := TRAINERS[index]
	var card := Panel.new()
	card.position = Vector2(100 + index * 370, 145)
	card.size = Vector2(340, 450)
	card.add_theme_stylebox_override("panel", _panel_style(Color("f2f3f5"), Color("747985"), 5))
	add_child(card)
	cards.append(card)
	var portrait_frame := Panel.new()
	portrait_frame.position = Vector2(22, 22)
	portrait_frame.size = Vector2(296, 300)
	portrait_frame.clip_contents = true
	portrait_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_frame.add_theme_stylebox_override("panel", _panel_style(Color("dfe6e8"), data["color"], 4))
	card.add_child(portrait_frame)
	var art := TextureRect.new()
	art.position = Vector2(4, -8)
	art.size = Vector2(288, 410)
	art.texture = load(String(data["art"])) as Texture2D
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_frame.add_child(art)
	var portrait_border := Panel.new()
	portrait_border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_border.z_index = 3
	portrait_border.add_theme_stylebox_override("panel", _panel_style(Color.TRANSPARENT, data["color"], 4))
	portrait_frame.add_child(portrait_border)
	var name_label := _label(String(data["name"]), Rect2(18, 330, 304, 38), 24, Color("252a32"))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.reparent(card, false)
	var title_label := _label(String(data["title"]), Rect2(18, 368, 304, 28), 16, data["color"])
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.reparent(card, false)
	var passive := _label(String(data["passive"]), Rect2(22, 402, 296, 35), 15, Color("3f4650"))
	passive.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	passive.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	passive.reparent(card, false)
	var card_border := Panel.new()
	card_border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_border.z_index = 5
	card_border.add_theme_stylebox_override("panel", _panel_style(Color.TRANSPARENT, data["color"], 5))
	card.add_child(card_border)
	var hit := Button.new()
	hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hit.flat = true
	hit.focus_mode = Control.FOCUS_NONE
	hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hit.pressed.connect(_select_trainer.bind(index))
	card.add_child(hit)


func _select_trainer(index: int) -> void:
	selected_index = index
	_refresh_selection()


func _refresh_selection() -> void:
	for index in cards.size():
		var data := TRAINERS[index]
		var selected := index == selected_index
		cards[index].add_theme_stylebox_override("panel", _panel_style(Color("fffdf6") if selected else Color("f2f3f5"), data["color"] if selected else Color("747985"), 8 if selected else 5))
		var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(cards[index], "scale", Vector2(1.035, 1.035) if selected else Vector2.ONE, 0.18)


func _confirm_selection() -> void:
	confirm_button.disabled = true
	var data := TRAINERS[selected_index]
	GameState.apply_trainer_choice(String(data["id"]))
	GameState.save_run()
	var curtain := ColorRect.new()
	curtain.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	curtain.color = Color(0, 0, 0, 0)
	curtain.z_index = 100
	add_child(curtain)
	var fade := create_tween()
	fade.tween_property(curtain, "color:a", 1.0, 0.45)
	await fade.finished
	get_tree().change_scene_to_file("res://map.tscn")


func _label(text: String, rect: Rect2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.text = text
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color("20242b"))
	label.add_theme_constant_override("outline_size", 1)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label


func _style_button(button: Button, color: Color) -> void:
	button.add_theme_font_override("font", FONT)
	button.add_theme_font_size_override("font_size", 24)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_outline_color", Color.BLACK)
	button.add_theme_constant_override("outline_size", 1)
	button.add_theme_stylebox_override("normal", _panel_style(color, Color("2b2e36"), 4))
	button.add_theme_stylebox_override("hover", _panel_style(color.lightened(0.12), Color.WHITE, 4))
	button.add_theme_stylebox_override("pressed", _panel_style(color.darkened(0.12), Color("2b2e36"), 4))


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
