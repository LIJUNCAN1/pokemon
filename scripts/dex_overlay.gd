extends Control

const SOURCE_HAN_FONT: FontFile = preload("res://assets/fonts/SourceHanSansSC-Heavy.otf")
const CATALOG = preload("res://scripts/creature_catalog.gd")
const DEX := "res://素材/图鉴/"
const POKEMON := "res://素材/宝可梦图/"
const CREATURES: Array[String] = [
	POKEMON + "1 (1).png", POKEMON + "1 (2).png", POKEMON + "1 (3).png", POKEMON + "1 (4).png",
	POKEMON + "1 (5).png", POKEMON + "1 (6).png", POKEMON + "1 (7).png", POKEMON + "1 (8).png",
	POKEMON + "1 (9).png", POKEMON + "1 (10).png", POKEMON + "图层 2.png", POKEMON + "图层 3.png",
	POKEMON + "图层 4.png", POKEMON + "图层 5.png", POKEMON + "图层 6.png",
]
const NAMES: Array[String] = [
	"芽叶兽", "钢甲象", "烛灵", "岩甲龟", "夜翼兽", "冰角鹿",
	"菌盖兽", "深海贤者", "绵云羊", "烈焰犬", "花叶兽", "铁壳蛛",
	"星云兽", "花甲虫", "熔岩蛛",
]
const TAB_NAMES: Array[String] = ["怪兽", "饰品", "道具", "训练家"]
const INACTIVE_TABS: Array[String] = [DEX + "03_切图_3.png", DEX + "03_切图_3.png", DEX + "04_切图_4.png", DEX + "05_切图_5.png"]
const TRAINER_TEXTURES: Array[String] = [
	"res://素材/主菜单/03_image-1785665935144-ihuz4v0r8x.png",
	"res://素材/主菜单/04_image-1785665946324-sdmjaqsxe3.png",
	"res://素材/主菜单/01_image-1785665922217-kl0enxabtzl.png",
]
const TRAINER_NAMES: Array[String] = ["银羽", "小岚", "晴"]
const TRAINER_SKILLS: Array[String] = [
	"每回合首次刷新返还 1 枚金币",
	"队伍中的自然角色获得额外生命",
	"每回合购买的第一只怪兽费用降低",
]

var source_han_font: FontFile
var tab_buttons: Array[TextureButton] = []
var monster_scroll: ScrollContainer
var monster_page: Control
var scroll_thumb: TextureRect
var empty_label: Label
var detail_root: Control
var detail_outer_frame: NinePatchRect
var detail_sprite: TextureRect
var detail_name: Label
var detail_type: Label
var detail_cooldown: Label
var detail_stats: Label
var detail_description: Label
var detail_unknown: Label
var selection_frames: Array[TextureRect] = []
var creature_cards: Array[Control] = []
var trainer_cards: Array[Control] = []
var trainer_selection_frames: Array[TextureRect] = []
var card_creature_sprites: Array[TextureRect] = []
var card_name_labels: Array[Label] = []
var card_unknown_labels: Array[Label] = []
var card_trophy_icons: Array[TextureRect] = []
var card_medal_icons: Array[TextureRect] = []
var card_star_icons: Array[TextureRect] = []
var counter_labels: Array[Label] = []
var selected_index := 0
var selected_trainer_index := 0
var current_tab := 0


func _ready() -> void:
	if get_parent() is Control:
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		position = Vector2.ZERO
		size = Vector2(1280, 720)
		scale = Vector2(1.5, 1.5)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 150
	source_han_font = SOURCE_HAN_FONT.duplicate() as FontFile
	source_han_font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	source_han_font.hinting = TextServer.HINTING_NORMAL
	source_han_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	source_han_font.oversampling = 1.5
	source_han_font.allow_system_fallback = false
	_build_interface()
	refresh_data()


func _build_interface() -> void:
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.025, 0.045, 0.07, 0.96)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)

	var outer := Panel.new()
	outer.position = Vector2(4, 42)
	outer.size = Vector2(1272, 635)
	outer.add_theme_stylebox_override("panel", _panel_style(Color(0.96, 0.96, 0.95), Color(0.23, 0.23, 0.24), 4))
	add_child(outer)

	_build_detail_panel()
	_build_tabs()
	_build_collection_panel()
	_build_counters()


func _build_detail_panel() -> void:
	detail_root = Control.new()
	detail_root.position = Vector2(8, 48)
	detail_root.size = Vector2(300, 613)
	add_child(detail_root)
	_add_color(detail_root, Color(0.98, 0.98, 0.98, 1.0), Rect2(Vector2.ZERO, detail_root.size))
	detail_outer_frame = _add_nine_patch(detail_root, DEX + "图鉴左栏_外框_九宫格.png", Rect2(Vector2.ZERO, detail_root.size), 8)
	_add_color(detail_root, Color("d77d00"), Rect2(8, 8, 284, 35))
	detail_name = _add_label(detail_root, "", Rect2(16, 12, 150, 26), 14)
	_add_label(detail_root, "稀有", Rect2(198, 12, 84, 26), 13, HORIZONTAL_ALIGNMENT_RIGHT)

	_add_info_frame(detail_root, Rect2(8, 49, 284, 160))
	_add_info_frame(detail_root, Rect2(20, 61, 112, 136))
	detail_sprite = _add_texture(detail_root, CREATURES[0], Rect2(30, 72, 92, 112))
	detail_unknown = _add_label(detail_root, "?", Rect2(30, 72, 92, 112), 42, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(detail_unknown)
	detail_unknown.visible = false
	_add_texture(detail_root, DEX + "图层 5（合并）.png", Rect2(166, 105, 96, 37), TextureRect.STRETCH_SCALE)
	detail_type = _add_label(detail_root, "", Rect2(166, 109, 96, 28), 13, HORIZONTAL_ALIGNMENT_CENTER)

	_add_info_frame(detail_root, Rect2(8, 217, 284, 102))
	_add_info_frame(detail_root, Rect2(20, 229, 78, 78))
	detail_cooldown = _add_label(detail_root, "", Rect2(26, 238, 66, 60), 14, HORIZONTAL_ALIGNMENT_CENTER)
	detail_stats = _add_label(detail_root, "", Rect2(112, 240, 158, 56), 14, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(detail_cooldown)
	_use_dark_text(detail_stats)

	_add_info_frame(detail_root, Rect2(8, 327, 284, 110))
	detail_description = _add_label(detail_root, "", Rect2(22, 340, 256, 84), 13, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(detail_description)
	detail_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	_add_info_frame(detail_root, Rect2(8, 445, 284, 36))
	var shift_hint := _add_label(detail_root, "SHIFT  长按查看更多信息", Rect2(18, 449, 264, 28), 12)
	_use_dark_text(shift_hint)

	for index in 4:
		var path := DEX + ("image-1785682708652-8ni6x6cdnyo.png" if index == 0 else "%02d_切图_%d.png" % [17 + index, 17 + index])
		var button := _add_texture_button(path, Rect2(27 + index * 68, 510, 60, 38), "等级 %d" % (index + 1), detail_root)
		button.pressed.connect(_on_level_pressed.bind(index))
		_add_label(detail_root, "Lv%d" % (index + 1), Rect2(27 + index * 68, 515, 60, 28), 12, HORIZONTAL_ALIGNMENT_CENTER)
	_add_texture(detail_root, DEX + "24_切图_24.png", Rect2(27, 560, 264, 37), TextureRect.STRETCH_SCALE)
	_add_label(detail_root, "闪光", Rect2(27, 563, 264, 28), 13, HORIZONTAL_ALIGNMENT_CENTER)


func _build_tabs() -> void:
	for index in 4:
		var button := _add_texture_button(DEX + ("02_切图_2.png" if index == 0 else "%02d_切图_%d.png" % [index + 2, index + 2]), Rect2(397 + index * 208, 48, 199, 43), TAB_NAMES[index])
		button.pressed.connect(_on_tab_pressed.bind(index))
		tab_buttons.append(button)
		_add_label(self, TAB_NAMES[index], Rect2(397 + index * 208, 50, 199, 36), 23, HORIZONTAL_ALIGNMENT_CENTER)
	var close := _add_texture_button(DEX + "06_切图_6.png", Rect2(1228, 48, 43, 43), "关闭")
	close.pressed.connect(_close)


func _build_collection_panel() -> void:
	_add_color(self, Color(0.99, 0.99, 0.99, 1.0), Rect2(317, 101, 953, 500))
	monster_scroll = ScrollContainer.new()
	monster_scroll.position = Vector2(326, 109)
	monster_scroll.size = Vector2(908, 484)
	monster_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	monster_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	monster_scroll.clip_contents = true
	add_child(monster_scroll)
	monster_page = Control.new()
	monster_page.custom_minimum_size = Vector2(892, 690)
	monster_page.size = monster_page.custom_minimum_size
	monster_scroll.add_child(monster_page)
	for index in CREATURES.size():
		var column := index % 4
		var row := index / 4
		_create_creature_card(index, Rect2(12 + column * 221, 10 + row * 171, 205, 152))
	for index in TRAINER_TEXTURES.size():
		_create_trainer_card(index, Rect2(12 + index * 221, 10, 205, 152))

	var native_scrollbar := monster_scroll.get_v_scroll_bar()
	native_scrollbar.modulate.a = 0.0
	native_scrollbar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	native_scrollbar.value_changed.connect(_on_collection_scrolled)
	_add_nine_patch(self, DEX + "图鉴右栏_外框_前景.png", Rect2(317, 101, 953, 500), 14)
	_add_texture(self, DEX + "1.png", Rect2(1243, 113, 16, 474), TextureRect.STRETCH_SCALE)
	scroll_thumb = _add_atlas_texture(self, DEX + "2.png", Rect2(1248, 118, 7, 82), Rect2(5, 173, 7, 44))
	_update_scroll_thumb()

	empty_label = _add_label(self, "", Rect2(430, 295, 730, 80), 20, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(empty_label)
	empty_label.visible = false


func _create_creature_card(index: int, rect: Rect2) -> void:
	var card := Control.new()
	card.position = rect.position
	card.size = rect.size
	monster_page.add_child(card)
	creature_cards.append(card)
	_add_texture(card, DEX + "13_切图_13.png", Rect2(Vector2.ZERO, rect.size), TextureRect.STRETCH_SCALE)
	var creature_sprite := _add_texture(card, CREATURES[index], Rect2(18, 15, 125, 98))
	var unknown_label := _add_label(card, "?", Rect2(18, 15, 125, 98), 36, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(unknown_label)
	var trophy := _add_texture(card, DEX + "image-1785683743659-hcg3y7d2ca2.png", Rect2(151, 16, 32, 32))
	var medal := _add_texture(card, DEX + "image-1785683749088-mt9x4axmxfo2.png", Rect2(154, 55, 27, 32))
	var star := _add_texture(card, DEX + "image-1785683749811-6btmw25d8ow2.png", Rect2(153, 96, 29, 29))
	var name_label := _add_label(card, "?", Rect2(12, 115, 132, 28), 12, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(name_label)
	card_creature_sprites.append(creature_sprite)
	card_unknown_labels.append(unknown_label)
	card_trophy_icons.append(trophy)
	card_medal_icons.append(medal)
	card_star_icons.append(star)
	card_name_labels.append(name_label)
	var selection := _add_texture(card, DEX + "image-1785681904517-raawndjoah.png", Rect2(2, 2, rect.size.x - 4, rect.size.y - 4), TextureRect.STRETCH_SCALE)
	selection.visible = index == 0
	selection_frames.append(selection)
	var hit := Button.new()
	hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hit.flat = true
	hit.focus_mode = Control.FOCUS_NONE
	hit.tooltip_text = NAMES[index]
	hit.pressed.connect(_select_creature.bind(index))
	card.add_child(hit)


func _create_trainer_card(index: int, rect: Rect2) -> void:
	var card := Control.new()
	card.position = rect.position
	card.size = rect.size
	card.visible = false
	monster_page.add_child(card)
	trainer_cards.append(card)
	_add_texture(card, DEX + "13_切图_13.png", Rect2(Vector2.ZERO, rect.size), TextureRect.STRETCH_SCALE)
	_add_texture(card, TRAINER_TEXTURES[index], Rect2(26, 13, 153, 108))
	var name_label := _add_label(card, TRAINER_NAMES[index], Rect2(16, 116, 173, 28), 14, HORIZONTAL_ALIGNMENT_CENTER)
	_use_dark_text(name_label)
	var selection := _add_texture(card, DEX + "image-1785681904517-raawndjoah.png", Rect2(2, 2, rect.size.x - 4, rect.size.y - 4), TextureRect.STRETCH_SCALE)
	selection.visible = index == 0
	trainer_selection_frames.append(selection)
	var hit := Button.new()
	hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hit.flat = true
	hit.focus_mode = Control.FOCUS_NONE
	hit.tooltip_text = TRAINER_NAMES[index]
	hit.pressed.connect(_select_trainer.bind(index))
	card.add_child(hit)


func _select_trainer(index: int) -> void:
	selected_trainer_index = clampi(index, 0, TRAINER_TEXTURES.size() - 1)
	detail_sprite.texture = load(TRAINER_TEXTURES[selected_trainer_index]) as Texture2D
	detail_unknown.visible = false
	detail_name.text = TRAINER_NAMES[selected_trainer_index]
	detail_type.text = "训练家"
	detail_cooldown.text = "被动"
	detail_stats.text = "训练家能力"
	detail_description.text = TRAINER_SKILLS[selected_trainer_index]
	for frame_index in trainer_selection_frames.size():
		trainer_selection_frames[frame_index].visible = frame_index == selected_trainer_index


func _build_counters() -> void:
	var paths := ["21_切图_21.png", "22_切图_22.png", "23_切图_23.png"]
	var texts := ["0/%d" % CREATURES.size(), "0/%d" % CREATURES.size(), "0/%d" % CREATURES.size()]
	for index in 3:
		var x := 408.0 + index * 260.0
		_add_texture(self, DEX + paths[index], Rect2(x, 611, 245, 55), TextureRect.STRETCH_SCALE)
		var counter := _add_label(self, texts[index], Rect2(x + 62, 618, 126, 38), 23, HORIZONTAL_ALIGNMENT_CENTER)
		_use_dark_text(counter)
		counter_labels.append(counter)


func _select_creature(index: int) -> void:
	selected_index = index
	if not GameState.has_seen_creature(CREATURES[index]):
		detail_sprite.texture = null
		detail_unknown.visible = true
		detail_name.text = "?"
		detail_type.text = "未知"
		detail_cooldown.text = "?"
		detail_stats.text = "未知"
		detail_description.text = "尚未遇见该怪兽"
		for frame_index in selection_frames.size():
			selection_frames[frame_index].visible = frame_index == index
		return
	detail_sprite.texture = load(CREATURES[index]) as Texture2D
	detail_unknown.visible = false
	detail_name.text = NAMES[index]
	var traits: PackedStringArray = CATALOG.traits_for_texture(CREATURES[index])
	detail_type.text = "%s·%s" % [traits[0], traits[1]]
	detail_cooldown.text = "%.1f\n秒" % [4.0 + index * 0.2]
	detail_stats.text = "技能强度  %d" % [20 + index * 3]
	detail_description.text = "释放技能时\n为队伍提供%s与%s加成" % [traits[0], traits[1]]
	for frame_index in selection_frames.size():
		selection_frames[frame_index].visible = frame_index == index


func _on_tab_pressed(index: int) -> void:
	current_tab = index
	for button_index in tab_buttons.size():
		tab_buttons[button_index].texture_normal = load(DEX + "02_切图_2.png" if button_index == index else INACTIVE_TABS[button_index]) as Texture2D
	monster_page.visible = index == 0 or index == 3
	for card in creature_cards:
		card.visible = index == 0
	for card in trainer_cards:
		card.visible = index == 3
	empty_label.visible = index == 1 or index == 2
	if index == 1 or index == 2:
		empty_label.text = "%s页素材尚未提供" % TAB_NAMES[index]
	elif index == 0:
		_select_creature(selected_index)
	else:
		_select_trainer(selected_trainer_index)
	monster_scroll.scroll_vertical = 0


func _on_collection_scrolled(_value: float) -> void:
	_update_scroll_thumb()


func _update_scroll_thumb() -> void:
	if scroll_thumb == null or monster_scroll == null:
		return
	var bar := monster_scroll.get_v_scroll_bar()
	var scroll_range := maxf(bar.max_value - bar.page, 1.0)
	var ratio := clampf(bar.value / scroll_range, 0.0, 1.0)
	scroll_thumb.position.y = 118.0 + ratio * 382.0


func _on_level_pressed(level_index: int) -> void:
	if current_tab != 0:
		return
	if not GameState.has_seen_creature(CREATURES[selected_index]):
		return
	detail_stats.text = "Lv%d  技能强度 %d" % [level_index + 1, 20 + selected_index * 3 + level_index * 8]


func refresh_data() -> void:
	var trophy_count := 0
	var medal_count := 0
	var star_count := 0
	for index in CREATURES.size():
		var seen := GameState.has_seen_creature(CREATURES[index])
		var mask := GameState.creature_achievement_mask(CREATURES[index])
		card_creature_sprites[index].visible = seen
		card_unknown_labels[index].visible = not seen
		card_name_labels[index].text = NAMES[index] if seen else "?"
		card_trophy_icons[index].texture = load(DEX + ("image-1785683743659-hcg3y7d2ca.png" if mask & GameState.ACHIEVEMENT_TROPHY else "image-1785683743659-hcg3y7d2ca2.png")) as Texture2D
		card_medal_icons[index].texture = load(DEX + ("image-1785683749088-mt9x4axmxfo.png" if mask & GameState.ACHIEVEMENT_MEDAL else "image-1785683749088-mt9x4axmxfo2.png")) as Texture2D
		card_star_icons[index].texture = load(DEX + ("image-1785683749811-6btmw25d8ow.png" if mask & GameState.ACHIEVEMENT_STAR else "image-1785683749811-6btmw25d8ow2.png")) as Texture2D
		trophy_count += 1 if mask & GameState.ACHIEVEMENT_TROPHY else 0
		medal_count += 1 if mask & GameState.ACHIEVEMENT_MEDAL else 0
		star_count += 1 if mask & GameState.ACHIEVEMENT_STAR else 0
	if counter_labels.size() == 3:
		counter_labels[0].text = "%d/%d" % [trophy_count, CREATURES.size()]
		counter_labels[1].text = "%d/%d" % [medal_count, CREATURES.size()]
		counter_labels[2].text = "%d/%d" % [star_count, CREATURES.size()]
	_select_creature(clampi(selected_index, 0, CREATURES.size() - 1))


func _close() -> void:
	visible = false


func _add_texture(parent: Control, path: String, rect: Rect2, stretch := TextureRect.STRETCH_KEEP_ASPECT_CENTERED) -> TextureRect:
	var texture := TextureRect.new()
	texture.position = rect.position
	texture.size = rect.size
	texture.texture = load(path) as Texture2D
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = stretch
	texture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(texture)
	return texture


func _add_atlas_texture(parent: Control, path: String, rect: Rect2, region: Rect2) -> TextureRect:
	var atlas := AtlasTexture.new()
	atlas.atlas = load(path) as Texture2D
	atlas.region = region
	var texture := TextureRect.new()
	texture.position = rect.position
	texture.size = rect.size
	texture.texture = atlas
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = TextureRect.STRETCH_SCALE
	texture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(texture)
	return texture


func _add_texture_button(path: String, rect: Rect2, tooltip: String, parent: Control = null) -> TextureButton:
	var button := TextureButton.new()
	button.position = rect.position
	button.size = rect.size
	button.texture_normal = load(path) as Texture2D
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	button.tooltip_text = tooltip
	(parent if parent != null else self).add_child(button)
	return button


func _add_color(parent: Control, color: Color, rect: Rect2) -> ColorRect:
	var panel := ColorRect.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.color = color
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(panel)
	return panel


func _add_nine_patch(parent: Control, path: String, rect: Rect2, margin: int) -> NinePatchRect:
	var frame := NinePatchRect.new()
	frame.position = rect.position
	frame.size = rect.size
	frame.texture = load(path) as Texture2D
	frame.patch_margin_left = margin
	frame.patch_margin_top = margin
	frame.patch_margin_right = margin
	frame.patch_margin_bottom = margin
	frame.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_STRETCH
	frame.axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_STRETCH
	frame.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(frame)
	return frame


func _add_info_frame(parent: Control, rect: Rect2) -> NinePatchRect:
	_add_color(parent, Color(0.99, 0.99, 0.99, 1.0), rect)
	return _add_nine_patch(parent, DEX + "图鉴左栏_信息框_九宫格.png", rect, 14)


func _add_label(parent: Control, text: String, rect: Rect2, font_size: int, alignment := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.text = text
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", source_han_font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 1)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


func _use_dark_text(label: Label) -> void:
	label.add_theme_color_override("font_color", Color("202127"))
	label.add_theme_color_override("font_shadow_color", Color(0.47, 0.48, 0.52, 0.88))
	label.add_theme_color_override("font_outline_color", Color("202127"))


func _panel_style(fill: Color, border: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	return style
